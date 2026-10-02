-- easel session "death_shrine": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=1517, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"raw sienna",0.8},{"bone brown",0.8},{"bone black",0.5},{"yellow ochre",0.2},{"lead white",0.3}}, um=45, apply="brush", texture=0.35}}}
VP = {690, 255}
FAR = {650, 220, 730, 290}
FLOOR = poly({{-40, 600}, {1040, 600}, {FAR[3], FAR[4]}, {FAR[1], FAR[4]}})
RWALL = poly({{1040, -40}, {1040, 600}, {FAR[3], FAR[4]}, {FAR[3], FAR[2]}})
LWALL = poly({{-40, -40}, {FAR[1], FAR[2]}, {FAR[1], FAR[4]}, {-40, 600}})
CEIL = poly({{-40, -40}, {1040, -40}, {FAR[3], FAR[2]}, {FAR[1], FAR[2]}})
FL = pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.6},{"lead white",0.22}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR, {hand="body", pile=FL, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
-- the hazard lamp's amber falls on the right wall
AW = pile{{"raw sienna",0.8},{"yellow ochre",0.5},{"lead white",0.6},{"bone black",0.2}}
local wash = (ellipse(880, 190, 170, 150):soften(40)) * RWALL
work(wash, {hand="body", pile=AW, coverage=2.5, fill=true, clip=RWALL, angle=toVP, length={15, 35}, tool="filbert 8", edge="lost"})

--@ chunk 2
print(wait(3*24*60), drying(880,190))
LAMP = {905, 128}
WL = {
 pile{{"raw sienna",0.8},{"bone brown",0.8},{"bone black",0.5},{"yellow ochre",0.2},{"lead white",0.3}},
 pile{{"raw sienna",0.8},{"bone brown",0.5},{"yellow ochre",0.3},{"bone black",0.35},{"lead white",0.4}},
 pile{{"yellow ochre",0.7},{"raw sienna",0.6},{"bone black",0.25},{"lead white",0.55}},
 pile{{"yellow ochre",0.8},{"raw sienna",0.4},{"lead white",0.8},{"bone black",0.12}},
 pile{{"lead white",1.3},{"yellow ochre",0.6},{"cadmium yellow",0.1}},
}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local cells = {}
for y = -4, 400, 3.2 do for x = 700, 1004, 3.2 do
  local xx, yy = x + rand(-1.4,1.4), y + rand(-1.4,1.4)
  if RWALL:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx, dy = xx - LAMP[1], (yy - LAMP[2])*0.85
    local d = math.sqrt(dx*dx + dy*dy)
    if d < 300 then
      local t = 5 - d/62 + randn(0, 0.35)
      cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 0.5), 1, 5)}
    end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 5 do if g[i] then
  b:reload(WL[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(WL[i], 0.9) end
    local a = toVP(c.x, c.y) + randn(0, 0.05)
    local h = rand(4, 8)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, ramps={0.15, 0.3}, clip=RWALL})
  end
end end
print(#cells)

--@ chunk 3
print(wait(5*24*60))
function limb(pts, w0, w1)
  local L, R = {}, {}
  for i, p in ipairs(pts) do
    local a = pts[math.min(i+1, #pts)] local b = pts[math.max(i-1, 1)]
    local dx, dy = a[1] - b[1], a[2] - b[2] local l = math.sqrt(dx*dx + dy*dy) + 1e-6
    local w = w0 + (w1 - w0)*(i-1)/(#pts-1)
    L[#L+1] = {p[1] - dy/l*w, p[2] + dx/l*w} R[#R+1] = {p[1] + dy/l*w, p[2] - dx/l*w}
  end
  local out = {} for _, p in ipairs(L) do out[#out+1] = p end for i = #R, 1, -1 do out[#out+1] = R[i] end
  return poly(out, true)
end
SHD = pile{{"bone black",2.5},{"ultramarine blue",0.4}}
MD = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.1}}

local floorc = FLOOR
-- deck grating: rails converging on the far end, cross bars closing up with distance
local GD = pile{{"bone black",1.6},{"bone brown",0.8},{"lead white",0.05}}
local GL = pile{{"raw sienna",0.6},{"yellow ochre",0.3},{"lead white",0.5},{"bone black",0.3}}
local r = brush{kind="rigger", width=0.7, point=1}
for x = -500, 1600, 38 do
  local a = {x, 600}
  local b = {VP[1] + (x - VP[1])*0.1, VP[2] + (600 - VP[2])*0.1}
  r:load(GD, 0.8) r:stroke({a, b}, {pressure={0.6, 0.15}, clip=floorc})
  r:load(GL, 0.7) r:stroke({{a[1] + 3, a[2]}, {b[1] + 0.3, b[2]}}, {pressure={0.3, 0.08}, clip=floorc})
end
local z = 1.0
while z < 9 do
  local y = VP[2] + (600 - VP[2])/z
  r:load(GD, 0.8) r:stroke({{-40, y}, {1040, y}}, {pressure={clamp(0.7/z, 0.12, 0.7), clamp(0.7/z, 0.12, 0.7)}, clip=floorc})
  z = z * 1.16
end
-- wall ribs and a rail on both walls
local function wallpt(side, t, h)  -- t: 0 near .. 1 far; h: 0 floor .. 1 ceiling
  local nx = (side < 0) and -40 or 1040
  local fx = (side < 0) and FAR[1] or FAR[3]
  local x = nx + (fx - nx)*t
  local ybot = 600 + (FAR[4] - 600)*t
  local ytop = -40 + (FAR[2] + 40)*t
  return {x, ybot + (ytop - ybot)*h}
end
local RB = pile{{"bone black",1.4},{"bone brown",1},{"raw sienna",0.2}}
local RL = pile{{"bone brown",0.8},{"raw sienna",0.5},{"lead white",0.4},{"bone black",0.3}}
for _, side in ipairs({-1, 1}) do
  local wall = (side < 0) and LWALL or RWALL
  local t = 0.08
  while t < 0.97 do
    local w = clamp(2.6*(1 - t), 0.6, 2.6)
    local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
    rb:load(RB, 0.9) rb:stroke({wallpt(side, t, 0.02), wallpt(side, t, 0.98)}, {pressure={0.7, 0.7}, clip=wall})
    local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
    rl:load(RL, 0.8) rl:stroke({wallpt(side, t + 0.004, 0.02), wallpt(side, t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=wall})
    t = t + 0.1*(1 - t*0.85)
  end
  local rail = brush{kind="filbert", width=3, stiffness=0.5}
  rail:load(RB, 0.9) rail:stroke({wallpt(side, 0, 0.42), wallpt(side, 1, 0.42)}, {pressure={0.8, 0.2}, clip=wall})
end
-- the lamp housing on the right wall
local hous = poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true)
work(hous, {hand="detail", pile=SHD, coverage=4, fill=true, clip=hous, tool={kind="round", width=1.2}, length={2, 4}})

--@ chunk 4
local CP = pile{{"bone brown",1},{"bone black",0.8},{"raw sienna",0.3},{"lead white",0.15}}
work(CEIL, {hand="body", pile=CP, coverage=3.2, fill=true, clip=CEIL, angle=function(x,y) return math.atan(VP[2] - y, VP[1] - x) end, length={25, 60}, tool="filbert 9"})
-- the far end: a dark doorway with the seed's faint warm glow deep beyond it
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
work(door, {hand="detail", pile=pile{{"bone brown",1},{"bone black",1},{"raw sienna",0.2}}, coverage=4, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 5
print(wait(5*24*60), drying(400,60), drying(690,260))
-- edges between planes
local ED = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.22}}
local r = brush{kind="rigger", width=0.9, point=1}
r:load(ED, 0.8) r:stroke({{-40, -40}, {FAR[1], FAR[2]}}, {pressure={0.6, 0.2}})
r:load(ED, 0.8) r:stroke({{FAR[1], FAR[2]}, {FAR[3], FAR[2]}}, {pressure={0.2, 0.2}})
r:load(ED, 0.8) r:stroke({{-40, 600}, {FAR[1], FAR[4]}}, {pressure={0.6, 0.2}})
-- seed glow beyond the door: very faint, warm
local GW = pile{{"Mars orange",1},{"burnt sienna",0.6},{"bone black",0.7},{"lead white",0.1}}
local GW2 = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"lead white",0.35},{"bone black",0.2}}
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
local g1 = ellipse(690, 284, 22, 10):soften(5) * door
work(g1, {hand="detail", pile=GW, coverage=3, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})
local g = brush{kind="round", width=2.2, point=0.2}
g:load(GW2, 0.9) g:touch(690, 287, {pressure=0.5})
-- the working light where the hazard lamp was: a warm white panel
local LT = pile{{"lead white",2.2},{"cadmium yellow",0.3},{"Mars orange",0.05}}
local LH = pile{{"bone brown",1},{"bone black",1}}
work(rect(886, 112, 40, 26), {hand="detail", pile=LH, coverage=5, fill=true, clip=rect(886, 112, 40, 26), tool={kind="round", width=1.2}, length={2, 5}})
work(rect(890, 116, 32, 18), {hand="detail", pile=LT, coverage=5, fill=true, clip=rect(890, 116, 32, 18), tool={kind="round", width=1.2}, length={2, 5}})
print(wait(5*24*60))
-- the far glow, much quieter: a dim warm floor-spill with one small warmer core
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
local DIM = pile{{"burnt sienna",0.6},{"bone black",1.4},{"Mars orange",0.3},{"ultramarine blue",0.1}}
local gm = ellipse(690, 284, 26, 12) * door
work(gm, {hand="detail", pile=DIM, coverage=4, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})
local GW2 = pile{{"Mars orange",1},{"burnt sienna",0.4},{"lead white",0.2},{"bone black",0.3}}
local g = brush{kind="filbert", width=3, stiffness=0.5}
g:load(GW2, 0.9) g:stroke({{682, 288}, {698, 288}}, {pressure={0.5, 0.5}, clip=door})

--@ chunk 6
print(wait(8*24*60), drying(420,480), drying(400,300))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- a bronze plate set into the grating where he fell, an inscription in bone-coloured marks
local BZ = pile{{"raw sienna",1},{"bone brown",0.6},{"yellow ochre",0.4},{"bone black",0.3},{"lead white",0.15}}
local BZD = pile{{"bone brown",1},{"bone black",0.9},{"raw sienna",0.3}}
local BZL = pile{{"yellow ochre",0.8},{"raw sienna",0.4},{"lead white",0.8}}
PLATE = poly({{360, 486}, {520, 470}, {556, 506}, {380, 528}})
fill(PLATE:grow(2), BZD)
fill(PLATE, BZ, "round 1.6")
local r = brush{kind="rigger", width=1.1, point=1}
r:load(BZL, 0.9) r:stroke({{362, 485}, {520, 469}}, {pressure={0.6, 0.6}})
local INS = pile{{"bone brown",1},{"bone black",1.1}}
for row = 0, 2 do
  local y0 = 486 + row*9
  local x = 384 + row*4
  while x < 520 - row*1 do
    local L = rand(3, 9)
    local t = (x - 360)/200
    r = brush{kind="rigger", width=1.0, point=1}
    r:load(INS, 0.9) r:stroke({{x, y0 - t*14 + row*1.5}, {x + L, y0 - (t + L/200)*14 + row*1.5}}, {pressure={0.6, 0.6}, clip=PLATE:shrink(2)})
    x = x + L + rand(2, 4)
  end
end
-- a cross cut into the plate's left end
r:load(INS, 0.9) r:stroke({{372, 494}, {374, 516}}, {pressure={0.7, 0.7}})
r:load(INS, 0.9) r:stroke({{366, 501}, {381, 500}}, {pressure={0.7, 0.7}})
-- the visor mounted on the left wall above, a scrap of crimson tied to it
local VIS = pile{{"bone black",1.6},{"ultramarine blue",0.4},{"lead white",0.3}}
local VISL = pile{{"lead white",1.1},{"ultramarine ash",0.3},{"bone black",0.4}}
local vis = poly({{368, 280}, {418, 268}, {428, 290}, {412, 312}, {380, 318}, {364, 302}}, true)
local crack = poly({{404, 270}, {410, 270}, {398, 316}, {392, 316}}, false)
fill(vis - crack, VIS)
fill(poly({{376, 292}, {414, 284}, {416, 292}, {378, 300}}), pile{{"bone black",2.4},{"bone brown",0.3}}, "round 0.8")
r = brush{kind="rigger", width=1.0, point=1}
r:load(VISL, 0.9) r:stroke({{370, 280}, {404, 271}}, {pressure={0.5, 0.4}})
r:load(VISL, 0.9) r:stroke({{410, 271}, {418, 268}, {428, 290}}, {pressure={0.5, 0.4}})
local BK = pile{{"bone brown",1},{"bone black",1.2}}
fill(rect(388, 258, 14, 8), BK, "round 0.8")
local CR = pile{{"Mars red",0.7},{"rose madder",0.6},{"bone black",0.6}}
local CRL = pile{{"cadmium red",0.6},{"Mars red",0.5},{"lead white",0.25}}
local rag = poly({{414, 300}, {426, 296}, {432, 330}, {424, 346}, {420, 332}, {414, 344}, {410, 318}}, true)
fill(rag, CR)
r:load(CRL, 0.9) r:stroke({{424, 298}, {428, 324}}, {pressure={0.4, 0.3}})
-- a child's drawing of a knight taped beside it
local PAPER = pile{{"lead white",2.2},{"yellow ochre",0.08}}
local sheet = poly({{306, 300}, {350, 294}, {354, 346}, {310, 352}})
fill(sheet, PAPER)
fill(poly({{318, 293}, {336, 291}, {337, 298}, {319, 300}}), pile{{"lead white",1.4},{"yellow ochre",0.3}}, "round 0.8")

--@ chunk 7
print(wait(8*24*60), drying(330,320), drying(450,480))
local r
local function cr(p, pts, w) r = brush{kind="rigger", width=w or 1.3, point=0.8} r:load(p, 0.9) r:stroke(pts, {pressure={0.6, 0.55}, ramps={0.03, 0.03}}) end
local BL = pile{{"bone black",2}}
local RD = pile{{"cadmium red",1},{"lead white",0.2}}
local YE = pile{{"cadmium yellow",1},{"lead white",0.2}}
local GR = pile{{"cobalt blue",0.8},{"lead white",0.6}}
-- the knight: grey helmet, red tabard with a white cross, stick legs, a sword, a yellow sun
cr(GR, {{326, 306}, {334, 305}, {335, 314}, {327, 315}, {326, 306}}, 1.6)
cr(RD, {{322, 318}, {340, 316}, {342, 334}, {324, 336}, {322, 318}}, 2.2)
cr(RD, {{326, 322}, {338, 321}}, 2.6) cr(RD, {{326, 328}, {338, 327}}, 2.6)
cr(pile{{"lead white",2}}, {{331, 319}, {332, 333}}, 1.1) cr(pile{{"lead white",2}}, {{327, 324}, {337, 323}}, 1.1)
cr(BL, {{327, 336}, {326, 346}}, 1.2) cr(BL, {{338, 335}, {339, 345}}, 1.2)
cr(GR, {{342, 320}, {348, 304}}, 1.1) cr(GR, {{344, 312}, {349, 314}}, 1.1)
cr(YE, {{312, 302}, {316, 300}, {318, 304}, {314, 307}, {312, 302}}, 1.4)
-- the tin of bone-flowers, and the candle-LED, on the grating at the plate's edge
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local TIN = pile{{"lead white",0.8},{"ultramarine ash",0.4},{"bone black",0.5}}
local TINL = pile{{"lead white",1.4},{"ultramarine ash",0.2},{"yellow ochre",0.1}}
fill(poly({{526, 452}, {548, 450}, {549, 478}, {527, 480}}, true), TIN)
r = brush{kind="rigger", width=1.2, point=1} r:load(TINL, 0.9) r:stroke({{528, 454}, {529, 476}}, {pressure={0.5, 0.5}})
fill(ellipse(537, 451, 11, 3), pile{{"bone black",1.6},{"ultramarine ash",0.3}})
local BONE = pile{{"lead white",1.5},{"yellow ochre",0.35},{"raw sienna",0.1}}
local STM = pile{{"bone brown",0.8},{"raw sienna",0.4},{"lead white",0.3}}
for i, f in ipairs({{530, 420}, {538, 412}, {546, 422}, {534, 430}, {544, 434}}) do
  r = brush{kind="rigger", width=0.8, point=1} r:load(STM, 0.9) r:stroke({{537 + (f[1] - 537)*0.3, 449}, f}, {pressure={0.5, 0.4}})
  for k = 0, 5 do local a = k/6*2*math.pi local p = brush{kind="round", width=2.2, point=0.5} p:load(BONE, 0.9) p:stroke({{f[1], f[2]}, {f[1] + math.cos(a)*3.5, f[2] + math.sin(a)*3}}, {pressure={0.6, 0.2}}) end
end
local CB = pile{{"lead white",1.6},{"yellow ochre",0.2},{"bone black",0.1}}
fill(rect(504, 470, 7, 12), CB, "round 0.8")

--@ chunk 8
print(wait(6*24*60))
local GL = pile{{"Mars orange",0.4},{"cadmium yellow",0.4},{"lead white",1}}
local g = brush{kind="filbert", width=1.6, stiffness=0.4}
for k = 0, 15 do local a = k/16*2*math.pi g:load(GL, 0.55) g:stroke({{507.5 + math.cos(a)*2, 465 + math.sin(a)*2.4}, {507.5 + math.cos(a)*6.5, 465 + math.sin(a)*7}}, {pressure={0.45, 0.05}}) end
local f = brush{kind="round", width=2.4, point=0.9}
f:load(pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.15}}, 0.95) f:stroke({{507.5, 469.5}, {507.6, 465}, {507.4, 461}}, {pressure={0.85, 0}})
local h = brush{kind="round", width=1.3, point=0.5}
h:load(pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}}, 0.95) h:touch(507.5, 467, {pressure=0.6})
-- warm candle-glow on the plate's near edge and the tin
local WG = pile{{"yellow ochre",0.6},{"Mars orange",0.3},{"lead white",0.9}}
local r = brush{kind="rigger", width=1.0, point=1}
r:load(WG, 0.8) r:stroke({{470, 474}, {500, 471}}, {pressure={0.35, 0.2}})
r:load(WG, 0.8) r:stroke({{527, 460}, {527, 474}}, {pressure={0.35, 0.2}})

--@ chunk 9
print(wait(6*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- the light fixture: the dark ragged surround replaced by a clean housing and a soft warm bloom
local around = ellipse(906, 125, 26, 22) * RWALL - rect(886, 112, 40, 26)
fill(around, WL[5], "round 1.4")
local GL = pile{{"lead white",1.6},{"yellow ochre",0.5},{"cadmium yellow",0.1}}
local s = brush{kind="filbert", width=2.4, stiffness=0.4}
for k = 0, 23 do local a = k/24*2*math.pi s:load(GL, 0.5) s:stroke({{906 + math.cos(a)*22, 125 + math.sin(a)*15}, {906 + math.cos(a)*32, 125 + math.sin(a)*22}}, {pressure={0.4, 0.05}, clip=RWALL - rect(884, 110, 44, 30)}) end
local r = brush{kind="rigger", width=1.2, point=1}
local HB = pile{{"bone brown",1},{"bone black",0.8},{"lead white",0.1}}
for _, s2 in ipairs({{{886, 112}, {926, 112}}, {{926, 112}, {926, 138}}, {{926, 138}, {886, 138}}, {{886, 138}, {886, 112}}}) do r:load(HB, 0.9) r:stroke(s2, {pressure={0.6, 0.6}, ramps={0.02, 0.02}}) end
-- the plate's inscription, cut deeper; and a bright lip along its far edge
local INS = pile{{"bone black",2},{"bone brown",0.4}}
local function rowline(y0, x0, x1)
  local x = x0
  while x < x1 do
    local L = rand(4, 10)
    local t0, t1 = (x - 360)/196, (x + L - 360)/196
    local b = brush{kind="filbert", width=1.8, stiffness=0.6}
    b:load(INS, 0.9) b:stroke({{x, y0 - t0*16}, {x + L, y0 - t1*16}}, {pressure={0.75, 0.75}, ramps={0.02, 0.02}, clip=PLATE:shrink(3)})
    x = x + L + rand(2.5, 4.5)
  end
end
rowline(496, 392, 512) rowline(506, 396, 520) rowline(516, 400, 528)
local BZL = pile{{"yellow ochre",0.8},{"raw sienna",0.3},{"lead white",1}}
r = brush{kind="rigger", width=1.4, point=1}
r:load(BZL, 0.9) r:stroke({{364, 486}, {518, 470}, {552, 504}}, {pressure={0.55, 0.55}})
