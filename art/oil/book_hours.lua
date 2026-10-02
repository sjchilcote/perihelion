-- easel session "book_hours": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={18,20}, seed=1717, ground={{pile={{"lead white",2.5},{"yellow ochre",0.25},{"raw sienna",0.05}}, um=160, apply="knife", texture=0.15}}}
LC = {500, 410}
local function half(r) local t = {} for k = 0, 60 do local a = math.pi + math.pi * k / 60; t[#t + 1] = {LC[1] + r * math.cos(a), LC[2] + r * math.sin(a)} end; return poly(t) end
LUN_G = half(384) - half(366)
LUN_B = half(366) - half(258)
LUN_I = half(258)
PIC = rect(110, 430, 780, 845)
SKY = rect(110, 430, 780, 300)
FIELD = poly({{110,690},{890,670},{890,1275},{110,1275}})
CASTLE = poly({{300,690},{310,600},{340,600},{345,560},{360,560},{365,600},{430,600},{440,520},{455,470},{470,520},{480,600},{520,600},{530,500},{545,450},{560,500},{570,600},{640,600},{645,560},{660,560},{665,600},{690,600},{700,690}})
RINGC = ellipse(500, 620, 150, 46) - ellipse(500, 620, 118, 30)
OUTPOST = rect(150, 760, 150, 80) + rect(170, 730, 60, 32)
local function W(m, p, a, s, tool) work(m, {hand="detail", tool={kind="filbert", width=tool or 6}, pile=p, coverage=3.6, fill=true, angle=a or 0, clip=m, seed=s}) end
local GOLD = pile{{"Mars yellow",1},{"cadmium yellow",0.6},{"yellow ochre",0.6},{"lead white",0.4}}
local BLUE = pile{{"ultramarine blue",1.5},{"cobalt blue",0.6},{"lead white",0.4}}
local BLUED = pile{{"ultramarine blue",1.5},{"bone black",0.5},{"cobalt blue",0.3}}
local SPACE = pile{{"ultramarine blue",1.2},{"bone black",1},{"cobalt violet",0.2}}
local CAST = pile{{"lead white",2},{"cerulean blue",0.6},{"cobalt violet",0.2}}
local SAIL = pile{{"lead white",2},{"Mars yellow",0.5},{"cerulean blue",0.15}}
local GREYB = pile{{"lead white",1.5},{"bone black",0.4},{"ultramarine blue",0.2}}
W(LUN_G, GOLD, 0, 101)
W(LUN_B, BLUE, 0, 102)
W(LUN_I, BLUED, 0, 103)
W(SKY, SPACE, 0, 104, 8)
W(FIELD, SAIL, 0.02, 105, 8)
W(CASTLE, CAST, 1.57, 106, 4)
W(RINGC, CAST, 0, 107, 4)
W(OUTPOST, GREYB, 0, 108, 4)
print(wait(3 * 24 * 60))

--@ chunk 2
-- pale shapes laid into the wet sky came up mottled: restate them on dry paint; then the figures and the sun's chariot
local function W(m, p, a, s, tool, cov) work(m, {hand="detail", tool={kind="filbert", width=tool or 4}, pile=p, coverage=cov or 5.5, fill=true, angle=a or 0, clip=m, seed=s}) end
local CAST = pile{{"lead white",2.2},{"cerulean blue",0.5},{"cobalt violet",0.2}}
local SAIL = pile{{"lead white",2},{"Mars yellow",0.5},{"cerulean blue",0.15}}
local GREYB = pile{{"lead white",1.5},{"bone black",0.35},{"ultramarine blue",0.2}}
W(CASTLE, CAST, 1.57, 201)
W(RINGC, CAST, 0, 202)
W(FIELD * rect(110, 660, 780, 90), SAIL, 0.02, 203, 6)
W(OUTPOST, GREYB, 0, 204)
print(wait(4 * 24 * 60))
-- docents in a row across the field, white-robed with jewel-coloured hoods, bending to the work
local WHITE = pile{{"lead white",3},{"yellow ochre",0.1}}
local HOODS = {pile{{"vermilion",1},{"rose madder",0.4}}, pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.3}}, pile{{"viridian",1},{"emerald green",0.4},{"lead white",0.3}}, pile{{"cobalt violet",1},{"magenta",0.3},{"lead white",0.4}}}
DOCS = {}
for i = 0, 6 do
  local x = 250 + i * 95 + ((i % 2) * 12)
  local y = 980 + ((i * 37) % 50)
  local lean = (i % 2 == 0) and 1 or -1
  local robe = poly({{x - 12, y - 52}, {x + 8, y - 54}, {x + 18, y}, {x - 22, y}}, true)
  local hood = ellipse(x - 2 + lean * 4, y - 60, 10, 11)
  W(robe, WHITE, 1.57, 210 + i)
  W(hood, HOODS[(i % 4) + 1], 0, 220 + i)
  DOCS[#DOCS + 1] = {x, y, lean}
end
-- MIRIAD crew at the outpost door, small, in grey with amber
local CREW = pile{{"lead white",1.2},{"bone black",0.5}}
local AMB = pile{{"Mars orange",1},{"cadmium yellow",0.6}}
CREWP = {{320, 850}, {346, 856}, {368, 846}}
for i, c in ipairs(CREWP) do
  local b = poly({{c[1] - 7, c[2] - 30}, {c[1] + 7, c[2] - 30}, {c[1] + 9, c[2]}, {c[1] - 9, c[2]}})
  W(b, CREW, 1.57, 230 + i)
  W(ellipse(c[1], c[2] - 37, 6, 6), AMB, 0, 240 + i)
end
-- the sun's chariot in the lunette: a red car on gold wheels, two white horses, the gold sun riding it
local RED = pile{{"vermilion",1},{"Mars red",0.5}}
local GOLD = pile{{"Mars yellow",1},{"cadmium yellow",0.8},{"lead white",0.5}}
local HORSE = pile{{"lead white",3}}
CAR = poly({{450,320},{560,320},{550,360},{460,360}})
W(CAR, RED, 0, 250)
WHEELS = ellipse(468, 366, 16, 16) + ellipse(542, 366, 16, 16)
W(WHEELS, GOLD, 0, 251)
HORSES = poly({{590,330},{650,322},{672,300},{684,306},{668,332},{660,360},{600,358}}, true) + poly({{604,346},{664,340},{686,318},{698,324},{682,350},{674,376},{614,374}}, true)
W(HORSES, HORSE, 0, 252)
SUNB = ellipse(505, 262, 50, 50)
W(SUNB, GOLD, 0, 253)
print(wait(4 * 24 * 60))

--@ chunk 3
-- all the drawing, as segments and arcs, on dry paint
local rig = brush{kind="rigger", width=1.8, point=0.85}
local fine = brush{kind="rigger", width=1.2, point=0.95}
local tip = brush{kind="round", width=2.5, point=0.5}
local function seg(b, p, a, c, pr, clip) b:reload(p, 0.8); b:stroke({a, c}, {pressure=pr or {0.5, 0.5}, ramps={0.06, 0.12}, clip=clip}) end
local function arcs(b, p, cx, cy, rx, ry, a0, a1, n, pr, clip) b:reload(p, 0.8); local t = {} for k = 0, n do local a = lerp(a0, a1, k / n); t[#t + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end; b:stroke(t, {pressure=pr or {0.45, 0.45}, ramps={0.05, 0.1}, clip=clip}) end
local OUT  = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.2}}
local GOLDL = pile{{"lead white",1.2},{"Mars yellow",1},{"cadmium yellow",0.6}}
local REDL = pile{{"vermilion",1},{"Mars red",0.5}}
local BLUL = pile{{"ultramarine blue",1},{"cobalt blue",0.5}}
local WHT = pile{{"zinc white",4}}
local WARM = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.5}}
local CDK = pile{{"cerulean blue",1},{"ultramarine blue",0.6},{"lead white",0.6},{"bone black",0.2}}
-- lunette: calendar ticks across the gold rim, the orbit in gold, the zodiac of fold glyphs, stars
for k = 0, 60 do
  local a = math.pi + math.pi * k / 60
  seg(fine, (k % 2 == 0) and REDL or BLUL, {LC[1] + 368 * math.cos(a), LC[2] + 368 * math.sin(a)}, {LC[1] + 382 * math.cos(a), LC[2] + 382 * math.sin(a)}, {0.45, 0.45})
end
arcs(rig, GOLDL, LC[1], LC[2], 312, 312, math.pi, 2 * math.pi, 60, {0.45, 0.45})
arcs(fine, GOLDL, LC[1], LC[2], 258, 258, math.pi, 2 * math.pi, 60, {0.4, 0.4})
local function glyph(cx, cy, n, r, rot, turn)
  local p, q = {}, {}
  for i = 0, n do local a = rot + 2 * math.pi * i / n; p[#p + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}; local b = rot + turn + 2 * math.pi * i / n; q[#q + 1] = {cx + 0.618 * r * math.cos(b), cy + 0.618 * r * math.sin(b)} end
  for i = 1, n do seg(fine, GOLDL, p[i], p[i + 1], {0.5, 0.5}); seg(fine, GOLDL, q[i], q[i + 1], {0.4, 0.4}) end
end
for k = 0, 11 do
  local a = math.pi + math.pi * (k + 0.5) / 12
  glyph(LC[1] + 312 * math.cos(a), LC[2] + 312 * math.sin(a) + 0, ({3, 4, 5, 6, 4, 5, 3, 6, 5, 4, 6, 3})[k + 1], 14, a, 0.2 + k * 0.37)
end
for _, s in ipairs({{330, 300}, {360, 210}, {420, 180}, {600, 190}, {660, 250}, {380, 370}, {700, 380}, {560, 160}, {290, 380}}) do tip:reload(GOLDL, 0.8); tip:touch(s[1], s[2], {pressure=0.6}) end
-- the sun: calm face and rays; chariot wheels, horses' legs and reins
arcs(fine, OUT, 490, 258, 9, 5, 0.15 * math.pi, 0.85 * math.pi, 6); arcs(fine, OUT, 520, 258, 9, 5, 0.15 * math.pi, 0.85 * math.pi, 6)
arcs(fine, OUT, 505, 280, 11, 5, 0.2 * math.pi, 0.8 * math.pi, 6)
for k = 0, 15 do local a = 2 * math.pi * k / 16; seg(fine, GOLDL, {505 + 54 * math.cos(a), 262 + 54 * math.sin(a)}, {505 + ((k % 2 == 0) and 74 or 64) * math.cos(a), 262 + ((k % 2 == 0) and 74 or 64) * math.sin(a)}, {0.5, 0.1}, LUN_I) end
for _, w in ipairs({{468, 366}, {542, 366}}) do for k = 0, 3 do local a = k * math.pi / 4; seg(fine, REDL, {w[1] - 14 * math.cos(a), w[2] - 14 * math.sin(a)}, {w[1] + 14 * math.cos(a), w[2] + 14 * math.sin(a)}, {0.4, 0.4}) end end
for _, l in ipairs({{608, 356}, {626, 358}, {646, 358}, {658, 356}, {620, 372}, {640, 374}, {660, 374}, {672, 372}}) do seg(fine, WHT, {l[1], l[2]}, {l[1] + 2, l[2] + 22}, {0.5, 0.4}, LUN_I) end
seg(fine, GOLDL, {556, 330}, {676, 306}, {0.4, 0.4}); seg(fine, GOLDL, {556, 336}, {688, 322}, {0.4, 0.4})
-- the picture's frame
for _, s in ipairs({{{110, 430}, {890, 430}}, {{890, 430}, {890, 1275}}, {{890, 1275}, {110, 1275}}, {{110, 1275}, {110, 430}}}) do seg(rig, GOLDL, s[1], s[2], {0.7, 0.7}) end
for _, s in ipairs({{{102, 422}, {898, 422}}, {{898, 422}, {898, 1283}}, {{898, 1283}, {102, 1283}}, {{102, 1283}, {102, 422}}}) do seg(fine, REDL, s[1], s[2], {0.5, 0.5}) end
-- sky: a few stars
for _, s in ipairs({{150, 470}, {220, 520}, {280, 455}, {720, 470}, {800, 530}, {860, 460}, {640, 500}, {380, 480}, {170, 600}, {840, 610}}) do tip:reload(WHT, 0.8); tip:touch(s[1], s[2], {pressure=0.5}) end
-- the castle: outlines, gold spire tips, windows, the ring's curtain wall
for _, s in ipairs({{{310,600},{340,600}}, {{365,600},{430,600}}, {{480,600},{520,600}}, {{570,600},{640,600}}, {{665,600},{690,600}}, {{440,520},{455,470}}, {{455,470},{470,520}}, {{530,500},{545,450}}, {{545,450},{560,500}}, {{300,690},{310,600}}, {{690,600},{700,690}}}) do seg(fine, CDK, s[1], s[2], {0.45, 0.45}) end
seg(rig, GOLDL, {450, 486}, {455, 470}, {0.6, 0.4}); seg(rig, GOLDL, {541, 466}, {545, 450}, {0.6, 0.4})
seg(rig, GOLDL, {345, 560}, {360, 560}, {0.5, 0.5}); seg(rig, GOLDL, {645, 560}, {660, 560}, {0.5, 0.5})
arcs(rig, CDK, 500, 620, 150, 46, 0, 2 * math.pi, 50, {0.45, 0.45})
arcs(fine, CDK, 500, 620, 118, 30, 0, 2 * math.pi, 40, {0.4, 0.4})
for k = 0, 23 do local a = 2 * math.pi * k / 24; if math.sin(a) > -0.2 then tip:reload(WARM, 0.8); tip:touch(500 + 134 * math.cos(a), 620 + 38 * math.sin(a), {pressure=0.5}) end end
for _, x in ipairs({448, 456, 462, 538, 546, 552}) do tip:reload(WARM, 0.8); tip:touch(x, 560, {pressure=0.45}) end
-- the field: furrows converging on the castle, polished bright strips behind the docents
for k = 0, 16 do
  local xb = 110 + k * 49
  seg(fine, pile{{"Mars yellow",1},{"yellow ochre",0.6},{"lead white",0.5}}, {xb, 1275}, {lerp(xb, 500, 0.82), 700}, {0.35, 0.1}, FIELD)
end
for _, d in ipairs(DOCS) do
  seg(rig, WHT, {d[1] - 30, d[2] + 30}, {d[1] + 50, d[2] + 70}, {0.4, 0.2}, FIELD)
end
-- docents: outlines, the long brush held out ahead, its head on the film
for _, d in ipairs(DOCS) do
  local x, y, l = d[1], d[2], d[3]
  seg(fine, OUT, {x - 12, y - 52}, {x - 22, y}, {0.45, 0.45}); seg(fine, OUT, {x + 8, y - 54}, {x + 18, y}, {0.45, 0.45}); seg(fine, OUT, {x - 22, y}, {x + 18, y}, {0.45, 0.45})
  seg(rig, pile{{"burnt sienna",1},{"bone black",0.4}}, {x + 4, y - 40}, {x + 4 + l * 60, y + 18}, {0.5, 0.5})
  seg(rig, pile{{"bone black",1},{"burnt sienna",0.5}}, {x + l * 58, y + 14}, {x + l * 72, y + 26}, {0.8, 0.8})
  seg(fine, pile{{"lead white",1},{"yellow ochre",0.6},{"raw sienna",0.3}}, {x - 4, y - 44}, {x - 8, y - 4}, {0.3, 0.2})
end
-- the outpost: amber hazard stripes, windows, a mast; the crew's visors
for k = 0, 7 do seg(rig, pile{{"Mars orange",1},{"cadmium yellow",0.6}}, {154 + k * 18, 834}, {166 + k * 18, 822}, {0.55, 0.55}, OUTPOST) end
for _, x in ipairs({180, 210, 240, 270}) do seg(rig, pile{{"cerulean blue",1},{"lead white",1}}, {x, 790}, {x + 10, 790}, {0.7, 0.7}) end
seg(rig, OUT, {200, 730}, {200, 690}, {0.5, 0.3}); tip:reload(REDL, 0.9); tip:touch(200, 688, {pressure=0.7})
for _, s in ipairs({{{150,760},{300,760}}, {{300,760},{300,840}}, {{300,840},{150,840}}, {{150,840},{150,760}}}) do seg(fine, OUT, s[1], s[2], {0.4, 0.4}) end
for _, c in ipairs(CREWP) do seg(fine, OUT, {c[1] - 4, c[2] - 37}, {c[1] + 4, c[2] - 37}, {0.6, 0.6}) end
