-- easel session "logbook": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=4/3, linen={20,18}, seed=55,
  ground={{pile={{"bone brown",1},{"lead white",0.5},{"yellow ochre",0.3},{"bone black",0.3}}, um=120, apply="knife", texture=0.3}}}
-- the wall behind: warm grey, lit from a window on the left, falling to dark on the right
TOPY, EDGEY = 455, 640
local wall = rect(0, 0, 1000, TOPY)
local Wp = {
  {0, 260, pile{{"lead white",1},{"bone black",0.55},{"yellow ochre",0.25},{"ultramarine ash",0.25}}},
  {260, 560, pile{{"lead white",0.6},{"bone black",0.7},{"yellow ochre",0.2},{"bone brown",0.3},{"ultramarine ash",0.15}}},
  {560, 820, pile{{"bone black",1},{"bone brown",0.6},{"lead white",0.25},{"yellow ochre",0.1}}},
  {820, 1100, pile{{"bone black",1.3},{"bone brown",0.6},{"lead white",0.1}}},
}
local function wv(x,y) return x + 0.5*y end
for _,p in ipairs(Wp) do
  local m = wall * mask(function(x,y) local v = wv(x,y); return (v >= p[1] and v < p[2]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=12}, pile=p[3], coverage=3.6, fill=true, clip=wall, angle=1.3, length={40,120}})
end
blend(wall * mask(function(x,y) local v = wv(x,y); return (math.abs(v-260) < 40 or math.abs(v-560) < 45 or math.abs(v-820) < 45) and 1 or 0 end), {angle=1.3, tool={kind="badger", width=20}})
-- the console top: a cool grey slab, lit from the left
local top = rect(0, TOPY, 1000, EDGEY - TOPY)
local Tp = {
  {0, 350, pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.4},{"yellow ochre",0.1}}},
  {350, 700, pile{{"lead white",0.7},{"bone black",0.65},{"ultramarine ash",0.35},{"bone brown",0.15}}},
  {700, 1100, pile{{"lead white",0.4},{"bone black",0.9},{"ultramarine ash",0.3},{"bone brown",0.25}}},
}
for _,p in ipairs(Tp) do
  local m = top * mask(function(x,y) return (x >= p[1] and x < p[2]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=10}, pile=p[3], coverage=3.6, fill=true, clip=top, angle=0, length={40,120}})
end
blend(top * (rect(320, 0, 60, H) + rect(670, 0, 60, H)), {angle=0, tool={kind="badger", width=16}})
-- the console's front face, in shadow
local front = rect(0, EDGEY, 1000, H - EDGEY)
work(front, {hand="body", tool={kind="filbert", width=12}, pile=pile{{"bone black",1.5},{"bone brown",0.6},{"ultramarine ash",0.3}}, coverage=3.6, fill=true, clip=front, angle=0, length={40,120}})

--@ chunk 2
local wall = rect(0, 0, 1000, TOPY)
local function wv(x,y) return x + 0.5*y end
local corner = wall * mask(function(x,y) return (wv(x,y) >= 1090) and 1 or 0 end)
work(corner, {hand="body", tool={kind="filbert", width=8}, pile=pile{{"bone black",1.3},{"bone brown",0.6},{"lead white",0.1}}, coverage=4, fill=true, clip=wall, angle=1.3})
for _,c in ipairs({260, 560, 820, 1090}) do
  local m = wall * mask(function(x,y) return (math.abs(wv(x,y)-c) < 70) and 1 or 0 end)
  blend(m, {angle=1.3, tool={kind="badger", width=24}})
  blend(m, {angle=-0.27, tool={kind="badger", width=24}})
end
local top = rect(0, TOPY, 1000, EDGEY - TOPY)
for _,c in ipairs({350, 700}) do
  local m = top * rect(c - 70, 0, 140, H)
  blend(m, {angle=0, tool={kind="badger", width=20}})
  blend(m, {angle=1.5708, tool={kind="badger", width=20}})
end

--@ chunk 3
print(wait(3*24*60))
local function mix(a, b, t)
  local acc, order = {}, {}
  for _,v in ipairs(a) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*(1-t) end
  for _,v in ipairs(b) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*t end
  local o = {}
  for _,k in ipairs(order) do if acc[k] > 0.001 then o[#o+1] = {k, acc[k]} end end
  return pile(o)
end
local L = {{"lead white",1},{"bone black",0.5},{"yellow ochre",0.25},{"ultramarine ash",0.25}}
local D = {{"bone black",1.3},{"bone brown",0.6},{"lead white",0.06}}
local wall = rect(0, 0, 1000, TOPY)
local function wv(x,y) return x + 0.45*y end
local N = 12
for i=0,N-1 do
  local lo, hi = -10 + i*1210/N, -10 + (i+1)*1210/N
  if i == N-1 then hi = 5000 end
  if i == 0 then lo = -5000 end
  local m = wall * mask(function(x,y) local v = wv(x,y); return (v >= lo and v < hi) and 1 or 0 end)
  local t = (i/(N-1))^0.8
  work(m, {hand="body", tool={kind="filbert", width=8}, pile=mix(L, D, t), coverage=3.8, fill=true, clip=wall, angle=1.15, length={30,90}})
end
local TL = {{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.4},{"yellow ochre",0.1}}
local TD = {{"lead white",0.35},{"bone black",0.95},{"ultramarine ash",0.3},{"bone brown",0.3}}
local top = rect(0, TOPY, 1000, EDGEY - TOPY)
local M = 8
for i=0,M-1 do
  local lo, hi = i*1000/M, (i+1)*1000/M
  local m = top * rect(lo - ((i==0) and 10 or 0), 0, (hi-lo) + ((i==M-1) and 10 or 0) + ((i==0) and 10 or 0), H)
  work(m, {hand="body", tool={kind="filbert", width=7}, pile=mix(TL, TD, i/(M-1)), coverage=3.8, fill=true, clip=top, angle=0, length={30,90}})
end

--@ chunk 4
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local SH = pile{{"bone black",1.2},{"ultramarine ash",0.4},{"bone brown",0.3},{"lead white",0.12}}
-- cast shadows, falling right and a little back, from the window light
fill(poly({{600,472},{700,470},{730,560},{625,572}}), SH, 4)
fill(poly({{800,532},{860,528},{880,545},{790,548}}, true), SH, 3)
fill(poly({{170,468},{260,464},{262,478},{175,482}}, true), SH, 3)
fill(poly({{640,610},{690,612},{688,628},{640,626}}, true), SH, 2)
-- the logbook: worn leather cover, then pages
COVER = poly({{246,482},{612,470},{642,578},{216,594}})
fill(COVER, pile{{"bone brown",1},{"red earth",0.4},{"bone black",0.5}}, 3)
PL = poly({{262,478},{426,472},{431,568},{240,580}})
PR = poly({{426,472},{598,467},{624,564},{431,568}})
fill(PL, pile{{"lead white",1.4},{"yellow ochre",0.3},{"bone black",0.12}}, 3, 0.05)
fill(PR, pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.25},{"ultramarine ash",0.1}}, 3, 0.05)
-- the mug, tipped on its side, mouth toward us at the right
MUGB = poly({{690,470},{790,466},{800,532},{694,534}}, true)
fill(MUGB, pile{{"lead white",1},{"bone black",0.35},{"ultramarine ash",0.3},{"yellow ochre",0.1}}, 3)
MOUTH = ellipse(800, 499, 17, 33)
fill(MOUTH, pile{{"bone black",1.4},{"bone brown",0.6}}, 2)
-- the dead indicator lamp: a dark collar on the console, a frosted bulb
LBASE = poly({{120,446},{180,446},{184,474},{116,474}}, true)
fill(LBASE, pile{{"bone black",1.2},{"ultramarine ash",0.6},{"lead white",0.15}}, 2.5)
BULB = ellipse(150, 405, 33, 42)
fill(BULB, pile{{"lead white",0.8},{"bone black",0.5},{"ultramarine ash",0.6},{"cerulean blue",0.1}}, 3, 1.5708)
-- crew badge on the console, near the edge
BADGE = poly({{122,590},{218,584},{222,620},{124,628}}, true)
fill(BADGE, pile{{"lead white",1.2},{"ultramarine ash",0.4},{"bone black",0.2}}, 2)
-- the stopped wristwatch: strap and case
STRAP = poly({{520,602},{680,592},{682,612},{522,622}}, true)
fill(STRAP, pile{{"bone black",1.2},{"bone brown",0.7}}, 2)
CASE = ellipse(600, 604, 27, 17)
fill(CASE, pile{{"lead white",0.8},{"bone black",0.6},{"ultramarine ash",0.3}}, 2)
-- the bone cross, lying flat in front of the book
CROSSM = poly({{300,618},{400,602},{402,610},{302,627}}) + poly({{326,600},{334,598},{345,630},{337,632}})
fill(CROSSM, pile{{"lead white",1.1},{"yellow ochre",0.45},{"raw sienna",0.15}}, 1.5)

--@ chunk 5
print(wait(3*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- pages: lit, curling up from the gutter, a shadow in the fold
local P1 = pile{{"lead white",1.6},{"yellow ochre",0.25},{"bone black",0.06}}
local P2 = pile{{"lead white",1.2},{"yellow ochre",0.3},{"bone black",0.18}}
local P3 = pile{{"lead white",0.8},{"yellow ochre",0.3},{"bone black",0.35},{"ultramarine ash",0.1}}
fill(PL * mask(function(x,y) return (x < 395) and 1 or 0 end), P1, 3, 0.05)
fill(PL * mask(function(x,y) return (x >= 395) and 1 or 0 end), P2, 2, 0.05)
fill(PR * mask(function(x,y) return (x < 460) and 1 or 0 end), P3, 2, 0.05)
fill(PR * mask(function(x,y) return (x >= 460) and 1 or 0 end), P2, 3, 0.05)
blend(PL * rect(380, 0, 30, H), {angle=0, tool={kind="badger", width=6}})
blend(PR * rect(448, 0, 26, H), {angle=0, tool={kind="badger", width=6}})
-- mug: lit top, shadowed belly, a glazed highlight
local MT = pile{{"lead white",1.6},{"yellow ochre",0.1},{"ultramarine ash",0.15}}
local MD = pile{{"bone black",1},{"lead white",0.4},{"ultramarine ash",0.4}}
fill(MUGB * rect(0, 0, 1000, 488), MT, 2)
fill(MUGB * rect(0, 512, 1000, 40), MD, 2)
fill(MUGB * rect(0, 488, 1000, 24), pile{{"lead white",1},{"bone black",0.4},{"ultramarine ash",0.3}}, 2)
blend(MUGB * (rect(0, 482, 1000, 12) + rect(0, 506, 1000, 12)), {angle=0, tool={kind="badger", width=4}})
-- bulb: lit left, shadow right
local BL = pile{{"lead white",1.3},{"ultramarine ash",0.4},{"bone black",0.15}}
local BD = pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.35}}
fill(BULB * mask(function(x,y) return (x < 143) and 1 or 0 end), BL, 2, 1.5708)
fill(BULB * mask(function(x,y) return (x > 160) and 1 or 0 end), BD, 2, 1.5708)
blend(BULB * rect(136, 0, 30, H), {angle=1.5708, tool={kind="badger", width=5}})
fill(LBASE * mask(function(x,y) return (x < 140) and 1 or 0 end), pile{{"bone black",0.9},{"ultramarine ash",0.6},{"lead white",0.4}}, 2)
-- watch case
fill(ellipse(600, 604, 22, 13), pile{{"lead white",1.2},{"yellow ochre",0.15},{"bone black",0.15}}, 1.5)
-- cross: shadow side
fill(poly({{302,623},{402,607},{402,610},{302,627}}) + poly({{337,632},{345,630},{342,621},{335,622}}), pile{{"yellow ochre",1},{"raw sienna",0.6},{"bone brown",0.3}}, 1)
-- badge: photo square, blue hex, name bar
fill(poly({{132,595},{158,593},{160,616},{134,618}}), pile{{"bone black",0.8},{"bone brown",0.6},{"lead white",0.3}}, 1)
fill(ellipse(200, 600, 9, 7), pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.2}}, 1)
fill(poly({{166,607},{214,604},{215,610},{167,613}}), pile{{"bone black",1},{"ultramarine ash",0.4}}, 1)

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local INK = pile{{"bone black",1.3},{"ultramarine blue",0.25},{"bone brown",0.2}}
local b = brush{kind="round", width=0.9, point=0.8}
-- the fold: a quiet grey shadow either side of the gutter
fill(poly({{418,473},{432,472},{434,568},{422,569}}), pile{{"lead white",0.7},{"bone black",0.4},{"yellow ochre",0.15}}, 1.5)
-- handwriting: full lines on the left page, the right page stopping mid-line
local function lines(x0, x1y, y0, n, dy, stopAt)
  for r=0,n-1 do
    local y = y0 + r*dy
    local xa = x0(y) + 6
    local xb = x1y(y) - 8
    if stopAt and r == n-1 then xb = xa + (xb - xa)*stopAt end
    local x = xa
    while x < xb do
      local L = rand(10, 28); if x + L > xb then L = xb - x end
      local pts = {}
      local k = math.max(2, math.floor(L/2.5))
      for j=0,k do local t = j/k; pts[#pts+1] = {x + L*t, y + 1.6*math.sin(t*k*2.1 + x) - 1.2*math.max(0, math.sin(t*5+x))^6} end
      b:reload(INK, 0.6); b:stroke(pts, {pressure={0.32,0.24}})
      x = x + L + rand(4, 8)
    end
  end
end
lines(function(y) return 262 - (y-478)*0.22 end, function(y) return 422 end, 488, 9, 9.5)
lines(function(y) return 432 end, function(y) return 598 + (y-468)*0.27 end, 486, 5, 9.5, 0.45)
-- the pen, dropped where the line stops
local pb = brush{kind="round", width=5, point=0.2}
pb:reload(pile{{"bone black",1.6},{"ultramarine blue",0.3}}, 0.95); pb:stroke({{486,528},{560,546},{620,560}}, {pressure={0.8,0.8}, ramps={0.02,0.05}})
local ph = brush{kind="round", width=1.2, point=0.5}
ph:reload(pile{{"lead white",1.5},{"ultramarine ash",0.3}}, 0.7); ph:stroke({{490,526},{558,543},{612,556}}, {pressure={0.45,0.3}})
local nib = brush{kind="round", width=1.8, point=0.8}
nib:reload(pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.4}}, 0.8); nib:stroke({{486,528},{475,526}}, {pressure={0.6,0.05}})
-- mug: the lit rim of its mouth, the dark inside, the spill on the console
local rim = brush{kind="round", width=2.0, point=0.5}
local pts = {}
for k=0,16 do local t = math.pi*0.55 + math.pi*0.9*k/16; pts[#pts+1] = {800 + 17*math.cos(t), 499 + 33*math.sin(t)} end
rim:reload(pile{{"lead white",1.6},{"ultramarine ash",0.2}}, 0.8); rim:stroke(pts, {pressure={0.5,0.4}})
local SPILL = poly({{786,534},{830,530},{880,538},{900,552},{850,560},{800,552}}, true)
fill(SPILL, pile{{"bone brown",1},{"bone black",0.8},{"burnt sienna",0.3}}, 2)
local g = brush{kind="round", width=1.3, point=0.5}
g:reload(pile{{"lead white",1.4},{"ultramarine ash",0.3}}, 0.7); g:stroke({{812,539},{840,537}}, {pressure={0.4,0.1}})
g:reload(pile{{"lead white",1.8}}, 0.8); g:stroke({{705,472},{780,469}}, {pressure={0.4,0.2}})
-- the watch, stopped: hands, ticks, a lit bezel
local hb = brush{kind="round", width=1.0, point=0.6}
hb:reload(INK, 0.8); hb:stroke({{600,604},{593,596}}, {pressure={0.5,0.3}})
hb:reload(INK, 0.8); hb:stroke({{600,604},{614,602}}, {pressure={0.4,0.2}})
for k=0,11 do local a = 2*math.pi*k/12; hb:reload(INK, 0.5); hb:touch(600 + 18*math.cos(a), 604 + 10.5*math.sin(a), {pressure=0.25}) end
local bz = {}
for k=0,12 do local t = math.pi*0.8 + math.pi*0.9*k/12; bz[#bz+1] = {600 + 26*math.cos(t), 604 + 16*math.sin(t)} end
hb:reload(pile{{"lead white",1.8},{"yellow ochre",0.1}}, 0.8); hb:stroke(bz, {pressure={0.5,0.4}})
-- the bulb: frost crystals, a cold highlight, the dead filament
stipple(BULB, {pile=pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.15}}, width=1.2, coverage=0.7, pressure={0.15,0.35}, cluster={0.5, 6}})
local hl = brush{kind="round", width=3, point=0.5}
hl:reload(pile{{"zinc white",3}}, 0.8); hl:stroke({{132,388},{136,378},{142,372}}, {pressure={0.5,0.2}})
local fl = brush{kind="round", width=1.0, point=0.6}
fl:reload(pile{{"bone black",1},{"ultramarine ash",0.5}}, 0.6); fl:stroke({{144,440},{146,412},{150,404},{156,412},{158,440}}, {pressure={0.3,0.3}})
-- the console's front lip: a lit edge, and frost creeping along it
local lip = brush{kind="round", width=2.4, point=0.3}
lip:reload(pile{{"lead white",1.2},{"ultramarine ash",0.5},{"bone black",0.2}}, 0.8); lip:stroke({{0,641},{500,641},{1000,641}}, {pressure={0.6,0.2}})
local FROST = rect(0, 632, 1000, 22) * mask(function(x,y) return (math.abs(y-641) < 3 + 8*math.exp(-x/260)) and 1 or 0 end)
stipple(FROST, {pile=pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25}}, width=1.2, coverage=1.4, pressure={0.2,0.45}, cluster={0.5, 5}})
stipple(BADGE:grow(3) - BADGE, {pile=pile{{"zinc white",2},{"cerulean blue",0.25}}, width=1.0, coverage=0.4, pressure={0.15,0.3}})
-- the cross: a lit edge along the left of each arm
local cr = brush{kind="round", width=1.0, point=0.5}
cr:reload(pile{{"lead white",2},{"yellow ochre",0.2}}, 0.8); cr:stroke({{302,618},{400,602}}, {pressure={0.45,0.35}})
cr:reload(pile{{"lead white",2},{"yellow ochre",0.2}}, 0.8); cr:stroke({{326,600},{337,632}}, {pressure={0.4,0.3}})

--@ chunk 7
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
PX, PY, PR = 205, 175, 118
local outer = ellipse(PX, PY, PR + 26, PR + 26)
GLASSP = ellipse(PX, PY, PR, PR)
-- the frame: a heavy ring, lit on its lower right inner bevel
fill(outer - GLASSP, pile{{"bone black",1.1},{"ultramarine ash",0.6},{"lead white",0.3},{"bone brown",0.2}}, 5, 1.5708)
local inner = (ellipse(PX, PY, PR + 8, PR + 8) - GLASSP)
fill(inner * mask(function(x,y) return ((x-PX) + (y-PY) > 0) and 1 or 0 end), pile{{"lead white",1.2},{"ultramarine ash",0.4},{"bone black",0.3}}, 2)
fill(inner * mask(function(x,y) return ((x-PX) + (y-PY) <= 0) and 1 or 0 end), pile{{"bone black",1.4},{"ultramarine ash",0.4}}, 2)
-- outside: black space above, the Testament's bronze hull below, cold light on it
local function hy(x) return PY + 10 + 0.0016*(x-PX)^2 - 0.18*(x-PX) end
local space = GLASSP * mask(function(x,y) return (y < hy(x)) and 1 or 0 end)
local hull = GLASSP - space
fill(space, pile{{"bone black",2},{"ultramarine blue",0.6}}, 4)
local HB = {
  {0, 30, pile{{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}},
  {30, 80, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"bone black",0.3}}},
  {80, 400, pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.4}}},
}
for _,h in ipairs(HB) do
  local m = hull * mask(function(x,y) local d = y - hy(x); return (d >= h[1] and d < h[2]) and 1 or 0 end)
  fill(m, h[3], 3, -0.15)
end
blend(hull * mask(function(x,y) local d = y - hy(x); return (math.abs(d-30) < 8 or math.abs(d-80) < 10) and 1 or 0 end), {angle=-0.15, tool={kind="badger", width=6}})

--@ chunk 8
print(wait(2*24*60))
local function hy(x) return PY + 10 + 0.0016*(x-PX)^2 - 0.18*(x-PX) end
local hull = GLASSP * mask(function(x,y) return (y >= hy(x)) and 1 or 0 end)
-- scale lips on the hull outside
local bD = brush{kind="round", width=1.3, point=0.5}
local bL = brush{kind="round", width=0.9, point=0.7}
local d, row = 3, 0
while d < 240 do
  local h = 2 + d*0.06
  local w = h*2.8
  local x = PX - PR - 10 + ((row*0.37)%1)*w
  while x < PX + PR + 10 do
    local y = hy(x) + d
    if hull:at(x, y) > 0.5 then
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; pts[#pts+1] = {x + a*w*0.5, y + h*(1 - a*a)}; lit[#lit+1] = {x + a*w*0.5, y + h*(1 - a*a) - 1} end
      bD:reload(pile{{"bone black",1.4},{"bone brown",0.5}}, 0.7); bD:stroke(pts, {pressure={0.3 + h*0.02, 0.2}})
      if d < 70 then bL:reload(pile{{"lead white",1.3},{"yellow ochre",0.5},{"cerulean blue",0.08}}, 0.6); bL:stroke({lit[1], lit[2], lit[3], lit[4]}, {pressure={0.3, 0.05}}) end
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
-- a cold glint on the hull's edge and a few stars
local e = brush{kind="round", width=1.6, point=0.5}
local pts = {}
for x=PX-PR+6, PX+PR-6, 8 do local y = hy(x); if GLASSP:at(x, y) > 0.5 then pts[#pts+1] = {x, y} end end
e:reload(pile{{"lead white",2},{"cerulean blue",0.15}}, 0.8); e:stroke(pts, {pressure={0.5,0.3}})
local sb = brush{kind="round", width=1.0, point=0.8}
local space = GLASSP * mask(function(x,y) return (y < hy(x) - 4) and 1 or 0 end)
for i=1,40 do local x, y = rand(PX-PR, PX+PR), rand(PY-PR, PY+40); if space:at(x, y) > 0.5 then sb:reload(pile{{"zinc white",3}}, 0.5); sb:touch(x, y, {pressure=rand(0.08,0.25)}) end end
-- a glint on the glass and a frost rime round its lower rim
local gl = brush{kind="round", width=2.6, point=0.5}
gl:reload(pile{{"zinc white",2},{"lead white",1}}, 0.5); gl:stroke({{PX-80, PY-60}, {PX-60, PY-82}}, {pressure={0.3,0.05}})
local rime = GLASSP * mask(function(x,y) local r = math.sqrt((x-PX)^2 + (y-PY)^2); return (r > PR - 10 and y > PY + 20) and 1 or 0 end)
stipple(rime, {pile=pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.2}}, width=1.2, coverage=1.3, pressure={0.2,0.45}, cluster={0.5, 5}})
-- the cold light the porthole throws: a pale patch on the console under it
local patch = ellipse(255, 520, 190, 40) * rect(0, TOPY + 3, 1000, 180) - COVER:grow(1)
work(patch, {hand="glaze", tool={kind="filbert", width=6}, pile=pile{{"lead white",2},{"cerulean blue",0.15},medium=0.6}, load=0.2, pressure={0.08,0.2}, coverage=1.0, clip=patch})

--@ chunk 9
print(wait(24*60))
local objs = COVER:grow(1.5) + LBASE:grow(1) + BADGE:grow(1) + CROSSM:grow(1) + poly({{170,468},{260,464},{262,478},{175,482}}, true):grow(1) + BULB:grow(1)
local top = rect(0, TOPY + 2, 1000, EDGEY - TOPY - 6)
local z1 = ellipse(230, 520, 230, 60) * top - objs
local z2 = ellipse(230, 520, 140, 34) * top - objs
work(z1 - z2, {hand="body", tool={kind="filbert", width=5}, pile=pile{{"lead white",1.1},{"bone black",0.48},{"ultramarine ash",0.42},{"yellow ochre",0.08}}, coverage=4.5, fill=true, clip=z1, angle=0, length={20,60}})
work(z2, {hand="body", tool={kind="filbert", width=5}, pile=pile{{"lead white",1.35},{"bone black",0.42},{"ultramarine ash",0.42},{"cerulean blue",0.05}}, coverage=4.5, fill=true, clip=z2, angle=0, length={20,60}})
blend(ellipse(230, 520, 250, 70) * top - objs - ellipse(230, 520, 200, 50), {angle=0, tool={kind="badger", width=10}})
blend(ellipse(230, 520, 158, 42) * top - objs - ellipse(230, 520, 122, 26), {angle=0, tool={kind="badger", width=8}})
