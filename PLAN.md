# PLAN — autocolors, the real deal (neovim first), on the nightfox chassis

*Seeded 2026-08-28 from the founding conversation (Joseph + agent, this repo's
first working session). Autocolors is a standalone program — NOT a child of
udon; the 2011 Ruby generator (vim output) and the 2026 udon-wasm engine
(Obsidian CSS) are both proofs of concept. This fork is where the real thing
gets built, initially for neovim only. Substrate: `~/src/arch/firmatum/udon/ux/
autocolors/` (2011 NOTES + archaeology, 2026-07-16 bridge plan) — the theory
lives there; the build lives here. Agent-drafted; Joseph's rulings quoted or
marked; agent proposals marked.*

## The quadruple (Joseph, 2026-08-28 — the definition of done)

The pieces that were each only ever partially there until now:

1. **Very rich, nested, highly granular syntactic/semantic spans** for target
   languages, *including embedded other-languages*.
2. **Statistics over the target-language trees** — lexical densities and
   adjacencies — projecting #1 onto perceptual needs.
3. **A very rich hierarchical color scheme that satisfies #2**, on displays
   that can carry that much color.
4. **Intent of the person viewing the file** — bug-fixing vs. progressive
   comprehension vs. mapping-to-side-effects; in markdown: first-time-reader
   vs. referencing vs. writer/maintainer perspective. (The 2011 NOTES
   §CONTEXTUAL EMPHASIS, rejoined 2026-08-28.) **Deferred** — but it is
   architecture-shaping now: intent doesn't just adjust the emphasis budget,
   it can *invert* it (fixing the math ⇒ prose goes dull-field, latex goes
   prominent — the same census, the opposite allocation). So the generator's
   signature is `scheme = f(census, intent)` with intent pinned at
   "reading/writing prose" for now; the parameter exists even while unvaried.
   Until then, #2's census guides "an appropriate balance and judicious use
   of sibling-schemes" (Joseph).

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
- Assignment map (**ratified 2026-08-28**): explicit designations for
  languages that matter; unlisted languages hash their name to a family
  member (name-is-seed applied to languages — every language a stable
  identity, no committee).
- **Block/inline split (ratified 2026-08-28, "right away")**: display math
  and fences get the full sibling identity, background alteration included;
  *inline* math and inline code get the sibling's hue identity but no (or
  whisper-level) background alteration — different-language-different-world
  stays fully intact where the eye enters a block; prose stays readable where
  the embedding is a three-character span mid-sentence.
- The earlier density-dial proposal (auto-dulling sibling distinctness as
  embedded share rises) is **parked**: density stays a P5 fitness
  *measurement*, not an automatic dial — and the latex-confetti case turns
  out to be an *intent* question (quadruple #4: fixing-the-math perspective
  legitimately wants prose dull and latex prominent), not a defect to
  engineer away. For now the census guides balance judiciously, by hand.

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

**Ratified 2026-08-28: generator in Lua, in this fork** (revised from an
earlier Rust-engine recommendation) — nvim is the sole initial target, the
census input is Lua-native, and the dev loop that matters is
`:Autocolors nightlynx-3` regenerating live while eyeballing a real document.
Extract a library later, when "real deal" has earned its shape. The udon-wasm
Rust engine remains the Obsidian PoC, not the upstream of this.

## Phases

- ~~**P1 — link-inversion refactor**~~ **LANDED 2026-08-28**:
  `lua/nightfox/kinship.lua` — every treesitter/LSP capture a node with an
  explicit parent; `group/modules/{treesitter,lsp_semantic_tokens}.lua` are
  now thin emitters from the tree. Formerly-implicit fallbacks materialized
  as parent links (902 → 929 groups, all individually addressable). Two
  upstream bugs fixed (marked DELTA in kinship.lua), and four `*.builtin`
  captures now follow kinship instead of accidentally inheriting nvim's
  runtime `link=Special` (Joseph loosened strict baseline preservation:
  "a lot of latitude for experimentation here"). Gotcha for all future
  verification: nightfox's compile cache (`~/.cache/nvim/nightfox/`) does
  NOT invalidate on module edits — `rm -rf` it or the old scheme keeps
  loading; a false "no diff" came from exactly this.
- **P2 — census maturation**: adjacency pairs; per-buffer census at load
  (measured: instant); LSP-token census on real code buffers.
- **P3 — generator v1**: lynx schemes as generated extensions of the fox
  anchors; widened spec (tree, not 20 slots); WCAG/APCA contrast solving;
  stochastic variation under the name-seed.
- **P4 — sibling schemes** *(next major milestone; scoped 2026-08-28 by
  verdict #7)*: math first — the current latex-kin monochrome block is
  replaced by the real design: the full latex capture set placed by the
  kinship machinery against the SIBLING fox's anchors (assignment map:
  math → designated fox; hash fallback for unlisted languages), contrast
  solved vs the block's bg. Includes a fork latex after-query capturing
  text-mode (`\text{}`) content explicitly — the runtime query marks it
  @none ("clear"), which is why it leaks host-prose today. Then fence
  languages by the same mechanism; block-bg contract with the
  render-markdown fork (cos-side). Also here: wire the cos pack to this
  fork so Joseph's live editor and the camera agree.
- **P5 — fitness**: the 2011 four criteria + composition budget as measured
  functions over census data; density-adaptive allocation; A/B against P3.
- **Beyond**: contextual emphasis (activity modes), other emission targets —
  gated on appetite, not feasibility.

## Tools

- `tools/markdown-census.lua` — capture census over a corpus (see
  markdown-census.md).
- `tools/snapshot.sh FILE [SCHEME] [OUT.png] [light|dark]` — full-color
  render of FILE under a scheme: headless nvim + builtin tohtml (byte-exact
  applied highlights, treesitter injections included) → headless Chrome PNG.
  The .html lands beside the PNG for inspection. This is the eyeball loop's
  camera — agents can *see* schemes without a GUI.
- `tools/hl-dump.lua` — dump all resolved highlight groups to a stable text
  file for diffing (`FOX_RTP=… FOX_SCHEME=… FOX_OUT=… nvim --headless
  --clean -l tools/hl-dump.lua`); strip `cterm=table: 0x…` noise before
  diffing. Remember the compile-cache gotcha (Log, 2026-08-28).

## Markdown futures (research, Joseph 2026-08-29)

- **Soft-wrap prose, never wrap tables** (scroll right for wide tables).
  Natively impossible: 'wrap' is window-local, not line-local (longstanding
  nvim limitation). Routes, ascending ambition: (a) *try first* —
  cursor-context auto-toggle: autocmd flips the window to nowrap when the
  cursor enters a pipe_table node (one treesitter call), back to
  wrap+breakindent on leave — tables as a "different reading mode," the
  sibling-worlds instinct in the layout dimension; (b) peek-float: wide
  table opens in a nowrap floating window on key/hover; (c) research-grade:
  the render-markdown fork conceals raw table lines and paints a
  VIRTUAL-TEXT VIEWPORT — table clipped to window width, horizontally
  scrollable by keys, prose around it wrapping normally. True per-region
  display semantics via extmarks (needs design against the cursor-line
  anti-conceal model; composes with sibling-bg since the fork owns table
  painting anyway).
- **Fixed reading measure** (soft-wrap prose at ~N columns regardless of
  window width; remaining space is margin). No native option: nvim has no
  'wrapwidth' — soft wrap always breaks at the window edge ('textwidth'/
  'wrapmargin' are hard-wrap: they insert real newlines, which would fight
  md-press's one-line-per-paragraph canonical form). Known knobs today:
  window width IS the wrap width (`:vertical resize 100`, drawer/split
  sizing); Neovide `neovide_padding_left/right` (global pixel margins);
  gutter tricks (`foldcolumn=9` + `signcolumn=yes:9` ≈ 18 cols left, not a
  real solution). Routes: (a) zen/centering pattern — dead side
  scratch-windows keeping the markdown window at fixed text width (what
  zen-mode-style plugins do; one autocmd could maintain it per-filetype);
  (b) the decoration layer pads (composes with the table-viewport and
  sibling-bg work if the fork owns page painting). Interacts with the
  never-wrap-tables entry above — a fixed measure plus scroll-right tables
  is the full "typeset page" feel.

## Open questions

- **Allocation stability across census regens**: allocated identity hues
  re-solve when the census changes (observed: italic green→coral when gate
  classes entered the adjacency graph). Name-is-seed holds for a fixed
  census; the census is effectively part of the seed. Decide whether that's
  correct (the scheme tracks the corpus) or whether identities should pin
  once ratified.

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
