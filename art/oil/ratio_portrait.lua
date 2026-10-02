-- easel session "ratio_portrait": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=41,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",1},{"lead white",0.5},{"raw sienna",0.5}}, um=35, apply="roller"}}}
print(W, H)

--@ chunk 2
-- silhouette: hair mass, face, neck, shoulders (rough, for keeping the background off the figure)
HAIRM = poly({{300,470},{318,330},{380,240},{470,196},{560,194},{650,232},{720,320},{748,450},{760,620},{780,800},{800,1000},{830,1180},{700,1180},{690,1000},{650,860},{360,860},{330,1000},{300,1180},{180,1180},{220,1000},{260,800},{285,620}}, true)
SHIRTM = poly({{330,880},{430,830},{580,830},{690,880},{820,980},{900,1250},{110,1250},{190,980}}, true)
FIGM = HAIRM + SHIRTM
BG1 = pile{{"bone brown",2},{"burnt sienna",0.7},{"bone black",0.6}}
BG2 = pile{{"bone brown",1.5},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.4}}
BG3 = pile{{"raw sienna",1.5},{"yellow ochre",0.6},{"bone brown",0.8},{"lead white",0.8}}
local bg = everywhere() - FIGM:grow(4)
work(bg * rect(380, 0, 620, 1250), {hand="broad", pile=BG1, coverage=2.6, fill=true, clip=bg, angle=math.pi/2 + 0.1})
work(bg * rect(0, 0, 420, 1250), {hand="broad", pile=BG2, coverage=2.6, fill=true, clip=bg, angle=math.pi/2 + 0.1})

--@ chunk 3
local bg = everywhere() - FIGM:grow(4)
local seam = bg * rect(340, 0, 130, 1250)
work(seam, {hand="body", pile=pile{{"bone brown",2},{"burnt sienna",0.7},{"raw sienna",0.5},{"bone black",0.3}}, coverage=1.6, clip=seam, angle=math.pi/2})
blend(seam, {angle=math.pi/2})
blend(bg * rect(0, 0, 340, 1250), {angle=math.pi/2})

--@ chunk 4
-- skin ramp (pale, warm in light, cooler-rose in shadow) and hair ramp (black-blue)
S1 = pile{{"raw sienna",1},{"bone brown",0.8},{"lead white",1.2},{"rose madder",0.4}}
S2 = pile{{"lead white",2},{"raw sienna",0.6},{"rose madder",0.3},{"bone brown",0.3}}
S3 = pile{{"lead white",3},{"yellow ochre",0.4},{"rose madder",0.25},{"raw sienna",0.2}}
S4 = pile{{"lead white",3},{"yellow ochre",0.3},{"vermilion",0.08}}
S5 = pile{{"lead white",3},{"zinc white",1},{"yellow ochre",0.2},{"vermilion",0.04}}
H1 = pile{{"bone black",1.2},{"ultramarine blue",0.8},{"bone brown",0.3}}
H2 = pile{{"bone black",1},{"ultramarine blue",1},{"lead white",0.25}}
H3 = pile{{"ultramarine blue",1},{"bone black",0.6},{"lead white",0.6},{"cobalt violet",0.15}}
H4 = pile{{"lead white",1.2},{"ultramarine ash",1},{"bone black",0.3},{"cerulean blue",0.2}}
FACE = poly({{372,430},{376,560},{410,650},{468,728},{560,700},{640,660},{686,560},{690,440},{530,420}})
NECK = poly({{440,690},{565,680},{578,850},{428,850}})
work(HAIRM - FACE - NECK, {hand="body", pile=H1, coverage=3, fill=true, clip=HAIRM, angle=math.pi/2})
work(FACE, {hand="body", pile=S3, coverage=3, fill=true, clip=FACE, angle=math.pi/2})
work(NECK - FACE, {hand="body", pile=S1, coverage=3, fill=true, clip=NECK, angle=math.pi/2})
local sh = SHIRTM - HAIRM - NECK
work(sh, {hand="body", pile=pile{{"lead white",2},{"raw sienna",0.3},{"ultramarine ash",0.3},{"bone brown",0.15}}, coverage=3, fill=true, clip=sh, angle=math.pi/2})

--@ chunk 5
wait(4 * 24 * 60)
print(drying(500, 550), drying(300, 700), drying(200, 300))
local bg = everywhere() - FIGM:grow(4)
local mid = pile{{"bone brown",2},{"burnt sienna",0.7},{"raw sienna",0.5},{"bone black",0.3}}
work(bg * rect(300, 0, 90, 1250), {hand="scumble", pile=mid, coverage=0.9, clip=bg, pressure={0.2, 0.5}})
work(bg * rect(380, 0, 120, 1250), {hand="scumble", pile=BG2, coverage=0.6, clip=bg, pressure={0.15, 0.4}})
work(bg * rect(440, 0, 140, 1250), {hand="scumble", pile=mid, coverage=0.7, clip=bg, pressure={0.2, 0.45}})

--@ chunk 6
V = {A={374,440}, M={528,424}, B={690,444}, H={482,512}, I={412,560}, J={572,566}, C={378,560}, D={686,560}, G={462,602}, N={488,612}, K={470,660}, L={604,624}, F={640,662}, E={468,728}, P={412,650}}
function facet(names, p, cov)
  local pts = {} for _, n in ipairs(names) do pts[#pts+1] = V[n] end
  local m = poly(pts) * FACE
  work(m, {hand="detail", pile=p, coverage=cov or 3, fill=true, clip=m, angle=math.pi/2})
  return m
end
FACETS = {
  {{"A","M","H","I"}, S4}, {{"M","B","J","H"}, S3}, {{"C","I","G","P"}, S4}, {{"I","H","G"}, S5},
  {{"H","J","N","G"}, S2}, {{"J","B","D"}, S2}, {{"J","D","L","N"}, S3}, {{"P","G","N","K"}, S4},
  {{"N","L","F","K"}, S2}, {{"P","K","E"}, S3}, {{"K","F","E"}, S1},
}
for _, f in ipairs(FACETS) do facet(f[1], f[2]) end

--@ chunk 7
-- crown and bangs: a fan of locks from the crown, each a flat plane; those turned to the window catch light
local Q = {512, 268}
local rim = {{300,470},{318,330},{380,240},{470,198},{560,196},{650,234},{720,322},{748,452}}
local bangs = {{748,452},{706,500},{672,462},{628,520},{596,470},{548,528},{518,474},{474,520},{440,470},{398,512},{362,468},{326,500},{300,470}}
local crownP = {H3, H4, H4, H3, H2, H2, H1}
for i = 1, #rim - 1 do
  local m = poly({Q, rim[i], rim[i+1]})
  work(m, {hand="detail", pile=crownP[i], coverage=3, fill=true, clip=m, angle=math.atan(rim[i][2] - Q[2], rim[i][1] - Q[1])})
end
for i = 1, #bangs - 1 do
  local m = poly({Q, bangs[i], bangs[i+1]})
  local x = (bangs[i][1] + bangs[i+1][1]) / 2
  local p = (x < 420) and H3 or (x < 520 and ((i % 2 == 0) and H3 or H2) or ((i % 2 == 0) and H2 or H1))
  work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m, angle=math.atan(bangs[i][2] - Q[2], bangs[i][1] - Q[1])})
end

--@ chunk 8
wait(4 * 24 * 60)
print(drying(500, 480), drying(420, 300))
HB = pile{{"bone black",1.2},{"ultramarine blue",0.9},{"lead white",0.3}}
HC = pile{{"bone black",1},{"ultramarine blue",1},{"lead white",0.55},{"ultramarine ash",0.3}}
local Q = {512, 268}
local rim = {{300,470},{318,330},{380,240},{470,198},{560,196},{650,234},{720,322},{748,452}}
local bangs = {{748,452},{706,500},{672,462},{628,520},{596,470},{548,528},{518,474},{474,520},{440,470},{398,512},{362,468},{326,500},{300,470}}
local crownP = {HB, HC, HC, HB, H2, H1, H1}
for i = 1, #rim - 1 do
  local m = poly({Q, rim[i], rim[i+1]})
  work(m, {hand="detail", pile=crownP[i], coverage=3, fill=true, clip=m, angle=math.atan(rim[i][2] - Q[2], rim[i][1] - Q[1])})
end
for i = 1, #bangs - 1 do
  local m = poly({Q, bangs[i], bangs[i+1]})
  local x = (bangs[i][1] + bangs[i+1][1]) / 2
  local p = (x < 420) and HB or (x < 560 and ((i % 2 == 0) and HB or H1) or H1)
  work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m, angle=math.atan(bangs[i][2] - Q[2], bangs[i][1] - Q[1])})
end

--@ chunk 9
EYE1 = pile{{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
EYE2 = pile{{"ultramarine blue",0.7},{"burnt sienna",0.5},{"bone black",0.5},{"lead white",0.45}}
EYEF = {{402,544},{432,526},{470,532},{484,575},{472,614},{432,620},{405,596}}
EYEN = {{562,542},{602,526},{642,536},{654,582},{642,624},{598,630},{567,602}}
for _, e in ipairs{EYEF, EYEN} do
  local m = poly(e)
  work(m, {hand="detail", pile=EYE1, coverage=3, fill=true, clip=m})
end
-- the lower half of each iris a lighter facet, catching the window
local lf = poly({{405,590},{484,575},{472,614},{432,620}}) * poly(EYEF)
work(lf, {hand="detail", pile=EYE2, coverage=3, fill=true, clip=lf})
local ln_ = poly({{567,598},{654,582},{642,624},{598,630}}) * poly(EYEN)
work(ln_, {hand="detail", pile=EYE2, coverage=3, fill=true, clip=ln_})

--@ chunk 10
wait(3 * 24 * 60)
BL = pile{{"lead white",2},{"rose madder",0.6},{"vermilion",0.2}}
MO = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.3},{"lead white",0.3}}
LIP = pile{{"lead white",2},{"rose madder",0.5},{"raw sienna",0.2}}
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
-- upper lids: heavy flat bands, a flick outward
F({{398,548},{432,522},{472,528},{488,546},{474,540},{432,534},{404,556},{392,560}}, H1)
F({{556,546},{602,520},{646,530},{664,548},{676,540},{660,556},{642,542},{602,534},{564,552}}, H1)
-- square highlights: one large up toward the window, one small below
F({{416,552},{434,552},{434,570},{416,570}}, S5)
F({{456,596},{464,596},{464,604},{456,604}}, S5)
F({{578,552},{598,552},{598,572},{578,572}}, S5)
F({{624,604},{633,604},{633,613},{624,613}}, S5)
-- blush facets
F({{414,630},{452,636},{434,648}}, BL)
F({{606,642},{652,632},{640,654}}, BL)
-- the mouth, a little open, about to speak
F({{480,664},{506,662},{502,672},{484,673}}, MO)
F({{484,673},{502,672},{498,678},{487,678}}, LIP)

--@ chunk 11
wait(2 * 24 * 60)
-- a lock: a bent strip of flat planes; its left half faces the window
function lock(pts, w, lit, dark, hi)
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i+1]
    local wa, wb = w * (1 - 0.15 * (i - 1) / #pts), w * (1 - 0.15 * i / #pts)
    local L = poly({{a[1] - wa, a[2]}, {a[1], a[2]}, {b[1], b[2]}, {b[1] - wb, b[2]}}) * HAIRM
    local R = poly({{a[1], a[2]}, {a[1] + wa, a[2]}, {b[1] + wb, b[2]}, {b[1], b[2]}}) * HAIRM
    local bend = (b[1] - a[1]) / (b[2] - a[2])
    work(L, {hand="detail", pile=(bend < 0.05) and lit or dark, coverage=3, fill=true, clip=L, angle=math.pi/2})
    work(R, {hand="detail", pile=dark, coverage=3, fill=true, clip=R, angle=math.pi/2})
  end
end
-- far side (toward the window)
lock({{334,500},{318,640},{300,800},{276,960},{240,1120},{226,1176}}, 30, HC, H2)
lock({{376,520},{364,660},{356,820},{340,980},{320,1176}}, 22, HB, H1)
-- near side, in shadow; a cool reflected light on a plane or two
lock({{700,500},{716,640},{730,800},{748,960},{770,1176}}, 30, H2, H1)
lock({{660,540},{668,700},{676,860},{688,1020},{700,1176}}, 22, HB, H1)

--@ chunk 12
-- the room behind her as large flat facets, lighter toward the window on the left
local BGM = pile{{"bone brown",2},{"burnt sienna",0.7},{"raw sienna",0.5},{"bone black",0.3}}
local BGD = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.5}}
local ramp = {BG3, BG2, BGM, BG1, BGD}
local xs = {0, 170, 350, 540, 730, 880, 1000}
local ys = {0, 280, 620, 940, 1250}
local P = {}
for j, y in ipairs(ys) do P[j] = {} for i, x in ipairs(xs) do
  local jx = (i > 1 and i < #xs) and 30 * math.sin(i * 2.3 + j * 1.7) or 0
  local jy = (j > 1 and j < #ys) and 40 * math.cos(i * 1.9 + j * 2.9) or 0
  P[j][i] = {x + jx, y + jy} end end
local bg = everywhere() - FIGM:grow(1)
for j = 1, #ys - 1 do for i = 1, #xs - 1 do
  local a, b, c, d = P[j][i], P[j][i+1], P[j+1][i+1], P[j+1][i]
  for t = 1, 2 do
    local tri = (t == 1) and {a, b, c} or {a, c, d}
    local cx = (tri[1][1] + tri[2][1] + tri[3][1]) / 3
    local k = clamp(math.floor(cx / 210) + 1 + ((i + j + t) % 2 == 0 and 0 or 1), 1, 5)
    local m = poly(tri) * bg
    if m:area() > 10 then work(m, {hand="body", pile=ramp[k], coverage=2.6, fill=true, clip=m, angle=math.pi/2 + 0.1 * t}) end
  end
end end

--@ chunk 13
W5 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.25}}
W4 = pile{{"lead white",3},{"raw sienna",0.25},{"ultramarine ash",0.15}}
W3 = pile{{"lead white",2},{"ultramarine ash",0.5},{"raw sienna",0.3},{"bone brown",0.15}}
W2 = pile{{"lead white",1.5},{"ultramarine ash",0.6},{"bone brown",0.4},{"raw sienna",0.3}}
OR = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.4}}
ORD = pile{{"Mars orange",1},{"burnt sienna",0.6},{"bone brown",0.2}}
NS = pile{{"raw sienna",1},{"bone brown",1},{"rose madder",0.4},{"lead white",0.6}}
local sh = SHIRTM - HAIRM:shrink(1) - NECK
local function F(pts, p, hand) local m = poly(pts) * sh; work(m, {hand=hand or "body", pile=p, coverage=3, fill=true, clip=m, angle=math.pi/2, tool="filbert 6"}) end
F({{100,1250},{190,980},{330,880},{430,840},{400,960},{300,1250}}, W5)
F({{430,840},{580,840},{560,960},{400,960}}, W4)
F({{400,960},{560,960},{620,1250},{300,1250}}, W4)
F({{580,840},{690,880},{820,980},{700,1050},{560,960}}, W3)
F({{560,960},{700,1050},{820,980},{900,1250},{620,1250}}, W2)
-- the collar, a band of orange round the neck, its far side lit
local col = poly({{424,830},{582,826},{596,852},{560,886},{500,900},{444,888},{412,858}}) - poly({{440,838},{566,834},{552,866},{500,878},{452,868}})
work(col * rect(0, 0, 500, 2000), {hand="detail", pile=OR, coverage=3, fill=true, clip=col})
work(col * rect(500, 0, 500, 2000), {hand="detail", pile=ORD, coverage=3, fill=true, clip=col})
local inner = poly({{440,838},{566,834},{552,866},{500,878},{452,868}})
work(inner, {hand="detail", pile=NS, coverage=3, fill=true, clip=inner})
-- neck: the far plane lit, a cast shadow under the jaw
local nl = poly({{440,700},{470,700},{462,850},{428,850}})
work(nl, {hand="detail", pile=S3, coverage=3, fill=true, clip=nl})
local nc = poly({{466,724},{566,690},{572,770},{500,760}})
work(nc, {hand="detail", pile=NS, coverage=3, fill=true, clip=nc})

--@ chunk 14
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
-- a fuller, lower jaw: the chin brought down, the cheeks rounded out in two more planes
F({{378,560},{412,650},{440,724},{404,660}}, S4)
F({{412,650},{470,660},{492,782},{440,724}}, S4)
F({{470,660},{640,662},{596,746},{492,782}}, S2)
F({{640,662},{686,560},{676,640},{596,746}}, S1)
-- the shadow the jaw throws on the neck
F({{444,792},{492,782},{596,746},{572,812},{500,820}}, NS)

--@ chunk 15
wait(2 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
F({{484,700},{514,697},{510,710},{490,711}}, MO)
F({{490,711},{510,710},{506,717},{494,717}}, LIP)
-- the near hair lock comes back over the cheek's edge
F({{690,440},{700,520},{684,620},{652,720},{612,800},{660,800},{700,700},{724,600},{730,500}}, H1)

--@ chunk 16
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
F({{506,612},{520,654},{502,662}}, S4)
F({{506,612},{530,650},{520,654}}, S1)
F({{502,662},{520,654},{530,660},{512,668}}, NS)

--@ chunk 17
wait(2 * 24 * 60)
local function F(pts, p) local m = poly(pts) * HAIRM; work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
-- crown: two narrow lit planes on the window side, like light on a carved surface
F({{512,268},{380,240},{400,232},{470,206}}, H4)
F({{512,268},{330,330},{340,312},{384,250}}, H3)
-- the top of the far lock where it turns over the shoulder
F({{304,500},{334,500},{330,560},{300,570}}, H4)
F({{300,570},{330,560},{318,660},{294,650}}, H3)
-- a thin light plane down the near lock
F({{676,700},{688,700},{700,860},{688,860}}, H2)

--@ chunk 18
-- the hair's outline as straight facets: lay the background over the dome outside a polygon
local hp = poly({{300,470},{312,360},{356,272},{420,222},{500,196},{590,200},{664,240},{716,312},{744,420},{754,560},{772,760},{796,980},{826,1180},{180,1180},{214,980},{252,780},{280,600}})
local cut = HAIRM - hp
local left = cut * rect(0, 0, 500, 1250)
local right = cut * rect(500, 0, 500, 1250)
work(left, {hand="detail", pile=BG2, coverage=3, fill=true, clip=left})
work(right, {hand="detail", pile=BG1, coverage=3, fill=true, clip=right})

--@ chunk 19
-- more locks in the dark masses, as mid planes, so the hair reads as carved strands
local function F(pts, p) local m = poly(pts) * HAIRM; work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
F({{250,780},{280,780},{262,960},{232,960}}, HB)
F({{232,960},{262,960},{240,1120},{212,1120}}, H2)
F({{396,700},{416,700},{410,860},{392,860}}, H2)
F({{716,620},{734,620},{752,800},{736,800}}, H2)
F({{736,800},{752,800},{776,980},{760,980}}, HB)
F({{620,800},{650,800},{664,1000},{640,1000}}, H2)

--@ chunk 20
wait(2 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
-- the collar as three flat planes of a folded band: lit front-left, mid front, shadowed right
F({{412,850},{430,832},{470,846},{466,888},{444,888}}, OR)
F({{470,846},{540,842},{544,890},{500,900},{466,888}}, pile{{"Mars orange",1},{"cadmium yellow",0.2},{"burnt sienna",0.3},{"lead white",0.2}})
F({{540,842},{582,828},{596,852},{560,886},{544,890}}, ORD)
-- the opening at the throat, in shadow
F({{446,838},{470,846},{540,842},{564,834},{540,830},{470,834}}, NS)

--@ chunk 21
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
BL2 = pile{{"lead white",3},{"rose madder",0.35},{"vermilion",0.15},{"yellow ochre",0.15}}
F({{410,626},{456,632},{440,652},{404,640}}, BL2)
F({{604,640},{654,630},{646,656},{612,656}}, BL2)

--@ chunk 22
wait(2 * 24 * 60)
-- the irises: a mid facet between the dark top and the lit lower plane, and a pupil
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
EYE3 = pile{{"ultramarine blue",0.8},{"bone black",0.6},{"burnt sienna",0.3},{"lead white",0.25}}
F({{408,578},{484,566},{484,578},{406,592}}, EYE3)
F({{566,584},{654,570},{654,584},{568,598}}, EYE3)
F({{440,568},{456,566},{458,590},{442,592}}, EYE1)
F({{604,574},{620,572},{622,596},{606,598}}, EYE1)

--@ chunk 23
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
F({{388,568},{404,600},{400,618},{384,590}}, S5)
F({{474,512},{500,520},{486,540}}, S5)
COOL = pile{{"lead white",2},{"ultramarine ash",0.6},{"rose madder",0.2},{"raw sienna",0.3}}
F({{606,744},{640,690},{646,696},{614,752}}, COOL)

--@ chunk 24
wait(2 * 24 * 60)
local sp = poly({{60,1250},{110,1080},{170,990},{250,940},{330,890},{690,890},{780,940},{860,1000},{920,1100},{950,1250}})
local cut = SHIRTM - sp - HAIRM
work(cut * rect(0,0,500,1250), {hand="detail", pile=BG2, coverage=3, fill=true, clip=cut})
work(cut * rect(500,0,500,1250), {hand="detail", pile=BG1, coverage=3, fill=true, clip=cut})
local sh = (SHIRTM * sp) - HAIRM - NECK
local function F(pts, p) local m = poly(pts) * sh; work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}) end
F({{60,1250},{110,1080},{170,990},{230,1100},{180,1250}}, W5)
F({{170,990},{250,940},{300,1040},{230,1100}}, W4)
F({{230,1100},{300,1040},{400,1250},{180,1250}}, W4)
F({{780,940},{860,1000},{830,1100},{760,1040}}, W3)
F({{760,1040},{830,1100},{860,1250},{720,1250}}, W2)
F({{860,1000},{920,1100},{950,1250},{860,1250},{830,1100}}, W3)

--@ chunk 25
local band = poly({{330,890},{430,836},{580,836},{690,890}}) - HAIRM:shrink(2)
work(band * rect(0,0,505,1250), {hand="detail", pile=W4, coverage=3, fill=true, clip=band})
work(band * rect(505,0,500,1250), {hand="detail", pile=W3, coverage=3, fill=true, clip=band})
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=m}); return m end
F({{412,850},{430,832},{470,846},{466,888},{444,888}}, OR)
F({{470,846},{540,842},{544,890},{500,900},{466,888}}, pile{{"Mars orange",1},{"cadmium yellow",0.2},{"burnt sienna",0.3},{"lead white",0.2}})
F({{540,842},{582,828},{596,852},{560,886},{544,890}}, ORD)
F({{446,838},{470,846},{540,842},{564,834},{540,830},{470,834}}, NS)

--@ chunk 26
wait(3 * 24 * 60)
local col = poly({{412,850},{430,832},{582,828},{596,852},{560,886},{500,900},{444,888}})
local band = poly({{320,900},{430,836},{580,836},{700,900}}) - HAIRM:shrink(2) - col
work(band * rect(0,0,505,1250), {hand="detail", pile=W4, coverage=3.5, fill=true, clip=band})
work(band * rect(505,0,500,1250), {hand="detail", pile=W3, coverage=3.5, fill=true, clip=band})

--@ chunk 27
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
F({{412,850},{430,832},{470,846},{466,888},{444,888}}, OR)
F({{470,846},{540,842},{544,890},{500,900},{466,888}}, pile{{"Mars orange",1},{"cadmium yellow",0.2},{"burnt sienna",0.3},{"lead white",0.2}})
F({{540,842},{582,828},{596,852},{560,886},{544,890}}, ORD)
F({{446,838},{470,846},{540,842},{564,834},{540,830},{470,834}}, NS)
-- shoulder tops, where the brown still shows
local sl = poly({{330,896},{400,860},{412,850},{444,888},{340,906}}) - HAIRM:shrink(2)
work(sl, {hand="detail", pile=W5, coverage=3.5, fill=true, clip=sl})
local sr = poly({{596,852},{620,860},{690,896},{680,906},{560,886}}) - HAIRM:shrink(2)
work(sr, {hand="detail", pile=W3, coverage=3.5, fill=true, clip=sr})

--@ chunk 28
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
F({{328,850},{378,846},{344,892},{322,900}}, H1)
F({{646,846},{700,850},{706,900},{684,894}}, H1)

--@ chunk 29
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
F({{404,516},{440,504},{474,494},{476,501},{442,512},{406,523}}, H1)
F({{566,496},{604,500},{640,512},{638,519},{602,508},{566,503}}, H1)

--@ chunk 30
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
F({{604,746},{640,688},{650,694},{616,754}}, pile{{"raw sienna",1},{"bone brown",0.6},{"lead white",0.9},{"ultramarine ash",0.5},{"rose madder",0.2}})

--@ chunk 31
local WIN = pile{{"lead white",3},{"yellow ochre",0.8},{"raw sienna",0.3}}
local WIN2 = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.6}}
local m1 = poly({{0,60},{120,40},{150,330},{0,360}}) - FIGM:grow(2)
work(m1, {hand="detail", pile=WIN, coverage=3, fill=true, clip=m1})
local m2 = poly({{0,360},{150,330},{110,420},{0,440}}) - FIGM:grow(2)
work(m2, {hand="detail", pile=WIN2, coverage=3, fill=true, clip=m2})
local bar = poly({{0,200},{136,188},{137,200},{0,212}}) + poly({{58,48},{70,47},{86,340},{74,342}})
work(bar, {hand="detail", pile=BG2, coverage=3, fill=true, clip=bar})

--@ chunk 32
local function F(pts, p) local m = poly(pts) * HAIRM; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
-- left: V tips between the strands
F({{170,1100},{214,1186},{170,1190}}, W5)
F({{214,1186},{246,1120},{270,1190}}, W5)
F({{270,1190},{290,1110},{310,1190}}, W4)
-- right
F({{690,1190},{716,1110},{742,1190}}, W2)
F({{742,1190},{770,1130},{800,1190}}, W2)
F({{800,1190},{830,1100},{850,1190}}, W2)

--@ chunk 33
local l = (HAIRM:grow(8) - poly({{170,1100},{214,1186},{246,1120},{270,1190},{290,1110},{310,1190},{330,1000},{300,700},{180,1000}})) * rect(150, 1030, 200, 220)
local l2 = ellipse(235, 1190, 75, 18) - HAIRM:shrink(0) + l
l2 = l2 - poly({{180,1000},{170,1100},{214,1186},{246,1120},{270,1190},{290,1110},{310,1190},{330,1000}})
work(l2, {hand="detail", pile=W5, coverage=3.5, fill=true, clip=l2})
local r = ellipse(765, 1190, 80, 18) + (HAIRM:grow(8) - HAIRM) * rect(680, 1030, 200, 220)
r = r - poly({{690,1000},{690,1190},{716,1110},{742,1190},{770,1130},{800,1190},{830,1100},{850,1190},{830,1000}})
work(r, {hand="detail", pile=W2, coverage=3.5, fill=true, clip=r})

--@ chunk 34
wait(2 * 24 * 60)
SCAN = pile{{"bone black",1},{"ultramarine blue",0.4},{"bone brown",0.5}, medium=0.6}
SCB = brush{kind="rigger", width=1.4, point=0.6}
function scan(y0, y1)
  for y = y0, y1, 9 do
    SCB:reload(SCAN, 0.25)
    SCB:stroke({{-5, y}, {1005, y + 0.5}}, {pressure={0.18, 0.18}, ramps={0.02, 0.02}})
  end
end
scan(4, 200)

--@ chunk 35
scan(4 + 9 * 22, 700)

--@ chunk 36
scan(4 + 9 * 78, 1250)

--@ chunk 37
-- the screen: a rounded rectangle whose sides bow outward
local pts = {}
local function sq(t) return t * t end
local x0, x1, y0, y1, r, bow = 26, 974, 26, 1224, 80, 10
local function add(x, y) pts[#pts+1] = {x, y} end
local N = 24
for i = 0, N do local t = i / N; add(lerp(x0 + r, x1 - r, t), y0 - bow * math.sin(math.pi * t)) end
for i = 1, 8 do local a = -math.pi / 2 + (math.pi / 2) * i / 8; add(x1 - r + r * math.cos(a), y0 + r + r * math.sin(a)) end
for i = 1, N do local t = i / N; add(x1 + bow * math.sin(math.pi * t), lerp(y0 + r, y1 - r, t)) end
for i = 1, 8 do local a = (math.pi / 2) * i / 8; add(x1 - r + r * math.cos(a), y1 - r + r * math.sin(a)) end
for i = 1, N do local t = i / N; add(lerp(x1 - r, x0 + r, t), y1 + bow * math.sin(math.pi * t)) end
for i = 1, 8 do local a = math.pi / 2 + (math.pi / 2) * i / 8; add(x0 + r + r * math.cos(a), y1 - r + r * math.sin(a)) end
for i = 1, N do local t = i / N; add(x0 - bow * math.sin(math.pi * t), lerp(y1 - r, y0 + r, t)) end
for i = 1, 7 do local a = math.pi + (math.pi / 2) * i / 8; add(x0 + r + r * math.cos(a), y0 + r + r * math.sin(a)) end
SCREEN = poly(pts)
local bez = everywhere() - SCREEN
work(bez, {hand="body", pile=pile{{"bone black",1.2},{"bone brown",0.6},{"ultramarine blue",0.3}}, coverage=3, fill=true, clip=bez, angle=0})

--@ chunk 38
local g = brush{kind="filbert", width=10}
local GL = pile{{"lead white",2},{"zinc white",1}, medium=0.5}
local pts = {}
for i = 0, 12 do local a = math.pi * 1.02 + (math.pi * 0.46) * i / 12; pts[#pts+1] = {150 + 108 * math.cos(a), 150 + 108 * math.sin(a)} end
g:reload(GL, 0.35); g:stroke(pts, {pressure={0.0, 0.35, 0.0}, ramps={0.4, 0.4}, clip=SCREEN})
local h = brush{kind="round", width=2.0, point=0.7}
local p2 = {}
for i = 0, 10 do local a = math.pi * 1.06 + (math.pi * 0.4) * i / 10; p2[#p2+1] = {150 + 118 * math.cos(a), 150 + 118 * math.sin(a)} end
h:reload(GL, 0.5); h:stroke(p2, {pressure={0.0, 0.5, 0.0}, ramps={0.4, 0.4}, clip=SCREEN})

--@ chunk 39
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
F({{600,750},{640,686},{654,692},{618,758}}, S1)
F({{596,746},{640,662},{650,664},{610,750}}, S1)

--@ chunk 40
wait(2 * 24 * 60)
WS3 = pile{{"lead white",2},{"raw sienna",0.6},{"ultramarine ash",0.5},{"bone brown",0.35}}
WS2 = pile{{"lead white",1.5},{"raw sienna",0.6},{"ultramarine ash",0.6},{"bone brown",0.6}}
WS1 = pile{{"lead white",1},{"raw sienna",0.6},{"ultramarine ash",0.6},{"bone brown",0.9}}
local sh = SCREEN * (SHIRTM - HAIRM:shrink(1) - NECK) - poly({{400,820},{600,820},{600,905},{400,905}})
local hair_tips = poly({{170,1100},{214,1186},{246,1120},{270,1190},{290,1110},{310,1190},{330,1000},{180,1000}}) + poly({{690,1000},{690,1190},{716,1110},{742,1190},{770,1130},{800,1190},{830,1100},{850,1190},{830,1000}})
sh = sh - (hair_tips * HAIRM)
local function F(pts, p) local m = poly(pts) * sh; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F({{400,960},{560,960},{620,1250},{300,1250}}, WS3)
F({{560,960},{700,1050},{820,980},{900,1250},{620,1250}}, WS1)
F({{760,1040},{830,1100},{860,1250},{720,1250}}, WS1)
F({{860,1000},{920,1100},{950,1250},{860,1250},{830,1100}}, WS2)
F({{780,940},{860,1000},{830,1100},{760,1040}}, WS2)
F({{580,840},{690,880},{820,980},{700,1050},{560,960}}, WS2)
F({{230,1100},{300,1040},{400,1250},{180,1250}}, WS3)
F({{430,840},{580,840},{560,960},{400,960}}, W3)

--@ chunk 41
local function F(pts, p) local m = poly(pts) * (HAIRM:grow(10)); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F({{170,1100},{214,1186},{170,1196}}, WS3)
F({{214,1186},{246,1120},{270,1196}}, WS3)
F({{270,1196},{290,1110},{310,1196}}, WS3)
F({{690,1196},{716,1110},{742,1196}}, WS1)
F({{742,1196},{770,1130},{800,1196}}, WS1)
F({{800,1196},{830,1100},{856,1196}}, WS1)
local lb = (ellipse(235, 1192, 80, 20) + ellipse(770, 1192, 90, 20)) * SCREEN - HAIRM:shrink(1)
work(lb * rect(0,0,500,1250), {hand="detail", pile=WS3, coverage=3.5, fill=true, clip=lb})
work(lb * rect(500,0,500,1250), {hand="detail", pile=WS1, coverage=3.5, fill=true, clip=lb})

--@ chunk 42
wait(2 * 24 * 60)
local m = SCREEN * (SHIRTM - HAIRM - NECK) * rect(0, 900, 1000, 350)
for y = 4 + 9 * 100, 1250, 9 do
  SCB:reload(SCAN, 0.25)
  SCB:stroke({{-5, y}, {1005, y + 0.5}}, {pressure={0.18, 0.18}, ramps={0.02, 0.02}, clip=m})
end

--@ chunk 43
HP = poly({{300,470},{312,360},{356,272},{420,222},{500,196},{590,200},{664,240},{716,312},{744,420},{754,560},{772,760},{796,980},{826,1180},{180,1180},{214,980},{252,780},{280,600}})
RING = (HAIRM:grow(9) - HP) * rect(0, 0, 1000, 900)
local BGM = pile{{"bone brown",2},{"burnt sienna",0.7},{"raw sienna",0.5},{"bone black",0.3}}
work(RING * rect(0, 0, 470, 1250), {hand="detail", pile=BGM, coverage=3.5, fill=true, clip=RING})
work(RING * rect(470, 0, 530, 1250), {hand="detail", pile=BG1, coverage=3.5, fill=true, clip=RING})

--@ chunk 44
local zone = RING * poly({{250,0},{486,0},{478,186},{325,300},{250,300}})
work(zone, {hand="detail", pile=BG2, coverage=3.5, fill=true, clip=zone})

--@ chunk 45
wait(4 * 24 * 60)
print(drying(400, 220))
local zone = RING * poly({{250,0},{486,0},{478,186},{325,300},{250,300}})
work(zone, {hand="detail", pile=BG2, coverage=3.5, fill=true, clip=zone})

--@ chunk 46
wait(2 * 24 * 60)
for y = 4, 900, 9 do
  SCB:reload(SCAN, 0.25)
  SCB:stroke({{-5, y}, {1005, y + 0.5}}, {pressure={0.18, 0.18}, ramps={0.02, 0.02}, clip=RING})
end

--@ chunk 47
local RIM = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.3},{"ultramarine ash",0.2}}
local r = brush{kind="round", width=2.6, point=0.6}
local edge = {{356,274},{312,360},{300,470},{280,600},{252,780},{226,920}}
r:reload(RIM, 0.7); r:stroke(edge, {pressure={0.1, 0.6, 0.5, 0.0}, ramps={0.2, 0.4}, clip=HAIRM:grow(1)})
r:reload(RIM, 0.7); r:stroke({{420,222},{390,240},{356,274}}, {pressure={0.1, 0.55, 0.3}, ramps={0.2, 0.3}, clip=HAIRM:grow(1)})
-- clean the bottom bezel edge
local bz = (everywhere() - SCREEN) * rect(0, 1190, 1000, 60)
work(bz, {hand="detail", pile=pile{{"bone black",1.2},{"bone brown",0.6},{"ultramarine blue",0.3}}, coverage=3, fill=true, clip=bz})
