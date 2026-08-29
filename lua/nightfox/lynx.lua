-- lynx.lua — the autocolors generator, v2 (P3; see PLAN.md).
--
-- v2 is an ALLOCATOR, not an assignment table (v1's hand-mapping was caught
-- by Joseph within the hour — "manually creating the variations instead of
-- based on an adjacency graph"). The model, per the 2011 NOTES:
--
--   * code base-families keep the anchor fox's hue identities (ratified:
--     lynxes are "nuanced extensions … generated from those actual
--     colorschemes as the basis") — strings green, keywords magenta, etc.;
--   * heading levels are SIX distinct allocation slots — an ordered hue arc
--     walking away from the anchor heading hue, so document depth reads as
--     hue, not as a brightness knob;
--   * remaining markdown identities (math, italic, list, quote, …) are
--     allocated GREEDILY INTO THE WHEEL'S GAPS, importance-ordered by
--     measured census share, scored by distance-to-taken-hues plus
--     adjacency-weighted separation from their measured neighbors;
--   * per-class contrast is DERIVED from the census (information vs clutter
--     vs readability floor), not from a tier table — the tier table remains
--     only as fallback for classes the markdown census can't see (code
--     captures await a code census);
--   * kinship divergence (seeded; name IS the seed) shades children within
--     a family; an adjacency post-pass pushes apart frequent cross-family
--     neighbors that landed too close in hue.
--
-- census substrate: lua/nightfox/census/markdown.lua (GENERATED — see
-- tools/census-derive.lua for corpus + regeneration).

local oklch = require("nightfox.lib.oklch")

local M = {}

-- ---------------------------------------------------------------------------
-- Seeded RNG — Park–Miller MINSTD (doubles-safe). Same name, same scheme.
-- ---------------------------------------------------------------------------
local function seed_from(str)
  local s = 0
  for i = 1, #str do
    s = (s * 33 + str:byte(i)) % 2147483647
  end
  return (s == 0) and 42 or s
end

local function rng(seed)
  local s = seed
  return function()
    s = (s * 16807) % 2147483647
    return s / 2147483647
  end
end

local function jit(r)
  return r() * 2 - 1
end

local function hue_dist(a, b)
  local d = math.abs(a - b) % 360
  return d > 180 and 360 - d or d
end

-- ---------------------------------------------------------------------------
-- Anchored code families (ratified base: the fox's own identities).
-- tier: fallback contrast class when the census can't see the capture.
-- ---------------------------------------------------------------------------
local TIER_CONTRAST = { [0] = 2.6, [1] = 3.6, [2] = 6.2, [3] = 7.0, [4] = 8.6 }

local FAMILIES = {
  ["@variable"] = { hue = "white", tier = 2, cscale = 0.5 },
  ["@constant"] = { hue = "orange", tier = 3 },
  ["@module"] = { hue = "cyan", tier = 3 },
  ["@label"] = { hue = "green", tier = 3 },
  ["@string"] = { hue = "green", tier = 3 },
  ["@character"] = { hue = "green", tier = 3 },
  ["@boolean"] = { hue = "orange", tier = 3 },
  ["@number"] = { hue = "orange", tier = 3 },
  ["@type"] = { hue = "yellow", tier = 4 },
  ["@attribute"] = { hue = "orange", tier = 3 },
  ["@property"] = { hue = "blue", tier = 2, cscale = 0.8 },
  ["@function"] = { hue = "blue", tier = 4 },
  ["@constructor"] = { hue = "cyan", tier = 3 },
  ["@operator"] = { hue = "fg", tier = 1 },
  ["@keyword"] = { hue = "magenta", tier = 4 },
  ["@punctuation.delimiter"] = { hue = "fg", tier = 0 },
  ["@punctuation.bracket"] = { hue = "fg", tier = 0 },
  ["@punctuation.special"] = { hue = "cyan", tier = 1, cscale = 0.6 },
  ["@comment"] = { hue = "comment", tier = 1, style = "italic" },
  ["@markup"] = { hue = "fg", tier = 2, cscale = 0.3 },
  ["@diff.plus"] = { hue = "green", tier = 3 },
  ["@diff.minus"] = { hue = "red", tier = 3 },
  ["@diff.delta"] = { hue = "blue", tier = 3 },
  ["@tag"] = { hue = "magenta", tier = 4 },
}

-- Markdown identities that keep an anchor kinship (ratified nightfox feel),
-- diverged from their code cousins by the kinship jitter:
local MD_ANCHORED = {
  ["@markup.strong"] = { hue = "red", style = "bold" },
  ["@markup.link"] = { hue = "magenta" },
  ["@markup.raw"] = { hue = "cyan" },
}

-- Markdown identities ALLOCATED into wheel gaps (importance = census share):
local MD_ALLOCATED = { "@markup.math", "@markup.italic", "@markup.list", "@markup.quote" }

-- Style conventions (typography, not color — carried, not derived):
local STYLES = {
  ["@markup.italic"] = "italic",
  ["@markup.strikethrough"] = "strikethrough",
  ["@markup.underline"] = "underline",
  ["@markup.heading"] = "bold",
  ["@markup.heading.1"] = "bold",
  ["@markup.heading.2"] = "bold",
  ["@markup.quote"] = "italic",
  ["@markup.link.url"] = "italic,underline",
  ["@string.escape"] = "bold",
  ["@constant.builtin"] = "bold",
}

-- Nodes whose P1 values carry backgrounds — untouched in v2:
local KEEP_P1 = {
  ["@comment.error"] = true,
  ["@comment.warning"] = true,
  ["@comment.todo"] = true,
  ["@comment.note"] = true,
}

-- ---------------------------------------------------------------------------
-- Census-derived contrast target.
--   information: rarer classes may spend more contrast (-log10 share);
--   clutter: high span-count classes are everywhere and must recede
--     (the 2011 balance rule: high contrast only against large low-contrast
--     fields — frequency damps emphasis);
--   readability floor: classes whose spans are *read* (avg span >= 4 bytes)
--     floor at body contrast; sub-glyph classes may recede much further.
-- ---------------------------------------------------------------------------
-- Derivation coefficients — honestly: first-guess constants, never fit.
-- They are the generator's personality parameters (the 2011 trio lives in
-- meta.lynx.personality = { contrast, chroma }); P5's fitness pass is where
-- these get fit against the exemplar corpus instead of guessed.
local PARAMS = {
  base = 3.0, -- contrast baseline
  info_gain = 1.6, -- how much rarity may spend
  clutter_cost = 2.0, -- how hard frequency damps (the balance rule)
  read_floor = 5.2, -- classes whose spans are read (avg >= 4 bytes)
  glyph_floor = 2.3, -- sub-glyph scaffold may recede this far
  cap = 9.2,
  colorfulness = 0.125, -- baseline chroma for allocated identities
}

local ok_census, CENSUS = pcall(require, "nightfox.census.markdown")
if not ok_census then CENSUS = { classes = {}, adjacency = {} } end

local function contrast_from_stats(c)
  local info = -math.log10(math.max(c.share, 1e-5))
  local clutter = math.log10(1 + c.density10k)
  local floor = (c.avg_len >= 4) and PARAMS.read_floor or PARAMS.glyph_floor
  local t = PARAMS.base + PARAMS.info_gain * info - PARAMS.clutter_cost * clutter
  if t < floor then t = floor end
  if t > PARAMS.cap then t = PARAMS.cap end
  return t
end

local function derived_contrast(name)
  local c = CENSUS.classes[name] or (CENSUS.lang_classes or {})[name]
  if not c then return nil end
  return contrast_from_stats(c)
end

local function share_of(name)
  local c = CENSUS.classes[name]
  return c and c.share or 0
end

-- ---------------------------------------------------------------------------

local function anchor_hue(palette, key, fg)
  if key == "fg" then return oklch.from_hex(fg) end
  if key == "comment" then return oklch.from_hex(palette.comment) end
  local shade = palette[key]
  local hex = type(shade) == "table" and shade.base or shade
  return oklch.from_hex(hex)
end

local function find_family(name, tree_index)
  local cur = name
  while cur do
    if FAMILIES[cur] then return FAMILIES[cur], cur end
    local node = tree_index[cur]
    cur = node and node.parent or nil
  end
  return { hue = "fg", tier = 2 }, name
end

--- Generate {capture -> attrs} for every ts node in the kinship tree.
function M.generate(spec)
  local kinship = require("nightfox.kinship")
  local meta = spec.palette.meta
  local scheme_seed = (meta.lynx and meta.lynx.seed) or meta.name
  local palette = spec.palette
  local bg, fg = spec.bg1, spec.fg1

  local tree = kinship.tree()
  local index = {}
  for _, node in ipairs(tree) do
    if node.name and not node.alias_of then index[node.name] = node end
  end
  local function depth_of(name)
    local d, cur = 0, index[name]
    while cur and cur.parent do
      d = d + 1
      cur = index[cur.parent]
    end
    return d
  end

  local R = rng(seed_from(scheme_seed))
  local pers = (meta.lynx and meta.lynx.personality) or {}
  local p_contrast = pers.contrast or 1.0
  local p_chroma = pers.chroma or 1.0
  local median_C = PARAMS.colorfulness * p_chroma

  -- 1) taken hues: the anchored code families
  local taken = {}
  local function take(h)
    taken[#taken + 1] = h
  end
  for _, fam in pairs(FAMILIES) do
    if fam.hue ~= "fg" and fam.hue ~= "comment" and fam.hue ~= "white" then
      take(anchor_hue(palette, fam.hue, fg).h)
    end
  end

  -- identity slots: name -> { h, C } (chromatic identities placed on wheel)
  local slot = {}

  -- 2) heading arc: six distinct slots walking away from the anchor heading
  -- hue (nightfox: Title blue), step ~26 deg + jitter, descending chroma a little
  local hb = anchor_hue(palette, "blue", fg)
  local arc_dir = -1 -- toward cyan/green
  for lvl = 1, 6 do
    local step = 26 + jit(R) * 5
    local h = (hb.h + arc_dir * step * (lvl - 1)) % 360
    slot["@markup.heading." .. lvl] = { h = h, C = math.max(hb.C, median_C) * (1.0 - 0.06 * (lvl - 1)) }
  end
  slot["@markup.heading"] = { h = hb.h, C = math.max(hb.C, median_C) }

  -- 3) markdown anchored identities (kin to code cousins, diverged later by
  -- the kinship jitter like any child)
  for name, a in pairs(MD_ANCHORED) do
    local base = anchor_hue(palette, a.hue, fg)
    slot[name] = { h = base.h, C = math.max(base.C * 0.9, median_C * 0.9) }
  end

  -- 4) greedy gap allocation for the remaining identities, importance-ordered
  -- by census share; score = min distance to taken hues + adjacency-weighted
  -- distance to measured neighbors already placed.
  local alloc = vim.deepcopy(MD_ALLOCATED)
  table.sort(alloc, function(a, b)
    return share_of(a) > share_of(b)
  end)
  -- adjacency weights involving an identity
  local function adj_neighbors(name)
    local out = {}
    for _, row in ipairs(CENSUS.adjacency or {}) do
      local a, b, w = row[1], row[2], row[3]
      if a == name and slot[b] then out[#out + 1] = { slot[b].h, w } end
      if b == name and slot[a] then out[#out + 1] = { slot[a].h, w } end
    end
    return out
  end
  for _, name in ipairs(alloc) do
    local neighbors = adj_neighbors(name)
    local best, best_score = nil, -1
    for probe = 0, 355, 5 do
      local h = (probe + jit(R) * 2) % 360
      local dmin = 360
      for _, t in ipairs(taken) do
        dmin = math.min(dmin, hue_dist(h, t))
      end
      for _, s in pairs(slot) do
        dmin = math.min(dmin, hue_dist(h, s.h))
      end
      local adjscore = 0
      for _, nb in ipairs(neighbors) do
        adjscore = adjscore + math.min(hue_dist(h, nb[1]), 60) * math.log10(1 + nb[2])
      end
      local score = dmin * 2 + adjscore * 0.15
      if score > best_score then
        best, best_score = h, score
      end
    end
    slot[name] = { h = best, C = median_C }
  end

  -- 5) walk the tree: identities take their slots; everything else derives
  -- from its family anchor with seeded kinship divergence.
  local out = {}
  local placed = {} -- name -> {c=oklch, fam_root=..., target=...}
  for _, node in ipairs(tree) do
    if node.ns == "ts" and node.name and not node.alias_of and not KEEP_P1[node.name] then
      local name = node.name
      local fam, fam_root = find_family(name, index)
      local r = rng(seed_from(scheme_seed .. "\0" .. name))
      local c
      -- nearest slotted ancestor (identity kinship beats family anchor)
      local slot_anc, cur = nil, name
      while cur do
        if slot[cur] then
          slot_anc = cur
          break
        end
        local nd = index[cur]
        cur = nd and nd.parent or nil
      end
      if slot_anc then
        local s = slot[slot_anc]
        local d = depth_of(name) - depth_of(slot_anc)
        local span = (d == 0) and 3 or (10 / math.max(d, 1))
        c = { h = (s.h + jit(r) * span) % 360, C = s.C * (0.92 + 0.16 * r()), L = 0.7 }
      else
        local base = anchor_hue(palette, fam.hue, fg)
        local d = depth_of(name)
        local span = (d == 0) and 4 or (14 / d)
        local cscale = fam.cscale or 1.0
        c = { h = (base.h + jit(r) * span) % 360, C = math.max(base.C * cscale, 0) * (0.9 + 0.2 * r()), L = base.L }
      end
      local target = derived_contrast(name) or TIER_CONTRAST[fam.tier] or 6.0
      placed[name] = { c = c, fam_root = slot_anc or fam_root, target = target }
    end
  end

  -- 6) adjacency separation: frequent cross-identity neighbors too close in
  -- hue get pushed apart (lesser share moves; achromatic classes exempt).
  for _, row in ipairs(CENSUS.adjacency or {}) do
    local a, b = placed[row[1]], placed[row[2]]
    if a and b and a.fam_root ~= b.fam_root and a.c.C > 0.045 and b.c.C > 0.045 then
      local d = hue_dist(a.c.h, b.c.h)
      if d < 28 then
        local mover = (share_of(row[1]) <= share_of(row[2])) and a or b
        local anchor = (mover == a) and b or a
        local dirn = ((mover.c.h - anchor.c.h) % 360 < 180) and 1 or -1
        mover.c.h = (mover.c.h + dirn * (28 - d)) % 360
      end
    end
  end

  -- 6.5) the math world — DERIVED, not hand-mapped: every measured latex
  -- capture (census lang_classes) plus the fork-added $/$$ capture becomes
  -- kin of the math identity: hue = math slot + seeded kinship jitter,
  -- contrast from its own measured stats, chroma FOLLOWING contrast (one
  -- emphasis budget expressed in both channels — dull scaffold falls out of
  -- its measured frequency, not a dulling table). P4 replaces this with a
  -- full sibling scheme; this is the kinship layer.
  local math_slot = slot["@markup.math"]
  do
    local kin_names = { ["@punctuation.delimiter.math"] = CENSUS.classes["@punctuation.delimiter.math"] }
    for lname, stats in pairs(CENSUS.lang_classes or {}) do
      if lname:match("%.latex$") then kin_names[lname] = stats end
    end
    for lname, stats in pairs(kin_names) do
      if stats then
        local r = rng(seed_from(scheme_seed .. "\0" .. lname))
        local target = contrast_from_stats(stats)
        local cscale = math.min(math.max(target / 6.5, 0.45), 1.1)
        placed[lname] = {
          c = { h = (math_slot.h + jit(r) * 9) % 360, C = math_slot.C * cscale, L = 0.7 },
          fam_root = "@markup.math",
          target = target,
        }
      end
    end
  end

  -- 6.6) gates, generally: fork-added delimiter captures render as the
  -- DULLED KIN of the family they open (math $, strong **, italic *,
  -- strikethrough ~~, code-span `). Contrast from their measured census
  -- stats where present (glyph-floor recede falls out of frequency);
  -- hue/chroma follow the host identity.
  local GATE_HOSTS = {
    ["@punctuation.delimiter.math"] = "@markup.math",
    ["@punctuation.delimiter.strong"] = "@markup.strong",
    ["@punctuation.delimiter.italic"] = "@markup.italic",
    ["@punctuation.delimiter.strikethrough"] = "@markup.strikethrough",
    ["@punctuation.delimiter.raw"] = "@markup.raw",
  }
  for gate, host in pairs(GATE_HOSTS) do
    local hostp = placed[host]
    if hostp then
      local r = rng(seed_from(scheme_seed .. "\0" .. gate))
      local stats = CENSUS.classes[gate]
      local target = stats and contrast_from_stats(stats) or 2.6
      local cscale = math.min(math.max(target / 6.5, 0.45), 1.1)
      placed[gate] = {
        c = { h = (hostp.c.h + jit(r) * 5) % 360, C = hostp.c.C * cscale, L = 0.7 },
        fam_root = host,
        target = target,
      }
    end
  end

  -- 7) solve lightness per node against the actual bg; emit
  for name, p in pairs(placed) do
    local target = 1 + (p.target - 1) * p_contrast
    local solved = oklch.solve_lightness(p.c, bg, target)
    local attrs = { fg = oklch.to_hex(solved) }
    local style = STYLES[name] or (FAMILIES[name] and FAMILIES[name].style)
    if name == "@markup.strong" then style = "bold" end
    if name == "@comment" or name:match("^@comment%.") then style = STYLES[name] or "italic" end
    if style then attrs.style = style end
    out[name] = attrs
  end
  return out
end

return M
