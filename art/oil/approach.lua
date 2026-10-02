-- easel session "approach": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=4117, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.15}, {pile={{"lead white",1},{"Mars brown",2},{"ultramarine blue",2},{"bone black",0.5}}, um=40, apply="brush", texture=0.4}}} print(W,H)

--@ chunk 2
-- geometry globals for the station
GC = {720, 320}
GA = -0.2
GU = {math.cos(GA), math.sin(GA)}
GV = {-math.sin(GA), math.cos(GA)}
SE, CE = 0.34, 0.94   -- sin/cos of view elevation
GD = 2400
function P(t, R, ax)   -- ring-frame point: angle t, radius R, axial ax -> screen x,y
  local d = R * math.sin(t) * CE + ax * SE
  local s = 1 / (1 - d / GD)
  local a = R * math.cos(t)
  local b = R * math.sin(t) * SE - ax * CE
  return GC[1] + s * (a * GU[1] + b * GV[1]), GC[2] + s * (a * GU[2] + b * GV[2]), s
end
function arc(t0, t1, R, ax, n)
  local pts = {}
  n = n or 80
  for i = 0, n do
    local t = t0 + (t1 - t0) * i / n
    local x, y = P(t, R, ax)
    pts[#pts + 1] = {x, y}
  end
  return pts
end
RO, RI, HW = 540, 495, 40   -- outer radius, inner radius, half axial width
-- spine: centre line point at axial ax, and its screen half-width
function SP(ax)
  local x, y, s = P(0, 0, ax)
  return x, y, s
end
SR = 58

--@ chunk 3

for _, t in ipairs({0, math.pi/4, math.pi/2, 3*math.pi/4, math.pi, 5*math.pi/4, 3*math.pi/2, 7*math.pi/4}) do
  local x1,y1 = P(t, RO, HW) local x2,y2 = P(t, RO, -HW) local x3,y3=P(t,RI,HW) local x4,y4=P(t,RI,-HW)
  print(string.format("t=%.2f  outer+ %.0f,%.0f outer- %.0f,%.0f inner+ %.0f,%.0f inner- %.0f,%.0f", t, x1,y1,x2,y2,x3,y3,x4,y4))
end
for _, ax in ipairs({-250,-150,0,150,300,400}) do local x,y,s=SP(ax) print(ax, math.floor(x), math.floor(y), s) end

--@ chunk 4
local h = pencil("HB")
local tau = 2*math.pi
h:line(arc(0, tau, RO, HW, 160), {pressure=0.5})
h:line(arc(0, math.pi, RO, -HW, 100), {pressure=0.5})
h:line(arc(math.pi, tau, RI, HW, 100), {pressure=0.5})
h:line(arc(math.pi, tau, RI, -HW, 100), {pressure=0.5})
local L, R = {}, {}
for ax = -260, 460, 20 do
  local x, y, s = SP(ax)
  L[#L+1] = {x - SR*s*GU[1], y - SR*s*GU[2]}
  R[#R+1] = {x + SR*s*GU[1], y + SR*s*GU[2]}
end
h:line(L, {pressure=0.5})
h:line(R, {pressure=0.5})

--@ chunk 5
GC = {640, 290}
GA = -0.25
GU = {math.cos(GA), math.sin(GA)}
GV = {-math.sin(GA), math.cos(GA)}
SE = 0.30
CE = math.sqrt(1 - SE*SE)
GD = 1300
RO, RI, HW, SR = 520, 450, 75, 80
function P(t, R, ax)
  local d = R * math.sin(t) * CE + ax * SE
  local s = 1 / (1 - d / GD)
  local a = R * math.cos(t)
  local b = R * math.sin(t) * SE - ax * CE
  return GC[1] + s * (a * GU[1] + b * GV[1]), GC[2] + s * (a * GU[2] + b * GV[2]), s
end
function arc(t0, t1, R, ax, n)
  local pts = {}
  n = n or 120
  for i = 0, n do
    local t = t0 + (t1 - t0) * i / n
    local x, y = P(t, R, ax)
    pts[#pts + 1] = {x, y}
  end
  return pts
end
function rev(p) local q = {} for i = #p, 1, -1 do q[#q+1] = p[i] end return q end
function cat(a, b) local q = {} for _, v in ipairs(a) do q[#q+1] = v end for _, v in ipairs(b) do q[#q+1] = v end return q end
-- spine: point on the axis at axial ax, offset across by w (in units of spine radius, -1 left .. 1 right)
function SPt(ax, w)
  local s = 1 / (1 - ax * SE / GD)
  local x = GC[1] - s * ax * CE * GV[1]
  local y = GC[2] - s * ax * CE * GV[2]
  return x + w * SR * s * GU[1], y + w * SR * s * GU[2], s
end
function spine_poly(w0, w1, a0, a1)
  local L, R = {}, {}
  for ax = a0, a1, 10 do
    local x, y = SPt(ax, w0) L[#L+1] = {x, y}
    x, y = SPt(ax, w1) R[#R+1] = {x, y}
  end
  return cat(L, rev(R))
end
-- masks of the big shapes
function M_near()  return poly(cat(arc(-0.25, math.pi + 0.02, RO, HW, 160), rev(arc(-0.25, math.pi + 0.02, RO, -HW, 160)))) end
function M_top()   return poly(cat(arc(0, 2*math.pi, RO, HW, 240), rev(arc(0, 2*math.pi, RI, HW, 240)))) end
function M_farin() return poly(cat(arc(math.pi - 0.05, 2*math.pi + 0.05, RI, HW, 160), rev(arc(math.pi - 0.05, 2*math.pi + 0.05, RI, -HW, 160)))) end
function M_spine() return poly(spine_poly(-1, 1, -400, 700)) end
function M_station() return M_near() + M_top() + M_farin() + M_spine() end

--@ chunk 6
local m = M_station() print(m:area(), W*H) for _,t in ipairs({0,0.5,1,1.57,2.2,2.8,3.14,3.6,4.2,4.71,5.3,5.8}) do local x,y=P(t,RO,HW) local x2,y2=P(t,RO,-HW) print(string.format("%.2f %4.0f %4.0f | %4.0f %4.0f",t,x,y,x2,y2)) end print(SPt(0,1)) print(SPt(300,-1))

--@ chunk 7
K1 = pile{{"bone black",2},{"ultramarine blue",1}}
K2 = pile{{"bone black",2},{"ultramarine blue",1.2},{"lead white",0.3},{"cobalt violet",0.2}}
K3 = pile{{"bone black",1.5},{"ultramarine blue",1},{"lead white",0.6},{"Mars brown",0.3}}
local sky = -(M_station():shrink(3))
local r1 = sky * mask(function(x,y) return x < 470 and 1 or 0 end):soften(30)
local r2 = sky * mask(function(x,y) return (x >= 430 and x < 820) and 1 or 0 end):soften(30)
local r3 = sky * mask(function(x,y) return x >= 780 and 1 or 0 end):soften(30)
work(r1, {hand="broad", pile=K1, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.15})
work(r2, {hand="broad", pile=K2, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.15})
work(r3, {hand="broad", pile=K3, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.15})

--@ chunk 8
function M_station() return M_near():grow(1.5) + M_top():grow(1.5) + M_farin():grow(1.5) + M_spine():grow(1.5) end

--@ chunk 9
K2 = pile{{"bone black",2},{"ultramarine blue",1.2},{"cobalt violet",0.15},{"lead white",0.08}}
K3 = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.4},{"lead white",0.2}}
local sky = -(M_station():shrink(3))
local r2 = sky * mask(function(x,y) return (x >= 410 and x < 830) and 1 or 0 end):soften(40)
local r3 = sky * mask(function(x,y) return x >= 790 and 1 or 0 end):soften(40)
work(r2, {hand="broad", pile=K2, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.15})
work(r3, {hand="broad", pile=K3, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.15})

--@ chunk 10
print(wait(24*60)) print(drying(200,100), drying(480,100), drying(900,250))

--@ chunk 11
-- near-face lookup: x -> t (t in [0.6, 2.8], x monotonic there)
NT = {}
for i = 0, 440 do
  local t = 0.6 + (2.8 - 0.6) * i / 440
  local x, y = P(t, RO, 0)
  NT[#NT+1] = {t, x}
end
function near_t(x)
  if x >= NT[1][2] then return NT[1][1] end
  for i = 2, #NT do
    if NT[i][2] <= x then
      local a, b = NT[i-1], NT[i]
      local f = (x - a[2]) / (b[2] - a[2])
      return a[1] + f * (b[1] - a[1])
    end
  end
  return 2.8
end
function ring_tangent(t, R, ax)
  local x1, y1 = P(t - 0.01, R, ax)
  local x2, y2 = P(t + 0.01, R, ax)
  return math.atan(y2 - y1, x2 - x1)
end
-- stroke angle along the near face (pointing leftward as t increases)
function near_angle(x, y) return ring_tangent(near_t(x), RO, 0) end
SPINE_ANG = math.atan(-GV[2], -GV[1])

--@ chunk 12
print(near_t(1000), near_t(700), near_t(300), near_t(120), near_angle(700,450), SPINE_ANG)

--@ chunk 13
D = pile{{"bone black",3},{"bone brown",1}}
local near = M_near()
local nearlit = near * mask(function(x,y) return x > 285 and 1 or 0 end)
local spinelit = poly(spine_poly(0.3, 1.05, -400, 700))
local dark = (M_top():grow(1.5) + M_farin():grow(1.5) + M_spine():grow(1.5) + near:grow(1.5)) - nearlit:shrink(1) - spinelit:shrink(1)
work(dark, {hand="body", pile=D, coverage=3, fill=true, edge="firm", angle=function(x,y) return near_angle(x,y) end})

--@ chunk 14
B1 = pile{{"burnt sienna",2},{"bone black",1.5},{"yellow ochre",0.5}}
B2 = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6}}
B3 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
local near = M_near()
local function band(a, b) return near * mask(function(x,y) return (x > a and x <= b) and 1 or 0 end) end
local ang = function(x,y) return near_angle(x,y) end
work(band(282, 470), {hand="body", pile=B1, coverage=3, fill=true, edge="firm", angle=ang})
work(band(450, 700), {hand="body", pile=B2, coverage=3, fill=true, edge="firm", angle=ang})
work(band(680, 1000), {hand="body", pile=B3, coverage=3, fill=true, edge="firm", angle=ang})

--@ chunk 15
local near = M_near():shrink(2) * mask(function(x,y) return x > 280 and 1 or 0 end)
blend(near, {angle=function(x,y) return near_angle(x,y) end})
blend(near, {angle=function(x,y) return near_angle(x,y) + 0.3 end})

--@ chunk 16
local s = M_spine()
local a = poly(spine_poly(0.28, 0.58, -400, 700)) * s
local b = poly(spine_poly(0.52, 1.1, -400, 700)) * s
local nearf = M_near():grow(1)
work(a - nearf, {hand="body", pile=B2, coverage=3, fill=true, edge="firm", angle=SPINE_ANG, clip=-nearf})
work(b - nearf, {hand="body", pile=B3, coverage=3, fill=true, edge="firm", angle=SPINE_ANG, clip=-nearf})
blend(poly(spine_poly(0.3, 0.97, -400, 700)) - nearf, {angle=SPINE_ANG})

--@ chunk 17
print(wait(2*24*60)) print(drying(560,150), drying(400,300), drying(800,450), drying(650,100))

--@ chunk 18
print(wait(4*24*60)) print(drying(560,150), drying(400,300), drying(100,100), drying(650,100))

--@ chunk 19
local s = M_spine()
local nearf = M_near():grow(1)
local a = poly(spine_poly(-0.55, -0.18, -400, 700)) * s - nearf
local b = poly(spine_poly(-0.24, 0.36, -400, 700)) * s - nearf
work(a, {hand="body", pile=B1, coverage=2.5, fill=true, edge="soft", angle=SPINE_ANG, clip=-nearf})
work(b, {hand="body", pile=B2, coverage=3, fill=true, edge="firm", angle=SPINE_ANG, clip=-nearf})
blend(poly(spine_poly(-0.62, 0.34, -400, 700)) - nearf, {angle=SPINE_ANG})

--@ chunk 20
PHI = (math.sqrt(5) - 1) / 2
local function dirs(p) return math.cos(p.at), math.sin(p.at), math.cos(p.aa), math.sin(p.aa) end
function scale_bodies(pl, w_scale, dip_every)
  local cur, n = nil, 0
  local b = brush{kind="filbert", width=4, stiffness=0.5}
  local bw = 4
  for _, p in ipairs(pl) do
    local want = math.max(1.2, p.Lt * (w_scale or 0.85))
    if math.abs(want - bw) > 0.6 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
    if p.pile ~= cur or n >= (dip_every or 5) then b:reload(p.pile, 0.75) cur = p.pile n = 0 end
    n = n + 1
    local tc, ts, ac, as_ = dirs(p)
    local hu, hd = p.La * 0.5, p.La * 0.42
    b:stroke({{p.x - ac*hu, p.y - as_*hu}, {p.x + ac*hd, p.y + as_*hd}}, {pressure={0.8, 0.25}, ramps={0.1, 0.5}})
  end
end
function scale_shadows(pl, pile_, w, pr)
  local b = brush{kind="round", width=w, point=0.7, stiffness=0.4}
  b:load(pile_, 0.8)
  local n = 0
  for _, p in ipairs(pl) do
    n = n + 1
    if n % 6 == 0 then b:load(pile_, 0.8) end
    local tc, ts, ac, as_ = dirs(p)
    local bx, by = p.x + ac*p.La*0.47, p.y + as_*p.La*0.47
    local h = p.Lt * 0.42
    b:stroke({{bx - tc*h - ac*p.La*0.18, by - ts*h - as_*p.La*0.18}, {bx, by}, {bx + tc*h - ac*p.La*0.18, by + ts*h - as_*p.La*0.18}},
      {pressure={pr*0.6, pr*0.4}, swell={0.5, 1.3, 0.5}, ramps={0.2, 0.3}})
  end
end
function scale_glints(pl, pile_, w, pr, side)
  side = side or 1
  local b = brush{kind="round", width=w, point=0.8, stiffness=0.4}
  b:load(pile_, 0.8)
  local n = 0
  for _, p in ipairs(pl) do
    n = n + 1
    if n % 6 == 0 then b:load(pile_, 0.8) end
    local tc, ts, ac, as_ = dirs(p)
    local r = side * p.Lt * 0.36
    local q = p.gl or 1
    b:stroke({{p.x + tc*r*0.7 - ac*p.La*0.38, p.y + ts*r*0.7 - as_*p.La*0.38},
              {p.x + tc*r, p.y + ts*r - as_*p.La*0.05},
              {p.x + tc*r*0.75 + ac*p.La*0.3, p.y + ts*r*0.75 + as_*p.La*0.3}},
      {pressure={pr*q*0.6, pr*q*0.2}, ramps={0.15, 0.5}})
  end
end

--@ chunk 21
PD = pile{{"bone black",2},{"burnt sienna",1}}
P2 = pile{{"burnt sienna",2},{"raw sienna",1},{"bone black",1}}
P1 = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.5}}
P3 = pile{{"yellow ochre",2},{"burnt sienna",1},{"bone black",0.35}}
P4 = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8}}
LI = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}
local nz = noise{seed=21, period=70, octaves=3}
local pl = {}
local d = 9
local ds = 0.866*d*d/(2*HW+10)   -- arc length per plate
local k = 0
local s0 = 1.02*RO
while true do
  k = k + 1
  local s = s0 + k*ds
  local t = s / RO
  if t > 3.13 then break end
  local ax = HW - ((k*PHI) % 1) * (2*HW + 10)
  local x, y = P(t, RO, ax)
  if x > -10 and x < 1010 and y < 575 then
    local xa, ya = P(t + 0.002, RO, ax)
    local xb, yb = P(t, RO, ax - 1)
    local lt = math.sqrt((xa-x)^2 + (ya-y)^2) / (0.002*RO)
    local la = math.sqrt((xb-x)^2 + (yb-y)^2)
    local L = (math.cos(t) + 0.6*math.sin(t)) / 1.166
    local p = {x=x + randn(0,0.4), y=y + randn(0,0.4), at=math.atan(y - ya, x - xa), aa=math.atan(yb - y, xb - x),
               Lt=d*1.12*lt*rand(0.88,1.12), La=d*1.2*la*rand(0.88,1.12), ax=ax, L=L}
    local v = L + 0.22*nz(x,y) + randn(0,0.1)
    if v < 0.03 then p.pile = PD elseif v < 0.3 then p.pile = P2 elseif v < 0.55 then p.pile = P1 elseif v < 0.82 then p.pile = P3 else p.pile = P4 end
    p.gl = clamp(0.35 + 0.8*L, 0.2, 1.1)
    pl[#pl+1] = p
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
print(#pl)
NEAR_PLATES = pl
scale_bodies(pl)
scale_shadows(pl, D, 1.8, 0.7)
local lt = {}
for _, p in ipairs(pl) do if p.L > -0.08 then lt[#lt+1] = p end end
scale_glints(lt, LI, 1.3, 0.6)
print(#lt)

--@ chunk 22
print(wait(4*24*60)) print(drying(500,500), drying(900,400), drying(640,200))

--@ chunk 23
G1 = pile{{"bone brown",2},{"ultramarine blue",1},medium=0.7}
G2 = pile{{"bone brown",2},{"ultramarine blue",1},{"bone black",0.5},medium=0.5}
G3 = pile{{"burnt sienna",1},{"bone brown",1},medium=0.75}
G3t = pile{{"burnt sienna",1},{"bone brown",1},medium=0.88}
local near = M_near()
local function band(a, b) return near * mask(function(x,y) return (x > a and x <= b) and 1 or 0 end):soften(25) end
local ang = function(x,y) return near_angle(x,y) end
work(band(-20, 340), {hand="glaze", pile=G2, coverage=2, fill=true, clip=near, angle=ang})
work(band(310, 570), {hand="glaze", pile=G1, coverage=1.6, fill=true, clip=near, angle=ang})
work(band(530, 800), {hand="glaze", pile=G3, coverage=1.4, fill=true, clip=near, angle=ang})
work(band(770, 1020), {hand="glaze", pile=G3t, coverage=1.0, fill=true, clip=near, angle=ang})

--@ chunk 24
print(wait(5*24*60)) print(drying(120,420), drying(250,500), drying(450,500), drying(900,450))

--@ chunk 25
print(wait(4*24*60)) print(drying(120,420), drying(250,500), drying(450,500), drying(900,450))

--@ chunk 26
D2 = pile{{"bone black",3},{"bone brown",1},{"ultramarine blue",0.4}}
local near = M_near()
local m = near * mask(function(x,y) return x < 255 and 1 or 0 end)
work(m, {hand="body", pile=D2, coverage=3, fill=true, edge="firm", clip=near, angle=function(x,y) return near_angle(x,y) end})
local m2 = near * mask(function(x,y) return (x >= 240 and x < 330) and 1 or 0 end)
work(m2, {hand="scumble", pile=D2, coverage=1.5, clip=near, angle=function(x,y) return near_angle(x,y) end, load=0.4})

--@ chunk 27
function leftmost_t(R, ax)
  local bt, bx = 0, 1e9
  for i = 0, 400 do
    local t = 2.0 + 1.3 * i / 400
    local x = P(t, R, ax)
    if x < bx then bx, bt = x, t end
  end
  return bt
end
function M_near()
  local tt = leftmost_t(RO, HW)
  local tb = leftmost_t(RO, -HW)
  return poly(cat(arc(-0.25, tt, RO, HW, 160), rev(arc(-0.25, tb, RO, -HW, 160))))
end

--@ chunk 28
print(leftmost_t(RO,HW), leftmost_t(RO,-HW), P(leftmost_t(RO,HW),RO,HW), P(leftmost_t(RO,-HW),RO,-HW))

--@ chunk 29
local near = M_near()
local m = near * mask(function(x,y) return x < 200 and 1 or 0 end)
work(m, {hand="body", pile=D2, coverage=3, fill=true, edge="firm", clip=near:grow(1), angle=function(x,y) return near_angle(x,y) end})

--@ chunk 30
local st = M_near() + M_top() + M_farin() + M_spine()
local sky = -(st:grow(1.5)):shrink(0)
sky = -(M_near():grow(2) + M_top():grow(2) + M_farin():grow(2) + M_spine():grow(2))
local r = sky * mask(function(x,y) return x > 390 and 1 or 0 end):soften(30)
work(r, {hand="body", pile=K1, coverage=3, fill=true, angle=0.08, edge="firm", angle_jitter=0.2, clip=sky})

--@ chunk 31
HR = 150
function M_hub()
  local top = poly(arc(0, 2*math.pi, HR, 0, 160))
  local side = poly(cat(arc(-0.2, math.pi + 0.2, HR, 0, 100), rev(arc(-0.2, math.pi + 0.2, HR, -16, 100))))
  local dome = poly(arc(0, 2*math.pi, HR*0.62, 22, 120))
  return top + side + dome
end
function M_spine_up() return poly(spine_poly(-1, 1, 0, 700)) end
function M_spine_low() return poly(spine_poly(-1, 1, -400, 0)) end

--@ chunk 32
local h = M_hub() print(h:area()) local x,y = P(0,HR,0) print(x,y) x,y = P(math.pi/2,HR,0) print(x,y) x,y=P(math.pi,HR,0) print(x,y) x,y=P(3*math.pi/2,HR,0) print(x,y)

--@ chunk 33
local hub = M_hub()
local back = poly(arc(math.pi, 2*math.pi, HR, 0, 100)) - poly(arc(0, 2*math.pi, HR*0.62, 22, 120))
local occl = M_spine_up() * back
HUB = hub - occl
work(HUB, {hand="body", pile=D, coverage=3, fill=true, edge="firm", clip=HUB:grow(0.5), angle=GA})

--@ chunk 34
print(wait(5*24*60)) print(drying(530,300), drying(760,270), drying(900,30))

--@ chunk 35
work(HUB, {hand="body", pile=D, coverage=3, fill=true, edge="firm", clip=HUB:grow(0.5), angle=GA}) print(wait(3*24*60))

--@ chunk 36
PHI = (math.sqrt(5) - 1) / 2
local function dirs(p) return math.cos(p.at), math.sin(p.at), math.cos(p.aa), math.sin(p.aa) end
function scale_bodies(pl, w_scale, dip_every)
  local cur, n = nil, 0
  local b = brush{kind="filbert", width=4, stiffness=0.5}
  local bw = 4
  for _, p in ipairs(pl) do
    local want = math.max(1.2, p.Lt * (w_scale or 0.85))
    if math.abs(want - bw) > 0.6 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
    if p.pile ~= cur or n >= (dip_every or 5) then b:reload(p.pile, 0.75) cur = p.pile n = 0 end
    n = n + 1
    local tc, ts, ac, as_ = dirs(p)
    local hu, hd = p.La * 0.5, p.La * 0.42
    b:stroke({{p.x - ac*hu, p.y - as_*hu}, {p.x + ac*hd, p.y + as_*hd}}, {pressure={0.8, 0.25}, ramps={0.1, 0.5}, clip=CLIP})
  end
end
function scale_shadows(pl, pile_, w, pr)
  local b = brush{kind="round", width=w, point=0.7, stiffness=0.4}
  b:load(pile_, 0.8)
  local n = 0
  for _, p in ipairs(pl) do
    n = n + 1
    if n % 6 == 0 then b:load(pile_, 0.8) end
    local tc, ts, ac, as_ = dirs(p)
    local bx, by = p.x + ac*p.La*0.47, p.y + as_*p.La*0.47
    local h = p.Lt * 0.42
    b:stroke({{bx - tc*h - ac*p.La*0.18, by - ts*h - as_*p.La*0.18}, {bx, by}, {bx + tc*h - ac*p.La*0.18, by + ts*h - as_*p.La*0.18}},
      {pressure={pr*0.6, pr*0.4}, swell={0.5, 1.3, 0.5}, ramps={0.2, 0.3}, clip=CLIP})
  end
end
function scale_glints(pl, pile_, w, pr, side)
  side = side or 1
  local b = brush{kind="round", width=w, point=0.8, stiffness=0.4}
  b:load(pile_, 0.8)
  local n = 0
  for _, p in ipairs(pl) do
    n = n + 1
    if n % 6 == 0 then b:load(pile_, 0.8) end
    local tc, ts, ac, as_ = dirs(p)
    local r = side * p.Lt * 0.36
    local q = p.gl or 1
    b:stroke({{p.x + tc*r*0.7 - ac*p.La*0.38, p.y + ts*r*0.7 - as_*p.La*0.38},
              {p.x + tc*r, p.y + ts*r - as_*p.La*0.05},
              {p.x + tc*r*0.75 + ac*p.La*0.3, p.y + ts*r*0.75 + as_*p.La*0.3}},
      {pressure={pr*q*0.6, pr*q*0.2}, ramps={0.15, 0.5}, clip=CLIP})
  end
end

--@ chunk 37
SPV = M_spine() - M_near():grow(1) - HUB
CLIP = SPV
local nz = noise{seed=37, period=60, octaves=3}
local GOLD = math.pi * (3 - math.sqrt(5))
local d = 8.5
local dz = d*d*0.866 / (2*math.pi*SR)
local pl = {}
local k = 0
while true do
  k = k + 1
  local ax = -230 + k*dz
  if ax > 360 then break end
  local th = (k*GOLD) % (2*math.pi)
  if th > math.pi then th = th - 2*math.pi end
  local c = math.cos(th)
  if c > 0.08 then
    local w = math.sin(th)
    local x, y, s = SPt(ax, w)
    if SPV:at(x, y) > 0.2 or SPV:at(x, y - 4) > 0.2 then
      local L = (w + 0.6*c) / 1.166
      local p = {x=x + randn(0,0.3), y=y + randn(0,0.3), at=GA, aa=math.atan(GV[2], GV[1]), Lt=d*1.12*c*s*rand(0.88,1.12), La=d*1.2*CE*s*rand(0.88,1.12), ax=ax, L=L}
      local v = L + 0.2*nz(x,y) + randn(0,0.1)
      if v < 0.03 then p.pile = PD elseif v < 0.3 then p.pile = P2 elseif v < 0.55 then p.pile = P1 elseif v < 0.82 then p.pile = P3 else p.pile = P4 end
      p.gl = clamp(0.35 + 0.8*L, 0.2, 1.1)
      pl[#pl+1] = p
    end
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
print(#pl)
SPINE_PLATES = pl
scale_bodies(pl)
scale_shadows(pl, D, 1.6, 0.7)
local lt = {}
for _, p in ipairs(pl) do if p.L > -0.05 then lt[#lt+1] = p end end
scale_glints(lt, LI, 1.2, 0.6)
CLIP = nil

--@ chunk 38
print(wait(5*24*60)) print(drying(600,100), drying(680,350), drying(560,250))

--@ chunk 39
print(wait(3*24*60)) print(drying(600,100), drying(540,60))

--@ chunk 40
Gd = pile{{"bone brown",2},{"bone black",0.5},{"ultramarine ash",1},medium=0.8}
Gn = pile{{"bone brown",1},{"ultramarine ash",1},medium=0.85}
local spv = SPV
local function sp(w0, w1) return poly(spine_poly(w0, w1, -400, 700)) * spv end
local ang = SPINE_ANG
work(sp(-1.1, 0.4):soften(6) * spv, {hand="glaze", pile=Gd, coverage=1.4, fill=true, clip=spv, angle=ang})
work(sp(-1.1, -0.25):soften(6) * spv, {hand="glaze", pile=Gd, coverage=1.4, fill=true, clip=spv, angle=ang})
work(sp(0.3, 1.1), {hand="glaze", pile=Gn, coverage=1.1, fill=true, clip=spv, angle=ang})
local near = M_near()
local function band(a, b) return near * mask(function(x,y) return (x > a and x <= b) and 1 or 0 end):soften(25) end
local nang = function(x,y) return near_angle(x,y) end
work(band(300, 590), {hand="glaze", pile=Gd, coverage=1.5, fill=true, clip=near, angle=nang})
work(band(540, 1020), {hand="glaze", pile=Gn, coverage=1.1, fill=true, clip=near, angle=nang})

--@ chunk 41
print(wait(6*24*60)) print(drying(530,100), drying(400,500), drying(900,450))

--@ chunk 42
print(wait(5*24*60)) print(drying(530,100), drying(400,500), drying(900,450), drying(600,300))

--@ chunk 43
GK = pile{{"bone black",2},{"bone brown",1},medium=0.6}
local spv = SPV
local function sp(w0, w1) return (poly(spine_poly(w0, w1, -400, 700)):soften(5)) * spv end
local ang = SPINE_ANG
work(sp(-1.2, -0.3), {hand="glaze", pile=GK, coverage=2, fill=true, clip=spv, angle=ang})
work(sp(-1.2, 0.1), {hand="glaze", pile=GK, coverage=1.4, fill=true, clip=spv, angle=ang})
work(sp(0.0, 0.42), {hand="glaze", pile=GK, coverage=0.8, fill=true, clip=spv, angle=ang})
local near = M_near()
local function band(a, b) return near * mask(function(x,y) return (x > a and x <= b) and 1 or 0 end):soften(25) end
local nang = function(x,y) return near_angle(x,y) end
work(band(60, 390), {hand="glaze", pile=GK, coverage=2, fill=true, clip=near, angle=nang})
work(band(60, 570), {hand="glaze", pile=GK, coverage=1.4, fill=true, clip=near, angle=nang})
work(band(540, 770), {hand="glaze", pile=GK, coverage=0.8, fill=true, clip=near, angle=nang})

--@ chunk 44
S1 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.12}}
S2 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.3},{"yellow ochre",0.1}}
S3 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.7},{"yellow ochre",0.2}}
S4 = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",1},{"yellow ochre",0.3}}
SUN = {1090, 235}
SKY = -(M_near():grow(2) + M_top():grow(2) + M_farin():grow(2) + M_spine():grow(2) + M_hub():grow(2))
local function ring(r0, r1, soft) return SKY * mask(function(x,y) local d = math.sqrt((x-SUN[1])^2 + (y-SUN[2])^2) return (d >= r0 and d < r1) and 1 or 0 end):soften(soft or 20) end
local ang = function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
work(ring(260, 420, 30), {hand="body", pile=S1, coverage=3, fill=true, clip=SKY, angle=ang, edge="firm"})
work(ring(170, 290), {hand="body", pile=S2, coverage=3, fill=true, clip=SKY, angle=ang, edge="firm"})
work(ring(100, 190), {hand="body", pile=S3, coverage=3, fill=true, clip=SKY, angle=ang, edge="firm"})
work(ring(0, 115), {hand="body", pile=S4, coverage=3, fill=true, clip=SKY, angle=ang, edge="firm"})
blend(ring(80, 440, 30), {angle=ang})
blend(ring(80, 440, 30), {angle=function(x,y) return ang(x,y) + 0.4 end})

--@ chunk 45
LT1 = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.2}}
LT2 = pile{{"lead white",3},{"lemon chrome",0.3}}
P5 = pile{{"yellow ochre",2},{"lead white",1.2},{"raw sienna",0.5}}
local nz = noise{seed=45, period=50, octaves=3}
local function relight(list, Lmin, clipm)
  local sel = {}
  for _, p in ipairs(list) do
    local v = p.L + 0.25*nz(p.x, p.y) + randn(0, 0.08)
    if v > Lmin then
      local q = {x=p.x, y=p.y - p.La*0.08, at=p.at, aa=p.aa, Lt=p.Lt*0.72, La=p.La*0.7, ax=p.ax, L=p.L}
      if v > Lmin + 0.3 then q.pile = LT1 elseif v > Lmin + 0.12 then q.pile = P5 else q.pile = P4 end
      q.gl = 1
      sel[#sel+1] = q
    end
  end
  table.sort(sel, function(a,b) return a.ax < b.ax end)
  CLIP = clipm
  scale_bodies(sel, 0.85, 4)
  scale_glints(sel, LT2, 1.1, 0.7)
  CLIP = nil
  return #sel
end
print(relight(SPINE_PLATES, 0.72, SPV))
print(relight(NEAR_PLATES, 0.62, M_near()))

--@ chunk 46
function Lnear(x, y)
  local t = near_t(x)
  return (math.cos(t) + 0.6*math.sin(t)) / 1.166
end
function spine_w(x, y)
  local dx, dy = x - GC[1], y - GC[2]
  local a = -(dx*GV[1] + dy*GV[2])
  local ws = dx*GU[1] + dy*GU[2]
  local ax = a / CE
  local s = 1 / (1 - ax*SE/GD)
  return ws / (SR*s), ax
end
function Lspine(x, y)
  local w = spine_w(x, y)
  w = clamp(w, -1, 1)
  local c = math.sqrt(1 - w*w)
  return (w + 0.6*c) / 1.166
end

--@ chunk 47
print(Lnear(1000,400), Lnear(675,450), Lnear(450,480), Lnear(290,500)) print(spine_w(SPt(100,0.5))) print(Lspine(SPt(200,-0.5)), Lspine(SPt(200,0.86)))

--@ chunk 48
print(wait(7*24*60)) print(drying(900,400), drying(650,100), drying(1000,250))

--@ chunk 49
P5 = pile{{"yellow ochre",2},{"lead white",1.2},{"raw sienna",0.5}}
local near = M_near()
local spv = SPV
local function zone(base, Lf, a, b) return base * mask(function(x,y) local L = Lf(x,y) return (L >= a and L < b) and 1 or 0 end) end
local nang = function(x,y) return near_angle(x,y) end
local Z = {{D2, -9, 0.06}, {P2, 0.0, 0.27}, {P1, 0.22, 0.5}, {P3, 0.45, 0.74}, {P5, 0.7, 9}}
for _, z in ipairs(Z) do
  local m = zone(near, Lnear, z[2], z[3])
  if m:area() > 10 then work(m, {hand="body", pile=z[1], coverage=4, fill=true, clip=near, angle=nang, edge="firm"}) end
end
blend(near:shrink(1), {angle=nang})
for _, z in ipairs(Z) do
  local m = zone(spv, Lspine, z[2], z[3])
  if m:area() > 10 then work(m, {hand="body", pile=z[1], coverage=4, fill=true, clip=spv, angle=GA, edge="firm"}) end
end
blend(spv:shrink(1), {angle=GA})

--@ chunk 50
print(drying(300,500), drying(560,100))

--@ chunk 51
print(wait(36*60)) print(drying(300,500), drying(560,100), drying(900,450))

--@ chunk 52
local near = M_near()
local spv = SPV
local function zone(base, Lf, a, b) return base * mask(function(x,y) local L = Lf(x,y) return (L >= a and L < b) and 1 or 0 end) end
local nang = function(x,y) return near_angle(x,y) end
local zn = zone(near, Lnear, -9, 0.08)
work(zn, {hand="body", pile=D2, coverage=4, fill=true, clip=near, angle=nang, edge="soft"})
local zs = zone(spv, Lspine, -9, 0.08)
work(zs, {hand="body", pile=D2, coverage=4, fill=true, clip=spv, angle=GA, edge="soft"})
local zn2 = zone(near, Lnear, 0.06, 0.24)
work(zn2, {hand="body", pile=P2, coverage=2.5, fill=true, clip=near, angle=nang, edge="soft"})
local zs2 = zone(spv, Lspine, 0.06, 0.26)
work(zs2, {hand="body", pile=P2, coverage=2.5, fill=true, clip=spv, angle=GA, edge="soft"})

--@ chunk 53
print(wait(6*24*60)) print(drying(300,500), drying(560,100), drying(900,450), drying(640,250))

--@ chunk 54
print(wait(4*24*60)) print(drying(300,500), drying(560,100), drying(530,200))

--@ chunk 55
GZL = pile{{"raw sienna",1},{"lead white",1},{"yellow ochre",0.5},{"ultramarine ash",0.3}}
GZ  = pile{{"raw sienna",1},{"bone black",0.4},{"lead white",0.5},{"ultramarine ash",0.5}}
GZD = pile{{"raw sienna",1},{"bone black",0.8},{"burnt sienna",0.5}}
local near = M_near()
local spv = SPV
local function zone(base, Lf, a, b) return base * mask(function(x,y) local L = Lf(x,y) return (L >= a and L < b) and 1 or 0 end) end
local nang = function(x,y) return near_angle(x,y) end
local Z = {{D2, -9, 0.16, 1.4}, {GZD, 0.08, 0.42, 1.3}, {GZ, 0.33, 0.75, 1.2}, {GZL, 0.66, 9, 1.0}}
for _, z in ipairs(Z) do
  local m = zone(near, Lnear, z[2], z[3])
  if m:area() > 10 then work(m, {hand="scumble", pile=z[1], coverage=z[4], load=0.18, pressure={0.2,0.45}, clip=near, angle=nang}) end
  m = zone(spv, Lspine, z[2], z[3])
  if m:area() > 10 then work(m, {hand="scumble", pile=z[1], coverage=z[4], load=0.18, pressure={0.2,0.45}, clip=spv, angle=GA}) end
end

--@ chunk 56
RP = {
 pile{{"bone black",3},{"bone brown",1}},
 pile{{"bone brown",2},{"bone black",1},{"raw sienna",0.5}},
 pile{{"raw sienna",1},{"bone brown",1},{"bone black",0.4}},
 pile{{"raw sienna",2},{"burnt sienna",0.3},{"bone black",0.4},{"ultramarine ash",0.3}},
 pile{{"raw sienna",2},{"yellow ochre",1},{"lead white",0.4},{"bone black",0.2},{"ultramarine ash",0.3}},
 pile{{"yellow ochre",2},{"lead white",1.2},{"raw sienna",0.5},{"ultramarine ash",0.4},{"bone black",0.05}},
 pile{{"lead white",2},{"yellow ochre",0.7},{"cadmium yellow",0.2}},
 pile{{"lead white",3},{"lemon chrome",0.3}},
}
-- cells: {x, y, ang, len, idx}; paints them grouped by idx, light to dark or as given
function grad_paint(cells, width, opts)
  opts = opts or {}
  local groups = {}
  for _, c in ipairs(cells) do
    local i = clamp(c.idx, 1, #RP)
    groups[i] = groups[i] or {}
    table.insert(groups[i], c)
  end
  local b = brush{kind="filbert", width=width, stiffness=0.55}
  local order = opts.order or {1,2,3,4,5,6,7,8}
  for _, i in ipairs(order) do
    local g = groups[i]
    if g then
      b:reload(RP[i], 0.8)
      local n = 0
      for _, c in ipairs(g) do
        n = n + 1
        if n % (opts.every or 4) == 0 then b:load(RP[i], 0.8) end
        local h = c.len / 2
        local ca, sa = math.cos(c.ang), math.sin(c.ang)
        b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={opts.pr or 0.7, (opts.pr or 0.7)*0.8}, ramps={0.15, 0.3}, clip=opts.clip})
      end
    end
  end
end
-- value (0..1) to ramp index with dither
function vidx(v, jit)
  local f = v * 7 + 1 + randn(0, jit or 0.35)
  return math.floor(f + 0.5)
end

--@ chunk 57
print(wait(6*24*60)) print(drying(300,500), drying(560,100), drying(900,450), drying(640,250))

--@ chunk 58
local nz = noise{seed=58, period=45, octaves=3}
local cells = {}
for ax = -250, 370, 4.8 do
  for w = -1.0, 1.0, 0.105 do
    local ww = clamp(w + rand(-0.04, 0.04), -0.99, 0.99)
    local x, y, s = SPt(ax + rand(-1.5, 1.5), ww)
    if SPV:at(x, y) > 0.1 then
      local c = math.sqrt(1 - ww*ww)
      local L = math.max(0, (ww + 0.6*c)/1.166)
      local spec = math.exp(-((ww - 0.49)/0.09)^2)
      local v = 0.03 + 0.58*L + 0.38*spec + 0.07*nz(x, y)
      cells[#cells+1] = {x=x, y=y, ang=GA + randn(0,0.06), len=(rand(10,15))*(0.35 + 0.65*c), idx=vidx(v, 0.33)}
    end
  end
end
print(#cells)
grad_paint(cells, 6, {clip=SPV})

--@ chunk 59
local nz = noise{seed=58, period=45, octaves=3}
local cells = {}
for ax = -247.6, 370, 4.8 do
  for w = -0.95, 1.0, 0.105 do
    local ww = clamp(w + rand(-0.04, 0.04), -0.99, 0.99)
    local x, y, s = SPt(ax + rand(-1.5, 1.5), ww)
    if SPV:at(x, y) > 0.1 then
      local c = math.sqrt(1 - ww*ww)
      local L = math.max(0, (ww + 0.6*c)/1.166)
      local spec = math.exp(-((ww - 0.49)/0.09)^2)
      local v = 0.03 + 0.58*L + 0.38*spec + 0.07*nz(x, y)
      cells[#cells+1] = {x=x, y=y, ang=GA + randn(0,0.06), len=(rand(10,15))*(0.35 + 0.65*c), idx=vidx(v, 0.33)}
    end
  end
end
print(#cells)
grad_paint(cells, 6, {clip=SPV})

--@ chunk 60
local nz = noise{seed=60, period=50, octaves=3}
local near = M_near()
for pass = 0, 1 do
  local cells = {}
  for t = 0.95 + pass*0.006, 2.95, 0.012 do
    for ax = -HW - 14 + pass*2.6, HW + 2, 5.2 do
      local tt = t + rand(-0.004, 0.004)
      local x, y = P(tt, RO, ax + rand(-1.5, 1.5))
      if x > -10 and x < 1010 and y < 570 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local L = math.max(0, (math.cos(tt) + 0.6*math.sin(tt))/1.166)
        local spec = math.exp(-((tt - 1.055)/0.11)^2)
        local v = 0.03 + 0.58*L + 0.38*spec + 0.07*nz(x, y)
        local fx = math.abs(math.sin(tt - 0.0))   -- foreshortening toward the left end
        cells[#cells+1] = {x=x, y=y, ang=ring_tangent(tt, RO, ax) + randn(0,0.05), len=rand(11,17)*(0.35 + 0.65*fx), idx=vidx(v, 0.33)}
      end
    end
  end
  print(#cells)
  grad_paint(cells, 6, {clip=near})
end

--@ chunk 61
print(wait(7*24*60)) print(drying(300,500), drying(560,100), drying(900,450), drying(150,450))

--@ chunk 62
print(wait(5*24*60)) print(drying(300,500), drying(560,100), drying(900,450), drying(700,300))

--@ chunk 63
local near = M_near()
local spv = SPV
local function zone(base, Lf, a, b, soft) return base * (mask(function(x,y) local L = Lf(x,y) return (L >= a and L < b) and 1 or 0 end):soften(soft or 15)) end
local nang = function(x,y) return near_angle(x,y) end
work(zone(near, Lnear, -9, 0.32, 20), {hand="glaze", pile=GK, coverage=1.3, fill=true, clip=near, angle=nang})
work(zone(near, Lnear, -9, 0.12, 20), {hand="glaze", pile=GK, coverage=1.5, fill=true, clip=near, angle=nang})
work(zone(spv, Lspine, -9, 0.25, 6), {hand="glaze", pile=GK, coverage=1.3, fill=true, clip=spv, angle=SPINE_ANG})
work(zone(spv, Lspine, -9, 0.08, 6), {hand="glaze", pile=GK, coverage=1.3, fill=true, clip=spv, angle=SPINE_ANG})

--@ chunk 64
TF = pile{{"bone brown",2},{"bone black",1.5},{"raw sienna",0.3},{"ultramarine blue",0.3}}
local top = M_top()
TOPV = top - M_near():shrink(0.5) - SPV:grow(0.5) - HUB:grow(0.5)
work(TOPV, {hand="body", pile=TF, coverage=3.5, fill=true, clip=TOPV, edge="firm",
  angle=function(x,y) local dx, dy = x - GC[1], y - GC[2] return math.atan(dy, dx) + math.pi/2 end})

--@ chunk 65
local nz = noise{seed=65, period=40, octaves=3}
FARV = M_farin() - SPV:grow(0.5) - HUB:grow(0.5) - M_near():grow(0.5) - TOPV
for pass = 0, 1 do
  local cells = {}
  for t = math.pi - 0.12 + pass*0.005, 4.8, 0.01 do
    local frac = lerp(0.58, 0.28, clamp((t - math.pi)/(4.8 - math.pi), 0, 1))
    local axlit = -HW + 2*HW*frac + 6*nz(t*100, 7)
    for ax = -HW - 4 + pass*2.4, HW + 4, 4.8 do
      local tt = t + rand(-0.003, 0.003)
      local x, y = P(tt, RI, ax)
      if FARV:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local L = math.max(0, (-math.cos(tt) - 0.6*math.sin(tt))/1.166)
        local inshade = (ax > axlit) or (tt > 3.52 and tt < 3.84)
        local v
        if inshade then v = 0.02 + 0.04*nz(x,y) else
          local edge = clamp((axlit - ax)/10, 0, 1)
          v = 0.05 + (0.55*L + 0.12) * (0.4 + 0.6*edge) + 0.07*nz(x,y)
        end
        cells[#cells+1] = {x=x, y=y, ang=ring_tangent(tt, RI, ax) + randn(0,0.05), len=rand(9,14)*0.8, idx=vidx(v, 0.3)}
      end
    end
  end
  print(#cells)
  grad_paint(cells, 5, {clip=FARV})
end

--@ chunk 66
local nz = noise{seed=66, period=30, octaves=3}
local function domeax(r) return 30 * (1 - (r - SR)/(HR - SR))^1.3 end
for pass = 0, 1 do
  local cells = {}
  -- dome surface
  for r = SR*1.0 + pass*2.5, HR, 5 do
    local n = math.floor(2*math.pi*r / 7)
    for i = 0, n - 1 do
      local t = (i + 0.5*pass + rand(-0.2, 0.2)) / n * 2*math.pi
      local ax = domeax(r)
      local x, y = P(t, r, ax)
      if HUB:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local slope = 0.55
        local L = math.max(0, (slope*(math.cos(t) + 0.6*math.sin(t)) - 0.15)/1.0)
        local v = 0.03 + 0.55*L + 0.05*nz(x,y)
        cells[#cells+1] = {x=x, y=y, ang=ring_tangent(t, r, ax) + randn(0,0.05), len=rand(7,11)*(0.4+0.6*math.abs(math.sin(t))+0.2), idx=vidx(v, 0.3)}
      end
    end
  end
  -- rim face
  for t = -0.4 + pass*0.01, math.pi + 0.4, 0.02 do
    for ax = -18 + pass*2, 1, 4 do
      local x, y = P(t, HR, ax)
      if HUB:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local L = math.max(0, (math.cos(t) + 0.6*math.sin(t))/1.166)
        local spec = math.exp(-((t - 1.055)/0.12)^2)
        local v = 0.03 + 0.55*L + 0.35*spec + 0.05*nz(x,y)
        cells[#cells+1] = {x=x, y=y, ang=ring_tangent(t, HR, ax), len=rand(7,11)*(0.4+0.6*math.abs(math.sin(t))), idx=vidx(v, 0.3)}
      end
    end
  end
  print(#cells)
  grad_paint(cells, 4, {clip=HUB})
end

--@ chunk 67
for _, t in ipairs({0.42, 1.72, 2.95, 4.05, 5.45}) do local x1,y1,s1 = P(t, HR, -4) local x2,y2,s2 = P(t, RI, -4) print(t, math.floor(x1), math.floor(y1), math.floor(x2), math.floor(y2), s1, s2, -math.sin(t)+0.6*math.cos(t)) end

--@ chunk 68
local occ_far = SPV + HUB + M_near() + TOPV
local occ_near = HUB + M_near() + TOPV
local spokes = {{0.42, 10, false}, {2.22, 12, false}, {2.95, 9, false}, {4.05, 11, true}, {5.45, 10, true}}
for _, sp in ipairs(spokes) do
  local t, rs, far = sp[1], sp[2], sp[3]
  local pts, wid, lit = {}, {}, {}
  local Ls = (-math.sin(t) + 0.6*math.cos(t))
  local sgn = Ls >= 0 and 1 or -1
  for i = 0, 40 do
    local R = HR - 4 + (RI + 6 - HR + 4) * i / 40
    local x, y, s = P(t, R, -4)
    local x2, y2 = P(t + 0.01, R, -4)
    local dx, dy = x2 - x, y2 - y
    local dl = math.sqrt(dx*dx + dy*dy)
    pts[#pts+1] = {x, y}
    wid[#wid+1] = 2*rs*s
    lit[#lit+1] = {x + sgn*dx/dl*rs*s*0.62, y + sgn*dy/dl*rs*s*0.62, x - sgn*dx/dl*rs*s*0.3, y - sgn*dy/dl*rs*s*0.3}
  end
  local clipm = -(far and occ_far or occ_near)
  local m = ribbon(pts, wid) * clipm
  local x1, y1 = pts[1][1], pts[1][2]
  local xn, yn = pts[#pts][1], pts[#pts][2]
  local ang = math.atan(yn - y1, xn - x1)
  work(m, {hand="body", pile=RP[2], coverage=3, fill=true, clip=m, angle=ang})
  local a = math.abs(Ls)/1.17
  local mid = RP[clamp(math.floor(2.5 + 3*a), 2, 6)]
  local hi = RP[clamp(math.floor(4.5 + 3.5*a), 4, 8)]
  local b = brush{kind="filbert", width=rs*0.7, stiffness=0.5}
  b:load(mid, 0.8)
  local mp = {} for i, l in ipairs(lit) do mp[#mp+1] = {(l[1] + l[3])/2*0 + (pts[i][1]*0.45 + l[1]*0.55), pts[i][2]*0.45 + l[2]*0.55} end
  b:stroke(mp, {pressure={0.6, 0.6}, clip=m})
  local h = brush{kind="round", width=1.6, point=0.6}
  h:load(hi, 0.9)
  local hp = {} for _, l in ipairs(lit) do hp[#hp+1] = {l[1], l[2]} end
  h:stroke(hp, {pressure={0.55, 0.5}, clip=m:grow(0.5)})
end

--@ chunk 69
local GOLD = math.pi * (3 - math.sqrt(5))
local d = 5.5
local dz = d*d*0.866 / (2*math.pi*SR)
local pl = {}
local k = 0
while true do
  k = k + 1
  local ax = -230 + k*dz
  if ax > 360 then break end
  local th = (k*GOLD) % (2*math.pi)
  if th > math.pi then th = th - 2*math.pi end
  local c = math.cos(th)
  if c > 0.12 then
    local w = math.sin(th)
    local x, y, s = SPt(ax, w)
    if SPV:at(clamp(x,0,999), clamp(y,0,562)) > 0.3 then
      local L = (w + 0.6*c) / 1.166
      if L > 0.12 then
        local p = {x=x + randn(0,0.25), y=y + randn(0,0.25), at=GA, aa=math.atan(GV[2], GV[1]), Lt=d*1.1*c*s*rand(0.9,1.1), La=d*1.15*CE*s*rand(0.9,1.1), ax=ax, L=L}
        p.gl = clamp(0.3 + 0.7*L, 0.2, 1)
        pl[#pl+1] = p
      end
    end
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
print(#pl)
CLIP = SPV
scale_shadows(pl, D, 1.1, 0.55)
local lt = {}
for _, p in ipairs(pl) do if rand(0,1) < (p.L - 0.2)*1.2 then lt[#lt+1] = p end end
scale_glints(lt, RP[8], 0.9, 0.5)
CLIP = nil
print(#lt)

--@ chunk 70
local near = M_near()
local d = 6.5
local ds = 0.866*d*d/(2*HW+10)
local pl = {}
local k = 0
while true do
  k = k + 1
  local s = 0.98*RO + k*ds
  local t = s / RO
  if t > 2.4 then break end
  local ax = HW - ((k*PHI) % 1) * (2*HW + 10)
  local x, y = P(t, RO, ax)
  if x > -5 and x < 1005 and y < 568 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.3 then
    local L = (math.cos(t) + 0.6*math.sin(t)) / 1.166
    if L > 0.1 then
      local xa, ya = P(t + 0.002, RO, ax)
      local xb, yb = P(t, RO, ax - 1)
      local lt = math.sqrt((xa-x)^2 + (ya-y)^2) / (0.002*RO)
      local la = math.sqrt((xb-x)^2 + (yb-y)^2)
      local p = {x=x + randn(0,0.25), y=y + randn(0,0.25), at=math.atan(y - ya, x - xa), aa=math.atan(yb - y, xb - x),
                 Lt=d*1.1*lt*rand(0.9,1.1), La=d*1.15*la*rand(0.9,1.1), ax=ax, L=L}
      p.gl = clamp(0.3 + 0.7*L, 0.2, 1)
      pl[#pl+1] = p
    end
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
print(#pl)
CLIP = near
scale_shadows(pl, D, 1.2, 0.55)
local lt = {}
for _, p in ipairs(pl) do if rand(0,1) < (p.L - 0.15)*1.1 then lt[#lt+1] = p end end
scale_glints(lt, RP[8], 1.0, 0.5)
CLIP = nil
print(#lt)

--@ chunk 71
WD = pile{{"bone black",2},{"ultramarine blue",1}}
WL = pile{{"lead white",2},{"cadmium yellow",1},{"cadmium red",0.1}}
WL2 = pile{{"lead white",3},{"chrome yellow",0.6}}
-- windows: list of {x, y, ang, len}
function paint_windows(list, pile_, width, pr, clipm)
  local b = brush{kind="round", width=width, point=0.3, stiffness=0.5}
  b:load(pile_, 0.9)
  for i, w in ipairs(list) do
    if i % 10 == 0 then b:load(pile_, 0.9) end
    local h = w.len/2
    local c, s = math.cos(w.ang), math.sin(w.ang)
    if w.len < 0.6 then
      b:touch(w.x, w.y, {pressure=pr, clip=clipm})
    else
      b:stroke({{w.x - c*h, w.y - s*h}, {w.x + c*h, w.y + s*h}}, {pressure={pr, pr}, ramps={0.05,0.05}, clip=clipm})
    end
  end
end
-- generate windows along a ring row at radius R, axial ax, t range
function ring_row(R, ax, t0, t1, spacing, run, gap, len, out, visible, litp, litlist)
  local arc_len = math.abs(t1 - t0) * R
  local pos = rand(0, gap)
  local inrun = math.floor(rand(run[1], run[2]))
  local lit_run = rand(0,1) < litp
  while pos < arc_len do
    local t = t0 + (t1 - t0) * pos / arc_len
    local x, y, s = P(t, R, ax)
    if x > 0 and x < 1000 and y > 0 and y < 562 and visible:at(x, y) > 0.5 then
      local w = {x=x, y=y, ang=ring_tangent(t, R, ax), len=len*s*math.abs(math.sin(t)*0.6+0.4)}
      if lit_run and rand(0,1) < 0.7 then litlist[#litlist+1] = w else out[#out+1] = w end
    end
    pos = pos + spacing * rand(0.85, 1.15)
    inrun = inrun - 1
    if inrun <= 0 then
      pos = pos + rand(gap*0.5, gap*1.5)
      inrun = math.floor(rand(run[1], run[2]))
      lit_run = rand(0,1) < litp
    end
  end
end

--@ chunk 72
local dark, lit = {}, {}
local vis = TOPV:shrink(1)
local radii = {RI + 8, RI + 19, RI + 31, RI + 44, RI + 57}
for i, r in ipairs(radii) do
  ring_row(r + rand(-2,2), HW, 0, 2*math.pi, 4.2 + i*0.3, {4, 16}, 14 + 4*i, 2.2, dark, vis, 0.06, lit)
end
print(#dark, #lit)
paint_windows(dark, WD, 0.9, 0.45, TOPV)
paint_windows(lit, WL, 0.9, 0.5, TOPV)

--@ chunk 73
local dark, lit = {}, {}
local vis = TOPV:shrink(1.5)
local radii = {RI + 13, RI + 25, RI + 38, RI + 51}
for i, r in ipairs(radii) do
  ring_row(r + rand(-2,2), HW, 0, 2*math.pi, 5.5 + i*0.4, {3, 9}, 22 + 5*i, 0.9, dark, vis, 0.07, lit)
end
print(#dark, #lit)
paint_windows(dark, WD, 1.3, 0.5, TOPV)
paint_windows(lit, WL, 1.3, 0.55, TOPV)

--@ chunk 74
function paint_dots(list, pile_, width, pr, clipm, every)
  local b = brush{kind="round", width=width, stiffness=0.6}
  b:load(pile_, 0.9)
  for i, w in ipairs(list) do
    if i % (every or 12) == 0 then b:load(pile_, 0.9) end
    local c, s = math.cos(w.ang), math.sin(w.ang)
    b:stroke({{w.x - c*w.len/2, w.y - s*w.len/2}, {w.x + c*w.len/2, w.y + s*w.len/2}}, {pressure={pr, pr}, ramps={0.02,0.02}, clip=clipm})
  end
end
local dark, lit = {}, {}
local vis = TOPV:shrink(1.5)
local radii = {RI + 10, RI + 22, RI + 35, RI + 48, RI + 60}
for i, r in ipairs(radii) do
  ring_row(r + rand(-2,2), HW, 0, 2*math.pi, 3.4 + i*0.25, {4, 14}, 16 + 4*i, 0.5, dark, vis, 0.12, lit)
end
print(#dark, #lit)
paint_dots(dark, WD, 1.1, 0.75, TOPV)
paint_dots(lit, WL, 1.2, 0.8, TOPV, 5)

--@ chunk 75
VG1 = pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"bone black",0.3},{"raw sienna",0.3}}
VG3 = pile{{"viridian",1},{"cerulean blue",0.4},{"lead white",0.5},{"bone black",0.5},{"raw sienna",0.4}}
local nz = noise{seed=75, period=70, octaves=4, warp={60, 25}}
local patch = mask(function(x,y) return nz(x,y) > 0.18 and 1 or 0 end):soften(5)
local near = M_near()
local spv = SPV
local nl = near * mask(function(x,y) return Lnear(x,y) > 0.15 and 1 or 0 end):soften(10)
stipple(patch * nl, {pile=VG1, width=1.5, coverage=0.9, cluster=0.5, feather=0.6, clip=near})
stipple(patch * (near - nl), {pile=VG3, width=1.5, coverage=0.7, cluster=0.5, feather=0.6, clip=near})
local sl = spv * mask(function(x,y) return Lspine(x,y) > 0.15 and 1 or 0 end):soften(4)
stipple(patch * sl, {pile=VG1, width=1.3, coverage=0.9, cluster=0.5, feather=0.6, clip=spv})
stipple(patch * (spv - sl), {pile=VG3, width=1.3, coverage=0.6, cluster=0.5, feather=0.6, clip=spv})
stipple(patch * FARV, {pile=VG1, width=1.2, coverage=0.7, cluster=0.5, feather=0.6, clip=FARV})
stipple(patch * HUB, {pile=VG1, width=1.2, coverage=0.7, cluster=0.5, feather=0.6, clip=HUB})

--@ chunk 76
print(wait(6*24*60)) print(drying(900,150), drying(700,450), drying(640,100))

--@ chunk 77
G3 = pile{{"burnt sienna",1},{"bone brown",1},medium=0.75}
local nz = noise{seed=75, period=70, octaves=4, warp={60, 25}}
local patch = mask(function(x,y) return nz(x,y) > 0.1 and 1 or 0 end):soften(12)
-- darks: kill the pale speckle
local fardark = FARV * mask(function(x,y) local L = 0 return 1 end)
local darkzones = (FARV * mask(function(x,y) return x > 560 and 1 or 0 end)) + (SPV * mask(function(x,y) return Lspine(x,y) < 0.18 and 1 or 0 end)) + (M_near() * mask(function(x,y) return Lnear(x,y) < 0.15 and 1 or 0 end))
work(darkzones * patch, {hand="glaze", pile=GK, coverage=1.6, fill=true, clip=darkzones})
-- lit: warm the verdigris into olive
local lit = (SPV * mask(function(x,y) return Lspine(x,y) >= 0.15 and 1 or 0 end)) + (M_near() * mask(function(x,y) return Lnear(x,y) >= 0.12 and 1 or 0 end)) + HUB
work(lit * patch, {hand="glaze", pile=G3, coverage=0.9, fill=true, clip=lit})

--@ chunk 78
RP = {}
for i, m in ipairs({
 {{"bone black",3},{"bone brown",1}},
 {{"bone brown",2},{"bone black",1},{"raw sienna",0.4},{"ultramarine blue",0.2}},
 {{"raw sienna",1},{"bone brown",1},{"bone black",0.5},{"ultramarine ash",0.3}},
 {{"raw sienna",2},{"bone black",0.5},{"ultramarine ash",0.6},{"lead white",0.2}},
 {{"raw sienna",2},{"yellow ochre",1},{"lead white",0.6},{"bone black",0.25},{"ultramarine ash",0.6}},
 {{"yellow ochre",2},{"lead white",1.5},{"raw sienna",0.5},{"ultramarine ash",0.6},{"bone black",0.1}},
 {{"lead white",2.5},{"yellow ochre",0.7},{"cadmium yellow",0.15}},
 {{"lead white",3},{"lemon chrome",0.25}},
}) do RP[i] = pile(m) end
VGP = {
 pile{{"viridian",1},{"bone black",1.2},{"raw sienna",0.5},{"cerulean blue",0.3}},
 pile{{"viridian",1},{"bone black",1},{"raw sienna",0.5},{"cerulean blue",0.3},{"lead white",0.2}},
 pile{{"viridian",1},{"bone black",0.7},{"raw sienna",0.4},{"cerulean blue",0.4},{"lead white",0.5}},
 pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"bone black",0.4},{"raw sienna",0.4}},
 pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1.6},{"bone black",0.2},{"raw sienna",0.4}},
 pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",2.4},{"raw sienna",0.3}},
}
-- like grad_paint but each cell may carry .vg = true (verdigris)
function grad_paint2(cells, width, opts)
  opts = opts or {}
  local groups = {}
  for _, c in ipairs(cells) do
    local key
    if c.vg then key = 100 + clamp(c.idx, 1, 6) else key = clamp(c.idx, 1, #RP) end
    groups[key] = groups[key] or {}
    table.insert(groups[key], c)
  end
  local b = brush{kind="filbert", width=width, stiffness=0.55}
  local keys = {1,2,3,4,5,6,7,8,101,102,103,104,105,106}
  for _, key in ipairs(keys) do
    local g = groups[key]
    if g then
      local pl_ = key > 100 and VGP[key - 100] or RP[key]
      b:reload(pl_, 0.8)
      local n = 0
      for _, c in ipairs(g) do
        n = n + 1
        if n % (opts.every or 4) == 0 then b:load(pl_, 0.8) end
        local h = c.len / 2
        local ca, sa = math.cos(c.ang), math.sin(c.ang)
        b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={opts.pr or 0.7, (opts.pr or 0.7)*0.8}, ramps={0.15, 0.3}, clip=opts.clip})
      end
    end
  end
end
VGN = noise{seed=101, period=28, octaves=3, warp={30, 10}}
function vg_chance(x, y) return clamp((VGN(x, y) - 0.05) * 0.9, 0, 0.55) end

--@ chunk 79
print(wait(7*24*60)) print(drying(900,150), drying(700,450), drying(640,100), drying(640,300))

--@ chunk 80
local nz = noise{seed=80, period=45, octaves=3}
local near = M_near()
local function mk(x, y, v, ang, len)
  local c = {x=x, y=y, ang=ang, len=len, idx=vidx(v, 0.33)}
  if rand(0,1) < vg_chance(x, y) then c.vg = true c.idx = clamp(c.idx - 1, 1, 6) end
  return c
end
for pass = 0, 1 do
  local cells = {}
  for ax = -250 + pass*2.4, 370, 4.8 do
    for w = -1.0 + pass*0.05, 1.0, 0.105 do
      local ww = clamp(w + rand(-0.04, 0.04), -0.99, 0.99)
      local x, y, s = SPt(ax + rand(-1.5, 1.5), ww)
      if SPV:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local c = math.sqrt(1 - ww*ww)
        local L = math.max(0, (ww + 0.6*c)/1.166)
        local spec = math.exp(-((ww - 0.49)/0.09)^2)
        local v = 0.02 + 0.56*L + 0.4*spec + 0.07*nz(x, y)
        cells[#cells+1] = mk(x, y, v, GA + randn(0,0.06), rand(10,15)*(0.35 + 0.65*c))
      end
    end
  end
  grad_paint2(cells, 6, {clip=SPV})
  cells = {}
  for t = 0.95 + pass*0.006, 2.95, 0.012 do
    for ax = -HW - 14 + pass*2.6, HW + 2, 5.2 do
      local tt = t + rand(-0.004, 0.004)
      local x, y = P(tt, RO, ax + rand(-1.5, 1.5))
      if x > -10 and x < 1010 and y < 570 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local L = math.max(0, (math.cos(tt) + 0.6*math.sin(tt))/1.166)
        local spec = math.exp(-((tt - 1.055)/0.11)^2)
        local v = 0.02 + 0.56*L + 0.4*spec + 0.07*nz(x, y)
        cells[#cells+1] = mk(x, y, v, ring_tangent(tt, RO, ax) + randn(0,0.05), rand(11,17)*(0.35 + 0.65*math.abs(math.sin(tt))))
      end
    end
  end
  grad_paint2(cells, 6, {clip=near})
end

--@ chunk 81
local nz = noise{seed=81, period=30, octaves=3}
local function domeax(r) return 30 * (1 - (r - SR)/(HR - SR))^1.3 end
for pass = 0, 1 do
  local cells = {}
  -- dome surface
  for r = SR*1.0 + pass*2.5, HR, 5 do
    local n = math.floor(2*math.pi*r / 7)
    for i = 0, n - 1 do
      local t = (i + 0.5*pass + rand(-0.2, 0.2)) / n * 2*math.pi
      local ax = domeax(r)
      local x, y = P(t, r, ax)
      if HUB:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local slope = 0.55
        local L = math.max(0, (slope*(math.cos(t) + 0.6*math.sin(t)) - 0.15)/1.0)
        local v = 0.03 + 0.55*L + 0.05*nz(x,y)
        local cc = {x=x, y=y, ang=ring_tangent(t, r, ax) + randn(0,0.05), len=rand(7,11)*(0.4+0.6*math.abs(math.sin(t))+0.2), idx=vidx(v, 0.3)} if rand(0,1) < vg_chance(x,y) then cc.vg = true cc.idx = clamp(cc.idx-1,1,6) end cells[#cells+1] = cc
      end
    end
  end
  -- rim face
  for t = -0.4 + pass*0.01, math.pi + 0.4, 0.02 do
    for ax = -18 + pass*2, 1, 4 do
      local x, y = P(t, HR, ax)
      if HUB:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local L = math.max(0, (math.cos(t) + 0.6*math.sin(t))/1.166)
        local spec = math.exp(-((t - 1.055)/0.12)^2)
        local v = 0.03 + 0.55*L + 0.35*spec + 0.05*nz(x,y)
        local cc = {x=x, y=y, ang=ring_tangent(t, HR, ax), len=rand(7,11)*(0.4+0.6*math.abs(math.sin(t))), idx=vidx(v, 0.3)} if rand(0,1) < vg_chance(x,y) then cc.vg = true cc.idx = clamp(cc.idx-1,1,6) end cells[#cells+1] = cc
      end
    end
  end
  print(#cells)
  grad_paint2(cells, 4, {clip=HUB})
end

--@ chunk 82
local nz = noise{seed=82, period=45, octaves=3}
local m = poly(spine_poly(-1, 1, 20, 120)) * HUB:grow(1)
SPV2 = SPV + m
local cells = {}
for pass = 0, 1 do
  for ax = 10 + pass*2.4, 120, 4.8 do
    for w = -1.0 + pass*0.05, 1.0, 0.105 do
      local ww = clamp(w + rand(-0.04, 0.04), -0.99, 0.99)
      local x, y = SPt(ax + rand(-1.5, 1.5), ww)
      if m:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local c = math.sqrt(1 - ww*ww)
        local L = math.max(0, (ww + 0.6*c)/1.166)
        local spec = math.exp(-((ww - 0.49)/0.09)^2)
        local v = 0.02 + 0.56*L + 0.4*spec + 0.07*nz(x, y)
        local cc = {x=x, y=y, ang=GA + randn(0,0.06), len=rand(10,15)*(0.35 + 0.65*c), idx=vidx(v, 0.33)}
        if rand(0,1) < vg_chance(x,y) then cc.vg = true cc.idx = clamp(cc.idx-1,1,6) end
        cells[#cells+1] = cc
      end
    end
  end
end
print(#cells)
grad_paint2(cells, 6, {clip=m})
-- contact shadow where spine meets dome
local b = brush{kind="round", width=3, point=0.3}
b:load(RP[1], 0.8)
local pts = {}
for i = 0, 60 do local t = math.pi + math.pi*i/60 local x, y = P(t, SR*1.02, 22) pts[#pts+1] = {x, y} end
b:stroke(pts, {pressure={0.6, 0.6}, clip=HUB})

--@ chunk 83
local nz = noise{seed=83, period=45, octaves=3}
local m = poly(arc(0, 2*math.pi, SR*1.03, 22, 120)) * HUB:grow(1)
SPV2 = SPV2 + m
local cells = {}
for pass = 0, 2 do
  for i = 0, 400 do
    local x, y = rand(GC[1]-110, GC[1]+110), rand(GC[2]-60, GC[2]+40)
    if m:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
      local w = clamp(spine_w(x, y), -0.99, 0.99)
      local c = math.sqrt(1 - w*w)
      local L = math.max(0, (w + 0.6*c)/1.166)
      local spec = math.exp(-((w - 0.49)/0.09)^2)
      local v = 0.02 + 0.5*L + 0.3*spec + 0.07*nz(x, y)
      cells[#cells+1] = {x=x, y=y, ang=GA + randn(0,0.06), len=rand(6,10), idx=vidx(v, 0.3)}
    end
  end
end
print(#cells)
grad_paint2(cells, 4, {clip=m})
local b = brush{kind="round", width=2.2, point=0.3}
b:load(RP[1], 0.8)
local pts = {}
for i = 0, 60 do local t = math.pi*i/60 - 0.15 local x, y = P(t, SR*1.03, 22) pts[#pts+1] = {x, y} end
b:stroke(pts, {pressure={0.5, 0.5}, clip=HUB:grow(1)})

--@ chunk 84
print(wait(8*24*60)) print(drying(900,450), drying(640,100), drying(640,300), drying(300,100))

--@ chunk 85
print(wait(5*24*60)) print(drying(900,450), drying(640,100), drying(640,300), drying(560,300))

--@ chunk 86
GK2 = pile{{"bone black",2},{"ultramarine blue",0.8},medium=0.6}
local sky = SKY
local left = mask(function(x,y) return 1 - smoothstep(700, 900, x + 0.3*y) end)
work(sky * left, {hand="glaze", pile=GK2, coverage=1.2, fill=true, clip=sky * left})

--@ chunk 87
print(wait(4*24*60)) print(drying(640,300), drying(560,300), drying(700,280)) for _,t in ipairs({1.0,1.1,1.2,1.3,1.4,1.5}) do print(t, P(t,RO,0)) end

--@ chunk 88
local near = M_near()
local dn = near * mask(function(x,y) local t = near_t(x) return smoothstep(1.22, 1.5, t) end)
local spv = SPV
local ds = spv * mask(function(x,y) local w = spine_w(x,y) return 1 - smoothstep(0.22, 0.55, w) end)
work(dn, {hand="glaze", pile=GK, coverage=1.4, fill=true, clip=dn, angle=function(x,y) return near_angle(x,y) end})
work(ds, {hand="glaze", pile=GK, coverage=1.4, fill=true, clip=ds, angle=SPINE_ANG})

--@ chunk 89
local top = TOPV
local g = top * mask(function(x,y) return 0.55 + 0.45*(1 - smoothstep(850, 1000, x)) end)
work(g, {hand="glaze", pile=GK, coverage=1.2, fill=true, clip=g,
  angle=function(x,y) local dx, dy = x - GC[1], y - GC[2] return math.atan(dy, dx) + math.pi/2 end})

--@ chunk 90
print(wait(4*24*60)) print(drying(640,300), drying(560,300), drying(700,280))

--@ chunk 91
print(wait(5*24*60)) print(drying(640,300), drying(560,300), drying(600,320), drying(520,310))

--@ chunk 92
print(wait(10*24*60)) print(drying(640,300), drying(560,300), drying(600,320), drying(520,310))

--@ chunk 93
print(wait(7*24*60)) print(drying(640,300), drying(560,300), drying(600,320), drying(520,310))

--@ chunk 94
function hub_t(x, y)
  local dx, dy = x - GC[1], y - GC[2]
  local a = dx*GU[1] + dy*GU[2]
  local b = dx*GV[1] + dy*GV[2]
  return math.atan((b + 10*CE)/SE, a)
end
local dh = HUB * mask(function(x,y) local t = hub_t(x,y) local L = math.cos(t) - 0.35*math.sin(t) return 1 - smoothstep(0.25, 0.8, L) end)
work(dh, {hand="glaze", pile=GK, coverage=1.4, fill=true, clip=dh, angle=GA})

--@ chunk 95
local occ_far = SPV2 + HUB + M_near() + TOPV
local occ_near = HUB + M_near() + TOPV
local spokes = {{0.42, 10, false}, {2.22, 12, false}, {2.95, 9, false}, {4.05, 11, true}, {5.45, 10, true}}
SPOKES = nil
for _, sp in ipairs(spokes) do
  local t, rs, far = sp[1], sp[2], sp[3]
  local pts, wid, lit = {}, {}, {}
  for i = 0, 40 do
    local R = HR - 4 + (RI + 6 - HR + 4) * i / 40
    local x, y, s = P(t, R, -4)
    local x2, y2 = P(t, R, -4 + 1)
    -- across-direction on screen: perpendicular to the spoke line
    pts[#pts+1] = {x, y}
    wid[#wid+1] = 2*rs*s*0.75
  end
  local x1, y1 = pts[1][1], pts[1][2]
  local xn, yn = pts[#pts][1], pts[#pts][2]
  local ang = math.atan(yn - y1, xn - x1)
  local nx, ny = -math.sin(ang), math.cos(ang)
  if nx < 0 then nx, ny = -nx, -ny end   -- across direction pointing right (toward the light)
  local clipm = -(far and occ_far or occ_near)
  local m = ribbon(pts, wid) * clipm
  SPOKES = SPOKES and (SPOKES + m) or m
  work(m, {hand="body", pile=RP[1], coverage=3, fill=true, clip=m, angle=ang})
  local b = brush{kind="filbert", width=rs*0.4, stiffness=0.5}
  b:load(RP[3], 0.8)
  local mp, hp = {}, {}
  for i, p in ipairs(pts) do
    local hw = wid[i]/2
    mp[#mp+1] = {p[1] + nx*hw*0.35, p[2] + ny*hw*0.35}
    hp[#hp+1] = {p[1] + nx*hw*0.72, p[2] + ny*hw*0.72}
  end
  b:stroke(mp, {pressure={0.6, 0.6}, clip=m})
  local h = brush{kind="round", width=1.3, point=0.6}
  h:load(RP[6], 0.9)
  h:stroke(hp, {pressure={0.5, 0.45}, clip=m:grow(0.3)})
end

--@ chunk 96
local near = M_near():shrink(1.5)
local dark, lit = {}, {}
local rows = {32, 22, 6, -20, -58}
for i, ax in ipairs(rows) do
  ring_row(RO + 0.5, ax, 0.95, 2.85, 3.6 + i*0.3, {5, 21}, 9 + 3*i, 0.9, dark, near, 0.22, lit)
end
-- split by light: dark windows only where lit, lit windows only where dark
local dw, lw = {}, {}
for _, w in ipairs(dark) do if near_t(w.x) < 1.42 then dw[#dw+1] = w end end
for _, w in ipairs(lit) do if near_t(w.x) > 1.3 then lw[#lw+1] = w end end
print(#dark, #lit, #dw, #lw)
paint_dots(dw, WD, 1.0, 0.7, near)
paint_dots(lw, WL, 1.0, 0.75, near, 6)

--@ chunk 97
for _, ax in ipairs({120,150,180,210,240}) do local x,y = SPt(ax,0.2) local x2,y2 = SPt(ax, 1.0) print(ax, math.floor(x), math.floor(y), math.floor(x2), math.floor(y2)) end

--@ chunk 98
OU = {-GV[1], -GV[2]}     -- up along spine axis
OV = {GU[1], GU[2]}       -- across, to the right (toward the sun)
function lp(o, u, v) return {o[1] + u*OU[1] + v*OV[1], o[2] + u*OU[2] + v*OV[2]} end
function quad(o, u0, u1, v0, v1) return poly({lp(o,u0,v0), lp(o,u1,v0), lp(o,u1,v1), lp(o,u0,v1)}) end
-- paint a box module: footprint u0..u1 along, v0..v1 across; side = lit strip width on +v side; cap at +u end
GR = {
  pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.4}},                 -- shadow gray
  pile{{"lead white",1},{"bone black",0.7},{"ultramarine blue",0.25},{"raw sienna",0.1}}, -- mid gray
  pile{{"lead white",2},{"bone black",0.35},{"ultramarine blue",0.15}},                -- light gray
  pile{{"lead white",3},{"bone black",0.08},{"lemon chrome",0.05}},                     -- sunlit
}
AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.2}}
function fillq(m, p, w)
  work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m, tool={kind="round", width=w or 1.4}, length={2, 6}})
end

--@ chunk 99
-- the MIRIAD outpost; O = anchor at spine surface (v=0 is the hull line), modules extend to +v (outward) and along u
function outpost(O, sc)
  sc = sc or 1
  local function Q(u0,u1,v0,v1) return quad(O, u0*sc, u1*sc, v0*sc, v1*sc) end
  -- 1. truss base plate bolted to the hull
  local base = Q(-16, 14, -2, 1.2)
  fillq(base, GR[1], 1.0)
  -- 2. main habitat module (long, along axis)
  local mf = Q(-12, 10, 1.2, 7.2)      -- front face
  local ms = Q(-12, 10, 7.2, 9.0)      -- sunlit side
  local mc = Q(10, 11.6, 1.2, 9.0)     -- top cap
  fillq(mf, GR[2]) fillq(ms, GR[4], 1.0) fillq(mc, GR[3], 1.0)
  -- 3. cross module projecting outward (perpendicular), lower
  local cf = Q(-10, -5, 9.0, 21)
  local cs = Q(-5, -3.8, 9.0, 21)      -- its upper face, catches light
  local ce = Q(-10, -3.8, 21, 22.4)    -- end face (sunlit)
  fillq(cf, GR[2]) fillq(cs, GR[3], 1.0) fillq(ce, GR[4], 1.0)
  -- 4. small box module upper, offset
  local bf = Q(12.5, 19, 1.2, 6.0)
  local bs = Q(12.5, 19, 6.0, 7.3)
  local bc = Q(19, 20.2, 1.2, 7.3)
  fillq(bf, GR[2]) fillq(bs, GR[4], 1.0) fillq(bc, GR[3], 1.0)
  -- 5. radiator panel: thin flat plane sticking out, edge-on-ish
  local rp = Q(2, 3.0, 9.0, 26)
  fillq(rp, GR[3], 0.9)
  -- 6. cargo / docking section at the lower end
  local kf = Q(-21, -12.5, 0.5, 5.5)
  local ks = Q(-21, -12.5, 5.5, 6.8)
  fillq(kf, GR[1]) fillq(ks, GR[3], 1.0)
  -- shadow (left side faces and cast shadow on hull) - painted to the -v side
  local sh = Q(-21, 20.2, -5.5, -2)
  work(sh, {hand="glaze", pile=GK, coverage=1.5, fill=true, clip=sh})
  -- amber hazard bands
  local b = brush{kind="round", width=0.7, point=0.3}
  b:load(AMB, 0.9)
  for i = 0, 4 do
    local v = 1.8 + i*1.3
    local p1 = lp(O, 10.0*sc, v*sc) local p2 = lp(O, 10.0*sc, (v+0.6)*sc)
    b:stroke({p1, p2}, {pressure={0.6,0.6}})
  end
  local q1 = lp(O, -7.5*sc, 21.7*sc) local q2 = lp(O, -7.5*sc, 21.7*sc)
  b:touch(q1[1], q1[2], {pressure=0.5})
  -- dark seams between modules
  local s = brush{kind="round", width=0.5, point=0.5}
  s:load(GR[1], 0.9)
  for _, u in ipairs({-6, -1, 4}) do
    s:stroke({lp(O, u*sc, 1.2*sc), lp(O, u*sc, 7.2*sc)}, {pressure={0.5,0.5}})
  end
  -- antenna mast + dish
  local a = brush{kind="round", width=0.45, point=0.6}
  a:load(GR[3], 0.9)
  a:stroke({lp(O, 20.2*sc, 4*sc), lp(O, 27*sc, 5*sc)}, {pressure={0.5,0.4}})
  local dc = lp(O, 27.5*sc, 5.2*sc)
  local dm = ellipse(dc[1], dc[2], 2.2*sc, 1.0*sc)
  fillq(dm, GR[3], 0.8)
end

--@ chunk 100
local x, y = SPt(165, 0.9) print(x, y) OUTPOST_O = {x, y} outpost(OUTPOST_O, 0.85)

--@ chunk 101
for _, p in ipairs({{390,205},{360,180},{330,160},{300,150},{420,170},{250,130}}) do print(p[1], p[2], SKY:at(p[1],p[2])) end

--@ chunk 102
function cuculus(hx, hy, ang, L, glow)
  glow = glow or 1
  local c, s = math.cos(ang), math.sin(ang)
  local function at(u, v) return {hx + c*u - s*v, hy + s*u + c*v} end
  local mid = at(L*0.3, 0)
  local function radial(rx, ry) return mask(function(x,y)
      local du = ((x - mid[1])*c + (y - mid[2])*s) / rx
      local dv = (-(x - mid[1])*s + (y - mid[2])*c) / ry
      local d = math.sqrt(du*du + dv*dv)
      return clamp(1 - d, 0, 1)^1.6 end) end
  if glow > 0 then
    local GL = pile{{"Mars orange",1},{"cadmium red",0.3},{"lead white",0.6},medium=0.5}
    local g = brush{kind="filbert", width=L*0.45, stiffness=0.3}
    g:load(GL, 0.25*glow)
    g:stroke({at(-L*0.1, 0), at(L*0.5, 0.3), at(L*1.15, 0.6)}, {pressure={0.35, 0.0}, ramps={0.1, 0.8}})
  end
  -- plume
  local PO = pile{{"Mars orange",1},{"cadmium red",0.4},{"cadmium yellow",0.6},{"lead white",0.5}}
  local PY = pile{{"lead white",2},{"cadmium yellow",1},{"chrome yellow",0.3}}
  local PW = pile{{"lead white",3},{"lemon chrome",0.15}}
  local r = brush{kind="round", width=4, point=0.9, stiffness=0.4}
  r:load(PO, 0.9)
  r:stroke({at(0, 0), at(L*0.5, 0.2), at(L, 0.4)}, {pressure={0.9, 0.0}, ramps={0.02, 0.95}})
  local y = brush{kind="round", width=3, point=0.9, stiffness=0.4}
  y:load(PY, 0.9)
  y:stroke({at(0, 0), at(L*0.35, 0.1), at(L*0.7, 0.2)}, {pressure={0.9, 0.0}, ramps={0.02, 0.95}})
  local w = brush{kind="round", width=2.4, point=0.6, stiffness=0.4}
  w:load(PW, 0.95)
  w:touch(at(0.6, 0)[1], at(0.6, 0)[2], {pressure=0.8})
  w:stroke({at(0.6, 0), at(L*0.2, 0.05), at(L*0.42, 0.1)}, {pressure={0.85, 0.0}, ramps={0.02, 0.9}})
  -- body
  local BK = pile{{"bone black",2},{"bone brown",1},{"Mars red",0.2}}
  local b = brush{kind="round", width=1.8, point=0.8, stiffness=0.5}
  b:load(BK, 0.9)
  b:stroke({at(-0.6, 0), at(-3, 0), at(-6.5, 0)}, {pressure={0.85, 0.2}, ramps={0.05, 0.6}})
  -- fins
  b:stroke({at(-4.5, 0), at(-6.8, 1.6)}, {pressure={0.5, 0.1}})
  b:stroke({at(-4.5, 0), at(-6.8, -1.6)}, {pressure={0.5, 0.1}})
end

--@ chunk 103
function trail(hx, hy, ang, len)
  local c, s = math.cos(ang), math.sin(ang)
  local function at(u, v) return {hx + c*u - s*v, hy + s*u + c*v} end
  local TC = pile{{"lead white",1},{"ultramarine blue",0.3},{"bone black",0.3}}
  local TW = pile{{"lead white",1},{"Mars orange",0.4},{"cadmium yellow",0.2}}
  local r = brush{kind="rigger", width=1.2, point=1, stiffness=0.3}
  r:load(TC, 0.35)
  local pts = {}
  for i = 0, 20 do local u = -6 - len * (i/20) pts[#pts+1] = at(u, 0.002*u*u*0.0 + 0.0) end
  r:stroke(pts, {pressure={0.4, 0.0}, ramps={0.05, 0.9}})
  local w = brush{kind="rigger", width=1.6, point=1, stiffness=0.3}
  w:load(TW, 0.6)
  w:stroke({at(-5, 0), at(-20, 0), at(-45, 0)}, {pressure={0.55, 0.0}, ramps={0.02, 0.9}})
end

--@ chunk 104
CUC = {452, 143} local a = math.atan(OUTPOST_O[2] - 143, OUTPOST_O[1] - 452) print(a) trail(452, 143, a, 230) cuculus(452, 143, a, 17, 0.8)

--@ chunk 105
SG1 = pile{{"lead white",3},{"lemon chrome",0.3}}
SG2 = pile{{"lead white",2},{"yellow ochre",0.35},{"cadmium yellow",0.1},{"bone black",0.04}}
SG3 = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.3},{"ultramarine blue",0.2}}
SG4 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.5},{"yellow ochre",0.15}}
local sky = SKY - SPOKES:grow(0.5)
local function ring(r0, r1, soft) return sky * mask(function(x,y) local d = math.sqrt((x-SUN[1])^2 + (y-SUN[2])^2) return (d >= r0 and d < r1) and 1 or 0 end):soften(soft or 12) end
local ang = function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
work(ring(270, 380, 20), {hand="body", pile=SG4, coverage=3, fill=true, clip=sky, angle=ang, edge="firm"})
work(ring(190, 285), {hand="body", pile=SG3, coverage=3, fill=true, clip=sky, angle=ang, edge="firm"})
work(ring(115, 200), {hand="body", pile=SG2, coverage=3, fill=true, clip=sky, angle=ang, edge="firm"})
work(ring(0, 125), {hand="body", pile=SG1, coverage=3.5, fill=true, clip=sky, angle=ang, edge="firm"})
local bl = ring(60, 400, 20)
blend(bl, {angle=ang})
blend(bl, {angle=function(x,y) return ang(x,y) + 0.5 end})
blend(bl, {angle=function(x,y) return ang(x,y) - math.pi/2 end})

--@ chunk 106
local SGK = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.25}}
local SG0 = pile{{"lead white",3},{"cadmium yellow",0.4},{"lemon chrome",0.3},{"Mars orange",0.05}}
local SG2w = pile{{"lead white",2},{"yellow ochre",0.5},{"cadmium yellow",0.2}}
local sky = SKY - SPOKES:grow(0.5)
local function ring(r0, r1, soft) return sky * mask(function(x,y) local d = math.sqrt((x-SUN[1])^2 + (y-SUN[2])^2) return (d >= r0 and d < r1) and 1 or 0 end):soften(soft or 12) end
local ang = function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
work(ring(330, 450, 25), {hand="body", pile=SGK, coverage=3, fill=true, clip=sky, angle=ang, edge="soft"})
work(ring(95, 175), {hand="body", pile=SG2w, coverage=2.5, fill=true, clip=sky, angle=ang, edge="soft"})
work(ring(0, 105), {hand="body", pile=SG0, coverage=3, fill=true, clip=sky, angle=ang, edge="soft"})
local bl = ring(40, 470, 20)
for i, da in ipairs({0, 0.6, -0.6, math.pi/2, 0.3}) do
  blend(bl, {angle=function(x,y) return ang(x,y) + da end})
end

--@ chunk 107
print(drying(950,240), drying(900,30)) local sky = SKY - SPOKES:grow(0.5)
local bl = sky * mask(function(x,y) local d = math.sqrt((x-SUN[1])^2 + (y-SUN[2])^2) return (d < 470) and 1 or 0 end):soften(20)
local ang = function(x,y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
for i, da in ipairs({0, math.pi/2, 0.8, -0.8, 0, math.pi/2}) do blend(bl, {angle=function(x,y) return ang(x,y) + da end, tool={kind="badger", width=60}}) end

--@ chunk 108
print(wait(10*24*60)) print(drying(950,240), drying(900,30), drying(980,250))

--@ chunk 109
local occ_far = -(SPV2 + HUB + M_near():grow(0.5) + SPOKES)
local function edge_line(R, ax, t0, t1, sign, clipm, wmax)
  -- sign +1: outward normal, -1: inward normal
  local segs = {}
  local cur = nil
  for i = 0, 600 do
    local t = t0 + (t1 - t0) * i / 600
    local L = sign * (math.cos(t) - 0.35*math.sin(t)) / 1.06
    local x, y, s = P(t, R, ax)
    if L > 0.12 and x > -5 and x < 1005 and y > -5 and y < 567 then
      cur = cur or {}
      cur[#cur+1] = {x, y, L}
    else
      if cur and #cur > 3 then segs[#segs+1] = cur end
      cur = nil
    end
  end
  if cur and #cur > 3 then segs[#segs+1] = cur end
  local b = brush{kind="round", width=wmax or 1.6, point=0.8, stiffness=0.4}
  for _, sg in ipairs(segs) do
    -- split into short runs so pressure can follow L
    local n = #sg
    local step = 25
    for a = 1, n - 1, step do
      local e = math.min(n, a + step)
      local pts = {}
      for k = a, e do pts[#pts+1] = {sg[k][1], sg[k][2]} end
      local La, Le = sg[a][3], sg[e][3]
      local Lm = (La + Le) / 2
      local pile_ = Lm > 0.7 and RP[7] or (Lm > 0.4 and RP[6] or RP[5])
      b:load(pile_, 0.85)
      b:stroke(pts, {pressure={0.25 + 0.4*La, 0.25 + 0.4*Le}, ramps={0.0, 0.0}, clip=clipm})
    end
  end
  return #segs
end
print(edge_line(RO, HW, math.pi, 2*math.pi + 0.1, 1, occ_far))   -- far outer top edge
print(edge_line(RI, HW, math.pi - 0.2, 2*math.pi, -1, occ_far))   -- far inner top edge
print(edge_line(RO, HW, -0.25, math.pi, 1, nil))                   -- near outer top edge
print(edge_line(RI, HW, 0, math.pi + 0.2, -1, nil))        -- near inner top edge

--@ chunk 110
print(wait(5*24*60)) print(drying(950,240), drying(900,30), drying(980,250), drying(990,40))

--@ chunk 111
local C = {1045, 240}
local sky = SKY - SPOKES:grow(0.5)
local function ring(r0, r1, soft) return sky * mask(function(x,y) local d = math.sqrt((x-C[1])^2 + (y-C[2])^2) return (d >= r0 and d < r1) and 1 or 0 end):soften(soft or 8) end
local ang = function(x,y) return math.atan(y - C[2], x - C[1]) + math.pi/2 end
local A = pile{{"lead white",3},{"lemon chrome",0.25}}
local B = pile{{"lead white",2.5},{"cadmium yellow",0.35},{"yellow ochre",0.2}}
local Cc = pile{{"lead white",1.5},{"yellow ochre",0.4},{"bone black",0.12},{"ultramarine blue",0.06}}
work(ring(100, 150), {hand="body", pile=Cc, coverage=2.5, fill=true, clip=sky, angle=ang, edge="soft"})
work(ring(68, 108), {hand="body", pile=B, coverage=3, fill=true, clip=sky, angle=ang, edge="soft"})
work(ring(0, 75), {hand="body", pile=A, coverage=3.5, fill=true, clip=sky, angle=ang, edge="soft"})
local bl = ring(40, 175, 15)
for _, da in ipairs({0, math.pi/2, 0.5}) do blend(bl, {angle=function(x,y) return ang(x,y) + da end, tool={kind="badger", width=25}}) end

--@ chunk 112
local C = {1045, 240}
local sky = SKY - SPOKES:grow(0.5)
local function ring(r0, r1, soft) return sky * mask(function(x,y) local d = math.sqrt((x-C[1])^2 + (y-C[2])^2) return (d >= r0 and d < r1) and 1 or 0 end):soften(soft or 8) end
local ang = function(x,y) return math.atan(y - C[2], x - C[1]) + math.pi/2 end
local S0 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",1.1},{"yellow ochre",0.1}}
local S1 = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",1.3},{"yellow ochre",0.25}}
work(ring(150, 200, 10), {hand="body", pile=S0, coverage=3, fill=true, clip=sky, angle=ang, edge="soft"})
work(ring(118, 158, 8), {hand="body", pile=S1, coverage=3, fill=true, clip=sky, angle=ang, edge="soft"})
local bl = ring(70, 205, 10)
for _, da in ipairs({0, math.pi/2, 0.5, 0}) do blend(bl, {angle=function(x,y) return ang(x,y) + da end, tool={kind="badger", width=25}}) end

--@ chunk 113
QP = {}
for i, m in ipairs({
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.12}},
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.3},{"yellow ochre",0.1}},
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.7},{"yellow ochre",0.2}},
 {{"bone black",1},{"ultramarine blue",0.4},{"lead white",1},{"yellow ochre",0.3}},
 {{"bone black",0.4},{"lead white",1.5},{"yellow ochre",0.3},{"ultramarine blue",0.1}},
 {{"lead white",2},{"yellow ochre",0.3},{"bone black",0.1}},
 {{"lead white",2.5},{"cadmium yellow",0.3},{"yellow ochre",0.1}},
 {{"lead white",3},{"lemon chrome",0.25}},
}) do QP[i] = pile(m) end
function q_paint(cells, width, clipm)
  local groups = {}
  for _, c in ipairs(cells) do local i = clamp(c.idx, 1, 8) groups[i] = groups[i] or {} table.insert(groups[i], c) end
  local b = brush{kind="filbert", width=width, stiffness=0.5}
  for i = 1, 8 do
    local g = groups[i]
    if g then
      b:reload(QP[i], 0.8)
      for n, c in ipairs(g) do
        if n % 4 == 0 then b:load(QP[i], 0.8) end
        local h = c.len/2
        local ca, sa = math.cos(c.ang), math.sin(c.ang)
        b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={0.7, 0.55}, ramps={0.15,0.3}, clip=clipm})
      end
    end
  end
end
GLC = {1060, 238}
function glare_v(x, y)
  local d = math.sqrt((x-GLC[1])^2 + ((y-GLC[2])*1.15)^2)
  return clamp(1 - d/430, 0, 1)^1.9
end
local sky = SKY - SPOKES:grow(0.5)
local cells = {}
for pass = 0, 1 do
  for y = -2 + pass*2, 566, 4 do
    for x = 560 + pass*3, 1004, 6 do
      local xx, yy = x + rand(-1.5,1.5), y + rand(-1.2,1.2)
      if sky:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.2 then
        local v = glare_v(xx, yy)
        if v > 0.0 then
          local idx = math.floor(1 + v*7.6 + randn(0, 0.35) + 0.5)
          local a = math.atan(yy - GLC[2], xx - GLC[1]) + math.pi/2
          cells[#cells+1] = {x=xx, y=yy, ang=a + randn(0,0.1), len=rand(8,13), idx=idx}
        end
      end
    end
  end
end
print(#cells)
q_paint(cells, 5, sky)

--@ chunk 114
local sky = SKY - SPOKES:grow(0.5)
local cells = {}
for pass = 0, 1 do
  for y = -2 + pass*2, 566, 4 do
    for x = 600 + pass*3, 1004, 6 do
      local xx, yy = x + rand(-1.5,1.5), y + rand(-1.2,1.2)
      if sky:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.2 then
        local v = glare_v(xx, yy)
        if v < 0.05 then
          local idx = (rand(0,1) < 0.5) and 1 or 2
          local a = math.atan(yy - GLC[2], xx - GLC[1]) + math.pi/2
          cells[#cells+1] = {x=xx, y=yy, ang=a + randn(0,0.1), len=rand(8,13), idx=idx}
        end
      end
    end
  end
end
print(#cells)
q_paint(cells, 5, sky)

--@ chunk 115
local sky = SKY - SPOKES:grow(0.5)
local m = sky * mask(function(x,y) return glare_v(x,y) > 0.03 and 1 or 0 end)
blend(m, {angle=function(x,y) return math.atan(y - GLC[2], x - GLC[1]) + math.pi/2 end, tool={kind="badger", width=14}})

--@ chunk 116
local sky = SKY - SPOKES:grow(1)
local ST1 = pile{{"lead white",3},{"cerulean blue",0.05}}
local ST2 = pile{{"lead white",2},{"bone black",0.3},{"ultramarine blue",0.3}}
local ST3 = pile{{"lead white",3},{"yellow ochre",0.15}}
local function ok(x, y) return x > 2 and x < 998 and y > 2 and y < 560 and sky:shrink(2):at(x, y) > 0.5 and glare_v(x,y) < 0.02 and math.abs((y - 143) - (x - 452)*math.tan(-0.1358)) > 4 end
-- faint specks
local b = brush{kind="round", width=0.7, point=0.5, stiffness=0.6}
b:load(ST2, 0.6)
local n = 0
local cl = worley{seed=7, period=140, jitter=0.9}
for i = 1, 900 do
  local x, y = rand(0, 1000), rand(0, 562)
  local d = cl:at(x, y)
  if ok(x, y) and rand(0,1) < 0.35 then
    n = n + 1
    if n % 15 == 0 then b:load(ST2, 0.6) end
    b:touch(x, y, {pressure=rand(0.15, 0.4)})
  end
end
-- small stars
local r = brush{kind="round", width=1.1, point=0.5, stiffness=0.6}
r:load(ST1, 0.8)
local m = 0
for i = 1, 140 do
  local x, y = rand(0, 1000), rand(0, 562)
  if ok(x, y) then
    m = m + 1
    if m % 10 == 0 then r:load((m % 20 == 0) and ST3 or ST1, 0.8) end
    r:touch(x, y, {pressure=rand(0.35, 0.65)})
  end
end
print(n, m)

--@ chunk 117
local GOLD = math.pi * (3 - math.sqrt(5))
-- spine
local d = 5.2
local dz = d*d*0.866 / (2*math.pi*SR)
local pl = {}
local k = 0
while true do
  k = k + 1
  local ax = -230 + k*dz
  if ax > 360 then break end
  local th = (k*GOLD) % (2*math.pi)
  if th > math.pi then th = th - 2*math.pi end
  local c = math.cos(th)
  if c > 0.1 then
    local w = math.sin(th)
    if w > 0.3 then
      local x, y, s = SPt(ax, w)
      if SPV:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 then
        local L = clamp((w - 0.3)/0.6, 0, 1)
        local p = {x=x + randn(0,0.2), y=y + randn(0,0.2), at=GA, aa=math.atan(GV[2], GV[1]), Lt=d*1.1*c*s*rand(0.9,1.1), La=d*1.15*CE*s*rand(0.9,1.1), ax=ax, L=L}
        p.gl = clamp(0.3 + 0.7*L, 0.2, 1)
        pl[#pl+1] = p
      end
    end
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
CLIP = SPV
scale_shadows(pl, D, 1.0, 0.5)
local lt = {}
for _, p in ipairs(pl) do if rand(0,1) < 0.25 + 0.6*p.L then lt[#lt+1] = p end end
scale_glints(lt, RP[8], 0.85, 0.5)
print(#pl, #lt)
-- near arc
local near = M_near()
d = 6.2
local ds = 0.866*d*d/(2*HW+10)
pl = {}
k = 0
while true do
  k = k + 1
  local s_ = 0.98*RO + k*ds
  local t = s_ / RO
  if t > 1.5 then break end
  local ax = HW - ((k*PHI) % 1) * (2*HW + 10)
  local x, y = P(t, RO, ax)
  if x > -5 and x < 1005 and y < 568 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 then
    local L = clamp((1.45 - t)/0.25, 0, 1)
    local xa, ya = P(t + 0.002, RO, ax)
    local xb, yb = P(t, RO, ax - 1)
    local lt_ = math.sqrt((xa-x)^2 + (ya-y)^2) / (0.002*RO)
    local la = math.sqrt((xb-x)^2 + (yb-y)^2)
    local p = {x=x + randn(0,0.25), y=y + randn(0,0.25), at=math.atan(y - ya, x - xa), aa=math.atan(yb - y, xb - x),
               Lt=d*1.1*lt_*rand(0.9,1.1), La=d*1.15*la*rand(0.9,1.1), ax=ax, L=L}
    p.gl = clamp(0.3 + 0.7*L, 0.2, 1)
    pl[#pl+1] = p
  end
end
table.sort(pl, function(a,b) return a.ax < b.ax end)
CLIP = near
scale_shadows(pl, D, 1.2, 0.55)
lt = {}
for _, p in ipairs(pl) do if rand(0,1) < 0.25 + 0.6*p.L then lt[#lt+1] = p end end
scale_glints(lt, RP[8], 1.0, 0.5)
CLIP = nil
print(#pl, #lt)

--@ chunk 118
DR = {
 pile{{"bone black",3},{"bone brown",1},{"ultramarine blue",0.4}},
 pile{{"bone black",2},{"bone brown",1},{"raw sienna",0.3},{"lead white",0.1}},
 pile{{"bone brown",2},{"bone black",1},{"raw sienna",0.4},{"ultramarine blue",0.2}},
 pile{{"raw sienna",1},{"bone brown",1},{"bone black",0.5},{"ultramarine ash",0.3}},
}
function dark_paint(cells, width, clipm)
  local groups = {}
  for _, c in ipairs(cells) do local i = clamp(c.idx, 1, 4) groups[i] = groups[i] or {} table.insert(groups[i], c) end
  local b = brush{kind="filbert", width=width, stiffness=0.5}
  for i = 1, 4 do
    local g = groups[i]
    if g then
      b:reload(DR[i], 0.85)
      for n, c in ipairs(g) do
        if n % 4 == 0 then b:load(DR[i], 0.85) end
        local h = c.len/2
        local ca, sa = math.cos(c.ang), math.sin(c.ang)
        b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={0.75, 0.6}, ramps={0.12,0.25}, clip=clipm})
      end
    end
  end
end
function didx(v) local f = v/0.08 + 1 + randn(0, 0.3) return math.floor(f) end
function vspine(w, x, y) return 0.03 + 0.8*smoothstep(0.25, 0.62, w) + 0.05*smoothstep(-0.55, -0.95, w) end
function vnear(t) return 0.03 + 0.8*(1 - smoothstep(1.2, 1.48, t)) + 0.05*smoothstep(2.3, 2.75, t) end
local nz = noise{seed=118, period=40, octaves=3}
for pass = 0, 1 do
  local cells = {}
  for ax = -250 + pass*2.2, 370, 4.4 do
    for w = -1.0 + pass*0.05, 0.6, 0.1 do
      local ww = clamp(w + rand(-0.04, 0.04), -0.99, 0.99)
      local x, y = SPt(ax + rand(-1.5, 1.5), ww)
      if SPV2:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local v = vspine(ww) + 0.03*nz(x,y)
        if v < 0.3 then
          local c = math.sqrt(1 - ww*ww)
          cells[#cells+1] = {x=x, y=y, ang=GA + randn(0,0.06), len=rand(10,15)*(0.35+0.65*c), idx=didx(v)}
        end
      end
    end
  end
  dark_paint(cells, 6, SPV2)
  print(#cells)
end

--@ chunk 119
local nz = noise{seed=119, period=40, octaves=3}
local near = M_near()
for pass = 0, 1 do
  local cells = {}
  for t = 1.15 + pass*0.006, 2.95, 0.012 do
    for ax = -HW - 14 + pass*2.6, HW + 2, 5.2 do
      local tt = t + rand(-0.004, 0.004)
      local x, y = P(tt, RO, ax + rand(-1.5, 1.5))
      if x > -10 and x < 1010 and y < 570 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
        local v = vnear(tt) + 0.03*nz(x,y)
        if v < 0.3 then
          cells[#cells+1] = {x=x, y=y, ang=ring_tangent(tt, RO, ax) + randn(0,0.05), len=rand(11,17)*(0.35 + 0.65*math.abs(math.sin(tt))), idx=didx(v)}
        end
      end
    end
  end
  dark_paint(cells, 6, near)
  print(#cells)
end
-- hub: dark except its lit right/front rim
local cells = {}
for pass = 0, 1 do
  for i = 1, 2600 do
    local x, y = rand(GC[1]-160, GC[1]+160), rand(GC[2]-80, GC[2]+70)
    if HUB:at(clamp(x,0,999), clamp(y,0,562)) > 0.1 then
      local t = hub_t(x, y)
      local L = math.cos(t) - 0.35*math.sin(t)
      local v = 0.03 + 0.8*smoothstep(0.35, 0.85, L) + 0.03*nz(x,y)
      if v < 0.3 then
        cells[#cells+1] = {x=x, y=y, ang=ring_tangent(t, HR, 0) + randn(0,0.05), len=rand(6,10), idx=didx(v)}
      end
    end
  end
end
dark_paint(cells, 4.5, HUB)
print(#cells)

--@ chunk 120
print(wait(10*24*60)) print(drying(560,200), drying(300,480), drying(640,300), drying(930,450))

--@ chunk 121
print(wait(10*24*60)) print(drying(560,200), drying(300,480), drying(640,300), drying(672,113))

--@ chunk 122
-- the MIRIAD outpost; O = anchor at spine surface (v=0 is the hull line), modules extend to +v (outward) and along u
function outpost(O, sc)
  sc = sc or 1
  local function Q(u0,u1,v0,v1) return quad(O, u0*sc, u1*sc, v0*sc, v1*sc) end
  local sh = Q(-22, 21, -7, -1.5)
  fillq(sh, DR[2], 1.2)
  -- 1. truss base plate bolted to the hull
  local base = Q(-16, 14, -2, 1.2)
  fillq(base, GR[1], 1.0)
  -- 2. main habitat module (long, along axis)
  local mf = Q(-12, 10, 1.2, 7.2)      -- front face
  local ms = Q(-12, 10, 7.2, 9.0)      -- sunlit side
  local mc = Q(10, 11.6, 1.2, 9.0)     -- top cap
  fillq(mf, GR[2]) fillq(ms, GR[4], 1.0) fillq(mc, GR[3], 1.0)
  -- 3. cross module projecting outward (perpendicular), lower
  local cf = Q(-10, -5, 9.0, 21)
  local cs = Q(-5, -3.8, 9.0, 21)      -- its upper face, catches light
  local ce = Q(-10, -3.8, 21, 22.4)    -- end face (sunlit)
  fillq(cf, GR[2]) fillq(cs, GR[3], 1.0) fillq(ce, GR[4], 1.0)
  -- 4. small box module upper, offset
  local bf = Q(12.5, 19, 1.2, 6.0)
  local bs = Q(12.5, 19, 6.0, 7.3)
  local bc = Q(19, 20.2, 1.2, 7.3)
  fillq(bf, GR[2]) fillq(bs, GR[4], 1.0) fillq(bc, GR[3], 1.0)
  -- 5. radiator panel: thin flat plane sticking out, edge-on-ish
  local rp = Q(2, 3.0, 9.0, 26)
  fillq(rp, GR[3], 0.9)
  -- 6. cargo / docking section at the lower end
  local kf = Q(-21, -12.5, 0.5, 5.5)
  local ks = Q(-21, -12.5, 5.5, 6.8)
  fillq(kf, GR[1]) fillq(ks, GR[3], 1.0)
  -- shadow (left side faces and cast shadow on hull) - painted to the -v side

  -- amber hazard bands
  local b = brush{kind="round", width=0.7, point=0.3}
  b:load(AMB, 0.9)
  for i = 0, 4 do
    local v = 1.8 + i*1.3
    local p1 = lp(O, 10.0*sc, v*sc) local p2 = lp(O, 10.0*sc, (v+0.6)*sc)
    b:stroke({p1, p2}, {pressure={0.6,0.6}})
  end
  local q1 = lp(O, -7.5*sc, 21.7*sc) local q2 = lp(O, -7.5*sc, 21.7*sc)
  b:touch(q1[1], q1[2], {pressure=0.5})
  -- dark seams between modules
  local s = brush{kind="round", width=0.5, point=0.5}
  s:load(GR[1], 0.9)
  for _, u in ipairs({-6, -1, 4}) do
    s:stroke({lp(O, u*sc, 1.2*sc), lp(O, u*sc, 7.2*sc)}, {pressure={0.5,0.5}})
  end
  -- antenna mast + dish
  local a = brush{kind="round", width=0.45, point=0.6}
  a:load(GR[3], 0.9)
  a:stroke({lp(O, 20.2*sc, 4*sc), lp(O, 27*sc, 5*sc)}, {pressure={0.5,0.4}})
  local dc = lp(O, 27.5*sc, 5.2*sc)
  local dm = ellipse(dc[1], dc[2], 2.2*sc, 1.0*sc)
  fillq(dm, GR[3], 0.8)
end

--@ chunk 123
outpost(OUTPOST_O, 0.85)

--@ chunk 124
local near = M_near():shrink(1.5)
local darkn = near * mask(function(x,y) return near_t(x) > 1.4 and 1 or 0 end)
local lit = {}
local dummy = {}
local rows = {30, 12, -8, -30, -52, -70}
for i, ax in ipairs(rows) do
  ring_row(RO + 0.5, ax + rand(-2,2), 1.35, 2.85, 3.0 + i*0.25, {4, 18}, 10 + 3*i, 0.9, dummy, darkn, 0.16, lit)
end
print(#lit)
local WL1 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.15}}
local WL2 = pile{{"lead white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
local a, b = {}, {}
for _, w in ipairs(lit) do if rand(0,1) < 0.6 then a[#a+1] = w else b[#b+1] = w end end
paint_dots(a, WL1, 1.05, 0.75, near, 6)
paint_dots(b, WL2, 0.95, 0.7, near, 6)
-- spine dark side: lit apertures along golden spiral rows
local GOLD = math.pi * (3 - math.sqrt(5))
local sp = {}
local k = 0
local spd = SPV * mask(function(x,y) return spine_w(x,y) < 0.15 and 1 or 0 end)
for k = 1, 4000 do
  local ax = -230 + k*0.15
  local th = (k*GOLD*8) % (2*math.pi)
  local w = math.sin(th)
  if math.cos(th) > 0.15 and w < 0.1 then
    local x, y = SPt(ax, w)
    if spd:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 and rand(0,1) < 0.035 then
      sp[#sp+1] = {x=x, y=y, ang=GA, len=0.6}
    end
  end
end
print(#sp)
paint_dots(sp, WL1, 0.95, 0.7, SPV, 6)

--@ chunk 125
local near = M_near():shrink(1.5)
local darkn = near * mask(function(x,y) return near_t(x) > 1.38 and 1 or 0 end)
local lit, dummy = {}, {}
local rows = {34, 24, 14, 2, -12, -26, -40, -56, -72}
for i, ax in ipairs(rows) do
  ring_row(RO + 0.5, ax + rand(-1.5,1.5), 1.35, 2.85, 2.6 + (i%3)*0.4, {3, 14}, 8 + 2*i, 0.9, dummy, darkn, 0.3, lit)
end
print(#lit)
local WL1 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.15}}
local WL2 = pile{{"lead white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
local WL3 = pile{{"Indian yellow",1},{"Mars orange",0.5},{"lead white",0.6}}
local a, b, c = {}, {}, {}
for _, w in ipairs(lit) do local r = rand(0,1) if r < 0.45 then a[#a+1] = w elseif r < 0.8 then b[#b+1] = w else c[#c+1] = w end end
paint_dots(a, WL1, 1.0, 0.72, near, 6)
paint_dots(b, WL2, 0.95, 0.7, near, 6)
paint_dots(c, WL3, 0.9, 0.65, near, 6)

--@ chunk 126
local near = M_near():shrink(1.5)
local darkn = near * mask(function(x,y) return near_t(x) > 1.38 and 1 or 0 end)
local lit, dummy = {}, {}
local rows = {38, 30, 20, 8, -4, -18}
for i, ax in ipairs(rows) do
  ring_row(RO + 0.5, ax + rand(-1.5,1.5), 1.35, 2.85, 2.6 + (i%3)*0.4, {3, 14}, 8 + 2*i, 0.9, dummy, darkn, 0.32, lit)
end
local WL1 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.15}}
local WL2 = pile{{"lead white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
local a, b = {}, {}
for _, w in ipairs(lit) do if rand(0,1) < 0.55 then a[#a+1] = w else b[#b+1] = w end end
paint_dots(a, WL1, 1.0, 0.72, near, 6)
paint_dots(b, WL2, 0.95, 0.7, near, 6)
-- far inner face (dark part): rows of windows, a few lit
local fd = FARV:shrink(1) * mask(function(x,y) return x > 520 and 1 or 0 end)
local lit2 = {}
for i, ax in ipairs({30, 15, 0, -15, -30, -50}) do
  ring_row(RI - 0.5, ax, 4.4, 2*math.pi + 0.2, 2.2, {3, 10}, 10 + 2*i, 0.7, dummy, fd, 0.22, lit2)
end
paint_dots(lit2, WL2, 0.85, 0.65, FARV, 6)
print(#lit, #lit2)

--@ chunk 127
print(P(1.24, RO, -5)) print(P(1.18, RO, 30)) print(P(1.30, RO, -40)) print(drying(950,450))

--@ chunk 128
local T0, A0 = 1.24, -5
local function S(u, a, depth) local x, y = P(T0 + u/RO, RO - (depth or 0), A0 + a) return {x, y} end
-- hole outline in surface coords (irregular)
local nz = noise{seed=128, period=12, octaves=3}
local outline_pts = {}
for i = 0, 47 do
  local th = i/48 * 2*math.pi
  local r = 1 + 0.22*nz(math.cos(th)*20, math.sin(th)*20) + 0.08*math.sin(3*th + 1)
  outline_pts[#outline_pts+1] = S(21*r*math.cos(th), 19*r*math.sin(th))
end
HOLE = poly(outline_pts, true)
-- 1) interior dark
work(HOLE, {hand="detail", pile=DR[1], coverage=3.5, fill=true, clip=HOLE, tool={kind="round", width=2.2}, length={3, 8}})
-- 2) the inner wall facing the light (left/back edge of the hole is lit by the raking sun): thin warm lit crescent along left side
local rimL, rimR = {}, {}
for i = 0, 30 do
  local th = math.pi*0.55 + i/30 * math.pi*0.95
  local r = 1 + 0.22*nz(math.cos(th)*20, math.sin(th)*20) + 0.08*math.sin(3*th + 1)
  rimL[#rimL+1] = S(21*r*math.cos(th)*0.9, 19*r*math.sin(th)*0.9, 4)
end
local b = brush{kind="round", width=2.0, point=0.6}
b:load(RP[6], 0.9)
b:stroke(rimL, {pressure={0.3, 0.3}, swell={0.4, 1.0, 1.2, 0.8, 0.3}, clip=HOLE})
-- 3) spiral chambers: golden spiral, centre offset in the hole
local cu, ca = 2, 1
local bsp = math.log((1 + math.sqrt(5))/2) / (math.pi/2)
local function spiral(th, depth) local r = 1.1*math.exp(bsp*th) return S(cu + r*math.cos(th), ca + r*math.sin(th)*0.95, depth) end
local sp = {}
for i = 0, 140 do local th = i/140 * 4.2*math.pi sp[#sp+1] = spiral(th, 6) end
local s1 = brush{kind="round", width=1.3, point=0.7}
s1:load(RP[5], 0.9)
s1:stroke(sp, {pressure={0.25, 0.55}, clip=HOLE:shrink(1)})
-- septa: from the spiral at th to the inner whorl at th - 2pi
local s2 = brush{kind="round", width=1.0, point=0.7}
s2:load(RP[5], 0.9)
local th = 2*math.pi + 0.3
local k = 0
while th < 4.2*math.pi do
  k = k + 1
  if k % 4 == 0 then s2:load(RP[5], 0.9) end
  local a1 = spiral(th, 6)
  local a0 = spiral(th - 2*math.pi + 0.25, 6)
  local mid = spiral(th - math.pi, 6)
  local m = {(a1[1] + a0[1])/2 + (mid[1] - (a1[1]+a0[1])/2)*0.0, (a1[2] + a0[2])/2}
  -- bow septum slightly toward the spiral centre
  local c = S(cu, ca, 6)
  local bw = {m[1] + (c[1] - m[1])*0.12, m[2] + (c[2] - m[2])*0.12}
  s2:stroke({a1, bw, a0}, {pressure={0.4, 0.25}, clip=HOLE:shrink(1)})
  th = th + 0.62 * (1 + 0.15*math.sin(k))
end
-- 4) the hull's broken edge: lit lip on the right/lower edge (facing the sun) and dark undercut shadow
local lip = {}
for i = 0, 26 do
  local t2 = -math.pi*0.45 + i/26 * math.pi*0.85
  local r = 1 + 0.22*nz(math.cos(t2)*20, math.sin(t2)*20) + 0.08*math.sin(3*t2 + 1)
  lip[#lip+1] = S(21*r*math.cos(t2)*1.02, 19*r*math.sin(t2)*1.02)
end
local l = brush{kind="round", width=1.4, point=0.6}
l:load(RP[8], 0.9)
l:stroke(lip, {pressure={0.2, 0.45}, swell={0.5, 1.2, 1, 0.6}})

--@ chunk 129
local T0, A0 = 1.24, -5
local function S(u, a, depth) local x, y = P(T0 + u/RO, RO - (depth or 0), A0 + a) return {x, y} end
local cu, ca = 2, 1
local bsp = math.log((1 + math.sqrt(5))/2) / (math.pi/2)
local function spiral(th, f) local r = 1.1*math.exp(bsp*th)*(f or 1) return S(cu + r*math.cos(th), ca + r*math.sin(th)*0.95, 6) end
-- chamber cells: between th and th+dth, radial fraction 0.62..0.97 of the whorl gap
local th = 2*math.pi*0.5
local k = 0
local inner = HOLE:shrink(1.2)
while th < 4.2*math.pi do
  k = k + 1
  local dth = 0.62 * (1 + 0.15*math.sin(k))
  local function W(t, f) -- point at angle t, fraction f between inner whorl (t-2pi) and outer (t)
    local o = spiral(t) local i = spiral(t - 2*math.pi)
    return {i[1] + (o[1]-i[1])*f, i[2] + (o[2]-i[2])*f}
  end
  local q = poly({W(th+0.05, 0.12), W(th+dth*0.55, 0.1), W(th+dth*0.55, 0.9), W(th+0.05, 0.92)}) * inner
  local shade = (k % 3 == 0) and RP[3] or RP[4]
  if q:area() > 0.5 then
    work(q, {hand="detail", pile=shade, coverage=2.5, fill=true, clip=q, tool={kind="round", width=1.0}, length={1.5, 4}})
  end
  th = th + dth
end
-- re-state the spiral wall as a lit line
local sp = {}
for i = 0, 160 do local t = 0.3 + i/160 * (4.2*math.pi - 0.3) sp[#sp+1] = spiral(t) end
local s1 = brush{kind="round", width=1.2, point=0.7}
s1:load(RP[6], 0.9)
s1:stroke(sp, {pressure={0.2, 0.6}, clip=inner})

--@ chunk 130
print(drying(950,240), drying(900,30), drying(990,260), drying(800,250))

--@ chunk 131
print(wait(10*24*60)) print(drying(950,240), drying(900,30), drying(990,260), drying(800,250), drying(955,450))

--@ chunk 132
GQ = {}
for i, m in ipairs({
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.12}},
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.45},{"Mars orange",0.08}},
 {{"lead white",1},{"bone black",0.6},{"ultramarine blue",0.3},{"raw sienna",0.2}},
 {{"lead white",1.5},{"yellow ochre",0.4},{"bone black",0.2},{"ultramarine blue",0.05}},
 {{"lead white",2},{"yellow ochre",0.4},{"cadmium yellow",0.15}},
 {{"lead white",2.5},{"cadmium yellow",0.35}},
 {{"lead white",3},{"lemon chrome",0.3}},
 {{"lead white",3},{"zinc white",1},{"lemon chrome",0.1}},
}) do GQ[i] = pile(m) end
GLC2 = {1035, 255}
function glare2(x, y)
  local dx, dy = x - GLC2[1], (y - GLC2[2])*1.25
  local d = math.sqrt(dx*dx + dy*dy)
  return clamp(1 - d/340, 0, 1)^2.0
end
local sky = SKY - SPOKES:grow(0.5)
local groups = {}
local cells = {}
for pass = 0, 1 do
  for y = -2 + pass*2, 566, 3.6 do
    for x = 640 + pass*2.5, 1004, 5 do
      local xx, yy = x + rand(-1.2,1.2), y + rand(-1,1)
      if sky:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.2 then
        local v = glare2(xx, yy)
        local idx = math.floor(1 + v*7.7 + randn(0, 0.3) + 0.5)
        local a = math.atan(yy - GLC2[2], xx - GLC2[1]) + math.pi/2
        cells[#cells+1] = {x=xx, y=yy, ang=a + randn(0,0.08), len=rand(7,11), idx=clamp(idx,1,8)}
      end
    end
  end
end
for _, c in ipairs(cells) do groups[c.idx] = groups[c.idx] or {} table.insert(groups[c.idx], c) end
local b = brush{kind="filbert", width=4.5, stiffness=0.5}
for i = 1, 8 do
  local g = groups[i]
  if g then
    b:reload(GQ[i], 0.85)
    for n, c in ipairs(g) do
      if n % 4 == 0 then b:load(GQ[i], 0.85) end
      local h = c.len/2
      local ca, sa = math.cos(c.ang), math.sin(c.ang)
      b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={0.75, 0.6}, ramps={0.12,0.25}, clip=sky})
    end
  end
end
print(#cells)

--@ chunk 133
local sky = SKY - SPOKES:grow(0.5)
local m = sky * mask(function(x,y) return x > 630 and 1 or 0 end)
local ang = function(x,y) return math.atan(y - GLC2[2], x - GLC2[1]) + math.pi/2 end
blend(m, {angle=ang, tool={kind="badger", width=16}})
blend(m, {angle=function(x,y) return ang(x,y) + math.pi/2 end, tool={kind="badger", width=16}})

--@ chunk 134
local function rim(ax0, ax1, w, pile_, width, pr, clipm)
  local pts = {}
  for ax = ax0, ax1, -4 do local x, y = SPt(ax, w) pts[#pts+1] = {x, y} end
  local b = brush{kind="rigger", width=width, point=0.9, stiffness=0.4}
  local n = #pts
  local seg = 18
  for a = 1, n - 1, seg do
    local e = math.min(n, a + seg)
    local sub = {}
    for k = a, e do sub[#sub+1] = pts[k] end
    b:load(pile_, 0.9)
    b:stroke(sub, {pressure={pr*rand(0.7,1), pr*rand(0.7,1)}, ramps={0.05,0.05}, clip=clipm})
  end
end
local clipS = SPV2:grow(0.6)
rim(470, 40, 0.975, RP[8], 1.6, 0.55, clipS)
rim(-30, -240, 0.975, RP[8], 1.6, 0.55, clipS)

--@ chunk 135
local hx, hy = 452, 143
local ang = math.atan(OUTPOST_O[2] - hy, OUTPOST_O[1] - hx)
local c, s = math.cos(ang), math.sin(ang)
local function at(u, v) return {hx + c*u - s*v, hy + s*u + c*v} end
-- soft halo: two light, low-load strokes of thin warm paint
local HL = pile{{"lead white",1},{"Mars orange",0.25},{"cadmium yellow",0.2},{"bone black",0.08},medium=0.6}
local g = brush{kind="filbert", width=9, stiffness=0.2}
g:load(HL, 0.18)
g:stroke({at(-6, 0), at(4, 0.5), at(16, 1)}, {pressure={0.25, 0.0}, ramps={0.2, 0.7}})
g:load(HL, 0.12)
g:stroke({at(-2, -3), at(6, 0), at(12, 3)}, {pressure={0.2, 0.0}, ramps={0.3, 0.6}})
-- plume core
local PY = pile{{"lead white",2},{"cadmium yellow",1},{"chrome yellow",0.3}}
local PW = pile{{"lead white",3},{"zinc white",1}}
local y = brush{kind="round", width=2.6, point=0.9, stiffness=0.4}
y:load(PY, 0.9)
y:stroke({at(0.5, 0), at(6, 0.1), at(12, 0.25)}, {pressure={0.85, 0.0}, ramps={0.02, 0.95}})
local w = brush{kind="round", width=2.0, point=0.7, stiffness=0.4}
w:load(PW, 0.95)
w:touch(at(0.8, 0)[1], at(0.8, 0)[2], {pressure=0.85})
w:stroke({at(0.8, 0), at(4, 0.05), at(7, 0.1)}, {pressure={0.8, 0.0}, ramps={0.02, 0.9}})
-- dark scorched body behind the flame
local BK = pile{{"bone black",2},{"bone brown",1},{"Mars red",0.25}}
local b = brush{kind="round", width=1.9, point=0.8, stiffness=0.5}
b:load(BK, 0.9)
b:stroke({at(-0.8, 0), at(-3.5, 0), at(-7, 0)}, {pressure={0.9, 0.25}, ramps={0.05, 0.6}})
-- glint on the nose rim
local r = brush{kind="rigger", width=0.9, point=1, stiffness=0.4}
r:load(PW, 0.9)
r:stroke({at(-1.2, -0.9), at(-3.8, -0.9)}, {pressure={0.4, 0.1}})
-- tiny cross flare
r:load(PW, 0.7)
r:stroke({at(0.8, -5), at(0.8, 0), at(0.8, 5)}, {pressure={0.0, 0.35, 0.0}, swell={0.1, 1, 0.1}})

--@ chunk 136
local T0, A0 = 1.24, -5
local function S(u, a) local x, y = P(T0 + u/RO, RO, A0 + a) return x, y end
local nz = noise{seed=128, period=12, octaves=3}
local d = brush{kind="round", width=2.2, point=0.3, stiffness=0.5}
local l = brush{kind="round", width=1.6, point=0.5, stiffness=0.5}
for i = 0, 40 do
  local th = i/41 * 2*math.pi + rand(-0.05, 0.05)
  local r = 1 + 0.22*nz(math.cos(th)*20, math.sin(th)*20) + 0.08*math.sin(3*th + 1)
  local rr = r * rand(1.02, 1.25)
  local x, y = S(21*rr*math.cos(th), 19*rr*math.sin(th))
  if rand(0,1) < 0.55 then
    d:load(DR[rand(0,1) < 0.5 and 1 or 2], 0.8)
    d:touch(x, y, {pressure=rand(0.4, 0.8), drag={rand(0.5,2), th + math.pi}})
  else
    l:load(RP[rand(0,1) < 0.5 and 4 or 5], 0.8)
    l:touch(x, y, {pressure=rand(0.4, 0.7)})
  end
end

--@ chunk 137
local T0, A0 = 1.24, -5
local function S(u, a) local x, y = P(T0 + u/RO, RO, A0 + a) return {x, y} end
local spots = {{-26, 8}, {-24, -6}, {-30, 2}, {22, 18}, {26, 6}, {-8, 24}, {6, 25}, {-14, -22}, {12, -22}, {30, -8}, {-36, -10}, {18, 28}}
for i, sp in ipairs(spots) do
  local u, a = sp[1] + rand(-2,2), sp[2] + rand(-2,2)
  local r = rand(2.6, 4.2)
  local pts = {}
  for k = 0, 11 do local th = k/12*2*math.pi pts[#pts+1] = S(u + r*math.cos(th)*rand(0.8,1.2), a + r*1.1*math.sin(th)*rand(0.8,1.2)) end
  local m = poly(pts, true)
  work(m, {hand="detail", pile=DR[1], coverage=3, fill=true, clip=m, tool={kind="round", width=1.2}, length={1.5, 4}})
  local lip = {S(u + r*0.9, a - r*0.4), S(u + r*0.6, a + r*0.7), S(u - r*0.2, a + r*1.05)}
  local l = brush{kind="round", width=1.0, point=0.6}
  l:load(RP[6], 0.85)
  l:stroke(lip, {pressure={0.35, 0.2}})
end

--@ chunk 138
print(wait(15*24*60)) print(drying(950,280), drying(900,30), drying(452,143), drying(955,450))

--@ chunk 139
print(wait(10*24*60)) print(drying(950,280), drying(900,30), drying(850,100), drying(990,100))

--@ chunk 140
local sky = SKY - SPOKES:grow(0.5)
local m1 = sky * mask(function(x,y) return glare2(x,y) > 0.03 and 1 or 0 end):soften(15)
local m2 = sky * mask(function(x,y) return glare2(x,y) > 0.25 and 1 or 0 end):soften(15)
local IY = pile{{"Indian yellow",1},{"lead white",0.15},medium=0.85}
local ang = function(x,y) return math.atan(y - GLC2[2], x - GLC2[1]) + math.pi/2 end
work(m1, {hand="glaze", pile=IY, coverage=0.7, fill=true, clip=sky, angle=ang})
work(m2, {hand="glaze", pile=IY, coverage=0.7, fill=true, clip=sky, angle=ang})

--@ chunk 141
print(wait(15*24*60)) print(drying(950,280), drying(900,60), drying(990,280))

--@ chunk 142
HQ = {}
for i, m in ipairs({
 {{"bone black",2},{"ultramarine blue",1},{"lead white",0.12}},
 {{"bone black",2},{"ultramarine blue",0.8},{"lead white",0.4},{"burnt sienna",0.2}},
 {{"lead white",1},{"bone black",0.55},{"burnt sienna",0.25},{"ultramarine blue",0.15}},
 {{"lead white",1.5},{"bone black",0.3},{"raw sienna",0.3},{"Mars orange",0.05}},
 {{"lead white",2},{"yellow ochre",0.35},{"Mars orange",0.08},{"bone black",0.06}},
 {{"lead white",2.5},{"cadmium yellow",0.3},{"Mars orange",0.05}},
 {{"lead white",3},{"lemon chrome",0.25}},
 {{"lead white",3},{"zinc white",1},{"lemon chrome",0.08}},
}) do HQ[i] = pile(m) end
function glare3(x, y)
  local dx, dy = x - GLC2[1], (y - GLC2[2])*1.2
  local d = math.sqrt(dx*dx + dy*dy)
  return clamp(1 - d/370, 0, 1)^2.1
end
local sky = SKY - SPOKES:grow(0.5)
local cells = {}
for pass = 0, 2 do
  for y = -2 + pass*1.2, 566, 3.4 do
    for x = 600 + pass*1.6, 1004, 4.6 do
      local xx, yy = x + rand(-1.2,1.2), y + rand(-1,1)
      if sky:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.2 then
        local v = glare3(xx, yy)
        if v > 0.004 then
          local idx = math.floor(1 + v*7.6 + randn(0, 0.28) + 0.5)
          if idx < 1 then idx = 1 end
          local a = math.atan(yy - GLC2[2], xx - GLC2[1]) + math.pi/2
          cells[#cells+1] = {x=xx, y=yy, ang=a + randn(0,0.07), len=rand(6,9), idx=clamp(idx,1,8)}
        end
      end
    end
  end
end
local groups = {}
for _, c in ipairs(cells) do groups[c.idx] = groups[c.idx] or {} table.insert(groups[c.idx], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 8 do
  local g = groups[i]
  if g then
    b:reload(HQ[i], 0.85)
    for n, c in ipairs(g) do
      if n % 4 == 0 then b:load(HQ[i], 0.85) end
      local h = c.len/2
      local ca, sa = math.cos(c.ang), math.sin(c.ang)
      b:stroke({{c.x - ca*h, c.y - sa*h}, {c.x + ca*h, c.y + sa*h}}, {pressure={0.75, 0.6}, ramps={0.12,0.25}, clip=sky})
    end
  end
end
print(#cells)

--@ chunk 143
local sky = SKY - SPOKES:grow(0.5)
local m = sky * mask(function(x,y) return glare3(x,y) > 0.0 and 1 or 0 end):soften(10)
local ang = function(x,y) return math.atan(y - GLC2[2], x - GLC2[1]) + math.pi/2 end
blend(m, {angle=ang, tool={kind="badger", width=10}})

--@ chunk 144
local sky = SKY - SPOKES:grow(0.5)
local m = sky * mask(function(x,y) return glare3(x,y) > 0.0 and 1 or 0 end):soften(10)
local ang = function(x,y) return math.atan(y - GLC2[2], x - GLC2[1]) + math.pi/2 end
blend(m, {angle=function(x,y) return ang(x,y) + math.pi/2 end, tool={kind="badger", width=8}, length={8, 18}})
blend(m, {angle=ang, tool={kind="badger", width=8}, length={8, 18}})

--@ chunk 145
local sky = SKY - SPOKES:grow(0.5)
local C = {1022, 262}
local function zone(r) return sky * mask(function(x,y) local dx, dy = x - C[1], (y - C[2])*1.3 return (math.sqrt(dx*dx+dy*dy) < r) and 1 or 0 end) end
local ang = function(x,y) return math.atan(y - C[2], x - C[1]) + math.pi/2 end
work(zone(70):soften(10), {hand="body", pile=HQ[7], coverage=2.5, fill=true, clip=sky, angle=ang, tool={kind="filbert", width=5}, length={6,12}})
work(zone(42):soften(8), {hand="body", pile=HQ[8], coverage=3, fill=true, clip=sky, angle=ang, tool={kind="filbert", width=5}, length={6,12}})
blend(zone(90):soften(10), {angle=ang, tool={kind="badger", width=8}, length={8, 16}})

--@ chunk 146
local WL1 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.15}}
local WL2 = pile{{"lead white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}
local hubd = HUB:shrink(1)
local lit, dummy = {}, {}
for i, ax in ipairs({-4, -11}) do
  ring_row(HR + 0.3, ax, 1.25, 3.3, 2.4, {3, 9}, 9, 0.6, dummy, hubd, 0.45, lit)
end
-- dome rows
for i, r in ipairs({HR*0.85, HR*0.72}) do
  ring_row(r, 30*(1 - (r - SR)/(HR - SR))^1.3, 1.6, 3.2, 2.6, {2, 7}, 12, 0.5, dummy, hubd, 0.3, lit)
end
paint_dots(lit, WL1, 0.9, 0.7, HUB, 6)
print(#lit)
-- running lights along two spokes (tiny, sparse)
local sl = {}
for _, t in ipairs({2.22, 2.95}) do
  for i = 1, 9 do
    local R = HR + 20 + (RI - HR - 40) * i / 9
    local x, y = P(t, R, 4)
    if SPOKES:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 then sl[#sl+1] = {x=x, y=y, ang=0, len=0.1} end
  end
end
paint_dots(sl, WL2, 0.8, 0.6, SPOKES, 6)
print(#sl)
-- outpost: amber hazard chevrons on the cross-module end and one dead amber beacon
local O, sc = OUTPOST_O, 0.85
local b = brush{kind="round", width=0.6, point=0.4}
b:load(AMB, 0.9)
for i = 0, 3 do
  local u = -9.5 + i*1.6
  b:stroke({lp(O, u*sc, 21.2*sc), lp(O, (u+0.8)*sc, 22.2*sc)}, {pressure={0.6,0.6}})
end
for i = 0, 2 do
  local v = 2 + i*2
  b:stroke({lp(O, -12*sc, v*sc), lp(O, -11.2*sc, (v+1)*sc)}, {pressure={0.6,0.6}})
end

--@ chunk 147
local HI = pile{{"lead white",3},{"lemon chrome",0.2},{"zinc white",0.5}}
local b = brush{kind="filbert", width=2.4, stiffness=0.5}
b:load(HI, 0.85)
local n = 0
-- spine specular streak around w = 0.72
for ax = -240, 380, 1.6 do
  local w = 0.72 + randn(0, 0.06)
  local x, y = SPt(ax, w)
  local x2, y2 = SPt(ax, w + 0.05)
  if SPV:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 and rand(0,1) < 0.55 then
    n = n + 1
    if n % 6 == 0 then b:load(HI, 0.85) end
    local L = rand(2, 5)
    b:stroke({{x, y}, {x + (x2-x)*0.4 - GV[1]*0 , y + (y2-y)*0.4 + L*0.0}, {x + GU[1]*L*0.3 - GV[1]*L, y + GU[2]*L*0.3 - GV[2]*L}}, {pressure={0.55, 0.2}, clip=SPV})
  end
end
-- near arc specular around t = 1.06
local near = M_near()
for ax = -HW - 14, HW, 1.5 do
  local t = 1.06 + randn(0, 0.025)
  local x, y = P(t, RO, ax)
  if x < 1000 and near:at(clamp(x,0,999), clamp(y,0,562)) > 0.5 and rand(0,1) < 0.6 then
    n = n + 1
    if n % 6 == 0 then b:load(HI, 0.85) end
    local a = ring_tangent(t, RO, ax)
    local L = rand(3, 6)
    b:stroke({{x, y}, {x + math.cos(a)*L, y + math.sin(a)*L}}, {pressure={0.55, 0.2}, clip=near})
  end
end
print(n)

--@ chunk 148
print(drying(720,80), drying(1000,260))

--@ chunk 149
local sky = SKY - SPOKES:grow(0.5)
local m = (ellipse(726, 80, 16, 22) + ellipse(912, 55, 14, 20) + ellipse(980, 65, 12, 10)):soften(4) * sky
local mix = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.3},{"burnt sienna",0.1}}
work(m, {hand="body", pile=mix, coverage=3, fill=true, clip=m, tool={kind="filbert", width=4}, length={5,10}, angle=-0.5})
blend(m:grow(3), {tool={kind="badger", width=6}, length={6,12}, angle=-0.5})

--@ chunk 150
print(wait(30*24*60))
