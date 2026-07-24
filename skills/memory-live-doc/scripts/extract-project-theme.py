#!/usr/bin/env python3
"""
extract-project-theme.py — derive memory-live-doc viewer theme.json from the project.

Priority (caller also handles locked / theme_id pin):
  1. CSS custom properties in globals/index/theme CSS (:root and optional .dark)
  2. Markdown styleguides (STYLEGUIDE.md, StyleGuide.md, …)
  3. Fail → exit 2 (caller uses default.json)

Usage:
  extract-project-theme.py [repo_root] [--prefer dark|light|auto]
  Prints theme JSON to stdout. Diagnostics on stderr.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

HEX = re.compile(r"#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b")
CSS_VAR = re.compile(
    r"--([a-zA-Z0-9_-]+)\s*:\s*([^;]+);",
    re.MULTILINE,
)
MD_COLOR = re.compile(
    r"(?P<label>[^\n:#*]{2,80}?)[:\s]+[`'\"]?(?P<hex>#[0-9A-Fa-f]{3,8})[`'\"]?",
    re.MULTILINE,
)
FONT_MD = re.compile(
    r"(?:Primary|Body|Sans|Display|Font Family|Monospace|Mono)[^\n]{0,40}?"
    r"['\"]([^'\"]{3,80})['\"]",
    re.I,
)

CANDIDATE_NAMES = {
    "styleguide.md",
    "style-guide.md",
    "design-tokens.css",
    "tokens.css",
    "theme.css",
    "globals.css",
    "global.css",
    "variables.css",
    "colors.css",
}

PREFERRED_REL = [
    "src/STYLEGUIDE.md",
    "STYLEGUIDE.md",
    "docs/guidelines/StyleGuide.md",
    "docs/STYLEGUIDE.md",
    "docs/styleguide.md",
    "src/styles/globals.css",
    "src/styles/global.css",
    "src/index.css",
    "src/app.css",
    "app/globals.css",
    "styles/globals.css",
    "packages/ui/src/globals.css",
]

SCAN_DIRS = [
    "src",
    "src/styles",
    "app",
    "styles",
    "docs",
    "docs/guidelines",
]

SKIP_PARTS = {
    "node_modules",
    ".git",
    "dist",
    "build",
    "coverage",
    ".next",
    "vendor",
    "gen",
    "android",
    "ios",
    "target",
    ".turbo",
    "storybook-static",
}


def norm_hex(h: str) -> str | None:
    h = h.strip().lower()
    if not h.startswith("#"):
        return None
    body = h[1:]
    if len(body) in (3, 4):
        body = "".join(c * 2 for c in body[:3])
    if len(body) >= 6:
        return "#" + body[:6]
    return None


def luminance(hex_color: str) -> float:
    h = norm_hex(hex_color)
    if not h:
        return 0.5
    r, g, b = (int(h[i : i + 2], 16) / 255 for i in (1, 3, 5))

    def lin(c: float) -> float:
        return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

    R, G, B = lin(r), lin(g), lin(b)
    return 0.2126 * R + 0.7152 * G + 0.0722 * B


def find_candidates(root: Path) -> list[Path]:
    found: list[Path] = []
    seen: set[Path] = set()

    def add(p: Path) -> None:
        if not p.is_file():
            return
        try:
            rp = p.resolve()
        except OSError:
            return
        if rp in seen:
            return
        if any(part in SKIP_PARTS for part in p.parts):
            return
        if p.suffix == ".css" and p.stat().st_size > 200_000 and "global" not in p.name.lower():
            return
        seen.add(rp)
        found.append(p)

    for rel in PREFERRED_REL:
        add(root / rel)

    # Case-insensitive STYLEGUIDE in preferred dirs only (depth-limited)
    for drel in SCAN_DIRS:
        d = root / drel
        if not d.is_dir():
            continue
        try:
            for p in d.rglob("*"):
                # depth limit: root/drel/... max 4 extra parts
                try:
                    rel_parts = p.relative_to(d).parts
                except ValueError:
                    continue
                if len(rel_parts) > 4:
                    continue
                if any(part in SKIP_PARTS for part in rel_parts):
                    continue
                name = p.name.lower()
                if name in CANDIDATE_NAMES or name == "styleguide.md" or (
                    name.endswith(".md") and "styleguide" in name.replace("-", "").replace("_", "")
                ):
                    add(p)
                elif name in ("globals.css", "global.css", "theme.css", "tokens.css", "variables.css"):
                    add(p)
        except OSError:
            continue

    return found[:30]


def parse_css_blocks(text: str) -> dict[str, dict[str, str]]:
    """Return {'root': {var: value}, 'dark': {...}} hex-only values."""
    blocks: dict[str, dict[str, str]] = {"root": {}, "dark": {}}

    def scoop(selector: str, key: str) -> None:
        # naive block extract
        for m in re.finditer(
            rf"{re.escape(selector)}\s*\{{([^{{}}]*(?:\{{[^{{}}]*\}}[^{{}}]*)*)\}}",
            text,
            re.DOTALL,
        ):
            body = m.group(1)
            for vm in CSS_VAR.finditer(body):
                name, val = vm.group(1).lower(), vm.group(2).strip()
                hx = HEX.search(val)
                if hx:
                    n = norm_hex(hx.group(0))
                    if n:
                        blocks[key][name] = n
                elif re.fullmatch(r"[\d.]+rem", val) and name in ("radius", "radius-lg"):
                    blocks[key][name] = val

    scoop(":root", "root")
    scoop(".dark", "dark")
    scoop("[data-theme=dark]", "dark")
    scoop('[data-theme="dark"]', "dark")
    scoop(".dark *", "dark")  # unlikely; ignore if empty
    return blocks


def map_css_vars(vars_: dict[str, str]) -> dict[str, str]:
    """Map CSS custom props → viewer token keys."""
    out: dict[str, str] = {}

    def first(*names: str) -> str | None:
        for n in names:
            if n in vars_:
                return vars_[n]
        return None

    bg = first("background", "bg", "color-background", "surface-ground")
    elev = first("card", "bg-elev", "popover", "surface", "muted")
    ink = first("foreground", "ink", "color-foreground", "text", "card-foreground")
    muted = first("muted-foreground", "muted", "secondary-text", "color-muted")
    line = first("border", "line", "divider", "input")
    accent = first(
        "primary",
        "accent",
        "brand",
        "color-primary",
        "sidebar-primary",
        "ring",
        "primary-purple",
    )
    accent2 = first("accent", "secondary", "accent-blue", "chart-2", "primary-foreground")
    danger = first("destructive", "danger", "error", "destructive-foreground")

    # If accent2 == accent, try secondary/accent-blue
    if accent and accent2 == accent:
        accent2 = first("accent-blue", "secondary", "chart-2") or accent2

    if bg:
        out["bg"] = bg
    if elev:
        out["bgElev"] = elev
    if ink:
        out["ink"] = ink
    if muted:
        out["muted"] = muted
    if line:
        out["line"] = line
    if accent:
        out["accent"] = accent
    if accent2:
        out["accent2"] = accent2
    if danger and danger != ink:
        # avoid using white foreground as danger
        if luminance(danger) < 0.85:
            out["danger"] = danger
    if "radius" in vars_:
        out["radius"] = vars_["radius"]
        out["tabRadius"] = vars_["radius"]
    return out


def parse_markdown_colors(text: str) -> dict[str, str]:
    """Label-based extraction from styleguide markdown."""
    labels: dict[str, str] = {}
    bold = re.compile(r"\*\*([^*]{2,80})\*\*\s*:\s*`?(#[0-9A-Fa-f]{3,8})`?")
    for m in bold.finditer(text):
        label = re.sub(r"\s+", " ", m.group(1)).strip().lower()
        hx = norm_hex(m.group(2))
        if hx:
            labels[label] = hx
    for m in MD_COLOR.finditer(text):
        label = re.sub(r"\s+", " ", m.group("label")).strip(" -*#").lower()
        hx = norm_hex(m.group("hex"))
        if not hx or len(label) > 60:
            continue
        labels.setdefault(label, hx)

    def find_label(*needles: str) -> str | None:
        for lab, hx in labels.items():
            if any(n in lab for n in needles):
                return hx
        return None

    out: dict[str, str] = {}
    primary = find_label(
        "primary (türkis",
        "primary (turkis",
        "primary purple",
        "primary (",
        "türkis/grün",
    ) or find_label("primary")
    if primary and "text" in (find_label("primary text") or ""):
        pass
    # Avoid primary text color
    if not primary or primary == find_label("primary text"):
        primary = find_label("primary (türkis", "primary purple", "brand") or find_label("primary")
        # if still text white, look for hex near Primary colors section first non-text
        for lab, hx in labels.items():
            if "primary" in lab and "text" not in lab and "foreground" not in lab:
                primary = hx
                break

    bg = find_label("background")
    surface = find_label("card background", "card", "surface")
    ink = find_label("primary text", "foreground")
    muted = find_label("secondary text", "muted text", "muted")
    line = find_label("border", "divider")
    accent2 = find_label("code layer", "cyan", "accent blue", "accent (")
    danger = find_label("error state", "error", "danger", "destructive")

    if primary and primary != "#ffffff":
        out["accent"] = primary
    if bg:
        out["bg"] = bg
    if surface:
        out["bgElev"] = surface
    if ink:
        out["ink"] = ink
    if muted and muted != bg:
        out["muted"] = muted
    if line:
        out["line"] = line
    if accent2 and accent2 != primary:
        out["accent2"] = accent2
    if danger:
        out["danger"] = danger
    return out


def parse_fonts(text: str) -> dict[str, str]:
    fonts: dict[str, str] = {}
    for m in FONT_MD.finditer(text):
        stack = m.group(1).strip()
        ctx = text[max(0, m.start() - 40) : m.start()].lower()
        if "mono" in ctx or "monospace" in m.group(0).lower():
            fonts["fontMono"] = stack
        elif "display" in ctx:
            fonts["fontDisplay"] = stack
        else:
            fonts.setdefault("fontBody", stack)
            fonts.setdefault("fontDisplay", stack)
    return fonts


def google_fonts_url(font_display: str, font_body: str, font_mono: str) -> str | None:
    names = []
    for stack in (font_display, font_body, font_mono):
        first = stack.split(",")[0].strip().strip("'\"")
        if first and first.lower() not in ("system-ui", "-apple-system", "blinkmacsystemfont", "segoe ui", "sans-serif", "monospace", "ui-monospace", "consolas"):
            names.append(first)
    # unique preserve order
    uniq = []
    for n in names:
        if n not in uniq:
            uniq.append(n)
    if not uniq:
        return None
    families = []
    for n in uniq[:3]:
        q = n.replace(" ", "+")
        if "mono" in n.lower() or n.lower() in ("jetbrains mono", "fira code", "ibm plex mono"):
            families.append(f"family={q}:wght@400;500")
        else:
            families.append(f"family={q}:wght@400;500;600;700")
    return "https://fonts.googleapis.com/css2?" + "&".join(families) + "&display=swap"


def glow_from_bg(bg: str, accent: str) -> tuple[str, str]:
    # soft tints for atmosphere
    return (
        accent if luminance(bg) < 0.3 else bg,
        bg,
    )


def mermaid_from_tokens(tokens: dict) -> dict:
    bg = tokens.get("bg", "#0f1115")
    elev = tokens.get("bgElev", "#181b22")
    ink = tokens.get("ink", "#e8eaef")
    accent = tokens.get("accent", "#5b9fd4")
    muted = tokens.get("muted", "#9aa3b2")
    dark = luminance(bg) < 0.45
    return {
        "theme": "dark" if dark else "default",
        "themeVariables": {
            "primaryColor": elev,
            "primaryTextColor": ink,
            "primaryBorderColor": accent,
            "lineColor": muted,
            "secondaryColor": elev,
            "tertiaryColor": bg,
            "background": bg,
            "mainBkg": elev,
            "nodeBorder": accent,
            "clusterBkg": bg,
            "titleColor": ink,
            "edgeLabelBackground": elev,
        },
    }


def load_default(skill_root: Path) -> dict:
    p = skill_root / "assets" / "themes" / "default.json"
    return json.loads(p.read_text(encoding="utf-8"))


def choose_css_map(blocks: dict[str, dict[str, str]], prefer: str) -> tuple[dict[str, str], str]:
    root, dark = blocks.get("root") or {}, blocks.get("dark") or {}
    if prefer == "light":
        return root or dark, "css:root"
    if prefer == "dark":
        return dark or root, "css:.dark" if dark else "css:root"
    # auto: prefer dark block for viewer when present (docs chrome reads better dark)
    if dark:
        return dark, "css:.dark"
    return root, "css:root"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("root", nargs="?", default=".")
    ap.add_argument("--prefer", choices=("dark", "light", "auto"), default="auto")
    ap.add_argument("--skill-root", default="")
    args = ap.parse_args()
    root = Path(args.root).resolve()
    skill_root = Path(args.skill_root).resolve() if args.skill_root else Path(__file__).resolve().parent.parent

    base = load_default(skill_root)
    tokens = dict(base.get("tokens") or {})
    sources: list[str] = []
    md_fonts: dict[str, str] = {}
    hit = False

    for path in find_candidates(root):
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        rel = str(path.relative_to(root))

        if path.suffix.lower() == ".css":
            blocks = parse_css_blocks(text)
            if not blocks["root"] and not blocks["dark"]:
                continue
            chosen, tag = choose_css_map(blocks, args.prefer)
            mapped = map_css_vars(chosen)
            if mapped:
                tokens.update(mapped)
                sources.append(f"{rel} ({tag})")
                hit = True
        else:
            mapped = parse_markdown_colors(text)
            fonts = parse_fonts(text)
            if mapped:
                # Markdown fills gaps / overrides when CSS not yet hit, or merges carefully
                if not hit:
                    tokens.update(mapped)
                else:
                    # CSS won for core; only fill missing from MD
                    for k, v in mapped.items():
                        if k not in tokens or tokens[k] == (base.get("tokens") or {}).get(k):
                            tokens[k] = v
                sources.append(rel)
                hit = True
            if fonts:
                md_fonts.update(fonts)

    if not hit:
        print("extract-project-theme: no project tokens found", file=sys.stderr)
        return 2

    if md_fonts.get("fontDisplay"):
        tokens["fontDisplay"] = md_fonts["fontDisplay"]
    if md_fonts.get("fontBody"):
        tokens["fontBody"] = md_fonts["fontBody"]
    if md_fonts.get("fontMono"):
        tokens["fontMono"] = md_fonts["fontMono"]

    # Atmosphere glows
    bg = tokens.get("bg", "#0f1115")
    accent = tokens.get("accent", "#5b9fd4")
    g1, g2 = glow_from_bg(bg, accent)
    # Mix-ish: use accent at low visual weight by picking near-bg with accent hint
    tokens["bgGlow1"] = accent
    tokens["bgGlow2"] = bg

    # ink-on-accent for buttons: if accent is light, use dark ink via CSS var ink-on-accent
    # stored only if we add token — viewer uses hardcoded #04140e; skip unless needed

    theme = {
        "schema_version": 1,
        "id": "project-derived",
        "source": "; ".join(sources[:6]),
        "locked": False,
        "tokens": tokens,
        "fonts": dict(base.get("fonts") or {}),
        "mermaid": mermaid_from_tokens(tokens),
    }
    gurl = google_fonts_url(
        tokens.get("fontDisplay", ""),
        tokens.get("fontBody", ""),
        tokens.get("fontMono", ""),
    )
    if gurl:
        theme["fonts"]["google"] = gurl

    # Prefer dark ink contrast note: if light bg, ensure muted readable
    if luminance(bg) > 0.6 and luminance(tokens.get("ink", "#000")) > 0.5:
        tokens["ink"] = "#0a0a0a"
        tokens["muted"] = tokens.get("muted") if luminance(tokens.get("muted", "#71717a")) < 0.5 else "#52525b"

    print(json.dumps(theme, indent=2, ensure_ascii=False))
    print(f"extract-project-theme: ok from {', '.join(sources[:4])}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
