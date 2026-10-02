-- easel session "docent_portrait": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=53,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.4},{"lead white",0.4}}, um=35, apply="roller"}}}

--@ chunk 2
HEAD = poly({{392,470},{400,360},{440,280},{510,248},{584,262},{636,320},{656,410},{650,520},{622,610},{570,660},{500,672},{440,640},{404,570}}, true)
RUFF = ellipse(520, 720, 270, 78)
ROBE = poly({{120,1250},{150,1000},{220,860},{320,770},{720,770},{820,860},{890,1000},{920,1250}}, true)
FIG = HEAD + RUFF + ROBE
BG1 = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.3}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"bone black",0.3},{"lead white",0.25}}
local bg = everywhere() - FIG:grow(3)
work(bg, {hand="broad", pile=BG1, coverage=2.8, fill=true, clip=bg, angle=math.pi/2 + 0.15})

--@ chunk 3
-- the light side of the room, scumbled into the wet dark so there is no seam
local bg = everywhere() - FIG:grow(3)
work(bg * poly({{0,0},{560,0},{300,500},{0,760}}), {hand="scumble", pile=BG2, coverage=1.2, clip=bg, pressure={0.2, 0.5}})
blend(bg * poly({{0,0},{700,0},{380,560},{0,900}}), {angle=math.pi/2 + 0.6})

--@ chunk 4
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
B1 = pile{{"raw sienna",1},{"bone brown",0.7},{"lead white",1},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
RB = pile{{"bone black",1.2},{"bone brown",0.8},{"ultramarine blue",0.3}}
RB2 = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.3},{"lead white",0.3}}
local robe = ROBE - RUFF
work(robe, {hand="body", pile=RB, coverage=3, fill=true, clip=robe, angle=math.pi/2})
local ruff = RUFF - HEAD
work(ruff, {hand="body", pile=B1, coverage=3, fill=true, clip=ruff, angle=0})
work(HEAD, {hand="body", pile=Q2, coverage=3, fill=true, clip=HEAD, angle=math.pi/2})

--@ chunk 5
wait(4 * 24 * 60)
print(drying(200, 200), drying(500, 450))
-- the ground re-laid over dry paint in three graded piles round the window corner, seams joined narrowly
BGM = pile{{"bone brown",2},{"raw sienna",0.4},{"bone black",0.5},{"lead white",0.1}}
local bg = everywhere() - FIG:grow(3)
local function ringm(r0, r1) return bg * (ellipse(0, 0, r1, r1) - ellipse(0, 0, r0, r0)) end
work(ringm(0, 520), {hand="body", pile=BG2, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ringm(520, 820), {hand="body", pile=BGM, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ringm(820, 2000), {hand="body", pile=BG1, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
blend(ringm(490, 550), {angle=-0.7})
blend(ringm(790, 850), {angle=-0.7})

--@ chunk 6
FACE = ellipse(486, 478, 74, 112)
local shell = HEAD:grow(2) - FACE
function plate(pts, p, clip) local m = poly(pts) * (clip or shell); if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}) end; return m end
PLATES = {
  {{{380,360},{430,270},{510,240},{520,330},{450,372}}, Q4},
  {{{510,240},{590,255},{646,320},{600,352},{520,330}}, Q3},
  {{{380,470},{390,360},{450,372},{418,480},{396,580}}, Q5},
  {{{450,372},{520,330},{600,352},{590,388},{520,372},{460,396}}, Q5},
  {{{600,352},{646,320},{666,410},{612,432},{590,388}}, Q2},
  {{{612,432},{666,410},{660,520},{600,542},{572,470}}, Q2},
  {{{600,542},{660,520},{632,620},{570,624},{562,562}}, Q1},
  {{{396,580},{436,650},{500,682},{574,668},{570,624},{520,604},{460,600}}, Q3},
  {{{556,396},{590,388},{612,432},{572,470},{562,530},{600,542},{562,562},{556,500}}, Q3},
}
for _, p in ipairs(PLATES) do plate(p[1], p[2]) end

--@ chunk 7
FN = {T={486,360}, A={426,402}, C={482,426}, D={548,400}, L={406,482}, E={472,522}, R={568,482}, G={434,566}, H={536,564}, B={486,598}}
local function F(names, p) local pts = {} for _, n in ipairs(names) do pts[#pts+1] = FN[n] end; local m = poly(pts) * FACE; work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}) end
F({"T","A","C"}, B4); F({"T","C","D"}, B3); F({"A","L","E","C"}, B3); F({"C","D","R","E"}, B2)
F({"L","G","E"}, B3); F({"E","R","H"}, B1); F({"G","B","H","E"}, B2)
-- edges of the oval outside the facet fan
local rest = FACE - poly({FN.T, FN.D, FN.R, FN.H, FN.B, FN.G, FN.L, FN.A})
work(rest * rect(0, 0, 486, 2000), {hand="detail", pile=B2, coverage=3, fill=true, clip=rest})
work(rest * rect(486, 0, 300, 2000), {hand="detail", pile=B1, coverage=3, fill=true, clip=rest})

--@ chunk 8
wait(2 * 24 * 60)
local cx, cy, rx, ry = 520, 720, 272, 80
local n = 26
local ruff = RUFF:grow(2) - HEAD
for i = 0, n - 1 do
  local a0 = 2 * math.pi * i / n + 0.05
  local a1 = 2 * math.pi * (i + 1) / n + 0.05
  local am = (a0 + a1) / 2
  local m = poly({{cx, cy}, {cx + rx * 1.1 * math.cos(a0), cy + ry * 1.1 * math.sin(a0)}, {cx + rx * 1.1 * math.cos(a1), cy + ry * 1.1 * math.sin(a1)}}) * ruff
  local lit = -math.cos(am) * 0.7 - math.sin(am) * 0.3   -- facing up-left
  local k = clamp(math.floor((lit + 1) * 1.6 + ((i % 2 == 0) and 0.6 or 0)), 0, 3) + 1
  local P = ({B1, B2, B3, B4})[k]
  if m:area() > 4 then work(m, {hand="detail", pile=P, coverage=3, fill=true, clip=m}) end
end

--@ chunk 9
wait(3 * 24 * 60)
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
local cx, cy, rx, ry = 520, 720, 272, 80
local ruff = RUFF:grow(2) - HEAD
local n = 26
for i = 0, n - 1 do
  local a0 = 2 * math.pi * i / n + 0.05
  local a1 = 2 * math.pi * (i + 1) / n + 0.05
  local am = (a0 + a1) / 2
  if math.cos(am) > 0.3 then
    local m = poly({{cx, cy}, {cx + rx * 1.1 * math.cos(a0), cy + ry * 1.1 * math.sin(a0)}, {cx + rx * 1.1 * math.cos(a1), cy + ry * 1.1 * math.sin(a1)}}) * ruff
    local P = (i % 2 == 0) and B1 or BD
    if math.cos(am) > 0.8 then P = (i % 2 == 0) and BD or Q2 end
    if m:area() > 4 then work(m, {hand="detail", pile=P, coverage=3, fill=true, clip=m}) end
  end
end
-- the opening for the neck, and a short bronze neck in shadow
local hole = ellipse(526, 708, 104, 30) - HEAD
work(hole, {hand="detail", pile=Q1, coverage=3, fill=true, clip=hole})
local neck = poly({{462,660},{590,650},{596,716},{460,720}}) * hole:grow(2) - HEAD
work(neck, {hand="detail", pile=Q2, coverage=3, fill=true, clip=neck})
-- the ruff's thickness: its lower rim, turning under, in shadow
local rim = RUFF - ellipse(520, 704, 272, 80)
work(rim * rect(0, 0, 470, 2000), {hand="detail", pile=B1, coverage=3, fill=true, clip=rim})
work(rim * rect(470, 0, 400, 2000), {hand="detail", pile=Q2, coverage=3, fill=true, clip=rim})

--@ chunk 10
wait(2 * 24 * 60)
local hole = ellipse(526, 708, 104, 30)
local neck = (poly({{448,640},{600,630},{606,716},{446,722}}) * (hole + rect(440, 600, 180, 108))) - HEAD
local nl = neck * rect(0, 0, 500, 2000)
local nr = neck * rect(500, 0, 300, 2000)
work(nl, {hand="detail", pile=Q3, coverage=3, fill=true, clip=nl, angle=math.pi/2})
work(nr, {hand="detail", pile=Q1, coverage=3, fill=true, clip=nr, angle=math.pi/2})
local cres = hole - ellipse(526, 700, 100, 27)
work(cres, {hand="detail", pile=pile{{"bone black",1},{"bone brown",1}}, coverage=3, fill=true, clip=cres})

--@ chunk 11
RBL = pile{{"bone black",1},{"bone brown",0.6},{"lead white",0.7},{"ultramarine ash",0.3}}
RBD = pile{{"bone black",1.4},{"bone brown",0.6},{"ultramarine blue",0.2}}
local robe = ROBE:grow(3) - RUFF
local function F(pts, p) local m = poly(pts) * robe; if m:area() > 4 then work(m, {hand="body", pile=p, coverage=3, fill=true, clip=m, angle=math.pi/2, tool="filbert 6"}) end end
F({{200,860},{320,760},{440,780},{380,900},{240,960}}, RBL)
F({{120,1000},{240,960},{380,900},{420,1260},{100,1260}}, RB2)
F({{380,900},{440,780},{620,780},{660,900},{600,1260},{420,1260}}, RB)
F({{620,780},{730,770},{830,860},{900,1000},{930,1260},{600,1260},{660,900}}, RBD)

--@ chunk 12
LX, LY = 474, 474
LENS = pile{{"bone black",1},{"viridian",0.4},{"ultramarine blue",0.4}}
local bez = ellipse(LX, LY, 27, 29) - ellipse(LX, LY, 19, 21)
work(bez * rect(0, 0, LX, 2000), {hand="detail", pile=Q5, coverage=3, fill=true, clip=bez})
work(bez * rect(LX, 0, 200, 2000), {hand="detail", pile=Q2, coverage=3, fill=true, clip=bez})
local glass = ellipse(LX, LY, 19, 21)
work(glass, {hand="detail", pile=LENS, coverage=3, fill=true, clip=glass})
-- a deep ring of amber in the glass, the iris of the lens
local ir = ellipse(LX + 2, LY + 2, 12, 13) - ellipse(LX + 2, LY + 2, 6, 7)
work(ir, {hand="detail", pile=pile{{"Mars orange",1},{"raw sienna",1},{"bone brown",0.6}}, coverage=2.5, fill=true, clip=ir})
-- the lid plate, raised just enough to look at you
local lid = ellipse(LX, LY, 28, 30) * rect(0, 0, 1000, LY - 15)
work(lid, {hand="detail", pile=Q3, coverage=3, fill=true, clip=lid})

--@ chunk 13
wait(3 * 24 * 60)
print(drying(LX, LY))
local DK = pile{{"bone black",1.5},{"bone brown",0.5}}
local glass = ellipse(LX, LY, 19, 21) * rect(0, LY - 15, 1000, 100)
work(glass, {hand="detail", pile=DK, coverage=3, fill=true, clip=glass})

--@ chunk 14
wait(2 * 24 * 60)
local ir = ellipse(LX + 2, LY + 2, 12, 13) - ellipse(LX + 2, LY + 2, 6, 7)
work(ir * rect(0, LY - 15, 1000, 100), {hand="detail", pile=pile{{"Mars orange",1},{"raw sienna",0.8},{"cadmium yellow",0.2}}, coverage=3, fill=true, clip=ir})
-- the window, reflected in the lens: four small panes
local S5 = pile{{"lead white",3},{"zinc white",1},{"yellow ochre",0.2}}
for _, p in ipairs{{462,460},{467,460},{462,465},{467,465}} do local m = rect(p[1], p[2], 3.8, 3.8); work(m, {hand="detail", pile=S5, coverage=3, fill=true, clip=m}) end
-- lit edge of the lid plate and of the bezel
local h = brush{kind="round", width=1.4, point=0.7}
local pts = {} for i = 0, 8 do local a = math.pi * 1.05 + math.pi * 0.55 * i / 8; pts[#pts+1] = {LX + 28 * math.cos(a), LY + 30 * math.sin(a)} end
h:reload(HL, 0.7); h:stroke(pts, {pressure={0.1, 0.7, 0.1}, ramps={0.2, 0.3}})
h:reload(Q1, 0.7); h:stroke({{LX - 26, LY - 15}, {LX + 26, LY - 15}}, {pressure={0.5, 0.5}})

--@ chunk 15
wait(2 * 24 * 60)
CRK = {{552,398},{538,416},{530,412},{516,440},{507,446},{500,500},{490,512},{470,530},{458,528},{446,556},{432,574}}
local c = brush{kind="round", width=2.2, point=0.7}
c:reload(pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.3}}, 0.8)
c:stroke(CRK, {pressure={0.2, 0.8, 0.7, 0.6, 0.1}, ramps={0.1, 0.2}, clip=FACE})
-- a pale lip along the lower edge of the crack, where the light catches the break
local lip = {} for i, p in ipairs(CRK) do lip[i] = {p[1] - 1.5, p[2] + 2.5} end
local h = brush{kind="round", width=1.0, point=0.8}
h:reload(B4, 0.7); h:stroke(lip, {pressure={0.1, 0.5, 0.1}, ramps={0.2, 0.3}, clip=FACE})

--@ chunk 16
wait(2 * 24 * 60)
-- three staples of bronze across the crack: a bar and two small set pins, each lit at its upper left
local b = brush{kind="round", width=3.2, point=0.2}
local h = brush{kind="round", width=1.1, point=0.8}
for _, s in ipairs{{{525,420},{543,430}}, {{493,488},{512,492}}, {{448,548},{466,556}}} do
  local a, z = s[1], s[2]
  b:reload(Q3, 0.85); b:stroke({a, z}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
  for _, p in ipairs{a, z} do b:reload(Q1, 0.8); b:touch(p[1], p[2], {pressure=0.5}) end
  h:reload(HL, 0.7); h:stroke({{a[1] + 1, a[2] - 1.2}, {lerp(a[1], z[1], 0.6), lerp(a[2], z[2], 0.6) - 1.2}}, {pressure={0.5, 0.2}})
end

--@ chunk 17
wait(1 * 24 * 60)
local c = brush{kind="round", width=3.6, point=0.5}
for i = 1, #CRK - 1 do
  c:reload(pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.3}}, 0.8)
  c:stroke({CRK[i], CRK[i+1]}, {pressure={0.55, 0.55}, ramps={0.05, 0.05}, clip=FACE - ellipse(LX, LY, 28, 30)})
end
wait(1 * 24 * 60)
local b = brush{kind="round", width=4.2, point=0.2}
local h = brush{kind="round", width=1.3, point=0.8}
for _, s in ipairs{{{523,419},{545,431}}, {{491,487},{514,493}}, {{446,547},{468,557}}} do
  b:reload(Q4, 0.85); b:stroke(s, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
  h:reload(HL, 0.7); h:stroke({{s[1][1] + 1, s[1][2] - 1.6}, {lerp(s[1][1], s[2][1], 0.7), lerp(s[1][2], s[2][2], 0.7) - 1.6}}, {pressure={0.6, 0.2}})
  for _, p in ipairs(s) do b:reload(Q1, 0.8); b:touch(p[1], p[2], {pressure=0.45}) end
end

--@ chunk 18
wait(1 * 24 * 60)
local clip = HEAD - FACE:grow(1)
local s = brush{kind="round", width=2.0, point=0.6}
for _, p in ipairs(PLATES) do
  local pts = p[1]
  for i = 1, #pts do
    local a, b = pts[i], pts[i % #pts + 1]
    s:reload(Q1, 0.8); s:stroke({a, b}, {pressure={0.5, 0.5}, ramps={0.05, 0.05}, clip=clip})
  end
end
-- the face plate set into the helm: a dark seat all round, lit on its lower-right lip (it stands proud)
local seat = FACE:grow(4) - FACE
work(seat, {hand="detail", pile=Q1, coverage=3, fill=true, clip=seat})

--@ chunk 19
wait(2 * 24 * 60)
local h = brush{kind="round", width=1.5, point=0.7}
local function L(pts, p, pr) h:reload(p or HL, 0.75); h:stroke(pts, {pressure=pr or {0.1, 0.7, 0.1}, ramps={0.2, 0.3}}) end
-- worn-smooth sheen on the crown plates, a broad soft stroke then a hairline
local f = brush{kind="filbert", width=12}
f:reload(Q5, 0.6); f:stroke({{420,330},{450,290},{500,262}}, {pressure={0.1, 0.6, 0.1}, ramps={0.3, 0.4}, clip=HEAD})
f:reload(HL, 0.5); f:stroke({{432,316},{458,286},{490,270}}, {pressure={0.05, 0.45, 0.0}, ramps={0.3, 0.4}, clip=HEAD})
L({{392,420},{396,370},{420,320}}, Q5)
L({{452,374},{520,334},{596,354}})
L({{390,470},{394,530},{402,570}}, Q5)
L({{404,586},{440,646},{496,676}}, Q4, {0.1, 0.5, 0.0})
-- rivets on the plate margins, lit dot and dark shadow below
local r = brush{kind="round", width=3.0, point=0.2}
for _, p in ipairs{{440,300},{480,272},{540,262},{590,286},{620,330},{640,400},{640,470},{620,560},{596,610},{420,340},{410,420},{412,520},{430,612},{470,652},{530,664}} do
  r:reload(Q1, 0.8); r:touch(p[1] + 0.8, p[2] + 1.2, {pressure=0.5})
  r:reload(p[1] < 560 and Q5 or Q3, 0.8); r:touch(p[1], p[2], {pressure=0.4})
end

--@ chunk 20
wait(1 * 24 * 60)
-- neck, repainted clean over dry paint
local hole = ellipse(526, 708, 104, 30)
local neck = (poly({{448,640},{600,630},{606,716},{446,722}}) * (hole + rect(440, 600, 180, 108))) - HEAD - (hole - ellipse(526, 700, 100, 27))
work(neck * rect(0, 0, 500, 2000), {hand="detail", pile=Q3, coverage=3, fill=true, clip=neck, angle=math.pi/2})
work(neck * rect(500, 0, 300, 2000), {hand="detail", pile=Q1, coverage=3, fill=true, clip=neck, angle=math.pi/2})
-- the golden-angle rosette on the far temple: bone studs in a sunflower spiral, dim in the shadow
local GA = math.rad(137.50776)
local st = brush{kind="round", width=3.0, point=0.2}
for k = 1, 34 do
  local r = 5.4 * math.sqrt(k); local a = k * GA
  local x, y = 618 + r * math.cos(a) * 0.8, 452 + r * math.sin(a)
  st:reload(Q1, 0.8); st:touch(x + 0.7, y + 1, {pressure=0.45})
  st:reload(k % 3 == 0 and B2 or B1, 0.75); st:touch(x, y, {pressure=0.38})
end

--@ chunk 21
-- fold notation incised round the ruff: six petal-glyphs about a heart, each holding a smaller turned copy, bridged by arcs
local cx, cy = 520, 716
local surf = (RUFF - ellipse(520, 704, 272, 80):map(function(v) return 0 end)) - HEAD:grow(2) - ellipse(526, 708, 108, 33)
surf = RUFF - HEAD:grow(2) - ellipse(526, 708, 108, 33) - (RUFF - ellipse(520, 704, 272, 80))
local g = brush{kind="round", width=1.5, point=0.7}
local function inc(pts, lit)
  g:reload(Q1, 0.75); g:stroke(pts, {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=surf})
  if lit then local l = {} for i, p in ipairs(pts) do l[i] = {p[1] + 0.8, p[2] + 1.6} end; g:reload(B4, 0.6); g:stroke(l, {pressure={0.3, 0.3}, ramps={0.05, 0.05}, clip=surf}) end
end
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * 0.42 * math.sin(a)} end return t end
local n = 14
local prev
for k = 0, n - 1 do
  local a = math.pi * 2 * k / n + 0.2
  local x, y = cx + 206 * math.cos(a), cy + 58 * math.sin(a)
  if surf:at(x, y) > 0.5 then
    local lit = x < 600
    local r = 13 + 2 * math.sin(k * 1.7)
    inc(hex(x, y, r, 0.15 * k), lit)
    inc(hex(x, y, r * 0.618, 0.15 * k + 0.4 + 0.1 * k), lit)
    if prev then
      local arc = {} for i = 0, 6 do local t = i / 6; arc[#arc+1] = {lerp(prev[1] + r, x - r, t), lerp(prev[2], y, t) - 5 * math.sin(math.pi * t)} end
      inc(arc, lit)
    end
    prev = {x, y}
  else prev = nil end
end

--@ chunk 22
wait(3 * 24 * 60)
local DK = pile{{"bone black",1.4},{"bone brown",0.8}}
local hole = ellipse(526, 708, 104, 30)
local neckcol = poly({{446,600},{606,600},{606,716},{446,722}})
local cres = (hole - ellipse(526, 700, 100, 27)) + (hole - neckcol)
cres = cres - HEAD
work(cres, {hand="detail", pile=DK, coverage=3.5, fill=true, clip=cres})
local rim = RUFF - ellipse(520, 704, 272, 80)
work(rim * rect(470, 0, 400, 2000), {hand="detail", pile=Q2, coverage=3.5, fill=true, clip=rim})
work(rim * rect(0, 0, 470, 2000), {hand="detail", pile=B1, coverage=3.5, fill=true, clip=rim})
-- the clasp at the throat of the robe, and a line of studs down the front opening
local cl = ellipse(512, 818, 20, 16)
work(cl * rect(0,0,512,2000), {hand="detail", pile=Q4, coverage=3, fill=true, clip=cl})
work(cl * rect(512,0,200,2000), {hand="detail", pile=Q2, coverage=3, fill=true, clip=cl})
local op = brush{kind="round", width=3.0, point=0.5}
op:reload(RBD, 0.85); op:stroke({{510,836},{506,960},{500,1100},{496,1250}}, {pressure={0.7, 0.7}, ramps={0.05, 0.05}})

--@ chunk 23
wait(2 * 24 * 60)
local h = brush{kind="round", width=1.4, point=0.7}
h:reload(HL, 0.7); h:stroke({{498,812},{504,805},{514,804}}, {pressure={0.2, 0.7, 0.1}})
h:reload(Q1, 0.7); h:stroke({{512,808},{512,828}}, {pressure={0.5, 0.5}})
local st = brush{kind="round", width=3.4, point=0.2}
local y, gap = 862, 26
for k = 1, 9 do
  st:reload(Q1, 0.8); st:touch(523 - k * 0.3, y + 1.2, {pressure=0.5})
  st:reload(k < 5 and Q4 or Q3, 0.8); st:touch(522 - k * 0.3, y, {pressure=0.42})
  y = y + gap; gap = gap * 1.0
end

--@ chunk 24
wait(2 * 24 * 60)
RBL2 = pile{{"bone black",1},{"bone brown",0.9},{"lead white",0.35},{"raw sienna",0.25}}
RBM = pile{{"bone black",1.1},{"bone brown",0.9},{"lead white",0.15},{"raw sienna",0.1}}
local robe = ROBE:grow(6) - RUFF - ellipse(512, 818, 21, 17) - ribbon({{510,836},{506,960},{500,1100},{496,1250}}, 5)
local function F(pts, p) local m = poly(pts) * robe; if m:area() > 4 then work(m, {hand="body", pile=p, coverage=3, fill=true, clip=m, angle=math.pi/2, tool="filbert 6"}) end end
F({{190,860},{320,750},{440,770},{380,900},{240,960}}, RBL2)
F({{100,1000},{240,960},{380,900},{420,1260},{80,1260}}, RBM)
F({{100,860},{200,860},{240,960},{100,1000}}, RBM)

--@ chunk 25
wait(3 * 24 * 60)
BK1 = pile{{"red earth",1},{"bone brown",1},{"bone black",0.3}}
BK2 = pile{{"red earth",1},{"burnt sienna",0.6},{"bone brown",0.5},{"lead white",0.2}}
-- the book, held at a slant: its cover top plane lit, the fore-edge of pages in bone, the spine in shadow
BOOKTOP = poly({{360,1150},{596,1110},{660,1220},{420,1262}})
work(BOOKTOP * rect(0,0,500,2000), {hand="detail", pile=BK2, coverage=3, fill=true, clip=BOOKTOP})
work(BOOKTOP * rect(500,0,300,2000), {hand="detail", pile=BK1, coverage=3, fill=true, clip=BOOKTOP})
local pages = poly({{596,1110},{612,1116},{676,1226},{660,1220}})
work(pages, {hand="detail", pile=B2, coverage=3, fill=true, clip=pages})

--@ chunk 26
wait(2 * 24 * 60)
-- two hands of bronze plates, one over the other on the book; each finger a short tube lit on its upper-left
local function finger(T, B, w, lit)
  local m = ribbon({T, B}, {w * 2, w * 1.6})
  work(m, {hand="detail", pile=lit and Q4 or Q2, coverage=3, fill=true, clip=m})
  local dx, dy = B[1] - T[1], B[2] - T[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = dy / l, -dx / l
  if nx > 0 then nx, ny = -nx, -ny end
  local h = brush{kind="round", width=1.3, point=0.7}
  h:reload(lit and HL or Q4, 0.7); h:stroke({{T[1] + nx * w * 0.5, T[2] + ny * w * 0.5}, {B[1] + nx * w * 0.4, B[2] + ny * w * 0.4}}, {pressure={0.5, 0.2}})
  h:reload(Q1, 0.7); h:stroke({{T[1] - nx * w * 0.8, T[2] - ny * w * 0.8}, {B[1] - nx * w * 0.7, B[2] - ny * w * 0.7}}, {pressure={0.5, 0.4}})
end
-- lower hand: back of the hand as a plate, fingers reaching right across the cover
local back1 = poly({{392,1160},{452,1146},{470,1196},{410,1214}})
work(back1, {hand="detail", pile=Q3, coverage=3, fill=true, clip=back1})
for i, f in ipairs{{{452,1150},{500,1146}}, {{458,1162},{510,1160}}, {{464,1176},{514,1176}}, {{468,1190},{508,1194}}} do finger(f[1], f[2], 6 - i * 0.4, true) end
-- upper hand laid on it, a little to the right, thumb along the spine
local back2 = poly({{500,1130},{556,1118},{574,1164},{518,1176}})
work(back2, {hand="detail", pile=Q4, coverage=3, fill=true, clip=back2})
for i, f in ipairs{{{556,1122},{598,1124}}, {{562,1136},{606,1140}}, {{568,1150},{608,1158}}} do finger(f[1], f[2], 5.6 - i * 0.4, i == 1) end
finger({506,1170}, {480,1206}, 5.6, true)
-- knuckle seams and a joint line on each back plate
local s = brush{kind="round", width=1.6, point=0.6}
s:reload(Q1, 0.8); s:stroke({{450,1148},{468,1196}}, {pressure={0.5, 0.5}})
s:reload(Q1, 0.8); s:stroke({{554,1120},{572,1164}}, {pressure={0.5, 0.5}})
s:reload(HL, 0.7); s:stroke({{394,1160},{450,1147}}, {pressure={0.2, 0.6, 0.1}})
s:reload(HL, 0.7); s:stroke({{502,1131},{554,1119}}, {pressure={0.2, 0.6, 0.1}})

--@ chunk 27
wait(3 * 24 * 60)
BK0 = pile{{"red earth",0.8},{"bone brown",1.2},{"bone black",0.5}}
local top = BOOKTOP
work(top * rect(0,0,470,2000), {hand="detail", pile=BK1, coverage=3.5, fill=true, clip=top})
work(top * rect(470,0,300,2000), {hand="detail", pile=BK0, coverage=3.5, fill=true, clip=top})
-- hands re-laid as plates: knuckle-to-tip in three segments, fingers side by side, each a step darker to the right
local function seg(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
-- lower hand, under, reaching across the lower edge of the cover
seg({{388,1166},{448,1150},{466,1200},{408,1218}}, Q3)
local ys = {1150, 1163, 1176, 1189, 1202}
for i = 1, 4 do
  local y0, y1 = ys[i], ys[i+1]
  local xs = {448 + i * 4, 476 + i * 3, 498 + i * 2, 512 - i}
  local P = ({Q4, Q4, Q3, Q2})[i]
  seg({{xs[1], y0}, {xs[2], y0 - 1}, {xs[2], y1 - 1}, {xs[1] + 3, y1}}, P)
  seg({{xs[2], y0 - 1}, {xs[3], y0}, {xs[3], y1 - 2}, {xs[2], y1 - 1}}, i < 3 and Q5 or Q3)
  seg({{xs[3], y0}, {xs[4], y0 + 3}, {xs[4] - 2, y1 - 3}, {xs[3], y1 - 2}}, P)
end
-- upper hand, flat on the cover above it
seg({{496,1128},{552,1116},{570,1160},{514,1174}}, Q4)
local ys2 = {1116, 1129, 1142, 1156}
for i = 1, 3 do
  local y0, y1 = ys2[i], ys2[i+1]
  local xs = {552 + i * 3, 576 + i * 2, 596 + i, 608}
  seg({{xs[1], y0}, {xs[2], y0}, {xs[2], y1}, {xs[1] + 3, y1}}, i == 1 and Q5 or Q4)
  seg({{xs[2], y0}, {xs[3], y0 + 1}, {xs[3], y1 - 1}, {xs[2], y1}}, Q4)
  seg({{xs[3], y0 + 1}, {xs[4], y0 + 4}, {xs[4] - 2, y1 - 2}, {xs[3], y1 - 1}}, Q3)
end

--@ chunk 28
wait(4 * 24 * 60)
-- hands re-laid as plates: knuckle-to-tip in three segments, fingers side by side, each a step darker to the right
local function seg(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
-- lower hand, under, reaching across the lower edge of the cover
seg({{388,1166},{448,1150},{466,1200},{408,1218}}, Q3)
local ys = {1150, 1163, 1176, 1189, 1202}
for i = 1, 4 do
  local y0, y1 = ys[i], ys[i+1]
  local xs = {448 + i * 4, 476 + i * 3, 498 + i * 2, 512 - i}
  local P = ({Q4, Q4, Q3, Q2})[i]
  seg({{xs[1], y0}, {xs[2], y0 - 1}, {xs[2], y1 - 1}, {xs[1] + 3, y1}}, P)
  seg({{xs[2], y0 - 1}, {xs[3], y0}, {xs[3], y1 - 2}, {xs[2], y1 - 1}}, i < 3 and Q5 or Q3)
  seg({{xs[3], y0}, {xs[4], y0 + 3}, {xs[4] - 2, y1 - 3}, {xs[3], y1 - 2}}, P)
end
-- upper hand, flat on the cover above it
seg({{496,1128},{552,1116},{570,1160},{514,1174}}, Q4)
local ys2 = {1116, 1129, 1142, 1156}
for i = 1, 3 do
  local y0, y1 = ys2[i], ys2[i+1]
  local xs = {552 + i * 3, 576 + i * 2, 596 + i, 608}
  seg({{xs[1], y0}, {xs[2], y0}, {xs[2], y1}, {xs[1] + 3, y1}}, i == 1 and Q5 or Q4)
  seg({{xs[2], y0}, {xs[3], y0 + 1}, {xs[3], y1 - 1}, {xs[2], y1}}, Q4)
  seg({{xs[3], y0 + 1}, {xs[4], y0 + 4}, {xs[4] - 2, y1 - 2}, {xs[3], y1 - 1}}, Q3)
end

--@ chunk 29
wait(2 * 24 * 60)
local s = brush{kind="round", width=1.4, point=0.7}
local function L(pts, p, pr) s:reload(p, 0.75); s:stroke(pts, {pressure=pr or {0.45, 0.45}, ramps={0.1, 0.1}}) end
-- seams between fingers, and the knuckle line
for _, y in ipairs{1163, 1176, 1189} do L({{452 + (y - 1150) / 3, y}, {510, y - 1}}, Q1) end
for _, y in ipairs{1129, 1142} do L({{555, y}, {606, y + 1}}, Q1) end
L({{450,1150},{468,1200}}, Q1); L({{553,1117},{571,1160}}, Q1)
-- light along the upper edges, a glint on a knuckle of each hand
L({{392,1166},{448,1151}}, HL, {0.2, 0.6, 0.1}); L({{498,1128},{552,1117}}, HL, {0.2, 0.6, 0.1})
L({{556,1116},{600,1118}}, Q5, {0.4, 0.1}); L({{452,1151},{496,1150}}, Q5, {0.4, 0.1})
local d = brush{kind="round", width=2.6, point=0.2}
d:reload(HL, 0.7); d:touch(470, 1152, {pressure=0.4}); d:reload(HL, 0.7); d:touch(578, 1118, {pressure=0.4})
-- the book's bone clasp
local c = rect(640, 1180, 14, 10); work(c, {hand="detail", pile=B2, coverage=3, fill=true, clip=c})

--@ chunk 30
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
-- the left sleeve, its fold lit at the top
F({{240,1120},{320,1080},{392,1150},{410,1220},{330,1250},{220,1250}}, RBM)
F({{250,1118},{320,1080},{360,1112},{290,1140}}, RBL2)
-- the right forearm coming down from the chest, in shadow
F({{456,1040},{548,1030},{556,1112},{494,1126}}, RBD)

--@ chunk 31
wait(3 * 24 * 60)
-- bone cuffs at both wrists
local c1 = ribbon({{386,1154},{404,1218}}, 9)
work(c1, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=c1})
local c2 = ribbon({{492,1124},{556,1110}}, 8)
work(c2, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=c2})
local s = brush{kind="round", width=1.2, point=0.7}
s:reload(B4, 0.7); s:stroke({{384,1154},{392,1186}}, {pressure={0.5, 0.1}})
s:reload(B3, 0.7); s:stroke({{494,1121},{530,1113}}, {pressure={0.5, 0.1}})

--@ chunk 32
wait(1 * 24 * 60)
-- the head's shadow thrown down-right across the ruff
local surf = RUFF - HEAD:grow(1) - ellipse(526, 708, 104, 30) - (RUFF - ellipse(520, 704, 272, 80))
local sh = surf * poly({{590,660},{700,660},{730,700},{690,740},{600,740}}, true)
work(sh, {hand="detail", pile=pile{{"raw sienna",1},{"bone brown",1.4},{"lead white",0.3},{"ultramarine ash",0.3}}, coverage=3, fill=true, clip=sh})
-- warm bounce from the ruff on the underside of the head, right
local b = brush{kind="round", width=3.0, point=0.5}
b:reload(Q3, 0.75); b:stroke({{600,620},{575,650},{540,668}}, {pressure={0.1, 0.6, 0.1}, ramps={0.3, 0.3}, clip=HEAD})
-- the window's rim light down the lit contour of the helm
local h = brush{kind="round", width=1.6, point=0.7}
h:reload(HL, 0.75); h:stroke({{448,276},{416,310},{396,360},{388,420},{390,480}}, {pressure={0.1, 0.7, 0.6, 0.2}, ramps={0.2, 0.3}, clip=HEAD:grow(1)})

--@ chunk 33
wait(3 * 24 * 60)
-- straighten the shadow's far edge into two facets by restating the lit pleats beyond it
local surf = RUFF - HEAD:grow(1) - ellipse(526, 708, 104, 30) - (RUFF - ellipse(520, 704, 272, 80))
local beyond = surf * (poly({{600,660},{720,660},{740,720},{700,750},{600,750}}, true) - poly({{596,660},{676,664},{700,700},{660,742},{596,742}}))
work(beyond, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=beyond})

--@ chunk 34
wait(2 * 24 * 60)
-- the inscription restated where the shadow lies, dim
local surf = RUFF - HEAD:grow(2) - ellipse(526, 708, 108, 33) - (RUFF - ellipse(520, 704, 272, 80))
local zone = surf * rect(580, 640, 180, 120)
local g = brush{kind="round", width=1.5, point=0.7}
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * 0.42 * math.sin(a)} end return t end
local cx, cy = 520, 716
for k = 0, 13 do
  local a = math.pi * 2 * k / 14 + 0.2
  local x, y = cx + 206 * math.cos(a), cy + 58 * math.sin(a)
  if zone:at(x, y) > 0.5 then
    local r = 13 + 2 * math.sin(k * 1.7)
    g:reload(Q1, 0.7); g:stroke(hex(x, y, r, 0.15 * k), {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=zone})
    g:reload(Q1, 0.7); g:stroke(hex(x, y, r * 0.618, 0.15 * k + 0.4 + 0.1 * k), {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=zone})
  end
end

--@ chunk 35
wait(3 * 24 * 60)
local cx, cy, rx, ry = 520, 720, 272, 80
local surf = RUFF - HEAD:grow(1) - ellipse(526, 708, 104, 30) - (RUFF - ellipse(520, 704, 272, 80))
local zone = surf * rect(560, 600, 260, 180)
local n = 26
for i = 0, n - 1 do
  local a0 = 2 * math.pi * i / n + 0.05
  local a1 = 2 * math.pi * (i + 1) / n + 0.05
  local am = (a0 + a1) / 2
  local m = poly({{cx, cy}, {cx + rx * 1.1 * math.cos(a0), cy + ry * 1.1 * math.sin(a0)}, {cx + rx * 1.1 * math.cos(a1), cy + ry * 1.1 * math.sin(a1)}}) * zone
  local P = (i % 2 == 0) and B1 or BD
  if math.cos(am) > 0.8 then P = (i % 2 == 0) and BD or Q2 end
  if math.cos(am) < 0.3 then P = (i % 2 == 0) and B2 or B1 end
  if m:area() > 4 then work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m}) end
end

--@ chunk 36
wait(3 * 24 * 60)
local surf = RUFF - HEAD:grow(1) - ellipse(526, 708, 104, 30) - (RUFF - ellipse(520, 704, 272, 80))
-- the head's shadow, straight-edged: from the neck out to the right across four pleats
local sh = surf * poly({{586,646},{660,652},{694,688},{652,724},{590,730}})
work(sh, {hand="detail", pile=pile{{"raw sienna",1},{"bone brown",1.5},{"lead white",0.25},{"ultramarine ash",0.3}}, coverage=3.5, fill=true, clip=sh})

--@ chunk 37
wait(2 * 24 * 60)
-- the inscription restated where the shadow lies, dim
local surf = RUFF - HEAD:grow(2) - ellipse(526, 708, 108, 33) - (RUFF - ellipse(520, 704, 272, 80))
local zone = surf * rect(580, 640, 180, 120)
local g = brush{kind="round", width=1.5, point=0.7}
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * 0.42 * math.sin(a)} end return t end
local cx, cy = 520, 716
for k = 0, 13 do
  local a = math.pi * 2 * k / 14 + 0.2
  local x, y = cx + 206 * math.cos(a), cy + 58 * math.sin(a)
  if zone:at(x, y) > 0.5 then
    local r = 13 + 2 * math.sin(k * 1.7)
    g:reload(Q1, 0.7); g:stroke(hex(x, y, r, 0.15 * k), {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=zone})
    g:reload(Q1, 0.7); g:stroke(hex(x, y, r * 0.618, 0.15 * k + 0.4 + 0.1 * k), {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=zone})
  end
end

--@ chunk 38
wait(2 * 24 * 60)
local keep = BOOKTOP:grow(3) + poly({{380,1140},{620,1100},{680,1240},{380,1260}}) + ribbon({{386,1154},{404,1218}}, 10) + poly({{456,1040},{548,1030},{556,1112},{494,1126}})
local robe = ROBE:grow(6) - RUFF - keep - ellipse(512, 818, 21, 17) - ribbon({{510,836},{506,960},{500,1100},{496,1250}}, 5)
local function F(pts, p) local m = poly(pts) * robe; if m:area() > 4 then work(m, {hand="body", pile=p, coverage=3.5, fill=true, clip=m, angle=math.pi/2, tool="filbert 6"}) end end
F({{90,960},{240,900},{390,900},{430,1260},{60,1260}}, RB)
F({{170,1010},{300,960},{404,1140},{404,1230},{300,1260},{150,1260}}, RBM)

--@ chunk 39
wait(3 * 24 * 60)
-- the fold along the top of the sleeve, lit by the window; and the robe's outer edge, clean against the wall
local h = brush{kind="filbert", width=5}
h:reload(RBL2, 0.8); h:stroke({{180,1010},{300,962},{360,1040},{398,1140}}, {pressure={0.2, 0.7, 0.6, 0.2}, ramps={0.2, 0.3}})
local edge = (ROBE:grow(9) - ROBE:grow(1)) - RUFF:grow(4)
work(edge * rect(0, 0, 400, 2000), {hand="detail", pile=BGM, coverage=3.5, fill=true, clip=edge})
work(edge * rect(400, 0, 600, 2000), {hand="detail", pile=BG1, coverage=3.5, fill=true, clip=edge})

--@ chunk 40
wait(2 * 24 * 60)
local robe = ROBE - RUFF:grow(3) - BOOKTOP:grow(4) - poly({{456,1040},{548,1030},{556,1112},{494,1126}})
local f = brush{kind="filbert", width=5}
local d = brush{kind="filbert", width=4}
local function S(b, p, pts, pr) b:reload(p, 0.75); b:stroke(pts, {pressure=pr, ramps={0.3, 0.4}, clip=robe}) end
-- long folds falling from the ruff: a dull sheen on the side toward the window, a crease beside it
for _, x in ipairs{430, 590, 660, 740} do
  S(f, x < 500 and RBL2 or RBM, {{x, 800}, {x - 6, 940}, {x - 14, 1080}}, {0.1, 0.5, 0.1})
  S(d, RBD, {{x + 9, 810}, {x + 4, 950}, {x - 4, 1090}}, {0.1, 0.6, 0.2})
end
-- bone studs down the opening, counted in golden gaps
local st = brush{kind="round", width=3.6, point=0.2}
local y, gap = 858, 22
for k = 1, 8 do
  st:reload(RBD, 0.8); st:touch(511 - k * 0.6, y + 1.4, {pressure=0.5})
  st:reload(k < 4 and B2 or B1, 0.8); st:touch(510 - k * 0.6, y, {pressure=0.45})
  y = y + gap; gap = gap * 1.12
end

--@ chunk 41
wait(2 * 24 * 60)
BGE = pile{{"bone brown",2},{"bone black",0.7},{"burnt sienna",0.3},{"raw sienna",0.2}}
local edge = ((ROBE:grow(10) - ROBE:grow(1)) - RUFF:grow(4)) * rect(0, 760, 400, 600)
work(edge, {hand="detail", pile=BGE, coverage=3.5, fill=true, clip=edge})
