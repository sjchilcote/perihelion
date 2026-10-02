-- easel session "outpost_fall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=41,
  ground={{pile={{"bone black",1},{"ultramarine ash",1},{"viridian",0.3},{"lead white",0.6}}, um=120, apply="knife", texture=0.3}}}
-- the same garden, months earlier: the same hourglass of floor, the same window
function hw(y) local d = y-300; if d > 0 then return 55 + 0.00563*d*d else return 55 + 0.00328*d*d end end
local L, R = {}, {}
for y=-5,630,5 do L[#L+1] = {500-hw(y), y}; R[#R+1] = {500+hw(y), y} end
local pts = {}
for i=1,#L do pts[#pts+1] = L[i] end
for i=#R,1,-1 do pts[#pts+1] = R[i] end
BAND = poly(pts)
LWALL = mask(function(x,y) return x < 500 - hw(y) and 1 or 0 end)
RWALL = mask(function(x,y) return x > 500 + hw(y) and 1 or 0 end)
VP = poly({{60,150},{290,175},{300,420},{50,455}}, true)
-- walls lit by the grow-lamps: warm grey with a pink cast, brighter toward the waist where the lamps hang
local WLa = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.3},{"rose madder",0.15}}
local WLb = pile{{"bone black",1.3},{"ultramarine ash",0.7},{"lead white",0.12}}
local FLb = pile{{"bone black",1.3},{"bone brown",0.6},{"viridian",0.3},{"lead white",0.05}}
local nearw = mask(function(x,y) local d = math.abs(x-500) - hw(y); return d < 130 and 1 or 0 end)
work((LWALL - VP:grow(9)) - nearw, {hand="body", pile=WLb, coverage=3, fill=true, clip=true, angle=1.5708})
work((LWALL - VP:grow(9)) * nearw, {hand="body", pile=WLa, coverage=3, fill=true, clip=true, angle=1.5708})
work(RWALL - nearw, {hand="body", pile=WLb, coverage=3, fill=true, clip=true, angle=1.5708})
work(RWALL * nearw, {hand="body", pile=WLa, coverage=3, fill=true, clip=true, angle=1.5708})
work(BAND, {hand="body", pile=FLb, coverage=3, fill=true, clip=true, angle=0})
-- the window: deep space, the Sun still far and small
local SPc = pile{{"bone black",2},{"ultramarine blue",1}}
local SPl = pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.15}}
work(VP:grow(9), {hand="body", tool="filbert 6", pile=SPc, coverage=4, fill=true, clip=true, angle=0.3})
work(VP * ellipse(170, 300, 90, 90), {hand="body", tool="filbert 5", pile=SPl, coverage=3, fill=true, clip=true, angle=0.3})
blend(VP * (ellipse(170,300,100,100) - ellipse(170,300,75,75)), {tool={kind="badger", width=10}})

--@ chunk 2
print(wait(24*60))
-- the beds: the same trays, now full and wet
function yt(t) if t >= 0 then return 300 + 325*t^1.7 else return 300 - 300*(-t)^1.7 end end
local TRAY = pile{{"lead white",0.5},{"bone black",1},{"ultramarine ash",1}}
local SOIL = pile{{"bone brown",1.2},{"burnt sienna",0.4},{"bone black",0.6}}
local WET = pile{{"zinc white",2},{"cerulean blue",0.4},{"rose madder",0.1}}
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
-- the crop, dark everywhere, a mass over each bed
local GD = pile{{"viridian",1},{"bone black",0.9},{"bone brown",0.4}}
local order = {}
for _,B in ipairs(BEDS) do order[#order+1] = B end
table.sort(order, function(a, b) return math.abs(a.y-300) < math.abs(b.y-300) end)
for i,B in ipairs(order) do
  local hgt = math.max(4, B.h*2.6)
  local top = B.up and (B.y - hgt) or (B.y + B.h*0.3)
  local m = rect(500-B.w*0.98, top, 2*B.w*0.98, hgt + B.h*0.2):roughen(math.max(1, B.h*0.5), math.max(3, B.h*1.6), i*7) * BAND
  local tw = math.max(1.2, math.min(7, B.h*0.5))
  work(m, {hand="body", tool={kind="filbert", width=tw}, pile=GD, coverage=3, fill=true, clip=m, length={tw*1.5, tw*4}, angle=1.5708})
end

--@ chunk 3
print(wait(2*24*60))
-- darkness takes the near walls; pink light lingers only at the far turn of the ring
local DK = pile{{"bone black",1.4},{"ultramarine ash",0.6},{"rose madder",0.1},{"lead white",0.05}}
local PK1 = pile{{"lead white",0.7},{"bone black",0.7},{"ultramarine ash",0.5},{"rose madder",0.35},{"magenta",0.1}}
local PK2 = pile{{"lead white",1.3},{"rose madder",0.4},{"magenta",0.15},{"bone black",0.25}}
local walls = (LWALL + RWALL) - VP:grow(10)
local function dw(x,y) return math.abs(x-500) - hw(y) end
local far = walls * mask(function(x,y) return (y > 200 and y < 410 and dw(x,y) < 90) and 1 or 0 end)
local core = walls * mask(function(x,y) return (y > 240 and y < 370 and dw(x,y) < 40) and 1 or 0 end)
work(walls - far, {hand="body", pile=DK, coverage=3.4, fill=true, clip=walls, angle=1.5708})
work(far - core, {hand="body", tool={kind="filbert", width=5}, pile=PK1, coverage=3.4, fill=true, clip=far, angle=1.5708})
work(core, {hand="body", tool={kind="filbert", width=4}, pile=PK2, coverage=3.4, fill=true, clip=core, angle=1.5708})
blend(walls * mask(function(x,y) local d = dw(x,y); return ((y > 180 and y < 430) and (math.abs(d-90) < 14 or (math.abs(d-40) < 10 and y > 220 and y < 390))) and 1 or 0 end), {angle=1.5708, tool={kind="badger", width=8}})
blend(walls * mask(function(x,y) local d = dw(x,y); return (d < 90 and (math.abs(y-200) < 14 or math.abs(y-410) < 14 or math.abs(y-240) < 10 or math.abs(y-370) < 10)) and 1 or 0 end), {angle=0, tool={kind="badger", width=8}})

--@ chunk 4
print(wait(3*24*60))
local walls = (LWALL + RWALL) - VP:grow(10)
local function dw(x,y) return math.abs(x-500) - hw(y) end
local function r(x,y) return math.sqrt((dw(x,y)/120)^2 + ((y-305)/135)^2) end
local Z = {
  {0, 0.3, pile{{"lead white",1.3},{"rose madder",0.4},{"magenta",0.15},{"bone black",0.2}}},
  {0.3, 0.5, pile{{"lead white",0.9},{"rose madder",0.35},{"magenta",0.1},{"bone black",0.45},{"ultramarine ash",0.2}}},
  {0.5, 0.72, pile{{"lead white",0.5},{"rose madder",0.3},{"bone black",0.7},{"ultramarine ash",0.4}}},
  {0.72, 0.95, pile{{"lead white",0.22},{"rose madder",0.2},{"bone black",1.0},{"ultramarine ash",0.5}}},
  {0.95, 1.3, pile{{"bone black",1.3},{"ultramarine ash",0.6},{"rose madder",0.12},{"lead white",0.07}}},
}
for _,z in ipairs(Z) do
  local m = walls * mask(function(x,y) local v = r(x,y); return (v >= z[1] and v < z[2]) and 1 or 0 end)
  if m:area() > 2 then work(m, {hand="body", tool={kind="filbert", width=4}, pile=z[3], coverage=3.6, fill=true, clip=walls, angle=1.5708, length={10,35}}) end
end
blend(walls * mask(function(x,y) local v = r(x,y); for _,c in ipairs({0.3,0.5,0.72,0.95}) do if math.abs(v-c) < 0.045 then return 1 end end return 0 end), {tool={kind="badger", width=6}})

--@ chunk 5
local walls = (LWALL + RWALL) - VP:grow(10)
local function dw(x,y) return math.abs(x-500) - hw(y) end
local function r(x,y) return math.sqrt((dw(x,y)/120)^2 + ((y-305)/135)^2) end
blend(walls * mask(function(x,y) return (r(x,y) < 1.05) and 1 or 0 end), {angle=1.5708, tool={kind="badger", width=14}})
print(wait(3*24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- tray lips, dim; pink-lit near the turn
local TRAYD = pile{{"lead white",0.35},{"bone black",1},{"ultramarine ash",1}}
local TRAYP = pile{{"lead white",1.1},{"rose madder",0.3},{"bone black",0.4},{"ultramarine ash",0.4}}
for _,B in ipairs(BEDS) do
  local lipH = math.max(1.5, B.h*0.35)
  local lip = B.up and rect(500-B.w, B.y+B.h/2, 2*B.w, lipH) or rect(500-B.w, B.y-B.h/2-lipH, 2*B.w, lipH)
  fill(lip, (math.abs(B.y-305) < 90) and TRAYP or TRAYD, (B.h > 8) and "round 3" or "round 1.4")
end
-- leaves still catching the pink at the turn of the ring
local GP = pile{{"viridian",0.4},{"lead white",1.2},{"rose madder",0.4},{"cadmium yellow",0.2}}
local GM = pile{{"viridian",0.7},{"cadmium yellow",0.5},{"rose madder",0.2},{"lead white",0.4},{"bone black",0.2}}
for _,B in ipairs(BEDS) do
  local d = math.abs(B.y - 305)
  if d < 140 then
    local tw = math.max(1.0, math.min(6, B.h*0.45))
    local lb = brush{kind="filbert", width=tw}
    local hgt = math.max(4, B.h*2.6)
    local n = math.floor(math.min(70, B.w/2) * (1 - d/140))
    for k=1,n do
      local x = 500 - B.w + rand(0, 2*B.w)
      local y = B.up and (B.y - hgt*rand(0.5, 1.0)) or (B.y + B.h*0.3 + hgt*rand(0.5, 1.0))
      local ang = rand(-0.9, 0.9) + (B.up and -1.5708 or 1.5708)
      local dl = tw*rand(1.2, 2.0)
      lb:reload((math.random() < 0.5) and GP or GM, 0.7)
      lb:stroke({{x,y},{x + math.cos(ang)*dl, y + math.sin(ang)*dl}}, {pressure={0.5,0.1}, ramps={0.1,0.6}})
    end
  end
end
-- the lamps: near and overhead dead, the mid one dimming, the one at the turn still burning
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.1}}
local DEAD = pile{{"bone black",1},{"cobalt violet",0.4},{"lead white",0.15}}
local DIM = pile{{"magenta",0.6},{"rose madder",0.5},{"lead white",0.6},{"bone black",0.3}}
local LIVE = pile{{"zinc white",2},{"magenta",0.4},{"lead white",1}}
local ROD = pile{{"bone black",1.5},{"ultramarine ash",0.6}}
local LL = {{x0=300, x1=700, y=470, hh=12, lh=7, down=false, p=DEAD}, {x0=438, x1=562, y=362, hh=6, lh=4, down=false, p=DIM},
            {x0=470, x1=530, y=326, hh=3, lh=2.5, down=false, p=LIVE}, {x0=414, x1=586, y=158, hh=7, lh=5, down=true, p=DEAD}}
for _,Lm in ipairs(LL) do
  local w = Lm.x1 - Lm.x0
  local hs, ln
  if Lm.down then hs = rect(Lm.x0, Lm.y + Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 2, Lm.y, w - 4, Lm.lh)
  else hs = rect(Lm.x0, Lm.y - Lm.hh - Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 2, Lm.y - Lm.lh, w - 4, Lm.lh) end
  local rb = brush{kind="round", width=math.max(1, Lm.hh*0.18), point=0.3}
  for _,x in ipairs({Lm.x0 + w*0.12, Lm.x1 - w*0.12}) do
    rb:reload(ROD, 0.9)
    if Lm.down then rb:stroke({{x, Lm.y + Lm.lh + Lm.hh}, {x + (500-x)*0.1, Lm.y + Lm.lh + Lm.hh + 45}}, {pressure={0.7,0.7}})
    else rb:stroke({{x, Lm.y - Lm.lh - Lm.hh}, {x + (500-x)*0.1, Lm.y - Lm.lh - Lm.hh - math.min(55, w*0.4)}}, {pressure={0.7,0.7}}) end
  end
  fill(hs, HOUS, "round 2")
  fill(ln, Lm.p)
end

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- near tray lips back into the dark, with a red edge from the strips
local TRAYK = pile{{"bone black",1.3},{"ultramarine ash",0.7},{"lead white",0.1}}
local REDG = pile{{"cadmium red",1},{"vermilion",0.4},{"bone black",0.3}}
for _,B in ipairs(BEDS) do
  if math.abs(B.y - 305) >= 90 then
    local lipH = math.max(1.5, B.h*0.35)
    local lip = B.up and rect(500-B.w, B.y+B.h/2, 2*B.w, lipH) or rect(500-B.w, B.y-B.h/2-lipH, 2*B.w, lipH)
    fill(lip, TRAYK, (B.h > 8) and "round 3" or "round 1.4")
    local yy = B.up and (B.y + B.h/2 + 0.6) or (B.y - B.h/2 - lipH + 0.6)
    local gb = brush{kind="round", width=math.max(0.6, lipH*0.25), point=0.5}
    for _,side in ipairs({-1, 1}) do
      gb:reload(REDG, 0.7)
      local x0 = 500 + side*B.w
      gb:stroke({{x0, yy}, {x0 - side*B.w*0.35, yy}}, {pressure={0.45,0.0}, ramps={0.05,0.9}})
    end
  end
end
-- red emergency strips along both feet of the walls, flickering: lit in runs, dead between
local RL = pile{{"cadmium red",1},{"vermilion",0.6},{"lead white",0.35}}
local RD = pile{{"Mars red",1},{"bone black",0.8}}
local RGLOW = pile{{"cadmium red",1},{"Mars red",0.5},{"bone black",0.5},medium=0.5}
for _,side in ipairs({-1, 1}) do
  local seg, k = {}, 0
  for y=-5,630,6 do
    seg[#seg+1] = {500 + side*(hw(y)-2), y}
    if #seg >= 6 then
      k = k + 1
      local lit = (k*7 + (side > 0 and 3 or 0)) % 5 ~= 0 and (k % 4 ~= 2)
      local m = ribbon(seg, 6)
      fill(m, lit and RL or RD, "round 2")
      if lit then
        local g = ribbon(seg, 26) * mask(function(x,y) return math.abs(math.abs(x-500) - hw(y)) < 13 and 1 or 0 end) - m
        work(g, {hand="scumble", tool={kind="filbert", width=4}, pile=RGLOW, coverage=0.8, load=0.25, pressure={0.08,0.2}, clip=g})
      end
      seg = {seg[#seg]}
    end
  end
end
-- the door at the far end of the curve, on the right wall: half-open, violet beyond
local DF = pile{{"bone black",1.5},{"ultramarine ash",0.5}}
local VIO = pile{{"cobalt violet",1},{"zinc white",0.8},{"magenta",0.2}}
local VIO2 = pile{{"cobalt violet",1},{"ultramarine blue",0.4},{"lead white",0.3}}
local function W(d, y) return {500 + hw(y) + d, y} end
local frame = poly({W(10, 262), W(36, 258), W(36, 334), W(10, 334)})
local gap = poly({W(14, 266), W(24, 264), W(24, 333), W(14, 333)})
local leaf = poly({W(24, 264), W(33, 262), W(33, 333), W(24, 333)})
fill(frame, DF, "round 2")
fill(gap, VIO, "round 1.4")
fill(leaf, pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.25}}, "round 1.4")
local c = W(19, 300)
local spill = poly({W(14, 333), W(24, 333), {c[1] - 45, 352}, {c[1] - 70, 346}}) * BAND
work(spill, {hand="glaze", tool={kind="filbert", width=4}, pile=pile{{"cobalt violet",1},{"lead white",0.6},medium=0.6}, load=0.3, pressure={0.1,0.25}, coverage=1.2, clip=spill, angle=3.0})
local halo = ellipse(c[1], c[2], 22, 46) * (RWALL - gap - leaf)
work(halo, {hand="scumble", tool={kind="filbert", width=3}, pile=VIO2, coverage=0.7, load=0.2, pressure={0.08,0.2}, clip=halo})

--@ chunk 7
print(wait(2*24*60))
-- the window: mullions, a far small Sun, stars
local MUL = pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.15}}
local fr = VP:grow(9) - VP
work(fr, {hand="detail", tool="round 3", pile=MUL, coverage=4, fill=true, clip=true})
local b = brush{kind="flat", width=7}
for _,s in ipairs({{{140,150},{135,450}}, {{222,160},{222,440}}}) do b:reload(MUL, 0.95); b:stroke(s, {pressure={0.9,0.9}, ramps={0.01,0.01}, orient="across", clip=VP:grow(2)}) end
for _,s in ipairs({{{45,240},{300,250}}, {{45,345},{300,340}}}) do b:reload(MUL, 0.95); b:stroke(s, {pressure={0.9,0.9}, ramps={0.01,0.01}, orient="across", clip=VP:grow(2)}) end
local sb = brush{kind="round", width=1.0, point=0.8}
local inn = VP:shrink(3)
for i=1,140 do
  local x, y = rand(50, 300), rand(150, 455)
  if inn:at(x,y) > 0.5 then sb:reload(pile{{"zinc white",3},{"lead white",1}}, 0.5); sb:touch(x, y, {pressure=rand(0.1,0.35)}) end
end
work(ellipse(178, 292, 4, 4), {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.2}}, coverage=4, fill=true, clip=true})
local rr = brush{kind="rigger", width=0.8, point=1}
for _,a in ipairs({0.3, 1.87, 3.44, 5.0}) do rr:reload(pile{{"zinc white",3}}, 0.5); rr:stroke({{178+5*math.cos(a), 292+5*math.sin(a)}, {178+20*math.cos(a), 292+20*math.sin(a)}}, {pressure={0.3,0}}) end
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- the watering can, dropped and rolling, water running out across the deck catching the red
local CAN = pile{{"chrome yellow",1.5},{"Mars orange",0.5},{"bone black",0.35}}
local CAND = pile{{"Mars orange",1},{"bone brown",0.8},{"bone black",0.3}}
local CANR = pile{{"cadmium red",1},{"chrome yellow",0.6},{"lead white",0.3}}
local cx, cy = 655, 560
local body = poly({{cx-16, cy-14}, {cx+12, cy-20}, {cx+18, cy}, {cx-10, cy+6}}, true)
fill(body, CAN, "round 2")
fill(poly({{cx+12, cy-20}, {cx+20, cy-17}, {cx+24, cy+2}, {cx+18, cy}}, true), CAND)
local sb = brush{kind="round", width=3.6, point=0.2}
sb:reload(CAN, 0.9); sb:stroke({{cx-14, cy-4}, {cx-34, cy+4}, {cx-46, cy+10}}, {pressure={0.8,0.6}})
sb:reload(CAND, 0.9); sb:stroke({{cx-6, cy-17}, {cx, cy-30}, {cx+10, cy-19}}, {pressure={0.55,0.55}})
local hl = brush{kind="round", width=1.4, point=0.5}
hl:reload(CANR, 0.8); hl:stroke({{cx-14, cy-13}, {cx+10, cy-19}}, {pressure={0.4,0.3}})
-- the spill: a dark wet sheet with red glints
local WET = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"viridian",0.2}}
local spill = poly({{cx-50, cy+11}, {cx-70, cy+16}, {cx-110, cy+26}, {cx-150, cy+24}, {cx-120, cy+34}, {cx-70, cy+30}, {cx-40, cy+20}}, true) * BAND
fill(spill, WET, "round 2")
local gl = brush{kind="round", width=1.2, point=0.5}
for i=1,12 do
  local x = cx - 50 - rand(0, 95); local y = cy + 16 + rand(0, 14)
  if spill:at(x, y) > 0.5 then gl:reload((i % 3 == 0) and pile{{"cobalt violet",1},{"zinc white",1}} or pile{{"cadmium red",1},{"lead white",0.6}}, 0.7); gl:stroke({{x, y}, {x + rand(3, 9), y}}, {pressure={0.4,0.1}}) end
end
-- the work cart, its mug knocked over and spilled
local CART = pile{{"lead white",0.4},{"bone black",1},{"ultramarine ash",1}}
local CARTD = pile{{"bone black",1.8},{"ultramarine ash",0.5}}
fill(rect(250, 540, 90, 40), CART, "round 2")
fill(rect(250, 552, 90, 5), pile{{"cadmium red",0.6},{"chrome yellow",0.6},{"bone black",0.5}})
fill(rect(254, 578, 82, 6), CARTD)
fill(ellipse(262, 590, 6, 6) + ellipse(328, 590, 6, 6), CARTD)
fill(rect(256, 528, 78, 12), pile{{"bone brown",1},{"bone black",0.6}})
local MUG = pile{{"lead white",0.9},{"cerulean blue",0.2},{"bone black",0.4},{"rose madder",0.1}}
local mug = poly({{300, 517}, {324, 521}, {322, 531}, {298, 527}}, true)
fill(mug, MUG)
fill(ellipse(326, 526, 3, 5.5), pile{{"bone black",1.5}})
local mh = brush{kind="round", width=1.8, point=0.3}
mh:reload(MUG, 0.9); mh:stroke({{304, 517}, {306, 510}, {314, 512}, {314, 519}}, {pressure={0.5,0.5}})
local drip = brush{kind="round", width=2.2, point=0.6}
drip:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.8); drip:stroke({{329, 527}, {340, 529}, {341, 545}}, {pressure={0.5,0.2}})
drip:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.6); drip:stroke({{341, 547}, {341, 572}}, {pressure={0.35,0.1}})

--@ chunk 8
print(wait(24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- the cart in the dark, its edges catching the red
local CARTK = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.12}}
fill(rect(250, 540, 90, 12) + rect(250, 557, 90, 23), CARTK, "round 2")
fill(rect(250, 552, 90, 5), pile{{"Mars orange",0.6},{"bone black",0.8}})
local e = brush{kind="round", width=1.2, point=0.5}
e:reload(pile{{"cadmium red",1},{"vermilion",0.4},{"lead white",0.2}}, 0.7)
e:stroke({{250, 540.5}, {250, 580}}, {pressure={0.45,0.3}})
e:reload(pile{{"cadmium red",1},{"vermilion",0.4},{"lead white",0.2}}, 0.6)
e:stroke({{250, 540.5}, {300, 540.5}}, {pressure={0.4,0.05}})
-- the spill: wider, a dark sheet that mirrors the red strips and a fleck of violet
local WET = pile{{"bone black",1.4},{"ultramarine blue",0.3},{"Mars red",0.2}}
local cx, cy = 655, 560
local spill = poly({{cx-46, cy+8}, {cx-80, cy+12}, {cx-130, cy+20}, {cx-175, cy+18}, {cx-150, cy+32}, {cx-90, cy+34}, {cx-40, cy+22}}, true) * BAND
fill(spill, WET, "round 2")
local gl = brush{kind="round", width=1.6, point=0.5}
for i=1,16 do
  local x = cx - 50 - rand(0, 120); local y = cy + 14 + rand(0, 16)
  if spill:shrink(1.5):at(x, y) > 0.5 then
    gl:reload((i % 5 == 0) and pile{{"cobalt violet",1},{"zinc white",1}} or pile{{"cadmium red",1},{"vermilion",0.5},{"lead white",0.5}}, 0.8)
    gl:stroke({{x, y}, {x + rand(5, 14), y + rand(-0.5, 0.5)}}, {pressure={0.5,0.1}})
  end
end
-- the door: open wider; violet light beyond, and lying across the deck at the turn
local VIO = pile{{"cobalt violet",1},{"zinc white",1},{"magenta",0.15}}
local VIOD = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",0.25}}
local function Wd(d, y) return {500 + hw(y) + d, y} end
fill(poly({Wd(13, 265), Wd(28, 263), Wd(28, 333), Wd(13, 333)}), VIO)
fill(poly({Wd(28, 263), Wd(37, 260), Wd(37, 334), Wd(28, 333)}), pile{{"bone black",1},{"ultramarine ash",0.6},{"cobalt violet",0.3},{"lead white",0.2}})
local e2 = brush{kind="round", width=1.0, point=0.5}
e2:reload(VIO, 0.7); e2:stroke({Wd(28.5, 264), Wd(28.5, 332)}, {pressure={0.4,0.4}})
local fan = poly({Wd(13, 333), Wd(28, 333), {470, 352}, {438, 349}}) * BAND
work(fan, {hand="body", tool={kind="filbert", width=2}, pile=VIOD, coverage=2.5, fill=true, clip=fan, angle=3.05, length={8,25}})
local fan2 = poly({Wd(15, 334), Wd(26, 334), {492, 346}, {468, 345}}) * BAND
work(fan2, {hand="detail", tool={kind="round", width=1.2}, pile=VIO, coverage=3, fill=true, clip=fan2, angle=3.05})

--@ chunk 9
print(wait(24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
local function Wd(d, y) return {500 + hw(y) + d, y} end
local VS = pile{{"cobalt violet",1},{"magenta",0.35},{"ultramarine blue",0.35},{"lead white",0.25}}
local VC = pile{{"zinc white",1},{"cobalt violet",0.8},{"magenta",0.2}}
fill(poly({Wd(13, 265), Wd(28, 263), Wd(28, 333), Wd(13, 333)}), VS)
local core = brush{kind="round", width=2.2, point=0.5}
core:reload(VC, 0.85); core:stroke({Wd(25, 266), Wd(25.5, 300), Wd(25.5, 331)}, {pressure={0.55,0.45}})
-- the leaf of the door, dark, with a violet edge
fill(poly({Wd(28, 263), Wd(37, 260), Wd(37, 334), Wd(28, 333)}), pile{{"bone black",1.4},{"ultramarine ash",0.4},{"cobalt violet",0.15}})
-- violet light lying across the beds from the gap, in a long wedge
local VG = pile{{"cobalt violet",1},{"magenta",0.25},{"ultramarine blue",0.4},{"lead white",0.15},medium=0.4}
local wedge = poly({Wd(13, 333), Wd(28, 333), {470, 356}, {420, 356}}) * BAND
work(wedge, {hand="scumble", tool={kind="filbert", width=2.5}, pile=VG, coverage=1.6, load=0.45, pressure={0.2,0.4}, clip=wedge, angle=3.05})
-- and a cold violet breath on the wall round the frame
local halo = ellipse(Wd(22, 298)[1], 298, 26, 52) * RWALL - poly({Wd(10, 260), Wd(38, 258), Wd(38, 335), Wd(10, 335)})
work(halo, {hand="scumble", tool={kind="filbert", width=3}, pile=VG, coverage=1.0, load=0.3, pressure={0.12,0.28}, clip=halo})

--@ chunk 10
local function Wd(d, y) return {500 + hw(y) + d, y} end
local door = poly({Wd(10, 258), Wd(38, 256), Wd(38, 336), Wd(10, 336)})
local zone = ellipse(Wd(22, 298)[1], 298, 40, 66) * RWALL - door:grow(1)
blend(zone, {tool={kind="badger", width=10}})
blend(zone, {angle=1.5708, tool={kind="badger", width=10}})
local wz = poly({Wd(13, 330), Wd(28, 330), {480, 360}, {400, 360}}) * BAND
blend(wz, {angle=3.05, tool={kind="badger", width=6}})

--@ chunk 11
print(wait(24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
fill(rect(251, 541, 88, 11) + rect(251, 558, 88, 21), pile{{"bone black",1.6},{"ultramarine ash",0.4},{"bone brown",0.3}}, "round 2")
local e = brush{kind="round", width=1.2, point=0.5}
local RE = pile{{"cadmium red",1},{"vermilion",0.4},{"lead white",0.2}}
e:reload(RE, 0.7); e:stroke({{250.5, 541}, {250.5, 580}}, {pressure={0.45,0.3}})
-- near leaves catching the red of the strips, thickest by the walls
local LR = pile{{"cadmium red",0.6},{"viridian",0.3},{"bone black",0.3},{"Mars orange",0.2}}
local LR2 = pile{{"vermilion",0.6},{"lead white",0.3},{"viridian",0.15}}
for _,B in ipairs(BEDS) do
  if math.abs(B.y - 305) >= 110 then
    local tw = math.max(1.0, math.min(6, B.h*0.45))
    local lb = brush{kind="filbert", width=tw}
    local hgt = math.max(4, B.h*2.6)
    for k=1,math.floor(math.min(40, B.w/4)) do
      local side = (math.random() < 0.5) and -1 or 1
      local u = math.abs(randn(0, 0.25))
      local x = 500 + side*B.w*(1 - math.min(0.9, u))
      local y = B.up and (B.y - hgt*rand(0.4, 1.0)) or (B.y + B.h*0.3 + hgt*rand(0.4, 1.0))
      local ang = rand(-0.9, 0.9) + (B.up and -1.5708 or 1.5708)
      local dl = tw*rand(1.0, 1.8)
      lb:reload((u < 0.1) and LR2 or LR, 0.6)
      lb:stroke({{x,y},{x + math.cos(ang)*dl, y + math.sin(ang)*dl}}, {pressure={0.45,0.1}, ramps={0.1,0.6}})
    end
  end
end

--@ chunk 12
print(wait(24*60))
local cx, cy = 655, 560
local gl = brush{kind="round", width=2.0, point=0.5}
local RR = pile{{"cadmium red",1},{"vermilion",0.6},{"lead white",0.6}}
for _,s in ipairs({{-60, 20, 30}, {-100, 25, 40}, {-140, 24, 22}, {-80, 28, 18}}) do
  gl:reload(RR, 0.85); gl:stroke({{cx + s[1], cy + s[2]}, {cx + s[1] + s[3], cy + s[2] - 1.5}}, {pressure={0.55,0.15}})
end
gl:reload(pile{{"cobalt violet",1},{"zinc white",1}}, 0.8); gl:stroke({{cx - 120, cy + 29}, {cx - 108, cy + 28}}, {pressure={0.45,0.1}})
