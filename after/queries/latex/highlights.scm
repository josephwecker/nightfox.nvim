;; extends
; autocolors (this fork): text-mode content inside math (\text{...} etc.) —
; the runtime query marks it @none (clear-all), which leaks host prose
; (verdict #7). Capture the words explicitly so the sibling scheme can give
; them sibling-prose tone: readable text, but a citizen of the math world.
((text_mode (curly_group (text) @markup.math.text)) (#set! priority 105))
