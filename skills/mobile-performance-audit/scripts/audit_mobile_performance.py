#!/usr/bin/env python3
"""Static evidence scanner for Capacitor Android performance audits.

The scanner is intentionally conservative. It discovers repository structure,
known dependencies, build modules, and risky source patterns. Its output is a
set of leads that must be reviewed in context before being reported as defects.

Usage:
    python audit_mobile_performance.py --frontend /path/to/mobile
    python audit_mobile_performance.py --frontend /path/to/mobile \
        --backend /path/to/backend --output audit.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Iterable


TEXT_EXTENSIONS = {
    ".cjs",
    ".css",
    ".gradle",
    ".html",
    ".java",
    ".js",
    ".json",
    ".jsx",
    ".kt",
    ".kts",
    ".md",
    ".mjs",
    ".scss",
    ".ts",
    ".tsx",
    ".vue",
    ".xml",
    ".yaml",
    ".yml",
}

DEFAULT_IGNORED_PARTS = {
    ".git",
    ".gradle",
    ".idea",
    ".next",
    ".nuxt",
    ".output",
    ".turbo",
    ".vite",
    "build",
    "coverage",
    "dist",
    "node_modules",
    "out",
    "target",
}

OBSERVABILITY_PACKAGES = {
    "sentry": (
        "@sentry/capacitor",
        "@sentry/react",
        "@sentry/vue",
        "@sentry/angular",
        "@sentry/node",
        "@sentry/nestjs",
    ),
    "grafana-faro": ("@grafana/faro-web-sdk", "@grafana/faro-react"),
    "opentelemetry": (
        "@opentelemetry/api",
        "@opentelemetry/sdk-node",
        "@opentelemetry/sdk-trace-web",
        "@opentelemetry/auto-instrumentations-node",
    ),
    "firebase-performance": ("@capacitor-firebase/performance",),
    "firebase-crashlytics": ("@capacitor-firebase/crashlytics",),
}

VIRTUALIZATION_PACKAGES = {
    "@tanstack/react-virtual",
    "react-window",
    "react-virtualized",
    "vue-virtual-scroller",
    "@angular/cdk",
}

SOURCE_GLOBS = (
    "src",
    "app",
    "pages",
    "components",
    "features",
    "lib",
    "server",
    "backend",
    "android",
)


@dataclass
class Finding:
    finding_id: str
    title: str
    severity: str
    evidence: str
    repository: str
    location: str
    observation: str
    impact: str
    required_change: str
    verification: str
    category: str


class AuditState:
    def __init__(self) -> None:
        self.findings: list[Finding] = []
        self._counter = 1

    def add(
        self,
        *,
        title: str,
        severity: str,
        evidence: str,
        repository: str,
        location: str,
        observation: str,
        impact: str,
        required_change: str,
        verification: str,
        category: str,
    ) -> None:
        self.findings.append(
            Finding(
                finding_id=f"MPA-{self._counter:03d}",
                title=title,
                severity=severity,
                evidence=evidence,
                repository=repository,
                location=location,
                observation=observation,
                impact=impact,
                required_change=required_change,
                verification=verification,
                category=category,
            )
        )
        self._counter += 1


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--frontend", required=True, help="Path to mobile frontend repository")
    parser.add_argument("--backend", help="Optional path to backend repository")
    parser.add_argument("--config", help="Optional mobile-performance.config.json")
    parser.add_argument("--output", help="Write JSON output to this file")
    parser.add_argument("--markdown-output", help="Write a concise Markdown lead report")
    parser.add_argument(
        "--max-file-bytes",
        type=int,
        default=1_500_000,
        help="Skip source files larger than this many bytes during content scanning",
    )
    return parser.parse_args()


def load_json(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"Could not read JSON file {path}: {exc}") from exc
    if not isinstance(data, dict):
        raise ValueError(f"Expected JSON object in {path}")
    return data


def load_config(path: str | None) -> dict[str, Any]:
    if not path:
        return {}
    return load_json(Path(path).resolve())


def path_is_ignored(path: Path, root: Path, ignored_parts: set[str], ignored_paths: list[str]) -> bool:
    try:
        relative = path.relative_to(root)
    except ValueError:
        return True

    if any(part in ignored_parts for part in relative.parts):
        return True

    relative_posix = relative.as_posix()
    for ignored in ignored_paths:
        normalized = ignored.strip("/")
        if normalized and (relative_posix == normalized or relative_posix.startswith(normalized + "/")):
            return True
    return False


def iter_text_files(
    root: Path,
    ignored_parts: set[str],
    ignored_paths: list[str],
    max_file_bytes: int,
) -> Iterable[Path]:
    for current_root, dir_names, file_names in os.walk(root):
        current = Path(current_root)
        dir_names[:] = [
            name
            for name in dir_names
            if name not in ignored_parts
            and not path_is_ignored(current / name, root, ignored_parts, ignored_paths)
        ]
        for file_name in file_names:
            path = current / file_name
            if path_is_ignored(path, root, ignored_parts, ignored_paths):
                continue
            if path.suffix.lower() not in TEXT_EXTENSIONS and file_name not in {
                "Dockerfile",
                "gradlew",
            }:
                continue
            try:
                if path.stat().st_size > max_file_bytes:
                    continue
            except OSError:
                continue
            yield path


def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return ""


def relative_location(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)


def package_manifest(root: Path) -> tuple[dict[str, Any], Path | None]:
    candidates = [root / "package.json"]
    for name in ("frontend", "mobile", "app", "server", "backend"):
        candidates.append(root / name / "package.json")
    for candidate in candidates:
        if candidate.is_file():
            try:
                return load_json(candidate), candidate
            except ValueError:
                return {}, candidate
    return {}, None


def all_dependencies(manifest: dict[str, Any]) -> set[str]:
    result: set[str] = set()
    for key in ("dependencies", "devDependencies", "peerDependencies", "optionalDependencies"):
        values = manifest.get(key, {})
        if isinstance(values, dict):
            result.update(str(name) for name in values)
    return result


def detect_framework(dependencies: set[str]) -> str:
    if "@angular/core" in dependencies:
        return "Angular"
    if "vue" in dependencies:
        return "Vue"
    if "react" in dependencies:
        return "React"
    if "svelte" in dependencies or "@sveltejs/kit" in dependencies:
        return "Svelte"
    if "solid-js" in dependencies:
        return "SolidJS"
    return "unknown"


def detect_backend_framework(dependencies: set[str]) -> str:
    if "@nestjs/core" in dependencies:
        return "NestJS"
    if "fastify" in dependencies:
        return "Fastify"
    if "express" in dependencies:
        return "Express"
    if "hono" in dependencies:
        return "Hono"
    if "next" in dependencies:
        return "Next.js"
    return "unknown"


def detect_providers(dependencies: set[str], combined_text: str) -> list[str]:
    providers: list[str] = []
    lower_text = combined_text.lower()
    for provider, packages in OBSERVABILITY_PACKAGES.items():
        if any(package in dependencies for package in packages):
            providers.append(provider)
            continue
        markers = {
            "sentry": ("sentry.init", "@sentry/"),
            "grafana-faro": ("initializefaro", "@grafana/faro"),
            "opentelemetry": ("opentelemetry", "trace.gettracer"),
            "firebase-performance": ("getperformance(", "firebase/performance"),
            "firebase-crashlytics": ("crashlytics",),
        }[provider]
        if any(marker in lower_text for marker in markers):
            providers.append(provider)
    return sorted(set(providers))


def collect_text_index(
    root: Path,
    ignored_parts: set[str],
    ignored_paths: list[str],
    max_file_bytes: int,
) -> tuple[list[Path], str, dict[str, str]]:
    files = list(iter_text_files(root, ignored_parts, ignored_paths, max_file_bytes))
    contents: dict[str, str] = {}
    combined_parts: list[str] = []
    for path in files:
        text = read_text(path)
        relative = relative_location(path, root)
        contents[relative] = text
        combined_parts.append(text)
    return files, "\n".join(combined_parts), contents


def find_pattern_locations(contents: dict[str, str], pattern: str, flags: int = 0, limit: int = 8) -> list[str]:
    regex = re.compile(pattern, flags)
    locations: list[str] = []
    for relative, text in contents.items():
        for match in regex.finditer(text):
            line = text.count("\n", 0, match.start()) + 1
            locations.append(f"{relative}:{line}")
            if len(locations) >= limit:
                return locations
    return locations


def count_pattern(contents: dict[str, str], pattern: str, flags: int = 0) -> int:
    regex = re.compile(pattern, flags)
    return sum(len(regex.findall(text)) for text in contents.values())


def any_file_path(files: list[Path], root: Path, predicate) -> list[str]:
    result = []
    for path in files:
        relative = relative_location(path, root)
        if predicate(relative.lower()):
            result.append(relative)
    return result


def evaluate_frontend(
    root: Path,
    config: dict[str, Any],
    max_file_bytes: int,
    state: AuditState,
) -> dict[str, Any]:
    ignored_paths = [str(item) for item in config.get("ignoredPaths", []) if isinstance(item, str)]
    ignored_parts = set(DEFAULT_IGNORED_PARTS)
    files, combined_text, contents = collect_text_index(
        root, ignored_parts, ignored_paths, max_file_bytes
    )
    manifest, manifest_path = package_manifest(root)
    dependencies = all_dependencies(manifest)
    scripts = manifest.get("scripts", {}) if isinstance(manifest.get("scripts", {}), dict) else {}
    framework = detect_framework(dependencies)

    capacitor_packages = sorted(name for name in dependencies if name.startswith("@capacitor/"))
    capacitor_present = "@capacitor/core" in dependencies or bool(capacitor_packages)
    android_dir = root / "android"
    capacitor_configs = [
        path.name
        for path in root.iterdir()
        if path.is_file() and path.name.startswith("capacitor.config.")
    ] if root.is_dir() else []

    providers = detect_providers(dependencies, combined_text)
    benchmark_paths = any_file_path(
        files,
        root,
        lambda p: "benchmark" in p and (p.endswith(".gradle") or p.endswith(".kts") or p.endswith(".kt")),
    )
    baseline_paths = any_file_path(files, root, lambda p: "baselineprofile" in p or "baseline-profile" in p)

    if not capacitor_present:
        state.add(
            title="Capacitor dependency not detected",
            severity="high",
            evidence="likely",
            repository="mobile frontend",
            location=relative_location(manifest_path, root) if manifest_path else "package.json",
            observation="No @capacitor dependency was found in the detected package manifest.",
            impact="The repository may not be the mobile app root, or Android-specific checks may be incomplete.",
            required_change="Confirm the correct repository path or document the non-Capacitor architecture.",
            verification="Open the actual package manifest and Capacitor configuration.",
            category="architecture",
        )

    if not android_dir.is_dir():
        state.add(
            title="Android project directory not detected",
            severity="high",
            evidence="verified",
            repository="mobile frontend",
            location="android/",
            observation="The repository root does not contain an Android project directory.",
            impact="Native lifecycle, build, benchmark, permission, and background-work checks cannot be completed.",
            required_change="Provide or generate the Capacitor Android project in the mobile repository.",
            verification="Confirm that android/app and Gradle files exist.",
            category="android build",
        )

    if not capacitor_configs:
        state.add(
            title="Capacitor configuration not detected at repository root",
            severity="medium",
            evidence="verified",
            repository="mobile frontend",
            location="capacitor.config.*",
            observation="No capacitor.config file was found at the supplied frontend root.",
            impact="The scanner may be running from the wrong directory and cannot verify app ID, web directory, or plugin settings.",
            required_change="Confirm the mobile repository root or add the version-controlled Capacitor configuration.",
            verification="Locate and inspect capacitor.config.ts, .js, or .json.",
            category="architecture",
        )

    if not providers:
        state.add(
            title="No supported mobile observability provider detected",
            severity="high",
            evidence="likely",
            repository="mobile frontend",
            location=relative_location(manifest_path, root) if manifest_path else "package.json",
            observation="No known JavaScript or Capacitor observability package or initialization marker was found.",
            impact="Production JavaScript errors, native crashes, release context, and key journey timings may be unavailable.",
            required_change="Select and integrate an observability stack that covers JavaScript errors, native crashes, release metadata, and custom journey spans.",
            verification="Trigger a controlled JavaScript error and native test crash in a non-production environment and confirm ingestion.",
            category="observability",
        )
    else:
        init_markers = find_pattern_locations(
            contents,
            r"(?:Sentry\.init|initializeFaro|getPerformance\s*\(|NodeSDK\s*\(|registerInstrumentations\s*\()",
            re.IGNORECASE,
        )
        if not init_markers:
            state.add(
                title="Observability dependency detected but initialization was not confirmed",
                severity="medium",
                evidence="likely",
                repository="mobile frontend",
                location=relative_location(manifest_path, root) if manifest_path else "package.json",
                observation=f"Detected provider packages or markers: {', '.join(providers)}, but no common initialization call was found.",
                impact="Installed packages may not capture runtime failures or performance traces.",
                required_change="Verify early application initialization, release metadata, source maps, sampling, and privacy filters.",
                verification="Inspect bootstrap code and confirm a test event reaches the selected provider.",
                category="observability",
            )

    performance_script = next(
        (name for name in scripts if "performance" in name.lower() or "benchmark" in name.lower()),
        None,
    )
    if not performance_script:
        state.add(
            title="No repository performance-check command detected",
            severity="medium",
            evidence="verified",
            repository="CI",
            location=relative_location(manifest_path, root) if manifest_path else "package.json",
            observation="No package script containing performance or benchmark was found.",
            impact="Agents and CI do not have a single deterministic command for recurring performance checks.",
            required_change="Add a documented performance check command that runs fast static checks, bundle budgets, and available Android checks.",
            verification="Run the command in a clean checkout and require a nonzero exit code on a known violation.",
            category="CI governance",
        )

    if not benchmark_paths:
        state.add(
            title="Jetpack Macrobenchmark module not detected",
            severity="medium",
            evidence="likely",
            repository="android",
            location="android/",
            observation="No benchmark module or benchmark source path was found.",
            impact="Startup and frame regressions cannot be reproduced reliably before release.",
            required_change="Add Macrobenchmark journeys for critical startup, navigation, scrolling, resume, and sync flows.",
            verification="Run benchmark tasks on a controlled device and retain JSON plus Perfetto artifacts.",
            category="android benchmark",
        )

    if not baseline_paths:
        state.add(
            title="Baseline Profile module not detected",
            severity="low",
            evidence="likely",
            repository="android",
            location="android/",
            observation="No baseline profile module or file path was found.",
            impact="Frequently used Android code paths may miss ahead-of-time profile optimization.",
            required_change="Generate and ship Baseline Profiles for representative critical journeys when supported by the build.",
            verification="Generate the profile and compare release-like startup benchmarks before and after.",
            category="android build",
        )

    fully_drawn_locations = find_pattern_locations(contents, r"reportFullyDrawn\s*\(", re.IGNORECASE)
    if not fully_drawn_locations:
        state.add(
            title="Full-display readiness marker not detected",
            severity="low",
            evidence="likely",
            repository="android",
            location="android/ and application bootstrap",
            observation="No reportFullyDrawn call was found.",
            impact="Android full-display startup timing may not represent when the first useful WebView screen is actually usable.",
            required_change="Bridge application readiness to Android reportFullyDrawn when full-display timing is part of the benchmark strategy.",
            verification="Confirm StartupTimingMetric reports timeToFullDisplayMs at the intended readiness point.",
            category="startup",
        )

    interval_locations = find_pattern_locations(contents, r"\bsetInterval\s*\(")
    if interval_locations:
        state.add(
            title="Periodic JavaScript timers require lifecycle review",
            severity="medium",
            evidence="likely",
            repository="mobile frontend",
            location=", ".join(interval_locations),
            observation=f"Found setInterval usage in {len(interval_locations)} displayed locations.",
            impact="Unbounded timers can waste CPU, trigger network work, continue while hidden, and create duplicate work after remounts.",
            required_change="Review each timer for cleanup, visibility gating, backoff, and replacement with events or Android-supported background work.",
            verification="Trace pause, resume, repeated navigation, and process restoration while confirming no duplicate timer activity.",
            category="lifecycle and background work",
        )

    watch_locations = find_pattern_locations(contents, r"(?:watchPosition|Geolocation\.watchPosition)\s*\(", re.IGNORECASE)
    clear_count = count_pattern(contents, r"(?:clearWatch|Geolocation\.clearWatch)\s*\(", re.IGNORECASE)
    watch_count = count_pattern(contents, r"(?:watchPosition|Geolocation\.watchPosition)\s*\(", re.IGNORECASE)
    if watch_count > clear_count:
        state.add(
            title="Location watcher cleanup was not matched statically",
            severity="high",
            evidence="likely",
            repository="mobile frontend",
            location=", ".join(watch_locations) if watch_locations else "source files",
            observation=f"Detected {watch_count} location watcher calls and {clear_count} clear calls.",
            impact="Location may continue after the related journey, increasing battery use and privacy exposure.",
            required_change="Centralize location sessions and guarantee cleanup on tour end, error, logout, unmount, and app-state transitions.",
            verification="Exercise all exit paths on a physical device and verify active location indicators and logs stop.",
            category="location and battery",
        )

    listener_add_count = count_pattern(contents, r"\.addListener\s*\(")
    listener_remove_count = count_pattern(contents, r"(?:\.remove\s*\(|removeAllListeners\s*\()")
    listener_locations = find_pattern_locations(contents, r"\.addListener\s*\(")
    if listener_add_count and listener_remove_count < listener_add_count:
        state.add(
            title="Listener cleanup requires manual verification",
            severity="medium",
            evidence="likely",
            repository="mobile frontend",
            location=", ".join(listener_locations),
            observation=f"Detected {listener_add_count} addListener calls and {listener_remove_count} common removal calls.",
            impact="Repeated mounting or resume cycles can create duplicate callbacks, memory growth, and duplicated network or sensor work.",
            required_change="Store listener handles and remove them at the owning lifecycle boundary.",
            verification="Open and close affected screens repeatedly and confirm callback counts and memory remain stable.",
            category="lifecycle and memory",
        )

    base64_locations = find_pattern_locations(
        contents,
        r"(?:readAsDataURL\s*\(|data:image/|base64\s*[,\"']|CameraResultType\.Base64)",
        re.IGNORECASE,
    )
    if base64_locations:
        state.add(
            title="Base64 image handling detected",
            severity="medium",
            evidence="likely",
            repository="mobile frontend",
            location=", ".join(base64_locations),
            observation="Source code contains Base64 or data-URL image handling markers.",
            impact="Large Base64 strings increase memory pressure, copying, payload size, and WebView garbage collection.",
            required_change="Prefer file URIs, blobs, thumbnails, bounded compression, and multipart or resumable uploads.",
            verification="Profile memory and upload size for representative photos before and after the change.",
            category="images and memory",
        )

    direct_fetch_locations = find_pattern_locations(contents, r"\bfetch\s*\(")
    api_client_markers = find_pattern_locations(
        contents,
        r"(?:axios\.create|createApiClient|ApiClient|HttpClient|ky\.create|ofetch\.create)",
        re.IGNORECASE,
    )
    if len(direct_fetch_locations) >= 4 and not api_client_markers:
        state.add(
            title="Multiple direct fetch calls without a detected central API client",
            severity="medium",
            evidence="likely",
            repository="mobile frontend",
            location=", ".join(direct_fetch_locations),
            observation="Several direct fetch calls were found and no common API-client marker was detected.",
            impact="Timeouts, cancellation, tracing, authentication, retries, deduplication, and privacy filtering may be inconsistent.",
            required_change="Route application requests through a central client with explicit policies and instrumentation.",
            verification="Inspect all network call sites and confirm shared request policies and trace headers.",
            category="network",
        )

    dynamic_import_count = count_pattern(contents, r"\bimport\s*\(")
    route_lazy_count = count_pattern(contents, r"(?:React\.lazy|loadComponent|loadChildren|defineAsyncComponent)", re.IGNORECASE)
    if dynamic_import_count + route_lazy_count == 0:
        state.add(
            title="No lazy-loading marker detected",
            severity="low",
            evidence="likely",
            repository="mobile frontend",
            location="routing and feature imports",
            observation="No dynamic import or common framework lazy-loading marker was found.",
            impact="Noncritical features and heavy libraries may be included in the initial WebView bundle.",
            required_change="Inspect the production bundle and lazy-load noncritical routes, maps, editors, and media tooling where beneficial.",
            verification="Compare initial compressed bundle size and cold-start traces.",
            category="startup and bundle",
        )

    virtualization_present = bool(dependencies.intersection(VIRTUALIZATION_PACKAGES)) or bool(
        find_pattern_locations(contents, r"(?:VirtualList|VirtualScroller|useVirtualizer|FixedSizeList)", re.IGNORECASE)
    )

    large_source_threshold = int(
        config.get("budgets", {}).get("maximumSourceFileBytes", 750000)
        if isinstance(config.get("budgets", {}), dict)
        else 750000
    )
    large_sources: list[str] = []
    for path in files:
        if path.suffix.lower() not in {".js", ".jsx", ".ts", ".tsx", ".vue"}:
            continue
        try:
            if path.stat().st_size > large_source_threshold:
                large_sources.append(relative_location(path, root))
        except OSError:
            continue
    if large_sources:
        state.add(
            title="Very large source files detected",
            severity="low",
            evidence="verified",
            repository="mobile frontend",
            location=", ".join(large_sources[:8]),
            observation=f"Found {len(large_sources)} source files above {large_source_threshold} bytes.",
            impact="Large modules can hide initialization work, reduce code-splitting effectiveness, and increase review difficulty.",
            required_change="Inspect generated or monolithic files, exclude generated assets from source scanning, and split runtime code when it reduces initial work.",
            verification="Use bundle analysis and route-level timing rather than file size alone to confirm impact.",
            category="startup and bundle",
        )

    return {
        "root": str(root),
        "manifest": str(manifest_path) if manifest_path else None,
        "framework": framework,
        "capacitorPresent": capacitor_present,
        "capacitorPackages": capacitor_packages,
        "capacitorConfigs": capacitor_configs,
        "androidProjectPresent": android_dir.is_dir(),
        "observabilityProviders": providers,
        "packageScripts": sorted(scripts),
        "macrobenchmarkPaths": benchmark_paths[:20],
        "baselineProfilePaths": baseline_paths[:20],
        "hasLazyLoadingMarker": dynamic_import_count + route_lazy_count > 0,
        "hasVirtualizationMarker": virtualization_present,
        "sourceFileCount": len(files),
    }


def evaluate_backend(
    root: Path,
    config: dict[str, Any],
    max_file_bytes: int,
    state: AuditState,
) -> dict[str, Any]:
    ignored_paths = [str(item) for item in config.get("ignoredPaths", []) if isinstance(item, str)]
    ignored_parts = set(DEFAULT_IGNORED_PARTS)
    files, combined_text, contents = collect_text_index(
        root, ignored_parts, ignored_paths, max_file_bytes
    )
    manifest, manifest_path = package_manifest(root)
    dependencies = all_dependencies(manifest)
    framework = detect_backend_framework(dependencies)
    providers = detect_providers(dependencies, combined_text)

    if not providers:
        state.add(
            title="No supported backend tracing or APM provider detected",
            severity="high",
            evidence="likely",
            repository="backend",
            location=relative_location(manifest_path, root) if manifest_path else "package.json",
            observation="No common backend observability SDK or initialization marker was found.",
            impact="Mobile request latency cannot be separated into backend, database, queue, and external-service time.",
            required_change="Instrument backend requests, database calls, queues, uploads, and external calls with a selected APM or OpenTelemetry-compatible stack.",
            verification="Send a traced mobile request and confirm an end-to-end backend trace with internal spans.",
            category="backend observability",
        )

    trace_locations = find_pattern_locations(
        contents,
        r"(?:traceparent|tracestate|propagat|request[-_ ]?id|correlation[-_ ]?id)",
        re.IGNORECASE,
    )
    if not trace_locations:
        state.add(
            title="Trace or correlation propagation not detected",
            severity="medium",
            evidence="likely",
            repository="backend",
            location="request middleware and HTTP clients",
            observation="No common traceparent, propagation, request ID, or correlation ID marker was found.",
            impact="A mobile request may not be traceable across frontend, backend, queues, and downstream services.",
            required_change="Adopt W3C trace context where supported and expose a safe request identifier for operational diagnosis.",
            verification="Confirm one mobile action produces linked frontend and backend spans.",
            category="distributed tracing",
        )

    database_markers = sorted(
        name
        for name in dependencies
        if name in {
            "@prisma/client",
            "drizzle-orm",
            "knex",
            "mongoose",
            "pg",
            "sequelize",
            "typeorm",
        }
    )
    load_test_markers = sorted(
        name for name in dependencies if name in {"autocannon", "k6", "artillery", "clinic"}
    )
    if not load_test_markers:
        state.add(
            title="Backend performance-test dependency not detected",
            severity="low",
            evidence="likely",
            repository="backend",
            location=relative_location(manifest_path, root) if manifest_path else "package.json",
            observation="No common load or backend profiling tool was found in the package manifest.",
            impact="Endpoint and sync regressions may only be discovered in production.",
            required_change="Add targeted endpoint performance tests for critical mobile operations rather than a generic maximum-throughput test only.",
            verification="Run representative test data through critical endpoints and store latency plus error results.",
            category="backend testing",
        )

    return {
        "root": str(root),
        "manifest": str(manifest_path) if manifest_path else None,
        "framework": framework,
        "observabilityProviders": providers,
        "databasePackages": database_markers,
        "performanceTestPackages": load_test_markers,
        "sourceFileCount": len(files),
    }


def summarize_categories(findings: list[Finding]) -> dict[str, str]:
    severity_rank = {"critical": 5, "high": 4, "medium": 3, "low": 2, "info": 1}
    category_map: dict[str, list[Finding]] = {}
    for finding in findings:
        category_map.setdefault(finding.category, []).append(finding)

    statuses: dict[str, str] = {}
    for category, category_findings in sorted(category_map.items()):
        maximum = max(severity_rank.get(item.severity, 0) for item in category_findings)
        if maximum >= 4:
            statuses[category] = "fail"
        elif maximum >= 2:
            statuses[category] = "partial"
        else:
            statuses[category] = "pass"
    return statuses


def markdown_report(payload: dict[str, Any]) -> str:
    lines = [
        "# Mobile Performance Static Scan",
        "",
        "This output contains static leads. Review them in context before treating them as confirmed defects.",
        "",
        "## Detected scope",
        "",
        f"- Frontend: `{payload['scope']['frontend']}`",
        f"- Backend: `{payload['scope'].get('backend') or 'not supplied'}`",
        f"- Frontend framework: `{payload['detected']['frontend'].get('framework', 'unknown')}`",
        f"- Findings: `{len(payload['findings'])}`",
        "",
        "## Category status",
        "",
        "| Category | Status |",
        "| --- | --- |",
    ]
    for category, status in payload["categoryStatus"].items():
        lines.append(f"| {category} | {status} |")

    lines.extend(["", "## Findings", ""])
    for finding in payload["findings"]:
        lines.extend(
            [
                f"### {finding['finding_id']} - {finding['title']}",
                "",
                f"- Severity: {finding['severity']}",
                f"- Evidence: {finding['evidence']}",
                f"- Repository: {finding['repository']}",
                f"- Location: {finding['location']}",
                f"- Observation: {finding['observation']}",
                f"- Impact: {finding['impact']}",
                f"- Required change: {finding['required_change']}",
                f"- Verification: {finding['verification']}",
                "",
            ]
        )
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    args = parse_args()
    frontend = Path(args.frontend).resolve()
    backend = Path(args.backend).resolve() if args.backend else None

    if not frontend.is_dir():
        print(f"Frontend repository does not exist or is not a directory: {frontend}", file=sys.stderr)
        return 2
    if backend and not backend.is_dir():
        print(f"Backend repository does not exist or is not a directory: {backend}", file=sys.stderr)
        return 2

    try:
        config = load_config(args.config)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    state = AuditState()
    frontend_data = evaluate_frontend(frontend, config, args.max_file_bytes, state)

    if backend:
        backend_data = evaluate_backend(backend, config, args.max_file_bytes, state)
    else:
        backend_data = None
        state.add(
            title="Backend performance and tracing were not inspected",
            severity="info",
            evidence="not verifiable",
            repository="backend",
            location="backend repository not supplied",
            observation="The audit received only the mobile frontend repository.",
            impact="Endpoint, database, queue, upload, and distributed-tracing findings remain incomplete.",
            required_change="Supply the backend repository or production traces for an end-to-end audit.",
            verification="Inspect the backend bootstrap, request tracing, database access, critical endpoints, queues, and telemetry.",
            category="backend observability",
        )

    payload = {
        "schemaVersion": 1,
        "scanner": "mobile-performance-audit",
        "scope": {
            "frontend": str(frontend),
            "backend": str(backend) if backend else None,
            "config": str(Path(args.config).resolve()) if args.config else None,
        },
        "detected": {
            "frontend": frontend_data,
            "backend": backend_data,
        },
        "categoryStatus": summarize_categories(state.findings),
        "findings": [asdict(item) for item in state.findings],
        "limitations": [
            "Static scanning cannot prove runtime cleanup, battery efficiency, frame performance, or correct SDK initialization.",
            "Physical-device benchmarks and production telemetry are required for representative runtime conclusions.",
            "Pattern counts can include tests, examples, generated code, or valid allowlisted cases.",
        ],
    }

    json_text = json.dumps(payload, indent=2, sort_keys=True)
    if args.output:
        output_path = Path(args.output).resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(json_text + "\n", encoding="utf-8")
    else:
        print(json_text)

    if args.markdown_output:
        markdown_path = Path(args.markdown_output).resolve()
        markdown_path.parent.mkdir(parents=True, exist_ok=True)
        markdown_path.write_text(markdown_report(payload), encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
