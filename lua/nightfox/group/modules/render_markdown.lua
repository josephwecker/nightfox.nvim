-- render-markdown.nvim — the daily markdown surface (autocolors: this module
-- takes its groups away from the plugin's carnival defaults — H1Bg=DiffText
-- etc. — and puts them under scheme control; for lynx schemes the heading
-- bands and code-block background derive from the generator's identities).
local C = require("nightfox.lib.color")

local M = {}

function M.get(spec, config, opts)
  local P = spec.palette
  local is_lynx = P.meta and P.meta.lynx
  local gen = is_lynx and require("nightfox.lynx").generate(spec) or nil

  local function band(hex, strength)
    return C(spec.bg1):blend(C(hex), strength or 0.14):to_css()
  end

  local hl = {
    RenderMarkdownCode = { bg = spec.bg0 }, -- block bg: the sibling-scheme landing zone (P4)
    RenderMarkdownCodeInline = { bg = spec.bg0 },
    RenderMarkdownCodeInfo = { link = "@label" },
    RenderMarkdownCodeBorder = { bg = spec.bg0 },
    RenderMarkdownBullet = { link = "@markup.list" },
    RenderMarkdownDash = { fg = spec.bg4 },
    RenderMarkdownMath = { link = "@markup.math" },
    RenderMarkdownQuote = { link = "@markup.quote" },
    RenderMarkdownLink = { link = "@markup.link" },
    RenderMarkdownWikiLink = { link = "@markup.link" },
    RenderMarkdownTableHead = { fg = spec.fg2 },
    RenderMarkdownTableRow = { fg = spec.fg3 },
    RenderMarkdownUnchecked = { link = "@markup.list.unchecked" },
    RenderMarkdownChecked = { link = "@markup.list.checked" },
    RenderMarkdownHtmlComment = { link = "@comment" },
  }
  for i = 1, 6 do
    local hg = "@markup.heading." .. i
    hl["RenderMarkdownH" .. i] = { link = hg }
    local src = gen and gen[hg] and gen[hg].fg or spec.syntax.func
    hl["RenderMarkdownH" .. i .. "Bg"] = { bg = band(src, 0.12) }
  end
  return hl
end

return M
