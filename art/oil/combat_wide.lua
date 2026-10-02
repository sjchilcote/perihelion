-- easel session "combat_wide": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=1212,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.6},{"lead white",0.3}}, um=90, apply="knife", texture=0.35}}}
-- stair centreline from the top landing (upper left) curving down to the fold (lower right)
CL = {{215,175},{275,262},{360,335},{470,392},{600,432},{740,462},{880,490}}
HW = {62,74,88,102,116,128,140}
STAIR = ribbon(CL, HW)
LAND = ellipse(190,165,120,52)
-- the hall: warm dark above, cold violet seeping from below right
local hallW = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.8}}
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local vio = pile{{"cobalt violet",1.5},{"ultramarine blue",1},{"bone black",0.8},{"lead white",0.3}}
work(everywhere() - STAIR - LAND, {hand="broad", pile=hallD, coverage=2.6, fill=true, angle=0.5})
work(ellipse(150,90,260,150):soften(40) - STAIR - LAND, {hand="body", tool="filbert 10", pile=hallW, coverage=2.2, fill=true, angle=0.3, length={30,90}, edge="soft"})
work(ellipse(900,520,260,160):roughen(20,80,3) - STAIR:shrink(30), {hand="body", tool="filbert 10", pile=vio, coverage=2.6, fill=true, angle=-0.6, length={30,90}, edge="soft"})

--@ chunk 2
HW2 = {120,140,165,190,215,240,262}
STAIR = ribbon(CL, HW2)
function PATH(t)
  local n = #CL - 1; local f = clamp(t,0,0.9999)*n; local i = math.floor(f)+1; local u = f - (i-1)
  local a, b = CL[i], CL[i+1]
  local x, y = lerp(a[1],b[1],u), lerp(a[2],b[2],u)
  local dx, dy = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(dx*dx+dy*dy)
  return x, y, -dy/l, dx/l, lerp(HW2[i],HW2[i+1],u)/2
end
NSTEP = 26
local function tc(i, lo, hi) return lerp(lo, hi, i/NSTEP) end
local warmT = pile{{"raw sienna",1.5},{"yellow ochre",0.8},{"burnt sienna",0.6},{"lead white",0.5}}
local midT = pile{{"raw sienna",1.2},{"burnt sienna",1},{"bone brown",0.8},{"lead white",0.3}}
local coolT = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"cobalt violet",0.5},{"ultramarine ash",0.5},{"lead white",0.3}}
local riser = pile{{"bone black",1.2},{"bone brown",1.5},{"burnt sienna",0.4}}
STEPS = {}
for i=0,NSTEP-1 do
  local t0, t1 = i/NSTEP, (i+1)/NSTEP
  local x0,y0,nx0,ny0,w0 = PATH(t0); local x1,y1,nx1,ny1,w1 = PATH(t1)
  local q = {{x0+nx0*w0,y0+ny0*w0},{x0-nx0*w0,y0-ny0*w0},{x1-nx1*w1,y1-ny1*w1},{x1+nx1*w1,y1+ny1*w1}}
  STEPS[#STEPS+1] = q
  local p = (i < 9) and warmT or ((i < 18) and midT or coolT)
  work(poly(q), {hand="body", tool="filbert 5", pile=p, coverage=2.8, fill=true, clip=true, angle=math.atan(ny0,nx0), length={10,40}})
  local r = ribbon({{q[3][1],q[3][2]},{q[4][1],q[4][2]}}, 3 + i*0.18)
  work(r, {hand="body", tool="filbert 2", pile=riser, coverage=3, fill=true, clip=true, angle=math.atan(ny1,nx1), length={8,30}})
end
-- top landing
work(LAND, {hand="body", tool="filbert 6", pile=warmT, coverage=2.8, fill=true, clip=true, angle=0.2, length={20,60}})

--@ chunk 3
print(wait(2*24*60))
-- the stair's near side (lower-left edge) has depth: a bronze stringer dropping into the dark
local side = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.4}}
local sideL = pile{{"raw sienna",1.5},{"yellow ochre",0.6},{"lead white",0.6}}
local edgeL, edgeR = {}, {}
for k=0,40 do local x,y,nx,ny,w = PATH(k/40); edgeL[#edgeL+1] = {x+nx*w, y+ny*w}; edgeR[#edgeR+1] = {x-nx*w, y-ny*w} end
EDGEL, EDGER = edgeL, edgeR
local drop = {}; for _,p in ipairs(edgeL) do drop[#drop+1] = p end
for i=#edgeL,1,-1 do drop[#drop+1] = {edgeL[i][1]-8, edgeL[i][2]+38} end
SIDE = poly(drop) - STAIR
work(SIDE, {hand="body", tool="filbert 4", pile=side, coverage=3, fill=true, clip=true, angle=0.6, length={10,40}})
local b = brush{kind="round", width=2.5, point=0.5}
b:load(sideL, 0.9); b:stroke(edgeL, {pressure={0.8,0.5}, ramps={0,0}})
-- balusters along both edges, spaced by the golden angle's fractional walk; some shattered mid-flight
local bal = pile{{"raw sienna",1.2},{"burnt sienna",1},{"bone brown",0.6}}
local balL = pile{{"yellow ochre",1.5},{"lead white",1},{"Indian yellow",0.3}}
local balD = pile{{"bone brown",2},{"bone black",0.8}}
local function baluster(x, y, h, broken)
  local top = broken and h*rand(0.25,0.55) or h
  local m = poly({{x-3,y},{x+3,y},{x+2.4,y-top},{x-2.4,y-top}})
  work(m, {hand="detail", pile=bal, coverage=3, fill=true})
  local s = brush{kind="round", width=1.5, point=0.6}
  s:load(balL, 0.9); s:stroke({{x-1.6,y-1},{x-1.6,y-top+1}}, {pressure={0.7,0.5}})
  s:load(balD, 0.9); s:stroke({{x+1.8,y-1},{x+1.8,y-top+1}}, {pressure={0.7,0.5}})
  if not broken then work(ellipse(x, y-top, 4, 2.4), {hand="detail", pile=balL, coverage=3, fill=true}) end
end
RAILL, RAILR = {}, {}
local u = 0
for k=1,70 do
  u = (u + 0.381966) % 1
  local t = (k-1)/70 + u*0.012
  for _,side in ipairs({1,-1}) do
    local x,y,nx,ny,w = PATH(t)
    local px, py = x+side*nx*w*0.97, y+side*ny*w*0.97
    local h = 30 + t*16
    local broken = (t > 0.36 and t < 0.52 and side == 1 and rand(0,1) < 0.7) or (t > 0.55 and t < 0.62 and side == -1)
    baluster(px, py, h, broken)
  end
end
-- handrails on top of the balusters (broken where they are)
local rl = brush{kind="round", width=3.5, point=0.4}
for _,seg in ipairs({{0,0.36,1},{0.52,1,1},{0,0.55,-1},{0.62,1,-1}}) do
  local pts = {}
  for k=0,20 do local t = lerp(seg[1],seg[2],k/20); local x,y,nx,ny,w = PATH(t); local s = seg[3]; pts[#pts+1] = {x+s*nx*w*0.97, y+s*ny*w*0.97 - (30+t*16)} end
  rl:load(bal, 1.0); rl:stroke(pts, {pressure={0.9,0.9}, ramps={0,0}})
  rl:load(balL, 0.6); rl:stroke(pts, {pressure={0.4,0.4}, ramps={0,0}})
end

--@ chunk 4
-- the Commando holding the top of the stair, cannon braced down the flight
local aD = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.3}}
local aWarm = pile{{"raw sienna",1},{"lead white",1.2},{"bone black",0.3},{"yellow ochre",0.3}}
local aCold = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4}}
local tab = pile{{"red earth",1},{"vermilion",0.6},{"bone black",0.5}}
local function part(pts, p, a) local m = poly(pts, true); work(m, {hand="body", tool="filbert 2", pile=p, coverage=3.5, fill=true, clip=true, angle=a, length={4,12}, load=1.0}); return m end
CM = {}
CM.bleg = part({{204,132},{218,138},{198,166},{186,192},{176,194},{186,166}}, aD, 2.0)
CM.fleg = part({{222,134},{236,136},{254,160},{256,190},{246,192},{242,164},{226,148}}, aD, 1.2)
CM.torso = part({{196,94},{232,90},{240,112},{236,140},{204,144},{196,118}}, aD, 1.6)
CM.tab = part({{204,134},{236,132},{244,168},{224,172},{206,168},{200,150}}, tab, 1.5)
CM.pl = part({{186,96},{200,88},{208,98},{202,110},{188,110}}, aD, 0.3)
CM.pr = part({{226,92},{240,86},{250,96},{246,108},{232,106}}, aD, 0.3)
CM.head = part({{208,70},{220,66},{230,74},{230,86},{220,92},{210,88},{206,78}}, aD, 1.5)
CM.arm = part({{232,104},{246,104},{252,124},{240,130}}, aD, 1.2)
CM.gun = part({{222,118},{262,126},{300,140},{304,152},{296,156},{258,142},{220,134}}, aD, 0.35)
CM.pack = part({{190,96},{180,104},{178,128},{194,134},{198,112}}, aD, 1.6)
CMDM = CM.bleg; for k,m in pairs(CM) do CMDM = CMDM + m end

--@ chunk 5
-- the Wardens climbing: big faceted bronze masses, dark, lit later on their sides
local wd = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.7}}
local function part(pts, p, a, tool) local m = poly(pts); work(m, {hand="body", tool=tool or "filbert 3", pile=p, coverage=3.5, fill=true, clip=true, angle=a, length={6,18}, load=1.0}); return m end
W1 = part({{380,392},{390,322},{408,278},{444,262},{480,280},{490,332},{478,394}}, wd, 1.5, "filbert 4")
  + part({{396,284},{410,262},{432,256},{432,280},{414,294}}, wd, 1.2)
  + part({{412,300},{372,282},{344,262},{328,248},{336,242},{372,264},{416,286}}, wd, 2.5)
W2 = part({{604,452},{611,398},{630,368},{660,362},{680,382},{684,452}}, wd, 1.5)
  + part({{622,372},{630,356},{648,352},{648,370}}, wd, 1.2)
  + part({{618,396},{590,384},{570,372},{574,366},{596,374},{622,386}}, wd, 2.6)
W3 = part({{768,502},{776,452},{794,426},{820,420},{836,442},{840,502}}, wd, 1.5)
  + part({{786,430},{794,414},{810,410},{810,428}}, wd, 1.2)
WARD = W1 + W2 + W3
-- the smaller things: pale, cold, lumpy, many-lobed, climbing out of the fold
local pv = pile{{"lead white",2},{"ultramarine ash",0.7},{"cobalt violet",0.3},{"bone black",0.1}}
local things = {{548,448},{582,476},{700,474},{724,500},{866,522},{886,472},{930,500},{742,440},{520,420},{860,440}}
THINGS = nil
for i,c in ipairs(things) do
  local m = ellipse(c[1],c[2],11,8) + ellipse(c[1]+8,c[2]-6,8,7) + ellipse(c[1]-7,c[2]+3,7,6) + ellipse(c[1]+3,c[2]+7,6,4)
  THINGS = THINGS and (THINGS + m) or m
end
work(THINGS - WARD, {hand="body", tool="filbert 2", pile=pv, coverage=3.5, fill=true, clip=true, angle=0.5, length={4,10}, load=1.0})

--@ chunk 6
print(wait(2*24*60))
local wHalf = pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",0.6}}
local wLit = pile{{"yellow ochre",2},{"lead white",1.2},{"raw sienna",0.6}}
local cRim = pile{{"lead white",2},{"cobalt violet",0.5},{"ultramarine ash",0.5}}
local function facet(pts, p, a, clip) work(poly(pts) * clip, {hand="body", tool={kind="filbert",width=2.5,point=0.4}, pile=p, coverage=3, fill=true, clip=clip, angle=a, length={4,12}, load=1.0, pressure={0.5,0.9}}) end
local function ln(pts, p, w, pr) local b = brush{kind="round", width=w, point=0.6}; b:load(p, 1.0); b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.05,0.3}}) end
-- Warden 1: lamp-lit planes on the upper left, a cold rim from the fold on the lower right
facet({{390,322},{408,278},{430,268},{424,330},{404,390},{380,392}}, wHalf, 1.6, W1)
facet({{408,278},{444,262},{460,270},{430,290}}, wLit, 0.4, W1)
facet({{396,284},{410,262},{432,256},{420,276}}, wLit, 0.8, W1)
facet({{372,264},{344,262},{328,248},{336,242},{372,262}}, wLit, 2.5, W1)
ln({{480,282},{490,332},{478,394}}, cRim, 2.2, {0.5,0.9})
ln({{430,268},{426,330},{410,390}}, pile{{"bone black",1},{"bone brown",1}}, 2.5, {0.6,0.4})
-- Warden 2, 3: the same, smaller
facet({{611,398},{630,368},{644,364},{638,410},{624,452},{604,452}}, wHalf, 1.6, W2)
facet({{630,368},{660,362},{668,370},{642,378}}, wLit, 0.4, W2)
facet({{596,374},{570,372},{574,366},{598,370}}, wLit, 2.6, W2)
ln({{680,384},{684,452}}, cRim, 2, {0.5,0.9})
facet({{776,452},{794,426},{806,424},{800,462},{790,502},{768,502}}, wHalf, 1.6, W3)
facet({{794,426},{820,420},{826,426},{804,432}}, wLit, 0.4, W3)
ln({{836,442},{840,502}}, cRim, 2, {0.6,0.9})
-- the Commando: warm on the planes turned to the lamps, a cold edge toward the fight
local aWarm = pile{{"raw sienna",1},{"lead white",1.2},{"bone black",0.3},{"yellow ochre",0.3}}
local aMid = pile{{"bone black",1},{"ultramarine ash",1.2},{"lead white",0.5}}
local aCold = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4}}
facet({{196,94},{214,92},{212,126},{200,130},{196,112}}, aMid, 1.6, CM.torso)
facet({{186,96},{200,88},{206,96},{192,102}}, aWarm, 0.3, CM.pl)
facet({{226,92},{240,86},{246,94},{232,98}}, aWarm, 0.3, CM.pr)
facet({{208,70},{220,66},{224,72},{212,80}}, aWarm, 0.5, CM.head)
facet({{180,104},{190,98},{192,120},{182,124}}, aMid, 1.6, CM.pack)
facet({{204,132},{212,136},{196,166},{188,190},{182,190},{190,164}}, aMid, 2.0, CM.bleg)
facet({{222,134},{232,136},{248,160},{244,164},{228,148}}, aMid, 1.2, CM.fleg)
ln({{230,74},{230,86},{220,92}}, aCold, 1.6, {0.7,0.3})
ln({{240,112},{236,140}}, aCold, 1.6, {0.7,0.3})
ln({{250,96},{246,108}}, aCold, 1.4, {0.7,0.3})
ln({{256,160},{256,190}}, aCold, 1.6, {0.6,0.3})
ln({{262,126},{300,140}}, aWarm, 1.6, {0.6,0.6})
ln({{258,142},{296,156}}, aCold, 1.4, {0.6,0.6})
ln({{220,82},{231,81}}, pile{{"bone black",1}}, 1.6, {0.8,0.8})
-- the small things: dark-violet undersides and many thin legs on the steps
local vd = pile{{"ultramarine blue",1},{"cobalt violet",1},{"bone black",1}}
for _,c in ipairs({{548,448},{582,476},{700,474},{724,500},{866,522},{886,472},{930,500},{742,440},{520,420},{860,440}}) do
  ln({{c[1]-10,c[2]+4},{c[1],c[2]+9},{c[1]+10,c[2]+5}}, vd, 2.2, {0.8,0.4})
  for k=1,4 do local a = 0.6 + k*0.55; ln({{c[1]+math.cos(a)*6, c[2]+5},{c[1]+math.cos(a)*16, c[2]+12+rand(-2,3)}}, vd, 1.1, {0.6,0.1}) end
end

--@ chunk 7
print(wait(24*60))
-- the fold at the stair's foot: a luminous cold violet tear, seeping up the lower steps
local f1 = pile{{"cobalt violet",1.5},{"ultramarine blue",1},{"lead white",0.8}}
local f2 = pile{{"lead white",2},{"cobalt violet",1},{"ultramarine ash",0.4}}
local f3 = pile{{"zinc white",2},{"lead white",1},{"cobalt violet",0.3}}
FOLD = ellipse(930,500,150,70):roughen(18,50,5)
work(FOLD - THINGS, {hand="body", tool="filbert 6", pile=f1, coverage=3, fill=true, clip=-THINGS, angle=-0.4, length={14,40}, load=1.0})
work(ellipse(950,505,90,34):roughen(12,40,6) - THINGS, {hand="body", tool="filbert 4", pile=f2, coverage=3, fill=true, clip=-THINGS, angle=-0.4, length={10,30}, load=1.0})
work(ellipse(965,508,40,12):roughen(6,20,7) - THINGS, {hand="body", tool="filbert 3", pile=f3, coverage=3, fill=true, clip=-THINGS, angle=-0.4, length={6,20}, load=1.0})
-- cold seeping up the lower steps
local seep = pile{{"cobalt violet",1},{"ultramarine ash",1},{"lead white",1}, medium=0.4}
local up = (STAIR * ellipse(820,470,240,110):roughen(14,60,8)) - WARD - THINGS
work(up, {hand="scumble", tool="filbert 5", pile=seep, coverage=1.0, clip=-(WARD+THINGS), angle=0.2, load=0.4})

--@ chunk 8
print(wait(2*24*60))
local coolT = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"cobalt violet",0.5},{"ultramarine ash",0.4},{"lead white",0.2}}
local coolT2 = pile{{"bone brown",1.2},{"cobalt violet",0.7},{"ultramarine blue",0.4},{"lead white",0.25}}
local riser = pile{{"bone black",1.2},{"bone brown",1.5},{"cobalt violet",0.3}}
local keep = -(WARD:grow(1) + THINGS:grow(1))
for i=13,#STEPS do
  local q = STEPS[i]
  local p = (i < 20) and coolT or coolT2
  work(poly(q) * keep, {hand="body", tool="filbert 5", pile=p, coverage=3.2, fill=true, clip=keep, angle=0.3, length={10,40}, load=1.0})
  work(ribbon({{q[3][1],q[3][2]},{q[4][1],q[4][2]}}, 3 + i*0.18) * keep, {hand="body", tool="filbert 2", pile=riser, coverage=3, fill=true, clip=keep, angle=1.2, length={8,30}})
end
-- the dark hall beyond the stair repainted where the pale went over it
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local outside = ellipse(800,440,280,140) - STAIR - FOLD - SIDE
work(outside * rect(560,300,440,263) * keep, {hand="body", tool="filbert 6", pile=hallD, coverage=3, fill=true, clip=keep, angle=0.4, length={14,40}})

--@ chunk 9
print(wait(2*24*60))
local keep = -(WARD:grow(1) + THINGS:grow(1))
local riser = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.3}}
local nose = pile{{"lead white",1},{"raw sienna",0.6},{"cobalt violet",0.4}}
for i=12,#STEPS do
  local q = STEPS[i]
  local b = brush{kind="filbert", width=3 + i*0.12, point=0.3}
  b:load(riser, 1.0); b:stroke({q[3], q[4]}, {pressure={0.9,0.9}, ramps={0.02,0.02}, clip=keep})
  local h = brush{kind="round", width=1.5, point=0.5}
  h:load(nose, 0.8); h:stroke({{q[3][1]-2,q[3][2]-3},{q[4][1]-2,q[4][2]-3}}, {pressure={0.5,0.5}, ramps={0.05,0.05}, clip=keep})
end
local bal = pile{{"raw sienna",1.2},{"burnt sienna",1},{"bone brown",0.6}}
local balL = pile{{"yellow ochre",1.5},{"lead white",1},{"Indian yellow",0.3}}
local balV = pile{{"lead white",1},{"cobalt violet",0.7},{"ultramarine ash",0.5}}
local function baluster(x, y, h, broken, t)
  local top = broken and h*rand(0.25,0.55) or h
  local m = poly({{x-3,y},{x+3,y},{x+2.4,y-top},{x-2.4,y-top}})
  work(m * keep, {hand="detail", pile=bal, coverage=3, fill=true})
  local s = brush{kind="round", width=1.5, point=0.6}
  s:load(balL, 0.9); s:stroke({{x-1.6,y-1},{x-1.6,y-top+1}}, {pressure={0.7,0.5}, clip=keep})
  if t > 0.7 then s:load(balV, 0.9); s:stroke({{x+1.8,y-1},{x+1.8,y-top+1}}, {pressure={0.7,0.5}, clip=keep}) end
end
local u = 0
for k=1,70 do
  u = (u + 0.381966) % 1
  local t = (k-1)/70 + u*0.012
  if t > 0.42 then
    local x,y,nx,ny,w = PATH(t)
    local px, py = x+nx*w*0.97, y+ny*w*0.97
    baluster(px, py, 30 + t*16, (t < 0.52 and rand(0,1) < 0.7) or (t > 0.8 and rand(0,1) < 0.4), t)
  end
end

--@ chunk 10
print(wait(24*60))
local aD = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.4}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.6}}
local wd = pile{{"bone black",1.4},{"bone brown",1.6},{"burnt sienna",0.6}}
local function P(pts, p, a, t) local m = poly(pts, true); work(m, {hand="body", tool=t or "filbert 3", pile=p, coverage=3.6, fill=true, clip=true, angle=a, length={5,16}, load=1.0}); return m end
-- the Commando, larger: braced wide at the head of the stair, leaning into the recoil, cannon down the flight
C2 = {}
C2.bleg = P({{196,150},{214,156},{196,192},{176,226},{162,228},{176,192}}, aD, 2.1)
C2.bfoot = P({{150,222},{176,220},{180,232},{146,234}}, aD, 0)
C2.fleg = P({{226,150},{246,148},{270,186},{282,222},{268,226},{256,194},{232,170}}, aD, 1.1)
C2.ffoot = P({{262,218},{288,216},{296,228},{266,230}}, aD, 0)
C2.pack = P({{176,78},{158,88},{154,128},{176,138},{184,104}}, aD, 1.6)
C2.torso = P({{180,74},{230,66},{246,96},{240,140},{196,152},{180,120}}, aD, 1.7)
C2.tab = P({{196,138},{240,134},{254,186},{226,192},{200,186},{190,160}}, tab, 1.4)
C2.pl = P({{168,78},{186,64},{200,76},{192,96},{172,96}}, aD, 0.3)
C2.pr = P({{220,68},{240,58},{256,72},{250,92},{230,88}}, aD, 0.3)
C2.head = P({{196,36},{214,30},{230,40},{232,56},{222,66},{204,64},{194,52}}, aD, 1.5)
C2.arm = P({{236,90},{256,92},{262,124},{246,130}}, aD, 1.3)
C2.gun = P({{212,116},{270,128},{318,150},{330,164},{320,172},{266,152},{208,140}}, aD, 0.45)
CMDM = C2.bleg; for k,m in pairs(C2) do CMDM = CMDM + m end
-- Wardens remade: hunched hulks, hump high, head thrust forward and down, a long arm reaching up the flight
W1 = P({{372,398},{378,330},{394,286},{430,262},{470,266},{496,300},{500,352},{488,400}}, wd, 1.5, "filbert 4")
   + P({{388,300},{370,280},{366,262},{384,256},{404,270}}, wd, 1.0)
   + P({{420,290},{392,280},{360,262},{332,248},{318,236},{326,230},{350,240},{392,262},{430,272}}, wd, 2.6)
W2 = P({{598,456},{602,404},{616,376},{646,362},{676,368},{692,402},{690,456}}, wd, 1.5)
   + P({{612,380},{600,366},{604,354},{618,354},{624,368}}, wd, 1.0)
   + P({{626,388},{600,378},{574,368},{562,360},{568,356},{590,362},{630,374}}, wd, 2.6)
W3 = P({{762,508},{766,462},{780,438},{806,428},{830,434},{844,462},{844,508}}, wd, 1.5)
   + P({{776,442},{766,432},{770,422},{782,422},{788,434}}, wd, 1.0)
WARD = W1 + W2 + W3

--@ chunk 11
print(wait(2*24*60))
function cen(m, x0, y0, x1, y1)
  local sx,sy,n = 0,0,0
  for x=x0,x1,2 do for y=y0,y1,2 do if m:at(x,y) > 0.5 then sx=sx+x; sy=sy+y; n=n+1 end end end
  return sx/n, sy/n, math.sqrt(n*4/math.pi)
end
function side(cx, cy, r, dx, dy, k)
  local l = math.sqrt(dx*dx+dy*dy); dx, dy = dx/l, dy/l
  return mask(function(x,y) return smoothstep(k-0.12, k+0.12, ((x-cx)*dx+(y-cy)*dy)/r) end)
end
local aWarm = pile{{"raw sienna",1},{"lead white",1},{"bone black",0.25},{"yellow ochre",0.4}}
local aWarm2 = pile{{"yellow ochre",1.2},{"lead white",1.5},{"raw sienna",0.5}}
local aMid = pile{{"bone black",1.2},{"ultramarine ash",1},{"burnt sienna",0.3},{"lead white",0.3}}
local aCold = pile{{"lead white",2},{"zinc white",1},{"cobalt violet",0.3},{"cerulean blue",0.3}}
local tabL = pile{{"vermilion",1},{"cadmium red",0.4},{"lead white",0.3}}
local ang = {bleg=2.1,fleg=1.1,pack=1.6,torso=1.7,tab=1.4,pl=0.3,pr=0.3,head=1.5,arm=1.3,gun=0.45,bfoot=0,ffoot=0}
for k,m in pairs(C2) do
  local cx, cy, r = cen(m, 140, 25, 335, 240)
  local a = ang[k]
  local t = {kind="filbert", width=2.4, point=0.4}
  local w1 = m * side(cx,cy,r,-1,-0.8,-0.1)
  local w2 = m * side(cx,cy,r,-1,-0.8,0.45)
  local cr = m * side(cx,cy,r,1,0.6,0.6)
  if k == "tab" then
    work(w1, {hand="body", tool=t, pile=tabL, angle=a, coverage=2.5, fill=true, clip=m, length={4,12}, load=1.0, pressure={0.5,0.9}})
  else
    work(m * side(cx,cy,r,-1,-0.8,-0.5) - w1, {hand="body", tool=t, pile=aMid, angle=a, coverage=2.5, fill=true, clip=m, length={4,12}, load=1.0, pressure={0.5,0.9}})
    work(w1, {hand="body", tool=t, pile=aWarm, angle=a, coverage=2.6, fill=true, clip=m, length={4,12}, load=1.0, pressure={0.5,0.9}})
    work(w2, {hand="body", tool=t, pile=aWarm2, angle=a, coverage=2.4, fill=true, clip=m, length={3,10}, load=1.0, pressure={0.5,0.9}})
    work(cr, {hand="body", tool=t, pile=aCold, angle=a, coverage=2.2, clip=m, length={3,10}, load=1.0, pressure={0.4,0.8}})
  end
end

--@ chunk 12
print(wait(2*24*60))
local aD = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.4}}
local aD2 = pile{{"bone black",1.5},{"ultramarine blue",0.8},{"burnt sienna",0.5},{"lead white",0.15}}
local warm = pile{{"burnt sienna",0.6},{"yellow ochre",1},{"lead white",1.2}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.3}}
local cold = pile{{"lead white",2},{"zinc white",1},{"cobalt violet",0.35},{"cerulean blue",0.25}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.6}}
local tabL = pile{{"vermilion",1},{"cadmium red",0.4},{"lead white",0.2}}
local ang = {bleg=2.1,fleg=1.1,pack=1.6,torso=1.7,tab=1.4,pl=0.3,pr=0.3,head=1.5,arm=1.3,gun=0.45,bfoot=0,ffoot=0}
local order = {"pack","bleg","bfoot","fleg","ffoot","torso","tab","pl","pr","head","arm","gun"}
for _,k in ipairs(order) do
  local m = C2[k]
  local cx, cy, r = cen(m, 140, 25, 335, 240)
  local a = ang[k]
  local t = {kind="filbert", width=2.4, point=0.4}
  local function an(x,y) return a + 0.25*math.sin(x*0.12+y*0.09) end
  local lit = m * side(cx,cy,r,-1,-0.8,0.5)
  local hot = m * side(cx,cy,r,-1,-0.8,0.78)
  local rim = m * side(cx,cy,r,1,0.6,0.72)
  if k == "tab" then
    work(m - lit, {hand="body", tool=t, pile=tab, angle=an, coverage=3.2, fill=true, clip=m, length={4,12}, load=1.0})
    work(lit, {hand="body", tool=t, pile=tabL, angle=an, coverage=2.6, fill=true, clip=m, length={4,12}, load=1.0, pressure={0.5,0.9}})
  else
    work(m - lit:grow(2), {hand="body", tool=t, pile=(k=="torso" or k=="gun") and aD or aD2, angle=an, coverage=3.4, fill=true, clip=m, length={4,14}, load=1.0})
    work(lit - hot, {hand="body", tool=t, pile=warm, angle=an, coverage=2.6, fill=true, clip=m, length={3,10}, load=1.0, pressure={0.5,0.9}})
    work(hot, {hand="body", tool=t, pile=warmH, angle=an, coverage=2.4, fill=true, clip=m, length={3,8}, load=1.0, pressure={0.5,0.9}})
    work(rim, {hand="body", tool={kind="filbert", width=1.8, point=0.5}, pile=cold, angle=an, coverage=2, clip=m, length={3,8}, load=1.0, pressure={0.4,0.8}})
  end
end

--@ chunk 13
print(wait(6*24*60))
print(drying(200,100), drying(290,145))
local aD = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.4}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.6}}
local ang = {bleg=2.1,fleg=1.1,pack=1.6,torso=1.7,tab=1.4,pl=0.3,pr=0.3,head=1.5,arm=1.3,gun=0.45,bfoot=0,ffoot=0}
local order = {"pack","bleg","bfoot","fleg","ffoot","torso","tab","pl","pr","head","arm","gun"}
for _,k in ipairs(order) do
  local m = C2[k]
  local a = ang[k]
  work(m:shrink(0.5), {hand="body", tool="filbert 3", pile=(k=="tab") and tab or aD, angle=function(x,y) return a + 0.2*math.sin(x*0.12+y*0.09) end, coverage=4, fill=true, clip=true, length={5,14}, load=1.0})
end

--@ chunk 14
print(wait(5*24*60))
local warm = pile{{"burnt sienna",0.5},{"yellow ochre",1},{"lead white",1.3}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.3}}
local mid = pile{{"bone black",1},{"ultramarine ash",1},{"burnt sienna",0.4},{"lead white",0.35}}
local cold = pile{{"lead white",2},{"zinc white",1},{"cobalt violet",0.35},{"cerulean blue",0.25}}
local seam = pile{{"bone black",2},{"ultramarine blue",0.5}}
local crossp = pile{{"lead white",2},{"ultramarine ash",0.6}}
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.6}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.08,0.4}, clip=clip})
end
local C = CMDM
-- helmet: lit crown and brow, cold cheek, visor slit
ST({{200,44},{210,34},{222,33}}, warm, 5, {0.8,0.4}, 1, C); ST({{204,40},{214,35}}, warmH, 3, {0.8,0.2}, 1, C)
ST({{196,52},{198,60}}, mid, 4, {0.7,0.3}, 1, C)
ST({{230,48},{232,58},{224,66}}, cold, 2.4, {0.4,0.8}, 1, C)
ST({{210,50},{230,50}}, seam, 2.6, {0.9,0.9}, 1, C); ST({{212,47},{228,47}}, mid, 1.4, {0.5,0.5}, 0.7, C)
-- pauldrons
ST({{170,84},{180,70},{194,66}}, warm, 5, {0.9,0.4}, 1, C); ST({{174,78},{184,70}}, warmH, 3, {0.8,0.2}, 1, C)
ST({{176,92},{188,94},{196,88}}, seam, 2, {0.7,0.5}, 1, C)
ST({{224,66},{238,59},{250,64}}, warm, 4.5, {0.9,0.4}, 1, C); ST({{252,74},{252,88},{244,93}}, cold, 2.2, {0.4,0.8}, 1, C)
ST({{224,84},{238,90},{250,90}}, seam, 2, {0.7,0.5}, 1, C)
-- pack and back plate: lit upper-left edge
ST({{160,90},{156,108},{158,126}}, warm, 4, {0.8,0.3}, 1, C); ST({{176,80},{162,88}}, warmH, 2.5, {0.7,0.2}, 1, C)
ST({{176,96},{180,120},{178,136}}, seam, 2, {0.6,0.4}, 1, C)
-- breastplate: centre ridge, lames, cold right flank
ST({{184,80},{206,72},{226,70}}, warm, 4, {0.8,0.3}, 1, C)
ST({{212,76},{214,104},{212,130}}, mid, 3, {0.7,0.4}, 1, C); ST({{210,78},{211,104}}, warm, 1.6, {0.6,0.2}, 1, C)
ST({{186,112},{214,110},{240,104}}, seam, 2, {0.7,0.5}, 1, C); ST({{188,116},{212,114}}, warm, 1.6, {0.5,0.1}, 0.8, C)
ST({{190,128},{216,126},{238,120}}, seam, 2, {0.7,0.5}, 1, C)
ST({{244,98},{242,120},{238,138}}, cold, 2.4, {0.4,0.8}, 1, C)
-- arm and gauntlet on the grip
ST({{238,92},{254,94}}, warm, 3.5, {0.8,0.3}, 1, C); ST({{260,104},{262,122},{252,130}}, cold, 2, {0.4,0.8}, 1, C)
ST({{240,110},{256,112}}, seam, 1.8, {0.6,0.4}, 1, C)
-- cannon: warm top edge, cold underside, barrel bands, hot muzzle
ST({{214,118},{262,128},{300,142},{318,150}}, warm, 3, {0.7,0.7}, 1, C); ST({{230,121},{262,129}}, warmH, 1.8, {0.6,0.4}, 1, C)
ST({{214,140},{264,152},{316,170}}, cold, 2.2, {0.6,0.8}, 1, C)
ST({{262,128},{262,152}}, seam, 2.4, {0.8,0.8}, 1, C); ST({{292,138},{290,160}}, seam, 2.2, {0.8,0.8}, 1, C)
-- legs: lit thigh fronts, knee cops, greaves; cold back edges
ST({{198,156},{188,176},{178,198},{168,222}}, warm, 3.2, {0.8,0.3}, 1, C)
ST({{186,174},{196,170},{200,180}}, seam, 2, {0.7,0.5}, 1, C); ST({{190,172},{196,170}}, warmH, 2, {0.8,0.2}, 1, C)
ST({{212,160},{200,190},{186,222}}, cold, 1.8, {0.3,0.7}, 1, C)
ST({{232,156},{250,170},{266,192},{278,214}}, warm, 3, {0.7,0.3}, 1, C)
ST({{254,180},{264,178},{270,190}}, seam, 2, {0.7,0.5}, 1, C); ST({{260,180},{266,182}}, warmH, 2, {0.8,0.2}, 1, C)
ST({{246,150},{270,184},{284,220}}, cold, 2, {0.3,0.8}, 1, C)
ST({{150,224},{176,220}}, warm, 2.6, {0.7,0.3}, 1, C); ST({{264,218},{288,216}}, warm, 2.6, {0.7,0.3}, 1, C); ST({{290,218},{296,228}}, cold, 2, {0.5,0.8}, 1, C)
-- the cross on the tabard
ST({{222,142},{223,170},{224,186}}, crossp, 3.5, {0.9,0.8}, 1, C); ST({{206,158},{224,156},{242,154}}, crossp, 3.5, {0.9,0.8}, 1, C)

--@ chunk 15
-- clean the pale smear at his waist
local aD = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.4}}
work(ellipse(222,118,20,14) * C2.torso - ribbon({{214,118},{318,150}},5), {hand="body", tool="filbert 2", pile=aD, coverage=3.5, fill=true, clip=true, angle=1.6, length={4,10}, load=1.0})
work(ellipse(212,104,10,22) * C2.torso, {hand="body", tool="filbert 2", pile=aD, coverage=3, fill=true, clip=true, angle=1.6, length={4,10}, load=1.0})
-- Wardens: warm lamplit facets on the upper-left, deep core, cold violet rim from the fold below right
local wHalf = pile{{"raw sienna",1.6},{"burnt sienna",1},{"bone brown",0.6}}
local wLit = pile{{"yellow ochre",1.6},{"lead white",1.2},{"raw sienna",0.5}}
local wHot = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.4}}
local cRim = pile{{"lead white",2},{"cobalt violet",0.6},{"ultramarine ash",0.4}}
local core = pile{{"bone black",1.8},{"bone brown",1}}
local function F(pts, p, a, clip) work(poly(pts) * clip, {hand="body", tool={kind="filbert",width=2.6,point=0.4}, pile=p, coverage=3, fill=true, clip=clip, angle=a, length={4,14}, load=1.0, pressure={0.5,0.9}}) end
-- W1, halfway up and sparking
F({{378,330},{394,286},{416,272},{410,320},{398,372},{374,396}}, wHalf, 1.6, W1)
F({{394,286},{430,262},{452,262},{424,280},{416,272}}, wLit, 0.3, W1)
F({{430,262},{470,266},{482,280},{452,282}}, wHalf, 0.1, W1)
F({{366,262},{384,256},{396,266},{378,272}}, wLit, 0.6, W1)
F({{332,248},{318,236},{326,230},{360,244},{392,262},{384,268}}, wLit, 2.6, W1)
ST({{396,290},{382,330},{378,370}}, wHot, 2.2, {0.8,0.3}, 1, W1)
ST({{430,280},{424,330},{414,396}}, core, 3, {0.6,0.5}, 1, W1)
ST({{496,302},{500,350},{488,398}}, cRim, 2.4, {0.5,0.9}, 1, W1)
ST({{404,276},{430,264},{456,264}}, wHot, 1.8, {0.8,0.2}, 1, W1)
for i,y in ipairs({300,322,344,366}) do ST({{430,y},{458,y+4},{486,y+3}}, core, 1.6, {0.6,0.3}, 0.8, W1); ST({{430,y+3},{448,y+6}}, wLit, 1.2, {0.5,0.1}, 0.7, W1) end
-- W2
F({{602,404},{616,376},{632,366},{626,410},{618,452},{598,456}}, wHalf, 1.6, W2)
F({{616,376},{646,362},{664,364},{634,378}}, wLit, 0.3, W2)
F({{600,366},{604,354},{618,354},{612,366}}, wLit, 0.6, W2)
F({{568,356},{590,362},{626,376},{622,384},{596,372}}, wLit, 2.6, W2)
ST({{690,402},{690,454}}, cRim, 2.2, {0.6,0.9}, 1, W2)
ST({{632,378},{628,420},{620,454}}, core, 2.6, {0.6,0.5}, 1, W2)
-- W3, near the fold: lit more by violet than by lamps
F({{766,462},{780,438},{792,432},{788,470},{780,508},{762,508}}, wHalf, 1.6, W3)
F({{780,438},{806,428},{820,430},{796,440}}, wLit, 0.3, W3)
ST({{830,436},{844,464},{844,506}}, cRim, 2.6, {0.7,0.9}, 1, W3)
ST({{810,440},{816,480},{820,506}}, cRim, 1.6, {0.4,0.6}, 0.8, W3)

--@ chunk 16
local wd = pile{{"bone black",1.4},{"bone brown",1.6},{"burnt sienna",0.6}}
local wLit = pile{{"yellow ochre",1.6},{"lead white",1.2},{"raw sienna",0.5}}
local cRim = pile{{"lead white",2},{"cobalt violet",0.6},{"ultramarine ash",0.4}}
local bone = pile{{"lead white",2},{"yellow ochre",0.6}}
local function limb(pts, w0, w1)
  local ws = {}; for i=1,#pts do ws[i] = lerp(w0,w1,(i-1)/(#pts-1)) end
  local m = ribbon(pts, ws); work(m, {hand="body", tool="filbert 3", pile=wd, coverage=3.5, fill=true, clip=true, angle=1.4, length={5,14}, load=1.0}); return m
end
-- W1: legs braced on two steps, a second arm, a hooded head thrust toward him with a bone rosette
W1 = W1 + limb({{396,390},{388,416},{398,438}}, 22, 14) + limb({{470,392},{486,414},{480,436}}, 20, 13)
W1 = W1 + limb({{480,286},{506,262},{520,232},{512,214}}, 18, 10)
ST({{382,404},{386,432}}, wLit, 2.2, {0.7,0.3}); ST({{496,404},{486,434}}, cRim, 2, {0.5,0.8})
ST({{474,288},{500,262},{512,232}}, wLit, 2, {0.7,0.2}); ST({{522,236},{518,214}}, cRim, 1.6, {0.6,0.6})
work(ellipse(384,262,9,7), {hand="detail", pile=wd, coverage=3.5, fill=true})
for i=1,9 do local a = i*2.39996; local r = 1.6*math.sqrt(i); stipple(ellipse(452+math.cos(a)*r*2.2, 300+math.sin(a)*r*2.2, 1.3,1.3), {pile=bone, width=1.6, coverage=2}) end
-- W2
W2 = W2 + limb({{612,452},{606,472},{616,488}}, 18, 12) + limb({{680,452},{690,470},{686,486}}, 16, 11)
ST({{604,462},{608,484}}, wLit, 1.8, {0.7,0.3}); ST({{694,462},{688,484}}, cRim, 1.8, {0.5,0.8})
-- W3
W3 = W3 + limb({{772,506},{766,526},{776,540}}, 16, 10) + limb({{836,506},{846,524},{840,540}}, 15, 10)
ST({{850,512},{842,538}}, cRim, 1.8, {0.5,0.8})
WARD = W1 + W2 + W3

--@ chunk 17
print(wait(2*24*60))
-- the cable: from the muzzle arcing down over the stair to the dart in W1, flickering violet, bursting into plasma
CAB = {{322,160},{350,190},{372,224},{392,252},{410,270},{430,282}}
local hot = pile{{"zinc white",4},{"lemon chrome",0.1}}
local hot2 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.1}}
local viol = pile{{"cobalt violet",1.2},{"ultramarine blue",1},{"zinc white",1.2}}
local pviol = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",2}}
local dark = pile{{"bone black",2},{"ultramarine blue",0.5}}
local b = brush{kind="round", width=3, point=0.6}
b:load(dark, 1.0); b:stroke({{322,160},{340,178},{356,200}}, {pressure={0.9,0.7}, ramps={0,0.1}})
local sh = ribbon({{345,186},{360,206},{378,232},{396,256},{414,272},{432,282}}, {4,10,16,20,22,24}):roughen(3,12,4)
work(sh, {hand="body", tool="filbert 3", pile=viol, coverage=2.6, fill=true, clip=true, angle=0.9, length={4,12}, load=1.0})
local core = brush{kind="round", width=4, point=0.8}
core:load(hot, 1.0); core:stroke({{350,192},{366,214},{382,238},{400,260},{418,274},{432,282}}, {pressure={0.4,0.9}, swell={0.6,1.2,0.8,1.3,1.0}, ramps={0.1,0.1}})
local fl = brush{kind="round", width=3, point=0.9}
local function burst(cx, cy, r, n, p1, p2)
  for k=1,n do local a = rand(0,2*math.pi); local L = r*rand(0.5,1.4); local bend = rand(-0.4,0.4)
    fl:load(p1, 0.9); fl:stroke({{cx,cy},{cx+math.cos(a)*L*0.5,cy+math.sin(a)*L*0.5},{cx+math.cos(a+bend)*L,cy+math.sin(a+bend)*L}}, {pressure={0.9,0}, ramps={0.05,0.7}}) end
  for k=1,math.floor(n*0.7) do local a = rand(0,2*math.pi); local L = r*rand(0.3,0.8)
    fl:load(p2, 1.0); fl:stroke({{cx,cy},{cx+math.cos(a)*L,cy+math.sin(a)*L}}, {pressure={1,0}, ramps={0.05,0.6}}) end
  stipple(ellipse(cx,cy,r*0.3,r*0.25), {pile=hot, width=2.5, coverage=4})
end
for _,p in ipairs({{366,214,10},{392,252,13}}) do burst(p[1],p[2],p[3],12,pviol,hot) end
-- three impact blooms: the dart in W1, one on W2's shoulder, one among the things by the fold
BLOOMS = {{438,284,34},{640,372,26},{760,462,24}}
for _,c in ipairs(BLOOMS) do
  work(ellipse(c[1],c[2],c[3]*0.55,c[3]*0.45):roughen(3,10,c[1]), {hand="body", tool="filbert 3", pile=hot2, coverage=3, fill=true, clip=true, angle=0, length={4,10}, load=1.0})
  burst(c[1], c[2], c[3]*1.6, 22, pviol, hot)
end
-- W1 already sparking: jagged branches crawling over its hide
local sp = brush{kind="rigger", width=1.6, point=1}
local function zig(x0,y0,x1,y1,n,amp)
  local pts = {{x0,y0}}
  for i=1,n-1 do local t=i/n; pts[#pts+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)} end
  pts[#pts+1] = {x1,y1}; sp:load(hot, 1.0); sp:stroke(pts, {pressure={0.9,0.2}, ramps={0.02,0.2}}); return pts
end
local a = zig(438,284,400,330,6,6); zig(a[3][1],a[3][2],380,300,4,4)
local c = zig(440,288,470,360,7,6); zig(c[4][1],c[4][2],490,340,3,4)
zig(436,282,404,262,4,4); zig(442,286,478,272,4,4); zig(438,290,430,392,8,6)
zig(640,372,620,410,5,5); zig(642,370,670,388,4,4)
zig(760,462,790,470,4,4); zig(758,464,740,490,4,4); zig(762,460,770,440,3,3)

--@ chunk 18
print(wait(24*60))
local hot = pile{{"zinc white",4},{"lemon chrome",0.1}}
local viol = pile{{"cobalt violet",1.2},{"ultramarine blue",0.8},{"zinc white",1.5}}
local pviol = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",2}}
local glow = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.25},{"cobalt violet",0.2}, medium=0.5}
local keepC = -(CMDM:grow(2))
-- cold light thrown around each bloom: low-load glaze, blended outward
for _,c in ipairs(BLOOMS) do
  local h = ellipse(c[1], c[2]+6, c[3]*2.6, c[3]*1.6):soften(c[3]*0.8)
  work(h, {hand="glaze", pile=glow, load=0.22, pressure={0.08,0.2}, coverage=1.3, clip=true})
  blend(h:shrink(2), {clip=true})
end
-- the cable as a long whip: up out of the muzzle, a high arc over the flight, down onto the dart
WHIP = {{322,160},{352,150},{390,152},{424,170},{446,200},{452,236},{444,266},{438,284}}
local sh = ribbon(WHIP, {3,8,12,14,15,14,12,8}):roughen(3,12,9) * keepC
work(sh, {hand="body", tool="filbert 3", pile=viol, coverage=2.4, fill=true, clip=true, angle=0.3, length={4,12}, load=1.0})
local core = brush{kind="round", width=3.5, point=0.8}
core:load(hot, 1.0); core:stroke(WHIP, {pressure={0.4,0.9}, swell={0.7,1,1.3,0.8,1.2,1.4,1.0,1.2}, ramps={0.05,0.05}})
local fl = brush{kind="round", width=2.6, point=0.9}
for i=2,#WHIP-1 do
  local cx, cy = WHIP[i][1], WHIP[i][2]
  for k=1,8 do local a = rand(0,2*math.pi); local L = rand(6,16)+i
    fl:load((k%2==0) and hot or pviol, 0.9); fl:stroke({{cx,cy},{cx+math.cos(a)*L*0.5+rand(-2,2),cy+math.sin(a)*L*0.5+rand(-2,2)},{cx+math.cos(a)*L,cy+math.sin(a)*L}}, {pressure={0.9,0}, ramps={0.05,0.7}}) end
  stipple(ellipse(cx,cy,3+i*0.5,3+i*0.4), {pile=hot, width=2.5, coverage=3})
end
-- the blooms themselves, larger and whiter at heart
for _,c in ipairs(BLOOMS) do
  work(ellipse(c[1],c[2],c[3]*0.7,c[3]*0.55):roughen(4,12,c[2]), {hand="body", tool="filbert 3", pile=hot, coverage=3, fill=true, clip=true, angle=0, length={4,10}, load=1.0})
  for k=1,26 do local a = rand(0,2*math.pi); local L = c[3]*rand(1.0,2.2)
    fl:load((k%3==0) and pviol or hot, 1.0); fl:stroke({{c[1],c[2]},{c[1]+math.cos(a)*L*0.5,c[2]+math.sin(a)*L*0.4},{c[1]+math.cos(a+rand(-0.3,0.3))*L,c[2]+math.sin(a)*L*0.75}}, {pressure={1,0}, ramps={0.05,0.75}}) end
end

--@ chunk 19
print(wait(2*24*60))
local smokeW = pile{{"lead white",1.5},{"raw sienna",0.6},{"burnt sienna",0.3},{"bone brown",0.4}}
local smokeD = pile{{"bone brown",1.5},{"raw sienna",0.6},{"lead white",0.5},{"cobalt violet",0.2}}
local hot = pile{{"zinc white",4},{"lemon chrome",0.1}}
-- break the clouds' hard ellipses into billows: lumps of warm-lit and shadowed smoke along their edges
for bi,c in ipairs(BLOOMS) do
  local rx, ry = c[3]*2.6, c[3]*1.6
  for k=1,16 do
    local a = k/16*2*math.pi + rand(-0.15,0.15)
    local x, y = c[1] + math.cos(a)*rx*rand(0.8,1.05), c[2]+6 + math.sin(a)*ry*rand(0.8,1.05)
    local r = c[3]*rand(0.35,0.6)
    local p = (math.sin(a) < 0) and smokeW or smokeD
    work(ellipse(x, y, r, r*0.75):roughen(2,8,k+bi*20) - CMDM:grow(2), {hand="body", tool="filbert 3", pile=p, coverage=2.6, fill=true, clip=-CMDM:grow(2), angle=a+1.57, length={4,12}, load=0.9})
  end
end
-- dust and smoke rising in the lamplight above the flight
local dust = pile{{"lead white",1},{"raw sienna",1},{"burnt sienna",0.4}, medium=0.3}
for k=1,14 do
  local x, y = rand(330,720), rand(150,300)
  if CMDM:at(x,y) < 0.5 then
    work(ellipse(x, y, rand(14,30), rand(8,16)):roughen(3,10,k), {hand="scumble", tool="filbert 3", pile=dust, coverage=0.8, clip=-CMDM:grow(2), load=0.35})
  end
end
-- hot hearts of the blooms restated over the smoke
for _,c in ipairs(BLOOMS) do stipple(ellipse(c[1],c[2],c[3]*0.35,c[3]*0.28), {pile=hot, width=3, coverage=4}) end

--@ chunk 20
print(wait(3*24*60))
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local smk = pile{{"bone brown",1.6},{"bone black",0.7},{"burnt sienna",0.4},{"cobalt violet",0.2}}
local smk2 = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"raw sienna",0.4},{"bone black",0.3}}
local keep = -(CMDM:grow(2) + STAIR + SIDE)
-- dust patches over the hall gone
work(rect(440,120,330,190) * keep, {hand="body", tool="filbert 6", pile=hallD, coverage=3.4, fill=true, clip=keep, angle=0.4, length={14,40}, load=1.0})
-- the billow rings darkened into smoke: dark below, warm-touched on top
for bi,c in ipairs(BLOOMS) do
  local ring = ellipse(c[1], c[2]+6, c[3]*3.0, c[3]*2.0) - ellipse(c[1], c[2]+2, c[3]*1.2, c[3]*0.9)
  ring = ring:roughen(6,16,bi) - CMDM:grow(2)
  work(ring, {hand="body", tool="filbert 4", pile=smk, coverage=3, fill=true, clip=-CMDM:grow(2), angle=function(x,y) return math.atan(y-c[2], x-c[1]) + 1.57 end, length={6,16}, load=1.0})
  work(ring * above(function(x) return c[2] - c[3]*0.9 end), {hand="body", tool="filbert 3", pile=smk2, coverage=1.8, clip=ring, angle=0, length={5,12}, load=0.8})
end

--@ chunk 21
print(wait(3*24*60))
local wd = pile{{"bone black",1.4},{"bone brown",1.6},{"burnt sienna",0.6}}
local wHalf = pile{{"raw sienna",1.6},{"burnt sienna",1},{"bone brown",0.6}}
local wLit = pile{{"yellow ochre",1.6},{"lead white",1.2},{"raw sienna",0.5}}
local cRim = pile{{"lead white",2},{"cobalt violet",0.6},{"ultramarine ash",0.4}}
local hot = pile{{"zinc white",4},{"lemon chrome",0.1}}
local function P(pts, p, a) local m = poly(pts, true); work(m, {hand="body", tool="filbert 3", pile=p, coverage=3.6, fill=true, clip=true, angle=a, length={5,14}, load=1.0}); return m end
local function F(pts, p, a, clip) work(poly(pts) * clip, {hand="body", tool={kind="filbert",width=2.6,point=0.4}, pile=p, coverage=3, fill=true, clip=clip, angle=a, length={4,12}, load=1.0, pressure={0.5,0.9}}) end
-- W1's hump, hooded head and reaching arm rise out of the smoke toward him
local h1 = P({{380,330},{384,282},{404,250},{440,232},{478,238},{500,268},{502,320}}, wd, 1.5)
local hd1 = P({{392,262},{372,246},{362,232},{376,224},{398,236}}, wd, 1.0)
local ar1 = P({{410,262},{380,246},{352,228},{334,214},{340,208},{362,220},{400,240},{420,252}}, wd, 2.6)
F({{384,282},{404,250},{424,240},{414,290},{396,330},{380,330}}, wHalf, 1.6, h1)
F({{404,250},{440,232},{462,232},{430,250}}, wLit, 0.3, h1)
F({{372,246},{362,232},{376,224},{390,234}}, wLit, 0.6, hd1)
F({{352,228},{334,214},{340,208},{362,220},{390,236},{384,242}}, wLit, 2.6, ar1)
ST({{498,270},{502,320}}, cRim, 2.4, {0.5,0.9}); ST({{404,252},{386,282},{382,326}}, hot, 1.6, {0.6,0.2})
-- W2, W3: hump and head above their blooms
local h2 = P({{598,380},{604,352},{626,334},{654,330},{676,342},{688,376}}, wd, 1.5)
P({{610,350},{596,338},{600,328},{614,328},{620,340}}, wd, 1.0)
F({{604,352},{626,334},{640,332},{622,350},{612,378}}, wLit, 0.4, h2)
ST({{684,350},{690,378}}, cRim, 2.2, {0.5,0.9})
local h3 = P({{752,456},{756,432},{776,418},{804,414},{826,424},{840,456}}, wd, 1.5)
F({{756,432},{776,418},{790,416},{772,434},{762,456}}, wLit, 0.4, h3)
ST({{830,428},{842,456}}, cRim, 2.2, {0.5,0.9})
-- the cable whip restated over everything, bursting
local viol = pile{{"cobalt violet",1.2},{"ultramarine blue",0.8},{"zinc white",1.5}}
local sh = ribbon(WHIP, {3,8,12,14,15,14,12,8}):roughen(3,12,9) - CMDM:grow(2)
work(sh, {hand="body", tool="filbert 3", pile=viol, coverage=2.6, fill=true, clip=true, angle=0.3, length={4,12}, load=1.0})
local core = brush{kind="round", width=3.5, point=0.8}
core:load(hot, 1.0); core:stroke(WHIP, {pressure={0.4,0.9}, swell={0.7,1,1.3,0.8,1.2,1.4,1.0,1.2}, ramps={0.05,0.05}})

--@ chunk 22
print(wait(4*24*60))
local hotO = pile{{"lead white",2},{"zinc white",2},{"lemon chrome",0.08}}
local pv = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",2}}
local cyan = pile{{"lead white",2},{"cerulean blue",0.6},{"zinc white",1}}
-- the cable core, hot along its length, beads of plasma bursting out of it
local core = brush{kind="round", width=3.2, point=0.7}
core:load(hotO, 1.0); core:stroke(WHIP, {pressure={0.6,0.9}, ramps={0.03,0.03}})
local fl = brush{kind="round", width=2.4, point=0.9}
for i,pt in ipairs(WHIP) do
  if i > 2 then
    local r = 4 + i*1.2
    work(ellipse(pt[1],pt[2],r*0.6,r*0.5), {hand="detail", pile=hotO, coverage=4, fill=true})
    for k=1,7 do local a = rand(0,2*math.pi); local L = r*rand(1.2,2.4)
      fl:load((k%2==0) and pv or hotO, 1.0); fl:stroke({{pt[1],pt[2]},{pt[1]+math.cos(a)*L*0.5+rand(-2,2),pt[2]+math.sin(a)*L*0.5+rand(-2,2)},{pt[1]+math.cos(a)*L,pt[2]+math.sin(a)*L}}, {pressure={0.9,0}, ramps={0.05,0.7}})
    end
  end
end
-- three impact blooms in front of the Wardens' chests
BLOOMS2 = {{440,300,30},{640,388,24},{780,470,22}}
for _,c in ipairs(BLOOMS2) do
  work(ellipse(c[1],c[2],c[3]*0.75,c[3]*0.6):roughen(4,12,c[1]), {hand="body", tool="filbert 3", pile=hotO, coverage=4, fill=true, clip=true, angle=0, length={4,10}, load=1.0})
  for k=1,30 do
    local a = rand(0,2*math.pi); local L = c[3]*rand(1.0,2.6)
    fl:load((k%3==0) and pv or ((k%3==1) and hotO or cyan), 1.0)
    fl:stroke({{c[1]+math.cos(a)*c[3]*0.4,c[2]+math.sin(a)*c[3]*0.3},{c[1]+math.cos(a)*L*0.55,c[2]+math.sin(a)*L*0.45},{c[1]+math.cos(a+rand(-0.3,0.3))*L,c[2]+math.sin(a)*L*0.8}}, {pressure={1,0}, ramps={0.03,0.75}})
  end
end
-- the Warden halfway up already sparking: lightning crawling over its hide and down its legs
local sp = brush{kind="rigger", width=1.8, point=1}
local function zig(x0,y0,x1,y1,n,amp)
  local pts = {{x0,y0}}
  for i=1,n-1 do local t=i/n; pts[#pts+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)} end
  pts[#pts+1] = {x1,y1}; sp:load(hotO, 1.0); sp:stroke(pts, {pressure={1,0.3}, ramps={0.02,0.2}}); return pts
end
local a = zig(440,300,392,262,6,6); zig(a[3][1],a[3][2],346,222,5,5)
local b = zig(442,302,486,262,6,6); zig(b[4][1],b[4][2],500,300,3,4)
local c = zig(438,304,400,390,8,7); zig(c[5][1],c[5][2],388,430,4,4)
local d = zig(444,304,480,380,7,7); zig(d[5][1],d[5][2],486,430,4,4)
zig(640,388,612,350,5,5); zig(642,388,684,360,5,5); zig(640,390,620,470,6,5)
zig(780,470,760,440,4,4); zig(782,470,826,440,4,4)

--@ chunk 23
local warmT = pile{{"raw sienna",1.5},{"yellow ochre",0.8},{"burnt sienna",0.6},{"lead white",0.5}}
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local keep = -(CMDM:grow(2) + ribbon(WHIP, 18))
-- the tan smear on the upper steps painted out
work(ellipse(352,222,30,18) * STAIR * keep, {hand="body", tool="filbert 3", pile=warmT, coverage=3.5, fill=true, clip=keep, angle=0.9, length={5,14}, load=1.0})
-- lose the hard outer edges of the smoke into the hall and the stair
for bi,c in ipairs(BLOOMS) do
  local ring = ellipse(c[1], c[2]+6, c[3]*3.0, c[3]*2.0):roughen(6,16,bi)
  lose(ring - CMDM:grow(3), {pile=pile{{"bone brown",1.6},{"burnt sienna",0.5},{"bone black",0.4}}, where=1, tool="filbert 4", reach={4,20}, load=0.5, pressure={0.5,0.05}, every=1.6})
end
-- the small things: violet-dark undersides, cold spines, many legs
local vd = pile{{"ultramarine blue",1},{"cobalt violet",1},{"bone black",1.2}}
local cg = pile{{"lead white",1.5},{"cobalt violet",0.7},{"cerulean blue",0.3}}
for _,c in ipairs({{548,448},{582,476},{700,474},{724,500},{866,522},{886,472},{930,500},{742,440},{520,420},{860,440}}) do
  work(ellipse(c[1]+1,c[2]+3,11,5), {hand="detail", pile=vd, coverage=3.5, fill=true})
  for k=1,5 do local a = -2.6 + k*0.45; ST({{c[1]+math.cos(a)*6,c[2]+math.sin(a)*5},{c[1]+math.cos(a)*15,c[2]+math.sin(a)*12}}, cg, 1.4, {0.8,0.05}) end
  for k=1,6 do local a = 0.3 + k*0.42; ST({{c[1]+math.cos(a)*7, c[2]+4},{c[1]+math.cos(a)*15, c[2]+11},{c[1]+math.cos(a)*19, c[2]+17}}, vd, 1.2, {0.7,0.1}) end
end
-- lamps: warm on posts along the near balustrade and on the hall wall above the landing
local lamp = pile{{"lead white",3},{"Indian yellow",0.8},{"lemon chrome",0.1}}
local lglow = pile{{"Indian yellow",1},{"raw sienna",0.8},{"lead white",0.8}}
for _,l in ipairs({{100,60,1.2},{330,40,1.0},{175,182,0.9},{300,330,0.8}}) do
  work(ellipse(l[1],l[2],26*l[3],22*l[3]):soften(8) - CMDM:grow(3), {hand="body", tool="filbert 3", pile=lglow, coverage=1.6, angle=0, length={4,12}, edge="soft"})
  work(ellipse(l[1],l[2],5*l[3],7*l[3]), {hand="detail", pile=lamp, coverage=4, fill=true})
end

--@ chunk 24
print(wait(3*24*60))
local hallW = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.8}}
local landW = pile{{"raw sienna",1.5},{"yellow ochre",0.8},{"burnt sienna",0.6},{"lead white",0.5}}
local keep = -(CMDM:grow(2))
for _,l in ipairs({{100,60,1.2,hallW},{330,40,1.0,hallW},{175,182,0.9,landW},{300,330,0.8,landW}}) do
  work(ellipse(l[1],l[2],30*l[3],26*l[3]) * keep, {hand="body", tool="filbert 4", pile=l[4], coverage=3.6, fill=true, clip=keep, angle=0.3, length={6,18}, load=1.0})
end
work(ellipse(356,214,22,12) * keep - ribbon(WHIP,10), {hand="body", tool="filbert 3", pile=hallW, coverage=3.6, fill=true, clip=keep - ribbon(WHIP,10), angle=0.3, length={5,14}, load=1.0})

--@ chunk 25
print(wait(3*24*60))
local lamp = pile{{"lead white",3},{"Indian yellow",0.8},{"lemon chrome",0.1}}
local lw = pile{{"Indian yellow",1},{"lead white",1.2},{"Mars orange",0.2}}
local brz = pile{{"bone brown",2},{"burnt sienna",1}}
-- hanging lamps: a chain, a cage, a hot core and short rays of warm light
for _,l in ipairs({{100,70,1.1},{330,48,1.0},{560,110,0.8},{730,150,0.7}}) do
  local x, y, s = l[1], l[2], l[3]
  ST({{x,0},{x,y-10*s}}, brz, 1.4, {0.6,0.6})
  work(poly({{x-6*s,y-8*s},{x+6*s,y-8*s},{x+5*s,y+8*s},{x-5*s,y+8*s}}), {hand="detail", pile=brz, coverage=3.5, fill=true})
  work(ellipse(x,y,3.6*s,6*s), {hand="detail", pile=lamp, coverage=4, fill=true})
  for k=1,16 do local a = k/16*2*math.pi; local L = rand(14,30)*s
    ST({{x+math.cos(a)*7*s, y+math.sin(a)*8*s},{x+math.cos(a)*L, y+math.sin(a)*L*0.9}}, lw, 1.6, {0.6,0.0})
  end
end

--@ chunk 26
print(wait(2*24*60))
local wd = pile{{"bone black",1.4},{"bone brown",1.6},{"burnt sienna",0.6}}
local wHalf = pile{{"raw sienna",1.6},{"burnt sienna",1},{"bone brown",0.4}}
local wLit = pile{{"yellow ochre",1.6},{"lead white",1.4},{"raw sienna",0.4}}
local wHot = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.4}}
local cRim = pile{{"lead white",2},{"cobalt violet",0.6},{"ultramarine ash",0.4}}
local avoid = -(ellipse(440,300,30,24) + ellipse(640,388,24,20) + ellipse(780,470,22,18) + ribbon(WHIP, 8))
local function F(pts, p, a) local m = poly(pts) * avoid; work(m, {hand="body", tool={kind="filbert",width=2.8,point=0.4}, pile=p, coverage=3.4, fill=true, clip=avoid, angle=a, length={4,12}, load=1.0, pressure={0.5,0.9}}) end
-- W1: hump of overlapping bronze plates, head thrust at him, a claw reaching up the stair
F({{372,400},{376,340},{394,286},{420,262},{416,320},{404,400}}, wHalf, 1.65)
F({{394,286},{420,252},{452,236},{482,240},{456,256},{424,276}}, wLit, 0.4)
F({{420,262},{456,256},{482,248},{500,276},{470,280},{430,286}}, wHalf, 0.2)
F({{404,256},{378,240},{364,226},{376,218},{398,226},{418,242}}, wLit, 0.7)
F({{362,226},{352,232},{356,242},{372,246}}, wd, 0.7)
F({{404,252},{380,240},{352,224},{332,212},{326,204},{336,202},{358,214},{388,230},{414,242}}, wHot, 2.65)
F({{466,280},{498,282},{506,330},{490,398},{470,400},{486,330}}, wd, 1.6)
ST({{500,278},{506,330},{494,398}}, cRim, 2.6, {0.5,0.9})
ST({{394,288},{382,340},{378,396}}, wHot, 2, {0.8,0.2})
for i,y in ipairs({254,270,286}) do ST({{420+i*6,y},{460+i*4,y-4},{490,y+4}}, wd, 1.6, {0.6,0.4}) end
ST({{326,204},{318,198}}, wHot, 1.6, {0.8,0.2}); ST({{330,210},{320,210}}, wHot, 1.4, {0.8,0.2})
-- W2 and W3: a lit hump edge and a head each, enough to read
F({{600,382},{610,352},{632,334},{652,330},{630,350},{614,384}}, wLit, 0.5)
F({{612,350},{598,340},{602,330},{616,332}}, wLit, 0.7)
ST({{682,346},{692,380},{690,450}}, cRim, 2.2, {0.5,0.9})
F({{752,456},{758,432},{776,418},{794,414},{774,432},{764,458}}, wLit, 0.5)
ST({{828,428},{842,460},{844,506}}, cRim, 2.2, {0.5,0.9})

--@ chunk 27
print(wait(2*24*60))
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local midT = pile{{"raw sienna",1.2},{"burnt sienna",1},{"bone brown",0.8},{"lead white",0.3}}
local coolT = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"cobalt violet",0.5},{"ultramarine ash",0.4},{"lead white",0.2}}
local B1 = poly({{370,404},{374,340},{392,284},{418,250},{452,234},{484,238},{502,276},{508,330},{494,404}}) + poly({{418,244},{376,236},{350,222},{326,204},{336,198},{362,212},{400,232}}) + ribbon({{396,390},{388,416},{398,438}}, 24) + ribbon({{470,392},{486,414},{480,436}}, 22)
local B2 = poly({{596,458},{598,380},{610,350},{632,332},{656,328},{680,340},{694,380},{692,458}}) + poly({{612,352},{596,338},{602,326},{618,330}}) + ribbon({{612,452},{606,472},{616,488}}, 20) + ribbon({{680,452},{690,470},{686,486}}, 18)
local B3 = poly({{760,510},{754,456},{760,432},{778,416},{806,412},{830,424},{846,460},{846,510}}) + ribbon({{772,506},{766,526},{776,540}}, 18) + ribbon({{836,506},{846,524},{840,540}}, 17)
local keepFX = -(ellipse(440,300,32,26) + ellipse(640,388,26,22) + ellipse(780,470,24,20) + ribbon(WHIP, 9) + CMDM:grow(2))
for i,c in ipairs(BLOOMS) do
  local ring = ellipse(c[1], c[2]+6, c[3]*3.3, c[3]*2.3) - ({B1,B2,B3})[i]:grow(1)
  ring = ring * keepFX
  work(ring * STAIR, {hand="body", tool="filbert 4", pile=(i==1) and midT or coolT, coverage=3.6, fill=true, clip=keepFX * STAIR, angle=0.35, length={8,24}, load=1.0})
  work(ring - STAIR, {hand="body", tool="filbert 4", pile=hallD, coverage=3.6, fill=true, clip=keepFX - STAIR, angle=0.4, length={8,24}, load=1.0})
end
-- a little smoke left behind each, drifting up the stair in the lamplight
local smk = pile{{"bone brown",1.2},{"raw sienna",0.6},{"lead white",0.35}}
for _,c in ipairs(BLOOMS) do
  for k=1,5 do local x, y = c[1] - 20 - k*9, c[2] - 20 - k*7
    work(ellipse(x, y, 12+k*2, 6+k):roughen(3,8,k+c[1]) * keepFX, {hand="body", tool="filbert 3", pile=smk, coverage=1.1, clip=keepFX, angle=-0.6, length={6,16}, load=0.5})
  end
end

--@ chunk 28
print(wait(3*24*60))
local riser = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.3}}
local nose = pile{{"lead white",1},{"raw sienna",0.6},{"cobalt violet",0.4}}
local noseW = pile{{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.5}}
local B = -(WARD:grow(2) + ellipse(440,300,32,26) + ellipse(640,388,26,22) + ellipse(780,470,24,20) + ribbon(WHIP, 9) + THINGS:grow(2) + CMDM:grow(2))
for i=6,#STEPS do
  local q = STEPS[i]
  local b = brush{kind="filbert", width=2.4 + i*0.1, point=0.3}
  b:load(riser, 1.0); b:stroke({q[3], q[4]}, {pressure={0.9,0.9}, ramps={0.02,0.02}, clip=B * STAIR})
  local h = brush{kind="round", width=1.4, point=0.5}
  h:load((i < 12) and noseW or nose, 0.9); h:stroke({{q[3][1]-2,q[3][2]-3},{q[4][1]-2,q[4][2]-3}}, {pressure={0.5,0.5}, ramps={0.05,0.05}, clip=B * STAIR})
end
-- the fold, luminous again, and cold light licking up the lowest risers
local f2 = pile{{"lead white",2},{"cobalt violet",1},{"ultramarine ash",0.4}}
local f3 = pile{{"zinc white",2},{"lead white",1},{"cobalt violet",0.3}}
work(ellipse(955,505,70,26):roughen(10,30,6) * B, {hand="body", tool="filbert 4", pile=f2, coverage=3, fill=true, clip=B, angle=-0.4, length={8,24}, load=1.0})
work(ellipse(968,508,30,10):roughen(5,16,7) * B, {hand="body", tool="filbert 3", pile=f3, coverage=3.5, fill=true, clip=B, angle=-0.4, length={5,14}, load=1.0})
local cv = pile{{"lead white",1.5},{"cobalt violet",0.8},{"cerulean blue",0.2}}
for i=19,#STEPS do local q = STEPS[i]; ST({{q[4][1]-3,q[4][2]-4},{lerp(q[4][1],q[3][1],0.5)-3, lerp(q[4][2],q[3][2],0.5)-4}}, cv, 1.4, {0.7,0.05}, 0.9, B) end

--@ chunk 29
-- PASS: Wardens redesigned. First the old rough masses painted out to stair/hall, then crisp new silhouettes, all on dry paint
print(wait(3*24*60))
WD = {{450,332,1.05},{648,404,0.82},{800,474,0.68}}
function wpts(cx, cy, s, list) local r = {}; for i,p in ipairs(list) do r[i] = {cx + p[1]*s, cy + p[2]*s} end; return r end
CARA = {{-50,-8},{-44,-36},{-16,-60},{22,-62},{54,-44},{68,-12},{56,10},{-40,12}}
CREST = {{-48,-12},{-70,-24},{-90,-46},{-74,-46},{-58,-40},{-44,-34}}
FORE1 = {{-38,-30},{-62,-62},{-92,-84}}
FORE2 = {{-28,-14},{-70,-44},{-104,-54}}
LEGS = {{{-30,8},{-46,26},{-52,46}}, {{-12,10},{-20,30},{-30,48}}, {{8,10},{4,30},{-2,48}}, {{28,10},{36,28},{30,48}}, {{46,6},{62,24},{60,46}}, {{60,-2},{82,16},{86,40}}}
function wsil(cx, cy, s)
  local m = poly(wpts(cx,cy,s,CARA), true) + poly(wpts(cx,cy,s,CREST))
  m = m + ribbon(wpts(cx,cy,s,FORE1), {9*s,7*s,3*s}) + ribbon(wpts(cx,cy,s,FORE2), {8*s,6*s,2*s})
  for _,l in ipairs(LEGS) do m = m + ribbon(wpts(cx,cy,s,l), {6*s,4.5*s,2.5*s}) end
  return m
end
NEWW = wsil(WD[1][1],WD[1][2],WD[1][3]) + wsil(WD[2][1],WD[2][2],WD[2][3]) + wsil(WD[3][1],WD[3][2],WD[3][3])
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local midT = pile{{"raw sienna",1.2},{"burnt sienna",1},{"bone brown",0.8},{"lead white",0.3}}
local coolT = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"cobalt violet",0.5},{"ultramarine ash",0.4},{"lead white",0.2}}
local old = (WARD:grow(4) + ellipse(440,300,34,28) + ellipse(640,388,28,24) + ellipse(780,470,26,22)) - NEWW - CMDM:grow(2) - ribbon(WHIP, 8)
work(old * STAIR * mask(function(x,y) return x < 560 and 1 or 0 end), {hand="body", tool="filbert 4", pile=midT, coverage=3.6, fill=true, clip=STAIR - NEWW, angle=0.35, length={8,24}, load=1.0})
work(old * STAIR * mask(function(x,y) return x >= 560 and 1 or 0 end), {hand="body", tool="filbert 4", pile=coolT, coverage=3.6, fill=true, clip=STAIR - NEWW, angle=0.35, length={8,24}, load=1.0})
work(old - STAIR, {hand="body", tool="filbert 4", pile=hallD, coverage=3.6, fill=true, clip=-(STAIR + NEWW), angle=0.4, length={8,24}, load=1.0})
-- the new bodies: dark bronze, crisp
local wd = pile{{"bone black",1.4},{"bone brown",1.6},{"burnt sienna",0.6}}
for _,w in ipairs(WD) do
  local m = wsil(w[1],w[2],w[3])
  work(m, {hand="body", tool="filbert 3", pile=wd, coverage=4, fill=true, clip=true, angle=0.2, length={4,14}, load=1.0})
end
WARD = NEWW

--@ chunk 30
-- PASS: the Wardens modelled with strokes on the dry dark: warm lamp side, violet underneath, bone, blades, lightning
print(wait(4*24*60))
print(drying(450,300))
local riser = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.3}}
local B = -(WARD:grow(2) + ribbon(WHIP, 9) + THINGS:grow(2) + CMDM:grow(2))
for i=6,#STEPS do local q = STEPS[i]; local b = brush{kind="filbert", width=2.4 + i*0.1, point=0.3}; b:load(riser, 1.0); b:stroke({q[3], q[4]}, {pressure={0.9,0.9}, ramps={0.02,0.02}, clip=B * STAIR}) end
local warm = pile{{"yellow ochre",1.4},{"lead white",1},{"raw sienna",0.6}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.4}}
local half = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone brown",0.4}}
local vio = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",1.2}}
local bone = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.2}}
local seamP = pile{{"bone black",2},{"bone brown",1}}
local hot = pile{{"lead white",2},{"zinc white",2},{"lemon chrome",0.08}}
local function S(cx,cy,s,pts,p,w,pr,load) local q = wpts(cx,cy,s,pts); local b = brush{kind="round", width=w*s, point=0.6}; b:load(p, load or 1.0); b:stroke(q, {pressure=pr or {0.8,0.3}, ramps={0.06,0.4}}) end
for wi,w in ipairs(WD) do
  local cx, cy, s = w[1], w[2], w[3]
  -- carapace: overlapping plates, each lit along its upper-left edge
  for k,band in ipairs({{{-44,-34},{-14,-56},{22,-58}}, {{-46,-18},{-12,-40},{30,-46},{56,-36}}, {{-46,-4},{-8,-22},{36,-28},{64,-14}}}) do
    S(cx,cy,s,band,half,6,{0.8,0.5}); S(cx,cy,s,band,(k==1) and warmH or warm,3,{0.9,0.3})
    local sm = {}; for i,p in ipairs(band) do sm[i] = {p[1]+2, p[2]+6} end; S(cx,cy,s,sm,seamP,2,{0.7,0.5})
  end
  -- violet underside and back edge, from the fold's light
  S(cx,cy,s,{{-38,12},{0,13},{40,11},{58,8}},vio,4,{0.6,0.8}); S(cx,cy,s,{{58,-40},{70,-12},{58,8}},vio,3,{0.4,0.9})
  -- crest / head-plate: lit top, bone studs, a cold eye
  S(cx,cy,s,{{-46,-34},{-60,-40},{-74,-46},{-90,-46}},warmH,3,{0.8,0.4}); S(cx,cy,s,{{-48,-14},{-70,-24},{-88,-44}},vio,2,{0.5,0.6})
  for i=1,6 do local a = i*2.39996; local r = 2.2*math.sqrt(i); local p = wpts(cx,cy,s,{{-62+math.cos(a)*r, -34+math.sin(a)*r}})[1]; stipple(ellipse(p[1],p[2],1.4*s,1.4*s), {pile=bone, width=1.6, coverage=2}) end
  local e = wpts(cx,cy,s,{{-78,-40}})[1]; stipple(ellipse(e[1],e[2],1.6,1.6), {pile=hot, width=1.6, coverage=3})
  -- raised forelimbs with blades: warm upper edge, hot blade edge
  S(cx,cy,s,{{-38,-34},{-62,-66},{-92,-88}},warm,2.4,{0.8,0.3}); S(cx,cy,s,{{-70,-72},{-92,-86}},hot,1.6,{0.9,0.2})
  S(cx,cy,s,{{-28,-18},{-70,-48},{-104,-58}},warm,2.2,{0.8,0.3}); S(cx,cy,s,{{-80,-52},{-104,-58}},hot,1.5,{0.9,0.2})
  -- legs: lit fronts, violet backs, bone knuckles
  for _,l in ipairs(LEGS) do
    local lf = {}; local lb = {}; for i,p in ipairs(l) do lf[i] = {p[1]-2, p[2]}; lb[i] = {p[1]+2, p[2]} end
    S(cx,cy,s,lf,warm,1.8,{0.7,0.2}); S(cx,cy,s,lb,vio,1.4,{0.5,0.4})
    local kn = wpts(cx,cy,s,{l[2]})[1]; stipple(ellipse(kn[1],kn[2],1.8*s,1.8*s), {pile=bone, width=1.8, coverage=2})
  end
  -- bone inlay along the carapace ridge
  for i=0,7 do local p = wpts(cx,cy,s,{{-30+i*11, -52+math.abs(i-3)*3}})[1]; stipple(ellipse(p[1],p[2],1.5*s,1.5*s), {pile=bone, width=1.6, coverage=2}) end
end
-- blooms restated as stroke bursts with small hot cores
local fl = brush{kind="round", width=2.4, point=0.9}
local pv = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",2}}
for _,c in ipairs({{440,300,26},{640,388,20},{780,470,18}}) do
  stipple(ellipse(c[1],c[2],c[3]*0.35,c[3]*0.3), {pile=hot, width=2.5, coverage=4})
  for k=1,24 do local a = rand(0,2*math.pi); local L = c[3]*rand(0.8,2.0)
    fl:load((k%3==0) and pv or hot, 1.0); fl:stroke({{c[1],c[2]},{c[1]+math.cos(a)*L*0.5,c[2]+math.sin(a)*L*0.4},{c[1]+math.cos(a+rand(-0.3,0.3))*L,c[2]+math.sin(a)*L*0.8}}, {pressure={1,0}, ramps={0.03,0.75}}) end
end
-- branching lightning crawling over the leading Warden
local sp = brush{kind="rigger", width=1.7, point=1}
local function zig(x0,y0,x1,y1,n,amp,depth)
  local pts = {{x0,y0}}
  for i=1,n-1 do local t=i/n; pts[#pts+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)} end
  pts[#pts+1] = {x1,y1}; sp:load(hot, 1.0); sp:stroke(pts, {pressure={0.9,0.2}, ramps={0.02,0.2}})
  if depth > 0 then for j=2,#pts-1,2 do local p = pts[j]; local a = rand(0,2*math.pi); zig(p[1],p[2],p[1]+math.cos(a)*18,p[2]+math.sin(a)*14,3,3,depth-1) end end
end
zig(440,300,392,272,6,5,1); zig(442,300,500,286,6,5,1); zig(440,304,412,372,7,5,1); zig(444,304,486,372,7,5,1); zig(438,298,362,252,8,5,1)

--@ chunk 31
-- PASS: starbursts painted out (dark), the Commando's tabard flares
print(wait(24*60))
local hallW = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.8}}
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
LAMPS2 = {{100,70,1.1},{330,48,1.0},{560,110,0.8},{730,150,0.7}}
for i,l in ipairs(LAMPS2) do
  work(ellipse(l[1],l[2],34*l[3],32*l[3]) - CMDM:grow(2), {hand="body", tool="filbert 3", pile=(i<=2) and hallW or hallD, coverage=3.8, fill=true, clip=-CMDM:grow(2), angle=0.4, length={5,14}, load=1.0})
end
-- tabard tails flaring back behind him
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.6}}
TABF = poly({{200,180},{186,196},{168,204},{176,190},{190,170}}, true) + poly({{246,180},{262,196},{278,200},{266,186},{252,172}}, true)
work(TABF, {hand="body", tool="filbert 2", pile=tab, coverage=4, fill=true, clip=true, angle=2.6, length={4,10}, load=1.0})

--@ chunk 32
-- PASS: lanterns, the Commando drawn further, more small things — strokes only, on dry paint
print(wait(3*24*60))
local brz = pile{{"bone brown",2},{"burnt sienna",1}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",1},{"lead white",0.5}}
local core = pile{{"lead white",2},{"Indian yellow",1},{"lemon chrome",0.1}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.4},{"lead white",0.6}}
for _,l in ipairs(LAMPS2) do
  local x, y, s = l[1], l[2], l[3]
  ST({{x,0},{x,y-13*s}}, brz, 1.4, {0.6,0.6})
  ST({{x-7*s,y-11*s},{x,y-15*s},{x+7*s,y-11*s}}, brzL, 2.2, {0.8,0.6})
  work(ellipse(x, y, 4*s, 7*s), {hand="detail", pile=amber, coverage=3.5, fill=true})
  stipple(ellipse(x, y-1*s, 2*s, 3.5*s), {pile=core, width=1.6, coverage=3})
  for k=-1,1 do ST({{x+k*5.5*s, y-10*s},{x+k*6.5*s, y},{x+k*5*s, y+10*s}}, (k==-1) and brzL or brz, 1.6, {0.8,0.8}) end
  ST({{x-6*s,y+10*s},{x+6*s,y+10*s}}, brz, 2.2, {0.8,0.8}); ST({{x,y+10*s},{x,y+15*s}}, brz, 1.4, {0.7,0.3})
end
-- the Commando: plate edges, braced legs, flapping tabard
local warm = pile{{"burnt sienna",0.5},{"yellow ochre",1},{"lead white",1.3}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.3}}
local cold = pile{{"lead white",2},{"zinc white",1},{"cobalt violet",0.35},{"cerulean blue",0.25}}
local seam = pile{{"bone black",2},{"ultramarine blue",0.5}}
local tabL = pile{{"vermilion",1},{"cadmium red",0.4},{"lead white",0.2}}
local C = CMDM + TABF
ST({{196,160},{184,184},{172,208},{160,224}}, seam, 2, {0.7,0.5}, 1, C)
ST({{192,158},{180,182},{168,206}}, warm, 2.4, {0.8,0.3}, 1, C)
ST({{178,196},{172,212},{164,222}}, warmH, 1.8, {0.8,0.2}, 1, C)
ST({{242,158},{258,178},{272,200},{282,218}}, warm, 2.4, {0.8,0.3}, 1, C)
ST({{268,196},{278,212}}, warmH, 1.8, {0.8,0.2}, 1, C)
ST({{248,152},{274,186},{288,220}}, cold, 1.6, {0.3,0.8}, 1, C)
ST({{150,232},{178,232}}, cold, 1.6, {0.6,0.6}, 1, C); ST({{266,230},{296,230}}, cold, 1.6, {0.6,0.6}, 1, C)
ST({{186,124},{212,122},{238,116}}, seam, 1.8, {0.7,0.5}, 1, C); ST({{186,128},{210,126}}, warm, 1.4, {0.6,0.1}, 1, C)
ST({{160,100},{178,96}}, seam, 1.6, {0.6,0.4}, 1, C); ST({{240,74},{252,80}}, warmH, 1.6, {0.8,0.2}, 1, C)
ST({{198,184},{184,196},{170,202}}, tabL, 2, {0.8,0.2}, 1, C); ST({{250,178},{264,192},{276,198}}, tabL, 2, {0.8,0.2}, 1, C)
ST({{206,150},{204,176},{208,188}}, tabL, 1.6, {0.7,0.2}, 1, C)
-- more small things scuttling on the lower stair: low pale strokes, violet bellies, many legs
local pale = pile{{"lead white",2},{"ultramarine ash",0.5},{"cobalt violet",0.2}}
local vd = pile{{"ultramarine blue",1},{"cobalt violet",1},{"bone black",1.2}}
for _,c in ipairs({{600,500},{660,520},{690,440},{830,500},{900,530},{560,500},{730,530}}) do
  if WARD:at(c[1],c[2]) < 0.5 then
    for k=-1,1 do ST({{c[1]-9,c[2]+k*2.2},{c[1]+9,c[2]+k*2.2-1}}, pale, 2.6, {0.9,0.6}) end
    ST({{c[1]-9,c[2]+4},{c[1]+9,c[2]+3}}, vd, 2, {0.8,0.5})
    for k=1,8 do local x = c[1] - 10 + k*2.5; local sgn = (k%2==0) and 1 or -1
      ST({{x,c[2]+4},{x+sgn*4,c[2]+8},{x+sgn*7,c[2]+12}}, vd, 1, {0.7,0.1}) end
  end
end

--@ chunk 33
local warmT = pile{{"raw sienna",1.5},{"yellow ochre",0.8},{"burnt sienna",0.6},{"lead white",0.4}}
local hallD = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.4}}
local keep = -(CMDM:grow(2) + ribbon(WHIP, 9) + WARD:grow(2))
local smear = poly({{320,196},{372,196},{420,232},{410,254},{350,240},{322,214}}) * keep
work(smear * STAIR, {hand="body", tool="filbert 3", pile=warmT, coverage=3.8, fill=true, clip=keep * STAIR, angle=0.9, length={5,14}, load=1.0})
work(smear - STAIR, {hand="body", tool="filbert 3", pile=hallD, coverage=3.8, fill=true, clip=keep - STAIR, angle=0.4, length={5,14}, load=1.0})
