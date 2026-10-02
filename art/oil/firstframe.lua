-- easel session "firstframe": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=2077,
  ground={{pile={{"bone black",2},{"lead white",1},{"burnt sienna",0.8},{"ultramarine blue",0.4}}, um=90, apply="knife", texture=0.35}}}
print(W,H)

--@ chunk 2
NX, NY = 250, 415
UX, UY = 0.959, -0.284
VX, VY = 0.284, 0.959
function P(t, s) return {NX + UX*t + VX*s, NY + UY*t + VY*s} end
-- seed radius profile: ogive nose over first 170
function R(t) if t < 170 then local u = t/170; return 122*math.sqrt(1-(1-u)^2) else return 122 end end
local top, bot = {}, {}
for t = 0, 900, 30 do top[#top+1] = P(t, -R(t)); bot[#bot+1] = P(t, R(t)) end
local c = chalk()
c:line(top, {pressure=0.35})
c:line(bot, {pressure=0.35})
-- opening lens
local op_top, op_bot = {}, {}
for t = 200, 520, 20 do
  local k = math.sin(math.pi*(t-200)/320)
  op_top[#op_top+1] = P(t, -30 - 70*k)
  op_bot[#op_bot+1] = P(t, 20 + 90*k)
end
c:line(op_top, {pressure=0.3}); c:line(op_bot, {pressure=0.3})
-- floor line and VP rays
c:rule({0, 400}, {1000, 392}, {pressure=0.2})
for _, x in ipairs({-300, 0, 200, 900, 1300}) do c:rule({470, 300}, {x, 562}, {pressure=0.12}) end
-- breach
c:line({{700,0},{730,40},{790,70},{850,60},{910,100},{960,80},{1000,110}}, {pressure=0.3})
-- crates
for _, r in ipairs({{30,330,110,130},{140,360,100,100},{50,230,95,100}}) do
  local x,y,w,h = table.unpack(r)
  c:line({{x,y},{x+w,y},{x+w,y+h},{x,y+h},{x,y}}, {pressure=0.3, smooth=false})
end
-- frame stick figure
c:line({{565,272},{560,300}}, {pressure=0.4})            -- head/neck
c:line({{540,312},{585,310}}, {pressure=0.4})            -- shoulders
c:line({{562,305},{558,400}}, {pressure=0.4})            -- spine
c:line({{558,400},{535,455},{530,520}}, {pressure=0.4})  -- left leg (viewer's left)
c:line({{560,400},{590,450},{600,515}}, {pressure=0.4})  -- right leg
c:line({{585,310},{615,350},{640,370}}, {pressure=0.4})  -- arm to husk lip
c:line({{540,312},{520,360},{515,400}}, {pressure=0.4})  -- hanging arm

--@ chunk 3
local top, bot = {}, {}
for t = 0, 960, 20 do top[#top+1] = P(t, -R(t)) end
for t = 960, 0, -20 do bot[#bot+1] = P(t, R(t)) end
local pts = {}
for _, p in ipairs(top) do pts[#pts+1] = p end
for _, p in ipairs(bot) do pts[#pts+1] = p end
seedM = poly(pts, true)
breachM = poly({{620,0},{1000,0},{1000,60},{960,40},{930,58},{885,30},{850,48},{800,30},{760,50},{700,30},{660,20}}) 
-- breach hole: from torn ceiling edge down to the seed top; build as region above seed top edge right of x 640, below a torn line
local torn = {{640,0},{655,22},{690,34},{720,24},{748,46},{790,38},{820,58},{860,44},{895,66},{930,52},{965,74},{1000,62}}
breachM = poly((function()
  local q = {} for _, p in ipairs(torn) do q[#q+1] = p end
  q[#q+1] = {1000, 0}
  return q end)())
breachM = (below(torn) * rect(600, 0, 400, 300)) - seedM
cratesM = rect(30,330,110,130) + rect(140,360,100,100) + rect(50,230,95,100)
wallM = rect(0,0,1000,400) - seedM - breachM - cratesM
deckM = rect(0,398,1000,165) - seedM - cratesM
print(seedM:area(), breachM:area(), wallM:area())

--@ chunk 4
wallP = pile{{"bone black",2},{"ultramarine ash",1},{"bone brown",0.6},{"lead white",0.35}}
deckP = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.5},{"lead white",0.3}}
spaceP = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",1.2}}
work(wallM, {hand="broad", pile=wallP, angle=function(x,y) return (math.floor(y/90)%2==0) and 0 or math.pi/2 end, coverage=3, fill=true, clip=true})
work(deckM, {hand="broad", pile=deckP, angle=function(x,y) return math.atan(y-300, x-470) end, coverage=3, fill=true, clip=true})
work(breachM, {hand="body", pile=spaceP, coverage=3.5, fill=true, clip=true})

--@ chunk 5
wallP2 = pile{{"bone black",2},{"ultramarine blue",0.6},{"bone brown",1}}
deckP2 = pile{{"bone brown",2},{"bone black",1.5},{"ultramarine blue",0.4}}
spaceP2 = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.6}}
work(wallM, {hand="body", pile=wallP2, angle=function(x,y) return (math.floor(x/120)%2==0) and math.pi/2 or 0 end, coverage=3, fill=true, clip=true, load=0.9})
work(deckM, {hand="body", pile=deckP2, angle=function(x,y) return math.atan(y-300, x-470) end, coverage=3, fill=true, clip=true, load=0.9})
work(breachM, {hand="body", pile=spaceP2, coverage=3, fill=true, clip=true})

--@ chunk 6
local a, b = {}, {}
for t = 190, 530, 10 do
  local k = math.sin(math.pi*(t-190)/340)
  a[#a+1] = P(t, -25 - 75*k)
end
for t = 530, 190, -10 do
  local k = math.sin(math.pi*(t-190)/340)
  b[#b+1] = P(t, 15 + 95*k^0.8)
end
local q = {} for _,p in ipairs(a) do q[#q+1]=p end for _,p in ipairs(b) do q[#q+1]=p end
openM = poly(q, true)
-- upper petal: peeled up and out from the top lip; ragged free edge
upPetM = outline{{430,300,"c"},{470,215},{530,165},{600,140,"c"},{640,150},{690,128,"c"},{720,175},{745,215},{725,232,"c"},{650,215},{560,225},{480,270}, char="broken", seed=5, amount=0.6}:mask()
-- lower petal folded down toward us
loPetM = outline{{445,378,"c"},{520,420},{600,433},{690,415},{745,372,"c"},{770,420},{750,470,"c"},{690,488},{640,478,"c"},{580,500},{510,486,"c"},{460,450}, char="broken", seed=6, amount=0.6}:mask()
print(openM:area(), upPetM:area(), loPetM:area())
local c = chalk()

--@ chunk 7
hullP = pile{{"bone black",2},{"burnt sienna",1},{"Mars brown",1}}
work(seedM - openM, {hand="body", pile=hullP, angle=function(x,y) return math.atan(VY, VX) end, coverage=3.5, fill=true, clip=true, load=0.9})

--@ chunk 8
CX, CY = 598, 318
local function dist(x,y) return math.sqrt((x-CX)^2 + ((y-CY)*1.15)^2) end
local function zone(lo, hi) return mask(function(x,y) local d = dist(x,y); return (d>=lo and d<hi) and 1 or 0 end) * openM end
coreP = pile{{"lead white",3},{"lemon chrome",1}}
yelP = pile{{"cadmium yellow",2},{"lead white",1}}
oraP = pile{{"Mars orange",1},{"cadmium yellow",1},{"cadmium red",0.3}}
redP = pile{{"cadmium red",1},{"burnt sienna",1}}
deepP = pile{{"burnt sienna",1},{"cadmium red",0.5},{"bone brown",1}}
local rad = function(x,y) return math.atan(y-CY, x-CX) end
work(zone(150, 999), {hand="body", pile=deepP, angle=rad, coverage=3, fill=true, clip=true})
work(zone(105, 150), {hand="body", pile=redP, angle=rad, coverage=3, fill=true, clip=true})
work(zone(65, 105), {hand="body", pile=oraP, angle=rad, coverage=3, fill=true, clip=true})
work(zone(32, 65), {hand="body", pile=yelP, angle=rad, coverage=3, fill=true, clip=true})
work(zone(0, 32), {hand="body", pile=coreP, angle=rad, coverage=4, fill=true, clip=true})

--@ chunk 9
local rad = function(x,y) return math.atan(y-CY, x-CX) end
local tan = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
blend(openM, {angle=rad})
blend(openM, {angle=tan})
blend(openM:shrink(4), {angle=rad})

--@ chunk 10
print(wait(240)); print(drying(598,318), drying(470,330), drying(300,100), drying(800,300))

--@ chunk 11
local function dist(x,y) return math.sqrt((x-CX)^2 + ((y-CY)*1.15)^2) end
local function disc(r) return mask(function(x,y) return dist(x,y) < r and 1 or 0 end) end
local rad = function(x,y) return math.atan(y-CY, x-CX) end
local tan = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
work(disc(110):roughen(8, 30, 3) * openM - disc(70), {hand="body", tool="filbert 6", pile=oraP, angle=rad, coverage=2.5, fill=true, clip=true})
work(disc(72):roughen(6, 25, 4) - disc(38), {hand="body", tool="filbert 6", pile=yelP, angle=tan, coverage=3, fill=true, clip=true})
work(disc(40):roughen(4, 20, 5), {hand="body", tool="filbert 5", pile=coreP, angle=tan, coverage=4, fill=true, clip=true})
blend(disc(115), {tool={kind="badger", width=14}, angle=rad, pressure={0.2,0.4}, coverage=1.5})

--@ chunk 12
upPetM = outline{{436,330,"c"},{428,285},{452,232},{495,180},{555,132,"c"},{600,118},{640,98,"c"},{700,110},{735,135,"c"},{762,175},{778,222,"c"},{752,244},{705,224},{659,212},{600,208},{555,222},{505,255},{465,292}, char="broken", seed=15, amount=0.5}:mask()
loPetM = outline{{447,375,"c"},{530,412},{626,420},{705,372},{756,290,"c"},{776,330},{772,392,"c"},{735,452},{690,486,"c"},{630,505},{565,512,"c"},{505,497},{462,455,"c"},{440,410}, char="broken", seed=16, amount=0.5}:mask()
local function dist(x,y) return math.sqrt((x-CX)^2 + ((y-CY)*1.15)^2) end
local function ring(lo,hi) return mask(function(x,y) local d=dist(x,y) return (d>=lo and d<hi) and 1 or 0 end) end
local rad = function(x,y) return math.atan(y-CY, x-CX) end
petLoP = pile{{"burnt sienna",1},{"bone brown",1.5},{"cadmium red",0.3}}
for _, pm in ipairs({upPetM - openM, loPetM - openM}) do
  work(pm * ring(0,150), {hand="body", tool="filbert 7", pile=redP, angle=rad, coverage=3, fill=true, clip=true})
  work(pm * ring(150,195), {hand="body", tool="filbert 7", pile=deepP, angle=rad, coverage=3, fill=true, clip=true})
  work(pm * ring(195,999), {hand="body", tool="filbert 7", pile=petLoP, angle=rad, coverage=3, fill=true, clip=true})
  blend(pm:shrink(2), {tool={kind="badger", width=16}, angle=rad, pressure={0.2,0.4}, coverage=1.5})
end

--@ chunk 13
print(wait(1440)); for _,p in ipairs({{598,318},{600,150},{300,100},{800,300},{500,500},{100,300}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 14
print(wait(2880)); for _,p in ipairs({{598,318},{600,150},{300,100},{800,300},{500,500},{100,300}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 15
print(wait(2880)); for _,p in ipairs({{600,150},{300,100},{800,300},{500,500}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 16
print(wait(7*1440)); for _,p in ipairs({{600,150},{300,100},{800,300},{500,500}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 17
panA = pile{{"bone black",2},{"ultramarine ash",0.7},{"lead white",0.18}}
panB = pile{{"bone black",2},{"ultramarine ash",0.5},{"bone brown",0.5},{"lead white",0.1}}
panC = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.35}}
local xs = {0, 52, 120, 203, 300, 378, 470, 543, 640}
local ys = {0, 95, 200, 290, 368}
local free = wallM - breachM
local k = 0
for i = 1, #xs-1 do for j = 1, #ys-1 do
  k = k + 1
  local p = ({panA, panB, panA, panC, panB})[(i*3 + j*2) % 5 + 1]
  local m = rect(xs[i]+2, ys[j]+2, xs[i+1]-xs[i]-4, ys[j+1]-ys[j]-4) * free
  if m:area() > 50 then
    work(m, {hand="body", tool="flat 10", pile=p, angle=(j%2==0) and 0 or math.pi/2, coverage=2.5, fill=true, clip=true, ruler=true})
  end
end end

--@ chunk 18
print(wait(2*1440)); for _,p in ipairs({{90,50},{250,250},{600,150},{500,450}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 19
print(wait(3*1440)); for _,p in ipairs({{90,50},{250,250},{600,150},{160,140}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 20
print(wait(7*1440)); for _,p in ipairs({{90,50},{250,250},{600,150},{160,140}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 21
local d1 = pile{{"bone black",2},{"ultramarine ash",0.4},{"lead white",0.07}}
local d2 = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.2}}
local d3 = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.12}}
local d4 = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.14}}
local xs = {0, 52, 120, 203, 300, 378, 470, 543, 640, 720, 800, 880, 960, 1000}
local ys = {0, 95, 200, 290, 368}
local free = wallM - upPetM - breachM
for i = 1, #xs-1 do for j = 1, #ys-1 do
  local p = ({d1, d2, d3, d4, d2})[(i*3 + j*2) % 5 + 1]
  local m = rect(xs[i]+2.5, ys[j]+2.5, xs[i+1]-xs[i]-5, ys[j+1]-ys[j]-5) * free
  if m:area() > 50 then
    work(m, {hand="body", tool="flat 10", pile=p, angle=(j%2==0) and 0 or math.pi/2, coverage=3.5, fill=true, clip=true, load=1})
  end
end end

--@ chunk 22
local function side(x, y0, y1, d)
  -- right side face receding toward VP (470,300) by fraction d
  local function toward(px, py) return {px + (470-px)*d, py + (300-py)*d} end
  local a, b = toward(x, y0), toward(x, y1)
  return poly({{x,y0}, a, b, {x,y1}})
end
crA = {30,330,110,130}; crB = {140,362,100,98}; crC = {48,228,98,102}
crFront = rect(table.unpack(crA)) + rect(table.unpack(crB)) + rect(table.unpack(crC))
crSide = side(240, 362, 460, 0.09) + (side(146, 228, 330, 0.08) - crFront)
cratesM = crFront + crSide
crateDark = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.3},{"burnt sienna",0.2}}
crateLit = pile{{"bone black",1},{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.4}}
work(crFront, {hand="body", tool="flat 8", pile=crateDark, angle=math.pi/2, coverage=3.5, fill=true, clip=true, ruler=true})
work(crSide, {hand="body", tool="flat 6", pile=crateLit, angle=math.pi/2, coverage=3.5, fill=true, clip=true, ruler=true})

--@ chunk 23
local GX, GY = 610, 470
local function dist(x,y) return math.sqrt((x-GX)^2 + ((y-GY)*2.2)^2) end
local function ring(lo,hi) return mask(function(x,y) local d=dist(x,y) return (d>=lo and d<hi) and 1 or 0 end):roughen(10, 40, 7) end
local fm = deckM - loPetM - seedM - cratesM
fl1 = pile{{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.5},{"bone brown",0.4}}
fl2 = pile{{"burnt sienna",1},{"bone brown",1},{"cadmium red",0.2}}
fl3 = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.6}}
local ang = function(x,y) return math.atan(y-300, x-470) end
work(fm * ring(260, 420), {hand="body", pile=fl3, angle=ang, coverage=3, fill=true, clip=true})
work(fm * ring(150, 260), {hand="body", pile=fl2, angle=ang, coverage=3, fill=true, clip=true})
work(fm * ring(0, 150), {hand="body", pile=fl1, angle=ang, coverage=3, fill=true, clip=true})
blend(fm * ring(0, 330), {tool={kind="badger", width=20}, angle=function(x,y) return math.atan((y-GY)*2.2, x-GX) end, pressure={0.2,0.4}, coverage=1.2})

--@ chunk 24
print(wait(10*1440)); for _,p in ipairs({{90,50},{100,400},{600,520},{160,140},{650,150}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 25
P1 = poly({{436,331},{470,296},{503,262},{537,236},{566,218},{558,186},{548,168},{528,146},{505,131},{484,140},{455,149},{440,175},{419,204},{413,236},{410,270},{420,300}})
P2 = poly({{566,218},{610,211},{659,212},{700,222},{742,240},{768,226},{785,205},{786,178},{790,150},{770,128},{745,106},{712,98},{680,90},{650,105},{615,120},{596,140},{576,166},{570,190}})
P3 = poly({{447,377},{488,397},{530,410},{580,418},{626,420},{622,445},{616,470},{598,488},{580,505},{548,503},{520,500},{494,485},{470,470},{452,446},{440,420},{438,395}})
P4 = poly({{626,420},{668,401},{705,372},{735,334},{756,290},{774,306},{790,330},{789,365},{785,400},{768,428},{745,455},{712,468},{680,480},{655,476},{630,470},{628,445}})
petals = P1 + P2 + P3 + P4
local old = (upPetM + loPetM) - openM - petals
local wallPart = old * rect(0,0,1000,398) - seedM
local deckPart = old - seedM - wallPart
local hullPart = old * seedM
local d1 = pile{{"bone black",2},{"ultramarine ash",0.4},{"lead white",0.05}}
work(wallPart, {hand="body", tool="flat 10", pile=d1, angle=math.pi/2, coverage=3.5, fill=true, clip=true})
work(deckPart, {hand="body", tool="filbert 8", pile=fl3, angle=0, coverage=3.5, fill=true, clip=true})
work(hullPart, {hand="body", tool="filbert 8", pile=hullP, angle=math.atan(VY,VX), coverage=3.5, fill=true, clip=true})
-- petal base: dark interior lining
petBase = pile{{"bone brown",1.5},{"burnt sienna",1},{"cadmium red",0.3}}
work(petals, {hand="body", tool="filbert 8", pile=petBase, angle=math.atan(VY,VX), coverage=3.5, fill=true, clip=true})

--@ chunk 26
local d = openM:distance(); print(d:at(598,318), d:at(480,200), d:at(420,250), d:at(100,100))

--@ chunk 27
local d = openM:distance()
local near = d:band(-28, 2, 6) * petals
local mid = d:band(-65, -22, 8) * petals
local gdir = function(x,y) return math.atan(y-CY, x-CX) end
work(mid, {hand="body", tool="filbert 6", pile=deepP, angle=gdir, coverage=3, fill=true, clip=true, load=0.9})
work(near, {hand="body", tool="filbert 6", pile=oraP, angle=gdir, coverage=3, fill=true, clip=true, load=0.9})
blend(petals, {tool={kind="badger", width=14}, angle=gdir, pressure={0.2,0.35}, coverage=1.2})

--@ chunk 28
print(wait(12*1440)); for _,p in ipairs({{90,50},{160,140},{480,200},{700,150},{520,470},{100,400}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 29
darkG = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}, medium=0.85}
local wm = wallM - petals - breachM
work(wm, {hand="glaze", pile=darkG, angle=math.pi/2, clip=true, coverage=2.5})
blend(wm, {tool={kind="badger", width=24}, angle=math.pi/2, pressure={0.2,0.35}})
local cf = crFront
work(cf, {hand="glaze", pile=darkG, angle=math.pi/2, clip=true, coverage=2.5})

--@ chunk 30
function ST(x,y) local dx,dy = x-NX, y-NY; return dx*UX+dy*UY, dx*VX+dy*VY end
hullM = seedM - petals - openM
local bounceM = hullM * mask(function(x,y) local t,s = ST(x,y); local r = R(t); return (s > 0.55*r) and 1 or 0 end):roughen(5, 40, 3)
local rimM = hullM * mask(function(x,y) local t,s = ST(x,y); local r = R(t); return (s < -0.86*r and t > 120) and 1 or 0 end)
local upperM = hullM * mask(function(x,y) local t,s = ST(x,y); local r = R(t); return (s < -0.55*r and s >= -0.86*r and t > 120) and 1 or 0 end)
bounceP = pile{{"burnt sienna",1},{"bone brown",1.2},{"cadmium red",0.25}}
rimP = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.2}}
upP = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.15}}
local ax = math.atan(UY, UX)
work(bounceM, {hand="body", tool="filbert 8", pile=bounceP, angle=ax, coverage=3, fill=true, clip=true})
work(upperM, {hand="body", tool="filbert 8", pile=upP, angle=ax, coverage=3, fill=true, clip=true})
work(rimM, {hand="body", tool="filbert 5", pile=rimP, angle=ax, coverage=3, fill=true, clip=true})
blend(hullM, {tool={kind="badger", width=18}, angle=math.atan(VY,VX), pressure={0.2,0.35}, coverage=1})

--@ chunk 31
blend(hullM, {tool={kind="badger", width=18}, angle=math.atan(UY,UX), pressure={0.25,0.4}, coverage=1.5})

--@ chunk 32
print(wait(14*1440)); for _,p in ipairs({{350,350},{850,200},{700,120},{500,300},{100,300}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 33
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
HR = {
 c4 = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",1},{"cerulean blue",0.2}},
 c3 = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.1}},
 c2 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.25}},
 d1 = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.08}},
 d0 = pile{{"bone black",2},{"bone brown",1}},
 w2 = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}},
 w3 = pile{{"bone black",1},{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.3}},
 w4 = pile{{"burnt sienna",1},{"cadmium red",0.5},{"Mars orange",0.5},{"bone black",0.3}},
}
local b = brush("filbert", 5)
local n = gradpaint(hullM, {box={240,40,1000,500}, cell=4, len=16, brush=b, pressure={0.55,0.3},
  angle=function(x,y) return math.atan(VY,VX) end,
  pick=function(x,y)
    local t,s = ST(x,y); local r = math.max(R(t), 1); local u = s / r
    -- cool strength grows to the right (under the breach); warm strongest near the opening
    local cool = clamp((x - 300) / 400, 0.3, 1)
    local warm = clamp(1 - math.abs(t - 330) / 450, 0.35, 1)
    local v
    if u < -0.55 then
      local k = (-0.55 - u) / 0.45 * cool * 3.2   -- 0..3.2
      v = ({"d1","c2","c3","c4"})[clamp(math.floor(k + randn(0,0.35) + 1), 1, 4)]
    elseif u < 0.35 then
      v = (randn(0,1) > 0.6) and "d1" or "d0"
    else
      local k = (u - 0.35) / 0.65 * warm * 3.2
      v = ({"d0","w2","w3","w4"})[clamp(math.floor(k + randn(0,0.35) + 1), 1, 4)]
    end
    return HR[v]
  end})
print(n)

--@ chunk 34
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
Q1 = poly({{436,331},{466,300},{503,262},{537,236},{566,218},{560,185},{545,150},{520,160},{492,138},{470,170},{430,160},{420,190},{388,205},{410,240},{398,262},{420,300}})
Q2 = poly({{566,218},{610,211},{659,212},{700,222},{742,240},{760,232},{800,200},{790,170},{812,140},{770,120},{752,92},{715,110},{690,78},{655,100},{630,96},{610,130},{585,150},{575,185}})
Q3 = poly({{447,377},{488,397},{530,410},{580,418},{626,420},{622,450},{600,470},{605,500},{565,495},{540,515},{510,490},{480,492},{470,460},{445,450},{438,415}})
Q4 = poly({{626,420},{668,401},{705,372},{735,334},{756,290},{770,300},{800,325},{790,350},{812,385},{780,410},{770,450},{735,455},{710,480},{680,470},{650,488},{632,460}})
newPet = Q1 + Q2 + Q3 + Q4
local rem = petals - newPet - openM
local remWall = rem * rect(0,0,1000,398) - seedM
local remHull = rem * seedM
local remDeck = rem - remWall - remHull
local d1 = pile{{"bone black",2},{"ultramarine ash",0.4},{"lead white",0.05}}
work(remWall, {hand="body", tool="flat 8", pile=d1, angle=math.pi/2, coverage=3.5, fill=true, clip=true})
work(remDeck, {hand="body", tool="filbert 6", pile=fl2, angle=0, coverage=3.5, fill=true, clip=true})
local b = brush("filbert", 5)
gradpaint(remHull, {box={380,60,830,520}, cell=4, len=16, brush=b, pressure={0.55,0.3},
  angle=function(x,y) return math.atan(VY,VX) end,
  pick=function(x,y) local t,s = ST(x,y); local u = s / R(t)
    if u < -0.6 then return (randn(0,1) > 0) and HR.c2 or HR.d1 elseif u < 0.35 then return HR.d0 else return (randn(0,1) > 0) and HR.w3 or HR.w2 end end})
petals = newPet

--@ chunk 35
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
local od = openM:distance()
local b = brush("filbert", 5)
local n = gradpaint(petals, {box={380,70,820,520}, cell=3.5, len=14, brush=b, pressure={0.6,0.35}, load=0.8,
  angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end,
  pick=function(x,y) local e = -od:at(x,y) + randn(0, 4)
    if e < 8 then return HR.w4 elseif e < 24 then return HR.w3 elseif e < 48 then return HR.w2 else return (randn(0,1) > 0.3) and HR.d0 or HR.w2 end end})
print(n)

--@ chunk 36
function framePartsDef()
  return {
    head = {{557,272},{572,269},{578,280},{576,293},{567,298},{557,295},{553,283}},
    neck = {{560,294},{570,294},{571,306},{559,306}},
    chest = {{534,305},{592,303},{589,330},{579,352},{570,371},{553,371},{544,352},{536,330}},
    shL = {{521,304},{540,301},{543,322},{527,327},{518,316}},
    shR = {{587,301},{605,303},{610,316},{603,327},{587,322}},
    abd = {{553,371},{569,371},{567,389},{555,389}},
    pelvis = {{543,388},{579,388},{583,402},{570,411},{552,411},{539,402}},
    thL = {{536,404},{558,408},{553,453},{532,455}},
    shinL = {{531,459},{552,459},{548,503},{530,505}},
    footL = {{527,503},{549,502},{554,520},{516,522}},
    thR = {{563,408},{583,399},{602,445},{584,454}},
    shinR = {{584,457},{603,455},{607,500},{590,503}},
    footR = {{588,500},{606,498},{623,516},{589,520}},
    uaR = {{594,317},{609,319},{631,349},{617,358}},
    faR = {{618,357},{630,351},{653,379},{641,388}},
    handR = {{641,378},{658,379},{663,392},{646,395}},
    uaL = {{521,318},{538,322},{530,355},{513,354}},
    faL = {{513,359},{530,360},{524,393},{509,392}},
    handL = {{509,392},{524,393},{523,408},{510,409}},
  }
end
function joints() return {{543,456,6},{593,454,6},{623,354,5},{522,357,5},{565,300,4},{561,390,5}} end
function shift(pts, ox, oy) local q = {} for i,p in ipairs(pts) do q[i] = {p[1]+ox, p[2]+oy} end return q end
frameParts = {}
frameM = nil
for k, pts in pairs(framePartsDef()) do local m = poly(pts); frameParts[k] = m; frameM = frameM and (frameM + m) or m end
for _, j in ipairs(joints()) do frameM = frameM + ellipse(j[1], j[2], j[3], j[3]) end
frameP = pile{{"bone black",2},{"ultramarine ash",0.8},{"bone brown",0.4}}
work(frameM, {hand="detail", pile=frameP, coverage=3.5, fill=true})

--@ chunk 37
print(wait(4*1440)); for _,p in ipairs({{540,480},{560,340},{700,200},{650,450}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 38
print(wait(10*1440)); for _,p in ipairs({{540,480},{560,340},{700,200},{650,450},{850,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 39
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
DK = {
 pile{{"bone black",2},{"bone brown",1}},
 pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.5}},
 pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}},
 pile{{"bone black",1},{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.3}},
 pile{{"burnt sienna",1},{"cadmium red",0.5},{"Mars orange",0.5},{"bone black",0.3}},
 pile{{"Mars orange",1},{"burnt sienna",1},{"cadmium red",0.3},{"lead white",0.2}},
}
deckArea = rect(0,398,1000,165) - seedM - petals - cratesM - frameM
local b = brush("filbert", 6)
local n = gradpaint(deckArea, {box={0,398,1000,562}, cell=4.5, len=18, brush=b, pressure={0.6,0.35}, load=0.8,
  angle=function(x,y) return math.atan(y-300, x-470) end,
  pick=function(x,y)
    local d = math.sqrt((x-605)^2 + ((y-500)*2.6)^2) + randn(0, 14)
    local i
    if d < 60 then i = 6 elseif d < 130 then i = 5 elseif d < 220 then i = 4 elseif d < 330 then i = 3 elseif d < 470 then i = 2 else i = 1 end
    return DK[i]
  end})
print(n)

--@ chunk 40
local sh = poly({{528,520},{552,519},{566,522},{590,519},{618,518},{660,540},{700,562},{455,562},{490,540}}, true)
shadowM = sh - frameM
work(shadowM, {hand="body", tool="filbert 6", pile=DK[1], angle=function(x,y) return math.atan(y-330, x-598) end, coverage=3, fill=true, edge="soft", load=1})

--@ chunk 41
local band = (rect(0, 371, 1000, 24) - seedM - cratesM - petals - frameM)
hazA = pile{{"chrome yellow",2},{"yellow ochre",1},{"bone black",0.35},{"burnt sienna",0.3}}
hazK = pile{{"bone black",2},{"bone brown",1}}
work(band, {hand="body", tool="flat 6", pile=hazA, angle=0, coverage=3.5, fill=true, clip=true})
local stripes = nil
for x = -40, 1000, 30 do
  local s = poly({{x,395},{x+15,395},{x+39,371},{x+24,371}})
  stripes = stripes and (stripes + s) or s
end
hazStripes = stripes * band
work(hazStripes, {hand="detail", pile=hazK, coverage=3, fill=true})

--@ chunk 42
local pts = {{595,48},{612,35},{640,48},{668,40},{690,62},{720,55},{748,78},{780,64},{805,82},{840,70},{872,90},{905,72},{940,88},{970,70},{1000,80},{1000,260},{600,260},{590,200},{598,160},{585,120},{600,80}}
holeM = poly(pts) - seedM - petals
spaceK = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
work(holeM, {hand="body", tool="filbert 6", pile=spaceK, angle=0.3, coverage=4, fill=true, clip=true, load=1})

--@ chunk 43
print(wait(12*1440)); for _,p in ipairs({{540,480},{560,340},{800,150},{600,530},{900,383}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 44
local legs = frameParts.thL + frameParts.shinL + frameParts.footL + frameParts.thR + frameParts.shinR + frameParts.footR + frameParts.pelvis + ellipse(543,456,6,6) + ellipse(593,454,6,6)
work(legs, {hand="detail", pile=frameP, coverage=3.5, fill=true, load=1})

--@ chunk 45
local hot = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local warm = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.3}}
local dim = pile{{"cadmium red",1},{"Mars orange",1},{"burnt sienna",0.5}}
local b = brush{kind="round", width=2.4, point=0.7}
local function rim(pts, p, pr)
  b:reload(p, 0.6)
  b:stroke(pts, {pressure={pr or 0.55, (pr or 0.55)*0.7}, ramps={0.1,0.25}})
end
rim({{558,272},{572,269},{578,280},{576,292}}, hot, 0.5)
rim({{588,301},{605,303},{610,315}}, hot, 0.55)
rim({{589,331},{580,351},{571,370}}, hot, 0.5)
rim({{609,320},{630,348}}, hot, 0.5)
rim({{631,351},{653,378}}, warm, 0.5)
rim({{522,304},{539,301}}, warm, 0.5)
rim({{520,319},{513,353}}, dim, 0.45)
rim({{513,360},{509,391}}, dim, 0.45)
rim({{583,400},{601,444}}, warm, 0.45)
rim({{603,456},{606,499}}, dim, 0.45)
rim({{567,371},{567,388}}, hot, 0.4)
rim({{579,389},{583,401}}, warm, 0.4)

--@ chunk 46
local hot = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local warm = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.3}}
local dim = pile{{"cadmium red",1},{"Mars orange",1},{"burnt sienna",0.5}}
local b = brush{kind="round", width=3, point=0.5}
local function rim(pts, p, pr)
  b:reload(p, 0.7)
  b:stroke(pts, {pressure={pr, pr*0.6}, ramps={0.08,0.3}, clip=frameM})
end
rim({{559,274.5},{572,271.5},{576,281},{574,291}}, hot, 0.7)
rim({{589,303.5},{604,305.5},{608,315}}, hot, 0.7)
rim({{587,331},{578,350},{569.5,368}}, hot, 0.65)
rim({{608,322},{628,349}}, hot, 0.65)
rim({{629,353},{650,378}}, warm, 0.6)
rim({{523,306},{539,303.5}}, warm, 0.6)
rim({{522,320},{515.5,352}}, dim, 0.55)
rim({{515.5,361},{511.5,390}}, dim, 0.55)
rim({{582,403},{599,444}}, warm, 0.55)
rim({{601,458},{604.5,498}}, dim, 0.55)
rim({{565.5,372},{565.5,387}}, hot, 0.5)

--@ chunk 47
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local hot = pile{{"cadmium yellow",2},{"lead white",1},{"Mars orange",0.3}}
local ember = pile{{"cadmium red",1},{"Mars orange",1}}
local b = brush{kind="round", width=4, point=0.3}
local J = {{623,354,1},{522,357,0.9},{543,456,1},{593,454,1},{549,405,0.8},{574,405,0.8},{565,301,0.8},{591,313,0.8},{530,313,0.8},{561,381,0.7}}
for _, j in ipairs(J) do
  local x, y, k = j[1], j[2], j[3]
  b:reload(ember, 0.6); b:touch(x, y, {pressure=0.55*k})
  b:reload(hot, 0.6); b:touch(x, y, {pressure=0.35*k})
end
local s = brush{kind="round", width=1.6, point=0.8}
for _, j in ipairs(J) do s:reload(hotW, 0.6); s:touch(j[1], j[2], {pressure=0.5}) end
-- visor slit, cold
local cold = pile{{"zinc white",3},{"cerulean blue",1}}
s:reload(cold, 0.7)
s:stroke({{560,284.5},{567,283.5},{573,282}}, {pressure={0.6,0.5}})

--@ chunk 48
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local hot = pile{{"cadmium yellow",2},{"lead white",1},{"Mars orange",0.3}}
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
-- fix the visor: dark over the grin, then a straight, dimmer slit
local d = brush{kind="round", width=3, point=0.3}
d:reload(frameP, 0.8)
d:stroke({{559,285},{567,284},{574,282.5}}, {pressure={0.8,0.8}})
local seams = {
  {{534,457},{550,457}, 1}, {{586,456},{601,452}, 1}, {{619,356},{630,350}, 0.9}, {{514,357},{529,358}, 0.8},
  {{555,388},{567,388}, 0.8}, {{539,405},{555,408}, 0.7}, {{566,407},{581,402}, 0.7},
  {{541,304},{542,320}, 0.6}, {{588,304},{588,320}, 0.7}, {{533,504},{546,503}, 0.6}, {{592,502},{605,500}, 0.6}, {{561,300},{570,300}, 0.7},
}
local f = brush{kind="flat", width=3.2}
local r = brush{kind="round", width=1.8, point=0.8}
for _, s in ipairs(seams) do
  f:reload(ember, 0.7); f:stroke({s[1], s[2]}, {pressure={0.7*s[3], 0.6*s[3]}, orient="along"})
end
for _, s in ipairs(seams) do
  if s[3] >= 0.7 then
    local mx, my = (s[1][1]+s[2][1])/2, (s[1][2]+s[2][2])/2
    local ax, ay = lerp(s[1][1], mx, 0.4), lerp(s[1][2], my, 0.4)
    local bx, by = lerp(s[2][1], mx, 0.4), lerp(s[2][2], my, 0.4)
    r:reload(s[3] >= 0.9 and hotW or hot, 0.6); r:stroke({{ax,ay},{bx,by}}, {pressure={0.55,0.45}})
  end
end

--@ chunk 49
local function lens(f, which)
  local pts = {}
  for t = 190, 530, 12 do
    local k = math.sin(math.pi*(t-190)/340)
    local p = (which == "top") and P(t, -25 - 75*k) or P(t, 15 + 95*k^0.8)
    pts[#pts+1] = {CX + f*(p[1]-CX), CY + f*(p[2]-CY)}
  end
  return pts
end
local ribP = pile{{"burnt sienna",1},{"bone brown",1},{"cadmium red",0.4}}
local ribD = pile{{"bone brown",2},{"burnt sienna",1}}
local b = brush{kind="round", width=6, point=0.3}
local inner = openM:shrink(3) - frameM
-- three receding rib arcs, top and bottom halves, broken into pieces
local spec = {{0.9, 0.85, ribD}, {0.74, 0.65, ribP}, {0.58, 0.5, ribP}}
for _, s in ipairs(spec) do
  for _, w in ipairs({"top", "bot"}) do
    local pts = lens(s[1], w)
    -- break into 3-4 pieces with gaps
    local i = 1
    while i < #pts - 1 do
      local j = math.min(#pts, i + math.random(4, 8))
      local seg = {} for q = i, j do seg[#seg+1] = pts[q] end
      b:reload(s[3], 0.7)
      b:stroke(seg, {pressure={0.75*s[2], 0.75*s[2]}, clip=inner})
      i = j + math.random(1, 2)
    end
  end
end

--@ chunk 50
local function lens(f, which)
  local pts = {}
  for t = 190, 530, 12 do
    local k = math.sin(math.pi*(t-190)/340)
    local p = (which == "top") and P(t, -25 - 75*k) or P(t, 15 + 95*k^0.8)
    pts[#pts+1] = {CX + f*(p[1]-CX), CY + f*(p[2]-CY)}
  end
  return pts
end
local hot = pile{{"cadmium yellow",2},{"lead white",1.2},{"Mars orange",0.3}}
local inner = openM:shrink(3) - frameM
local b = brush{kind="round", width=2.2, point=0.7}
for _, f in ipairs({0.875, 0.715, 0.555}) do
  for _, w in ipairs({"top", "bot"}) do
    b:reload(hot, 0.6)
    b:stroke(lens(f, w), {pressure={0.45, 0.45}, clip=inner})
  end
end

--@ chunk 51
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
-- outer (scorched) faces where the upper petals fold back over
local c2 = {{560,150},{610,138},{660,128},{720,135},{770,150},{820,160}}
local c1 = {{380,215},{420,196},{470,182},{520,172},{570,165}}
foldQ2 = Q2 * above(c2)
foldQ1 = Q1 * above(c1)
local b = brush("filbert", 4)
gradpaint(foldQ2 + foldQ1, {box={380,70,820,220}, cell=3.5, len=12, brush=b, pressure={0.6,0.35}, load=0.8,
  angle=function(x,y) return 0.15 end,
  pick=function(x,y)
    local c = (foldQ2:at(x,y) > 0.5) and c2 or c1
    -- distance above the crease line (approx by y)
    local yc
    for i = 1, #c-1 do if x >= c[i][1] and x <= c[i+1][1] then yc = lerp(c[i][2], c[i+1][2], (x-c[i][1])/(c[i+1][1]-c[i][1])) end end
    yc = yc or c[#c][2]
    local h = yc - y + randn(0, 4)   -- height above crease
    local cool = (foldQ2:at(x,y) > 0.5) and 1 or 0.5
    if h < 6 then return HR.d0 elseif h < 22 then return HR.d1 elseif h < 40*cool + 30*(1-cool) then return HR.c2 else return (cool > 0.7) and HR.c3 or HR.c2 end
  end})
-- a hot crease line where each petal bends
local hot = pile{{"Mars orange",1},{"cadmium red",0.5},{"cadmium yellow",0.4}}
local r = brush{kind="round", width=3, point=0.5}
r:reload(hot, 0.6); r:stroke({{585,145},{640,133},{700,131},{760,148},{800,160}}, {pressure={0.5,0.35}, clip=Q2})
r:reload(hot, 0.6); r:stroke({{395,212},{450,187},{510,174},{560,168}}, {pressure={0.45,0.3}, clip=Q1})

--@ chunk 52
debris = {
  {{222,470},{262,420},{300,432},{268,486}},
  {{255,490},{300,438},{352,452},{330,502}},
  {{318,508},{345,455},{398,448},{392,508}},
  {{380,502},{400,440},{440,425},{452,470},{430,505}},
  {{232,432},{240,395},{262,390},{270,424}},
  {{286,440},{296,380},{318,370},{314,442}},
  {{400,456},{424,410},{446,400},{452,432}},
  {{345,452},{360,405},{385,398},{396,446}},
}
local lit = {DK[4], DK[4], DK[3], DK[5], DK[3], DK[4], DK[5], DK[4]}
debrisM = nil
for i, q in ipairs(debris) do
  local m = poly(q)
  debrisM = debrisM and (debrisM + m) or m
  -- dark body
  work(m, {hand="detail", tool="round 3", pile=DK[1], coverage=3, fill=true})
  -- lit upper part: the half nearer the first two vertices' edge (top edge)
  local a, b = q[2], q[3]
  local mid1 = {(q[1][1]+q[2][1])/2, (q[1][2]+q[2][2])/2}
  local mid2 = {(q[3][1]+q[#q][1])/2, (q[3][2]+q[#q][2])/2}
  local litm = m * poly({mid1, a, b, mid2})
  work(litm, {hand="detail", tool="round 3", pile=lit[i], coverage=3, fill=true})
end

--@ chunk 53
print(wait(6*1440)); for _,p in ipairs({{300,460},{560,340},{700,110},{600,530}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 54
-- placard: a printed machine-language warning plate, dim in the dark
local plate = rect(318,150,62,44)
local plateP = pile{{"lead white",1},{"bone black",1},{"yellow ochre",0.4},{"ultramarine ash",0.3}}
work(plate, {hand="detail", tool="flat 4", pile=plateP, coverage=3.5, fill=true, angle=0})
-- amber header bar
local hdr = rect(318,150,62,9)
work(hdr, {hand="detail", tool="flat 3", pile=hazA, coverage=3, fill=true, angle=0})

--@ chunk 55
wait(150)
local dimA = pile{{"chrome yellow",1},{"yellow ochre",1},{"bone black",0.5},{"burnt sienna",0.3}}
local f = brush{kind="flat", width=6}
local function st(pts) f:reload(dimA, 0.55); f:stroke(pts, {pressure={0.75,0.7}, orient="across"}) end
-- stencil "0" with bridges
st({{196,52},{186,56},{184,70}})
st({{184,76},{185,90},{196,95}})
st({{204,95},{214,90},{215,76}})
st({{215,70},{214,56},{204,52}})
-- stencil "7"
st({{228,52},{256,52}})
st({{254,58},{238,95}})
-- machine glyph bars under it
local r = brush{kind="flat", width=3}
for i, w in ipairs({8, 3, 14, 5, 3, 10, 4}) do
  local x = 184 + (i-1)*11
  r:reload(dimA, 0.5); r:stroke({{x,104},{x+w*0.7,104}}, {pressure={0.7,0.7}})
end
-- hazard lamp housing + cold lens
local hous = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.3}}
work(rect(430,56,24,16), {hand="detail", tool="round 2", pile=hous, coverage=3, fill=true})
local cold = pile{{"zinc white",3},{"cerulean blue",1},{"viridian",0.2}}
local t = brush{kind="round", width=6, point=0.2}
t:reload(cold, 0.7); t:touch(442, 66, {pressure=0.6})

--@ chunk 56
print(drying(340,175))

--@ chunk 57
local ink = pile{{"bone black",2},{"bone brown",0.5}}
local r = brush{kind="flat", width=2.2}
for row = 0, 4 do
  local y = 164 + row*6
  local x = 322
  while x < 374 do
    local w = rand(2, 9)
    if x + w > 375 then break end
    if math.random() < 0.8 then r:reload(ink, 0.5); r:stroke({{x,y},{x+w,y}}, {pressure={0.6,0.6}}) end
    x = x + w + rand(1.5, 4)
  end
end
-- hazard glyph in header: three dark chevrons
for i = 0, 2 do r:reload(ink, 0.5); r:stroke({{323+i*6,157},{326+i*6,152},{329+i*6,157}}, {pressure={0.5,0.5}}) end
-- hand-painted red annotation slash
local red = pile{{"cadmium red",1},{"red earth",1}}
local rr = brush{kind="round", width=3, point=0.5}
rr:reload(red, 0.6); rr:stroke({{330,190},{350,178},{372,170}}, {pressure={0.55,0.3}})

--@ chunk 58
print(wait(8*1440)); for _,p in ipairs({{300,460},{340,175},{700,110},{600,530},{200,70}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 59
local groove = pile{{"bone black",2},{"bone brown",1}}
local coolH = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.9},{"cerulean blue",0.2}}
local warmH = pile{{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.4},{"bone black",0.3}}
local g = brush{kind="round", width=2.6, point=0.3}
local h = brush{kind="round", width=1.6, point=0.6}
local hm = hullM - frameM
local function ringSeam(t, bow)
  local pts, hl_top, hl_bot = {}, {}, {}
  local r = R(t)
  for k = -10, 10 do
    local s = r * k / 10.5
    local off = bow * (1 - (s/r)^2)
    local p = P(t + off, s)
    pts[#pts+1] = p
    local q = P(t + off + 2.6, s)
    if k <= -5 then hl_top[#hl_top+1] = q end
    if k >= 5 then hl_bot[#hl_bot+1] = q end
  end
  g:reload(groove, 0.7); g:stroke(pts, {pressure={0.7,0.7}, clip=hm})
  h:reload(coolH, 0.5); h:stroke(hl_top, {pressure={0.5,0.5}, clip=hm})
  h:reload(warmH, 0.5); h:stroke(hl_bot, {pressure={0.5,0.5}, clip=hm})
end
for _, t in ipairs({172, 560, 648, 668, 760, 862, 948}) do ringSeam(t, -7) end
-- longitudinal plate seams
local function longSeam(s0, t0, t1)
  local pts = {}
  for t = t0, t1, 20 do pts[#pts+1] = P(t, s0 * R(t)) end
  g:reload(groove, 0.7); g:stroke(pts, {pressure={0.6,0.6}, clip=hm})
end
longSeam(-0.42, 560, 990); longSeam(0.48, 560, 990); longSeam(-0.42, 172, 200)
-- bolts along the ring seams
local bolt = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.6}}
local bt = brush{kind="round", width=2, point=0.2}
for _, t in ipairs({560, 668, 862}) do
  for k = -8, 8, 2 do
    local s = R(t) * k / 10
    local p = P(t + 6, s)
    if hm:at(p[1], p[2]) > 0.5 then bt:reload((k < 0) and bolt or warmH, 0.5); bt:touch(p[1], p[2], {pressure=0.45}) end
  end
end

--@ chunk 60
local dk = pile{{"bone black",2},{"bone brown",1}}
local ab = pile{{"bone black",1},{"lead white",0.45},{"burnt sienna",0.5},{"ultramarine ash",0.3}}
local b = brush{kind="filbert", width=7}
local hm = hullM - frameM
for i = 1, 70 do
  local s = rand(-0.95, 0.95)
  local t0 = rand(140, 900)
  local L = rand(60, 220)
  local pts = {}
  for k = 0, 6 do local t = t0 + L*k/6; pts[#pts+1] = P(t, s * R(t) + randn(0, 1.5)) end
  local p = (math.random() < 0.7) and dk or ab
  b:reload(p, rand(0.15, 0.3))
  b:stroke(pts, {pressure={rand(0.3,0.55), 0.15}, ramps={0.05, 0.5}, clip=hm})
end

--@ chunk 61
print(drying(800,60), drying(900,85))
local hm = holeM:shrink(2)
local starP = pile{{"zinc white",3},{"cerulean blue",0.15}}
local starW = pile{{"zinc white",3},{"lemon chrome",0.1}}
local fine = brush{kind="round", width=1.4, point=0.9}
local mid = brush{kind="round", width=2.4, point=0.6}
local n = 0
for i = 1, 400 do
  local x, y = rand(590, 1000), rand(30, 200)
  if hm:at(x, y) > 0.5 then
    n = n + 1
    local r = math.random()
    if r < 0.8 then fine:reload(starP, 0.4); fine:touch(x, y, {pressure=rand(0.15, 0.3)})
    elseif r < 0.96 then fine:reload(starW, 0.5); fine:touch(x, y, {pressure=rand(0.35, 0.5)})
    else mid:reload(starW, 0.6); mid:touch(x, y, {pressure=rand(0.4, 0.55)}) end
  end
  if n > 70 then break end
end
print(n)

--@ chunk 62
local band = breachM - holeM - seedM - petals
work(band, {hand="detail", tool="round 4", pile=HR.d1, coverage=3, fill=true})
-- cold starlit lips along the torn edge of the hole (the hole's upper boundary)
local lip = {{595,48},{612,35},{640,48},{668,40},{690,62},{720,55},{748,78},{780,64},{805,82},{840,70},{872,90},{905,72},{940,88},{970,70},{1000,80}}
local coolL = pile{{"lead white",1.5},{"ultramarine ash",1},{"bone black",0.6},{"cerulean blue",0.3}}
local b = brush{kind="round", width=2.2, point=0.7}
for i = 1, #lip-1 do
  if math.random() < 0.75 then
    b:reload(coolL, 0.5)
    b:stroke({{lip[i][1], lip[i][2]-1.5}, {lip[i+1][1], lip[i+1][2]-1.5}}, {pressure={rand(0.3,0.55), rand(0.2,0.45)}})
  end
end
-- a few brighter stars with a faint cool halo
local halo = pile{{"zinc white",1},{"cerulean blue",0.5},{"bone black",0.6}, medium=0.5}
local starW = pile{{"zinc white",3},{"lemon chrome",0.1}}
local h = brush{kind="round", width=7, point=0.1}
local s = brush{kind="round", width=2.6, point=0.5}
for _, p in ipairs({{652,118},{835,104},{948,112}}) do
  if holeM:at(p[1],p[2]) > 0.5 then
    h:reload(halo, 0.3); h:touch(p[1], p[2], {pressure=0.25})
    s:reload(starW, 0.7); s:touch(p[1], p[2], {pressure=0.5})
  else print("miss", p[1], p[2]) end
end

--@ chunk 63
print(wait(4*1440)); for _,p in ipairs({{900,170},{780,330},{700,60}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 64
local mid = hullM * mask(function(x,y) local t,s = ST(x,y); local u = s / math.max(R(t),1); return (u > -0.78 and u < 0.6) and 1 or 0 end):soften(4) - frameM
work(mid, {hand="glaze", pile=darkG, angle=math.atan(UY,UX), clip=true, coverage=2})

--@ chunk 65
local coolHi = pile{{"lead white",1.5},{"ultramarine ash",1},{"bone black",0.4},{"cerulean blue",0.3}}
local coolLo = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.15}}
local warmHi = pile{{"Mars orange",1},{"cadmium red",0.5},{"burnt sienna",0.5}}
local warmLo = pile{{"burnt sienna",1},{"cadmium red",0.3},{"bone brown",0.5}}
local b = brush{kind="round", width=3, point=0.4}
local hm = hullM - frameM
-- top rim, in segments so the load stays even; cooler/brighter toward the tail
for t0 = 40, 940, 60 do
  local pts = {}
  for t = t0, t0 + 64, 8 do pts[#pts+1] = P(t, -R(t) + 2.2) end
  local k = clamp((t0 - 40) / 700, 0, 1)
  b:reload(k > 0.45 and coolHi or coolLo, 0.6)
  b:stroke(pts, {pressure={0.35 + 0.25*k, 0.35 + 0.25*k}, clip=hm})
end
-- bottom warm rim near the glowing floor
for t0 = 10, 560, 50 do
  local pts = {}
  for t = t0, t0 + 54, 8 do pts[#pts+1] = P(t, R(t) - 2.5) end
  local k = 1 - math.abs(t0 - 330) / 400
  b:reload(k > 0.4 and warmHi or warmLo, 0.6)
  b:stroke(pts, {pressure={0.3 + 0.3*k, 0.3 + 0.3*k}, clip=hm})
end

--@ chunk 66
armDark = pile{{"bone black",2},{"ultramarine ash",0.6},{"bone brown",0.5}}
local function seg(a, b, w0, w1)
  local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy); local nx, ny = -dy/L, dx/L
  return poly({{a[1]+nx*w0/2, a[2]+ny*w0/2}, {b[1]+nx*w1/2, b[2]+ny*w1/2}, {b[1]-nx*w1/2, b[2]-ny*w1/2}, {a[1]-nx*w0/2, a[2]-ny*w0/2}})
end
armA = {{455,352},{408,326},{360,384},{382,446}}
armB = {{748,298},{806,326},{842,398},{818,452}}
local function armMask(pts)
  local m = seg(pts[1], pts[2], 11, 9) + seg(pts[2], pts[3], 9, 8) + seg(pts[3], pts[4], 8, 6)
  for i = 2, 3 do m = m + ellipse(pts[i][1], pts[i][2], 7, 7) end
  -- cutter head: a small claw
  local e = pts[4]
  m = m + poly({{e[1]-7,e[2]-4},{e[1]+7,e[2]-4},{e[1]+5,e[2]+8},{e[1],e[2]+4},{e[1]-5,e[2]+8}})
  return m
end
armsM = (armMask(armA) + armMask(armB)) - frameM
work(armsM, {hand="detail", tool="round 2.5", pile=armDark, coverage=3.5, fill=true})

--@ chunk 67
local warmHi = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"cadmium red",0.3},{"lead white",0.2}}
local coolHi = pile{{"lead white",1.2},{"ultramarine ash",1},{"bone black",0.5},{"cerulean blue",0.2}}
local b = brush{kind="round", width=2.2, point=0.6}
local function rims(pts, ws)
  for i = 1, #pts-1 do
    local a, c = pts[i], pts[i+1]
    local dx, dy = c[1]-a[1], c[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy); local nx, ny = -dy/L, dx/L
    local mx, my = (a[1]+c[1])/2, (a[2]+c[2])/2
    -- normal toward the core
    if (CX-mx)*nx + (CY-my)*ny < 0 then nx, ny = -nx, -ny end
    local o = ws[i]/2 - 1.6
    b:reload(warmHi, 0.6)
    b:stroke({{a[1]+nx*o, a[2]+ny*o}, {c[1]+nx*o, c[2]+ny*o}}, {pressure={0.5,0.45}, clip=armsM})
    -- opposite side: faint cool where it faces up
    if -ny > 0.3 then
      b:reload(coolHi, 0.4)
      b:stroke({{a[1]-nx*o, a[2]-ny*o}, {c[1]-nx*o, c[2]-ny*o}}, {pressure={0.35,0.3}, clip=armsM})
    end
  end
end
rims(armA, {10, 8.5, 7}); rims(armB, {10, 8.5, 7})
-- joint glows, same tech as the frame
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local t = brush{kind="round", width=4, point=0.3}
for _, p in ipairs({armA[2], armA[3], armB[2], armB[3]}) do
  t:reload(ember, 0.6); t:touch(p[1], p[2], {pressure=0.6})
  b:reload(hotW, 0.6); b:touch(p[1], p[2], {pressure=0.45})
end

--@ chunk 68
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local hotY = pile{{"cadmium yellow",2},{"lead white",1}}
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local function curve(a, b, sag, n)
  local pts = {}
  local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2 + sag
  for i = 0, n do local t = i/n
    pts[#pts+1] = {(1-t)^2*a[1] + 2*(1-t)*t*mx + t^2*b[1], (1-t)^2*a[2] + 2*(1-t)*t*my + t^2*b[2]} end
  return pts
end
-- glowing cut seams
local f = brush{kind="round", width=4, point=0.4}
local r = brush{kind="round", width=2, point=0.7}
f:reload(ember, 0.7); f:stroke({{352,454},{372,450},{396,447}}, {pressure={0.6,0.5}})
r:reload(hotY, 0.6); r:stroke({{358,453},{375,449.5},{392,447.5}}, {pressure={0.5,0.4}})
f:reload(ember, 0.7); f:stroke({{790,472},{822,463},{862,456}}, {pressure={0.6,0.5}})
r:reload(hotY, 0.6); r:stroke({{796,471},{824,462.5},{856,457}}, {pressure={0.5,0.4}})
-- molten spots at the cutter heads
local t = brush{kind="round", width=7, point=0.2}
for _, p in ipairs({{382,449},{818,459}}) do
  t:reload(ember, 0.6); t:touch(p[1], p[2], {pressure=0.7})
  r:reload(hotW, 0.7); r:touch(p[1], p[2], {pressure=0.6})
end
-- raw stock: strands drawn from the cut sites up into the husk
local s = brush{kind="round", width=1.8, point=0.8}
local strandsA = {{{372,450},{452,388}}, {{380,451},{462,392}}, {{388,448},{474,398}}, {{365,452},{446,380}}}
for i, ab in ipairs(strandsA) do
  s:reload((i % 2 == 0) and hotY or ember, 0.55)
  s:stroke(curve(ab[1], ab[2], 14 + 4*i, 14), {pressure={0.45, 0.3}})
end
local strandsB = {{{806,465},{758,318}}, {{814,463},{752,332}}, {{826,460},{745,345}}, {{800,468},{740,356}}}
for i, ab in ipairs(strandsB) do
  s:reload((i % 2 == 0) and hotY or ember, 0.55)
  s:stroke(curve(ab[1], ab[2], 10 + 3*i, 16), {pressure={0.45, 0.3}})
end

--@ chunk 69
print(drying(900,383), drying(200,70), drying(340,175))

--@ chunk 70
local k = pile{{"bone black",2},{"bone brown",0.6}}
work(hazStripes - armsM, {hand="detail", tool="round 2.5", pile=k, coverage=3.5, fill=true, load=1})

--@ chunk 71
print(wait(3*1440)); print(drying(900,383), drying(818,459), drying(700,330))

--@ chunk 72
local g88 = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}, medium=0.88}
local band = rect(0, 369, 1000, 28) - seedM - cratesM - petals - frameM - armsM
work(band, {hand="glaze", pile=g88, angle=0, clip=true, coverage=2})
work(rect(176,42,92,70), {hand="glaze", pile=darkG, angle=0, clip=true, coverage=1.6})
work(rect(316,148,66,48), {hand="glaze", pile=g88, angle=0, clip=true, coverage=1.5})
-- lamp housing darker
work(rect(429,55,26,18), {hand="detail", tool="round 2", pile=frameP, coverage=3, fill=true})

--@ chunk 73
print(wait(2*1440))

--@ chunk 74
local band = rect(0, 371, 1000, 24) - seedM - cratesM - petals - frameM - armsM
local amberGaps = band - hazStripes:grow(0.8)
local a1 = pile{{"chrome yellow",2},{"yellow ochre",1},{"bone black",0.6},{"burnt sienna",0.5}}
local a2 = pile{{"yellow ochre",2},{"bone black",1},{"burnt sienna",0.6}}
work(amberGaps * rect(780,360,120,40), {hand="detail", tool="round 2.5", pile=a1, coverage=3, fill=true})
work(amberGaps * rect(900,360,100,40), {hand="detail", tool="round 2.5", pile=a2, coverage=3, fill=true})
work(amberGaps * rect(0,360,240,40), {hand="detail", tool="round 2.5", pile=a2, coverage=2.5, fill=true})

--@ chunk 75
local railP = pile{{"bone black",1},{"ultramarine ash",0.6},{"burnt sienna",0.4},{"lead white",0.25}}
local railW = pile{{"bone black",1},{"burnt sienna",0.7},{"Mars orange",0.3},{"lead white",0.25}}
local inner = pile{{"bone black",2},{"ultramarine ash",0.6},{"burnt sienna",0.3},{"lead white",0.06}}
crates = {crA, crB, crC}
for i, c in ipairs(crates) do
  local x, y, w, h = c[1], c[2], c[3], c[4]
  local outer = rect(x, y, w, h)
  local inn = rect(x+6, y+6, w-12, h-12)
  work(inn, {hand="body", tool="flat 6", pile=inner, angle=0, coverage=3.5, fill=true, clip=true, ruler=true})
  -- rails: left/top cooler, right side warmer (nearer the glow)
  work((outer - inn) * rect(x, y, w*0.6, h), {hand="detail", tool="round 2.5", pile=railP, coverage=3, fill=true})
  work((outer - inn) * rect(x + w*0.6, y, w*0.4, h), {hand="detail", tool="round 2.5", pile=railW, coverage=3, fill=true})
end

--@ chunk 76
local dm = deckArea - debrisM - armsM
local g = brush{kind="round", width=2.4, point=0.5}
local hl = brush{kind="round", width=1.4, point=0.7}
local function lit(x, y) local d = math.sqrt((x-605)^2 + ((y-500)*2.6)^2); return d end
-- receding seams (toward the VP)
for k = -5, 5 do
  local xb = 470 + 120*k + 18
  local a = {470 + (xb-470)*0.374, 398}
  local b = {xb, 562}
  local pts = {}
  for i = 0, 10 do local t = i/10; pts[#pts+1] = {lerp(a[1], b[1], t), lerp(a[2], b[2], t)} end
  g:reload(DK[1], 0.7); g:stroke(pts, {pressure={0.35, 0.8}, clip=dm})
  local m = {lerp(a[1],b[1],0.6), lerp(a[2],b[2],0.6)}
  if lit(m[1], m[2]) < 260 then
    local q = {} for i, p in ipairs(pts) do q[i] = {p[1] + 2.2*(p[2]-300)/262, p[2]} end
    hl:reload(DK[6], 0.5); hl:stroke(q, {pressure={0.25, 0.55}, clip=dm})
  end
end
-- transverse seams
for _, y in ipairs({413, 432, 458, 494, 545}) do
  local w = 0.3 + (y - 398) / 200
  local pts = {}
  for x = 0, 1000, 25 do pts[#pts+1] = {x, y} end
  g:reload(DK[1], 0.7); g:stroke(pts, {pressure={w, w}, clip=dm})
  local seg = {}
  for x = 420, 800, 20 do seg[#seg+1] = {x, y - 1.5 - w} end
  hl:reload(DK[6], 0.5); hl:stroke(seg, {pressure={0.3, 0.3}, clip=dm * mask(function(x,y) return lit(x,y) < 230 and 1 or 0 end)})
end

--@ chunk 77
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
local noseM = hullM * mask(function(x,y) local t,s = ST(x,y); return (t < 178) and 1 or 0 end) - debrisM - armsM - frameM
local emb1 = pile{{"cadmium red",1},{"burnt sienna",1},{"bone brown",0.6}}
local emb2 = pile{{"cadmium red",1},{"Mars orange",0.6},{"burnt sienna",0.4}}
local b = brush("filbert", 4)
local n = gradpaint(noseM, {box={240,280,440,500}, cell=3.5, len=13, brush=b, pressure={0.55,0.3}, load=0.75,
  angle=function(x,y) local t,s = ST(x,y); local r = R(t); local u = s / math.max(r,1)
    -- meridian direction: along the axis, bending toward the tip
    local slope = (t < 170) and (122/170) * (1 - t/170) / math.sqrt(math.max(1 - (1 - t/170)^2, 0.05)) or 0
    local ang = math.atan(UY, UX) + math.atan(slope * u)
    return ang end,
  pick=function(x,y)
    local t,s = ST(x,y); local u = s / math.max(R(t),1)
    local hot = clamp(1 - t/70, 0, 1) * clamp((u + 0.2)/1.0, 0, 1) + randn(0, 0.12)
    if hot > 0.55 then return emb2 elseif hot > 0.3 then return emb1 end
    local v = u + randn(0, 0.15)
    if v < -0.82 then return HR.c2 elseif v < -0.55 then return HR.d1 elseif v < 0.45 then return HR.d0 elseif v < 0.75 then return HR.w2 else return HR.w3 end
  end})
print(n)

--@ chunk 78
W1 = {{205,502},{212,462},{226,446},{240,432},{252,440},{262,446},{276,428},{286,420},{294,431},{300,440},{316,436},{330,432},{336,470},{338,506}}
W2 = {{318,508},{324,470},{330,450},{343,438},{352,428},{364,437},{375,445},{386,432},{395,425},{408,433},{420,438},{434,428},{445,420},{452,436},{460,450},{462,480},{458,510}}
W3 = {{268,476},{300,458},{326,462},{346,472},{332,496},{286,500}}
wave1 = poly(W1); wave2 = poly(W2); wave3 = poly(W3)
waveM = wave1 + wave2 + wave3
local waveP = pile{{"bone black",2},{"bone brown",1},{"burnt sienna",0.3}}
work((wave1 + wave2) - armsM, {hand="body", tool="flat 6", pile=waveP, angle=math.pi/2, coverage=3.5, fill=true, clip=true})

--@ chunk 79
local waveP = pile{{"bone black",2},{"bone brown",1},{"burnt sienna",0.3}}
work(debrisM - waveM - armsM, {hand="detail", tool="round 3", pile=waveP, coverage=3.5, fill=true})

--@ chunk 80
local wHot = pile{{"Mars orange",1},{"cadmium red",0.4},{"cadmium yellow",0.4},{"lead white",0.15}}
local wMid = pile{{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.4}}
local wDim = pile{{"burnt sienna",1},{"bone brown",0.6},{"cadmium red",0.2}}
local b = brush{kind="round", width=2.6, point=0.5}
local function edge(pts, i0, i1, dy)
  for i = i0, i1 - 1 do
    local a, c = pts[i], pts[i+1]
    local mx = (a[1] + c[1]) / 2
    local k = clamp((mx - 200) / 260, 0, 1)
    local p = (k > 0.66) and wHot or ((k > 0.33) and wMid or wDim)
    b:reload(p, 0.6)
    b:stroke({{a[1], a[2] + dy}, {c[1], c[2] + dy}}, {pressure={0.45 + 0.2*k, 0.4 + 0.2*k}, clip=waveM + debrisM})
  end
end
edge(W1, 2, 13, 1.8)
edge(W2, 2, 16, 1.8)
-- plates standing behind the wave: lit top edges
for _, q in ipairs({debris[5], debris[6], debris[7], debris[8]}) do edge(q, 2, 3, 1.6) end
-- nose tip ember where the warhead is buried
local emb1 = pile{{"cadmium red",1},{"burnt sienna",1},{"bone brown",0.5}}
local emb2 = pile{{"cadmium red",1},{"Mars orange",0.8},{"cadmium yellow",0.2}}
local tipM = ellipse(262, 418, 30, 16) * (hullM + debrisM) - waveM
stipple(tipM, {pile=emb1, width=4, coverage=1.6, feather=0.6})
stipple(ellipse(258, 422, 16, 9) * (hullM + debrisM) - waveM, {pile=emb2, width=3, coverage=1.5, feather=0.6})

--@ chunk 81
local c = worley{seed=7, period=14, jitter=0.9}; local r = {c:at(300,450)}; for i,v in ipairs(r) do print(i, type(v), type(v)=="table" and "t" or v) end

--@ chunk 82
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
local wm = (wave1 + wave2) - armsM
local wd = wm:distance()
local b = brush("filbert", 4)
local facetN = worley{seed=7, period=14, jitter=0.9}
local n = gradpaint(wm, {box={200,415,465,510}, cell=3.2, len=9, brush=b, pressure={0.6,0.35}, load=0.75,
  angle=function(x,y) local _,_,_,id = facetN:at(x,y); return id * 6.283 end,
  pick=function(x,y)
    local d = wd:at(x,y)
    if y > 485 then return DK[1] end
    local k = clamp((x - 200) / 260, 0, 1)          -- nearer the glow to the right
    local f = math.random()
    local lit = clamp(1 - d / 14, 0, 1) * (0.35 + 0.65*k)
    lit = lit + (f - 0.5) * 0.35
    if lit > 0.75 then return DK[5] elseif lit > 0.5 then return DK[4] elseif lit > 0.3 then return DK[3] elseif lit > 0.12 then return DK[2] else return DK[1] end
  end})
print(n)

--@ chunk 83
local function lensFull(f)
  local pts = {}
  for t = 150, 570, 10 do
    local k = math.sin(math.pi*(t-190)/340); if k < 0 then k = 0 end
    local p = P(t, -25 - 75*k)
    pts[#pts+1] = {CX + f*(p[1]-CX), CY + f*(p[2]-CY)}
  end
  return pts
end
local function lensBot(f)
  local pts = {}
  for t = 150, 570, 10 do
    local k = math.sin(math.pi*(t-190)/340); if k < 0 then k = 0 end
    local p = P(t, 15 + 95*k^0.8)
    pts[#pts+1] = {CX + f*(p[1]-CX), CY + f*(p[2]-CY)}
  end
  return pts
end
local inner = (petals - (foldQ1 + foldQ2)) - frameM - armsM
local ribD = pile{{"bone brown",2},{"bone black",1}}
local ribH = pile{{"Mars orange",1},{"cadmium red",0.5},{"burnt sienna",0.5}}
local g = brush{kind="round", width=3.2, point=0.3}
local h = brush{kind="round", width=1.6, point=0.6}
for _, f in ipairs({1.16, 1.32, 1.5}) do
  for _, fn in ipairs({lensFull, lensBot}) do
    local pts = fn(f)
    local ptsH = fn(f - 0.018)
    g:reload(ribD, 0.7); g:stroke(pts, {pressure={0.6,0.6}, clip=inner})
    h:reload(ribH, 0.5); h:stroke(ptsH, {pressure={0.45 - (f-1.16)*0.6, 0.45 - (f-1.16)*0.6}, clip=inner})
  end
end
-- radial stringers
for _, a in ipairs({-2.5, -2.05, -1.6, -1.15, -0.7, 0.55, 1.0, 1.5, 2.0, 2.5}) do
  local pts = {}
  for r = 90, 260, 10 do pts[#pts+1] = {CX + r*math.cos(a), CY + r*math.sin(a)*0.87} end
  g:reload(ribD, 0.7); g:stroke(pts, {pressure={0.5,0.5}, clip=inner - openM:grow(6)})
end

--@ chunk 84
local whiteHot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.4}}
local paleY = pile{{"lead white",2},{"lemon chrome",1},{"cadmium yellow",0.3}}
local function dist(x,y) return math.sqrt((x-CX)^2 + ((y-CY)*1.15)^2) end
local coreZone = mask(function(x,y) return dist(x,y) < 34 and 1 or 0 end):soften(6) * openM - frameM:grow(1.5)
local yZone = mask(function(x,y) return dist(x,y) < 62 and 1 or 0 end):soften(10) * openM - frameM:grow(1.5) - coreZone
stipple(yZone, {pile=paleY, width=3.5, coverage=function(x,y) return 1.6 * clamp(1 - dist(x,y)/62, 0, 1) end, feather=0.7})
stipple(coreZone, {pile=whiteHot, width=3, coverage=2.2, feather=0.5})

--@ chunk 85
local function dist(x,y) return math.sqrt((x-CX)^2 + ((y-CY)*1.15)^2) end
local z = mask(function(x,y) return dist(x,y) < 66 and 1 or 0 end) * openM - frameM:grow(2)
blend(z, {tool={kind="badger", width=10}, angle=function(x,y) return math.atan(y-CY, x-CX) end, pressure={0.25,0.4}, coverage=1.5})

--@ chunk 86
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
local legs = frameParts.shinL + frameParts.shinR + frameParts.footL + frameParts.footR + frameParts.thL + frameParts.thR
local inside = legs:shrink(1.8)
local b = brush("filbert", 3)
local n = gradpaint(inside, {box={510,400,630,525}, cell=2.5, len=7, brush=b, pressure={0.5,0.3}, load=0.7,
  angle=function(x,y) return math.pi/2 end,
  pick=function(x,y)
    local k = clamp((y - 440) / 75, 0, 1) + randn(0, 0.12)
    if k > 0.8 then return DK[3] elseif k > 0.45 then return DK[2] elseif k > 0.2 then return frameP end
    return nil
  end})
print(n)

--@ chunk 87
print(wait(300)); print(drying(540,480))

--@ chunk 88
-- the frame's own shadow thrown forward over the lower petals (legs first, then the body's wider shadow)
local legSh = poly({{530,505},{548,503},{556,520},{528,522}}) + poly({{591,503},{606,500},{618,519},{590,521}})
local bodySh = poly({{520,470},{612,466},{640,510},{606,522},{520,524},{500,505}}, true)
local sh = (bodySh * petals) - frameM
local shP = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.4}}
work(sh, {hand="body", tool="filbert 5", pile=shP, angle=math.pi/2, coverage=3, fill=true, clip=true, edge="soft"})

--@ chunk 89
print(wait(10*1440)); print(drying(540,480), drying(600,480), drying(560,500))

--@ chunk 90
print(wait(5*1440)); print(drying(540,480), drying(600,480), drying(560,500))

--@ chunk 91
local lower = frameParts.shinL + frameParts.shinR + frameParts.footL + frameParts.footR + frameParts.thL + frameParts.thR
work(lower, {hand="detail", pile=frameP, coverage=3.5, fill=true, load=1})

--@ chunk 92
local g88 = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}, medium=0.88}
local wm = (wallM - petals - breachM - holeM - cratesM - armsM - seedM)
local upper = wm * mask(function(x,y) return (y < 300) and 1 or 0 end)
work(upper, {hand="glaze", pile=g88, angle=math.pi/2, clip=true, coverage=2})
-- crates: knock the rails down, keep the right-hand (lit) rails warm
local rails = nil
for _, c in ipairs(crates) do
  local x, y, w, h = c[1], c[2], c[3], c[4]
  local r = rect(x, y, w, h) - rect(x+6, y+6, w-12, h-12)
  rails = rails and (rails + r) or r
end
work(rails * rect(0, 0, 200, 600), {hand="glaze", pile=darkG, angle=0, clip=true, coverage=1.8})

--@ chunk 93
local haloP = pile{{"zinc white",1},{"cerulean blue",0.6},{"bone black",0.9},{"viridian",0.1}, medium=0.55}
local lens = pile{{"zinc white",3},{"cerulean blue",0.5},{"viridian",0.1}}
local hot = pile{{"zinc white",3}}
local zone = ellipse(442, 66, 34, 26) - rect(429,55,26,18)
stipple(zone, {pile=haloP, width=4, coverage=function(x,y) local d = math.sqrt((x-442)^2 + ((y-66)*1.3)^2); return 1.4*clamp(1 - d/34, 0, 1)^1.5 end, feather=0.8})
-- lens: a small bar on the housing's face
local f = brush{kind="flat", width=4}
f:reload(lens, 0.7); f:stroke({{434,66},{450,66}}, {pressure={0.7,0.7}})
local r = brush{kind="round", width=1.8, point=0.7}
r:reload(hot, 0.6); r:stroke({{437,65.6},{447,65.6}}, {pressure={0.5,0.5}})
-- the cage bars over the lens
local cage = brush{kind="round", width=1.2, point=0.5}
for _, x in ipairs({437, 442, 447}) do cage:reload(frameP, 0.5); cage:stroke({{x,61},{x,71}}, {pressure={0.5,0.5}}) end

--@ chunk 94
local amb = pile{{"chrome yellow",1.5},{"yellow ochre",1},{"bone black",0.55},{"burnt sienna",0.4}}
local ink = pile{{"bone black",2},{"bone brown",0.5}}
local paleS = pile{{"lead white",1},{"bone black",1.2},{"yellow ochre",0.3}}
for i, c in ipairs(crates) do
  local x, y, w, h = c[1], c[2], c[3], c[4]
  -- hazard corner triangle (bottom-right of the front), striped
  local tri = poly({{x+w, y+h-22}, {x+w, y+h}, {x+w-22, y+h}})
  work(tri, {hand="detail", tool="round 2", pile=amb, coverage=3, fill=true})
  local f = brush{kind="flat", width=3}
  for k = 0, 2 do
    local o = 6 + k*7
    f:reload(ink, 0.6); f:stroke({{x+w-o, y+h}, {x+w, y+h-o}}, {pressure={0.6,0.6}})
  end
  -- stencil code: short pale bars in two rows
  local r = brush{kind="flat", width=2.6}
  local cx, cy = x + 14, y + h*0.42
  for row = 0, 1 do
    local xx = cx
    for j = 1, 5 do
      local ww = rand(3, 9)
      r:reload(paleS, 0.5); r:stroke({{xx, cy + row*7}, {xx + ww, cy + row*7}}, {pressure={0.65,0.65}})
      xx = xx + ww + rand(2, 4)
    end
  end
end

--@ chunk 95
local od = openM:distance()
local outerPet = (petals - frameM - armsM) * mask(function(x,y) return (-od:at(x,y) > 30) and 1 or 0 end):soften(8)
work(outerPet, {hand="glaze", pile=darkG, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end, clip=true, coverage=1.8})
-- deck periphery: corners and far right
local g88 = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}, medium=0.88}
local per = (deckArea - debrisM - waveM - armsM - shadowM) * mask(function(x,y) local d = math.sqrt((x-605)^2 + ((y-500)*2.6)^2); return (d > 230) and 1 or 0 end):soften(20)
work(per, {hand="glaze", pile=g88, angle=function(x,y) return math.atan(y-300, x-470) end, clip=true, coverage=1.8})

--@ chunk 96
print(wait(14*1440)); for _,p in ipairs({{540,480},{600,480},{560,500},{480,200},{900,500}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 97
local hot = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local warm = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.3}}
local dim = pile{{"cadmium red",1},{"Mars orange",1},{"burnt sienna",0.5}}
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local b = brush{kind="round", width=3, point=0.5}
local function rim(pts, p, pr) b:reload(p, 0.7); b:stroke(pts, {pressure={pr, pr*0.7}, ramps={0.08,0.3}, clip=frameM}) end
rim({{581.5,403},{598.5,444}}, warm, 0.6)
rim({{601,459},{604.5,498}}, warm, 0.55)
rim({{535,407},{531.5,452}}, dim, 0.5)
rim({{533.5,462},{532.5,502}}, dim, 0.5)
-- toes catch the floor glow
rim({{519,520},{552,519}}, dim, 0.5)
rim({{592,518},{620,515}}, dim, 0.5)
local f = brush{kind="flat", width=3.2}
local r = brush{kind="round", width=1.8, point=0.8}
for _, s in ipairs({{{534,457},{550,457}}, {{586,456},{601,452}}, {{533,504},{546,503}}, {{592,502},{605,500}}}) do
  f:reload(ember, 0.7); f:stroke(s, {pressure={0.7,0.6}, orient="along"})
  local mx, my = (s[1][1]+s[2][1])/2, (s[1][2]+s[2][2])/2
  r:reload(hotW, 0.6); r:stroke({{lerp(s[1][1],mx,0.4), lerp(s[1][2],my,0.4)}, {lerp(s[2][1],mx,0.4), lerp(s[2][2],my,0.4)}}, {pressure={0.5,0.4}})
end

--@ chunk 98
local warmG = pile{{"burnt sienna",1},{"bone brown",1},{"cadmium red",0.15}, medium=0.85}
local od = openM:distance()
local outerPet = (petals - frameM - armsM) * mask(function(x,y) return (-od:at(x,y) > 22) and 1 or 0 end):soften(8)
work(outerPet, {hand="glaze", pile=warmG, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end, clip=true, coverage=1.6})

--@ chunk 99
local function bez(a, c1, c2, b, n)
  local pts = {}
  for i = 0, n do local t = i/n; local u = 1-t
    pts[#pts+1] = {u^3*a[1] + 3*u^2*t*c1[1] + 3*u*t^2*c2[1] + t^3*b[1], u^3*a[2] + 3*u^2*t*c1[2] + 3*u*t^2*c2[2] + t^3*b[2]} end
  return pts
end
local cab = pile{{"bone black",2},{"bone brown",1}}
local hl = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.3}}
local b = brush{kind="round", width=4.5, point=0.2}
local h = brush{kind="round", width=1.4, point=0.7}
local cables = {
  {{574,396},{610,410},{660,380},{700,330}, 0.75},
  {{586,330},{620,320},{650,300},{690,280}, 0.6},
  {{548,396},{520,410},{480,375},{462,330}, 0.65},
  {{540,330},{505,320},{485,290},{470,262}, 0.5},
}
local clipM = openM:grow(4) - frameM
for _, c in ipairs(cables) do
  local pts = bez(c[1], c[2], c[3], c[4], 24)
  b:reload(cab, 0.8); b:stroke(pts, {pressure={c[5], c[5]*0.75}, clip=clipM})
  local q = {} for i, p in ipairs(pts) do q[i] = {p[1], p[2] - 1.4} end
  h:reload(hl, 0.5); h:stroke(q, {pressure={0.35, 0.25}, clip=clipM})
end

--@ chunk 100
local function bez(a, c1, c2, b, n)
  local pts = {}
  for i = 0, n do local t = i/n; local u = 1-t
    pts[#pts+1] = {u^3*a[1] + 3*u^2*t*c1[1] + 3*u*t^2*c2[1] + t^3*b[1], u^3*a[2] + 3*u^2*t*c1[2] + 3*u*t^2*c2[2] + t^3*b[2]} end
  return pts
end
local cab = pile{{"bone black",2},{"bone brown",1}}
local hl = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.5}}
local b = brush{kind="round", width=5}
local h = brush{kind="round", width=1.6, point=0.6}
local cables = {
  {{574,396},{610,410},{660,380},{700,330}, 1.0, 5.5},
  {{586,330},{620,320},{650,300},{690,280}, 0.85, 4.5},
  {{548,396},{520,410},{480,375},{462,330}, 0.9, 5},
  {{540,330},{505,320},{485,290},{470,262}, 0.75, 4},
}
local clipM = openM:grow(4) - frameM
for _, c in ipairs(cables) do
  local pts = bez(c[1], c[2], c[3], c[4], 30)
  for k = 1, 2 do b:reload(cab, 0.9); b:stroke(pts, {pressure={c[5], c[5]*0.8}, ramps={0.02,0.1}, clip=clipM}) end
  local q = {} for i, p in ipairs(pts) do q[i] = {p[1], p[2] - c[6]*0.32} end
  h:reload(hl, 0.6); h:stroke(q, {pressure={0.5, 0.35}, clip=clipM})
end

--@ chunk 101
local cab = pile{{"bone black",2},{"bone brown",1}}
local hl = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.5}}
local b = brush{kind="round", width=5}
local h = brush{kind="round", width=1.6, point=0.6}
local ext = {
  {{{696,334},{720,318},{748,306},{770,300}}, 0.8},
  {{{686,282},{712,268},{735,252},{752,240}}, 0.68},
  {{{464,334},{455,322},{444,300},{436,282}}, 0.72},
  {{{471,265},{466,250},{462,236},{460,222}}, 0.6},
}
local clipM = openM:grow(14) - frameM
for _, e in ipairs(ext) do
  for k = 1, 2 do b:reload(cab, 0.9); b:stroke(e[1], {pressure={e[2], e[2]*0.9}, ramps={0.02,0.05}, clip=clipM}) end
  local q = {} for i, p in ipairs(e[1]) do q[i] = {p[1], p[2] - 1.5} end
  h:reload(hl, 0.5); h:stroke(q, {pressure={0.4, 0.2}, clip=openM})
end
-- sockets where they enter the womb wall
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local t = brush{kind="round", width=5, point=0.2}
for _, p in ipairs({{760,303},{746,244},{440,290},{461,228}}) do t:reload(ember, 0.5); t:touch(p[1], p[2], {pressure=0.5}) end

--@ chunk 102
function gradpaint(m, o)
  local x0,y0,x1,y1 = o.box[1], o.box[2], o.box[3], o.box[4]
  local cell = o.cell or 5
  local b = o.brush
  local n = 0
  local pts = {}
  for y = y0, y1, cell do for x = x0, x1, cell do
    local px, py = x + rand(-cell/2, cell/2), y + rand(-cell/2, cell/2)
    if m:at(px, py) > 0.5 then pts[#pts+1] = {px, py} end
  end end
  -- shuffle
  for i = #pts, 2, -1 do local j = math.random(i); pts[i], pts[j] = pts[j], pts[i] end
  local last = nil
  for _, p in ipairs(pts) do
    local px, py = p[1], p[2]
    local pl = o.pick(px, py)
    if pl then
      if pl ~= last or b:fullness() < 0.3 then b:reload(pl, o.load or 0.7); last = pl end
      local a = o.angle(px, py) + rand(-0.15, 0.15)
      local L = (o.len or 10) * rand(0.7, 1.2)
      local dx, dy = math.cos(a)*L/2, math.sin(a)*L/2
      b:stroke({{px-dx, py-dy}, {px+dx, py+dy}}, {pressure=o.pressure or {0.6, 0.4}, clip=o.clip or m})
      n = n + 1
    end
  end
  return n
end
local T1 = {{380,250},{392,236},{398,214},{420,204},{436,182},{462,175},{470,160},{500,142},{522,150},{540,148},{556,178},{566,214}}
local T2 = {{566,214},{575,190},{588,150},{612,128},{632,118},{652,100},{675,104},{690,86},{712,104},{742,108},{760,128},{782,146},{805,160},{812,200},{790,228}}
local torn = {} for _, p in ipairs(T1) do torn[#torn+1] = p end for i = 2, #T2 do torn[#torn+1] = T2[i] end
local cut = petals * above(torn)
local wallBits = cut - holeM - seedM
local holeBits = cut * holeM
local hullBits = (cut * seedM) - holeM
local wallK = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.5}}
work(wallBits, {hand="detail", tool="round 3", pile=wallK, coverage=3.5, fill=true})
work(holeBits, {hand="detail", tool="round 3", pile=spaceK, coverage=3.5, fill=true})
work(hullBits, {hand="detail", tool="round 3", pile=HR.d1, coverage=3.5, fill=true})
-- the outer faces of the folded-back plates: exterior armor, dark, starlit along the torn edge
local c2 = {{560,150},{610,138},{660,128},{720,135},{770,150},{820,160}}
local c1 = {{380,215},{420,196},{470,182},{520,172},{570,165}}
foldOut = (petals - cut) * (above(c2) + above(c1))
local fd = cut:distance()
local b = brush("filbert", 4)
gradpaint(foldOut, {box={380,80,820,240}, cell=3.2, len=11, brush=b, pressure={0.6,0.35}, load=0.8,
  angle=function(x,y) return 0.2 end,
  pick=function(x,y)
    local d = -fd:at(x,y)   -- distance from torn edge into the fold
    if d < 0 then d = 0 end
    d = d + randn(0, 2.5)
    local cool = clamp((x - 380) / 300, 0.4, 1)
    if d < 3.5 * cool + 1 then return HR.c3 elseif d < 9 then return HR.c2 elseif d < 20 then return HR.d1 else return HR.d0 end
  end})

--@ chunk 103
local T1 = {{380,250},{392,236},{398,214},{420,204},{436,182},{462,175},{470,160},{500,142},{522,150},{540,148},{556,178},{566,214}}
local T2 = {{566,214},{575,190},{588,150},{612,128},{632,118},{652,100},{675,104},{690,86},{712,104},{742,108},{760,128},{782,146},{805,160},{812,200},{790,228}}
local torn = {} for _, p in ipairs(T1) do torn[#torn+1] = p end for i = 2, #T2 do torn[#torn+1] = T2[i] end
local cut = petals * above(torn)
local wallBits = cut - holeM - seedM
local wallK2 = pile{{"bone black",2},{"ultramarine ash",0.7},{"lead white",0.06}}
work(wallBits, {hand="detail", tool="round 3", pile=wallK2, coverage=3.5, fill=true})
-- hot cut edge: the plate thickness just above the lens top, lit from inside
local top = {}
for t = 196, 524, 8 do local k = math.sin(math.pi*(t-190)/340); top[#top+1] = P(t, -25 - 75*k - 3.5) end
local hotE = pile{{"Mars orange",1},{"cadmium yellow",0.7},{"cadmium red",0.3},{"lead white",0.2}}
local midE = pile{{"cadmium red",1},{"Mars orange",0.6},{"burnt sienna",0.5}}
local f = brush{kind="round", width=4.5}
local r = brush{kind="round", width=2, point=0.6}
local clipM = (petals - frameM - armsM):grow(0)
for i = 1, #top - 4, 4 do
  local seg = {} for j = i, math.min(#top, i + 5) do seg[#seg+1] = top[j] end
  f:reload(midE, 0.7); f:stroke(seg, {pressure={0.8,0.8}, clip=clipM})
  local seg2 = {} for _, p in ipairs(seg) do seg2[#seg2+1] = {p[1], p[2] + 1.6} end
  r:reload(hotE, 0.6); r:stroke(seg2, {pressure={0.55,0.5}, clip=clipM})
end

--@ chunk 104
local top = {}
for t = 196, 524, 6 do local k = math.sin(math.pi*(t-190)/340); top[#top+1] = P(t, -25 - 75*k - 2.5) end
local hotE = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.4}}
local r = brush{kind="round", width=3}
local clipM = (petals + openM) - frameM - armsM
for i = 1, #top - 3, 3 do
  local seg = {} for j = i, math.min(#top, i + 4) do seg[#seg+1] = top[j] end
  local mx = seg[1][1]
  local k = 1 - math.abs(mx - 600) / 200
  r:reload(hotE, 0.8); r:stroke(seg, {pressure={0.55 + 0.35*k, 0.55 + 0.35*k}, clip=clipM})
end

--@ chunk 105
print(wait(3*1440))

--@ chunk 106
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local hotY = pile{{"cadmium yellow",2},{"lead white",1}}
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local r = brush{kind="round", width=3, point=0.8}
local s = brush{kind="round", width=1.6, point=0.8}
-- drips of molten feedstock from the lower lip of the womb
for _, t in ipairs({262, 300, 338, 395, 430, 470}) do
  local k = math.sin(math.pi*(t-190)/340)
  local p = P(t, 15 + 95*k^0.8 + 1)
  local L = rand(6, 16)
  r:reload(ember, 0.6); r:stroke({{p[1], p[2]}, {p[1] + rand(-0.5,0.5), p[2] + L}}, {pressure={0.75, 0.0}, ramps={0.02, 0.8}})
  s:reload(hotY, 0.5); s:stroke({{p[1], p[2]}, {p[1], p[2] + L*0.5}}, {pressure={0.6, 0.0}, ramps={0.02, 0.8}})
end
-- a drip from the braced hand and from the hanging hand: still wet from the printer
for _, p in ipairs({{652,394}, {515,409}}) do
  r:reload(ember, 0.6); r:stroke({{p[1], p[2]}, {p[1], p[2] + 9}}, {pressure={0.6, 0.0}, ramps={0.02, 0.8}})
end
-- sparks: few, drifting outward from the womb and from the cutter heads
local function spark(x, y, big)
  if big then r:reload(hotY, 0.5); r:touch(x, y, {pressure=0.5}) end
  s:reload(hotW, 0.5); s:touch(x, y, {pressure=big and 0.5 or 0.35})
end
local free = -(frameM:grow(3))
local n = 0
for i = 1, 60 do
  local a = rand(0, 6.283); local d = rand(120, 300)
  local x, y = CX + d*math.cos(a), CY + d*math.sin(a)*0.75
  if x > 0 and x < 1000 and y > 0 and y < 560 and free:at(x,y) > 0.5 then spark(x, y, math.random() < 0.25); n = n + 1 end
  if n >= 26 then break end
end
for _, c in ipairs({{382,449},{818,459}}) do
  for i = 1, 7 do spark(c[1] + randn(0, 12), c[2] - math.abs(randn(0, 14)), math.random() < 0.3) end
end

--@ chunk 107
-- torn bulkhead sheet bent around the hull where it punched through the wall (upper-left rim of the hull)
local tongues = {
  {40, 70, 26, -0.2}, {72, 96, 18, 0.15}, {98, 130, 32, -0.1}, {132, 150, 14, 0.2}, {152, 188, 28, 0.05},
}
local tongueM = nil
local sheet = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.2}}
local coolE = pile{{"lead white",1.2},{"ultramarine ash",1},{"bone black",0.6},{"cerulean blue",0.2}}
local warmE = pile{{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.4}}
local r = brush{kind="round", width=2, point=0.6}
local hullTop = function(t) return P(t, -R(t) + 4) end
for _, tg in ipairs(tongues) do
  local t0, t1, L, lean = tg[1], tg[2], tg[3], tg[4]
  local tm = (t0 + t1) / 2 + lean * L
  local a, b = hullTop(t0), hullTop(t1)
  local tip = P(tm, -R(tm) - L)
  local mid1 = P(lerp(t0, tm, 0.6) - 3, -R(lerp(t0, tm, 0.6)) - L*0.55)
  local mid2 = P(lerp(t1, tm, 0.6) + 2, -R(lerp(t1, tm, 0.6)) - L*0.5)
  local q = {a, mid1, tip, mid2, b}
  local m = poly(q)
  tongueM = tongueM and (tongueM + m) or m
  work(m, {hand="detail", tool="round 2.5", pile=sheet, coverage=3.5, fill=true})
  r:reload(coolE, 0.5); r:stroke({{a[1], a[2]-1}, {mid1[1], mid1[2]-1}, {tip[1], tip[2]}}, {pressure={0.45, 0.25}})
  r:reload(warmE, 0.5); r:stroke({{tip[1], tip[2]}, {mid2[1]+0.8, mid2[2]}, {b[1]+0.8, b[2]}}, {pressure={0.25, 0.45}})
end
bulkTongues = tongueM

--@ chunk 108
print(wait(4*1440)); print(drying(330,250), drying(380,225))

--@ chunk 109
local cover = bulkTongues:grow(3) - seedM
local wallK2 = pile{{"bone black",2},{"ultramarine ash",0.7},{"lead white",0.06}}
work(cover, {hand="detail", tool="round 3", pile=wallK2, coverage=4, fill=true, load=1})
-- the hull's own silhouette edge restated where the cover may have nicked it
local coolLo = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.15}}
local b = brush{kind="round", width=3, point=0.4}
for t0 = 40, 190, 50 do
  local pts = {}
  for t = t0, t0 + 54, 6 do pts[#pts+1] = P(t, -R(t) + 2.2) end
  b:reload(coolLo, 0.6); b:stroke(pts, {pressure={0.4, 0.4}, clip=hullM})
end

--@ chunk 110
print(wait(5*1440)); print(drying(330,250), drying(380,225))

--@ chunk 111
local z = (bulkTongues:grow(8) - seedM - petals)
work(z, {hand="glaze", pile=darkG, angle=math.pi/2, clip=true, coverage=1.8})

--@ chunk 112
local edge = {{588,110},{594,72},{612,52},{631,49},{644,34},{676,38},{690,22},{729,30},{746,17},{781,26},{806,14},{842,30},{866,22},{889,40},{934,28},{960,44},{1000,32}}
local newHole = (below(edge) * rect(585, 0, 415, 260)) - seedM - petals
local add = newHole - holeM
work(add, {hand="detail", tool="round 3", pile=spaceK, coverage=4, fill=true, load=1})
holeM = newHole + holeM
-- the remaining band between the torn ceiling and the hole: dark wall
local band = (breachM - holeM - seedM - petals)
work(band, {hand="detail", tool="round 3", pile=pile{{"bone black",2},{"ultramarine ash",0.7},{"lead white",0.06}}, coverage=3.5, fill=true})
print(add:area(), band:area())

--@ chunk 113
print(wait(6*1440)); print(drying(700,60), drying(900,40))

--@ chunk 114
print(wait(4*1440)); print(drying(700,60), drying(900,40))

--@ chunk 115
local edge = {{588,110},{594,72},{612,52},{631,49},{644,34},{676,38},{690,22},{729,30},{746,17},{781,26},{806,14},{842,30},{866,22},{889,40},{934,28},{960,44},{1000,32}}
local coolL = pile{{"lead white",1.5},{"ultramarine ash",1},{"bone black",0.6},{"cerulean blue",0.3}}
local coolD = pile{{"lead white",0.7},{"ultramarine ash",1},{"bone black",1}}
local b = brush{kind="round", width=2.4, point=0.6}
for i = 1, #edge - 1 do
  local a, c = edge[i], edge[i+1]
  local r = math.random()
  if r < 0.55 then
    b:reload(coolL, 0.5); b:stroke({{a[1], a[2]-1.2}, {c[1], c[2]-1.2}}, {pressure={rand(0.3,0.55), rand(0.25,0.5)}})
  elseif r < 0.85 then
    b:reload(coolD, 0.5); b:stroke({{a[1], a[2]-1.2}, {c[1], c[2]-1.2}}, {pressure={0.35, 0.3}})
  end
end
-- stars in the newly opened sky
local starP = pile{{"zinc white",3},{"cerulean blue",0.15}}
local starW = pile{{"zinc white",3},{"lemon chrome",0.1}}
local fine = brush{kind="round", width=1.4, point=0.9}
local mid = brush{kind="round", width=2.4, point=0.6}
local hm = holeM:shrink(3)
local n = 0
for i = 1, 300 do
  local x, y = rand(590, 1000), rand(15, 110)
  if hm:at(x, y) > 0.5 then
    n = n + 1
    local r = math.random()
    if r < 0.8 then fine:reload(starP, 0.4); fine:touch(x, y, {pressure=rand(0.15, 0.3)})
    else fine:reload(starW, 0.5); fine:touch(x, y, {pressure=rand(0.35, 0.5)}) end
  end
  if n > 45 then break end
end
-- two brighter stars with a faint halo
local halo = pile{{"zinc white",1},{"cerulean blue",0.5},{"bone black",0.6}, medium=0.5}
local h = brush{kind="round", width=7, point=0.1}
for _, p in ipairs({{735,62},{905,75}}) do
  if hm:at(p[1],p[2]) > 0.5 then
    h:reload(halo, 0.3); h:touch(p[1], p[2], {pressure=0.25})
    mid:reload(starW, 0.7); mid:touch(p[1], p[2], {pressure=0.5})
  end
end
print(n)

--@ chunk 116
local xs = {52, 120, 203, 300, 378, 470, 543, 640, 720, 800, 880, 960}
local ys = {95, 200, 290, 368}
local vis = (wallM - petals - holeM - seedM - cratesM - armsM - frameM - breachM)
local piles = {DK[3], DK[4], DK[5]}
local b = brush{kind="round", width=1.8, point=0.6}
local function lvl(x, y) local d = math.sqrt((x-CX)^2 + ((y-CY)*1.2)^2); return 1 - d / 330 end
local n = 0
for _, x in ipairs(xs) do
  local side = (x < CX) and -1.6 or 1.6
  for y = 0, 395, 12 do
    local k = lvl(x, y + 6)
    if k > 0.05 and vis:at(x + side, y + 6) > 0.5 then
      local p = piles[clamp(math.floor(k * 3.5) + 1, 1, 3)]
      b:reload(p, 0.5)
      b:stroke({{x + side, y + 0.5}, {x + side, y + 11.5}}, {pressure={0.25 + 0.4*k, 0.25 + 0.4*k}, clip=vis})
      n = n + 1
    end
  end
end
for _, y in ipairs(ys) do
  local side = (y < CY) and -1.6 or 1.6
  for x = 0, 1000, 12 do
    local k = lvl(x + 6, y)
    if k > 0.05 and vis:at(x + 6, y + side) > 0.5 then
      local p = piles[clamp(math.floor(k * 3.5) + 1, 1, 3)]
      b:reload(p, 0.5)
      b:stroke({{x + 0.5, y + side}, {x + 11.5, y + side}}, {pressure={0.25 + 0.4*k, 0.25 + 0.4*k}, clip=vis})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 117
local z = hullM * mask(function(x,y) local t,s = ST(x,y); local u = s / math.max(R(t),1); return (t > 560 and u > -0.62 and u < 0.35) and 1 or 0 end):soften(5) - armsM - frameM
work(z, {hand="glaze", pile=darkG, angle=math.atan(UY,UX), clip=true, coverage=1.6})

--@ chunk 118
print(wait(2*1440))

--@ chunk 119
local groove = pile{{"bone black",2},{"bone brown",1}}
local coolH = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.7},{"cerulean blue",0.2}}
local g = brush{kind="round", width=2.4, point=0.4}
local h = brush{kind="round", width=1.4, point=0.6}
local fm = foldOut
local seams = {
  {{408,222},{440,203},{478,190},{520,182},{556,180}},
  {{432,200},{470,186},{500,170},{530,166}},
  {{596,170},{640,152},{690,140},{740,142},{790,160}},
  {{606,148},{650,128},{700,118},{748,126},{786,140}},
  {{520,150},{528,196}}, {{470,170},{474,214}}, {{660,108},{668,160}}, {{722,112},{720,170}},
}
for _, s in ipairs(seams) do
  g:reload(groove, 0.7); g:stroke(s, {pressure={0.5,0.5}, clip=fm})
  local q = {} for i, p in ipairs(s) do q[i] = {p[1], p[2] - 1.8} end
  h:reload(coolH, 0.4); h:stroke(q, {pressure={0.3,0.25}, clip=fm})
end
local bolt = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.6}}
local bt = brush{kind="round", width=2, point=0.2}
for _, s in ipairs({seams[1], seams[3]}) do
  for i = 1, #s - 1 do
    for f = 0.25, 0.8, 0.5 do
      local x, y = lerp(s[i][1], s[i+1][1], f), lerp(s[i][2], s[i+1][2], f) - 5
      if fm:at(x, y) > 0.5 then bt:reload(bolt, 0.5); bt:touch(x, y, {pressure=0.4}) end
    end
  end
end

--@ chunk 120
-- PASS 2, chunk A: dark lay-in. Wall repainted darker (no white), frame gets armour masses.
FX = {
 pauldL = {{509,301},{525,291},{543,295},{548,311},{541,327},{524,332},{509,322}},
 pauldR = {{582,297},{600,291},{616,298},{619,315},{610,330},{591,328},{582,312}},
 gorget = {{549,298},{581,298},{587,309},{544,309}},
 tasL = {{536,399},{555,404},{553,425},{535,421}},
 tasR = {{569,404},{586,396},{593,415},{577,424}},
 kneeL = {{529,446},{549,444},{554,459},{546,468},{530,465}},
 kneeR = {{582,445},{601,441},{608,457},{600,466},{585,462}},
 greaveL = {{528,478},{552,476},{554,501},{527,503}},
 greaveR = {{586,477},{605,475},{610,500},{589,502}},
 cuffR = {{633,371},{650,361},{659,375},{644,387}},
 cuffL = {{504,375},{530,376},{529,393},{503,392}},
}
FXM = nil
for k, pts in pairs(FX) do local m = poly(pts); FXM = FXM and (FXM + m) or m end
frameM = frameM + FXM
-- the wall: near-black, a touch warmer where it faces the seed
local lampE = ellipse(441, 65, 20, 14)
local placR = rect(314, 147, 70, 50)
wallVis = wallM - petals - holeM - seedM - cratesM - armsM - frameM - breachM - rect(0, 366, 1000, 34) - lampE - placR
local wallD = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.6}}
local wallW = pile{{"bone black",1.6},{"bone brown",1},{"burnt sienna",0.35}}
local nearE = ellipse(CX, CY + 20, 300, 260):roughen(18, 70, 7):soften(6)
local nearM = wallVis * nearE
local farM = wallVis - nearM
local rad = function(x, y) return math.atan(y - CY, x - CX) end
work(farM, {hand="body", pile=wallD, angle=rad, coverage=3.5, fill=true, clip=true, load=0.9})
work(nearM, {hand="body", pile=wallW, angle=rad, coverage=3.5, fill=true, clip=true, load=0.9})
work(FXM, {hand="detail", pile=frameP, coverage=3.5, fill=true})
print(wait(8*1440))

--@ chunk 121
-- PASS 2, chunk B: frame plate faces (machined, two lights: warm floor bounce below, cold breach above)
local plateTop = pile{{"bone black",2},{"ultramarine ash",1.2},{"lead white",0.14}}
local plateMid = pile{{"bone black",2},{"ultramarine ash",0.7},{"bone brown",0.6}}
local plateLow = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}}
local plateHot = pile{{"bone black",1},{"burnt sienna",1},{"cadmium red",0.4},{"Mars orange",0.3}}
local nz = noise{seed=41, period=9, octaves=2}
local fb = brush{kind="filbert", width=2.6}
local all = {}
for k, pts in pairs(framePartsDef()) do all[#all+1] = {k, pts} end
for k, pts in pairs(FX) do all[#all+1] = {k, pts} end
local nst = 0
for _, e in ipairs(all) do
  local k, pts = e[1], e[2]
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = math.min(x0, p[1]); x1 = math.max(x1, p[1]); y0 = math.min(y0, p[2]); y1 = math.max(y1, p[2]) end
  local face = poly(pts):shrink(2.2)
  -- plates covered by overlapping armour keep only what shows
  if not FX[k] then face = face - FXM:grow(1.2) end
  local ang = ((x1 - x0) > (y1 - y0)) and 0 or math.pi/2
  if k == "uaR" or k == "faR" then ang = math.atan(30, 23) end
  if k == "thR" then ang = math.atan(46, 19) end
  local legs = (y0 > 395) and 0.08 or 0
  for y = y0, y1, 2.2 do for x = x0, x1, 2.2 do
    local px, py = x + rand(-1.1, 1.1), y + rand(-1.1, 1.1)
    if face:at(px, py) > 0.5 then
      local r = (py - y0) / math.max(y1 - y0, 1) + 0.22 * nz(px, py) + legs
      local pl = (r < 0.28) and plateTop or (r < 0.72 and plateMid or (r < 1.08 and plateLow or plateHot))
      fb:reload(pl, 0.6)
      local a = ang + rand(-0.12, 0.12)
      local L = rand(4, 7)
      fb:stroke({{px - math.cos(a)*L/2, py - math.sin(a)*L/2}, {px + math.cos(a)*L/2, py + math.sin(a)*L/2}}, {pressure={0.5, 0.4}, clip=face})
      nst = nst + 1
    end
  end end
end
print(nst)

--@ chunk 122
-- PASS 2, chunk C: the husk's cut wall. A thick band round the womb opening:
-- dark armour skin outside, a dull red-hot section, and a torn incandescent inner lip.
local od = openM:distance()
local sg = (od:at(CX, CY) > 0) and 1 or -1
local jag = noise{seed=77, period=22, octaves=3, kind="ridged"}
local jag2 = noise{seed=78, period=60, octaves=2}
local function wid(x, y)
  local t, s = ST(x, y)
  local k = math.sin(math.pi * clamp((t - 190) / 340, 0, 1))
  local base = (s > 0) and 15 or 9
  return base * (0.35 + 0.65 * k) + 7 * jag(x, y) + 4 * jag2(x, y)
end
local F = mask(function(x, y)
  local d = sg * od:at(x, y)
  if d <= 0 or d > 30 then return 0 end
  local f = d / math.max(wid(x, y), 1)
  if f >= 1 then return 0 end
  return 0.05 + 0.95 * f
end)
local keep = frameM:grow(1.5) + armsM
local skin = F:band(0.04, 0.26, 0) - keep
local sectO = F:band(0.26, 0.55, 0) - keep
local sect = F:band(0.55, 0.867, 0) - keep
local lip  = F:band(0.867, 1.01, 0) - keep
HUSKBAND = F:band(0.04, 1.01, 0) - keep
local skinP = pile{{"bone black",2},{"ultramarine ash",0.6},{"bone brown",0.5}}
local sectP = pile{{"bone black",1},{"burnt sienna",1},{"cadmium red",0.45},{"Mars orange",0.3}}
local lipP  = pile{{"cadmium yellow",2},{"lead white",1},{"Mars orange",0.3}}
local sectOP = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.3}}
local along = math.atan(UY, UX)
work(skin, {hand="detail", tool="round 2.4", pile=skinP, angle=along, coverage=4, fill=true, load=1})
work(sectO, {hand="detail", tool="round 2.4", pile=sectOP, angle=along, coverage=4, fill=true, load=1})
work(sect, {hand="detail", tool="round 2.4", pile=sectP, angle=along, coverage=4, fill=true, load=1})
work(lip,  {hand="detail", tool="round 2", pile=lipP, angle=along, coverage=3.5, fill=true, load=1})
print(skin:area(), sect:area(), lip:area())

--@ chunk 123
-- PASS 2, chunk G: crates into the room's light: dark fronts warming toward the seed, lit right-hand sides, contact shadows.
local crD = pile{{"bone black",2},{"bone brown",1},{"ultramarine ash",0.4},{"lead white",0.08}}
local crM = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}}
local crL = DK[4]
local nz = noise{seed=93, period=14, octaves=2}
local fb = brush{kind="filbert", width=3.5}
local tri = nil
for _, c in ipairs({crA, crB, crC}) do
  local x1, y1 = c[1] + c[3], c[2] + c[4]
  local t = poly({{x1 - 25, y1}, {x1, y1}, {x1, y1 - 25}})
  tri = tri and (tri + t) or t
end
for _, c in ipairs({crA, crB, crC}) do
  local x0, y0, w, h = c[1], c[2], c[3], c[4]
  local face = rect(x0 + 1, y0 + 1, w - 2, h - 2) - tri
  for y = y0, y0 + h, 3 do for x = x0, x0 + w, 3 do
    local px, py = x + rand(-1.5, 1.5), y + rand(-1.5, 1.5)
    if face:at(px, py) > 0.5 then
      local u = (px - x0) / w + 0.15 * nz(px, py)
      local p = (u < 0.6) and crD or ((u < 0.9) and crM or crL)
      fb:reload(p, 0.6)
      fb:stroke({{px, py - 3}, {px + rand(-0.3, 0.3), py + 3}}, {pressure={0.55, 0.45}, clip=face})
    end
  end end
end
work(crSide, {hand="detail", tool="round 3", pile=crL, angle=math.pi/2, coverage=3.5, fill=true, load=1})
print(wait(3*1440))
-- rails: a groove inset from each edge, its right-hand lip catching the light
local groove = pile{{"bone black",2},{"bone brown",1}}
local g = brush{kind="round", width=2, point=0.4}
local l = brush{kind="round", width=1.4, point=0.6}
for _, c in ipairs({crA, crB, crC}) do
  local x0, y0, w, h = c[1], c[2], c[3], c[4]
  local ins = 6
  local L, R, T, B = x0 + ins, x0 + w - ins, y0 + ins, y0 + h - ins
  for _, s in ipairs({{{L,T},{R,T}}, {{L,B},{R - 20,B}}, {{L,T},{L,B}}, {{R,T},{R,B - 20}}}) do
    g:reload(groove, 0.6); g:stroke(s, {pressure={0.5, 0.5}})
  end
  l:reload(crM, 0.5); l:stroke({{L + 1.8, T + 2}, {L + 1.8, B - 2}}, {pressure={0.35, 0.3}})
  l:reload(crL, 0.5); l:stroke({{x0 + w - 1.6, y0 + 2}, {x0 + w - 1.6, y0 + h - 4}}, {pressure={0.45, 0.35}})
  -- stencilled codes, dull
  local st3 = pile{{"yellow ochre",1},{"bone brown",0.6},{"bone black",0.5}}
  local sx, sy = x0 + 16, y0 + 20
  for r = 0, 1 do
    local xx = sx
    for i = 1, 5 do
      local ww = rand(3, 8)
      l:reload(st3, 0.5); l:stroke({{xx, sy + r*7}, {xx + ww, sy + r*7}}, {pressure={0.55, 0.5}})
      xx = xx + ww + 3
    end
  end
end
-- contact shadow where they stand on the deck
local sh = pile{{"bone black",2},{"bone brown",1}}
work(rect(26, 459, 238, 7):roughen(2, 20, 3), {hand="detail", tool="round 2.4", pile=sh, coverage=3, fill=true})

--@ chunk 124
print(wait(6*1440))

--@ chunk 125
-- PASS 2, chunk D: the frame's machining: plate grooves, two-light bevels, backlit rims.
local groove = pile{{"bone black",2},{"bone brown",1}}
local coolH = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.7},{"cerulean blue",0.2}}
local bevW = pile{{"burnt sienna",1},{"cadmium red",0.5},{"Mars orange",0.5},{"bone black",0.3}}
local hot = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local warm = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.3}}
local dim = pile{{"cadmium red",1},{"Mars orange",1},{"burnt sienna",0.5}}
local gb = brush{kind="round", width=1.8, point=0.5}
local lb = brush{kind="round", width=1.4, point=0.7}
local rb = brush{kind="round", width=1.9, point=0.5}
local brightBG = BRIGHTBG or (openM:grow(6))
local function orient(pts)
  local a = 0
  for i = 1, #pts do local p, q = pts[i], pts[i % #pts + 1]; a = a + (p[1]*q[2] - q[1]*p[2]) end
  return (a > 0) and 1 or -1   -- screen coords: >0 means clockwise on screen
end
local function edges(pts, fn)
  local o = orient(pts)
  for i = 1, #pts do
    local a, b = pts[i], pts[i % #pts + 1]
    local dx, dy = b[1]-a[1], b[2]-a[2]
    local L = math.sqrt(dx*dx + dy*dy)
    if L > 4 then
      local nx, ny = o*dy/L, -o*dx/L
      fn(a, b, nx, ny, L)
    end
  end
end
local function seg(a, b, nx, ny, inset, f0, f1)
  return {{lerp(a[1], b[1], f0) - nx*inset, lerp(a[2], b[2], f0) - ny*inset},
          {lerp(a[1], b[1], f1) - nx*inset, lerp(a[2], b[2], f1) - ny*inset}}
end
-- 1. armour plates cast a dark groove onto the limb beneath them
for k, pts in pairs(FX) do
  edges(pts, function(a, b, nx, ny, L)
    local mx, my = (a[1]+b[1])/2 + nx*3, (a[2]+b[2])/2 + ny*3
    if frameM:at(mx, my) > 0.5 then
      gb:reload(groove, 0.7); gb:stroke(seg(a, b, nx, ny, -0.6, 0.0, 1.0), {pressure={0.55, 0.55}, clip=frameM})
    end
  end)
end
-- 2. bevels: edges facing down take the warm floor, edges facing up the cold breach; silhouette edges against the womb take the rim
local all = {}
for k, pts in pairs(framePartsDef()) do all[#all+1] = {k, pts} end
for k, pts in pairs(FX) do all[#all+1] = {k, pts} end
local nr = 0
for _, e in ipairs(all) do
  local k, pts = e[1], e[2]
  edges(pts, function(a, b, nx, ny, L)
    local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
    local outside = frameM:at(mx + nx*3, my + ny*3) < 0.5
    local covered = (not FX[k]) and FXM:at(mx - nx*2, my - ny*2) > 0.5
    if covered then return end
    if outside and brightBG:at(mx + nx*4, my + ny*4) > 0.5 then
      local d = math.sqrt((mx - CX)^2 + (my - CY)^2)
      if math.random() < 0.35 then return end
      local p = (d < 55) and warm or dim
      local f0, f1 = rand(0.05, 0.3), rand(0.6, 0.95)
      rb:reload(p, 0.6); rb:stroke(seg(a, b, nx, ny, 1.5, f0, f1), {pressure={rand(0.3,0.5), rand(0.15,0.35)}, ramps={0.1,0.4}, clip=frameM})
      nr = nr + 1
    elseif ny > 0.55 then
      lb:reload(bevW, 0.6); lb:stroke(seg(a, b, nx, ny, 1.3, 0.12, 0.88), {pressure={0.4, 0.35}, clip=frameM})
    elseif ny < -0.55 then
      lb:reload(coolH, 0.5); lb:stroke(seg(a, b, nx, ny, 1.3, 0.15, 0.85), {pressure={0.3, 0.25}, clip=frameM})
    end
  end)
end
-- 3. panel seams inside the big plates: a dark groove with a lit lip on its lower side
local seams = {
  {{565,309},{564,338},{561,368}},          -- chest keel
  {{539,326},{552,331},{564,334}}, {{564,334},{577,330},{589,325}},   -- pectoral plates
  {{555,377},{567,377}}, {{555,383},{567,383}},   -- abdominal segments
  {{538,430},{554,431}}, {{569,428},{591,424}},   -- thigh plates
  {{531,486},{551,485}}, {{589,486},{606,484}},   -- greave bands
  {{512,312},{544,306}}, {{585,306},{616,312}},   -- pauldron ridges
}
for _, s in ipairs(seams) do
  gb:reload(groove, 0.7); gb:stroke(s, {pressure={0.5, 0.5}, clip=frameM})
  local q = {} for i, p in ipairs(s) do q[i] = {p[1], p[2] + 1.6} end
  lb:reload(bevW, 0.5); lb:stroke(q, {pressure={0.3, 0.25}, clip=frameM})
end
print("rims", nr)

--@ chunk 126
print(wait(2*1440))

--@ chunk 127
-- PASS 2, chunk E: the joints still glow from the printer: slits between plates, a visor, one chest vent.
local ember = pile{{"cadmium red",1},{"Mars orange",1.2},{"cadmium yellow",0.3}}
local hotW = pile{{"lead white",3},{"lemon chrome",1}}
local f = brush{kind="flat", width=2.8}
local fs = brush{kind="flat", width=2.0}
local r = brush{kind="round", width=1.5, point=0.8}
local slits = {
  {{548,309.5},{582,309.5}, 0},               -- gorget/chest ring
  {{513,331},{529,335}, 1}, {{597,331},{612,329}, 1},   -- shoulders under the pauldrons
  {{616.5,359},{629,350}, 1}, {{514,357},{530,357.5}, 1}, -- elbows
  {{635,368},{648,361}, 1}, {{506,374.5},{528,375.5}, 1}, -- wrists
  {{555,371.5},{568,371.5}, 1}, {{554,389.5},{568,389.5}, 1}, -- waist
  {{539,402},{553,406}, 1}, {{572,405},{585,399}, 1},     -- hips
  {{533,467.5},{548,469}, 1}, {{587,464.5},{602,465.5}, 1}, -- knees, under the caps
}
for _, s in ipairs(slits) do
  local br = (s[3] == 0) and fs or f
  br:reload(ember, 0.7); br:stroke({s[1], s[2]}, {pressure={0.7, 0.6}, orient="along"})
  local mx, my = (s[1][1]+s[2][1])/2, (s[1][2]+s[2][2])/2
  r:reload(hotW, 0.6)
  r:stroke({{lerp(s[1][1], mx, 0.35), lerp(s[1][2], my, 0.35)}, {lerp(s[2][1], mx, 0.35), lerp(s[2][2], my, 0.35)}}, {pressure={0.45, 0.35}})
end
-- visor slit
fs:reload(ember, 0.7); fs:stroke({{559,281},{575,279.5}}, {pressure={0.6, 0.5}, orient="along"})
r:reload(hotW, 0.6); r:stroke({{562,280.7},{572,279.8}}, {pressure={0.4, 0.3}})
-- one chest vent
fs:reload(ember, 0.6); fs:stroke({{559,345},{569,345}}, {pressure={0.55, 0.5}, orient="along"})
r:reload(hotW, 0.5); r:touch(564, 345, {pressure=0.35})

--@ chunk 128
-- PASS 2, chunk G: crates into the room's light: dark fronts warming toward the seed, lit right-hand sides, contact shadows.
local crD = pile{{"bone black",2},{"bone brown",1},{"ultramarine ash",0.4},{"lead white",0.08}}
local crM = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}}
local crL = DK[4]
local nz = noise{seed=93, period=14, octaves=2}
local fb = brush{kind="filbert", width=3.5}
local tri = nil
for _, c in ipairs({crA, crB, crC}) do
  local x1, y1 = c[1] + c[3], c[2] + c[4]
  local t = poly({{x1 - 25, y1}, {x1, y1}, {x1, y1 - 25}})
  tri = tri and (tri + t) or t
end
for _, c in ipairs({crA, crB, crC}) do
  local x0, y0, w, h = c[1], c[2], c[3], c[4]
  local face = rect(x0 + 1, y0 + 1, w - 2, h - 2) - tri
  for y = y0, y0 + h, 3 do for x = x0, x0 + w, 3 do
    local px, py = x + rand(-1.5, 1.5), y + rand(-1.5, 1.5)
    if face:at(px, py) > 0.5 then
      local u = (px - x0) / w + 0.15 * nz(px, py)
      local p = (u < 0.8) and crD or ((u < 0.97) and crM or crL)
      fb:reload(p, 0.6)
      fb:stroke({{px, py - 3}, {px + rand(-0.3, 0.3), py + 3}}, {pressure={0.55, 0.45}, clip=face})
    end
  end end
end
work(crSide, {hand="detail", tool="round 3", pile=crM, angle=math.pi/2, coverage=3.5, fill=true, load=1})
print(wait(3*1440))
-- rails: a groove inset from each edge, its right-hand lip catching the light
local groove = pile{{"bone black",2},{"bone brown",1}}
local g = brush{kind="round", width=2, point=0.4}
local l = brush{kind="round", width=1.4, point=0.6}
for _, c in ipairs({crA, crB, crC}) do
  local x0, y0, w, h = c[1], c[2], c[3], c[4]
  local ins = 6
  local L, R, T, B = x0 + ins, x0 + w - ins, y0 + ins, y0 + h - ins
  for _, s in ipairs({{{L,T},{R,T}}, {{L,B},{R - 20,B}}, {{L,T},{L,B}}, {{R,T},{R,B - 20}}}) do
    g:reload(groove, 0.6); g:stroke(s, {pressure={0.5, 0.5}})
  end
  l:reload(crM, 0.5); l:stroke({{L + 1.8, T + 2}, {L + 1.8, B - 2}}, {pressure={0.35, 0.3}})
  l:reload(crL, 0.5); l:stroke({{x0 + w - 1.6, y0 + 2}, {x0 + w - 1.6, y0 + h - 4}}, {pressure={0.45, 0.35}})
  -- stencilled codes, dull
  local st3 = pile{{"yellow ochre",1},{"bone brown",0.6},{"bone black",0.5}}
  local sx, sy = x0 + 16, y0 + 20
  for r = 0, 1 do
    local xx = sx
    for i = 1, 5 do
      local ww = rand(3, 8)
      l:reload(st3, 0.5); l:stroke({{xx, sy + r*7}, {xx + ww, sy + r*7}}, {pressure={0.55, 0.5}})
      xx = xx + ww + 3
    end
  end
end
-- contact shadow where they stand on the deck
local sh = pile{{"bone black",2},{"bone brown",1}}
work(rect(26, 459, 238, 7):roughen(2, 20, 3), {hand="detail", tool="round 2.4", pile=sh, coverage=3, fill=true})

--@ chunk 129
-- PASS 2, chunk F: wall panel seams re-cut; the seed's light rakes across them, catching the lips that face it
-- and the tooth of the plating; a faded stencil 07.
local grooveW = pile{{"bone black",2},{"ultramarine ash",0.3},{"bone brown",0.4}}
local xs = {52, 120, 203, 300, 378, 470, 543, 640, 720, 800, 880, 960}
local ys = {95, 200, 290, 368}
local vis = wallVis
local g = brush{kind="round", width=2.2, point=0.4}
for _, x in ipairs(xs) do
  local y0 = nil
  for y = 0, 366, 6 do
    local inn = vis:at(x, y + 3) > 0.5
    if inn then g:reload(grooveW, 0.6); g:stroke({{x, y}, {x + rand(-0.3,0.3), y + 6.2}}, {pressure={0.5,0.5}, clip=vis}) end
  end
end
for _, y in ipairs(ys) do
  for x = 0, 1000, 6 do
    if vis:at(x + 3, y) > 0.5 then g:reload(grooveW, 0.6); g:stroke({{x, y}, {x + 6.2, y + rand(-0.3,0.3)}}, {pressure={0.5,0.5}, clip=vis}) end
  end
end
-- lips facing the glow
local piles = {DK[3], DK[4], DK[5], DK[6]}
local b = brush{kind="round", width=1.6, point=0.6}
local function lvl(x, y) local d = math.sqrt((x-CX)^2 + ((y-CY)*1.25)^2); return 1 - d / 430 end
local n = 0
for _, x in ipairs(xs) do
  local side = (x < CX) and 1.9 or -1.9
  for y = 0, 366, 10 do
    local k = lvl(x, y + 5) + rand(-0.06, 0.06)
    if k > 0.08 and vis:at(x + side, y + 5) > 0.5 then
      local p = piles[clamp(math.floor(k * 4.2) + 1, 1, 4)]
      b:reload(p, 0.5)
      b:stroke({{x + side, y + 0.5}, {x + side, y + 9.5}}, {pressure={0.2 + 0.45*k, 0.2 + 0.45*k}, clip=vis})
      n = n + 1
    end
  end
end
for _, y in ipairs(ys) do
  local side = (y < CY) and 1.9 or -1.9
  for x = 0, 1000, 10 do
    local k = lvl(x + 5, y) + rand(-0.06, 0.06)
    if k > 0.08 and vis:at(x + 5, y + side) > 0.5 then
      local p = piles[clamp(math.floor(k * 4.2) + 1, 1, 4)]
      b:reload(p, 0.5)
      b:stroke({{x + 0.5, y + side}, {x + 9.5, y + side}}, {pressure={0.2 + 0.45*k, 0.2 + 0.45*k}, clip=vis})
      n = n + 1
    end
  end
end
-- raking light on the plating's tooth: a dry, broken scumble fanning out from the opening
local rk = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.2}}
local function cov(x, y) local d = math.sqrt((x-CX)^2 + ((y-CY)*1.3)^2); return 0.75 * clamp(1 - d/340, 0, 1) end
work(vis * ellipse(CX, CY, 340, 262), {hand="scumble", pile=rk, load_at=function(x, y) return 0.04 + 0.12 * cov(x, y) end, pressure={0.05, 0.15}, coverage=0.7, clip=true,
  angle=function(x, y) return math.atan(y - CY, x - CX) end})
-- stencil 07: sprayed through a stencil long ago, worn
local zeroO = rect(183, 57, 32, 32) + ellipse(199, 57, 16, 9) + ellipse(199, 89, 16, 9)
local zeroI = rect(190, 59, 18, 28) + ellipse(199, 59, 9, 5) + ellipse(199, 87, 9, 5)
local zero = zeroO - zeroI - rect(197, 45, 4, 13) - rect(197, 88, 4, 12)
local seven = rect(222, 49, 34, 8) + ribbon({{251, 57}, {233, 97}}, 8)
seven = seven - rect(238, 57, 22, 2.5)
local dashes = nil
local dx = 183
for i, w in ipairs({7, 4, 9, 3, 6, 8, 4}) do local r = rect(dx, 104, w, 3); dashes = dashes and (dashes + r) or r; dx = dx + w + 4 end
local stM = (zero + seven + dashes) * vis
local st3 = pile{{"yellow ochre",1},{"bone brown",0.6},{"bone black",0.5}}
work(stM, {hand="detail", tool="round 2.4", pile=st3, coverage=3, fill=true, load=1})
STENCIL = stM
print(n)
-- wear: the dark of the wall scuffed back over the stencil
work(stM:grow(1.5), {hand="scumble", pile=pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.6}}, load=0.25, pressure={0.1, 0.3}, coverage=0.6, clip=true})

--@ chunk 130
-- PASS 2, chunk H: the lower flaps' inner faces glow from the womb; their torn free edges show the shell's thickness.
local od = openM:distance()
local sg = (od:at(CX, CY) > 0) and 1 or -1
local lowF = (Q3 + Q4) - openM - frameM:grow(1) - armsM - poly({{520,470},{612,466},{640,510},{606,522},{520,524},{500,505}}, true)
local nz = noise{seed=55, period=16, octaves=2}
local fb = brush{kind="filbert", width=3.2}
local piles = {DK[6], DK[5], DK[4], DK[3], DK[2]}
local n = 0
for y = 285, 520, 3.4 do for x = 430, 820, 3.4 do
  local px, py = x + rand(-1.7, 1.7), y + rand(-1.7, 1.7)
  if lowF:at(px, py) > 0.5 then
    local d = -sg * od:at(px, py) + 9 * nz(px, py)
    local i = (d < 12) and 1 or ((d < 30) and 2 or ((d < 55) and 3 or ((d < 80) and 4 or 5)))
    fb:reload(piles[i], 0.6)
    local a = math.atan(py - CY, px - CX) + rand(-0.2, 0.2)
    local L = rand(4, 8)
    fb:stroke({{px - math.cos(a)*L/2, py - math.sin(a)*L/2}, {px + math.cos(a)*L/2, py + math.sin(a)*L/2}}, {pressure={0.55, 0.4}, clip=lowF})
    n = n + 1
  end
end end
print(n)
print(wait(3*1440))
-- free edge: dark armour skin with a thin hot cut line just inside it
local freeEdge = ((Q3 + Q4) - (Q3 + Q4):shrink(3.5)) - openM:grow(4) - frameM:grow(1) - armsM
work(freeEdge, {hand="detail", tool="round 2", pile=pile{{"bone black",2},{"ultramarine ash",0.6},{"bone brown",0.5}}, coverage=3.5, fill=true, load=1})
local cutLine = (((Q3 + Q4):shrink(3.5)) - ((Q3 + Q4):shrink(5.5))) - openM:grow(4) - frameM:grow(1) - armsM
work(cutLine, {hand="detail", tool="round 1.6", pile=DK[5], coverage=2.5, fill=true, load=0.8})

--@ chunk 131
-- PASS 2, chunk I: the flaps' inner faces were too bright and the free edge read as a cog. Darken outward, lose the edge.
print(wait(5*1440))
local od = openM:distance()
local sg = (od:at(CX, CY) > 0) and 1 or -1
local all = (Q3 + Q4) - openM:grow(4) - frameM:grow(1) - armsM - poly({{520,470},{612,466},{640,510},{606,522},{520,524},{500,505}}, true)
local nz = noise{seed=56, period=18, octaves=2}
local fb = brush{kind="filbert", width=3.2}
local piles = {DK[5], DK[4], DK[3], DK[2], DK[1]}
local n = 0
for y = 285, 525, 3.4 do for x = 430, 825, 3.4 do
  local px, py = x + rand(-1.7, 1.7), y + rand(-1.7, 1.7)
  if all:at(px, py) > 0.5 then
    local d = -sg * od:at(px, py) + 7 * nz(px, py)
    local i = (d < 10) and 1 or ((d < 22) and 2 or ((d < 40) and 3 or ((d < 62) and 4 or 5)))
    if i >= 2 then
      fb:reload(piles[i], 0.6)
      local a = math.atan(py - CY, px - CX) + rand(-0.2, 0.2)
      local L = rand(4, 8)
      fb:stroke({{px - math.cos(a)*L/2, py - math.sin(a)*L/2}, {px + math.cos(a)*L/2, py + math.sin(a)*L/2}}, {pressure={0.55, 0.4}, clip=all})
      n = n + 1
    end
  end
end end
print(n)

--@ chunk 132
-- PASS 2, chunk J: knock the 07 and the placard back into the dark; torn, still-hot edges on the upper flaps.
print(wait(4*1440))
local wallD = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.6}}
work(STENCIL:grow(1.5), {hand="scumble", pile=wallD, load=0.35, pressure={0.15, 0.35}, coverage=1.3, clip=true})
work(rect(316, 149, 66, 46), {hand="scumble", pile=wallD, load=0.3, pressure={0.12, 0.3}, coverage=1.1, clip=true})
-- the upper flaps' free edges: a thin cold skin, then the cut face of the shell, dull red where it tore
local up = foldOut - armsM - frameM
local edgeB = (up - up:shrink(5)) - openM:grow(26) - HUSKBAND:grow(4)
local skinB = edgeB - (up:shrink(1.6))
local cutB = edgeB * up:shrink(1.6)
work(cutB, {hand="detail", tool="round 1.8", pile=DK[4], coverage=3, fill=true, load=0.9})
work(skinB, {hand="detail", tool="round 1.6", pile=pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.15}}, coverage=2.5, fill=true, load=0.8})
print(edgeB:area())

--@ chunk 133
-- PASS 2, chunk K: the flap-edge band read as trim. Break it: armour skin closes over it in long runs,
-- leaving the cut face showing only in torn stretches.
print(wait(4*1440))
local up = foldOut - armsM - frameM
local edgeB = (up - up:shrink(5)) - openM:grow(26) - HUSKBAND:grow(4)
local nz = noise{seed=313, period=45, octaves=2}
local runs = mask(function(x, y) return (nz(x, y) > -0.05) and 1 or 0 end)
local upP = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.15}}
work(edgeB:grow(1.2) * runs, {hand="detail", tool="round 2", pile=upP, coverage=3.5, fill=true, load=1})

--@ chunk 134
-- PASS 2, chunk L: the flap-edge skin also ran round the lower flaps and outlined them like a cog. Close it with dark.
print(wait(4*1440))
local L = Q3 + Q4
local below = mask(function(x, y) local t, s = ST(x, y); return (s > 25) and 1 or 0 end)
local G = (L:grow(1.5) - L:shrink(7)) * below - openM:grow(6) - frameM:grow(0.5) - armsM
work(G, {hand="detail", tool="round 2.2", pile=DK[1], coverage=3.5, fill=true, load=1})
-- the upper flaps' outer sides, away from the torn top edge: the same skin, toned down to the flap's dark
print(G:area())

--@ chunk 135
-- PASS 2, chunk M: fewer, larger tears on the lower flaps: fill the small saw-teeth, keep one big rip; no outline.
print(wait(3*1440))
local L = Q3 + Q4
local hull4 = poly({{632,460},{650,488},{680,472},{710,481},{742,467},{770,451},{794,418},{812,385},{803,345},{800,325},{770,300}})
local hull3 = poly({{622,450},{604,488},{605,500},{622,470}})
local fillR = (hull4 + hull3) - L - frameM:grow(0.5) - armsM
local below = mask(function(x, y) local t, s = ST(x, y); return (s > 25) and 1 or 0 end)
local G = ((L:grow(2) - L:shrink(8)) * below - openM:grow(6) - frameM:grow(0.5) - armsM) + fillR
local fb = brush{kind="filbert", width=3}
local n = 0
for y = 380, 525, 3 do for x = 430, 820, 3 do
  local px, py = x + rand(-1.5, 1.5), y + rand(-1.5, 1.5)
  if G:at(px, py) > 0.5 then
    fb:reload((math.random() < 0.55) and DK[2] or DK[1], 0.6)
    local a = math.atan(py - CY, px - CX) + rand(-0.2, 0.2)
    fb:stroke({{px - math.cos(a)*3, py - math.sin(a)*3}, {px + math.cos(a)*3, py + math.sin(a)*3}}, {pressure={0.55, 0.45}, clip=G})
    n = n + 1
  end
end end
print(n)

--@ chunk 136
-- PASS 2, chunk N: grey flecks of the edge skin left between the legs: back into shadow.
local Z = ((foldOut:grow(1.5) - foldOut:shrink(7)) * rect(500, 425, 135, 100)) - frameM:grow(0.4) - armsM
local fb = brush{kind="filbert", width=2.4}
local n = 0
for y = 425, 525, 2.4 do for x = 500, 635, 2.4 do
  local px, py = x + rand(-1.2, 1.2), y + rand(-1.2, 1.2)
  if Z:at(px, py) > 0.5 then
    fb:reload((math.random() < 0.5) and DK[2] or DK[1], 0.6)
    fb:stroke({{px, py - 2.5}, {px + rand(-0.5,0.5), py + 2.5}}, {pressure={0.55, 0.45}, clip=Z})
    n = n + 1
  end
end end
print(n)

--@ chunk 137
local Z = (rect(515, 438, 18, 46) + rect(546, 455, 14, 32) + rect(574, 438, 14, 48)) - frameM:grow(0.3)
work(Z, {hand="detail", tool="round 2", pile=DK[1], coverage=3.5, fill=true, load=1})

--@ chunk 138
print(wait(2*1440))
local Z = (rect(513, 436, 22, 50) + rect(545, 453, 16, 36) + rect(572, 436, 18, 52)) - frameM:grow(0.3)
local fb = brush{kind="filbert", width=2.6}
for y = 436, 490, 2.4 do for x = 513, 592, 2.4 do
  local px, py = x + rand(-1.2, 1.2), y + rand(-1.2, 1.2)
  if Z:at(px, py) > 0.5 then
    local r = math.random()
    fb:reload((r < 0.4) and DK[2] or ((r < 0.8) and DK[3] or DK[4]), 0.6)
    fb:stroke({{px - 2, py - 2}, {px + 2, py + 2}}, {pressure={0.55, 0.45}, clip=Z})
  end
end end

--@ chunk 139
-- PASS 2, chunk O: the 07 and the placard back, as old worn paint on the wall rather than labels laid on top.
local st3 = pile{{"yellow ochre",1},{"bone brown",0.6},{"bone black",0.5}}
work(STENCIL, {hand="scumble", pile=st3, load=0.45, pressure={0.2, 0.45}, coverage=1.6, clip=true})
local plc = pile{{"bone black",1},{"lead white",0.25},{"yellow ochre",0.2}}
local plate = rect(320, 152, 58, 40)
work(plate, {hand="detail", tool="round 2.6", pile=plc, coverage=3, fill=true, load=0.9})
local hz = pile{{"chrome yellow",2},{"yellow ochre",1},{"bone black",0.8}}
work(rect(320, 152, 58, 6), {hand="detail", tool="round 2", pile=hz, coverage=3, fill=true, load=0.9})
print(wait(1440))
local ink = pile{{"bone black",2},{"bone brown",1}}
local r = brush{kind="round", width=1.3, point=0.6}
for i, y in ipairs({164, 169, 174, 179, 184}) do
  local x = 325
  while x < 370 do
    local w = rand(3, 9)
    r:reload(ink, 0.5); r:stroke({{x, y}, {math.min(x + w, 372), y}}, {pressure={0.4, 0.4}, clip=plate})
    x = x + w + rand(1.5, 3)
  end
end
local red = pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.15}}
local rb = brush{kind="round", width=3.2, point=0.3}
rb:reload(red, 0.8); rb:stroke({{324, 190}, {350, 172}, {376, 156}}, {pressure={0.75, 0.5}, ramps={0.05, 0.3}, shake=1})
print(wait(2*1440))
local wallD = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.6}}
work(plate:grow(1), {hand="scumble", pile=wallD, load=0.15, pressure={0.08, 0.2}, coverage=0.5, clip=true})

--@ chunk 140
print(wait(3*1440))
local wallD = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.6}}
stipple(STENCIL:grow(0.5), {pile=wallD, width=2.2, coverage=0.35, cluster={0.7, 6}, pressure={0.3, 0.6}})
local red = pile{{"cadmium red",1},{"burnt sienna",0.4}}
local rb = brush{kind="round", width=3.6, point=0.3}
rb:reload(red, 0.9); rb:stroke({{326, 189}, {350, 173}, {374, 158}}, {pressure={0.8, 0.55}, ramps={0.05, 0.3}, shake=1})

--@ chunk 141
-- PASS 2, chunk P: the left flap's outer side faces away from the breach; its grey skin line down to the flap's dark.
local Z = (foldOut:grow(1.8) - foldOut:shrink(6)) * rect(380, 130, 75, 200) - openM:grow(10) - HUSKBAND:grow(3) - armsM
local sk = pile{{"bone black",2},{"ultramarine ash",0.6},{"bone brown",0.5}}
work(Z, {hand="detail", tool="round 2.2", pile=sk, coverage=3.5, fill=true, load=1})
print(Z:area())
