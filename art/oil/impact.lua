-- easel session "impact": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=9031, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.15}, {pile={{"lead white",0.6},{"Mars brown",2},{"ultramarine blue",2},{"bone black",0.8}}, um=40, apply="brush", texture=0.4}}} print(W,H)

--@ chunk 2
LX0, LX1 = 600, 370
LA = {-(LX0-LX1)/math.sqrt((LX0-LX1)^2+H^2), H/math.sqrt((LX0-LX1)^2+H^2)}   -- along axis (down-left)
LN = {LA[2], -LA[1]}   -- across, to the right
function dd(x, y) return (x - LX0)*LN[1] + y*LN[2] end
function uu(x, y) return (x - LX0)*LA[1] + y*LA[2] end
function XY(u, d) return LX0 + u*LA[1] + d*LN[1], u*LA[2] + d*LN[2] end
AXA = math.atan(LA[2], LA[1])
function M_hull() return mask(function(x,y) return dd(x,y) >= 0 and 1 or 0 end) end
function M_band(d0, d1) return mask(function(x,y) local d = dd(x,y) return (d >= d0 and d < d1) and 1 or 0 end) end
K1 = pile{{"bone black",2},{"ultramarine blue",1}}
K2 = pile{{"bone black",2},{"ultramarine blue",1.2},{"cobalt violet",0.15},{"lead white",0.08}}
local sky = -M_hull()
work(sky, {hand="broad", pile=K1, coverage=3, fill=true, angle=0.1, angle_jitter=0.15, clip=true})
print(XY(0,0)) print(XY(600,0)) print(dd(1000,562), dd(1000,0))

--@ chunk 3
HP = {
 pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.5}},
 pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}},
 pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
 pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.3}},
 pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}},
 pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",2},{"cadmium yellow",0.3}},
}
HB = {0, 55, 125, 205, 285, 370, 700}
local hull = M_hull()
for i = 1, 6 do
  local m = M_band(HB[i], HB[i+1]) * hull
  work(m, {hand="body", pile=HP[i], coverage=2.6, fill=true, angle=AXA, angle_jitter=0.12, length={30,80}, edge="soft", clip=hull})
end

--@ chunk 4
print(wait(30*60)) print(drying(200,200), drying(560,300), drying(900,400))

--@ chunk 5
print(wait(48*60)) print(drying(200,200), drying(560,300), drying(900,400))

--@ chunk 6
R = {
 pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.6}},
 pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3},{"yellow ochre",0.3}},
 pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}},
 pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
 pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.3}},
 pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}},
 pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",2},{"cadmium yellow",0.3}},
 pile{{"lead white",3},{"yellow ochre",1},{"lemon chrome",0.5}},
}
LN1 = noise{seed=11, period=120, octaves=3}
function lightstep(x, y)
  local d = dd(x, y)
  local t = smoothstep(165, 430, d + 30*LN1(x, y))
  return clamp(math.floor(1 + 7.4*t^1.1 + rand(-0.6, 0.6) + 0.5), 1, 8)
end
HULLC = M_hull()
function hull_strokes(list_fn, w, len, n_per_load)
  local by = {}
  for i = 1, 8 do by[i] = {} end
  for _, s in ipairs(list_fn) do table.insert(by[s.k], s) end
  local b = brush{kind="filbert", width=w, stiffness=0.55}
  for k = 1, 8 do
    local c = 0
    for _, s in ipairs(by[k]) do
      if c % n_per_load == 0 then b:reload(R[k], 0.8) end
      c = c + 1
      local L = s.L or len
      local x0, y0 = s.x - LA[1]*L*0.5, s.y - LA[2]*L*0.5
      local x1, y1 = s.x + LA[1]*L*0.5 + rand(-2,2), s.y + LA[2]*L*0.5
      b:stroke({{x0, y0}, {x1, y1}}, {pressure={0.8, 0.35}, ramps={0.1, 0.4}, clip=HULLC})
    end
  end
end
local list = {}
for u = -60, 760, 14 do
  for d = 0, 600, 6.5 do
    local x, y = XY(u + rand(-7, 7), d + rand(-2, 2))
    if x > -10 and x < 1010 and y > -10 and y < H + 10 then
      list[#list+1] = {x=x, y=y, k=lightstep(x, y), L=rand(26, 46)}
    end
  end
end
print(#list)
hull_strokes(list, 8, 36, 5)

--@ chunk 7
print(wait(3*24*60)) print(drying(200,200), drying(560,300), drying(700,100), drying(900,400))

--@ chunk 8
RC = 1100
function d_of_s(s) return RC*(1 - math.cos(s/RC)) end
function fsh(s) return math.max(0.1, math.sin(s/RC)) end
PLATES = {}
local row = 0
local s = 6
while s < 1180 do
  row = row + 1
  local step_u = 19 * rand(0.92, 1.08)
  local off = (row % 2) * step_u * 0.5 + rand(-3, 3)
  for u = -140 + off, 780, step_u do
    local uj = u + rand(-1.5, 1.5)
    local d = d_of_s(s + rand(-1.5, 1.5))
    local x, y = XY(uj, d)
    if x > -20 and x < 1020 and y > -20 and y < H + 20 then
      PLATES[#PLATES+1] = {u=uj, s=s, d=d, x=x, y=y, f=fsh(s), su=step_u*rand(0.9,1.1), k=lightstep(x,y)}
    end
  end
  s = s + 21 * rand(0.9, 1.1)
end
print(#PLATES)
function pt(p, a, b) return XY(p.u + a, p.d + b*p.f) end   -- a along axis, b across (true units)
function plate_shadows(list, pileF, w, pr)
  local b = brush{kind="round", width=w, point=0.6, stiffness=0.45}
  local cur, n = nil, 0
  for _, p in ipairs(list) do
    local pl = pileF(p)
    if pl then
      if pl ~= cur or n >= 6 then b:reload(pl, 0.8) cur = pl n = 0 end
      n = n + 1
      local hu, hs = p.su*0.5, 10.5
      local x0, y0 = pt(p, hu*0.35, -hs)
      local x1, y1 = pt(p, hu*0.95, -hs*0.3)
      local x2, y2 = pt(p, hu*0.95, hs*0.3)
      local x3, y3 = pt(p, hu*0.35, hs)
      b:stroke({{x0,y0},{x1,y1},{x2,y2},{x3,y3}}, {pressure={pr*0.7, pr*0.5}, swell={0.6,1.3,1.2,0.5}, ramps={0.2,0.3}, clip=HULLC})
    end
  end
end
function plate_glints(list, pileF, w, pr)
  local b = brush{kind="round", width=w, point=0.8, stiffness=0.4}
  local cur, n = nil, 0
  for _, p in ipairs(list) do
    local pl = pileF(p)
    if pl then
      if pl ~= cur or n >= 6 then b:reload(pl, 0.8) cur = pl n = 0 end
      n = n + 1
      local hu, hs = p.su*0.5, 10.5
      local x0, y0 = pt(p, -hu*0.2, hs*0.85)
      local x1, y1 = pt(p, hu*0.45, hs*0.9)
      local x2, y2 = pt(p, hu*0.85, hs*0.35)
      b:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={pr*0.5, pr*0.2}, ramps={0.15,0.5}, clip=HULLC})
    end
  end
end
plate_shadows(PLATES, function(p) if p.k <= 3 then return R[1] elseif p.k <= 6 then return R[2] else return R[3] end end, 2.6, 0.8)

--@ chunk 9
GLW = pile{{"lead white",3},{"lemon chrome",0.6},{"zinc white",1}}
plate_glints(PLATES, function(p)
  if p.k >= 7 then return GLW elseif p.k >= 5 then return R[8] elseif p.k >= 3 then return (rand(0,1) < 0.6) and R[6] or nil
  else return (rand(0,1) < 0.3) and R[4] or nil end end, 1.8, 0.85)

--@ chunk 10
print(wait(2*24*60))
G7 = pile{{"Mars yellow",2},{"yellow ochre",1},{"lead white",1},{"cadmium yellow",0.5}}
G6 = pile{{"yellow ochre",2},{"Mars yellow",1},{"burnt sienna",0.6},{"lead white",0.6}}
G5 = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.7}}
VG = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1},{"yellow ochre",0.5},{"raw sienna",0.5}}
local function pbody(p)
  if p.k >= 7 then return (rand(0,1) < 0.5) and G7 or G6
  elseif p.k >= 5 then return (rand(0,1) < 0.5) and G6 or G5
  elseif p.k == 4 then return (rand(0,1) < 0.6) and G5 or R[4] end
  return nil
end
local cur, n, bw = nil, 0, 0
local b
for _, p in ipairs(PLATES) do
  local pl = pbody(p)
  if pl and rand(0,1) < 0.04 and p.k >= 5 then pl = VG end
  if pl then
    local want = math.max(3, 17 * p.f)
    if math.abs(want - bw) > 1.5 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
    if pl ~= cur or n >= 4 then b:reload(pl, 0.75) cur = pl n = 0 end
    n = n + 1
    local x0, y0 = pt(p, -p.su*0.45, 0)
    local x1, y1 = pt(p, p.su*0.4, 0)
    b:stroke({{x0,y0},{x1,y1}}, {pressure={0.85, 0.3}, ramps={0.1, 0.5}, clip=HULLC})
  end
end

--@ chunk 11
print(wait(2*24*60))
local lit = {}
for _, p in ipairs(PLATES) do if p.k >= 4 then lit[#lit+1] = p end end
plate_shadows(lit, function(p) if p.k >= 6 then return R[2] else return R[1] end end, 3.0, 0.85)
plate_glints(lit, function(p) if p.k >= 6 then return GLW elseif rand(0,1) < 0.7 then return R[8] end end, 1.7, 0.85)

--@ chunk 12
WL = pile{{"lead white",2},{"cadmium yellow",1},{"cadmium red",0.1}}
WL2 = pile{{"lead white",3},{"chrome yellow",0.6}}
WDIM = pile{{"cadmium yellow",1},{"Mars orange",1},{"burnt sienna",0.5}}
WINS = {}
local s = 165
while s < 700 do
  local u = -140 + rand(0, 20)
  local lit_run = rand(0,1) < 0.45
  local runn = math.floor(rand(4, 16))
  local sp = 4.2 * rand(0.9, 1.1)
  while u < 780 do
    local d = d_of_s(s)
    local x, y = XY(u, d)
    if x > 0 and x < 1000 and y > 0 and y < H and lightstep(x,y) <= 3 then
      if lit_run and rand(0,1) < 0.8 then WINS[#WINS+1] = {x=x, y=y, f=fsh(s), lit=(rand(0,1)<0.25) and 2 or 1} end
    end
    u = u + sp * rand(0.9, 1.1)
    runn = runn - 1
    if runn <= 0 then u = u + rand(10, 45) runn = math.floor(rand(4, 16)) lit_run = rand(0,1) < 0.4 end
  end
  s = s + 42 * rand(0.85, 1.15)
end
print(#WINS)
local b = brush{kind="round", width=1.3, point=0.3, stiffness=0.5}
for pass = 1, 2 do
  local pl = (pass == 1) and WL or WL2
  b:reload(pl, 0.9)
  local n = 0
  for _, w in ipairs(WINS) do
    if w.lit == pass or (pass == 1) then
      n = n + 1 if n % 10 == 0 then b:load(pl, 0.9) end
      local h = 0.9
      if pass == 1 then
        b:stroke({{w.x - LA[1]*h, w.y - LA[2]*h}, {w.x + LA[1]*h, w.y + LA[2]*h}}, {pressure={0.55,0.55}, ramps={0.05,0.05}})
      else
        b:touch(w.x, w.y, {pressure=0.35})
      end
    end
  end
end

--@ chunk 13
OU = {-LA[1], -LA[2]}   -- up along limb
OV = {-LN[1], -LN[2]}   -- outward into space
OO = {XY(324, 0)}
function lp(u, v) return {OO[1] + u*OU[1] + v*OV[1], OO[2] + u*OU[2] + v*OV[2]} end
function quad(u0, u1, v0, v1) return poly({lp(u0,v0), lp(u1,v0), lp(u1,v1), lp(u0,v1)}) end
GR = {
  pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.4}},
  pile{{"lead white",1},{"bone black",0.8},{"ultramarine blue",0.25},{"raw sienna",0.1}},
  pile{{"lead white",2},{"bone black",0.45},{"ultramarine blue",0.15}},
  pile{{"lead white",3},{"bone black",0.1},{"lemon chrome",0.05}},
}
AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.2}}
function fillq(m, p, w)
  work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m, tool={kind="round", width=w or 1.4}, length={2, 6}, angle=AXA})
end
print(OO[1], OO[2])
-- (u0,u1,v0,v1, face pile)
local MODS = {
  {-26, 26, -1.5, 2.5, 1},      -- truss base plate
  {-17, 13, 2.5, 15, 2},        -- main hab front
  {13, 15, 2.5, 15, 3},         -- hab top face (up-axis)
  {-17, 13, 15, 16.5, 1},       -- hab outer end, edge
  {-34, -13, 9, 33, 2},         -- cargo module front
  {-13, -11.5, 9, 33, 3},       -- cargo top
  {-34, -13, 33, 34.5, 1},      -- cargo outer edge
  {16, 28, 2.5, 11, 2},         -- small box upper
  {28, 29.5, 2.5, 11, 3},
  {3, 4.4, 16.5, 44, 3},        -- radiator panel
  {-24, -18, 2.5, 9, 1},        -- connector tunnel
}
for _, m in ipairs(MODS) do fillq(quad(m[1], m[2], m[3], m[4]), GR[m[5]], 1.2) end

--@ chunk 14
print(wait(24*60)) print(drying(460,300))
GD = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.8},{"raw sienna",0.1}}
GDD = pile{{"bone black",2},{"ultramarine blue",0.6},{"lead white",0.35}}
fillq(quad(-17, 13, 2.5, 15), GD, 1.2)
fillq(quad(16, 28, 2.5, 11), GD, 1.2)
fillq(quad(-34, -13, 9, 33), GD, 1.2)
fillq(quad(-24, -18, 2.5, 9), GDD, 1.0)
fillq(quad(-26, 26, -1.5, 2.5), GDD, 1.0)

--@ chunk 15
local p = lp(-24, 20) IMP = p print(p[1], p[2]) print(wait(2*24*60)) print(drying(460,300), drying(300,300))

--@ chunk 16
FP = {
 pile{{"lead white",3},{"zinc white",3},{"lemon chrome",0.3}},
 pile{{"lead white",2},{"cadmium yellow",1}},
 pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",1}},
 pile{{"Mars orange",2},{"cadmium red",0.3},{"lead white",0.5}},
 pile{{"burnt sienna",1},{"Mars orange",1},{"bone black",0.6},{"lead white",0.2}},
 pile{{"ultramarine blue",1},{"bone black",1},{"Mars orange",0.5},{"burnt sienna",0.3},{"lead white",0.2}},
}
FR = {7, 15, 27, 44, 68, 105}
OUTP = quad(-26, 26, -1.5, 2.5) + quad(-17, 15, 2.5, 16.5) + quad(16, 29.5, 2.5, 11) + quad(3, 4.4, 16.5, 44) + quad(-24, -18, 2.5, 9)
CARGO = quad(-34, -11.5, 9, 34.5)
local HALO = (ellipse(IMP[1], IMP[2], 108, 108) - M_hull() - OUTP:grow(0.6)) + ellipse(IMP[1], IMP[2], 9, 9)
local by = {} for i = 1, 6 do by[i] = {} end
for i = 1, 3600 do
  local r = 108 * math.sqrt(rand(0,1))
  local a = rand(0, 2*math.pi)
  local x, y = IMP[1] + r*math.cos(a), IMP[2] + r*math.sin(a)
  if HALO:at(x, y) > 0.5 then
    local rr = r * rand(0.82, 1.18)
    local k = 6
    for j = 1, 6 do if rr < FR[j] then k = j break end end
    local keep = 1
    if k == 6 then keep = 1 - smoothstep(60, 108, r) * 0.7 end
    if rand(0,1) < keep then table.insert(by[k], {x=x, y=y, a=a, r=r}) end
  end
end
local order = {6,5,4,3,2,1}
for _, k in ipairs(order) do
  local b = brush{kind="filbert", width=(k <= 2) and 2.2 or 3.2, stiffness=0.5}
  local n = 0
  for _, s in ipairs(by[k]) do
    if n % 8 == 0 then b:reload(FP[k], (k == 6) and 0.5 or 0.75) end
    n = n + 1
    local L = rand(5, 12) * ((k <= 2) and 0.6 or 1)
    local c, sn = math.cos(s.a), math.sin(s.a)
    b:stroke({{s.x - c*L*0.4, s.y - sn*L*0.4}, {s.x + c*L*0.6, s.y + sn*L*0.6}}, {pressure={0.7, 0.2}, ramps={0.1, 0.5}, clip=HALO})
  end
  print(k, #by[k])
end

--@ chunk 17
local SP = -M_hull() - OUTP:grow(0.6)
local ring = (ellipse(IMP[1], IMP[2], 118, 118) - ellipse(IMP[1], IMP[2], 52, 52)) * SP
for i = 1, 3 do
  work(ring, {hand="scumble", blender=true, coverage=2, clip=true, angle=function(x,y) return math.atan(y-IMP[2], x-IMP[1]) end, seed=100+i})
end

--@ chunk 18
local SP = -M_hull() - OUTP:grow(0.6)
local ring = (ellipse(IMP[1], IMP[2], 66, 66) - ellipse(IMP[1], IMP[2], 16, 16)) * SP
for i = 1, 2 do
  work(ring, {hand="scumble", blender=true, coverage=2, clip=true, angle=function(x,y) return math.atan(y-IMP[2], x-IMP[1]) end, seed=200+i})
end

--@ chunk 19
print(wait(2*24*60)) print(drying(450,314), drying(400,300))

--@ chunk 20
local SPACE = -M_hull():grow(1)
local base = math.atan(OV[2], OV[1])
local hot = {FP[1], FP[2], FP[3], FP[4]}
local RED = pile{{"cadmium red",1},{"Mars orange",1},{"burnt sienna",0.5}}
STREAKS = {}
local rig = brush{kind="rigger", width=1.8, point=1, stiffness=0.4}
for i = 1, 46 do
  local a = base + randn(0, 0.62)
  if rand(0,1) < 0.15 then a = base + (rand(0,1) < 0.5 and -1 or 1) * rand(1.05, 1.35) end
  local r0 = rand(8, 22)
  local r1 = r0 + 40 + 380 * rand(0,1)^1.7
  local c, s = math.cos(a), math.sin(a)
  STREAKS[#STREAKS+1] = {a=a, r0=r0, r1=r1}
  local nseg = 3
  local pr = rand(0.25, 0.55)
  for j = 1, nseg do
    local f0, f1 = (j-1)/nseg, j/nseg
    local ra, rb = r0 + (r1-r0)*f0, r0 + (r1-r0)*f1
    local pl = hot[math.min(4, j + ((r1 > 250) and 0 or 1))]
    if j == 3 and r1 > 300 then pl = RED end
    rig:reload(pl, 0.85)
    if rand(0,1) < 0.85 then
      rig:stroke({{IMP[1] + c*ra, IMP[2] + s*ra}, {IMP[1] + c*rb, IMP[2] + s*rb}}, {pressure={pr*(0.7+0.3*f0), pr*(0.7+0.3*f1)}, ramps={0.05,0.05}, clip=SPACE})
    end
  end
  if rand(0,1) < 0.6 then
    rig:reload(FP[2], 0.9)
    rig:touch(IMP[1] + c*r1, IMP[2] + s*r1, {pressure=pr + 0.25, clip=SPACE})
  end
end

--@ chunk 21
print(wait(24*60))
local SPACE = -M_hull():grow(1)
-- torn panels flung out along some streaks: small gray quads, tumbling, a hot lit edge facing the flash
local PG = {GD, GR[2], GDD}
local HOTE = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}}
local edge = brush{kind="round", width=1.0, point=0.6, stiffness=0.5}
local cnt = 0
for i, st in ipairs(STREAKS) do
  if i % 2 == 0 or st.r1 > 200 then
    local r = st.r0 + (st.r1 - st.r0) * rand(0.35, 0.95)
    local c, s = math.cos(st.a), math.sin(st.a)
    local px, py = IMP[1] + c*r - s*rand(-4,4), IMP[2] + s*r + c*rand(-4,4)
    local sz = rand(2.2, 7) * (1 - r/700)
    local th = rand(0, math.pi)
    local pts = {}
    for k = 0, 3 do
      local ang = th + k*math.pi/2 + rand(-0.35, 0.35)
      local rr = sz * rand(0.6, 1.1) * ((k % 2 == 0) and 1 or rand(0.35, 0.7))
      pts[#pts+1] = {px + rr*math.cos(ang), py + rr*math.sin(ang)}
    end
    local m = poly(pts) * SPACE
    work(m, {hand="detail", pile=PG[(i % 3) + 1], coverage=3, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 4}})
    -- lit edge: the side facing back toward the impact
    local best, bi = 1e9, 1
    for k = 1, 4 do local dx, dy = pts[k][1]-IMP[1], pts[k][2]-IMP[2] local dd2 = dx*dx+dy*dy if dd2 < best then best, bi = dd2, k end end
    local p1, p2 = pts[bi], pts[(bi % 4) + 1]
    edge:reload(HOTE, 0.8)
    edge:stroke({p1, p2}, {pressure={0.55, 0.45}, ramps={0.05,0.05}})
    cnt = cnt + 1
  end
end
print(cnt)

--@ chunk 22
print(wait(24*60)) print(drying(IMP[1], IMP[2]), drying(IMP[1]-10, IMP[2]+5))
-- torn skin petals around the wound: dark gray tongues peeled outward, hot inner edges
local CL = CARGO:grow(5)
local HOTE = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}}
local edge = brush{kind="round", width=1.1, point=0.7, stiffness=0.5}
local n = 0
local a = rand(0, 1)
while a < 2*math.pi do
  local w = rand(0.3, 0.6)
  local r0, r1 = rand(4.5, 6.5), rand(13, 22)
  local a1, a2 = a, a + w
  local tip = a + w*rand(0.35, 0.65) + rand(-0.15, 0.15)
  local function P(r, ang) return {IMP[1] + r*math.cos(ang), IMP[2] + r*math.sin(ang)} end
  local pts = {P(r0, a1), P(r0*1.6 + rand(0,3), a1 - 0.08), P(r1, tip), P(r0*1.6 + rand(0,3), a2 + 0.08), P(r0, a2)}
  local m = poly(pts)
  work(m, {hand="detail", pile=(n % 2 == 0) and GD or GDD, coverage=3, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 4}})
  edge:reload(HOTE, 0.8)
  edge:stroke({pts[1], pts[2], pts[3]}, {pressure={0.6, 0.25}, ramps={0.05,0.3}})
  n = n + 1
  a = a + w + rand(0.25, 0.6)
end
print(n)

--@ chunk 23
print(wait(24*60))
local inner = ellipse(IMP[1], IMP[2], 12, 12):roughen(2.5, 6, 7)
stipple(inner, {pile=FP[3], width=2.2, coverage=2.2, cluster=0.3, feather=0.4})
local core = ellipse(IMP[1]-0.5, IMP[2]+0.5, 7.5, 6.5):roughen(1.8, 4, 3)
work(core, {hand="detail", pile=FP[2], coverage=3, fill=true, clip=core, tool={kind="round", width=1.6}, length={2, 5}})
local core2 = ellipse(IMP[1]-0.5, IMP[2]+0.5, 4.5, 4):roughen(1.2, 3, 5)
work(core2, {hand="detail", pile=FP[1], coverage=4, fill=true, clip=core2, tool={kind="round", width=1.4}, length={2, 4}})

--@ chunk 24
print(wait(24*60))
local c2 = ellipse(IMP[1]-0.5, IMP[2]+0.5, 3, 2.6):roughen(0.8, 2, 9)
work(c2, {hand="detail", pile=FP[1], coverage=4, fill=true, clip=c2, tool={kind="round", width=1.2}, length={1.5, 3}})
-- flash spikes: a thin starburst through the core
local rig = brush{kind="rigger", width=1.6, point=1, stiffness=0.4}
local SP4 = {{0.35, 95}, {0.35 + math.pi, 80}, {0.35 + math.pi/2, 55}, {0.35 - math.pi/2, 50}, {1.2, 30}, {1.2 + math.pi, 26}, {-0.6, 28}, {-0.6+math.pi, 24}}
for _, sp in ipairs(SP4) do
  local c, s = math.cos(sp[1]), math.sin(sp[1])
  rig:reload(FP[1], 0.9)
  rig:stroke({{IMP[1] + c*3, IMP[2] + s*3}, {IMP[1] + c*sp[2], IMP[2] + s*sp[2]}}, {pressure={0.75, 0.0}, ramps={0.02, 0.9}})
end
-- outpost: amber hazard marks
local b = brush{kind="round", width=0.8, point=0.3}
b:reload(AMB, 0.9)
for i = 0, 4 do
  local v = 3.5 + i*2.4
  b:stroke({lp(12.0, v), lp(12.0, v+1.1)}, {pressure={0.6,0.6}})
end
for i = 0, 2 do
  local v = 4 + i*2.4
  b:stroke({lp(26.8, v), lp(26.8, v+1.1)}, {pressure={0.55,0.55}})
end
b:stroke({lp(-16, 7), lp(-16, 13.5)}, {pressure={0.5,0.5}})
-- hot rim on faces turned toward the flash (the lower ends of the modules)
local HOTE = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}}
local e = brush{kind="round", width=1.0, point=0.6}
e:reload(HOTE, 0.85)
e:stroke({lp(-16.6, 2.6), lp(-16.6, 15)}, {pressure={0.6, 0.4}, ramps={0.05,0.2}})
e:stroke({lp(15.8, 2.6), lp(15.8, 10.8)}, {pressure={0.4, 0.3}, ramps={0.05,0.2}})
e:reload(HOTE, 0.85)
e:stroke({lp(2.8, 16.5), lp(2.8, 43)}, {pressure={0.45, 0.2}, ramps={0.05,0.3}})
e:stroke({lp(-25.5, -1.4), lp(-25.5, 2.4)}, {pressure={0.4, 0.4}})
-- panel seams on hab front
local s = brush{kind="round", width=0.5, point=0.5}
s:reload(GDD, 0.9)
for _, u in ipairs({-9, -2, 5}) do s:stroke({lp(u, 2.6), lp(u, 14.8)}, {pressure={0.5,0.5}}) end
s:stroke({lp(-16.5, 8.7), lp(12.8, 8.7)}, {pressure={0.45,0.45}})

--@ chunk 25
PA = 2.42
local c, s = math.cos(PA), math.sin(PA)
local function cone(len, half, r0)
  local px, py = -s, c
  local pts = {}
  local ox, oy = IMP[1] + c*r0, IMP[2] + s*r0
  pts[1] = {ox + px*3, oy + py*3}
  pts[2] = {IMP[1] + c*len*0.5 + px*len*0.5*math.tan(half)*1.05, IMP[2] + s*len*0.5 + py*len*0.5*math.tan(half)*1.05}
  pts[3] = {IMP[1] + c*len + px*len*math.tan(half), IMP[2] + s*len + py*len*math.tan(half)}
  pts[4] = {IMP[1] + c*len*1.08, IMP[2] + s*len*1.08}
  pts[5] = {IMP[1] + c*len - px*len*math.tan(half), IMP[2] + s*len - py*len*math.tan(half)}
  pts[6] = {IMP[1] + c*len*0.5 - px*len*0.5*math.tan(half)*1.05, IMP[2] + s*len*0.5 - py*len*0.5*math.tan(half)*1.05}
  pts[7] = {ox - px*3, oy - py*3}
  return poly(pts, true)
end
PLUME = (cone(270, 0.24, 8):roughen(6, 30, 21) - M_hull())
VEIL = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4}, medium=0.5}
work(PLUME, {hand="scumble", pile=VEIL, load=0.25, pressure={0.1, 0.25}, coverage=1.2, angle=PA, angle_jitter=0.2, clip=true, seed=31})
blend(PLUME:shrink(2), {angle=PA, tool={kind="badger", width=12}})
print(PLUME:area())

--@ chunk 26
local m = PLUME:grow(4) - M_hull()
for i = 1, 4 do
  work(m, {hand="scumble", blender=true, coverage=2, clip=true, angle=PA + (i%2)*1.2, seed=300+i})
end

--@ chunk 27
local far = (PLUME:grow(6) - M_hull()) * mask(function(x,y) local dx, dy = x-IMP[1], y-IMP[2] return smoothstep(130, 230, math.sqrt(dx*dx+dy*dy)) end)
for i = 1, 3 do
  work(far, {hand="scumble", blender=true, coverage=2, clip=true, threshold=0.2, angle=PA + (i%2)*1.3, seed=400+i})
end

--@ chunk 28
print(wait(3*24*60)) print(drying(250,480), drying(330,400))
local c, s = math.cos(PA), math.sin(PA)
local px, py = -s, c
local function P(r, w) return {IMP[1] + c*r + px*w, IMP[2] + s*r + py*w} end
NEWP = poly({P(6, -3), P(80, -16), P(170, -30), P(250, -40), P(290, -30), P(300, 0), P(285, 34), P(240, 44), P(170, 34), P(80, 18), P(6, 3)}, true):roughen(4, 25, 41)
local carve = (PLUME:grow(10) - NEWP) - M_hull()
work(carve, {hand="body", pile=K1, coverage=3, fill=true, angle=0.1, angle_jitter=0.3, edge="soft", clip=-M_hull()})

--@ chunk 29
local z = (ellipse(IMP[1], IMP[2], 135, 135) - M_hull():grow(0)) - OUTP
for i = 1, 4 do
  work(z, {hand="scumble", blender=true, coverage=2.2, clip=true, angle=PA + (i%2)*1.4, seed=500+i})
end

--@ chunk 30
print(wait(2*24*60))
local GL1 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.3}}
local GL2 = pile{{"zinc white",2},{"cerulean blue",0.6},{"ultramarine ash",0.4}}
local SPC = -M_hull() - OUTP
local cone = (NEWP + (PLUME:shrink(8))) * SPC
local dens = function(x, y)
  local dx, dy = x - IMP[1], y - IMP[2]
  local r = math.sqrt(dx*dx + dy*dy)
  return 0.9 * math.exp(-r / 70) + 0.08
end
stipple(cone, {pile=GL2, width=1.4, coverage=dens, cluster={0.5, 6}, feather=0.6, pressure={0.2, 0.55}, seed=61})
stipple(cone, {pile=GL1, width=1.0, coverage=function(x,y) return 0.6*dens(x,y) end, cluster={0.6, 4}, feather=0.6, pressure={0.25, 0.6}, seed=62})

--@ chunk 31
local SPC = -M_hull():grow(1)
-- the CUCULUS trail, fading back along its path
local TR = pile{{"lead white",2},{"ultramarine ash",1},{"cerulean blue",0.2}}
local rig = brush{kind="rigger", width=1.4, point=1, stiffness=0.4}
local sx, sy = -5, 118
local segs = 5
for j = 1, segs do
  local f0, f1 = (j-1)/segs, j/segs
  rig:reload(TR, 0.4 + 0.1*j)
  local ex, ey = IMP[1] - 9*(IMP[1]-sx)/math.sqrt((IMP[1]-sx)^2+(IMP[2]-sy)^2), IMP[2] - 9*(IMP[2]-sy)/math.sqrt((IMP[1]-sx)^2+(IMP[2]-sy)^2)
  rig:stroke({{sx + (ex-sx)*f0, sy + (ey-sy)*f0}, {sx + (ex-sx)*f1, sy + (ey-sy)*f1}}, {pressure={0.1 + 0.05*j, 0.12 + 0.05*j}, ramps={0.02,0.02}, clip=SPC})
end
-- warm flash spill on the hull plates nearest the wound
local SPILL = {pile{{"lead white",1},{"cadmium yellow",1},{"Mars orange",1}}, pile{{"Mars orange",2},{"cadmium red",0.3},{"lead white",0.3}}, pile{{"burnt sienna",1},{"Mars orange",1}}}
local b = brush{kind="round", width=1.6, point=0.7, stiffness=0.4}
local n = 0
for _, p in ipairs(PLATES) do
  local dx, dy = p.x - IMP[1], p.y - IMP[2]
  local r = math.sqrt(dx*dx + dy*dy)
  if r < 150 and dd(p.x, p.y) > 2 then
    local k = (r < 50) and 1 or ((r < 100) and 2 or 3)
    if rand(0,1) < 1 - r/170 then
      if n % 5 == 0 then b:reload(SPILL[k], 0.8) end
      n = n + 1
      local hu, hs = p.su*0.5, 10.5
      local x0, y0 = pt(p, -hu*0.4, -hs*0.85)
      local x1, y1 = pt(p, hu*0.3, -hs*0.95)
      local x2, y2 = pt(p, hu*0.85, -hs*0.4)
      local pr = 0.75 * (1 - r/190)
      b:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={pr, pr*0.3}, ramps={0.1,0.5}, clip=HULLC})
    end
  end
end
print(n)
-- sparse stars, kept away from the flash and the plume
local ST = pile{{"zinc white",3},{"lead white",1}}
local STB = pile{{"zinc white",3},{"cerulean blue",0.2}}
local sb = brush{kind="round", width=1.2, point=0.5}
sb:reload(ST, 0.8)
local placed = 0
for i = 1, 220 do
  local x, y = rand(0, 600), rand(0, H)
  local dx, dy = x - IMP[1], y - IMP[2]
  if dd(x, y) < -6 and dx*dx + dy*dy > 170*170 and PLUME:grow(20):at(x, y) < 0.1 then
    placed = placed + 1
    if placed % 12 == 0 then sb:reload((placed % 24 == 0) and STB or ST, 0.8) end
    local big = rand(0,1) < 0.08
    sb:touch(x, y, {pressure=big and 0.6 or rand(0.12, 0.3)})
    if placed > 70 then break end
  end
end
print(placed)

--@ chunk 32
print(wait(24*60))
local SPC = -M_hull():grow(1)
-- a few big torn panels, bent, near the wound
local PG = {GD, GDD, GR[2]}
local HOTE = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}}
local e = brush{kind="round", width=1.1, point=0.6, stiffness=0.5}
local spots = {{2.9, 48, 11, 0.4}, {3.55, 70, 9, 1.3}, {2.05, 95, 8, 2.2}, {3.3, 130, 7, 0.9}}
for i, sp in ipairs(spots) do
  local cx, cy = IMP[1] + sp[2]*math.cos(sp[1]), IMP[2] + sp[2]*math.sin(sp[1])
  local sz, th = sp[3], sp[4]
  local pts = {}
  local angs = {0, 0.9, 1.7, 3.1, 4.0, 5.0}
  for k, a in ipairs(angs) do
    local rr = sz * ((k % 2 == 0) and rand(0.45, 0.7) or rand(0.8, 1.1))
    pts[#pts+1] = {cx + rr*math.cos(th + a), cy + rr*0.55*math.sin(th + a)}
  end
  local m = poly(pts) * SPC
  work(m, {hand="detail", pile=PG[(i % 3) + 1], coverage=3, fill=true, clip=m, tool={kind="round", width=1.0}, length={1.5, 4}})
  -- bend line across the panel, and the hot edge facing the flash
  local s = brush{kind="round", width=0.6, point=0.5}
  s:reload(GDD, 0.9)
  s:stroke({pts[2], pts[5]}, {pressure={0.5,0.5}})
  local best, bi = 1e9, 1
  for k = 1, #pts do local dx, dy = pts[k][1]-IMP[1], pts[k][2]-IMP[2] if dx*dx+dy*dy < best then best, bi = dx*dx+dy*dy, k end end
  e:reload(HOTE, 0.8)
  local pa, pb = pts[(bi - 2) % #pts + 1], pts[bi % #pts + 1]
  e:stroke({pa, pts[bi], pb}, {pressure={0.4, 0.5}, ramps={0.1,0.1}})
end
-- hotter core zone: short fine radial strokes of white-gold
local hz = ellipse(IMP[1], IMP[2], 15, 15) - OUTP
local b = brush{kind="round", width=1.2, point=0.8}
for i = 1, 70 do
  if i % 8 == 1 then b:reload((i % 16 == 1) and FP[1] or FP[2], 0.8) end
  local a = rand(0, 2*math.pi)
  local r0 = rand(2, 6)
  local r1 = r0 + rand(5, 12)
  local c, s = math.cos(a), math.sin(a)
  b:stroke({{IMP[1] + c*r0, IMP[2] + s*r0}, {IMP[1] + c*r1, IMP[2] + s*r1}}, {pressure={0.6, 0.05}, ramps={0.05, 0.7}, clip=hz})
end

--@ chunk 33
GREENS = {{995.7,18.4},{957.7,21.4},{913.3,95.8},{949.9,128.3},{953.9,121.3},{922.9,152.9},{870.4,238.3},{958.0,271.6},{880.4,347.8},{783.2,371.3},{839.0,402.9},{940.6,403.9},{737.8,442.8},{929.7,477.7},{970.4,477.1},{737.4,525.0},{771.6,560.4}}
-- worn verdigris: dry-brush bronze back over the green plates so the patina shows only in breaks
local b = brush{kind="filbert", width=9, stiffness=0.6}
for i, g in ipairs(GREENS) do
  b:reload((i % 2 == 0) and G6 or G5, 0.3)
  local x, y = g[1], g[2]
  b:stroke({{x - LA[1]*7 - 1, y - LA[2]*7}, {x + LA[1]*5, y + LA[2]*5}}, {pressure={0.35, 0.15}, ramps={0.1,0.5}, clip=HULLC})
end
-- plate lips in silhouette along the limb
local L = brush{kind="round", width=2.6, point=0.4, stiffness=0.5}
local n = 0
local u = -10
while u < 640 do
  if n % 6 == 0 then L:reload(R[1], 0.8) end
  n = n + 1
  local x0, y0 = XY(u, 0.5)
  local x1, y1 = XY(u + 6, -1.6 * rand(0.6, 1.2))
  local x2, y2 = XY(u + 12, 0.3)
  L:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={0.55, 0.4}, ramps={0.1,0.3}})
  u = u + 19 * rand(0.85, 1.15)
end
-- missing plates in the sunlit field: dark sockets with a lit lower lip
local sock = brush{kind="filbert", width=12, stiffness=0.55}
local lip = brush{kind="round", width=1.6, point=0.7}
local cnt = 0
for _, p in ipairs(PLATES) do
  if p.k >= 5 and rand(0,1) < 0.018 then
    cnt = cnt + 1
    sock:reload(R[2], 0.8)
    local x0, y0 = pt(p, -p.su*0.35, 0)
    local x1, y1 = pt(p, p.su*0.3, 0)
    sock:stroke({{x0,y0},{x1,y1}}, {pressure={0.8, 0.5}, ramps={0.1,0.3}, clip=HULLC})
    lip:reload(GLW, 0.8)
    local a0, b0 = pt(p, p.su*0.5, -6)
    local a1, b1 = pt(p, p.su*0.62, 0)
    local a2, b2 = pt(p, p.su*0.5, 6)
    lip:stroke({{a0,b0},{a1,b1},{a2,b2}}, {pressure={0.5, 0.3}, ramps={0.1,0.3}, clip=HULLC})
  end
end
print(cnt)

--@ chunk 34
local ST = pile{{"zinc white",3},{"lead white",1}}
local STW = pile{{"lead white",2},{"cadmium yellow",0.3},{"zinc white",1}}
local STB = pile{{"zinc white",3},{"cerulean blue",0.3}}
local sb = brush{kind="round", width=1.3, point=0.5}
local pl = {ST, STW, STB}
local placed = 0
for i = 1, 600 do
  local x, y = rand(0, 600), rand(0, H)
  local dx, dy = x - IMP[1], y - IMP[2]
  if dd(x, y) < -8 and dx*dx + dy*dy > 190*190 and PLUME:grow(25):at(x, y) < 0.1 then
    placed = placed + 1
    if placed % 10 == 1 then sb:reload(pl[(placed // 10) % 3 + 1], 0.85) end
    local big = rand(0,1) < 0.06
    sb:touch(x, y, {pressure=big and 0.75 or rand(0.3, 0.5)})
    if placed >= 110 then break end
  end
end
print(placed)

--@ chunk 35
local AMB2 = pile{{"cadmium yellow",1.2},{"Mars orange",0.8},{"lead white",0.4}}
local b = brush{kind="flat", width=1.6, stiffness=0.6}
b:reload(AMB2, 0.9)
local v = 3.0
while v < 14.2 do
  b:stroke({lp(10.2, v), lp(11.8, v + 0.9)}, {pressure={0.7,0.7}, ramps={0.05,0.05}, orient="across"})
  v = v + 2.2
end
b:reload(AMB2, 0.9)
v = 3.2
while v < 10.5 do
  b:stroke({lp(25.0, v), lp(26.6, v + 0.9)}, {pressure={0.65,0.65}, ramps={0.05,0.05}, orient="across"})
  v = v + 2.2
end
-- amber stripe along the base plate
local r = brush{kind="round", width=1.0, point=0.3}
r:reload(AMB2, 0.9)
r:stroke({lp(6, 0.6), lp(24, 0.6)}, {pressure={0.6,0.6}, ramps={0.05,0.05}})

--@ chunk 36
print(wait(3*24*60))

--@ chunk 37
print(wait(24*60))

--@ chunk 38
KC = 0.10
function XYc(u, s) return XY(u + KC*RC*math.sin(s/RC), d_of_s(s)) end
TN = noise{seed=77, period=160, octaves=3}
WN = noise{seed=78, period=90, octaves=3}
SZN = noise{seed=79, period=260, octaves=2}
function term_d(x, y) return 228 + 22*TN(x, y) end
GP = pile{{"Mars yellow",2},{"lead white",1.2},{"cadmium yellow",0.6}}
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
PHI = (math.sqrt(5) - 1) / 2
PL2 = {}
local row = 0
local s = 4
while s < 1200 do
  row = row + 1
  local xm, ym = XYc(300, s)
  local sf = 1 + 0.18*SZN(xm, ym)
  local step_u = 19 * sf
  local off = ((row * PHI) % 1) * step_u
  local ds = 21 * sf * rand(0.92, 1.08)
  for u = -200 + off, 820, step_u do
    local q = rand(0.88, 1.12)
    local uj = u + rand(-1.2, 1.2)
    local sj = s + rand(-1.2, 1.2)
    local x, y = XYc(uj, sj)
    if x > -25 and x < 1025 and y > -25 and y < H + 25 and dd(x, y) > -2 then
      local d = dd(x, y)
      local T = term_d(x, y)
      local lt = smoothstep(T - 28, T + 28, d + rand(-14, 14))
      PL2[#PL2+1] = {u=uj, s=sj, x=x, y=y, d=d, f=fsh(sj), su=step_u*q, ss=ds*q, tilt=randn(0, 0.09), lt=lt,
                     lit=lt * (0.72 + 0.28*smoothstep(T, T + 260, d)), wear=WN(x, y), r=rand(0,1)}
    end
  end
  s = s + ds
end
table.sort(PL2, function(a, b) return a.u > b.u end)
print(#PL2)
-- local frame of a plate: along axis a, across b (true units), with tilt
function pt2(p, a, b)
  local ca, sa = math.cos(p.tilt), math.sin(p.tilt)
  local a2, b2 = a*ca - b*sa, a*sa + b*ca
  return XYc(p.u + a2, p.s + b2)
end
function plate_pile(p)
  if p.r < 0.012 then return R[1], "missing" end
  if p.lt < 0.5 then
    local v = p.r + 0.25*p.wear
    if v < 0.55 then return R[1] elseif v < 0.93 then return R[2] else return R[3] end
  end
  if p.r > 0.985 then return (p.wear > 0) and BONE or G7, "recut" end
  local v = p.lit + 0.22*p.wear + rand(-0.18, 0.18)
  if v < 0.45 then return R[4] elseif v < 0.62 then return G5 elseif v < 0.8 then return G6 elseif v < 0.95 then return G7 else return GP end
end
PCLIP = HULLC - OUTP:grow(1)
local cur, n, bw, b = nil, 0, 0, nil
for _, p in ipairs(PL2) do
  local pl, tag = plate_pile(p)
  p.tag = tag
  local want = math.max(2.5, p.ss * 1.0 * math.max(p.f, 0.12))
  if tag == "missing" then want = want * 0.8 end
  if math.abs(want - bw) > 1.2 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
  if pl ~= cur or n >= 4 then b:reload(pl, 0.8) cur = pl n = 0 end
  n = n + 1
  local x0, y0 = pt2(p, -p.su*0.62, 0)
  local x1, y1 = pt2(p, p.su*0.42, 0)
  b:stroke({{x0,y0},{x1,y1}}, {pressure={0.9, 0.55}, ramps={0.08, 0.35}, clip=PCLIP})
end

--@ chunk 39
print(wait(2*24*60))
local sb = brush{kind="round", width=2.6, point=0.6, stiffness=0.45}
local gb = brush{kind="round", width=1.7, point=0.8, stiffness=0.4}
local cur, n = nil, 0
-- shadows: crescent at the free (+u) end, heavier on the side away from the sun, longer near the terminator
for _, p in ipairs(PL2) do
  if p.lt >= 0.5 or (p.d > term_d(p.x,p.y) - 90 and p.r < 0.5) then
    local pl = (p.lt >= 0.5) and R[1] or R[1]
    if n % 6 == 0 then sb:reload(pl, 0.8) end
    n = n + 1
    local hu, hs = p.su*0.5, p.ss*0.5
    local long = 1 + 0.9*(1 - smoothstep(0.5, 1, p.lit))
    local x0, y0 = pt2(p, hu*0.3, -hs*1.05)
    local x1, y1 = pt2(p, hu*(0.95 + 0.25*long), -hs*0.45)
    local x2, y2 = pt2(p, hu*1.0, hs*0.35)
    local x3, y3 = pt2(p, hu*0.45, hs*0.95)
    local pr = 0.75 * math.min(1.3, long) * (0.85 + 0.3*rand(0,1))
    sb:stroke({{x0,y0},{x1,y1},{x2,y2},{x3,y3}}, {pressure={pr*0.9, pr*0.35}, swell={1.2,1.3,0.9,0.4}, ramps={0.15,0.35}, clip=PCLIP})
  end
end
-- glints on the sun-side rim; past the terminator only the raised lips catch it, fading into the dark
n = 0
for _, p in ipairs(PL2) do
  local T = term_d(p.x, p.y)
  local pl, pr = nil, 0
  if p.tag == "missing" then
  elseif p.lt >= 0.5 then
    local v = p.lit + 0.2*p.wear + rand(-0.2, 0.2)
    if v > 0.75 then pl, pr = GLW, 0.85 elseif v > 0.5 then pl, pr = R[8], 0.75 elseif rand(0,1) < 0.6 then pl, pr = G7, 0.6 end
  elseif p.d > T - 70 then
    local fall = smoothstep(T - 70, T - 25, p.d)
    if rand(0,1) < 0.75*fall then pl, pr = (fall > 0.6) and R[8] or G6, 0.5 + 0.3*fall end
  elseif rand(0,1) < 0.12 then pl, pr = R[4], 0.45
  end
  if pl then
    if pl ~= cur or n >= 6 then gb:reload(pl, 0.8) cur = pl n = 0 end
    n = n + 1
    local hu, hs = p.su*0.5, p.ss*0.5
    local a0 = rand(-0.4, 0.0)
    local x0, y0 = pt2(p, hu*a0, hs*0.88)
    local x1, y1 = pt2(p, hu*0.5, hs*0.92)
    local x2, y2 = pt2(p, hu*0.9, hs*0.3)
    gb:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={pr*0.55, pr*0.15}, ramps={0.1,0.55}, clip=PCLIP})
  end
end

--@ chunk 40
print(wait(24*60))
HI = pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.5}}
DK = pile{{"burnt sienna",1.5},{"raw sienna",1},{"bone black",0.4}}
local cur, n, bw, b = nil, 0, 0, nil
for _, p in ipairs(PL2) do
  if p.lt >= 0.5 and p.tag == nil then
    local v = p.lit + 0.25*p.wear + rand(-0.2, 0.2)
    local pl, side, pr
    if v > 0.7 then pl, side, pr = HI, 1, 0.6
    elseif v < 0.5 and rand(0,1) < 0.7 then pl, side, pr = DK, -1, 0.7
    elseif rand(0,1) < 0.35 then pl, side, pr = (rand(0,1) < 0.5) and HI or DK, (rand(0,1) < 0.5) and 1 or -1, 0.5 end
    if pl then
      local want = math.max(1.6, p.ss * 0.38 * math.max(p.f, 0.12))
      if math.abs(want - bw) > 0.8 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
      if pl ~= cur or n >= 5 then b:reload(pl, 0.6) cur = pl n = 0 end
      n = n + 1
      local x0, y0 = pt2(p, -p.su*0.5, side*p.ss*0.28)
      local x1, y1 = pt2(p, p.su*0.15, side*p.ss*0.3)
      b:stroke({{x0,y0},{x1,y1}}, {pressure={0.7, 0.2}, ramps={0.1, 0.6}, clip=PCLIP})
    end
  end
end

--@ chunk 41
print(wait(24*60))
TAR = pile{{"raw sienna",2},{"bone black",0.6},{"yellow ochre",1},{"burnt sienna",0.5}}
TAR2 = pile{{"burnt sienna",1},{"bone black",0.5},{"raw sienna",1}}
local cur, n, bw, b = nil, 0, 0, nil
local vb = brush{kind="round", width=2.2, point=0.5, stiffness=0.4}
for _, p in ipairs(PL2) do
  if p.lt >= 0.5 and p.tag == nil then
    local tz = -p.wear + rand(-0.25, 0.25)
    if tz > 0.22 then
      local pl = (tz > 0.45) and TAR2 or TAR
      local want = math.max(2, p.ss * 0.7 * math.max(p.f, 0.12))
      if math.abs(want - bw) > 1 then b = brush{kind="filbert", width=want, stiffness=0.6} bw = want cur = nil end
      if pl ~= cur or n >= 4 then b:reload(pl, 0.4) cur = pl n = 0 end
      n = n + 1
      local x0, y0 = pt2(p, -p.su*0.45, -p.ss*0.1)
      local x1, y1 = pt2(p, p.su*0.3, -p.ss*0.05)
      b:stroke({{x0,y0},{x1,y1}}, {pressure={0.45, 0.2}, ramps={0.1, 0.5}, clip=PCLIP})
    end
    if rand(0,1) < 0.05 then
      vb:reload(VG, 0.45)
      local x0, y0 = pt2(p, p.su*0.55, -p.ss*0.5)
      local x1, y1 = pt2(p, p.su*0.75, 0)
      vb:stroke({{x0,y0},{x1,y1}}, {pressure={0.45, 0.2}, ramps={0.1,0.5}, clip=PCLIP})
    end
  end
end

--@ chunk 42
print(wait(2*24*60))
local gb = brush{kind="round", width=1.6, point=0.8, stiffness=0.4}
local n, cur = 0, nil
for _, p in ipairs(PL2) do
  if p.lt >= 0.5 and p.tag ~= "missing" then
    local v = p.lit + 0.25*p.wear + rand(-0.25, 0.25)
    if v > 0.45 then
      local pl = (v > 0.7) and GLW or R[8]
      if pl ~= cur or n >= 6 then gb:reload(pl, 0.85) cur = pl n = 0 end
      n = n + 1
      local hu, hs = p.su*0.5, p.ss*0.5
      local x0, y0 = pt2(p, -hu*0.1, hs*0.9)
      local x1, y1 = pt2(p, hu*0.55, hs*0.88)
      local x2, y2 = pt2(p, hu*0.92, hs*0.25)
      gb:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={0.6, 0.12}, ramps={0.1,0.6}, clip=PCLIP})
    end
  end
end
-- flash spill on the plate lips nearest the wound (facing the limb)
local SPILL = {pile{{"lead white",1},{"cadmium yellow",1},{"Mars orange",1}}, pile{{"Mars orange",2},{"cadmium red",0.3},{"lead white",0.3}}, pile{{"burnt sienna",1},{"Mars orange",1}}}
local b = brush{kind="round", width=1.6, point=0.7, stiffness=0.4}
n = 0
for _, p in ipairs(PL2) do
  local dx, dy = p.x - IMP[1], p.y - IMP[2]
  local r = math.sqrt(dx*dx + dy*dy)
  if r < 150 and p.d > 2 and rand(0,1) < 1 - r/170 then
    local k = (r < 50) and 1 or ((r < 100) and 2 or 3)
    if n % 5 == 0 then b:reload(SPILL[k], 0.8) end
    n = n + 1
    local hu, hs = p.su*0.5, p.ss*0.5
    local x0, y0 = pt2(p, -hu*0.4, -hs*0.85)
    local x1, y1 = pt2(p, hu*0.3, -hs*0.95)
    local x2, y2 = pt2(p, hu*0.85, -hs*0.4)
    local pr = 0.75 * (1 - r/190)
    b:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={pr, pr*0.3}, ramps={0.1,0.5}, clip=PCLIP})
  end
end
print(n)

--@ chunk 43
print(wait(24*60))
local cur, n, bw, b = nil, 0, 0, nil
for _, p in ipairs(PL2) do
  local T = term_d(p.x, p.y)
  if p.lt < 0.5 and p.d < T - 45 then
    local pl = (rand(0,1) < 0.85) and R[1] or R[2]
    local want = math.max(2.5, p.ss * math.max(p.f, 0.12))
    if math.abs(want - bw) > 1.2 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
    if pl ~= cur or n >= 4 then b:reload(pl, 0.8) cur = pl n = 0 end
    n = n + 1
    local x0, y0 = pt2(p, -p.su*0.62, 0)
    local x1, y1 = pt2(p, p.su*0.42, 0)
    b:stroke({{x0,y0},{x1,y1}}, {pressure={0.9, 0.55}, ramps={0.08, 0.35}, clip=PCLIP})
  end
end
print(n)

--@ chunk 44
print(wait(12*60))
local W1 = {}
local u = -150 + rand(0, 10)
while u < 800 do
  local s = rand(30, 90)
  local runn = math.floor(rand(4, 14))
  local lit_run = rand(0,1) < 0.45
  local sp = 6.5 * rand(0.9, 1.1)
  while s < 900 do
    local x, y = XYc(u, s)
    local d = dd(x, y)
    if x > 0 and x < 1000 and y > 0 and y < H and d > 3 and d < term_d(x, y) - 40 then
      local dx, dy = x - IMP[1], y - IMP[2]
      if lit_run and rand(0,1) < 0.82 and dx*dx + dy*dy > 30*30 then
        local xa, ya = XYc(u, s - 1.4)
        local xb, yb = XYc(u, s + 1.4)
        W1[#W1+1] = {xa, ya, xb, yb, x, y, rand(0,1) < 0.18}
      end
    end
    s = s + sp * rand(0.92, 1.08)
    runn = runn - 1
    if runn <= 0 then s = s + rand(14, 60) runn = math.floor(rand(4, 14)) lit_run = rand(0,1) < 0.4 end
  end
  u = u + 24 * rand(0.9, 1.1)
end
print(#W1)
local b = brush{kind="round", width=1.25, point=0.3, stiffness=0.5}
b:reload(WL, 0.9)
for i, w in ipairs(W1) do
  if i % 10 == 0 then b:load(WL, 0.9) end
  local len2 = (w[3]-w[1])^2 + (w[4]-w[2])^2
  if len2 < 0.8 then b:touch(w[5], w[6], {pressure=0.5})
  else b:stroke({{w[1], w[2]}, {w[3], w[4]}}, {pressure={0.55,0.55}, ramps={0.05,0.05}}) end
end
b:reload(WL2, 0.9)
local n = 0
for _, w in ipairs(W1) do
  if w[7] then n = n + 1 if n % 10 == 0 then b:load(WL2, 0.9) end b:touch(w[5], w[6], {pressure=0.4}) end
end

--@ chunk 45
-- restate flash spill on the plates nearest the wound
local SPILL = {pile{{"lead white",1},{"cadmium yellow",1},{"Mars orange",1}}, pile{{"Mars orange",2},{"cadmium red",0.3},{"lead white",0.3}}, pile{{"burnt sienna",1},{"Mars orange",1}}}
local b = brush{kind="round", width=1.6, point=0.7, stiffness=0.4}
local n = 0
for _, p in ipairs(PL2) do
  local dx, dy = p.x - IMP[1], p.y - IMP[2]
  local r = math.sqrt(dx*dx + dy*dy)
  if r < 160 and p.d > 2 and rand(0,1) < 1.1 - r/170 then
    local k = (r < 55) and 1 or ((r < 105) and 2 or 3)
    if n % 5 == 0 then b:reload(SPILL[k], 0.8) end
    n = n + 1
    local hu, hs = p.su*0.5, p.ss*0.5
    local x0, y0 = pt2(p, -hu*0.4, -hs*0.85)
    local x1, y1 = pt2(p, hu*0.3, -hs*0.95)
    local x2, y2 = pt2(p, hu*0.85, -hs*0.4)
    local pr = 0.8 * (1 - r/200)
    b:stroke({{x0,y0},{x1,y1},{x2,y2}}, {pressure={pr, pr*0.3}, ramps={0.1,0.5}, clip=PCLIP})
  end
end
print(n)
-- break the plume's far end into wisps with dry navy strokes
local far = (PLUME:grow(8) - M_hull()) * mask(function(x,y) local dx, dy = x-IMP[1], y-IMP[2] return smoothstep(150, 240, math.sqrt(dx*dx+dy*dy)) end)
work(far, {hand="scumble", pile=K1, load=0.4, coverage=1.6, angle=PA, angle_jitter=0.25, threshold=0.25, clip=-M_hull(), seed=71})

--@ chunk 46
local far = (PLUME:grow(14) - M_hull()) * mask(function(x,y) local dx, dy = x-IMP[1], y-IMP[2] return smoothstep(140, 200, math.sqrt(dx*dx+dy*dy)) end)
for i = 1, 2 do
  work(far, {hand="scumble", blender=true, coverage=2, clip=true, threshold=0.2, angle=PA + (i-1)*0.5, seed=80+i})
end

--@ chunk 47
print(wait(2*24*60))
local GL1 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.3}}
local GL2 = pile{{"zinc white",2},{"cerulean blue",0.6},{"ultramarine ash",0.4}}
local SPC = -M_hull() - OUTP
local cone = (NEWP:grow(6) + PLUME:shrink(4)) * SPC
local dens = function(x, y)
  local dx, dy = x - IMP[1], y - IMP[2]
  local r = math.sqrt(dx*dx + dy*dy)
  return 0.5 * math.exp(-r / 110) + 0.05
end
stipple(cone, {pile=GL2, width=1.2, coverage=dens, cluster={0.6, 8}, feather=0.7, pressure={0.2, 0.5}, seed=91})
stipple(cone, {pile=GL1, width=0.9, coverage=function(x,y) return 0.5*dens(x,y) end, cluster={0.6, 5}, feather=0.7, pressure={0.25, 0.6}, seed=92})

--@ chunk 48
print(wait(24*60))
local SPK = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.15}}
local b = brush{kind="round", width=1.6, point=0.6}
local n = 0
for _, p in ipairs(PL2) do
  if p.lt >= 0.5 and p.tag == nil and p.lit + 0.3*p.wear > 0.75 and rand(0,1) < 0.16 then
    if n % 8 == 0 then b:reload(SPK, 0.85) end
    n = n + 1
    local x, y = pt2(p, p.su*0.1, p.ss*0.72)
    b:touch(x, y, {pressure=rand(0.45, 0.7), clip=PCLIP})
  end
end
print(n)

--@ chunk 49
print(wait(3*24*60))
