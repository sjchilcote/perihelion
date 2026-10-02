-- easel session "testator_portrait": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=61,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.5},{"lead white",0.35}}, um=35, apply="roller"}}}

--@ chunk 2
SKULL = poly({{372,420},{384,320},{430,232},{520,176},{640,150},{748,166},{800,226},{786,298},{720,358},{650,416},{610,510},{590,610},{548,690},{486,724},{432,700},{398,630},{378,530}}, true)
NECKM = poly({{450,690},{590,620},{640,760},{620,840},{430,840},{420,760}})
ROBE = poly({{80,1250},{110,1040},{190,900},{320,820},{430,800},{640,790},{760,830},{860,930},{920,1080},{940,1250}}, true)
TAB = poly({{300,1070},{640,1020},{712,1186},{364,1240}})
FIG = SKULL + NECKM + ROBE
BG1 = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.3}}
BGM = pile{{"bone brown",2},{"raw sienna",0.4},{"bone black",0.5},{"lead white",0.1}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"bone black",0.3},{"lead white",0.25}}
local bg = everywhere() - FIG:grow(3)
work(bg, {hand="broad", pile=BG1, coverage=2.8, fill=true, clip=bg, angle=math.pi/2 + 0.15})

--@ chunk 3
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
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
RB = pile{{"bone black",1.2},{"bone brown",0.8},{"rose madder",0.25},{"ultramarine blue",0.2}}
RBM = pile{{"bone black",1.1},{"bone brown",0.9},{"rose madder",0.2},{"lead white",0.15}}
RBL = pile{{"bone black",1},{"bone brown",0.9},{"rose madder",0.25},{"lead white",0.4},{"raw sienna",0.2}}
RBD = pile{{"bone black",1.4},{"bone brown",0.6},{"ultramarine blue",0.2}}
local robe = ROBE - NECKM
work(robe, {hand="body", pile=RB, coverage=3, fill=true, clip=robe, angle=math.pi/2})
work(NECKM - SKULL, {hand="body", pile=Q2, coverage=3, fill=true, clip=NECKM, angle=math.pi/2})
work(SKULL, {hand="body", pile=BD, coverage=3, fill=true, clip=SKULL, angle=math.pi/2})

--@ chunk 4
wait(4 * 24 * 60)
local bg = everywhere() - FIG:grow(3)
local function ringm(r0, r1) return bg * (ellipse(0, 0, r1, r1) - ellipse(0, 0, r0, r0)) end
work(ringm(0, 540), {hand="body", pile=BG2, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ringm(540, 860), {hand="body", pile=BGM, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ringm(860, 2000), {hand="body", pile=BG1, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
blend(ringm(510, 570), {angle=-0.7})
blend(ringm(830, 890), {angle=-0.7})

--@ chunk 5
HF = {
  {{{384,320},{430,232},{480,250},{450,340},{400,372}}, B3},
  {{{430,232},{520,176},{560,204},{500,262},{480,250}}, B4},
  {{{520,176},{640,150},{650,192},{560,206}}, B3},
  {{{640,150},{748,166},{730,212},{650,192}}, B2},
  {{{748,166},{800,226},{786,298},{740,272},{730,212}}, B1},
  {{{480,250},{560,206},{650,192},{730,212},{740,272},{680,302},{580,302},{500,300}}, B2},
  {{{500,300},{580,302},{680,302},{740,272},{786,298},{720,358},{650,416},{560,382}}, BD},
  {{{376,402},{400,372},{450,340},{500,300},{560,382},{600,440},{560,452},{480,432},{410,442}}, B2},
  {{{372,452},{410,442},{480,432},{500,522},{460,602},{400,622},{378,530}}, Q5},
  {{{480,432},{560,452},{600,440},{620,500},{580,562},{500,522}}, Q4},
  {{{600,440},{650,416},{612,510},{596,602},{580,562},{620,500}}, Q2},
  {{{400,622},{460,602},{500,642},{490,702},{450,714},{420,682}}, B2},
  {{{460,602},{500,522},{580,562},{596,602},{562,682},{500,642}}, Q3},
  {{{450,714},{490,702},{500,642},{562,682},{548,692},{486,726}}, Q1},
}
local clip = SKULL:grow(3)
for _, f in ipairs(HF) do local m = poly(f[1]) * clip; if m:area() > 4 then work(m, {hand="detail", pile=f[2], coverage=3, fill=true, clip=m}) end end

--@ chunk 6
wait(3 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local function bez(t) local a, b, c = {396,436}, {482,362}, {598,418}; local u = 1 - t; return {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]} end
EYES = {}
local t, gap = 0.04, 0.27
for k = 1, 7 do
  local p = bez(t)
  local s = 1 - 0.07 * (k - 1)
  EYES[k] = {p[1], p[2], 10 * s, 7.5 * s}
  t = t + gap; gap = gap * 0.72
end
-- sockets first: a darker plate round each eye
for _, e in ipairs(EYES) do local m = ellipse(e[1], e[2] + 1, e[3] + 5, e[4] + 4); work(m, {hand="detail", pile=BD, coverage=3, fill=true, clip=m}) end

--@ chunk 7
wait(3 * 24 * 60)
for _, e in ipairs(EYES) do local m = ellipse(e[1], e[2] + 1, e[3], e[4]); work(m, {hand="detail", pile=EYE, coverage=3, fill=true, clip=m}) end

--@ chunk 8
wait(2 * 24 * 60)
for k, e in ipairs(EYES) do
  local x, y, rx, ry = e[1], e[2] + 1, e[3], e[4]
  -- the upper lid: a plate over the top of the eye, its edge sloping down at the outer side (toward the back)
  local lid = poly({{x - rx - 4, y - ry - 6}, {x + rx + 4, y - ry - 6}, {x + rx + 4, y + ry * 0.05}, {x - rx - 4, y - ry * 0.35}})
  work(lid * ellipse(x, y, rx + 4.5, ry + 4.5), {hand="detail", pile=k <= 3 and B3 or B2, coverage=3, fill=true, clip=lid})
end

--@ chunk 9
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.4, point=0.7}
local t = brush{kind="round", width=2.2, point=0.2}
for k, e in ipairs(EYES) do
  local x, y, rx, ry = e[1], e[2] + 1, e[3], e[4]
  -- shadow under the lid edge, lit rim of the lid, lower lid catching the window
  d:reload(Q1, 0.8); d:stroke({{x - rx, y - ry * 0.3}, {x + rx, y + ry * 0.1}}, {pressure={0.5, 0.5}, ramps={0.1, 0.1}})
  d:reload(B4, 0.7); d:stroke({{x - rx - 2, y - ry * 0.55}, {x + rx * 0.4, y - ry * 0.3}}, {pressure={0.2, 0.5, 0.1}})
  d:reload(B3, 0.6); d:stroke({{x - rx * 0.8, y + ry + 1.5}, {x + rx * 0.6, y + ry + 2}}, {pressure={0.1, 0.4, 0.1}})
  -- a warm glint deep in each eye, and the window's highlight
  t:reload(pile{{"Mars orange",1},{"raw sienna",1},{"bone brown",0.3}}, 0.7); t:touch(x + rx * 0.2, y + ry * 0.35, {pressure=0.35})
  t:reload(B4, 0.8); t:touch(x - rx * 0.35, y + ry * 0.05, {pressure=0.25 + 0.03 * (7 - k)})
end

--@ chunk 10
wait(3 * 24 * 60)
for k, e in ipairs(EYES) do
  local x, y, rx, ry = e[1], e[2] + 1, e[3], e[4]
  local lid = poly({{x - rx - 4, y - ry - 6}, {x + rx + 4, y - ry - 6}, {x + rx + 4, y + ry * 0.05}, {x - rx - 4, y - ry * 0.35}}) * ellipse(x, y, rx + 5, ry + 5)
  work(lid, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=lid})
end

--@ chunk 11
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.8}
for k, e in ipairs(EYES) do
  local x, y, rx, ry = e[1], e[2] + 1, e[3], e[4]
  d:reload(Q1, 0.8); d:stroke({{x - rx, y - ry * 0.32}, {x + rx, y + ry * 0.08}}, {pressure={0.55, 0.55}, ramps={0.1, 0.1}})
  d:reload(B3, 0.7); d:stroke({{x - rx - 3, y - ry - 2}, {x, y - ry - 3}, {x + rx * 0.6, y - ry - 1}}, {pressure={0.1, 0.45, 0.05}})
end

--@ chunk 12
wait(1 * 24 * 60)
-- the mouth: seven folded bone pleats closing on a seam, like a fan closed over the lips
local cx, top, bot = 452, 640, 694
local xs = {420, 430, 439, 447, 455, 463, 472, 482}
for i = 1, #xs - 1 do
  local x0, x1 = xs[i], xs[i+1]
  local bow = 3 * math.sin(i * 1.3)
  local m = poly({{x0 + 3, top + 4 + math.abs(i - 4) * 2}, {x1 + 2, top + 2 + math.abs(i - 4) * 2}, {x1 + bow, bot - math.abs(i - 4) * 3}, {x0 + bow - 1, bot - 2 - math.abs(i - 4) * 3}})
  local P = (i % 2 == 1) and (i < 4 and B3 or B2) or (i < 4 and B1 or BD)
  work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m})
end

--@ chunk 13
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.3, point=0.7}
-- the seam where the pleats meet, and the fold creases
d:reload(Q1, 0.8); d:stroke({{418,668},{436,672},{454,670},{472,666},{486,660}}, {pressure={0.2, 0.7, 0.6, 0.2}, ramps={0.2, 0.2}})
for _, x in ipairs{430, 447, 463} do d:reload(Q1, 0.6); d:stroke({{x + 2, 646}, {x, 668}, {x + 1, 688}}, {pressure={0.1, 0.4, 0.1}}) end
d:reload(B4, 0.6); d:stroke({{424,648},{423,668}}, {pressure={0.1, 0.5, 0.0}})
d:reload(B4, 0.6); d:stroke({{441,646},{440,664}}, {pressure={0.1, 0.4, 0.0}})

--@ chunk 14
wait(3 * 24 * 60)
MOUTH = poly({{412,664},{424,646},{446,638},{470,640},{488,652},{490,668},{474,688},{448,694},{424,686}}, true)
work(MOUTH * rect(0, 0, 450, 2000), {hand="detail", pile=B2, coverage=3.5, fill=true, clip=MOUTH})
work(MOUTH * rect(450, 0, 200, 2000), {hand="detail", pile=B1, coverage=3.5, fill=true, clip=MOUTH})

--@ chunk 15
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.8}
-- fold lines fanning from the seam, faint; each fold lit on its window side
for i, x in ipairs{422, 432, 442, 452, 462, 472, 482} do
  local top = 648 - 6 * math.sin((i - 1) / 6 * math.pi)
  d:reload(BD, 0.6); d:stroke({{x + 1, top}, {x, 667}}, {pressure={0.05, 0.35, 0.1}, clip=MOUTH})
  if i < 5 then d:reload(B4, 0.5); d:stroke({{x - 2, top + 2}, {x - 3, 664}}, {pressure={0.05, 0.3, 0.0}, clip=MOUTH}) end
  d:reload(BD, 0.5); d:stroke({{x, 670}, {x + 1, 688 - 4 * math.abs(i - 4)}}, {pressure={0.1, 0.3, 0.05}, clip=MOUTH})
end
-- the seam, closed, its outer ends easing down a little
local s = brush{kind="round", width=1.8, point=0.7}
s:reload(Q1, 0.8); s:stroke({{416,670},{434,668},{452,667},{470,666},{486,668}}, {pressure={0.1, 0.6, 0.6, 0.1}, ramps={0.2, 0.2}})
-- the plate's outline: shadow below, soft light above
s:reload(Q1, 0.6); s:stroke({{424,688},{448,696},{476,688},{490,670}}, {pressure={0.1, 0.5, 0.1}})

--@ chunk 16
wait(1 * 24 * 60)
-- the tablet: a bone slab tilted toward us; top face lit, near edge in shade
TABTOP = poly({{300,1070},{640,1020},{700,1160},{352,1212}})
local edge = poly({{352,1212},{700,1160},{712,1186},{364,1240}})
work(TABTOP, {hand="body", pile=B2, coverage=3, fill=true, clip=TABTOP, angle=-0.15, tool="filbert 6"})
work(edge, {hand="detail", pile=B1, coverage=3, fill=true, clip=edge})
-- sleeves: the right arm comes in from the lower right, the left from the lower left
RSLV = poly({{900,1250},{880,1040},{800,930},{700,960},{660,1050},{700,1110},{760,1250}})
LSLV = poly({{90,1250},{130,1080},{220,1010},{320,1050},{330,1150},{250,1250}})
work(RSLV - TABTOP, {hand="body", pile=RBM, coverage=3, fill=true, clip=RSLV, angle=math.pi/2 + 0.4, tool="filbert 6"})
work(LSLV - TABTOP, {hand="body", pile=RBL, coverage=3, fill=true, clip=LSLV, angle=math.pi/2 - 0.4, tool="filbert 6"})

--@ chunk 17
wait(2 * 24 * 60)
function seg(a, b, w0, w1)
  local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx * w0, a[2] + ny * w0}, {b[1] + nx * w1, b[2] + ny * w1}, {b[1] - nx * w1, b[2] - ny * w1}, {a[1] - nx * w0, a[2] - ny * w0}})
end
function finger(J, w, P)
  for i = 1, #J - 1 do
    local w0, w1 = w * (1 - 0.12 * (i - 1)), w * (1 - 0.12 * i)
    local m = seg(J[i], J[i+1], w0, w1 * 0.92)
    work(m, {hand="detail", pile=P[(i % 2) + 1], coverage=3.5, fill=true, clip=m})
  end
end
-- the right hand: back plate, then five fingers curling down to a pinch
RHAND = poly({{646,1000},{700,990},{728,1040},{690,1074},{640,1060}})
work(RHAND, {hand="detail", pile=Q3, coverage=3.5, fill=true, clip=RHAND})
RF = {
  {{648,1010},{612,1020},{584,1040},{566,1066},{556,1090}},
  {{652,1032},{616,1046},{592,1068},{576,1090},{566,1104}},
  {{660,1052},{630,1070},{612,1094},{600,1114},{596,1130}},
  {{676,1066},{654,1090},{640,1112},{632,1134},{630,1150}},
  {{690,1070},{682,1098},{676,1122},{674,1142},{672,1158}},
}
for i, J in ipairs(RF) do finger(J, 6.2 - i * 0.4, i <= 2 and {Q4, Q3} or {Q3, Q2}) end
-- the left hand, in the light, its fingers laid over the near-left of the tablet
LHAND = poly({{290,1080},{340,1066},{362,1110},{330,1140},{296,1126}})
work(LHAND, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=LHAND})
LF = {
  {{338,1072},{368,1068},{396,1072},{420,1082},{438,1094}},
  {{350,1090},{380,1092},{406,1100},{428,1112},{444,1126}},
  {{354,1110},{382,1118},{404,1130},{422,1144},{434,1158}},
  {{344,1128},{368,1142},{386,1158},{398,1174},{406,1188}},
}
for i, J in ipairs(LF) do finger(J, 6 - i * 0.3, {Q5, Q4}) end

--@ chunk 18
wait(3 * 24 * 60)
HANDS = RHAND + LHAND
for _, J in ipairs(RF) do for i = 1, #J - 1 do HANDS = HANDS + seg(J[i], J[i+1], 6, 5) end end
for _, J in ipairs(LF) do for i = 1, #J - 1 do HANDS = HANDS + seg(J[i], J[i+1], 6, 5) end end
local t = TABTOP - HANDS:grow(1.5)
local far = t * poly({{480,900},{900,900},{900,1300},{560,1300}})
work(far, {hand="body", pile=B1, coverage=3.5, fill=true, clip=far, angle=-0.15, tool="filbert 6"})
local mid = t * poly({{400,900},{480,900},{560,1300},{470,1300}})
work(mid, {hand="body", pile=pile{{"lead white",1.5},{"raw sienna",0.8},{"bone brown",0.5},{"ultramarine ash",0.25}}, coverage=3.5, fill=true, clip=mid, angle=-0.15, tool="filbert 6"})

--@ chunk 19
wait(3 * 24 * 60)
local A, B, C, D = {300,1070}, {640,1020}, {700,1160}, {352,1212}
local function P(u, v) local x = (1-u)*(1-v)*A[1] + u*(1-v)*B[1] + u*v*C[1] + (1-u)*v*D[1]; local y = (1-u)*(1-v)*A[2] + u*(1-v)*B[2] + u*v*C[2] + (1-u)*v*D[2]; return {x, y} end
local clip = TABTOP:shrink(3) - HANDS:grow(2)
local g = brush{kind="round", width=1.6, point=0.7}
local function inc(uv)
  local pts = {} for i, q in ipairs(uv) do pts[i] = P(q[1], q[2]) end
  g:reload(Q1, 0.75); g:stroke(pts, {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=clip})
  local l = {} for i, p in ipairs(pts) do l[i] = {p[1] + 0.7, p[2] + 1.4} end
  g:reload(B4, 0.55); g:stroke(l, {pressure={0.25, 0.25}, ramps={0.05, 0.05}, clip=clip})
end
local function hex(cu, cv, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {cu + r * math.cos(a), cv + r * 1.6 * math.sin(a)} end return t end
local cu, cv = 0.56, 0.48
inc(hex(cu, cv, 0.06, 0.1)); inc(hex(cu, cv, 0.037, 0.45))
local cen = {}
for k = 0, 5 do
  local a = k * math.pi / 3 + 0.25 + 0.05 * math.sin(k * 2.3)
  local d = 0.17 + 0.012 * math.sin(k * 1.9)
  local pu, pv = cu + d * math.cos(a), cv + d * 1.6 * math.sin(a)
  cen[k + 1] = {pu, pv}
  local r = 0.045 + 0.004 * math.cos(k * 2.1)
  inc(hex(pu, pv, r, 0.2 * k)); inc(hex(pu, pv, r * 0.618, 0.2 * k + 0.3 + 0.12 * k))
  inc({{cu + 0.065 * math.cos(a), cv + 0.104 * math.sin(a)}, {lerp(cu, pu, 0.5) - 0.012 * math.sin(a), lerp(cv, pv, 0.5) + 0.02 * math.cos(a)}, {pu - r * math.cos(a), pv - r * 1.6 * math.sin(a)}})
end
for k = 1, 6 do local a, b = cen[k], cen[k % 6 + 1]
  inc({{lerp(a[1], b[1], 0.3), lerp(a[2], b[2], 0.3)}, {(a[1] + b[1]) / 2 + (a[1] + b[1] - 2 * cu) * 0.12, (a[2] + b[2]) / 2 + (a[2] + b[2] - 2 * cv) * 0.12}, {lerp(a[1], b[1], 0.7), lerp(a[2], b[2], 0.7)}}) end
-- a column of small script down the right margin
for r = 0, 6 do local v = 0.14 + r * 0.11; inc({{0.86, v}, {0.89, v - 0.01}, {0.91, v + 0.01}, {0.94, v}}) end

--@ chunk 20
wait(2 * 24 * 60)
-- the stylus, a bone needle held in the pinch of the first two fingers, its point on the glyph it is writing
local s = brush{kind="round", width=4.2, point=0.5}
s:reload(B3, 0.85); s:stroke({{636,968},{590,1048},{556,1108},{546,1126}}, {pressure={0.8, 0.8, 0.6, 0.1}, ramps={0.05, 0.5}})
local d = brush{kind="round", width=1.3, point=0.7}
d:reload(BD, 0.8); d:stroke({{639,970},{593,1050},{560,1108}}, {pressure={0.5, 0.4}})
d:reload(B4, 0.7); d:stroke({{632,968},{588,1044}}, {pressure={0.5, 0.2}})
-- the fingertips that hold it, laid back over it
for _, J in ipairs{RF[1], RF[2]} do local m = seg(J[4], J[5], 4.2, 3.6); work(m, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=m}) end

--@ chunk 21
wait(3 * 24 * 60)
local exact = RHAND + LHAND
local function add(J, w) for i = 1, #J - 1 do local w0, w1 = w * (1 - 0.12 * (i - 1)), w * (1 - 0.12 * i); exact = exact + seg(J[i], J[i+1], w0, w1 * 0.92) end end
for i, J in ipairs(RF) do add(J, 6.2 - i * 0.4) end
for i, J in ipairs(LF) do add(J, 6 - i * 0.3) end
HANDX = exact
TB = pile{{"lead white",1.8},{"raw sienna",0.75},{"bone brown",0.4},{"ultramarine ash",0.25}}
local t = TABTOP - exact - ribbon({{636,968},{590,1048},{556,1108},{546,1126}}, 3)
work(t, {hand="detail", pile=TB, coverage=3.5, fill=true, clip=t, angle=-0.15})

--@ chunk 22
wait(3 * 24 * 60)
local A, B, C, D = {300,1070}, {640,1020}, {700,1160}, {352,1212}
local function P(u, v) local x = (1-u)*(1-v)*A[1] + u*(1-v)*B[1] + u*v*C[1] + (1-u)*v*D[1]; local y = (1-u)*(1-v)*A[2] + u*(1-v)*B[2] + u*v*C[2] + (1-u)*v*D[2]; return {x, y} end
local clip = TABTOP:shrink(3) - HANDX:grow(1)
local g = brush{kind="round", width=1.6, point=0.7}
local function inc(uv)
  local pts = {} for i, q in ipairs(uv) do pts[i] = P(q[1], q[2]) end
  g:reload(Q1, 0.75); g:stroke(pts, {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=clip})
  local l = {} for i, p in ipairs(pts) do l[i] = {p[1] + 0.7, p[2] + 1.4} end
  g:reload(B4, 0.55); g:stroke(l, {pressure={0.25, 0.25}, ramps={0.05, 0.05}, clip=clip})
end
local function hex(cu, cv, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {cu + r * math.cos(a), cv + r * 1.6 * math.sin(a)} end return t end
local cu, cv = 0.56, 0.48
inc(hex(cu, cv, 0.06, 0.1)); inc(hex(cu, cv, 0.037, 0.45))
local cen = {}
for k = 0, 5 do
  local a = k * math.pi / 3 + 0.25 + 0.05 * math.sin(k * 2.3)
  local d = 0.17 + 0.012 * math.sin(k * 1.9)
  local pu, pv = cu + d * math.cos(a), cv + d * 1.6 * math.sin(a)
  cen[k + 1] = {pu, pv}
  local r = 0.045 + 0.004 * math.cos(k * 2.1)
  inc(hex(pu, pv, r, 0.2 * k)); inc(hex(pu, pv, r * 0.618, 0.2 * k + 0.3 + 0.12 * k))
  inc({{cu + 0.065 * math.cos(a), cv + 0.104 * math.sin(a)}, {lerp(cu, pu, 0.5) - 0.012 * math.sin(a), lerp(cv, pv, 0.5) + 0.02 * math.cos(a)}, {pu - r * math.cos(a), pv - r * 1.6 * math.sin(a)}})
end
for k = 1, 6 do local a, b = cen[k], cen[k % 6 + 1]
  inc({{lerp(a[1], b[1], 0.3), lerp(a[2], b[2], 0.3)}, {(a[1] + b[1]) / 2 + (a[1] + b[1] - 2 * cu) * 0.12, (a[2] + b[2]) / 2 + (a[2] + b[2] - 2 * cv) * 0.12}, {lerp(a[1], b[1], 0.7), lerp(a[2], b[2], 0.7)}}) end
-- a column of small script down the right margin
for r = 0, 6 do local v = 0.14 + r * 0.11; inc({{0.86, v}, {0.89, v - 0.01}, {0.91, v + 0.01}, {0.94, v}}) end

--@ chunk 23
wait(2 * 24 * 60)
-- the stylus, a bone needle held in the pinch of the first two fingers, its point on the glyph it is writing
local s = brush{kind="round", width=4.2, point=0.5}
s:reload(B3, 0.85); s:stroke({{636,968},{590,1048},{556,1108},{546,1126}}, {pressure={0.8, 0.8, 0.6, 0.1}, ramps={0.05, 0.5}})
local d = brush{kind="round", width=1.3, point=0.7}
d:reload(BD, 0.8); d:stroke({{639,970},{593,1050},{560,1108}}, {pressure={0.5, 0.4}})
d:reload(B4, 0.7); d:stroke({{632,968},{588,1044}}, {pressure={0.5, 0.2}})
-- the fingertips that hold it, laid back over it
for _, J in ipairs{RF[1], RF[2]} do local m = seg(J[4], J[5], 4.2, 3.6); work(m, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=m}) end

--@ chunk 24
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.3, point=0.7}
local t = brush{kind="round", width=2.0, point=0.2}
local function joints(J, w, lit)
  for i = 2, #J - 1 do
    local a, b = J[i - 1], J[i + 1]
    local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / l, dx / l
    local ww = w * (1 - 0.12 * (i - 1))
    d:reload(Q1, 0.8); d:stroke({{J[i][1] + nx * ww, J[i][2] + ny * ww}, {J[i][1] - nx * ww, J[i][2] - ny * ww}}, {pressure={0.5, 0.5}})
    t:reload(lit, 0.75); t:touch(J[i][1] - nx * ww * 0.5 - dx / l * 1.5, J[i][2] - ny * ww * 0.5 - dy / l * 1.5, {pressure=0.3})
  end
end
for i, J in ipairs(RF) do joints(J, 6.2 - i * 0.4, i <= 2 and Q5 or Q4) end
for i, J in ipairs(LF) do joints(J, 6 - i * 0.3, HL) end
-- plates on the backs of the hands
d:reload(Q1, 0.8); d:stroke({{652,1004},{690,1050}}, {pressure={0.4, 0.4}})
d:reload(Q5, 0.7); d:stroke({{648,1000},{698,990}}, {pressure={0.2, 0.6, 0.1}})
d:reload(Q2, 0.8); d:stroke({{300,1100},{350,1100}}, {pressure={0.4, 0.4}})
d:reload(HL, 0.7); d:stroke({{292,1082},{338,1068}}, {pressure={0.2, 0.6, 0.1}})

--@ chunk 25
-- the neck: chitin rings stacked, each lit on its left
local neck = NECKM - SKULL:grow(1)
local ys = {640, 672, 702, 730, 758, 790, 840}
for i = 1, #ys - 1 do
  local band = neck * poly({{400, ys[i] + 10}, {660, ys[i] - 14}, {660, ys[i+1] - 14}, {400, ys[i+1] + 10}})
  work(band * rect(0, 0, 500, 2000), {hand="detail", pile=(i % 2 == 0) and Q4 or Q3, coverage=3.5, fill=true, clip=band})
  work(band * rect(500, 0, 300, 2000), {hand="detail", pile=(i % 2 == 0) and Q2 or Q1, coverage=3.5, fill=true, clip=band})
end

--@ chunk 26
wait(2 * 24 * 60)
COLLAR = poly({{330,850},{392,776},{446,744},{474,800},{524,818},{600,792},{644,744},{712,786},{780,860},{650,890},{500,900},{372,890}}, true)
work(COLLAR * rect(0, 0, 470, 2000), {hand="body", pile=RBL, coverage=3.5, fill=true, clip=COLLAR, angle=-0.6, tool="filbert 6"})
work(COLLAR * rect(470, 0, 160, 2000), {hand="body", pile=RBM, coverage=3.5, fill=true, clip=COLLAR, angle=0, tool="filbert 6"})
work(COLLAR * rect(630, 0, 400, 2000), {hand="body", pile=RBD, coverage=3.5, fill=true, clip=COLLAR, angle=0.6, tool="filbert 6"})

--@ chunk 27
wait(3 * 24 * 60)
-- the collar as folds: wedges of cloth radiating round the neck, each lit on its window side
local cx, cy = 520, 760
local fold = {RBL, RBM, RBL, RBM, RBD, RBM, RBD, RBD}
local edges = {{330,860},{350,820},{392,778},{446,746},{480,800},{530,820},{600,790},{644,746},{712,788},{780,862}}
for i = 1, #edges - 1 do
  local a, b = edges[i], edges[i+1]
  local m = poly({{cx, cy + 60}, a, b}) * COLLAR:grow(2)
  local P = fold[math.min(#fold, i)]
  if a[1] > 600 then P = (i % 2 == 0) and RBD or RBM end
  if m:area() > 4 then work(m, {hand="detail", pile=P, coverage=3.5, fill=true, clip=m}) end
end
local low = COLLAR * rect(0, 840, 1000, 80)
work(low * rect(0,0,500,2000), {hand="detail", pile=RBM, coverage=3.5, fill=true, clip=low})
work(low * rect(500,0,500,2000), {hand="detail", pile=RBD, coverage=3.5, fill=true, clip=low})
-- the neck: the right side into shadow, rings kept only as faint seams
local neck = (NECKM - SKULL:grow(1) - COLLAR) * rect(510, 0, 300, 2000)
work(neck, {hand="detail", pile=Q1, coverage=3.5, fill=true, clip=neck})

--@ chunk 28
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.6, point=0.7}
for _, e in ipairs{{350,820},{392,778},{446,746},{480,800},{530,820},{600,790},{644,746},{712,788}} do
  d:reload(e[1] < 560 and Q1 or RBD, 0.8); d:stroke({{e[1], e[2]}, {lerp(e[1], 520, 0.4), lerp(e[2], 840, 0.6)}}, {pressure={0.6, 0.1}, ramps={0.05, 0.6}, clip=COLLAR})
end
-- light along the collar's upper edge where it turns toward the window
d:reload(pile{{"bone brown",1},{"lead white",0.8},{"rose madder",0.2},{"raw sienna",0.3}}, 0.7)
d:stroke({{334,856},{352,818},{394,776},{444,744}}, {pressure={0.2, 0.7, 0.6, 0.1}, ramps={0.2, 0.3}})

--@ chunk 29
wait(2 * 24 * 60)
local clip = SKULL - MOUTH:grow(2)
for _, e in ipairs(EYES) do clip = clip - ellipse(e[1], e[2] + 1, e[3] + 6, e[4] + 6) end
local s = brush{kind="round", width=1.8, point=0.6}
local l = brush{kind="round", width=1.1, point=0.8}
local done = {}
for _, f in ipairs(HF) do
  local pts = f[1]
  for i = 1, #pts do
    local a, b = pts[i], pts[i % #pts + 1]
    local key = math.floor(math.min(a[1], b[1])) .. ":" .. math.floor(math.min(a[2], b[2])) .. ":" .. math.floor(math.max(a[1], b[1])) .. ":" .. math.floor(math.max(a[2], b[2]))
    if not done[key] then
      done[key] = true
      local mx = (a[1] + b[1]) / 2
      s:reload(mx < 520 and BD or Q1, 0.75); s:stroke({a, b}, {pressure={0.4, 0.45}, ramps={0.05, 0.05}, clip=clip})
      if mx < 560 then l:reload(B4, 0.55); l:stroke({{a[1] + 0.8, a[2] + 1.8}, {b[1] + 0.8, b[2] + 1.8}}, {pressure={0.25, 0.25}, ramps={0.1, 0.1}, clip=clip}) end
    end
  end
end

--@ chunk 30
wait(2 * 24 * 60)
-- the brow ridge: a lit bone shelf over the eye arc, and its shadow on the cheek-chitin below the eyes
local f = brush{kind="filbert", width=6}
f:reload(B4, 0.75); f:stroke({{386,420},{430,380},{480,356},{540,356},{600,380}}, {pressure={0.1, 0.6, 0.5, 0.3, 0.05}, ramps={0.2, 0.3}, clip=SKULL})
f:reload(Q2, 0.75); f:stroke({{392,456},{440,432},{500,424},{560,436},{600,452}}, {pressure={0.1, 0.5, 0.4, 0.2, 0.0}, ramps={0.2, 0.3}, clip=SKULL})
-- polish: a long sheen on the skull's crest, a hairline highlight on the lit cheek plane
f:reload(HL, 0.55); f:stroke({{432,246},{520,192},{640,166},{730,176}}, {pressure={0.05, 0.45, 0.35, 0.05}, ramps={0.3, 0.3}, clip=SKULL})
local h = brush{kind="round", width=1.4, point=0.7}
h:reload(HL, 0.7); h:stroke({{380,470},{382,530},{392,590}}, {pressure={0.1, 0.6, 0.0}, ramps={0.2, 0.4}, clip=SKULL})

--@ chunk 31
wait(3 * 24 * 60)
local keep = MOUTH:grow(2)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2] + 1, e[3] + 5.5, e[4] + 5.5) end
local plateA = poly(HF[8][1]) * SKULL - keep
work(plateA, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=plateA})
local below = (poly(HF[9][1]) * SKULL * rect(0, 0, 1000, 470)) - keep
work(below, {hand="detail", pile=Q5, coverage=3.5, fill=true, clip=below})
local below2 = (poly(HF[10][1]) * SKULL * rect(0, 0, 1000, 480)) - keep
work(below2, {hand="detail", pile=Q4, coverage=3.5, fill=true, clip=below2})

--@ chunk 32
wait(3 * 24 * 60)
local keep = MOUTH:grow(2)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2] + 1, e[3] + 5, e[4] + 5) end
local clip = SKULL - keep
-- seams restated round the plate
local s = brush{kind="round", width=1.8, point=0.6}
local pts = HF[8][1]
for i = 1, #pts do local a, b = pts[i], pts[i % #pts + 1]; s:reload(BD, 0.75); s:stroke({a, b}, {pressure={0.4, 0.45}, ramps={0.05, 0.05}, clip=clip}) end
-- a brow ridge: one soft continuous light just above the eye arc
local f = brush{kind="filbert", width=5}
f:reload(B3, 0.7); f:stroke({{392,412},{440,378},{500,362},{560,370},{600,392}}, {pressure={0.05, 0.45, 0.4, 0.25, 0.0}, ramps={0.3, 0.3}, clip=clip})
-- soft shade under the eye arc, lower than before, fading out both ends
f:reload(BD, 0.5); f:stroke({{430,440},{480,428},{540,428},{590,436}}, {pressure={0.0, 0.3, 0.3, 0.0}, ramps={0.4, 0.4}, clip=clip})

--@ chunk 33
wait(2 * 24 * 60)
local keep = MOUTH:grow(2)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2] + 1, e[3] + 5.5, e[4] + 5.5) end
local p7 = poly(HF[7][1]) * SKULL * rect(480, 330, 200, 110)
work(p7, {hand="detail", pile=BD, coverage=3.5, fill=true, clip=p7})
local plateA = poly(HF[8][1]) * SKULL - keep
work(plateA, {hand="detail", pile=B2, coverage=3.5, fill=true, clip=plateA})

--@ chunk 34
wait(3 * 24 * 60)
local keep = MOUTH:grow(2)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2] + 1, e[3] + 5.5, e[4] + 5.5) end
-- the brow: a narrow lit facet over the eye arc, and a thin shaded facet beneath the eyes
local brow = poly({{386,416},{434,376},{500,358},{560,362},{598,384},{592,394},{556,376},{500,372},{440,390},{392,428}}) * SKULL - keep
work(brow, {hand="detail", pile=B4, coverage=3.5, fill=true, clip=brow})
local under = poly({{410,446},{470,432},{540,430},{596,440},{596,448},{540,440},{470,442},{412,456}}) * SKULL - keep
work(under, {hand="detail", pile=B1, coverage=3.5, fill=true, clip=under})
local s = brush{kind="round", width=1.8, point=0.6}
local pts = HF[8][1]
for i = 1, #pts do local a, b = pts[i], pts[i % #pts + 1]; s:reload(BD, 0.85); s:stroke({a, b}, {pressure={0.55, 0.55}, ramps={0.05, 0.05}, clip=SKULL - keep}) end

--@ chunk 35
wait(2 * 24 * 60)
local spill = (poly({{404,440},{470,426},{540,424},{604,436},{604,456},{540,446},{470,448},{404,462}}) * SKULL) - poly(HF[8][1]):shrink(1)
for _, k in ipairs{9, 10, 11} do
  local m = spill * poly(HF[k][1])
  if m:area() > 2 then work(m, {hand="detail", pile=HF[k][2], coverage=3.5, fill=true, clip=m}) end
end
local s = brush{kind="round", width=1.8, point=0.6}
local pts = HF[8][1]
for i = 5, #pts do local a, b = pts[i], pts[i % #pts + 1]; s:reload(BD, 0.85); s:stroke({a, b}, {pressure={0.55, 0.55}, ramps={0.05, 0.05}, clip=SKULL}) end

--@ chunk 36
wait(2 * 24 * 60)
local keep = MOUTH:grow(2)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2] + 1, e[3] + 5.5, e[4] + 5.5) end
local brow = poly({{386,416},{434,376},{500,358},{560,362},{598,384},{592,394},{556,376},{500,372},{440,390},{392,428}}) * SKULL - keep
work(brow * rect(0,0,500,2000), {hand="detail", pile=B3, coverage=3.5, fill=true, clip=brow})
work(brow * rect(500,0,300,2000), {hand="detail", pile=B2, coverage=3.5, fill=true, clip=brow})

--@ chunk 37
wait(2 * 24 * 60)
-- growth lines in the chitin: fine curves following each plate's lower edge, darker toward the shadow
local g = brush{kind="round", width=1.0, point=0.8}
for _, k in ipairs{9, 10, 11, 13} do
  local pts = HF[k][1]
  local cx, cy = 0, 0; for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end; cx, cy = cx / #pts, cy / #pts
  local m = poly(pts):shrink(3) * SKULL
  for r = 1, 4 do
    local s = 0.25 + 0.17 * r
    local line = {}
    for i, p in ipairs(pts) do line[#line+1] = {cx + (p[1] - cx) * s, cy + (p[2] - cy) * s + 4} end
    line[#line+1] = line[1]
    g:reload(k == 9 and Q4 or Q1, 0.5); g:stroke(line, {pressure={0.25, 0.25}, ramps={0.1, 0.1}, clip=m})
  end
end

--@ chunk 38
wait(1 * 24 * 60)
WSH = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.2}}
local sh = poly({{800,236},{860,250},{900,320},{860,420},{780,520},{700,640},{660,760},{620,800},{640,600},{720,420},{786,300}}, true) - FIG:grow(2)
work(sh, {hand="body", pile=WSH, coverage=2.6, fill=true, clip=sh, angle=math.pi/2 + 0.3, edge="soft"})

--@ chunk 39
wait(2 * 24 * 60)
-- the robe: sleeve folds and a shoulder fold, each a lit facet beside a dark one
local function F(pts, p, clip) local m = poly(pts) * (clip or ROBE:grow(2)) - TABTOP:grow(2) - HANDX:grow(2) - COLLAR; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
F({{110,1100},{180,1030},{230,1040},{160,1150},{120,1250},{90,1250}}, RBL)
F({{230,1040},{300,1060},{290,1120},{210,1150},{160,1150}}, RBM)
F({{170,1160},{250,1140},{290,1200},{250,1250},{150,1250}}, RBD)
F({{200,900},{300,840},{330,870},{250,940},{180,980}}, RBL)
F({{700,960},{790,930},{820,990},{740,1030},{700,1020}}, RBM)
F({{740,1030},{830,1000},{870,1100},{800,1130}}, RBD)
F({{780,1140},{880,1110},{900,1250},{800,1250}}, RBM)

--@ chunk 40
wait(2 * 24 * 60)
RBQ = pile{{"bone black",1.2},{"bone brown",0.9},{"rose madder",0.2},{"lead white",0.08}}
local m = poly({{740,1030},{830,1000},{870,1100},{800,1130}}) * ROBE:grow(2) - HANDX:grow(2) - TABTOP:grow(2)
work(m, {hand="detail", pile=RBQ, coverage=3.5, fill=true, clip=m})
local m2 = poly({{170,1160},{250,1140},{290,1200},{250,1250},{150,1250}}) * ROBE:grow(2) - TABTOP:grow(2) - HANDX:grow(2)
work(m2, {hand="detail", pile=RBQ, coverage=3.5, fill=true, clip=m2})
local sh = poly({{806,250},{850,266},{880,330},{846,420},{776,520},{706,640},{676,740},{640,780},{660,610},{730,430},{790,310}}, true) - FIG:grow(2)
work(sh, {hand="body", pile=WSH, coverage=2.6, fill=true, clip=sh, angle=math.pi/2 + 0.3, edge="soft"})

--@ chunk 41
wait(2 * 24 * 60)
local function P(k, p, cut) local m = poly(HF[k][1]):shrink(1) * SKULL; if cut then m = m * cut end; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
P(4, B1)
P(5, BD)
P(6, B1, rect(600, 0, 400, 2000))
P(6, pile{{"lead white",1.6},{"raw sienna",0.8},{"bone brown",0.45},{"ultramarine ash",0.25}}, rect(0, 0, 600, 2000))
P(3, B2, rect(560, 0, 400, 2000))

--@ chunk 42
wait(2 * 24 * 60)
-- seams back over the repainted plates
local s = brush{kind="round", width=1.8, point=0.6}
for _, k in ipairs{3, 4, 5, 6} do local pts = HF[k][1]
  for i = 1, #pts do local a, b = pts[i], pts[i % #pts + 1]; s:reload(Q1, 0.8); s:stroke({a, b}, {pressure={0.45, 0.45}, ramps={0.05, 0.05}, clip=SKULL}) end end
-- the crest's lit lip on the window side only
local f = brush{kind="filbert", width=4}
f:reload(HL, 0.55); f:stroke({{436,244},{480,214},{528,190}}, {pressure={0.05, 0.5, 0.05}, ramps={0.3, 0.3}, clip=SKULL})

--@ chunk 43
wait(5 * 24 * 60)
print(drying(800, 1060), drying(200, 1200))
local m = poly({{740,1030},{830,1000},{870,1100},{800,1130}}) * ROBE:grow(2) - HANDX:grow(2) - TABTOP:grow(2)
work(m, {hand="detail", pile=RBQ, coverage=4, fill=true, clip=m})
local m2 = poly({{170,1160},{250,1140},{290,1200},{250,1250},{150,1250}}) * ROBE:grow(2) - TABTOP:grow(2) - HANDX:grow(2)
work(m2, {hand="detail", pile=RBQ, coverage=4, fill=true, clip=m2})

--@ chunk 44
wait(1 * 24 * 60)
local f = brush{kind="filbert", width=5}
f:reload(Q3, 0.6); f:stroke({{596,604},{576,650},{548,690},{510,716}}, {pressure={0.05, 0.45, 0.4, 0.05}, ramps={0.3, 0.3}, clip=SKULL})
local d = brush{kind="round", width=1.6, point=0.7}
d:reload(Q1, 0.8); d:stroke({{410,666},{420,646},{446,636},{472,638},{490,652},{492,670},{476,690},{448,696},{422,688},{410,666}}, {pressure={0.4, 0.4}, ramps={0.05, 0.05}})
-- the point of the stylus, a fresh scratch of bright bone where it bites the tablet
local t = brush{kind="round", width=2.0, point=0.2}
t:reload(B4, 0.8); t:touch(547, 1126, {pressure=0.4})
