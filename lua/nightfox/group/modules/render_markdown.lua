-- render-markdown.nvim — the daily markdown surface (autocolors: full
-- coverage of its 46 highlight groups, replacing the plugin's carnival
-- defaults — H1Bg=DiffText etc. — with scheme-controlled values; for lynx
-- schemes the heading bands and code-block backgrounds derive from the
-- generator's identities. Block backgrounds here are the landing zone for
-- the sibling-scheme bg half of the P4 ruling.)
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
    -- Code blocks (bg0 = placeholder until the sibling-bg contract lands)
    RenderMarkdownCode = { bg = spec.bg0 },
    RenderMarkdownCodeInline = { bg = spec.bg0 },
    RenderMarkdownCodeBorder = { bg = spec.bg0 },
    RenderMarkdownCodeInfo = { link = "@label" },
    RenderMarkdownCodeFallback = { fg = spec.fg1 },
    -- General
    RenderMarkdownBullet = { link = "@markup.list" },
    RenderMarkdownDash = { fg = spec.bg4 },
    RenderMarkdownSign = { link = "SignColumn" },
    RenderMarkdownIndent = { link = "Whitespace" },
    RenderMarkdownMath = { link = "@markup.math" },
    RenderMarkdownHtmlComment = { link = "@comment" },
    -- ==inline highlight== : highlighter-pen band, readable fg
    RenderMarkdownInlineHighlight = { fg = spec.fg1, bg = band(P.yellow.base, 0.25) },
    -- Quotes (nesting ladder shares the quote identity for now)
    RenderMarkdownQuote = { link = "@markup.quote" },
    RenderMarkdownQuote1 = { link = "@markup.quote" },
    RenderMarkdownQuote2 = { link = "@markup.quote" },
    RenderMarkdownQuote3 = { link = "@markup.quote" },
    RenderMarkdownQuote4 = { link = "@markup.quote" },
    RenderMarkdownQuote5 = { link = "@markup.quote" },
    RenderMarkdownQuote6 = { link = "@markup.quote" },
    -- Links
    RenderMarkdownLink = { link = "@markup.link" },
    RenderMarkdownLinkTitle = { link = "@markup.link.label" },
    RenderMarkdownWikiLink = { link = "@markup.link" },
    -- Checkboxes
    RenderMarkdownUnchecked = { link = "@markup.list.unchecked" },
    RenderMarkdownChecked = { link = "@markup.list.checked" },
    RenderMarkdownTodo = { link = "@markup.raw" },
    -- Tables
    RenderMarkdownTableHead = { fg = spec.fg2 },
    RenderMarkdownTableRow = { fg = spec.fg3 },
    RenderMarkdownTableFill = { link = "Conceal" },
    -- Callouts ([!NOTE] etc.)
    RenderMarkdownSuccess = { link = "DiagnosticOk" },
    RenderMarkdownInfo = { link = "DiagnosticInfo" },
    RenderMarkdownHint = { link = "DiagnosticHint" },
    RenderMarkdownWarn = { link = "DiagnosticWarn" },
    RenderMarkdownError = { link = "DiagnosticError" },
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
