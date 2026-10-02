-- easel session "vigil": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.6, linen={18,16}, seed=7,
  ground={{pile={{"lead white",2},{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",1}}, um=120, apply="knife", texture=0.3}}}
CX,CY,R = 430,930,770
function hz(x) return 440 + 0.00015*(x-380)^2 + 0.02*(x-380) end

--@ chunk 2
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local sky = above(function(x) return hz(x)+15 end)
local disc = ellipse(CX,CY,R,R)
local cor = ellipse(CX,CY,R+90,R+90) - disc
local deep = sky - ellipse(CX,CY,R+90,R+90)
SP_DEEP = pile{{"ultramarine blue",1},{"burnt sienna",1.3},{"rose madder",0.4}}
SP_COR = pile{{"Mars red",1},{"rose madder",1},{"ultramarine blue",0.8},{"burnt sienna",0.8}}
work(deep, {hand="body", pile=SP_DEEP, coverage=3.5, fill=true, angle=tang, edge="soft"})
work(cor*sky, {hand="body", pile=SP_COR, coverage=3.5, fill=true, angle=tang, clip=sky-disc})

--@ chunk 3
function hzd(x) return 0.0003*(x-380) + 0.02 end
local hull = below(hz)
HULL_DK = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",1}}
work(hull, {hand="body", pile=HULL_DK, coverage=3.5, fill=true, angle=function(x,y) return math.atan(hzd(x)) end, clip=hull})

--@ chunk 4
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
SUN = {
 pile{{"lead white",5},{"lemon chrome",1}},
 pile{{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 pile{{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 pile{{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 pile{{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 pile{{"chrome yellow",1},{"Mars orange",1}},
 pile{{"Mars orange",2},{"vermilion",1}},
 pile{{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 pile{{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
SUNE = {0.55,0.68,0.75,0.80,0.85,0.89,0.93,0.96,0.985,1.0}
local vis = ellipse(CX,CY,R,R) - below(hz)
for i=1,9 do
  local a,b = SUNE[i]*R, SUNE[i+1]*R
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * vis
  work(m, {hand="body", pile=SUN[i], coverage=3.5, fill=true, angle=tang, edge="soft", clip=vis})
end
for i=2,9 do
  local r = SUNE[i]*R
  local w = (SUNE[i+1]-SUNE[i-1])*R*0.18
  blend((ellipse(CX,CY,r+w,r+w) - ellipse(CX,CY,r-w,r-w))*vis, {angle=tang})
end

--@ chunk 5
print(wait(2*24*60)); print(drying(100,50), drying(430,200), drying(430,400), drying(500,550), drying(900,300))

--@ chunk 6
print(wait(4*24*60)); print(drying(100,50), drying(430,200), drying(430,400), drying(500,550), drying(900,300))

--@ chunk 7
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local sky = above(hz) - ellipse(CX,CY,R,R)
SPACE = {
 pile{{"Mars orange",1},{"cadmium red",1},{"Mars red",0.5}},
 pile{{"Mars red",1},{"rose madder",0.6},{"bone black",0.4}},
 pile{{"Mars red",1},{"bone black",1},{"rose madder",0.5}},
 pile{{"ultramarine blue",1},{"burnt sienna",1},{"bone black",0.7},{"rose madder",0.3}},
 pile{{"bone black",2},{"ultramarine blue",1},{"rose madder",0.6}},
}
SPE = {0,16,50,115,215,900}
for i=1,5 do
  local a,b = R+SPE[i], R+SPE[i+1]
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * sky
  work(m, {hand="body", pile=SPACE[i], coverage=4, fill=true, angle=tang, edge="soft", clip=sky})
end
for i=2,5 do
  local r = R+SPE[i]
  local w = math.min(SPE[i+1]-SPE[i-1], 160)*0.2
  blend((ellipse(CX,CY,r+w,r+w) - ellipse(CX,CY,r-w,r-w))*sky, {angle=tang})
end

--@ chunk 8
print(wait(5*24*60)); print(drying(100,50), drying(430,140), drying(900,250), drying(980,30))

--@ chunk 9
print(wait(5*24*60)); print(drying(100,50), drying(430,140), drying(900,250), drying(980,30))

--@ chunk 10
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local sky = above(hz) - ellipse(CX,CY,R,R)
COR_DK = pile{{"Mars red",1},{"bone black",1.2},{"rose madder",0.5}}
local m = ellipse(CX,CY,R+70,R+70) * sky
work(m, {hand="body", pile=COR_DK, coverage=4, fill=true, angle=tang, edge="soft", clip=sky})
blend((ellipse(CX,CY,R+85,R+85) - ellipse(CX,CY,R+50,R+50))*sky, {angle=tang})

--@ chunk 11
local hull = below(hz)
local hx, hy = 430, 445
HG = {
 pile{{"lead white",1},{"cadmium yellow",1},{"Mars orange",1}},
 pile{{"Mars orange",2},{"yellow ochre",1},{"red lead",1}},
 pile{{"burnt sienna",1},{"Mars orange",1},{"yellow ochre",0.5}},
 pile{{"burnt sienna",2},{"raw sienna",1},{"bone black",0.5}},
 pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",1}},
 pile{{"bone brown",2},{"burnt sienna",1},{"bone black",1}},
 pile{{"bone brown",2},{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.5}},
}
HGE = {0,10,24,44,72,110,160,400}
local function E(r) return ellipse(hx,hy,r*3.2,r) end
local ang = function(x,y) return math.atan(hzd(x)) end
for i=1,7 do
  local m = (i>1 and (E(HGE[i+1]) - E(HGE[i])) or E(HGE[2])) * hull
  work(m, {hand="body", pile=HG[i], coverage=3.5, fill=true, angle=ang, edge="soft", clip=hull})
end
for i=2,7 do
  local r = HGE[i]; local w = (HGE[i+1]-HGE[i-1])*0.18
  blend((E(r+w)-E(math.max(r-w,1)))*hull, {angle=ang})
end

--@ chunk 12
print(wait(4*24*60)); print(drying(430,450), drying(430,520), drying(100,600), drying(900,560))

--@ chunk 13
wait(24*60)
BZ = {
 pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",1}},
 pile{{"Mars orange",2},{"cadmium yellow",1},{"red lead",1}},
 pile{{"Mars orange",1},{"burnt sienna",1},{"red lead",0.5}},
 pile{{"burnt sienna",2},{"Mars orange",0.5},{"bone brown",0.5}},
 pile{{"burnt sienna",1},{"bone brown",1},{"Mars red",0.3}},
 pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}},
 pile{{"bone brown",2},{"bone black",1},{"ultramarine blue",0.5},{"rose madder",0.3}},
}
HF = function(x,y) return (y-hz(x)) + 0.12*math.abs(x-430) end
HE = {-50,4,11,24,44,72,110,999}
local hull = below(hz)
local ang = function(x,y) return math.atan(hzd(x)) end
for i=1,7 do
  local lo,hi = HE[i],HE[i+1]
  local m = mask(function(x,y) local v=HF(x,y); return (v>=lo and v<hi) and 1 or 0 end) * hull
  work(m, {hand="body", pile=BZ[i], coverage=3.5, fill=true, angle=ang, edge="soft", clip=hull})
end
for i=2,7 do
  local c = HE[i]; local w = math.max(2,(HE[i+1]-HE[i-1])*0.15)
  blend(mask(function(x,y) local v=HF(x,y); return math.abs(v-c)<w and 1 or 0 end)*hull, {angle=ang})
end

--@ chunk 14
print(wait(2*24*60))
BZ[8] = pile{{"bone black",2},{"ultramarine blue",1},{"bone brown",1}}
RIM_HOT = RIM_HOT or pile{{"lead white",3},{"cadmium yellow",1},{"lemon chrome",0.5}}
function scale_lip(x, y, w, h, L, P, opts)
  opts = opts or {}
  P = P or BZ
  local rx, ry = w/2, h
  local arc = {}
  local n = 14
  for i=0,n do local th = math.pi*i/n; arc[#arc+1] = {x + rx*math.cos(th) + rand(-0.15,0.15)*h*0.1, y - ry + ry*math.sin(th)} end
  local dw = math.max(0.9, h*(opts.dark or 0.28))
  local d = brush{kind="round", width=dw, point=0.4}
  d:reload(P[math.min(L+(opts.dstep or 2), #P)], 0.75)
  d:stroke(arc, {pressure={0.25,0.25}, swell={0.4,1.1,1.4,1.1,0.4}})
  local bw = math.max(0.7, h*(opts.lit or 0.12))
  local b = brush{kind="round", width=bw, point=0.6}
  b:reload(L<=2 and RIM_HOT or P[math.max(L-(opts.lstep or 2),1)], 0.7)
  local arc2 = {}
  local m = math.floor(n*0.2)
  for i=m,n-m do local p = arc[i+1]; arc2[#arc2+1] = {p[1], p[2] - dw*0.55} end
  b:stroke(arc2, {pressure={0.2,0.2}, swell={0.3,1,1.2,1,0.3}})
end
function hullL(x,y) local v=HF(x,y); for i=1,7 do if v<HE[i+1] then return i end end return 7 end
local d = 2.5
local k = 0
while d < 200 do
  k = k + 1
  local h = math.max(1.2, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.5 + k*0.09)%1)*w
  while x < 1010 do
    local ww = w*rand(0.88,1.12)
    local xc = x+ww/2
    local y = hz(xc) + d + rand(-0.1,0.1)*h
    if y - h < 640 then
      scale_lip(xc, y, ww, h, hullL(xc, y))
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end
print(k)

--@ chunk 15
function fig_parts(dx, dy)
  dx = dx or 0; dy = dy or 0
  local function P(t) local o={} for i,p in ipairs(t) do o[i]={p[1]+dx,p[2]+dy} end return o end
  local parts = {}
  parts.torso = poly(P{{369,494},{367,474},{368,456},{366,447},{370,441},{380,438},{398,438},{408,441},{411,447},{409,456},{408,474},{406,494}}, true)
  parts.pack = poly(P{{376,446},{377,470},{399,470},{400,446},{392,443},{384,443}}, true)
  parts.lpaul = ellipse(368+dx,444+dy,7,5.5)
  parts.rpaul = ellipse(409+dx,444+dy,7,5.5)
  parts.neck = poly(P{{385,440},{386,430},{394,430},{395,440}}, true)
  parts.head = poly(P{{383,429},{383,420},{387,413},{394,411},{400,414},{403,421},{401,429},{396,433},{387,432}}, true)
  parts.ant = ribbon(P{{399,414},{404,404},{407,398}}, {1.6,1.2,0.9})
  parts.larm = ribbon(P{{366,447},{359,456},{355,463}}, {10,9,8.5})
  parts.knee = ellipse(353+dx,466+dy,8.5,7.5) + ribbon(P{{355,467},{363,490}}, {13,15})
  parts.rarm = ribbon(P{{412,447},{419,460},{423,472},{429,484},{433,492}}, {10,8.5,7.5,6.5,6.5})
  parts.hand = ellipse(434+dx,494+dy,6,3.2)
  parts.hips = poly(P{{360,498},{364,486},{410,486},{418,498}}, true)
  local all = parts.torso + parts.pack + parts.lpaul + parts.rpaul + parts.neck + parts.head + parts.ant + parts.larm + parts.knee + parts.rarm + parts.hand + parts.hips
  return all, parts
end
FIG, FIGP = fig_parts(0,0)
FIG_DK = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1}}
work(FIG, {hand="detail", pile=FIG_DK, coverage=3.5, fill=true})

--@ chunk 16
work(FIG, {hand="detail", pile=FIG_DK, coverage=3, fill=true, angle=math.pi/2})

--@ chunk 17
MAST_DK = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}}
-- mast: a lattice of two rails with bracing, leaning a little
local function lerp2(a,b,t) return {a[1]+(b[1]-a[1])*t, a[2]+(b[2]-a[2])*t} end
local A1,B1 = {788,506},{809,34}
local A2,B2 = {795,506},{814,36}
local rails = ribbon({A1, lerp2(A1,B1,0.5), B1}, {2.6,2.2,1.8}) + ribbon({A2, lerp2(A2,B2,0.5), B2}, {2.6,2.2,1.8})
local braces
local t = 0.02
while t < 0.97 do
  local p, q = lerp2(A1,B1,t), lerp2(A2,B2,t+0.025)
  local r = ribbon({p,q},1.1)
  braces = braces and (braces + r) or r
  t = t + rand(0.035,0.06)
end
local yardpts = {{809,92},{760,101},{700,112},{640,121},{596,128}}
local yardpts2 = {{809,98},{760,107},{700,118},{640,127},{598,133}}
local yard = ribbon(yardpts, {2.4,2.2,2,1.8,1.6}) + ribbon(yardpts2, {2.2,2,1.8,1.6,1.4})
local ybr
for i=0,40 do
  local tt = i/40
  local x = 809 + (598-809)*tt + rand(-1,1)
  local r = ribbon({{x, 92+ (128-92)*tt + 1}, {x-4, 98 + (133-98)*tt}}, 1.0)
  ybr = ybr and (ybr + r) or r
end
-- broken unfinished truss end: a few struts sticking out
local stubs = ribbon({{598,130},{586,124}},1.3) + ribbon({{597,133},{588,142}},1.2) + ribbon({{604,128},{593,115}},1.1)
SAILFRAME = rails + braces + yard + ybr + stubs
work(SAILFRAME, {hand="detail", pile=MAST_DK, coverage=3, fill=true})

--@ chunk 18
SAIL = pile{{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.3},medium=0.55}
local function y0(x) return 92 + (809-x)/213*36 + 3 end
local b = brush{kind="flat", width=12}
local x = 612
local n = 0
while x < 803 do
  local gap = (x > 652 and x < 672) or (x > 733 and x < 745)
  if not gap then
    local t = (x-612)/190
    local L = lerp(110, 330, t) * rand(0.55, 1.15)
    if x > 690 and x < 712 then L = L*0.45 end
    local ya = y0(x)
    local bow = rand(4, 14)
    local pts = {{x, ya}, {x+bow*0.2, ya+L*0.3}, {x+bow*0.6, ya+L*0.65}, {x+bow, ya+L}}
    b:reload(SAIL, rand(0.7,0.95))
    b:stroke(pts, {pressure={0.75, 0.15}, ramps={0.03, 0.35}, orient="across", shake=0.6})
    n = n + 1
  end
  x = x + rand(8, 13)
end
print(n)

--@ chunk 19
print(wait(3*24*60)); print(drying(390,460), drying(700,200), drying(800,300), drying(430,520))

--@ chunk 20
print(wait(4*24*60)); print(drying(390,460), drying(700,200), drying(780,330), drying(430,520))

--@ chunk 21
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local SUNT = {
 {{"lead white",5},{"lemon chrome",1}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
local function withmed(t, m) local o = {} for i,v in ipairs(t) do o[i]=v end o.medium=m return pile(o) end
local LIGHT0 = pile{{"lead white",6},{"lemon chrome",0.6},{"zinc white",1}}
local DARK10 = pile{{"Mars red",1},{"rose madder",1},{"bone brown",0.6}}
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1)
for i=1,9 do
  local a,b = SUNE[i]*R, SUNE[i+1]*R
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * vis
  work(m, {hand="body", pile=withmed(SUNT[i],0.3), coverage=2.6, fill=true, angle=tang, edge="soft", clip=vis})
end
for i=2,9 do
  local r = SUNE[i]*R
  local w = (SUNE[i+1]-SUNE[i-1])*R*0.18
  blend((ellipse(CX,CY,r+w,r+w) - ellipse(CX,CY,r-w,r-w))*vis, {angle=tang})
end
for i=1,9 do
  local a,b = SUNE[i]*R, SUNE[i+1]*R
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * vis
  local wd = lerp(5.5, 2.6, (i-1)/8)
  local lt = i>1 and pile(SUNT[i-1]) or LIGHT0
  local dk = i<9 and pile(SUNT[i+1]) or DARK10
  stipple(m, {pile=lt, width=wd, coverage=0.35, cluster={0.6,22}, pressure={0.3,0.6}, clip=vis})
  stipple(m, {pile=dk, width=wd*0.85, coverage=0.3, cluster={0.6,16}, pressure={0.3,0.6}, clip=vis})
end

--@ chunk 22
BOX_DK = pile{{"bone black",1},{"lead white",0.5},{"ultramarine ash",0.6},{"burnt sienna",0.3}}
local box = poly({{440,494},{440,485},{442,482},{455,482},{457,485},{457,494}}, false)
work(box, {hand="detail", pile=BOX_DK, coverage=3.5, fill=true})
local stalk = ribbon({{450,483},{450.5,477},{451,473}}, {1.6,1.4,1.3})
work(stalk, {hand="detail", pile=MAST_DK, coverage=3, fill=true})
local cable = ribbon({{457,491},{466,493},{478,490},{489,494},{497,499}}, {1.4,1.3,1.3,1.2,1.1})
work(cable, {hand="detail", pile=MAST_DK, coverage=3, fill=true})

--@ chunk 23
print(wait(4*24*60)); print(drying(390,460), drying(430,400), drying(700,300), drying(300,200), drying(448,488))

--@ chunk 24
function rell(cx,cy,a,b,th,n)
  n = n or 20
  local pts = {}
  for i=0,n-1 do local t = 2*math.pi*i/n; local x,y = a*math.cos(t), b*math.sin(t)
    pts[#pts+1] = {cx + x*math.cos(th) - y*math.sin(th), cy + x*math.sin(th) + y*math.cos(th)} end
  return poly(pts, true)
end
local PEN = pile{{"Mars red",1},{"burnt sienna",1},{"Mars orange",0.6}}
local UMB = pile{{"bone brown",1},{"Mars red",1},{"bone black",0.6}}
local function spot(x, y, a, rough)
  local dx, dy = x-CX, y-CY
  local r = math.sqrt(dx*dx+dy*dy)/R
  local f = math.sqrt(math.max(0.05, 1-r*r))
  local th = math.atan(dy,dx) + math.pi/2
  local pen = rell(x,y,a*2.1,a*2.1*f*rand(0.85,1.1),th):roughen(0.6, 4, math.random(1000))
  work(pen, {hand="detail", pile=PEN, coverage=3, fill=true, clip=true})
  if a > 1.2 then
    local um = rell(x+rand(-0.4,0.4),y,a,a*f*rand(0.8,1.1),th)
    work(um, {hand="detail", pile=UMB, coverage=3, fill=true, clip=true})
  end
end
spot(548,292,4.6) spot(567,294,2.2) spot(577,297,1.4) spot(539,289,1.0) spot(558,289,0.9) spot(584,298,1.1)
spot(262,318,3.0) spot(250,316,1.6) spot(272,322,1.0)
spot(690,262,1.2) spot(698,262,0.8)

--@ chunk 25
local function y0(x) return 92 + (809-x)/213*36 + 3 end
local b = brush{kind="flat", width=11}
local x = 610
local n = 0
SAILPATHS = {}
while x < 803 do
  local gap = (x > 652 and x < 671) or (x > 733 and x < 745)
  if not gap then
    local t = (x-612)/190
    local L = lerp(120, 330, t) * rand(0.6, 1.12)
    if x > 690 and x < 712 then L = L*0.45 end
    local ya = y0(x)
    local bow = rand(4, 14)
    local pts = {{x, ya}, {x+bow*0.2, ya+L*0.3}, {x+bow*0.6, ya+L*0.65}, {x+bow, ya+L}}
    SAILPATHS[#SAILPATHS+1] = {pts, L}
    b:reload(SAIL, rand(0.8,1.0))
    b:stroke(pts, {pressure={0.8, 0.2}, ramps={0.03, 0.3}, orient="across", shake=0.6})
    n = n + 1
  end
  x = x + rand(7, 12)
end
print(n)

--@ chunk 26
local sky = above(hz) - ellipse(CX,CY,R,R)
GK = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.5},medium=0.8}
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local m1 = (sky - ellipse(CX,CY,R+45,R+45))
work(m1, {hand="glaze", pile=GK, coverage=2, angle=tang, clip=m1:soften(12)})
local m2 = (sky - ellipse(CX,CY,R+150,R+150))
work(m2, {hand="glaze", pile=GK, coverage=2, angle=tang, clip=m2:soften(20)})

--@ chunk 27
print(wait(7*24*60)); print(drying(100,50), drying(900,100), drying(700,150), drying(390,460))

--@ chunk 28
SH = pile{{"bone brown",1},{"ultramarine blue",0.4},{"bone black",0.3},medium=0.6}
local m = poly({{356,492},{424,492},{446,560},{440,640},{280,640},{318,560}}, true):soften(18)
work(m, {hand="body", pile=SH, coverage=2, angle=math.pi/2+0.25, load=0.5, clip=m})
blend(m:grow(6), {angle=math.pi/2+0.25})

--@ chunk 29
wait(24*60)
LAMPGLOW = pile{{"Indian yellow",1},{"cadmium yellow",0.6},{"lead white",0.6},medium=0.6}
local pool = ellipse(447,494,34,13):soften(10)
work(pool, {hand="body", pile=LAMPGLOW, coverage=1.6, angle=0, load=0.45, clip=pool})
blend(pool:grow(5), {angle=0})

--@ chunk 30
local m = ellipse(447,494,40,17); for i=1,3 do work(m, {hand="body", blender=true, coverage=3, clip=m, angle=i*0.7, dips={2,0,1}}) end

--@ chunk 31
local m = ellipse(447,494,42,19); for i=1,6 do work(m, {hand="scumble", blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 32
print(wait(2*24*60)); print(drying(100,50), drying(900,100), drying(447,494), drying(400,600))

--@ chunk 33
print(wait(3*24*60)); print(drying(100,50), drying(900,100), drying(700,150), drying(400,600), drying(980,300))

--@ chunk 34
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local sky = above(hz) - ellipse(CX,CY,R,R)
SP2 = {
 pile{{"Mars red",1},{"bone black",0.8},{"rose madder",0.5},{"Mars orange",0.3}},
 pile{{"Mars red",1},{"bone black",1.1},{"rose madder",0.5}},
 pile{{"Mars red",0.6},{"bone black",1.3},{"rose madder",0.5},{"ultramarine blue",0.3}},
 pile{{"bone black",1.5},{"ultramarine blue",0.8},{"rose madder",0.5},{"burnt sienna",0.3}},
 pile{{"bone black",2},{"ultramarine blue",1},{"rose madder",0.6}},
}
SP2E = {0,14,45,95,165,900}
for i=1,5 do
  local a,b = R+SP2E[i], R+SP2E[i+1]
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * sky
  work(m, {hand="body", pile=SP2[i], coverage=4, fill=true, angle=tang, edge="soft", clip=sky, length={30,80}})
end
for i=2,5 do
  local r = R+SP2E[i]
  local w = math.min(SP2E[i+1]-SP2E[i-1], 140)*0.22
  blend((ellipse(CX,CY,r+w,r+w) - ellipse(CX,CY,r-w,r-w))*sky, {angle=tang})
end

--@ chunk 35
SH2 = pile{{"bone brown",1},{"burnt sienna",0.5},{"ultramarine blue",0.3},medium=0.6}
local hull = below(hz)
local m1 = (below(function(x) return hz(x)+28 end):soften(22)) * hull - FIG:grow(2)
work(m1, {hand="body", pile=SH2, coverage=2, angle=function(x,y) return math.atan(hzd(x)) end, load=0.5, clip=m1})
blend(m1, {angle=function(x,y) return math.atan(hzd(x)) end})
local m2 = (below(function(x) return hz(x)+95 end):soften(30)) * hull - FIG:grow(2)
work(m2, {hand="body", pile=SH2, coverage=1.8, angle=function(x,y) return math.atan(hzd(x)) end, load=0.5, clip=m2})
blend(m2, {angle=function(x,y) return math.atan(hzd(x)) end})

--@ chunk 36
print(wait(6*24*60)); print(drying(100,50), drying(900,100), drying(700,150), drying(400,600), drying(700,540))

--@ chunk 37
work(SAILFRAME, {hand="detail", pile=MAST_DK, coverage=3.5, fill=true})
SAIL_TOP = pile{{"burnt sienna",1},{"bone brown",1},{"Mars orange",0.3},{"lead white",0.2},medium=0.4}
local outside = -(ellipse(CX,CY,R-1,R-1))
local b = brush{kind="flat", width=11}
for i,sp in ipairs(SAILPATHS) do
  b:reload(SAIL_TOP, rand(0.8,1.0))
  b:stroke(sp[1], {pressure={0.8, 0.2}, ramps={0.03, 0.3}, orient="across", shake=0.6, clip=outside})
end

--@ chunk 38
local outside = -(ellipse(CX,CY,R-1,R-1))
local b = brush{kind="flat", width=11}
for i,sp in ipairs(SAILPATHS) do
  b:reload(SAIL, rand(0.8,1.0))
  b:stroke(sp[1], {pressure={0.8, 0.3}, ramps={0.03, 0.3}, orient="across", shake=0.6, clip=outside})
end

--@ chunk 39
print(wait(3*24*60)); print(drying(650,150), drying(780,150), drying(795,300))

--@ chunk 40
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local d = 2.5
local k = 0
while d < 200 do
  k = k + 1
  local h = math.max(1.2, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.5 + k*0.13)%1)*w
  while x < 1010 do
    local ww = w*rand(0.85,1.15)
    local xc = x+ww/2
    local y = hz(xc) + d + rand(-0.12,0.12)*h
    if y - h < 640 and okm:at(xc, y) > 0.5 then
      local L = hullL(xc, y)
      scale_lip(xc, y, ww, h, L, BZ, {dstep = (L>=5) and 3 or 2, lit = (L>=5) and 0.08 or 0.12})
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end

--@ chunk 41
print(wait(2*24*60), drying(650,150), drying(780,150))
SAIL_DK = pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.5},{"Mars red",0.2}}
local outside = -(ellipse(CX,CY,R-1,R-1))
local b = brush{kind="flat", width=11}
for i,sp in ipairs(SAILPATHS) do
  b:reload(SAIL_DK, 0.95)
  b:stroke(sp[1], {pressure={0.85, 0.5}, ramps={0.03, 0.2}, orient="across", shake=0.6, clip=outside})
end

--@ chunk 42
local okm = below(hz) - FIG:grow(1) - SAILFRAME:grow(1) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local GE = {-10, 6, 13, 24}
local GP = {BZ[1], BZ[2], BZ[3]}
local ang = function(x,y) return math.atan(hzd(x)) end
for i=1,3 do
  local lo,hi = GE[i],GE[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * okm
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=GP[i], coverage=3, fill=true, angle=ang, edge="soft", clip=okm, length={15,45}})
end
for i=2,4 do
  local c = GE[i]; local w = 2.5
  blend(mask(function(x,y) local v=G(x,y); return math.abs(v-c)<w and 1 or 0 end)*okm, {angle=ang})
end

--@ chunk 43
local okm = below(hz) - FIG:grow(1) - SAILFRAME:grow(1) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local ang = function(x,y) return math.atan(hzd(x)) end
blend(mask(function(x,y) local v=G(x,y); return math.abs(v-25)<7 and 1 or 0 end)*okm, {angle=ang})

--@ chunk 44
print(wait(2*24*60), drying(300,460), drying(650,150))

--@ chunk 45
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
GLINT1 = pile{{"lead white",4},{"lemon chrome",1},{"cadmium yellow",0.5}}
local function glint(x, y, w, h, gp, dp, pd)
  local rx, ry = w/2, h
  local arc = {}
  for i=0,10 do local th = math.pi*i/10; arc[#arc+1] = {x + rx*math.cos(th), y - ry + ry*math.sin(th)} end
  local d = brush{kind="round", width=math.max(0.7, h*0.25), point=0.4}
  d:reload(dp, 0.7)
  d:stroke(arc, {pressure={0.25,0.25}, swell={0.4,1.1,1.3,1.1,0.4}})
  if math.random() < pd then
    local b = brush{kind="round", width=math.max(0.6, h*0.2), point=0.6}
    b:reload(gp, 0.8)
    local a2 = {}
    for i=2,8 do local p = arc[i+1]; a2[#a2+1] = {p[1], p[2] - math.max(0.7,h*0.25)*0.6} end
    b:stroke(a2, {pressure={0.3,0.3}, swell={0.3,1,1.3,1,0.3}})
  end
end
local d = 1.2
local k = 0
local n = 0
while d < 34 do
  k = k + 1
  local h = math.max(1.0, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.5 + k*0.13)%1)*w
  while x < 1010 do
    local ww = w*rand(0.85,1.15)
    local xc = x+ww/2
    local y = hz(xc) + d
    local g = G(xc, y)
    if g < 34 and okm:at(xc, y) > 0.5 and okm:at(xc-ww/2, y-h) > 0.5 and okm:at(xc+ww/2, y-h) > 0.5 then
      local gp = g < 9 and GLINT1 or (g < 18 and RIM_HOT or BZ[1])
      local dp = g < 12 and BZ[3] or (g < 22 and BZ[4] or BZ[5])
      local pd = clamp(1.1 - g/34, 0.1, 0.95)
      glint(xc, y, ww, h, gp, dp, pd)
      n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end
print(n)

--@ chunk 46
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local b = brush{kind="round", width=1.6, point=0.5}
local n = 0
for i=1,2600 do
  local x = rand(0, 1000)
  local dd = math.abs(randn(0, 9)) + 0.8
  local y = hz(x) + dd
  local g = G(x, y)
  if g < 30 and math.random() < (1 - g/30)^1.5 and okm:at(x,y) > 0.5 then
    local len = rand(1.5, 7) * (1 - g/40)
    b:reload(g < 12 and GLINT1 or RIM_HOT, 0.6)
    local s = hzd(x)
    b:stroke({{x-len/2, y - s*len/2}, {x+len/2, y + s*len/2}}, {pressure={0.25,0.25}, swell={0.4,1.2,0.4}})
    n = n + 1
  end
end
print(n)
local rim = brush{kind="round", width=1.4, point=0.4}
local x = 230
while x < 640 do
  local L = rand(6, 30)
  if math.random() < 0.8 then
    local pts = {}
    for t=0,4 do local xx = x + L*t/4; pts[#pts+1] = {xx, hz(xx)+0.6} end
    rim:reload(GLINT1, 0.7)
    rim:stroke(pts, {pressure={0.3,0.3}, swell={0.5,1,1,0.5}, clip=okm})
  end
  x = x + L + rand(1, 6)
end

--@ chunk 47
print(wait(24*60))
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local ang = function(x,y) return math.atan(hzd(x)) end
local m1 = mask(function(x,y) return G(x,y) < 16 and 1 or 0 end) * okm
work(m1, {hand="scumble", pile=RIM_HOT, coverage=1.2, load=0.2, pressure={0.15,0.35}, angle=ang, clip=okm, length={6,16}})
local m2 = mask(function(x,y) return G(x,y) < 8 and 1 or 0 end) * okm
work(m2, {hand="scumble", pile=GLINT1, coverage=1.2, load=0.2, pressure={0.15,0.35}, angle=ang, clip=okm, length={6,16}})

--@ chunk 48
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local ang = function(x,y) return math.atan(hzd(x)) end
local m = mask(function(x,y) return G(x,y) < 22 and 1 or 0 end) * okm
blend(m, {angle=ang})
blend(m, {angle=function(x,y) return math.atan(hzd(x))+0.15 end})

--@ chunk 49
print(wait(24*60 + 600))
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - rect(436,470,26,28)
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local function glint(x, y, w, h, gp, dp, pd)
  local rx, ry = w/2, h
  local arc = {}
  for i=0,10 do local th = math.pi*i/10; arc[#arc+1] = {x + rx*math.cos(th), y - ry + ry*math.sin(th)} end
  local d = brush{kind="round", width=math.max(0.8, h*0.28), point=0.4}
  d:reload(dp, 0.7)
  d:stroke(arc, {pressure={0.3,0.3}, swell={0.4,1.1,1.3,1.1,0.4}})
  if math.random() < pd then
    local b = brush{kind="round", width=math.max(0.9, h*0.3), point=0.5}
    b:reload(gp, 0.85)
    local a2 = {}
    for i=2,8 do local p = arc[i+1]; a2[#a2+1] = {p[1], p[2] - math.max(0.8,h*0.28)*0.7} end
    b:stroke(a2, {pressure={0.4,0.4}, swell={0.3,1,1.3,1,0.3}})
  end
end
local d = 1.0
local k = 0
local n = 0
while d < 30 do
  k = k + 1
  local h = math.max(1.0, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.5 + k*0.17)%1)*w
  while x < 1010 do
    local ww = w*rand(0.85,1.15)
    local xc = x+ww/2
    local y = hz(xc) + d
    local g = G(xc, y)
    if g < 24 and okm:at(xc, y) > 0.5 and okm:at(xc-ww/2, y-h) > 0.5 and okm:at(xc+ww/2, y-h) > 0.5 then
      local gp = g < 12 and GLINT1 or RIM_HOT
      local dp = g < 8 and BZ[2] or (g < 16 and BZ[3] or BZ[4])
      glint(xc, y, ww, h, gp, dp, 0.75)
      n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end
print(n)
-- the hull's own silhouette against the sun: a thin serrated edge
local e = brush{kind="round", width=1.3, point=0.3}
local x = 0
while x < 1000 do
  local L = rand(3, 9)
  local pts = {}
  for t=0,3 do local xx = x + L*t/3; pts[#pts+1] = {xx, hz(xx) + 0.3} end
  local g = G(x, hz(x))
  e:reload(g < 10 and BZ[2] or BZ[3], 0.7)
  e:stroke(pts, {pressure={0.35,0.35}, swell={0.5,1.1,0.5}})
  x = x + L
end

--@ chunk 50
work(FIG, {hand="detail", pile=FIG_DK, coverage=3.5, fill=true, angle=math.pi/2})
FIG_COOL = pile{{"bone black",1},{"lead white",0.45},{"ultramarine blue",0.4},{"rose madder",0.3}}
FIG_WARM = pile{{"bone brown",1},{"burnt sienna",1},{"bone black",0.4}}
local up = FIG * mask(function(x,y) return y < 452 and 1 or 0 end):blur(4)
work(up, {hand="detail", pile=FIG_COOL, coverage=1.6, fill=true, angle=math.pi/2, clip=FIG})
local lo = FIG * mask(function(x,y) return y > 474 and 1 or 0 end):blur(5)
work(lo, {hand="detail", pile=FIG_WARM, coverage=1.6, fill=true, angle=0, clip=FIG})

--@ chunk 51
local up = FIG * mask(function(x,y) return y < 460 and 1 or 0 end):blur(4)
work(up, {hand="detail", pile=FIG_DK, coverage=1.5, fill=true, angle=math.pi/2, clip=FIG})
local lo = FIG * mask(function(x,y) return y > 470 and 1 or 0 end):blur(4)
work(lo, {hand="detail", pile=FIG_DK, coverage=1.0, fill=true, angle=0, clip=FIG})

--@ chunk 52
print(drying(447,488), drying(450,500), drying(390,450))

--@ chunk 53
LAMP_HOUSE = pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.25},{"burnt sienna",0.3}}
local base = ellipse(448,495.5,8.5,2.4)
local body = poly({{442.5,495},{442.5,486},{453.5,486},{453.5,495}})
local cap = ellipse(448,485.5,6.2,3.2) + rect(445.5,481.5,5,3)
LAMP = base + body + cap
work(LAMP, {hand="detail", pile=LAMP_HOUSE, coverage=3.5, fill=true})
local stalk = ribbon({{449,482},{449.5,477},{450,474.5}}, {1.0,0.8,0.7})
work(stalk, {hand="detail", pile=MAST_DK, coverage=3, fill=true})
local cable = ribbon({{455,494},{463,496.5},{474,495},{484,498.5},{494,503},{501,508}}, {1.5,1.4,1.4,1.3,1.2,1.1})
work(cable, {hand="detail", pile=MAST_DK, coverage=3, fill=true})

--@ chunk 54
print(wait(24*60), drying(448,490))
local dk = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}
-- darken the housing sides, keep a cooler cap
work(LAMP - rect(443.5,486.8,9,4.6), {hand="detail", pile=dk, coverage=2.5, fill=true})

--@ chunk 55
print(wait(12*60), drying(448,489))
LENS_O = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
LENS_C = pile{{"lead white",3},{"cadmium yellow",1.2},{"Indian yellow",0.3}}
local band = rect(443.6,487,8.8,4.4)
work(band, {hand="detail", pile=LENS_O, coverage=3.5, fill=true, angle=0})
local core = ellipse(448,489.2,3.2,1.5)
work(core, {hand="detail", pile=LENS_C, coverage=4, fill=true, angle=0})

--@ chunk 56
local avoid = LAMP:grow(0.5) + FIG:grow(1)
local p1 = ellipse(449,496,30,9) - avoid
work(p1, {hand="scumble", tool={kind="filbert", width=3}, pile=LENS_O, coverage=0.7, load=0.15, pressure={0.12,0.3}, angle=0, clip=p1, length={4,9}})
local p2 = ellipse(449,495,16,5) - avoid
work(p2, {hand="scumble", tool={kind="filbert", width=2.5}, pile=LENS_O, coverage=1.0, load=0.2, pressure={0.15,0.35}, angle=0, clip=p2, length={3,7}})

--@ chunk 57
local m = ellipse(449,496,32,10) - LAMP:grow(0.3) - FIG:grow(0.5); for i=1,6 do work(m, {hand="scumble", tool={kind="filbert", width=4}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 58
local b = brush{kind="round", width=2.2, point=0.6}
local function glint(x, y, w, p, pr)
  local pts = {}
  for i=0,6 do local t = i/6; local xx = x - w/2 + w*t; pts[#pts+1] = {xx, y + 0.9*math.sin(math.pi*t)*(w/10)} end
  b:reload(p, 0.75)
  b:stroke(pts, {pressure={pr,pr}, swell={0.3,1,1.2,1,0.3}})
end
LAMP_GLOW2 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"cadmium red",0.3},{"lead white",0.3}}
local ys = {500.5, 507, 515, 525, 537, 551, 568, 588}
for i,y in ipairs(ys) do
  local w = 11 - i*0.9
  local x = 449 + rand(-1.5,1.5) + (i-1)*0.6
  local p = i <= 2 and LENS_O or LAMP_GLOW2
  local pr = math.max(0.12, 0.42 - i*0.04)
  if i <= 6 or math.random() < 0.6 then glint(x, y, w, p, pr) end
end
-- small side glints on neighbouring plates
glint(466, 499, 6, LAMP_GLOW2, 0.25)
glint(478, 503, 5, LAMP_GLOW2, 0.18)
glint(461, 508, 5, LAMP_GLOW2, 0.2)

--@ chunk 59
print(wait(2*24*60), drying(650,150), drying(780,150), drying(390,450), drying(372,480))

--@ chunk 60
print(wait(24*60), drying(200,100), drying(300,60))
STREAM = pile{{"lead white",1},{"Mars orange",0.4},{"rose madder",0.3},{"bone black",0.2},medium=0.75}
local b = brush{kind="filbert", width=9}
local function streamer(ang, len, curve, w)
  local pts = {}
  for i=0,8 do
    local t = i/8
    local r = R + 6 + len*t
    local a = ang + curve*t*t
    pts[#pts+1] = {CX + r*math.cos(a), CY + r*math.sin(a)}
  end
  b:reload(STREAM, 0.35)
  b:stroke(pts, {pressure={0.35, 0.02}, ramps={0.05, 0.8}, swell={1.2,1,0.7}})
end
streamer(-math.pi/2 - 0.42, 190, -0.05)

--@ chunk 61
local pts = {}
for i=0,8 do local t=i/8; local r = R+6+190*t; local a = -math.pi/2-0.42 - 0.05*t*t; pts[#pts+1] = {CX + r*math.cos(a), CY + r*math.sin(a)} end
local m = ribbon(pts, 14)
for i=1,6 do work(m, {hand="scumble", tool={kind="filbert", width=6}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 62
local b = brush{kind="filbert", width=10}
local function streamer(ang, len, curve, lifts)
  local pts = {}
  for i=0,8 do
    local t = i/8
    local r = R + 4 + len*t
    local a = ang + curve*t*t
    pts[#pts+1] = {CX + r*math.cos(a), CY + r*math.sin(a)}
  end
  b:reload(STREAM, 0.35)
  b:stroke(pts, {pressure={0.4, 0.02}, ramps={0.05, 0.8}, swell={1.2,1,0.7}})
  local m = ribbon(pts, 16)
  for i=1,lifts do work(m, {hand="scumble", tool={kind="filbert", width=6}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end
end
local H = -math.pi/2
streamer(H-0.18, 150, 0.03, 4)
streamer(H-0.68, 210, -0.06, 4)
streamer(H+0.06, 120, 0.02, 4)
streamer(H-0.93, 170, -0.08, 4)
streamer(-0.8, 140, 0.05, 4)
streamer(H-1.2, 160, -0.05, 4)

--@ chunk 63
GLOWP = pile{{"Mars orange",1},{"cadmium red",0.35},{"lead white",0.3},medium=0.6}
local m = ellipse(449,496,15,5.5) - LAMP
work(m, {hand="body", tool={kind="filbert", width=4}, pile=GLOWP, coverage=2, load=0.5, angle=0, clip=m, length={5,12}})
blend(ellipse(449,497,30,11) - LAMP, {angle=0, clip=false})
blend(ellipse(449,497,26,10) - LAMP, {angle=1.2, clip=false})

--@ chunk 64
local m = (rect(385,488,110,40) - LAMP:grow(0.5) - FIG:grow(0.5) - ellipse(449,496,13,5))
for i=1,4 do work(m, {hand="scumble", tool={kind="filbert", width=4}, blender=true, coverage=2.5, clip=m, dips={1,0,1}}) end

--@ chunk 65
print(wait(6*24*60), drying(390,450), drying(372,485), drying(650,150), drying(449,496))

--@ chunk 66
local fb = brush{kind="flat", width=4.5}
local function shred(pts, sw)
  fb:reload(SAIL_DK, 0.9)
  fb:stroke(pts, {pressure={0.8,0.3}, ramps={0.05,0.3}, orient="across", swell=sw, shake=0.4})
end
shred({{600,132},{588,121},{578,104},{581,86},{594,73},{599,58},{593,45}}, {1,0.35,1,0.3,0.9,0.4,0.7})
shred({{812,46},{829,40},{848,37},{864,29},{879,17},{896,10},{912,8}}, {1,0.4,1,0.3,1,0.5,0.6})
shred({{801,300},{819,313},{843,321},{866,333},{890,338},{915,350},{934,367}}, {1,0.3,1,0.35,1,0.4,0.8})
shred({{806,96},{822,88},{840,86},{853,78},{860,64}}, {1,0.4,1,0.3,0.6})
-- sunlit edges and twists of the film
local g = brush{kind="round", width=1.3, point=0.6}
local function edge(pts, p, pr)
  g:reload(p, 0.7)
  g:stroke(pts, {pressure={pr, pr*0.4}, swell={0.4,1,1,0.5}})
end
for i,sp in ipairs(SAILPATHS) do
  local pts = sp[1]
  if i % 3 ~= 1 then
    local side = (i % 2 == 0) and 5.2 or -5.2
    local a, b = pts[1], pts[2]
    local L = math.min(sp[2]*0.3, 60) * rand(0.4, 1)
    local y0 = a[2] + rand(4, 20)
    edge({{a[1]+side, y0}, {a[1]+side+0.6, y0+L*0.5}, {a[1]+side+1.2, y0+L}}, BZ[2], rand(0.25,0.4))
  end
end
local t = brush{kind="round", width=2.2, point=0.5}
local function twist(x, y, p) t:reload(p, 0.7); t:stroke({{x-1.2,y-0.6},{x+1.2,y+0.6}}, {pressure={0.4,0.4}}) end
twist(583,113, GLINT1) twist(586,79, RIM_HOT) twist(838,38, GLINT1) twist(871,24, RIM_HOT) twist(831,317, GLINT1) twist(877,336, RIM_HOT) twist(846,84, RIM_HOT)

--@ chunk 67
local m = ribbon({{600,132},{588,121},{578,104},{581,86},{594,73},{599,58},{593,45}}, 9)
 + ribbon({{812,46},{829,40},{848,37},{864,29},{879,17},{896,10},{912,8}}, 9)
 + ribbon({{801,300},{819,313},{843,321},{866,333},{890,338},{915,350},{934,367}}, 9)
 + ribbon({{806,96},{822,88},{840,86},{853,78},{860,64}}, 9)
m = m - SAILFRAME:grow(0.5)
for i=1,6 do work(m, {hand="scumble", tool={kind="filbert", width=4}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 68
SHR1 = pile{{"Mars orange",1},{"bone brown",1},{"rose madder",0.3}}
SHR2 = pile{{"burnt sienna",1},{"Mars orange",1},{"lead white",0.3}}
local f = brush{kind="filbert", width=5}
local function rib(pts, p, load, sw)
  f:reload(p, load)
  f:stroke(pts, {pressure={0.55,0.1}, orient="across", swell=sw, shake=0.4})
end
rib({{812,47},{830,40},{850,38},{868,30},{884,20},{902,13},{922,12},{940,6}}, SHR1, 0.55, {1,0.35,1,0.3,1,0.4,0.8,0.4})
rib({{810,52},{826,57},{846,55},{866,60},{884,57},{900,64}}, SHR2, 0.45, {1,0.4,0.9,0.3,0.8,0.4})
rib({{600,131},{589,120},{579,104},{582,87},{594,73},{598,58},{591,44},{580,34}}, SHR1, 0.55, {1,0.35,1,0.3,0.9,0.4,0.7,0.3})
rib({{806,98},{822,91},{838,90},{852,82},{860,68},{872,58}}, SHR2, 0.5, {1,0.4,1,0.3,0.6,0.3})
rib({{812,240},{829,252},{850,258},{871,270},{893,276},{916,288},{934,304}}, SHR1, 0.5, {1,0.3,1,0.35,1,0.4,0.8})
-- a loose fragment drifting away
rib({{948,150},{957,143},{966,147},{975,140}}, SHR2, 0.4, {1,0.5,1,0.4})
rib({{662,52},{671,47},{680,50},{689,44}}, SHR1, 0.35, {1,0.5,1,0.4})

--@ chunk 69
local SUNT = {
 {{"lead white",5},{"lemon chrome",1}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
SUNP = {} for i,t in ipairs(SUNT) do SUNP[i] = pile(t) end
function bgpile(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  if r < R then
    local f = r / R
    for i=1,9 do if f < SUNE[i+1] then return SUNP[i] end end
    return SUNP[9]
  else
    local d = r - R
    for i=1,5 do if d < SP2E[i+1] then return SP2[i] end end
    return SP2[5]
  end
end
SAILM = nil
for i,sp in ipairs(SAILPATHS) do local m = ribbon(sp[1], 10); SAILM = SAILM and (SAILM + m) or m end
local holes = {
  {628,165,3,22}, {641,214,2.5,30}, {700,150,4,16}, {714,190,3,40}, {760,140,5,12},
  {772,200,2.5,34}, {752,250,3,26}, {690,240,2,22}, {786,170,3,18}, {626,240,2.5,15},
}
for i,h in ipairs(holes) do
  local x,y,a,b = h[1],h[2],h[3],h[4]
  local m = ellipse(x,y,a,b):roughen(1.2, 6, i*7) * SAILM:shrink(1.5)
  if m:area() > 1 then
    work(m, {hand="detail", pile=bgpile(x,y), coverage=4, fill=true, angle=math.pi/2})
  end
end

--@ chunk 70
local f = brush{kind="flat", width=3.5}
local g = brush{kind="round", width=1.1, point=0.6}
local function along(pts, off, frac0, frac1)
  local o = {}
  local n = #pts
  for i=1,n do
    local t = (i-1)/(n-1)
    local p = pts[i]
    o[#o+1] = {p[1]+off, p[2]}
  end
  local a, b = o[1], o[#o]
  local res = {}
  for i=0,6 do local t = frac0 + (frac1-frac0)*i/6
    local k = t*(n-1); local j = math.floor(k); local u = k-j
    j = math.min(j, n-2)
    res[#res+1] = {o[j+1][1] + (o[j+2][1]-o[j+1][1])*u, o[j+1][2] + (o[j+2][2]-o[j+1][2])*u}
  end
  return res
end
for i,sp in ipairs(SAILPATHS) do
  local pts = sp[1]
  local off = rand(-3,3)
  f:reload(SHR1, 0.4)
  f:stroke(along(pts, off, 0.03, rand(0.35,0.6)), {pressure={0.45,0.05}, ramps={0.05,0.6}, orient="across", shake=0.4})
  if math.random() < 0.6 then
    g:reload(math.random()<0.5 and RIM_HOT or BZ[2], 0.6)
    g:stroke(along(pts, off + (math.random()<0.5 and -2.2 or 2.2), rand(0.02,0.1), rand(0.25,0.5)), {pressure={0.35,0.05}, ramps={0.1,0.5}})
  end
end

--@ chunk 71
print(wait(2*24*60), drying(400,550), drying(450,560), drying(380,490), drying(700,520), drying(100,560))

--@ chunk 72
BZ[8] = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.5},{"ultramarine blue",0.3}}
local G = function(x,y) return (y-hz(x)) + 0.06*math.abs(x-430) end
local keep = FIG:grow(0.8) + LAMP:grow(0.8) + SAILFRAME:grow(0.8)
local hull = below(hz) - keep
local E2 = {28, 46, 80, 130, 999}
local P2 = {BZ[5], BZ[6], BZ[7], BZ[8]}
local ang = function(x,y) return math.atan(hzd(x)) end
for i=1,4 do
  local lo,hi = E2[i],E2[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * hull
  work(m, {hand="body", pile=P2[i], coverage=3.5, fill=true, angle=ang, edge=(i==1) and "lost" or "soft", clip=hull})
end
for i=2,4 do
  local c = E2[i]; local w = (E2[i+1]-E2[i-1])*0.14
  blend(mask(function(x,y) local v=G(x,y); return math.abs(v-c)<w and 1 or 0 end)*hull, {angle=ang})
end

--@ chunk 73
SHD = pile{{"bone brown",2},{"bone black",1.2},{"ultramarine blue",0.6},{"rose madder",0.2}}
local keep = FIG:grow(0.8) + LAMP:grow(0.8)
local sh = poly({{362,494},{416,494},{426,530},{432,580},{438,640},{262,640},{300,580},{330,530}}, true) - keep
work(sh, {hand="body", pile=SHD, coverage=3, fill=true, angle=math.pi/2+0.2, edge="soft", clip=below(hz)-keep})
blend(sh:grow(6)-keep, {angle=math.pi/2+0.2})

--@ chunk 74
print(wait(5*24*60), drying(400,550), drying(450,470), drying(700,520), drying(100,560), drying(330,600))

--@ chunk 75
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local SUNT = {
 {{"lead white",5},{"lemon chrome",1}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
local function norm(t) local s=0 for _,v in ipairs(t) do s=s+v[2] end local o={} for _,v in ipairs(t) do o[v[1]]=v[2]/s end return o end
local function mixrec(a, b, wa)
  local na, nb = norm(a), norm(b)
  local acc, order = {}, {}
  for k,v in pairs(na) do acc[k]=(acc[k] or 0)+v*wa end
  for k,v in pairs(nb) do acc[k]=(acc[k] or 0)+v*(1-wa) end
  local o = {}
  for _,t in ipairs(a) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  for _,t in ipairs(b) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  return o
end
-- interleaved bands
local bands = {}
for i=1,9 do
  local a, b = SUNE[i], SUNE[i+1]
  local w = b - a
  local lo = (i==1) and 0 or a + 0.22*w
  local hi = (i==9) and 1.0 or b - 0.22*w
  bands[#bands+1] = {lo, hi, SUNT[i]}
  if i < 9 then
    local w2 = SUNE[i+2] - SUNE[i+1]
    bands[#bands+1] = {hi, b + 0.22*w2, mixrec(SUNT[i], SUNT[i+1], 0.5)}
  end
end
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
for k,bd in ipairs(bands) do
  local m = (ellipse(CX,CY,bd[2]*R,bd[2]*R) - ellipse(CX,CY,bd[1]*R,bd[1]*R)) * vis
  work(m, {hand="body", pile=pile(bd[3]), coverage=3, fill=true, angle=tang, edge="soft", clip=vis})
end
for k=2,#bands do
  local r = bands[k][1]*R
  local w = math.max(2.5, (bands[k][2]-bands[k-1][1])*R*0.2)
  blend((ellipse(CX,CY,r+w,r+w) - ellipse(CX,CY,r-w,r-w))*vis, {angle=tang})
end
print(#bands)

--@ chunk 76
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local LIGHT0 = pile{{"lead white",6},{"lemon chrome",0.6}}
local DARK10 = pile{{"Mars red",1},{"rose madder",1},{"bone brown",0.6}}
for i=1,9 do
  local a,b = SUNE[i]*R, SUNE[i+1]*R
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * vis
  local wd = lerp(6, 2.6, (i-1)/8)
  local lt = i>1 and SUNP[i-1] or LIGHT0
  local dk = i<9 and SUNP[i+1] or DARK10
  stipple(m, {pile=lt, width=wd, coverage=0.3, cluster={0.65,28}, pressure={0.25,0.5}, clip=vis})
  stipple(m, {pile=dk, width=wd*0.85, coverage=0.25, cluster={0.65,20}, pressure={0.25,0.5}, clip=vis})
end

--@ chunk 77
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local m = vis * rect(0,0,300,640) * (ellipse(CX,CY,0.97*R,0.97*R) - ellipse(CX,CY,0.7*R,0.7*R))
blend(m, {angle=rad})

--@ chunk 78
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local m = vis * ellipse(CX,CY,0.975*R,0.975*R)
blend(m, {angle=rad})

--@ chunk 79
print(wait(5*24*60), drying(400,300), drying(200,400), drying(400,550), drying(700,520), drying(330,600))

--@ chunk 80
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local LIGHT0 = pile{{"lead white",6},{"lemon chrome",0.6}}
local Eo = ellipse(430,446,360,85)
local Em = ellipse(430,446,240,52)
local Ei = ellipse(425,446,130,28)
work((Eo - Em)*vis, {hand="body", pile=SUNP[3], coverage=2.6, fill=true, angle=rad, edge="soft", clip=vis})
work((Em - Ei)*vis, {hand="body", pile=SUNP[2], coverage=2.8, fill=true, angle=rad, edge="soft", clip=vis})
work(Ei*vis, {hand="body", pile=LIGHT0, coverage=3, fill=true, angle=rad, edge="soft", clip=vis})
blend(Eo:grow(8)*vis, {angle=rad})

--@ chunk 81
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local Eo = ellipse(430,446,360,85)
local ring = (ellipse(430,446,395,112) - ellipse(430,446,320,62)) * vis
blend(ring, {angle=rad})
blend(ring, {angle=rad, tool={kind="badger", width=20}})

--@ chunk 82
local vis = ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
local b = brush{kind="filbert", width=6}
local n = 0
for i=1,140 do
  local t = rand(0.02, 0.98) * math.pi
  local ex, ey = 430 + 380*math.cos(math.pi + t), 446 - 98*math.sin(t)
  if ey < hz(ex) - 3 then
    local a = math.atan(ey-CY, ex-CX)
    local r0, r1 = rand(-28,-10), rand(15,45)
    local pts = {}
    for k=0,4 do local r = r0 + (r1-r0)*k/4; pts[#pts+1] = {ex + r*math.cos(a) + rand(-1,1), ey + r*math.sin(a)} end
    local p = (math.random()<0.5) and SUNP[3] or SUNP[4]
    b:reload(p, rand(0.2,0.4))
    b:stroke(pts, {pressure={0.5,0.03}, ramps={0.05,0.7}, clip=vis})
    n = n + 1
  end
end
print(n)

--@ chunk 83
blend(ellipse(430,446,400,110) * (ellipse(CX,CY,R,R) - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)), {angle=function(x,y) return math.atan(y-CY,x-CX) end}); print(wait(4*24*60), drying(430,380), drying(300,300))

--@ chunk 84
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local SUNT = {
 {{"lead white",6},{"lemon chrome",0.7}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
local function norm(t) local s=0 for _,v in ipairs(t) do s=s+v[2] end local o={} for _,v in ipairs(t) do o[v[1]]=v[2]/s end return o end
local function mixrec(a, b, wa)
  local na, nb = norm(a), norm(b)
  local acc = {}
  for k,v in pairs(na) do acc[k]=(acc[k] or 0)+v*wa end
  for k,v in pairs(nb) do acc[k]=(acc[k] or 0)+v*(1-wa) end
  local o = {}
  for _,t in ipairs(a) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  for _,t in ipairs(b) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  return o
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local bands = {}
for i=1,9 do
  local a, b = E[i], (E[i+1] or 1.0)
  if i == 9 then b = 1.0 end
  local w = b - a
  local lo = (i==1) and -1 or a + 0.22*w
  local hi = (i==9) and 2 or b - 0.22*w
  bands[#bands+1] = {lo, hi, SUNT[i]}
  if i < 9 then
    local b2 = (i+2 <= #E) and E[i+2] or 1.0
    local w2 = b2 - E[i+1]
    bands[#bands+1] = {hi, b + 0.22*w2, mixrec(SUNT[i], SUNT[i+1], 0.5)}
  end
end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end
local disc = ellipse(CX,CY,0.975*R,0.975*R)
local vis = disc - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - SAILM - LAMP:grow(1)
for k,bd in ipairs(bands) do
  local lo, hi = bd[1], bd[2]
  local m = mask(function(x,y) local u = ueff(x,y); return (u>=lo and u<hi) and 1 or 0 end) * vis
  if m:area() > 2 then
    work(m, {hand="body", pile=pile(bd[3]), coverage=3, fill=true, angle=rad, edge="soft", clip=vis})
  end
end
blend(vis, {angle=rad})

--@ chunk 85
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local SUNT = {
 {{"lead white",6},{"lemon chrome",0.7}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
local function norm(t) local s=0 for _,v in ipairs(t) do s=s+v[2] end local o={} for _,v in ipairs(t) do o[v[1]]=v[2]/s end return o end
local function mixrec(a, b, wa)
  local na, nb = norm(a), norm(b)
  local acc = {}
  for k,v in pairs(na) do acc[k]=(acc[k] or 0)+v*wa end
  for k,v in pairs(nb) do acc[k]=(acc[k] or 0)+v*(1-wa) end
  local o = {}
  for _,t in ipairs(a) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  for _,t in ipairs(b) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  return o
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local bands = {}
for i=1,9 do
  local a, b = E[i], (E[i+1] or 1.0)
  if i == 9 then b = 1.0 end
  local w = b - a
  local lo = (i==1) and -1 or a + 0.22*w
  local hi = (i==9) and 2 or b - 0.22*w
  bands[#bands+1] = {lo, hi, SUNT[i]}
  if i < 9 then
    local b2 = (i+2 <= #E) and E[i+2] or 1.0
    local w2 = b2 - E[i+1]
    bands[#bands+1] = {hi, b + 0.22*w2, mixrec(SUNT[i], SUNT[i+1], 0.5)}
  end
end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end

local disc = ellipse(CX,CY,0.975*R,0.975*R)
local low = mask(function(x,y) if x > 738 then return y > 252 and 1 or 0 else return y > 200 and 1 or 0 end end)
local m = SAILM * disc * low - SAILFRAME:grow(1)
for k,bd in ipairs(bands) do
  local lo, hi = bd[1], bd[2]
  local mm = mask(function(x,y) local u = ueff(x,y); return (u>=lo and u<hi) and 1 or 0 end) * m
  if mm:area() > 1 then
    work(mm, {hand="detail", pile=pile(bd[3]), coverage=3.5, fill=true, angle=rad})
  end
end
local vis = disc - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - LAMP:grow(1) - (SAILM - low)
blend(m:grow(10) * vis, {angle=rad})

--@ chunk 86
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local disc = ellipse(CX,CY,0.975*R,0.975*R)
local low = mask(function(x,y) if x > 738 then return y > 252 and 1 or 0 else return y > 200 and 1 or 0 end end)
local m = SAILM * disc * low - SAILFRAME:grow(1)
local vis = disc - below(hz) - FIG:grow(1.2) - SAILFRAME:grow(1) - LAMP:grow(1) - (SAILM - low)
blend(m:grow(12) * vis, {angle=rad, tool={kind="badger", width=16}})
blend(m:grow(12) * vis, {angle=function(x,y) return rad(x,y)+0.3 end, tool={kind="badger", width=16}})

--@ chunk 87
print(wait(5*24*60), drying(430,380), drying(300,300), drying(700,350), drying(780,400))

--@ chunk 88
local function sub(pts, t0, t1, ext)
  local n = #pts
  local res = {}
  for i=0,8 do
    local t = t0 + (t1-t0)*i/8
    local k = t*(n-1); local j = math.min(math.floor(k), n-2); local u = k-j
    local a, b = pts[j+1], pts[j+2]
    res[#res+1] = {a[1]+(b[1]-a[1])*u, a[2]+(b[2]-a[2])*u}
  end
  if ext then local a, b = res[#res-1], res[#res]; res[#res] = {b[1]+(b[1]-a[1])*ext, b[2]+(b[2]-a[2])*ext} end
  return res
end
local SAIL_TR = pile{{"bone brown",1},{"burnt sienna",0.8},{"Mars red",0.3},medium=0.45}
for i,sp in ipairs(SAILPATHS) do
  local pts = sp[1]
  local w = rand(5, 10)
  local f = brush{kind="flat", width=w}
  f:reload((i%3==0) and SAIL_TR or SAIL_DK, 0.95)
  local path = sub(pts, 0.3, 1.0, 1.5)
  for _,p in ipairs(path) do p[1] = p[1] + rand(-1.2,1.2) end
  f:stroke(path, {pressure={0.85, 0.05}, ramps={0.02, 0.45}, orient="across", swell={1,0.7,1.1,0.5,1,0.6,0.9}, shake=0.6})
  if math.random() < 0.7 then
    local r = brush{kind="round", width=2.4, point=0.8}
    r:reload(SAIL_DK, 0.8)
    local p2 = sub(pts, rand(0.5,0.8), 1.0, rand(1.5, 3.5))
    local off = rand(-5,5)
    for _,p in ipairs(p2) do p[1] = p[1] + off + rand(-0.8,0.8) end
    r:stroke(p2, {pressure={0.6, 0.0}, ramps={0.05, 0.6}})
  end
end

--@ chunk 89
local G = function(x,y) return (y-hz(x)) + 0.07*math.abs(x-430) end
local keep = FIG:grow(0.8) + LAMP:grow(0.8) + SAILFRAME:grow(0.8)
local hull = below(hz) - keep
local E3 = {-60, 4, 10, 18, 30}
local P3 = {BZ[1], BZ[2], BZ[3], BZ[4]}
local ang = function(x,y) return math.atan(hzd(x)) end
for i=1,4 do
  local lo,hi = E3[i],E3[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * hull
  work(m, {hand="body", tool={kind="filbert", width=6}, pile=P3[i], coverage=3, fill=true, angle=ang, edge=(i==4) and "soft" or "firm", clip=hull, length={20,60}})
end
for i=2,4 do
  local c = E3[i]; local w = math.max(2, (E3[i+1]-E3[i-1])*0.16)
  blend(mask(function(x,y) local v=G(x,y); return math.abs(v-c)<w and 1 or 0 end)*hull, {angle=ang, tool={kind="badger", width=14}})
end

--@ chunk 90
print(wait(4*24*60), drying(300,455), drying(600,470))
local G = function(x,y) return (y-hz(x)) + 0.07*math.abs(x-430) end
local keep = FIG:grow(0.8) + LAMP:grow(0.8) + SAILFRAME:grow(0.8)
local hull = below(hz) - keep
local ang = function(x,y) return math.atan(hzd(x)) end
local HOT0 = pile{{"lead white",2},{"cadmium yellow",1.2},{"lemon chrome",0.4},{"Mars orange",0.3}}
local E3 = {-60, 3.5, 8, 14}
local P3 = {HOT0, BZ[1], BZ[2]}
for i=1,3 do
  local lo,hi = E3[i],E3[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * hull
  work(m, {hand="body", tool={kind="filbert", width=4}, pile=P3[i], coverage=3.5, fill=true, angle=ang, edge="firm", clip=hull, length={15,40}})
end
for i=2,3 do
  local c = E3[i]
  blend(mask(function(x,y) local v=G(x,y); return math.abs(v-c)<1.8 and 1 or 0 end)*hull, {angle=ang, tool={kind="badger", width=8}})
end

--@ chunk 91
local keep = FIG:grow(0.8) + LAMP:grow(0.8) + SAILFRAME:grow(0.8)
local hull = below(hz) - keep
local ang = function(x,y) return math.atan(hzd(x)) end
HOT0 = pile{{"lead white",2},{"cadmium yellow",1.2},{"lemon chrome",0.4},{"Mars orange",0.3}}
local G = function(x,y) return (y-hz(x)) + 0.025*math.abs(x-440) end
local m = mask(function(x,y) local v=G(x,y); return (y >= hz(x) and v < 5) and 1 or 0 end) * hull
work(m, {hand="detail", pile=HOT0, coverage=3.5, fill=true, angle=ang})
local m2 = mask(function(x,y) local d = y-hz(x); return (d >= 0 and d < 2.2) and 1 or 0 end) * hull - m
work(m2, {hand="detail", pile=BZ[1], coverage=3.5, fill=true, angle=ang})

--@ chunk 92
print(hz(470), below(hz):at(470,445), below(hz):at(470,441))

--@ chunk 93
print(wait(4*24*60), drying(300,445), drying(600,470), drying(500,560), drying(100,600))

--@ chunk 94
local G = function(x,y) return (y-hz(x)) + 0.065*math.abs(x-430) end
local GE = {4,10,18,30,46,80,130}
local function lev(x,y) local v=G(x,y); for i,e in ipairs(GE) do if v<e then return i end end return 8 end
local shadow = poly({{362,494},{416,494},{426,530},{432,580},{438,640},{262,640},{300,580},{330,530}}, true)
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - LAMP:grow(2)
local d = 2.2
local k = 0
local n = 0
while d < 210 do
  k = k + 1
  local h = math.max(1.1, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.618 + k*0.11)%1)*w
  while x < 1010 do
    local ww = w*rand(0.82,1.18)
    local xc = x+ww/2
    local y = hz(xc) + d + rand(-0.12,0.12)*h
    if y - h < 640 and okm:at(xc, y) > 0.5 and okm:at(xc, y-h) > 0.5 then
      local L = lev(xc, y)
      local insh = shadow:at(xc, y) > 0.5
      if insh then L = math.min(L+1, 8) end
      scale_lip(xc, y, ww, h, L, BZ, {dstep = (L>=5) and 3 or 2, lstep = insh and 1 or 2, lit = (L>=5) and 0.09 or 0.13})
      n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.93,1.07)
end
print(n)

--@ chunk 95
FIG_DK2 = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.8},{"rose madder",0.2}}
work(FIG, {hand="detail", pile=FIG_DK2, coverage=4, fill=true, angle=math.pi/2})
work(FIG, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=FIG_DK2, coverage=3, fill=true, angle=0})

--@ chunk 96
print(wait(3*24*60), drying(390,450), drying(372,485), drying(400,480))

--@ chunk 97
print(wait(3*24*60), drying(390,450), drying(390,420), drying(400,480))

--@ chunk 98
local clipm = FIG:grow(0.4)
local function rimline(pts, p, w, pr)
  local b = brush{kind="round", width=w or 1.3, point=0.5}
  b:reload(p, 0.75)
  b:stroke(pts, {pressure={pr or 0.4, (pr or 0.4)*0.6}, ramps={0.15,0.3}, clip=clipm})
end
local HOT = pile{{"lead white",2},{"cadmium yellow",1.5},{"lemon chrome",0.4}}
-- head
rimline({{383.3,428},{382.8,421},{385,415},{388.5,412},{393,410.8}}, HOT, 1.4, 0.45)
rimline({{396,411.5},{400,413.8},{402.6,418},{403.3,423},{401.6,429}}, HOT, 1.3, 0.4)
-- neck sides
rimline({{385.6,438},{386,431}}, BZ[1], 1.0, 0.3)
rimline({{394.4,431},{395,438}}, BZ[1], 1.0, 0.3)
-- shoulders (pauldron tops)
rimline({{361.5,445},{363.5,440.5},{368,438.6},{373,439.5},{378,438.2}}, HOT, 1.4, 0.45)
rimline({{401,438.2},{406,438.8},{411,438.7},{414.5,441},{416.3,445}}, HOT, 1.4, 0.45)
-- left arm outer edge & knee
rimline({{361.2,446},{356,452},{351.5,458.5},{347,463},{345,467}}, BZ[1], 1.2, 0.4)
rimline({{345,468},{347,472.5},{351,474}}, BZ[2], 1.0, 0.3)
-- right arm outer edge
rimline({{416.6,447},{421.8,456},{425.6,465},{428.2,472},{432,480},{435.6,487},{437.6,492}}, BZ[1], 1.2, 0.4)

--@ chunk 99
F_B1 = pile{{"bone brown",1},{"burnt sienna",1},{"bone black",0.5}}
F_B2 = pile{{"bone brown",1},{"burnt sienna",1},{"bone black",0.3},{"Mars orange",0.3}}
F_PATCH = pile{{"bone black",1},{"lead white",0.25},{"ultramarine ash",0.4},{"burnt sienna",0.3}}
F_HAZ = pile{{"Mars orange",1},{"yellow ochre",1},{"bone brown",0.6}}
local inside = FIG:shrink(0.8)
-- warm bounce from the glowing hull on the lower back and the undersides
local lowback = poly({{371,488},{372,474},{386,470},{402,474},{404,488}}, true):soften(3) * inside
work(lowback, {hand="detail", pile=F_B1, coverage=1.6, fill=true, angle=0})
-- backpack housing outline: a slightly lighter plate with a bounce on its lower lip
local b = brush{kind="round", width=1.0, point=0.5}
local function line(pts, p, w, pr) b = brush{kind="round", width=w or 1.0, point=0.5}; b:reload(p, 0.7); b:stroke(pts, {pressure={pr or 0.35, pr or 0.35}, clip=inside}) end
line({{377,469.5},{383,470.6},{390,470.8},{397,470.2},{400,469}}, F_B2, 1.1, 0.4)
line({{376.6,447},{377,458},{377.3,468}}, F_B1, 0.8, 0.3)
line({{399.6,447},{399.3,458},{399,468}}, F_B1, 0.8, 0.3)
-- spine segments below the pack
for i=0,3 do local y = 474 + i*3.6; line({{385.5,y},{388.5,y+0.6},{391.5,y}}, F_B2, 0.9, 0.35) end
-- the mismatched repair plate (outpost grey) on the upper left back
local patch = poly({{371,448},{377,447.5},{377.5,457},{371.5,457.5}}) * inside
work(patch, {hand="detail", pile=F_PATCH, coverage=3, fill=true})
-- helmet seam ring and the back of the neck
line({{383.5,424},{388,425.5},{394,425.8},{400,424.6},{402.4,423}}, F_B1, 0.8, 0.3)
-- hazard band on the right upper arm, chipped
line({{416.5,455},{419.5,453.6},{422.6,453.2}}, F_HAZ, 1.3, 0.4)
line({{417.6,458.6},{420.6,457.2},{423.6,456.6}}, F_HAZ, 1.1, 0.35)
-- elbow joint: a small round disc catching the bounce
local elbow = ellipse(423.5,470.5,2.4,2.2) * inside
work(elbow, {hand="detail", pile=F_B2, coverage=2.5, fill=true})
local lelbow = ellipse(354,462,2.4,2.2) * inside
work(lelbow, {hand="detail", pile=F_B1, coverage=2.5, fill=true})

--@ chunk 100
local inside = FIG:shrink(0.8)
local e = (ellipse(423.5,470.5,3.2,3) + ellipse(354,462,3.2,3)) * inside
for i=1,3 do work(e, {hand="detail", tool={kind="round", width=2}, blender=true, coverage=3, dips={1,0,1}}) end
local lb = poly({{369,490},{370,472},{386,467},{404,472},{406,490}}, true) * inside
for i=1,2 do work(lb, {hand="scumble", tool={kind="filbert", width=3}, blender=true, coverage=2.5, clip=lb, dips={1,0,1}}) end
blend(lb, {tool={kind="badger", width=6}, angle=0})

--@ chunk 101
print(wait(2*24*60), drying(388,480), drying(354,462))
local inside = FIG:shrink(0.6)
local lb = poly({{368,492},{369,471},{386,466},{405,471},{407,492}}, true) * inside
work(lb, {hand="detail", pile=FIG_DK2, coverage=4, fill=true, angle=0})
local e = (ellipse(423.5,470.5,3.4,3.2) + ellipse(354,462,3.4,3.2)) * inside
work(e, {hand="detail", pile=FIG_DK2, coverage=4, fill=true})

--@ chunk 102
OUT_DK = pile{{"bone black",1.5},{"bone brown",1},{"rose madder",0.3},{"lead white",0.15}}
local function box(x, w, h, tilt)
  local y0 = hz(x + w/2) + 1.5
  tilt = tilt or 0
  return poly({{x, y0}, {x + tilt, y0 - h}, {x + w + tilt, y0 - h}, {x + w, y0}})
end
local m = box(128, 22, 7.5) + box(150, 14, 11) + box(163, 26, 6) + box(189, 9, 9.5, 0.3) + box(197, 18, 5)
  + box(118, 11, 4.5)
-- mast with a cross-arm, and a dish
m = m + ribbon({{156,433},{157,410},{157.5,404}}, {1.3,1.0,0.8}) + ribbon({{152,413},{163,412}}, 0.7)
m = m + poly({{176,437},{180,429},{186,427},{189,429.5},{184,433}}, true) + ribbon({{181,436.5},{182,440}}, 1.0)
-- a crane arm leaning out
m = m + ribbon({{204,438},{214,424},{226,419}}, {1.2,1.0,0.8}) + ribbon({{226,419},{226.5,428}}, 0.5)
OUTPOST = m - below(function(x) return hz(x) + 0.5 end)
work(OUTPOST, {hand="detail", pile=OUT_DK, coverage=3.5, fill=true})

--@ chunk 103
local function box(x, w, h)
  local y0 = hz(x + w/2) + 1.5
  return poly({{x, y0}, {x, y0 - h}, {x + w, y0 - h}, {x + w, y0}})
end
local m = box(121, 8, 17) + box(129, 5, 12.5) + box(141, 6, 9.5)
  + box(199, 13, 9) + ellipse(205.5, 430.6, 6.5, 3.2)
  + box(168, 3, 13) + box(171, 6, 8)
  + ribbon({{134,433},{134,423}}, 0.7) + ribbon({{216,438},{220,431},{232,433},{236,439}}, 0.8)
m = m - below(function(x) return hz(x) + 0.5 end)
OUTPOST = OUTPOST + m
work(m, {hand="detail", pile=OUT_DK, coverage=3.5, fill=true})

--@ chunk 104
local m = OUTPOST:grow(1.5) - below(function(x) return hz(x) + 0.3 end)
for i=1,6 do work(m, {hand="detail", tool={kind="round", width=2.5}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 105
local m = OUTPOST:grow(2.5) - below(function(x) return hz(x) + 0.3 end)
for i=1,8 do work(m, {hand="detail", tool={kind="round", width=3}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 106
print(wait(4*24*60), drying(170,430), drying(700,350), drying(780,400), drying(390,450))

--@ chunk 107
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local function band(x,y) local u = ueff(x,y); for i=1,9 do if u < (E[i+1] or 1) then return i end end return 9 end
local disc = ellipse(CX,CY,0.975*R,0.975*R)
local low = mask(function(x,y) if x > 738 then return y > 255 and 1 or 0 else return y > 205 and 1 or 0 end end)
local region = ((SAILM:grow(4) * low) + (OUTPOST:grow(5) - below(function(x) return hz(x)+0.3 end))) * disc - SAILFRAME:grow(1) - FIG:grow(1)
SUNFIX = region
local b = brush{kind="filbert", width=5}
local n = 0
for i=1,2600 do
  local x, y = rand(100, 820), rand(205, 450)
  if region:at(x,y) > 0.5 then
    local a = rad(x,y)
    local L = rand(8, 22)
    local k = band(x,y)
    local p = SUNP[math.max(1, k - (math.random() < 0.55 and 1 or 0))]
    b:reload(p, rand(0.5,0.8))
    b:stroke({{x - L/2*math.cos(a), y - L/2*math.sin(a)}, {x + L/2*math.cos(a), y + L/2*math.sin(a)}}, {pressure={0.6,0.4}, clip=region})
    n = n + 1
  end
end
print(n)
blend(region:grow(5) * disc - SAILFRAME:grow(1) - FIG:grow(1) - below(hz), {angle=rad, tool={kind="badger", width=12}})

--@ chunk 108
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local disc = ellipse(CX,CY,0.975*R,0.975*R)
local m = (SUNFIX:grow(10)) * disc - SAILFRAME:grow(1) - FIG:grow(1) - below(hz)
blend(m, {angle=rad, tool={kind="badger", width=20}})
blend(m, {angle=function(x,y) return rad(x,y) + 0.15 end, tool={kind="badger", width=20}})

--@ chunk 109
print(wait(5*24*60), drying(160,425), drying(700,300), drying(780,400), drying(390,450))

--@ chunk 110
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local region = (ellipse(150,420,48,28) + ellipse(195,428,40,20)) - below(function(x) return hz(x)+0.3 end)
local b = brush{kind="filbert", width=5}
local n = 0
for i=1,1800 do
  local x, y = rand(95, 240), rand(385, 448)
  if region:at(x,y) > 0.5 then
    local a = rad(x,y)
    local L = rand(10, 24)
    local r = math.random()
    local p = r < 0.45 and SUNP[4] or (r < 0.8 and SUNP[5] or SUNP[3])
    b:reload(p, rand(0.6,0.9))
    b:stroke({{x - L/2*math.cos(a), y - L/2*math.sin(a)}, {x + L/2*math.cos(a), y + L/2*math.sin(a)}}, {pressure={0.65,0.45}, clip=region})
    n = n + 1
  end
end
print(n)
blend(region:grow(6) - below(hz), {angle=rad, tool={kind="badger", width=10}})

--@ chunk 111
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local region = (ellipse(150,420,60,36) + ellipse(195,428,50,28)) - below(function(x) return hz(x)+0.3 end)
blend(region, {angle=rad, tool={kind="badger", width=24}})
blend(region, {angle=function(x,y) return rad(x,y)+1.2 end, tool={kind="badger", width=24}})
blend(region, {angle=rad, tool={kind="badger", width=16}})

--@ chunk 112
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local edge = ((ellipse(150,420,66,42) + ellipse(195,428,56,34)) - (ellipse(150,420,50,26) + ellipse(195,428,40,18))) - below(function(x) return hz(x)+1 end)
blend(edge, {angle=rad, tool={kind="badger", width=10}, clip=false})
blend(edge, {angle=function(x,y) return rad(x,y)+0.6 end, tool={kind="badger", width=10}, clip=false})

--@ chunk 113
local box = rect(20,240,320,360)
local core = (ellipse(150,420,52,28) + ellipse(195,428,42,20)) - below(function(x) return hz(x)+0.5 end)
local m = box - core
for i=1,5 do work(m, {hand="scumble", tool={kind="filbert", width=5}, blender=true, coverage=2.5, clip=m, dips={1,0,1}}) end

--@ chunk 114
print(drying(120,480), drying(230,500), drying(150,300))

--@ chunk 115
local side = mask(function(x,y) return ((x-CX)*(180-CY) - (y-CY)*(330-CX)) > 0 and 1 or 0 end); print(side:at(100,300), side:at(600,300), side:at(350,440), side:at(380,440))

--@ chunk 116
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local SUNT = {
 {{"lead white",6},{"lemon chrome",0.7}},
 {{"lead white",3},{"lemon chrome",1},{"cadmium yellow",1}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"Mars red",1},{"Mars orange",0.5}},
 {{"Mars red",1},{"rose madder",1},{"burnt sienna",0.5}},
}
local function norm(t) local s=0 for _,v in ipairs(t) do s=s+v[2] end local o={} for _,v in ipairs(t) do o[v[1]]=v[2]/s end return o end
local function mixrec(a, b, wa)
  local na, nb = norm(a), norm(b)
  local acc = {}
  for k,v in pairs(na) do acc[k]=(acc[k] or 0)+v*wa end
  for k,v in pairs(nb) do acc[k]=(acc[k] or 0)+v*(1-wa) end
  local o = {}
  for _,t in ipairs(a) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  for _,t in ipairs(b) do if acc[t[1]] then o[#o+1] = {t[1], acc[t[1]]}; acc[t[1]] = nil end end
  return o
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local bands = {}
for i=1,9 do
  local a, b = E[i], (E[i+1] or 1.0)
  if i == 9 then b = 1.0 end
  local w = b - a
  local lo = (i==1) and -1 or a + 0.22*w
  local hi = (i==9) and 2 or b - 0.22*w
  bands[#bands+1] = {lo, hi, SUNT[i]}
  if i < 9 then
    local b2 = (i+2 <= #E) and E[i+2] or 1.0
    local w2 = b2 - E[i+1]
    bands[#bands+1] = {hi, b + 0.22*w2, mixrec(SUNT[i], SUNT[i+1], 0.5)}
  end
end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end

local disc = ellipse(CX,CY,0.975*R,0.975*R)
local side = mask(function(x,y) return ((x-CX)*(180-CY) - (y-CY)*(330-CX)) > 0 and 1 or 0 end)
local vis = disc * side - below(hz) - FIG:grow(1.2)
for k,bd in ipairs(bands) do
  local lo, hi = bd[1], bd[2]
  local m = mask(function(x,y) local u = ueff(x,y); return (u>=lo and u<hi) and 1 or 0 end) * vis
  if m:area() > 2 then
    work(m, {hand="body", pile=pile(bd[3]), coverage=3, fill=true, angle=rad, edge="soft", clip=vis})
  end
end
blend(vis, {angle=rad})

--@ chunk 117
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local dx, dy = 330-CX, 180-CY
local L = math.sqrt(dx*dx+dy*dy)
local seam = mask(function(x,y) local c = ((x-CX)*dy - (y-CY)*dx)/L; return math.abs(c) < 9 and 1 or 0 end) * ellipse(CX,CY,0.975*R,0.975*R) - below(hz) - FIG:grow(1.2)
blend(seam, {angle=function(x,y) return rad(x,y)+0.35 end, tool={kind="badger", width=10}})
blend(seam, {angle=rad, tool={kind="badger", width=10}})

--@ chunk 118
print(wait(5*24*60), drying(150,300), drying(340,300), drying(120,480), drying(390,450))

--@ chunk 119
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local function band(x,y) local u = ueff(x,y); for i=1,9 do if u < (E[i+1] or 1) then return i end end return 9 end
local SP = {} for i=1,9 do SP[i] = SUNP[i] end
local dx, dy = 330-CX, 180-CY
local L0 = math.sqrt(dx*dx+dy*dy)
local okm = ellipse(CX,CY,0.975*R,0.975*R) - below(function(x) return hz(x)+1 end) - FIG:grow(1.5)
local b = brush{kind="filbert", width=4.5}
local n = 0
for i=1,900 do
  local t = rand(0.0, 1.0)
  local px, py = CX + dx*t, CY + dy*t
  local off = randn(0, 9)
  local nx, ny = -dy/L0, dx/L0
  local x, y = px + nx*off, py + ny*off
  if okm:at(x,y) > 0.5 and y > 175 then
    local a = rad(x,y)
    local L = rand(18, 40)
    local k = band(x,y)
    local kk = clamp(k + (math.random() < 0.5 and 0 or (math.random()<0.5 and -1 or 1)), 1, 9)
    b:reload(SP[kk], rand(0.3,0.5))
    b:stroke({{x - L/2*math.cos(a), y - L/2*math.sin(a)}, {x, y}, {x + L/2*math.cos(a), y + L/2*math.sin(a)}}, {pressure={0.45,0.1}, ramps={0.25,0.5}, clip=okm})
    n = n + 1
  end
end
print(n)

--@ chunk 120
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local function band(x,y) local u = ueff(x,y); for i=1,9 do if u < (E[i+1] or 1) then return i end end return 9 end
local okm = ellipse(CX,CY,0.975*R,0.975*R) - below(function(x) return hz(x)+1 end) - FIG:grow(1.5) - SAILFRAME:grow(1)
local b = brush{kind="filbert", width=4.5}
local n = 0
for i=1,6000 do
  local x, y = rand(0, 1000), rand(165, 470)
  if okm:at(x,y) > 0.5 then
    local a = rad(x,y)
    local L = rand(16, 42)
    local k = band(x,y)
    local kk = clamp(k + (math.random() < 0.5 and 0 or (math.random()<0.55 and -1 or 1)), 1, 9)
    b:reload(SUNP[kk], rand(0.25,0.45))
    b:stroke({{x - L/2*math.cos(a), y - L/2*math.sin(a)}, {x, y}, {x + L/2*math.cos(a), y + L/2*math.sin(a)}}, {pressure={0.42,0.08}, ramps={0.25,0.5}, clip=okm})
    n = n + 1
    if n >= 2600 then break end
  end
end
print(n)

--@ chunk 121
local rad = function(x,y) return math.atan(y-CY,x-CX) end
local okm = ellipse(CX,CY,0.975*R,0.975*R) - below(function(x) return hz(x)+1 end) - FIG:grow(1.5) - SAILFRAME:grow(1)
blend(okm, {angle=rad})

--@ chunk 122
print(wait(5*24*60), drying(150,300), drying(500,400), drying(700,300), drying(120,480))

--@ chunk 123
local G = function(x,y) return (y-hz(x)) + 0.065*math.abs(x-430) end
local GE = {-99,4,10,18,30,46,80,130,999}
local ang = function(x,y) return math.atan(hzd(x)) end
local shadow = poly({{362,494},{416,494},{426,530},{432,580},{438,640},{262,640},{300,580},{330,530}}, true)
HPATCH = (rect(30, 436, 290, 210) - shadow:grow(2)) * below(hz) - FIG:grow(1)
local hull = HPATCH
for i=1,8 do
  local lo,hi = GE[i],GE[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * hull
  if m:area() > 2 then
    work(m, {hand="body", tool={kind="filbert", width=6}, pile=BZ[i], coverage=3.5, fill=true, angle=ang, edge="soft", clip=hull, length={20,60}})
  end
end
for i=2,8 do
  local c = GE[i]; local w = math.max(2, (GE[i+1]-GE[i-1])*0.14)
  local m = mask(function(x,y) local v=G(x,y); return math.abs(v-c)<w and 1 or 0 end)*hull
  if m:area() > 2 then blend(m, {angle=ang, tool={kind="badger", width=14}}) end
end

--@ chunk 124
local strip = (above(function(x) return hz(x) - 0.2 end) - above(function(x) return hz(x) - 14 end)) * rect(0, 400, 345, 60) - FIG:grow(1)
for i=1,6 do work(strip, {hand="detail", tool={kind="round", width=2.5}, blender=true, coverage=3, clip=strip, dips={1,0,1}}) end

--@ chunk 125
local G = function(x,y) return (y-hz(x)) + 0.035*math.abs(x-430) end
local GE = {-99,3,7,13,21,32,46}
local PP = {HOT0, BZ[1], BZ[2], BZ[3], BZ[4], BZ[5]}
local ang = function(x,y) return math.atan(hzd(x)) end
local zone = below(hz) * mask(function(x,y) return (y - hz(x)) < 52 and 1 or 0 end) - FIG:grow(1) - LAMP:grow(1.5) - SAILFRAME:grow(1)
for i=1,6 do
  local lo,hi = GE[i],GE[i+1]
  local m = mask(function(x,y) local v=G(x,y); return (v>=lo and v<hi) and 1 or 0 end) * zone
  if m:area() > 2 then
    work(m, {hand="body", tool={kind="filbert", width=5}, pile=PP[i], coverage=3.5, fill=true, angle=ang, edge="firm", clip=zone, length={20,60}})
  end
end
for i=2,6 do
  local c = GE[i]; local w = math.max(1.5, (GE[i+1]-GE[i-1])*0.14)
  local m = mask(function(x,y) local v=G(x,y); return math.abs(v-c)<w and 1 or 0 end)*zone
  if m:area() > 2 then blend(m, {angle=ang, tool={kind="badger", width=10}}) end
end

--@ chunk 126
print(wait(4*24*60), drying(150,460), drying(500,470), drying(200,560), drying(700,480))

--@ chunk 127
print(wait(4*24*60), drying(150,460), drying(500,470), drying(200,560), drying(300,490))

--@ chunk 128
print(wait(3*24*60), drying(200,560), drying(100,600), drying(280,520))

--@ chunk 129
BZ[9] = BZ[8]
local G = function(x,y) return (y-hz(x)) + 0.035*math.abs(x-430) end
local GE = {3,7,13,21,32,46,80,130}
local function lev(x,y) local v=G(x,y); for i,e in ipairs(GE) do if v<e then return i end end return 9 end
local shadow = poly({{362,494},{416,494},{426,530},{432,580},{438,640},{262,640},{300,580},{330,530}}, true)
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - LAMP:grow(2)
local d = 2.2
local k = 0
local n = 0
while d < 210 do
  k = k + 1
  local h = math.max(1.1, d*0.3)
  local w = h*3.1*rand(0.95,1.05)
  local x = -((k*0.382 + k*0.07)%1)*w
  while x < 1010 do
    local ww = w*rand(0.82,1.18)
    local xc = x+ww/2
    local y = hz(xc) + d + rand(-0.12,0.12)*h
    if y - h < 640 and okm:at(xc, y) > 0.5 and okm:at(xc, y-h) > 0.5 then
      local L = lev(xc, y) - 1; if L < 1 then L = 1 end
      local insh = shadow:at(xc, y) > 0.5
      if insh then L = math.min(L+1, 9) end
      scale_lip(xc, y, ww, h, L, BZ, {dstep = (L>=5) and 3 or 2, lstep = insh and 1 or 2, lit = (L>=5) and 0.09 or 0.13})
      n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.93,1.07)
end
print(n)

--@ chunk 130
local cover = ribbon({{812,47},{830,40},{850,38},{868,30},{884,20},{902,13},{922,12},{940,6}}, 9)
 + ribbon({{810,52},{826,57},{846,55},{866,60},{884,57},{900,64}}, 9)
 + ribbon({{600,131},{589,120},{579,104},{582,87},{594,73},{598,58},{591,44},{580,34}}, 9)
 + ribbon({{806,98},{822,91},{838,90},{852,82},{860,68},{872,58}}, 9)
 + ribbon({{812,240},{829,252},{850,258},{871,270},{893,276},{916,288},{934,304}}, 9)
 + ribbon({{948,150},{957,143},{966,147},{975,140}}, 9)
 + ribbon({{662,52},{671,47},{680,50},{689,44}}, 9)
 + ribbon({{812,46},{829,40},{848,37},{864,29},{879,17},{896,10},{912,8}}, 9)
 + ribbon({{801,300},{819,313},{843,321},{866,333},{890,338},{915,350},{934,367}}, 9)
 + ribbon({{806,96},{822,88},{840,86},{853,78},{860,64}}, 9)
cover = cover - SAILFRAME:grow(1) - SAILM:grow(1) - ellipse(CX,CY,R,R)
for i=1,5 do
  local a,b = R+SP2E[i], R+SP2E[i+1]
  local m = (ellipse(CX,CY,b,b) - ellipse(CX,CY,a,a)) * cover
  if m:area() > 1 then work(m, {hand="detail", pile=SP2[i], coverage=4, fill=true, angle=function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end}) end
end

--@ chunk 131
local SHRED = pile{{"bone black",1.2},{"bone brown",1},{"burnt sienna",0.4},{"rose madder",0.2}}
local function shred(x0, y0, L, sway, w, seed)
  local pts = {}
  local n = 10
  for i=0,n do
    local t = i/n
    local x = x0 + sway*math.sin(t*2.6 + seed) * t + sway*0.3*t
    pts[#pts+1] = {x, y0 + L*t}
  end
  local b = brush{kind="round", width=w, point=0.9}
  b:reload(SHRED, 0.95)
  b:stroke(pts, {pressure={0.75, 0.0}, ramps={0.02, 0.85}, swell={1,0.8,1,0.7,0.9,0.6,0.7}})
  local r = brush{kind="round", width=1.2, point=0.7}
  r:reload(GLINT1, 0.6)
  local e = {}
  local side = (seed % 2 == 0) and 1 or -1
  for i=2,8 do local p = pts[i]; local t=(i-1)/n; e[#e+1] = {p[1] + side*w*0.35*(1-t*0.8), p[2]} end
  r:stroke(e, {pressure={0.3, 0.0}, ramps={0.1, 0.6}})
end
shred(624, 214, 120, 7, 5, 1)
shred(652, 222, 70, -5, 4, 2)
shred(706, 236, 150, 9, 5.5, 3)
shred(728, 244, 95, -6, 4, 4)
shred(757, 258, 190, 10, 6, 5)
shred(772, 262, 120, -7, 4, 6)
shred(690, 232, 55, 4, 3.5, 7)

--@ chunk 132
local SHRED = pile{{"bone black",1.2},{"bone brown",1},{"burnt sienna",0.4},{"rose madder",0.2}}
local function tongue(x0, ytop, ybot, sway, w, seed)
  local pts = {}
  local n = 10
  for i=0,n do
    local t = i/n
    local x = x0 + sway*math.sin(t*2.6 + seed) * t * 0.6
    pts[#pts+1] = {x, ytop + (ybot-ytop)*t}
  end
  local b = brush{kind="filbert", width=w}
  b:reload(SHRED, 1.0)
  b:stroke(pts, {pressure={0.85, 0.05}, ramps={0.02, 0.7}, orient="across", swell={1,1,0.9,0.95,0.8,0.7,0.6}})
end
tongue(624, 180, 280, 7, 9, 1)
tongue(652, 190, 255, -5, 7, 2)
tongue(706, 195, 330, 9, 10, 3)
tongue(728, 205, 290, -6, 7, 4)
tongue(757, 215, 380, 10, 11, 5)
tongue(772, 222, 320, -7, 7, 6)
tongue(690, 200, 260, 4, 6, 7)

--@ chunk 133
print(wait(2*24*60), drying(448,489), drying(450,500))

--@ chunk 134
local LH = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.3}}
work(LAMP, {hand="detail", pile=LH, coverage=4, fill=true})
local stalk = ribbon({{449,482},{449.5,477},{450,474.5}}, {1.0,0.8,0.7})
work(stalk, {hand="detail", pile=LH, coverage=3, fill=true})
local band = rect(443.8,487.2,8.4,4.2)
work(band, {hand="detail", pile=pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.6}}, coverage=4, fill=true, angle=0})
local core = ellipse(448,489.3,3.0,1.4)
work(core, {hand="detail", pile=pile{{"lead white",4},{"cadmium yellow",1},{"lemon chrome",0.3}}, coverage=4, fill=true, angle=0})
-- pool on the hull, kept off the housing and hand
local avoid = LAMP:grow(0.3) + FIG:grow(0.5)
local m = ellipse(450,497,17,6) - avoid
work(m, {hand="body", tool={kind="filbert", width=4}, pile=GLOWP, coverage=2, load=0.5, angle=0, clip=m, length={5,12}})
local mb = ellipse(450,497,30,11) - avoid
blend(mb, {angle=0, tool={kind="badger", width=10}})
blend(mb, {angle=1.0, tool={kind="badger", width=10}})

--@ chunk 135
local m = ellipse(450,497,33,13) - LAMP:grow(0.3) - FIG:grow(0.5); for i=1,6 do work(m, {hand="scumble", tool={kind="filbert", width=3}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 136
print(wait(2*24*60), drying(448,489), drying(446,486), drying(700,300))

--@ chunk 137
print(wait(3*24*60), drying(448,489), drying(446,486), drying(448,484))

--@ chunk 138
local band = rect(443.8,487.2,8.4,4.2)
work(band, {hand="detail", pile=pile{{"cadmium yellow",1},{"Mars orange",1},{"cadmium red",0.3}}, coverage=4, fill=true, angle=0})

--@ chunk 139
local core = ellipse(448,489.3,2.8,1.3)
work(core, {hand="detail", pile=pile{{"lead white",4},{"cadmium yellow",1.2},{"lemon chrome",0.4}}, coverage=5, fill=true, angle=0})
local b = brush{kind="round", width=1.6, point=0.4}
b:reload(pile{{"lead white",4},{"lemon chrome",0.5}}, 0.9)
b:touch(448, 489.3, {pressure=0.6})

--@ chunk 140
local WARM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.8}}
local WARM2 = pile{{"Mars orange",1},{"cadmium red",0.3},{"burnt sienna",0.5},{"lead white",0.3}}
local b = brush{kind="round", width=1.1, point=0.6}
local function ln(pts, p, pr) b:reload(p, 0.7); b:stroke(pts, {pressure={pr, pr*0.5}, ramps={0.2,0.4}}) end
ln({{439.3,491.6},{440.2,493.8},{439.8,496}}, WARM, 0.35)
ln({{436.6,486.5},{438.2,489.2},{439.2,491}}, WARM2, 0.3)
-- light on the hull at the foot of the lamp
ln({{441,497.2},{437,497.6},{433,498.4}}, WARM2, 0.3)
ln({{455.5,496.8},{461,497.4},{466,498.6}}, WARM, 0.32)
ln({{454.5,498.6},{458,500},{461,502.2}}, WARM2, 0.25)
-- the near lips catch the lamp
local function arc(cx, cy, w, h, p, pr)
  local pts = {}
  for i=2,8 do local th = math.pi*i/10; pts[#pts+1] = {cx + w/2*math.cos(th), cy - h + h*math.sin(th)} end
  ln(pts, p, pr)
end
arc(462, 505, 11, 3.0, WARM2, 0.28)
arc(450, 507, 11, 3.0, WARM, 0.3)
arc(438, 507.5, 10, 3.0, WARM2, 0.25)
arc(472, 503, 10, 2.8, WARM2, 0.2)
arc(456, 515, 12, 3.4, WARM2, 0.22)
arc(444, 516, 12, 3.4, WARM2, 0.2)
arc(469, 498.5, 8, 2.2, WARM2, 0.2)

--@ chunk 141
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local holes = {
  {632,150,3.5,9}, {640,182,2.5,6}, {700,140,4,12}, {716,170,2.2,8}, {745,128,3,7},
  {771,160,3.5,14}, {788,196,2.5,9}, {686,196,2,6}, {760,210,2,7}, {620,200,2.5,8}
}
local core = SAILM:shrink(2) - SAILFRAME:grow(1)
for i,h in ipairs(holes) do
  local x,y,a,b = h[1],h[2],h[3],h[4]
  local m = poly({{x-a,y-b*0.8},{x+a*0.3,y-b},{x+a,y-b*0.2},{x+a*0.6,y+b*0.7},{x-a*0.2,y+b},{x-a*0.9,y+b*0.3}}, false):roughen(0.8, 4, i*11) * core
  if m:area() > 1 then
    work(m, {hand="detail", pile=bgpile(x,y), coverage=4, fill=true, angle=tang(x,y)})
  end
end
-- lit tear edges: a hot hairline on the lower lip of each hole
local r = brush{kind="round", width=0.9, point=0.6}
for i,h in ipairs(holes) do
  local x,y,a,b = h[1],h[2],h[3],h[4]
  r:reload((i%2==0) and GLINT1 or RIM_HOT, 0.6)
  r:stroke({{x-a*0.9,y+b*0.35},{x-a*0.2,y+b*1.05},{x+a*0.6,y+b*0.75}}, {pressure={0.3,0.1}})
end

--@ chunk 142
local okm = below(hz) - FIG:grow(1.5) - SAILFRAME:grow(1.5) - LAMP:grow(2)
local b = brush{kind="round", width=1.3, point=0.5}
local n = 0
for i=1,1400 do
  local x = rand(0, 1000)
  local dd = math.abs(randn(0, 4)) + 0.6
  local y = hz(x) + dd
  local w = math.exp(-((x-440)/300)^2)
  if math.random() < w and okm:at(x,y) > 0.5 then
    local len = rand(1.2, 4.5)
    b:reload((math.random() < 0.6) and GLINT1 or RIM_HOT, 0.6)
    local s = hzd(x)
    b:stroke({{x-len/2, y - s*len/2}, {x+len/2, y + s*len/2}}, {pressure={0.22,0.22}, swell={0.4,1.2,0.4}})
    n = n + 1
  end
end
print(n)

--@ chunk 143
local STAR = pile{{"lead white",4},{"zinc white",1},{"cerulean blue",0.15}}
local STAR2 = pile{{"lead white",3},{"Mars orange",0.2},{"bone black",0.3}}
local far = -(ellipse(CX,CY,R+190,R+190)) - SAILFRAME:grow(3) - SAILM:grow(3)
local b = brush{kind="round", width=1.0, point=0.8}
local n = 0
for i=1,400 do
  local x, y = rand(5, 995), rand(5, 300)
  if far:at(x,y) > 0.5 then
    local d = math.sqrt((x-CX)^2+(y-CY)^2) - R
    if math.random() < (d-190)/160 then
      b:reload(math.random()<0.6 and STAR2 or STAR, 0.5)
      b:touch(x, y, {pressure=rand(0.08,0.22)})
      n = n + 1
      if n >= 34 then break end
    end
  end
end
local bb = brush{kind="round", width=1.6, point=0.6}
for _,p in ipairs({{88,38},{212,16},{942,58}}) do
  if far:at(p[1],p[2]) > 0.5 then bb:reload(STAR, 0.7); bb:touch(p[1], p[2], {pressure=0.35}) end
end
print(n)

--@ chunk 144
local foot = poly({{782,509},{785,500},{799,500},{802,509}}) + ellipse(792,509,13,2.6)
work(foot, {hand="detail", pile=MAST_DK, coverage=4, fill=true})
local function cable(a, b, sag, w)
  local pts = {}
  for i=0,12 do local t=i/12; pts[#pts+1] = {a[1]+(b[1]-a[1])*t, a[2]+(b[2]-a[2])*t + sag*4*t*(1-t)} end
  local r = brush{kind="round", width=w, point=0.6}
  r:reload(MAST_DK, 0.9)
  r:stroke(pts, {pressure={0.35,0.3}})
end
cable({807,150}, {872,518}, 6, 1.0)
cable({797,330}, {754,505}, 3, 0.9)
local anc = ellipse(872,518,3,1.2) + ellipse(754,505.5,2.6,1.1)
work(anc, {hand="detail", pile=MAST_DK, coverage=4, fill=true})
-- contact shadow toward the viewer
local sh = poly({{780,510},{804,510},{812,540},{790,560},{772,540}}, true):soften(5)
work(sh, {hand="body", pile=SHD, coverage=1.5, load=0.4, angle=math.pi/2, clip=sh})

--@ chunk 145
local m = poly({{776,511},{808,511},{816,542},{792,564},{768,542}}, true) - ellipse(792,509,13,2.8); for i=1,5 do work(m, {hand="scumble", tool={kind="filbert", width=4}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 146
local GLW = pile{{"Mars orange",1},{"cadmium yellow",0.7},{"lead white",0.5}}
local cx, cy = 448, 494
local m = ellipse(cx, cy+2, 26, 12) - LAMP:grow(0.6) - FIG:grow(0.6)
stipple(m, {pile=GLW, width=1.4, coverage=function(x,y) local d = math.sqrt(((x-cx)/26)^2 + ((y-cy-2)/12)^2); return 1.3*math.max(0, 1-d)^2 end, feather=1, pressure={0.15,0.35}, dips={12,0.5,0.3}})

--@ chunk 147
local sh = poly({{443,496},{454,496},{460,520},{464,548},{434,548},{437,520}}, true):soften(5) - LAMP:grow(0.3)
work(sh, {hand="body", tool={kind="filbert", width=5}, pile=SH, coverage=2, angle=math.pi/2, load=0.5, clip=sh})
blend(sh:grow(3) - LAMP:grow(0.3) - FIG:grow(0.5), {angle=math.pi/2, tool={kind="badger", width=8}})

--@ chunk 148
local m = poly({{441,496},{456,496},{463,520},{468,552},{430,552},{434,520}}, true) - LAMP:grow(0.3) - FIG:grow(0.5); for i=1,6 do work(m, {hand="scumble", tool={kind="filbert", width=4}, blender=true, coverage=3, clip=m, dips={1,0,1}}) end

--@ chunk 149
print(wait(14*24*60))
