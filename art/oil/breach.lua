-- easel session "breach": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.5, linen={16,18}, seed=9091, ground={{pile={{"ultramarine blue",1},{"viridian",0.4},{"bone black",0.8},{"lead white",0.6},{"magenta",0.2}}, um=140, apply="knife", texture=0.4}}}
-- geometry
FN = noise{seed=3, period=300, octaves=3}
function drift(x, y) return 0.6 * math.sin(x / 140) + 0.8 * FN(x, y) end
-- the breach line: the torn right edge of the station's last wall
BREACH = {{230,0},{246,80},{232,150},{258,230},{240,320},{262,400},{248,470},{270,560},{252,667}}
WALL = poly({{-10,-10},{230,-10},{246,80},{232,150},{258,230},{240,320},{262,400},{248,470},{270,560},{252,680},{-10,680}})
print(W, H)

--@ chunk 2
SPACE = -WALL
local DEEP = pile{{"ultramarine blue",2},{"viridian",0.6},{"bone black",1.1},{"lead white",0.3}}
local HAZE = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.5},{"cobalt violet",0.3}}
local MAGD = pile{{"magenta",1},{"ultramarine blue",1},{"bone black",0.9}}
work(SPACE, {hand="body", pile=DEEP, coverage=1.6, fill=true, angle=drift, length={40, 90}, seed=201})
work(SPACE * ellipse(640, 330, 230, 170):soften(80), {hand="body", pile=HAZE, coverage=1.0, angle=drift, length={30, 80}, seed=202})
work(SPACE * ellipse(880, 600, 200, 120):soften(60), {hand="body", pile=MAGD, coverage=1.0, angle=drift, length={30, 80}, seed=203})

--@ chunk 3
-- the station's last wall: bronze plates in courses, warm-lit from inside; the bronze floor running out to the breach
BRZ_D = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
BRZ_M = pile{{"raw sienna",2},{"bone black",0.8},{"burnt sienna",1}}
BRZ_L = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
BRZ_W = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.5},{"Mars orange",0.4}}
FLOORB = poly({{-10,515},{276,532},{290,548},{300,680},{-10,680}})
work(WALL, {hand="body", pile=BRZ_D, coverage=3, fill=true, angle=math.pi/2, clip=WALL, seed=301})
TILES = {}
local y = -10
local row = 0
while y < 515 do
  local h = rand(46, 62)
  local x = -10 - rand(0, 40)
  while x < 270 do
    local w = rand(55, 85)
    local q = poly({{x + 2, y + 2}, {x + w - 2, y + 2}, {x + w - 2, y + h - 2}, {x + 2, y + h - 2}}) * WALL
    TILES[#TILES + 1] = {x = x, y = y, w = w, h = h}
    -- lit from the left and above: tiles nearer the light (left, low) warmer
    local p = (rand(0, 1) < 0.35) and BRZ_W or BRZ_M
    work(q, {hand="body", tool="filbert 5", pile=p, coverage=2.6, fill=true, angle=0.05 + rand(-0.1, 0.1), clip=q, seed=310 + #TILES})
    x = x + w
  end
  y = y + h
  row = row + 1
end
work(FLOORB, {hand="body", pile=BRZ_M, coverage=3, fill=true, angle=0.06, clip=FLOORB, seed=390})
print(#TILES)

--@ chunk 4
-- settle the background into one cold field, then the folding floor: a floor that rises into a wall, rolls over into a ceiling that is a floor
blend(SPACE, {angle=drift, tool={kind="badger", width=20}, seed=401})
ICEF  = pile{{"cerulean blue",1},{"viridian",0.3},{"lead white",2.5},{"zinc white",0.5}}
ICEM  = pile{{"cerulean blue",1},{"ultramarine blue",0.6},{"lead white",1.4},{"viridian",0.2}}
LIMEF = pile{{"emerald green",1},{"lemon chrome",0.3},{"lead white",1.6},{"cerulean blue",0.4}}
MAGF  = pile{{"magenta",1},{"cobalt violet",1},{"lead white",0.8},{"ultramarine blue",0.3}}
VIOF  = pile{{"ultramarine blue",1.5},{"magenta",0.5},{"bone black",0.7},{"lead white",0.4}}
PLANES = {
  {{{268,550},{560,560},{610,682},{280,682}}, ICEF},          -- the floor he steps onto
  {{{560,560},{610,682},{676,600},{640,520}}, VIOF},           -- the fold's underside, turning up
  {{{640,520},{676,600},{700,300},{660,250}}, ICEM},           -- the floor become a wall
  {{{660,250},{700,300},{880,240},{820,180}}, LIMEF},          -- the wall become a ceiling-floor
  {{{820,180},{880,240},{930,420},{870,390}}, MAGF},           -- turning down again on the far side
  {{{870,390},{930,420},{1010,520},{1010,430}}, ICEM},         -- and out, a floor again, off the edge
  {{{430,240},{560,210},{600,300},{470,330}}, ICEF},           -- a loose floor-slab in the air, seen from above
  {{{470,330},{600,300},{596,318},{468,348}}, VIOF},           -- its edge
}
for i, p in ipairs(PLANES) do
  local q = poly(p[1])
  local a = math.atan(p[1][2][2] - p[1][1][2], p[1][2][1] - p[1][1][1])
  work(q, {hand="body", tool="filbert 6", pile=p[2], coverage=3, fill=true, angle=a, clip=q, seed=410 + i})
end

--@ chunk 5
-- a corridor that loops into itself with a half twist, and a room seen from outside and inside at once
local DEEPI = pile{{"ultramarine blue",2},{"viridian",0.5},{"bone black",1.4}}
local cx, cy, rx, ry, rot = 420, 115, 120, 58, -0.12
local n = 28
local function P(t)
  local x, y = rx * math.cos(t), ry * math.sin(t)
  return {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)}
end
for i = 0, n - 1 do
  local t0, t1 = 2 * math.pi * i / n, 2 * math.pi * (i + 1) / n
  local a, b = P(t0), P(t1)
  local w0, w1 = 26 * math.cos(t0 / 2), 26 * math.cos(t1 / 2)
  -- the band's width runs across the loop's plane, foreshortened: mostly vertical
  local q = poly({{a[1] - 0.3 * w0, a[2] - w0}, {b[1] - 0.3 * w1, b[2] - w1}, {b[1] + 0.3 * w1, b[2] + w1}, {a[1] + 0.3 * w0, a[2] + w0}})
  local c = math.cos((t0 + t1) / 4)
  local p = (c > 0.3) and ICEF or ((c > -0.3) and ICEM or VIOF)
  work(q, {hand="body", tool="filbert 3", pile=p, coverage=3, fill=true, angle=math.atan(b[2] - a[2], b[1] - a[1]), clip=q, seed=500 + i})
end
-- the room: outside faces up and to the right, inside faces converging into the front face
local faces = {
  {{{760,60},{860,60},{900,28},{800,28}}, LIMEF},
  {{{860,60},{900,28},{902,128},{860,160}}, MAGF},
  {{{760,60},{785,82},{785,136},{760,160}}, ICEM},
  {{{760,160},{860,160},{838,136},{785,136}}, ICEF},
  {{{760,60},{860,60},{838,82},{785,82}}, DEEPI},
  {{{785,82},{838,82},{838,136},{785,136}}, VIOF},
  {{{860,60},{838,82},{838,136},{860,160}}, MAGF},
}
for i, f in ipairs(faces) do
  local q = poly(f[1])
  work(q, {hand="body", tool="filbert 3", pile=f[2], coverage=3, fill=true, angle=0.0, clip=q, seed=540 + i})
end

--@ chunk 6
-- the Commando, small, one stride past the breach; his crimson cloth lifting behind; the bubble of air he carries
FIG = ellipse(302, 503, 8, 9) + poly({{292,513},{312,512},{316,535},{310,556},{294,556},{290,535}})
  + ribbon({{297,553},{290,572},{282,592}}, 8) + ribbon({{306,553},{316,572},{325,589}}, 8)
  + ribbon({{312,518},{320,535},{327,548}}, 6) + ribbon({{292,518},{286,534},{283,548}}, 6)
FCLOAK = poly({{290,512},{300,511},{297,540},{282,566},{266,574},{274,546}}, true)
local CRIM = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
local DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
work(FCLOAK, {hand="detail", pile=CRIM, coverage=4, fill=true, angle=2.0, clip=FCLOAK, seed=601})
work(FIG, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=1.5, clip=FIG, seed=602})
-- the bubble: a faint skin of light, brighter where it turns away from us
BUB = ellipse(303, 545, 64, 68)
local AIR  = pile{{"zinc white",3},{"cerulean blue",0.3},{"lemon chrome",0.1},medium=0.6}
local AIRW = pile{{"lead white",2},{"Mars orange",0.2},medium=0.7}
work(BUB * -FIG:grow(2) * -FCLOAK:grow(2), {hand="glaze", tool="filbert 12", pile=AIRW, coverage=0.7, load=0.18, pressure={0.08, 0.16}, angle=0.3, clip=BUB, seed=603})
local skin = BUB:rim(5, 3) * -FIG:grow(2)
work(skin, {hand="body", tool="filbert 3", pile=AIR, coverage=1.2, load=0.3, pressure={0.15, 0.3}, angle=0, clip=BUB:grow(2), seed=604})

--@ chunk 7
-- the bronze: darker and colder toward the torn edge, warm where the station's light still falls; shards peeling off into the cold
local GZD = pile{{"bone brown",1},{"ultramarine blue",0.8},{"bone black",0.4},medium=0.65}
local GZW = pile{{"Indian yellow",1},{"Mars orange",0.5},{"lead white",0.4},medium=0.6}
local edge = WALL * mask(function(x, y) return clamp((x - 120) / 130, 0, 1) end)
work(edge, {hand="glaze", tool="filbert 10", pile=GZD, coverage=1.3, fill=true, angle=math.pi / 2, clip=WALL, seed=701})
local warm = (WALL + FLOORB) * ellipse(60, 520, 220, 200):soften(80)
work(warm, {hand="glaze", tool="filbert 10", pile=GZW, coverage=1.0, fill=true, angle=0.1, clip=WALL + FLOORB, seed=702})
-- shards: bronze near the wall, their colour inverting as they drift out
SHARDS = {{262,140,26,14,0.5}, {290,210,20,10,-0.6}, {320,120,16,8,1.1}, {300,300,22,10,0.3}, {350,250,14,7,-1.0}, {380,180,11,6,0.7}, {280,420,18,9,-0.3}, {330,380,12,6,0.9}}
local INV1 = pile{{"cerulean blue",1},{"ultramarine blue",0.5},{"lead white",1},{"bone black",0.2}}
for i, s in ipairs(SHARDS) do
  local c, sn = math.cos(s[5]), math.sin(s[5])
  local function P(u, v) return {s[1] + u * c - v * sn, s[2] + u * sn + v * c} end
  local q = poly({P(-s[3], -s[4]), P(s[3], -s[4]), P(s[3] * 0.8, s[4]), P(-s[3], s[4])})
  local far = (s[1] - 250) / 130
  local p = (far < 0.35) and BRZ_M or ((far < 0.7) and VIOF or INV1)
  work(q, {hand="detail", pile=p, coverage=3.5, fill=true, angle=s[5], clip=q, seed=710 + i})
end
-- the cold field: one more pass of blending through the hazy patch, and a darker edge to the top and right
local DEEP2 = pile{{"ultramarine blue",2},{"viridian",0.4},{"bone black",1.6}}
ARCH = ellipse(420, 115, 150, 90) + rect(755, 22, 152, 142)
for _, p in ipairs(PLANES) do ARCH = ARCH + poly(p[1]) end
local keep = SPACE * -(FIG:grow(3) + FCLOAK:grow(3) + BUB:grow(4) + ARCH:grow(3) + rect(250, 100, 160, 360))
local vig = keep * mask(function(x, y) return clamp(math.max((150 - y) / 150, (x - 850) / 150), 0, 1) end)
work(vig, {hand="glaze", tool="filbert 12", pile=DEEP2, coverage=1.0, fill=true, angle=drift, clip=keep, seed=720})
blend(keep * ellipse(640, 330, 280, 200), {angle=drift, tool={kind="badger", width=20}, seed=721})

--@ chunk 8
-- the warm glaze went olive and the dark glaze went streaky: restate the bronze opaquely, warm low and left, dark at the torn edge
local warmz = (WALL + FLOORB) * ellipse(40, 540, 250, 230):soften(40)
work(warmz, {hand="body", tool="filbert 6", pile=BRZ_W, coverage=3.5, fill=true, angle=0.05, clip=WALL + FLOORB, seed=801})
local LIT = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1.2}}
work((WALL + FLOORB) * ellipse(10, 560, 140, 130):soften(40), {hand="body", tool="filbert 6", pile=LIT, coverage=2.5, fill=true, angle=0.05, clip=WALL + FLOORB, seed=802})
local edgez = WALL * mask(function(x, y) return x > 150 and 1 or 0 end):soften(20) * -warmz
work(edgez, {hand="body", tool="filbert 5", pile=BRZ_D, coverage=3.5, fill=true, angle=math.pi / 2, clip=WALL, seed=803})
-- the frame left round the room by the dark veil: fill it with the field's dark
local DEEP2 = pile{{"ultramarine blue",2},{"viridian",0.4},{"bone black",1.6}}
ROOMH = poly({{760,60},{800,28},{900,28},{902,128},{860,160},{760,160}})
local fr = rect(745, 15, 172, 160) * -ROOMH
work(fr, {hand="body", tool="filbert 4", pile=DEEP2, coverage=3, fill=true, angle=0, clip=fr, seed=804})

--@ chunk 9
-- the room's frame came up darker than the field: lay the field's own blue over it and blend it into the field
local FIELD = pile{{"ultramarine blue",2},{"viridian",0.5},{"bone black",1},{"lead white",0.55}}
local fr = rect(745, 15, 172, 160) * -ROOMH
work(fr, {hand="body", tool="filbert 4", pile=FIELD, coverage=3, fill=true, angle=drift, clip=fr, seed=901})
blend(rect(735, 5, 192, 180) * -ROOMH * SPACE, {angle=drift, tool={kind="badger", width=14}, seed=902})
print(wait(3 * 24 * 60))

--@ chunk 10
-- on dry paint: the plating's seams and lit lips, the torn edge, the floors' joints and hinges, the figure's two lights
local rig = brush{kind="rigger", width=2.0, point=0.85}
local fb = brush{kind="filbert", width=3}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.15, 0.3}, clip=clip}) end
local SEAM = pile{{"bone black",2},{"burnt sienna",0.5}}
local LIP  = pile{{"yellow ochre",1.5},{"Mars orange",0.5},{"lead white",1.3}}
local ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local ICED = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.3}}
local VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
local GOLD = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
-- plating
for i, t in ipairs(TILES) do
  if t.y < 515 then
    S(rig, SEAM, 0.7, {{t.x, t.y}, {t.x + t.w, t.y + 1}}, {0.55, 0.5}, WALL)
    S(rig, SEAM, 0.7, {{t.x, t.y}, {t.x + 1, t.y + t.h}}, {0.5, 0.45}, WALL)
    local warmth = clamp(1 - (t.x + 20) / 260, 0.15, 1)
    S(rig, LIP, 0.6, {{t.x + 3, t.y + 3}, {t.x + t.w * (0.4 + 0.5 * warmth), t.y + 4}}, {0.35 * warmth + 0.1, 0.05}, WALL)
    if i % 7 == 3 then rig:reload(VERD, 0.6); rig:touch(t.x + t.w * 0.7, t.y + t.h * 0.6, {pressure=0.8, clip=WALL}) end
  end
end
-- floor plates running out to the breach
for _, y in ipairs({548, 575, 608, 645}) do S(rig, SEAM, 0.7, {{-5, y - 30 + (y - 548) * 0.2}, {150, y - 14}, {290, y}}, {0.5, 0.45}, FLOORB) end
for _, x in ipairs({60, 140, 215}) do S(rig, SEAM, 0.6, {{x, 520 + x * 0.06}, {x - 18, 680}}, {0.45, 0.5}, FLOORB) end
-- the torn edge: the cold catches it
S(rig, ICE, 0.7, BREACH, {0.4, 0.3})
-- the cold floors: joints across them and bright hinges where they fold
for i, p in ipairs(PLANES) do
  local a, b, c, d = p[1][1], p[1][2], p[1][3], p[1][4]
  for _, f in ipairs({0.25, 0.5, 0.75}) do
    S(rig, ICED, 0.5, {{lerp(a[1], b[1], f), lerp(a[2], b[2], f)}, {lerp(d[1], c[1], f), lerp(d[2], c[2], f)}}, {0.3, 0.25})
    S(rig, ICED, 0.5, {{lerp(a[1], d[1], f), lerp(a[2], d[2], f)}, {lerp(b[1], c[1], f), lerp(b[2], c[2], f)}}, {0.3, 0.25})
  end
  S(rig, ICE, 0.8, {a, b}, {0.5, 0.4})
end
-- the loop's joints
local cx, cy, rx, ry, rot = 420, 115, 120, 58, -0.12
for i = 0, 27, 2 do
  local t = 2 * math.pi * i / 28
  local x, y = rx * math.cos(t), ry * math.sin(t)
  local px, py = cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)
  local w = 24 * math.cos(t / 2)
  S(rig, ICED, 0.5, {{px - 0.3 * w, py - w}, {px + 0.3 * w, py + w}}, {0.3, 0.3})
end
-- the room's edges
for _, e in ipairs({{{760,60},{860,60}}, {{860,60},{900,28}}, {{760,60},{800,28}}, {{800,28},{900,28}}, {{860,60},{860,160}}}) do S(rig, ICE, 0.7, e, {0.4, 0.35}) end
-- the figure: the station's warm light on his back, the cold on his front, one cold optic
S(rig, GOLD, 0.7, {{295,500}, {292,512}, {290,535}, {294,554}}, {0.45, 0.3})
S(rig, ICE, 0.6, {{311,500}, {315,520}, {317,536}}, {0.35, 0.3})
rig:reload(ICE, 1.0); rig:touch(309, 502, {pressure=0.9})
-- the bubble: warm where it faces the station, cold where it faces out
local function arc(a0, a1) local pts = {} for k = 0, 12 do local a = lerp(a0, a1, k / 12); pts[#pts + 1] = {303 + 64 * math.cos(a), 545 + 68 * math.sin(a)} end return pts end
S(fb, GOLD, 0.35, arc(2.6, 4.2), {0.12, 0.2})
S(fb, ICE, 0.35, arc(5.4, 7.0), {0.15, 0.1})

--@ chunk 11
-- lose the boxes and halos the veils left round the room and the loop; his shadow thrown out ahead of him across the cold floor
local cx, cy, rx, ry, rot = 420, 115, 120, 58, -0.12
local function P(t)
  local x, y = rx * math.cos(t), ry * math.sin(t)
  return {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)}
end
LOOPM = nil
for i = 0, 27 do
  local t0, t1 = 2 * math.pi * i / 28, 2 * math.pi * (i + 1) / 28
  local a, b = P(t0), P(t1)
  local w0, w1 = 27 * math.cos(t0 / 2), 27 * math.cos(t1 / 2)
  local q = poly({{a[1] - 0.3 * w0, a[2] - w0}, {b[1] - 0.3 * w1, b[2] - w1}, {b[1] + 0.3 * w1, b[2] + w1}, {a[1] + 0.3 * w0, a[2] + w0}})
  LOOPM = LOOPM and (LOOPM + q) or q
end
local FIELD2 = pile{{"ultramarine blue",2},{"viridian",0.6},{"bone black",0.9},{"lead white",0.7}}
local around = (ellipse(830, 95, 160, 125):soften(40) - ROOMH:grow(1)) * SPACE
work(around, {hand="body", tool="filbert 6", pile=FIELD2, coverage=1.6, load=0.5, angle=drift, length={30, 80}, edge="lost", clip=SPACE - ROOMH:grow(1), seed=1101})
blend(around, {angle=drift, tool={kind="badger", width=18}, seed=1102})
local ring = (ellipse(420, 115, 180, 110):soften(35) - LOOPM:grow(1)) * SPACE
work(ring, {hand="body", tool="filbert 6", pile=FIELD2, coverage=1.4, load=0.5, angle=drift, length={30, 80}, edge="lost", clip=SPACE - LOOPM:grow(1), seed=1103})
blend(ring, {angle=drift, tool={kind="badger", width=18}, seed=1104})
-- his shadow on the ice floor, long, toward the folding wall
local SHV = pile{{"ultramarine blue",1},{"magenta",0.4},{"bone black",0.4},{"lead white",0.5}}
local sh = poly({{285,592},{325,589},{470,612},{520,622},{470,626},{300,600}}, true) * poly(PLANES[1][1])
work(sh, {hand="body", tool="filbert 3", pile=SHV, coverage=2.5, fill=true, angle=0.15, edge="soft", clip=poly(PLANES[1][1]), seed=1105})

--@ chunk 12
-- the softening went wrong: two flat pale discs, and they ran over the folding planes. Put the dark field back with
-- strokes like its own, restate the two planes they crossed, and quiet the shadow
local solid = LOOPM:grow(1) + ROOMH:grow(1)
for _, p in ipairs(PLANES) do solid = solid + poly(p[1]):grow(1) end
local field = SPACE - solid
local DK = pile{{"ultramarine blue",2},{"viridian",0.45},{"bone black",1.5},{"lead white",0.25}}
local discs = (ellipse(830, 95, 175, 140) + ellipse(420, 115, 195, 125)) * field
work(discs, {hand="body", tool="filbert 6", pile=DK, coverage=2.8, fill=true, angle=drift, length={40, 100}, edge="soft", clip=field, seed=1201})
for _, i in ipairs({4, 5}) do
  local q = poly(PLANES[i][1])
  local a = math.atan(PLANES[i][1][2][2] - PLANES[i][1][1][2], PLANES[i][1][2][1] - PLANES[i][1][1][1])
  work(q, {hand="body", tool="filbert 6", pile=PLANES[i][2], coverage=3, fill=true, angle=a, clip=q, seed=1210 + i})
end
local fl = poly(PLANES[1][1])
local sh = poly({{285,592},{325,589},{470,612},{520,622},{470,626},{300,600}}, true):grow(6) * fl
work(sh, {hand="body", tool="filbert 3", pile=ICEM, coverage=1.5, load=0.5, angle=0.15, clip=fl, seed=1220})
blend(sh, {angle=0.15, tool={kind="badger", width=10}, seed=1221})

--@ chunk 13
-- the discs still show as shapes: carry the same dark across the whole upper field so they become the field
local solid = LOOPM:grow(1) + ROOMH:grow(1)
for _, p in ipairs(PLANES) do solid = solid + poly(p[1]):grow(1) end
for _, s in ipairs(SHARDS) do solid = solid + ellipse(s[1], s[2], s[3] + 3, s[3] + 3) end
local field = SPACE - solid
local DK = pile{{"ultramarine blue",2},{"viridian",0.45},{"bone black",1.5},{"lead white",0.25}}
local top = field * mask(function(x, y) return clamp((265 - y) / 90, 0, 1) end)
work(top, {hand="body", tool="filbert 6", pile=DK, coverage=2.4, fill=true, angle=drift, length={40, 110}, edge="lost", clip=field, seed=1301})
blend(top * mask(function(x, y) return (y > 120 and y < 290) and 1 or 0 end):soften(30), {angle=drift, tool={kind="badger", width=18}, seed=1302})

--@ chunk 14
-- more floor coming loose: three small tiled slabs adrift, each turned another way; then let it all dry
SLABS2 = {
  {top={{700,462},{772,444},{792,486},{716,506}}, side={{716,506},{792,486},{792,497},{716,518}}, pt=ICEF, ps=MAGF},
  {top={{560,40},{610,30},{622,62},{570,74}}, side={{570,74},{622,62},{621,70},{569,82}}, pt=LIMEF, ps=VIOF},
  {top={{940,560},{985,548},{1000,590},{952,604}}, side={{940,560},{952,604},{946,612},{934,566}}, pt=ICEM, ps=VIOF},
}
for i, s in ipairs(SLABS2) do
  local t, sd = poly(s.top), poly(s.side)
  work(t, {hand="detail", pile=s.pt, coverage=3.5, fill=true, angle=math.atan(s.top[2][2] - s.top[1][2], s.top[2][1] - s.top[1][1]), clip=t, seed=1400 + i})
  work(sd, {hand="detail", pile=s.ps, coverage=3.5, fill=true, angle=0, clip=sd, seed=1410 + i})
end
print(wait(3 * 24 * 60))

--@ chunk 15
-- joints and hinges on the restated planes and the new slabs; his outline caught by both lights once more
local rig = brush{kind="rigger", width=2.0, point=0.85}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr or {0.4, 0.3}, ramps={0.15, 0.3}}) end
local ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local ICED = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.3}}
local quads = {PLANES[4][1], PLANES[5][1]}
for _, s in ipairs(SLABS2) do quads[#quads + 1] = s.top end
for _, q in ipairs(quads) do
  local a, b, c, d = q[1], q[2], q[3], q[4]
  for _, f in ipairs({0.25, 0.5, 0.75}) do
    S(ICED, 0.5, {{lerp(a[1], b[1], f), lerp(a[2], b[2], f)}, {lerp(d[1], c[1], f), lerp(d[2], c[2], f)}}, {0.28, 0.22})
    S(ICED, 0.5, {{lerp(a[1], d[1], f), lerp(a[2], d[2], f)}, {lerp(b[1], c[1], f), lerp(b[2], c[2], f)}}, {0.28, 0.22})
  end
  S(ICE, 0.8, {a, b}, {0.45, 0.35})
end
S(ICE, 0.8, {{660,250},{820,180}}, {0.5, 0.4})
S(ICE, 0.8, {{820,180},{880,240}}, {0.5, 0.4})

--@ chunk 16
-- the figure as a frame, not a stick: helm, pauldron, pack, heavier legs, his staff; the bubble's gold dashes off the wall; the shadow quieter
local DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
local parts = poly({{296,494},{306,492},{313,498},{313,508},{306,512},{297,510}}) + ellipse(299, 518, 9, 6) + poly({{286,516},{294,514},{294,540},{286,540}})
  + ribbon({{298,553},{291,572},{283,592}}, 10) + ribbon({{306,553},{316,572},{325,589}}, 10)
work(parts, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=1.5, clip=parts, seed=1601})
local rig = brush{kind="rigger", width=2.2, point=0.8}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.2}}) end
S(DARKSTEEL, 0.9, {{331,470},{330,530},{329,596}}, {0.7, 0.7})
local ICE = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local GOLD = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
S(ICE, 0.6, {{333,472},{332,530},{331,594}}, {0.3, 0.2})
S(GOLD, 0.7, {{295,495},{291,512},{287,520},{286,538}}, {0.4, 0.35})
S(ICE, 0.6, {{313,499},{313,508}}, {0.4, 0.4})
rig:reload(ICE, 1.0); rig:touch(311, 501, {pressure=0.8})
-- the bubble's gold arc where it fell on the wall: back to bronze
local arcm = ribbon((function() local pts = {} for k = 0, 16 do local a = lerp(2.5, 4.3, k / 16); pts[#pts + 1] = {303 + 64 * math.cos(a), 545 + 68 * math.sin(a)} end return pts end)(), 6) * (WALL + FLOORB)
work(arcm, {hand="detail", pile=BRZ_M, coverage=3, fill=true, angle=1.5, clip=arcm, seed=1602})
-- the shadow quieter
local fl = poly(PLANES[1][1])
local sh = poly({{285,592},{325,589},{470,612},{520,622},{470,626},{300,600}}, true):grow(8) * fl
work(sh, {hand="body", tool="filbert 4", pile=ICEF, coverage=1.2, load=0.35, angle=0.15, clip=fl, seed=1603})

--@ chunk 17
-- the patched arc came up darker than the warm bronze round it: lay the warm bronze over it
local arcm = ribbon((function() local pts = {} for k = 0, 16 do local a = lerp(2.5, 4.3, k / 16); pts[#pts + 1] = {303 + 64 * math.cos(a), 545 + 68 * math.sin(a)} end return pts end)(), 8) * (WALL + FLOORB)
local WB = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.6}}
work(arcm, {hand="detail", pile=WB, coverage=2.5, fill=true, angle=1.5, clip=arcm, seed=1701})
blend(arcm:grow(3) * (WALL + FLOORB), {angle=1.5, tool={kind="badger", width=6}, seed=1702})

--@ chunk 18
-- the TESTAMENT side as scale-plates, not bricks: overlapping rows laid from the bottom up so each row's lower edge
-- lies over the tops of the row beneath; rows offset by the golden fraction; torn along the breach
function scale_pts(cx, top, w, h, rot, dx, dy)
  local pts = {{-w / 2, 0}, {w / 2, 0}, {w / 2, h * 0.5}}
  for k = 1, 9 do local a = math.pi * k / 10; pts[#pts + 1] = {w / 2 * math.cos(a), h * 0.5 + h * 0.5 * math.sin(a)} end
  pts[#pts + 1] = {-w / 2, h * 0.5}
  local c, s = math.cos(rot or 0), math.sin(rot or 0)
  local out = {}
  for _, p in ipairs(pts) do out[#out + 1] = {cx + p[1] * c - p[2] * s + (dx or 0), top + p[1] * s + p[2] * c + (dy or 0)} end
  return out
end
local function breach_x(y)
  for i = 1, #BREACH - 1 do
    local a, b = BREACH[i], BREACH[i + 1]
    if y >= a[2] and y <= b[2] then return lerp(a[1], b[1], (y - a[2]) / (b[2] - a[2])) end
  end
  return 250
end
SCALES = {}
local SW, SH, STEP = 52, 46, 31
local phi = 0.618
local rows = {}
local y = -30
local r = 0
while y < 500 do rows[#rows + 1] = {y = y, r = r}; y = y + STEP; r = r + 1 end
local SC1 = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"yellow ochre",0.5}}
local SC2 = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.5}}
local SC3 = pile{{"bone black",1.4},{"burnt sienna",1},{"yellow ochre",0.8}}
local CAV = pile{{"bone black",1.6},{"burnt sienna",0.8},{"ultramarine blue",0.3}}
local wallup = WALL * rect(-10, -10, 290, 525)
work(wallup, {hand="body", tool="filbert 6", pile=CAV, coverage=3, fill=true, angle=math.pi / 2, clip=wallup, seed=1799})
wait(2 * 24 * 60)
for ri = #rows, 1, -1 do
  local row = rows[ri]
  local off = ((row.r * phi) % 1) * SW
  local x = -SW + off
  while x < 280 do
    local cx = x + SW / 2
    local bx = breach_x(row.y + SH * 0.5)
    local rot, dx, dy = rand(-0.05, 0.05), 0, 0
    local keep = true
    if cx + SW * 0.3 > bx then
      -- at the tear: some plates are gone, some hang loose and turned
      if rand(0, 1) < 0.45 then keep = false else rot = rand(-0.6, 0.6); dx = rand(2, 14); dy = rand(-4, 8) end
    end
    if keep and cx - SW / 2 < bx + 10 then
      local pts = scale_pts(cx, row.y, SW + rand(-4, 4), SH + rand(-3, 3), rot, dx, dy)
      local q = poly(pts)
      local warm = clamp(1 - (cx + 40) / 300, 0, 1) * 0.6 + clamp((row.y - 150) / 400, 0, 1) * 0.4
      local u = rand(0, 1)
      local p = (u < warm * 0.8) and SC2 or ((u < 0.75) and SC1 or SC3)
      work(q, {hand="detail", tool={kind="filbert", width=3}, pile=p, coverage=3.5, fill=true, angle=1.4 + rot, clip=q, seed=1800 + #SCALES})
      SCALES[#SCALES + 1] = {pts = pts, cx = cx + dx, top = row.y + dy, w = SW, h = SH, rot = rot, loose = (dx ~= 0)}
    end
    x = x + SW
  end
end
print(#SCALES)

--@ chunk 19
-- the figure redrawn as a war-body leaning into the step; first put the old staff back into the field and the floor
local FIELD = pile{{"ultramarine blue",2},{"viridian",0.5},{"bone black",1},{"lead white",0.55}}
local oldstaff_up = ribbon({{331,466},{330,550}}, 6)
local oldstaff_dn = ribbon({{330,552},{329,600}}, 6)
work(oldstaff_up, {hand="detail", pile=FIELD, coverage=3.5, fill=true, angle=1.57, clip=oldstaff_up, seed=1901})
work(oldstaff_dn, {hand="detail", pile=ICEF, coverage=3.5, fill=true, angle=0.1, clip=oldstaff_dn, seed=1902})
local DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
local CRIM = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
local CRIMD = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.3}}
-- cloak falling and lifting behind him
FCLOAK2 = poly({{297,511},{307,512},{302,540},{292,566},{276,588},{262,590},{258,580},{274,560},{284,534}}, true)
work(FCLOAK2, {hand="detail", pile=CRIM, coverage=4, fill=true, angle=2.0, clip=FCLOAK2, seed=1903})
local fold = ribbon({{300,520},{290,550},{274,578}}, 4)
work(fold * FCLOAK2, {hand="detail", pile=CRIMD, coverage=3, fill=true, angle=2.0, clip=FCLOAK2, seed=1904})
-- the frame: helm thrust forward, pauldron, breast, legs in stride, the arm out to the staff
HELM2 = poly({{305,489},{316,486},{324,492},{325,503},{318,510},{307,508},{303,499}})
PAUL2 = poly({{298,514},{310,509},{320,514},{318,523},{304,524}}, true)
TORSO2 = poly({{300,516},{320,515},{324,534},{317,556},{300,556},{296,534}})
LEGR2 = ribbon({{302,553},{292,573},{280,594}}, 10)
LEGF2 = ribbon({{311,553},{324,568},{336,588}}, 10)
ARM2 = ribbon({{318,520},{330,532},{340,534}}, 7)
FIG2 = HELM2 + PAUL2 + TORSO2 + LEGR2 + LEGF2 + ARM2
work(FIG2, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=1.3, clip=FIG2, seed=1905})
STAFF2 = ribbon({{349,600},{342,540},{335,470}}, 3)
work(STAFF2, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=-1.45, clip=STAFF2, seed=1906})

--@ chunk 20
-- depth: smaller, fainter folds further off; and the air: one continuous faint sphere, its skin running through colours
local FAR1 = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",1},{"bone black",0.4}}
local FAR2 = pile{{"cobalt violet",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.5}}
local FAR3 = pile{{"viridian",0.6},{"cerulean blue",1},{"lead white",0.9},{"bone black",0.5}}
FARPLANES = {
  {{{520,230},{580,222},{586,236},{526,244}}, FAR1}, {{{580,222},{586,236},{594,200},{590,190}}, FAR2}, {{{590,190},{594,200},{640,196},{634,186}}, FAR3},
  {{{900,300},{940,296},{944,306},{904,310}}, FAR1}, {{{940,296},{944,306},{960,330},{958,318}}, FAR2},
  {{{760,390},{800,384},{804,392},{764,398}}, FAR3}, {{{800,384},{804,392},{808,368},{805,362}}, FAR1},
}
for i, p in ipairs(FARPLANES) do
  local q = poly(p[1])
  work(q, {hand="detail", pile=p[2], coverage=3, fill=true, angle=0.05, clip=q, seed=2000 + i})
end
-- the bubble's skin, continuous: a soft pale band, tinted round its circumference
local cx, cy, rx, ry = 305, 543, 66, 70
local tints = {
  pile{{"zinc white",3},{"cerulean blue",0.5}}, pile{{"zinc white",3},{"cobalt violet",0.6}},
  pile{{"zinc white",3},{"emerald green",0.4},{"lemon chrome",0.1}}, pile{{"lead white",3},{"Indian yellow",0.3}},
}
local fb = brush{kind="filbert", width=3.5}
for k = 0, 11 do
  local a0, a1 = 2 * math.pi * k / 12, 2 * math.pi * (k + 1.15) / 12
  local pts = {}
  for j = 0, 6 do local a = lerp(a0, a1, j / 6); pts[#pts + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end
  -- warm tint on the side toward the station (left), cold ones elsewhere
  local t = (math.cos((a0 + a1) / 2) < -0.6) and tints[4] or tints[(k % 3) + 1]
  fb:reload(t, 0.3)
  fb:stroke(pts, {pressure={0.18, 0.18}, ramps={0.2, 0.2}})
end
local skin = ellipse(cx, cy, rx + 5, ry + 5) - ellipse(cx, cy, rx - 5, ry - 5)
blend(skin, {angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end, tool={kind="badger", width=6}, seed=2010})
-- a breath of air inside it: the faintest pale veil
local AIR = pile{{"zinc white",3},{"cerulean blue",0.2},medium=0.7}
local inside = ellipse(cx, cy, rx - 4, ry - 4) - FIG2:grow(2) - FCLOAK2:grow(2) - STAFF2:grow(1)
work(inside, {hand="glaze", tool="filbert 10", pile=AIR, coverage=0.6, load=0.12, pressure={0.06, 0.12}, angle=0.3, clip=inside, seed=2011})

--@ chunk 21
print(wait(3*24*60)); print(drying(100,200), drying(310,530))

--@ chunk 22
-- on dry paint: each plate's lip lit by the warm light behind us, its shadow cast on the plate below;
-- the loose plates at the tear catch the cold on their outer edges; the figure's two rims and optic
local rig = brush{kind="rigger", width=2.2, point=0.85}
local function S(p, ld, pts, pr, clip) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.15, 0.3}, clip=clip}) end
local LIPW = pile{{"yellow ochre",1.5},{"Mars orange",0.5},{"lead white",1.4}}
local LIPH = pile{{"lead white",2},{"cadmium yellow",0.8},{"yellow ochre",0.5}}
local SHAD = pile{{"bone black",2},{"burnt sienna",0.6}}
local ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
local GOLD = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
for i, s in ipairs(SCALES) do
  local arc, sh = {}, {}
  for k = 3, #s.pts do
    local p = s.pts[k]
    arc[#arc + 1] = {p[1], p[2] - 1.6}
    sh[#sh + 1] = {p[1], p[2] + 2.6}
  end
  local warm = clamp(1 - (s.cx + 20) / 300, 0.1, 1) * 0.6 + clamp((s.top - 100) / 400, 0, 1) * 0.4
  S(SHAD, 0.7, sh, {0.55, 0.5})
  S((warm > 0.55) and LIPH or LIPW, 0.6, arc, {0.25 + 0.3 * warm, 0.2 + 0.3 * warm})
  if s.loose then S(ICE, 0.6, {s.pts[2], s.pts[3], s.pts[5]}, {0.35, 0.25}) end
  if i % 9 == 4 then rig:reload(VERD, 0.6); rig:touch(s.cx + rand(-10, 10), s.top + s.h * 0.55, {pressure=0.8}) end
end
-- the figure: warm down his back and helm, cold down his front, the optic, the staff's two lights
S(GOLD, 0.7, {{304,492},{302,500},{299,514},{297,532},{301,552}}, {0.45, 0.3})
S(GOLD, 0.6, {{300,556},{291,574},{281,592}}, {0.3, 0.2})
S(ICE, 0.6, {{324,494},{325,503},{321,514}}, {0.4, 0.3})
S(ICE, 0.6, {{322,520},{325,535},{318,555}}, {0.35, 0.25})
S(ICE, 0.6, {{313,556},{326,569},{338,588}}, {0.3, 0.2})
rig:reload(ICE, 1.0); rig:touch(321, 497, {pressure=0.9})
S(ICE, 0.6, {{337,472},{344,540},{350,598}}, {0.3, 0.2})
S(GOLD, 0.5, {{334,474},{341,540}}, {0.2, 0.1})
S(GOLD, 0.6, {{299,512},{306,509},{316,511}}, {0.4, 0.2})
