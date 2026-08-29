-- oklch.lua — perceptual color space for the lynx generator (autocolors P3).
-- Björn Ottosson's OKLab/OKLCH; sRGB in and out; WCAG contrast; gamut clamp.
-- Self-contained doubles-only math (no bitops), safe on any nvim Lua.

local M = {}

local pow, floor, sqrt, atan2, cos, sin, pi = math.pow or function(a, b)
  return a ^ b
end, math.floor, math.sqrt, math.atan2 or math.atan, math.cos, math.sin, math.pi

local function cbrt(x)
  if x < 0 then return -((-x) ^ (1 / 3)) end
  return x ^ (1 / 3)
end

-- hex "#rrggbb" -> r,g,b in [0,1]
function M.hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

function M.rgb_to_hex(r, g, b)
  local function ch(c)
    c = floor(c * 255 + 0.5)
    if c < 0 then c = 0 elseif c > 255 then c = 255 end
    return c
  end
  return string.format("#%02x%02x%02x", ch(r), ch(g), ch(b))
end

local function srgb_to_linear(c)
  if c <= 0.04045 then return c / 12.92 end
  return ((c + 0.055) / 1.055) ^ 2.4
end

local function linear_to_srgb(c)
  if c <= 0.0031308 then return 12.92 * c end
  return 1.055 * (c ^ (1 / 2.4)) - 0.055
end

-- linear rgb -> OKLab
local function linear_to_oklab(r, g, b)
  local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
  local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
  local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
  local l_, m_, s_ = cbrt(l), cbrt(m), cbrt(s)
  return 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_,
    1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_,
    0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
end

-- OKLab -> linear rgb (may be out of gamut)
local function oklab_to_linear(L, a, b)
  local l_ = L + 0.3963377774 * a + 0.2158037573 * b
  local m_ = L - 0.1055613458 * a - 0.0638541728 * b
  local s_ = L - 0.0894841775 * a - 1.2914855480 * b
  local l, m, s = l_ ^ 3, m_ ^ 3, s_ ^ 3
  return 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
    -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
    -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
end

--- hex -> { L, C, h } (h in degrees, [0,360))
function M.from_hex(hex)
  local r, g, b = M.hex_to_rgb(hex)
  local L, a, bb = linear_to_oklab(srgb_to_linear(r), srgb_to_linear(g), srgb_to_linear(b))
  local C = sqrt(a * a + bb * bb)
  local h = math.deg(atan2(bb, a)) % 360
  return { L = L, C = C, h = h }
end

local function in_gamut(r, g, b)
  return r >= -0.0001 and r <= 1.0001 and g >= -0.0001 and g <= 1.0001 and b >= -0.0001 and b <= 1.0001
end

--- { L, C, h } -> hex, reducing chroma until inside sRGB gamut.
function M.to_hex(c)
  local L, C, h = c.L, c.C, c.h
  if L <= 0 then return "#000000" end
  if L >= 1 then return "#ffffff" end
  local hr = math.rad(h)
  for _ = 1, 32 do
    local a, b = C * cos(hr), C * sin(hr)
    local r, g, bl = oklab_to_linear(L, a, b)
    if in_gamut(r, g, bl) then
      return M.rgb_to_hex(linear_to_srgb(math.max(r, 0)), linear_to_srgb(math.max(g, 0)), linear_to_srgb(math.max(bl, 0)))
    end
    C = C * 0.9
  end
  local r, g, bl = oklab_to_linear(L, 0, 0)
  return M.rgb_to_hex(linear_to_srgb(math.max(r, 0)), linear_to_srgb(math.max(g, 0)), linear_to_srgb(math.max(bl, 0)))
end

-- WCAG relative luminance of a hex color
function M.luminance(hex)
  local r, g, b = M.hex_to_rgb(hex)
  return 0.2126 * srgb_to_linear(r) + 0.7152 * srgb_to_linear(g) + 0.0722 * srgb_to_linear(b)
end

--- WCAG contrast ratio between two hex colors (>= 1)
function M.contrast(hex1, hex2)
  local l1, l2 = M.luminance(hex1), M.luminance(hex2)
  if l1 < l2 then l1, l2 = l2, l1 end
  return (l1 + 0.05) / (l2 + 0.05)
end

--- Solve OKLCH lightness so that {L,C,h} vs bg_hex hits target WCAG contrast.
--- Direction inferred from bg (dark bg -> lighter fg, and vice versa).
--- Returns a NEW {L,C,h} (chroma may be gamut-reduced by to_hex at render).
function M.solve_lightness(c, bg_hex, target)
  local dark_bg = M.luminance(bg_hex) < 0.5
  local lo, hi = 0.05, 0.99
  if not dark_bg then lo, hi = 0.01, 0.95 end
  local best = { L = c.L, C = c.C, h = c.h }
  for _ = 1, 24 do
    local mid = (lo + hi) / 2
    local probe = { L = mid, C = c.C, h = c.h }
    local ratio = M.contrast(M.to_hex(probe), bg_hex)
    best = probe
    if dark_bg then
      if ratio < target then lo = mid else hi = mid end
    else
      if ratio < target then hi = mid else lo = mid end
    end
  end
  return best
end

return M
