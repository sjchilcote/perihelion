-- easel session "relics": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.25, linen=14, seed=77,
  ground={{pile={{"bone brown",2},{"ultramarine blue",1},{"lead white",0.3}}, um=60, apply="knife", texture=0.3}}}

--@ chunk 2
dk = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.5}}
wall = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",0.6}}
flr = pile{{"burnt sienna",1},{"ultramarine blue",1},{"yellow ochre",0.4},{"bone black",0.3}}
far = pile{{"ultramarine ash",1},{"bone black",0.5},{"cerulean blue",0.3},{"zinc white",0.4}}
local lw = poly({{0,0},{340,330},{340,460},{0,800}})
local rw = poly({{430,330},{1000,0},{1000,690},{430,460}})
local fl = poly({{0,800},{340,460},{430,460},{1000,690},{1000,800}})
local ce = poly({{0,0},{1000,0},{430,330},{340,330}})
local fe = rect(340,330,90,130)
work(ce, {hand="broad", pile=dk, coverage=2.5, fill=true, clip=true})
work(lw, {hand="broad", pile=dk, coverage=2.5, fill=true, clip=true, angle=0.8})
work(rw, {hand="broad", pile=wall, coverage=2.5, fill=true, clip=true, angle=-0.5})
work(fl, {hand="broad", pile=flr, coverage=2.5, fill=true, clip=true, angle=0.1})
work(fe, {hand="body", pile=far, coverage=3, fill=true, clip=true, angle=1.57})

--@ chunk 3
metal = pile{{"bone black",1},{"ultramarine blue",0.6},{"burnt sienna",0.4},{"zinc white",0.25}}
wreckm = pile{{"bone black",1.5},{"burnt sienna",1},{"ultramarine blue",0.5}}
WR = body_of{spine={{706,352},{715,430},{720,520},{720,600}}, widths={34,70,72,70},
  limbs={ {{720,600},{640,650},{560,720},{520,735}, widths={34,30,26,24}},
          {{760,600},{830,560},{800,650},{770,720}, widths={34,32,28,26}},
          {{660,410},{630,500},{610,590},{600,640}, widths={22,20,18,16}},
          {{775,410},{805,500},{815,580}, widths={22,20,18}} }, char="firm", seed=4}
NF = body_of{spine={{470,330},{440,400},{410,480},{400,560}}, widths={34,62,62,58},
  limbs={ {{405,560},{480,600},{500,650},{480,700}, widths={32,30,26,24}},
          {{395,560},{360,630},{330,700},{300,705}, widths={30,26,22,18}},
          {{480,380},{560,420},{620,450},{665,470}, widths={22,20,16,14}},
          {{420,400},{430,480},{455,540}, widths={20,18,16}} }, char="firm", seed=5}
work(WR:mask(), {hand="body", pile=wreckm, coverage=3, fill=true, clip=true})
work(NF:mask(), {hand="body", pile=metal, coverage=3, fill=true, clip=true})

--@ chunk 4
nfm = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.5}}
WRB = poly({{650,365},{770,358},{805,420},{815,540},{855,560},{862,620},{805,700},{765,722},{742,650},{700,640},{605,700},{535,748},{508,728},{595,640},{628,590},{622,450}}, true) + ellipse(708,342,30,36)
NFB = poly({{450,362},{520,378},{565,410},{662,452},{672,488},{565,455},{505,445},{475,520},{505,585},{522,660},{505,712},{452,712},{462,640},{412,622},{342,700},{290,718},{288,694},{358,620},{382,540},{396,440},{418,380}}, true) + ellipse(488,340,30,34)
work(WRB, {hand="body", pile=wreckm, coverage=3, fill=true, clip=true})
work(NFB, {hand="body", pile=nfm, coverage=3, fill=true, clip=true})

--@ chunk 5
wait(24*60)
crim = pile{{"cadmium red",1},{"rose madder",1},{"Mars red",0.5}}
crimd = pile{{"Mars red",1},{"rose madder",1},{"bone black",0.4}}
local tw = poly({{662,418},{768,412},{786,600},{738,618},{690,602},{650,600}}, true):roughen(4,30,3)
local tn = poly({{428,398},{492,420},{482,560},{402,560},{404,450}}, true):roughen(4,30,4)
work(tw, {hand="body", pile=crim, coverage=3, fill=true, clip=true, angle=1.5})
work(tn, {hand="body", pile=crimd, coverage=3, fill=true, clip=true, angle=1.4})

--@ chunk 6
wait(2*24*60)
crimdd = pile{{"Mars red",1},{"bone black",1},{"rose madder",0.5}}
gash = pile{{"bone black",2},{"burnt sienna",1}}
local tw = poly({{662,418},{768,412},{786,600},{738,618},{690,602},{650,600}}, true):grow(3)
local tn = poly({{428,398},{492,420},{482,560},{402,560},{404,450}}, true):grow(3)
local lit = ellipse(690,465,55,65):soften(25)
work(tn, {hand="body", pile=crimdd, coverage=3.5, fill=true, clip=true, angle=1.4})
work(tw - lit, {hand="body", pile=crimd, coverage=3, fill=true, clip=true, angle=1.5})
local g = poly({{688,430},{722,425},{752,448},{745,470},{758,492},{730,505},{705,498},{682,476},{694,455}}):roughen(5,15,9)
work(g, {hand="detail", pile=gash, coverage=4, fill=true, clip=true})

--@ chunk 7
wait(3*24*60)
flrd = pile{{"burnt sienna",1},{"ultramarine blue",1.2},{"bone black",0.6}}
far2 = pile{{"ultramarine ash",1},{"bone black",0.8},{"cerulean blue",0.2},{"zinc white",0.15}}
local fl = poly({{0,800},{340,460},{430,460},{1000,690},{1000,800}})
local pool = ellipse(600,640,280,110):soften(60)
local figs = WRB:grow(4) + NFB:grow(4)
work((fl - pool) - figs, {hand="broad", pile=flrd, coverage=2.5, fill=true, clip=true, angle=0.1})
work(rect(340,330,90,130), {hand="body", pile=far2, coverage=3, fill=true, clip=true, angle=1.57})

--@ chunk 8
local ov = NFB * rect(330,300,115,180)
local tn = poly({{428,398},{492,420},{482,560},{402,560},{404,450}}, true):grow(3)
work(ov - tn, {hand="body", pile=nfm, coverage=3.5, fill=true, clip=true})
work(ov * tn, {hand="body", pile=crimdd, coverage=3.5, fill=true, clip=true, angle=1.4})
wait(2*24*60)
lamp = pile{{"lead white",2},{"Mars orange",1},{"cadmium yellow",0.3}, medium=0.3}
local glow = ellipse(660,480,140,120):soften(70)
work(glow, {hand="glaze", pile=lamp, load=0.25, pressure={0.1,0.25}, coverage=1.5, clip=true})
local pool = ellipse(600,650,240,80):soften(60) - (WRB + NFB)
work(pool, {hand="glaze", pile=lamp, load=0.2, pressure={0.1,0.2}, coverage=1.2, clip=true, angle=0})

--@ chunk 9
blend(ellipse(660,480,150,130), {angle=0.3})
blend(ellipse(600,650,250,90) - (WRB+NFB), {angle=0})

--@ chunk 10
wait(2*24*60)
local tw = poly({{662,418},{768,412},{786,600},{738,618},{690,602},{650,600}}, true):roughen(3,30,3)
local g = poly({{688,430},{722,425},{752,448},{745,470},{758,492},{730,505},{705,498},{682,476},{694,455}}):roughen(5,15,9)
local zone = rect(420,260,300,380)
work((WRB*zone) - tw, {hand="body", pile=wreckm, coverage=3.5, fill=true, clip=true})
work(NFB*rect(440,330,240,180), {hand="body", pile=nfm, coverage=3.5, fill=true, clip=true, angle=0.35})
work(tw - ellipse(690,465,50,55), {hand="body", pile=crimd, coverage=3.5, fill=true, clip=true, angle=1.5})
work(tw * ellipse(690,465,50,55), {hand="body", pile=crim, coverage=3.5, fill=true, clip=true, angle=1.5})
work(g, {hand="detail", pile=gash, coverage=4, fill=true, clip=true})

--@ chunk 11
local tn = poly({{428,398},{492,420},{482,560},{402,560},{404,450}}, true):roughen(3,30,4)
local legs = NFB * rect(280,540,260,190)
work(tn, {hand="body", pile=crimdd, coverage=3.5, fill=true, clip=true, angle=1.4})
work((NFB - tn) * rect(330,280,200,290), {hand="body", pile=nfm, coverage=3.5, fill=true, clip=true, angle=1.2})
work(legs - tn, {hand="body", pile=nfm, coverage=3.5, fill=true, clip=true, angle=0.6})
work(WRB * rect(500,580,380,180), {hand="body", pile=wreckm, coverage=3.5, fill=true, clip=true, angle=0.5})

--@ chunk 12
local tw = poly({{662,418},{768,412},{786,600},{738,618},{690,602},{650,600}}, true):roughen(3,30,3)
work(WRB*rect(715,300,170,300) - tw, {hand="body", pile=wreckm, coverage=3.5, fill=true, clip=true})
work(tw*rect(640,570,160,60), {hand="body", pile=crimd, coverage=3.5, fill=true, clip=true, angle=1.5})
wait(4*24*60)
bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
hot = pile{{"zinc white",3},{"lemon chrome",0.3}}
rim = pile{{"lead white",2},{"Mars orange",1},{"cadmium yellow",0.5}}
cool = pile{{"zinc white",1},{"ultramarine ash",1},{"cerulean blue",0.3}}
local fb = brush("flat", 6)
fb:load(bone, 0.9)
fb:stroke({{722,500},{724,545},{725,590}}, {pressure={0.8,0.7}})
fb:load(bone, 0.9)
fb:stroke({{700,522},{725,520},{750,521}}, {pressure={0.8,0.7}})
local r = brush{kind="round", width=3, point=1}
r:load(rim, 0.8)
r:stroke({{560,428},{610,445},{650,460},{668,470}}, {pressure={0.5,0.3}})
r:load(rim, 0.8)
r:stroke({{684,432},{700,425},{724,428}}, {pressure={0.6,0.3}})
r:load(rim, 0.8)
r:stroke({{680,470},{690,492},{708,500}}, {pressure={0.5,0.2}})
r:load(rim, 0.8)
r:stroke({{655,372},{675,362},{690,355}}, {pressure={0.6,0.2}})
r:load(cool, 0.8)
r:stroke({{442,318},{448,345},{430,375},{404,420},{396,470}}, {pressure={0.4,0.15}})
work(ellipse(510,333,7,6), {hand="detail", pile=hot, coverage=5, fill=true, clip=true})

--@ chunk 13
brass = pile{{"yellow ochre",2},{"cadmium yellow",1},{"lead white",1}}
local r = brush{kind="round", width=3, point=0.6}
local pts = {{560,612,0.3},{585,625,1.2},{612,618,0.6},{540,640,2.0},{630,640,0.9},{575,655,0.2}}
for _,p in ipairs(pts) do
  r:load(brass, 0.8)
  r:stroke({{p[1],p[2]},{p[1]+9*math.cos(p[3]),p[2]+9*math.sin(p[3])}}, {pressure={0.7,0.6}})
end
r:load(rim, 0.8)
r:stroke({{690,312},{708,308},{726,318}}, {pressure={0.5,0.15}})

--@ chunk 14
local old = ellipse(708,340,36,42) * rect(660,290,100,62)
work(old, {hand="body", pile=wall, coverage=4, fill=true, clip=true, angle=-0.5})
local head = ellipse(684,372,30,26):roughen(2,20,5)
work(head, {hand="body", pile=wreckm, coverage=4, fill=true, clip=true})
local hand = poly({{648,452},{668,446},{684,456},{690,474},{676,486},{656,480}}, true)
work(hand, {hand="detail", pile=nfm, coverage=4, fill=true, clip=true})

--@ chunk 15
wait(5*24*60)
local r = brush{kind="round", width=3, point=1}
local function rs(p, pts, pr) r:load(p, 0.8); r:stroke(pts, {pressure=pr or {0.55,0.15}}) end
rs(rim, {{657,378},{664,358},{682,347},{702,350}}, {0.3,0.6})
rs(rim, {{664,380},{684,383},{700,378}}, {0.35,0.15})
rs(rim, {{632,396},{626,440},{622,500},{620,560}}, {0.5,0.1})
rs(rim, {{648,456},{664,448},{682,454}}, {0.6,0.2})
rs(rim, {{660,476},{676,481},{688,474}}, {0.35,0.1})
rs(rim, {{470,310},{492,302},{512,310}}, {0.4,0.1})
rs(rim, {{618,600},{580,640},{540,680},{510,712}}, {0.4,0.1})
rs(rim, {{752,402},{786,416},{805,440}}, {0.3,0.05})

--@ chunk 16
local nh = ellipse(505,354,29,26):roughen(2,20,6)
local oldh = ellipse(488,340,34,38) - nh - NFB:shrink(30)
local ab = below(function(x) return 330 - (x-430)*330/570 end)
work(oldh*ab*rect(440,290,100,60), {hand="detail", pile=wall, coverage=5, fill=true, clip=true})
work(oldh - ab, {hand="detail", pile=dk, coverage=5, fill=true, clip=true})
work(nh, {hand="body", pile=nfm, coverage=4, fill=true, clip=true})

--@ chunk 17
local nh = ellipse(505,354,29,26)
local ab = below(function(x) return 330 - (x-430)*330/570 end)
local zone = (ellipse(488,340,36,40) + ribbon({{466,312},{492,301},{516,312}}, 9)) - nh:grow(1) - rect(380,352,200,100)
work(zone*ab, {hand="detail", pile=wall, coverage=5, fill=true, clip=true})
work(zone-ab, {hand="detail", pile=dk, coverage=5, fill=true, clip=true})
work(ribbon({{445,316},{449,340},{437,362}}, 8)*rect(430,300,30,60) - nh, {hand="detail", pile=far2, coverage=5, fill=true, clip=true})

--@ chunk 18
local nh = ellipse(505,354,29,26)
local ab = below(function(x) return 330 - (x-430)*330/570 end)
local R = rect(430,295,40,57) - nh:grow(1)
work(R*ab, {hand="detail", pile=wall, coverage=6, fill=true, clip=true})
work(R-ab, {hand="detail", pile=dk, coverage=6, fill=true, clip=true})

--@ chunk 19
wait(4*24*60)
beam = pile{{"lead white",2},{"Mars orange",0.6},{"zinc white",1}, medium=0.4}
local bm = ribbon({{532,356},{600,410},{680,468}}, {4,30,60}):soften(6)
work(bm, {hand="glaze", pile=beam, load=0.15, pressure={0.08,0.15}, coverage=2, clip=true, angle=0.65})
blend(bm, {angle=0.65})
work(ellipse(531,356,6,5), {hand="detail", pile=hot, coverage=6, fill=true, clip=true})

--@ chunk 20
local fr = (rect(338,326,20,138) + rect(338,326,94,18)) - NFB:grow(2)
work(fr, {hand="detail", pile=dk, coverage=6, fill=true, clip=true})
local arm = ribbon({{790,420},{812,500},{826,570},{840,630}}, {26,24,22,20}) - WRB:shrink(2)*rect(600,300,200,200)
work(arm, {hand="body", pile=wreckm, coverage=4, fill=true, clip=true, angle=1.3})
local r = brush{kind="round", width=2, point=1}
local function rs(p, pts, pr) r:load(p, 0.8); r:stroke(pts, {pressure=pr or {0.5,0.1}}) end
rs(rim, {{702,440},{716,452},{728,447}})
rs(rim, {{712,472},{730,468},{742,480}})
rs(bone, {{700,458},{722,462},{738,458}}, {0.6,0.3})
rs(bone, {{704,484},{724,488},{740,484}}, {0.6,0.3})
rs(brass, {{720,430},{724,500}}, {0.3,0.05})

--@ chunk 21
wait(3*24*60)
plate = pile{{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.6},{"raw sienna",0.3}}
plateL = pile{{"burnt sienna",1},{"bone black",0.6},{"yellow ochre",0.5},{"Mars orange",0.2}}
seam = pile{{"bone black",2},{"ultramarine blue",0.5}}
local function P(pts, p, h) work(poly(pts, true), {hand=h or "detail", pile=p, coverage=4, fill=true, clip=true}) end
-- WRECK: helm tipped forward onto chest
P({{656,372},{664,350},{684,342},{706,348},{716,366},{712,392},{690,402},{664,396}}, plate)
P({{662,380},{690,386},{712,378},{708,396},{688,404},{666,396}}, seam)
-- wreck pauldrons, buckled
P({{632,372},{660,362},{684,372},{676,398},{650,410},{630,402}}, plateL)
P({{752,368},{782,366},{806,384},{806,414},{786,420},{760,400}}, plate)
-- wreck fallen right arm: rerebrace, couter, vambrace, gauntlet on deck
P({{798,420},{822,430},{826,494},{806,500}}, plate)
P({{804,500},{830,494},{838,520},{816,530}}, plateL)
P({{816,532},{840,526},{852,600},{830,606}}, plate)
P({{826,606},{856,600},{870,630},{858,648},{832,646}}, plate)
-- wreck legs: knee cops and greaves
P({{620,630},{650,622},{664,646},{646,664},{620,658}}, plateL)
P({{560,690},{610,665},{620,682},{570,712}}, plate)
P({{828,560},{858,556},{868,590},{846,604},{826,592}}, plateL)
P({{790,640},{820,615},{834,660},{800,700}}, plate)
-- KNEELING FRAME: bowed helm with visor
P({{478,340},{492,326},{514,326},{532,340},{538,362},{526,378},{500,380},{482,368}}, plate)
P({{512,348},{534,350},{538,364},{520,370}}, seam)
-- near pauldron
P({{440,372},{470,362},{500,370},{508,392},{484,410},{450,408},{436,392}}, plateL)
-- segmented reaching arm
P({{500,392},{548,410},{544,430},{496,418}}, plate)
P({{546,408},{568,414},{570,436},{548,436}}, plateL)
P({{570,418},{640,446},{636,466},{566,438}}, plate)
-- bent knee: thigh, knee cop, greave
P({{440,530},{510,560},{518,590},{450,580}}, plate)
P({{506,566},{532,572},{538,600},{516,610},{500,596}}, plateL)
P({{504,606},{526,606},{524,680},{504,700},{494,660}}, plate)
P({{480,692},{526,688},{534,712},{476,714}}, plate)
-- back leg kneeling on deck
P({{340,640},{372,628},{386,656},{360,680},{336,672}}, plate)

--@ chunk 22
wait(2*24*60)
local function P(pts, p) work(poly(pts):grow(2), {hand="detail", pile=p, coverage=5, fill=true, clip=true}) end
plateM = pile{{"bone black",1},{"burnt sienna",0.8},{"raw sienna",0.3},{"ultramarine blue",0.3}}
P({{804,500},{830,494},{838,520},{816,530}}, plate)
P({{828,560},{858,556},{868,590},{846,604},{826,592}}, plate)
P({{440,372},{470,362},{500,370},{508,392},{484,410},{450,408},{436,392}}, plate)
P({{632,372},{660,362},{684,372},{676,398},{650,410},{630,402}}, plateM)
P({{506,566},{532,572},{538,600},{516,610},{500,596}}, plateM)
P({{546,408},{568,414},{570,436},{548,436}}, plateM)
P({{620,630},{650,622},{664,646},{646,664},{620,658}}, plateM)

--@ chunk 23
wait(4*24*60)
local r = brush{kind="round", width=2.4, point=1}
local function rs(p, pts, pr) r:load(p, 0.8); r:stroke(pts, {pressure=pr or {0.5,0.1}}) end
-- wreck: warm rims on lamp-facing (upper-left) plate edges
rs(rim, {{658,370},{668,350},{688,343},{706,348}}, {0.3,0.6})
rs(rim, {{634,374},{660,363},{682,372}}, {0.6,0.2})
rs(rim, {{620,632},{650,622},{662,642}}, {0.5,0.1})
rs(rim, {{562,690},{610,666}}, {0.4,0.1})
rs(rim, {{806,502},{830,495}}, {0.3,0.05})
rs(rim, {{828,608},{856,601}}, {0.3,0.05})
rs(rim, {{666,382},{690,388},{710,380}}, {0.25,0.05})
-- seams of buckled plates
rs(seam, {{634,390},{660,384},{678,392}}, {0.5,0.3})
rs(seam, {{756,380},{780,392},{800,396}}, {0.5,0.3})
-- kneeling frame: light from the pool below and lamp on his forearm top
rs(rim, {{572,418},{606,431},{640,446}}, {0.5,0.2})
rs(rim, {{500,393},{546,409}}, {0.3,0.05})
rs(rim, {{508,568},{530,572},{537,596}}, {0.6,0.2})
rs(rim, {{442,532},{508,561}}, {0.35,0.05})
rs(rim, {{496,700},{526,690}}, {0.3,0.05})
rs(rim, {{516,330},{532,341},{538,360}}, {0.4,0.1})
rs(cool, {{442,374},{468,363},{496,369}}, {0.35,0.05})
rs(cool, {{484,340},{494,327},{512,325}}, {0.3,0.05})

--@ chunk 24
local r = brush{kind="round", width=2, point=1}
local function rs(p, pts, pr) r:load(p, 0.8); r:stroke(pts, {pressure=pr or {0.5,0.15}}) end
-- lames on pauldrons
rs(seam, {{442,392},{470,384},{504,388}})
rs(seam, {{446,402},{474,396},{500,400}})
rs(rim, {{636,388},{658,380},{678,386}}, {0.4,0.1})
rs(seam, {{634,398},{656,392},{674,398}})
-- segmented limbs
rs(seam, {{470,546},{476,566}}); rs(seam, {{490,554},{494,576}})
rs(seam, {{506,640},{524,636}}); rs(seam, {{502,664},{522,660}})
rs(seam, {{596,428},{592,444}}); rs(seam, {{616,436},{612,452}})
rs(seam, {{812,450},{824,452}}); rs(seam, {{832,560},{848,556}})
rs(seam, {{580,690},{592,708}}); rs(seam, {{598,680},{608,696}})
-- buckled tabard/breastplate: dents and torn edges catching lamp
rs(crimdd, {{668,520},{690,540},{700,575}}, {0.6,0.3})
rs(crimdd, {{752,430},{770,470},{764,520}}, {0.6,0.3})
rs(rim, {{680,428},{694,424},{708,430}}, {0.5,0.1})
rs(rim, {{664,452},{672,476},{668,500}}, {0.35,0.05})
