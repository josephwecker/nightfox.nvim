# Verdicts — Joseph's observation stream

*Contract (Joseph, 2026-08-28): he points out things that seem off as he
finds them, one message at a time — an observation is NOT necessarily "go
fix this now"; intermediate time may be used to investigate, but the intent
is simply to pass them along. Log every one here with its resolution state.*

| # | date | observation | diagnosis | state |
|---|---|---|---|---|
| 1 | 2026-08-28 | Opening `$` of inline latex unstyled while closing `$` gets the gate treatment | Every `$` carries two captures (our gate + the injected latex layer's whole-span `@markup.math`, since the injection includes children); the winner fell to a layer tie-break that resolves differently for open (same start col) vs close (starts inside the span) — and differently between tohtml and the live editor. Fixed: explicit `(#set! priority 105)` on the gate capture — deterministic in both renderers. | fixed |
