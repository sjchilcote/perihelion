-- easel session "arnolfini": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={24,22}, seed=83,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",1.5},{"raw sienna",1},{"burnt sienna",0.4},{"lead white",0.6}}, um=35, apply="roller"}}}

--@ chunk 2
-- the room
BACK = poly({{170,0},{830,0},{830,900},{170,900}})
LWALL = poly({{0,0},{170,0},{170,900},{0,1050}})
RWALL = poly({{830,0},{1000,0},{1000,1050},{830,900}})
FLOOR = poly({{0,1050},{170,900},{830,900},{1000,1050},{1000,1333},{0,1333}})
WIN = poly({{20,140},{140,170},{140,640},{20,700}})
BED = poly({{760,300},{1000,240},{1000,1150},{800,1100},{760,900}})
HUSB = poly({{250,1220},{262,1000},{280,820},{300,660},{330,560},{380,540},{420,560},{450,640},{480,760},{500,900},{480,1100},{470,1220}}, true)
WIFE = poly({{520,1240},{530,1050},{545,880},{560,700},{590,600},{640,580},{690,610},{720,700},{760,880},{800,1060},{830,1240}}, true)
HHEAD = poly({{330,560},{318,470},{330,380},{372,320},{430,300},{470,330},{464,410},{430,480},{418,540},{380,560}}, true)
WHEAD = poly({{600,600},{596,520},{606,450},{640,400},{690,380},{730,400},{730,460},{700,520},{684,590},{640,600}}, true)
FIG = HUSB + WIFE + HHEAD + WHEAD
WB = pile{{"raw sienna",1.5},{"burnt sienna",0.6},{"bone brown",0.6},{"lead white",0.5}}
WD = pile{{"bone brown",1.5},{"burnt sienna",0.6},{"raw sienna",0.5},{"bone black",0.3}}
FL1 = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.6},{"lead white",0.2}}
WN = pile{{"lead white",3},{"yellow ochre",0.4},{"zinc white",1}}
RD = pile{{"vermilion",1},{"red earth",1},{"rose madder",0.5},{"bone brown",0.2}}
local function W(m, p, a) m = m - FIG:grow(3); work(m, {hand="body", pile=p, coverage=2.8, fill=true, clip=m, angle=a, tool="filbert 12"}) end
W(BACK - BED, WB, math.pi/2)
W(LWALL - WIN, WD, math.pi/2)
W(RWALL - BED, WD, math.pi/2)
W(FLOOR, FL1, 0)
W(WIN, WN, math.pi/2)
W(BED, RD, math.pi/2)

--@ chunk 3
PL = pile{{"bone black",1},{"bone brown",0.8},{"rose madder",0.4},{"ultramarine blue",0.2}}
GR = pile{{"viridian",1},{"bone black",0.4},{"raw sienna",0.6},{"bone brown",0.3}}
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
work(HUSB - HHEAD, {hand="body", pile=PL, coverage=3, fill=true, clip=HUSB, angle=math.pi/2, tool="filbert 9"})
work(WIFE - WHEAD, {hand="body", pile=GR, coverage=3, fill=true, clip=WIFE, angle=math.pi/2, tool="filbert 9"})
work(HHEAD, {hand="detail", pile=BD, coverage=3, fill=true, clip=HHEAD})
work(WHEAD, {hand="detail", pile=BD, coverage=3, fill=true, clip=WHEAD})

--@ chunk 4
wait(4 * 24 * 60)
WB2 = pile{{"raw sienna",1.2},{"yellow ochre",0.6},{"burnt sienna",0.3},{"lead white",0.9}}
WBM = pile{{"raw sienna",1.3},{"burnt sienna",0.6},{"bone brown",0.8},{"lead white",0.35}}
local wall = (BACK - BED - FIG:grow(3))
local a = wall * rect(170, 0, 230, 900); local b = wall * rect(400, 0, 250, 900); local c = wall * rect(650, 0, 200, 900)
work(a, {hand="body", pile=WB2, coverage=3, fill=true, clip=a, angle=math.pi/2})
work(b, {hand="body", pile=WB, coverage=3, fill=true, clip=b, angle=math.pi/2})
work(c, {hand="body", pile=WBM, coverage=3, fill=true, clip=c, angle=math.pi/2})
blend(wall * rect(380, 0, 40, 900), {angle=math.pi/2})
blend(wall * rect(630, 0, 40, 900), {angle=math.pi/2})

--@ chunk 5
wait(2 * 24 * 60)
-- floor planks converging on the vanishing point, and the wall's plate seams
local VP = {500, 520}
local fl = FLOOR - FIG:grow(3) - BED
local s = brush{kind="round", width=1.8, point=0.6}
for i = -9, 9 do
  local xb = 500 + i * 120
  local t = (900 - VP[2]) / (1333 - VP[2])
  local xt = VP[1] + (xb - VP[1]) * t
  s:reload(WD, 0.8); s:stroke({{xt, 902}, {xb, 1333}}, {pressure={0.3, 0.6}, ramps={0.05, 0.05}, clip=fl})
end
for _, y in ipairs{960, 1040, 1150, 1290} do s:reload(WD, 0.6); s:stroke({{0, y}, {1000, y}}, {pressure={0.25, 0.25}, ramps={0.05, 0.05}, clip=fl}) end
-- wall: a few tall bronze plates, seams dark with a lit lip on the window side
local wall = BACK - BED - FIG:grow(3)
for _, x in ipairs{250, 360, 640, 740} do
  s:reload(WD, 0.7); s:stroke({{x, 0}, {x, 900}}, {pressure={0.35, 0.35}, ramps={0.02, 0.02}, clip=wall})
  s:reload(WB2, 0.6); s:stroke({{x + 2.5, 0}, {x + 2.5, 900}}, {pressure={0.2, 0.2}, ramps={0.02, 0.02}, clip=wall})
end
s:reload(WD, 0.8); s:stroke({{170, 900}, {830, 900}}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}})

--@ chunk 6
wait(2 * 24 * 60)
B1 = pile{{"raw sienna",1},{"bone brown",0.7},{"lead white",1},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
local function facets(F, clip) for _, f in ipairs(F) do local m = poly(f[1]) * clip:grow(1); if m:area() > 2 then work(m, {hand="detail", pile=f[2], coverage=3.5, fill=true, clip=m}) end end end
-- husband: skull sweeps up and back to the upper left, face turned right toward his wife
HF = {
  {{{318,470},{330,380},{372,320},{400,360},{360,420},{330,470}}, B4},
  {{{372,320},{430,300},{470,330},{440,370},{400,360}}, B3},
  {{{400,360},{440,370},{470,330},{464,410},{430,420}}, B2},
  {{{318,470},{330,470},{360,420},{400,360},{430,420},{440,440},{380,450},{336,490}}, B3},
  {{{336,490},{380,450},{440,440},{430,480},{418,540},{380,560},{330,560}}, Q4},
  {{{440,440},{464,410},{430,480}}, Q3},
  {{{418,540},{430,480},{440,500},{430,540}}, Q2},
}
facets(HF, HHEAD)
-- wife: head inclined toward him, skull sweeping back to the upper right
WF = {
  {{{606,450},{640,400},{660,430},{630,470}}, B4},
  {{{640,400},{690,380},{730,400},{700,430},{660,430}}, B2},
  {{{730,400},{730,460},{700,470},{700,430}}, B1},
  {{{606,450},{630,470},{660,430},{700,430},{700,470},{660,490},{600,500}}, B3},
  {{{596,520},{600,500},{660,490},{650,560},{640,600},{600,600}}, Q5},
  {{{660,490},{700,470},{730,460},{700,520},{684,590},{650,560}}, Q2},
}
facets(WF, WHEAD)

--@ chunk 7
wait(2 * 24 * 60)
WDK = pile{{"bone brown",1.6},{"burnt sienna",0.6},{"raw sienna",0.5},{"bone black",0.35}}
local wall = (BACK - BED - FIG:grow(2)) * rect(400, 0, 400, 900)
work(wall, {hand="body", pile=WDK, coverage=3, fill=true, clip=wall, angle=math.pi/2})
blend((BACK - BED - FIG:grow(2)) * rect(385, 0, 35, 900), {angle=math.pi/2})

--@ chunk 8
wait(3 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local function arc(a, b, c, n, s0)
  local E = {}
  local t, gap = 0.05, 0.3
  for k = 1, n do local u = 1 - t; E[k] = {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2], s0 * (1 - 0.08 * (k - 1))}; t = t + gap; gap = gap * 0.7 end
  return E
end
local d = brush{kind="round", width=1.1, point=0.8}
local tb = brush{kind="round", width=1.8, point=0.2}
local function eyes(E, lid)
  for _, e in ipairs(E) do
    local m = ellipse(e[1], e[2], e[3] + 3, e[3] * 0.75 + 3); work(m, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=m})
    local o = ellipse(e[1], e[2] + 0.5, e[3], e[3] * 0.72); work(o, {hand="detail", pile=EYE, coverage=3.5, fill=true, clip=o})
    local l = ellipse(e[1], e[2], e[3] + 3, e[3] * 0.75 + 3) * rect(0, 0, 2000, e[2] - e[3] * 0.15); work(l, {hand="detail", pile=lid, coverage=3.5, fill=true, clip=l})
    d:reload(Q1, 0.8); d:stroke({{e[1] - e[3], e[2] - e[3] * 0.15}, {e[1] + e[3], e[2] - e[3] * 0.05}}, {pressure={0.5, 0.5}})
    tb:reload(B4, 0.8); tb:touch(e[1] - e[3] * 0.3, e[2] + e[3] * 0.15, {pressure=0.22})
  end
end
-- husband, facing right: the arc runs along the line between bone and chitin, largest toward his wife
eyes(arc({430, 452}, {380, 432}, {340, 470}, 5, 5.5), B2)
-- wife, facing left toward him
eyes(arc({612, 506}, {640, 488}, {690, 482}, 5, 5), B2)
-- mouths: small closed pleated plates
for _, mo in ipairs{{{404,520},{420,512},{432,520},{426,534},{410,536}}, {{606,560},{622,552},{636,560},{630,574},{612,574}}} do
  local m = poly(mo, true); work(m, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=m})
  local c = {mo[1][1] + 2, (mo[1][2] + mo[4][2]) / 2}
  d:reload(Q1, 0.8); d:stroke({{mo[1][1] + 1, mo[1][2] + 3}, {mo[3][1] - 1, mo[3][2] + 4}}, {pressure={0.1, 0.6, 0.1}})
  for k = 1, 3 do local x = mo[1][1] + k * 6; d:reload(B1, 0.5); d:stroke({{x, mo[2][2] + 3}, {x - 0.5, mo[4][2] - 2}}, {pressure={0.05, 0.3, 0.05}, clip=m}) end
end

--@ chunk 9
wait(1 * 24 * 60)
MX, MY, MR = 512, 300, 54
GLASS = ellipse(MX, MY, MR, MR)
local frame = ellipse(MX, MY, MR + 16, MR + 16) - GLASS
work(frame * rect(0,0,MX,2000), {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=frame})
work(frame * rect(MX,0,500,2000), {hand="detail", pile=Q2, coverage=3.5, fill=true, clip=frame})
-- the reflected room, painted wet in big shapes: back wall (that is, our side of the room), window bright at left, floor
MG1 = pile{{"raw sienna",1},{"bone brown",1},{"lead white",0.4},{"ultramarine ash",0.3}}
MG2 = pile{{"bone brown",1.5},{"bone black",0.5},{"ultramarine ash",0.4},{"lead white",0.2}}
work(GLASS, {hand="detail", pile=MG1, coverage=3.5, fill=true, clip=GLASS})
local mfl = GLASS * rect(0, MY + 18, 2000, 100)
work(mfl, {hand="detail", pile=MG2, coverage=3.5, fill=true, clip=mfl})
local mw = GLASS * poly({{MX - 54, MY - 30}, {MX - 34, MY - 22}, {MX - 34, MY + 10}, {MX - 54, MY + 22}})
work(mw, {hand="detail", pile=WN, coverage=3.5, fill=true, clip=mw})

--@ chunk 10
wait(3 * 24 * 60)
-- in the mirror: the couple from behind, small and dark, the doorway between them lit, and in it the Commando
local function F(m, p) m = m * GLASS; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F(poly({{MX - 22, MY + 36}, {MX - 18, MY + 2}, {MX - 12, MY - 14}, {MX - 4, MY - 10}, {MX - 2, MY + 10}, {MX - 4, MY + 38}}, true), PL)
F(ellipse(MX - 10, MY - 20, 5, 8), BD)
F(poly({{MX + 6, MY + 38}, {MX + 6, MY + 4}, {MX + 12, MY - 10}, {MX + 20, MY - 8}, {MX + 24, MY + 10}, {MX + 26, MY + 38}}, true), GR)
F(ellipse(MX + 15, MY - 16, 5, 7), BD)
-- the doorway behind them, lit warm, and the dark figure standing in it
F(rect(MX - 3, MY - 22, 12, 30), pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.4}})
F(rect(MX - 0.5, MY - 16, 6, 20), pile{{"vermilion",1},{"red earth",0.8},{"bone brown",0.3}})
F(ellipse(MX + 2.5, MY - 19, 2.6, 3), pile{{"bone brown",1},{"bone black",0.6},{"lead white",0.3}})

--@ chunk 11
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.0, point=0.8}
d:reload(B4, 0.8); d:stroke({{MX + 2.5, MY - 13}, {MX + 2.5, MY - 5}}, {pressure={0.5, 0.5}})
d:reload(B4, 0.8); d:stroke({{MX + 0.5, MY - 11}, {MX + 4.5, MY - 11}}, {pressure={0.5, 0.5}})
-- roundels round the frame, ten, unequal, each a tiny lit medallion
local t = brush{kind="round", width=5.0, point=0.2}
for k = 0, 9 do local a = -math.pi / 2 + k * 2 * math.pi / 10 + 0.04 * math.sin(k * 2.3)
  local x, y = MX + (MR + 8) * math.cos(a), MY + (MR + 8) * math.sin(a)
  t:reload(Q1, 0.9); t:touch(x + 0.8, y + 1, {pressure=0.55}); t:reload(math.cos(a) < 0.2 and B3 or B1, 0.9); t:touch(x, y, {pressure=0.45}) end
-- the glass's highlight and its dark rim, so it bulges
local h = brush{kind="round", width=1.6, point=0.7}
local pts = {} for i = 0, 8 do local a = math.pi * 1.1 + 0.5 * i / 8; pts[#pts+1] = {MX + (MR - 7) * math.cos(a), MY + (MR - 7) * math.sin(a)} end
h:reload(B4, 0.7); h:stroke(pts, {pressure={0.05, 0.6, 0.05}, ramps={0.3, 0.3}})
local rim = GLASS - ellipse(MX, MY, MR - 4, MR - 4)
work(rim * rect(MX - 20, 0, 200, 2000), {hand="detail", pile=Q1, coverage=3, fill=true, clip=rim})

--@ chunk 12
-- the chandelier: a bronze ring of curling arms hung from a chain, one light lit
local cx, cy = 500, 120
local b = brush{kind="round", width=3.6, point=0.4}
local h = brush{kind="round", width=1.4, point=0.7}
b:reload(Q2, 0.9); b:stroke({{cx, 0}, {cx, cy - 20}}, {pressure={0.4, 0.4}})
local body = ellipse(cx, cy - 8, 10, 16); work(body, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=body})
h:reload(HL, 0.8); h:stroke({{cx - 6, cy - 18}, {cx - 7, cy}}, {pressure={0.1, 0.6, 0.1}})
local arms = {{-90, 18}, {-55, 28}, {-18, 32}, {20, 32}, {56, 26}, {88, 16}}
for i, a in ipairs(arms) do
  local tip = {cx + a[1], cy + a[2] - 22}
  local p = {{cx, cy}, {cx + a[1] * 0.4, cy + a[2] + 6}, {cx + a[1] * 0.85, cy + a[2] - 4}, tip}
  b:reload(a[1] < 0 and Q4 or Q2, 0.9); b:stroke(p, {pressure={0.5, 0.5, 0.4}, ramps={0.05, 0.1}})
  if a[1] < 0 then h:reload(HL, 0.7); h:stroke({p[2], p[3]}, {pressure={0.3, 0.1}}) end
  local cup = ellipse(tip[1], tip[2], 6, 3); work(cup, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=cup})
  local cand = rect(tip[1] - 2, tip[2] - 14, 4, 12); work(cand, {hand="detail", pile=i == 2 and B4 or B2, coverage=3.5, fill=true, clip=cand})
end
-- the one light lit: a small warm flame-LED with a soft glow
local tip = {cx - 55, cy + 28 - 22}
local glow = ellipse(tip[1], tip[2] - 20, 14, 16); work(glow, {hand="glaze", pile=pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.2}, medium=0.6}, coverage=0.8, clip=glow, load=0.3})
local fl = ellipse(tip[1], tip[2] - 19, 2.4, 4.5); work(fl, {hand="detail", pile=pile{{"lead white",3},{"lemon chrome",0.4}}, coverage=3.5, fill=true, clip=fl})

--@ chunk 13
wait(3 * 24 * 60)
local tip = {445, 126}
local glow = ellipse(tip[1], tip[2] - 20, 16, 18) - ellipse(tip[1], tip[2] - 19, 3, 5.5) - rect(tip[1] - 2, tip[2] - 14, 4, 12) - ellipse(tip[1], tip[2], 7, 4)
work(glow, {hand="detail", pile=WDK, coverage=3.5, fill=true, clip=glow})
-- the frame turned smoothly: lit at upper left, darker round to lower right, in four arcs
local frame = ellipse(MX, MY, MR + 16, MR + 16) - GLASS
local function sector(a0, a1) local p = {{MX, MY}} for i = 0, 8 do local a = a0 + (a1 - a0) * i / 8; p[#p+1] = {MX + 90 * math.cos(a), MY + 90 * math.sin(a)} end return poly(p) end
work(frame * sector(math.pi * 0.75, math.pi * 1.5), {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=frame})
work(frame * sector(math.pi * 1.5, math.pi * 2), {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=frame})
work(frame * sector(math.pi * 0.25, math.pi * 0.75), {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=frame})
work(frame * sector(0, math.pi * 0.25), {hand="detail", pile=Q2, coverage=3.5, fill=true, clip=frame})

--@ chunk 14
wait(2 * 24 * 60)
-- the flame's warmth on the arm and wall: a few small warm touches round it, not a glaze
local tip = {445, 126}
local t = brush{kind="round", width=2.6, point=0.3}
for _, o in ipairs{{-6, -26}, {6, -24}, {-9, -16}, {8, -14}, {0, -32}} do t:reload(pile{{"Mars orange",1},{"raw sienna",1},{"lead white",0.6}}, 0.7); t:touch(tip[1] + o[1], tip[2] + o[2], {pressure=0.3}) end
-- roundels: bigger, ten of them
local r = brush{kind="round", width=7.0, point=0.2}
for k = 0, 9 do local a = -math.pi / 2 + k * 2 * math.pi / 10 + 0.04 * math.sin(k * 2.3)
  local x, y = MX + (MR + 8) * math.cos(a), MY + (MR + 8) * math.sin(a)
  r:reload(Q1, 0.9); r:touch(x + 1, y + 1.2, {pressure=0.6}); r:reload((math.cos(a) + math.sin(a) < 0) and HL or Q4, 0.9); r:touch(x, y, {pressure=0.5}) end

--@ chunk 15
wait(1 * 24 * 60)
PLL = pile{{"bone black",0.8},{"bone brown",0.8},{"rose madder",0.5},{"lead white",0.35}}
GRL = pile{{"viridian",1},{"raw sienna",0.8},{"lead white",0.4},{"bone black",0.15}}
-- sleeves reaching to the centre
local hs = ribbon({{440,660},{478,720},{506,766}}, {34, 28, 22})
work(hs, {hand="detail", pile=PL, coverage=3.5, fill=true, clip=hs})
local ws = ribbon({{600,670},{560,724},{530,770}}, {36, 30, 24})
work(ws, {hand="detail", pile=GR, coverage=3.5, fill=true, clip=ws})
-- husband's other sleeve, raised at his chest
local hs2 = ribbon({{330,650},{316,720},{344,700}}, {30, 26, 22})
work(hs2, {hand="detail", pile=PL, coverage=3.5, fill=true, clip=hs2})

--@ chunk 16
wait(2 * 24 * 60)
function seg(a, b, w0, w1)
  local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx * w0, a[2] + ny * w0}, {b[1] + nx * w1, b[2] + ny * w1}, {b[1] - nx * w1, b[2] - ny * w1}, {a[1] - nx * w0, a[2] - ny * w0}})
end
local d = brush{kind="round", width=1.0, point=0.8}
function finger(J, w, P)
  for i = 1, #J - 1 do local m = seg(J[i], J[i+1], w * (1 - 0.1 * (i - 1)), w * (1 - 0.1 * i)); work(m, {hand="detail", pile=P[(i % 2) + 1], coverage=3.5, fill=true, clip=m}) end
  for i = 2, #J - 1 do d:reload(Q1, 0.8); d:touch(J[i][1], J[i][2], {pressure=0.4}) end
end
-- her hand, palm up, lying in his
local wb = poly({{518,770},{540,760},{548,786},{524,794}}); work(wb, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=wb})
for i, J in ipairs{{{520,774},{506,780},{494,790},{486,802}}, {{522,782},{508,792},{498,804},{492,816}}, {{526,790},{514,804},{506,816},{502,828}}} do finger(J, 3.2, {Q5, Q4}) end
-- his hand from the left, closing over hers
local hb = poly({{496,762},{514,758},{518,784},{498,790}}); work(hb, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=hb})
for i, J in ipairs{{{512,764},{528,766},{540,774},{546,786}}, {{514,772},{530,778},{540,790},{544,802}}, {{512,782},{526,792},{534,804},{536,816}}} do finger(J, 3.0, {Q4, Q3}) end
-- his raised hand, palm out, many-jointed fingers spread up
local rb = poly({{334,688},{358,684},{362,712},{338,716}}); work(rb, {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=rb})
for i, J in ipairs{{{336,688},{332,672},{330,656},{330,642}}, {{344,686},{344,668},{345,652},{346,638}}, {{352,686},{356,668},{360,654},{363,642}}, {{358,692},{368,680},{376,670},{382,662}}, {{334,700},{324,690},{316,682},{310,676}}} do finger(J, 3.0, {HL, Q5}) end

--@ chunk 17
wait(2 * 24 * 60)
GRD = pile{{"viridian",0.8},{"bone black",0.8},{"bone brown",0.4}}
PLD = pile{{"bone black",1.4},{"bone brown",0.6},{"rose madder",0.2}}
local keepH = ellipse(520, 790, 40, 40) + ellipse(345, 680, 45, 50)
local function F(pts, p, clip) local m = (poly(pts) * clip) - keepH; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
-- husband: long falls of cloth, a lit plane on the window side of each
local H = HUSB - HHEAD
F({{262,1000},{280,820},{300,660},{318,680},{300,860},{290,1220},{250,1220}}, PLL, H)
F({{360,760},{380,740},{390,960},{384,1220},{356,1220},{364,960}}, PLL, H)
F({{420,780},{440,760},{460,980},{460,1220},{430,1220},{432,980}}, PLL, H)
F({{392,760},{410,780},{420,1220},{396,1220}}, PLD, H)
F({{462,700},{490,820},{500,980},{480,1220},{466,1220},{474,980},{466,800}}, PLD, H)
-- wife: the great gathered skirt, folds swelling forward and catching the light on their left faces
local Wm = WIFE - WHEAD
F({{545,880},{560,760},{580,700},{596,720},{582,900},{566,1240},{524,1240},{530,1050}}, GRL, Wm)
F({{610,780},{630,760},{650,900},{648,1240},{620,1240},{624,900}}, GRL, Wm)
F({{680,800},{700,780},{730,960},{740,1240},{712,1240},{706,960}}, GRL, Wm)
F({{590,800},{610,780},{622,960},{620,1240},{590,1240},{600,960}}, GRD, Wm)
F({{652,800},{680,800},{706,960},{712,1240},{650,1240},{650,960}}, GRD, Wm)
F({{740,860},{770,960},{800,1060},{830,1240},{742,1240},{736,960}}, GRD, Wm)

--@ chunk 18
wait(3 * 24 * 60)
GRM = pile{{"viridian",1},{"bone black",0.45},{"raw sienna",0.6},{"lead white",0.1}}
PLM = pile{{"bone black",1},{"bone brown",0.8},{"rose madder",0.45},{"lead white",0.15}}
WBM2 = pile{{"raw sienna",1.3},{"burnt sienna",0.5},{"bone brown",0.7},{"lead white",0.4}}
local keepH = ellipse(520, 790, 40, 40) + ellipse(345, 680, 45, 50)
local function F(pts, p, clip) local m = (poly(pts) * clip) - keepH; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
local H = HUSB - HHEAD
F({{360,760},{380,740},{390,960},{384,1220},{356,1220},{364,960}}, PLM, H)
F({{420,780},{440,760},{460,980},{460,1220},{430,1220},{432,980}}, PLM, H)
local Wm = WIFE - WHEAD
F({{610,780},{630,760},{650,900},{648,1240},{620,1240},{624,900}}, GRM, Wm)
F({{680,800},{700,780},{730,960},{740,1240},{712,1240},{706,960}}, GRM, Wm)
F({{545,880},{560,760},{580,700},{596,720},{582,900},{566,1240},{524,1240},{530,1050}}, GRM, Wm)
-- the lit wall strip behind him, a step down
local w = (BACK - FIG:grow(2)) * rect(170, 0, 215, 900) - (ellipse(MX, MY, MR + 18, MR + 18))
work(w, {hand="body", pile=WBM2, coverage=3, fill=true, clip=w, angle=math.pi/2})

--@ chunk 19
wait(3 * 24 * 60)
-- a few narrow highlights on the forward folds, and soft dark creases
local h = brush{kind="filbert", width=3}
local function S(p, pts, pr) h:reload(p, 0.75); h:stroke(pts, {pressure=pr, ramps={0.25, 0.35}}) end
S(GRL, {{560,780},{548,900},{540,1060},{536,1220}}, {0.1, 0.6, 0.4, 0.1})
S(GRL, {{624,800},{628,960},{632,1140}}, {0.1, 0.5, 0.1})
S(GRL, {{694,820},{714,980},{726,1160}}, {0.1, 0.45, 0.1})
S(PLL, {{300,680},{288,860},{278,1060}}, {0.1, 0.55, 0.1})
S(PLL, {{370,780},{372,960},{370,1160}}, {0.1, 0.45, 0.1})
S(GRD, {{600,820},{606,1000},{606,1200}}, {0.1, 0.6, 0.2})
S(PLD, {{404,800},{410,1000},{410,1200}}, {0.1, 0.6, 0.2})

--@ chunk 20
wait(1 * 24 * 60)
RDD = pile{{"red earth",0.8},{"rose madder",0.6},{"bone black",0.6}}
RDL = pile{{"vermilion",1},{"cadmium red",0.3},{"lead white",0.3}}
-- window: leaded panes in a lattice, a mullion, the lower half a little darker (shutters' shade)
local s = brush{kind="round", width=1.6, point=0.6}
for i = 0, 7 do local y0 = 170 + i * 66; s:reload(Q2, 0.7); s:stroke({{20, y0 - 30 + i * 4}, {140, y0}}, {pressure={0.35, 0.35}, ramps={0.02, 0.02}, clip=WIN}) end
for i = 0, 5 do local x = 30 + i * 22; s:reload(Q2, 0.6); s:stroke({{x, 140}, {x, 720}}, {pressure={0.25, 0.25}, ramps={0.02, 0.02}, clip=WIN}) end
local mul = poly({{76,150},{86,152},{86,668},{76,672}}); work(mul, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=mul})
-- the sill and fruit
local sill = poly({{10,704},{146,640},{168,652},{168,668},{18,730}})
work(sill * rect(0,0,2000,2000), {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=sill})
for _, f in ipairs{{56,694,13}, {96,676,12}, {130,660,11}} do
  local o = ellipse(f[1], f[2] - f[3], f[3], f[3]); work(o, {hand="detail", pile=pile{{"Mars orange",1},{"cadmium yellow",0.4},{"red earth",0.2}}, coverage=3.5, fill=true, clip=o})
  local sh = ellipse(f[1] + 4, f[2] - f[3] + 3, f[3] * 0.8, f[3] * 0.85) - ellipse(f[1] - 3, f[2] - f[3] - 3, f[3] * 0.85, f[3] * 0.85)
  work(sh * o, {hand="detail", pile=pile{{"Mars orange",1},{"burnt sienna",0.7}}, coverage=3.5, fill=true, clip=o})
end
-- the bed canopy: tall folds
local bed = BED - FIG:grow(2)
for i, x in ipairs{790, 830, 870, 910, 950, 985} do
  local m = poly({{x - 14, 260}, {x + 6, 250}, {x + 10, 1150}, {x - 12, 1150}}) * bed
  work(m, {hand="detail", pile=(i % 2 == 0) and RDD or RD, coverage=3.5, fill=true, clip=m})
end

--@ chunk 21
wait(2 * 24 * 60)
local h = brush{kind="round", width=2.0, point=0.4}
for _, f in ipairs{{56,694,13}, {96,676,12}, {130,660,11}} do h:reload(pile{{"lead white",2},{"cadmium yellow",0.5}}, 0.8); h:touch(f[1] - 4, f[2] - f[3] - 5, {pressure=0.35}) end
local bed = BED - FIG:grow(2)
local f = brush{kind="filbert", width=4}
for _, x in ipairs{778, 818, 858, 898, 938} do f:reload(RDL, 0.7); f:stroke({{x, 280}, {x + 2, 700}, {x + 3, 1100}}, {pressure={0.1, 0.5, 0.2}, ramps={0.2, 0.3}, clip=bed}) end

--@ chunk 22
wait(1 * 24 * 60)
FLD = pile{{"bone brown",1.5},{"burnt sienna",0.4},{"bone black",0.7}}
-- contact shadows under the hems, falling right (light from the left)
local sh = (ellipse(380, 1236, 150, 16) + ellipse(690, 1250, 170, 16)) - FIG
work(sh, {hand="detail", pile=FLD, coverage=3.5, fill=true, clip=sh})
-- a pair of shoes, bronze-soled pattens with bone straps, one turned
local function shoe(cx, cy, ang, lit)
  local function R(x, y) return {cx + x * math.cos(ang) - y * math.sin(ang), cy + x * math.sin(ang) + y * math.cos(ang)} end
  local sole = poly({R(-34,-8), R(30,-10), R(40,-2), R(30,8), R(-34,8)}, true)
  work(sole, {hand="detail", pile=lit and Q4 or Q3, coverage=3.5, fill=true, clip=sole})
  local edge = poly({R(-34,4), R(34,2), R(36,9), R(-34,10)}); work(edge * sole:grow(2), {hand="detail", pile=Q1, coverage=3.5, fill=true, clip=edge})
  local strap = poly({R(0,-10), R(12,-11), R(14,8), R(2,8)}); work(strap, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=strap})
end
shoe(110, 1222, -0.25, true); shoe(150, 1262, -0.05, false)
local s2 = ellipse(130, 1276, 58, 8) - FIG; work(s2, {hand="detail", pile=FLD, coverage=3, fill=true, clip=s2})
-- the little creature: a round plated body on thin jointed legs, a small bony head with an arc of eyes, looking out at us
local body = ellipse(512, 1270, 34, 22); work(body, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=body})
local top = ellipse(506, 1262, 30, 13) * body; work(top, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=top})
local head = ellipse(478, 1250, 15, 12); work(head, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=head})
local lit = ellipse(474, 1246, 9, 7) * head; work(lit, {hand="detail", pile=B3, coverage=3.5, fill=true, clip=lit})

--@ chunk 23
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.6, point=0.6}
for _, l in ipairs{{{488,1280},{482,1300},{486,1318}}, {{504,1288},{502,1306},{506,1322}}, {{526,1288},{530,1306},{526,1322}}, {{540,1280},{548,1298},{546,1316}}} do
  d:reload(Q1, 0.85); d:stroke(l, {pressure={0.6, 0.5, 0.3}, ramps={0.05, 0.2}})
  d:reload(Q1, 0.8); d:touch(l[2][1], l[2][2], {pressure=0.5})
end
-- plate seams across its back, a lit ridge
for _, x in ipairs{498, 514, 530} do d:reload(Q1, 0.7); d:stroke({{x, 1252}, {x + 2, 1288}}, {pressure={0.35, 0.35}}) end
d:reload(HL, 0.7); d:stroke({{486,1258},{506,1250},{526,1252}}, {pressure={0.1, 0.5, 0.1}})
-- three small eyes on an arc, and a tiny tail
local t = brush{kind="round", width=2.2, point=0.2}
for _, e in ipairs{{468,1250},{474,1246},{481,1244}} do t:reload(EYE, 0.9); t:touch(e[1], e[2], {pressure=0.4}) end
t:reload(B4, 0.8); t:touch(467.5, 1249.5, {pressure=0.15})
d:reload(Q2, 0.8); d:stroke({{544,1266},{556,1256},{562,1246}}, {pressure={0.5, 0.1}})

--@ chunk 24
wait(3 * 24 * 60)
RDM = pile{{"red earth",1},{"rose madder",0.5},{"vermilion",0.3},{"bone black",0.25}}
local bed = BED - FIG:grow(2)
for i, x in ipairs{790, 830, 870, 910, 950, 985} do
  local m = poly({{x - 14, 260}, {x + 6, 250}, {x + 10, 1150}, {x - 12, 1150}}) * bed
  if i % 2 == 0 then work(m, {hand="detail", pile=RDM, coverage=3.5, fill=true, clip=m}) end
end
-- hands restated clean
local wb = poly({{518,770},{540,760},{548,786},{524,794}}); work(wb, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=wb})
for i, J in ipairs{{{520,774},{506,780},{494,790},{486,802}}, {{522,782},{508,792},{498,804},{492,816}}, {{526,790},{514,804},{506,816},{502,828}}} do finger(J, 3.2, {Q5, Q4}) end
local hb = poly({{496,762},{514,758},{518,784},{498,790}}); work(hb, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=hb})
for i, J in ipairs{{{512,764},{528,766},{540,774},{546,786}}, {{514,772},{530,778},{540,790},{544,802}}, {{512,782},{526,792},{534,804},{536,816}}} do finger(J, 3.0, {Q4, Q3}) end
local rb = poly({{334,688},{358,684},{362,712},{338,716}}); work(rb, {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=rb})
for i, J in ipairs{{{336,688},{332,672},{330,656},{330,642}}, {{344,686},{344,668},{345,652},{346,638}}, {{352,686},{356,668},{360,654},{363,642}}, {{358,692},{368,680},{376,670},{382,662}}, {{334,700},{324,690},{316,682},{310,676}}} do finger(J, 3.0, {Q5, Q4}) end

--@ chunk 25
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.7}
local h = brush{kind="round", width=1.3, point=0.7}
-- hands: his knuckle line lit, the gap between their palms dark
h:reload(HL, 0.8); h:stroke({{498,762},{514,758}}, {pressure={0.5, 0.3}})
h:reload(HL, 0.8); h:stroke({{513,764},{528,765},{539,772}}, {pressure={0.5, 0.4, 0.1}})
d:reload(Q1, 0.8); d:stroke({{518,786},{540,794}}, {pressure={0.5, 0.4}})
h:reload(HL, 0.8); h:stroke({{336,688},{356,684}}, {pressure={0.4, 0.3}})
-- head seams and the window's rim of light on the left contours
local function seams(F, clip) for _, f in ipairs(F) do local p = f[1]; for i = 1, #p do d:reload(Q1, 0.7); d:stroke({p[i], p[i % #p + 1]}, {pressure={0.35, 0.35}, ramps={0.05, 0.05}, clip=clip}) end end end
local ek = everywhere()
seams(HF, HHEAD - ellipse(380, 455, 60, 25) - ellipse(418, 525, 20, 16))
seams(WF, WHEAD - ellipse(650, 492, 50, 20) - ellipse(620, 563, 18, 16))
h:reload(B4, 0.8); h:stroke({{360,328},{332,370},{320,430},{318,480}}, {pressure={0.1, 0.6, 0.4, 0.05}, ramps={0.2, 0.3}, clip=HHEAD:grow(1)})
h:reload(B4, 0.8); h:stroke({{636,404},{612,436},{600,480},{598,520}}, {pressure={0.1, 0.55, 0.3, 0.05}, ramps={0.2, 0.3}, clip=WHEAD:grow(1)})

--@ chunk 26
wait(1 * 24 * 60)
local band = HUSB * rect(0, 893, 1000, 15)
local function seg(x0, x1, p) local m = band * rect(x0, 0, x1 - x0, 2000); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m, angle=math.pi/2}) end
seg(230, 500, PL); seg(254, 298, PLL); seg(360, 390, PLM); seg(394, 420, PLD); seg(430, 462, PLM); seg(468, 500, PLD)
-- the raised sleeve, a fold of lit cloth falling from the wrist
local f = brush{kind="filbert", width=5}
f:reload(PLL, 0.8); f:stroke({{338,716},{322,730},{306,760},{300,800}}, {pressure={0.2, 0.6, 0.4, 0.1}, ramps={0.2, 0.3}})
f:reload(PLD, 0.8); f:stroke({{356,716},{350,744},{344,780}}, {pressure={0.2, 0.5, 0.1}, ramps={0.2, 0.3}})

--@ chunk 27
wait(5 * 24 * 60)
print(drying(400, 900))
local band = HUSB * rect(0, 888, 1000, 25)
local function seg(x0, x1, p) local m = band * rect(x0, 0, x1 - x0, 2000); work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m, angle=math.pi/2}) end
seg(230, 254, PL); seg(254, 298, PLL); seg(298, 360, PL); seg(360, 390, PLM); seg(390, 430, PLD); seg(430, 462, PLM); seg(462, 500, PLD)
local dash = HUSB * poly({{362,760},{378,760},{376,1220},{360,1220}}) - band
work(dash, {hand="detail", pile=PLM, coverage=4, fill=true, clip=dash, angle=math.pi/2})

--@ chunk 28
wait(4 * 24 * 60)
local low = HUSB * rect(0, 860, 1000, 400)
work(low, {hand="detail", pile=PL, coverage=4, fill=true, clip=low, angle=math.pi/2})

--@ chunk 29
wait(4 * 24 * 60)
local low = HUSB * rect(0, 860, 1000, 400)
local function F(pts, p) local m = poly(pts) * low; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{262,1000},{280,820},{300,660},{318,680},{300,860},{290,1220},{250,1220}}, PLL)
F({{360,760},{380,740},{390,960},{384,1220},{356,1220},{364,960}}, PLM)
F({{420,780},{440,760},{460,980},{460,1220},{430,1220},{432,980}}, PLM)
F({{392,760},{410,780},{420,1220},{396,1220}}, PLD)
F({{462,700},{490,820},{500,980},{480,1220},{466,1220},{474,980},{466,800}}, PLD)

--@ chunk 30
wait(1 * 24 * 60)
local seam = (BACK - FIG:grow(2)) * rect(378, 0, 20, 900) - ellipse(MX, MY, MR + 18, MR + 18)
work(seam * rect(0,0,388,2000), {hand="detail", pile=WBM2, coverage=4, fill=true, clip=seam, angle=math.pi/2})
work(seam * rect(388,0,100,2000), {hand="detail", pile=WDK, coverage=4, fill=true, clip=seam, angle=math.pi/2})

--@ chunk 31
wait(2 * 24 * 60)
-- above the mirror, where van Eyck signed, a line of fold notation: a room-glyph, a bridge, a smaller turned copy, and a dot
local g = brush{kind="round", width=1.5, point=0.7}
local P = pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.3}}
local function hex(x, y, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {x + r * math.cos(a), y + r * math.sin(a)} end return t end
local x = 452
for k, r in ipairs{9, 7, 5.6, 4.4, 3.4, 2.6} do
  g:reload(Q4, 0.75); g:stroke(hex(x, 214, r, 0.35 * k), {pressure={0.4, 0.4}, ramps={0.05, 0.05}})
  if k < 6 then g:reload(Q4, 0.7); g:stroke({{x + r, 214}, {x + r + 6, 209}, {x + r + 12, 214}}, {pressure={0.35, 0.35}}) end
  x = x + r * 2 + 13
end
local t = brush{kind="round", width=2.0, point=0.2}; t:reload(Q4, 0.8); t:touch(x - 4, 214, {pressure=0.4})
-- chandelier: lit sides of the arms and body
local h = brush{kind="round", width=1.6, point=0.7}
for _, a in ipairs{{-90, 18}, {-55, 28}, {-18, 32}} do
  local cx, cy = 500, 120
  h:reload(HL, 0.8); h:stroke({{cx, cy}, {cx + a[1] * 0.4, cy + a[2] + 6 - 2}, {cx + a[1] * 0.85, cy + a[2] - 6}}, {pressure={0.3, 0.6, 0.1}})
end

--@ chunk 32
wait(2 * 24 * 60)
FLL = pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",0.4},{"lead white",0.45}}
local pool = poly({{40,1110},{160,1010},{300,1040},{240,1200},{60,1240}}) - FIG:grow(2) - ellipse(130, 1240, 75, 45)
work(pool, {hand="body", pile=FLL, coverage=2.6, fill=true, clip=pool, angle=0, edge="soft"})
-- long shadows thrown to the right
local s1 = poly({{420,1225},{600,1260},{700,1300},{520,1300},{360,1250}}) - FIG:grow(1) - ellipse(512, 1290, 50, 45)
local s2 = poly({{800,1235},{960,1270},{1000,1310},{860,1310},{760,1260}}) - FIG:grow(1) - BED
work(s1 + s2, {hand="body", pile=FLD, coverage=2.6, fill=true, clip=s1 + s2, angle=0, edge="soft"})

--@ chunk 33
wait(2 * 24 * 60)
-- floor seams restated over the pool and shadows
local VP = {500, 520}
local fl = FLOOR - FIG:grow(3) - BED - ellipse(512, 1275, 48, 34) - ellipse(130, 1240, 75, 45)
local s = brush{kind="round", width=1.6, point=0.6}
for i = -9, 9 do local xb = 500 + i * 120; local t = (900 - VP[2]) / (1333 - VP[2]); local xt = VP[1] + (xb - VP[1]) * t
  s:reload(WD, 0.7); s:stroke({{xt, 902}, {xb, 1333}}, {pressure={0.3, 0.5}, ramps={0.05, 0.05}, clip=fl}) end
for _, y in ipairs{960, 1040, 1150, 1290} do s:reload(WD, 0.55); s:stroke({{0, y}, {1000, y}}, {pressure={0.22, 0.22}, ramps={0.05, 0.05}, clip=fl}) end
-- fur edge on the husband's robe: a band of short soft dark-brown touches along the hem and the front opening
FUR = pile{{"bone brown",1.2},{"burnt sienna",0.5},{"raw sienna",0.4},{"lead white",0.15}}
local fur = (HUSB - HUSB:shrink(7)) * rect(0, 1180, 1000, 100) + ribbon({{392,580},{402,700},{412,780}}, 9)
stipple(fur * HUSB, {pile=FUR, width=2.4, coverage=1.3, cluster=0.4, drag={3, math.pi / 2}})

--@ chunk 34
wait(4 * 24 * 60)
SHOES = ellipse(110, 1220, 44, 15) + ellipse(152, 1262, 44, 13) + ellipse(130, 1278, 60, 9)
local area = (poly({{20,1100},{170,995},{320,1030},{260,1215},{40,1260}}) + ellipse(130, 1240, 80, 50)) * FLOOR - FIG:grow(2) - SHOES
work(area, {hand="body", pile=FL1, coverage=3.5, fill=true, clip=area, angle=0})

--@ chunk 35
wait(4 * 24 * 60)
local area = poly({{20,1100},{170,995},{320,1030},{260,1215},{40,1260}}) * FLOOR - FIG:grow(2) - SHOES
work(area, {hand="scumble", pile=FLL, coverage=0.7, clip=area, pressure={0.15, 0.4}, load=0.4})
local VP = {500, 520}
local fl = FLOOR - FIG:grow(3) - BED - ellipse(512, 1275, 48, 34) - SHOES
local s = brush{kind="round", width=1.6, point=0.6}
for i = -9, 0 do local xb = 500 + i * 120; local t = (900 - VP[2]) / (1333 - VP[2]); local xt = VP[1] + (xb - VP[1]) * t
  s:reload(WD, 0.7); s:stroke({{xt, 902}, {xb, 1333}}, {pressure={0.3, 0.5}, ramps={0.05, 0.05}, clip=fl * rect(0, 0, 400, 2000)}) end
for _, y in ipairs{1040, 1150, 1290} do s:reload(WD, 0.55); s:stroke({{0, y}, {400, y}}, {pressure={0.22, 0.22}, ramps={0.05, 0.05}, clip=fl}) end

--@ chunk 36
wait(5 * 24 * 60)
local function shoem(cx, cy, ang)
  local function R(x, y) return {cx + x * math.cos(ang) - y * math.sin(ang), cy + x * math.sin(ang) + y * math.cos(ang)} end
  return poly({R(-35,-12), R(31,-12), R(41,-2), R(37,11), R(-35,11)}, true)
end
SHOEM = shoem(110, 1222, -0.25) + shoem(150, 1262, -0.05)
local area = ((poly({{0,1080},{180,980},{340,1020},{280,1230},{30,1290}}) + ellipse(130, 1240, 90, 55)) * FLOOR) - FIG:grow(2) - SHOEM
work(area, {hand="detail", pile=FL1, coverage=4, fill=true, clip=area, angle=0})

--@ chunk 37
wait(4 * 24 * 60)
local VP = {500, 520}
local fl = (FLOOR - FIG:grow(3) - SHOEM:grow(1)) * rect(0, 960, 420, 400)
local s = brush{kind="round", width=1.6, point=0.6}
for i = -9, 0 do local xb = 500 + i * 120; local t = (900 - VP[2]) / (1333 - VP[2]); local xt = VP[1] + (xb - VP[1]) * t
  s:reload(WD, 0.7); s:stroke({{xt, 902}, {xb, 1333}}, {pressure={0.3, 0.5}, ramps={0.05, 0.05}, clip=fl}) end
for _, y in ipairs{1040, 1150, 1290} do s:reload(WD, 0.55); s:stroke({{0, y}, {420, y}}, {pressure={0.22, 0.22}, ramps={0.05, 0.05}, clip=fl}) end
local sh = ellipse(156, 1278, 50, 7) - SHOEM; work(sh, {hand="detail", pile=FLD, coverage=3.5, fill=true, clip=sh})
local sh2 = ellipse(116, 1236, 44, 6) - SHOEM; work(sh2, {hand="detail", pile=FLD, coverage=3.5, fill=true, clip=sh2})

--@ chunk 38
wait(2 * 24 * 60)
local wall = BACK - BED - FIG:grow(3) - ellipse(MX, MY, MR + 18, MR + 18) - rect(280, 0, 440, 230)
local s = brush{kind="round", width=1.8, point=0.6}
for _, x in ipairs{560, 660} do
  s:reload(Q1, 0.75); s:stroke({{x, 0}, {x, 900}}, {pressure={0.4, 0.4}, ramps={0.02, 0.02}, clip=wall})
  s:reload(WBM, 0.6); s:stroke({{x + 2.5, 0}, {x + 2.5, 900}}, {pressure={0.22, 0.22}, ramps={0.02, 0.02}, clip=wall})
end
-- the canopy's bronze rail, lit along its top
local rail = poly({{756,292},{1000,232},{1000,250},{758,308}})
work(rail, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=rail})
local h = brush{kind="round", width=1.6, point=0.7}
h:reload(HL, 0.8); h:stroke({{760,294},{880,264},{1000,234}}, {pressure={0.6, 0.4, 0.1}})
-- the stray sliver at the shoe
local sl = (SHOEM:grow(4) - SHOEM) * rect(0, 1190, 200, 40)
work(sl, {hand="detail", pile=FL1, coverage=3.5, fill=true, clip=sl})
