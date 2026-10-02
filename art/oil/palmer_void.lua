-- easel session "palmer_void": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=0.75, linen={18,16}, seed=9292, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"bone brown",3},{"burnt sienna",1.5},{"lead white",1},{"ultramarine blue",0.3}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
NP = {}
local function seg(x0, x1)
  local t = function(x) return 620 + 0.03*(x-400) end
  local b = function(x) return 870 - 0.02*(x-400) end
  return {{x0, t(x0)}, {(x0+x1)/2, t((x0+x1)/2)-6}, {x1+6, t(x1+6)}, {x1+12, (t(x1)+b(x1))/2}, {x1+6, b(x1+6)}, {(x0+x1)/2, b((x0+x1)/2)+5}, {x0, b(x0)}, {x0-6, (t(x0)+b(x0))/2}}
end
BSEG = {}
local xs = {400, 480, 560, 640, 720, 800, 870}
for i=1,#xs-1 do NP["seg"..i] = seg(xs[i], xs[i+1]); BSEG[#BSEG+1] = "seg"..i end
NP.cap = {{872,644},{896,656},{908,740},{900,826},{876,840},{866,740}}
NP.helm = {{340,268},{380,254},{420,264},{440,300},{444,340},{436,374},{418,394},{380,402},{344,394},{326,374},{318,340},{322,300}}
NP.visor = {{324,300},{404,296},{412,334},{404,366},{332,368},{318,334}}
NP.gorget = {{330,396},{430,396},{452,432},{308,434}}
NP.cuirass = {{300,430},{460,424},{480,490},{472,570},{456,650},{316,656},{296,570},{288,490}}
NP.fairing = {{306,640},{470,634},{506,700},{478,770},{334,780},{300,706}}
NP.lpaul = {{340,432},{300,430},{262,448},{240,480},{238,520},{262,530},{300,512},{332,494},{348,462}}
NP.rpaul = {{420,428},{460,424},{500,440},{522,472},{524,510},{500,520},{464,502},{430,488},{414,458}}
NP.lrere = {{250,520},{286,516},{284,580},{254,582}}
NP.lcout = {{246,576},{286,574},{298,594},{284,614},{250,614},{238,594}}
NP.lvamb = {{250,612},{282,612},{284,690},{254,692}}
NP.lcuff = {{244,688},{290,684},{294,706},{242,710}}
NP.lhand = {{244,706},{292,702},{300,734},{292,760},{266,768},{246,756},{236,732}}
NP.rrere = {{484,520},{518,520},{524,580},{490,584}}
NP.rcout = {{486,578},{524,574},{538,594},{524,614},{490,616},{476,596}}
NP.rvamb = {{490,612},{526,610},{536,664},{504,670}}
NP.rhand = {{500,658},{576,652},{584,688},{578,724},{506,730},{492,696}}
NP.muzzle = {{508,128},{572,128},{578,214},{502,214}}
NP.breech = {{512,740},{570,740},{572,820},{510,820}}
NP.turret = {{640,566},{720,560},{732,616},{632,622}}
NP.rag = {{316,500},{456,496},{466,600},{476,700},{470,820},{452,800},{440,838},{420,810},{404,850},{388,812},{368,840},{350,806},{330,826},{320,760},{312,640}}
LEGN = {
  {hip={470,850}, knee={420,985}, foot={440,1190}},
  {hip={640,852}, knee={598,990}, foot={622,1192}},
  {hip={800,845}, knee={770,985}, foot={800,1188}},
}
LEGF = {
  {hip={505,830}, knee={488,965}, foot={520,1172}},
  {hip={675,832}, knee={655,968}, foot={690,1175}},
  {hip={835,826}, knee={826,962}, foot={852,1170}},
}
function legpolys(L, s, tag)
  local h, k, f = L.hip, L.knee, L.foot
  local function quad(a, b, wa, wb)
    local dx, dy = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(dx*dx+dy*dy); local nx, ny = -dy/l, dx/l
    return {{a[1]+nx*wa, a[2]+ny*wa}, {b[1]+nx*wb, b[2]+ny*wb}, {b[1]-nx*wb, b[2]-ny*wb}, {a[1]-nx*wa, a[2]-ny*wa}}
  end
  NP[tag.."coxa"] = {{h[1]-30*s,h[2]-24*s},{h[1]+30*s,h[2]-24*s},{h[1]+34*s,h[2]+10*s},{h[1]+18*s,h[2]+28*s},{h[1]-20*s,h[2]+28*s},{h[1]-34*s,h[2]+8*s}}
  NP[tag.."fem"] = quad(h, {lerp(h[1],k[1],0.88), lerp(h[2],k[2],0.88)}, 24*s, 20*s)
  NP[tag.."kn"] = {{k[1]-24*s,k[2]-18*s},{k[1]+16*s,k[2]-22*s},{k[1]+26*s,k[2]},{k[1]+14*s,k[2]+22*s},{k[1]-20*s,k[2]+20*s},{k[1]-30*s,k[2]}}
  NP[tag.."tib"] = quad({lerp(k[1],f[1],0.1), lerp(k[2],f[2],0.1)}, {lerp(k[1],f[1],0.9), lerp(k[2],f[2],0.9)}, 17*s, 13*s)
  NP[tag.."ft"] = {{f[1]-18*s,f[2]-26*s},{f[1]+18*s,f[2]-26*s},{f[1]+30*s,f[2]},{f[1]-30*s,f[2]}}
end
for i,L in ipairs(LEGN) do legpolys(L, 1, "n"..i) end
for i,L in ipairs(LEGF) do legpolys(L, 0.85, "f"..i) end
function PM(k) return poly(NP[k]) end
CANN = ribbon({{540,210},{541,700},{542,1190}}, {40,38,34})
MASTS = {
  {{362,262},{346,200},{318,140},{300,88}}, {{404,258},{424,190},{452,124},{470,72}},
  {{262,452},{238,390},{214,330},{200,290}}, {{500,440},{532,380},{562,320},{582,276}},
}
TINES = {{{334,170},{302,150},{290,128}}, {{350,212},{376,170},{386,140}}, {{440,150},{476,140},{492,112}}, {{418,212},{396,170},{392,146}},
  {{226,360},{196,348},{180,322}}, {{548,350},{580,340},{598,318}}}
local mm = nil
for _,A in ipairs(MASTS) do local r = ribbon(A, {12,9,6,3}); mm = mm and (mm+r) or r end
for _,T in ipairs(TINES) do mm = mm + ribbon(T, {6,4,2}) end
MASTM = mm
FIGM = CANN + MASTM
for k,_ in pairs(NP) do FIGM = FIGM + PM(k) end
-- wall and floor as in PALMER
local floorM = below(function(x) return 1190 - 0.02*(x-500) end)
FLOORM = floorM
local fig = FIGM:grow(1)
local bg = everywhere() - floorM - fig
local glow = ellipse(260, 430, 420, 512):roughen(30,150,2)
local B0 = pile{{"bone brown",2},{"bone black",0.8},{"burnt sienna",0.6}}
local B1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"raw sienna",0.4}}
work(bg - glow, {hand="broad", pile=B0, coverage=3, fill=true, angle=math.pi/2 + 0.2, clip=bg})
work(bg * glow, {hand="broad", pile=B1, coverage=3, fill=true, angle=math.pi/2 + 0.2, clip=bg})
work(floorM - fig, {hand="broad", pile=pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.5}}, coverage=3, fill=true, angle=0, clip=floorM - fig})

--@ chunk 3
SDK = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
SMD = pile{{"ultramarine ash",1},{"bone black",0.7},{"yellow ochre",0.25},{"lead white",0.25}}
SLT = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"yellow ochre",0.25},{"bone black",0.15}}
SMF = pile{{"ultramarine ash",1},{"bone black",1.1},{"burnt sienna",0.3}}
function plate(k, ang, lit, far)
  local pts = NP[k]
  local minx,maxx,miny,maxy = 1e9,-1e9,1e9,-1e9
  for _,q in ipairs(pts) do minx=math.min(minx,q[1]) maxx=math.max(maxx,q[1]) miny=math.min(miny,q[2]) maxy=math.max(maxy,q[2]) end
  local cx, hw = (minx+maxx)/2, (maxx-minx)/2
  local m = poly(pts)
  local tool = hw > 40 and "filbert 6" or "filbert 3"
  work(m, {hand="body", pile=SDK, coverage=3, fill=true, tool=tool, angle=ang, clip=m, length={8,30}})
  local midz = m * rect(minx-4, miny-4, (cx + (lit or 0.05)*hw) - minx + 4, maxy-miny+8)
  work(midz, {hand="body", pile=far and SMF or SMD, coverage=2.5, fill=true, tool=tool, angle=ang, clip=m, length={8,30}})
  if not far then
    local ltz = m * rect(minx-4, miny-4, (cx - 0.55*hw) - minx + 4, maxy-miny+8)
    work(ltz, {hand="body", pile=SLT, coverage=1.6, tool=(hw > 40 and "filbert 4" or "filbert 2"), angle=ang, clip=m, length={6,20}})
  end
end
for i=1,3 do
  local t = "f"..i
  plate(t.."ft", 0, 0, true); plate(t.."tib", math.pi/2, 0, true); plate(t.."fem", math.pi/2, 0, true); plate(t.."kn", 0, 0, true); plate(t.."coxa", 0, 0, true)
end
for _,k in ipairs(BSEG) do plate(k, math.pi/2, -0.2) end
plate("cap", math.pi/2, -0.4, true)

--@ chunk 4
for i=1,3 do
  local t = "n"..i
  plate(t.."ft", 0); plate(t.."tib", math.pi/2); plate(t.."fem", math.pi/2); plate(t.."kn", 0); plate(t.."coxa", 0)
end
work(CANN, {hand="body", pile=SDK, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=CANN})
work(CANN * rect(500,200,36,1000), {hand="body", pile=SMD, coverage=2.5, fill=true, tool="filbert 3", angle=math.pi/2, clip=CANN})
plate("breech", math.pi/2); plate("muzzle", math.pi/2); plate("turret", 0)
local K = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
work(MASTM, {hand="detail", pile=K, coverage=4, fill=true, clip=MASTM})

--@ chunk 5
plate("fairing", 0, -0.1)
plate("cuirass", math.pi/2, -0.1)
local R = PM("rag")
local C0 = pile{{"rose madder",1.5},{"bone black",0.8},{"Mars red",0.4}}
local C1 = pile{{"Mars red",1.4},{"rose madder",1}}
local C2 = pile{{"vermilion",1.2},{"Mars red",0.6},{"lead white",0.3}}
work(R, {hand="body", pile=C0, coverage=3, fill=true, tool="filbert 6", angle=math.pi/2, clip=R})
for _,f in ipairs({{326,"L"},{344,"M"},{372,"L"},{390,"M"},{424,"M"}}) do
  local x = f[1]
  local band = R * poly({{x-7,500},{x+7,500},{x+10,850},{x-10,850}})
  work(band, {hand="body", pile=(f[2]=="L") and C2 or C1, coverage=2.5, fill=true, tool="filbert 3", angle=math.pi/2, clip=R, length={50,140}})
end
plate("gorget", 0)
for _,k in ipairs({"lrere","rrere","lvamb","rvamb","lcout","rcout","lpaul","rpaul","helm","visor","lcuff","lhand","rhand"}) do
  plate(k, (k:find("paul") or k:find("cout") or k:find("hand") or k:find("cuff")) and 0 or math.pi/2)
end

--@ chunk 6
print(wait(3*24*60))
-- the barrel as one long plated cylinder lit from upper left: lit back, dark belly, segment seams over it
local B = nil
for _,k in ipairs(BSEG) do B = B and (B + PM(k)) or PM(k) end
BARREL = B
local top = B * below(function(x) return 680 + 0.012*(x-400) end) * above(function(x) return 600 end)
local mid = B * below(function(x) return 780 end) - top
local bel = B - top - mid
work(bel, {hand="body", pile=SDK, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=B, length={20,60}})
work(mid, {hand="body", pile=SMF, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=B, length={20,60}})
work(top, {hand="body", pile=SMD, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=B, length={20,60}})
work(top * rect(390,600,260,50), {hand="body", pile=SLT, coverage=1.8, tool="filbert 4", angle=0, clip=top, length={10,30}})

--@ chunk 7
print(wait(2*24*60))
local B = BARREL - PM("fairing") - PM("cuirass") - PM("rag")
local top = B * above(function(x) return 672 + 0.012*(x-400) end)
local mid = B * above(function(x) return 770 end) - top
local bel = B - top - mid
work(bel, {hand="body", pile=SDK, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=B, length={20,60}})
work(mid, {hand="body", pile=SMF, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=B, length={20,60}})
work(top, {hand="body", pile=SMD, coverage=3.5, fill=true, tool="filbert 6", angle=0, clip=B, length={20,60}})
work(top * rect(470,600,260,46), {hand="body", pile=SLT, coverage=1.8, tool="filbert 4", angle=0, clip=top, length={10,30}})
-- torso's lower half rebuilt over the barrel's front
plate("fairing", 0, -0.1)
local R = PM("rag") * below(function(x) return 640 end)
work(R, {hand="body", pile=pile{{"rose madder",1.5},{"bone black",0.8},{"Mars red",0.4}}, coverage=3.5, fill=true, tool="filbert 5", angle=math.pi/2, clip=R})
for _,f in ipairs({{326,"L"},{344,"M"},{372,"L"},{390,"M"},{424,"M"}}) do
  local x = f[1]
  local band = R * poly({{x-7,500},{x+7,500},{x+10,850},{x-10,850}})
  work(band, {hand="body", pile=(f[2]=="L") and pile{{"vermilion",1.2},{"Mars red",0.6},{"lead white",0.3}} or pile{{"Mars red",1.4},{"rose madder",1}}, coverage=2.5, fill=true, tool="filbert 3", angle=math.pi/2, clip=R, length={50,140}})
end

--@ chunk 8
print(wait(3*24*60))
local HOT = pile{{"lead white",2.5},{"yellow ochre",0.25}}
local EDGE = pile{{"lead white",1.8},{"ultramarine ash",0.4},{"yellow ochre",0.3}}
local RF = pile{{"burnt sienna",1},{"Mars orange",0.7},{"bone brown",0.4}}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.5}}
local r = brush{kind="round", width=4, point=0.8}
function edges(k, far)
  local pts = NP[k]; local n = #pts
  local cx, cy = 0, 0 for _,q in ipairs(pts) do cx = cx + q[1]/n; cy = cy + q[2]/n end
  for i=1,n do
    local a, b = pts[i], pts[i % n + 1]
    local dx, dy = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(dx*dx+dy*dy)
    if l > 6 then
      local nx, ny = -dy/l, dx/l
      local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
      if (mx-cx)*nx + (my-cy)*ny < 0 then nx, ny = -nx, -ny end
      local facing = -0.8*nx - 0.6*ny
      local p0 = {a[1] - nx*1.6 + dx*0.06, a[2] - ny*1.6 + dy*0.06}
      local p1 = {b[1] - nx*1.6 - dx*0.06, b[2] - ny*1.6 - dy*0.06}
      if facing > 0.45 then
        r:reload((facing > 0.8 and not far) and HOT or EDGE, far and 0.4 or 0.6)
        r:stroke({p0, p1}, {pressure={r:pressure_for(far and 1.4 or 2.2), r:pressure_for(1)}, swell={0.4,1,0.5}})
      elseif nx > 0.6 then
        r:reload(RF, 0.5); r:stroke({p0, p1}, {pressure={r:pressure_for(1.2), r:pressure_for(0.8)}})
      end
      if ny > 0.6 then
        r:reload(SEAM, 0.6); r:stroke({{a[1]+nx*1.5, a[2]+ny*1.5},{b[1]+nx*1.5, b[2]+ny*1.5}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
      end
    end
  end
end
for i=1,3 do for _,p in ipairs({"coxa","fem","kn","tib","ft"}) do edges("f"..i..p, true) end end
for i=1,3 do for _,p in ipairs({"coxa","fem","kn","tib","ft"}) do edges("n"..i..p) end end
for _,k in ipairs({"breech","muzzle","turret","gorget","lrere","rrere","lvamb","rvamb","lcout","rcout","lpaul","rpaul","helm","visor","lcuff","lhand","rhand"}) do edges(k) end
-- barrel: segment seams as dark rings with a lit lip on their sunward side; top edge lit
local xs = {480, 560, 640, 720, 800}
for _,x in ipairs(xs) do
  local ring = {{x+2, 628 + 0.03*(x-400)}, {x+8, 700}, {x+10, 780}, {x+6, 868 - 0.02*(x-400)}}
  r:reload(SEAM, 0.7); r:stroke(ring, {pressure={r:pressure_for(3), r:pressure_for(3)}, clip=BARREL})
  local lipp = {} for _,q in ipairs(ring) do lipp[#lipp+1] = {q[1]-4, q[2]} end
  r:reload(EDGE, 0.5); r:stroke({lipp[1], lipp[2], lipp[3]}, {pressure={r:pressure_for(1.8), r:pressure_for(0.6)}, clip=BARREL})
end
r:reload(HOT, 0.6); r:stroke({{470,624},{560,624},{660,628},{760,633},{860,636}}, {pressure={r:pressure_for(2.6), r:pressure_for(1.2)}, clip=BARREL:grow(3)})
r:reload(RF, 0.5); r:stroke({{500,866},{640,864},{780,862},{860,860}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.2)}, clip=BARREL})

--@ chunk 9
-- folded manipulator arms against the flank, weapon mount on the back
NP.arm1a = {{600,700},{690,690},{694,712},{604,722}}
NP.arm1b = {{690,688},{722,700},{716,770},{694,764},{698,712}}
NP.arm1c = {{606,760},{708,754},{712,774},{610,782}}
NP.arm2a = {{740,708},{820,700},{824,720},{744,728}}
NP.arm2b = {{818,698},{846,708},{840,770},{820,764},{822,720}}
NP.mount = {{700,628},{744,616},{752,638},{708,646}}
for _,k in ipairs({"arm1a","arm1b","arm1c","arm2a","arm2b","mount"}) do plate(k, 0, -0.1) end
local K = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
local clawm = ribbon({{606,782},{596,796},{604,808}}, {6,5,3}) + ribbon({{612,782},{620,798},{612,810}}, {6,5,3})
work(clawm, {hand="detail", pile=K, coverage=4, fill=true, clip=clawm})
-- the wrong plates: pale, inside out, with a dark lip, each folding into a smaller turned copy
local PALE = pile{{"zinc white",2},{"cobalt violet",0.25},{"ultramarine ash",0.3}}
local LIP = pile{{"bone black",2},{"cobalt violet",0.4},{"ultramarine blue",0.4}}
WRONG = {{x=590,y=660,r=26,a=0.2},{x=760,y=820,r=20,a=-0.4},{x=404,y=1030,r=14,a=0.6},{x=294,y=560,r=13,a=1.1}}
for _,w in ipairs(WRONG) do
  local function hexp(cx, cy, r, a, sx)
    local p = {} for i=0,5 do local t = a + i*math.pi/3; p[#p+1] = {cx + r*math.cos(t)*sx, cy + r*math.sin(t)*0.75} end return p
  end
  local o = poly(hexp(w.x, w.y, w.r, w.a, 1.2))
  work(o, {hand="detail", pile=LIP, coverage=4, fill=true, clip=o})
  local i1 = poly(hexp(w.x+1, w.y+1, w.r*0.78, w.a+0.35, 1.2))
  work(i1, {hand="detail", pile=PALE, coverage=4, fill=true, clip=i1})
  local i2 = poly(hexp(w.x+2, w.y+2, w.r*0.48, w.a+0.7, 1.2))
  work(i2, {hand="detail", pile=LIP, coverage=4, fill=true, clip=i2})
  local i3 = poly(hexp(w.x+2.5, w.y+2.5, w.r*0.3, w.a+1.05, 1.2))
  work(i3, {hand="detail", pile=PALE, coverage=4, fill=true, clip=i3})
end
-- floor shadow cast to the right, as in the pair
local fig = FIGM:grow(1)
local shd = poly({{250,1196},{880,1180},{1010,1230},{1010,1320},{700,1290},{300,1215}}, true) * FLOORM - fig
work(shd, {hand="body", pile=pile{{"bone black",1.5},{"bone brown",1}}, coverage=3, fill=true, tool="filbert 10", angle=0.1, clip=shd, edge="soft"})

--@ chunk 10
print(wait(2*24*60))
local r = brush{kind="round", width=4, point=0.8}
local bone = pile{{"lead white",2},{"yellow ochre",0.7},{"raw sienna",0.2}}
local cr = rect(376, 520, 22, 120) + rect(342, 556, 90, 20)
work(cr * PM("rag"), {hand="detail", pile=bone, coverage=3.5, fill=true, clip=cr})
-- rag folds drawn on set paint, healing the seam
local CS = pile{{"rose madder",1.2},{"bone black",1.2},{"ultramarine blue",0.2}}
local CH = pile{{"vermilion",1.2},{"cadmium red",0.6},{"lead white",0.5}}
local R = PM("rag") - cr
local fr = brush{kind="round", width=8, point=0.8}
for _,x in ipairs({336, 410, 440, 456}) do fr:reload(CS, 0.8); fr:stroke({{x,520},{x-2,640},{x+2,760},{x+(x-400)*0.05,840}}, {pressure={fr:pressure_for(1.5), fr:pressure_for(6)}, clip=R}) end
for _,x in ipairs({326, 360, 400}) do fr:reload(CH, 0.6); fr:stroke({{x,650},{x-1,740},{x+2,820}}, {pressure={fr:pressure_for(4), fr:pressure_for(1.2)}, clip=R}) end
fr:reload(CS, 0.6); fr:stroke({{316,636},{360,640},{410,636},{460,640}}, {pressure={fr:pressure_for(3), fr:pressure_for(3)}, clip=R})
fr:reload(CH, 0.5); fr:stroke({{318,648},{360,652},{400,650}}, {pressure={fr:pressure_for(1.5), fr:pressure_for(0.8)}, clip=R})
-- visor slit, optic (cold), a second optic grown wrong
local K = pile{{"bone black",2},{"ultramarine blue",0.4}}
local sl = poly({{330,322},{404,320},{406,334},{330,336}})
work(sl, {hand="detail", pile=K, coverage=5, fill=true, clip=sl})
local CB = pile{{"cerulean blue",1},{"cobalt blue",1},{"zinc white",0.6}}
local CO = pile{{"zinc white",2},{"cerulean blue",1}}
r:reload(CB, 0.7); r:stroke({{348,328},{374,328}}, {pressure={r:pressure_for(5), r:pressure_for(5)}})
r:reload(CO, 0.8); r:touch(358, 328, {pressure=r:pressure_for(3.5)})
r:reload(CB, 0.7); r:touch(392, 350, {pressure=r:pressure_for(2.5)})
-- palm frond on the left pauldron, rosary on the left gauntlet, the crucifix hanging
local GOLD = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.3}}
local stem = {{252,518},{270,490},{296,464},{326,446}}
r:reload(GOLD, 0.7); r:stroke(stem, {pressure={r:pressure_for(2.4), r:pressure_for(1)}})
for i=1,7 do local t=i/8; local x=lerp(252,326,t); local y=lerp(518,446,t); local l=20*(1-t*0.5)
  r:reload(GOLD, 0.5); r:stroke({{x,y},{x-l*0.25,y-l*0.85}}, {pressure={r:pressure_for(1.6),0}})
  r:reload(GOLD, 0.5); r:stroke({{x,y},{x+l*0.8,y+l*0.35}}, {pressure={r:pressure_for(1.6),0}}) end
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
local bead = brush{kind="round", width=10, point=0}
for k=0,1 do for i=0,5 do local t=i/5; local x,y = lerp(242,296,t), 720 + k*22 + 7*math.sin(t*math.pi)
  bead:reload(BB, 0.8); bead:touch(x, y, {pressure=0.85}); if i%2==0 then r:reload(BH,0.5); r:touch(x-2.5,y-2.5,{pressure=0.35}) end end end
for i=1,6 do local x,y = 266+3*math.sin(i*0.7), 772+i*12; bead:reload(BB,0.8); bead:touch(x,y,{pressure=0.8}) end
local cb = brush{kind="round", width=8, point=0.3}
cb:reload(BB, 0.9); cb:stroke({{267,850},{267,902}}, {pressure={cb:pressure_for(7), cb:pressure_for(7)}})
cb:reload(BB, 0.9); cb:stroke({{251,866},{283,866}}, {pressure={cb:pressure_for(7), cb:pressure_for(7)}})
r:reload(BH, 0.6); r:stroke({{264,852},{264,898}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.3)}})
-- cannon coils, lit edge, cold muzzle
local BR = pile{{"burnt sienna",1},{"Mars orange",0.8},{"yellow ochre",0.6}}
for y=232,600,20 do r:reload(BR, 0.6); r:stroke({{521,y},{541,y+5},{561,y}}, {pressure={r:pressure_for(3), r:pressure_for(2.2)}, clip=CANN:grow(2)}) end
r:reload(pile{{"lead white",2.5},{"yellow ochre",0.25}}, 0.6); r:stroke({{523,830},{523,1000},{525,1180}}, {pressure={r:pressure_for(2.2), r:pressure_for(0.8)}})
local mz = poly({{514,134},{566,134},{570,156},{510,156}})
work(mz, {hand="detail", pile=CB, coverage=4, fill=true, clip=mz})
r:reload(CO, 0.7); r:stroke({{522,144},{558,144}}, {pressure={r:pressure_for(3), r:pressure_for(3)}})

--@ chunk 11
print(wait(2*24*60))
local PALE = pile{{"zinc white",2},{"cobalt violet",0.25},{"ultramarine ash",0.3}}
local PALE2 = pile{{"zinc white",1.5},{"cobalt violet",0.4},{"ultramarine ash",0.5},{"bone black",0.1}}
local LIP = pile{{"bone black",2},{"cobalt violet",0.4},{"ultramarine blue",0.4}}
local function quadp(cx, cy, r, a, sx, sy)
  local p = {} for i=0,4 do local t = a + i*2*math.pi/5; p[#p+1] = {cx + r*math.cos(t)*sx, cy + r*math.sin(t)*sy} end return p
end
-- big wrong plates: pentagons turned inside out, each holding a turned smaller copy, spiralling inward
local BIG = {{x=650,y=720,r=58,a=0.3,sx=1.2,sy=0.8},{x=470,y=930,r=30,a=1.0,sx=0.8,sy=1.1},{x=402,y=228,r=22,a=-0.4,sx=1,sy=1},{x=820,y=780,r=34,a=-0.8,sx=0.9,sy=1}}
for _,w in ipairs(BIG) do
  local s, a = 1, w.a
  for d=0,4 do
    local m = poly(quadp(w.x + d*2, w.y + d*1.5, w.r*s, a, w.sx, w.sy))
    work(m, {hand="detail", pile=(d % 2 == 0) and LIP or ((d==1) and PALE or PALE2), coverage=4, fill=true, clip=m})
    s = s * 0.72; a = a + 0.45
  end
end
-- the crucifix and rosary larger, hanging from the left fist
local BB = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
local cb = brush{kind="round", width=10, point=0.3}
local h = brush{kind="round", width=3, point=0.8}
for i=1,6 do local x,y = 266+2*math.sin(i*0.7), 772+i*11; cb:reload(BB,0.8); cb:touch(x,y,{pressure=0.9}); h:reload(BH,0.5); h:touch(x-2.5,y-2.5,{pressure=0.4}) end
cb:reload(BB, 0.9); cb:stroke({{267,842},{267,912}}, {pressure={cb:pressure_for(9), cb:pressure_for(9)}})
cb:reload(BB, 0.9); cb:stroke({{246,862},{288,862}}, {pressure={cb:pressure_for(9), cb:pressure_for(9)}})
h:reload(BH, 0.6); h:stroke({{263,846},{263,908}}, {pressure={h:pressure_for(2), h:pressure_for(1.6)}})
h:reload(BH, 0.6); h:stroke({{249,858},{285,858}}, {pressure={h:pressure_for(2), h:pressure_for(2)}})

--@ chunk 12
local BB = pile{{"bone brown",2},{"burnt sienna",1.2},{"yellow ochre",0.3}}
local cr = rect(258, 836, 12, 70) + rect(242, 852, 44, 11)
local chain = nil
for i=0,6 do local e = ellipse(264 + 2*math.sin(i*0.7), 770 + i*10, 5, 5); chain = chain and (chain + e) or e end
for k=0,1 do for i=0,5 do local t=i/5; chain = chain + ellipse(lerp(244,296,t), 724 + k*22 + 6*math.sin(t*math.pi), 5.5, 5) end end
work(cr + chain, {hand="detail", pile=BB, coverage=5, fill=true, clip=cr + chain})
print(wait(24*60))
local h = brush{kind="round", width=3, point=0.8}
local BH = pile{{"lead white",1.5},{"yellow ochre",0.6}}
h:reload(BH, 0.6); h:stroke({{260,840},{260,902}}, {pressure={h:pressure_for(2), h:pressure_for(1.6)}})
h:reload(BH, 0.6); h:stroke({{246,855},{282,855}}, {pressure={h:pressure_for(2), h:pressure_for(2)}})
for i=0,6,2 do h:reload(BH,0.5); h:touch(262 + 2*math.sin(i*0.7), 768 + i*10, {pressure=0.4}) end
for k=0,1 do for i=0,5,2 do local t=i/5; h:reload(BH,0.5); h:touch(lerp(244,296,t)-2, 722 + k*22 + 6*math.sin(t*math.pi), {pressure=0.4}) end end

--@ chunk 13
local D = pile{{"bone black",2},{"burnt sienna",0.6}}
local cr = rect(258, 836, 12, 70) + rect(242, 852, 44, 11)
local chain = nil
for i=0,6 do local e = ellipse(264 + 2*math.sin(i*0.7), 770 + i*10, 4.5, 4.5); chain = chain and (chain + e) or e end
work(cr + chain, {hand="detail", pile=D, coverage=6, fill=true, clip=cr + chain, load=1})
print(wait(2*24*60))
local h = brush{kind="round", width=3, point=0.8}
local BH = pile{{"lead white",2},{"yellow ochre",0.5}}
h:reload(BH, 0.7); h:stroke({{260,840},{260,902}}, {pressure={h:pressure_for(2.2), h:pressure_for(1.6)}})
h:reload(BH, 0.7); h:stroke({{246,855},{282,855}}, {pressure={h:pressure_for(2.2), h:pressure_for(2)}})
for i=0,6,2 do h:reload(BH,0.5); h:touch(262 + 2*math.sin(i*0.7), 768 + i*10, {pressure=0.4}) end

--@ chunk 14
local r = brush{kind="round", width=6, point=0.8}
local CB = pile{{"cerulean blue",1},{"cobalt blue",1},{"zinc white",0.6}}
local CO = pile{{"zinc white",2},{"cerulean blue",1}}
r:reload(CB, 0.8); r:stroke({{346,328},{378,328}}, {pressure={r:pressure_for(6), r:pressure_for(6)}})
r:reload(CO, 0.9); r:touch(360, 328, {pressure=r:pressure_for(5)})
local g1 = ellipse(360, 328, 40, 26) - poly(NP.visor):shrink(0) * mask(function(x,y) return 0 end)
stipple(ellipse(360,330,40,26), {pile=pile{{"zinc white",2},{"cerulean blue",0.8}}, width=2, pressure={0.3,0.5}, coverage=function(x,y) local d=math.sqrt((x-360)^2+((y-328)*1.5)^2) return 1.6*math.exp(-d/9) end, feather=0.6})
stipple(ellipse(540,140,56,40), {pile=pile{{"zinc white",2},{"cerulean blue",0.8}}, width=2, pressure={0.3,0.5}, coverage=function(x,y) local d=math.sqrt((x-540)^2+((y-140)*1.4)^2) return 1.6*math.exp(-d/12) end, feather=0.6})
