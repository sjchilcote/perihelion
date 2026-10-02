-- easel session "holdout": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=1.5, linen=18, seed=31, ground={{pile={{"lead white",2},{"burnt sienna",1},{"ultramarine blue",1}}, um=60, apply="roller"}}}

--@ chunk 2
function petal(cx, by, w, h)
  return poly({{cx - w/2, by}, {cx - w/2, by - h*0.5}, {cx - w*0.3, by - h*0.82}, {cx, by - h}, {cx + w*0.3, by - h*0.82}, {cx + w/2, by - h*0.5}, {cx + w/2, by}}, true)
end
DOORS = {{105,470,140,340}, {300,425,100,255}, {500,405,88,215}, {700,425,100,255}, {895,470,140,340}}
W = pile{{"burnt sienna",1.5},{"bone black",1.5},{"ultramarine blue",0.5}}
FL = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
GC = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt violet",0.3}}
GM = pile{{"cerulean blue",1},{"ultramarine blue",1},{"zinc white",1},{"cobalt violet",0.5}}
GE = pile{{"ultramarine blue",1},{"cobalt violet",0.6},{"bone black",0.8}}
local doors = nil
for _, d in ipairs(DOORS) do
  local m = petal(d[1], d[2], d[3], d[4])
  doors = doors and (doors + m) or m
end
DOORM = doors
local wall = above(function(x) return 440 + 40 * ((x - 500) / 500)^2 end)
work(wall - doors, {hand="body", pile=W, angle=1.57, coverage=4, load=1, fill=true, clip=true})
work(-wall, {hand="body", pile=FL, angle=0, coverage=4, load=1, fill=true, clip=true})
for _, d in ipairs(DOORS) do
  local cx, by, w, h = d[1], d[2], d[3], d[4]
  local m = petal(cx, by, w, h)
  work(m, {hand="body", tool="filbert 4", pile=GM, angle=1.57, coverage=4, fill=true, clip=true})
  work(m - petal(cx, by, w * 0.8, h * 0.9), {hand="detail", pile=GE, coverage=3.5})
  -- the same doorway again, inside the doorway
  local inner = petal(cx, by - h * 0.12, w * 0.5, h * 0.55)
  work(inner, {hand="detail", pile=W, coverage=4})
  work(petal(cx, by - h * 0.15, w * 0.34, h * 0.4), {hand="detail", pile=GC, coverage=4})
  work(petal(cx, by - h * 0.17, w * 0.16, h * 0.22), {hand="detail", pile=W, coverage=4})
end

--@ chunk 3
function rib(pts, w0, w1)
  local n = #pts
  local w = {}
  for i = 1, n do w[i] = lerp(w0, w1, (i-1)/(n-1)) end
  return ribbon(pts, w)
end
function shiftpts(pts, dx, dy) local o = {} for i, p in ipairs(pts) do o[i] = {p[1]+dx, p[2]+dy} end return o end
SIL2 = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
MAG = pile{{"magenta",1},{"cobalt violet",1},{"bone black",0.6}}
CY = pile{{"cerulean blue",1},{"emerald green",0.4},{"zinc white",1}}
BRZ = pile{{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.4}}
-- doorways meet the floor: cold light spilled out of each across the floor
for _, d in ipairs(DOORS) do
  local cx, by, w = d[1], d[2], d[3]
  work(poly({{cx - w*0.45, by}, {cx + w*0.45, by}, {cx + w*0.9 + (500-cx)*0.35, by + 70}, {cx - w*0.9 + (500-cx)*0.35, by + 70}}, true), {hand="detail", pile=GE, coverage=2})
end
-- things coming through: shards of inconsistency at doors 2, 4, 5; a corrupted Testator at door 1
for _, s in ipairs({ {{270,300},{318,262},{332,330},{296,352}}, {{684,280},{730,318},{706,372},{672,340}},
    {{860,250},{930,300},{900,380},{848,340}}, {{880,380},{940,420},{906,456}}, {{486,300},{520,282},{514,340}} }) do
  work(poly(s), {hand="detail", pile=SIL2, coverage=4})
  work(poly(s) - poly(shiftpts and shiftpts(s, 3, 2) or s), {hand="detail", pile=MAG, coverage=3})
end
for _, s in ipairs({ {{292,318},{314,300},{306,340}}, {{700,320},{716,336},{698,350}}, {{880,320},{900,340},{880,360}} }) do
  work(poly(s), {hand="detail", pile=CY, coverage=3.5})
end
local tes = poly({{80,470},{82,380},{92,320},{106,300},{122,320},{132,380},{136,470}}, true)
work(tes, {hand="detail", pile=SIL2, coverage=4})
work(ellipse(107,318,11,13), {hand="detail", pile=BRZ, coverage=3.5})
work(ellipse(107,318,5,6), {hand="detail", pile=CY, coverage=3.5})
work(rib({{84,380},{70,420},{60,440}}, 7, 4) + rib({{132,380},{150,410},{158,436}}, 7, 4), {hand="detail", pile=SIL2, coverage=4})
-- the heart: a worn bronze dais, the scorch of decades
work(ellipse(500,560,330,80) - ellipse(500,560,310,70), {hand="detail", pile=BRZ, coverage=3})
stipple(ellipse(500,580,230,55), {pile=SIL2, width=2.5, coverage=0.6, cluster=0.85})
-- the Commando: braced, rifle raised at the left doorway
local fig = rib({{440,606},{458,560},{478,512}}, 16, 20) + rib({{566,600},{548,556},{522,512}}, 16, 20)
  + poly({{470,520},{532,520},{540,470},{534,420},{470,416},{462,470}}, true)
  + poly({{518,410},{560,416},{566,470},{540,480},{524,450}}, true)
  + ellipse(498,396,15,17)
  + rib({{474,428},{452,410},{440,388}}, 14, 11) + rib({{528,430},{500,412},{470,392}}, 13, 10)
  + rib({{548,446},{486,392},{414,358}}, 11, 8)
work(fig, {hand="detail", pile=SIL2, coverage=4})
work(rib({{428,608},{458,608}}, 9, 9) + rib({{554,602},{584,604}}, 9, 9), {hand="detail", pile=SIL2, coverage=4})

--@ chunk 4
wait(24*60)
WARM = pile{{"Mars orange",1},{"burnt sienna",1},{"lead white",0.5},{"cadmium red",0.3}}
WARM2 = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",1}}
FLASH = pile{{"zinc white",2},{"lemon chrome",0.6}}
-- warm light from the flash pooled on the floor round his feet
local pool = ellipse(480,590,170,40):roughen(8,40,3)
work(pool, {hand="detail", pile=WARM, coverage=3})
work(ellipse(470,590,90,20):roughen(6,30,4), {hand="detail", pile=WARM2, coverage=2.5})
-- the figure again, fully opaque
local fig = rib({{440,606},{458,560},{478,512}}, 16, 20) + rib({{566,600},{548,556},{522,512}}, 16, 20)
  + poly({{470,520},{532,520},{540,470},{534,420},{470,416},{462,470}}, true)
  + poly({{518,410},{560,416},{566,470},{540,480},{524,450}}, true)
  + ellipse(498,396,15,17)
  + rib({{474,428},{452,410},{440,388}}, 14, 11) + rib({{528,430},{500,412},{470,392}}, 13, 10)
  + rib({{548,446},{486,392},{414,358}}, 11, 8)
  + rib({{428,608},{458,608}}, 9, 9) + rib({{554,602},{584,604}}, 9, 9)
work(fig, {hand="detail", pile=SIL2, coverage=4.5, load=1})
-- warm rims toward the flash, cold rims from the doors behind
for _, r in ipairs({ {{416,354},{486,386},{540,436}}, {{484,382},{486,396},{492,410}}, {{440,384},{450,406},{470,424}},
    {{464,420},{460,470},{468,516}}, {{474,516},{456,560},{436,604}}, {{430,603},{458,603}} }) do
  work(rib(r, 2.2, 1.6), {hand="detail", pile=WARM2, coverage=3})
end
for _, r in ipairs({ {{512,384},{513,398},{508,410}}, {{560,418},{567,450},{562,474}}, {{536,428},{541,470},{534,518}}, {{528,520},{548,556},{570,598}} }) do
  work(rib(r, 1.6, 1.2), {hand="detail", pile=GC, coverage=3})
end
-- visor slit catching the flash
work(rib({{486,394},{496,392}}, 2, 2), {hand="detail", pile=WARM2, coverage=3})
-- the flash
work(rib({{414,358},{360,330}}, 9, 1) + rib({{414,358},{372,374}}, 6, 1) + rib({{414,358},{392,322}}, 6, 1) + rib({{414,358},{380,350}}, 12, 2), {hand="detail", pile=WARM2, coverage=3.5})
work(ellipse(408,355,10,8), {hand="detail", pile=FLASH, coverage=4})
-- spent casings, decades of them
local bb = brush{kind="round", width=2.4, point=0.2}
for i = 1, 40 do
  local a = rand(0, 6.283)
  local r = rand(30, 230)
  local x, y = 490 + r * math.cos(a), 590 + r * 0.25 * math.sin(a)
  bb:reload(i % 3 == 0 and WARM2 or BRZ, 0.6)
  bb:stroke({{x, y}, {x + rand(-3, 3), y + rand(-1, 1)}}, {pressure={0.5, 0.4}})
end
-- the shards made solid and cold-edged
for _, s in ipairs({ {{270,300},{318,262},{332,330},{296,352}}, {{684,280},{730,318},{706,372},{672,340}},
    {{860,250},{930,300},{900,380},{848,340}}, {{880,380},{940,420},{906,456}}, {{486,300},{520,282},{514,340}} }) do
  work(poly(s), {hand="detail", pile=SIL2, coverage=4.5, load=1})
  work(rib({s[1], s[2]}, 1.6, 1) + rib({s[2], s[3]}, 1.2, 0.8), {hand="detail", pile=CY, coverage=3})
  work(rib({s[3], s[4] or s[1]}, 1.4, 1), {hand="detail", pile=MAG, coverage=3})
end

--@ chunk 5
wait(12*60)
-- the pool loses its edge into the floor; scorch streaks radiate from the heart
lose(ellipse(480,590,170,40):roughen(8,40,3), {pile=FL, reach={14, 30}, load=0.35, tool="filbert 4"})
local bb = brush("filbert", 4)
for i = 1, 14 do
  local a = rand(0, 6.283)
  local x0, y0 = 490 + 60 * math.cos(a), 590 + 15 * math.sin(a)
  local x1, y1 = 490 + rand(200, 320) * math.cos(a), 590 + rand(50, 75) * math.sin(a)
  bb:reload(SIL2, 0.4)
  bb:stroke({{x0, y0}, {x1, y1}}, {pressure={0.5, 0.05}, ramps={0.05, 0.6}})
end
-- the Testator wall: bronze ribs between the doorways, a cold lip on each
for _, x in ipairs({205, 400, 600, 795}) do
  local m = rib({{x, 20}, {x + (x - 500) * 0.04, 460}}, 22, 18)
  work(m, {hand="detail", pile=BRZ, coverage=3.5})
  work(rib({{x - 10, 20}, {x - 9 + (x - 500) * 0.04, 458}}, 1.8, 1.4), {hand="detail", pile=GM, coverage=2.5})
  work(rib({{x + 10, 20}, {x + 9 + (x - 500) * 0.04, 458}}, 2.4, 2), {hand="detail", pile=SIL2, coverage=3})
end
-- his armour read through the rims: pauldron, pack, helm crest; a crimson tabard at the waist
for _, r in ipairs({ {{462,424},{474,412},{492,414}}, {{530,412},{548,410},{562,420}}, {{488,382},{498,378},{508,382}} }) do
  work(rib(r, 2, 1.4), {hand="detail", pile=WARM2, coverage=3})
end
work(rib({{560,420},{568,446},{566,470}}, 2, 1.4), {hand="detail", pile=GC, coverage=3})
local tab = poly({{482,500},{518,500},{522,540},{512,566},{500,556},{488,566},{480,540}})
work(tab, {hand="detail", pile=pile{{"cadmium red",1},{"rose madder",0.8},{"bone black",0.3}}, coverage=3.5})
work(rib({{484,502},{482,540}}, 1.6, 1), {hand="detail", pile=WARM2, coverage=2.5})
work(rib({{500,508},{500,528}}, 2, 2) + rib({{493,514},{507,514}}, 2, 2), {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",1}}, coverage=3})

--@ chunk 6
wait(24*60)
DB = pile{{"burnt sienna",1.5},{"bone black",1.2},{"raw sienna",0.4}}
for _, x in ipairs({205, 400, 600, 795}) do
  local m = rib({{x, 20}, {x + (x - 500) * 0.04, 460}}, 23, 19)
  work(m, {hand="detail", pile=DB, coverage=4, load=1})
  work(rib({{x - 9, 120}, {x - 8 + (x - 500) * 0.04, 458}}, 1.6, 1.2), {hand="detail", pile=GM, coverage=2.5})
end
-- glow falls off toward the doors' tops, and the walls take a cold reflected sheen near them
for _, d in ipairs(DOORS) do
  local cx, by, w, h = d[1], d[2], d[3], d[4]
  local top = petal(cx, by, w * 0.8, h * 0.9) * poly({{0,0},{1000,0},{1000, by - h * 0.62},{0, by - h * 0.62}})
  work(top - petal(cx, by - h * 0.12, w * 0.5, h * 0.55), {hand="detail", pile=GE, coverage=2.5})
  work(petal(cx, by, w * 1.25, h * 1.08) - petal(cx, by, w, h), {hand="detail", pile=pile{{"ultramarine blue",1},{"bone black",1},{"burnt sienna",0.5}}, coverage=2.5})
end
-- the Testator coming through door 1: lit cold, a bronze eye-disc
work(rib({{88,330},{86,400}}, 1.6, 1.2) + rib({{126,330},{130,400}}, 1.6, 1.2), {hand="detail", pile=GC, coverage=3})
-- muzzle flash brighter, and a tracer to the left door's thing
work(ellipse(406,354,6,5), {hand="detail", pile=FLASH, coverage=4})
work(rib({{396,350},{140,316}}, 1.4, 0.6), {hand="detail", pile=WARM2, coverage=3})
work(ellipse(134,318,6,4), {hand="detail", pile=WARM2, coverage=3})

--@ chunk 7
-- soften the hard dark band inside each door
for _, d in ipairs(DOORS) do
  local cx, by, w, h = d[1], d[2], d[3], d[4]
  local y = by - h * 0.62
  blend(petal(cx, by, w * 0.8, h * 0.9) * rect(cx - w, y - 14, 2 * w, 28) - petal(cx, by - h * 0.12, w * 0.5, h * 0.55), {angle=1.57})
end
wait(24*60)
DB2 = pile{{"bone black",2},{"burnt sienna",1}}
for _, x in ipairs({205, 400, 600, 795}) do
  local m = rib({{x, 20}, {x + (x - 500) * 0.04, 460}}, 23, 19)
  work(m * poly({{0,0},{1000,0},{1000,500},{0,500}}) - rib({{x - 8, 20}, {x - 7 + (x - 500) * 0.04, 460}}, 5, 4), {hand="detail", pile=DB2, coverage=4.5, load=1})
end
-- his helm and gun barrel picked out once more, crisp against the door behind
work(rib({{470,392},{414,358}}, 4, 3), {hand="detail", pile=SIL2, coverage=4})
work(rib({{466,386},{416,354}}, 1.2, 1), {hand="detail", pile=WARM2, coverage=3})
work(ellipse(406,354,6,5), {hand="detail", pile=FLASH, coverage=4})

--@ chunk 8
-- the pool broken by his long shadow, cast away from the flash
work(poly({{470,600},{560,598},{660,612},{650,624},{540,618}}, true), {hand="detail", pile=SIL2, coverage=4})
stipple(ellipse(480,590,170,40), {pile=SIL2, width=2, coverage=0.35, cluster=0.8})
-- legs and back read as armour plates
for _, r in ipairs({ {{454,566},{462,540},{474,516}}, {{548,556},{536,534},{524,514}} }) do
  work(rib(r, 1.6, 1.2), {hand="detail", pile=r[1][1] < 500 and WARM2 or GC, coverage=3})
end
for _, s in ipairs({ {{470,450},{534,452}}, {{468,480},{536,482}}, {{524,436},{562,440}} }) do
  work(rib(s, 1.4, 1.2), {hand="detail", pile=BRZ, coverage=2.5})
end
work(rib({{470,452},{500,449}}, 1, 1) + rib({{468,482},{498,480}}, 1, 1), {hand="detail", pile=WARM, coverage=2.5})

--@ chunk 9
function rib(pts, w0, w1)
  local n = #pts
  local w = {}
  for i = 1, n do w[i] = lerp(w0, w1, (i-1)/(n-1)) end
  return ribbon(pts, w)
end
function shiftpts(pts, dx, dy) local o = {} for i, p in ipairs(pts) do o[i] = {p[1]+dx, p[2]+dy} end return o end
wait(24*60)
-- (3) ribs knocked down to dark bronze, opaque, with one dull lip
RB = pile{{"bone black",2.5},{"ultramarine blue",0.6},{"burnt sienna",0.8}}
RL = pile{{"burnt sienna",1},{"bone black",1},{"ultramarine ash",0.5}}
for _, x in ipairs({205, 400, 600, 795}) do
  local m = rib({{x, 0}, {x + (x - 500) * 0.04, 462}}, 26, 22)
  work(m, {hand="body", tool="filbert 4", pile=RB, angle=1.57, coverage=5, load=1, fill=true, clip=true})
  work(rib({{x - 9, 60}, {x - 8 + (x - 500) * 0.04, 455}}, 2.2, 1.6), {hand="detail", pile=RL, coverage=3})
  work(rib({{x - 11, 120}, {x - 10 + (x - 500) * 0.04, 455}}, 1, 0.8), {hand="detail", pile=GE, coverage=2.5})
end
-- (3) the doorway glow bands: a middle value laid across the seam, then fused
GMID = pile{{"cerulean blue",1},{"ultramarine blue",1.5},{"zinc white",0.6},{"cobalt violet",0.5}}
for _, d in ipairs(DOORS) do
  local cx, by, w, h = d[1], d[2], d[3], d[4]
  local y = by - h * 0.62
  local inside = petal(cx, by, w * 0.8, h * 0.9) - petal(cx, by - h * 0.12, w * 0.5, h * 0.55)
  work(inside * rect(cx - w, y - 16, 2 * w, 32), {hand="detail", pile=GMID, coverage=3.5})
  blend(inside * rect(cx - w, y - 30, 2 * w, 60), {angle=1.57})
end

--@ chunk 10
-- (2) the Adversary: forms that disagree with themselves, reaching out of the doorways
ADK = pile{{"bone black",2},{"ultramarine blue",1},{"cobalt violet",0.4}}
ACY = pile{{"zinc white",1},{"cerulean blue",1},{"emerald green",0.4}}
AMG = pile{{"magenta",1},{"cobalt violet",0.6},{"zinc white",0.4}}
AIN = pile{{"zinc white",2},{"cerulean blue",0.6},{"magenta",0.3}}
-- a reaching form: a tapering tongue from inside a door toward the heart, outlined twice, out of register
local function reach(pts, w0, w1, dx, dy)
  local body = rib(pts, w0, w1)
  work(body, {hand="detail", pile=ADK, coverage=4, load=1})
  local ghost = rib(shiftpts(pts, dx, dy), w0 * 0.92, w1 * 0.9)
  work(ghost:rim(1.4, 0.3) * ghost, {hand="detail", pile=AMG, coverage=3})
  work(body:rim(1.2, 0.3) * body, {hand="detail", pile=ACY, coverage=3})
  -- folds opening into more of itself: smaller copies of the tongue nested in its root
  for k = 1, 3 do
    local s = 1 - k * 0.22
    local sub = {}
    for i = 1, math.max(2, #pts - k) do sub[i] = pts[i] end
    local f = rib(sub, w0 * s, w1 * s + 1)
    work(f:rim(1, 0.3) * f, {hand="detail", pile=(k % 2 == 1) and AMG or ACY, coverage=2.5})
  end
end
reach({{300,330},{330,370},{372,430},{410,470}}, 26, 4, 6, -5)
reach({{700,330},{672,380},{630,440},{590,480}}, 26, 4, -7, -4)
reach({{895,330},{850,400},{760,470},{640,520}}, 34, 5, -8, 6)
reach({{500,300},{506,350},{530,380}}, 16, 3, 5, 4)
reach({{860,280},{905,250},{940,215}}, 18, 3, 6, -6)
reach({{285,300},{250,260},{236,230}}, 14, 2, -5, -5)
-- splinters of light inside the forms where they open
for _, p in ipairs({{318,352},{682,362},{866,380},{503,322}}) do
  work(ellipse(p[1], p[2], 3, 4), {hand="detail", pile=AIN, coverage=3.5})
end

--@ chunk 11
wait(12*60)
-- (1) the Commando as armour: each plate dark gunmetal, a hot edge toward the flash (left/up), a cold edge from the doors (right), a black thickness below
GUN = pile{{"bone black",2},{"ultramarine ash",0.8},{"burnt sienna",0.5}}
GUNL = pile{{"bone black",1},{"burnt sienna",0.8},{"Mars orange",0.4},{"ultramarine ash",0.4}}
HOT = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.6}}
CLD = pile{{"zinc white",1},{"cerulean blue",1},{"ultramarine blue",0.4}}
BLK = pile{{"bone black",2},{"ultramarine blue",0.4}}
local function ap(pts, warmside)
  local P = poly(pts)
  work(poly(shiftpts(pts, 0.8, 2.4)) - P, {hand="detail", pile=BLK, coverage=3.5})
  work(P, {hand="detail", pile=GUN, coverage=4, load=1})
  work(P - poly(shiftpts(pts, 7, 2)), {hand="detail", pile=GUNL, coverage=3.5})
  work(P - poly(shiftpts(pts, 1.6, 1.2)), {hand="detail", pile=HOT, coverage=3})
  work(P - poly(shiftpts(pts, -1.6, 0.4)), {hand="detail", pile=CLD, coverage=2.5})
end
-- legs: rear leg braced back taking the recoil, front leg bent
ap({{554,560},{572,598},{588,598},{588,608},{556,608},{540,566}})
ap({{528,512},{552,520},{560,562},{540,568}})
ap({{456,560},{442,596},{426,598},{426,610},{456,610},{470,566}})
ap({{470,512},{486,516},{474,566},{454,560}})
-- belt and faulds
ap({{466,500},{536,500},{538,522},{464,522}})
-- cuirass leaning back from the hips, back plates and the pack
ap({{470,446},{532,448},{536,500},{466,500}})
ap({{466,418},{534,420},{534,450},{468,450}})
ap({{526,408},{562,414},{568,470},{544,482},{528,452}})
-- pauldrons: the left raised with the rifle arm
ap({{446,402},{470,396},{486,412},{478,430},{454,428}})
ap({{520,404},{546,402},{556,420},{534,428},{518,420}})
-- arms on the rifle
ap({{452,410},{440,388},{450,382},{466,404}})
ap({{506,404},{474,388},{480,380},{514,398}})
-- helm with a visor slit lit by the flash
ap({{484,382},{500,378},{514,386},{514,404},{500,412},{486,406}})
work(rib({{486,392},{500,390}}, 2, 2), {hand="detail", pile=HOT, coverage=3.5})
-- rifle restated: long, heavy, a cold line along its back
work(rib({{548,446},{486,394},{414,358}}, 9, 7), {hand="detail", pile=GUN, coverage=4, load=1})
work(rib({{544,440},{486,389},{416,354}}, 1.4, 1.2), {hand="detail", pile=HOT, coverage=3})
work(rib({{548,452},{490,400},{420,363}}, 1, 0.8), {hand="detail", pile=CLD, coverage=2.5})
-- tabard over the faulds
local tab = poly({{484,506},{516,506},{520,542},{511,566},{500,557},{489,566},{481,542}})
work(tab, {hand="detail", pile=pile{{"cadmium red",1},{"rose madder",0.8},{"bone black",0.3}}, coverage=4})
work(rib({{485,508},{483,542}}, 1.6, 1), {hand="detail", pile=HOT, coverage=2.5})
work(rib({{500,514},{500,532}}, 2, 2) + rib({{494,519},{506,519}}, 2, 2), {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",1}}, coverage=3})
-- flash re-lit on top
work(ellipse(406,354,7,6), {hand="detail", pile=FLASH, coverage=4})

--@ chunk 12
-- the figure's far side turned cold and dark, so the flash side carries the warmth
local far = poly({{500,370},{580,370},{600,620},{500,620}})
local fig = poly({{528,512},{552,520},{560,562},{540,568}}) + poly({{554,560},{572,598},{588,598},{588,608},{556,608},{540,566}})
  + poly({{526,408},{562,414},{568,470},{544,482},{528,452}}) + poly({{470,446},{532,448},{536,500},{466,500}}) * far
  + poly({{466,418},{534,420},{534,450},{468,450}}) * far
work(fig:shrink(2.2), {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.8}}, coverage=4, load=1})
-- each Adversary form gets a second body, out of register, and a fold that opens into more of it
local function knot(cx, cy, r, dx, dy, seed)
  local a = ellipse(cx, cy, r, r * 1.3):roughen(r * 0.25, r * 0.8, seed)
  local b = ellipse(cx + dx, cy + dy, r * 1.05, r * 1.2):roughen(r * 0.25, r * 0.8, seed + 7)
  work(a + b, {hand="detail", pile=ADK, coverage=4, load=1})
  work(a:rim(1.3, 0.3) * a, {hand="detail", pile=ACY, coverage=3})
  work(b:rim(1.3, 0.3) * b, {hand="detail", pile=AMG, coverage=3})
  for k = 1, 3 do
    local s = 1 - k * 0.24
    local f = ellipse(cx + dx * k * 0.3, cy - r * 0.15 * k, r * s, r * 1.3 * s):roughen(r * 0.2 * s, r * 0.6, seed + k)
    work(f:rim(0.9, 0.3) * f, {hand="detail", pile=(k % 2 == 1) and AMG or ACY, coverage=2.5})
  end
  work(ellipse(cx + dx * 0.9, cy - r * 0.6, 2.4, 3), {hand="detail", pile=AIN, coverage=3.5})
end
knot(300, 345, 20, 7, -6, 3)
knot(700, 352, 20, -8, -5, 11)
knot(890, 360, 28, -9, 7, 19)
knot(503, 318, 12, 5, 4, 27)
work(ellipse(406,354,7,6), {hand="detail", pile=FLASH, coverage=4})
