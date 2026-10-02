-- easel session "ambassadors": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=109,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.3},{"lead white",0.5}}, um=35, apply="roller"}}}

--@ chunk 2
CURT = rect(0, 0, 1000, 900)
FLOOR = rect(0, 900, 1000, 350)
SHELF_TOP = poly({{370,520},{630,520},{640,560},{360,560}})
SHELF_LOW = poly({{380,760},{620,760},{628,790},{372,790}})
SHELFM = poly({{360,500},{640,500},{640,900},{360,900}})
LHEAD = poly({{150,340},{142,260},{160,190},{210,150},{260,160},{280,210},{270,280},{246,330},{206,352}}, true)
RHEAD = poly({{760,350},{740,290},{742,220},{770,170},{830,154},{868,190},{866,260},{846,320},{806,350}}, true)
LROBE = poly({{60,1180},{80,900},{100,620},{140,430},{200,370},{290,390},{340,470},{360,640},{360,900},{380,1180}}, true)
RROBE = poly({{620,1180},{640,900},{640,640},{660,470},{720,390},{820,380},{880,440},{910,620},{930,900},{950,1180}}, true)
FIG = LHEAD + RHEAD + LROBE + RROBE
CG1 = pile{{"viridian",1},{"bone black",0.5},{"raw sienna",0.5},{"bone brown",0.2}}
FL1 = pile{{"bone brown",1.5},{"raw sienna",0.6},{"lead white",0.4},{"bone black",0.2}}
local c = CURT - FIG:grow(3) - SHELFM
work(c, {hand="broad", pile=CG1, coverage=2.8, fill=true, clip=c, angle=math.pi/2})
local f = FLOOR - FIG:grow(3)
work(f, {hand="broad", pile=FL1, coverage=2.8, fill=true, clip=f, angle=0})

--@ chunk 3
CR = pile{{"vermilion",0.6},{"red earth",1},{"rose madder",0.6},{"bone brown",0.3}}
VB = pile{{"bone black",1},{"bone brown",0.6},{"cobalt violet",0.4},{"ultramarine blue",0.2}}
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
WD = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"bone black",0.6}}
work(LROBE - LHEAD, {hand="body", pile=CR, coverage=3, fill=true, clip=LROBE, angle=math.pi/2, tool="filbert 10"})
work(RROBE - RHEAD, {hand="body", pile=VB, coverage=3, fill=true, clip=RROBE, angle=math.pi/2, tool="filbert 10"})
work(LHEAD, {hand="detail", pile=BD, coverage=3, fill=true, clip=LHEAD})
work(RHEAD, {hand="detail", pile=BD, coverage=3, fill=true, clip=RHEAD})
local sh = SHELFM - FIG:grow(2)
work(sh, {hand="body", pile=WD, coverage=3, fill=true, clip=sh, angle=math.pi/2, tool="filbert 10"})

--@ chunk 4
wait(4 * 24 * 60)
CGL = pile{{"viridian",1},{"raw sienna",0.7},{"lead white",0.35},{"bone black",0.15}}
CGD = pile{{"viridian",0.8},{"bone black",0.8},{"bone brown",0.3}}
local c = CURT - FIG:grow(2) - SHELFM
local x = 0; local i = 0
while x < 1000 do
  local w = 46 + 18 * math.sin(i * 1.7)
  local band = c * poly({{x, 0}, {x + w, 0}, {x + w + 6, 900}, {x + 6, 900}})
  local P = (i % 3 == 0) and CGL or ((i % 3 == 1) and CG1 or CGD)
  work(band, {hand="detail", pile=P, coverage=3.5, fill=true, clip=band, angle=math.pi/2})
  x = x + w; i = i + 1
end

--@ chunk 5
wait(3 * 24 * 60)
-- damask: rosettes of seed-points on the golden angle, in a half-drop repeat, a lighter green, slightly varied
local c = CURT - FIG:grow(2) - SHELFM
local t = brush{kind="round", width=3.2, point=0.2}
local GA = math.rad(137.50776)
local DM = pile{{"viridian",1},{"raw sienna",0.8},{"lead white",0.6},{"yellow ochre",0.2}}
for row = 0, 6 do for col = 0, 6 do
  local cx = 40 + col * 150 + (row % 2) * 75 + 6 * math.sin(row * 2.1 + col)
  local cy = 60 + row * 130
  for k = 1, 21 do
    local r = 7 * math.sqrt(k); local a = k * GA + row
    local x, y = cx + r * math.cos(a), cy + r * math.sin(a) * 1.25
    if c:at(x, y) > 0.9 then t:reload(DM, 0.7); t:touch(x, y, {pressure=0.35}) end
  end
end end

--@ chunk 6
wait(2 * 24 * 60)
CGM = pile{{"viridian",1},{"raw sienna",0.6},{"lead white",0.18},{"bone black",0.3}}
local c = CURT - FIG:grow(2) - SHELFM
local x = 0; local i = 0
while x < 1000 do
  local w = 46 + 18 * math.sin(i * 1.7)
  if i % 3 == 0 then
    local band = c * poly({{x, 0}, {x + w, 0}, {x + w + 6, 900}, {x + 6, 900}})
    work(band, {hand="body", pile=CGM, coverage=3.5, fill=true, clip=band, angle=math.pi/2})
  end
  x = x + w; i = i + 1
end

--@ chunk 7
wait(3 * 24 * 60)
-- damask motifs: a pomegranate-like lozenge holding a smaller turned lozenge, in a half-drop repeat
local c = CURT - FIG:grow(2) - SHELFM
local DM = pile{{"viridian",1},{"raw sienna",0.8},{"lead white",0.45},{"yellow ochre",0.25}}
local outer, inner
for row = 0, 6 do for col = 0, 7 do
  local cx = 20 + col * 136 + (row % 2) * 68 + 5 * math.sin(row * 2.1 + col)
  local cy = 60 + row * 128
  local o = poly({{cx, cy - 26}, {cx + 16, cy}, {cx, cy + 26}, {cx - 16, cy}}) - poly({{cx, cy - 20}, {cx + 11, cy}, {cx, cy + 20}, {cx - 11, cy}})
  local a = 0.5 + 0.1 * col
  local n = {} for k = 0, 3 do local b = a + k * math.pi / 2; n[#n+1] = {cx + 8 * math.cos(b), cy + 10 * math.sin(b)} end
  local m = poly(n)
  outer = outer and (outer + o) or o; inner = inner and (inner + m) or m
end end
local all = (outer + inner) * c
work(all, {hand="detail", pile=DM, coverage=3.5, fill=true, clip=all})

--@ chunk 8
wait(1 * 24 * 60)
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
B1 = pile{{"raw sienna",1},{"bone brown",0.7},{"lead white",1},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
local function facets(F, clip) for _, f in ipairs(F) do local m = poly(f[1]) * clip:grow(1); if m:area() > 2 then work(m, {hand="detail", pile=f[2], coverage=3.5, fill=true, clip=m}) end end end
LHF = {
  {{{142,260},{160,190},{210,150},{200,220},{160,262}}, B4},
  {{{210,150},{260,160},{280,210},{236,214},{200,220}}, B3},
  {{{160,262},{200,220},{236,214},{280,210},{276,250},{226,262},{170,284}}, B3},
  {{{142,260},{160,262},{170,284},{160,330},{150,340}}, B2},
  {{{170,284},{226,262},{232,330},{206,352},{160,330}}, Q5},
  {{{226,262},{276,250},{270,280},{246,330},{232,330}}, Q3},
}
facets(LHF, LHEAD)
RHF = {
  {{{770,170},{830,154},{820,214},{780,226},{742,220}}, B3},
  {{{830,154},{868,190},{866,240},{820,214}}, B2},
  {{{742,220},{780,226},{820,214},{866,240},{866,260},{810,262},{752,280},{740,290}}, B3},
  {{{740,290},{752,280},{790,272},{790,340},{760,350}}, Q5},
  {{{752,280},{810,262},{866,260},{846,320},{806,350},{790,340},{790,272}}, Q3},
}
facets(RHF, RHEAD)

--@ chunk 9
wait(2 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local d = brush{kind="round", width=1.0, point=0.8}
local tb = brush{kind="round", width=1.8, point=0.2}
local function eyes(a, b, c, n, s0)
  local t, gap = 0.05, 0.3
  for k = 1, n do local u = 1 - t; local x, y = u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]; local s = s0 * (1 - 0.08 * (k - 1))
    local m = ellipse(x, y, s + 2.5, s * 0.75 + 2.5); work(m, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=m})
    local o = ellipse(x, y + 0.5, s, s * 0.72); work(o, {hand="detail", pile=EYE, coverage=3.5, fill=true, clip=o})
    local l = ellipse(x, y, s + 2.5, s * 0.75 + 2.5) * rect(0, 0, 2000, y - s * 0.15); work(l, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=l})
    tb:reload(B4, 0.8); tb:touch(x - s * 0.3, y + s * 0.15, {pressure=0.2})
    t = t + gap; gap = gap * 0.7 end
end
eyes({248, 272}, {206, 256}, {168, 288}, 5, 4.6)
eyes({760, 286}, {796, 266}, {846, 268}, 5, 4.4)
for _, mo in ipairs{{{222,318},{238,312},{248,320},{242,332},{226,332}}, {{758,322},{772,316},{784,322},{778,334},{762,334}}} do
  local m = poly(mo, true); work(m, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=m})
  d:reload(Q1, 0.8); d:stroke({{mo[1][1] + 1, mo[1][2] + 3}, {mo[3][1] - 1, mo[3][2] + 3}}, {pressure={0.1, 0.6, 0.1}})
end

--@ chunk 10
wait(1 * 24 * 60)
RUGR = pile{{"red earth",1},{"rose madder",0.4},{"vermilion",0.2},{"bone brown",0.2}}
DK = pile{{"bone black",1.2},{"bone brown",0.8}}
SHW = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.5}}
local rug = poly({{360,520},{640,520},{644,610},{356,610}}) - FIG:grow(2)
work(rug, {hand="detail", pile=RUGR, coverage=3.5, fill=true, clip=rug})
local rec = poly({{366,610},{634,610},{634,760},{366,760}}) - FIG:grow(2)
work(rec, {hand="detail", pile=DK, coverage=3.5, fill=true, clip=rec})
local low = poly({{366,760},{634,760},{634,790},{366,790}}) - FIG:grow(2)
work(low, {hand="detail", pile=SHW, coverage=3.5, fill=true, clip=low})
local below = poly({{366,790},{634,790},{634,900},{366,900}}) - FIG:grow(2)
work(below, {hand="detail", pile=DK, coverage=3.5, fill=true, clip=below})
local top = poly({{360,500},{640,500},{640,520},{360,520}}) - FIG:grow(2)
work(top, {hand="detail", pile=SHW, coverage=3.5, fill=true, clip=top})
-- the curtain behind the upper instruments
local cb = poly({{360,300},{640,300},{640,500},{360,500}}) - FIG:grow(2)
work(cb, {hand="detail", pile=CG1, coverage=3.5, fill=true, clip=cb})

--@ chunk 11
wait(3 * 24 * 60)
CB = pile{{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.2}}
CO = pile{{"yellow ochre",1.5},{"raw sienna",0.6},{"lead white",0.4}}
GOLD = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",0.4},{"chrome yellow",0.3}}
-- rug: a blue border band and ochre lozenges
local rug = poly({{360,520},{640,520},{644,610},{356,610}}) - FIG:grow(2)
local band = rug * rect(0, 586, 1000, 12); work(band, {hand="detail", pile=CB, coverage=3.5, fill=true, clip=band})
local loz
for i = 0, 13 do local x = 368 + i * 20; local y = 552 + 6 * math.sin(i * 1.3)
  local m = poly({{x - 7, y}, {x, y - 10}, {x + 7, y}, {x, y + 10}}); loz = loz and (loz + m) or m end
loz = loz * rug; work(loz, {hand="detail", pile=CO, coverage=3.5, fill=true, clip=loz})
-- the orrery's stand and the Sun
local stand = rect(427, 466, 6, 54) + poly({{414,516},{446,516},{450,522},{410,522}})
work(stand, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=stand})
SUN = ellipse(430, 444, 22, 22); work(SUN, {hand="detail", pile=GOLD, coverage=3.5, fill=true, clip=SUN})
-- the astrolabe: a bronze disc on edge, slightly turned
ASTRO = ellipse(526, 448, 30, 36); work(ASTRO, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=ASTRO})
local inner = ellipse(526, 448, 24, 29); work(inner, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=inner})
local ring = rect(522, 404, 8, 10); work(ring, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=ring})
-- the sealed reliquary case
CASE = poly({{572,456},{628,452},{630,520},{574,522}})
work(CASE * rect(0,0,600,2000), {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=CASE})
work(CASE * rect(600,0,100,2000), {hand="detail", pile=Q2, coverage=3.5, fill=true, clip=CASE})
local lid = poly({{568,446},{632,442},{634,456},{570,460}}); work(lid, {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=lid})

--@ chunk 12
wait(3 * 24 * 60)
local GD = pile{{"Mars yellow",1},{"raw sienna",1},{"burnt sienna",0.4}}
local GL = pile{{"lead white",2.5},{"chrome yellow",0.6},{"yellow ochre",0.4}}
-- the Sun modelled: shade lower right, a blaze upper left
local s = SUN - ellipse(424, 438, 20, 20); work(s, {hand="detail", pile=GD, coverage=3.5, fill=true, clip=s})
local hb = ellipse(422, 436, 7, 6); work(hb, {hand="detail", pile=GL, coverage=3.5, fill=true, clip=hb})
-- orbits: two tilted rings of bronze wire, the TESTAMENT a tiny ring-and-spine on the outer one
local o = brush{kind="round", width=1.5, point=0.6}
local function orbit(rx, ry, tilt, p)
  local pts = {} for i = 0, 40 do local a = 2 * math.pi * i / 40; local x, y = rx * math.cos(a), ry * math.sin(a)
    pts[#pts+1] = {430 + x * math.cos(tilt) - y * math.sin(tilt), 444 + x * math.sin(tilt) + y * math.cos(tilt)} end
  for i = 1, 40, 5 do local seg = {} for k = i, math.min(41, i + 5) do seg[#seg+1] = pts[k] end
    local mid = seg[math.ceil(#seg / 2)]
    local behind = (mid[2] < 444) and SUN:at(mid[1], mid[2]) > 0.5
    if not behind then o:reload(p, 0.8); o:stroke(seg, {pressure={0.45, 0.45}, ramps={0.05, 0.05}}) end end
  return pts
end
orbit(38, 10, -0.15, Q5)
local pts = orbit(62, 16, -0.15, Q4)
local T = pts[9]
local tr = ellipse(T[1], T[2], 5, 2.2) - ellipse(T[1], T[2], 2.6, 1.0)
work(tr, {hand="detail", pile=GL, coverage=3.5, fill=true, clip=tr})
o:reload(B3, 0.8); o:stroke({{T[1], T[2] - 6}, {T[1], T[2] + 6}}, {pressure={0.4, 0.4}})
-- astrolabe: scale ticks round the rim and a rete star
for k = 0, 23 do local a = 2 * math.pi * k / 24; o:reload(Q1, 0.7); o:stroke({{526 + 25 * math.cos(a), 448 + 30 * math.sin(a)}, {526 + 29 * math.cos(a), 448 + 34 * math.sin(a)}}, {pressure={0.4, 0.4}}) end
for k = 0, 4 do local a = k * math.rad(137.5); o:reload(Q5, 0.8); o:stroke({{526, 448}, {526 + 20 * math.cos(a), 448 + 24 * math.sin(a)}}, {pressure={0.5, 0.1}}) end
o:reload(GL, 0.8); o:stroke({{500,430},{506,416},{516,410}}, {pressure={0.2, 0.6, 0.1}})
-- the case: restated, a bone panel and a red seal
CASE2 = poly({{572,460},{628,456},{630,520},{574,522}})
work(CASE2 * rect(0,0,600,2000), {hand="detail", pile=Q4, coverage=4, fill=true, clip=CASE2})
work(CASE2 * rect(600,0,100,2000), {hand="detail", pile=Q2, coverage=4, fill=true, clip=CASE2})

--@ chunk 13
wait(2 * 24 * 60)
local pan = poly({{580,470},{606,468},{606,510},{580,512}}); work(pan, {hand="detail", pile=B3, coverage=4, fill=true, clip=pan})
local seal = ellipse(616, 486, 6, 6); work(seal, {hand="detail", pile=pile{{"vermilion",1},{"red earth",0.6}}, coverage=4, fill=true, clip=seal})
local o = brush{kind="round", width=1.2, point=0.7}
o:reload(Q1, 0.8); o:stroke({{580,470},{606,468},{606,510}}, {pressure={0.4, 0.4}})
o:reload(HL, 0.8); o:stroke({{570,446},{630,442}}, {pressure={0.5, 0.2}})
for k = 0, 3 do local y = 476 + k * 9; o:reload(Q1, 0.6); o:stroke({{585, y}, {600, y - 1}}, {pressure={0.3, 0.3}}) end
-- lower tier: the bone instrument lying on its back, its neck to the left, one string broken and curling
LUTE = ellipse(476, 736, 50, 22)
work(LUTE * rect(0,0,2000,736), {hand="detail", pile=B3, coverage=4, fill=true, clip=LUTE})
work(LUTE * rect(0,736,2000,100), {hand="detail", pile=B1, coverage=4, fill=true, clip=LUTE})
local neck = poly({{380,722},{430,728},{430,742},{380,738}}); work(neck, {hand="detail", pile=Q3, coverage=4, fill=true, clip=neck})
local rose = ellipse(486, 732, 9, 6); work(rose, {hand="detail", pile=Q1, coverage=4, fill=true, clip=rose})
-- the fold-notation tablet leaning against the back, and a closed book
TABL = poly({{556,662},{612,656},{618,756},{562,760}}); work(TABL, {hand="detail", pile=B2, coverage=4, fill=true, clip=TABL})
BOOK = poly({{540,740},{628,736},{630,758},{542,760}}); work(BOOK, {hand="detail", pile=pile{{"red earth",1},{"bone brown",0.6}}, coverage=4, fill=true, clip=BOOK})

--@ chunk 14
wait(2 * 24 * 60)
local o = brush{kind="round", width=0.9, point=0.8}
for k = 0, 4 do local y = 728 + k * 4; o:reload(Q1, 0.7); o:stroke({{384, y - 4}, {440, y - 1}, {500, y}}, {pressure={0.35, 0.35}, ramps={0.02, 0.02}}) end
-- the broken string, curling up off the body
o:reload(Q1, 0.8); o:stroke({{500,742},{470,742},{456,736},{452,726},{460,720}}, {pressure={0.4, 0.4, 0.3, 0.1}})
-- glyphs on the tablet: a heart with petals, small
local g = brush{kind="round", width=1.0, point=0.8}
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * math.sin(a)} end return t end
g:reload(Q1, 0.7); g:stroke(hex(586, 700, 7, 0.1), {pressure={0.35, 0.35}, ramps={0.05, 0.05}})
for k = 0, 5 do local a = k * math.pi / 3 + 0.2; g:reload(Q1, 0.7); g:stroke(hex(586 + 17 * math.cos(a), 700 + 20 * math.sin(a), 4, k * 0.3), {pressure={0.3, 0.3}, ramps={0.05, 0.05}}) end
-- book page edges
o:reload(B3, 0.7); o:stroke({{544,742},{626,738}}, {pressure={0.4, 0.4}})
-- floor: large inlaid roundels and bands in perspective, darker and lighter stone
FLD = pile{{"bone brown",1.6},{"bone black",0.5},{"burnt sienna",0.3}}
FLL = pile{{"lead white",1.6},{"raw sienna",0.8},{"bone brown",0.3}}
local fl = FLOOR - FIG:grow(2)
for _, c in ipairs{{220,1000,150,26}, {500,960,110,16}, {780,1010,150,26}, {500,1150,240,46}} do
  local ring = (ellipse(c[1], c[2], c[3], c[4]) - ellipse(c[1], c[2], c[3] * 0.84, c[4] * 0.84)) * fl
  work(ring, {hand="detail", pile=FLD, coverage=3.5, fill=true, clip=ring})
  local ring2 = (ellipse(c[1], c[2], c[3] * 0.62, c[4] * 0.62) - ellipse(c[1], c[2], c[3] * 0.5, c[4] * 0.5)) * fl
  work(ring2, {hand="detail", pile=FLL, coverage=3.5, fill=true, clip=ring2})
end
local band = (rect(0, 915, 1000, 10) + rect(0, 1065, 1000, 14)) * fl
work(band, {hand="detail", pile=FLD, coverage=3.5, fill=true, clip=band})

--@ chunk 15
wait(2 * 24 * 60)
AX = {470, 1150}; ANG = -0.30; LU = 330; LV = 40
local ca, sa = math.cos(ANG), math.sin(ANG)
function AP(u, v) return {AX[1] + u * LU * ca - v * LV * sa, AX[2] + u * LU * sa + v * LV * ca} end
-- the fold: each hexagon holds a smaller copy, turned and slid toward one side, five deep
LEVELS = {}
local cu, cv, r, rot = 0, 0, 1, 0.1
for k = 1, 6 do
  LEVELS[k] = {cu, cv, r, rot}
  cu = cu + r * 0.22 * math.cos(rot + 1.0); cv = cv + r * 0.22 * math.sin(rot + 1.0)
  r = r * 0.618; rot = rot + 0.42
end
function HEXP(L, scale) local t = {} for i = 0, 5 do local a = L[4] + i * math.pi / 3; t[#t+1] = AP(L[1] + L[3] * scale * math.cos(a), L[2] + L[3] * scale * math.sin(a)) end return poly(t) end
ANAM = HEXP(LEVELS[1], 1)
ACG = pile{{"zinc white",1},{"ultramarine ash",1},{"bone black",0.5},{"cobalt violet",0.3}}
ACL = pile{{"zinc white",2.2},{"ultramarine ash",0.5},{"cerulean blue",0.2},{"cobalt violet",0.15}}
ACD = pile{{"bone black",1},{"cobalt violet",0.6},{"ultramarine blue",0.5},{"zinc white",0.2}}
work(ANAM, {hand="detail", pile=ACG, coverage=3.5, fill=true, clip=ANAM})
for k = 1, 6 do
  local ring = HEXP(LEVELS[k], 1) - HEXP(LEVELS[k], 0.8)
  work(ring, {hand="detail", pile=ACL, coverage=3.5, fill=true, clip=ring})
  if k < 6 then local gap = HEXP(LEVELS[k], 0.8) - HEXP(LEVELS[k + 1], 1.08); work(gap * rect(0, 0, 2000, 2000), {hand="detail", pile=(k % 2 == 1) and ACD or ACG, coverage=3.5, fill=true, clip=gap}) end
end
-- the smear: a clean brush dragged along the axis while it is wet
local b = brush{kind="filbert", width=6, pickup=1}
for i = -8, 8 do
  local v = i / 8 * 0.95
  b:wipe(1)
  local p0, p1 = AP(-1.15, v), AP(1.15, v + 0.08)
  b:stroke({p0, p1}, {pressure={0.4, 0.5}, ramps={0.05, 0.1}})
end

--@ chunk 16
wait(4 * 24 * 60)
work(ANAM, {hand="detail", pile=ACG, coverage=4, fill=true, clip=ANAM})

--@ chunk 17
wait(4 * 24 * 60)
for k = 1, 6 do
  local ring = HEXP(LEVELS[k], 1) - HEXP(LEVELS[k], 0.8)
  work(ring, {hand="detail", pile=ACL, coverage=4, fill=true, clip=ring})
  if k < 6 then local gap = HEXP(LEVELS[k], 0.8) - HEXP(LEVELS[k + 1], 1.0); work(gap, {hand="detail", pile=(k % 2 == 1) and ACD or ACG, coverage=4, fill=true, clip=gap}) end
end
local core = HEXP(LEVELS[6], 0.8); work(core, {hand="detail", pile=ACD, coverage=4, fill=true, clip=core})

--@ chunk 18
wait(1 * 24 * 60)
CRL = pile{{"vermilion",0.8},{"red earth",1},{"rose madder",0.4},{"lead white",0.25}}
CRD = pile{{"red earth",0.8},{"rose madder",0.6},{"bone black",0.5}}
VBL = pile{{"bone black",0.8},{"bone brown",0.6},{"cobalt violet",0.5},{"lead white",0.3}}
VBD = pile{{"bone black",1.4},{"bone brown",0.5},{"cobalt violet",0.2}}
local keep = ANAM:grow(2)
local function F(pts, p, clip) local m = (poly(pts, true) * clip) - keep; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
local L = LROBE - LHEAD
-- left envoy: puffed sleeves, lit on the window side; the gown's front falling in long folds
F({{96,440},{150,400},{190,430},{180,560},{120,600},{90,540}}, CRL, L)
F({{120,600},{180,560},{196,640},{150,700},{110,660}}, CRD, L)
F({{280,420},{340,470},{356,600},{330,640},{290,600}}, CR, L)
F({{180,640},{210,640},{230,1180},{190,1180}}, CRL, L)
F({{260,650},{290,650},{320,1180},{286,1180}}, CRD, L)
local R = RROBE - RHEAD
F({{660,470},{720,410},{760,440},{740,600},{680,640}}, VBL, R)
F({{830,420},{880,450},{910,620},{870,660},{840,560}}, VBD, R)
F({{700,660},{730,660},{722,1180},{690,1180}}, VBL, R)
F({{790,660},{820,660},{850,1180},{816,1180}}, VBD, R)

--@ chunk 19
wait(3 * 24 * 60)
FUR = pile{{"bone brown",1.2},{"burnt sienna",0.5},{"raw sienna",0.5},{"lead white",0.25}}
FURL = pile{{"raw sienna",1},{"lead white",0.6},{"bone brown",0.4}}
-- the left envoy's fur stole: wide over the shoulders and down both edges of the gown's opening
local stole = (poly({{130,420},{200,372},{290,390},{330,440},{280,470},{250,460},{240,1180},{200,1180},{196,470},{160,460}}, true) * LROBE) - ANAM:grow(2)
stipple(stole, {pile=FUR, width=3.2, coverage=2.2, cluster=0.4, drag={4, math.pi / 2}})
stipple(stole * rect(0, 0, 230, 2000), {pile=FURL, width=2.6, coverage=0.8, cluster=0.5, drag={4, math.pi / 2}})
-- the right envoy's bone collar, a broad flat band, and a row of bronze studs down the front
local col = (ellipse(806, 384, 76, 20) - RHEAD) * RROBE:grow(4)
work(col * rect(0,0,800,2000), {hand="detail", pile=B3, coverage=4, fill=true, clip=col})
work(col * rect(800,0,200,2000), {hand="detail", pile=B1, coverage=4, fill=true, clip=col})
local t = brush{kind="round", width=3.6, point=0.2}
local y, gap = 430, 26
for k = 1, 10 do if ANAM:at(772, y) < 0.5 then t:reload(Q4, 0.85); t:touch(772 + k * 0.5, y, {pressure=0.45}) end; y = y + gap; gap = gap * 1.07 end

--@ chunk 20
wait(2 * 24 * 60)
OBJ = rect(365,412,132,60) + rect(408,460,48,64) + ASTRO:grow(3) + rect(520,400,12,16) + rect(564,436,74,90)
local blk = (rect(360, 296, 280, 206) - FIG:grow(2)) - OBJ
local x = 0; local i = 0
while x < 1000 do
  local w = 46 + 18 * math.sin(i * 1.7)
  local band = blk * poly({{x, 0}, {x + w, 0}, {x + w + 6, 900}, {x + 6, 900}})
  local P = (i % 3 == 0) and CGM or ((i % 3 == 1) and CG1 or CGD)
  if band:area() > 4 then work(band, {hand="detail", pile=P, coverage=4, fill=true, clip=band}) end
  x = x + w; i = i + 1
end

--@ chunk 21
wait(3 * 24 * 60)
local blk = (rect(360, 296, 280, 206) - FIG:grow(2)) - OBJ
local DM = pile{{"viridian",1},{"raw sienna",0.8},{"lead white",0.45},{"yellow ochre",0.25}}
local outer, inner
for row = 0, 6 do for col = 0, 7 do
  local cx = 20 + col * 136 + (row % 2) * 68 + 5 * math.sin(row * 2.1 + col)
  local cy = 60 + row * 128
  local o = poly({{cx, cy - 26}, {cx + 16, cy}, {cx, cy + 26}, {cx - 16, cy}}) - poly({{cx, cy - 20}, {cx + 11, cy}, {cx, cy + 20}, {cx - 11, cy}})
  local a = 0.5 + 0.1 * col
  local n = {} for k = 0, 3 do local b = a + k * math.pi / 2; n[#n+1] = {cx + 8 * math.cos(b), cy + 10 * math.sin(b)} end
  outer = outer and (outer + o) or o; inner = inner and (inner + poly(n)) or poly(n)
end end
local all = (outer + inner) * blk
if all:area() > 2 then work(all, {hand="detail", pile=DM, coverage=3.5, fill=true, clip=all}) end
-- hands resting on the shelf: jointed bronze fingers on the cloth
local function seg(a, b, w0, w1) local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}}) end
local d = brush{kind="round", width=1.0, point=0.8}
local function hand(back, fingers, lit)
  local hb = poly(back); work(hb, {hand="detail", pile=lit and Q4 or Q3, coverage=4, fill=true, clip=hb})
  for _, J in ipairs(fingers) do for k = 1, #J - 1 do local m = seg(J[k], J[k+1], 3.2 - k * 0.3, 2.9 - k * 0.3); work(m, {hand="detail", pile=(k % 2 == 1) and (lit and Q5 or Q4) or Q3, coverage=4, fill=true, clip=m}) end
    for k = 2, #J - 1 do d:reload(Q1, 0.8); d:touch(J[k][1], J[k][2], {pressure=0.35}) end end
end
local sl = poly({{300,500},{356,488},{372,520},{320,540}}, true); work(sl, {hand="detail", pile=CR, coverage=4, fill=true, clip=sl})
hand({{354,500},{376,496},{380,522},{358,526}}, {{{376,500},{390,502},{402,508},{410,516}}, {{378,508},{394,512},{404,520},{410,530}}, {{378,516},{392,522},{400,530},{404,540}}}, true)
local sr = poly({{644,488},{700,500},{690,540},{640,524}}, true); work(sr, {hand="detail", pile=VB, coverage=4, fill=true, clip=sr})
hand({{620,496},{644,500},{642,526},{620,524}}, {{{622,500},{608,504},{598,510},{590,518}}, {{620,508},{606,514},{596,522},{590,530}}, {{620,516},{608,524},{600,532},{596,542}}}, false)

--@ chunk 22
wait(2 * 24 * 60)
-- the anamorph casts a thin shadow on the floor, to the lower right: it is an object, not a stain
local ca, sa = math.cos(ANG), math.sin(ANG)
local pts = {} for i = 0, 5 do local a = LEVELS[1][4] + i * math.pi / 3; local p = AP(math.cos(a), math.sin(a)); pts[#pts+1] = {p[1] + 8, p[2] + 7} end
local sh = (poly(pts) - ANAM) - FIG:grow(1)
work(sh, {hand="detail", pile=pile{{"bone brown",1.4},{"bone black",0.7},{"cobalt violet",0.15}}, coverage=4, fill=true, clip=sh})
-- the cold light the thing gives off on the floor beside it, faint
local hal = (ANAM:grow(10) - ANAM:grow(2) - sh) - FIG:grow(1)
work(hal * rect(0, 900, 1000, 400), {hand="scumble", pile=pile{{"ultramarine ash",1},{"bone brown",0.8},{"lead white",0.5}}, coverage=0.6, clip=hal, pressure={0.15, 0.35}})
-- the right envoy's sleeve, smoother
local sr = poly({{644,486},{700,494},{712,520},{690,544},{640,526}}, true)
work(sr, {hand="detail", pile=VBL, coverage=4, fill=true, clip=sr})

--@ chunk 23
wait(3 * 24 * 60)
local keep = ANAM:grow(3)
local L = LROBE - LHEAD - keep
local stole = poly({{130,420},{200,372},{290,390},{330,440},{280,470},{250,460},{240,1180},{200,1180},{196,470},{160,460}}, true)
local function F(pts, p, clip) local m = (poly(pts, true) * clip); if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
-- left: the sleeve as one lit puff with a shadowed underside, replacing the oval
F({{80,460},{130,420},{196,440},{196,600},{150,640},{96,600}}, CR, L - stole)
F({{90,460},{130,430},{170,450},{150,540},{100,560}}, CRL, L - stole)
F({{100,580},{150,600},{196,600},{196,640},{150,660},{110,630}}, CRD, L - stole)
-- right: the sleeve as a broad dull puff
local R = RROBE - RHEAD - keep
F({{650,440},{720,404},{760,430},{756,600},{700,640},{652,600}}, VB, R)
F({{660,450},{720,416},{748,440},{720,520},{670,540}}, VBL, R)

--@ chunk 24
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.4, point=0.6}
local h = brush{kind="round", width=1.4, point=0.7}
local function seams(F, clip) for _, f in ipairs(F) do local p = f[1]; for i = 1, #p do d:reload(Q1, 0.7); d:stroke({p[i], p[i % #p + 1]}, {pressure={0.35, 0.35}, ramps={0.05, 0.05}, clip=clip}) end end end
seams(LHF, LHEAD - ellipse(208, 272, 46, 14) - ellipse(235, 322, 16, 12))
seams(RHF, RHEAD - ellipse(800, 274, 48, 14) - ellipse(771, 328, 16, 12))
h:reload(B4, 0.8); h:stroke({{196,158},{164,190},{146,240},{144,290}}, {pressure={0.1, 0.6, 0.4, 0.05}, ramps={0.2, 0.3}, clip=LHEAD:grow(1)})
h:reload(B4, 0.8); h:stroke({{798,160},{770,176},{748,214},{742,260}}, {pressure={0.1, 0.55, 0.3, 0.05}, ramps={0.2, 0.3}, clip=RHEAD:grow(1)})
-- the far end of the anamorph, smeared on purpose: long cold streaks running on along the axis, fading
local b = brush{kind="filbert", width=4}
for i = -6, 6 do local v = i / 6 * 0.8
  b:reload(i % 2 == 0 and ACG or ACL, 0.35)
  b:stroke({AP(0.95, v), AP(1.35, v + 0.05), AP(1.55, v + 0.12)}, {pressure={0.5, 0.25, 0.0}, ramps={0.05, 0.8}, clip=-(RROBE:shrink(2) - ANAM)})
end

--@ chunk 25
wait(2 * 24 * 60)
local fl = FLOOR - FIG:grow(2) - ANAM:grow(10)
for _, c in ipairs{{220,1000,150,26}, {500,960,110,16}, {780,1010,150,26}, {500,1150,240,46}} do fl = fl - ellipse(c[1], c[2], c[3] + 4, c[4] + 3) end
fl = fl - rect(0, 912, 1000, 16) - rect(0, 1062, 1000, 20)
local loz
local y = 935
local row = 0
while y < 1250 do
  local h = 8 + (y - 900) * 0.07
  local w = h * 2.2
  local x = (row % 2) * w
  while x < 1000 do
    local m = poly({{x, y - h * 0.5}, {x + w * 0.5, y}, {x, y + h * 0.5}, {x - w * 0.5, y}})
    loz = loz and (loz + m) or m
    x = x + w
  end
  y = y + h * 0.5; row = row + 1
end
local m = loz * fl
work(m, {hand="detail", pile=FLL, coverage=3.5, fill=true, clip=m})

--@ chunk 26
wait(3 * 24 * 60)
SHD = (poly({{340,1180},{380,960},{460,940},{600,1250},{400,1250}}) + poly({{930,1170},{940,960},{1000,940},{1000,1250},{960,1250}}) + rect(0, 905, 1000, 40)) * FLOOR - FIG:grow(1) - ANAM:grow(1)
work(SHD, {hand="detail", pile=FLD, coverage=4, fill=true, clip=SHD})

--@ chunk 27
wait(3 * 24 * 60)
FLM = pile{{"bone brown",1.4},{"raw sienna",0.6},{"lead white",0.35},{"bone black",0.2}}
local loz
local y = 935; local row = 0
while y < 1250 do local h = 8 + (y - 900) * 0.07; local w = h * 2.2; local x = (row % 2) * w
  while x < 1000 do local m = poly({{x, y - h * 0.5}, {x + w * 0.5, y}, {x, y + h * 0.5}, {x - w * 0.5, y}}); loz = loz and (loz + m) or m; x = x + w end
  y = y + h * 0.5; row = row + 1 end
local m = loz * SHD * rect(0, 945, 1000, 400)
work(m, {hand="detail", pile=FLM, coverage=3.5, fill=true, clip=m})

--@ chunk 28
wait(1 * 24 * 60)
local gap = poly({{0,0},{34,0},{30,90},{0,104}}) - FIG
work(gap, {hand="detail", pile=pile{{"bone black",1.2},{"bone brown",0.6}}, coverage=4, fill=true, clip=gap})
local g = brush{kind="round", width=2.0, point=0.6}
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * math.sin(a)} end return t end
g:reload(Q4, 0.85); g:stroke(hex(14, 44, 11, 0.1), {pressure={0.55, 0.55}, ramps={0.05, 0.05}, clip=gap})
g:reload(Q5, 0.85); g:stroke(hex(15, 45, 6.8, 0.52), {pressure={0.5, 0.5}, ramps={0.05, 0.05}, clip=gap})
local t = brush{kind="round", width=2.0, point=0.2}; t:reload(HL, 0.8); t:touch(15.5, 45.5, {pressure=0.35})
-- the edge of the curtain beside it, folded back and lit
local f = brush{kind="filbert", width=5}
f:reload(CGL, 0.85); f:stroke({{36,0},{34,50},{30,96}}, {pressure={0.6, 0.6, 0.4}, ramps={0.1, 0.3}})
-- the right envoy's hem: a narrow gold band with a dark border
local hem = (RROBE - RROBE:shrink(7)) * rect(0, 1150, 1000, 60) - ANAM:grow(2)
work(hem, {hand="detail", pile=pile{{"Mars yellow",1},{"yellow ochre",1},{"raw sienna",0.6}}, coverage=4, fill=true, clip=hem})

--@ chunk 29
wait(1 * 24 * 60)
local t = brush{kind="round", width=3.2, point=0.2}
-- chain: links on a curve from shoulder to shoulder, down to the medallion
local pts = {} for i = 0, 18 do local s = i / 18; local x = lerp(160, 290, s); local y = 410 + 120 * math.sin(math.pi * s); pts[#pts+1] = {x, y} end
for i, p in ipairs(pts) do if i % 1 == 0 then t:reload((i % 2 == 0) and Q5 or Q4, 0.9); t:touch(p[1], p[2], {pressure=0.45}) end end
local med = ellipse(225, 556, 13, 14); work(med, {hand="detail", pile=Q5, coverage=4, fill=true, clip=med})
local g = brush{kind="round", width=1.2, point=0.7}
local function hex(x, y, r, rot) local p = {} for i = 0, 6 do local a = rot + i * math.pi / 3; p[#p+1] = {x + r * math.cos(a), y + r * math.sin(a)} end return p end
g:reload(Q1, 0.8); g:stroke(hex(225, 556, 8, 0.1), {pressure={0.4, 0.4}, ramps={0.05, 0.05}})
g:reload(Q1, 0.8); g:stroke(hex(226, 557, 4.6, 0.5), {pressure={0.35, 0.35}, ramps={0.05, 0.05}})
t:reload(HL, 0.8); t:touch(220, 550, {pressure=0.3})

--@ chunk 30
wait(2 * 24 * 60)
local h = brush{kind="round", width=2.2, point=0.6}
h:reload(CRL, 0.8); h:stroke({{140,430},{110,520},{94,660},{84,860},{72,1100}}, {pressure={0.1, 0.6, 0.5, 0.3, 0.05}, ramps={0.2, 0.3}, clip=LROBE})
h:reload(VBL, 0.8); h:stroke({{716,396},{676,450},{654,600},{646,800},{636,1060}}, {pressure={0.1, 0.5, 0.4, 0.3, 0.05}, ramps={0.2, 0.3}, clip=RROBE - ANAM:grow(2)})

--@ chunk 31
wait(1 * 24 * 60)
local t = brush{kind="round", width=4.6, point=0.2}
for i = 0, 22 do local s = i / 22; local x = lerp(150, 300, s); local y = 412 + 140 * math.sin(math.pi * s) * (s < 0.5 and 1 or 1)
  if math.abs(x - 225) > 10 or y < 540 then t:reload(Q1, 0.9); t:touch(x + 0.8, y + 1, {pressure=0.5}); t:reload((i % 2 == 0) and Q5 or Q4, 0.9); t:touch(x, y, {pressure=0.42}) end end

--@ chunk 32
wait(1 * 24 * 60)
-- the anamorph's upper edge catches the window, so it lies on the floor as a thing
local h = brush{kind="round", width=1.8, point=0.6}
local L = LEVELS[1]
local pts = {} for i = 0, 6 do local a = L[4] + i * math.pi / 3; pts[#pts+1] = AP(math.cos(a), math.sin(a)) end
table.sort(pts, function(a, b) return a[2] < b[2] end)
local top = {} for i = 0, 6 do local a = L[4] + i * math.pi / 3; top[#top+1] = AP(math.cos(a), math.sin(a)) end
for i = 1, 6 do local a, b = top[i], top[i + 1]; local mid = {(a[1] + b[1]) / 2, (a[2] + b[2]) / 2}
  if mid[2] < AX[2] - 5 then h:reload(pile{{"zinc white",3},{"cerulean blue",0.3}}, 0.85); h:stroke({a, b}, {pressure={0.4, 0.6, 0.3}, ramps={0.1, 0.2}, clip=ANAM:grow(1.5) - FIG:grow(1)}) end end

--@ chunk 33
wait(1 * 24 * 60)
local t = brush{kind="round", width=2.2, point=0.2}
local function g(x, y, p) t:reload(p or HL, 0.85); t:touch(x, y, {pressure=0.3}) end
g(422, 436, pile{{"lead white",3},{"lemon chrome",0.3}}); g(506, 420); g(574, 448); g(458, 728, B4); g(402, 726, Q5); g(612, 482, pile{{"lead white",2},{"vermilion",0.3}})
g(218, 549); g(566, 662, B4)
