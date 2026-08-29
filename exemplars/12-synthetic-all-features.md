# Title with `inline code` and **bold**

A [link](https://v2.io) and *italic* and ~~strike~~ and a footnote[^1].

```lua
local function greet(name, count)
  -- a comment
  for i = 1, count do
    print(("hello %s #%d"):format(name, i))
  end
  return { ok = true, when = os.time() }
end
```

```python
def greet(name: str, count: int = 3) -> dict:
    """docstring"""
    for i in range(count):
        print(f"hello {name} #{i}")
    return {"ok": True}
```

```c
#include <stdio.h>
static int greet(const char *name) {
  for (int i = 0; i < 3; i++) printf("hello %s #%d\n", name, i);
  return 0;
}
```

| col1 | col2 |
|------|------|
| a    | b    |

> a blockquote with **bold**

- [ ] unchecked task
- [x] checked task

[^1]: the footnote text.
