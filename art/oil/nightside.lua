-- easel session "nightside": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=4401, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",1.2},{"Mars brown",0.3},{"lead white",0.05}}, um=45, apply="brush", texture=0.35}}}
LC = {430, 1400}
LR = 1180
function ld(x, y) local dx, dy = x - LC[1], y - LC[2] return LR - math.sqrt(dx*dx + dy*dy) end   -- depth below the limb (>0 on hull)
HULL = mask(function(x,y) return ld(x,y) > 0 and 1 or 0 end)
HD = {
 pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.2}},
 pile{{"bone black",1.5},{"bone brown",1},{"raw sienna",0.3},{"ultramarine blue",0.15}},
}
local tang = function(x,y) return math.atan(y - LC[2], x - LC[1]) + math.pi/2 end
work(HULL, {hand="body", pile=HD[1], coverage=3, fill=true, clip=HULL, angle=tang, length={25, 60}, tool="filbert 12"})

--@ chunk 2
K = {
 pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}},
 pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.5},{"bone black",0.08}},
 pile{{"Mars red",0.6},{"bone black",0.8},{"ultramarine blue",0.3},{"lead white",0.1}},
 pile{{"bone black",2},{"ultramarine blue",1.2},{"Mars brown",0.3},{"lead white",0.05}},
}
function cw(x) return 14 + 34*math.exp(-((x - 620)/210)^2) end
local SKYM = -HULL:grow(0.3)
local cells = {}
for y = 120, 420, 2.6 do for x = 0, 1004, 2.8 do
  local xx, yy = x + rand(-1, 1), y + rand(-1, 1)
  local d = -ld(xx, yy)
  local w = cw(xx)
  if d > 0 and d < w*1.25 then
    local t = d/w*3 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 1), 1, 4)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(K[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(K[i], 0.9) end
    local a = math.atan(c.y - LC[2], c.x - LC[1]) + randn(0, 0.03)
    local h = rand(2.5, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.5}, ramps={0.15, 0.35}, clip=SKYM})
  end
end end
print(#cells)
local band = SKYM * mask(function(x,y) local d = -ld(x,y) return (d > 1.5 and d < cw(x)*1.35) and 1 or 0 end)
blend(band, {angle=function(x,y) return math.atan(y - LC[2], x - LC[1]) end, tool={kind="badger", width=6}, length={8, 18}})

--@ chunk 3
print(wait(4*24*60), drying(500,450), drying(500,215))
-- scale-plate rows on the night hull, foreshortened toward the limb; edges barely lighter than the hull
PE = pile{{"bone brown",1.5},{"raw sienna",0.5},{"bone black",1},{"ultramarine blue",0.15}}
PS = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local function pt(phi, dep) local R = LR - dep return {LC[1] + R*math.cos(phi), LC[2] + R*math.sin(phi)} end
local rows = {}
local dep = 2.5
local k = 0
while dep < 420 do
  k = k + 1
  local h = 1.3 + 0.07*dep^0.95
  rows[#rows+1] = {dep=dep, h=h, k=k}
  dep = dep + h
end
NROWS = #rows
local e = brush{kind="rigger", width=0.5, point=1}
local sh = brush{kind="round", width=0.8, point=0.6}
local n = 0
PLATES = {}
for _, r in ipairs(rows) do
  local R = LR - r.dep
  local s = 7.5 + r.dep*0.018
  local dphi = s / R
  local phi0 = -math.pi*0.5 - 0.6
  local off = ((r.k*0.618) % 1) * dphi
  local phi = phi0 + off
  while phi < -math.pi*0.5 + 0.6 do
    local p = pt(phi, r.dep)
    if p[1] > -5 and p[1] < 1005 and p[2] < 570 then
      local ss = dphi*rand(0.85, 1.12)
      local a = pt(phi - ss*0.48, r.dep + r.h*0.55)
      local m = pt(phi, r.dep + r.h*1.0)
      local b = pt(phi + ss*0.48, r.dep + r.h*0.55)
      n = n + 1
      if n % 8 == 0 then e:load(PE, 0.7) sh:load(PS, 0.8) end
      if n == 1 then e:load(PE, 0.7) sh:load(PS, 0.8) end
      sh:stroke({a, m, b}, {pressure={0.25, 0.4, 0.25}, clip=HULL})
      e:stroke({pt(phi - ss*0.45, r.dep + r.h*0.4), pt(phi, r.dep + r.h*0.85), pt(phi + ss*0.45, r.dep + r.h*0.4)}, {pressure={0.12, 0.28, 0.12}, clip=HULL})
      if rand(0,1) < 0.07 then PLATES[#PLATES+1] = {phi=phi, dep=r.dep, h=r.h, s=ss} end
    end
    phi = phi + dphi*rand(0.92, 1.08)
  end
end
print(#rows, n, #PLATES)

--@ chunk 4
print(wait(8*24*60), drying(500,450), drying(500,215), drying(620,190))
local function pt(phi, dep) local R = LR - dep return {LC[1] + R*math.cos(phi), LC[2] + R*math.sin(phi)} end
local function phi_of(x) return -math.acos(clamp((x - LC[1]) / LR, -1, 1)) end
-- the ring's window belts: nearly all dark, a few warm
local WD = pile{{"bone brown",1},{"bone black",1.4},{"raw sienna",0.3}}
local WDl = pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.8}}
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
local WL2 = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.6}}
local d = brush{kind="round", width=0.7, point=0.5}
local nl, nd = 0, 0
for bi, dep in ipairs({20, 46, 92, 165, 285, 420}) do
  local R = LR - dep
  local s = 3.6 + dep*0.022
  local phi = -math.pi*0.5 - 0.62 + rand(0, 0.01)
  local k = 0
  local warmrun = 0
  while phi < -math.pi*0.5 + 0.62 do
    k = k + 1
    local p = pt(phi, dep)
    if p[1] > 0 and p[1] < 1000 and p[2] < 560 then
      if warmrun == 0 and rand(0,1) < 0.012 then warmrun = math.random(2, 6) end
      local w = clamp(0.5 + dep*0.004, 0.5, 1.6)
      d = brush{kind="round", width=w, point=0.5}
      if warmrun > 0 then
        warmrun = warmrun - 1
        d:load((rand(0,1) < 0.5) and WL or WL2, 0.95) d:touch(p[1], p[2], {pressure=0.55}) nl = nl + 1
      elseif rand(0,1) < 0.55 then
        d:load((rand(0,1) < 0.7) and WD or WDl, 0.8) d:touch(p[1], p[2], {pressure=0.4}) nd = nd + 1
      end
    end
    phi = phi + (s / R) * (1 + 0.5*((k*0.618) % 1))
  end
end
print("windows lit", nl, "dark", nd)
-- faint blue starlight on a few plate edges
local SB = pile{{"ultramarine ash",1},{"cerulean blue",0.3},{"bone black",0.5},{"lead white",0.25}}
local g = brush{kind="rigger", width=0.45, point=1}
for i, p in ipairs(PLATES) do
  if i % 5 == 1 then g:load(SB, 0.7) end
  local a = pt(p.phi - p.s*0.3, p.dep + p.h*0.5)
  local b = pt(p.phi + p.s*0.05, p.dep + p.h*0.85)
  g:stroke({a, b}, {pressure={0.25, 0.1}, clip=HULL})
end
-- the limb itself: a hard burning line, hottest where the Sun is behind
local HOT = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.15}}
local r = brush{kind="rigger", width=1.0, point=1}
local phi = phi_of(-10)
while phi < phi_of(1010) do
  local seg = {}
  for j = 0, 10 do seg[#seg+1] = pt(phi + j*0.004, -0.3) end
  local x = seg[6][1]
  local f = math.exp(-((x - 620)/260)^2)
  r:load(HOT, 0.9)
  r:stroke(seg, {pressure={0.25 + 0.35*f, 0.25 + 0.35*f}})
  phi = phi + 0.04
end
-- stars
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"cerulean blue",0.3}}, pile{{"lead white",1},{"ultramarine blue",0.5},{"bone black",0.3}}}
local sb = brush{kind="round", width=0.7, point=0.4}
local ns = 0
for i = 1, 700 do
  local x, y = rand(2, 998), rand(2, 380)
  if -ld(x, y) > cw(x)*1.4 + rand(0, 30) then
    ns = ns + 1
    local u = rand(0,1)
    sb:load(ST[(u < 0.35) and 1 or (u < 0.55) and 2 or 3], 0.9)
    sb:touch(x, y, {pressure=(u < 0.03) and 0.7 or rand(0.2, 0.45)})
  end
end
print(ns)

--@ chunk 5
print(wait(3*24*60))
local function pt(phi, dep) local R = LR - dep return {LC[1] + R*math.cos(phi), LC[2] + R*math.sin(phi)} end
local c = brush{kind="filbert", width=1.8, stiffness=0.5}
for i, p in ipairs(PLATES) do
  if i % 3 == 1 then c:load(HD[1], 0.9) end
  local a = pt(p.phi - p.s*0.36, p.dep + p.h*0.45)
  local b = pt(p.phi + p.s*0.12, p.dep + p.h*0.9)
  c:stroke({a, b}, {pressure={0.6, 0.6}, clip=HULL})
end

--@ chunk 6
local function pt(phi, dep) local R = LR - dep return {LC[1] + R*math.cos(phi), LC[2] + R*math.sin(phi)} end
local function phi_of(x) return -math.acos(clamp((x - LC[1]) / LR, -1, 1)) end
local WD = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.7},{"ultramarine blue",0.1}}
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
local SPILL = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"bone brown",0.6},{"bone black",0.3}}
local nl, nd = 0, 0
WARM = {}
for bi, dep in ipairs({24, 52, 100, 175, 300, 440}) do
  local R = LR - dep
  local s = 4.2 + dep*0.03
  local len = 0.9 + dep*0.012
  local w = clamp(0.5 + dep*0.004, 0.55, 1.8)
  local d = brush{kind="round", width=w, point=0.4}
  local phi = -math.pi*0.5 - 0.62 + rand(0, 0.01)
  local k = 0
  local warmrun = 0
  while phi < -math.pi*0.5 + 0.62 do
    k = k + 1
    local p = pt(phi, dep)
    local q = pt(phi + len/R, dep)
    if p[1] > 0 and p[1] < 1000 and p[2] < 560 then
      if warmrun == 0 and rand(0,1) < 0.01 then warmrun = math.random(3, 9) end
      if warmrun > 0 then
        warmrun = warmrun - 1
        d:load(WL, 0.95) d:stroke({p, q}, {pressure={0.65, 0.65}}) nl = nl + 1
        WARM[#WARM+1] = {p[1], p[2], w}
      elseif ((k*0.618) % 1) < 0.8 then
        d:load(WD, 0.8) d:stroke({p, q}, {pressure={0.45, 0.45}}) nd = nd + 1
      end
    end
    phi = phi + (s / R)
  end
end
print("lit", nl, "dark", nd)

--@ chunk 7
print(wait(4*24*60))
-- a faint warm spill around the lit windows
local SPILL = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"bone brown",0.5},{"bone black",0.2},{"lead white",0.1}}
local g = brush{kind="round", width=3, point=0.2}
for i, w in ipairs(WARM) do
  if i % 4 == 1 then g:load(SPILL, 0.25) end
  g = brush{kind="round", width=w[3]*3.2, point=0.2}
  g:load(SPILL, 0.2)
  g:touch(w[1], w[2] + w[3]*1.2, {pressure=0.18})
end
-- the dead MIRIAD outpost, silhouetted on the burning limb, its last beacon still blinking
local function pt(phi, dep) local R = LR - dep return {LC[1] + R*math.cos(phi), LC[2] + R*math.sin(phi)} end
local function phi_of(x) return -math.acos(clamp((x - LC[1]) / LR, -1, 1)) end
local ph = phi_of(782)
local o = pt(ph, 1.0)
local nx, ny = math.cos(ph), math.sin(ph)        -- outward normal
local tx, ty = -ny, nx                           -- along the limb
OUTP = {o, nx, ny, tx, ty}
local function L(u, v) return {o[1] + tx*u + nx*v, o[2] + ty*u + ny*v} end
local function Q(u0, u1, v0, v1) return poly({L(u0,v0), L(u1,v0), L(u1,v1), L(u0,v1)}) end
local GK = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.05}}
local sil = Q(-9, 7, -1, 4.2) + Q(-6, -1, 4.2, 7.5) + Q(2, 9.5, 4.2, 5.4) + Q(9.5, 12, -1, 2.6) + Q(-14, -9, -1, 1.8)
work(sil, {hand="detail", pile=GK, coverage=4, fill=true, clip=sil, tool={kind="round", width=0.8}, length={1, 3}})
local r = brush{kind="rigger", width=0.45, point=1}
r:load(GK, 0.95) r:stroke({L(-3.5, 7.5), L(-3.5, 15)}, {pressure={0.6, 0.5}})
r:load(GK, 0.95) r:stroke({L(4, 5.4), L(6, 10)}, {pressure={0.5, 0.4}})

--@ chunk 8
print(wait(4*24*60))
local o, nx, ny, tx, ty = OUTP[1], OUTP[2], OUTP[3], OUTP[4], OUTP[5]
local function L(u, v) return {o[1] + tx*u + nx*v, o[2] + ty*u + ny*v} end
local q = L(-3.5, 15.6)
local AG = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.3},medium=0.4}
local g = brush{kind="round", width=7, point=0.2}
g:load(AG, 0.3) g:touch(q[1], q[2], {pressure=0.25})
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.4}}
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.2}}
local b = brush{kind="round", width=2.2, point=0.3}
b:load(AM, 0.95) b:touch(q[1], q[2], {pressure=0.7})
local h = brush{kind="round", width=1.0, point=0.3}
h:load(AH, 0.95) h:touch(q[1], q[2], {pressure=0.6})

--@ chunk 9
local o, nx, ny, tx, ty = OUTP[1], OUTP[2], OUTP[3], OUTP[4], OUTP[5]
local function L(u, v) return {o[1] + tx*u + nx*v, o[2] + ty*u + ny*v} end
-- beacon moved down onto the low module, seen against the dark hull, with a faint amber pool on the plates
local q = L(-11.5, 0.6)
local POOL = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"bone brown",0.6},{"bone black",0.3}}
local p = brush{kind="round", width=9, point=0.1}
p:load(POOL, 0.25) p:touch(q[1] - nx*3, q[2] - ny*3, {pressure=0.2})
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.4}}
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.2}}
local b = brush{kind="round", width=2.0, point=0.3}
b:load(AM, 0.95) b:touch(q[1], q[2], {pressure=0.7})
local h = brush{kind="round", width=0.9, point=0.3}
h:load(AH, 0.95) h:touch(q[1], q[2], {pressure=0.6})
-- warm windows restated a little larger so the few that are lit read
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
for i, w in ipairs(WARM) do
  local d = brush{kind="round", width=w[3]*1.5, point=0.3}
  d:load(WL, 0.95) d:touch(w[1], w[2], {pressure=0.6})
end

--@ chunk 10
local o, nx, ny, tx, ty = OUTP[1], OUTP[2], OUTP[3], OUTP[4], OUTP[5] print(o[1], o[2], nx, ny, tx, ty) print(o[1] + tx*-11.5 + nx*0.6, o[2] + ty*-11.5 + ny*0.6) print(o[1] - 3.5*tx + 15.6*nx, o[2] - 3.5*ty + 15.6*ny)

--@ chunk 11
local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}} local b = brush{kind="round", width=2.4, point=0.2} b:load(AM, 0.95) print(b:fullness()) b:touch(771, 270.5, {pressure=0.85}) print(b:fullness()) b:touch(771.4, 270.6, {pressure=0.8}) print(b:fullness())

--@ chunk 12
print(wait(2*24*60)) local G = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.2},{"bone brown",0.3}} local g = brush{kind="round", width=6, point=0.1} g:load(G, 0.35) g:touch(771, 272, {pressure=0.25}) local AM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}} local b = brush{kind="round", width=3.0, point=0.2} b:load(AM, 0.95) b:touch(771.2, 270.6, {pressure=0.9}) local H = pile{{"lead white",2},{"cadmium yellow",1}} local h = brush{kind="round", width=1.2, point=0.2} h:load(H, 0.95) h:touch(771.2, 270.5, {pressure=0.8})
