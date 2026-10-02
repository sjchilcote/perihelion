-- easel session "clockmaker": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=750, aspect=3/4, linen={18,16}, seed=3131,
  ground={{pile={{"bone black",1},{"burnt sienna",0.9},{"ultramarine blue",0.3},{"lead white",0.4}}, um=110, apply="knife", texture=0.4}}}
-- a tall dim clock-room: the great face high on the back wall, a lamp hung near its upper right where the docent winds it
CX, CY, CR = 470, 470, 350
LX, LY = 700, 250
FLOORY = 1190
WALLM = rect(0, 0, 1000, FLOORY)
FLOORM = rect(0, FLOORY, 1000, 200)
local wD = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
local wM = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local wL = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local r1 = ellipse(LX, LY + 40, 520, 560)
local r2 = ellipse(LX, LY + 20, 300, 320)
work(WALLM - r1, {hand="body", tool="filbert 12", pile=wD, coverage=4, fill=true, clip=WALLM - r1, angle=math.pi/2, load=1})
work((WALLM * r1) - r2, {hand="body", tool="filbert 12", pile=wM, coverage=4, fill=true, clip=(WALLM * r1) - r2, angle=math.pi/2, load=1})
work(WALLM * r2, {hand="body", tool="filbert 10", pile=wL, coverage=4, fill=true, clip=WALLM * r2, angle=math.pi/2, load=1})
blend(WALLM * (ellipse(LX, LY + 40, 540, 580) - ellipse(LX, LY + 40, 500, 540)))
blend(WALLM * (ellipse(LX, LY + 20, 320, 340) - ellipse(LX, LY + 20, 280, 300)))
work(FLOORM, {hand="body", tool="filbert 12", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}, coverage=4, fill=true, clip=FLOORM, angle=0, load=1})
local sk = rect(0, FLOORY - 8, 1000, 14)
work(sk, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=sk, load=1})
print(W, H)

--@ chunk 2
-- the great face: a bronze disc of nested rings, each ring lit on its lamp side (upper right) and dark on the far side;
-- fold glyphs round the outer band, a turned inset at the hub; the single hand nearly at the top
print(wait(3*24*60))
FACEM = ellipse(CX, CY, CR, CR)
local dk = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local md = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local lt = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.5},{"burnt sienna",0.2}, medium=0.06}
local litSide = mask(function(x, y) return ((x - CX) * 0.75 - (y - CY) * 0.66 > 0) and 1 or 0 end):soften(30)
work(FACEM - litSide, {hand="body", tool="filbert 10", pile=dk, coverage=5, fill=true, clip=FACEM - litSide, angle=0, load=1})
work(FACEM * litSide, {hand="body", tool="filbert 10", pile=md, coverage=5, fill=true, clip=FACEM * litSide, angle=0, load=1})
-- ring ridges: dark grooves with a lit lip on the lamp side
local function circ(r, a0, a1, n)
  local pts = {}
  n = n or 48
  for j = 0, n do local a = a0 + (a1 - a0) * j / n; pts[#pts+1] = {CX + r * math.cos(a), CY + r * math.sin(a)} end
  return pts
end
local groove = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local lip = pile{{"yellow ochre",1.2},{"lead white",0.8},{"Mars orange",0.15}, medium=0.06}
local hot = pile{{"lead white",1.8},{"yellow ochre",0.6},{"cadmium yellow",0.2}, medium=0.05}
RINGS = {340, 300, 236, 180, 120, 62}
for i, r in ipairs(RINGS) do
  local b = brush{kind="round", width=(i == 1) and 10 or 5, stiffness=0.6}
  b:load(groove, 1); b:stroke(circ(r, 0, 2 * math.pi), {pressure={0.9, 0.9}, ramps={0.01, 0.01}})
  local l = brush{kind="round", width=(i == 1) and 3.4 or 2.2, point=0.4}
  l:load((i <= 2) and hot or lip, 0.9)
  l:stroke(circ(r - ((i == 1) and 7 or 4), -math.pi * 0.95, math.pi * 0.05, 30), {pressure={0.1, 0.1}, swell={0.2, 1, 1.4, 1, 0.2}})
end
-- fold glyphs in the outer band (between 300 and 340): small polygons with turned insets, at golden-ratio gaps
local ink = pile{{"bone black",1.8},{"burnt sienna",0.5}, medium=0.06}
local boneG = pile{{"lead white",1.4},{"yellow ochre",0.5},{"bone black",0.2}, medium=0.06}
local a = -math.pi / 2 + 0.25
local n = 0
while a < 1.5 * math.pi - 0.2 do
  n = n + 1
  local gx, gy = CX + 320 * math.cos(a), CY + 320 * math.sin(a)
  local sides = 3 + (n % 4)
  local lit = ((gx - CX) * 0.75 - (gy - CY) * 0.66) > 0
  local r, rot = 12, a
  for d = 1, 2 do
    local pts = {}
    for j = 0, sides do local t = rot + 2 * math.pi * j / sides; pts[#pts+1] = {gx + r * math.cos(t), gy + r * math.sin(t)} end
    local b = brush{kind="round", width=1.6, point=0.4}
    b:load(lit and boneG or ink, 0.85); b:stroke(pts, {pressure={0.6, 0.6}})
    r = r * 0.618; rot = rot + 0.4 * n
  end
  a = a + ((n % 2 == 0) and 0.236 or 0.382)
end
-- in the middle band, a ring of marks counting down: short ticks, the last few (near the top) bright
for j = 0, 59 do
  local t = -math.pi / 2 + 2 * math.pi * j / 60
  local r0, r1 = 245, (j % 5 == 0) and 290 or 270
  local b = brush{kind="round", width=(j % 5 == 0) and 3 or 1.8, point=0.3}
  local near = (j >= 55)
  b:load(near and hot or ink, 0.85)
  b:stroke({{CX + r0 * math.cos(t), CY + r0 * math.sin(t)}, {CX + r1 * math.cos(t), CY + r1 * math.sin(t)}}, {pressure={0.7, 0.7}})
end
-- hub: a turned hexagon inset
for d, r in ipairs{55, 34, 21} do
  local pts = {}
  for j = 0, 6 do local t = 0.3 * d + 2 * math.pi * j / 6; pts[#pts+1] = {CX + r * math.cos(t), CY + r * math.sin(t)} end
  local b = brush{kind="round", width=2.2, point=0.4}
  b:load(boneG, 0.85); b:stroke(pts, {pressure={0.6, 0.6}})
end
-- the single hand, nearly at the top (a few minutes before), a long bronze blade with a bone tip
local ha = -math.pi / 2 - 0.12
HAND = ribbon({{CX - 30 * math.cos(ha), CY - 30 * math.sin(ha)}, {CX + 200 * math.cos(ha), CY + 200 * math.sin(ha)}, {CX + 300 * math.cos(ha), CY + 300 * math.sin(ha)}}, {16, 9, 3})
work(HAND, {hand="detail", pile=dk, coverage=7, fill=true, clip=HAND, load=1})
local hl = brush{kind="round", width=2.4, point=0.5}
hl:load(hot, 0.9); hl:stroke({{CX + 6, CY - 20}, {CX + 200 * math.cos(ha) + 4, CY + 200 * math.sin(ha)}, {CX + 296 * math.cos(ha) + 1, CY + 296 * math.sin(ha)}}, {pressure={0.8, 0.3}})
local hub = ellipse(CX, CY, 14, 14)
work(hub, {hand="detail", pile=lt, coverage=6, fill=true, clip=hub, load=1})

--@ chunk 3
-- the hard diagonal split and the sunken rings: the face repainted graded by distance from the lamp (three steps, blended),
-- inside a heavy dark bezel; once set, the rings, glyphs, ticks and hand restated on top
print(wait(4*24*60))
local d1 = ellipse(LX, LY, 230, 230) * FACEM
local d2 = ellipse(LX, LY, 420, 420) * FACEM - d1
local d3 = FACEM - d1 - d2
local p1 = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.35}, medium=0.06}
local p2 = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.55},{"yellow ochre",0.15}, medium=0.06}
local p3 = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
work(d3, {hand="body", tool="filbert 10", pile=p3, coverage=6, fill=true, clip=d3, angle=0, load=1})
work(d2, {hand="body", tool="filbert 10", pile=p2, coverage=6, fill=true, clip=d2, angle=0, load=1})
work(d1, {hand="body", tool="filbert 8", pile=p1, coverage=6, fill=true, clip=d1, angle=0, load=1})
blend((ellipse(LX, LY, 245, 245) - ellipse(LX, LY, 215, 215)) * FACEM)
blend((ellipse(LX, LY, 440, 440) - ellipse(LX, LY, 400, 400)) * FACEM)
local bez = ellipse(CX, CY, CR + 22, CR + 22) - FACEM
work(bez, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.8},{"burnt sienna",0.7}, medium=0.06}, coverage=7, fill=true, clip=bez, angle=0, load=1})

--@ chunk 4
print(wait(6*24*60))
print(wait(3*24*60))
local dk = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local md = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local lt = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.5},{"burnt sienna",0.2}, medium=0.06}
-- ring ridges: dark grooves with a lit lip on the lamp side
local function circ(r, a0, a1, n)
  local pts = {}
  n = n or 48
  for j = 0, n do local a = a0 + (a1 - a0) * j / n; pts[#pts+1] = {CX + r * math.cos(a), CY + r * math.sin(a)} end
  return pts
end
local groove = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local lip = pile{{"yellow ochre",1.2},{"lead white",0.8},{"Mars orange",0.15}, medium=0.06}
local hot = pile{{"lead white",1.8},{"yellow ochre",0.6},{"cadmium yellow",0.2}, medium=0.05}
RINGS = {340, 300, 236, 180, 120, 62}
for i, r in ipairs(RINGS) do
  local b = brush{kind="round", width=(i == 1) and 10 or 5, stiffness=0.6}
  b:load(groove, 1); b:stroke(circ(r, 0, 2 * math.pi), {pressure={0.9, 0.9}, ramps={0.01, 0.01}})
  local l = brush{kind="round", width=(i == 1) and 3.4 or 2.2, point=0.4}
  l:load((i <= 2) and hot or lip, 0.9)
  l:stroke(circ(r - ((i == 1) and 7 or 4), -math.pi * 0.95, math.pi * 0.05, 30), {pressure={0.1, 0.1}, swell={0.2, 1, 1.4, 1, 0.2}})
end
-- fold glyphs in the outer band (between 300 and 340): small polygons with turned insets, at golden-ratio gaps
local ink = pile{{"bone black",1.8},{"burnt sienna",0.5}, medium=0.06}
local boneG = pile{{"lead white",1.4},{"yellow ochre",0.5},{"bone black",0.2}, medium=0.06}
local a = -math.pi / 2 + 0.25
local n = 0
while a < 1.5 * math.pi - 0.2 do
  n = n + 1
  local gx, gy = CX + 320 * math.cos(a), CY + 320 * math.sin(a)
  local sides = 3 + (n % 4)
  local lit = ((gx - CX) * 0.75 - (gy - CY) * 0.66) > 0
  local r, rot = 12, a
  for d = 1, 2 do
    local pts = {}
    for j = 0, sides do local t = rot + 2 * math.pi * j / sides; pts[#pts+1] = {gx + r * math.cos(t), gy + r * math.sin(t)} end
    local b = brush{kind="round", width=1.6, point=0.4}
    b:load(lit and boneG or ink, 0.85); b:stroke(pts, {pressure={0.6, 0.6}})
    r = r * 0.618; rot = rot + 0.4 * n
  end
  a = a + ((n % 2 == 0) and 0.236 or 0.382)
end
-- in the middle band, a ring of marks counting down: short ticks, the last few (near the top) bright
for j = 0, 59 do
  local t = -math.pi / 2 + 2 * math.pi * j / 60
  local r0, r1 = 245, (j % 5 == 0) and 290 or 270
  local b = brush{kind="round", width=(j % 5 == 0) and 3 or 1.8, point=0.3}
  local near = (j >= 55)
  b:load(near and hot or ink, 0.85)
  b:stroke({{CX + r0 * math.cos(t), CY + r0 * math.sin(t)}, {CX + r1 * math.cos(t), CY + r1 * math.sin(t)}}, {pressure={0.7, 0.7}})
end
-- hub: a turned hexagon inset
for d, r in ipairs{55, 34, 21} do
  local pts = {}
  for j = 0, 6 do local t = 0.3 * d + 2 * math.pi * j / 6; pts[#pts+1] = {CX + r * math.cos(t), CY + r * math.sin(t)} end
  local b = brush{kind="round", width=2.2, point=0.4}
  b:load(boneG, 0.85); b:stroke(pts, {pressure={0.6, 0.6}})
end
-- the single hand, nearly at the top (a few minutes before), a long bronze blade with a bone tip
local ha = -math.pi / 2 - 0.12
HAND = ribbon({{CX - 30 * math.cos(ha), CY - 30 * math.sin(ha)}, {CX + 200 * math.cos(ha), CY + 200 * math.sin(ha)}, {CX + 300 * math.cos(ha), CY + 300 * math.sin(ha)}}, {16, 9, 3})
work(HAND, {hand="detail", pile=dk, coverage=7, fill=true, clip=HAND, load=1})
local hl = brush{kind="round", width=2.4, point=0.5}
hl:load(hot, 0.9); hl:stroke({{CX + 6, CY - 20}, {CX + 200 * math.cos(ha) + 4, CY + 200 * math.sin(ha)}, {CX + 296 * math.cos(ha) + 1, CY + 296 * math.sin(ha)}}, {pressure={0.8, 0.3}})
local hub = ellipse(CX, CY, 14, 14)
work(hub, {hand="detail", pile=lt, coverage=6, fill=true, clip=hub, load=1})

--@ chunk 5
-- the ladder leaning on the wall beside the face, its lantern hooked at the top; the docent near the top, winding with a long
-- key in a keyhole on the face; the Commando at the foot, holding the ladder; the floor pool
print(wait(3*24*60))
local brD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5},{"burnt sienna",0.2}, medium=0.06}
local hot = pile{{"lead white",1.8},{"yellow ochre",0.6},{"cadmium yellow",0.25}, medium=0.05}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.02, 0.02}, clip=clipm})
end
-- floor pool under the ladder
local fp = ellipse(760, 1240, 260, 55) * FLOORM
work(fp, {hand="body", tool="filbert 8", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}, coverage=5, fill=true, clip=fp, angle=0, load=1})
blend(FLOORM * (ellipse(760, 1240, 280, 64) - ellipse(760, 1240, 235, 44)), {angle=0})
-- ladder: two rails from the floor up to beside the lantern, rungs
local A0, A1 = {770, 1196}, {668, 236}
local B0, B1 = {850, 1196}, {742, 236}
LADDER = ribbon({A0, A1}, 9) + ribbon({B0, B1}, 9)
for t = 0.04, 0.98, 0.075 do
  LADDER = LADDER + ribbon({{lerp(A0[1], A1[1], t), lerp(A0[2], A1[2], t)}, {lerp(B0[1], B1[1], t), lerp(B0[2], B1[2], t)}}, 6)
end
work(LADDER, {hand="detail", pile=brD, coverage=7, fill=true, clip=LADDER, load=1})
st({{A0[1] - 3, A0[2]}, {A1[1] - 3, A1[2]}}, brL, 2.2, {0.3, 0.9})
st({{B0[1] - 3, B0[2]}, {B1[1] - 3, B1[2]}}, brL, 2, {0.3, 0.9})
-- the lantern hooked at the top
local lx, ly = 705, 258
st({{lx, 230}, {lx, ly - 18}}, brD, 2, {0.9, 0.9})
local cage = poly({{lx - 14, ly - 18}, {lx + 14, ly - 18}, {lx + 16, ly + 18}, {lx - 16, ly + 18}}, true)
work(cage, {hand="detail", pile=hot, coverage=7, fill=true, clip=cage, load=1})
local core = ellipse(lx, ly, 6, 11)
work(core, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.03}, coverage=7, fill=true, clip=core, load=1})
for _, dx in ipairs{-15, 0, 15} do st({{lx + dx * 0.9, ly - 18}, {lx + dx, ly + 18}}, brD, 1.8, {0.8, 0.8}) end
st({{lx - 18, ly - 19}, {lx + 18, ly - 19}}, brD, 3, {0.9, 0.9}); st({{lx - 18, ly + 19}, {lx + 18, ly + 19}}, brD, 3, {0.9, 0.9})
-- keyhole in the face, left of the ladder
KEY = {600, 345}
local kh = ellipse(KEY[1], KEY[2], 13, 13)
work(kh, {hand="detail", pile=brD, coverage=7, fill=true, clip=kh, load=1})
st({{KEY[1] - 11, KEY[2] - 8}, {KEY[1] - 2, KEY[2] - 14}, {KEY[1] + 8, KEY[2] - 11}}, hot, 2, {0.6, 0.8})

--@ chunk 6
-- the docent on the ladder, facing the face, both hands on a long key turned in the keyhole; the Commando at the foot holding
-- the rails; the floor pool's edge lost
print(wait(3*24*60))
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local hot = pile{{"lead white",1.8},{"yellow ochre",0.6},{"cadmium yellow",0.25}, medium=0.05}
local warm = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.05, 0.2}, clip=clipm})
end
DROBE = poly({{700, 380}, {742, 372}, {770, 420}, {788, 560}, {796, 650}, {700, 655}, {692, 560}, {688, 440}}, true)
work(DROBE, {hand="body", tool="filbert 5", pile=robeD, coverage=7, fill=true, clip=DROBE, angle=math.pi/2, load=1})
DHEAD = ellipse(712, 356, 24, 28)
work(DHEAD, {hand="detail", pile=robeD, coverage=7, fill=true, clip=DHEAD, load=1})
DFACE = poly({{702, 342}, {690, 352}, {688, 374}, {698, 380}, {706, 362}}, true)
work(DFACE, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}, coverage=7, fill=true, clip=DFACE, load=1})
DARMS = ribbon({{704, 400}, {680, 420}, {660, 400}}, {18, 15, 12}) + ribbon({{730, 410}, {700, 440}, {668, 420}}, {16, 14, 11})
work(DARMS, {hand="detail", pile=robeD, coverage=7, fill=true, clip=DARMS, load=1})
-- the long key: shaft from the keyhole to the hands, a crossbar the hands grip
local keyP = pile{{"yellow ochre",1},{"Mars orange",0.5},{"burnt sienna",0.5},{"lead white",0.25}, medium=0.06}
st({{600, 345}, {660, 405}}, keyP, 5, {0.9, 0.9})
st({{640, 420}, {680, 384}}, keyP, 7, {0.9, 0.9})
local bone = pile{{"lead white",1.8},{"yellow ochre",0.45}, medium=0.05}
st({{652, 398}, {662, 404}}, bone, 5, {0.8, 0.6})
st({{664, 414}, {672, 418}}, bone, 5, {0.8, 0.6})
-- lantern light on the docent: crown, the face's brow, shoulders, the sleeves' tops, the robe's right edge
local Dg = (DROBE + DHEAD + DARMS):grow(1.5)
st({{698, 330}, {714, 326}, {730, 334}}, hot, 3.4, {0.8, 0.8}, Dg)
st({{710, 386}, {736, 376}, {760, 396}}, warm, 3.4, {0.7, 0.8}, Dg)
st({{702, 396}, {680, 412}, {662, 396}}, warm, 2.4, {0.7, 0.4}, Dg)
st({{762, 410}, {784, 540}, {794, 640}}, warm, 2.6, {0.8, 0.2}, Dg)
-- feet on a rung
st({{716, 652}, {764, 652}}, robeD, 7, {0.9, 0.9})
-- the Commando at the foot, his back to us, both hands up on the rails
local k = 205
local fx, fy = 805, 1225
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11, 0.93), Q(-0.13, 0.5), Q(-0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + ribbon({Q(0.11, 0.93), Q(0.13, 0.5), Q(0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + poly({Q(-0.26, 0.0), Q(-0.04, 0.0), Q(-0.05, 0.14), Q(-0.23, 0.14)}) + poly({Q(0.04, 0.0), Q(0.25, 0.0), Q(0.23, 0.14), Q(0.05, 0.14)})
  + poly({Q(-0.19, 0.88), Q(0.19, 0.88), Q(0.2, 1.06), Q(-0.2, 1.06)}, true)
  + poly({Q(-0.17, 1.02), Q(0.17, 1.02), Q(0.23, 1.32), Q(0.3, 1.5), Q(0.27, 1.58), Q(0.1, 1.61), Q(-0.1, 1.61), Q(-0.27, 1.58), Q(-0.3, 1.5), Q(-0.23, 1.32)}, true)
  + poly({Q(-0.05, 1.55), Q(0.05, 1.55), Q(0.05, 1.67), Q(-0.05, 1.67)})
  + ellipse(fx - 0.02 * k, fy - 1.77 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3, 1.5), Q(-0.38, 1.7), Q(-0.33, 1.9)}, {0.12 * k, 0.1 * k, 0.085 * k})
  + ribbon({Q(0.3, 1.5), Q(0.3, 1.72), Q(0.2, 1.92)}, {0.12 * k, 0.1 * k, 0.085 * k})
FIG = fig
work(fig, {hand="body", tool="filbert 4", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.45}, medium=0.06}, coverage=7, fill=true, clip=fig, angle=math.pi/2, load=1})
-- the floor pool's hard edge lost
blend(FLOORM * (ellipse(760, 1240, 280, 64) - ellipse(760, 1240, 235, 44)) - fig, {angle=0})
blend(FLOORM * (ellipse(760, 1240, 290, 70) - ellipse(760, 1240, 250, 50)) - fig, {angle=math.pi/2})
FK, FX, FYY = k, fx, fy

--@ chunk 7
-- on set paint: the key restated solid; lantern light on the docent and on the Commando's top planes (helm, pauldrons, raised
-- arms, hands on the rails); the floor pool's rim eaten from outside with a feathered dark stipple
print(wait(6*24*60))
local hot = pile{{"lead white",1.8},{"yellow ochre",0.6},{"cadmium yellow",0.25}, medium=0.05}
local warm = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, swell={0.7, 1.1, 0.7}, ramps={0.08, 0.25}, clip=clipm})
end
local keyP = pile{{"yellow ochre",1},{"Mars orange",0.5},{"burnt sienna",0.5},{"lead white",0.3}, medium=0.06}
local shaft = ribbon({{600, 345}, {662, 406}}, 6)
work(shaft, {hand="detail", pile=keyP, coverage=7, fill=true, clip=shaft, load=1})
local bar = ribbon({{638, 422}, {682, 382}}, 8)
work(bar, {hand="detail", pile=keyP, coverage=7, fill=true, clip=bar, load=1})
st({{602, 341}, {660, 400}}, hot, 1.6, {0.8, 0.5})
st({{640, 417}, {680, 378}}, hot, 1.8, {0.8, 0.6})
local bone = pile{{"lead white",1.8},{"yellow ochre",0.45}, medium=0.05}
st({{650, 396}, {662, 403}}, bone, 5.5, {0.9, 0.7})
st({{663, 412}, {673, 418}}, bone, 5.5, {0.9, 0.7})
local Dg = (DROBE + DHEAD + DARMS):grow(1.5)
st({{696, 332}, {714, 326}, {732, 336}}, hot, 3.6, {0.9, 0.8}, Dg)
st({{712, 386}, {738, 376}, {762, 396}}, warm, 3.6, {0.8, 0.9}, Dg)
st({{764, 412}, {786, 540}, {795, 640}}, warm, 2.8, {0.9, 0.2}, Dg)
st({{690, 352}, {688, 372}}, hot, 2, {0.8, 0.6}, Dg)
-- the Commando: lit from above
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local Fg = FIG:grow(1.5)
st({Q(-0.12, 1.86), Q(-0.02, 1.9), Q(0.08, 1.86)}, hot, 3.4, {0.8, 0.8}, Fg)
st({Q(-0.4, 1.6), Q(-0.3, 1.63), Q(-0.18, 1.62)}, warm, 3.2, {0.7, 0.8}, Fg)
st({Q(0.18, 1.62), Q(0.3, 1.63), Q(0.4, 1.6)}, warm, 3.2, {0.8, 0.7}, Fg)
st({Q(-0.32, 1.92), Q(-0.4, 1.72), Q(-0.36, 1.55)}, warm, 2.6, {0.9, 0.2}, Fg)
st({Q(0.22, 1.94), Q(0.32, 1.74), Q(0.34, 1.56)}, warm, 2.6, {0.9, 0.2}, Fg)
st({Q(-0.3, 1.95), Q(-0.24, 1.98)}, hot, 3, {0.8, 0.8}, Fg)
st({Q(0.18, 1.96), Q(0.24, 1.98)}, hot, 3, {0.8, 0.8}, Fg)
-- floor pool rim
local dk = pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}
local ring = (ellipse(760, 1240, 300, 72) - ellipse(760, 1240, 190, 30)) * FLOORM - FIG
stipple(ring, {pile=dk, width=1.8, coverage=function(x, y) local d = math.sqrt(((x - 760) / 270)^2 + ((y - 1240) / 60)^2); return clamp((d - 0.72) / 0.4, 0, 1) * 4 end, feather=0.9, cluster=0.25, dips={30, 0.8, 0}})

--@ chunk 8
-- the key's shadow side, so it stands off the gold face
print(wait(3*24*60))
local dk = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local function st(pts, w) local b = brush{kind="round", width=w, point=0.3, stiffness=0.6}; b:load(dk, 0.95); b:stroke(pts, {pressure={0.8, 0.8}}) end
st({{604, 352}, {664, 412}}, 2.2)
st({{644, 427}, {686, 388}}, 2.4)
