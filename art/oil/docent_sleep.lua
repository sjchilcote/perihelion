-- easel session "docent_sleep": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=3911, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"bone brown",1},{"raw sienna",0.2},{"ultramarine blue",0.3},{"lead white",0.05}}, um=45, apply="brush", texture=0.35}}}
VP = {505, 262}
XW, YF, YC, ZF = 520, 330, -250, 7
function pr(X, Y, z) return {VP[1] + X/z, VP[2] + Y/z} end
FLOOR = poly({pr(-XW, YF, 0.55), pr(XW, YF, 0.55), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
CEIL = poly({pr(-XW, YC, 0.55), pr(XW, YC, 0.55), pr(XW, YC, ZF), pr(-XW, YC, ZF)})
LW = poly({pr(-XW, YC, 0.4), pr(-XW, YC, ZF), pr(-XW, YF, ZF), pr(-XW, YF, 0.4)})
RW = poly({pr(XW, YC, 0.4), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(XW, YF, 0.4)})
ENDW = poly({pr(-XW, YC, ZF), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
BF = pile{{"bone black",2},{"bone brown",0.9},{"raw sienna",0.25},{"ultramarine blue",0.2},{"lead white",0.06}}
BW = pile{{"bone black",2.2},{"bone brown",0.8},{"burnt sienna",0.2},{"ultramarine blue",0.25},{"lead white",0.04}}
BC = pile{{"bone black",2.6},{"bone brown",0.5},{"ultramarine blue",0.3}}
BE = pile{{"bone black",1.6},{"bone brown",0.8},{"raw sienna",0.4},{"Mars orange",0.1},{"lead white",0.08}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR, {hand="body", pile=BF, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
work(CEIL, {hand="body", pile=BC, coverage=3, fill=true, clip=CEIL, angle=toVP, length={20, 50}, tool="filbert 9"})
work(LW + RW, {hand="body", pile=BW, coverage=3, fill=true, clip=LW + RW, angle=toVP, length={15, 40}, tool="filbert 8"})
work(ENDW, {hand="detail", pile=BE, coverage=4, fill=true, clip=ENDW, tool={kind="round", width=2}, length={3, 8}})

--@ chunk 2
print(wait(5*24*60))
local function wp(sd, z, Y) return pr(sd*XW, Y, z) end
local CASE = pile{{"bone black",2.4},{"bone brown",0.5},{"ultramarine blue",0.3}}
local FR = pile{{"bone black",1.6},{"bone brown",0.9},{"raw sienna",0.3},{"lead white",0.08}}
local cm = nil
CASES = {}
for _, sd in ipairs({-1, 1}) do
  local z = (sd < 0) and 0.9 or 0.95
  while z < 6.2 do
    local zb = z*1.32
    local m = poly({wp(sd, z, -130), wp(sd, zb, -130), wp(sd, zb, 150), wp(sd, z, 150)})
    cm = cm and (cm + m) or m
    CASES[#CASES+1] = {sd=sd, za=z, zb=zb}
    z = zb*1.12
  end
end
CASEM = cm
work(cm, {hand="detail", pile=CASE, coverage=4.5, fill=true, clip=cm, tool={kind="round", width=1.8}, length={3, 8}})
-- plinths beneath the cases and frame edges
local pl = nil
for _, c in ipairs(CASES) do
  local m = poly({wp(c.sd, c.za, 150), wp(c.sd, c.zb, 150), wp(c.sd, c.zb, YF), wp(c.sd, c.za, YF)})
  pl = pl and (pl + m) or m
end
work(pl, {hand="detail", pile=FR, coverage=4.5, fill=true, clip=pl, tool={kind="round", width=1.8}, length={3, 8}})

--@ chunk 3
print(wait(5*24*60))
local function wp(sd, z, Y) return pr(sd*XW, Y, z) end
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local GL = pile{{"bone black",1.3},{"bone brown",0.6},{"raw sienna",0.3},{"lead white",0.18}}
local BONE = pile{{"lead white",0.7},{"yellow ochre",0.25},{"raw sienna",0.1},{"bone black",0.6}}
local function L(p, a, b, pr_, w) local r = brush{kind="rigger", width=w, point=1} r:load(p, 0.9) r:stroke({a, b}, {pressure={pr_, pr_}, ramps={0.03, 0.03}}) end
for _, c in ipairs(CASES) do
  local s = 1 / ((c.za + c.zb)/2)
  local w = clamp(1.6*s, 0.4, 1.8)
  L(GL, wp(c.sd, c.za, -130), wp(c.sd, c.zb, -130), 0.5, w)
  L(GL, wp(c.sd, c.za, -130), wp(c.sd, c.za, 150), 0.45, w)
  L(JD, wp(c.sd, c.za, 150), wp(c.sd, c.zb, 150), 0.55, w*1.2)
  -- a dim exhibit inside: a bone object on a stand, barely seen
  local zc = (c.za + c.zb)/2
  local o = {}
  for j = 0, 9 do local t = j/10*2*math.pi o[#o+1] = pr(c.sd*(XW + 4), 40 + 38*math.sin(t), zc + (c.zb - c.za)*0.18*math.cos(t)) end
  work(poly(o, true), {hand="detail", pile=BONE, coverage=3, fill=true, clip=CASEM, tool={kind="round", width=clamp(1.4*s, 0.6, 1.6)}, length={2, 5}})
end

--@ chunk 4
print(wait(5*24*60))
local CASE = pile{{"bone black",2.4},{"bone brown",0.5},{"ultramarine blue",0.3}}
work(CASEM, {hand="detail", pile=CASE, coverage=5, fill=true, clip=CASEM, tool={kind="round", width=1.8}, length={3, 8}})

--@ chunk 5
print(wait(6*24*60))
local DIM = pile{{"bone black",1.4},{"bone brown",0.6},{"lead white",0.18},{"yellow ochre",0.08}}
local DIM2 = pile{{"bone black",1.6},{"bone brown",0.7},{"raw sienna",0.2},{"lead white",0.1}}
local shapes = {
 {{-0.5, 0}, {0.5, 0}, {0.35, -0.6}, {0.5, -1.1}, {0.2, -1.4}, {-0.2, -1.4}, {-0.5, -1.1}, {-0.35, -0.6}},
 {{-0.6, 0}, {0.6, 0}, {0.6, -1.5}, {-0.6, -1.5}},
 {{-0.15, 0}, {0.15, 0}, {0.1, -0.8}, {0.5, -1.3}, {0, -1.6}, {-0.5, -1.3}, {-0.1, -0.8}},
 {{-0.7, 0}, {0.7, 0}, {0.4, -0.5}, {0, -0.7}, {-0.4, -0.5}},
}
for i, c in ipairs(CASES) do
  local zc = (c.za + c.zb)/2
  local sh = shapes[(i*3) % #shapes + 1]
  local sz = 50*rand(0.8, 1.2)
  local o = {}
  for _, q in ipairs(sh) do o[#o+1] = pr(c.sd*(XW + 3), 120 + q[2]*sz, zc + q[1]*sz*0.6*(c.zb - c.za)/120) end
  local m = poly(o, true) * CASEM
  work(m, {hand="detail", pile=(i % 2 == 0) and DIM or DIM2, coverage=4, fill=true, clip=m, tool={kind="round", width=1.2}, length={2, 5}})
end
-- glass edges catching a faint line
local GL = pile{{"bone black",1.2},{"bone brown",0.6},{"raw sienna",0.4},{"lead white",0.2}}
local function wp(sd, z, Y) return pr(sd*XW, Y, z) end
for _, c in ipairs(CASES) do
  local s = 1 / ((c.za + c.zb)/2)
  local r = brush{kind="rigger", width=clamp(1.2*s, 0.4, 1.4), point=1}
  r:load(GL, 0.9) r:stroke({wp(c.sd, c.za, -130), wp(c.sd, c.zb, -130)}, {pressure={0.45, 0.45}})
  r:load(GL, 0.9) r:stroke({wp(c.sd, c.za + 0.01, -130), wp(c.sd, c.za + 0.01, 150)}, {pressure={0.35, 0.35}})
end

--@ chunk 6
print(wait(5*24*60))
-- the high window on the right wall
local function wp(z, Y) return pr(XW, Y, z) end
WIN = poly({wp(1.55, -235), wp(2.05, -235), wp(2.05, -165), wp(1.55, -165)})
local WW = pile{{"lead white",2.4},{"cadmium yellow",0.35},{"Mars orange",0.08}}
local WF = pile{{"bone black",1.8},{"bone brown",0.6}}
work(WIN:grow(4), {hand="detail", pile=WF, coverage=4.5, fill=true, clip=WIN:grow(4), tool={kind="round", width=1.6}, length={3, 6}})
work(WIN, {hand="detail", pile=WW, coverage=4.5, fill=true, clip=WIN, tool={kind="round", width=1.6}, length={3, 6}})
-- the light it lays on the floor: a skewed warm patch, brightest in its middle, graded by dithered strokes
local q = {pr(-170, YF, 1.5), pr(230, YF, 1.38), pr(330, YF, 2.35), pr(-80, YF, 2.7)}
PATCH = poly(q, true)
local cx, cy = 0, 0 for _, p in ipairs(q) do cx = cx + p[1]/4 cy = cy + p[2]/4 end
PC = {cx, cy}
local WP = {
 pile{{"bone black",1.5},{"bone brown",0.8},{"raw sienna",0.35},{"lead white",0.1}},
 pile{{"bone black",1},{"raw sienna",0.6},{"burnt sienna",0.2},{"lead white",0.2}},
 pile{{"bone black",0.6},{"raw sienna",0.6},{"yellow ochre",0.4},{"lead white",0.35}},
 pile{{"yellow ochre",0.7},{"raw sienna",0.3},{"lead white",0.7},{"bone black",0.2}},
}
local reg = PATCH:grow(14) * FLOOR
local cells = {}
for y = 380, 566, 2.6 do for x = 300, 760, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if reg:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.3 then
    local inside = PATCH:at(clamp(xx,0,999), clamp(yy,0,562))
    local d = math.sqrt(((xx - cx)/150)^2 + ((yy - cy)/45)^2)
    local v = (inside > 0.5) and (4.2 - d*1.5) or (1.4 - d*0.3)
    v = v + randn(0, 0.3)
    if v > 0.8 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 4)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(WP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(WP[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=reg})
  end
end end
print(#cells)

--@ chunk 7
print(wait(6*24*60), drying(500,450))
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(PATCH:grow(16) * FLOOR, {hand="detail", pile=BF, coverage=5, fill=true, clip=PATCH:grow(16) * FLOOR, angle=toVP, tool={kind="round", width=2.2}, length={4, 10}})

--@ chunk 8
print(wait(6*24*60), drying(500,450))
-- the window's light as a crisp skewed quad on the floor, split by the mullion's shadow
local function f(X, z) return pr(X, YF, z) end
local function quad(X0, X1, z0, z1, sk) return poly({f(X0 + sk*0, z0), f(X1, z0), f(X1 + sk, z1), f(X0 + sk, z1)}) end
LQ = quad(-90, 210, 1.6, 2.35, -60)
local A = pile{{"bone black",0.8},{"raw sienna",0.6},{"yellow ochre",0.3},{"lead white",0.3}}
local B = pile{{"yellow ochre",0.7},{"raw sienna",0.3},{"lead white",0.75},{"bone black",0.2}}
work(LQ, {hand="detail", pile=A, coverage=4.5, fill=true, clip=LQ, angle=0, tool={kind="round", width=1.8}, length={3, 8}})
local core = quad(-60, 180, 1.66, 2.25, -60)
work(core, {hand="detail", pile=B, coverage=4.5, fill=true, clip=core, angle=0, tool={kind="round", width=1.8}, length={3, 8}})
local MS = pile{{"bone black",1.3},{"raw sienna",0.4},{"bone brown",0.4},{"lead white",0.1}}
local ms = poly({f(55, 1.6), f(75, 1.6), f(15, 2.35), f(-5, 2.35)}) * LQ
work(ms, {hand="detail", pile=MS, coverage=4.5, fill=true, clip=ms, angle=0, tool={kind="round", width=1.4}, length={2, 5}})
local ms2 = poly({f(-150, 1.95), f(250, 1.95), f(250, 2.0), f(-150, 2.0)}) * LQ
work(ms2, {hand="detail", pile=MS, coverage=4.5, fill=true, clip=ms2, angle=0, tool={kind="round", width=1.2}, length={2, 5}})
-- the window's own mullions
local function wp(z, Y) return pr(XW, Y, z) end
local WF = pile{{"bone black",1.8},{"bone brown",0.6}}
local r = brush{kind="filbert", width=3, stiffness=0.6}
r:load(WF, 0.9) r:stroke({wp(1.8, -235), wp(1.8, -165)}, {pressure={0.8, 0.8}})
r:load(WF, 0.9) r:stroke({wp(1.55, -200), wp(2.05, -200)}, {pressure={0.7, 0.7}})

--@ chunk 9
print(wait(6*24*60), drying(530,430))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local DKB = pile{{"bone black",2.2},{"bone brown",0.6},{"ultramarine blue",0.2}}
local BRZ = pile{{"bone brown",1.2},{"raw sienna",0.6},{"bone black",0.8}}
-- bench and its shadow across the light
BSEAT = poly({{452, 394}, {590, 394}, {594, 402}, {448, 402}})
BFRONT = rect(448, 402, 146, 7)
BLEGS = rect(454, 409, 6, 23) + rect(582, 409, 6, 23)
fill(poly({{450, 430}, {596, 430}, {606, 440}, {446, 440}}), DKB, "round 1.4")
fill(BSEAT, BRZ) fill(BFRONT + BLEGS, DKB)
-- the docent, seated
DOC = {
 robe = poly({{500, 352}, {550, 352}, {556, 400}, {494, 400}}, true),
 lap = poly({{494, 396}, {556, 396}, {560, 436}, {490, 436}}, true),
 head = ellipse(525, 327, 12, 16),
 ruff = ellipse(525, 351, 23, 7),
}
local DM = DOC.robe + DOC.lap + DOC.head + DOC.ruff
DOCM = DM
fill(DM, BRZ)
-- the Commando standing a little way off, in profile, helm bowed
local function P(t) return poly(t, true) end
CP = {
 helm = P({{340, 292}, {358, 294}, {368, 306}, {362, 320}, {344, 320}, {336, 306}}),
 gorget = P({{340, 316}, {358, 316}, {358, 328}, {340, 328}}),
 torso = P({{326, 324}, {364, 326}, {368, 392}, {328, 392}}),
 paul = P({{330, 322}, {360, 320}, {368, 342}, {334, 350}}),
 arm = P({{344, 340}, {358, 340}, {361, 392}, {347, 394}}),
 faulds = P({{326, 388}, {370, 388}, {368, 410}, {328, 410}}),
 thighA = P({{330, 406}, {354, 406}, {356, 442}, {334, 442}}),
 thighB = P({{348, 406}, {370, 406}, {374, 442}, {352, 442}}),
 greaveA = P({{334, 440}, {355, 440}, {354, 470}, {336, 470}}),
 greaveB = P({{353, 440}, {374, 440}, {376, 470}, {356, 470}}),
 footA = P({{328, 468}, {358, 468}, {360, 477}, {328, 477}}),
 footB = P({{352, 468}, {386, 468}, {388, 477}, {354, 477}}),
}
local cm = nil for _, m in pairs(CP) do cm = cm and (cm + m) or m end
CMD = cm
fill(poly({{326, 474}, {392, 474}, {420, 482}, {320, 482}}), DKB, "round 1.4")
fill(cm, pile{{"bone black",2.2},{"ultramarine blue",0.35},{"lead white",0.08}})

--@ chunk 10
print(wait(10*24*60), drying(530,410), drying(345,400))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.1", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local BRZD = pile{{"bone brown",1.2},{"raw sienna",0.5},{"bone black",1.1}}
local BRZ = pile{{"bone brown",1},{"raw sienna",0.8},{"bone black",0.6},{"lead white",0.05}}
local BRZL = pile{{"raw sienna",1},{"yellow ochre",0.5},{"bone brown",0.4},{"lead white",0.3}}
-- robe: a tapering bell from the ruff to the lap, the lap over the bench edge, the hem to the floor
ROBE = poly({{510, 352}, {540, 352}, {552, 396}, {560, 432}, {490, 432}, {498, 396}}, true)
fill(ROBE, BRZD)
local lit = ROBE * poly({{528, 350}, {600, 350}, {600, 440}, {534, 440}})
fill(lit, BRZ)
fill(ROBE * poly({{544, 350}, {600, 350}, {600, 440}, {550, 440}}), BRZL)
-- head: bronze egg, bone face
local HEAD = ellipse(525, 327, 11, 15)
fill(HEAD, BRZD)
fill(HEAD * poly({{528, 300}, {560, 300}, {560, 350}, {528, 350}}), BRZL)

--@ chunk 11
print(wait(8*24*60), drying(530,410))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 0.8", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local BONE = pile{{"lead white",1.3},{"yellow ochre",0.35},{"raw sienna",0.12},{"bone black",0.15}}
local BONED = pile{{"lead white",0.7},{"yellow ochre",0.3},{"raw sienna",0.2},{"bone black",0.5}}
local DK = pile{{"bone black",2.4},{"bone brown",0.4}}
-- bone face on the egg, turned a little down
local face = ellipse(525, 331, 7.5, 10)
fill(face, BONED)
fill(face * poly({{526, 318}, {540, 318}, {540, 345}, {526, 345}}), BONE)
-- pleated ruff: alternate pale and dark pleats around a flattened ring
fill(ellipse(525, 350, 22, 6.5), BONED, "round 1")
local r = brush{kind="rigger", width=0.9, point=1}
for k = 0, 17 do
  local t = math.pi*(0.04 + 0.92*k/17)
  local x = 525 - 21*math.cos(t)
  r:load((k % 2 == 0) and BONE or DK, 0.9) r:stroke({{x, 350 - 5.5*math.sin(t)}, {x + (x - 525)*0.08, 350 + 5.5*math.sin(t)}}, {pressure={0.5, 0.5}})
end
-- tablet in the lap, hands folded on it
local TAB = poly({{510, 384}, {540, 384}, {542, 401}, {508, 401}})
fill(TAB, BONED, "round 1")
fill(TAB * poly({{526, 382}, {546, 382}, {546, 404}, {526, 404}}), BONE, "round 1")
local g = brush{kind="rigger", width=0.5, point=1}
for row = 0, 3 do
  local x = 512
  while x < 538 do local L = rand(1.5, 4) g:load(DK, 0.85) g:stroke({{x, 387 + row*3.6}, {x + L, 387 + row*3.6}}, {pressure={0.5, 0.5}}) x = x + L + rand(1, 2) end
end
local BRZ = pile{{"bone brown",1},{"raw sienna",0.8},{"bone black",0.6},{"lead white",0.05}}
fill(ellipse(520, 395, 7, 3.5) + ellipse(531, 397, 7, 3.5), BRZ)

--@ chunk 12
print(wait(8*24*60), drying(525,330), drying(345,400))
-- the single lens, dimming to a soft warm glow: a few short radial strokes, then the small core
local LS = pile{{"Mars orange",0.6},{"burnt sienna",0.3},{"lead white",0.6},{"bone black",0.2}}
local s = brush{kind="filbert", width=1.2, stiffness=0.4}
for k = 0, 15 do local a = k/16*2*math.pi s:load(LS, 0.6) s:stroke({{525 + math.cos(a)*1.6, 327 + math.sin(a)*1.6}, {525 + math.cos(a)*4.2, 327 + math.sin(a)*4.2}}, {pressure={0.4, 0.05}}) end
local CORE = pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.25}}
local c = brush{kind="round", width=2.2, point=0.3}
c:load(CORE, 0.95) c:touch(525, 327, {pressure=0.55})
local RIM = pile{{"bone black",2},{"bone brown",0.5}}
local rr = brush{kind="rigger", width=0.6, point=1}
local pts = {} for k = 0, 16 do local a = k/16*2*math.pi pts[#pts+1] = {525 + 2.8*math.cos(a), 327 + 2.8*math.sin(a)} end
rr:load(RIM, 0.9) rr:stroke(pts, {pressure={0.4, 0.4}})
-- the Commando's plates and the window's warm rim on his facing edges
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local AM = pile{{"Mars orange",0.5},{"raw sienna",0.3},{"lead white",0.6},{"bone black",0.3}}
local function L(p, pts, pr_, w) local b = brush{kind="rigger", width=w or 0.7, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_*0.4, pr_, pr_*0.4}, clip=CMD:grow(0.4)}) end
for _, s2 in ipairs({{{326, 390}, {368, 390}}, {{328, 408}, {368, 408}}, {{334, 441}, {372, 441}}, {{340, 326}, {358, 326}}, {{330, 346}, {366, 342}}}) do L(JD, s2, 0.6, 0.8) end
for _, v in ipairs({396, 402}) do L(JD, {{327, v}, {369, v}}, 0.45, 0.6) end
L(AM, {{358, 294}, {368, 306}, {362, 320}}, 0.6)
L(AM, {{360, 320}, {368, 342}}, 0.5)
L(AM, {{364, 326}, {368, 392}}, 0.4)
L(AM, {{370, 406}, {374, 442}}, 0.4)
L(AM, {{374, 440}, {376, 470}}, 0.4)
L(AM, {{358, 468}, {386, 468}}, 0.35)
L(JD, {{352, 306}, {364, 310}}, 0.6, 0.9)
-- warm rim on the docent's lit side and ruff edge
local AMH = pile{{"Mars orange",0.4},{"yellow ochre",0.4},{"lead white",0.9}}
local b = brush{kind="rigger", width=0.8, point=1}
b:load(AMH, 0.9) b:stroke({{534, 313}, {536, 327}, {531, 341}}, {pressure={0.15, 0.5, 0.15}})
b:load(AMH, 0.9) b:stroke({{540, 352}, {552, 396}, {560, 432}}, {pressure={0.2, 0.5, 0.3}})
b:load(AMH, 0.9) b:stroke({{530, 344}, {546, 349}}, {pressure={0.4, 0.3}})

--@ chunk 13
print(wait(6*24*60))
local function fill(m, p, t) if m:area() > 0.3 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
local keep = ROBE:grow(0.5) + ellipse(525, 327, 12, 16) + ellipse(525, 350, 23, 7.5)
local old = DOCM:grow(1.5) - keep
local function f(X, z) return pr(X, YF, z) end
local core = poly({f(-60, 1.66), f(180, 1.66), f(120, 2.25), f(-120, 2.25)})
local ms = poly({f(55, 1.6), f(75, 1.6), f(15, 2.35), f(-5, 2.35)}) + poly({f(-150, 1.95), f(250, 1.95), f(250, 2.0), f(-150, 2.0)})
local A = pile{{"bone black",0.8},{"raw sienna",0.6},{"yellow ochre",0.3},{"lead white",0.3}}
local B = pile{{"yellow ochre",0.7},{"raw sienna",0.3},{"lead white",0.75},{"bone black",0.2}}
local MS = pile{{"bone black",1.3},{"raw sienna",0.4},{"bone brown",0.4},{"lead white",0.1}}
local BRZ = pile{{"bone brown",1.2},{"raw sienna",0.6},{"bone black",0.8}}
local DKB = pile{{"bone black",2.2},{"bone brown",0.6},{"ultramarine blue",0.2}}
local bench = BSEAT + BFRONT + BLEGS
local shadow = poly({{450, 430}, {596, 430}, {606, 440}, {446, 440}})
fill(old - bench - LQ - shadow, BF)
fill(old * BSEAT, BRZ)
fill(old * (BFRONT + BLEGS), DKB)
fill(old * shadow - bench, DKB)
fill(old * LQ - core - ms - bench - shadow, A)
fill(old * core - ms - bench - shadow, B)
fill(old * ms * LQ - bench - shadow, MS)

--@ chunk 14
print(wait(6*24*60))
local function L(p, pts, pr_, w, clipm) local b = brush{kind="rigger", width=w or 0.8, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_*0.5, pr_, pr_*0.5}, clip=clipm}) end
local DK = pile{{"bone black",2.4},{"bone brown",0.5}}
local BRZD = pile{{"bone brown",1.2},{"raw sienna",0.5},{"bone black",1.1}}
local BRZL = pile{{"raw sienna",1},{"yellow ochre",0.5},{"bone brown",0.4},{"lead white",0.3}}
-- sleeves: from the shoulders down to the folded hands
local sb = brush{kind="filbert", width=5, stiffness=0.5}
sb:load(BRZD, 0.9) sb:stroke({{508, 360}, {503, 378}, {514, 394}}, {pressure={0.8, 0.7}, clip=ROBE})
sb:load(BRZL, 0.9) sb:stroke({{542, 360}, {547, 378}, {536, 396}}, {pressure={0.8, 0.7}, clip=ROBE})
L(DK, {{503, 362}, {499, 380}, {510, 398}}, 0.5, 0.8, ROBE:grow(0.5))
-- the lap: knees forward, a fold under them, the hem breaking over two feet
L(DK, {{498, 404}, {512, 408}, {525, 406}, {538, 408}, {553, 404}}, 0.6, 1.1)
L(BRZL, {{530, 402}, {540, 404}, {552, 401}}, 0.45, 0.9)
L(DK, {{514, 410}, {512, 430}}, 0.45, 0.8) L(DK, {{536, 410}, {539, 430}}, 0.45, 0.8)
local FT = pile{{"bone brown",1},{"bone black",1},{"raw sienna",0.3}}
local fb = brush{kind="filbert", width=4, stiffness=0.6}
fb:load(FT, 0.9) fb:stroke({{508, 433}, {520, 434}}, {pressure={0.7, 0.7}})
fb:load(FT, 0.9) fb:stroke({{531, 434}, {543, 433}}, {pressure={0.7, 0.7}})
-- the Commando: visor slit, helm crest, pauldron and gauntlet plates
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local MG = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.28}}
L(JD, {{354, 304}, {366, 309}}, 0.7, 1.2, CMD)
L(MG, {{340, 296}, {352, 292}, {362, 298}}, 0.4, 0.7, CMD)
L(MG, {{331, 324}, {358, 320}}, 0.45, 0.7, CMD)
L(JD, {{332, 334}, {362, 330}}, 0.5, 0.7, CMD)
L(JD, {{345, 372}, {360, 372}}, 0.5, 0.7, CMD)
L(MG, {{334, 330}, {336, 388}}, 0.35, 0.6, CMD)
L(JD, {{340, 455}, {354, 455}}, 0.45, 0.6, CMD) L(JD, {{357, 455}, {374, 455}}, 0.45, 0.6, CMD)
