-- easel session "hammershoi": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=4/3, linen={18,16}, seed=1905,
  ground={{pile={{"lead white",2},{"bone black",0.5},{"raw sienna",0.3},{"yellow ochre",0.1}}, um=80, apply="knife", texture=0.2}}}
FL = 560
WALLM = rect(0, 0, 1000, FL)
FLOORM = rect(0, FL, 1000, 750 - FL)
D1 = rect(300, 140, 140, FL - 140)
WIN = rect(640, 80, 140, 350)
local wall = pile{{"lead white",2},{"bone black",0.55},{"raw sienna",0.3},{"ultramarine ash",0.1}, medium=0.3}
local floor = pile{{"lead white",1.2},{"bone black",0.6},{"raw sienna",0.5},{"burnt sienna",0.1}, medium=0.3}
work(WALLM - D1 - WIN, {hand="body", pile=wall, coverage=3, fill=true, clip=true, angle=math.pi/2, load=0.9})
work(FLOORM, {hand="body", pile=floor, coverage=3, fill=true, clip=true, angle=0, load=0.9})
-- the room beyond the first door: its wall lit, a second door darker, a third lit again
local w2 = pile{{"lead white",2.4},{"bone black",0.4},{"raw sienna",0.3}, medium=0.3}
local w3 = pile{{"lead white",1.4},{"bone black",0.65},{"raw sienna",0.3}, medium=0.3}
local w4 = pile{{"lead white",2.6},{"bone black",0.3},{"yellow ochre",0.2}, medium=0.3}
D2 = rect(338, 225, 66, 275)
D3 = rect(356, 285, 30, 190)
work(D1 - D2, {hand="body", tool="filbert 6", pile=w2, coverage=3, fill=true, clip=true, angle=math.pi/2, load=0.9})
work(D2 - D3, {hand="body", tool="filbert 4", pile=w3, coverage=3, fill=true, clip=true, angle=math.pi/2, load=0.9})
work(D3, {hand="body", tool="filbert 3", pile=w4, coverage=3, fill=true, clip=true, angle=math.pi/2, load=0.9})
-- the window: pale northern light
local sky = pile{{"lead white",3},{"bone black",0.12},{"ultramarine ash",0.15}, medium=0.2}
work(WIN, {hand="body", tool="filbert 6", pile=sky, coverage=3, fill=true, clip=true, angle=math.pi/2, load=0.9})
print(wait(5*1440))

--@ chunk 2
local wall = pile{{"lead white",1.5},{"bone black",0.75},{"raw sienna",0.3},{"ultramarine ash",0.12}}
local wallTop = pile{{"lead white",1.2},{"bone black",0.85},{"raw sienna",0.3},{"ultramarine ash",0.12}}
local floor = pile{{"lead white",1},{"bone black",0.75},{"burnt sienna",0.25},{"raw sienna",0.2}}
ARCH1 = rect(286, 128, 168, FL - 128) - D1
work(WALLM - D1 - WIN - ARCH1 - rect(626, 66, 168, 378), {hand="body", pile=wall, coverage=3.2, fill=true, clip=true, angle=math.pi/2, load=1})
work(rect(0, 0, 1000, 60) - ARCH1, {hand="body", pile=wallTop, coverage=2.5, fill=true, clip=true, angle=0, load=0.9})
work(FLOORM, {hand="body", pile=floor, coverage=3.2, fill=true, clip=true, angle=0, load=1})
-- white-grey architraves round door and window
local trim = pile{{"lead white",2.5},{"bone black",0.35},{"raw sienna",0.15}}
work(ARCH1, {hand="detail", tool="round 3", pile=trim, coverage=4, fill=true, load=1})
work(rect(626, 66, 168, 378) - WIN, {hand="detail", tool="round 3", pile=trim, coverage=4, fill=true, load=1})
-- dado: a skirting and a chair rail, panels between
local dado = pile{{"lead white",1.7},{"bone black",0.7},{"raw sienna",0.25}}
work(rect(0, 535, 286, 25) + rect(454, 535, 546, 25), {hand="detail", tool="round 3", pile=dado, coverage=4, fill=true, load=1})
work(rect(0, 420, 286, 7) + rect(454, 420, 546, 7), {hand="detail", tool="round 2", pile=trim, coverage=4, fill=true, load=1})
print(wait(5*1440))

--@ chunk 3
local r2wall = pile{{"lead white",1.9},{"bone black",0.6},{"raw sienna",0.3}}
local r2floor = pile{{"lead white",1},{"bone black",0.8},{"burnt sienna",0.25},{"raw sienna",0.2}}
local jamb = pile{{"lead white",1},{"bone black",0.9},{"raw sienna",0.25}}
local leaf = pile{{"lead white",1.4},{"bone black",0.8},{"raw sienna",0.25},{"ultramarine ash",0.1}}
local r3 = pile{{"lead white",1.1},{"bone black",0.85},{"raw sienna",0.3}}
local r4 = pile{{"lead white",2.6},{"bone black",0.3},{"yellow ochre",0.2}}
local trim = pile{{"lead white",2.4},{"bone black",0.4},{"raw sienna",0.15}}
work(D1, {hand="detail", tool="round 3", pile=r2wall, coverage=4, fill=true, load=1})
work(poly({{300, 560}, {440, 560}, {440, 512}, {300, 512}}), {hand="detail", tool="round 3", pile=r2floor, coverage=4, fill=true, load=1})
-- left jamb (wall thickness) in shadow, the opened door leaf on the right, swung into the next room
work(poly({{300, 140}, {312, 150}, {312, 516}, {300, 560}}), {hand="detail", tool="round 2", pile=jamb, coverage=4, fill=true, load=1})
work(poly({{440, 140}, {414, 160}, {414, 524}, {440, 560}}), {hand="detail", tool="round 2", pile=leaf, coverage=4, fill=true, load=1})
print(wait(3*1440))
-- second doorway in the next room, its trim, the third room beyond, and a lit fourth
D2b = rect(342, 250, 56, 262)
work(rect(336, 244, 68, 268) - D2b, {hand="detail", tool="round 2", pile=trim, coverage=4, fill=true, load=1})
work(D2b, {hand="detail", tool="round 2", pile=r3, coverage=4, fill=true, load=1})
work(rect(342, 490, 56, 22), {hand="detail", tool="round 2", pile=r2floor, coverage=4, fill=true, load=1})
D3b = rect(360, 300, 22, 178)
work(D3b, {hand="detail", tool="round 1.6", pile=r4, coverage=4, fill=true, load=1})
work(rect(360, 478, 22, 12), {hand="detail", tool="round 1.6", pile=r2floor, coverage=4, fill=true, load=1})
-- fix: the chair rail must not cross the window
local sky = pile{{"lead white",3},{"bone black",0.12},{"ultramarine ash",0.15}}
work(rect(640, 414, 140, 16), {hand="detail", tool="round 2", pile=sky, coverage=4, fill=true, load=1})
print(wait(4*1440))

--@ chunk 4
-- the light on the floor from the window, soft-edged
LIGHT = poly({{632, 562}, {792, 562}, {752, 712}, {528, 712}})
local fl = pile{{"lead white",1.8},{"bone black",0.5},{"raw sienna",0.25},{"yellow ochre",0.1}}
work(LIGHT, {hand="body", tool="filbert 6", pile=fl, coverage=3.2, fill=true, clip=true, angle=0, load=1})
blend((LIGHT:grow(8) - LIGHT:shrink(8)), {angle=0, tool={kind="badger", width=12}})
-- floorboards, converging toward the far doorway
local gb = brush{kind="round", width=1.4, point=0.6}
local seam = pile{{"lead white",0.7},{"bone black",0.9},{"burnt sienna",0.25}}
for x0 = -500, 1500, 62 do
  local xf = 370 + (x0 - 370) * 0.18
  local t = (750 - 560) / (750 - 560)
  gb:reload(seam, 0.5); gb:stroke({{lerp(370, x0, 0.18), 562}, {x0, 750}}, {pressure={0.25, 0.45}})
end
-- the docent at the window, seen from behind: tall, narrow, still
local fig = pile{{"lead white",0.8},{"bone black",1},{"raw sienna",0.3},{"burnt sienna",0.1}}
DOC = poly({{702, 228}, {712, 220}, {722, 228}, {724, 245}, {736, 260}, {742, 330}, {746, 430}, {750, 548}, {694, 548}, {698, 430}, {700, 330}, {704, 262}, {706, 246}}, true)
work(DOC, {hand="detail", tool="round 2.5", pile=fig, coverage=4.5, fill=true, load=1})
print(wait(4*1440))

--@ chunk 5
local sky = pile{{"lead white",3},{"bone black",0.12},{"ultramarine ash",0.15}}
local wall = pile{{"lead white",1.5},{"bone black",0.75},{"raw sienna",0.3},{"ultramarine ash",0.12}}
local dado = pile{{"lead white",1.7},{"bone black",0.7},{"raw sienna",0.25}}
local trim = pile{{"lead white",2.5},{"bone black",0.35},{"raw sienna",0.15}}
local floor = pile{{"lead white",1},{"bone black",0.75},{"burnt sienna",0.25},{"raw sienna",0.2}}
local old = DOC:grow(3)
work(old * WIN, {hand="detail", tool="round 2.5", pile=sky, coverage=4.5, fill=true, load=1})
work(old * (rect(626, 66, 168, 378) - WIN), {hand="detail", tool="round 2.5", pile=trim, coverage=4.5, fill=true, load=1})
work(old * rect(0, 444, 1000, 91), {hand="detail", tool="round 2.5", pile=wall, coverage=4.5, fill=true, load=1})
work(old * rect(0, 535, 1000, 25), {hand="detail", tool="round 2.5", pile=dado, coverage=4.5, fill=true, load=1})
work(LIGHT:grow(14) * FLOORM, {hand="body", tool="filbert 6", pile=floor, coverage=3.5, fill=true, clip=true, angle=0, load=1})
print(wait(4*1440))
-- the docent: head bowed a little, square shoulders, a long robe to the floor
local fig = pile{{"lead white",0.9},{"bone black",1},{"raw sienna",0.3},{"burnt sienna",0.1}}
DOC = ellipse(719, 216, 7.5, 9.5) + poly({{714, 222}, {725, 222}, {726, 234}, {713, 234}})
    + poly({{700, 240}, {706, 233}, {733, 233}, {740, 241}, {742, 290}, {738, 340}, {744, 440}, {749, 552}, {695, 552}, {698, 440}, {702, 340}, {698, 290}}, true)
work(DOC, {hand="detail", tool="round 2", pile=fig, coverage=4.5, fill=true, load=1})
-- the window's light on the floor, a quiet even shape
LIGHT = poly({{640, 562}, {786, 562}, {748, 706}, {548, 706}})
local fl = pile{{"lead white",1.45},{"bone black",0.6},{"raw sienna",0.25},{"yellow ochre",0.1}}
work(LIGHT - DOC, {hand="body", tool="filbert 6", pile=fl, coverage=3.5, fill=true, clip=true, angle=0, load=1})
-- the docent's shadow falling toward us in the light
local sh = pile{{"lead white",0.9},{"bone black",0.8},{"burnt sienna",0.25},{"raw sienna",0.2}}
work(poly({{698, 562}, {746, 562}, {710, 700}, {664, 700}}) * LIGHT, {hand="body", tool="filbert 5", pile=sh, coverage=3.2, fill=true, clip=true, angle=1.9, load=1})
blend((LIGHT:grow(6) - LIGHT:shrink(6)) * FLOORM, {angle=1.7, tool={kind="badger", width=10}})
print(wait(4*1440))
-- floorboards, all across
local gb = brush{kind="round", width=1.4, point=0.6}
local seam = pile{{"lead white",0.6},{"bone black",0.9},{"burnt sienna",0.25}}
for x0 = -520, 1520, 58 do
  gb:reload(seam, 0.5); gb:stroke({{lerp(370, x0, 0.2), 562}, {x0, 750}}, {pressure={0.3, 0.5}})
end

--@ chunk 6
local trim = pile{{"lead white",2.2},{"bone black",0.45},{"raw sienna",0.15}}
local wood = pile{{"bone black",1},{"burnt sienna",0.45},{"lead white",0.5},{"raw sienna",0.3}}
local woodL = pile{{"lead white",1.1},{"bone black",0.7},{"burnt sienna",0.3},{"raw sienna",0.3}}
local r = brush{kind="round", width=4.5, point=0.2}
local r2 = brush{kind="round", width=3, point=0.3}
local function st(b, p, pts, clipM) b:reload(p, 0.8); b:stroke(pts, {pressure={0.75, 0.75}, ramps={0.03, 0.03}, clip=clipM}) end
local notDoc = -(DOC:grow(1))
st(r, trim, {{710, 82}, {710, 428}}, notDoc)
st(r, trim, {{642, 205}, {778, 205}}, notDoc)
st(r, trim, {{642, 320}, {778, 320}}, notDoc)
-- the chair, against the wall left of the door
local seat = poly({{150, 468}, {222, 468}, {226, 478}, {146, 478}})
work(seat, {hand="detail", tool="round 2", pile=wood, coverage=4.5, fill=true, load=1})
st(r2, wood, {{156, 468}, {158, 380}})
st(r2, wood, {{216, 468}, {214, 380}})
st(r2, wood, {{157, 384}, {215, 384}})
st(r2, wood, {{157, 404}, {215, 404}})
for _, l in ipairs({{{150, 478}, {148, 562}}, {{222, 478}, {225, 562}}, {{162, 478}, {164, 552}}, {{210, 478}, {209, 552}}}) do st(r2, wood, l) end
st(brush{kind="round", width=1.6, point=0.5}, woodL, {{150, 467.5}, {222, 467.5}})
-- the table: bare, between door and window
local top = poly({{470, 462}, {612, 462}, {612, 472}, {470, 472}})
work(top, {hand="detail", tool="round 2", pile=wood, coverage=4.5, fill=true, load=1})
work(rect(474, 472, 134, 12), {hand="detail", tool="round 2", pile=wood, coverage=4, fill=true, load=1})
for _, x in ipairs({478, 602}) do st(r, wood, {{x, 484}, {x, 562}}) end
st(brush{kind="round", width=1.6, point=0.5}, woodL, {{470, 461.5}, {612, 461.5}})
-- soft shadows under chair and table
local sh = pile{{"lead white",0.7},{"bone black",0.85},{"burnt sienna",0.25}, medium=0.3}
work(poly({{140, 560}, {232, 560}, {240, 572}, {132, 572}}) + poly({{466, 560}, {616, 560}, {626, 574}, {456, 574}}), {hand="detail", tool="round 2.5", pile=sh, coverage=3, fill=true, load=0.8})
print(wait(4*1440))
