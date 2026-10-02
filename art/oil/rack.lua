-- easel session "rack": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=2.0, linen={18,16}, seed=77, ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=80, apply="knife", texture=0.3},{pile={{"burnt sienna",2},{"ultramarine blue",1},{"yellow ochre",1}}, um=20, apply="brush"}}}

--@ chunk 2
VX, VY = 860, 225
function tovp(x, y) return math.atan(VY - y, VX - x) end
local far = ellipse(VX, VY, 170, 110):blur(40)
local ceil = poly({{0,0},{1000,0},{1000,60},{VX,VY},{0,20}})
local lwall = poly({{0,20},{VX,VY},{0,480}})
local floor = poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local rwall = poly({{1000,60},{VX,VY},{1000,360}})
D_far = pile{{"ultramarine blue",2},{"burnt sienna",1},{"bone black",1.2}}
D_ceil = pile{{"burnt sienna",2},{"ultramarine blue",1.2},{"bone black",0.6}}
D_wall = pile{{"burnt sienna",3},{"ultramarine blue",2},{"raw sienna",1},{"bone black",0.4}}
D_floor = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",1}}
local near = -far
work(ceil * near, {hand="broad", pile=D_ceil, angle=tovp, coverage=3, fill=true})
work(lwall * near, {hand="broad", pile=D_wall, angle=tovp, coverage=3, fill=true})
work(rwall * near, {hand="broad", pile=D_wall, angle=tovp, coverage=3, fill=true})
work(floor * near, {hand="broad", pile=D_floor, angle=tovp, coverage=3, fill=true})
work(far, {hand="body", pile=D_far, angle=tovp, coverage=3.5, fill=true})

--@ chunk 3
SEC = {{-60,30},{300,-20},{760,-25},{1060,50},{1060,370},{760,520},{300,540},{-60,480}}
function sec(s, d)
  local pts = {}
  for i, p in ipairs(SEC) do
    pts[i] = {VX + s * (p[1] - VX), VY + s * (p[2] - VY)}
  end
  return poly(pts, true)
end
D_near = pile{{"bone black",2},{"burnt sienna",1.2},{"ultramarine blue",0.5}}
local farm = ellipse(VX, VY, 150, 95):roughen(10, 60, 5)
work(farm, {hand="body", pile=D_near, angle=function(x,y) return 1.4 + 0.3*math.sin(x/30) end, coverage=3, fill=true, clip=true})
D_rib = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.6}}
for _, s in ipairs({0.9, 0.62, 0.42, 0.27, 0.16}) do
  local band = sec(s) - sec(s * 0.955)
  work(band, {hand="body", pile=D_rib, angle=function(x,y) return tovp(x,y) + 1.5708 end, coverage=3, fill=true, clip=true})
end

--@ chunk 4
D_mid = pile{{"bone black",1.5},{"burnt sienna",1.5},{"ultramarine blue",0.6},{"raw sienna",0.5}}
local ring = ellipse(875, 228, 245, 185):roughen(14, 80, 9) - ellipse(VX, VY, 140, 88)
work(ring, {hand="body", pile=D_mid, angle=function(x,y) return tovp(x,y) + 1.5708 end, coverage=3, fill=true, clip=true})
print(wait(24*60))

--@ chunk 5
print(drying(200,200), drying(700,230), drying(860,225), drying(30,300))

--@ chunk 6
local ring = ellipse(875, 228, 260, 195):roughen(16, 90, 11) - ellipse(VX, VY, 125, 80):roughen(10,50,3)
work(ring, {hand="body", pile=D_near, angle=function(x,y) return tovp(x,y) + 1.5708 end, coverage=3.5, fill=true, clip=true})
G_core = pile{{"lead white",3},{"lemon chrome",1},{"cadmium yellow",0.5}}
G_mid = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",1.5}}
G_out = pile{{"Mars orange",1},{"cadmium red",0.6},{"burnt sienna",0.4}}
FAB = poly({{0,166},{103,175},{103,381},{0,404}})
local inner = poly({{0,186},{88,191},{88,366},{0,386}})
work(FAB - inner, {hand="body", pile=G_mid, angle=1.5708, coverage=4, fill=true, clip=true})
work(inner, {hand="body", pile=G_core, angle=1.5708, coverage=4, fill=true, clip=true})
-- warm spill on the floor and the near wall around the mouth
local pool = poly({{0,405},{140,385},{360,430},{430,500},{0,500}}, true):roughen(12, 70, 4)
work(pool, {hand="scumble", pile=G_out, coverage=1.5, load=0.35, pressure={0.2,0.45}, angle=tovp, clip=true})
local halo = (ellipse(60, 280, 190, 210):roughen(10,60,8) - FAB) * poly({{0,20},{VX,VY},{0,480}})
work(halo, {hand="scumble", pile=G_out, coverage=1.2, load=0.3, pressure={0.15,0.4}, angle=tovp, clip=true})

--@ chunk 7
function eband(cx, cy, rx, ry, r0, r1, seed)
  local o = ellipse(cx, cy, rx*r1, ry*r1):roughen(8, 60, seed or 1)
  if r0 <= 0 then return o end
  return o - ellipse(cx, cy, rx*r0, ry*r0):roughen(8, 60, (seed or 1) + 1)
end
H1 = pile{{"Mars orange",1},{"red earth",1},{"burnt sienna",1}}
H2 = pile{{"burnt sienna",2},{"red earth",1},{"ultramarine blue",0.6}}
H3 = pile{{"burnt sienna",3},{"ultramarine blue",2},{"raw sienna",0.5},{"bone black",0.4}}
local room = -FAB
local cx, cy = 50, 285
local A = {{0, 0.55, H1}, {0.55, 0.85, H2}, {0.85, 1.25, H3}}
for i, a in ipairs(A) do
  local m = eband(cx, cy, 260, 240, a[1], a[2], 10*i) * room
  work(m, {hand="body", pile=a[3], angle=tovp, coverage=3.5, fill=true, clip=true})
end
-- fuse the seams between the halo bands
for i, r in ipairs({0.55, 0.85}) do
  local seam = eband(cx, cy, 260, 240, r - 0.08, r + 0.08, 50 + i) * room
  blend(seam, {angle=tovp})
end
-- far blob: an intermediate ring, then fuse its edges
D_tr = pile{{"bone black",1},{"burnt sienna",2},{"ultramarine blue",1},{"raw sienna",0.3}}
local tr = eband(875, 228, 260, 195, 0.9, 1.12, 70)
work(tr, {hand="body", pile=D_tr, angle=function(x,y) return tovp(x,y)+1.57 end, coverage=3, fill=true, clip=true})
blend(eband(875, 228, 260, 195, 0.82, 1.18, 80), {angle=function(x,y) return tovp(x,y)+1.57 end})

--@ chunk 8
-- tube: a tapered limb; shadow body, lit flank toward the light (light from the left/lower-left), dark core
function shiftpts(pts, dx, dy)
  local o = {}
  for i, p in ipairs(pts) do o[i] = {p[1] + dx, p[2] + dy} end
  return o
end
function widths(w, n, k)
  local o = {}
  for i = 1, n do o[i] = w[i] * k end
  return o
end
function tube(pts, w, P, side)
  side = side or -1
  local n = #pts
  local base = ribbon(pts, w)
  local ang = function(x, y) return math.atan(pts[n][2] - pts[1][2], pts[n][1] - pts[1][1]) end
  work(base, {hand="body", tool="filbert 4", pile=P.base, angle=ang, coverage=3, fill=true, clip=true})
  local wm = 0
  for i = 1, n do wm = wm + w[i] end
  wm = wm / n
  local lit = ribbon(shiftpts(pts, side * wm * 0.22, 0), widths(w, n, 0.42)) * base
  work(lit, {hand="body", tool="filbert 3", pile=P.lit, angle=ang, coverage=2.5, fill=true, clip=true})
  if P.dark then
    local dk = ribbon(shiftpts(pts, -side * wm * 0.33, 0), widths(w, n, 0.22)) * base
    work(dk, {hand="detail", pile=P.dark, angle=ang, coverage=2, fill=true})
  end
  return base
end
function slab(m, P, ang, litm)
  work(m, {hand="body", tool="filbert 4", pile=P.base, angle=ang or 1.57, coverage=3, fill=true, clip=true})
  if litm then
    work(litm * m, {hand="body", tool="filbert 3", pile=P.lit, angle=ang or 1.57, coverage=2.5, fill=true, clip=true})
  end
end
wait(24*60)
A = {base=pile{{"bone brown",1},{"raw sienna",1},{"ultramarine blue",0.4},{"lead white",0.8}},
     lit=pile{{"lead white",3},{"Mars orange",0.5},{"cadmium yellow",0.5},{"yellow ochre",0.5}},
     dark=pile{{"bone black",2},{"burnt sienna",1}}}
J = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
-- chain and yoke
work(ribbon({{200,0},{201,72}}, 4), {hand="detail", pile=J, coverage=3, fill=true})
slab(rect(160, 68, 84, 14), A, 0, rect(160, 68, 40, 14))
-- legs (behind), thighs to dangling feet
tube({{186,282},{183,330},{182,370}}, {30,28,22}, A)
tube({{182,372},{183,410},{185,445}}, {21,19,15}, A)
tube({{223,282},{227,330},{229,370}}, {30,28,22}, A)
tube({{229,372},{228,410},{226,446}}, {21,19,15}, A)
work(ellipse(186,456,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(225,457,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(183,371,11,10) + ellipse(229,371,11,10), {hand="detail", pile=J, coverage=3, fill=true})
-- pelvis and torso
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
slab(pel, A, 0, rect(150, 240, 40, 50))
work(rect(170,240,68,9), {hand="detail", pile=J, coverage=3, fill=true})
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
slab(torso, A, 1.57, poly({{140,100},{195,100},{185,250},{140,250}}))
-- arms
tube({{153,124},{148,165},{145,205}}, {21,19,16}, A)
tube({{145,207},{147,245},{151,285}}, {17,16,13}, A)
tube({{256,126},{261,166},{262,207}}, {21,19,16}, A)
tube({{262,209},{260,248},{256,287}}, {17,16,13}, A)
work(ellipse(151,300,9,15) + ellipse(256,302,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(146,206,10,9) + ellipse(262,208,10,9), {hand="detail", pile=J, coverage=3, fill=true})
-- pauldrons
local lp = ellipse(158, 114, 28, 21)
slab(lp, A, 0.3, ellipse(150, 108, 20, 14))
local rp = ellipse(250, 116, 27, 20)
slab(rp, A, -0.3, ellipse(238, 110, 14, 12))
-- helmet, bowed
work(ribbon({{204,82},{206,96}}, 12), {hand="detail", pile=J, coverage=3, fill=true})
local helm = poly({{188,92},{222,90},{230,110},{224,132},{208,138},{192,130},{185,110}}, true)
slab(helm, A, 1.2, ellipse(195, 106, 13, 20))
work(ribbon({{193,121},{208,126},{223,121}}, 4), {hand="detail", pile=J, coverage=3, fill=true})

--@ chunk 9
B = {base=pile{{"bone black",1.2},{"ultramarine blue",0.6},{"burnt sienna",0.4},{"lead white",0.5}},
     lit=pile{{"lead white",2},{"Mars orange",0.5},{"ultramarine ash",0.5},{"bone black",0.2}},
     dark=pile{{"bone black",2},{"ultramarine blue",1}}}
work(ribbon({{420,84},{421,100}}, 3), {hand="detail", pile=J, coverage=3, fill=true})
slab(rect(392, 98, 58, 9), B, 0, rect(392, 98, 25, 9))
-- sensor mast rising past the rail
work(ribbon({{432,112},{438,80},{446,48}}, {4,3,1.5}), {hand="detail", pile=B.dark, coverage=3, fill=true})
work(ribbon({{437,86},{448,84}}, 2), {hand="detail", pile=B.dark, coverage=3, fill=true})
work(ribbon({{441,66},{452,62}}, 1.6), {hand="detail", pile=B.dark, coverage=3, fill=true})
-- digitigrade legs
tube({{402,230},{399,255},{396,280}}, {20,18,15}, B)
tube({{396,282},{402,306},{408,330}}, {13,12,10}, B)
tube({{408,331},{404,350},{400,370}}, {9,8,6}, B)
tube({{440,230},{444,255},{447,280}}, {20,18,15}, B)
tube({{447,282},{442,306},{436,330}}, {13,12,10}, B)
tube({{436,331},{439,350},{442,372}}, {9,8,6}, B)
work(ellipse(396,281,8,7)+ellipse(447,281,8,7)+ellipse(408,331,6,5)+ellipse(436,331,6,5), {hand="detail", pile=B.dark, coverage=3, fill=true})
-- pelvis, torso
slab(poly({{396,203},{444,203},{448,232},{392,232}}, true), B, 0, rect(380,200,22,40))
local torso = poly({{386,110},{458,110},{454,172},{442,205},{398,205},{388,172}}, true)
slab(torso, B, 1.57, poly({{370,105},{410,105},{405,210},{370,210}}))
work(ribbon({{392,150},{422,156},{452,150}}, 3), {hand="detail", pile=B.dark, coverage=3, fill=true})
-- sensor head: housing with lens bosses
local hd = poly({{410,108},{440,106},{446,124},{434,134},{412,132},{406,120}}, true)
slab(hd, B, 0, ellipse(414,118,9,12))
-- upper arms
tube({{384,120},{378,172},{380,224}}, {14,13,11}, B)
tube({{459,122},{465,175},{461,226}}, {14,13,11}, B)
-- lower arm pair: a long barrel (left), a three-fingered claw (right)
tube({{396,178},{392,206},{388,236}}, {11,10,9}, B)
work(ribbon({{388,232},{386,270},{384,312}}, {8,7,7}), {hand="body", tool="filbert 3", pile=B.base, angle=1.6, coverage=3, fill=true, clip=true})
work(ribbon({{384,236},{383,270},{381,308}}, 2.5), {hand="detail", pile=B.lit, coverage=2, fill=true})
tube({{448,178},{453,205},{456,232}}, {11,10,9}, B)
for _, f in ipairs({{{453,234},{448,250},{450,262}}, {{457,236},{458,254},{462,264}}, {{460,234},{466,246},{468,258}}}) do
  work(ribbon(f, {3,2.5,1.5}), {hand="detail", pile=B.dark, coverage=3, fill=true})
end
work(ellipse(380,226,7,6)+ellipse(461,228,7,6), {hand="detail", pile=B.dark, coverage=3, fill=true})

--@ chunk 10
C = {base=pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.5}},
     lit=pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.6},{"Mars orange",0.3}},
     dark=pile{{"bone black",2},{"burnt sienna",0.5}}}
-- two chains from the rail
work(ribbon({{565,131},{566,170}}, 2.2), {hand="detail", pile=J, coverage=3, fill=true})
work(ribbon({{632,152},{632,190}}, 2.2), {hand="detail", pile=J, coverage=3, fill=true})
-- the quadruped barrel, slung level
local barrel = poly({{548,190},{600,184},{642,188},{652,204},{644,226},{600,232},{556,228},{544,210}}, true)
slab(barrel, C, 0, poly({{530,180},{660,180},{660,200},{530,205}}))
-- four legs dangling, jointed backward
tube({{560,224},{556,252},{560,278}}, {12,10,8}, C)
tube({{560,279},{554,298},{556,318}}, {7,6,4}, C)
tube({{580,228},{582,256},{588,280}}, {11,9,8}, C)
tube({{588,281},{584,300},{586,318}}, {6,5,4}, C)
tube({{622,226},{620,254},{626,278}}, {11,9,8}, C)
tube({{626,279},{620,298},{622,316}}, {6,5,4}, C)
tube({{640,220},{644,248},{650,272}}, {11,9,7}, C)
tube({{650,273},{646,294},{648,314}}, {6,5,4}, C)
-- the upright torso at the front, head bowed, arms hanging
local tor = poly({{544,150},{572,148},{574,190},{566,206},{550,206},{542,188}}, true)
slab(tor, C, 1.57, rect(530,140,20,70))
local hd = ellipse(556, 140, 9, 11)
slab(hd, C, 1.2, ellipse(552, 138, 5, 8))
tube({{542,156},{536,182},{538,212}}, {7,6,5}, C)
tube({{574,158},{580,184},{578,212}}, {7,6,5}, C)
-- a back-mounted cannon, barrel forward past the torso
work(ribbon({{640,182},{600,176},{560,170},{524,166}}, {12,10,8,7}), {hand="body", tool="filbert 3", pile=C.base, angle=3.0, coverage=3, fill=true, clip=true})
work(ribbon({{638,177},{600,172},{560,166},{526,163}}, 2.5), {hand="detail", pile=C.lit, coverage=2, fill=true})
work(ellipse(522,166,3,5), {hand="detail", pile=J, coverage=3, fill=true})
-- a second weapon pod under the belly
work(ribbon({{600,232},{596,250}}, 8), {hand="detail", pile=C.base, coverage=3, fill=true})
work(ribbon({{596,250},{575,262}}, 4), {hand="detail", pile=C.dark, coverage=3, fill=true})

--@ chunk 11
function rib(pts, w0, w1)
  local n = #pts
  local w = {}
  for i = 1, n do w[i] = lerp(w0, w1, (i-1)/(n-1)) end
  return ribbon(pts, w)
end
D4 = {base=pile{{"bone black",1.5},{"ultramarine blue",1},{"burnt sienna",0.3}},
      lit=pile{{"ultramarine ash",1},{"bone black",0.5},{"lead white",0.5},{"Mars orange",0.2}},
      dark=pile{{"bone black",2},{"ultramarine blue",1}}}
work(ribbon({{700,175},{700,206}}, 1.8), {hand="detail", pile=J, coverage=3, fill=true})
work(ribbon({{742,188},{742,212}}, 1.8), {hand="detail", pile=J, coverage=3, fill=true})
local barrel = poly({{690,206},{722,202},{752,206},{760,218},{752,232},{720,236},{694,232},{686,220}}, true)
slab(barrel, D4, 0, poly({{680,198},{770,198},{770,210},{680,213}}))
-- six legs, unequal
local legs = {{{694,228},{690,248},{694,266},{690,284}}, {{706,232},{708,252},{714,268},{711,286}},
              {{720,234},{718,254},{724,270},{722,288}}, {{734,233},{737,250},{735,268},{740,284}},
              {{746,230},{750,248},{748,262},{753,280}}, {{756,224},{762,240},{766,256},{764,272}}}
for _, l in ipairs(legs) do
  work(rib(l, 6, 2.5), {hand="detail", pile=D4.base, coverage=3, fill=true})
  work(ribbon(shiftpts(l, -1.2, 0), 1.4), {hand="detail", pile=D4.lit, coverage=1.5, fill=true})
end
-- front torso stub, hunched, with too many arms
local tor = poly({{684,184},{700,182},{702,208},{688,212},{680,200}}, true)
slab(tor, D4, 1.57, rect(676,180,8,34))
for _, a in ipairs({{{682,192},{674,214},{676,236},{670,250}}, {{686,200},{680,222},{684,244}}, {{698,196},{702,220},{698,240},{702,254}}, {{694,206},{690,230},{692,250},{688,262}}}) do
  work(rib(a, 3.2, 1.2), {hand="detail", pile=D4.base, coverage=3, fill=true})
end
-- sensor masts and antennae bristling off the back
for _, m in ipairs({{{712,204},{710,180},{706,150}}, {{724,202},{726,176},{730,140}}, {{736,204},{740,184},{748,160}}, {{748,206},{756,190},{766,174}}, {{718,203},{714,188},{716,166}}, {{704,186},{698,166},{692,150}}}) do
  work(rib(m, 2.6, 0.9), {hand="detail", pile=D4.dark, coverage=3, fill=true})
end
work(ribbon({{726,160},{738,156}}, 1.2) + ribbon({{708,166},{700,160}}, 1.2) + ribbon({{746,168},{756,170}}, 1.2), {hand="detail", pile=D4.dark, coverage=3, fill=true})
-- grafted organ on the flank: a cold swelling
O1 = pile{{"cobalt violet",1},{"lead white",1},{"cerulean blue",0.5}}
O2 = pile{{"magenta",1},{"cobalt violet",1},{"ultramarine blue",0.5}}
local org = poly({{710,214},{728,210},{744,216},{746,228},{730,234},{714,230}}, true)
work(org, {hand="detail", pile=O2, coverage=3, fill=true})
work(ellipse(724,218,9,4), {hand="detail", pile=O1, coverage=2.5, fill=true})
-- F5: the thing at the end, barely there
D5 = pile{{"bone black",2},{"ultramarine blue",1},{"magenta",0.3}}
local mass = poly({{782,210},{796,204},{812,208},{826,204},{838,214},{834,232},{840,246},{822,244},{806,250},{792,242},{780,236},{786,224}}, true):roughen(2, 12, 3)
work(mass, {hand="detail", pile=D5, coverage=3.5, fill=true})
for _, m in ipairs({{{800,206},{798,190},{804,178}}, {{814,207},{818,188}}, {{826,206},{834,192},{830,180}}, {{790,240},{786,256}}, {{806,248},{808,262}}, {{824,244},{830,258}}, {{836,238},{846,250}}}) do
  work(rib(m, 1.8, 0.7), {hand="detail", pile=D5, coverage=3, fill=true})
end

--@ chunk 12
print(wait(2*24*60))
-- floor: cover the stray orange patch, then plating seams running to the far end
local fl = poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local patch = poly({{270,415},{470,410},{480,500},{270,500}}, true):roughen(10,50,2) * fl
work(patch, {hand="body", pile=D_floor, angle=tovp, coverage=3.5, fill=true, clip=true})
for _, x0 in ipairs({-300, 60, 330, 620, 900, 1250}) do
  local t1 = 0.92
  local p0 = {x0, 520}
  local p1 = {lerp(x0, VX, t1), lerp(520, VY, t1)}
  work(rib({p0, p1}, 3, 0.6) * fl, {hand="detail", pile=J, coverage=2.5, fill=true})
end
-- the rack beam overhead
local beam = rib({{110,-14},{400,74},{600,136},{760,186},{846,213}}, 30, 3)
work(beam, {hand="body", tool="filbert 4", pile=J, angle=0.31, coverage=3.5, fill=true, clip=true})
local under = rib({{110,4},{400,86},{600,143},{760,190},{846,214}}, 3, 0.6)
work(under, {hand="detail", pile=H1, coverage=2, fill=true})
-- F5 back into the dark
work(ellipse(810,228,40,34):roughen(3,15,4), {hand="detail", pile=D_near, coverage=3, fill=true})

--@ chunk 13
print(drying(200,180), drying(160,350), drying(420,150))

--@ chunk 14
S1 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
RIM = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.6}}
local function shade(m, x0)
  return m * poly({{x0,0},{1000,0},{1000,500},{x0,500}})
end
-- torso shadow side, curving with the chest
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
local tsh = torso * poly({{218,95},{280,95},{280,250},{204,250},{212,200},{222,150}}, true)
work(tsh, {hand="body", tool="filbert 4", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true, edge="soft"})
-- pelvis and helmet shadow
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
work(pel * poly({{210,235},{250,235},{250,295},{205,295}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true})
local helm = poly({{188,92},{222,90},{230,110},{224,132},{208,138},{192,130},{185,110}}, true)
work(helm * poly({{210,85},{240,85},{240,140},{204,140}}), {hand="detail", pile=S1, coverage=3.5, fill=true})
-- limbs: shadow down the right flank of each
local limbs = {
  {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{182,372},{183,410},{185,445}}, {21,19,15}},
  {{{223,282},{227,330},{229,370}}, {30,28,22}}, {{{229,372},{228,410},{226,446}}, {21,19,15}},
  {{{153,124},{148,165},{145,205}}, {21,19,16}}, {{{145,207},{147,245},{151,285}}, {17,16,13}},
  {{{256,126},{261,166},{262,207}}, {21,19,16}}, {{{262,209},{260,248},{256,287}}, {17,16,13}}}
for _, L in ipairs(limbs) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  local sh = ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base
  work(sh, {hand="detail", pile=S1, coverage=3, fill=true})
  -- hot rim down the lit edge
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base, {hand="detail", pile=RIM, coverage=2, fill=true})
end
work(ellipse(260,116,16,18) * ellipse(250,116,27,20), {hand="detail", pile=S1, coverage=3, fill=true})
work(ellipse(166,118,10,14) * ellipse(158,114,28,21), {hand="detail", pile=S1, coverage=2.5, fill=true})
-- plate seams on chest and belly
for _, s in ipairs({{{160,150},{185,160},{204,162},{222,160},{248,150}}, {{170,198},{204,206},{238,198}}, {{176,224},{204,230},{230,224}}, {{204,108},{204,240}}}) do
  work(rib(s, 2, 1.6), {hand="detail", pile=J, coverage=2.5, fill=true})
end
-- rims on torso, pauldron and helmet left edges
work(rib({{153,108},{156,170},{168,215},{182,242}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{132,116},{140,102},{158,94},{176,100}}, 2.6, 1.6), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{188,96},{186,112},{192,130}}, 2.2, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{172,246},{170,286}}, 2, 1.5), {hand="detail", pile=RIM, coverage=2.5, fill=true})

--@ chunk 15
-- helmet: bowed dome, dark gorget behind it so it separates from the chest
work(ellipse(207,134,22,8), {hand="detail", pile=S1, coverage=3, fill=true})
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(helm, {hand="detail", pile=A.base, coverage=3, fill=true})
work(helm * poly({{212,80},{240,80},{240,140},{208,140}}), {hand="detail", pile=S1, coverage=3, fill=true})
work(helm:rim(2.2, 0.5), {hand="detail", pile=J, coverage=2.5, fill=true})
-- visor: a dark T, the cross-shaped sight of a Church helm
work(rib({{193,116},{207,121},{222,116}}, 4.5, 4.5) + rib({{207,104},{207,128}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3, fill=true})
work(rib({{190,94},{196,88},{206,85}}, 2.2, 1.2) + rib({{189,104},{190,118}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2.5, fill=true})
-- gauntlets: fingers hanging
for _, h in ipairs({{151,292}, {256,294}}) do
  local x, y = h[1], h[2]
  work(ellipse(x, y, 10, 13), {hand="detail", pile=S1, coverage=3, fill=true})
  for k = -1, 2 do
    work(rib({{x + k*4.5, y + 6}, {x + k*4.8 + 1, y + 20}, {x + k*4.5 + 2, y + 27}}, 3.6, 2.4), {hand="detail", pile=A.base, coverage=3, fill=true})
  end
  work(rib({{x-9, y-8}, {x-9, y+10}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2, fill=true})
end
-- crimson cloth over the yoke and the left shoulder
CRs = pile{{"rose madder",1},{"burnt sienna",0.8},{"bone black",0.3}}
CR = pile{{"vermilion",1},{"cadmium red",1},{"rose madder",0.4}}
CRL = pile{{"vermilion",1},{"cadmium red",0.6},{"lead white",0.4},{"Mars orange",0.4}}
local cloth = poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true):roughen(1.5, 14, 6)
work(cloth, {hand="body", tool="filbert 3", pile=CRs, angle=1.57, coverage=3.5, fill=true, clip=true})
for _, f in ipairs({{{170,70},{168,110},{170,160},{176,200}}, {{182,68},{180,120},{182,175}}, {{160,90},{164,130},{168,170}}}) do
  work(rib(f, 5, 2) * cloth, {hand="detail", pile=CR, coverage=2.5, fill=true})
end
work(rib({{158,86},{160,120},{166,160},{172,198}}, 2.4, 1.2) * cloth, {hand="detail", pile=CRL, coverage=2.5, fill=true})
-- the cross-hem fringe
work(rib({{168,204},{176,212},{184,214}}, 2, 1.5), {hand="detail", pile=CRs, coverage=3, fill=true})

--@ chunk 16
wait(2*24*60)
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(helm * poly({{150,80},{209,80},{209,140},{150,140}}), {hand="body", tool="filbert 3", pile=A.base, angle=1.57, coverage=4, fill=true, clip=true})
work(helm * poly({{209,80},{240,80},{240,140},{209,140}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=4, fill=true, clip=true})
work(helm:rim(2.4, 0.4), {hand="detail", tool={kind="round", width=2.4}, pile=J, coverage=3, fill=true})
work(rib({{193,115},{207,120},{222,115}}, 5, 5) + rib({{207,100},{207,129}}, 4, 4), {hand="detail", tool={kind="round", width=3}, pile=J, coverage=3.5, fill=true})
work(rib({{191,96},{197,89},{207,86}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=3, fill=true})
-- rosary from the hook: bone beads in a loop, a small brass cross
BEAD = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.3}}
BR = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",1}}
local bb = brush{kind="round", width=3.2, point=0.3}
local loop = {}
for i = 0, 26 do
  local t = i / 26
  local x = 201 + 30 * math.sin(t * math.pi) + 6 * t
  local y = 70 + 105 * math.sin(t * math.pi * 0.5) ^ 1.2 * (1 - 0.25 * t)
  loop[#loop+1] = {x, y}
end
for i, p in ipairs(loop) do
  if i % 2 == 0 then bb:reload(BEAD, 0.7) else bb:reload(J, 0.5) end
  bb:touch(p[1], p[2], {pressure=0.7})
end
local e = loop[#loop]
work(rib({{e[1], e[2]}, {e[1]+1, e[2]+18}}, 2.4, 2.2) + rib({{e[1]-5, e[2]+6}, {e[1]+6, e[2]+6}}, 2.2, 2.2), {hand="detail", tool={kind="round", width=2}, pile=BR, coverage=3, fill=true})
-- F2: shadow flank, darker overall, a separated sensor head
S2 = pile{{"bone black",1.5},{"ultramarine blue",1},{"burnt sienna",0.5}}
local torso2 = poly({{386,110},{458,110},{454,172},{442,205},{398,205},{388,172}}, true)
work(torso2 * poly({{418,100},{470,100},{470,215},{412,215},{416,160}}, true), {hand="body", tool="filbert 3", pile=S2, angle=1.57, coverage=4, fill=true, clip=true})
local lim2 = {
  {{{402,230},{399,255},{396,280}}, {20,18,15}}, {{{396,282},{402,306},{408,330}}, {13,12,10}}, {{{408,331},{404,350},{400,370}}, {9,8,6}},
  {{{440,230},{444,255},{447,280}}, {20,18,15}}, {{{447,282},{442,306},{436,330}}, {13,12,10}}, {{{436,331},{439,350},{442,372}}, {9,8,6}},
  {{{384,120},{378,172},{380,224}}, {14,13,11}}, {{{459,122},{465,175},{461,226}}, {14,13,11}},
  {{{396,178},{392,206},{388,236}}, {11,10,9}}, {{{448,178},{453,205},{456,232}}, {11,10,9}}}
for _, L in ipairs(lim2) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(ribbon(shiftpts(pts, w[2]*0.25, 0), widths(w, 3, 0.55)) * base, {hand="detail", pile=S2, coverage=3, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.3) * base, {hand="detail", pile=H1, coverage=2, fill=true})
end
work(poly({{396,203},{444,203},{448,232},{392,232}}, true) * rect(418,195,40,45), {hand="detail", pile=S2, coverage=3.5, fill=true})
local hd = poly({{410,108},{440,106},{446,124},{434,134},{412,132},{406,120}}, true)
work(hd * rect(424,100,30,40), {hand="detail", pile=S2, coverage=3.5, fill=true})
work(hd:rim(2, 0.4), {hand="detail", pile=J, coverage=3, fill=true})
GL = pile{{"zinc white",2},{"cerulean blue",1}}
for _, p in ipairs({{416,121},{424,124},{431,120}}) do
  work(ellipse(p[1], p[2], 2.6, 2.6), {hand="detail", pile=J, coverage=3, fill=true})
end
work(rib({{388,114},{386,150},{392,190}}, 1.8, 1.2), {hand="detail", pile=H1, coverage=2.5, fill=true})

--@ chunk 17
S3 = pile{{"bone black",1.5},{"burnt sienna",1},{"ultramarine blue",0.6}}
-- F3: belly and right flank into shadow
local barrel = poly({{548,190},{600,184},{642,188},{652,204},{644,226},{600,232},{556,228},{544,210}}, true)
work(barrel * poly({{530,206},{670,198},{670,240},{530,240}}), {hand="body", tool="filbert 3", pile=S3, angle=0.05, coverage=4, fill=true, clip=true})
work(barrel * poly({{620,180},{670,180},{670,240},{612,240}}), {hand="detail", pile=S3, coverage=3.5, fill=true})
local tor = poly({{544,150},{572,148},{574,190},{566,206},{550,206},{542,188}}, true)
work(tor * rect(560,140,20,70), {hand="detail", pile=S3, coverage=3.5, fill=true})
work(ellipse(556,140,9,11) * rect(557,128,12,24), {hand="detail", pile=S3, coverage=3.5, fill=true})
local lim3 = {
  {{{560,224},{556,252},{560,278}}, {12,10,8}}, {{{560,279},{554,298},{556,318}}, {7,6,4}},
  {{{580,228},{582,256},{588,280}}, {11,9,8}}, {{{588,281},{584,300},{586,318}}, {6,5,4}},
  {{{622,226},{620,254},{626,278}}, {11,9,8}}, {{{626,279},{620,298},{622,316}}, {6,5,4}},
  {{{640,220},{644,248},{650,272}}, {11,9,7}}, {{{650,273},{646,294},{648,314}}, {6,5,4}},
  {{{542,156},{536,182},{538,212}}, {7,6,5}}, {{{574,158},{580,184},{578,212}}, {7,6,5}}}
for _, L in ipairs(lim3) do
  local pts, w = L[1], L[2]
  work(ribbon(shiftpts(pts, w[2]*0.2, 0), widths(w, 3, 0.65)) * ribbon(pts, w), {hand="detail", pile=S3, coverage=3, fill=true})
end
work(rib({{556,200},{600,206},{646,200}}, 1.8, 1.8) + rib({{598,188},{598,230}}, 1.6, 1.6), {hand="detail", pile=J, coverage=3, fill=true})
-- F4: belly shadow
local b4 = poly({{690,206},{722,202},{752,206},{760,218},{752,232},{720,236},{694,232},{686,220}}, true)
work(b4 * poly({{680,222},{770,218},{770,240},{680,240}}), {hand="detail", pile=D4.dark, coverage=3.5, fill=true})
-- F5: the thing at the end, much larger than it should be, barely separated from the dark
D5b = pile{{"bone black",2},{"ultramarine blue",1.2},{"burnt sienna",0.6}}
local thing = poly({{772,214},{784,186},{800,176},{812,160},{826,170},{846,158},{866,174},{884,170},{900,194},{906,224},{896,250},{902,276},{884,290},{860,280},{842,296},{820,284},{798,292},{786,270},{770,256}}, true):roughen(4, 20, 13)
work(thing, {hand="body", tool="filbert 3", pile=D5b, angle=function(x,y) return 1.2 + 0.8*math.sin(y/9 + x/13) end, coverage=3.5, fill=true, clip=true})
print(wait(2*24*60))

--@ chunk 18
COLD = pile{{"ultramarine ash",1},{"bone black",0.6},{"zinc white",0.4},{"cerulean blue",0.3}}
EYE = pile{{"zinc white",2},{"cerulean blue",1},{"emerald green",0.2}}
-- masts and antlers rising out of it, past the rail
local masts = {{{800,180},{796,150},{790,122}}, {{812,166},{814,136},{808,104}}, {{828,170},{834,140},{846,112}},
  {{846,162},{850,130},{844,98}}, {{866,176},{874,150},{888,128}}, {{884,174},{896,156},{912,148}},
  {{820,168},{818,150},{826,132}}, {{858,166},{862,140},{870,120}}, {{790,190},{778,170},{772,150}}}
for _, m in ipairs(masts) do
  work(rib(m, 2.2, 0.7), {hand="detail", pile=D5b, coverage=3, fill=true})
  work(rib(shiftpts(m, -0.9, 0), 0.8, 0.5), {hand="detail", pile=COLD, coverage=1.5, fill=true})
end
for _, c in ipairs({{{808,128},{818,122}}, {{846,126},{856,118}}, {{834,140},{826,134}}, {{874,150},{882,140}}}) do
  work(rib(c, 1, 0.6), {hand="detail", pile=D5b, coverage=3, fill=true})
end
-- dangling manipulators, too many
local hang = {{{782,262},{778,288},{782,312}}, {{794,284},{792,306},{798,326}}, {{810,284},{814,308},{808,330}},
  {{826,286},{824,310},{830,322}}, {{844,292},{848,312},{842,334}}, {{862,282},{866,300},{872,318}},
  {{880,286},{878,304},{884,318}}, {{896,270},{902,290},{898,306}}, {{804,288},{800,300}}, {{854,290},{850,306}}}
for _, h in ipairs(hang) do
  work(rib(h, 2, 0.6), {hand="detail", pile=D5b, coverage=3, fill=true})
end
-- a cold rim along its upper edge
work(rib({{774,212},{784,188},{800,178},{812,162},{826,172},{846,160},{866,176}}, 1.4, 0.8), {hand="detail", pile=COLD, coverage=2, fill=true})
-- eyes: a cluster of pale lenses
local bb = brush{kind="round", width=1.8, point=0.4}
for i, p in ipairs({{792,206},{797,201},{801,209},{794,214},{806,204},{789,219},{803,217},{811,211},{798,224},{786,228},{808,226}}) do
  bb:reload(EYE, 0.55)
  bb:touch(p[1], p[2], {pressure=0.25 + 0.03 * (i % 4)})
end
-- grafted organs glowing dimly
work(poly({{828,226},{850,218},{872,228},{870,246},{846,252},{830,244}}, true):roughen(2,10,5), {hand="detail", pile=O2, coverage=2.5, fill=true})
work(ellipse(850,234,11,6), {hand="detail", pile=O1, coverage=2, fill=true})
work(ellipse(880,206,7,10), {hand="detail", pile=O2, coverage=2.5, fill=true})

--@ chunk 19
wait(24*60)
-- mute the organs back into the dark, leaving smeared fragments
work(poly({{826,222},{852,214},{876,226},{874,250},{846,256},{826,246}}, true), {hand="detail", pile=D5b, coverage=2.6, fill=true})
work(ellipse(880,206,9,12), {hand="detail", pile=D5b, coverage=3, fill=true})
OS = pile{{"cobalt violet",1},{"bone black",0.5},{"zinc white",0.5},{"ultramarine blue",0.3}}
for _, s in ipairs({{{832,236},{846,231},{862,238}}, {{840,244},{856,246},{868,240}}, {{876,198},{882,208},{878,218}}}) do
  work(rib(s, 2.4, 1), {hand="detail", pile=OS, coverage=1.8, fill=true})
end
-- faceted plates catching a little cold light, breaking the silhouette
FAC = pile{{"bone black",1},{"ultramarine ash",1},{"burnt sienna",0.3}}
for _, f in ipairs({ {{786,196},{806,186},{812,200},{794,210}}, {{816,176},{840,168},{844,182},{822,190}},
   {{852,178},{872,182},{878,196},{858,196}}, {{776,236},{790,228},{796,248},{780,254}},
   {{884,236},{904,228},{908,250},{890,258}}, {{812,256},{834,262},{828,280},{808,276}} }) do
  work(poly(f), {hand="detail", pile=FAC, coverage=3, fill=true})
end
-- inconsistent seams: thin cold lines that don't agree with the shape
for _, l in ipairs({{{796,182},{830,262}}, {{820,170},{788,250}}, {{868,190},{846,280}}, {{900,214},{860,268}}}) do
  work(rib(l, 1, 0.6), {hand="detail", pile=COLD, coverage=1.6, fill=true})
end
-- larger eyes, a cluster of them
local bb = brush{kind="round", width=3, point=0.3}
for i, p in ipairs({{794,204},{801,210},{796,218},{806,201},{810,214},{789,224},{803,224}}) do
  bb:reload(EYE, 0.6)
  bb:touch(p[1], p[2], {pressure=0.35 + 0.08 * (i % 3)})
end

--@ chunk 20
wait(24*60)
function beamy(x) return 225 - 0.317 * (860 - x) end
D_c2 = pile{{"burnt sienna",2},{"ultramarine blue",1.4},{"bone black",1}}
D_c3 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1}}
local ceil = above(function(x) return beamy(x) - 16 end) - rect(420,30,45,80) - rect(670,0,330,260)
local ceilnear = ceil * poly({{0,0},{360,0},{300,200},{0,200}})
local ceilfar = ceil - ceilnear
work(ceilfar, {hand="body", pile=D_c3, angle=tovp, coverage=3.5, fill=true, clip=true, edge="soft"})
work(ceilnear, {hand="body", pile=D_c2, angle=tovp, coverage=3, fill=true, clip=true, edge="soft"})
-- floor beyond the hanging feet: darker, the warm pool kept near the mouth
local floorm = below(function(x) return 225 + 0.39 * (860 - x) + 4 end) * poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local poolkeep = ellipse(60, 470, 260, 90):roughen(10, 60, 21)
work(floorm - poolkeep, {hand="body", pile=D_c3, angle=tovp, coverage=3.5, fill=true, clip=true})
work(floorm * poolkeep - ellipse(40, 480, 170, 60), {hand="body", pile=H2, angle=tovp, coverage=3, fill=true, clip=true})

--@ chunk 21
D_fw = pile{{"burnt sienna",2},{"bone black",1},{"red earth",0.5},{"ultramarine blue",0.3}}
D_ff = pile{{"burnt sienna",1.5},{"bone black",1.5},{"ultramarine blue",0.5}}
-- the notch round F2's mast
local mast = rib({{432,112},{438,80},{446,48}}, 9, 6) + rib({{437,86},{448,84}}, 6, 6) + rib({{441,66},{452,62}}, 5, 5)
work(rect(420,30,45,58) - mast, {hand="detail", pile=D_c2, coverage=3.5, fill=true})
-- floor warmed: a warm dark near, cooler going away; the seam softened
local floorm = below(function(x) return 225 + 0.39 * (860 - x) - 6 end) * poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local nearf = floorm * poly({{0,300},{560,300},{760,500},{0,500}}, true)
work(nearf - ellipse(40, 480, 170, 60), {hand="body", pile=D_fw, angle=tovp, coverage=3.5, fill=true, clip=true, edge="soft"})
work(floorm - nearf, {hand="body", pile=D_ff, angle=tovp, coverage=3.5, fill=true, clip=true, edge="soft"})
-- the same warm dark low on the left wall under the frames, so floor and wall meet
local lowwall = poly({{240,500},{260,430},{470,372},{640,320},{800,262},{860,240},{860,300},{600,400},{300,500}}, true)
work(lowwall * -floorm, {hand="body", pile=D_fw, angle=tovp, coverage=2.5, fill=true, clip=true, edge="soft"})

--@ chunk 22
wait(24*60)
D_fd = pile{{"bone black",2},{"burnt sienna",1.5},{"red earth",0.3}}
D_fx = pile{{"bone black",2.5},{"burnt sienna",1},{"ultramarine blue",0.6}}
local fl = poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
-- everything under the line from the near feet to the far thing's dangling arms
local low = below(function(x) return 225 + 0.39 * (860 - x) + 2 end)
local zoneA = (fl + low) * poly({{0,250},{1000,250},{1000,500},{0,500}}) - ellipse(40, 480, 200, 70):roughen(8,40,3)
local mid = zoneA * poly({{280,250},{620,250},{620,500},{280,500}})
local far = zoneA * poly({{620,250},{1000,250},{1000,500},{620,500}})
local near = zoneA - mid - far
work(near, {hand="body", pile=D_fd, angle=tovp, coverage=4, load=1, fill=true, clip=true})
work(mid, {hand="body", pile=D_fd, angle=tovp, coverage=4.5, load=1, fill=true, clip=true})
work(far, {hand="body", pile=D_fx, angle=tovp, coverage=4.5, load=1, fill=true, clip=true})
work(rect(420,30,45,60) - rib({{432,112},{438,80},{446,48}}, 8, 5) - rib({{437,86},{448,84}}, 5, 5) - rib({{441,66},{452,62}}, 4, 4), {hand="detail", pile=D_c3, coverage=4, fill=true})

--@ chunk 23
local fl = poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local low = below(function(x) return 225 + 0.39 * (860 - x) + 2 end)
local zoneA = (fl + low) * poly({{0,250},{1000,250},{1000,500},{0,500}})
blend(rect(596,240,48,260) * zoneA, {angle=0})
blend(rect(258,240,44,260) * zoneA, {angle=0})
blend(rect(620,236,380,30), {angle=1.57})

--@ chunk 24
local fl = poly({{0,480},{VX,VY},{1000,360},{1000,500},{0,500}})
local low = below(function(x) return 225 + 0.39 * (860 - x) + 2 end)
local zoneA = (fl + low) * poly({{0,250},{1000,250},{1000,500},{0,500}}) - ellipse(40, 480, 200, 70):roughen(8,40,3)
D_fu = pile{{"bone black",2.2},{"burnt sienna",1.3},{"ultramarine blue",0.3}}
work(zoneA * poly({{150,250},{1000,250},{1000,500},{150,500}}), {hand="body", pile=D_fu, angle=tovp, coverage=3.5, load=1, fill=true, clip=true})
print(wait(2*24*60))

--@ chunk 25
-- cast shadows on the floor, thrown right, away from the mouth
SH = pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.6}}
work(poly({{176,470},{214,462},{330,470},{340,486},{220,490},{180,484}}, true):roughen(3,20,2), {hand="body", tool="filbert 3", pile=SH, angle=0.1, coverage=3.5, fill=true, clip=true})
-- F1: lower legs and dangling feet, over the floor
for _, L in ipairs({ {{{182,372},{183,410},{185,445}}, {21,19,15}}, {{{229,372},{228,410},{226,446}}, {21,19,15}} }) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(base * poly({{0,410},{1000,410},{1000,500},{0,500}}), {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base * poly({{0,410},{1000,410},{1000,500},{0,500}}), {hand="detail", pile=S1, coverage=3, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base * poly({{0,412},{1000,412},{1000,500},{0,500}}), {hand="detail", pile=RIM, coverage=2, fill=true})
end
for _, f in ipairs({{186,457},{225,458}}) do
  local fm = poly({{f[1]-9,f[2]-12},{f[1]+9,f[2]-12},{f[1]+7,f[2]+10},{f[1]+1,f[2]+18},{f[1]-6,f[2]+10}}, true)
  work(fm, {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(fm * rect(f[1]+1, f[2]-14, 12, 34), {hand="detail", pile=S1, coverage=3, fill=true})
  work(rib({{f[1]-8,f[2]-10},{f[1]-6,f[2]+8}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2, fill=true})
end
-- F5: its lower body sags below where the floor should be; arms reach and pool on the floor
local lowerbody = poly({{770,236},{790,240},{840,238},{896,244},{904,268},{886,292},{860,282},{840,300},{818,286},{796,294},{780,272}}, true):roughen(4, 20, 17)
work(lowerbody, {hand="body", tool="filbert 3", pile=D5b, angle=1.3, coverage=3.5, fill=true, clip=true})
local hang = {{{782,262},{776,292},{782,318},{770,332}}, {{794,284},{792,310},{798,330},{790,344}}, {{810,284},{814,310},{808,334},{816,350}},
  {{826,286},{824,312},{832,330},{846,342}}, {{844,292},{848,316},{842,338},{830,352}}, {{862,282},{868,304},{874,322},{890,330}},
  {{880,286},{878,306},{886,320},{900,326}}, {{896,270},{904,292},{900,308},{912,318}}}
for _, h in ipairs(hang) do
  work(rib(h, 2.2, 0.7), {hand="detail", pile=D5b, coverage=3, fill=true})
  work(rib(shiftpts(h, -0.8, 0), 0.7, 0.4), {hand="detail", pile=COLD, coverage=1.2, fill=true})
end
-- F4 leg tips again
for _, l in ipairs({{{694,266},{690,284}}, {{714,268},{711,286}}, {{724,270},{722,288}}, {{735,268},{740,284}}}) do
  work(rib(l, 3.5, 2.5), {hand="detail", pile=D4.base, coverage=3, fill=true})
end

--@ chunk 26
-- dissolve the floor's edge with warm light dragged across it from the mouth's side
local low = below(function(x) return 225 + 0.39 * (860 - x) + 2 end) * poly({{230,250},{760,250},{760,500},{230,500}})
lose(low, {pile=D_fw, reach={14, 22}, load=0.3, tool="filbert 4", angle=-0.6})
-- light streaks reflected on the floor from the fabricator mouth
REF = pile{{"Mars orange",1},{"red earth",1},{"burnt sienna",0.6},{"lead white",0.3}}
local bb = brush("filbert", 3)
for i, s in ipairs({{{110,440},{300,470}}, {{120,460},{330,492}}, {{130,425},{280,445}}, {{240,438},{420,452}}, {{260,456},{470,474}}}) do
  bb:reload(REF, 0.35)
  bb:stroke(s, {pressure={0.45, 0.05}, ramps={0.05, 0.6}})
end
-- F2: knock the pale flank down to gunmetal, keep a lit edge; seams across the dark half
B2 = pile{{"bone black",1},{"ultramarine ash",1},{"burnt sienna",0.4},{"lead white",0.25}}
local torso2 = poly({{386,110},{458,110},{454,172},{442,205},{398,205},{388,172}}, true)
work(torso2 * poly({{392,100},{418,100},{416,160},{412,215},{394,215}}, true), {hand="body", tool="filbert 3", pile=B2, angle=1.57, coverage=3.5, fill=true, clip=true})
work(rib({{389,112},{388,150},{392,180},{400,204}}, 2.2, 1.6), {hand="detail", pile=H1, coverage=2.5, fill=true})
for _, s in ipairs({{{390,135},{420,140},{456,134}}, {{392,176},{420,182},{452,176}}, {{420,112},{420,204}}}) do
  work(rib(s, 1.6, 1.6), {hand="detail", pile=J, coverage=2.5, fill=true})
end
-- a warm reflected light down the shadowed flank of F2's torso
work(rib({{452,118},{453,160},{446,196}}, 1.6, 1), {hand="detail", pile=H2, coverage=2, fill=true})

--@ chunk 27
wait(24*60)
local inner = poly({{0,186},{88,191},{88,366},{0,386}})
-- even out the glow
work(inner, {hand="body", tool="filbert 4", pile=G_core, angle=1.57, coverage=3, fill=true, clip=true})
-- the gantry and the next body being printed, bottom up, backlit
SIL = pile{{"burnt sienna",1},{"bone black",1},{"Mars orange",0.4}}
work(rib({{0,214},{88,212}}, 7, 6) * inner, {hand="detail", pile=SIL, coverage=3.5, fill=true})
work(rib({{54,214},{52,250},{48,262}}, 5, 3) * inner, {hand="detail", pile=SIL, coverage=3.5, fill=true})
work(rib({{48,262},{44,270}}, 2, 1) * inner, {hand="detail", pile=G_mid, coverage=3, fill=true})
local printed = (rib({{30,380},{31,340},{33,305}}, 12, 15) + rib({{58,380},{57,340},{55,305}}, 12, 15) + poly({{24,300},{64,300},{62,276},{26,276}}, true)) * inner
work(printed, {hand="detail", pile=SIL, coverage=3.5, fill=true})
-- the hot line where the layer is being laid
work(rib({{24,276},{44,272},{64,276}}, 2.6, 2.6), {hand="detail", pile=G_mid, coverage=3, fill=true})
-- glow halation around the mouth edge
work(rib({{103,176},{103,380}}, 3, 3), {hand="detail", pile=G_mid, coverage=2.5, fill=true})

--@ chunk 28
-- F5: the tan facets back into cold darks, with only a faint cold edge each
FAC2 = pile{{"bone black",2},{"ultramarine blue",0.8},{"cobalt violet",0.3}}
for _, f in ipairs({ {{786,196},{806,186},{812,200},{794,210}}, {{816,176},{840,168},{844,182},{822,190}},
   {{852,178},{872,182},{878,196},{858,196}}, {{776,236},{790,228},{796,248},{780,254}},
   {{884,236},{904,228},{908,250},{890,258}}, {{812,256},{834,262},{828,280},{808,276}} }) do
  work(poly(f):grow(1.5), {hand="detail", pile=FAC2, coverage=4, fill=true})
  work(rib({f[1], f[2]}, 1, 0.8), {hand="detail", pile=COLD, coverage=1.5, fill=true})
end
-- eyes: a few larger pale lenses, some smaller
for _, e in ipairs({{796,206,2.6},{805,212,2.0},{792,218,1.6},{809,202,1.5},{800,222,1.3},{787,226,1.1},{814,218,1.1}}) do
  work(ellipse(e[1], e[2], e[3], e[3]), {hand="detail", pile=EYE, coverage=3, fill=true})
end
-- F3: warm rims along the top of the barrel, the cannon and the torso
for _, s in ipairs({{{548,192},{574,186},{600,184},{630,186}}, {{545,152},{544,170},{544,188}}, {{548,132},{552,129},{558,130}}, {{538,160},{534,184},{536,208}}}) do
  work(rib(s, 1.6, 1.1), {hand="detail", pile=CRL, coverage=2.2, fill=true})
end
-- F1: specular lights on the lit planes
SPEC = pile{{"lead white",3},{"lemon chrome",0.4},{"cadmium yellow",0.3}}
for _, s in ipairs({{{140,104},{150,98},{162,96}}, {{193,92},{199,88}}, {{162,130},{164,170},{170,200}}, {{176,250},{178,270}}, {{174,300},{173,340}}, {{176,380},{177,420}}, {{142,135},{140,180}}, {{141,215},{143,260}}}) do
  work(rib(s, 2.2, 1.2), {hand="detail", pile=SPEC, coverage=2.2, fill=true})
end

--@ chunk 29
-- break the halo's rings with strokes running toward the far end
local wall = poly({{0,20},{VX,VY},{0,480}}) - FAB
local halo = ellipse(50, 285, 330, 290) * wall * poly({{0,0},{330,0},{330,500},{0,500}})
work(halo, {hand="scumble", pile=H2, coverage=0.8, load=0.3, pressure={0.15,0.35}, angle=tovp, clip=true})
work(ellipse(70, 280, 170, 170) * wall * poly({{0,0},{330,0},{330,500},{0,500}}), {hand="scumble", pile=H1, coverage=0.6, load=0.3, pressure={0.15,0.3}, angle=tovp, clip=true})
-- conduits along the ceiling running into the dark, and slack cables between hooks
CON = pile{{"bone black",2},{"burnt sienna",1}}
for _, c in ipairs({{{0,60},{300,95},{600,160},{820,214}}, {{180,0},{500,90},{700,165},{835,212}}, {{1000,40},{940,120},{880,200}}}) do
  work(rib(c, 7, 1.2), {hand="detail", pile=CON, coverage=3, fill=true})
end
work(rib({{0,56},{300,91},{600,157}}, 1.5, 0.8), {hand="detail", pile=H1, coverage=2, fill=true})
for _, k in ipairs({{{212,22},{280,58},{340,62},{410,84}}, {{440,92},{480,120},{530,124},{562,130}}, {{640,154},{660,170},{684,172},{700,175}}}) do
  work(rib(k, 2, 1.4), {hand="detail", pile=CON, coverage=3, fill=true})
end

--@ chunk 30
wait(24*60)
A = {base=pile{{"bone brown",1},{"raw sienna",1},{"ultramarine blue",0.4},{"lead white",0.8}},
     lit=pile{{"lead white",3},{"Mars orange",0.5},{"cadmium yellow",0.5},{"yellow ochre",0.5}},
     dark=pile{{"bone black",2},{"burnt sienna",1}}}
J = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3}}
-- chain and yoke
work(ribbon({{200,0},{201,72}}, 4), {hand="detail", pile=J, coverage=3, fill=true})
slab(rect(160, 68, 84, 14), A, 0, rect(160, 68, 40, 14))
-- legs (behind), thighs to dangling feet
tube({{186,282},{183,330},{182,370}}, {30,28,22}, A)
tube({{182,372},{183,410},{185,445}}, {21,19,15}, A)
tube({{223,282},{227,330},{229,370}}, {30,28,22}, A)
tube({{229,372},{228,410},{226,446}}, {21,19,15}, A)
work(ellipse(186,456,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(225,457,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(183,371,11,10) + ellipse(229,371,11,10), {hand="detail", pile=J, coverage=3, fill=true})
-- pelvis and torso
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
slab(pel, A, 0, rect(150, 240, 40, 50))
work(rect(170,240,68,9), {hand="detail", pile=J, coverage=3, fill=true})
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
slab(torso, A, 1.57, poly({{140,100},{195,100},{185,250},{140,250}}))
-- arms
tube({{153,124},{148,165},{145,205}}, {21,19,16}, A)
tube({{145,207},{147,245},{151,285}}, {17,16,13}, A)
tube({{256,126},{261,166},{262,207}}, {21,19,16}, A)
tube({{262,209},{260,248},{256,287}}, {17,16,13}, A)
work(ellipse(151,300,9,15) + ellipse(256,302,9,15), {hand="detail", pile=A.base, coverage=3, fill=true})
work(ellipse(146,206,10,9) + ellipse(262,208,10,9), {hand="detail", pile=J, coverage=3, fill=true})
-- pauldrons
local lp = ellipse(158, 114, 28, 21)
slab(lp, A, 0.3, ellipse(150, 108, 20, 14))
local rp = ellipse(250, 116, 27, 20)
slab(rp, A, -0.3, ellipse(238, 110, 14, 12))
-- helmet, bowed
work(ribbon({{204,82},{206,96}}, 12), {hand="detail", pile=J, coverage=3, fill=true})
local helm = poly({{188,92},{222,90},{230,110},{224,132},{208,138},{192,130},{185,110}}, true)
slab(helm, A, 1.2, ellipse(195, 106, 13, 20))
work(ribbon({{193,121},{208,126},{223,121}}, 4), {hand="detail", pile=J, coverage=3, fill=true})
S1 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
RIM = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.6}}
local function shade(m, x0)
  return m * poly({{x0,0},{1000,0},{1000,500},{x0,500}})
end
-- torso shadow side, curving with the chest
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
local tsh = torso * poly({{218,95},{280,95},{280,250},{204,250},{212,200},{222,150}}, true)
work(tsh, {hand="body", tool="filbert 4", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true, edge="soft"})
-- pelvis and helmet shadow
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
work(pel * poly({{210,235},{250,235},{250,295},{205,295}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true})
local helm = poly({{188,92},{222,90},{230,110},{224,132},{208,138},{192,130},{185,110}}, true)
work(helm * poly({{210,85},{240,85},{240,140},{204,140}}), {hand="detail", pile=S1, coverage=3.5, fill=true})
-- limbs: shadow down the right flank of each
local limbs = {
  {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{182,372},{183,410},{185,445}}, {21,19,15}},
  {{{223,282},{227,330},{229,370}}, {30,28,22}}, {{{229,372},{228,410},{226,446}}, {21,19,15}},
  {{{153,124},{148,165},{145,205}}, {21,19,16}}, {{{145,207},{147,245},{151,285}}, {17,16,13}},
  {{{256,126},{261,166},{262,207}}, {21,19,16}}, {{{262,209},{260,248},{256,287}}, {17,16,13}}}
for _, L in ipairs(limbs) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  local sh = ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base
  work(sh, {hand="detail", pile=S1, coverage=3, fill=true})
  -- hot rim down the lit edge
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base, {hand="detail", pile=RIM, coverage=2, fill=true})
end
work(ellipse(260,116,16,18) * ellipse(250,116,27,20), {hand="detail", pile=S1, coverage=3, fill=true})
work(ellipse(166,118,10,14) * ellipse(158,114,28,21), {hand="detail", pile=S1, coverage=2.5, fill=true})
-- plate seams on chest and belly
for _, s in ipairs({{{160,150},{185,160},{204,162},{222,160},{248,150}}, {{170,198},{204,206},{238,198}}, {{176,224},{204,230},{230,224}}, {{204,108},{204,240}}}) do
  work(rib(s, 2, 1.6), {hand="detail", pile=J, coverage=2.5, fill=true})
end
-- rims on torso, pauldron and helmet left edges
work(rib({{153,108},{156,170},{168,215},{182,242}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{132,116},{140,102},{158,94},{176,100}}, 2.6, 1.6), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{188,96},{186,112},{192,130}}, 2.2, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{172,246},{170,286}}, 2, 1.5), {hand="detail", pile=RIM, coverage=2.5, fill=true})
-- helmet: bowed dome, dark gorget behind it so it separates from the chest
work(ellipse(207,134,22,8), {hand="detail", pile=S1, coverage=3, fill=true})
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(helm, {hand="detail", pile=A.base, coverage=3, fill=true})
work(helm * poly({{212,80},{240,80},{240,140},{208,140}}), {hand="detail", pile=S1, coverage=3, fill=true})
work(helm:rim(2.2, 0.5), {hand="detail", pile=J, coverage=2.5, fill=true})
-- visor: a dark T, the cross-shaped sight of a Church helm
work(rib({{193,116},{207,121},{222,116}}, 4.5, 4.5) + rib({{207,104},{207,128}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3, fill=true})
work(rib({{190,94},{196,88},{206,85}}, 2.2, 1.2) + rib({{189,104},{190,118}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2.5, fill=true})
-- gauntlets: fingers hanging
for _, h in ipairs({{151,292}, {256,294}}) do
  local x, y = h[1], h[2]
  work(ellipse(x, y, 10, 13), {hand="detail", pile=S1, coverage=3, fill=true})
  for k = -1, 2 do
    work(rib({{x + k*4.5, y + 6}, {x + k*4.8 + 1, y + 20}, {x + k*4.5 + 2, y + 27}}, 3.6, 2.4), {hand="detail", pile=A.base, coverage=3, fill=true})
  end
  work(rib({{x-9, y-8}, {x-9, y+10}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2, fill=true})
end
-- crimson cloth over the yoke and the left shoulder
CRs = pile{{"rose madder",1},{"burnt sienna",0.8},{"bone black",0.3}}
CR = pile{{"vermilion",1},{"cadmium red",1},{"rose madder",0.4}}
CRL = pile{{"vermilion",1},{"cadmium red",0.6},{"lead white",0.4},{"Mars orange",0.4}}
local cloth = poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true):roughen(1.5, 14, 6)
work(cloth, {hand="body", tool="filbert 3", pile=CRs, angle=1.57, coverage=3.5, fill=true, clip=true})
for _, f in ipairs({{{170,70},{168,110},{170,160},{176,200}}, {{182,68},{180,120},{182,175}}, {{160,90},{164,130},{168,170}}}) do
  work(rib(f, 5, 2) * cloth, {hand="detail", pile=CR, coverage=2.5, fill=true})
end
work(rib({{158,86},{160,120},{166,160},{172,198}}, 2.4, 1.2) * cloth, {hand="detail", pile=CRL, coverage=2.5, fill=true})
-- the cross-hem fringe
work(rib({{168,204},{176,212},{184,214}}, 2, 1.5), {hand="detail", pile=CRs, coverage=3, fill=true})
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(helm * poly({{150,80},{209,80},{209,140},{150,140}}), {hand="body", tool="filbert 3", pile=A.base, angle=1.57, coverage=4, fill=true, clip=true})
work(helm * poly({{209,80},{240,80},{240,140},{209,140}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=4, fill=true, clip=true})
work(helm:rim(2.4, 0.4), {hand="detail", tool={kind="round", width=2.4}, pile=J, coverage=3, fill=true})
work(rib({{193,115},{207,120},{222,115}}, 5, 5) + rib({{207,100},{207,129}}, 4, 4), {hand="detail", tool={kind="round", width=3}, pile=J, coverage=3.5, fill=true})
work(rib({{191,96},{197,89},{207,86}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=3, fill=true})
-- rosary from the hook: bone beads in a loop, a small brass cross
BEAD = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.3}}
BR = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",1}}
local bb = brush{kind="round", width=3.2, point=0.3}
local loop = {}
for i = 0, 26 do
  local t = i / 26
  local x = 201 + 30 * math.sin(t * math.pi) + 6 * t
  local y = 70 + 105 * math.sin(t * math.pi * 0.5) ^ 1.2 * (1 - 0.25 * t)
  loop[#loop+1] = {x, y}
end
for i, p in ipairs(loop) do
  if i % 2 == 0 then bb:reload(BEAD, 0.7) else bb:reload(J, 0.5) end
  bb:touch(p[1], p[2], {pressure=0.7})
end
local e = loop[#loop]
work(rib({{e[1], e[2]}, {e[1]+1, e[2]+18}}, 2.4, 2.2) + rib({{e[1]-5, e[2]+6}, {e[1]+6, e[2]+6}}, 2.2, 2.2), {hand="detail", tool={kind="round", width=2}, pile=BR, coverage=3, fill=true})
-- F1: lower legs and dangling feet, over the floor
for _, L in ipairs({ {{{182,372},{183,410},{185,445}}, {21,19,15}}, {{{229,372},{228,410},{226,446}}, {21,19,15}} }) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(base * poly({{0,410},{1000,410},{1000,500},{0,500}}), {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base * poly({{0,410},{1000,410},{1000,500},{0,500}}), {hand="detail", pile=S1, coverage=3, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base * poly({{0,412},{1000,412},{1000,500},{0,500}}), {hand="detail", pile=RIM, coverage=2, fill=true})
end
for _, f in ipairs({{186,457},{225,458}}) do
  local fm = poly({{f[1]-9,f[2]-12},{f[1]+9,f[2]-12},{f[1]+7,f[2]+10},{f[1]+1,f[2]+18},{f[1]-6,f[2]+10}}, true)
  work(fm, {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(fm * rect(f[1]+1, f[2]-14, 12, 34), {hand="detail", pile=S1, coverage=3, fill=true})
  work(rib({{f[1]-8,f[2]-10},{f[1]-6,f[2]+8}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2, fill=true})
end
-- F1: specular lights on the lit planes
SPEC = pile{{"lead white",3},{"lemon chrome",0.4},{"cadmium yellow",0.3}}
for _, s in ipairs({{{140,104},{150,98},{162,96}}, {{193,92},{199,88}}, {{162,130},{164,170},{170,200}}, {{176,250},{178,270}}, {{174,300},{173,340}}, {{176,380},{177,420}}, {{142,135},{140,180}}, {{141,215},{143,260}}}) do
  work(rib(s, 2.2, 1.2), {hand="detail", pile=SPEC, coverage=2.2, fill=true})
end

--@ chunk 31
wait(2*24*60)
ALIT = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.35}}
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
work(torso * poly({{140,100},{200,100},{196,250},{140,250}}), {hand="body", tool="filbert 3", pile=ALIT, angle=1.57, coverage=3.5, fill=true, clip=true})
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
work(pel * rect(160,240,36,50), {hand="detail", pile=ALIT, coverage=3.5, fill=true})
work(ellipse(152,110,20,14) * ellipse(158,114,28,21), {hand="detail", pile=ALIT, coverage=3.5, fill=true})
local limbs = {
  {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{182,372},{183,410},{185,445}}, {21,19,15}},
  {{{223,282},{227,330},{229,370}}, {30,28,22}}, {{{229,372},{228,410},{226,446}}, {21,19,15}},
  {{{153,124},{148,165},{145,205}}, {21,19,16}}, {{{145,207},{147,245},{151,285}}, {17,16,13}},
  {{{256,126},{261,166},{262,207}}, {21,19,16}}, {{{262,209},{260,248},{256,287}}, {17,16,13}}}
for _, L in ipairs(limbs) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(ribbon(shiftpts(pts, -w[2]*0.18, 0), widths(w, 3, 0.45)) * base, {hand="detail", pile=ALIT, coverage=3.5, fill=true})
end
S1 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
RIM = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.6}}
local function shade(m, x0)
  return m * poly({{x0,0},{1000,0},{1000,500},{x0,500}})
end
-- torso shadow side, curving with the chest
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
local tsh = torso * poly({{218,95},{280,95},{280,250},{204,250},{212,200},{222,150}}, true)
work(tsh, {hand="body", tool="filbert 4", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true, edge="soft"})
-- pelvis and helmet shadow
local pel = poly({{176,242},{230,242},{238,288},{170,288}}, true)
work(pel * poly({{210,235},{250,235},{250,295},{205,295}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=3.5, fill=true, clip=true})
local helm = poly({{188,92},{222,90},{230,110},{224,132},{208,138},{192,130},{185,110}}, true)
work(helm * poly({{210,85},{240,85},{240,140},{204,140}}), {hand="detail", pile=S1, coverage=3.5, fill=true})
-- limbs: shadow down the right flank of each
local limbs = {
  {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{182,372},{183,410},{185,445}}, {21,19,15}},
  {{{223,282},{227,330},{229,370}}, {30,28,22}}, {{{229,372},{228,410},{226,446}}, {21,19,15}},
  {{{153,124},{148,165},{145,205}}, {21,19,16}}, {{{145,207},{147,245},{151,285}}, {17,16,13}},
  {{{256,126},{261,166},{262,207}}, {21,19,16}}, {{{262,209},{260,248},{256,287}}, {17,16,13}}}
for _, L in ipairs(limbs) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  local sh = ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base
  work(sh, {hand="detail", pile=S1, coverage=3, fill=true})
  -- hot rim down the lit edge
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base, {hand="detail", pile=RIM, coverage=2, fill=true})
end
work(ellipse(260,116,16,18) * ellipse(250,116,27,20), {hand="detail", pile=S1, coverage=3, fill=true})
work(ellipse(166,118,10,14) * ellipse(158,114,28,21), {hand="detail", pile=S1, coverage=2.5, fill=true})
-- plate seams on chest and belly
for _, s in ipairs({{{160,150},{185,160},{204,162},{222,160},{248,150}}, {{170,198},{204,206},{238,198}}, {{176,224},{204,230},{230,224}}, {{204,108},{204,240}}}) do
  work(rib(s, 2, 1.6), {hand="detail", pile=J, coverage=2.5, fill=true})
end
-- rims on torso, pauldron and helmet left edges
work(rib({{153,108},{156,170},{168,215},{182,242}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{132,116},{140,102},{158,94},{176,100}}, 2.6, 1.6), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{188,96},{186,112},{192,130}}, 2.2, 1.4), {hand="detail", pile=RIM, coverage=2.5, fill=true})
work(rib({{172,246},{170,286}}, 2, 1.5), {hand="detail", pile=RIM, coverage=2.5, fill=true})
-- F1: specular lights on the lit planes
SPEC = pile{{"lead white",3},{"lemon chrome",0.4},{"cadmium yellow",0.3}}
for _, s in ipairs({{{140,104},{150,98},{162,96}}, {{193,92},{199,88}}, {{162,130},{164,170},{170,200}}, {{176,250},{178,270}}, {{174,300},{173,340}}, {{176,380},{177,420}}, {{142,135},{140,180}}, {{141,215},{143,260}}}) do
  work(rib(s, 2.2, 1.2), {hand="detail", pile=SPEC, coverage=2.2, fill=true})
end
-- rosary beads, larger, from the hook over the right breast
local bb = brush{kind="round", width=4.2, point=0.2}
for i = 0, 18 do
  local t = i / 18
  local x = 202 + 34 * math.sin(t * math.pi) + 4 * t
  local y = 72 + 100 * (t ^ 0.8)
  if i % 2 == 0 then bb:reload(BEAD, 0.8) else bb:reload(J, 0.6) end
  bb:touch(x, y, {pressure=0.8})
end
-- the wall's cut edge at x=330 lost into the room
local wall = poly({{0,20},{VX,VY},{0,480}}) - FAB
lose(wall * poly({{0,0},{331,0},{331,500},{0,500}}), {pile=D_wall, reach={16, 26}, load=0.3, tool="filbert 4", angle=3.1})

--@ chunk 32
wait(24*60)
-- helmet again, over the smears
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(ellipse(207,134,22,8), {hand="detail", pile=S1, coverage=3, fill=true})
work(helm * poly({{150,80},{209,80},{209,140},{150,140}}), {hand="body", tool="filbert 3", pile=ALIT, angle=1.57, coverage=4, fill=true, clip=true})
work(helm * poly({{209,80},{240,80},{240,140},{209,140}}), {hand="body", tool="filbert 3", pile=S1, angle=1.57, coverage=4, fill=true, clip=true})
work(helm:rim(2.4, 0.4), {hand="detail", tool={kind="round", width=2.4}, pile=J, coverage=3, fill=true})
work(rib({{193,115},{207,120},{222,115}}, 5, 5) + rib({{207,100},{207,129}}, 4, 4), {hand="detail", tool={kind="round", width=3}, pile=J, coverage=3.5, fill=true})
work(rib({{191,96},{197,89},{207,86}}, 2.4, 1.4), {hand="detail", pile=RIM, coverage=3, fill=true})
-- yoke and chain
work(ribbon({{200,0},{201,70}}, 4), {hand="detail", pile=J, coverage=3, fill=true})
work(rect(160, 68, 84, 13), {hand="detail", pile=S1, coverage=3.5, fill=true})
work(rect(160, 68, 34, 13), {hand="detail", pile=ALIT, coverage=3, fill=true})
work(rib({{160,68},{244,68}}, 1.5, 1.5), {hand="detail", pile=RIM, coverage=2, fill=true})
-- the crimson cloth again
local cloth = poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true):roughen(1.5, 14, 6)
work(cloth, {hand="body", tool="filbert 3", pile=CRs, angle=1.57, coverage=4, fill=true, clip=true})
for _, f in ipairs({{{170,70},{168,110},{170,160},{176,200}}, {{182,68},{180,120},{182,175}}, {{160,90},{164,130},{168,170}}}) do
  work(rib(f, 5, 2) * cloth, {hand="detail", pile=CR, coverage=3, fill=true})
end
work(rib({{158,86},{160,120},{166,160},{172,198}}, 2.4, 1.2) * cloth, {hand="detail", pile=CRL, coverage=3, fill=true})
-- shins where the smear crossed them
for _, L in ipairs({ {{{182,372},{183,410},{185,445}}, {21,19,15}}, {{{229,372},{228,410},{226,446}}, {21,19,15}} }) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w) * rect(150, 395, 120, 40)
  work(base, {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.18, 0), widths(w, 3, 0.45)) * base, {hand="detail", pile=ALIT, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.45)) * base, {hand="detail", pile=S1, coverage=3.5, fill=true})
end

--@ chunk 33
wait(24*60)
for _, L in ipairs({ {{{182,372},{183,410},{185,445}}, {21,19,15}}, {{{229,372},{228,410},{226,446}}, {21,19,15}},
                     {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{223,282},{227,330},{229,370}}, {30,28,22}} }) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(base, {hand="body", tool="filbert 3", pile=A.base, angle=1.57, coverage=3.5, fill=true, clip=true})
  work(ribbon(shiftpts(pts, -w[2]*0.18, 0), widths(w, 3, 0.42)) * base, {hand="detail", pile=ALIT, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, w[2]*0.3, 0), widths(w, 3, 0.42)) * base, {hand="detail", pile=S1, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.42, 0), 1.6) * base, {hand="detail", pile=RIM, coverage=2.5, fill=true})
end
-- knees, elbows, hip line
work(ellipse(183,371,11,9) + ellipse(229,371,11,9) + ellipse(146,206,9,8) + ellipse(262,208,9,8), {hand="detail", pile=J, coverage=3, fill=true})
work(rib({{172,244},{205,248},{236,244}}, 3, 3), {hand="detail", pile=J, coverage=3, fill=true})
-- neck shadow under the bowed helmet, so the head separates
local helm = poly({{189,88},{208,84},{225,90},{229,108},{224,128},{208,136},{192,129},{186,108}}, true)
work(ellipse(209,140,30,10) - helm - poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true), {hand="detail", pile=J, coverage=3.5, fill=true})
work(helm * poly({{150,80},{207,80},{207,140},{150,140}}) - rib({{193,115},{207,120},{222,115}}, 6, 6), {hand="detail", pile=SPEC, coverage=2, fill=true})
work(rib({{193,115},{207,120},{222,115}}, 5, 5) + rib({{207,100},{207,129}}, 4, 4), {hand="detail", tool={kind="round", width=3}, pile=J, coverage=3.5, fill=true})
work(helm:rim(2.4, 0.4), {hand="detail", tool={kind="round", width=2.4}, pile=J, coverage=3, fill=true})

--@ chunk 34
FR = rect(122,0,150,490) + rect(372,40,100,340) + rect(512,120,150,205) + rect(664,132,108,162)
D_rb = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.3}}
for _, R in ipairs({{0.575, 0.93, H1}, {0.205, 0.9, H2}}) do
  local s, k, litp = R[1], R[2], R[3]
  local band = (sec(s) - sec(s * k)) - FR
  work(band, {hand="body", tool="filbert 3", pile=D_rb, angle=function(x,y) return tovp(x,y) + 1.5708 end, coverage=4, load=1, fill=true, clip=true})
  local lip = (sec(s * k):rim(2.2, 0.3) * sec(s * k):grow(2)) - FR
  work(lip * poly({{0,0},{VX,0},{VX,500},{0,500}}), {hand="detail", pile=litp, coverage=2.5, fill=true})
end

--@ chunk 35
-- F3 rim toned from red to a hot ochre
work(rib({{548,192},{574,186},{600,184},{630,186}}, 2.2, 1.6), {hand="detail", pile=C.lit, coverage=3, fill=true})
-- cold sick light pooling on the floor under the far thing
COLDF = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"bone black",1},{"zinc white",0.4}}
local pool = poly({{760,300},{860,296},{940,320},{900,350},{800,352},{740,330}}, true):roughen(6,30,8)
work(pool, {hand="scumble", pile=COLDF, coverage=1, load=0.3, pressure={0.15,0.35}, angle=0.05, clip=true})
-- an old frame's helmet and forearm on the floor, a relic
local h = poly({{640,432},{668,424},{690,432},{694,452},{676,464},{650,462},{636,450}}, true)
work(h, {hand="body", tool="filbert 3", pile=S1, angle=0.2, coverage=4, fill=true, clip=true})
work(h * poly({{630,420},{668,418},{660,470},{630,470}}), {hand="detail", pile=A.base, coverage=3, fill=true})
work(rib({{644,446},{664,450},{684,446}}, 3.4, 3.4) + rib({{664,436},{664,458}}, 3, 3), {hand="detail", pile=J, coverage=3.5, fill=true})
work(rib({{638,442},{648,428},{664,423}}, 1.6, 1.2), {hand="detail", pile=RIM, coverage=2.5, fill=true})
local arm = rib({{700,462},{760,454},{806,458}}, 13, 10)
work(arm, {hand="body", tool="filbert 3", pile=S1, angle=0.0, coverage=4, fill=true, clip=true})
work(rib({{702,456},{760,449},{804,452}}, 2, 1.5), {hand="detail", pile=A.base, coverage=2.5, fill=true})
work(ellipse(812,460,9,7), {hand="detail", pile=S1, coverage=3.5, fill=true})
work(poly({{620,470},{820,468},{830,480},{630,482}}, true), {hand="detail", pile=SH, coverage=3, fill=true})

--@ chunk 36
wait(24*60)
local pool = poly({{760,300},{860,296},{940,320},{900,350},{800,352},{740,330}}, true):roughen(6,30,8):grow(4)
work(pool, {hand="body", pile=D_fu, angle=0.05, coverage=4.5, load=1, fill=true, clip=true})
-- a few cold reflections, thin and broken, lying flat on the floor
local bb = brush("filbert", 2.5)
for i, s in ipairs({{{780,312},{850,310}}, {{800,324},{890,326}}, {{770,338},{830,340}}, {{845,302},{900,304}}, {{860,336},{920,338}}}) do
  bb:reload(COLD, 0.25)
  bb:stroke(s, {pressure={0.3, 0.05}, ramps={0.1, 0.6}})
end
bb:reload(OS, 0.25)
bb:stroke({{820,318},{870,318}}, {pressure={0.3, 0.05}, ramps={0.1, 0.6}})

--@ chunk 37
-- ceiling plate seams following the hull's sections, above the beam only
local ceilonly = above(function(x) return beamy(x) - 18 end) - FR - rect(760,90,170,200)
for _, s in ipairs({0.82, 0.7, 0.47, 0.36, 0.28}) do
  local seam = sec(s):rim(1.8, 0.3) * sec(s):grow(1.8) * ceilonly
  work(seam, {hand="detail", pile=J, coverage=3, fill=true})
  local lipm = sec(s * 0.985):rim(1.2, 0.3) * sec(s * 0.985):grow(1.2) * ceilonly * poly({{0,0},{560,0},{560,300},{0,300}})
  work(lipm, {hand="detail", pile=H2, coverage=2, fill=true})
end
-- the far rib's lip continues round, dimming
local lip = (sec(0.205 * 0.9):rim(2.2, 0.3) * sec(0.205 * 0.9):grow(2)) * poly({{VX,0},{1000,0},{1000,500},{VX,500}})
work(lip, {hand="detail", pile=H3, coverage=2.5, fill=true})
-- warm glints in F2's dead lenses
for _, p in ipairs({{415,120},{423,123},{430,119}}) do
  work(ellipse(p[1]-0.6, p[2]-0.6, 1.1, 1.1), {hand="detail", pile=H1, coverage=3, fill=true})
end
-- the hard shelf edge low on the far right wall, lost
lose(rect(905, 238, 95, 80), {pile=D_c3, reach={10, 14}, load=0.3, tool="filbert 4", angle=1.57})

--@ chunk 38
-- umbilicals from the yoke into the back of the helm: the mind's port, empty
for _, c in ipairs({{{214,80},{222,92},{224,104}}, {{226,80},{236,96},{240,110}}, {{232,81},{246,94},{252,104}}}) do
  work(rib(c, 3, 2.2), {hand="detail", pile=J, coverage=3.5, fill=true})
end
work(rib({{221,84},{224,96}}, 1, 0.8), {hand="detail", pile=H1, coverage=2, fill=true})
-- knee cops and thigh plate edges on F1
for _, k in ipairs({{180,366},{226,366}}) do
  local cop = poly({{k[1]-10,k[2]-6},{k[1]+8,k[2]-8},{k[1]+11,k[2]+4},{k[1]+1,k[2]+12},{k[1]-10,k[2]+5}}, true)
  work(cop, {hand="detail", pile=A.base, coverage=3.5, fill=true})
  work(cop * rect(k[1]+1, k[2]-10, 14, 24), {hand="detail", pile=S1, coverage=3.5, fill=true})
  work(rib({{k[1]-9,k[2]-4},{k[1]-2,k[2]-8}}, 1.6, 1.2), {hand="detail", pile=SPEC, coverage=2.5, fill=true})
end
for _, s in ipairs({{{172,318},{186,322},{198,318}}, {{214,318},{228,322},{240,318}}}) do
  work(rib(s, 1.6, 1.6), {hand="detail", pile=J, coverage=3, fill=true})
end
-- generation numerals stencilled on each frame: I, II, III, IV
STN = pile{{"lead white",2},{"yellow ochre",1},{"bone black",0.2}}
local function bar(x, y, h, w) work(rib({{x, y}, {x, y + h}}, w, w), {hand="detail", pile=STN, coverage=3, fill=true}) end
bar(248, 112, 9, 1.8)
bar(437, 160, 7, 1.4); bar(441, 160, 7, 1.4)
bar(616, 206, 6, 1.2); bar(619, 206, 6, 1.2); bar(622, 206, 6, 1.2)
bar(744, 222, 4.5, 0.9)
work(rib({{746.5,222},{748,226.5},{749.5,222}}, 0.9, 0.9), {hand="detail", pile=STN, coverage=3, fill=true})

--@ chunk 39
-- the relic sits in shadow: darken it, keep a dim warm edge
local h = poly({{640,432},{668,424},{690,432},{694,452},{676,464},{650,462},{636,450}}, true)
work(h, {hand="detail", pile=S1, coverage=3.5, fill=true})
work(rib({{644,446},{664,450},{684,446}}, 3.4, 3.4) + rib({{664,436},{664,458}}, 3, 3), {hand="detail", pile=J, coverage=3.5, fill=true})
work(rib({{638,444},{646,430},{664,424}}, 1.4, 1), {hand="detail", pile=H1, coverage=2.5, fill=true})
work(rib({{700,462},{760,454},{806,458}}, 12, 9), {hand="detail", pile=D_fd, coverage=3.5, fill=true})
work(rib({{702,456},{760,449},{804,452}}, 1.4, 1), {hand="detail", pile=H2, coverage=2.5, fill=true})
-- F1's hands: the far hand in shadow, the near hand catching the mouth's light
local fr = poly({{246,286},{266,286},{268,322},{246,322}}, true)
work(fr, {hand="detail", pile=S1, coverage=3, fill=true})
for k = 0, 3 do
  work(rib({{248 + k*5, 300}, {249 + k*5, 314}, {250 + k*5, 322}}, 3.4, 2.2), {hand="detail", pile=S1, coverage=3, fill=true})
end
work(rib({{246,288},{246,316}}, 1.4, 1), {hand="detail", pile=RIM, coverage=2, fill=true})
for k = 0, 3 do
  work(rib({{143 + k*5, 300}, {144 + k*5, 314}, {145 + k*5, 321}}, 3.4, 2.2), {hand="detail", pile=A.base, coverage=3, fill=true})
end
work(rib({{142,288},{141,318}}, 1.8, 1.2), {hand="detail", pile=RIM, coverage=2.5, fill=true})

--@ chunk 40
wait(24*60)
AMID = pile{{"lead white",1.5},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone brown",0.4}}
-- torso: a half-tone where light turns into shadow, so the chest rounds
local torso = poly({{150,104},{258,104},{250,170},{238,215},{226,244},{180,244},{166,215},{156,170}}, true)
local turn = torso * poly({{198,138},{214,138},{214,244},{196,244}}) - poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true)
work(turn, {hand="detail", pile=AMID, coverage=3, fill=true})
work(rib({{204,140},{204,240}}, 1.4, 1.4), {hand="detail", pile=J, coverage=2.5, fill=true})
-- legs: one lit plane down the front of each, a half-tone, the shadow
for _, L in ipairs({ {{{186,282},{183,330},{182,370}}, {30,28,22}}, {{{223,282},{227,330},{229,370}}, {30,28,22}},
                     {{{182,378},{183,410},{185,445}}, {21,19,15}}, {{{229,378},{228,410},{226,446}}, {21,19,15}} }) do
  local pts, w = L[1], L[2]
  local base = ribbon(pts, w)
  work(ribbon(shiftpts(pts, -w[2]*0.2, 0), widths(w, 3, 0.4)) * base, {hand="detail", pile=ALIT, coverage=3.5, fill=true})
  work(ribbon(shiftpts(pts, w[2]*0.08, 0), widths(w, 3, 0.2)) * base, {hand="detail", pile=AMID, coverage=3, fill=true})
  work(ribbon(shiftpts(pts, -w[2]*0.33, 0), 1.6) * base, {hand="detail", pile=SPEC, coverage=2.5, fill=true})
end
-- numeral I on the near pauldron, darker so it reads on the ivory
work(rib({{150,104},{150,116}}, 2, 2), {hand="detail", pile=J, coverage=3, fill=true})

--@ chunk 41
-- rosary: a strand of bone beads from the hook, round the bowed helm, to the brass cross
local strand = {{205,74},{216,80},{226,90},{232,104},{232,118},{228,130},{220,140},{211,146}}
local pts = {}
for i = 1, #strand - 1 do
  local a, b = strand[i], strand[i+1]
  for k = 0, 1 do
    local t = k / 2
    pts[#pts+1] = {lerp(a[1], b[1], t), lerp(a[2], b[2], t)}
  end
end
work(rib(strand, 0.8, 0.8), {hand="detail", pile=J, coverage=2.5, fill=true})
for i, p in ipairs(pts) do
  work(ellipse(p[1], p[2], 2.4, 2.4), {hand="detail", pile=J, coverage=3, fill=true})
  work(ellipse(p[1] - 0.5, p[2] - 0.4, 1.7, 1.7), {hand="detail", pile=BEAD, coverage=3, fill=true})
end
-- the cross, restated larger
work(rib({{209,148},{209,166}}, 2.6, 2.4) + rib({{203,154},{215,154}}, 2.4, 2.4), {hand="detail", tool={kind="round", width=2}, pile=BR, coverage=3.5, fill=true})
work(rib({{208,149},{208,165}}, 0.8, 0.8), {hand="detail", pile=SPEC, coverage=2, fill=true})
-- F3's head: a visor and one dead lens
work(rib({{549,140},{558,142}}, 2.2, 2.2), {hand="detail", pile=J, coverage=3, fill=true})
work(ellipse(552,140,1, 1), {hand="detail", pile=H1, coverage=3, fill=true})

--@ chunk 42
-- F2 still carries a cross, smaller, its paint worn
CRW = pile{{"cadmium red",1},{"rose madder",0.6},{"burnt sienna",0.5},{"lead white",0.3}}
work(rib({{404,146},{404,170}}, 3, 3) + rib({{396,154},{412,154}}, 3, 3), {hand="detail", pile=CRW, coverage=2.2, fill=true})
-- F3 keeps only a rag of crimson tied at the waist of its torso
local rag = poly({{548,196},{562,194},{560,212},{556,226},{551,222},{549,210}}, true):roughen(1, 6, 4)
work(rag, {hand="detail", pile=CRs, coverage=3.5, fill=true})
work(rib({{551,198},{552,212},{553,222}}, 1.4, 0.8), {hand="detail", pile=CR, coverage=2.5, fill=true})

--@ chunk 43
wait(12*60)
-- wear the cross on F2: scrapes of gunmetal across it
for _, s in ipairs({{{397,151},{403,156}}, {{405,160},{410,163}}, {{402,166},{406,170}}, {{399,155},{401,158}}}) do
  work(rib(s, 1.4, 0.9), {hand="detail", pile=B2, coverage=3, fill=true})
end

--@ chunk 44
-- the mouth's lintel and jamb, a dark bronze frame with a hot inner edge
work(rib({{0,163},{104,173}}, 9, 7), {hand="detail", pile=SIL, coverage=3.5, fill=true})
work(rib({{106,174},{106,382}}, 6, 6), {hand="detail", pile=SIL, coverage=3.5, fill=true})
work(rib({{0,404},{106,382}}, 7, 6), {hand="detail", pile=SIL, coverage=3.5, fill=true})
work(rib({{0,169},{101,178}}, 2, 1.6), {hand="detail", pile=G_mid, coverage=3, fill=true})
work(rib({{102,180},{102,378}}, 2, 1.8), {hand="detail", pile=G_mid, coverage=3, fill=true})

--@ chunk 45
-- F4: weapons bristling from its flanks and back, pointing every way
for _, g in ipairs({{{700,210},{670,204}}, {{752,212},{780,206}}, {{744,206},{762,190}}, {{716,232},{700,246}}, {{730,204},{722,186}}}) do
  work(rib(g, 3.2, 2.4), {hand="detail", pile=D4.base, coverage=3.5, fill=true})
  work(rib(shiftpts(g, 0, -1), 0.8, 0.6), {hand="detail", pile=D4.lit, coverage=2, fill=true})
  work(ellipse(g[2][1], g[2][2], 1.4, 1.4), {hand="detail", pile=J, coverage=3, fill=true})
end

--@ chunk 46
PL_mid = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone brown",0.5}}
PL_lit = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.4}}
PL_sh = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
PL_b = pile{{"red earth",1},{"burnt sienna",1},{"bone brown",0.6},{"lead white",0.25}}
RIMH = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5}}
SCORCH = pile{{"bone black",2},{"burnt sienna",1}}
function bbox(pts)
  local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, p in ipairs(pts) do
    a = math.min(a, p[1]); b = math.max(b, p[1]); c = math.min(c, p[2]); d = math.max(d, p[2])
  end
  return a, b, c, d
end
-- one armour plate: thickness shadow, midtone, lit crescent, core shadow, fused wet, bounce, hot rim
function plate(pts, o)
  o = o or {}
  local P = poly(pts, true)
  local x0, x1, y0, y1 = bbox(pts)
  local d = o.d or math.max(2.5, (x1 - x0) * (o.k or 0.34))
  local th = o.th or 2.6
  work(poly(shiftpts(pts, th * 0.6, th), true) - P, {hand="detail", pile=J, coverage=3})
  work(P, {hand="detail", pile=o.mid or PL_mid, coverage=3.5})
  work(P - poly(shiftpts(pts, d, d * 0.2), true), {hand="detail", pile=o.lit or PL_lit, coverage=3.5})
  work(P - poly(shiftpts(pts, -d * 1.1, -d * 0.15), true), {hand="detail", pile=o.sh or PL_sh, coverage=3.5})
  if not o.noblend then
    work(P, {hand="blend", tool={kind="badger", width=math.min(12, math.max(4, (x1 - x0) * 0.4))}, angle=o.angle or 1.57, coverage=1})
  end
  work(P - poly(shiftpts(pts, -2.2, -0.3), true), {hand="detail", pile=o.b or PL_b, coverage=2.5})
  if not o.norim then
    work(P - poly(shiftpts(pts, 1.5, 0.9), true), {hand="detail", pile=o.rim or RIMH, coverage=3})
  end
  return P
end
-- a tapered limb plate between two spine points
function lplate(a, b, w0, w1, o)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts = {{a[1] + nx * w0 / 2, a[2] + ny * w0 / 2}, {a[1] - nx * w0 / 2, a[2] - ny * w0 / 2},
               {b[1] - nx * w1 / 2, b[2] - ny * w1 / 2}, {b[1] + nx * w1 / 2, b[2] + ny * w1 / 2}}
  o = o or {}
  o.angle = o.angle or math.atan(dy, dx)
  return plate(pts, o)
end
wait(24*60)
-- F1 legs, back to front: thighs, greaves, knee cops, sabatons, actuators behind the knees
for _, s in ipairs({1, -1}) do
  local L = s == 1
  local tx0, tx1 = L and 186 or 223, L and 183 or 228
  lplate({tx0, 284}, {tx1, 352}, 30, 25)
  local gx0, gx1 = L and 182 or 229, L and 185 or 226
  -- piston behind the knee, in the shadow side
  local px = (L and 193 or 239)
  work(rib({{px, 344}, {px - 1, 394}}, 4.5, 4.5), {hand="detail", pile=J, coverage=3})
  work(rib({{px - 0.6, 352}, {px - 1.4, 386}}, 1.4, 1.4), {hand="detail", pile=STEEL, coverage=3})
  lplate({gx0, 380}, {gx1, 440}, 21, 15)
  work(rib({{gx0 - 3, 386}, {gx1 - 2, 436}}, 1.6, 1), {hand="detail", pile=RIMH, coverage=2.5})
  local kx = L and 182 or 228
  plate({{kx - 12, 360}, {kx + 2, 355}, {kx + 13, 361}, {kx + 12, 374}, {kx, 381}, {kx - 11, 373}}, {k=0.3})
  local fx = L and 186 or 226
  plate({{fx - 9, 446}, {fx + 8, 446}, {fx + 7, 462}, {fx, 472}, {fx - 8, 462}}, {k=0.3})
  work(rib({{fx - 8, 457}, {fx + 7, 457}}, 1.4, 1.4), {hand="detail", pile=J, coverage=3})
end

--@ chunk 47
PL_mid = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone brown",0.5}}
PL_lit = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.4}}
PL_sh = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
PL_b = pile{{"red earth",1},{"burnt sienna",1},{"bone brown",0.6},{"lead white",0.25}}
RIMH = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5}}
SCORCH = pile{{"bone black",2},{"burnt sienna",1}}
function bbox(pts)
  local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, p in ipairs(pts) do
    a = math.min(a, p[1]); b = math.max(b, p[1]); c = math.min(c, p[2]); d = math.max(d, p[2])
  end
  return a, b, c, d
end
-- one armour plate: thickness shadow, midtone, lit crescent, core shadow, fused wet, bounce, hot rim
function plate(pts, o)
  o = o or {}
  local P = poly(pts, true)
  local x0, x1, y0, y1 = bbox(pts)
  local d = o.d or math.max(2.5, (x1 - x0) * (o.k or 0.34))
  local th = o.th or 2.6
  if not o.accent_only then
  work(poly(shiftpts(pts, th * 0.6, th), true) - P, {hand="detail", pile=J, coverage=3})
  work(P, {hand="detail", pile=o.mid or PL_mid, coverage=3.5})
  work(P - poly(shiftpts(pts, d, d * 0.2), true), {hand="detail", pile=o.lit or PL_lit, coverage=3.5})
  work(P - poly(shiftpts(pts, -d * 1.1, -d * 0.15), true), {hand="detail", pile=o.sh or PL_sh, coverage=3.5})
  if not o.noblend then
    work(P, {hand="blend", tool={kind="badger", width=math.min(12, math.max(4, (x1 - x0) * 0.4))}, angle=o.angle or 1.57, coverage=1})
  end
  end
  -- after the fusing: a narrower core shadow and a narrower light, so the form keeps its turn
  work(P - poly(shiftpts(pts, -d * 0.75, -d * 0.1), true) - (P - poly(shiftpts(pts, -2.6, -0.3), true)), {hand="detail", pile=o.sh or PL_sh, coverage=3})
  work(P - poly(shiftpts(pts, d * 0.55, d * 0.1), true), {hand="detail", pile=o.lit or PL_lit, coverage=3})
  work(P - poly(shiftpts(pts, -2.2, -0.3), true), {hand="detail", pile=o.b or PL_b, coverage=2.5})
  if not o.norim then
    work(P - poly(shiftpts(pts, 1.5, 0.9), true), {hand="detail", pile=o.rim or RIMH, coverage=3})
  end
  return P
end
-- a tapered limb plate between two spine points
function lplate(a, b, w0, w1, o)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts = {{a[1] + nx * w0 / 2, a[2] + ny * w0 / 2}, {a[1] - nx * w0 / 2, a[2] - ny * w0 / 2},
               {b[1] - nx * w1 / 2, b[2] - ny * w1 / 2}, {b[1] + nx * w1 / 2, b[2] + ny * w1 / 2}}
  o = o or {}
  o.angle = o.angle or math.atan(dy, dx)
  return plate(pts, o)
end
for _, s in ipairs({1, -1}) do
  local L = s == 1
  lplate({L and 186 or 223, 284}, {L and 183 or 228, 352}, 30, 25, {accent_only=true, norim=false})
  lplate({L and 182 or 229, 380}, {L and 185 or 226, 440}, 21, 15, {accent_only=true})
  local px = (L and 199 or 243)
  work(rib({{px, 350}, {px - 1, 390}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3})
  work(rib({{px - 0.5, 356}, {px - 1.2, 384}}, 1.2, 1.2), {hand="detail", pile=STEEL, coverage=3})
end
-- F1 faulds, belly lames, cuirass
plate({{170,258},{238,258},{241,280},{205,289},{167,280}}, {k=0.3})
plate({{172,243},{236,243},{240,262},{168,262}}, {k=0.3})
plate({{176,224},{232,224},{231,247},{178,247}}, {k=0.3, th=2})
plate({{172,210},{236,210},{233,229},{175,229}}, {k=0.3, th=2})
plate({{168,195},{240,195},{237,214},{171,214}}, {k=0.3, th=2})
-- cuirass: two pectoral plates meeting at a keel
plate({{205,106},{256,108},{253,150},{246,180},{228,199},{206,192}}, {k=0.42})
plate({{152,108},{205,106},{206,192},{181,199},{162,180},{155,150}}, {k=0.28})
work(rib({{206,110},{206,190}}, 1.6, 1.2), {hand="detail", pile=J, coverage=3})
work(rib({{204,112},{204,188}}, 1.2, 1), {hand="detail", pile=PL_lit, coverage=2.5})
-- chest seams and rivets
for _, r in ipairs({{214,120},{226,122},{238,124},{216,176},{230,170}}) do
  work(ellipse(r[1], r[2], 1.1, 1.1), {hand="detail", pile=J, coverage=3})
end

--@ chunk 48
PL_mid = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone brown",0.5}}
PL_lit = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.4}}
PL_sh = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
PL_b = pile{{"red earth",1},{"burnt sienna",1},{"bone brown",0.6},{"lead white",0.25}}
RIMH = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5}}
SCORCH = pile{{"bone black",2},{"burnt sienna",1}}
function bbox(pts)
  local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, p in ipairs(pts) do
    a = math.min(a, p[1]); b = math.max(b, p[1]); c = math.min(c, p[2]); d = math.max(d, p[2])
  end
  return a, b, c, d
end
-- one armour plate: thickness shadow, midtone, lit crescent, core shadow, fused wet, bounce, hot rim
function plate(pts, o)
  o = o or {}
  local P = poly(pts, o.smooth or false)
  local x0, x1, y0, y1 = bbox(pts)
  local d = o.d or math.max(2.5, (x1 - x0) * (o.k or 0.34))
  local th = o.th or 2.6
  if not o.accent_only then
  work(poly(shiftpts(pts, th * 0.6, th), o.smooth or false) - P, {hand="detail", pile=J, coverage=3})
  work(P, {hand="detail", pile=o.mid or PL_mid, coverage=3.5})
  work(P - poly(shiftpts(pts, d, d * 0.2), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3.5})
  work(P - poly(shiftpts(pts, -d * 1.1, -d * 0.15), o.smooth or false), {hand="detail", pile=o.sh or PL_sh, coverage=3.5})
  if not o.noblend then
    work(P, {hand="blend", tool={kind="badger", width=math.min(12, math.max(4, (x1 - x0) * 0.4))}, angle=o.angle or 1.57, coverage=1})
  end
  end
  -- after the fusing: a narrower core shadow and a narrower light, so the form keeps its turn
  work(P - poly(shiftpts(pts, -d * 0.75, -d * 0.1), o.smooth or false) - (P - poly(shiftpts(pts, -2.6, -0.3), o.smooth or false)), {hand="detail", pile=o.sh or PL_sh, coverage=3})
  work(P - poly(shiftpts(pts, d * 0.55, d * 0.1), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3})
  work(P - poly(shiftpts(pts, -2.2, -0.3), o.smooth or false), {hand="detail", pile=o.b or PL_b, coverage=2.5})
  if not o.norim then
    work(P - poly(shiftpts(pts, 1.5, 0.9), o.smooth or false), {hand="detail", pile=o.rim or RIMH, coverage=3})
  end
  return P
end
-- a tapered limb plate between two spine points
function lplate(a, b, w0, w1, o)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts = {{a[1] + nx * w0 / 2, a[2] + ny * w0 / 2}, {a[1] - nx * w0 / 2, a[2] - ny * w0 / 2},
               {b[1] - nx * w1 / 2, b[2] - ny * w1 / 2}, {b[1] + nx * w1 / 2, b[2] + ny * w1 / 2}}
  o = o or {}
  o.angle = o.angle or math.atan(dy, dx)
  return plate(pts, o)
end
PL_sh = pile{{"bone black",1.5},{"burnt sienna",1},{"bone brown",1}}
-- F1 arms: rerebrace, actuator, couter, vambrace, gauntlet
for _, s in ipairs({1, -1}) do
  local L = s == 1
  local ax = L and 153 or 257
  local ex = L and 146 or 262
  local hx = L and 151 or 257
  lplate({ax, 126}, {ex + (L and 1 or -1), 196}, 21, 18)
  local px = L and 158 or 251
  work(rib({{px, 186}, {px, 228}}, 4, 4), {hand="detail", pile=J, coverage=3})
  work(rib({{px, 192}, {px, 222}}, 1.3, 1.3), {hand="detail", pile=STEEL, coverage=3})
  lplate({ex, 214}, {hx, 282}, 17, 14)
  plate({{ex - 10, 198}, {ex + 4, 195}, {ex + 12, 203}, {ex + 9, 216}, {ex - 3, 219}, {ex - 11, 210}}, {k=0.3})
  plate({{hx - 10, 284}, {hx + 9, 284}, {hx + 11, 300}, {hx + 1, 310}, {hx - 9, 302}}, {k=0.3, th=2})
  for f = 0, 3 do
    local fx = hx - 7 + f * 4.6
    work(rib({{fx, 304}, {fx + 0.5, 316}, {fx + 1.5, 324}}, 3.6, 2.2), {hand="detail", pile=L and PL_mid or PL_sh, coverage=3})
    work(rib({{fx - 1, 305}, {fx - 0.5, 316}}, 0.8, 0.6), {hand="detail", pile=L and PL_lit or PL_b, coverage=2})
  end
end
-- pauldrons: three overlapping lames each, bottom lame first
plate({{130,124},{170,126},{171,140},{132,139}}, {k=0.3, th=2})
plate({{130,111},{171,112},{173,128},{129,128}}, {k=0.3, th=2})
plate({{133,96},{158,89},{180,95},{183,115},{131,117}}, {k=0.32})
plate({{238,127},{277,125},{278,139},{240,141}}, {k=0.5, th=2})
plate({{236,114},{277,112},{280,129},{238,131}}, {k=0.5, th=2})
plate({{229,98},{250,91},{274,97},{279,116},{231,118}}, {k=0.5})
-- gorget and helm
plate({{184,126},{231,126},{235,140},{208,147},{180,140}}, {k=0.35, th=2})
plate({{189,86},{208,82},{226,88},{231,108},{225,128},{208,136},{191,129},{185,108}}, {k=0.3})
work(rib({{193,115},{207,120},{222,115}}, 4.6, 4.6) + rib({{207,101},{207,129}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3.5})
work(rib({{194,112},{207,117},{220,112}}, 0.9, 0.9), {hand="detail", pile=RIMH, coverage=2})
work(rib({{198,86},{208,83},{218,86}}, 2.6, 2.6), {hand="detail", pile=PL_sh, coverage=3})
work(rib({{197,85},{207,82}}, 1, 1), {hand="detail", pile=RIMH, coverage=2.5})

--@ chunk 49
wait(24*60)
local realwork, realplate, realstipple = work, plate, stipple
local SHM, BM
local function add(a, b) if a == nil then return b end return a + b end
work = function() end
stipple = function() end
plate = function(pts, o)
  o = o or {}
  local x0, x1 = bbox(pts)
  local d = math.max(2.5, (x1 - x0) * (o.shk or 0.48))
  local P = poly(pts)
  SHM = add(SHM, P - poly(shiftpts(pts, -d, -d * 0.1)))
  BM = add(BM, P - poly(shiftpts(pts, -2.4, -0.3)))
  return P
end
-- F1 legs, back to front: thighs, greaves, knee cops, sabatons, actuators behind the knees
for _, s in ipairs({1, -1}) do
  local L = s == 1
  local tx0, tx1 = L and 186 or 223, L and 183 or 228
  lplate({tx0, 284}, {tx1, 352}, 30, 25)
  local gx0, gx1 = L and 182 or 229, L and 185 or 226
  -- piston behind the knee, in the shadow side
  local px = (L and 193 or 239)
  work(rib({{px, 344}, {px - 1, 394}}, 4.5, 4.5), {hand="detail", pile=J, coverage=3})
  work(rib({{px - 0.6, 352}, {px - 1.4, 386}}, 1.4, 1.4), {hand="detail", pile=STEEL, coverage=3})
  lplate({gx0, 380}, {gx1, 440}, 21, 15)
  work(rib({{gx0 - 3, 386}, {gx1 - 2, 436}}, 1.6, 1), {hand="detail", pile=RIMH, coverage=2.5})
  local kx = L and 182 or 228
  plate({{kx - 12, 360}, {kx + 2, 355}, {kx + 13, 361}, {kx + 12, 374}, {kx, 381}, {kx - 11, 373}}, {k=0.3})
  local fx = L and 186 or 226
  plate({{fx - 9, 446}, {fx + 8, 446}, {fx + 7, 462}, {fx, 472}, {fx - 8, 462}}, {k=0.3})
  work(rib({{fx - 8, 457}, {fx + 7, 457}}, 1.4, 1.4), {hand="detail", pile=J, coverage=3})
end
for _, s in ipairs({1, -1}) do
  local L = s == 1
  lplate({L and 186 or 223, 284}, {L and 183 or 228, 352}, 30, 25, {accent_only=true, norim=false})
  lplate({L and 182 or 229, 380}, {L and 185 or 226, 440}, 21, 15, {accent_only=true})
  local px = (L and 199 or 243)
  work(rib({{px, 350}, {px - 1, 390}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3})
  work(rib({{px - 0.5, 356}, {px - 1.2, 384}}, 1.2, 1.2), {hand="detail", pile=STEEL, coverage=3})
end
-- F1 faulds, belly lames, cuirass
plate({{170,258},{238,258},{241,280},{205,289},{167,280}}, {k=0.3})
plate({{172,243},{236,243},{240,262},{168,262}}, {k=0.3})
plate({{176,224},{232,224},{231,247},{178,247}}, {k=0.3, th=2})
plate({{172,210},{236,210},{233,229},{175,229}}, {k=0.3, th=2})
plate({{168,195},{240,195},{237,214},{171,214}}, {k=0.3, th=2})
-- cuirass: two pectoral plates meeting at a keel
plate({{205,106},{256,108},{253,150},{246,180},{228,199},{206,192}}, {k=0.42})
plate({{152,108},{205,106},{206,192},{181,199},{162,180},{155,150}}, {k=0.28})
work(rib({{206,110},{206,190}}, 1.6, 1.2), {hand="detail", pile=J, coverage=3})
work(rib({{204,112},{204,188}}, 1.2, 1), {hand="detail", pile=PL_lit, coverage=2.5})
-- chest seams and rivets
for _, r in ipairs({{214,120},{226,122},{238,124},{216,176},{230,170}}) do
  work(ellipse(r[1], r[2], 1.1, 1.1), {hand="detail", pile=J, coverage=3})
end
-- F1 arms: rerebrace, actuator, couter, vambrace, gauntlet
for _, s in ipairs({1, -1}) do
  local L = s == 1
  local ax = L and 153 or 257
  local ex = L and 146 or 262
  local hx = L and 151 or 257
  lplate({ax, 126}, {ex + (L and 1 or -1), 196}, 21, 18)
  local px = L and 158 or 251
  work(rib({{px, 186}, {px, 228}}, 4, 4), {hand="detail", pile=J, coverage=3})
  work(rib({{px, 192}, {px, 222}}, 1.3, 1.3), {hand="detail", pile=STEEL, coverage=3})
  lplate({ex, 214}, {hx, 282}, 17, 14)
  plate({{ex - 10, 198}, {ex + 4, 195}, {ex + 12, 203}, {ex + 9, 216}, {ex - 3, 219}, {ex - 11, 210}}, {k=0.3})
  plate({{hx - 10, 284}, {hx + 9, 284}, {hx + 11, 300}, {hx + 1, 310}, {hx - 9, 302}}, {k=0.3, th=2})
  for f = 0, 3 do
    local fx = hx - 7 + f * 4.6
    work(rib({{fx, 304}, {fx + 0.5, 316}, {fx + 1.5, 324}}, 3.6, 2.2), {hand="detail", pile=L and PL_mid or PL_sh, coverage=3})
    work(rib({{fx - 1, 305}, {fx - 0.5, 316}}, 0.8, 0.6), {hand="detail", pile=L and PL_lit or PL_b, coverage=2})
  end
end
-- pauldrons: three overlapping lames each, bottom lame first
plate({{130,124},{170,126},{171,140},{132,139}}, {k=0.3, th=2})
plate({{130,111},{171,112},{173,128},{129,128}}, {k=0.3, th=2})
plate({{133,96},{158,89},{180,95},{183,115},{131,117}}, {k=0.32})
plate({{238,127},{277,125},{278,139},{240,141}}, {k=0.5, th=2})
plate({{236,114},{277,112},{280,129},{238,131}}, {k=0.5, th=2})
plate({{229,98},{250,91},{274,97},{279,116},{231,118}}, {k=0.5})
-- gorget and helm
plate({{184,126},{231,126},{235,140},{208,147},{180,140}}, {k=0.35, th=2})
plate({{189,86},{208,82},{226,88},{231,108},{225,128},{208,136},{191,129},{185,108}}, {k=0.3})
work(rib({{193,115},{207,120},{222,115}}, 4.6, 4.6) + rib({{207,101},{207,129}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3.5})
work(rib({{194,112},{207,117},{220,112}}, 0.9, 0.9), {hand="detail", pile=RIMH, coverage=2})
work(rib({{198,86},{208,83},{218,86}}, 2.6, 2.6), {hand="detail", pile=PL_sh, coverage=3})
work(rib({{197,85},{207,82}}, 1, 1), {hand="detail", pile=RIMH, coverage=2.5})
work, plate, stipple = realwork, realplate, realstipple
DSH = pile{{"bone black",2},{"burnt sienna",1.2},{"red earth",0.3}}
work(SHM - BM, {hand="detail", pile=DSH, coverage=4, load=1})
work(BM, {hand="detail", pile=PL_b, coverage=3})

--@ chunk 50
PL_mid = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone brown",0.5}}
PL_lit = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.4}}
PL_sh = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
PL_b = pile{{"red earth",1},{"burnt sienna",1},{"bone brown",0.6},{"lead white",0.25}}
RIMH = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5}}
SCORCH = pile{{"bone black",2},{"burnt sienna",1}}
function bbox(pts)
  local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, p in ipairs(pts) do
    a = math.min(a, p[1]); b = math.max(b, p[1]); c = math.min(c, p[2]); d = math.max(d, p[2])
  end
  return a, b, c, d
end
-- one armour plate: thickness shadow, midtone, lit crescent, core shadow, fused wet, bounce, hot rim
function plate(pts, o)
  o = o or {}
  local P = poly(pts, o.smooth or false)
  local x0, x1, y0, y1 = bbox(pts)
  local d = o.d or math.max(2.5, (x1 - x0) * (o.k or 0.34))
  local th = o.th or 2.6
  if not o.accent_only then
  work(poly(shiftpts(pts, th * 0.6, th), o.smooth or false) - P, {hand="detail", pile=J, coverage=3})
  work(P, {hand="detail", pile=o.mid or PL_mid, coverage=3.5})
  work(P - poly(shiftpts(pts, d, d * 0.2), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3.5})
  work(P - poly(shiftpts(pts, -d * 1.1, -d * 0.15), o.smooth or false), {hand="detail", pile=o.sh or PL_sh, coverage=3.5})
  if not o.noblend then
    work(P, {hand="blend", tool={kind="badger", width=math.min(12, math.max(4, (x1 - x0) * 0.4))}, angle=o.angle or 1.57, coverage=1})
  end
  end
  -- after the fusing: a narrower core shadow and a narrower light, so the form keeps its turn
  work(P - poly(shiftpts(pts, -d * 0.75, -d * 0.1), o.smooth or false) - (P - poly(shiftpts(pts, -2.6, -0.3), o.smooth or false)), {hand="detail", pile=o.sh or PL_sh, coverage=3})
  work(P - poly(shiftpts(pts, d * 0.55, d * 0.1), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3})
  work(P - poly(shiftpts(pts, -2.2, -0.3), o.smooth or false), {hand="detail", pile=o.b or PL_b, coverage=2.5})
  if not o.norim then
    work(P - poly(shiftpts(pts, 1.5, 0.9), o.smooth or false), {hand="detail", pile=o.rim or RIMH, coverage=3})
  end
  return P
end
-- a tapered limb plate between two spine points
function lplate(a, b, w0, w1, o)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts = {{a[1] + nx * w0 / 2, a[2] + ny * w0 / 2}, {a[1] - nx * w0 / 2, a[2] - ny * w0 / 2},
               {b[1] - nx * w1 / 2, b[2] - ny * w1 / 2}, {b[1] + nx * w1 / 2, b[2] + ny * w1 / 2}}
  o = o or {}
  o.angle = o.angle or math.atan(dy, dx)
  return plate(pts, o)
end
wait(12*60)
-- umbilicals and cabling: yoke to the back of the helm and down the shoulders
for _, c in ipairs({{{214,80},{224,92},{228,104}}, {{226,80},{238,94},{244,106}}, {{233,81},{250,92},{262,100}},
                    {{240,140},{246,160},{244,186}}, {{168,138},{164,160},{165,186}}}) do
  work(rib(c, 3.2, 2.6), {hand="detail", pile=J, coverage=3.5})
  work(rib(shiftpts(c, -0.9, -0.4), 0.9, 0.7), {hand="detail", pile=PL_b, coverage=2})
end
-- yoke clamp restated
plate({{160,68},{244,68},{244,81},{160,81}}, {k=0.25, th=2, noblend=true})
work(ribbon({{200,0},{201,68}}, 4), {hand="detail", pile=J, coverage=3})
-- wear: scorch at the lower plate edges, scratches on the lit planes
stipple(rect(222,160,30,34) + rect(176,262,30,24) + rect(184,420,14,24) + rect(244,118,26,16), {pile=SCORCH, width=1.6, coverage=0.5, cluster=0.8, pressure={0.3,0.6}})
local bb = brush{kind="round", width=1.2, point=0.8}
for _, s in ipairs({{{186,300},{193,306}}, {{178,410},{181,420}}, {{148,232},{152,238}}, {{240,256},{246,252}}, {{220,132},{226,136}}, {{140,102},{148,99}}, {{183,330},{188,336}}}) do
  bb:reload(RIMH, 0.4)
  bb:stroke(s, {pressure={0.4, 0.05}})
end
-- the crimson cloth and the rosary, laid back over the new armour
local cloth = poly({{163,64},{198,62},{200,76},{194,110},{190,160},{184,212},{174,206},{166,176},{160,128},{150,96}}, true):roughen(1.5, 14, 6)
work(cloth, {hand="body", tool="filbert 3", pile=CRs, angle=1.57, coverage=4, fill=true, clip=true})
for _, f in ipairs({{{170,70},{168,110},{170,160},{176,200}}, {{182,68},{180,120},{182,175}}, {{160,90},{164,130},{168,170}}}) do
  work(rib(f, 5, 2) * cloth, {hand="detail", pile=CR, coverage=3})
end
work(rib({{156,86},{158,120},{164,160},{170,198}}, 2.2, 1) * cloth, {hand="detail", pile=CRL, coverage=3})
work(rib({{192,72},{190,120},{186,170},{182,208}}, 2.4, 1.6) * cloth, {hand="detail", pile=CRs, coverage=3})
local strand = {{205,74},{216,80},{226,90},{232,104},{232,118},{228,130},{220,140},{211,146}}
work(rib(strand, 0.8, 0.8), {hand="detail", pile=J, coverage=2.5})
for i = 1, #strand - 1 do
  for k = 0, 1 do
    local a, b = strand[i], strand[i+1]
    local x, y = lerp(a[1], b[1], k / 2), lerp(a[2], b[2], k / 2)
    work(ellipse(x, y, 2.4, 2.4), {hand="detail", pile=J, coverage=3})
    work(ellipse(x - 0.5, y - 0.4, 1.7, 1.7), {hand="detail", pile=BEAD, coverage=3})
  end
end
work(rib({{209,148},{209,166}}, 2.6, 2.4) + rib({{203,154},{215,154}}, 2.4, 2.4), {hand="detail", tool={kind="round", width=2}, pile=BR, coverage=3.5})
work(rib({{208,149},{208,165}}, 0.8, 0.8), {hand="detail", pile=RIMH, coverage=2})
work(rib({{150,104},{150,116}}, 2, 2), {hand="detail", pile=J, coverage=3})
-- helm: the lit side and the visor restated over the shadow pass
work(poly({{189,88},{204,83},{204,132},{191,128},{186,108}}), {hand="detail", pile=PL_lit, coverage=3})
work(rib({{193,115},{207,120},{222,115}}, 4.6, 4.6) + rib({{207,101},{207,129}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3.5})
work(rib({{189,92},{187,110},{192,127}}, 1.4, 1.2), {hand="detail", pile=RIMH, coverage=3})

--@ chunk 51
PL_mid = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone brown",0.5}}
PL_lit = pile{{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.4}}
PL_sh = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
PL_b = pile{{"red earth",1},{"burnt sienna",1},{"bone brown",0.6},{"lead white",0.25}}
RIMH = pile{{"lead white",3},{"cadmium yellow",0.6},{"lemon chrome",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5}}
SCORCH = pile{{"bone black",2},{"burnt sienna",1}}
function bbox(pts)
  local a, b, c, d = 1e9, -1e9, 1e9, -1e9
  for _, p in ipairs(pts) do
    a = math.min(a, p[1]); b = math.max(b, p[1]); c = math.min(c, p[2]); d = math.max(d, p[2])
  end
  return a, b, c, d
end
-- one armour plate: thickness shadow, midtone, lit crescent, core shadow, fused wet, bounce, hot rim
function plate(pts, o)
  o = o or {}
  local P = poly(pts, o.smooth or false)
  local x0, x1, y0, y1 = bbox(pts)
  local d = o.d or math.max(2.5, (x1 - x0) * (o.k or 0.34))
  local th = o.th or 2.6
  if not o.accent_only then
  work(poly(shiftpts(pts, th * 0.6, th), o.smooth or false) - P, {hand="detail", pile=J, coverage=3})
  work(P, {hand="detail", pile=o.mid or PL_mid, coverage=3.5})
  work(P - poly(shiftpts(pts, d, d * 0.2), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3.5})
  work(P - poly(shiftpts(pts, -d * 1.1, -d * 0.15), o.smooth or false), {hand="detail", pile=o.sh or PL_sh, coverage=3.5})
  if not o.noblend then
    work(P, {hand="blend", tool={kind="badger", width=math.min(12, math.max(4, (x1 - x0) * 0.4))}, angle=o.angle or 1.57, coverage=1})
  end
  end
  -- after the fusing: a narrower core shadow and a narrower light, so the form keeps its turn
  work(P - poly(shiftpts(pts, -d * 0.75, -d * 0.1), o.smooth or false) - (P - poly(shiftpts(pts, -2.6, -0.3), o.smooth or false)), {hand="detail", pile=o.sh or PL_sh, coverage=3})
  work(P - poly(shiftpts(pts, d * 0.55, d * 0.1), o.smooth or false), {hand="detail", pile=o.lit or PL_lit, coverage=3})
  work(P - poly(shiftpts(pts, -2.2, -0.3), o.smooth or false), {hand="detail", pile=o.b or PL_b, coverage=2.5})
  if not o.norim then
    work(P - poly(shiftpts(pts, 1.5, 0.9), o.smooth or false), {hand="detail", pile=o.rim or RIMH, coverage=3})
  end
  return P
end
-- a tapered limb plate between two spine points
function lplate(a, b, w0, w1, o)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts = {{a[1] + nx * w0 / 2, a[2] + ny * w0 / 2}, {a[1] - nx * w0 / 2, a[2] - ny * w0 / 2},
               {b[1] - nx * w1 / 2, b[2] - ny * w1 / 2}, {b[1] + nx * w1 / 2, b[2] + ny * w1 / 2}}
  o = o or {}
  o.angle = o.angle or math.atan(dy, dx)
  return plate(pts, o)
end
wait(6*60)
local hp = {{190,86},{208,81},{226,87},{231,107},{225,128},{208,137},{191,129},{185,107}}
plate(hp, {k=0.3})
work(poly(hp) - poly(shiftpts(hp, -11, -1)), {hand="detail", pile=DSH, coverage=3.5})
work(rib({{193,113},{207,118},{222,113}}, 4.6, 4.6) + rib({{207,100},{207,128}}, 3.6, 3.6), {hand="detail", pile=J, coverage=3.5})
work(rib({{194,110},{206,114}}, 0.9, 0.9), {hand="detail", pile=RIMH, coverage=2.5})
work(rib({{198,85},{208,82},{218,85}}, 2.2, 2.2), {hand="detail", pile=PL_sh, coverage=3})
work(rib({{186,96},{185,110},{190,126}}, 1.6, 1.2), {hand="detail", pile=RIMH, coverage=3})
local strand = {{226,90},{232,104},{232,118},{228,130}}
for i = 1, #strand do
  local p = strand[i]
  work(ellipse(p[1], p[2], 2.4, 2.4), {hand="detail", pile=J, coverage=3})
  work(ellipse(p[1] - 0.5, p[2] - 0.4, 1.7, 1.7), {hand="detail", pile=BEAD, coverage=3})
end

--@ chunk 52
RIM3 = pile{{"Mars orange",1},{"lead white",1},{"yellow ochre",0.5}}
RIM4 = pile{{"Mars orange",1},{"burnt sienna",0.6},{"lead white",0.5}}
local function gun(pts, w, body, rim, muzzle)
  work(rib(pts, w, w * 0.8), {hand="detail", pile=body, coverage=3.5})
  work(rib(shiftpts(pts, -w * 0.25, -w * 0.3), w * 0.25, w * 0.2), {hand="detail", pile=rim, coverage=2.5})
  local e = pts[#pts]
  if muzzle then work(ellipse(e[1], e[2], w * 0.45, w * 0.45), {hand="detail", pile=J, coverage=3}) end
end
-- F3: an over-under pair of guns on the back, a ventral cannon, manipulators at the front, a sensor mast with a dish
gun({{632,178},{600,170},{560,163},{520,158}}, 6, C.dark, RIM3, true)
gun({{640,186},{600,180},{566,175}}, 5, C.base, RIM3, true)
gun({{604,232},{598,248},{584,262},{560,272}}, 6, C.dark, RIM4, true)
for _, m in ipairs({{{546,170},{532,190},{528,214},{520,226}}, {{570,172},{586,196},{590,222},{598,232}}}) do
  gun(m, 3, C.dark, RIM3, false)
  local e = m[#m]
  work(rib({e, {e[1] - 4, e[2] + 7}}, 1.4, 0.8) + rib({e, {e[1] + 3, e[2] + 8}}, 1.4, 0.8), {hand="detail", pile=C.dark, coverage=3})
end
gun({{622,186},{624,160},{628,138},{634,120}}, 3, C.dark, RIM3, false)
work(ellipse(637,116,7,3), {hand="detail", pile=C.dark, coverage=3.5})
work(rib({{631,114},{641,113}}, 1, 0.8), {hand="detail", pile=RIM3, coverage=2.5})
-- warm rim down the lit fronts of F3's legs and barrel nose
for _, l in ipairs({{{554,226},{550,252},{554,278},{548,298},{550,318}}, {{575,230},{576,256},{582,280},{578,300},{580,318}},
                    {{616,228},{614,254},{620,278},{614,298},{616,316}}, {{634,222},{638,248},{644,272},{640,294},{642,314}},
                    {{545,196},{544,210},{550,224}}}) do
  work(rib(l, 1.4, 0.9), {hand="detail", pile=RIM4, coverage=2.5})
end
-- F4: a rotary gun, more manipulators, rims both warm (near) and cold (from the thing beyond)
gun({{688,214},{668,218},{650,222}}, 5, D4.dark, RIM4, true)
work(rib({{670,215},{652,219}}, 0.8, 0.8) + rib({{670,221},{652,225}}, 0.8, 0.8), {hand="detail", pile=J, coverage=3})
for _, m in ipairs({{{702,232},{694,252},{686,266},{680,276}}, {{748,228},{758,246},{768,256},{776,262}}, {{728,234},{730,256},{724,272}}}) do
  gun(m, 2.6, D4.dark, RIM4, false)
  local e = m[#m]
  work(rib({e, {e[1] - 3, e[2] + 6}}, 1.2, 0.7) + rib({e, {e[1] + 3, e[2] + 6}}, 1.2, 0.7), {hand="detail", pile=D4.dark, coverage=3})
end
for _, m in ipairs({{{712,204},{710,180},{706,150}}, {{724,202},{726,176},{730,140}}, {{704,186},{698,166},{692,150}}, {{718,203},{714,188},{716,166}}}) do
  work(rib(shiftpts(m, -1, 0), 0.9, 0.5), {hand="detail", pile=RIM4, coverage=2.2})
end
for _, m in ipairs({{{736,204},{740,184},{748,160}}, {{748,206},{756,190},{766,174}}, {{756,224},{762,240},{766,256}}}) do
  work(rib(shiftpts(m, 1, 0), 0.9, 0.5), {hand="detail", pile=COLD, coverage=2.2})
end
work(rib({{688,207},{720,202},{752,206}}, 1.4, 1.2), {hand="detail", pile=RIM4, coverage=2.5})
work(rib({{756,212},{760,220},{754,230}}, 1.2, 1), {hand="detail", pile=COLD, coverage=2.5})

--@ chunk 53
wait(12*60)
G2 = {mid=B2, lit=pile{{"lead white",1.5},{"Mars orange",0.4},{"ultramarine ash",0.6},{"bone black",0.25}},
      sh=S2, b=pile{{"burnt sienna",1},{"red earth",0.5},{"bone black",0.6}},
      rim=pile{{"lead white",1.5},{"Mars orange",0.8},{"cadmium yellow",0.3}}}
local function g(o) o = o or {}; for k, v in pairs(G2) do if o[k] == nil then o[k] = v end end; return o end
-- legs: reverse-jointed, plated
for _, s in ipairs({1, -1}) do
  local L = s == 1
  lplate(L and {402,232} or {440,232}, L and {396,280} or {447,280}, 20, 15, g())
  lplate(L and {396,284} or {447,284}, L and {408,330} or {436,330}, 13, 10, g())
  lplate(L and {408,333} or {436,333}, L and {400,370} or {442,372}, 9, 6, g({th=1.5}))
  work(ellipse(L and 396 or 447, 282, 6, 5) + ellipse(L and 408 or 436, 331, 4.5, 4), {hand="detail", pile=J, coverage=3})
  work(rib(L and {{404,262},{410,300}} or {{438,262},{432,300}}, 1.3, 1.3), {hand="detail", pile=STEEL, coverage=3})
end
-- lower arm pair: barrel and claw
lplate({396,180}, {388,234}, 11, 9, g())
lplate({388,236}, {384,312}, 8, 7, g({th=1.5}))
work(rib({{384,248},{382,306}}, 1, 1), {hand="detail", pile=G2.rim, coverage=2.5})
work(ellipse(384,312,2.5,2), {hand="detail", pile=J, coverage=3})
lplate({448,180}, {456,232}, 11, 9, g())
-- pelvis, abdomen, chest
plate({{396,203},{444,203},{448,232},{392,232}}, g({k=0.3}))
plate({{390,170},{452,170},{442,206},{398,206}}, g({k=0.3, th=2}))
plate({{421,110},{458,110},{455,172},{421,176}}, g({k=0.5}))
plate({{386,110},{421,110},{421,176},{390,172}}, g({k=0.3}))
-- upper arms over the chest edge
lplate({384,120}, {379,172}, 14, 13, g())
lplate({379,174}, {380,224}, 13, 11, g())
lplate({459,122}, {465,172}, 14, 13, g())
lplate({465,174}, {461,224}, 13, 11, g())
-- sensor head and yoke
plate({{410,108},{440,106},{446,124},{434,134},{412,132},{406,120}}, g({k=0.3}))
for _, p in ipairs({{416,121},{424,124},{431,120}}) do
  work(ellipse(p[1], p[2], 2.6, 2.6), {hand="detail", pile=J, coverage=3})
  work(ellipse(p[1] - 0.6, p[2] - 0.6, 1, 1), {hand="detail", pile=H1, coverage=3})
end
plate({{392,98},{450,98},{450,107},{392,107}}, g({k=0.25, noblend=true}))
-- the worn cross and the numeral
work(rib({{404,146},{404,168}}, 3, 3) + rib({{397,154},{411,154}}, 3, 3), {hand="detail", pile=CRW, coverage=2.2})
for _, s in ipairs({{{397,151},{403,156}}, {{405,160},{410,163}}, {{402,165},{406,169}}}) do
  work(rib(s, 1.3, 0.9), {hand="detail", pile=B2, coverage=3})
end
work(rib({{437,160},{437,167}}, 1.3, 1.3) + rib({{441,160},{441,167}}, 1.3, 1.3), {hand="detail", pile=STN, coverage=3})
stipple(rect(426,180,22,24) + rect(392,214,20,16), {pile=SCORCH, width=1.4, coverage=0.4, cluster=0.8})

--@ chunk 54
wait(12*60)
local realwork, realplate, realstipple = work, plate, stipple
local SHM, BM
local function add(a, b) if a == nil then return b end return a + b end
work = function() end
stipple = function() end
plate = function(pts, o)
  o = o or {}
  local x0, x1 = bbox(pts)
  local d = math.max(2.5, (x1 - x0) * (o.shk or 0.48))
  local P = poly(pts)
  SHM = add(SHM, P - poly(shiftpts(pts, -d, -d * 0.1)))
  BM = add(BM, P - poly(shiftpts(pts, -2.4, -0.3)))
  return P
end
G2 = {mid=B2, lit=pile{{"lead white",1.5},{"Mars orange",0.4},{"ultramarine ash",0.6},{"bone black",0.25}},
      sh=S2, b=pile{{"burnt sienna",1},{"red earth",0.5},{"bone black",0.6}},
      rim=pile{{"lead white",1.5},{"Mars orange",0.8},{"cadmium yellow",0.3}}}
local function g(o) o = o or {}; for k, v in pairs(G2) do if o[k] == nil then o[k] = v end end; return o end
-- legs: reverse-jointed, plated
for _, s in ipairs({1, -1}) do
  local L = s == 1
  lplate(L and {402,232} or {440,232}, L and {396,280} or {447,280}, 20, 15, g())
  lplate(L and {396,284} or {447,284}, L and {408,330} or {436,330}, 13, 10, g())
  lplate(L and {408,333} or {436,333}, L and {400,370} or {442,372}, 9, 6, g({th=1.5}))
  work(ellipse(L and 396 or 447, 282, 6, 5) + ellipse(L and 408 or 436, 331, 4.5, 4), {hand="detail", pile=J, coverage=3})
  work(rib(L and {{404,262},{410,300}} or {{438,262},{432,300}}, 1.3, 1.3), {hand="detail", pile=STEEL, coverage=3})
end
-- lower arm pair: barrel and claw
lplate({396,180}, {388,234}, 11, 9, g())
lplate({388,236}, {384,312}, 8, 7, g({th=1.5}))
work(rib({{384,248},{382,306}}, 1, 1), {hand="detail", pile=G2.rim, coverage=2.5})
work(ellipse(384,312,2.5,2), {hand="detail", pile=J, coverage=3})
lplate({448,180}, {456,232}, 11, 9, g())
-- pelvis, abdomen, chest
plate({{396,203},{444,203},{448,232},{392,232}}, g({k=0.3}))
plate({{390,170},{452,170},{442,206},{398,206}}, g({k=0.3, th=2}))
plate({{421,110},{458,110},{455,172},{421,176}}, g({k=0.5}))
plate({{386,110},{421,110},{421,176},{390,172}}, g({k=0.3}))
-- upper arms over the chest edge
lplate({384,120}, {379,172}, 14, 13, g())
lplate({379,174}, {380,224}, 13, 11, g())
lplate({459,122}, {465,172}, 14, 13, g())
lplate({465,174}, {461,224}, 13, 11, g())
-- sensor head and yoke
plate({{410,108},{440,106},{446,124},{434,134},{412,132},{406,120}}, g({k=0.3}))
for _, p in ipairs({{416,121},{424,124},{431,120}}) do
  work(ellipse(p[1], p[2], 2.6, 2.6), {hand="detail", pile=J, coverage=3})
  work(ellipse(p[1] - 0.6, p[2] - 0.6, 1, 1), {hand="detail", pile=H1, coverage=3})
end
plate({{392,98},{450,98},{450,107},{392,107}}, g({k=0.25, noblend=true}))
-- the worn cross and the numeral
work(rib({{404,146},{404,168}}, 3, 3) + rib({{397,154},{411,154}}, 3, 3), {hand="detail", pile=CRW, coverage=2.2})
for _, s in ipairs({{{397,151},{403,156}}, {{405,160},{410,163}}, {{402,165},{406,169}}}) do
  work(rib(s, 1.3, 0.9), {hand="detail", pile=B2, coverage=3})
end
work(rib({{437,160},{437,167}}, 1.3, 1.3) + rib({{441,160},{441,167}}, 1.3, 1.3), {hand="detail", pile=STN, coverage=3})
stipple(rect(426,180,22,24) + rect(392,214,20,16), {pile=SCORCH, width=1.4, coverage=0.4, cluster=0.8})
work, plate, stipple = realwork, realplate, realstipple
DSH2 = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}}
work(SHM - BM, {hand="detail", pile=DSH2, coverage=4, load=1})
work(BM, {hand="detail", pile=G2.b, coverage=3})
work(rib({{404,146},{404,168}}, 3, 3) + rib({{397,154},{411,154}}, 3, 3), {hand="detail", pile=CRW, coverage=3})
for _, s in ipairs({{{397,151},{403,156}}, {{405,160},{410,163}}}) do
  work(rib(s, 1.3, 0.9), {hand="detail", pile=B2, coverage=3})
end
