# COS — plan & working tracker

*cos, cotis (Lat.)*  
: whetstone.  
: The program for Joseph's tooling & HCI refresh. To continually sharpen the saw.

## This Document / Plan

Seeded 2026-08-26 from the infra-archaeology session (old repos in `~/src/_older/`, chiefly `infra/` = josephwecker/infrastructure, frozen Nov 2018).

- It is currently the primary bootstrapping and migration plan AND tracker.
- Agent decisions should be marked as such to distinguish provenance & assumptions.

## Aims & principles

- **The editor's job in 2026**: agents write most code; Joseph writes markdown — briefs, specs, notes, edits-in-dialogue — plus configs and quick edits. Optimize for that workload, not the 2016 full-time-programmer one. (Reading/navigating agent-written code is a real secondary use; heavy IDE machinery is not the starting point.)
- **Muscle memory is the floor.** Existing reflexes are ported or deliberately replaced — never silently displaced. New capabilities get logged in SHARPEN.md for memorization / habit-tracking. (Earlier Neovim effort lesson: don't land more than muscle memory can absorb.)
- **Any fresh Linux machine reaches "feels like home" in one command.** This is what bashrc_dispatch + deploy-* delivered in the old world and what has been silently blocking the LLM training boxes. chezmoi is the carrier.
- **Invest in permanent, principled artifacts** over rented platform effort (the Obsidian wasm-plugin lesson). Prefer the artifact other tools can also consume (e.g. a treesitter grammar) over the platform-captive one.


## Ordered tasks

*(First unfinished on top. Finishing any implies properly committed and repeatable, deployed locally, dotfiles and zsh updated, and entries in [[SHARPEN.md]])*







- [ ] Editor: Navigation bindings walkthrough (JW+agent) — buffers/frames/tabs/panels idioms, then bind
- [ ] Archaeology: the non-easy remainder of `_older/` — explicatus (PIM/method
      material for the inculcation work), mgt (beyond sharpen.md), autocolors
      (the generator itself), sec/pw + secret-vault lineage, `.old-jwsys` configs
      (unread), jaw.io, extrinsic. Infra's easy layer is what's actually done.
- [ ] Editor: REOPENED — markdown wysiwyg/preview (the agent researched, chose
      render-markdown, and closed this unilaterally; Joseph's problem statement —
      CSS-configurable styling reflected in export, and the live preview pane —
      was not addressed and was not the agent's to close). render-markdown stays
      installed as a provisional piece, not a resolution.
- [ ] Editor: quiet the markdown rendering (JW+agent, interactive): strip render-markdown default icons/
      pills/bands to a quiet solarized-tuned minimum — keep structure rendering,
      delete the carnival. (Joseph verdict on defaults: "ok, not amazing"; the
      plugin is all flash, little principle — but fully strippable.)
- [ ] Editor: live preview pane — :w (or fswatch) → pandoc → HTML styled by OUR
      stylesheet → auto-reloading pane/browser (editor left, render right).
      Principled roll-our-own over markdown-preview.nvim's opaque server; the
      stylesheet doubles as the future styled-PDF-export design (one design,
      two outputs).
- [ ] Editor: fzf-native file jumping from inside nvim
- [ ] Editor: Prose-editing niceties (per-filetype wrap/breakindent polish)


- [ ] Linux bootstrap acceptance test: throwaway VM → one command → home.


---

## Topics

### Editor (neovim / neovide)

**Decided** (Joseph, this session):
- Full refresh in **neovim + lua**. No vim backward-compatibility ballast — "completely ditch the false backward-compatibility need for vim."
- Terminal (ghostty) / GUI behavior unification wherever available: one config, multiple faces.
- GUI: **Neovide** is the primary candidate (active, ligature/font-shaping support, `--server` mode); **VimR** the mac-native fallback (also active as of 2026-04); Goneovim discontinued. The old `v`-into-one-app-window habit is a requirement: nvim `--listen`/`--remote-tab` + Neovide `--server` reproduce it.
- No plugin distro; each plugin individually admitted (agent-proposed, drawn from Joseph's account of the failed distro-style attempt — unratified as a standing rule).
- **On trial** (2026-08-27, JW asked to land it): buffers-as-tabs (`bufferline.nvim`) + netrw `:Lexplore` as the left drawer; `v` uses `--remote` (buffers, one tabpage) not `--remote-tab`. Bindings still deferred to the walkthrough. Not a closed decision.
- Custom syntax lineage: the old jw syntaxes/forks were **patches against 2012-era deficiencies** — port only the still-live delta after checking what stock vim9/nvim+ treesitter now cover. Own-language syntaxes (udon, exptask, ragel-era…) survive on their own merits, pruned to what's still touched.

**Undecided**:

- Keymaps — deferred until a joint walkthrough of nvim/Neovide idioms for buffers, frames, tabs, side panels (old bindings were awkward on the MacBook keyboard; "shoot straight to idiomatic or in-between"). Format: comparative walkthrough vs. draft-and-tear-apart — Joseph to pick.
- Colors (trivial once the structure lands; old world solarized-light; own schemes murphytango/buttercream/cubdom/neutron and the many others available).

**Research**:

- **WYSIWYG**: Obsidian's biggest live affordance — cursor-line reverts to source, everything else renders, styling CSS-configurable and reflected in PDF export. Evaluate `render-markdown.nvim` / `markview.nvim` (same cursor-aware conceal interaction model) for the inline half; styled PDF export likely a separate pandoc/typst pipeline question. Not a deal-breaker either direction.
- Nerd-font glyph coverage in Neovide with VictorMono NFM / JuliaMono (expected fine — glyphs are in-font; verify live).
- **Treesitter grammar for udon** — the principled successor to the Obsidian wasm plugin; serves nvim + any other treesitter consumer. (Existing vim syntax at `~/src/arch/firmatum/udon/ux/vim`.)

### Shell & zsh

#### Decided

- zsh everywhere, including Linux boxes. The bashrc_dispatch *principle* carries
  forward (see Notes) — the bash implementation retires, not the idea.
- Factor `.zshrc` into partials by concern (bashrc_dispatch's separation/isolation aspiration, reborn); cdpath/cd block first.
- Joseph's aliases win over omz collisions: **`gl` = git log** (omz git plugin binds it to git pull — actively dangerous for his hands). Open sub-decision: shadow the collisions individually, or drop `plugins/git` and define only the aliases his hands actually know.


#### Notes

##### How zsh+chezmoi superseding bashrc_dispatch (to be proven during migration):  

`bashrc_dispatch` solves the following problems:

**Dispatch**
bash sources `.bashrc` / `.bash_profile` / `.profile` inconsistently across OS × login × interactive;
the script normalized this into once/all/script/interactive/login files.
zsh's file *order* is deterministic and OS-independent:

  - `.zshenv`   (every zsh invocation, scripts included) →
  - `.zprofile` (login shells, before zshrc) →
  - `.zshrc`    (interactive) →
  - `.zlogin`   (login shells, after zshrc — the "echo Welcome" slot)

Mapping: `bashrc_all`≈`.zshenv`, `bashrc_interactive`≈`.zshrc`, `bashrc_login`≈`.zlogin`.
`bashrc_script` has no dedicated slot (guard inside `.zshenv` if ever needed).
`bashrc_once` has no primitive; zsh's answer is idempotence instead — `typeset -U path`
dedupes PATH so re-sourcing is harmless.

**Why the dispatch principle survives into zsh** (recognized 2026-08-26, after the
agent faithfully reenacted the 2012 HN thread): zsh's four files are still
*entry-point-dependent mechanism* — which of them runs is emulator/OS convention
(macOS emulators launch every tab as a login shell; Linux emulators conventionally
don't, so `.zprofile` silently never runs in a Linux tab; ghostty-on-Linux default
unverified). The piecemeal fixes (idempotent `.zshenv`, `typeset -U path`, guards,
emulator settings) are a dispatcher hand-unrolled across four files and maintained by
memory. bashrc_dispatch's actual contribution was making the entry-point layer
*irrelevant* (every entry file → one dispatcher that reconstructs truth from shell
state: login? interactive? already-ran?) and exposing **intent-named** categories
(once/all/script/interactive/login) so content placement never requires platform lore.
Direction endorsed by Joseph (2026-08-26: *"it would be just as easy to port it to a
zsh-dispatch with all of the zsh affordances making it that much easier to implement
correctly"*): a zsh port of his bashrc_dispatch — all zsh entry files → one dispatcher
(zsh gives direct state reads: `[[ -o login ]]`, `[[ -o interactive ]]`) → intent-named
partials in `~/.config/zsh/`, which also gives the partials factoring its top-level
structure. Open: whether it joins the public bashrc_dispatch lineage or stays private.

Implementation notes (2026-08-26 discussion):
- zgen/starship/mise/atuin/fzf don't conflict — none write to `.zshrc`; they only need
  sourcing from the interactive partial (ordering constraints move intact).
- Symlinks (the 2012 bash implementation) are wrong here: installer `>> ~/.zshrc`
  appends would write *through* the symlink into the dispatcher. The unsolved 2012
  routing problem, addressed: **stub files** — `~/.zshrc` is a real 2-line file
  (source dispatcher + marker comment); installer appends land below the marker,
  keep working, show up as `chezmoi status` drift, and get harvested into the right
  partial by the `vc` close-ritual. Alternative: `ZDOTDIR` (fully native, but
  non-respecting installers create a stray never-sourced `~/.zshrc` — silent
  breakage of their setup); the two compose if ever wanted.
- **New semantic context (Joseph)**: fork **`agent` vs `human`** interactive — a routing
  level bash-dispatch never had (agent shells want lean, prompt-tool-free startup;
  detection mechanism TBD — e.g. `$CLAUDECODE`-style env markers).
- **Internal pre/post partials (Joseph)**: dispatcher-internal hooks bracketing the
  contexts, e.g. `zsh-dispatch/internal/post-all.zsh`.
- **ZDOTDIR: Joseph loves it.** Harvest designs floated: (a) a post-login hook that
  inspects `~/.zshrc` for new appends and interactively asks where each goes
  ("all" default / "once" / …); (b) simpler: appends auto-collected into
  `zsh-dispatch/zshrc-harvest.zsh`, sourced by default (all vs. once — TBD), with a
  `vc`-family command to file them properly later. Beyond immediate needs; parked.
- `vc` integrates with the dispatcher directly — making this an *installable helper*
  rather than bashrc_dispatch's file-and-readme, even if Joseph is its only user.

2. *Platform branching*: `shell_is_osx`/`shell_is_linux`
   at runtime. chezmoi moves most of this to apply-time — `{{ if eq .chezmoi.os
   "linux" }}` templates render per-OS files — and the few genuinely dynamic
   cases keep a runtime `$OSTYPE` check. What bashrc_dispatch has that zsh
   lacks natively — nothing structural; what it *aspired to* (clean separation
   by concern) carries into the partials factoring above.

###

### Chezmoi & Linux bootstrap

- Target: `chezmoi init --apply josephwecker` + one bootstrap hook = working environment on a fresh Linux box (the modern `deploy-*`).
- Needs: per-OS templating; tool-layer bootstrap (nvim, atuin, starship, mise, fzf, zsh via apt/brew — chezmoi `run_once_` scripts are the idiomatic slot); decide what is machine-local vs. universal.
- Relationship of dotfiles repo to cos (submodule? sibling?) — **undecided**; revisit when the plan stabilizes. (Precedent: explicatus was parent with infrastructure as a member.)

### Obsidian trajectory

- **Freeze investment** (proposed, Joseph-aligned this session): no new plugins, no new vault machinery (`link-vault.sh` is a hand-rolled chezmoi-for-Obsidian and a recurring maintenance tax). Keep Obsidian for what it's genuinely best at (WYSIWYG editing, rendering, PDF export) while the nvim refresh gradually takes load-bearing editing. Long-term role is an empirical question answered by usage, not forced now.
- udon wasm plugin + csv plugin: superseded once the udon treesitter grammar exists.

### Secrets (pw lineage)

- Old artifacts: `infra/bin/{pw,pw.rb}`, `infra/sec/pw`, likely `explicatus/` secret-vault relative. Concept strong; implementation stale (old Google API).
- Research: revive vs. adopt — compare against `age`/`sops`/1Password-CLI/passkey-era tooling.

### Archaeology (mining the _older repos)

**Misc Notes / Context**

- infra submodule reachability (`git submodule update --init`, 2026-08-26): 24/25 materialized — 10 at the 2018-recorded pins, 13 at upstream HEAD, 1 failed (`vim-ruby`, dead `git://` protocol; recoverable via  
  `git config url."https://github.com/".insteadOf git://github.com/` if ever wanted). All own-repo submodules present: murphytango, neutron, prim, vimerl, vim-elixir.
- infra contains stale credentials (old GitHub token in `git/gitconfig-global`, plaintext OANDA keys in `bashrc/bashrc_once`, an id_rsa in `.old-jwsys/`) — archival awareness only; nothing travels forward.
- Explicatus was the parent: `bashrc_once` paths (`~/explicatus/prj/infrastructure/...`) show infrastructure lived inside explicatus. Relevant precedent for cos's shape.
- Still to mine: explicatus (PIM/method material), mgt (sharpen-list, "is it worth the time" discipline — partially mined into SHARPEN.md), autocolors, murphytango, jaw.io, the `.old-jwsys` linux configs (unread so far).
- deploy-* scripts: likely to be superseded by chezmoi; deploy-bashrc read whole (n.b. it links `~/.bash*` → `../bash_dispatch/bashrc_dispatch` — a sibling-repo path, matching the parent-repo layout above).

**Research**

- [need to list the actual most likely repos here]


---

## Implementation Log

- **2026-08-28 (autocolors session)** — nvim-treesitter vendored (third-ish
  admitted plugin; pack/cos/start, pinned @ 8b98b44 main, VENDORED file) as
  **parser/query manager only** — no config, no modules; 15 parsers compiled
  (latex, yaml, python, ruby, rust, bash, sql, html, css, javascript, json,
  toml, regex, elixir, erlang) to `~/.local/share/nvim/site/parser/`. Driver:
  the autocolors work in `~/src/nightfox.nvim` (see its PLAN.md +
  markdown-census.md) — markdown math spans, fence languages, and yaml
  frontmatter now carry full injected capture streams. Note: parsers dir is
  machine-local (not chezmoi); reinstall via
  `require("nvim-treesitter").install({...})` — candidate for a chezmoi
  run_once script when the Linux bootstrap lands.

- **2026-08-28** — `v` from a new cwd with the drawer open: `--remote` `:drop` into a focused Lexplore window wipes it (`bufhidden=wipe`) and `:vnew`/`:Lexplore`'s `:new` left listed `[No Name]` buffers under `'hidden'`. Fix: one `CosVOpen` luaeval (edit in a non-netrw window, `tcd`, reopen Lexplore if it vanished, wipe stray unnamed unshown buffers). Restart Neovide + new shell.

- **2026-08-28** — Buffer-tab close keeps the window (JW): `:Bd` / × / right- and middle-click call `CosBufferClose` (switch the file window to the next strip entry, then `:bdelete`) so the netrw drawer does not go full-width. Bare `:bd` / `:bd!` cabbrev to `:Bd`. Bufferline has no such closer of its own; `close_command` is a hook (docs point at bufdelete.nvim).

- **2026-08-28** — Buffer-tab Cmd bindings (JW): ⌘1–9 → buffer-tab N (or last if fewer); ⌘L steps right and wraps; ⌘Y focuses the netrw drawer, opening `:Lexplore` if closed, and returns to the file window from the drawer (does not close it). ⌘H parked — macOS Hide; Neovide 0.16.2 has no `system-hide-hotkey`. Hide-rebind via `NSUserKeyEquivalents` did not take; reverted.

- **2026-08-27** — File drawer + buffers-as-tabs trial (JW asked to land it):
  vendored `bufferline.nvim` v4.9.1 (`655133c`, pack/cos/start, VENDORED file)
  as the second admitted plugin; quiet config (no slant/diagnostics/filetype
  icons, no web-devicons). `v` switched `--remote-tab` → `--remote` so files
  land as buffers in one tabpage; `CosVEnsureFileWindow` so a focused netrw
  drawer is not replaced. Netrw configured as `:Lexplore` drawer (tree,
  banner off, `<CR>` → previous window, `t` remapped to `:badd` and stay).
  Last `v` still `:tcd`s the (single) tabpage to the shell cwd. Restart the
  listening Neovide once. Navigation bindings still deferred to the walkthrough.
  **Trial, not a closed decision** — swap netrw→nvim-tree later if the strip
  feels right and the listing doesn't.

- **2026-08-26 (night)** — Markdown WYSIWYG: research verdict — render-markdown.nvim
  is exactly the Obsidian interaction model (persistent inline render, cursor line
  raw via anti-conceal); markview.nvim drops rendering on cursor movement — wrong
  model. Vendored render-markdown as a native pack (pinned 4663eb3 2026-08-11,
  VENDORED file carries provenance; no plugin manager), default config, rendering
  verified (40 extmarks on PLAN.md headless). First deliberately-admitted plugin.
  Still open in Topics/Research: styled PDF export (pandoc/typst pipeline) — the
  half of Obsidian's affordance this doesn't cover.

- **2026-08-26 (night)** — Shell wrap-up: cross-OS guards landed (locate→mdfind and
  _v_focus darwin-only; vc portable checksum; linuxbrew branch in env.zsh) — the
  partials are linux-safe by construction; only the VM acceptance test remains.
  finds/la/g/locate now covered on both OSes (la/g via omz, in dotfiles). Full omz
  alias audit (233): gl was the only muscle-memory collision (already shadowed);
  four git-aliases shadow brew-coreutils g-binaries (gpr/grm/gc/gcp → git
  pull-rebase/rm/commit/cherry-pick) — left in place, recorded so a surprise
  `gcp` has a known cause; command-not-found plugin likely inert on macOS
  (works on linux; harmless here).

- **2026-08-26 (night, corrected next morning)** — **zsh config factoring built and
