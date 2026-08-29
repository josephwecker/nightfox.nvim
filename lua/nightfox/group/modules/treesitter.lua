-- Treesitter captures — emitted from the kinship tree (autocolors P1).
-- The tree (parents, values, deltas) lives in lua/nightfox/kinship.lua.
local M = {}

function M.get(spec, config, opts)
  return require("nightfox.kinship").emit("ts", spec, config)
end

return M
