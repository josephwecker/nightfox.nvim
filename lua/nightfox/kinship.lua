-- kinship.lua — the role kinship tree (autocolors P1; see PLAN.md).
--
-- Every treesitter/LSP capture is a node that names its PARENT explicitly.
-- P1 carries today's colors (`value` below) so emission is ~equivalent to the
-- old group/modules/{treesitter,lsp_semantic_tokens} — deliberate deltas are
-- marked DELTA below. P3 replaces `value` with derivation (parent +
-- divergence marks in OKLCH); the tree structure is the part that survives.
--
-- Node forms:
--   n(name, parent, value [, opts])
--     value: string          -> emit as { link = value } (legacy anchor or group)
--            function(ctx)   -> emit explicit attrs (ctx = spec/config/etc.)
--            nil             -> inherit: emitted as a link to the PARENT, so
--                               every tree node is individually addressable
--                               (visually identical to nvim's runtime capture
--                               fallback, but explicit and overridable).
--     opts.ns: "ts" (default) | "lsp" — which module emits it.
--   alias(name, target) — legacy capture names emitted as copies of target's
--     resolved value (upstream behavior; aliases of value-less targets emit
--     nothing).
--
-- ctx fields: spec, config, syn (spec.syntax), stl (config.styles),
--             P (spec.palette).

local M = {}

local nodes = {} -- ordered
local by_name = {}

local function n(name, parent, value, opts)
  opts = opts or {}
  local node = { name = name, parent = parent, value = value, ns = opts.ns or "ts" }
  nodes[#nodes + 1] = node
  by_name[name] = node
end

local function alias(name, target, opts)
  opts = opts or {}
  nodes[#nodes + 1] = { name = name, alias_of = target, ns = opts.ns or "ts" }
end

-- =========================================================================
-- Identifiers
-- =========================================================================
n("@variable", nil, function(c) return { fg = c.syn.variable, style = c.stl.variables } end)
n("@variable.builtin", "@variable", function(c) return { fg = c.syn.builtin0, style = c.stl.variables } end)
-- DELTA: upstream had `{ fg = syn.builtin1, stl.variables }` — positional
-- value, a bug (the style was silently dropped). Fixed to style=:
n("@variable.parameter", "@variable", function(c) return { fg = c.syn.builtin1, style = c.stl.variables } end)
n("@variable.parameter.builtin", "@variable.parameter", nil)
n("@variable.member", "@variable", function(c) return { fg = c.syn.field } end)

n("@constant", nil, "Constant")
n("@constant.builtin", "@constant", function(c) return { fg = c.syn.builtin2, style = c.stl.keywords } end)
n("@constant.macro", "@constant", "Macro")

n("@module", nil, function(c) return { fg = c.syn.builtin1 } end)
n("@module.builtin", "@module", nil)
n("@label", nil, "Label")

-- =========================================================================
-- Literals
-- =========================================================================
n("@string", nil, "String")
n("@string.documentation", "@string", nil)
n("@string.regexp", "@string", function(c) return { fg = c.syn.regex, style = c.stl.strings } end)
n("@string.escape", "@string", function(c) return { fg = c.syn.regex, style = "bold" } end)
n("@string.special", "@string", "Special")
n("@string.special.symbol", "@string.special", nil)
n("@string.special.url", "@string.special", function(c) return { fg = c.syn.const, style = "italic,underline" } end)
n("@string.special.path", "@string.special", nil)

n("@character", nil, "Character")
n("@character.special", "@character", "SpecialChar")

n("@boolean", nil, "Boolean")
n("@number", nil, "Number")
n("@number.float", "@number", "Float")

-- =========================================================================
-- Types
-- =========================================================================
n("@type", nil, "Type")
n("@type.builtin", "@type", function(c) return { fg = c.syn.builtin1, style = c.stl.types } end)
n("@type.definition", "@type", nil)
n("@type.qualifier", "@type", nil)

n("@attribute", nil, "Constant")
n("@attribute.builtin", "@attribute", nil)
n("@property", nil, function(c) return { fg = c.syn.field } end)

-- =========================================================================
-- Functions
-- =========================================================================
n("@function", nil, "Function")
n("@function.builtin", "@function", function(c) return { fg = c.syn.builtin0, style = c.stl.functions } end)
n("@function.call", "@function", nil)
n("@function.macro", "@function", function(c) return { fg = c.syn.builtin0, style = c.stl.functions } end)
n("@function.method", "@function", nil)
n("@function.method.call", "@function.method", nil)

n("@constructor", nil, function(c) return { fg = c.syn.ident } end)
n("@operator", nil, "Operator")

-- =========================================================================
-- Keywords
-- =========================================================================
n("@keyword", nil, "Keyword")
n("@keyword.coroutine", "@keyword", nil)
n("@keyword.function", "@keyword", function(c) return { fg = c.syn.keyword, style = c.stl.functions } end)
n("@keyword.operator", "@keyword", function(c) return { fg = c.syn.operator, style = c.stl.operators } end)
n("@keyword.import", "@keyword", "Include")
n("@keyword.storage", "@keyword", "StorageClass")
n("@keyword.repeat", "@keyword", "Repeat")
n("@keyword.return", "@keyword", function(c) return { fg = c.syn.builtin0, style = c.stl.keywords } end)
n("@keyword.debug", "@keyword", nil)
n("@keyword.exception", "@keyword", "Exception")
n("@keyword.conditional", "@keyword", "Conditional")
n("@keyword.conditional.ternary", "@keyword.conditional", "Conditional")
n("@keyword.directive", "@keyword", nil)
n("@keyword.directive.define", "@keyword.directive", nil)

-- =========================================================================
-- Punctuation
-- =========================================================================
n("@punctuation.delimiter", nil, function(c) return { fg = c.syn.bracket } end)
n("@punctuation.bracket", nil, function(c) return { fg = c.syn.bracket } end)
n("@punctuation.special", nil, function(c) return { fg = c.syn.builtin1, style = c.stl.operators } end)

-- =========================================================================
-- Comments
-- =========================================================================
n("@comment", nil, "Comment")
n("@comment.documentation", "@comment", nil)
n("@comment.error", "@comment", function(c) return { fg = c.spec.bg1, bg = c.spec.diag.error } end)
n("@comment.warning", "@comment", function(c) return { fg = c.spec.bg1, bg = c.spec.diag.warn } end)
n("@comment.todo", "@comment", function(c) return { fg = c.spec.bg1, bg = c.spec.diag.hint } end)
n("@comment.note", "@comment", function(c) return { fg = c.spec.bg1, bg = c.spec.diag.info } end)

-- =========================================================================
-- Markup
-- =========================================================================
n("@markup", nil, function(c) return { fg = c.spec.fg1 } end)
n("@markup.strong", "@markup", function(c) return { fg = c.P.red:subtle(), style = "bold" } end)
n("@markup.italic", "@markup", "Italic")
n("@markup.strikethrough", "@markup", function(c) return { fg = c.spec.fg1, style = "strikethrough" } end)
n("@markup.underline", "@markup", "Underline")

n("@markup.heading", "@markup", "Title")
n("@markup.heading.1", "@markup.heading", nil)
n("@markup.heading.2", "@markup.heading", nil)
n("@markup.heading.3", "@markup.heading", nil)
n("@markup.heading.4", "@markup.heading", nil)
n("@markup.heading.5", "@markup.heading", nil)
n("@markup.heading.6", "@markup.heading", nil)

n("@markup.quote", "@markup", function(c) return { fg = c.spec.fg2 } end)
n("@markup.math", "@markup", function(c) return { fg = c.syn.func } end)
n("@markup.environment", "@markup", nil)

n("@markup.link", "@markup", function(c) return { fg = c.syn.keyword, style = "bold" } end)
n("@markup.link.label", "@markup.link", "Special")
n("@markup.link.url", "@markup.link", function(c) return { fg = c.syn.const, style = "italic,underline" } end)

n("@markup.raw", "@markup", function(c) return { fg = c.syn.ident, style = "italic" } end)
n("@markup.raw.block", "@markup.raw", function(c) return { fg = c.P.pink.base } end)

n("@markup.list", "@markup", function(c) return { fg = c.syn.builtin1, style = c.stl.operators } end)
n("@markup.list.checked", "@markup.list", function(c) return { fg = c.P.green.base } end)
n("@markup.list.unchecked", "@markup.list", function(c) return { fg = c.P.yellow.base } end)

n("@diff.plus", nil, "diffAdded")
n("@diff.minus", nil, "diffRemoved")
n("@diff.delta", nil, "diffChanged")

n("@tag", nil, function(c) return { fg = c.syn.keyword } end)
n("@tag.builtin", "@tag", nil)
n("@tag.attribute", "@tag", function(c) return { fg = c.syn.func, style = "italic" } end)
n("@tag.delimiter", "@tag", function(c) return { fg = c.syn.builtin1 } end)

-- =========================================================================
-- Language-specific overrides (kinship: children of the base capture)
-- =========================================================================
n("@label.json", "@label", function(c) return { fg = c.syn.func } end)
n("@constructor.lua", "@constructor", function(c) return { fg = c.spec.fg2 } end)
n("@field.rust", "@variable.member", function(c) return { fg = c.spec.fg2 } end)
-- DELTA: upstream defined this ({ fg = syn.func }) then accidentally wiped it
-- via `hl["@variable.member.yaml"] = hl["@field.yaml"]` (undefined). The
-- definition is restored — frontmatter keys in 213 of 260 censused files:
n("@variable.member.yaml", "@variable.member", function(c) return { fg = c.syn.func } end)

-- =========================================================================
-- Legacy capture aliases (upstream emitted as value copies, not links)
-- =========================================================================
alias("@parameter", "@variable.parameter")
alias("@field", "@variable.member")
alias("@namespace", "@module")
alias("@float", "@number.float")
alias("@symbol", "@string.special.symbol")           -- latent target: no emission
alias("@string.regex", "@string.regexp")

alias("@text", "@markup")
alias("@text.strong", "@markup.strong")
alias("@text.emphasis", "@markup.italic")
alias("@text.underline", "@markup.underline")
alias("@text.strike", "@markup.strikethrough")
alias("@text.math", "@markup.math")
alias("@text.environment", "@markup.environment")    -- latent target
alias("@text.environment.name", "@markup.environment.name") -- undefined target
alias("@text.title", "@markup.heading")
alias("@text.literal", "@markup.raw")
alias("@text.reference", "@markup.link")
alias("@text.todo.checked", "@markup.list.checked")
alias("@text.todo.unchecked", "@markup.list.unchecked")
alias("@text.todo", "@comment.todo")
alias("@text.warning", "@comment.warning")
alias("@text.note", "@comment.note")
alias("@text.danger", "@comment.error")
alias("@text.uri", "@markup.link.uri")               -- upstream's final (typo'd) assignment; undefined target
alias("@method", "@function.method")                 -- latent target
alias("@method.call", "@function.method.call")       -- latent target
alias("@text.diff.add", "@diff.plus")
alias("@text.diff.delete", "@diff.minus")
alias("@define", "@keyword.directive.define")        -- latent target
alias("@preproc", "@keyword.directive")              -- latent target
alias("@storageclass", "@keyword.storage")
alias("@conditional", "@keyword.conditional")
alias("@exception", "@keyword.exception")
alias("@include", "@keyword.import")
alias("@repeat", "@keyword.repeat")
alias("@text.title.1.markdown", "@markup.heading.1.markdown") -- undefined targets, all six
alias("@text.title.2.markdown", "@markup.heading.2.markdown")
alias("@text.title.3.markdown", "@markup.heading.3.markdown")
alias("@text.title.4.markdown", "@markup.heading.4.markdown")
alias("@text.title.5.markdown", "@markup.heading.5.markdown")
alias("@text.title.6.markdown", "@markup.heading.6.markdown")

-- =========================================================================
-- LSP semantic tokens (ns = "lsp"): parents are the treesitter captures
-- they linked to — the kinship edge was always there; now it's explicit.
-- =========================================================================
local function lsp(name, parent, value)
  n(name, parent, value, { ns = "lsp" })
end

lsp("@lsp.type.boolean", "@boolean", "@boolean")
lsp("@lsp.type.builtinType", "@type.builtin", "@type.builtin")
lsp("@lsp.type.comment", "@comment", "@comment")
lsp("@lsp.type.enum", "@type", "@type")
lsp("@lsp.type.enumMember", "@constant", "@constant")
lsp("@lsp.type.escapeSequence", "@string.escape", "@string.escape")
lsp("@lsp.type.formatSpecifier", "@punctuation.special", "@punctuation.special")
lsp("@lsp.type.interface", "@type", function(c) return { fg = c.spec.syntax.builtin3 } end)
lsp("@lsp.type.keyword", "@keyword", "@keyword")
lsp("@lsp.type.namespace", "@module", "@module")
lsp("@lsp.type.number", "@number", "@number")
lsp("@lsp.type.operator", "@operator", "@operator")
lsp("@lsp.type.parameter", "@variable.parameter", "@parameter")
lsp("@lsp.type.property", "@property", "@property")
lsp("@lsp.type.selfKeyword", "@variable.builtin", "@variable.builtin")
lsp("@lsp.type.typeAlias", "@type.definition", "@type.definition")
lsp("@lsp.type.unresolvedReference", nil, "@error")
lsp("@lsp.type.variable", "@variable", function() return {} end) -- deliberate: defer to treesitter
lsp("@lsp.typemod.class.defaultLibrary", "@type.builtin", "@type.builtin")
lsp("@lsp.typemod.enum.defaultLibrary", "@type.builtin", "@type.builtin")
lsp("@lsp.typemod.enumMember.defaultLibrary", "@constant.builtin", "@constant.builtin")
lsp("@lsp.typemod.function.defaultLibrary", "@function.builtin", "@function.builtin")
lsp("@lsp.typemod.keyword.async", "@keyword.coroutine", "@keyword.coroutine")
lsp("@lsp.typemod.macro.defaultLibrary", "@function.builtin", "@function.builtin")
lsp("@lsp.typemod.method.defaultLibrary", "@function.builtin", "@function.builtin")
lsp("@lsp.typemod.operator.injected", "@operator", "@operator")
lsp("@lsp.typemod.string.injected", "@string", "@string")
lsp("@lsp.typemod.type.defaultLibrary", "@type.builtin", "@type.builtin")
lsp("@lsp.typemod.variable.defaultLibrary", "@variable.builtin", "@variable.builtin")
lsp("@lsp.typemod.variable.injected", "@variable", "@variable")

-- =========================================================================
-- Emission
-- =========================================================================

--- Emit the highlight table for one namespace ("ts" | "lsp"), P1-faithful.
---@param ns string
---@param spec table
---@param config table
---@return table
function M.emit(ns, spec, config)
  local ctx = {
    spec = spec,
    config = config,
    syn = spec.syntax,
    stl = config.styles,
    P = spec.palette,
  }
  local hl = {}
  for _, node in ipairs(nodes) do
    if node.ns == ns then
      if node.alias_of then
        -- value-copy of the target's emitted entry (nil target => no entry),
        -- matching upstream's `hl[legacy] = hl[modern]` behavior.
        hl[node.name] = hl[node.alias_of]
      elseif type(node.value) == "string" then
        hl[node.name] = { link = node.value }
      elseif type(node.value) == "function" then
        hl[node.name] = node.value(ctx)
      elseif node.parent then
        -- inherit: explicit link to parent — the tree, materialized.
        hl[node.name] = { link = node.parent }
      end
    end
  end
  return hl
end

--- The tree itself, for tooling (census cross-refs, P3 generator).
function M.tree()
  return nodes
end

return M
