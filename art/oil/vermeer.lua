-- easel session "vermeer": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=97,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"lead white",2},{"raw sienna",0.8},{"bone brown",0.4},{"ultramarine ash",0.3}}, um=35, apply="roller"}}}

--@ chunk 2
WIN = poly({{30,90},{250,170},{250,770},{30,860}})
TABLE = poly({{0,830},{520,860},{600,1250},{0,1250}}, true)
CURT = poly({{850,0},{1000,0},{1000,1250},{870,1250},{880,900},{860,500}})
HEAD = poly({{500,330},{520,280},{570,262},{622,276},{650,320},{652,390},{632,450},{596,486},{550,490},{510,470},{492,420}}, true)
RUFF = ellipse(578, 508, 120, 30)
ROBE = poly({{470,520},{530,500},{640,500},{700,560},{720,700},{740,900},{770,1250},{520,1250},{560,1000},{470,800},{440,640}}, true)
TAB = poly({{410,540},{470,520},{486,640},{426,664}})
FIG = HEAD + RUFF + ROBE + TAB
WL1 = pile{{"lead white",3},{"raw sienna",0.6},{"ultramarine ash",0.25},{"yellow ochre",0.2}}
WL2 = pile{{"lead white",2.4},{"raw sienna",0.7},{"ultramarine ash",0.35},{"bone brown",0.1}}
WL3 = pile{{"lead white",2},{"raw sienna",0.7},{"ultramarine ash",0.45},{"bone brown",0.25}}
local wall = everywhere() - FIG:grow(3) - WIN - TABLE - CURT
local function ringm(r0, r1) return wall * (ellipse(140, 300, r1, r1) - ellipse(140, 300, r0, r0)) end
work(ringm(0, 420), {hand="body", pile=WL1, coverage=3, fill=true, clip=wall, angle=math.pi/2})
work(ringm(420, 720), {hand="body", pile=WL2, coverage=3, fill=true, clip=wall, angle=math.pi/2})
work(ringm(720, 2000), {hand="body", pile=WL3, coverage=3, fill=true, clip=wall, angle=math.pi/2})
blend(ringm(395, 445), {angle=-0.6})
blend(ringm(695, 745), {angle=-0.6})

--@ chunk 3
WN = pile{{"lead white",3},{"zinc white",1},{"ultramarine ash",0.15},{"yellow ochre",0.1}}
BL = pile{{"ultramarine blue",1},{"lead white",1},{"bone black",0.15}}
BLD = pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.35}}
CG = pile{{"viridian",1},{"bone black",0.5},{"raw sienna",0.4}}
TR = pile{{"red earth",1},{"rose madder",0.4},{"bone brown",0.5}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
local function W(m, p, a) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=m, angle=a, tool="filbert 10"}) end
W(WIN, WN, math.pi/2)
W(CURT - FIG, CG, math.pi/2)
W(TABLE - FIG, TR, 0)
W(ROBE - RUFF - HEAD - TAB, BL, math.pi/2)
W(RUFF - HEAD, BD, 0)
W(HEAD, Q2, math.pi/2)
W(TAB, BD, 0)

--@ chunk 4
wait(4 * 24 * 60)
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
B1 = pile{{"raw sienna",1},{"bone brown",0.7},{"lead white",1},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
HF = {
  {{{520,280},{570,262},{580,300},{540,330},{506,330}}, Q5},
  {{{570,262},{622,276},{650,320},{610,330},{580,300}}, Q4},
  {{{540,330},{580,300},{610,330},{600,380},{560,380}}, Q4},
  {{{610,330},{650,320},{652,390},{620,410},{600,380}}, Q3},
  {{{560,380},{600,380},{620,410},{600,460},{560,440}}, Q3},
  {{{620,410},{652,390},{632,450},{596,486},{600,460}}, Q2},
  {{{550,440},{560,440},{600,460},{596,486},{550,490},{530,476}}, Q1},
}
for _, f in ipairs(HF) do local m = poly(f[1]) * HEAD:grow(1); work(m, {hand="detail", pile=f[2], coverage=3.5, fill=true, clip=m}) end
-- the bone face-plate in profile: a narrow oval on the window side, in flat facets
FACE = ellipse(528, 404, 30, 78)
local FN = {T={530,326}, A={502,370}, C={534,372}, E={530,430}, L={500,430}, G={510,470}, B={532,482}, R={556,420}}
local function F(n, p) local pts = {} for _, k in ipairs(n) do pts[#pts+1] = FN[k] end; local m = poly(pts) * FACE; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F({"T","A","C"}, B4); F({"A","L","E","C"}, B3); F({"T","C","R"}, B2); F({"C","E","R"}, B2); F({"L","G","E"}, B3); F({"E","G","B","R"}, B1)
local rest = FACE - poly({FN.T, FN.R, FN.B, FN.G, FN.L, FN.A})
work(rest * rect(0,0,528,2000), {hand="detail", pile=B3, coverage=3.5, fill=true, clip=rest})
work(rest * rect(528,0,200,2000), {hand="detail", pile=B1, coverage=3.5, fill=true, clip=rest})

--@ chunk 5
wait(2 * 24 * 60)
LENS = pile{{"bone black",1},{"viridian",0.3},{"ultramarine blue",0.4}}
-- the lens barrel, protruding toward the window, its end face toward the tablet
local barrel = poly({{494,384},{516,380},{518,414},{496,418}})
work(barrel * rect(0,0,2000,398), {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=barrel})
work(barrel * rect(0,398,2000,100), {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=barrel})
local glass = ellipse(493, 400, 5, 17)
work(glass, {hand="detail", pile=LENS, coverage=3.5, fill=true, clip=glass})
-- a lid plate over it, lowered for reading
local lid = poly({{490,374},{522,368},{526,388},{492,390}})
work(lid, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=lid})

--@ chunk 6
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.6, point=0.6}
local h = brush{kind="round", width=1.4, point=0.7}
for _, f in ipairs(HF) do local p = f[1]; for i = 1, #p do d:reload(Q1, 0.75); d:stroke({p[i], p[i % #p + 1]}, {pressure={0.35, 0.35}, ramps={0.05, 0.05}, clip=HEAD - FACE:grow(2)}) end end
-- the window's cool light on the crown and down the face-plate's front edge
local CL = pile{{"lead white",3},{"zinc white",1},{"ultramarine ash",0.2}}
h:reload(CL, 0.8); h:stroke({{510,318},{530,284},{566,266},{600,268}}, {pressure={0.1, 0.7, 0.5, 0.05}, ramps={0.2, 0.3}, clip=HEAD:grow(1)})
h:reload(CL, 0.7); h:stroke({{500,356},{498,420},{504,466}}, {pressure={0.1, 0.5, 0.05}, ramps={0.2, 0.3}, clip=FACE:grow(1)})
-- glints: the barrel's lit edge, a window reflection in the glass
local t = brush{kind="round", width=1.8, point=0.2}
t:reload(CL, 0.8); t:touch(491, 394, {pressure=0.3})
h:reload(HL, 0.8); h:stroke({{496,383},{514,380}}, {pressure={0.5, 0.2}})

--@ chunk 7
wait(1 * 24 * 60)
BLL = pile{{"ultramarine blue",0.8},{"lead white",1.6},{"bone brown",0.25},{"zinc white",0.3}}
BLM = pile{{"ultramarine blue",1},{"lead white",1},{"bone brown",0.35}}
BLS = pile{{"ultramarine blue",1},{"bone black",0.45},{"bone brown",0.3},{"lead white",0.3}}
local robe = ROBE - RUFF - HEAD - TAB:grow(2)
local function F(pts, p) local m = poly(pts) * robe; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
F({{440,520},{560,500},{560,640},{520,800},{470,800},{440,640}}, BLL)
F({{560,500},{640,500},{700,560},{690,700},{600,720},{560,640}}, BLM)
F({{690,560},{740,560},{740,900},{700,880},{690,700}}, BLS)
F({{470,800},{520,800},{560,1000},{520,1250},{480,1250}}, BLM)
F({{520,800},{600,720},{690,700},{700,880},{650,1000},{560,1000}}, BLM)
F({{560,1000},{650,1000},{680,1250},{520,1250}}, BLS)
F({{650,1000},{700,880},{740,900},{770,1250},{680,1250}}, BLS)
-- the wall gap round the figure
local gap = (FIG:grow(6) - FIG) - WIN - TABLE - CURT
work(gap * ellipse(140, 300, 420, 420), {hand="detail", pile=WL1, coverage=3.5, fill=true, clip=gap})
work(gap - ellipse(140, 300, 420, 420), {hand="detail", pile=WL2, coverage=3.5, fill=true, clip=gap})

--@ chunk 8
wait(2 * 24 * 60)
local up = ribbon({{570,540},{582,610},{576,668}}, {44, 40, 36})
local fore = ribbon({{576,668},{530,660},{486,628}}, {34, 30, 26})
ARM = up + fore
work(up * rect(0,0,578,2000), {hand="detail", pile=BLL, coverage=3.5, fill=true, clip=up})
work(up * rect(578,0,200,2000), {hand="detail", pile=BLM, coverage=3.5, fill=true, clip=up})
work(fore * rect(0,0,2000,650), {hand="detail", pile=BLL, coverage=3.5, fill=true, clip=fore})
work(fore * rect(0,650,2000,100), {hand="detail", pile=BLM, coverage=3.5, fill=true, clip=fore})
-- the tablet: its face turned up toward the lens, its edge toward us
TABF = poly({{404,536},{468,512},{486,622},{424,648}})
local edge = poly({{424,648},{486,622},{488,632},{428,660}})
work(TABF, {hand="detail", pile=B3, coverage=3.5, fill=true, clip=TABF})
work(edge, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=edge})

--@ chunk 9
wait(2 * 24 * 60)
-- the hand on the tablet's edge: a bronze back-plate and jointed fingers curling round the slab
local function seg(a, b, w0, w1) local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}}) end
local hb = poly({{482,610},{504,604},{510,632},{488,640}}); work(hb, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=hb})
local d = brush{kind="round", width=1.0, point=0.8}
for i, J in ipairs{{{484,612},{472,606},{462,604},{454,606}}, {{484,620},{470,618},{458,618},{450,622}}, {{486,628},{472,630},{460,632},{452,638}}} do
  for k = 1, 3 do local m = seg(J[k], J[k+1], 3.2 - k * 0.3, 2.9 - k * 0.3); work(m, {hand="detail", pile=(k % 2 == 1) and Q5 or Q4, coverage=3.5, fill=true, clip=m}) end
  for k = 2, 3 do d:reload(Q1, 0.8); d:touch(J[k][1], J[k][2], {pressure=0.35}) end
end
-- fold notation on the tablet face, in perspective, small
local A, B, C, D = {404,536}, {468,512}, {486,622}, {424,648}
local function P(u, v) return {(1-u)*(1-v)*A[1] + u*(1-v)*B[1] + u*v*C[1] + (1-u)*v*D[1], (1-u)*(1-v)*A[2] + u*(1-v)*B[2] + u*v*C[2] + (1-u)*v*D[2]} end
local g = brush{kind="round", width=1.0, point=0.8}
local function hex(cu, cv, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = P(cu + r * math.cos(a), cv + r * 0.6 * math.sin(a)) end return t end
local clip = TABF:shrink(2) - hb:grow(1)
for k = 0, 5 do local a = k * math.pi / 3 + 0.3; g:reload(Q1, 0.7); g:stroke(hex(0.45 + 0.24 * math.cos(a), 0.45 + 0.17 * math.sin(a), 0.08, 0.2 * k), {pressure={0.35, 0.35}, ramps={0.05, 0.05}, clip=clip}) end
g:reload(Q1, 0.7); g:stroke(hex(0.45, 0.45, 0.1, 0), {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=clip})

--@ chunk 10
wait(3 * 24 * 60)
WP1 = pile{{"lead white",3},{"zinc white",0.5},{"raw sienna",0.35},{"ultramarine ash",0.35}}
WP2 = pile{{"lead white",2.4},{"raw sienna",0.45},{"ultramarine ash",0.55},{"bone brown",0.15}}
WP3 = pile{{"lead white",2},{"raw sienna",0.5},{"ultramarine ash",0.6},{"bone brown",0.32}}
FIGX = FIG + ARM + TABF:grow(2) + poly({{424,648},{486,622},{488,632},{428,660}})
local wall = everywhere() - FIGX:grow(1) - WIN - TABLE - CURT
local function ringm(r0, r1) return wall * (ellipse(140, 300, r1, r1) - ellipse(140, 300, r0, r0)) end
work(ringm(0, 420), {hand="body", pile=WP1, coverage=3.5, fill=true, clip=wall, angle=math.pi/2})
work(ringm(420, 720), {hand="body", pile=WP2, coverage=3.5, fill=true, clip=wall, angle=math.pi/2})
work(ringm(720, 2000), {hand="body", pile=WP3, coverage=3.5, fill=true, clip=wall, angle=math.pi/2})
blend(ringm(395, 445), {angle=-0.6})
blend(ringm(695, 745), {angle=-0.6})

--@ chunk 11
wait(1 * 24 * 60)
-- the casement: a dark wooden-bronze frame, the panes cooler and darker toward the bottom (outside greenery)
FR = pile{{"bone brown",1.4},{"bone black",0.4},{"burnt sienna",0.3}}
PANE2 = pile{{"lead white",2},{"ultramarine ash",0.6},{"viridian",0.15},{"raw sienna",0.2}}
local inner = poly({{46,112},{236,180},{236,756},{46,836}})
local frame = WIN - inner
work(frame, {hand="detail", pile=FR, coverage=3.5, fill=true, clip=frame})
local low = inner * poly({{0,560},{300,520},{300,900},{0,900}})
work(low, {hand="detail", pile=PANE2, coverage=3.5, fill=true, clip=low})
blend(inner * poly({{0,530},{300,500},{300,580},{0,610}}), {angle=math.pi/2})

--@ chunk 12
wait(2 * 24 * 60)
local inner = poly({{46,112},{236,180},{236,756},{46,836}})
local s = brush{kind="round", width=1.3, point=0.7}
-- diagonal leading, two directions, following the pane's perspective
for i = -12, 12 do
  local x0 = 46 + i * 26
  s:reload(FR, 0.6); s:stroke({{x0, 100}, {x0 + 420, 900}}, {pressure={0.3, 0.3}, ramps={0.02, 0.02}, clip=inner})
  s:reload(FR, 0.6); s:stroke({{x0 + 240, 100}, {x0 - 180, 900}}, {pressure={0.3, 0.3}, ramps={0.02, 0.02}, clip=inner})
end
-- a crossbar and the mullion
local cb = poly({{46,440},{236,470},{236,482},{46,454}}); work(cb, {hand="detail", pile=FR, coverage=3.5, fill=true, clip=cb})
-- the lens, reflected faintly in the glass: a small dark ring with a bronze glint, and the egg's ghost
local gh = ellipse(196, 380, 22, 30) * inner
work(gh, {hand="glaze", pile=pile{{"raw sienna",1},{"bone brown",0.6},{"lead white",1.5}, medium=0.6}, coverage=0.8, clip=gh, load=0.3})
local r = ellipse(190, 392, 4, 5) * inner; work(r, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine ash",0.6},{"lead white",0.6}}, coverage=3, fill=true, clip=r})

--@ chunk 13
local cx, cy, rx, ry = 578, 508, 120, 30
local ruff = RUFF:grow(1) - HEAD
-- the top surface: pleats radiating, lit toward the window; then the near rim in shadow
local n = 22
for i = 0, n - 1 do
  local a0, a1 = 2 * math.pi * i / n, 2 * math.pi * (i + 1) / n
  local am = (a0 + a1) / 2
  local m = poly({{cx, cy}, {cx + rx * 1.1 * math.cos(a0), cy + ry * 1.1 * math.sin(a0)}, {cx + rx * 1.1 * math.cos(a1), cy + ry * 1.1 * math.sin(a1)}}) * ruff
  local lit = -math.cos(am)
  local P = lit > 0.3 and ((i % 2 == 0) and B4 or B3) or (lit > -0.3 and ((i % 2 == 0) and B3 or B2) or ((i % 2 == 0) and B2 or B1))
  if m:area() > 2 then work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m}) end
end
local rim = RUFF - ellipse(cx, cy - 7, rx, ry)
work(rim * rect(0,0,560,2000), {hand="detail", pile=B1, coverage=3.5, fill=true, clip=rim})
work(rim * rect(560,0,300,2000), {hand="detail", pile=BD, coverage=3.5, fill=true, clip=rim})

--@ chunk 14
wait(2 * 24 * 60)
-- a ring of tiny glyphs incised round the ruff's rim, foreshortened
local g = brush{kind="round", width=1.0, point=0.8}
local clip = (RUFF - ellipse(578, 501, 120, 30)) + (ellipse(578, 508, 118, 29) - ellipse(578, 508, 100, 23))
for k = 0, 13 do
  local a = math.pi * 2 * k / 14 + 0.15
  local x, y = 578 + 108 * math.cos(a), 508 + 26 * math.sin(a)
  if HEAD:at(x, y) < 0.5 then
    local pts = {} for i = 0, 6 do local b = i * math.pi / 3 + k * 0.3; pts[#pts+1] = {x + 5 * math.cos(b), y + 2 * math.sin(b)} end
    g:reload(math.cos(a) < 0 and BD or Q1, 0.7); g:stroke(pts, {pressure={0.35, 0.35}, ramps={0.05, 0.05}})
  end
end

--@ chunk 15
wait(2 * 24 * 60)
local sh = (ellipse(600, 498, 60, 14) * RUFF) - HEAD
work(sh, {hand="detail", pile=BD, coverage=3.5, fill=true, clip=sh})
local sh2 = (ellipse(575, 494, 40, 9) * RUFF) - HEAD
work(sh2, {hand="detail", pile=Q1, coverage=3.5, fill=true, clip=sh2})
-- carpet: rumpled folds as broad facets, lit ridges toward the window
TRL = pile{{"red earth",1},{"vermilion",0.4},{"yellow ochre",0.2},{"lead white",0.3}}
TRD = pile{{"red earth",0.8},{"rose madder",0.4},{"bone black",0.5},{"bone brown",0.3}}
local tab = TABLE - FIGX:grow(1)
local function F(pts, p) local m = poly(pts) * tab; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
F({{0,830},{200,836},{150,960},{0,980}}, TRL)
F({{200,836},{360,846},{300,980},{150,960}}, TR)
F({{360,846},{520,860},{540,960},{420,1000},{300,980}}, TRD)
F({{0,980},{150,960},{120,1120},{0,1150}}, TR)
F({{150,960},{300,980},{260,1130},{120,1120}}, TRL)
F({{300,980},{420,1000},{440,1150},{260,1130}}, TR)
F({{420,1000},{540,960},{580,1150},{440,1150}}, TRD)
F({{0,1150},{120,1120},{260,1130},{440,1150},{580,1150},{600,1250},{0,1250}}, TRD)

--@ chunk 16
wait(2 * 24 * 60)
CB = pile{{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.2}}
CO = pile{{"yellow ochre",1.5},{"raw sienna",0.6},{"lead white",0.4}}
local tab = TABLE - FIGX:grow(1)
-- a border band along the near-top edge
local band = (poly({{0,850},{520,874},{526,900},{0,880}}) * tab)
work(band, {hand="detail", pile=CB, coverage=3.5, fill=true, clip=band})
local t = brush{kind="round", width=4.0, point=0.2}
for x = 10, 510, 22 do t:reload(CO, 0.9); t:touch(x, 865 + x * 0.046, {pressure=0.45}) end
-- the medallion: a golden-angle spiral of ochre and blue knots, foreshortened, its rows bent by the rumples
local GA = math.rad(137.50776)
for k = 4, 160 do
  local r = 9 * math.sqrt(k); local a = k * GA
  local x, y = 250 + r * math.cos(a) * 1.4, 1060 + r * math.sin(a) * 0.55
  y = y + 10 * math.sin(x / 70)
  if tab:at(x, y) > 0.9 then t:reload(k % 3 == 0 and CB or CO, 0.85); t:touch(x, y, {pressure=0.32 + 0.15 * (y - 900) / 350}) end
end

--@ chunk 17
wait(1 * 24 * 60)
local tab = TABLE - FIGX:grow(1)
local t = brush{kind="round", width=6.5, point=0.2}
local GA = math.rad(137.50776)
-- a second, denser spiral of larger knots, rows bent by the rumples, smaller toward the back
for k = 3, 220 do
  local r = 11 * math.sqrt(k); local a = k * GA
  local x, y = 270 + r * math.cos(a) * 1.5, 1080 + r * math.sin(a) * 0.5
  y = y + 12 * math.sin(x / 60)
  if tab:at(x, y) > 0.9 and y > 900 then
    local p = (k % 5 == 0) and CB or ((k % 2 == 0) and CO or TRD)
    t:reload(p, 0.85); t:touch(x, y, {pressure=0.25 + 0.3 * (y - 900) / 350})
  end
end
-- the fruit bowl: a tipped bronze dish with the fruit spilling toward us
DISH = poly({{150,846},{320,836},{336,858},{300,880},{170,886},{140,866}}, true)
work(DISH * rect(0,0,240,2000), {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=DISH})
work(DISH * rect(240,0,200,2000), {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=DISH})
local inner = ellipse(236, 848, 80, 9) * DISH
work(inner, {hand="detail", pile=Q2, coverage=3.5, fill=true, clip=inner})

--@ chunk 18
wait(2 * 24 * 60)
FRU = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"red earth",0.2}}
FRD = pile{{"Mars orange",1},{"burnt sienna",0.7}}
for _, f in ipairs{{196,830,17}, {232,824,18}, {270,832,16}, {214,850,15}, {254,852,16}, {330,890,14}, {300,906,13}} do
  local o = ellipse(f[1], f[2], f[3], f[3]); work(o, {hand="detail", pile=FRU, coverage=3.5, fill=true, clip=o})
  local sh = o - ellipse(f[1] - 4, f[2] - 4, f[3] * 0.92, f[3] * 0.92); work(sh, {hand="detail", pile=FRD, coverage=3.5, fill=true, clip=sh})
end

--@ chunk 19
wait(2 * 24 * 60)
local h = brush{kind="round", width=2.4, point=0.3}
for _, f in ipairs{{196,830,17}, {232,824,18}, {270,832,16}, {214,850,15}, {254,852,16}, {330,890,14}, {300,906,13}} do
  h:reload(pile{{"lead white",2},{"cadmium yellow",0.3},{"zinc white",0.5}}, 0.85); h:touch(f[1] - f[3] * 0.4, f[2] - f[3] * 0.4, {pressure=0.3})
end
-- the dish's lit rim
local r = brush{kind="round", width=1.6, point=0.7}
r:reload(HL, 0.8); r:stroke({{144,864},{170,848},{220,840}}, {pressure={0.2, 0.7, 0.1}})
-- a shadow under the dish and the spilled fruit
local sh = (ellipse(240, 892, 100, 10) + ellipse(318, 914, 32, 6)) * (TABLE - FIGX) - DISH
work(sh, {hand="detail", pile=TRD, coverage=3.5, fill=true, clip=sh})

--@ chunk 20
wait(4 * 24 * 60)
FRUITS = {{196,830,17}, {232,824,18}, {270,832,16}, {214,850,15}, {254,852,16}, {330,890,14}, {300,906,13}}
local fm = nil
for _, f in ipairs(FRUITS) do local o = ellipse(f[1], f[2], f[3], f[3]); fm = fm and (fm + o) or o end
FRM = fm
local d = DISH - FRM
work(d * rect(0,0,240,2000), {hand="detail", pile=Q5, coverage=4, fill=true, clip=d})
work(d * rect(240,0,200,2000), {hand="detail", pile=Q3, coverage=4, fill=true, clip=d})
local inner = (ellipse(236, 848, 80, 9) * DISH) - FRM
work(inner, {hand="detail", pile=Q2, coverage=4, fill=true, clip=inner})

--@ chunk 21
wait(3 * 24 * 60)
-- the carpet medallion: lozenges set along a golden-angle spiral, foreshortened, rows bent by the rumples
local tab = TABLE - FIGX:grow(1) - DISH:grow(2) - FRM:grow(2) - (ellipse(240, 892, 100, 10) + ellipse(318, 914, 32, 6))
local GA = math.rad(137.50776)
local lozC, lozB, lozR
for k = 3, 140 do
  local r = 14 * math.sqrt(k); local a = k * GA
  local x, y = 270 + r * math.cos(a) * 1.5, 1090 + r * math.sin(a) * 0.5
  y = y + 12 * math.sin(x / 60)
  if y > 920 and tab:at(x, y) > 0.9 then
    local s = 4 + 6 * (y - 900) / 350
    local m = poly({{x - s * 1.3, y}, {x, y - s * 0.6}, {x + s * 1.3, y}, {x, y + s * 0.6}})
    if k % 5 == 0 then lozB = lozB and (lozB + m) or m elseif k % 2 == 0 then lozC = lozC and (lozC + m) or m else lozR = lozR and (lozR + m) or m end
  end
end
work(lozC * tab, {hand="detail", pile=CO, coverage=3.5, fill=true, clip=lozC * tab})
work(lozB * tab, {hand="detail", pile=CB, coverage=3.5, fill=true, clip=lozB * tab})
work(lozR * tab, {hand="detail", pile=pile{{"lead white",1.2},{"red earth",0.6},{"yellow ochre",0.4}}, coverage=3.5, fill=true, clip=lozR * tab})

--@ chunk 22
wait(3 * 24 * 60)
for _, f in ipairs(FRUITS) do
  local o = ellipse(f[1], f[2], f[3], f[3]); work(o, {hand="detail", pile=FRU, coverage=4, fill=true, clip=o})
end

--@ chunk 23
wait(3 * 24 * 60)
local h = brush{kind="round", width=2.4, point=0.3}
for _, f in ipairs(FRUITS) do
  local o = ellipse(f[1], f[2], f[3], f[3])
  local sh = o - ellipse(f[1] - 4, f[2] - 4, f[3] * 0.92, f[3] * 0.92); work(sh, {hand="detail", pile=FRD, coverage=4, fill=true, clip=sh})
  h:reload(pile{{"lead white",2},{"cadmium yellow",0.3},{"zinc white",0.5}}, 0.85); h:touch(f[1] - f[3] * 0.4, f[2] - f[3] * 0.4, {pressure=0.3})
end

--@ chunk 24
wait(1 * 24 * 60)
CGL = pile{{"viridian",1},{"raw sienna",0.7},{"lead white",0.45},{"bone black",0.1}}
CGM = pile{{"viridian",1},{"raw sienna",0.5},{"bone black",0.3},{"lead white",0.15}}
CGD = pile{{"viridian",0.8},{"bone black",0.7},{"bone brown",0.3}}
local c = CURT:grow(1)
local xs = {848, 878, 900, 926, 944, 968, 986, 1004}
for i = 1, #xs - 1 do
  local m = poly({{xs[i] + 8 * math.sin(i), 0}, {xs[i+1] + 8 * math.sin(i + 1), 0}, {xs[i+1] + 14 * math.cos(i + 1), 1250}, {xs[i] + 14 * math.cos(i), 1250}}) * c
  local P = ({CGL, CGM, CGD, CGL, CGD, CGM, CGD})[i]
  work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m})
end
-- the wall's upper right, re-laid flat and cool
local wall = (everywhere() - FIGX:grow(1) - WIN - TABLE - CURT) * rect(560, 0, 320, 520)
work(wall, {hand="detail", pile=WP3, coverage=4, fill=true, clip=wall, angle=math.pi/2})

--@ chunk 25
wait(3 * 24 * 60)
WPM = pile{{"lead white",2.7},{"zinc white",0.25},{"raw sienna",0.4},{"ultramarine ash",0.45},{"bone brown",0.07}}
local wall = everywhere() - FIGX:grow(1) - WIN - TABLE - CURT
local function band(x0, x1) return wall * rect(x0, 0, x1 - x0, 860) end
work(band(260, 470), {hand="body", pile=WP1, coverage=3.5, fill=true, clip=band(260, 470), angle=math.pi/2})
work(band(470, 640), {hand="body", pile=WPM, coverage=3.5, fill=true, clip=band(470, 640), angle=math.pi/2})
work(band(640, 790), {hand="body", pile=WP2, coverage=3.5, fill=true, clip=band(640, 790), angle=math.pi/2})
work(band(790, 880), {hand="body", pile=WP3, coverage=3.5, fill=true, clip=band(790, 880), angle=math.pi/2})
blend(band(445, 495), {angle=math.pi/2}); blend(band(615, 665), {angle=math.pi/2}); blend(band(765, 815), {angle=math.pi/2})
blend(band(235, 285), {angle=math.pi/2})

--@ chunk 26
wait(3 * 24 * 60)
WSH = pile{{"lead white",1.8},{"raw sienna",0.55},{"ultramarine ash",0.6},{"bone brown",0.4}}
local function sh(m, dx, dy) return m end
local wall = everywhere() - FIGX:grow(1) - WIN - TABLE - CURT
local cast = poly({{640,300},{700,290},{730,340},{734,420},{712,480},{780,520},{800,640},{820,860},{760,860},{720,700}}, true) * wall
work(cast, {hand="body", pile=WSH, coverage=3, fill=true, clip=cast, angle=math.pi/2, edge="soft"})
-- curtain: soften the darkest stripes a step
local c = CURT:grow(1)
local xs = {848, 878, 900, 926, 944, 968, 986, 1004}
for _, i in ipairs{3, 5, 7} do
  local m = poly({{xs[i] + 8 * math.sin(i), 0}, {xs[i+1] + 8 * math.sin(i + 1), 0}, {xs[i+1] + 14 * math.cos(i + 1), 1250}, {xs[i] + 14 * math.cos(i), 1250}}) * c
  work(m, {hand="detail", pile=CGM, coverage=3.5, fill=true, clip=m})
end
for _, i in ipairs{1, 4} do
  local m = poly({{xs[i] + 8 * math.sin(i), 0}, {xs[i+1] + 8 * math.sin(i + 1), 0}, {xs[i+1] + 14 * math.cos(i + 1), 1250}, {xs[i] + 14 * math.cos(i), 1250}}) * c
  work(m, {hand="detail", pile=pile{{"viridian",1},{"raw sienna",0.6},{"lead white",0.3},{"bone black",0.18}}, coverage=3.5, fill=true, clip=m})
end

--@ chunk 27
wait(2 * 24 * 60)
local low = (ROBE - TABLE:grow(1)) * rect(0, 760, 1000, 500)
work(low, {hand="detail", pile=BLM, coverage=4, fill=true, clip=low})

--@ chunk 28
wait(3 * 24 * 60)
local low = (ROBE - TABLE:grow(1)) * rect(0, 760, 1000, 500)
local function F(pts, p) local m = poly(pts) * low; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{480,760},{540,760},{580,1250},{520,1250}}, BLL)
F({{560,760},{590,760},{640,1250},{610,1250}}, BLL)
F({{620,760},{660,760},{700,1250},{660,1250}}, BLS)
F({{690,760},{740,760},{780,1250},{720,1250}}, BLS)
F({{600,760},{620,760},{660,1250},{640,1250}}, BLS)

--@ chunk 29
wait(2 * 24 * 60)
local robe = ROBE - TABLE:grow(1)
local hem = poly({{440,760},{750,760},{752,772},{440,772}}) * robe
work(hem, {hand="detail", pile=BLS, coverage=4, fill=true, clip=hem})
local h = brush{kind="round", width=1.6, point=0.7}
h:reload(pile{{"lead white",2},{"ultramarine blue",0.5},{"zinc white",0.4}}, 0.8); h:stroke({{474,757},{560,757},{640,757}}, {pressure={0.5, 0.4, 0.05}, ramps={0.1, 0.3}, clip=robe})
-- the window light down the robe's front edge and the sleeve
h:reload(pile{{"lead white",2},{"ultramarine blue",0.5},{"zinc white",0.4}}, 0.8); h:stroke({{470,530},{450,600},{446,680},{462,750}}, {pressure={0.1, 0.6, 0.4, 0.05}, ramps={0.2, 0.3}, clip=robe + ARM})
-- the tablet's lit top edge and a cool reflected light on its face
h:reload(pile{{"lead white",3},{"zinc white",1}}, 0.8); h:stroke({{404,536},{468,512}}, {pressure={0.6, 0.3}, ramps={0.1, 0.2}})

--@ chunk 30
wait(2 * 24 * 60)
local up = poly({{46,112},{236,180},{236,440},{46,440}}) * WIN
local t = brush{kind="round", width=5, point=0.2}
-- small bright touches in some panes, the sky through old glass
for i = 0, 40 do
  local x = 60 + (i * 37) % 170; local y = 150 + ((i * 53) % 270)
  if up:at(x, y) > 0.9 and i % 3 ~= 0 then t:reload(pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.08}}, 0.7); t:touch(x, y, {pressure=0.3}) end
end
-- the light on the table's near edge and the carpet's top fold
local h = brush{kind="filbert", width=4}
h:reload(TRL, 0.7); h:stroke({{0,836},{120,838},{200,840}}, {pressure={0.1, 0.6, 0.1}, ramps={0.3, 0.3}})
h:reload(pile{{"lead white",2},{"vermilion",0.3},{"yellow ochre",0.2}}, 0.6); h:stroke({{20,880},{100,876}}, {pressure={0.05, 0.4, 0.05}, ramps={0.3, 0.3}})

--@ chunk 31
wait(3 * 24 * 60)
SKIRT = poly({{452,772},{748,772},{760,900},{790,1250},{530,1250},{560,1040},{476,900}}) - TABLE:grow(1)
local wl = (ROBE - SKIRT - TABLE - CURT) * rect(0, 772, 1000, 500)
work(wl, {hand="detail", pile=WP2, coverage=4, fill=true, clip=wl})
work(SKIRT, {hand="detail", pile=BLM, coverage=4, fill=true, clip=SKIRT})

--@ chunk 32
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts) * SKIRT; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{470,772},{530,772},{580,1250},{530,1250}}, BLL)
F({{560,772},{585,772},{640,1250},{612,1250}}, BLL)
F({{600,772},{630,772},{684,1250},{650,1250}}, BLS)
F({{660,772},{700,772},{740,1250},{700,1250}}, BLS)
F({{720,772},{752,772},{792,1250},{760,1250}}, BLS)

--@ chunk 33
wait(3 * 24 * 60)
SKIRT = poly({{446,772},{750,772},{762,900},{792,1250},{452,1250},{478,1000},{458,880}})
work(SKIRT, {hand="detail", pile=BLM, coverage=4, fill=true, clip=SKIRT})

--@ chunk 34
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts) * SKIRT; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{446,772},{470,772},{490,1250},{452,1250}}, BLS)
F({{480,772},{530,772},{566,1250},{520,1250}}, BLL)
F({{560,772},{585,772},{636,1250},{606,1250}}, BLL)
F({{606,772},{632,772},{682,1250},{650,1250}}, BLS)
F({{664,772},{702,772},{742,1250},{702,1250}}, BLS)
F({{724,772},{752,772},{794,1250},{764,1250}}, BLS)

--@ chunk 35
wait(3 * 24 * 60)
BLQ = pile{{"ultramarine blue",1},{"lead white",1.25},{"bone brown",0.3}}
local function F(pts, p) local m = poly(pts) * SKIRT; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{480,772},{530,772},{566,1250},{520,1250}}, BLQ)
F({{560,772},{585,772},{636,1250},{606,1250}}, BLM)
F({{632,772},{664,772},{702,1250},{682,1250}}, BLM)
-- a narrow lit edge on the pleat nearest the window, as in Vermeer's single soft highlights
local h = brush{kind="round", width=2.0, point=0.6}
h:reload(BLL, 0.8); h:stroke({{486,780},{506,1000},{526,1240}}, {pressure={0.4, 0.5, 0.2}, ramps={0.1, 0.2}, clip=SKIRT})
