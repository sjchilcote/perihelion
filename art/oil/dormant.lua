-- easel session "dormant": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=3307, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"bone brown",1},{"raw sienna",0.2},{"ultramarine blue",0.3},{"lead white",0.05}}, um=45, apply="brush", texture=0.35}}}
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
local nl = 0 for _, a in ipairs(ALC) do if a.sd < 0 then nl = nl + 1 end end
EMPTY = nl - 1
function ap(a, s, h) local z = a.za + (a.zb - a.za)*s local Y = YF - h*(YF - a.top) return pr(a.sd*(XW + 8), Y, z) end
local shells = nil
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local pts = {}
    for j = 0, 23 do
      local t = j/24*2*math.pi
      local s = 0.5 + 0.38*math.cos(t)
      local h = 0.52 + 0.43*math.sin(t) + ((math.sin(t) > 0.85) and 0.05 or 0)
      pts[#pts+1] = ap(a, s, h)
    end
    local m = poly(pts, true) * RECM
    shells = shells and (shells + m) or m
  end
end
SHELLS = shells
SH = pile{{"bone black",1.8},{"bone brown",1},{"raw sienna",0.3},{"lead white",0.06}}
work(shells, {hand="detail", pile=SH, coverage=4.5, fill=true, clip=shells, tool={kind="round", width=1.6}, length={3, 7}})

--@ chunk 4
print(wait(6*24*60), drying(100,300))
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local RIDGE = pile{{"bone brown",1},{"raw sienna",0.8},{"Mars orange",0.15},{"lead white",0.25}}
local EDGE = pile{{"lead white",1},{"ultramarine ash",0.4},{"bone black",0.6}}
local LEG = pile{{"bone black",2},{"bone brown",0.6}}
local function L(p, pts, pr_, w) local b = brush{kind="rigger", width=w, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_, pr_*0.7}, ramps={0.05, 0.1}}) end
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local sc = 1 / ((a.za + a.zb)/2)
    local w = clamp(2.0*sc, 0.4, 2.2)
    -- shell ridges (crest down the middle, two side ridges), warm toward the far lamp
    L(RIDGE, {ap(a, 0.5, 0.97), ap(a, 0.52, 0.7), ap(a, 0.5, 0.2)}, 0.6, w)
    L(RIDGE, {ap(a, 0.68, 0.88), ap(a, 0.78, 0.55), ap(a, 0.7, 0.18)}, 0.45, w*0.8)
    L(JD, {ap(a, 0.32, 0.88), ap(a, 0.22, 0.55), ap(a, 0.3, 0.18)}, 0.5, w*0.8)
    -- folded legs under the shell: jointed zigzags
    for j = 0, 3 do
      local s0 = 0.22 + j*0.18
      L(LEG, {ap(a, s0, 0.16), ap(a, s0 + 0.08, 0.07), ap(a, s0 - 0.02, 0.0)}, 0.6, w*0.8)
    end
    -- bladed forelimbs crossed over the front, a thin cold edge on each
    L(JD, {ap(a, 0.2, 0.85), ap(a, 0.42, 0.55), ap(a, 0.72, 0.18)}, 0.7, w*1.2)
    L(JD, {ap(a, 0.8, 0.85), ap(a, 0.58, 0.55), ap(a, 0.28, 0.18)}, 0.7, w*1.2)
    L(EDGE, {ap(a, 0.22, 0.86), ap(a, 0.44, 0.57), ap(a, 0.73, 0.2)}, 0.3, w*0.5)
    L(EDGE, {ap(a, 0.79, 0.87), ap(a, 0.57, 0.57), ap(a, 0.27, 0.2)}, 0.3, w*0.5)
  end
end
-- the empty alcove: its back wall faintly scored where something once stood, a few dropped shell flakes on the floor
for i, a in ipairs(ALC) do if a.sd < 0 and a.k == EMPTY then
  local sc = 1 / ((a.za + a.zb)/2)
  for j = 0, 3 do L(RIDGE, {ap(a, 0.3 + j*0.12, 0.85), ap(a, 0.34 + j*0.12, 0.25)}, 0.3, clamp(1.2*sc, 0.4, 1)) end
  EMPTYA = a
end end

--@ chunk 5
print(wait(8*24*60), drying(100,300))
-- darken the lower body of each shell (it faces away from the far lamp), leaving a lighter crest crescent on top
local SHD = pile{{"bone black",2.3},{"bone brown",0.7},{"ultramarine blue",0.15}}
local low = nil
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local pts = {}
    for j = 0, 20 do local t = j/20*math.pi pts[#pts+1] = ap(a, 0.5 + 0.40*math.cos(t), 0.52 - 0.45*math.sin(t)) end
    pts[#pts+1] = ap(a, 0.08, 0.62) pts[#pts+1] = ap(a, 0.5, 0.74) pts[#pts+1] = ap(a, 0.92, 0.62)
    local m = poly(pts, true) * SHELLS
    low = low and (low + m) or m
  end
end
work(low, {hand="detail", pile=SHD, coverage=4.5, fill=true, clip=low, tool={kind="round", width=1.6}, length={3, 7}})

--@ chunk 6
print(wait(8*24*60), drying(100,300))
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local BAND = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.12}}
local CR = pile{{"raw sienna",1},{"Mars orange",0.25},{"bone brown",0.5},{"lead white",0.35}}
local BL = pile{{"bone black",2},{"bone brown",0.8},{"lead white",0.1}}
local BE = pile{{"lead white",0.8},{"ultramarine ash",0.35},{"bone black",0.6}}
local function L(p, pts, pr_, w, sw) local b = brush{kind="rigger", width=w, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_, pr_*0.8}, swell=sw, ramps={0.05, 0.15}}) end
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local sc = 1 / ((a.za + a.zb)/2)
    local w = clamp(2.0*sc, 0.4, 2.2)
    -- segment bands across the shell, bowing downward
    for _, h in ipairs({0.82, 0.68, 0.54, 0.40}) do
      local half = 0.36*math.sqrt(math.max(0.05, 1 - ((h - 0.52)/0.45)^2))
      local pts = {}
      for j = 0, 8 do local f = j/8 pts[#pts+1] = ap(a, 0.5 - half + 2*half*f, h - 0.05*math.sin(f*math.pi)) end
      L(JD, pts, 0.55, w*0.9)
      local pts2 = {} for _, p in ipairs(pts) do pts2[#pts2+1] = {p[1], p[2] - w*0.9} end
      L(BAND, pts2, 0.4, w*0.6)
    end
    -- lit crest crescent on top
    local cr = {}
    for j = 0, 10 do local t = math.pi*(0.15 + 0.7*j/10) cr[#cr+1] = ap(a, 0.5 + 0.37*math.cos(t), 0.53 + 0.42*math.sin(t)) end
    L(CR, cr, 0.6, w*1.1, {0.4, 1, 0.4})
    -- bladed forelimbs: curved sickles folded across the front
    L(BL, {ap(a, 0.16, 0.8), ap(a, 0.1, 0.55), ap(a, 0.28, 0.3), ap(a, 0.6, 0.22)}, 0.75, w*1.8, {0.5, 1.2, 1, 0.2})
    L(BL, {ap(a, 0.84, 0.8), ap(a, 0.9, 0.55), ap(a, 0.72, 0.3), ap(a, 0.4, 0.22)}, 0.75, w*1.8, {0.5, 1.2, 1, 0.2})
    L(BE, {ap(a, 0.13, 0.62), ap(a, 0.22, 0.36), ap(a, 0.58, 0.25)}, 0.3, w*0.5)
    -- folded legs out at the sides, knees up
    for j, h in ipairs({0.45, 0.33, 0.22}) do
      L(BL, {ap(a, 0.12, h), ap(a, 0.04, h + 0.1), ap(a, 0.06, h - 0.12)}, 0.6, w*0.8)
      L(BL, {ap(a, 0.88, h), ap(a, 0.96, h + 0.1), ap(a, 0.94, h - 0.12)}, 0.6, w*0.8)
    end
  end
end

--@ chunk 7
print(wait(6*24*60), drying(505,400))
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
 armRf = {{52, 156}, {66, 162}, {40, 234}, {28, 228}},
 handR = {{20, 226}, {38, 222}, {40, 244}, {22, 248}},
}
FORD = {"footR","greaveR","kneeR","cuisseR","footL","greaveL","kneeL","cuisseL","faulds","torso","armLu","armLv","gauntL","paulL","gorget","helm","paulR","armRu","armRf","handR"}
local a = nil
for _, k in ipairs(FORD) do local m = pp(FP[k]) a = a and (a + m) or m end
FIG = a
local FC = pile{{"bone black",2.2},{"ultramarine blue",0.4},{"lead white",0.12}}
work(FIG, {hand="detail", pile=FC, coverage=5, fill=true, clip=FIG, tool={kind="round", width=1.3}, length={2, 5}})

--@ chunk 8
print(wait(8*24*60), drying(492,400), drying(505,392))
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local MG = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"lead white",0.25}}
local r
local function ln(p, uv, pr_, w) r = brush{kind="rigger", width=w or 0.6, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG:grow(0.4)}) end
-- plate separations
for _, s in ipairs({{{-27, 72}, {-6, 72}}, {{10, 84}, {30, 82}}, {{-28, 86}, {-5, 86}}, {{8, 97}, {31, 96}}, {{-31, 132}, {32, 132}},
  {{-36, 125}, {36, 125}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-14, 224}, {14, 224}}, {{-42, 151}, {-58, 151}}, {{-43, 103}, {-61, 104}}}) do ln(JD, s, 0.55, 0.7) end
for _, v in ipairs({138, 145}) do ln(JD, {{-35, v}, {0, v - 1}, {34, v}}, 0.45, 0.6) end
ln(JD, {{0, 150}, {1, 180}, {0, 208}}, 0.5, 0.7)
-- faint edges where the cold far light and his own lamp's bounce graze the plates
ln(MG, {{-17, 224}, {-20, 250}, {-10, 265}}, 0.35, 0.5)
ln(MG, {{-56, 186}, {-56, 214}}, 0.35, 0.5)
ln(MG, {{-58, 150}, {-60, 104}}, 0.3, 0.45)
ln(MG, {{54, 188}, {66, 160}}, 0.35, 0.5)
ln(MG, {{-28, 0}, {-6, 0}}, 0.4, 0.5)
-- the lamp at his left shoulder, turned low: a small warm point and a short beam down to the pool
local LP = pile{{"lead white",2},{"cadmium yellow",0.4},{"Mars orange",0.1}}
local q = P(-40, 200)
local l = brush{kind="round", width=1.6, point=0.3}
l:load(LP, 0.95) l:touch(q[1], q[2], {pressure=0.5})

--@ chunk 9
print(wait(6*24*60))
-- the far amber hazard lamp and its wash on the end wall
local AW = pile{{"bone black",1},{"Mars orange",0.45},{"raw sienna",0.4},{"lead white",0.12}}
local w = ellipse(505, 240, 34, 18) * ENDW
work(w, {hand="detail", pile=AW, coverage=3.5, fill=true, clip=w, tool={kind="round", width=1.4}, length={2, 5}})
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.35}}
local h = brush{kind="round", width=3, point=0.3}
h:load(AM, 0.95) h:touch(505, 237, {pressure=0.7})
local k = brush{kind="round", width=1.4, point=0.3}
k:load(AH, 0.95) k:touch(505, 236.5, {pressure=0.6})
-- a thin amber line along the far floor edge and the last pilasters
local r = brush{kind="rigger", width=0.6, point=1}
r:load(AW, 0.8) r:stroke({pr(-XW, YF, ZF), pr(XW, YF, ZF)}, {pressure={0.4, 0.4}})
-- the cold eyes: one pinpoint per sleeping Warden, receding in two rows
local EY = pile{{"zinc white",2},{"cerulean blue",0.6},{"lead white",1}}
local EH = pile{{"cerulean blue",1},{"ultramarine blue",0.4},{"lead white",0.6},{"bone black",0.5}}
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local sc = 1 / ((a.za + a.zb)/2)
    local e = ap(a, 0.5, 0.6)
    local g = brush{kind="round", width=clamp(5*sc, 1.4, 5), point=0.2}
    g:load(EH, 0.4) g:touch(e[1], e[2], {pressure=0.25})
    local p = brush{kind="round", width=clamp(1.6*sc, 0.7, 1.6), point=0.3}
    p:load(EY, 0.95) p:touch(e[1], e[2], {pressure=0.6})
  end
end

--@ chunk 10
print(wait(20*24*60), drying(492,400), drying(505,392), drying(505,240))
local FC = pile{{"bone black",2.4},{"ultramarine blue",0.35},{"lead white",0.06}}
for k = 1, 2 do work(FIG, {hand="body", pile=FC, coverage=4, fill=true, clip=FIG, tool={kind="filbert", width=1.8}, length={3, 6}, angle=1.57}) end
local w = ellipse(505, 240, 40, 22) * ENDW
work(w, {hand="detail", pile=BE, coverage=5, fill=true, clip=w, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 11
print(wait(10*24*60), drying(492,400), drying(505,240))
-- plates and edges restated on the dry figure
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local MG = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local WM = pile{{"bone black",1.2},{"raw sienna",0.5},{"Mars orange",0.1},{"lead white",0.25}}
local r
local function ln(p, uv, pr_, w) r = brush{kind="rigger", width=w or 0.6, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG:grow(0.4)}) end
for _, s in ipairs({{{-25, 72}, {-6, 72}}, {{11, 84}, {29, 82}}, {{-31, 132}, {32, 132}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-42, 151}, {-58, 151}}}) do ln(MG, {s[1], s[2]}, 0.4, 0.5) end
ln(MG, {{0, 150}, {1, 180}, {0, 208}}, 0.4, 0.6)
-- warm bounce from the pool ahead on the inner edges of the legs and the raised arm
ln(WM, {{-6, 12}, {-5, 84}}, 0.45, 0.6)
ln(WM, {{11, 32}, {9, 96}}, 0.45, 0.6)
ln(WM, {{-17, 224}, {-20, 250}, {-10, 265}, {12, 264}}, 0.4, 0.6)
ln(WM, {{28, 228}, {52, 156}}, 0.4, 0.6)
ln(WM, {{-34, 182}, {-56, 186}}, 0.35, 0.5)
local LP = pile{{"lead white",2},{"cadmium yellow",0.4},{"Mars orange",0.1}}
local q = P(-40, 200)
local l = brush{kind="round", width=1.8, point=0.3}
l:load(LP, 0.95) l:touch(q[1], q[2], {pressure=0.55})
-- far lamp: a small lens and a tight warm falloff on the end wall
local AW = pile{{"bone black",1},{"Mars orange",0.45},{"raw sienna",0.4},{"lead white",0.12}}
local AW2 = pile{{"bone black",1.4},{"Mars orange",0.25},{"raw sienna",0.4},{"lead white",0.08}}
local s = brush{kind="filbert", width=2.4, stiffness=0.5}
for k = 0, 23 do
  local a = k/24*2*math.pi
  s:load(AW2, 0.7) s:stroke({{505 + math.cos(a)*5, 238 + math.sin(a)*4}, {505 + math.cos(a)*16, 238 + math.sin(a)*11}}, {pressure={0.5, 0.05}, clip=ENDW})
  s:load(AW, 0.7) s:stroke({{505 + math.cos(a)*3, 238 + math.sin(a)*2.5}, {505 + math.cos(a)*9, 238 + math.sin(a)*6.5}}, {pressure={0.5, 0.1}, clip=ENDW})
end
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.35}}
local h = brush{kind="round", width=3, point=0.3}
h:load(AM, 0.95) h:touch(505, 238, {pressure=0.7})
local k = brush{kind="round", width=1.4, point=0.3}
k:load(AH, 0.95) k:touch(505, 237.5, {pressure=0.6})
-- eyes larger and colder
local EY = pile{{"zinc white",2},{"cerulean blue",0.6},{"lead white",1}}
for i, a in ipairs(ALC) do
  if not (a.sd < 0 and a.k == EMPTY) then
    local sc = 1 / ((a.za + a.zb)/2)
    local e = ap(a, 0.5, 0.6)
    local p = brush{kind="round", width=clamp(3.4*sc, 1.1, 3.2), point=0.3}
    p:load(EY, 0.95) p:touch(e[1], e[2], {pressure=0.65})
  end
end
