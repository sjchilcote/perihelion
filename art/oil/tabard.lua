-- easel session "tabard": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=1409, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}, um=45, apply="brush", texture=0.35}}}
VP = {690, 255}
FAR = {650, 220, 730, 290}
FLOOR = poly({{-40, 600}, {1040, 600}, {FAR[3], FAR[4]}, {FAR[1], FAR[4]}})
RWALL = poly({{1040, -40}, {1040, 600}, {FAR[3], FAR[4]}, {FAR[3], FAR[2]}})
LWALL = poly({{-40, -40}, {FAR[1], FAR[2]}, {FAR[1], FAR[4]}, {-40, 600}})
CEIL = poly({{-40, -40}, {1040, -40}, {FAR[3], FAR[2]}, {FAR[1], FAR[2]}})
FL = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.4},{"lead white",0.12}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR, {hand="body", pile=FL, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
-- the hazard lamp's amber falls on the right wall
AW = pile{{"bone black",1},{"Mars orange",0.45},{"raw sienna",0.4},{"lead white",0.12}}
local wash = (ellipse(880, 190, 170, 150):soften(40)) * RWALL
work(wash, {hand="body", pile=AW, coverage=2.5, fill=true, clip=RWALL, angle=toVP, length={15, 35}, tool="filbert 8", edge="lost"})

--@ chunk 2
print(wait(3*24*60), drying(880,190))
LAMP = {905, 128}
WL = {
 pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}},
 pile{{"bone black",2},{"Mars brown",0.6},{"burnt sienna",0.3},{"ultramarine blue",0.3},{"lead white",0.06}},
 pile{{"bone black",1.4},{"burnt sienna",0.6},{"Mars orange",0.25},{"lead white",0.08}},
 pile{{"bone black",0.9},{"burnt sienna",0.6},{"Mars orange",0.45},{"lead white",0.14}},
 pile{{"Mars orange",0.8},{"burnt sienna",0.4},{"bone black",0.5},{"lead white",0.25}},
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
local GD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GL = pile{{"bone black",1.4},{"ultramarine blue",0.3},{"Mars brown",0.3},{"lead white",0.25}}
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
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
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
local CP = pile{{"bone black",2.6},{"ultramarine blue",0.6},{"Mars brown",0.2},{"lead white",0.03}}
work(CEIL, {hand="body", pile=CP, coverage=3.2, fill=true, clip=CEIL, angle=function(x,y) return math.atan(VP[2] - y, VP[1] - x) end, length={25, 60}, tool="filbert 9"})
-- the far end: a dark doorway with the seed's faint warm glow deep beyond it
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
work(door, {hand="detail", pile=SHD, coverage=4, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})

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
-- the hazard lamp: amber lens in its housing
local AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.35}}
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.2}}
local l = brush{kind="filbert", width=6, stiffness=0.5}
l:load(AMB, 0.95) l:stroke({{898, 126}, {914, 124}}, {pressure={0.8, 0.8}})
local h = brush{kind="round", width=2.4, point=0.3}
h:load(AH, 0.95) h:touch(905, 124, {pressure=0.7})
-- hazard chevrons on the right wall low
local CH = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"bone black",0.35}}
local c = brush{kind="round", width=1.6, point=0.4}
for i = 0, 4 do
  local x = 870 + i*22
  c:load(CH, 0.9) c:stroke({{x, 395 + i*12}, {x + 9, 384 + i*12}, {x + 18, 395 + i*12}}, {pressure={0.6, 0.6}, clip=RWALL})
end

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
print(wait(4*24*60))
GO = {300, 505}
GA_ = {0.96, -0.28}
GN = {0.28, 0.96}
function G(u, v) return {GO[1] + u*GA_[1] + v*GN[1], GO[2] + u*GA_[2] + v*GN[2]} end
function gpoly(uv, dv, smooth) local p = {} for _, q in ipairs(uv) do p[#p+1] = G(q[1], q[2] + (dv or 0)) end return poly(p, smooth) end
function glimb(uv, w0, w1, dv)
  local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = G(q[1], q[2] + (dv or 0)) end
  return limb(pts, w0, w1)
end
PARTS = {
 legA = function(dv) return glimb({{150, -18}, {80, -26}, {12, -22}}, 9, 7, dv) end,
 footA = function(dv) return gpoly({{-10, -36}, {14, -34}, {14, -12}, {-8, -12}}, dv, true) end,
 thighB = function(dv) return glimb({{158, 12}, {100, 40}}, 11, 9, dv) end,
 shinB = function(dv) return glimb({{100, 40}, {116, 62}, {132, 80}}, 8, 7, dv) end,
 footB = function(dv) return gpoly({{122, 80}, {146, 78}, {148, 96}, {126, 98}}, dv, true) end,
 pelvis = function(dv) return gpoly({{130, -30}, {178, -32}, {182, 24}, {132, 26}}, dv, true) end,
 torso = function(dv) return gpoly({{175, -42}, {250, -50}, {292, -38}, {298, 20}, {272, 40}, {185, 34}}, dv, true) end,
 neck = function(dv) return glimb({{290, -6}, {310, -4}}, 7, 7, dv) end,
 helm = function(dv) return gpoly({{305, -26}, {336, -31}, {353, -14}, {351, 14}, {330, 25}, {306, 16}}, dv, true) end,
 farArm = function(dv) return glimb({{250, -48}, {215, -62}, {176, -58}}, 8, 6, dv) end,
 nearArm = function(dv) return glimb({{285, 26}, {335, 78}, {392, 104}}, 10, 8, dv) end,
 hand = function(dv) return gpoly({{388, 94}, {408, 92}, {414, 112}, {396, 120}}, dv, true) end,
 paul = function(dv) return gpoly({{266, 20}, {300, 12}, {320, 40}, {294, 58}, {268, 46}}, dv, true) end,
}
PORDER = {"legA", "footA", "farArm", "thighB", "shinB", "footB", "pelvis", "torso", "neck", "helm", "nearArm", "hand", "paul"}
local all = nil
for _, k in ipairs(PORDER) do local m = PARTS[k](0) all = all and (all + m) or m end
FRAME = all

FB = {560, 470}
function P(u, v) return {FB[1] + u, FB[2] - v} end
function pp(t, smooth) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, smooth) end
FP = {
 footL = {{-28, 0}, {-6, 0}, {-6, 9}, {-24, 10}},
 footR = {{8, 2}, {34, 0}, {32, 10}, {10, 11}},
 greaveL = {{-25, 9}, {-8, 9}, {-7, 72}, {-24, 74}},
 greaveR = {{10, 10}, {29, 9}, {28, 74}, {11, 74}},
 kneeL = {{-27, 70}, {-6, 70}, {-5, 86}, {-26, 86}},
 kneeR = {{8, 72}, {31, 71}, {30, 88}, {9, 88}},
 cuisseL = {{-28, 84}, {-5, 84}, {-3, 132}, {-30, 132}},
 cuisseR = {{6, 86}, {30, 86}, {32, 132}, {4, 132}},
 faulds = {{-36, 124}, {36, 124}, {32, 152}, {-32, 152}},
 torso = {{-34, 148}, {34, 148}, {40, 212}, {-40, 210}},
 gorget = {{-16, 210}, {16, 210}, {14, 228}, {-14, 228}},
 helm = {{-17, 224}, {4, 222}, {20, 230}, {22, 250}, {12, 264}, {-10, 265}, {-20, 250}},
 paulL = {{-56, 186}, {-34, 182}, {-24, 210}, {-36, 222}, {-56, 214}},
 paulR = {{30, 186}, {54, 188}, {58, 214}, {44, 224}, {26, 212}},
 armLu = {{-58, 150}, {-42, 150}, {-40, 188}, {-56, 190}},
 armLv = {{-60, 100}, {-44, 100}, {-42, 152}, {-58, 152}},
 gauntL = {{-62, 80}, {-44, 80}, {-43, 102}, {-61, 102}},
 armRu = {{40, 196}, {54, 188}, {72, 228}, {60, 236}},
 armRf = {{60, 226}, {72, 236}, {44, 262}, {34, 252}},
 handR = {{30, 248}, {44, 246}, {46, 262}, {32, 266}},
}
FORD = {"footL","footR","greaveL","greaveR","kneeL","kneeR","cuisseL","cuisseR","faulds","torso","armLu","armLv","gauntL","paulL","gorget","helm","armRu","armRf","paulR","handR"}
local a = nil
for _, k in ipairs(FORD) do local m = pp(FP[k], true) a = a and (a + m) or m end
FIG = a
FRAME = FIG

--@ chunk 7
print(wait(4*24*60))
-- the lamp's amber reaching the deck along the right wall
local FA1 = pile{{"bone black",1.8},{"Mars brown",0.5},{"burnt sienna",0.35},{"lead white",0.1}}
local FA2 = pile{{"bone black",1.3},{"burnt sienna",0.55},{"Mars orange",0.25},{"lead white",0.12}}
local ON = FRAME:grow(2)
local cells = {}
for y = 290, 566, 3 do for x = 660, 1004, 3.2 do
  local xx, yy = x + rand(-1.3,1.3), y + rand(-1.3,1.3)
  if FLOOR:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 and ON:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    -- distance from the wall-floor line, measured across the floor
    local t = (yy - VP[2]) / (600 - VP[2])
    local xwall = VP[1] + (1040 - VP[1])*t
    local d = (xwall - xx) / (t*350 + 1)
    local dl = math.abs(yy - 360)/200
    local v = 2.3 - d*3.2 - dl + randn(0, 0.3)
    if v > 0.5 then cells[#cells+1] = {x=xx, y=yy, i=(v > 1.4) and 2 or 1} end
  end
end end
local P = {FA1, FA2}
local g = {}
for _, c2 in ipairs(cells) do g[c2.i] = g[c2.i] or {} table.insert(g[c2.i], c2) end
local fb = brush{kind="filbert", width=3, stiffness=0.5}
for i = 1, 2 do if g[i] then
  fb:reload(P[i], 0.9)
  for n, c2 in ipairs(g[i]) do
    if n % 4 == 0 then fb:load(P[i], 0.9) end
    local a = math.atan(VP[2] - c2.y, VP[1] - c2.x) + randn(0, 0.05)
    local h = rand(3, 6)
    fb:stroke({{c2.x - math.cos(a)*h, c2.y - math.sin(a)*h}, {c2.x + math.cos(a)*h, c2.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=FLOOR - ON})
  end
end end
print(#cells)

--@ chunk 8
print(wait(4*24*60))
local ON = FRAME:grow(2)
local cells = {}
for y = 290, 566, 2.8 do for x = 700, 1004, 3.0 do
  local xx, yy = x + rand(-1.3,1.3), y + rand(-1.3,1.3)
  if FLOOR:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 and ON:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    local t = (yy - VP[2]) / (600 - VP[2])
    local xwall = VP[1] + (1040 - VP[1])*t
    local d = (xwall - xx) / (t*350 + 1)
    -- keep the pool under the lamp (y about 380-460 at the wall); return the rest, and the inner edge, to dark deck
    local keep = math.exp(-((yy - 420)/55)^2) * clamp(1.3 - d*2.2, 0, 1)
    if rand(0,1) > keep + 0.12 then cells[#cells+1] = {x=xx, y=yy} end
  end
end end
local fb = brush{kind="filbert", width=3, stiffness=0.5}
fb:reload(FL, 0.9)
for n, c in ipairs(cells) do
  if n % 4 == 0 then fb:load(FL, 0.9) end
  local a = math.atan(VP[2] - c.y, VP[1] - c.x) + randn(0, 0.05)
  local h = rand(3, 6)
  fb:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=FLOOR - ON})
end
print(#cells)

--@ chunk 9
print(wait(6*24*60))
-- the scorch where the first frame lay: a ragged burnt outline on the grating, ash inside
local body = nil
for _, k in ipairs(PORDER) do local m = PARTS[k](0) body = body and (body + m) or m end
body = body:roughen(3, 14, 77)
local ring = (body:grow(4) - body:shrink(4)) * FLOOR
local inner = body:shrink(4) * FLOOR
local SC = pile{{"bone black",2.2},{"burnt sienna",0.4},{"Mars brown",0.3}}
local ASH = pile{{"bone black",1.2},{"Mars brown",0.4},{"lead white",0.2},{"ultramarine blue",0.2}}
work(inner, {hand="detail", pile=ASH, coverage=3, fill=true, clip=inner, tool={kind="round", width=1.6}, length={2, 6}, angle=0.3})
work(ring, {hand="detail", pile=SC, coverage=4, fill=true, clip=ring, tool={kind="round", width=1.4}, length={2, 5}, angle=0.3})
SCORCH = body
-- a few casings left
local BR = pile{{"raw sienna",1},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.1}}
local BG = pile{{"lead white",1.2},{"yellow ochre",0.6},{"Mars orange",0.2}}
local cs = brush{kind="round", width=1.5, point=0.3}
local gl = brush{kind="round", width=0.8, point=0.3}
for i = 1, 9 do
  local x, y = rand(330, 760), rand(440, 556)
  if FIG:grow(4):at(x, y) < 0.1 then
    local a = rand(0, math.pi)
    local L = 2.6 + (y - 380)*0.014
    cs:load(BR, 0.9) cs:stroke({{x - math.cos(a)*L/2, y - math.sin(a)*L/2}, {x + math.cos(a)*L/2, y + math.sin(a)*L/2}}, {pressure={0.6, 0.6}})
    if i % 2 == 0 then gl:load(BG, 0.9) gl:touch(x + math.cos(a)*L*0.3, y + math.sin(a)*L*0.3 - 0.5, {pressure=0.4}) end
  end
end
-- the standing frame's shadow, thrown down and left across the deck, and its core in lean dark grey
local sh = poly({P(-30, 2), P(36, 2), P(-60, -60), P(-140, -70)}, true) * FLOOR - FIG
work(sh:soften(3), {hand="body", pile=SHD, coverage=3, fill=true, clip=FLOOR - FIG, angle=2.5, length={8, 16}, tool="filbert 5"})
NC2 = pile{{"lead white",0.22},{"bone black",1},{"ultramarine blue",0.3}}
work(FIG, {hand="detail", pile=NC2, coverage=5, fill=true, clip=FIG, tool={kind="round", width=1.6}, length={2, 6}})

--@ chunk 10
print(wait(8*24*60), drying(560,350))
function ppo(t, du, dv) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1] + du, q[2] + dv) end return poly(o, true) end
NG2 = pile{{"lead white",0.6},{"bone black",0.8},{"ultramarine blue",0.25},{"yellow ochre",0.05}}
local mid = nil
for _, k in ipairs(FORD) do local m = ppo(FP[k], 0, 0) - ppo(FP[k], -5, -6) mid = mid and (mid + m) or m end
mid = mid * FIG
work(mid, {hand="detail", pile=NG2, coverage=4.5, fill=true, clip=mid, tool={kind="round", width=1.1}, length={2, 4}})

--@ chunk 11
print(wait(8*24*60), drying(560,350))
local JD = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local NH = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.2}}
local r
local function ln(p, uv, pr, w) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.85}, clip=FIG:grow(0.5)}) end
-- separations between plates
for _, s in ipairs({
  {{-27, 72}, {-6, 72}}, {{9, 74}, {30, 74}}, {{-28, 86}, {-5, 86}}, {{8, 88}, {31, 88}},
  {{-31, 132}, {32, 132}}, {{-36, 125}, {36, 125}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-14, 224}, {14, 224}},
  {{-42, 151}, {-58, 151}}, {{-43, 101}, {-61, 101}}, {{-7, 12}, {-7, 70}},
}) do ln(JD, s, 0.55, 0.9) end
-- fauld lames, gorget rings, pauldron lames
for _, v in ipairs({138, 145}) do ln(JD, {{-35, v}, {0, v - 1}, {34, v}}, 0.45, 0.7) end
for _, v in ipairs({215, 220}) do ln(JD, {{-15, v}, {15, v}}, 0.4, 0.6) end
for _, o in ipairs({0, 8}) do ln(JD, {{-55, 196 + o}, {-42, 190 + o}, {-28, 196 + o}}, 0.45, 0.7) end
for _, o in ipairs({0, 8}) do ln(JD, {{30, 198 + o}, {44, 194 + o}, {57, 200 + o}}, 0.45, 0.7) end
-- greave and cuisse ridges, lit along their lamp side
ln(JD, {{-16, 12}, {-16, 70}}, 0.4, 0.6) ln(NH, {{-14, 12}, {-14, 70}}, 0.3, 0.5)
ln(JD, {{19, 12}, {20, 72}}, 0.4, 0.6) ln(NH, {{21, 12}, {22, 72}}, 0.3, 0.5)
ln(JD, {{-17, 90}, {-17, 130}}, 0.4, 0.6) ln(JD, {{17, 92}, {18, 130}}, 0.4, 0.6)
-- knee cop wings
ln(JD, {{-27, 78}, {-17, 82}, {-6, 78}}, 0.45, 0.7) ln(JD, {{8, 80}, {19, 84}, {31, 80}}, 0.45, 0.7)
-- vambrace and gauntlet lames on the left arm
for _, v in ipairs({118, 134}) do ln(JD, {{-60, v}, {-43, v}}, 0.4, 0.6) end
for _, v in ipairs({86, 91, 96}) do ln(JD, {{-62, v}, {-44, v}}, 0.4, 0.55) end
-- helm: back ridge, and the edge of the visor turned away to the right
ln(JD, {{-3, 224}, {-2, 246}, {0, 264}}, 0.45, 0.7) ln(NH, {{-1, 225}, {0, 246}, {2, 263}}, 0.3, 0.5)
ln(JD, {{14, 234}, {20, 246}, {16, 258}}, 0.5, 0.8)

--@ chunk 12
print(wait(8*24*60), drying(560,350), drying(560,250))
-- the old tabard, pulled up over the shoulders: laid on dry paint, deep crimson
CRD2 = pile{{"rose madder",0.8},{"Mars red",0.45},{"bone black",1.3},{"ultramarine blue",0.1}}
TABM = pp({{-34, 212}, {-12, 216}, {10, 214}, {26, 220}, {36, 248}, {44, 254}, {44, 236}, {48, 200}, {44, 160}, {40, 120}, {30, 106}, {14, 110}, {-2, 102}, {-18, 108}, {-32, 104}, {-38, 140}, {-38, 180}}, true):roughen(2.5, 9, 41)
TABM = TABM - pp(FP.handR, true) - pp(FP.armLu, true)
work(TABM, {hand="detail", pile=CRD2, coverage=4.5, fill=true, clip=TABM, tool={kind="round", width=1.8}, length={3, 8}, angle=-1.4})

--@ chunk 13
-- scorch as a burn, not an outline: soot laid patchily across the whole shape, the edge broken
local SOOT = pile{{"bone black",2.4},{"burnt sienna",0.2},{"ultramarine blue",0.2}}
local m = SCORCH:grow(2) * FLOOR - FIG:grow(1)
work(m, {hand="scumble", pile=SOOT, coverage=1.6, fill=false, clip=m, tool={kind="filbert", width=4}, length={6, 14}, angle=0.3})
local SC = pile{{"bone black",1.4},{"Mars brown",0.5},{"lead white",0.12}}
local ring = (SCORCH:grow(7) - SCORCH:grow(1)) * FLOOR - FIG:grow(1)
work(ring, {hand="scumble", pile=SC, coverage=1.0, fill=false, clip=ring, tool={kind="filbert", width=3}, length={4, 10}, angle=0.3})
-- the frame's plate cores darker: only a narrow band toward the lamp stays mid grey
local core = nil
for _, k in ipairs(FORD) do local c = ppo(FP[k], -5, -6) * pp(FP[k], true) core = core and (core + c) or c end
core = core * FIG - TABM
work(core, {hand="detail", pile=NC2, coverage=4.5, fill=true, clip=core, tool={kind="round", width=1.1}, length={2, 4}})

--@ chunk 14
print(wait(15*24*60), drying(560,320))
local r
local function ln(p, uv, pr, w, clipm) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr*0.3, pr, pr*0.4}, clip=clipm}) end
local CRF = pile{{"bone black",2},{"Mars red",0.5},{"rose madder",0.3}}
local CRL = pile{{"Mars red",0.8},{"rose madder",0.5},{"cadmium red",0.3},{"bone black",0.35}}
local f = brush{kind="filbert", width=2.6, stiffness=0.5}
local function fold(p, uv, pr) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end f:load(p, 0.85) f:stroke(pts, {pressure={0.1, pr, 0.1}, clip=TABM}) end
-- folds hanging from the shoulders, dragged toward the lifting hand
fold(CRF, {{-24, 208}, {-26, 160}, {-22, 112}}, 0.6)
fold(CRF, {{-8, 210}, {-4, 170}, {-8, 110}}, 0.5)
fold(CRF, {{14, 212}, {22, 170}, {20, 112}}, 0.6)
fold(CRF, {{30, 236}, {36, 190}, {34, 130}}, 0.55)
fold(CRL, {{24, 222}, {32, 180}, {30, 128}}, 0.5)
fold(CRL, {{-16, 206}, {-14, 160}, {-12, 116}}, 0.4)
fold(CRL, {{38, 246}, {42, 210}}, 0.45)
-- scorch: burnt hem and two holes
local SC = pile{{"bone black",2.2},{"burnt sienna",0.4},{"Mars brown",0.3}}
for _, h in ipairs({{-20, 120, 7, 5}, {24, 142, 5, 4}, {6, 110, 8, 4}}) do
  local pts = {} for j = 0, 10 do local a = j/11*2*math.pi pts[#pts+1] = P(h[1] + h[3]*math.cos(a)*rand(0.7,1.2), h[2] + h[4]*math.sin(a)*rand(0.7,1.2)) end
  local m = poly(pts, true) * TABM
  work(m, {hand="detail", pile=SC, coverage=4, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 3}})
end
-- the bone cross, broken across the middle and mended with wire
local BND = pile{{"lead white",0.8},{"yellow ochre",0.3},{"raw sienna",0.15},{"bone black",0.3}}
local cb = brush{kind="filbert", width=3.4, stiffness=0.5}
local function bar(a, b) cb:load(BND, 0.9) cb:stroke({P(a[1], a[2]), P(b[1], b[2])}, {pressure={0.7, 0.7}, clip=TABM}) end
bar({-1, 198}, {0, 168})
bar({1, 160}, {3, 128})
bar({-20, 182}, {-4, 181})
bar({5, 180}, {20, 179})
local WI = pile{{"lead white",0.8},{"ultramarine ash",0.4},{"bone black",0.4}}
for _, w in ipairs({{{-4, 168}, {5, 160}}, {{-4, 161}, {5, 167}}, {{-5, 183}, {5, 178}}, {{-5, 178}, {5, 183}}}) do ln(WI, w, 0.5, 0.5) end
-- ragged bone hem
ln(BND, {{-32, 105}, {-18, 109}, {-2, 103}, {14, 111}, {30, 107}}, 0.45, 1.0)

--@ chunk 15
print(wait(8*24*60), drying(560,320))
local r
local function rim(p, uv, pr, w) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr*0.3, pr, pr*0.3}}) end
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8}}
local AMC = pile{{"Mars orange",0.7},{"cadmium red",0.3},{"lead white",0.4},{"rose madder",0.2}}
-- amber only on the edges facing the lamp
rim(AMH, {{4, 222}, {20, 230}, {22, 250}}, 0.6)
rim(AMH, {{54, 188}, {58, 214}}, 0.55)
rim(AMH, {{54, 188}, {72, 228}, {72, 236}}, 0.5)
rim(AMH, {{29, 9}, {28, 74}}, 0.4)
rim(AMH, {{31, 88}, {32, 130}}, 0.4)
rim(AMH, {{36, 125}, {32, 152}}, 0.35)
rim(AMC, {{44, 236}, {48, 200}, {44, 160}, {40, 120}}, 0.5, 1.0)
rim(AMH, {{-36, 182}, {-24, 208}}, 0.35)
rim(AMH, {{30, 248}, {44, 246}, {46, 262}}, 0.45)
-- the optic: the helm turned a little toward the far end; its warm point just shows past the visor edge
local OP = pile{{"lead white",2},{"cadmium yellow",0.35},{"zinc white",1}}
local o = brush{kind="round", width=1.6, point=0.3}
local q = P(21, 244) o:load(OP, 0.95) o:touch(q[1], q[2], {pressure=0.55})
-- the rosary wound round the left gauntlet, the crucifix hanging below
local BEAD = pile{{"lead white",1.3},{"yellow ochre",0.3},{"bone black",0.15},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local b = brush{kind="round", width=2.2, point=0.4}
for _, row in ipairs({{{-63, 84}, {-43, 90}}, {{-63, 92}, {-43, 98}}, {{-63, 100}, {-43, 106}}}) do
  rim(CHN, row, 0.35, 0.7)
  for k = 0, 5 do local t = k/5 local q2 = P(row[1][1] + (row[2][1]-row[1][1])*t, row[1][2] + (row[2][2]-row[1][2])*t) b:load(BEAD, 0.9) b:touch(q2[1], q2[2], {pressure=0.5}) end
end
local drop = {{-52, 82}, {-53, 72}, {-52, 62}}
rim(CHN, drop, 0.35, 0.7)
for _, d in ipairs({{-52.5, 76}, {-52.6, 68}}) do local q2 = P(d[1], d[2]) b:load(BEAD, 0.9) b:touch(q2[1], q2[2], {pressure=0.5}) end
local cr = brush{kind="filbert", width=1.8, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({P(-52, 62), P(-52, 46)}, {pressure={0.75, 0.75}})
cr:load(BEAD, 0.95) cr:stroke({P(-58, 57), P(-46, 57)}, {pressure={0.75, 0.75}})

--@ chunk 16
print(wait(6*24*60))
local REG = SCORCH:grow(8) * FLOOR - FIG:grow(1)
local ASH = pile{{"bone black",1.3},{"Mars brown",0.4},{"lead white",0.25},{"ultramarine blue",0.2}}
stipple(REG, {pile=ASH, width=3, coverage=0.9, cluster={0.6, 12}, clip=REG})
local GD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GL = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"Mars brown",0.4},{"lead white",0.3}}
local r = brush{kind="rigger", width=0.8, point=1}
for x = -500, 1600, 38 do
  local a = {x, 600}
  local b = {VP[1] + (x - VP[1])*0.1, VP[2] + (600 - VP[2])*0.1}
  r:load(GL, 0.7) r:stroke({{a[1] + 3, a[2]}, {b[1] + 0.3, b[2]}}, {pressure={0.4, 0.1}, clip=REG})
end
local z = 1.0
while z < 9 do
  local y = VP[2] + (600 - VP[2])/z
  r:load(GL, 0.7) r:stroke({{-40, y + 1.5}, {1040, y + 1.5}}, {pressure={clamp(0.6/z, 0.12, 0.6), clamp(0.6/z, 0.12, 0.6)}, clip=REG})
  z = z * 1.16
end

--@ chunk 17
print(wait(4*24*60))
local REG = SCORCH:grow(9) * FLOOR - FIG:grow(1)
work(REG, {hand="scumble", pile=FL, coverage=0.7, fill=false, clip=REG, tool={kind="filbert", width=3}, length={4, 9}, angle=0.3})
local sh = poly({P(-30, 2), P(36, 2), P(-60, -60), P(-140, -70)}, true) * FLOOR - FIG
work(sh:soften(3), {hand="body", pile=SHD, coverage=3, fill=true, clip=FLOOR - FIG, angle=2.5, length={8, 16}, tool="filbert 5"})

--@ chunk 18
print(wait(4*24*60))
local SOOT = pile{{"bone black",2.4},{"burnt sienna",0.25},{"ultramarine blue",0.2}}
local ring = (SCORCH:grow(3) - SCORCH:shrink(2)) * FLOOR - FIG:grow(1)
work(ring, {hand="scumble", pile=SOOT, coverage=0.9, fill=false, clip=ring, tool={kind="filbert", width=2.5}, length={3, 8}, angle=0.3})
local inner = SCORCH:shrink(2) * FLOOR - FIG:grow(1)
work(inner, {hand="scumble", pile=SOOT, coverage=0.35, fill=false, clip=inner, tool={kind="filbert", width=3}, length={4, 9}, angle=0.3})

--@ chunk 19
print(wait(4*24*60))
local BEAD = pile{{"lead white",1.3},{"yellow ochre",0.3},{"bone black",0.15},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local r = brush{kind="rigger", width=0.7, point=1}
r:load(CHN, 0.9) r:stroke({P(-52, 82), P(-53, 72), P(-52, 62)}, {pressure={0.35, 0.35}})
local b = brush{kind="round", width=2.2, point=0.4}
for _, d in ipairs({{-52.5, 76}, {-52.6, 68}}) do local q2 = P(d[1], d[2]) b:load(BEAD, 0.9) b:touch(q2[1], q2[2], {pressure=0.5}) end
local cr = brush{kind="filbert", width=1.8, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({P(-52, 62), P(-52, 46)}, {pressure={0.75, 0.75}})
cr:load(BEAD, 0.95) cr:stroke({P(-58, 57), P(-46, 57)}, {pressure={0.75, 0.75}})

--@ chunk 20
-- Pass 2.1: paint the old figure, its shadow and the body-shaped burn back to wall and grating
local shadow = poly({P(-30, 2), P(36, 2), P(-60, -60), P(-140, -70)}, true)
local R = (FIG:grow(5) + TABM:grow(5) + SCORCH:grow(12) + shadow:grow(5) + rect(480, 250, 40, 240))
CLR = R
local GP = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local wl = R * LWALL
work(wl, {hand="detail", pile=GP, coverage=4, fill=true, clip=wl, angle=toVP, tool={kind="round", width=2.2}, length={4, 10}})
local fl = R * FLOOR
work(fl, {hand="body", pile=FL, coverage=3.5, fill=true, clip=fl, angle=toVP, length={10, 25}, tool="filbert 6"})

--@ chunk 21
print(wait(6*24*60), drying(560,300), drying(470,500))
local function wallpt(side, t, h)
  local nx = (side < 0) and -40 or 1040
  local fx = (side < 0) and FAR[1] or FAR[3]
  local x = nx + (fx - nx)*t
  local ybot = 600 + (FAR[4] - 600)*t
  local ytop = -40 + (FAR[2] + 40)*t
  return {x, ybot + (ytop - ybot)*h}
end
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local wl = CLR:grow(2) * LWALL
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(-1, t, 0.02), wallpt(-1, t, 0.98)}, {pressure={0.7, 0.7}, clip=wl})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(-1, t + 0.004, 0.02), wallpt(-1, t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=wl})
  t = t + 0.1*(1 - t*0.85)
end
local rail = brush{kind="filbert", width=3, stiffness=0.5}
rail:load(RB, 0.9) rail:stroke({wallpt(-1, 0, 0.42), wallpt(-1, 1, 0.42)}, {pressure={0.8, 0.2}, clip=wl})
local ED = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.22}}
local e = brush{kind="rigger", width=0.9, point=1}
e:load(ED, 0.8) e:stroke({{-40, 600}, {FAR[1], FAR[4]}}, {pressure={0.6, 0.2}, clip=CLR:grow(2)})
local REG = CLR:grow(2) * FLOOR
local GD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GL = pile{{"bone black",1.4},{"ultramarine blue",0.3},{"Mars brown",0.3},{"lead white",0.25}}
local r = brush{kind="rigger", width=0.7, point=1}
for x = -500, 1600, 38 do
  local a = {x, 600}
  local b = {VP[1] + (x - VP[1])*0.1, VP[2] + (600 - VP[2])*0.1}
  r:load(GD, 0.8) r:stroke({a, b}, {pressure={0.6, 0.15}, clip=REG})
  r:load(GL, 0.7) r:stroke({{a[1] + 3, a[2]}, {b[1] + 0.3, b[2]}}, {pressure={0.3, 0.08}, clip=REG})
end
local z = 1.0
while z < 9 do
  local y = VP[2] + (600 - VP[2])/z
  r:load(GD, 0.8) r:stroke({{-40, y}, {1040, y}}, {pressure={clamp(0.7/z, 0.12, 0.7), clamp(0.7/z, 0.12, 0.7)}, clip=REG})
  z = z * 1.16
end

--@ chunk 22
print(wait(6*24*60), drying(470,500))
-- a soft, irregular scorch where the wreck lay: darker grating, streaks along the slats, heat-blued metal
local patch = ellipse(470, 492, 120, 40):roughen(14, 60, 5):soften(10) * FLOOR
local SD = pile{{"bone black",2.4},{"Mars brown",0.5},{"ultramarine blue",0.3}}
work(patch, {hand="scumble", pile=SD, coverage=0.6, fill=false, clip=FLOOR, tool={kind="filbert", width=4}, length={6, 14}, angle=0.25})
local r = brush{kind="filbert", width=2.4, stiffness=0.5}
for i = 1, 14 do
  local x = rand(370, 580) local y = rand(468, 518)
  local a = math.atan(VP[2] - y, VP[1] - x)
  local L = rand(14, 34)
  r:load(SD, 0.8) r:stroke({{x, y}, {x + math.cos(a)*L, y + math.sin(a)*L}}, {pressure={0.5, 0.1}, clip=patch})
end
local BL = pile{{"ultramarine blue",1},{"cobalt violet",0.3},{"lead white",0.5},{"bone black",0.6}}
local BL2 = pile{{"Mars orange",0.4},{"raw sienna",0.4},{"bone black",0.6},{"lead white",0.2}}
local t = brush{kind="rigger", width=0.8, point=1}
for i = 1, 8 do
  local x = rand(410, 540) local y = rand(474, 510)
  local a = math.atan(VP[2] - y, VP[1] - x)
  local L = rand(8, 18)
  t:load((i % 3 == 0) and BL2 or BL, 0.8) t:stroke({{x, y}, {x + math.cos(a)*L, y + math.sin(a)*L}}, {pressure={0.35, 0.1}})
end
local BR = pile{{"raw sienna",1},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.1}}
local BG = pile{{"lead white",1},{"cadmium yellow",0.5},{"Mars orange",0.4}}
local cs = brush{kind="round", width=1.6, point=0.3}
local gl = brush{kind="round", width=0.9, point=0.3}
for i, c in ipairs({{402, 520}, {455, 528}, {530, 512}, {610, 540}, {372, 474}, {560, 486}}) do
  local a = rand(0, math.pi) local L = 3 + (c[2] - 380)*0.014
  cs:load(BR, 0.9) cs:stroke({{c[1] - math.cos(a)*L/2, c[2] - math.sin(a)*L/2}, {c[1] + math.cos(a)*L/2, c[2] + math.sin(a)*L/2}}, {pressure={0.65, 0.65}})
  gl:load(BG, 0.9) gl:touch(c[1] + math.cos(a)*L*0.3, c[2] + math.sin(a)*L*0.3 - 0.4, {pressure=0.45})
end
-- the new figure, further down the corridor, mid-step
FB = {590, 442}
local S = 0.86
function P(u, v) return {FB[1] + u*S, FB[2] - v*S} end
function pp(t, smooth) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, smooth) end
function ppo(t, du, dv) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1] + du, q[2] + dv) end return poly(o, true) end
FP = {
 footL = {{-26, 0}, {-5, 0}, {-5, 10}, {-23, 11}},
 greaveL = {{-24, 10}, {-7, 10}, {-6, 72}, {-23, 74}},
 kneeL = {{-26, 70}, {-5, 70}, {-4, 86}, {-25, 86}},
 cuisseL = {{-28, 84}, {-4, 84}, {-2, 132}, {-30, 132}},
 soleR = {{12, -16}, {30, -18}, {31, -6}, {13, -3}},
 greaveR = {{12, -4}, {29, -6}, {31, 62}, {13, 66}},
 kneeR = {{9, 62}, {32, 60}, {31, 78}, {10, 80}},
 cuisseR = {{6, 78}, {31, 80}, {32, 130}, {4, 132}},
 faulds = {{-36, 124}, {36, 124}, {32, 152}, {-32, 152}},
 torso = {{-34, 148}, {34, 148}, {40, 212}, {-40, 210}},
 gorget = {{-16, 210}, {16, 210}, {14, 228}, {-14, 228}},
 helm = {{-17, 224}, {4, 222}, {20, 230}, {22, 250}, {12, 264}, {-10, 265}, {-20, 250}},
 paulL = {{-56, 186}, {-34, 182}, {-24, 210}, {-36, 222}, {-56, 214}},
 armLu = {{-58, 150}, {-42, 150}, {-40, 188}, {-56, 190}},
 armLv = {{-62, 102}, {-46, 100}, {-42, 152}, {-58, 152}},
 gauntL = {{-66, 82}, {-48, 80}, {-45, 102}, {-63, 104}},
 paulR = {{30, 186}, {54, 188}, {58, 214}, {44, 224}, {26, 212}},
 armRu = {{42, 196}, {56, 190}, {64, 164}, {50, 158}},
 armRf = {{50, 158}, {64, 164}, {46, 208}, {34, 202}},
 handR = {{28, 198}, {44, 196}, {46, 214}, {30, 216}},
}
FORD = {"footL","greaveL","kneeL","cuisseL","soleR","greaveR","kneeR","cuisseR","faulds","torso","armLu","armLv","gauntL","paulL","gorget","helm","paulR","armRu","armRf","handR"}
local a = nil
for _, k in ipairs(FORD) do local m = pp(FP[k], true) a = a and (a + m) or m end
FIG = a
local sh = poly({P(-30, 2), P(36, -6), P(-50, -50), P(-120, -54)}, true) * FLOOR - FIG
work(sh:soften(3), {hand="body", pile=SHD, coverage=3, fill=true, clip=FLOOR - FIG, angle=2.6, length={8, 16}, tool="filbert 5"})
work(FIG, {hand="detail", pile=NC2, coverage=5, fill=true, clip=FIG, tool={kind="round", width=1.5}, length={2, 6}})

--@ chunk 23
local patch = ellipse(470, 492, 130, 46):roughen(14, 60, 5) * FLOOR - FIG:grow(1)
work(patch, {hand="scumble", pile=FL, coverage=0.9, fill=false, clip=patch, tool={kind="filbert", width=4}, length={6, 14}, angle=0.25})
blend(patch:shrink(2), {angle=0.25, tool={kind="badger", width=10}, length={20, 40}})
-- stray marks: the doubled rail on the left wall, and a pale smudge on the deck
local GP = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}
local m1 = poly({{470, 268}, {545, 262}, {545, 276}, {470, 282}}) * LWALL - FIG:grow(1)
work(m1, {hand="detail", pile=GP, coverage=4, fill=true, clip=m1, tool={kind="round", width=1.6}, length={3, 6}, angle=-0.3})
local m2 = ellipse(505, 412, 7, 5) * FLOOR
work(m2, {hand="detail", pile=FL, coverage=4, fill=true, clip=m2, tool={kind="round", width=1.4}, length={2, 4}})

--@ chunk 24
print(wait(8*24*60), drying(470,492), drying(590,350))
local patch = ellipse(470, 492, 135, 50) * FLOOR - FIG:grow(1)
-- a faint soot, then the grating restated through it
local SD = pile{{"bone black",2.4},{"Mars brown",0.5},{"ultramarine blue",0.3}}
local core = ellipse(462, 494, 95, 32):roughen(10, 50, 9) * FLOOR - FIG:grow(1)
work(core, {hand="scumble", pile=SD, coverage=0.3, fill=false, clip=core, tool={kind="filbert", width=3}, length={5, 10}, angle=0.25})
local GD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GL = pile{{"bone black",1.4},{"ultramarine blue",0.3},{"Mars brown",0.3},{"lead white",0.25}}
local r = brush{kind="rigger", width=0.7, point=1}
for x = -500, 1600, 38 do
  local a = {x, 600}
  local b = {VP[1] + (x - VP[1])*0.1, VP[2] + (600 - VP[2])*0.1}
  r:load(GD, 0.8) r:stroke({a, b}, {pressure={0.6, 0.15}, clip=patch})
  r:load(GL, 0.7) r:stroke({{a[1] + 3, a[2]}, {b[1] + 0.3, b[2]}}, {pressure={0.3, 0.08}, clip=patch})
end
local z = 1.0
while z < 9 do
  local y = VP[2] + (600 - VP[2])/z
  r:load(GD, 0.8) r:stroke({{-40, y}, {1040, y}}, {pressure={clamp(0.7/z, 0.12, 0.7), clamp(0.7/z, 0.12, 0.7)}, clip=patch})
  z = z * 1.16
end
-- streaks of soot and heat-blue running along the slats, only near the old site
local BL = pile{{"ultramarine blue",1},{"cobalt violet",0.4},{"lead white",0.7},{"bone black",0.4}}
local ST = pile{{"bone black",2.5},{"burnt sienna",0.3}}
local s = brush{kind="rigger", width=1.2, point=1}
for _, x in ipairs({-120, -82, -44, -6, 32, 70, 108, 146}) do
  local a = {x, 600}
  local b = {VP[1] + (x - VP[1])*0.1, VP[2] + (600 - VP[2])*0.1}
  local function at(t) return {a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t} end
  for _, seg in ipairs({{rand(0.18, 0.26), rand(0.3, 0.36)}, {rand(0.36, 0.4), rand(0.42, 0.46)}}) do
    local p0, p1 = at(seg[1]), at(seg[2])
    if core:grow(14):at(clamp(p0[1],0,999), clamp(p0[2],0,562)) > 0.3 then
      s:load((rand(0,1) < 0.45) and BL or ST, 0.85)
      s:stroke({{p0[1] + 1.5, p0[2]}, {p1[1] + 1.5, p1[2]}}, {pressure={0.1, 0.5, 0.1}, swell={0.4, 1, 0.4}})
    end
  end
end
-- the figure's shadow back on the deck
local sh = poly({P(-30, 2), P(36, -6), P(-50, -50), P(-120, -54)}, true) * FLOOR - FIG
work(sh:soften(3), {hand="body", pile=SHD, coverage=3, fill=true, clip=FLOOR - FIG, angle=2.6, length={8, 16}, tool="filbert 5"})
-- plate mid-planes toward the lamp
local mid = nil
for _, k in ipairs(FORD) do local m = ppo(FP[k], 0, 0) - ppo(FP[k], -4, -5) mid = mid and (mid + m) or m end
mid = mid * FIG
work(mid, {hand="detail", pile=NG2, coverage=4.5, fill=true, clip=mid, tool={kind="round", width=1.0}, length={2, 4}})

--@ chunk 25
print(wait(8*24*60), drying(590,350))
local JD = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local NH = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.2}}
local r
local function ln(p, uv, pr, w) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.85}, clip=FIG:grow(0.5)}) end
-- separations between plates
for _, s in ipairs({
  {{-27, 72}, {-6, 72}}, {{11, 64}, {31, 62}}, {{-28, 86}, {-5, 86}}, {{8, 79}, {31, 80}},
  {{-31, 132}, {32, 132}}, {{-36, 125}, {36, 125}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-14, 224}, {14, 224}},
  {{-42, 151}, {-58, 151}}, {{-43, 101}, {-61, 101}}, {{-7, 12}, {-7, 70}},
}) do ln(JD, s, 0.55, 0.9) end
-- fauld lames, gorget rings, pauldron lames
for _, v in ipairs({138, 145}) do ln(JD, {{-35, v}, {0, v - 1}, {34, v}}, 0.45, 0.7) end
for _, v in ipairs({215, 220}) do ln(JD, {{-15, v}, {15, v}}, 0.4, 0.6) end
for _, o in ipairs({0, 8}) do ln(JD, {{-55, 196 + o}, {-42, 190 + o}, {-28, 196 + o}}, 0.45, 0.7) end
for _, o in ipairs({0, 8}) do ln(JD, {{30, 198 + o}, {44, 194 + o}, {57, 200 + o}}, 0.45, 0.7) end
-- greave and cuisse ridges, lit along their lamp side
ln(JD, {{-16, 12}, {-16, 70}}, 0.4, 0.6) ln(NH, {{-14, 12}, {-14, 70}}, 0.3, 0.5)
ln(JD, {{20, -2}, {21, 60}}, 0.4, 0.6) ln(NH, {{22, -2}, {23, 60}}, 0.3, 0.5)
ln(JD, {{-17, 90}, {-17, 130}}, 0.4, 0.6) ln(JD, {{17, 92}, {18, 130}}, 0.4, 0.6)
-- knee cop wings
ln(JD, {{-27, 78}, {-17, 82}, {-6, 78}}, 0.45, 0.7) ln(JD, {{9, 70}, {20, 74}, {32, 70}}, 0.45, 0.7)
-- vambrace and gauntlet lames on the left arm
for _, v in ipairs({118, 134}) do ln(JD, {{-61, v}, {-44, v}}, 0.4, 0.6) end
for _, v in ipairs({86, 91, 96}) do ln(JD, {{-65, v}, {-46, v}}, 0.4, 0.55) end
-- helm: back ridge, and the edge of the visor turned away to the right
ln(JD, {{-3, 224}, {-2, 246}, {0, 264}}, 0.45, 0.7) ln(NH, {{-1, 225}, {0, 246}, {2, 263}}, 0.3, 0.5)
ln(JD, {{14, 234}, {20, 246}, {16, 258}}, 0.5, 0.8)

-- backplate: central ridge and the shoulder lames above where the tabard will hang
ln(JD, {{0, 150}, {1, 180}, {0, 208}}, 0.55, 0.9) ln(NH, {{2, 152}, {3, 180}, {2, 206}}, 0.35, 0.6)
for _, v in ipairs({196, 203}) do ln(JD, {{-36, v}, {-14, v + 4}, {0, v + 5}}, 0.45, 0.7) end
ln(JD, {{-34, 175}, {0, 178}, {36, 175}}, 0.4, 0.6)
-- the sole of the lifting foot, heel up
ln(JD, {{13, -10}, {30, -12}}, 0.5, 0.8)

--@ chunk 26
print(wait(8*24*60), drying(590,350), drying(590,250))
-- the old tabard, pulled up over the shoulders: laid on dry paint, deep crimson
CRD2 = pile{{"rose madder",0.8},{"Mars red",0.45},{"bone black",1.3},{"ultramarine blue",0.1}}
TABM = pp({{-36, 182}, {-20, 188}, {-4, 196}, {14, 206}, {30, 212}, {44, 214}, {48, 196}, {44, 160}, {40, 120}, {30, 106}, {14, 110}, {-2, 102}, {-18, 108}, {-32, 104}, {-38, 140}, {-38, 170}}, true):roughen(2.5, 9, 41)
TABM = TABM - pp(FP.handR, true) - pp(FP.armLu, true)
work(TABM, {hand="detail", pile=CRD2, coverage=4.5, fill=true, clip=TABM, tool={kind="round", width=1.8}, length={3, 8}, angle=-1.4})

--@ chunk 27
print(wait(15*24*60), drying(590,320))
local r
local function ln(p, uv, pr, w, clipm) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr*0.3, pr, pr*0.4}, clip=clipm}) end
local CRF = pile{{"bone black",2},{"Mars red",0.5},{"rose madder",0.3}}
local CRL = pile{{"Mars red",0.8},{"rose madder",0.5},{"cadmium red",0.3},{"bone black",0.35}}
local f = brush{kind="filbert", width=2.6, stiffness=0.5}
local function fold(p, uv, pr) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end f:load(p, 0.85) f:stroke(pts, {pressure={0.1, pr, 0.1}, clip=TABM}) end
-- folds hanging from the shoulders, dragged toward the lifting hand
fold(CRF, {{-24, 188}, {-26, 160}, {-22, 112}}, 0.6)
fold(CRF, {{-6, 196}, {-4, 170}, {-8, 110}}, 0.5)
fold(CRF, {{14, 202}, {22, 170}, {20, 112}}, 0.6)
fold(CRF, {{34, 210}, {38, 180}, {34, 130}}, 0.55)
fold(CRL, {{24, 206}, {30, 176}, {30, 128}}, 0.5)
fold(CRL, {{-16, 190}, {-14, 160}, {-12, 116}}, 0.4)
fold(CRL, {{40, 210}, {44, 190}}, 0.45)
-- scorch: burnt hem and two holes
local SC = pile{{"bone black",2.2},{"burnt sienna",0.4},{"Mars brown",0.3}}
for _, h in ipairs({{-20, 120, 7, 5}, {24, 142, 5, 4}, {6, 110, 8, 4}}) do
  local pts = {} for j = 0, 10 do local a = j/11*2*math.pi pts[#pts+1] = P(h[1] + h[3]*math.cos(a)*rand(0.7,1.2), h[2] + h[4]*math.sin(a)*rand(0.7,1.2)) end
  local m = poly(pts, true) * TABM
  work(m, {hand="detail", pile=SC, coverage=4, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 3}})
end
-- the bone cross, broken across the middle and mended with wire
local BND = pile{{"lead white",0.8},{"yellow ochre",0.3},{"raw sienna",0.15},{"bone black",0.3}}
local cb = brush{kind="filbert", width=3.4, stiffness=0.5}
local function bar(a, b) cb:load(BND, 0.9) cb:stroke({P(a[1], a[2]), P(b[1], b[2])}, {pressure={0.7, 0.7}, clip=TABM}) end
bar({0, 190}, {1, 164})
bar({2, 156}, {3, 126})
bar({-18, 176}, {-3, 176})
bar({6, 176}, {22, 175})
local WI = pile{{"lead white",0.8},{"ultramarine ash",0.4},{"bone black",0.4}}
for _, w in ipairs({{{-3, 164}, {6, 156}}, {{-3, 157}, {6, 163}}, {{-4, 179}, {6, 174}}, {{-4, 174}, {6, 179}}}) do ln(WI, w, 0.5, 0.5) end
-- ragged bone hem
ln(BND, {{-32, 105}, {-18, 109}, {-2, 103}, {14, 111}, {30, 107}}, 0.45, 1.0)

--@ chunk 28
print(wait(8*24*60), drying(590,320))
local r
local function rim(p, uv, pr, w) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr*0.3, pr, pr*0.3}}) end
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8}}
local AMC = pile{{"Mars orange",0.7},{"cadmium red",0.3},{"lead white",0.4},{"rose madder",0.2}}
-- amber only on the edges facing the lamp
rim(AMH, {{4, 222}, {20, 230}, {22, 250}}, 0.6)
rim(AMH, {{54, 188}, {58, 214}}, 0.55)
rim(AMH, {{56, 190}, {64, 164}}, 0.5)
rim(AMH, {{29, -6}, {31, 62}}, 0.4)
rim(AMH, {{31, 88}, {32, 130}}, 0.4)
rim(AMH, {{36, 125}, {32, 152}}, 0.35)
rim(AMC, {{46, 212}, {48, 196}, {44, 160}, {40, 120}}, 0.5, 1.0)
rim(AMH, {{-36, 182}, {-24, 208}}, 0.35)
rim(AMH, {{30, 214}, {44, 212}, {46, 198}}, 0.45)
rim(AMH, {{42, 196}, {56, 190}}, 0.4)
-- the optic: the helm turned a little toward the far end; its warm point just shows past the visor edge
local OP = pile{{"lead white",2},{"cadmium yellow",0.35},{"zinc white",1}}
local o = brush{kind="round", width=1.6, point=0.3}
local q = P(21, 244) o:load(OP, 0.95) o:touch(q[1], q[2], {pressure=0.55})
-- the rosary wound round the left gauntlet, the crucifix hanging below
local BEAD = pile{{"lead white",1.3},{"yellow ochre",0.3},{"bone black",0.15},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local b = brush{kind="round", width=2.2, point=0.4}
for _, row in ipairs({{{-66, 84}, {-46, 89}}, {{-66, 91}, {-46, 96}}, {{-65, 98}, {-45, 103}}}) do
  rim(CHN, row, 0.35, 0.7)
  for k = 0, 5 do local t = k/5 local q2 = P(row[1][1] + (row[2][1]-row[1][1])*t, row[1][2] + (row[2][2]-row[1][2])*t) b:load(BEAD, 0.9) b:touch(q2[1], q2[2], {pressure=0.5}) end
end
local drop = {{-56, 82}, {-57, 72}, {-56, 62}}
rim(CHN, drop, 0.35, 0.7)
for _, d in ipairs({{-56.5, 76}, {-56.6, 68}}) do local q2 = P(d[1], d[2]) b:load(BEAD, 0.9) b:touch(q2[1], q2[2], {pressure=0.5}) end
local cr = brush{kind="filbert", width=1.8, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({P(-56, 62), P(-56, 46)}, {pressure={0.75, 0.75}})
cr:load(BEAD, 0.95) cr:stroke({P(-62, 57), P(-50, 57)}, {pressure={0.75, 0.75}})
