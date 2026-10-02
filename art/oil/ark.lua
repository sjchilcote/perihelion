-- easel session "ark": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=0.75, linen={16,13}, seed=4471,
  ground={
    {pile={{"lead white",4},{"bone black",0.25}}, um=90, apply="knife", texture=0.35},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"ultramarine blue",1.2},{"lead white",0.8}, medium=0.4}, um=22, apply="brush"},
  }}
print(W,H)

--@ chunk 2
-- test swatches of darks in the top-left corner (will be vault darkness)
local mixes = {
  pile{{"ultramarine blue",2},{"burnt sienna",1}},
  pile{{"ultramarine blue",1},{"burnt sienna",1},{"bone brown",1}},
  pile{{"bone brown",2},{"ultramarine ash",1},{"burnt sienna",1}},
  pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",0.5}},
  pile{{"burnt sienna",2},{"ultramarine blue",1},{"raw sienna",1},{"lead white",0.6}},
}
for i,p in ipairs(mixes) do
  work(rect(20+(i-1)*36, 20, 30, 40), {hand="body", pile=p, coverage=2.5, fill=true, angle=1.2, clip=true})
end

--@ chunk 3
local mixes = {
  pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1}},
  pile{{"bone black",1},{"bone brown",2},{"ultramarine blue",0.5}},
  pile{{"ultramarine blue",1},{"burnt sienna",2},{"bone black",1}},
  -- bronze mids
  pile{{"burnt sienna",2},{"yellow ochre",1},{"ultramarine ash",0.5}},
  pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",1}},
  -- bronze lights
  pile{{"yellow ochre",2},{"lead white",1},{"cadmium yellow",0.3}},
  pile{{"lead white",3},{"Indian yellow",1},{"cadmium yellow",0.5}},
  -- verdigris
  pile{{"viridian",1},{"cerulean blue",1},{"lead white",1},{"yellow ochre",0.3}},
  -- rock
  pile{{"bone brown",1},{"ultramarine ash",1},{"lead white",1},{"raw sienna",0.5}},
  -- frost
  pile{{"lead white",4},{"cerulean blue",0.3}},
}
for i,p in ipairs(mixes) do
  work(rect(20+(i-1)*36, 70, 30, 40), {hand="body", pile=p, coverage=3, fill=true, angle=1.2, clip=true})
end

--@ chunk 4
-- brush drawing: lean dark lines placing the big shapes
draw = pile{{"burnt sienna",1},{"ultramarine blue",1},{"bone black",0.5}, medium=0.55}
local b = brush{kind="round", width=3, point=0.8}
b:load(draw, 0.7)
-- oculus
local oc = outline{{665,170},{735,125},{808,165},{740,212}, closed=true, char="searching", seed=11}
oc:paint(b, {pressure=0.5, dip={draw,0.6}, every=3})
-- left tank sphere edge
local lt = outline{{120,175},{245,260},{320,420},{345,620},{318,820},{240,980},{150,1080}, char="searching", seed=12}
lt:paint(b, {pressure=0.5, dip={draw,0.6}, every=3})
-- right tank
local rt = outline{{1000,370},{850,400},{760,520},{735,650},{770,790},{860,870},{1000,900}, char="searching", seed=13}
rt:paint(b, {pressure=0.5, dip={draw,0.6}, every=3})
-- shaft edges
b:stroke({{690,205},{300,1060}}, {pressure={0.35,0.25}})
b:load(draw,0.6)
b:stroke({{790,200},{590,1075}}, {pressure={0.35,0.25}})
-- rock horizon / heaps
local hz = outline{{0,1110},{120,1040},{260,960},{420,930},{560,945},{700,905},{820,915},{1000,880}, char="searching", seed=14}
hz:paint(b, {pressure=0.45, dip={draw,0.6}, every=3})
local fg = outline{{560,1333},{640,1230},{760,1170},{900,1150},{1000,1160}, char="searching", seed=15}
fg:paint(b, {pressure=0.45, dip={draw,0.6}, every=3})
-- the Ark (capsule) and the kneeling frame, simple
local ark = outline{{345,1040,"c"},{352,1012,"c"},{428,998,"c"},{432,1026,"c"}, closed=true, char="firm", seed=16}
ark:paint(b, {pressure=0.4, dip={draw,0.6}, every=2})
local fig = outline{{452,1062,"c"},{448,1030},{462,1000},{470,968},{486,950},{500,962},{508,995},{520,1030},{532,1062,"c"}, char="searching", seed=17}
fig:paint(b, {pressure=0.4, dip={draw,0.6}, every=2})

--@ chunk 5
-- global shapes
HZ = {{0,1110},{120,1040},{260,962},{420,932},{560,946},{700,906},{820,916},{1000,882}}
FLOOR = below(HZ)
LT = ellipse(-130, 630, 475, 520)
RT = ellipse(1010, 640, 275, 270)
SHAFT = poly({{690,200},{790,195},{600,1080},{290,1065}})
local back = everywhere() - FLOOR - LT - RT
vaultDark = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1}, medium=0.15}
vaultWarm = pile{{"bone black",1},{"bone brown",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}, medium=0.15}
work(back, {hand="broad", pile=vaultDark, coverage=2.2, fill=true, angle=function(x,y) return math.atan(y-170, x-735) end})
print(drying(500,300))

--@ chunk 6
tankDark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.6},{"ultramarine blue",0.6}, medium=0.1}
tankMid  = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}, medium=0.1}
local ltBody = LT - FLOOR
work(ltBody, {hand="broad", pile=tankDark, coverage=2.5, fill=true, edge="firm",
  angle=function(x,y) return math.atan(y-630, x+130) + math.pi/2 end})
local ltCres = (LT - ellipse(-175, 615, 470, 520)):soften(10) - FLOOR
work(ltCres, {hand="body", pile=tankMid, coverage=2.5, fill=true, edge="soft",
  angle=function(x,y) return math.atan(y-630, x+130) + math.pi/2 end})
local rtBody = RT - FLOOR
work(rtBody, {hand="broad", pile=tankDark, coverage=2.5, fill=true, edge="firm",
  angle=function(x,y) return math.atan(y-640, x-1010) + math.pi/2 end})
local rtCres = (RT - ellipse(1050, 670, 275, 270)):soften(10) - FLOOR
work(rtCres, {hand="body", pile=tankMid, coverage=2.5, fill=true, edge="soft",
  angle=function(x,y) return math.atan(y-640, x-1010) + math.pi/2 end})

--@ chunk 7
local s = body.ellipsoid({-130,630,0},{475,520,450})
local f = form{{s}, light={from={1,-0.45}, front=0.2, ambient=0.05}}
for _,p in ipairs({{0,630},{150,630},{250,630},{300,630},{330,630},{340,630},{250,300},{300,400},{200,900},{100,200}}) do
  print(p[1],p[2], f:value(p[1],p[2]))
end

--@ chunk 8
local s = body.ellipsoid({-130,630,0},{475,520,450})
local f = form{{s}, light={from={1,-0.35}, front=-0.1, ambient=0.0}}
for _,p in ipairs({{0,630},{150,630},{250,630},{300,630},{330,630},{340,630},{200,300},{230,400},{200,900},{100,200},{150,1000}}) do
  print(p[1],p[2], f:value(p[1],p[2]))
end

--@ chunk 9
tankDim  = pile{{"bone black",2},{"raw sienna",1},{"burnt sienna",1},{"ultramarine blue",0.5}, medium=0.1}
tankMid2 = pile{{"raw sienna",2},{"bone black",1.5},{"burnt sienna",1},{"ultramarine blue",0.3}, medium=0.1}
tankLit  = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.5}, medium=0.1}
local function bands(f, shape, ang)
  local function band(lo, hi)
    return mask(function(x,y) local v=f:value(x,y); return smoothstep(lo-0.05,lo+0.05,v)*(1-smoothstep(hi-0.05,hi+0.05,v)) end) * shape
  end
  work(band(-1,0.42), {hand="body", pile=tankDark, coverage=2.2, fill=true, angle=ang})
  work(band(0.42,0.68), {hand="body", pile=tankDim, coverage=2.2, fill=true, angle=ang})
  work(band(0.68,0.86), {hand="body", pile=tankMid2, coverage=2.2, fill=true, angle=ang})
  work(band(0.86,2), {hand="body", pile=tankLit, coverage=2.0, fill=true, angle=ang, clip=true})
end
local s = body.ellipsoid({-130,630,0},{475,520,450})
local f = form{{s}, light={from={1,-0.35}, front=-0.1, ambient=0.0}}
bands(f, LT - FLOOR, function(x,y) return math.atan(y-630, x+130) + math.pi/2 end)
local s2 = body.ellipsoid({1010,640,0},{275,270,260})
local f2 = form{{s2}, light={from={-1,-0.6}, front=-0.15, ambient=0.0}}
bands(f2, RT - FLOOR, function(x,y) return math.atan(y-640, x-1010) + math.pi/2 end)

--@ chunk 10
bzDeep = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}, medium=0.1}
bzDark = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}, medium=0.1}
bzMid  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1}, medium=0.1}
bzLit  = pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",1},{"bone brown",0.5}, medium=0.1}
bzGold = pile{{"raw sienna",2},{"burnt sienna",1},{"lead white",0.5},{"yellow ochre",1}, medium=0.1}
LT = ellipse(-330, 560, 680, 720)
RT = rect(772, 445, 260, 520) + ellipse(1020, 445, 248, 105)
-- vault dark over the old right sphere where it is no longer tank
local oldR = ellipse(1010, 640, 280, 275) - RT - FLOOR
work(oldR, {hand="body", pile=vaultDark, coverage=3, fill=true, angle=1.0})
local s = body.ellipsoid({-330,560,0},{680,720,600})
local f = form{{s}, light={from={1,-0.25}, front=-0.15, ambient=0.0}}
local function band(lo, hi, shape)
  return mask(function(x,y) local v=f:value(x,y); return smoothstep(lo-0.04,lo+0.04,v)*(1-smoothstep(hi-0.04,hi+0.04,v)) end) * shape
end
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local sh = LT - FLOOR
work(band(-1,0.5,sh), {hand="broad", pile=bzDeep, coverage=2.5, fill=true, angle=ang})
work(band(0.5,0.72,sh), {hand="body", pile=bzDark, coverage=2.5, fill=true, angle=ang})
work(band(0.72,0.86,sh), {hand="body", pile=bzMid, coverage=2.5, fill=true, angle=ang})
work(band(0.86,0.93,sh), {hand="body", pile=bzLit, coverage=2.2, fill=true, angle=ang, clip=true})
-- cylinder: bands by x
local R = RT - FLOOR
work(R * rect(870,0,200,1333), {hand="body", pile=bzDeep, coverage=2.5, fill=true, angle=math.pi/2})
work(R * rect(805,0,65,1333), {hand="body", pile=bzDark, coverage=2.5, fill=true, angle=math.pi/2})
work(R * rect(772,0,33,1333), {hand="body", pile=bzMid, coverage=2.5, fill=true, angle=math.pi/2, clip=true})

--@ chunk 11
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local sh = LT - FLOOR
local inner = LT:shrink(90) - FLOOR
work(inner, {hand="broad", pile=bzDeep, coverage=2.6, fill=true, angle=ang})
local rimUp = (sh - LT:shrink(90)) * mask(function(x,y) return 1 - smoothstep(350, 520, y) end)
work(rimUp, {hand="body", pile=bzDark, coverage=2.4, fill=true, angle=ang})
blend(sh, {angle=ang})
-- right cylinder: pull bands together, darker
local R = RT - FLOOR
work(R * rect(840,0,200,1333), {hand="body", pile=bzDeep, coverage=2.4, fill=true, angle=math.pi/2})
blend(R, {angle=math.pi/2})
-- leftovers of the old sphere
local left = (ellipse(1010, 640, 290, 285) - RT - FLOOR):grow(4) * rect(700,330,100,320)
work(left, {hand="body", pile=vaultDark, coverage=3, fill=true, angle=1.0, clip=true})

--@ chunk 12
rockDark = pile{{"bone brown",1},{"ultramarine ash",1},{"bone black",0.5},{"lead white",0.25},{"burnt sienna",0.3}, medium=0.1}
rockDeep = pile{{"bone brown",2},{"ultramarine blue",0.8},{"bone black",0.6}, medium=0.1}
rockMid  = pile{{"raw sienna",1},{"bone brown",1},{"lead white",1},{"ultramarine ash",0.5}, medium=0.05}
local pool = ellipse(400, 1050, 270, 95):soften(40)
local farFloor = FLOOR * rect(0,0,1000,1000)
work(FLOOR - pool, {hand="broad", pile=rockDark, coverage=2.5, fill=true, angle=function(x,y) return 0.08*math.sin(x/90) end})
-- foreground deep shadow bottom
local fgShadow = FLOOR * mask(function(x,y) return smoothstep(1180, 1300, y) end)
work(fgShadow, {hand="broad", pile=rockDeep, coverage=2, fill=true, angle=0.05})
work(pool, {hand="body", pile=rockMid, coverage=2.5, fill=true, angle=-0.05})

--@ chunk 13
-- kill the pale disc: work dark rock into it while wet, broken
local pool = ellipse(400, 1050, 290, 110)
work(pool, {hand="body", pile=rockDark, coverage=2.2, fill=true, angle=function(x,y) return -0.15 + 0.2*math.sin(y/30) end})
-- heaps
rockWarm = pile{{"burnt sienna",1},{"bone brown",1},{"ultramarine ash",0.6},{"lead white",0.35}, medium=0.05}
-- H1 heap behind Ark, piled against the left tank
H1 = poly({{40,1100},{120,1010},{220,935},{300,905},{350,902},{420,925},{520,975},{600,1030},{560,1080},{300,1090}}, true)
-- its lit slope (the side facing the beam, right/upper-right)
local H1lit = H1 * poly({{300,880},{360,890},{430,920},{530,975},{600,1030},{450,1050},{340,960}}, true)
work(H1 - H1lit, {hand="body", pile=rockDeep, coverage=2.2, fill=true, angle=function(x,y) return -0.6 end})
work(H1lit, {hand="body", pile=rockWarm, coverage=2.2, fill=true, angle=0.45})
-- far heap H2 under the cylinder
H2 = poly({{480,975},{560,930},{640,895},{720,878},{800,890},{900,905},{1000,898},{1000,990},{600,1000}}, true)
work(H2, {hand="body", pile=rockDark, coverage=2.2, fill=true, angle=0.1})
-- foreground mound, shadowed
FG = poly({{470,1333},{560,1260},{680,1195},{800,1165},{900,1150},{1000,1148},{1000,1333}}, true)
work(FG, {hand="broad", pile=rockDeep, coverage=2.5, fill=true, angle=-0.25})

--@ chunk 14
-- unify the floor around the heap; kill the pale ring
local ring = (ellipse(400, 1050, 310, 125) - H1:shrink(10)) * FLOOR
work(ring, {hand="body", pile=rockDark, coverage=2.5, fill=true, angle=function(x,y) return 0.1*math.sin(x/70) end})
-- mid floor band between heaps and foreground: darker toward viewer
local mid = FLOOR - H1 - H2 - FG
work(mid * mask(function(x,y) return smoothstep(1080,1200,y) end), {hand="body", pile=rockDeep, coverage=2, fill=true, angle=0.05})
blend(mid, {angle=0.05})

--@ chunk 15
print(wait(24*60)); for _,p in ipairs({{500,300},{100,600},{330,600},{800,600},{700,1000},{400,1000},{700,1250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 16
print(wait(36*60)); for _,p in ipairs({{500,300},{100,600},{330,600},{800,600},{700,1000},{400,1000},{700,1250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 17
print(wait(3*24*60)); for _,p in ipairs({{500,300},{100,600},{330,600},{800,600},{700,1000},{400,1000},{700,1250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 18
glazeDark = pile{{"bone brown",1.2},{"ultramarine blue",1},{"burnt sienna",0.3}, medium=0.6}
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local inner = (LT:shrink(28) - FLOOR)
work(inner, {hand="glaze", pile=glazeDark, coverage=1.6, angle=ang, clip=inner:soften(12)})
-- right drum: glaze all but a narrow left edge
local R = (RT - FLOOR)
local Rin = R * rect(790,0,300,1333)
work(Rin, {hand="glaze", pile=glazeDark, coverage=1.6, angle=math.pi/2, clip=Rin:soften(8)})

--@ chunk 19
bzWarmDark = pile{{"bone brown",2},{"burnt sienna",1.5},{"raw sienna",0.5}, medium=0.05}
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local inner = (LT:shrink(20) - FLOOR)
work(inner, {hand="body", pile=bzWarmDark, coverage=2.6, fill=true, angle=ang, clip=inner:soften(10)})
blend(inner, {angle=ang})
local R = (RT - FLOOR)
local Rin = R * rect(786,0,300,1333)
work(Rin, {hand="body", pile=bzWarmDark, coverage=2.6, fill=true, angle=math.pi/2, clip=Rin:soften(6)})
blend(Rin, {angle=math.pi/2})

--@ chunk 20
bzShadow = pile{{"bone black",2},{"Mars brown",1},{"ultramarine blue",0.5}, medium=0.05}
bzShadowWarm = pile{{"bone black",1},{"burnt sienna",1}, medium=0.05}
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local inner = (LT:shrink(60) - FLOOR)
work(inner, {hand="body", pile=bzShadow, coverage=3, fill=true, angle=ang, clip=inner:soften(15)})
local mid = (LT:shrink(22) - LT:shrink(60) - FLOOR)
work(mid, {hand="body", pile=bzShadowWarm, coverage=2.6, fill=true, angle=ang, clip=mid:soften(8)})
blend(LT:shrink(18) - FLOOR, {angle=ang})
local R = (RT - FLOOR)
local Rin = R * rect(830,0,300,1333)
work(Rin, {hand="body", pile=bzShadow, coverage=3, fill=true, angle=math.pi/2, clip=Rin:soften(10)})
local Rm = R * rect(790,0,40,1333)
work(Rm, {hand="body", pile=bzShadowWarm, coverage=2.6, fill=true, angle=math.pi/2, clip=Rm:soften(6)})
blend(R * rect(786,0,300,1333), {angle=math.pi/2})

--@ chunk 21
local ang = function(x,y) return math.atan(y-560, x+330) + math.pi/2 end
local limb = (LT - LT:shrink(26) - FLOOR)
work(limb, {hand="body", pile=bzShadowWarm, coverage=2.4, fill=true, angle=ang, clip=limb,
  load_at=function(x,y) return lerp(0.9, 0.35, smoothstep(300, 650, y)) end})
local seam = (LT:shrink(8) - LT:shrink(60) - FLOOR)
blend(seam, {angle=ang})
local R = (RT - FLOOR) * rect(770,0,40,1333)
work(R, {hand="body", pile=bzShadowWarm, coverage=2.2, fill=true, angle=math.pi/2, clip=R, load=0.45})
blend((RT - FLOOR) * rect(776,0,80,1333), {angle=math.pi/2})

--@ chunk 22
for _,p in ipairs({{700,1000},{900,950},{600,1100},{700,1250},{300,1000},{250,1200}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 23
local ps = {
  pile{{"bone black",1},{"Mars brown",1.5},{"ultramarine blue",0.5},{"lead white",0.3}},
  pile{{"bone black",1},{"Mars brown",2},{"ultramarine blue",0.5}},
  pile{{"Mars brown",1.2},{"ultramarine ash",1},{"bone black",0.8},{"lead white",0.4}},
  pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",0.5}},
}
rockShadow = ps[1]
local x0 = H1:grow(10)
local zone = FLOOR - x0 - ellipse(420, 1045, 130, 50):soften(20)
-- break the zone into patches; vary piles by patch
local cells = worley{seed=7, period=90, jitter=0.9}
for i=1,4 do
  local m = zone * mask(function(x,y) local d1,d2,wall,id = cells:at(x,y); return (math.floor(id*4)+1 == i) and 1 or 0 end)
  work(m, {hand="body", pile=ps[i], coverage=2.4, fill=true, angle=function(x,y) return 0.12*math.sin(x/60+y/40) end, length={25,70}})
end

--@ chunk 24
local zone = FLOOR - H1:grow(10) - ellipse(420, 1045, 130, 50):soften(20)
work(zone, {hand="body", pile=pile{{"bone black",1},{"Mars brown",2},{"ultramarine blue",0.5}}, coverage=1.6, fill=false, angle=0.05, length={30,90}, load=0.6})
blend(zone, {angle=0.03})
blend(zone, {angle=-0.1})

--@ chunk 25
print(wait(5*24*60)); for _,p in ipairs({{500,300},{100,600},{330,600},{800,600},{700,1000},{400,1000},{700,1250},{250,1050}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 26
OC = {735, 170}
VAULT_OK = everywhere() - LT:grow(3) - RT:grow(3) - FLOOR
plateNear = pile{{"raw sienna",2},{"burnt sienna",1},{"lead white",0.7},{"yellow ochre",1}, medium=0.1}
plateMid  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.2}, medium=0.1}
plateFar  = pile{{"burnt sienna",1},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.1}
GA = math.pi * (3 - math.sqrt(5))
function plate(n, c, sq, brush, rmin, rmax)
  local r = c * math.sqrt(n)
  if r < rmin or r > rmax then return end
  local th = n * GA
  local x = OC[1] + r*math.cos(th)
  local y = OC[2] + sq*r*math.sin(th)
  if x < -10 or x > 1010 or y < -10 or y > 1340 then return end
  if VAULT_OK:at(x,y) < 0.5 then return end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local sp = c * 0.9 * (0.85 + 0.3*math.random())
  local half = sp*0.45
  -- bow the arc toward the oculus (inner edge of the scale)
  local rx, ry = OC[1]-x, OC[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  local bow = sp*0.18
  local pts = {{x - tx*half, y - ty*half}, {x + rx*bow, y + ry*bow}, {x + tx*half, y + ty*half}}
  local fall = smoothstep(rmin, rmax, r)
  brush:stroke(pts, {pressure={0.55*(1-0.5*fall), 0.15}, ramps={0.2,0.5}, shake=0.6})
end
local b = brush{kind="round", width=3.2, point=0.6}
local count = 0
for n=1,400 do
  local r = 16*math.sqrt(n)
  if r>=60 and r<=300 then
    if count % 6 == 0 then b:load(r < 180 and plateNear or plateMid, 0.55) end
    plate(n, 16, 0.6, b, 60, 300)
    count = count + 1
  end
end
print(count)

--@ chunk 27
local m = ellipse(735, 170, 330, 205) * VAULT_OK
blend(m, {angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end})

--@ chunk 28
local m = ellipse(735, 170, 345, 220):soften(15) * VAULT_OK
work(m, {hand="body", pile=vaultDark, coverage=3.2, fill=true, angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end, length={30,80}})

--@ chunk 29
print(wait(6*24*60)); for _,p in ipairs({{735,170},{600,300},{900,100},{500,450},{800,450}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 30
GA = math.pi * (3 - math.sqrt(5))
-- one scale plate of a phyllotactic dome centered at C (squash sq); r = c * n^ex
-- tools = {bodies={{maxsize, brush},...}, be=edge brush, bs=shadow brush}
function plate3(C, n, c, ex, sq, tools, okmask, light)
  local r = c * n^ex
  local th = n * GA
  local x = C[1] + r*math.cos(th)
  local y = C[2] + sq*r*math.sin(th)
  if x < -30 or x > 1030 or y < -30 or y > 1360 then return false end
  if okmask and okmask:at(x,y) < 0.5 then return false end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local rx, ry = C[1]-x, C[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  -- spacing between neighbours at this radius
  local dr = c * ex * n^(ex-1) * 1.0
  local s = math.sqrt(2*math.pi*r*dr) * (0.92 + 0.16*math.random())
  local half = s*0.55
  local radial = s*(0.4 + 0.6*sq)*0.5
  local bb
  for _,e in ipairs(tools.bodies) do if s <= e[1] then bb = e[2]; break end end
  bb = bb or tools.bodies[#tools.bodies][2]
  bb:stroke({{x - tx*half*0.75, y - ty*half*0.75}, {x - rx*radial*0.15, y - ry*radial*0.15}, {x + tx*half*0.75, y + ty*half*0.75}}, {pressure={0.85,0.75}, ramps={0.15,0.25}})
  local ox, oy = -rx*radial*0.8, -ry*radial*0.8
  tools.bs:stroke({{x - tx*half*0.9 + ox*0.7, y - ty*half*0.9 + oy*0.7}, {x + ox, y + oy}, {x + tx*half*0.9 + ox*0.7, y + ty*half*0.9 + oy*0.7}}, {pressure={0.5,0.15}, ramps={0.2,0.4}})
  local ix, iy = rx*radial*0.6, ry*radial*0.6
  local L = light or 1
  if L > 0.05 then
    tools.be:stroke({{x - tx*half*0.8 + ix*0.5, y - ty*half*0.8 + iy*0.5}, {x + ix, y + iy}, {x + tx*half*0.8 + ix*0.5, y + ty*half*0.8 + iy*0.5}}, {pressure={0.5*L,0.08}, ramps={0.25,0.5}})
  end
  return true, r, s
end
local bodyNear = pile{{"bone black",1},{"burnt sienna",1.2},{"raw sienna",0.3}, medium=0.1}
local bodyFar  = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.4}, medium=0.1}
local edgeNear = pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",1},{"lead white",0.8}, medium=0.1}
local edgeMid  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.4}, medium=0.1}
local edgeFar  = pile{{"burnt sienna",2},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",1}, medium=0.1}
local tools = {bodies={{14, brush("filbert",9)},{20, brush("filbert",12)},{27, brush("filbert",16)},{99, brush("filbert",21)}},
  be=brush{kind="round", width=2.6, point=0.7}, bs=brush{kind="round", width=3.2, point=0.5}}
local C = OC
local c, ex, sq = 4, 0.7, 0.6
local k = 0
local nmax = math.floor((650/c)^(1/ex))
local nmin = math.floor((78/c)^(1/ex))
for n=nmax,nmin,-1 do
  local r = c*n^ex
  local t = smoothstep(90, 520, r)
  if k % 4 == 0 then
    local bp = (t < 0.5) and bodyNear or bodyFar
    for _,e in ipairs(tools.bodies) do e[2]:load(bp,0.6) end
    tools.be:load(t < 0.25 and edgeNear or (t < 0.65 and edgeMid or edgeFar), 0.5)
    tools.bs:load(shP,0.55)
  end
  local ok = plate3(C, n, c, ex, sq, tools, VAULT_OK, 1 - 0.85*t)
  if ok then k = k + 1 end
end
print(nmin, nmax, k)

--@ chunk 31
print(wait(6*24*60)); for _,p in ipairs({{735,170},{600,300},{900,100},{500,450},{800,450},{300,100}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 32
darkGlaze = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.8}
local function ed(x,y) local dx=(x-OC[1]); local dy=(y-OC[2])/0.6; return math.sqrt(dx*dx+dy*dy) end
local m = VAULT_OK * mask(function(x,y) return smoothstep(110, 220, ed(x,y)) end)
work(m, {hand="glaze", pile=darkGlaze, coverage=2.0, fill=true, clip=m,
  angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end,
  load_at=function(x,y) return lerp(0.2, 0.75, smoothstep(150, 600, ed(x,y))) end})
blend(m, {angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end})

--@ chunk 33
rimGold = pile{{"yellow ochre",2},{"lead white",1.5},{"cadmium yellow",0.4},{"raw sienna",0.5}}
lightWhite = pile{{"lead white",5},{"lemon chrome",0.25},{"cadmium yellow",0.15}}
lightWarm = pile{{"lead white",3},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
OPEN = ellipse(735, 166, 64, 38)
local shell = (ellipse(735, 175, 72, 46) - OPEN) * mask(function(x,y) return smoothstep(150, 175, y) end)
work(shell, {hand="detail", pile=rimGold, coverage=3, fill=true, angle=0, clip=true})
work(OPEN, {hand="body", tool="filbert 8", pile=lightWarm, coverage=3, fill=true, angle=0, clip=true})
work(ellipse(735,164,48,26), {hand="body", tool="filbert 8", pile=lightWhite, coverage=3.5, fill=true, angle=0, clip=true})

--@ chunk 34
local shell = (ellipse(735, 176, 74, 48) - OPEN) * mask(function(x,y) return smoothstep(150, 175, y) end)
work(shell, {hand="detail", pile=pile{{"bone black",1.2},{"burnt sienna",1},{"bone brown",0.5}}, coverage=3, fill=true, angle=0, clip=true})
blend(shell, {angle=0})
local pureW = pile{{"lead white",6},{"lemon chrome",0.1}}
work(ellipse(735,163,40,20), {hand="body", tool="filbert 6", pile=pureW, coverage=3, fill=true, angle=0, clip=true})
blend(OPEN:shrink(2), {angle=0})

--@ chunk 35
print(wait(6*24*60)); for _,p in ipairs({{735,166},{735,200},{600,300},{500,600},{400,1000},{600,1000},{300,100}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 36
BEAM_A = 1.94
BEAM = poly({{675,185},{798,180},{575,1075},{265,1060}}):soften(30)
BEAMCORE = poly({{700,190},{772,186},{510,1060},{330,1052}}):soften(25)
warmGlaze = pile{{"burnt sienna",1},{"Mars orange",1}, medium=0.9}
veilA = pile{{"lead white",1},{"Mars orange",1},{"cadmium yellow",0.6}, medium=0.85}
local bm = BEAM - FLOOR:shrink(30)
work(bm, {hand="glaze", pile=warmGlaze, coverage=1.0, load=0.3, angle=BEAM_A, clip=bm})
blend(bm, {angle=BEAM_A})

--@ chunk 37
local bm = BEAM - FLOOR:shrink(30)
work(bm, {hand="glaze", pile=veilA, coverage=1.4, load=0.3, angle=BEAM_A, clip=bm,
  load_at=function(x,y) return lerp(0.4, 0.22, smoothstep(250, 700, y)) + 0.12*smoothstep(800, 1000, y) end})
blend(bm, {angle=BEAM_A})

--@ chunk 38
rkDeep = pile{{"bone black",2},{"Mars brown",1},{"lead white",0.15}}
rkDark = pile{{"bone black",1.5},{"Mars brown",1},{"lead white",0.35},{"yellow ochre",0.3}}
rkWarm = pile{{"Mars brown",1},{"bone black",0.7},{"lead white",0.6},{"yellow ochre",0.5}}
rkCool = pile{{"bone brown",1},{"bone black",1},{"lead white",0.7},{"ultramarine ash",0.5}}
rkLit1 = pile{{"yellow ochre",1},{"lead white",1},{"bone black",0.3},{"raw sienna",0.5}}
rkLit2 = pile{{"lead white",2},{"yellow ochre",1},{"Mars orange",0.3},{"bone black",0.1}}
rkLit3 = pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}
local F = FLOOR:grow(4)
-- far floor and heaps: dark, strokes following the slopes
work(F * mask(function(x,y) return 1 - smoothstep(1100, 1160, y) end), {hand="body", pile=rkDark, coverage=2.6, fill=true,
  angle=function(x,y) return 0.15*math.sin(x/80) - 0.1 end, length={20,55}})
-- near floor: deeper
work(F * mask(function(x,y) return smoothstep(1080, 1160, y) end), {hand="broad", pile=rkDeep, coverage=2.6, fill=true,
  angle=function(x,y) return 0.1*math.sin(x/120) end})

--@ chunk 39
H1 = poly({{120,1060},{180,1000},{220,950},{262,914},{300,898},{340,899},{382,918},{432,952},{482,984},{530,1004},{560,1030},{300,1060}}, true)
local left = H1 * poly({{100,880},{318,880},{335,1070},{100,1070}})
local right = H1 - left
work(left, {hand="body", pile=rkDark, coverage=2.6, fill=true, angle=-0.75, length={15,40}, edge="firm"})
work(right, {hand="body", pile=rkWarm, coverage=2.4, fill=true, angle=0.55, length={15,40}, edge="firm"})
blend(H1:shrink(4) * poly({{290,880},{350,880},{350,1070},{290,1070}}), {angle=1.5})

--@ chunk 40
local left = H1 * poly({{100,880},{318,880},{335,1070},{100,1070}})
local right = H1 - left
rkFlank = pile{{"bone black",1},{"Mars brown",1},{"burnt sienna",0.5}}
work(left:soften(6), {hand="body", pile=rkDeep, coverage=3, fill=true, angle=-0.75, length={15,40}, clip=H1:grow(2)})
work(right:soften(6), {hand="body", pile=rkFlank, coverage=2.6, fill=true, angle=0.55, length={15,40}, clip=H1:grow(2)})

--@ chunk 41
GA = math.pi * (3 - math.sqrt(5))
-- Fibonacci-sphere scale plates on a sphere (center cx,cy, radius R in canvas units)
-- o.rot: rotation of the pole; o.light: unit vector (z toward viewer)
-- o.pickBody(nd,p) -> brush ; o.edge, o.shadow brushes ; o.reload(nd,p) loads brushes ; o.edgeLight(nd,p) -> 0..1
function sphere_plates(o)
  local N, R, cx, cy = o.N, o.R, o.cx, o.cy
  local pts = {}
  for n=0,N-1 do
    local zz = 1 - 2*(n+0.5)/N
    local rr = math.sqrt(1-zz*zz)
    local th = n*GA
    local v = o.rot({rr*math.cos(th), rr*math.sin(th), zz})
    if v[3] > 0.02 then
      local x, y = cx + R*v[1], cy + R*v[2]
      if x > -40 and x < 1040 and y > -40 and y < 1380 and (not o.ok or o.ok:at(x,y) > 0.5) then
        pts[#pts+1] = {x=x, y=y, v=v, n=n}
      end
    end
  end
  table.sort(pts, function(a,b) return a.v[3] < b.v[3] end)
  local spacing = R * math.sqrt(4*math.pi/N)
  local pole = o.rot({0,0,1})
  local k = 0
  for _,p in ipairs(pts) do
    local v = p.v
    local t = {pole[2]*v[3]-pole[3]*v[2], pole[3]*v[1]-pole[1]*v[3], pole[1]*v[2]-pole[2]*v[1]}
    local tl = math.sqrt(t[1]^2+t[2]^2+t[3]^2)+1e-6
    t = {t[1]/tl, t[2]/tl, t[3]/tl}
    local m = {v[2]*t[3]-v[3]*t[2], v[3]*t[1]-v[1]*t[3], v[1]*t[2]-v[2]*t[1]}
    local s = spacing * (0.92 + 0.16*math.random())
    local h = s*0.55
    local function Q(a, b) return {p.x + a*t[1] + b*m[1], p.y + a*t[2] + b*m[2]} end
    local L = o.light
    local nd = v[1]*L[1] + v[2]*L[2] + v[3]*L[3]
    local foreshort = math.sqrt(t[1]^2+t[2]^2)
    if foreshort > 0.15 then
      if k % 4 == 0 then o.reload(nd, p) end
      k = k + 1
      local bb = o.pickBody(nd, p)
      bb:stroke({Q(-h*0.8, 0), Q(0, -h*0.12), Q(h*0.8, 0)}, {pressure={0.8,0.7}, ramps={0.15,0.25}, clip=o.clip})
      o.shadow:stroke({Q(-h*0.9, -h*0.5), Q(0, -h*0.62), Q(h*0.9, -h*0.5)}, {pressure={0.45,0.12}, ramps={0.2,0.4}, clip=o.clip})
      local lit = o.edgeLight(nd, p)
      if lit > 0.05 then
        o.edge:stroke({Q(-h*0.8, h*0.3), Q(0, h*0.5), Q(h*0.8, h*0.3)}, {pressure={0.5*lit,0.08}, ramps={0.25,0.5}, clip=o.clip})
      end
    end
  end
  return k
end
function rotXYZ(ax, ay, az)
  local cxa, sxa, cya, sya, cza, sza = math.cos(ax), math.sin(ax), math.cos(ay), math.sin(ay), math.cos(az), math.sin(az)
  return function(v)
    local x,y,z = v[1],v[2],v[3]
    y, z = y*cxa - z*sxa, y*sxa + z*cxa
    x, z = x*cya + z*sya, -x*sya + z*cya
    x, y = x*cza - y*sza, x*sza + y*cza
    return {x,y,z}
  end
end
local bodyDark = pile{{"bone black",1},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.1}
local bodyDim  = pile{{"bone black",1},{"burnt sienna",1.2},{"raw sienna",0.4}, medium=0.1}
local bodyLit  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1}, medium=0.1}
local edgeDim  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.3}, medium=0.1}
local edgeLit  = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.8}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",0.6}, medium=0.1}
local B = {dark=brush("filbert",20), dim=brush("filbert",20), lit=brush("filbert",20)}
local edge = brush{kind="round", width=4, point=0.7}
local shadow = brush{kind="round", width=5, point=0.5}
local sh = LT - FLOOR
local n = sphere_plates{N=4900, R=690, cx=-340, cy=560, rot=rotXYZ(0.087, 0.79, 0),
  light={0.89,-0.26,0.37}, ok=LT:shrink(6) - FLOOR, clip=sh, edge=edge, shadow=shadow,
  pickBody=function(nd,p) if nd > 0.75 then return B.lit elseif nd > 0.5 then return B.dim else return B.dark end end,
  reload=function(nd,p) B.dark:load(bodyDark,0.6); B.dim:load(bodyDim,0.6); B.lit:load(bodyLit,0.6);
    edge:load(nd > 0.7 and edgeLit or edgeDim, 0.5); shadow:load(shP,0.55) end,
  edgeLight=function(nd,p) return clamp((nd-0.45)*2.2, 0, 1) end}
print(n)

--@ chunk 42
print(wait(5*24*60)); for _,p in ipairs({{100,300},{300,600},{200,900},{300,1000},{600,1000},{700,1200}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 43
print(wait(3*24*60)); for _,p in ipairs({{100,300},{300,600},{200,900},{300,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 44
local function nd(x,y)
  local u, w = (x+340)/690, (y-560)/690
  local q = 1 - u*u - w*w
  if q < 0 then q = 0 end
  return u*0.89 - w*0.26 + math.sqrt(q)*0.37
end
local sh = LT - FLOOR
local ang = function(x,y) return math.atan(y-560, x+340) + math.pi/2 end
work(sh, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=sh, angle=ang,
  load_at=function(x,y) return lerp(0.9, 0.3, smoothstep(0.6, 0.97, nd(x,y))) end})
blend(sh, {angle=ang})

--@ chunk 45
local F = (FLOOR - H1:grow(3)) * rect(300, 850, 700, 483) + FLOOR * rect(0, 1000, 300, 333) - H1:grow(3)
local function pd(x,y) local dx=(x-410)/1.0; local dy=(y-1045)/0.33; return math.sqrt(dx*dx+dy*dy) end
work(F, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=F, angle=0.03,
  load_at=function(x,y) return lerp(0.0, 0.85, smoothstep(140, 420, pd(x,y))) end})
blend(F, {angle=0.03})

--@ chunk 46
local GA = math.pi * (3 - math.sqrt(5))
local bodyDark = pile{{"bone black",1},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.1}
local bodyDim  = pile{{"bone black",1},{"burnt sienna",1.2},{"raw sienna",0.4}, medium=0.1}
local bodyLit  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1}, medium=0.1}
local edgeDim  = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.3}, medium=0.1}
local edgeLit  = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.8}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",0.6}, medium=0.1}
local B = {dark=brush("filbert",16), dim=brush("filbert",16), lit=brush("filbert",16)}
local edge = brush{kind="round", width=3.5, point=0.7}
local shadow = brush{kind="round", width=4, point=0.5}
local R, AX, s = 250, 1020, 28
local dy = s*s/(2*math.pi*R)
local clipm = (RT - FLOOR) * rect(760, 440, 300, 600)
local pts = {}
local n = 0
local y = 452
while y < 960 do
  local phi = (n*GA) % (2*math.pi)
  if phi > math.pi then phi = phi - 2*math.pi end
  if math.cos(phi) > 0.08 then
    local x = AX + R*math.sin(phi)
    if x < 1030 and clipm:at(math.max(x,773), y) > 0.5 then pts[#pts+1] = {x=x, y=y, phi=phi} end
  end
  n = n + 1; y = y + dy
end
table.sort(pts, function(a,b) return a.y < b.y end)
local k = 0
for _,p in ipairs(pts) do
  local nd = -0.85*math.sin(p.phi) + 0.45*math.cos(p.phi)
  if k % 4 == 0 then B.dark:load(bodyDark,0.6); B.dim:load(bodyDim,0.6); B.lit:load(bodyLit,0.6); edge:load(nd > 0.75 and edgeLit or edgeDim, 0.5); shadow:load(shP,0.55) end
  k = k + 1
  local bb = (nd > 0.8) and B.lit or ((nd > 0.6) and B.dim or B.dark)
  local hw = s*0.45*math.cos(p.phi) * (0.92 + 0.16*math.random())
  local hh = s*0.5
  bb:stroke({{p.x-hw, p.y}, {p.x, p.y+hh*0.1}, {p.x+hw, p.y}}, {pressure={0.8,0.7}, ramps={0.15,0.25}, clip=clipm})
  shadow:stroke({{p.x-hw*1.05, p.y+hh*0.45}, {p.x, p.y+hh*0.6}, {p.x+hw*1.05, p.y+hh*0.45}}, {pressure={0.45,0.12}, ramps={0.2,0.4}, clip=clipm})
  local lit = clamp((nd-0.5)*2.2, 0, 1)
  if lit > 0.05 then edge:stroke({{p.x-hw*0.9, p.y-hh*0.3}, {p.x, p.y-hh*0.45}, {p.x+hw*0.9, p.y-hh*0.3}}, {pressure={0.5*lit,0.08}, ramps={0.25,0.5}, clip=clipm}) end
end
print(#pts)

--@ chunk 47
WALL = rect(340, 500, 440, 440) - LT:grow(2) - RT:grow(2) - FLOOR - H1
local ledgeLit = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.35}, medium=0.1}
local ledgeDk = pile{{"bone black",2},{"ultramarine blue",0.6},{"bone brown",0.5}, medium=0.1}
local function arc(y0, k, x0, x1)
  local pts = {}
  for x=x0,x1,12 do pts[#pts+1] = {x, y0 - k*(x-560)^2} end
  return pts
end
local lit = brush{kind="round", width=2.6, point=0.5}
local dk = brush{kind="flat", width=6}
local levels = {{545,0.00035,4},{650,0.00025,3},{760,0.00014,2.4},{850,0.00006,2}}
for _,L in ipairs(levels) do
  local pts = arc(L[1], L[2], 330, 790)
  local below = {}
  for i,p in ipairs(pts) do below[i] = {p[1], p[2] + L[3]*1.3} end
  dk:load(ledgeDk, 0.7)
  dk:stroke(below, {pressure={0.8,0.8}, clip=WALL})
  lit:load(ledgeLit, 0.6)
  lit:stroke(pts, {pressure={0.55,0.5}, clip=WALL})
end

--@ chunk 48
local apDark = pile{{"bone black",2},{"ultramarine blue",0.7}, medium=0.1}
local apSill = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.3}, medium=0.1}
local apLit = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.3}}
local ribLit = pile{{"burnt sienna",1.5},{"bone brown",1},{"raw sienna",0.6},{"lead white",0.2}, medium=0.1}
local function yarc(y0,k,x) return y0 - k*(x-560)^2 end
local rows = {{650,0.00025,8,6},{760,0.00014,7,5},{850,0.00006,6,4.5}}
local tip = brush{kind="flat", width=4}
local sill = brush{kind="round", width=1.6, point=0.5}
local litb = brush{kind="round", width=3, point=0.3}
local rib = brush{kind="round", width=2.2, point=0.4}
local nlit = 0
for ri,R in ipairs(rows) do
  local xs = uneven(46 - ri*6, 345, 775, 0.5, 0.4, 100+ri)
  for i,x in ipairs(xs) do
    local yt = yarc(R[1], R[2], x) + 6
    if WALL:at(x, yt+R[3]*0.5) > 0.5 then
      local w = R[4]*(0.85+0.3*math.random())
      if i % 3 == 1 then tip:load(apDark, 0.7); sill:load(apSill, 0.5) end
      tip:stroke({{x, yt}, {x, yt + R[3]}}, {pressure={0.75,0.75}, clip=WALL})
      sill:stroke({{x - w*0.6, yt + R[3] + 1.2}, {x + w*0.6, yt + R[3] + 1.2}}, {pressure={0.5,0.4}, clip=WALL})
      if math.random() < 0.07 and nlit < 6 then
        litb:load(apLit, 0.7)
        litb:touch(x, yt + R[3]*0.55, {pressure=0.55})
        nlit = nlit + 1
      end
    end
  end
  -- ribs between this ledge and the one below
  local ybot = (rows[ri+1] and rows[ri+1][1] or 905)
  local rx = uneven(7, 360, 760, 0.6, 0.3, 200+ri)
  for _,x in ipairs(rx) do
    rib:load(ribLit, 0.5)
    rib:stroke({{x, yarc(R[1],R[2],x) + R[3] + 6}, {x, yarc(ybot, 0.0001, x) - 3}}, {pressure={0.4,0.3}, clip=WALL})
  end
end
print(nlit)

--@ chunk 49
print(wait(5*24*60)); for _,p in ipairs({{100,300},{300,600},{850,600},{950,800},{500,760},{400,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 50
print(wait(3*24*60)); for _,p in ipairs({{850,600},{950,800},{800,500}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 51
local function nd(x,y)
  local u, w = (x+340)/690, (y-560)/690
  local q = 1 - u*u - w*w
  if q < 0 then q = 0 end
  return u*0.89 - w*0.26 + math.sqrt(q)*0.37
end
local sh = LT - FLOOR
local ang = function(x,y) return math.atan(y-560, x+340) + math.pi/2 end
work(sh, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=sh, angle=ang,
  load_at=function(x,y)
    local base = lerp(0.95, 0.45, smoothstep(0.7, 0.98, nd(x,y)))
    local mid = 1 - 0.35*math.exp(-((y-720)/220)^2)
    return clamp(base*mid, 0.15, 1) end})
blend(sh, {angle=ang})
-- the back wall: a light dark veil to knock back ledges and ribs
work(WALL, {hand="glaze", pile=darkGlaze, coverage=1.6, fill=true, clip=WALL, angle=1.94, load=0.35})
blend(WALL, {angle=1.94})

--@ chunk 52
print(wait(4*24*60)); for _,p in ipairs({{850,600},{950,800},{500,700},{200,500},{400,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 53
local R = (RT - FLOOR)
work(R, {hand="glaze", pile=darkGlaze, coverage=2.4, fill=true, clip=R, angle=math.pi/2,
  load_at=function(x,y) return lerp(0.35, 0.95, smoothstep(775, 880, x)) * (1 - 0.25*math.exp(-((y-720)/200)^2)) end})
blend(R, {angle=math.pi/2})
print(wait(2*24*60), drying(500,700))

--@ chunk 54
local bm = BEAM * rect(0, 150, 1000, 905)
work(bm, {hand="glaze", pile=warmGlaze, coverage=1.0, load=0.3, angle=BEAM_A, clip=bm})
blend(bm, {angle=BEAM_A})
work(bm, {hand="glaze", pile=veilA, coverage=1.5, angle=BEAM_A, clip=bm,
  load_at=function(x,y) return lerp(0.42, 0.24, smoothstep(220, 650, y)) + 0.14*smoothstep(750, 1010, y) end})
blend(bm, {angle=BEAM_A})

--@ chunk 55
local wide = (BEAM:grow(28)) * rect(0, 150, 1000, 940)
blend(wide, {angle=BEAM_A + 0.06})
blend(wide, {angle=BEAM_A - 0.06})

--@ chunk 56
print(wait(4*24*60)); for _,p in ipairs({{420,1050},{500,700},{600,300},{350,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 57
POOLC = {412, 1064}
function pdist(x,y) local dx=(x-POOLC[1])/150; local dy=(y-POOLC[2])/42; return math.sqrt(dx*dx+dy*dy) end
local zone = ellipse(POOLC[1], POOLC[2], 210, 62)
-- warm mid light, broad and broken
stipple(zone, {pile=rkLit1, width=4, coverage=function(x,y) return 6*(1-smoothstep(0.45, 1.35, pdist(x,y))) end,
  cluster={0.5, 6}, feather=0.6, dips={18, 0.6, 0.3}})
-- the lit flank of the heap above the pool
local flank = H1 * poly({{380,960},{560,1010},{560,1050},{360,1050}}, true)
stipple(flank, {pile=rkLit1, width=3.5, coverage=function(x,y) return 3*(1-smoothstep(0.6, 1.6, pdist(x,y))) end,
  cluster={0.6, 5}, feather=0.6})

--@ chunk 58
print(wait(2*24*60), drying(412,1064))
local sd = brush{kind="round", width=4, point=0.3}
local lt = brush{kind="round", width=3.5, point=0.3}
local cnt = 0
for i=1,900 do
  local a = rand(0, 2*math.pi)
  local rr = math.sqrt(rand(0,1)) * 1.45
  local x = POOLC[1] + rr*150*math.cos(a)
  local y = POOLC[2] + rr*42*math.sin(a)
  local d = pdist(x,y)
  local sz = rand(1.5, 5.5) * (0.7 + 0.5*(y-1000)/100)
  if cnt % 12 == 0 then sd:load(rkDeep, 0.6); lt:load(d < 0.5 and rkLit3 or rkLit2, 0.6) end
  cnt = cnt + 1
  -- shadow side (lower-left), stronger away from centre
  sd:stroke({{x - sz*0.6, y + sz*0.15}, {x + sz*0.2, y + sz*0.45}}, {pressure={0.35 + 0.3*math.min(d,1), 0.2}, ramps={0.2,0.4}})
  -- lit top (upper-right) only inside the light
  if d < 1.0 and math.random() < 0.75 then
    lt:stroke({{x - sz*0.3, y - sz*0.2}, {x + sz*0.5, y - sz*0.35}}, {pressure={0.4*(1-0.5*d), 0.15}, ramps={0.2,0.4}})
  end
end

--@ chunk 59
print(wait(3*24*60), drying(412,1064))
local zone = ellipse(POOLC[1], POOLC[2], 260, 85)
work(zone, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=zone, angle=0.02,
  load_at=function(x,y) return 0.95*smoothstep(0.35, 1.25, pdist(x,y)) end})
blend(zone, {angle=0.02})
blend(zone, {angle=-0.3})

--@ chunk 60
local ring = ellipse(POOLC[1], POOLC[2], 300, 115) - ellipse(POOLC[1], POOLC[2], 200, 55)
blend(ring, {angle=0.02})
blend(ring, {angle=1.2})
blend(ring, {angle=-1.2})

--@ chunk 61
print(wait(3*24*60), drying(412,1064))
local outer = ellipse(POOLC[1], POOLC[2]+2, 175, 50):roughen(10, 40, 3)
local core = ellipse(POOLC[1]-5, POOLC[2], 110, 30):roughen(8, 30, 4)
local heart = ellipse(POOLC[1]-10, POOLC[2]-2, 60, 17):roughen(6, 20, 5)
work(outer, {hand="scumble", pile=rkLit1, coverage=1.6, load=0.35, angle=0.05, length={8,22}})
work(core, {hand="scumble", pile=rkLit2, coverage=1.8, load=0.4, angle=0.05, length={8,20}})
work(heart, {hand="scumble", pile=rkLit3, coverage=1.6, load=0.45, angle=0.05, length={6,16}})

--@ chunk 62
local m = ellipse(POOLC[1], POOLC[2]+2, 200, 62)
blend(m, {angle=0.0})
blend(m, {angle=0.5})
blend(m, {angle=-0.5})

--@ chunk 63
local oval = ellipse(POOLC[1], POOLC[2]+2, 205, 66)
local inner = ellipse(POOLC[1]-8, POOLC[2], 125, 34):roughen(12, 45, 9)
local ring = oval - inner
work(ring, {hand="body", pile=rkDark, coverage=2.6, fill=true, angle=function(x,y) return 0.1*math.sin(x/25) end, length={10,30}, edge="soft"})
local ring2 = oval - ellipse(POOLC[1], POOLC[2]+2, 170, 50):roughen(10, 40, 11)
work(ring2, {hand="body", pile=rkDeep, coverage=2.2, fill=true, angle=0.05, length={10,30}, edge="soft"})

--@ chunk 64
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60), drying(412,1064), drying(300,1090))
rkDark2 = pile{{"bone black",1.5},{"Mars brown",1},{"yellow ochre",0.25}}
rkWarm2 = pile{{"Mars brown",1},{"bone black",0.8},{"lead white",0.35},{"yellow ochre",0.4}}
RUBP = {deep=rkDeep, dark=rkDark2, warm=rkWarm2, lit1=rkLit1, lit2=rkLit2, lit3=rkLit3}
function floorLight(x,y)
  local dx=(x-POOLC[1])/165; local dy=(y-POOLC[2])/48
  local pool = 1 - smoothstep(0.25, 1.5, math.sqrt(dx*dx+dy*dy))
  -- faint scatter near the beam foot, and the heap flank in the beam
  local sc = 0.18 * (1 - smoothstep(0.8, 3.0, math.sqrt(dx*dx+dy*dy)))
  return math.max(pool, sc)
end
FLOORALL = FLOOR + H1
local n = rubble{n=2600, x0=0, x1=1000, y0=870, y1=1010, bias=1, where=FLOORALL, clip=FLOORALL,
  size=function(x,y) return 2.2 + 5*(y-870)/140 end, light=floorLight, piles=RUBP}
print(n)

--@ chunk 65
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local n = rubble{n=4200, x0=0, x1=1000, y0=990, y1=1170, bias=1, where=FLOORALL, clip=FLOORALL,
  size=function(x,y) return 5 + 6*(y-990)/180 end, light=floorLight, piles=RUBP}
print(n)

--@ chunk 66
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local n = rubble{n=2600, x0=0, x1=1000, y0=1150, y1=1333, bias=1, where=FLOORALL, clip=FLOORALL,
  size=function(x,y) return 10 + 10*(y-1150)/183 end, light=floorLight, piles=RUBP}
print(n)

--@ chunk 67
print(wait(3*24*60)); for _,p in ipairs({{412,1064},{380,1040},{460,1030},{420,1060}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 68
function P(ox, oy, pts) local r = {} for i,p in ipairs(pts) do r[i] = {p[1]+ox, p[2]+oy} end return r end
function arkShapes(ox, oy)
  local s = {}
  s.body = poly(P(ox,oy,{{-50,-12},{-46,-23},{-34,-28},{12,-32},{19,-30},{23,-22},{22,-10},{18,-4},{-48,-2}}), true)
  s.top  = poly(P(ox,oy,{{-46,-23},{-34,-28.5},{12,-32.5},{19,-30.5},{15,-25},{-32,-21},{-47,-18}}), true)
  s.under = poly(P(ox,oy,{{-49,-9},{20,-13},{22,-8},{18,-3},{-48,-1}}), true)
  s.cap  = poly(P(ox,oy,{{14,-31},{19,-30},{23,-22},{22,-10},{18,-4},{15,-5},{17,-17}}), true)
  s.band = poly(P(ox,oy,{{-18,-30.5},{-13,-30.8},{-13,-4},{-18,-3.8}}))
  s.panel = poly(P(ox,oy,{{-2,-24},{10,-25},{10,-15},{-2,-14}}))
  s.eye = {ox+7, oy-19}
  return s
end
function figShapes(ox, oy)
  local f = {}
  f.head = poly(P(ox,oy,{{33,-65},{38,-71},{45,-71},{49,-65},{46,-59},{38,-57},{33,-60}}), true)
  f.torso = poly(P(ox,oy,{{53,-29},{67,-31},{69,-48},{68,-57},{63,-63},{52,-63},{44,-60},{43,-52},{48,-40}}), true)
  f.pack = poly(P(ox,oy,{{64,-62},{71,-59},{73,-47},{69,-42},{66,-45}}), true)
  f.armR = ribbon(P(ox,oy,{{47,-58},{33,-47},{20,-36}}), {7.5,6.5,5.5}) + ellipse(ox+18, oy-34, 4, 3.2)
  f.armL = ribbon(P(ox,oy,{{60,-58},{57,-43},{44,-31}}), {7.5,6.5,5.5})
  f.legF = ribbon(P(ox,oy,{{57,-30},{39,-28},{37,-6}}), {11,9.5,8}) + poly(P(ox,oy,{{28,-7},{44,-8},{45,0},{26,0}}), true)
  f.legR = ribbon(P(ox,oy,{{62,-30},{65,-6},{87,-4}}), {11,9,6.5})
  f.all = f.head + f.torso + f.pack + f.armR + f.armL + f.legF + f.legR
  return f
end
AOX, AOY = 405, 1064
ARK = arkShapes(AOX, AOY)
FIG = figShapes(AOX, AOY)
arkFront = pile{{"bone black",1},{"lead white",0.6},{"yellow ochre",0.2},{"ultramarine ash",0.2}}
arkUnder = pile{{"bone black",2},{"Mars brown",0.5},{"lead white",0.15}}
arkTop   = pile{{"lead white",3},{"yellow ochre",0.5},{"bone black",0.15}}
arkCap   = pile{{"lead white",2},{"bone black",0.35},{"yellow ochre",0.4}}
frameDark = pile{{"bone black",2},{"Mars brown",0.6},{"lead white",0.2}}
local t4 = "filbert 4"
work(ARK.body, {hand="body", tool=t4, pile=arkFront, coverage=3, fill=true, angle=-0.06, clip=true})
work(ARK.under, {hand="body", tool=t4, pile=arkUnder, coverage=3, fill=true, angle=-0.06, clip=ARK.body})
work(ARK.top, {hand="body", tool="filbert 3", pile=arkTop, coverage=3, fill=true, angle=-0.08, clip=ARK.body})
work(ARK.cap, {hand="body", tool="filbert 3", pile=arkCap, coverage=3, fill=true, angle=1.5, clip=ARK.body})
work(FIG.all, {hand="body", tool=t4, pile=frameDark, coverage=3.2, fill=true, angle=1.4, clip=true})

--@ chunk 69
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
function floorLight2(x,y)
  local dx=(x-430)/140; local dy=(y-1030)/48
  local d = math.sqrt(dx*dx+dy*dy)
  return math.max(floorLight(x,y), 1 - smoothstep(0.2, 1.35, d))
end
local keep = FLOORALL - FIG.all:grow(1.5) - ARK.body:grow(1.5)
local n = rubble{n=1500, x0=290, x1=580, y0=975, y1=1080, bias=1, where=keep * ellipse(430,1030,170,60), clip=keep,
  size=function(x,y) return 3.2 + 4*(y-975)/105 end, light=floorLight2, piles=RUBP}
print(n)

--@ chunk 70
print(wait(3*24*60)); for _,p in ipairs({{380,1050},{460,1020},{440,1000},{400,1040}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 71
print(wait(4*24*60)); for _,p in ipairs({{380,1050},{460,1020},{440,1000},{400,1040}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 72
function P(ox, oy, pts) local r = {} for i,p in ipairs(pts) do r[i] = {p[1]+ox, p[2]+oy} end return r end
function arkShapes(ox, oy)
  local s = {}
  s.body = poly(P(ox,oy,{{-50,-12},{-46,-23},{-34,-28},{12,-32},{19,-30},{23,-22},{22,-10},{18,-4},{-48,-2}}), true)
  s.top  = poly(P(ox,oy,{{-46,-23},{-34,-28.5},{12,-32.5},{19,-30.5},{15,-25},{-32,-21},{-47,-18}}), true)
  s.under = poly(P(ox,oy,{{-49,-9},{20,-13},{22,-8},{18,-3},{-48,-1}}), true)
  s.cap  = poly(P(ox,oy,{{14,-31},{19,-30},{23,-22},{22,-10},{18,-4},{15,-5},{17,-17}}), true)
  s.band = poly(P(ox,oy,{{-18,-30.5},{-13,-30.8},{-13,-4},{-18,-3.8}}))
  s.panel = poly(P(ox,oy,{{-2,-24},{10,-25},{10,-15},{-2,-14}}))
  s.eye = {ox+7, oy-19}
  return s
end
function figShapes(ox, oy)
  local f = {}
  local function Q(pts) return poly(P(ox,oy,pts), true) end
  f.shinR = Q({{60,-10},{68,-12},{82,-10},{86,-11},{91,-3},{90,0},{60,0}})
  f.thighR = Q({{57,-34},{69,-35},{70,-10},{60,-8}})
  f.thighF = Q({{58,-38},{56,-27},{40,-24},{35,-29},{37,-36}})
  f.shinF = Q({{34,-32},{42,-30},{41,-8},{33,-8}})
  f.bootF = Q({{27,-9},{43,-10},{45,0},{25,0},{25,-4}})
  f.torso = Q({{52,-32},{68,-33},{70,-45},{69,-56},{56,-58},{46,-55},{47,-44},{51,-38}})
  f.padN = ellipse(ox+50, oy-56, 6.5, 5)
  f.padF = ellipse(ox+64, oy-60, 7, 5)
  f.pack = Q({{63,-64},{73,-61},{75,-48},{70,-42},{66,-46}})
  f.head = Q({{35,-63},{36,-70},{42,-73.5},{48.5,-71},{50,-65},{46,-60.5},{39,-59.5}})
  f.armR = ribbon(P(ox,oy,{{48,-55},{36,-44.5},{22,-36.5}}), {7,6.5,5.5}) + Q({{23,-40},{16,-36},{15,-32},{21,-32}})
  f.armL = ribbon(P(ox,oy,{{62,-57},{60,-45},{46,-35}}), {7,6.5,5.5})
  f.all = f.shinR + f.thighR + f.thighF + f.shinF + f.bootF + f.torso + f.padN + f.padF + f.pack + f.head + f.armR + f.armL
  return f
end

function figShapesOld(ox, oy)
  local f = {}
  f.head = poly(P(ox,oy,{{33,-65},{38,-71},{45,-71},{49,-65},{46,-59},{38,-57},{33,-60}}), true)
  f.torso = poly(P(ox,oy,{{53,-29},{67,-31},{69,-48},{68,-57},{63,-63},{52,-63},{44,-60},{43,-52},{48,-40}}), true)
  f.pack = poly(P(ox,oy,{{64,-62},{71,-59},{73,-47},{69,-42},{66,-45}}), true)
  f.armR = ribbon(P(ox,oy,{{47,-58},{33,-47},{20,-36}}), {7.5,6.5,5.5}) + ellipse(ox+18, oy-34, 4, 3.2)
  f.armL = ribbon(P(ox,oy,{{60,-58},{57,-43},{44,-31}}), {7.5,6.5,5.5})
  f.legF = ribbon(P(ox,oy,{{57,-30},{39,-28},{37,-6}}), {11,9.5,8}) + poly(P(ox,oy,{{28,-7},{44,-8},{45,0},{26,0}}), true)
  f.legR = ribbon(P(ox,oy,{{62,-30},{65,-6},{87,-4}}), {11,9,6.5})
  f.all = f.head + f.torso + f.pack + f.armR + f.armL + f.legF + f.legR
  return f
end
FIG = figShapes(AOX, AOY)
local OLD = figShapesOld(AOX, AOY)
local left = (OLD.all - FIG.all:grow(0.5))
print(left:area(), FIG.all:area(), OLD.all:area())

--@ chunk 73
function P(ox, oy, pts) local r = {} for i,p in ipairs(pts) do r[i] = {p[1]+ox, p[2]+oy} end return r end
function arkShapes(ox, oy)
  local s = {}
  s.body = poly(P(ox,oy,{{-50,-12},{-46,-23},{-34,-28},{12,-32},{19,-30},{23,-22},{22,-10},{18,-4},{-48,-2}}), true)
  s.top  = poly(P(ox,oy,{{-46,-23},{-34,-28.5},{12,-32.5},{19,-30.5},{15,-25},{-32,-21},{-47,-18}}), true)
  s.under = poly(P(ox,oy,{{-49,-9},{20,-13},{22,-8},{18,-3},{-48,-1}}), true)
  s.cap  = poly(P(ox,oy,{{14,-31},{19,-30},{23,-22},{22,-10},{18,-4},{15,-5},{17,-17}}), true)
  s.band = poly(P(ox,oy,{{-18,-30.5},{-13,-30.8},{-13,-4},{-18,-3.8}}))
  s.panel = poly(P(ox,oy,{{-2,-24},{10,-25},{10,-15},{-2,-14}}))
  s.eye = {ox+7, oy-19}
  return s
end
function figShapes(ox, oy)
  local f = {}
  local function Q(pts) return poly(P(ox,oy,pts), true) end
  f.shinR = Q({{60,-10},{68,-12},{82,-10},{86,-11},{91,-3},{90,0},{60,0}})
  f.thighR = Q({{57,-34},{69,-35},{70,-10},{60,-8}})
  f.thighF = Q({{58,-38},{56,-27},{40,-24},{35,-29},{37,-36}})
  f.shinF = Q({{34,-32},{42,-30},{41,-8},{33,-8}})
  f.bootF = Q({{27,-9},{43,-10},{45,0},{25,0},{25,-4}})
  f.torso = Q({{52,-32},{68,-33},{70,-45},{69,-56},{56,-58},{46,-55},{47,-44},{51,-38}})
  f.padN = ellipse(ox+50, oy-56, 6.5, 5)
  f.padF = ellipse(ox+64, oy-60, 7, 5)
  f.pack = Q({{63,-64},{73,-61},{75,-48},{70,-42},{66,-46}})
  f.head = Q({{35,-63},{36,-70},{42,-73.5},{48.5,-71},{50,-65},{46,-60.5},{39,-59.5}})
  f.armR = ribbon(P(ox,oy,{{48,-55},{36,-44.5},{22,-36.5}}), {7,6.5,5.5}) + Q({{23,-40},{16,-36},{15,-32},{21,-32}})
  f.armL = ribbon(P(ox,oy,{{62,-57},{60,-45},{46,-35}}), {7,6.5,5.5})
  f.all = f.shinR + f.thighR + f.thighF + f.shinF + f.bootF + f.torso + f.padN + f.padF + f.pack + f.head + f.armR + f.armL
  return f
end

function figShapesOld(ox, oy)
  local f = {}
  f.head = poly(P(ox,oy,{{33,-65},{38,-71},{45,-71},{49,-65},{46,-59},{38,-57},{33,-60}}), true)
  f.torso = poly(P(ox,oy,{{53,-29},{67,-31},{69,-48},{68,-57},{63,-63},{52,-63},{44,-60},{43,-52},{48,-40}}), true)
  f.pack = poly(P(ox,oy,{{64,-62},{71,-59},{73,-47},{69,-42},{66,-45}}), true)
  f.armR = ribbon(P(ox,oy,{{47,-58},{33,-47},{20,-36}}), {7.5,6.5,5.5}) + ellipse(ox+18, oy-34, 4, 3.2)
  f.armL = ribbon(P(ox,oy,{{60,-58},{57,-43},{44,-31}}), {7.5,6.5,5.5})
  f.legF = ribbon(P(ox,oy,{{57,-30},{39,-28},{37,-6}}), {11,9.5,8}) + poly(P(ox,oy,{{28,-7},{44,-8},{45,0},{26,0}}), true)
  f.legR = ribbon(P(ox,oy,{{62,-30},{65,-6},{87,-4}}), {11,9,6.5})
  f.all = f.head + f.torso + f.pack + f.armR + f.armL + f.legF + f.legR
  return f
end
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local OLD = figShapesOld(AOX, AOY)
local left = (OLD.all - FIG.all):grow(1.2) - FIG.all - ARK.body
work(left, {hand="detail", pile=rkWarm2, coverage=3, fill=true, angle=0.1, clip=true})
local n = rubble{n=500, x0=AOX+10, x1=AOX+100, y0=AOY-80, y1=AOY+5, bias=1, where=left:grow(2), clip=left,
  size=function(x,y) return 3.5 end, light=floorLight2, piles=RUBP}
print(n)
work(FIG.all, {hand="body", tool="filbert 4", pile=frameDark, coverage=3.2, fill=true, angle=1.4, clip=true})

--@ chunk 74
print(wait(4*24*60)); for _,p in ipairs({{450,1010},{460,1040},{400,1040}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 75
local ox, oy = AOX, AOY
local function L(pts) return P(ox, oy, pts) end
frostLit = pile{{"lead white",5},{"lemon chrome",0.15}}
frostCool = pile{{"lead white",3},{"cerulean blue",0.35},{"bone black",0.1}}
frostMid = pile{{"lead white",3},{"yellow ochre",0.3},{"bone black",0.15},{"cerulean blue",0.1}}
local seam = pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.2}}
-- band ring: dark seams either side, a pale ridge between
local b = brush{kind="round", width=1.2, point=0.8}
b:load(seam, 0.6)
b:stroke(L({{-18.5,-30},{-18.5,-18},{-18.3,-5}}), {pressure={0.5,0.4}, clip=ARK.body})
b:stroke(L({{-12.5,-30.5},{-12.6,-18},{-12.7,-4.5}}), {pressure={0.5,0.4}, clip=ARK.body})
b:load(seam, 0.6)
-- panel recess
b:stroke(L({{-2,-24},{10,-25},{10,-15},{-2,-14},{-2,-24}}), {pressure={0.45,0.45}, clip=ARK.body})
work(ARK.panel:shrink(0.8), {hand="detail", pile=pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.3}}, coverage=3, fill=true, clip=true})
-- stencil marks: faded lettering on the front
local st = brush{kind="round", width=0.9, point=0.9}
st:load(pile{{"bone black",1},{"lead white",0.3}}, 0.4)
local x = -42
for i=1,9 do
  local w = rand(1.2, 2.4)
  st:stroke(L({{x, -15.5},{x + w*0.3, -12.5}}), {pressure={0.4,0.3}, clip=ARK.body})
  if math.random() < 0.5 then st:stroke(L({{x, -15.5},{x + w, -15.6}}), {pressure={0.35,0.3}, clip=ARK.body}) end
  x = x + w + rand(0.6, 1.6)
  if i == 5 then x = x + 2.5 end
end
-- faded red band near the left end
local rb = brush{kind="flat", width=3}
rb:load(pile{{"red earth",1},{"lead white",0.5},{"bone black",0.3}, medium=0.3}, 0.4)
rb:stroke(L({{-38,-26},{-38.5,-6}}), {pressure={0.5,0.4}, clip=ARK.body})

--@ chunk 76
local ox, oy = AOX, AOY
local rim = (ARK.top:grow(1.5) - ARK.body:shrink(6)) * mask(function(x,y) return y < oy - 18 and 1 or 0 end)
-- frost crust: cool in its own shade, then lit on top
stipple(ARK.top:grow(1), {pile=frostCool, width=1.6, coverage=5, cluster={0.5, 3}, feather=0.3, dips={14,0.5,0.3}})
stipple(ARK.top * mask(function(x,y) return y < oy - 24 + 0.06*(x-ox) and 1 or 0 end), {pile=frostMid, width=1.4, coverage=5, cluster={0.5,3}})
-- frost creeping down the front face in patches
local creep = ARK.body * mask(function(x,y) return y < oy - 15 and 1 or 0 end) * (noise{seed=8, period=9}:at01(0,0) and mask(function(x,y) local n=noise{seed=8, period=9}; return n:at01(x,y) > 0.55 and 1 or 0 end))
stipple(creep, {pile=frostCool, width=1.2, coverage=3, cluster={0.6,2}, feather=0.5})

--@ chunk 77
local function nd(x,y,L)
  local u, w = (x+340)/690, (y-560)/690
  local q = 1 - u*u - w*w
  if q < 0 then q = 0 end
  return u*L[1] + w*L[2] + math.sqrt(q)*L[3]
end
local Ls = {{0.82,-0.52,0.24},{0.85,-0.45,0.27}}
for _,L in ipairs(Ls) do
  local l = math.sqrt(L[1]^2+L[2]^2+L[3]^2); L = {L[1]/l, L[2]/l, L[3]/l}
  local row = ""
  for _,y in ipairs({100,200,300,400,500,600,700,800}) do
    local best, bx = -1, 0
    for x=0,345,5 do if LT:at(x,y) > 0.5 then local v = nd(x,y,L); if v > best then best, bx = v, x end end end
    row = row .. string.format(" y%d:%.2f@%d", y, best, bx)
  end
  print(row)
end

--@ chunk 78
GA = math.pi * (3 - math.sqrt(5))
-- Fibonacci-sphere scale plates on a sphere (center cx,cy, radius R in canvas units)
-- o.rot: rotation of the pole; o.light: unit vector (z toward viewer)
-- o.pickBody(nd,p) -> brush ; o.edge, o.shadow brushes ; o.reload(nd,p) loads brushes ; o.edgeLight(nd,p) -> 0..1
function sphere_plates(o)
  local N, R, cx, cy = o.N, o.R, o.cx, o.cy
  local pts = {}
  for n=0,N-1 do
    local zz = 1 - 2*(n+0.5)/N
    local rr = math.sqrt(1-zz*zz)
    local th = n*GA
    local v = o.rot({rr*math.cos(th), rr*math.sin(th), zz})
    if v[3] > 0.02 then
      local x, y = cx + R*v[1], cy + R*v[2]
      if x > -40 and x < 1040 and y > -40 and y < 1380 and (not o.ok or o.ok:at(x,y) > 0.5) then
        pts[#pts+1] = {x=x, y=y, v=v, n=n}
      end
    end
  end
  table.sort(pts, function(a,b) return a.v[3] < b.v[3] end)
  local spacing = R * math.sqrt(4*math.pi/N)
  local pole = o.rot({0,0,1})
  local k = 0
  for _,p in ipairs(pts) do
    local v = p.v
    local t = {pole[2]*v[3]-pole[3]*v[2], pole[3]*v[1]-pole[1]*v[3], pole[1]*v[2]-pole[2]*v[1]}
    local tl = math.sqrt(t[1]^2+t[2]^2+t[3]^2)+1e-6
    t = {t[1]/tl, t[2]/tl, t[3]/tl}
    local m = {v[2]*t[3]-v[3]*t[2], v[3]*t[1]-v[1]*t[3], v[1]*t[2]-v[2]*t[1]}
    local s = spacing * (0.92 + 0.16*math.random())
    local h = s*0.55
    local function Q(a, b) return {p.x + a*t[1] + b*m[1], p.y + a*t[2] + b*m[2]} end
    local L = o.light
    local nd = v[1]*L[1] + v[2]*L[2] + v[3]*L[3]
    local foreshort = math.sqrt(t[1]^2+t[2]^2)
    if foreshort > 0.15 then
      if k % 4 == 0 then o.reload(nd, p) end
      k = k + 1
      local bb = o.pickBody(nd, p)
      bb:stroke({Q(-h*0.8, 0), Q(0, -h*0.12), Q(h*0.8, 0)}, {pressure={0.8,0.7}, ramps={0.15,0.25}, clip=o.clip})
      o.shadow:stroke({Q(-h*0.9, -h*0.5), Q(0, -h*0.62), Q(h*0.9, -h*0.5)}, {pressure={0.45,0.12}, ramps={0.2,0.4}, clip=o.clip})
      local lit = o.edgeLight(nd, p)
      if lit > 0.05 then
        o.edge:stroke({Q(-h*0.8, h*0.3), Q(0, h*0.5), Q(h*0.8, h*0.3)}, {pressure={0.5*lit,0.08}, ramps={0.25,0.5}, clip=o.clip})
      end
    end
  end
  return k
end
function rotXYZ(ax, ay, az)
  local cxa, sxa, cya, sya, cza, sza = math.cos(ax), math.sin(ax), math.cos(ay), math.sin(ay), math.cos(az), math.sin(az)
  return function(v)
    local x,y,z = v[1],v[2],v[3]
    y, z = y*cxa - z*sxa, y*sxa + z*cxa
    x, z = x*cya + z*sya, -x*sya + z*cya
    x, y = x*cza - y*sza, x*sza + y*cza
    return {x,y,z}
  end
end
local L1 = {0.82,-0.52,0.24}; do local l = math.sqrt(L1[1]^2+L1[2]^2+L1[3]^2); L1 = {L1[1]/l, L1[2]/l, L1[3]/l} end
LT_L = L1
function ltnd(x,y)
  local u, w = (x+340)/690, (y-560)/690
  local q = 1 - u*u - w*w
  if q < 0 then q = 0 end
  return u*L1[1] + w*L1[2] + math.sqrt(q)*L1[3]
end
local cres = (LT - FLOOR) * mask(function(x,y) return ltnd(x,y) > 0.84 and 1 or 0 end)
local bodyMid = pile{{"burnt sienna",2},{"bone brown",0.6},{"raw sienna",1}, medium=0.05}
local bodyLit = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.5}, medium=0.05}
local bodyHot = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",1.2},{"cadmium yellow",0.2}}
local edgeLit = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}
local edgeHot = pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}
local shP = pile{{"bone black",2},{"Mars brown",0.6}, medium=0.05}
local B = {mid=brush("filbert",20), lit=brush("filbert",20), hot=brush("filbert",20)}
local edge = brush{kind="round", width=3.5, point=0.7}
local shadow = brush{kind="round", width=4.5, point=0.5}
local n = sphere_plates{N=4900, R=690, cx=-340, cy=560, rot=rotXYZ(0.087, 0.79, 0),
  light=L1, ok=cres, clip=LT - FLOOR, edge=edge, shadow=shadow,
  pickBody=function(nd,p) if nd > 0.96 then return B.hot elseif nd > 0.9 then return B.lit else return B.mid end end,
  reload=function(nd,p) B.mid:load(bodyMid,0.6); B.lit:load(bodyLit,0.6); B.hot:load(bodyHot,0.6);
    edge:load(nd > 0.95 and edgeHot or edgeLit, 0.55); shadow:load(shP,0.55) end,
  edgeLight=function(nd,p) return clamp((nd-0.84)*7, 0, 1) end}
print(n)

--@ chunk 79
print(wait(2*24*60)); for _,p in ipairs({{450,1010},{460,1040},{470,1030},{250,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 80
print(wait(3*24*60)); for _,p in ipairs({{450,1010},{470,1030},{250,250},{300,400}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 81
function figDetail(ox, oy, rimP, bounceP, plateP, clipm)
  local function L(pts) return P(ox, oy, pts) end
  local rim = brush{kind="round", width=1.3, point=0.9}
  local bo = brush{kind="round", width=3.2, point=0.3}
  local pl = brush{kind="filbert", width=3}
  -- dim plates in reflected light (low contrast, broad)
  pl:load(plateP, 0.5)
  pl:stroke(L({{45,-55},{37,-48}}), {pressure={0.6,0.5}, clip=clipm})
  pl:stroke(L({{54,-33},{44,-31}}), {pressure={0.6,0.5}, clip=clipm})
  pl:load(plateP, 0.5)
  pl:stroke(L({{61,-54},{62,-44}}), {pressure={0.5,0.4}, clip=clipm})
  -- warm bounce from the lit floor, on the faces turned to the ark and down
  bo:load(bounceP, 0.45)
  bo:stroke(L({{44,-55},{44,-48},{47,-41}}), {pressure={0.4,0.25}, clip=clipm})
  bo:stroke(L({{34,-24},{33.5,-9}}), {pressure={0.4,0.25}, clip=clipm})
  bo:stroke(L({{36,-58},{42,-57.5}}), {pressure={0.35,0.2}, clip=clipm})
  -- rim light, thin and broken, only where the form turns up to the oculus
  rim:load(rimP, 0.6)
  rim:stroke(L({{39,-71},{43,-71.6},{46.5,-70.5},{48.5,-67}}), {pressure={0.55,0.15}, ramps={0.15,0.5}})
  rim:stroke(L({{55,-63.4},{60,-63.8},{64,-62.6}}), {pressure={0.5,0.1}, ramps={0.2,0.5}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{66,-61.5},{70.5,-59.5},{72.3,-55}}), {pressure={0.55,0.1}, ramps={0.1,0.5}})
  rim:stroke(L({{68.5,-30},{69.8,-20}}), {pressure={0.4,0.05}, ramps={0.1,0.6}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{72,-8.6},{80,-7.6},{86,-6.6}}), {pressure={0.4,0.05}, ramps={0.2,0.6}})
  rim:stroke(L({{47,-59.6},{40,-53.5},{33,-48.5}}), {pressure={0.45,0.05}, ramps={0.1,0.6}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{56,-35.4},{48,-34.2}}), {pressure={0.4,0.05}, ramps={0.1,0.6}})
  -- knee joint glint
  rim:touch(ox+39, oy-33.5, {pressure=0.35})
end
rimP = pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}
bounceP = pile{{"Mars brown",1},{"yellow ochre",1},{"lead white",0.4},{"bone black",0.4}}
plateP = pile{{"bone black",1.5},{"Mars brown",1},{"lead white",0.3},{"yellow ochre",0.3}}
figDetail(AOX, AOY, rimP, bounceP, plateP, FIG.all)

--@ chunk 82
local ox, oy = AOX, AOY
local function L(pts) return P(ox, oy, pts) end
coldCore = pile{{"lead white",4},{"cerulean blue",0.25},{"emerald green",0.08}}
coldHalo = pile{{"lead white",2},{"emerald green",0.4},{"cerulean blue",0.6}}
coldDim  = pile{{"cerulean blue",1},{"lead white",1},{"viridian",0.3},{"bone black",0.2}}
-- readout: a soft cold square of light in the panel, a few lines of text, one bright point
local pan = ARK.panel:shrink(1.6)
work(pan, {hand="detail", tool={kind="round", width=1.6, point=0.5}, pile=coldDim, coverage=1.6, fill=false, clip=true, angle=0})
local t = brush{kind="round", width=0.8, point=0.9}
t:load(coldHalo, 0.5)
for i=0,3 do
  local y = -22 + i*1.9
  local w = ({7.5, 5, 6.5, 3.5})[i+1]
  t:stroke(L({{0.4, y},{0.4 + w, y - 0.05}}), {pressure={0.45,0.4}, clip=pan})
end
local c = brush{kind="round", width=2.2, point=0.4}
c:load(coldCore, 0.7)
c:touch(ox + 7.6, oy - 16.5, {pressure=0.55})
-- frost glints on top, in the warm light
local g = brush{kind="round", width=1.3, point=0.8}
g:load(frostLit, 0.6)
local pts = {{-44,-24.5},{-39,-26.5},{-33,-28},{-27,-28.6},{-20,-29.6},{-10,-30.8},{-4,-31.2},{3,-31.8},{9,-32.2},{14,-31.6}}
for i,p in ipairs(pts) do
  if i % 4 == 0 then g:load(frostLit, 0.6) end
  g:stroke(L({{p[1], p[2]+0.3},{p[1] + rand(1.5,3.5), p[2] - 0.1}}), {pressure={0.5,0.2}})
end
for i=1,7 do g:touch(ox + rand(-44, 15), oy + rand(-30, -24), {pressure=rand(0.2,0.45)}) end
-- cold light catching the underside of the frame's hand
local h = brush{kind="round", width=1.2, point=0.8}
h:load(coldHalo, 0.5)
h:stroke(L({{16.5,-32.8},{20.5,-32.5}}), {pressure={0.4,0.2}})

--@ chunk 83
veilW = pile{{"lead white",1},{"red lead",0.6},{"Indian yellow",0.5}, medium=0.85}
local core = BEAMCORE * rect(0, 190, 1000, 860)
work(core, {hand="glaze", pile=veilW, coverage=1.3, angle=BEAM_A, clip=core,
  load_at=function(x,y) return lerp(0.38, 0.12, smoothstep(200, 750, y)) + 0.1*smoothstep(850, 1040, y) end})
blend(BEAM * rect(0, 190, 1000, 860), {angle=BEAM_A})

--@ chunk 84
print(wait(4*24*60)); for _,p in ipairs({{450,1010},{430,1040},{250,250},{300,400},{600,500}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 85
frameDark2 = pile{{"bone black",2},{"Mars brown",0.8},{"lead white",0.25}}
work(FIG.all, {hand="body", tool="filbert 3", pile=frameDark2, coverage=3.4, fill=true, angle=1.4, clip=true})
work(ARK.under:grow(0.5) * ARK.body, {hand="body", tool="filbert 3", pile=arkUnder, coverage=3, fill=true, angle=-0.06, clip=true})

--@ chunk 86
print(wait(4*24*60)); for _,p in ipairs({{450,1010},{430,1040},{380,1060},{250,250},{300,400}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 87
print(wait(6*24*60)); for _,p in ipairs({{450,1010},{380,1060},{250,250},{300,400},{150,150}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 88
local ox, oy = AOX, AOY
local function L(pts) return P(ox, oy, pts) end
local front = ARK.body - ARK.top - ARK.under:shrink(1)
arkFront2 = pile{{"bone black",1},{"lead white",0.8},{"ultramarine ash",0.35},{"yellow ochre",0.15}}
work(front, {hand="body", tool="filbert 3", pile=arkFront2, coverage=3, fill=true, angle=-0.05, clip=true})
-- the top: frost again, cool first then lit
stipple(ARK.top:grow(0.8), {pile=frostCool, width=1.5, coverage=5, cluster={0.5, 3}, feather=0.3, dips={14,0.5,0.3}})

--@ chunk 89
print(wait(3*24*60)); for _,p in ipairs({{380,1045},{400,1035},{420,1050}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 90
local sh = LT - FLOOR
local ang = function(x,y) return math.atan(y-560, x+340) + math.pi/2 end
local zone = sh * mask(function(x,y) return ltnd(x,y) > 0.8 and 1 or 0 end):blur(15)
work(zone, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=sh, angle=ang,
  load_at=function(x,y) local v = ltnd(x,y); return lerp(0.85, 0.3, smoothstep(0.86, 0.99, v)) end})
blend(zone, {angle=ang})
blend(zone, {angle=function(x,y) return ang(x,y) + 0.8 end})

--@ chunk 91
for _,p in ipairs({{380,1045},{420,1050},{360,1050},{450,1010}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 92
function figDetail(ox, oy, rimP, bounceP, plateP, clipm)
  local function L(pts) return P(ox, oy, pts) end
  local rim = brush{kind="round", width=1.3, point=0.9}
  local bo = brush{kind="round", width=3.2, point=0.3}
  local pl = brush{kind="filbert", width=3}
  -- dim plates in reflected light (low contrast, broad)
  pl:load(plateP, 0.5)
  pl:stroke(L({{45,-55},{37,-48}}), {pressure={0.6,0.5}, clip=clipm})
  pl:stroke(L({{54,-33},{44,-31}}), {pressure={0.6,0.5}, clip=clipm})
  pl:load(plateP, 0.5)
  pl:stroke(L({{61,-54},{62,-44}}), {pressure={0.5,0.4}, clip=clipm})
  -- warm bounce from the lit floor, on the faces turned to the ark and down
  bo:load(bounceP, 0.45)
  bo:stroke(L({{44,-55},{44,-48},{47,-41}}), {pressure={0.4,0.25}, clip=clipm})
  bo:stroke(L({{34,-24},{33.5,-9}}), {pressure={0.4,0.25}, clip=clipm})
  bo:stroke(L({{36,-58},{42,-57.5}}), {pressure={0.35,0.2}, clip=clipm})
  -- rim light, thin and broken, only where the form turns up to the oculus
  rim:load(rimP, 0.6)
  rim:stroke(L({{39,-71},{43,-71.6},{46.5,-70.5},{48.5,-67}}), {pressure={0.55,0.15}, ramps={0.15,0.5}})
  rim:stroke(L({{55,-63.4},{60,-63.8},{64,-62.6}}), {pressure={0.5,0.1}, ramps={0.2,0.5}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{66,-61.5},{70.5,-59.5},{72.3,-55}}), {pressure={0.55,0.1}, ramps={0.1,0.5}})
  rim:stroke(L({{68.5,-30},{69.8,-20}}), {pressure={0.4,0.05}, ramps={0.1,0.6}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{72,-8.6},{80,-7.6},{86,-6.6}}), {pressure={0.4,0.05}, ramps={0.2,0.6}})
  rim:stroke(L({{47,-59.6},{40,-53.5},{33,-48.5}}), {pressure={0.45,0.05}, ramps={0.1,0.6}})
  rim:load(rimP, 0.6)
  rim:stroke(L({{56,-35.4},{48,-34.2}}), {pressure={0.4,0.05}, ramps={0.1,0.6}})
  -- knee joint glint
  rim:touch(ox+39, oy-33.5, {pressure=0.35})
end
figDetail(AOX, AOY, rimP, bounceP, plateP, FIG.all)
print(wait(2*24*60))
for _,p in ipairs({{380,1045},{420,1050},{360,1050}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 93
print(wait(3*24*60)); for _,p in ipairs({{420,1050},{360,1050},{450,1010},{465,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 94
local inner = FIG.all:shrink(1.0)
work(inner, {hand="detail", tool={kind="round", width=2.5, point=0.3}, pile=frameDark2, coverage=3.4, fill=true, angle=1.4, clip=true})
local F = FIG.all
local sh = mask(function(x,y) return F:at(x+1.8, y-1.8) end)
RIMM = (F - sh) * mask(function(x,y) return y < AOY - 7 and 1 or 0 end)
print(RIMM:area())

--@ chunk 95
local ox, oy = AOX, AOY
local function L(pts) return P(ox, oy, pts) end
local seam = pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.2}}
local b = brush{kind="round", width=1.1, point=0.8}
b:load(seam, 0.6)
b:stroke(L({{-18.5,-26},{-18.4,-15},{-18.3,-6}}), {pressure={0.5,0.4}, clip=ARK.body})
b:stroke(L({{-12.5,-27},{-12.6,-16},{-12.7,-5.5}}), {pressure={0.5,0.4}, clip=ARK.body})
b:load(seam, 0.6)
b:stroke(L({{-2,-23},{10,-24},{10,-14},{-2,-13.5},{-2,-23}}), {pressure={0.45,0.45}, clip=ARK.body})
b:stroke(L({{-46,-14},{-30,-15},{0,-16.5}}), {pressure={0.25,0.2}, clip=ARK.body})
-- ridge highlight on the band (catching bounce)
local hl = brush{kind="round", width=1.0, point=0.8}
hl:load(pile{{"lead white",2},{"bone black",0.2},{"yellow ochre",0.2}}, 0.5)
hl:stroke(L({{-15.5,-26},{-15.6,-16},{-15.7,-6}}), {pressure={0.35,0.25}, clip=ARK.body})
-- panel: dark glass, a cold screen of lines, one bright point
local pan = ARK.panel:shrink(0.8)
work(pan, {hand="detail", tool={kind="round", width=1.4, point=0.5}, pile=pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.2}}, coverage=3, fill=true, clip=true, angle=0})
work(ARK.panel:shrink(1.8), {hand="detail", tool={kind="round", width=1.2, point=0.5}, pile=coldDim, coverage=1.2, fill=false, clip=true, angle=0})
local t = brush{kind="round", width=0.8, point=0.9}
t:load(coldHalo, 0.55)
for i=0,3 do
  local y = -21.5 + i*1.9
  local w = ({7.5, 4.5, 6.5, 3})[i+1]
  t:stroke(L({{0.6, y},{0.6 + w, y - 0.05}}), {pressure={0.45,0.4}, clip=ARK.panel:shrink(1.2)})
end
local c = brush{kind="round", width=2.2, point=0.4}
c:load(coldCore, 0.7)
c:touch(ox + 7.6, oy - 16.2, {pressure=0.55})
-- faded red band
local rb = brush{kind="flat", width=3}
rb:load(pile{{"red earth",1},{"lead white",0.5},{"bone black",0.3}, medium=0.3}, 0.45)
rb:stroke(L({{-38,-21},{-38.4,-6}}), {pressure={0.5,0.4}, clip=ARK.body})

--@ chunk 96
print(wait(4*24*60)); for _,p in ipairs({{410,1045},{450,1010},{465,1000},{470,1040}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 97
local keep = ellipse(POOLC[1]+10, POOLC[2]-15, 230, 100):blur(30)
local F = (FLOORALL - FIG.all:grow(3) - ARK.body:grow(3)) * rect(0, 1080, 1000, 260) + (FLOORALL * rect(560, 880, 440, 200) - FIG.all:grow(3))
work(F, {hand="glaze", pile=darkGlaze, coverage=2.0, fill=true, clip=F, angle=0.03,
  load_at=function(x,y)
    local dx=(x-POOLC[1])/240; local dy=(y-POOLC[2]+10)/85
    local d = math.sqrt(dx*dx+dy*dy)
    return 0.85*smoothstep(0.9, 2.2, d) end})
blend(F, {angle=0.03})

--@ chunk 98
local R = (RT - FLOOR)
work(R, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=R, angle=math.pi/2,
  load_at=function(x,y) return lerp(0.1, 0.95, smoothstep(780, 900, x)) * (1 - 0.3*math.exp(-((y-650)/180)^2)) end})
blend(R, {angle=math.pi/2})

--@ chunk 99
print(wait(2*24*60)); for _,p in ipairs({{410,1045},{450,1010},{470,1040},{440,1030}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 100
local GA = math.pi * (3 - math.sqrt(5))
local bodyLit = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.4}, medium=0.05}
local bodyMid = pile{{"burnt sienna",2},{"bone brown",0.6},{"raw sienna",1}, medium=0.05}
local edgeHot = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}
local shP = pile{{"bone black",2},{"Mars brown",0.6}, medium=0.05}
local B = {lit=brush("filbert",16), mid=brush("filbert",16)}
local edge = brush{kind="round", width=3.0, point=0.7}
local shadow = brush{kind="round", width=4, point=0.5}
local R, AX, s = 250, 1020, 28
local dy = s*s/(2*math.pi*R)
local clipm = (RT - FLOOR) * rect(760, 440, 300, 600)
local pts = {}
local n = 0
local y = 452
while y < 960 do
  local phi = (n*GA) % (2*math.pi)
  if phi > math.pi then phi = phi - 2*math.pi end
  if math.cos(phi) > 0.08 then
    local x = AX + R*math.sin(phi)
    if x < 815 and clipm:at(math.max(x,773), y) > 0.5 then pts[#pts+1] = {x=x, y=y, phi=phi} end
  end
  n = n + 1; y = y + dy
end
table.sort(pts, function(a,b) return a.y < b.y end)
local k = 0
for _,p in ipairs(pts) do
  local t = smoothstep(815, 776, p.x) * (1 - 0.6*smoothstep(600, 940, p.y))
  if k % 4 == 0 then B.lit:load(bodyLit,0.6); B.mid:load(bodyMid,0.6); edge:load(edgeHot, 0.55); shadow:load(shP,0.55) end
  k = k + 1
  local bb = (t > 0.5) and B.lit or B.mid
  local hw = s*0.45*math.cos(p.phi) * (0.92 + 0.16*math.random())
  local hh = s*0.5
  bb:stroke({{p.x-hw, p.y}, {p.x, p.y+hh*0.1}, {p.x+hw, p.y}}, {pressure={0.8,0.7}, ramps={0.15,0.25}, clip=clipm})
  shadow:stroke({{p.x-hw*1.05, p.y+hh*0.45}, {p.x, p.y+hh*0.6}, {p.x+hw*1.05, p.y+hh*0.45}}, {pressure={0.45,0.12}, ramps={0.2,0.4}, clip=clipm})
  if t > 0.25 then edge:stroke({{p.x-hw*0.9, p.y-hh*0.3}, {p.x, p.y-hh*0.45}, {p.x+hw*0.9, p.y-hh*0.3}}, {pressure={0.5*t,0.08}, ramps={0.25,0.5}, clip=clipm}) end
end
print(#pts)
-- lit rim on the drum's top edge
local rim = brush{kind="round", width=2.2, point=0.6}
rim:load(edgeHot, 0.6)
local top = {}
for x=774,1000,8 do top[#top+1] = {x, 445 - 105*math.sqrt(math.max(0, 1 - ((x-1020)/248)^2)) + 1} end
rim:stroke(top, {pressure={0.55,0.15}, ramps={0.05,0.7}})

--@ chunk 101
print(wait(3*24*60)); for _,p in ipairs({{410,1045},{450,1010},{470,1040},{460,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 102
print(wait(6*24*60)); for _,p in ipairs({{410,1045},{450,1010},{470,1040},{460,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 103
-- rim light where the silhouette turns up toward the oculus; stronger high on the figure
local strength = function(x,y) return lerp(1.0, 0.35, smoothstep(AOY-70, AOY-10, y)) end
work(RIMM, {hand="detail", tool={kind="round", width=1.4, point=0.8}, pile=rimP, coverage=2.2, fill=true, clip=true,
  angle=function(x,y) return -0.8 end, load_at=function(x,y) return 0.6*strength(x,y) end})
-- the cold readout, restated brighter
local ox, oy = AOX, AOY
local c = brush{kind="round", width=1.6, point=0.5}
c:load(coldHalo, 0.6)
for i=1,10 do c:touch(ox + rand(0.5, 9.5), oy + rand(-22.5, -15.5), {pressure=rand(0.25,0.45), clip=ARK.panel:shrink(1)}) end
local t = brush{kind="round", width=0.8, point=0.9}
t:load(coldCore, 0.6)
for i=0,3 do
  local y = -21.5 + i*1.9
  local w = ({7, 4.5, 6, 3})[i+1]
  t:stroke(P(ox,oy,{{0.8, y},{0.8 + w, y - 0.05}}), {pressure={0.5,0.45}, clip=ARK.panel:shrink(1.2)})
end
local cc = brush{kind="round", width=2.4, point=0.4}
cc:load(coldCore, 0.8)
cc:touch(ox + 7.8, oy - 16.3, {pressure=0.6})
-- frost glints on top
local g = brush{kind="round", width=1.3, point=0.8}
g:load(frostLit, 0.6)
local pts = {{-44,-24.5},{-39,-26.5},{-33,-28},{-27,-28.6},{-20,-29.6},{-10,-30.8},{-4,-31.2},{3,-31.8},{9,-32.2}}
for i,p in ipairs(pts) do
  if i % 4 == 0 then g:load(frostLit, 0.6) end
  g:stroke(P(ox,oy,{{p[1], p[2]+0.4},{p[1] + rand(1.5,3.5), p[2]}}), {pressure={0.5,0.2}})
end

--@ chunk 104
print(wait(3*24*60)); for _,p in ipairs({{447,995},{475,1020},{487,1055},{412,1048}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 105
local F = FIG.all
-- keep a rim whose width shrinks down the figure, and breaks along the edge
local nz = noise{seed=31, period=6}
local function rimw(y) return lerp(1.1, 0.25, smoothstep(AOY-68, AOY-25, y)) end
local cut = F * mask(function(x,y)
  local w = rimw(y)
  local inside = F:at(x + w, y - w) > 0.5
  local broken = nz:at01(x,y) < 0.35 and y > AOY - 55
  return (inside or broken) and 1 or 0 end)
work(cut, {hand="detail", tool={kind="round", width=1.2, point=0.6}, pile=frameDark2, coverage=3.2, fill=true, clip=true, angle=-0.8})

--@ chunk 106
for _,p in ipairs({{100,200},{250,300},{200,500},{150,800},{600,400},{700,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 107
vgDark = pile{{"viridian",1},{"bone black",0.8},{"raw sienna",0.5},{"lead white",0.35}}
vgLit = pile{{"viridian",1},{"cerulean blue",0.4},{"lead white",1},{"raw sienna",1},{"bone black",0.3}}
local sh = (LT - FLOOR):shrink(4)
local nz = noise{seed=77, period=140, octaves=3}
local patches = sh * mask(function(x,y) return smoothstep(0.58, 0.72, nz:at01(x,y)) end)
stipple(patches, {pile=vgDark, width=4, coverage=function(x,y) return 1.4*smoothstep(0.58,0.75,nz:at01(x,y)) end, cluster={0.7, 8}, feather=0.6, dips={20, 0.5, 0.3}})
local R = (RT - FLOOR):shrink(3)
local patches2 = R * mask(function(x,y) return smoothstep(0.55, 0.7, nz:at01(x+400,y)) end)
stipple(patches2, {pile=vgDark, width=3.5, coverage=function(x,y) return 1.2*smoothstep(0.55,0.72,nz:at01(x+400,y)) end, cluster={0.7, 8}, feather=0.6})

--@ chunk 108
local nz = noise{seed=77, period=140, octaves=3}
local sh = (LT - FLOOR)
local p1 = sh * mask(function(x,y) return smoothstep(0.52, 0.62, nz:at01(x,y)) end)
local R = (RT - FLOOR)
local p2 = R * mask(function(x,y) return smoothstep(0.5, 0.6, nz:at01(x+400,y)) end)
local all = p1 + p2
for i=1,3 do
  blend(all, {angle=function(x,y) return math.atan(y-560, x+340) + math.pi/2 + (i-2)*0.7 end})
end

--@ chunk 109
print(wait(5*24*60)); for _,p in ipairs({{40,300},{100,400},{150,760},{960,560}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 110
local sh = LT - FLOOR
local ang = function(x,y) return math.atan(y-560, x+340) + math.pi/2 end
work(sh, {hand="glaze", pile=darkGlaze, coverage=2.4, fill=true, clip=sh, angle=ang,
  load_at=function(x,y) return lerp(0.95, 0.4, smoothstep(0.86, 0.99, ltnd(x,y))) end})
blend(sh, {angle=ang})
local R = (RT - FLOOR)
work(R, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=R, angle=math.pi/2,
  load_at=function(x,y) return lerp(0.25, 0.95, smoothstep(785, 870, x)) end})
blend(R, {angle=math.pi/2})

--@ chunk 111
local function ed(x,y) local dx=(x-OC[1]); local dy=(y-OC[2]+4)/0.62; return math.sqrt(dx*dx+dy*dy) end
local halo = ellipse(OC[1], OC[2]-4, 230, 145) - ellipse(735, 166, 66, 40)
local veilH = pile{{"lead white",1},{"Mars orange",0.8},{"cadmium yellow",0.6},{"red lead",0.2}, medium=0.85}
work(halo, {hand="glaze", pile=veilH, coverage=1.6, fill=true, clip=halo,
  angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end,
  load_at=function(x,y) return 0.45*(1 - smoothstep(70, 220, ed(x,y))) end})
blend(halo, {angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end})

--@ chunk 112
local edgeBand = (ellipse(OC[1], OC[2]-4, 260, 170) - ellipse(OC[1], OC[2]-4, 175, 105))
local radial = function(x,y) return math.atan(y-OC[2], x-OC[1]) end
blend(edgeBand, {angle=radial, clip=false})
blend(edgeBand, {angle=function(x,y) return radial(x,y) + math.pi/2 end, clip=false})
blend(edgeBand, {angle=radial, clip=false})

--@ chunk 113
print(wait(7*24*60)); for _,p in ipairs({{735,100},{620,170},{850,200},{735,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 114
amberG = pile{{"Mars orange",1},{"red lead",0.4},{"Indian yellow",0.6}, medium=0.85}
local function ed(x,y) local dx=(x-OC[1]); local dy=(y-OC[2]+4)/0.62; return math.sqrt(dx*dx+dy*dy) end
local halo = ellipse(OC[1], OC[2]-4, 270, 175) - ellipse(735, 166, 64, 38)
work(halo, {hand="glaze", pile=amberG, coverage=1.4, fill=true, clip=halo,
  angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end,
  load_at=function(x,y) return 0.4*(1 - smoothstep(60, 260, ed(x,y))) end})
blend(halo, {angle=function(x,y) return math.atan(y-OC[2], x-OC[1]) + math.pi/2 end})
local bm = BEAM * rect(0, 200, 1000, 840) - FIG.all:grow(4) - ARK.body:grow(4)
work(bm, {hand="glaze", pile=amberG, coverage=1.3, fill=true, angle=BEAM_A, clip=bm,
  load_at=function(x,y) return lerp(0.35, 0.12, smoothstep(220, 800, y)) end})
blend(bm, {angle=BEAM_A})

--@ chunk 115
local sunW = pile{{"lead white",6},{"lemon chrome",0.12}}
local sunWarm = pile{{"lead white",4},{"cadmium yellow",0.5},{"Indian yellow",0.2}}
local o = ellipse(735, 166, 62, 36)
work(o - ellipse(735, 163, 46, 25), {hand="body", tool="filbert 5", pile=sunWarm, coverage=3.5, fill=true, angle=0, clip=o})
work(ellipse(735, 163, 48, 27), {hand="body", tool="filbert 6", pile=sunW, coverage=4, fill=true, angle=0.05, clip=o, load=0.9})
blend(o:shrink(1), {angle=0})

--@ chunk 116
print(wait(6*24*60)); for _,p in ipairs({{600,400},{500,700},{735,166},{420,900}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 117
-- dust motes hanging in the beam: tiny, sparse, clustered, brighter near the top and the floor
local mote = pile{{"lead white",4},{"cadmium yellow",0.4},{"Indian yellow",0.2}}
local mote2 = pile{{"lead white",2},{"Mars orange",0.4},{"yellow ochre",0.5}}
local b = brush{kind="round", width=1.4, point=0.6}
local b2 = brush{kind="round", width=1.0, point=0.8}
local n = 0
-- beam axis from (737,190) to (430,1062); half width grows from 50 to 155
for i=1,260 do
  local t = rand(0,1)^0.9
  local ax = lerp(737, 430, t); local ay = lerp(195, 1050, t)
  local hw = lerp(48, 150, t) * 0.9
  local u = randn(0, 0.45)
  if math.abs(u) < 1 then
    local x = ax + u*hw*0.97; local y = ay + u*hw*0.24
    if FIG.all:grow(3):at(x,y) < 0.5 and ARK.body:grow(3):at(x,y) < 0.5 then
      local bright = 1 - math.abs(u)
      if n % 10 == 0 then b:load(mote, 0.5); b2:load(mote2, 0.5) end
      if math.random() < 0.25 + 0.3*bright then
        b:touch(x, y, {pressure=rand(0.15, 0.4)*bright + 0.08})
      else
        b2:touch(x, y, {pressure=rand(0.1, 0.35)})
      end
      n = n + 1
    end
  end
end
print(n)

--@ chunk 118
local mote = pile{{"lead white",4},{"cadmium yellow",0.4},{"Indian yellow",0.2}}
local b = brush{kind="round", width=2.4, point=0.5}
local n = 0
for i=1,110 do
  local t = rand(0,1)^0.8
  local ax = lerp(737, 430, t); local ay = lerp(195, 1050, t)
  local hw = lerp(48, 150, t) * 0.9
  local u = randn(0, 0.4)
  if math.abs(u) < 0.95 then
    local x = ax + u*hw*0.97 + randn(0, 6); local y = ay + u*hw*0.24 + randn(0, 6)
    if FIG.all:grow(4):at(x,y) < 0.5 and ARK.body:grow(4):at(x,y) < 0.5 then
      if n % 8 == 0 then b:load(mote, 0.55) end
      b:touch(x, y, {pressure=rand(0.3, 0.6)})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 119
local ox, oy = AOX, AOY
local pan = ARK.panel:shrink(1.0)
work(pan, {hand="detail", tool={kind="round", width=1.4, point=0.5}, pile=coldHalo, coverage=1.8, fill=true, clip=true, angle=0, load=0.5})
local t = brush{kind="round", width=0.8, point=0.9}
t:load(pile{{"cerulean blue",1},{"bone black",0.6},{"lead white",0.4}}, 0.5)
for i=0,3 do
  local y = -21.6 + i*1.9
  local w = ({7, 4.5, 6, 3})[i+1]
  t:stroke(P(ox,oy,{{0.9, y},{0.9 + w, y - 0.05}}), {pressure={0.4,0.35}, clip=pan})
end
local cc = brush{kind="round", width=2.0, point=0.4}
cc:load(coldCore, 0.8)
cc:touch(ox + 7.8, oy - 16.3, {pressure=0.6})
-- cold spill on the frost around the panel and on the reaching hand
local spill = (ellipse(ox+4, oy-19, 16, 11) - ARK.panel) * ARK.body
stipple(spill, {pile=coldHalo, width=1.2, coverage=function(x,y) local dx=(x-ox-4)/16; local dy=(y-oy+19)/11; return 2.5*(1-smoothstep(0.3,1,math.sqrt(dx*dx+dy*dy))) end, feather=0.7})
local h = brush{kind="round", width=1.2, point=0.8}
h:load(coldHalo, 0.6)
h:stroke(P(ox,oy,{{15.5,-32.5},{19.5,-32.3},{22,-33.5}}), {pressure={0.45,0.2}, clip=FIG.all:grow(0.5)})

--@ chunk 120
print(wait(5*24*60)); for _,p in ipairs({{735,166},{660,150},{800,190}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 121
local collar = ellipse(735, 168, 100, 62) - ellipse(735, 166, 63, 37)
local cGold = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8},{"burnt sienna",0.4}}
local cDeep = pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",0.6}}
local radial = function(x,y) return math.atan(y-166, x-735) + math.pi/2 end
local function ed(x,y) local dx=(x-735)/100; local dy=(y-168)/62; return math.sqrt(dx*dx+dy*dy) end
work(collar * mask(function(x,y) return ed(x,y) > 0.8 and 1 or 0 end):soften(3), {hand="body", tool="filbert 6", pile=cDeep, coverage=3, fill=true, angle=radial, clip=collar})
work(collar * mask(function(x,y) return ed(x,y) <= 0.8 and 1 or 0 end):soften(3), {hand="body", tool="filbert 6", pile=cGold, coverage=3, fill=true, angle=radial, clip=collar})
blend(collar, {angle=radial})

--@ chunk 122
print(wait(4*24*60), drying(735,215), drying(650,170))
local groove = pile{{"bone black",1.5},{"burnt sienna",1},{"bone brown",0.5}}
local boneP = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local boneSh = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.5}}
local function ell(cx, cy, rx, ry, a0, a1, step)
  local pts = {}
  for a=a0,a1,step do pts[#pts+1] = {cx + rx*math.cos(a), cy + ry*math.sin(a)} end
  return pts
end
-- throat: the lower inside of the opening, in shadow, thicker at the bottom
local th = brush{kind="round", width=3.2, point=0.5}
th:load(groove, 0.7)
th:stroke(ell(735, 167, 63.5, 37.5, 0.15, math.pi-0.15, 0.08), {pressure={0.35,0.35}, swell={0.4, 1.0, 1.3, 1.0, 0.4}})
-- outer groove of the collar
local g = brush{kind="round", width=2.2, point=0.6}
g:load(groove, 0.7)
g:stroke(ell(735, 168, 100, 62, -math.pi, 0, 0.06), {pressure={0.5,0.5}})
g:load(groove, 0.7)
g:stroke(ell(735, 168, 100, 62, 0, math.pi, 0.06), {pressure={0.55,0.55}})
-- inscription band: a ring of small bone plates at uneven intervals
local angs = uneven(34, 0, 2*math.pi*0.97, 0.5, 0.3, 21)
local b = brush{kind="flat", width=4}
local s = brush{kind="round", width=1.6, point=0.6}
for i,a in ipairs(angs) do
  local cx, cy = 735 + 82*math.cos(a), 168 + 50*math.sin(a)
  local tx, ty = -math.sin(a)*82, math.cos(a)*50
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local L = rand(2.5, 5.5)
  if i % 4 == 1 then b:load(boneP, 0.6); s:load(boneSh, 0.6) end
  b:stroke({{cx - tx*L, cy - ty*L}, {cx + tx*L, cy + ty*L}}, {pressure={0.55,0.5}, orient="across"})
  local rx, ry = math.cos(a), math.sin(a)*0.62
  s:stroke({{cx - tx*L + rx*2.5, cy - ty*L + ry*2.5}, {cx + tx*L + rx*2.5, cy + ty*L + ry*2.5}}, {pressure={0.35,0.3}})
end

--@ chunk 123
print(wait(3*24*60), drying(735,215))
local area = ellipse(735, 168, 125, 80) - ellipse(735, 166, 63, 37)
local radial = function(x,y) return math.atan(y-166, x-735) + math.pi/2 end
local function ed(x,y) local dx=(x-735)/100; local dy=(y-168)/62; return math.sqrt(dx*dx+dy*dy) end
work(area, {hand="glaze", pile=darkGlaze, coverage=1.8, fill=true, clip=area, angle=radial,
  load_at=function(x,y) return 0.15 + 0.55*smoothstep(0.75, 1.15, ed(x,y)) end})
blend(area, {angle=radial})
work(area, {hand="glaze", pile=amberG, coverage=1.4, fill=true, clip=area, angle=radial, load=0.35})
blend(area, {angle=radial})

--@ chunk 124
print(wait(3*24*60))
local function sd(x,y, x0,y0,x1,y1)
  local dx, dy = x1-x0, y1-y0; local l = math.sqrt(dx*dx+dy*dy)
  return ((x-x0)*dy - (y-y0)*dx)/l   -- positive to one side
end
-- left edge: outside is to the left (negative?), check sign at a point clearly outside
local sL = sd(100,600, 675,185,265,1060) > 0 and 1 or -1
local sR = sd(950,600, 798,180,575,1075) > 0 and 1 or -1
local function feather(x,y)
  local t = smoothstep(190, 1060, y)
  local w = lerp(8, 55, t)
  local dl = sL*sd(x,y, 675,185,265,1060)
  local dr = sR*sd(x,y, 798,180,575,1075)
  local d = math.min(math.abs(dl), math.abs(dr))
  local outside = (dl > 0 or dr > 0)
  if not outside then return 0 end
  return 1 - smoothstep(0, w, d)
end
local zone = mask(function(x,y) return (y > 200 and y < 1040 and feather(x,y) > 0.02) and 1 or 0 end) - FIG.all:grow(3) - ARK.body:grow(3)
work(zone, {hand="glaze", pile=amberG, coverage=1.6, fill=true, clip=zone, angle=BEAM_A,
  load_at=function(x,y) return 0.28*feather(x,y) end})
blend(zone, {angle=BEAM_A})
blend(zone, {angle=BEAM_A + 1.2})

--@ chunk 125
print(wait(3*24*60))
-- foreground and corner darkening
local F = FLOORALL - FIG.all:grow(3) - ARK.body:grow(3)
work(F, {hand="glaze", pile=darkGlaze, coverage=2.0, fill=true, clip=F, angle=0.03,
  load_at=function(x,y)
    local dx=(x-POOLC[1])/260; local dy=(y-POOLC[2]+10)/95
    local d = math.sqrt(dx*dx+dy*dy)
    return 0.8*smoothstep(1.0, 2.6, d) + 0.2*smoothstep(1150, 1333, y) end})
blend(F, {angle=0.03})
-- collar: sink the outer ring
local area = ellipse(735, 168, 130, 84) - ellipse(735, 166, 75, 46)
local radial = function(x,y) return math.atan(y-166, x-735) + math.pi/2 end
work(area, {hand="glaze", pile=darkGlaze, coverage=1.6, fill=true, clip=area, angle=radial, load=0.4})
blend(area, {angle=radial})

--@ chunk 126
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60))
H3 = poly({{560,935},{600,912},{650,903},{700,896},{745,885},{790,872},{830,866},{870,872},{920,868},{965,876},{1000,872},{1000,960},{560,960}}, true)
local h3 = H3 - FLOORALL:shrink(25)
work(H3, {hand="body", pile=rkDeep, coverage=2.8, fill=true, angle=-0.15, length={15,40}, edge="firm", clip=H3:grow(1)})
local n = rubble{n=900, x0=560, x1=1000, y0=860, y1=960, bias=1, where=H3, clip=H3,
  size=function(x,y) return 3 end, light=function(x,y) return 0.12 end, piles=RUBP}
print(n)

--@ chunk 127
local band = rect(540, 925, 460, 70)
blend(band, {angle=1.4, clip=false})
blend(band, {angle=1.7, clip=false})
local nose = ellipse(585, 925, 50, 25)
blend(nose, {angle=0.4, clip=false})
-- ridge bumps along the top of H3: small rock silhouettes poking above the line
local ridge = {}
for x=600,1000,1 do end
local b = brush("flat", 5)
local cnt = 0
for i=1,140 do
  local x = rand(600, 1000)
  local ytop
  for y=850,960 do if H3:at(x,y) > 0.5 then ytop = y; break end end
  if ytop then
    if cnt % 4 == 0 then b:reload(rkDeep, 0.6) end
    cnt = cnt + 1
    local s = rand(3, 8)
    b:stroke({{x - s*0.5, ytop + 2}, {x + rand(-1,1), ytop - s*rand(0.2,0.6)}, {x + s*0.5, ytop + 2}}, {pressure={0.7,0.6}})
  end
end
print(cnt)

--@ chunk 128
print(wait(4*24*60)); for _,p in ipairs({{700,880},{900,850},{580,870},{800,1000},{700,1150}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 129
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local top = {{575,960},{590,925},{612,900},{640,880},{668,866},{700,852},{735,840},{768,826},{800,816},{835,811},{868,806},{905,800},{945,796},{980,790},{1005,788}}
H4 = outline{pts=top, char="broken", amount=0.6, seed=91}:below(1010) * rect(560, 700, 450, 320)
H4 = H4 - H1:grow(2)
work(H4, {hand="body", pile=rkDeep, coverage=3.2, fill=true, angle=-0.2, length={12,35}, clip=H4})
-- a slightly lighter, warmer, broken top skin where the faint spill reaches
local skin = H4 - H4:shrink(10)
work(skin, {hand="body", tool="filbert 4", pile=rkDark2, coverage=1.4, fill=false, angle=-0.25, length={6,16}, clip=H4})
print(H4:area())

--@ chunk 130
print(wait(5*24*60)); for _,p in ipairs({{700,880},{900,820},{580,870},{800,1000}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 131
print(wait(2*24*60), drying(900,820))
-- sink the whole right-hand dark zone: heap H4 and the floor below it, out of the light
local zone = (H4 + (FLOORALL * rect(560, 900, 440, 350))) - FIG.all:grow(4) - ARK.body:grow(4)
local function pd(x,y) local dx=(x-POOLC[1])/260; local dy=(y-POOLC[2]+10)/95; return math.sqrt(dx*dx+dy*dy) end
work(zone, {hand="glaze", pile=darkGlaze, coverage=2.4, fill=true, clip=zone, angle=-0.15,
  load_at=function(x,y) return 0.95*smoothstep(0.7, 1.6, pd(x,y)) end})
blend(zone, {angle=-0.15})

--@ chunk 132
print(wait(2*24*60), drying(560,860), drying(900,820))
FZ = (BEAM:grow(20) * rect(495, 812, 165, 135) - H4 - H1:grow(2) - FIG.all:grow(6)):roughen(4, 20, 5)
work(FZ, {hand="body", tool="filbert 6", pile=vaultDark, coverage=3.2, fill=true, angle=BEAM_A, clip=FZ})

--@ chunk 133
print(wait(4*24*60)); print(drying(560,860), drying(620,830))

--@ chunk 134
print(wait(4*24*60)); print(drying(560,860), drying(620,830))

--@ chunk 135
print(wait(6*24*60)); print(drying(560,860), drying(620,830))

--@ chunk 136
local brownG = pile{{"bone brown",1},{"burnt sienna",0.7}, medium=0.8}
work(FZ, {hand="glaze", pile=brownG, coverage=1.6, fill=true, clip=FZ, angle=BEAM_A, load=0.5})
blend(FZ, {angle=BEAM_A})

--@ chunk 137
print(wait(4*24*60), drying(560,860))
-- restate the gallery ledge and its apertures across the patch first
local ledgeLit = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.35}, medium=0.1}
local ledgeDk = pile{{"bone black",2},{"ultramarine blue",0.6},{"bone brown",0.5}, medium=0.1}
local apDark = pile{{"bone black",2},{"ultramarine blue",0.7}, medium=0.1}
local function yarc(x) return 850 - 0.00006*(x-560)^2 end
local pts, below = {}, {}
for x=490,670,10 do pts[#pts+1] = {x, yarc(x)}; below[#below+1] = {x, yarc(x) + 2.6} end
local dk = brush{kind="flat", width=6}
dk:load(ledgeDk, 0.7); dk:stroke(below, {pressure={0.8,0.8}, clip=FZ})
local lit = brush{kind="round", width=2.6, point=0.5}
lit:load(ledgeLit, 0.6); lit:stroke(pts, {pressure={0.55,0.5}, clip=FZ})
local tip = brush{kind="flat", width=4}
for _,x in ipairs({512, 541, 566, 597, 611, 640}) do
  tip:load(apDark, 0.7)
  tip:stroke({{x, yarc(x)+6}, {x, yarc(x)+12}}, {pressure={0.75,0.75}, clip=FZ})
end

--@ chunk 138
print(wait(3*24*60))
local soft = FZ:grow(6):blur(5) * BEAM
work(soft, {hand="glaze", pile=darkGlaze, coverage=1.6, fill=true, clip=FZ:grow(3):blur(3), angle=BEAM_A, load=0.45})
blend(FZ:grow(3), {angle=BEAM_A})

--@ chunk 139
print(wait(5*24*60), drying(560,860), drying(520,900))
local m = FZ:grow(4) * BEAM
work(m, {hand="glaze", pile=warmGlaze, coverage=1.2, fill=true, clip=m:blur(3), angle=BEAM_A, load=0.3})
blend(m, {angle=BEAM_A})
work(m, {hand="glaze", pile=veilA, coverage=1.6, fill=true, clip=m:blur(3), angle=BEAM_A, load=0.36})
blend(m, {angle=BEAM_A})

--@ chunk 140
print(wait(7*24*60)); print(drying(560,860), drying(520,900))

--@ chunk 141
local m = FZ:grow(4) * BEAM
-- olive-neutral dark glaze: pulls the orange back toward the beam's olive gold
local oliveG = pile{{"bone black",1},{"raw sienna",0.6},{"ultramarine blue",0.15}, medium=0.85}
work(m, {hand="glaze", pile=oliveG, coverage=1.6, fill=true, clip=m:blur(4), angle=BEAM_A, load=0.4})
blend(m, {angle=BEAM_A})

--@ chunk 142
print(wait(5*24*60), drying(560,860))
local m = FZ:grow(2) * BEAM
local greyV = pile{{"lead white",1},{"ultramarine ash",0.7},{"bone black",0.15}, medium=0.85}
work(m, {hand="glaze", pile=greyV, coverage=1.6, fill=true, clip=m:blur(4), angle=BEAM_A, load=0.25})
blend(m, {angle=BEAM_A})
blend(m, {angle=BEAM_A + 0.5})

--@ chunk 143
print(wait(7*24*60), drying(560,860))
local m = FZ:grow(2) * BEAM
local oliveG = pile{{"bone black",1},{"raw sienna",0.8},{"ultramarine blue",0.1}, medium=0.85}
work(m, {hand="glaze", pile=oliveG, coverage=1.6, fill=true, clip=m:blur(4), angle=BEAM_A, load=0.35})
blend(m, {angle=BEAM_A})
blend(m, {angle=BEAM_A + 0.5})

--@ chunk 144
print(wait(7*24*60), drying(560,860))
local m = FZ:grow(2) * BEAM
local roseG = pile{{"rose madder",1},{"burnt sienna",0.3}, medium=0.9}
work(m, {hand="glaze", pile=roseG, coverage=1.4, fill=true, clip=m:blur(4), angle=BEAM_A, load=0.22})
blend(m, {angle=BEAM_A})
blend(m, {angle=BEAM_A + 0.5})

--@ chunk 145
local ledgeLit = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",1},{"lead white",0.35}, medium=0.1}
local ledgeDk = pile{{"bone black",2},{"Mars brown",0.6},{"bone brown",0.5}, medium=0.1}
local apDark = pile{{"bone black",2},{"Mars brown",0.5}, medium=0.1}
local function yarc(x) return 850 - 0.00006*(x-560)^2 end
local clipm = FZ:grow(3)
local pts, below = {}, {}
for x=480,680,10 do pts[#pts+1] = {x, yarc(x)}; below[#below+1] = {x, yarc(x) + 2.6} end
local dk = brush{kind="flat", width=5}
dk:load(ledgeDk, 0.6); dk:stroke(below, {pressure={0.7,0.7}, clip=clipm})
local lit = brush{kind="round", width=2.2, point=0.5}
lit:load(ledgeLit, 0.5); lit:stroke(pts, {pressure={0.5,0.45}, clip=clipm})
local tip = brush{kind="flat", width=3.5}
local sill = brush{kind="round", width=1.4, point=0.5}
for _,x in ipairs({508, 529, 556, 571, 603, 626, 648}) do
  tip:load(apDark, 0.7); sill:load(ledgeLit, 0.5)
  tip:stroke({{x, yarc(x)+6}, {x, yarc(x)+11.5}}, {pressure={0.75,0.75}, clip=clipm})
  sill:stroke({{x-2.6, yarc(x)+12.6}, {x+2.6, yarc(x)+12.6}}, {pressure={0.45,0.4}, clip=clipm})
end
local rib = brush{kind="round", width=1.8, point=0.4}
for _,x in ipairs({538, 615}) do
  rib:load(ledgeLit, 0.45)
  rib:stroke({{x, yarc(x)+16}, {x, 905}}, {pressure={0.35,0.25}, clip=clipm})
end

--@ chunk 146
print(wait(4*24*60), drying(560,860))
-- one long-stroked veil over the whole lower beam: its streaks cross the patch and tie it in
local m = BEAM * rect(0, 560, 1000, 440) - FIG.all:grow(5) - ARK.body:grow(5) - H1:shrink(5)
work(m, {hand="glaze", pile=amberG, coverage=1.0, fill=false, clip=m, angle=BEAM_A, load=0.18, length={200,320}})
blend(m, {angle=BEAM_A})

--@ chunk 147
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60))
local top = {{462,960},{470,925},{478,880},{486,840},{494,812},{510,800},{532,793},{556,795},{575,788},{602,792},{628,799},{650,806},{672,818},{694,836},{716,852}}
H5 = outline{pts=top, char="broken", amount=0.8, seed=57}:below(1000) * rect(455, 770, 270, 240) - H1:grow(1) - FIG.all:grow(4) - ARK.body:grow(4)
work(H5, {hand="body", pile=rkDeep, coverage=3.4, fill=true, angle=-0.6, length={10,30}, clip=H5})
print(H5:area())

--@ chunk 148
local fillm = poly({{470,940},{700,850},{730,860},{730,1000},{462,1000}}) - H1:grow(1) - FIG.all:grow(4) - ARK.body:grow(4)
fillm = fillm * mask(function(x,y) return 1 end)
work(fillm, {hand="body", pile=rkDeep, coverage=3.4, fill=true, angle=-0.6, length={10,30}, clip=fillm})
H5 = H5 + fillm

--@ chunk 149
print(wait(5*24*60)); print(drying(560,860), drying(700,950))

--@ chunk 150
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60), drying(560,860))
local n = rubble{n=2400, x0=455, x1=740, y0=780, y1=1005, bias=1, where=H5, clip=H5,
  size=function(x,y) return 3.5 + 3*(y-780)/225 end,
  light=function(x,y) return 0.1 + 0.25*smoothstep(840, 790, y) end, piles=RUBP}
print(n)

--@ chunk 151
print(wait(6*24*60)); print(drying(560,860), drying(600,950), drying(500,900))

--@ chunk 152
local m = (BEAM * H5:grow(3)) - FIG.all:grow(5) - ARK.body:grow(5)
local soft = m:blur(4)
work(m, {hand="glaze", pile=warmGlaze, coverage=1.0, fill=true, clip=soft, angle=BEAM_A, load=0.22, length={120,300}})
blend(m, {angle=BEAM_A})
work(m, {hand="glaze", pile=veilA, coverage=1.3, fill=true, clip=soft, angle=BEAM_A, load=0.22, length={120,300}})
blend(m, {angle=BEAM_A})

--@ chunk 153
print(wait(7*24*60), drying(560,880))
local m = (BEAM * H5:grow(3)) - FIG.all:grow(5) - ARK.body:grow(5)
local oliveG2 = pile{{"bone black",1},{"raw sienna",0.5},{"bone brown",0.4}, medium=0.85}
work(m, {hand="glaze", pile=oliveG2, coverage=1.3, fill=true, clip=m:blur(4), angle=BEAM_A, load=0.3, length={120,300}})
blend(m, {angle=BEAM_A})

--@ chunk 154
print(wait(4*24*60))
-- break the heap's top contour with rocks and a few rolling-down stones
local moundRock = pile{{"bone black",1},{"raw sienna",1},{"yellow ochre",0.4},{"lead white",0.25}}
local b = brush("flat", 5)
local cnt = 0
for i=1,90 do
  local x = rand(470, 715)
  local ytop
  for y=770,1000 do if H5:at(x,y) > 0.5 then ytop = y; break end end
  if ytop then
    if cnt % 4 == 0 then b:reload(moundRock, 0.55) end
    cnt = cnt + 1
    local s = rand(3, 7)
    b:stroke({{x - s*0.5, ytop + 3}, {x + rand(-1.5,1.5), ytop - s*rand(0.2,0.7)}, {x + s*0.5, ytop + 3}}, {pressure={0.7,0.6}})
  end
end
-- feather the beam's right edge across the heap
local function sd(x,y, x0,y0,x1,y1) local dx, dy = x1-x0, y1-y0; local l = math.sqrt(dx*dx+dy*dy); return ((x-x0)*dy - (y-y0)*dx)/l end
local sR = sd(950,600, 798,180,575,1075) > 0 and 1 or -1
local band = H5 * mask(function(x,y) local d = sR*sd(x,y, 798,180,575,1075); return (d > -15 and d < 45) and 1 or 0 end)
work(band, {hand="glaze", pile=amberG, coverage=1.2, fill=true, clip=band:blur(6), angle=BEAM_A, length={60,140},
  load_at=function(x,y) local d = sR*sd(x,y, 798,180,575,1075); return 0.22*(1 - smoothstep(-10, 45, d)) end})
blend(band, {angle=BEAM_A})
print(cnt)

--@ chunk 155
print(wait(7*24*60)); print(drying(560,800), drying(640,830), drying(560,900))

--@ chunk 156
moundIn  = pile{{"bone black",1},{"yellow ochre",0.8},{"lead white",0.2},{"burnt sienna",0.3}}
moundOut = pile{{"bone black",1.5},{"Mars brown",1},{"yellow ochre",0.4},{"lead white",0.1}}
-- reshape: the heap's top as a softer, rounder line, slightly lower than the old block top
local top = {{455,975},{462,940},{474,900},{490,862},{510,833},{535,815},{560,806},{588,803},{615,808},{642,818},{668,832},{695,846},{722,858}}
local o = outline{pts=top, char="soft", amount=0.5, seed=63}
local newH = o:below(1010) * rect(450, 780, 285, 230)
-- everything of the old block that is above the new line goes back to beam-over-wall colour
local above = (H5:grow(2) - newH) - FIG.all:grow(4) - ARK.body:grow(4)
local beamWall = pile{{"bone black",1},{"yellow ochre",0.8},{"lead white",0.3},{"burnt sienna",0.25}}
work(above * BEAM, {hand="body", tool="filbert 5", pile=beamWall, coverage=3, fill=true, angle=BEAM_A, clip=above * BEAM, length={10,30}})
work(above - BEAM, {hand="body", tool="filbert 5", pile=moundOut, coverage=3, fill=true, angle=BEAM_A, clip=above - BEAM, length={10,30}})
H5n = newH - H1:grow(1) - FIG.all:grow(4) - ARK.body:grow(4)
local inB = H5n * BEAM:shrink(6)
local outB = H5n - BEAM:grow(6)
local edgeB = H5n - inB - outB
work(inB, {hand="body", pile=moundIn, coverage=3, fill=true, angle=BEAM_A, clip=H5n, length={15,40}})
work(outB, {hand="body", pile=moundOut, coverage=3, fill=true, angle=-0.4, clip=H5n, length={15,40}})
work(edgeB, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.25},{"Mars brown",0.5},{"yellow ochre",0.6},{"lead white",0.15},{"burnt sienna",0.15}}, coverage=3, fill=true, angle=BEAM_A, clip=H5n, length={10,25}})
blend(H5n * BEAM:grow(14) - BEAM:shrink(14), {angle=BEAM_A})

--@ chunk 157
print(wait(5*24*60)); print(drying(560,820), drying(640,850), drying(560,900))

--@ chunk 158
print(wait(4*24*60), drying(640,850), drying(560,900))
MD = poly({{440,1010},{446,965},{456,920},{466,880},{474,845},{483,815},{496,795},{516,783},{540,776},{566,773},{592,772},{618,777},{645,788},{672,804},{700,822},{730,840},{762,853},{762,1010}}, true):roughen(3, 14, 81)
MD = MD - H1:grow(1) - FIG.all:grow(4) - ARK.body:grow(4)
local moundDeep = pile{{"bone black",1.5},{"Mars brown",1},{"yellow ochre",0.25},{"lead white",0.08}}
work(MD, {hand="body", pile=moundDeep, coverage=3.4, fill=true, angle=function(x,y) return (x < 590) and -0.9 or 0.5 end, clip=MD, length={12,35}})

--@ chunk 159
print(wait(6*24*60)); print(drying(560,800), drying(640,830), drying(520,900))

--@ chunk 160
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
-- distance below the crest
local function crestY(x) for y=760,1010 do if MD:at(x,y) > 0.5 then return y end end return 1010 end
local cy = {}
for x=440,762,2 do cy[x] = crestY(x) end
local function depth(x,y) local xi = math.floor(x/2)*2; local c = cy[xi] or 1010; return y - c end
local function inBeam(x,y) return BEAM:at(x,y) end
-- light on the heap: a crest band lit by the beam, falling off fast down the front face
local function L(x,y)
  local d = depth(x,y)
  local b = inBeam(x, y - 6)
  return clamp(b * (1 - smoothstep(2, 22, d)) * 0.95 + 0.06, 0, 1)
end
local n = rubble{n=3200, x0=440, x1=762, y0=770, y1=1010, bias=1.0, where=MD, clip=MD,
  size=function(x,y) return 3.2 + 2.8*(y-770)/240 end, light=L, piles=RUBP}
print(n)

--@ chunk 161
print(wait(6*24*60), drying(560,850), drying(700,900))
local function crestY(x) for y=760,1010 do if MD:at(x,y) > 0.5 then return y end end return 1010 end
local cy = {}
for x=440,762,2 do cy[x] = crestY(x) end
local function depth(x,y) local xi = math.floor(x/2)*2; local c = cy[xi] or 1010; return y - c end
local zone = (MD + H4 + (FLOORALL * rect(560, 840, 440, 200))) - FIG.all:grow(4) - ARK.body:grow(4) - H1:grow(2)
work(zone, {hand="glaze", pile=darkGlaze, coverage=2.2, fill=true, clip=zone, angle=-0.3,
  load_at=function(x,y)
    if MD:at(x,y) > 0.5 then return 0.85*smoothstep(8, 45, depth(x,y)) end
    return 0.8 end})
blend(zone, {angle=-0.3})

--@ chunk 162
print(wait(4*24*60), drying(850,850))
-- the drum base meets a heap that leans against it: one new dark heap shape from the mound to the right edge
local top = {{700,860},{740,846},{780,830},{815,812},{850,800},{885,792},{920,788},{955,790},{985,787},{1005,786}}
H6 = outline{pts=top, char="broken", amount=0.5, seed=66}:below(1010) * rect(690, 760, 320, 260) - MD:shrink(2) - FIG.all:grow(4)
local heapDeep = pile{{"bone black",1.5},{"Mars brown",1},{"yellow ochre",0.25},{"lead white",0.08}}
work(H6, {hand="body", pile=heapDeep, coverage=3.4, fill=true, angle=-0.25, clip=H6, length={12,35}})

--@ chunk 163
for _,p in ipairs({{850,795},{850,810},{850,830},{850,900},{950,800},{950,850},{750,860}}) do print(p[1],p[2],H6:at(p[1],p[2]), drying(p[1],p[2])) end; print(H6:area())

--@ chunk 164
print(wait(3*24*60), drying(850,810))
H6 = poly({{700,862},{740,848},{780,832},{815,814},{850,802},{885,794},{920,790},{955,792},{985,789},{1005,788},{1005,1010},{700,1010}}, true):roughen(3, 14, 66) - MD:shrink(2) - FIG.all:grow(4)
local heapBlack = pile{{"bone black",2},{"Mars brown",0.8},{"ultramarine blue",0.2}}
work(H6, {hand="body", pile=heapBlack, coverage=3.4, fill=true, angle=-0.25, clip=H6, length={12,35}})
print(H6:area())

--@ chunk 165
print(wait(7*24*60)); print(drying(850,850), drying(950,950))

--@ chunk 166
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local P2 = {deep=rkDeep, dark=rkDeep, warm=rkDark2, lit1=rkWarm2, lit2=rkLit1, lit3=rkLit2}
local function crestY(x) for y=770,1010 do if H6:at(x,y) > 0.5 then return y end end return 1010 end
local cy = {}
for x=690,1004,2 do cy[x] = crestY(x) end
local function depth(x,y) local xi = math.floor(x/2)*2; return y - (cy[xi] or 1010) end
local n = rubble{n=1500, x0=690, x1=1004, y0=780, y1=1010, bias=1, where=H6, clip=H6,
  size=function(x,y) return 3.5 + 3*(y-780)/230 end,
  light=function(x,y) return 0.25*(1 - smoothstep(0, 18, depth(x,y))) + 0.05 end, piles=P2}
print(n)

--@ chunk 167
local ox, oy = AOX, AOY
local shA = poly(P(ox,oy,{{-52,-6},{20,-8},{24,-2},{16,4},{-30,7},{-58,6}}), true):soften(1.5) - ARK.body
local shF = poly(P(ox,oy,{{26,-2},{46,-4},{66,-5},{90,-4},{93,1},{75,7},{52,13},{30,14},{12,9},{18,2}}), true):soften(2) - FIG.all - ARK.body
local sh = shA + shF
local castG = pile{{"bone black",1.5},{"Mars brown",0.8},{"ultramarine blue",0.3}, medium=0.75}
work(sh, {hand="glaze", tool="filbert 5", pile=castG, coverage=2.4, fill=true, clip=sh, angle=0.1, load=0.7, length={10,30}})
-- contact: darkest line where things touch the ground
local c = brush{kind="round", width=1.6, point=0.5}
c:load(pile{{"bone black",2},{"Mars brown",0.5}}, 0.6)
c:stroke(P(ox,oy,{{-49,-1.5},{-20,-2.5},{18,-3.5}}), {pressure={0.55,0.5}})
c:load(pile{{"bone black",2},{"Mars brown",0.5}}, 0.6)
c:stroke(P(ox,oy,{{26,0.5},{45,0.2}}), {pressure={0.55,0.5}})
c:stroke(P(ox,oy,{{62,-1},{90,-0.5}}), {pressure={0.5,0.4}})

--@ chunk 168
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60), drying(380,1066), drying(450,1072))
local ox, oy = AOX, AOY
local shA = poly(P(ox,oy,{{-52,-6},{20,-8},{24,-2},{16,4},{-30,7},{-58,6}}), true):soften(1.5) - ARK.body
local shF = poly(P(ox,oy,{{26,-2},{46,-4},{66,-5},{90,-4},{93,1},{75,7},{52,13},{30,14},{12,9},{18,2}}), true):soften(2) - FIG.all - ARK.body
SHADOWS = shA + shF
local P3 = {deep=rkDeep, dark=rkDeep, warm=rkDark2, lit1=rkWarm2, lit2=rkWarm2, lit3=rkLit1}
-- pieces in shadow: dim, with their tops catching a little
local where = SHADOWS:grow(2) - FIG.all:grow(1) - ARK.body:grow(1)
local n = rubble{n=500, x0=340, x1=505, y0=1055, y1=1082, bias=1, where=where, clip=where,
  size=function(x,y) return 4 end,
  light=function(x,y) return 0.25 + 0.45*(1 - SHADOWS:at(x,y)) end, piles=P3}
print(n)

--@ chunk 169
print(wait(3*24*60))
RL = outline{{-10,1205,"c"},{40,1190},{95,1176},{150,1180},{205,1198},{248,1222},{280,1255},{300,1300},{310,1345,"c"},{-10,1345,"c"}, closed=true, char="broken", amount=0.8, seed=171}:mask()
RR = outline{{1010,1160,"c"},{960,1168},{900,1185},{850,1205},{800,1238},{770,1275},{752,1345,"c"},{1010,1345,"c"}, closed=true, char="broken", amount=0.8, seed=172}:mask()
local rep = pile{{"bone black",2},{"Mars brown",0.6},{"ultramarine blue",0.3}}
work(RL, {hand="body", pile=rep, coverage=3.4, fill=true, angle=-0.3, clip=RL, length={15,45}})
work(RR, {hand="body", pile=rep, coverage=3.4, fill=true, angle=0.3, clip=RR, length={15,45}})

--@ chunk 170
print(wait(6*24*60)); print(drying(100,1250), drying(900,1250))

--@ chunk 171
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60), drying(900,1250))
local P2 = {deep=rkDeep, dark=rkDeep, warm=rkDark2, lit1=rkWarm2, lit2=rkLit1, lit3=rkLit2}
local function topY(m, x, y0) for y=y0,1333 do if m:at(x,y) > 0.5 then return y end end return 1340 end
local tl, tr = {}, {}
for x=0,320,2 do tl[x] = topY(RL, x, 1150) end
for x=740,1000,2 do tr[x] = topY(RR, x, 1130) end
local function dL(x,y) return y - (tl[math.floor(x/2)*2] or 1340) end
local function dR(x,y) return y - (tr[math.floor(x/2)*2] or 1340) end
-- faint light from the pool catching the tops nearest it
local function lightL(x,y) return 0.32*(1 - smoothstep(0, 14, dL(x,y))) * smoothstep(60, 260, x) + 0.03 end
local function lightR(x,y) return 0.32*(1 - smoothstep(0, 14, dR(x,y))) * smoothstep(980, 780, x) + 0.03 end
local n1 = rubble{n=1300, x0=0, x1=320, y0=1170, y1=1333, bias=1, where=RL, clip=RL, size=function(x,y) return 9 + 8*(y-1170)/163 end, light=lightL, piles=P2}
local n2 = rubble{n=1300, x0=740, x1=1000, y0=1150, y1=1333, bias=1, where=RR, clip=RR, size=function(x,y) return 9 + 8*(y-1150)/183 end, light=lightR, piles=P2}
print(n1, n2)

--@ chunk 172
print(wait(4*24*60), drying(900,1250), drying(100,1250))
local R = (RL + RR)
work(R, {hand="glaze", pile=darkGlaze, coverage=2.0, fill=true, clip=R, angle=0.2,
  load_at=function(x,y) return 0.85 end})
blend(R, {angle=0.2})

--@ chunk 173
local m = (rect(255, 50, 160, 70):roughen(5, 20, 3)) - LT:grow(2)
-- match the vault: vault dark body + then the same dark glaze treatment later
work(m, {hand="body", pile=vaultDark, coverage=3.4, fill=true, angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end, clip=m:blur(3), length={20,50}})

--@ chunk 174
print(wait(8*24*60)); print(drying(330,85), drying(900,1250))

--@ chunk 175
GA = math.pi * (3 - math.sqrt(5))
-- one scale plate of a phyllotactic dome centered at C (squash sq); r = c * n^ex
-- tools = {bodies={{maxsize, brush},...}, be=edge brush, bs=shadow brush}
function plate3(C, n, c, ex, sq, tools, okmask, light)
  local r = c * n^ex
  local th = n * GA
  local x = C[1] + r*math.cos(th)
  local y = C[2] + sq*r*math.sin(th)
  if x < -30 or x > 1030 or y < -30 or y > 1360 then return false end
  if okmask and okmask:at(x,y) < 0.5 then return false end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local rx, ry = C[1]-x, C[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  -- spacing between neighbours at this radius
  local dr = c * ex * n^(ex-1) * 1.0
  local s = math.sqrt(2*math.pi*r*dr) * (0.92 + 0.16*math.random())
  local half = s*0.55
  local radial = s*(0.4 + 0.6*sq)*0.5
  local bb
  for _,e in ipairs(tools.bodies) do if s <= e[1] then bb = e[2]; break end end
  bb = bb or tools.bodies[#tools.bodies][2]
  bb:stroke({{x - tx*half*0.75, y - ty*half*0.75}, {x - rx*radial*0.15, y - ry*radial*0.15}, {x + tx*half*0.75, y + ty*half*0.75}}, {pressure={0.85,0.75}, ramps={0.15,0.25}})
  local ox, oy = -rx*radial*0.8, -ry*radial*0.8
  tools.bs:stroke({{x - tx*half*0.9 + ox*0.7, y - ty*half*0.9 + oy*0.7}, {x + ox, y + oy}, {x + tx*half*0.9 + ox*0.7, y + ty*half*0.9 + oy*0.7}}, {pressure={0.5,0.15}, ramps={0.2,0.4}})
  local ix, iy = rx*radial*0.6, ry*radial*0.6
  local L = light or 1
  if L > 0.05 then
    tools.be:stroke({{x - tx*half*0.8 + ix*0.5, y - ty*half*0.8 + iy*0.5}, {x + ix, y + iy}, {x + tx*half*0.8 + ix*0.5, y + ty*half*0.8 + iy*0.5}}, {pressure={0.5*L,0.08}, ramps={0.25,0.5}})
  end
  return true, r, s
end
local m = (rect(255, 50, 160, 70):roughen(5, 20, 3)) - LT:grow(2)
local warmish = pile{{"burnt sienna",1},{"bone brown",0.6}, medium=0.85}
work(m, {hand="glaze", pile=warmish, coverage=1.4, fill=true, clip=m:blur(5), angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end, load=0.25})
blend(m:grow(4), {angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end})

--@ chunk 176
print(wait(5*24*60), drying(330,85))
local m = (rect(255, 50, 160, 70):roughen(5, 20, 3)) - LT:grow(2)
work(m, {hand="glaze", pile=darkGlaze, coverage=1.4, fill=true, clip=m:blur(5), angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end, load=0.3})
blend(m:grow(4), {angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end})

--@ chunk 177
GA = math.pi * (3 - math.sqrt(5))
-- one scale plate of a phyllotactic dome centered at C (squash sq); r = c * n^ex
-- tools = {bodies={{maxsize, brush},...}, be=edge brush, bs=shadow brush}
function plate3(C, n, c, ex, sq, tools, okmask, light)
  local r = c * n^ex
  local th = n * GA
  local x = C[1] + r*math.cos(th)
  local y = C[2] + sq*r*math.sin(th)
  if x < -30 or x > 1030 or y < -30 or y > 1360 then return false end
  if okmask and okmask:at(x,y) < 0.5 then return false end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local rx, ry = C[1]-x, C[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  -- spacing between neighbours at this radius
  local dr = c * ex * n^(ex-1) * 1.0
  local s = math.sqrt(2*math.pi*r*dr) * (0.92 + 0.16*math.random())
  local half = s*0.55
  local radial = s*(0.4 + 0.6*sq)*0.5
  local bb
  for _,e in ipairs(tools.bodies) do if s <= e[1] then bb = e[2]; break end end
  bb = bb or tools.bodies[#tools.bodies][2]
  bb:stroke({{x - tx*half*0.75, y - ty*half*0.75}, {x - rx*radial*0.15, y - ry*radial*0.15}, {x + tx*half*0.75, y + ty*half*0.75}}, {pressure={0.85,0.75}, ramps={0.15,0.25}})
  local ox, oy = -rx*radial*0.8, -ry*radial*0.8
  tools.bs:stroke({{x - tx*half*0.9 + ox*0.7, y - ty*half*0.9 + oy*0.7}, {x + ox, y + oy}, {x + tx*half*0.9 + ox*0.7, y + ty*half*0.9 + oy*0.7}}, {pressure={0.5,0.15}, ramps={0.2,0.4}})
  local ix, iy = rx*radial*0.6, ry*radial*0.6
  local L = light or 1
  if L > 0.05 then
    tools.be:stroke({{x - tx*half*0.8 + ix*0.5, y - ty*half*0.8 + iy*0.5}, {x + ix, y + iy}, {x + tx*half*0.8 + ix*0.5, y + ty*half*0.8 + iy*0.5}}, {pressure={0.5*L,0.08}, ramps={0.25,0.5}})
  end
  return true, r, s
end
print(wait(3*24*60))
local bodyFar  = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.4}, medium=0.1}
local edgeFar  = pile{{"burnt sienna",2},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",1}, medium=0.1}
local tools = {bodies={{14, brush("filbert",9)},{20, brush("filbert",12)},{27, brush("filbert",16)},{99, brush("filbert",21)}},
  be=brush{kind="round", width=2.2, point=0.7}, bs=brush{kind="round", width=3.0, point=0.5}}
local ok = (rect(250, 45, 170, 80)) - LT:grow(2)
local k = 0
local c, ex, sq = 4, 0.7, 0.6
for n=1439,69,-1 do
  local r = c*n^ex
  if k % 4 == 0 then for _,e in ipairs(tools.bodies) do e[2]:load(bodyFar,0.5) end; tools.be:load(edgeFar,0.45); tools.bs:load(shP,0.5) end
  local okk = plate3(OC, n, c, ex, sq, tools, ok, 0.2)
  if okk then k = k + 1 end
end
print(k)

--@ chunk 178
print(wait(6*24*60), drying(330,85))
local m = (rect(245, 40, 180, 90)) - LT:grow(2)
work(m, {hand="glaze", pile=darkGlaze, coverage=1.8, fill=true, clip=m:blur(8), angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end, load=0.55})
blend(m:grow(6), {angle=function(x,y) return math.atan(y-170, x-735) + math.pi/2 end})

--@ chunk 179
print(wait(8*24*60)); print(drying(330,85), drying(280,60), drying(900,1250))

--@ chunk 180
print(wait(20*24*60)); print(drying(330,85), drying(280,60), drying(400,100))

--@ chunk 181
print(wait(30*24*60)); print(drying(330,85), drying(280,60), drying(400,100))

--@ chunk 182
print(wait(40*24*60)); print(drying(330,85), drying(280,60), drying(400,100))

--@ chunk 183
GA = math.pi * (3 - math.sqrt(5))
-- one scale plate of a phyllotactic dome centered at C (squash sq); r = c * n^ex
-- tools = {bodies={{maxsize, brush},...}, be=edge brush, bs=shadow brush}
function plate3(C, n, c, ex, sq, tools, okmask, light)
  local r = c * n^ex
  local th = n * GA
  local x = C[1] + r*math.cos(th)
  local y = C[2] + sq*r*math.sin(th)
  if x < -30 or x > 1030 or y < -30 or y > 1360 then return false end
  if okmask and okmask:at(x,y) < 0.5 then return false end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local rx, ry = C[1]-x, C[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  -- spacing between neighbours at this radius
  local dr = c * ex * n^(ex-1) * 1.0
  local s = math.sqrt(2*math.pi*r*dr) * (0.92 + 0.16*math.random())
  local half = s*0.55
  local radial = s*(0.4 + 0.6*sq)*0.5
  local bb
  for _,e in ipairs(tools.bodies) do if s <= e[1] then bb = e[2]; break end end
  bb = bb or tools.bodies[#tools.bodies][2]
  bb:stroke({{x - tx*half*0.75, y - ty*half*0.75}, {x - rx*radial*0.15, y - ry*radial*0.15}, {x + tx*half*0.75, y + ty*half*0.75}}, {pressure={0.85,0.75}, ramps={0.15,0.25}})
  local ox, oy = -rx*radial*0.8, -ry*radial*0.8
  tools.bs:stroke({{x - tx*half*0.9 + ox*0.7, y - ty*half*0.9 + oy*0.7}, {x + ox, y + oy}, {x + tx*half*0.9 + ox*0.7, y + ty*half*0.9 + oy*0.7}}, {pressure={0.5,0.15}, ramps={0.2,0.4}})
  local ix, iy = rx*radial*0.6, ry*radial*0.6
  local L = light or 1
  if L > 0.05 then
    tools.be:stroke({{x - tx*half*0.8 + ix*0.5, y - ty*half*0.8 + iy*0.5}, {x + ix, y + iy}, {x + tx*half*0.8 + ix*0.5, y + ty*half*0.8 + iy*0.5}}, {pressure={0.5*L,0.08}, ramps={0.25,0.5}})
  end
  return true, r, s
end
local bodyD = pile{{"bone black",2},{"Mars brown",1},{"burnt sienna",0.3}, medium=0.1}
local edgeD = pile{{"bone black",1},{"burnt sienna",1}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",0.6}, medium=0.1}
local tools = {bodies={{14, brush("filbert",9)},{20, brush("filbert",12)},{27, brush("filbert",16)},{99, brush("filbert",21)}},
  be=brush{kind="round", width=2.0, point=0.7}, bs=brush{kind="round", width=2.8, point=0.5}}
local ok = (rect(262, 52, 150, 66)) - LT:grow(2)
local k = 0
local c, ex, sq = 4, 0.7, 0.6
for n=1439,69,-1 do
  if k % 4 == 0 then for _,e in ipairs(tools.bodies) do e[2]:load(bodyD,0.5) end; tools.be:load(edgeD,0.45); tools.bs:load(shP,0.5) end
  if plate3(OC, n, c, ex, sq, tools, ok, 0.35) then k = k + 1 end
end
print(k)

--@ chunk 184
print(drying(442,1001))
local v = brush{kind="round", width=1.2, point=0.8}
v:load(coldHalo, 0.5)
v:stroke(P(AOX,AOY,{{36.5,-63.5},{37.5,-61.2},{40,-60.2}}), {pressure={0.4,0.15}, clip=FIG.all})

--@ chunk 185
local function L(pts) return P(AOX, AOY, pts) end
-- antenna from the pack, catching the light at its tip
local a = brush{kind="round", width=0.9, point=0.9}
a:load(frameDark2, 0.6)
a:stroke(L({{70,-60},{72.5,-68},{74.5,-75}}), {pressure={0.6,0.35}})
local t = brush{kind="round", width=1.0, point=0.8}
t:load(rimP, 0.6)
t:stroke(L({{72.6,-68},{74.3,-74.6}}), {pressure={0.35,0.1}})
-- visor: a cold slit facing the ark
local v = brush{kind="round", width=1.3, point=0.8}
v:load(coldCore, 0.6)
v:stroke(L({{35.8,-65.5},{36.6,-62.6}}), {pressure={0.5,0.3}})
-- shoulder plate edge and elbow joint in warm bounce
local s = brush{kind="round", width=1.0, point=0.8}
s:load(bounceP, 0.5)
s:stroke(L({{44,-59},{49,-61.5},{54,-61.5}}), {pressure={0.35,0.15}, clip=FIG.all})
s:touch(AOX+35, AOY-45.5, {pressure=0.3, clip=FIG.all})
s:stroke(L({{40,-27.5},{36,-25.5}}), {pressure={0.3,0.1}, clip=FIG.all})

--@ chunk 186
local v = brush{kind="round", width=1.8, point=0.4}
v:load(coldCore, 0.8)
v:touch(AOX+37, AOY-63.5, {pressure=0.55})
v:touch(AOX+37.4, AOY-61.8, {pressure=0.45})

--@ chunk 187
print(wait(30*24*60)); print(drying(330,85), drying(280,60), drying(400,100))

--@ chunk 188
print(wait(90*24*60)); print(drying(330,85), drying(280,60), drying(400,100))

--@ chunk 189
print(wait(180*24*60)); print(drying(330,85), drying(280,60), drying(300,100))

--@ chunk 190
vaultMatch = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.4}}
local m = (rect(244, 40, 182, 95):roughen(6, 25, 13)) - LT:grow(3)
local radial = function(x,y) return math.atan(y-170, x-735) + math.pi/2 end
work(m, {hand="body", pile=vaultMatch, coverage=3.6, fill=true, angle=radial, edge="soft", length={15,40}})

--@ chunk 191
GA = math.pi * (3 - math.sqrt(5))
-- one scale plate of a phyllotactic dome centered at C (squash sq); r = c * n^ex
-- tools = {bodies={{maxsize, brush},...}, be=edge brush, bs=shadow brush}
function plate3(C, n, c, ex, sq, tools, okmask, light)
  local r = c * n^ex
  local th = n * GA
  local x = C[1] + r*math.cos(th)
  local y = C[2] + sq*r*math.sin(th)
  if x < -30 or x > 1030 or y < -30 or y > 1360 then return false end
  if okmask and okmask:at(x,y) < 0.5 then return false end
  local tx, ty = -math.sin(th), sq*math.cos(th)
  local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
  local rx, ry = C[1]-x, C[2]-y; local rl = math.sqrt(rx*rx+ry*ry)+1e-6; rx, ry = rx/rl, ry/rl
  -- spacing between neighbours at this radius
  local dr = c * ex * n^(ex-1) * 1.0
  local s = math.sqrt(2*math.pi*r*dr) * (0.92 + 0.16*math.random())
  local half = s*0.55
  local radial = s*(0.4 + 0.6*sq)*0.5
  local bb
  for _,e in ipairs(tools.bodies) do if s <= e[1] then bb = e[2]; break end end
  bb = bb or tools.bodies[#tools.bodies][2]
  bb:stroke({{x - tx*half*0.75, y - ty*half*0.75}, {x - rx*radial*0.15, y - ry*radial*0.15}, {x + tx*half*0.75, y + ty*half*0.75}}, {pressure={0.85,0.75}, ramps={0.15,0.25}})
  local ox, oy = -rx*radial*0.8, -ry*radial*0.8
  tools.bs:stroke({{x - tx*half*0.9 + ox*0.7, y - ty*half*0.9 + oy*0.7}, {x + ox, y + oy}, {x + tx*half*0.9 + ox*0.7, y + ty*half*0.9 + oy*0.7}}, {pressure={0.5,0.15}, ramps={0.2,0.4}})
  local ix, iy = rx*radial*0.6, ry*radial*0.6
  local L = light or 1
  if L > 0.05 then
    tools.be:stroke({{x - tx*half*0.8 + ix*0.5, y - ty*half*0.8 + iy*0.5}, {x + ix, y + iy}, {x + tx*half*0.8 + ix*0.5, y + ty*half*0.8 + iy*0.5}}, {pressure={0.5*L,0.08}, ramps={0.25,0.5}})
  end
  return true, r, s
end
local bodyM = pile{{"bone black",2},{"burnt sienna",1},{"lead white",0.12}, medium=0.1}
local edgeM = pile{{"burnt sienna",2},{"raw sienna",1},{"bone brown",0.5}, medium=0.1}
local shP = pile{{"bone black",2},{"ultramarine blue",0.6}, medium=0.1}
local tools = {bodies={{14, brush("filbert",9)},{20, brush("filbert",12)},{27, brush("filbert",16)},{99, brush("filbert",21)}},
  be=brush{kind="round", width=1.6, point=0.8}, bs=brush{kind="round", width=2.8, point=0.5}}
local ok = (rect(248, 44, 174, 88)) - LT:grow(3)
local k = 0
local c, ex, sq = 4, 0.7, 0.6
for n=1439,69,-1 do
  if k % 4 == 0 then for _,e in ipairs(tools.bodies) do e[2]:load(bodyM,0.35) end; tools.be:load(edgeM,0.4); tools.bs:load(shP,0.45) end
  if plate3(OC, n, c, ex, sq, tools, ok, 0.3) then k = k + 1 end
end
print(k)

--@ chunk 192
print(wait(60*24*60)); print(drying(330,85), drying(280,60), drying(300,100), drying(400,70))

--@ chunk 193
print(wait(300*24*60)); print(drying(330,85), drying(280,60), drying(300,100), drying(400,70))

--@ chunk 194
local m = (rect(246, 42, 178, 92):roughen(6, 25, 13)) - LT:grow(3)
local radial = function(x,y) return math.atan(y-170, x-735) + math.pi/2 end
work(m, {hand="glaze", pile=darkGlaze, coverage=2.0, fill=true, clip=m:blur(6), angle=radial, load=0.6})

--@ chunk 195
print(wait(10*24*60), drying(330,85))
local GA = math.pi * (3 - math.sqrt(5))
local ok = (rect(250, 46, 170, 84)) - LT:grow(3)
local edgeM = pile{{"burnt sienna",2},{"raw sienna",1},{"bone brown",0.5}, medium=0.1}
local be = brush{kind="round", width=1.3, point=0.9}
local c, ex, sq = 4, 0.7, 0.6
local k = 0
for n=1439,69,-1 do
  local r = c*n^ex
  local th = n*GA
  local x = OC[1] + r*math.cos(th); local y = OC[2] + sq*r*math.sin(th)
  if ok:at(x,y) > 0.5 and math.random() < 0.75 then
    local tx, ty = -math.sin(th), sq*math.cos(th); local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
    local rx, ry = OC[1]-x, OC[2]-y; local rl = math.sqrt(rx*rx+ry*ry); rx, ry = rx/rl, ry/rl
    local dr = c*ex*n^(ex-1)
    local s = math.sqrt(2*math.pi*r*dr)
    local h = s*0.45
    if k % 3 == 0 then be:load(edgeM, 0.4) end
    k = k + 1
    -- one hairline arc on the lit (inner) side, short, like the surrounding plates
    be:stroke({{x - tx*h*0.6 + rx*h*0.2, y - ty*h*0.6 + ry*h*0.2}, {x + rx*h*0.45, y + ry*h*0.45}, {x + tx*h*0.5 + rx*h*0.3, y + ty*h*0.5 + ry*h*0.3}}, {pressure={0.3,0.05}, ramps={0.2,0.6}})
  end
end
print(k)

--@ chunk 196
print(wait(30*24*60), drying(330,85), drying(300,100))
local m = (rect(246, 42, 178, 92):roughen(6, 25, 13)) - LT:grow(3)
local radial = function(x,y) return math.atan(y-170, x-735) + math.pi/2 end
work(m, {hand="glaze", pile=darkGlaze, coverage=1.6, fill=true, clip=m:blur(6), angle=radial, load=0.4})

--@ chunk 197
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
local outer = (SHADOWS:grow(2) * mask(function(x,y) return y > AOY + 1.5 and 1 or 0 end)) - FIG.all:grow(1) - ARK.body:grow(1)
local n = rubble{n=380, x0=330, x1=510, y0=AOY, y1=AOY+20, bias=1, where=outer, clip=outer,
  size=function(x,y) return 4 end,
  light=function(x,y) return 0.35 + 0.5*smoothstep(AOY+2, AOY+12, y) end, piles=RUBP}
print(n)

--@ chunk 198
-- rubble: angular facets laid with flat brushes over a dark floor
function rubble(o)
  local brushes = {}
  local function getb(w)
    local key = math.floor(w + 0.5)
    if key < 2 then key = 2 end
    if not brushes[key] then brushes[key] = {b=brush("flat", key), n=0, p=nil} end
    return brushes[key]
  end
  local function use(bb, p, load)
    if bb.p ~= p or bb.n % 3 == 0 then bb.b:reload(p, load or 0.55); bb.p = p end
    bb.n = bb.n + 1
    return bb.b
  end
  local P = o.piles
  local cnt = 0
  for i=1,o.n do
    local x = rand(o.x0, o.x1)
    local y = o.y0 + (o.y1 - o.y0) * (rand(0,1)^o.bias)
    if o.where:at(x,y) > 0.5 then
      local s = o.size(x,y) * rand(0.5, 1.5)
      local L = clamp(o.light(x,y) + randn(0, 0.1), 0, 1)
      -- facet facing up-right gets more light; others less
      local face = rand(0,1)
      local Lf = L * (0.35 + 0.65*face)
      local mid = (Lf < 0.12) and P.dark or ((Lf < 0.35) and P.warm or ((Lf < 0.62) and P.lit1 or P.lit2))
      local a = rand(-0.9, 0.9) * 0.6
      local ca, sa = math.cos(a), math.sin(a)
      local hl = s*rand(0.25, 0.6)
      local b = use(getb(s*rand(0.4,0.8)), mid)
      b:stroke({{x - ca*hl, y - sa*hl}, {x + ca*hl, y + sa*hl}}, {pressure={0.7,0.7}, ramps={0.05,0.1}, orient=a + math.pi/2 + rand(-0.5,0.5), clip=o.clip})
      if Lf > 0.55 and math.random() < 0.6 then
        local bh = use(getb(math.max(2, s*0.3)), (Lf > 0.8) and P.lit3 or P.lit2)
        bh:stroke({{x - ca*hl*0.5, y - s*0.18}, {x + ca*hl*0.7, y - s*0.22}}, {pressure={0.55,0.4}, ramps={0.05,0.2}, clip=o.clip})
      end
      cnt = cnt + 1
    end
  end
  return cnt
end
print(wait(3*24*60))
local outer = (SHADOWS:grow(3)) - FIG.all:grow(2.5) - ARK.body:grow(2.5)
local n = rubble{n=500, x0=330, x1=510, y0=AOY-12, y1=AOY+20, bias=1, where=outer, clip=outer,
  size=function(x,y) return 3.5 end,
  light=function(x,y) return 0.5 + 0.4*smoothstep(AOY, AOY+12, y) end, piles=RUBP}
print(n)

--@ chunk 199
print(wait(3*24*60), drying(450,1030))
local F = FIG.all
local up = mask(function(x,y) return F:at(x - 1.2, y + 1.6) end)
local bottomRim = (F - up) * mask(function(x,y) return (y < AOY - 6) and 1 or 0 end)
local nz = noise{seed=44, period=5}
local broken = bottomRim * mask(function(x,y) return nz:at01(x,y) > 0.4 and 1 or 0 end)
bounce2 = pile{{"Mars brown",1},{"yellow ochre",1.2},{"lead white",0.5},{"bone black",0.3}}
work(broken, {hand="detail", tool={kind="round", width=1.2, point=0.7}, pile=bounce2, coverage=1.8, fill=true, clip=true, angle=0.6, load=0.45})
print(bottomRim:area())
