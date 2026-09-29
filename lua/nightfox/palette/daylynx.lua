-- daylynx — the light lynx: dayfox anchors, kinship-tree syntax colors from
-- the lynx generator (autocolors P3; see PLAN.md), solved against dayfox's
-- light background. The math world's sibling is dawnfox (dawn to its day, as
-- nightlynx gives math to duskfox); every other embedded language hashes its
-- name into the full fox family, exactly as nightlynx's do.
local fox = require("nightfox.palette.dayfox")

return {
  meta = { name = "daylynx", light = true, lynx = { anchor = "dayfox", seed = "daylynx", pair = "nightlynx", siblings = { latex = "dawnfox" } } },
  palette = fox.palette,
  generate_spec = fox.generate_spec,
}
