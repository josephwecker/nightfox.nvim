# PLAN — autocolors, the real deal (neovim first), on the nightfox chassis

*Seeded 2026-08-28 from the founding conversation (Joseph + agent, this repo's
first working session). Autocolors is a standalone program — NOT a child of
udon; the 2011 Ruby generator (vim output) and the 2026 udon-wasm engine
(Obsidian CSS) are both proofs of concept. This fork is where the real thing
gets built, initially for neovim only. Substrate: `~/src/arch/firmatum/udon/ux/
autocolors/` (2011 NOTES + archaeology, 2026-07-16 bridge plan) — the theory
lives there; the build lives here. Agent-drafted; Joseph's rulings quoted or
marked; agent proposals marked.*

## The triple (Joseph, 2026-08-28 — the definition of done)

The three pieces that were each only ever partially there until now:

1. **Very rich, nested, highly granular syntactic/semantic spans** for target
   languages, *including embedded other-languages*.
2. **Statistics over the target-language trees** — lexical densities and
   adjacencies — projecting #1 onto perceptual needs.
3. **A very rich hierarchical color scheme that satisfies #2**, on displays
   that can carry that much color.

Neovim supplies #1 for free (treesitter + LSP captures with byte-exact spans,
injections included). This fork's census tool is the start of #2 (see
[[markdown-census]]). #3 is the generator to be built here.

## Why this fork

Nightfox is architecturally the thesis the 2011 claim argues against — every
fox funnels through ~20 hand-assigned `spec.syntax` slots, and hundreds of
fine treesitter/LSP captures get `link`-collapsed back into them (the
interesting sub-captures are literally commented out in
`lua/nightfox/group/modules/treesitter.lua`). And it is simultaneously the
best donor body for the antithesis:

- **Keep**: the exhaustive highlight-group inventory (editor groups, full
  modern treesitter capture set + legacy aliases, LSP semantic tokens/typemods,
  42 plugin ecosystems in `group/modules/`) — the nvim column of the 2011
  mapping table, fifteen years matured; the runtime plumbing (override/
  template, compile cache, lualine/extras); the seven fox palettes as proven
  anchors — real light schemes included (dayfox/dawnfox).
- **Ditch** (ruled): all current mapping/collapse — the palette→spec-bucket
  pipeline. Captures become individually addressable leaves of a kinship tree;
  colors are derived ("parent, diverged slightly"), never hand-assigned per
  leaf.

Generated scheme families take the **-lynx** names: nightlynx / daylynx /
dawnlynx / dusklynx / nordlynx / teralynx / carbonlynx — initially "nuanced
extensions (with some stochastic variation) generated from those actual
colorschemes as the basis" (Joseph). Name IS the seed (2011/2026 invariant:
same name, same scheme, forever).

## Ruled 2026-08-28: parallel sibling schemes for embedded languages

Not in any prior planning — new ruling, stronger than the old
"diverge-slightly" note for embedded languages:

- An embedded language does **not** reuse the host's scheme with divergence.
  It gets a **designated parallel scheme drawn from the same family**:
  markdown-main from nightfox ⇒ generic code-fence from carbonfox, ruby fence
  from duskfox, etc.
- **High contrast between host and embedded is deliberate**: "they are
  literally different languages — different mental contexts altogether."
- **The background-color alteration is the key that is primarily missed**
  (Joseph): the fence/math block carries the sibling scheme's *background*,
  and the embedded foreground colors are contrast-solved against *that* bg,
  not the host's.
- What makes this lawful: the fox family shares one lightness/contrast
  architecture and differs in hue personality — so a sibling scheme is the
  same kinship tree run with a different personality seed, re-solved against
  its block bg. The family is a *palette of palettes*.
- Assignment map: explicit designations for languages that matter; unlisted
  languages hash their name to a family member (name-is-seed applied to
  languages — every language a stable identity, no committee). *(mechanism:
  agent proposal, unratified)*
- Composition guard *(agent proposal)*: sibling-distinctness scales down as
  embedded density rises (a doc that is half fences must not shatter) —
  measurable from census fence/math byte-share; a fitness term, not taste.

**Mechanics, verified 2026-08-28**: nvim resolves injected captures with a
language suffix (`@function.call.ruby`), so per-language columns are pure
emission — no runtime machinery. Block-level *background* needs line-level
decoration (the render-markdown `RenderMarkdownCode` mechanism); the fence-bg
painter and the colorscheme must agree, which is what makes a cos-side fork
of render-markdown load-bearing rather than optional. One design, two
cooperating emitters.

## Markdown first (ruled)

Udon's spec is in flux — udon is explicitly *not* a concern right now.
Markdown (the actual 2026 workload: briefs, specs, plans, theory segments) is
the first target, embedded fence languages included.

Census findings that shape the work (measured, 260 estate files — full data
and method in [[markdown-census]]):

- **Math is the dominant embedded language: 8.4% of corpus bytes, in 71% of
  files — ~10× code fences** (0.8%, 6% of files). First sibling scheme =
  **latex/math**, not fences. The bundled grammar already parses
  `latex_block`; installing the `latex` treesitter parser turns every math
  span into a full injected capture stream. Today math renders as plain prose
  — the largest unserved information class in the estate.
- **Bold+italic are a primary semantic channel here**: 9.5% of bytes. They
  get first-class information-class treatment, not styled-prose treatment.
- **Delimiter/conceal noise: ~74k tiny spans** — the measured target of the
  2011 plumbing-recedes rule; count matters perceptually even where area
  doesn't.
- Injection coverage is gated purely on parser installation (bundled: c, lua,
  markdown, markdown_inline, query, vim, vimdoc; estate fences are udon/sql/
  bash/yaml/text ⇒ zero injections fire today).

## Architecture (adapted from the 2026-07-16 bridge plan, five layers)

```
 [1] role stream   treesitter captures + LSP tokens, injections included (exists)
 [2] census        tools/markdown-census.lua → densities, span counts, areas;
                   adjacency pairs planned (this repo, started)
 [3] mapping       kinship tree replacing group/-collapse: every capture a leaf,
                   each leaf = parent + divergence marks, never a color
 [4] generator     fox-anchor personalities + OKLCH kinship divergence +
                   contrast solving vs actual bg + census-weighted emphasis
                   budget + name-as-seed; sibling-scheme assignment map
 [5] emission      nvim highlight groups (this fork's runtime applies them);
                   later: the block-bg decoration contract with render-markdown
```

*(Agent proposal, revised from an earlier Rust-engine recommendation and
unratified: generator in **Lua, in this fork** — nvim is the sole initial
target, the census input is Lua-native, and the dev loop that matters is
`:Autocolors nightlynx-3` regenerating live while eyeballing a real document.
Extract a library later, when "real deal" has earned its shape. The udon-wasm
Rust engine remains the Obsidian PoC, not the upstream of this.)*

## Phases

- **P1 — link-inversion refactor** *(next)*: break the `link` collapses in
  `group/` into the explicit kinship tree, values still fed from the existing
  spec — zero visual change, pure structure. Ship and sit on it.
- **P2 — census maturation**: adjacency pairs; per-buffer census at load
  (measured: instant); LSP-token census on real code buffers.
- **P3 — generator v1**: lynx schemes as generated extensions of the fox
  anchors; widened spec (tree, not 20 slots); WCAG/APCA contrast solving;
  stochastic variation under the name-seed.
- **P4 — sibling schemes**: math first (install latex parser), then fence
  languages; block-bg contract with the render-markdown fork (cos-side).
- **P5 — fitness**: the 2011 four criteria + composition budget as measured
  functions over census data; density-adaptive allocation; A/B against P3.
- **Beyond**: contextual emphasis (activity modes), other emission targets —
  gated on appetite, not feasibility.

## Open questions

- ~~Parser installation strategy~~ **Resolved 2026-08-28** (Joseph: "feel free
  to install parsers / treesitters / lsp"): nvim-treesitter main branch
  vendored per cos convention (pack/cos/start, pinned @ 8b98b44, VENDORED
  file), used as parser/query manager only — no config, no highlighting
  module. 15 parsers installed; udon parser remains future (spec in flux).
- Relationship to upstream: this fork will diverge structurally (group/ →
  kinship tree). Merging upstream fixes stays possible while P1 preserves
  group names; after P3, upstream is reference material, not a spec.
- Where the sibling-assignment map lives (scheme config vs. per-family file).
- cos integration: point cos's vendored colorscheme at this fork (agent
  recommendation, pending the moment nightlynx v1 is worth daily eyes).

## Log

- **2026-08-28** — Repo adopted as the autocolors vehicle (Joseph). Rulings:
  standalone-program status; markdown first / udon deferred; ditch the
  collapse; lynx naming; parallel sibling schemes with background alteration
  as the key and deliberate host↔embedded contrast. Census tool built and run
  on 260 estate files (`markdown-census.md`); math-dominance finding; verified
  `latex_block` parsing, injection gating, and per-language capture
  resolution. No code changes to the scheme itself yet.
- **2026-08-28 (later)** — Frontmatter noted by Joseph; already censused (212
  of 260 files). Parser green-light: nvim-treesitter vendored (manager-only),
  15 parsers compiled; estate re-census 25 → 76 capture pairs — math's
  internal anatomy (7 captures, 184 files) and frontmatter yaml decomposition
  now live. See markdown-census.md post-install section.
