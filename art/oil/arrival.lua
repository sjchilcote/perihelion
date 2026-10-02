-- easel session "arrival": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=8086,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"bone brown",1},{"lead white",0.5}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
SUN = {578, 846}
WIN = rect(232, 380, 536, 720) + ellipse(500, 380, 268, 270)
WALL = everywhere() - WIN
HZ = {{220,906},{330,880},{450,862},{560,852},{680,850},{790,856}}
HULL = below(HZ) * WIN
SKY = WIN - HULL
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + ((y - SUN[2]) * 1.15)^2) end
local function rad(x, y) return math.atan(y - SUN[2], x - SUN[1]) end
skyTop = pile{{"bone brown",1.5},{"rose madder",0.8},{"ultramarine blue",0.6},{"burnt sienna",0.5}}
skyRed = pile{{"cadmium red",1},{"burnt sienna",1},{"rose madder",0.5}}
skyOr  = pile{{"Mars orange",1.5},{"cadmium red",0.4},{"Indian yellow",0.6}}
skyGold = pile{{"cadmium yellow",1},{"Mars yellow",1},{"lead white",1}}
wallP = pile{{"bone black",2},{"burnt sienna",1.2},{"raw sienna",0.3}}
work(WALL, {hand="broad", pile=wallP, coverage=2.8, fill=true, angle=1.57, angle_jitter=0.3})
work(SKY, {hand="broad", pile=skyTop, coverage=2.4, fill=true, angle=rad, clip=SKY})
local r1 = SKY * mask(function(x, y) return rd(x, y) < 470 and 1 or 0 end)
work(r1, {hand="broad", pile=skyRed, coverage=2.2, fill=true, angle=rad, clip=SKY})
local r2 = SKY * mask(function(x, y) return rd(x, y) < 330 and 1 or 0 end)
work(r2, {hand="broad", pile=skyOr, coverage=2.2, fill=true, angle=rad, clip=SKY})
local r3 = SKY * mask(function(x, y) return rd(x, y) < 200 and 1 or 0 end)
work(r3, {hand="body", pile=skyGold, coverage=2.4, fill=true, angle=rad, clip=SKY})

--@ chunk 3
-- melt the sky's band seams (radially, once), then the hull: a dark convex limb, warmer toward the Sun
local function rad(x, y) return math.atan(y - SUN[2], x - SUN[1]) end
blend(SKY:shrink(3), {angle=rad})
hullD = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
hullW = pile{{"bone black",1.5},{"burnt sienna",1.2},{"Mars orange",0.3}}
local H = HULL:grow(2) * WIN
work(H, {hand="body", pile=hullD, coverage=3, fill=true, angle=0.05, clip=H})
local near = H * ellipse(SUN[1], 870, 220, 60)
work(near, {hand="body", pile=hullW, coverage=2.2, fill=true, angle=0.05, clip=H})
-- wall overrun at the sill: repaint the window bottom edge region of wall cleanly
local sill = WALL * rect(200, 1080, 600, 60)
work(sill, {hand="body", pile=wallP, coverage=3, fill=true, angle=0, clip=true})

--@ chunk 4
print(wait(3*24*60), drying(500, 600), drying(578, 800))
-- the corona: long strokes running out from the Sun, hottest and densest near it, thinning outward; the disc, white-hot, cut by the limb
local cW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.4}}
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.8}}
local thin = brush{kind="round", width=2.6, point=0.5}
local mid = brush("filbert", 6)
local wide = brush("filbert", 12)
local n = 0
for i = 1, 150 do
  local a = rand(-math.pi, 0) + rand(-0.12, 0.12)
  local r0 = rand(50, 90)
  local len = 60 + 380 * rand(0, 1)^1.6
  local br = (len > 250) and wide or ((math.random() < 0.5) and mid or thin)
  local p = (len < 140) and cW or ((len < 260) and cG or cO)
  local x0, y0 = SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0
  local x1, y1 = SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)
  br:reload(p, 0.5)
  br:stroke({{x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2}, {x1, y1}}, {pressure={0.55, 0.02}, ramps={0.1, 0.8}, orient="along", clip=SKY})
  n = n + 1
end
local disc = ellipse(SUN[1], SUN[2], 74, 74) * SKY
work(disc, {hand="body", pile=cW, coverage=2.8, fill=true, angle=0, clip=true})
local core = ellipse(SUN[1], SUN[2] + 8, 52, 46) * SKY
work(core, {hand="body", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=2.6, fill=true, angle=0, clip=true})
print(n)

--@ chunk 5
-- soften the corona into a huge gold glow: a transparent yellow glaze, heaviest near the Sun
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + ((y - SUN[2]) * 1.1)^2) end
local function rad(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
local gY = pile{{"Indian yellow",1},{"cadmium yellow",0.8},{"lead white",0.25}, medium=0.8}
local G = SKY * ellipse(SUN[1], SUN[2], 380, 340) - ellipse(SUN[1], SUN[2], 70, 70)
work(G, {hand="glaze", pile=gY, coverage=1.6, fill=true, angle=rad, clip=SKY, pressure={0.15, 0.3},
  load_at=function(x, y) return 0.5 * (1 - smoothstep(80, 380, rd(x, y))) end})
-- the limb catching the light: a thin hot rim along the hull's crest, brightest under the Sun
local rimP = pile{{"lead white",3},{"cadmium yellow",0.5},{"Indian yellow",0.2}}
local r = brush{kind="round", width=2.4, point=0.6}
local pts = {}
for _, p in ipairs(HZ) do pts[#pts+1] = {p[1], p[2] + 1.5} end
r:load(rimP, 0.6)
r:stroke(pts, {pressure={0.15, 0.15}, swell={0.3, 0.6, 1.6, 1.6, 0.8, 0.4}, ramps={0.2, 0.2}})
-- far off, the sail: a dark mirror sliver catching the first light on its lower edge
local sail = poly({{300,452},{372,430},{438,424},{430,436},{366,446},{304,462}}, true)
work(sail, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.6},{"rose madder",0.3}}, coverage=2.6, fill=true, angle=-0.2, clip=true})
local e = brush{kind="round", width=1.3, point=0.8}
e:load(rimP, 0.6)
e:stroke({{306,461},{366,445},{429,435}}, {pressure={0.2, 0.55}, ramps={0.2, 0.1}})
local t = brush{kind="round", width=0.8, point=0.9}
t:load(pile{{"bone black",2},{"rose madder",0.4}}, 0.5)
t:stroke({{370,437},{392,500}}, {pressure={0.25, 0.1}})

--@ chunk 6
print(wait(2*24*60))
-- the bronze surround: a deep reveal around the opening, plates on it, the inner edge catching the light
FRAME = WIN:grow(46) - WIN
frameD = pile{{"bone black",1.6},{"burnt sienna",1.2},{"raw sienna",0.5}}
frameM = pile{{"burnt sienna",1.4},{"raw sienna",1},{"bone black",0.5}}
work(FRAME, {hand="body", pile=frameD, coverage=3, fill=true, angle=function(x, y) return math.atan(y - 380, x - 500) + math.pi/2 end, clip=FRAME})
-- plates around the reveal, laid by golden angle along its length
local GA = math.pi * (3 - math.sqrt(5))
local pb = brush("filbert", 11)
local sb = brush{kind="round", width=2.2, point=0.5}
local L = 2 * 720 + math.pi * 268
local n = 0
for k = 1, 340 do
  local s = (k * 0.618034) % 1 * L
  local x, y, nx, ny
  if s < 720 then x, y, nx, ny = 232, 1100 - s, -1, 0
  elseif s < 720 + math.pi * 268 then
    local a = math.pi + (s - 720) / 268; x, y, nx, ny = 500 + math.cos(a) * 268, 380 + math.sin(a) * 270, math.cos(a), math.sin(a)
  else x, y, nx, ny = 768, 380 + (s - 720 - math.pi * 268), 1, 0 end
  local d = 6 + ((k * GA) % 1) * 34
  local px, py = x + nx * d, y + ny * d
  local tx, ty = -ny, nx
  local toward = clamp(1 - math.sqrt((px - SUN[1])^2 + (py - SUN[2])^2) / 700, 0, 1)
  if n % 3 == 0 then pb:reload((toward > 0.35) and frameM or frameD, 0.5); sb:reload(pile{{"bone black",2},{"ultramarine blue",0.3}}, 0.5) end
  n = n + 1
  pb:stroke({{px - tx * 6, py - ty * 6}, {px + nx * 1.5, py + ny * 1.5}, {px + tx * 6, py + ty * 6}}, {pressure={0.55, 0.4}, ramps={0.15, 0.4}, clip=FRAME})
  sb:stroke({{px - tx * 6 + nx * 5, py - ty * 6 + ny * 5}, {px + nx * 6.5, py + ny * 6.5}, {px + tx * 6 + nx * 5, py + ty * 6 + ny * 5}}, {pressure={0.4, 0.1}, ramps={0.2, 0.4}, clip=FRAME})
end
print(n)

--@ chunk 7
-- golden-angle tracery in the arch head: crossing spiral bars round a central boss, and a transom; dark against the sky, lit edges toward the Sun
local HEAD = WIN * rect(200, 90, 600, 290)
local C = {500, 330}
local bar = pile{{"bone black",2},{"burnt sienna",1}}
local lit = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.8},{"cadmium yellow",0.2}}
local b = brush{kind="round", width=4.2, point=0.3}
local e = brush{kind="round", width=1.4, point=0.8}
local function spiral(a0, dir)
  local pts = {}
  for k = 0, 40 do
    local th = k * 0.09
    local r = 14 * math.exp(0.306 * th * 2.2)
    local a = a0 + dir * th
    local x, y = C[1] + math.cos(a) * r, C[2] + math.sin(a) * r * 1.02
    pts[#pts+1] = {x, y}
    if r > 330 then break end
  end
  return pts
end
local arms = {}
for i = 0, 12 do arms[#arms+1] = spiral(i * 2 * math.pi / 13, 1) end
for i = 0, 7 do arms[#arms+1] = spiral(i * 2 * math.pi / 8 + 0.2, -1) end
for _, pts in ipairs(arms) do
  b:load(bar, 0.7); b:stroke(pts, {pressure={0.8, 0.8}, ramps={0.05, 0.05}, clip=HEAD})
end
for _, pts in ipairs(arms) do
  local q = {}
  for _, p in ipairs(pts) do q[#q+1] = {p[1] + 1.6, p[2] + 1.6} end
  e:load(lit, 0.5); e:stroke(q, {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=HEAD})
end
-- transom and central boss
local t = brush("flat", 9)
t:load(bar, 0.8); t:stroke({{232, 376}, {768, 376}}, {pressure={0.9, 0.9}, ramps={0.01, 0.01}, orient="across", clip=WIN})
e:load(lit, 0.6); e:stroke({{232, 381}, {768, 381}}, {pressure={0.55, 0.55}, ramps={0.01, 0.01}, clip=WIN})
local bo = brush{kind="round", width=16, point=0.1}
bo:load(bar, 0.85); bo:touch(C[1], C[2], {pressure=0.9})
e:load(lit, 0.6); e:stroke({{C[1] - 4, C[2] + 6}, {C[1] + 5, C[2] + 5}}, {pressure={0.5, 0.3}})

--@ chunk 8
print(wait(2*24*60))
-- the tracery heavier and reaching the whole arch head: same spirals carried out to the frame, dark bronze bars
local HEAD = WIN * rect(200, 90, 600, 282)
local C = {500, 330}
local bar = pile{{"bone black",2.5},{"burnt sienna",1}}
local b = brush("filbert", 6)
local function spiral(a0, dir)
  local pts = {}
  for k = 0, 80 do
    local th = k * 0.06
    local r = 14 * math.exp(0.67 * th)
    local a = a0 + dir * th
    pts[#pts+1] = {C[1] + math.cos(a) * r, C[2] + math.sin(a) * r}
    if r > 340 then break end
  end
  return pts
end
for i = 0, 12 do b:load(bar, 0.85); b:stroke(spiral(i * 2 * math.pi / 13, 1), {pressure={0.6, 0.9}, ramps={0.05, 0.05}, orient="across", clip=HEAD}) end
for i = 0, 7 do b:load(bar, 0.85); b:stroke(spiral(i * 2 * math.pi / 8 + 0.2, -1), {pressure={0.6, 0.9}, ramps={0.05, 0.05}, orient="across", clip=HEAD}) end
local bo = brush{kind="round", width=22, point=0.1}
bo:load(bar, 0.9); bo:touch(C[1], C[2], {pressure=0.95})

--@ chunk 9
print(wait(2*24*60))
-- the sill: a ledge catching the light
local sillTop = rect(220, 1098, 560, 10)
work(sillTop, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.7},{"Mars orange",0.2}}, coverage=2.6, fill=true, angle=0, clip=true})
local sillFace = rect(214, 1108, 572, 26)
work(sillFace, {hand="detail", pile=frameD, coverage=2.6, fill=true, angle=0, clip=true})
-- the Commando: back to us, standing at the sill, head against the gold just left of the Sun
FIG = ellipse(470, 818, 23, 27)
  + poly({{450,840},{490,840},{526,864},{540,900},{538,1000},{528,1060},{512,1088},{428,1088},{412,1060},{402,1000},{400,900},{414,864}}, true)
  + ellipse(470, 935, 50, 62)
  + ribbon({{410,872},{392,985},{398,1078}}, {22, 18, 15})
  + ribbon({{530,872},{552,982},{560,1072}}, {22, 18, 15})
  + ribbon({{452,1080},{447,1190},{442,1302}}, {34, 28, 24})
  + ribbon({{490,1080},{496,1190},{502,1302}}, {34, 28, 24})
FIG = FIG:roughen(1.5, 10, 9)
figP = pile{{"bone black",2.5},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
work(FIG, {hand="body", tool="filbert 5", pile=figP, coverage=3.6, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 10
print(wait(2*24*60))
-- heavier legs and boots, lost into the dark floor; rim light on head and shoulders from the Sun; the crimson rag lifting by nothing
local legs = ribbon({{450,1080},{446,1190},{440,1300}}, {46, 40, 36}) + ribbon({{492,1080},{498,1190},{505,1300}}, {46, 40, 36})
work(legs, {hand="body", tool="filbert 5", pile=figP, coverage=3.4, fill=true, angle=math.pi/2, clip=true, load=0.95})
local r = brush{kind="round", width=1.6, point=0.8}
local rimP = pile{{"lead white",3},{"cadmium yellow",0.4},{"Indian yellow",0.2}}
r:load(rimP, 0.55); r:stroke({{462,795},{474,791},{488,800},{493,812}}, {pressure={0.3, 0.55}, ramps={0.2, 0.3}})
r:load(rimP, 0.55); r:stroke({{494,842},{514,850},{528,862},{536,880}}, {pressure={0.5, 0.2}, ramps={0.1, 0.5}})
r:load(rimP, 0.5);  r:stroke({{445,842},{430,852},{418,864}}, {pressure={0.3, 0.1}, ramps={0.1, 0.6}})
-- rag: tied at the left shoulder, lifting up and out in a soft curl
local rag = pile{{"cadmium red",1.5},{"vermilion",0.5},{"rose madder",0.4}}
local ragL = pile{{"vermilion",1},{"cadmium red",0.5},{"lead white",0.3},{"Mars orange",0.3}}
local f = brush("filbert", 7)
f:load(rag, 0.8)
f:stroke({{426,858},{404,834},{382,822},{360,824},{344,812}}, {pressure={0.8, 0.25}, swell={1, 1.2, 0.9, 0.6}, ramps={0.1, 0.5}, orient="across"})
f:load(rag, 0.7)
f:stroke({{422,866},{396,850},{374,846},{352,850}}, {pressure={0.6, 0.15}, ramps={0.1, 0.6}, orient="across"})
local g = brush{kind="round", width=2.2, point=0.6}
g:load(ragL, 0.6)
g:stroke({{410,836},{388,824},{366,823}}, {pressure={0.45, 0.15}, ramps={0.1, 0.5}})

--@ chunk 11
print(wait(3*24*60))
-- rim light restated hot on dry paint; rag fuller with a lit fold
local r = brush{kind="round", width=2.2, point=0.7}
local rimP = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.4}}
r:load(rimP, 0.65); r:stroke({{458,797},{472,791},{486,797},{493,808},{494,822}}, {pressure={0.35, 0.7}, ramps={0.2, 0.2}})
r:load(rimP, 0.6);  r:stroke({{495,843},{512,849},{526,860},{534,876},{538,900}}, {pressure={0.65, 0.1}, ramps={0.05, 0.6}})
r:load(rimP, 0.5);  r:stroke({{444,842},{430,850},{419,862}}, {pressure={0.4, 0.1}, ramps={0.1, 0.6}})
local f = brush("filbert", 9)
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5},{"rose madder",0.4}}, 0.8)
f:stroke({{424,862},{402,842},{380,834},{358,836},{338,826}}, {pressure={0.7, 0.2}, ramps={0.1, 0.5}, orient="across"})
local g = brush{kind="round", width=2.4, point=0.6}
g:load(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.5}}, 0.6)
g:stroke({{414,842},{392,830},{368,828},{350,822}}, {pressure={0.5, 0.1}, ramps={0.1, 0.5}})
-- the hull: a few plate courses curving with the limb, lit faintly on their sunward edges
local hl = pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone black",0.6}}
local e = brush{kind="round", width=1.6, point=0.6}
for k = 1, 6 do
  local dy = k * k * 6
  local pts = {}
  for _, p in ipairs(HZ) do pts[#pts+1] = {p[1], p[2] + dy + 4} end
  e:load(hl, 0.5)
  e:stroke(pts, {pressure={0.1, 0.1}, swell={0.4, 0.8, 1.4, 1.4, 0.8, 0.4}, ramps={0.2, 0.2}, clip=HULL - FIG:grow(2)})
end
-- warm light thrown on the left reveal (the Sun stands to the right)
local rev = (WIN:grow(46) - WIN) * rect(186, 420, 60, 680)
work(rev, {hand="scumble", pile=pile{{"Mars orange",1},{"raw sienna",1},{"lead white",0.6}}, coverage=0.9, angle=math.pi/2, clip=rev})

--@ chunk 12
print(wait(3*24*60))
-- the scumble went pale and opaque: repaint the left reveal in bronze, then only a narrow warm edge where it meets the light
local rev = (WIN:grow(46) - WIN) * rect(180, 410, 70, 700)
work(rev, {hand="body", tool="filbert 6", pile=frameD, coverage=3.6, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 13
print(wait(3*24*60))
local rev = (WIN:grow(46) - WIN) * rect(180, 410, 70, 700)
local pb = brush("filbert", 11)
local sb = brush{kind="round", width=2.2, point=0.5}
for k = 1, 40 do
  local y = 420 + ((k * 0.618034) % 1) * 670
  local x = 232 - 6 - ((k * 0.381966) % 1) * 34
  if k % 3 == 1 then pb:reload(frameM, 0.5); sb:reload(pile{{"bone black",2},{"ultramarine blue",0.3}}, 0.5) end
  pb:stroke({{x, y - 6}, {x - 1.5, y}, {x, y + 6}}, {pressure={0.55, 0.4}, ramps={0.15, 0.4}, clip=rev})
  sb:stroke({{x - 5, y - 6}, {x - 6.5, y}, {x - 5, y + 6}}, {pressure={0.4, 0.1}, ramps={0.2, 0.4}, clip=rev})
end
local e = brush{kind="round", width=2.4, point=0.6}
e:load(pile{{"lead white",2},{"Mars orange",0.5},{"cadmium yellow",0.4}}, 0.6)
e:stroke({{229, 560}, {229, 800}, {229, 1095}}, {pressure={0.1, 0.65}, ramps={0.3, 0.1}})

--@ chunk 14
-- quiet the wall: a lean dark coat so it sinks back (the flecks of ground showing through went noisy)
local w = WALL - WIN:grow(48) - FIG:grow(3) - rect(208, 1094, 584, 44)
work(w, {hand="broad", pile=pile{{"bone black",2},{"burnt sienna",1.3},{"raw sienna",0.25}}, coverage=3, fill=true, angle=1.57, angle_jitter=0.15, clip=w})

--@ chunk 15
print(wait(3*24*60))
-- last lights on dry paint: hot Sun core, long rays reaching into the upper sky past the transom, the sail's lit edge, a glint on the rag
local thin = brush{kind="round", width=2.4, point=0.5}
local mid = brush("filbert", 5)
local cW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.35}}
local cG = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local clipS = SKY - FIG:grow(2)
for i = 1, 60 do
  local a = rand(-math.pi + 0.15, -0.15)
  local r0 = rand(70, 110)
  local len = 150 + 420 * rand(0, 1)^1.3
  local br = (math.random() < 0.4) and mid or thin
  br:reload((len < 300) and cW or cG, 0.5)
  local x0, y0 = SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0
  local x1, y1 = SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)
  br:stroke({{x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2}, {x1, y1}}, {pressure={0.5, 0.02}, ramps={0.1, 0.8}, orient="along", clip=clipS})
end
local core = ellipse(SUN[1], SUN[2] + 6, 46, 40) * SKY - FIG:grow(2)
work(core, {hand="body", pile=pile{{"zinc white",4},{"lemon chrome",0.12}}, coverage=2.6, fill=true, angle=0, clip=true})
local e = brush{kind="round", width=1.6, point=0.8}
e:load(cW, 0.6)
e:stroke({{306,461},{366,446},{429,436}}, {pressure={0.3, 0.7}, ramps={0.2, 0.1}})
e:load(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.8}}, 0.55)
e:stroke({{404,836},{384,826},{362,826}}, {pressure={0.4, 0.1}, ramps={0.1, 0.5}})

--@ chunk 16
print(wait(2*24*60))
-- the wall darkens away from the window: a deeper lean coat at the margins, graded
local w = WALL - WIN:grow(52) - FIG:grow(3) - rect(208, 1094, 584, 44)
local function d(x, y) return math.sqrt(((x - 500) / 1.0)^2 + ((y - 700) / 1.3)^2) end
work(w, {hand="broad", pile=pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.3}}, coverage=2.6, fill=true, angle=1.57, angle_jitter=0.15, clip=w,
  load_at=function(x, y) return 0.15 + 0.8 * smoothstep(330, 650, d(x, y)) end})

--@ chunk 17
print(wait(4*24*60), drying(470, 950), drying(450, 1200))
-- PASS · the war-body. First the new silhouette's shapes; then paint out what of the old overcoat lies outside it; floor plane.
NEW = {}
NEW.helm = poly({{446,790},{460,785},{466,778},{476,778},{481,785},{496,790},{499,814},{494,836},{488,848},{456,848},{448,836},{443,814}})
NEW.paulL = poly({{432,842},{410,840},{390,848},{378,864},{380,880},{398,878},{420,872},{440,866}}, true)
NEW.paulR = poly({{508,842},{530,840},{550,848},{562,864},{560,880},{542,878},{520,872},{500,866}}, true)
NEW.torso = poly({{432,846},{508,846},{514,880},{506,930},{496,978},{444,978},{434,930},{426,880}})
NEW.fauld = poly({{444,976},{496,976},{506,1010},{514,1052},{426,1052},{434,1010}})
NEW.armL = ribbon({{402,872},{394,930},{396,990},{402,1030}}, {26, 22, 20, 18})
NEW.armR = ribbon({{538,872},{546,930},{544,990},{538,1030}}, {26, 22, 20, 18})
NEW.gauL = poly({{390,1026},{414,1026},{416,1050},{406,1064},{392,1058},{388,1042}}, true)
NEW.gauR = poly({{526,1026},{550,1026},{552,1042},{548,1058},{534,1064},{524,1050}}, true)
NEW.legL = ribbon({{450,1046},{446,1150},{442,1250},{441,1292}}, {38, 34, 32, 30})
NEW.legR = ribbon({{490,1046},{495,1150},{499,1250},{500,1292}}, {38, 34, 32, 30})
NEW.footL = poly({{420,1282},{462,1282},{466,1300},{458,1312},{414,1312},{412,1298}}, true)
NEW.footR = poly({{480,1282},{522,1282},{528,1298},{526,1312},{482,1312},{476,1300}}, true)
local N = NEW.helm
for _, k in ipairs({"paulL","paulR","torso","fauld","armL","armR","gauL","gauR","legL","legR","footL","footR"}) do N = N + NEW[k] end
NEWFIG = N
-- floor: a dark plane meeting the wall at y=1236
FLOOR = rect(0, 1236, 1000, 100)
local floorP = pile{{"bone black",2.5},{"burnt sienna",0.7},{"ultramarine blue",0.4}}
work(FLOOR - NEWFIG:grow(1), {hand="body", tool="filbert 8", pile=floorP, coverage=3.2, fill=true, angle=0, clip=true, load=0.9})
-- paint out the old coat outside the new body, each region in its own ground
local out = (FIG:grow(2) - NEWFIG) 
local hullR = out * rect(0, 860, 1000, 238)
local skyR = out * rect(0, 0, 1000, 860)
local sillR = out * rect(0, 1098, 1000, 36)
local wallR = out * rect(0, 1134, 1000, 102)
work(hullR, {hand="detail", pile=hullD, coverage=3, fill=true, angle=0.05, clip=true})
work(skyR, {hand="detail", pile=pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.8}}, coverage=3, fill=true, angle=0, clip=true})
work(sillR * rect(0, 1098, 1000, 10), {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.7},{"Mars orange",0.2}}, coverage=2.6, fill=true, angle=0, clip=true})
work(sillR * rect(0, 1108, 1000, 26), {hand="detail", pile=frameD, coverage=2.6, fill=true, angle=0, clip=true})
work(wallR, {hand="detail", pile=pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.3}}, coverage=3, fill=true, angle=1.57, clip=true})
print(out:area())

--@ chunk 18
-- the silhouette, crisp, opaque near-black
local armour = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.4}}
work(NEWFIG, {hand="body", tool="filbert 4", pile=armour, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 19
print(wait(3*24*60))
-- part the legs: a narrow wedge of the room between them, from the fauld hem down to the floor
local gap = poly({{468,1056},{472,1056},{482,1236},{486,1300},{456,1300},{460,1236}})
local function inR(y0, h) return gap * rect(0, y0, 1000, h) end
work(inR(1050, 48), {hand="detail", pile=hullD, coverage=3, fill=true, angle=0, clip=true})
work(inR(1098, 10), {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.7},{"Mars orange",0.2}}, coverage=2.8, fill=true, angle=0, clip=true})
work(inR(1108, 26), {hand="detail", pile=frameD, coverage=2.8, fill=true, angle=0, clip=true})
work(inR(1134, 102), {hand="detail", pile=pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.3}}, coverage=3, fill=true, angle=1.57, clip=true})
work(inR(1236, 64), {hand="detail", pile=pile{{"bone black",2.5},{"burnt sienna",0.7},{"ultramarine blue",0.4}}, coverage=3, fill=true, angle=0, clip=true})
-- knee cops and a fauld notch, in the same near-black, so the legs articulate
local armour = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.4}}
local k = brush("filbert", 10)
for _, p in ipairs({{447,1150},{494,1150}}) do
  k:load(armour, 0.9); k:stroke({{p[1] - 13, p[2] - 4}, {p[1], p[2] - 9}, {p[1] + 13, p[2] - 4}}, {pressure={0.9, 0.9}, orient="across"})
end

--@ chunk 20
print(wait(4*24*60), drying(470, 950))
-- thin warm rim on helm, pauldrons and the sunward arm edges; faint plate seams; the rag from the left pauldron; shadow toward us
local rimP = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.4}}
local rimW = pile{{"lead white",2},{"Mars orange",0.5},{"cadmium yellow",0.4}}
local r = brush{kind="round", width=1.8, point=0.8}
local function rim(p, pts, a, b) r:load(p, 0.6); r:stroke(pts, {pressure={a, b}, ramps={0.15, 0.4}}) end
rim(rimP, {{448,791},{460,786},{466,779},{476,779},{481,786},{494,791}}, 0.55, 0.6)   -- helm top and crest
rim(rimP, {{495,792},{498,812},{494,834}}, 0.6, 0.15)                                  -- helm, sun side
rim(rimP, {{506,843},{530,841},{550,849},{561,864}}, 0.55, 0.2)                        -- right pauldron
rim(rimW, {{432,843},{410,841},{392,848}}, 0.4, 0.1)                                   -- left pauldron
rim(rimW, {{550,880},{557,930},{556,990},{550,1028}}, 0.35, 0.05)                       -- right arm edge
rim(rimW, {{551,1030},{553,1046}}, 0.35, 0.1)                                           -- gauntlet
rim(rimW, {{509,880},{503,930},{496,976}}, 0.2, 0.05)                                   -- flank
-- faint seams in reflected light: helm brow, fauld lames, knee
local s = brush{kind="round", width=1.1, point=0.8}
local seam = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.4}}
for _, pts in ipairs({ {{450,806},{494,806}}, {{440,996},{500,996}}, {{436,1016},{504,1016}}, {{432,1036},{510,1036}}, {{430,1148},{462,1148}}, {{478,1148},{510,1148}} }) do
  s:load(seam, 0.5); s:stroke(pts, {pressure={0.3, 0.3}, ramps={0.1, 0.1}})
end
-- the rag, lifting from the left pauldron
local f = brush("filbert", 8)
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5},{"rose madder",0.4}}, 0.8)
f:stroke({{404,846},{386,830},{366,824},{348,826},{332,816}}, {pressure={0.75, 0.2}, ramps={0.1, 0.5}, orient="across"})
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5},{"rose madder",0.4}}, 0.7)
f:stroke({{400,852},{378,842},{358,842},{340,846}}, {pressure={0.55, 0.12}, ramps={0.1, 0.6}, orient="across"})
local g = brush{kind="round", width=2.2, point=0.6}
g:load(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.8}}, 0.55)
g:stroke({{394,834},{374,826},{354,826}}, {pressure={0.45, 0.1}, ramps={0.1, 0.5}})
-- shadow on the floor, falling toward us from the feet
local sh = brush("filbert", 14)
sh:load(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.8)
sh:stroke({{470, 1310}, {474, 1322}, {478, 1335}}, {pressure={0.9, 0.9}, ramps={0.05, 0.05}, orient="across"})
-- a faint warm sheen on the floor either side, where the window's light reaches
local sheen = (FLOOR * rect(250, 1236, 500, 30)) - NEWFIG:grow(6)
work(sheen, {hand="glaze", pile=pile{{"Mars orange",1},{"raw sienna",1},{"lead white",0.3}, medium=0.75}, coverage=1.2, fill=true, angle=0, clip=true, load=0.35})

--@ chunk 21
print(wait(4*24*60))
-- the floor sheen glazed acid and rectangular: repaint that strip with the floor's own dark, then a soft low warm touch only at the wall's foot
local strip = (rect(240, 1230, 520, 42)) - NEWFIG:grow(1)
work(strip, {hand="body", tool="filbert 6", pile=pile{{"bone black",2.5},{"burnt sienna",0.7},{"ultramarine blue",0.4}}, coverage=3.6, fill=true, angle=0, clip=true, load=0.95})

--@ chunk 22
print(wait(3*24*60))
local e = brush("filbert", 3)
local warm = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.6}}
for _, seg in ipairs({{{300,1238},{426,1238}}, {{516,1238},{700,1238}}}) do
  e:load(warm, 0.5); e:stroke(seg, {pressure={0.15, 0.45}, swell={0.6, 1, 0.6}, ramps={0.3, 0.3}})
end
local sh = brush("filbert", 12)
sh:load(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.85)
sh:stroke({{460, 1312}, {458, 1324}, {456, 1335}}, {pressure={0.9, 0.9}, orient="across"})
sh:load(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.85)
sh:stroke({{505, 1312}, {510, 1324}, {514, 1335}}, {pressure={0.9, 0.9}, orient="across"})
