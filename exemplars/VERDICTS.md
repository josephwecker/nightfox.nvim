# Verdicts — Joseph's observation stream

*Contract (Joseph, 2026-08-28): he points out things that seem off as he
finds them, one message at a time — an observation is NOT necessarily "go
fix this now"; intermediate time may be used to investigate, but the intent
is simply to pass them along. Log every one here with its resolution state.*

| # | date | observation | diagnosis | state |
|---|---|---|---|---|
| 1 | 2026-08-28 | Opening `$` of inline latex unstyled while closing `$` gets the gate treatment | Every `$` carries two captures (our gate + the injected latex layer's whole-span `@markup.math`, since the injection includes children); the winner fell to a layer tie-break that resolves differently for open (same start col) vs close (starts inside the span) — and differently between tohtml and the live editor. Fixed: explicit `(#set! priority 105)` on the gate capture — deterministic in both renderers. | fixed |
| 2 | 2026-08-28 | `**` / `*` "merge in with the text … one smear"; dimmed sigils would materially improve reading | The gate principle generalized: fork queries now capture emphasis/strikethrough/code-span delimiters with parent context (`@punctuation.delimiter.{strong,italic,strikethrough,raw}`, priority 105) and the generator places each as dulled kin of its host family, contrast derived from its measured stats (30k strong-gates, 18k italic-gates, 10.5k backtick-gates in the corpus). Side-finding: allocation is census-sensitive — regenerating the census can move allocated hues (italic green→coral here); name-is-seed holds per census version. | fixed |
| 3 | 2026-08-28 | Front `$` still undimmed after verdict #1 fix | CAMERA artifact, not the scheme: builtin tohtml inserts captures in raw per-tree order — no priority, no cross-layer resolution — so meta-captures and later injection layers stomp real highlights; the live editor resolves correctly. Fix: snapshot.lua no longer uses tohtml; it renders the styletable itself with editor semantics (priority → layer → order, capture-name fallback chain). This resolver is the seed of the future ANSI emitter. | fixed |
