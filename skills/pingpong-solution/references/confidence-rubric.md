# Confidence Rubric

Report confidence as **XX%** with explicit criteria. Never exceed **95%**.

## Criteria (all must be ✅ for 90–95%)

| # | Criterion | ✅ when |
|---|-----------|---------|
| 1 | User intent clarified | User confirmed restatement OR answered Socratic round |
| 2 | Codebase mapped | Identified files, layers, existing patterns |
| 3 | Evidence sourced | Options cite codebase/docs; no invented SOTA |
| 4 | Cross-domain sign-off | No ❌ in matrix; ⚠️ documented |
| 5 | No open blockers | User decisions complete for v1 scope |

## Score bands

| Range | Meaning |
|-------|---------|
| **90–95** | All criteria ✅; ready for `/implement` |
| **75–89** | 1–2 ⚠️; implement OK with documented assumptions |
| **60–74** | Significant ⚠️ or unanswered Socratic items; recommend another pingpong round |
| **<60** | Do not recommend `/implement`; gather more input |

## Cap rules

- Open product question → cap at **85%**
- Unverified external claim → cap at **70%**
- AGENTS conflict unresolved → cap at **50%**
- User has not confirmed restatement → cap at **75%**

## Output format

Always include the criteria table in the recommendation section.
