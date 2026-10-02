-- easel session "seed_cell": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.25, linen={18,16}, seed=7373, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"burnt sienna",3},{"bone brown",2},{"lead white",1},{"ultramarine blue",0.4}}, um=30, apply="brush"}}}
VP = {500, 400}
FAB = {x=500, y=455, rx=95, ry=78}
-- hull: dark, warming toward the fabricator
local H0 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.5}}
local H1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local H2 = pile{{"burnt sienna",2},{"Mars orange",0.6},{"bone brown",0.6}}
local d = function(x,y) return math.sqrt(((x-FAB.x)/1.25)^2 + (y-FAB.y)^2) end
local outer = mask(function(x,y) return d(x,y) > 330 and 1 or 0 end):roughen(15,80,1)
local midr = mask(function(x,y) local v=d(x,y) return (v > 190 and v <= 340) and 1 or 0 end):roughen(12,70,2)
local inner = mask(function(x,y) return d(x,y) <= 200 and 1 or 0 end)
local rad = function(x,y) return math.atan(y-VP[2], x-VP[1]) + math.pi/2 end
work(outer, {hand="broad", pile=H0, coverage=3, fill=true, angle=rad})
work(midr, {hand="broad", pile=H1, coverage=3, fill=true, angle=rad})
work(inner, {hand="body", pile=H2, coverage=3, fill=true, angle=rad, tool="filbert 14"})
print(W,H)

--@ chunk 2
local d = function(x,y) return math.sqrt(((x-FAB.x)/1.25)^2 + (y-FAB.y)^2) end
local tan = function(x,y) return math.atan(y-FAB.y, x-FAB.x) + math.pi/2 end
for _,r in ipairs({200, 335}) do
  local band = mask(function(x,y) local v=d(x,y) return math.abs(v-r) < 26 and 1 or 0 end)
  blend(band, {angle=tan, tool={kind="badger", width=24}, pressure={0.3,0.5}})
end

--@ chunk 3
RINGS = {}
local m = nil
for k,s in ipairs({1.3, 1.02, 0.8, 0.62}) do
  local pts, ws = {}, {}
  for i=0,64 do local a = 2*math.pi*i/64; pts[#pts+1] = {500 + 470*s*math.cos(a), 420 + 370*s*math.sin(a)}; ws[#ws+1] = 34*s end
  RINGS[k] = {s=s, pts=pts}
  local r = ribbon(pts, ws); m = m and (m+r) or r
end
RIBM = m
-- the deck: a grated floor across the lower hull
DECK = poly({{-10,640},{1010,640},{1010,810},{-10,810}}) + poly({{170,560},{830,560},{1010,650},{-10,650}})
local R0 = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.6}}
work(RIBM - DECK, {hand="body", pile=R0, coverage=3.5, fill=true, tool="filbert 10", angle=function(x,y) return math.atan(y-420,x-500)+math.pi/2 end, clip=RIBM - DECK})
local D0 = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local D1 = pile{{"burnt sienna",2},{"Mars orange",0.8},{"bone brown",0.5}}
work(DECK * above(function(x) return 640 end), {hand="body", pile=D1, coverage=3, fill=true, tool="filbert 12", angle=0, clip=DECK})
work(DECK * below(function(x) return 640 end), {hand="broad", pile=D0, coverage=3, fill=true, angle=0, clip=DECK})

--@ chunk 4
print(wait(3*24*60)); print(drying(500,450), drying(500,700), drying(100,100))
local collar = ellipse(FAB.x, FAB.y, FAB.rx+22, FAB.ry+18)
local mouth = ellipse(FAB.x, FAB.y, FAB.rx, FAB.ry)
local K = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}
work(collar - mouth, {hand="detail", pile=K, coverage=4, fill=true, clip=collar - mouth})
-- the hot throat: deep orange at the rim, white-yellow low in the throat where the print bed glows
local H1 = pile{{"Mars orange",1.5},{"cadmium red",0.6},{"burnt sienna",0.6}}
local H2 = pile{{"cadmium yellow",1.5},{"Mars orange",1},{"lead white",0.5}}
local H3 = pile{{"zinc white",2},{"cadmium yellow",1},{"lemon chrome",0.4}}
work(mouth, {hand="body", pile=H1, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=mouth})
local inner = ellipse(FAB.x, FAB.y+18, FAB.rx*0.72, FAB.ry*0.6) * mouth
work(inner, {hand="body", pile=H2, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=mouth})
local core = ellipse(FAB.x, FAB.y+34, FAB.rx*0.45, FAB.ry*0.28) * mouth
work(core, {hand="body", pile=H3, coverage=4, fill=true, tool="filbert 5", angle=0, clip=mouth})
blend(mouth:shrink(3), {angle=0, tool={kind="badger", width=14}, pressure={0.25,0.4}})

--@ chunk 5
-- the rack at the left edge: spare frames hanging, shadowed
local K = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}}
local rk = nil
for i,x in ipairs({40, 112, 176}) do
  local s = 1 - (i-1)*0.12
  local top = 150 + (i-1)*30
  local body = ellipse(x, top+30*s, 20*s, 24*s)
           + poly({{x-38*s, top+60*s},{x+38*s, top+60*s},{x+30*s, top+190*s},{x-30*s, top+190*s}}, true)
           + ribbon({{x-36*s, top+66*s},{x-44*s, top+160*s},{x-42*s, top+250*s}}, {16*s,13*s,11*s})
           + ribbon({{x+36*s, top+66*s},{x+44*s, top+160*s},{x+42*s, top+250*s}}, {16*s,13*s,11*s})
           + ribbon({{x-14*s, top+190*s},{x-16*s, top+300*s},{x-15*s, top+400*s}}, {20*s,16*s,13*s})
           + ribbon({{x+14*s, top+190*s},{x+16*s, top+300*s},{x+15*s, top+400*s}}, {20*s,16*s,13*s})
           + ribbon({{x, top-60},{x, top+8*s}}, 3)
  rk = rk and (rk + body) or body
end
RACK = rk
work(RACK, {hand="body", pile=K, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, clip=RACK:grow(1), edge="firm"})
-- the rack's rail across the top
local rail = ribbon({{-10,100},{120,108},{240,122}}, 10)
work(rail, {hand="detail", pile=K, coverage=4, fill=true, clip=rail})

--@ chunk 6
-- the frame, seated on an ammunition crate, in profile facing the shrine, head bowed
FG = {}
FG.crate = poly({{318,622},{452,618},{456,712},{314,716}})
FG.head = ellipse(436, 448, 25, 28)
FG.torso = poly({{372,470},{404,458},{432,472},{446,500},{448,540},{440,600},{430,630},{372,632},{360,590},{358,530},{362,494}}, true)
FG.thigh = ribbon({{420,612},{470,610},{510,612}}, {38,34,30})
FG.shin = ribbon({{510,612},{516,660},{518,705}}, {28,24,20})
FG.foot = poly({{500,700},{540,700},{546,716},{498,716}})
FG.arm = ribbon({{420,488},{432,530},{452,566},{486,586}}, {24,20,18,16})
FG.hand = ellipse(492, 588, 11, 9)
FG.all = FG.head + FG.torso + FG.thigh + FG.shin + FG.foot + FG.arm + FG.hand
local C = pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.4}}
work(FG.crate, {hand="body", pile=C, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=FG.crate, edge="found"})
local F = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.8}}
work(FG.all, {hand="body", pile=F, coverage=4, fill=true, tool="filbert 6", angle=math.pi/2, clip=FG.all:grow(1), edge="found"})
-- the shrine on the right wall: a ledge cut from a rib
SH = {}
SH.ledge = poly({{770,566},{930,560},{934,578},{772,584}})
SH.cloth = poly({{790,566},{900,562},{904,640},{892,632},{878,646},{862,634},{846,648},{830,636},{812,650},{794,638}}, true)
local L = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.4}}
work(SH.ledge, {hand="detail", pile=L, coverage=4, fill=true, clip=SH.ledge})
work(SH.cloth, {hand="detail", pile=pile{{"rose madder",1.5},{"Mars red",1.5},{"bone black",0.3}}, coverage=4, fill=true, clip=SH.cloth})

--@ chunk 7
print(wait(4*24*60)); print(drying(436,448), drying(400,560), drying(500,450))
local F = pile{{"bone black",2.5},{"ultramarine blue",0.8},{"burnt sienna",0.6}}
work(FG.all, {hand="body", pile=F, coverage=4.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=FG.all, load=1})
-- altar block under the cloth
local alt = poly({{788,580},{906,576},{910,660},{786,664}})
work(alt - SH.cloth, {hand="body", pile=pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.5}}, coverage=4, fill=true, tool="filbert 5", clip=alt - SH.cloth})
-- the cross, cut from hull scrap, against the wall above
CROSS = poly({{842,440},{856,438},{858,476},{884,474},{885,488},{858,490},{860,560},{846,562},{844,492},{818,494},{817,480},{843,478}})
work(CROSS, {hand="detail", pile=pile{{"bone black",1.5},{"bone brown",1},{"burnt sienna",0.6}}, coverage=4.5, fill=true, clip=CROSS})

--@ chunk 8
print(wait(2*24*60))
local F = FG.all:grow(2) + FG.crate:grow(2)
-- glow spill onto the deck below the mouth, warm pool fading toward us
local pool = poly({{300,560},{700,560},{860,700},{140,700}}, true):soften(30) * DECK - F
work(pool * above(function(x) return 620 end), {hand="body", pile=pile{{"Mars orange",1.5},{"cadmium yellow",0.6},{"burnt sienna",0.6}}, coverage=2.5, tool="filbert 10", angle=0, clip=DECK - F, edge="soft"})
work(pool * below(function(x) return 620 end), {hand="body", pile=pile{{"burnt sienna",1.5},{"Mars orange",0.8},{"bone brown",0.4}}, coverage=2.5, tool="filbert 12", angle=0, clip=DECK - F, edge="soft"})
-- the deck's lip edge catching it
local lip = brush{kind="round", width=4, point=0.6}
lip:reload(pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}, 0.6)
lip:stroke({{180,561},{320,560},{450,559}}, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.6)}, clip=-F})
lip:reload(pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}, 0.6)
lip:stroke({{560,559},{700,560},{820,561}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.5)}, clip=-F})
-- grating lines across the deck
local g = pile{{"bone black",1.5},{"bone brown",1}}
for _,y in ipairs({585, 615, 652, 700, 760}) do
  lip:reload(g, 0.6); lip:stroke({{-5,y},{500,y},{1005,y}}, {pressure={lip:pressure_for(1+(y-560)/80), lip:pressure_for(1+(y-560)/80)}, clip=DECK - F - poly({{786,560},{910,560},{910,664},{786,664}})})
end
for _,x in ipairs({-500,-200,60,280,500,720,940,1200}) do
  local x0 = lerp(500, x, (560-400)/(810-400))
  lip:reload(g, 0.6); lip:stroke({{x0,561},{x,810}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(2.4)}, clip=DECK - F - poly({{786,560},{910,560},{910,664},{786,664}})})
end

--@ chunk 9
local F = FG.all:grow(3) + FG.crate:grow(3)
local pool = poly({{300,560},{700,560},{860,700},{140,700}}, true):soften(30)
local edge = (pool:grow(30) - pool:shrink(30)) * DECK - F
blend(edge, {angle=0, tool={kind="badger", width=30}, pressure={0.35,0.55}})
blend(DECK * rect(0,600,1000,60) - F, {angle=0, tool={kind="badger", width=30}, pressure={0.25,0.4}})

--@ chunk 10
print(wait(3*24*60)); print(drying(500,600), drying(500,750))
local F = FG.all:grow(1) + FG.crate:grow(1)
ALT = poly({{788,576},{906,572},{910,664},{786,668}})
local D = DECK - F - ALT:grow(1)
local horiz = 0
local P1 = pile{{"Mars orange",1.5},{"cadmium yellow",0.5},{"burnt sienna",0.7}}
local P2 = pile{{"burnt sienna",2},{"Mars orange",0.8},{"bone brown",0.3}}
local P3 = pile{{"burnt sienna",1.5},{"bone brown",1.5},{"ultramarine blue",0.2}}
local P4 = pile{{"bone brown",2},{"bone black",0.6},{"ultramarine blue",0.4}}
local function wedge(lo, hi, sx) return D * below(function(x) return lo end) * above(function(x) return hi end) end
-- far deck brightest near the mouth, and toward the sides it darkens
local centre = function(x,y) return math.abs(x-500) end
local bandA = wedge(560, 612) * mask(function(x,y) return math.abs(x-500) < 330 and 1 or 0 end):roughen(20,80,3)
work(wedge(560,612) - bandA, {hand="body", pile=P3, coverage=3, fill=true, tool="filbert 10", angle=0, clip=D})
work(bandA, {hand="body", pile=P1, coverage=3, fill=true, tool="filbert 10", angle=0, clip=D})
local bandB = wedge(605,680) * mask(function(x,y) return math.abs(x-500) < 360 and 1 or 0 end):roughen(25,90,4)
work(wedge(605,680) - bandB, {hand="body", pile=P4, coverage=3, fill=true, tool="filbert 12", angle=0, clip=D})
work(bandB, {hand="body", pile=P2, coverage=3, fill=true, tool="filbert 12", angle=0, clip=D})
work(wedge(672,740), {hand="body", pile=P3, coverage=3, fill=true, tool="filbert 14", angle=0, clip=D})
work(wedge(732,820), {hand="broad", pile=P4, coverage=3, fill=true, angle=0, clip=D})

--@ chunk 11
print(wait(3*24*60))
local F = FG.all:grow(1) + FG.crate:grow(1)
local D = DECK - F - ALT:grow(1)
local TOP = poly({{170,560},{830,560},{1010,650},{-10,650}}) * D * above(function(x) return 641 end)
local FRONT = D * below(function(x) return 641 end)
local P1 = pile{{"Mars orange",1.5},{"cadmium yellow",0.4},{"burnt sienna",0.9}}
local P2 = pile{{"burnt sienna",2},{"Mars orange",0.5},{"bone brown",0.6}}
local P3 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
local P4 = pile{{"bone brown",2},{"bone black",0.6},{"ultramarine blue",0.4}}
local mid = TOP * mask(function(x,y) local k = (y-560)/90; return math.abs(x-500) < 260 + 200*k and 1 or 0 end)
work(TOP - mid, {hand="body", pile=P2, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=TOP})
work(mid, {hand="body", pile=P1, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=TOP})
work(FRONT * above(function(x) return 700 end), {hand="body", pile=P3, coverage=3.5, fill=true, tool="filbert 12", angle=0, clip=FRONT})
work(FRONT * below(function(x) return 700 end), {hand="broad", pile=P4, coverage=3.5, fill=true, angle=0, clip=FRONT})
local seam = (TOP - mid):grow(14) * mid:grow(14) * TOP
blend(seam, {angle=math.pi/2, tool={kind="badger", width=12}, pressure={0.25,0.4}})

--@ chunk 12
print(wait(3*24*60))
local A = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.5}}
local alt = poly({{790,600},{904,596},{908,668},{788,672}})
work(alt, {hand="detail", pile=A, coverage=4.5, fill=true, clip=alt, load=1})
work(FG.crate, {hand="detail", pile=A, coverage=4.5, fill=true, clip=FG.crate, load=1})
CL = poly({{784,566},{906,562},{910,604},{898,598},{886,612},{872,600},{856,614},{840,602},{822,616},{806,604},{786,612}}, true)
work(CL, {hand="detail", pile=pile{{"rose madder",1.5},{"Mars red",1.5},{"bone black",0.35}}, coverage=5, fill=true, clip=CL, load=1})

--@ chunk 13
print(wait(3*24*60))
local warm = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.8}}
local hot = pile{{"zinc white",2},{"cadmium yellow",1},{"lemon chrome",0.3}}
local dull = pile{{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",0.5}}
local K = pile{{"bone black",2},{"ultramarine blue",0.6}}
local lip = brush{kind="round", width=4, point=0.8}
-- rib inner edges catching the fabricator
for k,R in ipairs(RINGS) do
  local s = R.s
  local pts = {}
  for i=0,64 do local a = 2*math.pi*i/64
    local x, y = 500 + (470*s - 17*s)*math.cos(a), 420 + (370*s - 17*s)*math.sin(a)
    if y < 556 and x > -20 and x < 1020 then pts[#pts+1] = {x,y} elseif #pts > 1 then
      lip:reload(k >= 3 and warm or dull, 0.6); lip:stroke(pts, {pressure={lip:pressure_for(0.6), lip:pressure_for(0.6)}, swell={0.2,1,1,1,1,1,1,0.2}, clip=-(RACK:grow(2)) - FG.all:grow(2) - CROSS:grow(2)}); pts = {} else pts = {} end
  end
  if #pts > 1 then lip:reload(k >= 3 and warm or dull, 0.6); lip:stroke(pts, {pressure={lip:pressure_for(0.6), lip:pressure_for(0.6)}, clip=-(RACK:grow(2)) - FG.all:grow(2) - CROSS:grow(2)}) end
end
-- the fabricator collar: bolted rim lit from inside
local pts = {} for i=0,40 do local a = math.pi*(0.15 + 0.7*i/40) + math.pi; pts[#pts+1] = {FAB.x + (FAB.rx+3)*math.cos(a), FAB.y + (FAB.ry+3)*math.sin(a)} end
lip:reload(hot, 0.6); lip:stroke(pts, {pressure={lip:pressure_for(1), lip:pressure_for(1)}, swell={0.2,1,1,1,0.2}, clip=-FG.all:grow(2)})
-- rim on the frame from the mouth behind him
lip:reload(hot, 0.6)
local hp = {} for i=0,12 do local a = -1.4 + 1.9*i/12; hp[#hp+1] = {436 + 24*math.cos(a), 448 + 27*math.sin(a)} end
lip:stroke(hp, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.8)}, swell={0.3,1,1,0.6}})
lip:reload(warm, 0.6); lip:stroke({{432,474},{444,494},{448,530}}, {pressure={lip:pressure_for(1.5), lip:pressure_for(0.6)}})
lip:reload(warm, 0.5); lip:stroke({{440,594},{470,592},{506,596}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1.0)}})
lip:reload(warm, 0.5); lip:stroke({{372,472},{392,460},{410,458}}, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.4)}})
-- the cable from the back of his neck up into the archive in the ribs
ARCH = rect(250, 228, 46, 34)
work(ARCH, {hand="detail", pile=pile{{"bone black",2},{"bone brown",1}}, coverage=4, fill=true, clip=ARCH})
local cab = brush{kind="round", width=5, point=0.3}
cab:reload(K, 0.9); cab:stroke({{392,470},{360,440},{330,400},{300,340},{285,290},{276,262}}, {pressure={cab:pressure_for(3), cab:pressure_for(3)}})
lip:reload(dull, 0.5); lip:stroke({{358,436},{330,396},{302,338}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(0.6)}})
local led = brush{kind="round", width=2.5, point=0.9}
for i,c in ipairs({{"viridian","lead white"},{"cadmium yellow","lead white"},{"viridian","lead white"},{"vermilion","lead white"}}) do
  led:reload(pile{{c[1],1},{c[2],1}}, 0.6); led:touch(258 + i*7, 238, {pressure=0.5})
end

--@ chunk 14
-- candle-LED on the altar
local cnd = rect(808, 532, 10, 30)
work(cnd, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.5}}, coverage=4, fill=true, clip=cnd})
local glow = ellipse(813, 524, 40, 36) - cnd - CROSS
stipple(glow, {pile=pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, width=2, pressure={0.3,0.5},
  coverage=function(x,y) local d=math.sqrt((x-813)^2+(y-524)^2) return 2.2*math.exp(-d/9) end, feather=0.6})
local fl = brush{kind="round", width=3, point=1}
fl:reload(pile{{"zinc white",2},{"lemon chrome",0.6}}, 0.7); fl:stroke({{813,531},{813,524},{813.5,517}}, {pressure={fl:pressure_for(3), 0}})
-- the cross takes the candle on its near edges; rivets
local lip = brush{kind="round", width=3, point=0.8}
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",1}}
lip:reload(warm, 0.6); lip:stroke({{843,480},{844,520},{846,560}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1.0)}})
lip:reload(warm, 0.6); lip:stroke({{818,494},{830,493},{843,492}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.2)}})
for _,p in ipairs({{851,446},{851,484},{868,481},{852,530}}) do lip:reload(pile{{"burnt sienna",1},{"Mars orange",1}}, 0.5); lip:touch(p[1], p[2], {pressure=0.4}) end
-- the cloth's top catches the candle, its folds
lip:reload(pile{{"vermilion",1.2},{"cadmium red",0.8},{"lead white",0.2}}, 0.6); lip:stroke({{788,566},{820,563},{850,563}}, {pressure={lip:pressure_for(2), lip:pressure_for(0.6)}, clip=CL})
local dk = pile{{"rose madder",1},{"bone black",0.8}}
for _,x in ipairs({815, 846, 878}) do lip:reload(dk, 0.6); lip:stroke({{x,572},{x+1,590},{x,606}}, {pressure={lip:pressure_for(2), lip:pressure_for(1)}, clip=CL}) end
-- the rack's edges toward the glow, faint
local dull = pile{{"burnt sienna",1},{"Mars orange",0.8},{"bone brown",0.5}}
for i,x in ipairs({40, 112, 176}) do
  local s = 1 - (i-1)*0.12; local top = 150 + (i-1)*30
  lip:reload(dull, 0.5); lip:stroke({{x+36*s, top+66*s},{x+44*s, top+160*s},{x+42*s, top+245*s}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(0.5)}, clip=RACK})
  lip:reload(dull, 0.5); lip:stroke({{x+4*s, top+10*s},{x+18*s, top+24*s},{x+16*s, top+44*s}}, {pressure={lip:pressure_for(1), lip:pressure_for(0.5)}, clip=RACK})
end

--@ chunk 15
print(wait(3*24*60))
local P = pile{{"bone black",1.5},{"bone brown",1},{"burnt sienna",0.6},{"ultramarine blue",0.3}}
local dull = pile{{"burnt sienna",1.2},{"Mars orange",0.8},{"yellow ochre",0.4}}
local warm = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.8}}
local lip = brush{kind="round", width=4, point=0.8}
-- pauldron on the near (left) shoulder, plates down the back, knee cop, helm seam
local paul = ellipse(392, 486, 30, 20)
work(paul, {hand="detail", pile=P, coverage=4.5, fill=true, clip=paul * FG.all:grow(4)})
for k,y in ipairs({520, 548, 576}) do
  lip:reload(dull, 0.5); lip:stroke({{362,y},{382,y-3},{404,y-2},{424,y+2}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.0)}, clip=FG.torso:shrink(2)})
end
local arc = {} for i=0,12 do local a = math.pi*(1.0 + 1.0*i/12); arc[#arc+1] = {392 + 30*math.cos(a), 486 + 20*math.sin(a)} end
lip:reload(warm, 0.6); lip:stroke(arc, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.6)}, swell={0.4,1,1,0.6}})
lip:reload(dull, 0.5); lip:stroke({{368,496},{392,502},{416,496}}, {pressure={lip:pressure_for(1), lip:pressure_for(1)}})
local knee = ellipse(510, 612, 17, 15)
work(knee, {hand="detail", pile=P, coverage=4.5, fill=true, clip=knee})
local ka = {} for i=0,10 do local a = math.pi*(1.2 + 0.9*i/10); ka[#ka+1] = {510 + 16*math.cos(a), 612 + 14*math.sin(a)} end
lip:reload(warm, 0.6); lip:stroke(ka, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.6)}})
lip:reload(dull, 0.5); lip:stroke({{414,440},{430,436},{448,440}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(1)}})
-- rosary in his hands, falling between his knees
local bead = brush{kind="round", width=3, point=0}
local BB = pile{{"bone brown",2},{"burnt sienna",1}}
for i=1,8 do bead:reload(BB, 0.6); bead:touch(492 + 2*math.sin(i), 594 + i*4.2, {pressure=0.8}) end
local c = brush{kind="round", width=3, point=0.4}
c:reload(BB, 0.7); c:stroke({{492,630},{492,642}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})
c:reload(BB, 0.7); c:stroke({{488,634},{496,634}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})
for i=1,8,2 do lip:reload(warm, 0.4); lip:touch(493 + 2*math.sin(i), 593 + i*4.2, {pressure=0.2}) end
-- inside the fabricator: the print gantry and a half-formed limb on the bed
local K = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars red",0.4}}
local gan = ribbon({{FAB.x-70, FAB.y-30},{FAB.x+80, FAB.y-34}}, 5) + ribbon({{FAB.x+30, FAB.y-32},{FAB.x+34, FAB.y+6}}, 4)
       + ribbon({{FAB.x+5, FAB.y+44},{FAB.x+40, FAB.y+38},{FAB.x+70, FAB.y+40}}, {9,7,6})
work(gan * ellipse(FAB.x, FAB.y, FAB.rx-2, FAB.ry-2) - FG.all:grow(2), {hand="detail", pile=K, coverage=4, fill=true, clip=ellipse(FAB.x, FAB.y, FAB.rx-2, FAB.ry-2) - FG.all:grow(2)})
local sp = brush{kind="round", width=3, point=1}
sp:reload(pile{{"zinc white",2},{"lemon chrome",0.4}}, 0.7); sp:touch(FAB.x+34, FAB.y+8, {pressure=0.6})

--@ chunk 16
print(wait(2*24*60))
-- heat glow off the mouth onto the hull around it
local cx, cy = FAB.x, FAB.y
local ring = (ellipse(cx, cy, FAB.rx+80, FAB.ry+70) - ellipse(cx, cy, FAB.rx+21, FAB.ry+17)) - FG.all:grow(3) - DECK
stipple(ring, {pile=pile{{"Mars orange",1.5},{"cadmium yellow",0.8},{"lead white",0.4}}, width=2.4, pressure={0.3,0.6},
  coverage=function(x,y) local d = math.sqrt(((x-cx)/(FAB.rx+20))^2 + ((y-cy)/(FAB.ry+17))^2) return 2.0*math.exp(-(d-1)/0.25) end, feather=0.6})
-- scorch streaks on the hull: dark drags radiating from the mouth, the burrowing's burn
local sc = brush{kind="filbert", width=8}
local S = pile{{"bone black",2},{"burnt sienna",0.6}}
for i=1,22 do
  local a = rand(-math.pi, 0) + rand(-0.3,0.3)
  local r0 = rand(160, 260)
  local x0, y0 = cx + r0*1.25*math.cos(a), cy + r0*math.sin(a)
  local x1, y1 = cx + (r0+rand(60,140))*1.25*math.cos(a), cy + (r0+rand(60,140))*math.sin(a)
  sc:reload(S, 0.3)
  sc:stroke({{x0,y0},{x1,y1}}, {pressure={0.4, 0.05}, clip=-(RACK:grow(3)) - FG.all:grow(3) - CROSS:grow(3) - DECK - ARCH:grow(3)})
end
-- rivets along the inner rib
local rv = brush{kind="round", width=3, point=0.3}
local R = RINGS[4]
for i=1,#R.pts,2 do local p = R.pts[i]
  if p[2] < 550 and FG.all:at(p[1],p[2]) < 0.5 then rv:reload(pile{{"Mars orange",1},{"yellow ochre",0.6},{"lead white",0.3}}, 0.5); rv:touch(p[1], p[2], {pressure=0.5}) end
end
-- crate top lit by the mouth, the neck jack
local lip = brush{kind="round", width=4, point=0.8}
lip:reload(pile{{"Mars orange",1},{"cadmium yellow",0.6},{"burnt sienna",0.6}}, 0.6); lip:stroke({{318,623},{385,620},{452,619}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(1.6)}, clip=-FG.all})
lip:reload(pile{{"zinc white",2},{"cerulean blue",0.6}}, 0.6); lip:touch(397, 471, {pressure=0.5})

--@ chunk 17
local keep = RACK:grow(4) + FG.all:grow(4) + CROSS:grow(4) + DECK + ARCH:grow(4) + ellipse(FAB.x, FAB.y, FAB.rx+23, FAB.ry+19) + ellipse(813,530,20,24) + CL:grow(3)
local zone = (ellipse(500, 420, 470*1.3, 370*1.3) - keep)
blend(zone, {angle=function(x,y) return math.atan(y-FAB.y, x-FAB.x) end, tool={kind="badger", width=16}, pressure={0.2,0.35}})

--@ chunk 18
print(wait(3*24*60))
local F = FG.all:grow(1) + FG.crate:grow(1)
local FRONT = DECK * below(function(x) return 642 end) - F - ALT:grow(2)
-- shadows of the frame and crate falling toward us
local SH = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.4}}
local fs = poly({{316,716},{456,712},{520,716},{548,716},{600,810},{240,810}}, true) * FRONT
work(fs, {hand="body", pile=SH, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2, clip=fs, edge="soft"})
-- grating
local lip = brush{kind="round", width=4, point=0.5}
local g = pile{{"bone black",1.5},{"bone brown",1}}
local hi = pile{{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",0.4}}
for _,y in ipairs({668, 700, 742, 792}) do
  local w = 1 + (y-640)/50
  lip:reload(g, 0.6); lip:stroke({{-5,y},{500,y},{1005,y}}, {pressure={lip:pressure_for(w), lip:pressure_for(w)}, clip=FRONT - fs})
  lip:reload(hi, 0.5); lip:stroke({{150,y-w},{500,y-w},{850,y-w}}, {pressure={lip:pressure_for(w*0.4), lip:pressure_for(w*0.4)}, swell={0.1,1,0.1}, clip=FRONT - fs})
end
for _,x in ipairs({-600,-300,-60,150,350,550,760,980,1250}) do
  local x0 = lerp(500, x, (642-400)/(810-400))
  lip:reload(g, 0.6); lip:stroke({{x0,643},{x,810}}, {pressure={lip:pressure_for(1), lip:pressure_for(2.6)}, clip=FRONT - fs})
end
-- the lit lip of the platform edge
lip:reload(pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}, 0.6)
lip:stroke({{0,641},{300,640},{500,640},{700,640},{1000,641}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1.4)}, swell={0.3,1,1,1,0.3}, clip=-F - ALT:grow(2)})
