-- easel session "mirror": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=9127, ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=80, apply="knife", texture=0.3},{pile={{"burnt sienna",2},{"ultramarine blue",1},{"yellow ochre",1},{"lead white",1}}, um=30, apply="brush"}}}

--@ chunk 2
VPX, VPY = 500, 300
function P(sc, X, Y) return {VPX + X * sc, VPY + Y * sc} end
-- the arch of the mirror join
local ap = {{300, 471}, {300, 205}}
for i = 1, 15 do
  local a = math.pi + i * math.pi / 16
  ap[#ap + 1] = {500 + 200 * math.cos(a), 205 + 82 * math.sin(a)}
end
ap[#ap + 1] = {700, 205}; ap[#ap + 1] = {700, 471}
JOIN = poly(ap)
local K = 4
FLOOR = poly({P(1, -260, 170), P(1, 260, 170), P(K, 260, 170), P(K, -260, 170)})
CEIL = poly({P(1, -260, -200), P(1, 260, -200), P(K, 260, -200), P(K, -260, -200)})
LWALL = poly({P(1, -260, -200), P(1, -260, 170), P(K, -260, 170), P(K, -260, -200)})
RWALL = poly({P(1, 260, -200), P(1, 260, 170), P(K, 260, 170), P(K, 260, -200)})
BACK = rect(240, 100, 520, 370) - JOIN
local h = 0.5
RFLOOR = poly({P(1, -260, 170), P(1, 260, 170), P(h, 260, 170), P(h, -260, 170)}) * JOIN
RCEIL = poly({P(1, -260, -200), P(1, 260, -200), P(h, 260, -200), P(h, -260, -200)}) * JOIN
RLWALL = poly({P(1, -260, -200), P(1, -260, 170), P(h, -260, 170), P(h, -260, -200)}) * JOIN
RRWALL = poly({P(1, 260, -200), P(1, 260, 170), P(h, 260, 170), P(h, 260, -200)}) * JOIN
RFAR = rect(370, 200, 260, 185) * JOIN
local dp = {{455, 386}, {455, 300}}
for i = 1, 9 do local a = math.pi + i * math.pi / 10 dp[#dp + 1] = {500 + 45 * math.cos(a), 300 + 32 * math.sin(a)} end
dp[#dp + 1] = {545, 300}; dp[#dp + 1] = {545, 386}
DOOR = poly(dp)
RAD = function(x, y) return math.atan(y - VPY, x - VPX) end
local wallP = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.45},{"ultramarine blue",0.3}}
local ceilP = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.5}}
local backP = pile{{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.35},{"yellow ochre",0.5},{"bone black",0.15}}
local floorP = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.6},{"raw sienna",0.5},{"bone black",0.1}}
work(CEIL, {hand="body", pile=ceilP, angle=RAD, coverage=3, fill=true, clip=true})
work(LWALL, {hand="body", pile=wallP, angle=RAD, coverage=3, fill=true, clip=true})
work(RWALL, {hand="body", pile=wallP, angle=RAD, coverage=3, fill=true, clip=true})
work(BACK, {hand="body", pile=backP, angle=0, coverage=3, fill=true, clip=true})
work(FLOOR, {hand="body", pile=floorP, angle=RAD, coverage=3, fill=true, clip=true})

--@ chunk 3
wallP = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.45},{"ultramarine blue",0.35}}
ceilP = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.5}}
local fl1 = pile{{"burnt sienna",1},{"yellow ochre",0.8},{"raw sienna",0.5},{"bone black",0.3},{"lead white",0.25}}
local fl2 = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.6},{"raw sienna",0.5},{"bone black",0.1}}
local farP = pile{{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.5},{"yellow ochre",0.6},{"bone black",0.1}}
local doorP = pile{{"lead white",3},{"cadmium yellow",0.5},{"Indian yellow",0.3},{"zinc white",0.5}}
work(RCEIL, {hand="body", pile=ceilP, angle=RAD, coverage=3, fill=true, clip=true})
work(RLWALL, {hand="body", pile=wallP, angle=RAD, coverage=3, fill=true, clip=true})
work(RRWALL, {hand="body", pile=wallP, angle=RAD, coverage=3, fill=true, clip=true})
local mid = above(function(x) return 425 end)
work(RFLOOR - mid, {hand="body", pile=fl1, angle=RAD, coverage=3, fill=true, clip=true})
work(RFLOOR * mid, {hand="body", pile=fl2, angle=RAD, coverage=3, fill=true, clip=true})
work(RFAR - DOOR, {hand="body", pile=farP, angle=0, coverage=3, fill=true, clip=true})
work(DOOR, {hand="detail", pile=doorP, coverage=4, fill=true, clip=true})

--@ chunk 4
BONE = pile{{"lead white",3},{"yellow ochre",0.5},{"raw sienna",0.2},{"ultramarine ash",0.3}}
BONED = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.5},{"ultramarine ash",0.4},{"burnt sienna",0.15}}
local b = brush{kind="round", width=3, point=0.5, stiffness=0.5}
local xs = {-260, -195, -128, -64, 2, 66, 131, 197, 260}
for _, X in ipairs(xs) do
  -- real floor: from the bottom edge up to the join
  b:load(BONED, 0.8)
  b:stroke({P(2.0, X, 170), P(1.0, X, 170)}, {pressure={0.75, 0.35}, clip=FLOOR})
  b:load(BONED, 0.6)
  b:stroke({P(3.9, X, 170), P(2.0, X, 170)}, {pressure={1, 0.75}, clip=FLOOR})
  -- and on, without a break, through it
  b:load(BONED, 0.6)
  b:stroke({P(1.0, X, 170), P(0.5, X, 170)}, {pressure={0.35, 0.18}, clip=RFLOOR})
end
local real = {1.15, 1.35, 1.65, 2.1, 2.9}
local refl = {0.885, 0.79, 0.717, 0.656, 0.604}
for i, s in ipairs(real) do
  b:load(BONED, 0.7)
  b:stroke({P(s, -260, 170), P(s, 260, 170)}, {pressure={0.3 + 0.12 * i, 0.3 + 0.12 * i}, clip=FLOOR})
end
for i, s in ipairs(refl) do
  b:load(BONED, 0.6)
  b:stroke({P(s, -260, 170), P(s, 260, 170)}, {pressure={0.28 - 0.025 * i, 0.28 - 0.025 * i}, clip=RFLOOR})
end

--@ chunk 5
LITB = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.5},{"raw sienna",0.4}}
MIDB = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.35},{"yellow ochre",0.3}}
DRKB = pile{{"bone black",1},{"burnt sienna",0.9},{"ultramarine blue",0.4}}
PAD = pile{{"lead white",2.5},{"yellow ochre",0.5},{"raw sienna",0.3},{"ultramarine ash",0.35}}
PADD = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.5},{"ultramarine ash",0.5},{"bone black",0.1}}
function couch(sn, sf, X0, X1, front, side, top, pad)
  local Yt, Yf = 118, 170
  local Ym = Yt + 0.45 * (Yf - Yt)
  local function q(pts) return poly(pts) end
  local topM = q({P(sn, X0, Yt), P(sn, X1, Yt), P(sf, X1, Yt), P(sf, X0, Yt)})
  local frontM = q({P(sn, X0, Yt), P(sn, X1, Yt), P(sn, X1 * 0.97 + X0 * 0.03, Yf), P(sn, X0, Yf)})
  local sideM = q({P(sn, X1, Yt), P(sf, X1, Yt), P(sf, X1 * 0.97 + X0 * 0.03, Yf), P(sn, X1 * 0.97 + X0 * 0.03, Yf)})
  work(sideM, {hand="detail", pile=side, coverage=4, fill=true, clip=true})
  work(frontM, {hand="detail", pile=front, coverage=4, fill=true, clip=true})
  work(topM, {hand="detail", pile=top, coverage=4, fill=true, clip=true})
  -- the bone pad, inset on the top
  local dx = (X1 - X0)
  local padM = q({P(sn - (sn - sf) * 0.08, X0 + dx * 0.16, Yt - 4), P(sn - (sn - sf) * 0.08, X1 - dx * 0.04, Yt - 4), P(sf + (sn - sf) * 0.08, X1 - dx * 0.04, Yt - 4), P(sf + (sn - sf) * 0.08, X0 + dx * 0.16, Yt - 4)})
  work(padM, {hand="detail", pile=pad, coverage=4, fill=true, clip=true})
  -- the headrest against the wall: a curved bone lip rising
  local hr = q({P(sn - (sn - sf) * 0.1, X0 + 2, Yt), P(sn - (sn - sf) * 0.1, X0 + dx * 0.15, Yt - 2), P(sn - (sn - sf) * 0.25, X0 + dx * 0.13, 82), P(sf + (sn - sf) * 0.2, X0 + dx * 0.1, 78), P(sf + (sn - sf) * 0.1, X0 + 2, Yt)})
  work(hr, {hand="detail", pile=pad, coverage=4, fill=true, clip=true})
  return topM + frontM + sideM
end
C_RL = couch(2.2, 1.65, -260, -105, LITB, MIDB, MIDB, PAD)
C_RR = couch(1.55, 1.25, 260, 118, LITB, MIDB, MIDB, PAD)

--@ chunk 6
print(wait(24 * 60))
FRONTB = pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.5},{"ultramarine blue",0.25},{"yellow ochre",0.2}}
function cgeom(sn, sf, X0, X1)
  local Yt, Yf = 118, 170
  local g = {}
  local Xb = X1 * 0.97 + X0 * 0.03
  g.top = poly({P(sn, X0, Yt), P(sn, X1, Yt), P(sf, X1, Yt), P(sf, X0, Yt)})
  g.front = poly({P(sn, X0, Yt), P(sn, X1, Yt), P(sn, Xb, Yf), P(sn, X0, Yf)})
  g.side = poly({P(sn, X1, Yt), P(sf, X1, Yt), P(sf, Xb, Yf), P(sn, Xb, Yf)})
  local dx = X1 - X0
  g.pad = poly({P(sn - (sn - sf) * 0.08, X0 + dx * 0.18, Yt - 4), P(sn - (sn - sf) * 0.08, X1 - dx * 0.05, Yt - 4), P(sf + (sn - sf) * 0.08, X1 - dx * 0.05, Yt - 4), P(sf + (sn - sf) * 0.08, X0 + dx * 0.18, Yt - 4)})
  g.head = poly({P(sn - (sn - sf) * 0.08, X0, Yt), P(sn - (sn - sf) * 0.08, X0 + dx * 0.16, Yt), P(sn - (sn - sf) * 0.14, X0 + dx * 0.14, 92), P(sf + (sn - sf) * 0.14, X0 + dx * 0.14, 92), P(sf + (sn - sf) * 0.08, X0 + dx * 0.16, Yt), P(sf + (sn - sf) * 0.08, X0, Yt)}, true)
  return g
end
function cbody(g, front, side, top)
  work(g.side, {hand="detail", pile=side, coverage=4, fill=true, clip=true})
  work(g.front, {hand="detail", pile=front, coverage=4, fill=true, clip=true})
  work(g.top, {hand="detail", pile=top, coverage=4, fill=true, clip=true})
end
G_RL = cgeom(2.2, 1.65, -260, -105)
G_RR = cgeom(1.55, 1.25, 260, 118)
cbody(G_RL, FRONTB, DRKB, MIDB)
cbody(G_RR, FRONTB, DRKB, MIDB)

--@ chunk 7
print(wait(2 * 24 * 60))
work(G_RR.front, {hand="detail", pile=FRONTB, coverage=4, fill=true, clip=true})
work(G_RR.side, {hand="detail", pile=DRKB, coverage=4, fill=true, clip=true})
for _, g in ipairs({G_RL, G_RR}) do
  work(g.pad, {hand="detail", pile=PAD, coverage=4, fill=true, clip=true})
  work(g.head, {hand="detail", pile=PAD, coverage=4, fill=true, clip=true})
end

--@ chunk 8
G_ML = cgeom(0.728, 0.648, -260, -106)
G_MR = cgeom(0.81, 0.735, 260, 116)
local SH = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.45},{"raw sienna",0.2}}
cbody(G_ML, SH, DRKB, MIDB)
cbody(G_MR, SH, DRKB, MIDB)
print(wait(2 * 24 * 60))
local PADL = pile{{"lead white",2.5},{"yellow ochre",0.6},{"raw sienna",0.2},{"ultramarine ash",0.2}}
for _, g in ipairs({G_ML, G_MR}) do
  work(g.pad, {hand="detail", pile=PADL, coverage=4, fill=true, clip=true})
  work(g.head, {hand="detail", pile=PADL, coverage=4, fill=true, clip=true})
end

--@ chunk 9
GUN = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"burnt sienna",0.4},{"lead white",0.25}}
function frame(x, y, u, armL, armR)
  local L = function(dx, dy) return {x + dx * u, y + dy * u} end
  local f = body_of{spine={L(0, -25.2), L(0, -22.5), L(0, -19), L(0.1, -14), L(0, -10)}, widths={3.4 * u, 2.4 * u, 8.6 * u, 6.2 * u, 5.6 * u}, limbs={
    {L(-1.5, -10), L(-1.8, -5), L(-2.0, 0), widths={2.5 * u, 2.2 * u, 2.4 * u}},
    {L(1.5, -10), L(1.8, -5), L(2.1, 0), widths={2.5 * u, 2.2 * u, 2.4 * u}},
    {L(-4.2, -19), L(armL[1], armL[2]), L(armL[3], armL[4]), widths={2.2 * u, 1.9 * u, 1.8 * u}},
    {L(4.2, -19), L(armR[1], armR[2]), L(armR[3], armR[4]), widths={2.2 * u, 1.9 * u, 1.8 * u}},
  }, char="firm", amount=0.12}
  return f:mask()
end
-- the Commando's frame, from behind, arms at his sides
FIG1 = frame(430, 540, 6.3, {-4.9, -13.5, -5.0, -8.5}, {4.9, -13.5, 5.1, -8.5})
work(FIG1, {hand="detail", pile=GUN, coverage=4, fill=true, clip=true})
-- his reflection, facing us, backlit by the doorway: its right hand raised, palm to the join
FIG2 = frame(461, 432, 3.5, {-5.6, -19.5, -6.2, -25.5}, {4.8, -13.5, 5.0, -8.6})
work(FIG2, {hand="detail", pile=pile{{"bone black",1.4},{"ultramarine blue",0.6},{"burnt sienna",0.5}}, coverage=4, fill=true, clip=true})

--@ chunk 10
-- the lintel over the join, where the warning is carved
LINTEL = rect(240, 100, 520, 40)
work(LINTEL, {hand="body", pile=pile{{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.3},{"yellow ochre",0.4},{"bone black",0.25}}, angle=0, coverage=3.5, fill=true, clip=true})
-- the real frame's shadow runs away from us toward the join; the reflection's runs toward us; they meet at the plane
local sp = pile{{"burnt sienna",1},{"bone black",0.5},{"ultramarine blue",0.4},{"raw sienna",0.4}}
local s1 = poly({{418, 540}, {444, 540}, {470, 471}, {452, 471}}, true) * FLOOR
work(s1, {hand="detail", pile=sp, coverage=2.5, fill=true, clip=true})
local s2 = poly({{455, 432}, {468, 432}, {462, 470}, {449, 470}}, true) * RFLOOR
work(s2, {hand="detail", pile=sp, coverage=2.5, fill=true, clip=true})
-- the patient on the reflected couch, which in the room is empty
local Y = 107
local function Q(X, dy) return P(0.688, X, Y + (dy or 0)) end
PAT = body_of{spine={Q(-236, -6), Q(-222, -3), Q(-190, -4), Q(-160, -3), Q(-128, -2), Q(-116, -1)}, widths={9, 6, 11, 10, 8, 5}, char="soft", amount=0.25}
work(PAT:mask(), {hand="detail", pile=pile{{"lead white",2.6},{"yellow ochre",0.4},{"ultramarine ash",0.45},{"zinc white",0.4}}, coverage=4, fill=true, clip=true})

--@ chunk 11
print(wait(2 * 24 * 60))
work(FIG1 * rect(395, 470, 70, 80), {hand="detail", pile=GUN, coverage=4, fill=true, clip=true})
-- in the reflection only: a Testator nurse standing by the far couch, tall, thin, a bone face-disc
local x, y, u = 572, 432, 4.1
local L = function(dx, dy) return {x + dx * u, y + dy * u} end
local T = body_of{spine={L(0, -24), L(0.2, -20), L(0, -13), L(-0.2, -6), L(0, 0)}, widths={1.6 * u, 3.6 * u, 2.6 * u, 3.4 * u, 4.2 * u}, limbs={
  {L(-1.6, -20), L(-2.6, -13), L(-2.2, -6.5), widths={1.1 * u, 0.9 * u, 0.8 * u}},
  {L(1.6, -20), L(3.6, -15), L(5.6, -12.5), widths={1.1 * u, 0.9 * u, 0.8 * u}},
}, char="firm", amount=0.12}
TESM = T:mask()
work(TESM, {hand="detail", pile=pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.4},{"ultramarine blue",0.2}}, coverage=4, fill=true, clip=true})

--@ chunk 12
print(wait(24 * 60))
work(TESM, {hand="detail", pile=pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.3},{"ultramarine blue",0.3}}, coverage=4, fill=true, clip=true})
-- the carving on the lintel: room-glyph | bar | its reflected inset, outlined in bone
local BL = pile{{"lead white",3},{"yellow ochre",0.45},{"ultramarine ash",0.3}}
local DK = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.3}}
local b = brush{kind="round", width=1.6, point=0.5, stiffness=0.5}
local function line(pts, p, pr) b:load(p, 0.75) b:stroke(pts, {pressure={pr, pr}, ramps={0.05, 0.05}}) end
local function poly_line(pts, p, pr) for i = 1, #pts do line({pts[i], pts[i % #pts + 1]}, p, pr) end end
-- the ward as a glyph: a long room with an arched end and two notched doors
local g = {{430, 108}, {482, 108}, {490, 113}, {490, 127}, {430, 127}}
poly_line(g, DK, 0.7)
line({{447, 108}, {447, 104.5}}, DK, 0.5)
line({{438, 127}, {438, 130.5}}, DK, 0.5); line({{441, 127}, {441, 130.5}}, DK, 0.5)
-- its upright inset (the ward as you know it)
poly_line({{442, 113.5}, {470, 113.5}, {474, 116}, {474, 122}, {442, 122}}, DK, 0.45)
-- the bar
line({{500, 104}, {500, 132}}, BL, 0.85)
-- across the bar: the same room, reflected, at 0.618, outlined in bone
local r = {{570, 108}, {518, 108}, {510, 113}, {510, 127}, {570, 127}}
poly_line(r, DK, 0.7)
poly_line({{558, 113.5}, {529, 113.5}, {525, 116}, {525, 122}, {558, 122}}, BL, 0.6)
line({{553, 108}, {553, 104.5}}, DK, 0.5)
-- the bridge: an arc that leaves the glyph and comes back to it across the bar
b:load(BL, 0.7)
b:stroke({{460, 107}, {480, 101.5}, {500, 100.5}, {520, 101.5}, {541, 107}}, {pressure={0.45, 0.45}})

--@ chunk 13
print(wait(5 * 24 * 60), drying(461, 400), drying(572, 400), drying(430, 420))
local RIM = pile{{"lead white",2.5},{"cadmium yellow",0.35},{"Indian yellow",0.15},{"zinc white",0.5}}
-- backlit edges of what stands in the reflection: thin, broken toward the feet
local function rimpass(m, w, top)
  local band = (m - m:shrink(w)) * above(function(x) return top end)
  work(band, {hand="detail", pile=RIM, coverage=2.5, fill=true, clip=true})
end
rimpass(FIG2, 0.9, 420)
rimpass(TESM, 0.9, 420)
-- the Testator's face: a bone disc with a ring of petals
local fx, fy = 572, 432 - 24 * 4.1
local b = brush{kind="round", width=1.3, point=0.6}
local BN = pile{{"lead white",3},{"yellow ochre",0.4},{"ultramarine ash",0.25}}
for i = 0, 12 do
  local a = i * 2.39996
  local rr = 4.6 + 0.4 * math.sin(i * 1.7)
  b:load(BN, 0.6)
  b:touch(fx + rr * math.cos(a), fy + rr * math.sin(a) * 0.95, {pressure=0.45})
end
work(ellipse(fx, fy, 2.6, 2.8), {hand="detail", pile=BN, coverage=4, fill=true, clip=true})
b:load(pile{{"bone black",1},{"ultramarine blue",0.5}}, 0.6)
b:touch(fx + 0.2, fy, {pressure=0.35})
-- the real frame: its back takes the light from behind us
local LITG = pile{{"bone black",0.7},{"ultramarine ash",0.8},{"lead white",0.8},{"burnt sienna",0.3},{"yellow ochre",0.2}}
local back = FIG1 * (FIG1:shrink(4)) * above(function(x) return 478 end)
work(back * mask(function(x, y) return (x < 445) and 1 or 0 end), {hand="detail", pile=LITG, coverage=2, fill=true, clip=true})
local warmrim = (FIG1 - FIG1:shrink(1.2)) * above(function(x) return 430 end)
work(warmrim, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.6},{"burnt sienna",0.2}}, coverage=2, fill=true, clip=true})

--@ chunk 14
print(wait(3 * 24 * 60), drying(430, 420), drying(572, 400))
local GUND = pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}
work(FIG1, {hand="detail", pile=GUND, coverage=4.5, fill=true, clip=true})
local TD = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.3},{"ultramarine blue",0.3}}
local tr = (TESM - TESM:shrink(1.3)) * mask(function(x, y) return (x > 573 or y > 395) and 1 or 0 end)
work(tr, {hand="detail", pile=TD, coverage=4, fill=true, clip=true})

--@ chunk 15
print(wait(4 * 24 * 60), drying(430, 440))
local MG = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.3},{"burnt sienna",0.3}}
local u, x, y = 6.3, 430, 540
-- pauldrons: two curved plates over the shoulders
local pl = ellipse(x - 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u) * FIG1:grow(4)
local pr = ellipse(x + 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u) * FIG1:grow(4)
work(pl + pr, {hand="detail", pile=MG, coverage=4, fill=true, clip=true})
-- a spine housing down the back
local sp = ribbon({{x, y - 21.5 * u}, {x + 0.1 * u, y - 15 * u}, {x, y - 11 * u}}, 1.6 * u)
work(sp, {hand="detail", pile=MG, coverage=3, fill=true, clip=true})
-- light from behind us catches the tops: helmet crown, plate edges (broken, not an outline)
local lit = pile{{"lead white",1.6},{"yellow ochre",0.5},{"burnt sienna",0.2},{"ultramarine ash",0.3}}
local b = brush{kind="round", width=2.2, point=0.5}
local function s(pts, pr) b:load(lit, 0.55) b:stroke(pts, {pressure={pr, pr * 0.4}, ramps={0.2, 0.5}}) end
s({{x - 8, y - 25.4 * u + 2}, {x - 2, y - 26.2 * u + 2}, {x + 6, y - 25.6 * u + 2}}, 0.6)
s({{x - 6.8 * u, y - 19.4 * u}, {x - 5.2 * u, y - 20.6 * u}, {x - 3.2 * u, y - 20.8 * u}}, 0.55)
s({{x + 3.0 * u, y - 20.9 * u}, {x + 5.0 * u, y - 20.7 * u}, {x + 6.6 * u, y - 19.6 * u}}, 0.5)
s({{x - 0.6, y - 21 * u}, {x - 0.2, y - 16 * u}}, 0.35)
-- a small bone cross on the back plate: a Church soldier
local cb = brush{kind="round", width=1.8, point=0.3}
local cp = pile{{"lead white",2.5},{"yellow ochre",0.4},{"raw sienna",0.2}}
cb:load(cp, 0.7) cb:stroke({{x + 2.6 * u, y - 18.2 * u}, {x + 2.6 * u, y - 14.6 * u}}, {pressure={0.6, 0.6}})
cb:load(cp, 0.7) cb:stroke({{x + 1.6 * u, y - 17.2 * u}, {x + 3.6 * u, y - 17.2 * u}}, {pressure={0.6, 0.6}})

--@ chunk 16
local RIBD = pile{{"bone black",0.8},{"burnt sienna",1},{"raw sienna",0.3},{"ultramarine blue",0.3}}
local RIBL = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.7},{"raw sienna",0.3}}
-- ribs on the side walls and beams across the ceiling, at uneven depths
local function rib(sc, w, wallL, wallR, ceil, lit)
  local function band(X, Y0, Y1, dz) return poly({P(sc, X, Y0), P(sc, X, Y1), P(sc * (1 - dz), X, Y1), P(sc * (1 - dz), X, Y0)}) end
  local dz = w
  local mL = band(-260, -200, 170, dz) * wallL
  local mR = band(260, -200, 170, dz) * wallR
  local mC = poly({P(sc, -260, -200), P(sc, 260, -200), P(sc * (1 - dz), 260, -200), P(sc * (1 - dz), -260, -200)}) * ceil
  work(mL + mR + mC, {hand="detail", pile=RIBD, coverage=4, fill=true, clip=true})
  local b = brush{kind="round", width=math.max(1, 1.6 * sc), point=0.4}
  b:load(lit, 0.7) b:stroke({P(sc, -260, -195), P(sc, -260, 165)}, {pressure={0.5, 0.6}, clip=wallL})
  b:load(lit, 0.7) b:stroke({P(sc, 260, -195), P(sc, 260, 165)}, {pressure={0.5, 0.6}, clip=wallR})
end
rib(1.32, 0.05, LWALL, RWALL, CEIL, RIBL)
rib(1.86, 0.045, LWALL, RWALL, CEIL, RIBL)
rib(2.75, 0.04, LWALL, RWALL, CEIL, RIBL)
rib(0.79, 0.05, RLWALL, RRWALL, RCEIL, RIBL)
rib(0.685, 0.045, RLWALL, RRWALL, RCEIL, RIBL)
rib(0.583, 0.04, RLWALL, RRWALL, RCEIL, RIBL)
-- the join: a thin bone line round the arch, and across the floor where the room meets itself
local BL = pile{{"lead white",3},{"yellow ochre",0.4},{"ultramarine ash",0.3},{"zinc white",0.3}}
local o = (JOIN:grow(2.2) - JOIN)
work(o, {hand="detail", pile=BL, coverage=3, fill=true, clip=true})
local b = brush{kind="round", width=1.6, point=0.3}
b:load(BL, 0.7) b:stroke({{301, 471}, {699, 471}}, {pressure={0.5, 0.5}})

--@ chunk 17
print(wait(3 * 24 * 60))
local SH = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.45},{"raw sienna",0.2}}
local PADL = pile{{"lead white",2.5},{"yellow ochre",0.6},{"raw sienna",0.2},{"ultramarine ash",0.2}}
local function fix(g, strip, front, pad)
  for _, part in ipairs({{g.side, DRKB}, {g.front, front}, {g.top, MIDB}}) do
    local m = part[1] * strip
    if m:area() > 0 then work(m, {hand="detail", pile=part[2], coverage=4, fill=true, clip=true}) end
  end
end
local function padfix(g, strip, pad)
  for _, m in ipairs({g.pad * strip, g.head * strip}) do
    if m:area() > 0 then work(m, {hand="detail", pile=pad, coverage=4, fill=true, clip=true}) end
  end
end
local sL = rect(150, 0, 32, 667) + rect(8, 0, 40, 667)
local sR = rect(818, 0, 32, 667)
local sML = rect(316, 0, 20, 667)
local sMR = rect(664, 0, 20, 667)
fix(G_RL, sL, FRONTB); fix(G_RR, sR, FRONTB); fix(G_ML, sML, SH); fix(G_MR, sMR, SH)
print(wait(2 * 24 * 60))
padfix(G_RL, sL, PAD); padfix(G_RR, sR, PAD); padfix(G_ML, sML, PADL); padfix(G_MR, sMR, PADL)

--@ chunk 18
local SH = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.45},{"raw sienna",0.2}}
local PADL = pile{{"lead white",2.5},{"yellow ochre",0.6},{"raw sienna",0.2},{"ultramarine ash",0.2}}
local s1, s2 = rect(340, 0, 18, 667), rect(642, 0, 18, 667)
for _, gs in ipairs({{G_ML, s1}, {G_MR, s2}}) do
  local g, s = gs[1], gs[2]
  for _, part in ipairs({{g.side, DRKB}, {g.front, SH}, {g.top, MIDB}}) do
    local m = part[1] * s - PAT:mask():grow(1)
    if m:area() > 0 then work(m, {hand="detail", pile=part[2], coverage=4, fill=true, clip=true}) end
  end
end
print(wait(2 * 24 * 60))
for _, gs in ipairs({{G_ML, s1}, {G_MR, s2}}) do
  for _, m in ipairs({gs[1].pad * gs[2] - PAT:mask(), gs[1].head * gs[2]}) do
    if m:area() > 0 then work(m, {hand="detail", pile=PADL, coverage=4, fill=true, clip=true}) end
  end
end
-- the patient: a second, firmer coat, lit from the doorway beyond
work(PAT:mask(), {hand="detail", pile=pile{{"lead white",2.6},{"yellow ochre",0.35},{"ultramarine ash",0.5},{"zinc white",0.4}}, coverage=4, fill=true, clip=true})

--@ chunk 19
-- warm air round the far doorway (the light that is, in the room, behind us)
local VEIL = pile{{"lead white",2},{"cadmium yellow",0.35},{"Mars orange",0.1},medium=0.4}
local m = (ellipse(500, 335, 95, 85):blur(25) * JOIN) - FIG2:grow(1) - TESM:grow(1)
work(m, {hand="scumble", tool={kind="filbert", width=5}, pile=VEIL, pressure={0.1, 0.25}, coverage=1.2, angle=RAD, clip=true,
  load_at=function(x, y) local d = math.sqrt((x - 500)^2 + (y - 335)^2) return clamp(0.3 - d / 400, 0.03, 0.28) end})
blend(m, {angle=RAD, tool={kind="badger", width=12}})
-- small wayfinding plaques beside the couches: the ward's glyph, carved small
local BL = pile{{"lead white",3},{"yellow ochre",0.45},{"ultramarine ash",0.3}}
local b = brush{kind="round", width=1.4, point=0.4}
local function plaque(pts, pr)
  for i = 1, #pts do b:load(BL, 0.6) b:stroke({pts[i], pts[i % #pts + 1]}, {pressure={pr, pr}, ramps={0.05, 0.05}}) end
end
plaque({{60, 330}, {98, 318}, {104, 322}, {104, 338}, {60, 349}}, 0.6)
plaque({{70, 333}, {92, 327}, {95, 329}, {95, 337}, {70, 343}}, 0.4)
plaque({{905, 345}, {878, 337}, {873, 340}, {873, 352}, {905, 361}}, 0.55)
plaque({{897, 347}, {883, 343}, {881, 345}, {881, 351}, {897, 355}}, 0.38)

--@ chunk 20
print(wait(3*24*60))
work(FIG1 * above(function(x) return 470 end), {hand="detail", pile=pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}, coverage=5, fill=true, clip=true})
local veil2 = (ellipse(500, 335, 95, 85):blur(25) * JOIN) - FIG1:grow(2) - FIG2:grow(1) - TESM:grow(1)
blend(veil2, {angle=RAD, tool={kind="badger", width=8}})

--@ chunk 21
print(wait(4 * 24 * 60), drying(430, 400))
local MG = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.3},{"burnt sienna",0.3}}
local u, x, y = 6.3, 430, 540
-- pauldrons: two curved plates over the shoulders
local pl = ellipse(x - 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u) * FIG1:grow(4)
local pr = ellipse(x + 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u) * FIG1:grow(4)
work(pl + pr, {hand="detail", pile=MG, coverage=4, fill=true, clip=true})
-- a spine housing down the back
local sp = ribbon({{x, y - 21.5 * u}, {x + 0.1 * u, y - 15 * u}, {x, y - 11 * u}}, 1.6 * u)
work(sp, {hand="detail", pile=MG, coverage=3, fill=true, clip=true})
-- light from behind us catches the tops: helmet crown, plate edges (broken, not an outline)
local lit = pile{{"lead white",1.6},{"yellow ochre",0.5},{"burnt sienna",0.2},{"ultramarine ash",0.3}}
local b = brush{kind="round", width=2.2, point=0.5}
local function s(pts, pr) b:load(lit, 0.55) b:stroke(pts, {pressure={pr, pr * 0.4}, ramps={0.2, 0.5}}) end
s({{x - 8, y - 25.4 * u + 2}, {x - 2, y - 26.2 * u + 2}, {x + 6, y - 25.6 * u + 2}}, 0.6)
s({{x - 6.8 * u, y - 19.4 * u}, {x - 5.2 * u, y - 20.6 * u}, {x - 3.2 * u, y - 20.8 * u}}, 0.55)
s({{x + 3.0 * u, y - 20.9 * u}, {x + 5.0 * u, y - 20.7 * u}, {x + 6.6 * u, y - 19.6 * u}}, 0.5)
s({{x - 0.6, y - 21 * u}, {x - 0.2, y - 16 * u}}, 0.35)
-- a small bone cross on the back plate: a Church soldier
local cb = brush{kind="round", width=1.8, point=0.3}
local cp = pile{{"lead white",2.5},{"yellow ochre",0.4},{"raw sienna",0.2}}
cb:load(cp, 0.7) cb:stroke({{x + 2.6 * u, y - 18.2 * u}, {x + 2.6 * u, y - 14.6 * u}}, {pressure={0.6, 0.6}})
cb:load(cp, 0.7) cb:stroke({{x + 1.6 * u, y - 17.2 * u}, {x + 3.6 * u, y - 17.2 * u}}, {pressure={0.6, 0.6}})

--@ chunk 22
print(wait(3 * 24 * 60), drying(430, 471))
local GUND = pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}
local MG = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.3},{"burnt sienna",0.3}}
local band = rect(380, 466, 100, 10)
local spine = ribbon({{430, 540 - 21.5 * 6.3}, {430.6, 540 - 15 * 6.3}, {430, 540 - 11 * 6.3}}, 1.6 * 6.3)
work(FIG1 * band - spine, {hand="detail", pile=GUND, coverage=5, fill=true, clip=true})
work(FIG1 * band * spine, {hand="detail", pile=MG, coverage=5, fill=true, clip=true})

--@ chunk 23
-- the room's address inlaid in the floor, in perspective, in front of the frame: glyph | bar | reflected inset
local BL = pile{{"lead white",2.6},{"yellow ochre",0.5},{"ultramarine ash",0.3},{"raw sienna",0.15}}
local b = brush{kind="round", width=3.2, point=0.3, stiffness=0.5}
local function F(X, s) return P(s, X, 170) end
local function seg(a, c, pr) b:load(BL, 0.75) b:stroke({a, c}, {pressure={pr, pr}, ramps={0.03, 0.03}, clip=FLOOR - FIG1:grow(2)}) end
local function room(Xa, Xb, sn, sf, pr)
  local pts = {F(Xa, sn), F(Xb, sn), F(Xb, sf), F(Xa, sf)}
  for i = 1, 4 do seg(pts[i], pts[i % 4 + 1], pr) end
end
-- the ward (long room) on the left of the bar, its upright inset
room(-150, -20, 3.4, 2.35, 0.75)
room(-120, -40, 3.0, 2.6, 0.5)
-- the bar
seg(F(2, 3.6), F(2, 2.25), 0.9)
-- reflected copy on the far side, golden smaller; its inset outlined in bone, flipped toward the bar
room(24, 104, 3.15, 2.5, 0.65)
room(34, 82, 2.95, 2.65, 0.45)
-- the bridge arc over the bar
local arc = {}
for i = 0, 10 do local t = i / 10 arc[#arc + 1] = F(-60 + 140 * t, 2.32 - 0.12 * math.sin(math.pi * t)) end
b:load(BL, 0.7) b:stroke(arc, {pressure={0.5, 0.5}, clip=FLOOR - FIG1:grow(2)})

--@ chunk 24
-- the room's address inlaid in the floor, in perspective, in front of the frame: glyph | bar | reflected inset
local BL = pile{{"lead white",2.6},{"yellow ochre",0.5},{"ultramarine ash",0.3},{"raw sienna",0.15}}
local b = brush{kind="round", width=3.2, point=0.3, stiffness=0.5}
local function F(X, s) return P(s, X, 170) end
local function seg(a, c, pr) b:load(BL, 0.75) b:stroke({a, c}, {pressure={pr, pr}, ramps={0.03, 0.03}, clip=FLOOR - FIG1:grow(2)}) end
local function room(Xa, Xb, sn, sf, pr)
  local pts = {F(Xa, sn), F(Xb, sn), F(Xb, sf), F(Xa, sf)}
  for i = 1, 4 do seg(pts[i], pts[i % 4 + 1], pr) end
end
-- the ward (long room) on the left of the bar, its upright inset
room(-150, -20, 2.02, 1.62, 0.75)
room(-122, -42, 1.9, 1.72, 0.5)
-- the bar
seg(F(2, 2.08), F(2, 1.57), 0.9)
-- reflected copy on the far side, golden smaller; its inset outlined in bone, flipped toward the bar
room(24, 104, 1.93, 1.68, 0.65)
room(34, 84, 1.86, 1.75, 0.45)
-- the bridge arc over the bar
local arc = {}
for i = 0, 10 do local t = i / 10 arc[#arc + 1] = F(-60 + 140 * t, 1.6 - 0.06 * math.sin(math.pi * t)) end
b:load(BL, 0.7) b:stroke(arc, {pressure={0.5, 0.5}, clip=FLOOR - FIG1:grow(2)})

--@ chunk 25
print(wait(4 * 24 * 60), drying(240, 640))
local r = rect(180, 555, 160, 112)
work(G_RL.side * r, {hand="detail", pile=DRKB, coverage=5, fill=true, clip=true})
work((G_RL.front - G_RL.side) * r, {hand="detail", pile=FRONTB, coverage=5, fill=true, clip=true})

--@ chunk 26
print(wait(2 * 24 * 60), drying(270, 300), drying(500, 120))
local GW = pile{{"burnt sienna",1},{"bone black",0.6},{"ultramarine blue",0.4},medium=0.75}
local m = BACK - JOIN:grow(3.5)
work(m, {hand="glaze", pile=GW, load=0.45, angle=math.pi / 2, coverage=1.6, clip=true})
blend(m, {angle=math.pi / 2, tool={kind="badger", width=14}})

--@ chunk 27
local m = BACK - JOIN:grow(3.5)
local couch = (G_RR.top + G_RR.pad + G_RR.head + G_RR.front + G_RR.side):grow(1)
work(m * couch, {hand="scumble", blender=true, tool={kind="filbert", width=3}, coverage=5, angle=0, clip=true})
work(m - couch, {hand="scumble", blender=true, tool={kind="filbert", width=6}, coverage=2.5, angle=math.pi / 2, clip=true})

--@ chunk 28
-- second pass, 1: a clean glow round the far door. Repaint the scribbled burst opaque in rings, blend within each surface only.
local G = ellipse(500, 335, 128, 112) * JOIN - FIG2:grow(1.5) - TESM:grow(1.5) - FIG1:grow(2)
local CO = nil
for _, g in ipairs({G_ML, G_MR}) do for _, k in ipairs({"top", "front", "side", "pad", "head"}) do CO = CO and (CO + g[k]) or g[k] end end
CO = CO + PAT:mask()
local E1, E2 = ellipse(500, 332, 66, 70), ellipse(500, 336, 100, 98)
local W = G * (RFAR - DOOR) - CO
local F = G * RFLOOR - CO
local L1 = pile{{"lead white",3},{"cadmium yellow",0.35},{"yellow ochre",0.2},{"zinc white",0.4}}
local L2 = pile{{"lead white",2},{"yellow ochre",0.7},{"cadmium yellow",0.15},{"raw sienna",0.25}}
local L3 = pile{{"raw sienna",1},{"burnt sienna",0.4},{"lead white",0.8},{"yellow ochre",0.7},{"bone black",0.05}}
local F1 = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.15},{"raw sienna",0.3}}
local F2 = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.8},{"raw sienna",0.5}}
local F3 = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5},{"raw sienna",0.5},{"bone black",0.12}}
work(W * E1, {hand="detail", pile=L1, coverage=4, fill=true, clip=true})
work(W * (E2 - E1), {hand="detail", pile=L2, coverage=4, fill=true, clip=true})
work(W - E2, {hand="detail", pile=L3, coverage=4, fill=true, clip=true})
work(F * E1, {hand="detail", pile=F1, angle=RAD, coverage=4, fill=true, clip=true})
work(F * (E2 - E1), {hand="detail", pile=F2, angle=RAD, coverage=4, fill=true, clip=true})
work(F - E2, {hand="detail", pile=F3, angle=RAD, coverage=4, fill=true, clip=true})
work(DOOR - FIG2:grow(1.5), {hand="detail", pile=pile{{"lead white",3},{"cadmium yellow",0.5},{"Indian yellow",0.25},{"zinc white",0.6}}, coverage=4, fill=true, clip=true})
blend(W, {tool={kind="badger", width=10}, coverage=1.2})
blend(F, {tool={kind="badger", width=10}, angle=RAD, coverage=1.2})
-- the reflected couches where the burst crossed them
local SH = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.45},{"raw sienna",0.2}}
for _, g in ipairs({G_ML, G_MR}) do
  local z = ellipse(500, 335, 128, 112)
  work((g.side * z) - g.top, {hand="detail", pile=DRKB, coverage=4, fill=true, clip=true})
  work((g.front * z) - g.side, {hand="detail", pile=SH, coverage=4, fill=true, clip=true})
end

--@ chunk 29
print(type(mixr))

--@ chunk 30
function mixr(a, b, t)
  local parts, order, out = {}, {}, {}
  for _, e in ipairs(a) do if not parts[e[1]] then order[#order + 1] = e[1] end parts[e[1]] = (parts[e[1]] or 0) + e[2] * (1 - t) end
  for _, e in ipairs(b) do if not parts[e[1]] then order[#order + 1] = e[1] end parts[e[1]] = (parts[e[1]] or 0) + e[2] * t end
  for _, n in ipairs(order) do if parts[n] > 0.01 then out[#out + 1] = {n, parts[n]} end end
  return out
end
print(wait(2 * 24 * 60), drying(470, 300), drying(430, 380))
-- the head of the frame where the couch repaint crossed it
work(FIG1 * rect(380, 360, 100, 60), {hand="detail", pile=pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}, coverage=5, fill=true, clip=true})
-- the far wall again, in nine close steps from the door outward, no hard ring
local CO = nil
for _, g in ipairs({G_ML, G_MR}) do for _, k in ipairs({"top", "front", "side", "pad", "head"}) do CO = CO and (CO + g[k]) or g[k] end end
WALL = (RFAR - DOOR) - FIG2:grow(1.5) - TESM:grow(1.5) - FIG1:grow(2) - CO
local A = {{"lead white",3},{"cadmium yellow",0.3},{"yellow ochre",0.25},{"zinc white",0.3}}
local Z = {{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.45},{"yellow ochre",0.6},{"bone black",0.1}}
local radii = {58, 70, 83, 97, 112, 128, 146, 166, 400}
local prev = nil
for i, r in ipairs(radii) do
  local e = ellipse(500, 330, r, r * 1.05)
  local ring = prev and (e - prev) or e
  local t = ((i - 1) / (#radii - 1)) ^ 0.8
  work(WALL * ring, {hand="detail", pile=pile(mixr(A, Z, t)), coverage=4, fill=true, clip=true})
  prev = e
end
blend(WALL, {tool={kind="badger", width=8}, coverage=1.0})

--@ chunk 31
print(wait(2 * 24 * 60), drying(470, 420), drying(520, 600))
-- seams of the reflected floor, restated inside the cleaned glow
local G = ellipse(500, 335, 128, 112) * RFLOOR - FIG2:grow(1.5) - TESM:grow(1.5) - FIG1:grow(2)
local CO = nil
for _, g in ipairs({G_ML, G_MR}) do for _, k in ipairs({"top", "front", "side", "pad", "head"}) do CO = CO and (CO + g[k]) or g[k] end end
G = G - CO
local SP = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.5},{"ultramarine ash",0.4},{"burnt sienna",0.15}}
local b = brush{kind="round", width=3, point=0.5, stiffness=0.5}
for _, X in ipairs({-260, -195, -128, -64, 2, 66, 131, 197, 260}) do
  b:load(SP, 0.6) b:stroke({P(1.0, X, 170), P(0.5, X, 170)}, {pressure={0.35, 0.18}, clip=G})
end
for i, s in ipairs({0.885, 0.79, 0.717, 0.656, 0.604}) do
  b:load(SP, 0.6) b:stroke({P(s, -260, 170), P(s, 260, 170)}, {pressure={0.28 - 0.025 * i, 0.28 - 0.025 * i}, clip=G})
end
-- 2: the near floor sinks into shadow, graded in separate piles, seams blended narrowly
NF = FLOOR - FIG1:grow(1)
for _, g in ipairs({G_RL, G_RR}) do for _, k in ipairs({"top", "front", "side", "pad", "head"}) do NF = NF - g[k]:grow(1) end end
local function yb(a, c) return NF * (above(function(x) return c end) - above(function(x) return a end)) end
local B1 = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.35},{"raw sienna",0.5},{"bone black",0.22}}
local B2 = pile{{"yellow ochre",0.8},{"burnt sienna",0.7},{"lead white",0.18},{"raw sienna",0.5},{"bone black",0.35}}
local B3 = pile{{"raw sienna",0.8},{"burnt sienna",0.8},{"yellow ochre",0.4},{"bone black",0.5},{"ultramarine blue",0.1}}
local B4 = pile{{"burnt sienna",0.9},{"raw sienna",0.5},{"bone black",0.7},{"ultramarine blue",0.25}}
work(yb(505, 550), {hand="body", pile=B1, angle=RAD, coverage=3.5, fill=true, clip=true})
work(yb(550, 595), {hand="body", pile=B2, angle=RAD, coverage=3.5, fill=true, clip=true})
work(yb(595, 635), {hand="body", pile=B3, angle=RAD, coverage=3.5, fill=true, clip=true})
work(yb(635, 667), {hand="body", pile=B4, angle=RAD, coverage=3.5, fill=true, clip=true})
for _, y in ipairs({550, 595, 635}) do blend(yb(y - 9, y + 9), {tool={kind="badger", width=8}, angle=math.pi / 2, coverage=1.5}) end

--@ chunk 32
print(wait(3 * 24 * 60), drying(500, 550), drying(500, 640))
local function yb(a, c) return NF * (above(function(x) return c end) - above(function(x) return a end)) end
local B1 = {{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.35},{"raw sienna",0.5},{"bone black",0.22}}
local B2 = {{"yellow ochre",0.8},{"burnt sienna",0.7},{"lead white",0.18},{"raw sienna",0.5},{"bone black",0.35}}
local B3 = {{"raw sienna",0.8},{"burnt sienna",0.8},{"yellow ochre",0.4},{"bone black",0.5},{"ultramarine blue",0.1}}
local B4 = {{"burnt sienna",0.9},{"raw sienna",0.5},{"bone black",0.7},{"ultramarine blue",0.25}}
work(yb(539, 561), {hand="detail", pile=pile(mixr(B1, B2, 0.5)), coverage=4.5, fill=true, clip=true, angle=RAD})
work(yb(584, 606), {hand="detail", pile=pile(mixr(B2, B3, 0.5)), coverage=4.5, fill=true, clip=true, angle=RAD})
work(yb(624, 646), {hand="detail", pile=pile(mixr(B3, B4, 0.5)), coverage=4.5, fill=true, clip=true, angle=RAD})
print(wait(2 * 24 * 60))
-- floor seams and the inlaid address, restated dimmer in the shadow
local below505 = NF - above(function(x) return 505 end)
local DS = pile{{"lead white",1.2},{"yellow ochre",0.6},{"raw sienna",0.5},{"ultramarine ash",0.4},{"burnt sienna",0.3}}
local b = brush{kind="round", width=3, point=0.5, stiffness=0.5}
for _, X in ipairs({-260, -195, -128, -64, 2, 66, 131, 197, 260}) do
  b:load(DS, 0.6) b:stroke({P(2.0, X, 170), P(1.0, X, 170)}, {pressure={0.75, 0.35}, clip=below505})
  b:load(DS, 0.6) b:stroke({P(3.9, X, 170), P(2.0, X, 170)}, {pressure={1, 0.75}, clip=below505})
end
for i, s in ipairs({1.15, 1.35, 1.65, 2.1, 2.9}) do
  b:load(DS, 0.6) b:stroke({P(s, -260, 170), P(s, 260, 170)}, {pressure={0.3 + 0.12 * i, 0.3 + 0.12 * i}, clip=below505})
end
local IL = pile{{"lead white",1.8},{"yellow ochre",0.5},{"raw sienna",0.35},{"ultramarine ash",0.3}}
local c = brush{kind="round", width=3.2, point=0.3, stiffness=0.5}
local function F(X, s) return P(s, X, 170) end
local function seg(a, d, pr) c:load(IL, 0.75) c:stroke({a, d}, {pressure={pr, pr}, ramps={0.03, 0.03}, clip=NF}) end
local function room(Xa, Xb, sn, sf, pr)
  local pts = {F(Xa, sn), F(Xb, sn), F(Xb, sf), F(Xa, sf)}
  for i = 1, 4 do seg(pts[i], pts[i % 4 + 1], pr) end
end
room(-150, -20, 2.02, 1.62, 0.75)
room(-122, -42, 1.9, 1.72, 0.5)
seg(F(2, 2.08), F(2, 1.57), 0.9)
room(24, 104, 1.93, 1.68, 0.65)
local BLR = pile{{"lead white",2.4},{"yellow ochre",0.4},{"ultramarine ash",0.3}}
local pts = {F(34, 1.86), F(84, 1.86), F(84, 1.75), F(34, 1.75)}
for i = 1, 4 do c:load(BLR, 0.75) c:stroke({pts[i], pts[i % 4 + 1]}, {pressure={0.45, 0.45}, ramps={0.03, 0.03}, clip=NF}) end
local arc = {}
for i = 0, 10 do local t = i / 10 arc[#arc + 1] = F(-60 + 140 * t, 1.6 - 0.06 * math.sin(math.pi * t)) end
c:load(IL, 0.7) c:stroke(arc, {pressure={0.5, 0.5}, clip=NF})
-- his shadow, longer now, down toward the join
local sp = pile{{"burnt sienna",1},{"bone black",0.8},{"ultramarine blue",0.4},{"raw sienna",0.3}}
work(poly({{418, 540}, {444, 540}, {470, 471}, {452, 471}}, true) * FLOOR, {hand="detail", pile=sp, coverage=3, fill=true, clip=true})

--@ chunk 33
print(wait(3 * 24 * 60), drying(440, 500))
work(FIG1 * rect(395, 455, 85, 90), {hand="detail", pile=pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}, coverage=5, fill=true, clip=true})
work(FIG1 * rect(380, 395, 100, 30), {hand="detail", pile=pile{{"bone black",1.2},{"ultramarine blue",0.7},{"burnt sienna",0.45}}, coverage=5, fill=true, clip=true})
print(wait(3 * 24 * 60), drying(440, 500))
-- 3: the frame as armour. Light from behind us on his back; the join's light rims his contour.
local x, y, u = 430, 540, 6.3
local MG = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.45},{"burnt sienna",0.3}}
local MGL = pile{{"bone black",0.7},{"ultramarine ash",1},{"lead white",0.8},{"burnt sienna",0.3},{"yellow ochre",0.15}}
local DK = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local RIMW = pile{{"lead white",2.4},{"cadmium yellow",0.35},{"yellow ochre",0.3},{"zinc white",0.3}}
local function tube(pts, w, p, load, clipm)
  local b = brush{kind="filbert", width=w, stiffness=0.5}
  b:load(p, load) b:stroke(pts, {pressure={0.7, 0.55}, ramps={0.15, 0.3}, clip=clipm})
end
local M = FIG1:shrink(1.2)
-- helmet: lit crown to dark nape
tube({{x - 1, y - 25.3 * u}, {x, y - 23 * u}}, 0.9 * u, MGL, 0.6, M)
-- back plate either side of the spine housing, upper lighter
tube({{x - 2.6 * u, y - 19.6 * u}, {x - 2.4 * u, y - 15 * u}, {x - 2.0 * u, y - 11.8 * u}}, 1.7 * u, MG, 0.6, M)
tube({{x + 2.6 * u, y - 19.6 * u}, {x + 2.4 * u, y - 15 * u}, {x + 2.0 * u, y - 11.8 * u}}, 1.4 * u, MG, 0.55, M - ellipse(x + 2.6 * u, y - 16.4 * u, 1.4 * u, 2.2 * u))
-- arms and legs: a lit stroke down each, plate breaks at elbow and knee
for _, s in ipairs({-1, 1}) do
  tube({{x + s * 4.85 * u, y - 18 * u}, {x + s * 4.95 * u, y - 14 * u}}, 0.9 * u, MGL, 0.55, M)
  tube({{x + s * 5.0 * u, y - 13 * u}, {x + s * 5.05 * u, y - 9 * u}}, 0.8 * u, MG, 0.55, M)
  tube({{x + s * 1.75 * u, y - 9.4 * u}, {x + s * 1.85 * u, y - 5.6 * u}}, 1.0 * u, MG, 0.55, M)
  tube({{x + s * 1.95 * u, y - 4.6 * u}, {x + s * 2.05 * u, y - 0.8 * u}}, 0.9 * u, MG, 0.5, M)
  local d = brush{kind="round", width=1.3, point=0.3}
  d:load(DK, 0.7) d:stroke({{x + s * 4.4 * u, y - 13.6 * u}, {x + s * 5.6 * u, y - 13.4 * u}}, {pressure={0.6, 0.6}, clip=FIG1})
  d:load(DK, 0.7) d:stroke({{x + s * 1.1 * u, y - 5.2 * u}, {x + s * 2.6 * u, y - 5.0 * u}}, {pressure={0.6, 0.6}, clip=FIG1})
end
-- belt line
local d = brush{kind="round", width=1.6, point=0.3}
d:load(DK, 0.7) d:stroke({{x - 3 * u, y - 10.6 * u}, {x + 3 * u, y - 10.4 * u}}, {pressure={0.6, 0.6}, clip=FIG1})
-- the rim from the join: a thin warm edge, strongest on head and shoulders, breaking down the limbs, gone at the feet
local n = noise{seed=31, period=14, octaves=2}
local edge = (FIG1 - FIG1:shrink(1.1)) * mask(function(px, py)
  local top = clamp((500 - py) / 90, 0, 1)
  return (n(px, py) + 0.35 * top > 0.05) and 1 or 0
end) * above(function(px) return 500 end)
work(edge, {hand="detail", pile=RIMW, coverage=2.5, fill=true, clip=true})

--@ chunk 34
work(FIG1:shrink(1.6), {hand="scumble", blender=true, tool={kind="filbert", width=3}, coverage=2.5, angle=math.pi/2, clip=true})

--@ chunk 35
print(wait(2 * 24 * 60), drying(430, 450))
local x, y, u = 430, 540, 6.3
local DK = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local LT = pile{{"lead white",1.6},{"ultramarine ash",0.6},{"yellow ochre",0.3},{"bone black",0.2}}
local d = brush{kind="round", width=1.5, point=0.3}
local l = brush{kind="round", width=1.2, point=0.4}
local function seam(a, c, lip)
  d:load(DK, 0.7) d:stroke({a, c}, {pressure={0.6, 0.6}, clip=FIG1:shrink(1)})
  if lip then l:load(LT, 0.5) l:stroke({{a[1], a[2] + 1.8}, {c[1], c[2] + 1.8}}, {pressure={0.45, 0.25}, ramps={0.1, 0.5}, clip=FIG1:shrink(1)}) end
end
seam({x - 3.2 * u, y - 10.6 * u}, {x + 3.2 * u, y - 10.4 * u}, true)
for _, s in ipairs({-1, 1}) do
  seam({x + s * 4.3 * u, y - 13.6 * u}, {x + s * 5.7 * u, y - 13.4 * u}, true)
  seam({x + s * 1.0 * u, y - 5.2 * u}, {x + s * 2.7 * u, y - 5.0 * u}, true)
  -- pauldron: a curved plate lip catching the light from behind us
  l:load(LT, 0.6) l:stroke({{x + s * 2.6 * u, y - 21.0 * u}, {x + s * 4.4 * u, y - 20.9 * u}, {x + s * 6.0 * u, y - 19.6 * u}}, {pressure={0.6, 0.3}, ramps={0.1, 0.4}, clip=FIG1:shrink(0.8)})
  d:load(DK, 0.6) d:stroke({{x + s * 2.8 * u, y - 18.6 * u}, {x + s * 4.6 * u, y - 18.2 * u}, {x + s * 6.0 * u, y - 17.2 * u}}, {pressure={0.55, 0.5}, clip=FIG1:shrink(1)})
end
-- helmet crown
l:load(LT, 0.6) l:stroke({{x - 1.2 * u, y - 25.0 * u}, {x, y - 25.6 * u}, {x + 1.1 * u, y - 25.0 * u}}, {pressure={0.55, 0.3}, clip=FIG1:shrink(0.8)})
-- the reflection: the same body, same plates, same cross, facing us against the light
local x, y, u = 461, 432, 3.5
local MGD = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.25},{"burnt sienna",0.35}}
local pl = (ellipse(x - 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u) + ellipse(x + 4.6 * u, y - 19.2 * u, 2.5 * u, 1.7 * u)) * FIG2:shrink(0.9)
work(pl - ribbon({{x - 5.6 * u, y - 19.5 * u}, {x - 6.2 * u, y - 25.5 * u}}, 2.2 * u), {hand="detail", pile=MGD, coverage=4, fill=true, clip=true})
local cp = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.3},{"ultramarine ash",0.3}}
local cb = brush{kind="round", width=1.0, point=0.3}
cb:load(cp, 0.6) cb:stroke({{x + 2.6 * u, y - 18.2 * u}, {x + 2.6 * u, y - 14.6 * u}}, {pressure={0.5, 0.5}})
cb:load(cp, 0.6) cb:stroke({{x + 1.6 * u, y - 17.2 * u}, {x + 3.6 * u, y - 17.2 * u}}, {pressure={0.5, 0.5}})
local d = brush{kind="round", width=0.9, point=0.3}
local DK = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
d:load(DK, 0.6) d:stroke({{x - 3 * u, y - 10.6 * u}, {x + 3 * u, y - 10.4 * u}}, {pressure={0.5, 0.5}, clip=FIG2})
for _, s in ipairs({-1, 1}) do
  d:load(DK, 0.6) d:stroke({{x + s * 1.1 * u, y - 5.2 * u}, {x + s * 2.6 * u, y - 5.0 * u}}, {pressure={0.5, 0.5}, clip=FIG2})
end
d:load(DK, 0.6) d:stroke({{x + 4.4 * u, y - 13.6 * u}, {x + 5.6 * u, y - 13.4 * u}}, {pressure={0.5, 0.5}, clip=FIG2})
-- the nurse, handmade: a bronze robe lit at its door-side edge, bone ribs, bone hands, a bone collar
local tx, ty, tu = 572, 432, 4.1
local T = function(dx, dy) return {tx + dx * tu, ty + dy * tu} end
local BRZ = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.5},{"yellow ochre",0.3}}
local BRL = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.6},{"raw sienna",0.3}}
local BONE2 = pile{{"lead white",2.6},{"yellow ochre",0.45},{"ultramarine ash",0.3}}
local TI = TESM:shrink(1.0)
local function st(pts, w, p, l, pr, clipm) local b = brush{kind="filbert", width=w} b:load(p, l) b:stroke(pts, {pressure={pr, pr * 0.7}, ramps={0.15, 0.3}, clip=clipm}) end
st({T(-0.4, -19), T(-0.6, -12), T(-0.9, -5), T(-0.9, -0.5)}, 1.2 * tu, BRZ, 0.6, 0.7, TI)
st({T(-0.9, -19.5), T(-1.2, -13), T(-1.5, -6), T(-1.7, -1)}, 0.5 * tu, BRL, 0.55, 0.6, TI)
local r = brush{kind="round", width=1.0, point=0.5}
for i = 0, 4 do
  local yy = -18.5 + i * 2.1 + (i % 2) * 0.4
  r:load(BONE2, 0.6) r:stroke({T(-1.2, yy), T(0, yy + 0.7), T(1.1, yy)}, {pressure={0.35, 0.3}, clip=TI})
end
r:load(BONE2, 0.7) r:stroke({T(-1.4, -21.4), T(0, -20.3), T(1.4, -21.4)}, {pressure={0.5, 0.45}})
for i = 1, 5 do
  local yy = -11 + i * 1.9 * (1 + i * 0.12)
  r:load(BONE2, 0.6) r:touch(tx + (-0.3 + 0.25 * ((i * 0.618) % 1)) * tu, ty + yy * tu, {pressure=0.45})
end
r:load(BONE2, 0.7) r:stroke({T(-2.2, -7.0), T(-2.3, -6.0)}, {pressure={0.6, 0.4}})
r:load(BONE2, 0.7) r:stroke({T(5.3, -12.8), T(6.1, -12.2)}, {pressure={0.6, 0.4}})

--@ chunk 36
print(wait(2 * 24 * 60), drying(150, 520))
local PM = pile{{"lead white",1.6},{"yellow ochre",0.5},{"raw sienna",0.45},{"ultramarine ash",0.45},{"bone black",0.05}}
local PM2 = pile{{"lead white",1.9},{"yellow ochre",0.5},{"raw sienna",0.35},{"ultramarine ash",0.4}}
work(G_RL.pad + G_RL.head, {hand="detail", pile=PM, coverage=4, fill=true, clip=true})
work(G_RR.pad + G_RR.head, {hand="detail", pile=PM2, coverage=4, fill=true, clip=true})
