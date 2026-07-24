#!/usr/bin/env bash
# enrich-evidence-urls.sh — fill evidence[].url from project.repository + git + paths
# Usage: enrich-evidence-urls.sh [repo_root]
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

[[ -f .project-memory/project.json ]] || { echo "error: missing .project-memory/project.json" >&2; exit 1; }
[[ -d .project-memory/changes ]] || exit 0

node <<'NODE'
const fs = require("fs");
const path = require("path");

const project = JSON.parse(fs.readFileSync(".project-memory/project.json", "utf8"));
const repo = (project.repository?.url || "").replace(/\.git$/i, "").replace(/\/$/, "");
const defaultBranch = project.repository?.default_branch || "main";
if (!repo) {
  console.error("enrich-evidence-urls: no project.repository.url — skip");
  process.exit(0);
}

function isSha(s) {
  return /^[0-9a-f]{7,40}$/i.test(String(s || "")) && !String(s).includes("/");
}
function isDirPath(p) {
  return /\/$/.test(p) || !/\.[a-z0-9]{1,8}$/i.test((p.split("/").pop() || ""));
}
function commitUrl(sha) {
  if (!sha || String(sha).replace(/0/g, "") === "") return null;
  return `${repo}/commit/${sha}`;
}
function compareUrl(base, head) {
  if (!base || !head || base === head || String(base).replace(/0/g, "") === "") return null;
  return `${repo}/compare/${base}...${head}`;
}
function pathUrl(ref, p) {
  const clean = String(p || "").replace(/^\.\//, "").replace(/^\/+/, "").replace(/\/$/, "");
  if (!clean || isSha(clean)) return null;
  const kind = isDirPath(clean) ? "tree" : "blob";
  return `${repo}/${kind}/${ref || defaultBranch}/${clean}`;
}

let n = 0;
const dir = ".project-memory/changes";
for (const file of fs.readdirSync(dir).filter((f) => f.endsWith(".json"))) {
  const fp = path.join(dir, file);
  const ch = JSON.parse(fs.readFileSync(fp, "utf8"));
  const head = ch.git?.head || defaultBranch;
  const base = ch.git?.base || "";
  const evidence = [];
  const seen = new Set();
  const push = (item) => {
    const key = item.url || `${item.kind}:${item.path}`;
    if (seen.has(key)) return;
    seen.add(key);
    evidence.push(item);
  };

  const cmp = compareUrl(base, head);
  if (cmp) push({ kind: "compare", path: `${base}...${head}`, url: cmp });
  const hu = commitUrl(head);
  if (hu) push({ kind: "commit", path: head, sha: head, url: hu });
  if (ch.git?.pull_request) {
    push({ kind: "pr", path: ch.git.pull_request, url: ch.git.pull_request });
  }
  for (const p of ch.affected_components || []) {
    const url = pathUrl(head, p);
    if (url) push({ kind: "file", path: p, url });
  }
  for (const e of ch.evidence || []) {
    if (e.kind === "pr" && (e.url || e.path)) {
      push({ kind: "pr", path: e.path || e.url, url: e.url || e.path });
      continue;
    }
    if (e.kind === "commit" || e.kind === "compare" || isSha(e.path) || isSha(e.sha)) {
      if (e.kind === "compare" && e.url) {
        push(e);
        continue;
      }
      const sha = e.sha || e.path;
      const url = e.url || commitUrl(sha);
      if (url) push({ kind: "commit", path: sha, sha, url });
      continue;
    }
    if (e.path) {
      push({ kind: e.kind || "file", path: e.path, url: e.url || pathUrl(head, e.path) || null });
    } else if (e.url) {
      push({ ...e });
    }
  }
  ch.evidence = evidence;
  fs.writeFileSync(fp, JSON.stringify(ch, null, 2) + "\n");
  n++;
}
console.log(`enrich-evidence-urls: updated ${n} change event(s)`);
NODE
