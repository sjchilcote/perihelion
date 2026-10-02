-- easel session "first_death": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=1203, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}, um=45, apply="brush", texture=0.35}}}
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
print(wait(3*24*60))
FO = {300, 505}
FA = {0.97, -0.244}
FN = {0.244, 0.97}
function F(u, v) return {FO[1] + u*FA[1] + v*FN[1], FO[2] + u*FA[2] + v*FN[2]} end
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
CD = pile{{"Mars red",1},{"rose madder",0.6},{"bone black",0.9}}
-- cast shadow on the deck (lamp is up and to the right)
local sh = poly({F(-10, 20), F(130, 40), F(250, 30), F(270, 10), F(250, -8), F(120, -10), F(-10, -2)}, true)
work(sh:soften(4), {hand="body", pile=SHD, coverage=3, fill=true, angle=math.atan(FA[2], FA[1]), length={8, 18}, tool="filbert 5"})
LEG1 = limb({F(0, -8), F(60, -9), F(120, -7)}, 5, 8)
LEG2 = limb({F(2, 12), F(55, 18), F(118, 7)}, 5, 8)
TORSO = poly({F(112, -20), F(215, -18), F(222, 0), F(215, 20), F(112, 18)}, true)
HEAD = poly({F(228, -10), F(246, -13), F(256, -3), F(252, 10), F(234, 11), F(226, 2)}, true)
NECK = limb({F(212, 0), F(230, 0)}, 5, 5)
ARM1 = limb({F(210, -22), F(170, -30), F(135, -26)}, 5, 4)
ARM2 = limb({F(205, 18), F(185, 52), F(160, 78)}, 6, 5)
HAND = poly({F(150, 76), F(162, 72), F(166, 86), F(152, 92)}, true)
BODY = LEG1 + LEG2 + TORSO + HEAD + NECK + ARM1 + ARM2 + HAND
work(BODY, {hand="detail", pile=MD, coverage=4, fill=true, clip=BODY, tool={kind="round", width=1.6}, length={2, 6}})
TAB = poly({F(108, -30), F(150, -36), F(205, -30), F(222, -22), F(220, 6), F(226, 28), F(204, 40), F(176, 46), F(150, 50), F(118, 44), F(98, 30), F(104, 10)}, true)
work(TAB, {hand="detail", pile=CD, coverage=4, fill=true, clip=TAB, tool={kind="round", width=1.8}, length={2, 6}})

--@ chunk 4
print(wait(12*24*60), drying(480,450), drying(380,480))
CDK = pile{{"Mars red",0.7},{"rose madder",0.5},{"bone black",1.4},{"ultramarine blue",0.1}}
CM = pile{{"Mars red",1},{"rose madder",0.5},{"bone black",0.8}}
-- tabard repainted darker in long fold strokes along the body
local ang = math.atan(FA[2], FA[1])
work(TAB:shrink(0.5), {hand="body", pile=CDK, coverage=3.5, fill=true, clip=TAB, angle=ang, length={10, 30}, tool="filbert 5"})
-- the raised folds catching a little of the lamp (upper-right side of each ridge)
local b = brush{kind="filbert", width=3, stiffness=0.5}
for i, v in ipairs({-24, -12, 2, 16, 30}) do
  b:reload(CM, 0.85)
  local u0 = 112 + rand(-4, 4)
  local u1 = (v > 20) and 196 or 214
  b:stroke({F(u0, v + rand(-2, 2)), F((u0 + u1)/2, v + rand(-3, 3)), F(u1, v + rand(-2, 2))}, {pressure={0.4, 0.65, 0.3}, swell={0.6, 1, 0.6}, clip=TAB})
end
-- pauldrons and helmet shell, gunmetal
local MM = pile{{"bone black",1.5},{"ultramarine blue",0.5},{"lead white",0.3}}
PAUL1 = poly({F(198, -30), F(220, -28), F(224, -16), F(204, -14)}, true)
PAUL2 = poly({F(196, 16), F(220, 14), F(226, 28), F(202, 32)}, true)
local pm = PAUL1 + PAUL2
work(pm, {hand="detail", pile=MM, coverage=4, fill=true, clip=pm, tool={kind="round", width=1.2}, length={2, 5}})

--@ chunk 5
print(wait(40*24*60), drying(480,450), drying(380,480), drying(530,430))
CDK2 = pile{{"Mars red",0.6},{"rose madder",0.4},{"bone black",1.6},{"bone brown",0.3}}
local ang = math.atan(FA[2], FA[1])
-- the tabard as cloth: narrow over the shoulders, spreading out on the deck at its hem, ragged
TAB2 = poly({F(204, -26), F(214, -12), F(214, 12), F(206, 26), F(180, 34), F(150, 48), F(124, 60), F(104, 52), F(96, 34), F(100, 14), F(98, -8), F(104, -28), F(130, -36), F(170, -32)}, true)
local old = TAB - TAB2
work(old:grow(1), {hand="detail", pile=FL, coverage=4, fill=true, clip=old:grow(1) - TORSO - PAUL1 - PAUL2, tool={kind="round", width=1.6}, length={2, 5}})
work(TAB2, {hand="detail", pile=CDK2, coverage=4.5, fill=true, clip=TAB2, tool={kind="round", width=1.8}, length={3, 8}, angle=ang})
-- pauldrons darkened back to gunmetal
work(PAUL1 + PAUL2, {hand="detail", pile=MD, coverage=4, fill=true, clip=PAUL1 + PAUL2, tool={kind="round", width=1.2}, length={2, 5}})

--@ chunk 6
print(wait(5*24*60))
local ON = (BODY + TAB2):grow(1.5)
local floorc = FLOOR - ON
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
-- the killer's shadow on the lit wall: too many joints, long, stretched toward the far end
local SHM = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
local shm = nil
local function add(m) shm = shm and (shm + m) or m end
add(poly({{790, 150}, {845, 140}, {870, 160}, {840, 182}, {792, 178}}, true))
local legs = {
 {{805, 175}, {780, 230}, {800, 300}, {770, 380}},
 {{820, 178}, {840, 240}, {812, 300}, {828, 360}},
 {{838, 175}, {880, 228}, {870, 290}, {905, 345}},
 {{800, 168}, {760, 210}, {745, 270}, {738, 320}},
 {{850, 168}, {905, 200}, {930, 260}, {960, 300}},
 {{830, 150}, {800, 105}, {770, 80}, {742, 120}, {735, 175}},
}
for _, L in ipairs(legs) do add(limb(L, 3.4, 1.6)) end
add(limb({{795, 158}, {760, 150}, {740, 165}, {732, 195}}, 4, 2.4))
add(poly({{722, 190}, {738, 186}, {742, 202}, {726, 206}}, true))
SHADOWM = shm * RWALL
work(SHADOWM:soften(0.8), {hand="detail", pile=SHM, coverage=4, fill=true, clip=RWALL, tool={kind="round", width=1.4}, length={2, 6}})

--@ chunk 7
local CP = pile{{"bone black",2.6},{"ultramarine blue",0.6},{"Mars brown",0.2},{"lead white",0.03}}
work(CEIL, {hand="body", pile=CP, coverage=3.2, fill=true, clip=CEIL, angle=function(x,y) return math.atan(VP[2] - y, VP[1] - x) end, length={25, 60}, tool="filbert 9"})
-- the far end: a dark doorway with the seed's faint warm glow deep beyond it
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
work(door, {hand="detail", pile=SHD, coverage=4, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 8
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
  c:load(CH, 0.9) c:stroke({{x, 395 + i*12}, {x + 9, 384 + i*12}, {x + 18, 395 + i*12}}, {pressure={0.6, 0.6}, clip=RWALL - SHADOWM})
end

--@ chunk 9
print(wait(10*24*60), drying(480,450), drying(690,285))
-- the far glow, much quieter: a dim warm floor-spill with one small warmer core
local door = poly({{FAR[1] + 18, FAR[2] + 14}, {FAR[3] - 18, FAR[2] + 14}, {FAR[3] - 18, FAR[4]}, {FAR[1] + 18, FAR[4]}})
local DIM = pile{{"burnt sienna",0.6},{"bone black",1.4},{"Mars orange",0.3},{"ultramarine blue",0.1}}
local gm = ellipse(690, 284, 26, 12) * door
work(gm, {hand="detail", pile=DIM, coverage=4, fill=true, clip=door, tool={kind="round", width=1.4}, length={2, 5}})
local GW2 = pile{{"Mars orange",1},{"burnt sienna",0.4},{"lead white",0.2},{"bone black",0.3}}
local g = brush{kind="filbert", width=3, stiffness=0.5}
g:load(GW2, 0.9) g:stroke({{682, 288}, {698, 288}}, {pressure={0.5, 0.5}, clip=door})
-- the fallen frame, in the lamp's last light
local AMR = pile{{"Mars orange",0.7},{"burnt sienna",0.4},{"lead white",0.35},{"bone black",0.25}}
local GMT = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"lead white",0.35}}
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local r = brush{kind="rigger", width=0.8, point=1}
local function line(p, pts, pr) r:load(p, 0.9) r:stroke(pts, {pressure={pr or 0.45, (pr or 0.45)*0.8}}) end
-- rims on the lamp-facing edges
line(AMR, {F(230, -11), F(246, -14), F(256, -4)}, 0.55)
line(AMR, {F(200, -30), F(220, -28), F(225, -18)}, 0.5)
line(AMR, {F(199, 15), F(220, 13), F(227, 24)}, 0.45)
line(GMT, {F(4, -14), F(60, -15.5), F(118, -13)}, 0.4)
line(GMT, {F(6, 6), F(55, 11), F(116, 0)}, 0.35)
line(AMR, {F(210, 12), F(190, 46), F(166, 71)}, 0.4)
line(GMT, {F(208, -28), F(170, -36), F(137, -32)}, 0.35)
-- joints: knees, elbow, plate breaks
line(JD, {F(60, -16), F(60, -2)}, 0.5)
line(JD, {F(56, 6), F(54, 24)}, 0.5)
line(JD, {F(178, 44), F(192, 56)}, 0.5)
line(JD, {F(30, -15), F(30, -3)}, 0.35)
line(JD, {F(92, -15), F(92, -1)}, 0.35)
-- boots
local boot = poly({F(-14, -15), F(4, -15), F(4, -1), F(-12, -2)}, true) + poly({F(-12, 6), F(6, 6), F(6, 19), F(-10, 20)}, true)
work(boot, {hand="detail", pile=JD, coverage=4, fill=true, clip=boot, tool={kind="round", width=1.0}, length={1.5, 3}})
line(GMT, {F(-13, -15), F(3, -15)}, 0.4)
-- helmet visor slit
line(JD, {F(240, -3), F(250, -6), F(255, 0)}, 0.5)
-- the tabard: a bone cross and bone hem, dark folds
local BND = pile{{"lead white",0.7},{"yellow ochre",0.3},{"raw sienna",0.15},{"bone black",0.35}}
local CDF = pile{{"bone black",2},{"Mars red",0.4},{"rose madder",0.2}}
local f = brush{kind="filbert", width=2.4, stiffness=0.5}
for _, fl in ipairs({{{108, 30}, {150, 26}, {190, 22}}, {{112, -10}, {150, -4}, {176, -8}}, {{100, 46}, {130, 44}, {160, 38}}}) do
  f:load(CDF, 0.85) f:stroke({F(fl[1][1], fl[1][2]), F(fl[2][1], fl[2][2]), F(fl[3][1], fl[3][2])}, {pressure={0.1, 0.55, 0.1}, clip=TAB2})
end
local cb = brush{kind="filbert", width=3.2, stiffness=0.5}
cb:load(BND, 0.9) cb:stroke({F(140, 0), F(200, -1)}, {pressure={0.7, 0.7}, clip=TAB2})
cb:load(BND, 0.9) cb:stroke({F(186, -14), F(186, 13)}, {pressure={0.7, 0.7}, clip=TAB2})
local hem = brush{kind="rigger", width=1.1, point=1}
hem:load(BND, 0.9) hem:stroke({F(204, 27), F(180, 35), F(150, 49), F(124, 61), F(104, 53), F(96, 35)}, {pressure={0.4, 0.4}})

--@ chunk 10
local f = brush{kind="filbert", width=2.6, stiffness=0.5}
local inner = TAB2:shrink(1.2)
for _, pts in ipairs({
  {F(210, 12), F(190, 46), F(166, 71)},
  {F(4, -14), F(60, -15.5), F(118, -13)},
  {F(6, 6), F(55, 11), F(116, 0)},
  {F(208, -28), F(170, -36), F(137, -32)},
}) do
  for k = 1, 2 do f:reload(CDK2, 0.9) f:stroke(pts, {pressure={0.75, 0.75}, clip=inner}) end
end

--@ chunk 11
print(wait(6*24*60))
-- gauntlet fingers curled on the rosary; the rosary run out across the deck
local GMT = pile{{"bone black",1.3},{"ultramarine blue",0.5},{"lead white",0.35}}
local AMR = pile{{"Mars orange",0.7},{"burnt sienna",0.4},{"lead white",0.35},{"bone black",0.25}}
local r = brush{kind="rigger", width=0.7, point=1}
for i = 0, 3 do r:load(GMT, 0.9) r:stroke({F(152 + i*3.5, 88), F(150 + i*3.5, 94)}, {pressure={0.5, 0.3}}) end
r:load(AMR, 0.9) r:stroke({F(151, 77), F(163, 73)}, {pressure={0.5, 0.4}})
local BEAD = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.3},{"Mars orange",0.08}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local path = {F(156, 94), F(150, 106), F(158, 118), F(176, 120), F(190, 110), F(186, 98), F(172, 96)}
r:load(CHN, 0.8) r:stroke(path, {pressure={0.25, 0.25}})
local b = brush{kind="round", width=1.3, point=0.4}
for i = 1, #path - 1 do
  for k = 0, 2 do
    local t = k/3
    local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t}
    b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.45})
  end
end
-- the crucifix at the end of its tail
local tail = {F(150, 106), F(140, 116), F(132, 124)}
r:load(CHN, 0.8) r:stroke(tail, {pressure={0.25, 0.25}})
local c = F(130, 127)
local cr = brush{kind="rigger", width=1.0, point=1}
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 1.5, c[2] - 4}, {c[1] + 1.5, c[2] + 5}}, {pressure={0.6, 0.6}})
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 3.5, c[2] - 0.5}, {c[1] + 3.5, c[2] - 1.5}}, {pressure={0.6, 0.6}})
-- spent casings scattered on the grating, a few catching the lamp
local BR = pile{{"raw sienna",1},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.1}}
local BG = pile{{"lead white",1.2},{"yellow ochre",0.6},{"Mars orange",0.2}}
local cs = brush{kind="round", width=1.3, point=0.3}
local gl = brush{kind="round", width=0.7, point=0.3}
local spots = {}
for i = 1, 22 do
  local u, v = rand(40, 330), rand(28, 150)
  if i % 3 == 0 then u, v = rand(120, 360), rand(-60, -25) end
  local p = F(u, v)
  if TAB2:grow(2):at(p[1], p[2]) < 0.1 and BODY:grow(2):at(p[1], p[2]) < 0.1 and p[2] < 560 then
    local a = rand(0, math.pi)
    local L = 2.4 + (p[2] - 400)*0.012
    cs:load(BR, 0.9) cs:stroke({{p[1] - math.cos(a)*L/2, p[2] - math.sin(a)*L/2}, {p[1] + math.cos(a)*L/2, p[2] + math.sin(a)*L/2}}, {pressure={0.6, 0.6}})
    if i % 2 == 0 then gl:load(BG, 0.9) gl:touch(p[1] + math.cos(a)*L*0.3, p[2] + math.sin(a)*L*0.3 - 0.5, {pressure=0.4}) end
  end
end
-- the optic going dark: one last cold point
local OC = pile{{"zinc white",2},{"cerulean blue",0.5},{"lead white",1}}
local OH = pile{{"cerulean blue",1},{"ultramarine blue",0.5},{"lead white",0.6},{"bone black",0.4},medium=0.5}
local o = F(251, -2)
local h = brush{kind="round", width=4, point=0.2}
h:load(OH, 0.3) h:touch(o[1], o[2], {pressure=0.2})
local p = brush{kind="round", width=1.2, point=0.3}
p:load(OC, 0.95) p:touch(o[1], o[2], {pressure=0.6})

--@ chunk 12
local m = nil
for _, pts in ipairs({
  {F(212, 12), F(190, 46), F(166, 71)},
  {F(2, -14), F(60, -15.5), F(120, -13)},
  {F(4, 6), F(55, 11), F(118, 0)},
  {F(210, -28), F(170, -36), F(135, -32)},
}) do local rb = ribbon(pts, 2.6) m = m and (m + rb) or rb end
local cover = m * TAB2:shrink(1.2)
work(cover, {hand="detail", pile=CDK2, coverage=5, fill=true, clip=cover, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 13
print(wait(4*24*60))
-- the rosary, run out from the gauntlet along the deck (inside the frame this time)
local BEAD = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.3},{"Mars orange",0.08}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local path = {F(158, 84), F(176, 80), F(194, 73), F(210, 64), F(222, 52)}
local r = brush{kind="rigger", width=0.7, point=1}
r:load(CHN, 0.8) r:stroke(path, {pressure={0.25, 0.25}})
local b = brush{kind="round", width=1.4, point=0.4}
for i = 1, #path - 1 do
  for k = 0, 3 do
    local t = k/4
    local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t}
    b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.45})
  end
end
local c = F(226, 46)
local cr = brush{kind="rigger", width=1.1, point=1}
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 4, c[2] + 1}, {c[1] + 5, c[2] - 2}}, {pressure={0.6, 0.6}})
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 0.5, c[2] - 4}, {c[1] + 1.5, c[2] + 3}}, {pressure={0.6, 0.6}})
-- the lamp's amber reaching the deck along the right wall
local FA1 = pile{{"bone black",1.8},{"Mars brown",0.5},{"burnt sienna",0.35},{"lead white",0.1}}
local FA2 = pile{{"bone black",1.3},{"burnt sienna",0.55},{"Mars orange",0.25},{"lead white",0.12}}
local ON = (BODY + TAB2):grow(2)
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

--@ chunk 14
print(wait(4*24*60))
local ON = (BODY + TAB2):grow(2)
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

--@ chunk 15
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.35}}
local HAL = pile{{"Mars orange",0.8},{"burnt sienna",0.3},{"bone black",0.35},{"lead white",0.3}}
local out = RWALL - poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true):grow(0.8) - SHADOWM
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
for k = 0, 23 do
  local a = k/24*2*math.pi
  local r0 = 21 + rand(-2, 2)
  b:load(HAL, 0.85)
  b:stroke({{906 + math.cos(a)*r0, 126 + math.sin(a)*r0*0.9}, {906 + math.cos(a)*(r0 + 9), 126 + math.sin(a)*(r0 + 9)*0.9}}, {pressure={0.6, 0.2}, clip=out})
end
local r = brush{kind="rigger", width=0.8, point=1}
r:load(AMB, 0.9) r:stroke({{892, 112}, {918, 106}, {920, 142}}, {pressure={0.45, 0.45}})
local l = brush{kind="filbert", width=6, stiffness=0.5}
l:load(AH, 0.95) l:stroke({{899, 125}, {913, 123}}, {pressure={0.75, 0.75}})

--@ chunk 16
print(wait(3*24*60))
local hous = poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true)
local ann = (ellipse(906, 126, 34, 31) - hous:grow(0.6)) * RWALL - SHADOWM
work(ann, {hand="detail", pile=WL[5], coverage=4, fill=true, clip=ann, angle=function(x,y) return math.atan(VP[2] - y, VP[1] - x) end, tool={kind="round", width=1.8}, length={3, 7}})

--@ chunk 17
local hous = poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true)
local clipm = RWALL - SHADOWM - hous:grow(0.6)
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
local n = 0
for y = 80, 175, 2.2 do for x = 860, 952, 2.2 do
  local xx, yy = x + rand(-1, 1), y + rand(-1, 1)
  local d = math.sqrt(((xx - 906)/34)^2 + ((yy - 126)/31)^2)
  if d > 0.72 and d < 1.35 then
    local p = (d - 0.72)/0.63 + randn(0, 0.15)
    local pl = (rand(0,1) < p) and WL[3] or ((rand(0,1) < 0.5) and WL[4] or WL[5])
    n = n + 1
    b:reload(pl, 0.8)
    local a = math.atan(VP[2] - yy, VP[1] - xx)
    b:stroke({{xx - math.cos(a)*2.5, yy - math.sin(a)*2.5}, {xx + math.cos(a)*2.5, yy + math.sin(a)*2.5}}, {pressure={0.7, 0.6}, clip=clipm})
  end
end end
print(n)

--@ chunk 18
print(wait(3*24*60))
local hous = poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true)
local clipm = RWALL - SHADOWM - hous:grow(0.6)
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
local n = 0
for y = 80, 175, 2.2 do for x = 860, 952, 2.2 do
  local xx, yy = x + rand(-1, 1), y + rand(-1, 1)
  local d = math.sqrt(((xx - 906)/34)^2 + ((yy - 126)/31)^2)
  if d > 0.6 and d < 1.5 then
    local p = (d - 0.72)/0.63 + randn(0, 0.15)
    local pl = (rand(0,1) < 0.55) and WL[4] or WL[5]
    n = n + 1
    b:reload(pl, 0.8)
    local a = math.atan(VP[2] - yy, VP[1] - xx)
    b:stroke({{xx - math.cos(a)*2.5, yy - math.sin(a)*2.5}, {xx + math.cos(a)*2.5, yy + math.sin(a)*2.5}}, {pressure={0.7, 0.6}, clip=clipm})
  end
end end
print(n)

--@ chunk 19
-- Pass 2.1: clear the old frame and the old shadow back to deck and lit wall
local REG = FLOOR * poly({{270, 345}, {795, 345}, {795, 600}, {270, 600}})
work(REG, {hand="body", pile=FL, coverage=3.5, fill=true, clip=REG, angle=function(x,y) return math.atan(VP[2] - y, VP[1] - x) end, length={12, 30}, tool="filbert 7"})
local SM = SHADOWM:grow(3) * RWALL
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local cells = {}
for y = 60, 480, 2.6 do for x = 700, 1004, 2.6 do
  local xx, yy = x + rand(-1.1,1.1), y + rand(-1.1,1.1)
  if SM:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.3 then
    local dx, dy = xx - LAMP[1], (yy - LAMP[2])*0.85
    local d = math.sqrt(dx*dx + dy*dy)
    local t = 5 - d/62 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 0.5), 1, 5)}
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
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=RWALL})
  end
end end
print(#cells)

--@ chunk 20
print(wait(6*24*60), drying(500,480), drying(820,250))
-- restate the grating, rails and cross bars, in the cleared deck
local REG = FLOOR * poly({{270, 345}, {795, 345}, {795, 600}, {270, 600}})
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
-- restate the wall ribs where the old shadow was
local SM = SHADOWM:grow(4) * RWALL
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function wallpt(t, h) local x = 1040 + (FAR[3] - 1040)*t local yb = 600 + (FAR[4] - 600)*t local yt = -40 + (FAR[2] + 40)*t return {x, yb + (yt - yb)*h} end
RIBX = {}
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(t, 0.02), wallpt(t, 0.98)}, {pressure={0.7, 0.7}, clip=SM})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(t + 0.004, 0.02), wallpt(t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=SM})
  RIBX[#RIBX+1] = wallpt(t, 0.5)[1]
  t = t + 0.1*(1 - t*0.85)
end
local rail = brush{kind="filbert", width=3, stiffness=0.5}
rail:load(RB, 0.9) rail:stroke({wallpt(0, 0.42), wallpt(1, 0.42)}, {pressure={0.8, 0.2}, clip=SM})
print(#RIBX)

--@ chunk 21
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

--@ chunk 22
-- the killer's shadow: turret head on a long armature, unequal jointed legs, a trailing cable; kinked at each rib
local function kink(pts)
  local out = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i+1]
    for k = 0, 9 do
      local t = k/10
      local x, y = a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t
      local n = 0
      for _, rx in ipairs(RIBX) do if x > rx then n = n + 1 end end
      out[#out+1] = {x - n*1.2, y + n*2.6}
    end
  end
  out[#out+1] = pts[#pts]
  return out
end
local m = nil
local function add(q) m = m and (m + q) or q end
local function arm(pts, w0, w1) add(limb(kink(pts), w0, w1)) end
-- body / base block
add(poly(kink({{800, 238}, {846, 230}, {862, 252}, {848, 270}, {804, 272}, {792, 256}}), true))
-- armature: long, two joints, up and toward the far end
arm({{812, 240}, {790, 196}, {760, 160}, {744, 150}}, 4.2, 3)
-- turret head with a barrel
add(poly(kink({{722, 138}, {758, 136}, {764, 156}, {726, 162}}), true))
arm({{724, 147}, {700, 150}, {690, 151}}, 2, 1.6)
arm({{756, 140}, {766, 128}}, 1.6, 1.2)
-- legs, unequal, too many joints
arm({{806, 266}, {786, 300}, {796, 336}, {778, 372}, {772, 392}}, 3.2, 1.5)
arm({{824, 270}, {840, 312}, {826, 350}, {834, 400}}, 3, 1.4)
arm({{842, 266}, {876, 290}, {870, 330}, {892, 362}, {896, 420}}, 3.2, 1.4)
arm({{800, 258}, {770, 274}, {752, 306}, {746, 340}}, 2.6, 1.3)
arm({{856, 258}, {900, 268}, {922, 300}, {940, 316}, {948, 350}}, 2.8, 1.3)
arm({{830, 272}, {818, 318}, {806, 342}}, 2.4, 1.2)
-- a cable trailing behind, sagging
arm({{858, 262}, {900, 300}, {940, 330}, {975, 344}, {1004, 352}}, 1.3, 1.0)
SHADOW2 = m * RWALL
local SHM = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
work(SHADOW2:soften(0.8), {hand="detail", pile=SHM, coverage=4, fill=true, clip=RWALL, tool={kind="round", width=1.4}, length={2, 6}})

--@ chunk 23
local SM = SHADOW2:grow(3) * RWALL
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local cells = {}
for y = 60, 480, 2.6 do for x = 700, 1004, 2.6 do
  local xx, yy = x + rand(-1.1,1.1), y + rand(-1.1,1.1)
  if SM:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.3 then
    local dx, dy = xx - LAMP[1], (yy - LAMP[2])*0.85
    local d = math.sqrt(dx*dx + dy*dy)
    local t = 5 - d/62 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 0.5), 1, 5)}
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
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=RWALL})
  end
end end
print(#cells)

-- restate the wall ribs where the old shadow was
local SM = SHADOW2:grow(4) * RWALL
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function wallpt(t, h) local x = 1040 + (FAR[3] - 1040)*t local yb = 600 + (FAR[4] - 600)*t local yt = -40 + (FAR[2] + 40)*t return {x, yb + (yt - yb)*h} end
local RIBX_ = {}
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(t, 0.02), wallpt(t, 0.98)}, {pressure={0.7, 0.7}, clip=SM})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(t + 0.004, 0.02), wallpt(t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=SM})
  RIBX_[#RIBX_+1] = wallpt(t, 0.5)[1]
  t = t + 0.1*(1 - t*0.85)
end
local rail = brush{kind="filbert", width=3, stiffness=0.5}
rail:load(RB, 0.9) rail:stroke({wallpt(0, 0.42), wallpt(1, 0.42)}, {pressure={0.8, 0.2}, clip=SM})

--@ chunk 24
print(wait(3*24*60))
-- the killer's shadow: turret head on a long armature, unequal jointed legs, a trailing cable; kinked at each rib
local function kink(pts)
  local out = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i+1]
    for k = 0, 9 do
      local t = k/10
      local x, y = a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t
      local n = 0
      for _, rx in ipairs(RIBX) do if (x - rx)*(830 - rx) < 0 then n = n + ((x < 830) and 1 or -1) end end
      out[#out+1] = {x, y + n*1.8}
    end
  end
  out[#out+1] = pts[#pts]
  return out
end
local m = nil
local function add(q) m = m and (m + q) or q end
local function arm(pts, w0, w1) add(limb(kink(pts), w0, w1)) end
-- body / base block
add(poly(kink({{800, 238}, {846, 230}, {862, 252}, {848, 270}, {804, 272}, {792, 256}}), true))
-- armature: long, two joints, up and toward the far end
arm({{812, 240}, {790, 196}, {760, 160}, {744, 150}}, 4.2, 3)
-- turret head with a barrel
add(poly(kink({{722, 138}, {758, 136}, {764, 156}, {726, 162}}), true))
arm({{724, 147}, {700, 150}, {690, 151}}, 2, 1.6)
arm({{756, 140}, {766, 128}}, 1.6, 1.2)
-- legs, unequal, too many joints
arm({{806, 266}, {786, 300}, {796, 336}, {778, 372}, {772, 392}}, 3.2, 1.5)
arm({{824, 270}, {840, 312}, {826, 350}, {834, 400}}, 3, 1.4)
arm({{842, 266}, {876, 290}, {870, 330}, {892, 362}, {896, 420}}, 3.2, 1.4)
arm({{800, 258}, {770, 274}, {752, 306}, {746, 340}}, 2.6, 1.3)
arm({{856, 258}, {900, 268}, {922, 300}, {940, 316}, {948, 350}}, 2.8, 1.3)
arm({{830, 272}, {818, 318}, {806, 342}}, 2.4, 1.2)
-- a cable trailing behind, sagging
arm({{858, 262}, {900, 300}, {940, 330}, {975, 344}, {1004, 352}}, 1.3, 1.0)
SHADOW2 = m * RWALL
local SHM = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
work(SHADOW2:soften(0.8), {hand="detail", pile=SHM, coverage=4, fill=true, clip=RWALL, tool={kind="round", width=1.4}, length={2, 6}})

--@ chunk 25
print(wait(4*24*60))
local SM = RWALL * poly({{735, 120}, {1004, 120}, {1004, 520}, {735, 520}}) - poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true):grow(30)
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local cells = {}
for y = 60, 480, 2.6 do for x = 700, 1004, 2.6 do
  local xx, yy = x + rand(-1.1,1.1), y + rand(-1.1,1.1)
  if SM:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.3 then
    local dx, dy = xx - LAMP[1], (yy - LAMP[2])*0.85
    local d = math.sqrt(dx*dx + dy*dy)
    local t = 5 - d/62 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 0.5), 1, 5)}
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
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=RWALL})
  end
end end
print(#cells)

-- restate the wall ribs where the old shadow was
local SM = RWALL * poly({{735, 120}, {1004, 120}, {1004, 520}, {735, 520}}) - poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true):grow(30)
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function wallpt(t, h) local x = 1040 + (FAR[3] - 1040)*t local yb = 600 + (FAR[4] - 600)*t local yt = -40 + (FAR[2] + 40)*t return {x, yb + (yt - yb)*h} end
local RIBX_ = {}
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(t, 0.02), wallpt(t, 0.98)}, {pressure={0.7, 0.7}, clip=SM})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(t + 0.004, 0.02), wallpt(t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=SM})
  RIBX_[#RIBX_+1] = wallpt(t, 0.5)[1]
  t = t + 0.1*(1 - t*0.85)
end
local rail = brush{kind="filbert", width=3, stiffness=0.5}
rail:load(RB, 0.9) rail:stroke({wallpt(0, 0.42), wallpt(1, 0.42)}, {pressure={0.8, 0.2}, clip=SM})

--@ chunk 26
print(wait(4*24*60))
-- the killer's shadow: turret head on a long armature, unequal jointed legs, a trailing cable; kinked at each rib
local function kink(pts)
  local out = {}
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i+1]
    for k = 0, 9 do
      local t = k/10
      local x, y = a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t
      local n = 0
      for _, rx in ipairs(RIBX) do if (x - rx)*(940 - rx) < 0 then n = n + ((x < 940) and 1 or -1) end end
      out[#out+1] = {x, y + n*1.8}
    end
  end
  out[#out+1] = pts[#pts]
  return out
end
local m = nil
local function add(q) m = m and (m + q) or q end
local function arm(pts, w0, w1) add(limb(kink(pts), w0, w1)) end
add(poly(kink({{926, 250}, {972, 246}, {980, 270}, {962, 284}, {930, 282}, {920, 266}}), true))
arm({{934, 262}, {888, 252}, {846, 278}, {818, 298}}, 4.2, 3)
add(poly(kink({{788, 288}, {822, 286}, {826, 308}, {792, 314}}), true))
arm({{792, 300}, {770, 304}, {760, 306}}, 2, 1.6)
arm({{812, 290}, {818, 276}}, 1.6, 1.2)
arm({{940, 278}, {920, 320}, {935, 370}, {915, 430}}, 3.2, 1.5)
arm({{956, 282}, {985, 330}, {970, 390}, {995, 450}}, 3, 1.4)
arm({{930, 276}, {895, 300}, {880, 350}, {868, 398}}, 2.8, 1.4)
arm({{966, 272}, {1004, 296}}, 2.6, 2)
arm({{946, 284}, {950, 340}, {938, 384}, {952, 432}, {948, 470}}, 2.8, 1.3)
arm({{924, 268}, {876, 272}, {852, 320}, {846, 360}}, 2.4, 1.2)
arm({{972, 262}, {990, 236}, {1004, 222}}, 1.3, 1.0)
SHADOW2 = m * RWALL
local SHM = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
work(SHADOW2:soften(0.8), {hand="detail", pile=SHM, coverage=4, fill=true, clip=RWALL, tool={kind="round", width=1.4}, length={2, 6}})

--@ chunk 27
print(wait(8*24*60), drying(900,300), drying(950,400))
-- restate the wall ribs where the old shadow was
local SM = RWALL * poly({{735, 120}, {1004, 120}, {1004, 520}, {735, 520}}) - poly({{892, 112}, {918, 106}, {920, 142}, {894, 146}}, true):grow(4)
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function wallpt(t, h) local x = 1040 + (FAR[3] - 1040)*t local yb = 600 + (FAR[4] - 600)*t local yt = -40 + (FAR[2] + 40)*t return {x, yb + (yt - yb)*h} end
local RIBX_ = {}
local t = 0.08
while t < 0.97 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({wallpt(t, 0.02), wallpt(t, 0.98)}, {pressure={0.7, 0.7}, clip=SM})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({wallpt(t + 0.004, 0.02), wallpt(t + 0.004, 0.98)}, {pressure={0.4, 0.4}, clip=SM})
  RIBX_[#RIBX_+1] = wallpt(t, 0.5)[1]
  t = t + 0.1*(1 - t*0.85)
end
local rail = brush{kind="filbert", width=3, stiffness=0.5}
rail:load(RB, 0.9) rail:stroke({wallpt(0, 0.42), wallpt(1, 0.42)}, {pressure={0.8, 0.2}, clip=SM})

local SHM = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
work(SHADOW2, {hand="detail", pile=SHM, coverage=4.5, fill=true, clip=SHADOW2:grow(0.5), tool={kind="round", width=1.2}, length={2, 5}})
local CH = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"bone black",0.35}}
local c = brush{kind="round", width=1.6, point=0.4}
for i = 0, 4 do
  local x = 870 + i*22
  c:load(CH, 0.9) c:stroke({{x, 395 + i*12}, {x + 9, 384 + i*12}, {x + 18, 395 + i*12}}, {pressure={0.6, 0.6}, clip=RWALL - SHADOW2})
end

--@ chunk 28
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

--@ chunk 29
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

--@ chunk 30
print(wait(12*24*60), drying(560,440), drying(420,500))
-- the tabard, half pulled off and crumpled, laid on DRY paint in a deep crimson
CRD = pile{{"Mars red",0.7},{"rose madder",0.7},{"bone black",0.8}}
TAB3 = gpoly({{118, -16}, {160, -24}, {192, -10}, {205, 14}, {196, 44}, {170, 60}, {136, 72}, {104, 80}, {74, 74}, {58, 60}, {72, 44}, {66, 26}, {90, 16}, {104, -2}}, 0, true)
work(TAB3, {hand="detail", pile=CRD, coverage=4.5, fill=true, clip=TAB3, tool={kind="round", width=1.8}, length={3, 8}, angle=0.4})

--@ chunk 31
print(wait(15*24*60), drying(420,500))
CRD2 = pile{{"rose madder",0.8},{"Mars red",0.45},{"bone black",1.3},{"ultramarine blue",0.1}}
-- deeper crimson, ragged torn edge where it was pulled
local rag = TAB3:roughen(2.5, 9, 31)
work(rag, {hand="detail", pile=CRD2, coverage=4.5, fill=true, clip=rag, tool={kind="round", width=1.6}, length={3, 8}, angle=0.4})

--@ chunk 32
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
-- the rosary spilling from the open hand
local BEAD = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.3},{"Mars orange",0.08}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local h0 = G(406, 112)
local path = {h0, {h0[1] + 10, h0[2] + 14}, {h0[1] + 4, h0[2] + 28}, {h0[1] + 22, h0[2] + 36}, {h0[1] + 40, h0[2] + 30}, {h0[1] + 46, h0[2] + 18}}
r:load(CHN, 0.8) r:stroke(path, {pressure={0.3, 0.3}})
local b = brush{kind="round", width=1.8, point=0.4}
for i = 1, #path - 1 do for k = 0, 3 do
  local t = k/4
  local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t}
  b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.5})
end end
local c = {h0[1] + 52, h0[2] + 14}
local cr = brush{kind="rigger", width=1.2, point=1}
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 1, c[2] - 6}, {c[1] + 1, c[2] + 6}}, {pressure={0.65, 0.65}})
cr:load(BEAD, 0.95) cr:stroke({{c[1] - 4, c[2] - 2}, {c[1] + 4, c[2] - 2.5}}, {pressure={0.65, 0.65}})
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
-- the last cold point of the optic, on the helm turned toward us
local OC = pile{{"zinc white",2},{"cerulean blue",0.5},{"lead white",1}}
local OH = pile{{"cerulean blue",1},{"ultramarine blue",0.5},{"lead white",0.6},{"bone black",0.4}}
local vis = brush{kind="rigger", width=1.0, point=1}
vis:load(pile{{"bone black",2.5},{"ultramarine blue",0.3}}, 0.9) vis:stroke(gl({{326, -12}, {340, -2}, {344, 10}}), {pressure={0.6, 0.5}})
local o = G(338, 0)
local hb = brush{kind="round", width=3.4, point=0.2}
hb:load(OH, 0.5) hb:touch(o[1], o[2], {pressure=0.25})
local p = brush{kind="round", width=1.5, point=0.3}
p:load(OC, 0.95) p:touch(o[1], o[2], {pressure=0.65})

--@ chunk 33
print(wait(5*24*60))

--@ chunk 34
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
-- the optic: one last cold point, a little stronger
local o = G(338, 0)
local OC = pile{{"zinc white",2},{"cerulean blue",0.4},{"lead white",1}}
local p = brush{kind="round", width=2.2, point=0.3}
p:load(OC, 0.95) p:touch(o[1], o[2], {pressure=0.7})
local OH = pile{{"cerulean blue",1},{"ultramarine blue",0.4},{"lead white",0.8},{"bone black",0.3}}
local r = brush{kind="rigger", width=0.6, point=1}
r:load(OH, 0.8) r:stroke({{o[1] - 5, o[2]}, {o[1] + 5, o[2]}}, {pressure={0.0, 0.4, 0.0}})
