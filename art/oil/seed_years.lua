-- easel session "seed_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.25, linen={18,16}, seed=7474, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"burnt sienna",3},{"bone brown",2},{"lead white",1},{"ultramarine blue",0.4}}, um=30, apply="brush"}}}
VP = {500, 400}
FAB = {x=500, y=455, rx=95, ry=78}
-- the things that will be pale, kept off the wet hull
COVER = poly({{50,140},{110,140},{122,160},{140,200},{128,206},{112,180},{112,250},{100,330},{86,330},{80,262},{74,330},{60,330},{48,250},{48,180},{32,206},{20,200},{38,160}}, true)
TABLET = rect(166, 168, 40, 56)
PAPER = poly({{648,300},{716,296},{720,352},{652,356}})
PILLOW = ellipse(424, 604, 26, 13)
PALES = COVER + TABLET + PAPER + PILLOW
local H0 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.5}}
local H1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local H2 = pile{{"burnt sienna",2},{"Mars orange",0.6},{"bone brown",0.6}}
local d = function(x,y) return math.sqrt(((x-FAB.x)/1.25)^2 + (y-FAB.y)^2) end
local outer = mask(function(x,y) return d(x,y) > 330 and 1 or 0 end):roughen(15,80,1) - PALES
local midr = mask(function(x,y) local v=d(x,y) return (v > 190 and v <= 340) and 1 or 0 end):roughen(12,70,2) - PALES
local inner = mask(function(x,y) return d(x,y) <= 200 and 1 or 0 end) - PALES
local rad = function(x,y) return math.atan(y-VP[2], x-VP[1]) + math.pi/2 end
work(outer, {hand="broad", pile=H0, coverage=3, fill=true, angle=rad, clip=outer})
work(midr, {hand="broad", pile=H1, coverage=3, fill=true, angle=rad, clip=midr})
work(inner, {hand="body", pile=H2, coverage=3, fill=true, angle=rad, tool="filbert 14", clip=inner})
print(W,H)

--@ chunk 2
local d = function(x,y) return math.sqrt(((x-FAB.x)/1.25)^2 + (y-FAB.y)^2) end
local tan = function(x,y) return math.atan(y-FAB.y, x-FAB.x) + math.pi/2 end
for _,r in ipairs({200, 335}) do
  local band = mask(function(x,y) local v=d(x,y) return math.abs(v-r) < 26 and 1 or 0 end) - PALES:grow(6)
  blend(band, {angle=tan, tool={kind="badger", width=24}, pressure={0.3,0.5}})
end
-- ribs
RINGS = {}
local m = nil
for k,s in ipairs({1.3, 1.02, 0.8, 0.62}) do
  local pts, ws = {}, {}
  for i=0,64 do local a = 2*math.pi*i/64; pts[#pts+1] = {500 + 470*s*math.cos(a), 420 + 370*s*math.sin(a)}; ws[#ws+1] = 34*s end
  RINGS[k] = {s=s, pts=pts}
  local r = ribbon(pts, ws); m = m and (m+r) or r
end
DECK = poly({{-10,640},{1010,640},{1010,810},{-10,810}}) + poly({{170,560},{830,560},{1010,650},{-10,650}})
RIBM = m - DECK - PALES
work(RIBM, {hand="body", pile=pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.6}}, coverage=3.5, fill=true, tool="filbert 10", angle=function(x,y) return math.atan(y-420,x-500)+math.pi/2 end, clip=RIBM})

--@ chunk 3
print(wait(2*24*60))
function F(m, p) work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
-- figures
CRATE = poly({{396,622},{566,618},{570,714},{392,718}})
BLANK = poly({{396,606},{430,596},{470,584},{500,576},{530,582},{556,596},{568,612},{566,632},{396,636}}, true)
CHILD = ellipse(432, 594, 12, 11)    -- the sleeping child's head on the pillow
SF = {}
SF.head = ellipse(300, 470, 24, 26)
SF.torso = poly({{252,490},{292,482},{318,500},{330,540},{324,600},{304,652},{252,652},{240,600},{238,530}}, true)
SF.legs = poly({{236,640},{372,630},{392,656},{386,688},{252,700},{228,680}}, true)
SF.arm = ribbon({{306,506},{326,556},{350,598}}, {18,15,13})
SF.hand = ellipse(356, 602, 11, 9)
SFALL = SF.head + SF.torso + SF.legs + SF.arm + SF.hand
CROSS = poly({{842,440},{856,438},{858,476},{884,474},{885,488},{858,490},{860,560},{846,562},{844,492},{818,494},{817,480},{843,478}})
ALT = poly({{790,600},{904,596},{908,668},{788,672}})
CL = poly({{784,566},{906,562},{910,604},{898,598},{886,612},{872,600},{856,614},{840,602},{822,616},{806,604},{786,612}}, true)
CND = rect(808, 532, 10, 30)
RAIL = ribbon({{-10,100},{120,108},{240,122}}, 10)
OBJ = SFALL + CRATE + BLANK + PILLOW + CHILD + CROSS + ALT + CL + CND + PALES + RAIL
-- the deck, around everything
local D = DECK - OBJ
local TOP = poly({{170,560},{830,560},{1010,650},{-10,650}}) * D * above(function(x) return 641 end)
local FRONT = D * below(function(x) return 641 end)
local mid = TOP * mask(function(x,y) local k = (y-560)/90; return math.abs(x-500) < 240 + 200*k and 1 or 0 end)
work(TOP - mid, {hand="body", pile=pile{{"burnt sienna",2},{"Mars orange",0.4},{"bone brown",0.7}}, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=TOP})
work(mid, {hand="body", pile=pile{{"Mars orange",1.3},{"cadmium yellow",0.3},{"burnt sienna",1}}, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=TOP})
work(FRONT * above(function(x) return 700 end), {hand="body", pile=pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.3}}, coverage=3.5, fill=true, tool="filbert 12", angle=0, clip=FRONT})
work(FRONT * below(function(x) return 700 end), {hand="broad", pile=pile{{"bone brown",2},{"bone black",0.6},{"ultramarine blue",0.4}}, coverage=3.5, fill=true, angle=0, clip=FRONT})
-- the fabricator mouth, banked low: a deep orange throat with a small glow low in it
local collar = ellipse(FAB.x, FAB.y, FAB.rx+22, FAB.ry+18) - OBJ
local mouth = ellipse(FAB.x, FAB.y, FAB.rx, FAB.ry) - OBJ
F(collar - mouth, pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}})
local core = ellipse(FAB.x, FAB.y+40, FAB.rx*0.5, FAB.ry*0.25) * mouth
work(mouth - core, {hand="body", pile=pile{{"Mars red",1},{"Mars orange",1},{"burnt sienna",0.8}}, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=mouth - core})
work(core, {hand="body", pile=pile{{"cadmium yellow",1.2},{"Mars orange",1},{"lead white",0.5}}, coverage=3.5, fill=true, tool="filbert 5", angle=0, clip=core})

--@ chunk 4
-- the darks: the frame, the crate, rail, cross, altar, child's hair
local FR = pile{{"bone black",2},{"ultramarine blue",0.7},{"burnt sienna",0.7}}
F(SFALL, FR)
F(CRATE, pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.5}})
F(RAIL, FR)
F(CROSS, pile{{"bone black",1.5},{"bone brown",1},{"burnt sienna",0.6}})
F(ALT - CL, pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.5}})
F(CL, pile{{"rose madder",1.5},{"Mars red",1.5},{"bone black",0.35}})
F(CHILD, pile{{"bone black",1.6},{"burnt sienna",0.6}})
F(BLANK, pile{{"Mars red",1},{"rose madder",0.6},{"burnt sienna",0.6}})   -- a red blanket, the old rag's colour
-- hooks and strings on the rail
local r = brush{kind="round", width=3, point=0.6}
r:reload(FR, 0.7); r:stroke({{80,106},{80,140}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
r:reload(FR, 0.7); r:stroke({{186,118},{172,168}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
r:reload(FR, 0.7); r:stroke({{186,118},{200,168}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})

--@ chunk 5
print(wait(4*24*60))
F(COVER, pile{{"cerulean blue",0.6},{"lead white",1.6},{"yellow ochre",0.3}})
F(TABLET, pile{{"lead white",2.2},{"yellow ochre",0.5},{"raw sienna",0.1}})
F(PAPER, pile{{"lead white",2.6},{"yellow ochre",0.2}})
F(PILLOW, pile{{"lead white",2.3},{"yellow ochre",0.4},{"Mars orange",0.1}})
F(CND, pile{{"lead white",2},{"yellow ochre",0.5}})
-- the frame's plates: a warm edge from the fabricator glow on his front, seams
local r = brush{kind="round", width=4, point=0.8}
local W = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local K = pile{{"bone black",2},{"ultramarine blue",0.5}}
r:reload(W, 0.6); r:stroke({{314,452},{324,470},{322,490}}, {pressure={r:pressure_for(1), r:pressure_for(2.2)}})
r:reload(W, 0.6); r:stroke({{318,502},{330,540},{324,598},{306,648}}, {pressure={r:pressure_for(2.2), r:pressure_for(1)}})
r:reload(W, 0.6); r:stroke({{330,560},{348,594}}, {pressure={r:pressure_for(1.6), r:pressure_for(1)}})
r:reload(W, 0.6); r:stroke({{300,636},{372,630},{390,654}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(W, 0.5); r:stroke({{394,620},{480,618},{566,618}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}, clip=CRATE:grow(2)})
for _,s in ipairs({{{250,540},{320,536}},{{246,590},{322,586}},{{290,486},{294,520}}}) do r:reload(pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone brown",0.6}}, 0.5); r:stroke(s, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}}) end
-- visor slit with the one cold optic, looking down at the child
local sl = poly({{290,470},{322,466},{322,474},{290,478}})
F(sl, K)
r:reload(pile{{"cerulean blue",1},{"zinc white",1}}, 0.8); r:touch(314, 471, {pressure=0.35})
-- the rosary hanging from his gauntlet
local bead = brush{kind="round", width=4, point=0}
for i=1,8 do bead:reload(pile{{"bone brown",2},{"burnt sienna",1}}, 0.7); bead:touch(358 + 1.5*math.sin(i), 610 + i*4.5, {pressure=0.8}) end
local c = brush{kind="round", width=3, point=0.4}
c:reload(pile{{"bone brown",2},{"burnt sienna",1}}, 0.8); c:stroke({{359,648},{359,660}}, {pressure={c:pressure_for(2), c:pressure_for(2)}})
c:reload(pile{{"bone brown",2},{"burnt sienna",1}}, 0.8); c:stroke({{354,652},{364,652}}, {pressure={c:pressure_for(2), c:pressure_for(2)}})

--@ chunk 6
print(wait(3*24*60))
local r = brush{kind="round", width=4, point=0.8}
local W = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
-- the crayon drawing: the big knight in red and grey, a sun, a small figure, the child's hand
local cr = brush{kind="round", width=3, point=0.3}
local function C(p, pts, w) cr:reload(p, 0.6); cr:stroke(pts, {pressure={cr:pressure_for(w), cr:pressure_for(w)}, clip=PAPER:shrink(2)}) end
C(pile{{"ultramarine ash",1},{"bone black",0.3}}, {{676,316},{670,326},{676,336},{684,326},{676,316}}, 2)  -- helm
C(pile{{"cadmium red",1}}, {{668,332},{666,346},{688,346},{686,332},{668,332}}, 2.5)                     -- tabard
C(pile{{"cadmium red",1}}, {{672,338},{684,338}}, 3)
C(pile{{"ultramarine ash",1},{"bone black",0.3}}, {{670,346},{668,352}}, 2); C(pile{{"ultramarine ash",1},{"bone black",0.3}}, {{684,346},{686,352}}, 2)
C(pile{{"bone black",1.5}}, {{700,334},{700,348}}, 2); C(pile{{"bone black",1.5}}, {{700,334},{702,334}}, 3)   -- the little one
C(pile{{"cadmium yellow",1},{"Mars orange",0.5}}, {{704,306},{708,310},{704,314},{700,310},{704,306}}, 2.5) -- sun
r:reload(pile{{"lead white",2},{"yellow ochre",0.6}}, 0.4); r:stroke({{644,298},{660,304}}, {pressure={r:pressure_for(4), r:pressure_for(4)}})  -- tape
r:reload(pile{{"lead white",2},{"yellow ochre",0.6}}, 0.4); r:stroke({{708,296},{724,302}}, {pressure={r:pressure_for(4), r:pressure_for(4)}})
-- the bone tablet's marks, the coverall's seams and a red patch on its knee
for _,y in ipairs({182,192,202,212}) do r:reload(pile{{"burnt sienna",1},{"bone brown",0.6}}, 0.5); r:stroke({{172,y},{198,y}}, {pressure={r:pressure_for(1), r:pressure_for(1)}}) end
r:reload(pile{{"ultramarine ash",1},{"lead white",0.6}}, 0.6); r:stroke({{80,146},{80,250}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
local patch = rect(86, 280, 12, 12); F(patch, pile{{"cadmium red",1},{"lead white",0.4}})
-- the child's blanket: folds and the glow on its top, and the sleeping face's edge
r:reload(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.4}}, 0.6); r:stroke({{440,594},{480,580},{520,578},{556,594}}, {pressure={r:pressure_for(2), r:pressure_for(2.5)}, clip=BLANK})
r:reload(pile{{"rose madder",1},{"bone black",0.6}}, 0.6); r:stroke({{480,592},{486,630}}, {pressure={r:pressure_for(2), r:pressure_for(3)}, clip=BLANK})
r:reload(pile{{"rose madder",1},{"bone black",0.6}}, 0.6); r:stroke({{530,594},{524,630}}, {pressure={r:pressure_for(2), r:pressure_for(3)}, clip=BLANK})
r:reload(pile{{"lead white",2.4},{"rose madder",0.2},{"yellow ochre",0.15}}, 0.6); r:stroke({{440,590},{443,598}}, {pressure={r:pressure_for(2.5), r:pressure_for(2)}})
-- candle flame and its glow; cross edge
local fl = brush{kind="round", width=3, point=1}
fl:reload(pile{{"zinc white",2},{"lemon chrome",0.6}}, 0.7); fl:stroke({{813,531},{813,524},{813.5,517}}, {pressure={fl:pressure_for(3), 0}})
stipple(ellipse(813, 524, 36, 32) - CND - CROSS, {pile=pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, width=2, pressure={0.3,0.5},
  coverage=function(x,y) local d=math.sqrt((x-813)^2+(y-524)^2) return 2*math.exp(-d/9) end, feather=0.6})
r:reload(W, 0.6); r:stroke({{843,480},{844,520},{846,560}}, {pressure={r:pressure_for(1.4), r:pressure_for(1)}})
-- the rail's lit top, rivets on the inner rib
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6}}, 0.5); r:stroke({{0,96},{120,104},{240,118}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})

--@ chunk 7
print(wait(3*24*60))
F(COVER - rect(86,280,12,12), pile{{"cerulean blue",0.6},{"lead white",1},{"yellow ochre",0.4},{"bone brown",0.35}})
F(TABLET, pile{{"lead white",1.6},{"yellow ochre",0.6},{"raw sienna",0.2},{"bone brown",0.15}})
-- the deck's back edge cleaned where the old exclusion left grit
local strip = poly({{40,600},{250,586},{250,640},{0,640},{0,620}}) - SFALL:grow(2)
F(strip, pile{{"burnt sienna",2},{"Mars orange",0.4},{"bone brown",0.7}})

--@ chunk 8
print(wait(3*24*60))
local r = brush{kind="round", width=4, point=0.8}
for _,y in ipairs({182,192,202,212}) do r:reload(pile{{"burnt sienna",1},{"bone brown",0.6}}, 0.5); r:stroke({{172,y},{198,y}}, {pressure={r:pressure_for(1), r:pressure_for(1)}}) end
r:reload(pile{{"ultramarine ash",1},{"bone brown",0.4}}, 0.6); r:stroke({{80,146},{80,250}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
local bead = brush{kind="round", width=6, point=0}
local BH = pile{{"yellow ochre",1},{"Mars orange",0.6},{"lead white",0.6}}
for i=1,8 do bead:reload(BH, 0.6); bead:touch(358 + 1.5*math.sin(i), 610 + i*4.5, {pressure=0.6}) end
local c = brush{kind="round", width=3, point=0.4}
c:reload(BH, 0.8); c:stroke({{359,648},{359,662}}, {pressure={c:pressure_for(2.5), c:pressure_for(2.5)}})
c:reload(BH, 0.8); c:stroke({{353,652},{365,652}}, {pressure={c:pressure_for(2.5), c:pressure_for(2.5)}})
-- the low glow reaching the child and the frame's bowed helm
r:reload(pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}, 0.6); r:stroke({{404,600},{424,592},{446,596}}, {pressure={r:pressure_for(1.4), r:pressure_for(1)}})
r:reload(pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}, 0.6); r:stroke({{322,450},{325,466}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
