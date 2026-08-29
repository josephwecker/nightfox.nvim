-- dump all resolved highlight groups (post-colorscheme) as sorted stable text
vim.opt.rtp:prepend(os.getenv("FOX_RTP"))
vim.cmd.colorscheme(os.getenv("FOX_SCHEME") or "nightfox")
local out = {}
for name, attrs in pairs(vim.api.nvim_get_hl(0, {})) do
  local keys = {}
  for k in pairs(attrs) do keys[#keys+1] = k end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do parts[#parts+1] = k .. "=" .. tostring(attrs[k]) end
  out[#out+1] = name .. "\t" .. table.concat(parts, " ")
end
table.sort(out)
local f = io.open(os.getenv("FOX_OUT"), "w")
f:write(table.concat(out, "\n"))
f:close()
print("dumped " .. #out .. " groups to " .. os.getenv("FOX_OUT"))
