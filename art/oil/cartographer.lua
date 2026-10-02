-- easel session "cartographer": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=4/3, linen={18,16}, seed=7373,
  ground={{pile={{"bone black",1},{"burnt sienna",0.9},{"raw sienna",0.3},{"lead white",0.45}}, um=110, apply="knife", texture=0.4}}}
-- a round room seen from a little above: the table a wide ellipse, the lamp hanging over its centre; walls curving round behind
TX, TY, TRX, TRY = 500, 500, 330, 118
TABLE = ellipse(TX, TY, TRX, TRY)
TEDGE = (ellipse(TX, TY + 18, TRX, TRY) - TABLE) * below(function(x) return TY end)
LAMPX, LAMPY = 500, 150
-- the floor ring and the curved wall behind: a band whose base follows the far edge of a big ellipse
function WALLBASE(x) local u = (x - 500) / 700; return 380 - 120 * math.sqrt(math.max(0, 1 - u * u)) + 0 end
WALLM = above(function(x) return 390 end)
FLOORM = below(function(x) return 390 end)
local dk = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
local fl = pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}
work(WALLM, {hand="body", tool="filbert 12", pile=dk, coverage=4, fill=true, clip=WALLM, angle=math.pi/2, load=1})
work(FLOORM - TABLE - TEDGE, {hand="body", tool="filbert 12", pile=fl, coverage=4, fill=true, clip=FLOORM - TABLE - TEDGE, angle=0, load=1})
-- the light falls in a soft ring on the floor round the table and a faint cone in the air: three opaque steps on the wall behind
local glow = ellipse(TX, 400, 380, 200) * WALLM
work(glow, {hand="body", tool="filbert 8", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.35}, medium=0.06}, coverage=4, fill=true, clip=glow, angle=math.pi/2, load=1})
blend((ellipse(TX, 400, 395, 212) - ellipse(TX, 400, 360, 185)) * WALLM)
-- the table: bone, brightest at its centre under the lamp, two rings of falling light
local t1 = pile{{"lead white",1},{"yellow ochre",0.5},{"burnt sienna",0.3},{"bone black",0.45}, medium=0.06}
local t2 = pile{{"lead white",1.6},{"yellow ochre",0.55},{"raw sienna",0.15},{"bone black",0.15}, medium=0.06}
local t3 = pile{{"lead white",2.2},{"yellow ochre",0.45},{"cadmium yellow",0.08}, medium=0.05}
local r2 = ellipse(TX, TY, TRX * 0.75, TRY * 0.75)
local r3 = ellipse(TX, TY, TRX * 0.42, TRY * 0.42)
work(TABLE - r2, {hand="body", tool="filbert 8", pile=t1, coverage=5, fill=true, clip=TABLE - r2, angle=0, load=1})
work(r2 - r3, {hand="body", tool="filbert 7", pile=t2, coverage=5, fill=true, clip=r2 - r3, angle=0, load=1})
work(r3, {hand="body", tool="filbert 6", pile=t3, coverage=5, fill=true, clip=r3, angle=0, load=1})
blend(ellipse(TX, TY, TRX * 0.8, TRY * 0.8) - ellipse(TX, TY, TRX * 0.7, TRY * 0.7), {angle=0})
blend(ellipse(TX, TY, TRX * 0.47, TRY * 0.47) - ellipse(TX, TY, TRX * 0.37, TRY * 0.37), {angle=0})
work(TEDGE, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.4},{"burnt sienna",0.9},{"raw sienna",0.4}, medium=0.06}, coverage=5, fill=true, clip=TEDGE, angle=0, load=1})
print(W, H)

--@ chunk 2
-- the round wall: its base a curve rising toward the middle, shelves curving the other way (above the eye), each packed with
-- rolled plans seen end-on; dim, a little warmth where the lamp reaches. The table's thick bronze rim and its shadow.
print(wait(2*24*60))
local function base(x) local u = (x - 500) / 620; return 405 - 55 * (1 - u * u) end
local function shelf(y0) return function(x) local u = (x - 500) / 620; return y0 + 70 * (1 - u * u) * (y0 < 300 and 1 or -1) * (300 - y0) / 300 end end
local wall = above(base) - TABLE - TEDGE
local floorC = below(base) * above(function(x) return 395 end) - TABLE - TEDGE
work(wall, {hand="body", tool="filbert 12", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}, coverage=5, fill=true, clip=wall, angle=math.pi/2, load=1})
work(floorC, {hand="body", tool="filbert 8", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}, coverage=5, fill=true, clip=floorC, angle=0, load=1})
local board = pile{{"bone black",1.5},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}
local endD = pile{{"bone black",1},{"burnt sienna",0.7},{"lead white",0.45},{"yellow ochre",0.2}, medium=0.06}
local endL = pile{{"lead white",1.1},{"yellow ochre",0.55},{"bone black",0.35},{"burnt sienna",0.2}, medium=0.06}
SHELVES = {}
for si, y0 in ipairs{70, 150, 230, 310} do
  local f = shelf(y0)
  local pts = {}
  for x = -20, 1020, 40 do pts[#pts+1] = {x, f(x)} end
  local b = brush{kind="round", width=6, stiffness=0.6}
  b:load(board, 1); b:stroke(pts, {pressure={0.9, 0.9}, clip=wall})
  -- rolls stacked on it: little discs above the board, in heaps
  for x = 10, 990, 13 do
    local h = ((x * 0.618034 + si * 0.37) % 1)
    if h < 0.82 then
      local y = f(x) - 8 - ((h < 0.3) and 13 or 0)
      local lit = math.abs(x - 500) < 330 and y > 120
      local r = 5 + 2 * h
      local e = ellipse(x, y, r, r) * wall
      work(e, {hand="detail", pile=lit and endL or endD, coverage=5, fill=true, clip=e, load=1})
      local c = brush{kind="round", width=1.4}
      c:load(board, 0.9); c:touch(x, y, {pressure=0.6, clip=e})
    end
  end
end
-- the table's rim, thick bronze, lit on its top edge; the shadow under it
local rim = (ellipse(TX, TY + 26, TRX + 6, TRY + 6) - TABLE) * below(function(x) return TY - 10 end)
work(rim, {hand="body", tool="filbert 5", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.9}, medium=0.06}, coverage=6, fill=true, clip=rim, angle=0, load=1})
local lip = {}
for j = 0, 40 do local a = math.pi * j / 40; lip[#lip+1] = {TX + (TRX + 2) * math.cos(a), TY + (TRY + 2) * math.sin(a)} end
local lb = brush{kind="round", width=2.2, point=0.4}
lb:load(pile{{"yellow ochre",1},{"lead white",0.7},{"raw sienna",0.3}, medium=0.06}, 0.9); lb:stroke(lip, {pressure={0.4, 0.4}})
local sh = ellipse(TX, TY + 70, TRX * 0.9, 34) - rim - TABLE
work(sh, {hand="body", tool="filbert 8", pile=pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=sh, angle=0, load=1})
blend(sh:grow(10) - sh:shrink(8) - rim - TABLE, {angle=0})
RIM = rim

--@ chunk 3
-- the inked plan on the table, foreshortened (y squashed): room-glyphs, edge ticks, bridging arcs, rotated insets, a spiral of insets
print(wait(2*24*60))
local ink = pile{{"burnt sienna",1},{"bone black",1},{"Mars brown",0.3}, medium=0.06}
local inkL = pile{{"burnt sienna",1},{"bone black",0.5},{"raw sienna",0.5},{"lead white",0.3}, medium=0.06}
local SQ = TRY / TRX
local function T(u, v) return {TX + u, TY + v * SQ} end
local function poly_(cx, cy, n, r, rot, stretch)
  local pts = {}
  for j = 0, n do local a = rot + 2 * math.pi * j / n; pts[#pts+1] = T(cx + r * math.cos(a) * (stretch or 1), cy + r * math.sin(a)) end
  return pts
end
local function st(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.4}
  b:load(pl, 0.85); b:stroke(pts, {pressure=pr or {0.6, 0.6}, clip=TABLE})
end
local function glyph(cx, cy, n, r, rot, stretch, insetTurn, depth)
  st(poly_(cx, cy, n, r, rot, stretch), ink, 1.4)
  -- edge ticks on two edges
  for _, e in ipairs{0, 2} do
    local a = rot + 2 * math.pi * (e + 0.5) / n
    local mx, my = cx + r * 1.06 * math.cos(a) * (stretch or 1), cy + r * 1.06 * math.sin(a)
    st({T(mx, my), T(mx + 6 * math.cos(a), my + 6 * math.sin(a))}, ink, 1.0)
  end
  -- the holonomy inset: a smaller copy, turned
  local rr, rt = r * 0.618, rot + insetTurn
  for d = 1, depth do
    st(poly_(cx, cy, n, rr, rt, stretch), inkL, 1.0)
    rr = rr * 0.618; rt = rt + insetTurn
  end
end
-- rooms around the table, the heart in the middle with six petals (THE FOLD)
glyph(0, 0, 6, 48, 0.2, 1, 0, 1)
for i = 0, 5 do
  local a = 0.2 + i * math.pi / 3
  local cx, cy = 128 * math.cos(a), 128 * math.sin(a)
  glyph(cx, cy, (i % 2 == 0) and 5 or 4, 34, a, 1, (i % 3 == 0) and 0.6 or 0.25, 2)
  -- bridge arcs: petal to heart, petal to neighbour
  st({T(48 * math.cos(a), 48 * math.sin(a)), T(70 * math.cos(a + 0.12), 70 * math.sin(a + 0.12)), T(94 * math.cos(a), 94 * math.sin(a))}, ink, 1.1)
  local b2 = a + math.pi / 3
  st({T(cx + 30 * math.cos(a + 1.2), cy + 30 * math.sin(a + 1.2)), T(150 * math.cos(a + math.pi / 6), 150 * math.sin(a + math.pi / 6)), T(128 * math.cos(b2) + 30 * math.cos(b2 - 1.2), 128 * math.sin(b2) + 30 * math.sin(b2 - 1.2))}, inkL, 1.0)
end
-- an outer long corridor-glyph spiralling into itself at the right (RECURSION STACK)
local sx, sy, r, rot = 245, -10, 30, 0
for d = 1, 6 do st(poly_(sx, sy, 4, r, rot, 2.2), (d == 1) and ink or inkL, math.max(0.7, 1.4 - d * 0.1)); r = r * 0.618; rot = rot + 0.5 end
-- a self-gluing at the left: an arc leaving a room and returning to it
glyph(-250, 10, 4, 30, 0.3, 1.6, 0.9, 1)
st({T(-220, -20), T(-200, -60), T(-260, -70), T(-290, -30)}, ink, 1.2)
-- small arrows along corridors
for _, q in ipairs{{-170, 50, 0.3}, {170, -60, 2.6}, {60, 160, -1.4}, {-80, -150, 1.8}} do
  local x, y, a = q[1], q[2], q[3]
  st({T(x, y), T(x + 16 * math.cos(a), y + 16 * math.sin(a))}, ink, 1.0)
  st({T(x + 16 * math.cos(a), y + 16 * math.sin(a)), T(x + 10 * math.cos(a + 0.5), y + 10 * math.sin(a + 0.5))}, ink, 1.0)
end

--@ chunk 4
-- the room-glyphs restated with crisp corners (each edge its own stroke); the corrected corridor: an old line scraped pale,
-- a fresh dark one beside it; the lamp hanging over the centre; the docent leaning over the far side
print(wait(2*24*60))
local ink = pile{{"burnt sienna",1},{"bone black",1.1}, medium=0.06}
local SQ = TRY / TRX
local function T(u, v) return {TX + u, TY + v * SQ} end
local function edge(a, b, w, pl)
  local br = brush{kind="round", width=w, point=0.3}
  br:load(pl or ink, 0.85); br:stroke({a, b}, {pressure={0.7, 0.7}, clip=TABLE})
end
local function cpoly(cx, cy, n, r, rot, stretch, w)
  local p = {}
  for j = 0, n - 1 do local a = rot + 2 * math.pi * j / n; p[#p+1] = T(cx + r * math.cos(a) * (stretch or 1), cy + r * math.sin(a)) end
  for j = 1, n do edge(p[j], p[j % n + 1], w) end
end
cpoly(0, 0, 6, 48, 0.2, 1, 1.6)
for i = 0, 5 do
  local a = 0.2 + i * math.pi / 3
  cpoly(128 * math.cos(a), 128 * math.sin(a), (i % 2 == 0) and 5 or 4, 34, a, 1, 1.4)
end
-- the corridor being corrected: between the heart and the lower-right petal
local old1, old2 = T(40, 30), T(110, 95)
edge(old1, old2, 3, pile{{"lead white",1.6},{"yellow ochre",0.4}, medium=0.05})
edge(T(52, 22), T(128, 82), 1.8, pile{{"bone black",2},{"burnt sienna",0.6}, medium=0.06})
-- the lamp: chain, a bronze shade, a white bulb under it, a small glow
local lx, ly = 500, 200
local ch = brush{kind="round", width=1.6}
ch:load(pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, 0.9); ch:stroke({{lx, 0}, {lx, ly - 22}}, {pressure={0.8, 0.8}})
local shade = poly({{lx - 14, ly - 24}, {lx + 14, ly - 24}, {lx + 38, ly}, {lx - 38, ly}}, true)
work(shade, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.8}, medium=0.06}, coverage=6, fill=true, clip=shade, load=1})
local sl = brush{kind="round", width=2, point=0.4}
sl:load(pile{{"yellow ochre",1},{"lead white",0.6}, medium=0.06}, 0.8); sl:stroke({{lx - 13, ly - 23}, {lx + 13, ly - 23}}, {pressure={0.5, 0.5}})
local bulb = ellipse(lx, ly + 3, 16, 5)
work(bulb, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.08}, medium=0.03}, coverage=6, fill=true, clip=bulb, load=1})
-- the docent on the far side, leaning in over the table toward us
local robeD = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local robeL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5},{"burnt sienna",0.3}, medium=0.06}
BODY = poly({{352, 262}, {418, 250}, {450, 290}, {460, 382}, {330, 382}, {336, 300}}, true)
work(BODY, {hand="body", tool="filbert 5", pile=robeD, coverage=6, fill=true, clip=BODY, angle=math.pi/2, load=1})
local top = BODY * ellipse(400, 262, 62, 26)
work(top, {hand="body", tool="filbert 4", pile=robeL, coverage=5, fill=true, clip=top, angle=0, load=1})
blend(BODY * ellipse(400, 272, 64, 22))
HOOD = ellipse(408, 238, 25, 28)
work(HOOD, {hand="detail", pile=robeD, coverage=6, fill=true, clip=HOOD, load=1})
local crown = HOOD * ellipse(412, 222, 22, 14)
work(crown, {hand="detail", pile=robeL, coverage=5, fill=true, clip=crown, load=1})
FACE = poly({{410, 236}, {430, 244}, {432, 266}, {418, 270}, {408, 252}}, true)
work(FACE, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}, coverage=6, fill=true, clip=FACE, load=1})
-- arms down onto the table: compass hand on the left, stylus hand reaching toward the corrected corridor
ARMS = ribbon({{372, 290}, {380, 345}, {410, 395}}, {20, 16, 12}) + ribbon({{440, 288}, {480, 330}, {540, 400}}, {18, 15, 11})
work(ARMS, {hand="body", tool="filbert 3", pile=robeD, coverage=6, fill=true, clip=ARMS, angle=math.pi/2, load=1})
local al = brush{kind="round", width=2.2, point=0.4}
al:load(robeL, 0.9); al:stroke({{442, 282}, {484, 323}, {543, 393}}, {pressure={0.7, 0.4}})
-- bone hands
local bone = pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}
local hb = brush{kind="round", width=5, point=0.5}
hb:load(bone, 0.9); hb:stroke({{406, 396}, {414, 404}}, {pressure={0.8, 0.6}})
hb:load(bone, 0.9); hb:stroke({{538, 400}, {548, 410}}, {pressure={0.8, 0.6}})
-- the compass: two bronze legs from the left hand, spread on the plan
local cp = pile{{"yellow ochre",1},{"Mars orange",0.4},{"burnt sienna",0.5},{"lead white",0.3}, medium=0.06}
local cb = brush{kind="round", width=2, point=0.5}
cb:load(cp, 0.9); cb:stroke({{410, 398}, {392, 440}}, {pressure={0.8, 0.3}})
cb:load(cp, 0.9); cb:stroke({{410, 398}, {440, 436}}, {pressure={0.8, 0.3}})
-- the stylus: a thin bone rod from the right hand to the fresh line
local sb = brush{kind="round", width=1.6, point=0.6}
sb:load(bone, 0.9); sb:stroke({{544, 404}, {560, 440}}, {pressure={0.8, 0.2}})

--@ chunk 5
-- on set paint: the docent restated opaque and larger in the shoulders, its arms as sleeves, lit from the lamp above on the
-- crown, shoulders and the tops of the sleeves; a soft glow round the lamp; the Commando at the near right edge, pointing
print(wait(4*24*60))
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local robeL = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.2}, medium=0.06}
local SLV = ribbon({{368, 286}, {372, 340}, {404, 392}}, {30, 24, 16}) + ribbon({{438, 284}, {482, 330}, {536, 396}}, {28, 22, 15})
local D = (BODY + SLV + HOOD) - FACE
work(D, {hand="body", tool="filbert 4", pile=robeD, coverage=7, fill=true, clip=D, angle=math.pi/2, load=1})
print(wait(3*24*60))
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm})
end
local Dg = D:grow(1.5)
ln({{390, 216}, {408, 210}, {428, 216}}, robeL, 4, {0.7, 0.8}, Dg)
ln({{340, 278}, {372, 258}, {408, 254}, {440, 266}, {456, 284}}, robeL, 4.5, {0.6, 0.8}, Dg)
ln({{362, 288}, {360, 340}, {392, 386}}, robeL, 3, {0.7, 0.3}, Dg)
ln({{446, 278}, {490, 320}, {538, 384}}, robeL, 3, {0.8, 0.4}, Dg)
work(FACE, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}, coverage=6, fill=true, clip=FACE, load=1})
local lens = ellipse(426, 254, 3, 3)
work(lens, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}, coverage=6, fill=true, clip=lens, load=1})
local gl = brush{kind="round", width=1.2}; gl:load(pile{{"zinc white",3}, medium=0.03}, 0.9); gl:touch(427, 253, {pressure=0.6})
-- the lamp's glow, a soft halo below and around the bulb
local lx, ly = 500, 200
local halo = ellipse(lx, ly + 6, 70, 34) - ellipse(lx, ly + 3, 17, 6) - poly({{lx - 14, ly - 24}, {lx + 14, ly - 24}, {lx + 38, ly}, {lx - 38, ly}}) - D
stipple(halo, {pile=pile{{"yellow ochre",1},{"lead white",0.9},{"raw sienna",0.2}, medium=0.05}, width=1.1, coverage=function(x, y) local d = math.sqrt(((x - lx) / 70)^2 + ((y - ly - 6) / 34)^2); return clamp(1 - d, 0, 1)^1.6 * 2.6 end, feather=0.9, cluster=0.1})
-- the Commando, near right, three-quarter from behind, leaning on the rim, his right arm out pointing at a room on the plan
local k = 200
local fx, fy = 790, 742
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11, 0.93), Q(-0.13, 0.5), Q(-0.14, 0.05)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + ribbon({Q(0.11, 0.93), Q(0.13, 0.5), Q(0.15, 0.05)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + poly({Q(-0.19, 0.88), Q(0.19, 0.88), Q(0.2, 1.06), Q(-0.2, 1.06)}, true)
  + poly({Q(-0.17, 1.02), Q(0.17, 1.02), Q(0.23, 1.32), Q(0.3, 1.5), Q(0.27, 1.58), Q(0.1, 1.61), Q(-0.1, 1.61), Q(-0.27, 1.58), Q(-0.3, 1.5), Q(-0.23, 1.32)}, true)
  + poly({Q(-0.17, 1.12), Q(0.16, 1.12), Q(0.18, 1.52), Q(-0.18, 1.53)})
  + poly({Q(-0.05, 1.55), Q(0.05, 1.55), Q(0.05, 1.67), Q(-0.05, 1.67)})
  + ellipse(fx - 0.03 * k, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(0.3, 1.5), Q(0.36, 1.26), Q(0.33, 1.02)}, {0.12 * k, 0.1 * k, 0.09 * k})
  + ribbon({Q(-0.3, 1.52), Q(-0.6, 1.3), Q(-0.92, 1.12)}, {0.12 * k, 0.1 * k, 0.085 * k})
  + ellipse(fx - 0.97 * k, fy - 1.1 * k, 0.07 * k, 0.05 * k)
  + ribbon({Q(-0.98, 1.1), Q(-1.13, 1.04)}, 0.025 * k)
FIG = fig
work(fig, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.35}, medium=0.06}, coverage=7, fill=true, clip=fig, angle=math.pi/2, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 6
-- on set paint: the lamp's light on the Commando's top planes (helm crown, pauldrons, the pointing arm and gauntlet), table
-- bounce warming his front edge; plate seams; the docent's face set back into its hood
print(wait(4*24*60))
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local top = pile{{"yellow ochre",1},{"lead white",0.9},{"raw sienna",0.3}, medium=0.06}
local bounce = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.3}, medium=0.06}
local seam = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
local Fg = FIG:grow(1.5)
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm == false and nil or (clipm or Fg)})
end
ln({Q(-0.12, 1.86), Q(-0.04, 1.89), Q(0.06, 1.86)}, top, 3, {0.7, 0.6})
ln({Q(-0.4, 1.56), Q(-0.3, 1.62), Q(-0.15, 1.61)}, top, 3.4, {0.6, 0.9})
ln({Q(0.15, 1.61), Q(0.3, 1.62), Q(0.39, 1.56)}, top, 3, {0.8, 0.5})
ln({Q(-0.32, 1.6), Q(-0.6, 1.38), Q(-0.92, 1.19)}, top, 2.6, {0.8, 0.6})
ln({Q(-0.92, 1.16), Q(-1.0, 1.14), Q(-1.12, 1.08)}, top, 2, {0.7, 0.4})
ln({Q(-0.3, 1.45), Q(-0.24, 1.2), Q(-0.18, 0.95)}, bounce, 2.4, {0.7, 0.2})
ln({Q(-0.19, 0.9), Q(-0.2, 0.5), Q(-0.2, 0.1)}, bounce, 2, {0.5, 0.05})
ln({Q(-0.2, 1.06), Q(0.2, 1.06)}, seam, 1.6, {0.6, 0.6})
ln({Q(-0.17, 1.32), Q(0.2, 1.32)}, seam, 1.4, {0.5, 0.5})
ln({Q(-0.13, 0.52), Q(-0.03, 0.52)}, seam, 1.4, {0.5, 0.5})
-- the docent's face: hood edge over it so it sits inside
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
ln({{432, 236}, {438, 252}, {436, 270}}, robeD, 5, {0.8, 0.6}, false)
ln({{404, 230}, {420, 226}, {434, 236}}, robeD, 4, {0.8, 0.8}, false)

--@ chunk 7
-- on set paint: the lamp's light on the Commando's top planes (helm crown, pauldrons, the pointing arm and gauntlet), table
-- bounce warming his front edge; plate seams; the docent's face set back into its hood
print(wait(8*24*60))
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local top = pile{{"yellow ochre",1},{"lead white",0.9},{"raw sienna",0.3}, medium=0.06}
local bounce = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.3}, medium=0.06}
local seam = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
local Fg = FIG:grow(1.5)
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm == false and nil or (clipm or Fg)})
end
ln({Q(-0.12, 1.86), Q(-0.04, 1.89), Q(0.06, 1.86)}, top, 4, {0.9, 0.8})
ln({Q(-0.4, 1.56), Q(-0.3, 1.62), Q(-0.15, 1.61)}, top, 4.4, {0.8, 0.95})
ln({Q(0.15, 1.61), Q(0.3, 1.62), Q(0.39, 1.56)}, top, 4, {0.9, 0.7})
ln({Q(-0.32, 1.6), Q(-0.6, 1.38), Q(-0.92, 1.19)}, top, 3.4, {0.9, 0.8})
ln({Q(-0.92, 1.16), Q(-1.0, 1.14), Q(-1.12, 1.08)}, top, 2, {0.7, 0.4})
ln({Q(-0.3, 1.45), Q(-0.24, 1.2), Q(-0.18, 0.95)}, bounce, 2.4, {0.7, 0.2})
ln({Q(-0.19, 0.9), Q(-0.2, 0.5), Q(-0.2, 0.1)}, bounce, 2, {0.5, 0.05})
ln({Q(-0.2, 1.06), Q(0.2, 1.06)}, seam, 1.6, {0.6, 0.6})
ln({Q(-0.17, 1.32), Q(0.2, 1.32)}, seam, 1.4, {0.5, 0.5})
ln({Q(-0.13, 0.52), Q(-0.03, 0.52)}, seam, 1.4, {0.5, 0.5})
-- the docent's face: hood edge over it so it sits inside
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
ln({{432, 236}, {438, 252}, {436, 270}}, robeD, 5, {0.8, 0.6}, false)
ln({{404, 230}, {420, 226}, {434, 236}}, robeD, 4, {0.8, 0.8}, false)
