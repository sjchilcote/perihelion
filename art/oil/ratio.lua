-- easel session "ratio": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.8, linen={18,16}, seed=1997,
  ground={{pile={{"lead white",3},{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.6}}, um=80, apply="knife", texture=0.3}}}
print(W,H)

--@ chunk 2
function rrect(x0,y0,x1,y1,r,bulge)
  bulge = bulge or 0
  local pts = {}
  local cs = {{x1-r,y0+r,-math.pi/2},{x1-r,y1-r,0},{x0+r,y1-r,math.pi/2},{x0+r,y0+r,math.pi}}
  for _,c in ipairs(cs) do
    for k=0,6 do local a=c[3]+k*(math.pi/2)/6
      pts[#pts+1]={c[1]+r*math.cos(a), c[2]+r*math.sin(a)} end
  end
  return poly(pts)
end
BEZEL = rrect(38,48,962,1092,46)
SCREEN = rrect(96,108,904,1022,60)
local room = -BEZEL
local P_room = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.7}}
local P_bez = pile{{"bone black",2.5},{"ultramarine ash",1},{"lead white",0.25}}
local P_deep = pile{{"ultramarine blue",2},{"viridian",1},{"bone black",1.2}}
work(room, {hand="broad", pile=P_room, coverage=3, fill=true, clip=true})
work(BEZEL - SCREEN, {hand="body", pile=P_bez, coverage=3, fill=true, clip=true, angle=0})
work(SCREEN, {hand="broad", pile=P_deep, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 3
P_mid = pile{{"cerulean blue",2},{"viridian",1},{"ultramarine blue",1.2},{"lead white",0.8},{"bone black",0.3}}
P_glow = pile{{"cerulean blue",2},{"viridian",1},{"ultramarine blue",0.5},{"lead white",2}}
local g1 = ellipse(500,560,330,420) * SCREEN
work(g1, {hand="body", pile=P_mid, coverage=3, fill=true, edge="soft", angle=0, length={30,70}})
local g2 = ellipse(500,520,190,280)
work(g2, {hand="body", pile=P_glow, coverage=2.5, fill=true, edge="soft", angle=0, length={30,60}})
blend(ellipse(500,550,380,470):rim(80,20) * SCREEN, {angle=0})
blend(ellipse(500,520,190,280):rim(60,15), {angle=0})

--@ chunk 4
print(wait(1440), drying(500,500), drying(150,150))
local R = {
 pile{{"ultramarine blue",2},{"viridian",0.6},{"bone black",1.2}},
 pile{{"ultramarine blue",2},{"cobalt blue",1},{"bone black",0.5},{"lead white",0.2}},
 pile{{"ultramarine blue",1.5},{"cobalt blue",1.5},{"cerulean blue",0.5},{"lead white",0.5}},
 pile{{"cobalt blue",1.5},{"cerulean blue",1.5},{"ultramarine blue",0.5},{"lead white",1.1}},
 pile{{"cerulean blue",2},{"cobalt blue",0.6},{"lead white",2.2}},
}
local sx, sy = 112, 118
local P = {}
for j=0,9 do P[j]={} for i=0,9 do
  local x = 60 + i*sx + ((i>0 and i<9) and rand(-34,34) or 0)
  local y = 70 + j*sy + ((j>0 and j<9) and rand(-34,34) or 0)
  P[j][i]={x,y} end end
local n=0
for j=0,8 do for i=0,8 do
  local a,b,c,d = P[j][i],P[j][i+1],P[j+1][i+1],P[j+1][i]
  local tris = (math.random()<0.5) and {{a,b,c},{a,c,d}} or {{a,b,d},{b,c,d}}
  for _,t in ipairs(tris) do
    local cx=(t[1][1]+t[2][1]+t[3][1])/3; local cy=(t[1][2]+t[2][2]+t[3][2])/3
    local dd = math.sqrt(((cx-500)/360)^2 + ((cy-540)/470)^2)
    local k = clamp(math.floor(5.6 - dd*4.2 + rand(-0.6,0.6)),1,5)
    local m = poly(t) * SCREEN
    if m:area() > 10 then
      work(m, {hand="body", tool="filbert 7", pile=R[k], coverage=3.2, fill=true, clip=true, angle=rand(-0.3,0.3), length={20,50}})
      n=n+1
    end
  end
end end
print(n)

--@ chunk 5
HAIR = poly{{500,212},{575,220},{640,250},{690,300},{722,365},{735,440},{732,520},{742,610},{758,700},{772,790},{782,870},{752,845},{738,905},{708,860},{690,915},{662,870},{630,900},{600,868},{560,882},{500,862},{440,885},{400,870},{372,905},{350,860},{318,912},{300,858},{268,880},{240,860},{250,780},{262,690},{268,600},{262,520},{265,440},{282,360},{318,293},{372,245},{432,220}}
HP = {
 pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}},
 pile{{"bone black",2},{"ultramarine blue",1.5},{"lead white",0.3}},
 pile{{"ultramarine blue",1.2},{"bone black",1},{"lead white",0.7},{"cobalt violet",0.3}},
 pile{{"ultramarine blue",1},{"cerulean blue",0.8},{"lead white",1.4},{"bone black",0.25}},
}
function facet(t, p, tool, clipm)
  local m = poly(t)
  if clipm then m = m * clipm end
  if m:area() < 4 then return end
  work(m, {hand="body", tool=tool or "filbert 5", pile=p, coverage=3.2, fill=true, clip=true, angle=rand(-0.4,0.4)+math.pi/2, length={15,40}})
end
local G = {}
local xs, ys = {}, {}
for i=0,8 do xs[i] = 225 + i*72 end
for j=0,6 do ys[j] = 200 + j*122 end
for j=0,6 do G[j]={} for i=0,8 do
  local jx = (i>0 and i<8) and rand(-22,22) or 0
  local jy = (j>0 and j<6) and rand(-40,40) or 0
  G[j][i] = {xs[i]+jx, ys[j]+jy} end end
local n=0
for j=0,5 do for i=0,7 do
  local a,b,c,d = G[j][i],G[j][i+1],G[j+1][i+1],G[j+1][i]
  local tris = (math.random()<0.5) and {{a,b,c},{a,c,d}} or {{a,b,d},{b,c,d}}
  for _,t in ipairs(tris) do
    local cx=(t[1][1]+t[2][1]+t[3][1])/3; local cy=(t[1][2]+t[2][2]+t[3][2])/3
    local lit = -(cx-500)/260*0.8 - (cy-500)/400 + rand(-0.5,0.5)
    local k = lit > 0.9 and 3 or (lit > 0.0 and 2 or 1)
    if cy < 360 and cy > 250 and cx < 600 and cx > 330 and math.random() < 0.6 then k = 4 end
    if HAIR:at(cx,cy) > 0.3 or (poly(t)*HAIR):area() > 20 then facet(t, HP[k], nil, HAIR); n=n+1 end
  end
end end
print(n)

--@ chunk 6
print(wait(2880), drying(500,500), drying(300,700))
FACE = poly{{392,372},{608,372},{628,448},{614,522},{562,584},{500,610},{438,584},{388,522},{372,448}}
local G = {}
for j=0,6 do G[j]={} for i=0,8 do
  local jx = (i>0 and i<8) and rand(-22,22) or 0
  local jy = (j>0 and j<6) and rand(-40,40) or 0
  G[j][i] = {225 + i*72+jx, 200 + j*122+jy} end end
local n=0
local MASK = HAIR - FACE:shrink(12)
for j=0,5 do for i=0,7 do
  local a,b,c,d = G[j][i],G[j][i+1],G[j+1][i+1],G[j+1][i]
  local tris = (math.random()<0.5) and {{a,b,c},{a,c,d}} or {{a,b,d},{b,c,d}}
  for _,t in ipairs(tris) do
    local cx=(t[1][1]+t[2][1]+t[3][1])/3; local cy=(t[1][2]+t[2][2]+t[3][2])/3
    local lit = -(cx-500)/260*0.8 - (cy-450)/400 + rand(-0.5,0.5)
    local k = lit > 1.0 and 2 or 1
    if cy < 345 and cy > 250 and cx < 610 and cx > 330 then k = (math.random()<0.55) and 4 or 3 end
    if (poly(t)*MASK):area() > 20 then facet(t, HP[k], "filbert 6", MASK); n=n+1 end
  end
end end
print(n)

--@ chunk 7
S1 = pile{{"lead white",6},{"yellow ochre",0.3},{"vermilion",0.15}}
S2 = pile{{"lead white",4},{"yellow ochre",0.4},{"vermilion",0.3},{"cobalt violet",0.15}}
S3 = pile{{"lead white",3},{"vermilion",0.3},{"rose madder",0.2},{"cobalt violet",0.35},{"ultramarine blue",0.15}}
S4 = pile{{"lead white",2},{"rose madder",0.3},{"cobalt violet",0.4},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
D1 = pile{{"lead white",4},{"cerulean blue",0.1}}
D15 = pile{{"lead white",3.5},{"ultramarine ash",0.3}}
D2 = pile{{"lead white",3},{"ultramarine ash",0.6},{"cobalt violet",0.2}}
D3 = pile{{"lead white",2},{"ultramarine ash",0.8},{"ultramarine blue",0.3},{"bone black",0.1}}
O1 = pile{{"cadmium yellow",1},{"Mars orange",1.5},{"lead white",0.3}}
O2 = pile{{"vermilion",1},{"cadmium red",1}}
O3 = pile{{"cadmium red",1},{"Mars red",0.6},{"rose madder",0.3}}
function f(p, pile_, tool) 
  local m = poly(p)
  work(m, {hand="body", tool=tool or "filbert 4", pile=pile_, coverage=3.5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}})
end
local A,B,C,D,E,F,G,H,I = {392,372},{608,372},{628,448},{614,522},{562,584},{500,610},{438,584},{388,522},{372,448}
local M1,L,R,N = {500,420},{432,498},{570,500},{496,522}
f({{478,598},{522,598},{526,652},{474,652}}, S4)
f({A,M1,I},S1); f({I,M1,L},S1); f({M1,B,C},S2); f({M1,C,R},S2); f({M1,L,N},S1); f({M1,N,R},S2)
f({I,L,H},S1); f({H,L,G},S2); f({L,N,G},S1); f({G,N,F},S2); f({N,R,E},S2); f({N,E,F},S3)
f({R,C,D},S3); f({R,D,E},S3)
-- dress
f({{452,640},{500,655},{432,745}},D1); f({{432,745},{500,655},{470,830}},D15); f({{432,745},{470,830},{398,830}},D2)
f({{500,655},{548,640},{566,742}},D2); f({{500,655},{566,742},{540,828}},D15); f({{500,655},{540,828},{470,830}},D1)
f({{566,742},{604,826},{540,828}},D3)
f({{398,830},{604,826},{598,806},{404,810}},O1)
f({{480,648},{520,648},{500,692}},O1)
-- sleeves and arms
f({{452,640},{425,652},{418,690},{445,694}},D1)
f({{420,690},{445,694},{430,765},{410,760}},S2)
f({{405,758},{432,762},{436,790},{418,800},{402,786}},S1)
f({{548,640},{575,650},{585,685},{556,690}},D2)
f({{575,668},{590,690},{640,655},{628,632}},S2)
f({{628,632},{645,652},{668,580},{650,570}},S1)
f({{642,575},{676,568},{690,530},{672,505},{648,510},{636,540}},S1)
f({{638,562},{622,548},{636,535}},S2)
-- legs, socks, shoes
f({{448,826},{478,826},{476,880},{452,880}},S2); f({{522,826},{552,826},{550,880},{526,880}},S3)
f({{450,880},{477,880},{476,905},{452,905}},D1); f({{524,880},{551,880},{552,905},{524,905}},D2)
f({{442,903},{480,903},{482,935},{436,938},{432,925}},O2)
f({{520,903},{554,903},{560,930},{512,940},{506,930}},O3)

--@ chunk 8
print(wait(4320), drying(470,700), drying(500,450))
local function g(p, pile_, tool) 
  work(poly(p), {hand="body", tool=tool or "filbert 4", pile=pile_, coverage=4.5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}})
end
f = g
f({{452,640},{500,655},{432,745}},D1); f({{432,745},{500,655},{470,830}},D15); f({{432,745},{470,830},{398,830}},D2)
f({{500,655},{548,640},{566,742}},D2); f({{500,655},{566,742},{540,828}},D15); f({{500,655},{540,828},{470,830}},D1)
f({{566,742},{604,826},{540,828}},D3)
f({{452,640},{425,652},{418,690},{445,694}},D1)
f({{420,690},{445,694},{430,765},{410,760}},S2)
f({{405,758},{432,762},{436,790},{418,800},{402,786}},S1)
f({{548,640},{575,650},{585,685},{556,690}},D2)
f({{575,668},{590,690},{640,655},{628,632}},S2)
f({{628,632},{645,652},{668,580},{650,570}},S1)
f({{642,575},{676,568},{690,530},{672,505},{648,510},{636,540}},S1)
f({{448,826},{478,826},{476,880},{452,880}},S2); f({{522,826},{552,826},{550,880},{526,880}},S3)
HP1 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
HP2 = pile{{"bone black",2},{"ultramarine blue",1.5},{"lead white",0.3}}
HP3 = pile{{"ultramarine blue",1.2},{"bone black",1},{"lead white",0.7},{"cobalt violet",0.3}}
f({{365,328},{640,328},{642,382},{363,382}},HP1)
f({{380,340},{470,340},{420,470}},HP3)
f({{440,345},{540,345},{488,445}},HP2)
f({{510,345},{610,345},{560,462}},HP1)
f({{590,345},{642,360},{630,472},{606,420}},HP1)
f({{362,345},{402,350},{386,472},{368,430}},HP2)
f({{368,430},{398,480},{396,620},{380,702},{362,610}},HP2)
f({{632,440},{610,500},{608,620},{622,694},{640,600}},HP1)

--@ chunk 9
BANGS = poly{{365,328},{640,328},{642,382},{363,382}} + poly{{380,340},{470,340},{420,470}} + poly{{440,345},{540,345},{488,445}}
  + poly{{510,345},{610,345},{560,462}} + poly{{590,345},{642,360},{630,472},{606,420}} + poly{{362,345},{402,350},{386,472},{368,430}}
  + poly{{368,430},{398,480},{396,620},{380,702},{362,610}} + poly{{632,440},{610,500},{608,620},{622,694},{640,600}}
local NB = -BANGS
local function g(p, pile_, tool, cov) 
  work(poly(p)*NB, {hand="body", tool=tool or "filbert 4", pile=pile_, coverage=cov or 4.5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}})
end
local A,B,C,D,E,F,G,H,I = {392,372},{608,372},{628,448},{614,522},{562,584},{500,610},{438,584},{388,522},{372,448}
local M1,L,R,N = {500,420},{432,498},{570,500},{496,522}
g({A,M1,I},S1); g({I,M1,L},S1); g({M1,B,C},S2); g({M1,C,R},S2); g({M1,L,N},S1); g({M1,N,R},S2)
g({I,L,H},S2); g({H,L,G},S2); g({L,N,G},S1); g({G,N,F},S2); g({N,R,E},S2); g({N,E,F},S3)
g({R,C,D},S3); g({R,D,E},S3)
g({{478,600},{522,600},{526,652},{474,652}}, S4)
print(wait(1440))
-- eyes
local K = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local IR = pile{{"ultramarine blue",1.5},{"cobalt violet",1},{"lead white",0.8}}
local IR2 = pile{{"cerulean blue",1},{"cobalt violet",0.6},{"lead white",2}}
local WH = pile{{"zinc white",4},{"lemon chrome",0.05}}
local PK = pile{{"lead white",3},{"rose madder",0.6},{"vermilion",0.25}}
local MO = pile{{"rose madder",1},{"Mars red",0.6},{"bone black",0.3}}
local function e(p, pile_, cov) work(poly(p), {hand="detail", tool="round 3", pile=pile_, coverage=cov or 4, fill=true, clip=true}) end
e({{418,450},{476,448},{483,480},{473,514},{427,516},{413,484}}, K)
e({{424,484},{474,484},{469,509},{430,511}}, IR)
e({{432,500},{466,499},{463,510},{435,511}}, IR2)
e({{410,446},{481,440},{488,456},{407,462}}, K)
e({{526,452},{584,454},{590,486},{581,514},{536,512},{524,482}}, K)
e({{530,486},{584,488},{578,509},{538,509}}, IR)
e({{540,500},{574,501},{571,510},{543,510}}, IR2)
e({{520,448},{588,450},{594,466},{519,462}}, K)
e({{428,460},{442,459},{443,473},{429,474}}, WH)
e({{458,492},{466,492},{466,499},{458,499}}, WH)
e({{537,463},{551,462},{552,476},{538,477}}, WH)
e({{566,494},{574,494},{574,501},{566,501}}, WH)
-- blush, mouth
e({{416,528},{446,525},{442,538},{414,540}}, PK, 3)
e({{556,526},{588,528},{586,540},{556,538}}, PK, 3)
e({{490,562},{516,561},{508,578},{500,579}}, MO)
-- bow, thumb
e({{478,650},{522,650},{500,694}}, O1)
e({{646,552},{626,540},{640,526},{652,532}}, S2)

--@ chunk 10
print(drying(300,600), drying(500,700))
HP4 = pile{{"ultramarine blue",1},{"cerulean blue",0.8},{"lead white",1.4},{"bone black",0.25}}
local function h(p, pile_) work(poly(p)*HAIR, {hand="body", tool="filbert 5", pile=pile_, coverage=4, fill=true, clip=true, angle=rand(0,3.1), length={12,35}}) end
local T = {{270,372},{318,293},{372,245},{432,214},{500,206},{575,214},{640,246},{690,298},{730,372}}
local Rg = {{300,372},{345,318},{405,285},{470,268},{540,270},{606,290},{660,325},{705,372}}
local Bt = {{300,400},{360,352},{440,342},{520,342},{600,348},{660,362},{720,400}}
local upper = {HP3,HP3,HP3,HP2,HP2,HP1,HP1,HP1}
for i=1,8 do
  h({T[i],T[i+1],Rg[i]}, upper[i])
  if i<8 then h({T[i+1],Rg[i+1],Rg[i]}, (i<4) and HP2 or HP1) end
end
local ring = {HP4,HP4,HP4,HP3,HP4,HP3,HP2}
for i=1,7 do
  h({Rg[i],Rg[i+1],Bt[i]}, ring[i])
  if i<7 then h({Rg[i+1],Bt[i+1],Bt[i]}, (i<3) and HP3 or ((i<5) and HP2 or HP1)) end
end
-- long strand wedges down the sides
local x = 255
while x < 370 do
  local w = rand(26,44); local y0 = rand(380,460); local y1 = rand(760,900)
  h({{x,y0},{x+w,y0+rand(-20,20)},{x+w*rand(0.3,0.7),y1}}, (math.random()<0.45) and HP3 or HP2)
  x = x + w*rand(0.7,1.1)
end
x = 640
while x < 770 do
  local w = rand(26,44); local y0 = rand(400,480); local y1 = rand(760,900)
  h({{x,y0},{x+w,y0+rand(-20,20)},{x+w*rand(0.3,0.7),y1}}, (math.random()<0.6) and HP2 or HP1)
  x = x + w*rand(0.7,1.1)
end
-- restore hem band
work(poly{{398,830},{604,826},{599,805},{403,809}}, {hand="body", tool="filbert 4", pile=O1, coverage=4.5, fill=true, clip=true, angle=0})
work(poly{{402,831},{603,827},{604,835},{400,838}}, {hand="detail", tool="round 3", pile=O3, coverage=4, fill=true, clip=true})

--@ chunk 11
print(wait(2880), drying(700,500), drying(400,600))
local function g(p, pile_, tool) work(poly(p), {hand="body", tool=tool or "filbert 4", pile=pile_, coverage=4.5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}}) end
g({{575,668},{590,690},{640,655},{628,632}},S2)
g({{626,634},{645,652},{670,580},{650,570}},S1)
g({{642,578},{678,570},{692,530},{674,503},{648,508},{636,540}},S1)
g({{676,568},{692,530},{674,503},{690,520},{698,548}},S2)
g({{640,560},{618,548},{626,530},{644,536}},S2)
-- floor grid
FIG = HAIR + poly{{440,800},{560,800},{565,945},{430,945}}
local CLIPG = (SCREEN * rect(96,786,808,240)) - FIG
local CY = pile{{"cerulean blue",2},{"zinc white",2},{"viridian",0.3}}
local b = brush{kind="round", width=2.4}
local vx, vy = 500, 640
for _,y in ipairs({792, 812, 838, 872, 916, 972}) do
  b:load(CY, 0.8)
  b:stroke({{90,y},{500,y+rand(-0.5,0.5)},{910,y}}, {pressure={0.7,0.7}, clip=CLIPG})
end
for k=-7,7 do
  local xb = 500 + k*95
  local t0 = (792-vy)/(1030-vy)
  b:load(CY, 0.8)
  b:stroke({{vx+(xb-vx)*t0, 792},{xb,1030}}, {pressure={0.55,0.85}, clip=CLIPG})
end

--@ chunk 12
print(wait(4320), drying(660,540))
local function g(p, pile_, tool) work(poly(p), {hand="body", tool=tool or "filbert 4", pile=pile_, coverage=5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}}) end
g({{626,634},{645,652},{670,580},{650,570}},S1)
g({{642,578},{678,570},{692,530},{674,503},{648,508},{636,540}},S1)
g({{676,568},{692,530},{674,503},{690,520},{698,548}},S2)
g({{640,560},{618,548},{626,530},{644,536}},S2)
-- floor shadow
local SH = poly{{395,935},{450,918},{560,918},{612,935},{575,955},{430,955}} - poly{{430,895},{570,895},{565,942},{505,942},{500,930},{482,938},{430,940}}
work(SH, {hand="body", tool="filbert 5", pile=pile{{"ultramarine blue",2},{"bone black",1.5},{"viridian",0.3}}, coverage=4, fill=true, clip=true, angle=0})

--@ chunk 13
local function fl(m, p, tool, cov) work(m, {hand="body", tool=tool or "filbert 4", pile=p, coverage=cov or 4.5, fill=true, clip=true, angle=0, length={15,40}}) end
local function dt(m, p, cov) work(m, {hand="detail", tool="round 2.5", pile=p, coverage=cov or 4, fill=true, clip=true}) end
UIP = pile{{"lead white",2},{"cerulean blue",0.6},{"ultramarine ash",0.5}}
UID = pile{{"ultramarine blue",2},{"bone black",1.2},{"viridian",0.3}}
-- header bar
fl(rrect(112,118,888,156,12) * SCREEN, UIP, "filbert 5")
for i=0,8 do local x = 140 + i*rand(26,40); dt(rect(x,131,rand(10,26),10), UID) end
dt(rect(150,131,14,10), O1)
dt(rrect(800,127,822,147,4), O1); dt(rrect(830,127,852,147,4), UID); dt(rrect(860,127,876,147,4), UID)
-- untrusted tag (the Commando's annotation)
local tag = rrect(116,168,452,198,6)
fl(tag, O2, "filbert 4")

--@ chunk 14
print(wait(1440), drying(300,140), drying(300,183))
local function dt(m, p, cov) work(m, {hand="detail", tool="round 2.5", pile=p, coverage=cov or 4, fill=true, clip=true}) end
local UIK = pile{{"bone black",2},{"ultramarine blue",1.5}}
for _,r in ipairs({{142,132,22},{176,132,30},{214,132,14},{236,132,34},{282,132,20},{318,132,26},{354,132,12}}) do dt(rect(r[1],r[2],r[3],8), UIK) end
dt(rect(150,131,12,10), O1)
-- sign-painted letters UNTRUSTED in the red tag
local L = {
 U={{{0,0},{0,13},{2,16},{8,16},{10,13},{10,0}}},
 N={{{0,16},{0,0},{10,16},{10,0}}},
 T={{{0,0},{10,0}},{{5,0},{5,16}}},
 R={{{0,16},{0,0},{8,0},{10,3},{10,6},{8,8},{0,8}},{{5,8},{10,16}}},
 S={{{10,1},{8,0},{2,0},{0,2},{0,6},{2,8},{8,8},{10,10},{10,14},{8,16},{2,16},{0,15}}},
 E={{{10,0},{0,0},{0,16},{10,16}},{{0,8},{7,8}}},
 D={{{0,0},{0,16},{6,16},{10,12},{10,4},{6,0},{0,0}}},
}
local TX = pile{{"zinc white",4},{"lemon chrome",0.15}}
local b = brush{kind="round", width=2.6, point=0.3}
local x0, y0 = 134, 175
for i,ch in ipairs({"U","N","T","R","U","S","T","E","D"}) do
  for _,seg in ipairs(L[ch]) do
    local pts = {}
    for _,p in ipairs(seg) do pts[#pts+1] = {x0 + p[1]*1.1, y0 + p[2]} end
    b:load(TX, 0.85)
    b:stroke(pts, {pressure={0.75,0.75}})
  end
  x0 = x0 + 18
end
-- blinking cursor block after it
dt(rect(x0+6, 175, 9, 16), TX)
-- thinking bubble
local BUB = rrect(682,214,812,262,16) + poly{{700,256},{722,256},{672,292}}
work(BUB, {hand="body", tool="filbert 4", pile=UIP, coverage=4.5, fill=true, clip=true, angle=0, length={15,40}})

--@ chunk 15
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 5", pile=p, coverage=cov or 4, fill=true, clip=true, angle=ang or 0, length={15,40}}) end
local BEV = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.7},{"cerulean blue",0.3}}
local BEV2 = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.35},{"ultramarine blue",0.2}}
-- inner bevel: lower and right sides take more screen light
local ring = SCREEN:grow(14) - SCREEN
fl(ring * rect(0,560,1000,700), BEV, "filbert 4", 4)
fl(ring * rect(0,0,1000,560), BEV2, "filbert 4", 4)
-- desk top catching the screen spill
local DESK = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.5},{"ultramarine ash",0.6}}
fl(rect(0,1108,1000,48), DESK, "filbert 7", 3.5, 0)
local DESK2 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4},{"lead white",0.2}}
fl(rect(0,1156,1000,94), DESK2, "filbert 7", 3.5, 0)
-- port on the bezel
local PORT = pile{{"bone black",3},{"ultramarine blue",0.5}}
fl(rrect(758,1036,826,1066,5), PORT, "filbert 3", 5)

--@ chunk 16
print(wait(1440), drying(740,240), drying(500,1130))
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 4", pile=p, coverage=cov or 4.5, fill=true, clip=true, angle=ang or 0, length={10,30}}) end
local function dt(m, p, cov) work(m, {hand="detail", tool="round 2.5", pile=p, coverage=cov or 4, fill=true, clip=true}) end
local UIK = pile{{"bone black",2},{"ultramarine blue",1.5}}
dt(rrect(716,231,730,245,4), UIK); dt(rrect(740,231,754,245,4), UIK); dt(rrect(764,231,778,245,4), UIK)
-- cable
local CAB = pile{{"bone black",2.5},{"ultramarine blue",0.8},{"burnt sienna",0.3}}
local cpts = {{792,1104},{795,1150},{826,1198},{892,1232},{960,1248},{1010,1256}}
fl(ribbon(cpts, 22), CAB, "filbert 5", 5, 0.6)
-- plug housing
local MET = pile{{"bone black",1.5},{"lead white",0.8},{"ultramarine ash",0.6}}
local MET2 = pile{{"bone black",2},{"lead white",0.3},{"ultramarine ash",0.5}}
fl(poly{{772,1060},{812,1060},{810,1100},{774,1100}}, MET2)
fl(poly{{772,1060},{786,1060},{786,1100},{774,1100}}, MET)
fl(poly{{774,1098},{810,1098},{808,1110},{776,1110}}, O1)
-- power LED, amber (emergency power)
dt(ellipse(890,1062,6,6), pile{{"cadmium yellow",1},{"Mars orange",1},{"zinc white",0.6}})

--@ chunk 17
SCN = pile{{"ultramarine blue",1.5},{"bone black",1.5},{"viridian",0.2}, medium=0.5}
sb = brush{kind="round", width=1.4}
local clipm = SCREEN * rect(96,940,260,90)
for y=944,1020,6 do
  sb:load(SCN, 0.5)
  sb:stroke({{96,y},{360,y}}, {pressure={0.35,0.35}, clip=clipm})
end

--@ chunk 18
local clipm = SCREEN * rect(360,850,560,90)
for y=854,938,6 do
  sb:load(SCN, 0.4)
  sb:stroke({{360,y},{920,y}}, {pressure={0.3,0.3}, clip=clipm})
end

--@ chunk 19
local EXC = HAIR:grow(2) + rect(395,800,220,160) + rrect(110,116,890,158,12) + rrect(114,166,454,200,6) + rrect(680,212,814,264,16) + poly{{700,256},{722,256},{672,292}}
local clipm = (SCREEN * rect(0,108,1000,832)) - EXC
for y=112,938,6 do
  sb:load(SCN, 0.5)
  sb:stroke({{96,y},{904,y}}, {pressure={0.35,0.35}, clip=clipm})
end

--@ chunk 20
print(drying(60,600), drying(500,1200), drying(800,1180))
local function fl(m, p, tool, cov, ang, extra) local o={hand="body", tool=tool or "filbert 6", pile=p, coverage=cov or 4, fill=true, clip=true, angle=ang or 0, length={20,50}}
  if extra then for k,v in pairs(extra) do o[k]=v end end; work(m, o) end
local CABM = ribbon({{792,1104},{795,1150},{826,1198},{892,1232},{960,1248},{1010,1256}}, 24) + rect(768,1056,48,58)
local KEEP = SCREEN:grow(14) + rrect(756,1034,828,1068,5) + ellipse(890,1062,9,9) + CABM
local BZ = pile{{"bone black",2.5},{"ultramarine ash",1},{"lead white",0.12}}
fl((BEZEL - KEEP), BZ, "filbert 6", 4, 0)
-- desk: dark, with the screen's reflection pooled under it
local DK = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.4}}
fl(rect(0,1094,1000,160) - CABM, DK, "filbert 7", 4, 0)

--@ chunk 21
print(wait(2880), drying(500,1200), drying(800,1180))
local cp = {{792,1104},{795,1150},{826,1198},{892,1232},{960,1248},{1010,1256}}
local CABM = ribbon(cp, 24) + rect(768,1056,48,58)
local REF = pile{{"ultramarine blue",1.5},{"bone black",1.2},{"cobalt blue",0.5},{"lead white",0.45}}
work(poly{{120,1096},{880,1096},{840,1128},{160,1128}} - CABM, {hand="body", tool="filbert 5", pile=REF, coverage=3, fill=true, edge="soft", angle=0, length={30,80}})
-- cable body restated slightly lifted, then a cool rim along its upper side
local CAB2 = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.25}}
work(ribbon(cp, 20), {hand="body", tool="filbert 4", pile=CAB2, coverage=4, fill=true, clip=true, angle=0.6, length={15,40}})
local RIM = pile{{"cerulean blue",1},{"ultramarine ash",1},{"lead white",1.5}}
local b = brush{kind="round", width=2.2, point=0.4}
b:load(RIM, 0.7)
b:stroke({{784,1106},{786,1150},{818,1200},{886,1236},{958,1250},{1004,1258}}, {pressure={0.5,0.7}, ramps={0.1,0.2}})
b:load(RIM, 0.7)
b:stroke({{775,1062},{775,1098}}, {pressure={0.6,0.6}})

--@ chunk 22
local cp = {{792,1104},{795,1150},{826,1198},{892,1232},{960,1248},{1010,1256}}
local CABM = ribbon(cp, 26) + rect(766,1056,52,60)
blend(poly{{100,1094},{900,1094},{860,1140},{140,1140}} - CABM, {angle=0, tool="badger 14"})

--@ chunk 23
print(drying(500,620), drying(425,720), drying(300,300))
local function g(p, pile_) work(poly(p), {hand="body", tool="filbert 4", pile=pile_, coverage=5, fill=true, clip=true, angle=rand(0,3.1), length={10,30}}) end
local S5 = pile{{"lead white",3},{"yellow ochre",0.3},{"vermilion",0.3},{"rose madder",0.2},{"ultramarine ash",0.4}}
g({{480,606},{520,606},{524,652},{476,652}}, S5)
g({{482,606},{520,606},{500,625}}, S4)
-- inner side of the lowered forearm and hand in shade
g({{432,694},{445,694},{430,765},{421,763}}, S3)
g({{420,762},{432,762},{436,790},{426,797}}, S3)
-- backlit rim on the hair silhouette, broken, mostly upper-left
local RIMP = pile{{"cerulean blue",1},{"cobalt blue",1},{"lead white",1.6}}
local band = HAIR - HAIR:shrink(4)
local zone = poly{{230,200},{560,195},{430,320},{300,600},{230,860}}
work(band * zone, {hand="detail", tool="round 2", pile=RIMP, coverage=3, fill=true, clip=true})
local zone2 = poly{{600,215},{780,300},{790,700},{740,700},{700,330}}
work(band * zone2, {hand="detail", tool="round 2", pile=pile{{"ultramarine blue",1},{"cobalt blue",1},{"lead white",0.9}}, coverage=2.5, fill=true, clip=true})

--@ chunk 24
local BEVM = pile{{"bone black",1.2},{"ultramarine ash",1},{"lead white",0.5},{"cerulean blue",0.25}}
local ring = SCREEN:grow(14) - SCREEN
work(ring - rect(756,1020,72,60), {hand="body", tool="filbert 4", pile=BEVM, coverage=4.5, fill=true, clip=true, angle=0, length={20,50}})
-- brand on the bezel: MIRIAD, raised gray letters
local L = {
 M={{{0,14},{0,0},{5,8},{10,0},{10,14}}},
 I={{{5,0},{5,14}},{{2,0},{8,0}},{{2,14},{8,14}}},
 R={{{0,14},{0,0},{8,0},{10,2},{10,5},{8,7},{0,7}},{{5,7},{10,14}}},
 A={{{0,14},{5,0},{10,14}},{{2,9},{8,9}}},
 D={{{0,0},{0,14},{6,14},{10,10},{10,4},{6,0},{0,0}}},
}
local LG = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.6}}
local b = brush{kind="round", width=2.0, point=0.3}
local x0, y0 = 96, 1050
for _,ch in ipairs({"M","I","R","I","A","D"}) do
  for _,seg in ipairs(L[ch]) do
    local pts = {}
    for _,p in ipairs(seg) do pts[#pts+1] = {x0 + p[1], y0 + p[2]} end
    b:load(LG, 0.8); b:stroke(pts, {pressure={0.7,0.7}})
  end
  x0 = x0 + 16
end

--@ chunk 25
print(wait(2880), drying(95,600))
local BEVD = pile{{"bone black",1.8},{"ultramarine ash",1},{"lead white",0.28},{"cerulean blue",0.2}}
local ring = SCREEN:grow(14) - SCREEN
work(ring - rect(756,1020,72,60), {hand="body", tool="filbert 4", pile=BEVD, coverage=4.5, fill=true, clip=true, angle=0, length={20,50}})
-- a faint lit lip right at the glass edge
local LIP = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.6},{"cerulean blue",0.4}}
work((SCREEN:grow(3) - SCREEN) - rect(756,1020,72,60), {hand="detail", tool="round 2", pile=LIP, coverage=3, fill=true, clip=true})

--@ chunk 26
print(drying(400,183), drying(200,137))
local L = {
 D={{{0,0},{0,16},{6,16},{10,12},{10,4},{6,0},{0,0}}},
 O={{{3,0},{7,0},{10,3},{10,13},{7,16},{3,16},{0,13},{0,3},{3,0}}},
 N={{{0,16},{0,0},{10,16},{10,0}}},
 T={{{0,0},{10,0}},{{5,0},{5,16}}},
 B={{{0,0},{0,16},{8,16},{10,14},{10,10},{8,8},{0,8}},{{0,0},{7,0},{9,2},{9,6},{7,8}}},
 E={{{10,0},{0,0},{0,16},{10,16}},{{0,8},{7,8}}},
 Y={{{0,0},{5,8},{10,0}},{{5,8},{5,16}}},
}
local TY = pile{{"zinc white",3},{"lemon chrome",0.5}}
local b = brush{kind="round", width=2.0, point=0.3}
local x0, y0, s = 326, 177, 0.72
for _,ch in ipairs({"D","O"," ","N","O","T"," ","O","B","E","Y"}) do
  if L[ch] then
    for _,seg in ipairs(L[ch]) do
      local pts = {}
      for _,p in ipairs(seg) do pts[#pts+1] = {x0 + p[1]*s, y0 + p[2]*s} end
      b:load(TY, 0.85); b:stroke(pts, {pressure={0.6,0.6}})
    end
    x0 = x0 + 10.5
  else x0 = x0 + 6 end
end
-- crisp header glyph dashes
local UIK = pile{{"bone black",2},{"ultramarine blue",1.5}}
for _,r in ipairs({{176,133,30},{214,133,14},{236,133,34},{282,133,20},{318,133,26},{354,133,12}}) do
  work(rect(r[1],r[2],r[3],7), {hand="detail", tool="round 2", pile=UIK, coverage=4, fill=true, clip=true}) end
-- signal tear: chromatic glitch dashes in the bg
local CYG = pile{{"cerulean blue",1.5},{"zinc white",2},{"viridian",0.3}}
local MAG = pile{{"magenta",1},{"zinc white",1},{"cobalt violet",0.5}}
local g = brush{kind="flat", width=2.2}
for _,s2 in ipairs({{104,232,566},{132,196,571},{760,898,566},{790,860,571},{120,170,608}}) do
  g:load(CYG,0.7); g:stroke({{s2[1],s2[3]},{s2[2],s2[3]}}, {pressure={0.6,0.6}, orient="along", clip=SCREEN-HAIR})
  g:load(MAG,0.6); g:stroke({{s2[1]+6,s2[3]+3},{s2[2]+6,s2[3]+3}}, {pressure={0.5,0.5}, orient="along", clip=SCREEN-HAIR})
end

--@ chunk 27
local band = BEZEL - BEZEL:shrink(4)
local zone = poly{{0,0},{1000,0},{1000,60},{70,140},{60,1100},{0,1100}}
work(band * zone, {hand="detail", tool="round 2", pile=pile{{"bone black",1.2},{"ultramarine ash",1},{"lead white",0.45}}, coverage=3, fill=true, clip=true})
-- lower edge of the bezel catches the desk's reflected glow
local zone2 = rect(80,1080,840,14)
work(band * zone2, {hand="detail", tool="round 2", pile=pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.5}}, coverage=3, fill=true, clip=true})
