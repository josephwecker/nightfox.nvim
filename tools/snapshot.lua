-- snapshot.lua — render FILE with a colorscheme to standalone HTML with the
-- EDITOR'S OWN resolution semantics (autocolors camera; see PLAN.md).
--
-- Why not builtin tohtml: it inserts captures in raw per-tree iteration
-- order — no priority, no cross-layer resolution — so colorless meta
-- captures and later-iterated injection layers stomp real highlights
-- (verdict #3, 2026-08-28: opening $ of inline math rendered unstyled /
-- as whole-span math while the editor shows the dim gate). The editor
-- resolves per cell by (priority, layer order); we do the same here.
-- This resolver is also the seed of the future ANSI emitter (layer [5]).
--
-- Env: SNAP_FILE, SNAP_OUT (html path), SNAP_SCHEME (default nightfox),
--      SNAP_BG (dark|light), SNAP_RTP (colorscheme repo root)

local rtp = os.getenv("SNAP_RTP")
if rtp then
  vim.opt.rtp:prepend(rtp)
  vim.opt.rtp:append(rtp .. "/after") -- after/queries extensions
end
local site = vim.fn.stdpath("data") .. "/site"
vim.opt.rtp:append(site)
for _, p in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/pack/*/start/nvim-treesitter", true, true)) do
  vim.opt.rtp:append(p)
end

vim.o.background = os.getenv("SNAP_BG") or "dark"
vim.cmd.colorscheme(os.getenv("SNAP_SCHEME") or "nightfox")
vim.cmd.edit(vim.fn.fnameescape(os.getenv("SNAP_FILE")))
local buf = vim.api.nvim_get_current_buf()
local ft = vim.filetype.match({ buf = buf })
local lang = ft and (vim.treesitter.language.get_lang(ft) or ft) or nil

local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

-- cellhl[row][col] = { prio, layer, ord, name } — later/higher wins
local cellhl = {}
for i = 1, #lines do
  cellhl[i] = {}
end

local META = { spell = true, nospell = true, conceal = true, none = false }
local function is_meta(name)
  return META[name] or name:sub(1, 1) == "_"
end

local ok_parser, parser = pcall(vim.treesitter.get_parser, buf, lang)
if ok_parser and parser then
  parser:parse(true)
  local layer_i = 0
  local ord = 0
  parser:for_each_tree(function(tstree, ltree)
    layer_i = layer_i + 1
    local l = ltree:lang()
    local q = vim.treesitter.query.get(l, "highlights")
    if q then
      for id, node, metadata in q:iter_captures(tstree:root(), buf, 0, -1) do
        local name = q.captures[id]
        if not is_meta(name) then
          ord = ord + 1
          local prio = tonumber(metadata.priority or (metadata[id] and metadata[id].priority))
            or vim.hl.priorities.treesitter
          local hlname = "@" .. name .. "." .. l
          local sr, sc, er, ec = node:range()
          for row = sr, math.min(er, #lines - 1) do
            local from = (row == sr) and sc or 0
            local to = (row == er) and ec or #(lines[row + 1] or "")
            local cells = cellhl[row + 1]
            for col = from, to - 1 do
              local cur = cells[col]
              if not cur or prio > cur.prio or (prio == cur.prio and (layer_i > cur.layer or (layer_i == cur.layer and ord >= cur.ord))) then
                cells[col] = { prio = prio, layer = layer_i, ord = ord, name = hlname }
              end
            end
          end
        end
      end
    end
  end)
end

-- resolve a highlight name with the editor's capture fallback:
-- @a.b.c.lang -> @a.b.c -> @a.b -> @a
local hl_cache = {}
local function resolve(name)
  if hl_cache[name] ~= nil then
    return hl_cache[name]
  end
  local probe = name
  while probe do
    local h = vim.api.nvim_get_hl(0, { name = probe, link = false })
    if next(h) ~= nil and (h.fg or h.bg or h.bold or h.italic or h.underline or h.strikethrough) then
      hl_cache[name] = h
      return h
    end
    probe = probe:match("^(.*)%.[^.]+$")
    if probe == "@" or probe == "" then probe = nil end
  end
  hl_cache[name] = false
  return false
end

local function css(h)
  local parts = {}
  if h.fg then parts[#parts + 1] = ("color:#%06x"):format(h.fg) end
  if h.bg then parts[#parts + 1] = ("background-color:#%06x"):format(h.bg) end
  if h.bold then parts[#parts + 1] = "font-weight:bold" end
  if h.italic then parts[#parts + 1] = "font-style:italic" end
  local deco = {}
  if h.underline or h.undercurl then deco[#deco + 1] = "underline" end
  if h.strikethrough then deco[#deco + 1] = "line-through" end
  if #deco > 0 then parts[#parts + 1] = "text-decoration:" .. table.concat(deco, " ") end
  return table.concat(parts, ";")
end

local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
local esc = { ["&"] = "&amp;", ["<"] = "&lt;", [">"] = "&gt;" }

local out = {}
out[#out + 1] = ('<!DOCTYPE html><html><head><meta charset="utf-8"><style>body{background:#%06x;color:#%06x;margin:0}pre{font-family:"JuliaMono","Menlo",monospace;font-size:14px;line-height:1.45;margin:0;padding:8px}</style></head><body><pre>'):format(
  normal.bg or 0x000000, normal.fg or 0xffffff)

for row = 1, #lines do
  local line = lines[row]
  local cells = cellhl[row]
  local pieces = {}
  local col = 0
  while col < #line do
    local cur = cells[col]
    local name = cur and cur.name or nil
    local stop = col + 1
    while stop < #line do
      local nxt = cells[stop]
      if (nxt and nxt.name or nil) ~= name then break end
      stop = stop + 1
    end
    local text = line:sub(col + 1, stop):gsub("[&<>]", esc)
    local h = name and resolve(name)
    if h then
      pieces[#pieces + 1] = ('<span style="%s">%s</span>'):format(css(h), text)
    else
      pieces[#pieces + 1] = text
    end
    col = stop
  end
  out[#out + 1] = table.concat(pieces)
end

out[#out + 1] = "</pre></body></html>"

local f = io.open(os.getenv("SNAP_OUT"), "w")
f:write(table.concat(out, "\n"))
f:close()
print(("wrote %s (%d lines, ft=%s)"):format(os.getenv("SNAP_OUT"), #lines, ft or "?"))
