#!/usr/bin/env bash
# detect-history-coverage.sh — decide if git history backfill is required.
# Usage: detect-history-coverage.sh [repo_root]
# Prints key=value lines + one JSON object. Exit 0 always (detection never fails hard).
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
cd "$ROOT"

MEM=".project-memory"
json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

# Thresholds (mature project → expect timeline, not only last ~30 commits)
MIN_COMMITS_MATURE=40
MIN_MONTHS_MATURE=2
MIN_CHANGES_FOR_MATURE=8
# Also mature if medium activity over >=1 month
MED_COMMITS=20
MED_MONTHS=1

commit_count=0
first_date=""
last_date=""
span_months=0
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  commit_count="$(git rev-list --count HEAD 2>/dev/null || echo 0)"
  first_date="$(git log --reverse --format=%cs -1 2>/dev/null || echo "")"
  last_date="$(git log -1 --format=%cs 2>/dev/null || echo "")"
  if [[ -n "$first_date" && -n "$last_date" ]]; then
    # Approximate month span via Python (portable)
    span_months="$(
      python3 - "$first_date" "$last_date" <<'PY' 2>/dev/null || echo 0
import sys
from datetime import date
a, b = sys.argv[1], sys.argv[2]
fa = date.fromisoformat(a)
fb = date.fromisoformat(b)
months = (fb.year - fa.year) * 12 + (fb.month - fa.month)
print(max(0, months))
PY
    )"
  fi
fi

change_count=0
if [[ -d "$MEM/changes" ]]; then
  change_count="$(find "$MEM/changes" -type f -name '*.json' 2>/dev/null | wc -l | tr -d ' ')"
fi

arch_hist_count=0
if [[ -d "$MEM/architecture/history" ]]; then
  arch_hist_count="$(find "$MEM/architecture/history" -type f -name '*.json' 2>/dev/null | wc -l | tr -d ' ')"
fi

coverage_status="missing"
if [[ -f "$MEM/config.json" ]] && grep -q '"history_coverage"' "$MEM/config.json" 2>/dev/null; then
  coverage_status="$(
    python3 - <<'PY' 2>/dev/null || echo "unknown"
import json, pathlib
p = pathlib.Path(".project-memory/config.json")
data = json.loads(p.read_text())
hc = data.get("history_coverage") or {}
print(hc.get("status") or "unknown")
PY
  )"
fi

mature=false
reason_mature=""
if [[ "$commit_count" -ge "$MIN_COMMITS_MATURE" ]]; then
  mature=true
  reason_mature="commit_count>=${MIN_COMMITS_MATURE}"
elif [[ "$span_months" -ge "$MIN_MONTHS_MATURE" ]]; then
  mature=true
  reason_mature="span_months>=${MIN_MONTHS_MATURE}"
elif [[ "$commit_count" -ge "$MED_COMMITS" && "$span_months" -ge "$MED_MONTHS" ]]; then
  mature=true
  reason_mature="medium_activity_over_time"
fi

# Earliest change event date vs first commit (coverage gap)
earliest_change=""
if [[ -d "$MEM/changes" ]]; then
  earliest_change="$(
    python3 - <<'PY' 2>/dev/null || echo ""
import json, pathlib
dates = []
for p in pathlib.Path(".project-memory/changes").glob("*.json"):
    try:
        d = json.loads(p.read_text()).get("date") or ""
        if d:
            dates.append(d[:10])
    except Exception:
        pass
print(min(dates) if dates else "")
PY
  )"
fi

timeline_gap=false
if [[ -n "$first_date" && -n "$earliest_change" && "$earliest_change" > "$first_date" ]]; then
  # More than ~45 days after first commit → thin early coverage
  gap_days="$(
    python3 - "$first_date" "$earliest_change" <<'PY' 2>/dev/null || echo 0
import sys
from datetime import date
a, b = date.fromisoformat(sys.argv[1]), date.fromisoformat(sys.argv[2])
print((b - a).days)
PY
  )"
  if [[ "${gap_days:-0}" -gt 45 ]]; then
    timeline_gap=true
  fi
fi

action="none"
reason="coverage_ok_or_young_repo"

if [[ "$coverage_status" == "complete" || "$coverage_status" == "skipped" ]]; then
  action="none"
  reason="history_coverage=${coverage_status}"
elif [[ "$mature" == true ]]; then
  if [[ ! -d "$MEM" ]] || [[ ! -f "$MEM/checkpoint.json" ]]; then
    action="required"
    reason="bootstrap_mature_repo"
  elif [[ "$change_count" -lt "$MIN_CHANGES_FOR_MATURE" ]]; then
    action="required"
    reason="too_few_change_events_for_mature_repo"
  elif [[ "$timeline_gap" == true ]]; then
    action="required"
    reason="change_events_start_late_vs_first_commit"
  elif [[ "$arch_hist_count" -lt 3 && "$span_months" -ge 2 ]]; then
    action="recommended"
    reason="thin_architecture_history"
  else
    action="none"
    reason="mature_but_coverage_looks_adequate"
  fi
else
  action="none"
  reason="young_or_small_repo"
fi

echo "commit_count=${commit_count}"
echo "first_commit_date=${first_date}"
echo "last_commit_date=${last_date}"
echo "span_months=${span_months}"
echo "change_event_count=${change_count}"
echo "architecture_history_count=${arch_hist_count}"
echo "earliest_change_date=${earliest_change}"
echo "mature=${mature}"
echo "mature_reason=${reason_mature}"
echo "timeline_gap=${timeline_gap}"
echo "history_coverage_status=${coverage_status}"
echo "history_action=${action}"
echo "history_reason=${reason}"

printf '%s\n' "{\"commit_count\":${commit_count},\"first_commit_date\":\"$(json_escape "$first_date")\",\"last_commit_date\":\"$(json_escape "$last_date")\",\"span_months\":${span_months},\"change_event_count\":${change_count},\"architecture_history_count\":${arch_hist_count},\"earliest_change_date\":\"$(json_escape "$earliest_change")\",\"mature\":${mature},\"mature_reason\":\"$(json_escape "$reason_mature")\",\"timeline_gap\":${timeline_gap},\"history_coverage_status\":\"$(json_escape "$coverage_status")\",\"history_action\":\"$(json_escape "$action")\",\"history_reason\":\"$(json_escape "$reason")\"}"
