-- easel session "combat": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1200, aspect=16/9, linen={18,16}, seed=4141,
  ground={{pile={{"lead white",3},{"yellow ochre",0.3}}, um=60, apply="knife", texture=0.2},
          {pile={{"burnt sienna",2},{"ultramarine blue",2},{"bone black",0.5},{"lead white",0.6}}, um=40, apply="brush", texture=0.4}}}
print(W,H)

--@ chunk 2
VPX, VPY, TILT = 645, 300, 0.09
local ca, sa = math.cos(TILT), math.sin(TILT)
function R(x, y) local dx, dy = x - VPX, y - VPY; return VPX + dx*ca - dy*sa, VPY + dx*sa + dy*ca end
-- cross-section at k=1 (relative to VP)
SEC = {{-55,25},{-55,-45},{-38,-65},{38,-65},{55,-45},{55,25}}
function CP(k, cx, cy) local x, y = R(VPX + k*cx, VPY + k*cy); return {x, y} end
-- face between section vertices i,i+1 from depth k1 to k2
function face(i, j, k1, k2)
  local a, b = SEC[i], SEC[j]
  return poly({CP(k1,a[1],a[2]), CP(k1,b[1],b[2]), CP(k2,b[1],b[2]), CP(k2,a[1],a[2])})
end
K0, KN = 1, 30
FLOOR = face(6,1,K0,KN)
LWALL = face(1,2,K0,KN)
LCHAM = face(2,3,K0,KN)
CEIL  = face(3,4,K0,KN)
RCHAM = face(4,5,K0,KN)
RWALL = face(5,6,K0,KN)
local fr = {}
for i, v in ipairs(SEC) do fr[#fr+1] = CP(K0, v[1], v[2]) end
FAR = poly(fr)
DK  = pile{{"ultramarine blue",2},{"burnt sienna",1.5},{"bone black",1.2}}
WG  = pile{{"bone black",1},{"ultramarine ash",1},{"burnt sienna",0.4},{"lead white",0.15}}
FL  = pile{{"bone black",1},{"ultramarine blue",0.6},{"burnt sienna",0.6},{"lead white",0.2}}
work(FAR, {hand="body", pile=DK, coverage=3, fill=true, clip=true})
work(CEIL+LCHAM+RCHAM, {hand="broad", pile=DK, coverage=3, fill=true, angle=0.0, clip=true})
work(LWALL, {hand="broad", pile=WG, coverage=3, fill=true, angle=function(x,y) return math.atan(y-VPY, x-VPX) end, clip=true})
work(RWALL, {hand="broad", pile=WG, coverage=3, fill=true, angle=function(x,y) return math.atan(y-VPY, x-VPX) end, clip=true})
work(FLOOR, {hand="broad", pile=FL, coverage=3, fill=true, angle=function(x,y) return math.atan(y-VPY, x-VPX) end, clip=true})

--@ chunk 3
WD = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.6}}
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
work(LWALL+RWALL, {hand="broad", pile=WD, coverage=3.5, fill=true, angle=ang, clip=true})
work(LCHAM+RCHAM, {hand="body", pile=DK, coverage=3, fill=true, angle=ang, clip=true})

--@ chunk 4
function P(t) return poly(t) end
-- Commando parts
CM = {
 helm  = P{{232,118},{262,112},{282,128},{284,160},{266,175},{238,172},{226,150}},
 torso = P{{165,182},{205,168},{300,170},{338,190},{330,240},{300,320},{220,330},{190,260}},
 pelv  = P{{215,318},{300,312},{310,352},{225,362}},
 lthigh= P{{222,350},{262,355},{235,450},{200,445}},
 lshin = P{{200,440},{238,448},{205,535},{170,530}},
 lfoot = P{{150,528},{212,530},{218,558},{138,560}},
 rthigh= P{{268,345},{310,345},{345,430},{315,440}},
 rshin = P{{315,430},{348,428},{372,505},{345,512}},
 rfoot = P{{338,500},{380,498},{402,520},{342,524}},
 rua   = P{{318,185},{345,195},{345,250},{320,252}},
 rfa   = P{{320,245},{348,240},{380,280},{355,290}},
 lua   = P{{160,190},{190,195},{195,255},{165,258}},
 lfa   = P{{168,250},{196,252},{240,280},{220,295}},
 gun   = P{{290,262},{395,252},{472,260},{472,290},{395,298},{300,302}},
}
CMALL = CM.helm
for k,m in pairs(CM) do CMALL = CMALL + m end
WN = {
 helm  = P{{640,128},{672,120},{700,135},{704,170},{688,190},{656,192},{636,172}},
 lpaul = P{{585,182},{640,172},{650,210},{600,225},{578,210}},
 rpaul = P{{690,172},{745,180},{758,210},{735,228},{690,212}},
 torso = P{{615,195},{725,195},{712,270},{690,300},{645,300},{625,265}},
 skirt = P{{630,290},{705,290},{748,372},{700,380},{660,382},{603,374}},
 rua   = P{{590,205},{615,215},{595,255},{572,248}},
 rfa   = P{{572,245},{598,252},{560,274},{545,262}},
 hand  = P{{545,256},{560,268},{548,286},{528,282},{524,262}},
 lua   = P{{735,215},{758,222},{765,275},{742,278}},
 shaft = ribbon({{800,110},{748,250},{705,372}}, 5),
}
WNALL = WN.helm
for k,m in pairs(WN) do WNALL = WNALL + m end
CMD = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
BZD = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.7}}
work(CMALL, {hand="body", pile=CMD, coverage=3.5, fill=true, clip=true})
work(WNALL, {hand="body", pile=BZD, coverage=3.5, fill=true, clip=true})

--@ chunk 5
local P = poly
CM = {
 helm  = P{{212,92},{245,82},{268,98},{272,135},{255,152},{222,150},{205,125}},
 torso = P{{150,175},{190,155},{300,160},{345,182},{340,240},{318,330},{235,345},{195,270}},
 pelv  = P{{232,330},{320,320},{332,368},{245,380}},
 lthigh= P{{238,365},{282,372},{232,465},{192,452}},
 lshin = P{{192,445},{235,462},{185,563},{128,563}},
 rthigh= P{{285,360},{328,352},{375,430},{345,445}},
 rshin = P{{345,430},{378,425},{392,505},{362,512}},
 rfoot = P{{352,498},{398,494},{428,514},{356,522}},
 rua   = P{{325,180},{358,192},{360,250},{332,256}},
 rfa   = P{{333,248},{360,240},{392,262},{372,283}},
 lua   = P{{150,180},{182,186},{190,245},{160,250}},
 lfa   = P{{162,242},{192,240},{250,275},{232,292}},
 gun   = P{{280,268},{340,252},{395,242},{400,274},{345,290},{288,302}},
 muz   = P{{390,234},{410,231},{414,280},{396,283}},
}
CMALL = CM.helm
for k,m in pairs(CM) do CMALL = CMALL + m end
WN = {
 helm  = P{{650,52},{698,38},{740,56},{752,105},{735,148},{690,158},{656,140},{642,98}},
 lpaul = P{{560,112},{650,88},{675,162},{620,198},{552,178}},
 rpaul = P{{748,84},{842,102},{872,162},{836,204},{760,178}},
 torso = P{{600,142},{832,138},{806,278},{772,332},{670,338},{630,282}},
 skirt = P{{650,318},{792,314},{872,436},{800,446},{700,452},{590,440}},
 rua   = P{{568,142},{615,162},{576,248},{540,234}},
 rfa   = P{{540,226},{580,246},{522,302},{496,282}},
 hand  = P{{498,274},{526,296},{506,336},{470,330},{460,292}},
 lua   = P{{830,172},{872,184},{882,282},{846,288}},
 shaft = ribbon({{935,-10},{870,230},{790,450}}, 7),
}
WNALL = WN.helm
for k,m in pairs(WN) do WNALL = WNALL + m end
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
-- paint out old figures with corridor piles where new figures don't go
local oldc = rect(120,100,370,463)
local oldw = rect(515,100,300,290)
local fig = CMALL + WNALL
local o = oldc + oldw
work((o*LWALL) - fig, {hand="body", pile=WD, coverage=3.5, fill=true, angle=ang, clip=true})
work((o*RWALL) - fig, {hand="body", pile=WD, coverage=3.5, fill=true, angle=ang, clip=true})
work((o*FLOOR) - fig, {hand="body", pile=FL, coverage=3.5, fill=true, angle=ang, clip=true})
work((o*(FAR+CEIL+LCHAM+RCHAM)) - fig, {hand="body", pile=DK, coverage=3.5, fill=true, angle=ang, clip=true})
work(CMALL, {hand="body", pile=CMD, coverage=4, fill=true, clip=true})
work(WNALL, {hand="body", pile=CMD, coverage=4, fill=true, clip=true})

--@ chunk 6
print(wait(36*60)); print(drying(300,300), drying(100,100), drying(500,450), drying(700,250))

--@ chunk 7
print(wait(48*60)); print(drying(300,300), drying(100,100), drying(500,450), drying(700,250))

--@ chunk 8
print(wait(4*24*60)); print(drying(300,300), drying(100,100), drying(500,450), drying(700,250))

--@ chunk 9
L1 = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4},{"bone black",0.05}}
L2 = pile{{"lead white",1},{"cerulean blue",0.3},{"ultramarine blue",0.2},{"bone black",0.25}}
L3 = pile{{"bone black",1},{"ultramarine blue",0.8},{"lead white",1},{"cerulean blue",0.3}}
L4 = pile{{"bone black",1},{"ultramarine blue",1},{"lead white",0.4},{"burnt sienna",0.2}}
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
FIG = CMALL + WNALL
CSHAD = poly({{352,512},{428,516},{340,563},{0,563},{0,520},{150,525}})
local fl = FLOOR - FIG - CSHAD
local bands = {
  {ellipse(470,455,430,250), L4}, {ellipse(470,455,280,165), L3},
  {ellipse(465,458,160,95), L2},  {ellipse(460,462,80,48), L1}}
for i,b in ipairs(bands) do
  local m = (b[1]:roughen(8,60,i)) * fl
  work(m, {hand="body", pile=b[2], coverage=3, fill=true, angle=ang, clip=true, length={15,45}})
end
for i,b in ipairs(bands) do
  if i > 1 then blend(b[1]:rim(10) * fl, {angle=ang, tool="badger 12"}) end
end
-- left wall
local lw = LWALL - FIG
local wb = {{ellipse(380,250,330,300), L4}, {ellipse(390,250,200,170), L3}, {ellipse(420,255,90,90), L2}}
for i,b in ipairs(wb) do
  work((b[1]:roughen(8,60,10+i)) * lw, {hand="body", pile=b[2], coverage=3, fill=true, angle=ang, clip=true, length={15,45}})
end
for i,b in ipairs(wb) do
  if i > 1 then blend(b[1]:rim(10) * lw, {angle=ang, tool="badger 12"}) end
end
-- ceiling glow above the discharge
local ce = (CEIL + LCHAM) - FIG
work((ellipse(440,30,300,130):roughen(8,60,21)) * ce, {hand="body", pile=L4, coverage=3, fill=true, angle=ang, clip=true})
work((ellipse(450,20,150,70):roughen(8,60,22)) * ce, {hand="body", pile=L3, coverage=3, fill=true, angle=ang, clip=true})
-- right wall near edge, past the warden
local rw = RWALL - FIG
work((ellipse(1000,330,170,260):roughen(8,60,23)) * rw, {hand="body", pile=L4, coverage=3, fill=true, angle=ang, clip=true})

--@ chunk 10
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
local fl = FLOOR - FIG - CSHAD
local fe = {ellipse(470,455,280,165), ellipse(465,458,160,95), ellipse(460,462,80,48)}
for i,e in ipairs(fe) do blend(e:rim(36, 12) * fl, {angle=ang, tool="badger 26"}) end
local lw = LWALL - FIG
local we = {ellipse(380,250,330,300), ellipse(390,250,200,170), ellipse(420,255,90,90)}
for i,e in ipairs(we) do blend(e:rim(36, 12) * lw, {angle=ang, tool="badger 26"}) end
local ce = (CEIL + LCHAM) - FIG
for i,e in ipairs({ellipse(440,30,300,130), ellipse(450,20,150,70)}) do blend(e:rim(36,12)*ce, {angle=0, tool="badger 26"}) end
blend(ellipse(1000,330,170,260):rim(36,12) * (RWALL - FIG), {angle=ang, tool="badger 26"})

--@ chunk 11
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
L12 = pile{{"lead white",3},{"zinc white",1},{"cerulean blue",0.7},{"ultramarine blue",0.2},{"bone black",0.3}}
L23 = pile{{"lead white",2},{"bone black",1.2},{"ultramarine blue",1},{"cerulean blue",0.6}}
L34 = pile{{"bone black",2},{"ultramarine blue",1.8},{"lead white",1.4},{"cerulean blue",0.3},{"burnt sienna",0.2}}
L45 = pile{{"bone black",1.5},{"ultramarine blue",1},{"lead white",0.25},{"burnt sienna",0.5}}
local function seam(e, surf, p, w)
  work(e:rim(w, 10) * surf, {hand="scumble", pile=p, coverage=2.2, angle=ang, clip=true, length={8,22}, load=0.5})
end
local fl = FLOOR - FIG - CSHAD
seam(ellipse(470,455,430,250), fl, L45, 50)
seam(ellipse(470,455,280,165), fl, L34, 50)
seam(ellipse(465,458,160,95), fl, L23, 40)
seam(ellipse(460,462,80,48), fl, L12, 30)
local lw = LWALL - FIG
seam(ellipse(380,250,330,300), lw, L45, 50)
seam(ellipse(390,250,200,170), lw, L34, 50)
seam(ellipse(420,255,90,90), lw, L23, 40)
local ce = (CEIL + LCHAM) - FIG
seam(ellipse(440,30,300,130), ce, L45, 50)
seam(ellipse(450,20,150,70), ce, L34, 40)
seam(ellipse(1000,330,170,260), RWALL - FIG, L45, 50)

--@ chunk 12
print(wait(5*24*60)); print(drying(460,462), drying(400,250), drying(300,450), drying(950,330), drying(700,250))

--@ chunk 13
RAMP = {
 pile{{"bone black",1.5},{"ultramarine blue",1},{"burnt sienna",0.6}},
 pile{{"bone black",1.5},{"ultramarine blue",1.2},{"burnt sienna",0.4},{"lead white",0.15}},
 pile{{"bone black",1.2},{"ultramarine blue",1.2},{"lead white",0.4},{"cerulean blue",0.2}},
 pile{{"bone black",1},{"ultramarine blue",1},{"lead white",1},{"cerulean blue",0.3}},
 pile{{"bone black",0.6},{"ultramarine blue",0.8},{"lead white",1.6},{"cerulean blue",0.5}},
 pile{{"bone black",0.25},{"ultramarine blue",0.4},{"lead white",2},{"cerulean blue",0.5}},
 pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4},{"bone black",0.05}},
}
LIGHTS = {{-25,-5,74}, {-22,-4,88}, {-19,-15,108}}
FOC = 700
FACES = {
 {6,1,4,{0,-1}}, {1,2,3,{1,0}}, {2,3,1,{0.76,0.65}}, {3,4,2,{0,1}}, {4,5,1,{-0.76,0.65}}, {5,6,3,{-1,0}},
}
KS = {1.7, 2.2, 2.8, 3.6, 4.6, 5.9, 7.5, 9.6, 12.3, 16, 22, 30}
function illum(X, Y, Z, nx, ny)
  local s = 0
  for _, L in ipairs(LIGHTS) do
    local dx, dy, dz = L[1]-X, L[2]-Y, L[3]-Z
    local d = math.sqrt(dx*dx + dy*dy + dz*dz)
    local c = (nx*dx + ny*dy) / d
    if c > 0 then s = s + (0.25 + 0.75*c) / (1 + (d/45)^2) end
  end
  return s
end
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
local n = 0
for fi, F in ipairs(FACES) do
  local A, B, dv, nrm = SEC[F[1]], SEC[F[2]], F[3], F[4]
  for ki = 1, #KS-1 do
    local k1, k2 = KS[ki], KS[ki+1]
    for d = 0, dv-1 do
      local s1, s2 = d/dv, (d+1)/dv
      local ax, ay = lerp(A[1],B[1],s1), lerp(A[2],B[2],s1)
      local bx, by = lerp(A[1],B[1],s2), lerp(A[2],B[2],s2)
      local m = poly({CP(k1,ax,ay), CP(k1,bx,by), CP(k2,bx,by), CP(k2,ax,ay)}) - FIG
      if m:area() > 20 then
        local km = math.sqrt(k1*k2)
        local I = illum((ax+bx)/2, (ay+by)/2, FOC/km, nrm[1], nrm[2])
        local t = clamp(I/1.6, 0, 1)^0.6
        local idx = clamp(math.floor(t*6.99) + 1 + (rand(0,1) < 0.15 and -1 or 0), 1, 7)
        work(m, {hand="body", pile=RAMP[idx], coverage=3, fill=true, clip=true, angle=ang, length={6,35}})
        n = n + 1
      end
    end
  end
end
print("panels", n)
local deep = FAR + poly({CP(1,-55,25),CP(1,-55,-45),CP(1,-38,-65),CP(1,38,-65),CP(1,55,-45),CP(1,55,25),CP(1.7,55,25),CP(1.7,55,-45),CP(1.7,38,-65),CP(1.7,-38,-65),CP(1.7,-55,-45),CP(1.7,-55,25)})
work((deep:grow(2)) - FIG, {hand="body", pile=RAMP[1], coverage=3, fill=true, clip=true, angle=ang, length={4,15}})

--@ chunk 14
RAMP = {
 pile{{"bone black",1.5},{"ultramarine blue",1},{"burnt sienna",0.6}},
 pile{{"bone black",1.5},{"ultramarine blue",1.2},{"burnt sienna",0.4},{"lead white",0.15}},
 pile{{"bone black",1.2},{"ultramarine blue",1.2},{"lead white",0.4},{"cerulean blue",0.2}},
 pile{{"bone black",1},{"ultramarine blue",1},{"lead white",1},{"cerulean blue",0.3}},
 pile{{"bone black",0.6},{"ultramarine blue",0.8},{"lead white",1.6},{"cerulean blue",0.5}},
 pile{{"bone black",0.25},{"ultramarine blue",0.4},{"lead white",2},{"cerulean blue",0.5}},
 pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4},{"bone black",0.05}},
}
LIGHTS = {{-25,-5,74}, {-22,-4,88}, {-19,-15,108}}
FOC = 700
FACES = {
 {6,1,4,{0,-1}}, {1,2,3,{1,0}}, {2,3,1,{0.76,0.65}}, {3,4,2,{0,1}}, {4,5,1,{-0.76,0.65}}, {5,6,3,{-1,0}},
}
KS = {1.7, 2.2, 2.8, 3.6, 4.6, 5.9, 7.5, 9.6, 12.3, 16, 22, 30}
function illum(X, Y, Z, nx, ny)
  local s = 0
  for _, L in ipairs(LIGHTS) do
    local dx, dy, dz = L[1]-X, L[2]-Y, L[3]-Z
    local d = math.sqrt(dx*dx + dy*dy + dz*dz)
    local c = (nx*dx + ny*dy) / d
    if c > 0 then s = s + (0.25 + 0.75*c) / (1 + (d/45)^2) end
  end
  return s
end
local ang = function(x,y) return math.atan(y-VPY, x-VPX) end
print(wait(4*24*60)); local n = 0
for fi, F in ipairs(FACES) do
  local A, B, dv, nrm = SEC[F[1]], SEC[F[2]], F[3], F[4]
  for ki = 1, #KS-1 do
    local k1, k2 = KS[ki], KS[ki+1]
    for d = 0, dv-1 do
      local s1, s2 = d/dv, (d+1)/dv
      local ax, ay = lerp(A[1],B[1],s1), lerp(A[2],B[2],s1)
      local bx, by = lerp(A[1],B[1],s2), lerp(A[2],B[2],s2)
      local m = poly({CP(k1,ax,ay), CP(k1,bx,by), CP(k2,bx,by), CP(k2,ax,ay)}) - FIG
      if m:area() > 20 then
        local km = math.sqrt(k1*k2)
        local I = illum((ax+bx)/2, (ay+by)/2, FOC/km, nrm[1], nrm[2])
        local t = clamp(I/3.6, 0, 1)^0.85
        local idx = clamp(math.floor(t*6.99) + 1 + (rand(0,1) < 0.15 and -1 or 0), 1, 7)
        work(m, {hand="body", pile=RAMP[idx], coverage=3, fill=true, clip=true, angle=ang, length={6,35}})
        n = n + 1
      end
    end
  end
end
print("panels", n)

--@ chunk 15
BZ1 = pile{{"lead white",2},{"yellow ochre",1},{"lemon chrome",0.2}}
BZ2 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
BZ3 = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
BZ4 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.7}}
DX, DY = 520, 200
HALO = (ellipse(708,96,98,94) - ellipse(708,96,84,80)) - WNALL
local axes = {helm=1.75, lpaul=0.3, rpaul=0.3, torso=1.57, skirt=1.45, rua=2.0, rfa=2.4, hand=2.0, lua=1.5, shaft=1.92}
local function part(m, a)
  work(m, {hand="body", pile=BZ4, coverage=3, fill=true, clip=true, angle=a, length={8,30}})
  work(m * ellipse(DX,DY,300,300), {hand="body", pile=BZ3, coverage=2.5, fill=true, clip=true, angle=a, length={8,26}})
  work(m * ellipse(DX,DY,200,200), {hand="body", pile=BZ2, coverage=2.5, fill=true, clip=true, angle=a, length={6,22}})
  work(m * ellipse(DX,DY,105,105), {hand="body", pile=BZ1, coverage=2.2, fill=true, clip=true, angle=a, length={5,18}})
end
for _, name in ipairs({"skirt","torso","rpaul","lpaul","lua","helm","rua","rfa","hand","shaft"}) do
  part(WN[name], axes[name])
end
part(HALO, function(x,y) return math.atan(y-96, x-708) + 1.5708 end)

--@ chunk 16
print(wait(4*24*60))
WPTS = {
 helm  = {{650,52},{698,38},{740,56},{752,105},{735,148},{690,158},{656,140},{642,98}},
 lpaul = {{560,112},{650,88},{675,162},{620,198},{552,178}},
 rpaul = {{748,84},{842,102},{872,162},{836,204},{760,178}},
 torso = {{600,142},{832,138},{806,278},{772,332},{670,338},{630,282}},
 skirt = {{650,318},{792,314},{872,436},{800,446},{700,452},{590,440}},
 rua   = {{568,142},{615,162},{576,248},{540,234}},
 rfa   = {{540,226},{580,246},{522,302},{496,282}},
 hand  = {{498,274},{526,296},{506,336},{470,330},{460,292}},
 lua   = {{830,172},{872,184},{882,282},{846,288}},
}
BZ0 = pile{{"bone black",2},{"burnt sienna",0.8},{"raw sienna",0.4},{"ultramarine blue",0.4}}
function modelpart(pts, m, a, hot)
  local cx, cy = 0, 0
  for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end
  cx, cy = cx/#pts, cy/#pts
  local ux, uy = DX - cx, DY - cy
  local dl = math.sqrt(ux*ux + uy*uy); ux, uy = ux/dl, uy/dl
  local e = 0
  for _, p in ipairs(pts) do e = math.max(e, (p[1]-cx)*ux + (p[2]-cy)*uy) end
  local function side(f) return m * mask(function(x,y) return ((x-cx)*ux + (y-cy)*uy) > f*e and 1 or 0 end) end
  work(m, {hand="body", pile=BZ0, coverage=3, fill=true, clip=true, angle=a, length={8,30}})
  local near = dl < 140 and 2 or (dl < 260 and 1 or 0)
  work(side(-0.1), {hand="body", pile=BZ3, coverage=2.2, fill=true, clip=true, angle=a, length={6,24}})
  work(side(0.45), {hand="body", pile=(near >= 1) and BZ2 or BZ3, coverage=2.2, fill=true, clip=true, angle=a, length={5,18}})
  work(side(0.78), {hand="body", pile=(near >= 1) and BZ1 or BZ2, coverage=2.2, fill=true, clip=true, angle=a, length={4,14}})
end
local axes = {helm=1.75, lpaul=0.3, rpaul=0.3, torso=1.57, skirt=1.45, rua=2.0, rfa=2.4, hand=2.0, lua=1.5}
for _, name in ipairs({"skirt","torso","rpaul","lpaul","lua","helm","rua","rfa","hand"}) do
  modelpart(WPTS[name], WN[name], axes[name])
end

--@ chunk 17
local P = poly
EN = {
 hl_t = P{{560,320},{600,318},{610,368},{578,386},{552,366}},
 hl_h = P{{566,296},{586,292},{594,312},{580,322},{564,316}},
 hl_l1= P{{558,378},{576,382},{548,446},{532,442}},
 hl_l2= P{{586,380},{602,376},{618,440},{602,446}},
 hl_a = P{{560,328},{572,338},{532,368},{524,358}},
 hr_t = P{{890,286},{945,282},{956,350},{916,372},{888,346}},
 hr_h = P{{898,256},{928,250},{936,276},{918,290},{896,282}},
 hr_l1= P{{895,360},{916,362},{890,472},{872,468}},
 hr_l2= P{{926,358},{946,354},{968,466},{950,472}},
 hr_a = P{{890,300},{906,306},{868,348},{858,340}},
}
MITES = {{668,498,1},{728,482,0.85},{785,512,1.1},{612,520,1.2},{960,190,0.9}}
local ms = nil
for _, mt in ipairs(MITES) do
  local x, y, s = mt[1], mt[2], mt[3]
  local m = ellipse(x, y, 16*s, 8*s)
  for j = 1, 3 do
    local dx = (j-2)*9*s
    m = m + ribbon({{x+dx, y}, {x+dx-14*s, y-6*s}, {x+dx-20*s, y+10*s}}, 2.2*s)
    m = m + ribbon({{x+dx, y}, {x+dx+15*s, y-7*s}, {x+dx+22*s, y+9*s}}, 2.2*s)
  end
  ms = ms and (ms + m) or m
end
ENALL = ms
for k, m in pairs(EN) do ENALL = ENALL + m end
ENALL = ENALL - WNALL
ENM = ms - WNALL
ENP = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6},{"lead white",0.1}}
work(ENALL, {hand="detail", pile=ENP, coverage=4, fill=true, clip=true})
-- warden shadow side: the far (right) halves sink into dark
local sh = WNALL * mask(function(x,y) return (x - 700) + 0.3*(y-250) > 30 and 1 or 0 end)
work(sh, {hand="body", pile=BZ0, coverage=2.5, fill=true, clip=true, angle=1.57, length={8,26}, edge="soft"})

--@ chunk 18
print(wait(4*24*60))
local P = poly
SHD = pile{{"bone black",1.5},{"ultramarine blue",1.2},{"burnt sienna",0.5}}
-- warden far side into shadow
local sh = WNALL * mask(function(x,y) return (x - 735) + 0.35*(y-250) > 0 and 1 or 0 end)
work(sh, {hand="body", pile=BZ0, coverage=4, fill=true, clip=true, angle=1.57, length={8,26}})
-- cast shadows on the floor, hard
local fs = P{{350,505},{424,518},{300,563},{150,563}}
     + P{{800,446},{872,436},{1000,452},{1000,505}}
     + P{{548,446},{535,442},{560,450},{600,470},{580,476}}
for _, mt in ipairs(MITES) do
  if mt[2] > 400 then fs = fs + ellipse(mt[1]+18*mt[3], mt[2]+6*mt[3], 22*mt[3], 6*mt[3]) end
end
fs = fs * FLOOR - FIG - ENALL
work(fs, {hand="body", pile=SHD, coverage=3.5, fill=true, clip=true, angle=ang or 0.4, length={6,20}})
-- polearm and husk shadows thrown on the right wall
local rws = (ribbon({{1000,60},{975,250},{955,470}}, 12) + P{{960,300},{1000,290},{1000,420},{975,430}}) * RWALL - FIG - ENALL
work(rws, {hand="body", pile=SHD, coverage=3.5, fill=true, clip=true, angle=1.4, length={6,20}})
-- the crusader's tabard and the cross on his back
TAB = P{{235,330},{318,320},{345,345},{398,418},{372,430},{332,410},{302,442},{272,404},{242,422},{225,380}}
CROSS = ribbon({{246,182},{250,305}}, 11) + ribbon({{200,226},{298,220}}, 11)
TABP = pile{{"vermilion",1},{"bone black",1.2},{"rose madder",0.5}}
CRP = pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.5},{"ultramarine blue",0.3}}
work(TAB, {hand="body", pile=TABP, coverage=4, fill=true, clip=true, angle=1.2, length={10,40}})
work(CROSS * CM.torso, {hand="detail", pile=CRP, coverage=4, fill=true, clip=true})
CMALL = CMALL + TAB

--@ chunk 19
TABD = pile{{"bone black",2},{"vermilion",0.5},{"rose madder",0.5},{"ultramarine blue",0.3}}
CRD = pile{{"bone black",1},{"lead white",0.5},{"yellow ochre",0.3},{"ultramarine blue",0.4}}
work(TAB, {hand="body", pile=TABD, coverage=4, fill=true, clip=true, angle=1.2, length={10,40}})
work(CROSS * CM.torso, {hand="detail", pile=CRD, coverage=4, fill=true, clip=true})
work(HALO * mask(function(x,y) return x > 735 and 1 or 0 end), {hand="detail", pile=BZ0, coverage=4, fill=true, clip=true})

--@ chunk 20
print(wait(5*24*60))
CABLE = {{410,256},{428,276},{450,284},{470,272},{482,250},{494,226},{508,210},{521,201}}
DART = {521,201}
GL = pile{{"zinc white",3},{"cerulean blue",0.35},{"cobalt violet",0.15}, medium=0.5}
local glowm = ellipse(500,225,150,130):blur(40) + ribbon(CABLE, 70):blur(20)
work(glowm, {hand="glaze", pile=GL, load=0.25, pressure={0.1,0.25}, coverage=1.5, angle=function(x,y) return math.atan(y-DART[2], x-DART[1]) end, tool="filbert 14", length={30,90}})
work(ellipse(505,222,85,75):blur(25) + ribbon(CABLE, 30):blur(10), {hand="glaze", pile=GL, load=0.3, pressure={0.15,0.3}, coverage=1.5, angle=function(x,y) return math.atan(y-DART[2], x-DART[1]) end, tool="filbert 10", length={20,60}})
blend(ellipse(500,225,160,140), {tool="badger 20"})

--@ chunk 21
local m = ellipse(500,225,175,160)
for i = 1, 4 do
  work(m, {hand="scumble", blender=true, coverage=2, tool="filbert 10", dips={4,0,1}, angle=0.3*i})
end

--@ chunk 22
print(wait(6*24*60))
print(drying(500,225), drying(450,284))
HOT = pile{{"zinc white",3},{"lemon chrome",0.05}}
ICE = pile{{"zinc white",2},{"cerulean blue",0.5},{"lead white",1}}
VIO = pile{{"zinc white",1.5},{"cobalt violet",1},{"magenta",0.3},{"ultramarine blue",0.3}}
CAB = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.2}}
function along(pts, t1, t2, n)
  local L, acc = {}, 0
  L[1] = 0
  for i = 2, #pts do
    local dx, dy = pts[i][1]-pts[i-1][1], pts[i][2]-pts[i-1][2]
    acc = acc + math.sqrt(dx*dx+dy*dy); L[i] = acc
  end
  local out = {}
  for j = 0, n do
    local s = (t1 + (t2-t1)*j/n) * acc
    local i = 2
    while i < #pts and L[i] < s do i = i + 1 end
    local u = (s - L[i-1]) / math.max(1e-6, L[i]-L[i-1])
    out[#out+1] = {lerp(pts[i-1][1], pts[i][1], u), lerp(pts[i-1][2], pts[i][2], u)}
  end
  return out
end
local b = brush{kind="round", width=3.2, point=0.2}
b:load(CAB, 0.9)
b:stroke(CABLE, {pressure={0.9,0.7}})
local db = brush{kind="round", width=5, point=0.8}
db:load(CAB, 0.9)
db:stroke({{511,209},{521,201},{534,191}}, {pressure={0.6,0.2}})
local vb = brush{kind="filbert", width=9}
for _, s in ipairs({{0.12,0.42},{0.55,0.84}}) do
  vb:reload(VIO, 0.6)
  vb:stroke(along(CABLE, s[1], s[2], 10), {pressure={0.5,0.4}, swell={0.6,1.3,0.8}})
end
local ib = brush{kind="round", width=4, point=0.6}
for _, s in ipairs({{0.14,0.40},{0.57,0.82},{0.9,1.0}}) do
  ib:reload(ICE, 0.8)
  ib:stroke(along(CABLE, s[1], s[2], 8), {pressure={0.4,0.7}, swell={0.5,1.2,0.6}})
end

--@ chunk 23
print(wait(2*24*60))
local gb = brush{kind="filbert", width=18}
gb:load(VIO, 0.3)
gb:stroke(along(CABLE, 0.05, 1.0, 16), {pressure={0.3,0.35}, swell={0.7,1.2,0.9,1.3,1}})
local mb = brush{kind="round", width=9, point=0.3}
for _, s in ipairs({{0.08,0.46},{0.52,0.88},{0.9,1.0}}) do
  mb:reload(ICE, 0.75)
  mb:stroke(along(CABLE, s[1], s[2], 10), {pressure={0.45,0.6}, swell={0.5,1.3,0.8,1.2,0.6}})
end
local cb = brush{kind="round", width=4, point=0.4}
for _, s in ipairs({{0.1,0.44},{0.54,0.86},{0.92,1.0}}) do
  cb:reload(HOT, 1.0)
  cb:stroke(along(CABLE, s[1], s[2], 10), {pressure={0.6,0.7}})
end
-- spits of arc off the bursting cable
local rb = brush{kind="rigger", width=2, point=1}
for i = 1, 14 do
  local t = rand(0.08, 0.98)
  local p = along(CABLE, t, t, 1)[1]
  local a = rand(0, 2*math.pi)
  local L = rand(8, 26)
  local q = {p[1] + L*math.cos(a), p[2] + L*math.sin(a)}
  local mid = {(p[1]+q[1])/2 + rand(-5,5), (p[2]+q[2])/2 + rand(-5,5)}
  rb:reload(i % 2 == 0 and HOT or ICE, 0.8)
  rb:stroke({p, mid, q}, {pressure={0.45,0.0}})
end

--@ chunk 24
function jag(a, b, n, amp)
  local pts = {{a[1], a[2]}}
  local dx, dy = b[1]-a[1], b[2]-a[2]
  local len = math.sqrt(dx*dx+dy*dy)
  local px, py = -dy/len, dx/len
  for i = 1, n-1 do
    local t = i/n
    local o = randn(0, amp) * math.sin(math.pi*t)
    pts[#pts+1] = {a[1]+dx*t+px*o, a[2]+dy*t+py*o}
  end
  pts[#pts+1] = {b[1], b[2]}
  return pts
end
local rig = brush{kind="rigger", width=2.2, point=1}
local glow = brush{kind="round", width=6, point=0.5}
local tip = {534,191}
local targets = {
  {{552,236}, 7, 6, 0.75}, {{600,150}, 8, 7, 0.6}, {{652,112}, 9, 8, 0.5},
  {{628,205}, 7, 6, 0.6}, {{580,300}, 9, 9, 0.45}, {{612,262}, 7, 6, 0.4},
}
SPARKS = {}
for _, T in ipairs(targets) do
  local p = jag(tip, T[1], T[2], T[3])
  SPARKS[#SPARKS+1] = p
  glow:reload(VIO, 0.35)
  glow:stroke(p, {pressure={0.35*T[4]+0.1, 0.15}})
  rig:reload(HOT, 0.9)
  rig:stroke(p, {pressure={0.55*T[4]+0.3, 0.3}})
  -- a branch or two off the channel
  for k = 1, 2 do
    local i = math.random(2, #p-1)
    local q = p[i]
    local e = {q[1] + rand(-28,28), q[2] + rand(-28,20)}
    rig:reload(ICE, 0.7)
    rig:stroke(jag(q, e, 4, 3), {pressure={0.3,0.0}})
  end
end
-- contact splashes where the feelers land
local tb = brush{kind="round", width=4, point=0.3}
for _, T in ipairs(targets) do
  tb:reload(HOT, 0.9)
  tb:touch(T[1][1], T[1][2], {pressure=0.55})
end
-- the dart's head flares
tb:reload(HOT, 1.0)
tb:touch(534, 191, {pressure=0.9})
tb:touch(530, 194, {pressure=0.7})

--@ chunk 25
print(wait(3*24*60))
print(drying(760,250), drying(300,380), drying(250,250))
BZM = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.8},{"ultramarine blue",0.3}}
local far = WNALL * mask(function(x,y) return (x - 715) + 0.45*(y-230) > 0 and 1 or 0 end)
local mid = WNALL * mask(function(x,y) local v = (x - 715) + 0.45*(y-230); return (v > -45 and v <= 0) and 1 or 0 end)
work(far, {hand="body", pile=BZ0, coverage=4, fill=true, clip=true, angle=1.57, length={8,26}})
work(mid, {hand="body", pile=BZM, coverage=3.5, fill=true, clip=true, angle=1.57, length={8,26}})
TABD2 = pile{{"bone black",2.5},{"vermilion",0.35},{"rose madder",0.4},{"ultramarine blue",0.4}}
work(TAB, {hand="body", pile=TABD2, coverage=4, fill=true, clip=true, angle=1.25, length={10,40}})
work(TAB * mask(function(x,y) return (x - 330) - 0.3*(y-380) > 0 and 1 or 0 end), {hand="body", pile=TABD, coverage=3, fill=true, clip=true, angle=1.0, length={8,30}})
CRD2 = pile{{"bone black",1.2},{"lead white",0.35},{"yellow ochre",0.25},{"ultramarine blue",0.5}}
work(CROSS * CM.torso, {hand="detail", pile=CRD2, coverage=4, fill=true, clip=true})
-- plates on his back: dark seams that model the war-body
local sb = brush{kind="round", width=2.2, point=0.3}
for _, l in ipairs({{{170,250},{205,262},{240,268}}, {{285,262},{318,256},{336,248}}, {{200,300},{250,312},{305,305}}, {{298,172},{305,215},{316,240}}, {{188,170},{182,212},{190,256}}}) do
  sb:reload(SEAM or pile{{"bone black",2},{"ultramarine blue",1}}, 0.9)
  sb:stroke(l, {pressure={0.6,0.5}})
end

--@ chunk 26
print(wait(5*24*60)); print(drying(760,250), drying(690,120), drying(300,380))
RIMC = pile{{"lead white",1.5},{"zinc white",1},{"cerulean blue",0.5},{"ultramarine blue",0.15}}
RIMW = pile{{"lead white",2},{"yellow ochre",0.6},{"lemon chrome",0.2}}
local rg = brush{kind="rigger", width=2.6, point=0.6}
local function rim(pts, p, pr)
  rg:reload(p, 0.85)
  rg:stroke(pts, {pressure=pr or {0.55,0.35}, ramps={0.1,0.3}})
end
-- the Commando, lit from in front: thin cold edges on his right-hand contours
rim({{247,84},{268,98},{272,135},{258,150}}, RIMC, {0.5,0.25})
rim({{300,161},{345,182},{341,238}}, RIMC)
rim({{340,240},{318,330}}, RIMC, {0.4,0.15})
rim({{326,181},{358,192},{360,248}}, RIMC, {0.6,0.4})
rim({{360,241},{392,262}}, RIMC, {0.6,0.5})
rim({{290,268},{340,253},{392,243}}, RIMC, {0.65,0.55})
rim({{391,235},{410,231},{414,279}}, RIMC, {0.7,0.5})
rim({{328,353},{376,430}}, RIMC, {0.45,0.35})
rim({{378,426},{392,504}}, RIMC, {0.45,0.3})
rim({{398,495},{427,513}}, RIMC, {0.5,0.3})
rim({{346,346},{398,418}}, RIMC, {0.4,0.2})
rim({{283,372},{262,415}}, RIMC, {0.25,0.05})
-- the Warden, struck from below-left: warm-white edges toward the dart
rim({{460,292},{470,330},{506,336}}, RIMW, {0.55,0.35})
rim({{498,274},{460,292}}, RIMW, {0.7,0.5})
rim({{496,282},{540,226}}, RIMW, {0.75,0.5})
rim({{540,234},{568,142}}, RIMW, {0.65,0.4})
rim({{552,178},{560,112},{650,88}}, RIMW, {0.6,0.3})
rim({{642,98},{650,52},{698,38}}, RIMW, {0.5,0.25})
rim({{656,140},{642,98}}, RIMW, {0.55,0.4})
rim({{630,282},{600,142}}, RIMW, {0.45,0.25})
rim({{650,318},{590,440}}, RIMW, {0.4,0.2})
-- husks: the near one edged cold on its left, the far one barely
rim({{524,358},{560,328}}, RIMC, {0.5,0.3})
rim({{552,366},{560,320},{566,296},{586,292}}, RIMC, {0.5,0.3})
rim({{532,442},{558,378}}, RIMC, {0.4,0.2})
rim({{858,340},{890,300},{898,256},{928,250}}, RIMC, {0.3,0.15})
rim({{872,468},{895,360}}, RIMC, {0.25,0.1})
for _, mt in ipairs(MITES) do
  rim({{mt[1]-14*mt[3], mt[2]-3*mt[3]}, {mt[1], mt[2]-8*mt[3]}, {mt[1]+8*mt[3], mt[2]-7*mt[3]}}, RIMC, {0.35,0.15})
end
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
BONED = pile{{"lead white",1},{"yellow ochre",0.8},{"raw sienna",0.6},{"bone black",0.4}}
DARKB = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}}
local tb = brush{kind="round", width=3, point=0.3}
-- face: a sunflower rosette of bone studs round a dark eye, turned down toward him
local fx, fy = 672, 112
local fb = brush{kind="round", width=16, point=0.1}
fb:load(DARKB, 0.9); fb:touch(fx, fy, {pressure=0.95})
for i = 3, 40 do
  local r, th = 3.3*math.sqrt(i), i*2.39996
  local x, y = fx + r*math.cos(th)*1.0, fy + r*math.sin(th)*1.15
  local lit = (x - fx)*(-0.8) + (y - fy)*0.3 > -4
  tb:reload(lit and BONE or BONED, 0.8)
  tb:touch(x, y, {pressure=0.25 + 0.012*i})
end
local eb = brush{kind="round", width=6, point=0.4}
eb:load(DARKB, 1); eb:touch(fx, fy, {pressure=0.8})
eb:reload(VIO, 0.8); eb:touch(fx-1, fy+1, {pressure=0.25})
-- bone lancet down the chest with a column of glyphs
LANCET = poly{{666,176},{690,172},{695,298},{681,320},{663,298}}
work(LANCET, {hand="detail", pile=BONED, coverage=4, fill=true, clip=true})
work(LANCET * mask(function(x,y) return x < 680 and 1 or 0 end), {hand="detail", pile=BONE, coverage=3, fill=true, clip=true})
local gb = brush{kind="round", width=1.6, point=0.6}
for i = 0, 11 do
  local y = 186 + i*9.5 + rand(-1.5,1.5)
  gb:reload(DARKB, 0.8)
  gb:stroke({{672 + rand(-2,2), y}, {684 + rand(-2,2), y + rand(-2,2)}}, {pressure={0.4,0.2}})
end
-- lames across the skirt: dark joints, each lip caught on the light side
local lb = brush{kind="round", width=2.4, point=0.3}
for i, y in ipairs({338, 360, 384, 408, 432}) do
  local w = (y - 318) * 0.6
  local pts = {{640 - w, y + 4}, {700, y - 4}, {770 + w*0.7, y + 2}}
  lb:reload(DARKB, 0.9); lb:stroke(pts, {pressure={0.7,0.6}})
  lb:reload(RIMW, 0.6); lb:stroke({{640 - w + 2, y + 7}, {690, y - 0.5}}, {pressure={0.35,0.05}})
end
-- studs on the nimbus at golden-angle steps
for i = 1, 14 do
  local th = math.pi + 0.15 + (i * 0.618 % 1) * 2.9
  local x, y = 708 + 91*math.cos(th), 96 + 87*math.sin(th)
  if not (WNALL:at(x, y) > 0.5) then
    tb:reload(x < 720 and BONE or BONED, 0.8); tb:touch(x, y, {pressure=0.4})
  end
end
-- corruption: the reaching hand stutters, a cold displaced ghost of its contour
local gh = brush{kind="rigger", width=1.8, point=1}
for _, c in ipairs({{{486,262},{514,284},{494,324},{458,318},{448,280},{486,262}}, {{528,214},{568,234},{510,290}}}) do
  gh:reload(VIO, 0.7)
  local pts = {}
  for _, p in ipairs(c) do pts[#pts+1] = {p[1] - 14, p[2] - 12} end
  gh:stroke(pts, {pressure={0.35,0.3}})
end

--@ chunk 27
-- ribs of the prefab corridor in the dark beyond, catching a little of the discharge
local rb = brush{kind="round", width=3, point=0.3}
for _, k in ipairs({2.2, 2.8, 3.6, 4.6}) do
  for i = 1, 6 do
    local a, b = SEC[i], SEC[i % 6 + 1]
    for s = 0, 5 do
      local p1 = CP(k, lerp(a[1],b[1],s/6), lerp(a[2],b[2],s/6))
      local p2 = CP(k, lerp(a[1],b[1],(s+1)/6), lerp(a[2],b[2],(s+1)/6))
      local x, y = (p1[1]+p2[1])/2, (p1[2]+p2[2])/2
      if FIG:at(x, y) < 0.5 and ENALL:at(x, y) < 0.5 then
        local d = math.sqrt((x-520)^2 + (y-200)^2)
        rb:reload(d < 200 and RAMP[4] or RAMP[3], 0.7)
        rb:stroke({p1, p2}, {pressure={0.45,0.45}})
      end
    end
  end
end
-- the muzzle where the cable leaves the barrel, white hot
local tb = brush{kind="round", width=7, point=0.2}
tb:load(VIO, 0.6); tb:touch(412, 257, {pressure=0.8})
tb:reload(HOT, 1); tb:touch(412, 257, {pressure=0.5})

--@ chunk 28
SEAM = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.3}}
LIP = pile{{"lead white",1},{"cerulean blue",0.3},{"ultramarine blue",0.3},{"bone black",0.3}}
AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.2}}
AMBD = pile{{"chrome yellow",1},{"Mars orange",0.6},{"bone black",0.8},{"ultramarine blue",0.2}}
local sb = brush{kind="round", width=2.2, point=0.3}
local function vis(pts) -- skip segments behind figures
  local x, y = (pts[1][1]+pts[2][1])/2, (pts[1][2]+pts[2][2])/2
  return FIG:at(x, y) < 0.5 and ENALL:at(x, y) < 0.5
end
-- seams of the prefab panels on the lit left wall and floor
for _, k in ipairs({5.9, 7.5, 9.6, 12.3}) do
  for _, e in ipairs({{{-55,25},{-55,-45}}, {{55,25},{-55,25}}}) do
    local a, b = e[1], e[2]
    for s = 0, 9 do
      local p1 = CP(k, lerp(a[1],b[1],s/10), lerp(a[2],b[2],s/10))
      local p2 = CP(k, lerp(a[1],b[1],(s+1)/10), lerp(a[2],b[2],(s+1)/10))
      if vis({p1,p2}) then
        sb:reload(SEAM, 0.8); sb:stroke({p1,p2}, {pressure={0.6,0.6}})
        sb:reload(LIP, 0.5); sb:stroke({{p1[1]+2.5,p1[2]+1},{p2[1]+2.5,p2[2]+1}}, {pressure={0.25,0.2}})
      end
    end
  end
end
-- hazard kick-plate along the left wall's foot, amber and black diagonals
local kick = poly({CP(5.5,-55,25), CP(5.5,-55,17), CP(16,-55,17), CP(16,-55,25)}) - FIG - ENALL
work(kick, {hand="detail", pile=AMBD, coverage=4, fill=true, clip=true})
local hb = brush{kind="flat", width=4}
for k = 5.7, 15.5, 0.55 do
  local p1, p2 = CP(k, -55, 25), CP(k*1.06, -55, 17)
  hb:reload(SEAM, 0.9)
  hb:stroke({p1, p2}, {pressure={0.8,0.8}, clip=kick})
end
-- glints of the discharge on the polished deck below it
local gl = brush{kind="round", width=3, point=0.5}
for i = 1, 22 do
  local x = 505 + randn(0, 12)
  local y = rand(400, 525)
  if FIG:at(x, y) < 0.5 and ENALL:at(x,y) < 0.5 then
    gl:reload(i % 3 == 0 and HOT or ICE, 0.6)
    gl:stroke({{x, y}, {x + rand(-2,2), y + rand(4,14)}}, {pressure={0.35,0.1}})
  end
end

--@ chunk 29
local kick = poly({CP(5.5,-55,25), CP(5.5,-55,17), CP(16,-55,17), CP(16,-55,25)}) - FIG - ENALL
AMBX = pile{{"chrome yellow",0.7},{"Mars orange",0.5},{"bone black",1.3},{"ultramarine blue",0.3}}
work(kick, {hand="detail", pile=AMBX, coverage=4, fill=true, clip=true})
local hb = brush{kind="flat", width=4}
for k = 5.7, 15.5, 0.55 do
  hb:reload(SEAM, 0.9)
  hb:stroke({CP(k, -55, 25), CP(k*1.06, -55, 17)}, {pressure={0.8,0.8}, clip=kick})
end

--@ chunk 30
-- ionised specks round the discharge, thinning outward
stipple(ellipse(500,225,150,120), {pile=ICE, width=1.6, feather=0.8, cluster=0.5,
  coverage=function(x,y) local d = math.sqrt(((x-505)/1.25)^2 + (y-222)^2); return 0.5*math.max(0, 1 - d/120)^2 end})
stipple(ribbon(CABLE, 40), {pile=VIO, width=1.8, feather=0.8, cluster=0.4, coverage=0.25})

--@ chunk 31
print(wait(3*24*60))
local mb = brush{kind="round", width=5, point=0.7}
for _, i in ipairs({1, 4, 3}) do
  mb:reload(HOT, 1.0)
  mb:stroke(SPARKS[i], {pressure={0.7,0.2}, ramps={0.02,0.5}})
end
local cb = brush{kind="round", width=5, point=0.4}
for _, s in ipairs({{0.12,0.42},{0.56,0.84},{0.92,1.0}}) do
  cb:reload(HOT, 1.0)
  cb:stroke(along(CABLE, s[1], s[2], 10), {pressure={0.75,0.8}})
end
-- the dart, white-hot
local tb = brush{kind="round", width=9, point=0.2}
tb:load(HOT, 1); tb:touch(532, 193, {pressure=0.8})
-- hot glints on the bronze nearest the feelers
local gb = brush{kind="round", width=2.5, point=0.6}
for _, g in ipairs({{{548,182},{560,150}}, {{590,152},{612,140}}, {{556,240},{545,262}}, {{640,118},{652,96}}, {{612,200},{620,232}}}) do
  gb:reload(HOT, 0.8); gb:stroke(g, {pressure={0.5,0.1}})
end

--@ chunk 32
local kick = poly({CP(5.5,-55,25), CP(5.5,-55,17), CP(16,-55,17), CP(16,-55,25)}) - FIG - ENALL
local strip = kick * mask(function(x,y) local k = math.floor(x / 22); return (k % 2 == 0) and 1 or 0 end)
work(kick - strip, {hand="detail", pile=RAMP[1], coverage=4, fill=true, clip=true})
work(strip, {hand="detail", pile=RAMP[2], coverage=3, fill=true, clip=true})
