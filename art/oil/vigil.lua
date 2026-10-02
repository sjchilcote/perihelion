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

--@ chunk 150
print(wait(60)); print(drying(430,300), drying(390,460), drying(700,250))

--@ chunk 151
OCC_RUNS = {}
STRIP_RUNS = {}
OCC_RUNS[366]={611.25,612.92}
STRIP_RUNS[366]={611.25,612.92}
OCC_RUNS[367]={611.25,615.0}
STRIP_RUNS[367]={611.25,615.0}
OCC_RUNS[368]={611.25,617.08}
STRIP_RUNS[368]={611.25,617.08}
OCC_RUNS[369]={611.25,618.75}
STRIP_RUNS[369]={611.25,618.75}
OCC_RUNS[370]={611.25,620.83}
STRIP_RUNS[370]={611.25,620.83}
OCC_RUNS[371]={611.25,622.92}
STRIP_RUNS[371]={611.25,622.92}
OCC_RUNS[372]={611.25,624.58}
STRIP_RUNS[372]={611.25,624.58}
OCC_RUNS[373]={611.25,626.67}
STRIP_RUNS[373]={611.25,626.67}
OCC_RUNS[374]={611.67,628.33}
STRIP_RUNS[374]={611.67,628.33}
OCC_RUNS[375]={611.67,630.42}
STRIP_RUNS[375]={611.67,630.42}
OCC_RUNS[376]={611.67,632.08}
STRIP_RUNS[376]={611.67,632.08}
OCC_RUNS[377]={611.67,632.5}
STRIP_RUNS[377]={611.67,632.5}
OCC_RUNS[378]={612.08,632.5,635.0,635.83}
STRIP_RUNS[378]={612.08,632.5,635.0,635.83}
OCC_RUNS[379]={612.08,632.5,635.0,637.5}
STRIP_RUNS[379]={612.08,632.5,635.0,637.5}
OCC_RUNS[380]={612.08,632.5,635.42,639.58}
STRIP_RUNS[380]={612.08,632.5,635.42,639.58}
OCC_RUNS[381]={612.08,632.5,635.42,641.25}
STRIP_RUNS[381]={612.08,632.5,635.42,641.25}
OCC_RUNS[382]={612.08,632.5,635.42,642.92}
STRIP_RUNS[382]={612.08,632.5,635.42,642.92}
OCC_RUNS[383]={612.5,620.0,621.25,632.5,635.42,644.58}
STRIP_RUNS[383]={612.5,620.0,621.25,632.5,635.42,644.58}
OCC_RUNS[384]={612.5,620.0,621.25,632.5,635.42,645.0,645.42,646.25}
STRIP_RUNS[384]={612.5,620.0,621.25,632.5,635.42,645.0,645.42,646.25}
OCC_RUNS[385]={612.5,619.58,620.83,632.5,635.42,645.0,645.42,647.92}
STRIP_RUNS[385]={612.5,619.58,620.83,632.5,635.42,645.0,645.42,647.92}
OCC_RUNS[386]={612.92,619.17,620.83,632.5,635.42,645.0,645.42,649.58}
STRIP_RUNS[386]={612.92,619.17,620.83,632.5,635.42,645.0,645.42,649.58}
OCC_RUNS[387]={612.92,618.33,620.83,632.5,635.83,645.0,645.42,651.25}
STRIP_RUNS[387]={612.92,618.33,620.83,632.5,635.83,645.0,645.42,651.25}
OCC_RUNS[388]={612.92,617.5,621.25,632.5,635.83,652.92}
STRIP_RUNS[388]={612.92,617.5,621.25,632.5,635.83,652.92}
OCC_RUNS[389]={612.92,617.08,622.08,632.92,635.83,654.58}
STRIP_RUNS[389]={612.92,617.08,622.08,632.92,635.83,654.58}
OCC_RUNS[390]={613.33,617.08,622.08,632.92,635.83,656.25}
STRIP_RUNS[390]={613.33,617.08,622.08,632.92,635.83,656.25}
OCC_RUNS[391]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,657.92}
STRIP_RUNS[391]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,657.92}
OCC_RUNS[392]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,659.58}
STRIP_RUNS[392]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,659.58}
OCC_RUNS[393]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,660.83}
STRIP_RUNS[393]={613.33,617.08,622.08,632.92,635.83,645.42,645.83,660.83}
OCC_RUNS[394]={613.33,617.08,622.08,632.92,636.25,638.75,639.17,660.83}
STRIP_RUNS[394]={613.33,617.08,622.08,632.92,636.25,638.75,639.17,660.83}
OCC_RUNS[395]={613.75,617.08,622.5,632.92,636.25,638.75,639.17,660.83}
STRIP_RUNS[395]={613.75,617.08,622.5,632.92,636.25,638.75,639.17,660.83}
OCC_RUNS[396]={613.75,617.08,622.5,632.92,636.25,638.75,639.17,660.83}
STRIP_RUNS[396]={613.75,617.08,622.5,632.92,636.25,638.75,639.17,660.83}
OCC_RUNS[397]={613.75,617.08,622.92,632.92,636.25,638.75,639.17,645.83,646.25,660.83}
STRIP_RUNS[397]={613.75,617.08,622.92,632.92,636.25,638.75,639.17,645.83,646.25,660.83}
OCC_RUNS[398]={614.17,617.08,622.5,632.92,636.25,645.83,646.25,661.25}
STRIP_RUNS[398]={614.17,617.08,622.5,632.92,636.25,645.83,646.25,661.25}
OCC_RUNS[399]={614.17,617.08,622.5,632.92,636.25,645.83,646.25,661.25}
STRIP_RUNS[399]={614.17,617.08,622.5,632.92,636.25,645.83,646.25,661.25}
OCC_RUNS[400]={614.17,617.08,622.08,632.92,636.67,645.83,646.25,661.25}
STRIP_RUNS[400]={614.17,617.08,622.08,632.92,636.67,645.83,646.25,661.25}
OCC_RUNS[401]={614.58,617.08,622.08,632.92,636.67,638.75,639.17,646.25,646.67,661.25}
STRIP_RUNS[401]={614.58,617.08,622.08,632.92,636.67,638.75,639.17,646.25,646.67,661.25}
OCC_RUNS[402]={614.58,617.08,622.08,632.92,636.67,646.25,646.67,661.25}
STRIP_RUNS[402]={614.58,617.08,622.08,632.92,636.67,646.25,646.67,661.25}
OCC_RUNS[403]={614.58,617.92,622.5,633.33,636.67,646.25,646.67,661.25}
STRIP_RUNS[403]={614.58,617.92,622.5,633.33,636.67,646.25,646.67,661.25}
OCC_RUNS[404]={614.58,617.92,622.5,633.33,636.67,638.75,639.17,661.25,677.08,677.92}
STRIP_RUNS[404]={614.58,617.92,622.5,633.33,636.67,638.75,639.17,661.25,677.08,677.92}
OCC_RUNS[405]={614.58,615.0,615.83,617.5,617.92,618.33,622.5,633.33,637.08,646.67,647.08,661.25,677.08,679.58}
STRIP_RUNS[405]={615.83,617.5,622.5,633.33,637.08,646.67,647.08,661.25,677.08,679.58}
OCC_RUNS[406]={617.08,617.5,622.5,633.33,637.08,646.67,647.08,661.25,677.08,680.83}
STRIP_RUNS[406]={622.5,633.33,637.08,646.67,647.08,661.25,677.08,680.83}
OCC_RUNS[407]={622.08,633.33,637.08,646.67,647.08,661.67,677.08,682.5}
STRIP_RUNS[407]={622.08,633.33,637.08,646.67,647.08,661.67,677.08,682.5}
OCC_RUNS[408]={616.67,617.08,622.08,633.33,637.08,638.75,639.58,646.67,647.08,661.67,677.08,683.75}
STRIP_RUNS[408]={622.08,633.33,637.08,638.75,639.58,646.67,647.08,661.67,677.08,683.75}
OCC_RUNS[409]={622.08,633.33,637.5,638.75,639.58,661.67,677.08,685.0}
STRIP_RUNS[409]={622.08,633.33,637.5,638.75,639.58,661.67,677.08,685.0}
OCC_RUNS[410]={616.25,616.67,622.08,633.33,637.5,638.75,639.58,647.08,647.5,660.42,660.83,661.67,677.5,686.67}
STRIP_RUNS[410]={622.08,633.33,637.5,638.75,639.58,647.08,647.5,660.42,660.83,661.67,677.5,686.67}
OCC_RUNS[411]={616.25,616.67,622.08,633.33,637.5,638.75,639.58,647.08,647.5,660.42,660.83,661.67,677.5,687.92}
STRIP_RUNS[411]={622.08,633.33,637.5,638.75,639.58,647.08,647.5,660.42,660.83,661.67,677.5,687.92}
OCC_RUNS[412]={616.25,616.67,622.08,633.33,637.5,638.33,639.58,644.17,644.58,660.42,660.83,661.67,677.5,689.58}
STRIP_RUNS[412]={622.08,633.33,637.5,638.33,639.58,644.17,644.58,660.42,660.83,661.67,677.5,689.58}
OCC_RUNS[413]={615.83,616.25,621.25,630.42,631.67,633.33,637.92,638.33,639.58,644.17,644.58,660.42,660.83,661.67,677.5,690.83}
STRIP_RUNS[413]={621.25,630.42,631.67,633.33,639.58,644.17,644.58,660.42,660.83,661.67,677.5,690.83}
OCC_RUNS[414]={615.83,616.25,620.83,630.42,637.92,638.33,639.58,660.42,660.83,661.67,677.5,692.08}
STRIP_RUNS[414]={620.83,630.42,639.58,660.42,660.83,661.67,677.5,692.08}
OCC_RUNS[415]={620.83,630.42,637.92,638.33,639.58,660.42,660.83,661.67,677.5,693.75}
STRIP_RUNS[415]={620.83,630.42,639.58,660.42,660.83,661.67,677.5,693.75}
OCC_RUNS[416]={620.42,630.42,637.92,638.33,639.58,662.08,677.5,695.0}
STRIP_RUNS[416]={620.42,630.42,639.58,662.08,677.5,695.0}
OCC_RUNS[417]={617.92,618.75,620.42,630.42,632.5,632.92,640.0,645.42,645.83,662.08,677.5,696.25}
STRIP_RUNS[417]={617.92,618.75,620.42,630.42,640.0,645.42,645.83,662.08,677.5,696.25}
OCC_RUNS[418]={617.92,618.75,619.58,630.42,631.67,632.92,640.0,644.58,645.0,645.42,645.83,662.08,677.5,697.5}
STRIP_RUNS[418]={617.92,618.75,619.58,630.42,631.67,632.92,640.0,644.58,645.83,662.08,677.5,697.5}
OCC_RUNS[419]={617.92,618.75,619.58,630.0,631.67,632.92,640.0,644.58,645.0,645.42,645.83,662.08,677.5,699.17}
STRIP_RUNS[419]={617.92,618.75,619.58,630.0,631.67,632.92,640.0,644.58,645.83,662.08,677.5,699.17}
OCC_RUNS[420]={617.5,618.75,619.17,630.0,631.67,632.92,640.0,642.08,643.33,645.42,645.83,662.08,677.5,700.42}
STRIP_RUNS[420]={617.5,618.75,619.17,630.0,631.67,632.92,640.0,642.08,643.33,645.42,645.83,662.08,677.5,700.42}
OCC_RUNS[421]={617.5,618.75,619.17,630.0,631.67,632.92,640.0,641.67,644.58,645.0,645.42,662.08,677.92,701.67}
STRIP_RUNS[421]={617.5,618.75,619.17,630.0,631.67,632.92,640.0,641.67,645.42,662.08,677.92,701.67}
OCC_RUNS[422]={617.5,617.92,618.33,618.75,619.17,630.0,631.67,632.08,632.5,632.92,640.0,641.67,646.67,662.08,677.92,702.92}
STRIP_RUNS[422]={619.17,630.0,640.0,641.67,646.67,662.08,677.92,702.92}
OCC_RUNS[423]={619.58,630.0,631.67,632.5,640.42,642.08,647.92,662.08,677.92,685.0,685.42,704.17}
STRIP_RUNS[423]={619.58,630.0,631.67,632.5,640.42,642.08,647.92,662.08,677.92,685.0,685.42,704.17}
OCC_RUNS[424]={619.58,630.0,631.67,632.08,640.42,642.08,647.92,662.08,677.92,685.0,685.42,705.42}
STRIP_RUNS[424]={619.58,630.0,640.42,642.08,647.92,662.08,677.92,685.0,685.42,705.42}
OCC_RUNS[425]={617.08,617.5,620.0,630.0,631.67,632.5,640.42,642.5,647.92,662.08,677.92,685.0,685.42,707.08}
STRIP_RUNS[425]={620.0,630.0,631.67,632.5,640.42,642.5,647.92,662.08,677.92,685.0,685.42,707.08}
OCC_RUNS[426]={620.0,630.0,631.67,632.5,640.42,642.08,647.92,662.5,677.92,685.0,685.42,708.33}
STRIP_RUNS[426]={620.0,630.0,631.67,632.5,640.42,642.08,647.92,662.5,677.92,685.0,685.42,708.33}
OCC_RUNS[427]={619.17,630.0,630.42,630.83,631.67,632.92,640.42,642.08,648.33,662.5,677.92,685.0,685.42,709.58}
STRIP_RUNS[427]={619.17,630.0,631.67,632.92,640.42,642.08,648.33,662.5,677.92,685.0,685.42,709.58}
OCC_RUNS[428]={618.75,630.0,631.67,632.08,632.5,632.92,640.83,641.25,647.5,647.92,648.33,662.5,677.92,710.83}
STRIP_RUNS[428]={618.75,630.0,648.33,662.5,677.92,710.83}
OCC_RUNS[429]={618.75,630.0,631.67,632.92,640.83,641.25,647.5,647.92,648.33,655.42,655.83,657.08,658.75,662.5,677.92,685.0,685.42,686.25,686.67,711.67}
STRIP_RUNS[429]={618.75,630.0,631.67,632.92,648.33,655.42,655.83,657.08,658.75,662.5,677.92,685.0,685.42,686.25,686.67,711.67}
OCC_RUNS[430]={619.17,630.0,647.5,647.92,648.33,655.42,656.25,657.08,660.0,662.5,677.92,685.0,685.42,711.67}
STRIP_RUNS[430]={619.17,630.0,648.33,655.42,656.25,657.08,660.0,662.5,677.92,685.0,685.42,711.67}
OCC_RUNS[431]={619.17,630.0,632.5,632.92,640.83,641.25,647.5,647.92,648.75,655.42,655.83,657.08,657.5,658.75,661.25,662.5,677.92,711.67}
STRIP_RUNS[431]={619.17,630.0,648.75,655.42,655.83,657.08,657.5,658.75,661.25,662.5,677.92,711.67}
OCC_RUNS[432]={619.17,630.0,632.5,632.92,647.5,647.92,648.75,655.42,655.83,657.08,657.5,657.92,678.33,711.25}
STRIP_RUNS[432]={619.17,630.0,648.75,655.42,655.83,657.08,678.33,711.25}
OCC_RUNS[433]={619.58,629.58,647.5,647.92,648.33,655.42,656.25,656.67,678.33,686.67,687.08,711.25}
STRIP_RUNS[433]={619.58,629.58,648.33,655.42,678.33,686.67,687.08,711.25}
OCC_RUNS[434]={619.58,629.58,642.5,642.92,647.08,647.92,648.75,655.42,678.33,685.0,685.42,686.25,687.08,711.25}
STRIP_RUNS[434]={619.58,629.58,647.08,647.92,648.75,655.42,678.33,685.0,685.42,686.25,687.08,711.25}
OCC_RUNS[435]={619.58,629.58,642.5,642.92,647.08,647.92,648.75,655.42,656.67,657.08,678.33,685.0,685.83,686.67,687.08,711.25}
STRIP_RUNS[435]={619.58,629.58,647.08,647.92,648.75,655.42,678.33,685.0,685.83,686.67,687.08,711.25}
OCC_RUNS[436]={619.58,629.58,647.08,647.92,648.75,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.0,720.83}
STRIP_RUNS[436]={619.58,629.58,647.08,647.92,648.75,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.0,720.83}
OCC_RUNS[437]={620.0,630.0,642.08,642.5,647.08,648.33,648.75,655.42,678.33,685.42,685.83,711.25,720.42,722.08}
STRIP_RUNS[437]={620.0,630.0,647.08,648.33,648.75,655.42,678.33,685.42,685.83,711.25,720.42,722.08}
OCC_RUNS[438]={620.0,629.58,642.08,642.5,647.5,648.33,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,723.33}
STRIP_RUNS[438]={620.0,629.58,647.5,648.33,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,723.33}
OCC_RUNS[439]={620.83,629.58,642.08,642.5,645.83,646.67,647.5,647.92,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,724.58}
STRIP_RUNS[439]={620.83,629.58,645.83,646.67,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,724.58}
OCC_RUNS[440]={620.83,629.58,645.42,646.67,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,725.42}
STRIP_RUNS[440]={620.83,629.58,645.42,646.67,649.17,655.42,678.33,685.42,685.83,686.67,687.08,711.25,720.42,725.42}
OCC_RUNS[441]={620.83,629.58,645.42,647.08,649.17,655.42,655.83,656.25,678.33,686.67,687.08,711.25,720.42,726.67}
STRIP_RUNS[441]={620.83,629.58,645.42,647.08,649.17,655.42,678.33,686.67,687.08,711.25,720.42,726.67}
OCC_RUNS[442]={620.83,629.58,644.58,645.0,645.42,647.08,649.58,655.42,678.33,686.67,687.08,711.25,720.42,727.92}
STRIP_RUNS[442]={620.83,629.58,645.42,647.08,649.58,655.42,678.33,686.67,687.08,711.25,720.42,727.92}
OCC_RUNS[443]={620.83,629.58,645.0,647.08,649.58,655.42,679.58,686.67,687.08,711.25,720.42,729.17}
STRIP_RUNS[443]={620.83,629.58,645.0,647.08,649.58,655.42,679.58,686.67,687.08,711.25,720.42,729.17}
OCC_RUNS[444]={620.83,629.58,644.58,647.08,649.58,655.42,681.25,685.42,686.25,686.67,687.08,711.25,720.42,730.42}
STRIP_RUNS[444]={620.83,629.58,644.58,647.08,649.58,655.42,681.25,685.42,687.08,711.25,720.42,730.42}
OCC_RUNS[445]={620.83,629.58,644.58,646.67,649.17,655.42,682.5,685.42,686.25,686.67,687.08,711.25,720.42,731.67}
STRIP_RUNS[445]={620.83,629.58,644.58,646.67,649.17,655.42,682.5,685.42,687.08,711.25,720.42,731.67}
OCC_RUNS[446]={620.83,629.58,644.58,646.25,649.58,655.42,683.33,685.42,686.25,686.67,687.08,693.33,693.75,711.25,720.42,732.92}
STRIP_RUNS[446]={620.83,629.58,644.58,646.25,649.58,655.42,683.33,685.42,687.08,693.33,693.75,711.25,720.42,732.92}
OCC_RUNS[447]={620.83,629.58,644.17,646.25,649.58,655.42,684.58,685.42,686.25,686.67,687.08,693.33,693.75,711.25,720.42,733.75}
STRIP_RUNS[447]={620.83,629.58,644.17,646.25,649.58,655.42,684.58,685.42,687.08,693.33,693.75,711.25,720.42,733.75}
OCC_RUNS[448]={620.83,629.58,644.17,645.83,650.0,655.42,687.08,693.33,693.75,711.25,720.42,735.0}
STRIP_RUNS[448]={620.83,629.58,644.17,645.83,650.0,655.42,687.08,693.33,693.75,711.25,720.42,735.0}
OCC_RUNS[449]={620.83,629.58,643.75,645.83,650.0,655.42,687.92,693.33,693.75,711.25,720.83,736.25}
STRIP_RUNS[449]={620.83,629.58,643.75,645.83,650.0,655.42,687.92,693.33,693.75,711.25,720.83,736.25}
OCC_RUNS[450]={620.83,629.58,643.33,645.42,650.0,655.42,687.92,693.33,693.75,711.25,720.83,737.5}
STRIP_RUNS[450]={620.83,629.58,643.33,645.42,650.0,655.42,687.92,693.33,693.75,711.25,720.83,737.5}
OCC_RUNS[451]={620.83,629.17,643.75,645.42,649.17,649.58,650.0,655.42,687.92,693.75,694.17,695.0,695.42,711.25,720.83,738.33}
STRIP_RUNS[451]={620.83,629.17,643.75,645.42,650.0,655.42,687.92,693.75,694.17,695.0,695.42,711.25,720.83,738.33}
OCC_RUNS[452]={620.83,629.58,643.33,645.42,649.17,649.58,650.0,655.42,687.92,693.75,694.17,694.58,695.42,711.25,720.83,739.58}
STRIP_RUNS[452]={620.83,629.58,643.33,645.42,650.0,655.42,687.92,693.75,695.42,711.25,720.83,739.58}
OCC_RUNS[453]={620.83,629.17,643.75,644.58,649.17,649.58,650.42,655.42,687.92,693.75,694.17,694.58,695.0,710.83,720.83,740.83}
STRIP_RUNS[453]={620.83,629.17,643.75,644.58,650.42,655.42,687.92,693.75,695.0,710.83,720.83,740.83}
OCC_RUNS[454]={620.83,629.17,644.17,645.0,649.17,649.58,650.42,655.42,688.33,693.75,695.42,710.83,720.83,742.08}
STRIP_RUNS[454]={620.83,629.17,644.17,645.0,650.42,655.42,688.33,693.75,695.42,710.83,720.83,742.08}
OCC_RUNS[455]={620.83,629.17,644.58,645.0,648.75,649.58,650.42,655.42,688.33,693.75,695.83,710.83,720.83,741.67}
STRIP_RUNS[455]={620.83,629.17,648.75,649.58,650.42,655.42,688.33,693.75,695.83,710.83,720.83,741.67}
OCC_RUNS[456]={620.83,629.17,644.17,645.0,650.42,655.42,688.33,693.75,697.08,710.83,720.83,741.67}
STRIP_RUNS[456]={620.83,629.17,644.17,645.0,650.42,655.42,688.33,693.75,697.08,710.83,720.83,741.67}
OCC_RUNS[457]={620.83,629.17,644.17,645.0,650.42,655.42,688.33,693.75,697.92,710.83,720.83,741.67}
STRIP_RUNS[457]={620.83,629.17,644.17,645.0,650.42,655.42,688.33,693.75,697.92,710.83,720.83,741.67}
OCC_RUNS[458]={620.83,629.17,644.58,645.42,647.08,647.5,648.75,649.17,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
STRIP_RUNS[458]={620.83,629.17,644.58,645.42,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
OCC_RUNS[459]={620.83,629.17,644.58,645.42,647.08,647.5,648.75,649.17,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
STRIP_RUNS[459]={620.83,629.17,644.58,645.42,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
OCC_RUNS[460]={620.83,628.75,645.0,645.83,646.25,646.67,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
STRIP_RUNS[460]={620.83,628.75,645.0,645.83,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
OCC_RUNS[461]={620.83,628.75,645.0,646.25,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
STRIP_RUNS[461]={620.83,628.75,645.0,646.25,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67}
OCC_RUNS[462]={621.25,628.75,645.0,646.25,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67,749.58,750.83}
STRIP_RUNS[462]={621.25,628.75,645.0,646.25,650.0,655.0,688.75,693.75,700.0,710.83,720.83,741.67,749.58,750.83}
OCC_RUNS[463]={621.25,629.17,645.42,645.83,650.0,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,751.67}
STRIP_RUNS[463]={621.25,629.17,650.0,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,751.67}
OCC_RUNS[464]={621.25,628.75,650.0,652.08,652.5,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,752.92}
STRIP_RUNS[464]={621.25,628.75,650.0,652.08,652.5,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,752.92}
OCC_RUNS[465]={621.25,629.17,649.58,651.67,652.5,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,754.17}
STRIP_RUNS[465]={621.25,629.17,649.58,651.67,652.5,655.0,688.75,693.75,700.0,710.42,720.83,742.08,749.58,754.17}
OCC_RUNS[466]={621.25,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,720.83,742.08,749.58,755.0}
STRIP_RUNS[466]={621.25,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,720.83,742.08,749.58,755.0}
OCC_RUNS[467]={621.25,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,720.83,742.08,749.58,756.25}
STRIP_RUNS[467]={621.25,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,720.83,742.08,749.58,756.25}
OCC_RUNS[468]={621.67,628.75,649.58,651.67,652.5,655.42,688.75,693.33,700.0,710.42,720.83,742.08,749.58,757.08}
STRIP_RUNS[468]={621.67,628.75,649.58,651.67,652.5,655.42,688.75,693.33,700.0,710.42,720.83,742.08,749.58,757.08}
OCC_RUNS[469]={621.67,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,721.25,742.08,749.58,758.33}
STRIP_RUNS[469]={621.67,628.75,649.58,651.67,652.5,655.0,688.75,693.33,700.0,710.42,721.25,742.08,749.58,758.33}
OCC_RUNS[470]={621.67,628.75,649.58,651.67,652.5,654.58,688.75,693.33,700.0,710.42,721.25,742.08,749.58,759.17}
STRIP_RUNS[470]={621.67,628.75,649.58,651.67,652.5,654.58,688.75,693.33,700.0,710.42,721.25,742.08,749.58,759.17}
OCC_RUNS[471]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.42,721.25,742.08,749.58,760.42}
STRIP_RUNS[471]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.42,721.25,742.08,749.58,760.42}
OCC_RUNS[472]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,742.08,749.58,761.25}
STRIP_RUNS[472]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,742.08,749.58,761.25}
OCC_RUNS[473]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,742.08,749.58,762.5}
STRIP_RUNS[473]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,742.08,749.58,762.5}
OCC_RUNS[474]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,733.75,734.17,742.08,749.58,763.75}
STRIP_RUNS[474]={621.67,628.33,649.58,651.67,652.5,654.58,689.17,693.33,700.0,710.0,721.25,733.75,734.17,742.08,749.58,763.75}
OCC_RUNS[475]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.0,721.25,742.08,749.58,764.58}
STRIP_RUNS[475]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.0,721.25,742.08,749.58,764.58}
OCC_RUNS[476]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.42,721.67,742.08,749.58,765.42}
STRIP_RUNS[476]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.42,721.67,742.08,749.58,765.42}
OCC_RUNS[477]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.42,722.08,742.5,749.58,766.67}
STRIP_RUNS[477]={622.08,628.33,649.58,651.67,652.5,654.58,689.58,693.33,700.0,710.42,722.08,742.5,749.58,766.67}
OCC_RUNS[478]={622.08,628.33,634.58,635.0,649.58,651.67,652.5,654.58,690.0,692.92,700.0,710.0,722.08,732.92,733.33,742.5,749.58,767.5}
STRIP_RUNS[478]={622.08,628.33,649.58,651.67,652.5,654.58,690.0,692.92,700.0,710.0,722.08,732.92,733.33,742.5,749.58,767.5}
OCC_RUNS[479]={622.08,627.92,634.58,635.0,649.58,651.67,652.92,654.58,690.0,692.92,700.0,710.0,722.08,725.0,725.83,732.92,733.33,742.5,749.58,768.75}
STRIP_RUNS[479]={622.08,627.92,649.58,651.67,652.92,654.58,690.0,692.92,700.0,710.0,722.08,725.0,725.83,732.92,733.33,742.5,749.58,768.75}
OCC_RUNS[480]={622.08,627.92,634.58,635.0,649.58,651.67,652.92,654.58,690.0,692.92,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,749.58,769.58}
STRIP_RUNS[480]={622.08,627.92,649.58,651.67,652.92,654.58,690.0,692.92,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,749.58,769.58}
OCC_RUNS[481]={622.08,627.92,634.58,635.0,649.58,651.67,652.5,654.58,690.0,693.33,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,749.58,770.83}
STRIP_RUNS[481]={622.08,627.92,649.58,651.67,652.5,654.58,690.0,693.33,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,749.58,770.83}
OCC_RUNS[482]={622.08,627.92,634.17,635.0,649.58,651.67,653.33,655.0,690.0,692.92,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,750.0,771.67}
STRIP_RUNS[482]={622.08,627.92,634.17,635.0,649.58,651.67,653.33,655.0,690.0,692.92,700.0,710.0,722.08,725.0,725.42,732.92,733.33,742.5,750.0,771.67}
OCC_RUNS[483]={622.5,627.92,633.75,634.58,649.58,652.08,653.33,654.17,690.0,692.92,700.42,710.0,721.67,725.0,725.83,732.92,733.33,734.17,734.58,742.5,750.0,772.92}
STRIP_RUNS[483]={622.5,627.92,633.75,634.58,649.58,652.08,653.33,654.17,690.0,692.92,700.42,710.0,721.67,725.0,725.83,732.92,733.33,734.17,734.58,742.5,750.0,772.92}
OCC_RUNS[484]={622.5,627.92,633.75,634.58,646.25,646.67,649.58,651.67,654.58,655.0,690.0,692.92,700.42,710.0,721.67,725.0,725.83,732.92,733.33,734.17,734.58,742.5,750.0,773.75}
STRIP_RUNS[484]={622.5,627.92,633.75,634.58,649.58,651.67,690.0,692.92,700.42,710.0,721.67,725.0,725.83,732.92,733.33,734.17,734.58,742.5,750.0,773.75}
OCC_RUNS[485]={622.5,627.92,633.75,634.58,645.83,646.67,649.58,651.67,653.33,653.75,690.0,692.5,700.42,710.0,721.67,724.58,725.0,732.92,733.33,734.17,734.58,742.5,750.0,774.58}
STRIP_RUNS[485]={622.5,627.92,633.75,634.58,645.83,646.67,649.58,651.67,690.0,692.5,700.42,710.0,721.67,724.58,725.0,732.92,733.33,734.17,734.58,742.5,750.0,774.58}
OCC_RUNS[486]={622.5,627.5,633.75,634.58,646.25,646.67,649.58,651.67,690.0,692.92,700.42,710.0,721.67,723.33,723.75,724.17,724.58,732.92,733.33,734.17,734.58,742.5,750.0,775.83}
STRIP_RUNS[486]={622.5,627.5,633.75,634.58,649.58,651.67,690.0,692.92,700.42,710.0,721.67,723.33,724.58,732.92,733.33,734.17,734.58,742.5,750.0,775.83}
OCC_RUNS[487]={622.5,627.5,631.67,632.08,633.75,634.58,649.58,651.67,690.0,692.5,700.42,710.0,721.67,724.17,724.58,725.42,725.83,732.92,734.58,742.5,750.0,776.67}
STRIP_RUNS[487]={622.5,627.5,633.75,634.58,649.58,651.67,690.0,692.5,700.42,710.0,721.67,724.17,724.58,725.42,725.83,732.92,734.58,742.5,750.0,776.67}
OCC_RUNS[488]={622.5,627.92,631.67,632.5,633.33,634.58,649.58,651.67,690.0,692.5,700.42,709.58,721.67,723.33,723.75,724.58,725.83,732.92,736.25,742.92,750.0,777.92}
STRIP_RUNS[488]={622.5,627.92,631.67,632.5,633.33,634.58,649.58,651.67,690.0,692.5,700.42,709.58,721.67,723.33,723.75,724.58,725.83,732.92,736.25,742.92,750.0,777.92}
OCC_RUNS[489]={622.5,627.92,631.67,632.5,633.33,634.17,650.0,651.67,653.75,654.17,690.42,692.5,700.42,709.58,721.67,724.17,725.83,732.92,737.08,742.92,750.0,778.75}
STRIP_RUNS[489]={622.5,627.92,631.67,632.5,633.33,634.17,650.0,651.67,690.42,692.5,700.42,709.58,721.67,724.17,725.83,732.92,737.08,742.92,750.0,778.75}
OCC_RUNS[490]={622.5,627.5,631.67,632.5,633.33,633.75,650.0,651.67,690.42,692.5,700.42,709.58,721.67,724.17,725.42,732.92,737.92,742.92,750.0,779.58}
STRIP_RUNS[490]={622.5,627.5,631.67,632.5,650.0,651.67,690.42,692.5,700.42,709.58,721.67,724.17,725.42,732.92,737.92,742.92,750.0,779.58}
OCC_RUNS[491]={622.5,627.92,631.25,632.5,633.33,633.75,650.0,651.67,653.75,654.17,690.0,692.5,700.42,709.58,721.67,722.5,722.92,724.17,725.42,732.92,738.75,742.92,750.0,780.83}
STRIP_RUNS[491]={622.5,627.92,631.25,632.5,650.0,651.67,690.0,692.5,700.42,709.58,721.67,722.5,722.92,724.17,725.42,732.92,738.75,742.92,750.0,780.83}
OCC_RUNS[492]={622.5,627.92,631.25,632.5,650.0,651.67,690.0,692.5,700.42,709.58,721.67,722.5,722.92,724.17,725.42,732.92,740.0,741.67,742.08,742.92,750.0,781.67}
STRIP_RUNS[492]={622.5,627.92,631.25,632.5,650.0,651.67,690.0,692.5,700.42,709.58,721.67,722.5,722.92,724.17,725.42,732.92,740.0,741.67,742.08,742.92,750.0,781.67}
OCC_RUNS[493]={622.5,627.5,631.25,632.5,650.0,651.67,655.0,655.42,690.0,692.08,700.42,709.58,721.67,722.08,722.5,724.17,725.83,732.92,741.67,742.92,750.0,782.5}
STRIP_RUNS[493]={622.5,627.5,631.25,632.5,650.0,651.67,690.0,692.08,700.42,709.58,722.5,724.17,725.83,732.92,741.67,742.92,750.0,782.5}
OCC_RUNS[494]={622.5,627.5,631.25,632.08,650.0,651.67,654.17,654.58,655.0,655.42,690.0,692.5,700.42,709.58,721.67,722.08,722.5,724.17,725.83,732.92,742.5,742.92,750.42,783.75}
STRIP_RUNS[494]={622.5,627.5,631.25,632.08,650.0,651.67,690.0,692.5,700.42,709.58,722.5,724.17,725.83,732.92,750.42,783.75}
OCC_RUNS[495]={622.5,627.5,631.25,632.08,650.42,651.67,654.17,654.58,655.0,655.42,690.42,692.08,700.42,709.58,722.5,724.17,725.83,732.92,750.42,784.58}
STRIP_RUNS[495]={622.5,627.5,631.25,632.08,650.42,651.67,690.42,692.08,700.42,709.58,722.5,724.17,725.83,732.92,750.42,784.58}
OCC_RUNS[496]={622.5,627.92,631.25,632.08,650.42,651.67,654.17,655.42,690.0,690.42,690.83,692.08,700.0,709.58,722.08,724.17,725.83,732.92,750.42,785.42}
STRIP_RUNS[496]={622.5,627.92,631.25,632.08,650.42,651.67,654.17,655.42,690.83,692.08,700.0,709.58,722.08,724.17,725.83,732.92,750.42,785.42}
OCC_RUNS[497]={622.5,627.92,630.83,632.08,650.42,651.67,654.58,655.42,690.0,690.42,690.83,692.08,700.0,709.58,722.08,723.75,725.83,732.92,750.42,786.67}
STRIP_RUNS[497]={622.5,627.92,630.83,632.08,650.42,651.67,654.58,655.42,690.83,692.08,700.0,709.58,722.08,723.75,725.83,732.92,750.42,786.67}
OCC_RUNS[498]={622.5,627.92,630.83,631.67,650.42,651.67,655.0,655.42,690.0,690.42,690.83,692.08,700.42,709.58,721.67,723.33,726.25,732.92,750.42,787.5}
STRIP_RUNS[498]={622.5,627.92,630.83,631.67,650.42,651.67,690.83,692.08,700.42,709.58,721.67,723.33,726.25,732.92,750.42,787.5}
OCC_RUNS[499]={622.5,627.92,630.83,631.67,650.42,651.67,655.0,655.42,690.42,692.5,700.42,709.58,721.67,723.33,726.25,732.5,750.42,788.33}
STRIP_RUNS[499]={622.5,627.92,630.83,631.67,650.42,651.67,690.42,692.5,700.42,709.58,721.67,723.33,726.25,732.5,750.42,788.33}
OCC_RUNS[500]={622.5,627.92,630.0,630.42,630.83,631.67,650.42,651.67,655.0,655.42,691.25,692.08,700.42,709.58,721.67,722.92,726.67,732.5,750.42,789.17}
STRIP_RUNS[500]={622.5,627.92,630.83,631.67,650.42,651.67,691.25,692.08,700.42,709.58,721.67,722.92,726.67,732.5,750.42,789.17}
OCC_RUNS[501]={622.5,627.92,630.0,630.42,630.83,631.67,650.42,651.67,655.0,655.42,690.42,690.83,691.25,692.08,700.42,709.58,721.67,722.92,726.67,732.5,750.42,790.42}
STRIP_RUNS[501]={622.5,627.92,630.83,631.67,650.42,651.67,691.25,692.08,700.42,709.58,721.67,722.92,726.67,732.5}
OCC_RUNS[502]={622.5,627.92,630.0,631.67,650.42,651.67,655.0,655.42,691.25,692.5,700.0,709.58,721.67,722.5,726.67,732.5,750.42,791.25}
STRIP_RUNS[502]={622.5,627.92,630.0,631.67,650.42,651.67,691.25,692.5,700.0,709.58,721.67,722.5,726.67,732.5}
OCC_RUNS[503]={622.5,627.92,630.0,631.25,650.83,651.67,655.0,655.42,691.25,692.5,700.0,709.58,727.08,732.5,750.42,790.42,790.83,791.67}
STRIP_RUNS[503]={622.5,627.92,630.0,631.25,650.83,651.67,691.25,692.5,700.0,709.58,727.08,732.5}
OCC_RUNS[504]={622.92,625.42,625.83,627.92,629.58,631.25,650.83,651.67,655.0,655.42,691.25,692.5,700.0,709.17,727.08,732.5,750.42,790.42,791.25,791.67,792.08,792.92}
STRIP_RUNS[504]={622.92,625.42,625.83,627.92,629.58,631.25,650.83,651.67,691.25,692.5,700.0,709.17,727.08,732.5}
OCC_RUNS[505]={622.92,625.42,625.83,627.92,629.17,631.25,650.83,651.67,655.0,655.42,691.25,692.5,700.0,709.17,727.08,732.5,750.42,790.42,791.25,794.17}
STRIP_RUNS[505]={622.92,625.42,625.83,627.92,629.17,631.25,650.83,651.67,691.25,692.5,700.0,709.17,727.08,732.5}
OCC_RUNS[506]={622.92,625.42,625.83,628.33,629.17,630.0,630.42,631.25,650.83,651.67,655.0,655.42,691.25,692.5,700.0,709.17,727.08,732.5,750.42,762.08,762.5,790.83,791.25,795.0}
STRIP_RUNS[506]={622.92,625.42,625.83,628.33,629.17,630.0,630.42,631.25,650.83,651.67,691.25,692.5,700.0,709.17,727.08,732.5,750.42,762.08}
OCC_RUNS[507]={623.33,625.42,625.83,628.33,629.17,630.0,630.42,631.25,650.83,652.08,655.0,655.83,691.25,692.5,700.0,709.17,727.08,732.5,750.42,762.08,762.5,790.83,791.25,795.83}
STRIP_RUNS[507]={623.33,625.42,625.83,628.33,629.17,630.0,630.42,631.25,650.83,652.08,655.0,655.83,691.25,692.5,700.0,709.17,727.08,732.5,750.42,762.08}
OCC_RUNS[508]={623.33,625.42,625.83,628.33,630.0,631.25,650.83,652.08,691.67,692.5,700.0,709.17,727.08,732.5,750.42,790.83,791.25,796.67}
STRIP_RUNS[508]={623.33,625.42,625.83,628.33,630.0,631.25,650.83,652.08,691.67,692.5,700.0,709.17,727.08,732.5}
OCC_RUNS[509]={623.33,625.0,625.83,628.33,629.58,630.0,630.42,631.25,650.83,652.08,655.42,655.83,691.67,692.5,700.0,709.17,727.08,732.5,750.42,790.83,791.25,797.92}
STRIP_RUNS[509]={623.33,625.0,625.83,628.33,630.42,631.25,650.83,652.08,691.67,692.5,700.0,709.17,727.08,732.5}
OCC_RUNS[510]={622.92,623.75,624.17,625.0,625.83,628.33,630.0,631.25,650.83,652.08,691.67,692.5,700.0,709.17,727.08,732.5,750.42,762.5,762.92,790.83,791.25,798.75}
STRIP_RUNS[510]={622.92,623.75,624.17,625.0,625.83,628.33,630.0,631.25,650.83,652.08,691.67,692.5,700.0,709.17,727.08,732.5,750.42,762.5}
OCC_RUNS[511]={622.92,624.58,625.83,628.75,630.42,631.25,651.25,652.08,691.67,692.5,700.0,709.17,727.08,732.08,750.42,790.83,791.25,799.58}
STRIP_RUNS[511]={622.92,624.58,625.83,628.75,630.42,631.25,651.25,652.08,691.67,692.5,700.0,709.17,727.08,732.08}
OCC_RUNS[512]={623.33,625.0,625.83,628.75,630.0,631.25,651.25,652.08,691.67,692.92,700.0,709.17,727.5,732.08,750.42,762.5,762.92,790.83,791.25,800.42}
STRIP_RUNS[512]={623.33,625.0,625.83,628.75,630.0,631.25,651.25,652.08,691.67,692.92,700.0,709.17,727.5,732.08,750.42,762.5}
OCC_RUNS[513]={623.33,624.58,626.25,628.75,630.0,631.25,632.92,633.33,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67,762.92,801.25}
STRIP_RUNS[513]={623.33,624.58,626.25,628.75,630.0,631.25,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67}
OCC_RUNS[514]={623.33,624.58,626.25,628.75,630.0,631.25,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67,763.75,790.42,791.25,802.08}
STRIP_RUNS[514]={623.33,624.58,626.25,628.75,630.0,631.25,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67}
OCC_RUNS[515]={623.33,624.17,626.25,628.75,630.0,631.67,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67,762.92,763.33,764.58,790.42,791.25,792.08,792.5,803.33}
STRIP_RUNS[515]={623.33,624.17,626.25,628.75,630.0,631.67,651.25,652.08,691.67,692.92,700.0,708.75,727.5,732.08,750.42,761.67}
OCC_RUNS[516]={622.5,622.92,623.33,623.75,626.25,627.92,628.33,628.75,630.42,631.67,651.25,652.08,691.67,692.92,699.58,708.75,727.5,732.08,750.42,761.67,762.92,763.33,763.75,764.17,765.42,790.83,791.25,792.08,792.5,804.17}
STRIP_RUNS[516]={626.25,627.92,630.42,631.67,651.25,652.08,691.67,692.92,699.58,708.75,727.5,732.08,750.42,761.67}
OCC_RUNS[517]={622.5,623.75,626.25,627.92,628.33,629.17,630.42,631.67,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,762.92,763.75,764.17,764.58,766.25,774.17,774.58,790.83,791.25,792.08,792.5,793.33,793.75,805.0}
STRIP_RUNS[517]={622.5,623.75,626.25,627.92,628.33,629.17,630.42,631.67,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,762.92,763.75,766.25,774.17}
OCC_RUNS[518]={622.5,622.92,626.25,627.92,628.33,629.17,630.83,631.67,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,763.75,764.58,765.83,766.67,767.5,790.83,791.67,792.08,792.5,793.33,793.75,805.83}
STRIP_RUNS[518]={626.25,627.92,628.33,629.17,630.83,631.67,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,763.75,764.58,765.83,766.67}
OCC_RUNS[519]={626.25,627.92,628.33,629.17,630.42,632.5,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,763.33,764.17,765.42,766.25,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,806.67}
STRIP_RUNS[519]={626.25,627.92,628.33,629.17,630.42,632.5,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,763.33,764.17,765.42,766.25,767.5,774.17}
OCC_RUNS[520]={623.33,624.17,626.25,627.92,628.33,629.17,630.42,632.08,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,762.92,764.17,765.42,766.25,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,807.08}
STRIP_RUNS[520]={623.33,624.17,626.25,627.92,628.33,629.17,630.42,632.08,651.25,652.08,692.08,692.92,699.58,708.75,727.5,732.08,750.42,761.67,762.92,764.17,765.42,766.25,767.5,774.17}
OCC_RUNS[521]={626.25,627.92,628.75,629.58,631.25,632.08,651.25,652.08,692.08,692.92,699.58,708.33,727.5,732.08,750.42,761.67,762.92,764.17,765.42,765.83,767.5,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,807.08}
STRIP_RUNS[521]={626.25,627.92,628.75,629.58,631.25,632.08,651.25,652.08,692.08,692.92,699.58,708.33,727.5,732.08,750.42,761.67,762.92,764.17}
OCC_RUNS[522]={623.75,624.17,626.25,627.92,628.75,629.17,631.25,632.08,651.67,652.08,692.08,692.92,699.58,708.33,727.5,731.67,750.42,761.67,762.92,764.17,765.0,765.42,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,807.08}
STRIP_RUNS[522]={626.25,627.92,631.25,632.08,692.08,692.92,699.58,708.33,727.5,731.67,750.42,761.67,762.92,764.17,767.5,774.17}
OCC_RUNS[523]={626.25,627.92,629.17,629.58,631.25,632.08,651.67,652.08,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,762.92,763.33,763.75,764.17,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[523]={626.25,627.92,631.25,632.08,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,767.5,774.17}
OCC_RUNS[524]={623.33,623.75,626.25,627.92,631.25,632.08,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[524]={626.25,627.92,631.25,632.08,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,767.5,774.17}
OCC_RUNS[525]={623.33,623.75,626.25,627.92,628.75,629.58,631.25,632.5,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,762.92,763.33,767.5,774.17,774.58,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[525]={626.25,627.92,628.75,629.58,631.25,632.5,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,767.5,774.17}
OCC_RUNS[526]={626.25,627.92,629.17,629.58,631.67,632.92,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,762.92,763.33,766.67,767.08,767.5,774.17,775.0,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[526]={626.25,627.92,631.67,632.92,651.67,652.5,692.08,692.92,700.0,708.33,727.5,731.67,750.83,761.67,767.5,774.17}
OCC_RUNS[527]={626.25,627.92,629.17,629.58,631.67,632.5,651.67,652.5,692.08,692.92,699.58,708.33,727.5,731.25,750.83,761.67,762.92,763.33,766.67,767.08,767.5,774.17,775.83,790.83,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[527]={626.25,627.92,631.67,632.5,651.67,652.5,692.08,692.92,699.58,708.33,727.5,731.25,750.83,761.67,767.5,774.17}
OCC_RUNS[528]={622.5,622.92,626.67,627.92,631.67,632.08,651.67,652.5,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,766.25,766.67,767.5,774.17,777.08,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[528]={626.67,627.92,651.67,652.5,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,767.5,774.17}
OCC_RUNS[529]={626.67,627.92,629.17,630.0,631.67,632.08,652.08,652.5,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,765.83,766.25,767.5,774.17,777.5,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[529]={626.67,627.92,629.17,630.0,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,767.5,774.17}
OCC_RUNS[530]={626.67,627.92,629.17,630.0,632.5,632.92,652.08,652.5,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,766.67,767.08,767.5,773.75,777.92,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[530]={626.67,627.92,629.17,630.0,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,767.5,773.75}
OCC_RUNS[531]={626.67,627.92,629.17,630.0,632.5,632.92,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,765.42,765.83,766.67,767.08,767.5,773.75,777.92,778.75,779.17,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[531]={626.67,627.92,629.17,630.0,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.83,750.83,761.67,767.5,773.75,777.92,778.75}
OCC_RUNS[532]={626.67,627.92,629.17,630.0,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.0,730.42,730.83,750.83,761.67,766.25,766.67,767.5,773.75,777.5,777.92,780.0,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[532]={626.67,627.92,629.17,630.0,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.0,750.83,761.67,767.5,773.75}
OCC_RUNS[533]={626.67,627.92,629.58,630.0,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.0,730.42,730.83,750.83,761.67,765.42,766.25,766.67,767.08,767.5,773.75,777.92,778.33,782.08,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[533]={626.67,627.92,652.08,652.92,692.5,693.33,699.58,707.92,727.5,730.0,750.83,761.67,765.42,766.25,767.5,773.75}
OCC_RUNS[534]={627.08,627.92,629.58,630.0,630.42,630.83,631.67,632.08,652.5,652.92,692.5,692.92,699.58,707.5,727.92,730.0,730.42,730.83,750.83,761.67,765.83,766.25,767.5,773.75,782.92,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[534]={627.08,627.92,699.58,707.5,727.92,730.0,750.83,761.67,767.5,773.75}
OCC_RUNS[535]={626.67,627.92,629.58,630.42,652.5,652.92,692.5,692.92,699.58,707.5,727.92,730.0,730.42,730.83,751.25,761.67,767.5,773.75,783.75,791.25,791.67,792.08,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[535]={626.67,627.92,629.58,630.42,699.58,707.5,727.92,730.0,751.25,761.67,767.5,773.75}
OCC_RUNS[536]={622.92,623.33,626.67,627.92,629.58,630.42,652.5,652.92,692.5,692.92,699.58,707.5,727.92,730.0,730.42,730.83,751.25,761.67,767.5,773.75,777.92,778.33,784.17,791.25,791.67,792.08,792.5,793.33,794.58,806.67}
STRIP_RUNS[536]={626.67,627.92,629.58,630.42,699.58,707.5,727.92,730.0,751.25,761.67,767.5,773.75}
OCC_RUNS[537]={626.67,627.92,629.58,630.42,652.5,653.33,692.5,692.92,699.58,707.5,727.92,730.0,751.25,761.67,767.5,773.75,777.5,777.92,785.0,791.25,791.67,792.08,792.5,793.33,794.58,806.67}
STRIP_RUNS[537]={626.67,627.92,629.58,630.42,652.5,653.33,699.58,707.5,727.92,730.0,751.25,761.67,767.5,773.75}
OCC_RUNS[538]={627.08,627.92,629.58,630.42,652.5,653.33,692.5,692.92,699.58,707.08,727.92,730.0,751.25,762.08,767.5,773.75,786.67,791.25,791.67,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[538]={627.08,627.92,629.58,630.42,652.5,653.33,699.58,707.08,727.92,730.0,751.25,762.08,767.5,773.75}
OCC_RUNS[539]={627.08,627.92,629.58,630.0,652.5,653.33,692.5,692.92,699.58,707.08,727.92,730.42,751.25,762.08,767.08,773.75,787.5,791.25,791.67,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[539]={627.08,627.92,652.5,653.33,699.58,707.08,727.92,730.42,751.25,762.08,767.08,773.75}
OCC_RUNS[540]={627.08,627.92,629.58,630.0,652.5,653.33,692.5,692.92,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.75,788.33,791.67,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[540]={627.08,627.92,652.5,653.33,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.75}
OCC_RUNS[541]={627.08,627.92,652.92,653.33,692.5,692.92,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.75,776.25,776.67,789.17,791.67,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[541]={627.08,627.92,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.75}
OCC_RUNS[542]={627.08,627.92,652.92,653.33,692.08,692.92,699.58,707.08,727.5,727.92,728.33,730.0,751.25,762.08,767.08,773.33,776.25,777.08,790.0,791.67,792.5,793.33,793.75,794.17,794.58,806.67}
STRIP_RUNS[542]={627.08,627.92,692.08,692.92,699.58,707.08,728.33,730.0,751.25,762.08,767.08,773.33,776.25,777.08}
OCC_RUNS[543]={627.08,627.92,652.92,653.75,692.08,692.92,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.33,776.25,777.08,792.5,793.33,794.58,806.67}
STRIP_RUNS[543]={627.08,627.92,652.92,653.75,692.08,692.92,699.58,707.08,727.5,730.0,751.25,762.08,767.5,773.33,776.25,777.08}
OCC_RUNS[544]={627.08,628.33,652.92,653.75,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,767.5,773.33,776.25,777.5,792.5,793.33,794.58,806.25,827.5,827.92}
STRIP_RUNS[544]={627.08,628.33,652.92,653.75,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,767.5,773.33,776.25,777.5}
OCC_RUNS[545]={627.08,628.33,652.92,653.75,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,767.5,773.33,776.25,777.08,792.92,793.33,794.58,806.25,827.5,827.92}
STRIP_RUNS[545]={627.08,628.33,652.92,653.75,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,767.5,773.33,776.25,777.08}
OCC_RUNS[546]={622.08,622.5,627.08,628.33,653.33,653.75,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,764.58,765.0,767.5,773.33,776.25,777.08,794.58,806.25,827.5,827.92}
STRIP_RUNS[546]={627.08,628.33,692.08,692.92,699.58,706.67,727.92,730.0,751.67,762.08,767.5,773.33,776.25,777.08}
OCC_RUNS[547]={627.08,628.33,653.33,653.75,692.08,692.5,699.58,706.67,727.5,730.0,751.67,762.08,764.58,765.0,765.83,766.25,767.5,773.33,776.25,777.08,794.58,806.25,827.92,828.33}
STRIP_RUNS[547]={627.08,628.33,699.58,706.67,727.5,730.0,751.67,762.08,767.5,773.33,776.25,777.08}
OCC_RUNS[548]={621.67,622.5,627.08,628.33,692.08,692.5,699.58,706.25,727.5,730.0,751.67,762.08,767.5,772.92,776.25,777.08,796.25,806.25,827.92,828.33}
STRIP_RUNS[548]={621.67,622.5,627.08,628.33,699.58,706.25,727.5,730.0,751.67,762.08,767.5,772.92,776.25,777.08}
OCC_RUNS[549]={627.08,628.33,653.33,653.75,699.58,706.67,727.5,730.42,751.67,762.08,763.33,763.75,767.5,772.92,776.25,776.67,777.08,777.5,796.25,806.25,827.92,828.33}
STRIP_RUNS[549]={627.08,628.33,699.58,706.67,727.5,730.42,751.67,762.08,767.5,772.92}
OCC_RUNS[550]={627.08,628.33,653.33,653.75,699.58,706.67,727.92,730.42,751.67,762.08,763.33,763.75,767.5,772.92,776.25,777.5,796.25,800.83,801.25,806.25,827.92,828.33}
STRIP_RUNS[550]={627.08,628.33,699.58,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.5}
OCC_RUNS[551]={627.08,628.33,699.58,706.67,728.33,730.42,751.67,762.08,763.33,763.75,767.5,772.92,776.25,777.08,796.25,806.25,828.33,828.75}
STRIP_RUNS[551]={627.08,628.33,699.58,706.67,728.33,730.42,751.67,762.08,767.5,772.92,776.25,777.08}
OCC_RUNS[552]={627.08,628.33,653.75,654.17,691.67,692.08,700.0,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.08,796.25,800.83,801.25,806.25,828.33,828.75}
STRIP_RUNS[552]={627.08,628.33,700.0,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.08}
OCC_RUNS[553]={627.5,628.33,653.75,654.17,700.0,706.67,727.92,730.42,751.67,762.08,763.33,763.75,767.5,772.92,776.25,777.08,796.25,800.0,801.25,806.25,828.33,828.75}
STRIP_RUNS[553]={627.5,628.33,700.0,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.08}
OCC_RUNS[554]={627.5,628.33,653.75,654.17,700.0,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.08,796.25,800.0,801.25,806.25,828.33,828.75}
STRIP_RUNS[554]={627.5,628.33,700.0,706.67,727.92,730.42,751.67,762.08,767.5,772.92,776.25,777.08}
OCC_RUNS[555]={627.5,628.33,653.75,654.17,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5,775.42,775.83,776.25,776.67,796.25,800.0,801.67,806.25,828.75,829.17}
STRIP_RUNS[555]={627.5,628.33,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5}
OCC_RUNS[556]={621.67,622.08,627.5,628.33,653.75,654.17,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5,775.42,775.83,776.25,776.67,796.25,800.0,801.25,806.25,828.75,829.17}
STRIP_RUNS[556]={627.5,628.33,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5}
OCC_RUNS[557]={627.5,628.33,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5,776.25,776.67,796.25,800.0,800.83,806.25,828.75,829.17}
STRIP_RUNS[557]={627.5,628.33,700.0,706.67,727.92,730.42,752.08,762.08,767.5,772.5}
OCC_RUNS[558]={627.5,628.33,654.17,654.58,700.0,706.67,727.5,730.42,752.08,762.08,766.67,772.5,796.25,806.25,828.75,829.17}
STRIP_RUNS[558]={627.5,628.33,700.0,706.67,727.5,730.42,752.08,762.08,766.67,772.5}
OCC_RUNS[559]={627.5,628.33,654.17,654.58,691.67,692.08,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5,777.5,777.92,796.25,806.25,828.75,829.17}
STRIP_RUNS[559]={627.5,628.33,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5}
OCC_RUNS[560]={627.5,628.33,654.17,654.58,691.67,692.08,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5,777.5,777.92,795.83,806.25,828.75,829.17}
STRIP_RUNS[560]={627.5,628.33,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5}
OCC_RUNS[561]={627.5,628.33,654.17,654.58,691.25,691.67,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5,777.08,777.5,795.83,806.25,828.75,829.17}
STRIP_RUNS[561]={627.5,628.33,700.0,706.67,727.5,730.42,752.08,762.08,767.92,772.5}
OCC_RUNS[562]={627.5,628.33,654.17,654.58,691.25,691.67,700.0,706.67,727.5,728.33,728.75,730.42,752.08,762.08,763.75,764.17,767.92,772.08,777.08,777.5,795.83,806.25,828.75,829.17}
STRIP_RUNS[562]={627.5,628.33,700.0,706.67,727.5,728.33,728.75,730.42,752.08,762.08,767.92,772.08}
OCC_RUNS[563]={627.5,628.33,700.0,706.67,727.5,728.33,728.75,730.42,752.08,761.67,767.92,772.08,776.67,777.08,795.83,806.25,829.17,829.58}
STRIP_RUNS[563]={627.5,628.33,700.0,706.67,727.5,728.33,728.75,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[564]={627.5,628.33,654.58,655.0,691.25,691.67,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08,776.25,776.67,795.83,806.25,829.17,829.58}
STRIP_RUNS[564]={627.5,628.33,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[565]={627.5,628.33,654.58,655.0,691.25,691.67,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08,776.25,776.67,795.83,805.83,829.17,829.58}
STRIP_RUNS[565]={627.5,628.33,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[566]={627.5,628.33,654.58,655.0,690.83,691.25,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08,795.83,805.83,829.17,829.58}
STRIP_RUNS[566]={627.5,628.33,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[567]={627.5,628.33,654.58,655.0,690.83,691.25,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.5,795.83,805.83,829.17,829.58}
STRIP_RUNS[567]={627.5,628.33,700.0,706.25,727.08,727.92,728.75,730.42,752.08,761.67,767.92,772.5}
OCC_RUNS[568]={627.5,628.33,654.58,655.0,690.83,691.25,700.0,706.25,727.08,727.92,729.17,730.42,752.08,761.67,767.92,772.08,795.83,801.25,802.08,805.83,829.58,830.0}
STRIP_RUNS[568]={627.5,628.33,700.0,706.25,727.08,727.92,729.17,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[569]={627.5,628.33,700.0,706.25,727.08,727.5,729.17,730.42,752.08,761.67,765.83,766.67,767.92,772.08,795.83,800.83,802.08,805.83,829.58,830.0}
STRIP_RUNS[569]={627.5,628.33,700.0,706.25,729.17,730.42,752.08,761.67,765.83,766.67,767.92,772.08}
OCC_RUNS[570]={627.5,628.33,690.42,690.83,700.42,706.25,727.08,727.5,728.75,730.0,752.08,761.67,767.92,772.08,795.83,800.42,802.08,805.83,829.58,830.0}
STRIP_RUNS[570]={627.5,628.33,700.42,706.25,728.75,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[571]={627.5,628.33,690.42,690.83,700.42,706.25,726.67,727.5,729.17,730.42,752.08,761.67,767.08,767.5,767.92,772.08,795.83,800.42,802.08,805.83,829.58,830.0}
STRIP_RUNS[571]={627.5,628.33,700.42,706.25,726.67,727.5,729.17,730.42,752.08,761.67,767.92,772.08}
OCC_RUNS[572]={627.5,628.33,655.0,655.42,690.42,690.83,700.0,706.25,727.08,727.5,729.17,730.0,752.08,761.67,767.08,767.5,767.92,772.08,795.83,800.0,802.08,805.83,830.0,830.42}
STRIP_RUNS[572]={627.5,628.33,700.0,706.25,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[573]={627.5,628.33,655.0,655.42,700.42,706.25,729.17,730.0,752.08,761.67,767.92,772.08,795.83,799.58,801.67,805.83,830.0,830.42}
STRIP_RUNS[573]={627.5,628.33,700.42,706.25,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[574]={627.5,628.33,655.0,655.42,700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08,795.83,799.58,801.67,805.83,817.92,818.33,830.0,830.42}
STRIP_RUNS[574]={627.5,628.33,700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[575]={627.5,628.33,655.0,655.42,700.42,705.83,727.08,727.5,729.17,730.0,752.08,761.67,767.92,772.08,795.83,799.58,801.67,805.83,830.0,830.42}
STRIP_RUNS[575]={627.5,628.33,700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[576]={627.5,628.33,655.0,655.42,700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08,795.83,799.58,801.67,805.83,830.0,830.42}
STRIP_RUNS[576]={627.5,628.33,700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[577]={627.5,627.92,655.0,655.42,700.42,705.83,726.67,727.08,729.17,730.0,752.08,761.67,767.92,772.08,795.83,799.58,801.67,805.83}
STRIP_RUNS[577]={700.42,705.83,729.17,730.0,752.08,761.67,767.92,772.08}
OCC_RUNS[578]={627.5,627.92,700.42,705.83,726.25,727.08,729.17,730.0,752.5,761.67,767.92,772.08,795.42,799.58,801.67,805.83,830.42,830.83}
STRIP_RUNS[578]={700.42,705.83,726.25,727.08,729.17,730.0,752.5,761.67,767.92,772.08}
OCC_RUNS[579]={627.08,627.92,700.42,705.83,726.25,727.08,729.17,730.0,752.5,761.67,767.92,772.08,795.42,799.58,801.67,805.83,830.42,830.83}
STRIP_RUNS[579]={627.08,627.92,700.42,705.83,726.25,727.08,729.17,730.0,752.5,761.67,767.92,772.08}
OCC_RUNS[580]={627.08,627.92,700.42,705.83,728.75,730.0,752.5,761.25,767.92,772.08,795.42,799.58,801.67,805.83,830.42,830.83}
STRIP_RUNS[580]={627.08,627.92,700.42,705.83,728.75,730.0,752.5,761.25,767.92,772.08}
OCC_RUNS[581]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,772.08,795.42,799.58,801.67,805.83,830.42,830.83}
STRIP_RUNS[581]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,772.08}
OCC_RUNS[582]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,772.08,795.42,799.58,801.67,805.83}
STRIP_RUNS[582]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,772.08}
OCC_RUNS[583]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,771.67,795.42,799.58,801.67,805.83,830.83,831.25}
STRIP_RUNS[583]={627.08,627.92,700.83,705.83,728.75,730.0,752.5,761.25,767.92,771.67}
OCC_RUNS[584]={627.08,627.92,700.83,705.83,728.75,729.58,752.5,761.25,767.92,771.67,795.42,799.58,801.67,805.83,830.83,831.25}
STRIP_RUNS[584]={627.08,627.92,700.83,705.83,728.75,729.58,752.5,761.25,767.92,771.67}
OCC_RUNS[585]={627.08,627.92,700.83,705.42,728.75,729.58,752.5,761.25,767.92,771.67,795.42,799.58,801.67,805.83,830.83,831.25}
STRIP_RUNS[585]={627.08,627.92,700.83,705.42,728.75,729.58,752.5,761.25,767.92,771.67}
OCC_RUNS[586]={627.08,627.92,700.83,705.42,728.75,729.58,752.5,761.25,768.33,771.67,795.42,799.58,801.67,805.42,827.5,827.92}
STRIP_RUNS[586]={627.08,627.92,700.83,705.42,728.75,729.58,752.5,761.25,768.33,771.67}
OCC_RUNS[587]={627.08,627.92,701.25,705.42,728.75,729.58,752.5,761.25,768.33,771.67,795.42,799.58,801.67,805.42,831.25,831.67}
STRIP_RUNS[587]={627.08,627.92,701.25,705.42,728.75,729.58,752.5,761.25,768.33,771.67}
OCC_RUNS[588]={627.08,627.5,700.42,705.42,728.75,729.58,752.5,761.25,769.17,771.67,795.42,799.58,801.67,805.42,831.25,831.67}
STRIP_RUNS[588]={700.42,705.42,728.75,729.58,752.5,761.25,769.17,771.67}
OCC_RUNS[589]={627.08,627.5,700.83,705.42,728.75,729.58,752.5,761.25,768.75,771.67,795.42,799.58,801.25,805.42,831.25,831.67}
STRIP_RUNS[589]={700.83,705.42,728.75,729.58,752.5,761.25,768.75,771.67}
OCC_RUNS[590]={627.08,627.5,700.42,705.42,729.17,729.58,752.5,761.25,768.75,771.67,795.42,799.58,800.83,805.42}
STRIP_RUNS[590]={700.42,705.42,752.5,761.25,768.75,771.67}
OCC_RUNS[591]={626.67,627.5,700.42,705.42,728.75,729.58,752.5,761.25,769.58,771.25,795.42,799.58,800.83,805.42,831.25,832.08}
STRIP_RUNS[591]={626.67,627.5,700.42,705.42,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[592]={626.67,627.5,700.83,705.42,728.75,729.58,752.5,761.25,768.75,769.17,769.58,771.25,795.42,799.17,800.42,805.42,831.67,832.08}
STRIP_RUNS[592]={626.67,627.5,700.83,705.42,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[593]={626.67,627.5,700.83,702.5,702.92,703.33,703.75,705.42,728.75,729.58,752.5,761.25,769.58,771.25,795.42,799.17,799.58,805.42,831.67,832.08}
STRIP_RUNS[593]={626.67,627.5,700.83,702.5,703.75,705.42,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[594]={626.67,627.5,700.83,702.5,702.92,703.33,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25,795.42,799.17,799.58,805.42,831.67,832.5,834.17,834.58}
STRIP_RUNS[594]={626.67,627.5,700.83,702.5,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[595]={626.67,627.5,700.83,702.5,702.92,703.33,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25,795.42,805.42,831.67,832.5}
STRIP_RUNS[595]={626.67,627.5,700.83,702.5,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[596]={626.67,627.08,700.83,702.5,703.75,705.0,728.75,729.58,752.5,761.25,768.75,769.17,769.58,771.25,795.42,805.42,832.08,832.5}
STRIP_RUNS[596]={700.83,702.5,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[597]={626.67,627.08,700.83,702.5,702.92,703.33,703.75,705.0,728.75,729.58,752.5,761.25,767.92,771.25,795.0,805.42,832.08,832.5}
STRIP_RUNS[597]={700.83,702.5,703.75,705.0,728.75,729.58,752.5,761.25,767.92,771.25}
OCC_RUNS[598]={626.67,627.08,700.83,701.67,703.75,705.0,728.75,729.58,752.5,761.25,767.92,768.33,769.58,771.25,795.0,805.42,832.08,832.92}
STRIP_RUNS[598]={700.83,701.67,703.75,705.0,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[599]={626.67,627.08,703.33,705.0,728.75,729.58,752.5,761.25,769.58,771.25,795.0,805.42,832.08,832.92}
STRIP_RUNS[599]={703.33,705.0,728.75,729.58,752.5,761.25,769.58,771.25}
OCC_RUNS[600]={626.25,627.08,703.33,704.58,728.75,729.58,752.5,761.25,768.33,768.75,769.58,770.83,795.0,805.42,832.08,832.92}
STRIP_RUNS[600]={626.25,627.08,703.33,704.58,728.75,729.58,752.5,761.25,769.58,770.83}
OCC_RUNS[601]={626.25,627.08,701.67,702.08,703.33,704.58,728.75,729.58,752.5,761.25,768.33,768.75,769.58,770.83,795.42,805.42,832.5,832.92}
STRIP_RUNS[601]={626.25,627.08,703.33,704.58,728.75,729.58,752.5,761.25,769.58,770.83}
OCC_RUNS[602]={626.25,627.08,701.67,702.5,703.33,704.58,728.75,729.58,752.5,760.83,769.58,770.83,795.42,800.83,801.25,805.42,832.5,832.92}
STRIP_RUNS[602]={626.25,627.08,701.67,702.5,703.33,704.58,728.75,729.58,752.5,760.83,769.58,770.83}
OCC_RUNS[603]={626.25,626.67,700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.58,770.83,795.0,800.42,801.25,805.42,832.5,833.33}
STRIP_RUNS[603]={700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.58,770.83}
OCC_RUNS[604]={626.25,626.67,700.42,702.5,702.92,704.58,728.75,729.58,752.5,761.25,768.75,769.17,769.58,770.83,795.42,800.42,801.25,805.42,832.5,833.33}
STRIP_RUNS[604]={700.42,702.5,702.92,704.58,728.75,729.58,752.5,761.25,769.58,770.83}
OCC_RUNS[605]={626.25,626.67,700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.17,770.83,795.0,800.0,801.25,805.42,832.5,833.33}
STRIP_RUNS[605]={700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.17,770.83}
OCC_RUNS[606]={626.25,626.67,700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.17,770.83,795.42,799.58,801.25,805.42,832.92,833.33}
STRIP_RUNS[606]={700.83,702.5,702.92,704.58,728.75,729.58,752.5,760.83,769.17,770.83}
OCC_RUNS[607]={626.25,626.67,701.67,702.08,702.92,704.58,728.75,729.17,752.92,760.83,769.17,770.83,795.42,799.58,801.25,805.0,832.92,833.33}
STRIP_RUNS[607]={702.92,704.58,752.92,760.83,769.17,770.83}
OCC_RUNS[608]={625.83,626.67,702.92,704.17,728.75,729.17,752.92,760.83,769.17,770.83,795.42,799.17,801.25,805.0,832.92,833.75}
STRIP_RUNS[608]={625.83,626.67,702.92,704.17,752.92,760.83,769.17,770.83}
OCC_RUNS[609]={625.83,626.67,700.83,702.08,702.92,704.17,728.75,729.17,752.92,760.83,769.17,770.42,795.42,799.17,801.25,805.0,832.92,833.75}
STRIP_RUNS[609]={625.83,626.67,700.83,702.08,702.92,704.17,752.92,760.83,769.17,770.42}
OCC_RUNS[610]={625.83,626.67,700.83,702.08,702.92,704.17,728.75,729.17,752.92,760.83,769.17,770.42,795.42,799.17,801.25,805.0,832.92,833.75}
STRIP_RUNS[610]={625.83,626.67,700.83,702.08,702.92,704.17,752.92,760.83,769.17,770.42}
OCC_RUNS[611]={625.83,626.25,700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,769.17,770.42,795.42,798.75,801.25,805.0,832.92,833.75}
STRIP_RUNS[611]={700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,769.17,770.42}
OCC_RUNS[612]={625.83,626.25,700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,768.75,770.42,795.42,798.75,801.25,805.0,833.33,833.75}
STRIP_RUNS[612]={700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,768.75,770.42}
OCC_RUNS[613]={625.83,626.25,700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,768.75,770.42,795.42,798.75,800.83,805.0,833.33,833.75}
STRIP_RUNS[613]={700.83,702.08,702.92,704.17,728.33,729.17,752.92,760.83,768.75,770.42}
OCC_RUNS[614]={625.83,626.25,700.83,701.67,702.92,704.17,728.33,729.17,753.33,760.83,768.75,770.42,795.42,798.75,800.83,805.0,833.33,834.17}
STRIP_RUNS[614]={700.83,701.67,702.92,704.17,728.33,729.17,753.33,760.83,768.75,770.42}
OCC_RUNS[615]={625.83,626.25,700.83,701.67,702.5,704.17,728.33,729.17,753.33,760.42,768.75,770.0,795.0,798.75,800.83,805.0,833.33,834.17,850.0,850.42}
STRIP_RUNS[615]={700.83,701.67,702.5,704.17,728.33,729.17,753.33,760.42,768.75,770.0}
OCC_RUNS[616]={625.83,626.25,702.5,704.17,728.33,728.75,753.33,760.83,768.75,770.0,795.42,798.75,800.83,805.0,833.75,834.17}
STRIP_RUNS[616]={702.5,704.17,753.33,760.83,768.75,770.0}
OCC_RUNS[617]={625.42,626.25,702.5,703.75,728.33,728.75,753.33,760.42,768.75,770.0,795.42,798.75,800.83,805.0,833.75,834.17,851.25,851.67}
STRIP_RUNS[617]={625.42,626.25,702.5,703.75,753.33,760.42,768.75,770.0}
OCC_RUNS[618]={625.42,626.25,702.5,703.75,728.33,728.75,753.33,760.83,768.75,770.0,795.0,798.75,800.83,805.0,833.75,834.17,852.5,852.92}
STRIP_RUNS[618]={625.42,626.25,702.5,703.75,753.33,760.83,768.75,770.0}
OCC_RUNS[619]={625.42,625.83,702.5,703.75,728.33,728.75,753.33,760.83,768.75,770.0,795.0,798.75,800.83,805.0,833.75,834.17}
STRIP_RUNS[619]={702.5,703.75,753.33,760.83,768.75,770.0}
OCC_RUNS[620]={625.42,625.83,702.5,703.75,728.33,728.75,753.33,760.83,768.75,770.0,795.0,798.75,800.83,805.0,833.75,834.58}
STRIP_RUNS[620]={702.5,703.75,753.33,760.83,768.75,770.0}
OCC_RUNS[621]={625.42,625.83,702.5,703.75,728.33,728.75,753.33,760.83,768.33,770.0,795.0,798.75,800.83,805.0,833.75,834.58}
STRIP_RUNS[621]={702.5,703.75,753.33,760.83,768.33,770.0}
OCC_RUNS[622]={625.42,625.83,702.5,703.75,728.33,728.75,753.33,760.42,768.33,770.0,795.0,798.75,800.83,805.0,834.17,834.58}
STRIP_RUNS[622]={702.5,703.75,753.33,760.42,768.33,770.0}
OCC_RUNS[623]={700.83,701.25,702.5,703.75,727.92,728.75,753.33,760.42,768.33,770.0,795.0,798.75,800.83,805.0,834.17,835.0}
STRIP_RUNS[623]={702.5,703.75,727.92,728.75,753.33,760.42,768.33,770.0}
OCC_RUNS[624]={702.5,703.75,727.92,728.75,753.75,760.42,768.33,769.58,795.0,798.75,800.83,805.0,834.17,835.0}
STRIP_RUNS[624]={702.5,703.75,727.92,728.75,753.75,760.42,768.33,769.58}
OCC_RUNS[625]={702.5,703.75,727.92,728.75,753.75,760.42,768.33,769.58,794.58,798.75,800.83,805.0,834.17,835.0}
STRIP_RUNS[625]={702.5,703.75,727.92,728.75,753.75,760.42,768.33,769.58}
OCC_RUNS[626]={700.83,701.25,702.5,703.33,727.92,728.33,753.75,760.42,768.33,769.17,794.58,798.75,800.83,805.0,834.58,835.0}
STRIP_RUNS[626]={702.5,703.33,753.75,760.42,768.33,769.17}
OCC_RUNS[627]={700.83,701.25,702.5,703.33,727.92,728.33,753.75,760.42,768.33,769.17,795.0,798.75,800.42,805.0,834.58,835.42}
STRIP_RUNS[627]={702.5,703.33,753.75,760.42,768.33,769.17}
OCC_RUNS[628]={700.83,701.67,702.08,703.33,727.92,728.33,753.75,760.42,768.33,769.17,794.58,798.75,800.0,804.58,835.0,835.42}
STRIP_RUNS[628]={700.83,701.67,702.08,703.33,753.75,760.42,768.33,769.17}
OCC_RUNS[629]={702.08,703.33,727.92,728.33,753.75,760.42,767.92,769.17,794.58,798.33,799.58,804.58,835.0,835.42}
STRIP_RUNS[629]={702.08,703.33,753.75,760.42,767.92,769.17}
OCC_RUNS[630]={702.08,703.33,727.92,728.33,753.75,760.42,767.92,769.17,795.0,798.33,799.58,804.58,835.0,835.42}
STRIP_RUNS[630]={702.08,703.33,753.75,760.42,767.92,769.17}
OCC_RUNS[631]={702.08,703.33,727.92,728.33,744.58,745.0,754.17,760.42,767.92,769.17,794.58,798.33,799.17,804.58,835.0,835.83}
STRIP_RUNS[631]={702.08,703.33,754.17,760.42,767.92,769.17}
OCC_RUNS[632]={702.08,703.33,727.92,728.33,744.58,745.0,754.17,760.42,767.92,769.17,795.0,798.33,799.17,804.58,835.0,835.83}
STRIP_RUNS[632]={702.08,703.33,754.17,760.42,767.92,769.17}
OCC_RUNS[633]={702.08,703.33,727.92,728.33,744.58,745.0,754.17,760.42,767.92,768.75,794.58,798.33,799.17,804.58,835.42,835.83}
STRIP_RUNS[633]={702.08,703.33,754.17,760.42,767.92,768.75}
OCC_RUNS[634]={702.08,703.33,727.92,728.33,754.17,760.42,767.92,768.75,794.17,794.58,795.0,798.33,798.75,804.58,835.42,835.83}
STRIP_RUNS[634]={702.08,703.33,754.17,760.42,767.92,768.75}
OCC_RUNS[635]={702.08,702.92,754.17,760.42,767.92,768.75,794.17,798.33,798.75,804.58,835.42,835.83}
STRIP_RUNS[635]={702.08,702.92,754.17,760.42,767.92,768.75}
OCC_RUNS[636]={702.08,702.92,754.58,760.42,767.92,769.17,794.17,804.58,835.42,836.25}
STRIP_RUNS[636]={702.08,702.92,754.58,760.42,767.92,769.17}
OCC_RUNS[637]={701.25,701.67,702.08,702.92,754.58,760.42,767.92,768.75,794.58,800.42,800.83,804.58,835.42,836.25}
STRIP_RUNS[637]={702.08,702.92,754.58,760.42,767.92,768.75}
OCC_RUNS[638]={702.08,702.92,754.58,760.42,767.92,768.75,794.58,800.0,800.83,804.58,835.83,836.25}
STRIP_RUNS[638]={702.08,702.92,754.58,760.42,767.92,768.75}
OCC_RUNS[639]={701.67,702.92,754.58,760.42,767.5,768.75,794.58,800.0,800.83,804.58,835.83,836.25}
STRIP_RUNS[639]={701.67,702.92,754.58,760.42,767.5,768.75}
OCC_RUNS[640]={701.67,702.92,727.5,727.92,754.58,760.42,767.5,768.75,794.58,800.0,800.83,804.58,835.83,836.25}
STRIP_RUNS[640]={701.67,702.92,754.58,760.42,767.5,768.75}
OCC_RUNS[641]={701.67,702.92,727.5,727.92,754.58,760.42,767.5,768.75,794.17,799.58,800.83,804.58,835.83,836.67}
STRIP_RUNS[641]={701.67,702.92,754.58,760.42,767.5,768.75}
OCC_RUNS[642]={701.67,702.92,727.5,727.92,754.58,760.42,767.5,768.75,794.58,799.58,800.83,804.58,835.83,836.67}
STRIP_RUNS[642]={701.67,702.92,754.58,760.42,767.5,768.75}
OCC_RUNS[643]={701.67,702.92,727.5,727.92,755.0,760.42,767.5,768.33,794.58,798.75,800.83,804.58,836.25,836.67}
STRIP_RUNS[643]={701.67,702.92,755.0,760.42,767.5,768.33}
OCC_RUNS[644]={701.25,702.5,727.5,727.92,755.42,760.42,767.5,768.33,794.58,798.75,800.83,804.58,836.25,836.67}
STRIP_RUNS[644]={701.25,702.5,755.42,760.42,767.5,768.33}
OCC_RUNS[645]={701.25,702.5,754.58,755.0,755.42,760.42,767.5,768.33,795.0,798.33,801.25,804.58,836.25,836.67}
STRIP_RUNS[645]={701.25,702.5,755.42,760.42,767.5,768.33}
OCC_RUNS[646]={701.25,702.92,727.08,727.5,754.58,755.0,755.42,760.42,767.5,768.33,794.58,798.33,800.42,800.83,801.25,804.58,836.25,836.67}
STRIP_RUNS[646]={701.25,702.92,755.42,760.42,767.5,768.33}
OCC_RUNS[647]={701.25,702.5,727.08,727.5,754.58,755.0,755.42,760.42,767.08,768.33,794.58,798.33,801.25,804.58,836.25,836.67}
STRIP_RUNS[647]={701.25,702.5,755.42,760.42,767.08,768.33}
OCC_RUNS[648]={701.25,702.5,755.42,760.42,767.08,768.33,794.58,797.92,800.83,804.58,836.25,837.08,868.75,870.0}
STRIP_RUNS[648]={701.25,702.5,755.42,760.42,767.08,768.33}
OCC_RUNS[649]={701.25,702.5,755.42,760.42,767.08,768.33,794.17,797.92,800.83,804.17,836.67,837.08,868.75,869.17}
STRIP_RUNS[649]={701.25,702.5,755.42,760.42,767.08,768.33}
OCC_RUNS[650]={701.25,702.5,726.67,727.08,755.42,760.42,767.08,767.92,794.17,797.92,800.83,804.17,836.67,837.08,869.17,869.58,870.42,871.67}
STRIP_RUNS[650]={701.25,702.5,755.42,760.42,767.08,767.92}
OCC_RUNS[651]={701.25,702.92,726.67,727.08,755.42,760.42,767.08,767.92,794.17,797.92,800.83,804.17,836.67,837.08,868.33,869.58,870.0,870.42}
STRIP_RUNS[651]={701.25,702.92,755.42,760.42,767.08,767.92}
OCC_RUNS[652]={701.25,702.92,726.67,727.08,755.42,760.42,767.08,767.92,794.17,797.92,800.83,804.17,836.67,837.08,867.92,868.33,868.75,869.17,869.58,870.42}
STRIP_RUNS[652]={701.25,702.92,755.42,760.42,767.08,767.92}
OCC_RUNS[653]={701.67,702.5,755.42,760.42,767.08,767.92,794.17,797.92,800.0,800.42,800.83,803.75,836.67,837.5,866.67,867.08,868.33,868.75}
STRIP_RUNS[653]={701.67,702.5,755.42,760.42,767.08,767.92}
OCC_RUNS[654]={701.67,702.92,726.25,726.67,755.42,760.0,767.08,767.92,794.17,797.92,800.0,803.33,837.08,837.5,866.67,867.08,867.5,868.33}
STRIP_RUNS[654]={701.67,702.92,755.42,760.0,767.08,767.92}
OCC_RUNS[655]={701.67,702.5,726.25,726.67,755.42,760.42,766.67,767.92,794.17,797.92,800.0,803.33,837.08,837.5,872.92,873.33}
STRIP_RUNS[655]={701.67,702.5,755.42,760.42,766.67,767.92}
OCC_RUNS[656]={701.67,702.92,726.25,726.67,755.83,760.42,766.67,767.5,794.17,797.92,800.0,803.33,837.08,837.5,868.33,868.75,872.5,873.33}
STRIP_RUNS[656]={701.67,702.92,755.83,760.42,766.67,767.5}
OCC_RUNS[657]={701.25,702.5,726.25,726.67,755.83,760.0,766.67,767.5,794.17,797.92,800.0,803.33,837.08,837.5,866.67,867.08,867.5,867.92}
STRIP_RUNS[657]={701.25,702.5,755.83,760.0,766.67,767.5}
OCC_RUNS[658]={701.25,702.92,755.83,760.42,766.67,767.5,794.17,797.92,800.0,803.33,837.5,837.92}
STRIP_RUNS[658]={701.25,702.92,755.83,760.42,766.67,767.5}
OCC_RUNS[659]={701.25,702.92,755.83,760.0,766.67,767.5,794.58,797.92,800.0,803.33,837.5,837.92,868.33,868.75}
STRIP_RUNS[659]={701.25,702.92,755.83,760.0,766.67,767.5}
OCC_RUNS[660]={701.67,702.92,755.83,760.0,766.67,767.5,794.58,797.92,800.0,803.33,837.5,837.92,870.83,871.67}
STRIP_RUNS[660]={701.67,702.92,755.83,760.0,766.67,767.5}
OCC_RUNS[661]={701.67,702.08,725.83,726.25,755.83,760.42,766.67,767.5,794.58,797.92,800.0,803.33,837.5,837.92,867.92,868.33}
STRIP_RUNS[661]={755.83,760.42,766.67,767.5}
OCC_RUNS[662]={701.67,702.5,725.83,726.25,755.83,760.42,766.67,767.5,794.58,797.92,800.0,803.33,837.5,838.33}
STRIP_RUNS[662]={701.67,702.5,755.83,760.42,766.67,767.5}
OCC_RUNS[663]={701.67,702.5,725.83,726.25,755.83,760.0,766.25,767.08,794.58,797.92,800.0,803.33,837.92,838.33}
STRIP_RUNS[663]={701.67,702.5,755.83,760.0,766.25,767.08}
OCC_RUNS[664]={701.67,702.5,755.83,760.0,766.25,767.08,794.58,797.92,800.0,803.33,837.92,838.33}
STRIP_RUNS[664]={701.67,702.5,755.83,760.0,766.25,767.08}
OCC_RUNS[665]={701.67,702.5,755.83,760.42,766.25,767.08,794.58,797.92,800.0,803.33,837.92,838.33}
STRIP_RUNS[665]={701.67,702.5,755.83,760.42,766.25,767.08}
OCC_RUNS[666]={701.67,702.08,725.42,725.83,756.25,760.42,766.25,767.08,794.17,797.92,800.0,803.33,837.92,838.33}
STRIP_RUNS[666]={756.25,760.42,766.25,767.08}
OCC_RUNS[667]={701.25,702.08,725.42,725.83,756.25,760.42,766.25,767.08,794.17,797.92,800.0,803.33,837.92,838.75}
STRIP_RUNS[667]={701.25,702.08,756.25,760.42,766.25,767.08}
OCC_RUNS[668]={701.25,702.08,756.25,758.75,766.25,767.08,794.17,797.5,800.0,803.33,838.33,838.75}
STRIP_RUNS[668]={701.25,702.08,756.25,758.75,766.25,767.08}
OCC_RUNS[669]={701.67,702.08,756.25,758.75,760.0,760.42,766.25,767.08,794.17,797.5,800.0,803.33,838.33,838.75}
STRIP_RUNS[669]={756.25,758.75,766.25,767.08}
OCC_RUNS[670]={701.67,702.08,756.67,758.33,759.58,760.42,766.25,767.08,794.17,797.5,800.0,803.33,838.33,838.75,884.17,884.58}
STRIP_RUNS[670]={756.67,758.33,759.58,760.42,766.25,767.08}
OCC_RUNS[671]={701.25,702.08,725.0,725.42,756.25,757.92,766.25,767.08,793.33,793.75,794.17,797.5,800.0,803.33,838.33,838.75,882.92,883.33,883.75,884.17}
STRIP_RUNS[671]={701.25,702.08,756.25,757.92,766.25,767.08}
OCC_RUNS[672]={701.25,702.08,725.0,725.42,756.25,758.33,758.75,760.42,760.83,761.25,766.25,767.08,793.33,793.75,794.17,797.5,800.0,803.33,838.33,839.17,883.33,884.17,885.83,886.25}
STRIP_RUNS[672]={701.25,702.08,756.25,758.33,758.75,760.42,766.25,767.08}
OCC_RUNS[673]={701.25,702.08,756.25,758.33,766.25,767.08,793.33,793.75,794.17,797.08,799.58,803.33,838.33,839.17,883.75,885.83}
STRIP_RUNS[673]={701.25,702.08,756.25,758.33,766.25,767.08}
OCC_RUNS[674]={701.25,702.08,756.67,758.33,759.17,760.0,766.25,767.08,793.33,793.75,794.17,797.08,799.58,803.33,838.75,839.17,881.25,881.67,883.33,883.75,884.58,885.83,887.92,890.0}
STRIP_RUNS[674]={701.25,702.08,756.67,758.33,759.17,760.0,766.25,767.08}
OCC_RUNS[675]={701.25,702.08,756.67,758.33,758.75,760.83,766.25,766.67,793.33,797.08,799.58,802.92,838.75,839.17,881.25,882.08,885.0,885.83,886.67,887.08,887.5,889.58,890.42,891.25}
STRIP_RUNS[675]={701.25,702.08,756.67,758.33,758.75,760.83}
OCC_RUNS[676]={701.25,702.08,724.58,725.0,756.67,758.33,758.75,760.42,766.25,766.67,793.33,797.08,799.58,802.92,838.75,839.58,881.25,882.5,885.42,888.75,890.42,891.25,891.67,892.08}
STRIP_RUNS[676]={701.25,702.08,756.67,758.33,758.75,760.42}
OCC_RUNS[677]={701.25,702.08,724.58,725.0,757.08,758.33,758.75,760.42,766.25,766.67,793.33,797.08,799.58,802.92,838.75,839.58,880.0,880.42,881.25,881.67,882.08,882.92,884.17,885.42,887.92,891.25}
STRIP_RUNS[677]={701.25,702.08,757.08,758.33,758.75,760.42}
OCC_RUNS[678]={701.25,701.67,757.08,758.33,758.75,759.17,761.25,761.67,765.83,766.67,793.33,797.08,799.58,802.92,839.17,839.58,880.42,880.83,881.67,883.75,884.17,886.25,887.5,889.17,889.58,892.5}
STRIP_RUNS[678]={757.08,758.33,765.83,766.67}
OCC_RUNS[679]={701.25,701.67,757.08,758.33,759.58,760.0,765.83,766.67,793.33,797.08,799.58,802.92,839.17,839.58,879.58,880.42,881.25,883.75,884.17,887.08,887.5,889.58,890.0,892.5}
STRIP_RUNS[679]={757.08,758.33,765.83,766.67}
OCC_RUNS[680]={701.25,701.67,756.67,758.33,760.83,761.25,765.83,766.67,793.33,797.08,799.58,802.92,839.17,840.0,878.75,879.17,880.0,880.42,880.83,882.92,883.33,883.75,884.17,887.5,887.92,889.58}
STRIP_RUNS[680]={756.67,758.33,765.83,766.67}
OCC_RUNS[681]={701.25,701.67,756.67,758.33,760.83,761.25,765.83,766.67,793.33,797.08,799.58,802.92,839.17,840.0,880.42,882.92,884.58,885.42,886.25,889.58,893.33,894.17,895.0,895.42}
STRIP_RUNS[681]={756.67,758.33,765.83,766.67}
OCC_RUNS[682]={701.25,701.67,756.67,758.33,760.83,761.25,765.83,766.67,793.33,793.75,794.17,797.08,799.58,802.92,839.58,840.0,879.17,879.58,880.42,882.5,882.92,883.33,885.0,885.42,886.25,889.58,895.42,895.83}
STRIP_RUNS[682]={756.67,758.33,765.83,766.67}
OCC_RUNS[683]={701.25,701.67,757.08,758.33,765.83,766.25,793.33,797.08,799.17,802.92,839.58,840.0,878.33,878.75,879.58,880.83,881.25,882.08,882.5,882.92,885.83,886.67,887.92,888.33,888.75,890.42,892.08,894.58}
STRIP_RUNS[683]={757.08,758.33}
OCC_RUNS[684]={701.25,701.67,757.5,758.33,758.75,759.17,760.42,761.25,765.83,766.25,793.33,797.08,798.75,802.92,839.58,840.42,879.17,880.83,881.25,881.67,882.5,883.33,884.58,888.33,889.17,889.58,892.92,894.17,897.08,897.5}
STRIP_RUNS[684]={757.5,758.33,760.42,761.25}
OCC_RUNS[685]={701.25,702.08,757.5,758.75,760.83,761.25,765.83,766.25,793.33,797.08,798.75,802.92,839.58,840.42,878.75,879.58,880.0,881.25,882.08,883.75,884.58,885.0,885.83,889.58,890.42,890.83,893.33,893.75}
STRIP_RUNS[685]={701.25,702.08,757.5,758.75}
OCC_RUNS[686]={701.25,702.08,757.5,758.75,760.0,761.25,765.83,766.25,793.33,796.67,798.33,802.92,840.0,840.42,880.0,881.25,881.67,885.42,885.83,889.17,891.25,892.08,892.5,892.92}
STRIP_RUNS[686]={701.25,702.08,757.5,758.75,760.0,761.25}
OCC_RUNS[687]={701.25,702.08,757.5,758.75,759.58,761.25,765.42,766.25,793.33,796.67,798.75,802.92,840.0,840.42,881.25,885.42,885.83,887.5,888.33,888.75,891.25,892.08}
STRIP_RUNS[687]={701.25,702.08,757.5,758.75,759.58,761.25,765.42,766.25}
OCC_RUNS[688]={701.25,702.08,757.08,758.75,760.0,760.42,765.42,766.25,793.33,796.67,798.33,802.92,840.0,840.83,880.83,881.25,881.67,885.83,886.67,887.5,888.33,888.75,889.17,890.0,890.83,892.5,899.58,900.0}
STRIP_RUNS[688]={701.25,702.08,757.08,758.75,765.42,766.25}
OCC_RUNS[689]={701.25,702.08,757.08,759.17,765.42,766.25,792.92,796.67,797.92,802.92,840.0,840.83,882.08,885.0,886.67,887.5,888.33,888.75,889.17,890.0,891.67,892.08}
STRIP_RUNS[689]={701.25,702.08,757.08,759.17,765.42,766.25}
OCC_RUNS[690]={701.25,702.08,757.5,759.17,760.0,760.42,765.42,766.25,792.92,796.67,797.5,802.92,840.42,840.83,881.67,882.5,882.92,883.33,884.17,884.58,885.0,886.25,887.5,889.58}
STRIP_RUNS[690]={701.25,702.08,757.5,759.17,765.42,766.25}
OCC_RUNS[691]={701.25,702.08,757.5,759.17,765.42,766.25,792.92,796.67,797.5,802.92,840.42,840.83,883.75,884.58,885.42,886.25,887.5,887.92,888.33,890.83}
STRIP_RUNS[691]={701.25,702.08,757.5,759.17,765.42,766.25}
OCC_RUNS[692]={701.25,702.08,757.92,759.17,765.42,766.25,792.92,793.33,793.75,796.25,797.5,802.92,840.42,840.83,882.5,882.92,883.75,884.17,888.75,889.17}
STRIP_RUNS[692]={701.25,702.08,757.92,759.17,765.42,766.25}
OCC_RUNS[693]={701.25,702.08,757.5,758.75,765.42,765.83,792.5,793.33,793.75,796.25,796.67,802.92,840.42,840.83,882.5,884.17}
STRIP_RUNS[693]={701.25,702.08,757.5,758.75}
OCC_RUNS[694]={701.25,702.08,757.5,758.75,760.0,760.42,765.42,765.83,792.5,793.33,793.75,796.25,796.67,802.92,840.42,840.83,881.67,882.08,883.33,883.75,884.17,884.58,903.33,903.75}
STRIP_RUNS[694]={701.25,702.08,757.5,758.75}
OCC_RUNS[695]={701.25,702.08,757.92,758.75,765.42,765.83,792.5,793.33,793.75,802.92,840.42,840.83}
STRIP_RUNS[695]={701.25,702.08,757.92,758.75}
OCC_RUNS[696]={701.25,702.08,757.92,759.17,765.42,765.83,792.5,793.33,793.75,798.75,799.17,802.92,840.83,841.25}
STRIP_RUNS[696]={701.25,702.08,757.92,759.17}
OCC_RUNS[697]={701.25,702.08,757.92,759.17,765.42,765.83,792.5,793.33,793.75,797.92,799.17,802.5,840.83,841.25,905.0,905.42}
STRIP_RUNS[697]={701.25,702.08,757.92,759.17}
OCC_RUNS[698]={701.67,702.08,758.33,759.58,765.42,765.83,792.08,792.5,792.92,793.33,793.75,797.5,799.17,802.5,840.83,841.25,905.83,906.25}
STRIP_RUNS[698]={758.33,759.58}
OCC_RUNS[699]={701.67,702.08,757.92,759.58,765.42,765.83,792.08,792.5,792.92,793.33,793.75,796.67,799.58,802.5,840.83,841.25}
STRIP_RUNS[699]={757.92,759.58}
OCC_RUNS[700]={701.67,702.08,757.92,759.58,760.0,760.83,765.42,765.83,792.08,792.5,792.92,793.33,793.75,796.67,799.58,802.5}
STRIP_RUNS[700]={757.92,759.58,760.0,760.83}
OCC_RUNS[701]={701.67,702.08,757.92,759.17,760.0,760.42,765.42,765.83,792.08,792.5,792.92,793.33,793.75,796.25,799.58,802.5}
STRIP_RUNS[701]={757.92,759.17}
OCC_RUNS[702]={701.67,702.08,757.92,759.17,760.0,760.42,765.42,765.83,792.08,792.5,793.75,796.25,799.58,802.5,841.25,841.67,907.92,908.33}
STRIP_RUNS[702]={757.92,759.17}
OCC_RUNS[703]={701.67,702.08,758.33,759.17,765.0,765.83,791.67,792.08,793.33,796.25,799.58,802.5,841.25,841.67}
STRIP_RUNS[703]={758.33,759.17,765.0,765.83}
OCC_RUNS[704]={701.67,702.08,758.33,759.58,765.0,765.83,791.67,792.08,793.33,796.25,799.17,802.5,841.25,841.67}
STRIP_RUNS[704]={758.33,759.58,765.0,765.83}
OCC_RUNS[705]={701.67,702.08,758.75,759.58,765.0,765.83,791.67,792.08,793.33,796.25,799.17,802.5,841.25,842.08}
STRIP_RUNS[705]={758.75,759.58,765.0,765.83}
OCC_RUNS[706]={701.67,702.08,758.75,759.58,765.0,765.42,791.67,792.08,793.33,796.25,799.17,802.5,841.67,842.08,899.58,900.0}
STRIP_RUNS[706]={758.75,759.58}
OCC_RUNS[707]={701.67,702.08,758.33,760.0,765.0,765.42,791.25,792.08,793.33,796.25,799.17,802.5,841.67,842.08,910.83,911.25}
STRIP_RUNS[707]={758.33,760.0}
OCC_RUNS[708]={701.25,702.08,758.33,760.0,765.0,765.42,791.25,791.67,792.5,792.92,793.33,796.25,799.17,802.5,841.67,842.08,900.83,901.25,902.08,902.5}
STRIP_RUNS[708]={701.25,702.08,758.33,760.0}
OCC_RUNS[709]={701.25,702.08,758.75,760.0,791.25,791.67,792.5,792.92,793.33,796.25,799.17,802.5,842.08,842.5,905.83,906.25}
STRIP_RUNS[709]={701.25,702.08,758.75,760.0}
OCC_RUNS[710]={701.25,702.08,758.75,760.0,765.0,765.42,791.25,791.67,792.5,792.92,793.33,796.25,799.17,802.5,842.08,842.5}
STRIP_RUNS[710]={701.25,702.08,758.75,760.0}
OCC_RUNS[711]={701.25,701.67,758.75,759.58,765.0,765.42,790.83,791.67,792.5,792.92,793.33,795.83,799.17,802.5,842.08,842.5,913.33,913.75}
STRIP_RUNS[711]={758.75,759.58}
OCC_RUNS[712]={758.75,759.58,765.0,765.42,790.83,791.25,792.5,792.92,793.33,795.83,799.58,802.5,842.08,842.5,913.75,914.17}
STRIP_RUNS[712]={758.75,759.58}
OCC_RUNS[713]={759.17,760.0,765.0,765.42,790.83,791.25,792.5,792.92,793.33,795.83,798.75,799.17,799.58,802.5,842.08,842.5}
STRIP_RUNS[713]={759.17,760.0}
OCC_RUNS[714]={758.75,760.0,765.0,765.42,790.42,791.25,792.5,792.92,793.33,795.83,798.75,799.17,799.58,802.5,842.08,842.5}
STRIP_RUNS[714]={758.75,760.0}
OCC_RUNS[715]={758.75,760.42,765.0,765.42,790.42,790.83,792.5,792.92,793.33,795.83,799.58,802.5}
STRIP_RUNS[715]={758.75,760.42}
OCC_RUNS[716]={759.17,760.42,790.42,790.83,793.33,795.83,799.58,802.5,912.92,913.33,916.25,916.67}
STRIP_RUNS[716]={759.17,760.42}
OCC_RUNS[717]={758.75,760.42,760.83,761.67,790.42,790.83,792.5,792.92,793.33,795.83,799.58,802.5,916.25,917.08}
STRIP_RUNS[717]={758.75,760.42,760.83,761.67}
OCC_RUNS[718]={759.17,760.42,790.0,790.42,792.5,792.92,793.33,795.83,799.58,802.08,842.92,843.33,913.75,914.58}
STRIP_RUNS[718]={759.17,760.42}
OCC_RUNS[719]={759.17,760.42,761.25,761.67,790.0,790.42,792.5,792.92,793.33,795.83,799.58,802.08,842.92,843.33,912.08,912.5,918.33,918.75}
STRIP_RUNS[719]={759.17,760.42}
OCC_RUNS[720]={759.58,760.0,789.58,790.42,792.5,792.92,793.33,795.83,799.17,802.08,842.92,843.33,913.75,914.17}
OCC_RUNS[721]={759.17,760.0,789.58,790.0,792.5,792.92,793.33,795.83,799.17,802.08,842.92,843.33,912.5,913.33}
STRIP_RUNS[721]={759.17,760.0}
OCC_RUNS[722]={759.17,760.0,789.58,790.0,792.5,795.83,799.17,802.08,842.92,843.33}
STRIP_RUNS[722]={759.17,760.0}
OCC_RUNS[723]={759.17,760.42,789.17,790.0,792.5,795.83,799.17,802.08,843.33,843.75,911.67,912.08}
STRIP_RUNS[723]={759.17,760.42}
OCC_RUNS[724]={759.17,760.42,789.17,789.58,792.5,795.83,799.17,802.08,843.33,843.75,910.83,911.67}
STRIP_RUNS[724]={759.17,760.42}
OCC_RUNS[725]={759.17,760.42,761.67,762.08,789.17,789.58,792.5,795.83,799.17,802.08,843.33,843.75}
STRIP_RUNS[725]={759.17,760.42}
OCC_RUNS[726]={759.17,760.42,761.67,762.08,789.17,789.58,792.08,795.83,798.75,802.08,843.33,843.75}
STRIP_RUNS[726]={759.17,760.42}
OCC_RUNS[727]={759.17,760.42,761.67,762.08,788.75,789.58,792.08,792.5,792.92,795.83,799.17,802.08,843.33,843.75}
STRIP_RUNS[727]={759.17,760.42}
OCC_RUNS[728]={759.58,760.42,788.75,789.17,792.08,792.5,792.92,795.83,798.75,802.08}
STRIP_RUNS[728]={759.58,760.42}
OCC_RUNS[729]={759.58,760.42,788.75,789.17,792.08,792.5,792.92,795.42,798.33,798.75,799.17,802.08,843.75,844.17}
STRIP_RUNS[729]={759.58,760.42}
OCC_RUNS[730]={759.58,760.42,761.67,762.08,788.75,789.17,792.08,792.5,792.92,795.42,798.33,802.08,843.75,844.17}
STRIP_RUNS[730]={759.58,760.42}
OCC_RUNS[731]={759.58,760.42,788.33,788.75,792.08,792.5,792.92,795.42,798.75,802.08,843.75,844.17}
STRIP_RUNS[731]={759.58,760.42}
OCC_RUNS[732]={759.58,760.83,788.33,788.75,792.08,792.5,792.92,795.42,798.33,802.08,843.75,844.17}
STRIP_RUNS[732]={759.58,760.83}
OCC_RUNS[733]={759.58,760.83,788.33,788.75,792.08,792.5,792.92,795.42,797.92,802.08,926.25,926.67}
STRIP_RUNS[733]={759.58,760.83}
OCC_RUNS[734]={759.58,760.83,787.92,788.75,792.08,792.5,792.92,795.42,797.5,802.08,844.17,844.58}
STRIP_RUNS[734]={759.58,760.83,787.92,788.75}
OCC_RUNS[735]={760.0,760.83,787.92,788.33,792.08,795.42,797.5,802.08,844.17,844.58}
STRIP_RUNS[735]={760.0,760.83}
OCC_RUNS[736]={759.58,760.83,787.92,788.33,792.08,795.42,797.08,802.08,844.17,844.58}
STRIP_RUNS[736]={759.58,760.83}
OCC_RUNS[737]={759.58,760.83,787.92,788.33,792.08,795.42,797.08,802.08,844.17,844.58}
STRIP_RUNS[737]={759.58,760.83}
OCC_RUNS[738]={760.0,760.83,787.5,787.92,792.08,795.42,796.67,798.33,799.17,801.67,844.17,844.58}
STRIP_RUNS[738]={760.0,760.83}
OCC_RUNS[739]={760.0,760.83,787.5,787.92,792.08,795.42,796.25,798.33,799.17,801.67,844.17,845.0}
STRIP_RUNS[739]={760.0,760.83}
OCC_RUNS[740]={760.0,760.83,787.5,787.92,792.08,795.42,795.83,797.92,799.17,801.67,844.58,845.0}
STRIP_RUNS[740]={760.0,760.83}
OCC_RUNS[741]={760.0,760.83,787.08,787.5,792.08,795.42,795.83,797.5,798.75,801.67,844.58,845.0}
STRIP_RUNS[741]={760.0,760.83}
OCC_RUNS[742]={760.0,760.83,787.08,787.5,792.08,797.08,798.75,801.67,844.58,845.0}
STRIP_RUNS[742]={760.0,760.83}
OCC_RUNS[743]={760.0,761.25,787.08,787.5,792.08,796.67,798.75,801.67,845.0,845.42}
STRIP_RUNS[743]={760.0,761.25}
OCC_RUNS[744]={760.0,761.25,791.67,796.67,798.75,801.67,845.0,845.42}
STRIP_RUNS[744]={760.0,761.25}
OCC_RUNS[745]={760.42,761.25,764.17,764.58,786.67,787.08,791.67,796.25,798.75,801.67}
STRIP_RUNS[745]={760.42,761.25}
OCC_RUNS[746]={760.0,761.25,786.67,787.08,791.67,795.83,798.75,801.67}
STRIP_RUNS[746]={760.0,761.25}
OCC_RUNS[747]={760.0,761.25,786.67,787.08,792.08,795.83,798.75,801.67}
STRIP_RUNS[747]={760.0,761.25}
OCC_RUNS[748]={760.42,761.25,792.08,795.42,798.75,801.67}
STRIP_RUNS[748]={760.42,761.25}
OCC_RUNS[749]={760.42,761.25,792.08,795.0,798.75,801.67,845.42,845.83,935.42,935.83}
STRIP_RUNS[749]={760.42,761.25}
OCC_RUNS[750]={760.42,761.25,786.25,786.67,791.67,795.0,798.75,801.67,845.83,846.25,935.83,936.25}
STRIP_RUNS[750]={760.42,761.25}
OCC_RUNS[751]={760.42,761.25,786.25,786.67,791.67,795.0,798.33,801.67,845.83,846.25}
STRIP_RUNS[751]={760.42,761.25}
OCC_RUNS[752]={760.42,761.25,786.25,786.67,791.67,795.0,798.75,801.67,845.83,846.25}
STRIP_RUNS[752]={760.42,761.25}
OCC_RUNS[753]={760.42,761.67,791.67,795.0,798.75,801.67}
STRIP_RUNS[753]={760.42,761.67}
OCC_RUNS[754]={760.42,761.67,785.83,786.25,791.67,795.0,798.75,801.67,845.83,846.25}
STRIP_RUNS[754]={760.42,761.67}
OCC_RUNS[755]={760.83,761.67,785.83,786.25,791.67,792.08,792.5,795.0,798.75,801.67}
STRIP_RUNS[755]={760.83,761.67}
OCC_RUNS[756]={760.42,761.67,785.83,786.25,792.5,795.0,798.75,801.67}
STRIP_RUNS[756]={760.42,761.67}
OCC_RUNS[757]={760.42,761.67,764.58,765.0,792.5,795.0,798.75,801.67}
STRIP_RUNS[757]={760.42,761.67}
OCC_RUNS[758]={760.83,761.67,785.42,785.83,792.08,795.0,798.33,801.67,846.25,846.67}
STRIP_RUNS[758]={760.83,761.67}
OCC_RUNS[759]={760.83,761.67,785.42,785.83,791.67,795.0,798.33,801.25,846.25,846.67}
STRIP_RUNS[759]={760.83,761.67}
OCC_RUNS[760]={760.83,761.67,791.67,795.0,798.33,801.25,846.25,847.08}
STRIP_RUNS[760]={760.83,761.67}
OCC_RUNS[761]={760.83,761.67,785.0,785.42,791.67,795.0,798.33,801.25,846.67,847.08}
STRIP_RUNS[761]={760.83,761.67}
OCC_RUNS[762]={760.83,761.67,785.0,785.42,791.67,795.0,798.33,801.25,846.67,847.08}
STRIP_RUNS[762]={760.83,761.67}
OCC_RUNS[763]={761.25,762.08,791.67,795.0,798.33,801.25,846.67,847.08}
STRIP_RUNS[763]={761.25,762.08}
OCC_RUNS[764]={761.25,762.08,784.58,785.0,791.67,795.0,798.75,801.25}
STRIP_RUNS[764]={761.25,762.08}
OCC_RUNS[765]={761.25,762.08,784.58,785.0,792.08,795.0,798.75,801.25}
STRIP_RUNS[765]={761.25,762.08}
OCC_RUNS[766]={761.25,761.67,784.58,785.0,792.08,795.0,798.75,801.25}
OCC_RUNS[767]={761.25,762.08,792.08,795.0,798.75,801.25}
STRIP_RUNS[767]={761.25,762.08}
OCC_RUNS[768]={761.25,762.08,784.17,784.58,792.08,794.58,798.75,801.25,847.08,847.5}
STRIP_RUNS[768]={761.25,762.08}
OCC_RUNS[769]={761.25,762.08,792.08,794.58,798.33,801.25,847.08,847.92}
STRIP_RUNS[769]={761.25,762.08}
OCC_RUNS[770]={761.25,762.08,783.75,784.17,791.25,791.67,792.08,794.58,798.33,801.25,847.5,847.92}
OCC_RUNS[771]={761.67,762.5,783.75,784.17,791.25,791.67,792.08,794.58,798.33,801.25,847.5,847.92}
OCC_RUNS[772]={761.67,762.5,783.75,784.17,791.25,791.67,792.08,794.58,798.33,801.25,847.5,847.92}
OCC_RUNS[773]={761.67,762.5,783.33,783.75,791.25,791.67,792.08,794.58,798.33,801.25}
OCC_RUNS[774]={761.67,762.5,783.33,783.75,791.25,791.67,792.08,794.58,797.92,801.25}
OCC_RUNS[775]={761.67,762.5,783.33,783.75,791.25,791.67,792.08,794.58,797.92,801.25,947.5,947.92}
OCC_RUNS[776]={761.67,762.5,792.08,794.58,797.5,801.25,847.92,848.33}
OCC_RUNS[777]={762.08,762.5,782.92,783.33,791.67,794.58,797.08,801.25,847.92,848.33}
OCC_RUNS[778]={762.08,762.92,782.92,783.33,791.67,794.58,796.67,801.25,847.92,848.33,945.42,945.83}
OCC_RUNS[779]={762.08,762.92,791.67,794.58,796.25,801.25,848.33,848.75,944.58,945.42}
OCC_RUNS[780]={762.08,762.92,782.5,782.92,791.67,794.58,796.25,797.92,798.33,801.25,848.33,848.75}
OCC_RUNS[781]={762.08,762.92,782.5,782.92,791.67,794.58,795.83,797.92,798.33,800.83,848.33,848.75}
OCC_RUNS[782]={762.08,762.92,782.5,782.92,791.67,794.58,795.83,797.5,798.33,800.83,848.33,848.75,946.67,947.08}
OCC_RUNS[783]={762.5,762.92,791.67,794.58,795.0,797.08,798.33,800.83}
OCC_RUNS[784]={762.5,762.92,782.08,782.5,791.67,794.58,795.0,796.67,798.33,800.83}
OCC_RUNS[785]={762.5,762.92,782.08,782.5,791.67,796.25,798.33,800.83,848.75,849.17}
OCC_RUNS[786]={762.5,763.33,782.08,782.5,791.67,796.25,798.33,800.83,947.08,947.5}
OCC_RUNS[787]={762.5,763.33,791.67,795.83,798.33,800.83,946.67,947.08}
OCC_RUNS[788]={762.5,763.33,781.67,782.08,791.67,795.42,798.33,800.83,849.17,849.58,950.0,950.83,955.83,956.25}
OCC_RUNS[789]={762.5,763.33,781.67,782.08,791.67,795.0,798.33,800.83,849.17,849.58,949.58,950.42,955.83,956.67}
OCC_RUNS[790]={762.5,763.33,781.67,782.08,791.67,795.0,797.92,800.83,849.17,849.58,949.17,950.0,956.25,957.08}
OCC_RUNS[791]={762.5,763.33,781.25,781.67,791.67,794.58,797.92,800.83,948.75,949.58}
OCC_RUNS[792]={762.92,763.33,781.25,781.67,791.67,794.17,797.92,800.83,948.33,949.17,955.0,955.83,957.5,957.92}
OCC_RUNS[793]={762.92,763.33,791.67,794.17,797.92,800.83,952.92,953.33,954.17,955.42,958.33,958.75}
OCC_RUNS[794]={762.92,763.33,780.83,781.25,791.67,794.17,797.92,800.83,849.58,850.0,954.17,955.42,955.83,956.25,958.75,959.17}
OCC_RUNS[795]={406.25,407.5,762.92,763.75,780.83,781.25,791.25,794.17,797.92,800.83,849.58,850.0,947.08,947.5,953.75,956.67,959.17,959.58}
OCC_RUNS[796]={406.25,407.5,762.92,763.75,780.83,781.25,791.25,794.17,797.92,800.83,849.58,850.0,953.75,955.42,956.67,957.08,959.58,960.0}
OCC_RUNS[797]={405.83,407.5,762.92,763.75,791.25,794.17,797.92,800.83,849.58,850.0,951.67,952.08,953.33,956.25}
OCC_RUNS[798]={405.42,407.08,763.33,763.75,780.42,780.83,791.25,794.17,797.92,800.83,850.0,850.42,952.08,955.42}
OCC_RUNS[799]={405.42,407.08,763.33,763.75,780.42,780.83,791.25,794.17,797.92,800.83,950.42,950.83,951.67,955.0}
OCC_RUNS[800]={405.0,406.67,763.33,763.75,791.25,794.17,797.92,800.83,850.0,850.42,950.0,953.75,955.83,956.25}
OCC_RUNS[801]={405.0,406.67,763.33,764.17,791.25,794.17,797.92,800.83,950.83,952.08,952.5,953.33,955.42,956.25}
OCC_RUNS[802]={404.58,406.25,763.33,764.17,780.0,780.42,791.25,794.17,797.92,800.42,951.67,952.08,955.0,955.83}
OCC_RUNS[803]={404.17,405.83,763.75,764.17,791.25,794.17,797.92,800.42,951.67,952.08,957.08,958.33}
OCC_RUNS[804]={404.17,405.83,763.75,764.17,791.25,794.17,797.92,800.42,959.17,959.58}
OCC_RUNS[805]={403.75,405.42,763.75,764.17,779.58,780.0,791.25,794.17,797.92,800.42}
OCC_RUNS[806]={403.75,405.42,763.75,764.58,779.58,780.0,791.25,793.75,797.92,800.42,957.08,957.5}
OCC_RUNS[807]={403.33,405.0,763.75,764.58,791.25,793.75,797.92,800.42,958.33,958.75}
OCC_RUNS[808]={402.92,404.58,763.75,764.58,779.17,779.58,791.25,793.75,797.92,800.42,957.08,957.5}
OCC_RUNS[809]={402.5,404.58,779.17,779.58,791.25,793.75,797.92,800.42,850.83,851.25,957.08,957.5}
OCC_RUNS[810]={402.5,404.17,791.25,793.75,797.5,800.42,850.83,851.25}
OCC_RUNS[811]={402.08,404.17,791.25,793.75,797.5,800.42}
OCC_RUNS[812]={402.08,403.75,791.25,793.75,797.5,800.42,851.25,851.67}
OCC_RUNS[813]={401.67,403.33,778.75,779.17,790.83,793.75,797.5,800.42,851.25,851.67}
OCC_RUNS[814]={401.25,403.33,778.75,779.17,790.83,793.75,797.5,800.42}
OCC_RUNS[815]={401.25,402.92,790.83,793.75,797.5,800.42}
OCC_RUNS[816]={400.83,402.92,790.83,793.75,797.5,800.42,851.67,852.08}
OCC_RUNS[817]={400.83,402.92,778.33,778.75,790.83,793.75,797.5,800.42,851.67,852.08}
OCC_RUNS[818]={400.42,402.5,790.83,793.75,797.5,800.42,851.67,852.08,968.75,969.17}
OCC_RUNS[819]={400.0,402.08,790.83,793.75,797.5,800.42,968.33,968.75,971.25,971.67}
OCC_RUNS[820]={400.0,402.08,777.92,778.33,790.83,793.75,797.5,800.42,967.92,968.75,971.67,972.08}
OCC_RUNS[821]={399.58,401.67,777.92,778.33,790.83,793.75,797.5,800.42,968.75,969.17}
OCC_RUNS[822]={391.25,391.67,392.92,395.42,399.58,401.67,790.83,793.75,797.08,800.42,852.08,852.5,967.92,969.17,972.5,972.92}
OCC_RUNS[823]={389.58,396.25,399.17,401.25,777.5,777.92,790.83,793.75,796.67,800.0,968.75,969.17,973.33,973.75}
OCC_RUNS[824]={388.75,397.5,399.17,400.83,777.5,777.92,790.83,793.75,796.67,800.0,973.75,974.17}
OCC_RUNS[825]={387.92,398.33,399.58,400.83,790.83,793.33,796.25,800.0,967.5,968.33}
OCC_RUNS[826]={387.08,398.75,400.0,400.42,790.83,793.33,795.83,800.0,967.08,967.5}
OCC_RUNS[827]={386.67,399.17,790.83,793.75,795.83,800.0}
OCC_RUNS[828]={385.83,400.0,790.83,793.75,795.0,797.08,797.5,800.0}
OCC_RUNS[829]={385.83,400.42,790.83,793.75,795.0,796.67,797.5,800.0}
OCC_RUNS[830]={385.42,400.83,776.67,777.08,790.42,793.75,794.58,796.25,797.08,800.0}
OCC_RUNS[831]={385.0,400.83,776.67,777.08,790.42,793.75,794.58,796.25,797.08,800.0}
OCC_RUNS[832]={385.0,401.25,790.42,793.75,794.17,795.83,797.08,800.0}
OCC_RUNS[833]={384.58,401.67,776.25,776.67,790.0,793.33,793.75,795.42,797.08,800.0}
OCC_RUNS[834]={384.58,401.67,776.25,776.67,790.0,795.0,797.08,800.0}
OCC_RUNS[835]={384.17,402.08,790.42,795.0,797.08,800.0,853.33,853.75}
OCC_RUNS[836]={384.17,402.08,790.42,794.58,797.08,800.0}
OCC_RUNS[837]={383.75,402.5,775.83,776.25,790.42,794.17,797.08,800.0}
OCC_RUNS[838]={383.75,402.5,790.42,794.17,797.08,800.0}
OCC_RUNS[839]={383.75,402.5,790.0,794.17,797.08,800.0}
OCC_RUNS[840]={383.33,402.92,775.42,775.83,790.0,793.33,793.75,794.17,797.08,800.0,853.75,854.17}
OCC_RUNS[841]={383.33,402.92,775.42,775.83,790.0,793.33,797.08,800.0,853.75,854.17}
OCC_RUNS[842]={383.33,402.92,790.0,793.33,797.08,800.0,853.75,854.17,981.67,982.08}
OCC_RUNS[843]={383.33,402.92,775.0,775.42,790.0,793.33,797.08,800.0,976.25,977.08,982.08,982.5}
OCC_RUNS[844]={383.33,403.33,790.0,792.92,797.08,799.58,976.25,976.67,977.08,977.5,982.5,983.33}
OCC_RUNS[845]={383.33,402.92,790.0,792.92,797.08,799.58,975.0,975.42,980.0,981.25,981.67,982.08,983.33,983.75}
OCC_RUNS[846]={383.33,402.92,774.58,775.0,790.0,792.92,797.08,799.58,977.5,977.92,980.42,981.25,983.75,984.17}
OCC_RUNS[847]={383.33,402.92,774.58,775.0,790.0,792.92,797.08,799.58,977.5,977.92,980.42,981.25,981.67,982.08}
OCC_RUNS[848]={383.33,402.92,790.0,792.92,797.08,799.58,977.08,977.5,979.58,980.0,983.33,983.75}
OCC_RUNS[849]={383.33,402.92,774.17,774.58,790.0,792.92,797.08,799.58,976.67,977.08,979.17,979.58}
OCC_RUNS[850]={383.33,402.5,790.0,792.92,796.67,799.58,854.58,855.0,979.17,979.58,982.08,982.5}
OCC_RUNS[851]={383.33,402.5,790.0,792.92,796.67,799.58,854.58,855.0,982.08,982.5}
OCC_RUNS[852]={383.33,402.5,790.0,792.92,796.67,799.58,854.58,855.0,978.75,979.17,985.42,985.83}
OCC_RUNS[853]={382.5,382.92,383.33,402.08,790.0,792.92,796.67,799.58,855.0,855.42,987.08,987.5}
OCC_RUNS[854]={382.5,382.92,383.33,402.08,790.0,792.92,796.67,799.58,855.0,855.42,987.5,987.92}
OCC_RUNS[855]={382.5,382.92,383.33,401.67,790.0,792.92,796.67,799.58,855.0,855.42,987.92,988.33}
OCC_RUNS[856]={382.5,382.92,383.33,401.67,773.33,773.75,790.0,792.92,796.67,799.58}
OCC_RUNS[857]={382.5,401.67,789.58,792.92,796.67,799.58}
OCC_RUNS[858]={382.92,400.83,772.92,773.33,789.58,792.92,796.67,799.58}
OCC_RUNS[859]={382.92,400.83,772.92,773.33,790.0,792.92,796.67,799.58,855.42,855.83}
OCC_RUNS[860]={383.33,400.42,790.0,792.92,796.67,799.58,855.42,855.83}
OCC_RUNS[861]={383.75,400.0,790.0,792.92,796.67,799.58}
OCC_RUNS[862]={384.17,394.17,394.58,399.58,772.5,772.92,790.0,792.92,796.67,799.58,855.83,856.25,990.83,991.25}
OCC_RUNS[863]={385.0,385.83,386.25,394.17,395.0,398.75,772.5,772.92,790.0,792.5,796.67,799.58}
OCC_RUNS[864]={384.58,385.83,386.25,394.17,395.0,398.33,790.0,792.5,796.67,799.58}
OCC_RUNS[865]={384.58,385.83,386.25,394.58,395.0,397.5,790.0,792.5,796.67,799.17,855.83,856.25}
OCC_RUNS[866]={384.58,385.42,386.25,394.58,395.0,396.25,772.08,772.5,790.0,792.5,796.67,799.17,855.83,856.25}
OCC_RUNS[867]={384.58,385.42,386.25,394.58,395.0,395.42,772.08,772.5,790.0,792.5,796.67,799.17}
OCC_RUNS[868]={384.17,385.42,385.83,394.58,395.0,395.83,789.58,792.5,796.67,799.17,993.75,994.17}
OCC_RUNS[869]={384.17,385.42,385.83,394.58,395.0,395.83,771.67,772.08,789.58,792.5,796.67,799.17,856.25,856.67}
OCC_RUNS[870]={384.17,385.42,385.83,394.58,395.0,395.83,771.67,772.08,789.58,792.5,796.25,799.17}
OCC_RUNS[871]={384.17,385.42,385.83,394.58,395.0,395.83,789.58,792.5,796.25,799.17}
OCC_RUNS[872]={384.17,385.42,385.83,394.58,395.0,395.83,789.58,792.5,796.25,799.17,856.25,856.67}
OCC_RUNS[873]={384.17,385.42,385.83,394.58,395.0,395.83,771.25,771.67,789.58,792.5,796.25,799.17}
OCC_RUNS[874]={384.17,385.42,385.83,394.58,395.0,395.83,771.25,771.67,789.58,792.5,796.25,799.17}
OCC_RUNS[875]={381.25,385.42,385.83,396.67,789.58,792.5,796.25,799.17,856.67,857.08}
OCC_RUNS[876]={377.92,400.42,789.58,792.5,796.25,799.17}
OCC_RUNS[877]={365.83,366.25,375.42,375.83,377.08,401.25,789.58,792.5,795.83,799.17}
OCC_RUNS[878]={363.75,364.17,366.25,370.83,375.0,411.67,770.83,771.25,789.58,792.5,795.42,799.17,857.08,857.5}
OCC_RUNS[879]={380.42,412.5,789.58,792.5,795.0,799.17,857.08,857.5}
OCC_RUNS[880]={401.67,413.33,789.58,792.5,794.58,799.17}
OCC_RUNS[881]={770.42,770.83,789.58,792.5,794.58,799.17,857.5,857.92}
OCC_RUNS[882]={770.42,770.83,789.58,792.5,794.17,799.17,857.5,857.92}
OCC_RUNS[883]={789.58,792.08,793.75,795.42,796.25,799.17}
OCC_RUNS[884]={770.0,770.42,789.58,792.08,793.33,795.42,796.25,799.17}
OCC_RUNS[885]={789.58,792.08,793.33,795.0,796.25,799.17}
OCC_RUNS[886]={789.58,792.08,792.92,794.58,796.25,798.75}
OCC_RUNS[887]={769.58,770.0,789.17,792.08,792.5,794.58,796.25,798.75,857.92,858.33}
OCC_RUNS[888]={769.58,770.0,789.17,793.75,796.25,798.75}
OCC_RUNS[889]={769.17,770.0,789.17,793.75,796.25,798.75}
OCC_RUNS[890]={769.17,769.58,789.17,793.33,796.25,798.75}
OCC_RUNS[891]={769.17,769.58,789.17,793.33,795.83,798.75}
OCC_RUNS[892]={769.17,769.58,789.17,792.92,795.83,798.75}
OCC_RUNS[893]={768.75,769.17,789.17,792.5,795.83,798.75}
OCC_RUNS[894]={789.17,792.08,795.83,798.75}
OCC_RUNS[895]={789.17,792.08,795.83,798.75}
OCC_RUNS[896]={768.33,768.75,789.17,792.08,795.83,798.75}
OCC_RUNS[897]={768.33,768.75,789.17,792.08,795.83,798.75}
OCC_RUNS[898]={789.17,792.08,795.83,798.75}
OCC_RUNS[899]={767.92,768.33,789.17,792.08,795.83,798.75}
OCC_RUNS[900]={767.92,768.33,789.17,792.08,795.83,798.75}
OCC_RUNS[901]={789.17,792.08,795.83,798.75}
OCC_RUNS[902]={789.17,791.67,795.83,798.75}
OCC_RUNS[903]={767.5,767.92,789.17,791.67,795.83,798.75}
OCC_RUNS[904]={789.17,791.67,795.83,798.75}
OCC_RUNS[905]={788.75,791.67,795.83,798.75}
OCC_RUNS[906]={767.08,767.5,788.75,791.67,795.83,798.75}
OCC_RUNS[907]={767.08,767.5,788.75,791.67,795.83,798.33,859.58,860.0}
OCC_RUNS[908]={788.75,791.67,795.83,798.33}
OCC_RUNS[909]={766.67,767.08,788.75,791.67,795.83,798.33,860.0,860.42}
function runmask(T)
  return mask(function(x,y)
    local r = T[math.floor(y/0.5+0.5)]
    if not r then return 0 end
    for i=1,#r,2 do if x>=r[i] and x<=r[i+1] then return 1 end end
    return 0 end)
end
OCC = runmask(OCC_RUNS)
STRIP = runmask(STRIP_RUNS)
-- pass 2: settle the disc. Concentric bands laid along the circles (not across them), clipped
-- crisply at the limb and around everything standing in front of the Sun.
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local SUNT = {
 {{"zinc white",4},{"lead white",2},{"lemon chrome",0.6}},
 {{"lead white",3},{"zinc white",1},{"lemon chrome",1},{"cadmium yellow",0.6}},
 {{"lead white",2},{"cadmium yellow",2},{"lemon chrome",1}},
 {{"cadmium yellow",2},{"chrome yellow",1},{"lead white",1}},
 {{"chrome yellow",2},{"Mars orange",1},{"cadmium yellow",1}},
 {{"chrome yellow",1},{"Mars orange",1}},
 {{"Mars orange",2},{"vermilion",1}},
 {{"cadmium red",1},{"vermilion",1},{"Mars orange",0.5}},
 {{"cadmium red",1},{"Mars red",1},{"rose madder",0.4}},
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
SUNT2 = SUNT
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985}
local bands = {}
for i=1,9 do
  local a, b = E[i], (E[i+1] or 1.0)
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
function ueff(x,y)
  local u = math.sqrt((x-CX)^2 + (y-CY)^2) / R
  local e = ((x-425)/390)^2 + ((y-446)/105)^2
  if e < 1 then u = u - 0.10*(1-e)^1.3 end
  return u
end
BANDC = {} for k,bd in ipairs(bands) do if k>1 then BANDC[#BANDC+1]=bd[1] end end
DISCV = ellipse(CX,CY,R-0.5,R-0.5) - below(function(x) return hz(x)-0.3 end) - OCC:grow(0.6) - FIG - SAILFRAME:grow(0.8) - LAMP:grow(1)
for k,bd in ipairs(bands) do
  local lo, hi = bd[1], bd[2]
  local m = mask(function(x,y) local u = ueff(x,y); return (u>=lo and u<hi) and 1 or 0 end) * DISCV
  if m:area() > 2 then
    work(m, {hand="body", tool={kind="filbert", width=12}, pile=pile(bd[3]), coverage=3.2, fill=true,
             angle=tang, length={60,160}, angle_jitter=0.05, edge="soft", clip=DISCV})
  end
end

--@ chunk 152
-- fuse only the seams between bands, along the circles
local tang = function(x,y) return math.atan(y-CY,x-CX)+math.pi/2 end
local C = BANDC
local seams = mask(function(x,y)
  local u = ueff(x,y)
  for _,c in ipairs(C) do if math.abs(u-c) < 0.0045 then return 1 end end
  return 0 end) * DISCV:shrink(1.5)
blend(seams, {angle=tang, tool={kind="badger", width=12}})
print(wait(2*24*60))
-- the sail against the Sun: thin film lit from behind. The Sun's colour, filtered redder and
-- darker, fills each tongue; the folded edges stay dark.
local E = {0.0, 0.62, 0.71, 0.77, 0.82, 0.865, 0.90, 0.935, 0.962, 0.985, 9}
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
local FILM = {{"burnt sienna",1},{"Mars red",0.5},{"bone brown",0.3}}
local inner = STRIP:shrink(1.1) - SAILFRAME:grow(1)
FILMP = {}
for i=1,10 do
  local m = mask(function(x,y) local u = ueff(x,y); return (u>=E[i] and u<E[i+1]) and 1 or 0 end) * inner
  if m:area() > 1 then
    local src = SUNT2[math.min(i+2, 9)]
    local p = pile(mixrec(src, FILM, 0.55))
    FILMP[i] = p
    work(m, {hand="detail", tool={kind="round", width=2.4}, pile=p, coverage=3, fill=true, angle=math.pi/2, clip=inner})
  end
end
-- Ratio's light on the plates: a small warm pool, graded in three piles, brightest at the lamp's foot
LP1 = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
LP2 = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"burnt sienna",0.5},{"lead white",0.15}}
LP3 = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone brown",0.5}}
PCX, PCY, PRX, PRY = 449, 499, 34, 10.5
local function pd(x,y) return math.sqrt(((x-PCX)/PRX)^2 + ((y-PCY)/PRY)^2) end
POOLM = ellipse(PCX, PCY, PRX, PRY) - LAMP:grow(0.4) - FIG:grow(0.6)
local rings = {{0, 0.38, LP1}, {0.38, 0.68, LP2}, {0.68, 1.01, LP3}}
for i,rg in ipairs(rings) do
  local m = mask(function(x,y) local d = pd(x,y); return (d>=rg[1] and d<rg[2]) and 1 or 0 end) * POOLM
  work(m, {hand="body", tool={kind="filbert", width=3.2}, pile=rg[3], coverage=3, fill=true, angle=0,
           length={5,14}, edge=(i==3) and "soft" or "firm", clip=(i==3) and nil or POOLM})
end
local seam = mask(function(x,y) local d = pd(x,y); return (math.abs(d-0.38)<0.07 or math.abs(d-0.68)<0.07) and 1 or 0 end) * POOLM
blend(seam, {angle=0, tool={kind="badger", width=4}})
-- the frame: modelling inside the silhouette. Cool sky-light on the upward planes, a dark core
-- down the back, warm bounce from the hot plates low on the hips and knee. Then the repair plate.
local P = FIGP
local up = function(y0) return above(function(x) return y0 end) end
local dn = function(y0) return below(function(x) return y0 end) end
F_COOL = pile{{"bone black",1},{"lead white",0.55},{"ultramarine blue",0.45},{"rose madder",0.3}}
F_BNC = pile{{"bone brown",1},{"burnt sienna",1},{"Mars orange",0.45},{"bone black",0.25}}
local inside = FIG:shrink(1.2)
-- cool upward planes
local cool = ((P.head * up(419)) + (P.lpaul * up(443)) + (P.rpaul * up(443)) + (P.torso * up(442)) + (P.pack * up(447))) * inside
work(cool, {hand="detail", tool={kind="round", width=1.8, point=0.4}, pile=F_COOL, coverage=2, fill=true, angle=0.15, length={3,8}, clip=inside, pressure={0.3,0.6}})
-- warm bounce low down, facing the plates
local warm = ((P.hips * dn(489)) + (P.knee * dn(474)) + (P.torso * dn(484)) + (P.larm * dn(458))) * inside
work(warm, {hand="detail", tool={kind="round", width=1.8, point=0.4}, pile=F_BNC, coverage=1.6, fill=false, angle=0, length={3,9}, clip=inside, pressure={0.25,0.5}})
-- the repair plate: outpost grey, the wrong size and set askew, standing proud of the back
F_PLATE = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.55},{"burnt sienna",0.15}}
PLATE = poly({{369.5,448.5},{382.5,446.2},{384.2,463.8},{371.2,466.4}}) * FIG:shrink(0.8)
work(PLATE, {hand="detail", tool={kind="flat", width=2.2}, pile=F_PLATE, coverage=3.5, fill=true, angle=1.45, length={4,10}, clip=PLATE})

--@ chunk 153
print(wait(24*60)); print(drying(372,458), drying(353,470), drying(449,500), drying(700,300))
local P = FIGP
local up = function(y0) return above(function(x) return y0 end) end
local dn = function(y0) return below(function(x) return y0 end) end
local inside = FIG:shrink(1.2)
-- quieter modelling: the warm bounce and the cool tops were too loud; restate them close to the dark
local F_WD = pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.7},{"Mars orange",0.12}}
local F_CD = pile{{"bone black",1.4},{"ultramarine blue",0.6},{"lead white",0.3},{"rose madder",0.25}}
local warm = ((P.hips * dn(489)) + (P.knee * dn(474)) + (P.torso * dn(484)) + (P.larm * dn(458))) * inside
work(warm, {hand="detail", tool={kind="filbert", width=2.4}, pile=F_WD, coverage=3.2, fill=true, angle=0, length={4,10}, clip=warm})
local cool = ((P.head * up(419)) + (P.lpaul * up(443)) + (P.rpaul * up(443)) + (P.torso * up(442)) + (P.pack * up(447))) * inside - PLATE:grow(0.5)
work(cool, {hand="detail", tool={kind="filbert", width=2.0}, pile=F_CD, coverage=3, fill=true, angle=0.15, length={3,8}, clip=cool})
-- the plate: outpost grey, lighter and cooler than the frame but still in its shadow
local F_PLATE2 = pile{{"bone black",1},{"lead white",0.75},{"ultramarine ash",0.7},{"burnt sienna",0.2}}
work(PLATE, {hand="detail", tool={kind="flat", width=2.2}, pile=F_PLATE2, coverage=3.5, fill=true, angle=1.45, length={4,10}, clip=PLATE})
-- the film against the Sun: a transparent warm-dark glaze, then fold lines
local film = STRIP:shrink(0.6) - SAILFRAME:grow(1)
work(film, {hand="glaze", tool={kind="filbert", width=4}, pile=pile{{"burnt sienna",1},{"Mars red",0.5},{"bone brown",0.4},medium=0.7}, coverage=1.6, angle=math.pi/2, length={20,60}, clip=film, load=0.5})
local fb = brush{kind="round", width=1.2, point=0.6}
for i=1,26 do
  local x = rand(600, 785); local y = rand(190, 300)
  if STRIP:shrink(1.5):at(x,y) > 0.5 then
    fb:reload(SAIL_DK, 0.6)
    local L = rand(12, 40)
    fb:stroke({{x,y},{x+rand(-0.8,0.8),y+L*0.5},{x+rand(-1.2,1.2),y+L}}, {pressure={0.25,0.05}, clip=STRIP:shrink(0.8)})
  end
end
-- the pool's rim lost into the plates
lose(ellipse(PCX, PCY, PRX, PRY) - LAMP:grow(0.5) - FIG:grow(0.5), {pile=LP3, where=1, load=0.15, tool="filbert 3"})

--@ chunk 154
print(wait(5*24*60)); print(drying(372,458), drying(353,470), drying(700,300))
local P = FIGP
local dn = function(y0) return below(function(x) return y0 end) end
local inside = FIG:shrink(0.9)
-- put the lower body back into the frame's dark; the bounce stays only as a thin warm edge low down
local warm = ((P.hips * dn(486)) + (P.knee * dn(470)) + (P.torso * dn(482)) + (P.larm * dn(455))) * inside
work(warm, {hand="detail", tool={kind="filbert", width=2.4}, pile=FIG_DK2, coverage=4.5, fill=true, angle=0, length={4,10}, clip=warm})
local bnc = (FIG - FIG:shrink(1.6)) * dn(470) * FIG:shrink(0.3) - P.rarm - P.hand
work(bnc, {hand="detail", tool={kind="round", width=1.0}, pile=F_B2, coverage=2, fill=true, clip=bnc, pressure={0.3,0.5}})
local F_PLATE3 = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.3},{"burnt sienna",0.2}}
work(PLATE, {hand="detail", tool={kind="flat", width=2.2}, pile=F_PLATE3, coverage=4.5, fill=true, angle=1.45, length={4,10}, clip=PLATE})
-- the film: a deeper red through most of each tongue, leaving the lighter glow in streaks
local film = STRIP:shrink(1.0) - SAILFRAME:grow(1)
SAILGLOW = pile{{"Mars red",1},{"burnt sienna",1},{"cadmium red",0.3},{"bone brown",0.5}}
work(film, {hand="detail", tool={kind="round", width=1.8, point=0.4}, pile=SAILGLOW, coverage=1.3, fill=false, angle=math.pi/2, length={10,40}, clip=film})

--@ chunk 155
print(PLATE:area(), STRIP:area(), (STRIP:shrink(1.0)-SAILFRAME:grow(1)):area(), drying(376,456), drying(700,250), drying(650,220))

--@ chunk 156
print(wait(5*24*60)); print(drying(376,456), drying(390,470), drying(449,500))
-- sunlight wrapping the frame's contour: wider and hotter on the dome and shoulder tops, thinner
-- down the arms, broken here and there, gone where the form turns away below the horizon line
local P = FIGP
local up = function(y0) return above(function(x) return y0 end) end
local dn = function(y0) return below(function(x) return y0 end) end
local nz = noise{seed=41, period=9, octaves=2}
local brk = mask(function(x,y) return nz(x,y) > -0.45 and 1 or 0 end)
local body = FIG - P.ant
local rimA = (body - body:shrink(1.4)) * up(436) * brk
local rimB = (body - body:shrink(0.8)) * up(456) * dn(436) * brk
local rb = {kind="round", width=1.0, point=0.5}
work(rimA, {hand="detail", tool=rb, pile=RIM_HOT, coverage=3, fill=true, clip=rimA, pressure={0.4,0.7}})
work(rimB, {hand="detail", tool=rb, pile=GLINT1, coverage=2.5, fill=true, clip=rimB, pressure={0.3,0.6}})
-- the antenna: one lit side, a hot tip
local a = brush{kind="round", width=0.8, point=0.7}
a:reload(RIM_HOT, 0.6); a:stroke({{400.2,414.5},{404.8,404.5},{407.6,398.4}}, {pressure={0.35,0.25}})
-- the repair plate's edges and rivets
local e = brush{kind="round", width=0.9, point=0.5}
local PL_HI = pile{{"lead white",2},{"ultramarine ash",0.5},{"Mars orange",0.35}}
e:reload(PL_HI, 0.7); e:stroke({{370.2,448.7},{376,447.6},{382.0,446.6}}, {pressure={0.4,0.35}})
e:reload(FIG_DK2, 0.8); e:stroke({{371.6,466.9},{378,465.7},{384.3,464.5}}, {pressure={0.5,0.45}})
e:reload(FIG_DK2, 0.8); e:stroke({{383.0,447.2},{383.8,456},{384.6,464.2}}, {pressure={0.35,0.35}})
local rv = brush{kind="round", width=1.1, point=0.3}
for _,p in ipairs({{371.6,450.4},{380.8,448.6},{382.4,462.4},{372.9,464.6},{376.2,449.5},{377.7,463.6}}) do
  rv:reload(FIG_DK2, 0.7); rv:touch(p[1], p[2], {pressure=0.35})
  e:reload(PL_HI, 0.5); e:touch(p[1]-0.3, p[2]-0.35, {pressure=0.12})
end
-- Ratio's light on the hand and the underside of the forearm
local function sd(x,y) return (x-412)*0.906 - (y-447)*0.423 end
local armlit = (P.rarm * dn(476) * mask(function(x,y) return sd(x,y) > 1.4 and 1 or 0 end)) * FIG:shrink(0.3)
local handlit = P.hand * mask(function(x,y) return (x > 434.5 or y > 495.3) and 1 or 0 end) * FIG:shrink(0.2)
work(armlit, {hand="detail", tool={kind="round", width=1.1, point=0.5}, pile=LP2, coverage=2.5, fill=true, clip=armlit, pressure={0.3,0.6}})
work(handlit, {hand="detail", tool={kind="round", width=1.1, point=0.5}, pile=LP1, coverage=3, fill=true, clip=handlit, pressure={0.35,0.7}})

--@ chunk 157
-- the scale lips carry on through Ratio's pool: a shadowed under-edge, a lamp-lit crest
local LIPD = pile{{"burnt sienna",1},{"bone brown",1},{"Mars orange",0.3}}
local b = brush{kind="round", width=1.0, point=0.6}
local clipm = ellipse(PCX, PCY, PRX+2, PRY+1.5) - LAMP:grow(0.6) - FIG:grow(0.6)
local function arc(cx, cy, w, h, lit)
  local pts, top = {}, {}
  for i=1,9 do local th = math.pi*i/10; pts[#pts+1] = {cx + w/2*math.cos(th), cy - h + h*math.sin(th)}; top[#top+1] = {pts[#pts][1], pts[#pts][2]-0.9} end
  b:reload(LIPD, 0.7); b:stroke(pts, {pressure={0.4,0.3}, clip=clipm})
  b:reload(lit, 0.6); b:stroke(top, {pressure={0.25,0.15}, clip=clipm})
end
arc(424, 503.5, 18, 4.2, LP2) arc(442, 504.5, 18, 4.2, LP1) arc(460, 504, 18, 4.2, LP1) arc(477, 503, 18, 4.2, LP2)
arc(433, 510, 19, 4.4, LP2) arc(451, 510.5, 19, 4.4, LP2) arc(469, 510, 19, 4.4, LP3)
