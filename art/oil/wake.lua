-- easel session "wake": a painting replayed chunk by chunk.
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
function skip(a) return (a.sd < 0 and a.k == EMPTY) or (a.sd > 0 and a.k == 2) end
for _, a in ipairs(ALC) do if a.sd > 0 and a.k == 2 then WAKE = a end end
function ap(a, s, h) local z = a.za + (a.zb - a.za)*s local Y = YF - h*(YF - a.top) return pr(a.sd*(XW + 8), Y, z) end
local shells = nil
for i, a in ipairs(ALC) do
  if not skip(a) then
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
  if not skip(a) then
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
  if not skip(a) then
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
  if not skip(a) then
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
print(wait(6*24*60), drying(500,400))
local a = WAKE
EYE = ap(a, 0.5, 0.6)
print(EYE[1], EYE[2])
-- cold spill on the floor and the near pilasters from the blazing eye
local CS = {
 pile{{"bone black",1.8},{"bone brown",0.5},{"ultramarine blue",0.6},{"lead white",0.1}},
 pile{{"bone black",1.3},{"ultramarine blue",0.6},{"cerulean blue",0.2},{"lead white",0.25}},
 pile{{"bone black",0.8},{"ultramarine blue",0.5},{"cerulean blue",0.35},{"lead white",0.5}},
}
local region = (FLOOR + RW) - RECM:grow(0.5)
local cells = {}
for y = 150, 566, 3 do for x = 330, 1004, 3.2 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  if region:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx, dy = (xx - EYE[1]), (yy - EYE[2])*0.8
    local d = math.sqrt(dx*dx + dy*dy)
    local fl = FLOOR:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5
    local v = 3.3 - d/(fl and 120 or 70) + randn(0, 0.3)
    if v > 0.7 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3.2, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(CS[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(CS[i], 0.9) end
    local an = math.atan(c.y - EYE[2], c.x - EYE[1])
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(an)*h, c.y - math.sin(an)*h}, {c.x + math.cos(an)*h, c.y + math.sin(an)*h}}, {pressure={0.7, 0.55}, clip=region})
  end
end end
print(#cells)
-- the waking Warden's dark body inside its alcove
local inner = poly((function() local p = {} for j = 0, 15 do local t = j/16*2*math.pi p[#p+1] = ap(a, 0.5 + 0.22*math.cos(t), 0.5 + 0.28*math.sin(t)) end return p end)(), true)
CORE = inner
work(inner, {hand="detail", pile=SH, coverage=4.5, fill=true, clip=inner, tool={kind="round", width=1.4}, length={2, 5}})

--@ chunk 8
print(wait(8*24*60), drying(900,330))
local a = WAKE
local c = ap(a, 0.5, 0.52)
-- the shell opening like a flower of blades: long narrow petals radiating from the body
local PET = pile{{"bone black",2},{"bone brown",0.9},{"raw sienna",0.2},{"lead white",0.05}}
local petals = nil
PETS = {}
for i, ang in ipairs({-2.75, -2.35, -1.95, -1.55, -1.15, -0.75, 2.6, 2.95}) do
  local L = ((ang < -1.3 and ang > -1.8) and 150 or 110) * (0.85 + 0.2*((i*0.618) % 1))
  local tipx, tipy = c[1] + math.cos(ang)*L*0.75, c[2] + math.sin(ang)*L
  local nx, ny = -math.sin(ang), math.cos(ang)
  local w = 7
  local bend = 0.18
  local mid = {c[1] + math.cos(ang + bend)*L*0.45, c[2] + math.sin(ang + bend)*L*0.55}
  local pts = {{c[1] + nx*w*0.6, c[2] + ny*w*0.6}, {mid[1] + nx*w, mid[2] + ny*w}, {tipx, tipy}, {mid[1] - nx*w*0.6, mid[2] - ny*w*0.6}, {c[1] - nx*w*0.6, c[2] - ny*w*0.6}}
  local m = poly(pts, true)
  petals = petals and (petals + m) or m
  PETS[#PETS+1] = {c=c, mid=mid, tip={tipx, tipy}, nx=nx, ny=ny}
end
-- forelimbs unfolding toward the aisle: two long jointed blades
local function limb(pts, w0, w1)
  local L, R = {}, {}
  for i, p in ipairs(pts) do
    local q1 = pts[math.min(i+1, #pts)] local q0 = pts[math.max(i-1, 1)]
    local dx, dy = q1[1] - q0[1], q1[2] - q0[2] local l = math.sqrt(dx*dx + dy*dy) + 1e-6
    local w = w0 + (w1 - w0)*(i-1)/(#pts-1)
    L[#L+1] = {p[1] - dy/l*w, p[2] + dx/l*w} R[#R+1] = {p[1] + dy/l*w, p[2] - dx/l*w}
  end
  local out = {} for _, p in ipairs(L) do out[#out+1] = p end for i = #R, 1, -1 do out[#out+1] = R[i] end
  return poly(out, true)
end
LIMB1 = {{c[1] - 10, c[2] - 30}, {c[1] - 70, c[2] - 95}, {c[1] - 150, c[2] - 60}, {c[1] - 200, c[2] + 10}}
LIMB2 = {{c[1] - 12, c[2] + 20}, {c[1] - 80, c[2] + 5}, {c[1] - 160, c[2] + 60}, {c[1] - 190, c[2] + 120}}
local arms = limb(LIMB1, 6, 1.5) + limb(LIMB2, 6, 1.5)
-- legs unfolding at the bottom
local legs = nil
for _, L in ipairs({{{c[1] - 5, c[2] + 40}, {c[1] - 40, c[2] + 70}, {c[1] - 55, c[2] + 115}}, {{c[1] + 5, c[2] + 42}, {c[1] - 15, c[2] + 85}, {c[1] - 20, c[2] + 125}}, {{c[1] + 15, c[2] + 35}, {c[1] + 30, c[2] + 80}, {c[1] + 22, c[2] + 120}}}) do
  local m = limb(L, 3.5, 1.5) legs = legs and (legs + m) or m
end
WK = petals + arms + legs + CORE
work(WK, {hand="detail", pile=PET, coverage=4.5, fill=true, clip=WK, tool={kind="round", width=1.3}, length={2, 5}})

--@ chunk 9
print(wait(10*24*60), drying(880,300))
local a = WAKE
local rec = poly((function() local p = {} p[#p+1] = ap(a, 0, 0) p[#p+1] = ap(a, 0, 1) for j = 1, 7 do local f = j/8 p[#p+1] = ap(a, f, 1 + 0.25*math.sin(f*math.pi)) end p[#p+1] = ap(a, 1, 1) p[#p+1] = ap(a, 1, 0) return p end)()) * RECM
local CB = {
 pile{{"bone black",1.6},{"ultramarine blue",0.6},{"lead white",0.18}},
 pile{{"bone black",1.1},{"ultramarine blue",0.6},{"cerulean blue",0.25},{"lead white",0.35}},
 pile{{"bone black",0.6},{"ultramarine blue",0.4},{"cerulean blue",0.4},{"lead white",0.7}},
}
local region = rec - WK:grow(0.5)
local cells = {}
for y = 100, 566, 2.6 do for x = 780, 1004, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if region:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local d = math.sqrt((xx - EYE[1])^2 + ((yy - EYE[2])*0.7)^2)
    local v = 3.4 - d/45 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 3)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(CB[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(CB[i], 0.9) end
    local an = math.atan(c.y - EYE[2], c.x - EYE[1])
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(an)*h, c.y - math.sin(an)*h}, {c.x + math.cos(an)*h, c.y + math.sin(an)*h}}, {pressure={0.7, 0.55}, clip=region})
  end
end end
print(#cells)
local DKW = pile{{"bone black",2.5},{"bone brown",0.4},{"ultramarine blue",0.3}}
work(WK, {hand="detail", pile=DKW, coverage=5, fill=true, clip=WK, tool={kind="round", width=1.2}, length={2, 5}})

--@ chunk 10
print(wait(8*24*60), drying(500,380), drying(880,300))
-- the Commando's long shadow thrown down the aisle by the eye
FB = {529, 394}
local S = 0.36
function P(u, v) return {FB[1] + u*S, FB[2] - v*S} end
function pp(t) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, true) end
local SHC = pile{{"bone black",2.4},{"ultramarine blue",0.5}}
local sh = poly({{512, 392}, {546, 397}, {388, 352}, {362, 342}, {366, 334}}, true) * FLOOR
work(sh:soften(1.5), {hand="detail", pile=SHC, coverage=4.5, fill=true, clip=FLOOR, tool={kind="round", width=1.6}, length={3, 8}, angle=0.3})
-- the figure: turned toward the light, half-crouched, cannon coming up
FP = {
 footB = {{-62, 0}, {-38, -2}, {-38, 9}, {-60, 10}},
 shinB = {{-54, 8}, {-40, 6}, {-22, 52}, {-36, 58}},
 thighB = {{-36, 50}, {-20, 46}, {-2, 98}, {-20, 104}},
 footF = {{30, 0}, {56, 0}, {56, 10}, {32, 11}},
 shinF = {{34, 8}, {50, 8}, {48, 62}, {32, 64}},
 thighF = {{30, 60}, {50, 58}, {20, 104}, {2, 100}},
 faulds = {{-26, 96}, {24, 98}, {22, 122}, {-24, 120}},
 torso = {{-26, 118}, {26, 122}, {44, 186}, {-6, 194}, {-24, 168}},
 gorget = {{12, 186}, {34, 182}, {38, 198}, {16, 202}},
 helm = {{20, 196}, {44, 192}, {58, 206}, {56, 226}, {38, 232}, {20, 222}},
 paul = {{-14, 168}, {14, 176}, {22, 196}, {2, 204}, {-18, 190}},
 armB = {{-4, 160}, {10, 158}, {54, 150}, {50, 138}},
 cannon = {{22, 158}, {150, 214}, {146, 230}, {18, 176}},
 muzzle = {{140, 206}, {162, 214}, {156, 236}, {136, 228}},
 armF = {{30, 150}, {44, 146}, {70, 176}, {58, 184}},
}
FORD = {"footB","shinB","thighB","footF","shinF","thighF","faulds","torso","armB","paul","gorget","helm","cannon","muzzle","armF"}
local m = nil
for _, k in ipairs(FORD) do local q = pp(FP[k]) m = m and (m + q) or q end
FIG = m

--@ chunk 11
print(wait(10*24*60), drying(529,370))
local FC = pile{{"bone black",2.4},{"ultramarine blue",0.35},{"lead white",0.06}}
for k = 1, 2 do work(FIG, {hand="body", pile=FC, coverage=4, fill=true, clip=FIG, tool={kind="filbert", width=1.5}, length={2, 5}, angle=1.57}) end

--@ chunk 12
print(wait(10*24*60), drying(529,370), drying(880,300))
local r
local function L(p, pts, pr_, w, sw) r = brush{kind="rigger", width=w, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.8}, swell=sw, ramps={0.05, 0.15}}) end
local COLD = pile{{"lead white",1.6},{"cerulean blue",0.35},{"ultramarine blue",0.15}}
local COLDM = pile{{"lead white",0.9},{"cerulean blue",0.3},{"ultramarine blue",0.3},{"bone black",0.4}}
local WARM = pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.15}}
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
-- petals: inner edges lit cold by the eye, outer edges a dull bronze
for _, p in ipairs(PETS) do
  L(COLD, {{p.c[1] + p.nx*3, p.c[2] + p.ny*3}, {p.mid[1] + p.nx*5, p.mid[2] + p.ny*5}, p.tip}, 0.5, 1.1, {1, 0.8, 0.2})
end
L(COLD, LIMB1, 0.45, 1.0, {1, 0.8, 0.4, 0.1})
L(COLD, LIMB2, 0.45, 1.0, {1, 0.8, 0.4, 0.1})
-- crest rising straight up from the opened shell
local a = WAKE
local c = ap(a, 0.5, 0.52)
L(JD, {{c[1] + 2, c[2] - 30}, {c[1] + 6, c[2] - 110}, {c[1], c[2] - 175}}, 0.8, 3.2, {1, 0.7, 0.1})
L(COLDM, {{c[1] - 1, c[2] - 32}, {c[1] + 3, c[2] - 110}, {c[1] - 1, c[2] - 170}}, 0.45, 1.0)
-- figure plates and rims: cold on the side facing the Warden, warm lamp at the helm
local function fl(p, uv, pr_, w) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end L(p, pts, pr_, w) end
fl(COLD, {{44, 192}, {58, 206}, {56, 226}}, 0.55, 0.7)
fl(COLD, {{26, 122}, {44, 186}}, 0.5, 0.7)
fl(COLD, {{50, 8}, {48, 62}}, 0.45, 0.6)
fl(COLD, {{50, 58}, {20, 104}}, 0.4, 0.6)
fl(COLD, {{22, 158}, {150, 214}}, 0.5, 0.7)
fl(COLD, {{140, 206}, {162, 214}, {156, 236}}, 0.5, 0.7)
fl(COLD, {{14, 176}, {22, 196}}, 0.4, 0.6)
fl(COLDM, {{-40, 6}, {-22, 52}}, 0.35, 0.5)
fl(JD, {{-24, 120}, {22, 122}}, 0.5, 0.6)
fl(JD, {{-36, 50}, {-20, 46}}, 0.5, 0.6)
-- the lamp, full on: a bright warm point at the helm and its warm beam reaching to the Warden
local lp = P(52, 214)
local lb = brush{kind="round", width=2.6, point=0.3}
lb:load(WARM, 0.95) lb:touch(lp[1], lp[2], {pressure=0.7})
local BEAM = pile{{"lead white",1},{"cadmium yellow",0.2},{"Mars orange",0.06},medium=0.6}
local beam = poly({{lp[1], lp[2] - 2}, {c[1] - 40, c[2] - 70}, {c[1] - 20, c[2] + 80}, {lp[1], lp[2] + 2}})
work(beam, {hand="glaze", pile=BEAM, coverage=0.8, fill=true, clip=beam, angle=math.atan(c[2] - lp[2], c[1] - lp[1]), load=0.22, pressure={0.08, 0.18}, length={40, 90}, tool={kind="filbert", width=6, stiffness=0.2}})
-- warm light caught on the petals facing him
for i, p in ipairs(PETS) do if i <= 3 then L(pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.7}}, {{p.mid[1] - p.nx*4, p.mid[2] - p.ny*4}, p.tip}, 0.4, 0.8) end end

--@ chunk 13
print(wait(8*24*60))
-- the eye blazing: a cold white core and radial strokes, then a radial blend on dry paint
local E = EYE
local C1 = pile{{"lead white",1},{"cerulean blue",0.4},{"ultramarine blue",0.3},{"bone black",0.3}}
local C2 = pile{{"lead white",1.8},{"cerulean blue",0.35},{"zinc white",0.5}}
local s = brush{kind="filbert", width=2.4, stiffness=0.5}
for k = 0, 35 do
  local an = k/36*2*math.pi + rand(-0.05, 0.05)
  s:load(C1, 0.7) s:stroke({{E[1] + math.cos(an)*6, E[2] + math.sin(an)*6}, {E[1] + math.cos(an)*rand(22, 34), E[2] + math.sin(an)*rand(22, 34)}}, {pressure={0.5, 0.05}})
  s:load(C2, 0.7) s:stroke({{E[1] + math.cos(an)*3, E[2] + math.sin(an)*3}, {E[1] + math.cos(an)*rand(10, 16), E[2] + math.sin(an)*rand(10, 16)}}, {pressure={0.55, 0.1}})
end
blend(ellipse(E[1], E[2], 36, 36), {angle=function(x,y) return math.atan(y - E[2], x - E[1]) end, tool={kind="badger", width=5}, length={8, 18}})

--@ chunk 14
print(wait(8*24*60))
local E = EYE
local HOT = pile{{"zinc white",2},{"lead white",1.5},{"cerulean blue",0.12}}
local k = brush{kind="round", width=6, point=0.3}
k:load(HOT, 0.95) k:touch(E[1], E[2], {pressure=0.8})
local f = brush{kind="rigger", width=1.0, point=1}
f:load(HOT, 0.9) f:stroke({{E[1] - 30, E[2]}, {E[1], E[2]}, {E[1] + 30, E[2]}}, {pressure={0.0, 0.6, 0.0}, swell={0.1, 1, 0.1}})
f:load(HOT, 0.9) f:stroke({{E[1], E[2] - 22}, {E[1], E[2]}, {E[1], E[2] + 22}}, {pressure={0.0, 0.5, 0.0}, swell={0.1, 1, 0.1}})
-- every other eye one step brighter: a slightly larger point and a faint halo
local EY = pile{{"zinc white",2},{"cerulean blue",0.6},{"lead white",1}}
local EH = pile{{"cerulean blue",1},{"ultramarine blue",0.4},{"lead white",0.8},{"bone black",0.4}}
for i, a in ipairs(ALC) do
  if not skip(a) then
    local sc = 1 / ((a.za + a.zb)/2)
    local e = ap(a, 0.5, 0.6)
    local g = brush{kind="round", width=clamp(9*sc, 2.4, 8), point=0.2}
    g:load(EH, 0.5) g:touch(e[1], e[2], {pressure=0.3})
    local p = brush{kind="round", width=clamp(4.5*sc, 1.4, 4), point=0.3}
    p:load(EY, 0.95) p:touch(e[1], e[2], {pressure=0.7})
  end
end
-- the far amber lamp, as before
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.35}}
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local h = brush{kind="round", width=3, point=0.3}
h:load(AM, 0.95) h:touch(505, 238, {pressure=0.7})
local kk = brush{kind="round", width=1.4, point=0.3}
kk:load(AH, 0.95) kk:touch(505, 237.5, {pressure=0.6})

--@ chunk 15
print(wait(15*24*60), drying(700,330), drying(529,370))
local lp = P(52, 214)
local c = ap(WAKE, 0.5, 0.52)
local beam = poly({{lp[1], lp[2] - 2}, {c[1] - 40, c[2] - 70}, {c[1] - 20, c[2] + 80}, {lp[1], lp[2] + 2}}):grow(3)
local dir = math.atan(c[2] - lp[2], c[1] - lp[1])
local Lb = math.sqrt((c[1]-lp[1])^2 + (c[2]-lp[2])^2)
local BP = {
 pile{{"bone black",1.8},{"ultramarine blue",0.6},{"lead white",0.15}},
 pile{{"bone black",1.3},{"ultramarine blue",0.4},{"raw sienna",0.3},{"lead white",0.3}},
 pile{{"bone black",0.8},{"raw sienna",0.5},{"yellow ochre",0.3},{"lead white",0.55}},
 pile{{"lead white",1.5},{"yellow ochre",0.35},{"cadmium yellow",0.1},{"bone black",0.15}},
}
local cells = {}
for y = 200, 470, 2.4 do for x = 540, 900, 2.6 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if beam:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.3 then
    local px, py = xx - lp[1], yy - lp[2]
    local along = (px*math.cos(dir) + py*math.sin(dir)) / Lb
    local across = math.abs(-px*math.sin(dir) + py*math.cos(dir)) / (2 + along*72)
    local v = 4.1 - along*2.2 - across*2.4 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 4)}
  end
end end
local g = {}
for _, cc in ipairs(cells) do g[cc.i] = g[cc.i] or {} table.insert(g[cc.i], cc) end
local b = brush{kind="filbert", width=2.8, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, cc in ipairs(g[i]) do
    if n % 4 == 0 then b:load(BP[i], 0.9) end
    local h = rand(4, 9)
    b:stroke({{cc.x - math.cos(dir)*h, cc.y - math.sin(dir)*h}, {cc.x + math.cos(dir)*h, cc.y + math.sin(dir)*h}}, {pressure={0.75, 0.6}, clip=beam - FIG - WK})
  end
end end
print(#cells)
-- figure repainted dark (the stray rim lines lay across it)
local FC = pile{{"bone black",2.4},{"ultramarine blue",0.35},{"lead white",0.06}}
work(FIG:grow(1.2), {hand="detail", pile=FC, coverage=5, fill=true, clip=FIG:grow(1.2), tool={kind="round", width=1.0}, length={2, 4}})

--@ chunk 16
print(wait(12*24*60), drying(700,330), drying(529,370))
local lp = P(52, 214)
local c = ap(WAKE, 0.5, 0.52)
local beam = poly({{lp[1], lp[2] - 2}, {c[1] - 40, c[2] - 70}, {c[1] - 20, c[2] + 80}, {lp[1], lp[2] + 2}}):grow(3)
blend(beam:shrink(1) - FIG:grow(1) - WK:grow(1), {angle=math.atan(c[2] - lp[2], c[1] - lp[1]), tool={kind="badger", width=8}, length={30, 60}})

--@ chunk 17
print(wait(12*24*60), drying(700,330), drying(529,370))
local r
local function L(p, pts, pr_, w) r = brush{kind="rigger", width=w, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.8}, ramps={0.05, 0.15}, clip=FIG:grow(0.3)}) end
local COLD = pile{{"lead white",1.6},{"cerulean blue",0.35},{"ultramarine blue",0.15}}
local function fl(p, uv, pr_, w) local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end L(p, pts, pr_, w) end
-- cold rims only along the outline edges that face the Warden, clipped to the figure
fl(COLD, {{44, 192}, {58, 206}, {56, 226}}, 0.5, 0.6)
fl(COLD, {{26, 122}, {44, 186}}, 0.45, 0.6)
fl(COLD, {{50, 8}, {48, 62}}, 0.4, 0.5)
fl(COLD, {{22, 160}, {148, 216}}, 0.45, 0.6)
fl(COLD, {{140, 206}, {162, 214}, {156, 236}}, 0.45, 0.6)
local WARM = pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.15}}
local lp = P(52, 214)
local lb = brush{kind="round", width=3, point=0.3}
lb:load(WARM, 0.95) lb:touch(lp[1], lp[2], {pressure=0.75})

--@ chunk 18
print(wait(10*24*60), drying(700,330))
local lp = P(52, 214)
local c = ap(WAKE, 0.5, 0.52)
WEDGE = poly({{lp[1], lp[2] - 2}, {c[1] - 40, c[2] - 70}, {c[1] - 20, c[2] + 80}, {lp[1], lp[2] + 2}}):grow(5)
CORE2 = poly({{lp[1], lp[2] - 1.5}, {c[1] - 30, c[2] - 20}, {c[1] - 30, c[2] + 18}, {lp[1], lp[2] + 1.5}})
local region = WEDGE - CORE2 - FIG:grow(0.5) - WK:grow(0.5)
local fl = region * FLOOR
local rest = region - FLOOR
local shellr = rest * SHELLS
local recr = rest * RECM - SHELLS
local wallr = rest - RECM
work(recr, {hand="detail", pile=REC, coverage=5, fill=true, clip=recr, tool={kind="round", width=1.6}, length={3, 7}})
work(shellr, {hand="detail", pile=SH, coverage=5, fill=true, clip=shellr, tool={kind="round", width=1.6}, length={3, 7}})
work(wallr, {hand="detail", pile=PIL, coverage=5, fill=true, clip=wallr, tool={kind="round", width=1.6}, length={3, 7}})
-- floor: the cold spill again, dithered by distance from the eye
local CS = {
 BF,
 pile{{"bone black",1.8},{"bone brown",0.5},{"ultramarine blue",0.6},{"lead white",0.1}},
 pile{{"bone black",1.3},{"ultramarine blue",0.6},{"cerulean blue",0.2},{"lead white",0.25}},
 pile{{"bone black",0.8},{"ultramarine blue",0.5},{"cerulean blue",0.35},{"lead white",0.5}},
}
local cells = {}
for y = 300, 520, 2.8 do for x = 540, 920, 3 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  if fl:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local d = math.sqrt((xx - EYE[1])^2 + ((yy - EYE[2])*0.8)^2)
    local v = 4.3 - d/120 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 4)}
  end
end end
local g = {}
for _, cc in ipairs(cells) do g[cc.i] = g[cc.i] or {} table.insert(g[cc.i], cc) end
local b = brush{kind="filbert", width=3.2, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(CS[i], 0.9)
  for n, cc in ipairs(g[i]) do
    if n % 4 == 0 then b:load(CS[i], 0.9) end
    local an = math.atan(cc.y - EYE[2], cc.x - EYE[1])
    local h = rand(3, 6)
    b:stroke({{cc.x - math.cos(an)*h, cc.y - math.sin(an)*h}, {cc.x + math.cos(an)*h, cc.y + math.sin(an)*h}}, {pressure={0.7, 0.55}, clip=fl})
  end
end end
print(#cells)
-- the waking Warden's limbs and petals, dark again (the old crackle lay on them)
local DKW = pile{{"bone black",2.5},{"bone brown",0.4},{"ultramarine blue",0.3}}
work(WK - CORE, {hand="detail", pile=DKW, coverage=5, fill=true, clip=WK - CORE, tool={kind="round", width=1.1}, length={2, 5}})

--@ chunk 19
print(wait(12*24*60), drying(700,330), drying(880,300))
-- restate the shell bands, crest and blades on the right-hand Wardens the wedge crossed, clipped to the repainted area
local reg = WEDGE - CORE2
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local BAND = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.12}}
local CR = pile{{"raw sienna",1},{"Mars orange",0.25},{"bone brown",0.5},{"lead white",0.35}}
local BL = pile{{"bone black",2},{"bone brown",0.8},{"lead white",0.1}}
local function L(p, pts, pr_, w, sw) local b = brush{kind="rigger", width=w, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr_, pr_*0.8}, swell=sw, ramps={0.05, 0.15}, clip=reg}) end
for i, a in ipairs(ALC) do
  if a.sd > 0 and not skip(a) and a.k <= 5 then
    local sc = 1 / ((a.za + a.zb)/2)
    local w = clamp(2.0*sc, 0.4, 2.2)
    for _, h in ipairs({0.82, 0.68, 0.54, 0.40}) do
      local half = 0.36*math.sqrt(math.max(0.05, 1 - ((h - 0.52)/0.45)^2))
      local pts = {}
      for j = 0, 8 do local f = j/8 pts[#pts+1] = ap(a, 0.5 - half + 2*half*f, h - 0.05*math.sin(f*math.pi)) end
      L(JD, pts, 0.55, w*0.9)
    end
    local cr = {}
    for j = 0, 10 do local t = math.pi*(0.15 + 0.7*j/10) cr[#cr+1] = ap(a, 0.5 + 0.37*math.cos(t), 0.53 + 0.42*math.sin(t)) end
    L(CR, cr, 0.6, w*1.1, {0.4, 1, 0.4})
    L(BL, {ap(a, 0.16, 0.8), ap(a, 0.1, 0.55), ap(a, 0.28, 0.3), ap(a, 0.6, 0.22)}, 0.75, w*1.8, {0.5, 1.2, 1, 0.2})
    L(BL, {ap(a, 0.84, 0.8), ap(a, 0.9, 0.55), ap(a, 0.72, 0.3), ap(a, 0.4, 0.22)}, 0.75, w*1.8, {0.5, 1.2, 1, 0.2})
  end
end
-- the lamp beam, narrow: warm, brightest at the lamp, fading toward the Warden, dithered at its edges
local lp = P(52, 214)
local c = ap(WAKE, 0.5, 0.52)
local dir = math.atan(c[2] - lp[2], c[1] - lp[1])
local Lb = math.sqrt((c[1]-lp[1])^2 + (c[2]-lp[2])^2)
local BP = {
 pile{{"bone black",1.4},{"ultramarine blue",0.4},{"raw sienna",0.3},{"lead white",0.25}},
 pile{{"bone black",0.9},{"raw sienna",0.5},{"yellow ochre",0.3},{"lead white",0.5}},
 pile{{"lead white",1.5},{"yellow ochre",0.35},{"cadmium yellow",0.1},{"bone black",0.15}},
 pile{{"lead white",2},{"cadmium yellow",0.3}},
}
local core = CORE2 - FIG:grow(0.5) - WK:grow(0.5)
local cells = {}
for y = 230, 420, 2.2 do for x = 540, 900, 2.4 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if core:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.4 then
    local px, py = xx - lp[1], yy - lp[2]
    local along = (px*math.cos(dir) + py*math.sin(dir)) / Lb
    local across = math.abs(-px*math.sin(dir) + py*math.cos(dir)) / (1.5 + along*20)
    local v = 4.5 - along*2.5 - across*1.8 + randn(0, 0.35)
    if v > 0.6 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 4)} end
  end
end end
local g = {}
for _, cc in ipairs(cells) do g[cc.i] = g[cc.i] or {} table.insert(g[cc.i], cc) end
local b = brush{kind="filbert", width=2.4, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, cc in ipairs(g[i]) do
    if n % 4 == 0 then b:load(BP[i], 0.9) end
    local h = rand(4, 9)
    b:stroke({{cc.x - math.cos(dir)*h, cc.y - math.sin(dir)*h}, {cc.x + math.cos(dir)*h, cc.y + math.sin(dir)*h}}, {pressure={0.7, 0.55}, clip=core})
  end
end end
print(#cells)

--@ chunk 20
print(wait(12*24*60), drying(700,330), drying(880,300))
local r
local function L(p, pts, pr_, w, sw) r = brush{kind="rigger", width=w, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.8}, swell=sw, ramps={0.05, 0.15}, clip=WK:grow(0.4)}) end
local COLD = pile{{"lead white",1.6},{"cerulean blue",0.35},{"ultramarine blue",0.15}}
for _, p in ipairs(PETS) do L(COLD, {{p.c[1] + p.nx*3, p.c[2] + p.ny*3}, {p.mid[1] + p.nx*5, p.mid[2] + p.ny*5}, p.tip}, 0.5, 1.0, {1, 0.8, 0.2}) end
L(COLD, LIMB1, 0.45, 0.9, {1, 0.8, 0.4, 0.1})
L(COLD, LIMB2, 0.45, 0.9, {1, 0.8, 0.4, 0.1})
local WP = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.7}}
for i, p in ipairs(PETS) do if i <= 3 then L(WP, {{p.mid[1] - p.nx*4, p.mid[2] - p.ny*4}, p.tip}, 0.35, 0.7) end end
local HOT = pile{{"zinc white",2},{"lead white",1.5},{"cerulean blue",0.12}}
local k = brush{kind="round", width=6, point=0.3}
k:load(HOT, 0.95) k:touch(EYE[1], EYE[2], {pressure=0.8})
