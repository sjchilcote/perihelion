-- easel session "sail_far": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=909, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"ultramarine blue",2},{"bone black",1.6},{"Mars brown",0.3},{"lead white",0.12}}, um=45, apply="brush", texture=0.35}}}
SUNC = {-150, 290}
SUNR = 340
function sd(x, y) local dx, dy = x - SUNC[1], y - SUNC[2] return math.sqrt(dx*dx + dy*dy) end
SN = {
 pile{{"lead white",2.5},{"cadmium yellow",0.35},{"Mars orange",0.12}},   -- limb, warm
 pile{{"lead white",3},{"lemon chrome",0.15}},                           -- inner
 pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.05}},           -- core, white-hot
}
local ang = function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) + math.pi/2 end
local disc = mask(function(x,y) return sd(x,y) < SUNR and 1 or 0 end)
SUNM = disc
work(disc, {hand="body", pile=SN[1], coverage=3, fill=true, clip=disc, angle=ang, length={20, 50}, tool="filbert 10"})
local inner = mask(function(x,y) return sd(x,y) < SUNR - 28 and 1 or 0 end):soften(10)
work(inner, {hand="body", pile=SN[2], coverage=3, fill=true, clip=disc, angle=ang, length={20, 50}, tool="filbert 10"})
local core = mask(function(x,y) return sd(x,y) < SUNR - 90 and 1 or 0 end):soften(14)
work(core, {hand="body", pile=SN[3], coverage=3.5, fill=true, clip=disc, angle=ang, length={20, 50}, tool="filbert 10"})

--@ chunk 2
SC = {650, 215}
STILT = -0.1
local c, s = math.cos(STILT), math.sin(STILT)
function sp(u, v) return {SC[1] + c*u - s*v, SC[2] + s*u + c*v} end
SRX, SRY = 300, 92
local pts = {}
for k = 0, 71 do
  local th = k/72 * 2*math.pi
  local r = 1 + 0.012*math.sin(12*th) + 0.006*math.sin(29*th + 1)
  pts[#pts+1] = sp(SRX*r*math.cos(th), SRY*r*math.sin(th))
end
SAILM = poly(pts, true)
SL = {
 pile{{"lead white",1},{"ultramarine ash",0.7},{"bone black",0.3},{"yellow ochre",0.2}},  -- far end, turned away
 pile{{"lead white",2},{"yellow ochre",0.3},{"ultramarine ash",0.4},{"bone black",0.08}}, -- sheet
 pile{{"lead white",3},{"lemon chrome",0.15}},                                           -- reflection
}
local rad = function(x,y) return math.atan(y - SC[2], x - SC[1]) end
local function uof(x, y) local dx, dy = x - SC[1], y - SC[2] return (dx*c + dy*s) / SRX end
work(SAILM, {hand="body", pile=SL[2], coverage=3, fill=true, clip=SAILM, angle=rad, length={20, 45}, tool="filbert 9"})
local far = SAILM * mask(function(x,y) return uof(x,y) > 0.45 and 1 or 0 end):soften(25)
work(far, {hand="body", pile=SL[1], coverage=2.5, fill=true, clip=SAILM, angle=rad, length={15, 35}, tool="filbert 9"})
local hot = SAILM * ellipse(SC[1] - 120, SC[2] + 8, 110, 50):soften(20)
work(hot, {hand="body", pile=SL[3], coverage=3, fill=true, clip=SAILM, angle=rad, length={15, 35}, tool="filbert 9"})

--@ chunk 3
local c, s = math.cos(STILT), math.sin(STILT)
local function uof(x, y) local dx, dy = x - SC[1], y - SC[2] return (dx*c + dy*s) / SRX end
local rad = function(x,y) return math.atan(y - SC[2], x - SC[1]) end
local e1 = ellipse(SC[1] - 120, SC[2] + 8, 110, 50)
local seam1 = (e1:grow(14) - e1:shrink(14)) * SAILM:shrink(3)
local seam2 = SAILM:shrink(3) * mask(function(x,y) local u = uof(x,y) return (u > 0.33 and u < 0.62) and 1 or 0 end)
blend(seam1, {angle=rad, tool={kind="badger", width=10}, length={15, 30}})
blend(seam2, {angle=rad, tool={kind="badger", width=10}, length={15, 30}})

--@ chunk 4
local GLW = pile{{"lead white",1},{"Mars orange",0.12},{"cadmium yellow",0.08}}
local radial = function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end
local out = -SUNM:grow(0.5)
local b1 = mask(function(x,y) local d = sd(x,y) return (d >= SUNR and d < SUNR + 90) and 1 or 0 end):soften(20) * out
local b2 = mask(function(x,y) local d = sd(x,y) return (d >= SUNR and d < SUNR + 35) and 1 or 0 end):soften(10) * out
work(b1, {hand="glaze", pile=GLW, coverage=1.2, fill=true, clip=out, angle=radial, load=0.25, pressure={0.1, 0.25}, length={30, 70}, tool={kind="filbert", width=10, stiffness=0.2}})
work(b2, {hand="glaze", pile=GLW, coverage=1.2, fill=true, clip=out, angle=radial, load=0.3, pressure={0.15, 0.3}, length={20, 50}, tool={kind="filbert", width=8, stiffness=0.2}})
blend(b1:grow(10) * out, {angle=radial, tool={kind="badger", width=12}, length={30, 60}})
print(wait(4*24*60), drying(650, 215), drying(100, 300))

--@ chunk 5
local SEAM = pile{{"lead white",1},{"ultramarine ash",0.5},{"bone black",0.35},{"yellow ochre",0.15}}
local r = brush{kind="rigger", width=0.55, point=1}
local hub = {-40, 4}
-- radial panel seams
for k = 0, 27 do
  local th = k/28 * 2*math.pi + 0.06*math.sin(k*1.7)
  r:load(SEAM, 0.7)
  r:stroke({sp(hub[1], hub[2]), sp(hub[1] + (SRX*0.55)*math.cos(th), hub[2] + (SRY*0.55)*math.sin(th)), sp(SRX*0.985*math.cos(th), SRY*0.985*math.sin(th))}, {pressure={0.15, 0.35}, clip=SAILM:shrink(1)})
end
-- concentric seams
for _, f in ipairs({0.35, 0.62, 0.86}) do
  local pts = {}
  for k = 0, 64 do local th = k/64*2*math.pi pts[#pts+1] = sp(hub[1]*(1-f) + SRX*f*math.cos(th), hub[2]*(1-f) + SRY*f*math.sin(th)) end
  r:load(SEAM, 0.6)
  r:stroke(pts, {pressure={0.25, 0.25}, clip=SAILM:shrink(1)})
end
-- the hoop at the sail's edge: bright on the sun side, darker where it turns away
local RIM = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.05}}
local RD = pile{{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.5}}
local h = brush{kind="rigger", width=1.3, point=1}
local seg = {}
for k = 0, 40 do local th = math.pi*0.55 + k/40*math.pi*0.9 seg[#seg+1] = sp(SRX*1.005*math.cos(th), SRY*1.005*math.sin(th)) end
h:load(RIM, 0.95) h:stroke(seg, {pressure={0.3, 0.7, 0.3}, swell={0.5, 1, 1, 0.5}})
local seg2 = {}
for k = 0, 40 do local th = -math.pi*0.45 + k/40*math.pi*0.9 seg2[#seg2+1] = sp(SRX*1.005*math.cos(th), SRY*1.005*math.sin(th)) end
h:load(RD, 0.95) h:stroke(seg2, {pressure={0.5, 0.6, 0.5}})
local seg3 = {}
for k = 0, 30 do local th = math.pi*0.1 + k/30*math.pi*0.45 seg3[#seg3+1] = sp(SRX*1.005*math.cos(th), SRY*1.005*math.sin(th)) end
h:load(RIM, 0.8) h:stroke(seg3, {pressure={0.2, 0.45, 0.2}})
-- the Sun's reflection blazing in the mirror
local hs = sp(-120, 8)
HOTSPOT = hs
local w = brush{kind="round", width=7, point=0.3}
w:load(RIM, 0.95) w:touch(hs[1], hs[2], {pressure=0.9})
local f = brush{kind="rigger", width=1.0, point=1}
f:load(RIM, 0.9) f:stroke({{hs[1] - 40, hs[2] + 4}, {hs[1], hs[2]}, {hs[1] + 40, hs[2] - 4}}, {pressure={0.0, 0.7, 0.0}, swell={0.1, 1, 0.1}})
f:load(RIM, 0.9) f:stroke({{hs[1] + 1, hs[2] - 16}, {hs[1], hs[2]}, {hs[1] - 1, hs[2] + 16}}, {pressure={0.0, 0.6, 0.0}, swell={0.1, 1, 0.1}})

--@ chunk 6
local MS = pile{{"lead white",1},{"ultramarine ash",0.55},{"bone black",0.28},{"yellow ochre",0.1}}
local hs = HOTSPOT
local function dh(x, y) local dx, dy = (x - hs[1]), (y - hs[2])*2.6 return math.sqrt(dx*dx + dy*dy) end
local rad = function(x,y) return math.atan(y - hs[2], x - hs[1]) end
local m1 = SAILM:shrink(1.5) * mask(function(x,y) local d = dh(x,y) return (d > 90 and d < 175) and 1 or 0 end):soften(20)
local m2 = SAILM:shrink(1.5) * mask(function(x,y) return dh(x,y) >= 175 and 1 or 0 end):soften(20)
work(m1, {hand="body", pile=MS, coverage=1.0, fill=false, clip=SAILM:shrink(1.5), angle=rad, length={15, 35}, tool="filbert 7"})
work(m2, {hand="body", pile=MS, coverage=2.8, fill=true, clip=SAILM:shrink(1.5), angle=rad, length={15, 35}, tool="filbert 7"})

--@ chunk 7
local hs = HOTSPOT
local function dh(x, y) local dx, dy = (x - hs[1]), (y - hs[2])*2.6 return math.sqrt(dx*dx + dy*dy) end
local rad = function(x,y) return math.atan(y - hs[2], x - hs[1]) end
local m = SAILM:shrink(2) * mask(function(x,y) local d = dh(x,y) return (d > 60 and d < 200) and 1 or 0 end):soften(10)
blend(m, {angle=rad, tool={kind="badger", width=8}, length={20, 40}})

--@ chunk 8
print(wait(5*24*60), drying(650,215), drying(530,235), drying(100,300))
local SEAM = pile{{"lead white",0.7},{"ultramarine ash",0.5},{"bone black",0.45},{"yellow ochre",0.1}}
local r = brush{kind="rigger", width=0.5, point=1}
local hub = {-40, 4}
local inner = SAILM:shrink(1.5)
for k = 0, 27 do
  local th = k/28 * 2*math.pi + 0.06*math.sin(k*1.7)
  r:load(SEAM, 0.7)
  r:stroke({sp(hub[1], hub[2]), sp(hub[1] + (SRX*0.55)*math.cos(th), hub[2] + (SRY*0.55)*math.sin(th)), sp(SRX*0.985*math.cos(th), SRY*0.985*math.sin(th))}, {pressure={0.12, 0.4}, clip=inner})
end
for _, f in ipairs({0.35, 0.62, 0.86}) do
  local pts = {}
  for k = 0, 64 do local th = k/64*2*math.pi pts[#pts+1] = sp(hub[1]*(1-f) + SRX*f*math.cos(th), hub[2]*(1-f) + SRY*f*math.sin(th)) end
  r:load(SEAM, 0.6)
  r:stroke(pts, {pressure={0.3, 0.3}, clip=inner})
end
-- blaze: the Sun's own image in the mirror
local RIM = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.05}}
local hs = HOTSPOT
local w = brush{kind="round", width=9, point=0.3}
w:load(RIM, 0.95) w:touch(hs[1], hs[2], {pressure=0.9})
w:load(RIM, 0.95) w:touch(hs[1] + 3, hs[2], {pressure=0.8})
local f = brush{kind="rigger", width=1.2, point=1}
f:load(RIM, 0.9) f:stroke({{hs[1] - 70, hs[2] + 7}, {hs[1], hs[2]}, {hs[1] + 70, hs[2] - 7}}, {pressure={0.0, 0.8, 0.0}, swell={0.1, 1, 0.1}})
f:load(RIM, 0.9) f:stroke({{hs[1] + 1, hs[2] - 30}, {hs[1], hs[2]}, {hs[1] - 1, hs[2] + 30}}, {pressure={0.0, 0.7, 0.0}, swell={0.1, 1, 0.1}})
-- crisp hoop: lit on the Sun side, a dark lower lip that shows the sheet's thinness
local RD = pile{{"lead white",0.6},{"ultramarine ash",0.6},{"bone black",0.6}}
local h = brush{kind="rigger", width=1.2, point=1}
local seg = {}
for k = 0, 40 do local th = math.pi*0.55 + k/40*math.pi*0.9 seg[#seg+1] = sp(SRX*0.995*math.cos(th), SRY*0.995*math.sin(th)) end
h:load(RIM, 0.95) h:stroke(seg, {pressure={0.3, 0.75, 0.3}, swell={0.5, 1, 1, 0.5}})
local lip = {}
for k = 0, 50 do local th = math.pi*0.05 + k/50*math.pi*0.9 lip[#lip+1] = sp(SRX*1.0*math.cos(th), SRY*1.0*math.sin(th) + 1.2) end
h:load(RD, 0.95) h:stroke(lip, {pressure={0.4, 0.6, 0.4}})

--@ chunk 9
local hs = HOTSPOT
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local cd, sdn = math.cos(dir), math.sin(dir)
local function beam(halfw0, halfw1)
  local L = math.sqrt((tip[1]-hs[1])^2 + (tip[2]-hs[2])^2)
  local nx, ny = -sdn, cd
  return poly({{hs[1] + nx*halfw0, hs[2] + ny*halfw0}, {tip[1] + nx*halfw1, tip[2] + ny*halfw1}, {tip[1] - nx*halfw1, tip[2] - ny*halfw1}, {hs[1] - nx*halfw0, hs[2] - ny*halfw0}})
end
local out = -SAILM:grow(0.5)
local BW = pile{{"lead white",1},{"Mars orange",0.06},{"cadmium yellow",0.06}}
local B1 = beam(10, 95):soften(18) * out
local B2 = beam(4, 38):soften(8) * out
work(B1, {hand="glaze", pile=BW, coverage=1.3, fill=true, clip=out, angle=dir, load=0.25, pressure={0.1, 0.22}, length={60, 140}, tool={kind="filbert", width=12, stiffness=0.2}})
work(B2, {hand="glaze", pile=BW, coverage=1.5, fill=true, clip=out, angle=dir, load=0.35, pressure={0.15, 0.3}, length={60, 140}, tool={kind="filbert", width=8, stiffness=0.2}})
blend(B1:grow(8) * out, {angle=dir, tool={kind="badger", width=12}, length={40, 90}})
-- outer corona: a fainter falloff beyond the first band
local GLW = pile{{"lead white",1},{"Mars orange",0.12},{"cadmium yellow",0.08},{"ultramarine ash",0.2}}
local radial = function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end
local o = -SUNM:grow(0.5)
local b3 = mask(function(x,y) local d = sd(x,y) return (d >= SUNR + 60 and d < SUNR + 190) and 1 or 0 end):soften(30) * o
work(b3, {hand="glaze", pile=GLW, coverage=1.0, fill=true, clip=o, angle=radial, load=0.18, pressure={0.08, 0.18}, length={40, 90}, tool={kind="filbert", width=12, stiffness=0.2}})
blend(mask(function(x,y) local d = sd(x,y) return (d >= SUNR + 50 and d < SUNR + 210) and 1 or 0 end) * o, {angle=radial, tool={kind="badger", width=12}, length={30, 60}})

--@ chunk 10
print(wait(5*24*60), drying(400,150), drying(300,450))
SKYP = pile{{"ultramarine blue",2},{"bone black",1.6},{"Mars brown",0.3},{"lead white",0.12}}
local hs = HOTSPOT
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local cd, sdn = math.cos(dir), math.sin(dir)
local nx, ny = -sdn, cd
local B = poly({{hs[1] + nx*14, hs[2] + ny*14}, {tip[1] + nx*100, tip[2] + ny*100}, {tip[1] - nx*100, tip[2] - ny*100}, {hs[1] - nx*14, hs[2] - ny*14}})
local keep = SAILM:grow(1) + B
local m = mask(function(x,y) local d = sd(x,y) return (d >= SUNR + 120) and 1 or 0 end):soften(22) - keep
work(m, {hand="body", pile=SKYP, coverage=3.2, fill=true, clip=-keep, angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) + math.pi/2 end, length={20, 45}, tool="filbert 9", edge="soft"})

--@ chunk 11
print(wait(4*24*60), drying(735,420))
local st = {735, 425}
local sl = 0.14
local function rp(rx, ry, th) return {st[1] + rx*math.cos(th), st[2] + ry*math.sin(th) + sl*rx*math.cos(th)} end
local function ell(rx, ry) local p = {} for k = 0, 47 do p[#p+1] = rp(rx, ry, k/48*2*math.pi) end return poly(p, true) end
local BZ = pile{{"bone brown",2},{"raw sienna",1},{"bone black",0.6}}
local BM = pile{{"raw sienna",2},{"yellow ochre",1},{"bone black",0.3},{"lead white",0.3}}
local BL = pile{{"yellow ochre",2},{"lead white",1.6},{"Mars orange",0.2}}
local VG = pile{{"viridian",1},{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
local top, bot = {st[1] + 8, st[2] - 58}, {st[1] - 6, st[2] + 52}
local spine = poly({{top[1] - 2.6, top[2]}, {top[1] + 2.6, top[2]}, {bot[1] + 2.6, bot[2]}, {bot[1] - 2.6, bot[2]}})
work(spine, {hand="detail", pile=BZ, coverage=3.5, fill=true, clip=spine, tool={kind="round", width=1.2}, length={2, 5}})
local ring = ell(34, 10.5) - ell(26, 6.2)
work(ring, {hand="detail", pile=BZ, coverage=3.5, fill=true, clip=ring, tool={kind="round", width=1.2}, length={2, 5}})
local lit = ring * mask(function(x,y) return (x - st[1]) < -8 and 1 or 0 end):soften(5)
work(lit, {hand="detail", pile=BM, coverage=3, fill=true, clip=ring, tool={kind="round", width=1.0}, length={2, 4}})
local hub = ell(5.5, 3.4)
work(hub, {hand="detail", pile=BM, coverage=3, fill=true, clip=hub, tool={kind="round", width=1.0}, length={1.5, 3}})

--@ chunk 12
print(wait(3*24*60), drying(735,425))

--@ chunk 13
local st = {735, 425}
local sl = 0.14
local function rp(rx, ry, th) return {st[1] + rx*math.cos(th), st[2] + ry*math.sin(th) + sl*rx*math.cos(th)} end
local BL = pile{{"yellow ochre",2},{"lead white",1.6},{"Mars orange",0.2}}
local VG = pile{{"viridian",1},{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
local top, bot = {st[1] + 8, st[2] - 58}, {st[1] - 6, st[2] + 52}
local r = brush{kind="rigger", width=0.8, point=1}
local rim = {} for k = 0, 16 do rim[#rim+1] = rp(34, 10.5, math.pi*0.55 + k/16*math.pi*0.95) end
r:load(BL, 0.95) r:stroke(rim, {pressure={0.2, 0.65, 0.2}, swell={0.4, 1, 0.5}})
r:load(BL, 0.95) r:stroke({{top[1] - 2.4, top[2] + 2}, {bot[1] - 2.4, bot[2] - 2}}, {pressure={0.45, 0.35}})
local v = brush{kind="round", width=1.1, point=0.5}
for k = 1, 5 do v:load(VG, 0.8) local q = rp(30, 8.3, -0.3 + k*0.28) v:touch(q[1], q[2], {pressure=0.4}) end
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.25}}
local d = brush{kind="round", width=0.8, point=0.5}
local th = 0.25
while th < 2.9 do
  if rand(0,1) < 0.75 then d:load(WL, 0.95) local q = rp(30, 8.3, th) d:touch(q[1], q[2], {pressure=rand(0.4, 0.55)}) end
  th = th + rand(0.1, 0.22)
end
for k = 1, 6 do d:load(WL, 0.9) local f = rand(0.1, 0.9) d:touch(top[1] + (bot[1]-top[1])*f, top[2] + (bot[2]-top[2])*f, {pressure=0.35}) end
-- tethers: from the sail's lower hoop down to the spine head
local TL = pile{{"lead white",1.2},{"yellow ochre",0.3},{"ultramarine ash",0.3},{"bone black",0.2}}
local t = brush{kind="rigger", width=0.4, point=1}
for _, th2 in ipairs({0.25, 0.6, 1.0, 1.45, 1.9, 2.35, 2.75}) do
  t:load(TL, 0.6)
  local p = sp(SRX*0.98*math.cos(th2), SRY*0.98*math.sin(th2))
  t:stroke({p, {top[1], top[2]}}, {pressure={0.28, 0.28}})
end
-- stars in the open dark
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"yellow ochre",0.2}}, pile{{"lead white",2},{"cerulean blue",0.25}}}
local hs = HOTSPOT
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local b = brush{kind="round", width=0.8, point=0.4}
local n = 0
for i = 1, 600 do
  local x, y = rand(2, 998), rand(2, 560)
  local inbeam = false
  local px, py = x - hs[1], y - hs[2]
  local along = px*math.cos(dir) + py*math.sin(dir)
  local across = math.abs(-px*math.sin(dir) + py*math.cos(dir))
  if along > -20 and across < 20 + along*0.25 then inbeam = true end
  if sd(x, y) > SUNR + 150 and SAILM:at(x, y) < 0.1 and not inbeam and ((x-735)^2 + (y-425)^2 > 70^2) then
    n = n + 1
    local u = rand(0,1)
    b:load(ST[(u < 0.5) and 1 or (u < 0.75) and 2 or 3], 0.9)
    b:touch(x, y, {pressure=(u < 0.05) and 0.75 or rand(0.25, 0.5)})
  end
end
print(n)

--@ chunk 14
local MIDC = pile{{"ultramarine blue",1.5},{"bone black",0.8},{"lead white",0.7},{"Mars orange",0.06},{"yellow ochre",0.05}}
local hs = HOTSPOT
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local cd, sdn = math.cos(dir), math.sin(dir)
local nx, ny = -sdn, cd
local B = poly({{hs[1] + nx*12, hs[2] + ny*12}, {tip[1] + nx*98, tip[2] + ny*98}, {tip[1] - nx*98, tip[2] - ny*98}, {hs[1] - nx*12, hs[2] - ny*12}})
local keep = SAILM:grow(1) + B:shrink(2)
local tang = function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) + math.pi/2 end
local band = mask(function(x,y) local d = sd(x,y) return (d >= SUNR + 95 and d < SUNR + 150) and 1 or 0 end) - keep
work(band, {hand="body", pile=MIDC, coverage=2.2, fill=false, clip=-keep, angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, length={10, 25}, tool="filbert 6"})
local seam = mask(function(x,y) local d = sd(x,y) return (d >= SUNR + 90 and d < SUNR + 160) and 1 or 0 end) - keep:grow(2)
blend(seam, {angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, tool={kind="badger", width=10}, length={20, 40}})

--@ chunk 15
-- Pass 2.1: the sail as a dark mirror; the corona as radial strokes graded into the sky
local hs = HOTSPOT
local function dh(x, y) local dx, dy = (x - hs[1]), (y - hs[2])*2.6 return math.sqrt(dx*dx + dy*dy) end
local radh = function(x,y) return math.atan(y - hs[2], x - hs[1]) end
local MR = {
 pile{{"ultramarine blue",2},{"bone black",1.5},{"lead white",0.25},{"ultramarine ash",0.3}},   -- mirror: black space
 pile{{"ultramarine blue",1.5},{"bone black",1},{"lead white",0.6},{"ultramarine ash",0.5}},    -- sheen
 pile{{"lead white",1.2},{"ultramarine ash",0.6},{"bone black",0.35},{"yellow ochre",0.08}},    -- near the blaze
}
local S = SAILM:shrink(0.8)
local function z(a, b) return S * mask(function(x,y) local d = dh(x,y) return (d >= a and d < b) and 1 or 0 end) end
work(z(150, 9999), {hand="body", pile=MR[1], coverage=3.5, fill=true, clip=S, angle=radh, length={20, 45}, tool="filbert 8"})
work(z(75, 150), {hand="body", pile=MR[2], coverage=3.5, fill=true, clip=S, angle=radh, length={12, 30}, tool="filbert 7"})
work(z(0, 75), {hand="body", pile=MR[3], coverage=3.5, fill=true, clip=S, angle=radh, length={8, 20}, tool="filbert 6"})
for _, r in ipairs({75, 150}) do
  blend(S:shrink(1) * mask(function(x,y) return math.abs(dh(x,y) - r) < 16 and 1 or 0 end), {angle=radh, tool={kind="badger", width=8}, length={15, 30}})
end
-- corona: radial strokes, pile chosen by distance from the limb with a little scatter
local C = {
 pile{{"lead white",2.5},{"cadmium yellow",0.3},{"Mars orange",0.1}},
 pile{{"lead white",2},{"yellow ochre",0.3},{"Mars orange",0.1},{"ultramarine ash",0.25}},
 pile{{"lead white",1.2},{"ultramarine ash",0.6},{"Mars orange",0.08},{"bone black",0.15}},
 pile{{"ultramarine blue",1.2},{"lead white",0.7},{"bone black",0.6},{"ultramarine ash",0.3}},
 SKYP,
}
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local cd, sdn = math.cos(dir), math.sin(dir)
local nx, ny = -sdn, cd
BEAMP = function(w0, w1) return poly({{hs[1] + nx*w0, hs[2] + ny*w0}, {tip[1] + nx*w1, tip[2] + ny*w1}, {tip[1] - nx*w1, tip[2] - ny*w1}, {hs[1] - nx*w0, hs[2] - ny*w0}}) end
local keep = SAILM:grow(1) + SUNM
local cells = {}
for y = -4, 566, 4.5 do for x = -4, 620, 4.5 do
  local xx, yy = x + rand(-2, 2), y + rand(-2, 2)
  local d = sd(xx, yy) - SUNR
  if d > 0 and d < 230 and keep:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    local t = d/230*4 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 1), 1, 5)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=5, stiffness=0.5}
local out = -keep
for i = 1, 5 do if g[i] then
  b:reload(C[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 3 == 0 then b:load(C[i], 0.9) end
    local a = math.atan(c.y - SUNC[2], c.x - SUNC[1]) + randn(0, 0.03)
    local h = rand(8, 16)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.55}, ramps={0.15, 0.35}, clip=out})
  end
end end
print(#cells)
local ring = mask(function(x,y) local d = sd(x,y) - SUNR return (d > 2 and d < 240) and 1 or 0 end) - keep:grow(1)
blend(ring, {angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, tool={kind="badger", width=10}, length={25, 50}})

--@ chunk 16
-- soften the corona's outer edge into the sky, radially
local C4 = pile{{"ultramarine blue",1.2},{"lead white",0.7},{"bone black",0.6},{"ultramarine ash",0.3}}
local keep = SAILM:grow(1) + SUNM + BEAMP(8, 90)
local out = -keep
local cells = {}
for y = -4, 566, 4.5 do for x = -4, 760, 4.5 do
  local xx, yy = x + rand(-2, 2), y + rand(-2, 2)
  local d = sd(xx, yy) - SUNR
  if d > 190 and d < 320 and keep:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    local p = (d - 190)/130 + randn(0, 0.2)
    if p < 0.5 then cells[#cells+1] = {x=xx, y=yy, i=1} elseif p < 1.0 then cells[#cells+1] = {x=xx, y=yy, i=2} end
  end
end end
local P = {C4, SKYP}
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=5, stiffness=0.5}
for i = 1, 2 do if g[i] then
  b:reload(P[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 3 == 0 then b:load(P[i], 0.9) end
    local a = math.atan(c.y - SUNC[2], c.x - SUNC[1]) + randn(0, 0.03)
    local h = rand(8, 16)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.55}, ramps={0.15, 0.35}, clip=out})
  end
end end
print(#cells)
local ring = mask(function(x,y) local d = sd(x,y) - SUNR return (d > 170 and d < 330) and 1 or 0 end) - keep:grow(1)
blend(ring, {angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, tool={kind="badger", width=10}, length={25, 50}})

--@ chunk 17
print(wait(6*24*60), drying(650,215), drying(300,300))
-- the beam: light in space, brightest at the mirror, crisp-edged, fading as it widens
local hs = HOTSPOT
local tip = {250, 600}
local dir = math.atan(tip[2] - hs[2], tip[1] - hs[1])
local L = math.sqrt((tip[1]-hs[1])^2 + (tip[2]-hs[2])^2)
local beam = BEAMP(6, 85) - SAILM:grow(1)
local BP = {
 pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.05}},
 pile{{"lead white",2.5},{"cadmium yellow",0.15},{"ultramarine ash",0.15}},
 pile{{"lead white",1.5},{"ultramarine ash",0.6},{"bone black",0.2},{"yellow ochre",0.1}},
 pile{{"lead white",0.9},{"ultramarine blue",0.8},{"bone black",0.5},{"ultramarine ash",0.4}},
}
local cells = {}
for y = 220, 566, 4 do for x = 200, 560, 4 do
  local xx, yy = x + rand(-1.5, 1.5), y + rand(-1.5, 1.5)
  if beam:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local along = ((xx - hs[1])*math.cos(dir) + (yy - hs[2])*math.sin(dir)) / L
    local t = along*3.6 + randn(0, 0.25)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 1), 1, 4)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(BP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 3 == 0 then b:load(BP[i], 0.9) end
    local h = rand(8, 16)
    b:stroke({{c.x - math.cos(dir)*h, c.y - math.sin(dir)*h}, {c.x + math.cos(dir)*h, c.y + math.sin(dir)*h}}, {pressure={0.75, 0.6}, ramps={0.1, 0.3}, clip=beam})
  end
end end
print(#cells)
blend(beam:shrink(1), {angle=dir, tool={kind="badger", width=10}, length={40, 80}})

--@ chunk 18
print(wait(6*24*60), drying(650,215), drying(400,400))
local hs = HOTSPOT
local RIM = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.05}}
local SEAML = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.2}}
local inner = SAILM:shrink(1.5)
local r = brush{kind="rigger", width=0.45, point=1}
local hub = {-40, 4}
for k = 0, 27 do
  local th = k/28 * 2*math.pi + 0.06*math.sin(k*1.7)
  r:load(SEAML, 0.6)
  r:stroke({sp(hub[1], hub[2]), sp(hub[1] + (SRX*0.55)*math.cos(th), hub[2] + (SRY*0.55)*math.sin(th)), sp(SRX*0.985*math.cos(th), SRY*0.985*math.sin(th))}, {pressure={0.1, 0.3}, clip=inner})
end
for _, f in ipairs({0.35, 0.62, 0.86}) do
  local pts = {}
  for k = 0, 64 do local th = k/64*2*math.pi pts[#pts+1] = sp(hub[1]*(1-f) + SRX*f*math.cos(th), hub[2]*(1-f) + SRY*f*math.sin(th)) end
  r:load(SEAML, 0.5)
  r:stroke(pts, {pressure={0.22, 0.22}, clip=inner})
end
-- sunward rim: a hard bright line; far side a faint cool edge
local h = brush{kind="rigger", width=1.4, point=1}
local seg = {}
for k = 0, 50 do local th = math.pi*0.45 + k/50*math.pi*1.1 seg[#seg+1] = sp(SRX*0.997*math.cos(th), SRY*0.997*math.sin(th)) end
h:load(RIM, 0.95) h:stroke(seg, {pressure={0.25, 0.8, 0.8, 0.25}, swell={0.4, 1, 1, 0.4}})
local seg2 = {}
for k = 0, 50 do local th = -math.pi*0.55 + k/50*math.pi*1.1 seg2[#seg2+1] = sp(SRX*0.997*math.cos(th), SRY*0.997*math.sin(th)) end
h:load(SEAML, 0.8) h:stroke(seg2, {pressure={0.1, 0.35, 0.35, 0.1}})
-- the blaze and its specular streak along the film
local w = brush{kind="round", width=8, point=0.3}
w:load(RIM, 0.95) w:touch(hs[1], hs[2], {pressure=0.9})
w:load(RIM, 0.95) w:touch(hs[1] + 3, hs[2] - 0.5, {pressure=0.85})
local s = brush{kind="filbert", width=3.5, stiffness=0.5}
s:load(RIM, 0.9) s:stroke({sp(-205, 9), sp(-120, 8), sp(-30, 6)}, {pressure={0.0, 0.75, 0.0}, swell={0.2, 1, 0.2}, clip=inner})
local f = brush{kind="rigger", width=1.0, point=1}
f:load(RIM, 0.9) f:stroke({sp(-270, 10), sp(-120, 8), sp(60, 4)}, {pressure={0.0, 0.6, 0.0}, swell={0.1, 1, 0.1}, clip=inner})
f:load(RIM, 0.9) f:stroke({{hs[1] + 1, hs[2] - 24}, {hs[1], hs[2]}, {hs[1] - 1, hs[2] + 24}}, {pressure={0.0, 0.6, 0.0}, swell={0.1, 1, 0.1}})
-- the station in bronze
local st = {735, 425}
local sl = 0.14
local function rp(rx, ry, th) return {st[1] + rx*math.cos(th), st[2] + ry*math.sin(th) + sl*rx*math.cos(th)} end
local function ell(rx, ry) local p = {} for k = 0, 47 do p[#p+1] = rp(rx, ry, k/48*2*math.pi) end return poly(p, true) end
local BZ = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.7}}
local BM = pile{{"burnt sienna",1},{"raw sienna",1},{"bone brown",1},{"lead white",0.25}}
local top, bot = {st[1] + 8, st[2] - 58}, {st[1] - 6, st[2] + 52}
local spine = poly({{top[1] - 2.8, top[2]}, {top[1] + 2.8, top[2]}, {bot[1] + 2.8, bot[2]}, {bot[1] - 2.8, bot[2]}})
local ring = ell(34.5, 10.8) - ell(25.6, 6.0)
local body = spine + ring + ell(5.8, 3.6)
work(body, {hand="detail", pile=BZ, coverage=4, fill=true, clip=body, tool={kind="round", width=1.2}, length={2, 5}})
local lit = body * mask(function(x,y) return (x - st[1]) < -10 and 1 or 0 end):soften(5)
work(lit, {hand="detail", pile=BM, coverage=3, fill=true, clip=body, tool={kind="round", width=1.0}, length={2, 4}})

--@ chunk 19
print(wait(5*24*60), drying(735,425))
local st = {735, 425}
local sl = 0.14
local function rp(rx, ry, th) return {st[1] + rx*math.cos(th), st[2] + ry*math.sin(th) + sl*rx*math.cos(th)} end
local top, bot = {st[1] + 8, st[2] - 58}, {st[1] - 6, st[2] + 52}
local RL = pile{{"lead white",1.5},{"raw sienna",0.6},{"burnt sienna",0.25},{"yellow ochre",0.2}}
local r = brush{kind="rigger", width=0.9, point=1}
local rim = {} for k = 0, 16 do rim[#rim+1] = rp(34.5, 10.8, math.pi*0.6 + k/16*math.pi*0.85) end
r:load(RL, 0.95) r:stroke(rim, {pressure={0.2, 0.7, 0.2}, swell={0.4, 1, 0.5}})
r:load(RL, 0.95) r:stroke({{top[1] - 2.6, top[2] + 2}, {bot[1] - 2.6, bot[2] - 2}}, {pressure={0.5, 0.35}})
local VG = pile{{"viridian",1},{"lead white",0.8},{"raw sienna",0.4},{"bone black",0.3}}
local v = brush{kind="round", width=1.2, point=0.5}
for k = 1, 5 do v:load(VG, 0.8) local q = rp(30, 8.3, -0.2 + k*0.3) v:touch(q[1], q[2], {pressure=0.4}) end
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local d = brush{kind="round", width=1.1, point=0.5}
for _, th in ipairs({0.45, 0.8, 1.05, 1.5, 1.75, 2.2, 2.5}) do d:load(WL, 0.95) local q = rp(30, 8.4, th) d:touch(q[1], q[2], {pressure=0.6}) end
for _, f in ipairs({0.2, 0.37, 0.7, 0.85}) do d:load(WL, 0.95) d:touch(top[1] + (bot[1]-top[1])*f, top[2] + (bot[2]-top[2])*f, {pressure=0.5}) end
-- stars back where the corona was repainted
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"cerulean blue",0.25}}}
local b = brush{kind="round", width=0.8, point=0.4}
local n = 0
for i = 1, 200 do
  local x, y = rand(2, 650), rand(2, 560)
  local dd = sd(x, y) - SUNR
  if dd > 190 and dd < 280 and SAILM:at(x, y) < 0.1 and BEAMP(10, 95):at(x, y) < 0.1 then
    n = n + 1 b:load(ST[(rand(0,1) < 0.6) and 1 or 2], 0.9) b:touch(x, y, {pressure=rand(0.25, 0.5)})
  end
end
print(n)

--@ chunk 20
print(wait(4*24*60))
-- soften the corona's outer edge into the sky, radially
local C4 = pile{{"ultramarine blue",1.2},{"lead white",0.7},{"bone black",0.6},{"ultramarine ash",0.3}}
local keep = SAILM:grow(1) + SUNM + BEAMP(8, 90)
local out = -keep
local cells = {}
for y = -4, 566, 4.5 do for x = -4, 760, 4.5 do
  local xx, yy = x + rand(-2, 2), y + rand(-2, 2)
  local d = sd(xx, yy) - SUNR
  if d > 280 and d < 400 and keep:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    local p = (d - 280)/120 + randn(0, 0.2)
    if p < 0.5 then cells[#cells+1] = {x=xx, y=yy, i=1} elseif p < 1.0 then cells[#cells+1] = {x=xx, y=yy, i=2} end
  end
end end
local P = {C4, SKYP}
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=5, stiffness=0.5}
for i = 1, 2 do if g[i] then
  b:reload(P[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 3 == 0 then b:load(P[i], 0.9) end
    local a = math.atan(c.y - SUNC[2], c.x - SUNC[1]) + randn(0, 0.03)
    local h = rand(8, 16)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.55}, ramps={0.15, 0.35}, clip=out})
  end
end end
print(#cells)
local ring = mask(function(x,y) local d = sd(x,y) - SUNR return (d > 270 and d < 410) and 1 or 0 end) - keep:grow(1)
blend(ring, {angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, tool={kind="badger", width=10}, length={25, 50}})

--@ chunk 21
print(wait(5*24*60))
local keep = SAILM:grow(1) + SUNM + BEAMP(8, 90)
local out = -keep
local cells = {}
for y = -4, 566, 4 do for x = 200, 900, 4 do
  local xx, yy = x + rand(-2, 2), y + rand(-2, 2)
  local d = sd(xx, yy) - SUNR
  if d > 300 and d < 440 and keep:at(clamp(xx,0,999), clamp(yy,0,562)) < 0.5 then
    local p = (d - 300)/90 + randn(0, 0.15)
    if rand(0,1) < p then cells[#cells+1] = {x=xx, y=yy} end
  end
end end
local b = brush{kind="filbert", width=5, stiffness=0.5}
b:reload(SKYP, 0.9)
for n, c in ipairs(cells) do
  if n % 3 == 0 then b:load(SKYP, 0.9) end
  local a = math.atan(c.y - SUNC[2], c.x - SUNC[1]) + randn(0, 0.03)
  local h = rand(8, 16)
  b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.55}, ramps={0.15, 0.35}, clip=out})
end
print(#cells)
local ring = mask(function(x,y) local d = sd(x,y) - SUNR return (d > 290 and d < 450) and 1 or 0 end) - keep:grow(1)
blend(ring, {angle=function(x,y) return math.atan(y - SUNC[2], x - SUNC[1]) end, tool={kind="badger", width=10}, length={25, 50}})

--@ chunk 22
print(wait(5*24*60))
local top = {743, 367}
local TL = pile{{"lead white",1.2},{"yellow ochre",0.3},{"ultramarine ash",0.3},{"bone black",0.2}}
local t = brush{kind="rigger", width=0.4, point=1}
for _, th2 in ipairs({0.25, 0.6, 1.0, 1.45, 1.9, 2.35, 2.75}) do
  t:load(TL, 0.6)
  local p = sp(SRX*0.98*math.cos(th2), SRY*0.98*math.sin(th2))
  t:stroke({p, top}, {pressure={0.28, 0.28}})
end
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",2},{"cerulean blue",0.25}}}
local b = brush{kind="round", width=0.8, point=0.4}
local n = 0
for i = 1, 300 do
  local x, y = rand(300, 999), rand(2, 560)
  local dd = sd(x, y) - SUNR
  if dd > 330 and SAILM:at(x, y) < 0.1 and BEAMP(10, 95):at(x, y) < 0.1 and ((x-735)^2 + (y-425)^2 > 70^2) then
    n = n + 1 b:load(ST[(rand(0,1) < 0.6) and 1 or 2], 0.9) b:touch(x, y, {pressure=rand(0.25, 0.5)})
  end
end
print(n)
