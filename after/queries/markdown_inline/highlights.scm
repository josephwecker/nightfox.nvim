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

; Emphasis / code-span gates: same principle as the math gates — the
; delimiter glyphs are the dulled kin of the family they open (verdict #2,
; Joseph 2026-08-28: undimmed ** / * "merge in with the text … one smear";
; dimming them makes the inner read as itself).
((strong_emphasis (emphasis_delimiter) @punctuation.delimiter.strong)
  (#set! priority 105))
((emphasis (emphasis_delimiter) @punctuation.delimiter.italic)
  (#set! priority 105))
((strikethrough (emphasis_delimiter) @punctuation.delimiter.strikethrough)
  (#set! priority 105))
((code_span (code_span_delimiter) @punctuation.delimiter.raw)
  (#set! priority 105))
