-- census-graph.lua — the corpus's class structure as graphs (autocolors #2).
-- Measures CONTAINMENT (which classes nest inside which — the DAG) from span
-- ranges, joins it with the census adjacency graph, and emits Graphviz DOT
-- with nodes colored by the CURRENT generated scheme — the graph doubles as
-- the scheme's legend.
--   CORPUS=<filelist> SNAP_SCHEME=nightlynx nvim --headless -l tools/census-graph.lua
-- writes /tmp path given in GRAPH_OUT (default exemplars/graph.dot)

local here = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(here)
vim.opt.rtp:append(here .. "/after")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/site")
for _, pk in ipairs(vim.fn.glob(vim.fn.stdpath("config") .. "/pack/*/start/nvim-treesitter", true, true)) do
  vim.opt.rtp:append(pk)
end
vim.cmd.colorscheme(os.getenv("SNAP_SCHEME") or "nightlynx")

local files = {}
for line in io.lines(os.getenv("CORPUS")) do
  files[#files + 1] = line
end

local META = { ["@spell"] = true, ["@nospell"] = true, ["@conceal"] = true, ["@none"] = true }
local function is_meta(name)
  return META[name] or name:match("^@_")
end

local contain = {} -- "parent\tchild" -> count (innermost enclosing class)
local classes = {} -- name -> bytes
local total = 0

for _, file in ipairs(files) do
  local bufnr = vim.fn.bufnr(file, true)
  if pcall(vim.fn.bufload, bufnr) and vim.fn.getfsize(file) > 0 then
    total = total + vim.fn.getfsize(file)
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
    if ok and parser then
      parser:parse(true)
      local spans = {}
      parser:for_each_tree(function(tstree, ltree)
        local q = vim.treesitter.query.get(ltree:lang(), "highlights")
        if q then
          for id, node in q:iter_captures(tstree:root(), bufnr, 0, -1) do
            local name = "@" .. q.captures[id]
            if not is_meta(name) then
              local _, _, sb, _, _, eb = node:range(true)
              classes[name] = (classes[name] or 0) + (eb - sb)
              spans[#spans + 1] = { sb, eb, name }
            end
          end
        end
      end)
      table.sort(spans, function(a, b)
        if a[1] ~= b[1] then return a[1] < b[1] end
        return a[2] > b[2]
      end)
      local stack = {}
      for _, sp in ipairs(spans) do
        while #stack > 0 and stack[#stack][2] <= sp[1] do
          stack[#stack] = nil
        end
        local top = stack[#stack]
        if top and top[2] >= sp[2] and top[3] ~= sp[3] then
          local key = top[3] .. "\t" .. sp[3]
          contain[key] = (contain[key] or 0) + 1
        end
        stack[#stack + 1] = sp
      end
    end
  end
end

-- node colors from the live scheme (capture fallback like the editor)
local function color_of(name)
  local probe = name
  while probe do
    local h = vim.api.nvim_get_hl(0, { name = probe, link = false })
    if h.fg then return ("#%06x"):format(h.fg) end
    probe = probe:match("^(.*)%.[^.]+$")
  end
  return "#888888"
end

local out = {}
local function w(s)
  out[#out + 1] = s
end
w("digraph markdown {")
w('  rankdir=TB; bgcolor="#192330"; ')
w('  node [style=filled fontname="Menlo" fontsize=11 shape=box fontcolor="#0d1017"];')
w('  edge [color="#4a5878" fontcolor="#8a94ac" fontname="Menlo" fontsize=9];')
local names = {}
for k in pairs(classes) do
  names[#names + 1] = k
end
table.sort(names)
for _, name in ipairs(names) do
  local share = classes[name] / total
  local size = 0.35 + math.min(math.sqrt(share) * 4, 2.2)
  w(('  "%s" [fillcolor="%s" width=%.2f height=%.2f label="%s\\n%.2f%%"];'):format(
    name, color_of(name), size, size * 0.45, name:gsub("@", ""), share * 100))
end
local edges = {}
for k, v in pairs(contain) do
  edges[#edges + 1] = { k, v }
end
table.sort(edges, function(a, b)
  return a[2] > b[2]
end)
for i = 1, math.min(#edges, 90) do
  local parent, child = edges[i][1]:match("^(.-)\t(.+)$")
  local wt = edges[i][2]
  w(('  "%s" -> "%s" [penwidth=%.1f label="%d"];'):format(parent, child, 0.4 + math.log10(wt) * 1.1, wt))
end
w("}")
local outfile = os.getenv("GRAPH_OUT") or (here .. "/exemplars/containment.dot")
local f = io.open(outfile, "w")
f:write(table.concat(out, "\n"))
f:close()
print(("wrote %s: %d classes, %d containment edges (top 90 kept)"):format(outfile, #names, #edges))
