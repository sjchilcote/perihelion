-- easel session "last_testator": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={22,20}, seed=163,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.25}}, um=35, apply="roller"}}}

--@ chunk 2
function TX(p) return {330 + (p[1] - 372) * 0.62, 260 + (p[2] - 150) * 0.62} end
function TP(pts) local t = {} for i, p in ipairs(pts) do t[i] = TX(p) end return t end
SKULL = poly(TP({{372,420},{384,320},{430,232},{520,176},{640,150},{748,166},{800,226},{786,298},{720,358},{650,416},{610,510},{590,610},{548,690},{486,724},{432,700},{398,630},{378,530}}), true)
WIN = poly({{30,70},{330,70},{330,640},{30,640}})
ROBE = poly({{250,1250},{280,1000},{330,800},{390,690},{470,660},{560,690},{620,780},{660,950},{700,1250}}, true)
DOC = poly({{660,1250},{670,900},{690,640},{720,540},{780,500},{850,520},{880,600},{900,900},{920,1250}}, true)
DOCH = ellipse(790, 400, 62, 84)
DESK = poly({{0,880},{620,850},{640,910},{0,960}})
FIG = SKULL + ROBE + DOC + DOCH
BG1 = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.3}}
BGM = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"raw sienna",0.2}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"burnt sienna",0.5},{"lead white",0.25}}
local bg = everywhere() - FIG:grow(3) - WIN - DESK
local function ring(r0, r1) return bg * (ellipse(180, 340, r1, r1) - ellipse(180, 340, r0, r0)) end
work(ring(0, 360), {hand="body", pile=BG2, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(ring(360, 600), {hand="body", pile=BGM, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(ring(600, 2000), {hand="body", pile=BG1, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
blend(ring(330, 390), {angle=-0.7}); blend(ring(570, 630), {angle=-0.7})
-- the window and the Sun, graded rings round a white core, laid wet together
G1 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
G2 = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}}
G3 = pile{{"zinc white",3},{"lemon chrome",0.12}}
local function wr(r0, r1) return WIN * (ellipse(180, 330, r1, r1) - ellipse(180, 330, r0, r0)) end
work(wr(210, 600), {hand="body", pile=G1, coverage=3.5, fill=true, clip=WIN, angle=math.pi/2})
work(wr(140, 210), {hand="body", pile=G2, coverage=3.5, fill=true, clip=WIN, angle=math.pi/2})
work(wr(0, 140), {hand="body", pile=G3, coverage=3.5, fill=true, clip=WIN, angle=math.pi/2})
blend(wr(195, 225), {angle=0}); blend(wr(125, 155), {angle=0})

--@ chunk 3
RB = pile{{"bone black",1.1},{"bone brown",0.9},{"rose madder",0.15},{"raw sienna",0.1}}
DOCB = pile{{"bone brown",1.4},{"bone black",0.8},{"burnt sienna",0.2}}
DSK = pile{{"bone brown",1.4},{"burnt sienna",0.6},{"raw sienna",0.4},{"bone black",0.3}}
work(ROBE - SKULL, {hand="body", pile=RB, coverage=3.5, fill=true, clip=ROBE - SKULL, angle=math.pi/2, tool="filbert 9"})
work(DOC, {hand="body", pile=DOCB, coverage=3.5, fill=true, clip=DOC, angle=math.pi/2, tool="filbert 9"})
work(DOCH, {hand="body", pile=DOCB, coverage=3.5, fill=true, clip=DOCH})
work(DESK - ROBE, {hand="body", pile=DSK, coverage=3.5, fill=true, clip=DESK - ROBE, angle=0, tool="filbert 9"})
work(SKULL, {hand="body", pile=pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}, coverage=3.5, fill=true, clip=SKULL})

--@ chunk 4
wait(4 * 24 * 60)
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.2},{"raw sienna",1.2},{"bone brown",1.2},{"lead white",0.15}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",0.8},{"yellow ochre",0.8},{"lead white",0.2}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.45}}
B1 = pile{{"raw sienna",1},{"bone brown",0.8},{"lead white",0.9},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.8},{"bone brown",0.4},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.7},{"raw sienna",0.4}}
B4 = pile{{"lead white",3},{"yellow ochre",0.45},{"cadmium yellow",0.1}}
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
HFo = {
  {{{384,320},{430,232},{480,250},{450,340},{400,372}}, B4},
  {{{430,232},{520,176},{560,204},{500,262},{480,250}}, B3},
  {{{520,176},{640,150},{650,192},{560,206}}, B2},
  {{{640,150},{748,166},{730,212},{650,192}}, B1},
  {{{748,166},{800,226},{786,298},{740,272},{730,212}}, BD},
  {{{480,250},{560,206},{650,192},{730,212},{740,272},{680,302},{580,302},{500,300}}, B1},
  {{{500,300},{580,302},{680,302},{740,272},{786,298},{720,358},{650,416},{560,382}}, BD},
  {{{376,402},{400,372},{450,340},{500,300},{560,382},{600,440},{560,452},{480,432},{410,442}}, B3},
  {{{372,452},{410,442},{480,432},{500,522},{460,602},{400,622},{378,530}}, Q5},
  {{{480,432},{560,452},{600,440},{620,500},{580,562},{500,522}}, Q4},
  {{{600,440},{650,416},{612,510},{596,602},{580,562},{620,500}}, Q2},
  {{{400,622},{460,602},{500,642},{490,702},{450,714},{420,682}}, B2},
  {{{460,602},{500,522},{580,562},{596,602},{562,682},{500,642}}, Q3},
  {{{450,714},{490,702},{500,642},{562,682},{548,692},{486,726}}, Q1},
}
HF = {}
for i, f in ipairs(HFo) do HF[i] = {TP(f[1]), f[2]}; local m = poly(HF[i][1]) * SKULL:grow(2); work(m, {hand="detail", pile=f[2], coverage=4, fill=true, clip=m}) end

--@ chunk 5
wait(3 * 24 * 60)
NECK = poly(TP({{450,690},{590,620},{640,760},{620,860},{430,860},{420,760}})) - SKULL
for i, y in ipairs{630, 650, 670, 690, 710} do
  local band = NECK * poly({{300, y + 6}, {500, y - 10}, {500, y + 10}, {300, y + 26}})
  work(band * rect(0,0,410,2000), {hand="detail", pile=(i % 2 == 0) and Q4 or Q3, coverage=4, fill=true, clip=band})
  work(band * rect(410,0,200,2000), {hand="detail", pile=Q1, coverage=4, fill=true, clip=band})
end
COLL = poly({{300,700},{360,668},{420,660},{480,676},{520,710},{470,730},{380,736}}, true)
work(COLL * rect(0,0,400,2000), {hand="detail", pile=pile{{"bone black",0.9},{"bone brown",0.9},{"rose madder",0.2},{"lead white",0.35},{"raw sienna",0.2}}, coverage=4, fill=true, clip=COLL})
work(COLL * rect(400,0,300,2000), {hand="detail", pile=RB, coverage=4, fill=true, clip=COLL})

--@ chunk 6
wait(2 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local function bez(t) local a, b, c = TX({396,436}), TX({482,362}), TX({598,418}); local u = 1 - t; return {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]} end
local t, gap = 0.04, 0.27
local d = brush{kind="round", width=1.0, point=0.8}
local tb = brush{kind="round", width=1.6, point=0.2}
for k = 1, 7 do
  local p = bez(t); local s = 0.62 * (1 - 0.07 * (k - 1))
  local x, y, rx, ry = p[1], p[2] + 1, 10 * s, 7.5 * s
  local sock = ellipse(x, y, rx + 3, ry + 3); work(sock, {hand="detail", pile=BD, coverage=4, fill=true, clip=sock})
  local closed = (k == 3 or k == 6)
  if not closed then
    local e = ellipse(x, y, rx, ry); work(e, {hand="detail", pile=EYE, coverage=4, fill=true, clip=e})
    local lid = ellipse(x, y, rx + 3, ry + 3) * rect(0, 0, 2000, y - ry * 0.05); work(lid, {hand="detail", pile=B1, coverage=4, fill=true, clip=lid})
    tb:reload(pile{{"Mars orange",1},{"raw sienna",0.8}}, 0.7); tb:touch(x + rx * 0.2, y + ry * 0.4, {pressure=0.2})
  else
    local lid = ellipse(x, y, rx + 2, ry + 2); work(lid, {hand="detail", pile=B1, coverage=4, fill=true, clip=lid})
    d:reload(Q1, 0.8); d:stroke({{x - rx, y + 1}, {x, y + 2}, {x + rx, y + 1}}, {pressure={0.4, 0.5, 0.3}})
  end
  t = t + gap; gap = gap * 0.72
end
-- mouth: the small closed pleated plate
MOUTH = poly(TP({{412,664},{424,646},{446,638},{470,640},{488,652},{490,668},{474,688},{448,694},{424,686}}), true)
work(MOUTH * rect(0,0,TX({450,0})[1],2000), {hand="detail", pile=B2, coverage=4, fill=true, clip=MOUTH})
work(MOUTH * rect(TX({450,0})[1],0,500,2000), {hand="detail", pile=B1, coverage=4, fill=true, clip=MOUTH})

--@ chunk 7
wait(3 * 24 * 60)
-- neck filled solid from chin to robe, rings over it after
local nk = poly({{318,612},{420,590},{450,640},{456,700},{320,710},{300,660}}) - SKULL:shrink(2)
work(nk * rect(0,0,400,2000), {hand="detail", pile=Q3, coverage=4.5, fill=true, clip=nk})
work(nk * rect(400,0,200,2000), {hand="detail", pile=Q1, coverage=4.5, fill=true, clip=nk})
COLL2 = poly({{280,712},{340,676},{420,668},{486,684},{520,716},{470,744},{360,748}})
work(COLL2 * rect(0,0,400,2000), {hand="detail", pile=pile{{"bone black",1},{"bone brown",0.9},{"raw sienna",0.3},{"lead white",0.25}}, coverage=4.5, fill=true, clip=COLL2})
work(COLL2 * rect(400,0,300,2000), {hand="detail", pile=RB, coverage=4.5, fill=true, clip=COLL2})

--@ chunk 8
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.8}
-- neck rings as seams
for i, y in ipairs{622, 640, 658, 676, 694} do d:reload(Q1, 0.7); d:stroke({{316, y + 4}, {380, y - 4}, {450, y - 10}}, {pressure={0.35, 0.35}, clip=nk or (poly({{318,612},{420,590},{450,640},{456,700},{320,710},{300,660}}) - SKULL:shrink(2))}) end
-- eyes bigger and darker so they read at this scale; two of seven shut
local function bez(t) local a, b, c = TX({396,436}), TX({482,362}), TX({598,418}); local u = 1 - t; return {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]} end
local t, gap = 0.04, 0.27
local tb = brush{kind="round", width=1.8, point=0.2}
EYES = {}
for k = 1, 7 do
  local p = bez(t); local s = 0.8 * (1 - 0.07 * (k - 1))
  local x, y, rx, ry = p[1], p[2] + 1, 10 * s, 7.5 * s
  EYES[k] = {x, y, rx, ry}
  local sock = ellipse(x, y, rx + 3.5, ry + 3.5); work(sock, {hand="detail", pile=Q1, coverage=4.5, fill=true, clip=sock})
  if k == 3 or k == 6 then
    local lid = ellipse(x, y, rx + 1.5, ry + 1.5); work(lid, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=lid})
    d:reload(Q1, 0.85); d:stroke({{x - rx, y + 1}, {x, y + 2.5}, {x + rx, y + 1}}, {pressure={0.45, 0.55, 0.35}})
  else
    local e = ellipse(x, y + 0.5, rx, ry); work(e, {hand="detail", pile=EYE, coverage=4.5, fill=true, clip=e})
    local lid = ellipse(x, y, rx + 3.5, ry + 3.5) * rect(0, 0, 2000, y - ry * 0.15); work(lid, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=lid})
    tb:reload(pile{{"Mars orange",1},{"raw sienna",0.8}}, 0.75); tb:touch(x + rx * 0.2, y + ry * 0.35, {pressure=0.22})
    tb:reload(B4, 0.8); tb:touch(x - rx * 0.4, y + ry * 0.05, {pressure=0.16})
  end
  t = t + gap; gap = gap * 0.72
end

--@ chunk 9
wait(2 * 24 * 60)
local cut = poly({{290,590},{352,590},{348,640},{360,712},{290,716}}) - SKULL:grow(1)
work(cut * WIN, {hand="detail", pile=G1, coverage=4.5, fill=true, clip=cut * WIN})
work(cut - WIN, {hand="detail", pile=BG2, coverage=4.5, fill=true, clip=cut - WIN})
-- the tablet on the desk, its face lit by the Sun
TAB = poly({{150,846},{340,830},{372,880},{176,900}})
work(TAB, {hand="detail", pile=B3, coverage=4.5, fill=true, clip=TAB})
local tedge = poly({{176,900},{372,880},{374,890},{178,910}}); work(tedge, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=tedge})
local dl = poly({{0,872},{150,862},{176,900},{0,920}}); work(dl, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.3},{"lead white",0.25}}, coverage=4.5, fill=true, clip=dl})

--@ chunk 10
wait(2 * 24 * 60)
function seg(a, b, w0, w1) local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}}) end
local d = brush{kind="round", width=1.2, point=0.8}
function finger(J, w, P)
  for k = 1, #J - 1 do local m = seg(J[k], J[k+1], w * (1 - 0.12 * (k - 1)), w * (1 - 0.12 * k) * 0.92); work(m, {hand="detail", pile=P[(k % 2) + 1], coverage=4.5, fill=true, clip=m}) end
  for k = 2, #J - 1 do d:reload(Q1, 0.85); d:touch(J[k][1], J[k][2], {pressure=0.4}) end
end
-- sleeves reaching from the robe to the desk, threadbare cloth
local s1 = ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}); work(s1, {hand="detail", pile=RB, coverage=4.5, fill=true, clip=s1})
local s2 = ribbon({{380,800},{372,840},{360,872}}, {40, 34, 30}); work(s2, {hand="detail", pile=RB, coverage=4.5, fill=true, clip=s2})
-- the writing hand: back plate, fingers pinching a bone stylus down to the tablet
local hb = poly({{238,840},{276,826},{290,856},{252,872}}); work(hb, {hand="detail", pile=Q4, coverage=4.5, fill=true, clip=hb})
for i, J in ipairs{{{240,846},{222,850},{208,858},{200,868},{198,878}}, {{244,856},{226,862},{214,872},{210,882}}, {{250,866},{236,874},{228,884},{226,892}}} do finger(J, 4.0 - i * 0.3, {Q5, Q4}) end
local st = brush{kind="round", width=3.0, point=0.5}
st:reload(B3, 0.9); st:stroke({{232,820},{214,850},{200,876}}, {pressure={0.8, 0.6, 0.1}, ramps={0.05, 0.5}})
-- the other hand resting flat at the tablet's far edge, its fingers long and still
local hb2 = poly({{330,846},{364,840},{376,866},{340,874}}); work(hb2, {hand="detail", pile=Q3, coverage=4.5, fill=true, clip=hb2})
for i, J in ipairs{{{332,850},{312,852},{294,856},{280,862},{270,868}}, {{334,860},{314,864},{298,870},{286,876}}, {{338,868},{320,874},{306,882},{296,888}}} do finger(J, 3.6 - i * 0.3, {Q4, Q3}) end

--@ chunk 11
wait(2 * 24 * 60)
local function F(pts, p, clip) local m = poly(pts); if clip then m = m * clip end; work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
local H = DOCH:grow(1)
F({{720,330},{760,316},{780,400},{740,470},{722,430}}, Q3, H)
F({{760,316},{830,320},{860,380},{820,420},{780,400}}, Q2, H)
F({{780,400},{820,420},{860,380},{856,450},{820,484},{760,484},{740,470}}, Q1, H)
F({{740,300},{790,312},{830,320},{820,310},{780,300}}, Q2, H)
-- the docent's face-plate turned toward the Testator, and its lens catching the Sun
local face = ellipse(744, 410, 20, 34) * H
work(face, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=face})
local lens = ellipse(738, 398, 7, 8); work(lens, {hand="detail", pile=pile{{"bone black",1},{"viridian",0.3}}, coverage=4.5, fill=true, clip=lens})
local glint = ellipse(737, 397, 3, 3); work(glint, {hand="detail", pile=pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.5}}, coverage=4.5, fill=true, clip=glint})
-- the ruff, pleated, its lit edge toward the window
local ruff = ellipse(790, 500, 92, 22) - DOCH
local cx, cy = 790, 500
for k = 0, 15 do local a0, a1 = 2 * math.pi * k / 16, 2 * math.pi * (k + 1) / 16
  local w = poly({{cx, cy}, {cx + 101 * math.cos(a0), cy + 24 * math.sin(a0)}, {cx + 101 * math.cos(a1), cy + 24 * math.sin(a1)}}) * ruff
  local lit = -math.cos((a0 + a1) / 2)
  work(w, {hand="detail", pile=(lit > 0.3) and ((k % 2 == 0) and B2 or B1) or ((k % 2 == 0) and BD or Q1), coverage=4.5, fill=true, clip=w}) end

--@ chunk 12
wait(2 * 24 * 60)
DRB = pile{{"bone black",1.2},{"bone brown",0.8},{"ultramarine blue",0.15}}
DRL = pile{{"bone black",0.9},{"bone brown",0.9},{"raw sienna",0.3},{"lead white",0.2}}
local body = DOC - ellipse(790, 500, 92, 22) - ROBE
work(body, {hand="detail", pile=DRB, coverage=4.5, fill=true, clip=body})
local lit = body * poly({{660,520},{740,520},{720,700},{700,1250},{650,1250}})
work(lit, {hand="detail", pile=DRL, coverage=4.5, fill=true, clip=lit})
-- the outlines left by the dead-colour masks lost into the dark
local ring = (DOC:grow(4) - DOC:shrink(3)) - ROBE - DOCH:grow(2) - ellipse(790, 500, 92, 22)
work(ring, {hand="detail", pile=BG1, coverage=4.5, fill=true, clip=ring})

--@ chunk 13
wait(2 * 24 * 60)
local keep = MOUTH:grow(1)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2], e[3] + 4, e[4] + 4) end
local clip = SKULL - keep
local s = brush{kind="round", width=1.4, point=0.6}
for _, f in ipairs(HF) do local p = f[1]; for i = 1, #p do s:reload(Q1, 0.75); s:stroke({p[i], p[i % #p + 1]}, {pressure={0.38, 0.38}, ramps={0.05, 0.05}, clip=clip}) end end
-- cracks: jagged, branching, across the bone vault, each with a pale lip on its lower side
local c = brush{kind="round", width=1.8, point=0.6}
local l = brush{kind="round", width=1.0, point=0.8}
for _, cr in ipairs{
  {{420,300},{438,288},{446,296},{466,276},{478,282},{500,262},{520,258}},
  {{560,236},{572,250},{566,262},{584,276},{596,272},{610,292}},
  {{470,282},{462,300},{470,316}},
} do
  c:reload(pile{{"bone black",1},{"bone brown",1}}, 0.85); c:stroke(cr, {pressure={0.2, 0.6, 0.6, 0.5, 0.2}, ramps={0.1, 0.2}, clip=clip})
  local lip = {} for i, p in ipairs(cr) do lip[i] = {p[1] - 0.8, p[2] + 1.8} end
  l:reload(B4, 0.7); l:stroke(lip, {pressure={0.1, 0.4, 0.1}, clip=clip})
end
-- the Sun's thick rim of light along the front of the skull and the lit jaw
local RIM = pile{{"lead white",3},{"cadmium yellow",0.35},{"Mars orange",0.08}}
local r = brush{kind="filbert", width=4}
r:reload(RIM, 1.0); r:stroke({TX({430,236}), TX({388,312}), TX({376,402}), TX({372,452})}, {pressure={0.3, 0.8, 0.7, 0.2}, ramps={0.2, 0.3}, clip=SKULL:grow(1)})
r:reload(RIM, 0.9); r:stroke({TX({378,530}), TX({398,630}), TX({420,682})}, {pressure={0.2, 0.6, 0.1}, ramps={0.2, 0.3}, clip=SKULL:grow(1)})

--@ chunk 14
wait(2 * 24 * 60)
local r = poly({{276,640},{352,640},{352,724},{276,724}}) - SKULL:grow(1) - COLL2
work(r, {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=r})
-- neck: a narrow column of chitin rings from jaw to collar, the near side in shadow
local nk = poly({{352,616},{420,600},{440,640},{438,676},{350,684}}) - SKULL:shrink(1)
work(nk * rect(0,0,392,2000), {hand="detail", pile=Q3, coverage=4.5, fill=true, clip=nk})
work(nk * rect(392,0,200,2000), {hand="detail", pile=Q1, coverage=4.5, fill=true, clip=nk})

--@ chunk 15
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.7}
for _, y in ipairs{628, 644, 660} do d:reload(Q1, 0.8); d:stroke({{354, y + 4}, {400, y - 2}, {436, y - 6}}, {pressure={0.4, 0.4}}) end
-- mouth: dark closed seam and three fold creases, no light line
local m = MOUTH
local a, b = TX({414,668}), TX({488,664})
d:reload(Q1, 0.85); d:stroke({a, {(a[1] + b[1]) / 2, a[2] + 1}, b}, {pressure={0.5, 0.55, 0.4}, clip=m:grow(0.5)})
for _, x in ipairs{428, 446, 464} do local p0, p1 = TX({x, 646}), TX({x - 1, 686}); d:reload(BD, 0.6); d:stroke({p0, p1}, {pressure={0.1, 0.35, 0.1}, clip=m}) end
-- the brow crest over the eye arc, so the eyes sit under hoods rather than on the surface
local function bez(t) local p0, p1, p2 = TX({390,418}), TX({482,346}), TX({600,400}); local u = 1 - t; return {u*u*p0[1] + 2*u*t*p1[1] + t*t*p2[1], u*u*p0[2] + 2*u*t*p1[2] + t*t*p2[2]} end
local top, bot = {}, {}
for i = 0, 10 do local p = bez(i / 10); top[#top+1] = {p[1], p[2] - 4}; bot[#bot+1] = {p[1], p[2] + 2} end
local crest = {} for _, p in ipairs(top) do crest[#crest+1] = p end; for i = #bot, 1, -1 do crest[#crest+1] = bot[i] end
local cm = poly(crest) * SKULL
work(cm * rect(0,0,330,2000), {hand="detail", pile=B4, coverage=4.5, fill=true, clip=cm})
work(cm * rect(330,0,300,2000), {hand="detail", pile=B2, coverage=4.5, fill=true, clip=cm})

--@ chunk 16
wait(3 * 24 * 60)
-- the whole throat region reset: background left of the neck, dark robe-collar below, then a narrow neck
local reg = poly({{276,600},{540,600},{540,770},{276,770}}) - SKULL:grow(1) - ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}) - ribbon({{380,800},{372,840},{360,872}}, {40, 34, 30})
work(reg, {hand="detail", pile=RB, coverage=4.5, fill=true, clip=reg})
local leftbg = reg * poly({{276,600},{340,600},{330,690},{276,700}})
work(leftbg, {hand="detail", pile=BG1, coverage=4.5, fill=true, clip=leftbg})

--@ chunk 17
wait(3 * 24 * 60)
NK = poly({{350,620},{418,598},{430,640},{424,690},{348,700}}) - SKULL:shrink(1)
work(NK * rect(0,0,392,2000), {hand="detail", pile=Q3, coverage=4.5, fill=true, clip=NK})
work(NK * rect(392,0,200,2000), {hand="detail", pile=Q1, coverage=4.5, fill=true, clip=NK})
-- a heavy worn collar folded round the neck's base, its fold lit on the window side
local col = poly({{318,700},{352,684},{424,686},{470,700},{450,730},{360,734}}, true)
work(col * rect(0,0,380,2000), {hand="detail", pile=pile{{"bone black",0.9},{"bone brown",0.9},{"raw sienna",0.35},{"lead white",0.3}}, coverage=4.5, fill=true, clip=col})
work(col * rect(380,0,200,2000), {hand="detail", pile=RB, coverage=4.5, fill=true, clip=col})

--@ chunk 18
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.7}
for _, y in ipairs{632, 650, 668} do d:reload(Q1, 0.8); d:stroke({{352, y + 4}, {392, y - 1}, {424, y - 4}}, {pressure={0.4, 0.4}, clip=NK}) end

--@ chunk 19
wait(3 * 24 * 60)
local col = poly({{318,700},{352,684},{424,686},{470,700},{450,730},{360,734}}, true)
local reg = (poly({{270,594},{545,594},{545,775},{270,775}}) - SKULL:grow(1) - ROBE - NK - col - WIN) - ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32})
local function ring(r0, r1) return reg * (ellipse(180, 340, r1, r1) - ellipse(180, 340, r0, r0)) end
work(ring(0, 360), {hand="detail", pile=BG2, coverage=4.5, fill=true, clip=reg})
work(ring(360, 600), {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=reg})
blend(ring(345, 375), {angle=-0.7})
-- robe top, restored under the collar
local rt = (ROBE * rect(0, 594, 2000, 180)) - col - NK
work(rt, {hand="detail", pile=RB, coverage=4.5, fill=true, clip=rt})

--@ chunk 20
wait(2 * 24 * 60)
local notch = WIN * poly({{270,590},{335,590},{335,645},{270,645}}) - SKULL:grow(1)
work(notch, {hand="detail", pile=G1, coverage=4.5, fill=true, clip=notch})
-- the robe: a few heavy threadbare folds, lit only near the light; the mask outline lost
RBL2 = pile{{"bone black",0.8},{"bone brown",0.9},{"raw sienna",0.35},{"lead white",0.3},{"rose madder",0.1}}
local rob = ROBE - SKULL - poly({{318,700},{352,684},{424,686},{470,700},{450,730},{360,734}}, true)
local function F(pts, p) local m = poly(pts) * rob; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{280,1000},{310,880},{350,760},{380,740},{360,900},{330,1250},{250,1250}}, RBL2)
F({{410,760},{440,750},{450,1000},{440,1250},{410,1250},{420,1000}}, RBL2)
local edge = (ROBE:grow(3) - ROBE:shrink(2)) - SKULL:grow(2) - DOC - DESK
local function ring(r0, r1) return edge * (ellipse(180, 340, r1, r1) - ellipse(180, 340, r0, r0)) end
work(ring(360, 600), {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=edge})
work(ring(600, 2000), {hand="detail", pile=BG1, coverage=4.5, fill=true, clip=edge})
-- threadbare: a few worn pale patches where the weave shows, low on the lit sleeve
stipple(poly({{290,800},{340,780},{330,840},{290,850}}) * ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}), {pile=RBL2, width=1.4, coverage=0.5, cluster=0.5})

--@ chunk 21
wait(2 * 24 * 60)
-- docent: the mask outline lost into the dark, its near edge lit faintly by the Sun
local edge = (DOC:grow(3) - DOC:shrink(2) + DOCH:grow(3) - DOCH:shrink(2)) - ellipse(790, 500, 92, 22) - ROBE
local function ring(r0, r1) return edge * (ellipse(180, 340, r1, r1) - ellipse(180, 340, r0, r0)) end
work(ring(360, 600), {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=edge})
work(ring(600, 2000), {hand="detail", pile=BG1, coverage=4.5, fill=true, clip=edge})
local h = brush{kind="round", width=2.0, point=0.6}
h:reload(pile{{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.5}}, 0.75); h:stroke({{730,330},{722,380},{726,440},{740,476}}, {pressure={0.1, 0.5, 0.4, 0.05}, clip=DOCH})

--@ chunk 22
wait(3 * 24 * 60)
RBQ = pile{{"bone black",1},{"bone brown",0.9},{"rose madder",0.15},{"raw sienna",0.2},{"lead white",0.1}}
local rob = ROBE - SKULL - poly({{318,700},{352,684},{424,686},{470,700},{450,730},{360,734}}, true)
local function F(pts, p) local m = poly(pts) * rob; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{280,1000},{310,880},{350,760},{380,740},{360,900},{330,1250},{250,1250}}, RBQ)
F({{410,760},{440,750},{450,1000},{440,1250},{410,1250},{420,1000}}, RB)
local SL = pile{{"bone black",0.9},{"bone brown",0.9},{"raw sienna",0.3},{"lead white",0.22}}
local s1 = ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}) - poly({{238,840},{276,826},{290,856},{252,872}})
work(s1, {hand="detail", pile=SL, coverage=4.5, fill=true, clip=s1})
local s2 = ribbon({{380,800},{372,840},{362,866}}, {40, 34, 30}) - poly({{330,846},{364,840},{376,866},{340,874}})
work(s2, {hand="detail", pile=RBQ, coverage=4.5, fill=true, clip=s2})

--@ chunk 23
wait(3 * 24 * 60)
local s1 = ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}) - poly({{238,840},{276,826},{290,856},{252,872}})
work(s1, {hand="detail", pile=RBQ, coverage=4.5, fill=true, clip=s1})
local s2 = ribbon({{380,800},{372,840},{368,856}}, {40, 34, 30})
work(s2, {hand="detail", pile=RB, coverage=4.5, fill=true, clip=s2})

--@ chunk 24
wait(3 * 24 * 60)
local hb = poly({{238,840},{276,826},{290,856},{252,872}}); work(hb, {hand="detail", pile=Q5, coverage=4.5, fill=true, clip=hb})
for i, J in ipairs{{{240,846},{222,850},{208,858},{200,868},{198,878}}, {{244,856},{226,862},{214,872},{210,882}}, {{250,866},{236,874},{228,884},{226,892}}} do finger(J, 4.2 - i * 0.3, {B3, Q5}) end
local st = brush{kind="round", width=3.0, point=0.5}
st:reload(B4, 0.9); st:stroke({{232,820},{214,850},{200,876}}, {pressure={0.8, 0.6, 0.1}, ramps={0.05, 0.5}})
local hb2 = poly({{330,846},{364,840},{376,866},{340,874}}); work(hb2, {hand="detail", pile=Q4, coverage=4.5, fill=true, clip=hb2})
for i, J in ipairs{{{332,850},{312,852},{294,856},{280,862},{270,868}}, {{334,860},{314,864},{298,870},{286,876}}, {{338,868},{320,874},{306,882},{296,888}}} do finger(J, 3.8 - i * 0.3, {Q5, Q4}) end
-- glints of the Sun on the knuckles and the stylus point
local t = brush{kind="round", width=2.2, point=0.2}
for _, p in ipairs{{222,850},{226,862},{236,874},{312,852},{314,864},{246,834},{198,878}} do t:reload(pile{{"lead white",3},{"cadmium yellow",0.3}}, 0.9); t:touch(p[1] - 1, p[2] - 2, {pressure=0.25}) end

--@ chunk 25
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.0, point=0.8}
for i, J in ipairs{{{240,846},{222,850},{208,858},{200,868},{198,878}}, {{244,856},{226,862},{214,872},{210,882}}, {{250,866},{236,874},{228,884},{226,892}}} do
  finger(J, 4.2 - i * 0.3, {Q4, Q3})
  local und = {} for k, p in ipairs(J) do und[k] = {p[1] + 1, p[2] + 3.2} end
  d:reload(Q1, 0.8); d:stroke(und, {pressure={0.45, 0.35}})
end
local t = brush{kind="round", width=2.0, point=0.2}
for _, p in ipairs{{222,849},{226,861},{236,873},{208,857},{214,871}} do t:reload(pile{{"lead white",3},{"cadmium yellow",0.35}}, 0.9); t:touch(p[1] - 1, p[2] - 2, {pressure=0.22}) end
-- writing on the tablet, the last lines of the warning, and the glyph half-made under the stylus
local g = brush{kind="round", width=1.0, point=0.8}
for r = 0, 2 do local y = 852 + r * 12; g:reload(Q1, 0.7); g:stroke({{160 + r * 3, y + 2}, {200, y}, {236 - r * 4, y - 2}}, {pressure={0.3, 0.3}, clip=poly({{150,846},{340,830},{372,880},{176,900}})}) end
local hex = {} for i = 0, 4 do local a = 0.2 + i * math.pi / 3; hex[#hex+1] = {182 + 10 * math.cos(a), 886 + 5 * math.sin(a)} end
g:reload(Q1, 0.8); g:stroke(hex, {pressure={0.4, 0.4}})

--@ chunk 26
wait(3 * 24 * 60)
local col = poly({{318,700},{352,684},{424,686},{470,700},{450,730},{360,734}}, true)
work(col * rect(0,0,380,2000), {hand="detail", pile=pile{{"bone brown",1},{"bone black",0.5},{"burnt sienna",0.4},{"raw sienna",0.35},{"lead white",0.12}}, coverage=4.5, fill=true, clip=col})
local rob = ROBE - SKULL - col - ribbon({{330,780},{300,820},{270,850}}, {44, 38, 32}) - DESK
local strip = rob * poly({{240,760},{345,740},{340,1260},{230,1260}})
work(strip, {hand="detail", pile=pile{{"bone black",1},{"bone brown",0.9},{"rose madder",0.15},{"raw sienna",0.25},{"lead white",0.07}}, coverage=4.5, fill=true, clip=strip})
local dstrip = DOC * poly({{650,520},{745,520},{735,1260},{640,1260}}) - ellipse(790, 500, 92, 22) - ROBE
work(dstrip, {hand="detail", pile=pile{{"bone black",1.1},{"bone brown",0.9},{"raw sienna",0.2},{"lead white",0.08}}, coverage=4.5, fill=true, clip=dstrip})
