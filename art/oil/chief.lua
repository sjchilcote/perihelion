-- easel session "chief": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={24,22}, seed=151,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"bone black",0.6},{"burnt sienna",0.4},{"lead white",0.3}}, um=35, apply="roller"}}}

--@ chunk 2
HEAD = poly({{372,330},{392,262},{440,226},{500,218},{560,232},{604,276},{620,340},{624,410},{612,470},{590,530},{562,578},{520,606},{466,614},{428,598},{398,562},{378,505},{368,440},{366,380}}, true)
EAR = poly({{596,396},{620,388},{634,410},{630,452},{612,480},{596,470}}, true)
NECK = poly({{430,580},{560,560},{590,700},{420,710}})
BODY = poly({{80,1250},{110,1020},{190,860},{330,760},{420,700},{600,690},{700,760},{820,860},{900,1020},{930,1250}}, true)
FIG = HEAD + EAR + NECK + BODY
BG1 = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.2}}
BGM = pile{{"bone brown",2},{"bone black",0.5},{"raw sienna",0.3},{"ultramarine ash",0.2},{"lead white",0.12}}
BGC = pile{{"bone brown",1.4},{"ultramarine ash",0.6},{"lead white",0.45},{"raw sienna",0.3}}
local bg = everywhere() - FIG:grow(3)
local function band(x0, x1) return bg * rect(x0, 0, x1 - x0, 1250) end
work(band(0, 120), {hand="body", pile=BGC, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(band(120, 360), {hand="body", pile=BGM, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(band(360, 1000), {hand="body", pile=BG1, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
blend(band(95, 145), {angle=math.pi/2}); blend(band(335, 385), {angle=math.pi/2})
NV = pile{{"ultramarine blue",1},{"bone black",0.6},{"bone brown",0.3},{"lead white",0.2}}
work(BODY - NECK, {hand="body", pile=NV, coverage=3, fill=true, clip=BODY, angle=math.pi/2, tool="filbert 10"})

--@ chunk 3
SK1 = pile{{"bone brown",1.2},{"burnt sienna",0.6},{"rose madder",0.25},{"lead white",0.35}}
SK2 = pile{{"raw sienna",1},{"red earth",0.4},{"bone brown",0.5},{"lead white",0.9}}
SK3 = pile{{"lead white",2},{"yellow ochre",0.45},{"red earth",0.25},{"raw sienna",0.3}}
SK4 = pile{{"lead white",3},{"yellow ochre",0.4},{"vermilion",0.08},{"raw sienna",0.15}}
SKC = pile{{"lead white",2},{"ultramarine ash",0.35},{"raw sienna",0.35},{"rose madder",0.12}}
SKR = pile{{"burnt sienna",0.8},{"bone brown",0.8},{"raw sienna",0.5},{"lead white",0.5}}
LIT = poly({{366,380},{372,330},{392,262},{440,226},{462,224},{452,330},{432,420},{430,500},{438,560},{430,600},{398,562},{378,505},{368,440}}, true) * HEAD
SHD = poly({{520,226},{560,232},{604,276},{624,410},{612,470},{590,530},{562,578},{520,606},{482,612},{500,560},{502,470},{494,430},{512,380},{528,300}}, true) * HEAD
REF = poly({{596,330},{622,360},{616,470},{590,530},{570,520},{590,420}}, true) * SHD
MID = HEAD - LIT - SHD
work(MID, {hand="body", pile=SK3, coverage=3.5, fill=true, clip=MID, angle=math.pi/2, tool="filbert 6"})
work(LIT, {hand="body", pile=SK4, coverage=3.5, fill=true, clip=LIT, angle=math.pi/2, tool="filbert 6"})
work(SHD - REF, {hand="body", pile=SK1, coverage=3.5, fill=true, clip=SHD - REF, angle=math.pi/2, tool="filbert 6"})
work(REF, {hand="body", pile=SKR, coverage=3.5, fill=true, clip=REF, angle=math.pi/2, tool="filbert 6"})
blend((LIT:grow(6) - LIT:shrink(6)) * MID:grow(6), {angle=math.pi/2})
blend((SHD:grow(5) - SHD:shrink(5)) * MID:grow(5), {angle=math.pi/2})
work(EAR, {hand="detail", pile=SK2, coverage=3.5, fill=true, clip=EAR})
work(NECK - HEAD, {hand="detail", pile=SK1, coverage=3.5, fill=true, clip=NECK - HEAD})

--@ chunk 4
wait(4 * 24 * 60)
SKS = pile{{"bone brown",1},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.5},{"ultramarine ash",0.1}}
SKH = pile{{"lead white",1.6},{"raw sienna",0.6},{"red earth",0.25},{"bone brown",0.25}}
SKD = pile{{"bone brown",1.4},{"raw sienna",0.4},{"burnt sienna",0.3},{"lead white",0.25}}
PLANES = {
  {{{372,330},{430,300},{455,300},{450,384},{372,388}}, SK4},
  {{{455,300},{520,302},{512,384},{450,384}}, SK3},
  {{{520,302},{604,320},{618,384},{512,384}}, SKS},
  {{{370,388},{450,384},{452,398},{378,404}}, SK4},
  {{{452,384},{512,384},{508,398},{452,398}}, SK3},
  {{{378,404},{450,398},{448,440},{384,442}}, SKH},
  {{{492,398},{572,400},{580,444},{496,446}}, SKD},
  {{{572,400},{620,390},{622,450},{580,444}}, SKS},
  {{{368,442},{448,440},{440,500},{398,540},{376,500}}, SK4},
  {{{448,398},{462,396},{456,480},{440,486},{448,440}}, SK4},
  {{{462,396},{492,398},{496,446},{486,486},{470,490},{456,480}}, SKH},
  {{{440,486},{456,480},{470,490},{488,488},{486,506},{444,506}}, SK3},
  {{{486,446},{580,444},{600,500},{560,520},{506,506},{486,506}}, SKS},
  {{{398,540},{440,500},{444,506},{486,506},{506,506},{510,540},{420,548}}, SK3},
  {{{420,548},{510,540},{518,580},{490,606},{440,604},{410,572}}, SK3},
  {{{506,506},{560,520},{600,500},{590,530},{562,578},{520,606},{490,606},{518,580},{510,540}}, SKD},
}
for _, p in ipairs(PLANES) do local m = poly(p[1]) * HEAD; work(m, {hand="detail", pile=p[2], coverage=3.5, fill=true, clip=m}) end
for _, p in ipairs(PLANES) do local m = poly(p[1]) * HEAD; blend((m:grow(3) - m:shrink(3)) * HEAD:shrink(2), {angle=math.pi/2}) end

--@ chunk 5
wait(4 * 24 * 60)
AP = {
  {{{372,330},{400,300},{410,386},{380,400},{366,380}}, SKC},
  {{{400,300},{470,296},{500,300},{492,380},{466,392},{410,386}}, SK4},
  {{{500,300},{560,305},{600,330},{612,385},{540,388},{492,380}}, SKH},
  {{{560,305},{604,320},{622,390},{600,392},{590,340}}, SKS},
  {{{384,398},{410,386},{466,392},{458,406},{400,410}}, SK4},
  {{{466,392},{492,380},{540,388},{600,392},{574,404},{520,398},{484,406}}, SKH},
  {{{392,410},{420,404},{452,410},{448,432},{420,440},{396,430}}, SKH},
  {{{484,406},{520,398},{574,404},{580,428},{540,442},{494,436}}, SKD},
  {{{458,406},{472,402},{466,470},{452,484},{448,470},{452,432}}, SK4},
  {{{472,402},{484,406},{494,436},{492,470},{478,492},{466,470}}, SKD},
  {{{444,474},{466,470},{478,492},{470,506},{446,504}}, SK3},
  {{{396,430},{420,440},{448,432},{448,470},{444,504},{420,520},{392,500},{380,460}}, SK4},
  {{{366,410},{396,430},{380,460},{392,500},{380,506},{368,460}}, SKC},
  {{{494,436},{540,442},{580,428},{578,470},{540,500},{492,500},{492,470}}, SKH},
  {{{580,404},{616,400},{614,470},{590,520},{560,510},{578,470},{580,428}}, SKS},
  {{{420,520},{444,504},{470,506},{492,500},{504,540},{470,546},{424,546}}, SK3},
  {{{492,500},{540,500},{560,510},{540,560},{506,548},{504,540}}, SKD},
  {{{430,556},{470,552},{502,556},{504,592},{470,610},{440,600}}, SK3},
  {{{506,548},{540,560},{560,510},{590,520},{570,570},{530,604},{504,592},{502,556}}, SKS},
  {{{378,505},{392,500},{420,520},{424,546},{430,556},{440,600},{420,592},{398,562}}, SKH},
}
for _, p in ipairs(AP) do local m = poly(p[1]) * HEAD:grow(1); work(m, {hand="detail", pile=p[2], coverage=4, fill=true, clip=m}) end

--@ chunk 6
wait(3 * 24 * 60)
HG1 = pile{{"lead white",2.5},{"ultramarine ash",0.4},{"raw sienna",0.25},{"zinc white",0.3}}
HG2 = pile{{"lead white",1.6},{"ultramarine ash",0.5},{"raw sienna",0.35},{"bone brown",0.25}}
HG3 = pile{{"lead white",0.9},{"bone brown",0.7},{"ultramarine ash",0.4},{"raw sienna",0.3}}
HG4 = pile{{"bone brown",1},{"bone black",0.4},{"lead white",0.35},{"ultramarine ash",0.2}}
HAIR = poly({{366,345},{372,300},{392,258},{432,224},{500,210},{570,222},{614,262},{632,330},{630,398},{612,398},{606,340},{572,304},{520,294},{470,290},{430,294},{394,306}}, true)
local function F(pts, p) local m = poly(pts) * HAIR; if m:area() > 2 then work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}) end end
F({{360,350},{372,290},{400,250},{430,290},{394,310}}, HG2)
F({{400,250},{432,222},{500,208},{490,262},{430,290}}, HG1)
F({{500,208},{572,220},{560,272},{490,262}}, HG2)
F({{430,290},{490,262},{560,272},{570,304},{470,292}}, HG2)
F({{572,220},{616,260},{600,300},{560,272}}, HG3)
F({{560,272},{600,300},{632,330},{634,400},{608,400},{604,340},{570,304}}, HG4)

--@ chunk 7
wait(3 * 24 * 60)
-- short cropped strokes in the hair, following the growth back from the hairline, light on the crown
local b = brush{kind="round", width=1.6, point=0.7}
for i = 0, 40 do
  local t = i / 40; local x = lerp(380, 620, t) + 6 * math.sin(i * 2.3); local y = 300 - 60 * math.sin(math.pi * t) + 6 * math.cos(i * 1.7)
  local dx, dy = (x - 500) * 0.12, -14
  local p = (x < 470) and HG1 or ((x < 560) and HG2 or HG3)
  b:reload(p, 0.7); b:stroke({{x, y}, {x + dx, y + dy}}, {pressure={0.4, 0.05}, ramps={0.1, 0.6}, clip=HAIR})
end
-- the ear: a rim lit faintly, the bowl in shadow
EARR = pile{{"burnt sienna",0.7},{"raw sienna",0.6},{"lead white",0.5},{"rose madder",0.2}}
local inner = poly({{604,404},{620,400},{624,420},{616,452},{604,458}}, true)
work(inner, {hand="detail", pile=SKD, coverage=4, fill=true, clip=inner})
local rim = brush{kind="round", width=2.4, point=0.6}
rim:reload(EARR, 0.8); rim:stroke({{600,396},{622,390},{632,412},{628,452},{610,480}}, {pressure={0.3, 0.6, 0.5, 0.2}, ramps={0.2, 0.3}})

--@ chunk 8
wait(3 * 24 * 60)
EW = pile{{"lead white",2},{"ultramarine ash",0.35},{"raw sienna",0.25},{"bone brown",0.1}}
EWD = pile{{"lead white",1},{"ultramarine ash",0.4},{"raw sienna",0.3},{"bone brown",0.4}}
IR = pile{{"bone brown",1},{"burnt sienna",0.4},{"ultramarine blue",0.2},{"lead white",0.15}}
DK = pile{{"bone black",1},{"bone brown",1},{"burnt sienna",0.3}}
local function F(pts, p) local m = poly(pts, true); work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=m}); return m end
-- far eye (lit side)
local e1 = F({{404,421},{414,414},{428,412},{442,416},{448,423},{436,428},{420,428}}, EW)
-- near eye, slightly foreshortened, in half-shadow
local e2 = F({{510,420},{520,413},{534,411},{548,415},{554,421},{542,427},{524,428}}, EWD)
-- irises, partly under the upper lid
local i1 = ellipse(428, 421, 6.5, 7) * e1; work(i1, {hand="detail", pile=IR, coverage=4, fill=true, clip=i1})
local i2 = ellipse(530, 420, 6, 7) * e2; work(i2, {hand="detail", pile=IR, coverage=4, fill=true, clip=i2})

--@ chunk 9
wait(3 * 24 * 60)
local b = brush{kind="round", width=2.6, point=0.6}
local f = brush{kind="round", width=1.4, point=0.7}
local t = brush{kind="round", width=1.8, point=0.2}
local function S(br, p, pts, pr) br:reload(p, 0.85); br:stroke(pts, {pressure=pr, ramps={0.2, 0.3}}) end
-- pupils
t:reload(DK, 0.9); t:touch(428, 421, {pressure=0.35}); t:reload(DK, 0.9); t:touch(530, 420, {pressure=0.32})
-- upper lid lines, heavy, shadowing the top of the eye
S(b, DK, {{402,421},{414,412},{428,410},{442,414},{450,422}}, {0.2, 0.7, 0.7, 0.4})
S(b, DK, {{508,420},{520,411},{534,409},{548,413},{556,421}}, {0.2, 0.7, 0.7, 0.5})
-- lid creases, a soft line above
S(f, SKD, {{406,409},{424,402},{444,406}}, {0.1, 0.45, 0.1})
S(f, SKS, {{512,408},{532,401},{552,406}}, {0.1, 0.45, 0.1})
-- lower lids: a thin lit rim on the far eye, a bag beneath, a crow's foot or two
S(f, SK3, {{408,430},{424,432},{444,427}}, {0.1, 0.45, 0.1})
S(f, SKH, {{412,438},{428,442},{446,436}}, {0.05, 0.35, 0.05})
S(f, SKD, {{514,430},{530,432},{548,428}}, {0.1, 0.4, 0.1})
S(f, SKH, {{398,420},{388,414}}, {0.3, 0.05}); S(f, SKH, {{398,426},{386,428}}, {0.3, 0.05})
-- catchlights from the strip light, small and cold, on the window side of each iris
t:reload(pile{{"lead white",2},{"zinc white",1},{"ultramarine ash",0.1}}, 0.85); t:touch(425, 418, {pressure=0.18}); t:touch(527, 417, {pressure=0.15})
-- grey brows following the ridge, sparse
local BR = pile{{"lead white",1},{"bone brown",0.8},{"ultramarine ash",0.3}}
for i = 0, 10 do local x = 400 + i * 5; local y = 400 - 4 * math.sin(i / 10 * math.pi); S(f, BR, {{x, y + 2}, {x + 6, y - 2}}, {0.5, 0.1}) end
for i = 0, 10 do local x = 506 + i * 5; local y = 398 - 4 * math.sin(i / 10 * math.pi); S(f, HG4, {{x, y + 2}, {x + 6, y - 1}}, {0.5, 0.1}) end

--@ chunk 10
wait(3 * 24 * 60)
IR2 = pile{{"bone brown",1.2},{"burnt sienna",0.5},{"raw sienna",0.3},{"bone black",0.2}}
EW2 = pile{{"lead white",1.4},{"raw sienna",0.4},{"ultramarine ash",0.3},{"bone brown",0.25}}
EWD2 = pile{{"lead white",0.6},{"raw sienna",0.4},{"bone brown",0.6},{"ultramarine ash",0.25}}
local function F(pts, p, smooth) local m = poly(pts, smooth); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
-- whites dimmed
local e1 = poly({{404,421},{414,414},{428,412},{442,416},{448,423},{436,428},{420,428}}, true)
local e2 = poly({{510,420},{520,413},{534,411},{548,415},{554,421},{542,427},{524,428}}, true)
work(e1, {hand="detail", pile=EW2, coverage=4.5, fill=true, clip=e1})
work(e2, {hand="detail", pile=EWD2, coverage=4.5, fill=true, clip=e2})
-- larger, warmer irises
local i1 = ellipse(428, 422, 8, 8.5) * e1; work(i1, {hand="detail", pile=IR2, coverage=4.5, fill=true, clip=i1})
local i2 = ellipse(531, 421, 7.5, 8.5) * e2; work(i2, {hand="detail", pile=IR2, coverage=4.5, fill=true, clip=i2})
-- upper lids lowered: the lid's skin comes down over the top of each eye, tired
F({{398,412},{414,404},{430,402},{446,406},{452,418},{442,416},{428,414},{414,416},{404,422}}, SK3, true)
F({{504,412},{520,403},{536,401},{552,405},{558,418},{548,415},{534,413},{520,415},{510,421}}, SKD, true)

--@ chunk 11
wait(3 * 24 * 60)
local b = brush{kind="round", width=2.4, point=0.6}
local f = brush{kind="round", width=1.3, point=0.7}
local t = brush{kind="round", width=2.0, point=0.2}
local function S(br, p, pts, pr) br:reload(p, 0.85); br:stroke(pts, {pressure=pr, ramps={0.2, 0.3}}) end
-- the lid edge, a dark line where the lid meets the eye, heavier at the outer corners
S(b, DK, {{402,422},{414,416},{428,414},{442,416},{450,423}}, {0.3, 0.6, 0.6, 0.5})
S(b, DK, {{508,421},{520,415},{534,413},{548,415},{557,422}}, {0.3, 0.6, 0.6, 0.6})
t:reload(DK, 0.9); t:touch(428, 423, {pressure=0.38}); t:reload(DK, 0.9); t:touch(531, 422, {pressure=0.36})
t:reload(pile{{"lead white",2},{"zinc white",1},{"ultramarine ash",0.1}}, 0.85); t:touch(425, 419, {pressure=0.17})
t:reload(pile{{"lead white",1.6},{"zinc white",0.6},{"ultramarine ash",0.2}}, 0.85); t:touch(528, 418, {pressure=0.14})
-- brows: soft solid bands of grey, thicker toward the nose
local BRL = pile{{"lead white",1.2},{"bone brown",0.7},{"ultramarine ash",0.3}}
local brow1 = poly({{396,398},{420,390},{448,392},{450,399},{422,398},{398,404}}, true); work(brow1, {hand="detail", pile=BRL, coverage=4, fill=true, clip=brow1})
local brow2 = poly({{504,396},{530,388},{556,392},{560,398},{532,396},{506,402}}, true); work(brow2, {hand="detail", pile=HG4, coverage=4, fill=true, clip=brow2})

--@ chunk 12
wait(2 * 24 * 60)
LIPU = pile{{"burnt sienna",0.6},{"rose madder",0.3},{"bone brown",0.6},{"lead white",0.6}}
LIPL = pile{{"lead white",1.4},{"red earth",0.4},{"rose madder",0.2},{"raw sienna",0.3}}
local function F(pts, p) local m = poly(pts, true); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
-- nose underside plane in shadow, the cast shadow falling down-right onto the upper lip
F({{444,500},{470,504},{486,500},{482,510},{456,512},{442,508}}, SKD)
F({{470,512},{492,506},{502,520},{486,526},{470,522}}, SKS)
-- nostrils
F({{448,502},{456,500},{458,506},{450,507}}, DK)
F({{470,503},{480,500},{483,506},{473,508}}, DK)
-- the upper lip, a narrow plane turned down, in half-shadow; lower lip a lit plane; the mouth line between
F({{426,544},{446,538},{464,540},{484,537},{504,543},{486,548},{464,547},{444,548}}, LIPU)
F({{434,552},{466,552},{496,551},{486,562},{464,566},{442,562}}, LIPL)

--@ chunk 13
wait(3 * 24 * 60)
local b = brush{kind="round", width=2.2, point=0.6}
local f = brush{kind="round", width=1.4, point=0.7}
local function S(br, p, pts, pr) br:reload(p, 0.85); br:stroke(pts, {pressure=pr, ramps={0.2, 0.3}}) end
-- the mouth line: dark, closed, the corners easing down a little, tired
S(b, DK, {{426,549},{444,550},{464,550},{484,549},{506,550}}, {0.2, 0.6, 0.6, 0.5, 0.2})
-- shadow under the lower lip and the chin's cleft above it
S(f, SKD, {{440,570},{464,574},{490,570}}, {0.1, 0.5, 0.1})
-- nasolabial folds: strong on the near side in shadow, faint on the lit side
S(b, SKS, {{488,500},{500,520},{508,540},{512,556}}, {0.3, 0.6, 0.4, 0.1})
S(f, SKH, {{442,504},{430,522},{424,542}}, {0.3, 0.4, 0.05})
-- nose: a lit ridge and a cold highlight on the tip
S(f, SK4, {{458,410},{456,450},{452,478}}, {0.2, 0.5, 0.2})
local t = brush{kind="round", width=2.2, point=0.2}
t:reload(pile{{"lead white",2.5},{"zinc white",0.6},{"ultramarine ash",0.1}}, 0.85); t:touch(453, 488, {pressure=0.25})

--@ chunk 14
wait(3 * 24 * 60)
LU2 = pile{{"bone brown",0.9},{"burnt sienna",0.4},{"rose madder",0.15},{"lead white",0.45}}
LL2 = pile{{"lead white",1.6},{"raw sienna",0.5},{"red earth",0.2},{"rose madder",0.08}}
BRW = pile{{"lead white",0.9},{"bone brown",0.9},{"raw sienna",0.3},{"bone black",0.1}}
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
-- the old full lips painted back to skin, then thinner ones
F({{422,534},{506,534},{508,572},{424,572}}, SK3)
F({{486,534},{508,534},{510,572},{486,572}}, SKD)
F({{430,544},{464,542},{500,545},{500,549},{464,548},{430,550}}, LU2, true)
F({{438,552},{466,553},{494,552},{486,558},{464,560},{444,558}}, LL2, true)
F({{430,548},{466,547},{502,548},{502,551},{466,551},{430,552}}, DK)
-- a squarer jaw and chin
F({{586,520},{606,546},{596,592},{560,620},{520,622},{530,604},{570,570},{590,530}}, SKS)
F({{396,560},{390,584},{412,610},{444,616},{440,600},{420,592}}, SKH)
F({{440,600},{470,610},{504,592},{520,622},{470,628},{444,616}}, SKD)
-- brows heavier and warm grey
F({{394,400},{420,388},{450,390},{452,400},{422,400},{396,406}}, BRW, true)
F({{502,398},{530,386},{560,390},{562,398},{532,396},{504,404}}, pile{{"bone brown",1.2},{"bone black",0.3},{"lead white",0.4}}, true)

--@ chunk 15
wait(3 * 24 * 60)
-- stubble: a few days' growth, fine grey dots over jaw, chin and upper lip, darker in the shadow
local lips = poly({{426,540},{506,540},{504,562},{428,562}})
local beard = (poly({{378,500},{420,520},{444,512},{500,512},{560,512},{606,520},{610,560},{590,600},{560,622},{470,630},{420,616},{390,584},{372,530}}, true)) - lips - poly({{440,496},{490,496},{490,512},{440,512}})
local lit = beard * rect(0, 0, 470, 2000)
local shd = beard - lit
stipple(lit, {pile=pile{{"lead white",1},{"ultramarine ash",0.5},{"bone brown",0.5}}, width=1.2, coverage=0.55, cluster=0.3, pressure={0.3, 0.5}})
stipple(shd, {pile=pile{{"bone brown",1},{"bone black",0.5},{"ultramarine ash",0.3}}, width=1.2, coverage=0.6, cluster=0.3, pressure={0.3, 0.5}})

--@ chunk 16
wait(4 * 24 * 60)
-- background over the stubble that spilled outside the face
local spill = (HEAD:grow(14) - HEAD) * rect(340, 470, 120, 200)
work(spill, {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=spill})
-- muzzle and chin planes re-laid clean (the plane pattern, now with the squarer jaw)
local function F(pts, p) local m = poly(pts) * (HEAD + poly({{586,520},{606,546},{596,592},{560,620},{520,622},{530,604},{570,570},{590,530}}) + poly({{396,560},{390,584},{412,610},{444,616},{440,600},{420,592}}) + poly({{440,600},{470,610},{504,592},{520,622},{470,628},{444,616}})); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end
F({{420,514},{444,510},{470,514},{492,508},{504,540},{470,544},{424,544}}, SK3)
F({{492,508},{540,500},{560,510},{540,560},{506,548},{504,540}}, SKD)
F({{424,552},{470,552},{504,552},{506,592},{470,610},{440,600},{426,580}}, SK3)
F({{506,548},{540,560},{560,510},{606,546},{596,592},{560,620},{520,622},{506,592},{504,552}}, SKS)
F({{378,505},{392,500},{420,520},{424,546},{426,580},{440,600},{444,616},{412,610},{390,584},{396,560}}, SKH)
F({{440,600},{470,610},{506,592},{520,622},{470,628},{444,616}}, SKD)

--@ chunk 17
wait(3 * 24 * 60)
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
F({{430,544},{464,541},{500,545},{500,548},{464,547},{430,549}}, LU2, true)
F({{440,552},{466,553},{494,552},{486,558},{464,560},{446,558}}, LL2, true)
F({{430,547},{466,546},{502,547},{502,550},{466,550},{430,551}}, DK)
F({{440,566},{470,569},{494,566},{490,571},{468,573},{444,571}}, SKH, true)
-- stubble, light this time
local lips = poly({{426,540},{506,540},{504,562},{428,562}})
local beard = poly({{382,506},{420,520},{444,514},{500,514},{560,512},{604,522},{604,560},{588,600},{560,620},{470,628},{420,614},{394,584},{380,530}}, true) - lips - poly({{440,498},{490,498},{490,512},{440,512}})
local lit = beard * rect(0, 0, 470, 2000)
stipple(lit, {pile=pile{{"lead white",0.8},{"ultramarine ash",0.5},{"bone brown",0.6}}, width=1.0, coverage=0.25, cluster=0.2, pressure={0.25, 0.4}})
stipple(beard - lit, {pile=pile{{"bone brown",1},{"bone black",0.4},{"ultramarine ash",0.3}}, width=1.0, coverage=0.3, cluster=0.2, pressure={0.25, 0.4}})
-- nasolabial fold and mouth corner, as narrow shapes rather than strokes
F({{486,506},{494,506},{506,530},{512,556},{506,556},{498,532}}, SKS)
F({{502,546},{508,548},{510,556},{504,554}}, SKS)

--@ chunk 18
wait(3 * 24 * 60)
BRW2 = pile{{"bone brown",0.9},{"raw sienna",0.6},{"yellow ochre",0.3},{"lead white",0.7}}
BRW3 = pile{{"bone brown",1.2},{"raw sienna",0.4},{"bone black",0.2},{"lead white",0.3}}
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
F({{394,400},{420,388},{450,390},{452,400},{422,400},{396,406}}, BRW2, true)
F({{502,398},{530,386},{560,390},{562,398},{532,396},{504,404}}, BRW3, true)
-- hairline gap on the near side, and the red sliver near the brow
F({{500,292},{572,298},{606,322},{604,334},{570,308},{500,304}}, HG4)
F({{540,384},{604,384},{604,394},{540,394}}, SKS)
-- the far jaw contour made clean: background outside, a half-tone plane inside
local jaw = poly({{368,440},{372,500},{384,548},{398,580},{420,606},{448,622},{470,630}}, false)
local outside = poly({{340,440},{368,440},{372,500},{384,548},{398,580},{420,606},{448,622},{470,632},{470,660},{340,660}})
work(outside - NECK, {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=outside - NECK})
F({{372,500},{392,500},{420,520},{424,546},{426,580},{440,600},{448,620},{420,606},{398,580},{384,548}}, SKH)

--@ chunk 19
wait(3 * 24 * 60)
-- light stubble back over the repainted far jaw, and the neck: a warm shadow under the jaw, the far side half-lit
stipple(poly({{378,505},{420,520},{426,580},{446,616},{420,606},{398,580},{384,548}}), {pile=pile{{"lead white",0.8},{"ultramarine ash",0.5},{"bone brown",0.6}}, width=1.0, coverage=0.25, cluster=0.2, pressure={0.25, 0.4}})
local nk = NECK - HEAD - poly({{586,520},{606,546},{596,592},{560,620},{520,622},{470,630},{444,616}})
work(nk * rect(0,0,470,2000), {hand="detail", pile=SKH, coverage=4.5, fill=true, clip=nk})
work(nk * rect(470,0,600,2000), {hand="detail", pile=SKD, coverage=4.5, fill=true, clip=nk})
local under = nk * rect(0, 610, 1000, 40)
work(under, {hand="detail", pile=SKS, coverage=4.5, fill=true, clip=under})

--@ chunk 20
wait(2 * 24 * 60)
NVL = pile{{"ultramarine blue",1},{"lead white",0.7},{"bone brown",0.25},{"ultramarine ash",0.3}}
NVM = pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.35},{"bone brown",0.2}}
NVD = pile{{"ultramarine blue",0.8},{"bone black",0.8},{"bone brown",0.4}}
local body = BODY - HEAD
local function F(pts, p) local m = poly(pts, true) * body; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{80,1250},{110,1020},{190,860},{330,760},{400,720},{420,840},{330,960},{250,1250}}, NVL)
F({{250,1250},{330,960},{420,840},{505,820},{600,840},{680,960},{740,1250}}, NVM)
F({{600,690},{700,760},{820,860},{900,1020},{930,1250},{740,1250},{680,960},{600,840},{620,760}}, NVD)
-- collar flaps, the V open at the throat
F({{404,680},{448,664},{470,700},{505,810},{450,780},{398,736}}, NVL)
F({{560,660},{608,676},{630,740},{570,784},{505,810},{540,700}}, NVD)
local v = poly({{448,664},{560,660},{540,700},{505,810},{470,700}}) - HEAD
work(v, {hand="detail", pile=SKD, coverage=4.5, fill=true, clip=v})
local tee = poly({{470,700},{540,700},{505,810}}) * poly({{440,740},{580,740},{580,820},{440,820}})
work(tee, {hand="detail", pile=NVD, coverage=4.5, fill=true, clip=tee})

--@ chunk 21
wait(3 * 24 * 60)
SL1 = pile{{"lead white",2},{"ultramarine ash",0.5},{"zinc white",0.5}}
SL2 = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone brown",0.4}}
SL3 = pile{{"bone brown",0.8},{"ultramarine ash",0.7},{"lead white",0.4},{"bone black",0.2}}
AMB = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"yellow ochre",0.4}}
AMBD = pile{{"Mars orange",1},{"burnt sienna",0.5},{"raw sienna",0.3}}
local body = BODY - HEAD
-- the reflective band across the chest, following the body's curve
local band = poly({{100,1060},{300,1004},{505,990},{700,1004},{910,1062},{914,1092},{700,1034},{505,1020},{300,1034},{96,1090}}) * body
work(band * rect(0,0,330,2000), {hand="detail", pile=SL1, coverage=4.5, fill=true, clip=band})
work(band * rect(330,0,350,2000), {hand="detail", pile=SL2, coverage=4.5, fill=true, clip=band})
work(band * rect(680,0,400,2000), {hand="detail", pile=SL3, coverage=4.5, fill=true, clip=band})
-- the amber hazard patch on the near-window shoulder, with its chevron
local patch = poly({{196,880},{256,860},{268,900},{208,920}})
work(patch, {hand="detail", pile=AMB, coverage=4.5, fill=true, clip=patch})
local chev = poly({{214,898},{232,884},{250,892},{248,900},{232,894},{218,906}})
work(chev, {hand="detail", pile=AMBD, coverage=4.5, fill=true, clip=chev})

--@ chunk 22
wait(4 * 24 * 60)
NV2L = pile{{"ultramarine blue",1},{"bone black",0.35},{"lead white",0.45},{"bone brown",0.3}}
NV2M = pile{{"ultramarine blue",1},{"bone black",0.7},{"bone brown",0.35},{"lead white",0.2}}
NV2D = pile{{"ultramarine blue",0.7},{"bone black",1},{"bone brown",0.4}}
BODY2 = poly({{80,1250},{110,1020},{190,860},{330,760},{404,700},{430,650},{580,640},{610,700},{700,760},{820,860},{900,1020},{930,1250}})
local keep = poly({{196,880},{256,860},{268,900},{208,920}}):grow(1) + poly({{100,1060},{300,1004},{505,990},{700,1004},{910,1062},{914,1092},{700,1034},{505,1020},{300,1034},{96,1090}})
local body = BODY2 - HEAD - keep
local function F(pts, p) local m = poly(pts) * body; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{60,1260},{110,1020},{190,860},{330,760},{404,700},{430,800},{360,1000},{300,1260}}, NV2L)
F({{300,1260},{360,1000},{430,800},{505,830},{590,800},{650,1000},{700,1260}}, NV2M)
F({{580,640},{610,700},{700,760},{820,860},{900,1020},{940,1260},{700,1260},{650,1000},{590,800}}, NV2D)
-- the collar, standing up round the neck, opening in a V
F({{404,700},{430,650},{462,656},{480,720},{505,830},{456,790},{416,744}}, NV2L)
F({{548,654},{580,640},{610,700},{604,760},{560,790},{505,830},{530,720}}, NV2D)
local v = poly({{462,656},{548,654},{530,720},{505,830},{480,720}}) - HEAD
work(v * rect(0, 0, 2000, 740), {hand="detail", pile=SKD, coverage=4.5, fill=true, clip=v})
work(v * rect(0, 740, 2000, 200), {hand="detail", pile=NV2D, coverage=4.5, fill=true, clip=v})

--@ chunk 23
wait(2 * 24 * 60)
-- the background beside the head re-laid in its bands, the patch gone
local bg = (everywhere() - (HEAD + EAR + BODY2 + NECK):grow(2)) * rect(120, 120, 880, 640)
local function band(x0, x1) return bg * rect(x0, 0, x1 - x0, 1250) end
work(band(120, 360), {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=bg})
work(band(360, 1000), {hand="detail", pile=BG1, coverage=4.5, fill=true, clip=bg})

--@ chunk 24
local bg = everywhere() - (HEAD + EAR + BODY2 + NECK):grow(3)
blend(bg * rect(95, 0, 60, 1250), {angle=math.pi/2})
blend(bg * rect(330, 0, 60, 1250), {angle=math.pi/2})
blend(bg * rect(120, 100, 880, 40), {angle=0})

--@ chunk 25
wait(4 * 24 * 60)
CB = pile{{"burnt sienna",0.8},{"raw sienna",0.8},{"bone brown",0.6}}
CBD = pile{{"bone brown",1.2},{"burnt sienna",0.5},{"bone black",0.3}}
PAP = pile{{"lead white",2},{"raw sienna",0.25},{"ultramarine ash",0.2}}
PAPD = pile{{"lead white",1.2},{"raw sienna",0.4},{"ultramarine ash",0.35},{"bone brown",0.25}}
-- the clipboard held flat against the chest, tilted a little, its top edge just below the band
CLIP = poly({{372,1052},{606,1036},{622,1260},{386,1270}})
work(CLIP, {hand="detail", pile=CB, coverage=4.5, fill=true, clip=CLIP})
local pap = poly({{388,1070},{592,1056},{604,1260},{400,1270}})
work(pap * rect(0,0,500,2000), {hand="detail", pile=PAP, coverage=4.5, fill=true, clip=pap})
work(pap * rect(500,0,500,2000), {hand="detail", pile=PAPD, coverage=4.5, fill=true, clip=pap})
local clamp_ = poly({{446,1036},{534,1030},{536,1062},{448,1068}})
work(clamp_, {hand="detail", pile=pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.3}}, coverage=4.5, fill=true, clip=clamp_})
local edge = poly({{372,1052},{606,1036},{608,1044},{374,1060}}) - clamp_
work(edge, {hand="detail", pile=CBD, coverage=4.5, fill=true, clip=edge})

--@ chunk 26
wait(3 * 24 * 60)
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
-- left hand (toward the light): sleeve, back of the hand, four fingers curling over the board's edge
F({{250,1100},{320,1070},{350,1150},{290,1190}}, NV2L)
F({{318,1074},{372,1070},{392,1112},{386,1148},{348,1150}}, SK4)
F({{348,1150},{386,1148},{392,1112},{404,1130},{394,1160}}, SK3)
for k = 0, 3 do local y = 1082 + k * 17
  F({{378, y}, {404, y - 2}, {418, y + 4}, {416, y + 14}, {402, y + 13}, {380, y + 13}}, k < 2 and SK4 or SK3)
  F({{404, y + 12}, {416, y + 12}, {416, y + 15}, {404, y + 15}}, SKD)
end
-- right hand in shadow, gripping the right edge
F({{690,1150},{740,1130},{760,1200},{700,1230}}, NV2D)
F({{612,1120},{660,1110},{696,1150},{690,1200},{640,1210},{612,1180}}, SKS)
for k = 0, 2 do local y = 1126 + k * 20
  F({{588, y}, {614, y - 2}, {616, y + 14}, {592, y + 15}}, SKD)
end

--@ chunk 27
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.8}
local pap = poly({{420,1078},{586,1066},{596,1250},{420,1260}})
for r = 0, 8 do local y = 1090 + r * 18
  local pts = {} for i = 0, 18 do local x = 430 + i * 8; pts[#pts+1] = {x, y - (x - 430) * 0.07 + 2 * math.sin(i * 1.9 + r)} end
  d:reload(pile{{"bone brown",1},{"ultramarine ash",0.4},{"lead white",0.4}}, 0.6); d:stroke(pts, {pressure={0.3, 0.3}, ramps={0.1, 0.2}, clip=pap})
end
-- knuckle lights and nail glints on the lit hand
local t = brush{kind="round", width=2.0, point=0.2}
for k = 0, 3 do t:reload(pile{{"lead white",2.5},{"zinc white",0.5},{"ultramarine ash",0.1}}, 0.8); t:touch(390, 1083 + k * 17, {pressure=0.22}) end

--@ chunk 28
wait(3 * 24 * 60)
BGa = pile{{"bone brown",1.6},{"ultramarine ash",0.45},{"raw sienna",0.3},{"lead white",0.3},{"bone black",0.2}}
local bg = everywhere() - (HEAD + EAR + BODY2 + NECK + HAIR):grow(2)
local function band(x0, x1) return bg * rect(x0, 0, x1 - x0, 1250) end
work(band(0, 110), {hand="body", pile=BGC, coverage=4, fill=true, clip=bg, angle=math.pi/2})
work(band(110, 240), {hand="body", pile=BGa, coverage=4, fill=true, clip=bg, angle=math.pi/2})
work(band(240, 400), {hand="body", pile=BGM, coverage=4, fill=true, clip=bg, angle=math.pi/2})
work(band(400, 1000) * rect(0, 0, 2000, 760), {hand="body", pile=BG1, coverage=4, fill=true, clip=bg, angle=math.pi/2})
blend(band(85, 135), {angle=math.pi/2}); blend(band(215, 265), {angle=math.pi/2}); blend(band(375, 425), {angle=math.pi/2})

--@ chunk 29
wait(4 * 24 * 60)
local pap = poly({{388,1070},{592,1056},{604,1260},{400,1270}}) - poly({{378,1074},{420,1074},{420,1160},{378,1160}}) - poly({{586,1110},{620,1110},{620,1200},{586,1200}}) - poly({{446,1036},{534,1030},{536,1062},{448,1068}})
work(pap * rect(0,0,500,2000), {hand="detail", pile=PAP, coverage=5, fill=true, clip=pap})
work(pap * rect(500,0,500,2000), {hand="detail", pile=PAPD, coverage=5, fill=true, clip=pap})

--@ chunk 30
wait(3 * 24 * 60)
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
-- writing on the paper
local d = brush{kind="round", width=1.2, point=0.8}
local pap = poly({{420,1078},{586,1066},{596,1250},{420,1260}})
for r = 0, 8 do local y = 1090 + r * 18
  local pts = {} for i = 0, 18 do local x = 430 + i * 8; pts[#pts+1] = {x, y - (x - 430) * 0.07 + 2 * math.sin(i * 1.9 + r)} end
  d:reload(pile{{"bone brown",1},{"ultramarine ash",0.4},{"lead white",0.4}}, 0.6); d:stroke(pts, {pressure={0.3, 0.3}, ramps={0.1, 0.2}, clip=pap})
end
-- the strip light's cold rim along the lit contour, as a narrow facet
COLD = pile{{"lead white",2.5},{"zinc white",0.8},{"ultramarine ash",0.3}}
F({{366,345},{372,300},{392,258},{432,224},{436,230},{398,264},{378,304},{372,346}}, COLD)
F({{368,380},{372,345},{376,346},{374,380},{372,440},{370,440}}, COLD)
-- kind eyes: lower lids lifted a touch, small crow's feet on the lit side
F({{408,431},{424,435},{444,430},{442,434},{424,439},{410,435}}, SK4, true)
F({{394,418},{384,412},{386,410},{396,415}}, SKH)
F({{394,424},{382,426},{382,423},{394,421}}, SKH)
F({{396,430},{386,436},{384,433},{394,428}}, SKH)
F({{514,431},{530,434},{548,430},{546,434},{530,438},{516,435}}, SKH, true)

--@ chunk 31
wait(3 * 24 * 60)
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
F({{510,428},{532,432},{552,428},{552,438},{532,442},{510,438}}, SKD)
F({{536,382},{610,382},{612,398},{536,398}}, SKS)
F({{504,398},{530,386},{560,390},{596,392},{596,398},{560,397},{532,396},{506,404}}, BRW3, true)
-- near-side hair, one plane graded into the dark
F({{500,292},{560,272},{600,300},{632,330},{634,400},{612,400},{606,340},{572,304},{520,296}}, HG3)
F({{600,300},{632,330},{634,400},{614,400},{608,340}}, HG4)
-- under the chin, into the neck's shadow
F({{470,628},{520,622},{560,620},{556,640},{470,642}}, SKS)
F({{500,606},{536,612},{530,626},{504,624}}, SKS)

--@ chunk 32
wait(3 * 24 * 60)
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
F({{500,288},{576,292},{604,318},{600,330},{570,306},{500,306}}, HG3)
F({{536,380},{612,380},{612,402},{536,402}}, SKH)

--@ chunk 33
wait(3 * 24 * 60)
local function F(pts, p, sm) local m = poly(pts, sm); work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}); return m end
F({{504,398},{530,386},{560,390},{590,394},{590,400},{560,397},{532,396},{506,404}}, BRW3, true)
F({{596,396},{612,394},{612,402},{596,404}}, SKS)
