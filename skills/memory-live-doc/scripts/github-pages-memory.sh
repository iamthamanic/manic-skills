#!/usr/bin/env bash
# Detect / safely enable GitHub Pages for memory-live-doc viewer.
# NEVER overwrite an existing Pages site that serves something else.
#
# Usage (from repo root):
#   bash ~/.claude/skills/memory-live-doc/scripts/github-pages-memory.sh status
#   bash ~/.claude/skills/memory-live-doc/scripts/github-pages-memory.sh enable
#   bash ~/.claude/skills/memory-live-doc/scripts/github-pages-memory.sh enable --write-config
#
# Exit codes:
#   0 = ok / noop / enabled
#   2 = Pages owned by something else (refused to change)
#   3 = missing prerequisites (gh, git remote, private/plan, etc.)
#   4 = usage / unexpected API error

set -euo pipefail

ACTION="${1:-status}"
WRITE_CONFIG=false
for arg in "${@:2}"; do
  case "$arg" in
    --write-config) WRITE_CONFIG=true ;;
    *) echo "error: unknown flag: $arg" >&2; exit 4 ;;
  esac
done

VIEWER_REL="docs/memory-live-doc/viewer"
VIEWER_MARKER="memory-live-doc/viewer"

die() { echo "error: $*" >&2; exit 3; }
json_field() {
  # usage: json_field '<json>' 'jq-expr'
  printf '%s' "$1" | jq -r "$2" 2>/dev/null
}

command -v gh >/dev/null || die "gh CLI not found"
command -v jq >/dev/null || die "jq not found"
command -v git >/dev/null || die "git not found"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"

REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
[[ -n "$REMOTE_URL" ]] || die "no origin remote"

# owner/repo from origin
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
[[ -n "$REPO" ]] || die "could not resolve GitHub repo via gh"

DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo main)"
VISIBILITY="$(gh repo view --json isPrivate -q .isPrivate 2>/dev/null || echo true)"
OWNER="$(echo "$REPO" | cut -d/ -f1)"
NAME="$(echo "$REPO" | cut -d/ -f2)"

# Expected viewer URLs for common source layouts
expected_viewer_url_for_docs() {
  echo "https://${OWNER}.github.io/${NAME}/${VIEWER_MARKER}/"
}
expected_viewer_url_for_viewer_root() {
  echo "https://${OWNER}.github.io/${NAME}/"
}

# Fetch Pages config (404 → not configured)
PAGES_HTTP=0
PAGES_JSON=""
set +e
PAGES_JSON="$(gh api "repos/${REPO}/pages" 2>/dev/null)"
PAGES_HTTP=$?
set -e

HAS_PAGES=false
BUILD_TYPE=""
SOURCE_BRANCH=""
SOURCE_PATH=""
HTML_URL=""
STATUS_GH=""

if [[ $PAGES_HTTP -eq 0 && -n "$PAGES_JSON" ]]; then
  HAS_PAGES=true
  BUILD_TYPE="$(json_field "$PAGES_JSON" '.build_type // empty')"
  SOURCE_BRANCH="$(json_field "$PAGES_JSON" '.source.branch // empty')"
  SOURCE_PATH="$(json_field "$PAGES_JSON" '.source.path // empty')"
  HTML_URL="$(json_field "$PAGES_JSON" '.html_url // empty')"
  STATUS_GH="$(json_field "$PAGES_JSON" '.status // empty')"
fi

# Local viewer present?
LOCAL_VIEWER=false
[[ -f "${VIEWER_REL}/index.html" && -d "${VIEWER_REL}/data" ]] && LOCAL_VIEWER=true

# Classify memory-live-doc Pages status
# - not_enabled: no Pages site
# - memory_viewer_active: Pages serves /docs (viewer at …/memory-live-doc/viewer/) OR Pages root IS the viewer folder
# - pages_compatible_docs: Pages = branch + /docs, but we cannot prove viewer is live yet (files maybe not pushed) — safe to ADD files, do NOT change Pages settings
# - pages_other: Pages on for something else (/, other path, Actions workflow, other branch) — DO NOT TOUCH
# - blocked_private: private repo / plan issues (best-effort)

STATUS="not_enabled"
VIEWER_URL=""
REASON=""
CAN_ENABLE=false
CAN_CHANGE_PAGES=false
ACTION_TAKEN="none"

if [[ "$VISIBILITY" == "true" ]]; then
  # still allow status; enable may fail — note it
  PRIVATE_NOTE="private_repo"
else
  PRIVATE_NOTE=""
fi

if [[ "$HAS_PAGES" != "true" ]]; then
  STATUS="not_enabled"
  REASON="GitHub Pages is not configured for this repository."
  CAN_ENABLE=true
  CAN_CHANGE_PAGES=true
  VIEWER_URL="$(expected_viewer_url_for_docs)"
else
  # Actions-based Pages: never rewrite workflows or source
  if [[ "$BUILD_TYPE" == "workflow" ]]; then
    STATUS="pages_other"
    REASON="Pages is Actions-based (build_type=workflow). memory-live-doc will not create/replace that workflow. Add the viewer under the existing site manually if desired."
    CAN_ENABLE=false
    CAN_CHANGE_PAGES=false
    VIEWER_URL=""
    # If prior config recorded our viewer URL, surface it without claiming we manage Pages
    if [[ -f .project-memory/config.json ]]; then
      PREV_URL="$(jq -r '.pages.viewer_url // empty' .project-memory/config.json 2>/dev/null || true)"
      PREV_STATUS="$(jq -r '.pages.status // empty' .project-memory/config.json 2>/dev/null || true)"
      if [[ "$PREV_STATUS" == "memory_viewer_active" && -n "$PREV_URL" ]]; then
        VIEWER_URL="$PREV_URL"
        REASON="Pages is Actions-based; previous memory-live-doc viewer_url kept for reference only — not modifying Pages."
      fi
    fi
  else
    # Legacy branch deploy
    norm_path="${SOURCE_PATH:-/}"
    case "$norm_path" in
      /docs)
        STATUS="pages_compatible_docs"
        VIEWER_URL="$(expected_viewer_url_for_docs)"
        REASON="Pages already deploys branch '${SOURCE_BRANCH}' from /docs. memory-live-doc viewer is a subdirectory — safe to add files; will NOT change Pages source."
        CAN_ENABLE=false
        CAN_CHANGE_PAGES=false
        # If local viewer exists, treat as ready-for-publish (active once pushed)
        if [[ "$LOCAL_VIEWER" == "true" ]]; then
          STATUS="memory_viewer_active"
          REASON="Pages /docs is active and local ${VIEWER_REL} exists. After push, viewer URL should work. No Pages config change needed."
        fi
        ;;
      /docs/memory-live-doc/viewer|/docs/memory-live-doc/viewer/)
        STATUS="memory_viewer_active"
        VIEWER_URL="$(expected_viewer_url_for_viewer_root)"
        REASON="Pages root is the memory-live-doc viewer folder."
        CAN_ENABLE=false
        CAN_CHANGE_PAGES=false
        ;;
      /)
        STATUS="pages_other"
        REASON="Pages deploys repository root (/). Changing to /docs would overwrite that site. Refusing."
        CAN_ENABLE=false
        CAN_CHANGE_PAGES=false
        ;;
      *)
        STATUS="pages_other"
        REASON="Pages source path is '${norm_path}' (branch '${SOURCE_BRANCH}'), not /docs or memory-live-doc viewer. Refusing to overwrite."
        CAN_ENABLE=false
        CAN_CHANGE_PAGES=false
        ;;
    esac

    # Wrong branch (e.g. gh-pages with unrelated site)
    if [[ "$STATUS" != "pages_other" && -n "$SOURCE_BRANCH" && "$SOURCE_BRANCH" != "$DEFAULT_BRANCH" ]]; then
      # /docs on a non-default branch might still be intentional docs — mark other if not our viewer root
      if [[ "$norm_path" != "/docs" && "$norm_path" != "/docs/memory-live-doc/viewer" && "$norm_path" != "/docs/memory-live-doc/viewer/" ]]; then
        STATUS="pages_other"
        REASON="Pages uses branch '${SOURCE_BRANCH}' with path '${norm_path}', not identified as memory-live-doc. Refusing."
        CAN_CHANGE_PAGES=false
        CAN_ENABLE=false
      fi
    fi
  fi
fi

emit_report() {
  jq -n \
    --arg status "$STATUS" \
    --arg reason "$REASON" \
    --arg repo "$REPO" \
    --arg default_branch "$DEFAULT_BRANCH" \
    --argjson has_pages "$HAS_PAGES" \
    --arg build_type "$BUILD_TYPE" \
    --arg source_branch "$SOURCE_BRANCH" \
    --arg source_path "$SOURCE_PATH" \
    --arg html_url "$HTML_URL" \
    --arg pages_status "$STATUS_GH" \
    --arg viewer_url "$VIEWER_URL" \
    --argjson local_viewer "$LOCAL_VIEWER" \
    --argjson can_enable "$CAN_ENABLE" \
    --argjson can_change_pages "$CAN_CHANGE_PAGES" \
    --arg action_taken "$ACTION_TAKEN" \
    --arg private_note "$PRIVATE_NOTE" \
    '{
      schema_version: 1,
      kind: "memory-live-doc-pages",
      status: $status,
      reason: $reason,
      repo: $repo,
      default_branch: $default_branch,
      has_pages: $has_pages,
      build_type: (if $build_type == "" then null else $build_type end),
      source: {
        branch: (if $source_branch == "" then null else $source_branch end),
        path: (if $source_path == "" then null else $source_path end)
      },
      html_url: (if $html_url == "" then null else $html_url end),
      github_pages_status: (if $pages_status == "" then null else $pages_status end),
      viewer_url: (if $viewer_url == "" then null else $viewer_url end),
      local_viewer_present: $local_viewer,
      can_enable: $can_enable,
      can_change_pages: $can_change_pages,
      action_taken: $action_taken,
      private_note: (if $private_note == "" then null else $private_note end)
    }'
}

write_config_pages() {
  local report_json="$1"
  local cfg=".project-memory/config.json"
  [[ -f "$cfg" ]] || return 0
  local tmp
  tmp="$(mktemp)"
  jq --argjson pages "$report_json" '.pages = $pages' "$cfg" >"$tmp" && mv "$tmp" "$cfg"
  echo "updated ${cfg} .pages" >&2
}

do_enable() {
  if [[ "$STATUS" == "memory_viewer_active" || "$STATUS" == "pages_compatible_docs" ]]; then
    ACTION_TAKEN="noop_already_compatible"
    REASON="${REASON} Enable skipped: no Pages overwrite required."
    return 0
  fi

  if [[ "$STATUS" == "pages_other" ]]; then
    ACTION_TAKEN="refused"
    echo "REFUSED: $REASON" >&2
    return 2
  fi

  if [[ "$STATUS" != "not_enabled" ]]; then
    ACTION_TAKEN="refused"
    echo "REFUSED: unexpected status=$STATUS" >&2
    return 2
  fi

  if [[ "$LOCAL_VIEWER" != "true" ]]; then
    die "local viewer missing at ${VIEWER_REL}/ — run @memory-live-doc apply first"
  fi

  # Create Pages: legacy, default branch, /docs only
  set +e
  CREATE_OUT="$(gh api -X POST "repos/${REPO}/pages" \
    -f build_type=legacy \
    -f "source[branch]=${DEFAULT_BRANCH}" \
    -f "source[path]=/docs" 2>&1)"
  CREATE_RC=$?
  set -e

  if [[ $CREATE_RC -ne 0 ]]; then
    # Already exists race
    if echo "$CREATE_OUT" | grep -qiE 'already exists|409'; then
      ACTION_TAKEN="noop_race_exists"
      STATUS="pages_compatible_docs"
      VIEWER_URL="$(expected_viewer_url_for_docs)"
      REASON="Pages already existed when enable was attempted; not modifying."
      return 0
    fi
    echo "error: failed to enable Pages: $CREATE_OUT" >&2
    return 3
  fi

  ACTION_TAKEN="enabled_docs_legacy"
  STATUS="memory_viewer_active"
  VIEWER_URL="$(expected_viewer_url_for_docs)"
  HAS_PAGES=true
  SOURCE_BRANCH="$DEFAULT_BRANCH"
  SOURCE_PATH="/docs"
  BUILD_TYPE="legacy"
  REASON="Enabled GitHub Pages: branch ${DEFAULT_BRANCH}, path /docs. Viewer: ${VIEWER_URL} (after push)."
  return 0
}

case "$ACTION" in
  status)
    REPORT="$(emit_report)"
    echo "$REPORT"
    if [[ "$WRITE_CONFIG" == "true" ]]; then
      write_config_pages "$REPORT"
    fi
    if [[ "$STATUS" == "pages_other" ]]; then
      exit 2
    fi
    exit 0
    ;;
  enable)
    RC=0
    do_enable || RC=$?
    REPORT="$(emit_report)"
    echo "$REPORT"
    if [[ "$WRITE_CONFIG" == "true" ]]; then
      write_config_pages "$REPORT"
    fi
    exit "$RC"
    ;;
  *)
    echo "usage: $0 status|enable [--write-config]" >&2
    exit 4
    ;;
esac
