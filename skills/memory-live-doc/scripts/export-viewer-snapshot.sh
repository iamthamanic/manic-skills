#!/usr/bin/env bash
# Export self-contained GitHub Pages viewer snapshot from .project-memory/
# Usage: export-viewer-snapshot.sh [repo_root]
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VIEWER_SRC="${SKILL_ROOT}/assets/viewer"
VIEWER_DST="docs/memory-live-doc/viewer"
DATA="${VIEWER_DST}/data"
MEM=".project-memory"

[[ -d "$MEM" ]] || { echo "error: missing $MEM/" >&2; exit 1; }

mkdir -p "$DATA" "$VIEWER_DST" "$MEM/architecture/history"

# Sync viewer shell from skill (preserves data/)
rsync -a --exclude 'data/' "${VIEWER_SRC}/" "${VIEWER_DST}/"

# Theme
bash "${SKILL_ROOT}/scripts/resolve-viewer-theme.sh" "$ROOT" >/dev/null

# Ensure GitHub evidence URLs on change events
bash "${SKILL_ROOT}/scripts/enrich-evidence-urls.sh" "$ROOT"

# Core JSON copies / aggregates
cp "$MEM/project.json" "$DATA/project.json"
cp "$MEM/current-state.json" "$DATA/current-state.json"

node <<'NODE'
const fs = require("fs");
const path = require("path");

function readDirJson(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".json"))
    .map((f) => JSON.parse(fs.readFileSync(path.join(dir, f), "utf8")));
}

const data = "docs/memory-live-doc/viewer/data";
const features = readDirJson(".project-memory/features");
const changes = readDirJson(".project-memory/changes").sort((a, b) =>
  String(b.date || "").localeCompare(String(a.date || "")),
);
const decisions = readDirJson(".project-memory/decisions");
const history = readDirJson(".project-memory/architecture/history");

fs.writeFileSync(
  path.join(data, "features.json"),
  JSON.stringify({ schema_version: 1, features }, null, 2) + "\n",
);
fs.writeFileSync(
  path.join(data, "changes.json"),
  JSON.stringify({ schema_version: 1, changes }, null, 2) + "\n",
);
fs.writeFileSync(
  path.join(data, "decisions.json"),
  JSON.stringify({ schema_version: 1, decisions }, null, 2) + "\n",
);

const mermaidPath = ".project-memory/architecture/overview.mermaid";
let mermaid = "";
if (fs.existsSync(mermaidPath)) {
  mermaid = fs.readFileSync(mermaidPath, "utf8");
}

const current = {
  schema_version: 1,
  id: "overview-current",
  date: new Date().toISOString().slice(0, 10),
  title: { de: "Aktuell", en: "Current" },
  summary: {
    de: "Aktueller Stand aus overview.mermaid",
    en: "Current state from overview.mermaid",
  },
  mermaid,
  source_path: ".project-memory/architecture/overview.mermaid",
  is_current: true,
};

fs.writeFileSync(
  path.join(data, "architecture.json"),
  JSON.stringify(
    {
      schema_version: 1,
      id: "overview",
      title: { de: "Architektur", en: "Architecture" },
      mermaid,
      source_path: ".project-memory/architecture/overview.mermaid",
    },
    null,
    2,
  ) + "\n",
);

const versions = [...history]
  .map((h) => ({ ...h, is_current: false }))
  .sort((a, b) => String(b.date || "").localeCompare(String(a.date || "")));

// Prepend current if no history entry matches same mermaid content
const already = versions.some((v) => (v.mermaid || "").trim() === mermaid.trim());
const allVersions = already ? versions : [current, ...versions];

fs.writeFileSync(
  path.join(data, "architecture-history.json"),
  JSON.stringify({ schema_version: 1, versions: allVersions }, null, 2) + "\n",
);

console.log(
  JSON.stringify({
    features: features.length,
    changes: changes.length,
    decisions: decisions.length,
    mermaid_chars: mermaid.length,
    architecture_versions: allVersions.length,
  }),
);
NODE

echo "export-viewer-snapshot: ok → ${VIEWER_DST}/" >&2
