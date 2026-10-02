-- easel session "combat2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=1.9, linen=18, seed=11,
  ground={{pile={{"bone black",3},{"ultramarine blue",2},{"burnt sienna",1},{"lead white",0.6}}, um=80, apply="knife", texture=0.3}}}

--@ chunk 2
dk = pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",1}}
dkw = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",1},{"zinc white",0.3}}
wallc = pile{{"zinc white",1},{"ultramarine ash",1},{"bone black",1.2}}
floorl = pile{{"zinc white",2},{"ultramarine ash",1},{"bone black",0.5}}
FAR = {{552,165},{722,150},{735,290},{560,305}}
local far = poly(FAR)
local floor = poly{{560,305},{735,290},{1100,470},{1100,560},{-100,560}}
local ceil = poly{{552,165},{722,150},{1100,-60},{-100,-20}}
local lw = poly{{552,165},{560,305},{-100,560},{-100,-20}}
local rw = poly{{722,150},{735,290},{1100,470},{1100,-60}}
work(far, {hand="body", pile=dk, coverage=3, fill=true, clip=true})
work(ceil, {hand="broad", pile=dk, coverage=2.5, fill=true, clip=true, angle=-0.3})
work(lw, {hand="broad", pile=dkw, coverage=2.5, fill=true, clip=true, angle=-0.45})
work(rw, {hand="broad", pile=dkw, coverage=2.5, fill=true, clip=true, angle=0.5})
work(floor, {hand="broad", pile=dkw, coverage=2.5, fill=true, clip=true, angle=0.1})

--@ chunk 3
local floor = poly{{560,305},{735,290},{1100,470},{1100,560},{-100,560}}
local lw = poly{{552,165},{560,305},{-100,560},{-100,-20}}
local rw = poly{{722,150},{735,290},{1100,470},{1100,-60}}
local ceil = poly{{552,165},{722,150},{1100,-60},{-100,-20}}
local big = (ellipse(560,370,380,120) * floor + ellipse(470,250,200,150)*lw + ellipse(780,250,130,170)*rw + ellipse(560,110,260,70)*ceil):roughen(20,90,3)
local small = (ellipse(570,350,220,55)*floor + ellipse(520,250,70,90)*lw + ellipse(745,240,45,90)*rw):roughen(12,60,4)
work(big, {hand="body", pile=wallc, coverage=2.5, fill=true, edge="lost", angle=function(x,y) return math.atan(y-265, x-590) end})
work(small, {hand="body", pile=floorl, coverage=2.5, fill=true, edge="soft", angle=function(x,y) return math.atan(y-265, x-590) end})
print(wait(30*60))

--@ chunk 4
local ring = (everywhere() - ellipse(585,300,300,105):roughen(25,80,5) - ellipse(590,240,170,150):roughen(20,70,6))
work(ring, {hand="body", pile=dk, coverage=2.5, fill=true, edge="soft", angle=function(x,y) return math.atan(y-265, x-590)+1.57 end})
bzd = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
bzm = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
bzl = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
WARDEN = poly({{640,120},{700,62},{772,78},{842,130},{872,220},{852,320},{822,382},{834,472},{772,478},{752,392},{702,392},{690,472},{628,472},{638,372},{606,300},{616,200}}, true)
ARM = ribbon({{650,150},{600,190},{585,225},{566,250}}, {44,36,30,22}) + ribbon({{566,250},{548,262}},6)+ribbon({{566,250},{552,274}},6)+ribbon({{570,252},{566,282}},5)
local nimbus = ellipse(712,105,92,82) - WARDEN
local W = WARDEN + ARM
work(nimbus, {hand="body", pile=bzd, coverage=2.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-105,x-712)+1.57 end})
work(W, {hand="body", pile=bzd, coverage=2.6, fill=true, clip=true, angle=function(x,y) return math.atan(y-300,x-740)+1.57 end})
local lit = W * ellipse(590,250,120,200):roughen(10,50,7)
work(lit, {hand="body", pile=bzm, coverage=2, fill=true, clip=true, edge="soft", angle=function(x,y) return math.atan(y-265,x-590)+1.57 end})

--@ chunk 5
wait(2*24*60)
bzk = pile{{"bone black",3},{"burnt sienna",1},{"yellow ochre",0.6}}
local oldW = WARDEN + ARM + ellipse(712,105,95,85)
NEWW = poly{{600,172},{636,124},{660,74},{700,44},{748,54},{778,96},{842,118},{888,190},{882,300},{852,362},{862,472},{792,478},{776,402},{722,402},{716,472},{640,472},{654,382},{614,322},{604,252}}
ARM2 = ribbon({{656,150},{612,182},{590,215},{560,248}}, {50,42,34,24}) + ribbon({{562,248},{536,252}},7)+ribbon({{560,250},{540,272}},7)+ribbon({{566,254},{560,284}},6)
local ring = (ellipse(712,92,100,90) - ellipse(712,92,76,68)) - NEWW
local cover = oldW:grow(4) - NEWW - ARM2 - ring
work(cover, {hand="body", pile=dk, coverage=3, fill=true, clip=true, angle=0.3})
work(NEWW + ARM2, {hand="body", pile=bzk, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-300,x-740)+1.57 end})
work(ring, {hand="body", pile=bzk, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-92,x-712)+1.57 end})

--@ chunk 6
arm = pile{{"bone black",2},{"ultramarine blue",1},{"zinc white",0.35}}
armd = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
tab = pile{{"Mars red",2},{"bone black",1.2}}
gun = pile{{"bone black",2},{"Mars brown",1},{"zinc white",0.3}}
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=2.8, fill=true, clip=true, angle=ang}) end
C = {}
C.legB = ribbon({{210,330},{150,400},{92,462},{58,500}}, {58,50,40,34}) + poly{{30,490},{75,488},{88,526},{18,526}}
C.legF = ribbon({{262,335},{318,405},{312,470},{300,526}}, {60,50,40,36})
C.hips = poly{{182,292},{278,286},{290,348},{186,354}}
C.torso = poly{{146,150},{252,132},{290,190},{274,300},{186,312},{158,242}}
C.head = ellipse(196,104,36,42)
C.pR = poly{{226,135},{272,128},{300,160},{288,192},{240,180}}
C.pL = poly{{128,148},{176,136},{190,180},{150,196},{124,180}}
C.arm = ribbon({{280,180},{320,225},{338,262}}, {34,30,26}) + ribbon({{165,190},{200,250},{250,268}}, {30,26,24})
C.tab = poly{{196,300},{282,298},{340,372},{318,402},{278,368},{246,416},{206,372}}
C.gun = ribbon({{232,272},{330,258},{436,244}}, {50,44,30}) + ellipse(268,272,44,38) + poly{{300,276},{330,272},{326,306},{306,306}}
part(C.legB, armd, -0.85)
part(C.legF, armd, 1.2)
part(C.tab, tab, 1.0)
part(C.hips, arm, 0)
part(C.torso, arm, 1.4)
part(C.pR, arm, 0.3)
part(C.pL, armd, 0.3)
part(C.head, armd, 1.5)
part(C.arm, arm, 0.9)
part(C.gun, gun, -0.13)

--@ chunk 7
wait(3*24*60)
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
tab2 = pile{{"bone black",3},{"red earth",1.2}}
gun2 = pile{{"bone black",3},{"Mars brown",1}}
part(C.tab, tab2, 1.0)
part(C.hips, armd, 0)
part(C.torso, armd, 1.4)
part(C.pR, armd, 0.3)
part(C.arm, armd, 0.9)
part(C.gun, gun2, -0.13)
-- warden lit facets
local facets = poly{{604,252},{614,322},{654,382},{676,372},{652,300},{640,226}}
  + poly{{638,124},{660,74},{678,120},{652,172}}
  + poly{{662,74},{700,44},{714,58},{684,108}}
  + ribbon({{650,140},{606,176},{584,210},{558,244}}, {14,12,10,8})
  + ribbon({{646,384},{642,470}}, 12)
part(facets, bzm, 1.3)
part(facets:shrink(4) * ellipse(560,260,130,140), bzl, 1.3)
bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
boned = pile{{"yellow ochre",1},{"lead white",1},{"bone black",0.6}}
local r = brush{kind="round", width=5, point=0.6}
local ga = 2.39996
for i = 1, 34 do
  local rr = 7 * math.sqrt(i)
  local x, y = 735 + rr*math.cos(i*ga), 225 + rr*math.sin(i*ga)*1.15
  local p = (x < 725) and bone or boned
  r:reload(p, 0.6)
  r:touch(x, y, {pressure=0.7})
end
-- bone lancet down the chest
local b3 = brush{kind="round", width=3, point=0.8}
b3:reload(boned, 0.7)
b3:stroke({{700,280},{708,320},{712,360}}, {pressure={0.8,0.3}})
b3:reload(boned, 0.7)
b3:stroke({{742,90},{746,105},{740,118}}, {pressure={0.9,0.4}})

--@ chunk 8
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
husk = pile{{"bone black",2},{"viridian",0.4},{"burnt sienna",1}}
huskl = pile{{"bone black",1},{"viridian",0.4},{"zinc white",1},{"ultramarine ash",0.5}}
-- husk 1 shadow toward viewer
part(ribbon({{462,398},{400,440},{330,486}}, {26,36,50}):roughen(4,30,2), dk, 2.5)
part(ribbon({{496,396},{450,450},{400,500}}, {14,22,30}), dk, 2.2)
H1 = poly{{438,300},{492,290},{504,350},{448,360}} + ellipse(468,282,15,12) + ribbon({{456,356},{462,380},{448,402}},{12,10,8}) + ribbon({{490,350},{488,376},{500,398}},{12,10,8}) + ribbon({{498,310},{516,322},{524,340}},{9,8,6})
part(H1, husk, 1.5)
H2 = poly{{878,246},{944,236},{958,322},{890,334}} + ellipse(908,228,18,14) + ribbon({{896,330},{886,380},{898,432}},{16,13,10}) + ribbon({{940,322},{948,376},{940,430}},{16,13,10}) + ribbon({{882,262},{858,288},{846,310}},{12,10,8})
part(H2, husk, 1.5)
-- mites
local mb = brush{kind="filbert", width=7}
local pts = {{380,372},{412,392},{556,356},{598,372},{520,402},{350,415},{612,338},{445,425},{820,450},{860,470},{575,420}}
for _, q in ipairs(pts) do
  mb:reload(husk, 0.8)
  mb:touch(q[1], q[2], {pressure=0.8, drag={8, 0.2}})
  mb:reload(dk, 0.6)
  mb:stroke({{q[1]-2,q[2]+4},{q[1]-14,q[2]+16}}, {pressure={0.6,0.1}})
end
local lg = brush{kind="rigger", width=1.4, point=1}
for _, q in ipairs(pts) do
  lg:reload(husk, 0.6)
  lg:stroke({{q[1]-3,q[2]},{q[1]-8,q[2]+6}}, {pressure={0.5,0.1}})
  lg:stroke({{q[1]+3,q[2]},{q[1]+9,q[2]+6}}, {pressure={0.5,0.1}})
end
print(wait(3*24*60))

--@ chunk 9
CAB = {{436,244},{452,222},{470,204},{490,188},{508,178},{530,176},{548,184},{562,200},{568,220},{566,240},{570,256},{584,268}}
local function part(m, p, ang) work(m, {hand="detail", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
-- the dark cable itself near the muzzle
local cb = brush{kind="round", width=7, point=0.3}
cb:reload(gun2, 0.9)
cb:stroke({CAB[1],CAB[2],CAB[3],CAB[4],CAB[5]}, {pressure={0.9,0.7}})
violet = pile{{"cobalt violet",1},{"ultramarine blue",1},{"zinc white",1.6}}
violet2 = pile{{"cobalt violet",1},{"cerulean blue",0.5},{"zinc white",3}}
local wid = {}
local pts = {}
for i = 3, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 4 + 24 * ((i-3)/(#CAB-3))^1.3 end
local sheath = ribbon(pts, wid):roughen(5, 18, 9)
-- ruptures: bulges along the latter half
local rup = ellipse(548,184,14,11) + ellipse(567,222,15,13) + ellipse(569,252,18,16) + ellipse(510,178,8,7) + ellipse(584,268,22,20)
sheath = sheath + rup:roughen(5,12,4)
work(sheath, {hand="body", tool={kind="filbert", width=5}, pile=violet, coverage=3, fill=true, clip=true, angle=0.5})
work(sheath:shrink(4), {hand="detail", pile=violet2, coverage=2.5, fill=true, angle=0.5})
print(wait(24*60*2))

--@ chunk 10
local figs = NEWW + ARM2 + H1 + C.legB + C.legF + C.hips + C.torso + C.head + C.pR + C.pL + C.arm + C.tab + C.gun
local pts, wid = {}, {}
for i = 3, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 4 + 24 * ((i-3)/(#CAB-3))^1.3 end
local cab = ribbon(pts, wid):grow(16) + ribbon({CAB[1],CAB[2],CAB[3]}, 12)
local zone = (ellipse(560,280,360,200) - ellipse(565,355,150,40):roughen(10,40,3) - ellipse(575,240,70,80):roughen(10,40,8)) - figs - cab
midv = pile{{"bone black",2},{"ultramarine blue",1},{"cobalt violet",1},{"zinc white",0.5}}
work(zone, {hand="body", pile=midv, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})

--@ chunk 11
wait(3*24*60)
local figs = NEWW + ARM2 + H1 + C.legB + C.legF + C.hips + C.torso + C.head + C.pR + C.pL + C.arm + C.tab + C.gun
local pts, wid = {}, {}
for i = 3, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 4 + 24 * ((i-3)/(#CAB-3))^1.3 end
local cab = ribbon(pts, wid):grow(16) + ribbon({CAB[1],CAB[2],CAB[3]}, 12)
local zone = (ellipse(560,280,372,212) - ellipse(565,265,200,125):roughen(30,70,12)) - figs - cab
work(zone, {hand="body", pile=dk, coverage=3.2, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
-- middle falloff band: darker violet between
local band = (ellipse(565,265,215,135):roughen(20,60,13) - ellipse(565,262,130,90):roughen(20,50,14) - ellipse(565,355,150,40):roughen(10,40,3)) - figs - cab
midv2 = pile{{"bone black",2},{"ultramarine blue",1},{"cobalt violet",1}}
work(band, {hand="body", pile=midv2, coverage=2.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
print(wait(2*24*60))

--@ chunk 12
hot = pile{{"zinc white",3},{"lemon chrome",0.15}}
hotv = pile{{"zinc white",3},{"cobalt violet",0.6},{"cerulean blue",0.3}}
-- violet glow halo around latter cable, light glaze
local pts, wid = {}, {}
for i = 4, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 10 + 40 * ((i-4)/(#CAB-4)) end
local halo = ribbon(pts, wid):soften(10)
work(halo, {hand="glaze", tool={kind="filbert", width=12, stiffness=0.2}, pile=pile{{"zinc white",2},{"cobalt violet",1},{"ultramarine blue",0.4}, medium=0.5}, load=0.25, pressure={0.1,0.22}, coverage=1.2, length={20,50}, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
-- core: broken segments, thickening
local core = brush{kind="round", width=7, point=0.8}
local segs = {{3,6,0.2,0.45},{6,8,0.45,0.7},{8,10,0.65,0.9},{10,12,0.85,1.0}}
for _, s in ipairs(segs) do
  local p = {}
  for i = s[1], s[2] do p[#p+1] = {CAB[i][1] + rand(-1.5,1.5), CAB[i][2] + rand(-1.5,1.5)} end
  core:reload(hot, 0.9)
  core:stroke(p, {pressure={s[3], s[4]}, swell={1,1.3,0.8,1.2}})
end
-- beads
local bb = brush{kind="round", width=9, point=0.3}
local beads = {{508,178,0.5},{531,174,0.6},{549,186,0.8},{563,205,0.7},{568,224,0.95},{566,243,0.9},{573,258,1},{584,268,1}}
for _, q in ipairs(beads) do bb:reload(hot, 0.9); bb:touch(q[1], q[2], {pressure=q[3]}) end

--@ chunk 13
local figs = NEWW + ARM2 + H1 + C.legB + C.legF + C.hips + C.torso + C.head + C.pR + C.pL + C.arm + C.tab + C.gun
local pts, wid = {}, {}
for i = 3, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 4 + 24 * ((i-3)/(#CAB-3))^1.3 end
local cab = ribbon(pts, wid):grow(5) + ribbon({CAB[1],CAB[2],CAB[3]}, 10)
local near = ribbon(pts, wid):grow(34):roughen(10,30,21)
local pocket = (ellipse(560,262,150,108):roughen(14,50,22) - ellipse(560,350,140,34):roughen(10,40,23)) - figs - cab
glowv = pile{{"cobalt violet",1},{"ultramarine blue",1},{"bone black",1.5},{"zinc white",0.3}}
work(pocket - near, {hand="body", pile=midv2, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
work(pocket * near, {hand="body", pile=glowv, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
local pool = ellipse(560,352,145,36):roughen(10,40,23) - figs
work(pool, {hand="body", pile=wallc, coverage=3, fill=true, clip=true, angle=0.05})

--@ chunk 14
print(wait(3*24*60))
rim = pile{{"zinc white",2},{"ultramarine ash",0.4},{"cerulean blue",0.1}}
rimw = pile{{"zinc white",3},{"lemon chrome",0.1}}
local rg = brush{kind="rigger", width=2.6, point=1}
local function line(p, pl, pr) rg:reload(pl, 0.8); rg:stroke(p, {pressure=pr or {0.8,0.2}}) end
-- commando rims
line({{220,78},{232,104},{226,136}}, rim)
line({{268,128},{300,160},{290,192}}, rimw, {0.9,0.4})
line({{292,196},{284,250},{276,300}}, rim, {0.7,0.3})
line({{298,186},{322,212},{340,250}}, rim, {0.6,0.8})
line({{240,248},{330,236},{434,222}}, rimw, {0.5,1.0})
line({{438,226},{442,246},{436,262}}, rimw, {0.9,0.5})
line({{280,288},{292,346}}, rim, {0.6,0.3})
line({{290,330},{345,398},{338,470},{322,526}}, rim, {0.8,0.2})
line({{238,338},{176,402},{116,462},{84,498}}, rim, {0.5,0.15})
line({{284,300},{342,372},{320,402}}, rim, {0.6,0.2})
-- husk rim
line({{493,290},{505,350}}, rimw, {0.9,0.5}); line({{478,272},{484,290}}, rimw, {0.8,0.3})
line({{506,352},{490,376},{500,398}}, rim, {0.5,0.2})
-- warden hot edges
line({{604,252},{614,322},{654,382}}, rimw, {1.0,0.3})
line({{650,140},{606,176},{584,210},{558,244}}, rimw, {0.5,1.0})
line({{604,252},{620,196},{638,124}}, rim, {0.9,0.3})
line({{640,124},{662,74},{700,44}}, rim, {0.6,0.2})
-- floor: husk shadows across the pool toward us, lose its edge
local sh = ribbon({{458,392},{420,420},{380,452}}, {12,18,26}) + ribbon({{498,394},{480,425},{455,460}}, {10,14,20})
work(sh, {hand="detail", pile=dk, coverage=3, fill=true, clip=true})
lose(ellipse(560,352,145,36), {pile=dk, where=1, load=0.4})

--@ chunk 15
print(wait(2*24*60))
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
-- cover the over-long back-leg rim
part(ribbon({{238,338},{176,402},{116,462},{84,498}}, 9), armd, -0.85)
-- lit planes facing the discharge
local helm = C.head * poly{{205,60},{240,60},{240,150},{214,150}}
local pr = C.pR * poly{{260,120},{310,120},{310,200},{276,200}}
local tor = C.torso * poly{{262,140},{300,140},{300,310},{252,310},{240,200}}
local gunt = C.gun * poly{{300,220},{440,200},{440,240},{300,262}}
local hip = C.hips * poly{{258,280},{300,280},{300,360},{262,360}}
local legf = C.legF * poly{{290,320},{360,380},{360,526},{318,526},{318,430},{280,350}}
local tabr = C.tab * poly{{290,290},{350,360},{340,410},{300,340}}
part(helm, arm, 1.5); part(pr, arm, 0.4); part(tor, arm, 1.5); part(gunt, gun, -0.13)
part(hip, arm, 1.4); part(legf, arm, 1.3); part(tabr, tab, 0.9)
-- calm the dashed pool edge
local ringb = (ellipse(560,352,158,44) - ellipse(560,350,128,28):roughen(8,40,31)) - (NEWW + H1 + C.legF)
work(ringb, {hand="body", pile=midv2, coverage=3, fill=true, clip=true, edge="soft", angle=0.05})

--@ chunk 16
local pts, wid = {}, {}
for i = 3, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 8 + 36 * ((i-3)/(#CAB-3))^1.2 end
local sheath2 = ribbon(pts, wid):roughen(8, 22, 41)
local inner = ribbon(pts, wid):shrink(6)
local outer = sheath2 - inner
violet3 = pile{{"cobalt violet",1.2},{"ultramarine blue",1},{"zinc white",1.2}}
work(outer, {hand="detail", pile=violet3, coverage=2.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
-- rupture flares: short tapered radial strokes off the cable
local fb = brush{kind="round", width=4, point=1}
local flares = {{530,176,-1.6,18},{548,184,-0.9,24},{562,200,-0.3,22},{568,224,0.1,28},{566,242,2.8,26},{572,258,2.2,30},{584,268,1.2,26},{584,268,-0.5,30},{508,178,-2.0,14},{490,188,2.4,10}}
for _, f in ipairs(flares) do
  local x, y, a, L = f[1], f[2], f[3], f[4]
  fb:reload(violet2, 0.8)
  fb:stroke({{x,y},{x+L*0.5*math.cos(a)+rand(-3,3), y+L*0.5*math.sin(a)+rand(-3,3)},{x+L*math.cos(a), y+L*math.sin(a)}}, {pressure={0.9,0.0}})
end
print(wait(2*24*60))

--@ chunk 17
local core = brush{kind="round", width=9, point=0.8}
local p = {}
for i = 4, #CAB do p[#p+1] = {CAB[i][1], CAB[i][2]} end
core:reload(hot, 1.0)
core:stroke(p, {pressure={0.25, 1.0}, swell={1,0.7,1.3,0.8,1.4,1}})
core:reload(hot, 1.0)
core:stroke({p[5],p[6],p[7],p[8],p[9]}, {pressure={0.8, 1.0}})
local bb = brush{kind="round", width=12, point=0.2}
for _, q in ipairs({{530,175,0.4},{549,186,0.6},{567,222,0.8},{572,256,1},{586,268,1}}) do bb:reload(hot, 1.0); bb:touch(q[1], q[2], {pressure=q[3]}) end
-- pilot sparks: jagged feelers from the dart to the warden's bronze
spark = pile{{"zinc white",3},{"cobalt violet",0.25}}
local rg = brush{kind="rigger", width=1.6, point=1}
local function zig(x0,y0,x1,y1,n,amp)
  local q = {{x0,y0}}
  for k = 1, n-1 do
    local t = k/n
    q[#q+1] = {lerp(x0,x1,t)+rand(-amp,amp), lerp(y0,y1,t)+rand(-amp,amp)}
  end
  q[#q+1] = {x1,y1}
  return q
end
local targets = {{608,250},{612,292},{632,330},{606,214},{560,248},{640,240},{618,360},{596,310}}
for _, t in ipairs(targets) do
  rg:reload(spark, 0.9)
  rg:stroke(zig(588,268,t[1],t[2],5,6), {pressure={0.9,0.2}, ramps={0.02,0.3}})
end
-- forked side arcs off the cable
for _, s in ipairs({{548,184,520,140},{566,224,600,190},{562,200,590,160},{572,258,540,300},{530,176,505,140}}) do
  rg:reload(spark, 0.8)
  rg:stroke(zig(s[1],s[2],s[3],s[4],4,5), {pressure={0.7,0.05}})
end

--@ chunk 18
local pts, wid = {}, {}
for i = 4, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 40 + 90 * ((i-4)/(#CAB-4)) end
local haze = (ribbon(pts, wid) + ellipse(586,268,70,60)):soften(20) - (NEWW + ARM2):shrink(3)
haze_p = pile{{"zinc white",2},{"cobalt violet",1},{"cerulean blue",0.3}, medium=0.25}
work(haze, {hand="glaze", tool={kind="filbert", width=10, stiffness=0.2}, pile=haze_p, load=0.35, pressure={0.15,0.35}, coverage=1.6, length={15,40}, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
print(wait(24*60))
local rg = brush{kind="rigger", width=1.8, point=1}
local function bolt(x0,y0,x1,y1,n,amp,pr)
  local px, py = x0, y0
  local pr0 = pr
  for k = 1, n do
    local t = k/n
    local nx, ny = lerp(x0,x1,t), lerp(y0,y1,t)
    if k < n then nx, ny = nx + rand(-amp,amp), ny + rand(-amp,amp) end
    rg:reload(spark, 0.9)
    rg:stroke({{px,py},{nx,ny}}, {pressure={pr0, pr0*0.8}, ramps={0.0,0.1}})
    pr0 = pr0 * 0.8
    px, py = nx, ny
  end
end
local targets = {{610,248},{614,296},{636,334},{606,212},{644,236},{620,364},{600,322},{648,280}}
for _, t in ipairs(targets) do bolt(588,268,t[1],t[2],6,7,0.9) end
for _, s in ipairs({{548,184,512,130},{566,224,612,186},{560,200,588,150},{572,258,532,306},{526,176,496,136},{586,268,560,320}}) do bolt(s[1],s[2],s[3],s[4],5,6,0.7) end

--@ chunk 19
local pts, wid = {}, {}
for i = 4, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 40 + 90 * ((i-4)/(#CAB-4)) end
local haze = (ribbon(pts, wid) + ellipse(586,268,70,60)):soften(20) - (NEWW + ARM2):shrink(3)
blend(haze:grow(4), {angle=function(x,y) return math.atan(y-262,x-575)+1.57 end, clip=true})
blend(haze:grow(4), {angle=function(x,y) return math.atan(y-262,x-575) end, clip=true})
print(wait(2*24*60))

--@ chunk 20
local pts, wid, w2 = {}, {}, {}
for i = 4, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 40 + 90 * ((i-4)/(#CAB-4)); w2[#w2+1] = 10 + 26*((i-4)/(#CAB-4)) end
local haze = (ribbon(pts, wid) + ellipse(586,268,70,60)):soften(20) - (NEWW + ARM2):shrink(3)
local band = ribbon(pts, w2):soften(4)
vglaze = pile{{"cobalt violet",1},{"ultramarine blue",1.2},{"bone black",0.15}, medium=0.6}
work((haze - band:grow(8)):soften(6), {hand="glaze", pile=vglaze, load=0.5, pressure={0.2,0.4}, coverage=1.5, clip=true, angle=function(x,y) return math.atan(y-262,x-575)+1.57 end})
work(band - band:shrink(4), {hand="detail", pile=violet3, coverage=2.5, fill=true, clip=true})
print(wait(2*24*60))

--@ chunk 21
local figs = NEWW + ARM2 + H1 + C.legB + C.legF + C.hips + C.torso + C.head + C.pR + C.pL + C.arm + C.tab + C.gun
ribp = pile{{"bone black",1.5},{"ultramarine blue",1},{"cobalt violet",0.6},{"zinc white",0.35}}
ribl = pile{{"zinc white",1},{"ultramarine ash",1},{"cobalt violet",0.3},{"bone black",0.6}}
local fb = brush{kind="flat", width=7}
local function arc(cx, cy, r, ry, a0, a1, p, pr)
  local q = {}
  for k = 0, 12 do local a = lerp(a0, a1, k/12); q[#q+1] = {cx + r*math.cos(a), cy + ry*math.sin(a)} end
  fb:reload(p, 0.8)
  fb:stroke(q, {pressure=pr, orient="across", clip=-figs})
end
-- corridor ribs: arcs around the burst, lit on the side nearest it
arc(585,250,250,215,3.3,4.6,ribl,{0.3,0.8})
arc(585,250,250,215,4.6,6.0,ribp,{0.8,0.3})
arc(585,250,190,160,3.2,4.7,ribl,{0.4,0.9})
arc(585,250,190,160,4.7,6.1,ribl,{0.9,0.4})
arc(585,250,350,300,3.4,4.5,ribp,{0.2,0.7})
arc(585,250,350,300,4.5,5.4,ribp,{0.7,0.2})
-- floor seams converging to the far end
local rg = brush{kind="rigger", width=1.6, point=1}
for _, s in ipairs({{{610,318},{470,388}},{{640,320},{620,390}},{{590,316},{400,372}},{{660,318},{700,380}}}) do
  rg:reload(dk, 0.7); rg:stroke(s, {pressure={0.3,0.7}, clip=-figs})
end
-- cold specular on the warden's bronze nearest the discharge
local sp = brush{kind="filbert", width=4}
for _, s in ipairs({{{610,262},{616,300}},{{622,322},{640,352}},{{606,222},{612,250}},{{596,190},{606,175}},{{648,120},{660,90}}}) do
  sp:reload(rim, 0.7); sp:stroke(s, {pressure={0.8,0.2}})
end
-- the corruption: a violet ghost of the head and reaching arm, displaced
local gh = brush{kind="round", width=3, point=0.8}
ghost = pile{{"cobalt violet",1},{"zinc white",1.2},{"ultramarine blue",0.4}}
for _, s in ipairs({{{676,70},{716,40},{758,50},{790,92}},{{640,150},{596,184},{574,218}},{{690,62},{705,52}},{{790,98},{850,118}}}) do
  gh:reload(ghost, 0.6); gh:stroke({{s[1][1]-10,s[1][2]-8}, table.unpack(s, 2)}, {pressure={0.6,0.1}})
end

--@ chunk 22
hot2 = pile{{"zinc white",3},{"lemon chrome",0.35}}
-- the dart, dark metal, pointing into the warden
local dart = poly{{578,258},{606,266},{580,280},{584,269}}
work(dart, {hand="detail", pile=gun2, coverage=3, fill=true, clip=true})
-- core: warm-white line along the cable
local core = brush{kind="round", width=5, point=0.9}
local p = {}
for i = 4, #CAB-1 do p[#p+1] = {CAB[i][1]+rand(-1,1), CAB[i][2]+rand(-1,1)} end
p[#p+1] = {578,268}
core:reload(hot2, 1.0)
core:stroke(p, {pressure={0.3, 0.9}})
-- ruptures breaking through the sheath
local bb = brush{kind="round", width=10, point=0.3}
for _, q in ipairs({{506,178,0.4},{536,170,0.6},{556,190,0.7},{574,212,0.8},{560,236,0.9},{576,260,1}}) do bb:reload(hot2, 1.0); bb:touch(q[1], q[2], {pressure=q[3], drag={rand(4,8), rand(-3,3)}}) end
-- plasma beads flung off
local sm = brush{kind="round", width=4, point=0.5}
for k = 1, 22 do
  local i = math.random(5, #CAB)
  local a = rand(0, 6.28); local r = rand(14, 40)
  sm:reload(k % 3 == 0 and violet3 or hot, 0.8)
  sm:touch(CAB[i][1] + r*math.cos(a), CAB[i][2] + r*math.sin(a), {pressure=rand(0.3,0.8)})
end
-- the discharge edges the dart
local rg = brush{kind="rigger", width=1.4, point=1}
rg:reload(hot2, 0.8); rg:stroke({{578,257},{606,265}}, {pressure={0.8,0.3}})

--@ chunk 23
local fb = brush{kind="filbert", width=6}
for i = 5, #CAB-1 do
  local x, y = CAB[i][1], CAB[i][2]
  local dx, dy = CAB[i+1][1]-CAB[i-1][1], CAB[i+1][2]-CAB[i-1][2]
  local a = math.atan(dy, dx) + 1.5708
  local s = 1 + (i-5)/4
  for _, sg in ipairs({1, -1}) do
    local L = (10 + rand(0, 10)) * s
    local aa = a + rand(-0.4, 0.4)
    fb:reload(hot2, 0.9)
    fb:stroke({{x - sg*4*math.cos(aa), y - sg*4*math.sin(aa)}, {x + sg*L*0.6*math.cos(aa) + rand(-3,3), y + sg*L*0.6*math.sin(aa) + rand(-3,3)}, {x + sg*L*math.cos(aa+rand(-0.3,0.3)), y + sg*L*math.sin(aa)}}, {pressure={0.9, 0.0}})
  end
end
-- a hot heart where the dart bites
local bb = brush{kind="filbert", width=12}
bb:reload(hot2, 1.0); bb:touch(584, 266, {pressure=1.0, drag={10, 0.2}})
bb:reload(hot, 1.0); bb:touch(570, 250, {pressure=0.8, drag={8, 1.4}})

--@ chunk 24
local pts, wid = {}, {}
for i = 4, #CAB do pts[#pts+1] = CAB[i]; wid[#wid+1] = 50 + 60 * ((i-4)/(#CAB-4)) end
local zone = ribbon(pts, wid):soften(10) - (NEWW + ARM2):shrink(2)
blend(zone, {angle=function(x,y) return math.atan(y-262,x-575)+1.57 end, clip=true})
print(wait(2*24*60))

--@ chunk 25
local core = brush{kind="round", width=4.5, point=0.9}
local p = {}
for i = 3, #CAB-1 do p[#p+1] = {CAB[i][1], CAB[i][2]} end
p[#p+1] = {578,268}
core:reload(hot2, 1.0); core:stroke(p, {pressure={0.2, 0.9}})
core:reload(hot2, 1.0); core:stroke({p[6],p[7],p[8],p[9],p[10]}, {pressure={0.9, 1.0}})
local dart = poly{{578,259},{604,266},{580,278},{585,268}}
work(dart, {hand="detail", pile=gun2, coverage=3, fill=true, clip=true})
local rg = brush{kind="rigger", width=1.3, point=1}
rg:reload(hot2, 0.8); rg:stroke({{579,258},{605,265}}, {pressure={0.8,0.3}})
-- flickers along the still-intact cable near the muzzle
local sm = brush{kind="round", width=3, point=0.6}
for _, q in ipairs({{447,228},{458,214},{470,204},{481,195},{494,186}}) do sm:reload(violet3, 0.7); sm:touch(q[1]+rand(-2,2), q[2]+rand(-2,2), {pressure=0.5}) end
for _, q in ipairs({{466,206},{490,188}}) do sm:reload(hot, 0.7); sm:touch(q[1], q[2], {pressure=0.6}) end
-- crisp pilot sparks to the bronze
local function bolt(x0,y0,x1,y1,n,amp,pr)
  local px, py, p0 = x0, y0, pr
  for k = 1, n do
    local t = k/n
    local nx, ny = lerp(x0,x1,t), lerp(y0,y1,t)
    if k < n then nx, ny = nx + rand(-amp,amp), ny + rand(-amp,amp) end
    rg:reload(spark, 0.9); rg:stroke({{px,py},{nx,ny}}, {pressure={p0, p0*0.85}, ramps={0,0.05}})
    p0 = p0*0.85; px, py = nx, ny
  end
end
for _, t in ipairs({{618,240},{626,286},{612,312},{640,262},{616,212}}) do bolt(604,266,t[1],t[2],5,5,1.0) end

--@ chunk 26
-- mites skittering across the lit deck, shadows thrown toward us
local mb = brush{kind="filbert", width=6}
local lg = brush{kind="rigger", width=1.2, point=1}
for _, q in ipairs({{520,352},{548,366},{596,348},{640,360},{486,340},{612,374},{570,338}}) do
  local x, y = q[1], q[2]
  mb:reload(dk, 0.6); mb:stroke({{x-2,y+3},{x-12,y+16}}, {pressure={0.5,0.05}})
  mb:reload(husk, 0.9); mb:touch(x, y, {pressure=0.8, drag={7, rand(-0.4,0.4)}})
  for _, d in ipairs({{-6,4},{-2,6},{4,6},{8,3}}) do lg:reload(husk, 0.6); lg:stroke({{x+d[1]*0.4,y},{x+d[1],y+d[2]}}, {pressure={0.5,0.1}}) end
  lg:reload(rimw, 0.6); lg:stroke({{x+1,y-2},{x+6,y-2}}, {pressure={0.6,0.2}})
end
-- warden plate seams and lamellae
local sb = brush{kind="round", width=2.2, point=0.8}
for _, s in ipairs({{{690,130},{760,120},{830,140}},{{660,190},{700,200},{790,190},{860,200}},{{700,300},{760,310},{850,300}},{{690,330},{750,345},{840,335}},{{700,360},{760,372},{830,365}}}) do
  sb:reload(dk, 0.8); sb:stroke(s, {pressure={0.6,0.4}})
end
for _, s in ipairs({{{698,302},{702,330}},{{722,306},{726,340}},{{746,310},{748,344}},{{772,310},{774,342}},{{800,306},{802,338}}}) do
  sb:reload(dk, 0.8); sb:stroke(s, {pressure={0.5,0.3}})
end
-- tabard tails flung toward the warden by the backward run
local tb = brush{kind="filbert", width=9}
for _, s in ipairs({{{300,340},{340,352},{380,348}},{{290,372},{330,392},{372,396}},{{300,315},{344,320},{372,312}}}) do
  tb:reload(tab2, 0.9); tb:stroke(s, {pressure={0.9,0.1}})
end
local rg = brush{kind="rigger", width=1.8, point=1}
rg:reload(rim, 0.6); rg:stroke({{302,312},{344,317},{370,310}}, {pressure={0.5,0.1}})
-- husk 2 catches a little light
rg:reload(rim, 0.6); rg:stroke({{878,248},{890,332}}, {pressure={0.5,0.2}})
rg:reload(rim, 0.6); rg:stroke({{892,228},{900,218}}, {pressure={0.5,0.2}})
rg:reload(rim, 0.6); rg:stroke({{882,262},{858,288},{846,310}}, {pressure={0.5,0.2}})

--@ chunk 27
local rg = brush{kind="rigger", width=2, point=1}
rg:reload(rimw, 0.8); rg:stroke({{360,232},{400,227},{432,224}}, {pressure={0.3,0.9}})
rg:reload(rimw, 0.8); rg:stroke({{430,226},{436,236},{432,256}}, {pressure={0.9,0.4}})
local fb = brush{kind="filbert", width=4}
fb:reload(rim, 0.7); fb:stroke({{214,96},{226,94}}, {pressure={0.8,0.3}})
fb:reload(rim, 0.6); fb:stroke({{280,150},{292,166}}, {pressure={0.7,0.2}})
-- a glint on the warden's crown and the bronze nimbus edge nearest the light
fb:reload(rim, 0.6); fb:stroke({{628,80},{640,58},{660,40}}, {pressure={0.6,0.1}})

--@ chunk 28
local figs = NEWW + ARM2 + H1 + C.legF
local pool = ellipse(560,352,150,40) - ellipse(588,346,80,20):roughen(8,30,51) - figs
floord = pile{{"zinc white",1},{"ultramarine ash",1},{"bone black",2.2},{"cobalt violet",0.3}}
work(pool, {hand="body", pile=floord, coverage=2.2, fill=true, clip=true, edge="soft", angle=0.08})

--@ chunk 29
print(wait(4*24*60))
local figs = NEWW + ARM2 + H1 + C.legF + C.legB + C.tab
local outer = (ellipse(560,358,215,72) - ellipse(565,350,128,30):roughen(10,40,61)) - figs
work(outer, {hand="body", pile=dk, coverage=3, fill=true, clip=true, angle=0.08})
local mid = (ellipse(565,350,132,33):roughen(10,40,61) - ellipse(586,346,82,20):roughen(8,30,51)) - figs
work(mid, {hand="body", pile=midv2, coverage=2.2, fill=true, clip=true, angle=0.08})

--@ chunk 30
print(wait(3*24*60))
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
-- kill the grin: bronze over the belly seams
local seams = ribbon({{700,300},{760,310},{850,300}},8) + ribbon({{690,330},{750,345},{840,335}},8) + ribbon({{700,360},{760,372},{830,365}},8)
for _, x in ipairs({698,722,746,772,800}) do seams = seams + ribbon({{x+1,302},{x+3,342}},7) end
part(seams * NEWW, bzk, 0.1)
-- commando: dark bases on each armour form
armlit = pile{{"bone black",2},{"ultramarine ash",1},{"zinc white",0.4},{"burnt sienna",0.2}}
local helm = ellipse(198,104,36,42)
local pR = ellipse(262,160,40,31)
local breast = poly{{168,170},{250,150},{286,196},{276,296},{196,306},{172,240}}
local thighF = ribbon({{262,335},{318,405}}, {52,44})
local kneeF = ellipse(318,408,22,20)
local shinF = ribbon({{318,410},{312,470},{300,526}}, {40,36,34})
local thighB = ribbon({{210,330},{150,400}}, {54,46})
local kneeB = ellipse(148,404,22,20)
local shinB = ribbon({{148,404},{92,462},{58,500}}, {40,36,32})
for _, m in ipairs({breast, thighB, shinB, thighF, shinF}) do part(m, armd, 1.0) end
for _, m in ipairs({helm, pR, kneeF, kneeB}) do part(m, armd, 0.6) end
-- lit planes facing the burst (right side of each form), laid into the wet dark so they turn through a core shadow
part(helm * ellipse(214,98,24,36), armlit, 1.5)
part(pR * ellipse(276,152,26,22), armlit, 0.4)
part(breast * poly{{250,150},{286,196},{276,296},{252,300},{258,220},{236,160}}, armlit, 1.45)
part(thighF * ribbon({{276,322},{334,392}}, 18), armlit, 0.9)
part(kneeF * ellipse(330,402,12,14), armlit, 0.6)
part(shinF * ribbon({{332,414},{326,470},{316,526}}, 14), armlit, 1.5)
part(thighB * ribbon({{226,326},{168,392}}, 14), armlit, -0.85)
part(kneeB * ellipse(156,396,12,10), armlit, 0.6)
part(shinB * ribbon({{160,400},{106,456},{74,492}}, 10), armlit, -0.85)

--@ chunk 31
local forms = {
  {ellipse(198,104,36,42), 0.0},
  {ellipse(262,160,40,31), 0.0},
  {poly{{168,170},{250,150},{286,196},{276,296},{196,306},{172,240}}, 0.0},
  {ribbon({{262,335},{318,405}}, {52,44}), 2.47},
  {ribbon({{318,410},{312,470},{300,526}}, {40,36,34}), 0.0},
  {ribbon({{210,330},{150,400}}, {54,46}), 0.7},
  {ribbon({{148,404},{92,462},{58,500}}, {40,36,32}), 0.75},
}
for _, f in ipairs(forms) do blend(f[1]:shrink(2), {angle=f[2], clip=true, tool={kind="badger", width=14}}) end
print(wait(3*24*60))

--@ chunk 32
local function part(m, p, ang) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=ang}) end
local helm = ellipse(198,104,36,42)
local pR = ellipse(262,160,40,31)
local breast = poly{{168,170},{250,150},{286,196},{276,296},{196,306},{172,240}}
local thighF = ribbon({{262,335},{318,405}}, {52,44})
local shinF = ribbon({{318,410},{312,470},{300,526}}, {40,36,34})
local thighB = ribbon({{210,330},{150,400}}, {54,46})
local shinB = ribbon({{148,404},{92,462},{58,500}}, {40,36,32})
-- dark sides, away from the burst
part(helm * poly{{150,50},{200,50},{192,160},{150,160}}, armd, 1.5)
part(pR * poly{{215,120},{256,120},{250,200},{215,200}}, armd, 0.4)
part(breast * poly{{160,140},{232,140},{244,310},{160,320}}, armd, 1.45)
part(thighF * ribbon({{248,350},{302,422}}, 26), armd, 0.9)
part(shinF * ribbon({{298,414},{294,470},{282,526}}, 22), armd, 1.5)
part(thighB * ribbon({{196,346},{136,414}}, 30), armd, -0.85)
part(shinB * ribbon({{134,418},{80,474},{46,510}}, 24), armd, -0.85)
-- lit edges, crisp, facing the discharge
local fb = brush{kind="filbert", width=5}
local rg = brush{kind="rigger", width=1.8, point=1}
local edges = {
  {{224,70},{234,104},{226,140}}, {{268,130},{298,152},{298,182}}, {{254,152},{286,198},{278,294}},
  {{268,314},{304,350},{340,390}}, {{338,412},{332,470},{320,524}},
  {{228,314},{198,346},{168,382}}, {{164,392},{126,432},{96,462},{72,488}}, {{334,394},{344,410},{338,426}} }
for _, e in ipairs(edges) do
  fb:reload(armlit, 0.8); fb:stroke(e, {pressure={0.7,0.5}})
  rg:reload(rimw, 0.8); rg:stroke(e, {pressure={0.4,0.8,}})
end
-- visor slit, breastplate ridge, plate breaks
local sb = brush{kind="round", width=2.5, point=0.8}
sb:reload(dk, 0.9); sb:stroke({{190,100},{222,94}}, {pressure={0.8,0.5}})
rg:reload(hot2, 0.7); rg:stroke({{212,96},{222,94}}, {pressure={0.6,0.3}})
sb:reload(dk, 0.9); sb:stroke({{246,160},{252,230},{248,296}}, {pressure={0.5,0.5}})
rg:reload(armlit, 0.8); rg:stroke({{250,162},{256,230}}, {pressure={0.5,0.2}})
sb:reload(dk, 0.9); sb:stroke({{186,250},{270,244}}, {pressure={0.5,0.4}})
sb:reload(dk, 0.9); sb:stroke({{296,384},{326,368}}, {pressure={0.5,0.4}})
sb:reload(dk, 0.9); sb:stroke({{130,412},{164,384}}, {pressure={0.5,0.4}})

--@ chunk 33
local whip = {{438,244},{446,232},{456,219},{468,207},{481,196},{495,186},{508,178}}
local cb = brush{kind="round", width=6, point=0.3}
cb:reload(gun2, 0.9); cb:stroke(whip, {pressure={0.9,0.8}})
local vb = brush{kind="round", width=2.2, point=0.9}
local up, dn = {}, {}
for _, q in ipairs(whip) do up[#up+1] = {q[1]-3, q[2]-3}; dn[#dn+1] = {q[1]+3, q[2]+3} end
vb:reload(violet3, 0.8); vb:stroke(up, {pressure={0.2,0.9}})
vb:reload(violet3, 0.8); vb:stroke(dn, {pressure={0.1,0.7}})
-- beads rupturing along the whip, growing toward the burst
local fb = brush{kind="filbert", width=8}
local hb = brush{kind="round", width=4, point=0.4}
local rg = brush{kind="rigger", width=1.2, point=1}
for _, b in ipairs({{452,224,0.45},{474,201,0.7},{497,185,0.95}}) do
  fb:reload(violet3, 0.9); fb:touch(b[1], b[2], {pressure=b[3], drag={5, -0.7}})
  hb:reload(hot2, 1.0); hb:touch(b[1], b[2], {pressure=b[3]})
  for k = 1, 3 do
    local a = rand(0, 6.28); local L = rand(8, 16) * b[3] + 4
    rg:reload(spark, 0.8)
    rg:stroke({{b[1], b[2]}, {b[1] + L*0.5*math.cos(a) + rand(-2,2), b[2] + L*0.5*math.sin(a) + rand(-2,2)}, {b[1] + L*math.cos(a), b[2] + L*math.sin(a)}}, {pressure={0.7,0.05}})
  end
end
-- the core runs continuous from the whip into the burst
local core = brush{kind="round", width=3, point=0.9}
core:reload(hot2, 1.0); core:stroke({{462,213},{481,196},{508,178},{530,176},{548,184}}, {pressure={0.2,0.8}})

--@ chunk 34
local gb = brush{kind="filbert", width=14}
local hb = brush{kind="round", width=8, point=0.3}
local rg = brush{kind="rigger", width=1.4, point=1}
for _, b in ipairs({{453,222,0.55},{475,201,0.75},{496,186,0.95}}) do
  gb:reload(violet3, 1.0); gb:touch(b[1], b[2], {pressure=b[3], drag={6, -0.7}, angle=-0.7})
  hb:reload(hot2, 1.0); hb:touch(b[1], b[2], {pressure=b[3], drag={3, -0.7}})
  for k = 1, 4 do
    local a = rand(0, 6.28); local L = 10 + 14*b[3]
    rg:reload(spark, 0.9)
    rg:stroke({{b[1], b[2]}, {b[1] + L*0.45*math.cos(a) + rand(-3,3), b[2] + L*0.45*math.sin(a) + rand(-3,3)}, {b[1] + L*math.cos(a), b[2] + L*math.sin(a)}}, {pressure={0.8,0.05}})
  end
end
