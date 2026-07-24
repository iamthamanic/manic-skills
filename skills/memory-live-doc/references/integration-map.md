# Integration map

Minimal insert points into other **global** skills. **Applied** (do not rewrite those skills wholesale).

## 1. `@implement` (`~/.cursor/skills/implement/SKILL.md`) — applied

After material implementation (near end / before verify handoff):

- Helper table row for `@memory-live-doc`
- §10 note: draft interactive **or** pipeline applies at ecc-check

## 2. `@ecc-check` (`~/.cursor/skills/ecc-check/SKILL.md`) — applied

Before READY:

- Phase E2: material changes since checkpoint → `@memory-live-doc` with `mode=apply`
- READY may proceed with docs marked `needs-review`; report doc health

## 3. `@ecc-runner` (`~/.cursor/skills/ecc-runner/SKILL.md` + `references/helper-skills.md`) — applied

- Pipeline comment: ecc-check includes memory-live-doc apply for material issues
- Helper table during ecc-check / docs

## 4. `@commit-push-safe` (`~/.cursor/skills/commit-push-safe/SKILL.md` §5b) — applied

- Prefer `## Recent changes` from latest `.project-memory/changes/*`
- Missing memory + material user-facing → `@memory-live-doc apply` before commit
- Stage `.project-memory/**` + `docs/**` with same commit

## 5. `@project-setup` (`~/.cursor/skills/project-setup/SKILL.md`) — applied

- Step 3: ensure **Living documentation** section in `AGENTS.md` (skeleton + append on existing)
- Step 9: if `.project-memory/checkpoint.json` missing → `@memory-live-doc bootstrap`
  - `init`: apply after short summary
  - `audit`: draft first, apply after user OK
  - Then `github-pages-memory.sh status --write-config`; enable **only** if `not_enabled` (never overwrite other Pages sites)
- Step 10 report: living-docs row + Pages status
- AGENTS skeleton: Living documentation section
- Setup report template: living-docs fields

## GitHub Pages safety

Policy: `memory-live-doc/references/github-pages-policy.md`  
Script: `memory-live-doc/scripts/github-pages-memory.sh`

Check **memory-live-doc Pages** vs **any Pages**:

- Pages off → may enable `/docs`
- Pages `/docs` → additive viewer path only
- Pages `/` or Actions or other path → refuse
## AGENTS.md snippet (repos) — also written on bootstrap apply

```markdown
## Living documentation

After material changes, run `@memory-live-doc` (or rely on `@implement` / `@ecc-check` / `@commit-push-safe` / `@project-setup` integration).

- Do not invent features in docs without evidence.
- Storage: `.project-memory/` (bilingual DE+EN JSON; human docs under `docs/` + `docs/en/`).
- Interactive viewer: `docs/memory-live-doc/viewer/` (GitHub Pages).
- First setup: `@project-setup` Step 9 or `@memory-live-doc bootstrap`.
```

On first **bootstrap apply**, `@memory-live-doc` appends this section if missing (see `bootstrap-checklist.md`).
