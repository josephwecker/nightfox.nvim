;; extends
; autocolors (this fork): block-grammar gates — heading markers and fence
; delimiters render as the dulled kin of what they open (verdict #6,
; Joseph 2026-08-28: "undulled ## and ` markers").
((atx_h1_marker) @punctuation.delimiter.heading.1 (#set! priority 105))
((atx_h2_marker) @punctuation.delimiter.heading.2 (#set! priority 105))
((atx_h3_marker) @punctuation.delimiter.heading.3 (#set! priority 105))
((atx_h4_marker) @punctuation.delimiter.heading.4 (#set! priority 105))
((atx_h5_marker) @punctuation.delimiter.heading.5 (#set! priority 105))
((atx_h6_marker) @punctuation.delimiter.heading.6 (#set! priority 105))
((setext_h1_underline) @punctuation.delimiter.heading.1 (#set! priority 105))
((setext_h2_underline) @punctuation.delimiter.heading.2 (#set! priority 105))
((fenced_code_block_delimiter) @punctuation.delimiter.fence (#set! priority 105))
