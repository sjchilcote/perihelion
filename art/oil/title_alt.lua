-- easel session "title_alt": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=7702, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.6},{"cobalt violet",0.3},{"lead white",0.04}}, um=45, apply="brush", texture=0.35}}}
SC = {520, -950}
SR = 1130
function sd(x, y) local dx, dy = x - SC[1], y - SC[2] return SR - math.sqrt(dx*dx + dy*dy) end  -- >0 inside the Sun
SUNM = mask(function(x,y) return sd(x,y) > 0 and 1 or 0 end)
SP = {
 pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.35}},
 pile{{"lead white",2.5},{"cadmium yellow",0.4},{"lemon chrome",0.1}},
 pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.08}},
}
local radial = function(x,y) return math.atan(y - SC[2], x - SC[1]) end
work(SUNM, {hand="body", pile=SP[1], coverage=3, fill=true, clip=SUNM, angle=radial, length={20, 45}, tool="filbert 9"})
local m2 = mask(function(x,y) return sd(x,y) > 22 and 1 or 0 end):soften(8)
work(m2, {hand="body", pile=SP[2], coverage=3, fill=true, clip=SUNM, angle=radial, length={20, 45}, tool="filbert 9"})
local m3 = mask(function(x,y) return sd(x,y) > 60 and 1 or 0 end):soften(14)
work(m3, {hand="body", pile=SP[3], coverage=3.5, fill=true, clip=SUNM, angle=radial, length={20, 45}, tool="filbert 9"})

--@ chunk 2
K = {
 pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.3}},
 pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.5}},
 pile{{"Mars orange",0.6},{"cadmium red",0.4},{"bone black",0.35},{"lead white",0.1}},
 pile{{"Mars red",0.6},{"bone black",0.9},{"cobalt violet",0.3},{"ultramarine blue",0.2}},
 pile{{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.6},{"cobalt violet",0.3},{"lead white",0.04}},
}
function cwid(x) return 70 + 60*math.exp(-((x - 520)/300)^2) end
local SKY = -SUNM:grow(0.3)
local cells = {}
for y = 30, 360, 3.2 do for x = 0, 1004, 3.4 do
  local xx, yy = x + rand(-1.3, 1.3), y + rand(-1.3, 1.3)
  local d = -sd(xx, yy)
  local w = cwid(xx)
  if d > 0 and d < w*1.2 then
    local t = d/w*4 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(t + 1), 1, 5)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3.2, stiffness=0.5}
for i = 1, 5 do if g[i] then
  b:reload(K[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(K[i], 0.9) end
    local a = math.atan(c.y - SC[2], c.x - SC[1]) + randn(0, 0.03)
    local h = rand(4, 9)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.5}, ramps={0.15, 0.35}, clip=SKY})
  end
end end
print(#cells)
local band = SKY * mask(function(x,y) local d = -sd(x,y) return (d > 1.5 and d < cwid(x)*1.3) and 1 or 0 end)
blend(band, {angle=function(x,y) return math.atan(y - SC[2], x - SC[1]) end, tool={kind="badger", width=8}, length={12, 26}})

--@ chunk 3
print(wait(6*24*60), drying(500,150), drying(500,250))
HUB = {600, 178}
local tilt = 0.05
local c, s = math.cos(tilt), math.sin(tilt)
function rpt(rx, ry, th, cx, cy) cx = cx or HUB[1] cy = cy or HUB[2] local u, v = rx*math.cos(th), ry*math.sin(th) return {cx + c*u - s*v, cy + s*u + c*v} end
local function ell(rx, ry, cx, cy) local p = {} for k = 0, 95 do p[#p+1] = rpt(rx, ry, k/96*2*math.pi, cx, cy) end return poly(p, true) end
RINGM = ell(560, 168) - ell(530, 150, HUB[1], HUB[2] - 6)
local sp = nil
SPOKES = {}
for i, th in ipairs({0.35, 1.25, 2.15, 2.95, 3.75, 4.6, 5.45}) do
  local a = rpt(30, 12, th) local b = rpt(535, 152, th, HUB[1], HUB[2] - 6)
  SPOKES[#SPOKES+1] = {a, b}
  local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
  local w0, w1 = 5, 8
  local q = poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}})
  sp = sp and (sp + q) or q
end
SPOKEM = sp
-- the spine coming down toward us, out past the left edge: its near end cropped by the frame
SPA = {HUB[1], HUB[2]}
SPB = {-60, 470}
local dx, dy = SPB[1] - SPA[1], SPB[2] - SPA[2]
local L = math.sqrt(dx*dx + dy*dy)
SPN = {-dy/L, dx/L}
local function S(t, w) return {SPA[1] + dx*t + SPN[1]*w, SPA[2] + dy*t + SPN[2]*w} end
SPT = S
local pts = {}
for k = 0, 20 do local t = k/20 pts[#pts+1] = S(t, -(28 + 150*t^1.4)) end
for k = 20, 0, -1 do local t = k/20 pts[#pts+1] = S(t, (28 + 150*t^1.4)) end
SPINEM = poly(pts, true)
HUBM = ell(70, 30)
DK = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.25}}
local all = RINGM + SPOKEM + SPINEM + HUBM
STATION = all
work(all, {hand="body", pile=DK, coverage=3.5, fill=true, clip=all, angle=0.3, length={10, 30}, tool="filbert 6"})

--@ chunk 4
print(wait(5*24*60), drying(300,350), drying(600,178))
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}
local WARM = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.4},{"bone brown",0.2}}
local BR1 = pile{{"bone brown",1.2},{"raw sienna",1},{"Mars orange",0.3},{"bone black",0.4}}
local BR2 = pile{{"raw sienna",1.2},{"Mars orange",0.6},{"yellow ochre",0.4},{"lead white",0.3},{"bone brown",0.3}}
-- slices of light across the spine where the Sun gets through between the spokes
local S = SPT
for _, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t1, t2 = sl[1], sl[2]
  local pts = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m = poly(pts) * SPINEM
  work(m, {hand="detail", pile=BR1, coverage=3.5, fill=true, clip=m, tool={kind="round", width=1.8}, length={3, 8}})
  local pts2 = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*0.55*k/8 pts2[#pts2+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*0.55*k/8 pts2[#pts2+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m2 = poly(pts2) * SPINEM
  work(m2, {hand="detail", pile=BR2, coverage=3, fill=true, clip=m, tool={kind="round", width=1.6}, length={3, 8}})
end

--@ chunk 5
print(wait(5*24*60))
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}
local WARM = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.4},{"bone brown",0.2}}
local DK2 = pile{{"bone black",2},{"bone brown",0.6}}
local S = SPT
-- vault bays: dark recesses with lit lips, only where the slices fall
local bay = brush{kind="filbert", width=3, stiffness=0.5}
local lip = brush{kind="rigger", width=0.7, point=1}
for _, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t = (sl[1] + sl[2]) / 2
  local half = 28 + 150*t^1.4
  local nb = math.floor(2 + t*6)
  for j = 1, nb do
    local w = -half + (2*half)*(j - 0.5)/nb
    local a, b = S(sl[1] + 0.006, w - half/nb*0.55), S(sl[1] + 0.006, w + half/nb*0.55)
    local a2, b2 = S(sl[2] - 0.006, w - half/nb*0.55), S(sl[2] - 0.006, w + half/nb*0.55)
    local m = poly({a, b, b2, a2})
    bay = brush{kind="filbert", width=clamp(2 + t*5, 2, 7), stiffness=0.5}
    bay:load(DK2, 0.9)
    local mid1, mid2 = S(sl[1] + 0.01, w), S(sl[2] - 0.01, w)
    bay:stroke({mid1, mid2}, {pressure={0.8, 0.8}, clip=m})
    lip = brush{kind="rigger", width=clamp(0.5 + t*1.2, 0.5, 1.6), point=1}
    lip:load(HOT, 0.9)
    lip:stroke({a, b}, {pressure={0.55, 0.55}})
  end
end
-- rims: the near arc's inner edge and the spokes catch the light on their sunward sides
local tilt = 0.05
local r = brush{kind="rigger", width=1.0, point=1}
local seg = {}
for k = 0, 60 do local th = 0.05 + k/60*3.05 seg[#seg+1] = rpt(530, 150, th, HUB[1], HUB[2] - 6) end
for i = 1, #seg - 6, 6 do
  local sub = {} for j = i, i + 6 do sub[#sub+1] = seg[j] end
  r:load(HOT, 0.9) r:stroke(sub, {pressure={0.4, 0.4}})
end
for _, sp in ipairs(SPOKES) do
  local a, b = sp[1], sp[2]
  if b[2] > a[2] - 20 then
    local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
    if ny > 0 then nx, ny = -nx, -ny end
    r:load(WARM, 0.9)
    r:stroke({{a[1] + nx*5, a[2] + ny*5}, {b[1] + nx*8, b[2] + ny*8}}, {pressure={0.3, 0.45}})
  end
end
-- the ingestion maw at the spine's near end, cropped by the frame: concentric lit rims
for i, k in ipairs({1.0, 0.82, 0.66}) do
  local pts = {}
  for j = 0, 30 do
    local th = -1.6 + j/30*1.9
    local u, v = 190*k*math.cos(th), 120*k*math.sin(th)
    pts[#pts+1] = {SPB[1] + 25 + u*0.55 - v*0.85, SPB[2] - 30 + u*0.85*0.5 + v*0.5}
  end
  r:load((i == 1) and HOT or WARM, 0.9)
  r:stroke(pts, {pressure={0.1, 0.5 - i*0.08, 0.1}, clip=SPINEM})
end
-- CUCULUS: a single spark crossing the dark
local tr = brush{kind="rigger", width=0.6, point=1}
local TR = pile{{"Mars orange",1},{"lead white",0.6},{"cadmium yellow",0.3}}
tr:load(TR, 0.7) tr:stroke({{1004, 402}, {900, 418}, {792, 436}}, {pressure={0.0, 0.25, 0.4}})
local SPK = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.1}}
local k2 = brush{kind="round", width=2.4, point=0.3}
k2:load(SPK, 0.95) k2:touch(790, 436.5, {pressure=0.75})
local f = brush{kind="rigger", width=0.6, point=1}
f:load(SPK, 0.9) f:stroke({{784, 437.5}, {790, 436.5}, {797, 435.3}}, {pressure={0.0, 0.5, 0.0}})
f:load(SPK, 0.9) f:stroke({{790.3, 432}, {790, 436.5}, {789.7, 441}}, {pressure={0.0, 0.45, 0.0}})
-- a few stars in the dark below
local ST = {pile{{"lead white",3},{"zinc white",1}}, pile{{"lead white",1},{"ultramarine blue",0.4},{"bone black",0.3}}}
local sb = brush{kind="round", width=0.7, point=0.4}
local n = 0
for i = 1, 400 do
  local x, y = rand(2, 998), rand(250, 560)
  if STATION:at(x, y) < 0.1 and -sd(x, y) > 140 then
    n = n + 1 sb:load(ST[(rand(0,1) < 0.4) and 1 or 2], 0.9) sb:touch(x, y, {pressure=rand(0.2, 0.45)})
  end
end
print(n)

--@ chunk 6
print(wait(3*24*60))
local r = brush{kind="filbert", width=2.6, stiffness=0.5}
local seg = {}
for k = 0, 60 do local th = 0.05 + k/60*3.05 seg[#seg+1] = rpt(530, 150, th, HUB[1], HUB[2] - 6) end
for i = 1, #seg - 3, 3 do
  local sub = {} for j = i, i + 3 do sub[#sub+1] = seg[j] end
  r:load(DK, 0.9) r:stroke(sub, {pressure={0.7, 0.7}, clip=SPINEM:shrink(0.5)})
end

--@ chunk 7
print(wait(3*24*60))
local S = SPT
local BR1 = pile{{"bone brown",1.2},{"raw sienna",1},{"Mars orange",0.3},{"bone black",0.4}}
local SL = nil
for _, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t1, t2 = sl[1], sl[2]
  local pts = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m = poly(pts)
  SL = SL and (SL + m) or m
end
local inside = SPINEM:shrink(0.5)
local darkpart = inside - SL
local litpart = inside * SL
local lines = {}
local seg = {}
for k = 0, 60 do local th = 0.05 + k/60*3.05 seg[#seg+1] = rpt(530, 150, th, HUB[1], HUB[2] - 6) end
lines[#lines+1] = seg
for _, sp in ipairs(SPOKES) do
  local a, b = sp[1], sp[2]
  local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
  if ny > 0 then nx, ny = -nx, -ny end
  local pts = {}
  for k = 0, 30 do local f = k/30 local w = 5 + 3*f pts[#pts+1] = {a[1] + (b[1]-a[1])*f + nx*w, a[2] + (b[2]-a[2])*f + ny*w} end
  lines[#lines+1] = pts
end
local r = brush{kind="filbert", width=3, stiffness=0.5}
for _, ln in ipairs(lines) do
  for i = 1, #ln - 3, 3 do
    local sub = {} for j = i, math.min(#ln, i + 3) do sub[#sub+1] = ln[j] end
    r:load(DK, 0.9) r:stroke(sub, {pressure={0.75, 0.75}, clip=darkpart})
    r:load(BR1, 0.9) r:stroke(sub, {pressure={0.75, 0.75}, clip=litpart})
  end
end

--@ chunk 8
print(wait(4*24*60))
local S = SPT
local BR1 = pile{{"bone brown",1.2},{"raw sienna",1},{"Mars orange",0.3},{"bone black",0.4}}
local SL = nil
for _, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t1, t2 = sl[1], sl[2]
  local pts = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m = poly(pts)
  SL = SL and (SL + m) or m
end
local inside = SPINEM:shrink(0.5)
local darkpart = inside - SL
local litpart = inside * SL
local lines = {}
local seg = {}
for k = 0, 60 do local th = 0.05 + k/60*3.05 seg[#seg+1] = rpt(530, 150, th, HUB[1], HUB[2] - 6) end
lines[#lines+1] = seg
for _, sp in ipairs(SPOKES) do
  local a, b = sp[1], sp[2]
  local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
  if ny > 0 then nx, ny = -nx, -ny end
  local pts = {}
  for k = 0, 30 do local f = k/30 local w = 5 + 3*f pts[#pts+1] = {a[1] + (b[1]-a[1])*f + nx*w, a[2] + (b[2]-a[2])*f + ny*w} end
  lines[#lines+1] = pts
end
local r = brush{kind="filbert", width=4.2, stiffness=0.5}
local r2 = brush{kind="filbert", width=3.4, stiffness=0.5}
for _, ln in ipairs(lines) do
  for i = 1, #ln - 3, 3 do
    local sub = {} for j = i, math.min(#ln, i + 3) do sub[#sub+1] = ln[j] end
    r:reload(DK, 0.9) r:stroke(sub, {pressure={0.75, 0.75}, clip=darkpart})
    r2:reload(BR1, 0.9) r2:stroke(sub, {pressure={0.75, 0.75}, clip=litpart})
  end
end

--@ chunk 9
print(wait(4*24*60))
local S = SPT
local BR1 = pile{{"bone brown",1.2},{"raw sienna",1},{"Mars orange",0.3},{"bone black",0.4}}
local SL = nil
for _, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t1, t2 = sl[1], sl[2]
  local pts = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m = poly(pts)
  SL = SL and (SL + m) or m
end
local inside = SPINEM:shrink(0.5)
local rib = nil
local seg = {}
for k = 0, 60 do local th = 0.05 + k/60*3.05 seg[#seg+1] = rpt(530, 150, th, HUB[1], HUB[2] - 6) end
rib = ribbon(seg, 5)
for _, sp in ipairs(SPOKES) do
  local a, b = sp[1], sp[2]
  local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
  if ny > 0 then nx, ny = -nx, -ny end
  rib = rib + ribbon({{a[1] + nx*5, a[2] + ny*5}, {b[1] + nx*8, b[2] + ny*8}}, 5)
end
local dk = rib * inside - SL
local lt = rib * inside * SL
work(dk, {hand="detail", pile=DK, coverage=4, fill=true, clip=dk, tool={kind="round", width=1.6}, length={2, 5}})
work(lt, {hand="detail", pile=BR1, coverage=4, fill=true, clip=lt, tool={kind="round", width=1.6}, length={2, 5}})

--@ chunk 10
-- Pass 2.1: a massive ring band, thicker tapering spokes, a bigger hub (lean darks, spine stays in front)
local function ell(rx, ry, cx, cy) local p = {} for k = 0, 119 do p[#p+1] = rpt(rx, ry, k/120*2*math.pi, cx, cy) end return poly(p, true) end
RO_ = {570, 176, HUB[1], HUB[2]}
RO2_ = {570, 176, HUB[1], HUB[2] + 14}
RI_ = {512, 136, HUB[1], HUB[2] - 8}
local front = -SPINEM:grow(0.5)
RING2 = (ell(table.unpack(RO_)) + ell(table.unpack(RO2_))) - ell(table.unpack(RI_))
local spk = nil
SPK2 = {}
for i, th in ipairs({0.35, 1.25, 2.15, 2.95, 3.75, 4.6, 5.45}) do
  local a = rpt(40, 16, th) local b = rpt(518, 140, th, RI_[3], RI_[4])
  local near = math.sin(th) > 0
  local w0, w1 = near and 11 or 8, near and 7 or 5
  local nx, ny = -(b[2]-a[2]), (b[1]-a[1]) local L = math.sqrt(nx*nx + ny*ny) nx, ny = nx/L, ny/L
  if ny > 0 then nx, ny = -nx, -ny end
  SPK2[#SPK2+1] = {a=a, b=b, nx=nx, ny=ny, w0=w0, w1=w1}
  local q = poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}})
  spk = spk and (spk + q) or q
end
SPOKE2 = spk
HUB2 = ell(84, 36)
local all = (RING2 + SPOKE2 + HUB2) * front
work(all, {hand="detail", pile=DK, coverage=4, fill=true, clip=all, tool={kind="round", width=2.2}, length={3, 8}})

--@ chunk 11
print(wait(5*24*60), drying(600,10), drying(300,330))
local front = -SPINEM:grow(0.5)
local function lerp2(a, b, f) return {a[1] + (b[1]-a[1])*f, a[2] + (b[2]-a[2])*f} end
-- ring underside scale-plates: faint bronze crescents; lit lips where the glare grazes the far arc
local PL = pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.9}}
local LIP = pile{{"Mars orange",1},{"raw sienna",0.6},{"lead white",0.35},{"bone brown",0.3}}
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}
local ringc = RING2:shrink(1.5) * front
local pb = brush{kind="round", width=1.0, point=0.6}
local lb = brush{kind="rigger", width=0.6, point=1}
local n = 0
for row = 0, 5 do
  local f = 0.12 + row*0.16
  local th = row*0.013
  while th < 2*math.pi do
    local pin = rpt(RI_[1], RI_[2], th, RI_[3], RI_[4])
    local po = math.sin(th) > 0 and rpt(RO2_[1], RO2_[2], th, RO2_[3], RO2_[4]) or rpt(RO_[1], RO_[2], th, RO_[3], RO_[4])
    local p = lerp2(pin, po, f)
    local dx, dy = po[1] - pin[1], po[2] - pin[2]
    local L = math.sqrt(dx*dx + dy*dy) + 1e-6
    local tx, ty = -dy/L, dx/L
    local h = clamp(L*0.09, 2.2, 5)
    if ringc:at(clamp(p[1],0,999), clamp(p[2],0,562)) > 0.5 then
      n = n + 1
      if n % 8 == 1 then pb:load(PL, 0.85) end
      pb:stroke({{p[1] - tx*h, p[2] - ty*h}, {p[1] + dx/L*h*0.5, p[2] + dy/L*h*0.5}, {p[1] + tx*h, p[2] + ty*h}}, {pressure={0.2, 0.4, 0.2}, clip=ringc})
      if p[2] < 70 and rand(0,1) < 0.6 then
        lb:load(LIP, 0.85)
        lb:stroke({{p[1] - tx*h*0.8 - dx/L*1.2, p[2] - ty*h*0.8 - dy/L*1.2}, {p[1] + tx*h*0.8 - dx/L*1.2, p[2] + ty*h*0.8 - dy/L*1.2}}, {pressure={0.3, 0.2}, clip=ringc})
      end
    end
    th = th + (h*2.1) / (0.5*(RI_[1] + RO_[1])) * (1 + 0.6*math.abs(math.cos(th))) * rand(0.9, 1.1)
  end
end
print("plates", n)
-- rows of tiny windows along the inner face: mostly dark, a few warm runs
local WD = pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.7}}
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
local wd = brush{kind="round", width=0.9, point=0.5}
local nw, nl = 0, 0
for _, f in ipairs({0.05, 0.11}) do
  local th = 0
  local run = 0
  while th < 2*math.pi do
    local pin = rpt(RI_[1], RI_[2], th, RI_[3], RI_[4])
    local po = math.sin(th) > 0 and rpt(RO2_[1], RO2_[2], th, RO2_[3], RO2_[4]) or rpt(RO_[1], RO_[2], th, RO_[3], RO_[4])
    local p = lerp2(pin, po, f)
    if ringc:at(clamp(p[1],0,999), clamp(p[2],0,562)) > 0.5 then
      if run == 0 and rand(0,1) < 0.035 then run = math.random(3, 8) end
      if run > 0 then run = run - 1 wd:load(WL, 0.95) wd:touch(p[1], p[2], {pressure=0.5}) nl = nl + 1
      elseif rand(0,1) < 0.6 then wd:load(WD, 0.8) wd:touch(p[1], p[2], {pressure=0.4}) nw = nw + 1 end
    end
    th = th + 0.011
  end
end
print("windows", nw, nl)
-- thin hot line on the ring's inner edge (the face looking up into the light)
local r = brush{kind="rigger", width=0.9, point=1}
local seg = {}
for k = 0, 90 do local th = -0.25 + k/90*3.6 seg[#seg+1] = rpt(RI_[1] + 1.5, RI_[2] + 1.5, th, RI_[3], RI_[4]) end
for i = 1, #seg - 5, 5 do
  local sub = {} for j = i, i + 5 do sub[#sub+1] = seg[j] end
  r:load(HOT, 0.9) r:stroke(sub, {pressure={0.4, 0.4}, clip=front * RING2:grow(1)})
end
-- spokes: rails, truss zigzag, a pipe, rim light on the upper side
local BRM = pile{{"bone brown",1},{"raw sienna",1},{"bone black",0.5}}
local WARM = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.4},{"bone brown",0.2}}
local t = brush{kind="rigger", width=0.6, point=1}
for _, s in ipairs(SPK2) do
  local a, b, nx, ny = s.a, s.b, s.nx, s.ny
  local m = SPOKE2 * front
  local function P(f, w) local ww = s.w0 + (s.w1 - s.w0)*f return {a[1] + (b[1]-a[1])*f + nx*ww*w, a[2] + (b[2]-a[2])*f + ny*ww*w} end
  t:load(BRM, 0.9) t:stroke({P(0.08, 0.55), P(0.98, 0.55)}, {pressure={0.4, 0.3}, clip=m})
  t:load(BRM, 0.9) t:stroke({P(0.08, -0.55), P(0.98, -0.55)}, {pressure={0.4, 0.3}, clip=m})
  local zz = {}
  local k = 0
  for f = 0.1, 0.97, 0.035 do k = k + 1 zz[#zz+1] = P(f, (k % 2 == 0) and 0.5 or -0.5) end
  for i = 1, #zz - 6, 6 do
    local sub = {} for j = i, i + 6 do sub[#sub+1] = zz[j] end
    t:load(BRM, 0.85) t:stroke(sub, {pressure={0.3, 0.3}, clip=m})
  end
  t:load(PL, 0.9) t:stroke({P(0.05, -0.85), P(0.99, -0.85)}, {pressure={0.5, 0.4}, clip=m})
  t:load(WARM, 0.9) t:stroke({P(0.05, 0.97), P(0.6, 0.97)}, {pressure={0.35, 0.2}, clip=m})
  t:load(WARM, 0.9) t:stroke({P(0.55, 0.97), P(1.0, 0.97)}, {pressure={0.2, 0.35}, clip=m})
end

--@ chunk 12
-- spine: scale-plates inside the lit slices; the ingestion maw at the cropped end
local S = SPT
local DKP = pile{{"bone black",2},{"bone brown",0.8}}
local LIPB = pile{{"raw sienna",1.2},{"yellow ochre",0.6},{"Mars orange",0.4},{"lead white",0.45}}
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}
local inside = SPINEM:shrink(1)
local n = 0
for si, sl in ipairs({{0.18, 0.235}, {0.36, 0.44}, {0.57, 0.64}, {0.78, 0.86}}) do
  local t1, t2 = sl[1], sl[2]
  local pts = {}
  for k = 0, 8 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, -(28 + 150*t^1.4) - 2) end
  for k = 8, 0, -1 do local t = t1 + (t2-t1)*k/8 pts[#pts+1] = S(t, (28 + 150*t^1.4) + 2) end
  local m = poly(pts) * inside
  local tm = (t1 + t2)/2
  local half = 28 + 150*tm^1.4
  local nb = math.floor(2 + tm*6)
  local sz = 3 + tm*6
  local d = brush{kind="round", width=clamp(0.5 + tm*1.4, 0.6, 1.8), point=0.6}
  local l = brush{kind="rigger", width=clamp(0.4 + tm*0.9, 0.45, 1.3), point=1}
  local row = 0
  local t = t1 + 0.004
  while t < t2 do
    row = row + 1
    local hw = 28 + 150*t^1.4
    local step = sz*2.1
    local w = -hw + ((row % 2) * 0.5 + 0.3) * step
    while w < hw do
      local bayhit = false
      for j = 1, nb do local wc = -half + (2*half)*(j - 0.5)/nb if math.abs(w - wc) < half/nb*0.62 and t > t1 + 0.008 and t < t2 - 0.008 then bayhit = true end end
      if not bayhit then
        local p = S(t, w)
        local a, b = S(t, w - sz*0.9), S(t, w + sz*0.9)
        local c = S(t + 0.004 + tm*0.004, w)
        n = n + 1
        if n % 6 == 1 then d:load(DKP, 0.9) l:load(LIPB, 0.9) end
        d:stroke({a, c, b}, {pressure={0.25, 0.5, 0.25}, clip=m})
        l:stroke({S(t - 0.002, w - sz*0.7), S(t - 0.002, w + sz*0.7)}, {pressure={0.35, 0.25}, clip=m})
      end
      w = w + step * rand(0.92, 1.08)
    end
    t = t + (0.006 + tm*0.009)
  end
end
print("spine plates", n)
-- the ingestion maw: ribbed, flared, dark inside
local L = math.sqrt((SPB[1]-SPA[1])^2 + (SPB[2]-SPA[2])^2)
local ax, ay = (SPB[1]-SPA[1])/L, (SPB[2]-SPA[2])/L
local c0 = S(0.9, 0)
local function E(rw, ra, back, th) return {c0[1] + SPN[1]*rw*math.cos(th) - ax*back + ax*ra*math.sin(th), c0[2] + SPN[2]*rw*math.cos(th) - ay*back + ay*ra*math.sin(th)} end
local function ring(rw, ra, back) local p = {} for k = 0, 59 do p[#p+1] = E(rw, ra, back, k/60*2*math.pi) end return p end
local mouth = poly(ring(150, 52, 0), true)
MAW = mouth
work(mouth, {hand="detail", pile=DKP, coverage=4, fill=true, clip=mouth, tool={kind="round", width=2.4}, length={3, 8}})
_G.MAWG = {c0=c0, ax=ax, ay=ay}

--@ chunk 13
print(wait(3*24*60))
local S = SPT
local L = math.sqrt((SPB[1]-SPA[1])^2 + (SPB[2]-SPA[2])^2)
local ax, ay = (SPB[1]-SPA[1])/L, (SPB[2]-SPA[2])/L
local c0 = S(0.79, 0)
local function E(rw, ra, back, th) return {c0[1] + SPN[1]*rw*math.cos(th) - ax*back + ax*ra*math.sin(th), c0[2] + SPN[2]*rw*math.cos(th) - ay*back + ay*ra*math.sin(th)} end
local function ring(rw, ra, back) local p = {} for k = 0, 59 do p[#p+1] = E(rw, ra, back, k/60*2*math.pi) end return p end
local mouth = poly(ring(158, 50, 0), true)
-- the spine ends at the mouth: clear what lay beyond it back to night sky
local beyond = mask(function(x, y) return ((x - c0[1])*ax + (y - c0[2])*ay > 0) and 1 or 0 end)
local SKYG = pile{{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.6},{"cobalt violet",0.3},{"lead white",0.04}}
local clear = (SPINEM:grow(2) * beyond) - mouth
work(clear, {hand="body", pile=SKYG, coverage=4, fill=true, clip=clear, angle=0.4, length={10, 25}, tool="filbert 6"})
local DKP = pile{{"bone black",2},{"bone brown",0.8}}
work(mouth, {hand="detail", pile=DKP, coverage=4, fill=true, clip=mouth, tool={kind="round", width=2.4}, length={3, 8}})
MAW = mouth
MAWG = {c0=c0, ax=ax, ay=ay}

--@ chunk 14
print(wait(4*24*60))
local S = SPT
local c0, ax, ay = MAWG.c0, MAWG.ax, MAWG.ay
local function E(rw, ra, back, th) return {c0[1] + SPN[1]*rw*math.cos(th) - ax*back + ax*ra*math.sin(th), c0[2] + SPN[2]*rw*math.cos(th) - ay*back + ay*ra*math.sin(th)} end
local BRM = pile{{"bone brown",1},{"raw sienna",1},{"bone black",0.5}}
local LIPB = pile{{"raw sienna",1.2},{"yellow ochre",0.6},{"Mars orange",0.4},{"lead white",0.45}}
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}
-- receding ribs inside the throat: each a smaller ellipse further back, lit only on its upper (sunward) arc
for i, k in ipairs({0.86, 0.72, 0.59, 0.47, 0.36, 0.26}) do
  local back = (1 - k) * 70
  local pts = {}
  for j = 0, 24 do local th = -math.pi*0.45 + j/24*math.pi*0.9 pts[#pts+1] = E(158*k, 50*k, back, th) end
  local r = brush{kind="rigger", width=clamp(1.6*k, 0.5, 1.4), point=1}
  r:load((i <= 2) and LIPB or BRM, 0.9)
  r:stroke(pts, {pressure={0.05, 0.45*k + 0.1, 0.05}, clip=MAW})
end
-- radial ribs on the flare
for j = 0, 13 do
  local th = j/14*2*math.pi
  local r = brush{kind="rigger", width=1.0, point=1}
  r:load(BRM, 0.85)
  r:stroke({E(156, 49, 0, th), E(124, 39, 10, th)}, {pressure={0.4, 0.15}, clip=MAW})
end
-- the flared lip: hot on its upper edge, dull bronze below
local top = {}
for j = 0, 30 do local th = -math.pi*0.5 + j/30*math.pi*1.0 top[#top+1] = E(159, 51, 0, th) end
local h = brush{kind="rigger", width=1.4, point=1}
h:load(HOT, 0.95) h:stroke(top, {pressure={0.1, 0.7, 0.7, 0.1}, swell={0.5, 1, 1, 0.5}})
local bot = {}
for j = 0, 30 do local th = math.pi*0.5 + j/30*math.pi*1.0 bot[#bot+1] = E(159, 51, 0, th) end
h:load(BRM, 0.9) h:stroke(bot, {pressure={0.4, 0.4}})

--@ chunk 15
local WL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
local front = -SPINEM:grow(0.5)
local ringc = RING2:shrink(1.5) * front
local d = brush{kind="round", width=1.5, point=0.4}
local n = 0
local th = 0.1
while th < 3.0 do
  if rand(0,1) < 0.09 then
    local run = math.random(3, 7)
    for k = 1, run do
      local pin = rpt(RI_[1], RI_[2], th, RI_[3], RI_[4])
      local po = rpt(RO2_[1], RO2_[2], th, RO2_[3], RO2_[4])
      local p = {pin[1] + (po[1]-pin[1])*0.09, pin[2] + (po[2]-pin[2])*0.09}
      if ringc:at(clamp(p[1],0,999), clamp(p[2],0,562)) > 0.5 then d:load(WL, 0.95) d:touch(p[1], p[2], {pressure=0.6}) n = n + 1 end
      th = th + 0.012
    end
  end
  th = th + 0.03
end
print(n)
