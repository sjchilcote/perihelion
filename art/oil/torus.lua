-- easel session "torus": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=31,
  ground={{pile={{"bone black",1},{"ultramarine ash",1},{"raw sienna",0.6},{"lead white",0.6}}, um=120, apply="knife", texture=0.3}}}
function hw(y) local d = y-300; if d > 0 then return 55 + 0.00563*d*d else return 55 + 0.00328*d*d end end
local L, R = {}, {}
for y=-5,630,5 do L[#L+1] = {500-hw(y), y}; R[#R+1] = {500+hw(y), y} end
local pts = {}
for i=1,#L do pts[#pts+1] = L[i] end
for i=#R,1,-1 do pts[#pts+1] = R[i] end
BAND = poly(pts)
LWALL = mask(function(x,y) return x < 500 - hw(y) and 1 or 0 end)
RWALL = mask(function(x,y) return x > 500 + hw(y) and 1 or 0 end)
WL = pile{{"bone black",1.2},{"ultramarine ash",1},{"lead white",0.35},{"raw sienna",0.2}}
WR = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.2},{"ultramarine blue",0.2}}
FL = pile{{"bone black",1.4},{"burnt sienna",0.5},{"ultramarine ash",0.8},{"lead white",0.15}}
work(LWALL, {hand="body", pile=WL, coverage=3, fill=true, clip=true, angle=1.5708})
work(RWALL, {hand="body", pile=WR, coverage=3, fill=true, clip=true, angle=1.5708})
work(BAND, {hand="body", pile=FL, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 2
VP = poly({{60,150},{290,175},{300,420},{50,455}}, true)
S1 = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
S2 = pile{{"lead white",2},{"cadmium yellow",1},{"chrome yellow",0.4}}
S3 = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.4}}
SX, SY = 170, 300
work(VP, {hand="body", tool="filbert 8", pile=S1, coverage=4, fill=true, clip=true, angle=0})
work(VP*ellipse(SX,SY,120,120), {hand="body", tool="filbert 8", pile=S2, coverage=4, fill=true, clip=true, angle=0})
work(VP*ellipse(SX,SY,70,70), {hand="body", tool="filbert 6", pile=S3, coverage=5, fill=true, clip=true, angle=0})
blend(VP*(ellipse(SX,SY,135,135) - ellipse(SX,SY,100,100)), {angle=0.8})
blend(VP*(ellipse(SX,SY,85,85) - ellipse(SX,SY,58,58)), {angle=0.8})

--@ chunk 3
function yt(t) if t >= 0 then return 300 + 325*t^1.7 else return 300 - 300*(-t)^1.7 end end
TRAY = pile{{"lead white",1},{"bone black",1},{"ultramarine ash",1},{"cerulean blue",0.15}}
TRAY_D = pile{{"bone black",1.6},{"ultramarine ash",1}}
SOIL = pile{{"bone brown",1.2},{"burnt sienna",0.5},{"bone black",0.5}}
BEDS = {}
local ts = {}
for k=1,10 do ts[#ts+1] = 0.03 + (k-1)*0.105 end
for k=1,10 do ts[#ts+1] = -(0.03 + (k-1)*0.105) end
for _,t in ipairs(ts) do
  local y = yt(t)
  local dy = math.abs(yt(t + 0.05) - yt(t - 0.05))
  local h = math.max(2.5, dy*0.55)
  local w = hw(y)*0.74
  if y > -20 and y < 650 then
    local up = t >= 0
    -- soil top face and tray front lip (front lip faces us: below the soil for floor beds, above for overhead)
    local soil = rect(500-w, y-h/2, 2*w, h)
    local lipH = math.max(1.5, h*0.35)
    local lip = up and rect(500-w, y+h/2, 2*w, lipH) or rect(500-w, y-h/2-lipH, 2*w, lipH)
    local tool = (h > 8) and "round 3" or "round 1.4"
    work(soil, {hand="detail", tool=tool, pile=SOIL, coverage=4, fill=true, clip=true, angle=0})
    work(lip, {hand="detail", tool=tool, pile=TRAY, coverage=4, fill=true, clip=true, angle=0})
    BEDS[#BEDS+1] = {t=t, y=y, h=h, w=w, up=up, lipH=lipH}
  end
end
print(#BEDS)

--@ chunk 4
wait(4*24*60)
print(drying(500,560), drying(500,100))
ET1 = pile{{"lead white",2},{"lemon chrome",0.5},{"yellow ochre",0.3}}
ET2 = pile{{"lead white",1},{"yellow ochre",1},{"raw sienna",0.4}}
ET3 = pile{{"lead white",1.2},{"yellow ochre",0.5},{"viridian",0.12},{"bone black",0.1}}
GRN = pile{{"viridian",0.6},{"cadmium yellow",1},{"lead white",0.8},{"yellow ochre",0.3}}
DEAD = pile{{"raw sienna",1},{"burnt sienna",0.5},{"bone black",0.3},{"lead white",0.3}}
local n = 0
for _,B in ipairs(BEDS) do
  local cnt = math.min(55, math.floor(B.w/5))
  local sgn = B.up and -1 or 1   -- stems grow away from the floor: up for our floor, down for the overhead floor
  local L = math.max(3, B.h*3.2)
  local wdt = math.max(0.6, math.min(2.6, B.h*0.18))
  local b = brush{kind="round", width=wdt, point=0.9}
  for i=1,cnt do
    local x = 500 - B.w + (i-0.5)*(2*B.w/cnt) + rand(-1,1)*B.w/cnt*0.4
    local y0 = B.y + rand(-0.3,0.3)*B.h
    -- lean toward the window: strongest for stems on the window side
    local dx = SX - x
    local lean = clamp(dx/600, -1, 0.2)
    local Ls = L*rand(0.6,1.25)
    local p
    local r = rand(0,1)
    if x < 470 and r < 0.18 then p = GRN elseif r < 0.55 then p = ET1 elseif r < 0.8 then p = ET3 elseif r < 0.93 then p = ET2 else p = DEAD end
    local pts = {{x,y0},{x + lean*Ls*0.25, y0 + sgn*Ls*0.5},{x + lean*Ls*0.75, y0 + sgn*Ls*0.85},{x + lean*Ls*1.25, y0 + sgn*Ls*0.95}}
    b:reload(p, 0.75)
    b:stroke(pts, {pressure={0.6,0.05}, ramps={0.05,0.5}})
    n = n + 1
  end
end
print(n)

--@ chunk 5
wait(5*24*60)
print(drying(170,300), drying(500,500))
MUL = pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.15}}
AMB = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1},{"bone black",0.08}}
-- window frame and mullions: a heavy MIRIAD grid
local fr = VP:grow(9) - VP
work(fr, {hand="detail", tool="round 3", pile=MUL, coverage=4, fill=true, clip=true})
local b = brush{kind="flat", width=7}
for _,s in ipairs({{{140,150},{135,450}}, {{222,160},{222,440}}}) do b:reload(MUL, 0.95); b:stroke(s, {pressure={0.9,0.9}, ramps={0.01,0.01}, orient="across", clip=VP:grow(2)}) end
for _,s in ipairs({{{45,240},{300,250}}, {{45,345},{300,340}}}) do b:reload(MUL, 0.95); b:stroke(s, {pressure={0.9,0.9}, ramps={0.01,0.01}, orient="across", clip=VP:grow(2)}) end
-- amber hazard strips along both edges of the floor (the walls' feet)
local edgeL, edgeR = {}, {}
for y=-5,630,6 do edgeL[#edgeL+1] = {500-hw(y)+2, y}; edgeR[#edgeR+1] = {500+hw(y)-2, y} end
local function hz(pts)
  local m = ribbon(pts, 7)
  work(m, {hand="detail", tool="round 2", pile=AMB, coverage=4, fill=true, clip=true})
  return m
end
HZ = hz(edgeL) + hz(edgeR)
-- pipes on the right wall following the curve
for k,off in ipairs({40, 58, 140}) do
  local p = {}
  for y=-5,630,6 do p[#p+1] = {500+hw(y)+off*(hw(y)/120), y} end
  local r = brush{kind="round", width=math.max(3, 6 - k), point=0.2}
  r:reload(MUL, 0.9); r:stroke(p, {pressure={0.8,0.8}, ramps={0.01,0.01}, clip=RWALL})
  local p2 = {}
  for i,q in ipairs(p) do p2[i] = {q[1]-1.5, q[2]} end
  local h = brush{kind="round", width=1.3, point=0.5}
  h:reload(S1, 0.7); h:stroke(p2, {pressure={0.4,0.4}, ramps={0.01,0.01}, clip=RWALL})
end

--@ chunk 6
WLD = pile{{"bone black",1.5},{"ultramarine ash",1},{"burnt sienna",0.3},{"lead white",0.1}}
WLG = pile{{"bone black",1},{"ultramarine ash",1},{"raw sienna",0.6},{"lead white",0.35},{"Mars orange",0.15}}
local lw = LWALL - VP:grow(9) - HZ
local near = VP:grow(60) - VP:grow(9)
work(lw - near, {hand="body", tool="filbert 7", pile=WLD, coverage=3.5, fill=true, clip=lw, angle=1.5708})
work(lw * near, {hand="body", tool="filbert 7", pile=WLG, coverage=3.5, fill=true, clip=lw, angle=1.5708})
blend(lw * (VP:grow(72) - VP:grow(48)), {angle=1.5708, tool={kind="badger", width=12}})
-- sunlight thrown through the window onto the right wall
POOL = poly({{640,175},{860,140},{900,470},{660,430}}, true) * RWALL - HZ:grow(2)
PL1 = pile{{"yellow ochre",1},{"lead white",1},{"Mars orange",0.3},{"raw sienna",0.3}}
PL2 = pile{{"raw sienna",1},{"ultramarine ash",0.6},{"lead white",0.5},{"Mars orange",0.2},{"bone black",0.3}}
work(POOL:grow(18) * RWALL - HZ:grow(2) - POOL, {hand="body", tool="filbert 6", pile=PL2, coverage=3.5, fill=true, clip=true, angle=1.5708})
work(POOL, {hand="body", tool="filbert 6", pile=PL1, coverage=3.5, fill=true, clip=true, angle=1.5708})
blend((POOL:grow(26) - POOL:shrink(8)) * RWALL - HZ:grow(2), {angle=1.5708, tool={kind="badger", width=12}})

--@ chunk 7
wait(6*24*60)
print(drying(750,300), drying(30,300))
-- mullion shadows across the light on the right wall (the window's grid, thrown and skewed)
SHD = pile{{"raw sienna",1},{"bone black",0.9},{"ultramarine ash",0.6},{"burnt sienna",0.3}}
local b = brush{kind="flat", width=11}
for _,s in ipairs({{{735,120},{760,480}}, {{820,110},{845,490}}, {{610,255},{930,215}}, {{620,370},{930,345}}}) do
  b:reload(SHD, 0.9); b:stroke(s, {pressure={0.85,0.85}, ramps={0.01,0.01}, orient="across", clip=POOL:grow(14)})
end
-- left wall: warm dark glow round the window, no blue in it
WLG2 = pile{{"bone black",1.2},{"burnt sienna",0.8},{"Mars orange",0.25},{"lead white",0.2}}
local lw = LWALL - VP:grow(9) - HZ
local function radial(x,y) return math.atan(y-SY, x-SX) end
work(lw * (VP:grow(55) - VP:grow(9)), {hand="body", tool="filbert 6", pile=WLG2, coverage=4, fill=true, clip=true, angle=radial})
work(lw * (VP:grow(110) - VP:grow(55)), {hand="body", tool="filbert 6", pile=WLD, coverage=4, fill=true, clip=true, angle=radial})
blend(lw * (VP:grow(68) - VP:grow(42)), {angle=radial, tool={kind="badger", width=12}})

--@ chunk 8
CANY = pile{{"cadmium yellow",1.5},{"chrome yellow",0.6},{"lead white",0.3}}
CANS = pile{{"Mars orange",0.6},{"yellow ochre",1},{"bone black",0.25}}
CANH = pile{{"lead white",2},{"lemon chrome",0.5}}
function can(cx, cy, s, th)
  local function P(x,y) return {cx + (x*math.cos(th) - y*math.sin(th))*s, cy + (x*math.sin(th) + y*math.cos(th))*s} end
  local function pl(t) local o={} for i,v in ipairs(t) do o[i]=P(v[1],v[2]) end return poly(o) end
  local body = pl({{-10,-8},{8,-8},{10,9},{-8,9}})
  local tool = s > 0.8 and "round 1.6" or "round 1"
  work(body, {hand="detail", tool=tool, pile=CANY, coverage=6, fill=true, clip=true})
  work(body * pl({{-12,3},{12,3},{12,10},{-12,10}}), {hand="detail", tool=tool, pile=CANS, coverage=6, fill=true, clip=true})
  local w = math.max(1.2, 2.6*s)
  local b = brush{kind="round", width=w, point=0.2}
  b:reload(CANY, 0.95); b:stroke({P(8,0),P(16,-7),P(22,-13)}, {pressure={0.8,0.6}, ramps={0.02,0.02}})
  local r = brush{kind="round", width=math.max(1.5, 4.5*s), point=0.1}
  r:reload(CANY, 0.95); r:touch(P(23,-14)[1], P(23,-14)[2], {pressure=0.8})
  local h = brush{kind="round", width=math.max(1, 2.2*s), point=0.2}
  h:reload(CANY, 0.95); h:stroke({P(-8,-8),P(-6,-15),P(2,-16),P(5,-8)}, {pressure={0.7,0.7}, ramps={0.02,0.02}})
  h:reload(CANH, 0.8); h:stroke({P(-9,-7),P(7,-7)}, {pressure={0.4,0.4}})
end
-- the dropped can, here on our floor between two beds, spout toward the window
can(690, 560, 1.4, math.pi + 0.15)
-- the same can, the same place in the bed rows, on the floor overhead: turned a quarter, not a half
can(674, 55, 0.95, math.pi/2 + 0.15)

--@ chunk 9
FROST = pile{{"zinc white",3},{"cerulean blue",0.4},{"lead white",0.5}}
-- coolant leaked from the right-hand pipes: frost creeping over the near trays on that side
local fm = mask(function(x,y)
  if x < 520 or y < 330 then return 0 end
  local edge = 500 + hw(y)
  local d = edge - x
  if d < 0 then return 0 end
  return clamp(1 - d/(0.55*hw(y)), 0, 1)
end)
local lips = nil
for _,B in ipairs(BEDS) do
  if B.up and B.y > 330 then
    local r = rect(500-B.w, B.y-B.h/2, 2*B.w, B.h + B.lipH)
    lips = lips and (lips + r) or r
  end
end
stipple(lips * fm, {pile=FROST, width=1.6, coverage=function(x,y) return 1.4*fm:at(x,y) end, feather=0.6, dips={18,0.5,0}})
-- the pipe's leak: a white crust where the coolant ran down the wall foot
stipple(ellipse(905,470,50,30)*RWALL, {pile=FROST, width=2, coverage=0.9, feather=0.5})

--@ chunk 10
wait(4*24*60)
print(drying(905,470))
local E = ellipse(905,470,56,36) * RWALL - HZ:grow(2)
local inpool = POOL:shrink(4)
work(E * inpool, {hand="detail", tool="round 3", pile=PL1, coverage=5, fill=true, clip=true, angle=1.5708})
work(E - inpool, {hand="detail", tool="round 3", pile=WR, coverage=5, fill=true, clip=true, angle=1.5708})
-- the only green: a few leaves on stems nearest the window
LEAF = pile{{"viridian",0.7},{"cadmium yellow",1},{"lead white",0.5}}
LEAF2 = pile{{"viridian",1},{"yellow ochre",0.6},{"bone black",0.2}}
local n = 0
for _,B in ipairs(BEDS) do
  if B.up and B.y > 360 then
    for i=1,math.floor(B.w/40) do
      local x = 500 - B.w + rand(0, B.w*0.9)
      local y = B.y - rand(0.5, 2.2)*B.h
      local s = clamp(B.h/14, 0.4, 1.4)
      local b = brush{kind="filbert", width=4*s}
      b:reload((i%3==0) and LEAF2 or LEAF, 0.8)
      local a = -2.4 + rand(-0.4,0.4)
      b:stroke({{x,y},{x+math.cos(a)*7*s, y+math.sin(a)*7*s}}, {pressure={0.7,0.1}})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 11
-- the stems standing in the sunbeam (between the window and its image on the far wall) catch the light
HOTS = pile{{"lead white",2},{"zinc white",1},{"lemon chrome",0.6},{"cadmium yellow",0.2}}
local beam = poly({{300,160},{640,150},{650,450},{300,440}}) * BAND
local n = 0
for _,B in ipairs(BEDS) do
  local sgn = B.up and -1 or 1
  local L = math.max(3, B.h*3.2)
  local wdt = math.max(0.6, math.min(2.2, B.h*0.15))
  local b = brush{kind="round", width=wdt, point=0.9}
  for i=1,24 do
    local x = 500 - B.w + rand(0, 2*B.w)
    local y0 = B.y + rand(-0.3,0.3)*B.h
    if beam:at(x, y0 + sgn*L*0.5) > 0.5 then
      local lean = clamp((SX - x)/600, -1, 0.2)
      local Ls = L*rand(0.7,1.2)
      b:reload(HOTS, 0.7)
      b:stroke({{x + lean*Ls*0.1, y0 + sgn*Ls*0.3},{x + lean*Ls*0.5, y0 + sgn*Ls*0.7},{x + lean*Ls*1.2, y0 + sgn*Ls*0.95}}, {pressure={0.45,0.0}, ramps={0.1,0.5}})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 12
wait(3*24*60)
-- the stems' shadows thrown onto the sunlit wall: thin, leaning the other way, rising from the pool's foot
local b = brush{kind="round", width=1.8, point=0.9}
for i=1,46 do
  local x = rand(625, 900)
  local y0 = 480 - (x-640)*0.05 + rand(-5,12)
  local L = rand(40, 120)
  local lean = rand(0.15, 0.45)
  b:reload(SHD, 0.6)
  b:stroke({{x,y0},{x + lean*L*0.3, y0 - L*0.5},{x + lean*L*0.9, y0 - L*0.85},{x + lean*L*1.4, y0 - L}}, {pressure={0.55,0.0}, ramps={0.05,0.5}, clip=POOL:grow(10)})
end

--@ chunk 13
print(#BEDS) for _,B in ipairs(BEDS) do io_ = 0 end local s="" for _,B in ipairs(BEDS) do s = s .. string.format("%.0f/%.1f ", B.y, B.h) end print(s)

--@ chunk 14
-- (3) thin the near beds: repaint the floor at our feet, re-lay the trays, sparser stems after
CANM = ellipse(688,556,38,30)
local near = (BAND * rect(-5,468,1010,165)) - HZ:grow(1) - CANM
work(near, {hand="body", tool="filbert 8", pile=FL, coverage=4, fill=true, clip=true, angle=0})
for _,B in ipairs(BEDS) do
  if B.up and B.y > 470 then
    local soil = rect(500-B.w, B.y-B.h/2, 2*B.w, B.h) - CANM
    local lip = rect(500-B.w, B.y+B.h/2, 2*B.w, B.lipH) - CANM
    work(soil, {hand="detail", tool="round 3", pile=SOIL, coverage=5, fill=true, clip=true, angle=0})
    work(lip, {hand="detail", tool="round 2.5", pile=TRAY, coverage=5, fill=true, clip=true, angle=0})
    -- tray hardware: a dark lower edge and bolts
    local d = brush{kind="round", width=1.8, point=0.3}
    d:reload(TRAY_D, 0.9); d:stroke({{500-B.w, B.y+B.h/2+B.lipH},{500+B.w, B.y+B.h/2+B.lipH}}, {pressure={0.6,0.6}, ramps={0.01,0.01}, clip=-CANM})
    for x = 500-B.w+12, 500+B.w-12, 48 do
      if CANM:at(x, B.y+B.h/2+B.lipH/2) < 0.5 then d:reload(TRAY_D, 0.8); d:touch(x, B.y+B.h/2+B.lipH/2, {pressure=0.45}) end
    end
  end
end
-- (1a) the far wall: paint out the soft light patch
local wall = (POOL:grow(34) * RWALL) - HZ:grow(2)
work(wall, {hand="body", tool="filbert 7", pile=WR, coverage=4, fill=true, clip=true, angle=1.5708})

--@ chunk 15
wait(4*24*60)
print(drying(800,300), drying(500,560))
-- (1b) crisp sunlight: a hard-edged skewed quad
Q = {{648,168},{868,132},{906,468},{668,436}}
POOLC = poly(Q) * RWALL - HZ:grow(2)
work(POOLC, {hand="detail", tool="round 3", pile=PL1, coverage=5, fill=true, clip=true, angle=1.5708})
-- a slightly brighter core toward the window side
PLH = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.3}}
work(POOLC * poly({{648,168},{760,150},{785,452},{668,436}}), {hand="detail", tool="round 3", pile=PLH, coverage=4, fill=true, clip=true, angle=1.5708})
blend(POOLC * poly({{740,150},{780,145},{805,455},{765,452}}), {angle=1.5708, tool={kind="badger", width=10}})

--@ chunk 16
wait(4*24*60)
print(drying(800,300))
local function bil(u,v)
  local a = {lerp(Q[1][1],Q[2][1],u), lerp(Q[1][2],Q[2][2],u)}
  local b = {lerp(Q[4][1],Q[3][1],u), lerp(Q[4][2],Q[3][2],u)}
  return {lerp(a[1],b[1],v), lerp(a[2],b[2],v)}
end
SHD2 = pile{{"bone black",1},{"raw sienna",0.8},{"ultramarine ash",0.6},{"burnt sienna",0.3}}
local bars = nil
local t = 0.022
for _,u in ipairs({0.37, 0.69}) do
  local m = poly({bil(u-t,-0.05), bil(u+t,-0.05), bil(u+t,1.05), bil(u-t,1.05)})
  bars = bars and (bars + m) or m
end
for _,v in ipairs({0.28, 0.62}) do
  local m = poly({bil(-0.05,v-t*1.3), bil(1.05,v-t*1.3), bil(1.05,v+t*1.3), bil(-0.05,v+t*1.3)})
  bars = bars + m
end
work(bars * POOLC, {hand="detail", tool="round 1.6", pile=SHD2, coverage=6, fill=true, clip=true})
-- the stems' shadows, crisp, rising from the foot of the patch, leaning away from the window
local b = brush{kind="round", width=1.6, point=0.9}
for i=1,60 do
  local u = rand(0.02, 0.98)
  local base = bil(u, 1.0)
  local L = rand(30, 130)
  local lean = rand(0.1, 0.45)
  local x, y0 = base[1], base[2] + 4
  b:reload(SHD2, 0.95)
  b:stroke({{x,y0},{x + lean*L*0.3, y0 - L*0.5},{x + lean*L*0.9, y0 - L*0.85},{x + lean*L*1.4, y0 - L}}, {pressure={0.6,0.02}, ramps={0.02,0.6}, clip=POOLC})
end
-- sparse stems at our feet: fewer, taller, the trays show between them
local n = 0
for _,B in ipairs(BEDS) do
  if B.up and B.y > 470 then
    local cnt = 14
    local L = B.h*3.4
    local bb = brush{kind="round", width=2.2, point=0.9}
    for i=1,cnt do
      local x = 500 - B.w + (i-0.5)*(2*B.w/cnt) + rand(-8,8)
      if CANM:at(x, B.y) < 0.5 then
        local lean = clamp((SX - x)/600, -1, 0.2)
        local Ls = L*rand(0.7,1.2)
        local r = rand(0,1)
        local p = (x < 470 and r < 0.25) and GRN or (r < 0.6 and ET1 or (r < 0.85 and ET3 or DEAD))
        local y0 = B.y
        bb:reload(p, 0.8)
        bb:stroke({{x,y0},{x + lean*Ls*0.25, y0 - Ls*0.5},{x + lean*Ls*0.75, y0 - Ls*0.85},{x + lean*Ls*1.25, y0 - Ls*0.95}}, {pressure={0.6,0.05}, ramps={0.05,0.5}})
        n = n + 1
      end
    end
  end
end
print(n)

--@ chunk 17
-- (2) dead grow-lamp fixtures hanging over the beds, a rim of window light on their window side
LAMP_D = pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.15}}
LAMP_M = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.45}}
LENSD = pile{{"cobalt violet",1},{"bone black",1},{"magenta",0.3},{"lead white",0.2}}
RIML = pile{{"lead white",2},{"cadmium yellow",0.5},{"yellow ochre",0.4}}
local function lamp(B, up)
  local sgn = up and -1 or 1
  local y = B.y + sgn*B.h*2.6
  local w = B.w*0.62
  local th = math.max(3, B.h*0.45)
  local body = rect(500-w, y - th/2, 2*w, th)
  local lens = up and rect(500-w+2, y + th/2, 2*w-4, th*0.45) or rect(500-w+2, y - th/2 - th*0.45, 2*w-4, th*0.45)
  -- cables, toward the ring's axis (up for our floor, down for the floor overhead)
  local c = brush{kind="round", width=math.max(1, th*0.18), point=0.3}
  for _,x in ipairs({500-w*0.8, 500+w*0.8}) do
    c:reload(LAMP_D, 0.9); c:stroke({{x, y}, {x + (500-x)*0.08, y + sgn*B.h*3.5}}, {pressure={0.6,0.3}})
  end
  local tool = th > 6 and "round 2" or "round 1"
  work(body, {hand="detail", tool=tool, pile=LAMP_M, coverage=6, fill=true, clip=true})
  work(body * rect(0, up and (y - th/2 + th*0.5) or (y - th/2), 1000, th*0.5), {hand="detail", tool=tool, pile=LAMP_D, coverage=6, fill=true, clip=true})
  work(lens, {hand="detail", tool=tool, pile=LENSD, coverage=6, fill=true, clip=true})
  -- dead LED dots in the lens
  local d = brush{kind="round", width=math.max(1, th*0.22), point=0.1}
  for x = 500-w+6, 500+w-6, math.max(5, th*1.3) do
    d:reload(LAMP_D, 0.8); d:touch(x, up and (y + th/2 + th*0.22) or (y - th/2 - th*0.22), {pressure=0.5})
  end
  -- rim of window light on the window (left) end and along the edge facing the light
  local r = brush{kind="round", width=math.max(1, th*0.22), point=0.5}
  r:reload(RIML, 0.9); r:stroke({{500-w, y+th/2},{500-w, y-th/2},{500-w*0.2, y-th/2}}, {pressure={0.6,0.15}, ramps={0.02,0.4}})
end
for _,B in ipairs(BEDS) do
  if B.up and (math.abs(B.y - 556) < 3 or math.abs(B.y - 419) < 3) then lamp(B, true) end
  if (not B.up) and math.abs(B.y - 110) < 3 then lamp(B, false) end
end

--@ chunk 18
local L = {{484,195,12.4,true},{367,62,9,true},{170.6,79.6,10.5,false}}
for _,l in ipairs(L) do
  local y, w, th, up = l[1], l[2], l[3], l[4]
  local sgn = up and -1 or 1
  local edge = up and (y - th/2) or (y + th/2)
  -- hangers: rods toward the ring's axis, with a lit left side
  for _,x in ipairs({500-w*0.78, 500+w*0.78}) do
    local tip = {x + (500-x)*0.1, edge + sgn*th*6}
    local c = brush{kind="round", width=math.max(1.6, th*0.22), point=0.2}
    c:reload(LAMP_D, 0.95); c:stroke({{x, edge}, tip}, {pressure={0.8,0.6}, ramps={0.02,0.02}})
    local h = brush{kind="round", width=1, point=0.6}
    h:reload(RIML, 0.8); h:stroke({{x-0.8, edge + sgn*1}, {tip[1]-0.8, tip[2]}}, {pressure={0.4,0.1}})
    -- bracket
    local bk = brush{kind="round", width=math.max(2, th*0.4), point=0.1}
    bk:reload(LAMP_M, 0.9); bk:touch(x, edge + sgn*1.5, {pressure=0.7})
  end
  -- sunlit edge along the housing and its window-side end cap
  local r = brush{kind="round", width=math.max(1.3, th*0.2), point=0.5}
  r:reload(RIML, 1.0); r:stroke({{500-w+1, edge - sgn*0.8},{500, edge - sgn*0.8},{500+w*0.6, edge - sgn*0.8}}, {pressure={0.75,0.05}, ramps={0.02,0.5}})
  r:reload(RIML, 1.0); r:stroke({{500-w+0.8, y-th/2+1},{500-w+0.8, y+th/2-1}}, {pressure={0.7,0.6}, ramps={0.02,0.02}})
end
