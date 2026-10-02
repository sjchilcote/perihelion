-- easel session "late_selfportrait": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={22,20}, seed=139,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.25}}, um=35, apply="roller"}}}

--@ chunk 2
HELM = poly({{322,560},{328,430},{368,316},{448,242},{548,218},{640,240},{706,306},{736,410},{740,540},{722,660},{690,770},{640,846},{560,884},{462,880},{392,844},{352,764},{330,660}}, true)
RAG = poly({{180,1250},{220,1030},{320,910},{430,870},{620,870},{740,910},{830,1020},{880,1250}}, true)
BG1 = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.3}}
BGM = pile{{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.5},{"raw sienna",0.2}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"burnt sienna",0.5},{"lead white",0.25}}
local bg = everywhere() - (HELM + RAG):grow(3)
local function ring(r0, r1) return bg * (ellipse(320, 330, r1, r1 * 1.1) - ellipse(320, 330, r0, r0 * 1.1)) end
work(ring(0, 280), {hand="body", pile=BG2, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ring(280, 440), {hand="body", pile=BGM, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ring(440, 2000), {hand="body", pile=BG1, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
blend(ring(255, 305), {angle=-0.7}); blend(ring(415, 465), {angle=-0.7})
S1 = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.15}}
S2 = pile{{"bone brown",1.5},{"bone black",0.6},{"raw sienna",0.5},{"lead white",0.2}}
FR = pile{{"red earth",0.8},{"bone brown",1},{"rose madder",0.3},{"bone black",0.2}}
work(RAG - HELM, {hand="body", pile=FR, coverage=3, fill=true, clip=RAG, angle=math.pi/2})
work(HELM, {hand="body", pile=S2, coverage=3, fill=true, clip=HELM, angle=math.pi/2})

--@ chunk 3
wait(4 * 24 * 60)
T1 = pile{{"bone black",1},{"bone brown",0.8},{"lead white",0.18},{"ultramarine ash",0.2}}
T2 = pile{{"bone black",0.8},{"bone brown",0.8},{"lead white",0.35},{"ultramarine ash",0.25}}
T3 = pile{{"lead white",0.7},{"bone black",0.6},{"raw sienna",0.4},{"ultramarine ash",0.3},{"bone brown",0.3}}
T4 = pile{{"lead white",1},{"bone black",0.4},{"raw sienna",0.45},{"ultramarine ash",0.35}}
W1 = pile{{"bone brown",1.5},{"burnt sienna",0.5},{"bone black",0.5}}
HF = {
  {{{328,430},{368,316},{448,242},{478,320},{420,400},{340,450}}, T4},
  {{{448,242},{548,218},{560,298},{478,320}}, T4},
  {{{548,218},{640,240},{706,306},{640,346},{560,298}}, T3},
  {{{706,306},{736,410},{740,470},{680,450},{640,346}}, T1},
  {{{478,320},{560,298},{640,346},{680,450},{580,430},{470,420}}, T3},
  {{{340,450},{420,400},{470,420},{580,430},{680,450},{740,470},{740,520},{600,506},{460,496},{330,520}}, T2},
  {{{330,520},{460,496},{456,620},{440,740},{392,844},{352,764},{330,660}}, W1},
  {{{460,496},{600,506},{740,520},{722,660},{690,770},{640,846},{560,884},{462,880},{392,844},{440,740},{456,620}}, S1},
}
for _, f in ipairs(HF) do local m = poly(f[1]) * HELM:grow(2); work(m, {hand="detail", pile=f[2], coverage=4, fill=true, clip=m}) end

--@ chunk 4
wait(2 * 24 * 60)
SLIT = pile{{"bone black",1.5},{"ultramarine blue",0.3}}
GW = pile{{"raw sienna",1},{"yellow ochre",0.6},{"bone brown",0.5},{"lead white",0.2}}
G1 = pile{{"raw sienna",1.5},{"burnt sienna",0.8},{"bone brown",0.6}}
local slit = poly({{332,556},{400,544},{470,540},{560,546},{660,556},{734,566},{732,580},{660,574},{560,566},{470,562},{400,566},{332,580}}) * HELM
work(slit, {hand="detail", pile=SLIT, coverage=4, fill=true, clip=slit})
-- the cross worn nearly away: broken stretches of dull gold, steel showing through
local t = brush{kind="round", width=5.5, point=0.3}
local function worn(pts, n0) for i = 1, #pts - 1 do if (i + n0) % 3 ~= 0 then t:reload(i % 2 == 0 and GW or G1, 0.85); t:stroke({pts[i], pts[i+1]}, {pressure={0.6, 0.4}, ramps={0.2, 0.3}, clip=HELM}) end end end
local up = {} for i = 0, 10 do up[#up+1] = {458 + i * 1.2 + 2 * math.sin(i * 2), 262 + i * 22} end
worn(up, 0)
local arm = {} for i = 0, 6 do arm[#arm+1] = {414 + i * 18, 318 - i * 1.5 + 2 * math.cos(i * 3)} end
worn(arm, 1)
-- a worn band at the brow, dull, mostly gone
local band = poly({{336,486},{460,466},{600,474},{740,488},{740,504},{600,492},{460,484},{332,506}}) * HELM
stipple(band, {pile=GW, width=3, coverage=0.5, cluster={0.7, 10}, pressure={0.4, 0.7}})

--@ chunk 5
wait(2 * 24 * 60)
-- the optic, cold, small, deep in the slit
local o = ellipse(420, 561, 7, 5); work(o, {hand="detail", pile=pile{{"cerulean blue",1},{"zinc white",1},{"ultramarine ash",0.5}}, coverage=4, fill=true, clip=o})
local c = ellipse(419, 560.5, 3.4, 2.4); work(c, {hand="detail", pile=pile{{"zinc white",3},{"cerulean blue",0.5}}, coverage=4, fill=true, clip=c})
local g = brush{kind="filbert", width=6}
g:reload(pile{{"zinc white",1},{"cerulean blue",1},{"ultramarine ash",1}, medium=0.6}, 0.3)
g:stroke({{396,552},{420,549},{446,552}}, {pressure={0.05, 0.28, 0.05}, ramps={0.4, 0.4}})
-- sensor masts grown out of the back of the crown: thin bronze rods with rings and a dish, leaning back
local m = brush{kind="round", width=3.2, point=0.5}
local h = brush{kind="round", width=1.4, point=0.7}
for _, s in ipairs{{640,250,700,120,0}, {680,280,770,170,1}, {700,330,800,250,2}, {600,232,630,90,3}} do
  m:reload(T1, 0.9); m:stroke({{s[1], s[2]}, {lerp(s[1], s[3], 0.5) + 6, lerp(s[2], s[4], 0.5)}, {s[3], s[4]}}, {pressure={0.7, 0.5, 0.3}, ramps={0.05, 0.2}})
  h:reload(T3, 0.8); h:stroke({{s[1] - 2, s[2]}, {lerp(s[1], s[3], 0.5) + 4, lerp(s[2], s[4], 0.5)}}, {pressure={0.4, 0.1}})
  for _, f in ipairs{0.45, 0.8} do local x, y = lerp(s[1], s[3], f), lerp(s[2], s[4], f); local r = ellipse(x, y, 7, 2.6) - ellipse(x, y, 4, 1.2); work(r, {hand="detail", pile=T2, coverage=4, fill=true, clip=r}) end
  if s[5] == 1 then local d = ellipse(s[3], s[4], 14, 6); work(d, {hand="detail", pile=T3, coverage=4, fill=true, clip=d}) end
end

--@ chunk 6
wait(2 * 24 * 60)
-- soften the glow's edge: scumble the middle tone back and forth across it
local bg = everywhere() - (HELM + RAG):grow(3)
local edge = bg * (ellipse(320, 330, 320, 352) - ellipse(320, 330, 240, 264))
work(edge, {hand="scumble", pile=BGM, coverage=1.6, clip=edge, pressure={0.3, 0.6}})
local edge2 = bg * (ellipse(320, 330, 270, 297) - ellipse(320, 330, 200, 220))
work(edge2, {hand="scumble", pile=BG2, coverage=0.9, clip=edge2, pressure={0.2, 0.5}})

--@ chunk 7
wait(3 * 24 * 60)
-- the Void graft: pale inside-out plates along the right cheek-guard, each folding into a smaller turned copy of itself
VP1 = pile{{"zinc white",1.6},{"ultramarine ash",0.8},{"cobalt violet",0.3},{"bone black",0.15}}
VP2 = pile{{"ultramarine ash",1},{"cobalt violet",0.5},{"bone black",0.5},{"zinc white",0.4}}
VP3 = pile{{"zinc white",2.5},{"cerulean blue",0.2},{"cobalt violet",0.15}}
local function hexp(cx, cy, r, rot, sq) local t = {} for i = 0, 5 do local a = rot + i * math.pi / 3; t[#t+1] = {cx + r * math.cos(a) * sq, cy + r * math.sin(a)} end return poly(t) end
GRAFT = nil
for _, g in ipairs{{660,640,46,0.3}, {690,720,36,1.0}, {640,770,28,0.6}, {700,600,22,1.4}} do
  local cx, cy, r, rot = g[1], g[2], g[3], g[4]
  for k = 1, 4 do
    local outer = hexp(cx, cy, r, rot, 0.7) * HELM
    local inner = hexp(cx + r * 0.12, cy - r * 0.05, r * 0.618, rot + 0.5, 0.7)
    local rim = outer - inner
    GRAFT = GRAFT and (GRAFT + outer) or outer
    work(rim, {hand="detail", pile=(k % 2 == 1) and VP1 or VP2, coverage=4, fill=true, clip=rim})
    cx, cy, r, rot = cx + r * 0.12, cy - r * 0.05, r * 0.618, rot + 0.5
  end
  local core = hexp(cx, cy, r, rot, 0.7); work(core, {hand="detail", pile=VP3, coverage=4, fill=true, clip=core})
end

--@ chunk 8
wait(5 * 24 * 60)
BGa = pile{{"bone brown",2},{"raw sienna",0.65},{"burnt sienna",0.5},{"bone black",0.12},{"lead white",0.18}}
BGb = pile{{"bone brown",2},{"raw sienna",0.35},{"burnt sienna",0.5},{"bone black",0.35},{"lead white",0.08}}
BGc = pile{{"bone brown",2},{"burnt sienna",0.4},{"bone black",0.7}}
local bg = everywhere() - (HELM + RAG):grow(2) - poly({{590,60},{820,60},{820,260},{640,260}})
local function ring(r0, r1) return bg * (ellipse(320, 330, r1, r1 * 1.1) - ellipse(320, 330, r0, r0 * 1.1)) end
local rs = {0, 200, 300, 400, 500, 2000}
local ps = {BG2, BGa, BGM, BGb, BGc}
for i = 1, 5 do work(ring(rs[i], rs[i+1]), {hand="body", pile=ps[i], coverage=3.5, fill=true, clip=bg, angle=math.pi/2 + 0.2}) end
for i = 2, 5 do blend(ring(rs[i] - 30, rs[i] + 30), {angle=-0.7}) end

--@ chunk 9
wait(3 * 24 * 60)
local box = poly({{580,50},{830,50},{830,270},{630,270}}) - HELM:grow(1)
local function ring(r0, r1) return box * (ellipse(320, 330, r1, r1 * 1.1) - ellipse(320, 330, r0, r0 * 1.1)) end
work(ring(300, 400), {hand="body", pile=BGM, coverage=3.5, fill=true, clip=box, angle=math.pi/2 + 0.2})
work(ring(400, 500), {hand="body", pile=BGb, coverage=3.5, fill=true, clip=box, angle=math.pi/2 + 0.2})
work(ring(500, 2000), {hand="body", pile=BGc, coverage=3.5, fill=true, clip=box, angle=math.pi/2 + 0.2})
blend(ring(370, 430), {angle=-0.7}); blend(ring(470, 530), {angle=-0.7})

--@ chunk 10
wait(4 * 24 * 60)
-- masts: tapering bronze rods, dark against the glow, with a lit edge toward the window
local function rod(a, b, w0, w1)
  local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}})
end
MASTS = {{{636,258},{688,110}}, {{676,286},{776,168}}, {{702,334},{808,262}}, {{604,238},{622,88}}}
local h = brush{kind="round", width=1.6, point=0.7}
for i, s in ipairs(MASTS) do
  local m = rod(s[1], s[2], 5, 2.4) - HELM:shrink(6)
  work(m, {hand="detail", pile=T1, coverage=4, fill=true, clip=m})
  h:reload(T3, 0.8); h:stroke({{s[1][1] - 3, s[1][2] - 1}, {lerp(s[1][1], s[2][1], 0.7) - 2, lerp(s[1][2], s[2][2], 0.7)}}, {pressure={0.5, 0.1}, clip=m:grow(1)})
  for _, f in ipairs{0.4, 0.75} do local x, y = lerp(s[1][1], s[2][1], f), lerp(s[1][2], s[2][2], f); local r = ellipse(x, y, 9, 3.4) - ellipse(x, y, 5, 1.6); work(r, {hand="detail", pile=T2, coverage=4, fill=true, clip=r}) end
end
local d = ellipse(776, 168, 18, 8); work(d, {hand="detail", pile=T2, coverage=4, fill=true, clip=d})
local di = ellipse(774, 166, 12, 5); work(di, {hand="detail", pile=T1, coverage=4, fill=true, clip=di})

--@ chunk 11
wait(1 * 24 * 60)
local m = GRAFT:grow(2) * HELM
work(m, {hand="detail", pile=S1, coverage=4, fill=true, clip=m})

--@ chunk 12
wait(3 * 24 * 60)
-- one large inside-out plate erupting from under the slit, turning back on itself; inside it a smaller turned copy, then another
local function quad(cx, cy, w, h, rot, skew)
  local p = {{-w, -h * 0.6}, {w * 0.8, -h}, {w, h * 0.7}, {-w * 0.7, h}}
  local t = {} for i, q in ipairs(p) do local x, y = q[1] + skew * q[2], q[2]; t[i] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)} end
  return poly(t, true)
end
GRAFT2 = nil
local cx, cy, w, h, rot = 650, 690, 70, 92, 0.25
local piles = {VP2, VP1, VP2, VP1, VP3}
for k = 1, 5 do
  local o = quad(cx, cy, w, h, rot, 0.25) * HELM
  local nx, ny = cx + w * 0.16, cy - h * 0.08
  local i = quad(nx, ny, w * 0.618, h * 0.618, rot + 0.5, 0.25)
  local rim = (k < 5) and (o - i) or o
  if k == 1 then GRAFT2 = o end
  work(rim, {hand="detail", pile=piles[k], coverage=4, fill=true, clip=rim})
  cx, cy, w, h, rot = nx, ny, w * 0.618, h * 0.618, rot + 0.5
end

--@ chunk 13
wait(6 * 24 * 60)
VD1 = pile{{"ultramarine ash",1},{"cobalt violet",0.5},{"bone black",0.7},{"bone brown",0.3},{"zinc white",0.25}}
VD2 = pile{{"ultramarine ash",1},{"cobalt violet",0.4},{"bone black",0.35},{"zinc white",0.6}}
VD3 = pile{{"zinc white",1.2},{"ultramarine ash",0.8},{"cobalt violet",0.3},{"bone black",0.1}}
local function quad(cx, cy, w, h, rot, skew)
  local p = {{-w, -h * 0.6}, {w * 0.8, -h}, {w, h * 0.7}, {-w * 0.7, h}}
  local t = {} for i, q in ipairs(p) do local x, y = q[1] + skew * q[2], q[2]; t[i] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)} end
  return poly(t, true), t
end
QS = {}
local cx, cy, w, h, rot = 650, 690, 70, 92, 0.25
local piles = {VD1, VD2, VD1, VD2, VD3}
for k = 1, 5 do
  local o, pts = quad(cx, cy, w, h, rot, 0.25); o = o * HELM
  QS[k] = pts
  local nx, ny = cx + w * 0.16, cy - h * 0.08
  local i = quad(nx, ny, w * 0.618, h * 0.618, rot + 0.5, 0.25)
  local rim = (k < 5) and (o - i) or o
  work(rim, {hand="detail", pile=piles[k], coverage=4.5, fill=true, clip=rim})
  cx, cy, w, h, rot = nx, ny, w * 0.618, h * 0.618, rot + 0.5
end

--@ chunk 14
wait(4 * 24 * 60)
local h = brush{kind="round", width=1.8, point=0.6}
for k = 1, 5 do local p = QS[k]
  h:reload(VD3, 0.85); h:stroke({p[1], p[2]}, {pressure={0.2, 0.6, 0.2}, ramps={0.2, 0.2}, clip=HELM})
  h:reload(pile{{"bone black",1},{"cobalt violet",0.3}}, 0.8); h:stroke({p[3], p[4]}, {pressure={0.2, 0.5, 0.2}, ramps={0.2, 0.2}, clip=HELM})
end

--@ chunk 15
wait(2 * 24 * 60)
FR1 = pile{{"red earth",0.6},{"bone brown",1.2},{"rose madder",0.2},{"raw sienna",0.3},{"lead white",0.2}}
FR2 = pile{{"red earth",0.5},{"bone brown",1.2},{"bone black",0.4},{"rose madder",0.2}}
FR3 = pile{{"bone brown",1.3},{"bone black",0.7},{"red earth",0.3}}
local rag = RAG - HELM:grow(1)
local function F(pts, p) local m = poly(pts) * rag; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{180,1250},{220,1030},{320,910},{400,890},{360,1000},{300,1250}}, FR2)
F({{320,910},{440,870},{480,890},{400,1010},{360,1000}}, FR1)
F({{300,1250},{360,1000},{400,1010},{440,1250}}, FR3)
F({{400,1010},{480,890},{570,880},{530,1000},{510,1250},{440,1250}}, FR2)
F({{570,880},{630,870},{700,910},{610,1030},{530,1000}}, FR3)
F({{530,1000},{610,1030},{650,1250},{510,1250}}, FR3)
F({{610,1030},{700,910},{750,910},{840,1020},{880,1250},{650,1250}}, FR3)

--@ chunk 16
wait(4 * 24 * 60)
-- the gauntlet at the bottom edge, holding the rosary: plates lit only on their upper-left edges, the rest lost in the dark
local Gm = poly({{300,1140},{390,1110},{440,1150},{450,1250},{300,1250}}, true)
work(Gm, {hand="detail", pile=T1, coverage=4, fill=true, clip=Gm})
local h = brush{kind="round", width=2.2, point=0.6}
local L = pile{{"lead white",1.2},{"raw sienna",0.6},{"bone brown",0.4},{"ultramarine ash",0.2}}
for k = 0, 3 do local y = 1150 + k * 20; h:reload(k == 0 and L or T3, 0.8); h:stroke({{306 + k * 4, y}, {360, y - 14}, {420, y - 8}}, {pressure={0.2, 0.55, 0.1}, ramps={0.2, 0.3}, clip=Gm:grow(1)}) end
-- rosary beads looping from the fist up over the knuckles and down out of the frame
local t = brush{kind="round", width=4.4, point=0.2}
for i = 0, 20 do local s = i / 20; local x = 340 + 90 * s + 30 * math.sin(s * math.pi * 1.4); local y = 1130 - 50 * math.sin(s * math.pi) + 80 * s * s
  t:reload(i % 5 == 0 and T3 or BGc, 0.85); t:touch(x + 0.8, y + 1, {pressure=0.45}); t:reload(i % 5 == 0 and L or FR1, 0.85); t:touch(x, y, {pressure=0.38}) end
-- a small bone cross hanging, catching a little light
local cx, cy = 446, 1210
h:reload(L, 0.85); h:stroke({{cx, cy}, {cx, cy + 28}}, {pressure={0.6, 0.6}}); h:reload(L, 0.85); h:stroke({{cx - 8, cy + 8}, {cx + 8, cy + 8}}, {pressure={0.6, 0.6}})

--@ chunk 17
wait(2 * 24 * 60)
IMP1 = pile{{"lead white",3},{"yellow ochre",0.7},{"raw sienna",0.25}}
IMP2 = pile{{"lead white",3},{"yellow ochre",0.35},{"zinc white",0.4}}
local cross = ribbon({{458,262},{470,482}}, 8) + ribbon({{414,318},{522,308}}, 8)
local dome = (poly(HF[1][1]) + poly(HF[2][1])) * HELM - cross
-- thick loaded strokes following the dome's curve, the fullest where the light strikes
local b = brush{kind="filbert", width=9}
for i, st in ipairs{{{344,440},{372,360},{420,300},{470,262}}, {{360,420},{392,350},{440,300},{500,262},{540,240}}, {{384,410},{420,350},{470,310},{530,280}}, {{350,470},{380,410},{420,370}}} do
  b:reload(i % 2 == 1 and IMP1 or IMP2, 1.0); b:stroke(st, {pressure={0.4, 0.9, 0.8, 0.3}, ramps={0.15, 0.4}, clip=dome})
end
stipple(dome * ellipse(420, 320, 80, 70), {pile=IMP2, width=3.6, coverage=0.5, cluster={0.6, 10}, pressure={0.6, 1.0}, dips={5, 1.0, 0}})

--@ chunk 18
wait(2 * 24 * 60)
-- the shadow side dissolves: the helm's right contour lost into the warm dark, a light halo line painted out
local ring = (HELM:grow(8) - HELM:shrink(10)) * rect(560, 300, 440, 620) - GRAFT2:grow(2)
work(ring, {hand="body", pile=BGc, coverage=2.5, fill=true, clip=ring, angle=math.pi/2, edge="soft"})
local ringL = (HELM:grow(6) - HELM:grow(0.5)) * rect(300, 500, 120, 420)
work(ringL, {hand="detail", pile=BGb, coverage=3.5, fill=true, clip=ringL})

--@ chunk 19
wait(4 * 24 * 60)
local dome = (poly(HF[1][1]) + poly(HF[2][1]) + poly(HF[5][1])) * HELM
local z1 = dome * ellipse(420, 320, 60, 54)
local z2 = dome * ellipse(420, 320, 120, 104) - z1
local z3 = dome - z1 - z2
work(z3, {hand="body", pile=T4, coverage=4, fill=true, clip=z3, angle=-0.6, tool="filbert 7"})
work(z2, {hand="body", pile=IMP1, coverage=4, fill=true, clip=z2, angle=-0.6, tool="filbert 7"})
work(z1, {hand="body", pile=IMP2, coverage=4.5, fill=true, clip=z1, angle=-0.6, tool="filbert 7", load=1.0})
blend(dome * (ellipse(420, 320, 70, 64) - ellipse(420, 320, 50, 45)), {angle=-0.6})
blend(dome * (ellipse(420, 320, 130, 114) - ellipse(420, 320, 110, 95)), {angle=-0.6})

--@ chunk 20
wait(3 * 24 * 60)
local dome = (poly(HF[1][1]) + poly(HF[2][1]) + poly(HF[5][1])) * HELM
local wedge = poly({{420,400},{482,300},{480,440},{440,440}}) * HELM - dome:shrink(0.5) - poly(HF[6][1])
work(wedge * ellipse(420, 320, 120, 104), {hand="detail", pile=IMP1, coverage=4, fill=true, clip=wedge})
work(wedge - ellipse(420, 320, 120, 104), {hand="detail", pile=T4, coverage=4, fill=true, clip=wedge})

--@ chunk 21
wait(3 * 24 * 60)
-- the cross, a ghost: thin broken lines of old gold sunk into the steel, a few flecks left in the scratches
GO = pile{{"raw sienna",1},{"yellow ochre",0.8},{"bone brown",0.3},{"lead white",0.25}}
local b = brush{kind="round", width=3.0, point=0.5}
local up = {} for i = 0, 12 do up[#up+1] = {450 + i * 1.6, 262 + i * 18} end
for i = 1, #up - 1 do if i % 4 ~= 2 then b:reload(GO, 0.6); b:stroke({up[i], up[i+1]}, {pressure={0.35, 0.45}, ramps={0.2, 0.2}, clip=HELM}) end end
local arm = {} for i = 0, 7 do arm[#arm+1] = {406 + i * 16, 318 - i * 1.4} end
for i = 1, #arm - 1 do if i % 3 ~= 1 then b:reload(GO, 0.6); b:stroke({arm[i], arm[i+1]}, {pressure={0.35, 0.45}, ramps={0.2, 0.2}, clip=HELM}) end end
local t = brush{kind="round", width=2.2, point=0.2}
for _, p in ipairs{{452,290},{456,340},{430,316},{486,312},{462,420}} do t:reload(pile{{"lead white",2},{"chrome yellow",0.5},{"yellow ochre",0.4}}, 0.9); t:touch(p[1], p[2], {pressure=0.35}) end
-- a few scratches and dents across the lit steel
local l = brush{kind="round", width=1.2, point=0.8}
for _, s in ipairs{{350,400,410,372},{380,336,426,306},{520,248,590,240},{560,330,612,350},{340,470,372,452}} do l:reload(pile{{"lead white",2},{"zinc white",0.5},{"raw sienna",0.2}}, 0.6); l:stroke({{s[1], s[2]}, {s[3], s[4]}}, {pressure={0.05, 0.4, 0.0}, ramps={0.2, 0.5}, clip=HELM}) end
for _, p in ipairs{{396,350,12},{560,290,10},{620,400,14}} do
  local arc = {} for i = 0, 6 do local a = math.pi * 0.9 + math.pi * 0.9 * i / 6; arc[#arc+1] = {p[1] + p[3] * math.cos(a), p[2] + p[3] * 0.6 * math.sin(a)} end
  l:reload(T1, 0.8); l:stroke(arc, {pressure={0.1, 0.6, 0.1}, ramps={0.3, 0.3}, clip=HELM})
end

--@ chunk 22
wait(3 * 24 * 60)
VD0 = pile{{"ultramarine ash",0.8},{"cobalt violet",0.3},{"bone black",0.9},{"bone brown",0.5},{"zinc white",0.12}}
local function quad(cx, cy, w, h, rot, skew)
  local p = {{-w, -h * 0.6}, {w * 0.8, -h}, {w, h * 0.7}, {-w * 0.7, h}}
  local t = {} for i, q in ipairs(p) do local x, y = q[1] + skew * q[2], q[2]; t[i] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)} end
  return poly(t, true)
end
local o = quad(650, 690, 70, 92, 0.25, 0.25) * HELM
local i = quad(650 + 70 * 0.16, 690 - 92 * 0.08, 70 * 0.618, 92 * 0.618, 0.75, 0.25)
work(o - i, {hand="detail", pile=VD0, coverage=4.5, fill=true, clip=o - i})
-- the rag's lit fold, repainted clean
local rag = RAG - HELM:grow(1)
local f = poly({{320,910},{440,870},{480,890},{400,1010},{360,1000}}) * rag
work(f, {hand="detail", pile=FR1, coverage=4.5, fill=true, clip=f})

--@ chunk 23
wait(3 * 24 * 60)
-- the dark side of the helm dissolves: soft strokes of the ground dragged across the right contour
local right = HELM * rect(600, 380, 300, 500) - poly({{560,600},{740,560},{740,820},{560,820}})
lose(right, {pile=BGc, where=1, reach={26, 18}, load=0.35, tool="filbert 6"})
local below = (HELM * rect(380, 800, 360, 100))
lose(below, {pile=FR3, where=0.8, reach={18, 12}, load=0.3, tool="filbert 6"})

--@ chunk 24
wait(5 * 24 * 60)
local slit = poly({{332,556},{400,544},{470,540},{560,546},{660,556},{734,566},{732,580},{660,574},{560,566},{470,562},{400,566},{332,580}})
local keep = GRAFT2:grow(1) + slit:grow(1) + ellipse(420, 561, 9, 7)
for _, k in ipairs{3, 4, 6, 8} do
  local m = (poly(HF[k][1]) * HELM:grow(2)) * rect(560, 0, 500, 2000) - keep
  if k == 6 then m = m - poly({{336,486},{460,466},{600,474},{740,488},{740,504},{600,492},{460,484},{332,506}}) end
  work(m, {hand="detail", pile=HF[k][2], coverage=4.5, fill=true, clip=m})
end
local lowr = (poly(HF[7][1]) + poly(HF[8][1])) * HELM * rect(0, 760, 1000, 200) - keep
work(lowr, {hand="detail", pile=S1, coverage=4.5, fill=true, clip=lowr})
-- right contour lost: the background just outside matched to the helm's dark value
local out = (HELM:grow(14) - HELM) * rect(600, 380, 400, 520) - RAG
work(out, {hand="detail", pile=BGc, coverage=4.5, fill=true, clip=out})

--@ chunk 25
wait(3 * 24 * 60)
local m5 = poly(HF[5][1]) * HELM * rect(560, 300, 200, 160) - ellipse(420, 320, 120, 104)
work(m5, {hand="detail", pile=T3, coverage=4.5, fill=true, clip=m5})
local m7 = poly(HF[7][1]) * HELM * rect(0, 700, 1000, 300)
work(m7, {hand="detail", pile=W1, coverage=4.5, fill=true, clip=m7})
local o = (HELM:grow(14) - HELM) * rect(330, 740, 300, 180) - RAG
work(o, {hand="detail", pile=BGc, coverage=4.5, fill=true, clip=o})
local r = (RAG * rect(330, 860, 140, 60)) - HELM
work(r, {hand="detail", pile=FR1, coverage=4.5, fill=true, clip=r})

--@ chunk 26
wait(3 * 24 * 60)
local function quad(cx, cy, w, h, rot, skew)
  local p = {{-w, -h * 0.6}, {w * 0.8, -h}, {w, h * 0.7}, {-w * 0.7, h}}
  local t = {} for i, q in ipairs(p) do local x, y = q[1] + skew * q[2], q[2]; t[i] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)} end
  return poly(t, true)
end
local cx, cy, w, h, rot = 650, 690, 70, 92, 0.25
local piles = {VD0, VD1, VD2}
for k = 1, 3 do
  local o = quad(cx, cy, w, h, rot, 0.25) * HELM
  local nx, ny = cx + w * 0.16, cy - h * 0.08
  local i = quad(nx, ny, w * 0.618, h * 0.618, rot + 0.5, 0.25)
  work(o - i:grow(0.5), {hand="detail", pile=piles[k], coverage=5, fill=true, clip=o - i:grow(0.5)})
  cx, cy, w, h, rot = nx, ny, w * 0.618, h * 0.618, rot + 0.5
end
local slit = poly({{332,556},{400,544},{470,540},{560,546},{660,556},{734,566},{732,580},{660,574},{560,566},{470,562},{400,566},{332,580}})
local band = HELM * rect(560, 520, 200, 110) - slit:grow(1) - GRAFT2:grow(1) - poly({{336,486},{460,466},{600,474},{740,488},{740,504},{600,492},{460,484},{332,506}})
local up = band * rect(0, 0, 2000, 552)
work(up, {hand="detail", pile=T2, coverage=4.5, fill=true, clip=up})
local dn = band * rect(0, 560, 2000, 200)
work(dn, {hand="detail", pile=S1, coverage=4.5, fill=true, clip=dn})

--@ chunk 27
wait(3 * 24 * 60)
local slit = poly({{332,556},{400,544},{470,540},{560,546},{660,556},{734,566},{732,580},{660,574},{560,566},{470,562},{400,566},{332,580}})
local r = HELM * rect(556, 500, 200, 56) - slit:grow(1) - poly({{336,486},{460,466},{600,474},{740,488},{740,504},{600,492},{460,484},{332,506}})
work(r, {hand="detail", pile=T1, coverage=4.5, fill=true, clip=r})
-- gauntlet sinks: its body to dark, only a few knuckle edges catching light
local Gm = poly({{300,1140},{390,1110},{440,1150},{450,1250},{300,1250}}, true)
work(Gm, {hand="detail", pile=FR3, coverage=4.5, fill=true, clip=Gm})
-- rag: the far side sinks further
local rag = RAG - HELM:grow(1)
local far = rag * poly({{600,880},{1000,880},{1000,1250},{560,1250}})
work(far, {hand="detail", pile=pile{{"bone brown",1.4},{"bone black",0.8},{"red earth",0.2}}, coverage=4.5, fill=true, clip=far})

--@ chunk 28
wait(3 * 24 * 60)
local h = brush{kind="round", width=2.4, point=0.6}
local L = pile{{"lead white",1.2},{"raw sienna",0.6},{"bone brown",0.4},{"ultramarine ash",0.2}}
-- knuckle plates: three short lit edges, the rest left to the dark
for k, s in ipairs{{{318,1150},{350,1138},{380,1132}}, {{326,1172},{356,1162},{386,1158}}, {{336,1196},{364,1188},{392,1186}}} do
  h:reload(k == 1 and L or T3, 0.85); h:stroke(s, {pressure={0.1, 0.55, 0.1}, ramps={0.25, 0.35}}) end
h:reload(T2, 0.85); h:stroke({{300,1160},{302,1250}}, {pressure={0.5, 0.5}})
-- rosary: beads a little clearer where they cross the light
local t = brush{kind="round", width=4.8, point=0.2}
for i = 0, 14 do local s = i / 14; local x = 352 + 90 * s; local y = 1128 - 30 * math.sin(s * math.pi) + 70 * s * s
  t:reload(BGc, 0.85); t:touch(x + 0.8, y + 1.2, {pressure=0.45}); t:reload(i < 8 and L or FR1, 0.85); t:touch(x, y, {pressure=0.38}) end
local c = brush{kind="round", width=2.4, point=0.5}
c:reload(L, 0.85); c:stroke({{446,1206},{446,1236}}, {pressure={0.6, 0.6}}); c:reload(L, 0.85); c:stroke({{438,1214},{454,1214}}, {pressure={0.6, 0.6}})
-- soft creases in the rag, a lit ridge at the left
local f = brush{kind="filbert", width=5}
f:reload(pile{{"red earth",0.6},{"raw sienna",0.5},{"bone brown",0.8},{"lead white",0.35}}, 0.7); f:stroke({{332,930},{300,1010},{270,1120}}, {pressure={0.1, 0.5, 0.1}, ramps={0.3, 0.3}})
f:reload(FR3, 0.7); f:stroke({{420,900},{396,1010},{380,1120}}, {pressure={0.1, 0.5, 0.1}, ramps={0.3, 0.3}})

--@ chunk 29
wait(2 * 24 * 60)
local o = ellipse(420, 561, 8, 5.5); work(o, {hand="detail", pile=pile{{"cerulean blue",1},{"zinc white",1.2},{"ultramarine ash",0.4}}, coverage=4.5, fill=true, clip=o})
local c = ellipse(419, 560.5, 3.8, 2.6); work(c, {hand="detail", pile=pile{{"zinc white",3},{"cerulean blue",0.4}}, coverage=4.5, fill=true, clip=c})
local g = brush{kind="round", width=1.6, point=0.6}
g:reload(pile{{"zinc white",1.5},{"cerulean blue",1},{"ultramarine ash",0.6}}, 0.7); g:stroke({{398,545},{420,541},{444,544}}, {pressure={0.05, 0.4, 0.05}, ramps={0.3, 0.3}})
g:reload(pile{{"zinc white",1.5},{"cerulean blue",1},{"ultramarine ash",0.6}}, 0.6); g:stroke({{400,579},{420,582},{442,580}}, {pressure={0.05, 0.3, 0.05}, ramps={0.3, 0.3}})
-- warm bounce from the rag on the chin of the face-plate
local f = brush{kind="filbert", width=6}
f:reload(pile{{"red earth",0.5},{"bone brown",1},{"raw sienna",0.3},{"lead white",0.15}}, 0.6)
f:stroke({{410,846},{470,872},{540,876}}, {pressure={0.05, 0.4, 0.05}, ramps={0.35, 0.35}, clip=HELM})
