# Markdown capture census — estate corpus, 2026-08-28

*What the treesitter role stream actually yields on the markdown this estate writes.
Method and tool at the bottom; this is input #2 of the autocolors triple (see [[PLAN]]):
measured lexical densities that tell the generator where information actually is.*

**Method, stated once:** real parsers, no regex. `vim.treesitter` over Neovim's
bundled split grammars (`markdown` block grammar + `markdown_inline`, the
tree-sitter-markdown pair), full injection tree walked (`parser:parse(true)`,
`for_each_tree`), captures from the runtime `highlights.scm` queries, byte-exact
spans from `node:range(true)`. Run headless on nvim 0.12.4.

## Corpus

260 files, 5,752,755 bytes:

- `~/src/arch/asf/OUTLINE.md`, `~/src/arch/asf/01-aat-core/OUTLINE.md`
- `~/src/arch/asf/01-aat-core/src/**/*.md` (173 files — the deriv/def/form segments)
- `~/src/arch/vivarium/{FORMAT,ORIENT,ASF,ETHICS}.md`, `core/OUTLINE.md`, `ref/architecture-audit.md`
- `~/src/arch/firmatum/udon/v2/references/**/*.md` (79 files, archives included)

A skew worth naming: this corpus is theory-heavy (asf segments dominate byte count).
Briefs/plans/logs (e.g. cos PLAN.md, censused separately 2026-08-28) have the same
capture vocabulary with different densities — more lists, less math.

## Aggregate (capture × count × bytes × files-present)

| lang | capture | n | bytes | % of corpus | files |
|---|---|---:|---:|---:|---:|
| markdown | @spell (plain prose) | 15,893 | 5,113,245 | 88.9% | 258 |
| markdown | @keyword.directive (frontmatter fence) | 212 | 46,535 | 0.8% | 212 |
| markdown | @markup.raw.block (fenced code) | 70 | 45,796 | 0.8% | 16 |
| markdown | @markup.heading.2 | 1,159 | 37,130 | 0.6% | 226 |
| markdown | @markup.heading.3 | 796 | 36,781 | 0.6% | 179 |
| markdown | @punctuation.special | 14,961 | 29,035 | 0.5% | 219 |
| markdown | @markup.heading.4 | 732 | 25,267 | 0.4% | 125 |
| markdown | @markup.heading (5/6 + setext) | 1,033 | 24,932 | 0.4% | 129 |
| markdown | @markup.heading.1 | 288 | 19,036 | 0.3% | 257 |
| markdown | @markup.quote | 30 | 16,039 | 0.3% | 16 |
| markdown | @markup.list (markers only) | 4,466 | 9,530 | 0.2% | 220 |
| markdown | @label | 19 | 72 | — | 6 |
| markdown_inline | @markup.strong | 7,538 | 289,559 | 5.0% | 228 |
| markdown_inline | @markup.italic | 9,018 | 256,769 | 4.5% | 229 |
| markdown_inline | @nospell | 7,512 | 180,926 | 3.1% | 256 |
| markdown_inline | @markup.raw (inline code) | 5,257 | 118,103 | 2.1% | 213 |
| markdown_inline | @conceal (delimiters) | 58,764 | 58,766 | 1.0% | 232 |
| markdown_inline | @markup.link.label | 2,190 | 56,585 | 1.0% | 233 |
| markdown_inline | @_label | 852 | 39,106 | 0.7% | 24 |
| markdown_inline | @markup.link | 7,055 | 26,543 | 0.5% | 233 |
| markdown_inline | @markup.link.url | 884 | 21,694 | 0.4% | 24 |
| markdown_inline | @string.escape | 3,338 | 6,728 | 0.1% | 126 |
| markdown_inline | @markup.strikethrough | 31 | 2,235 | — | 11 |

*(Percentages overlap — inline captures nest inside block @spell spans.)*

**Plus, not in the highlights queries but in the parse tree** (queried directly):

| node | n | bytes | % | files |
|---|---:|---:|---:|---:|
| markdown_inline `latex_block` ($…$ / $$…$$) | **19,510** | **482,576** | **8.4%** | **184** |

## Findings

1. **Math is the dominant embedded language — ~10× fences.** 8.4% of all bytes
   sit inside latex spans, in 71% of files (asf deriv segments run 300–600 math
   spans *each*; `zwaan-2024-defining.md` has 748). Fenced code is 0.8% in 6% of
   files. For this estate, the first sibling-scheme to build is **math**, not
   code fences. The bundled `markdown_inline` grammar already parses
   `latex_block` and the runtime injection query routes it to a `latex` parser —
   which is simply not installed. Today those spans render as *undifferentiated
   prose* (they don't even get `@markup.math`): the single largest unserved
   information class in the corpus.

2. **The injection machinery is proven but currently fires on nothing.** Zero
   injected-language captures across all 260 files: fence info-strings in this
   corpus are `udon×9, sql×4, text×4, bash×1, yaml×1` plus untagged — none with
   a bundled parser (bundled: `c, lua, markdown, markdown_inline, query, vim,
   vimdoc`). A separate fence-rich test file confirmed lua/c fences yield their
   full fine capture streams (`@function.method.call`, `@keyword.modifier`,
   `@module.builtin`, …) the moment the parser exists. Parser installation is
   the whole gate — and per-language highlight resolution (`@variable.lua`
   inside a lua fence) means each installed language can carry its own sibling
   scheme with no runtime machinery.

3. **Emphasis inline spans are enormous: strong+italic = 546KB, 9.5% of the
   corpus**, ~16.5k spans. In this estate bold/italic are not decoration — they
   are a primary semantic channel (steward-voice, term-introduction, citation
   texture). The emphasis budget should treat them as first-class information
   classes, not styled prose.

4. **Delimiter noise is huge in count, tiny in area**: `@conceal` 58,764
   one-byte spans; `@punctuation.special` 14,961 spans at 0.5% of bytes. The
   2011 plumbing-recedes rule has its measured target — and the *count* matters
   perceptually even where area doesn't (58k glints of anything bright would
   shatter a page).

5. **Frontmatter appears in 212 of 260 files** and currently captures only its
   `---` fences (`@keyword.directive`); yaml body would need the yaml parser —
   another sibling-scheme candidate, low priority (small areas).

6. **Heading mass is well-behaved**: h2+h3 dominate (as structure should), h1
   nearly one-per-file. Levels are distinct captures — the kinship tree can
   shade depth directly.

7. **Link anatomy is fully decomposed** (label / url / delimiters / `@_label`
   wiki-style) — 233 files have links; url spans concentrate in 24 reference-
   style files. Fine-grained treatment is available; the collapse in current
   schemes is a choice, not a limit.

## Implications for the generator (see PLAN)

- Density-adaptive emphasis has real spread to work with: prose 89%, math 8.4%,
  emphasis 9.5%, headings ~2.3%, code ~3% — and per-file variance is extreme
  (deriv segments vs. logs). Per-buffer census at load is cheap (this whole
  260-file run took seconds; single file is instant).
- Balance rule targets: the 58k-span conceal/punctuation class must recede;
  math and fences earn background-alteration (block-level sibling identity);
  strong/italic earn hue identity, not just weight.

## Post-parser-install re-census (same day)

Joseph green-lit installing parsers; nvim-treesitter (main, parser/query
manager only) vendored at `~/.config/nvim/pack/cos/start/nvim-treesitter`
(@ 8b98b44, VENDORED file), and 15 parsers compiled: latex, yaml, python,
ruby, rust, bash, sql, html, css, javascript, json, toml, regex, elixir,
erlang. Same 260-file corpus, injections now live: **25 → 76 capture pairs.**

| lang | top captures | n | bytes | files |
|---|---|---:|---:|---:|
| latex | @function (\int, \frac, \sqrt, …) | 43,598 | 236,515 | 183 |
| latex | @markup.math (whole spans) | 19,739 | 476,568 | 184 |
| latex | @punctuation.bracket | 37,747 | 37,747 | 182 |
| latex | @operator | 34,643 | 34,643 | 184 |
| latex | @_name / @module / @label / @markup.strong | ~1,110 | ~5,000 | — |
| yaml | @string / @property / delimiters | 5,572 | 45,575 | 213 |
| html | tag anatomy (5 captures) | 4,212 | 11,929 | 11 |
| sql | full anatomy (keywords, types, members…) | ~400 | ~1,400 | 1 |

The math class alone went from *one undifferentiated node type* to a
seven-capture internal anatomy present in 184 files — command names are 49%
of math bytes. Frontmatter yaml decomposes in every file that has it.
Remaining uninjected: `udon` fences (own parser, future — udon spec in flux)
and untagged fences.

## Tool

`tools/markdown-census.lua` in this repo. Run:

```sh
ls path/**/*.md > /tmp/corpus.txt
CORPUS=/tmp/corpus.txt nvim --headless -u NORC -l tools/markdown-census.lua
```

Emits TSV: `TOTAL` line, `AGG` rows (lang, capture, n, bytes, files),
`FILE` rows (path, size, capture-pairs, langs, fences, fence-langs, math-spans).
Adjacency-pair census (which classes neighbor which) is a planned extension —
the composition/neighbor-coherence fitness term needs it.
