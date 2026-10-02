-- easel session "hydro_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=38,
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
local WLa = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.8},{"rose madder",0.2},{"yellow ochre",0.15}}
local WLb = pile{{"lead white",0.6},{"bone black",0.8},{"ultramarine ash",1},{"rose madder",0.15}}
local FLb = pile{{"bone black",1},{"bone brown",0.6},{"viridian",0.4},{"lead white",0.15}}
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
-- the seam between the lamp-lit and far wall, softened
local edge = mask(function(x,y) local d = math.abs(x-500) - hw(y); return (d > 115 and d < 145) and 1 or 0 end) * (LWALL + RWALL) - VP:grow(10)
blend(edge, {angle=1.5708, tool={kind="badger", width=12}})
-- the beds: the same trays, now full and wet
function yt(t) if t >= 0 then return 300 + 325*t^1.7 else return 300 - 300*(-t)^1.7 end end
local TRAY = pile{{"lead white",1.4},{"bone black",0.6},{"ultramarine ash",1},{"rose madder",0.1}}
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

--@ chunk 3
print(wait(2*24*60))
-- lush masses of crop over each bed, far beds first so the near ones overlap them
local GD = pile{{"viridian",1},{"bone black",0.45},{"bone brown",0.3},{"cadmium yellow",0.2}}
local GM = pile{{"viridian",0.6},{"cadmium yellow",1},{"bone black",0.15},{"yellow ochre",0.2}}
local GL = pile{{"cadmium yellow",1},{"viridian",0.35},{"lead white",0.9}}
local GP = pile{{"viridian",0.4},{"lead white",1.2},{"rose madder",0.3},{"cadmium yellow",0.3}}
local order = {}
for _,B in ipairs(BEDS) do order[#order+1] = B end
table.sort(order, function(a, b) return math.abs(a.y-300) < math.abs(b.y-300) end)
for i,B in ipairs(order) do
  local hgt = math.max(4, B.h*2.6)
  local top = B.up and (B.y - hgt) or (B.y + B.h*0.3)
  local m = rect(500-B.w*1.02, top, 2*B.w*1.02, hgt + B.h*0.2):roughen(math.max(1, B.h*0.5), math.max(3, B.h*1.6), i*7)
  local tw = math.max(1.2, math.min(7, B.h*0.5))
  work(m, {hand="body", tool={kind="filbert", width=tw}, pile=GD, coverage=2.6, fill=true, clip=m, length={tw*1.5, tw*4}, angle=1.5708})
  local lit = B.up and (m * rect(0, top - 5, 1000, hgt*0.55 + 5)) or (m * rect(0, top + hgt*0.45, 1000, hgt*0.6 + 5))
  stipple(lit, {pile=GM, width=tw*0.9, coverage=0.9, pressure={0.3,0.6}, cluster={0.5, tw*3}, drag={tw*0.8, B.up and -1.2 or 1.2}})
  stipple(lit, {pile=GL, width=tw*0.7, coverage=0.35, pressure={0.25,0.5}, cluster={0.6, tw*3}, drag={tw*0.6, B.up and -1.0 or 1.0}})
  stipple(m, {pile=GP, width=tw*0.6, coverage=0.12, pressure={0.2,0.4}, cluster={0.7, tw*4}})
end

--@ chunk 4
print(wait(2*24*60))
local TRAY = pile{{"lead white",1.5},{"bone black",0.5},{"ultramarine ash",1},{"rose madder",0.12}}
local TRAYD = pile{{"bone black",1.5},{"ultramarine ash",1}}
local WET = pile{{"zinc white",2},{"cerulean blue",0.4},{"rose madder",0.1}}
local GL = pile{{"cadmium yellow",1},{"viridian",0.3},{"lead white",1.0}}
local GM = pile{{"viridian",0.5},{"cadmium yellow",1},{"lead white",0.2},{"yellow ochre",0.2}}
local GP = pile{{"viridian",0.3},{"lead white",1.4},{"rose madder",0.35},{"cadmium yellow",0.3}}
local order = {}
for _,B in ipairs(BEDS) do order[#order+1] = B end
table.sort(order, function(a, b) return math.abs(a.y-300) < math.abs(b.y-300) end)
for i,B in ipairs(order) do
  local hgt = math.max(4, B.h*2.6)
  local tw = math.max(1.0, math.min(6, B.h*0.45))
  -- leaves catching the lamps along the crown of each bed
  local lb = brush{kind="filbert", width=tw}
  local cnt = math.min(70, math.floor(B.w/3))
  for k=1,cnt do
    local x = 500 - B.w + rand(0, 2*B.w)
    local y = B.up and (B.y - hgt*rand(0.55, 1.0)) or (B.y + B.h*0.3 + hgt*rand(0.55, 1.0))
    local ang = rand(-0.9, 0.9) + (B.up and -1.5708 or 1.5708)
    local r = rand(0,1)
    local p = (r < 0.5) and GM or ((r < 0.85) and GL or GP)
    local dl = tw*rand(1.2, 2.2)
    lb:reload(p, 0.75)
    lb:stroke({{x,y},{x + math.cos(ang)*dl, y + math.sin(ang)*dl}}, {pressure={0.55,0.1}, ramps={0.1,0.6}})
  end
  -- the tray's front lip, crisp, with a wet glint on its edge
  local lipH = math.max(1.5, B.h*0.35)
  local lip = B.up and rect(500-B.w, B.y+B.h/2, 2*B.w, lipH) or rect(500-B.w, B.y-B.h/2-lipH, 2*B.w, lipH)
  local tool = (B.h > 8) and "round 3" or "round 1.4"
  work(lip, {hand="detail", tool=tool, pile=TRAY, coverage=4, fill=true, clip=true, angle=0})
  local under = B.up and rect(500-B.w, B.y+B.h/2+lipH, 2*B.w, math.max(1, lipH*0.5)) or rect(500-B.w, B.y-B.h/2-lipH*1.5, 2*B.w, math.max(1, lipH*0.5))
  work(under, {hand="detail", tool="round 1.4", pile=TRAYD, coverage=4, fill=true, clip=true, angle=0})
  local wb = brush{kind="round", width=math.max(0.6, lipH*0.3), point=0.5}
  for g=1,3 do
    local x = 500 - B.w + rand(0.1, 1.9)*B.w
    local yy = B.up and (B.y+B.h/2+0.3) or (B.y-B.h/2-lipH+0.3)
    wb:reload(WET, 0.6); wb:stroke({{x, yy}, {x + rand(4,14)*math.max(0.4,B.h/10), yy}}, {pressure={0.35,0.1}})
  end
end
-- amber hazard strips along the feet of both walls
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1},{"bone black",0.08}}
local edgeL, edgeR = {}, {}
for y=-5,630,6 do edgeL[#edgeL+1] = {500-hw(y)+2, y}; edgeR[#edgeR+1] = {500+hw(y)-2, y} end
HZ = ribbon(edgeL, 7) + ribbon(edgeR, 7)
work(HZ, {hand="detail", tool="round 2", pile=AMB, coverage=4, fill=true, clip=true})

--@ chunk 5
-- clean the walls where the crop overran them
local WLa = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.8},{"rose madder",0.2},{"yellow ochre",0.15}}
local nearw = mask(function(x,y) local d = math.abs(x-500) - hw(y); return (d > 3 and d < 128) and 1 or 0 end)
local w = (LWALL + RWALL) * nearw - VP:grow(10) - HZ:grow(1)
work(w, {hand="body", pile=WLa, coverage=3.2, fill=true, clip=w, angle=1.5708})
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

--@ chunk 6
print(wait(24*60))
-- grow-lamps that read as lamps: heavy housings on rods, blazing pink-violet lenses
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.15}}
local LENS3 = pile{{"zinc white",1.5},{"magenta",1},{"lead white",0.5},{"cobalt violet",0.2}}
local HOT = pile{{"zinc white",3},{"magenta",0.12}}
local ROD = pile{{"bone black",1.5},{"ultramarine ash",0.6}}
local LL = {{x0=300, x1=700, y=470, hh=12, lh=7, down=false}, {x0=438, x1=562, y=362, hh=6, lh=4, down=false}, {x0=414, x1=586, y=158, hh=7, lh=5, down=true}}
for _,Lm in ipairs(LL) do
  local w = Lm.x1 - Lm.x0
  local hs, ln
  if Lm.down then hs = rect(Lm.x0, Lm.y + Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 3, Lm.y, w - 6, Lm.lh)
  else hs = rect(Lm.x0, Lm.y - Lm.hh - Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 3, Lm.y - Lm.lh, w - 6, Lm.lh) end
  local r = brush{kind="round", width=math.max(1.2, Lm.hh*0.18), point=0.3}
  for _,x in ipairs({Lm.x0 + w*0.12, Lm.x1 - w*0.12}) do
    r:reload(ROD, 0.9)
    if Lm.down then r:stroke({{x, Lm.y + Lm.lh + Lm.hh}, {x + (500-x)*0.1, Lm.y + Lm.lh + Lm.hh + 45}}, {pressure={0.7,0.7}})
    else r:stroke({{x, Lm.y - Lm.lh - Lm.hh}, {x + (500-x)*0.1, Lm.y - Lm.lh - Lm.hh - 55}}, {pressure={0.7,0.7}}) end
  end
  work(hs, {hand="detail", tool="round 2", pile=HOUS, coverage=4.5, fill=true, clip=true, angle=0})
  work(ln, {hand="detail", tool="round 1.4", pile=LENS3, coverage=4.5, fill=true, clip=true, angle=0})
end
print(wait(24*60))
for _,Lm in ipairs(LL) do
  local hl = brush{kind="round", width=math.max(0.8, Lm.lh*0.3), point=0.5}
  local yy = Lm.y + (Lm.down and 1 or -1)*Lm.lh*0.5
  hl:reload(HOT, 0.85); hl:stroke({{Lm.x0 + 8, yy}, {Lm.x1 - 8, yy}}, {pressure={0.5,0.5}})
end

--@ chunk 7
print(wait(24*60))
local CORE = pile{{"zinc white",3},{"lead white",1},{"magenta",0.15}}
local EDGE = pile{{"zinc white",1},{"magenta",1},{"cobalt violet",0.3}}
local GLOW = pile{{"lead white",2},{"zinc white",1},{"magenta",0.35},{"cobalt violet",0.1}}
local LL = {{x0=300, x1=700, y=470, lh=7, down=false}, {x0=438, x1=562, y=362, lh=4, down=false}, {x0=414, x1=586, y=158, lh=5, down=true}}
for _,Lm in ipairs(LL) do
  local w = Lm.x1 - Lm.x0
  local ln = Lm.down and rect(Lm.x0 + 3, Lm.y, w - 6, Lm.lh) or rect(Lm.x0 + 3, Lm.y - Lm.lh, w - 6, Lm.lh)
  local core = Lm.down and rect(Lm.x0 + 8, Lm.y + Lm.lh*0.15, w - 16, Lm.lh*0.5) or rect(Lm.x0 + 8, Lm.y - Lm.lh*0.65, w - 16, Lm.lh*0.5)
  work(ln - core, {hand="detail", tool="round 1.2", pile=EDGE, coverage=4, fill=true, clip=ln - core, angle=0})
  work(core, {hand="detail", tool="round 1.2", pile=CORE, coverage=4.5, fill=true, clip=core, angle=0})
  -- light falling from the lens: a broken pale scumble just below it
  local gh = Lm.lh*3.2
  local g = Lm.down and poly({{Lm.x0, Lm.y}, {Lm.x1, Lm.y}, {Lm.x1 + 10, Lm.y - gh}, {Lm.x0 - 10, Lm.y - gh}}) or poly({{Lm.x0, Lm.y}, {Lm.x1, Lm.y}, {Lm.x1 + 12, Lm.y + gh}, {Lm.x0 - 12, Lm.y + gh}})
  g = g * BAND
  work(g, {hand="scumble", tool={kind="filbert", width=math.max(2, Lm.lh*0.6)}, pile=GLOW, coverage=0.9, load=0.18, pressure={0.08,0.2}, clip=g, angle=0})
end

--@ chunk 8
-- the irrigation lines along the right wall, following the curve, with a lit upper edge
local MUL = pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.15}}
local LITP = pile{{"lead white",2},{"rose madder",0.15},{"ultramarine ash",0.4}}
local avoid = rect(752, 285, 86, 72)
for k,off in ipairs({40, 58, 140}) do
  local p, p2 = {}, {}
  for y=-5,630,6 do
    local x = 500+hw(y)+off*(hw(y)/120)
    p[#p+1] = {x, y}; p2[#p2+1] = {x - math.max(1, 3 - k*0.5), y}
  end
  local r = brush{kind="round", width=math.max(3, 6 - k), point=0.2}
  r:reload(MUL, 0.9); r:stroke(p, {pressure={0.8,0.8}, ramps={0.01,0.01}, clip=RWALL - avoid})
  local r2 = brush{kind="round", width=1.0, point=0.3}
  r2:reload(LITP, 0.7); r2:stroke(p2, {pressure={0.45,0.45}, ramps={0.01,0.01}, clip=RWALL - avoid})
end

--@ chunk 9
print(wait(2*24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- the docents' channel: a narrow hand-beaten bronze runnel down the middle of the floor, through the beds and up overhead
local L, R = {}, {}
for y=-5,630,5 do local w = 4 + 0.075*hw(y); L[#L+1] = {500 - w, y}; R[#R+1] = {500 + w, y} end
local pts = {}
for i=1,#L do pts[#pts+1] = L[i] end
for i=#R,1,-1 do pts[#pts+1] = R[i] end
CHAN = poly(pts)
local BR = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"raw sienna",0.4},{"bone black",0.1}}
local BRD = pile{{"burnt sienna",1},{"bone brown",0.6},{"bone black",0.3}}
fill(CHAN, BR, "round 2")
local WAT = {}
for y=-5,630,5 do local w = 1.5 + 0.045*hw(y); WAT[#WAT+1] = {y, w} end
local wl, wr = {}, {}
for _,v in ipairs(WAT) do wl[#wl+1] = {500 - v[2], v[1]}; wr[#wr+1] = {500 + v[2], v[1]} end
local wp = {}
for i=1,#wl do wp[#wp+1] = wl[i] end
for i=#wr,1,-1 do wp[#wp+1] = wr[i] end
WATM = poly(wp)
fill(WATM, pile{{"cerulean blue",0.6},{"lead white",1},{"viridian",0.2},{"magenta",0.05}}, "round 1.4")
-- its beaten edges: lips catching the lamps, dark seams, little phyllotactic studs along the rim
local eb = brush{kind="round", width=1.4, point=0.4}
local le, re = {}, {}
for y=-5,630,10 do local w = 4 + 0.075*hw(y); le[#le+1] = {500 - w, y}; re[#re+1] = {500 + w, y} end
eb:reload(BRD, 0.8); eb:stroke(le, {pressure={0.45,0.45}})
eb:reload(BRD, 0.8); eb:stroke(re, {pressure={0.45,0.45}})
local st = brush{kind="round", width=2, point=0.3}
local k = 0
local y = 4
while y < 620 do
  local w = 4 + 0.075*hw(y)
  local s = math.max(0.8, 0.025*hw(y))
  k = k + 1
  st:reload(pile{{"lead white",1.2},{"yellow ochre",0.6},{"cadmium yellow",0.2}}, 0.8)
  st:touch(500 - w, y, {pressure=math.min(0.6, 0.15 + s*0.08)}); st:touch(500 + w, y + 2, {pressure=math.min(0.6, 0.15 + s*0.08)})
  y = y + math.max(3, 0.12*hw(y)) * 1.618
end
-- glints on the water
local gb = brush{kind="round", width=1.2, point=0.6}
for i=1,40 do
  local yy = rand(0, 625)
  local w = 1.5 + 0.045*hw(yy)
  gb:reload(pile{{"zinc white",3},{"magenta",0.05}}, 0.7)
  gb:stroke({{500 - w*0.6, yy}, {500 + w*0.3, yy + 0.5}}, {pressure={0.35,0.1}})
end

--@ chunk 10
print(wait(24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- Testator bone-flowers among the crops: ivory heads, seeds set in golden-angle spirals
local IV = pile{{"lead white",1.6},{"yellow ochre",0.25},{"raw sienna",0.05}}
local IVD = pile{{"yellow ochre",1},{"lead white",0.8},{"bone brown",0.25}}
local GA = 2.39996
local n = 0
for _,B in ipairs(BEDS) do
  local hgt = math.max(4, B.h*2.6)
  local cnt = math.max(1, math.floor(B.w / 60))
  for c=1,cnt do
    if math.random() < 0.75 then
      local x = 500 - B.w + rand(0.1, 1.9)*B.w
      if math.abs(x - 500) > 8 + 0.08*hw(B.y) then
        local yy = B.up and (B.y - hgt*rand(0.7, 1.05)) or (B.y + B.h*0.3 + hgt*rand(0.7, 1.05))
        local r = math.max(2, B.h*0.55)
        -- stalk
        local sb = brush{kind="round", width=math.max(0.6, r*0.12), point=0.6}
        sb:reload(IVD, 0.7); sb:stroke({{x, B.y}, {x + rand(-1,1), yy}}, {pressure={0.4,0.3}})
        fill(ellipse(x, yy, r, r*0.8), IVD, (r > 6) and "round 2" or "round 1")
        local db = brush{kind="round", width=math.max(0.6, r*0.18), point=0.4}
        local m = math.floor(math.min(34, r*2.2))
        for j=1,m do
          local rr = r*0.92*math.sqrt(j/m)
          local a = j*GA
          db:reload(IV, 0.7); db:touch(x + rr*math.cos(a), yy + rr*math.sin(a)*0.8, {pressure=0.35})
        end
        n = n + 1
      end
    end
  end
end
print(n)

--@ chunk 11
FLW = {{409.4,159.9,12.5},{426.9,211.0,11.5},{527.9,242.2,10.0},{544.1,264.6,8.8},{536.8,281.6,7.3},{562.0,341.5,9.4},{680.8,453.0,13.8}}
print(wait(24*60))
local GA = 2.39996
local IV = pile{{"lead white",2},{"yellow ochre",0.15},{"zinc white",0.3}}
local IVS = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.1}}
local SEED = pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.3}}
for _,f in ipairs(FLW) do
  local x, y, r = f[1], f[2], f[3] + 1
  local disc = ellipse(x, y, r, r*0.85)
  work(disc, {hand="detail", tool={kind="round", width=1.4}, pile=IVS, coverage=4.5, fill=true, clip=disc})
  local lit = disc * ellipse(x - r*0.15, y - r*0.15, r*0.8, r*0.65)
  work(lit, {hand="detail", tool={kind="round", width=1.2}, pile=IV, coverage=4.5, fill=true, clip=lit})
  local db = brush{kind="round", width=math.max(0.7, r*0.14), point=0.4}
  local m = math.floor(math.min(40, r*2.6))
  for j=1,m do
    local rr = r*0.85*math.sqrt(j/m)
    local a = j*GA
    db:reload(SEED, 0.75); db:touch(x + rr*math.cos(a), y + rr*math.sin(a)*0.85, {pressure=0.35})
  end
  -- a ring of thin pale petals round the head
  local pb = brush{kind="round", width=math.max(0.6, r*0.12), point=0.7}
  for k=0,12 do
    local a = k*2*math.pi/13
    pb:reload(IV, 0.6)
    pb:stroke({{x + r*0.95*math.cos(a), y + r*0.8*math.sin(a)}, {x + r*1.45*math.cos(a), y + r*1.2*math.sin(a)}}, {pressure={0.4,0.05}})
  end
end

--@ chunk 12
FLW = {{346.8,75.3,11.2},{605.9,94.7,10.9},{568.2,119.6,10.5},{617.2,407.0,9.0},{566.9,442.3,10.1},{409.3,457.3,10.1},{408.9,484.2,10.9},{451.5,492.8,10.9},{327.5,502.9,10.9},{104.3,533.3,12.0},{788.5,540.1,11.6},{396.8,546.9,12.0},{406.0,85.0,10.0},{432.0,82.0,10.0}}
print(wait(24*60))
local GA = 2.39996
local IV = pile{{"lead white",2},{"yellow ochre",0.15},{"zinc white",0.3}}
local IVS = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.1}}
local SEED = pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.3}}
for _,f in ipairs(FLW) do
  local x, y, r = f[1], f[2], f[3] + 1
  local disc = ellipse(x, y, r, r*0.85)
  work(disc, {hand="detail", tool={kind="round", width=1.4}, pile=IVS, coverage=4.5, fill=true, clip=disc})
  local lit = disc * ellipse(x - r*0.15, y - r*0.15, r*0.8, r*0.65)
  work(lit, {hand="detail", tool={kind="round", width=1.2}, pile=IV, coverage=4.5, fill=true, clip=lit})
  local db = brush{kind="round", width=math.max(0.7, r*0.14), point=0.4}
  local m = math.floor(math.min(40, r*2.6))
  for j=1,m do
    local rr = r*0.85*math.sqrt(j/m)
    local a = j*GA
    db:reload(SEED, 0.75); db:touch(x + rr*math.cos(a), y + rr*math.sin(a)*0.85, {pressure=0.35})
  end
  -- a ring of thin pale petals round the head
  local pb = brush{kind="round", width=math.max(0.6, r*0.12), point=0.7}
  for k=0,12 do
    local a = k*2*math.pi/13
    pb:reload(IV, 0.6)
    pb:stroke({{x + r*0.95*math.cos(a), y + r*0.8*math.sin(a)}, {x + r*1.45*math.cos(a), y + r*1.2*math.sin(a)}}, {pressure={0.4,0.05}})
  end
end

--@ chunk 13
print(wait(24*60))
local function fill(m, p, t) if m:area() > 0.2 then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end end
-- the seven crew badges, hung in a row on the wall above the viewport, each on a short cord from a pin
local CARD = pile{{"lead white",1.6},{"ultramarine ash",0.3},{"yellow ochre",0.1}}
local BLU = pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.2}}
local PH = {pile{{"bone brown",1},{"red earth",0.4},{"lead white",0.4}}, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"lead white",0.4}}, pile{{"bone brown",1},{"bone black",0.3},{"lead white",0.4}}}
local cord = brush{kind="round", width=1, point=0.6}
local pin = brush{kind="round", width=3, point=0.2}
for i=0,6 do
  local x = 66 + i*35
  local y = 96 + ((i % 2 == 0) and 0 or 2)
  pin:reload(pile{{"cadmium red",1},{"lead white",0.2}}, 0.9); pin:touch(x, y - 14, {pressure=0.55})
  cord:reload(pile{{"bone black",1.2},{"ultramarine blue",0.3}}, 0.8); cord:stroke({{x, y - 14}, {x - 5, y - 6}}, {pressure={0.4,0.4}}); cord:stroke({{x, y - 14}, {x + 5, y - 6}}, {pressure={0.4,0.4}})
  local c = poly({{x - 11, y - 6}, {x + 11, y - 6}, {x + 11, y + 24}, {x - 11, y + 24}})
  fill(c, CARD, "round 1.4")
  fill(rect(x - 8, y - 2, 9, 11), PH[(i % 3) + 1], "round 1")
  fill(ellipse(x + 5, y + 1, 3.2, 3), BLU, "round 1")
  fill(rect(x - 8, y + 13, 16, 2.5), pile{{"bone black",1.2},{"ultramarine ash",0.3}}, "round 1")
  fill(rect(x - 8, y + 18, 11, 2), pile{{"bone black",1},{"ultramarine ash",0.4},{"lead white",0.3}}, "round 1")
  local sh = brush{kind="round", width=1.6, point=0.4}
  sh:reload(pile{{"bone black",0.8},{"ultramarine ash",0.6},{"rose madder",0.1}}, 0.6); sh:stroke({{x + 12, y - 4}, {x + 12.5, y + 25}, {x - 9, y + 25.5}}, {pressure={0.4,0.4}})
end
-- the placard on the right wall, now covered in children's drawings
local PAP = pile{{"lead white",2},{"yellow ochre",0.06}}
fill(poly({{764,304},{826,297},{828,341},{766,348}}), PAP, "round 2")
local cr = brush{kind="round", width=2.2, point=0.3}
local function c(p, pts, pr) cr:reload(p, 0.85); cr:stroke(pts, {pressure={pr or 0.5, pr or 0.45}, shake=1.2}) end
local YEL = pile{{"cadmium yellow",1},{"lemon chrome",0.4}}
c(YEL, {{772,310},{778,306},{783,311},{777,316},{772,310}})
for _,a in ipairs({0, 1.2, 2.4, 3.6, 4.8}) do c(YEL, {{777 + 7*math.cos(a), 311 + 7*math.sin(a)}, {777 + 11*math.cos(a), 311 + 11*math.sin(a)}}, 0.35) end
c(pile{{"viridian",1},{"cadmium yellow",0.3}}, {{770,340},{790,338},{822,334}}, 0.45)
c(pile{{"bone black",1}}, {{796,322},{796,334}}, 0.4); c(pile{{"bone black",1}}, {{791,327},{801,327}}, 0.35)
c(pile{{"cadmium red",1}}, {{794,316},{798,316},{798,320},{794,320},{794,316}}, 0.4)
c(pile{{"bone black",1}}, {{810,326},{810,334}}, 0.4); c(pile{{"cadmium red",1}}, {{808,320},{812,321}}, 0.4)
local fl = brush{kind="round", width=1.4, point=0.3}
for j=1,12 do local r = 4*math.sqrt(j/12); local a = j*2.39996; fl:reload(pile{{"lead white",1},{"yellow ochre",0.6},{"bone brown",0.2}}, 0.8); fl:touch(818 + r*math.cos(a), 312 + r*math.sin(a), {pressure=0.35}) end
-- the work cart, a child's small coverall hung over its handle
local CART = pile{{"lead white",1},{"bone black",0.8},{"ultramarine ash",1}}
local CARTD = pile{{"bone black",1.8},{"ultramarine ash",0.5}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1},{"bone black",0.08}}
fill(rect(250, 540, 90, 40), CART, "round 2")
fill(rect(250, 552, 90, 5), AMB)
fill(rect(254, 578, 82, 6), CARTD)
fill(ellipse(262, 590, 6, 6) + ellipse(328, 590, 6, 6), CARTD)
local hb = brush{kind="round", width=2.5, point=0.2}
hb:reload(CARTD, 0.9); hb:stroke({{340, 545}, {356, 520}, {366, 520}}, {pressure={0.8,0.8}})
fill(rect(256, 528, 78, 12), pile{{"bone brown",1},{"bone black",0.4}})
local sd = brush{kind="filbert", width=3}
for i=1,22 do
  local x, y = rand(258, 332), rand(522, 532)
  sd:reload((i%3==0) and pile{{"cadmium yellow",1},{"viridian",0.3},{"lead white",0.9}} or pile{{"viridian",0.6},{"cadmium yellow",1},{"yellow ochre",0.2}}, 0.8)
  sd:stroke({{x, y}, {x + rand(-3,3), y - rand(4,8)}}, {pressure={0.6,0.1}})
end
local CV = pile{{"cobalt blue",1},{"ultramarine blue",0.4},{"lead white",0.35}}
local CVD = pile{{"ultramarine blue",1},{"bone black",0.5}}
local cov = poly({{352,522},{368,522},{372,532},{370,552},{366,568},{361,568},{360,553},{358,553},{357,568},{352,568},{350,552},{348,532}}, true)
fill(cov, CV, "round 1.4")
fill(cov * rect(361, 520, 20, 60), CVD, "round 1")
fill(rect(349, 545, 23, 2.5), pile{{"lead white",1.6},{"ultramarine ash",0.4}}, "round 1")
fill(rect(351, 528, 5, 4), pile{{"chrome yellow",1},{"Mars orange",0.4}}, "round 1")
-- the yellow watering can, upright, by the beds
local CAN = pile{{"chrome yellow",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local CAND = pile{{"Mars orange",1},{"bone brown",0.6}}
fill(rect(672, 548, 18, 20), CAN)
fill(rect(686, 548, 4, 20), CAND)
local cb = brush{kind="round", width=2.4, point=0.3}
cb:reload(CAN, 0.9); cb:stroke({{672, 562}, {658, 548}, {654, 546}}, {pressure={0.7,0.6}})
cb:reload(CAN, 0.9); cb:stroke({{674, 548}, {681, 538}, {688, 548}}, {pressure={0.6,0.6}})

--@ chunk 14
print(wait(24*60))
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.15}}
local ROD = pile{{"bone black",1.5},{"ultramarine ash",0.6}}
local LL = {{x0=300, x1=700, y=470, hh=10, lh=7, down=false}, {x0=438, x1=562, y=362, hh=5, lh=4, down=false}, {x0=414, x1=586, y=158, hh=6, lh=5, down=true}}
for _,Lm in ipairs(LL) do
  local w = Lm.x1 - Lm.x0
  local hs = Lm.down and rect(Lm.x0, Lm.y + Lm.lh, w, Lm.hh) or rect(Lm.x0, Lm.y - Lm.hh - Lm.lh, w, Lm.hh)
  hs = hs - CHAN
  work(hs, {hand="detail", tool="round 1.4", pile=HOUS, coverage=4.5, fill=true, clip=hs, angle=0})
  local r = brush{kind="round", width=math.max(1.2, Lm.hh*0.2), point=0.3}
  for _,x in ipairs({Lm.x0 + w*0.12, Lm.x1 - w*0.12}) do
    r:reload(ROD, 0.9)
    if Lm.down then r:stroke({{x, Lm.y + Lm.lh + Lm.hh}, {x + (500-x)*0.1, Lm.y + Lm.lh + Lm.hh + 45}}, {pressure={0.7,0.7}})
    else r:stroke({{x, Lm.y - Lm.lh - Lm.hh}, {x + (500-x)*0.1, Lm.y - Lm.lh - Lm.hh - math.min(55, w*0.4)}}, {pressure={0.7,0.7}}) end
  end
  local e = brush{kind="round", width=1.2, point=0.5}
  local yy = Lm.down and (Lm.y + Lm.lh + Lm.hh) or (Lm.y - Lm.lh - Lm.hh)
  e:reload(pile{{"lead white",1.4},{"magenta",0.2}}, 0.7); e:stroke({{Lm.x0 + 2, yy}, {Lm.x1 - 2, yy}}, {pressure={0.4,0.4}, clip=rect(0,0,1000,H) - CHAN})
end

--@ chunk 15
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.15}}
local LENS = pile{{"zinc white",1.5},{"magenta",1},{"lead white",0.5},{"cobalt violet",0.2}}
local LL = {{x0=300, x1=700, y=470, hh=10, lh=7, down=false}, {x0=438, x1=562, y=362, hh=5, lh=4, down=false}, {x0=414, x1=586, y=158, hh=6, lh=5, down=true}}
for _,Lm in ipairs(LL) do
  local w = Lm.x1 - Lm.x0
  local hs = Lm.down and rect(Lm.x0, Lm.y + Lm.lh, w, Lm.hh) or rect(Lm.x0, Lm.y - Lm.hh - Lm.lh, w, Lm.hh)
  local ln = Lm.down and rect(Lm.x0 + 2, Lm.y, w - 4, Lm.lh) or rect(Lm.x0 + 2, Lm.y - Lm.lh, w - 4, Lm.lh)
  local c = CHAN:grow(1)
  work(hs * c, {hand="detail", tool="round 1.4", pile=HOUS, coverage=4.5, fill=true, clip=hs * c, angle=0})
  work(ln * c, {hand="detail", tool="round 1.4", pile=LENS, coverage=4.5, fill=true, clip=ln * c, angle=0})
end
