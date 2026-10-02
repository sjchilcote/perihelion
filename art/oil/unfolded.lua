-- easel session "unfolded": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.5, linen=16, seed=4242,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5},{"lead white",0.6}}, um=120, apply="knife", texture=0.4}}}
print(W,H)

--@ chunk 2
WALL = pile{{"Mars brown",2},{"bone black",0.9},{"raw sienna",0.6},{"ultramarine blue",0.3},{"viridian",0.1}}
NICHE = pile{{"bone black",1.5},{"ultramarine blue",0.8},{"Mars brown",0.6},{"viridian",0.15}}
FLOOR = pile{{"bone brown",1.5},{"bone black",0.8},{"ultramarine blue",0.4},{"raw sienna",0.4},{"lead white",0.5}}
NICHEM = rect(362, 200, 276, 232) + ellipse(500, 200, 138, 118) * above(function(x) return 201 end)
FLOORM = below(function(x) return 430 end)
WALLM = -(NICHEM + FLOORM)
work(WALLM, {hand="broad", pile=WALL, coverage=2.5, fill=true, clip=true, seed=11})
work(NICHEM, {hand="body", pile=NICHE, angle=math.pi/2, coverage=3, fill=true, clip=true, seed=12})
work(FLOORM, {hand="broad", pile=FLOOR, angle=0, coverage=2.5, fill=true, clip=true, seed=13})

--@ chunk 3
print(wait(24*60), drying(100,100), drying(500,300))
LIP = pile{{"raw sienna",1},{"burnt sienna",0.5},{"Mars brown",0.6},{"yellow ochre",0.3},{"lead white",0.25},{"viridian",0.08}}
SH = pile{{"bone black",1.2},{"Mars brown",0.8},{"ultramarine blue",0.4}}
VG = pile{{"viridian",1},{"cerulean blue",0.5},{"bone black",0.8},{"lead white",0.6},{"raw sienna",0.3}}
local lipb = brush{kind="filbert", width=6, stiffness=0.6}
local shb = brush{kind="filbert", width=7, stiffness=0.6}
local cx, cy = 500, 250
local ga = math.pi*(3-math.sqrt(5))
local n = 0
for i=30,900 do
  local r = 14*math.sqrt(i)
  local a = i*ga
  local x, y = cx + r*math.cos(a), cy + r*math.sin(a)*0.92
  local inside = NICHEM:at(x,y) > 0.1 or (x-500)^2/(155^2) + (y-200)^2/(135^2) < 1 and y < 200 or (x>345 and x<655 and y>190)
  if x > -10 and x < 1010 and y > -10 and y < 422 and not inside then
    n = n + 1
    local s = 9 + r*0.035 + rand(-1.5,1.5)
    local t = a + math.pi/2 + rand(-0.15,0.15)
    local dx, dy = math.cos(t)*s, math.sin(t)*s*0.92
    local ox, oy = math.cos(a)*s*0.35, math.sin(a)*s*0.35
    if n % 5 == 1 then shb:load(SH, 0.5); lipb:load((n % 11 == 0) and VG or LIP, 0.4) end
    shb:stroke({{x-dx+ox, y-dy+oy+2},{x+ox*1.4, y+oy*1.4+3},{x+dx+ox, y+dy+oy+2}}, {pressure={0.6,0.4}})
    lipb:stroke({{x-dx, y-dy},{x+ox*0.6, y+oy*0.6},{x+dx, y+dy}}, {pressure={0.35,0.15}, ramps={0.2,0.4}})
  end
end
print(n)

--@ chunk 4
LIP2 = pile{{"Mars brown",1},{"raw sienna",0.6},{"burnt sienna",0.3},{"bone black",0.25},{"lead white",0.1}}
local lipb = brush{kind="filbert", width=7, stiffness=0.6}
local shb = brush{kind="filbert", width=8, stiffness=0.6}
local cx, cy = 500, 250
local ga = math.pi*(3-math.sqrt(5))
local n = 0
for i=880,2600 do
  local r = 14*math.sqrt(i)
  local a = i*ga
  local x, y = cx + r*math.cos(a), cy + r*math.sin(a)*0.92
  if x > -15 and x < 1015 and y > -15 and y < 422 then
    n = n + 1
    local s = 9 + r*0.035 + rand(-1.5,1.5)
    local t = a + math.pi/2 + rand(-0.15,0.15)
    local dx, dy = math.cos(t)*s, math.sin(t)*s*0.92
    local ox, oy = math.cos(a)*s*0.35, math.sin(a)*s*0.35
    if n % 5 == 1 then shb:load(SH, 0.5); lipb:load((n % 13 == 0) and VG or LIP2, 0.35) end
    shb:stroke({{x-dx+ox, y-dy+oy+2},{x+ox*1.4, y+oy*1.4+3},{x+dx+ox, y+dy+oy+2}}, {pressure={0.6,0.4}})
    lipb:stroke({{x-dx, y-dy},{x+ox*0.6, y+oy*0.6},{x+dx, y+dy}}, {pressure={0.3,0.12}, ramps={0.2,0.4}})
  end
end
print(n)

--@ chunk 5
print(wait(2*24*60), drying(500,300))
-- cold shaft from above, inside the niche
SHAFT = pile{{"lead white",2},{"cerulean blue",0.5},{"ultramarine ash",0.5},{"bone black",0.2}, medium=0.4}
local shaftm = poly({{465,85},{535,85},{585,400},{415,400}}):soften(14) * NICHEM
work(shaftm, {hand="glaze", pile=SHAFT, load=0.25, pressure={0.1,0.25}, angle=math.pi/2, coverage=1.5, clip=NICHEM, seed=21})
blend(shaftm:grow(10) * NICHEM, {angle=math.pi/2, seed=22})
-- plinth, stepped
PL = pile{{"Mars brown",1.5},{"bone black",0.8},{"raw sienna",0.4},{"ultramarine blue",0.2}}
PLD = pile{{"bone black",1.4},{"Mars brown",0.8},{"ultramarine blue",0.4}}
work(rect(392, 412, 216, 60), {hand="body", pile=PLD, angle=0, coverage=3, fill=true, clip=true, seed=23})
work(rect(426, 378, 148, 36), {hand="body", pile=PL, angle=0, coverage=3, fill=true, clip=true, seed=24})

--@ chunk 6
print(wait(2*24*60), drying(500,250), drying(500,300))
NS1 = pile{{"bone black",1.2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.55},{"cerulean blue",0.15}}
NS2 = pile{{"bone black",1.0},{"ultramarine blue",0.7},{"Mars brown",0.2},{"lead white",1.0},{"cerulean blue",0.25}}
local nm = NICHEM - rect(390, 376, 220, 60)
local core = poly({{482,85},{518,85},{548,380},{452,380}})
local mid = poly({{470,85},{530,85},{572,380},{428,380}})
work(nm - mid, {hand="body", pile=NICHE, angle=math.pi/2, coverage=3, fill=true, clip=nm - mid, seed=31})
work(mid - core, {hand="body", pile=NS1, angle=math.pi/2, coverage=3, fill=true, clip=(mid - core)*nm, seed=32})
work(core * nm, {hand="body", pile=NS2, angle=math.pi/2, coverage=3, fill=true, clip=core*nm, seed=33})
blend(mid:rim(12, 6) * nm, {angle=math.pi/2, seed=34})
blend(core:rim(10, 5) * nm, {angle=math.pi/2, seed=35})

--@ chunk 7
local nm = NICHEM - rect(390, 376, 220, 60)
local mid = poly({{470,85},{530,85},{572,380},{428,380}})
local z = mid:grow(30) * nm
blend(z, {angle=0, seed=41})
blend(z, {angle=math.pi/2, seed=42})
blend(z, {angle=0.3, seed=43})

--@ chunk 8
local nm = NICHEM - rect(390, 376, 220, 60)
local mid = poly({{470,85},{530,85},{572,380},{428,380}})
local z = mid:grow(30) * nm
local band = (z:grow(16) - z:shrink(16)) * nm
print(band:area())
blend(band, {angle=0, tool={kind="badger", width=20}, seed=51})
blend(band, {angle=0.2, tool={kind="badger", width=20}, seed=52})

--@ chunk 9
print(wait(3*24*60), drying(500,250), drying(410,395))
-- cover the stray pale glaze beside the plinth
local side = (rect(395,372,33,42) + rect(572,372,33,42)) * NICHEM
work(side, {hand="body", pile=NICHE, tool="filbert 6", angle=math.pi/2, coverage=3, fill=true, clip=true, seed=61})
BS = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.4},{"bone black",0.45},{"ultramarine blue",0.15}}
BONE = pile{{"lead white",3},{"yellow ochre",0.8},{"raw sienna",0.25},{"bone black",0.12}}
BCOLD = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25},{"yellow ochre",0.2}}
BASIN = poly({{436,349},{564,349},{556,368},{534,381},{468,381},{445,369}}, true)
work(BASIN, {hand="body", pile=BS, tool="filbert 6", angle=0, coverage=3, fill=true, clip=true, seed=62})
-- ribs: cupped bone fingers rising from the basin
local rib = brush{kind="filbert", width=8, stiffness=0.6}
local ribs = {
  {{452,356},{438,330},{434,306},{442,288},{455,280}},
  {{466,354},{458,326},{458,302},{466,288}},
  {{548,356},{561,331},{567,307},{560,290},{546,281}},
  {{534,354},{543,327},{544,304},{537,290}},
}
for k,pts in ipairs(ribs) do
  rib:reload(BS, 0.8)
  rib:stroke(pts, {pressure={0.9,0.25}, ramps={0.1,0.5}, orient="across"})
end

--@ chunk 10
BSD = pile{{"lead white",1},{"yellow ochre",0.4},{"raw sienna",0.4},{"bone black",0.6},{"ultramarine blue",0.3}}
HOL = pile{{"bone black",0.8},{"ultramarine blue",0.5},{"lead white",0.9},{"raw sienna",0.2}}
local b = brush{kind="filbert", width=5, stiffness=0.6}
-- underside of the basin in shadow
for k=0,3 do
  b:reload(BSD, 0.6)
  local y = 370 + k*3
  b:stroke({{450+k*4, y-2},{500, y+6+k},{550-k*4, y-2}}, {pressure={0.6,0.5}})
end
-- the hollow bed where the container lay
work(ellipse(500, 355, 52, 7), {hand="detail", pile=HOL, tool={kind="round", width=3}, angle=0, coverage=3, fill=true, clip=true, seed=71})
-- shadow on the inner faces of the ribs, cold light on their outer tops
local ribs = {
  {{452,356},{438,330},{434,306},{442,288},{455,280}},
  {{466,354},{458,326},{458,302},{466,288}},
  {{548,356},{561,331},{567,307},{560,290},{546,281}},
  {{534,354},{543,327},{544,304},{537,290}},
}
local thin = brush{kind="round", width=3, point=0.6}
for k,pts in ipairs(ribs) do
  local dir = (k<=2) and 1 or -1
  local inner, outer = {}, {}
  for _,p in ipairs(pts) do inner[#inner+1] = {p[1]+dir*2.5, p[2]}; outer[#outer+1] = {p[1]-dir*2.2, p[2]-1} end
  thin:reload(BSD, 0.6); thin:stroke(inner, {pressure={0.6,0.15}})
  thin:reload(BCOLD, 0.5); thin:stroke(outer, {pressure={0.5,0.1}})
end
-- cold lip along the basin rim
thin:reload(BCOLD, 0.6)
thin:stroke({{440,350},{470,347},{500,346.5},{530,347},{560,350}}, {pressure={0.55,0.4}})

--@ chunk 11
print(wait(2*24*60), drying(100,100), drying(200,550), drying(500,355))
WD = pile{{"Mars brown",1.2},{"bone black",1.3},{"ultramarine blue",0.4},{"raw sienna",0.2}}
FD = pile{{"bone brown",1.2},{"bone black",1.2},{"ultramarine blue",0.5},{"lead white",0.15}}
FM = pile{{"bone brown",1.2},{"bone black",0.9},{"ultramarine blue",0.45},{"raw sienna",0.3},{"lead white",0.35}}
-- the wall goes dark away from the niche: two rings of broken dark strokes
local far = WALLM * mask(function(x,y) local d = math.sqrt((x-500)^2 + ((y-260)*1.3)^2); return smoothstep(330, 420, d) end)
local mid = WALLM * mask(function(x,y) local d = math.sqrt((x-500)^2 + ((y-260)*1.3)^2); return smoothstep(220, 300, d) end)
work(mid, {hand="body", pile=WD, tool="filbert 10", length={30,90}, load=0.45, coverage=1.0, clip=WALLM, seed=81})
work(far, {hand="body", pile=WD, tool="filbert 12", length={40,120}, load=0.55, coverage=2.2, clip=WALLM, seed=82})
-- floor: darker toward the viewer and the sides
local fl = FLOORM - rect(388, 408, 224, 68)
local front = fl * mask(function(x,y) local d = math.sqrt(((x-500)*0.55)^2 + ((y-450)*1.6)^2); return smoothstep(110, 200, d) end)
local fmid = fl * mask(function(x,y) local d = math.sqrt(((x-500)*0.55)^2 + ((y-450)*1.6)^2); return smoothstep(60, 120, d) end)
work(fmid, {hand="body", pile=FM, tool="filbert 12", angle=0, angle_jitter=0.1, length={40,120}, load=0.5, coverage=1.6, clip=fl, seed=83})
work(front, {hand="body", pile=FD, tool="filbert 14", angle=0, angle_jitter=0.1, length={50,150}, load=0.6, coverage=2.4, fill=true, clip=fl, seed=84})

--@ chunk 12
print(wait(3*24*60), drying(500,600), drying(500,355), drying(100,100))
FROST = pile{{"zinc white",3},{"cerulean blue",0.35},{"ultramarine ash",0.2}}
-- frost: the outline of what lay here
stipple(ellipse(500,354,38,6):soften(2), {pile=FROST, width=1.4, coverage=0.5, pressure={0.2,0.4}, feather=0.6, seed=91})
stipple(ellipse(500, 354, 34, 4.8) - ellipse(500, 354, 30, 3.4), {pile=FROST, width=1.6, coverage=2.2, pressure={0.35,0.6}, seed=92})
-- terminal (MIRIAD, bolted to the bronze), dead
TG = pile{{"lead white",1},{"bone black",1.2},{"ultramarine blue",0.25},{"viridian",0.1}}
TS = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"viridian",0.15}}
work(rect(110, 255, 96, 78), {hand="body", pile=TG, tool="filbert 5", angle=0, ruler=true, coverage=3, fill=true, clip=true, seed=93})
work(rect(120, 263, 62, 46), {hand="detail", pile=TS, tool={kind="round", width=3}, angle=0, coverage=3, fill=true, clip=true, seed=94})
work(rect(150, 333, 8, 95), {hand="detail", pile=TG, tool={kind="round", width=3}, angle=math.pi/2, coverage=3, fill=true, clip=true, seed=95})
-- lamp rows high on the wall: most already out
LAMPW = pile{{"Indian yellow",1},{"lead white",1},{"Mars orange",0.3}}
LAMPD = pile{{"Mars brown",1},{"bone black",0.8},{"raw sienna",0.3}}
local lb = brush{kind="filbert", width=4}
for row=0,2 do
  local y = 22 + row*30
  local xs = uneven(26, 40, 960, 0.3, 0.2, 100+row)
  for i,x in ipairs(xs) do
    if not (x > 340 and x < 660 and y > 60) then
      local lit = (row == 2 and i % 5 ~= 0 and x < 520) or (row == 1 and (i == 3 or i == 4))
      lb:reload(lit and LAMPW or LAMPD, 0.6)
      lb:stroke({{x, y-3},{x, y+3}}, {pressure={0.7,0.7}})
    end
  end
end

--@ chunk 13
print(wait(3*24*60), drying(500,600), drying(150,290))
TG2 = pile{{"lead white",0.5},{"bone black",1.3},{"ultramarine blue",0.3},{"Mars brown",0.3}}
TS2 = pile{{"bone black",1.6},{"ultramarine blue",0.5},{"Mars brown",0.2}}
work(rect(110, 255, 96, 78), {hand="body", pile=TG2, tool="filbert 5", angle=0, ruler=true, coverage=3, fill=true, clip=true, seed=101})
work(rect(150, 333, 8, 95), {hand="detail", pile=TG2, tool={kind="round", width=3}, angle=math.pi/2, coverage=3, fill=true, clip=true, seed=102})
work(rect(121, 264, 60, 44), {hand="detail", pile=TS2, tool={kind="round", width=3}, angle=0, coverage=3.5, fill=true, clip=true, seed=103})
-- tracks: many feet, pairs of short marks, curving from the plinth away down-left and out of the picture
TRK = pile{{"bone black",1.4},{"ultramarine blue",0.4},{"bone brown",0.6}}
DUST = pile{{"lead white",1.2},{"bone brown",0.6},{"bone black",0.5},{"ultramarine ash",0.4}}
local tb = brush{kind="filbert", width=3.5}
local db = brush{kind="filbert", width=5}
local path = {{470,478},{430,505},{370,535},{300,570},{220,610},{130,650},{60,690}}
local function at(t)
  local n = #path - 1
  local f = t*n; local i = math.min(math.floor(f), n-1); local u = f - i
  local a, b = path[i+1], path[i+2]
  return a[1] + (b[1]-a[1])*u, a[2] + (b[2]-a[2])*u, math.atan(b[2]-a[2], b[1]-a[1])
end
local k = 0
for s=0,1,0.012 do
  local x, y, ang = at(s)
  local sc = 0.6 + s*0.9          -- larger toward the viewer
  for side=-1,1,2 do
    for leg=1,3 do
      k = k + 1
      local off = side*(9 + leg*7)*sc
      local px = x + math.cos(ang+math.pi/2)*off + rand(-3,3)*sc + math.cos(ang)*(leg-2)*6*sc
      local py = y + math.sin(ang+math.pi/2)*off*0.45 + rand(-1.5,1.5)*sc
      if math.random() < 0.55 then
        if k % 6 == 1 then tb:reload(TRK, 0.5); db:reload(DUST, 0.3) end
        db:stroke({{px - 3*sc, py - 1}, {px + 3*sc, py + 1}}, {pressure={0.3,0.2}})
        tb:stroke({{px - 2*sc, py}, {px + 2*sc, py + 0.5}}, {pressure={0.5*sc,0.3}})
      end
    end
  end
end
-- crimson scrap, lower right, lying flat
CR = pile{{"vermilion",0.6},{"rose madder",1},{"Mars red",0.6},{"bone black",0.25}}
CRD = pile{{"rose madder",1},{"Mars red",0.5},{"bone black",0.6},{"ultramarine blue",0.2}}
local cloth = outline{{690,560,"c"},{742,548},{790,556,"c"},{770,574},{728,586,"c"},{700,580}, char="soft", seed=7}
work(cloth:mask(), {hand="body", pile=CRD, tool="filbert 5", angle=0.2, coverage=3, fill=true, clip=true, seed=104})
local cb = brush{kind="filbert", width=4}
cb:reload(CR, 0.6); cb:stroke({{700,566},{730,559},{765,558}}, {pressure={0.6,0.3}})
cb:reload(CR, 0.5); cb:stroke({{712,577},{745,570},{775,566}}, {pressure={0.5,0.2}})

--@ chunk 14
print(wait(3*24*60), drying(740,566), drying(400,540))
-- heavier pointed-foot gouges along the trail
local gb = brush{kind="round", width=4, point=0.8}
local path = {{470,478},{430,505},{370,535},{300,570},{220,610},{130,650},{60,690}}
local function at(t)
  local n = #path - 1
  local f = t*n; local i = math.min(math.floor(f), n-1); local u = f - i
  local a, b = path[i+1], path[i+2]
  return a[1] + (b[1]-a[1])*u, a[2] + (b[2]-a[2])*u, math.atan(b[2]-a[2], b[1]-a[1])
end
local k = 0
for s=0.02,1,0.035 do
  local x, y, ang = at(s + rand(-0.01,0.01))
  local sc = 0.7 + s*1.1
  for leg=1,4 do
    k = k + 1
    local side = (leg % 2 == 0) and 1 or -1
    local off = side*(12 + rand(0,14))*sc
    local px = x + math.cos(ang+math.pi/2)*off
    local py = y + math.sin(ang+math.pi/2)*off*0.45
    if k % 5 == 1 then gb:reload(TRK, 0.6) end
    local a2 = ang + rand(-0.5,0.5)
    gb:stroke({{px - math.cos(a2)*5*sc, py - math.sin(a2)*2*sc},{px + math.cos(a2)*4*sc, py + math.sin(a2)*1.5*sc}}, {pressure={0.7,0.05}, ramps={0.05,0.6}})
  end
end
-- folds in the cloth, dust settling on it
local cb = brush{kind="filbert", width=3}
cb:reload(CRD, 0.6); cb:stroke({{705,572},{735,566},{760,563}}, {pressure={0.5,0.2}})
cb:reload(CRD, 0.6); cb:stroke({{720,556},{750,553},{778,557}}, {pressure={0.4,0.1}})
stipple(cloth_m or ellipse(740,566,48,14), {pile=DUST, width=2, coverage=0.25, pressure={0.2,0.35}, feather=0.5, seed=111})
-- rosary dropped beside it: bone beads on a loose loop, a small cross
BEAD = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.3},{"bone black",0.35}}
local bb = brush{kind="round", width=3.2}
local loop = {{800,585},{830,578},{858,584},{866,598},{850,610},{820,612},{796,604},{788,594},{800,585}}
local pts = {}
for i=1,#loop-1 do
  local a, b = loop[i], loop[i+1]
  for u=0,0.99,0.25 do pts[#pts+1] = {a[1]+(b[1]-a[1])*u + rand(-0.8,0.8), a[2]+(b[2]-a[2])*u + rand(-0.6,0.6)} end
end
for i,p in ipairs(pts) do
  if i % 8 == 1 then bb:reload(BEAD, 0.6) end
  bb:touch(p[1], p[2], {pressure=0.55})
end
-- a tail of beads and the cross
for i,p in ipairs({{790,603},{784,611},{779,619},{775,627}}) do bb:touch(p[1], p[2], {pressure=0.55}) end
local xb = brush{kind="filbert", width=2.4}
xb:reload(BEAD, 0.7)
xb:stroke({{772,632},{768,646}}, {pressure={0.7,0.6}})
xb:stroke({{764,637},{776,639}}, {pressure={0.7,0.6}})
-- inscription on the plinth front: dim bone glyph lines
INS = pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.6},{"raw sienna",0.3}}
local ib = brush{kind="round", width=1.6, point=0.7}
ib:reload(INS, 0.5)
for row=0,2 do
  local y = 424 + row*14
  local xs = uneven(14, 404, 596, 0.4, 0.3, 300+row)
  for i,x in ipairs(xs) do
    if i % 4 == 0 then ib:reload(INS, 0.45) end
    local h = rand(4,8)
    ib:stroke({{x, y},{x + rand(-2,2), y + h}}, {pressure={0.5,0.3}})
    if math.random() < 0.4 then ib:stroke({{x, y + h*0.5},{x + rand(3,6), y + h*0.5 + rand(-1,1)}}, {pressure={0.4,0.2}}) end
  end
end

--@ chunk 15
print(wait(2*24*60), drying(150,290), drying(500,395))
TG3 = pile{{"bone black",1.3},{"ultramarine blue",0.35},{"Mars brown",0.4},{"lead white",0.25},{"viridian",0.1}}
work(rect(110, 255, 96, 78) - rect(121,264,60,44), {hand="body", pile=TG3, tool="filbert 4", angle=0, ruler=true, coverage=3.5, fill=true, clip=true, seed=121})
work(rect(150, 333, 8, 95), {hand="detail", pile=TG3, tool={kind="round", width=3}, angle=math.pi/2, coverage=3.5, fill=true, clip=true, seed=122})
-- cold top edges: terminal lip, plinth steps
local lb = brush{kind="round", width=2.2, point=0.3}
COLDE = pile{{"lead white",1.4},{"cerulean blue",0.3},{"bone black",0.5},{"ultramarine blue",0.2}}
lb:reload(COLDE, 0.45); lb:stroke({{111,256},{205,256}}, {pressure={0.4,0.3}})
lb:reload(COLDE, 0.6); lb:stroke({{428,379},{572,379}}, {pressure={0.55,0.55}})
lb:reload(COLDE, 0.5); lb:stroke({{394,413},{606,413}}, {pressure={0.5,0.4}})
-- dim the brown plinth step: shadow under the basin
PLS = pile{{"Mars brown",1},{"bone black",1.2},{"ultramarine blue",0.4}}
work(rect(428, 382, 144, 30), {hand="body", pile=PLS, tool="filbert 6", angle=0, load=0.5, coverage=1.6, clip=true, seed=123})
-- spill of the cold light on the floor before the plinth
SPILL = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"bone black",0.5},{"bone brown",0.3}}
local sp = ellipse(500, 490, 120, 16):roughen(5, 30, 4)
work(sp, {hand="scumble", pile=SPILL, load=0.2, coverage=0.8, pressure={0.15,0.35}, angle=0, clip=sp:soften(6), seed=124})

--@ chunk 16
local z = ellipse(500, 490, 150, 26):soften(8)
blend(z, {angle=0, seed=131})
blend(z, {angle=0.15, seed=132})

--@ chunk 17
print(wait(2*24*60), drying(500,490))
local outer = ellipse(500, 490, 158, 30)
local ring = (outer - ellipse(500, 488, 85, 11):roughen(6, 25, 8)) * FLOORM
work(ring, {hand="body", pile=FM, tool="filbert 9", angle=0, angle_jitter=0.15, length={20,60}, load=0.5, coverage=2.2, clip=outer:roughen(8, 30, 9) * FLOORM, seed=141})
work(ellipse(500, 488, 85, 11), {hand="body", pile=FM, tool="filbert 9", angle=0, angle_jitter=0.15, length={20,50}, load=0.35, coverage=0.7, clip=true, seed=142})
INSD = pile{{"bone black",1.2},{"Mars brown",0.8},{"ultramarine blue",0.3},{"lead white",0.3}}
work(rect(394, 418, 212, 50), {hand="scumble", pile=INSD, tool="filbert 5", load=0.25, coverage=0.7, pressure={0.15,0.3}, angle=0, clip=true, seed=143})

--@ chunk 18
print(wait(24*60), drying(430,200), drying(500,354))
-- break the hard edges of the light inside the niche
local nm = NICHEM - rect(388, 270, 224, 170)
for _,ex in ipairs({{420,575},{580,425}}) do end
local edges = (poly({{448,85},{492,85},{452,380},{404,380}}) + poly({{508,85},{552,85},{596,380},{548,380}})) * nm
work(edges, {hand="body", pile=NS1, tool="filbert 7", angle=math.pi/2, angle_jitter=0.15, length={20,60}, load=0.4, coverage=1.3, pressure={0.3,0.6}, clip=nm, seed=151})
local outer = (poly({{420,85},{455,85},{420,380},{380,380}}) + poly({{545,85},{580,85},{620,380},{580,380}})) * nm
work(outer, {hand="body", pile=NICHE, tool="filbert 7", angle=math.pi/2, angle_jitter=0.15, length={20,60}, load=0.45, coverage=1.3, pressure={0.3,0.6}, clip=nm, seed=152})
-- frost: the lightest light, the shape of what is gone
local fb = brush{kind="round", width=1.6, point=0.5}
for i=1,46 do
  local a = rand(0, 2*math.pi)
  local x, y = 500 + math.cos(a)*rand(29,35), 354 + math.sin(a)*rand(3.6,5)
  if i % 6 == 1 then fb:reload(FROST, 0.6) end
  fb:touch(x, y, {pressure=rand(0.3,0.6)})
end
for i=1,24 do
  local x = rand(442,558); local y = 348 + rand(-1.5,1.5)
  if i % 6 == 1 then fb:reload(FROST, 0.5) end
  fb:stroke({{x,y},{x+rand(-3,3), y-rand(1,4)}}, {pressure={0.4,0.05}})
end
-- one more row of lamps on the right, dying
local lb = brush{kind="filbert", width=4}
DIM = pile{{"Mars orange",1},{"burnt sienna",0.6},{"lead white",0.3}}
local xs = uneven(10, 680, 960, 0.3, 0.2, 777)
for i,x in ipairs(xs) do
  lb:reload((i == 2 or i == 7) and DIM or LAMPD, 0.6)
  lb:stroke({{x, 49},{x, 55}}, {pressure={0.7,0.7}})
end

--@ chunk 19
local cr = ellipse(500, 330, 76, 58) + rect(388, 345, 224, 100)
local nm2 = (NICHEM * rect(355, 240, 290, 140)) - cr
local band = nm2 * rect(355, 255, 290, 125)
work(band * (poly({{448,85},{492,85},{452,380},{404,380}}) + poly({{508,85},{552,85},{596,380},{548,380}})), {hand="body", pile=NS1, tool="filbert 7", angle=math.pi/2, angle_jitter=0.15, length={20,60}, load=0.4, coverage=1.3, pressure={0.3,0.6}, clip=nm2, seed=161})
work(band * (poly({{420,85},{455,85},{420,380},{350,380}}) + poly({{545,85},{580,85},{650,380},{580,380}})), {hand="body", pile=NICHE, tool="filbert 7", angle=math.pi/2, angle_jitter=0.15, length={20,60}, load=0.45, coverage=1.3, pressure={0.3,0.6}, clip=nm2, seed=162})

--@ chunk 20
print(wait(2*24*60), drying(450,365))
local side = (rect(386,340,44,73) + rect(570,340,44,73)) * NICHEM
work(side, {hand="body", pile=NICHE, tool="filbert 6", angle=math.pi/2, coverage=3, fill=true, clip=side, seed=171})
-- model the basin: lit upper band, darker warm belly, a cool reflected line at the bottom
local b = brush{kind="filbert", width=4, stiffness=0.6}
BMID = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.35},{"bone black",0.3},{"ultramarine blue",0.1}}
for k=0,2 do
  b:reload(BONE, 0.55)
  local y = 360 + k*2.5
  b:stroke({{444+k*2, y-3},{470, y},{500, y+0.8},{530, y},{556-k*2, y-3}}, {pressure={0.5,0.3}})
end
for k=0,3 do
  b:reload(BSD, 0.65)
  local y = 369 + k*3
  b:stroke({{455+k*5, y-3},{480, y+1},{500, y+1.5},{522, y+1},{545-k*5, y-3}}, {pressure={0.55,0.4}})
end
local t = brush{kind="round", width=2, point=0.5}
t:reload(COLDE, 0.5); t:stroke({{470,381},{500,383},{530,381}}, {pressure={0.4,0.2}})
-- ribs: a darker inner core, the cold light along their crowns
local ribs = {
  {{452,356},{438,330},{434,306},{442,288},{455,280}},
  {{466,354},{458,326},{458,302},{466,288}},
  {{548,356},{561,331},{567,307},{560,290},{546,281}},
  {{534,354},{543,327},{544,304},{537,290}},
}
for k,pts in ipairs(ribs) do
  local dir = (k<=2) and 1 or -1
  local inner = {}
  for _,p in ipairs(pts) do inner[#inner+1] = {p[1]+dir*2.2, p[2]+1} end
  t:reload(BSD, 0.7); t:stroke(inner, {pressure={0.7,0.2}})
  local crown = {}
  for _,p in ipairs(pts) do crown[#crown+1] = {p[1]-dir*1.8, p[2]-1} end
  t:reload(BCOLD, 0.55); t:stroke(crown, {pressure={0.45,0.05}})
end

--@ chunk 21
local b = brush{kind="filbert", width=6}
for i=1,16 do
  local left = i <= 8
  local x = left and rand(388,428) or rand(572,612)
  if (left and x > 426) or ((not left) and x < 574) then x = left and 420 or 580 end
  b:reload(NICHE, rand(0.35,0.55))
  b:stroke({{x, 352},{x + rand(-2,2), 330},{x + rand(-3,3), rand(285,315)}}, {pressure={0.6,0.0}, ramps={0.05,0.7}, clip=NICHEM - ellipse(500,330,70,55)})
end

--@ chunk 22
print(wait(24*60))
local ring = WALLM * mask(function(x,y) local d = math.sqrt((x-500)^2 + ((y-260)*1.3)^2); return smoothstep(185, 240, d) end) - rect(100,245,115,190)
work(ring, {hand="body", pile=WD, tool="filbert 9", length={25,80}, load=0.4, coverage=0.9, clip=WALLM - rect(100,245,115,190), seed=181})

--@ chunk 23
print(wait(2*24*60), drying(100,100), drying(700,200))
-- body piles darkening outward; lips: dim light, cooler near the niche
PB = {
  pile{{"Mars brown",1.2},{"raw sienna",0.7},{"burnt sienna",0.3},{"bone black",0.45},{"lead white",0.12}},
  pile{{"Mars brown",1.3},{"raw sienna",0.4},{"bone black",0.7},{"ultramarine blue",0.15}},
  pile{{"Mars brown",1},{"bone black",1.1},{"ultramarine blue",0.3},{"raw sienna",0.2}},
}
PU = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"Mars brown",0.5}}
PLIP = {
  pile{{"raw sienna",1},{"yellow ochre",0.5},{"lead white",0.6},{"cerulean blue",0.12},{"bone black",0.1}},
  pile{{"raw sienna",1},{"burnt sienna",0.3},{"yellow ochre",0.3},{"lead white",0.25},{"bone black",0.2}},
  pile{{"Mars brown",1},{"raw sienna",0.6},{"bone black",0.35},{"lead white",0.08}},
}
local avoid = NICHEM:grow(16) + rect(98, 245, 120, 190)
local cx, cy = 500, 255
local ga = math.pi*(3-math.sqrt(5))
local list = {}
for i=95,2000 do
  local r = 15*math.sqrt(i)
  local a = i*ga
  local x, y = cx + r*math.cos(a), cy + r*math.sin(a)*0.92
  if x > -20 and x < 1020 and y > -20 and y < 428 and avoid:at(clamp(x,0,999), clamp(y,0,666)) < 0.1 then
    list[#list+1] = {x, y, r, a}
  end
end
table.sort(list, function(p, q) return p[3] > q[3] end)   -- outermost first; inner plates lap over them
print(#list)
local UB = {brush{kind="filbert", width=10, stiffness=0.6}, brush{kind="filbert", width=13, stiffness=0.6}, brush{kind="filbert", width=17, stiffness=0.6}}
local BB = {brush{kind="filbert", width=12, stiffness=0.6}, brush{kind="filbert", width=16, stiffness=0.6}, brush{kind="filbert", width=20, stiffness=0.6}}
local lb = brush{kind="round", width=2.4, point=0.5}
for n,p in ipairs(list) do
  local x, y, r, a = p[1], p[2], p[3], p[4]
  local band = (r < 260) and 1 or ((r < 420) and 2 or 3)
  local s = 13 + (r-150)*0.03 + rand(-1.5,1.5)
  local ox, oy = math.cos(a), math.sin(a)*0.92
  local tx, ty = -oy, ox
  local L = s*0.55
  local ub, bb = UB[band], BB[band]
  ub:reload(PU, 0.5)
  ub:stroke({{x+ox*s*0.35 - tx*L, y+oy*s*0.35 - ty*L},{x+ox*s*0.5, y+oy*s*0.5},{x+ox*s*0.35 + tx*L, y+oy*s*0.35 + ty*L}}, {pressure={0.7,0.6}})
  bb:reload(PB[band], 0.55)
  bb:stroke({{x - tx*L, y - ty*L},{x+ox*s*0.08, y+oy*s*0.08},{x + tx*L, y + ty*L}}, {pressure={0.75,0.65}})
  if band < 3 or n % 2 == 0 then
    lb:reload(PLIP[band], 0.5)
    lb:stroke({{x-ox*s*0.25 - tx*L*0.8, y-oy*s*0.25 - ty*L*0.8},{x-ox*s*0.36, y-oy*s*0.36},{x-ox*s*0.25 + tx*L*0.8, y-oy*s*0.25 + ty*L*0.8}}, {pressure={0.45,0.1}, ramps={0.25,0.5}})
  end
end

--@ chunk 24
print(wait(4*24*60), drying(700,200), drying(900,100))
-- body piles darkening outward; lips: dim light, cooler near the niche
PB = {
  pile{{"Mars brown",1.2},{"raw sienna",0.5},{"bone black",0.7},{"ultramarine blue",0.12},{"viridian",0.05}},
  pile{{"Mars brown",1.1},{"raw sienna",0.25},{"bone black",1.0},{"ultramarine blue",0.25}},
  pile{{"Mars brown",0.8},{"bone black",1.4},{"ultramarine blue",0.4}},
}
PU = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"Mars brown",0.5}}
PLIP = {
  pile{{"raw sienna",1},{"yellow ochre",0.5},{"lead white",0.6},{"cerulean blue",0.12},{"bone black",0.1}},
  pile{{"raw sienna",1},{"burnt sienna",0.3},{"bone black",0.35},{"lead white",0.15}},
  pile{{"Mars brown",1},{"raw sienna",0.4},{"bone black",0.6}},
}
local avoid = NICHEM:grow(16) + rect(98, 245, 120, 190)
local cx, cy = 500, 255
local ga = math.pi*(3-math.sqrt(5))
local list = {}
for i=95,2000 do
  local r = 15*math.sqrt(i)
  local a = i*ga
  local x, y = cx + r*math.cos(a), cy + r*math.sin(a)*0.92
  if x > -20 and x < 1020 and y > -20 and y < 428 and avoid:at(clamp(x,0,999), clamp(y,0,666)) < 0.1 then
    list[#list+1] = {x, y, r, a}
  end
end
table.sort(list, function(p, q) return p[3] > q[3] end)   -- outermost first; inner plates lap over them
print(#list)
local UB = {brush{kind="filbert", width=13, stiffness=0.6}, brush{kind="filbert", width=17, stiffness=0.6}, brush{kind="filbert", width=22, stiffness=0.6}}
local BB = {brush{kind="filbert", width=16, stiffness=0.6}, brush{kind="filbert", width=21, stiffness=0.6}, brush{kind="filbert", width=27, stiffness=0.6}}
local lb = brush{kind="round", width=2.4, point=0.5}
for n,p in ipairs(list) do
  local x, y, r, a = p[1], p[2], p[3], p[4]
  local band = (r < 260) and 1 or ((r < 420) and 2 or 3)
  local s = 13 + (r-150)*0.03 + rand(-1.5,1.5)
  local ox, oy = math.cos(a), math.sin(a)*0.92
  local tx, ty = -oy, ox
  local L = s*0.75
  local ub, bb = UB[band], BB[band]
  ub:reload(PU, 0.5)
  ub:stroke({{x+ox*s*0.35 - tx*L, y+oy*s*0.35 - ty*L},{x+ox*s*0.5, y+oy*s*0.5},{x+ox*s*0.35 + tx*L, y+oy*s*0.35 + ty*L}}, {pressure={0.7,0.6}})
  bb:reload(PB[band], 0.55)
  bb:stroke({{x - tx*L, y - ty*L},{x+ox*s*0.08, y+oy*s*0.08},{x + tx*L, y + ty*L}}, {pressure={0.75,0.65}})
  if band < 3 or n % 3 == 0 then
    lb:reload(PLIP[band], 0.5)
    lb:stroke({{x-ox*s*0.25 - tx*L*0.8, y-oy*s*0.25 - ty*L*0.8},{x-ox*s*0.36, y-oy*s*0.36},{x-ox*s*0.25 + tx*L*0.8, y-oy*s*0.25 + ty*L*0.8}}, {pressure={0.45,0.1}, ramps={0.25,0.5}})
  end
end

--@ chunk 25
-- cover the bead-like tracks with floor colour, graded (FM near plinth, FD toward viewer)
local trail = ribbon({{470,478},{430,505},{370,535},{300,570},{220,610},{130,650},{60,690}}, {44,50,60,70,80,90,100})
local near = trail * above(function(x) return 560 end)
local farm = trail * below(function(x) return 560 end)
work(near, {hand="body", pile=FM, tool="filbert 9", angle=-0.45, angle_jitter=0.2, length={20,60}, load=0.6, coverage=2.6, fill=true, clip=trail:soften(4) * FLOORM, seed=191})
work(farm, {hand="body", pile=FD, tool="filbert 12", angle=-0.45, angle_jitter=0.2, length={30,80}, load=0.6, coverage=2.6, fill=true, clip=trail:soften(4) * FLOORM, seed=192})
-- cloth: a darker, larger folded shape over the old blob
CRB = pile{{"rose madder",1},{"Mars red",0.6},{"Mars brown",0.6},{"bone black",0.45}}
CLOTH = outline{{676,566,"c"},{700,548},{742,541},{770,546,"c"},{800,553},{790,568},{772,580,"c"},{745,594},{712,592,"c"},{690,584}, char="soft", seed=12}
work(CLOTH:mask(), {hand="body", pile=CRB, tool="filbert 5", angle=0.15, coverage=3, fill=true, clip=true, seed=193})

--@ chunk 26
CRV = pile{{"rose madder",0.6},{"Mars brown",0.8},{"bone black",1.0},{"ultramarine blue",0.2}}
CRR = pile{{"Mars red",1},{"rose madder",0.5},{"vermilion",0.3},{"lead white",0.35},{"raw sienna",0.2}}
local m = CLOTH:mask()
local v = brush{kind="filbert", width=4}
local r = brush{kind="filbert", width=3.5}
local folds = {
  {{684,568},{705,560},{730,556},{752,560}},
  {{700,585},{722,577},{748,572},{776,570}},
  {{712,552},{738,549},{768,551},{792,557}},
  {{742,592},{760,582},{778,575}},
}
for i,f in ipairs(folds) do
  v:reload(CRV, 0.65); v:stroke(f, {pressure={0.6,0.15}, clip=m})
  local up = {}
  for _,p in ipairs(f) do up[#up+1] = {p[1]+1.5, p[2]-4.5} end
  r:reload(CRR, 0.55); r:stroke(up, {pressure={0.45,0.1}, clip=m})
end

--@ chunk 27
print(wait(3*24*60), drying(400,540), drying(740,566))
FUR = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"bone brown",0.6}}
LIPD = pile{{"lead white",1.3},{"bone brown",0.4},{"bone black",0.35},{"ultramarine ash",0.4}}
local fb = brush{kind="round", width=3.6, point=0.6}
local lb = brush{kind="round", width=1.8, point=0.6}
local path = {{470,478},{430,505},{370,535},{300,570},{220,610},{130,650},{60,690}}
local function at(t)
  local n = #path - 1
  local f = t*n; local i = math.min(math.floor(f), n-1); local u = f - i
  local a, b = path[i+1], path[i+2]
  return a[1] + (b[1]-a[1])*u, a[2] + (b[2]-a[2])*u, math.atan(b[2]-a[2], b[1]-a[1])
end
local k = 0
for s=0.01,1,0.02 do
  local x, y, ang = at(s)
  local sc = 0.7 + s*1.2
  for leg=1,3 do
    k = k + 1
    local side = (k % 2 == 0) and 1 or -1
    local off = side*(8 + rand(0,22))*sc
    local px = x + math.cos(ang+math.pi/2)*off + rand(-4,4)*sc
    local py = y + math.sin(ang+math.pi/2)*off*0.45
    local a2 = ang + rand(-0.35,0.35)
    local L = rand(4,7)*sc
    local dx, dy = math.cos(a2)*L, math.sin(a2)*L*0.5
    if k % 6 == 1 then fb:reload(FUR, 0.6); lb:reload(LIPD, 0.5) end
    fb:stroke({{px-dx, py-dy},{px+dx, py+dy}}, {pressure={0.75,0.05}, ramps={0.05,0.6}})
    lb:stroke({{px-dx*0.9, py-dy*0.9-2.2*sc},{px+dx*0.7, py+dy*0.7-1.8*sc}}, {pressure={0.5,0.05}, ramps={0.1,0.5}})
  end
end
-- dust on the cloth
DST = pile{{"lead white",1.2},{"bone brown",0.5},{"bone black",0.4},{"ultramarine ash",0.3}}
local d = brush{kind="filbert", width=5}
for i=1,26 do
  local x, y = rand(690,790), rand(550,588)
  if CLOTH:mask():at(x,y) > 0.5 then
    d:reload(DST, 0.18)
    d:stroke({{x-6,y},{x+6,y+rand(-1,1)}}, {pressure={0.25,0.1}})
  end
end

--@ chunk 28
print(wait(2*24*60), drying(450,320), drying(500,440))
BC = pile{{"lead white",2},{"yellow ochre",0.35},{"raw sienna",0.12},{"bone black",0.22},{"ultramarine blue",0.08}}
BSH = pile{{"lead white",1},{"yellow ochre",0.3},{"raw umber" == nil and "raw sienna" or "raw sienna",0.3},{"bone black",0.55},{"ultramarine blue",0.25}}
BHI = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.15},{"yellow ochre",0.1}}
local ribs = {
  {{452,356},{438,330},{434,306},{442,288},{455,280}},
  {{466,354},{458,326},{458,302},{466,288}},
  {{548,356},{561,331},{567,307},{560,290},{546,281}},
  {{534,354},{543,327},{544,304},{537,290}},
}
local body = brush{kind="filbert", width=7, stiffness=0.6}
local sh = brush{kind="filbert", width=3.5, stiffness=0.6}
local hi = brush{kind="round", width=1.8, point=0.6}
for k,pts in ipairs(ribs) do
  local dir = (k<=2) and 1 or -1
  body:reload(BC, 0.7); body:stroke(pts, {pressure={0.85,0.2}, ramps={0.1,0.5}, orient="across"})
  local s1, s2 = {}, {}
  for _,p in ipairs(pts) do s1[#s1+1] = {p[1]+dir*2.6, p[2]+0.5}; s2[#s2+1] = {p[1]-dir*1.9, p[2]-0.8} end
  sh:reload(BSH, 0.7); sh:stroke(s1, {pressure={0.75,0.15}})
  hi:reload(BHI, 0.6); hi:stroke(s2, {pressure={0.5,0.05}})
end
-- basin: cool top band, shadowed belly, cold reflected rim at the bottom
local b = brush{kind="filbert", width=5, stiffness=0.6}
for k=0,2 do b:reload(BC, 0.6); b:stroke({{446+k*3, 358+k*2.5},{500, 361.5+k*2.5},{554-k*3, 358+k*2.5}}, {pressure={0.55,0.45}}) end
for k=0,2 do b:reload(BSH, 0.65); b:stroke({{458+k*6, 370+k*3},{500, 375+k*2.5},{542-k*6, 370+k*3}}, {pressure={0.55,0.45}}) end
hi:reload(BHI, 0.6); hi:stroke({{442,349.5},{470,346.8},{500,346.2},{530,346.8},{558,349.5}}, {pressure={0.5,0.4}})
-- plinth: lit top lip, contact shadow at the foot, a cool vertical edge on each corner
PLL = pile{{"Mars brown",1},{"raw sienna",0.6},{"lead white",0.35},{"ultramarine ash",0.3}}
work(rect(394,414,212,6), {hand="detail", pile=PLL, tool={kind="round", width=2.5}, angle=0, ruler=true, coverage=2.5, fill=true, clip=true, seed=201})
work(rect(392,458,216,14), {hand="body", pile=PLD, tool="filbert 5", angle=0, load=0.5, coverage=1.6, clip=true, seed=202})
work(rect(426,381,148,4), {hand="detail", pile=PLL, tool={kind="round", width=2}, angle=0, ruler=true, coverage=2.5, fill=true, clip=true, seed=203})
-- the few surviving lamps among the scales
local lb = brush{kind="round", width=3, point=0.3}
for _,p in ipairs({{214,64},{263,47},{611,28},{702,58},{158,121},{846,106}}) do
  lb:reload(LAMPW, 0.6); lb:touch(p[1], p[2], {pressure=0.55})
end

--@ chunk 29
COL2 = pile{{"lead white",0.8},{"bone black",0.9},{"ultramarine blue",0.35},{"cerulean blue",0.15}}
work(rect(394,414,212,6), {hand="detail", pile=COL2, tool={kind="round", width=2.5}, angle=0, ruler=true, coverage=2.5, fill=true, clip=true, seed=211})
work(rect(426,381,148,4), {hand="detail", pile=COL2, tool={kind="round", width=2}, angle=0, ruler=true, coverage=2.5, fill=true, clip=true, seed=212})

--@ chunk 30
print(wait(2*24*60), drying(740,566))
local m = CLOTH:mask()
work(m, {hand="body", pile=CRV, tool="filbert 4", angle=0.15, angle_jitter=0.2, length={8,22}, load=0.35, coverage=0.9, pressure={0.3,0.55}, clip=m:soften(1.5), seed=221})
