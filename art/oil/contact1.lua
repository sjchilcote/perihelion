-- easel session "contact1": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=7,
  ground={{pile={{"lead white",2},{"raw sienna",1.2},{"ultramarine blue",0.6},{"bone black",0.4}}, um=120, apply="knife", texture=0.3}}}
SEAM = {{650,-10},{615,80},{632,150},{580,225},{548,290},{542,355},{566,430},{532,505},{560,640}}
local pts = {{-10,-10}}
for _,p in ipairs(SEAM) do pts[#pts+1]=p end
pts[#pts+1]={-10,640}
WALL = poly(pts)
FIELD = -WALL
F_IND = pile{{"ultramarine blue",2},{"magenta",0.5},{"bone black",1.4}}
F_DEEP = pile{{"bone black",2},{"ultramarine blue",1.2},{"magenta",0.2}}
work(FIELD * rect(560,0,440,330), {hand="broad", pile=F_DEEP, coverage=3, fill=true, angle=0.15})
work(FIELD * rect(520,300,480,330), {hand="broad", pile=F_IND, coverage=3, fill=true, angle=-0.1})

--@ chunk 2
W_L = pile{{"lead white",3},{"bone black",0.6},{"ultramarine ash",1},{"raw sienna",0.25}}
W_M = pile{{"lead white",2},{"bone black",0.9},{"ultramarine ash",1},{"raw sienna",0.5}}
W_D = pile{{"lead white",1},{"bone black",1.2},{"ultramarine ash",1},{"burnt sienna",0.3}}
work(WALL * rect(0,0,700,260), {hand="body", pile=W_L, coverage=3, fill=true, clip=WALL, angle=1.5708, angle_jitter=0.1})
work(WALL * rect(0,260,700,250), {hand="body", pile=W_M, coverage=3, fill=true, clip=WALL, angle=1.5708, angle_jitter=0.1})
work(WALL * rect(0,510,700,130), {hand="body", pile=W_D, coverage=3, fill=true, clip=WALL, angle=1.5708, angle_jitter=0.1})

--@ chunk 3
W_P1 = pile{{"lead white",1.6},{"bone black",0.9},{"ultramarine ash",1},{"raw sienna",0.35}}
W_P2 = pile{{"lead white",1.4},{"bone black",0.9},{"ultramarine ash",1.2},{"cerulean blue",0.15}}
W_P3 = pile{{"lead white",1.2},{"bone black",1.0},{"ultramarine ash",1},{"raw sienna",0.5}}
C_FACE = pile{{"bone black",1.4},{"ultramarine ash",1},{"lead white",0.5},{"ultramarine blue",0.2}}
local function panel(x,y,w,h,p,a)
  work(WALL*rect(x,y,w,h), {hand="body", pile=p, coverage=2.5, fill=true, clip=true, angle=a or 1.5708, angle_jitter=0.08})
end
panel(0,0,170,118,W_P1); panel(172,0,270,118,W_P2); panel(444,0,260,118,W_P3)
panel(0,120,282,380,W_P2); panel(284,120,420,40,W_P1,0); panel(532,160,170,320,W_P3)
panel(284,472,420,30,W_P1,0)
panel(0,502,700,140,W_P3,0)
CONSOLE = rect(292,165,236,302)
work(CONSOLE, {hand="body", pile=C_FACE, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 4
print(wait(36*60)); print(drying(100,300), drying(400,300), drying(800,300))

--@ chunk 5
print(wait(24*60)); print(drying(100,300), drying(400,300), drying(800,300), drying(800,100))

--@ chunk 6
print(wait(3*24*60)); print(drying(100,300), drying(400,300), drying(800,300), drying(800,100))

--@ chunk 7
D1 = pile{{"lead white",1},{"bone black",1},{"ultramarine ash",1.2},{"raw sienna",0.3}}
D2 = pile{{"lead white",0.9},{"bone black",1},{"ultramarine ash",1},{"cerulean blue",0.12}}
D3 = pile{{"lead white",0.7},{"bone black",1.1},{"ultramarine ash",1},{"burnt sienna",0.35}}
C_DARK = pile{{"bone black",2},{"ultramarine ash",1},{"ultramarine blue",0.3}}
local function panel(x,y,w,h,p,a)
  work(WALL*rect(x,y,w,h), {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=a or 1.5708, angle_jitter=0.08})
end
panel(0,0,169,117,D2); panel(173,0,268,117,D1); panel(445,0,260,117,D3)
panel(0,121,280,378,D1); panel(285,121,420,38,D2,0); panel(533,161,170,318,D3)
panel(285,473,420,28,D2,0)
panel(0,503,700,140,D3,0)
work(rect(296,169,228,294), {hand="body", pile=C_DARK, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 8
G_M = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.5}}
G_D = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
ARM = poly({{-79,622},{140,482},{360,356},{412,434},{180,600},{-1,738}}, true)
FIST = poly({{352,352},{383,311},{420,296},{470,300},{489,317},{492,360},{484,396},{456,419},{410,426},{372,421},{348,396}}, true)
CABLE_PTS = {{430,418},{428,470},{405,525},{360,575},{318,640}}
work(ARM, {hand="body", pile=G_M, coverage=3, fill=true, clip=true, angle=-0.59, angle_jitter=0.1})
work(ARM * below(function(x) return 560 - 0.67*x end), {hand="body", pile=G_D, coverage=2.5, fill=true, clip=true, angle=-0.59})
work(FIST, {hand="body", pile=G_M, coverage=3, fill=true, clip=true, angle=0.3})

--@ chunk 9
G_L = pile{{"lead white",1.2},{"bone black",1},{"ultramarine ash",1}}
G_HI = pile{{"lead white",2.5},{"bone black",0.4},{"ultramarine ash",1}}
ux,uy = 0.83,-0.557; nx,ny = 0.557,0.83
function AP(t, s) -- arm point: t along axis, s across (-1 upper edge .. 1 lower edge)
  local h = 70 - 25*t/512
  return {-40 + ux*t + nx*h*s, 680 + uy*t + ny*h*s}
end
local function line(t0,t1,s0,s1)
  local pts={}
  for i=0,8 do local t=lerp(t0,t1,i/8); pts[#pts+1]=AP(t, lerp(s0,s1,i/8)) end
  return pts
end
local b = brush("filbert", 12)
-- upper lit band on the vambrace
for k,s in ipairs({-0.78,-0.66,-0.55}) do
  b:reload(G_L, 0.8)
  b:stroke(line(60,300,s,s), {pressure={0.7,0.6}, clip=ARM})
end
b:reload(G_HI, 0.6)
b:stroke(line(80,290,-0.72,-0.72), {pressure={0.45,0.35}, clip=ARM})
-- second lit band on the wrist cuff segment
for _,s in ipairs({-0.75,-0.6}) do
  b:reload(G_L, 0.8)
  b:stroke(line(320,420,s,s), {pressure={0.6,0.5}, clip=ARM})
end

--@ chunk 10
wait(2*24*60)
print(drying(200,520))
function APOLY(t0,t1,s0,s1)
  local pts={}
  for i=0,6 do local t=lerp(t0,t1,i/6); pts[#pts+1]=AP(t,s0) end
  for i=6,0,-1 do local t=lerp(t0,t1,i/6); pts[#pts+1]=AP(t,s1) end
  return poly(pts)
end
G_TOP = pile{{"lead white",1.5},{"bone black",0.9},{"ultramarine ash",1},{"raw sienna",0.15}}
G_SIDE = pile{{"lead white",0.5},{"bone black",1.4},{"ultramarine ash",1}}
G_UND = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local segs = {{-20,192},{198,332}}
for _,sg in ipairs(segs) do
  work(APOLY(sg[1],sg[2],-1.05,-0.42)*ARM, {hand="body", pile=G_TOP, coverage=3, fill=true, clip=true, angle=-0.59})
  work(APOLY(sg[1],sg[2],-0.42,0.52)*ARM, {hand="body", pile=G_SIDE, coverage=3, fill=true, clip=true, angle=-0.59})
  work(APOLY(sg[1],sg[2],0.52,1.1)*ARM, {hand="body", pile=G_UND, coverage=3, fill=true, clip=true, angle=-0.59})
end
-- wrist joint: dark ribbed cylinder
work(APOLY(332,420,-1.1,1.1)*ARM, {hand="body", pile=G_UND, coverage=3, fill=true, clip=true, angle=-0.59+1.5708})

--@ chunk 11
wait(3*24*60)
print(drying(420,360), drying(200,560))
DORSAL = poly({{366,320},{410,306},{450,300},{466,316},{466,392},{430,420},{378,418},{356,392}}, true)
work(DORSAL, {hand="body", pile=G_SIDE, coverage=3, fill=true, clip=true, angle=-0.3})
work(DORSAL*above(function(x) return 340 - 0.15*(x-360) end), {hand="body", pile=G_TOP, coverage=3, fill=true, clip=true, angle=-0.2})
work(DORSAL*below(function(x) return 395 end), {hand="body", pile=G_UND, coverage=3, fill=true, clip=true, angle=0})
-- knuckle caps above the plug
KNUCK = poly({{440,303},{470,296},{492,306},{498,326},{470,332},{444,330}}, true)
work(KNUCK, {hand="body", pile=G_TOP, coverage=3, fill=true, clip=true, angle=0.2})
-- curled fingers in front of the plug
FING = {}
local fy = {{334,356,466,497},{358,378,463,494},{380,399,460,490},{401,417,455,484}}
for i,f in ipairs(fy) do
  local m = poly({{f[3],f[1]},{f[4]-4,f[1]},{f[4],f[1]+5},{f[4],f[2]-4},{f[4]-5,f[2]},{f[3]+2,f[2]}}, true)
  FING[i]=m
  work(m, {hand="detail", pile=G_SIDE, coverage=4, fill=true, clip=true, angle=0})
  work(m*above(function(x) return f[1]+6 end), {hand="detail", pile=G_TOP, coverage=4, fill=true, clip=true, angle=0})
end

--@ chunk 12
wait(5*24*60) print(drying(420,360), drying(200,560), drying(480,345))

--@ chunk 13
GRID = pile{{"cerulean blue",1},{"ultramarine blue",1},{"zinc white",0.8},{"cobalt violet",0.2}}
GRID_F = pile{{"ultramarine blue",1.5},{"cobalt violet",0.5},{"zinc white",0.5},{"bone black",0.3}}
VPX, VPY = 830, 392
local fieldR = FIELD * rect(560,395,440,240)
local r = brush{kind="round", width=2.2, point=0.8}
-- horizontal grid lines
local rows = {404, 414, 427, 444, 466, 494, 530, 576, 632}
for i,y in ipairs(rows) do
  local p = (i<=3) and GRID_F or GRID
  r:reload(p, 0.85)
  local pr = 0.25 + 0.06*i
  r:stroke({{1005,y},{820,y+rand(-0.5,0.5)},{560,y}}, {pressure={pr,pr*0.6}, clip=fieldR})
end
-- radial lines from the vanishing point
for k=-14,10 do
  local xb = VPX + k*58 + rand(-3,3)
  r:reload(GRID, 0.85)
  r:stroke({{VPX + (xb-VPX)*0.04, VPY+8},{xb, 640}}, {pressure={0.12,0.6}, clip=fieldR})
end

--@ chunk 14
wait(6*24*60) print(drying(420,360), drying(200,560), drying(480,345), drying(100,100), drying(800,450))

--@ chunk 15
SX, SY = 548, 343
WZ1 = pile{{"lead white",1.2},{"bone black",0.7},{"ultramarine ash",1},{"cerulean blue",0.35}}
WZ2 = pile{{"lead white",0.7},{"bone black",1},{"ultramarine ash",1},{"cerulean blue",0.15}}
WZ3 = pile{{"lead white",0.35},{"bone black",1.2},{"ultramarine ash",1},{"burnt sienna",0.2}}
CONS = rect(292,165,236,302)
local base = WALL - CONS
local z1 = ellipse(SX,SY,190,170)
local z2 = ellipse(SX,SY,380,330)
work(base*z1, {hand="body", pile=WZ1, coverage=3, fill=true, clip=base, angle=1.5708, angle_jitter=0.1})
work(base*(z2-z1), {hand="body", pile=WZ2, coverage=3, fill=true, clip=base, angle=1.5708, angle_jitter=0.1})
work(base*(-z2), {hand="body", pile=WZ3, coverage=3, fill=true, clip=base, angle=1.5708, angle_jitter=0.1})
-- re-darken the console face where the old fist was
work(CONS:shrink(4), {hand="body", pile=C_DARK, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 16
local base = WALL - CONS
local d1 = ellipse(SX,SY,190,170)
local d2 = ellipse(SX,SY,380,330)
local s1 = (d1:grow(28) - d1:shrink(28)) * base
local s2 = (d2:grow(40) - d2:shrink(40)) * base
blend(s1, {angle=0.4})
blend(s2, {angle=0.4})
blend(s2:shrink(10), {angle=-0.6})

--@ chunk 17
wait(4*24*60) print(drying(420,360), drying(100,560), drying(300,100))

--@ chunk 18
U2x,U2y = 0.832,-0.555; N2x,N2y = 0.555,0.832
function H2(t)
  if t < 150 then return lerp(100,94,t/150)
  elseif t < 380 then return lerp(94,74,(t-150)/230)
  else return 50 end
end
function AP2(t,s) local h=H2(t); return {-60+U2x*t+N2x*h*s, 700+U2y*t+N2y*h*s} end
function APOLY2(t0,t1,s0,s1,n)
  n = n or 8
  local pts={}
  for i=0,n do local t=lerp(t0,t1,i/n); pts[#pts+1]=AP2(t,s0) end
  for i=n,0,-1 do local t=lerp(t0,t1,i/n); pts[#pts+1]=AP2(t,s1) end
  return poly(pts, true)
end
function LINE2(t0,t1,s,n)
  n=n or 8; local pts={}
  for i=0,n do pts[#pts+1]=AP2(lerp(t0,t1,i/n), s) end
  return pts
end
-- five-value gunmetal ramp, lean
GM = {
  pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}},          -- 1 core dark
  pile{{"bone black",2},{"ultramarine ash",1}},                                  -- 2
  pile{{"bone black",1.4},{"ultramarine ash",1},{"lead white",0.35}},            -- 3
  pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.8}},               -- 4 lit top
  pile{{"bone black",0.6},{"ultramarine ash",1},{"lead white",1.5},{"cerulean blue",0.2}}, -- 5 highlight
}
-- strips across the plate: s ranges and ramp index
PROFILE = {{-1.05,-0.85,4},{-0.85,-0.55,5},{-0.55,-0.25,4},{-0.25,0.15,3},{0.15,0.6,1},{0.6,0.85,2},{0.85,1.08,3}}
function plate(t0,t1,seed)
  local whole = APOLY2(t0,t1,-1.02,1.02)
  for _,pr in ipairs(PROFILE) do
    work(APOLY2(t0,t1,pr[1],pr[2])*whole, {hand="body", tool="filbert 7", pile=GM[pr[3]], coverage=3.5, fill=true, clip=whole, angle=-0.588, angle_jitter=0.05, seed=seed})
  end
  blend(whole:shrink(3), {angle=-0.588+1.5708, tool={kind="badger", width=14}})
  return whole
end
PLATE_A = plate(-30,205,1)

--@ chunk 19
GM[3] = pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.12}}
GM[4] = pile{{"bone black",1.2},{"ultramarine ash",1},{"lead white",0.35}}
GM[5] = pile{{"bone black",0.8},{"ultramarine ash",1},{"lead white",0.8},{"cerulean blue",0.2}}
PLATE_A = plate(-30,215,2)
PLATE_B = plate(200,395,3)

--@ chunk 20
function H2(t)
  if t < 150 then return lerp(100,94,t/150)
  elseif t < 395 then return lerp(94,74,(t-150)/245)
  elseif t < 470 then return 50
  else return 66 end
end
-- wrist joint: dark cylinder with ribs
WRIST = APOLY2(390,478,-1.02,1.02)
work(WRIST, {hand="body", tool="filbert 6", pile=GM[1], coverage=3.5, fill=true, clip=true, angle=-0.588+1.5708})
local r = brush("filbert", 5)
for _,t in ipairs({402,418,434,450,466}) do
  r:reload(GM[3], 0.7)
  r:stroke({AP2(t,-0.95),AP2(t,-0.3),AP2(t,0.4)}, {pressure={0.7,0.2}, clip=WRIST})
  r:reload(GM[5], 0.5)
  r:stroke({AP2(t-1,-0.95),AP2(t-1,-0.55)}, {pressure={0.5,0.2}, clip=WRIST})
end
-- back of the hand: a boxy gauntlet plate
HAND = APOLY2(475,598,-1.0,1.0)
local whole = HAND
for _,pr in ipairs(PROFILE) do
  work(APOLY2(475,598,pr[1],pr[2])*whole, {hand="body", tool="filbert 6", pile=GM[pr[3]], coverage=3.5, fill=true, clip=whole, angle=-0.588})
end

--@ chunk 21
function H2(t)
  if t < 150 then return lerp(100,94,t/150)
  elseif t < 395 then return lerp(94,74,(t-150)/245)
  elseif t < 470 then return 50
  else return 66 end
end
function SEGPOLY(t0,t1,s0,s1,round)
  local p = {AP2(t0,s0),AP2(t1,s0),AP2(t1,s1),AP2(t0,s1)}
  local m = poly(p)
  if round then m = m:soften(round):map(function(v) return v>0.5 and 1 or 0 end) end
  return m
end
function seg(t0,t1,s0,s1,dark)
  local m = poly({AP2(t0,s0),AP2(t1-3,s0),AP2(t1,s0+0.08),AP2(t1,s1-0.08),AP2(t1-3,s1),AP2(t0,s1)}, true)
  local sm = lerp(s0,s1,0.38)
  work(m, {hand="detail", tool="round 3", pile=GM[dark and 1 or 2], coverage=4, fill=true, clip=true, angle=-0.588})
  work(m*poly({AP2(t0-5,s0-0.2),AP2(t1+5,s0-0.2),AP2(t1+5,sm),AP2(t0-5,sm)}), {hand="detail", tool="round 3", pile=GM[dark and 3 or 4], coverage=4, fill=true, clip=true, angle=-0.588})
  local r = brush{kind="round", width=2.2, point=0.6}
  r:reload(GM[5], 0.7)
  r:stroke({AP2(t0+2,s0+0.05),AP2(t1-3,s0+0.05)}, {pressure={0.55,0.35}, clip=m})
  return m
end
-- plug body (dark rubber housing), out of the fist toward the socket
PLUG = seg(590,700,-0.36,0.24,true)
-- fingers wrapped under it
FINGERS = {}
FINGERS[1] = seg(585,650,0.22,0.46)
FINGERS[2] = seg(580,642,0.48,0.71)
FINGERS[3] = seg(574,630,0.73,0.95)
-- thumb on top, pressing
THUMB = seg(560,640,-0.9,-0.42)

--@ chunk 22
ARMALL = PLATE_A + PLATE_B + WRIST + HAND + PLUG + FINGERS[1] + FINGERS[2] + FINGERS[3] + THUMB
SCREEN = rect(310,182,202,270) - ARMALL:grow(1)
SC1 = pile{{"ultramarine blue",1},{"cerulean blue",1},{"bone black",1.2},{"zinc white",0.5}}
SC2 = pile{{"ultramarine blue",1},{"cerulean blue",1.3},{"bone black",0.7},{"zinc white",1.0}}
work(SCREEN, {hand="body", tool="filbert 6", pile=SC1, coverage=3.5, fill=true, clip=true, angle=0})
work(SCREEN*ellipse(400,280,95,90):soften(10), {hand="body", tool="filbert 6", pile=SC2, coverage=3, fill=true, clip=SCREEN, angle=0})
blend(SCREEN*ellipse(400,280,125,120)-SCREEN:rim(4), {angle=0, tool={kind="badger", width=16}})

--@ chunk 23
SLAB_Y = {120, 168, 216, 264, 312}
SLAB_CX = {838, 830, 842, 826, 836}
SLABS = {}
SLABFILL = {
  pile{{"ultramarine blue",1},{"cobalt violet",0.6},{"zinc white",0.5},{"bone black",0.6}},
  pile{{"ultramarine blue",1},{"cerulean blue",0.4},{"zinc white",0.4},{"bone black",0.7}},
}
function slabpts(cx,cy)
  return {{cx-125,cy+12},{cx-55,cy-20},{cx+125,cy-20},{cx+55,cy+12}}
end
for k=1,5 do
  local cx, cy = SLAB_CX[k], SLAB_Y[k]
  local top = poly(slabpts(cx,cy))
  local front = poly({{cx-125,cy+12},{cx+55,cy+12},{cx+125,cy-20},{cx+125,cy-14},{cx+55,cy+18},{cx-125,cy+18}})
  SLABS[k] = {top=top, front=front, cx=cx, cy=cy}
  work(top, {hand="body", tool="filbert 6", pile=SLABFILL[(k%2)+1], coverage=3, fill=true, clip=true, angle=0})
  work(front, {hand="detail", pile=F_DEEP, coverage=4, fill=true, clip=true, angle=0})
end

--@ chunk 24
AMBER = pile{{"chrome yellow",2},{"Mars orange",1},{"yellow ochre",1}}
AMBER_D = pile{{"Mars orange",1},{"burnt sienna",1},{"bone black",0.3}}
COPPER = pile{{"burnt sienna",1},{"cadmium red",0.5},{"Mars orange",1},{"lead white",0.3}}
COPPER_HI = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",1}}
CYAN = pile{{"zinc white",3},{"cerulean blue",1.3}}
HOT = pile{{"zinc white",4},{"cerulean blue",0.3},{"lemon chrome",0.08}}
-- socket collar
COLLAR = poly({AP2(700,-0.66),AP2(724,-0.66),AP2(724,0.56),AP2(700,0.56)})
work(COLLAR, {hand="detail", tool="round 3", pile=AMBER, coverage=4, fill=true, clip=true, angle=-0.588})
local r = brush{kind="round", width=3, point=0.3}
for i,s in ipairs({-0.5,-0.15,0.2}) do
  r:reload(bone and AMBER_D or AMBER_D, 0.7)
  r:stroke({AP2(700,s),AP2(724,s+0.14)}, {pressure={0.8,0.8}, clip=COLLAR})
end
-- copper strands fraying out of the socket
local f = brush{kind="round", width=1.6, point=0.8}
SOCK = AP2(726,-0.05)
for i,dv in ipairs({-9,-6,-3.5,-1,1.5,4,6.5}) do
  f:reload((i%2==0) and COPPER_HI or COPPER, 0.8)
  local p1 = {SOCK[1]+ 18, SOCK[2]-12 + dv*0.7}
  local p2 = {SOCK[1]+ 42, SOCK[2]-26 + dv*0.35}
  local p3 = {SOCK[1]+ 62, SOCK[2]-38 + dv*0.12}
  f:stroke({{SOCK[1]+1, SOCK[2]+dv*0.8}, p1, p2, p3}, {pressure={0.55,0.4}})
end
-- the hot core carrying on from where the strands converge
NODE = {SOCK[1]+62, SOCK[2]-38}
local c = brush{kind="round", width=5, point=0.4}
c:reload(CYAN, 0.9)
c:stroke({{SOCK[1]+40, SOCK[2]-25}, NODE, {NODE[1]+14, NODE[2]-9}}, {pressure={0.4,0.9}})
c:reload(HOT, 0.9)
c:stroke({{SOCK[1]+50, SOCK[2]-31}, NODE, {NODE[1]+12, NODE[2]-8}}, {pressure={0.3,0.6}})
print(SOCK[1],SOCK[2],NODE[1],NODE[2])

--@ chunk 25
ORANGE = pile{{"cadmium yellow",1},{"Mars orange",1.2},{"lead white",0.4}}
MAGENTA_L = pile{{"magenta",1},{"zinc white",1.5},{"cobalt violet",0.3}}
BLUE_L = pile{{"cerulean blue",1},{"ultramarine blue",0.6},{"zinc white",1.4}}
TRACE_P = {ORANGE, CYAN, HOT, BLUE_L, MAGENTA_L}
TRACES = {}
local r = brush{kind="round", width=2.6, point=0.4}
for k=1,5 do
  local S = SLABS[k]
  local Lx, Ly = S.cx-125, S.cy+12
  local p1 = {NODE[1]+10+k*4, NODE[2]-6+(k-3)*5}
  local dy = Ly - p1[2]
  local p2 = {p1[1] + math.abs(dy)*0.75 + 6, Ly}
  if p2[1] > Lx - 8 then p2[1] = Lx - 8 end
  local pts = {{NODE[1]+2, NODE[2]-1}, p1, {p1[1]+4, p1[2]}, p2, {Lx+2, Ly}}
  TRACES[k] = pts
  r:reload(TRACE_P[k], 0.95)
  r:stroke(pts, {pressure={0.75,0.65}, ramps={0.02,0.05}})
end

--@ chunk 26
wait(4*24*60) print(drying(840,120), drying(400,300), drying(200,560), drying(450,350))

--@ chunk 27
wait(6*24*60) print(drying(840,120), drying(400,300), drying(200,560), drying(450,350), drying(640,240))

--@ chunk 28
local r = brush{kind="round", width=2.2, point=0.5}
for k=1,5 do
  local S = SLABS[k]
  local p = slabpts(S.cx, S.cy)
  local P = TRACE_P[k]
  -- front edge (bright), left edge, back edge (dim), right edge
  local edges = {{p[1],p[4],0.75},{p[4],p[3],0.6},{p[1],p[2],0.55},{p[2],p[3],0.35}}
  for _,e in ipairs(edges) do
    r:reload(P, 0.9)
    r:stroke({e[1], e[2]}, {pressure={e[3],e[3]}, ramps={0.02,0.02}})
  end
  -- the front thickness edge, darker line of the same hue
  r:reload(P, 0.5)
  r:stroke({{p[1][1],p[1][2]+6},{p[4][1],p[4][2]+6},{p[3][1],p[3][2]+6}}, {pressure={0.3,0.25}})
end
-- vertical posts joining the stack at its corners
local v = brush{kind="round", width=1.6, point=0.6}
for k=1,4 do
  local a, b = SLABS[k], SLABS[k+1]
  local pa, pb = slabpts(a.cx,a.cy), slabpts(b.cx,b.cy)
  for _,i in ipairs({1,3,4}) do
    v:reload(BLUE_L, 0.7)
    v:stroke({{pa[i][1],pa[i][2]+7},{pb[i][1],pb[i][2]-1}}, {pressure={0.3,0.3}})
  end
end

--@ chunk 29
CABLE_P = {{285,650},{322,600},{368,548},{412,505},{448,470},{470,440}}
CABLE = ribbon(CABLE_P, 24) - ARMALL
work(CABLE, {hand="detail", tool="round 4", pile=GM[1], coverage=4, fill=true, clip=true, angle=-0.85})
local b = brush{kind="round", width=5, point=0.3}
local up = {}
for i,p in ipairs(CABLE_P) do up[i] = {p[1]-6, p[2]-7} end
b:reload(GM[4], 0.8)
b:stroke(up, {pressure={0.6,0.5}, clip=CABLE})
local h = brush{kind="round", width=1.8, point=0.6}
local up2 = {}
for i,p in ipairs(CABLE_P) do up2[i] = {p[1]-7, p[2]-9} end
h:reload(GM[5], 0.8)
h:stroke(up2, {pressure={0.45,0.3}, clip=CABLE})

--@ chunk 30
local A = ARMALL + CABLE
RIM = mask(function(x,y)
  if x < 150 or y < 240 then return 0 end
  local a = A:at(x,y)
  if a < 0.5 then return 0 end
  return (1 - A:at(x+2.2, y-2.6))
end)
RIMC = pile{{"lead white",1.2},{"zinc white",1},{"ultramarine ash",1},{"cerulean blue",0.5},{"bone black",0.2}}
work(RIM, {hand="detail", tool="round 2", pile=RIMC, coverage=3, fill=true, clip=true})
print(RIM:area())

--@ chunk 31
AMBER_HOT = pile{{"chrome yellow",2},{"cadmium yellow",1},{"lead white",1.2}}
function brace(x, y0, y1, dir, p, w)
  -- dir = 1 opens right ("{"), -1 opens left ("}")
  local ym = (y0+y1)/2
  local d = dir
  local b = brush{kind="round", width=w, point=0.9}
  local up = {{x+d*16, y0}, {x+d*4, y0+6}, {x, y0+22}, {x, ym-26}, {x-d*3, ym-10}, {x-d*14, ym}}
  local lo = {{x-d*14, ym}, {x-d*3, ym+10}, {x, ym+26}, {x, y1-22}, {x+d*4, y1-6}, {x+d*16, y1}}
  b:reload(p, 1.0)
  b:stroke(up, {pressure={0.2,0.95}, swell={0.5,1,1,0.9,1}, ramps={0.15,0.05}})
  b:reload(p, 1.0)
  b:stroke(lo, {pressure={0.95,0.2}, swell={1,0.9,1,1,0.5}, ramps={0.05,0.15}})
end
brace(662, 88, 350, 1, AMBER, 7)
brace(978, 88, 350, -1, AMBER, 7)

--@ chunk 32
HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
HAIR_HI = pile{{"bone black",1},{"ultramarine blue",1},{"zinc white",0.5}}
SKIN = pile{{"zinc white",2},{"lead white",1},{"rose madder",0.08},{"yellow ochre",0.04}}
SKIN_SH = pile{{"zinc white",2},{"cobalt violet",0.25},{"cerulean blue",0.12},{"rose madder",0.05}}
DRESS = pile{{"zinc white",3},{"cerulean blue",0.15}}
DRESS_SH = pile{{"zinc white",1.5},{"ultramarine blue",0.4},{"cobalt violet",0.2},{"bone black",0.1}}
local function facet(pts, p) work(poly(pts), {hand="detail", tool="round 1.6", pile=p, coverage=5, fill=true, clip=true}) end
local ox, oy = 0, 0
-- shadow on the grid
work(ellipse(852,499,16,3.5), {hand="detail", tool="round 1.6", pile=F_DEEP, coverage=4, fill=true, clip=true})
-- hair, back mass falling to the waist
facet({{842,434},{860,431},{871,441},{874,462},{872,482},{864,490},{858,476},{852,462}}, HAIR)
-- legs
facet({{845,486},{849,486},{848,499},{845,499}}, SKIN_SH)
facet({{853,486},{857,486},{857,499},{854,499}}, SKIN_SH)
-- dress: lit left facet, shaded right facet
facet({{843,463},{851,462},{851,489},{838,489}}, DRESS)
facet({{851,462},{858,464},{863,489},{851,489}}, DRESS_SH)
-- arms
facet({{842,465},{845,466},{841,481},{838,480}}, SKIN)
-- face: lit front facet, shaded side facet (facing left, toward the cable)
facet({{834,444},{846,441},{848,457},{840,462},{834,456}}, SKIN)
facet({{846,441},{853,444},{853,457},{848,457}}, SKIN_SH)
-- fringe and crown
facet({{832,446},{837,436},{848,431},{860,433},{852,440},{845,442},{838,449}}, HAIR)
facet({{846,433},{856,432},{851,437}}, HAIR_HI)

--@ chunk 33
local e = brush{kind="round", width=1.6, point=0.8}
e:reload(HAIR, 0.7)
e:touch(838.5, 450, {pressure=0.35})
-- the Thinking... stall: a speech bubble outline and three dots
local r = brush{kind="round", width=1.4, point=0.8}
local bub = {{796,414},{830,414},{833,417},{833,430},{830,433},{818,433},{813,439},{812,433},{799,433},{796,430},{796,414}}
r:reload(BLUE_L, 0.9)
r:stroke(bub, {pressure={0.45,0.45}, ramps={0.01,0.01}})
local d = brush{kind="round", width=3.2, point=0.2}
for i,a in ipairs({0.75,0.6,0.4}) do
  d:reload(i==1 and HOT or (i==2 and CYAN or BLUE_L), 0.8)
  d:touch(803 + (i-1)*8.5, 423.5, {pressure=a})
end

--@ chunk 34
local d = brush{kind="round", width=4.2, point=0.1}
for i,a in ipairs({0.9,0.8,0.65}) do
  d:reload(i==1 and HOT or (i==2 and CYAN or BLUE_L), 0.9)
  d:touch(803 + (i-1)*9, 423.5, {pressure=a})
end
local e = brush{kind="round", width=2.4, point=0.2}
e:reload(HAIR, 0.9)
e:touch(838.8, 450.5, {pressure=0.7})
-- her targeting box round his connector: red corner brackets
REDT = pile{{"cadmium red",1.5},{"vermilion",1},{"lead white",0.35}}
local r = brush{kind="round", width=2.6, point=0.3}
local x0,y0,x1,y1 = 468,236,612,352
local L = 18
local corners = {
  {{x0,y0+L},{x0,y0},{x0+L,y0}}, {{x1-L,y0},{x1,y0},{x1,y0+L}},
  {{x1,y1-L},{x1,y1},{x1-L,y1}}, {{x0+L,y1},{x0,y1},{x0,y1-L}} }
for _,c in ipairs(corners) do
  r:reload(REDT, 0.95)
  r:stroke({c[1],c[2]}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
  r:reload(REDT, 0.95)
  r:stroke({c[2],c[3]}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
end
-- a little red tag under the box
work(rect(x1-46, y1+5, 46, 9), {hand="detail", tool="round 2", pile=REDT, coverage=5, fill=true, clip=true})

--@ chunk 35
HAZ = (WALL * FIELD:grow(13)) - ARMALL:grow(1) - COLLAR:grow(1) - CABLE
AMBER_W = pile{{"chrome yellow",2},{"Mars orange",0.8},{"yellow ochre",1.2},{"bone black",0.08}}
work(HAZ, {hand="detail", tool="round 3", pile=AMBER_W, coverage=4, fill=true, clip=true, angle=1.3})

--@ chunk 36
WALLFREE = WALL - ARMALL:grow(2) - CABLE:grow(2) - HAZ - CONS - COLLAR:grow(2)
SEAM_D = pile{{"bone black",2},{"ultramarine ash",0.6},{"burnt sienna",0.3}}
LIP = pile{{"lead white",1.6},{"ultramarine ash",1},{"bone black",0.3},{"cerulean blue",0.15}}
local seams = {
  {{0,120},{640,120}}, {{172,0},{172,120}}, {{446,0},{446,120}},
  {{283,120},{283,500}}, {{0,502},{560,502}}, {{530,120},{530,500}},
}
local d = brush{kind="round", width=2.4, point=0.3}
local l = brush{kind="round", width=1.6, point=0.5}
for _,s in ipairs(seams) do
  local a, b = s[1], s[2]
  local horiz = math.abs(a[2]-b[2]) < 1
  d:reload(SEAM_D, 0.9)
  d:stroke({a,b}, {pressure={0.7,0.7}, ramps={0.01,0.01}, clip=WALLFREE, shake=0.3})
  l:reload(LIP, 0.8)
  local o = horiz and {0,2.6} or {2.6,0}
  l:stroke({{a[1]+o[1],a[2]+o[2]},{b[1]+o[1],b[2]+o[2]}}, {pressure={0.5,0.5}, ramps={0.01,0.01}, clip=WALLFREE, shake=0.3})
  -- rivets
  local len = math.sqrt((b[1]-a[1])^2+(b[2]-a[2])^2)
  local n = math.floor(len/30)
  local rv = brush{kind="round", width=3, point=0.1}
  for i=1,n do
    local t = (i-0.5)/n
    local x, y = lerp(a[1],b[1],t), lerp(a[2],b[2],t)
    local px, py = horiz and x or x+7, horiz and y+7 or y
    if WALLFREE:at(px,py) > 0.5 then
      rv:reload(SEAM_D, 0.6); rv:touch(px, py, {pressure=0.5})
      rv:reload(LIP, 0.5); rv:touch(px-0.8, py-0.8, {pressure=0.18})
    end
  end
end

--@ chunk 37
wait(3*24*60) print(drying(550,150), drying(400,250), drying(850,470))

--@ chunk 38
STRIPE = pile{{"bone black",2},{"Mars brown",0.4},{"ultramarine blue",0.3}}
local b = brush{kind="flat", width=7}
local n = 0
for c = 450, 1300, 17 do
  local xa, xb
  for x = 440, 700, 1 do
    local y = c - x
    if y >= -5 and y <= 630 and HAZ:at(x,y) > 0.5 then
      if not xa then xa = x end
      xb = x
    end
  end
  if xa and xb - xa < 60 then
    b:reload(STRIPE, 0.9)
    b:stroke({{xa-3, c-xa+3},{xb+3, c-xb-3}}, {pressure={0.8,0.8}, ramps={0.02,0.02}, clip=HAZ, orient="across"})
    n = n + 1
  end
end
print(n)

--@ chunk 39
local free = SCREEN - ARMALL:grow(3)
local t = brush{kind="round", width=1.9, point=0.2}
local function textrow(x0, x1, y, p, pr)
  local x = x0
  while x < x1 do
    local w = rand(5, 19)
    if x + w > x1 then w = x1 - x end
    if w > 2 then
      t:reload(p, 0.8)
      t:stroke({{x,y},{x+w,y}}, {pressure={pr,pr}, ramps={0.05,0.05}, clip=free})
    end
    x = x + w + rand(3.5, 5.5)
  end
end
SCR_TXT = pile{{"zinc white",3},{"cerulean blue",0.6}}
SCR_DIM = pile{{"zinc white",1.5},{"cerulean blue",1},{"ultramarine blue",0.4}}
-- carrier / protocol header
textrow(320, 470, 196, SCR_DIM, 0.5)
textrow(320, 420, 207, SCR_DIM, 0.5)
-- the amber brace line: { UNTRUSTED CONTENT FOLLOWS }
local g = brush{kind="round", width=1.6, point=0.7}
g:reload(AMBER_HOT, 0.9)
g:stroke({{326,220},{322,221},{322,226},{319,228},{322,230},{322,235},{326,236}}, {pressure={0.5,0.5}, clip=free})
textrow(331, 452, 228, AMBER_HOT, 0.55)
g:reload(AMBER_HOT, 0.9)
g:stroke({{456,220},{460,221},{460,226},{463,228},{460,230},{460,235},{456,236}}, {pressure={0.5,0.5}, clip=free})
-- the blinking DO NOT OBEY block
work(rect(322,244,74,11)*free, {hand="detail", tool="round 2", pile=REDT, coverage=5, fill=true, clip=true})
-- her words
for i,y in ipairs({266, 277, 288, 299, 310}) do
  textrow(320, 505 - i*12, y, SCR_TXT, 0.45)
end

--@ chunk 40
-- the socket: steel, not tape
work(COLLAR, {hand="detail", tool="round 3", pile=GM[3], coverage=5, fill=true, clip=true, angle=-0.588})
work(COLLAR*poly({AP2(690,-0.8),AP2(735,-0.8),AP2(735,-0.3),AP2(690,-0.3)}), {hand="detail", tool="round 2", pile=GM[5], coverage=5, fill=true, clip=true, angle=-0.588})
work(COLLAR*poly({AP2(690,0.25),AP2(735,0.25),AP2(735,0.7),AP2(690,0.7)}), {hand="detail", tool="round 2", pile=GM[1], coverage=5, fill=true, clip=true, angle=-0.588})
local r = brush{kind="round", width=2, point=0.5}
r:reload(AMBER_HOT, 0.9)
r:stroke({AP2(703,-0.64),AP2(703,0.54)}, {pressure={0.6,0.6}, clip=COLLAR})
r:reload(RIMC, 0.9)
r:stroke({AP2(700,-0.66),AP2(724,-0.66)}, {pressure={0.6,0.6}})
-- copper strands, dull at the socket, heating toward the node
local f = brush{kind="round", width=2.2, point=0.7}
local S = {SOCK[1], SOCK[2]}
local function lerp2(a,b,t) return {lerp(a[1],b[1],t), lerp(a[2],b[2],t)} end
for i,dv in ipairs({-11,-8,-5,-2.5,0,2.5,5,8,11}) do
  local p0 = {S[1]-2, S[2]+dv*0.9}
  local p1 = {S[1]+16, S[2]-10 + dv*0.85}
  local p2 = {S[1]+36, S[2]-23 + dv*0.45}
  local p3 = {S[1]+54, S[2]-34 + dv*0.12}
  local p4 = {NODE[1], NODE[2]}
  f:reload(COPPER, 0.85);   f:stroke({p0, p1, lerp2(p1,p2,0.5)}, {pressure={0.55,0.5}})
  f:reload(COPPER_HI, 0.85); f:stroke({lerp2(p1,p2,0.45), p2, lerp2(p2,p3,0.5)}, {pressure={0.5,0.45}})
  f:reload(AMBER_HOT, 0.85); f:stroke({lerp2(p2,p3,0.45), p3}, {pressure={0.45,0.35}})
  f:reload(HOT, 0.85);      f:stroke({lerp2(p2,p3,0.8), p3, p4}, {pressure={0.4,0.3}})
end
-- the node: a white-hot knot with a few hard glints
local n = brush{kind="round", width=7, point=0.2}
n:reload(CYAN, 0.9); n:touch(NODE[1], NODE[2], {pressure=0.9})
n:reload(HOT, 0.9);  n:touch(NODE[1]+0.5, NODE[2]-0.5, {pressure=0.65})
local g = brush{kind="round", width=1.6, point=0.9}
for _,a in ipairs({-2.6, -1.1, 0.5, 2.0, 2.9, -0.3}) do
  local L = rand(10, 22)
  g:reload(HOT, 0.8)
  g:stroke({{NODE[1]+math.cos(a)*3, NODE[2]+math.sin(a)*3},{NODE[1]+math.cos(a)*L, NODE[2]+math.sin(a)*L}}, {pressure={0.55,0.0}})
end

--@ chunk 41
local P1 = {692, 20, 812, 74}
local P2 = {832, 20, 962, 74}
for _,P in ipairs({P1,P2}) do
  work(rect(P[1],P[2],P[3]-P[1],P[4]-P[2]), {hand="detail", tool="round 2.5", pile=SLABFILL[2], coverage=4, fill=true, clip=true})
end
local r = brush{kind="round", width=1.6, point=0.6}
for _,P in ipairs({P1,P2}) do
  r:reload(BLUE_L, 0.9)
  r:stroke({{P[1],P[2]},{P[3],P[2]},{P[3],P[4]},{P[1],P[4]},{P[1],P[2]}}, {pressure={0.4,0.4}, ramps={0.01,0.01}})
  r:reload(CYAN, 0.9)
  r:stroke({{P[1]+4,P[2]+8},{P[1]+40,P[2]+8}}, {pressure={0.4,0.4}})
end
-- bar chart
local bb = brush{kind="flat", width=5}
local hs = {14, 22, 18, 30, 26, 34, 12, 38}
for i,h in ipairs(hs) do
  local x = P1[1] + 10 + (i-1)*13
  bb:reload(i==#hs and ORANGE or BLUE_L, 0.9)
  bb:stroke({{x, P1[4]-5},{x, P1[4]-5-h}}, {pressure={0.8,0.8}, ramps={0.01,0.01}, orient="across"})
end
-- ledger: rows and a figure column, then a sparkline
local t = brush{kind="round", width=1.5, point=0.3}
for row=0,3 do
  local y = P2[2] + 18 + row*9
  t:reload(SCR_DIM, 0.8); t:stroke({{P2[1]+6,y},{P2[1]+48,y}}, {pressure={0.4,0.4}})
  t:reload(SCR_TXT, 0.8); t:stroke({{P2[1]+56,y},{P2[1]+56+rand(14,24),y}}, {pressure={0.4,0.4}})
end
local sp = {}
for i=0,8 do sp[#sp+1] = {P2[1]+86+i*4.4, P2[2]+44 - (i*2.5) + rand(-6,6)} end
t:reload(ORANGE, 0.9); t:stroke(sp, {pressure={0.45,0.45}})

--@ chunk 42
-- shards of the wall drifting into her space: solid flat-shaded near the seam, wireframe further out
local shards = {
  {650, 30, 13, 0.0}, {668, 62, 9, 0.6}, {688, 100, 6, 1.3}, {640, 180, 8, 2.0}, {676, 196, 5, 2.6},
  {585, 395, 12, 0.3}, {612, 430, 8, 1.1}, {640, 400, 6, 1.9}, {596, 470, 7, 2.4}, {666, 455, 4.5, 3.0},
}
local r = brush{kind="round", width=1.4, point=0.7}
for i,s in ipairs(shards) do
  local cx, cy, R, a = s[1], s[2], s[3], s[4]
  local pts = {}
  for k=0,2 do
    local ang = a + k*2.094 + rand(-0.4,0.4)
    local rr = R*rand(0.7,1.25)
    pts[#pts+1] = {cx + math.cos(ang)*rr, cy + math.sin(ang)*rr*0.8}
  end
  local cxp = {(pts[1][1]+pts[2][1]+pts[3][1])/3 + rand(-1,1), (pts[1][2]+pts[2][2]+pts[3][2])/3 + rand(-1,1)}
  local dist = (cx - 600)
  if R >= 7 then
    -- solid: two facets (lit / shaded)
    work(poly({pts[1],pts[2],cxp}), {hand="detail", tool="round 1.6", pile=WZ1, coverage=5, fill=true, clip=true})
    work(poly({pts[2],pts[3],cxp}) + poly({pts[3],pts[1],cxp}), {hand="detail", tool="round 1.6", pile=WZ2, coverage=5, fill=true, clip=true})
  else
    -- wireframe only
    r:reload(BLUE_L, 0.8)
    r:stroke({pts[1],pts[2],pts[3],pts[1]}, {pressure={0.4,0.4}, ramps={0.01,0.01}})
  end
end

--@ chunk 43
local METAL = {{-1.05,-0.86,4},{-0.86,-0.62,5},{-0.62,-0.36,2},{-0.36,0.28,3},{0.28,0.76,1},{0.76,1.08,3}}
local function metalplate(t0,t1,seed)
  local whole = APOLY2(t0,t1,-1.0,1.0)
  for _,pr in ipairs(METAL) do
    work(APOLY2(t0,t1,pr[1],pr[2])*whole, {hand="body", tool="filbert 5", pile=GM[pr[3]], coverage=4, fill=true, clip=whole, angle=-0.588, angle_jitter=0.03, length={30,80}, seed=seed})
  end
  -- soften only the seams between bands, along the axis
  blend(whole:shrink(4), {angle=-0.588, tool={kind="badger", width=6}, coverage=0.6})
  return whole
end
metalplate(-40,198,11)
metalplate(204,388,12)

--@ chunk 44
local METAL = {{-1.05,-0.86,4},{-0.86,-0.62,5},{-0.62,-0.36,2},{-0.36,0.28,3},{0.28,0.76,1},{0.76,1.08,3}}
local whole = APOLY2(478,592,-1.0,1.0) - PLUG
for _,pr in ipairs(METAL) do
  work(APOLY2(478,592,pr[1],pr[2])*whole, {hand="body", tool="filbert 4", pile=GM[pr[3]], coverage=4, fill=true, clip=whole, angle=-0.588, angle_jitter=0.03, length={20,50}})
end
blend(whole:shrink(4), {angle=-0.588, tool={kind="badger", width=6}, coverage=0.6})
-- knuckle ridge across the back of the hand
local r = brush{kind="round", width=3, point=0.3}
r:reload(GM[1], 0.8); r:stroke({AP2(560,-0.98),AP2(560,0.2)}, {pressure={0.6,0.6}, clip=whole})
r:reload(GM[5], 0.8); r:stroke({AP2(564,-0.98),AP2(564,-0.3)}, {pressure={0.45,0.3}, clip=whole})

--@ chunk 45
function seg2(t0,t1,s0,s1)
  local m = poly({AP2(t0,s0),AP2(t1-4,s0),AP2(t1,s0+0.1),AP2(t1,s1-0.1),AP2(t1-4,s1),AP2(t0,s1)}, true)
  local function band(a,b) return poly({AP2(t0-6,lerp(s0,s1,a)),AP2(t1+6,lerp(s0,s1,a)),AP2(t1+6,lerp(s0,s1,b)),AP2(t0-6,lerp(s0,s1,b))}) end
  work(m, {hand="detail", tool="round 2.5", pile=GM[3], coverage=4, fill=true, clip=true, angle=-0.588})
  work(m*band(-0.2,0.28), {hand="detail", tool="round 2", pile=GM[5], coverage=4, fill=true, clip=true, angle=-0.588})
  work(m*band(0.28,0.45), {hand="detail", tool="round 2", pile=GM[2], coverage=4, fill=true, clip=true, angle=-0.588})
  work(m*band(0.62,1.2), {hand="detail", tool="round 2", pile=GM[1], coverage=4, fill=true, clip=true, angle=-0.588})
  return m
end
local T1 = seg2(548,600,-0.98,-0.46)
local T2 = seg2(598,644,-0.9,-0.42)
local F = {}
local rows = {{0.22,0.46},{0.48,0.71},{0.73,0.95}}
for i,rw in ipairs(rows) do
  F[#F+1] = seg2(586-i*3, 622-i*3, rw[1], rw[2])
  F[#F+1] = seg2(620-i*3, 652-i*4, rw[1]+0.01, rw[2]-0.01)
end
FINGERS2 = T1 + T2
for _,m in ipairs(F) do FINGERS2 = FINGERS2 + m end
ARMALL = ARMALL + FINGERS2

--@ chunk 46
wait(5*24*60) print(drying(200,520), drying(450,330), drying(360,248), drying(820,200))

--@ chunk 47
wait(6*24*60) print(drying(200,520), drying(450,330), drying(360,248), drying(820,200))

--@ chunk 48
SPEC = pile{{"lead white",2},{"zinc white",1},{"ultramarine ash",0.5},{"cerulean blue",0.2}}
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local h = brush{kind="round", width=2.2, point=0.8}
for _,seg in ipairs({{-30,60},{75,150},{160,192},{212,300},{312,380},{482,552}}) do
  h:reload(SPEC, 0.8)
  h:stroke(LINE2(seg[1],seg[2],-0.75,4), {pressure={0.15,0.5}, swell={0.6,1,1,0.4}, clip=ARMALL})
end
-- the overlap of plate B over plate A: shadow line and lit lip
local d = brush{kind="round", width=3, point=0.3}
d:reload(GM[1], 0.8)
d:stroke({AP2(197,-0.98),AP2(197,0),AP2(197,0.98)}, {pressure={0.7,0.7}, clip=ARMALL})
h:reload(SPEC, 0.7)
h:stroke({AP2(203,-0.98),AP2(203,-0.5)}, {pressure={0.5,0.2}, clip=ARMALL})
h:reload(GM[4], 0.7)
h:stroke({AP2(203,-0.5),AP2(203,0.4)}, {pressure={0.4,0.3}, clip=ARMALL})
-- a worn bone cross stencilled on the vambrace (head toward the hand)
local c = brush{kind="flat", width=5}
c:reload(BONE, 0.35)
c:stroke({AP2(268,-0.05),AP2(330,-0.05)}, {pressure={0.45,0.4}, orient="across", clip=ARMALL})
c:reload(BONE, 0.35)
c:stroke({AP2(314,-0.32),AP2(314,0.22)}, {pressure={0.45,0.4}, orient="across", clip=ARMALL})
-- scratches
local s = brush{kind="round", width=1.2, point=0.8}
for i=1,16 do
  local t = rand(20,380); local sv = rand(-0.6,0.5)
  local p0 = AP2(t, sv)
  local a = -0.588 + rand(-0.5,0.5)
  local L = rand(5,16)
  s:reload(GM[5], 0.4)
  s:stroke({p0, {p0[1]+math.cos(a)*L, p0[2]+math.sin(a)*L}}, {pressure={0.4,0.1}, clip=ARMALL})
end

--@ chunk 49
-- DO NOT OBEY: dark letters-as-dashes in the red block
local t = brush{kind="round", width=1.7, point=0.2}
local x = 326
for _,w in ipairs({9,0,11,0,13,0}) do
  if w > 0 then
    t:reload(STRIPE, 0.8)
    t:stroke({{x,249.5},{x+w,249.5}}, {pressure={0.5,0.5}, ramps={0.05,0.05}})
    x = x + w + 6
  end
end
-- labels on each slab of the stack (her layers, each named)
for k=1,5 do
  local S = SLABS[k]
  local cx, cy = S.cx, S.cy
  -- dashes laid along the slab's plane (parallel to the front edge)
  local x0 = cx - 70
  local n = 0
  local xx = x0
  while xx < cx + 40 and n < 5 do
    local w = rand(8, 22)
    t:reload(TRACE_P[k], 0.8)
    t:stroke({{xx, cy-2},{xx+w, cy-2}}, {pressure={0.35,0.35}, ramps={0.05,0.05}})
    xx = xx + w + rand(5,8); n = n + 1
  end
end
-- packets travelling the traces: short bright dashes
local pk = brush{kind="flat", width=2.6}
for k=1,5 do
  local pts = TRACES[k]
  for _,f in ipairs({0.45, 0.8}) do
    local i = math.max(2, math.floor(f*(#pts-1))+1)
    local a, b = pts[i-1], pts[i]
    local u = rand(0.3,0.7)
    local px, py = lerp(a[1],b[1],u), lerp(a[2],b[2],u)
    local ang = math.atan(b[2]-a[2], b[1]-a[1])
    pk:reload(HOT, 0.9)
    pk:stroke({{px - math.cos(ang)*3, py - math.sin(ang)*3},{px + math.cos(ang)*3, py + math.sin(ang)*3}}, {pressure={0.8,0.8}, orient="across"})
  end
end

--@ chunk 50
local PL = rect(196,30,108,62)
work(PL, {hand="detail", tool="round 3", pile=AMBER_W, coverage=5, fill=true, clip=true})
-- grime streaks running down from the seams and rivets
GRIME = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.2}}
local g = brush{kind="filbert", width=4}
for i=1,26 do
  local x = rand(10, 520)
  local y0 = (rand(0,1) < 0.6) and 124 or 506
  if y0 == 506 then x = rand(300, 520) end
  local L = rand(18, 70)
  if WALLFREE:at(x, y0+4) > 0.5 then
    g:reload(GRIME, rand(0.12,0.22))
    g:stroke({{x, y0+2},{x+rand(-1.5,1.5), y0+L}}, {pressure={0.45,0.05}, clip=WALLFREE})
  end
end

--@ chunk 51
wait(4*24*60) print(drying(250,60), drying(80,140))

--@ chunk 52
wait(4*24*60) print(drying(250,60), drying(80,140))

--@ chunk 53
local x0,y0,x1,y1 = 196,30,304,92
local r = brush{kind="round", width=2.2, point=0.3}
r:reload(STRIPE, 0.9)
r:stroke({{x0+3,y0+3},{x1-3,y0+3},{x1-3,y1-3},{x0+3,y1-3},{x0+3,y0+3}}, {pressure={0.6,0.6}, ramps={0.01,0.01}})
-- header band
work(rect(x0+6,y0+6,x1-x0-12,12), {hand="detail", tool="round 2", pile=STRIPE, coverage=5, fill=true, clip=true})
-- hazard triangle
local tri = poly({{x0+18,y0+24},{x0+30,y0+46},{x0+6,y0+46}})
work(tri, {hand="detail", tool="round 1.6", pile=STRIPE, coverage=5, fill=true, clip=true})
-- text rows
local t = brush{kind="round", width=1.8, point=0.2}
for i,y in ipairs({y0+27, y0+35, y0+43, y0+51}) do
  local xx = x0 + 38
  while xx < x1 - 12 do
    local w = rand(5, 16)
    if xx + w > x1 - 10 then w = x1 - 10 - xx end
    if w > 2 then t:reload(STRIPE, 0.8); t:stroke({{xx,y},{xx+w,y}}, {pressure={0.45,0.45}, ramps={0.05,0.05}}) end
    xx = xx + w + rand(3,5)
  end
end
-- a hand-painted addition below it, in white: a crude arrow pointing at the terminal
local w = brush{kind="round", width=3.2, point=0.5}
w:reload(BONE, 0.55)
w:stroke({{x0+8,y1+12},{x0+60,y1+14},{x1+30,y1+40}}, {pressure={0.6,0.5}})
w:reload(BONE, 0.5)
w:stroke({{x1+18,y1+40},{x1+31,y1+41},{x1+27,y1+29}}, {pressure={0.6,0.5}})

--@ chunk 54
local N = NODE
local g = brush{kind="round", width=2.0, point=0.9}
local n = 0
for i=1,18 do
  local a = (i/18)*2*math.pi + rand(-0.12,0.12)
  local L = (i%3==0) and rand(55,85) or rand(18,40)
  local x1, y1 = N[1]+math.cos(a)*L, N[2]+math.sin(a)*L
  if WALL:at(x1,y1) < 0.5 and not (math.cos(a) < -0.5 and math.abs(math.sin(a)) < 0.6) then
    g:reload((i%2==0) and HOT or CYAN, 0.8)
    g:stroke({{N[1]+math.cos(a)*5, N[2]+math.sin(a)*5},{x1,y1}}, {pressure={0.45,0.0}, ramps={0.02,0.6}})
    n = n + 1
  end
end
-- a thin handshake ring round the knot
local ring = {}
for i=0,40 do local a = i/40*2*math.pi; ring[#ring+1] = {N[1]+math.cos(a)*16, N[2]+math.sin(a)*13} end
g:reload(BLUE_L, 0.9)
g:stroke(ring, {pressure={0.3,0.3}, ramps={0.01,0.01}})
-- brighter, bigger knot
local k = brush{kind="round", width=10, point=0.1}
k:reload(CYAN, 0.9); k:touch(N[1], N[2], {pressure=0.8})
k = brush{kind="round", width=6, point=0.1}
k:reload(HOT, 1.0); k:touch(N[1], N[2], {pressure=0.9})
print(n)

--@ chunk 55
-- her stack speaks through the stall: a dotted thread from the lowest layer down to the bubble
local S = SLABS[5]
local p = slabpts(S.cx, S.cy)
local a = {p[4][1]-30, p[4][2]+8}
local b = {812, 412}
local d = brush{kind="round", width=2.4, point=0.2}
for i=0,12 do
  local t = i/12
  d:reload(MAGENTA_L, 0.8)
  d:touch(lerp(a[1],b[1],t), lerp(a[2],b[2],t), {pressure=0.35 + 0.25*(1-t)})
end
-- the cable: a cool highlight from the glow and a scuffed stretch where the braid shows
local c = brush{kind="round", width=2.4, point=0.6}
local up = {}
for i,q in ipairs(CABLE_P) do up[i] = {q[1]+3, q[2]-7} end
c:reload(RIMC, 0.8)
c:stroke({up[3],up[4],up[5],up[6]}, {pressure={0.1,0.55}, clip=CABLE})
local bx = brush{kind="round", width=1.4, point=0.6}
for i=0,9 do
  local t = 0.25 + i*0.035
  local q1 = {lerp(CABLE_P[2][1],CABLE_P[4][1],t*1.6-0.2), lerp(CABLE_P[2][2],CABLE_P[4][2],t*1.6-0.2)}
  bx:reload(COPPER, 0.5)
  bx:stroke({{q1[1]-8,q1[2]-4},{q1[1]+5,q1[2]+8}}, {pressure={0.4,0.4}, clip=CABLE})
  bx:reload(GM[4], 0.5)
  bx:stroke({{q1[1]-6,q1[2]+6},{q1[1]+6,q1[2]-5}}, {pressure={0.35,0.35}, clip=CABLE})
end

--@ chunk 56
local d = brush{kind="round", width=2.2, point=0.4}
local l = brush{kind="round", width=1.5, point=0.7}
local function joint(t, s0, s1)
  d:reload(GM[1], 0.8); d:stroke({AP2(t,s0),AP2(t,s1)}, {pressure={0.6,0.6}, clip=ARMALL})
  l:reload(SPEC, 0.6);  l:stroke({AP2(t+2.2,s0+0.02),AP2(t+2.2,lerp(s0,s1,0.45))}, {pressure={0.45,0.15}, clip=ARMALL})
end
joint(599, -0.92, -0.44)
for i=1,3 do
  local rw = ({{0.22,0.46},{0.48,0.71},{0.73,0.95}})[i]
  joint(620-i*3, rw[1]+0.02, rw[2]-0.02)
  -- gap line between fingers
  d:reload(GM[1], 0.8)
  d:stroke({AP2(583-i*3, rw[1]), AP2(652-i*4, rw[1])}, {pressure={0.4,0.4}, clip=ARMALL})
end
-- fingertip glints from the spark
for i,rw in ipairs({{0.22,0.46},{0.48,0.71},{0.73,0.95}}) do
  l:reload(CYAN, 0.7)
  l:stroke({AP2(652-i*4-2, rw[1]+0.04), AP2(652-i*4, lerp(rw[1],rw[2],0.5))}, {pressure={0.5,0.2}, clip=ARMALL})
end
l:reload(CYAN, 0.7)
l:stroke({AP2(641,-0.86), AP2(643,-0.6)}, {pressure={0.5,0.2}, clip=ARMALL})

--@ chunk 57
local function pipe(x0, w, seed)
  local whole = rect(x0, -5, w, 640) - ARMALL:grow(1) - CABLE:grow(1)
  local prof = {{0,0.12,3},{0.12,0.32,5},{0.32,0.45,2},{0.45,0.75,3},{0.75,1.0,1}}
  for _,p in ipairs(prof) do
    work(whole*rect(x0+w*p[1], -5, w*(p[2]-p[1])+0.5, 640), {hand="detail", tool="round 2.5", pile=GM[p[3]], coverage=4, fill=true, clip=true, angle=1.5708})
  end
  -- brackets
  for _,y in ipairs({60, 230, 400}) do
    local br = rect(x0-4, y, w+8, 9) - ARMALL:grow(1)
    work(br, {hand="detail", tool="round 2", pile=GM[2], coverage=4, fill=true, clip=true})
    local l = brush{kind="round", width=1.4, point=0.6}
    l:reload(SPEC, 0.6); l:stroke({{x0-3,y+1},{x0+w+3,y+1}}, {pressure={0.4,0.4}, clip=br})
  end
end
pipe(38, 22)
pipe(66, 13)

--@ chunk 58
local busy = WALL:grow(6)
for k=1,5 do busy = busy + SLABS[k].top:grow(4) + SLABS[k].front:grow(4) end
busy = busy + rect(686,14,282,66) + ellipse(852,465,28,40)
local sq = brush{kind="flat", width=2.2}
local n = 0
for i=1,90 do
  local x, y
  if i <= 40 then
    -- drifting out from the knot toward the stack and up
    local t = rand(0.05,1)
    x = NODE[1] + t*rand(40,300); y = NODE[2] - t*rand(-60,200) + rand(-25,25)
  else
    x = rand(570, 995); y = rand(5, 395)
  end
  if x > 560 and x < 998 and y > 2 and y < 400 and busy:at(x,y) < 0.5 then
    local p = (rand(0,1) < 0.3) and CYAN or BLUE_L
    sq:reload(p, 0.7)
    local L = rand(1,2.4)
    sq:stroke({{x,y},{x+L,y}}, {pressure={rand(0.35,0.75),0.5}, orient="across"})
    n = n + 1
  end
end
print(n)

--@ chunk 59
wait(6*24*60)
print(drying(795,50), drying(940,55))
local P1 = {692, 20, 812, 74}
local bb = brush{kind="flat", width=5}
local x = P1[1] + 10 + 7*13
bb:reload(ORANGE, 1.0)
bb:stroke({{x, P1[4]-5},{x, P1[4]-5-38}}, {pressure={0.85,0.85}, ramps={0.01,0.01}, orient="across"})

--@ chunk 60
local t = brush{kind="round", width=2.0, point=0.3}; t:reload(ORANGE, 1.0); t:stroke({{918,66},{924,64},{930,60},{935,50},{940,44},{946,42},{953,40}}, {pressure={0.6,0.6}, ramps={0.02,0.02}})
