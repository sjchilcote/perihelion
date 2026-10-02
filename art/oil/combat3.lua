-- easel session "combat3": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=31,
  ground={{pile={{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1},{"lead white",2}}, um=80, apply="knife", texture=0.3}}}
local c = chalk()
local function L(p) c:line(p, {pressure={0.5,0.7,0.5}}) end
-- head (turned right)
L({{305,85},{318,70},{340,68},{358,80},{362,100},{355,122},{335,132},{312,126},{302,108},{305,85}})
L({{340,98},{362,96}})               -- visor slit
-- torso, shoulders twisted toward threat
L({{268,148},{300,138},{340,140},{385,150},{392,175}})
L({{268,148},{262,190},{280,240},{298,288}})
L({{392,175},{378,230},{360,290}})
L({{298,288},{330,296},{360,290}})
L({{330,145},{328,210},{330,292}}) -- centre ridge
-- pelvis
L({{292,292},{285,320},{318,335},{362,318},{360,292}})
-- planted leg behind (left)
L({{292,320},{255,370},{232,410},{205,470},{175,520},{150,540},{185,546},{205,530}})
L({{318,335},{280,385},{258,420},{235,470},{215,520},{205,530}})
-- lifting leg (toward threat)
L({{340,325},{378,365},{410,400},{418,420}})
L({{362,318},{405,350},{432,385},{430,415}})
L({{418,420},{400,460},{385,490},{395,512},{410,505},{412,480},{430,415}})
-- cannon braced at hip
L({{300,275},{360,262},{430,252},{520,238},{535,240},{537,262},{520,266},{430,280},{360,295},{305,302},{300,275}})
-- near arm
L({{385,155},{405,190},{408,240},{420,262}})
L({{368,170},{385,205},{388,248},{405,268}})
-- far arm
L({{270,155},{262,200},{290,250},{330,270}})
-- cable whip
L({{535,250},{575,228},{602,175},{648,142},{700,160},{722,200},{740,212}})
-- warden
L({{720,560},{735,430},{760,330},{745,250},{770,160},{820,100},{880,80},{940,110},{975,190},{990,300},{970,440},{960,560}})
-- flankers
L({{600,520},{595,430},{610,380},{640,370},{660,400},{665,520}})
L({{960,450},{940,380},{980,340},{1000,340}})

--@ chunk 2
P = {}
P.head = ellipse(333,100,31,34)
P.neck = poly({{315,122},{352,122},{355,146},{310,146}})
P.torso = poly({{262,142},{300,132},{345,134},{395,148},{402,178},{386,236},{364,292},{296,294},{278,240},{258,190}}, true)
P.npaul = ellipse(394,168,30,27)
P.fpaul = ellipse(270,158,24,22)
P.pelvis = poly({{288,286},{366,284},{372,318},{332,344},{284,326}}, true)
P.bthigh = poly({{284,312},{328,330},{292,396},{264,428},{234,410},{254,364}}, true)
P.bshin = poly({{236,404},{266,424},{234,482},{214,530},{186,528},{204,470}}, true)
P.bfoot = poly({{184,518},{216,520},{224,542},{142,550},{148,534}})
P.fthigh = poly({{332,318},{370,304},{414,348},{444,394},{420,428},{394,408},{358,366}}, true)
P.fshin = poly({{410,410},{442,402},{430,452},{412,496},{388,494},{400,450}}, true)
P.ffoot = poly({{384,484},{416,486},{424,514},{394,520}})
P.uarm = poly({{378,158},{410,172},{414,236},{390,242}}, true)
P.farm = poly({{390,232},{414,226},{434,262},{410,272}}, true)
P.barm = poly({{276,186},{262,214},{298,262},{332,270},{338,250},{302,232}}, true)
P.cannon = poly({{294,272},{430,250},{518,234},{540,236},{542,266},{520,270},{430,284},{300,308}})
CMD = P.head
for k,m in pairs(P) do CMD = CMD + m end
blackp = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
work(-CMD, {hand="broad", pile=blackp, coverage=2.2, fill=true})

--@ chunk 3
SRC = {650,175}
armB = pile{{"bone black",2},{"ultramarine blue",1},{"zinc white",0.3}}
armH = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",1}}
armL = pile{{"zinc white",3},{"cerulean blue",0.5},{"ultramarine ash",0.5}}
INFO = {
 {"barm",300,240,0.8},{"fpaul",270,158,0.3},{"bthigh",275,370,2.09},{"bshin",225,465,1.99},{"bfoot",180,535,0.05},
 {"torso",328,215,1.6},{"pelvis",328,312,0.0},{"neck",333,134,1.57},{"head",333,100,1.57},
 {"fthigh",390,365,0.91},{"fshin",418,452,1.86},{"ffoot",404,502,1.3},{"cannon",420,270,-0.15},
 {"uarm",398,200,1.55},{"npaul",394,168,0.3},{"farm",412,250,1.1}}
function hp(cx,cy,k,r)
  local dx,dy = SRC[1]-cx, SRC[2]-cy; local n = math.sqrt(dx*dx+dy*dy); dx,dy = dx/n, dy/n
  return mask(function(x,y) local d = ((x-cx)*dx+(y-cy)*dy)/r; return smoothstep(k-0.15,k+0.15,d) end)
end
function model(name,cx,cy,ang)
  local m = P[name]; local r = math.sqrt(m:area()/math.pi)
  local function a(x,y) return ang + 0.25*math.sin(x*0.07+y*0.05) end
  work(m, {hand="body", tool="filbert 5", pile=armB, angle=a, coverage=3, fill=true, clip=true, length={10,30}})
  work(m*hp(cx,cy,-0.1,r), {hand="body", tool="filbert 4", pile=armH, angle=a, coverage=1.8, clip=m, length={8,22}})
  work(m*hp(cx,cy,0.45,r), {hand="body", tool="filbert 3", pile=armL, angle=a, coverage=1.4, clip=m, length={6,16}, pressure={0.4,0.8}})
end
for _,t in ipairs(INFO) do model(t[1],t[2],t[3],t[4]) end

--@ chunk 4
for _,t in ipairs(INFO) do
  blend(P[t[1]]:shrink(1.5), {angle=t[4], clip=true})
end
print(wait(2*24*60))

--@ chunk 5
P.helm = poly({{306,80},{320,66},{346,64},{363,76},{370,98},{367,116},{353,128},{328,131},{310,123},{301,102}}, true)
P.pack = poly({{266,146},{246,160},{238,200},{242,236},{262,252},{280,240},{276,180}}, true)
local bg = (P.head + P.neck) - P.helm - P.neck:shrink(3)
work(bg:grow(1), {hand="body", tool="filbert 4", pile=blackp, coverage=3, fill=true, clip=true})
PL = {
 helm = poly({{344,68},{360,78},{368,100},{365,116},{351,127},{354,100}}, true),
 chest = poly({{336,142},{384,150},{396,178},{382,232},{364,262},{348,250},{342,200}}, true),
 npaul = poly({{378,147},{404,144},{422,163},{421,186},{409,175},{392,160}}, true),
 uarm = poly({{402,174},{414,182},{414,234},{404,238}}),
 farm = poly({{400,232},{414,227},{434,260},{425,263}}),
 cannon = poly({{330,268},{430,250},{518,235},{541,237},{541,245},{520,245},{430,259},{330,277}}),
 muzzle = poly({{534,237},{542,237},{542,266},{534,268}}),
 pelvis = poly({{346,288},{366,286},{372,318},{352,332}}, true),
 fthigh = poly({{368,306},{414,347},{444,393},{432,410},{400,366},{362,320}}, true),
 fknee = ellipse(432,408,13,14),
 fshin = poly({{430,412},{442,404},{430,452},{414,496},{404,494},{420,450}}, true),
 ffoot = poly({{405,486},{416,487},{424,513},{412,516}}),
 bthigh = poly({{318,328},{329,332},{292,397},{266,428},{258,420},{286,388}}, true),
 bshin = poly({{258,422},{267,424},{235,482},{215,530},{207,528},{226,478}}, true),
 bfoot = poly({{150,534},{185,519},{216,520},{220,528},{186,528},{152,540}}),
}
PLM = PL.helm
for k,m in pairs(PL) do PLM = PLM + m end
local order = {{"pack",1.6},{"barm",0.8},{"fpaul",0.3},{"bthigh",2.09},{"bshin",1.99},{"bfoot",0.05},
 {"torso",1.6},{"pelvis",0.0},{"neck",1.57},{"helm",1.2},
 {"fthigh",0.91},{"fshin",1.86},{"ffoot",1.3},{"cannon",-0.15},{"uarm",1.55},{"npaul",0.3},{"farm",1.1}}
local core = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
for _,t in ipairs(order) do
  local m = P[t[1]] - PLM
  local a = t[2]
  work(m, {hand="body", tool="filbert 4", pile=armB, angle=function(x,y) return a + 0.3*math.sin(x*0.09+y*0.06) end,
     coverage=3, fill=true, clip=true, length={8,24}})
end
CMD = CMD + P.pack + P.helm

--@ chunk 6
local pmap = {helm="helm",chest="torso",npaul="npaul",uarm="uarm",farm="farm",cannon="cannon",muzzle="cannon",pelvis="pelvis",
  fthigh="fthigh",fknee="fshin",fshin="fshin",ffoot="ffoot",bthigh="bthigh",bshin="bshin",bfoot="bfoot"}
local ang = {helm=1.3,chest=1.7,npaul=0.6,uarm=1.55,farm=1.1,cannon=-0.15,muzzle=1.57,pelvis=1.3,fthigh=0.91,fknee=1.6,fshin=1.86,ffoot=1.3,bthigh=2.09,bshin=1.99,bfoot=0.0}
for k,m in pairs(PL) do
  local part = P[pmap[k]] + (k=="fknee" and P.fthigh or P[pmap[k]])
  local band = (m:grow(7) - m:shrink(3)) * part
  local a = ang[k]
  work(band, {hand="body", tool={kind="filbert", width=3, point=0.5}, pile=armH, angle=function(x,y) return a + 0.2*math.sin(x*0.1+y*0.07) end,
     coverage=1.6, clip=part, length={6,18}, pressure={0.25,0.6}, ramps={0.3,0.5}, load=0.6})
end

--@ chunk 7
WB = poly({{742,562},{750,450},{768,360},{758,290},{772,222},{800,150},{850,96},{910,78},{962,108},{992,180},{1000,260},{1000,562}}, true)
WH = poly({{752,150},{795,128},{822,150},{818,195},{790,212},{758,198},{748,175}}, true)
WA = poly({{805,236},{770,252},{735,282},{700,305},{684,322},{692,334},{712,330},{745,312},{785,292},{815,282}}, true)
WC = poly({{688,318},{668,312},{660,322},{676,326},{662,336},{680,340},{672,350},{694,342},{702,330}})
WAR = WB + WH + WA + WC
H1 = poly({{580,530},{586,470},{578,430},{590,400},{604,380},{628,376},{648,392},{652,430},{646,470},{650,530},{632,530},{626,480},{610,480},{602,530}}, true)
H1h = ellipse(612,372,14,13)
H2 = poly({{668,505},{672,460},{666,430},{680,412},{700,410},{712,428},{708,470},{712,505},{700,505},{694,470},{684,470},{680,505}}, true)
H2h = ellipse(686,404,10,9)
wdark = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",1}}
hdark = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",1}}
work(WAR, {hand="body", pile=wdark, coverage=2.6, fill=true, clip=true, angle=function(x,y) return 1.3+0.6*math.sin(x*0.02+y*0.015) end, length={20,50}})
work(H2+H2h, {hand="body", tool="filbert 4", pile=hdark, coverage=3, fill=true, clip=true, angle=1.6, length={8,20}})
work(H1+H1h, {hand="body", tool="filbert 5", pile=hdark, coverage=3, fill=true, clip=true, angle=1.6, length={8,24}})

--@ chunk 8
print(wait(2*24*60))
CORE = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local list = {{"pack",255,200,1.6},{"fpaul",270,158,0.3},{"torso",320,215,1.6},{"pelvis",328,312,0.2},{"helm",333,98,1.3},
 {"bthigh",275,370,2.09},{"bshin",225,465,1.99},{"fthigh",390,365,0.91},{"fshin",418,452,1.86},{"uarm",398,200,1.55},{"npaul",394,168,0.4},{"cannon",420,275,-0.15}}
for _,t in ipairs(list) do
  local m = P[t[1]]; local r = math.sqrt(m:area()/math.pi)
  local a = t[4]
  local sh = m * (-hp(t[2],t[3],-0.25,r))
  work(sh, {hand="body", tool={kind="filbert",width=4,point=0.4}, pile=CORE, angle=function(x,y) return a+0.25*math.sin(x*0.08+y*0.05) end,
     coverage=2.2, clip=m, length={8,22}, pressure={0.4,0.8}, ramps={0.2,0.4}, edge="soft"})
end

--@ chunk 9
function centroid(m)
  local sx,sy,n = 0,0,0
  for x=100,1000,3 do for y=0,562,3 do local v=m:at(x,y); if v>0.5 then sx=sx+x; sy=sy+y; n=n+1 end end end
  return sx/n, sy/n, math.sqrt(n*9/math.pi)
end
local pmap = {helm="helm",chest="torso",npaul="npaul",uarm="uarm",farm="farm",cannon="cannon",muzzle="cannon",pelvis="pelvis",
  fthigh="fthigh",fknee="fshin",fshin="fshin",ffoot="ffoot",bthigh="bthigh",bshin="bshin",bfoot="bfoot"}
ANG = {helm=1.3,chest=1.7,npaul=0.6,uarm=1.55,farm=1.1,cannon=-0.15,muzzle=1.57,pelvis=1.3,fthigh=0.91,fknee=1.6,fshin=1.86,ffoot=1.3,bthigh=2.09,bshin=1.99,bfoot=0.0,
  pack=1.6,barm=0.8,fpaul=0.3,torso=1.6,neck=1.57}
local order = {"pack","barm","fpaul","bthigh","bshin","bfoot","torso","pelvis","neck","helm","fthigh","fshin","ffoot","cannon","uarm","npaul","farm"}
local PLg = PLM:grow(1.5)
for _,k in ipairs(order) do
  local a = ANG[k]
  work(P[k] - PLg, {hand="body", tool="filbert 4", pile=armB, angle=function(x,y) return a+0.25*math.sin(x*0.08+y*0.05) end,
     coverage=3, fill=true, clip=true, length={8,24}})
end
PC = {}
for k,m in pairs(PL) do
  local cx,cy,r = centroid(m); PC[k] = {cx,cy,r}
  local a = ANG[k]
  local part = P[pmap[k]] + (k=="fknee" and P.fthigh or P[pmap[k]])
  work(m, {hand="body", tool="filbert 3", pile=armH, angle=function(x,y) return a+0.2*math.sin(x*0.1+y*0.07) end, coverage=3, fill=true, clip=part, length={6,18}})
  work(m*hp(cx,cy,0.1,r), {hand="body", tool={kind="filbert",width=2.5,point=0.4}, pile=armL, angle=function(x,y) return a+0.2*math.sin(x*0.1+y*0.07) end,
     coverage=2, clip=m, length={5,14}, pressure={0.4,0.9}, ramps={0.25,0.45}})
end

--@ chunk 10
print(wait(3*24*60))
wlit = pile{{"yellow ochre",2},{"zinc white",2},{"cerulean blue",0.3}}
whalf = pile{{"raw sienna",2},{"burnt sienna",1},{"zinc white",1}}
wdeep = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",1}}
WF = {
 {poly({{752,152},{790,132},{797,150},{772,176},{752,180}}), wlit, 1.0},
 {poly({{752,183},{772,178},{792,204},{764,202}}), whalf, 0.6},
 {poly({{800,152},{846,98},{866,104},{830,165},{812,232},{792,234}}), wlit, 2.2},
 {poly({{806,234},{770,250},{735,280},{698,303},{703,312},{740,294},{776,266},{812,250}}), wlit, 2.7},
 {poly({{772,292},{792,300},{786,360},{776,452},{760,452},{768,360},{761,296}}), wlit, 1.65},
 {poly({{750,456},{772,456},{770,562},{744,562}}), whalf, 1.6},
 {poly({{812,252},{862,246},{872,330},{822,342},{792,302}}), whalf, 1.4},
 {poly({{790,345},{825,345},{818,450},{782,455}}), whalf, 1.6},
}
-- deepen the far side first
local far = WAR - poly({{740,100},{880,60},{880,250},{830,350},{830,562},{700,562},{680,300}})
work(far, {hand="body", pile=wdeep, coverage=2.5, fill=true, clip=WAR, angle=1.4, length={20,50}})
for _,f in ipairs(WF) do
  work(f[1], {hand="body", tool="filbert 4", pile=f[2], angle=f[3], coverage=2.6, fill=true, clip=WAR, length={8,26}, edge="firm"})
end

--@ chunk 11
print(wait(2*24*60))
local wmid = pile{{"bone brown",2},{"burnt sienna",1.5},{"bone black",0.6}}
-- repaint Warden: deep far side, dark warm bronze toward near side
local near = poly({{740,100},{860,70},{880,250},{840,350},{830,562},{700,562},{680,300}})
work(WAR - near, {hand="body", pile=wdeep, coverage=3, fill=true, clip=WAR, angle=1.4, length={20,50}})
work(WAR * near, {hand="body", tool="filbert 6", pile=wmid, coverage=3, fill=true, clip=WAR, angle=function(x,y) return 1.5+0.5*math.sin(y*0.03) end, length={14,40}})

--@ chunk 12
print(drying(370,300), drying(420,380), drying(300,250))
rig = brush{kind="rigger", width=2.2, point=1}
rnd = brush{kind="round", width=4, point=0.7}
seam = pile{{"bone black",2},{"ultramarine blue",1}}
hot = pile{{"zinc white",4},{"lemon chrome",0.12}}
function ln(b, pts, p, pr, load)
  b:reload(p, load or 0.7)
  b:stroke(pts, {pressure=pr or {0.5,0.3}, ramps={0.15,0.35}})
end
-- helmet: sallet tail, gorget, visor
local tail = poly({{312,96},{292,112},{286,124},{302,124},{318,116}}, true)
work(tail, {hand="body", tool="filbert 3", pile=armB, coverage=3, fill=true, clip=true, angle=2.4, length={6,14}})
ln(rnd, {{344,99},{356,97},{370,96}}, seam, {0.7,0.5})
ln(rig, {{346,104},{358,103},{368,102}}, armL, {0.5,0.2})
ln(rnd, {{314,128},{333,132},{352,131}}, seam, {0.8,0.6})
ln(rig, {{318,67},{334,63},{350,66},{362,76}}, armH, {0.3,0.2}, 0.4)
-- breastplate ridge and waist break, lames
ln(rig, {{352,146},{356,180},{356,215},{352,250}}, armL, {0.6,0.3})
ln(rnd, {{348,148},{350,190},{348,248}}, seam, {0.4,0.3}, 0.5)
ln(rnd, {{290,256},{330,258},{372,252},{386,240}}, seam, {0.9,0.6})
ln(rnd, {{294,272},{330,274},{368,268}}, seam, {0.8,0.6})
ln(rig, {{340,261},{360,259},{374,254}}, armL, {0.5,0.2})
ln(rig, {{344,277},{358,275},{368,272}}, armH, {0.5,0.2})
-- near pauldron lames
ln(rnd, {{372,170},{390,162},{410,170},{420,186}}, seam, {0.7,0.5})
ln(rig, {{378,176},{394,169},{410,176}}, armL, {0.4,0.2})
ln(rnd, {{376,186},{396,182},{414,196}}, seam, {0.6,0.4})
-- gauntlet on the grip
local hand = poly({{405,252},{424,246},{436,258},{430,272},{410,274}}, true)
work(hand, {hand="body", tool="filbert 3", pile=armB, coverage=3, fill=true, clip=true, angle=0.3, length={5,12}})
ln(rig, {{414,250},{426,248},{434,256}}, armL, {0.6,0.3})
-- cannon housing, barrel bands, muzzle
ln(rnd, {{365,262},{368,300}}, seam, {0.8,0.8})
ln(rnd, {{455,248},{458,278}}, seam, {0.7,0.7})
ln(rnd, {{490,242},{492,272}}, seam, {0.7,0.7})
ln(rig, {{368,263},{440,251},{530,236}}, hot, {0.6,0.4})
ln(rig, {{539,238},{541,252},{540,265}}, hot, {0.7,0.4})
-- knee cops
ln(rnd, {{420,396},{432,394},{444,402},{444,418},{432,424},{420,418}}, seam, {0.6,0.5})
ln(rig, {{436,398},{443,406},{442,416}}, hot, {0.6,0.2})
ln(rnd, {{246,414},{258,410},{270,418},{266,432},{252,436}}, seam, {0.6,0.5})
-- greave tops, sabatons
ln(rnd, {{404,456},{430,460}}, seam, {0.6,0.5})
ln(rnd, {{206,476},{232,482}}, seam, {0.6,0.5})
ln(rnd, {{168,536},{180,530}}, seam, {0.5,0.4})
ln(rnd, {{190,532},{200,526}}, seam, {0.5,0.4})
-- rims, varying with form
ln(rig, {{358,72},{367,88},{370,100},{367,116},{356,127}}, hot, {0.3,0.8})
ln(rig, {{384,147},{404,144},{420,160},{423,182}}, hot, {0.8,0.3})
ln(rig, {{413,186},{415,210},{414,234}}, hot, {0.5,0.2})
ln(rig, {{372,306},{400,330},{420,355},{442,392}}, hot, {0.2,0.9})
ln(rig, {{442,420},{436,446},{426,470},{416,494}}, hot, {0.8,0.2})
ln(rig, {{416,488},{423,512}}, hot, {0.5,0.3})
ln(rig, {{327,333},{306,366},{290,396},{268,424}}, hot, {0.6,0.2})
ln(rig, {{266,426},{248,458},{234,484},{218,526}}, hot, {0.5,0.15})
ln(rig, {{186,520},{214,520},{222,538}}, hot, {0.4,0.5})
ln(rig, {{386,150},{396,176},{386,234},{366,288}}, armL, {0.6,0.2})

--@ chunk 13
local sd = pile{{"bone black",2},{"ultramarine blue",1.5},{"zinc white",0.12}}
local order = {"pack","barm","fpaul","bthigh","bshin","bfoot","torso","pelvis","neck","helm","fthigh","fshin","ffoot","cannon","uarm","npaul","farm"}
local keep = PLM:grow(3)
for _,k in ipairs(order) do
  local a = ANG[k]
  work(P[k] - keep, {hand="body", tool="filbert 4", pile=sd, angle=function(x,y) return a+0.25*math.sin(x*0.08+y*0.05) end,
     coverage=2.8, fill=true, clip=true, length={8,24}})
end

--@ chunk 14
print(wait(2*24*60))
CAB = {{541,251},{565,240},{585,214},{598,180},{620,150},{655,135},{690,145},{712,170},{722,195},{728,212}}
dimL = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",0.8}}
local function dl(pts, pr) ln(rig, pts, dimL, pr or {0.35,0.15}, 0.45) end
local function sl(pts, pr) ln(rnd, pts, seam, pr or {0.5,0.4}, 0.6) end
-- plates in shadow
sl({{278,152},{282,200},{280,242}}); dl({{248,162},{262,150},{276,148}})
dl({{240,200},{242,232},{258,250}}, {0.3,0.1})
sl({{268,200},{300,206},{336,204}}); dl({{270,206},{300,212},{334,210}})
sl({{272,232},{304,238},{340,236}}); dl({{276,238},{306,244},{338,242}})
dl({{252,162},{266,142},{292,138}}, {0.4,0.2})
dl({{290,262},{320,264},{345,262}})
sl({{288,302},{316,308},{344,306}}); dl({{290,307},{318,313},{344,311}})
sl({{290,320},{318,328},{340,326}})
dl({{300,124},{290,120}}, {0.4,0.2})
dl({{312,72},{306,86},{303,102}}, {0.3,0.1})
sl({{300,350},{280,380},{262,410}}, {0.4,0.3})
dl({{290,340},{272,372},{250,402}}, {0.3,0.1})
sl({{372,330},{396,360},{410,390}}, {0.4,0.3})
dl({{238,440},{224,470},{210,505}}, {0.3,0.1})
dl({{400,470},{396,490}}, {0.3,0.1})
-- the glow around the cable, kept off the figure
local glow = ribbon(CAB, {14,30,44,52,58,62,60,56,50,40}):soften(8) - CMD:grow(2)
local gp = pile{{"zinc white",3},{"cobalt violet",1},{"ultramarine blue",0.6}, medium=0.5}
work(glow, {hand="glaze", pile=gp, load=0.25, pressure={0.1,0.25}, coverage=1.6, clip=true})
blend(glow:shrink(3), {clip=true})

--@ chunk 15
local W = {10,22,34,40,44,48,46,42,38,30}
local outer = ribbon(CAB, W) - CMD:grow(2)
local W2 = {} for i,w in ipairs(W) do W2[i] = w*0.42 end
local ring = outer - ribbon(CAB, W2)
viol = pile{{"ultramarine blue",2},{"cobalt violet",2},{"magenta",0.6},{"zinc white",0.6}}
work(ring, {hand="body", tool="filbert 4", pile=viol, coverage=1.6, clip=outer, length={8,20}, angle=function(x,y) return 0.6*math.sin(x*0.04)+ (x<620 and -1.0 or (x<680 and -0.2 or 1.0)) end})
blend(outer:shrink(2), {clip=true})
-- hot core, swelling at burst nodes
local core = brush{kind="round", width=7, point=0.8}
core:load(hot, 1.0)
core:stroke({{585,214},{598,180},{620,150},{655,135},{690,145},{712,170},{722,195},{728,212}},
   {pressure={0.35,0.8}, swell={0.6,1.2,0.7,1.4,0.8,1.5,1.0}, ramps={0.1,0.2}})
core:reload(hot, 1.0)
for _,n in ipairs({{600,178,7},{640,140,10},{690,146,12},{720,190,9}}) do
  core:touch(n[1], n[2], {pressure=0.9, drag={n[3]*0.6, 0.4}, twist=0.6})
end
-- the dark cable from the muzzle, still intact
ln(rnd, {{541,251},{556,246},{568,237},{578,226},{586,213}}, seam, {0.9,0.6}, 0.9)

--@ chunk 16
print(wait(2*24*60))
print(drying(650,140))
local W = {10,22,34,40,44,48,46,42,38,30}
local outer = ribbon(CAB, W)
-- ragged edge: drag corridor dark in over the sheath's border
lose(outer - CMD:grow(3), {pile=blackp, where=1, tool="filbert 5", reach={4,14}, load=0.5, pressure={0.6,0.05}, every=1.6})
-- pinch the sheath between bursts
for _,p in ipairs({{{612,150},{622,172}},{{672,124},{676,150}}}) do
  local m = ribbon(p, 9):roughen(3,10,5)
  work(m, {hand="body", tool="filbert 3", pile=blackp, coverage=2.5, fill=true, clip=true, length={4,10}})
end

--@ chunk 17
pviol = pile{{"cobalt violet",1},{"ultramarine blue",1},{"zinc white",3}}
local fl = brush{kind="round", width=5, point=0.9}
local sm = brush{kind="round", width=3, point=1}
local function burst(cx, cy, r, n)
  for k=1,n do
    local a = rand(0, 2*math.pi); local L = r*rand(0.6,1.4)
    local x0,y0 = cx+math.cos(a)*r*0.15, cy+math.sin(a)*r*0.15
    local bend = rand(-0.4,0.4)
    fl:reload(pviol, 0.8)
    fl:stroke({{x0,y0},{cx+math.cos(a)*L*0.5, cy+math.sin(a)*L*0.5},{cx+math.cos(a+bend)*L, cy+math.sin(a+bend)*L}}, {pressure={0.9,0.0}, ramps={0.05,0.7}})
  end
  for k=1,math.floor(n*0.8) do
    local a = rand(0, 2*math.pi); local L = r*rand(0.3,0.9)
    sm:reload(hot, 0.9)
    sm:stroke({{cx,cy},{cx+math.cos(a)*L*0.5+rand(-2,2), cy+math.sin(a)*L*0.5+rand(-2,2)},{cx+math.cos(a)*L, cy+math.sin(a)*L}}, {pressure={1.0,0.0}, ramps={0.05,0.6}})
  end
  stipple(ellipse(cx,cy,r*0.35,r*0.3), {pile=hot, width=3, coverage=3})
end
for i=2,#CAB do
  local p = CAB[i]
  burst(p[1], p[2], 6 + 2.6*i, 8 + 2*i)
end
-- restate the hot core line
local core = brush{kind="round", width=5, point=0.9}
core:load(hot, 1.0)
core:stroke({{578,226},{590,205},{600,178},{622,150},{655,134},{690,145},{712,170},{722,195},{728,212}}, {pressure={0.3,0.7}, ramps={0.05,0.1}, swell={0.7,1.2,0.8,1.3,1.0}})

--@ chunk 18
-- Warden: hard light on the near side
local function band(pts, ws, p, a)
  local m = ribbon(pts, ws) * WAR
  work(m, {hand="body", tool="filbert 3", pile=p, coverage=2.4, fill=true, clip=WAR, angle=a, length={6,18}})
end
band({{760,140},{750,160},{750,180},{760,198},{785,212}}, {10,16,18,14,8}, whalf, 1.5)
band({{762,142},{752,160},{752,180},{762,196}}, {5,8,9,6}, wlit, 1.5)
band({{800,152},{825,118},{850,96},{880,84},{910,78}}, {10,14,14,10,6}, whalf, -0.7)
band({{802,150},{826,118},{850,98}}, {6,7,5}, wlit, -0.7)
band({{812,236},{780,250},{746,276},{712,298},{690,316}}, {14,16,16,14,10}, whalf, 2.6)
band({{812,236},{780,248},{746,274},{712,296},{690,314}}, {6,9,9,7,5}, wlit, 2.6)
band({{772,222},{760,260},{758,292},{768,360},{752,450},{744,562}}, {12,16,14,14,12,10}, whalf, 1.6)
band({{772,224},{761,260},{759,292},{767,355}}, {5,8,7,4}, wlit, 1.6)
-- dark eye and a few bone studs on the lit face
work(ellipse(770,172,5,4), {hand="detail", pile=wdeep, coverage=3, fill=true})
local bone = pile{{"zinc white",3},{"yellow ochre",1},{"raw sienna",0.3}}
for _,s in ipairs({{786,270},{796,262},{780,300},{790,318},{778,336},{800,300},{772,390},{776,410}}) do
  stipple(ellipse(s[1],s[2],2.2,2.2), {pile=bone, width=2.5, coverage=2})
end
-- the dart
local dart = poly({{716,206},{734,212},{748,224},{730,222},{714,216}})
work(dart, {hand="detail", pile=seam, coverage=3, fill=true})
ln(rig, {{718,206},{734,211},{746,222}}, hot, {0.5,0.3})
-- pilot sparks leaping to the Warden
local sp = brush{kind="rigger", width=1.6, point=1}
local function zig(x0,y0,x1,y1,n,amp)
  local pts = {{x0,y0}}
  for i=1,n-1 do local t=i/n; pts[#pts+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)} end
  pts[#pts+1] = {x1,y1}
  sp:reload(hot, 0.9); sp:stroke(pts, {pressure={0.8,0.25}, ramps={0.02,0.2}})
  return pts
end
local a = zig(748,222,762,176,5,4); zig(a[3][1],a[3][2],776,160,3,3)
local b = zig(748,224,790,226,6,4); zig(b[4][1],b[4][2],800,246,3,3)
local c = zig(746,226,760,262,5,4); zig(c[2][1],c[2][2],744,250,2,2)
zig(744,222,772,208,4,3)

--@ chunk 19
print(wait(2*24*60))
-- nimbus behind the Warden's hump (dim bronze ring, mostly hidden)
local nim = (ellipse(900,150,120,110) - ellipse(900,150,104,94)) - WAR
local nimp = pile{{"bone brown",2},{"raw sienna",1},{"burnt sienna",0.5}}
work(nim, {hand="body", tool="filbert 4", pile=nimp, coverage=2.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-150,x-900)+1.57 end, length={10,24}})
-- hood/carapace over the head joins it to the mass
WHD = poly({{760,150},{774,128},{800,112},{830,100},{850,96},{820,140},{805,180},{800,215},{790,212},{796,170},{780,145}}, true)
local litzone = ribbon({{760,140},{750,170},{762,198},{790,214}}, 20) + ribbon({{802,150},{850,96},{910,78}}, 18)
   + ribbon({{812,236},{746,276},{690,316}}, 22) + ribbon({{772,222},{758,292},{768,360},{752,450},{744,562}}, 22)
local wd2 = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",1}}
work((WAR + WHD) - litzone, {hand="body", tool="filbert 6", pile=wd2, coverage=2.6, fill=true, clip=true, angle=function(x,y) return 1.4+0.5*math.sin(x*0.03+y*0.02) end, length={14,36}})
WAR = WAR + WHD
-- corridor ribs, caught by the discharge
local rib = pile{{"ultramarine ash",2},{"bone black",1},{"zinc white",1.2}}
local vp = {640,280}
for k,s in ipairs({0.45,0.62,0.85,1.15}) do
  local pts = {}
  for i=0,24 do
    local a = math.pi*(1.08 + 0.84*i/24)
    pts[#pts+1] = {vp[1]+math.cos(a)*420*s, vp[2]+math.sin(a)*300*s}
  end
  local b = brush{kind="round", width=3+2*k, point=0.6}
  b:load(rib, 0.35 - 0.05*k)
  b:stroke(pts, {pressure={0.05,0.05}, swell={0.4,1.0,1.4,1.0,0.5}, ramps={0.3,0.3}})
end

--@ chunk 20
wd2 = pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",1}}
-- Warden: kill the even outline low down, break it higher up
local low = ribbon({{768,360},{752,450},{744,562}}, 26) * WAR
work(low, {hand="body", tool="filbert 5", pile=wd2, coverage=3, fill=true, clip=true, angle=1.6, length={12,30}})
local mid = ribbon({{760,292},{768,355}}, 22) * WAR
work(mid, {hand="body", tool="filbert 4", pile=wd2, coverage=1.4, clip=true, angle=1.6, length={8,20}})
-- lamellae on the near side, a handful of hard glints
for i,y in ipairs({300,322,344,366,388}) do
  ln(rnd, {{772,y},{800,y+6},{828,y+8}}, seam, {0.6,0.3}, 0.6)
  ln(rig, {{772,y+3},{790,y+7},{806,y+9}}, wlit, {0.5-0.07*i,0.05}, 0.6)
end
ln(rig, {{762,146},{756,162}}, hot, {0.7,0.2}); ln(rig, {{806,148},{824,122}}, hot, {0.6,0.1}); ln(rig, {{760,264},{740,280}}, hot, {0.6,0.1})
-- husks: top and near edges caught from above-left
local hl = pile{{"ultramarine ash",2},{"zinc white",2},{"cobalt violet",0.5}}
ln(rnd, {{600,368},{612,360},{624,364}}, hl, {0.6,0.3}, 0.6)
ln(rnd, {{606,386},{628,378},{646,392}}, hl, {0.7,0.3}, 0.6)
ln(rig, {{646,392},{652,430},{646,470}}, hl, {0.5,0.1}, 0.5)
ln(rig, {{590,400},{580,430},{586,470}}, hl, {0.3,0.05}, 0.4)
ln(rnd, {{678,398},{688,394},{694,398}}, hl, {0.4,0.2}, 0.5)
ln(rnd, {{680,414},{700,410},{712,428}}, hl, {0.5,0.2}, 0.5)
ln(rig, {{712,430},{708,470}}, hl, {0.3,0.05}, 0.4)
-- eyes of the husks: tiny cold sparks
stipple(ellipse(618,372,2,1.5), {pile=hot, width=2, coverage=2})
stipple(ellipse(690,404,1.5,1.2), {pile=hot, width=2, coverage=2})
-- light pool on the deck under the discharge
local pool = ellipse(640,480,220,70):soften(30) - CMD:grow(2) - WAR - H1 - H2
local pp = pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.6}, medium=0.4}
work(pool, {hand="glaze", pile=pp, load=0.22, pressure={0.08,0.2}, coverage=1.2, angle=0.0})
blend(pool:shrink(4) - CMD:grow(4) - WAR:grow(4) - H1:grow(3) - H2:grow(3), {clip=true, angle=0})

--@ chunk 21
print(wait(24*60))
local lowH = rect(560,440,170,100)
work((H1+H2)*lowH, {hand="body", tool="filbert 3", pile=hdark, coverage=3, fill=true, clip=true, angle=1.6, length={6,16}})
work(WAR*rect(740,420,260,142) - ribbon({{752,450},{744,562}}, 6), {hand="body", tool="filbert 5", pile=wd2, coverage=2.8, fill=true, clip=true, angle=1.5, length={12,30}})
-- thicker forearm below the lit top
local arm = poly({{814,250},{782,266},{744,296},{706,318},{700,338},{738,330},{778,312},{816,298}}, true)
work(arm, {hand="body", tool="filbert 4", pile=wd2, coverage=3, fill=true, clip=true, angle=2.6, length={10,24}})
WAR = WAR + arm
-- claw fingers reaching, lit on top
for _,f in ipairs({{{702,320},{684,306},{670,302}},{{700,326},{680,322},{664,326}},{{702,332},{684,338},{670,348}}}) do
  ln(rnd, f, wd2, {0.9,0.4}, 0.9)
end
ln(rig, {{700,318},{684,304},{670,300}}, wlit, {0.6,0.1}); ln(rig, {{700,324},{682,320},{666,324}}, wlit, {0.4,0.05})
-- fix the glaze streak on the near shin
work(P.fshin*rect(380,430,70,40) - PL.fshin, {hand="body", tool="filbert 3", pile=armB, coverage=3, fill=true, clip=true, angle=1.86, length={6,14}})

--@ chunk 22
local pmap = {helm="helm",chest="torso",npaul="npaul",uarm="uarm",farm="farm",cannon="cannon",muzzle="cannon",pelvis="pelvis",
  fthigh="fthigh",fknee="fshin",fshin="fshin",ffoot="ffoot",bthigh="bthigh",bshin="bshin",bfoot="bfoot"}
local bright = pile{{"zinc white",4},{"cerulean blue",0.25},{"lemon chrome",0.05}}
local mid = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",1.6},{"cobalt violet",0.3}}
for k,m in pairs(PL) do
  if k ~= "pelvis" then
  local c = PC[k]; local a = ANG[k]
  local function an(x,y) return a+0.2*math.sin(x*0.1+y*0.07) end
  local tb = {kind="filbert", width=2.5, point=0.5}
  work(m, {hand="body", tool="filbert 3", pile=armL, angle=an, coverage=2.5, fill=true, clip=true, length={6,16}})
  work(m*(-hp(c[1],c[2],-0.15,c[3])), {hand="body", tool=tb, pile=mid, angle=an, coverage=2.2, clip=m, length={5,14}, pressure={0.4,0.9}, ramps={0.2,0.5}})
  work(m*hp(c[1],c[2],0.55,c[3]), {hand="body", tool=tb, pile=bright, angle=an, coverage=1.8, clip=m, length={4,12}, pressure={0.4,0.9}, ramps={0.2,0.5}})
  end
end

--@ chunk 23
print(wait(2*24*60))
local mdk = pile{{"bone black",1.2},{"ultramarine ash",1.5},{"ultramarine blue",0.5},{"zinc white",0.5}}
local mid = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",1.4},{"cobalt violet",0.3}}
for k,m in pairs(PL) do
  if k ~= "pelvis" and k ~= "muzzle" then
  local c = PC[k]; local a = ANG[k]
  local function an(x,y) return a+0.2*math.sin(x*0.1+y*0.07) end
  local tb = {kind="filbert", width=3, point=0.4}
  work(m*(-hp(c[1],c[2],0.0,c[3])), {hand="body", tool=tb, pile=mdk, angle=an, coverage=2.6, fill=true, clip=m, length={5,14}, pressure={0.5,0.9}, ramps={0.2,0.4}})
  work(m*hp(c[1],c[2],0.0,c[3])*(-hp(c[1],c[2],0.45,c[3])), {hand="body", tool=tb, pile=mid, angle=an, coverage=2.0, clip=m, length={5,12}, pressure={0.4,0.9}, ramps={0.2,0.5}})
  end
end

--@ chunk 24
print(wait(2*24*60))
TAB = poly({{304,262},{370,255},{380,284},{398,310},{428,334},{410,337},{394,347},{374,340},{354,354},{334,343},{316,350},{302,322}}, true):roughen(2,8,3)
local td = pile{{"red earth",1},{"bone black",1},{"burnt sienna",1}}
local tl = pile{{"vermilion",1},{"red earth",1},{"zinc white",0.5}}
work(TAB, {hand="body", tool="filbert 4", pile=td, coverage=3, fill=true, clip=true, angle=1.3, length={10,26}})
local litT = TAB * poly({{360,255},{382,255},{430,330},{410,345},{372,320}})
work(litT, {hand="body", tool={kind="filbert",width=3,point=0.4}, pile=tl, coverage=1.8, clip=TAB, angle=1.0, length={8,20}, pressure={0.4,0.9}, ramps={0.2,0.5}})
CMD = CMD + TAB

--@ chunk 25
print(wait(2*24*60))
local fd = pile{{"bone black",1.5},{"red earth",1},{"ultramarine blue",0.4}}
local cannonL = P.cannon * rect(280,240,150,80)
work(cannonL - PL.cannon, {hand="body", tool="filbert 3", pile=armB, coverage=3, fill=true, clip=true, angle=-0.15, length={10,30}})
work(PL.cannon * rect(280,240,150,80), {hand="body", tool="filbert 2", pile=armL, coverage=3, fill=true, clip=true, angle=-0.15, length={10,30}})
-- tabard folds (dark troughs, lit ridges) and the cross
for _,f in ipairs({{{318,272},{314,300},{318,340}},{{336,280},{338,312},{334,345}},{{356,272},{362,305},{370,338}},{{372,280},{390,310},{408,334}}}) do
  ln(rnd, f, fd, {0.7,0.3}, 0.7)
end
local tl = pile{{"vermilion",1},{"red earth",1},{"zinc white",0.7}}
ln(rnd, {{364,282},{378,308},{396,330}}, tl, {0.6,0.2}, 0.6)
ln(rnd, {{346,284},{350,318},{354,346}}, tl, {0.4,0.1}, 0.5)
local crossp = pile{{"zinc white",2},{"ultramarine ash",1},{"bone black",0.4}}
ln(rnd, {{345,276},{346,300},{347,328}}, crossp, {0.9,0.8}, 0.8)
ln(rnd, {{328,296},{346,295},{366,293}}, crossp, {0.9,0.8}, 0.8)

--@ chunk 26
print(wait(2*24*60))
local gun = pile{{"bone black",2},{"ultramarine blue",1}}
HOUS = poly({{286,264},{382,250},{386,314},{292,320}})
local bar = P.cannon * rect(380,230,60,70)
work(HOUS + bar, {hand="body", tool="filbert 3", pile=gun, coverage=4, fill=true, clip=true, angle=-0.15, length={10,30}, load=1.0})
CMD = CMD + HOUS

--@ chunk 27
gun = pile{{"bone black",2},{"ultramarine blue",1}}
print(wait(24*60))
local bright = pile{{"zinc white",4},{"cerulean blue",0.25},{"lemon chrome",0.05}}
local fd = pile{{"bone black",1.5},{"red earth",1},{"ultramarine blue",0.4}}
local crossp = pile{{"zinc white",2},{"ultramarine ash",1},{"bone black",0.4}}
-- gun housing: lit right face and top edge, barrel top restored, a vent and a cable spool
work(poly({{374,252},{383,251},{387,313},{378,314}}), {hand="detail", pile=armL, coverage=3, fill=true})
ln(rig, {{300,263},{340,257},{382,251}}, armL, {0.2,0.6})
ln(rig, {{382,251},{420,246},{460,241}}, bright, {0.7,0.5})
ln(rnd, {{300,280},{340,276},{372,272}}, seam, {0.5,0.5})
ln(rig, {{304,284},{340,280},{372,276}}, dimL, {0.3,0.1})
ln(rnd, {{300,296},{340,292},{372,289}}, seam, {0.5,0.5})
work(ellipse(352,302,9,7), {hand="detail", pile=dimL, coverage=2})
-- tabard below the gun: cross foot, fold accents
ln(rnd, {{338,320},{339,334},{340,346}}, crossp, {0.9,0.8}, 0.8)
ln(rnd, {{392,318},{404,330},{416,336}}, fd, {0.6,0.2})
-- helmet: crest, visor lip, breaths
ln(rnd, {{312,74},{326,64},{344,62},{360,70}}, seam, {0.6,0.4})
ln(rig, {{330,63},{346,62},{360,70},{366,82}}, bright, {0.6,0.2})
ln(rnd, {{343,99},{356,97},{371,96}}, gun, {0.9,0.7}, 0.9)
ln(rig, {{348,104},{360,103},{370,101}}, bright, {0.6,0.3})
for i=0,2 do stipple(ellipse(360+i*3,112,0.8,0.8), {pile=seam, width=1.5, coverage=1.5}) end
ln(rig, {{368,90},{370,100}}, hot, {0.8,0.2})
-- plates across the lit bands: chest lames, couter, cuisse/poleyn/greave breaks
ln(rnd, {{338,196},{368,190},{392,194}}, seam, {0.6,0.4}); ln(rig, {{344,200},{370,195},{390,199}}, bright, {0.5,0.1})
ln(rnd, {{342,226},{366,222},{384,226}}, seam, {0.6,0.4}); ln(rig, {{346,230},{368,226},{382,230}}, bright, {0.4,0.1})
ln(rnd, {{396,226},{412,224}}, seam, {0.6,0.4}); ln(rig, {{404,230},{414,229}}, hot, {0.7,0.2})
ln(rnd, {{376,340},{392,334},{410,350}}, seam, {0.6,0.4}); ln(rig, {{380,346},{396,340},{412,356}}, bright, {0.5,0.1})
ln(rnd, {{398,384},{418,376},{432,388}}, seam, {0.6,0.4})
ln(rnd, {{408,470},{424,466},{432,474}}, seam, {0.6,0.4}); ln(rig, {{416,476},{426,472}}, bright, {0.5,0.1})
ln(rnd, {{262,380},{290,372}}, seam, {0.6,0.4}); ln(rig, {{266,386},{292,378}}, bright, {0.4,0.1})
ln(rnd, {{230,452},{250,458}}, seam, {0.6,0.4})
ln(rnd, {{168,532},{176,540}}, seam, {0.5,0.4}); ln(rnd, {{184,526},{192,536}}, seam, {0.5,0.4})
-- specular glints where the forms face the discharge
for _,g in ipairs({{366,84},{412,158},{420,176},{442,404},{536,240},{439,396},{414,206},{392,150},{318,334},{270,422},{214,520}}) do
  local s = brush{kind="round", width=2.5, point=1}; s:load(hot, 1.0)
  s:stroke({{g[1]-2,g[2]+1},{g[1]+2,g[2]-1}}, {pressure={0.9,0.1}})
end

--@ chunk 28
local neutral = pile{{"bone black",2},{"burnt sienna",0.5},{"zinc white",0.5}}
local order = {"pack","fpaul","torso","bthigh","bshin","fthigh","fshin","helm","uarm"}
local keep = PLM:grow(3) + TAB + HOUS
for _,k in ipairs(order) do
  local a = ANG[k]
  work(P[k] - keep, {hand="scumble", tool="filbert 4", pile=neutral, angle=a, coverage=0.9, clip=true, load=0.5})
end
-- far pauldron and pack: dim edges catching floor bounce and the discharge
local bounce = pile{{"ultramarine ash",2},{"bone black",1},{"zinc white",0.9},{"cobalt violet",0.3}}
ln(rig, {{250,150},{262,142},{282,138}}, bounce, {0.5,0.2}, 0.6)
ln(rnd, {{248,172},{268,166},{290,170}}, seam, {0.6,0.4}, 0.6)
ln(rig, {{246,176},{266,171},{288,175}}, bounce, {0.3,0.05}, 0.5)
ln(rig, {{242,236},{252,248},{264,252}}, bounce, {0.4,0.1}, 0.5)
ln(rnd, {{258,150},{266,190},{270,240}}, seam, {0.5,0.4}, 0.6)
ln(rig, {{262,152},{270,192},{274,240}}, bounce, {0.25,0.05}, 0.4)
ln(rig, {{290,322},{300,330},{316,334}}, bounce, {0.4,0.1}, 0.5)
ln(rig, {{232,412},{246,422}}, bounce, {0.4,0.1}, 0.5)
ln(rig, {{186,528},{150,540}}, bounce, {0.5,0.1}, 0.5)
ln(rig, {{396,496},{410,500}}, bounce, {0.4,0.1}, 0.5)
ln(rig, {{304,124},{318,130},{332,132}}, bounce, {0.4,0.1}, 0.5)

--@ chunk 29
print(wait(2*24*60))
local order = {"pack","fpaul","barm","bthigh","bshin","bfoot","torso","pelvis","neck","helm","fthigh","fshin","ffoot","uarm","npaul","farm"}
local keep = PLM:grow(2.5) + TAB + HOUS + P.cannon
local sl2 = pile{{"bone black",2},{"ultramarine blue",1.2},{"Mars brown",0.3}}
for _,k in ipairs(order) do
  local a = ANG[k]
  work(P[k] - keep, {hand="body", tool="filbert 4", pile=sl2, angle=function(x,y) return a+0.25*math.sin(x*0.08+y*0.05) end,
     coverage=3.5, fill=true, clip=true, length={8,24}, load=1.0})
end

--@ chunk 30
print(wait(2*24*60))
local bounce = pile{{"ultramarine ash",2},{"bone black",1.2},{"zinc white",0.7},{"cobalt violet",0.3}}
local function bl(pts, pr) ln(rig, pts, bounce, pr or {0.4,0.1}, 0.55) end
-- plates in the shadow side, caught faintly
bl({{250,150},{262,142},{282,138}}, {0.5,0.2})
ln(rnd, {{248,172},{268,166},{290,170}}, seam, {0.6,0.4}, 0.6); bl({{246,177},{266,172},{288,176}}, {0.3,0.05})
bl({{240,236},{250,248},{264,252}})
ln(rnd, {{278,150},{282,200},{280,244}}, seam, {0.5,0.4}, 0.6); bl({{283,152},{287,200},{285,244}}, {0.25,0.05})
bl({{290,206},{312,210},{334,208}}, {0.3,0.05}); bl({{292,236},{314,240},{336,238}}, {0.3,0.05})
bl({{306,124},{320,130},{334,132}})
bl({{312,74},{306,90},{303,106}}, {0.3,0.05})
bl({{232,412},{246,422}}); bl({{186,528},{150,540}}, {0.5,0.1}); bl({{392,498},{408,502}})
bl({{300,350},{284,376},{268,404}}, {0.3,0.05}); bl({{236,440},{224,470},{212,500}}, {0.3,0.05})
bl({{372,336},{388,362},{400,388}}, {0.3,0.05})
-- Warden: halftone facets beside the lit edges, seams, rosette round the eye
local wh2 = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone brown",1}}
for _,f in ipairs({
   poly({{776,150},{800,120},{820,112},{806,160},{790,200},{778,196}}),
   poly({{780,300},{800,296},{805,360},{790,420},{774,420},{778,360}}),
   poly({{830,110},{872,90},{860,130},{826,170}}) }) do
  work(f, {hand="body", tool="filbert 4", pile=wh2, coverage=2, clip=WAR, angle=1.5, length={8,20}, edge="soft"})
end
local bone = pile{{"zinc white",3},{"yellow ochre",1},{"raw sienna",0.3}}
for i=0,9 do local a=i*2.39996; local r=4+1.6*math.sqrt(i+1)*2
  stipple(ellipse(770+math.cos(a)*r, 172+math.sin(a)*r*0.9, 1.5,1.5), {pile=bone, width=2, coverage=1.5}) end
ln(rnd, {{820,220},{840,250},{850,300}}, seam, {0.5,0.3}); ln(rnd, {{800,420},{830,430},{860,428}}, seam, {0.5,0.3})
-- mites on the deck, small dark machines with a lit back
for _,m in ipairs({{520,500,9},{560,532,7},{486,540,8},{720,520,7}}) do
  local sh = ellipse(m[1],m[2],m[3],m[3]*0.55)
  work(sh, {hand="detail", pile=hdark, coverage=3, fill=true})
  ln(rig, {{m[1]-m[3]*0.6,m[2]-m[3]*0.4},{m[1]+m[3]*0.6,m[2]-m[3]*0.5}}, bounce, {0.6,0.2}, 0.6)
  for j=-1,1,2 do ln(rig, {{m[1]+j*m[3]*0.5,m[2]+2},{m[1]+j*m[3]*1.3,m[2]+m[3]*0.7}}, hdark, {0.5,0.3}, 0.7) end
end
-- cast shadows of the Commando's legs, thrown toward us and left
local cs = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.5}}
work(poly({{215,540},{180,562},{140,562},{160,548}}) + poly({{410,512},{396,520},{340,562},{310,562},{380,515}}), {hand="body", tool="filbert 4", pile=cs, coverage=2.5, fill=true, clip=true, angle=2.4, length={8,20}})

--@ chunk 31
print(wait(2*24*60))
local wd3 = pile{{"bone black",1.6},{"bone brown",1.4},{"burnt sienna",0.8}}
local nearband = ribbon({{760,135},{748,170},{760,200},{792,214}}, 26) + ribbon({{798,152},{850,94},{915,76}}, 24)
   + ribbon({{814,240},{746,280},{690,320}}, 30) + ribbon({{772,222},{758,292},{768,360}}, 26) + ribbon({{768,360},{752,450},{744,562}}, 10)
work(WAR - nearband, {hand="body", tool="filbert 6", pile=wd3, coverage=3.5, fill=true, clip=true, load=1.0,
   angle=function(x,y) return 1.4+0.5*math.sin(x*0.03+y*0.02) end, length={14,36}})
-- a narrow transition: a few warm halftone strokes just inside the band
local trans = (nearband:grow(10) - nearband) * WAR * rect(680,60,200,320)
local wh2 = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",1.5}}
work(trans, {hand="body", tool={kind="filbert",width=3,point=0.4}, pile=wh2, coverage=1.2, clip=WAR, angle=1.5, length={6,16}, pressure={0.3,0.8}, ramps={0.2,0.5}})

--@ chunk 32
print(wait(2*24*60))
local low = WAR * (rect(740,380,260,182) + rect(890,60,110,330)) - ribbon({{768,360},{752,450},{744,562}}, 8)
work(low, {hand="body", tool="filbert 6", pile=gun, coverage=3, fill=true, clip=true, load=1.0, angle=1.5, length={14,36}})
-- air lit by the discharge
local halo = ribbon(CAB, {30,60,80,90,95,100,100,95,85,70}):soften(25) - CMD:grow(3) - WAR:grow(3) - ribbon(CAB, {6,12,18,22,24,26,26,24,20,16})
local gp = pile{{"zinc white",3},{"cobalt violet",0.6},{"ultramarine blue",0.4}, medium=0.7}
work(halo, {hand="glaze", pile=gp, load=0.18, pressure={0.06,0.16}, coverage=0.8, clip=true})
blend(halo:shrink(4), {clip=true})

--@ chunk 33
print(wait(2*24*60))
gunW = pile{{"bone black",2},{"ultramarine blue",0.6},{"bone brown",1}}
NB = ribbon({{760,135},{748,170},{760,200},{792,214}}, 24) + ribbon({{798,152},{850,94},{915,76}}, 22)
   + ribbon({{814,240},{746,280},{690,320}}, 28) + ribbon({{772,222},{758,292},{768,360}}, 24) + ribbon({{768,360},{752,450},{744,562}}, 8)
work(WAR - NB, {hand="body", tool="filbert 6", pile=gunW, coverage=3.5, fill=true, clip=true, load=1.0,
   angle=function(x,y) return 1.4+0.5*math.sin(x*0.03+y*0.02) end, length={14,36}})

--@ chunk 34
print(wait(2*24*60))
local wh2 = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",1.5}}
local wh3 = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.5}}
local F = {
 {poly({{776,134},{806,118},{814,150},{802,200},{790,212},{782,190}}), wh2, 1.6},
 {poly({{806,160},{850,104},{892,90},{872,130},{832,172},{814,232}}), wh2, 2.3},
 {poly({{872,92},{930,80},{940,100},{880,130}}), wh3, 2.8},
 {poly({{772,300},{800,298},{812,350},{798,400},{774,382}}), wh3, 1.6},
 {poly({{814,240},{850,236},{860,290},{818,300}}), wh3, 1.8},
}
for _,f in ipairs(F) do
  work(f[1]*WAR, {hand="body", tool={kind="filbert",width=4,point=0.4}, pile=f[2], coverage=2.4, fill=true, clip=WAR, angle=f[3], length={8,22}, pressure={0.5,0.9}})
end
-- break the even rim low down
for _,y in ipairs({430,470,505,540}) do
  work(ellipse(752 - (y-430)*0.08, y, 9, 14), {hand="body", tool="filbert 3", pile=gunW, coverage=3, fill=true, clip=WAR, angle=1.6, length={6,14}})
end
-- seams between the facets
ln(rnd, {{808,156},{812,200},{814,236}}, gun, {0.6,0.4}); ln(rnd, {{804,160},{840,120},{880,100}}, gun, {0.5,0.3})
ln(rnd, {{772,298},{810,296},{850,290}}, gun, {0.6,0.4})

--@ chunk 35
print(wait(24*60))
local head = poly({{752,148},{776,130},{800,122},{806,150},{798,196},{788,212},{762,200},{748,176}}, true) * WAR
work(head, {hand="body", tool="filbert 3", pile=whalf, coverage=3, fill=true, clip=WAR, angle=1.5, length={6,16}})
work(head * poly({{740,130},{782,124},{772,210},{740,210}}), {hand="body", tool={kind="filbert",width=3,point=0.4}, pile=wlit, coverage=2, clip=head, angle=1.5, length={5,14}, pressure={0.5,0.9}})
local sh = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",1}}
work(head * poly({{790,120},{810,120},{810,214},{786,214}}), {hand="body", tool="filbert 3", pile=sh, coverage=2.4, clip=head, angle=1.5, length={6,14}})

--@ chunk 36
print(wait(24*60))
local dart = poly({{712,204},{732,210},{752,224},{732,224},{710,216}})
work(dart, {hand="detail", pile=gun, coverage=4, fill=true})
work(poly({{738,212},{746,206},{744,218}}), {hand="detail", pile=gun, coverage=4, fill=true})
ln(rig, {{714,204},{732,209},{750,222}}, hot, {0.6,0.4})
local sp = brush{kind="rigger", width=1.8, point=1}
local function zig(x0,y0,x1,y1,n,amp,pr)
  local pts = {{x0,y0}}
  for i=1,n-1 do local t=i/n; pts[#pts+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)} end
  pts[#pts+1] = {x1,y1}
  sp:reload(hot, 1.0); sp:stroke(pts, {pressure=pr or {0.9,0.3}, ramps={0.02,0.15}})
  return pts
end
local a = zig(752,222,768,172,7,5); zig(a[4][1],a[4][2],782,150,4,4,{0.6,0.2}); zig(a[2][1],a[2][2],776,200,3,3,{0.5,0.1})
local b = zig(752,224,800,240,7,5); zig(b[4][1],b[4][2],790,262,3,3,{0.6,0.2})
local c = zig(750,226,738,268,6,4); zig(c[3][1],c[3][2],722,262,3,3,{0.5,0.1})
zig(752,222,812,212,8,6,{0.7,0.2})
-- where the sparks bite: hot specks
for _,g in ipairs({{768,172},{782,150},{800,240},{812,212},{738,268},{776,200}}) do
  stipple(ellipse(g[1],g[2],2.5,2.5), {pile=hot, width=2.5, coverage=3})
end
-- the Warden's eye: a dark socket with a cold point
work(ellipse(772,170,6,4), {hand="detail", pile=gun, coverage=4, fill=true})
stipple(ellipse(773,170,1.2,1.2), {pile=hot, width=1.5, coverage=2})

--@ chunk 37
local bnc = pile{{"ultramarine ash",2},{"zinc white",1.3},{"bone black",0.5},{"cobalt violet",0.2}}
local bright = pile{{"zinc white",4},{"cerulean blue",0.25},{"lemon chrome",0.05}}
local function bl(pts, pr) ln(rig, pts, bnc, pr or {0.45,0.1}, 0.6) end
-- helmet: projecting visor, comb, cheek plate
local visor = poly({{348,84},{372,88},{380,98},{376,106},{352,104}}, true)
work(visor, {hand="detail", pile=armL, coverage=3, fill=true})
work(poly({{350,98},{378,100},{376,106},{352,105}}), {hand="detail", pile=armH, coverage=2})
ln(rnd, {{350,107},{364,108},{376,107}}, gun, {0.8,0.6}, 0.9)
ln(rig, {{352,85},{368,88},{379,96}}, hot, {0.7,0.3})
ln(rnd, {{306,84},{318,68},{336,60},{352,62}}, gun, {0.9,0.7}, 0.9)
ln(rig, {{320,66},{336,59},{352,61},{362,68}}, bnc, {0.5,0.2}, 0.6)
ln(rnd, {{344,112},{340,124},{346,130}}, gun, {0.6,0.4})
bl({{306,92},{304,108},{310,122}}, {0.4,0.1})
-- dark side plates with a cool bounce
bl({{248,150},{264,141},{286,137}}, {0.6,0.2})
ln(rnd, {{246,174},{268,168},{292,171}}, gun, {0.7,0.5}); bl({{246,179},{268,173},{290,177}}, {0.4,0.05})
ln(rnd, {{280,150},{284,200},{282,246}}, gun, {0.6,0.5}); bl({{285,152},{289,200},{287,244}}, {0.35,0.05})
bl({{292,206},{314,210},{332,208}}, {0.35,0.05}); bl({{294,236},{316,240},{334,238}}, {0.35,0.05})
bl({{240,232},{250,246},{266,252}}, {0.5,0.1})
bl({{300,345},{284,374},{268,402}}, {0.35,0.05}); bl({{236,440},{224,470},{212,500}}, {0.35,0.05})
bl({{360,345},{378,372},{394,396}}, {0.35,0.05})
-- gun: lit top plane of the housing, rivets, hot muzzle ring where the cable leaves
work(poly({{288,262},{382,249},{384,256},{290,270}}), {hand="detail", pile=armH, coverage=2.5, fill=true})
ln(rig, {{290,262},{340,255},{382,249}}, bright, {0.3,0.7})
for _,r in ipairs({{300,276},{300,306},{370,268},{372,300}}) do stipple(ellipse(r[1],r[2],1.6,1.6), {pile=armL, width=2, coverage=2}) end
ln(rnd, {{533,236},{535,252},{534,268}}, hot, {0.9,0.6}, 1.0)
stipple(ellipse(542,251,4,5), {pile=hot, width=2.5, coverage=3})

--@ chunk 38
local nim = ellipse(900,150,121,111) - ellipse(900,150,103,93)
local vig = (-(ellipse(650,260,480,330):soften(80))) - CMD:grow(2) - WAR:grow(2) - nim:grow(2)
local deep = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.6}}
work(vig, {hand="body", tool="filbert 12", pile=deep, coverage=2.4, fill=true, clip=true, angle=0.1, length={40,110}, edge="lost"})

--@ chunk 39
sl2 = pile{{"bone black",2},{"ultramarine blue",1.2},{"Mars brown",0.3}}
print(wait(2*24*60))
local R = rect(120,330,200,232)
local legs = (P.bthigh + P.bshin + P.bfoot) * R
local planes = (PL.bthigh + PL.bshin + PL.bfoot) * R
work(legs - planes:grow(1.5), {hand="body", tool="filbert 4", pile=sl2, coverage=3.5, fill=true, clip=true, load=1.0, angle=1.99, length={8,22}})
work(planes, {hand="body", tool="filbert 2", pile=armL, coverage=3, fill=true, clip=true, angle=1.99, length={6,16}})

--@ chunk 40
print(wait(2*24*60))
local mid = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",1.2},{"cobalt violet",0.3}}
local R = rect(120,330,200,232)
local planes = (PL.bthigh + PL.bshin + PL.bfoot) * R
work(planes * rect(120,470,200,100), {hand="body", tool={kind="filbert",width=2.5,point=0.4}, pile=mid, coverage=2, clip=planes, angle=1.99, length={5,14}, pressure={0.4,0.9}})
ln(rnd, {{250,416},{262,412},{272,420},{268,434},{254,438}}, gun, {0.6,0.5})
ln(rig, {{266,416},{271,424}}, hot, {0.7,0.2})
ln(rnd, {{226,470},{246,476}}, gun, {0.6,0.5}); ln(rnd, {{290,372},{276,368}}, gun, {0.5,0.4})
ln(rnd, {{166,532},{174,541}}, gun, {0.6,0.5}); ln(rnd, {{186,524},{194,535}}, gun, {0.6,0.5})
ln(rig, {{150,534},{184,520},{214,519}}, hot, {0.3,0.6})

--@ chunk 41
local bnc = pile{{"ultramarine ash",2},{"zinc white",1.3},{"bone black",0.5},{"cobalt violet",0.2}}
ln(rig, {{286,318},{258,360},{236,404}}, bnc, {0.5,0.2}, 0.6)
ln(rig, {{236,410},{214,460},{196,500},{186,520}}, bnc, {0.45,0.15}, 0.6)
ln(rig, {{184,522},{160,532},{144,546}}, bnc, {0.4,0.1}, 0.5)
ln(rig, {{144,548},{180,550},{220,544}}, bnc, {0.3,0.1}, 0.5)
-- Warden forearm: warm halftone side plane under the lit top
local side = ribbon({{812,256},{780,272},{746,296},{712,318},{700,332}}, {12,14,14,12,8}) * WAR
work(side, {hand="body", tool={kind="filbert",width=3,point=0.4}, pile=whalf, coverage=2.2, fill=true, clip=WAR, angle=2.6, length={8,20}, pressure={0.4,0.8}})
ln(rnd, {{812,262},{778,280},{744,304},{710,326}}, gun, {0.4,0.2}, 0.5)

--@ chunk 42
-- PASS 2 / A: the discharge's light thrown on the deck and walls, falling off
print(wait(24*60))
local figs = CMD:grow(2) + WAR:grow(2)
local floor = poly({{250,425},{1000,425},{1000,562},{150,562}})
local f1 = pile{{"bone black",1.2},{"ultramarine ash",1},{"Mars brown",0.4},{"zinc white",0.35}}
local f2 = pile{{"ultramarine ash",1.5},{"bone black",0.8},{"zinc white",0.9},{"cobalt violet",0.25}}
local f3 = pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.3}}
local outer = floor * ellipse(650,470,420,120):roughen(10,60,3) - figs
local midz = floor * ellipse(650,465,270,72):roughen(8,50,4) - figs
local inner = floor * ellipse(650,458,150,38):roughen(6,40,5) - figs
-- the old husk blobs go under the deck too; they are repainted later
work(outer, {hand="body", tool="filbert 8", pile=f1, coverage=2.6, fill=true, clip=floor - figs, angle=0.0, length={30,80}, edge="soft"})
work(midz, {hand="body", tool="filbert 6", pile=f2, coverage=2.4, fill=true, clip=floor - figs, angle=0.0, length={20,60}, edge="soft"})
work(inner, {hand="body", tool="filbert 5", pile=f3, coverage=2.2, fill=true, clip=floor - figs, angle=0.0, length={14,40}, edge="soft"})
-- deck plate seams running to the vanishing point
for _,x in ipairs({420,560,740,900}) do
  local b = brush{kind="round", width=2, point=0.6}; b:load(gun, 0.6)
  b:stroke({{640,428},{lerp(640,x*1.6-380,0.5),495},{x*1.6-380,562}}, {pressure={0.15,0.6}, clip=floor - figs})
end

--@ chunk 43
local figs = CMD:grow(2) + WAR:grow(2)
local floor = poly({{250,425},{1000,425},{1000,562},{150,562}})
blend(floor:shrink(2) - figs:grow(3), {clip=true, angle=0.0})
blend(floor:shrink(2) - figs:grow(3), {clip=true, angle=0.0})
-- dissolve the hard far edge of the deck into the wall
local wallp = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1},{"zinc white",0.3}}
lose(floor - figs, {pile=wallp, where=function(x,y) return y < 440 and 1 or 0 end, tool="filbert 5", reach={6,22}, load=0.45, pressure={0.5,0.05}, every=1.4, angle=1.57})

--@ chunk 44
print(wait(2*24*60))
local figs = CMD:grow(2) + WAR:grow(2)
local floor = poly({{150,412},{1000,412},{1000,562},{150,562}})
local fd = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.8},{"zinc white",0.15}}
local fm = pile{{"bone black",1.3},{"ultramarine ash",1},{"Mars brown",0.5},{"zinc white",0.5}}
local pool = ellipse(640,468,230,52):roughen(10,50,7)
local core = ellipse(640,462,120,28):roughen(6,40,8)
work(floor - pool - figs, {hand="body", tool="filbert 8", pile=fd, coverage=3, fill=true, clip=floor - figs, angle=0.0, length={30,90}, edge="soft"})
work(pool - core - figs, {hand="body", tool="filbert 5", pile=fm, coverage=2.6, fill=true, clip=floor - figs, angle=0.0, length={14,44}, edge="soft"})

--@ chunk 45
local figs = CMD:grow(2) + WAR:grow(2)
local deep = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.6}}
local fm = pile{{"bone black",1.3},{"ultramarine ash",1},{"Mars brown",0.5},{"zinc white",0.5}}
local left = poly({{100,400},{330,410},{300,562},{100,562}}) - figs
work(left, {hand="body", tool="filbert 8", pile=deep, coverage=3, fill=true, clip=-figs, angle=0.3, length={20,60}})
local core = ellipse(640,462,120,28):roughen(6,40,8)
work(core:grow(6) - figs, {hand="scumble", tool="filbert 4", pile=fm, coverage=1.0, clip=-figs, angle=0.0, load=0.5})
-- cast shadows of the Commando's legs across the lit deck, away from the discharge
local cs = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.5}}
work(poly({{420,516},{440,512},{360,562},{325,562}}) - figs, {hand="body", tool="filbert 4", pile=cs, coverage=2.6, fill=true, clip=-figs, angle=2.5, length={10,30}})

--@ chunk 46
-- PASS 2 / B: wall above the old husk blobs, then the husks rebuilt as boxy outpost machines
local wallp = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1},{"zinc white",0.5}}
local old = (H1 + H1h + H2 + H2h):grow(2) * rect(560,340,170,90)
work(old, {hand="body", tool="filbert 4", pile=wallp, coverage=3, fill=true, clip=true, angle=0.0, length={10,30}})
local f2 = pile{{"ultramarine ash",1.5},{"bone black",0.8},{"zinc white",0.9},{"cobalt violet",0.25}}
local oldlow = (H1 + H2):grow(2) * rect(560,425,170,120)
work(oldlow, {hand="body", tool="filbert 4", pile=f2, coverage=3, fill=true, clip=true, angle=0.0, length={10,30}})

--@ chunk 47
-- PASS 2 / C: husks as subverted outpost machines
local hd = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.6}}
local hm = pile{{"bone black",1},{"ultramarine ash",1.5},{"zinc white",0.6},{"cobalt violet",0.2}}
local hl = pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.4}}
local function part(pts) local m = poly(pts); work(m, {hand="body", tool="filbert 3", pile=hd, coverage=3.5, fill=true, clip=true, load=1.0, angle=1.57, length={5,14}}); return m end
local function lit(pts, p, a) work(poly(pts), {hand="detail", pile=p, coverage=3, fill=true, angle=a or 0}) end
-- H1, nearer
part({{586,386},{646,382},{650,446},{592,452}})
part({{594,450},{646,445},{644,462},{596,466}})
part({{598,464},{611,464},{606,500},{614,528},{599,530},{592,500}})
part({{630,460},{643,460},{649,500},{645,528},{632,528},{635,500}})
part({{588,526},{615,525},{617,535},{585,535}}); part({{627,525},{651,525},{653,535},{625,535}})
part({{604,378},{624,376},{626,388},{606,390}})
part({{594,358},{629,354},{633,378},{597,382}})
part({{588,390},{574,394},{566,428},{577,431},{584,404}})
part({{566,428},{560,436},{570,440},{578,432}})
lit({{594,358},{629,354},{630,360},{596,364}}, hl)
lit({{586,386},{646,382},{646,389},{587,392}}, hl)
lit({{586,392},{593,391},{596,450},{591,451}}, hm, 1.57)
lit({{575,394},{588,390},{586,398},{573,400}}, hl)
lit({{596,364},{601,363},{601,380},{597,381}}, hm, 1.57)
lit({{599,466},{611,465},{606,498},{600,498}}, hm, 1.8)
lit({{631,461},{637,461},{640,500},{636,500}}, hm, 1.5)
lit({{588,526},{615,525},{615,528},{588,529}}, hm)
-- chest panel seams, the sensor eye
ln(rnd, {{604,404},{636,402}}, hm, {0.4,0.3}, 0.5); ln(rnd, {{606,424},{636,421}}, hm, {0.3,0.2}, 0.4)
stipple(ellipse(601,371,3.5,3.5), {pile=hl, width=2.5, coverage=3}); stipple(ellipse(601,371,1.4,1.4), {pile=hot, width=1.5, coverage=3})
ln(rig, {{624,354},{628,342},{627,334}}, hm, {0.5,0.2}, 0.6)
-- H2, further back, smaller and darker
part({{670,416},{710,413},{712,456},{674,460}})
part({{678,458},{687,458},{685,503},{676,503}}); part({{698,456},{707,456},{711,503},{702,503}})
part({{674,500},{690,500},{690,507},{672,507}}); part({{700,500},{714,500},{715,507},{698,507}})
part({{684,410},{698,409},{699,416},{685,417}})
part({{674,396},{700,393},{702,411},{676,413}})
part({{670,420},{660,424},{654,448},{662,449},{668,430}})
lit({{674,396},{700,393},{700,398},{675,400}}, hl)
lit({{670,416},{710,413},{710,418},{671,421}}, hm)
lit({{670,421},{675,420},{676,458},{673,458}}, hm, 1.57)
stipple(ellipse(678,404,2.6,2.6), {pile=hl, width=2, coverage=3}); stipple(ellipse(678,404,1,1), {pile=hot, width=1.2, coverage=3})
-- short shadows on the deck, thrown down and away from the discharge
local cs = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.5}}
work(poly({{585,535},{655,535},{672,548},{596,550}}), {hand="body", tool="filbert 3", pile=cs, coverage=2.5, fill=true, clip=true, angle=0.2, length={8,20}, edge="soft"})
work(poly({{672,507},{716,507},{730,516},{684,518}}), {hand="body", tool="filbert 3", pile=cs, coverage=2.5, fill=true, clip=true, angle=0.2, length={8,20}, edge="soft"})

--@ chunk 48
print(wait(2*24*60))
local fm = pile{{"bone black",1.3},{"ultramarine ash",1},{"Mars brown",0.5},{"zinc white",0.5}}
local figs = CMD:grow(2) + WAR:grow(2)
work((H1+H2):grow(4)*rect(560,425,170,120) - figs, {hand="body", tool="filbert 4", pile=fm, coverage=3, fill=true, clip=true, angle=0.0, length={10,30}})
local wallp = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1},{"zinc white",0.5}}
work((H1+H1h+H2+H2h):grow(4)*rect(555,330,180,95), {hand="body", tool="filbert 4", pile=wallp, coverage=3, fill=true, clip=true, angle=0.0, length={10,30}})
print(wait(2*24*60))
-- PASS 2 / C: husks as subverted outpost machines
local hd = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.6}}
local hm = pile{{"bone black",1},{"ultramarine ash",1.5},{"zinc white",0.6},{"cobalt violet",0.2}}
local hl = pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.4}}
local function part(pts) local m = poly(pts); work(m, {hand="body", tool="filbert 3", pile=hd, coverage=4, fill=true, clip=true, load=1.0, angle=1.57, length={5,14}}); return m end
local function lit(pts, p, a) work(poly(pts), {hand="detail", pile=p, coverage=3, fill=true, angle=a or 0}) end
-- H1, nearer
part({{586,386},{646,382},{650,446},{592,452}})
part({{594,450},{646,445},{644,462},{596,466}})
part({{598,464},{611,464},{606,500},{614,528},{599,530},{592,500}})
part({{630,460},{643,460},{649,500},{645,528},{632,528},{635,500}})
part({{588,526},{615,525},{617,535},{585,535}}); part({{627,525},{651,525},{653,535},{625,535}})
part({{604,378},{624,376},{626,388},{606,390}})
part({{594,358},{629,354},{633,378},{597,382}})
part({{588,390},{574,394},{566,428},{577,431},{584,404}})
part({{566,428},{560,436},{570,440},{578,432}})
lit({{594,358},{629,354},{630,360},{596,364}}, hl)
lit({{586,386},{646,382},{646,389},{587,392}}, hl)
lit({{586,392},{593,391},{596,450},{591,451}}, hm, 1.57)
lit({{575,394},{588,390},{586,398},{573,400}}, hl)
lit({{596,364},{601,363},{601,380},{597,381}}, hm, 1.57)
lit({{599,466},{611,465},{606,498},{600,498}}, hm, 1.8)
lit({{631,461},{637,461},{640,500},{636,500}}, hm, 1.5)
lit({{588,526},{615,525},{615,528},{588,529}}, hm)
-- chest panel seams, the sensor eye
ln(rnd, {{604,404},{636,402}}, hm, {0.4,0.3}, 0.5); ln(rnd, {{606,424},{636,421}}, hm, {0.3,0.2}, 0.4)
stipple(ellipse(601,371,3.5,3.5), {pile=hl, width=2.5, coverage=3}); stipple(ellipse(601,371,1.4,1.4), {pile=hot, width=1.5, coverage=3})
ln(rig, {{624,354},{628,342},{627,334}}, hm, {0.5,0.2}, 0.6)
-- H2, further back, smaller and darker
part({{670,416},{710,413},{712,456},{674,460}})
part({{678,458},{687,458},{685,503},{676,503}}); part({{698,456},{707,456},{711,503},{702,503}})
part({{674,500},{690,500},{690,507},{672,507}}); part({{700,500},{714,500},{715,507},{698,507}})
part({{684,410},{698,409},{699,416},{685,417}})
part({{674,396},{700,393},{702,411},{676,413}})
part({{670,420},{660,424},{654,448},{662,449},{668,430}})
lit({{674,396},{700,393},{700,398},{675,400}}, hl)
lit({{670,416},{710,413},{710,418},{671,421}}, hm)
lit({{670,421},{675,420},{676,458},{673,458}}, hm, 1.57)
stipple(ellipse(678,404,2.6,2.6), {pile=hl, width=2, coverage=3}); stipple(ellipse(678,404,1,1), {pile=hot, width=1.2, coverage=3})
-- short shadows on the deck, thrown down and away from the discharge
local cs = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.5}}

--@ chunk 49
print(wait(3*24*60))
local hd = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.6}}
local hm = pile{{"bone black",1},{"ultramarine ash",1.5},{"zinc white",0.6},{"cobalt violet",0.2}}
local parts = {
 {{586,400},{646,396},{650,446},{592,452}}, {{594,450},{646,445},{644,462},{596,466}},
 {{598,464},{611,464},{606,500},{614,528},{599,530},{592,500}}, {{630,460},{643,460},{649,500},{645,528},{632,528},{635,500}},
 {{588,526},{615,525},{617,535},{585,535}}, {{627,525},{651,525},{653,535},{625,535}},
 {{670,430},{710,427},{712,456},{674,460}}, {{678,458},{687,458},{685,503},{676,503}}, {{698,456},{707,456},{711,503},{702,503}},
 {{674,500},{690,500},{690,507},{672,507}}, {{700,500},{714,500},{715,507},{698,507}}, {{588,390},{574,394},{566,428},{577,431},{584,404}}, {{670,420},{660,424},{654,448},{662,449},{668,430}} }
local HU = poly(parts[1])
for _,p in ipairs(parts) do local m = poly(p); HU = HU + m
  work(m, {hand="body", tool="filbert 3", pile=hd, coverage=4, fill=true, clip=true, load=1.0, angle=1.57, length={5,14}}) end
-- break the ghost of the old blobs on the deck
local fm = pile{{"bone black",1.5},{"ultramarine ash",1},{"Mars brown",0.6},{"zinc white",0.35}}
local ring = ((H1+H2):grow(6) - (H1+H2):shrink(4)) * rect(560,440,170,100) - HU:grow(1)
work(ring, {hand="scumble", tool="filbert 4", pile=fm, coverage=1.6, clip=-HU:grow(1), angle=0.0, load=0.6})
-- lit edges facing the discharge, laid on the legs once more
ln(rig, {{599,466},{593,500},{599,528}}, hm, {0.5,0.2}, 0.6); ln(rig, {{631,461},{635,500},{632,527}}, hm, {0.4,0.1}, 0.5)
ln(rig, {{588,400},{592,450}}, hm, {0.5,0.2}, 0.6); ln(rig, {{679,459},{677,502}}, hm, {0.4,0.1}, 0.5)
local cs = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",0.5}}
work(poly({{585,535},{655,535},{672,548},{596,550}}), {hand="body", tool="filbert 3", pile=cs, coverage=2.5, fill=true, clip=true, angle=0.2, length={8,20}})
work(poly({{672,507},{716,507},{730,516},{684,518}}), {hand="body", tool="filbert 3", pile=cs, coverage=2.5, fill=true, clip=true, angle=0.2, length={8,20}})

--@ chunk 50
-- PASS 2 / D: the Warden as faceted handmade bronze; nimbus as solid metal
print(wait(24*60))
local wh3 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.6}}
local wcore = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}
local function facet(pts, p, a)
  work(poly(pts) * WAR, {hand="body", tool={kind="filbert",width=3.5,point=0.4}, pile=p, coverage=3, fill=true, clip=WAR, angle=a, length={6,18}, pressure={0.5,0.9}})
end
-- shoulder hump: planes turning away from the discharge
facet({{842,150},{872,96},{905,84},{882,140},{862,200},{826,202}}, whalf, 2.2)
facet({{882,140},{905,84},{942,94},{922,152},{896,212},{862,200}}, wh3, 2.4)
facet({{922,152},{942,94},{975,140},{960,200},{930,232},{896,212}}, wcore, 2.0)
facet({{826,202},{862,200},{896,212},{880,240},{830,240}}, wh3, 0.2)
-- chest and belly below the arm
facet({{770,300},{800,300},{797,370},{787,440},{759,450},{767,370}}, wlit, 1.62)
facet({{800,300},{838,296},{833,380},{821,450},{787,440},{797,370}}, whalf, 1.6)
facet({{838,296},{880,296},{873,390},{861,460},{821,450},{833,380}}, wh3, 1.55)
facet({{880,296},{930,300},{920,400},{905,470},{861,460},{873,390}}, wcore, 1.5)
facet({{759,450},{787,440},{785,520},{781,562},{745,562}}, whalf, 1.6)
facet({{787,440},{821,450},{819,562},{781,562},{785,520}}, wh3, 1.6)
facet({{821,450},{861,460},{858,562},{819,562}}, wcore, 1.6)
-- head: cheek and jaw planes
facet({{790,128},{812,122},{816,160},{804,204},{790,212},{796,170}}, wh3, 1.6)
-- the nimbus as a solid bronze band, lit where it faces the discharge
local ring = (ellipse(900,150,126,116) - ellipse(900,150,100,90)) - WAR
work(ring, {hand="body", tool="filbert 4", pile=wh3, coverage=3.2, fill=true, clip=true, load=1.0, angle=function(x,y) return math.atan(y-150,x-900)+1.57 end, length={10,24}})
local litring = ring * poly({{760,40},{860,20},{830,140},{760,200}})
work(litring, {hand="body", tool="filbert 3", pile=whalf, coverage=2.5, fill=true, clip=ring, angle=function(x,y) return math.atan(y-150,x-900)+1.57 end, length={8,20}})
NIMB = ring

--@ chunk 51
-- PASS 2 / E: Warden detail on dry paint: facet edges, golden-angle bone rosette, cold displaced ghost contour
print(wait(2*24*60))

local wh3 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.6}}
local function facet(pts, p, a)
  work(poly(pts) * WAR, {hand="body", tool={kind="filbert",width=3.5,point=0.4}, pile=p, coverage=3, fill=true, clip=WAR, angle=a, length={6,18}, pressure={0.5,0.9}})
end
facet({{759,450},{787,440},{785,520},{781,562},{745,562}}, wh3, 1.6)
facet({{787,440},{821,450},{819,562},{781,562},{785,520}}, pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}, 1.6)
facet({{767,400},{792,400},{787,440},{759,450}}, whalf, 1.62)
facet({{821,450},{861,460},{858,562},{819,562}}, pile{{"bone black",2},{"ultramarine blue",0.6},{"bone brown",0.6}}, 1.6)
print(wait(2*24*60))
local wcore = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}
local bone = pile{{"zinc white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local boneD = pile{{"yellow ochre",1},{"raw sienna",1},{"bone brown",1}}
-- facet edges: dark seams with a hot edge on the lit side
for _,s in ipairs({ {{800,300},{797,370},{787,440}}, {{838,296},{833,380},{821,450}}, {{787,440},{785,520},{781,560}}, {{872,96},{842,150},{826,202}} }) do
  ln(rnd, s, wcore, {0.6,0.4}, 0.7)
end
ln(rig, {{771,302},{768,370},{760,448}}, hot, {0.7,0.2})
ln(rig, {{806,150},{828,120},{850,100}}, wlit, {0.6,0.2})
ln(rig, {{900,40},{860,46},{820,66},{790,96}}, wlit, {0.7,0.2})
for _,g in ipairs({{770,330},{812,126},{756,160},{700,318},{794,92},{776,250}}) do stipple(ellipse(g[1],g[2],1.8,1.8), {pile=hot, width=2, coverage=3}) end
-- golden-angle rosette of bone studs on the breast
for i=1,38 do
  local a = i*2.39996; local r = 3.4*math.sqrt(i)
  local x, y = 832 + math.cos(a)*r, 360 + math.sin(a)*r*1.1
  local p = (x < 828) and bone or boneD
  stipple(ellipse(x,y,1.7,1.7), {pile=p, width=2.2, coverage=2})
end
stipple(ellipse(832,360,3,3), {pile=wcore, width=2.5, coverage=3})
-- bone studs in a line down the arm
for i=0,5 do stipple(ellipse(800-i*18, 246+i*12, 1.6,1.6), {pile=bone, width=2, coverage=2}) end
-- corruption: a cold outline of the head, shoulder and arm, displaced up and right
local ghost = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt violet",0.6}}
local g = brush{kind="rigger", width=1.6, point=1}
local function gl(pts) g:reload(ghost, 0.7); g:stroke(pts, {pressure={0.45,0.15}, ramps={0.1,0.3}}) end
gl({{766,128},{758,148},{758,172},{766,190}})
gl({{772,120},{800,104},{826,96}})
gl({{812,82},{850,72},{884,64}})
gl({{708,296},{740,276},{774,254},{806,236}})
gl({{696,312},{684,302},{672,298}})
gl({{780,290},{774,330},{780,372}})

--@ chunk 52
-- PASS 2 / F: each lit plate graded from core shadow to the hot edge facing the discharge
local mdk = pile{{"bone black",1.4},{"ultramarine ash",1.2},{"ultramarine blue",0.6},{"zinc white",0.25}}
local mid = pile{{"bone black",1},{"ultramarine ash",2},{"zinc white",1.0},{"cobalt violet",0.3}}
local lt = pile{{"zinc white",2.2},{"ultramarine ash",1},{"cerulean blue",0.2}}
local br = pile{{"zinc white",4},{"cerulean blue",0.25},{"lemon chrome",0.05}}
local skip = {pelvis=true, muzzle=true, bfoot=true, ffoot=true}
for k,m in pairs(PL) do
  if not skip[k] then
    local c = PC[k]; local a = ANG[k]
    local function an(x,y) return a+0.15*math.sin(x*0.1+y*0.07) end
    local t = {kind="filbert", width=2.5, point=0.4}
    local h1 = hp(c[1],c[2],-0.35,c[3]); local h2 = hp(c[1],c[2],0.05,c[3]); local h3 = hp(c[1],c[2],0.5,c[3])
    work(m * (-h1), {hand="body", tool=t, pile=mdk, angle=an, coverage=3, fill=true, clip=m, length={4,12}})
    work(m * h1 * (-h2), {hand="body", tool=t, pile=mid, angle=an, coverage=3, fill=true, clip=m, length={4,12}})
    work(m * h2 * (-h3), {hand="body", tool=t, pile=lt, angle=an, coverage=3, fill=true, clip=m, length={4,12}})
    work(m * h3, {hand="body", tool=t, pile=br, angle=an, coverage=3, fill=true, clip=m, length={4,12}})
  end
end

--@ chunk 53
-- PASS 2 / G: on dry paint: restate seams, rim varying with form, hard glints
print(wait(2*24*60))
local br = pile{{"zinc white",4},{"cerulean blue",0.25},{"lemon chrome",0.05}}
-- chest lames and plate breaks
ln(rnd, {{338,196},{368,190},{392,194}}, seam, {0.6,0.4}); ln(rig, {{346,200},{370,195},{390,199}}, br, {0.1,0.6})
ln(rnd, {{342,226},{366,222},{384,226}}, seam, {0.6,0.4}); ln(rig, {{350,230},{368,226},{382,230}}, br, {0.1,0.5})
ln(rnd, {{372,170},{390,162},{410,170},{420,186}}, seam, {0.6,0.4}); ln(rig, {{392,168},{410,175},{419,190}}, br, {0.1,0.6})
ln(rnd, {{396,226},{412,224}}, seam, {0.6,0.4})
ln(rnd, {{376,340},{392,334},{410,350}}, seam, {0.6,0.4}); ln(rig, {{392,340},{410,356}}, br, {0.1,0.5})
ln(rnd, {{398,384},{418,376},{432,388}}, seam, {0.6,0.4})
ln(rnd, {{420,396},{432,394},{444,402},{444,418},{432,424},{420,418}}, seam, {0.6,0.5})
ln(rnd, {{408,470},{424,466},{432,474}}, seam, {0.6,0.4})
ln(rnd, {{262,380},{290,372}}, seam, {0.6,0.4}); ln(rnd, {{250,416},{262,412},{272,420},{268,434},{254,438}}, seam, {0.6,0.5})
ln(rnd, {{226,470},{246,476}}, seam, {0.6,0.5})
-- rims: thick where the plate turns edge-on to the discharge, thinning where it turns toward us
ln(rig, {{358,70},{367,86},{372,100}}, hot, {0.2,0.9})
ln(rig, {{386,148},{404,144},{420,160},{424,182}}, hot, {0.9,0.2})
ln(rig, {{414,186},{416,212},{414,236}}, hot, {0.6,0.1})
ln(rig, {{372,306},{400,330},{422,358},{444,392}}, hot, {0.1,0.9})
ln(rig, {{443,420},{437,446},{426,472}}, hot, {0.9,0.1})
ln(rig, {{328,333},{306,366},{290,396}}, hot, {0.7,0.1})
ln(rig, {{268,426},{250,458},{236,484}}, hot, {0.6,0.05})
ln(rig, {{396,152},{398,178},{392,210}}, br, {0.5,0.1})
-- hard glints
for _,gp in ipairs({{369,92},{415,160},{422,178},{443,402},{440,394},{415,206},{394,148},{430,368},{386,150},{536,240},{271,422}}) do
  local s = brush{kind="round", width=2.8, point=1}; s:load(hot, 1.0)
  s:stroke({{gp[1]-2.5,gp[2]+1},{gp[1]+2.5,gp[2]-1}}, {pressure={1.0,0.1}})
  stipple(ellipse(gp[1],gp[2],1.2,1.2), {pile=hot, width=1.5, coverage=2})
end
-- visor slit and helm comb again
ln(rnd, {{350,104},{364,106},{377,104}}, gun, {0.8,0.6}, 0.9)
ln(rig, {{352,86},{368,88},{379,96}}, hot, {0.7,0.3})
ln(rnd, {{306,84},{318,68},{336,60},{352,62}}, gun, {0.8,0.6}, 0.9)
-- gun housing edge and barrel break
ln(rnd, {{382,250},{386,314}}, gun, {0.5,0.5}); ln(rnd, {{455,244},{458,276}}, gun, {0.6,0.6})
-- husk sensor eyes
stipple(ellipse(600,371,3,3), {pile=hot, width=2.5, coverage=3})
stipple(ellipse(678,404,2,2), {pile=hot, width=2, coverage=3})
-- the Warden's rosette, studs restated larger with their own shadows
local bone = pile{{"zinc white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local boneD = pile{{"yellow ochre",1.5},{"raw sienna",1},{"zinc white",0.5}}
local wcore = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}}
for i=1,34 do
  local a = i*2.39996; local r = 3.6*math.sqrt(i)
  local x, y = 832 + math.cos(a)*r, 360 + math.sin(a)*r*1.1
  stipple(ellipse(x+1.2,y+1.2,2,2), {pile=wcore, width=2.2, coverage=2})
  stipple(ellipse(x,y,2,2), {pile=(x < 830) and bone or boneD, width=2.4, coverage=2.5})
end

--@ chunk 54
-- PASS 2 / H: the ribs of the corridor catch the discharge, strongest nearest it
local ribL = pile{{"ultramarine ash",1.5},{"zinc white",1.6},{"cobalt violet",0.4},{"bone black",0.3}}
local ribD = pile{{"bone black",2},{"ultramarine blue",1}}
local L = {660,185}
local block = CMD:grow(3) + WAR:grow(3) + (NIMB or WAR)
for k,s in ipairs({0.5,0.66,0.86,1.1}) do
  local n = 40
  for i=0,n-1 do
    local a0 = math.pi*(1.02 + 0.96*i/n); local a1 = math.pi*(1.02 + 0.96*(i+1)/n)
    local x0,y0 = 640+math.cos(a0)*430*s, 280+math.sin(a0)*310*s
    local x1,y1 = 640+math.cos(a1)*430*s, 280+math.sin(a1)*310*s
    local d = math.sqrt(((x0+x1)/2-L[1])^2 + ((y0+y1)/2-L[2])^2)
    local f = math.exp(-d/170)
    if f > 0.12 and block:at((x0+x1)/2,(y0+y1)/2) < 0.5 then
      local b = brush{kind="round", width=3+3*k*f, point=0.5}
      b:load(ribL, 0.25 + 0.6*f)
      b:stroke({{x0,y0},{x1,y1}}, {pressure={0.25+0.5*f, 0.25+0.5*f}, ramps={0.2,0.2}, clip=-block})
      local b2 = brush{kind="round", width=2+2*k, point=0.5}; b2:load(ribD, 0.6)
      local ox, oy = (x0-640)*0.02, (y0-280)*0.02
      b2:stroke({{x0+ox,y0+oy},{x1+ox,y1+oy}}, {pressure={0.4,0.4}, clip=-block})
    end
  end
end

--@ chunk 55
print(wait(24*60))
local ribM = pile{{"ultramarine ash",1.5},{"bone black",1},{"zinc white",0.7},{"cobalt violet",0.3}}
local L = {660,185}
local block = CMD:grow(3) + WAR:grow(3) + NIMB
for k,s in ipairs({0.5,0.66,0.86,1.1}) do
  local pts = {}
  for i=0,80 do
    local a = math.pi*(1.02 + 0.96*i/80)
    local x,y = 640+math.cos(a)*430*s, 280+math.sin(a)*310*s
    local d = math.sqrt((x-L[1])^2 + (y-L[2])^2)
    if math.exp(-d/170) > 0.1 then pts[#pts+1] = {x,y} end
  end
  if #pts > 2 then
    local b = brush{kind="round", width=4+2*k, point=0.5}
    b:load(ribM, 0.9)
    b:stroke(pts, {pressure={0.55,0.55}, swell={0.3,0.8,1.2,0.8,0.3}, ramps={0.25,0.25}, clip=-block})
    b:reload(ribM, 0.9)
    b:stroke(pts, {pressure={0.5,0.5}, swell={0.3,0.8,1.1,0.8,0.3}, ramps={0.25,0.25}, clip=-block})
  end
end

--@ chunk 56
-- corruption: a cold, displaced second contour of the Warden's head, crown and reaching arm
local ghost = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt violet",0.7}}
local g = brush{kind="round", width=3, point=0.8}
local function gl(pts, pr) g:reload(ghost, 0.8); g:stroke(pts, {pressure=pr or {0.6,0.2}, ramps={0.1,0.3}}) end
gl({{770,124},{762,146},{762,172},{770,192},{782,204}})
gl({{774,118},{804,100},{834,90},{866,78}}, {0.5,0.1})
gl({{820,240},{786,256},{752,280},{718,302},{702,314}})
gl({{702,314},{688,304},{676,300}}, {0.5,0.1}); gl({{700,320},{684,318},{670,322}}, {0.5,0.1})
gl({{784,296},{778,340},{784,380}}, {0.4,0.05})

--@ chunk 57
print(wait(24*60))
local wl = pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.8}}
local m = WAR * poly({{740,480},{800,470},{800,562},{740,562}})
work(m - ribbon({{752,470},{746,520}}, 4), {hand="body", tool={kind="filbert",width=4,point=0.4}, pile=wl, coverage=3, fill=true, clip=WAR, angle=1.6, length={8,22}, edge="soft"})
