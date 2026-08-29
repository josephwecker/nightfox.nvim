-- LSP semantic tokens — emitted from the kinship tree (autocolors P1).
-- https://neovim.io/doc/user/lsp.html#lsp-semantic-highlight
local M = {}

function M.get(spec, config, opts)
  return require("nightfox.kinship").emit("lsp", spec, config)
end

return M
