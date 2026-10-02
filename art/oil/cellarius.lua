-- easel session "cellarius": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.4, linen={18,20}, seed=2525, ground={{pile={{"lead white",2.5},{"yellow ochre",0.35},{"raw sienna",0.06}}, um=160, apply="knife", texture=0.15}}}
PAPER = pile{{"lead white",2.5},{"yellow ochre",0.35}}
SKY = pile{{"cerulean blue",0.8},{"cobalt blue",0.4},{"lead white",1.4}}
SKYD = pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.5}}
RED = pile{{"vermilion",1},{"red earth",0.6},{"Mars red",0.2}}
GOLD = pile{{"cadmium yellow",1},{"Mars yellow",0.6},{"lead white",0.4}}
BLK = pile{{"bone brown",1},{"bone black",0.8}}
WHITE = pile{{"lead white",3},{"yellow ochre",0.08}}
SUN = {300, 357}
EC = {580, 357}; EA, EB = 330, 172
PLATE = rect(66, 66, 868, 582)
FRAME = rect(36, 36, 928, 642) - PLATE
local function F(m, p, s) work(m, {hand="body", tool="filbert 8", pile=p, coverage=3.8, fill=true, angle=0.05, clip=m, seed=s}) end
F(FRAME, RED, 101)
F(PLATE, SKY, 102)
print(wait(3 * 24 * 60))
-- a deeper sky toward the plate's edges, flat bands like hand colouring
local edge = PLATE - ellipse(EC[1], EC[2] - 4, 470, 300)
F(edge, SKYD, 103)
print(wait(3 * 24 * 60))

--@ chunk 2
-- flat hand colour: the planets' rings, the Sun, clouds in the corners with docent-cherubs and their scrolls, the title banner
local function F(m, p, s, tool) work(m, {hand="detail", tool={kind="filbert", width=tool or 4}, pile=p, coverage=4.5, fill=true, angle=0.05, clip=m, seed=s}) end
local RINGP = {pile{{"yellow ochre",1},{"lead white",1.6}}, pile{{"rose madder",0.6},{"lead white",2},{"vermilion",0.2}}, pile{{"viridian",0.5},{"lead white",2},{"yellow ochre",0.3}}, pile{{"cobalt violet",0.8},{"lead white",1.8}}}
RINGS = {58, 92, 128, 168}
for i, r in ipairs(RINGS) do F(ellipse(SUN[1], SUN[2], r + 7, r + 7) - ellipse(SUN[1], SUN[2], r - 7, r - 7), RINGP[i], 200 + i) end
F(ellipse(SUN[1], SUN[2], 30, 30), GOLD, 210)
-- clouds: clusters of lobes in the four corners, with a grey-blue underside
local CW = pile{{"lead white",3},{"cerulean blue",0.08}}
local CG = pile{{"lead white",1.6},{"ultramarine blue",0.25},{"bone black",0.08},{"yellow ochre",0.1}}
CLOUDS = {}
local corners = {{66, 66, 1, 1}, {934, 66, -1, 1}, {66, 648, 1, -1}, {934, 648, -1, -1}}
for i, c in ipairs(corners) do
  local m = nil
  local lobes = {{30, 30, 46}, {90, 22, 34}, {28, 92, 34}, {130, 16, 24}, {18, 140, 22}, {72, 66, 30}}
  for _, l in ipairs(lobes) do
    local e = ellipse(c[1] + c[3] * l[1], c[2] + c[4] * l[2], l[3], l[3] * 0.85)
    m = m and (m + e) or e
    CLOUDS[#CLOUDS + 1] = {c[1] + c[3] * l[1], c[2] + c[4] * l[2], l[3]}
  end
  m = m * PLATE
  F(m, CG, 220 + i, 6)
  local top = nil
  for _, l in ipairs(lobes) do local e = ellipse(c[1] + c[3] * l[1], c[2] + c[4] * l[2] - c[4] * 5, l[3] * 0.82, l[3] * 0.7); top = top and (top + e) or e end
  F(top * PLATE, CW, 230 + i, 6)
end
-- cherubs (docents) on the clouds, each holding a scroll
CHERUB = {{150, 150, 1}, {850, 150, -1}, {150, 566, 1}, {850, 566, -1}}
local ROBE = pile{{"lead white",3},{"yellow ochre",0.15}}
local WING = pile{{"lead white",2},{"cerulean blue",0.4}}
local SCR = pile{{"lead white",2.2},{"yellow ochre",0.7},{"raw sienna",0.1}}
for i, ch in ipairs(CHERUB) do
  local x, y, d = ch[1], ch[2], ch[3]
  F(poly({{x - 16 * d, y - 22}, {x - 40 * d, y - 34}, {x - 32 * d, y - 6}}), WING, 240 + i, 3)
  F(poly({{x + 10 * d, y - 22}, {x + 30 * d, y - 40}, {x + 28 * d, y - 12}}), WING, 250 + i, 3)
  F(poly({{x - 10, y - 24}, {x + 10, y - 24}, {x + 14, y + 10}, {x - 14, y + 10}}), ROBE, 260 + i, 3)
  F(ellipse(x, y - 32, 8, 8), pile{{"lead white",2.5},{"vermilion",0.08},{"yellow ochre",0.15}}, 270 + i, 3)
  local sx = x + 24 * d
  F(poly({{sx - 6 * d, y - 6}, {sx + 100 * d, y - 6}, {sx + 100 * d, y + 16}, {sx - 6 * d, y + 16}}), SCR, 280 + i, 3)
  F(ellipse(sx + 100 * d, y + 5, 5, 12), SCR, 290 + i, 3)
end
-- the title banner
TB = {360, 78, 640, 112}
F(poly({{TB[1], TB[2]}, {TB[3], TB[2]}, {TB[3], TB[4]}, {TB[1], TB[4]}}), SCR, 300, 4)
F(poly({{TB[1] - 30, TB[2] + 10}, {TB[1], TB[2] + 4}, {TB[1], TB[4] + 4}, {TB[1] - 30, TB[4] + 12}, {TB[1] - 18, TB[2] + 26}}), SCR, 301, 3)
F(poly({{TB[3] + 30, TB[2] + 10}, {TB[3], TB[2] + 4}, {TB[3], TB[4] + 4}, {TB[3] + 30, TB[4] + 12}, {TB[3] + 18, TB[2] + 26}}), SCR, 302, 3)
print(wait(4 * 24 * 60))

--@ chunk 3
-- ink and gold, on dry colour: every line a short segment
local ink = brush{kind="rigger", width=1.7, point=0.85}
local gb = brush{kind="round", width=4.5, point=0.3}
local tip = brush{kind="round", width=3, point=0.5}
local INK = pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.2}}
local GL = pile{{"Mars yellow",1},{"cadmium yellow",0.7},{"lead white",0.3}}
local function seg(b, p, a, c, pr) b:reload(p, 0.85); b:stroke({a, c}, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.03}}) end
local function ell(b, p, cx, cy, rx, ry, a0, a1, pr, step) local n = math.max(3, math.floor(math.abs(a1 - a0) * math.max(rx, ry) / (step or 9))); for k = 0, n - 1 do local t0, t1 = lerp(a0, a1, k / n), lerp(a0, a1, (k + 1) / n); seg(b, p, {cx + rx * math.cos(t0), cy + ry * math.sin(t0)}, {cx + rx * math.cos(t1), cy + ry * math.sin(t1)}, pr) end end
local TAU = 2 * math.pi
-- the planets' rings, inked both edges, each with its planet
local PL = {pile{{"Mars orange",1},{"lead white",0.3}}, pile{{"lead white",2},{"lemon chrome",0.3}}, pile{{"cobalt blue",1},{"lead white",0.6}}, pile{{"vermilion",1},{"Mars red",0.4}}}
for i, r in ipairs(RINGS) do
  ell(ink, INK, SUN[1], SUN[2], r + 7, r + 7, 0, TAU, {0.45, 0.45}); ell(ink, INK, SUN[1], SUN[2], r - 7, r - 7, 0, TAU, {0.45, 0.45})
  local a = ({-0.8, 2.2, 0.9, -2.3})[i]
  local pl = brush{kind="round", width=11, point=0.3}; pl:reload(PL[i], 1); pl:touch(SUN[1] + r * math.cos(a), SUN[2] + r * math.sin(a), {pressure=0.85})
  ell(ink, INK, SUN[1] + r * math.cos(a), SUN[2] + r * math.sin(a), 6, 6, 0, TAU, {0.4, 0.4}, 3)
end
-- the Sun: face, wavy rays, ink rim
local sx, sy = SUN[1], SUN[2]
ell(ink, INK, sx, sy, 30, 30, 0, TAU, {0.5, 0.5})
ell(ink, INK, sx - 10, sy - 5, 6, 3, 0.1 * math.pi, 0.9 * math.pi, {0.5, 0.5}, 2); ell(ink, INK, sx + 10, sy - 5, 6, 3, 0.1 * math.pi, 0.9 * math.pi, {0.5, 0.5}, 2)
seg(ink, INK, {sx, sy - 3}, {sx - 2, sy + 7}); ell(ink, INK, sx, sy + 9, 8, 4, 0.2 * math.pi, 0.8 * math.pi, {0.5, 0.5}, 2)
for k = 0, 15 do
  local a = TAU * k / 16; local r1 = (k % 2 == 0) and 50 or 42
  local m = {sx + 40 * math.cos(a + 0.07), sy + 40 * math.sin(a + 0.07)}
  seg(gb, GL, {sx + 32 * math.cos(a), sy + 32 * math.sin(a)}, m, {0.5, 0.4}); seg(gb, GL, m, {sx + r1 * math.cos(a - 0.04), sy + r1 * math.sin(a - 0.04)}, {0.4, 0.05})
end
-- the TESTAMENT's long orbit: a gold band inked both sides, ticked by the day
ell(gb, GL, EC[1], EC[2], EA, EB, 0, TAU, {0.75, 0.75}, 7)
ell(ink, INK, EC[1], EC[2], EA + 4, EB + 4, 0, TAU, {0.45, 0.45}); ell(ink, INK, EC[1], EC[2], EA - 4, EB - 4, 0, TAU, {0.45, 0.45})
for k = 0, 71 do
  local a = TAU * k / 72
  local c, s = math.cos(a), math.sin(a)
  local p = {EC[1] + EA * c, EC[2] + EB * s}
  local nx, ny = EB * c, EA * s; local l = math.sqrt(nx * nx + ny * ny); nx, ny = nx / l, ny / l
  seg(ink, INK, {p[1] + nx * 4, p[2] + ny * 4}, {p[1] + nx * ((k % 6 == 0) and 13 or 8), p[2] + ny * ((k % 6 == 0) and 13 or 8)}, {0.4, 0.4})
end
-- the station at perihelion (and its ghost at aphelion): ring and spine
local function station(x, y, s, p)
  ell(gb, p, x, y, 11 * s, 11 * s, 0, TAU, {0.6, 0.6}, 3)
  seg(gb, p, {x, y - 20 * s}, {x, y + 20 * s}, {0.6, 0.6})
  ell(ink, INK, x, y, 14 * s, 14 * s, 0, TAU, {0.4, 0.4}, 3)
  seg(ink, INK, {x - 3 * s, y - 21 * s}, {x - 3 * s, y + 21 * s}, {0.35, 0.35}); seg(ink, INK, {x + 3 * s, y - 21 * s}, {x + 3 * s, y + 21 * s}, {0.35, 0.35})
end
local BRZ = pile{{"raw sienna",1.2},{"burnt sienna",0.7},{"yellow ochre",0.4}}
station(EC[1] - EA, EC[2], 1.0, BRZ)
station(EC[1] + EA - 6, EC[2], 0.6, BRZ)
-- the line of apsides, dotted, with a small fold-glyph at each end
for x = EC[1] - EA + 22, EC[1] + EA - 18, 14 do seg(ink, INK, {x, EC[2]}, {x + 6, EC[2]}, {0.35, 0.35}) end
-- clouds: inked upper edges of the lobes
for _, c in ipairs(CLOUDS) do ell(ink, INK, c[1], c[2], c[3], c[3] * 0.85, math.pi * 1.05, math.pi * 1.95, {0.4, 0.4}) end
-- cherubs: faces, curls, wing feathers, the scrolls' lettering
for i, ch in ipairs(CHERUB) do
  local x, y, d = ch[1], ch[2], ch[3]
  ell(ink, INK, x, y - 32, 8, 8, 0, TAU, {0.4, 0.4}, 3)
  tip:reload(INK, 0.8); tip:touch(x - 3, y - 33, {pressure=0.35}); tip:reload(INK, 0.8); tip:touch(x + 3, y - 33, {pressure=0.35})
  for k = 0, 4 do local a = math.pi * (1.1 + 0.2 * k); ell(ink, pile{{"Mars yellow",1},{"raw sienna",0.5}}, x + 8 * math.cos(a), y - 32 + 8 * math.sin(a), 3, 3, 0, TAU, {0.4, 0.4}, 2) end
  seg(ink, INK, {x - 10, y - 24}, {x - 14, y + 10}); seg(ink, INK, {x + 10, y - 24}, {x + 14, y + 10}); seg(ink, INK, {x - 14, y + 10}, {x + 14, y + 10})
  for k = 0, 2 do seg(ink, INK, {x - (16 + k * 6) * d, y - 22 - k * 3}, {x - (30 + k * 2) * d, y - 10 - k * 4}, {0.35, 0.35}) end
  local sx2 = x + 24 * d
  local x0 = math.min(sx2 - 6 * d, sx2 + 100 * d) + 8
  seg(ink, INK, {sx2 - 6 * d, y - 6}, {sx2 + 100 * d, y - 6}); seg(ink, INK, {sx2 - 6 * d, y + 16}, {sx2 + 100 * d, y + 16})
  for k = 0, 6 do
    local lx = x0 + k * 12
    seg(ink, INK, {lx, y}, {lx, y + 10}, {0.45, 0.45})
    if k % 2 == 0 then seg(ink, INK, {lx, y}, {lx + 6, y + 5}, {0.45, 0.45}) else seg(ink, INK, {lx, y + 5}, {lx + 7, y + 5}, {0.45, 0.45}) end
  end
end
-- the title: abstract capitals on the banner
for k = 0, 14 do
  local lx = TB[1] + 22 + k * 17
  seg(ink, INK, {lx, TB[2] + 9}, {lx, TB[4] - 9}, {0.6, 0.6})
  local kd = k % 4
  if kd == 0 then seg(ink, INK, {lx, TB[2] + 9}, {lx + 9, TB[2] + 17}); seg(ink, INK, {lx + 9, TB[2] + 17}, {lx, TB[4] - 9})
  elseif kd == 1 then seg(ink, INK, {lx + 9, TB[2] + 9}, {lx + 9, TB[4] - 9}); seg(ink, INK, {lx, TB[2] + 17}, {lx + 9, TB[2] + 17})
  elseif kd == 2 then seg(ink, INK, {lx, TB[2] + 9}, {lx + 9, TB[4] - 9})
  else seg(ink, INK, {lx, TB[2] + 9}, {lx + 9, TB[2] + 9}); seg(ink, INK, {lx, TB[4] - 9}, {lx + 9, TB[4] - 9}) end
end
for _, s in ipairs({{{TB[1], TB[2]}, {TB[3], TB[2]}}, {{TB[1], TB[4]}, {TB[3], TB[4]}}}) do seg(ink, INK, s[1], s[2]) end
-- the frame: gold rules and a row of fold-glyphs, a polygon round a smaller turned copy of itself
for _, r in ipairs({{40, 40, 960, 674}, {62, 62, 938, 652}}) do
  seg(gb, GL, {r[1], r[2]}, {r[3], r[2]}, {0.55, 0.55}); seg(gb, GL, {r[3], r[2]}, {r[3], r[4]}, {0.55, 0.55})
  seg(gb, GL, {r[3], r[4]}, {r[1], r[4]}, {0.55, 0.55}); seg(gb, GL, {r[1], r[4]}, {r[1], r[2]}, {0.55, 0.55})
end
local function glyph(cx, cy, n, r, rot)
  local p, q = {}, {}
  for i = 0, n do local a = rot + TAU * i / n; p[#p + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}; local b = a + 0.45; q[#q + 1] = {cx + 0.618 * r * math.cos(b), cy + 0.618 * r * math.sin(b)} end
  for i = 1, n do seg(ink, GL, p[i], p[i + 1], {0.6, 0.6}); seg(ink, pile{{"lead white",2},{"yellow ochre",0.4}}, q[i], q[i + 1], {0.5, 0.5}) end
end
local k = 0
for x = 90, 920, 64 do glyph(x, 51, 3 + k % 4, 8, k * 0.6); glyph(x, 663, 3 + (k + 2) % 4, 8, k * 0.5); k = k + 1 end
for y = 110, 610, 64 do glyph(51, y, 3 + k % 4, 8, k * 0.6); glyph(949, y, 3 + (k + 1) % 4, 8, k * 0.4); k = k + 1 end
