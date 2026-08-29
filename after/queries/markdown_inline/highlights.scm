;; extends
; autocolors (this fork): give math delimiters their own capture so $ / $$
; render as the dulled kin of the math family (PLAN.md; ruling: in
; |element[123] the sigil is a DULL shade of the element's hue).
; priority 105: the injected latex layer covers the whole span INCLUDING the
; delimiters (injection.include-children), so without an explicit priority
; the $ glyphs land on a layer tie-break — resolved differently by the
; editor vs tohtml, and observed rendering open/close gates differently
; (Joseph, 2026-08-28).
((latex_span_delimiter) @punctuation.delimiter.math
  (#set! priority 105))
