-- easel session "dormant_empty": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=3409, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"bone brown",1},{"raw sienna",0.2},{"ultramarine blue",0.3},{"lead white",0.05}}, um=45, apply="brush", texture=0.35}}}
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
ALC = {}
local function wp(sd, z, Y) return pr(sd*XW, Y, z) end
REC = pile{{"bone black",2.6},{"bone brown",0.4},{"ultramarine blue",0.4}}
PIL = pile{{"bone black",1.8},{"bone brown",0.9},{"raw sienna",0.35},{"lead white",0.07}}
local recm, pilm = nil, nil
for _, sd in ipairs({-1, 1}) do
  local z = (sd < 0) and 0.78 or 0.84
  local k = 0
  while z < 6.6 do
    k = k + 1
    local za, zb = z, z*(1.30 + rand(-0.015, 0.015))
    local top = -150 + rand(-8, 8)
    local apex = top - 46 - rand(0, 6)
    local pts = {}
    pts[#pts+1] = wp(sd, za, YF)
    pts[#pts+1] = wp(sd, za, top)
    for j = 1, 7 do local f = j/8 local zz = za + (zb - za)*f local Y = top + (apex - top)*math.sin(f*math.pi)^0.7 pts[#pts+1] = wp(sd, zz, Y) end
    pts[#pts+1] = wp(sd, zb, top)
    pts[#pts+1] = wp(sd, zb, YF)
    local m = poly(pts)
    recm = recm and (recm + m) or m
    ALC[#ALC+1] = {sd=sd, za=za, zb=zb, top=top, apex=apex, k=k}
    local zc = zb*(1.07 + rand(-0.01, 0.01))
    local pm = poly({wp(sd, zb, YC*0.98), wp(sd, zc, YC*0.98), wp(sd, zc, YF), wp(sd, zb, YF)})
    pilm = pilm and (pilm + pm) or pm
    z = zc
  end
end
RECM = recm
work(recm, {hand="detail", pile=REC, coverage=4.5, fill=true, clip=recm, tool={kind="round", width=1.8}, length={3, 8}})
work(pilm, {hand="detail", pile=PIL, coverage=4, fill=true, clip=pilm, tool={kind="round", width=1.8}, length={3, 8}})
print(#ALC)

--@ chunk 3
print(wait(6*24*60), drying(100,300))
function ap(a, s, h) local z = a.za + (a.zb - a.za)*s local Y = YF - h*(YF - a.top) return pr(a.sd*(XW + 8), Y, z) end
-- every alcove empty: torn fittings and scratch marks
local SC = pile{{"raw sienna",0.8},{"bone brown",0.6},{"Mars orange",0.15},{"lead white",0.3}}
local FIT = pile{{"bone black",1.4},{"bone brown",0.9},{"raw sienna",0.4},{"lead white",0.1}}
local CBL = pile{{"bone black",2},{"bone brown",0.4}}
local function L(p, pts, pr_, w) local b = brush{kind="rigger", width=w, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_, pr_*0.6}, ramps={0.05, 0.2}, clip=RECM}) end
for i, a in ipairs(ALC) do
  local s = 1 / ((a.za + a.zb)/2)
  local w = clamp(1.4*s, 0.4, 1.6)
  -- claw scratches: clusters of three parallel slashes
  for c = 1, 2 do
    local s0, h0 = rand(0.25, 0.7), rand(0.35, 0.85)
    for k = 0, 2 do L(SC, {ap(a, s0 + k*0.05, h0), ap(a, s0 + k*0.05 + 0.08, h0 - 0.2)}, 0.45, w) end
  end
  -- torn cradle brackets: stubs at the sides, one bent outward
  L(FIT, {ap(a, 0.06, 0.55), ap(a, 0.2, 0.52), ap(a, 0.26, 0.6)}, 0.7, w*2)
  L(FIT, {ap(a, 0.94, 0.4), ap(a, 0.82, 0.38), ap(a, 0.78, 0.28)}, 0.7, w*2)
  -- a hanging severed cable
  L(CBL, {ap(a, 0.5, 0.98), ap(a, 0.52, 0.8), ap(a, 0.47, 0.66)}, 0.6, w*1.2)
end

--@ chunk 4
print(wait(6*24*60), drying(505,400))
-- far end: the lamp broken, a doorway open on violet light
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
DOOR = poly({pr(-110, YF, ZF), pr(110, YF, ZF), pr(110, -60, ZF), pr(-110, -60, ZF)})
local V1 = pile{{"cobalt violet",1},{"lead white",1},{"magenta",0.2},{"ultramarine blue",0.2}}
local V2 = pile{{"cobalt violet",0.6},{"lead white",1.8},{"magenta",0.1}}
fill(DOOR, V1)
fill(poly({pr(-60, YF, ZF), pr(60, YF, ZF), pr(60, 0, ZF), pr(-60, 0, ZF)}), V2)
-- door leaf hanging open at the left
fill(poly({pr(-110, YF, ZF), pr(-110, -60, ZF), pr(-150, -70, ZF*0.93), pr(-150, YF, ZF*0.93)}), pile{{"bone black",1.8},{"bone brown",0.6}})
-- violet spill on the near floor in front of the door
local spill = poly({pr(-110, YF, ZF), pr(110, YF, ZF), pr(170, YF, 4.6), pr(-170, YF, 4.6)})
local SV = pile{{"bone black",1.3},{"cobalt violet",0.5},{"ultramarine blue",0.2},{"lead white",0.2}}
fill(spill, SV, "round 1.6")
-- the broken lamp: an empty housing, a glass shard, a dead wire
local HS = pile{{"bone black",2},{"bone brown",0.4}}
fill(poly({pr(-30, -150, ZF), pr(30, -150, ZF), pr(30, -110, ZF), pr(-30, -110, ZF)}), HS)
local r = brush{kind="rigger", width=0.6, point=1}
r:load(pile{{"Mars orange",0.6},{"bone brown",0.6},{"bone black",0.6}}, 0.9) r:stroke({pr(-20, -110, ZF), pr(-24, -96, ZF), pr(-14, -88, ZF)}, {pressure={0.5, 0.4}})
r:load(HS, 0.9) r:stroke({pr(10, -110, ZF), pr(14, -80, ZF), pr(8, -70, ZF)}, {pressure={0.5, 0.3}})

--@ chunk 5
print(wait(6*24*60), drying(505,400))
-- many-legged tracks scored on the floor, all leading away toward the door
local TR = pile{{"bone black",2.2},{"bone brown",0.5}}
local TL = pile{{"raw sienna",0.6},{"bone brown",0.6},{"lead white",0.25},{"bone black",0.3}}
local n = 0
for lane = 1, 9 do
  local X0 = -380 + lane*76 + rand(-20, 20)
  local wob = rand(0.6, 1.6)
  local z = 0.62 + rand(0, 0.08)
  while z < 6.3 do
    local X = X0*(1 - (z - 0.6)/6.5*0.7) + 30*math.sin(z*wob + lane)
    for leg = -2, 2 do
      if leg ~= 0 then
        local dx = leg*18
        local a = pr(X + dx, YF, z)
        local b = pr(X + dx + leg*6, YF, z*1.05)
        local w = clamp(2.4/z, 0.35, 2.4)
        local br = brush{kind="rigger", width=w, point=1}
        br:load(TR, 0.85) br:stroke({a, b}, {pressure={0.5, 0.2}})
        if z < 2 then br:load(TL, 0.8) br:stroke({{a[1], a[2] - w*0.8}, {b[1], b[2] - w*0.8}}, {pressure={0.3, 0.1}}) end
        n = n + 1
      end
    end
    z = z * 1.11
  end
end
print(n)

--@ chunk 6
print(wait(6*24*60), drying(492,400))
-- the Commando's lamp, turned low: a small warm pool on the floor ahead of him
POOL = {
 pile{{"bone black",1.8},{"bone brown",0.8},{"raw sienna",0.4},{"lead white",0.1}},
 pile{{"bone black",1.3},{"raw sienna",0.6},{"Mars orange",0.15},{"lead white",0.2}},
 pile{{"bone black",0.9},{"raw sienna",0.6},{"yellow ochre",0.3},{"lead white",0.35}},
}
local cx, cy = 512, 392
local cells = {}
for y = 360, 430, 2.4 do for x = 380, 640, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if FLOOR:at(xx, yy) > 0.5 then
    local d = math.sqrt(((xx - cx)/95)^2 + ((yy - cy)/24)^2)
    local v = 3.2 - d*2.6 + randn(0, 0.3)
    if v > 0.6 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(POOL[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(POOL[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=FLOOR})
  end
end end
print(#cells)
-- the Commando, built as plates, back to us, mid-step, one hand raised to his helm
FB = {492, 470}
local S = 0.56
function P(u, v) return {FB[1] + u*S, FB[2] - v*S} end
function pp(t) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, true) end
FP = {
 footL = {{-28, 0}, {-6, 0}, {-6, 10}, {-24, 11}},
 greaveL = {{-25, 10}, {-8, 10}, {-7, 72}, {-24, 74}},
 kneeL = {{-27, 70}, {-6, 70}, {-5, 86}, {-26, 86}},
 cuisseL = {{-28, 84}, {-4, 84}, {-2, 132}, {-30, 132}},
 footR = {{10, 22}, {28, 20}, {29, 30}, {11, 32}},
 greaveR = {{11, 30}, {28, 28}, {29, 84}, {12, 86}},
 kneeR = {{8, 82}, {31, 80}, {31, 96}, {9, 98}},
 cuisseR = {{6, 94}, {31, 94}, {32, 134}, {4, 134}},
 faulds = {{-36, 124}, {36, 124}, {32, 152}, {-32, 152}},
 torso = {{-34, 148}, {34, 148}, {40, 212}, {-40, 210}},
 gorget = {{-16, 210}, {16, 210}, {14, 228}, {-14, 228}},
 helm = {{-17, 224}, {4, 222}, {20, 230}, {22, 250}, {12, 264}, {-10, 265}, {-20, 250}},
 paulL = {{-56, 186}, {-34, 182}, {-24, 210}, {-36, 222}, {-56, 214}},
 armLu = {{-58, 150}, {-42, 150}, {-40, 188}, {-56, 190}},
 armLv = {{-60, 104}, {-44, 102}, {-42, 152}, {-58, 152}},
 gauntL = {{-62, 82}, {-44, 80}, {-43, 104}, {-61, 106}},
 paulR = {{30, 186}, {54, 188}, {58, 214}, {44, 224}, {26, 212}},
 armRu = {{42, 196}, {56, 190}, {66, 160}, {52, 156}},
 armRf = {{52, 156}, {66, 162}, {62, 110}, {48, 108}},
 handR = {{46, 90}, {64, 90}, {64, 110}, {46, 110}},
}
FORD = {"footR","greaveR","kneeR","cuisseR","footL","greaveL","kneeL","cuisseL","faulds","torso","armLu","armLv","gauntL","paulL","gorget","helm","paulR","armRu","armRf","handR"}
local a = nil
for _, k in ipairs(FORD) do local m = pp(FP[k]) a = a and (a + m) or m end
FIG = a
local FC = pile{{"bone black",2.2},{"ultramarine blue",0.4},{"lead white",0.12}}
work(FIG, {hand="detail", pile=FC, coverage=5, fill=true, clip=FIG, tool={kind="round", width=1.3}, length={2, 5}})

--@ chunk 7
print(wait(8*24*60), drying(492,400))
-- the lamp full on, its warm beam reaching down the empty aisle
local lp = P(-40, 200)
local tip = {505, 330}
local dir = math.atan(tip[2] - lp[2], tip[1] - lp[1])
local Lb = math.sqrt((tip[1]-lp[1])^2 + (tip[2]-lp[2])^2)
local nx, ny = -math.sin(dir), math.cos(dir)
BEAM = poly({{lp[1] + nx*2, lp[2] + ny*2}, {tip[1] + nx*60, tip[2] + ny*14}, {tip[1] - nx*60, tip[2] - ny*14}, {lp[1] - nx*2, lp[2] - ny*2}}) - FIG
-- its footprint on the floor: a long warm pool where the beam strikes, along the aisle
POOLM = poly({pr(-90, YF, 1.05), pr(90, YF, 1.05), pr(60, YF, 4.2), pr(-60, YF, 4.2)}) - FIG
local BP = {
 pile{{"bone black",1.6},{"bone brown",0.7},{"raw sienna",0.35},{"lead white",0.1}},
 pile{{"bone black",1.1},{"raw sienna",0.6},{"burnt sienna",0.15},{"lead white",0.22}},
 pile{{"bone black",0.6},{"raw sienna",0.6},{"yellow ochre",0.35},{"lead white",0.4}},
}
local cells = {}
for y = 270, 566, 2.4 do for x = 380, 640, 2.6 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if POOLM:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (yy - 270)/230
    local cx = math.abs(xx - 505)/(20 + t*150)
    local v = 1.4 + t*2 - cx*1.6 + randn(0, 0.3)
    if v > 0.7 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(BP[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(3, 7)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=POOLM})
  end
end end
print(#cells)

--@ chunk 8
print(wait(8*24*60), drying(505,400))
-- the tracks restated inside the lamp's pool, where the light shows them scored dark with lit lips
local TR = pile{{"bone black",2.4},{"bone brown",0.4}}
local TL = pile{{"yellow ochre",0.6},{"raw sienna",0.4},{"lead white",0.6}}
for lane = 1, 9 do
  local X0 = -380 + lane*76 + ((lane*29) % 40) - 20
  local wob = 0.6 + (lane % 5)*0.2
  local z = 1.05
  while z < 4.2 do
    local X = X0*(1 - (z - 0.6)/6.5*0.7) + 30*math.sin(z*wob + lane)
    for leg = -2, 2 do
      if leg ~= 0 then
        local a = pr(X + leg*18, YF, z) local b = pr(X + leg*18 + leg*6, YF, z*1.05)
        local w = clamp(2.4/z, 0.35, 2.4)
        local br = brush{kind="rigger", width=w, point=1}
        br:load(TR, 0.9) br:stroke({a, b}, {pressure={0.55, 0.2}, clip=POOLM})
        br:load(TL, 0.85) br:stroke({{a[1], a[2] - w}, {b[1], b[2] - w}}, {pressure={0.35, 0.1}, clip=POOLM})
      end
    end
    z = z * 1.11
  end
end
-- the lamp itself, full on, and the faint beam in the dark air (short dithered streaks from the lamp)
local LP = pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.1}}
local q = P(-40, 200)
local l = brush{kind="round", width=3, point=0.3}
l:load(LP, 0.95) l:touch(q[1], q[2], {pressure=0.75})
local SB = pile{{"bone black",0.9},{"raw sienna",0.5},{"yellow ochre",0.3},{"lead white",0.35}}
local s = brush{kind="filbert", width=1.6, stiffness=0.4}
for k = 1, 14 do
  local f = rand(0.05, 0.5)
  local tx, ty = q[1] + (505 - q[1])*f + rand(-3, 3)*f*10, q[2] + (330 - q[2])*f
  s:load(SB, 0.5) s:stroke({{tx, ty}, {tx + (505 - q[1])*0.05, ty + (330 - q[2])*0.05}}, {pressure={0.3, 0.05}, clip=-FIG})
end
-- rims on the figure from the violet door ahead (cold) and the bounce of its own pool (warm)
local CV = pile{{"cobalt violet",0.6},{"lead white",1},{"ultramarine blue",0.2}}
local WM = pile{{"bone black",1.2},{"raw sienna",0.5},{"Mars orange",0.1},{"lead white",0.25}}
local function ln(p, uv, pr_, w) local r = brush{kind="rigger", width=w or 0.6, point=1} local pts = {} for _, qq in ipairs(uv) do pts[#pts+1] = P(qq[1], qq[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG:grow(0.4)}) end
ln(CV, {{-17, 224}, {4, 222}, {20, 230}}, 0.4, 0.5)
ln(CV, {{-56, 186}, {-34, 182}}, 0.35, 0.5) ln(CV, {{30, 186}, {54, 188}}, 0.35, 0.5)
ln(WM, {{-6, 12}, {-5, 84}}, 0.45, 0.6) ln(WM, {{11, 32}, {9, 96}}, 0.45, 0.6)
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
for _, s2 in ipairs({{{-31, 132}, {32, 132}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}}) do ln(JD, s2, 0.5, 0.6) end

--@ chunk 9
print(wait(15*24*60), drying(505,500), drying(492,420))
-- the floor behind the figure back to dark deck (the pool was laid on the wrong side), the old near pool too
local back = (poly({pr(-110, YF, 0.95), pr(110, YF, 0.95), pr(80, YF, 1.62), pr(-80, YF, 1.62)}) + ellipse(512, 392, 140, 40) * FLOOR) - FIG:grow(1)
work(back, {hand="detail", tool="round 2", pile=BF, coverage=5, fill=true, clip=back, angle=0})
-- the figure repainted opaque on dry paint
local FC = pile{{"bone black",2.4},{"ultramarine blue",0.35},{"lead white",0.06}}
for k = 1, 2 do work(FIG, {hand="body", pile=FC, coverage=4, fill=true, clip=FIG, tool={kind="filbert", width=1.8}, length={3, 6}, angle=1.57}) end

--@ chunk 10
print(wait(15*24*60), drying(505,500), drying(492,420))
-- tracks restated across the repainted deck behind him
local TR = pile{{"bone black",2.4},{"bone brown",0.4}}
local TL = pile{{"raw sienna",0.6},{"bone brown",0.6},{"lead white",0.25},{"bone black",0.3}}
local reg = (poly({pr(-110, YF, 0.95), pr(110, YF, 0.95), pr(80, YF, 1.62), pr(-80, YF, 1.62)}) + ellipse(512, 392, 140, 40) * FLOOR):grow(2) - FIG:grow(1)
for lane = 1, 9 do
  local X0 = -380 + lane*76 + ((lane*29) % 40) - 20
  local wob = 0.6 + (lane % 5)*0.2
  local z = 0.65
  while z < 3.2 do
    local X = X0*(1 - (z - 0.6)/6.5*0.7) + 30*math.sin(z*wob + lane)
    for leg = -2, 2 do if leg ~= 0 then
      local a = pr(X + leg*18, YF, z) local b = pr(X + leg*18 + leg*6, YF, z*1.05)
      local w = clamp(2.4/z, 0.35, 2.4)
      local br = brush{kind="rigger", width=w, point=1}
      br:load(TR, 0.85) br:stroke({a, b}, {pressure={0.5, 0.2}, clip=reg})
      br:load(TL, 0.8) br:stroke({{a[1], a[2] - w*0.8}, {b[1], b[2] - w*0.8}}, {pressure={0.3, 0.1}, clip=reg})
    end end
    z = z * 1.11
  end
end
-- the beam's pool ahead of him, narrowing down the aisle toward the door
local POOL2 = poly({pr(-70, YF, 1.65), pr(70, YF, 1.65), pr(45, YF, 4.6), pr(-45, YF, 4.6)}) - FIG:grow(1)
POOLM = POOL2
local BP = {
 pile{{"bone black",1.6},{"bone brown",0.7},{"raw sienna",0.35},{"lead white",0.1}},
 pile{{"bone black",1.1},{"raw sienna",0.6},{"burnt sienna",0.15},{"lead white",0.22}},
 pile{{"bone black",0.6},{"raw sienna",0.6},{"yellow ochre",0.35},{"lead white",0.4}},
}
local cells = {}
for y = 290, 470, 2.2 do for x = 420, 600, 2.4 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if POOL2:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (yy - 290)/170
    local cx = math.abs(xx - 505)/(10 + t*45)
    local v = 3.2 - (1 - t)*1.4 - cx*1.4 + randn(0, 0.3)
    if v > 0.7 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.2, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(BP[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(2.5, 5)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=POOL2})
  end
end end
print(#cells)

--@ chunk 11
print(wait(10*24*60), drying(505,400))
-- tracks lit inside the beam's pool
local TR = pile{{"bone black",2.4},{"bone brown",0.4}}
local TL = pile{{"yellow ochre",0.6},{"raw sienna",0.4},{"lead white",0.6}}
for lane = 1, 9 do
  local X0 = -380 + lane*76 + ((lane*29) % 40) - 20
  local wob = 0.6 + (lane % 5)*0.2
  local z = 1.6
  while z < 4.7 do
    local X = X0*(1 - (z - 0.6)/6.5*0.7) + 30*math.sin(z*wob + lane)
    for leg = -2, 2 do if leg ~= 0 then
      local a = pr(X + leg*18, YF, z) local b = pr(X + leg*18 + leg*6, YF, z*1.05)
      local w = clamp(2.4/z, 0.35, 2.4)
      local br = brush{kind="rigger", width=w, point=1}
      br:load(TR, 0.9) br:stroke({a, b}, {pressure={0.55, 0.2}, clip=POOLM})
      br:load(TL, 0.85) br:stroke({{a[1], a[2] - w}, {b[1], b[2] - w}}, {pressure={0.35, 0.1}, clip=POOLM})
    end end
    z = z * 1.11
  end
end
-- plates, rims and the lamp on the dry figure
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local MG = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local CV = pile{{"cobalt violet",0.6},{"lead white",1},{"ultramarine blue",0.2}}
local function ln(p, uv, pr_, w) local r = brush{kind="rigger", width=w or 0.6, point=1} local pts = {} for _, qq in ipairs(uv) do pts[#pts+1] = P(qq[1], qq[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG:grow(0.4)}) end
for _, s2 in ipairs({{{-25, 72}, {-6, 72}}, {{11, 84}, {29, 82}}, {{-31, 132}, {32, 132}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-42, 151}, {-58, 151}}}) do ln(MG, s2, 0.4, 0.5) end
ln(MG, {{0, 150}, {1, 180}, {0, 208}}, 0.4, 0.6)
ln(CV, {{-17, 224}, {-20, 250}, {-10, 265}, {12, 264}, {22, 250}}, 0.45, 0.6)
ln(CV, {{-56, 186}, {-34, 182}}, 0.4, 0.5) ln(CV, {{30, 186}, {54, 188}}, 0.4, 0.5)
local LP = pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.1}}
local q = P(-40, 200)
local l = brush{kind="round", width=3, point=0.3}
l:load(LP, 0.95) l:touch(q[1], q[2], {pressure=0.75})

--@ chunk 12
print(wait(8*24*60))
-- the beam's pool ahead of him, narrowing down the aisle toward the door
local POOL2 = poly({pr(-150, YF, 1.62), pr(150, YF, 1.62), pr(80, YF, 5.0), pr(-80, YF, 5.0)}) - FIG:grow(1)
POOLM = POOL2
local BP = {
 pile{{"bone black",1.6},{"bone brown",0.7},{"raw sienna",0.35},{"lead white",0.1}},
 pile{{"bone black",1.1},{"raw sienna",0.6},{"burnt sienna",0.15},{"lead white",0.22}},
 pile{{"bone black",0.6},{"raw sienna",0.6},{"yellow ochre",0.35},{"lead white",0.4}},
}
local cells = {}
for y = 280, 472, 2.2 do for x = 380, 640, 2.4 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if POOL2:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (yy - 290)/170
    local cx = math.abs(xx - 505)/(16 + t*80)
    local v = 3.2 - (1 - t)*1.4 - cx*1.4 + randn(0, 0.3)
    if v > 0.7 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.2, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(BP[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(2.5, 5)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=POOL2})
  end
end end
print(#cells)

--@ chunk 13
print(wait(10*24*60), drying(505,400))
-- tracks lit inside the beam's pool
local TR = pile{{"bone black",2.4},{"bone brown",0.4}}
local TL = pile{{"yellow ochre",0.6},{"raw sienna",0.4},{"lead white",0.6}}
for lane = 1, 9 do
  local X0 = -380 + lane*76 + ((lane*29) % 40) - 20
  local wob = 0.6 + (lane % 5)*0.2
  local z = 1.6
  while z < 5.1 do
    local X = X0*(1 - (z - 0.6)/6.5*0.7) + 30*math.sin(z*wob + lane)
    for leg = -2, 2 do if leg ~= 0 then
      local a = pr(X + leg*18, YF, z) local b = pr(X + leg*18 + leg*6, YF, z*1.05)
      local w = clamp(2.4/z, 0.35, 2.4)
      local br = brush{kind="rigger", width=w, point=1}
      br:load(TR, 0.9) br:stroke({a, b}, {pressure={0.55, 0.2}, clip=POOLM})
      br:load(TL, 0.85) br:stroke({{a[1], a[2] - w}, {b[1], b[2] - w}}, {pressure={0.35, 0.1}, clip=POOLM})
    end end
    z = z * 1.11
  end
end
