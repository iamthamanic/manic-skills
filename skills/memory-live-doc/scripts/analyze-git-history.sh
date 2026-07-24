#!/usr/bin/env bash
# analyze-git-history.sh — deterministic milestone candidates for history backfill.
# Usage: analyze-git-history.sh [repo_root] [--write]
# Always prints JSON to stdout. With --write, also saves:
#   .project-memory/providers/git-history-analysis.json
set -euo pipefail

ROOT=""
WRITE=0
for arg in "$@"; do
  case "$arg" in
    --write) WRITE=1 ;;
    *) [[ -z "$ROOT" ]] && ROOT="$arg" ;;
  esac
done
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo '{"error":"not a git repository"}' >&2
  exit 1
fi

OUT="$(
  python3 - <<'PY'
import json, re, subprocess
from collections import defaultdict
from datetime import datetime

def run(args):
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL).strip()

head = run(["git", "rev-parse", "HEAD"])
first = run(["git", "log", "--reverse", "--format=%H|%cs|%s", "-1"])
parts = first.split("|", 2)
first_sha, first_date, first_subj = parts[0], parts[1], parts[2] if len(parts) > 2 else ""
total = int(run(["git", "rev-list", "--count", "HEAD"]) or "0")

# Monthly buckets
monthly = defaultdict(int)
log_all = run(["git", "log", "--format=%cs"]).splitlines()
for d in log_all:
    if len(d) >= 7:
        monthly[d[:7]] += 1

# Candidate signals: merges, conventional commits, tags, large file-touch commits
candidates = []
seen_keys = set()

def add(date, kind, title, sha, score, files_hint=None):
    key = f"{date}|{kind}|{re.sub(r'[^a-z0-9]+', '-', title.lower())[:40]}"
    if key in seen_keys:
        return
    seen_keys.add(key)
    candidates.append({
        "date": date,
        "kind": kind,
        "title": title[:160],
        "sha": sha[:40],
        "score": score,
        "files_hint": files_hint or [],
    })

# First commit always
add(first_date, "bootstrap", first_subj or "Initial commit", first_sha, 100)

# Tags
try:
    tags = run(["git", "tag", "--sort=creatordate", "--format=%(creatordate:short)|%(refname:short)|%(objectname)"]).splitlines()
    for line in tags:
        if "|" not in line:
            continue
        d, name, sha = line.split("|", 2)
        add(d, "release", f"Tag {name}", sha, 90)
except Exception:
    pass

# Merge commits + conventional
raw = run([
    "git", "log", "--format=%H|%cs|%s", "--merges", "-n", "80"
]).splitlines()
for line in raw:
    if "|" not in line:
        continue
    sha, d, subj = line.split("|", 2)
    add(d, "merge", subj, sha, 70)

raw = run([
    "git", "log", "--format=%H|%cs|%s", "-n", "400"
]).splitlines()
conv = re.compile(r"^(feat|fix|security|perf|BREAKING CHANGE|breaking)(\(.+\))?!?:\s*(.+)$", re.I)
kw = re.compile(
    r"\b(auth|oauth|security|idor|rls|preview|runner|blueprint|architecture|migration|stripe|supabase|access.?control|graph|api)\b",
    re.I,
)
for line in raw:
    if "|" not in line:
        continue
    sha, d, subj = line.split("|", 2)
    m = conv.match(subj.strip())
    if m:
        add(d, m.group(1).lower(), subj, sha, 80)
    elif kw.search(subj):
        add(d, "keyword", subj, sha, 55)

# High-churn commits (by --numstat shortlog proxy: commits touching many paths)
raw = run([
    "git", "log", "--format=%H|%cs|%s", "--name-only", "-n", "200"
]).splitlines()
cur = None
files = []
for line in raw:
    if "|" in line and re.match(r"^[0-9a-f]{7,40}\|", line):
        if cur and len(files) >= 25:
            add(cur["date"], "high-churn", cur["subj"], cur["sha"], 65, files[:12])
        sha, d, subj = line.split("|", 2)
        cur = {"sha": sha, "date": d, "subj": subj}
        files = []
    elif line.strip() and cur is not None:
        files.append(line.strip())
if cur and len(files) >= 25:
    add(cur["date"], "high-churn", cur["subj"], cur["sha"], 65, files[:12])

# Sort by date then score; keep top ~40
candidates.sort(key=lambda c: (c["date"], -c["score"]))
# Cap: prefer diversity by month
by_month = defaultdict(list)
for c in candidates:
    by_month[c["date"][:7]].append(c)
selected = []
for month in sorted(by_month.keys()):
    month_cands = sorted(by_month[month], key=lambda c: -c["score"])
    selected.extend(month_cands[:4])
selected = selected[:40]

# Suggested architecture snapshot dates: first + month ends with activity peaks
peaks = sorted(monthly.items(), key=lambda x: -x[1])[:6]
arch_dates = sorted({first_date[:7] + "-01"} | {f"{m}-15" for m, _ in peaks})

out = {
    "schema_version": 1,
    "analyzed_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ"),
    "head": head,
    "first_commit": {"sha": first_sha, "date": first_date, "subject": first_subj},
    "commit_count": total,
    "monthly_counts": dict(sorted(monthly.items())),
    "milestone_candidates": selected,
    "suggested_architecture_dates": arch_dates,
    "agent_instructions": (
        "Cluster candidates into 8–20 bilingual change events spanning first_commit→HEAD. "
        "Do not invent runtime behavior; use commit messages + paths as evidence. "
        "Create architecture/history snapshots at major eras. Mark needs-review. "
        "Set config.history_coverage.status=complete after apply."
    ),
}
print(json.dumps(out, indent=2, ensure_ascii=False))
PY
)"

printf '%s\n' "$OUT"

if [[ "$WRITE" -eq 1 ]]; then
  mkdir -p .project-memory/providers
  printf '%s\n' "$OUT" > .project-memory/providers/git-history-analysis.json
  echo "wrote .project-memory/providers/git-history-analysis.json" >&2
fi
