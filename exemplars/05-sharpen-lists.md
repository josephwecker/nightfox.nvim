# SHARPEN — muscle-memory & memorization log

*The log of implemented things that need practice, memorization, or habit-building (lineage: the `_older/mgt/` "sharpen-list for 10% time"). Habit tracking & empirical register formats: Joseph's, to be implemented. Things not yet built live in PLAN.md, not here.*

## To memorize / build muscle memory

- **`v file` / `:e file`** (2026-08-27, trial): from any shell, lands the file as a **buffer** in the one Neovide window (bufferline strip at the top), popped to front, tabpage `:tcd`'d to the shell's cwd. Last `v` wins for cwd — there is no longer a tabpage per file. No args = focus the editor. Multiple files become multiple buffers; the last one is shown.  
  *Watch:* restart the listening Neovide once so it picks up the new `init.lua` (`CosVEnsureFileWindow`). Same as 2026-08-26: a fresh app context may raise a one-time macOS Automation permission dialog — approve once.
- **`:Lex` / `:Lexplore`** (2026-08-27, trial): toggle the left file drawer (netrw, tree listing). `<CR>` / left-click opens in the file window (replaces). `t` adds the file as a buffer and stays in the drawer. `p` vertical preview. `-` parent dir (netrw default). Bufferline offsets so the file-tabs start to the right of the drawer.
- **Panes** (2026-08-28, trial): the drawer and the file are two **windows** in the same tabpage. Switch focus with a click, or:
  - `⌘Y` — focus the drawer, opening `:Lex` if it's closed; from the drawer, back to the file. Does not close the drawer.
  - `Ctrl-w h` — window left (file → drawer)
  - `Ctrl-w l` — window right (drawer → file)
  - `Ctrl-w w` — cycle windows
  - `Ctrl-w p` — previous window (toggles if you just switched)
  - In the drawer, `Ctrl-l` is netrw *refresh*, not window-right. Use `Ctrl-w l` (or `⌘Y` to leave).
- **Buffer-tabs** (2026-08-27, trial): the strip is **buffers**, not Neovim tabpages. `:tabclose` is the wrong command. Bindings deferred to the navigation walkthrough — these are the commands until then.

  Close this one (keeps the drawer; does not `:bdelete` the window):
  - `:Bd` — keyboard equivalent of the × (`:Bd!` if modified)
  - `:bd` / `:bd!` typed alone also run `:Bd` (not a count/`bdelete` form)
  - Mouse: hover the name → click ×, or right-click / middle-click the name
  - `:BufferLinePickClose` — letters on the strip, type one to close that buffer
  - Modified files refuse `:Bd` until `:w` or `:Bd!` (the × is already the `!` form)

  Close several:
  - `:BufferLineCloseOthers` — every buffer except this one
  - `:BufferLineCloseLeft` / `:BufferLineCloseRight`

  Switch:
  - `⌘1`…`⌘9` — that buffer-tab from the left; if fewer than N, the last one
  - `⌘L` — one tab right, wraps to the first
  - click the name
  - `:bn` / `:bp` (`:bnext` / `:bprev`)
  - `:BufferLineCycleNext` / `:BufferLineCyclePrev` — wraps either way
  - `:BufferLinePick` — letters on the strip, type one to jump
  - `:b filename` or `:buffer N`

  Reorder the strip:
  - `:BufferLineMoveNext` / `:BufferLineMovePrev`

  `:q` still quits the window/editor. `:bd` is the “close this tab” analogue.
- **`:Fs pattern` / `:R`** (2026-08-26): fold the buffer to lines matching a pattern (`:R` = ruby-ish default or `b:foldsearchexpr`). Old .gvimrc-era muscle memory; also a prose outliner — `:Fs ^#` in markdown.
- **`;s`** (2026-08-26): toggle syntax highlighting.
- **`:set ft=exptask|zml|nodus|ragel|…`** (2026-08-26): the ported legacy syntaxes are deliberately unmapped; invoke by hand when opening an old-format file.
- **`:Inspect`** (nvim built-in): full syntax/treesitter stack under the cursor — the deep, on-demand version of the statusline's SYN= readout.
- **`gl`** (2026-08-26): git graph-log again (shadowed omz's git-pull binding); `gitl` = `git log --no-merges --stat`; `gpo` = push all remotes + tags.
- **`gd` / `gd2` / `gd3`** (2026-08-26): plain diff / difftastic structural diff / delta side-by-side pager. Same args as `git diff` (`gd2 HEAD~1`, `gd3 --staged`).
- **`git pull` now refuses on divergence** (pull.ff=only, Joseph): when it aborts, choose explicitly — `git pull --rebase` or `git merge`.
- **`vc <target>`** (2026-08-26): edit any config by intent-name (Tab-completes: nvim, git, ghostty, plugins, aliases, env, cd, tools…); on close it runs the whole ritual — zgen reset when plugins changed, dotsync (prompts for message), drift check. The one command to remember for all config editing.
- **zsh config now lives in `~/.config/zsh/` by intent** (2026-08-26): env / profile / login / interactive/* / agent / human. The home-dir files are stubs — installer appends land below the marker and show up as `chezmoi status` drift; harvest them into the right partial (`vc env` etc.) when noticed.
- **`finds foo`** / **`locate foo`** (2026-08-26): case-insensitive filename find from `.` / machine-wide mdfind-by-name.
- **Neovide Cmd-layer** (2026-08-26, Joseph-authored; buffer-tabs 2026-08-28): ⌘V/⌘C/⌘X clipboard, ⌘A select-all, ⌘←/→ line start/end (⌘E end), ⌘⌫ kill-to-line-start. Buffer-tabs: ⌘1–9, ⌘L (right, wraps), ⌘Y (drawer). ⌘H is macOS Hide — parked; 0.16.2 cannot unbind it.
- **Markdown renders inline now** (2026-08-26): headings/bold/callouts/tables render in-buffer; the cursor's line shows raw source (Obsidian model). `:RenderMarkdown` toggles it when raw-everything is wanted.
- **`dotsync "msg"`** (pre-existing, now load-bearing daily): after editing any tracked dotfile. `chezmoi status` silent = safe.

## Empirical register

*(lessons learned the hard way; date · change · verdict · evidence)*

- 2026-08-26 · Neovide fonts match Ghostty (VictorMono NFM SemiBold primary, JuliaMono fallback, all four styles named) · earned same-day after correcting an inverted mix · lesson: Neovide renders only faces that actually exist — no synthesis — so a single-face install silently kills bold/italic; Ghostty synthesizes and masks the same gap. Also: Ghostty's first `font-family` is the roman, later entries are fallback — don't invent a per-style split from a fallback line. Diagnose with `nvim_get_hl` (is the attr requested?) vs. installed faces (can it render?).

- 2026-08-26 · render-markdown defaults · provisional keep ("ok, not amazing, better than vanilla" — JW) · de-flash pass queued in PLAN; the broader lesson: nvim-ecosystem defaults skew flashy/low-principle — expect to strip, not adopt.

## Habit tracking

*(format TBD by Joseph — placeholder for whatever tracking scheme gets implemented)*
