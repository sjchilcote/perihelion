-- easel session "mat_grate": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen=16, seed=4242,
  ground={{pile={{"lead white",2},{"bone black",0.5},{"raw sienna",0.3},{"ultramarine blue",0.15}}, um=60, apply="knife", texture=0.3}}}
-- 4x4 load panels of 250; grates at a fixed irregular set, all inside canvas
PAN = {}
local grates = {["0,1"]=1, ["1,3"]=1, ["2,0"]=1, ["3,2"]=1, ["2,2"]=1, ["0,3"]=0}
for j=0,3 do for i=0,3 do
  PAN[#PAN+1] = {i=i, j=j, x=i*250, y=j*250, grate=(grates[i..","..j]==1)}
end end

--@ chunk 2
G = {
  pile{{"lead white",2},{"bone black",0.55},{"yellow ochre",0.3},{"ultramarine blue",0.15},{"viridian",0.08}},
  pile{{"lead white",2.4},{"bone black",0.5},{"cerulean blue",0.2},{"raw sienna",0.2}},
  pile{{"lead white",1.6},{"bone black",0.6},{"raw sienna",0.4},{"viridian",0.12}},
}
PIT = pile{{"bone black",1},{"ultramarine blue",0.6},{"burnt sienna",0.4},{"lead white",0.5}}
local grp = {nil,nil,nil}
local gm = nil
for _,P in ipairs(PAN) do
  if P.grate then
    local r = rect(P.x+7, P.y+7, 236, 236); gm = gm and (gm+r) or r
  else
    for a=0,1 do for b=0,1 do
      local t = math.random(1,3)
      local r = rect(P.x+a*125+2.5, P.y+b*125+2.5, 120, 120)
      grp[t] = grp[t] and (grp[t]+r) or r
    end end
  end
end
GRM = gm
for t=1,3 do work(grp[t], {hand="body", tool="filbert 12", pile=G[t], coverage=3, fill=true, clip=true, length={40,110}, angle=math.pi/2, angle_jitter=0.12}) end
work(gm, {hand="body", tool="filbert 12", pile=PIT, coverage=3, fill=true, clip=true, length={40,110}, angle=0})

--@ chunk 3
print(wait(360))
G = {
  pile{{"lead white",1},{"bone black",0.8},{"yellow ochre",0.25},{"ultramarine blue",0.1},{"viridian",0.08}},
  pile{{"lead white",1.1},{"bone black",0.75},{"cerulean blue",0.2},{"raw sienna",0.15}},
  pile{{"lead white",0.9},{"bone black",0.8},{"raw sienna",0.35},{"viridian",0.12}},
}
PIT = pile{{"bone black",1},{"burnt sienna",0.35},{"ultramarine blue",0.15},{"lead white",0.35}}
local grp = {nil,nil,nil}
for _,P in ipairs(PAN) do
  if not P.grate then
    for a=0,1 do for b=0,1 do
      local t = math.random(1,3)
      local r = rect(P.x+a*125+2.5, P.y+b*125+2.5, 120, 120)
      grp[t] = grp[t] and (grp[t]+r) or r
    end end
  end
end
for t=1,3 do work(grp[t], {hand="body", tool="filbert 12", pile=G[t], coverage=3, fill=true, clip=true, length={40,110}, angle=math.pi/2, angle_jitter=0.12}) end
work(GRM, {hand="body", tool="filbert 12", pile=PIT, coverage=3, fill=true, clip=true, length={40,110}, angle=0})

--@ chunk 4
print(wait(1440))
SEAM = pile{{"bone black",1},{"burnt sienna",0.3},{"lead white",0.45},{"ultramarine blue",0.1}}
STEEL = pile{{"lead white",0.9},{"bone black",0.8},{"ultramarine blue",0.12},{"raw sienna",0.15}}
-- frames around grates: steel
local fr = nil
for _,P in ipairs(PAN) do if P.grate then local f = rect(P.x+2.5,P.y+2.5,245,245) - rect(P.x+9,P.y+9,232,232); fr = fr and (fr+f) or f end end
work(fr, {hand="body", tool="flat 5", pile=STEEL, coverage=3, fill=true, clip=true, length={30,90}, angle=function(x,y) local u=(x%250); return (u<12 or u>238) and math.pi/2 or 0 end})
-- bearing bars (vertical) and cross rods
local bars = nil
for _,P in ipairs(PAN) do if P.grate then
  for k=1,15 do local x = P.x + k*15.625; local b = rect(x-2.6, P.y+9, 5.2, 232); bars = bars and (bars+b) or b end
end end
work(bars, {hand="body", tool="flat 5", pile=STEEL, coverage=2.5, fill=true, clip=true, length={60,120}, angle=math.pi/2, ruler=true})
local rods = nil
for _,P in ipairs(PAN) do if P.grate then
  for k=1,7 do local y = P.y + k*31.25; local b = rect(P.x+9, y-1.6, 232, 3.2); rods = rods and (rods+b) or b end
end end
work(rods, {hand="body", tool="flat 3", pile=STEEL, coverage=2, fill=true, clip=true, length={40,100}, angle=0, ruler=true})
-- seams between solid plates, on the 125 grid (wrap: lines on 0 and 1000 halves)
local sm = nil
for k=0,8 do
  local a = rect(k*125-2.5, -5, 5, 1010); local b = rect(-5, k*125-2.5, 1010, 5)
  sm = sm and (sm+a+b) or (a+b)
end
sm = sm - GRM:grow(0)
work(sm, {hand="detail", pile=SEAM, coverage=3, fill=true, clip=true})

--@ chunk 5
print(wait(1440))
AMBER = pile{{"cadmium yellow",1},{"yellow ochre",1},{"Mars orange",0.3},{"lead white",0.3},{"bone black",0.08}}
STW = pile{{"lead white",2},{"bone black",0.25},{"yellow ochre",0.1}}
RUB = pile{{"bone black",1},{"burnt sienna",0.4},{"lead white",0.25}}
-- amber load-zone corner brackets in panel (1,1)
local am = brush("flat", 7)
local function seg(b, p, x1,y1,x2,y2) b:load(p, 0.45); b:stroke({{x1,y1},{x2,y2}}, {pressure={0.6,0.45}, shake=0.6}) end
local x0,y0,x1,y1 = 270,270,480,480
for _,c in ipairs({{x0,y0,1,1},{x1,y0,-1,1},{x0,y1,1,-1},{x1,y1,-1,-1}}) do
  seg(am, AMBER, c[1], c[2], c[1]+c[3]*55, c[2]); seg(am, AMBER, c[1], c[2], c[1], c[2]+c[4]*55)
end
-- amber edge stripe beside the grate at (2,2): a worn line along x=520 from y=525..725
seg(am, AMBER, 513, 530, 513, 720)
-- stencil "07" in panel (2,1), small, worn
local st = brush("flat", 5)
local cx, cy = 600, 360
local o = {}
for k=0,12 do local a = k/12*2*math.pi; o[#o+1] = {cx-14 + 9*math.cos(a), cy + 16*math.sin(a)} end
for k=1,12,3 do st:load(STW, 0.5); st:stroke({o[k],o[k+1],o[k+2]}, {pressure={0.55,0.5}}) end
seg(st, STW, cx+4, cy-16, cx+24, cy-16); seg(st, STW, cx+24, cy-15, cx+11, cy+16)
-- tie-down rings at chosen interior intersections of solid plates
local RECESS = pile{{"bone black",1},{"burnt sienna",0.3},{"lead white",0.3}}
local ring = brush{kind="round", width=3.5, point=0.2}
local pts = {{375,125},{625,125},{125,500},{375,625},{625,875},{875,375},{250,375},{875,875},{125,875},{750,625}}
for _,q in ipairs(pts) do
  local d = brush("round", 13); d:load(RECESS, 0.8); d:touch(q[1]+rand(-1,1), q[2]+rand(-1,1), {pressure=0.8})
end

--@ chunk 6
print(wait(600))
local ring = brush{kind="round", width=3.2, point=0.2}
for _,q in ipairs({{375,125},{625,125},{375,625},{625,875},{875,375},{875,875},{125,875}}) do
  local r = 9; local o = {}
  local a0 = rand(0, 6.28)
  for k=0,10 do local a = a0 + k/10*5.6; o[#o+1] = {q[1] + r*math.cos(a), q[2] + r*math.sin(a)*0.8} end
  ring:load(STEEL, 0.7); ring:stroke(o, {pressure={0.6,0.5}})
end
-- tire scuffs and pallet drag marks, all running in y, spread evenly
local sc = brush("flat", 9)
local xs = uneven(46, 12, 988, 0.6, 0.3, 77)
for n,x in ipairs(xs) do
  sc:reload(RUB, rand(0.12,0.22))
  local y = rand(0, 1000); local L = rand(120, 320)
  local pts = {}
  for k=0,6 do pts[#pts+1] = {x + rand(-3,3) + k*rand(-1,1), y + k*L/6} end
  if y + L > 1000 then
    -- keep marks inside the tile: shift up so they don't cross the bottom edge
    for _,p in ipairs(pts) do p[2] = p[2] - (y + L - 990) end
  end
  sc:stroke(pts, {pressure={0.35,0.15}, ramps={0.1,0.4}, shake=1.2})
end
-- thin pallet drag scratches, pale
local dr = brush{kind="round", width=2, point=0.4}
for n=1,40 do
  local x = rand(15,985); local y = rand(15, 700); local L = rand(60, 250)
  dr:reload(STEEL, 0.25)
  dr:stroke({{x,y},{x+rand(-4,4), y+L}}, {pressure={0.4,0.1}})
end

--@ chunk 7
print(wait(1440))
TRACK = pile{{"lead white",0.8},{"bone black",0.85},{"raw sienna",0.25},{"ultramarine blue",0.08}}
local xs = uneven(46, 12, 988, 0.6, 0.3, 77)
local tm = nil
for _,x in ipairs(xs) do
  local y = rand(0, 700); local L = rand(200, 300)
  local r = rect(x-11, y, 22, L):roughen(4, 30, math.random(1,999))
  tm = tm and (tm + r) or r
end
tm = tm - GRM:grow(4)
work(tm, {hand="body", tool="filbert 10", pile=TRACK, coverage=1.6, load=0.45, pressure={0.3,0.6}, clip=true, length={60,160}, angle=math.pi/2, fill=false})
-- bigger tie-down rings
local RING = pile{{"lead white",1.3},{"bone black",0.7},{"ultramarine blue",0.1}}
local ring = brush{kind="round", width=5, point=0.15}
for _,q in ipairs({{375,125},{625,125},{375,625},{625,875},{875,375},{875,875},{125,875}}) do
  local o = {}; local a0 = rand(0,6.28)
  for k=0,12 do local a = a0 + k/12*5.8; o[#o+1] = {q[1] + 13*math.cos(a), q[2] + 10*math.sin(a)} end
  ring:load(RING, 0.8); ring:stroke(o, {pressure={0.75,0.65}})
end
-- a few fluid stains, well inside
local OIL = pile{{"bone black",1},{"burnt sienna",0.5},{"ultramarine blue",0.2}, medium=0.75}
local sm = nil
for _,s in ipairs({{180,600,40,28},{690,230,30,40},{420,840,46,30},{860,120,26,22}}) do
  local e = ellipse(s[1],s[2],s[3],s[4]):roughen(10,30,math.random(1,999)):soften(4)
  sm = sm and (sm+e) or e
end
work(sm, {hand="glaze", tool="filbert 14", pile=OIL, coverage=1.2, load=0.4, clip=true, length={20,50}})

--@ chunk 8
print(wait(1440))
local grp = {nil,nil,nil}
for _,P in ipairs(PAN) do
  if not P.grate then
    for a=0,1 do for b=0,1 do
      local t = math.random(1,3)
      local r = rect(P.x+a*125+2.5, P.y+b*125+2.5, 120, 120)
      grp[t] = grp[t] and (grp[t]+r) or r
    end end
  end
end
for t=1,3 do work(grp[t], {hand="body", tool="filbert 12", pile=G[t], coverage=3.2, fill=true, clip=true, length={40,110}, angle=math.pi/2, angle_jitter=0.12}) end
work(GRM, {hand="body", tool="filbert 12", pile=PIT, coverage=3.2, fill=true, clip=true, length={40,110}, angle=0})

--@ chunk 9
print(wait(1440))
SEAM = pile{{"bone black",1},{"burnt sienna",0.3},{"lead white",0.45},{"ultramarine blue",0.1}}
STEEL = pile{{"lead white",0.9},{"bone black",0.8},{"ultramarine blue",0.12},{"raw sienna",0.15}}
-- frames around grates: steel
local fr = nil
for _,P in ipairs(PAN) do if P.grate then local f = rect(P.x+2.5,P.y+2.5,245,245) - rect(P.x+9,P.y+9,232,232); fr = fr and (fr+f) or f end end
work(fr, {hand="body", tool="flat 5", pile=STEEL, coverage=3, fill=true, clip=true, length={30,90}, angle=function(x,y) local u=(x%250); return (u<12 or u>238) and math.pi/2 or 0 end})
-- bearing bars (vertical) and cross rods
local bars = nil
for _,P in ipairs(PAN) do if P.grate then
  for k=1,15 do local x = P.x + k*15.625; local b = rect(x-2.6, P.y+9, 5.2, 232); bars = bars and (bars+b) or b end
end end
work(bars, {hand="body", tool="flat 5", pile=STEEL, coverage=2.5, fill=true, clip=true, length={60,120}, angle=math.pi/2, ruler=true})
local rods = nil
for _,P in ipairs(PAN) do if P.grate then
  for k=1,7 do local y = P.y + k*31.25; local b = rect(P.x+9, y-1.6, 232, 3.2); rods = rods and (rods+b) or b end
end end
work(rods, {hand="body", tool="flat 3", pile=STEEL, coverage=2, fill=true, clip=true, length={40,100}, angle=0, ruler=true})
-- seams between solid plates, on the 125 grid (wrap: lines on 0 and 1000 halves)
local sm = nil
for k=0,8 do
  local a = rect(k*125-2.5, -5, 5, 1010); local b = rect(-5, k*125-2.5, 1010, 5)
  sm = sm and (sm+a+b) or (a+b)
end
sm = sm - GRM:grow(0)
work(sm, {hand="detail", pile=SEAM, coverage=3, fill=true, clip=true})
-- test scuff on plate at (500..625, 0..125)
TRK = pile{{"bone black",1},{"raw sienna",0.3},{"lead white",0.5},{"ultramarine blue",0.05}, medium=0.55}
local sc = brush("filbert", 16)
sc:load(TRK, 0.25); sc:stroke({{540,10},{543,60},{541,115}}, {pressure={0.3,0.15}, ramps={0.1,0.4}})
sc:load(TRK, 0.15); sc:stroke({{585,10},{586,60},{588,115}}, {pressure={0.2,0.1}, ramps={0.1,0.4}})

--@ chunk 10
-- repair the test smear on grate (2,0)
local fix = rect(528, 9, 72, 120)
local bars = nil
for k=1,15 do local x = 500 + k*15.625; local b = rect(x-2.6, 9, 5.2, 232); bars = bars and (bars+b) or b end
local rods = nil
for k=1,7 do local y = k*31.25; local b = rect(509, y-1.6, 232, 3.2); rods = rods and (rods+b) or b end
work(fix - bars - rods, {hand="detail", pile=PIT, coverage=3, fill=true, clip=true})
work(fix * bars, {hand="detail", pile=STEEL, coverage=3, fill=true, clip=true})
work(fix * rods, {hand="detail", pile=STEEL, coverage=3, fill=true, clip=true})
-- scuff test on solid plate (0..125)
TRK = pile{{"bone black",1},{"raw sienna",0.35},{"ultramarine blue",0.05}, medium=0.35}
local sc = brush("filbert", 16)
sc:load(TRK, 0.25); sc:stroke({{30,10},{33,60},{31,115}}, {pressure={0.3,0.15}, ramps={0.1,0.4}})
sc:wipe(0.9); sc:load(TRK, 0.12); sc:stroke({{80,10},{81,60},{83,115}}, {pressure={0.2,0.1}, ramps={0.1,0.4}})

--@ chunk 11
TRK2 = pile{{"bone black",1},{"burnt sienna",0.3},{"lead white",0.35},{"ultramarine blue",0.08}, medium=0.5}
local sc = brush("filbert", 18)
sc:load(TRK2, 0.12); sc:stroke({{160,8},{162,60},{161,118}}, {pressure={0.55,0.35}, ramps={0.1,0.4}})
sc:wipe(0.9); sc:load(TRK2, 0.08); sc:stroke({{210,8},{211,60},{213,118}}, {pressure={0.5,0.3}, ramps={0.1,0.4}})

--@ chunk 12
local am = brush("flat", 7)
local function seg(b, p, ld, x1,y1,x2,y2) b:load(p, ld); b:stroke({{x1,y1},{(x1+x2)/2+rand(-0.8,0.8),(y1+y2)/2},{x2,y2}}, {pressure={0.55,0.4}, shake=0.6}) end
local x0,y0,x1,y1 = 272,272,478,478
for _,c in ipairs({{x0,y0,1,1},{x1,y0,-1,1},{x0,y1,1,-1},{x1,y1,-1,-1}}) do
  seg(am, AMBER, 0.3, c[1], c[2], c[1]+c[3]*55, c[2]); seg(am, AMBER, 0.3, c[1], c[2], c[1], c[2]+c[4]*55)
end
seg(am, AMBER, 0.3, 486, 530, 486, 625); seg(am, AMBER, 0.25, 486, 625, 486, 720)
local st = brush("flat", 5)
local cx, cy = 575, 312
local o = {}
for k=0,12 do local a = k/12*2*math.pi; o[#o+1] = {cx-14 + 9*math.cos(a), cy + 16*math.sin(a)} end
for k=1,12,3 do st:load(STW, 0.4); st:stroke({o[k],o[k+1],o[k+2]}, {pressure={0.55,0.5}}) end
seg(st, STW, 0.4, cx+4, cy-16, cx+24, cy-16); seg(st, STW, 0.4, cx+24, cy-15, cx+11, cy+16)
local RING = pile{{"lead white",1.3},{"bone black",0.7},{"ultramarine blue",0.1}}
local ring = brush{kind="round", width=5, point=0.15}
local d = brush("round", 14)
for _,q in ipairs({{375,125},{625,375},{375,625},{625,875},{875,375},{875,875},{125,875},{125,625}}) do
  d:reload(PIT, 0.8); d:touch(q[1], q[2], {pressure=0.85})
  local o2 = {}; local a0 = rand(0,6.28)
  for k=0,12 do local a = a0 + k/12*5.8; o2[#o2+1] = {q[1] + 13*math.cos(a), q[2] + 10*math.sin(a)} end
  ring:reload(RING, 0.8); ring:stroke(o2, {pressure={0.75,0.65}})
end
-- forklift-tire scuffs: gray, low contrast, all running in y, kept off grates
SCUF = pile{{"lead white",1},{"bone black",1},{"raw sienna",0.15},{"ultramarine blue",0.05}, medium=0.2}
local keep = -(GRM:grow(6))
local sc = brush("filbert", 18)
local xs = uneven(36, 20, 980, 0.6, 0.4, 91)
for _,x in ipairs(xs) do
  local y = rand(10, 760); local L = rand(80, 220)
  sc:reload(SCUF, rand(0.1,0.18))
  sc:stroke({{x,y},{x+rand(-2,2), y+L/2},{x+rand(-3,3), y+L}}, {pressure={0.5,0.25}, ramps={0.1,0.45}, shake=1, clip=keep})
end

--@ chunk 13
print(wait(720))
local m = rect(2.5,2.5,120,120) + rect(127.5,2.5,120,120)
work(m, {hand="body", tool="filbert 12", pile=G[2], coverage=3.5, fill=true, clip=true, length={40,110}, angle=math.pi/2, angle_jitter=0.12})
local OILS = pile{{"lead white",0.8},{"bone black",1},{"burnt sienna",0.25},{"ultramarine blue",0.1}, medium=0.3}
local sm = nil
for _,s in ipairs({{190,560,26,18},{860,160,20,26},{430,850,30,20},{700,300,16,12}}) do
  local e = ellipse(s[1],s[2],s[3],s[4]):roughen(7,25,math.random(1,999))
  sm = sm and (sm+e) or e
end
work(sm, {hand="body", tool="filbert 6", pile=OILS, coverage=2, fill=true, clip=true, load=0.5, length={8,20}})
blend(sm:grow(3), {})

--@ chunk 14
print(wait(1440))
local fix = rect(392, 822, 76, 58)
local bars = nil
for k=1,15 do local x = 250 + k*15.625; local b = rect(x-2.6, 759, 5.2, 232); bars = bars and (bars+b) or b end
local rods = nil
for k=1,7 do local y = 750 + k*31.25; local b = rect(259, y-1.6, 232, 3.2); rods = rods and (rods+b) or b end
work(fix - bars - rods, {hand="detail", pile=PIT, coverage=3.5, fill=true, clip=true})
work(fix * (bars + rods), {hand="detail", pile=STEEL, coverage=3.5, fill=true, clip=true})
