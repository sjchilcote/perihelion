-- easel session "epilogue": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=2511, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.15}, {pile={{"lead white",0.6},{"ultramarine blue",2},{"bone black",1.2},{"Mars brown",0.6}}, um=40, apply="brush", texture=0.4}}}
SUN = {1090, -70}
SAIL = {655, 165}
function sund(x, y) local dx, dy = x - SUN[1], (y - SUN[2])*1.15 return math.sqrt(dx*dx + dy*dy) end
SK = {
 pile{{"ultramarine blue",2},{"bone black",1.6},{"lead white",0.12}},
 pile{{"ultramarine blue",2},{"bone black",1.2},{"lead white",0.3},{"cobalt violet",0.3}},
 pile{{"ultramarine blue",1.5},{"bone black",0.8},{"lead white",0.6},{"cobalt violet",0.4},{"Mars orange",0.1}},
 pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.35},{"Mars orange",0.25},{"cobalt violet",0.2}},
 pile{{"lead white",1.5},{"yellow ochre",0.35},{"Mars orange",0.25},{"bone black",0.2},{"ultramarine ash",0.3}},
}
local function zone(a, b) return mask(function(x,y) local d = sund(x,y) return (d >= a and d < b) and 1 or 0 end):soften(14) end
local Z = {{SK[1], 760, 9999}, {SK[2], 580, 760}, {SK[3], 430, 580}, {SK[4], 300, 430}, {SK[5], 0, 300}}
for _, z in ipairs(Z) do
  local m = zone(z[2], z[3])
  if m:area() > 10 then
    work(m, {hand="body", pile=z[1], coverage=3, fill=true, angle=function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, length={30, 70}, tool="filbert 12"})
  end
end

--@ chunk 2
SK0 = pile{{"bone black",2.2},{"ultramarine blue",1},{"Mars brown",0.2}}
local m = mask(function(x,y) return sund(x,y) > 720 and 1 or 0 end):soften(30)
work(m, {hand="body", pile=SK0, coverage=2.5, fill=true, angle=function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, length={30, 70}, tool="filbert 12"})
for _, r in ipairs({720, 580, 430, 300}) do
  local s = mask(function(x,y) local d = sund(x,y) return (math.abs(d - r) < 28) and 1 or 0 end):soften(10)
  blend(s, {angle=function(x,y) return math.atan(y - SUN[2], x - SUN[1]) end, tool={kind="badger", width=14}, length={30, 60}})
end

--@ chunk 3
print(wait(4*24*60), drying(655,165), drying(100,400))
SW = pile{{"lead white",3},{"zinc white",1},{"lemon chrome",0.12}}
SG = pile{{"lead white",2.5},{"cadmium yellow",0.4},{"Indian yellow",0.15}}
SB = pile{{"lead white",1.5},{"yellow ochre",0.6},{"Mars orange",0.15}}
local cx, cy = SAIL[1], SAIL[2]
local tilt = -0.32
local c, s = math.cos(tilt), math.sin(tilt)
function sailpt(u, v) return {cx + c*u - s*v, cy + s*u + c*v} end
-- soft halo first: low-load warm white glaze around the sail
local HALO = pile{{"lead white",1},{"Mars orange",0.12},{"cadmium yellow",0.1},medium=0.7}
local hm = ellipse(cx, cy, 70, 44):soften(30)
work(hm, {hand="glaze", pile=HALO, coverage=0.8, fill=true, angle=tilt, tool={kind="filbert", width=10, stiffness=0.2}, length={20, 50}, load=0.3, pressure={0.1, 0.25}})
-- the sail: an oblique disc, a little ragged where panels are still unfurling
local pts = {}
for k = 0, 35 do
  local th = k/36 * 2*math.pi
  local r = 1 + 0.04*math.sin(5*th + 1) + rand(-0.02, 0.02)
  pts[#pts+1] = sailpt(36*r*math.cos(th), 13*r*math.sin(th))
end
SAILM = poly(pts, true)
work(SAILM, {hand="detail", pile=SB, coverage=3, fill=true, clip=SAILM, tool={kind="round", width=2.2}, length={3, 8}, angle=tilt})
local lit = SAILM * mask(function(x,y) local dx, dy = x - cx, y - cy return (dx*c + dy*s > -14) and 1 or 0 end):soften(6)
work(lit, {hand="detail", pile=SG, coverage=3, fill=true, clip=SAILM, tool={kind="round", width=2.2}, length={3, 8}, angle=tilt})
local hot = SAILM * mask(function(x,y) local dx, dy = x - cx, y - cy return (dx*c + dy*s > 6) and 1 or 0 end):soften(5)
work(hot, {hand="detail", pile=SW, coverage=3, fill=true, clip=SAILM, tool={kind="round", width=2.0}, length={3, 7}, angle=tilt})

--@ chunk 4
print(wait(4*24*60), drying(600,140))
local m = ellipse(SAIL[1], SAIL[2], 80, 52) - SAILM:grow(0.8)
work(m, {hand="body", pile=SK[3], coverage=3.5, fill=true, clip=-SAILM:grow(0.8), edge="soft", angle=function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, length={12, 30}, tool="filbert 6"})

--@ chunk 5
local cx, cy = SAIL[1], SAIL[2]
-- ribs of the sail
local RB = pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.4}}
local r = brush{kind="rigger", width=0.5, point=1}
for k = 0, 11 do
  local th = k/12 * 2*math.pi + 0.13*math.sin(k*2.3)
  r:load(RB, 0.8)
  r:stroke({sailpt(2*math.cos(th), 0.8*math.sin(th)), sailpt(34*math.cos(th), 12.2*math.sin(th))}, {pressure={0.4, 0.15}, clip=SAILM})
end
-- the sun-facing rim, white-hot and crisp
local rim = {}
for k = -8, 8 do local th = k/16 * math.pi*0.9 rim[#rim+1] = sailpt(35.5*math.cos(th), 12.7*math.sin(th)) end
local w = brush{kind="rigger", width=0.9, point=1}
w:load(SW, 0.9)
w:stroke(rim, {pressure={0.1, 0.6, 0.1}, swell={0.3, 1, 0.3}})
-- tethers down to the station hanging in the sail's shadow
local st = sailpt(-14, 34)
STN = st
local TL = pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
local t = brush{kind="rigger", width=0.35, point=1}
for _, a in ipairs({-0.9, 0.2, 1.4, 2.6}) do
  t:load(TL, 0.6)
  local p = sailpt(30*math.cos(a + math.pi*0.45), 11*math.sin(a + math.pi*0.45))
  t:stroke({p, {st[1], st[2] - 3}}, {pressure={0.25, 0.25}})
end
-- the TESTAMENT: tiny dark bronze ring nearly edge-on with its spine; sun-side rim lit, a few warm windows
local BZ = pile{{"bone brown",2},{"raw sienna",1},{"bone black",0.6}}
local BL = pile{{"yellow ochre",2},{"lead white",1.2},{"Mars orange",0.2}}
local ring = {}
for k = 0, 24 do local th = k/24*2*math.pi ring[#ring+1] = {st[1] + 10*math.cos(th), st[2] + 3.4*math.sin(th) + 0.18*10*math.cos(th)} end
local b = brush{kind="round", width=1.6, point=0.5}
b:load(BZ, 0.9) b:stroke(ring, {pressure={0.7, 0.7}})
b:load(BZ, 0.9) b:stroke({{st[1] + 1.5, st[2] - 9}, {st[1] - 1.5, st[2] + 9}}, {pressure={0.8, 0.6}})
local l = brush{kind="rigger", width=0.6, point=1}
l:load(BL, 0.9) l:stroke({{st[1] + 6, st[2] - 3.2}, {st[1] + 10.2, st[2] + 0.6}, {st[1] + 7, st[2] + 3.5}}, {pressure={0.5, 0.3}})
l:load(BL, 0.9) l:stroke({{st[1] + 2.3, st[2] - 8.5}, {st[1] + 0.5, st[2] + 0}}, {pressure={0.5, 0.2}})
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.25}}
local d = brush{kind="round", width=0.6, point=0.5}
for k = 1, 5 do d:load(WL, 0.9) local th = 1.9 + k*0.33 d:touch(st[1] + 10*math.cos(th), st[2] + 3.4*math.sin(th) + 1.8*math.cos(th), {pressure=0.4}) end
-- knock out the stray fleck below-left
local f = brush{kind="filbert", width=4}
f:load(SK[3], 0.8) f:stroke({{600, 216}, {612, 214}}, {pressure={0.7, 0.6}})

--@ chunk 6
GD_ = pile{{"bone black",1.4},{"lead white",0.5},{"ultramarine blue",0.35}}
GM_ = pile{{"lead white",1},{"bone black",0.6},{"ultramarine blue",0.25}}
GL_ = pile{{"lead white",2.5},{"bone black",0.25},{"ultramarine ash",0.2}}
AM_ = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.2}}
CR_ = pile{{"cadmium red",1},{"rose madder",0.5},{"bone black",0.15}}
CD_ = pile{{"Mars red",1},{"rose madder",0.6},{"bone black",0.7}}
BN_ = pile{{"lead white",2},{"yellow ochre",0.4},{"raw sienna",0.1}}
BD_ = pile{{"lead white",0.7},{"raw sienna",0.5},{"bone black",0.45}}
HW_ = pile{{"lead white",3},{"zinc white",0.6},{"lemon chrome",0.08}}
local function frame(x, y, k)
  local a = math.atan(STN[2] - y, STN[1] - x)
  local c, s = math.cos(a), math.sin(a)
  -- which side faces the sun (+v or -v)
  local sx, sy = SUN[1] - x, SUN[2] - y
  local side = ((-s)*sx + c*sy) > 0 and 1 or -1
  return function(u, v) return {x + (c*u - s*v*side)*k, y + (s*u + c*v*side)*k} end
end
local function Q(L, u0, u1, v0, v1) return poly({L(u0,v0), L(u1,v0), L(u1,v1), L(u0,v1)}) end
local function fill(m, p, w) work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m, tool={kind="round", width=w}, length={1.5, 4}}) end
function miriad(x, y, k)
  local L = frame(x, y, k)
  local w = clamp(1.1*k, 0.6, 1.6)
  fill(Q(L, -11, 9, -3.2, 0), GD_, w)       -- shadow half of the hull
  fill(Q(L, -11, 9, 0, 3.2), GM_, w)        -- lit half
  fill(Q(L, -14, -11, -4.2, 4.2), GD_, w)   -- drive block
  fill(Q(L, -6, 2, 3.2, 5.6), GM_, w)       -- side module
  fill(Q(L, 9, 12, -2, 2), GM_, w)          -- blunt prow
  fill(Q(L, 4, 5.4, -3.2, 3.2), AM_, w*0.8) -- amber band
  local r = brush{kind="rigger", width=clamp(0.5*k, 0.3, 0.8), point=1}
  r:load(GL_, 0.9) r:stroke({L(-11, 3.2), L(9, 3.2), L(12, 2)}, {pressure={0.6, 0.5}})
  r:load(GL_, 0.9) r:stroke({L(-6, 5.6), L(2, 5.6)}, {pressure={0.6, 0.5}})
end
function church(x, y, k)
  local L = frame(x, y, k)
  local w = clamp(1.1*k, 0.6, 1.6)
  fill(Q(L, -13, 10, -1.8, 0), CD_, w)      -- spine, shadow side
  fill(Q(L, -13, 10, 0, 1.8), CR_, w)       -- spine, lit side
  fill(Q(L, 3, 6.5, -8, 0), BD_, w)         -- cross-arm, shadow half
  fill(Q(L, 3, 6.5, 0, 8), BN_, w)          -- cross-arm, lit half
  fill(poly({L(10, -1.8), L(17, 0), L(10, 1.8)}), BN_, w*0.8)   -- spire prow
  fill(Q(L, -15, -13, -2.6, 2.6), CD_, w)   -- drive
  local r = brush{kind="rigger", width=clamp(0.5*k, 0.3, 0.8), point=1}
  r:load(HW_, 0.9) r:stroke({L(-13, 1.8), L(10, 1.8), L(17, 0)}, {pressure={0.55, 0.5}})
  r:load(HW_, 0.9) r:stroke({L(3.2, 8), L(6.3, 8)}, {pressure={0.6, 0.5}})
end
MSH = {{330,330,0.55},{250,300,0.45},{395,380,0.7},{150,350,0.6},{290,420,0.9},{80,410,0.75},{200,460,1.15},{360,480,1.0},{110,520,1.4},{285,540,1.6},{30,330,0.5}}
CSH = {{655,320,0.5},{740,300,0.45},{610,370,0.65},{830,350,0.6},{705,410,0.85},{920,400,0.75},{790,460,1.1},{640,470,1.0},{900,520,1.4},{720,545,1.55},{975,320,0.5}}
for _, p in ipairs(MSH) do miriad(p[1], p[2], p[3]) end
for _, p in ipairs(CSH) do church(p[1], p[2], p[3]) end

--@ chunk 7
print(wait(3*24*60))
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"yellow ochre",0.3}}, pile{{"lead white",2},{"cerulean blue",0.3}}, pile{{"lead white",1},{"ultramarine blue",0.5},{"bone black",0.3}}}
local function nearship(x, y)
  for _, L in ipairs({MSH, CSH}) do for _, p in ipairs(L) do if (x-p[1])^2 + (y-p[2])^2 < (22*p[3])^2 then return true end end end
  return false
end
local b = brush{kind="round", width=0.7, point=0.5}
local n = 0
for i = 1, 520 do
  local x, y = rand(2, 998), rand(2, 560)
  local d = sund(x, y)
  if d > 600 + rand(0, 120) and not nearship(x, y) then
    n = n + 1
    local u = rand(0,1)
    local pi_ = (u < 0.12) and 1 or (u < 0.3) and 2 or (u < 0.45) and 3 or 4
    b:load(ST[pi_], 0.8)
    local pr = (pi_ == 4) and rand(0.25, 0.45) or rand(0.2, 0.4)
    if u < 0.03 then pr = 0.7 end
    b:touch(x, y, {pressure=pr})
  end
end
print(n)
-- the stray fleck under the sail
local f = brush{kind="filbert", width=5}
f:load(SK[3], 0.85) f:stroke({{596, 219}, {616, 217}}, {pressure={0.8, 0.7}})
f:load(SK[3], 0.85) f:stroke({{598, 222}, {614, 220}}, {pressure={0.8, 0.7}})
-- the testimony going out: a few faint broken rings spreading from the sail
local RG = pile{{"lead white",1},{"yellow ochre",0.25},{"ultramarine ash",0.3},{"bone black",0.15}}
local r = brush{kind="rigger", width=0.6, point=1}
for j, R in ipairs({95, 150, 215, 290}) do
  local th = rand(0, 1)
  while th < 2*math.pi do
    local span = rand(0.25, 0.7)
    local pts = {}
    for k = 0, 10 do local t = th + span*k/10 pts[#pts+1] = {SAIL[1] + R*math.cos(t), SAIL[2] + 30 + R*0.42*math.sin(t)} end
    r:load(RG, 0.5)
    r:stroke(pts, {pressure={0.0, 0.32 - j*0.05, 0.0}, swell={0.2, 1, 0.2}})
    th = th + span + rand(0.15, 0.5)
  end
end

--@ chunk 8
-- the Sun's edge in the corner: hotter, harder core
local SC1 = pile{{"lead white",2.5},{"cadmium yellow",0.3},{"Mars orange",0.05}}
local SC2 = pile{{"lead white",3},{"zinc white",1.5},{"lemon chrome",0.08}}
local ang = function(x,y) return math.atan(y - SUN[2], x - SUN[1]) end
local m1 = mask(function(x,y) return sund(x,y) < 235 and 1 or 0 end):roughen(6, 30, 7)
local m2 = mask(function(x,y) return sund(x,y) < 180 and 1 or 0 end)
work(m1, {hand="body", pile=SC1, coverage=3, fill=true, angle=ang, length={12, 30}, tool="filbert 8", edge="soft"})
work(m2, {hand="body", pile=SC2, coverage=3.5, fill=true, clip=m2, angle=ang, length={12, 30}, tool="filbert 8"})
-- more stars, a few strong ones
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"yellow ochre",0.2}}, pile{{"lead white",2},{"cerulean blue",0.25}}}
local function nearship(x, y)
  for _, L in ipairs({MSH, CSH}) do for _, p in ipairs(L) do if (x-p[1])^2 + (y-p[2])^2 < (22*p[3])^2 then return true end end end
  return false
end
local b = brush{kind="round", width=1.0, point=0.4}
local n = 0
for i = 1, 420 do
  local x, y = rand(2, 998), rand(2, 560)
  if sund(x, y) > 640 + rand(0, 150) and not nearship(x, y) then
    n = n + 1
    local u = rand(0,1)
    b:load(ST[(u < 0.5) and 1 or (u < 0.75) and 2 or 3], 0.9)
    b:touch(x, y, {pressure=(u < 0.06) and 0.8 or rand(0.35, 0.6)})
  end
end
print(n)

--@ chunk 9
print(wait(2*24*60))
function shipframe(x, y, k)
  local a = math.atan(STN[2] - y, STN[1] - x)
  local c, s = math.cos(a), math.sin(a)
  local sx, sy = SUN[1] - x, SUN[2] - y
  local side = ((-s)*sx + c*sy) > 0 and 1 or -1
  return function(u, v) return {x + (c*u - s*v*side)*k, y + (s*u + c*v*side)*k} end
end
local DK = pile{{"bone black",2},{"ultramarine blue",0.4}}
local r = brush{kind="rigger", width=0.45, point=1}
local d = brush{kind="round", width=0.5, point=0.5}
for _, p in ipairs(MSH) do
  if p[3] >= 0.7 then
    local L = shipframe(p[1], p[2], p[3])
    -- window grid on the lit half
    for u = -9, 7, 2.2 do d:load(DK, 0.8) local q = L(u, 1.6) d:touch(q[1], q[2], {pressure=0.35}) end
    -- cold gun barrels along the shadow flank
    r:load(DK, 0.9) r:stroke({L(-2, -3.6), L(11, -3.6)}, {pressure={0.6, 0.5}})
    r:load(DK, 0.9) r:stroke({L(-1, -2.2), L(12.5, -2.2)}, {pressure={0.5, 0.4}})
    -- antenna
    r:load(GL_, 0.9) r:stroke({L(-4, 5.6), L(-6, 9)}, {pressure={0.4, 0.3}})
    -- signage block
    d:load(AM_, 0.9) local q = L(-12.5, 0) d:touch(q[1], q[2], {pressure=0.5})
  end
end
for _, p in ipairs(CSH) do
  if p[3] >= 0.6 then
    local L = shipframe(p[1], p[2], p[3])
    -- bone ribs across the crimson spine
    for u = -11, 1, 3 do r:load(BN_, 0.9) r:stroke({L(u, -1.8), L(u, 1.8)}, {pressure={0.45, 0.45}}) end
    -- cold lance barrels along the shadow side
    r:load(DK, 0.9) r:stroke({L(-6, -2.6), L(14, -2.6)}, {pressure={0.55, 0.45}})
    -- small crimson cross on the cross-arm
    d:load(CR_, 0.9) local q = L(4.75, 4.5) d:touch(q[1], q[2], {pressure=0.5})
    -- dark ports
    for u = -9, 7, 4 do d:load(DK, 0.8) local q = L(u, 0.9) d:touch(q[1], q[2], {pressure=0.3}) end
  end
end
-- the sail's sun side, white-hot
local w = brush{kind="filbert", width=3, stiffness=0.5}
for k = 1, 9 do
  w:load(SW, 0.9)
  local u = rand(8, 30) local v = rand(-8, 8) * (1 - u/40)
  local p1, p2 = sailpt(u, v), sailpt(u + 5, v + rand(-1, 1))
  w:stroke({p1, p2}, {pressure={0.6, 0.4}, clip=SAILM:shrink(1.2)})
end

--@ chunk 10
local m = ellipse(SAIL[1], SAIL[2], 80, 52)
local leftside = mask(function(x,y) return sund(x,y) > 470 and 1 or 0 end)
print(lose(m, {pile=SK[2], where=leftside, load=0.3, reach={10, 12}, tool="filbert 5"}))

--@ chunk 11
local keep = SAILM:grow(1.0) + ellipse(STN[1], STN[2], 14, 12)
local m = ellipse(SAIL[1], SAIL[2] + 4, 100, 68) - ellipse(SAIL[1], SAIL[2] + 4, 58, 36)
work(m, {hand="body", pile=SK[3], coverage=3.5, fill=true, clip=-keep, edge="loose", angle=function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, length={10, 24}, tool="filbert 6"})
print(wait(4*24*60))
local RG = pile{{"lead white",1},{"yellow ochre",0.25},{"ultramarine ash",0.3},{"bone black",0.15}}
local r = brush{kind="rigger", width=0.6, point=1}
for j, R in ipairs({95, 150}) do
  local th = rand(0, 1)
  while th < 2*math.pi do
    local span = rand(0.25, 0.6)
    local pts = {}
    for k = 0, 10 do local t = th + span*k/10 pts[#pts+1] = {SAIL[1] + R*math.cos(t), SAIL[2] + 30 + R*0.42*math.sin(t)} end
    r:load(RG, 0.5)
    r:stroke(pts, {pressure={0.0, 0.25, 0.0}, swell={0.2, 1, 0.2}, clip=-keep})
    th = th + span + rand(0.2, 0.5)
  end
end

