lua << EOF
-- Useful when debugging
if vim.g.nightfox_debug then
  require("nightfox.util.reload")()
end

require("nightfox.config").set_fox("daylynx")
require("nightfox").load()
EOF
