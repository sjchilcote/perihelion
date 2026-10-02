-- easel session "hydro_green": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=37,
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
-- glints of water in the trays
local WET = pile{{"zinc white",2},{"cerulean blue",0.4},{"rose madder",0.1}}
local wb = brush{kind="round", width=0.8, point=0.6}
for _,B in ipairs(BEDS) do
  for i=1,math.floor(B.w/25) do
    local x = 500 - B.w + rand(0, 2*B.w)
    local L = rand(3, 10) * math.max(0.4, B.h/10)
    wb:reload(WET, 0.6); wb:stroke({{x, B.y + rand(-0.3,0.3)*B.h}, {x+L, B.y + rand(-0.3,0.3)*B.h}}, {pressure={0.4,0.1}})
  end
end
-- the crop: leafy plants in every bed, growing toward the ring's axis
local GD = pile{{"viridian",1},{"bone black",0.5},{"bone brown",0.3}}
local GM = pile{{"viridian",0.6},{"cadmium yellow",1},{"bone black",0.2},{"yellow ochre",0.2}}
local GL = pile{{"cadmium yellow",1},{"viridian",0.4},{"lead white",0.8}}
local GP = pile{{"viridian",0.5},{"lead white",1},{"rose madder",0.25},{"cadmium yellow",0.4}}
local STEM = pile{{"viridian",0.6},{"yellow ochre",1},{"bone brown",0.3}}
local n = 0
for _,B in ipairs(BEDS) do
  local cnt = math.min(42, math.floor(B.w/5))
  local sgn = B.up and -1 or 1
  local L = math.max(3, B.h*2.6)
  local lw = math.max(0.8, math.min(6, B.h*0.45))
  local sb = brush{kind="round", width=math.max(0.5, lw*0.25), point=0.8}
  local lb = brush{kind="filbert", width=lw}
  for i=1,cnt do
    local x = 500 - B.w + (i-0.5)*(2*B.w/cnt) + rand(-0.4,0.4)*B.w/cnt
    local y0 = B.y + rand(-0.3,0.3)*B.h
    local Ls = L*rand(0.7,1.2)
    local tx, ty = x + rand(-0.15,0.15)*Ls, y0 + sgn*Ls
    sb:reload(STEM, 0.7); sb:stroke({{x,y0},{(x+tx)/2, (y0+ty)/2},{tx,ty}}, {pressure={0.5,0.2}})
    for j=1,4 do
      local f = rand(0.35, 1.0)
      local px, py = x + (tx-x)*f + rand(-0.3,0.3)*lw, y0 + (ty-y0)*f
      local ang = (j%2==0) and rand(0.3,0.9) or rand(2.2,2.8)
      if sgn > 0 then ang = -ang end
      local r = rand(0,1)
      local p = (j==1) and GD or ((r < 0.45) and GM or ((r < 0.8) and GL or GP))
      if f < 0.5 and j > 1 then p = GD end
      lb:reload(p, 0.8)
      local dl = lw*rand(1.2,2.0)
      lb:stroke({{px,py},{px + math.cos(ang)*dl, py - math.sin(ang)*dl*(-sgn)}}, {pressure={0.6,0.1}, ramps={0.1,0.6}})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 4
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

--@ chunk 5
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

--@ chunk 6
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

--@ chunk 7
print(wait(24*60))
-- the grow-lamps, blazing: two over our floor, one over the floor overhead
local HOUS = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.25}}
local LENS = pile{{"zinc white",2},{"lead white",1},{"magenta",0.35},{"cobalt violet",0.2}}
local LENSH = pile{{"zinc white",3},{"magenta",0.08}}
local HALO = pile{{"lead white",2},{"zinc white",1},{"magenta",0.4},{"cobalt violet",0.2},medium=0.65}
local ROD = pile{{"bone black",1.5},{"ultramarine ash",0.6}}
LAMPS = {{x0=305, x1=695, y=482, h=9, down=false}, {x0=440, x1=560, y=367, h=5, down=false}, {x0=420, x1=580, y=168, h=6, down=true}}
for _,Lm in ipairs(LAMPS) do
  local w = Lm.x1 - Lm.x0
  -- light poured on the crop below (or above, for the overhead lamp): a pink-white glaze
  local g = Lm.down and poly({{Lm.x0, Lm.y}, {Lm.x1, Lm.y}, {Lm.x1 + w*0.12, Lm.y - 70}, {Lm.x0 - w*0.12, Lm.y - 70}}, true)
                     or poly({{Lm.x0, Lm.y}, {Lm.x1, Lm.y}, {Lm.x1 + w*0.15, Lm.y + 90}, {Lm.x0 - w*0.15, Lm.y + 90}}, true)
  g = g:soften(8) * BAND
  work(g, {hand="glaze", tool={kind="filbert", width=8}, pile=HALO, load=0.2, pressure={0.08,0.2}, coverage=1.0, clip=g, angle=1.5708})
  local hs = rect(Lm.x0, Lm.y - Lm.h, w, Lm.h)
  local ln = Lm.down and rect(Lm.x0 + 2, Lm.y - Lm.h - Lm.h*0.45, w - 4, Lm.h*0.45) or rect(Lm.x0 + 2, Lm.y, w - 4, Lm.h*0.45)
  work(hs, {hand="detail", tool="round 2", pile=HOUS, coverage=4, fill=true, clip=true, angle=0})
  work(ln, {hand="detail", tool="round 1.4", pile=LENS, coverage=4, fill=true, clip=true, angle=0})
  local r = brush{kind="round", width=math.max(1, Lm.h*0.12), point=0.3}
  for _,x in ipairs({Lm.x0 + w*0.1, Lm.x1 - w*0.1}) do
    r:reload(ROD, 0.8)
    local ty = Lm.down and (Lm.y + 50) or (Lm.y - 60)
    r:stroke({{x, Lm.down and Lm.y or (Lm.y - Lm.h)}, {x + (500 - x)*0.15, ty}}, {pressure={0.6,0.6}})
  end
end
-- mist from the irrigation: thin pale veils drifting over the beds near the waist
local MIST = pile{{"lead white",2},{"rose madder",0.1},{"cerulean blue",0.1},medium=0.7}
local mist = (ellipse(500, 300, 120, 70):soften(25) + ellipse(470, 430, 160, 30):soften(20)) * BAND
work(mist, {hand="glaze", tool={kind="filbert", width=10}, pile=MIST, load=0.18, pressure={0.06,0.16}, coverage=0.8, clip=mist, angle=0.1})
print(wait(24*60))
for _,Lm in ipairs(LAMPS) do
  local hl = brush{kind="round", width=math.max(0.8, Lm.h*0.15), point=0.5}
  hl:reload(LENSH, 0.8)
  local yy = Lm.down and (Lm.y - Lm.h - Lm.h*0.22) or (Lm.y + Lm.h*0.22)
  hl:stroke({{Lm.x0 + 6, yy}, {Lm.x1 - 6, yy}}, {pressure={0.45,0.45}})
end

--@ chunk 8
-- make the lamps blaze: a pink-violet bloom round each, heavier housings, hot lenses
local HAL = pile{{"lead white",1},{"magenta",0.3},{"cobalt violet",0.15},{"zinc white",0.3}}
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.15}}
local LENS2 = pile{{"zinc white",2},{"lead white",1},{"magenta",0.5},{"cobalt violet",0.15}}
local L2 = {{x0=300, x1=700, y=478, h=14, down=false}, {x0=436, x1=564, y=365, h=7, down=false}, {x0=414, x1=586, y=170, h=9, down=true}}
for _,Lm in ipairs(L2) do
  local w = Lm.x1 - Lm.x0
  local cy = Lm.down and (Lm.y - Lm.h*1.6) or (Lm.y + Lm.h*0.6)
  local halo = ellipse((Lm.x0+Lm.x1)/2, cy, w*0.58, Lm.h*2.6)
  work(halo, {hand="body", tool={kind="filbert", width=math.max(3, Lm.h*0.5)}, pile=HAL, coverage=1.6, fill=true, angle=0, clip=halo, edge="lost", load=0.6})
  local hs = Lm.down and rect(Lm.x0, Lm.y - Lm.h, w, Lm.h*0.55) or rect(Lm.x0, Lm.y - Lm.h, w, Lm.h*0.6)
  local ln = Lm.down and rect(Lm.x0 + 3, Lm.y - Lm.h*0.45, w - 6, Lm.h*0.45) or rect(Lm.x0 + 3, Lm.y - Lm.h*0.4, w - 6, Lm.h*0.45)
  work(hs, {hand="detail", tool="round 2", pile=HOUS, coverage=4.5, fill=true, clip=true, angle=0})
  work(ln, {hand="detail", tool="round 1.4", pile=LENS2, coverage=4.5, fill=true, clip=true, angle=0})
end
L2G = L2

--@ chunk 9
-- the blooms went on as solid pink lozenges: drag them out thin with the badger
for _,Lm in ipairs(L2G) do
  local w = Lm.x1 - Lm.x0
  local cy = Lm.down and (Lm.y - Lm.h*1.6) or (Lm.y + Lm.h*0.6)
  local hs = rect(Lm.x0 - 2, Lm.y - Lm.h - 2, w + 4, Lm.h + 4)
  local zone = ellipse((Lm.x0+Lm.x1)/2, cy, w*0.58 + 18, Lm.h*2.6 + 14) - hs
  blend(zone, {angle=0, tool={kind="badger", width=math.max(6, Lm.h)}})
  blend(zone, {angle=1.5708, tool={kind="badger", width=math.max(6, Lm.h)}})
  blend(zone, {angle=0.6, tool={kind="badger", width=math.max(6, Lm.h)}})
end

--@ chunk 10
print(wait(2*24*60))
-- paint the pink lozenges out: wall, crop and tray lips laid again inside them
local Z
for _,Lm in ipairs(L2G) do
  local w = Lm.x1 - Lm.x0
  local cy = Lm.down and (Lm.y - Lm.h*1.6) or (Lm.y + Lm.h*0.6)
  local e = ellipse((Lm.x0+Lm.x1)/2, cy, w*0.58 + 24, Lm.h*2.6 + 20)
  Z = Z and (Z + e) or e
end
ZONE = Z
local WLa = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.8},{"rose madder",0.2},{"yellow ochre",0.15}}
local wz = Z * (LWALL + RWALL) - HZ:grow(1)
work(wz, {hand="body", tool="filbert 6", pile=WLa, coverage=3.5, fill=true, clip=wz, angle=1.5708})
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1},{"bone black",0.08}}
work(HZ * Z, {hand="detail", tool="round 2", pile=AMB, coverage=4, fill=true, clip=HZ * Z})
local bz = Z * BAND - HZ:grow(1)
local GD = pile{{"viridian",1},{"bone black",0.45},{"bone brown",0.3},{"cadmium yellow",0.2}}
work(bz, {hand="body", tool="filbert 5", pile=GD, coverage=3.5, fill=true, clip=bz, angle=1.5708, length={8,25}})
print(wait(24*60))
local GL = pile{{"cadmium yellow",1},{"viridian",0.3},{"lead white",1.0}}
local GM = pile{{"viridian",0.5},{"cadmium yellow",1},{"lead white",0.2},{"yellow ochre",0.2}}
local GP = pile{{"viridian",0.25},{"lead white",1.5},{"rose madder",0.4},{"magenta",0.1},{"cadmium yellow",0.25}}
local TRAY = pile{{"lead white",1.5},{"bone black",0.5},{"ultramarine ash",1},{"rose madder",0.12}}
for _,B in ipairs(BEDS) do
  local lipH = math.max(1.5, B.h*0.35)
  local lip = (B.up and rect(500-B.w, B.y+B.h/2, 2*B.w, lipH) or rect(500-B.w, B.y-B.h/2-lipH, 2*B.w, lipH)) * bz
  if lip:area() > 1 then work(lip, {hand="detail", tool=(B.h > 8) and "round 3" or "round 1.4", pile=TRAY, coverage=4, fill=true, clip=lip, angle=0}) end
  local tw = math.max(1.0, math.min(6, B.h*0.45))
  local lb = brush{kind="filbert", width=tw}
  local hgt = math.max(4, B.h*2.6)
  for k=1,math.min(90, math.floor(B.w/2)) do
    local x = 500 - B.w + rand(0, 2*B.w)
    local y = B.up and (B.y - hgt*rand(0.2, 1.0)) or (B.y + B.h*0.3 + hgt*rand(0.2, 1.0))
    if bz:at(x, y) > 0.5 then
      local ang = rand(-0.9, 0.9) + (B.up and -1.5708 or 1.5708)
      local r = rand(0,1)
      local p = (r < 0.35) and GM or ((r < 0.6) and GL or GP)
      local dl = tw*rand(1.2, 2.2)
      lb:reload(p, 0.75)
      lb:stroke({{x,y},{x + math.cos(ang)*dl, y + math.sin(ang)*dl}}, {pressure={0.55,0.1}, ramps={0.1,0.6}})
    end
  end
end
-- the fixtures, crisp, over it all
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.15}}
local LENS2 = pile{{"zinc white",2},{"lead white",1},{"magenta",0.5},{"cobalt violet",0.15}}
for _,Lm in ipairs(L2G) do
  local w = Lm.x1 - Lm.x0
  local hs = Lm.down and rect(Lm.x0, Lm.y - Lm.h, w, Lm.h*0.55) or rect(Lm.x0, Lm.y - Lm.h, w, Lm.h*0.6)
  local ln = Lm.down and rect(Lm.x0 + 3, Lm.y - Lm.h*0.45, w - 6, Lm.h*0.45) or rect(Lm.x0 + 3, Lm.y - Lm.h*0.4, w - 6, Lm.h*0.45)
  work(hs, {hand="detail", tool="round 2", pile=HOUS, coverage=4.5, fill=true, clip=true, angle=0})
  work(ln, {hand="detail", tool="round 1.4", pile=LENS2, coverage=4.5, fill=true, clip=true, angle=0})
end

--@ chunk 11
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
-- signs of life: a work cart with a seedling flat, gloves on a tray lip, the watering can upright
local CART = pile{{"lead white",1},{"bone black",0.8},{"ultramarine ash",1}}
local CARTD = pile{{"bone black",1.8},{"ultramarine ash",0.5}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1},{"bone black",0.08}}
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end
fill(rect(250, 540, 90, 40), CART, "round 2")
fill(rect(250, 552, 90, 5), AMB)
fill(rect(254, 578, 82, 6), CARTD)
fill(ellipse(262, 590, 6, 6) + ellipse(328, 590, 6, 6), CARTD)
local hb = brush{kind="round", width=2.5, point=0.2}
hb:reload(CARTD, 0.9); hb:stroke({{340, 545}, {356, 520}, {362, 520}}, {pressure={0.8,0.8}})
fill(rect(256, 528, 78, 12), pile{{"bone brown",1},{"bone black",0.4}})
local sd = brush{kind="filbert", width=3}
for i=1,22 do
  local x, y = rand(258, 332), rand(522, 532)
  sd:reload((i%3==0) and pile{{"cadmium yellow",1},{"viridian",0.3},{"lead white",0.9}} or pile{{"viridian",0.6},{"cadmium yellow",1},{"yellow ochre",0.2}}, 0.8)
  sd:stroke({{x, y}, {x + rand(-3,3), y - rand(4,8)}}, {pressure={0.6,0.1}})
end
local GLV = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.3}}
fill(poly({{590,566},{604,563},{608,572},{602,584},{594,583}}, true), GLV)
fill(poly({{612,565},{624,567},{622,580},{616,586},{610,578}}, true), GLV)
local gb = brush{kind="round", width=1.3, point=0.5}
for _,f in ipairs({{596,583,593,590},{599,584,598,592},{602,583,603,590},{614,585,612,592},{618,585,619,593}}) do gb:reload(GLV, 0.7); gb:stroke({{f[1],f[2]},{f[3],f[4]}}, {pressure={0.5,0.3}}) end
local CAN = pile{{"chrome yellow",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local CAND = pile{{"Mars orange",1},{"bone brown",0.6}}
fill(rect(672, 548, 18, 20), CAN)
fill(rect(686, 548, 4, 20), CAND)
local cb = brush{kind="round", width=2.4, point=0.3}
cb:reload(CAN, 0.9); cb:stroke({{672, 562}, {658, 548}, {654, 546}}, {pressure={0.7,0.6}})
cb:reload(CAN, 0.9); cb:stroke({{674, 548}, {681, 538}, {688, 548}}, {pressure={0.6,0.6}})
fill(rect(670, 46, 14, 14), CAN)
cb:reload(CAN, 0.8); cb:stroke({{670, 50}, {660, 60}, {657, 62}}, {pressure={0.5,0.5}})
cb:reload(CAN, 0.8); cb:stroke({{671, 60}, {677, 67}, {683, 60}}, {pressure={0.5,0.5}})
-- a placard on the right wall
local PLC = pile{{"lead white",2},{"bone black",0.2},{"ultramarine ash",0.3}}
fill(poly({{760,300},{830,292},{832,345},{762,352}}), AMB, "round 2")
fill(poly({{764,304},{826,297},{828,341},{766,348}}), PLC, "round 2")
local tb = brush{kind="round", width=1.2, point=0.3}
for i=0,4 do
  local y = 308 + i*7.5
  tb:reload(pile{{"bone black",2}}, 0.8); tb:stroke({{770, y - i*0.1}, {770 + ((i==0) and 50 or rand(25,48)), y - 0.8 - i*0.1}}, {pressure={(i==0) and 0.9 or 0.5, 0.5}})
end

--@ chunk 12
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

--@ chunk 13
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
