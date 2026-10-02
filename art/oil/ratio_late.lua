-- easel session "ratio_late": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=43,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",1},{"lead white",0.5},{"raw sienna",0.5}}, um=35, apply="roller"}}}

--@ chunk 2
HAIRP = {{300,470},{312,360},{356,272},{420,222},{500,196},{590,200},{664,240},{716,312},{744,420},{756,560},{774,760},{800,980},{832,1150},{850,1250},{150,1250},{176,1150},{210,980},{248,780},{278,600}}
HAIRM = poly(HAIRP)
SHIRTM = poly({{330,880},{430,830},{580,830},{690,880},{820,980},{900,1250},{110,1250},{190,980}}, true)
FIGM = HAIRM + SHIRTM
BG1 = pile{{"bone brown",2},{"burnt sienna",0.7},{"bone black",0.6}}
BG2 = pile{{"bone brown",1.5},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.4}}
BG3 = pile{{"raw sienna",1.5},{"yellow ochre",0.6},{"bone brown",0.8},{"lead white",0.8}}
BGM = pile{{"bone brown",2},{"burnt sienna",0.7},{"raw sienna",0.5},{"bone black",0.3}}
BGD = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.5}}
local ramp = {BG3, BG2, BGM, BG1, BGD}
local xs = {0, 170, 350, 540, 730, 880, 1000}
local ys = {0, 280, 620, 940, 1250}
local P = {}
for j, y in ipairs(ys) do P[j] = {} for i, x in ipairs(xs) do
  local jx = (i > 1 and i < #xs) and 30 * math.sin(i * 2.9 + j * 1.3) or 0
  local jy = (j > 1 and j < #ys) and 40 * math.cos(i * 1.4 + j * 2.6) or 0
  P[j][i] = {x + jx, y + jy} end end
local bg = everywhere() - FIGM:grow(1)
for j = 1, #ys - 1 do for i = 1, #xs - 1 do
  local a, b, c, d = P[j][i], P[j][i+1], P[j+1][i+1], P[j+1][i]
  for t = 1, 2 do
    local tri = (t == 1) and {a, b, c} or {a, c, d}
    local cx = (tri[1][1] + tri[2][1] + tri[3][1]) / 3
    local k = clamp(math.floor(cx / 210) + 1 + ((i + j + t) % 2 == 0 and 0 or 1), 1, 5)
    local m = poly(tri) * bg
    if m:area() > 10 then work(m, {hand="detail", pile=ramp[k], coverage=3.5, fill=true, clip=m}) end
  end
end end

--@ chunk 3
S1 = pile{{"raw sienna",1},{"bone brown",0.8},{"lead white",1.2},{"rose madder",0.4}}
S2 = pile{{"lead white",2},{"raw sienna",0.6},{"rose madder",0.3},{"bone brown",0.3}}
S3 = pile{{"lead white",3},{"yellow ochre",0.4},{"rose madder",0.25},{"raw sienna",0.2}}
S4 = pile{{"lead white",3},{"yellow ochre",0.3},{"vermilion",0.08}}
S5 = pile{{"lead white",3},{"zinc white",1},{"yellow ochre",0.2},{"vermilion",0.04}}
H1 = pile{{"bone black",1.2},{"ultramarine blue",0.8},{"bone brown",0.3}}
H2 = pile{{"bone black",1},{"ultramarine blue",1},{"lead white",0.25}}
H3 = pile{{"ultramarine blue",1},{"bone black",0.6},{"lead white",0.6},{"cobalt violet",0.15}}
H4 = pile{{"lead white",1.2},{"ultramarine ash",1},{"bone black",0.3},{"cerulean blue",0.2}}
HB = pile{{"bone black",1.2},{"ultramarine blue",0.9},{"lead white",0.3}}
HC = pile{{"bone black",1},{"ultramarine blue",1},{"lead white",0.55},{"ultramarine ash",0.3}}
NS = pile{{"raw sienna",1},{"bone brown",1},{"rose madder",0.4},{"lead white",0.6}}
-- the face drawn with its fuller lower jaw from the start
FACE = poly({{372,430},{376,560},{404,660},{440,724},{492,782},{596,746},{676,640},{690,560},{690,440},{530,420}})
NECK = poly({{444,760},{576,730},{582,850},{430,850}})
work(HAIRM - FACE - NECK, {hand="body", pile=H1, coverage=3, fill=true, clip=HAIRM, angle=math.pi/2})
work(FACE, {hand="body", pile=S3, coverage=3, fill=true, clip=FACE, angle=math.pi/2})
work(NECK - FACE, {hand="body", pile=NS, coverage=3, fill=true, clip=NECK, angle=math.pi/2})
local sh = SHIRTM - HAIRM - NECK
work(sh, {hand="body", pile=pile{{"lead white",2},{"raw sienna",0.5},{"ultramarine ash",0.5},{"bone brown",0.3}}, coverage=3, fill=true, clip=sh, angle=math.pi/2})

--@ chunk 4
wait(4 * 24 * 60)
W5 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.25}}
W3 = pile{{"lead white",2},{"ultramarine ash",0.5},{"raw sienna",0.3},{"bone brown",0.15}}
WS3 = pile{{"lead white",2},{"raw sienna",0.6},{"ultramarine ash",0.5},{"bone brown",0.35}}
WS1 = pile{{"lead white",1},{"raw sienna",0.6},{"ultramarine ash",0.6},{"bone brown",0.9}}
CHEST = poly({{372,850},{436,826},{580,826},{648,850},{700,1000},{736,1250},{262,1250},{320,1000}})
LOCKL = poly({{248,780},{278,600},{300,470},{376,520},{360,700},{340,860},{300,1020},{262,1250},{150,1250},{176,1150},{210,980}})
LOCKR = poly({{690,560},{756,560},{774,760},{800,980},{832,1150},{850,1250},{736,1250},{700,1000},{676,860},{676,700}})
local ch = CHEST - NECK - LOCKL - LOCKR
work(ch * rect(0,0,505,2000), {hand="detail", pile=WS3, coverage=3.5, fill=true, clip=ch})
work(ch * rect(505,0,500,2000), {hand="detail", pile=WS1, coverage=3.5, fill=true, clip=ch})
-- face facets, the same carved planes, the lower jaw in place
V = {A={374,440}, M={528,424}, B={690,444}, H={482,512}, I={412,560}, J={572,566}, C={378,560}, D={686,560}, G={462,602}, N={488,612}, K={470,660}, L={604,624}, F={640,662}, E={468,728}, P={412,650}, Q={440,724}, R={492,782}, T={596,746}, U={676,640}}
local function facet(n, p) local pts = {} for _, k in ipairs(n) do pts[#pts+1] = V[k] end; local m = poly(pts) * FACE; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
for _, f in ipairs{
  {{"A","M","H","I"}, S4}, {{"M","B","J","H"}, S3}, {{"C","I","G","P"}, S4}, {{"I","H","G"}, S5},
  {{"H","J","N","G"}, S2}, {{"J","B","D"}, S2}, {{"J","D","L","N"}, S3}, {{"P","G","N","K"}, S4},
  {{"N","L","F","K"}, S2}, {{"P","K","E","Q"}, S3}, {{"K","F","T","R","E"}, S2}, {{"F","L","D","U","T"}, S1}, {{"Q","E","R"}, S3},
} do facet(f[1], f[2]) end

--@ chunk 5
wait(3 * 24 * 60)
local Q = {512, 268}
local rim = {{300,470},{312,360},{356,272},{420,222},{500,196},{590,200},{664,240},{716,312},{744,420}}
local bangs = {{744,452},{704,508},{670,466},{628,526},{594,474},{548,532},{516,478},{474,524},{440,474},{398,516},{362,472},{326,504},{300,470}}
local crownP = {HC, H3, HC, HB, H2, H1, H1, H1}
for i = 1, #rim - 1 do
  local m = poly({Q, rim[i], rim[i+1]}) * HAIRM:grow(1)
  work(m, {hand="detail", pile=crownP[i], coverage=3.5, fill=true, clip=m})
end
local tri = poly({Q, {744,420}, {744,452}}); work(tri, {hand="detail", pile=H1, coverage=3.5, fill=true, clip=tri})
for i = 1, #bangs - 1 do
  local m = poly({Q, bangs[i], bangs[i+1]})
  local x = (bangs[i][1] + bangs[i+1][1]) / 2
  local p = (x < 420) and HB or (x < 560 and ((i % 2 == 0) and HB or H1) or H1)
  work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m})
end

--@ chunk 6
wait(3 * 24 * 60)
-- the long locks, faceted, lit on their window faces, reaching to the frame
local function F(pts, p) local m = poly(pts) * HAIRM; if m:area() > 2 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
F({{300,470},{334,500},{318,640},{288,650}}, H4)
F({{288,650},{318,640},{300,800},{262,800}}, HC)
F({{262,800},{300,800},{276,960},{232,960}}, HB)
F({{232,960},{276,960},{248,1120},{196,1120}}, H2)
F({{196,1120},{248,1120},{232,1250},{160,1250}}, HB)
F({{334,500},{376,520},{364,660},{318,640}}, HB)
F({{318,640},{364,660},{356,820},{300,800}}, H1)
F({{300,800},{356,820},{340,980},{276,960}}, H2)
F({{276,960},{340,980},{318,1150},{248,1120}}, H1)
F({{248,1120},{318,1150},{300,1250},{232,1250}}, H2)
-- near side, in shadow
F({{690,520},{740,500},{756,640},{700,660}}, H2)
F({{700,660},{756,640},{774,800},{716,820}}, H1)
F({{716,820},{774,800},{796,980},{738,1000}}, H2)
F({{738,1000},{796,980},{828,1150},{760,1170}}, H1)
F({{760,1170},{828,1150},{850,1250},{770,1250}}, H2)
F({{676,700},{700,660},{716,820},{690,860}}, HB)

--@ chunk 7
wait(3 * 24 * 60)
EYE1 = pile{{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
EYE2 = pile{{"ultramarine blue",0.7},{"burnt sienna",0.5},{"bone black",0.5},{"lead white",0.45}}
EYE3 = pile{{"ultramarine blue",0.8},{"bone black",0.6},{"burnt sienna",0.3},{"lead white",0.25}}
EYEF = {{402,550},{432,534},{470,540},{484,578},{472,614},{432,620},{405,598}}
EYEN = {{562,548},{602,534},{642,542},{654,584},{642,624},{598,630},{567,604}}
for _, e in ipairs{EYEF, EYEN} do local m = poly(e); work(m, {hand="detail", pile=EYE1, coverage=3.5, fill=true, clip=m}) end
local function F(pts, p, clip) local m = poly(pts); if clip then m = m * clip end; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F({{405,592},{484,578},{472,614},{432,620}}, EYE2, poly(EYEF))
F({{567,600},{654,584},{642,624},{598,630}}, EYE2, poly(EYEN))
F({{408,580},{484,570},{484,580},{406,594}}, EYE3, poly(EYEF))
F({{566,588},{654,576},{654,586},{568,600}}, EYE3, poly(EYEN))

--@ chunk 8
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
-- heavy, relaxed upper lids: a lowered band of shadow over the top of each eye, then the lid line
F({{398,552},{432,532},{472,538},{488,556},{486,566},{470,560},{432,556},{404,570},{394,566}}, H1)
F({{556,552},{602,532},{646,540},{664,556},{676,550},{660,566},{642,560},{602,556},{564,572}}, H1)
-- square highlights, a little smaller and lower than before (a softer gaze)
F({{418,572},{432,572},{432,586},{418,586}}, S5)
F({{456,600},{463,600},{463,607},{456,607}}, S5)
F({{580,576},{595,576},{595,591},{580,591}}, S5)
F({{624,606},{632,606},{632,614},{624,614}}, S5)
-- pupils
F({{440,582},{456,580},{458,598},{442,600}}, EYE1)
F({{604,586},{620,584},{622,602},{606,604}}, EYE1)
-- brows level and calm, not raised
F({{404,514},{440,508},{476,506},{476,513},{440,515},{406,521}}, H1)
F({{566,506},{604,506},{640,512},{640,519},{604,513},{566,513}}, H1)
-- a soft lower lid facet catching the window, the look of someone at ease
F({{408,618},{432,624},{472,618},{470,624},{432,630},{410,624}}, S4)
F({{570,628},{598,634},{640,628},{638,634},{598,640},{572,634}}, S3)

--@ chunk 9
wait(2 * 24 * 60)
MO = pile{{"rose madder",1},{"bone brown",1},{"bone black",0.35},{"lead white",0.2}}
LIPL = pile{{"lead white",2},{"rose madder",0.45},{"raw sienna",0.3}}
BL2 = pile{{"lead white",3},{"rose madder",0.3},{"vermilion",0.12},{"yellow ochre",0.15}}
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}); return m end
-- the stray lower-lid strip on the near eye, back to cheek
F({{568,626},{642,624},{644,638},{570,640}}, S3)
-- nose
F({{506,622},{520,662},{502,668}}, S4)
F({{506,622},{530,658},{520,662}}, S1)
F({{502,668},{520,662},{530,668},{512,674}}, NS)
-- mouth: closed, a short seam rising very slightly at the far corner, a soft lower lip plane beneath
F({{484,708},{496,706},{512,705},{520,702},{521,705},{512,709},{496,710},{485,711}}, MO)
F({{488,712},{512,711},{508,718},{492,718}}, LIPL)
-- faint blush facets
F({{412,640},{452,646},{438,660},{406,652}}, BL2)
F({{606,652},{652,642},{646,664},{614,664}}, BL2)

--@ chunk 10
wait(3 * 24 * 60)
-- the locks darkened toward the first portrait's values: dark planes, light only on the window-facing tops
local function F(pts, p) local m = poly(pts) * HAIRM; if m:area() > 2 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{288,650},{318,640},{300,800},{262,800}}, HB)
F({{262,800},{300,800},{276,960},{232,960}}, H1)
F({{232,960},{276,960},{248,1120},{196,1120}}, HB)
F({{196,1120},{248,1120},{232,1250},{160,1250}}, H1)
F({{334,500},{376,520},{364,660},{318,640}}, H1)
F({{300,800},{356,820},{340,980},{276,960}}, H1)
F({{248,1120},{318,1150},{300,1250},{232,1250}}, H1)
F({{690,520},{740,500},{756,640},{700,660}}, H1)
F({{716,820},{774,800},{796,980},{738,1000}}, H1)
F({{760,1170},{828,1150},{850,1250},{770,1250}}, H1)
F({{512,268},{356,272},{420,222}}, H3)
F({{512,268},{312,360},{356,272}}, HB)

--@ chunk 11
wait(2 * 24 * 60)
W4 = pile{{"lead white",3},{"raw sienna",0.25},{"ultramarine ash",0.15}}
W2 = pile{{"lead white",1.5},{"ultramarine ash",0.6},{"bone brown",0.4},{"raw sienna",0.3}}
local sh = (SHIRTM - HAIRM:shrink(1)) + (CHEST - NECK - LOCKL - LOCKR)
local function F(pts, p) local m = poly(pts) * sh; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{60,1250},{110,1080},{170,990},{230,1100},{180,1250}}, W5)
F({{170,990},{250,940},{300,1040},{230,1100}}, W4)
F({{230,1100},{300,1040},{400,1250},{180,1250}}, W4)
F({{330,880},{440,850},{420,980},{320,1000}}, W4)
F({{420,980},{440,850},{580,850},{560,980}}, W4)
F({{320,1000},{420,980},{560,980},{620,1250},{280,1250}}, WS3)
F({{580,850},{690,880},{700,1000},{560,980}}, W2)
F({{560,980},{700,1000},{740,1250},{620,1250}}, WS1)
F({{780,940},{860,1000},{830,1100},{760,1040}}, W3)
F({{760,1040},{830,1100},{860,1250},{720,1250}}, W2)
F({{860,1000},{920,1100},{950,1250},{860,1250},{830,1100}}, W3)
local nk = NECK - FACE
work(nk * rect(0,0,500,2000), {hand="detail", pile=S2, coverage=4, fill=true, clip=nk})
work(nk * rect(500,0,500,2000), {hand="detail", pile=NS, coverage=4, fill=true, clip=nk})

--@ chunk 12
wait(4 * 24 * 60)
OR = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.4}}
ORM = pile{{"Mars orange",1},{"cadmium yellow",0.2},{"burnt sienna",0.3},{"lead white",0.2}}
ORD = pile{{"Mars orange",1},{"burnt sienna",0.6},{"bone brown",0.2}}
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}); return m end
F({{412,850},{430,832},{470,846},{466,888},{444,888}}, OR)
F({{470,846},{540,842},{544,890},{500,900},{466,888}}, ORM)
F({{540,842},{582,828},{596,852},{560,886},{544,890}}, ORD)
F({{446,838},{470,846},{540,842},{564,834},{540,830},{470,834}}, NS)
-- the pendant: a cord over the collar, a bone hexagon holding a smaller turned hexagon
local cord = brush{kind="round", width=1.6, point=0.6}
cord:reload(pile{{"bone brown",1},{"bone black",0.4}}, 0.85); cord:stroke({{470,880},{490,920},{506,944}}, {pressure={0.5, 0.5}})
cord:reload(pile{{"bone brown",1},{"bone black",0.4}}, 0.85); cord:stroke({{548,880},{528,920},{512,944}}, {pressure={0.5, 0.5}})
local function hex(cx, cy, r, rot) local t = {} for i = 0, 5 do local a = rot + i * math.pi / 3; t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return t end
PEND = poly(hex(509, 964, 20, 0.1))
work(PEND * rect(0,0,509,2000), {hand="detail", pile=pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}, coverage=4, fill=true, clip=PEND})
work(PEND * rect(509,0,500,2000), {hand="detail", pile=pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}, coverage=4, fill=true, clip=PEND})

--@ chunk 13
wait(3 * 24 * 60)
local g = brush{kind="round", width=1.1, point=0.8}
local function hex(cx, cy, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return t end
g:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.85); g:stroke(hex(510, 965, 11, 0.4), {pressure={0.4, 0.4}, ramps={0.05, 0.05}})
g:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.85); g:stroke(hex(511, 966, 6, 0.9), {pressure={0.35, 0.35}, ramps={0.05, 0.05}})
local t = brush{kind="round", width=1.8, point=0.2}; t:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.85); t:touch(511.5, 966.5, {pressure=0.3})
local h = brush{kind="round", width=1.4, point=0.7}
h:reload(pile{{"lead white",3},{"zinc white",0.6}}, 0.8); h:stroke({{491,960},{499,947},{512,944}}, {pressure={0.2, 0.6, 0.1}})
-- the crimson thread: wound three times round the window-side lock, a knot, two loose ends
CR = pile{{"vermilion",1},{"red earth",0.6},{"rose madder",0.3}}
CRD = pile{{"red earth",1},{"rose madder",0.5},{"bone black",0.3}}
local b = brush{kind="round", width=3.0, point=0.4}
for k = 0, 2 do local y = 700 + k * 9; b:reload(k == 1 and CR or CRD, 0.9); b:stroke({{282, y + 2}, {310, y - 2}, {346, y + 1}}, {pressure={0.6, 0.7, 0.5}, ramps={0.05, 0.05}}) end
b:reload(CR, 0.9); b:touch(318, 708, {pressure=0.7})
local e = brush{kind="round", width=2.2, point=0.6}
e:reload(CR, 0.85); e:stroke({{318,712},{314,736},{320,760}}, {pressure={0.6, 0.4, 0.05}, ramps={0.05, 0.6}})
e:reload(CRD, 0.85); e:stroke({{320,712},{328,734},{326,752}}, {pressure={0.5, 0.3, 0.05}, ramps={0.05, 0.6}})
local hi = brush{kind="round", width=1.2, point=0.7}
hi:reload(pile{{"vermilion",1},{"lead white",0.6},{"cadmium yellow",0.2}}, 0.8); hi:stroke({{286,697},{306,693}}, {pressure={0.5, 0.2}})

--@ chunk 14
wait(2 * 24 * 60)
local function F(m, p) work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end
-- the wrap: three crimson bands round the lock, lit on top
for k = 0, 2 do local y = 694 + k * 11
  local m = poly({{278, y}, {346, y - 3}, {346, y + 6}, {278, y + 9}}); F(m, k == 0 and CR or CRD)
  local l = poly({{280, y}, {340, y - 2.5}, {340, y + 1}, {280, y + 3}}); F(l, pile{{"vermilion",1},{"cadmium red",0.3},{"lead white",0.35}})
end
F(ellipse(316, 708, 7, 6), CR)
F(poly({{312,712},{320,712},{318,770},{310,768}}), CR)
F(poly({{320,712},{328,712},{334,752},{328,754}}), CRD)
-- the pendant's glyph restated as two hexagons, the inner turned
local function hex(cx, cy, r, rot) local t = {} for i = 0, 5 do local a = rot + i * math.pi / 3; t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return poly(t) end
local GD = pile{{"bone brown",1},{"bone black",0.5}}
F(hex(510, 965, 12, 0.1) - hex(510, 965, 9.6, 0.1), GD)
F(hex(511, 966, 7, 0.62) - hex(511, 966, 5, 0.62), GD)

--@ chunk 15
wait(1 * 24 * 60)
-- the window, the same place, the light a little later and warmer
local WIN = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.35},{"Mars orange",0.1}}
local WIN2 = pile{{"lead white",2},{"yellow ochre",1.1},{"raw sienna",0.6},{"Mars orange",0.1}}
local m1 = poly({{0,60},{120,40},{150,330},{0,360}}) - FIGM:grow(2)
work(m1, {hand="detail", pile=WIN, coverage=4, fill=true, clip=m1})
local m2 = poly({{0,360},{150,330},{110,420},{0,440}}) - FIGM:grow(2)
work(m2, {hand="detail", pile=WIN2, coverage=4, fill=true, clip=m2})
local bar = poly({{0,200},{136,188},{137,200},{0,212}}) + poly({{58,48},{70,47},{86,340},{74,342}})
work(bar, {hand="detail", pile=BG2, coverage=4, fill=true, clip=bar})
-- the brightest facets on the lit cheek and brow, and a warm rim of window light down the hair's far contour
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end
F({{388,568},{404,604},{400,620},{384,592}}, S5)
F({{474,520},{498,526},{486,544}}, S5)
local RIM = pile{{"lead white",2},{"yellow ochre",0.9},{"raw sienna",0.3},{"ultramarine ash",0.15}}
local r = brush{kind="round", width=2.6, point=0.6}
r:reload(RIM, 0.75); r:stroke({{356,274},{312,360},{300,470},{278,600},{248,780},{210,980},{180,1140}}, {pressure={0.1, 0.6, 0.55, 0.45, 0.3, 0.15, 0.0}, ramps={0.2, 0.3}, clip=HAIRM:grow(1)})

--@ chunk 16
wait(2 * 24 * 60)
-- the hair's light planes, few and narrow, as before
local function F(pts, p) local m = poly(pts) * HAIRM; if m:area() > 2 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{512,268},{380,240},{400,232},{470,206}}, H4)
F({{304,500},{334,500},{330,560},{300,570}}, H4)
F({{300,570},{330,560},{318,660},{294,650}}, H3)
F({{258,840},{282,840},{268,940},{246,940}}, H3)
F({{684,720},{696,720},{708,860},{696,860}}, H2)

--@ chunk 17
wait(2 * 24 * 60)
local sh = (SHIRTM - HAIRM:shrink(1)) - poly({{400,820},{620,820},{620,905},{400,905}}) - PEND:grow(2)
local function F(pts, p) local m = poly(pts) * sh; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{60,1250},{110,1080},{170,990},{230,1100},{180,1250}}, W3)
F({{170,990},{250,940},{300,1040},{230,1100}}, WS3)
F({{230,1100},{300,1040},{400,1250},{180,1250}}, WS3)
F({{780,940},{860,1000},{830,1100},{760,1040}}, WS1)
F({{760,1040},{830,1100},{860,1250},{720,1250}}, WS1)
F({{860,1000},{920,1100},{950,1250},{860,1250},{830,1100}}, W2)
local ch = (CHEST - NECK - LOCKL - LOCKR) - poly({{400,820},{620,820},{620,905},{400,905}}) - PEND:grow(2)
work(ch * rect(0,0,505,2000) * rect(0, 980, 2000, 400), {hand="detail", pile=WS3, coverage=4, fill=true, clip=ch})

--@ chunk 18
wait(2 * 24 * 60)
-- the crown's dome cut to straight facets: the ground painted over the curve outside a polygon
local hp = poly({{300,470},{312,360},{356,272},{420,222},{500,196},{590,200},{664,240},{716,312},{744,420},{756,560},{774,760},{800,980},{832,1150},{850,1250},{150,1250},{176,1150},{210,980},{248,780},{278,600}})
local ring = (HAIRM:grow(10) - hp) * rect(0, 0, 1000, 900)
work(ring * rect(0,0,470,2000), {hand="detail", pile=BGM, coverage=4, fill=true, clip=ring})
work(ring * rect(470,0,600,2000), {hand="detail", pile=BG1, coverage=4, fill=true, clip=ring})

--@ chunk 19
wait(3 * 24 * 60)
SCAN = pile{{"bone black",1},{"ultramarine blue",0.4},{"bone brown",0.5}, medium=0.6}
SCB = brush{kind="rigger", width=1.4, point=0.6}
for y = 4, 1250, 9 do
  SCB:reload(SCAN, 0.25)
  SCB:stroke({{-5, y}, {1005, y + 0.5}}, {pressure={0.18, 0.18}, ramps={0.02, 0.02}})
end

--@ chunk 20
wait(2 * 24 * 60)
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
local g = brush{kind="filbert", width=10}
local GL = pile{{"lead white",2},{"zinc white",1}, medium=0.5}
local pts = {}
for i = 0, 12 do local a = math.pi * 1.02 + (math.pi * 0.46) * i / 12; pts[#pts+1] = {150 + 108 * math.cos(a), 150 + 108 * math.sin(a)} end
g:reload(GL, 0.35); g:stroke(pts, {pressure={0.0, 0.35, 0.0}, ramps={0.4, 0.4}, clip=SCREEN})
local h = brush{kind="round", width=2.0, point=0.7}
local p2 = {}
for i = 0, 10 do local a = math.pi * 1.06 + (math.pi * 0.4) * i / 10; p2[#p2+1] = {150 + 118 * math.cos(a), 150 + 118 * math.sin(a)} end
h:reload(GL, 0.5); h:stroke(p2, {pressure={0.0, 0.5, 0.0}, ramps={0.4, 0.4}, clip=SCREEN})
