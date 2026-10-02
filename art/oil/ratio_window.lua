-- easel session "ratio_window": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=4/3, linen={18,16}, seed=6262, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.5},{"cobalt violet",0.3},{"ultramarine ash",0.3}}, um=30, apply="brush"}}}
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
-- the REAL outside through the window: painted loose and dark, wet into wet
local W = WIN
local SPACE = pile{{"bone black",1.5},{"ultramarine blue",0.6},{"burnt sienna",0.3}}
local COR1 = pile{{"burnt sienna",1.5},{"Mars orange",1},{"bone brown",0.5}}
local COR2 = pile{{"Mars orange",1.2},{"cadmium yellow",0.8},{"lead white",0.5}}
local SUNP = pile{{"zinc white",3},{"lemon chrome",0.4}}
local HULL0 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local HULL1 = pile{{"burnt sienna",1.5},{"yellow ochre",1},{"bone black",0.3}}
local SX, SY = 590, 250
local sunm = ellipse(SX, SY, 48, 48)
local c2 = ellipse(SX, SY, 95, 90):roughen(10, 50, 3)
local c1 = ellipse(SX, SY, 175, 165):roughen(16, 70, 4)
local hull = W * below(function(x) return 340 + 0.0012*(x-470)^2 end)
local tan = function(x,y) return math.atan(y-SY, x-SX) + math.pi/2 end
work(W - c1 - hull, {hand="body", pile=SPACE, coverage=3, fill=true, tool="filbert 10", angle=tan, clip=W})
work((c1 - c2) * W - hull, {hand="body", pile=COR1, coverage=3, fill=true, tool="filbert 8", angle=tan, clip=W})
work((c2 - sunm) * W - hull, {hand="body", pile=COR2, coverage=3, fill=true, tool="filbert 6", angle=tan, clip=W})
work(sunm * W - hull, {hand="body", pile=SUNP, coverage=3.5, fill=true, tool="filbert 6", angle=tan, clip=W})
work(hull * above(function(x) return 372 end), {hand="body", pile=HULL1, coverage=3, fill=true, tool="filbert 8", angle=0, clip=W})
work(hull * below(function(x) return 372 end), {hand="body", pile=HULL0, coverage=3, fill=true, tool="filbert 10", angle=0, clip=W})
blend((c1:grow(20) - sunm) * W - hull, {angle=tan, tool={kind="badger", width=16}, pressure={0.3,0.5}})
OUTSIDE_SUN = {SX, SY}

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

--@ chunk 5
print(wait(24*60))
-- the hull: rows of scale-plates catching the corona, a hot rim along the limb
local r = brush{kind="round", width=3, point=0.7}
local LIP = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}}
local LIP2 = pile{{"yellow ochre",1},{"Mars orange",0.6},{"lead white",0.6}}
local DK = pile{{"bone brown",2},{"bone black",0.8}}
local function limb(x) return 340 + 0.0012*(x-470)^2 end
for row=0,4 do
  local y0 = 350 + row*13 + row*row*2
  local w = 16 + row*8
  local x = 320 + (row % 2)*w/2
  while x < 690 do
    local y = y0 + 0.0012*(x-470)^2*(1 - row*0.15)
    local glare = math.exp(-((x-590)/120)^2) * (1 - row*0.18)
    local arc = {} for k=0,8 do local a = math.pi*(0.1 + 0.8*k/8); arc[#arc+1] = {x + w*0.45*math.cos(a), y - w*0.18*math.sin(a)} end
    if y > limb(x) + 3 and y < 408 then
      r:reload(DK, 0.6); r:stroke(arc, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}, clip=WIN})
      local a2 = {} for _,q in ipairs(arc) do a2[#a2+1] = {q[1], q[2]-2} end
      r:reload(glare > 0.35 and LIP or LIP2, 0.6); r:stroke(a2, {pressure={r:pressure_for(0.8+glare), r:pressure_for(0.8+glare)}, swell={0.2,1,1,0.2}, clip=WIN})
    end
    x = x + w
  end
end
local pts = {} for x=320,680,20 do pts[#pts+1] = {x, limb(x) + 1} end
local hot = brush{kind="round", width=4, point=0.7}
hot:reload(pile{{"zinc white",2},{"lemon chrome",0.4}}, 0.7); hot:stroke(pts, {pressure={hot:pressure_for(1), hot:pressure_for(2.5)}, swell={0.3,0.6,1,1,0.6}, clip=WIN})

--@ chunk 6
print(wait(2*24*60))
-- window frame: thick flat mullions
local FR = rect(312,152,376,10) + rect(312,408,376,12) + rect(312,152,10,268) + rect(678,152,10,268) + rect(495,160,10,250) + rect(320,280,360,8)
work(FR, {hand="detail", pile=pile{{"lead white",2},{"Mars orange",0.3},{"rose madder",0.2}}, coverage=4, fill=true, clip=FR})
FRM = FR
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

--@ chunk 7
print(wait(2*24*60))
-- the real light falls into the flat room: a warm skewed pool, painted flat like everything in here
local excl = (BEAN + TOP + FRONT + LEGS + CRT_F + CRT_S + CRT_T):grow(1)
POOL = poly({{330,472},{690,472},{820,700},{260,700}}) * FLOOR - excl
work(POOL - TILES, {hand="body", pile=pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.3}}, coverage=4, fill=true, tool="filbert 6", angle=0, clip=POOL - TILES, load=1})
work(POOL * TILES, {hand="body", pile=pile{{"lead white",1.4},{"viridian",0.25},{"cadmium yellow",0.45},{"Mars orange",0.15}}, coverage=4, fill=true, tool="filbert 6", angle=0, clip=POOL * TILES, load=1})
-- the window light on the beanbag's top facet and the CRT's top
local f = poly({{300,560},{380,540},{470,555},{430,600},{340,604}})
work(f, {hand="detail", pile=pile{{"lead white",2},{"rose madder",0.3},{"cadmium yellow",0.3}}, coverage=4, fill=true, clip=f})
work(CRT_T, {hand="detail", pile=pile{{"lead white",2.5},{"cadmium yellow",0.4}}, coverage=4, fill=true, clip=CRT_T})
-- Ratio at the window, from behind, palms on the glass
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local HAIR2 = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.35}}
local TOPW = pile{{"zinc white",2.5},{"cerulean blue",0.08}}
local NAVY = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
RT = {}
RT.legL = F({{476,440},{492,440},{490,492},{478,492}}, NAVY)
RT.legR = F({{502,440},{518,440},{518,492},{506,492}}, NAVY)
RT.shoes = F({{472,490},{494,490},{496,502},{470,502}}, pile{{"rose madder",1},{"lead white",0.8}}) + F({{504,490},{526,490},{528,502},{502,502}}, pile{{"rose madder",1},{"lead white",0.8}})
RT.skirt = F({{468,404},{530,404},{540,446},{458,446}}, TOPW)
RT.armL = F({{474,372},{462,352},{452,334},{442,330},{448,344},{462,366},{470,382}}, TOPW)
RT.armR = F({{524,372},{536,352},{548,334},{558,330},{552,344},{538,366},{528,382}}, TOPW)
RT.handL = F({{436,318},{450,318},{452,334},{438,336}}, SKIN)
RT.handR = F({{548,318},{562,318},{564,336},{550,334}}, SKIN)
RT.hair = F({{462,300},{478,282},{520,282},{536,300},{544,340},{540,400},{530,436},{512,428},{500,442},{486,428},{468,436},{456,400},{454,340}}, HAIR)
RT.lock1 = F({{466,330},{478,300},{486,360},{474,430},{462,410}}, HAIR2)
RT.lock2 = F({{508,296},{522,300},{532,350},{520,420},{506,380}}, HAIR2)
RATIO = RT.legL + RT.legR + RT.shoes + RT.skirt + RT.armL + RT.armR + RT.handL + RT.handR + RT.hair

--@ chunk 8
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local TOPW = pile{{"zinc white",2.5},{"cerulean blue",0.08}}
local NAVY = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
-- larger, arms clear of the hair, reaching up and out to the glass
RW_ = {}
RW_.legL = F({{470,440},{490,440},{488,500},{474,500}}, NAVY)
RW_.legR = F({{506,440},{526,440},{524,500},{510,500}}, NAVY)
RW_.shoeL = F({{466,496},{492,496},{494,510},{464,510}}, pile{{"rose madder",1},{"lead white",0.8}})
RW_.shoeR = F({{506,496},{532,496},{534,510},{504,510}}, pile{{"rose madder",1},{"lead white",0.8}})
RW_.skirt = F({{458,396},{540,396},{554,448},{444,448}}, TOPW)
RW_.armL = F({{462,360},{440,334},{416,306},{404,298},{410,318},{432,346},{452,374}}, TOPW)
RW_.armR = F({{536,360},{558,334},{582,306},{594,298},{588,318},{566,346},{546,374}}, TOPW)

--@ chunk 9
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local HAIR2 = pile{{"bone black",1.4},{"ultramarine blue",0.6},{"lead white",0.25}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
F({{394,280},{410,278},{414,300},{398,304}}, SKIN)
F({{588,278},{604,280},{602,304},{586,300}}, SKIN)
F({{456,276},{474,250},{524,250},{542,276},{550,330},{546,400},{534,444},{516,432},{500,450},{484,432},{464,444},{452,400},{448,330}}, HAIR)
F({{462,320},{476,276},{486,350},{474,436},{458,410}}, HAIR2)
F({{512,272},{528,280},{540,340},{526,428},{510,376}}, HAIR2)

--@ chunk 10
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
-- paint out the first, smaller figure's hands on the glass
F({{434,316},{453,316},{454,338},{434,338}}, pile{{"burnt sienna",1.5},{"Mars orange",0.7},{"bone brown",0.6}})
F({{546,316},{566,316},{566,338},{546,338}}, pile{{"Mars orange",1.2},{"cadmium yellow",0.6},{"lead white",0.4}})
F({{454,396},{546,396},{534,444},{516,432},{500,450},{484,432},{464,444}}, pile{{"bone black",2},{"ultramarine blue",0.4}})

--@ chunk 11
print(wait(3*24*60))
local r = brush{kind="round", width=5, point=0.8}
local WARM = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",0.8}}
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6}}
-- the real light on her: a warm rim down the hair's sunward edge, the arms and the hands
r:reload(WARM, 0.7); r:stroke({{528,256},{544,280},{551,330},{547,400},{536,440}}, {pressure={r:pressure_for(2.5), r:pressure_for(1)}})
r:reload(HOT, 0.7); r:stroke({{560,330},{582,306},{594,298}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(WARM, 0.6); r:stroke({{416,306},{438,332},{458,356}}, {pressure={r:pressure_for(1), r:pressure_for(1.6)}})
r:reload(HOT, 0.6); r:stroke({{587,280},{603,282}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
r:reload(WARM, 0.6); r:stroke({{410,280},{396,282}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}})
r:reload(WARM, 0.6); r:stroke({{540,400},{552,446}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(WARM, 0.5); r:stroke({{522,442},{523,498}}, {pressure={r:pressure_for(1.6), r:pressure_for(1)}})
-- facets of light in the hair
local H = pile{{"ultramarine ash",0.6},{"Mars orange",0.4},{"bone black",0.6},{"lead white",0.4}}
r:reload(H, 0.6); r:stroke({{512,272},{528,300},{536,350}}, {pressure={r:pressure_for(3), r:pressure_for(1)}})
r:reload(H, 0.5); r:stroke({{476,262},{500,254},{522,258}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
-- her shadow thrown toward us across the warm pool, a flat cool shape
local sh = poly({{466,510},{534,510},{570,640},{430,640}}) - BEAN
work(sh, {hand="detail", pile=pile{{"ultramarine ash",1},{"cobalt violet",0.3},{"lead white",0.7},{"yellow ochre",0.2}}, coverage=5, fill=true, clip=sh, load=1})
-- the fog in the far corner, retreated: a thinner dither only near the corner
local excl = (CRT_F + CRT_S + CRT_T + TOP + FRONT + LEGS + WIN + FRM):grow(2)
local FOG = pile{{"zinc white",2},{"cobalt violet",0.25},{"ultramarine ash",0.3}}
local f = brush{kind="flat", width=4}
for y=140,500,6 do
  if rand(0,1) < 0.7 then
    local x1 = 748 + rand(-6, 20); local len = rand(10, 45) * (1 - math.abs(y-320)/400)
    f:reload(FOG, 0.35); f:stroke({{x1 - len, y}, {x1 + len*0.4, y}}, {pressure={0.3, 0.3}, clip=-excl})
  end
end
-- scanlines over the room, but not across the real window
local s = brush{kind="round", width=1.5, point=0.5}
for y=6,744,9 do
  s:reload(pile{{"ultramarine ash",1},{"lead white",1}}, 0.25)
  s:stroke({{0,y},{1000,y}}, {pressure={0.12, 0.12}, clip=-(WIN:grow(1))})
end

--@ chunk 12
print(wait(5*24*60)); print(drying(500,420))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
F({{456,380},{544,380},{536,444},{516,432},{500,450},{484,432},{464,444},{452,400}}, HAIR)
F({{714,478},{750,476},{760,500},{758,544},{708,544},{704,500}}, pile{{"bone black",1.5},{"ultramarine ash",0.5},{"lead white",0.25}})
F({{708,500},{756,498},{756,506},{708,508}}, pile{{"bone black",2}})
F({{680,456},{784,452},{784,462},{680,466}}, pile{{"cobalt blue",1},{"cerulean blue",0.6},{"lead white",0.4}})

--@ chunk 13
print(wait(3*24*60))
local r = brush{kind="round", width=5, point=0.8}
r:reload(pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",0.8}}, 0.6); r:stroke({{544,380},{538,420},{534,442}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})
r:reload(pile{{"zinc white",2},{"cerulean blue",1}}, 0.8); r:stroke({{736,503},{744,503}}, {pressure={r:pressure_for(2.5), r:pressure_for(2.5)}})
