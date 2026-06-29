# License Rules

Classify before recommending **übernehmen**.

## SPDX handling

| License | Recommendation |
|---------|----------------|
| MIT, Apache-2.0, BSD-2/3-Clause, ISC | **übernehmen** OK (attribute) |
| Unlicense, CC0 | **übernehmen** OK — verify intent |
| GPL-2.0, GPL-3.0, AGPL-3.0 | **inspirieren** only — warn on linking/copy |
| Proprietary / No license / null | **Referenz** only — no code copy |
| Unknown | **Referenz** — flag for manual check |

## Integration types

| Type | Requires |
|------|----------|
| npm/pip/cargo dependency | Permissive license + maintained repo |
| Copy snippet (<50 lines) | Permissive license + note source in commit |
| Copy architecture | **inspirieren** — rewrite, don't paste |
| Fork and modify | License compatibility + maintenance cost |

## Agent must not

- Run `npm install` / `pip install` without user approval
- Paste GPL code into proprietary projects
- Omit license field when recommending **übernehmen**

## Report format per match

```markdown
**License:** MIT — OK for dependency
**Recommendation:** inspirieren (pattern only)
```
