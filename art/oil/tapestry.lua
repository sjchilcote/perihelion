-- easel session "tapestry": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=3, linen={14,15}, seed=1818, ground={{pile={{"lead white",2},{"yellow ochre",0.35},{"raw sienna",0.12}}, um=150, apply="brush", texture=0.4}}}
-- wool colours
TERRA = pile{{"red earth",1},{"burnt sienna",0.5},{"lead white",0.6}}
OCHRE = pile{{"yellow ochre",1.5},{"lead white",0.5},{"raw sienna",0.2}}
GREENW = pile{{"viridian",0.8},{"yellow ochre",1},{"lead white",0.6},{"bone black",0.1}}
BLUEB = pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.3}}
BLUEL = pile{{"ultramarine blue",1},{"lead white",1},{"bone black",0.15}}
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.2}}
GREYW = pile{{"lead white",1.2},{"bone black",0.35},{"yellow ochre",0.2}}
SH = {}       -- every filled shape: {pts, pile, angle}
function E(cx, cy, rx, ry, n) local t = {} n = n or 14; for i = 0, n - 1 do local a = 2 * math.pi * i / n; t[#t + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end; return t end
function R(x, y, w, h) return {{x, y}, {x + w, y}, {x + w, y + h}, {x, y + h}} end
function add(pts, p, a) SH[#SH + 1] = {pts = pts, p = p, a = a or 1.57} end
function band(a, b, w) -- a straight limb as a quad
  local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / l * w / 2, dx / l * w / 2
  return {{a[1] + nx, a[2] + ny}, {b[1] + nx, b[2] + ny}, {b[1] - nx, b[2] - ny}, {a[1] - nx, a[2] - ny}}
end
-- a frame-figure standing at foot (x,y), height h, facing dir; body colour, tabard colour
function figure(x, y, h, body, tab, dir, pose)
  local s = h / 60
  dir = dir or 1
  local function P(u, v) return {x + dir * u * s, y + v * s} end
  add(E(x, y - 54 * s, 5 * s, 6 * s, 10), body, 0)                                      -- helm
  add({P(-7, -47), P(7, -47), P(8, -24), P(-8, -24)}, tab or body, 1.57)                 -- torso / tabard
  add(band(P(-3, -24), P(-6 - (pose == "walk" and 5 or 0), 0), 5 * s), body, 1.57)       -- legs
  add(band(P(3, -24), P(6 + (pose == "walk" and 6 or 0), 0), 5 * s), body, 1.57)
  add(band(P(-7, -45), P(-11, -28), 4 * s), body, 1.57)                                    -- back arm
  add(band(P(7, -45), P(16, -34), 4 * s), body, 0.6)                                      -- front arm out
end
print(W, H)

--@ chunk 2
-- the scenes as flat shapes, left to right (ground line y=262)
local G = 262
-- 1. the CUCULUS crosses: a dark ship-like lander with a crimson keel over waves of space; the Sun behind
add(E(45, 105, 16, 16, 16), OCHRE, 0)
add({{38,170},{100,152},{116,160},{104,180},{50,186}}, BLUEB, 0.2)
add({{50,186},{104,180},{100,190},{56,194}}, TERRA, 0.2)
-- 2. the seed burrows: hull scales, the lander nose-down in them
for i = 0, 5 do for j = 0, 1 do add(E(122 + i * 15 + j * 7, 236 + j * 12, 8, 6, 10), OCHRE, 0) end end
add({{150,150},{176,140},{196,222},{180,232}}, BLUEB, 1.2)
add({{170,228},{190,226},{184,248}}, TERRA, 0)
-- 3. the first frame lies dead; the second stands and takes up the tabard
add({{212,252},{262,250},{262,260},{212,262}}, BLUEB, 0)
add(E(208, 254, 6, 5, 10), BLUEB, 0)
figure(280, G, 66, BLUEB, TERRA, -1)
-- 4. the dead outpost: a grey prefab box, dark doorways, amber stripes, a broken mast
add(R(312, 168, 66, 94), GREYW, 0)
add(R(326, 210, 14, 52), BLUEB, 1.57)
add(R(352, 190, 14, 18), BLUEB, 0)
add(R(312, 160, 66, 8), OCHRE, 0)
-- 5. Ratio on a screen; the Commando kneels before it
add(R(410, 150, 44, 36), CREAM, 0)
add(R(414, 154, 36, 28), BLUEL, 0)
add(R(428, 186, 8, 76), GREYW, 1.57)
add(E(432, 167, 8, 9, 12), CREAM, 0)
add({{422,160},{442,160},{446,182},{418,182}}, BLUEB, 1.57)
figure(478, G, 50, BLUEB, TERRA, -1)
-- 6. the docents in their museum: an arcade, three white figures, a relic on a plinth
for i = 0, 2 do add(R(500 + i * 26, 140, 6, 122), OCHRE, 1.57) end
add(R(496, 132, 64, 10), OCHRE, 0)
for i = 0, 1 do add({{508 + i * 26, 204}, {520 + i * 26, 204}, {524 + i * 26, 262}, {504 + i * 26, 262}}, CREAM, 1.57); add(E(514 + i * 26, 198, 5, 5, 10), CREAM, 0) end
add(R(566, 232, 14, 30), GREENW, 1.57)
add(E(573, 224, 7, 7, 10), TERRA, 0)
-- 7. the Wardens: angular green things; the Commando with his cannon
figure(608, G, 64, BLUEB, TERRA, 1)
add(band({620, 220}, {650, 210}, 5), BLUEB, 0.3)
add({{660,262},{672,180},{690,200},{700,262}}, GREENW, 1.57)
add({{672,180},{682,150},{698,170},{690,200}}, GREENW, 0.5)
add({{700,262},{712,196},{726,212},{724,262}}, GREENW, 1.57)
-- 8. the sail spreads: a great fan of ochre film from a mast
add({{752,250},{730,110},{770,96}}, OCHRE, 1.0)
add({{752,250},{770,96},{808,112}}, TERRA, 1.3)
add({{752,250},{808,112},{820,170}}, OCHRE, 1.7)
add(R(749, 150, 6, 112), BLUEB, 1.57)
-- 9. perihelion: the Sun huge, the station small before it
add(E(858, 150, 44, 44, 20), TERRA, 0)
add(E(858, 150, 30, 30, 18), OCHRE, 0)
add(E(858, 222, 14, 8, 12), BLUEB, 0)
-- 10. the station sails on: ring and sail over waves, heading out right
add(E(935, 190, 26, 26, 18), BLUEB, 0)
add(E(935, 190, 16, 16, 16), CREAM, 0)
add({{935,164},{976,120},{986,170}}, OCHRE, 1.0)
-- dividers: stylised trees with interlaced crowns
for _, x in ipairs({112, 200, 302, 396, 490, 588, 740, 812}) do
  add(R(x - 2, 200, 4, 62), TERRA, 1.57)
  add(E(x, 192, 9, 14, 12), GREENW, 0)
end
-- fill every shape: embroidered laid work, short parallel stitches
for i, s in ipairs(SH) do
  local m = poly(s.pts)
  work(m, {hand="hatch", pile=s.p, coverage=3, fill=true, angle=s.a, clip=m, seed=2000 + i})
end
print(#SH, wait(4 * 24 * 60))

--@ chunk 3
-- all the stitching, on dry wool: stem-stitch contours, the borders with beasts and fold-glyphs, the lettering, details
local st = brush{kind="rigger", width=1.5, point=0.8}
local function stitch(p, a, b, len)
  len = len or 3.6
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local n = math.max(1, math.floor(l / (len + 1.1)))
  for i = 0, n - 1 do
    local t0, t1 = i / n, (i + len / (len + 1.1)) / n
    st:reload(p, 0.7)
    st:stroke({{a[1] + dx * t0, a[2] + dy * t0}, {a[1] + dx * t1, a[2] + dy * t1}}, {pressure={0.55, 0.55}, ramps={0.1, 0.1}})
  end
end
local function ring(p, pts) for i = 1, #pts do stitch(p, pts[i], pts[i % #pts + 1]) end end
local function line(p, pts, len) for i = 1, #pts - 1 do stitch(p, pts[i], pts[i + 1], len) end end
local DARK = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.15}}
-- contours of every shape
for _, s in ipairs(SH) do ring(DARK, s.pts) end
-- the ground line, with small hillocks
line(GREENW, {{18, 263}, {982, 263}}, 4)
for x = 30, 970, 46 do line(GREENW, {{x, 263}, {x + 10, 256}, {x + 20, 263}}, 3) end
-- borders: rules, slanted compartments, beasts and fold-glyphs in alternate ones
for _, y in ipairs({8, 48, 288, 326}) do line(TERRA, {{14, y}, {986, y}}, 4) end
local function beast(x, y, dir, p)
  local body = poly(E(x, y, 9, 4.5, 12))
  work(body, {hand="detail", pile=p, coverage=4, fill=true, angle=0, clip=body, seed=math.floor(x + y)})
  ring(DARK, E(x, y, 9, 4.5, 12))
  line(DARK, {{x - 6, y + 3}, {x - 7, y + 11}}, 2); line(DARK, {{x + 5, y + 3}, {x + 6, y + 11}}, 2)
  line(DARK, {{x + dir * 8, y - 2}, {x + dir * 13, y - 8}}, 2); ring(DARK, E(x + dir * 14, y - 9, 2.6, 2.6, 8))
  line(DARK, {{x - dir * 9, y - 1}, {x - dir * 14, y - 7}, {x - dir * 12, y - 11}}, 2)
end
local function glyph(cx, cy, n, r, rot)
  local p, q = {}, {}
  for i = 0, n - 1 do local a = rot + 2 * math.pi * i / n; p[#p + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}; local b = a + 0.5; q[#q + 1] = {cx + 0.618 * r * math.cos(b), cy + 0.618 * r * math.sin(b)} end
  ring(OCHRE, p); ring(TERRA, q)
end
local k = 0
for x = 14, 960, 40 do
  for _, b in ipairs({{8, 48}, {288, 326}}) do
    line(TERRA, {{x, b[2]}, {x + 14, b[1]}}, 3)
    local cx, cy = x + 27, (b[1] + b[2]) / 2 + 3
    if k % 2 == 0 then beast(cx, cy, (k % 4 == 0) and 1 or -1, ({OCHRE, GREENW, TERRA, BLUEL})[(k % 4) + 1])
    else glyph(cx, cy - 3, 3 + (k % 4), 10, k * 0.4) end
    k = k + 1
  end
end
-- lettering band: abstract stitched capitals, crosses between words
local x = 24
local i = 0
while x < 970 do
  if i % 6 == 5 then line(TERRA, {{x + 4, 55}, {x + 4, 71}}, 2); line(TERRA, {{x - 2, 61}, {x + 10, 61}}, 2); x = x + 16
  else
    local kd = (i * 7) % 4
    line(DARK, {{x, 55}, {x, 71}}, 2.5)
    if kd == 0 then line(DARK, {{x, 55}, {x + 9, 63}, {x, 71}}, 2.5)
    elseif kd == 1 then line(DARK, {{x + 9, 55}, {x + 9, 71}}, 2.5); line(DARK, {{x, 63}, {x + 9, 63}}, 2.5)
    elseif kd == 2 then line(DARK, {{x, 55}, {x + 9, 71}}, 2.5); line(DARK, {{x + 9, 55}, {x + 9, 71}}, 2.5)
    else line(DARK, {{x, 55}, {x + 9, 55}}, 2.5); line(DARK, {{x, 63}, {x + 7, 63}}, 2.5) end
    x = x + 15
  end
  i = i + 1
end
-- details
local function wave(x0, x1, y) local pts = {} for xx = x0, x1, 6 do pts[#pts + 1] = {xx, y + 3 * math.sin(xx / 4)} end; line(BLUEL, pts, 3) end
for _, y in ipairs({205, 215, 225}) do wave(22, 104, y) end
for _, y in ipairs({228, 238, 248}) do wave(900, 984, y) end
for kk = 0, 11 do local a = 2 * math.pi * kk / 12; line(OCHRE, {{45 + 19 * math.cos(a), 105 + 19 * math.sin(a)}, {45 + 27 * math.cos(a), 105 + 27 * math.sin(a)}}, 3) end
for kk = 0, 15 do local a = 2 * math.pi * kk / 16; line(TERRA, {{858 + 48 * math.cos(a), 150 + 48 * math.sin(a)}, {858 + 60 * math.cos(a), 150 + 60 * math.sin(a)}}, 3) end
line(DARK, {{116, 170}, {140, 168}}, 3); line(DARK, {{116, 176}, {136, 178}}, 3)                     -- the lander's wake
for kk = 0, 7 do local a = -math.pi * kk / 7; line(OCHRE, {{184, 238}, {184 + 18 * math.cos(a), 238 + 18 * math.sin(a)}}, 2.5) end   -- sparks
line(BLUEB, {{426, 162}, {427, 162}}, 1); line(BLUEB, {{437, 162}, {438, 162}}, 1)                   -- Ratio's eyes
line(CREAM, {{416, 186}, {448, 186}}, 3)
line(BLUEL, {{650, 210}, {660, 200}, {656, 196}, {672, 186}}, 3)                                     -- lightning
line(CREAM, {{652, 208}, {662, 199}, {658, 195}, {674, 184}}, 2.5)
line(DARK, {{752, 250}, {770, 96}}, 3); line(DARK, {{752, 250}, {808, 112}}, 3)                    -- sail seams
for kk = 0, 11 do local a = 2 * math.pi * kk / 12; local t = brush{kind="round", width=2.2, point=0.5}; t:reload(OCHRE, 0.8); t:touch(935 + 21 * math.cos(a), 190 + 21 * math.sin(a), {pressure=0.6}) end
line(DARK, {{560, 140}, {560, 262}}, 3)
