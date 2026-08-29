# Exemplars — pinned render-comparison corpus

*Created 2026-08-28 (Joseph: "a dozen or so exemplars from the estate to
compare screenshots of later"). These are **frozen copies** (long sources
trimmed to their first 250 lines; the snapshot window auto-sizes to full document height) so scheme
comparisons stay reproducible while the estate moves. Do not md-press or
otherwise canonicalize; they render as their sources rendered.*

| exemplar | source | why it's here |
|---|---|---|
| 01-math-deriv-edge-credence | arch/asf/01-aat-core/src/deriv-edge-credence-dynamics.md | math-densest class (595 latex spans in full file) |
| 02-math-form-composition | arch/asf/01-aat-core/src/form-composition-closure.md | math + formal-segment structure |
| 03-outline-asf | arch/asf/OUTLINE.md | deep heading/outline structure |
| 04-plan-cos | src/cos/PLAN.md | plan/tracker: tasks, checkboxes, dense lists |
| 05-sharpen-lists | src/cos/SHARPEN.md | nested lists, inline code, bold-led entries |
| 06-vivarium-format | arch/vivarium/FORMAT.md | frontmatter + spec register |
| 07-fences-vanantwerpen | udon/v2/references/ref/vanantwerpen-2018-scopes/content.md | fence-densest file in census (14 fences) |
| 08-math-fences-zwaan | udon/v2/references/ref/zwaan-2024-defining/… | math (748 spans) + fences together |
| 09-tables-terminator | udon/v2/references/ref/terminator-table.md | tables + fences |
| 10-prose-delegation | arch/AGENTIC-DELEGATION.md | long-form prose, blockquotes, emphasis-heavy |
| 11-narrative-changelog | arch/vivarium/changelog/2026-07-28-03-… | narrative prose register |
| 12-synthetic-all-features | (synthetic, this repo) | PROBE: every construct — 3 fence langs, table, quote, tasks, links, footnote |
| 13-synthetic-math | (synthetic, this repo) | PROBE: minimal inline+display math |
| 16-extended-syntax | (synthetic, this repo) | PROBE — extended-markdown coverage: alignment tables, definition lists, footnotes, ==highlight==, sub/superscript, heading IDs, emoji shortcodes, autolinks, tasks, ruby fence. The P1 shot doubles as the capture-gap report: definition lists, highlight, sub/sup, heading IDs, shortcodes, and bare URLs are UNCAPTURED by the grammar today — exactly the nuance layer autocolors exists to facilitate (markdownguide.org/extended-syntax) |
| 17-footnotes-litreview | arch/asf/02-tst-core/lit-review/formal-bounds-on-implementation-speed → specification-bound-prior-art.md | footnotes at natural density (80 defs), ==highlight== used in anger, inline math, html span |
| 18-aligned-tables-arxiv | ops/Recent_arXiv_papers_on_AI_alignment_welfare_and_agentic_systems.md | real alignment-spec table, 151 rows, links in cells |
| 19-notation-tables-math | arch/asf/NOTATION.md | math-inside-tables at reference density |
| 14-code-lua-kinship.lua | this repo, lua/nightfox/kinship.lua | plain code buffer (lua), comment-heavy |
| 15-code-lua-color.lua | this repo, lua/nightfox/lib/color.lua | plain code buffer (lua), logic-heavy |

## Probes vs. exemplars (Joseph, 2026-08-28)

The synthetics (12, 13, 16) are **coverage probes** — "is construct X
captured?" — and are **excluded from visual-coherence judgment**: a
1-of-everything page has no representative densities, so it renders as "a
bowl of jellybeans" under any scheme; there is no field for the figure to
stand against. Aesthetic verdicts come only from the real-density exemplars
(01–11, 17–19 for prose/markdown; 14–15 for code).

## Taking a comparison set

    tools/snapshot-all.sh SCHEME [light|dark]

writes `exemplars/shots/SCHEME/NN-name.png` (+ .html beside each).
`shots/` is gitignored except committed baselines. Baseline set:
`shots/nightfox-p1-baseline/` — taken 2026-08-28 at P1 (kinship tree,
pre-generator), the "before" for every lynx comparison.
