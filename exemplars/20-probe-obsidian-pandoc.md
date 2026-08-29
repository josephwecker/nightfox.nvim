# Obsidian & pandoc-residue probe

I need to highlight these ==very important words== inline.

Obsidian: a [[wikilink]] and [[target|aliased link]] and a #tag and %%an obsidian comment%% and an embed ![[image.png]].

> [!note] A callout title
> Callout body text here.

Inline html: some <small>fine print</small> and <sup>sup</sup> / <sub>sub</sub> and a line<br/> break and <span style="color:red">styled span</span>.

Pandoc residue: an html comment <!-- pandoc: converted from docx --> and entities &nbsp; &amp; &mdash; and a div:

<div class="warning" id="w1">
Block-level html content.
</div>

::: {.callout-warning}
Pandoc fenced div.
:::

Heading attrs {#sec-id .unnumbered}, a [reference link][ref1], escaped \*not bold\*.

[ref1]: https://example.com "Title"
