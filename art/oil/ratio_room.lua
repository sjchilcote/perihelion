-- easel session "ratio_room": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=4/3, linen={18,16}, seed=6161, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.5},{"cobalt violet",0.3},{"ultramarine ash",0.3}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
VP = {500, 330}
BW = poly({{260,130},{740,130},{740,470},{260,470}})
CEIL = poly({{0,0},{1000,0},{740,130},{260,130}})
LW = poly({{0,0},{260,130},{260,470},{0,750}})
RW = poly({{1000,0},{740,130},{740,470},{1000,750}})
FLOOR = poly({{260,470},{740,470},{1000,750},{0,750}})
WIN = poly({{320,160},{680,160},{680,410},{320,410}})
local function flat(m, p, ang) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 10", angle=ang or 0, clip=m}) end
flat(CEIL, pile{{"lead white",2},{"cobalt violet",0.4},{"ultramarine ash",0.4}}, 0)
flat(LW, pile{{"lead white",2},{"Mars orange",0.25},{"rose madder",0.2},{"yellow ochre",0.3}}, math.pi/2)
flat(RW, pile{{"lead white",2},{"cerulean blue",0.3},{"viridian",0.15},{"yellow ochre",0.2}}, math.pi/2)
flat(BW - WIN, pile{{"lead white",2.5},{"yellow ochre",0.35},{"Mars orange",0.1}}, math.pi/2)
flat(FLOOR, pile{{"lead white",2.5},{"yellow ochre",0.5},{"raw sienna",0.1}}, 0)
-- the window's pixel sky: bands of flat blue, paler toward the horizon
local skies = {
  pile{{"cerulean blue",1.2},{"cobalt blue",0.3},{"lead white",0.8}},
  pile{{"cerulean blue",1},{"lead white",1.2}},
  pile{{"cerulean blue",0.8},{"lead white",1.8}},
  pile{{"cerulean blue",0.5},{"lead white",2.2},{"yellow ochre",0.1}},
}
for i=1,4 do flat(WIN * rect(320, 160 + (i-1)*62.5, 360, 63), skies[i], 0) end

--@ chunk 3
function fp(X, d) return 500 + X*720/d, 330 + 420/d end
local ds = {} for k=0,10 do ds[#ds+1] = 1 + k*0.2 end
local dark = nil
for i=1,#ds-1 do
  for j=-6,5 do
    if (i + j) % 2 == 0 then
      local X0, X1 = j*0.2, (j+1)*0.2
      local a = {fp(X0, ds[i])}; local b = {fp(X1, ds[i])}; local c = {fp(X1, ds[i+1])}; local d = {fp(X0, ds[i+1])}
      local t = poly({a, b, c, d})
      dark = dark and (dark + t) or t
    end
  end
end
TILES = dark * FLOOR
work(TILES, {hand="body", pile=pile{{"viridian",0.5},{"cerulean blue",0.6},{"lead white",1.6}}, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=TILES})
-- pixel clouds: flat white blocks in the sky, and the octagon sun
local cl = rect(350,200,60,20) + rect(370,180,30,20) + rect(560,250,80,20) + rect(580,232,40,18) + rect(420,300,50,18)
work(cl * WIN, {hand="detail", pile=pile{{"zinc white",3},{"cerulean blue",0.1}}, coverage=4, fill=true, clip=cl * WIN})
local oct = {} for k=0,7 do local a = math.pi/8 + k*math.pi/4; oct[#oct+1] = {600 + 36*math.cos(a), 205 + 36*math.sin(a)} end
SUN = poly(oct)
work(SUN, {hand="detail", pile=pile{{"cadmium yellow",1.5},{"lemon chrome",0.6},{"lead white",0.4}}, coverage=5, fill=true, clip=SUN})
-- window frame: thick flat mullions
local FR = rect(312,152,376,10) + rect(312,408,376,12) + rect(312,152,10,268) + rect(678,152,10,268) + rect(495,160,10,250) + rect(320,280,360,8)
work(FR, {hand="detail", pile=pile{{"lead white",2},{"Mars orange",0.3},{"rose madder",0.2}}, coverage=4, fill=true, clip=FR})
FRM = FR

--@ chunk 4
function lw(x, v) local yf = 750 - 1.0769*x; local yc = 0.5*x; return {x, yf + v*(yc - yf)} end
function lwq(x0, x1, v0, v1) return poly({lw(x0,v0), lw(x1,v0), lw(x1,v1), lw(x0,v1)}) end
-- bookshelf against the left wall
SHELF = lwq(50, 215, 0, 0.58)
work(SHELF, {hand="body", pile=pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.8}}, coverage=4, fill=true, tool="filbert 5", angle=math.pi/2, clip=SHELF})
local inner = nil
for _,b in ipairs({{0.03,0.17},{0.21,0.36},{0.40,0.55}}) do local q = lwq(58, 207, b[1], b[2]); inner = inner and (inner + q) or q end
work(inner, {hand="detail", pile=pile{{"burnt sienna",1},{"bone brown",1},{"Mars orange",0.3}}, coverage=4, fill=true, clip=inner})
-- books: flat-coloured slabs
local cols = {
  pile{{"cadmium red",1},{"lead white",0.4}}, pile{{"cobalt blue",1},{"lead white",0.6}}, pile{{"cadmium yellow",1},{"lead white",0.3}},
  pile{{"emerald green",1},{"lead white",0.5}}, pile{{"magenta",1},{"lead white",0.6}}, pile{{"lead white",2},{"cerulean blue",0.2}},
  pile{{"Mars orange",1},{"lead white",0.4}}, pile{{"cobalt violet",1},{"lead white",0.5}},
}
local k = 0
for si,b in ipairs({{0.03,0.17},{0.21,0.36},{0.40,0.55}}) do
  local x = 62
  while x < 196 do
    k = k + 1
    local w = 7 + (k*37 % 9)
    local h = b[2] - (0.012 + (k*53 % 5)*0.006)
    if k % 7 == 3 then -- a slab lying down
      local q = lwq(x, x+22, b[1], b[1] + 0.04)
      work(q, {hand="detail", pile=cols[(k % #cols)+1], coverage=4, fill=true, clip=q}); x = x + 24
    else
      local q = lwq(x, x+w, b[1], h)
      work(q, {hand="detail", pile=cols[(k % #cols)+1], coverage=4, fill=true, clip=q}); x = x + w + 1
    end
  end
end
-- the plant in the back-right corner: a trapezoid pot, triangle leaves
POT = poly({{690,440},{738,440},{730,478},{698,478}})
work(POT, {hand="detail", pile=pile{{"red earth",1},{"Mars orange",0.6},{"lead white",0.4}}, coverage=4, fill=true, clip=POT})
local Ls = {{{714,442},{680,380},{702,436}},{{714,442},{714,360},{726,436}},{{714,442},{752,384},{722,440}},{{714,440},{668,412},{700,442}},{{716,440},{764,414},{728,442}},{{714,440},{696,350},{712,432}}}
local G1 = pile{{"emerald green",1},{"viridian",0.4},{"lead white",0.5}}
local G2 = pile{{"viridian",1},{"emerald green",0.4},{"lead white",0.15}}
for i,t in ipairs(Ls) do local m = poly(t); work(m, {hand="detail", pile=(i%2==0) and G1 or G2, coverage=4, fill=true, clip=m}) end

--@ chunk 5
print(wait(2*24*60))
-- beanbag: a low-poly lump in flat facets, lit from the window (upper back)
local BB = {
  {pts={{250,640},{300,560},{380,540},{470,555},{530,600},{540,660},{480,700},{360,708},{270,690}}, p=pile{{"cobalt violet",0.8},{"rose madder",0.3},{"lead white",1.4}}},
  {pts={{300,560},{380,540},{470,555},{430,600},{340,604}}, p=pile{{"cobalt violet",0.6},{"rose madder",0.2},{"lead white",2.2}}},
  {pts={{250,640},{300,560},{340,604},{320,680},{270,690}}, p=pile{{"cobalt violet",1},{"rose madder",0.3},{"lead white",0.9},{"ultramarine ash",0.2}}},
  {pts={{320,680},{340,604},{430,600},{480,700},{360,708}}, p=pile{{"cobalt violet",0.9},{"rose madder",0.3},{"lead white",1.1}}},
  {pts={{430,600},{470,555},{530,600},{540,660},{480,700}}, p=pile{{"cobalt violet",1},{"ultramarine ash",0.3},{"lead white",0.8}}},
}
BEAN = nil
for _,f in ipairs(BB) do local m = poly(f.pts); BEAN = BEAN and (BEAN + m) or m; work(m, {hand="detail", pile=f.p, coverage=4, fill=true, clip=m}) end
-- its shadow on the floor
local sh = poly({{260,690},{360,712},{480,704},{560,690},{540,720},{300,730}}, true) - BEAN
work(sh, {hand="body", pile=pile{{"ultramarine ash",1},{"cobalt violet",0.3},{"lead white",0.6}}, coverage=3, fill=true, tool="filbert 6", clip=sh})
-- the low table and the CRT on the right
TOP = poly({{620,560},{880,556},{900,584},{604,590}})
FRONT = poly({{604,590},{900,584},{900,598},{604,604}})
LEGS = rect(616,600,12,80) + rect(882,594,12,82) + rect(650,592,10,60) + rect(856,590,10,58)
work(TOP, {hand="detail", pile=pile{{"lead white",1.5},{"Mars orange",0.5},{"burnt sienna",0.3}}, coverage=4, fill=true, clip=TOP})
work(FRONT + LEGS, {hand="detail", pile=pile{{"burnt sienna",1},{"Mars orange",0.5},{"lead white",0.4}}, coverage=4, fill=true, clip=FRONT + LEGS})
CRT_F = poly({{660,436},{800,432},{804,566},{662,570}})
CRT_S = poly({{800,432},{842,446},{842,552},{804,566}})
CRT_T = poly({{660,436},{800,432},{842,446},{708,450}})
work(CRT_F, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.3},{"ultramarine ash",0.3}}, coverage=4, fill=true, clip=CRT_F})
work(CRT_S, {hand="detail", pile=pile{{"lead white",1.2},{"ultramarine ash",0.6},{"yellow ochre",0.2}}, coverage=4, fill=true, clip=CRT_S})
work(CRT_T, {hand="detail", pile=pile{{"lead white",2.5},{"yellow ochre",0.25}}, coverage=4, fill=true, clip=CRT_T})
SCR = poly({{676,452},{786,448},{788,540},{678,544}})
work(SCR, {hand="detail", pile=pile{{"bone black",1},{"ultramarine blue",0.8},{"viridian",0.2}}, coverage=5, fill=true, clip=SCR})
local tsh = poly({{604,604},{900,598},{960,700},{640,712}}) * FLOOR - LEGS
work(tsh, {hand="body", pile=pile{{"ultramarine ash",1},{"viridian",0.2},{"lead white",0.6}}, coverage=2.5, fill=true, tool="filbert 6", clip=tsh})

--@ chunk 6
print(wait(2*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=5, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local HAIR2 = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.35}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
local SKIN2 = pile{{"lead white",2.2},{"rose madder",0.2},{"cobalt violet",0.15},{"yellow ochre",0.1}}
local TOPW = pile{{"zinc white",2.5},{"cerulean blue",0.08}}
local TOPS = pile{{"lead white",1.5},{"ultramarine ash",0.5},{"cobalt violet",0.15}}
local NAVY = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
-- long hair behind, in faceted locks down over the beanbag
F({{352,430},{372,410},{360,520},{334,590},{318,580}}, HAIR)
F({{372,410},{400,404},{380,540},{356,600},{340,594}}, HAIR2)
F({{356,470},{376,480},{368,560},{352,606},{336,600}}, HAIR)
-- torso and the knees hugged up, turned toward the screen
F({{376,486},{414,484},{420,540},{408,566},{374,566},{366,530}}, TOPS)
F({{386,488},{414,484},{420,530},{396,528}}, TOPW)
F({{404,530},{446,500},{462,512},{424,552}}, NAVY)       -- thigh
F({{446,500},{462,512},{458,578},{440,578}}, NAVY)       -- shin
F({{434,574},{462,574},{470,588},{432,590}}, pile{{"rose madder",1},{"lead white",0.8}}) -- shoe
F({{410,494},{448,512},{444,524},{406,510}}, SKIN2)      -- forearm wrapped round the shins
F({{444,508},{456,512},{454,524},{442,522}}, SKIN)       -- hand
-- the head: big, low-poly, three-quarter toward the screen
F({{356,434},{372,406},{404,398},{432,410},{442,440},{434,474},{410,488},{380,484},{360,466}}, HAIR)
F({{396,430},{432,420},{442,444},{434,474},{412,486},{398,470}}, SKIN)
F({{396,430},{404,440},{398,470}}, SKIN2)
-- fringe in faceted points
F({{388,404},{436,410},{444,434},{430,426},{424,440},{414,424},{404,438},{398,420}}, HAIR)
-- eye, mouth (open, mid-sentence), a pink blush facet
F({{420,446},{430,444},{431,458},{421,460}}, pile{{"bone black",1.5},{"ultramarine blue",0.4}})
F({{426,468},{434,467},{432,474},{426,474}}, pile{{"rose madder",0.8},{"bone black",0.6}})

--@ chunk 7
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
local SKIN2 = pile{{"lead white",2.4},{"rose madder",0.2},{"cobalt violet",0.12},{"yellow ochre",0.1}}
F({{404,438},{430,424},{440,444},{434,472},{412,484},{402,468}}, SKIN)
F({{400,440},{406,440},{404,470},{400,466}}, SKIN2)
F({{410,494},{448,512},{444,524},{406,510}}, SKIN2)
F({{444,508},{456,512},{454,524},{442,522}}, SKIN)
print(wait(3*24*60))

--@ chunk 8
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
F({{396,404},{436,410},{444,432},{432,426},{426,440},{416,426},{406,440},{398,422}}, HAIR)
F({{419,446},{430,444},{431,459},{420,461}}, pile{{"bone black",2},{"ultramarine blue",0.3}})
F({{426,468},{434,467},{432,474},{426,474}}, pile{{"rose madder",1},{"bone black",0.6}})
local r = brush{kind="round", width=3, point=0.9}
r:reload(pile{{"zinc white",2}}, 0.6); r:touch(427, 449, {pressure=0.4})
r:reload(pile{{"rose madder",1},{"lead white",1.5}}, 0.4); r:touch(422, 466, {pressure=0.6, drag={4,0}})
-- the hair's lit facet edges from the window
r:reload(pile{{"ultramarine ash",1},{"lead white",0.8},{"cerulean blue",0.2}}, 0.6)
r:stroke({{372,410},{402,402}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"ultramarine ash",1},{"lead white",0.8},{"cerulean blue",0.2}}, 0.6)
r:stroke({{372,412},{362,500},{346,580}}, {pressure={r:pressure_for(1.5), r:pressure_for(0.6)}})
-- the CRT: the Commando's helm, very small, looking in: dark helm, visor slit, a cold optic
local SCR = poly({{676,452},{786,448},{788,540},{678,544}})
local glow = poly({{680,456},{784,452},{786,536},{680,540}})
work(glow, {hand="detail", pile=pile{{"ultramarine blue",0.6},{"cerulean blue",0.6},{"bone black",0.4},{"lead white",0.4}}, coverage=5, fill=true, clip=glow, load=1})
F({{714,478},{750,476},{760,500},{758,544},{708,544},{704,500}}, pile{{"bone black",1.5},{"ultramarine ash",0.5},{"lead white",0.25}})
F({{708,500},{756,498},{756,506},{708,508}}, pile{{"bone black",2}})
r:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.7); r:touch(740, 503, {pressure=0.6, drag={4,0}})
-- the session header bar at the top of the screen
F({{680,456},{784,452},{784,462},{680,466}}, pile{{"cobalt blue",1},{"cerulean blue",0.6},{"lead white",0.4}})
F({{682,458},{700,457},{700,463},{682,464}}, pile{{"vermilion",1.5},{"cadmium red",0.5}})

--@ chunk 9
print(wait(2*24*60))
local excl = (CRT_F + CRT_S + CRT_T + TOP + FRONT + LEGS + POT):grow(2)
local FOG = pile{{"zinc white",2},{"cobalt violet",0.2},{"ultramarine ash",0.25}}
local fogm = (poly({{690,120},{860,60},{900,560},{620,520},{650,470}}, true):roughen(20, 90, 3)) - excl
work(fogm, {hand="scumble", pile=FOG, coverage=2, load=0.35, angle=0.0, clip=fogm})
blend(fogm, {angle=math.pi/2, tool={kind="badger", width=20}, pressure={0.3,0.5}})
-- the beanbag's shadow tucked under it
local sh = poly({{262,684},{360,706},{480,700},{540,664},{566,690},{480,724},{330,726},{250,706}}, true) - BEAN
work(sh, {hand="body", pile=pile{{"ultramarine ash",1},{"cobalt violet",0.4},{"lead white",0.5}}, coverage=3.5, fill=true, tool="filbert 5", clip=sh})
-- the window's light thrown onto the floor in a pale skewed pool
local pool = poly({{360,480},{640,480},{700,560},{320,560}}) * FLOOR - BEAN - excl
work(pool, {hand="scumble", pile=pile{{"zinc white",2},{"lemon chrome",0.1}}, coverage=1.4, load=0.3, angle=0, clip=pool})

--@ chunk 10
print(wait(3*24*60))
AVP = {
  hair1={{352,430},{372,410},{360,520},{334,590},{318,580}},
  hair2={{372,410},{400,404},{380,540},{356,600},{340,594}},
  hair3={{356,470},{376,480},{368,560},{352,606},{336,600}},
  torso={{376,486},{414,484},{420,540},{408,566},{374,566},{366,530}},
  shirt={{386,488},{414,484},{420,530},{396,528}},
  thigh={{404,530},{446,500},{462,512},{424,552}},
  shin={{446,500},{462,512},{458,578},{440,578}},
  shoe={{434,574},{462,574},{470,588},{432,590}},
  arm={{410,494},{448,512},{444,524},{406,510}},
  hand={{444,508},{456,512},{454,524},{442,522}},
  head={{356,434},{372,406},{404,398},{432,410},{442,440},{434,474},{410,488},{380,484},{360,466}},
}
AV = nil
for _,p in pairs(AVP) do local m = poly(p); AV = AV and (AV + m) or m end
local excl = (CRT_F + CRT_S + CRT_T + TOP + FRONT + LEGS + POT + BEAN + AV):grow(1)
local zone = (poly({{690,120},{860,60},{900,560},{620,520},{650,470}}, true):roughen(20, 90, 3)):grow(14) + (poly({{360,480},{640,480},{700,560},{320,560}}):grow(8))
local function flat(m, p) work(m, {hand="body", pile=p, coverage=4, fill=true, tool="filbert 6", angle=0, clip=m, load=1}) end
local Z = zone - excl
flat(Z * CEIL, pile{{"lead white",2},{"cobalt violet",0.4},{"ultramarine ash",0.4}})
flat(Z * RW, pile{{"lead white",2},{"cerulean blue",0.3},{"viridian",0.15},{"yellow ochre",0.2}})
flat(Z * (BW - WIN - FRM), pile{{"lead white",2.5},{"yellow ochre",0.35},{"Mars orange",0.1}})
flat(Z * FRM, pile{{"lead white",2},{"Mars orange",0.3},{"rose madder",0.2}})
local skies = {
  pile{{"cerulean blue",1.2},{"cobalt blue",0.3},{"lead white",0.8}}, pile{{"cerulean blue",1},{"lead white",1.2}},
  pile{{"cerulean blue",0.8},{"lead white",1.8}}, pile{{"cerulean blue",0.5},{"lead white",2.2},{"yellow ochre",0.1}},
}
for i=1,4 do flat(Z * (WIN - FRM) * rect(320, 160 + (i-1)*62.5, 360, 63), skies[i]) end
flat(Z * (FLOOR - TILES), pile{{"lead white",2.5},{"yellow ochre",0.5},{"raw sienna",0.1}})
flat(Z * TILES, pile{{"viridian",0.5},{"cerulean blue",0.6},{"lead white",1.6}})

--@ chunk 11
print(wait(2*24*60))
local function F(k, p) local m = poly(AVP[k]); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}) end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local HAIR2 = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.35}}
local TOPW = pile{{"zinc white",2.5},{"cerulean blue",0.08}}
local TOPS = pile{{"lead white",1.5},{"ultramarine ash",0.5},{"cobalt violet",0.15}}
local NAVY = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
local SKIN2 = pile{{"lead white",2.4},{"rose madder",0.2},{"cobalt violet",0.12},{"yellow ochre",0.1}}
F("hair1", HAIR); F("hair2", HAIR2); F("hair3", HAIR)
F("torso", TOPS); F("thigh", NAVY); F("shin", NAVY)
F("shoe", pile{{"rose madder",1},{"lead white",0.8}})

--@ chunk 12
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}) end
F(AVP.shirt, pile{{"zinc white",2.5},{"cerulean blue",0.08}})
F({{388,486},{414,484},{410,500},{400,506},{392,500}}, pile{{"cerulean blue",1},{"cobalt blue",0.4},{"lead white",0.6}}) -- sailor collar
F({{398,500},{406,500},{404,512}}, pile{{"cadmium red",1},{"lead white",0.2}})                                             -- the little red tie
F(AVP.arm, pile{{"lead white",2.4},{"rose madder",0.2},{"cobalt violet",0.12},{"yellow ochre",0.1}})
F(AVP.hand, pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}})
local r = brush{kind="round", width=3, point=0.9}
r:reload(pile{{"zinc white",2}}, 0.7); r:touch(427, 449, {pressure=0.5})
r:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.8); r:stroke({{736,503},{744,503}}, {pressure={r:pressure_for(2.5), r:pressure_for(2.5)}})
-- a little speech bubble between them, three dots: she is mid-sentence
local bub = ellipse(520, 400, 30, 18) + poly({{500,410},{486,428},{510,414}})
F({{492,384},{548,384},{552,412},{510,416},{488,430},{496,412},{490,396}}, pile{{"zinc white",2.5}})
for _,x in ipairs({508,520,532}) do r:reload(pile{{"ultramarine ash",1},{"bone black",0.4}}, 0.7); r:touch(x, 400, {pressure=0.7}) end

--@ chunk 13
print(wait(3*24*60))
local r = brush{kind="round", width=3, point=0.9}
for _,x in ipairs({507,520,533}) do r:reload(pile{{"ultramarine ash",1},{"bone black",0.6}}, 0.8); r:touch(x, 400, {pressure=0.8}) end
-- the far corner where the world stops: horizontal dither of pale fog, thickening into the corner
local excl = (CRT_F + CRT_S + CRT_T + TOP + FRONT + LEGS + POT + AV + BEAN):grow(2)
local FOG = pile{{"zinc white",2},{"cobalt violet",0.25},{"ultramarine ash",0.3}}
local f = brush{kind="flat", width=4}
for y=134,520,5 do
  local n = 1 + math.floor(rand(0,3))
  for i=1,n do
    local x1 = 742 + rand(-10, 30)
    local len = rand(20, 90) * (1 - math.abs(y-320)/400)
    f:reload(FOG, 0.35)
    f:stroke({{x1 - len, y}, {x1 + len*0.5, y}}, {pressure={0.3, 0.3}, clip=-excl})
  end
end
-- scanlines: faint horizontal lines over the whole picture
local s = brush{kind="round", width=1.5, point=0.5}
for y=6,744,9 do
  s:reload(pile{{"ultramarine ash",1},{"lead white",1}}, 0.25)
  s:stroke({{0,y},{1000,y}}, {pressure={0.12, 0.12}})
end

--@ chunk 14
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}) end
-- the potted plant, moved where it can be seen: on the floor by the window, triangle leaves
local px, py = 282, 500
F({{px-22,py-34},{px+22,py-34},{px+16,py},{px-16,py}}, pile{{"red earth",1},{"Mars orange",0.7},{"lead white",0.4}})
F({{px-24,py-38},{px+24,py-38},{px+24,py-32},{px-24,py-32}}, pile{{"Mars orange",1},{"lead white",0.8}})
local G1 = pile{{"emerald green",1},{"viridian",0.3},{"lead white",0.6}}
local G2 = pile{{"viridian",1},{"emerald green",0.4},{"lead white",0.15}}
local Ls = {{{px,py-38},{px-40,py-110},{px-10,py-40}},{{px,py-38},{px,py-140},{px+12,py-42}},{{px,py-38},{px+44,py-104},{px+10,py-40}},{{px-2,py-38},{px-56,py-70},{px-14,py-36}},{{px+2,py-38},{px+58,py-66},{px+14,py-36}},{{px,py-40},{px-22,py-128},{px-4,py-44}}}
for i,t in ipairs(Ls) do F(t, (i%2==0) and G1 or G2) end
local sh = ellipse(px+8, py+2, 26, 5)
work(sh, {hand="detail", pile=pile{{"ultramarine ash",1},{"viridian",0.2},{"lead white",0.5}}, coverage=3, fill=true, clip=sh - poly({{px-22,py-34},{px+22,py-34},{px+16,py},{px-16,py}})})
