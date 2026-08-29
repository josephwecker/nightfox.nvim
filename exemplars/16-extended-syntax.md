# Extended syntax exercise {#custom-id}

## Tables with alignment

| left-aligned | centered | right-aligned |
|:-------------|:--------:|--------------:|
| aa           |    bb    |            cc |
| longer cell  |  center  |          1234 |

## Definition lists

First Term
: This is the definition of the first term.

Second Term
: One definition of the second term.
: Another definition of the second term.

## Footnotes

Here's a simple footnote,[^1] and here's a longer one.[^bignote]

[^1]: This is the first footnote.
[^bignote]: Here's one with multiple paragraphs and code.

    Indent paragraphs to include them in the footnote.

## Strikethrough, highlight, sub/superscript

~~The world is flat.~~ We now know it is ==very important== to write H~2~O
and X^2^ correctly. E = mc^2^ either way.

## Task lists

- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media

## Emoji shortcodes and literal

Gone camping! :tent: Be back soon. That is so funny! :joy: (literal: 🏕️ 😂)

## Automatic URL linking

http://www.example.com and <https://v2.io> and not `http://in-code.example`.

## Heading IDs referenced

[Jump to the top](#custom-id).

## Fenced code with language (baseline for comparison)

```ruby
def greet(name, count: 3)
  count.times { |i| puts "hello #{name} ##{i}" }
  { ok: true }
end
```
