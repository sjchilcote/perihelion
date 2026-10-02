-- easel session "museum": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=21,
  ground={{pile={{"raw sienna",2},{"burnt sienna",1},{"lead white",1},{"bone black",0.3}}, um=120, apply="knife", texture=0.3}}}
WALLD = pile{{"burnt sienna",1.2},{"raw sienna",1},{"bone black",1},{"ultramarine blue",0.3}}
WALLM = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.5},{"lead white",0.3}}
FLOOR = pile{{"bone brown",1.5},{"burnt sienna",1},{"bone black",0.6}}
ARCH = poly({{540,470},{540,200},{560,150},{600,120},{660,100},{745,92},{830,100},{890,120},{930,150},{950,200},{950,470}}, true)
HALLWALL = rect(-5,-5,1010,476) - ARCH
HALLFLOOR = rect(-5,470,1010,160)
work(HALLWALL*rect(-5,-5,1010,230), {hand="broad", pile=WALLD, coverage=3, fill=true, clip=HALLWALL, angle=1.5708})
work(HALLWALL*rect(-5,225,1010,252), {hand="broad", pile=WALLM, coverage=3, fill=true, clip=HALLWALL, angle=1.5708})
work(HALLFLOOR, {hand="broad", pile=FLOOR, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 2
local pts = {{560,470}}
for i=0,24 do local a = math.pi - i*math.pi/24; pts[#pts+1] = {745 + 185*math.cos(a), 215 - 120*math.sin(a)} end
pts[#pts+1] = {930,470}
ARCH = poly(pts)
HALLWALL = rect(-5,-5,1010,476) - ARCH
WALLM2 = pile{{"burnt sienna",1.2},{"raw sienna",1.2},{"bone black",0.8},{"lead white",0.15}}
work(HALLWALL*rect(-5,150,1010,327), {hand="body", pile=WALLM2, coverage=3, fill=true, clip=HALLWALL, angle=1.5708})
work(HALLWALL*rect(-5,-5,1010,160), {hand="body", pile=WALLD, coverage=3, fill=true, clip=HALLWALL, angle=1.5708})
blend(HALLWALL*rect(-5,130,1010,45), {angle=1.5708})

--@ chunk 3
RBACK = pile{{"lead white",2.2},{"yellow ochre",1},{"raw sienna",0.3}}
RSIDE = pile{{"lead white",1.2},{"yellow ochre",1},{"burnt sienna",0.4},{"raw sienna",0.4}}
RSIDE2 = pile{{"lead white",0.9},{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.1}}
RFLOOR = pile{{"lead white",1},{"raw sienna",1},{"burnt sienna",0.4},{"yellow ochre",0.4}}
RCEIL = pile{{"raw sienna",1},{"burnt sienna",0.8},{"lead white",0.5},{"bone black",0.2}}
BW = {630,175,860,395}
R_BACK = rect(630,175,230,220)
R_FLOOR = poly({{555,475},{935,475},{860,395},{630,395}})
R_LEFT = poly({{555,475},{630,395},{630,175},{555,100}}) * ARCH
R_RIGHT = poly({{935,475},{860,395},{860,175},{935,100}}) * ARCH
R_CEIL = ARCH - R_BACK - R_FLOOR - R_LEFT - R_RIGHT
work(R_BACK, {hand="body", pile=RBACK, coverage=3, fill=true, clip=true, angle=1.5708})
work(R_LEFT, {hand="body", pile=RSIDE, coverage=3, fill=true, clip=true, angle=1.5708})
work(R_RIGHT, {hand="body", pile=RSIDE2, coverage=3, fill=true, clip=true, angle=1.5708})
work(R_FLOOR, {hand="body", pile=RFLOOR, coverage=3, fill=true, clip=true, angle=0})
work(R_CEIL, {hand="body", pile=RCEIL, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 4
print(wait(2*24*60)); print(drying(745,300), drying(300,300), drying(300,550))

--@ chunk 5
function T(x0,y0,s) return function(x,y) return {x0 + (x-560)*s, y0 + (y-95)*s} end end
function archpoly(f)
  local pts = {f(560,470)}
  for i=0,24 do local a = math.pi - i*math.pi/24; pts[#pts+1] = f(745 + 185*math.cos(a), 215 - 120*math.sin(a)) end
  pts[#pts+1] = f(930,470)
  return poly(pts)
end
function roomview(x0,y0,s, tool)
  local f = T(x0,y0,s)
  local A = archpoly(f)
  local back = poly({f(630,175),f(860,175),f(860,395),f(630,395)})
  local floor = poly({f(555,475),f(935,475),f(860,395),f(630,395)}) * A
  local left = poly({f(555,475),f(630,395),f(630,175),f(555,100)}) * A
  local right = poly({f(935,475),f(860,395),f(860,175),f(935,100)}) * A
  local ceil = A - back - floor - left - right
  local o = {hand="detail", tool=tool, coverage=5, fill=true, clip=true}
  local function w(m,p) o.pile=p; work(m,o) end
  w(back, RBACK); w(left, RSIDE); w(right, RSIDE2); w(floor, RFLOOR); w(ceil, RCEIL)
  return A
end
DOOR1 = archpoly(T(700,300,0.25))
-- jamb: a slightly larger dark reveal behind the door shape
work(archpoly(T(696,296,0.272)) , {hand="detail", tool="round 2", pile=RSIDE2, coverage=5, fill=true, clip=true})
roomview(700,300,0.25,"round 1.6")

--@ chunk 6
FRAME_D = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.4}}
FRAME_M = pile{{"bone black",1.4},{"ultramarine ash",1},{"burnt sienna",0.3},{"lead white",0.15}}
TABARD = pile{{"Mars red",1},{"bone black",0.8},{"burnt sienna",0.6}}
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
RIMW = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}
function frame_back(cx, fy, h, tool, withcross)
  local function P(x,y) return {cx + x*h, fy + y*h} end
  local function pl(t) local o={} for i,v in ipairs(t) do o[i]=P(v[1],v[2]) end return poly(o, false) end
  local o = {hand="detail", tool=tool, coverage=5, fill=true, clip=true}
  local function w(m,p) o.pile=p; work(m,o) end
  local legs = pl({{-0.15,-0.44},{-0.03,-0.44},{-0.06,0},{-0.17,0}}) + pl({{0.03,-0.44},{0.15,-0.44},{0.18,0},{0.07,0}})
  local arms = pl({{-0.29,-0.80},{-0.19,-0.79},{-0.22,-0.47},{-0.31,-0.48}}) + pl({{0.19,-0.79},{0.29,-0.80},{0.32,-0.50},{0.24,-0.47}})
  local torso = pl({{-0.21,-0.84},{0.21,-0.84},{0.18,-0.56},{0.12,-0.43},{-0.12,-0.43},{-0.18,-0.56}})
  local head = ellipse(cx, fy-0.925*h, 0.075*h, 0.07*h) + pl({{-0.04,-0.88},{0.04,-0.88},{0.035,-0.83},{-0.035,-0.83}})
  local paul = ellipse(cx-0.21*h, fy-0.8*h, 0.095*h, 0.06*h) + ellipse(cx+0.21*h, fy-0.8*h, 0.095*h, 0.06*h)
  w(legs, FRAME_D); w(arms, FRAME_D); w(torso, FRAME_M); w(head, FRAME_M); w(paul, FRAME_M)
  local tab = pl({{-0.15,-0.79},{0.15,-0.79},{0.165,-0.27},{0.06,-0.23},{-0.05,-0.27},{-0.16,-0.24}})
  w(tab, TABARD)
  local all = legs + arms + torso + head + paul
  if withcross then
    local c = brush{kind="flat", width=0.035*h}
    c:reload(BONE, 0.5); c:stroke({P(0,-0.72),P(0,-0.4)}, {pressure={0.6,0.5}, orient="across", clip=tab})
    c:reload(BONE, 0.5); c:stroke({P(-0.08,-0.63),P(0.08,-0.63)}, {pressure={0.6,0.5}, orient="across", clip=tab})
  end
  return all + tab
end
FRAME1 = frame_back(640, 456, 185, "round 2.5", true)
FRAME2 = frame_back(720, 390, 46, "round 1.2", true)
-- the second doorway, deeper, and a last speck of him
local f2 = T(735,351.25,0.0625)
work(archpoly(f2), {hand="detail", tool="round 1", pile=RBACK, coverage=6, fill=true, clip=true})
local d = brush{kind="round", width=1.4, point=0.3}
d:reload(FRAME_D, 0.8); d:stroke({{740,371.5},{740,374.5}}, {pressure={0.8,0.8}})

--@ chunk 7
local pts = {{70,425}}
for i=0,20 do local a = math.pi - i*math.pi/20; pts[#pts+1] = {210 + 140*math.cos(a), 160 - 90*math.sin(a)} end
pts[#pts+1] = {350,425}
PLATE = poly(pts)
PLATE_IN = PLATE:shrink(10)
BRZ_D = pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.6},{"yellow ochre",0.3}}
BRZ_M = pile{{"raw sienna",1.2},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.25}}
BRZ_L = pile{{"yellow ochre",1.5},{"raw sienna",0.6},{"lead white",0.6},{"burnt sienna",0.2}}
-- the rim (frame), lit from the right where the room's light spills
work(PLATE - PLATE_IN, {hand="detail", tool="round 3", pile=BRZ_M, coverage=4, fill=true, clip=true})
work((PLATE - PLATE_IN)*rect(250,0,120,430), {hand="detail", tool="round 3", pile=BRZ_L, coverage=4, fill=true, clip=true})
-- the field: dark bronze, warmer toward the right
work(PLATE_IN, {hand="body", tool="filbert 6", pile=BRZ_D, coverage=3.5, fill=true, clip=true, angle=1.5708})
work(PLATE_IN*rect(230,0,140,430), {hand="body", tool="filbert 6", pile=BRZ_M, coverage=2.5, fill=true, clip=true, angle=1.5708})
blend(PLATE_IN*rect(205,60,55,370), {angle=0})

--@ chunk 8
BRZ_H = pile{{"yellow ochre",1},{"cadmium yellow",0.4},{"lead white",1.2},{"raw sienna",0.2}}
VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
local o = {hand="detail", tool="round 3", coverage=4, fill=true, clip=true}
local function w(m,p,ang) o.pile=p; o.angle=ang; work(m,o) end
-- bell of long lamellar plates
BELL = poly({{398,318},{462,318},{474,380},{490,470},{502,548},{356,548},{370,470},{384,380}}, true)
w(BELL, BRZ_D, 1.5708)
w(BELL*poly({{440,300},{480,300},{520,560},{455,560}}), BRZ_M, 1.5708)
w(BELL*poly({{466,300},{480,300},{520,560},{490,560}}), BRZ_L, 1.5708)
-- spine of stacked discs
SPINE = poly({{419,322},{441,322},{437,210},{425,210}})
w(SPINE, BRZ_M, 1.5708)
w(SPINE*rect(432,200,20,130), BRZ_L, 1.5708)
-- shoulder yoke
YOKE = ellipse(431,228,26,9)
w(YOKE, BRZ_M, 0); w(YOKE*rect(431,215,30,10), BRZ_L, 0)
-- head: a ring of bronze petals round a bone disc
HEADR = ellipse(424,168,36,32)
w(HEADR, BRZ_M, 0)
w(HEADR*rect(428,130,40,80), BRZ_L, 0)
HEADD = ellipse(424,168,17,15)
w(HEADD, BONE, 0)
-- neck
w(poly({{425,186},{433,186},{434,212},{426,212}}), BRZ_D, 1.5708)

--@ chunk 9
wait(4*24*60) print(drying(100,300), drying(200,250), drying(430,400), drying(640,350), drying(500,550))

--@ chunk 10
wait(5*24*60) print(drying(100,300), drying(200,250), drying(430,400), drying(640,350), drying(300,50))

--@ chunk 11
DOCENT = BELL + SPINE + YOKE + HEADR + poly({{425,186},{433,186},{434,212},{426,212}})
WALLDK = pile{{"burnt sienna",1},{"bone black",1.2},{"raw sienna",0.6},{"ultramarine blue",0.3}}
WALLGL = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.45},{"yellow ochre",0.45}}
local base = HALLWALL - PLATE - DOCENT
local glow = ARCH:grow(70) - ARCH
work(base - glow, {hand="body", pile=WALLDK, coverage=3.5, fill=true, clip=base, angle=1.5708})
work(base * glow, {hand="body", pile=WALLGL, coverage=3.5, fill=true, clip=base, angle=1.5708})
blend(base * (ARCH:grow(85) - ARCH:grow(55)), {angle=1.5708})

--@ chunk 12
PLATE_D = pile{{"burnt sienna",1},{"bone black",0.9},{"raw sienna",0.7}}
PLATE_D2 = pile{{"burnt sienna",1},{"bone black",0.6},{"raw sienna",0.9},{"yellow ochre",0.2}}
work(PLATE_IN, {hand="body", tool="filbert 6", pile=PLATE_D, coverage=3.5, fill=true, clip=true, angle=1.5708})
work(PLATE_IN*ellipse(300,260,90,200), {hand="body", tool="filbert 6", pile=PLATE_D2, coverage=2.5, fill=true, clip=PLATE_IN, angle=1.5708})
blend(PLATE_IN*(ellipse(300,260,110,220) - ellipse(300,260,70,180)), {angle=1.5708})
-- frame: darker left half so the lit right edge reads as a raised moulding
work((PLATE - PLATE_IN)*rect(60,0,170,430), {hand="detail", tool="round 3", pile=BRZ_D, coverage=4, fill=true, clip=true})

--@ chunk 13
wait(5*24*60) print(drying(150,300), drying(300,260))

--@ chunk 14
wait(4*24*60) print(drying(150,300), drying(300,260), drying(430,400))

--@ chunk 15
BONE_HI = pile{{"lead white",3},{"yellow ochre",0.6},{"lemon chrome",0.1}}
BONE_SH = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.1}}
local function sq(cx,cy,s,w,p)
  local b = brush{kind="round", width=w, point=0.2}
  local h = s/2
  local c = {{cx-h,cy-h},{cx+h,cy-h},{cx+h,cy+h},{cx-h,cy+h}}
  for i=1,4 do
    local a, z = c[i], c[i%4+1]
    b:reload(p, 0.9)
    b:stroke({a,z}, {pressure={0.75,0.75}, ramps={0.01,0.01}})
  end
end
GX, GY, GS = 210, 268, 128
-- the room-glyph, its inset (0.618), and the inset's inset
sq(GX, GY, GS, 3.2, BONE)
sq(GX+6, GY, GS*0.618, 2.4, BONE)
sq(GX+10, GY, GS*0.382, 1.8, BONE)
sq(GX+12.5, GY, GS*0.236, 1.4, BONE_SH)
-- notches: two ticks on the far (top) edge and the near (bottom) edge: the same door
local t = brush{kind="round", width=2.2, point=0.3}
for _,e in ipairs({{GY-GS/2, -1},{GY+GS/2, 1}}) do
  for k,dx in ipairs({-6, 4}) do
    t:reload(BONE, 0.9)
    t:stroke({{GX+dx, e[1]},{GX+dx, e[1]+e[2]*9}}, {pressure={0.7,0.7}, ramps={0.01,0.01}})
  end
  -- chevron on the notch
  t:reload(BONE, 0.9)
  t:stroke({{GX+10, e[1]+e[2]*4},{GX+15, e[1]+e[2]*9},{GX+20, e[1]+e[2]*4}}, {pressure={0.55,0.55}})
end
-- the bridge: an arc leaving the far edge and coming back into the near edge (the room opens onto itself)
local arc = {}
for i=0,24 do
  local a = -math.pi/2 - i*math.pi/24
  arc[#arc+1] = {GX - 2 + 112*math.cos(a)*0.95 + (i==0 and 0 or 0), GY + 92*math.sin(a)}
end
arc[1] = {GX-2, GY-GS/2-10}; arc[#arc] = {GX-2, GY+GS/2+10}
local ab = brush{kind="round", width=3.0, point=0.4}
ab:reload(BONE, 1.0)
ab:stroke(arc, {pressure={0.4,0.4}, swell={0.8,1.1,1.2,1.1,0.8}, ramps={0.05,0.05}})
-- the visitor, a dot at the same place in each copy
local d = brush{kind="round", width=3.5, point=0.1}
d:reload(BONE_HI, 0.9); d:touch(GX-20, GY+30, {pressure=0.7})
d:reload(BONE_HI, 0.9); d:touch(GX+6-12.4, GY+18.5, {pressure=0.5})
d:reload(BONE_HI, 0.9); d:touch(GX+10-7.6, GY+11.5, {pressure=0.35})
-- golden-angle studs round the heart
local s = brush{kind="round", width=3, point=0.1}
for i=1,8 do
  local a = i*2.39996
  local r = 86 + 4*math.sqrt(i)
  local x, y = GX+6 + math.cos(a)*r*0.95, GY + math.sin(a)*r
  if x > 92 and x < 330 and y > 110 and y < 405 then
    s:reload(BONE_SH, 0.8); s:touch(x, y, {pressure=0.5})
  end
end
-- plate number under the crown: four marks
for i=0,3 do t:reload(BONE, 0.9); t:touch(186 + i*15, 112 + (i%2)*3, {pressure=0.55}) end

--@ chunk 16
local top = {GX-6, GY-GS/2-9}
local bot = {GX-6, GY+GS/2+9}
local arc = {top, {GX-30, GY-GS/2-30}, {GX-80, GY-GS/2-28}, {GX-112, GY-30}, {GX-116, GY+10}, {GX-104, GY+52}, {GX-75, GY+GS/2+26}, {GX-32, GY+GS/2+30}, bot}
local ab = brush{kind="round", width=4.2, point=0.3}
ab:reload(BONE, 1.0)
ab:stroke(arc, {pressure={0.65,0.65}, ramps={0.03,0.03}})
-- arrowhead where the bridge re-enters: you come back in through the near side
ab:reload(BONE, 1.0)
ab:stroke({{bot[1]-9, bot[2]+9},{bot[1], bot[2]},{bot[1]+3, bot[2]+12}}, {pressure={0.55,0.55}})
-- restate the outer glyph boldly
local b = brush{kind="round", width=4.0, point=0.2}
local h = GS/2
local c = {{GX-h,GY-h},{GX+h,GY-h},{GX+h,GY+h},{GX-h,GY+h}}
for i=1,4 do b:reload(BONE, 1.0); b:stroke({c[i], c[i%4+1]}, {pressure={0.75,0.75}, ramps={0.01,0.01}}) end
-- the lesson sequence below: 1 a glyph, 2 two glyphs bridged, 3 this plate's self-gluing (small), 4 the untranslated blank
local t = brush{kind="round", width=2.0, point=0.3}
local function msq(cx,cy,s) local hh=s/2; local cc={{cx-hh,cy-hh},{cx+hh,cy-hh},{cx+hh,cy+hh},{cx-hh,cy+hh}}
  for i=1,4 do t:reload(BONE_SH, 0.9); t:stroke({cc[i], cc[i%4+1]}, {pressure={0.6,0.6}, ramps={0.01,0.01}}) end end
msq(118, 380, 16)
msq(152, 380, 14); msq(176, 380, 14)
t:reload(BONE_SH, 0.9); t:stroke({{152,372},{164,364},{176,372}}, {pressure={0.5,0.5}})
msq(215, 380, 16); msq(216, 380, 9)
t:reload(BONE_SH, 0.9); t:stroke({{215,371},{200,366},{200,394},{215,389}}, {pressure={0.5,0.5}})
-- the last: a bridge running off into nothing
t:reload(BONE_SH, 0.9); t:stroke({{252,380},{270,372},{292,378},{312,370}}, {pressure={0.5,0.2}})
-- inscription rows under the crown, gaps by the golden ratio
for row=0,2 do
  local x = 130; local y = 135 + row*11; local w = 22
  while x < 300 do
    t:reload(BONE_SH, 0.8)
    t:stroke({{x,y},{x+w,y}}, {pressure={0.45,0.45}, ramps={0.05,0.05}})
    x = x + w + 6; w = (w*0.618 < 5) and 22 or w*0.618 + 3
  end
end

--@ chunk 17
local function rod(pts, w)
  local m = ribbon(pts, w)
  work(m, {hand="detail", tool="round 1.6", pile=BRZ_M, coverage=5, fill=true, clip=true})
  local hi = {}; for i,p in ipairs(pts) do hi[i] = {p[1]+0.6, p[2]-w*0.28} end
  local b = brush{kind="round", width=w*0.35, point=0.5}
  b:reload(BRZ_H, 0.9); b:stroke(hi, {pressure={0.6,0.6}, clip=m})
  local lo = {}; for i,p in ipairs(pts) do lo[i] = {p[1], p[2]+w*0.3} end
  b:reload(BRZ_D, 0.9); b:stroke(lo, {pressure={0.6,0.6}, clip=m})
  return m
end
local function knob(x,y,r)
  local m = ellipse(x,y,r,r)
  work(m, {hand="detail", tool="round 1.4", pile=BRZ_M, coverage=5, fill=true, clip=true})
  local b = brush{kind="round", width=r*0.8, point=0.2}
  b:reload(BRZ_H, 0.9); b:touch(x+r*0.3, y-r*0.35, {pressure=0.5})
  return m
end
ARML = rod({{408,229},{372,214},{340,207}}, 7) + rod({{340,207},{300,228},{262,250}}, 6) + knob(340,207,6) + knob(408,229,7)
FING = rod({{262,250},{250,257},{238,263}}, 3.5) + knob(262,250,4.5)
local b = brush{kind="round", width=3.2, point=0.2}
b:reload(BONE_HI, 0.9); b:touch(237, 263.5, {pressure=0.7})
ARMR = rod({{454,230},{482,252},{500,276}}, 7) + rod({{500,276},{515,292},{527,300}}, 6) + knob(500,276,6) + knob(454,230,7)
-- an open hand: palm and three long fingers fanned toward the room
PALM = ellipse(531,302,7,6)
work(PALM, {hand="detail", tool="round 1.4", pile=BRZ_M, coverage=5, fill=true, clip=true})
local F = rod({{535,298},{545,288},{553,283}}, 3) + rod({{537,302},{549,300},{558,301}}, 3) + rod({{535,307},{545,314},{552,320}}, 3)
DOCENT = DOCENT + ARML + FING + ARMR + PALM + F

--@ chunk 18
FLOOR_D = pile{{"bone black",1},{"burnt sienna",1},{"raw sienna",0.5},{"ultramarine blue",0.2}}
FLOOR_M = pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.45},{"yellow ochre",0.3}}
FLOOR_L = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.4}}
local fl = HALLFLOOR - DOCENT
local pool = poly({{560,471},{930,471},{1010,560},{1010,630},{430,630}})
local core = poly({{600,471},{890,471},{960,630},{530,630}})
work(fl - pool, {hand="body", pile=FLOOR_D, coverage=3.5, fill=true, clip=fl, angle=0})
work(fl * pool - core, {hand="body", pile=FLOOR_M, coverage=3.5, fill=true, clip=fl, angle=0})
work(fl * core, {hand="body", pile=FLOOR_L, coverage=3.5, fill=true, clip=fl, angle=0})
blend(fl * (pool:grow(18) - pool:shrink(18)), {angle=0})
blend(fl * (core:grow(14) - core:shrink(14)), {angle=0})

--@ chunk 19
CHAIR_D = pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.3}}
CHAIR_M = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.7}}
-- plinth along the foot of the wall
local pl = rect(-5,458,566,14) - DOCENT
work(pl, {hand="detail", tool="round 3", pile=FLOOR_D, coverage=4, fill=true, clip=true, angle=0})
local b = brush{kind="round", width=1.8, point=0.4}
b:reload(BRZ_M, 0.8); b:stroke({{0,459},{355,459}}, {pressure={0.5,0.5}, clip=pl})
b:reload(BRZ_L, 0.8); b:stroke({{460,459},{558,459}}, {pressure={0.5,0.5}, clip=pl})
-- two empty chairs in the front row
CHAIRS = nil
for i,cx in ipairs({105, 282}) do
  local top = 512 + (i-1)*6
  local back = ellipse(cx, top+34, 74, 36) + rect(cx-74, top+34, 148, 120)
  work(back, {hand="body", tool="filbert 5", pile=CHAIR_D, coverage=4, fill=true, clip=true, angle=0})
  local rail = back - back:shrink(9)
  work(rail*rect(cx-80, top-4, 160, 60), {hand="detail", tool="round 2.5", pile=CHAIR_M, coverage=4, fill=true, clip=true})
  -- lit top edge of the rail, warmer toward the arch
  local rim = {}
  for k=0,16 do local a = math.pi + k*math.pi/16; rim[#rim+1] = {cx + 72*math.cos(a), top+34 + 34*math.sin(a)} end
  local r = brush{kind="round", width=2.4, point=0.5}
  r:reload(BRZ_L, 0.9); r:stroke(rim, {pressure={0.15,0.7}, clip=back})
  -- bone inlay: studs in a golden spiral on the back
  local s = brush{kind="round", width=2.6, point=0.1}
  for k=1,21 do
    local a = k*2.39996; local rr = 3.6*math.sqrt(k)
    s:reload(BONE_SH, 0.7); s:touch(cx + math.cos(a)*rr, top+60 + math.sin(a)*rr, {pressure=0.45})
  end
  CHAIRS = CHAIRS and (CHAIRS + back) or back
end

--@ chunk 20
local HX, HY = 424, 168
-- petals: 13 round the disc, one missing
work(HEADR, {hand="detail", tool="round 2", pile=WALLDK, coverage=4, fill=true, clip=true})
for k=0,12 do
  if k ~= 9 then
    local a = k*2*math.pi/13 + 0.12
    local px, py = HX + math.cos(a)*25, HY + math.sin(a)*22
    local m = ellipse(px, py, 9, 6.5)
    local lit = math.cos(a) > 0.1
    work(m, {hand="detail", tool="round 1.6", pile=lit and BRZ_L or BRZ_M, coverage=5, fill=true, clip=true})
    local r = brush{kind="round", width=1.6, point=0.5}
    r:reload(lit and BRZ_H or BRZ_L, 0.8)
    r:stroke({{px-4, py-4},{px+3, py-5}}, {pressure={0.4,0.2}, clip=m})
  end
end
-- the bone face with seed-studs and one warm lens
work(HEADD, {hand="detail", tool="round 1.6", pile=BONE, coverage=5, fill=true, clip=true})
local s = brush{kind="round", width=1.8, point=0.1}
for k=1,14 do
  local a = k*2.39996; local rr = 3.6*math.sqrt(k)
  if rr < 14 then s:reload(BONE_SH, 0.7); s:touch(HX + math.cos(a)*rr, HY + math.sin(a)*rr*0.9, {pressure=0.4}) end
end
LENS = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.8}}
local l = brush{kind="round", width=4.5, point=0.1}
l:reload(LENS, 0.9); l:touch(HX-3, HY+1, {pressure=0.8})
l = brush{kind="round", width=2, point=0.1}
l:reload(BONE_HI, 0.9); l:touch(HX-3.5, HY+0.3, {pressure=0.6})
-- lamellae on the bell: grooves with lit lips
local g = brush{kind="round", width=2.2, point=0.4}
local h = brush{kind="round", width=1.5, point=0.6}
for i,x0 in ipairs({408, 420, 432, 444, 455}) do
  local f = (x0-430)/30
  local x1 = 430 + f*68
  g:reload(BRZ_D, 0.85); g:stroke({{x0,325},{x0 + (x1-x0)*0.5, 440},{x1,546}}, {pressure={0.5,0.6}, clip=BELL})
  h:reload(x0 > 440 and BRZ_H or BRZ_L, 0.7); h:stroke({{x0+2.5,328},{x0+2.5 + (x1-x0)*0.5, 440},{x1+3,544}}, {pressure={0.4,0.5}, clip=BELL})
end
-- rim light where the room's light catches the right edge
h:reload(BRZ_H, 0.9); h:stroke({{462,320},{475,385},{490,470},{501,545}}, {pressure={0.6,0.6}, clip=BELL})
h:reload(BRZ_H, 0.9); h:stroke({{440,322},{437,212}}, {pressure={0.5,0.5}, clip=SPINE})
-- a crack, and verdigris weeping from it
g:reload(WALLDK, 0.9); g:stroke({{392,360},{398,378},{393,392},{400,410}}, {pressure={0.5,0.3}, clip=BELL})
local v = brush{kind="filbert", width=4}
v:reload(VERD, 0.25); v:stroke({{398,412},{397,450},{399,480}}, {pressure={0.4,0.05}, clip=BELL})

--@ chunk 21
wait(3*24*60)
local shade = BELL * poly({{380,300},{425,300},{420,560},{340,560}})
work(shade, {hand="body", tool="filbert 4", pile=BRZ_D, coverage=3.5, fill=true, clip=BELL, angle=1.5708})
local deep = BELL * poly({{380,300},{400,300},{380,560},{340,560}})
work(deep, {hand="body", tool="filbert 4", pile=WALLDK, coverage=3, fill=true, clip=BELL, angle=1.5708})
blend(BELL * poly({{392,300},{430,300},{425,560},{368,560}}), {angle=1.5708, tool={kind="badger", width=10}})
local SPSH = SPINE * rect(400,200,26,130)
work(SPSH, {hand="detail", tool="round 2", pile=BRZ_D, coverage=4, fill=true, clip=true})
local l = brush{kind="round", width=5, point=0.1}
l:reload(LENS, 0.9); l:touch(421, 169, {pressure=0.85})

--@ chunk 22
local cx, fy, h = 640, 456, 185
local function P(x,y) return {cx + x*h, fy + y*h} end
-- shadow on the demo-room floor, thrown toward us by the bright back wall
SHAD = pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.5},{"lead white",0.2}}
local sh = poly({P(-0.17,0),P(0.18,0),P(0.26,0.09),P(-0.24,0.09)}, true) * R_FLOOR - FRAME1
work(sh, {hand="detail", tool="round 3", pile=SHAD, coverage=4, fill=true, clip=true})
-- warm rim light round the silhouette: where the figure meets the bright wall behind
local A = FRAME1
RIMF = mask(function(x,y)
  if x < 570 or x > 710 or y < 260 or y > 460 then return 0 end
  if A:at(x,y) < 0.5 then return 0 end
  local e = 1 - math.min(A:at(x-2.4,y), A:at(x+2.4,y), A:at(x,y-2.4))
  return e
end)
work(RIMF, {hand="detail", tool="round 1.4", pile=RIMW, coverage=3, fill=true, clip=true})
-- helmet: a visor ridge and crest seen from behind; back plates; joints
local b = brush{kind="round", width=2, point=0.5}
b:reload(FRAME_D, 0.9); b:stroke({P(-0.07,-0.93),P(0.07,-0.93)}, {pressure={0.6,0.6}, clip=A})
b:reload(RIMW, 0.6); b:stroke({P(0,-0.995),P(0,-0.87)}, {pressure={0.45,0.3}, clip=A})
b:reload(FRAME_D, 0.9); b:stroke({P(-0.29,-0.64),P(-0.21,-0.64)}, {pressure={0.6,0.6}, clip=A})
b:reload(FRAME_D, 0.9); b:stroke({P(0.21,-0.64),P(0.3,-0.65)}, {pressure={0.6,0.6}, clip=A})
b:reload(FRAME_D, 0.9); b:stroke({P(-0.16,-0.17),P(-0.06,-0.17)}, {pressure={0.6,0.6}, clip=A})
b:reload(FRAME_D, 0.9); b:stroke({P(0.06,-0.17),P(0.17,-0.17)}, {pressure={0.6,0.6}, clip=A})
-- the cross on the tabard, restated in bone on the dry cloth
local c = brush{kind="flat", width=0.034*h}
c:reload(BONE, 0.6); c:stroke({P(0,-0.72),P(0,-0.4)}, {pressure={0.65,0.55}, orient="across"})
c:reload(BONE, 0.6); c:stroke({P(-0.075,-0.63),P(0.075,-0.63)}, {pressure={0.65,0.55}, orient="across"})
-- a rifle slung across the back
RIFLE = ribbon({P(-0.27,-0.36), P(0.25,-0.86)}, 7)
work(RIFLE, {hand="detail", tool="round 1.6", pile=FRAME_D, coverage=5, fill=true, clip=true})
b:reload(RIMW, 0.6); b:stroke({P(-0.24,-0.4), P(0.22,-0.85)}, {pressure={0.3,0.3}, clip=RIFLE})

--@ chunk 23
local cx, fy, h = 640, 456, 185
local function P(x,y) return {cx + x*h, fy + y*h} end
local function pl(t) local o={} for i,v in ipairs(t) do o[i]=P(v[1],v[2]) end return poly(o, false) end
local tab = pl({{-0.15,-0.79},{0.15,-0.79},{0.165,-0.27},{0.06,-0.23},{-0.05,-0.27},{-0.16,-0.24}})
local R = RIFLE:grow(1.5)
work(R*tab, {hand="detail", tool="round 1.6", pile=TABARD, coverage=6, fill=true, clip=true})
work(R*(FRAME1 - tab), {hand="detail", tool="round 1.6", pile=FRAME_M, coverage=6, fill=true, clip=true})
work(R - FRAME1 - FRAME1:grow(3), {hand="detail", tool="round 1.6", pile=RBACK, coverage=6, fill=true, clip=true})
local c = brush{kind="flat", width=0.034*h}
c:reload(BONE, 0.7); c:stroke({P(0,-0.72),P(0,-0.4)}, {pressure={0.65,0.55}, orient="across"})
c:reload(BONE, 0.7); c:stroke({P(-0.075,-0.63),P(0.075,-0.63)}, {pressure={0.65,0.55}, orient="across"})

--@ chunk 24
wait(5*24*60)
print(drying(640,350), drying(600,340))
local cx, fy, h = 640, 456, 185
local function P(x,y) return {cx + x*h, fy + y*h} end
local function pl(t) local o={} for i,v in ipairs(t) do o[i]=P(v[1],v[2]) end return poly(o, false) end
TAB1 = pl({{-0.15,-0.79},{0.15,-0.79},{0.165,-0.27},{0.06,-0.23},{-0.05,-0.27},{-0.16,-0.24}})
work(TAB1, {hand="detail", tool="round 2", pile=TABARD, coverage=6, fill=true, clip=true, angle=1.5708})
local R = RIFLE:grow(2.5)
work(R*(FRAME1 - TAB1), {hand="detail", tool="round 1.6", pile=FRAME_D, coverage=6, fill=true, clip=true})
work((R - FRAME1:grow(2.5))*R_LEFT, {hand="detail", tool="round 1.6", pile=RSIDE, coverage=6, fill=true, clip=true})
work((R - FRAME1:grow(2.5))*R_BACK, {hand="detail", tool="round 1.6", pile=RBACK, coverage=6, fill=true, clip=true})

--@ chunk 25
wait(5*24*60) print(drying(640,350))

--@ chunk 26
wait(4*24*60)
print(drying(640,350))
local cx, fy, h = 640, 456, 185
local function P(x,y) return {cx + x*h, fy + y*h} end
TAB_D = pile{{"Mars red",0.6},{"bone black",1.2},{"burnt sienna",0.6}}
TAB_L = pile{{"Mars red",1},{"red earth",0.6},{"lead white",0.25},{"yellow ochre",0.2}}
local f = brush{kind="round", width=3, point=0.6}
for _,x in ipairs({-0.09, 0.04, 0.11}) do
  f:reload(TAB_D, 0.6); f:stroke({P(x,-0.7),P(x+0.01,-0.45),P(x-0.005,-0.27)}, {pressure={0.1,0.6}, clip=TAB1})
end
f:reload(TAB_L, 0.5); f:stroke({P(-0.14,-0.76),P(-0.145,-0.5),P(-0.15,-0.26)}, {pressure={0.4,0.4}, clip=TAB1})
local c = brush{kind="flat", width=0.036*h}
c:reload(BONE, 0.6); c:stroke({P(0.005,-0.73),P(0.005,-0.41)}, {pressure={0.7,0.6}, orient="across", clip=TAB1})
c:reload(BONE, 0.6); c:stroke({P(-0.075,-0.635),P(0.08,-0.635)}, {pressure={0.7,0.6}, orient="across", clip=TAB1})
-- a worn edge: the cross scuffed
local s = brush{kind="round", width=1.4, point=0.6}
s:reload(TABARD, 0.4); s:stroke({P(-0.03,-0.56),P(0.03,-0.5)}, {pressure={0.4,0.2}})

--@ chunk 27
-- the docent's shadow on the hall floor, thrown left by the light from the arch
local sh = poly({{358,548},{500,548},{420,575},{250,600},{150,606},{210,585}}, true) * HALLFLOOR - CHAIRS - DOCENT
work(sh, {hand="body", tool="filbert 5", pile=WALLDK, coverage=3, fill=true, clip=true, angle=0.15})
-- the threshold carving over the arch: the join, written before you walk through it
local KX, KY, KS = 745, 52, 34
local b = brush{kind="round", width=2.6, point=0.3}
local function sq(cx,cy,s,w) local h=s/2; local c={{cx-h,cy-h},{cx+h,cy-h},{cx+h,cy+h},{cx-h,cy+h}}
  local br = brush{kind="round", width=w, point=0.3}
  for i=1,4 do br:reload(BONE, 0.9); br:stroke({c[i],c[i%4+1]}, {pressure={0.7,0.7}, ramps={0.01,0.01}}) end end
sq(KX, KY, KS, 2.6); sq(KX+1.5, KY, KS*0.618, 2); sq(KX+2.5, KY, KS*0.382, 1.5)
b:reload(BONE, 0.9)
b:stroke({{KX-2,KY-KS/2-3},{KX-14,KY-KS/2-10},{KX-30,KY-6},{KX-30,KY+6},{KX-14,KY+KS/2+10},{KX-2,KY+KS/2+3}}, {pressure={0.55,0.55}})
-- frieze of bone studs along the wall head, placed by the golden angle along a band
local s = brush{kind="round", width=2.4, point=0.1}
local x = 4
local k = 0
while x < 1000 do
  k = k + 1
  local y = 22 + 5*math.sin(k*2.39996)
  local inside = ARCH:grow(40):at(x,y) > 0.5 or (x > KX-40 and x < KX+30)
  if not inside then s:reload(BONE_SH, 0.7); s:touch(x, y, {pressure=0.45}) end
  x = x + 9 + 5*((k*0.618) % 1)
end
local r = brush{kind="round", width=2, point=0.3}
r:reload(BRZ_M, 0.8); r:stroke({{0,36},{1000,36}}, {pressure={0.5,0.5}, ramps={0.01,0.01}})

--@ chunk 28
-- the visitor marked in the plate: a red tick at the same spot in each nested copy
local d = brush{kind="round", width=4, point=0.1}
local sizes = {GS, GS*0.618, GS*0.382, GS*0.236}
local offs = {0, 6, 10, 12.5}
for i=1,4 do
  local s = sizes[i]
  local x = GX + offs[i] - s*0.18
  local y = GY + s*0.30
  d = brush{kind="round", width=math.max(1.6, 5.5*s/GS), point=0.1}
  d:reload(TAB_L, 0.9); d:touch(x, y, {pressure=0.8})
end
-- bronze moulding round the great arch
local AR = ARCH:grow(9) - ARCH
work(AR, {hand="detail", tool="round 2.5", pile=BRZ_M, coverage=4, fill=true, clip=true})
local inner = ARCH:grow(3) - ARCH
work(inner, {hand="detail", tool="round 1.6", pile=BRZ_H, coverage=4, fill=true, clip=true})
-- the room's address inlaid in its floor: a ring of glyphs, in perspective
local fx, fy = 745, 432
local b = brush{kind="round", width=1.6, point=0.4}
local ring = {}
for i=0,40 do local a = i/40*2*math.pi; ring[#ring+1] = {fx + 70*math.cos(a), fy + 13*math.sin(a)} end
b:reload(BONE, 0.8); b:stroke(ring, {pressure={0.45,0.45}, clip=R_FLOOR - FRAME1:grow(2)})
for k=0,4 do
  local a = k*2.39996
  local x, y = fx + 50*math.cos(a), fy + 9.5*math.sin(a)
  local w, h = 9, 3
  b:reload(BONE, 0.8)
  b:stroke({{x-w,y-h},{x+w,y-h},{x+w,y+h},{x-w,y+h},{x-w,y-h}}, {pressure={0.4,0.4}, ramps={0.01,0.01}, clip=R_FLOOR - FRAME1:grow(2)})
end
b:reload(BONE, 0.8); b:stroke({{fx-12,fy-3},{fx+12,fy-3},{fx+12,fy+3},{fx-12,fy+3},{fx-12,fy-3}}, {pressure={0.45,0.45}, clip=R_FLOOR - FRAME1:grow(2)})
-- chairs: seat ledge catching the light, arm curve
for i,cx in ipairs({105, 282}) do
  local top = 512 + (i-1)*6
  local r = brush{kind="round", width=3, point=0.4}
  r:reload(CHAIR_M, 0.9); r:stroke({{cx-74, top+92},{cx+74, top+92}}, {pressure={0.7,0.7}, clip=CHAIRS})
  r:reload(BRZ_L, 0.8); r:stroke({{cx-60, top+89},{cx+74, top+89}}, {pressure={0.1,0.5}, clip=CHAIRS})
end

--@ chunk 29
WALLMID = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}}
local base = (HALLWALL - PLATE - DOCENT:grow(2) - ARCH:grow(9)) * rect(-5,40,1010,420)
local b1 = ARCH:grow(32) * base
local b2 = (ARCH:grow(60) - ARCH:grow(32)) * base
local b3 = (ARCH:grow(110) - ARCH:grow(60)) * base
work(b1, {hand="body", tool="filbert 6", pile=WALLGL, coverage=3.5, fill=true, clip=true, angle=1.5708})
work(b2, {hand="body", tool="filbert 6", pile=WALLMID, coverage=3.5, fill=true, clip=true, angle=1.5708})
work(b3, {hand="body", tool="filbert 6", pile=WALLDK, coverage=3.5, fill=true, clip=true, angle=1.5708})
blend((ARCH:grow(44) - ARCH:grow(20)) * base, {angle=1.5708, tool={kind="badger", width=12}})
blend((ARCH:grow(74) - ARCH:grow(46)) * base, {angle=1.5708, tool={kind="badger", width=12}})
blend((ARCH:grow(124) - ARCH:grow(96)) * base, {angle=1.5708, tool={kind="badger", width=12}})

--@ chunk 30
wait(6*24*60)
print(drying(745,60), drying(560,150))
local KX, KY, KS = 745, 50, 30
-- a small bronze cartouche to carry it
local cart = ellipse(KX-8, KY, 40, 24)
work(cart, {hand="detail", tool="round 2", pile=BRZ_D, coverage=5, fill=true, clip=true})
local r = brush{kind="round", width=2, point=0.3}
local ring = {}
for i=0,40 do local a=i/40*2*math.pi; ring[#ring+1] = {KX-8+40*math.cos(a), KY+24*math.sin(a)} end
r:reload(BRZ_L, 0.9); r:stroke(ring, {pressure={0.55,0.55}})
local function sq(cx,cy,s,w) local h=s/2; local c={{cx-h,cy-h},{cx+h,cy-h},{cx+h,cy+h},{cx-h,cy+h}}
  local br = brush{kind="round", width=w, point=0.3}
  for i=1,4 do br:reload(BONE, 0.9); br:stroke({c[i],c[i%4+1]}, {pressure={0.7,0.7}, ramps={0.01,0.01}}) end end
sq(KX, KY, KS, 2.4); sq(KX+1.5, KY, KS*0.618, 1.9); sq(KX+2.5, KY, KS*0.382, 1.5)
local b = brush{kind="round", width=2.4, point=0.3}
b:reload(BONE, 0.9)
b:stroke({{KX-2,KY-KS/2-2},{KX-14,KY-KS/2-6},{KX-28,KY-6},{KX-28,KY+6},{KX-14,KY+KS/2+6},{KX-2,KY+KS/2+2}}, {pressure={0.5,0.5}})
r:reload(BRZ_M, 0.8); r:stroke({{560,36},{700,36}}, {pressure={0.5,0.5}, ramps={0.01,0.01}})
r:reload(BRZ_M, 0.8); r:stroke({{790,36},{1000,36}}, {pressure={0.5,0.5}, ramps={0.01,0.01}})

--@ chunk 31
wait(3*24*60) print(drying(745,60))

--@ chunk 32
-- (1) the glow round the arch: concentric bands, strokes running along them
local CX, CY = 745, 215
local function tang(x,y)
  if y < CY then return math.atan(y-CY, x-CX) + math.pi/2 end
  return 1.5708
end
G1 = pile{{"raw sienna",1},{"yellow ochre",0.7},{"burnt sienna",0.6},{"bone black",0.3}}
G2 = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.45},{"yellow ochre",0.4}}
G3 = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.65},{"yellow ochre",0.15}}
G4 = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.9},{"ultramarine blue",0.1}}
G5 = WALLDK
local base = (HALLWALL - PLATE - DOCENT:grow(2) - ARCH:grow(9)) * rect(-5,72,1010,388)
local radii = {9, 30, 55, 82, 112, 150}
local P = {G1,G2,G3,G4,G5}
for i=1,5 do
  local band = (ARCH:grow(radii[i+1]) - ARCH:grow(radii[i])) * base
  work(band, {hand="body", tool="filbert 6", pile=P[i], coverage=4, fill=true, clip=true, angle=tang, angle_jitter=0.05, length={30,70}})
end
for i=2,5 do
  local seam = (ARCH:grow(radii[i]+9) - ARCH:grow(radii[i]-9)) * base
  blend(seam, {angle=tang, tool={kind="badger", width=12}})
end

--@ chunk 33
local CX, CY = 745, 215
local function tang(x,y) if y < CY then return math.atan(y-CY, x-CX) + math.pi/2 end return 1.5708 end
local base = (HALLWALL - ARCH:grow(9)) * rect(-5,39,1010,36) - ellipse(737,50,42,26)
local radii = {9, 30, 55, 82, 112, 150}
local P = {G1,G2,G3,G4,G5}
for i=1,5 do
  local band = (ARCH:grow(radii[i+1]) - ARCH:grow(radii[i])) * base
  if band:area() > 1 then
    work(band, {hand="body", tool="filbert 5", pile=P[i], coverage=4, fill=true, clip=true, angle=tang, angle_jitter=0.05, length={20,50}})
  end
end
local wide = (ARCH:grow(150) - ARCH:grow(9)) * rect(-5,39,1010,46) - ellipse(737,50,42,26) - PLATE - DOCENT:grow(2)
blend(wide * rect(-5,62,1010,20), {angle=0, tool={kind="badger", width=10}})
for i=2,5 do
  local seam = (ARCH:grow(radii[i]+9) - ARCH:grow(radii[i]-9)) * base
  blend(seam, {angle=tang, tool={kind="badger", width=10}})
end

--@ chunk 34
-- (2) a clean pool of light on the hall floor
P1 = pile{{"yellow ochre",1},{"raw sienna",0.8},{"lead white",0.7},{"burnt sienna",0.3}}
P2 = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.5},{"lead white",0.3}}
P3 = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.3},{"yellow ochre",0.2}}
P4 = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.6}}
local fl = (HALLFLOOR * rect(-5,478,1010,160)) - DOCENT:grow(1) - CHAIRS:grow(1)
local function trap(k)
  -- trapezoid spreading from the sill, widened by k units on each side
  return poly({{560-k*0.25,476},{930+k*0.25,476},{1060+k,640},{450-k,640}})
end
local zones = {trap(-60), trap(0), trap(70), trap(150)}
local Pz = {P1,P2,P3,P4}
work(fl - zones[4], {hand="body", tool="filbert 6", pile=FLOOR_D, coverage=4, fill=true, clip=true, angle=0, length={30,70}})
for i=4,1,-1 do
  local z = zones[i] - (zones[i-1] or poly({{0,0},{1,0},{1,1}}))
  work(fl * z, {hand="body", tool="filbert 6", pile=Pz[i], coverage=4, fill=true, clip=true, angle=0, length={30,70}})
end
for i=1,4 do
  blend(fl * (zones[i]:grow(10) - zones[i]:shrink(10)), {angle=0, tool={kind="badger", width=12}})
end
-- the sill's own reflection: a soft lighter strip just in front of it

--@ chunk 35
-- (3) the docent's bell as handmade bronze: 9 lamellae, each its own strip, lit from the arch (right)
B_RAMP = {
  pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.4}},
  pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.6}},
  pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.45}},
  pile{{"raw sienna",1},{"burnt sienna",0.7},{"bone black",0.25},{"yellow ochre",0.2}},
  pile{{"raw sienna",1.2},{"yellow ochre",0.8},{"burnt sienna",0.5},{"bone black",0.15}},
  pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.3},{"burnt sienna",0.2}},
  pile{{"yellow ochre",1.2},{"cadmium yellow",0.2},{"lead white",0.8},{"raw sienna",0.3}},
}
local topL, topR, botL, botR = 384, 476, 356, 502
local N = 9
local ramp = {1,1,2,2,3,4,5,6,4}
for i=1,N do
  local u0, u1 = (i-1)/N, i/N
  local strip = poly({{lerp(topL,topR,u0)-0.5,300},{lerp(topL,topR,u1)+0.5,300},{lerp(botL,botR,u1)+0.5,560},{lerp(botL,botR,u0)-0.5,560}}) * BELL
  local p = B_RAMP[ramp[i]]
  local ang = math.atan(260, lerp(botL,botR,(u0+u1)/2) - lerp(topL,topR,(u0+u1)/2))
  work(strip, {hand="detail", tool="round 3", pile=p, coverage=5, fill=true, clip=true, angle=ang})
  -- each lamella: a lit lip on its right edge, a dark groove on its left
  local g = brush{kind="round", width=1.8, point=0.5}
  g:reload(B_RAMP[1], 0.85)
  g:stroke({{lerp(topL,topR,u0)+0.8,312},{lerp(botL,botR,u0)+0.8,552}}, {pressure={0.5,0.6}, clip=BELL})
  if ramp[i] >= 3 then
    g:reload(B_RAMP[math.min(7, ramp[i]+2)], 0.8)
    g:stroke({{lerp(topL,topR,u1)-1.5,316},{lerp(botL,botR,u1)-1.8,548}}, {pressure={0.35,0.45}, clip=BELL})
  end
end
-- the hem: a bone band with golden-angle studs, and the top collar
BONE_BAND = poly({{356,532},{502,532},{503,546},{355,546}}) * BELL
work(BONE_BAND, {hand="detail", tool="round 2", pile=BONE_SH, coverage=5, fill=true, clip=true})
work(BONE_BAND*rect(440,520,70,30), {hand="detail", tool="round 2", pile=BONE, coverage=5, fill=true, clip=true})
local s = brush{kind="round", width=2.4, point=0.1}
local x = 360; local k = 0
while x < 500 do k=k+1; s:reload(B_RAMP[2], 0.7); s:touch(x, 539, {pressure=0.4}); x = x + 7 + 6*((k*0.618)%1) end
COLLAR_D = poly({{386,300},{474,300},{477,318},{383,318}}, true)
work(COLLAR_D, {hand="detail", tool="round 2", pile=B_RAMP[3], coverage=5, fill=true, clip=true})
work(COLLAR_D*rect(440,290,50,40), {hand="detail", tool="round 2", pile=B_RAMP[6], coverage=5, fill=true, clip=true})
-- worn sheen: a soft warm specular down the lit side, broken
local sh = brush{kind="filbert", width=5}
sh:reload(B_RAMP[7], 0.35)
sh:stroke({{462,330},{470,400},{478,460},{486,520}}, {pressure={0.4,0.15}, clip=BELL})
-- crack + verdigris again on the shadow side
local g = brush{kind="round", width=1.6, point=0.6}
g:reload(B_RAMP[1], 0.9); g:stroke({{392,360},{398,378},{393,392},{400,410}}, {pressure={0.5,0.3}, clip=BELL})
local v = brush{kind="filbert", width=4}
v:reload(VERD, 0.3); v:stroke({{398,412},{397,450},{399,480}}, {pressure={0.4,0.05}, clip=BELL})
-- the spine: round in section
work(SPINE, {hand="detail", tool="round 2", pile=B_RAMP[2], coverage=5, fill=true, clip=true, angle=1.5708})
work(SPINE*rect(430,200,20,130), {hand="detail", tool="round 2", pile=B_RAMP[5], coverage=5, fill=true, clip=true, angle=1.5708})
g:reload(B_RAMP[7], 0.8); g:stroke({{437.5,214},{439.5,318}}, {pressure={0.4,0.4}, clip=SPINE})
for _,y in ipairs({236, 262, 288}) do
  g:reload(BONE, 0.8); g:stroke({{423,y},{440,y}}, {pressure={0.5,0.5}, clip=SPINE})
end

--@ chunk 36
-- (4) the head: lit rims on the arch side of the petals, a darker shadow side
for k=0,12 do
  if k ~= 9 then
    local a = k*2*math.pi/13 + 0.12
    local px, py = 424 + math.cos(a)*25, 168 + math.sin(a)*22
    local r = brush{kind="round", width=1.5, point=0.6}
    if math.cos(a) > -0.2 then
      r:reload(B_RAMP[7], 0.8); r:stroke({{px+2, py-5},{px+7, py-1},{px+6, py+3}}, {pressure={0.4,0.25}})
    else
      r:reload(B_RAMP[1], 0.8); r:stroke({{px-7, py-2},{px-4, py+5}}, {pressure={0.5,0.3}})
    end
  end
end
-- the empty petal socket: a dark hole with a broken stub
local a = 9*2*math.pi/13 + 0.12
local px, py = 424 + math.cos(a)*25, 168 + math.sin(a)*22
local h = brush{kind="round", width=3, point=0.2}
h:reload(B_RAMP[1], 0.9); h:touch(px*0.75+424*0.25, py*0.75+168*0.25, {pressure=0.7})

--@ chunk 37
-- (5) the frame: form within the silhouette, backlit by the bright room
local cx, fy, h = 640, 456, 185
local function P(x,y) return {cx + x*h, fy + y*h} end
FR_L = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.55},{"yellow ochre",0.25}}
FR_W = pile{{"bone black",1},{"burnt sienna",0.6},{"raw sienna",0.6},{"lead white",0.25}}
local body = FRAME1 - TAB1
local b = brush{kind="round", width=5, point=0.4}
local function limb(x0,x1,y0,y1)
  -- side planes: light on both outer flanks (light wraps from the room), dark core, warm floor bounce low
  local w = x1 - x0
  b = brush{kind="round", width=math.max(3, w*h*0.28), point=0.3}
  b:reload(FR_L, 0.7); b:stroke({P(x0+w*0.2, y0+0.02), P(x0+w*0.2, y1-0.02)}, {pressure={0.5,0.6}, clip=body})
  b:reload(FR_L, 0.6); b:stroke({P(x1-w*0.18, y0+0.02), P(x1-w*0.18, y1-0.02)}, {pressure={0.4,0.55}, clip=body})
  b:reload(FRAME_D, 0.8); b:stroke({P(x0+w*0.55, y0+0.02), P(x0+w*0.55, y1-0.02)}, {pressure={0.5,0.6}, clip=body})
end
limb(-0.165,-0.035,-0.42,-0.01)
limb(0.035,0.175,-0.42,-0.01)
limb(-0.305,-0.195,-0.78,-0.49)
limb(0.2,0.315,-0.78,-0.49)
-- knee and elbow joints
local j = brush{kind="round", width=2, point=0.4}
for _,q in ipairs({{-0.17,-0.03,-0.22},{0.04,0.18,-0.22},{-0.31,-0.19,-0.62},{0.2,0.32,-0.62}}) do
  j:reload(FRAME_D, 0.9); j:stroke({P(q[1],q[3]),P(q[2],q[3])}, {pressure={0.6,0.6}, clip=body})
  j:reload(FR_L, 0.7); j:stroke({P(q[1],q[3]-0.012),P(q[2],q[3]-0.012)}, {pressure={0.4,0.4}, clip=body})
end
-- warm bounce from the lit floor on the shins
for _,q in ipairs({{-0.165,-0.035},{0.035,0.175}}) do
  local bb = brush{kind="round", width=6, point=0.3}
  bb:reload(FR_W, 0.5); bb:stroke({P((q[1]+q[2])/2,-0.12),P((q[1]+q[2])/2,-0.02)}, {pressure={0.3,0.6}, clip=body})
end
-- pauldrons and helmet: lit tops
local t = brush{kind="round", width=3, point=0.4}
for _,sx in ipairs({-0.21, 0.21}) do
  local arc = {}
  for i=0,10 do local a = math.pi + i*math.pi/10; arc[#arc+1] = P(sx + 0.085*math.cos(a), -0.8 + 0.05*math.sin(a)) end
  t:reload(FR_L, 0.8); t:stroke(arc, {pressure={0.3,0.5}, clip=body})
end
local arc = {}
for i=0,10 do local a = math.pi*1.1 + i*math.pi*0.8/10; arc[#arc+1] = P(0.06*math.cos(a), -0.925 + 0.055*math.sin(a)) end
t:reload(FR_L, 0.8); t:stroke(arc, {pressure={0.3,0.45}, clip=body})
-- rim, restated as a bright hairline only where he meets the bright wall (upper body and flanks)
local A = FRAME1
RIM2 = mask(function(x,y)
  if x < 570 or x > 710 or y < 260 or y > 420 then return 0 end
  if A:at(x,y) < 0.5 then return 0 end
  return 1 - math.min(A:at(x-1.4,y), A:at(x+1.4,y), A:at(x,y-1.4))
end)
RIMH = pile{{"lead white",3},{"yellow ochre",0.5},{"cadmium yellow",0.2}}
work(RIM2, {hand="detail", tool="round 1", pile=RIMH, coverage=3, fill=true, clip=true})

--@ chunk 38
-- (6) plate: the turned inset. Cover the two inner squares, then carve them turned.
local inner = rect(GX+6-34, GY-34, 68, 68)
work(inner, {hand="detail", tool="round 2.5", pile=PLATE_D, coverage=5, fill=true, clip=true, angle=1.5708})

--@ chunk 39
wait(6*24*60) print(drying(215,268), drying(430,310), drying(640,330))

--@ chunk 40
wait(5*24*60) print(drying(215,268), drying(430,310))

--@ chunk 41
-- (7) carve the turned insets in the sunken well, and give every cut line depth
CUT_D = pile{{"bone black",1.4},{"burnt sienna",0.8},{"raw sienna",0.3}}
CUT_L = pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.3}}
local function rsq(cx,cy,s,th)
  local h = s/2; local pts = {}
  for _,c in ipairs({{-h,-h},{h,-h},{h,h},{-h,h},{-h,-h}}) do
    pts[#pts+1] = {cx + c[1]*math.cos(th) - c[2]*math.sin(th), cy + c[1]*math.sin(th) + c[2]*math.cos(th)}
  end
  return pts
end
local function carve(pts, w, p)
  local function off(dx,dy) local o={} for i,q in ipairs(pts) do o[i]={q[1]+dx,q[2]+dy} end return o end
  local d = brush{kind="round", width=w*0.8, point=0.3}
  d:reload(CUT_D, 0.9); d:stroke(off(-w*0.55,-w*0.55), {pressure={0.6,0.6}, ramps={0.01,0.01}})
  local b = brush{kind="round", width=w, point=0.3}
  b:reload(p or BONE, 0.95); b:stroke(pts, {pressure={0.7,0.7}, ramps={0.01,0.01}})
  local l = brush{kind="round", width=math.max(1, w*0.35), point=0.6}
  l:reload(BONE_HI, 0.9); l:stroke(off(w*0.3,w*0.3), {pressure={0.45,0.45}, ramps={0.01,0.01}})
end
-- the sunken well's edges: dark top-left, lit bottom-right
local x0,y0,x1,y1 = GX+6-34, GY-34, GX+6+34, GY+34
local e = brush{kind="round", width=2.4, point=0.3}
e:reload(CUT_D, 0.9); e:stroke({{x0,y1},{x0,y0},{x1,y0}}, {pressure={0.7,0.7}, ramps={0.01,0.01}})
e:reload(BRZ_L, 0.9); e:stroke({{x1,y0},{x1,y1},{x0,y1}}, {pressure={0.6,0.6}, ramps={0.01,0.01}})
TH = 0.38
carve(rsq(GX+10, GY, GS*0.382, TH), 2.4)
carve(rsq(GX+12.5, GY, GS*0.236, 2*TH), 1.9)
carve(rsq(GX+13.5, GY, GS*0.146, 3*TH), 1.5, BONE_SH)
local dd = brush{kind="round", width=2.2, point=0.1}
dd:reload(BONE_HI, 0.9); dd:touch(GX+14, GY, {pressure=0.6})
-- the visitor ticks, turned with each copy
local function tick(cx,cy,s,th,w)
  local lx, ly = -0.18*s, 0.30*s
  local x = cx + lx*math.cos(th) - ly*math.sin(th)
  local y = cy + lx*math.sin(th) + ly*math.cos(th)
  local d = brush{kind="round", width=w, point=0.1}
  d:reload(TAB_L, 0.9); d:touch(x, y, {pressure=0.8})
end
tick(GX+10, GY, GS*0.382, TH, 3.2)
tick(GX+12.5, GY, GS*0.236, 2*TH, 2.4)
-- restate the outer glyph and the 0.618 square as cut lines
carve(rsq(GX, GY, GS, 0), 3.6)
carve(rsq(GX+6, GY, GS*0.618, 0), 2.6)
-- the bridge, cut deep
local top = {GX-6, GY-GS/2-9}
local bot = {GX-6, GY+GS/2+9}
carve({top, {GX-30, GY-GS/2-30}, {GX-80, GY-GS/2-28}, {GX-112, GY-30}, {GX-116, GY+10}, {GX-104, GY+52}, {GX-75, GY+GS/2+26}, {GX-32, GY+GS/2+30}, bot}, 3.8)

--@ chunk 42
-- (8) the pointer: a long bronze finger whose bone tip touches the corner of the turned inset
local tipx, tipy = 244.2, 267.2
local m = ribbon({{262,250},{252,259},{tipx+2,tipy-2}}, 3.2)
work(m, {hand="detail", tool="round 1.2", pile=B_RAMP[4], coverage=6, fill=true, clip=true})
local r = brush{kind="round", width=1.2, point=0.6}
r:reload(B_RAMP[7], 0.9); r:stroke({{262,248.6},{252,257.6},{tipx+2.4,tipy-3.2}}, {pressure={0.4,0.4}, clip=m})
local d = brush{kind="round", width=2.6, point=0.1}
d:reload(BONE_HI, 0.95); d:touch(tipx+0.6, tipy-0.6, {pressure=0.7})
-- the touch: a small bright contact on the cut corner
local g = brush{kind="round", width=1.2, point=0.9}
for _,a in ipairs({0.6, 2.2, 3.6, 5.0}) do
  g:reload(BONE_HI, 0.8); g:stroke({{tipx+math.cos(a)*2.5, tipy+math.sin(a)*2.5},{tipx+math.cos(a)*7, tipy+math.sin(a)*7}}, {pressure={0.4,0.0}})
end

--@ chunk 43
wait(10*24*60)
print(drying(215,268))
local field = PLATE_IN - DOCENT:grow(1)
work(field, {hand="body", tool="filbert 6", pile=PLATE_D, coverage=4, fill=true, clip=true, angle=1.5708})
work(field*ellipse(300,260,90,200), {hand="body", tool="filbert 6", pile=PLATE_D2, coverage=3, fill=true, clip=field, angle=1.5708})
blend(field*(ellipse(300,260,110,220) - ellipse(300,260,70,180)), {angle=1.5708})

--@ chunk 44
wait(10*24*60) print(drying(215,268), drying(300,268))

--@ chunk 45
local function seg(a, b, w, p)
  local d = brush{kind="round", width=w*0.7, point=0.3}
  d:reload(CUT_D, 0.9); d:stroke({{a[1]-w*0.4,a[2]-w*0.4},{b[1]-w*0.4,b[2]-w*0.4}}, {pressure={0.6,0.6}, ramps={0.01,0.01}})
  local bb = brush{kind="round", width=w, point=0.3}
  bb:reload(p or BONE, 0.95); bb:stroke({a,b}, {pressure={0.7,0.7}, ramps={0.01,0.01}})
  local l = brush{kind="round", width=math.max(0.9, w*0.3), point=0.6}
  l:reload(BONE_HI, 0.9); l:stroke({{a[1]+w*0.25,a[2]+w*0.25},{b[1]+w*0.25,b[2]+w*0.25}}, {pressure={0.45,0.45}, ramps={0.01,0.01}})
end
function rsqc(cx,cy,s,th,w,p)
  local h = s/2; local pts = {}
  for _,c in ipairs({{-h,-h},{h,-h},{h,h},{-h,h}}) do
    pts[#pts+1] = {cx + c[1]*math.cos(th) - c[2]*math.sin(th), cy + c[1]*math.sin(th) + c[2]*math.cos(th)}
  end
  for i=1,4 do seg(pts[i], pts[i%4+1], w, p) end
end
SEG = seg
-- room-glyph and its displaced upright inset
rsqc(GX, GY, GS, 0, 3.6)
rsqc(GX+6, GY, GS*0.618, 0, 2.6)
-- turned insets
rsqc(GX+10, GY, GS*0.382, TH, 2.2)
rsqc(GX+12.5, GY, GS*0.236, 2*TH, 1.8)
rsqc(GX+13.5, GY, GS*0.146, 3*TH, 1.4, BONE_SH)
local dd = brush{kind="round", width=2.2, point=0.1}
dd:reload(BONE_HI, 0.9); dd:touch(GX+14, GY, {pressure=0.6})
-- notches + chevrons
for _,e in ipairs({{GY-GS/2, -1},{GY+GS/2, 1}}) do
  for _,dx in ipairs({-6, 4}) do seg({GX+dx, e[1]}, {GX+dx, e[1]+e[2]*9}, 2.2) end
  seg({GX+10, e[1]+e[2]*4}, {GX+15, e[1]+e[2]*9}, 1.8); seg({GX+15, e[1]+e[2]*9}, {GX+20, e[1]+e[2]*4}, 1.8)
end
-- the bridge as one cut curve
local top = {GX-6, GY-GS/2-9}
local bot = {GX-6, GY+GS/2+9}
local arc = {top, {GX-30, GY-GS/2-30}, {GX-80, GY-GS/2-28}, {GX-112, GY-30}, {GX-116, GY+10}, {GX-104, GY+52}, {GX-75, GY+GS/2+26}, {GX-32, GY+GS/2+30}, bot}
local function off(pts,dx,dy) local o={} for i,q in ipairs(pts) do o[i]={q[1]+dx,q[2]+dy} end return o end
local d = brush{kind="round", width=2.8, point=0.3}
d:reload(CUT_D, 0.9); d:stroke(off(arc,-1.6,-1.6), {pressure={0.6,0.6}, ramps={0.02,0.02}})
local b = brush{kind="round", width=4, point=0.3}
b:reload(BONE, 1.0); b:stroke(arc, {pressure={0.7,0.7}, ramps={0.02,0.02}})
local l = brush{kind="round", width=1.3, point=0.6}
l:reload(BONE_HI, 0.9); l:stroke(off(arc,1,1), {pressure={0.45,0.45}, ramps={0.02,0.02}})
seg({bot[1]-9, bot[2]+9}, bot, 2.4); seg(bot, {bot[1]+3, bot[2]+12}, 2.4)
-- visitor ticks
local function tick(cx,cy,s,th,w)
  local lx, ly = -0.18*s, 0.30*s
  local x = cx + lx*math.cos(th) - ly*math.sin(th)
  local y = cy + lx*math.sin(th) + ly*math.cos(th)
  local t = brush{kind="round", width=w, point=0.1}
  t:reload(TAB_L, 0.95); t:touch(x, y, {pressure=0.85})
end
tick(GX, GY, GS, 0, 5.5); tick(GX+6, GY, GS*0.618, 0, 4.2)
tick(GX+10, GY, GS*0.382, TH, 3.2); tick(GX+12.5, GY, GS*0.236, 2*TH, 2.4)

--@ chunk 46
-- inscription rows, plate number, studs, lesson row: re-cut
local t = brush{kind="round", width=2.0, point=0.3}
for row=0,2 do
  local x = 130; local y = 135 + row*11; local w = 22
  while x < 300 do
    SEG({x,y},{x+w,y}, 2.0, BONE_SH)
    x = x + w + 6; w = (w*0.618 < 5) and 22 or w*0.618 + 3
  end
end
for i=0,3 do t:reload(BONE, 0.9); t:touch(186 + i*15, 112 + (i%2)*3, {pressure=0.55}) end
local function msq(cx,cy,s) local h=s/2; local c={{cx-h,cy-h},{cx+h,cy-h},{cx+h,cy+h},{cx-h,cy+h}}
  for i=1,4 do SEG(c[i], c[i%4+1], 2.0, BONE_SH) end end
msq(118, 380, 16)
msq(152, 380, 14); msq(176, 380, 14)
SEG({152,372},{164,364},1.8,BONE_SH); SEG({164,364},{176,372},1.8,BONE_SH)
msq(215, 380, 16)
rsqc(216, 380, 9, TH, 1.6, BONE_SH)
SEG({215,371},{200,366},1.8,BONE_SH); SEG({200,366},{200,394},1.8,BONE_SH); SEG({200,394},{215,389},1.8,BONE_SH)
local b = brush{kind="round", width=2, point=0.3}
b:reload(BONE_SH, 0.9); b:stroke({{252,380},{270,372},{292,378},{312,370}}, {pressure={0.5,0.15}})
local s = brush{kind="round", width=3, point=0.1}
for i=1,8 do
  local a = i*2.39996
  local r = 86 + 4*math.sqrt(i)
  local x, y = GX+6 + math.cos(a)*r*0.95, GY + math.sin(a)*r
  if x > 92 and x < 330 and y > 110 and y < 405 and DOCENT:at(x,y) < 0.5 then
    s:reload(BONE_SH, 0.8); s:touch(x, y, {pressure=0.5})
  end
end

--@ chunk 47
-- (8) the pointer: a long bronze finger whose bone tip touches the corner of the turned inset
local tipx, tipy = 244.2, 267.2
local m = ribbon({{262,250},{252,259},{tipx+2,tipy-2}}, 3.2)
work(m, {hand="detail", tool="round 1.2", pile=B_RAMP[4], coverage=6, fill=true, clip=true})
local r = brush{kind="round", width=1.2, point=0.6}
r:reload(B_RAMP[7], 0.9); r:stroke({{262,248.6},{252,257.6},{tipx+2.4,tipy-3.2}}, {pressure={0.4,0.4}, clip=m})
local d = brush{kind="round", width=2.6, point=0.1}
d:reload(BONE_HI, 0.95); d:touch(tipx+0.6, tipy-0.6, {pressure=0.7})
-- the touch: a small bright contact on the cut corner
local g = brush{kind="round", width=1.2, point=0.9}
for _,a in ipairs({0.6, 2.2, 3.6, 5.0}) do
  g:reload(BONE_HI, 0.8); g:stroke({{tipx+math.cos(a)*2.5, tipy+math.sin(a)*2.5},{tipx+math.cos(a)*7, tipy+math.sin(a)*7}}, {pressure={0.4,0.0}})
end

--@ chunk 48
local CX, CY = 745, 215
local function tang(x,y) if y < CY then return math.atan(y-CY, x-CX) + math.pi/2 end return 1.5708 end
local cart = ellipse(737,50,43,27)
local base = (HALLWALL - ARCH:grow(9) - PLATE - DOCENT:grow(2)) * rect(430,-5,580,125) - cart
local radii = {9, 30, 55, 82, 112, 150, 400}
local P = {G1,G2,G3,G4,G5,G5}
for i=1,6 do
  local band = (ARCH:grow(radii[i+1]) - ARCH:grow(radii[i])) * base
  if band:area() > 1 then
    work(band, {hand="body", tool="filbert 5", pile=P[i], coverage=4, fill=true, clip=true, angle=tang, angle_jitter=0.04, length={25,60}})
  end
end
for i=2,5 do
  blend((ARCH:grow(radii[i]+10) - ARCH:grow(radii[i]-10)) * base, {angle=tang, tool={kind="badger", width=10}})
end
-- the seam with the older wall below y=120 at the sides
blend((HALLWALL - ARCH:grow(9) - PLATE - DOCENT:grow(2)) * rect(430,108,580,24) - cart, {angle=tang, tool={kind="badger", width=10}})

--@ chunk 49
-- soften the pool's side edges: an intermediate band laid along each edge, then blended along it
local fl = (HALLFLOOR * rect(-5,478,1010,160)) - DOCENT:grow(1) - CHAIRS:grow(1)
local sides = {
  {{560-15,476},{450-150,640}, {560+15,476},{450+60,640}},
  {{930-15,476},{1060-60,640}, {930+15,476},{1060+150,640}},
}
for _,s in ipairs(sides) do
  local m = poly({s[1], s[3], s[4], s[2]}) * fl
  local ang = math.atan(s[2][2]-s[1][2], s[2][1]-s[1][1])
  work(m, {hand="body", tool="filbert 6", pile=P3, coverage=4, fill=true, clip=true, angle=ang, length={40,90}})
  blend(m, {angle=ang, tool={kind="badger", width=12}})
end
-- flange under the docent's spine: dark underside, lit rim
local r = brush{kind="round", width=3, point=0.3}
r:reload(B_RAMP[1], 0.9); r:stroke({{386,316},{430,320},{474,316}}, {pressure={0.6,0.6}, clip=COLLAR_D})
r = brush{kind="round", width=1.6, point=0.5}
r:reload(B_RAMP[7], 0.9); r:stroke({{430,301},{456,302},{474,306}}, {pressure={0.4,0.5}})

--@ chunk 50
wait(8*24*60) print(drying(700,30))

--@ chunk 51
local s = brush{kind="round", width=2.4, point=0.1}
local x = 430; local k = 50
while x < 1000 do
  k = k + 1
  local y = 22 + 5*math.sin(k*2.39996)
  if ellipse(737,50,46,30):at(x,y) < 0.5 then s:reload(BONE_SH, 0.7); s:touch(x, y, {pressure=0.45}) end
  x = x + 9 + 5*((k*0.618) % 1)
end
local r = brush{kind="round", width=2, point=0.3}
r:reload(BRZ_M, 0.8); r:stroke({{428,36},{692,36}}, {pressure={0.5,0.5}, ramps={0.01,0.01}})
r:reload(BRZ_M, 0.8); r:stroke({{782,36},{1000,36}}, {pressure={0.5,0.5}, ramps={0.01,0.01}})
