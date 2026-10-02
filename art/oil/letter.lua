-- easel session "letter": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=4/3, linen={18,16}, seed=3131, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"bone brown",3},{"burnt sienna",1},{"lead white",1},{"ultramarine blue",0.6}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
-- big value shapes: dark cabin, warm pool around the reader, cold wash from the strip at upper left
WALLM = rect(0,0,1000,470) + rect(0,470,1000,150) 
FLOORM = rect(0,620,1000,130)
BUNK = poly({{0,440},{430,452},{440,560},{430,640},{0,640}})
DESK = poly({{440,500},{860,494},{872,536},{446,546}})
local W0 = pile{{"bone brown",2},{"ultramarine blue",0.8},{"bone black",0.6}}
local W1 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
local WC = pile{{"bone brown",1.5},{"ultramarine blue",1},{"bone black",0.3},{"lead white",0.25}}
local wall = rect(0,0,1000,640) - BUNK - DESK
local warm = ellipse(640, 470, 330, 230):roughen(20,100,2) * wall
local cold = poly({{0,0},{560,0},{420,250},{0,420}}):roughen(20,100,3) * wall - warm
work(wall - warm - cold, {hand="broad", pile=W0, coverage=3, fill=true, angle=math.pi/2, clip=wall})
work(cold, {hand="broad", pile=WC, coverage=3, fill=true, angle=math.pi/2, clip=wall})
work(warm, {hand="body", pile=W1, coverage=3, fill=true, angle=math.pi/2, tool="filbert 12", clip=wall})
work(FLOORM - BUNK, {hand="broad", pile=pile{{"bone black",1.5},{"bone brown",1.5},{"ultramarine blue",0.4}}, coverage=3, fill=true, angle=0, clip=FLOORM - BUNK})

--@ chunk 3
-- bunk: frame, mattress edge, rumpled blanket; desk slab, bracket
FRAME = poly({{0,560},{436,556},{440,640},{0,644}})
BLANK = poly({{0,446},{90,436},{170,452},{240,440},{330,458},{428,456},{438,500},{430,560},{340,572},{250,562},{150,576},{60,566},{0,570}}, true)
PILLOW = poly({{8,420},{110,412},{140,440},{120,462},{14,466}}, true)
local K = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.5}}
work(FRAME, {hand="body", pile=K, coverage=3.5, fill=true, tool="filbert 10", angle=0, clip=FRAME})
local BL = pile{{"bone brown",1},{"ultramarine ash",1},{"bone black",0.6},{"viridian",0.15}}
work(BLANK, {hand="body", pile=BL, coverage=3.5, fill=true, tool="filbert 10", angle=0.1, clip=BLANK})
work(PILLOW, {hand="body", pile=pile{{"ultramarine ash",1},{"bone brown",0.8},{"lead white",0.3}}, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=PILLOW})
local DK = pile{{"bone black",1},{"burnt sienna",1},{"bone brown",1}}
work(DESK, {hand="body", pile=DK, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=DESK})
BRK = poly({{760,546},{780,546},{800,620},{786,620}}) + poly({{490,546},{508,546},{470,620},{456,620}})
work(BRK, {hand="detail", pile=K, coverage=4, fill=true, clip=BRK})
-- the wall seam: bulkhead panels
local r = brush{kind="round", width=4, point=0.5}
for _,x in ipairs({470, 900}) do r:reload(K, 0.6); r:stroke({{x,0},{x,500}}, {pressure={r:pressure_for(2.5), r:pressure_for(2.5)}, clip=-(BUNK+DESK)}) end
r:reload(K, 0.6); r:stroke({{0,190},{1000,170}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})

--@ chunk 4
print(wait(2*24*60))
local wall = rect(0,0,1000,622) - BUNK - DESK - BRK - PILLOW - BLANK - FRAME
local W0 = pile{{"bone black",1.2},{"bone brown",1.5},{"ultramarine blue",0.5}}
local W1 = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.3}}
local W2 = pile{{"burnt sienna",1.5},{"bone brown",1},{"Mars orange",0.4}}
local WC = pile{{"bone black",1},{"ultramarine ash",1},{"bone brown",0.8},{"cerulean blue",0.15}}
local warm1 = ellipse(630, 470, 260, 190):roughen(15,90,4) * wall
local warm2 = ellipse(630, 480, 150, 110):roughen(10,70,5) * wall
local cold = poly({{0,30},{520,30},{380,200},{0,330}}):roughen(15,90,6) * wall
work(wall - warm1 - cold, {hand="broad", pile=W0, coverage=3.5, fill=true, angle=math.pi/2, clip=wall})
work(cold - warm1, {hand="body", pile=WC, coverage=3.5, fill=true, tool="filbert 14", angle=math.pi/2, clip=wall})
work(warm1 - warm2, {hand="body", pile=W1, coverage=3.5, fill=true, tool="filbert 12", angle=math.pi/2, clip=wall})
work(warm2, {hand="body", pile=W2, coverage=3.5, fill=true, tool="filbert 10", angle=math.pi/2, clip=wall})
blend((warm1:grow(25) - warm1:shrink(25)) * wall, {angle=math.pi/2, tool={kind="badger", width=24}, pressure={0.35,0.55}})
blend((warm2:grow(18) - warm2:shrink(18)) * wall, {angle=math.pi/2, tool={kind="badger", width=18}, pressure={0.3,0.5}})
blend((cold:grow(25) - cold:shrink(25)) * wall - warm1, {angle=math.pi/2, tool={kind="badger", width=24}, pressure={0.35,0.55}})

--@ chunk 5
-- soften the glow's rings with an in-between tone scumbled across each boundary
local wall = rect(0,0,1000,622) - BUNK - DESK - BRK - PILLOW - BLANK - FRAME
local T1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
local T2 = pile{{"burnt sienna",1.5},{"bone brown",1.2}}
local e1 = ellipse(630, 470, 260, 190)
local e2 = ellipse(630, 480, 150, 110)
work((e1:grow(30) - e1:shrink(40)) * wall, {hand="scumble", pile=T1, coverage=2, load=0.45, angle=function(x,y) return math.atan(y-470,x-630) end, clip=wall})
work((e2:grow(25) - e2:shrink(30)) * wall, {hand="scumble", pile=T2, coverage=2, load=0.45, angle=function(x,y) return math.atan(y-480,x-630) end, clip=wall})
-- objects, as darks first
local K = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.4}}
READER = poly({{560,452},{690,440},{700,500},{570,512}})
SCREEN = poly({{572,456},{680,446},{688,494},{580,504}})
work(READER, {hand="detail", pile=K, coverage=4, fill=true, clip=READER})
PHOTO = poly({{566,236},{684,230},{688,318},{570,326}})
work(PHOTO, {hand="detail", pile=pile{{"bone brown",1},{"yellow ochre",0.6},{"bone black",0.4}}, coverage=4, fill=true, clip=PHOTO})
MUG = poly({{480,462},{522,460},{520,506},{484,508}}, true)
work(MUG, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine ash",0.8},{"bone black",0.3}}, coverage=4, fill=true, clip=MUG})
local handle = ribbon({{522,470},{536,476},{536,492},{521,496}}, 4)
work(handle, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine ash",0.8},{"bone black",0.3}}, coverage=4, fill=true, clip=handle})
POT = poly({{752,470},{796,470},{790,500},{758,500}})
work(POT, {hand="detail", pile=pile{{"burnt sienna",1.2},{"bone brown",1},{"Mars red",0.2}}, coverage=4, fill=true, clip=POT})
SLIP = poly({{290,672},{352,664},{366,684},{300,694}}, true) + poly({{360,684},{424,676},{436,698},{370,706}}, true)
work(SLIP, {hand="detail", pile=pile{{"bone brown",1},{"Mars red",0.5},{"ultramarine ash",0.3}}, coverage=4, fill=true, clip=SLIP})
-- the gauntlet entering from the right edge, resting on the desk's lip
GAUNT = poly({{1000,430},{930,436},{880,460},{846,486},{836,506},{850,520},{900,516},{940,500},{1000,500}}, true)
work(GAUNT, {hand="body", pile=pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}, coverage=4, fill=true, tool="filbert 5", clip=GAUNT})

--@ chunk 6
print(wait(2*24*60))
OBJ = (READER + PHOTO + MUG + POT + GAUNT + BRK + DESK + BUNK + PILLOW + BLANK + FRAME):grow(1)
local wall = rect(0,0,1000,622) - OBJ
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local W1 = pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.4}}
local W2 = pile{{"burnt sienna",1.5},{"bone brown",1},{"Mars orange",0.3}}
local core = ellipse(630, 470, 110, 80):roughen(8,50,9)
local mid = ellipse(630, 470, 200, 150):roughen(12,70,10)
work(wall - mid, {hand="body", pile=W0, coverage=3.5, fill=true, tool="filbert 12", angle=math.pi/2, clip=wall})
work((mid - core) * wall, {hand="body", pile=W1, coverage=3.5, fill=true, tool="filbert 10", angle=math.pi/2, clip=wall})
work(core * wall, {hand="body", pile=W2, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2, clip=wall})
local ang = function(x,y) return math.atan(y-470, x-630) + math.pi/2 end
blend((mid:grow(30) - mid:shrink(30)) * wall, {angle=ang, tool={kind="badger", width=20}, pressure={0.4,0.6}})
blend((core:grow(22) - core:shrink(22)) * wall, {angle=ang, tool={kind="badger", width=16}, pressure={0.4,0.6}})
-- floor dark again, with the warm only under the desk
local fl = rect(0,620,1000,130) - OBJ - SLIP
work(fl, {hand="body", pile=pile{{"bone black",1.6},{"bone brown",1.4},{"ultramarine blue",0.4}}, coverage=3.5, fill=true, tool="filbert 14", angle=0, clip=fl})

--@ chunk 7
print(wait(2*24*60))
-- slippers darker, worn
work(SLIP, {hand="detail", pile=pile{{"bone brown",1.4},{"Mars red",0.4},{"bone black",0.5}}, coverage=4, fill=true, clip=SLIP})
-- the photo: a sunlit beach from home, flat simple bands and a few figures
local ph = PHOTO:shrink(4)
local SKY = pile{{"cerulean blue",1},{"lead white",1.5},{"yellow ochre",0.2}}
local SEA = pile{{"cobalt blue",1},{"cerulean blue",0.6},{"lead white",0.6}}
local SAND = pile{{"yellow ochre",1.2},{"lead white",1.2},{"Mars orange",0.15}}
work(ph * rect(560,230,140,40), {hand="detail", pile=SKY, coverage=4, fill=true, clip=ph})
work(ph * rect(560,270,140,16), {hand="detail", pile=SEA, coverage=4, fill=true, clip=ph})
work(ph * rect(560,286,140,40), {hand="detail", pile=SAND, coverage=4, fill=true, clip=ph})
-- the photo's white border
local border = PHOTO - PHOTO:shrink(4)
work(border, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.3},{"burnt sienna",0.1}}, coverage=3, fill=true, clip=border})
-- the reader's screen: warm, near white at its middle
local S1 = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1.2}}
local S2 = pile{{"lead white",2},{"cadmium yellow",0.6},{"lemon chrome",0.2}}
work(SCREEN, {hand="detail", pile=S1, coverage=4, fill=true, clip=SCREEN})
local sc = SCREEN:shrink(6)
work(sc, {hand="detail", pile=S2, coverage=4, fill=true, clip=sc})

--@ chunk 8
print(wait(2*24*60))
local r = brush{kind="round", width=3, point=0.9}
local K = pile{{"bone black",1.5},{"bone brown",1}}
-- the half-written message: lines of marks, the last line stopping short, a cursor
local lines = {{462,0.9},{470,0.95},{478,0.8},{486,0.6}}
for i,l in ipairs(lines) do
  local y = l[1]
  local x0 = 590; local x1 = x0 + 80*l[2]
  local x = x0
  while x < x1 do
    local w = rand(4, 12)
    r:reload(pile{{"burnt sienna",1},{"bone brown",1}}, 0.5)
    r:stroke({{x, y - 0.012*(x-590)}, {x+w, y - 0.012*(x+w-590)}}, {pressure={r:pressure_for(1.1), r:pressure_for(1.1)}, clip=SCREEN:shrink(3)})
    x = x + w + rand(2,5)
  end
end
r:reload(pile{{"bone black",1}}, 0.6); r:stroke({{643,483},{643,491}}, {pressure={r:pressure_for(1.3), r:pressure_for(1.3)}})
-- figures in the photo: a parent, two children, a dog, on the sand
local F = pile{{"burnt sienna",1},{"bone brown",1},{"Mars red",0.3}}
local figs = {{596,284,22},{612,292,13},{624,293,12},{648,286,20}}
for _,f in ipairs(figs) do
  r:reload(F, 0.6); r:stroke({{f[1], f[2]},{f[1], f[2]+f[3]}}, {pressure={r:pressure_for(f[3]*0.22), r:pressure_for(f[3]*0.18)}, clip=PHOTO:shrink(4)})
  r:reload(F, 0.6); r:touch(f[1], f[2]-2, {pressure=r:pressure_for(f[3]*0.2), clip=PHOTO:shrink(4)})
end
r:reload(pile{{"vermilion",1},{"lead white",0.4}}, 0.6); r:stroke({{612,296},{612,302}}, {pressure={r:pressure_for(3), r:pressure_for(3)}, clip=PHOTO:shrink(4)})
r:reload(F, 0.6); r:stroke({{664,308},{676,308}}, {pressure={r:pressure_for(3.5), r:pressure_for(3)}, clip=PHOTO:shrink(4)})
-- tape at the photo's top corners
for _,p in ipairs({{{560,234},{580,226}},{{676,226},{694,234}}}) do
  r:reload(pile{{"lead white",1.5},{"yellow ochre",0.6}}, 0.4); r:stroke(p, {pressure={r:pressure_for(5), r:pressure_for(5)}})
end
-- glow spilling from the screen across the desk top and the mug's near side
local G = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
local dtop = DESK * rect(440,494,440,14)
stipple(dtop, {pile=G, width=2.2, pressure={0.3,0.6}, coverage=function(x,y) return 2.2*math.exp(-math.abs(x-630)/70) end, feather=0.6})
r:reload(G, 0.6); r:stroke({{448,546},{560,543},{700,540},{860,536}}, {pressure={r:pressure_for(0.6), r:pressure_for(1.6)}, swell={0.3,1,1,0.4}})
r:reload(G, 0.5); r:stroke({{520,466},{519,486},{518,504}}, {pressure={r:pressure_for(1.8), r:pressure_for(0.8)}})
r:reload(G, 0.5); r:stroke({{484,462},{502,460},{521,461}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}})
r:reload(G, 0.5); r:stroke({{752,472},{758,486},{760,498}}, {pressure={r:pressure_for(1.8), r:pressure_for(0.8)}})
-- the dead plant: dry stalks, a few curled leaves
local DR = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.6}}
for _,s in ipairs({{{770,470},{766,440},{758,416}},{{776,470},{782,436},{794,420},{800,424}},{{772,470},{774,446},{768,430}}}) do
  r:reload(DR, 0.6); r:stroke(s, {pressure={r:pressure_for(1.6), r:pressure_for(0.5)}})
end
for _,p in ipairs({{758,418},{798,426},{762,446},{786,456}}) do r:reload(pile{{"raw sienna",1},{"yellow ochre",0.6},{"bone brown",0.4}}, 0.5); r:touch(p[1], p[2], {pressure=0.5, drag={3,1}}) end

--@ chunk 9
print(wait(2*24*60))
local S2 = pile{{"lead white",2},{"cadmium yellow",0.6},{"lemon chrome",0.2}}
local sc = SCREEN:shrink(5)
work(sc, {hand="detail", pile=S2, coverage=5, fill=true, clip=sc, load=1})
-- the gauntlet: plates and fingers, laid lean and dark
local D = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local M = pile{{"ultramarine ash",1},{"bone black",0.8},{"burnt sienna",0.3}}
GP = {
  {{1000,432},{950,436},{930,470},{1000,470}},
  {{950,440},{900,452},{880,480},{930,484}},
  {{1000,470},{930,474},{930,500},{1000,502}},
  {{905,456},{870,470},{860,492},{892,494}},
}
FING = {
  {{868,486},{846,494},{836,506},{842,516},{864,508},{880,500}},
  {{884,494},{860,506},{852,520},{860,528},{880,518},{896,506}},
  {{900,500},{880,514},{874,528},{884,534},{900,524},{914,510}},
}
for _,p in ipairs(GP) do local m = poly(p); work(m, {hand="detail", pile=D, coverage=4, fill=true, clip=m}); work(m * rect(0,0,1000,470), {hand="detail", pile=M, coverage=2, clip=m}) end
for _,p in ipairs(FING) do local m = poly(p); work(m, {hand="detail", pile=D, coverage=4, fill=true, clip=m}) end
-- the cold emergency strip along the ceiling, upper left
STRIP = rect(30, 18, 380, 12)
work(STRIP, {hand="detail", pile=pile{{"zinc white",2},{"cerulean blue",0.8},{"viridian",0.15}}, coverage=5, fill=true, clip=STRIP})
local housing = rect(24, 30, 392, 6)
work(housing, {hand="detail", pile=pile{{"bone black",1.5},{"ultramarine blue",0.5}}, coverage=4, fill=true, clip=housing})
local spill = rect(0, 36, 520, 110) - OBJ
stipple(spill, {pile=pile{{"cerulean blue",1},{"zinc white",1},{"bone black",0.3}}, width=2.2, pressure={0.3,0.5},
  coverage=function(x,y) return 1.4*math.exp(-(y-36)/22) * (x < 440 and 1 or math.exp(-(x-440)/40)) end, feather=0.6})

--@ chunk 10
local r = brush{kind="round", width=3, point=0.9}
for i,l in ipairs({{462,0.9},{470,0.95},{478,0.8},{486,0.55}}) do
  local y = l[1]; local x0 = 592; local x1 = x0 + 78*l[2]; local x = x0
  while x < x1 do local w = rand(4, 12)
    r:reload(pile{{"burnt sienna",1},{"bone brown",1}}, 0.6)
    r:stroke({{x, y - 0.012*(x-590)}, {x+w, y - 0.012*(x+w-590)}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}, clip=SCREEN:shrink(3)})
    x = x + w + rand(2,5) end
end
r:reload(pile{{"bone black",1}}, 0.6); r:stroke({{640,484},{640,492}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
-- slippers, worn dark felt
work(SLIP, {hand="detail", pile=pile{{"bone black",1},{"bone brown",1},{"ultramarine ash",0.4}}, coverage=5, fill=true, clip=SLIP, load=1})
-- blanket and pillow, lean darks; the light comes later
local BLd = pile{{"bone black",1},{"ultramarine ash",0.8},{"bone brown",0.8}}
work(BLANK, {hand="body", pile=BLd, coverage=4, fill=true, tool="filbert 8", angle=0.1, clip=BLANK})
work(PILLOW, {hand="body", pile=pile{{"ultramarine ash",1},{"bone brown",0.6},{"bone black",0.4}}, coverage=4, fill=true, tool="filbert 5", angle=0, clip=PILLOW})
blend(rect(0,36,520,110) - OBJ, {angle=0, tool={kind="badger", width=24}, pressure={0.25,0.4}})

--@ chunk 11
print(wait(2*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local edge = rect(380, 30, 180, 140) - OBJ
work(edge, {hand="scumble", pile=W0, coverage=1.8, load=0.5, angle=0.3, clip=edge})
local r = brush{kind="round", width=5, point=0.8}
local COLD = pile{{"zinc white",1.5},{"cerulean blue",0.8},{"ultramarine ash",0.5}}
local COLD2 = pile{{"ultramarine ash",1},{"cerulean blue",0.4},{"lead white",0.6},{"bone black",0.2}}
-- the cold strip's light on the tops of the blanket's rumples and the pillow
for _,s in ipairs({{{0,448},{40,440},{90,436}},{{150,452},{200,444},{240,440},{280,448}},{{330,458},{380,456},{426,458}}}) do
  r:reload(COLD2, 0.6); r:stroke(s, {pressure={r:pressure_for(1), r:pressure_for(3)}, swell={0.3,1,1,0.4}, clip=BLANK:grow(1)})
end
r:reload(COLD, 0.6); r:stroke({{14,420},{60,414},{108,414}}, {pressure={r:pressure_for(1.5), r:pressure_for(2.5)}, clip=PILLOW:grow(1)})
-- folds of the blanket in shadow
local FD = pile{{"bone black",1.5},{"ultramarine blue",0.5}}
for _,s in ipairs({{{90,440},{110,480},{100,540}},{{240,444},{226,500},{238,556}},{{330,460},{350,510},{340,566}},{{170,456},{176,500}}}) do
  r:reload(FD, 0.6); r:stroke(s, {pressure={r:pressure_for(2), r:pressure_for(4)}, clip=BLANK})
end
-- the gauntlet: warm from the screen on the knuckles and fingertips facing it, cold rim on top from the strip
local WARM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
for _,p in ipairs(FING) do
  r:reload(WARM, 0.6); r:stroke({p[2], p[3], p[4]}, {pressure={r:pressure_for(1.6), r:pressure_for(0.8)}})
end
r:reload(WARM, 0.5); r:stroke({{904,458},{872,472},{862,490}}, {pressure={r:pressure_for(1.8), r:pressure_for(1)}})
r:reload(COLD2, 0.6); r:stroke({{1000,433},{952,437},{908,454}}, {pressure={r:pressure_for(1.2), r:pressure_for(2)}})
for _,p in ipairs({{{930,472},{1000,472}},{{935,486},{1000,488}}}) do r:reload(FD, 0.6); r:stroke(p, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}}) end
-- mug handle, mug rim
r:reload(pile{{"ultramarine ash",1},{"bone brown",1},{"bone black",0.5}}, 0.8); r:stroke({{521,470},{536,474},{537,490},{521,496}}, {pressure={r:pressure_for(3.5), r:pressure_for(3.5)}})
r:reload(WARM, 0.5); r:stroke({{536,476},{537,488}}, {pressure={r:pressure_for(1.2), r:pressure_for(0.6)}})
-- the slippers catch a little of the glow on their toes
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone brown",0.6}}, 0.5); r:stroke({{344,666},{358,672}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone brown",0.6}}, 0.5); r:stroke({{416,678},{430,686}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})

--@ chunk 12
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local WM = pile{{"bone black",1},{"bone brown",1},{"ultramarine ash",0.8}}
local band = rect(330, 34, 90, 110)
work(band, {hand="body", pile=WM, coverage=2.5, fill=true, tool="filbert 8", angle=0.2, clip=band, length={10,30}})
blend(rect(300, 34, 160, 120), {angle=0, tool={kind="badger", width=20}, pressure={0.35,0.55}})
blend(rect(0, 120, 420, 60) - OBJ, {angle=math.pi/2, tool={kind="badger", width=20}, pressure={0.3,0.5}})
-- the blanket's near face in shadow, its edge toward us
local face = BLANK * rect(0,500,440,80)
work(face, {hand="body", pile=pile{{"bone black",1.2},{"ultramarine ash",0.6},{"bone brown",0.8}}, coverage=3, fill=true, tool="filbert 8", angle=0.05, clip=BLANK})

--@ chunk 13
print(wait(2*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local WC = pile{{"bone black",1.1},{"ultramarine ash",0.9},{"bone brown",0.9}}
local patch = (rect(296, 34, 180, 150) + rect(240,120,80,70)):roughen(10, 50, 3) - OBJ
local coldpart = patch * poly({{296,34},{340,34},{300,110},{260,150},{240,190}}):roughen(8,40,4)
work(patch - coldpart, {hand="body", pile=W0, coverage=3.5, fill=true, tool="filbert 8", angle=math.pi/2, clip=patch})
work(coldpart, {hand="body", pile=WC, coverage=3.5, fill=true, tool="filbert 6", angle=math.pi/2, clip=patch})
-- the blanket: break the band with rumples running front to back
local r = brush{kind="round", width=8, point=0.8}
local FD = pile{{"bone black",1.5},{"ultramarine blue",0.5}}
local MID = pile{{"ultramarine ash",1},{"bone brown",0.8},{"bone black",0.6}}
for _,s in ipairs({{{60,470},{70,520},{56,566}},{{140,476},{150,526},{136,572}},{{300,480},{290,530},{306,566}},{{400,478},{396,530},{410,560}}}) do
  r:reload(FD, 0.6); r:stroke(s, {pressure={r:pressure_for(2), r:pressure_for(5)}, clip=BLANK})
end
for _,s in ipairs({{{30,476},{36,520}},{{190,480},{196,530}},{{350,482},{346,530}}}) do
  r:reload(MID, 0.5); r:stroke(s, {pressure={r:pressure_for(5), r:pressure_for(2)}, clip=BLANK})
end

--@ chunk 14
print(wait(3*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local area = rect(0, 31, 560, 400):roughen(12, 60, 5) - OBJ - SLIP
area = area - ellipse(630, 470, 200, 150)
work(area, {hand="body", pile=W0, coverage=4, fill=true, tool="filbert 12", angle=math.pi/2, clip=area, length={30,90}})

--@ chunk 15
print(wait(3*24*60))
-- the cold light: a few long strokes down the wall, only a little lighter than the dark, graded by load
local C1 = pile{{"bone black",1},{"ultramarine ash",1},{"bone brown",0.7},{"cerulean blue",0.1}}
local C2 = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"bone brown",1}}
local wall = rect(0, 36, 500, 400) - OBJ
local top = wall * rect(0,36,470,70)
local next = wall * rect(0,100,440,90)
work(top, {hand="body", pile=C1, coverage=3, fill=true, tool="filbert 10", angle=math.pi/2, clip=wall, length={50,110}, edge="soft"})
work(next, {hand="body", pile=C2, coverage=2.5, fill=true, tool="filbert 10", angle=math.pi/2, clip=wall, length={50,110}, edge="soft"})
blend(wall * rect(0,36,500,200), {angle=math.pi/2, tool={kind="badger", width=24}, pressure={0.3,0.5}})

--@ chunk 16
print(wait(3*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local area = (rect(0, 31, 470, 200):roughen(14, 60, 7) + rect(0,180,420,60):roughen(14,60,8)) - OBJ
work(area, {hand="body", pile=W0, coverage=4.5, fill=true, tool="filbert 10", angle=math.pi/2, clip=area, length={30,90}, load=1})
-- the pool's left edge, lost into the dark with a middle tone
local W1 = pile{{"bone brown",2},{"burnt sienna",0.7},{"bone black",0.5}}
local pool = ellipse(630, 470, 200, 150)
print(lose(pool - OBJ, {pile=W1, where=1, reach={30,30}, load=0.3}))

--@ chunk 17
print(wait(3*24*60))
local K = pile{{"bone black",1.5},{"bone brown",1},{"ultramarine blue",0.4}}
local DK = pile{{"bone black",1},{"burnt sienna",1},{"bone brown",1}}
work(DESK, {hand="detail", pile=DK, coverage=5, fill=true, clip=DESK, load=1})
work(BRK, {hand="detail", pile=K, coverage=5, fill=true, clip=BRK, load=1})
work(READER - SCREEN, {hand="detail", pile=K, coverage=5, fill=true, clip=READER - SCREEN, load=1})
work(MUG, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine ash",0.8},{"bone black",0.3}}, coverage=5, fill=true, clip=MUG, load=1})
work(POT, {hand="detail", pile=pile{{"burnt sienna",1.2},{"bone brown",1},{"Mars red",0.2}}, coverage=5, fill=true, clip=POT, load=1})
local S2 = pile{{"lead white",2},{"cadmium yellow",0.6},{"lemon chrome",0.2}}
local S1 = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1.2}}
work(SCREEN, {hand="detail", pile=S1, coverage=5, fill=true, clip=SCREEN, load=1})
work(SCREEN:shrink(5), {hand="detail", pile=S2, coverage=5, fill=true, clip=SCREEN:shrink(5), load=1})
-- the floor under the desk, dark again where the drags crossed it
local fl = rect(390,560,480,64) - OBJ
work(fl, {hand="body", pile=pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.5}}, coverage=4, fill=true, tool="filbert 8", angle=math.pi/2, clip=fl})

--@ chunk 18
print(wait(3*24*60))
local r = brush{kind="round", width=3, point=0.9}
for i,l in ipairs({{462,0.9},{470,0.95},{478,0.8},{486,0.55}}) do
  local y = l[1]; local x0 = 592; local x1 = x0 + 78*l[2]; local x = x0
  while x < x1 do local w = rand(4, 12)
    r:reload(pile{{"burnt sienna",1},{"bone brown",1}}, 0.6)
    r:stroke({{x, y - 0.012*(x-590)}, {x+w, y - 0.012*(x+w-590)}}, {pressure={r:pressure_for(1.2), r:pressure_for(1.2)}, clip=SCREEN:shrink(3)})
    x = x + w + rand(2,5) end
end
r:reload(pile{{"bone black",1}}, 0.6); r:stroke({{640,484},{640,492}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
local G = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
local g = brush{kind="round", width=5, point=0.8}
g:reload(G, 0.6); g:stroke({{448,546},{560,543},{700,540},{860,536}}, {pressure={g:pressure_for(0.6), g:pressure_for(1.6)}, swell={0.3,1,1,0.4}})
g:reload(G, 0.6); g:stroke({{540,507},{600,503},{700,498},{760,497}}, {pressure={g:pressure_for(0.8), g:pressure_for(0.8)}, swell={0.2,1,1,0.2}})
g:reload(G, 0.5); g:stroke({{520,466},{519,486},{518,504}}, {pressure={g:pressure_for(1.8), g:pressure_for(0.8)}})
g:reload(G, 0.5); g:stroke({{484,462},{502,460},{521,461}}, {pressure={g:pressure_for(1.2), g:pressure_for(1.2)}})
g:reload(G, 0.5); g:stroke({{752,472},{758,486},{760,498}}, {pressure={g:pressure_for(1.8), g:pressure_for(0.8)}})
g:reload(pile{{"ultramarine ash",1},{"bone brown",1},{"bone black",0.5}}, 0.8); g:stroke({{521,470},{536,474},{537,490},{521,496}}, {pressure={g:pressure_for(3.5), g:pressure_for(3.5)}})
-- the cold light: a few long, lightly loaded strokes down the wall from the strip
local C1 = pile{{"bone black",0.8},{"ultramarine ash",1},{"bone brown",0.6},{"cerulean blue",0.1}}
local b = brush{kind="filbert", width=22}
for i=0,7 do
  local x = 40 + i*52 + rand(-6,6)
  b:reload(C1, 0.45)
  b:stroke({{x,40},{x+rand(-4,4),130},{x,200+rand(0,40)}}, {pressure={0.55, 0.05}, clip=rect(0,36,470,400) - OBJ})
end

--@ chunk 19
print(wait(3*24*60))
local ph = PHOTO:shrink(4)
local SKY = pile{{"cerulean blue",1.2},{"zinc white",1.6}}
local SEA = pile{{"cobalt blue",1.2},{"cerulean blue",0.8},{"zinc white",0.4}}
local SAND = pile{{"lemon chrome",0.3},{"yellow ochre",0.8},{"zinc white",1.8}}
local sky = ph * above(function(x) return 268 - 0.05*(x-560) end)
local sand = ph * below(function(x) return 284 - 0.05*(x-560) end)
local sea = ph - sky - sand
work(sky, {hand="detail", pile=SKY, coverage=6, fill=true, clip=sky, load=1})
work(sea, {hand="detail", pile=SEA, coverage=6, fill=true, clip=sea, load=1})
work(sand, {hand="detail", pile=SAND, coverage=6, fill=true, clip=sand, load=1})
local border = PHOTO - ph
work(border, {hand="detail", pile=pile{{"zinc white",2},{"yellow ochre",0.25}}, coverage=4, fill=true, clip=border, load=1})

--@ chunk 20
print(wait(3*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local CA = pile{{"bone black",1},{"ultramarine ash",0.9},{"bone brown",1}}
local CB = pile{{"bone black",1.2},{"ultramarine ash",0.6},{"bone brown",1.3}}
local area = rect(0, 31, 480, 220):roughen(10, 60, 11) - OBJ
work(area, {hand="body", pile=W0, coverage=4, fill=true, tool="filbert 10", angle=0, clip=area, length={30,80}, load=1})
local b1 = area * rect(0,31,470,55)
local b2 = area * rect(0,80,450,60):roughen(10,50,12)
work(b1, {hand="body", pile=CA, coverage=2.5, fill=true, tool="filbert 10", angle=0, clip=area, length={40,100}, edge="soft"})
work(b2, {hand="body", pile=CB, coverage=2, tool="filbert 10", angle=0, clip=area, length={40,100}, edge="soft"})
-- under the desk: dark floor again
local fl = rect(390,546,480,78) - OBJ
work(fl, {hand="body", pile=pile{{"bone black",1.3},{"bone brown",1.5},{"burnt sienna",0.5}}, coverage=4, fill=true, tool="filbert 8", angle=0, clip=fl, load=1})
-- the gauntlet's fingers restored on the desk's lip
local D = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
for _,p in ipairs(FING) do local m = poly(p); work(m, {hand="detail", pile=D, coverage=5, fill=true, clip=m, load=1}) end

--@ chunk 21
print(wait(3*24*60))
local r = brush{kind="round", width=5, point=0.8}
local WARM = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
for _,p in ipairs(FING) do r:reload(WARM, 0.6); r:stroke({p[2], p[3], p[4]}, {pressure={r:pressure_for(1.6), r:pressure_for(0.8)}}) end
-- the strip's cold edge right under it, and on the bunk-frame top
local COLD = pile{{"zinc white",1},{"cerulean blue",0.6},{"ultramarine ash",0.8},{"bone black",0.2}}
r:reload(COLD, 0.5); r:stroke({{30,38},{200,38},{410,38}}, {pressure={r:pressure_for(3), r:pressure_for(3)}, swell={0.2,1,1,0.2}})
r:reload(COLD, 0.5); r:stroke({{0,556},{200,554},{430,552}}, {pressure={r:pressure_for(1.2), r:pressure_for(0.6)}, clip=FRAME:grow(2)})

--@ chunk 22
print(wait(3*24*60))
-- figures as simple bright shapes on the sand
local function fig(x, y, h, top, legs)
  local head = ellipse(x, y, h*0.13, h*0.13)
  local body = poly({{x-h*0.13, y+h*0.15},{x+h*0.13, y+h*0.15},{x+h*0.12, y+h*0.6},{x-h*0.12, y+h*0.6}})
  local lg = rect(x-h*0.1, y+h*0.6, h*0.2, h*0.4)
  work(head, {hand="detail", pile=pile{{"lead white",1.5},{"Mars orange",0.4},{"rose madder",0.1}}, coverage=5, fill=true, clip=head, load=1})
  work(body, {hand="detail", pile=top, coverage=5, fill=true, clip=body, load=1})
  work(lg, {hand="detail", pile=legs, coverage=5, fill=true, clip=lg, load=1})
end
fig(598, 276, 30, pile{{"vermilion",1.5},{"cadmium red",0.5}}, pile{{"ultramarine blue",1},{"lead white",0.3}})
fig(618, 286, 19, pile{{"cadmium yellow",1.5},{"lemon chrome",0.3}}, pile{{"lead white",1.2},{"Mars orange",0.4}})
fig(636, 287, 18, pile{{"emerald green",1},{"lead white",0.4}}, pile{{"lead white",1.2},{"Mars orange",0.4}})
local dog = ellipse(660, 304, 9, 4) + ellipse(668, 300, 3.5, 3)
work(dog, {hand="detail", pile=pile{{"Mars orange",1},{"burnt sienna",0.6},{"lead white",0.4}}, coverage=5, fill=true, clip=dog, load=1})
-- blanket ridges catching the cold strip; slippers a touch lighter
local r = brush{kind="round", width=6, point=0.8}
local L = pile{{"ultramarine ash",1},{"lead white",0.5},{"bone brown",0.4}}
for _,s in ipairs({{{40,476},{46,520},{40,560}},{{180,480},{186,528},{176,566}},{{262,470},{258,520},{266,560}},{{360,484},{356,530}}}) do
  r:reload(L, 0.6); r:stroke(s, {pressure={r:pressure_for(4), r:pressure_for(1)}, clip=BLANK})
end
local SL = pile{{"bone brown",1},{"ultramarine ash",0.6},{"burnt sienna",0.4},{"lead white",0.2}}
work(SLIP:shrink(1), {hand="detail", pile=SL, coverage=4, fill=true, clip=SLIP})
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5); r:stroke({{340,666},{358,671}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5); r:stroke({{412,678},{430,685}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})

--@ chunk 23
print(wait(3*24*60))
local W0 = pile{{"bone black",1.4},{"bone brown",1.5},{"ultramarine blue",0.5}}
local seam = rect(470, 31, 40, 210):roughen(5,30,13) - OBJ
work(seam, {hand="body", pile=W0, coverage=4, fill=true, tool="filbert 6", angle=math.pi/2, clip=seam, load=1})
local fl = rect(440,548,420,74) - OBJ
work(fl, {hand="body", pile=pile{{"bone black",1.8},{"bone brown",1},{"ultramarine blue",0.4},{"burnt sienna",0.3}}, coverage=4.5, fill=true, tool="filbert 8", angle=0, clip=fl, load=1})
work(SLIP:shrink(1), {hand="detail", pile=pile{{"bone brown",1.2},{"ultramarine ash",0.5},{"bone black",0.4},{"burnt sienna",0.3}}, coverage=5, fill=true, clip=SLIP, load=1})

--@ chunk 24
print(wait(3*24*60))
local r = brush{kind="round", width=5, point=0.8}
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5); r:stroke({{340,666},{358,671}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5); r:stroke({{412,678},{430,685}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"ultramarine ash",1},{"lead white",0.3},{"bone brown",0.4}}, 0.4); r:stroke({{296,668},{340,662}}, {pressure={r:pressure_for(1.2), r:pressure_for(0.6)}})
local G = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
r:reload(G, 0.6); r:stroke({{448,547},{560,544},{700,541},{860,537}}, {pressure={r:pressure_for(0.6), r:pressure_for(1.6)}, swell={0.3,1,1,0.4}})
