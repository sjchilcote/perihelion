-- easel session "revival": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=1311, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}, um=45, apply="brush", texture=0.35}}}
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
-- cast shadow on the deck, pushed away from the lamp (down and left)
local sh = gpoly({{-20, -10}, {150, 10}, {300, 30}, {360, 40}, {420, 120}, {380, 130}, {300, 60}, {150, 100}, {100, 104}, {-20, 20}}, 0, true)
work(sh:soften(4) - all, {hand="body", pile=SHD, coverage=3.5, fill=true, angle=math.atan(GA_[2], GA_[1]), length={8, 18}, tool="filbert 5"})
work(all, {hand="detail", pile=MD, coverage=4, fill=true, clip=all, tool={kind="round", width=1.6}, length={2, 6}})

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
print(wait(8*24*60), drying(560,440), drying(820,250))
-- planes: upper faces catch a little of the lamp, lower faces stay dark
local GMT = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"lead white",0.35}}
local GMW = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"burnt sienna",0.3},{"lead white",0.3}}
local up = nil
for _, k in ipairs(PORDER) do
  local band = PARTS[k](0) - PARTS[k](7)
  up = up and (up + band) or band
end
up = up * FRAME
work(up, {hand="detail", pile=GMT, coverage=3.5, fill=true, clip=up, tool={kind="round", width=1.3}, length={2, 5}})
local warm = (PARTS.helm(0) - PARTS.helm(5)) + (PARTS.paul(0) - PARTS.paul(6)) + (PARTS.torso(0) - PARTS.torso(9))
warm = warm * FRAME
work(warm, {hand="detail", pile=GMW, coverage=3, fill=true, clip=warm, tool={kind="round", width=1.2}, length={2, 4}})
-- plate seams and breaks
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local r = brush{kind="rigger", width=0.8, point=1}
local function line(p, uv, pr) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = G(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.8}, clip=FRAME}) end
for _, u in ipairs({200, 228, 258}) do line(JD, {{u, -46}, {u + 4, 30}}, 0.5) end
line(JD, {{180, -10}, {290, -16}}, 0.4)
line(JD, {{46, -30}, {46, -14}}, 0.5)
line(JD, {{360, 92}, {362, 104}}, 0.5)
line(JD, {{318, -28}, {336, 20}}, 0.35)
-- scorched plate on the chest
local SC = pile{{"bone black",2},{"burnt sienna",0.6},{"Mars brown",0.3}}
local SE = pile{{"burnt sienna",1},{"Mars orange",0.3},{"bone black",0.6}}
for _, s in ipairs({{215, -20, 16, 11}, {262, 4, 12, 9}, {300, -16, 6, 5}}) do
  local pts = {}
  for k = 0, 11 do local a = k/12*2*math.pi pts[#pts+1] = G(s[1] + s[3]*math.cos(a)*rand(0.7, 1.2), s[2] + s[4]*math.sin(a)*rand(0.7, 1.2)) end
  local m = poly(pts, true) * FRAME
  work(m, {hand="detail", pile=SC, coverage=4, fill=true, clip=m, tool={kind="round", width=1.2}, length={1.5, 3}})
  local rim = {} for k = 0, 5 do local a = -2.6 + k*0.35 rim[#rim+1] = G(s[1] + s[3]*1.1*math.cos(a), s[2] + s[4]*1.1*math.sin(a)) end
  r:load(SE, 0.8) r:stroke(rim, {pressure={0.1, 0.35, 0.1}, clip=FRAME})
end
-- the knee broken backwards: dark socket, pistons and a bright joint pin
local sock = gpoly({{92, 30}, {110, 30}, {112, 48}, {94, 50}}, 0, true)
work(sock, {hand="detail", pile=JD, coverage=4, fill=true, clip=sock, tool={kind="round", width=1.0}, length={1, 3}})
local PIS = pile{{"lead white",1},{"ultramarine ash",0.4},{"bone black",0.5}}
local p = brush{kind="rigger", width=1.0, point=1}
p:load(PIS, 0.9) p:stroke({G(124, 26), G(104, 38), G(110, 52)}, {pressure={0.5, 0.5}})
p:load(PIS, 0.9) p:stroke({G(118, 32), G(98, 44)}, {pressure={0.4, 0.4}})
p:load(PIS, 0.9) p:stroke({G(96, 36), G(106, 34), G(112, 44)}, {pressure={0.3, 0.3}})
local pin = brush{kind="round", width=2.4, point=0.3}
pin:load(PIS, 0.9) local q = G(102, 41) pin:touch(q[1], q[2], {pressure=0.6})

--@ chunk 10
print(wait(8*24*60), drying(560,440))
local GWM = pile{{"bone black",1.4},{"burnt sienna",0.45},{"ultramarine blue",0.2},{"lead white",0.22}}
local up, lo = nil, nil
for _, k in ipairs(PORDER) do
  local band = PARTS[k](0) - PARTS[k](6)
  local lb = PARTS[k](0) - PARTS[k](-6)
  up = up and (up + band) or band
  lo = lo and (lo + lb) or lb
end
up = up * FRAME
lo = lo * FRAME - up
work(up, {hand="detail", pile=GWM, coverage=4, fill=true, clip=up, tool={kind="round", width=1.2}, length={2, 5}})
work(lo, {hand="detail", pile=SHD, coverage=4, fill=true, clip=lo, tool={kind="round", width=1.2}, length={2, 5}})
-- segment seams on the limbs
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local r = brush{kind="rigger", width=0.9, point=1}
for _, s in ipairs({{{30, -32}, {30, -14}}, {{110, -30}, {112, -14}}, {{126, 16}, {136, 34}}, {{312, 36}, {302, 52}}, {{352, 72}, {346, 88}}, {{226, -66}, {230, -52}}}) do
  r:load(JD, 0.9) r:stroke({G(s[1][1], s[1][2]), G(s[2][1], s[2][2])}, {pressure={0.5, 0.5}, clip=FRAME})
end

--@ chunk 11
print(wait(12*24*60), drying(560,440), drying(420,500))
-- the tabard, half pulled off and crumpled, laid on DRY paint in a deep crimson
CRD = pile{{"Mars red",0.7},{"rose madder",0.7},{"bone black",0.8}}
TAB3 = gpoly({{118, -16}, {160, -24}, {192, -10}, {205, 14}, {196, 44}, {170, 60}, {136, 72}, {104, 80}, {74, 74}, {58, 60}, {72, 44}, {66, 26}, {90, 16}, {104, -2}}, 0, true)
work(TAB3, {hand="detail", pile=CRD, coverage=4.5, fill=true, clip=TAB3, tool={kind="round", width=1.8}, length={3, 8}, angle=0.4})

--@ chunk 12
print(wait(15*24*60), drying(420,500))
CRD2 = pile{{"rose madder",0.8},{"Mars red",0.45},{"bone black",1.3},{"ultramarine blue",0.1}}
-- deeper crimson, ragged torn edge where it was pulled
local rag = TAB3:roughen(2.5, 9, 31)
work(rag, {hand="detail", pile=CRD2, coverage=4.5, fill=true, clip=rag, tool={kind="round", width=1.6}, length={3, 8}, angle=0.4})

--@ chunk 13
print(wait(15*24*60), drying(400,520), drying(560,440))
local r = brush{kind="rigger", width=0.8, point=1}
local function gl(uv) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = G(q[1], q[2]) end return pts end
-- crumpled folds: dark creases, a few lit ridges, a torn bone hem and a fragment of the cross
local CRF = pile{{"bone black",2},{"Mars red",0.5},{"rose madder",0.3}}
local CRL = pile{{"Mars red",0.8},{"rose madder",0.5},{"cadmium red",0.3},{"bone black",0.35}}
local f = brush{kind="filbert", width=2.4, stiffness=0.5}
for _, c in ipairs({{{120, -8}, {150, 6}, {172, 26}}, {{86, 30}, {118, 40}, {150, 56}}, {{150, -14}, {176, 0}, {196, 18}}, {{70, 62}, {98, 64}, {126, 70}}, {{110, 14}, {130, 30}, {136, 52}}}) do
  f:load(CRF, 0.85) f:stroke(gl(c), {pressure={0.1, 0.6, 0.1}, clip=TAB3})
end
for _, c in ipairs({{{126, -12}, {152, 0}}, {{92, 24}, {120, 34}}, {{170, 34}, {190, 24}}, {{80, 52}, {102, 56}}}) do
  f:load(CRL, 0.85) f:stroke(gl(c), {pressure={0.1, 0.5, 0.1}, clip=TAB3})
end
local BND = pile{{"lead white",0.7},{"yellow ochre",0.3},{"raw sienna",0.15},{"bone black",0.35}}
r:load(BND, 0.9) r:stroke(gl({{58, 60}, {74, 74}, {104, 80}, {136, 72}}), {pressure={0.4, 0.45}})
local cb = brush{kind="filbert", width=2.8, stiffness=0.5}
cb:load(BND, 0.9) cb:stroke(gl({{150, 26}, {182, 18}}), {pressure={0.6, 0.6}, clip=TAB3})
cb:load(BND, 0.9) cb:stroke(gl({{170, 8}, {174, 34}}), {pressure={0.6, 0.6}, clip=TAB3})
-- amber rim along the upper edges, lamp-side
local AMR = pile{{"Mars orange",0.7},{"burnt sienna",0.4},{"lead white",0.4},{"bone black",0.2}}
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.7}}
local function rim(p, uv, pr) r:load(p, 0.9) r:stroke(gl(uv), {pressure={pr*0.4, pr, pr*0.5}}) end
rim(AMH, {{307, -27}, {336, -32}, {353, -15}}, 0.6)
rim(AMH, {{268, 19}, {300, 11}, {319, 38}}, 0.55)
rim(AMR, {{178, -43}, {250, -51}, {291, -39}}, 0.55)
rim(AMR, {{178, -60}, {215, -64}, {250, -50}}, 0.4)
rim(AMR, {{132, -31}, {177, -33}}, 0.4)
rim(AMR, {{14, -31}, {80, -35}, {148, -27}}, 0.4)
rim(AMR, {{-9, -36}, {13, -34}}, 0.45)
rim(AMR, {{290, 18}, {336, 69}, {390, 95}}, 0.4)
rim(AMR, {{389, 93}, {408, 91}}, 0.45)
-- the open gauntlet: splayed fingers on the grating
local GMT = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"lead white",0.35}}
local fg = brush{kind="rigger", width=1.3, point=0.8}
for i, a in ipairs({-0.5, -0.15, 0.2, 0.55}) do
  local base = G(410, 98 + i*5)
  fg:load(GMT, 0.9) fg:stroke({base, {base[1] + math.cos(a)*11, base[2] + math.sin(a)*11 + 2}}, {pressure={0.6, 0.4}})
end
-- spent casings
local BR = pile{{"raw sienna",1},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.1}}
local BG = pile{{"lead white",1.2},{"yellow ochre",0.6},{"Mars orange",0.2}}
local cs = brush{kind="round", width=1.5, point=0.3}
local gls = brush{kind="round", width=0.8, point=0.3}
for i = 1, 26 do
  local x, y = rand(300, 780), rand(380, 558)
  if FRAME:grow(3):at(x, y) < 0.1 and TAB3:grow(2):at(x, y) < 0.1 then
    local a = rand(0, math.pi)
    local L = 2.6 + (y - 380)*0.014
    cs:load(BR, 0.9) cs:stroke({{x - math.cos(a)*L/2, y - math.sin(a)*L/2}, {x + math.cos(a)*L/2, y + math.sin(a)*L/2}}, {pressure={0.6, 0.6}})
    if i % 2 == 0 then gls:load(BG, 0.9) gls:touch(x + math.cos(a)*L*0.3, y + math.sin(a)*L*0.3 - 0.5, {pressure=0.4}) end
  end
end
local vis = brush{kind="rigger", width=1.0, point=1}
vis:load(pile{{"bone black",2.5},{"ultramarine blue",0.3}}, 0.9) vis:stroke(gl({{326, -12}, {340, -2}, {344, 10}}), {pressure={0.6, 0.5}})

--@ chunk 14
print(wait(5*24*60))
-- a soft lamp glow: short radial strokes just lighter than the wall, then blended along the radius
local GLW = pile{{"Mars orange",0.8},{"burnt sienna",0.3},{"bone black",0.25},{"lead white",0.45}}
local hous = poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true)
local ann = (ellipse(906, 126, 30, 27) - hous:grow(0.8)) * RWALL
local b = brush{kind="filbert", width=2.2, stiffness=0.5}
for k = 0, 35 do
  local a = k/36*2*math.pi + rand(-0.05, 0.05)
  local r0, r1 = rand(15, 18), rand(22, 28)
  b:reload(GLW, 0.6)
  b:stroke({{906 + math.cos(a)*r0, 126 + math.sin(a)*r0*0.9}, {906 + math.cos(a)*r1, 126 + math.sin(a)*r1*0.9}}, {pressure={0.45, 0.05}, clip=ann})
end
blend(ann, {angle=function(x,y) return math.atan(y - 126, x - 906) end, tool={kind="badger", width=5}, length={8, 14}})
-- the seed's glow, a touch warmer
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
local SW = pile{{"Mars orange",1},{"cadmium yellow",0.25},{"lead white",0.35},{"burnt sienna",0.2}}
local g = brush{kind="filbert", width=3, stiffness=0.5}
g:load(SW, 0.9) g:stroke({{684, 288}, {696, 288}}, {pressure={0.55, 0.55}, clip=door})
local g2 = brush{kind="round", width=1.6, point=0.3}
g2:load(pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.6}}, 0.9) g2:touch(690, 287.5, {pressure=0.5})

--@ chunk 15
print(wait(5*24*60))
-- the second frame, kneeling over the first, reaching for the rosary
local function off(pts, ox, oy) local o = {} for _, p in ipairs(pts) do o[#o+1] = {p[1] + ox, p[2] + oy} end return o end
NP = {
 {"restArm", "limb", {{808, 352}, {800, 410}, {762, 460}}, 8, 7},
 {"backThigh", "limb", {{812, 452}, {826, 528}}, 12, 10},
 {"backShin", "limb", {{826, 528}, {882, 540}}, 9, 7},
 {"backFoot", "poly", {{878, 530}, {898, 532}, {900, 548}, {880, 548}}},
 {"torso", "poly", {{762, 338}, {806, 326}, {828, 360}, {824, 436}, {784, 442}, {760, 398}}},
 {"pelvis", "poly", {{780, 430}, {822, 428}, {828, 462}, {784, 468}}},
 {"frontThigh", "limb", {{792, 456}, {752, 466}}, 12, 10},
 {"frontShin", "limb", {{752, 466}, {748, 536}}, 9, 8},
 {"frontFoot", "poly", {{730, 534}, {764, 532}, {766, 548}, {728, 548}}},
 {"neck", "limb", {{764, 342}, {748, 334}}, 6, 6},
 {"head", "poly", {{722, 318}, {748, 311}, {761, 330}, {753, 352}, {730, 357}, {717, 340}}},
 {"reachArm", "limb", {{770, 352}, {744, 410}, {716, 468}}, 9, 7},
 {"hand", "poly", {{704, 466}, {722, 464}, {726, 482}, {708, 488}}},
 {"paul", "poly", {{752, 342}, {784, 336}, {790, 362}, {764, 374}}},
}
function npart(p, ox, oy)
  if p[2] == "limb" then return limb(off(p[3], ox or 0, oy or 0), p[4], p[5]) end
  return poly(off(p[3], ox or 0, oy or 0), true)
end
local all = nil
for _, p in ipairs(NP) do local m = npart(p) all = all and (all + m) or m end
NF = all
-- its shadow on the deck, thrown down and left by the lamp, and contact darks under knee and feet
local sh = poly({{735, 548}, {900, 550}, {880, 562}, {600, 562}, {640, 548}}, true) * FLOOR - FRAME - NF
work(sh:soften(3), {hand="body", pile=SHD, coverage=3, fill=true, clip=FLOOR - NF, angle=0, length={8, 16}, tool="filbert 5"})
ND = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.35}}
work(NF, {hand="detail", pile=ND, coverage=4, fill=true, clip=NF, tool={kind="round", width=1.6}, length={2, 6}})

--@ chunk 16
print(wait(8*24*60), drying(790,400))
-- clean plate: lit planes toward the lamp (up and right), a cool mid plane, the far side dark
local NM = pile{{"lead white",1},{"bone black",0.7},{"ultramarine blue",0.3}}
local NL = pile{{"lead white",2},{"bone black",0.25},{"ultramarine ash",0.2},{"yellow ochre",0.12}}
local mid, lit = nil, nil
for _, p in ipairs(NP) do
  local a = npart(p)
  local m1 = a - npart(p, -9, 9)
  local m2 = a - npart(p, -4, 4)
  mid = mid and (mid + m1) or m1
  lit = lit and (lit + m2) or m2
end
mid = mid * NF
lit = lit * NF
work(mid, {hand="detail", pile=NM, coverage=4, fill=true, clip=mid, tool={kind="round", width=1.3}, length={2, 5}})

--@ chunk 17
print(wait(6*24*60), drying(790,400))
local NL = pile{{"lead white",2},{"bone black",0.25},{"ultramarine ash",0.2},{"yellow ochre",0.12}}
local lit = nil
for _, p in ipairs(NP) do local m = npart(p) - npart(p, -4, 4) lit = lit and (lit + m) or m end
lit = lit * NF
work(lit, {hand="detail", pile=NL, coverage=4, fill=true, clip=lit, tool={kind="round", width=1.1}, length={2, 4}})

--@ chunk 18
print(wait(6*24*60), drying(790,400))
local r = brush{kind="rigger", width=0.8, point=1}
local function ln(p, pts, pr) r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.8}, clip=NF}) end
-- plate seams, still faintly warm from the fabricator
local SW = pile{{"Mars orange",0.6},{"burnt sienna",0.3},{"bone black",0.6},{"lead white",0.15}}
local JD = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
for _, s in ipairs({
  {{768, 380}, {820, 372}}, {{776, 410}, {822, 404}}, {{790, 334}, {800, 436}},
  {{744, 408}, {752, 404}}, {{752, 468}, {760, 474}}, {{818, 492}, {830, 488}}, {{840, 532}, {846, 540}},
  {{730, 334}, {756, 326}},
}) do ln(JD, s, 0.5) end
for _, s in ipairs({{{769, 382}, {818, 374}}, {{791, 340}, {799, 430}}, {{778, 412}, {820, 406}}}) do ln(SW, s, 0.35) end
-- visor slit on the bowed head, dark; the optic lit and alive, a warm-white point looking down
ln(JD, {{722, 340}, {738, 344}, {750, 340}}, 0.55)
local OP = pile{{"lead white",2},{"cadmium yellow",0.3},{"zinc white",1}}
local o = brush{kind="round", width=1.6, point=0.3}
o:load(OP, 0.95) o:touch(731, 344, {pressure=0.6})
-- fingers closing on the rosary
local NM = pile{{"lead white",1},{"bone black",0.7},{"ultramarine blue",0.3}}
local fg = brush{kind="rigger", width=1.2, point=0.8}
for i = 0, 3 do fg:load(NM, 0.9) fg:stroke({{706 + i*4.5, 486}, {705 + i*4.5, 494}}, {pressure={0.6, 0.4}}) end
-- amber rim along the upper right edges, from the lamp
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8}}
local rr = brush{kind="rigger", width=0.9, point=1}
local function rim(pts, pr) rr:load(AMH, 0.9) rr:stroke(pts, {pressure={pr*0.3, pr, pr*0.4}}) end
rim({{764, 336}, {806, 325}, {828, 358}, {825, 430}}, 0.6)
rim({{723, 316}, {748, 309}, {762, 328}}, 0.6)
rim({{754, 340}, {784, 334}, {791, 358}}, 0.55)
rim({{813, 450}, {828, 462}, {832, 526}}, 0.5)
rim({{828, 524}, {882, 534}, {898, 530}}, 0.45)
rim({{780, 448}, {752, 458}, {756, 468}, {754, 532}}, 0.4)
rim({{810, 352}, {806, 408}}, 0.35)

--@ chunk 19
print(wait(5*24*60))
-- the rosary lifted from the open gauntlet: hanging from the new hand, still trailing to the old
local BEAD = pile{{"lead white",1.2},{"yellow ochre",0.3},{"bone black",0.2},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local r = brush{kind="rigger", width=0.7, point=1}
local path = {{714, 494}, {712, 504}, {716, 512}, {724, 506}, {722, 498}}
r:load(CHN, 0.8) r:stroke(path, {pressure={0.3, 0.3}})
local tail = {{714, 494}, {718, 506}, {723, 516}}
local b = brush{kind="round", width=1.8, point=0.4}
for i = 1, #path - 1 do for k = 0, 2 do
  local t = k/3
  local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t}
  b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.5})
end end
r:load(CHN, 0.8) r:stroke({{716, 512}, {712, 522}, {710, 528}}, {pressure={0.3, 0.3}})
local cr = brush{kind="rigger", width=1.2, point=1}
cr:load(BEAD, 0.95) cr:stroke({{710, 527}, {710, 540}}, {pressure={0.65, 0.65}})
cr:load(BEAD, 0.95) cr:stroke({{705, 531}, {715, 531}}, {pressure={0.65, 0.65}})
-- a little steam lifting off the fresh plate
local ST = pile{{"lead white",1},{"ultramarine ash",0.2},{"Mars orange",0.04},medium=0.6}
local s = brush{kind="filbert", width=4, stiffness=0.2}
for _, w in ipairs({{{796, 330}, {790, 300}, {800, 270}}, {{812, 340}, {822, 310}, {816, 280}, {826, 255}}, {{824, 380}, {840, 350}, {836, 320}}, {{770, 336}, {766, 310}, {776, 288}}}) do
  s:load(ST, 0.22)
  s:stroke(w, {pressure={0.25, 0.12, 0.0}, ramps={0.2, 0.6}})
end

--@ chunk 20
local clipm = -NF:grow(0.5)
local b = brush{kind="filbert", width=6, stiffness=0.5}
for _, w in ipairs({{{796, 330}, {790, 300}, {800, 270}}, {{812, 340}, {822, 310}, {816, 280}, {826, 255}}, {{824, 380}, {840, 350}, {836, 320}}, {{770, 336}, {766, 310}, {776, 288}}}) do
  for k = 1, 2 do b:reload(WL[2], 0.9) b:stroke(w, {pressure={0.8, 0.8}, clip=clipm}) end
end
-- lit planes knocked down to a warm mid: clean plate, not glowing
local NW = pile{{"lead white",1},{"bone black",0.5},{"burnt sienna",0.15},{"yellow ochre",0.1},{"ultramarine blue",0.1}}
local lit = nil
for _, p in ipairs(NP) do local m = npart(p) - npart(p, -4, 4) lit = lit and (lit + m) or m end
lit = lit * NF
work(lit, {hand="detail", pile=NW, coverage=4.5, fill=true, clip=lit, tool={kind="round", width=1.1}, length={2, 4}})

--@ chunk 21
print(wait(8*24*60), drying(790,400), drying(800,300))
-- thin amber rims only on the edges that face the lamp, and a single bright clean edge on the shoulder
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8}}
local CL = pile{{"lead white",2},{"ultramarine ash",0.2},{"bone black",0.1}}
local rr = brush{kind="rigger", width=0.7, point=1}
local function rim(p, pts, pr) rr:load(p, 0.9) rr:stroke(pts, {pressure={pr*0.3, pr, pr*0.4}}) end
rim(AMH, {{764, 336}, {806, 325}, {828, 358}, {825, 430}}, 0.55)
rim(AMH, {{723, 316}, {748, 309}, {762, 328}}, 0.55)
rim(AMH, {{813, 450}, {828, 462}, {832, 526}}, 0.45)
rim(AMH, {{828, 524}, {882, 534}, {898, 530}}, 0.4)
rim(CL, {{756, 341}, {784, 335}, {790, 356}}, 0.5)
-- the optic restated
local OP = pile{{"lead white",2},{"cadmium yellow",0.3},{"zinc white",1}}
local o = brush{kind="round", width=1.6, point=0.3}
o:load(OP, 0.95) o:touch(731, 344, {pressure=0.6})
-- a faint breath of steam off the shoulders, barely lighter than the dark
local ST = pile{{"bone black",1},{"ultramarine ash",0.4},{"lead white",0.45},{"Mars brown",0.2}}
local s = brush{kind="filbert", width=3, stiffness=0.3}
for _, w in ipairs({{{790, 322}, {786, 300}, {794, 282}}, {{812, 330}, {818, 308}, {812, 290}}}) do
  s:load(ST, 0.5)
  s:stroke(w, {pressure={0.35, 0.2, 0.0}, ramps={0.2, 0.7}, clip=-NF:grow(0.5)})
end

--@ chunk 22
print(wait(4*24*60)) local clipm = RWALL - NF:grow(0.5) local b = brush{kind="filbert", width=7, stiffness=0.5} for _, w in ipairs({{{796, 330}, {790, 300}, {800, 270}}, {{812, 340}, {822, 310}, {816, 280}, {826, 255}}, {{824, 380}, {840, 350}, {836, 320}}, {{770, 336}, {766, 310}, {776, 288}}}) do for k = 1, 2 do b:reload(WL[3], 0.9) b:stroke(w, {pressure={0.8, 0.8}, clip=clipm}) end end

--@ chunk 23
-- Pass 2.1 (on dry paint): paint the wisps out with the wall's own lamp-falloff piles, restate ribs; core the new frame
local W = nil
for _, w in ipairs({{{796, 330}, {790, 300}, {800, 270}}, {{812, 340}, {822, 310}, {816, 280}, {826, 255}}, {{824, 380}, {840, 350}, {836, 320}}, {{770, 336}, {766, 310}, {776, 288}}}) do
  local rb = ribbon(w, 9) W = W and (W + rb) or rb
end
local SM = W * RWALL - NF:grow(0.8)
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local cells = {}
for y = 230, 400, 2.4 do for x = 740, 860, 2.4 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if SM:at(xx, yy) > 0.3 then
    local dx, dy = xx - LAMP[1], (yy - LAMP[2])*0.85
    local d = math.sqrt(dx*dx + dy*dy)
    local t = 5 - d/62 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 0.5), 1, 5)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3.5, stiffness=0.5}
for i = 1, 5 do if g[i] then
  b:reload(WL[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(WL[i], 0.9) end
    local a = toVP(c.x, c.y) + randn(0, 0.05)
    local h = rand(2.5, 5)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=SM})
  end
end end
print(#cells)
-- the new frame's core: clean grey plate, darker in the cores
NC = pile{{"lead white",0.7},{"bone black",1},{"ultramarine blue",0.3}}
work(NF, {hand="detail", pile=NC, coverage=4.5, fill=true, clip=NF, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 24
print(wait(8*24*60), drying(790,400), drying(800,300))
-- ribs restated where the wisps were
local W = nil
for _, w in ipairs({{{796, 330}, {790, 300}, {800, 270}}, {{812, 340}, {822, 310}, {816, 280}, {826, 255}}, {{824, 380}, {840, 350}, {836, 320}}, {{770, 336}, {766, 310}, {776, 288}}}) do
  local rb = ribbon(w, 10) W = W and (W + rb) or rb
end
local SM = W * RWALL - NF:grow(0.8)
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function wallpt(t, h) local x = 1040 + (FAR[3] - 1040)*t local yb = 600 + (FAR[4] - 600)*t local yt = -40 + (FAR[2] + 40)*t return {x, yb + (yt - yb)*h} end
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(t, 0.02), wallpt(t, 0.98)}, {pressure={0.7, 0.7}, clip=SM})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(t + 0.004, 0.02), wallpt(t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=SM})
  t = t + 0.1*(1 - t*0.85)
end
-- mid plane on each plate, the side turned up toward the lamp
NG = pile{{"lead white",1},{"bone black",0.55},{"ultramarine blue",0.2},{"yellow ochre",0.05}}
local mid = nil
for _, p in ipairs(NP) do local m = npart(p) - npart(p, -5, 9) mid = mid and (mid + m) or m end
mid = mid * NF
work(mid, {hand="detail", pile=NG, coverage=4, fill=true, clip=mid, tool={kind="round", width=1.2}, length={2, 4}})

--@ chunk 25
print(wait(8*24*60), drying(790,400))
NC2 = pile{{"lead white",0.22},{"bone black",1},{"ultramarine blue",0.3}}
work(NF, {hand="detail", pile=NC2, coverage=5, fill=true, clip=NF, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 26
print(wait(8*24*60), drying(790,400))
NG2 = pile{{"lead white",0.6},{"bone black",0.8},{"ultramarine blue",0.25},{"yellow ochre",0.05}}
local mid = nil
for _, p in ipairs(NP) do local m = npart(p) - npart(p, -3, 6) mid = mid and (mid + m) or m end
mid = mid * NF
work(mid, {hand="detail", pile=NG2, coverage=4.5, fill=true, clip=mid, tool={kind="round", width=1.1}, length={2, 4}})

--@ chunk 27
print(wait(8*24*60), drying(790,400))
local JD = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local NG = NG2
local NH = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.2}}
local r = brush{kind="rigger", width=0.8, point=1}
local function ln(p, pts, pr, w) if w then r = brush{kind="rigger", width=w, point=1} end r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.85}, clip=NF:grow(0.5)}) end
-- helm: brow ridge, visor slit, cheek plate
ln(JD, {{719, 336}, {735, 341}, {752, 337}}, 0.75, 1.2)
ln(NH, {{721, 324}, {742, 316}, {756, 326}}, 0.4, 0.8)
ln(JD, {{742, 346}, {748, 354}}, 0.5, 0.7)
-- gorget: stacked rings at the neck
for i = 0, 2 do ln(JD, {{748 + i*5, 334 + i*1.5}, {752 + i*5, 346 + i*1.5}}, 0.45, 0.8) end
-- pauldron: three lames over the shoulder
for i, o in ipairs({0, 7, 14}) do ln(JD, {{756, 350 + o*0.6}, {770, 345 + o}, {788, 348 + o}}, 0.45, 0.8) end
-- breastplate: central ridge, lit on its lamp side; lower edge
ln(JD, {{790, 340}, {794, 380}, {798, 430}}, 0.5, 0.9)
ln(NH, {{793, 340}, {797, 380}, {801, 428}}, 0.35, 0.6)
ln(JD, {{766, 404}, {790, 432}, {822, 430}}, 0.55, 1.0)
-- faulds: overlapping lames across the hips
for i = 0, 2 do ln(JD, {{782, 440 + i*8}, {804, 438 + i*8}, {826, 440 + i*8}}, 0.5, 0.9) end
-- thighs: plate edges; knee cops; greaves with a shin ridge
ln(JD, {{800, 460}, {770, 468}}, 0.45, 0.8)
ln(JD, {{816, 470}, {822, 512}}, 0.45, 0.8)
for _, k in ipairs({{752, 466, 9, 8}, {826, 528, 9, 8}}) do
  local pts = {} for j = 0, 12 do local a = j/12*2*math.pi pts[#pts+1] = {k[1] + k[3]*math.cos(a), k[2] + k[4]*math.sin(a)} end
  local m = poly(pts, true)
  work(m, {hand="detail", pile=NG, coverage=4, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 3}})
  ln(JD, {{k[1] - k[3], k[2] + 2}, {k[1], k[2] + k[4]}, {k[1] + k[3], k[2] + 2}}, 0.5, 0.8)
end
ln(JD, {{750, 480}, {749, 530}}, 0.4, 0.7)
ln(JD, {{838, 534}, {878, 540}}, 0.4, 0.7)
-- reaching arm: vambrace edge, elbow; gauntlet with finger lames
ln(JD, {{756, 384}, {752, 392}}, 0.5, 0.8)
ln(JD, {{732, 438}, {740, 442}}, 0.5, 0.8)
for i = 0, 3 do ln(JD, {{705, 471 + i*4}, {723, 469 + i*4}}, 0.4, 0.6) end
-- heat: a faint warm glow along a few seams
local SW = pile{{"Mars orange",0.7},{"burnt sienna",0.3},{"bone black",0.5},{"lead white",0.2}}
ln(SW, {{768, 404}, {790, 431}}, 0.35, 0.6)
ln(SW, {{784, 441}, {804, 439}}, 0.3, 0.6)
ln(SW, {{749, 336}, {752, 344}}, 0.3, 0.5)

--@ chunk 28
print(wait(6*24*60), drying(790,400))
-- amber only on the edges facing the lamp (upper right)
local AMH = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8}}
local rr = brush{kind="rigger", width=0.8, point=1}
local function rim(pts, pr) rr:load(AMH, 0.9) rr:stroke(pts, {pressure={pr*0.3, pr, pr*0.3}}) end
rim({{780, 330}, {806, 326}, {826, 356}}, 0.6)
rim({{826, 362}, {825, 425}}, 0.45)
rim({{742, 314}, {749, 311}, {761, 329}}, 0.55)
rim({{772, 337}, {784, 336}, {790, 358}}, 0.5)
rim({{822, 452}, {829, 470}, {832, 520}}, 0.4)
rim({{858, 534}, {882, 534}, {898, 531}}, 0.35)
-- the optic, warm and alive on the visor slit
local OP = pile{{"lead white",2},{"cadmium yellow",0.35},{"zinc white",1}}
local o = brush{kind="round", width=1.8, point=0.3}
o:load(OP, 0.95) o:touch(737, 340, {pressure=0.6})
-- the rosary, larger: wrapped through the fingers, the crucifix swinging below
local BEAD = pile{{"lead white",1.3},{"yellow ochre",0.3},{"bone black",0.15},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local c = brush{kind="rigger", width=0.8, point=1}
local loop = {{706, 486}, {701, 498}, {704, 510}, {714, 514}, {722, 506}, {723, 492}}
c:load(CHN, 0.85) c:stroke(loop, {pressure={0.35, 0.35}})
local drop = {{714, 514}, {716, 524}, {717, 533}}
c:load(CHN, 0.85) c:stroke(drop, {pressure={0.35, 0.35}})
local b = brush{kind="round", width=2.6, point=0.4}
local function beads(path, per)
  for i = 1, #path - 1 do for k = 0, per - 1 do
    local t = k/per
    local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t}
    b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.55})
  end end
end
beads(loop, 2) beads(drop, 2)
local cr = brush{kind="filbert", width=1.8, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({{717.5, 534}, {718.5, 552}}, {pressure={0.75, 0.75}})
cr:load(BEAD, 0.95) cr:stroke({{711, 539}, {725, 538.5}}, {pressure={0.75, 0.75}})
local hl = brush{kind="rigger", width=0.5, point=1}
hl:load(pile{{"lead white",2},{"cadmium yellow",0.4}}, 0.9) hl:stroke({{719, 535}, {719.6, 545}}, {pressure={0.4, 0.3}})

--@ chunk 29
local m = ellipse(708, 532, 5.5, 8.5) * mask(function(x,y) return x < 711.5 and 1 or 0 end) - NF:grow(0.5) work(m, {hand="detail", pile=FL, coverage=5, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 3}})
