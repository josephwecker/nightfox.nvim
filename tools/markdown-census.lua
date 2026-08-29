local files = {}
for line in io.lines(os.getenv("CORPUS")) do files[#files+1] = line end
arg = files
-- multi-file capture census; aggregate + per-file; markdown-format output
local agg = {}          -- key -> {n, bytes, files={}}
local perfile = {}      -- file -> {size, nlangs, ncaps, fence_langs={}, uninjected=n, mathblocks, per={key->{n,bytes}}}
local total_size = 0
for _, file in ipairs(files) do
  local bufnr = vim.fn.bufnr(file, true)
  local okload = pcall(vim.fn.bufload, bufnr)
  local fsize = vim.fn.getfsize(file)
  if okload and fsize > 0 then
    total_size = total_size + fsize
    local pf = { size = fsize, per = {}, langs = {}, fence_info = {}, mathblocks = 0 }
    perfile[file] = pf
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "markdown")
    if ok and parser then
      parser:parse(true)
      parser:for_each_tree(function(tstree, ltree)
        local lang = ltree:lang()
        pf.langs[lang] = true
        local q = vim.treesitter.query.get(lang, "highlights")
        if q then
          for id, node in q:iter_captures(tstree:root(), bufnr, 0, -1) do
            local name = q.captures[id]
            local _, _, sb, _, _, eb = node:range(true)
            local key = lang .. "\t@" .. name
            local a = agg[key] or { n = 0, bytes = 0, files = {} }
            a.n = a.n + 1; a.bytes = a.bytes + (eb - sb); a.files[file] = true
            agg[key] = a
            local p = pf.per[key] or { n = 0, bytes = 0 }
            p.n = p.n + 1; p.bytes = p.bytes + (eb - sb)
            pf.per[key] = p
          end
        end
        -- fence languages + uninjected fences + math (markdown tree only)
        if lang == "markdown" then
          local lq = vim.treesitter.query.parse("markdown", "(fenced_code_block (info_string (language) @l))")
          for _, n in lq:iter_captures(tstree:root(), bufnr, 0, -1) do
            local l = vim.treesitter.get_node_text(n, bufnr)
            pf.fence_info[l] = (pf.fence_info[l] or 0) + 1
          end
          local fq = vim.treesitter.query.parse("markdown", "(fenced_code_block) @f")
          local nf = 0
          for _ in fq:iter_captures(tstree:root(), bufnr, 0, -1) do nf = nf + 1 end
          pf.fences = nf
        elseif lang == "markdown_inline" then
          local mq = vim.treesitter.query.parse("markdown_inline", "(latex_block) @m")
          for _ in mq:iter_captures(tstree:root(), bufnr, 0, -1) do pf.mathblocks = pf.mathblocks + 1 end
        end
      end)
    end
  end
end
-- output
local keys = {}
for k in pairs(agg) do keys[#keys+1] = k end
table.sort(keys, function(a,b)
  local la, lb = a:match("^[^\t]+"), b:match("^[^\t]+")
  if la ~= lb then return la < lb end
  return agg[a].bytes > agg[b].bytes
end)
print(("TOTAL\t%d files\t%d bytes\t%d capture-pairs"):format(#files, total_size, #keys))
for _, k in ipairs(keys) do
  local a = agg[k]
  local nf = 0; for _ in pairs(a.files) do nf = nf + 1 end
  print(("AGG\t%s\t%d\t%d\t%d"):format(k, a.n, a.bytes, nf))
end
for _, file in ipairs(files) do
  local pf = perfile[file]
  if pf then
    local langs = {}
    for l in pairs(pf.langs) do langs[#langs+1] = l end
    table.sort(langs)
    local fl = {}
    for l, c in pairs(pf.fence_info) do fl[#fl+1] = l .. "×" .. c end
    table.sort(fl)
    local ncaps = 0; for _ in pairs(pf.per) do ncaps = ncaps + 1 end
    print(("FILE\t%s\t%d\t%d\t%s\t%d\t%s\t%d"):format(file, pf.size, ncaps,
      table.concat(langs, ","), pf.fences or 0, table.concat(fl, ","), pf.mathblocks))
  end
end
