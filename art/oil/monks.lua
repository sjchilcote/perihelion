-- easel session "monks": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=4/3, linen={18,16}, seed=4141, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"raw sienna",3},{"burnt sienna",1.5},{"lead white",2},{"bone brown",0.6}}, um=30, apply="brush"}}}
function opening(x0, x1, spring, bot)
  local w = x1-x0
  return rect(x0, spring, w, bot-spring) + (ellipse((x0+x1)/2, spring, w/2, w*0.42) * above(function(x) return spring+1 end))
end
OP = opening(-40, 175, 250, 540) + opening(290, 690, 300, 540) + opening(805, 1050, 260, 540)
FLOOR = below(function(x) return 560 end)
WALL = everywhere() - OP - FLOOR
local WD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local FL = pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",0.6}}
local SILL = pile{{"burnt sienna",2},{"bone brown",1},{"yellow ochre",0.5}}
work(WALL, {hand="broad", pile=WD, coverage=3, fill=true, angle=math.pi/2, clip=WALL})
work(rect(0,540,1000,20), {hand="body", pile=SILL, coverage=3, fill=true, angle=0, tool="filbert 8", clip=rect(0,540,1000,20)})
work(FLOOR, {hand="broad", pile=FL, coverage=3, fill=true, angle=0.05, clip=FLOOR})
print(H)

--@ chunk 2
local VAULT = OP * above(function(x) return 235 end)
local FW = OP * below(function(x) return 235 end) * above(function(x) return 445 end)
local LAWN = OP * below(function(x) return 445 end)
work(VAULT, {hand="body", pile=pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.4}}, coverage=3, fill=true, tool="filbert 10", angle=0, clip=VAULT})
work(FW, {hand="body", pile=pile{{"yellow ochre",2},{"lead white",1},{"Mars orange",0.4},{"raw sienna",0.5}}, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2, clip=FW})
work(LAWN, {hand="body", pile=pile{{"yellow ochre",2},{"viridian",0.4},{"lead white",0.6},{"raw sienna",0.6}}, coverage=3, fill=true, tool="filbert 10", angle=0, clip=LAWN})

--@ chunk 3
local WD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
-- far arcade: arched slots, its own shade band under the vault
local slots = nil
for _,x in ipairs({30, 120, 330, 420, 560, 650, 850, 950}) do
  local s = rect(x-22, 285, 44, 160) + ellipse(x, 285, 22, 20)
  slots = slots and (slots+s) or s
end
slots = slots * OP
work(slots, {hand="body", pile=pile{{"burnt sienna",2},{"bone brown",0.8},{"Mars orange",0.5}}, coverage=3, fill=true, tool="filbert 5", angle=math.pi/2, clip=slots})
local band = OP * below(function(x) return 235 end) * above(function(x) return 262 end)
work(band, {hand="body", pile=pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",0.4}}, coverage=2.5, fill=true, tool="filbert 6", angle=0, clip=band})
-- pillar shadows thrown toward us across the walk floor
local s1 = poly({{175,560},{290,560},{160,750},{-60,750}})
local s2 = poly({{690,560},{805,560},{1060,750},{830,750}})
local sh = (s1 + s2):roughen(4, 40, 3) * FLOOR
work(sh, {hand="body", pile=WD, coverage=3, fill=true, tool="filbert 12", angle=0.05, clip=sh, edge="soft"})
-- the walk beyond the pools, deeper in shade at the edges
local edges = (rect(0,560,60,190) + rect(950,560,50,190)) * FLOOR
work(edges, {hand="body", pile=WD, coverage=2, tool="filbert 12", clip=FLOOR, edge="lost"})

--@ chunk 4
SUNC = {482, 222}
local glow = (ellipse(SUNC[1], SUNC[2], 60, 55) - ellipse(SUNC[1], SUNC[2], 18, 18)) * OP
stipple(glow, {pile=pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, width=2, pressure={0.3,0.6},
  coverage=function(x,y) local d=math.sqrt((x-SUNC[1])^2+(y-SUNC[2])^2) return 1.6*math.exp(-(d-18)/14) end, feather=0.5})
local core = ellipse(SUNC[1], SUNC[2], 18, 18)
work(core, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.3}}, coverage=4, fill=true, clip=core})
local b = brush{kind="round", width=2, point=1}
b:reload(pile{{"bone brown",2},{"bone black",1}}, 0.6); b:stroke({{482,122},{482,170},{482,204}}, {pressure={b:pressure_for(1),b:pressure_for(1)}})
-- warm pool on the lawn below it, and plantings
local pool = ellipse(482, 492, 170, 34):soften(10) * OP * below(function(x) return 446 end)
work(pool, {hand="body", pile=pile{{"yellow ochre",2},{"lead white",1.5},{"cadmium yellow",0.5}}, coverage=2.2, tool="filbert 8", angle=0, clip=OP})
local GA = math.pi*(3-math.sqrt(5))
local pl = brush{kind="filbert", width=7}
local GP = pile{{"viridian",1},{"yellow ochre",1},{"bone brown",0.4}}
for i=1,90 do
  local r = 22*math.sqrt(i); local a = i*GA
  local x, y = 482 + r*math.cos(a)*2.4, 492 + r*math.sin(a)*0.35
  if y > 452 and y < 535 and OP:at(x,y) > 0.5 then
    local s = 3 + (y-450)/16
    pl:reload(GP, 0.6); pl:touch(x, y, {pressure=clamp(s/8,0.3,0.9), drag={s*0.8,0}})
  end
end

--@ chunk 5
-- the Commando's frame, seated on the step, his back to us
CM = {}
CM.helm = ellipse(392, 402, 27, 30)
CM.neck = rect(380, 425, 24, 18)
CM.torso = poly({{344,452},{368,438},{392,436},{418,438},{442,452},{450,490},{446,530},{440,560},{348,560},{340,530},{336,490}}, true)
CM.larm = ribbon({{344,456},{332,492},{330,526},{334,548}}, {24,20,17,15})
CM.rarm = ribbon({{442,458},{458,492},{470,520},{486,540}}, {24,20,17,15})
CM.all = CM.helm + CM.neck + CM.torso + CM.larm + CM.rarm
local F = pile{{"bone brown",2},{"ultramarine blue",0.8},{"bone black",0.6},{"burnt sienna",0.4}}
work(CM.all, {hand="body", pile=F, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, edge="found", clip=CM.all:grow(1)})
-- the MIRIAD terminal propped against the pillar
TM = {}
TM.body = poly({{598,458},{676,444},{690,452},{694,566},{606,568},{600,540}})
TM.screen = poly({{610,466},{670,455},{674,530},{614,541}})
local TB = pile{{"ultramarine ash",1},{"bone black",1},{"burnt sienna",0.4},{"lead white",0.3}}
work(TM.body, {hand="body", pile=TB, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, edge="found", clip=TM.body})

--@ chunk 6
print(wait(3*24*60)); print(drying(392,480), drying(640,500), drying(480,600))
local F = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.8},{"bone brown",0.5}}
work(CM.all, {hand="body", pile=F, coverage=4, fill=true, tool="filbert 5", angle=math.pi/2, edge="found", clip=CM.all:grow(0.5)})
local TB = pile{{"bone black",1.5},{"ultramarine ash",1},{"burnt sienna",0.4}}
work(TM.body, {hand="body", pile=TB, coverage=4, fill=true, tool="filbert 5", angle=math.pi/2, edge="found", clip=TM.body})

--@ chunk 7
-- capelet
CAPE = poly({{346,452},{368,440},{392,438},{418,440},{442,452},{448,474},{446,500},{436,506},{426,498},{414,508},{402,500},{390,510},{378,500},{366,507},{354,498},{342,504},{338,476}}, true)
work(CAPE, {hand="body", pile=pile{{"rose madder",1.5},{"Mars red",1.5},{"bone black",0.3}}, coverage=4, fill=true, tool="filbert 4", angle=math.pi/2, clip=CAPE})
-- the screen: cold light, a flat-shaded field
local SC = pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.15}}
work(TM.screen, {hand="detail", pile=SC, coverage=4, fill=true, clip=TM.screen})

--@ chunk 8
print(wait(3*24*60)); print(drying(640,500), drying(392,470))
local SC = pile{{"zinc white",2.5},{"cerulean blue",1},{"cobalt blue",0.2}}
local s = TM.screen:shrink(1)
work(s, {hand="detail", pile=SC, coverage=5, fill=true, clip=s, load=1})
local CR = pile{{"rose madder",1.5},{"Mars red",1.5},{"vermilion",0.3},{"bone black",0.25}}
work(CAPE:shrink(0.8), {hand="body", pile=CR, coverage=4, fill=true, tool="filbert 4", angle=math.pi/2, clip=CAPE})
print(wait(2*24*60)); print(drying(640,500), drying(392,470))

--@ chunk 9
local S = TM.screen:shrink(1.5)
local HAIR = poly({{627,478},{636,470},{648,470},{656,479},{657,496},{660,522},{650,528},{642,512},{634,512},{626,528},{619,522},{623,496}})
local FACE = poly({{631,481},{640,477},{650,481},{652,491},{646,500},{640,502},{633,499},{629,491}})
local BODYA = poly({{634,503},{646,503},{652,526},{628,527}})
local ARM = ribbon({{648,506},{657,497},{664,486}}, {3.2,2.8,2.4}) + ellipse(665,484,2.4,2.4)
local ARM2 = ribbon({{633,507},{627,516},{626,522}}, {3,2.6,2.4})
local HB = pile{{"bone black",2},{"ultramarine blue",1}}
local SK = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.1}}
local DR = pile{{"zinc white",2},{"cobalt blue",0.6},{"cobalt violet",0.3}}
work(HAIR*S, {hand="detail", pile=HB, coverage=4, fill=true, clip=HAIR*S})
work((FACE)*S, {hand="detail", pile=SK, coverage=4, fill=true, clip=FACE})
work((BODYA+ARM+ARM2)*S - HAIR:shrink(100), {hand="detail", pile=DR, coverage=4, fill=true, clip=(BODYA+ARM+ARM2)})

--@ chunk 10
print(wait(4*24*60)); print(drying(640,490))
local HAIR = poly({{627,478},{636,470},{648,470},{656,479},{657,496},{660,522},{650,528},{642,512},{634,512},{626,528},{619,522},{623,496}})
local FACE = poly({{631,481},{640,477},{650,481},{652,491},{646,500},{640,502},{633,499},{629,491}})
local BODYA = poly({{634,503},{646,503},{652,526},{628,527}})
local ARM = ribbon({{648,506},{657,497},{664,486}}, {3.2,2.8,2.4}) + ellipse(665,484,2.4,2.4)
local ARM2 = ribbon({{633,507},{627,516},{626,522}}, {3,2.6,2.4})
local HB = pile{{"bone black",2.5},{"ultramarine blue",0.6}}
local SK = pile{{"lead white",3},{"rose madder",0.2},{"yellow ochre",0.1}}
local DR = pile{{"lead white",2},{"cobalt violet",0.5},{"cobalt blue",0.3}}
work(HAIR - FACE - BODYA, {hand="detail", pile=HB, coverage=5, fill=true, clip=HAIR - FACE - BODYA, load=1})
work(FACE, {hand="detail", pile=SK, coverage=5, fill=true, clip=FACE, load=1})
work(BODYA+ARM+ARM2, {hand="detail", pile=DR, coverage=5, fill=true, clip=BODYA+ARM+ARM2, load=1})
AV = {HAIR=HAIR, FACE=FACE}

--@ chunk 11
print(wait(2*24*60))
local b = brush{kind="round", width=1.6, point=1}
local K = pile{{"bone black",2},{"ultramarine blue",0.5}}
-- eyes, big and low, as the chibi kind are
for _,e in ipairs({{635,491},{645,491}}) do b:reload(K, 0.6); b:stroke({{e[1],e[2]-1.6},{e[1],e[2]+1.4}}, {pressure={0.9,0.9}}) end
-- one flat-shaded facet on the face, the low-poly tell
local facet = poly({{646,481},{650,481},{652,491},{646,500}})
work(facet, {hand="detail", pile=pile{{"lead white",2},{"rose madder",0.3},{"cobalt violet",0.2},{"yellow ochre",0.1}}, coverage=4, fill=true, clip=facet})
-- the session header and the Commando's red warning tag
local hdr = poly({{612,468},{670,457},{670,461},{612,472}})
work(hdr, {hand="detail", pile=pile{{"cobalt blue",1},{"ultramarine blue",1},{"bone black",0.3}}, coverage=4, fill=true, clip=hdr})
local tag = poly({{614,475},{630,472},{630,476},{614,479}})
work(tag, {hand="detail", pile=pile{{"vermilion",2},{"cadmium red",1}}, coverage=4, fill=true, clip=tag})
-- an asterisk by her raised hand: she is footnoting herself
local y = pile{{"cadmium yellow",1},{"lead white",1}}
for _,s in ipairs({{{666,474},{666,480}},{{663,475.5},{669,478.5}},{{663,478.5},{669,475.5}}}) do b:reload(K, 0.5); b:stroke(s, {pressure={0.7,0.7}}) end

--@ chunk 12
local lip = brush{kind="round", width=3, point=0.8}
local warm = pile{{"cadmium yellow",1},{"lead white",1.5},{"Mars orange",0.3}}
local cold = pile{{"zinc white",2},{"cerulean blue",1}}
-- the garth's light on his helmet and shoulders (it hangs up and to his right)
local pts = {} for i=0,14 do local a = -2.4 + 1.9*i/14; pts[#pts+1] = {392 + 26.5*math.cos(a), 402 + 29.5*math.sin(a)} end
lip:reload(warm, 0.7); lip:stroke(pts, {pressure={lip:pressure_for(0.6), lip:pressure_for(2.2)}, swell={0.4,1,1,0.6}})
lip:reload(warm, 0.6); lip:stroke({{400,437},{420,439},{438,449},{446,462}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.6)}})
lip:reload(warm, 0.5); lip:stroke({{362,441},{376,437},{388,436}}, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.2)}})
-- the screen's cold light along the inside of his right arm
lip:reload(cold, 0.6); lip:stroke({{456,478},{466,500},{476,520},{488,536}}, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.8)}})
-- the faded bone cross on the capelet
local bone = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.2}}
local c = brush{kind="round", width=4, point=0.4}
c:reload(bone, 0.4); c:stroke({{393,452},{393,470},{393,488}}, {pressure={c:pressure_for(3), c:pressure_for(2.6)}})
c:reload(bone, 0.35); c:stroke({{383,463},{393,463.5},{404,463}}, {pressure={c:pressure_for(2.6), c:pressure_for(2.6)}})
-- the jack cable, from his forearm sagging over the step's edge to the terminal port
local K = pile{{"bone black",2},{"ultramarine blue",0.6}}
local cab = brush{kind="round", width=4, point=0.3}
cab:reload(K, 0.8); cab:stroke({{486,542},{510,560},{545,571},{580,566},{604,552}}, {pressure={cab:pressure_for(2.6), cab:pressure_for(2.6)}})
lip:reload(warm, 0.4); lip:stroke({{512,559},{545,569},{578,564}}, {pressure={lip:pressure_for(0.7), lip:pressure_for(0.7)}})
-- the rosary, hanging from his left hand over the step
local bead = brush{kind="round", width=3.2, point=0}
local BB = pile{{"bone brown",2},{"burnt sienna",1}}
local y = 548
for i=1,9 do
  local x = 333 + 1.5*math.sin(i*0.9); y = y + 3.4
  bead:reload(BB, 0.6); bead:touch(x, y, {pressure=0.8})
end
lip:reload(warm, 0.5)
for i=1,9,2 do local x = 333 + 1.5*math.sin(i*0.9); lip:touch(x+0.8, 548+3.4*i-0.8, {pressure=0.2}) end
c:reload(BB, 0.7); c:stroke({{333,580},{333,592}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})
c:reload(BB, 0.7); c:stroke({{329,584},{337,584}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})

--@ chunk 13
-- the floor: bronze plates in perspective; the warm pool through the arch and the screen's cold pool
local VP = {482, 330}
local warm = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.8}}
local lit = poly({{300,562},{680,562},{820,750},{150,750}}):roughen(5,40,2) * FLOOR - poly({{175,560},{290,560},{160,750},{-60,750}}) - poly({{690,560},{805,560},{1060,750},{830,750}})
work(lit * above(function(x) return 660 end), {hand="scumble", pile=warm, coverage=1.6, load=0.45, angle=0.03, clip=lit})
local cool = ellipse(585, 590, 95, 20):soften(8) * FLOOR
work(cool, {hand="scumble", pile=pile{{"zinc white",1.5},{"cerulean blue",1},{"yellow ochre",0.3}}, coverage=1.4, load=0.35, angle=0, clip=FLOOR})
local seam = pile{{"bone brown",2},{"burnt sienna",1}}
local b = brush{kind="round", width=3, point=0.5}
for _,x in ipairs({-500,-250,-60,110,270,420,560,710,870,1060,1300}) do
  -- a seam from the step's edge running toward us, away from the vanishing point
  local x0 = lerp(VP[1], x, (562-VP[2])/(750-VP[2]))
  b:reload(seam, 0.6); b:stroke({{x0, 562},{x, 750}}, {pressure={b:pressure_for(0.8), b:pressure_for(1.8)}, clip=FLOOR - CM.all - TM.body})
end
for _,y in ipairs({585, 618, 664, 728}) do
  b:reload(seam, 0.6); b:stroke({{-5,y},{350,y+0.5},{700,y-0.5},{1005,y}}, {pressure={b:pressure_for(0.6+(y-560)/150), b:pressure_for(0.6+(y-560)/150)}, clip=FLOOR - CM.all - TM.body})
end

--@ chunk 14
local F = FLOOR - CM.all:grow(2) - TM.body:grow(2)
blend(rect(130, 630, 720, 60) * F, {angle=math.pi/2, pressure={0.3,0.5}})
blend(rect(180, 562, 640, 80) * F, {angle=0.0, pressure={0.25,0.4}})
blend(ellipse(585, 590, 115, 26) * F, {angle=0, pressure={0.3,0.5}})

--@ chunk 15
print(wait(3*24*60)); print(drying(480,600), drying(300,650))
local F = FLOOR - CM.all - TM.body
local s1 = poly({{175,560},{290,560},{160,750},{-60,750}}):roughen(3,40,3)
local s2 = poly({{690,560},{805,560},{1060,750},{830,750}}):roughen(3,40,4)
local lit = (FLOOR - s1 - s2) * rect(100,560,800,190)
local FL1 = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.6}}
local FL0 = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.5},{"Mars orange",0.3}}
local WD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
work(lit * F * below(function(x) return 615 end), {hand="body", pile=FL1, coverage=3, fill=true, tool="filbert 10", angle=0.02, clip=lit*F})
work(lit * F * above(function(x) return 625 end), {hand="body", pile=FL0, coverage=3, fill=true, tool="filbert 8", angle=0.02, clip=lit*F})
work((s1 + s2) * F * rect(0,560,1000,190), {hand="body", pile=WD, coverage=3, fill=true, tool="filbert 10", angle=0.05, clip=(s1+s2)*F})

--@ chunk 16
print(wait(3*24*60))
local F = FLOOR - CM.all - TM.body
local s1 = poly({{175,560},{290,560},{160,750},{-60,750}}):roughen(3,40,3)
local s2 = poly({{690,560},{805,560},{1060,750},{830,750}}):roughen(3,40,4)
local WD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local sides = (poly({{-10,560},{175,560},{-60,750},{-10,750}}) + poly({{805,560},{1010,560},{1010,750},{1060,750}})) * F
work(sides, {hand="body", pile=WD, coverage=3.5, fill=true, tool="filbert 12", angle=0.05, clip=sides})
-- the light nearest the arch is brightest
local near = poly({{290,562},{690,562},{730,620},{250,620}}) * F - s1 - s2
work(near, {hand="body", pile=pile{{"yellow ochre",2},{"lead white",1.2},{"cadmium yellow",0.4},{"Mars orange",0.2}}, coverage=3, fill=true, tool="filbert 8", angle=0.02, clip=near})

--@ chunk 17
print(wait(2*24*60))
local F = FLOOR - CM.all - TM.body
local s1 = poly({{175,560},{290,560},{160,750},{-60,750}}):roughen(3,40,3)
local s2 = poly({{690,560},{805,560},{1060,750},{830,750}}):roughen(3,40,4)
local lit = F - s1 - s2
local seam = lit * rect(0, 600, 1000, 40):roughen(6, 30, 9)
work(seam, {hand="scumble", pile=pile{{"yellow ochre",2},{"raw sienna",0.8},{"lead white",0.6}}, coverage=2, load=0.5, angle=0.02, clip=lit})
-- cast shadows of the frame and the terminal, toward us
local SHD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}}
local fs = poly({{338,562},{448,562},{470,640},{448,750},{300,750},{300,640}}, true):roughen(3,30,5) * F
work(fs, {hand="body", pile=SHD, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2+0.1, clip=fs, edge="soft"})
local ts = poly({{606,566},{694,566},{760,690},{790,750},{680,750},{640,690}}):roughen(3,30,6) * F
work(ts, {hand="body", pile=SHD, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2+0.4, clip=ts, edge="soft"})
-- the screen's cold light meeting the warm on the floor between them
local cold = poly({{470,565},{604,566},{600,600},{560,640},{490,630},{455,600}}, true):soften(6) * F - fs - ts
work(cold, {hand="scumble", pile=pile{{"zinc white",2},{"cerulean blue",1},{"yellow ochre",0.25}}, coverage=1.6, load=0.4, angle=0.6, clip=F})

--@ chunk 18
print(wait(3*24*60)); print(drying(100,610), drying(380,650), drying(520,580))
local F = FLOOR - CM.all - TM.body
local WD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local sides = (poly({{-10,560},{180,560},{-60,750},{-10,750}}) + poly({{800,560},{1010,560},{1010,750},{1060,750}})) * F
work(sides, {hand="body", pile=WD, coverage=4, fill=true, tool="filbert 10", angle=0.05, clip=sides})
-- the cast shadows warmed by the bounce from the lit floor: reflected light
local SB = pile{{"burnt sienna",2},{"bone brown",1},{"raw sienna",0.6}}
local fs = poly({{338,562},{448,562},{470,640},{448,750},{300,750},{300,640}}, true):roughen(3,30,5) * F
local ts = poly({{606,566},{694,566},{760,690},{790,750},{680,750},{640,690}}):roughen(3,30,6) * F
work((fs+ts):shrink(5), {hand="body", pile=SB, coverage=2.5, fill=true, tool="filbert 8", angle=math.pi/2+0.2, clip=(fs+ts):shrink(3)})
local cold = poly({{470,565},{604,566},{600,600},{560,640},{490,630},{455,600}}, true) * F
work(cold:shrink(2), {hand="scumble", pile=pile{{"yellow ochre",1.2},{"cerulean blue",0.8},{"lead white",0.6},{"raw sienna",0.3}}, coverage=1.5, load=0.4, angle=0.5, clip=cold})

--@ chunk 19
print(wait(2*24*60))
local F = FLOOR - CM.all - TM.body
local s1 = poly({{180,560},{292,560},{160,750},{-60,750}})
local s2 = poly({{688,560},{800,560},{1060,750},{830,750}})
local lit = (F - s1 - s2) * rect(140,560,720,190)
local A = pile{{"yellow ochre",2},{"lead white",1.2},{"cadmium yellow",0.3},{"Mars orange",0.2}}
local B = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.5},{"Mars orange",0.2}}
local C = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.5}}
work(lit * below(function(x) return 615 end), {hand="body", pile=A, coverage=3, fill=true, tool="filbert 10", angle=0.02, clip=lit})
work(lit * above(function(x) return 615 end) * below(function(x) return 680 end), {hand="body", pile=B, coverage=3, fill=true, tool="filbert 10", angle=0.02, clip=lit})
work(lit * above(function(x) return 680 end), {hand="body", pile=C, coverage=3, fill=true, tool="filbert 12", angle=0.02, clip=lit})
-- cast shadows, straight-sided as the light is one small source behind them
local SHD = pile{{"burnt sienna",2},{"bone brown",1.4},{"ultramarine blue",0.3}}
FS = poly({{340,562},{446,562},{462,750},{318,750}}) * lit
TS = poly({{608,566},{692,566},{772,750},{660,750}}) * lit
work(FS + TS, {hand="body", pile=SHD, coverage=3, fill=true, tool="filbert 8", angle=math.pi/2, clip=FS+TS, edge="firm"})
-- the cold of the screen, a short pale-blue tongue along the step between them
COLD = poly({{462,563},{606,566},{620,590},{560,600},{476,590}}, true) * lit - FS - TS
work(COLD, {hand="body", pile=pile{{"lead white",2},{"cerulean blue",0.8},{"yellow ochre",0.5}}, coverage=2.5, fill=true, tool="filbert 6", angle=0.02, clip=COLD})

--@ chunk 20
print(wait(3*24*60)); print(drying(500,640), drying(380,640))
local F = FLOOR - CM.all - TM.body
local VP = {482, 330}
local seam = pile{{"bone brown",2},{"burnt sienna",1}}
local b = brush{kind="round", width=3, point=0.5}
for _,x in ipairs({-400,-150,40,215,370,520,660,810,980,1200}) do
  local x0 = lerp(VP[1], x, (562-VP[2])/(750-VP[2]))
  b:reload(seam, 0.6); b:stroke({{x0, 563},{x, 750}}, {pressure={b:pressure_for(0.7), b:pressure_for(1.6)}, clip=F})
end
for _,y in ipairs({588, 622, 668, 732}) do
  local w = 0.6+(y-560)/160
  b:reload(seam, 0.6); b:stroke({{-5,y},{350,y+0.5},{700,y-0.5},{1005,y}}, {pressure={b:pressure_for(w), b:pressure_for(w)}, clip=F})
end
-- glints on plate edges in the light
local g = pile{{"lead white",2},{"cadmium yellow",0.6}}
local lit = F - FS - TS - poly({{180,560},{292,560},{160,750},{-60,750}}) - poly({{688,560},{800,560},{1060,750},{830,750}})
for _,y in ipairs({588, 622, 668}) do
  b:reload(g, 0.5); b:stroke({{280,y-1.5},{420,y-1.5}}, {pressure={b:pressure_for(0.7), b:pressure_for(0.4)}, clip=lit})
  b:reload(g, 0.5); b:stroke({{480,y-1.5},{640,y-1.5}}, {pressure={b:pressure_for(0.6), b:pressure_for(0.5)}, clip=lit})
end
-- restate the cable and the rosary over the new floor
local K = pile{{"bone black",2},{"ultramarine blue",0.6}}
local cab = brush{kind="round", width=4, point=0.3}
cab:reload(K, 0.8); cab:stroke({{486,542},{506,558},{540,572},{578,568},{604,553}}, {pressure={cab:pressure_for(2.6), cab:pressure_for(2.6)}})
local lip = brush{kind="round", width=3, point=0.8}
lip:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.4); lip:stroke({{545,570},{578,566},{598,556}}, {pressure={lip:pressure_for(0.7), lip:pressure_for(0.5)}})
local bead = brush{kind="round", width=3.2, point=0}
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.5}}
for i=1,9 do local x = 333 + 1.5*math.sin(i*0.9); bead:reload(BB, 0.6); bead:touch(x, 548+3.4*i, {pressure=0.8}) end
local c = brush{kind="round", width=4, point=0.4}
c:reload(BB, 0.7); c:stroke({{333,580},{333,593}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})
c:reload(BB, 0.7); c:stroke({{328.5,584},{337.5,584}}, {pressure={c:pressure_for(1.6), c:pressure_for(1.6)}})
local warm = pile{{"cadmium yellow",1},{"lead white",1.5}}
for i=1,9,2 do local x = 333 + 1.5*math.sin(i*0.9); lip:reload(warm, 0.4); lip:touch(x+0.9, 548+3.4*i-0.9, {pressure=0.2}) end
-- more cold on the floor tongue
work(COLD:shrink(3), {hand="scumble", pile=pile{{"zinc white",2},{"cerulean blue",1}}, coverage=1.2, load=0.35, angle=0.02, clip=COLD})

--@ chunk 21
print(wait(3*24*60))
local F = FLOOR - CM.all - TM.body
local reg = (COLD:grow(6) * F) - FS - TS
local A = pile{{"yellow ochre",2},{"lead white",1.2},{"cadmium yellow",0.3},{"Mars orange",0.2}}
work(reg, {hand="body", pile=A, coverage=3.5, fill=true, tool="filbert 6", angle=0.02, clip=reg})
local CP = pile{{"zinc white",2},{"cerulean blue",0.8},{"lead white",0.5}}
stipple(reg, {pile=CP, width=2.5, pressure={0.3,0.6}, cluster={0.3,6},
  coverage=function(x,y) local d = math.sqrt(((x-606)/1.6)^2 + ((y-566)*2.2)^2); return 1.4*math.exp(-d/45) end, feather=0.6})

--@ chunk 22
local F = FLOOR - CM.all - TM.body - FS - TS
local reg = (COLD:grow(6) * F)
blend((reg:grow(8) - reg:shrink(8)) * F, {angle=0.02, tool={kind="badger", width=12}, pressure={0.3,0.5}})
print(wait(3*24*60))
local CP = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt blue",0.2}}
local b = brush{kind="filbert", width=4}
for i=1,26 do
  local a = math.pi*(0.55 + 0.4*rand(0,1))
  local len = rand(25, 90)
  local x0, y0 = 600 + rand(-6,4), 566 + rand(0,3)
  b:reload(CP, 0.35)
  b:stroke({{x0, y0},{x0 + math.cos(a)*len*1.6, y0 + math.sin(a)*len*0.35}}, {pressure={0.35, 0.02}, clip=F})
end

--@ chunk 23
print(wait(2*24*60))
local F = FLOOR - CM.all - TM.body
local K = pile{{"bone black",2},{"ultramarine blue",0.6}}
local cab = brush{kind="round", width=4, point=0.3}
cab:reload(K, 0.9); cab:stroke({{486,542},{506,558},{540,571},{578,568},{604,554}}, {pressure={cab:pressure_for(2.8), cab:pressure_for(2.8)}})
local lip = brush{kind="round", width=3, point=0.8}
lip:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.5); lip:stroke({{550,569},{580,566},{599,557}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(0.5)}})
lip:reload(pile{{"cadmium yellow",1},{"lead white",1.5}}, 0.5); lip:stroke({{508,557},{530,566}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(0.5)}})
local VP = {482, 330}
local seam = pile{{"bone brown",2},{"burnt sienna",1}}
local b = brush{kind="round", width=3, point=0.5}
local reg = COLD:grow(14) * F
for _,x in ipairs({370,520,660}) do
  local x0 = lerp(VP[1], x, (562-VP[2])/(750-VP[2]))
  b:reload(seam, 0.6); b:stroke({{x0, 563},{x, 750}}, {pressure={b:pressure_for(0.7), b:pressure_for(1.6)}, clip=reg})
end
b:reload(seam, 0.6); b:stroke({{400,588},{700,588}}, {pressure={b:pressure_for(0.8), b:pressure_for(0.8)}, clip=reg})
-- the niche in the left pillar, his lamp and his scrap-metal cross
NICHE = rect(214, 320, 40, 60) + ellipse(234, 320, 20, 16)
work(NICHE, {hand="detail", pile=pile{{"burnt sienna",1.5},{"Mars orange",1},{"bone brown",0.6}}, coverage=4, fill=true, clip=NICHE})
local sill = rect(208, 378, 52, 6)
work(sill, {hand="detail", pile=pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.5}}, coverage=4, fill=true, clip=sill})

--@ chunk 24
print(wait(2*24*60))
local K = pile{{"bone black",1.5},{"bone brown",1}}
local b = brush{kind="round", width=4, point=0.4}
b:reload(K, 0.8); b:stroke({{234,334},{234,352},{235,372}}, {pressure={b:pressure_for(3), b:pressure_for(2.6)}})
b:reload(K, 0.8); b:stroke({{224,343},{234,344},{245,342}}, {pressure={b:pressure_for(2.4), b:pressure_for(2.4)}})
local fl = brush{kind="round", width=3, point=1}
fl:reload(pile{{"lead white",2},{"cadmium yellow",1}}, 0.7); fl:stroke({{240,376},{240,370},{240.5,364}}, {pressure={fl:pressure_for(2.6), 0}})
local lip = brush{kind="round", width=3, point=0.8}
lip:reload(pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.8}}, 0.5); lip:stroke({{226,341},{233,340}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(0.5)}})
-- warm light on the reveals of the arch openings, the garth side
local warm = pile{{"Mars orange",1},{"yellow ochre",1},{"burnt sienna",0.7}}
local rv = brush{kind="filbert", width=6}
for _,s in ipairs({{{175,250},{175,540}}, {{290,300},{290,540}}, {{690,300},{690,540}}, {{805,260},{805,540}}}) do
  local x = s[1][1]; local side = (x==175 or x==690) and 1 or -1
  rv:reload(warm, 0.6)
  rv:stroke({{x+side*4, s[1][2]},{x+side*4, s[2][2]}}, {pressure={0.6,0.6}, clip=WALL})
end
local arc = {} for i=0,30 do local a = math.pi + math.pi*i/30; arc[#arc+1] = {490 + 205*math.cos(a), 300 + 172*math.sin(a)} end
rv:reload(warm, 0.6); rv:stroke(arc, {pressure={0.6,0.6}, clip=WALL})

--@ chunk 25
-- warm light thrown up from the lit floor onto his back and the terminal's face
local lip = brush{kind="round", width=5, point=0.6}
local bronze = pile{{"burnt sienna",1.5},{"Mars orange",1},{"yellow ochre",0.6}}
local dull = pile{{"burnt sienna",1.5},{"bone brown",1},{"Mars orange",0.4}}
local back = (CM.torso - CAPE):shrink(3)
-- plate seams across the lower back, lit from below
for _,y in ipairs({518, 536, 552}) do
  lip:reload(bronze, 0.5); lip:stroke({{350,y},{370,y+2},{393,y+3},{418,y+2},{438,y}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(1.6)}, swell={0.2,1,1,1,0.2}, clip=back})
end
lip:reload(dull, 0.5); lip:stroke({{393,512},{393,556}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.2)}, clip=back})
-- elbow and forearm joints
lip:reload(bronze, 0.5); lip:stroke({{448,492},{462,488}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1)}})
lip:reload(bronze, 0.5); lip:stroke({{325,492},{340,494}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1)}})
lip:reload(bronze, 0.5); lip:stroke({{326,500},{326,520},{329,544}}, {pressure={lip:pressure_for(1.3), lip:pressure_for(0.6)}})
-- the back of the helmet: a seam and a cold edge where her screen reaches it
lip:reload(dull, 0.5); lip:stroke({{372,396},{392,392},{412,396}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.2)}})
lip:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.5)
local pts = {} for i=0,8 do local a = 0.15 + 0.9*i/8; pts[#pts+1] = {392 + 26*math.cos(a), 402 + 29*math.sin(a)} end
lip:stroke(pts, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.4)}, swell={0.3,1,1,0.4}})
-- the terminal's casing: a lit top edge from the garth, battered corner
lip:reload(pile{{"cadmium yellow",1},{"lead white",1.2},{"Mars orange",0.3}}, 0.5)
lip:stroke({{600,459},{640,451},{676,445}}, {pressure={lip:pressure_for(1.4), lip:pressure_for(1.6)}})
lip:reload(bronze, 0.5); lip:stroke({{676,446},{690,452}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(0.8)}})
lip:reload(dull, 0.5); lip:stroke({{690,456},{692,520},{694,562}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.2)}})

--@ chunk 26
-- the rosary's tail lying on the lit step
local bead = brush{kind="round", width=3.2, point=0}
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.6}}
local warm = pile{{"cadmium yellow",1},{"lead white",1.5}}
local lip = brush{kind="round", width=3, point=0.8}
local pts = {}
for i=0,10 do local t=i/10; pts[#pts+1] = {333 - 22*t + 4*math.sin(t*3), 582 + 10*t - 6*t*t} end
for i,p in ipairs(pts) do bead:reload(BB, 0.6); bead:touch(p[1], p[2], {pressure=0.8}) end
for i=1,#pts,2 do lip:reload(warm, 0.4); lip:touch(pts[i][1]+0.8, pts[i][2]-0.8, {pressure=0.2}) end
-- the frieze of fold-notation over the arches, in worn bone
local bone = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.25}}
local b = brush{kind="round", width=3, point=0.6}
local function glyph(cx, cy, r, n, rot, depth)
  local phi = (1+math.sqrt(5))/2
  for d=0,depth-1 do
    local rr = r / phi^d; local ro = rot + d*2*math.pi/n/phi
    local p = {}
    for k=0,n do local a = ro + 2*math.pi*k/n; p[#p+1] = {cx + rr*math.cos(a), cy + rr*0.8*math.sin(a)} end
    b:reload(bone, 0.5); b:stroke(p, {pressure={b:pressure_for(1.6-0.3*d), b:pressure_for(1.6-0.3*d)}})
  end
end
local gs = {{60,70,3},{150,72,4},{350,62,5},{490,58,6},{630,62,5},{830,72,4},{935,70,3}}
for i,g in ipairs(gs) do glyph(g[1], g[2], 24, g[3], -math.pi/2 + i*0.3, 3) end
for i=1,#gs-1 do
  local a, c = gs[i], gs[i+1]
  local m = {(a[1]+c[1])/2, (a[2]+c[2])/2 + 22}
  b:reload(bone, 0.4); b:stroke({{a[1]+24, a[2]+4}, m, {c[1]-24, c[2]+4}}, {pressure={b:pressure_for(1.1), b:pressure_for(1.1)}})
end

--@ chunk 27
print(wait(2*24*60))
local core = ellipse(SUNC[1], SUNC[2], 16, 16)
work(core, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.6},{"cadmium yellow",0.2}}, coverage=5, fill=true, clip=core, load=1})
local ring = (ellipse(SUNC[1], SUNC[2], 19, 19) - core)
work(ring, {hand="detail", pile=pile{{"cadmium yellow",1.5},{"Mars orange",0.5},{"lead white",1}}, coverage=4, fill=true, clip=ring})
local glow = (ellipse(SUNC[1], SUNC[2], 70, 62) - ellipse(SUNC[1], SUNC[2], 19, 19)) * OP
stipple(glow, {pile=pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}, width=2, pressure={0.3,0.6},
  coverage=function(x,y) local d=math.sqrt((x-SUNC[1])^2+(y-SUNC[2])^2) return 2.2*math.exp(-(d-19)/12) end, feather=0.5})

--@ chunk 28
local band = ellipse(SUNC[1], SUNC[2], 24, 24) - ellipse(SUNC[1], SUNC[2], 13, 13)
blend(band, {angle=function(x,y) return math.atan(y-SUNC[2], x-SUNC[1]) end, tool={kind="badger", width=6}, pressure={0.3,0.5}})

--@ chunk 29
local LAWN = OP * below(function(x) return 447 end) * above(function(x) return 538 end) - CM.all - TM.body
local GA = math.pi*(3-math.sqrt(5))
local pl = brush{kind="filbert", width=6}
local GP = pile{{"viridian",1},{"yellow ochre",1},{"bone brown",0.5}}
local GT = pile{{"yellow ochre",1.5},{"lemon chrome",0.3},{"lead white",0.6},{"viridian",0.2}}
for i=1,260 do
  local r = 14*math.sqrt(i); local a = i*GA
  local x, y = 482 + r*math.cos(a)*2.6, 480 + r*math.sin(a)*0.33
  if LAWN:at(x,y) > 0.5 then
    local s = 2.5 + (y-447)/12
    pl:reload(GP, 0.6); pl:touch(x, y, {pressure=clamp(s/7,0.3,0.9), drag={s,0}})
    pl:reload(GT, 0.4); pl:touch(x-0.5, y-s*0.35, {pressure=clamp(s/14,0.2,0.5), drag={s*0.6,0}})
  end
end

--@ chunk 30
print(type(WALL),type(NICHE),type(CM),type(SUNC),type(CAPE),type(TM))

--@ chunk 31
-- the wall and pillars as bronze: dark vault above, warming toward the arches, lit reveals
local keep = (NICHE:grow(4) + TM.body:grow(3) + rect(206,376,56,10))
local W = WALL * above(function(x) return 538 end) - keep
local top = W * above(function(x) return 150 end)
local mid = W * below(function(x) return 150 end) * above(function(x) return 300 end)
local low = W * below(function(x) return 300 end)
local V0 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.5},{"burnt sienna",0.4}}
local V1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local V2 = pile{{"burnt sienna",2},{"bone brown",0.8},{"raw sienna",0.6}}
work(top:roughen(8,60,1), {hand="broad", pile=V0, coverage=3, fill=true, angle=0.05, clip=W})
work(mid:roughen(8,60,2), {hand="body", pile=V1, coverage=3, fill=true, angle=0.05, tool="filbert 12", clip=W})
work(low, {hand="body", pile=V2, coverage=3, fill=true, angle=math.pi/2, tool="filbert 10", clip=W})
-- lit sides of each pillar toward the garth light (it sits in the middle bay)
local L = pile{{"raw sienna",2},{"Mars orange",0.8},{"yellow ochre",0.6}}
local lit = (rect(266,250,24,288) + rect(690,300,22,238) + rect(152,250,23,288) + rect(805,260,20,278)) * W
work(lit, {hand="body", pile=L, coverage=3, fill=true, angle=math.pi/2, tool="filbert 6", clip=lit})
for _,s in ipairs({{120,170},{140,310}}) do
  blend(W * below(function(x) return s[1]-12 end) * above(function(x) return s[1]+12 end), {angle=0, tool={kind="badger", width=20}, pressure={0.25,0.4}})
end
blend(W * below(function(x) return 288 end) * above(function(x) return 312 end), {angle=0, tool={kind="badger", width=20}, pressure={0.25,0.4}})

--@ chunk 32
print(wait(3*24*60)); print(drying(50,60), drying(230,450))
local V1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local tops = (rect(262,240,32,45) + rect(686,290,30,40) + rect(148,240,31,40) + rect(801,250,28,40)) * WALL
work(tops, {hand="scumble", pile=V1, coverage=1.6, load=0.45, angle=math.pi/2, clip=tops})
-- the arch reveals, restated along the curves
local warm = pile{{"Mars orange",1},{"yellow ochre",1},{"burnt sienna",0.6}}
local rv = brush{kind="filbert", width=5}
local function arc(cx, spring, r, ry)
  local p = {} for i=0,30 do local a = math.pi + math.pi*i/30; p[#p+1] = {cx + r*math.cos(a), spring + ry*math.sin(a)} end
  rv:reload(warm, 0.6); rv:stroke(p, {pressure={0.55,0.55}, clip=WALL})
end
arc(490, 300, 203, 170); arc(67.5, 250, 110, 92); arc(927.5, 260, 125, 105)

-- fold-notation frieze, recut: straight-edged room-glyphs, each holding a turned inset at 0.618
local bone = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.25}}
local b = brush{kind="round", width=3, point=0.6}
local phi = 0.618
local function edge(p, q, w)
  b:reload(bone, 0.55)
  b:stroke({p, {lerp(p[1],q[1],0.5), lerp(p[2],q[2],0.5)}, q}, {pressure={b:pressure_for(w), b:pressure_for(w*0.9)}, ramps={0.05,0.1}})
end
local function poly_(cx, cy, r, n, rot, sx, w)
  local pts = {}
  for k=0,n-1 do local a = rot + 2*math.pi*k/n; pts[#pts+1] = {cx + r*sx*math.cos(a), cy + r*math.sin(a)} end
  for k=1,n do edge(pts[k], pts[k % n + 1], w) end
  return pts
end
local function glyph(cx, cy, r, n, twist, sx, depth)
  local rot = -math.pi/2
  local outer
  for d=0,depth-1 do
    local p = poly_(cx, cy, r*phi^d, n, rot + d*twist, sx, 2.0 - 0.45*d)
    if d == 0 then outer = p end
  end
  return outer
end
-- glyphs over the pillars and arch crowns; twist differs per room
GLY = {
  {x=70,  y=72, r=26, n=3, tw=0.35, sx=1.1},
  {x=215, y=78, r=24, n=4, tw=0.0,  sx=1.3},
  {x=350, y=68, r=27, n=5, tw=0.6,  sx=1.0},
  {x=490, y=64, r=30, n=6, tw=2.4,  sx=1.0},
  {x=630, y=68, r=27, n=5, tw=0.25, sx=1.0},
  {x=750, y=78, r=24, n=4, tw=0.785,sx=1.6},
  {x=920, y=72, r=26, n=3, tw=-0.5, sx=1.1},
}
for _,g in ipairs(GLY) do glyph(g.x, g.y, g.r, g.n, g.tw, g.sx, 3) end
-- bridges: arcs from edge to edge, with notches
for i=1,#GLY-1 do
  local a, c = GLY[i], GLY[i+1]
  local p0 = {a.x + a.r*a.sx*0.9, a.y + 8}
  local p1 = {c.x - c.r*c.sx*0.9, c.y + 8}
  local m = {(p0[1]+p1[1])/2, math.max(p0[2],p1[2]) + 20}
  b:reload(bone, 0.45); b:stroke({p0, m, p1}, {pressure={b:pressure_for(1.2), b:pressure_for(1.2)}})
  for t=1,(i%3)+1 do
    local x = p0[1] + 4 + t*3.2
    b:reload(bone, 0.45); b:stroke({{x, p0[2]-3},{x, p0[2]+3}}, {pressure={b:pressure_for(1), b:pressure_for(1)}})
  end
end
-- one self-gluing over the middle glyph: an arc leaving and returning
b:reload(bone, 0.45); b:stroke({{475,38},{490,18},{505,38}}, {pressure={b:pressure_for(1.2), b:pressure_for(1.2)}})

--@ chunk 33
-- the Commando: plates on back and shoulders, warm rim from the garth, cold rim from the screen
local F = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.8}}
local P = pile{{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.8},{"lead white",0.15}}
local warm = pile{{"cadmium yellow",1},{"lead white",1.5},{"Mars orange",0.4}}
local bronze = pile{{"burnt sienna",1.5},{"Mars orange",1},{"yellow ochre",0.6}}
local cold = pile{{"zinc white",2},{"cerulean blue",1}}
local lip = brush{kind="round", width=5, point=0.7}
-- pauldrons: overlapping curved plates on each shoulder
local function pauld(cx, cy, dir)
  for k=0,2 do
    local y = cy + k*9
    local m = ellipse(cx + dir*k*2, y, 17 - k*2, 7)
    work(m, {hand="detail", pile=P, coverage=4, fill=true, clip=m})
    local arc = {} for i=0,10 do local a = math.pi*(1.05 + 0.9*i/10); arc[#arc+1] = {cx + dir*k*2 + (17-k*2)*math.cos(a), y + 7*math.sin(a)} end
    lip:reload(dir < 0 and warm or bronze, 0.5); lip:stroke(arc, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.4)}, swell={0.4,1,1,0.5}})
  end
end
pauld(346, 452, -1)
pauld(442, 454, 1)
-- back plates below the capelet: a spine ridge and overlapping horizontal plates
local back = (CM.torso - CAPE):shrink(2.5)
for k,y in ipairs({512, 528, 544}) do
  local m = poly({{346,y-2},{392,y-6},{440,y-2},{438,y+12},{392,y+9},{348,y+12}}) * back
  work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m})
end
print(wait(24*60))
for k,y in ipairs({512, 528, 544}) do
  lip:reload(bronze, 0.5); lip:stroke({{350,y-1},{372,y-4},{392,y-5},{414,y-4},{436,y-1}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(1.2)}, swell={0.2,1,1,1,0.2}, clip=back})
end
-- warm rim from the garth along the top silhouette
lip:reload(warm, 0.6); lip:stroke({{338,470},{340,458},{348,446}}, {pressure={lip:pressure_for(0.6), lip:pressure_for(1.6)}})
lip:reload(warm, 0.6); lip:stroke({{437,446},{446,456},{450,470}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.6)}})
-- cold rim from the screen down the right side: arm, flank
lip:reload(cold, 0.6); lip:stroke({{448,470},{451,500},{448,530},{444,556}}, {pressure={lip:pressure_for(1.6), lip:pressure_for(0.6)}})
lip:reload(cold, 0.6); lip:stroke({{458,462},{468,486},{478,510},{490,532}}, {pressure={lip:pressure_for(0.8), lip:pressure_for(1.6)}})

--@ chunk 34
print(wait(3*24*60))
local P = pile{{"bone black",1.5},{"bone brown",1},{"burnt sienna",0.8},{"ultramarine blue",0.4}}
local back = (CM.torso - CAPE):shrink(2.5)
local m = nil
for k,y in ipairs({512, 528, 544}) do
  local q = poly({{346,y-2},{392,y-6},{440,y-2},{438,y+12},{392,y+9},{348,y+12}}) * back
  m = m and (m+q) or q
end
for _,c in ipairs({{346,452,-1},{442,454,1}}) do
  for k=0,2 do local e = ellipse(c[1] + c[3]*k*2, c[2] + k*9, 17-k*2, 7); m = m + e end
end
work(m, {hand="detail", pile=P, coverage=5, fill=true, clip=m, load=1})
print(wait(3*24*60))
local warm = pile{{"cadmium yellow",1},{"lead white",1.5},{"Mars orange",0.4}}
local bronze = pile{{"burnt sienna",1.5},{"Mars orange",1},{"yellow ochre",0.6}}
local cold = pile{{"zinc white",2},{"cerulean blue",1}}
local lip = brush{kind="round", width=4, point=0.8}
for _,c in ipairs({{346,452,-1},{442,454,1}}) do
  for k=0,2 do
    local cx, cy, r = c[1] + c[3]*k*2, c[2] + k*9, 17-k*2
    local arc = {} for i=0,10 do local a = math.pi*(1.08 + 0.84*i/10); arc[#arc+1] = {cx + r*math.cos(a), cy + 7*math.sin(a)} end
    lip:reload(k == 0 and warm or bronze, 0.55); lip:stroke(arc, {pressure={lip:pressure_for(0.5), lip:pressure_for(1.3)}, swell={0.4,1,1,0.5}})
    if c[3] > 0 then
      lip:reload(cold, 0.5); lip:stroke({{cx + r*0.75, cy+1},{cx + r*0.98, cy+4}}, {pressure={lip:pressure_for(1.2), lip:pressure_for(0.5)}})
    end
  end
end
for k,y in ipairs({512, 528, 544}) do
  lip:reload(bronze, 0.5); lip:stroke({{350,y-1},{372,y-4},{392,y-5},{414,y-4},{436,y-1}}, {pressure={lip:pressure_for(1.1), lip:pressure_for(1.1)}, swell={0.2,1,1,1,0.2}})
  lip:reload(cold, 0.5); lip:stroke({{426,y-2},{437,y}}, {pressure={lip:pressure_for(1.1), lip:pressure_for(0.5)}})
end
lip:reload(bronze, 0.4); lip:stroke({{393,510},{393,556}}, {pressure={lip:pressure_for(1), lip:pressure_for(1)}})

--@ chunk 35
-- the hanging sun: lose the ring in a soft glow
local cx, cy = SUNC[1], SUNC[2]
local G1 = pile{{"lead white",2},{"cadmium yellow",0.8},{"lemon chrome",0.3}}
local G2 = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1.2},{"burnt sienna",0.3}}
local ring = ellipse(cx, cy, 26, 26) - ellipse(cx, cy, 12, 12)
work(ring, {hand="detail", pile=G1, coverage=4, fill=true, clip=ring})
local halo = (ellipse(cx, cy, 48, 44) - ellipse(cx, cy, 24, 24)) * OP
work(halo, {hand="scumble", pile=G2, coverage=1.6, load=0.3, angle=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end, clip=OP})
blend(ellipse(cx, cy, 52, 48) * OP, {angle=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end, tool={kind="badger", width=10}, pressure={0.25,0.45}})
local core = ellipse(cx, cy, 11, 11)
work(core, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.4}}, coverage=5, fill=true, clip=core})

--@ chunk 36
local cx, cy = SUNC[1], SUNC[2]
local tan = function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end
local rad = function(x,y) return math.atan(y-cy,x-cx) end
local A = (ellipse(cx, cy, 46, 44) - ellipse(cx, cy, 32, 32)) * OP
local B = (ellipse(cx, cy, 60, 56) - ellipse(cx, cy, 42, 40)) * OP
local M1 = pile{{"Mars orange",1.2},{"yellow ochre",1},{"burnt sienna",0.8}}
local M2 = pile{{"burnt sienna",2},{"bone brown",0.6},{"Mars orange",0.6}}
local over = OP * below(function(x) return 236 end) -- the far frieze band below keeps its own colour
work(A * above(function(x) return 236 end), {hand="detail", pile=M1, coverage=3, fill=true, clip=A})
work(B * above(function(x) return 236 end), {hand="detail", pile=M2, coverage=3, fill=true, clip=B})
local lowA = (A + B) * over
work(lowA, {hand="detail", pile=pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.5}}, coverage=3, fill=true, clip=lowA})
blend((ellipse(cx, cy, 64, 60) - ellipse(cx, cy, 16, 16)) * OP, {angle=rad, tool={kind="badger", width=14}, pressure={0.3,0.5}})
blend((ellipse(cx, cy, 64, 60) - ellipse(cx, cy, 16, 16)) * OP, {angle=tan, tool={kind="badger", width=14}, pressure={0.25,0.4}})

--@ chunk 37
print(wait(4*24*60))
local cx, cy = SUNC[1], SUNC[2]
local disc = ellipse(cx, cy, 66, 62) * OP
local up = disc * above(function(x) return 236 end)
local dn = disc * below(function(x) return 236 end)
local V = pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.4}}
local FB = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",0.6}}
work(up, {hand="detail", pile=V, coverage=4, fill=true, clip=up, load=1})
work(dn, {hand="detail", pile=FB, coverage=4, fill=true, clip=dn, load=1})
print(wait(3*24*60))
-- the glow as touches thinning outward, and a white core with no edge colour
local glow = (ellipse(cx, cy, 80, 72) - ellipse(cx, cy, 10, 10)) * OP
stipple(glow, {pile=pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.2}}, width=2.4, pressure={0.3,0.6},
  coverage=function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2) return 3.2*math.exp(-(d-10)/13) end, feather=0.6})
stipple(ellipse(cx, cy, 24, 24), {pile=pile{{"zinc white",3},{"lemon chrome",0.4}}, width=2, pressure={0.4,0.7},
  coverage=function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2) return 4*math.exp(-math.max(0,d-9)/5) end, feather=0.6})
local core = ellipse(cx, cy, 10, 10)
work(core, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.25}}, coverage=5, fill=true, clip=core})

--@ chunk 38
local cx, cy = SUNC[1], SUNC[2]
local disc = ellipse(cx, cy, 68, 64) * OP * below(function(x) return 236 end)
local band = disc * above(function(x) return 262 end)
local slots = (rect(398, 285, 44, 160) + ellipse(420, 285, 22, 20)) * disc
local fw = disc - band - slots
work(band, {hand="detail", pile=pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",0.4},{"yellow ochre",0.6}}, coverage=4, fill=true, clip=band})
work(fw, {hand="detail", pile=pile{{"yellow ochre",2},{"lead white",1},{"Mars orange",0.4},{"raw sienna",0.5}}, coverage=4, fill=true, clip=fw})
work(slots, {hand="detail", pile=pile{{"burnt sienna",2},{"bone brown",0.8},{"Mars orange",0.5}}, coverage=4, fill=true, clip=slots})
print(wait(2*24*60))
stipple(disc, {pile=pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.2}}, width=2.4, pressure={0.3,0.6},
  coverage=function(x,y) local d=math.sqrt((x-cx)^2+(y-cy)^2) return 3.2*math.exp(-(d-10)/13) end, feather=0.6})
local b = brush{kind="round", width=2, point=1}
b:reload(pile{{"bone brown",2},{"bone black",1}}, 0.6); b:stroke({{482,122},{482,170},{482,208}}, {pressure={b:pressure_for(1),b:pressure_for(0.8)}})

--@ chunk 39
-- garth plantings: golden-angle clumps, larger toward us
local LAWN = OP * below(function(x) return 449 end) * above(function(x) return 538 end) - CM.all:grow(2) - TM.body:grow(2)
local GA = math.pi*(3-math.sqrt(5))
local GP = pile{{"viridian",1},{"yellow ochre",1},{"bone brown",0.6}}
local GT = pile{{"yellow ochre",1.5},{"lemon chrome",0.3},{"lead white",0.6},{"viridian",0.2}}
local leaf = brush{kind="filbert", width=5}
local centres = {{60,500},{125,470},{330,512},{560,490},{640,515},{850,505},{945,475},{410,470},{210,522}}
for ci,c in ipairs(centres) do
  local s = 0.6 + (c[2]-450)/80
  for i=1,13 do
    local r = 3.2*s*math.sqrt(i); local a = i*GA + ci
    local x, y = c[1] + r*math.cos(a)*1.4, c[2] + r*math.sin(a)*0.55
    if LAWN:at(x,y) > 0.5 then
      leaf:reload(GP, 0.6); leaf:touch(x, y, {pressure=clamp(0.4+0.4*s,0.3,0.95), drag={4*s, -0.3}})
    end
  end
  for i=1,13,2 do
    local r = 3.2*s*math.sqrt(i); local a = i*GA + ci
    local x, y = c[1] + r*math.cos(a)*1.4, c[2] + r*math.sin(a)*0.55 - 2*s
    if LAWN:at(x,y) > 0.5 then leaf:reload(GT, 0.4); leaf:touch(x, y, {pressure=clamp(0.25*s,0.2,0.5), drag={3*s,-0.3}}) end
  end
end

--@ chunk 40
-- garth plantings: golden-angle clumps, larger toward us
local LAWN = OP * below(function(x) return 449 end) * above(function(x) return 538 end) - CM.all:grow(2) - TM.body:grow(2)
local GA = math.pi*(3-math.sqrt(5))
local GP = pile{{"viridian",1},{"yellow ochre",1},{"bone brown",0.6}}
local GT = pile{{"yellow ochre",1.5},{"lemon chrome",0.3},{"lead white",0.6},{"viridian",0.2}}
local leaf = brush{kind="filbert", width=5}
local centres = {{60,500},{125,470},{330,512},{560,490},{640,515},{850,505},{945,475},{410,470},{210,522}}
for ci,c in ipairs(centres) do
  local s = 1.5 + (c[2]-450)/40
  for i=1,21 do
    local r = 3.2*s*math.sqrt(i); local a = i*GA + ci
    local x, y = c[1] + r*math.cos(a)*1.4, c[2] + r*math.sin(a)*0.55
    if LAWN:at(x,y) > 0.5 then
      leaf:reload(GP, 0.6); leaf:touch(x, y, {pressure=clamp(0.4+0.4*s,0.3,0.95), drag={4*s, -0.3}})
    end
  end
  for i=1,21,2 do
    local r = 3.2*s*math.sqrt(i); local a = i*GA + ci
    local x, y = c[1] + r*math.cos(a)*1.4, c[2] + r*math.sin(a)*0.55 - 2*s
    if LAWN:at(x,y) > 0.5 then leaf:reload(GT, 0.4); leaf:touch(x, y, {pressure=clamp(0.25*s,0.2,0.5), drag={3*s,-0.3}}) end
  end
end
local V0 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.5},{"burnt sienna",0.4}}
local gh = (ellipse(150,72,22,18) + ellipse(830,72,22,18) + ellipse(1000,75,10,10)) - ellipse(215,78,36,28) - ellipse(750,78,42,28) - ellipse(920,72,32,28)
gh = gh - ribbon({{100,80},{150,100},{190,86}}, 5) - ribbon({{790,86},{835,100},{890,80}}, 5)
work(gh, {hand="detail", pile=V0, coverage=3, fill=true, clip=gh, load=0.8})

--@ chunk 41
print(wait(2*24*60))
local LAWN = OP * below(function(x) return 452 end) * above(function(x) return 538 end) - CM.all:grow(2) - TM.body:grow(2)
local GA = math.pi*(3-math.sqrt(5))
local D = pile{{"viridian",1},{"bone brown",0.8},{"yellow ochre",0.6}}
local M = pile{{"viridian",1},{"yellow ochre",1.2},{"raw sienna",0.3}}
local T = pile{{"yellow ochre",1.5},{"lemon chrome",0.4},{"lead white",0.8},{"viridian",0.2}}
local centres = {{60,505},{140,478},{330,515},{565,492},{640,520},{860,508},{948,480},{410,474},{215,524},{770,470}}
for ci,c in ipairs(centres) do
  local s = 0.7 + (c[2]-450)/50
  local b = brush{kind="filbert", width=4*s+2}
  local pts = {}
  for i=1,8 do local r = 3*s*math.sqrt(i); local a = i*GA + ci; pts[#pts+1] = {c[1] + r*math.cos(a)*1.5, c[2] + r*math.sin(a)*0.5} end
  for _,p in ipairs(pts) do if LAWN:at(p[1],p[2]) > 0.5 then b:reload(D, 0.7); b:touch(p[1], p[2]+1.5*s, {pressure=0.7, drag={3*s,0}, clip=LAWN}) end end
  for _,p in ipairs(pts) do if LAWN:at(p[1],p[2]) > 0.5 then b:reload(M, 0.6); b:touch(p[1], p[2], {pressure=0.55, drag={2.5*s,0}, clip=LAWN}) end end
  for k,p in ipairs(pts) do if k%2==1 and LAWN:at(p[1],p[2]) > 0.5 then b:reload(T, 0.5); b:touch(p[1]-s, p[2]-1.5*s, {pressure=0.3, drag={2*s,0}, clip=LAWN}) end end
end
