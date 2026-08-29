-- nightlynx — the first generated lynx: nightfox anchors, kinship-tree
-- syntax colors from the lynx generator (autocolors P3; see PLAN.md).
local fox = require("nightfox.palette.nightfox")

return {
  meta = { name = "nightlynx", light = false, lynx = { anchor = "nightfox", seed = "nightlynx" } },
  palette = fox.palette,
  generate_spec = fox.generate_spec,
}
