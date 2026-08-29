-- snapshot.lua — render FILE with a colorscheme to standalone HTML via the
-- built-in tohtml (real applied highlights: treesitter, injections, the lot).
-- Env: SNAP_FILE, SNAP_OUT (html path), SNAP_SCHEME (default nightfox),
--      SNAP_RTP (colorscheme repo rtp, default: this repo relative to script)
-- Used by tools/snapshot.sh; needs the treesitter parser/query dirs on rtp
-- (we add stdpath('data')/site and any pack/*/start/nvim-treesitter found).
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
if ft then
  vim.bo[buf].filetype = ft
  pcall(vim.treesitter.start, buf, vim.treesitter.language.get_lang(ft) or ft)
end
vim.cmd.redraw()
vim.cmd.packadd("nvim.tohtml")
local html = require("tohtml").tohtml(0, { number_lines = false })
local f = io.open(os.getenv("SNAP_OUT"), "w")
f:write(table.concat(html, "\n"))
f:close()
print(("wrote %s (%d lines, ft=%s)"):format(os.getenv("SNAP_OUT"), #html, ft or "?"))
