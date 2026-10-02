-- easel session "icon": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={16,18}, seed=1414, ground={{pile={{"lead white",2},{"yellow ochre",0.3}}, um=160, apply="knife", texture=0.2}}}
CX = 500
HALO = {500, 330, 150}
INNER = rect(52, 52, 896, 1229)
BORDER = -INNER
HEAVEN = ellipse(500, 30, 230, 120) * INNER
print(W, H)

--@ chunk 2
-- the dark red border, the gold ground, the halo a richer gold, the segment of heaven deep blue
local RED  = pile{{"red earth",1.5},{"Mars red",0.6},{"bone black",0.3}}
local GOLD = pile{{"yellow ochre",1.5},{"Mars yellow",0.8},{"cadmium yellow",0.3},{"lead white",0.5}}
local GOLDH = pile{{"Mars yellow",1},{"cadmium yellow",0.6},{"yellow ochre",0.6},{"lead white",0.4},{"Mars orange",0.15}}
local BLUE = pile{{"ultramarine blue",1.5},{"cobalt blue",0.5},{"bone black",0.3},{"lead white",0.2}}
work(BORDER, {hand="body", tool="filbert 8", pile=RED, coverage=3.2, fill=true, angle=0, clip=BORDER, seed=201})
local field = INNER - HEAVEN
work(field, {hand="body", tool="filbert 10", pile=GOLD, coverage=3, fill=true, angle=0.05, clip=field, seed=202})
work(HEAVEN, {hand="body", tool="filbert 6", pile=BLUE, coverage=3.5, fill=true, angle=0, clip=HEAVEN, seed=203})
HALOM = ellipse(HALO[1], HALO[2], HALO[3], HALO[3])
work(HALOM, {hand="body", tool="filbert 6", pile=GOLDH, coverage=3, fill=true, angle=function(x, y) return math.atan(y - HALO[2], x - HALO[1]) + 1.57 end, clip=HALOM, seed=204})
print(wait(3 * 24 * 60))

--@ chunk 3
-- the saint in flat shapes: cannon-lance, arms and pauldrons in dark steel, crimson tabard, great helm, greaves;
-- the palm; the sea of fire and the TESTAMENT; the angels in heaven
local STEEL = pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.6}}
local STEELD = pile{{"bone black",1.4},{"ultramarine blue",0.8},{"lead white",0.2}}
local CRIM = pile{{"vermilion",1},{"Mars red",0.8},{"rose madder",0.5}}
local GREEN = pile{{"viridian",1},{"yellow ochre",0.5},{"bone black",0.2}}
local FIRE = pile{{"vermilion",1},{"Mars orange",0.8},{"cadmium red",0.3}}
local FIRED = pile{{"Mars red",1},{"red earth",0.6},{"bone black",0.2}}
local BRZ = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.4}}
local WHITE = pile{{"lead white",3},{"yellow ochre",0.15}}
local function W(m, p, a, s) work(m, {hand="detail", tool={kind="filbert", width=4}, pile=p, coverage=4.5, fill=true, angle=a or 1.57, clip=m, seed=s}) end
LANCE = rect(318, 190, 24, 880) + poly({{306,150},{354,150},{350,196},{310,196}}) + poly({{312,150},{348,150},{330,108}})
W(LANCE, STEELD, 1.57, 301)
ARMS = ribbon({{392,455},{362,560},{338,650}}, 40) + ribbon({{608,455},{640,560},{662,640}}, 40)
PAULS = ellipse(400, 455, 72, 42) + ellipse(600, 455, 72, 42)
GREAVES = poly({{432,1030},{474,1030},{470,1110},{436,1110}}) + poly({{526,1030},{568,1030},{564,1110},{530,1110}})
FEET = poly({{424,1108},{474,1108},{478,1128},{420,1128}}) + poly({{522,1108},{574,1108},{580,1128},{524,1128}})
W(ARMS + GREAVES + FEET, STEEL, 1.57, 302)
W(PAULS, STEEL, 0, 303)
TABARD = poly({{440,425},{560,425},{590,640},{630,1040},{370,1040},{410,640}})
W(TABARD, CRIM, 1.57, 304)
HANDS = ellipse(332, 660, 22, 26) + ellipse(664, 640, 22, 26)
W(HANDS, STEELD, 0, 305)
HELM = poly({{448,262},{470,238},{500,232},{530,238},{552,262},{556,400},{444,400}}, true)
GORGET = poly({{438,398},{562,398},{566,428},{434,428}})
W(GORGET, STEELD, 0, 306)
W(HELM, STEEL, 1.57, 307)
-- the palm frond: a stem, and leaflets laid as single strokes
local rig = brush{kind="round", width=5, point=0.7}
rig:reload(GREEN, 0.9); rig:stroke({{664, 630}, {676, 480}, {690, 320}, {700, 250}}, {pressure={0.6, 0.15}})
for k = 0, 14 do
  local t = k / 14
  local x, y = lerp(668, 698, t), lerp(560, 262, t)
  local l = lerp(70, 26, t)
  rig:reload(GREEN, 0.8); rig:stroke({{x, y}, {x - l * 0.6, y + l * 0.35}, {x - l, y + l * 0.85}}, {pressure={0.55, 0.0}, ramps={0.05, 0.7}})
  rig:reload(GREEN, 0.8); rig:stroke({{x, y}, {x + l * 0.6, y + l * 0.3}, {x + l, y + l * 0.8}}, {pressure={0.55, 0.0}, ramps={0.05, 0.7}})
end
-- sea of fire across the bottom, the TESTAMENT small upon it
SEA = rect(52, 1140, 896, 141)
W(SEA, FIRED, 0, 310)
for k = 0, 22 do
  local x = 60 + k * 40 + rand(-6, 6)
  local fl = poly({{x - 20, 1180}, {x + 20, 1180}, {x + 6, 1152}, {x + 2, 1128}, {x - 6, 1150}}, true) * INNER
  W(fl, FIRE, -1.57, 320 + k)
end
RINGO = ellipse(500, 1196, 92, 32)
RINGI = ellipse(500, 1196, 62, 19)
W(RINGO - RINGI, BRZ, 0, 350)
-- angels: white robes, small wings, in the blue
for i, a in ipairs({{405, 70}, {500, 96}, {595, 70}}) do
  local robe = poly({{a[1] - 9, a[2]}, {a[1] + 9, a[2]}, {a[1] + 15, a[2] + 34}, {a[1] - 15, a[2] + 34}}, true) * HEAVEN
  local wings = (poly({{a[1] - 6, a[2] + 4}, {a[1] - 36, a[2] - 10}, {a[1] - 30, a[2] + 14}}) + poly({{a[1] + 6, a[2] + 4}, {a[1] + 36, a[2] - 10}, {a[1] + 30, a[2] + 14}})) * HEAVEN
  W(wings, pile{{"lead white",2},{"cerulean blue",0.4}}, 0, 360 + i)
  W(robe, WHITE, 1.57, 370 + i)
  W(ellipse(a[1], a[2] - 8, 7, 7) * HEAVEN, pile{{"Mars yellow",1},{"cadmium yellow",0.6},{"lead white",0.5}}, 0, 380 + i)
end
print(wait(4 * 24 * 60))

--@ chunk 4
-- lines, on dry paint: outlines, the incised halo, assist, the cross, the cannon's coils, the palm, fire, lettering
local rig = brush{kind="rigger", width=2.0, point=0.85}
local fine = brush{kind="rigger", width=1.3, point=0.95}
local fl = brush{kind="flat", width=12}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.55, 0.5}, ramps={0.08, 0.15}, clip=clip}) end
local OUT  = pile{{"bone brown",1},{"bone black",0.6},{"red earth",0.3}}
local INC  = pile{{"raw sienna",1},{"burnt sienna",0.5},{"yellow ochre",0.4}}
local GOLDL = pile{{"lead white",1.5},{"Mars yellow",1},{"cadmium yellow",0.5}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.15}}
local REDL = pile{{"red earth",1.2},{"Mars red",0.6},{"bone black",0.2}}
local CRD  = pile{{"rose madder",1},{"Mars red",0.6},{"bone black",0.35}}
local ICE  = pile{{"zinc white",3},{"cerulean blue",1}}
local GRN  = pile{{"viridian",1},{"bone black",0.4},{"yellow ochre",0.3}}
local function circle(cx, cy, rx, ry, a0, a1, n) local t = {} for k = 0, n do local a = lerp(a0, a1, k / n); t[#t + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end return t end
-- the halo: incised rays and a double rim, behind the helm
local behind = HALOM - (HELM:grow(2) + PAULS:grow(2) + GORGET:grow(2) + LANCE:grow(2))
for k = 0, 47 do
  local a = 2 * math.pi * k / 48
  S(fine, INC, 0.6, {{HALO[1] + 92 * math.cos(a), HALO[2] + 92 * math.sin(a)}, {HALO[1] + 140 * math.cos(a), HALO[2] + 140 * math.sin(a)}}, {0.35, 0.35}, behind)
end
S(rig, OUT, 0.7, circle(HALO[1], HALO[2], 149, 149, 0, 2 * math.pi, 80), {0.55, 0.55}, -(HELM + PAULS + LANCE:grow(2)))
S(fine, REDL, 0.6, circle(HALO[1], HALO[2], 142, 142, 0, 2 * math.pi, 80), {0.4, 0.4}, behind)
-- outlines of the figure
local function outline(pts, closed) local t = {} for _, p in ipairs(pts) do t[#t + 1] = p end; if closed then t[#t + 1] = pts[1] end; S(rig, OUT, 0.8, t, {0.6, 0.6}) end
outline({{440,425},{410,640},{370,1040},{630,1040},{590,640},{560,425}}, false)
outline(circle(500, 315, 54, 84, math.pi, 2 * math.pi, 24), false)
outline({{446,262},{444,400}}, false); outline({{554,262},{556,400}}, false)
outline(circle(400, 455, 72, 42, 0, 2 * math.pi, 30), true); outline(circle(600, 455, 72, 42, 0, 2 * math.pi, 30), true)
-- helm: visor slit, breaths, the single cold optic, gold assist down its sides
S(rig, OUT, 0.9, {{458, 320}, {542, 320}}, {0.8, 0.8})
S(rig, OUT, 0.9, {{500, 322}, {500, 392}}, {0.6, 0.6})
for _, y in ipairs({345, 360, 375}) do S(fine, OUT, 0.8, {{476, y}, {490, y}}, {0.5, 0.5}); S(fine, OUT, 0.8, {{510, y}, {524, y}}, {0.5, 0.5}) end
for _, x in ipairs({458, 464, 470}) do S(fine, GOLDL, 0.7, {{x, 262}, {x - 2, 300}}, {0.35, 0.2}); S(fine, GOLDL, 0.7, {{x, 336}, {x - 3, 392}}, {0.35, 0.2}) end
local tip = brush{kind="round", width=7, point=0.4}
tip:reload(ICE, 1.0); tip:touch(500, 320, {pressure=0.95})
-- pauldrons: lames with assist
for _, c in ipairs({{400, 455}, {600, 455}}) do
  for k = 1, 3 do S(fine, GOLDL, 0.7, circle(c[1], c[2] + 8 * k - 6, 60 - 8 * k, 26 - 4 * k, math.pi * 1.1, math.pi * 1.9, 16), {0.35, 0.3}) end
end
-- arms: lames
for _, a in ipairs({{{392,455},{362,560},{338,650}}, {{608,455},{640,560},{662,640}}}) do
  for t = 0.2, 0.9, 0.14 do
    local p = {lerp(a[1][1], a[3][1], t), lerp(a[1][2], a[3][2], t)}
    S(fine, OUT, 0.7, {{p[1] - 18, p[2]}, {p[1] + 18, p[2] + 2}}, {0.5, 0.5})
    S(fine, GOLDL, 0.7, {{p[1] - 16, p[2] + 4}, {p[1] + 6, p[2] + 5}}, {0.3, 0.2})
  end
end
-- tabard: folds and assist, the bone cross
for _, f in ipairs({{{455,620},{440,830},{420,1030}}, {{478,640},{472,840},{462,1036}}, {{522,640},{530,840},{540,1036}}, {{545,620},{562,830},{582,1030}}}) do S(rig, CRD, 0.8, f, {0.5, 0.6}) end
for _, f in ipairs({{{462,700},{452,860},{436,1020}}, {{530,700},{542,860},{556,1020}}, {{432,760},{420,900},{404,1024}}, {{566,760},{580,900},{596,1024}}}) do S(fine, GOLDL, 0.7, f, {0.3, 0.15}) end
S(fl, BONE, 0.9, {{500, 470}, {500, 720}}, {0.9, 0.9})
S(fl, BONE, 0.9, {{440, 545}, {560, 545}}, {0.9, 0.9})
S(fine, OUT, 0.6, {{506, 470}, {506, 720}}, {0.35, 0.35})
-- the cannon: coils, a cold muzzle, and lightning held at its tip
for y = 220, 1040, 46 do S(fine, ICE, 0.6, {{318, y}, {342, y + 4}}, {0.4, 0.4}) end
S(rig, OUT, 0.8, {{318, 196}, {318, 1070}}, {0.45, 0.45}); S(rig, OUT, 0.8, {{342, 196}, {342, 1070}}, {0.45, 0.45})
S(rig, ICE, 0.9, {{330, 108}, {322, 88}, {336, 74}, {326, 52}}, {0.55, 0.2})
S(fine, ICE, 0.8, {{330, 108}, {344, 92}, {338, 78}}, {0.45, 0.1})
-- the palm: darker leaflets over the first, a gold midrib
S(rig, GOLDL, 0.7, {{664, 630}, {676, 480}, {690, 320}, {700, 250}}, {0.4, 0.1})
for k = 0, 10 do
  local t = k / 10
  local x, y = lerp(670, 698, t), lerp(540, 270, t)
  local l = lerp(66, 26, t)
  S(rig, GRN, 0.8, {{x, y}, {x - l * 0.6, y + l * 0.4}, {x - l, y + l * 0.9}}, {0.6, 0.0})
  S(rig, GRN, 0.8, {{x, y}, {x + l * 0.6, y + l * 0.35}, {x + l, y + l * 0.85}}, {0.6, 0.0})
end
-- fire: tongues in layers, the ring of the TESTAMENT gold within
local FO = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.3}}
local FY = pile{{"cadmium yellow",1},{"lead white",0.6}}
for k = 0, 40 do
  local x = 60 + k * 22
  local h = rand(24, 44)
  S(rig, (k % 2 == 0) and FO or FY, 0.8, {{x, 1270}, {x + 6, 1230 - h * 0.5}, {x - 2, 1200 - h}}, {0.6, 0.0}, INNER - (RINGO:grow(4)))
end
S(rig, GOLDL, 0.8, circle(500, 1196, 92, 32, 0, 2 * math.pi, 40), {0.45, 0.45})
S(rig, OUT, 0.8, circle(500, 1196, 62, 19, 0, 2 * math.pi, 40), {0.4, 0.4})
work(RINGI, {hand="detail", pile=pile{{"cadmium yellow",1},{"lead white",1.2},{"Mars yellow",0.4}}, coverage=4, fill=true, angle=0, clip=RINGI, seed=401})
for k = 0, 15 do local a = 2 * math.pi * k / 16; S(fine, OUT, 0.7, {{500 + 64 * math.cos(a), 1196 + 20 * math.sin(a)}, {500 + 90 * math.cos(a), 1196 + 31 * math.sin(a)}}, {0.4, 0.4}) end
-- lettering, abstract, red on gold, each word under a titlo
local function glyphs(x0, y0, n, seed)
  for i = 0, n - 1 do
    local x = x0 + i * 26
    S(rig, REDL, 0.8, {{x, y0}, {x, y0 + 34}}, {0.65, 0.65})
    local kind = (i + seed) % 3
    if kind == 0 then S(rig, REDL, 0.8, {{x, y0 + 17}, {x + 14, y0 + 17}, {x + 14, y0 + 34}}, {0.6, 0.6})
    elseif kind == 1 then S(rig, REDL, 0.8, {{x, y0}, {x + 15, y0 + 10}, {x, y0 + 20}}, {0.6, 0.6})
    else S(rig, REDL, 0.8, {{x + 15, y0}, {x + 15, y0 + 34}}, {0.6, 0.6}); S(rig, REDL, 0.8, {{x, y0}, {x + 15, y0 + 34}}, {0.6, 0.6}) end
  end
  S(rig, REDL, 0.8, {{x0 - 4, y0 - 12}, {x0 + n * 26 - 10, y0 - 12}}, {0.45, 0.45})
end
glyphs(120, 230, 4, 0); glyphs(160, 290, 3, 1)
glyphs(760, 230, 4, 2); glyphs(780, 290, 3, 0)
-- an inner line round the gold
S(rig, OUT, 0.7, {{60, 60}, {940, 60}, {940, 1273}, {60, 1273}, {60, 60}}, {0.5, 0.5})

--@ chunk 5
-- two long strokes ran away as loose curves (the frame line through the border, the tabard's outline round the feet):
-- paint them out with border red and ground gold, then the frame line as straight segments
local RED  = pile{{"red earth",1.5},{"Mars red",0.6},{"bone black",0.3}}
local GOLD = pile{{"yellow ochre",1.5},{"Mars yellow",0.8},{"cadmium yellow",0.3},{"lead white",0.5}}
work(BORDER, {hand="body", tool="filbert 8", pile=RED, coverage=3.2, fill=true, angle=0, clip=BORDER, seed=501})
local figure = TABARD:grow(3) + GREAVES:grow(3) + FEET:grow(3) + LANCE:grow(3) + ARMS:grow(3) + HANDS:grow(3) + PAULS:grow(3) + HALOM:grow(2) + SEA
local strip = (INNER - INNER:shrink(26)) - HEAVEN:grow(2) - SEA
local base = INNER * rect(190, 560, 620, 590) - figure
work(strip + base, {hand="body", tool="filbert 6", pile=GOLD, coverage=3.2, fill=true, angle=0.05, clip=strip + base, seed=502})
print(wait(3 * 24 * 60))
local rig = brush{kind="rigger", width=2.0, point=0.85}
local OUT = pile{{"bone brown",1},{"bone black",0.6},{"red earth",0.3}}
for _, s in ipairs({{{62,62},{938,62}}, {{938,62},{938,1271}}, {{938,1271},{62,1271}}, {{62,1271},{62,62}}}) do
  rig:reload(OUT, 0.8); rig:stroke(s, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
end
-- the tabard hem and sides as straight segments
for _, s in ipairs({{{410,640},{370,1040}}, {{370,1040},{630,1040}}, {{630,1040},{590,640}}}) do
  rig:reload(OUT, 0.8); rig:stroke(s, {pressure={0.55, 0.55}, ramps={0.02, 0.02}})
end

--@ chunk 6
-- the palm's lower stem and leaflets back to the hand; the cold optic brighter
local rig = brush{kind="round", width=5, point=0.7}
local GREEN = pile{{"viridian",1},{"yellow ochre",0.5},{"bone black",0.2}}
local GRN  = pile{{"viridian",1},{"bone black",0.4},{"yellow ochre",0.3}}
local GOLDL = pile{{"lead white",1.5},{"Mars yellow",1},{"cadmium yellow",0.5}}
rig:reload(GREEN, 0.9); rig:stroke({{664, 632}, {670, 590}, {676, 540}}, {pressure={0.6, 0.5}})
for k = 0, 4 do
  local t = k / 4
  local x, y = lerp(664, 674, t), lerp(616, 548, t)
  local l = lerp(74, 66, t)
  for _, sgn in ipairs({-1, 1}) do
    rig:reload((k % 2 == 0) and GREEN or GRN, 0.8)
    rig:stroke({{x, y}, {x + sgn * l * 0.6, y + l * 0.35}, {x + sgn * l, y + l * 0.85}}, {pressure={0.55, 0.0}, ramps={0.05, 0.7}, clip=-(HANDS + ARMS)})
  end
end
local fine = brush{kind="rigger", width=1.3, point=0.95}
fine:reload(GOLDL, 0.7); fine:stroke({{666, 628}, {676, 540}}, {pressure={0.4, 0.3}})
local tip = brush{kind="round", width=10, point=0.4}
tip:reload(pile{{"cerulean blue",1},{"zinc white",2}}, 1.0); tip:touch(500, 320, {pressure=0.9})
local c = brush{kind="round", width=5, point=0.4}
c:reload(pile{{"zinc white",4}}, 1.0); c:touch(500, 320, {pressure=0.9})
