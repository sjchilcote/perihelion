-- easel session "helm": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={22,20}, seed=71,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.4},{"lead white",0.2}}, um=35, apply="roller"}}}

--@ chunk 2
HELM = poly({{318,520},{326,400},{370,290},{450,222},{548,200},{640,222},{708,290},{738,390},{740,520},{720,640},{690,760},{640,840},{560,880},{460,876},{390,840},{350,760},{326,640}}, true)
CLOTH = poly({{200,1250},{230,1020},{330,900},{430,860},{620,860},{740,900},{830,1010},{880,1250}}, true)
PAUL = poly({{0,1250},{20,1060},{110,980},{230,990},{290,1080},{300,1250}}, true)
FIG = HELM + CLOTH + PAUL
BG1 = pile{{"bone brown",2},{"bone black",1.2},{"burnt sienna",0.3}}
BG2 = pile{{"bone brown",2},{"bone black",0.5},{"burnt sienna",0.6},{"raw sienna",0.3}}
local bg = everywhere() - FIG:grow(3)
work(bg, {hand="broad", pile=BG1, coverage=2.8, fill=true, clip=bg, angle=math.pi/2 + 0.15})

--@ chunk 3
S1 = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.2}}
S2 = pile{{"bone brown",1.5},{"bone black",0.6},{"raw sienna",0.5},{"lead white",0.2}}
S3 = pile{{"raw sienna",1},{"bone brown",1},{"lead white",0.5},{"ultramarine ash",0.3}}
S4 = pile{{"lead white",1.5},{"raw sienna",0.8},{"bone brown",0.4},{"ultramarine ash",0.3}}
G1 = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone brown",0.5}}
G2 = pile{{"Mars yellow",1},{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.3}}
G3 = pile{{"yellow ochre",1.5},{"chrome yellow",0.6},{"lead white",0.6}}
G4 = pile{{"lead white",2.5},{"chrome yellow",0.8},{"yellow ochre",0.4}}
C1 = pile{{"red earth",1},{"rose madder",0.6},{"bone black",0.4}}
C2 = pile{{"vermilion",1},{"red earth",0.8},{"rose madder",0.4}}
C3 = pile{{"vermilion",1.2},{"cadmium red",0.4},{"lead white",0.3}}
work(PAUL - CLOTH, {hand="body", pile=S2, coverage=3, fill=true, clip=PAUL, angle=-0.4})
work(CLOTH - HELM, {hand="body", pile=C1, coverage=3, fill=true, clip=CLOTH, angle=math.pi/2})
work(HELM, {hand="body", pile=S2, coverage=3, fill=true, clip=HELM, angle=math.pi/2})

--@ chunk 4
wait(4 * 24 * 60)
local bg = everywhere() - FIG:grow(3)
local glow = bg * ellipse(330, 330, 330, 360)
work(glow, {hand="body", pile=BG2, coverage=2.6, fill=true, clip=bg, angle=math.pi/2 + 0.2})
blend(bg * (ellipse(330, 330, 360, 390) - ellipse(330, 330, 290, 320)), {angle=-0.7})

--@ chunk 5
wait(3 * 24 * 60)
BGM = pile{{"bone brown",2},{"bone black",0.85},{"burnt sienna",0.45},{"raw sienna",0.15}}
local bg = everywhere() - FIG:grow(3)
local function ring(r0, r1) return bg * (ellipse(330, 330, r1, r1 * 1.1) - ellipse(330, 330, r0, r0 * 1.1)) end
work(ring(0, 260), {hand="body", pile=BG2, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ring(260, 400), {hand="body", pile=BGM, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
work(ring(400, 520), {hand="body", pile=BG1, coverage=3, fill=true, clip=bg, angle=math.pi/2 + 0.2})
blend(ring(235, 285), {angle=-0.7})
blend(ring(375, 425), {angle=-0.7})

--@ chunk 6
wait(2 * 24 * 60)
HF = {
  {{{326,400},{370,290},{450,222},{480,300},{420,380},{340,430}}, S4},          -- dome, front-left, in the light
  {{{450,222},{548,200},{560,280},{480,300}}, S4},
  {{{548,200},{640,222},{708,290},{640,330},{560,280}}, S3},
  {{{708,290},{738,390},{740,450},{680,430},{640,330}}, S2},
  {{{480,300},{560,280},{640,330},{680,430},{580,410},{470,400}}, S3},
  {{{340,430},{420,380},{470,400},{580,410},{680,430},{740,450},{740,500},{600,486},{460,476},{330,500}}, S3}, -- brow band
  {{{330,500},{460,476},{456,600},{440,720},{390,840},{350,760},{326,640}}, S2},  -- face-plate, the left (toward us)
  {{{460,476},{600,486},{740,500},{720,640},{690,760},{640,840},{560,880},{460,876},{390,840},{440,720},{456,600}}, S1},
}
for _, f in ipairs(HF) do local m = poly(f[1]) * HELM:grow(2); work(m, {hand="detail", pile=f[2], coverage=3, fill=true, clip=m}) end

--@ chunk 7
wait(3 * 24 * 60)
S15 = pile{{"bone brown",1.4},{"bone black",0.8},{"raw sienna",0.3},{"lead white",0.12}}
WR = pile{{"bone brown",1.2},{"red earth",0.6},{"bone black",0.5},{"rose madder",0.2}}
local function F(pts, p) local m = poly(pts) * HELM; work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
-- the front ridge of the face-plate, catching a little of the light
F({{452,478},{474,480},{470,620},{456,740},{420,846},{404,836},{440,720},{452,600}}, S15)
-- the chin of the plate, warmed by the crimson below
F({{404,836},{456,760},{540,770},{640,780},{640,840},{560,880},{460,876}}, WR)

--@ chunk 8
wait(2 * 24 * 60)
SLIT = pile{{"bone black",1.5},{"ultramarine blue",0.3}}
-- the visor slit: a dark band following the curve of the plate, wider at the front
SLITM = poly({{334,540},{400,528},{470,524},{560,530},{660,540},{732,552},{730,566},{660,560},{560,552},{470,548},{400,552},{334,566}}) * HELM
work(SLITM, {hand="detail", pile=SLIT, coverage=3.5, fill=true, clip=SLITM})
-- breathing holes on the cheek, counted in golden gaps
local t = brush{kind="round", width=3.0, point=0.2}
local x, gap = 372, 18
for k = 1, 6 do for r = 0, 2 do t:reload(SLIT, 0.8); t:touch(x + r * 3, 640 + r * 22 + k * 4, {pressure=0.5}) end; x = x + gap; gap = gap * 0.86 end

--@ chunk 9
wait(2 * 24 * 60)
BAND = poly({{334,470},{460,446},{600,454},{740,470},{740,500},{600,486},{460,476},{330,500}}) * HELM
work(BAND * rect(0,0,520,2000), {hand="detail", pile=G2, coverage=3.5, fill=true, clip=BAND})
work(BAND * rect(520,0,500,2000), {hand="detail", pile=G1, coverage=3.5, fill=true, clip=BAND})
-- the cross on the brow: the upright climbs the front of the dome, the arms run along the band's top
CROSS = poly({{448,250},{472,246},{476,446},{450,450}}) + poly({{392,382},{540,372},{542,394},{394,404}})
CROSS = CROSS * HELM
work(CROSS * rect(0,0,462,2000), {hand="detail", pile=G3, coverage=3.5, fill=true, clip=CROSS})
work(CROSS * rect(462,0,500,2000), {hand="detail", pile=G2, coverage=3.5, fill=true, clip=CROSS})
-- gold rims above and below the slit
RIMS = (poly({{334,528},{400,516},{470,512},{560,518},{660,528},{732,540},{732,552},{660,540},{560,530},{470,524},{400,528},{334,540}}) + poly({{334,566},{400,552},{470,548},{560,552},{660,560},{730,566},{728,578},{660,572},{560,564},{470,560},{400,564},{334,578}})) * HELM
work(RIMS * rect(0,0,520,2000), {hand="detail", pile=G2, coverage=3.5, fill=true, clip=RIMS})
work(RIMS * rect(520,0,500,2000), {hand="detail", pile=G1, coverage=3.5, fill=true, clip=RIMS})

--@ chunk 10
wait(3 * 24 * 60)
local arms = (poly({{388,378},{544,368},{546,398},{390,408}}) * HELM) - poly({{448,250},{472,246},{476,446},{450,450}})
for _, k in ipairs{1, 5, 6, 2} do local m = arms * poly(HF[k][1]); if m:area() > 1 then work(m, {hand="detail", pile=HF[k][2], coverage=3.5, fill=true, clip=m}) end end

--@ chunk 11
wait(3 * 24 * 60)
CROSS = (poly({{448,250},{472,246},{476,446},{450,450}}) + poly({{404,296},{526,288},{528,310},{406,318}})) * HELM
local arms = poly({{404,296},{526,288},{528,310},{406,318}}) - poly({{448,250},{472,246},{476,446},{450,450}})
work(arms * rect(0,0,462,2000), {hand="detail", pile=G3, coverage=3.5, fill=true, clip=arms})
work(arms * rect(462,0,500,2000), {hand="detail", pile=G2, coverage=3.5, fill=true, clip=arms})

--@ chunk 12
wait(3 * 24 * 60)
local t = brush{kind="round", width=3.6, point=0.3}
local function dab(x, y, p, pr) t:reload(p, 1.0); t:touch(x, y, {pressure=pr or 0.7}) end
local function run(pts, p, w, pr) local b = brush{kind="round", width=w, point=0.4}; b:reload(p, 1.0); b:stroke(pts, {pressure=pr or {0.8, 0.8}, ramps={0.1, 0.2}}) end
-- the cross: a blazing edge on the lit side of the upright and the top of the arms
run({{452,256},{453,320},{454,390},{456,440}}, G4, 3.4, {0.9, 0.7, 0.2})
run({{410,298},{450,294}}, G4, 3.0, {0.8, 0.3})
run({{470,292},{500,290}}, G3, 2.4, {0.6, 0.1})
-- the brow band: a bright upper edge on the left, broken into thick touches
for i, x in ipairs{344, 362, 380, 398, 416, 432, 448, 462, 480, 500, 522} do
  local y = 470 - (x - 334) * 0.12
  dab(x, y, i < 8 and G4 or G3, 0.75 - i * 0.03)
end
-- the rims: thick touches where they turn toward the window
for i, x in ipairs{346, 366, 388, 410, 430, 452} do dab(x, 528 - (x - 334) * 0.09, G3, 0.6); dab(x + 8, 566 - (x - 334) * 0.1, G3, 0.5) end

--@ chunk 13
wait(2 * 24 * 60)
-- filigree along the band and rims: small scrolls, each a tight curl, darker gold on the shadow side
local b = brush{kind="round", width=1.3, point=0.7}
local function scroll(x, y, s, p)
  local pts = {}
  for i = 0, 12 do local a = i / 12 * math.pi * 1.6; local r = s * (1 - i / 16); pts[#pts+1] = {x + r * math.cos(a), y - r * 0.7 * math.sin(a)} end
  b:reload(p, 0.85); b:stroke(pts, {pressure={0.5, 0.5, 0.2}, ramps={0.1, 0.2}})
end
local x = 340
while x < 730 do
  local p = x < 470 and G4 or (x < 600 and G3 or G2)
  scroll(x, 486 - (x - 334) * 0.03, 6, p)
  scroll(x + 10, 547 + (x - 334) * 0.03, 4, x < 520 and G3 or G2)
  x = x + 22 + 4 * math.sin(x)
end

--@ chunk 14
wait(2 * 24 * 60)
T4 = pile{{"lead white",1},{"bone black",0.45},{"raw sienna",0.35},{"ultramarine ash",0.4}}
T3 = pile{{"lead white",0.7},{"bone black",0.6},{"raw sienna",0.35},{"ultramarine ash",0.35},{"bone brown",0.3}}
T2 = pile{{"bone black",0.8},{"bone brown",0.8},{"lead white",0.35},{"ultramarine ash",0.25}}
local keep = CROSS:grow(1.5) + BAND:grow(1)
local piles = {T4, T4, T3, T2, T3}
for k = 1, 5 do local m = (poly(HF[k][1]) * HELM:grow(2)) - keep; work(m, {hand="detail", pile=piles[k], coverage=3.5, fill=true, clip=m}) end

--@ chunk 15
local strip = (poly(HF[6][1]) * HELM:grow(2) * rect(0, 0, 1000, 470)) - CROSS:grow(1.5) - BAND:grow(1)
work(strip * rect(0,0,560,2000), {hand="detail", pile=T3, coverage=3.5, fill=true, clip=strip})
work(strip * rect(560,0,500,2000), {hand="detail", pile=T2, coverage=3.5, fill=true, clip=strip})

--@ chunk 16
wait(3 * 24 * 60)
-- the band blazes where it turns toward the window: a broad lit plane laid thick, then a hot edge
local lit = BAND * poly({{320,440},{470,430},{470,520},{320,520}})
work(lit, {hand="detail", pile=G3, coverage=4, fill=true, clip=lit, load=1.0})
local hot = brush{kind="round", width=3.0, point=0.4}
hot:reload(G4, 1.0); hot:stroke({{340,474},{380,466},{420,460},{458,454}}, {pressure={0.6, 0.9, 0.8, 0.3}, ramps={0.1, 0.3}})

--@ chunk 17
wait(2 * 24 * 60)
-- the stray gold sliver beside the upright
local sl = poly({{420,382},{448,378},{448,400},{420,400}}) - CROSS
work(sl, {hand="detail", pile=T3, coverage=3.5, fill=true, clip=sl})
-- the optic: a small cold lens deep in the slit, its glow just spilling onto the rims
OPT = pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.2}}
OPTD = pile{{"cerulean blue",1},{"ultramarine blue",0.6},{"zinc white",0.5}}
local o = ellipse(420, 541, 9, 6)
work(o, {hand="detail", pile=OPTD, coverage=3.5, fill=true, clip=o})
local c = ellipse(419, 540, 4, 3)
work(c, {hand="detail", pile=OPT, coverage=3.5, fill=true, clip=c})
local g = brush{kind="round", width=1.4, point=0.7}
g:reload(OPTD, 0.5); g:stroke({{404,531},{420,529},{436,531}}, {pressure={0.05, 0.35, 0.05}})
g:reload(OPTD, 0.5); g:stroke({{404,553},{420,555},{436,553}}, {pressure={0.05, 0.3, 0.05}})

--@ chunk 18
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
wait(1 * 24 * 60)
-- dents: each a small dark crescent with a lit lip on its far side; scratches: fine light lines on the lit steel
local d = brush{kind="round", width=2.4, point=0.5}
local l = brush{kind="round", width=1.2, point=0.8}
local dome = HELM - CROSS:grow(2) - BAND:grow(2) - SLITM:grow(2) - RIMS:grow(1)
for _, p in ipairs{{392,330,12},{540,250,9},{610,360,14},{372,640,10},{520,700,13},{660,600,11}} do
  local x, y, r = p[1], p[2], p[3]
  local arc = {} for i = 0, 6 do local a = math.pi * 0.9 + math.pi * 0.9 * i / 6; arc[#arc+1] = {x + r * math.cos(a), y + r * 0.6 * math.sin(a)} end
  d:reload(T2, 0.8); d:stroke(arc, {pressure={0.1, 0.6, 0.1}, ramps={0.3, 0.3}, clip=dome})
  local lip = {} for i = 0, 6 do local a = math.pi * 0.05 + math.pi * 0.7 * i / 6; lip[#lip+1] = {x + r * math.cos(a), y + r * 0.6 * math.sin(a)} end
  l:reload(y < 470 and B4 or T3, 0.6); l:stroke(lip, {pressure={0.05, 0.45, 0.05}, ramps={0.3, 0.3}, clip=dome})
end
for _, s in ipairs{{350,360,410,330},{380,300,430,286},{520,236,600,226},{560,330,612,316},{360,420,400,404},{356,690,396,676}} do
  l:reload(B4, 0.5); l:stroke({{s[1], s[2]}, {s[3], s[4]}}, {pressure={0.05, 0.35, 0.0}, ramps={0.2, 0.5}, clip=dome})
end

--@ chunk 19
wait(1 * 24 * 60)
local function F(pts, p, clip) local m = poly(pts) * (clip or HELM:grow(1)); work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end
F({{404,836},{456,760},{540,770},{640,780},{640,840},{560,880},{460,876}}, S1)
F({{430,850},{480,812},{560,814},{630,828},{560,880},{460,876}}, WR)
F({{476,600},{600,610},{700,640},{690,700},{560,680},{470,660}}, pile{{"bone black",1},{"bone brown",1},{"raw sienna",0.2},{"lead white",0.08}})

--@ chunk 20
-- the crimson gorget-cloth in heavy folds falling from the throat, lit from the upper left
local cl = CLOTH - HELM:grow(1)
local function F(pts, p) local m = poly(pts) * cl; if m:area() > 4 then work(m, {hand="body", pile=p, coverage=3.5, fill=true, clip=m, angle=math.pi/2, tool="filbert 6"}) end end
F({{200,1250},{230,1020},{330,900},{400,880},{360,1000},{300,1250}}, C2)
F({{330,900},{430,860},{470,880},{400,1010},{360,1000}}, C3)
F({{300,1250},{360,1000},{400,1010},{440,1250}}, C1)
F({{400,1010},{470,880},{560,880},{520,1000},{500,1250},{440,1250}}, C2)
F({{560,880},{620,860},{680,900},{600,1020},{520,1000}}, C2)
F({{520,1000},{600,1020},{640,1250},{500,1250}}, C1)
F({{600,1020},{680,900},{740,900},{830,1010},{880,1250},{640,1250}}, C1)

--@ chunk 21
wait(4 * 24 * 60)
D1 = pile{{"red earth",0.8},{"rose madder",0.5},{"bone black",0.7},{"bone brown",0.4}}
D2 = pile{{"red earth",1},{"rose madder",0.5},{"bone black",0.35},{"bone brown",0.3}}
D3 = pile{{"red earth",1},{"vermilion",0.4},{"rose madder",0.3},{"bone brown",0.15}}
local cl = CLOTH - HELM:grow(1)
local function F(pts, p) local m = poly(pts) * cl; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=3.5, fill=true, clip=m}) end end
F({{200,1250},{230,1020},{330,900},{400,880},{360,1000},{300,1250}}, D2)
F({{330,900},{430,860},{470,880},{400,1010},{360,1000}}, D3)
F({{300,1250},{360,1000},{400,1010},{440,1250}}, D1)
F({{400,1010},{470,880},{560,880},{520,1000},{500,1250},{440,1250}}, D2)
F({{560,880},{620,860},{680,900},{600,1020},{520,1000}}, D1)
F({{520,1000},{600,1020},{640,1250},{500,1250}}, D1)
F({{600,1020},{680,900},{740,900},{830,1010},{880,1250},{640,1250}}, D1)
local ch = poly({{430,850},{480,812},{560,814},{630,828},{560,880},{460,876}}) * HELM
work(ch, {hand="detail", pile=WR, coverage=3.5, fill=true, clip=ch})

--@ chunk 22
local p = PAUL - CLOTH:grow(1)
local function F(pts, pl) local m = poly(pts) * p; if m:area() > 4 then work(m, {hand="detail", pile=pl, coverage=3.5, fill=true, clip=m}) end end
-- three overlapping lames, each lit along its top and falling into shade below
F({{0,1080},{60,1020},{150,990},{230,1000},{250,1040},{150,1036},{60,1066},{0,1110}}, T4)
F({{0,1110},{60,1066},{150,1036},{250,1040},{270,1090},{150,1090},{50,1130},{0,1160}}, T3)
F({{0,1160},{50,1130},{150,1090},{270,1090},{290,1150},{150,1150},{40,1200},{0,1220}}, T2)
F({{0,1220},{40,1200},{150,1150},{290,1150},{300,1250},{0,1250}}, S1)

--@ chunk 23
wait(3 * 24 * 60)
local b = brush{kind="round", width=3.0, point=0.4}
local function run(pts, p, pr) b:reload(p, 1.0); b:stroke(pts, {pressure=pr, ramps={0.1, 0.3}, clip=PAUL:grow(2) - CLOTH}) end
-- gilded edges on the lames, blazing near the top where the light strikes
run({{4,1080},{60,1020},{150,990},{230,1000}}, G4, {0.6, 0.9, 0.7, 0.2})
run({{4,1110},{60,1066},{150,1036},{250,1040}}, G3, {0.5, 0.7, 0.5, 0.1})
run({{4,1160},{50,1130},{150,1090},{270,1090}}, G2, {0.4, 0.6, 0.4, 0.1})
run({{4,1220},{40,1200},{150,1150},{290,1150}}, G1, {0.3, 0.5, 0.3, 0.1})
-- rivets on the top lame
local t = brush{kind="round", width=3.2, point=0.2}
for _, q in ipairs{{70,1032},{130,1012},{190,1006}} do t:reload(G3, 1.0); t:touch(q[1], q[2], {pressure=0.5}) end

--@ chunk 24
wait(1 * 24 * 60)
SH = pile{{"lead white",2},{"zinc white",0.5},{"raw sienna",0.3},{"ultramarine ash",0.3}}
local clip = HELM:grow(2) - CROSS:grow(1)
local b = brush{kind="round", width=4.2, point=0.4}
local h = brush{kind="round", width=1.6, point=0.7}
local crest = {{430,234},{490,212},{548,204},{600,210},{650,228},{700,282}}
b:reload(T2, 0.9); b:stroke(crest, {pressure={0.6, 0.7, 0.7, 0.6, 0.5, 0.3}, ramps={0.1, 0.2}, clip=clip})
local top = {} for i, p in ipairs(crest) do top[i] = {p[1], p[2] - 3} end
h:reload(SH, 0.8); h:stroke({top[1], top[2], top[3], top[4]}, {pressure={0.3, 0.7, 0.5, 0.1}, ramps={0.2, 0.3}, clip=clip})
-- the window's rim of light down the helm's left contour
h:reload(T4, 0.8); h:stroke({{372,292},{342,360},{328,440},{326,520},{332,620},{346,720}}, {pressure={0.1, 0.6, 0.5, 0.4, 0.2, 0.0}, ramps={0.2, 0.4}, clip=clip})
-- a broad soft sheen across the lit dome plate
local f = brush{kind="filbert", width=12}
f:reload(SH, 0.5); f:stroke({{360,380},{392,320},{430,280}}, {pressure={0.05, 0.45, 0.05}, ramps={0.4, 0.4}, clip=clip})

--@ chunk 25
wait(2 * 24 * 60)
-- impasto: heavy, irregular touches of the hottest gold where the light hits the band and the cross
local zone = (BAND * rect(320, 430, 150, 60)) + (CROSS * rect(440, 240, 22, 210)) + (CROSS * rect(400, 286, 60, 30))
stipple(zone, {pile=G4, width=3.2, coverage=0.55, cluster={0.7, 8}, pressure={0.5, 0.9}, dips={6, 1.0, 0}})
local warm = BAND * rect(470, 430, 120, 70)
stipple(warm, {pile=G3, width=2.6, coverage=0.3, cluster={0.7, 8}, pressure={0.4, 0.7}, dips={6, 1.0, 0}})

--@ chunk 26
wait(2 * 24 * 60)
-- the gold throws a warm glow onto the steel just above the band
local glow = (poly(HF[6][1]) * HELM * rect(320, 410, 260, 40)) - CROSS:grow(1) - BAND
local f = brush{kind="filbert", width=8}
f:reload(pile{{"raw sienna",1},{"lead white",0.8},{"yellow ochre",0.4},{"bone black",0.2}}, 0.5)
f:stroke({{340,440},{400,430},{440,428}}, {pressure={0.05, 0.4, 0.05}, ramps={0.3, 0.4}, clip=glow})
-- the shadowed face-plate: a faint ghost of filigree below the slit, only just readable
local b = brush{kind="round", width=1.1, point=0.8}
for x = 470, 700, 26 do
  local y = 590 + (x - 470) * 0.05
  local pts = {} for i = 0, 10 do local a = i / 10 * math.pi * 1.6; local r = 5 * (1 - i / 14); pts[#pts+1] = {x + r * math.cos(a), y - r * 0.7 * math.sin(a)} end
  b:reload(G1, 0.6); b:stroke(pts, {pressure={0.35, 0.35, 0.1}, ramps={0.1, 0.2}})
end

--@ chunk 27
wait(2 * 24 * 60)
local o = ellipse(420, 541, 10, 7)
work(o, {hand="detail", pile=SLIT, coverage=3.5, fill=true, clip=o})

--@ chunk 28
wait(2 * 24 * 60)
OPC = pile{{"ultramarine ash",1},{"cerulean blue",0.5},{"bone black",0.4},{"zinc white",0.3}}
local o = ellipse(421, 541, 6, 4)
work(o, {hand="detail", pile=OPC, coverage=3.5, fill=true, clip=o})
local t = brush{kind="round", width=2.2, point=0.2}
t:reload(pile{{"zinc white",3},{"cerulean blue",0.6}}, 0.9); t:touch(419, 540, {pressure=0.35})

--@ chunk 29
wait(1 * 24 * 60)
local c = ellipse(421, 541, 3, 2.4)
work(c, {hand="detail", pile=pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.15}}, coverage=3.5, fill=true, clip=c})
local t = brush{kind="round", width=1.6, point=0.2}
t:reload(pile{{"zinc white",3},{"lemon chrome",0.1}}, 1.0); t:touch(420.5, 540.5, {pressure=0.3})

--@ chunk 30
wait(1 * 24 * 60)
local o = ellipse(421, 541, 7, 5)
work(o, {hand="detail", pile=pile{{"cerulean blue",1},{"zinc white",1},{"ultramarine ash",0.5}}, coverage=3.5, fill=true, clip=o})
local c = ellipse(420, 540.5, 3.6, 2.6)
work(c, {hand="detail", pile=pile{{"zinc white",3},{"cerulean blue",0.6}}, coverage=3.5, fill=true, clip=c})
local g = brush{kind="filbert", width=6}
g:reload(pile{{"zinc white",1},{"cerulean blue",1},{"ultramarine ash",1}, medium=0.6}, 0.35)
g:stroke({{392,532},{421,529},{450,532}}, {pressure={0.05, 0.3, 0.05}, ramps={0.4, 0.4}})
g:reload(pile{{"zinc white",1},{"cerulean blue",1},{"ultramarine ash",1}, medium=0.6}, 0.35)
g:stroke({{394,553},{421,556},{448,553}}, {pressure={0.05, 0.25, 0.05}, ramps={0.4, 0.4}})

--@ chunk 31
wait(1 * 24 * 60)
-- the Rembrandt dark: the far side of the cloth and the bottom of the canvas sink into shadow
D0 = pile{{"red earth",0.5},{"rose madder",0.3},{"bone black",1},{"bone brown",0.6}}
local m = (CLOTH - HELM:grow(1)) * poly({{560,1000},{1000,900},{1000,1250},{500,1250}})
work(m, {hand="detail", pile=D0, coverage=3.5, fill=true, clip=m})
local m2 = (CLOTH - HELM:grow(1)) * poly({{300,1180},{560,1150},{560,1250},{300,1250}})
work(m2, {hand="detail", pile=D1, coverage=3.5, fill=true, clip=m2})

--@ chunk 32
wait(1 * 24 * 60)
T1 = pile{{"bone black",1},{"bone brown",0.8},{"lead white",0.18},{"ultramarine ash",0.2}}
local m = (poly(HF[4][1]) * HELM:grow(2)) - BAND:grow(1)
work(m, {hand="detail", pile=T1, coverage=3.5, fill=true, clip=m})

--@ chunk 33
wait(2 * 24 * 60)
local t = brush{kind="round", width=3.0, point=0.2}
local function rivet(x, y, lit) t:reload(T1, 0.9); t:touch(x + 0.8, y + 1.2, {pressure=0.5}); t:reload(lit, 0.9); t:touch(x, y, {pressure=0.4}) end
-- rivets down the front ridge of the face-plate and along the brow band's lower edge
for i = 0, 6 do local y = 600 + i * 38; rivet(462 - i * 4, y, i < 3 and T3 or S2) end
for i, x in ipairs{352, 400, 520, 580, 640, 700} do rivet(x, 500 - (x - 334) * 0.02 + 6, x < 470 and G3 or G2) end
-- a gold lip along the band's lower edge, catching the light on the left
local b = brush{kind="round", width=1.8, point=0.6}
b:reload(G4, 0.9); b:stroke({{336,498},{400,490},{460,478}}, {pressure={0.3, 0.7, 0.2}, ramps={0.1, 0.3}})
b:reload(G2, 0.8); b:stroke({{470,478},{600,486},{738,498}}, {pressure={0.4, 0.4, 0.1}, ramps={0.1, 0.3}})

--@ chunk 34
wait(1 * 24 * 60)
-- creases in the crimson: dark folds and a lit ridge beside each, on the side toward the window
local cl = CLOTH - HELM:grow(2)
local d = brush{kind="filbert", width=4}
for _, f in ipairs{{{350,920},{320,1040},{300,1180}}, {{420,900},{410,1030},{400,1200}}, {{520,900},{530,1040},{520,1180}}} do
  d:reload(D0, 0.8); d:stroke(f, {pressure={0.2, 0.6, 0.3}, ramps={0.2, 0.3}, clip=cl})
  local r = {} for i, p in ipairs(f) do r[i] = {p[1] - 7, p[2]} end
  d:reload(D3, 0.7); d:stroke(r, {pressure={0.1, 0.45, 0.1}, ramps={0.3, 0.3}, clip=cl})
end

--@ chunk 35
wait(1 * 24 * 60)
local ring = (HELM:grow(7) - HELM:grow(0.5)) * rect(560, 150, 440, 730) - CLOTH:grow(2)
work(ring, {hand="detail", pile=BG1, coverage=3.5, fill=true, clip=ring})

--@ chunk 36
wait(1 * 24 * 60)
-- paint out the crude streak on the lit dome plate
local st = poly({{340,410},{370,330},{400,290},{430,272},{436,284},{404,304},{378,344},{352,414}}) * HELM - CROSS:grow(1)
work(st, {hand="detail", pile=T4, coverage=3.5, fill=true, clip=st})
-- the cross stands proud: its shadow falls to the lower right on the dome
local sh = (poly({{472,252},{480,252},{484,450},{476,452}}) + poly({{526,296},{532,298},{534,318},{528,316}}) + poly({{462,312},{528,306},{532,316},{466,322}})) * HELM - CROSS
work(sh, {hand="detail", pile=T1, coverage=3.5, fill=true, clip=sh})

--@ chunk 37
wait(2 * 24 * 60)
-- a few clean glints on the lit steel, short and sharp, following the dome's curve
local h = brush{kind="round", width=1.6, point=0.7}
local clip = HELM - CROSS:grow(1) - BAND:grow(1)
for _, s in ipairs{{{352,392},{362,366},{376,340}}, {{392,306},{404,292}}, {{500,226},{530,218}}, {{336,470},{338,450}}} do
  h:reload(SH, 0.9); h:stroke(s, {pressure={0.1, 0.8, 0.0}, ramps={0.2, 0.5}, clip=clip})
end

--@ chunk 38
wait(1 * 24 * 60)
local sm = (poly({{330,420},{450,414},{452,446},{330,452}}) * HELM) - CROSS:grow(1) - BAND:grow(0.5)
work(sm, {hand="detail", pile=T3, coverage=3.5, fill=true, clip=sm})

--@ chunk 39
wait(2 * 24 * 60)
local p = PAUL - CLOTH:grow(1)
local function F(pts, pl) local m = (poly(pts) * p):shrink(0); if m:area() > 4 then work(m, {hand="detail", pile=pl, coverage=3.5, fill=true, clip=m}) end end
F({{0,1084},{60,1026},{150,996},{226,1006},{246,1038},{150,1032},{60,1062},{0,1106}}, T3)
F({{0,1114},{60,1070},{150,1040},{248,1044},{266,1086},{150,1086},{50,1126},{0,1156}}, T2)
F({{0,1164},{50,1134},{150,1094},{268,1094},{286,1146},{150,1146},{40,1196},{0,1216}}, T1)

--@ chunk 40
wait(2 * 24 * 60)
local b = brush{kind="round", width=2.6, point=0.4}
local function run(pts, p, pr) b:reload(p, 1.0); b:stroke(pts, {pressure=pr, ramps={0.1, 0.3}, clip=PAUL:grow(2) - CLOTH}) end
run({{4,1080},{60,1020},{150,990},{230,1000}}, G3, {0.5, 0.8, 0.6, 0.2})
run({{4,1110},{60,1066},{150,1036},{250,1040}}, G2, {0.4, 0.6, 0.4, 0.1})
run({{4,1160},{50,1130},{150,1090},{270,1090}}, G1, {0.3, 0.5, 0.3, 0.1})
