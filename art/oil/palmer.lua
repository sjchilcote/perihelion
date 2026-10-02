-- easel session "palmer": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=0.62, linen={18,16}, seed=9191, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"bone brown",3},{"burnt sienna",1.5},{"lead white",1},{"ultramarine blue",0.3}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
P = {}
P.helm = poly({{455,215},{500,200},{548,212},{572,250},{578,300},{570,348},{548,372},{500,382},{452,372},{430,348},{422,300},{428,250}}, true)
P.gorget = poly({{440,360},{560,360},{590,400},{410,400}}, true)
P.lpaul = poly({{410,390},{360,388},{306,410},{276,452},{272,500},{300,512},{350,490},{400,470},{420,430}}, true)
P.rpaul = poly({{590,390},{640,388},{694,410},{724,452},{728,500},{700,512},{650,490},{600,470},{580,430}}, true)
P.chest = poly({{405,400},{595,400},{618,470},{612,560},{590,640},{410,640},{388,560},{382,470}}, true)
P.waist = poly({{410,630},{590,630},{600,700},{400,700}}, true)
P.larm = ribbon({{318,500},{306,580},{300,650},{298,720}}, {62,54,50,48})
P.lgaunt = poly({{270,710},{326,706},{338,760},{330,812},{300,826},{272,808},{262,760}}, true)
P.rarm = ribbon({{684,500},{700,570},{708,630},{712,680}}, {62,54,50,48})
P.rgaunt = poly({{686,664},{746,660},{758,700},{752,740},{700,746},{684,712}}, true)
P.lthigh = ribbon({{450,720},{440,840},{432,980}}, {96,88,74})
P.rthigh = ribbon({{550,720},{562,840},{572,980}}, {96,88,74})
P.lknee = ellipse(430, 1000, 44, 40)
P.rknee = ellipse(574, 1000, 44, 40)
P.lgreave = ribbon({{430,1030},{424,1200},{420,1380}}, {70,66,54})
P.rgreave = ribbon({{576,1030},{586,1200},{592,1380}}, {70,66,54})
P.lfoot = poly({{372,1370},{452,1366},{462,1420},{456,1452},{360,1456},{352,1420}}, true)
P.rfoot = poly({{560,1370},{640,1366},{664,1418},{670,1452},{566,1456},{556,1420}}, true)
P.staff = ribbon({{728,240},{730,700},{734,1100},{738,1452}}, {22,26,28,30})
P.muzzle = poly({{712,180},{746,180},{752,250},{706,250}})
P.tabard = poly({{420,520},{580,520},{592,640},{600,700},{604,1100},{576,1130},{500,1112},{424,1130},{396,1100},{400,700},{408,640}}, true)
P.all = P.helm + P.gorget + P.lpaul + P.rpaul + P.chest + P.waist + P.larm + P.lgaunt + P.rarm + P.rgaunt + P.lthigh + P.rthigh + P.lknee + P.rknee + P.lgreave + P.rgreave + P.lfoot + P.rfoot + P.tabard
local STEEL0 = pile{{"bone black",2},{"ultramarine blue",0.7},{"burnt sienna",0.5}}
work(P.all, {hand="body", pile=STEEL0, coverage=3.5, fill=true, tool="filbert 10", angle=math.pi/2, clip=P.all:grow(1), edge="found"})
local ST = pile{{"bone black",1.5},{"burnt sienna",1},{"bone brown",0.8}}
work(P.staff + P.muzzle, {hand="body", pile=ST, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=(P.staff+P.muzzle):grow(1), edge="found"})

--@ chunk 3
local fig = (P.all + P.staff + P.muzzle):grow(1)
local floor = below(function(x) return 1440 - 0.02*(x-500) end)
local bg = everywhere() - floor - fig
local glow = ellipse(260, 520, 420, 620):roughen(30,150,2)
local B0 = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.6}}
local B1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"raw sienna",0.4}}
work(bg - glow, {hand="broad", pile=B0, coverage=3, fill=true, angle=math.pi/2 + 0.2, clip=bg})
work(bg * glow, {hand="broad", pile=B1, coverage=3, fill=true, angle=math.pi/2 + 0.2, clip=bg})
local FL = pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.5}}
work(floor - fig, {hand="broad", pile=FL, coverage=3, fill=true, angle=0, clip=floor - fig})

--@ chunk 4
PARTS = {
  {P.helm, 500, 78, math.pi/2},
  {P.gorget, 500, 90, 0},
  {P.lpaul, 345, 75, 0.4},
  {P.rpaul, 655, 75, -0.4},
  {P.chest, 500, 118, math.pi/2},
  {P.larm, 305, 30, math.pi/2},
  {P.lgaunt, 300, 38, math.pi/2},
  {P.rarm, 700, 30, math.pi/2},
  {P.rgaunt, 720, 36, 0},
  {P.lthigh, 442, 48, math.pi/2},
  {P.rthigh, 560, 48, math.pi/2},
  {P.lknee, 430, 44, 0},
  {P.rknee, 574, 44, 0},
  {P.lgreave, 425, 35, math.pi/2},
  {P.rgreave, 584, 35, math.pi/2},
  {P.lfoot, 408, 52, 0},
  {P.rfoot, 612, 54, 0},
}
STM = pile{{"bone black",1},{"lead white",0.9},{"ultramarine ash",0.5},{"burnt sienna",0.3}}
STD = pile{{"bone black",1.5},{"lead white",0.3},{"ultramarine blue",0.4},{"burnt sienna",0.4}}
function zone(m, cx, hw, k) return m * mask(function(x,y) return x < cx + k*hw and 1 or 0 end):soften(3) end
for _,p in ipairs(PARTS) do
  local m, cx, hw, ang = p[1], p[2], p[3], p[4]
  local tool = hw > 60 and "filbert 8" or "filbert 5"
  work(zone(m, cx, hw, 0.35) - P.tabard, {hand="body", pile=STD, coverage=2.5, fill=true, tool=tool, angle=ang, clip=m - P.tabard, length={12,40}})
  work(zone(m, cx, hw, -0.15) - P.tabard, {hand="body", pile=STM, coverage=2.5, fill=true, tool=tool, angle=ang, clip=m - P.tabard, length={12,40}})
end

--@ chunk 5
local fig = (P.all + P.staff + P.muzzle):grow(3)
local floor = below(function(x) return 1440 - 0.02*(x-500) end)
local glow = ellipse(260, 520, 420, 620):roughen(30,150,2)
local band = (glow:grow(60) - glow:shrink(60)) - fig - floor:grow(5)
blend(band, {angle=math.pi/2+0.2, tool={kind="badger", width=30}, pressure={0.35,0.55}})
print(wait(3*24*60))

--@ chunk 6
local D = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
local M = pile{{"bone black",1},{"lead white",0.6},{"yellow ochre",0.2},{"ultramarine blue",0.25}}
local L = pile{{"lead white",1.5},{"bone black",0.35},{"yellow ochre",0.3}}
for _,p in ipairs(PARTS) do
  local m, cx, hw, ang = p[1], p[2], p[3], p[4]
  local mm = m - P.tabard
  local tool = hw > 60 and "filbert 8" or "filbert 5"
  work(mm, {hand="body", pile=D, coverage=3, fill=true, tool=tool, angle=ang, clip=mm, length={15,45}})
  work(zone(mm, cx, hw, 0.0), {hand="body", pile=M, coverage=2.5, fill=true, tool=tool, angle=ang, clip=mm, length={12,40}})
  work(zone(mm, cx, hw, -0.55), {hand="body", pile=L, coverage=2, tool=(hw > 60 and "filbert 6" or "filbert 4"), angle=ang, clip=mm, length={10,30}})
end
local C0 = pile{{"rose madder",1.5},{"bone black",0.6},{"Mars red",0.6}}
local C1 = pile{{"Mars red",1.5},{"rose madder",1},{"vermilion",0.3}}
local C2 = pile{{"vermilion",1.5},{"cadmium red",0.6},{"lead white",0.25}}
work(P.tabard, {hand="body", pile=C0, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2, clip=P.tabard})
work(zone(P.tabard, 500, 100, 0.1), {hand="body", pile=C1, coverage=2.5, fill=true, tool="filbert 8", angle=math.pi/2, clip=P.tabard})
work(zone(P.tabard, 500, 100, -0.6), {hand="body", pile=C2, coverage=2, tool="filbert 6", angle=math.pi/2, clip=P.tabard})

--@ chunk 7
print(wait(3*24*60)); print(drying(500,700), drying(300,600))
local lip = brush{kind="round", width=5, point=0.8}
local K = pile{{"bone black",2},{"ultramarine blue",0.5}}
local HI = pile{{"lead white",2},{"yellow ochre",0.35}}
local function line(pts, w, p) lip:reload(p, 0.7); lip:stroke(pts, {pressure={lip:pressure_for(w), lip:pressure_for(w*0.7)}, swell={0.3,1,1,0.4}}) end
-- tabard folds: deep troughs and lit ridges
local CD = pile{{"rose madder",1.5},{"bone black",0.8},{"ultramarine blue",0.2}}
local CH = pile{{"vermilion",1.2},{"cadmium red",0.6},{"lead white",0.35}}
local fb = brush{kind="filbert", width=9}
for _,x in ipairs({448, 486, 528, 566}) do
  fb:reload(CD, 0.7); fb:stroke({{x,560},{x-3,800},{x+2,1000},{x-4,1110}}, {pressure={0.5,0.75}, clip=P.tabard})
end
for _,x in ipairs({432, 468, 508}) do
  fb:reload(CH, 0.5); fb:stroke({{x,580},{x-2,800},{x+2,1000}}, {pressure={0.3,0.45}, clip=P.tabard})
end
-- the bone cross on the breast of the tabard
local bone = pile{{"lead white",2},{"yellow ochre",0.7},{"raw sienna",0.2}}
CR = rect(488, 560, 22, 150) + rect(450, 600, 98, 20)
work(CR, {hand="detail", pile=bone, coverage=3.5, fill=true, clip=CR})
-- helm: visor slit and one cold optic
local slit = poly({{440,290},{560,290},{566,304},{434,304}})
work(slit, {hand="detail", pile=K, coverage=5, fill=true, clip=slit})
-- plate lines: lames on pauldrons, couters, cuisses, poleyns, greave ridges, gorget
line({{288,456},{330,440},{380,438},{410,446}}, 2.2, K)
line({{282,482},{320,470},{370,468},{404,478}}, 2.2, K)
line({{712,456},{670,440},{620,438},{590,446}}, 2.2, K)
line({{718,482},{680,470},{630,468},{596,478}}, 2.2, K)
line({{415,398},{500,404},{585,398}}, 2.2, K)
line({{424,360},{500,368},{576,360}}, 2, K)
line({{404,700},{500,706},{596,700}}, 2.5, K)
for _,y in ipairs({600, 640}) do line({{278,y},{306,y+4},{334,y}}, 2, K); line({{678,y},{704,y+4},{732,y}}, 2, K) end
for _,y in ipairs({800, 880}) do line({{400,y},{440,y+6},{482,y}}, 2.2, K); line({{518,y},{560,y+6},{606,y}}, 2.2, K) end
line({{394,1006},{430,1030},{468,1006}}, 2.4, K); line({{538,1006},{574,1030},{612,1006}}, 2.4, K)
line({{360,1408},{410,1400},{460,1408}}, 2, K); line({{560,1408},{612,1400},{664,1408}}, 2, K)
-- highlights on the lit edges (light from the left)
line({{436,240},{428,290},{432,340}}, 2.6, HI)
line({{280,446},{300,420},{340,398}}, 2.6, HI)
line({{600,420},{640,398},{690,412}}, 2, HI)
line({{390,420},{386,480},{392,540}}, 2.4, HI)
line({{282,520},{278,600},{276,700}}, 2.2, HI)
line({{405,740},{398,860},{396,960}}, 2.6, HI)
line({{520,740},{518,860},{528,960}}, 2, HI)
line({{390,995},{405,975},{430,968}}, 2.4, HI)
line({{536,995},{552,975},{574,968}}, 2, HI)
line({{396,1060},{392,1220},{390,1360}}, 2.4, HI)
line({{554,1060},{556,1220},{562,1360}}, 2, HI)
line({{356,1420},{372,1374},{420,1368}}, 2, HI)
line({{684,520},{680,600},{682,660}}, 2, HI)

--@ chunk 8
print(wait(2*24*60))
local T = P.tabard - CR:grow(1)
local C0 = pile{{"rose madder",1.5},{"bone black",0.7},{"Mars red",0.5}}
local C1 = pile{{"Mars red",1.2},{"rose madder",1.2},{"bone black",0.15}}
local C2 = pile{{"vermilion",1},{"Mars red",0.8},{"lead white",0.2}}
-- folds as vertical tapered bands, wet into wet: dark troughs, mid, lit ridges toward the light
local folds = {{410,"L"},{430,"M"},{450,"D"},{470,"L"},{490,"M"},{512,"D"},{534,"M"},{552,"D"},{574,"M"},{594,"D"}}
work(T, {hand="body", pile=C0, coverage=3, fill=true, tool="filbert 8", angle=math.pi/2, clip=T})
for _,f in ipairs(folds) do
  local x = f[1]
  local band = T * poly({{x-10,520},{x+10,520},{x+14+(x-500)*0.05,1130},{x-14+(x-500)*0.05,1130}})
  if f[2] == "L" then work(band, {hand="body", pile=C2, coverage=2.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=T, length={40,120}})
  elseif f[2] == "M" then work(band, {hand="body", pile=C1, coverage=2.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=T, length={40,120}}) end
end
-- the lightning cannon, held like a staff: heavier barrel, coil rings, a cold muzzle
CAN = ribbon({{730,190},{732,700},{736,1100},{740,1450}}, {34,34,30,26})
local ST0 = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
work(CAN - P.rgaunt, {hand="body", pile=ST0, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=CAN - P.rgaunt})

--@ chunk 9
print(wait(3*24*60)); print(drying(500,800), drying(730,800))
local T = P.tabard - CR:grow(1)
local CS = pile{{"rose madder",1.2},{"bone black",1},{"ultramarine blue",0.2}}
local shade = T * mask(function(x,y) return x > 548 and 1 or 0 end):roughen(6,60,3)
work(shade, {hand="body", pile=CS, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, clip=T, length={40,140}})
local r = brush{kind="round", width=6, point=0.8}
for _,f in ipairs({{452,560,6},{512,540,5},{470,700,4},{540,640,5},{430,760,4}}) do
  local x, y0, w = f[1], f[2], f[3]
  r:reload(CS, 0.8); r:stroke({{x,y0},{x-2,y0+200},{x+3,y0+380},{x+(x-500)*0.06,1120}}, {pressure={r:pressure_for(1), r:pressure_for(w)}, clip=T})
end
local CH = pile{{"vermilion",1.2},{"cadmium red",0.8},{"lead white",0.45}}
for _,f in ipairs({{440,600},{462,820},{498,620},{420,900}}) do
  r:reload(CH, 0.6); r:stroke({{f[1],f[2]},{f[1]-1,f[2]+140},{f[1]+2,f[2]+260}}, {pressure={r:pressure_for(3), r:pressure_for(0.8)}, clip=T})
end
-- cold optic in the visor, and its spill
local CO = pile{{"zinc white",2},{"cerulean blue",1}}
local CB = pile{{"cerulean blue",1},{"cobalt blue",1},{"zinc white",0.5}}
r:reload(CB, 0.7); r:stroke({{506,297},{536,297}}, {pressure={r:pressure_for(5), r:pressure_for(5)}})
r:reload(CO, 0.8); r:touch(520, 297, {pressure=r:pressure_for(3.5)})
-- cannon: lit edge, coil rings, cold muzzle
local HI = pile{{"lead white",2},{"yellow ochre",0.35}}
local cb = brush{kind="round", width=4, point=0.6}
cb:reload(HI, 0.6); cb:stroke({{716,200},{717,660}}, {pressure={cb:pressure_for(1.8), cb:pressure_for(1.4)}})
cb:reload(HI, 0.6); cb:stroke({{720,760},{722,1440}}, {pressure={cb:pressure_for(1.6), cb:pressure_for(0.6)}})
local BR = pile{{"burnt sienna",1},{"Mars orange",0.8},{"yellow ochre",0.6}}
for y=230,560,22 do cb:reload(BR, 0.6); cb:stroke({{714,y},{730,y+4},{746,y}}, {pressure={cb:pressure_for(2.2), cb:pressure_for(1.6)}}) end
cb:reload(CB, 0.7); cb:stroke({{716,190},{744,190}}, {pressure={cb:pressure_for(4), cb:pressure_for(4)}})
-- right gauntlet back over the barrel, closed round it
local G = pile{{"bone black",1},{"lead white",0.6},{"yellow ochre",0.2},{"ultramarine blue",0.25}}
local g = poly({{690,666},{760,662},{770,700},{764,742},{698,748},{684,712}}, true)
work(g, {hand="detail", pile=G, coverage=4, fill=true, clip=g})
for _,y in ipairs({680, 700, 720}) do cb:reload(pile{{"bone black",2}}, 0.6); cb:stroke({{694,y},{730,y+2},{762,y}}, {pressure={cb:pressure_for(1.4), cb:pressure_for(1.4)}, clip=g}) end
cb:reload(HI, 0.6); cb:stroke({{690,672},{688,700},{692,736}}, {pressure={cb:pressure_for(1.8), cb:pressure_for(0.8)}})

--@ chunk 10
local G = pile{{"bone black",1.5},{"lead white",0.35},{"yellow ochre",0.15},{"ultramarine blue",0.3}}
local g = poly({{690,666},{760,662},{770,700},{764,742},{698,748},{684,712}}, true)
work(g, {hand="detail", pile=G, coverage=5, fill=true, clip=g, load=1})
-- palm frond etched on the left pauldron, in bone-gold
local et = brush{kind="round", width=3, point=0.9}
local GOLD = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.3}}
local stem = {{300,492},{318,462},{340,438},{366,420}}
et:reload(GOLD, 0.6); et:stroke(stem, {pressure={et:pressure_for(2), et:pressure_for(0.8)}})
for i=1,7 do
  local t = i/8
  local x = lerp(300, 366, t); local y = lerp(492, 420, t)
  local l = 18*(1-t*0.5)
  et:reload(GOLD, 0.5); et:stroke({{x,y},{x - l*0.3, y - l*0.9}}, {pressure={et:pressure_for(1.2), 0}})
  et:reload(GOLD, 0.5); et:stroke({{x,y},{x + l*0.9, y + l*0.2}}, {pressure={et:pressure_for(1.2), 0}})
end
-- rosary wound round the left gauntlet, the crucifix hanging below
local bead = brush{kind="round", width=5, point=0}
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
for k=0,1 do
  for i=0,9 do
    local t = i/9
    local x = lerp(268, 334, t); local y = 744 + k*22 + 10*math.sin(t*math.pi)
    bead:reload(BB, 0.6); bead:touch(x, y, {pressure=0.7})
  end
end
for i=1,9 do bead:reload(BB, 0.6); bead:touch(286 + 2*math.sin(i*0.8), 790 + i*7, {pressure=0.7}) end
local cr = brush{kind="round", width=4, point=0.4}
cr:reload(BB, 0.8); cr:stroke({{287,856},{287,888}}, {pressure={cr:pressure_for(3), cr:pressure_for(3)}})
cr:reload(BB, 0.8); cr:stroke({{277,866},{297,866}}, {pressure={cr:pressure_for(3), cr:pressure_for(3)}})
for k=0,1 do for i=0,9,2 do local t=i/9; bead:reload(BH, 0.4); bead:touch(lerp(268,334,t)-1.2, 744 + k*22 + 10*math.sin(t*math.pi)-1.5, {pressure=0.15}) end end
cr:reload(BH, 0.5); cr:stroke({{285,858},{285,886}}, {pressure={cr:pressure_for(0.8), cr:pressure_for(0.8)}})

--@ chunk 11
print(wait(2*24*60))
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
local bead = brush{kind="round", width=9, point=0}
print(bead:mark_width(0.8))
for k=0,1 do
  for i=0,6 do
    local t = i/6
    bead:reload(BB, 0.7); bead:touch(lerp(272,330,t), 748 + k*24 + 9*math.sin(t*math.pi), {pressure=0.8})
  end
end
for i=1,8 do bead:reload(BB, 0.7); bead:touch(290 + 2*math.sin(i*0.8), 800 + i*10, {pressure=0.7}) end
local cr = brush{kind="round", width=6, point=0.3}
cr:reload(BB, 0.9); cr:stroke({{291,888},{291,930}}, {pressure={cr:pressure_for(5), cr:pressure_for(5)}})
cr:reload(BB, 0.9); cr:stroke({{278,902},{304,902}}, {pressure={cr:pressure_for(5), cr:pressure_for(5)}})
local h = brush{kind="round", width=3, point=0.8}
for k=0,1 do for i=0,6,2 do local t=i/6; h:reload(BH, 0.5); h:touch(lerp(272,330,t)-2, 746 + k*24 + 9*math.sin(t*math.pi), {pressure=0.35}) end end
h:reload(BH, 0.5); h:stroke({{288,890},{288,928}}, {pressure={h:pressure_for(1.2), h:pressure_for(1)}})
-- couters (elbows): domed plates with a highlight
local D = pile{{"bone black",1.4},{"lead white",0.4},{"ultramarine blue",0.3},{"yellow ochre",0.1}}
local HI = pile{{"lead white",2},{"yellow ochre",0.35}}
for _,c in ipairs({{304,620,1},{704,622,0.5}}) do
  local e = ellipse(c[1], c[2], 36, 26)
  work(e, {hand="detail", pile=D, coverage=4, fill=true, clip=e})
  local arc = {} for i=0,10 do local a = math.pi*(0.85 + 0.75*i/10); arc[#arc+1] = {c[1] + 33*math.cos(a), c[2] + 23*math.sin(a)} end
  h:reload(HI, 0.6); h:stroke(arc, {pressure={h:pressure_for(0.8), h:pressure_for(2.6*c[3])}})
end
-- floor: the figure's shadow cast away from the light, to the right
local fig = (P.all + CAN):grow(1)
local floorM = below(function(x) return 1440 - 0.02*(x-500) end)
local shd = poly({{360,1452},{680,1450},{1010,1520},{1010,1600},{700,1560},{420,1470}}, true) * floorM - fig
work(shd, {hand="body", pile=pile{{"bone black",1.5},{"bone brown",1}}, coverage=3, fill=true, tool="filbert 10", angle=0.15, clip=shd, edge="soft"})
local lit = poly({{-10,1450},{360,1450},{340,1612},{-10,1612}}, true):soften(20) * floorM - fig
work(lit, {hand="body", pile=pile{{"burnt sienna",1.5},{"raw sienna",1},{"yellow ochre",0.4}}, coverage=2, tool="filbert 10", angle=0, clip=floorM - fig, edge="soft"})

--@ chunk 12
print(wait(2*24*60))
local SD = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.7}}
local extra = {
  {ellipse(304,620,36,26), 304, 36, 0},
  {ellipse(704,622,36,26), 704, 36, 0},
  {poly({{690,666},{760,662},{770,700},{764,742},{698,748},{684,712}}, true) - CAN, 726, 40, 0},
}
local list = {}
for _,p in ipairs(PARTS) do list[#list+1] = p end
for _,p in ipairs(extra) do list[#list+1] = p end
for _,p in ipairs(list) do
  local m, cx, hw, ang = p[1], p[2], p[3], p[4]
  local mm = (m - P.tabard - CR):shrink(1.5)
  local sh = mm * mask(function(x,y) return x > cx + 0.3*hw and 1 or 0 end):roughen(3, 20, 7)
  work(sh, {hand="body", pile=SD, coverage=3.5, fill=true, tool=(hw > 60 and "filbert 6" or "filbert 4"), angle=ang, clip=mm, length={12,40}, edge="soft"})
end
local CS = pile{{"rose madder",1},{"bone black",1.2},{"ultramarine blue",0.2}}
local T = P.tabard - CR:grow(1)
local tsh = T * mask(function(x,y) return x > 566 and 1 or 0 end):roughen(4,40,9)
work(tsh, {hand="body", pile=CS, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=T, length={40,120}, edge="soft"})
local floorM = below(function(x) return 1440 - 0.02*(x-500) end)
blend(rect(0,1440,420,173) * floorM - (P.all):grow(2), {angle=0, tool={kind="badger", width=24}, pressure={0.3,0.5}})

--@ chunk 13
local floorM = below(function(x) return 1440 - 0.02*(x-500) end)
local fig = (P.all + CAN):grow(1)
local shd = poly({{360,1452},{680,1450},{1010,1520},{1010,1600},{700,1560},{420,1470}}, true)
local fl = floorM - fig - shd:shrink(2)
work(fl * rect(0,1430,1000,90), {hand="body", pile=pile{{"burnt sienna",1.5},{"raw sienna",0.8},{"bone brown",0.6}}, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=fl})
work(fl * rect(0,1515,1000,100), {hand="body", pile=pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.3}}, coverage=3.5, fill=true, tool="filbert 12", angle=0, clip=fl})
local D = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5},{"lead white",0.1}}
local g = poly({{690,666},{760,662},{770,700},{764,742},{698,748},{684,712}}, true) - CAN
local c1, c2 = ellipse(304,620,36,26), ellipse(704,622,36,26)
work(g + c2, {hand="detail", pile=D, coverage=5, fill=true, clip=g + c2, load=1})
work(c1 * mask(function(x,y) return x > 300 and 1 or 0 end), {hand="detail", pile=D, coverage=5, fill=true, clip=c1, load=1})

--@ chunk 14
print(wait(2*24*60))
local h = brush{kind="round", width=4, point=0.8}
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.2}}
local RF = pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone brown",0.6}}
local function s(pts, w, p, w2) h:reload(p, 0.7); h:stroke(pts, {pressure={h:pressure_for(w), h:pressure_for(w2 or w*0.4)}, swell={0.3,1,1,0.3}}) end
-- hot speculars on the lit planes
s({{448,232},{442,256}}, 3.2, HOT)
s({{300,416},{318,404}}, 3, HOT)
s({{394,430},{392,470}}, 3, HOT)
s({{404,760},{400,800}}, 3, HOT)
s({{394,1080},{392,1130}}, 3, HOT)
s({{280,560},{279,590}}, 2.6, HOT)
s({{370,1380},{396,1372}}, 2.6, HOT)
-- warm reflected light along the shadowed right contours, to turn the forms
s({{572,250},{577,300},{570,345}}, 1.6, RF, 1.2)
s({{724,456},{728,500}}, 1.6, RF, 1)
s({{612,470},{616,540},{610,600}}, 1.6, RF, 1)
s({{606,740},{608,840},{604,960}}, 1.6, RF, 1)
s({{620,1060},{622,1220},{624,1360}}, 1.6, RF, 1)
s({{456,1060},{458,1220},{456,1360}}, 1.4, RF, 1)
s({{334,520},{332,600},{330,700}}, 1.4, RF, 1)
s({{668,1420},{672,1450}}, 1.4, RF, 1)
-- sword-belt across the hips over the tabard, with a lit buckle
local belt = poly({{396,690},{604,690},{606,712},{394,712}})
work(belt, {hand="detail", pile=pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.6}}, coverage=4, fill=true, clip=belt})
local bk = rect(486, 688, 28, 26)
work(bk, {hand="detail", pile=pile{{"yellow ochre",1.5},{"raw sienna",0.6},{"lead white",0.5}}, coverage=4, fill=true, clip=bk})
s({{398,692},{450,692}}, 1.4, pile{{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.4}}, 1)
-- tabard hem catching the light
s({{402,1100},{430,1126},{470,1118},{500,1110}}, 2, pile{{"vermilion",1},{"lead white",0.3}}, 1)

--@ chunk 15
NP = {}
NP.helm = {{446,222},{492,204},{540,214},{566,250},{572,300},{562,346},{540,370},{492,380},{448,368},{424,340},{418,296},{424,252}}
NP.visor = {{428,262},{522,256},{532,300},{522,340},{434,344},{420,300}}
NP.gorget = {{440,362},{548,362},{576,404},{414,406}}
NP.cuirass = {{404,404},{596,396},{620,466},{612,556},{594,636},{410,644},{388,560},{382,472}}
NP.lpaul = {{410,404},{360,402},{306,424},{274,466},{270,514},{300,526},{350,506},{398,486},{420,446}}
NP.llame = {{276,512},{346,498},{342,526},{282,540}}
NP.rpaul = {{590,394},{640,384},{694,402},{726,442},{730,490},{702,504},{652,484},{604,464},{582,428}}
NP.rlame = {{652,482},{728,488},{724,514},{660,508}}
NP.lrere = {{284,540},{328,536},{324,604},{288,606}}
NP.lcout = {{280,600},{318,598},{332,620},{316,642},{282,642},{270,620}}
NP.lfan = {{316,602},{346,616},{318,638}}
NP.lvamb = {{284,640},{322,640},{326,736},{286,740}}
NP.lcuff = {{278,734},{330,730},{336,758},{274,762}}
NP.lhand = {{276,758},{332,754},{342,790},{332,818},{300,828},{276,812},{266,786}}
NP.rrere = {{686,510},{724,510},{728,576},{692,580}}
NP.rcout = {{686,574},{728,570},{742,592},{728,616},{692,618},{678,596}}
NP.rfan = {{682,582},{658,596},{682,612}}
NP.rvamb = {{690,612},{730,610},{740,672},{706,678}}
NP.tabard = {{420,520},{580,516},{594,640},{600,700},{606,900},{596,930},{560,918},{500,936},{440,920},{404,932},{394,900},{398,700},{406,640}}
NP.belt = {{396,682},{604,694},{606,716},{394,704}}
NP.lcuisse = {{404,900},{490,900},{484,982},{414,984}}
NP.lpoleyn = {{410,976},{484,974},{492,1000},{480,1026},{416,1028},{404,1000}}
NP.lwing = {{406,984},{382,1000},{406,1018}}
NP.lgreave = {{414,1024},{480,1022},{472,1200},{464,1380},{424,1382},{418,1200}}
NP.lsab = {{418,1378},{468,1376},{474,1410},{464,1446},{372,1452},{366,1430},{392,1410}}
NP.rcuisse = {{512,904},{600,898},{612,980},{548,996}}
NP.rpoleyn = {{546,986},{612,976},{628,1002},{616,1030},{556,1036},{540,1012}}
NP.rwing = {{626,992},{648,1006},{626,1022}}
NP.rgreave = {{558,1032},{618,1026},{616,1200},{606,1370},{568,1374},{562,1200}}
NP.rsab = {{566,1370},{610,1366},{642,1396},{674,1430},{670,1452},{574,1452},{562,1420}}
NP.rhand = {{700,668},{780,662},{790,700},{784,742},{710,748},{694,712}}
NP.muzzle = {{708,148},{778,148},{784,250},{702,250}}
NP.breech = {{714,770},{778,770},{780,870},{712,870}}
CANN = ribbon({{743,240},{744,700},{746,1100},{748,1450}}, {46,46,42,38})
function PM(k) return poly(NP[k]) end
NEWFIG = CANN + PM("muzzle") + PM("breech")
for k,_ in pairs(NP) do NEWFIG = NEWFIG + PM(k) end
-- repaint the background wherever the old figure stood and the new one does not
local old = (P.all + P.staff + P.muzzle + CAN):grow(2)
local floorM = below(function(x) return 1440 - 0.02*(x-500) end)
local patch = old - NEWFIG:shrink(2) - floorM
local glow = ellipse(260, 520, 420, 620):roughen(30,150,2)
local B0 = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.6}}
local B1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"raw sienna",0.4}}
work(patch - glow, {hand="body", pile=B0, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2+0.2, clip=patch})
work(patch * glow, {hand="body", pile=B1, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2+0.2, clip=patch})
local fpatch = old * floorM - NEWFIG:shrink(2)
work(fpatch, {hand="body", pile=pile{{"bone black",1.5},{"bone brown",1}}, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=fpatch})

--@ chunk 16
SDK = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
SMD = pile{{"ultramarine ash",1},{"bone black",0.7},{"yellow ochre",0.25},{"lead white",0.25}}
SLT = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"yellow ochre",0.25},{"bone black",0.15}}
function plate(k, ang, lit)
  local pts = NP[k]
  local minx,maxx,miny,maxy = 1e9,-1e9,1e9,-1e9
  for _,q in ipairs(pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
  local cx, hw = (minx+maxx)/2, (maxx-minx)/2
  local m = poly(pts)
  local tool = hw > 50 and "filbert 6" or "filbert 3"
  work(m, {hand="body", pile=SDK, coverage=3, fill=true, tool=tool, angle=ang, clip=m, length={8,30}})
  local midz = m * rect(minx-4, miny-4, (cx + (lit or 0.05)*hw) - minx + 4, maxy-miny+8)
  work(midz, {hand="body", pile=SMD, coverage=2.5, fill=true, tool=tool, angle=ang, clip=m, length={8,30}})
  local ltz = m * rect(minx-4, miny-4, (cx - 0.55*hw) - minx + 4, maxy-miny+8)
  work(ltz, {hand="body", pile=SLT, coverage=1.6, tool=(hw > 50 and "filbert 4" or "filbert 2"), angle=ang, clip=m, length={6,20}})
end
-- the cannon, back to front: barrel, breech, muzzle
work(CANN, {hand="body", pile=SDK, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=CANN})
work(CANN * rect(700,140,38,1320), {hand="body", pile=SMD, coverage=2.5, fill=true, tool="filbert 3", angle=math.pi/2, clip=CANN})
plate("breech", math.pi/2); plate("muzzle", math.pi/2)
for _,k in ipairs({"lsab","rsab"}) do plate(k, 0) end
for _,k in ipairs({"lgreave","rgreave"}) do plate(k, math.pi/2) end
for _,k in ipairs({"lcuisse","rcuisse"}) do plate(k, math.pi/2) end
for _,k in ipairs({"lpoleyn","rpoleyn","lwing","rwing"}) do plate(k, 0) end

--@ chunk 17
plate("cuirass", math.pi/2, -0.1)
-- tabard, heavier folds wet into wet
local T = PM("tabard")
local C0 = pile{{"rose madder",1.5},{"bone black",0.8},{"Mars red",0.4}}
local C1 = pile{{"Mars red",1.4},{"rose madder",1}}
local C2 = pile{{"vermilion",1.2},{"Mars red",0.6},{"lead white",0.3}}
work(T, {hand="body", pile=C0, coverage=3, fill=true, tool="filbert 8", angle=math.pi/2, clip=T})
TFOLD = {{416,"L"},{432,"M"},{462,"L"},{478,"M"},{520,"M"},{548,"M"}}
for _,f in ipairs(TFOLD) do
  local x = f[1]
  local band = T * poly({{x-8,530},{x+8,530},{x+12+(x-500)*0.04,940},{x-12+(x-500)*0.04,940}})
  work(band, {hand="body", pile=(f[2]=="L") and C2 or C1, coverage=2.5, fill=true, tool="filbert 4", angle=math.pi/2, clip=T, length={60,160}})
end
-- upper body
plate("belt", 0)
for _,k in ipairs({"lrere","rrere"}) do plate(k, math.pi/2) end
for _,k in ipairs({"lvamb","rvamb"}) do plate(k, math.pi/2) end
for _,k in ipairs({"lcout","rcout","lfan","rfan"}) do plate(k, 0) end
for _,k in ipairs({"llame","rlame","lpaul","rpaul"}) do plate(k, 0.3) end
plate("gorget", 0); plate("helm", math.pi/2); plate("visor", math.pi/2)
for _,k in ipairs({"lcuff","lhand","rhand"}) do plate(k, 0) end

--@ chunk 18
print(wait(3*24*60)); print(drying(450,1100), drying(500,700))
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.25}}
local EDGE = pile{{"lead white",1.8},{"ultramarine ash",0.4},{"yellow ochre",0.3}}
local RF = pile{{"burnt sienna",1},{"Mars orange",0.7},{"bone brown",0.4}}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.5}}
local r = brush{kind="round", width=4, point=0.8}
-- for every plate: lit edge on the sides that face the light (left/up), warm reflection on the far right edge, a dark seam under it
local order = {"lsab","rsab","lgreave","rgreave","lcuisse","rcuisse","lpoleyn","rpoleyn","lwing","rwing","breech","muzzle","cuirass","belt","lrere","rrere","lvamb","rvamb","lcout","rcout","lfan","rfan","llame","rlame","lpaul","rpaul","gorget","helm","visor","lcuff","lhand","rhand"}
for _,k in ipairs(order) do
  local pts = NP[k]; local n = #pts
  for i=1,n do
    local a, b = pts[i], pts[i % n + 1]
    local dx, dy = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(dx*dx+dy*dy)
    if l > 6 then
      -- outward normal (polygons wound clockwise on screen or not: test with centroid)
      local cx, cy = 0, 0 for _,q in ipairs(pts) do cx = cx + q[1]/n; cy = cy + q[2]/n end
      local nx, ny = -dy/l, dx/l
      local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
      if (mx-cx)*nx + (my-cy)*ny < 0 then nx, ny = -nx, -ny end
      local facing = -0.8*nx - 0.6*ny
      local p0 = {a[1] - nx*1.6 + dx*0.06, a[2] - ny*1.6 + dy*0.06}
      local p1 = {b[1] - nx*1.6 - dx*0.06, b[2] - ny*1.6 - dy*0.06}
      if facing > 0.45 then
        r:reload(facing > 0.8 and HOT or EDGE, 0.6)
        r:stroke({p0, p1}, {pressure={r:pressure_for(2.2), r:pressure_for(1.2)}, swell={0.4,1,0.5}})
      elseif nx > 0.6 then
        r:reload(RF, 0.5)
        r:stroke({p0, p1}, {pressure={r:pressure_for(1.2), r:pressure_for(0.8)}})
      end
      if ny > 0.6 and k ~= "lsab" and k ~= "rsab" then
        r:reload(SEAM, 0.6)
        r:stroke({{a[1]+nx*1.5, a[2]+ny*1.5},{b[1]+nx*1.5, b[2]+ny*1.5}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
      end
    end
  end
end
-- visor slit and the cold optic, turned toward the light
local K = pile{{"bone black",2},{"ultramarine blue",0.4}}
local sl = poly({{432,290},{520,288},{522,302},{432,304}})
work(sl, {hand="detail", pile=K, coverage=5, fill=true, clip=sl})
local CB = pile{{"cerulean blue",1},{"cobalt blue",1},{"zinc white",0.6}}
local CO = pile{{"zinc white",2},{"cerulean blue",1}}
r:reload(CB, 0.7); r:stroke({{456,296},{486,296}}, {pressure={r:pressure_for(5.5), r:pressure_for(5.5)}})
r:reload(CO, 0.8); r:touch(468, 296, {pressure=r:pressure_for(4)})
-- bone cross on the breast, worn
local bone = pile{{"lead white",2},{"yellow ochre",0.7},{"raw sienna",0.2}}
local cr = rect(488, 556, 24, 140) + rect(452, 594, 96, 22)
work(cr * PM("tabard") - PM("belt"), {hand="detail", pile=bone, coverage=3.5, fill=true, clip=cr})
-- tabard: deep troughs and lit ridges drawn on set paint
local CS = pile{{"rose madder",1.2},{"bone black",1.2},{"ultramarine blue",0.2}}
local CH = pile{{"vermilion",1.2},{"cadmium red",0.6},{"lead white",0.5}}
local T = PM("tabard") - cr - PM("belt")
local fr = brush{kind="round", width=8, point=0.8}
for _,x in ipairs({444, 490, 534, 568, 590}) do
  fr:reload(CS, 0.8); fr:stroke({{x,722},{x-2,800},{x+2,870},{x+(x-500)*0.05,935}}, {pressure={fr:pressure_for(1.5), fr:pressure_for(x > 560 and 8 or 6)}, clip=T})
  fr:reload(CS, 0.6); fr:stroke({{x+2,530},{x,600},{x+1,676}}, {pressure={fr:pressure_for(1.2), fr:pressure_for(4)}, clip=T})
end
for _,x in ipairs({426, 468, 512}) do
  fr:reload(CH, 0.6); fr:stroke({{x,726},{x-1,820},{x+2,920}}, {pressure={fr:pressure_for(4), fr:pressure_for(1.5)}, clip=T})
end
fr:reload(CH, 0.5); fr:stroke({{400,926},{440,916},{480,930},{500,934}}, {pressure={fr:pressure_for(2.5), fr:pressure_for(1)}, clip=T:grow(2)})

--@ chunk 19
print(wait(2*24*60))
local GOLD = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.3}}
local et = brush{kind="round", width=4, point=0.9}
-- the palm frond, larger, etched across the left pauldron
local stem = {{288,508},{306,476},{332,448},{366,424},{396,412}}
et:reload(GOLD, 0.7); et:stroke(stem, {pressure={et:pressure_for(2.6), et:pressure_for(1)}})
for i=1,9 do
  local t = i/10
  local x = lerp(288, 396, t); local y = lerp(508, 412, t) - 6*math.sin(t*math.pi)
  local l = 26*(1 - t*0.55)
  et:reload(GOLD, 0.55); et:stroke({{x,y},{x - l*0.25, y - l*0.85}}, {pressure={et:pressure_for(1.8), 0}})
  et:reload(GOLD, 0.55); et:stroke({{x,y},{x + l*0.8, y + l*0.35}}, {pressure={et:pressure_for(1.8), 0}})
end
-- gauntlet finger lames, left and right
local K = pile{{"bone black",2},{"ultramarine blue",0.4}}
for _,y in ipairs({772, 786, 800, 812}) do et:reload(K, 0.6); et:stroke({{272,y},{304,y+3},{336,y}}, {pressure={et:pressure_for(1.6), et:pressure_for(1.2)}}) end
for _,x in ipairs({716, 730, 744}) do et:reload(K, 0.6); et:stroke({{x,676},{x+2,710},{x,740}}, {pressure={et:pressure_for(1.6), et:pressure_for(1.2)}}) end
-- the rosary, bigger beads wound twice round the left fist, the crucifix hanging below
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
local bead = brush{kind="round", width=11, point=0}
local h = brush{kind="round", width=3, point=0.8}
for k=0,1 do
  for i=0,5 do local t=i/5
    local x, y = lerp(270, 338, t), 776 + k*26 + 8*math.sin(t*math.pi)
    bead:reload(BB, 0.8); bead:touch(x, y, {pressure=0.85})
    if i % 2 == 0 then h:reload(BH, 0.5); h:touch(x-2.5, y-2.5, {pressure=0.4}) end
  end
end
for i=1,7 do local x, y = 296 + 3*math.sin(i*0.7), 830 + i*12; bead:reload(BB, 0.8); bead:touch(x, y, {pressure=0.8}); h:reload(BH, 0.5); h:touch(x-2, y-2, {pressure=0.35}) end
local cr = brush{kind="round", width=8, point=0.3}
cr:reload(BB, 0.9); cr:stroke({{297,920},{297,976}}, {pressure={cr:pressure_for(7), cr:pressure_for(7)}})
cr:reload(BB, 0.9); cr:stroke({{280,938},{314,938}}, {pressure={cr:pressure_for(7), cr:pressure_for(7)}})
h:reload(BH, 0.6); h:stroke({{294,922},{294,972}}, {pressure={h:pressure_for(1.6), h:pressure_for(1.4)}})
h:reload(BH, 0.6); h:stroke({{282,935},{310,935}}, {pressure={h:pressure_for(1.4), h:pressure_for(1.4)}})
-- cannon: copper coil rings, a lit edge, cold light in the muzzle
local BR = pile{{"burnt sienna",1},{"Mars orange",0.8},{"yellow ochre",0.6}}
for y=262,640,20 do et:reload(BR, 0.6); et:stroke({{721,y},{744,y+5},{767,y}}, {pressure={et:pressure_for(3), et:pressure_for(2.2)}}) end
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.25}}
et:reload(HOT, 0.6); et:stroke({{723,880},{724,1100},{728,1420}}, {pressure={et:pressure_for(2.4), et:pressure_for(0.8)}})
local CB = pile{{"cerulean blue",1},{"cobalt blue",1},{"zinc white",0.6}}
local CO = pile{{"zinc white",2},{"cerulean blue",1}}
local mz = poly({{718,154},{768,154},{772,176},{714,176}})
work(mz, {hand="detail", pile=CB, coverage=4, fill=true, clip=mz})
et:reload(CO, 0.7); et:stroke({{726,163},{760,163}}, {pressure={et:pressure_for(3), et:pressure_for(3)}})
local glow = ellipse(743, 160, 50, 34) - mz - PM("muzzle")
stipple(glow, {pile=pile{{"zinc white",2},{"cerulean blue",0.8}}, width=2, pressure={0.3,0.5}, coverage=function(x,y) local d = math.sqrt((x-743)^2 + ((y-160)*1.4)^2) return 1.4*math.exp(-d/10) end, feather=0.6})
