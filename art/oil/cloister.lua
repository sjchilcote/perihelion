-- easel session "cloister": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=4/3, linen=14, seed=909,
  ground={{pile={{"lead white",1},{"raw sienna",1},{"burnt sienna",0.5},{"bone brown",0.3}}, um=60, apply="knife", texture=0.4}}}
-- near arcade: pillars and arch openings
PIL = {{40,130},{388,452},{640,700},{930,1000}}   -- x ranges (uneven: handmade)
OPEN = nil
local spans = {{130,388},{452,640},{700,930}}
for _,s in ipairs(spans) do
  local cx = (s[1]+s[2])/2; local r = (s[2]-s[1])/2
  local springline = 300 - (r-100)*0.4
  local o = rect(s[1], springline, s[2]-s[1], 520-springline) + ellipse(cx, springline, r, r*0.95)
  OPEN = OPEN and (OPEN + o) or o
end
PARA = rect(0, 500, 1000, 62) * OPEN:grow(30)   -- low parapet seen within/below openings
FLOOR = rect(0, 560, 1000, 200)
print(H)

--@ chunk 2
GLOW = pile{{"lead white",2.2},{"yellow ochre",0.8},{"cadmium yellow",0.35},{"Mars orange",0.15}}
AIR  = pile{{"lead white",1},{"raw sienna",1},{"burnt sienna",0.4},{"bone brown",0.5}}
FARW = pile{{"raw sienna",1.4},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.6},{"bone brown",0.4}}
GARTH = pile{{"yellow ochre",1},{"viridian",0.35},{"lead white",1},{"raw sienna",0.5}}
local big = OPEN:grow(12)
local sky = big * rect(0,0,1000,268)
local halo = ellipse(545, 215, 150, 120):soften(40)
work(sky - halo, {hand="body", tool="filbert 12", pile=AIR, coverage=2.6, fill=true, clip=true, angle=0.3})
work(sky * halo, {hand="body", tool="filbert 12", pile=GLOW, coverage=2.6, fill=true, clip=true, angle=function(x,y) return math.atan(y-215, x-545)+math.pi/2 end})
local far = big * rect(0,262,1000,184)
work(far, {hand="body", tool="filbert 10", pile=FARW, coverage=2.6, fill=true, clip=true, angle=math.pi/2})
local g = big * rect(0,440,1000,130)
work(g, {hand="body", tool="filbert 10", pile=GARTH, coverage=2.6, fill=true, clip=true, angle=0})

--@ chunk 3
DARK = pile{{"bone brown",2},{"burnt sienna",0.6},{"ultramarine blue",0.35},{"bone black",0.3}}
DARK2 = pile{{"bone brown",1.6},{"raw sienna",0.8},{"burnt sienna",0.4},{"ultramarine blue",0.2}}
DARKF = pile{{"bone brown",1.5},{"raw sienna",1},{"burnt sienna",0.4},{"bone black",0.2}}
POOL = pile{{"raw sienna",1.2},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}
local wall = rect(0,0,1000,562) - OPEN
local upper = wall * rect(0,0,1000,330)
work(upper, {hand="body", tool="filbert 12", pile=DARK, coverage=2.8, fill=true, clip=true, angle=0})
work(wall - upper, {hand="body", tool="filbert 12", pile=DARK2, coverage=2.8, fill=true, clip=true, angle=math.pi/2})
-- floor: light pools thrown through the three arches, in perspective toward the viewer
local pools = poly({{150,562},{380,562},{360,750},{40,750}}) + poly({{462,562},{630,562},{700,750},{430,750}}) + poly({{712,562},{920,562},{1000,690},{1000,750},{800,750}})
pools = pools:roughen(10, 60, 5):soften(12)
work(FLOOR - pools, {hand="body", tool="filbert 12", pile=DARKF, coverage=2.8, fill=true, clip=true, angle=0})
work(FLOOR * pools, {hand="body", tool="filbert 12", pile=POOL, coverage=2.6, fill=true, clip=true, angle=0})

--@ chunk 4
print(wait(240))
local big = OPEN:grow(12)
FARD = pile{{"bone brown",1.4},{"burnt sienna",0.6},{"raw sienna",0.5},{"lead white",0.15}}
CORN = pile{{"raw sienna",1},{"bone brown",0.8},{"burnt sienna",0.4},{"lead white",0.3}}
-- cornice of the far arcade
work(big * rect(0,262,1000,22), {hand="body", tool="flat 6", pile=CORN, coverage=2.5, fill=true, clip=true, angle=0})
-- far arches: dark openings, uneven spacing and widths
local xs = {96,158,226,288,352,410,470,528,590,650,708,770,832,890}
local fa = nil
for i,x in ipairs(xs) do
  local w = rand(30,40); local sp = 340 + rand(-6,6)
  local a = rect(x, sp, w, 440-sp) + ellipse(x+w/2, sp, w/2, w/2*0.95)
  fa = fa and (fa+a) or a
end
FA = fa
work(big * fa, {hand="body", tool="filbert 5", pile=FARD, coverage=2.6, fill=true, clip=true, angle=math.pi/2, length={10,40}})

--@ chunk 5
print(wait(300))
local big = OPEN:grow(12)
VAULT = pile{{"bone brown",1.2},{"burnt sienna",0.6},{"raw sienna",0.5},{"lead white",0.35},{"cobalt violet",0.2}}
MIDAIR = pile{{"raw sienna",1},{"lead white",1},{"burnt sienna",0.3},{"yellow ochre",0.4}}
local sky = big * rect(0,0,1000,262)
local d = function(x,y) return math.sqrt((x-545)^2 + ((y-215)*1.2)^2) end
local inner = mask(function(x,y) return d(x,y) < 95 and 1 or 0 end):soften(15)
local mid = mask(function(x,y) local r = d(x,y); return (r >= 95 and r < 200) and 1 or 0 end):soften(15)
local outer = mask(function(x,y) return d(x,y) >= 200 and 1 or 0 end):soften(15)
work(sky * outer, {hand="body", tool="filbert 10", pile=VAULT, coverage=2.6, fill=true, clip=true, angle=function(x,y) return math.atan(y-215, x-545)+math.pi/2 end})
work(sky * mid, {hand="body", tool="filbert 10", pile=MIDAIR, coverage=2.6, fill=true, clip=true, angle=function(x,y) return math.atan(y-215, x-545)+math.pi/2 end})
work(sky * inner, {hand="body", tool="filbert 10", pile=GLOW, coverage=2.6, fill=true, clip=true, angle=function(x,y) return math.atan(y-215, x-545)+math.pi/2 end})
blend(sky:shrink(3), {angle=0.4})
-- garth ground: light falls off toward us, shadow of the far arcade along its base
GSHAD = pile{{"yellow ochre",0.8},{"viridian",0.4},{"raw sienna",0.8},{"lead white",0.5},{"bone brown",0.3}}
work(big * rect(0,440,1000,22), {hand="body", tool="filbert 6", pile=GSHAD, coverage=2.4, fill=true, clip=true, angle=0})

--@ chunk 6
print(wait(240))
local wall = rect(0,0,1000,562) - OPEN:grow(14)
WALLD = pile{{"bone brown",1.8},{"burnt sienna",0.7},{"raw sienna",0.5},{"ultramarine blue",0.25},{"bone black",0.2}}
local n = noise{seed=3, period=220}
work(wall, {hand="body", tool="filbert 12", pile=WALLD, coverage=3, fill=true, clip=true, angle=function(x,y) return y < 330 and 0.1 or math.pi/2 end, length={30,90}})
REVEAL = pile{{"raw sienna",1.2},{"burnt sienna",0.6},{"yellow ochre",0.5},{"bone brown",0.6},{"lead white",0.2}}
local rev = OPEN:grow(14) - OPEN
work(rev, {hand="body", tool="filbert 5", pile=REVEAL, coverage=2.6, fill=true, clip=true, length={10,40}})

--@ chunk 7
print(wait(1440))
CORE = pile{{"zinc white",3},{"lemon chrome",0.25}}
HALO = pile{{"lead white",2},{"cadmium yellow",0.3},{"yellow ochre",0.3}, medium=0.4}
local cx, cy = 546, 296
local halo = ellipse(cx, cy, 70, 64):soften(30) * OPEN
work(halo, {hand="glaze", tool="filbert 10", pile=HALO, coverage=1.4, load=0.3, pressure={0.15,0.3}, clip=true, angle=function(x,y) return math.atan(y-cy, x-cx)+math.pi/2 end})
blend(ellipse(cx, cy, 72, 66) * OPEN:shrink(2), {angle=0.5})
work(ellipse(cx, cy, 15, 15), {hand="detail", pile=CORE, coverage=4, fill=true, clip=true})
-- the cord it hangs from, up into the dark
local cord = brush{kind="rigger", width=1.6, point=0.8}
cord:load(pile{{"bone brown",1},{"raw sienna",0.5}}, 0.6)
cord:stroke({{cx+0.5, 200},{cx, 250},{cx, cy-16}}, {pressure={0.4,0.5}})

--@ chunk 8
local cx, cy = 546, 296
local ann = (ellipse(cx, cy, 92, 86) - ellipse(cx, cy, 45, 42)) * OPEN:shrink(2)
blend(ann, {angle=function(x,y) return math.atan(y-cy, x-cx)+math.pi/2 end})
blend(ann, {angle=function(x,y) return math.atan(y-cy, x-cx) end})

--@ chunk 9
print(wait(2880))
SEAMD = pile{{"bone brown",1.5},{"burnt sienna",0.5},{"bone black",0.3}}
local vx, vy = 546, 420
local pen = brush{kind="round", width=3, point=0.3}
-- floor seams: courses (horizontal) and runs toward the vanishing point
for _,y in ipairs({577, 598, 626, 664, 716}) do
  pen:reload(SEAMD, 0.6); pen:stroke({{0,y+rand(-1,1)},{500,y+rand(-1,1)},{1000,y+rand(-1,1)}}, {pressure={0.5,0.5}, shake=0.4})
end
for _,X in ipairs({-700,-380,-90,150,370,590,810,1040,1300,1620}) do
  local t0 = (562 - vy) / (750 - vy)
  local x0 = vx + (X - vx) * t0
  pen:reload(SEAMD, 0.6); pen:stroke({{x0, 562},{X, 750}}, {pressure={0.35,0.65}, shake=0.4})
end
-- frieze of fold-notation over the arches, in worn bone
BONEP = pile{{"lead white",1.6},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone brown",0.25}}
local fp = brush{kind="round", width=3.2, point=0.3}
local GA = 2.39996323
local cxs = {70, 175, 300, 410, 520, 640, 745, 860, 955}
local prev = nil
for i,cx in ipairs(cxs) do
  local cy = 85 + rand(-6,6)
  local n = ({3,4,5,6,4,5,3,6,5})[i]
  local rx, ry = rand(28,40), rand(22,32)
  local turn = (i % 3 == 0) and 0 or (i*GA % (2*math.pi))
  local function glyph(sx, sy, s, rot)
    local v = {}
    for k=0,n-1 do local a = rot + k*2*math.pi/n - math.pi/2; v[#v+1] = {cx + sx*s*math.cos(a), cy + sy*s*math.sin(a)} end
    for k=1,n do local a, b = v[k], v[k%n+1]; fp:load(BONEP, 0.5); fp:stroke({{a[1],a[2]},{b[1],b[2]}}, {pressure={0.5,0.45}, shake=0.5}) end
    return v
  end
  local v = glyph(rx, ry, 1, 0)
  glyph(rx, ry, 0.618, turn)
  if i % 2 == 1 then glyph(rx, ry, 0.382, 2*turn) end
  -- bridge arc to the previous glyph
  if prev then
    local a = {prev[1]+prev[3], prev[2]}; local b = {cx - rx, cy}
    fp:load(BONEP, 0.45)
    fp:stroke({{a[1],a[2]+4},{(a[1]+b[1])/2, cy + 34 + rand(-4,4)},{b[1],b[2]+4}}, {pressure={0.35,0.35}})
  end
  prev = {cx, cy, rx}
end

--@ chunk 10
POOL2 = pile{{"raw sienna",1},{"bone brown",0.7},{"yellow ochre",0.5},{"burnt sienna",0.3},{"lead white",0.2}}
local pools = poly({{150,562},{380,562},{360,750},{40,750}}) + poly({{462,562},{630,562},{700,750},{430,750}}) + poly({{712,562},{920,562},{1000,690},{1000,750},{800,750}})
-- dim the pools more toward the viewer (light falls off away from the arches)
work(pools * rect(0,600,1000,150), {hand="body", tool="filbert 12", pile=POOL2, coverage=1.6, clip=pools:grow(6), angle=0, load=0.6, length={40,120}})
-- garden in the garth: a spiral of low plantings and a basin, seen flattened
local big = OPEN
PLANT = pile{{"viridian",0.8},{"raw sienna",0.8},{"bone brown",0.6},{"yellow ochre",0.4}}
PLANTL = pile{{"viridian",0.4},{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.3}}
local GA = 2.39996323
local tuft = brush("filbert", 7)
local cnt = 0
for k=1,140 do
  local r = 20*math.sqrt(k); local a = k*GA
  local x = 546 + r*math.cos(a)*1.6; local y = 487 + r*math.sin(a)*0.2
  if y > 455 and y < 518 and big:at(x,y) > 0.5 then
    if cnt % 6 == 0 then tuft:reload(PLANT, 0.6) end
    tuft:touch(x, y, {pressure=0.45 + 0.15*(y-455)/60, drag={4,0}})
    cnt = cnt + 1
  end
end
local hl = brush("round", 3)
cnt = 0
for k=1,140,2 do
  local r = 20*math.sqrt(k); local a = k*GA
  local x = 546 + r*math.cos(a)*1.6; local y = 487 + r*math.sin(a)*0.2 - 3
  if y > 455 and y < 518 and big:at(x,y) > 0.5 then
    if cnt % 8 == 0 then hl:reload(PLANTL, 0.6) end
    hl:touch(x, y, {pressure=0.5}); cnt = cnt + 1
  end
end
-- basin rim in the middle bay
local BONEW = pile{{"lead white",1.5},{"yellow ochre",0.6},{"raw sienna",0.3}}
local rim = brush{kind="round", width=3.5, point=0.2}
local pts = {}
for k=0,24 do local a = k/24*2*math.pi; pts[#pts+1] = {546 + 30*math.cos(a), 492 + 6*math.sin(a)} end
rim:load(BONEW, 0.8); rim:stroke(pts, {pressure={0.5,0.5}})
-- a few warm lamps in the far arcade
LAMP = pile{{"lead white",1.5},{"cadmium yellow",0.6},{"Mars orange",0.2}}
local lp = brush("round", 5)
for _,q in ipairs({{176,395},{360,400},{500,398},{720,396},{850,402}}) do
  if OPEN:at(q[1],q[2]) > 0.5 then lp:reload(LAMP, 0.7); lp:touch(q[1], q[2], {pressure=0.5}) end
end

--@ chunk 11
local pools = poly({{150,562},{380,562},{360,750},{40,750}}) + poly({{462,562},{630,562},{700,750},{430,750}}) + poly({{712,562},{920,562},{1000,690},{1000,750},{800,750}})
blend(pools * rect(0,595,1000,160), {angle=0})
-- the Commando's niche on the left pillar: a small arched recess, warm-lit by a lamp
NICHE = pile{{"bone brown",1.4},{"burnt sienna",0.7},{"bone black",0.25}}
local nm = rect(64, 360, 40, 70) + ellipse(84, 360, 20, 20)
work(nm, {hand="detail", pile=NICHE, coverage=3.5, fill=true, clip=true})

--@ chunk 12
print(wait(1440))
-- warm glow inside the niche (low load white-orange glaze) then the scrap cross
NGLOW = pile{{"lead white",1.5},{"cadmium yellow",0.4},{"Mars orange",0.4}, medium=0.4}
work(ellipse(84, 418, 18, 30) * (rect(64, 360, 40, 70) + ellipse(84, 360, 20, 20)), {hand="detail", pile=NGLOW, coverage=1.5, load=0.35, clip=true})
SCRAP = pile{{"lead white",0.9},{"bone black",0.5},{"raw sienna",0.4},{"burnt sienna",0.2}}
local b = brush("flat", 4)
b:load(SCRAP, 0.8); b:stroke({{84.5,370},{84,392},{83.5,418}}, {pressure={0.7,0.7}})
b:load(SCRAP, 0.8); b:stroke({{73,385},{84,384.5},{95,386}}, {pressure={0.7,0.7}})
local hl = brush{kind="round", width=1.5, point=0.5}
hl:load(pile{{"lead white",1.5},{"yellow ochre",0.5},{"Mars orange",0.2}}, 0.6)
hl:stroke({{86.5,388},{86,404},{85.5,417}}, {pressure={0.5,0.4}})
-- a small flame at its foot
local fl = brush("round", 4); fl:load(pile{{"zinc white",2},{"lemon chrome",0.4},{"Mars orange",0.1}}, 0.8)
fl:touch(84, 424, {pressure=0.6, drag={0,-4}})
-- the bedroll in the cleared corner
ROLL = pile{{"bone black",0.6},{"viridian",0.25},{"raw sienna",0.7},{"lead white",0.5}}
ROLLD = pile{{"bone black",0.8},{"bone brown",0.6},{"viridian",0.15}}
local roll = ribbon({{22,700},{150,676}}, 30)
work(roll, {hand="body", tool="filbert 8", pile=ROLLD, coverage=3, fill=true, clip=true, angle=-0.18, length={20,50}})
work(ribbon({{26,692},{146,668}}, 12), {hand="body", tool="filbert 6", pile=ROLL, coverage=2, clip=true, angle=-0.18, length={20,50}})
local tie = brush("flat", 3); tie:load(pile{{"raw sienna",1},{"bone brown",0.5},{"lead white",0.2}}, 0.7)
for _,x in ipairs({55,118}) do local y = 700 - (x-22)*24/128; tie:stroke({{x-3,y-15},{x+3,y+15}}, {pressure={0.6,0.6}}) end

--@ chunk 13
local niche = rect(64, 360, 40, 70) + ellipse(84, 360, 20, 20)
local cross = ribbon({{84.5,370},{83.5,418}}, 5) + ribbon({{73,385},{95,386}}, 5)
NWARM = pile{{"lead white",1},{"yellow ochre",0.6},{"Mars orange",0.35},{"burnt sienna",0.35}}
NMID = pile{{"burnt sienna",1},{"Mars orange",0.3},{"bone brown",0.6},{"lead white",0.3}}
local low = ellipse(84, 425, 17, 26):soften(5)
work((niche - cross) * low, {hand="detail", pile=NWARM, coverage=3, fill=true, clip=true})
work((niche - cross) * rect(60,385,50,22) - low, {hand="detail", pile=NMID, coverage=2, fill=true, clip=true})
local fl = brush("round", 5); fl:load(pile{{"zinc white",2},{"lemon chrome",0.4},{"Mars orange",0.1}}, 0.9)
fl:touch(84, 424, {pressure=0.7, drag={0,-5}})

--@ chunk 14
print(wait(1440))
AIRG = pile{{"lead white",2},{"Mars orange",0.25},{"yellow ochre",0.3}, medium=0.5}
local m = OPEN:shrink(2) * rect(0,262,1000,200) - ellipse(546,296,20,20)
work(m, {hand="glaze", tool="filbert 14", pile=AIRG, coverage=1.0, load=0.22, pressure={0.1,0.22}, clip=true, angle=0.2, length={60,150}})
blend(m, {angle=0.2})

--@ chunk 15
print(drying(240, 300))
local m = OPEN:shrink(2) * rect(0,262,1000,200) - ellipse(546,296,20,20)
blend(m, {angle=1.4})
blend(m, {angle=0.6})

--@ chunk 16
print(wait(600))
FARD2 = pile{{"bone brown",1},{"burnt sienna",0.6},{"raw sienna",0.6},{"lead white",0.35}}
work(FA:shrink(1.5) * OPEN:shrink(2), {hand="body", tool="filbert 5", pile=FARD2, coverage=2.8, fill=true, clip=true, angle=math.pi/2, length={15,45}})
local lp = brush("round", 8)
for _,q in ipairs({{176,410},{500,405},{720,408},{850,412},{290,415}}) do
  if OPEN:at(q[1],q[2]) > 0.5 and FA:at(q[1],q[2]) > 0.5 then
    lp:reload(LAMP, 0.8); lp:touch(q[1], q[2], {pressure=0.6})
  end
end

--@ chunk 17
print(wait(2880))
local lp = brush("round", 7)
for _,q in ipairs({{176,410},{500,405},{720,408},{850,412},{290,415}}) do
  if FA:at(q[1],q[2]) > 0.5 and OPEN:at(q[1],q[2]) > 0.5 then lp:reload(LAMP, 0.9); lp:touch(q[1], q[2], {pressure=0.65}) end
end
-- warm light catching the inner edge of each near arch, strongest on the middle bay
RIM = pile{{"lead white",1},{"yellow ochre",0.8},{"raw sienna",0.5},{"Mars orange",0.15}}
local rb = brush{kind="round", width=3, point=0.3}
local spans = {{130,388},{452,640},{700,930}}
for i,s in ipairs(spans) do
  local cx = (s[1]+s[2])/2; local r = (s[2]-s[1])/2
  local sp = 300 - (r-100)*0.4
  local pts = {}
  for k=0,20 do local a = math.pi + k/20*math.pi; pts[#pts+1] = {cx + (r+2)*math.cos(a), sp + (r+2)*0.95*math.sin(a)} end
  rb:reload(RIM, i==2 and 0.8 or 0.55)
  rb:stroke(pts, {pressure={0.35, 0.35}, swell={0.6,1.2,0.6}})
end

--@ chunk 18
RIB = pile{{"bone brown",1.4},{"raw sienna",0.8},{"burnt sienna",0.5},{"lead white",0.15}}
RIBL = pile{{"raw sienna",1.2},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.45}}
CELL = pile{{"bone brown",1.6},{"burnt sienna",0.5},{"ultramarine blue",0.35},{"bone black",0.35}}
local vx, vy = 546, 420
local ribs = nil
local lits = nil
for _,px in ipairs({85, 420, 672, 965}) do
  local y0 = 160
  local dx, dy = px - vx, y0 - vy
  local L = math.sqrt(dx*dx + dy*dy); dx, dy = dx/L, dy/L
  local pts, ws, lpts = {}, {}, {}
  for k=0,10 do
    local t = k/10 * 420
    local bow = 18*math.sin(k/10*math.pi)
    local x = px + dx*t - dy*bow*(px<vx and 1 or -1)
    local y = y0 + dy*t
    pts[#pts+1] = {x, y}; ws[#ws+1] = 16 + 34*k/10
    lpts[#lpts+1] = {x + (px<vx and 1 or -1)*(5 + 12*k/10), y + 4 + 6*k/10}
  end
  local r = ribbon(pts, ws); ribs = ribs and (ribs + r) or r
  local l = ribbon(lpts, 5); lits = lits and (lits + l) or l
end
-- darken the vault cells between ribs, above the frieze line
local cells = rect(0,0,1000,42) - ribs
work(cells, {hand="body", tool="filbert 10", pile=CELL, coverage=2.5, fill=true, clip=true, angle=0.2})
work(ribs, {hand="body", tool="filbert 8", pile=RIB, coverage=3, fill=true, clip=true, length={20,60}})
work(lits * ribs, {hand="detail", pile=RIBL, coverage=3, fill=true, clip=true})
RIBS = ribs

--@ chunk 19
local vx, vy = 546, 420
local ribs, lits, shads = nil, nil, nil
for _,px in ipairs({85, 420, 672, 965}) do
  local y0 = 165
  local dx, dy = px - vx, y0 - vy
  local L = math.sqrt(dx*dx + dy*dy); dx, dy = dx/L, dy/L
  local s = (px<vx and 1 or -1)
  local pts, ws, lpts, spts = {}, {}, {}, {}
  for k=0,10 do
    local t = k/10 * 420
    local bow = 22*math.sin(k/10*math.pi)
    local x = px + dx*t - dy*bow*s
    local y = y0 + dy*t
    local w = 34 + 80*k/10
    pts[#pts+1] = {x, y}; ws[#ws+1] = w
    lpts[#lpts+1] = {x + s*w*0.36, y + w*0.12}
    spts[#spts+1] = {x - s*w*0.36, y - w*0.1}
  end
  local r = ribbon(pts, ws); ribs = ribs and (ribs + r) or r
  local l = ribbon(lpts, 7); lits = lits and (lits + l) or l
  local sh = ribbon(spts, 9); shads = shads and (shads + sh) or sh
end
work(ribs, {hand="body", tool="filbert 10", pile=RIB, coverage=3, fill=true, clip=true, length={20,70}})
work(lits * ribs, {hand="body", tool="filbert 4", pile=RIBL, coverage=3, fill=true, clip=true, length={20,60}})
work(shads * ribs, {hand="body", tool="filbert 4", pile=CELL, coverage=3, fill=true, clip=true, length={20,60}})
RIBS = ribs

--@ chunk 20
local O = OPEN:shrink(1)
GSH = pile{{"raw sienna",1},{"viridian",0.35},{"bone brown",0.6},{"yellow ochre",0.5},{"lead white",0.3}}
GLIT = pile{{"yellow ochre",1},{"lead white",1},{"cadmium yellow",0.2},{"viridian",0.1}}
-- shade along the foot of the far arcade, value step back to front
work(O * rect(0,440,1000,24):soften(4), {hand="body", tool="filbert 8", pile=GSH, coverage=2.6, fill=true, clip=true, angle=0})
-- the light of the hanging sun on the garth
work(O * ellipse(546, 492, 150, 22):soften(10), {hand="body", tool="filbert 8", pile=GLIT, coverage=2.2, fill=true, clip=true, angle=0})
-- plantings: clumps on a golden-angle spiral, larger toward us
local GA = 2.39996323
local cl = brush("filbert", 10)
local tp = brush("filbert", 5)
local n = 0
for k=1,90 do
  local r = 22*math.sqrt(k); local a = k*GA
  local x = 546 + r*math.cos(a)*1.7; local y = 490 + r*math.sin(a)*0.22
  local dd = math.abs(x-546)/1.7
  if y > 462 and y < 516 and O:at(x,y) > 0.5 and math.sqrt(((x-546)/1.7)^2 + ((y-490)/0.22)^2) > 50 then
    local s = 0.35 + 0.5*(y-462)/54
    if n % 5 == 0 then cl:reload(PLANT, 0.7) end
    cl:touch(x, y, {pressure=s, drag={6*s,0}})
    n = n + 1
  end
end

--@ chunk 21
print(wait(1440))
local O = OPEN:shrink(1)
local GA = 2.39996323
local cl = brush("filbert", 18)
local tp = brush("filbert", 9)
PLANTL2 = pile{{"viridian",0.35},{"yellow ochre",1},{"lead white",0.6},{"cadmium yellow",0.15}}
local spots = {}
for k=1,70 do
  local r = 26*math.sqrt(k); local a = k*GA
  local x = 546 + r*math.cos(a)*1.8; local y = 490 + r*math.sin(a)*0.2
  if y > 466 and y < 514 and O:at(x,y) > 0.5 and math.abs(x-546) > 55 then spots[#spots+1] = {x,y} end
end
for i,p in ipairs(spots) do
  local s = 0.45 + 0.5*(p[2]-466)/48
  if i % 4 == 1 then cl:reload(PLANT, 0.8) end
  cl:touch(p[1], p[2], {pressure=s, drag={8*s,0}})
end
for i,p in ipairs(spots) do
  local s = 0.4 + 0.4*(p[2]-466)/48
  if i % 5 == 1 then tp:reload(PLANTL2, 0.7) end
  tp:touch(p[1]-2, p[2]-3*s-1, {pressure=s, drag={5*s,0}})
end
-- the well: a bone stone ring with dark water catching the small sun
WELLD = pile{{"bone brown",1},{"ultramarine blue",0.3},{"bone black",0.3},{"lead white",0.2}}
WELLF = pile{{"lead white",1.2},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone brown",0.2}}
WELLS = pile{{"lead white",0.8},{"raw sienna",0.6},{"bone brown",0.5},{"yellow ochre",0.3}}
local outer = ellipse(546, 486, 40, 9)
local front = (rect(506, 486, 80, 16) + ellipse(546, 502, 40, 9)) - outer
work(front, {hand="detail", pile=WELLS, coverage=3.5, fill=true, clip=true})
work(outer, {hand="detail", pile=WELLF, coverage=3.5, fill=true, clip=true})
work(ellipse(546, 486, 31, 6), {hand="detail", pile=WELLD, coverage=3.5, fill=true, clip=true})

--@ chunk 22
local O = OPEN:shrink(1)
local cl = brush("filbert", 16)
local tp = brush("filbert", 8)
local spots = {}
local GA = 2.39996323
for k=1,400 do
  local x = 140 + (k*GA*97) % 790; local y = 468 + (k*0.618*53) % 46
  if O:at(x,y) > 0.5 and not (math.abs(x-546) < 60 and y > 474) and #spots < 46 then spots[#spots+1] = {x,y} end
end
for i,p in ipairs(spots) do
  local s = 0.4 + 0.5*(p[2]-468)/46
  if i % 4 == 1 then cl:reload(PLANT, 0.8) end
  cl:touch(p[1], p[2], {pressure=s, drag={7*s,0}})
end
-- shade under the far arcade's own vault, a value step back
CSH = pile{{"bone brown",1},{"raw sienna",0.7},{"burnt sienna",0.4},{"lead white",0.35}}
work(O * rect(0,284,1000,16) - FA, {hand="body", tool="filbert 6", pile=CSH, coverage=2.5, fill=true, clip=true, angle=0})
-- contact shade under the well's lip
work(ellipse(546, 507, 46, 6) - ellipse(546, 502, 40, 9), {hand="detail", pile=GSH, coverage=3, fill=true, clip=true})

--@ chunk 23
print(wait(1440))
local O = OPEN:shrink(1)
-- the sun that isn't the Sun: restate the core, give it a hot centre and a bronze armillary ring
work(ellipse(546, 296, 16, 16), {hand="detail", pile=CORE, coverage=4, fill=true, clip=true})
local HOT = pile{{"zinc white",3},{"lemon chrome",0.1}}
local d = brush("round", 9); d:load(HOT, 0.9); d:touch(544, 293, {pressure=0.7})
local ring = brush{kind="round", width=2.6, point=0.3}
local RINGP = pile{{"raw sienna",1},{"burnt sienna",0.5},{"yellow ochre",0.6},{"lead white",0.3}}
local pts = {}
for k=0,30 do local a = k/30*2*math.pi; local x = 26*math.cos(a); local y = 8*math.sin(a)
  pts[#pts+1] = {546 + x*math.cos(-0.35) - y*math.sin(-0.35), 296 + x*math.sin(-0.35) + y*math.cos(-0.35)} end
ring:load(RINGP, 0.8); ring:stroke(pts, {pressure={0.5,0.5}})
-- sun in the well's water
local rf = brush("round", 6); rf:load(HOT, 0.8); rf:touch(546, 485, {pressure=0.5, drag={6,0}})
-- lit tops on the plantings
local tp = brush("filbert", 8)
local GA = 2.39996323
local n = 0
for k=1,400 do
  local x = 140 + (k*GA*97) % 790; local y = 468 + (k*0.618*53) % 46
  if O:at(x,y) > 0.5 and not (math.abs(x-546) < 60 and y > 474) and n < 46 then
    local s = 0.4 + 0.5*(y-468)/46
    if n % 5 == 0 then tp:reload(PLANTL2, 0.7) end
    tp:touch(x - 2, y - 3*s - 1, {pressure=s*0.8, drag={5*s,0}})
    n = n + 1
  end
end

--@ chunk 24
local HOT = pile{{"zinc white",3},{"lemon chrome",0.12}}
local d = brush("round", 12); d:load(HOT, 0.9); d:touch(546, 296, {pressure=0.75}); d:load(HOT, 0.9); d:touch(543, 292, {pressure=0.6})
local halo = (ellipse(546, 296, 62, 58) - ellipse(546, 296, 17, 17)) * OPEN:shrink(2)
stipple(halo, {pile=GLOW, width=4, coverage=function(x,y) local r = math.sqrt((x-546)^2+(y-296)^2); return math.max(0, 1.3*(1 - (r-17)/45)) end, feather=0.8, pressure={0.2,0.45}, seed=11})

--@ chunk 25
print(wait(1440))
local pools = poly({{150,562},{380,562},{360,750},{40,750}}) + poly({{462,562},{630,562},{700,750},{430,750}}) + poly({{712,562},{920,562},{1000,690},{1000,750},{800,750}})
POOLA = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.7},{"burnt sienna",0.25}}
POOLB = pile{{"raw sienna",1},{"yellow ochre",0.6},{"bone brown",0.45},{"burnt sienna",0.3},{"lead white",0.35}}
POOLC = pile{{"raw sienna",1},{"bone brown",0.8},{"burnt sienna",0.35},{"yellow ochre",0.3},{"lead white",0.2}}
local near = rect(0,560,1000,52); local mid = rect(0,612,1000,60); local far = rect(0,672,1000,80)
work(pools * near, {hand="body", tool="filbert 10", pile=POOLA, coverage=3, fill=true, clip=true, angle=0, length={30,90}})
work(pools * mid,  {hand="body", tool="filbert 10", pile=POOLB, coverage=3, fill=true, clip=true, angle=0, length={30,90}})
work(pools * far,  {hand="body", tool="filbert 10", pile=POOLC, coverage=3, fill=true, clip=true, angle=0, length={30,90}})
blend(pools * (rect(0,600,1000,24) + rect(0,660,1000,24)), {angle=math.pi/2})

--@ chunk 26
print(wait(1440))
local vx, vy = 546, 420
local pen = brush{kind="round", width=3, point=0.3}
for _,y in ipairs({577, 598, 626, 664, 716}) do
  pen:reload(SEAMD, 0.6); pen:stroke({{0,y+rand(-1,1)},{500,y+rand(-1,1)},{1000,y+rand(-1,1)}}, {pressure={0.45,0.6}, shake=0.4})
end
for _,X in ipairs({-700,-380,-90,150,370,590,810,1040,1300,1620}) do
  local t0 = (562 - vy) / (750 - vy)
  local x0 = vx + (X - vx) * t0
  pen:reload(SEAMD, 0.6); pen:stroke({{x0, 562},{X, 750}}, {pressure={0.35,0.7}, shake=0.4})
end
-- bedroll, given form: shadow on the floor, dark body, lit top from the arches, end-spiral
local SHF = pile{{"bone brown",1.4},{"burnt sienna",0.4},{"bone black",0.3}}
work(ribbon({{30,712},{160,688}}, 30), {hand="body", tool="filbert 8", pile=SHF, coverage=3, fill=true, clip=true, angle=-0.18})
local ROLLM = pile{{"bone black",0.5},{"viridian",0.2},{"raw sienna",0.8},{"lead white",0.45}}
local ROLLT = pile{{"lead white",0.8},{"yellow ochre",0.5},{"raw sienna",0.5},{"viridian",0.1},{"bone black",0.15}}
work(ribbon({{24,698},{150,674}}, 30), {hand="body", tool="filbert 8", pile=ROLLD, coverage=3, fill=true, clip=true, angle=-0.18, length={20,50}})
work(ribbon({{26,690},{148,666}}, 14), {hand="body", tool="filbert 6", pile=ROLLM, coverage=3, fill=true, clip=true, angle=-0.18, length={20,50}})
work(ribbon({{30,686},{146,663}}, 5), {hand="detail", pile=ROLLT, coverage=3, fill=true, clip=true})
local tie = brush("flat", 3); tie:load(pile{{"raw sienna",1},{"bone brown",0.5},{"lead white",0.3}}, 0.8)
for _,x in ipairs({58,120}) do local y = 698 - (x-24)*24/126; tie:stroke({{x-3,y-15},{x+3,y+15}}, {pressure={0.6,0.6}}) end

--@ chunk 27
-- the niche: a sill, a lamp bowl with a flame, the cross's shadow and lit edge, warm spill on the pillar
local SILL = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.4},{"lead white",0.35}}
work(rect(58, 429, 52, 5), {hand="detail", pile=SILL, coverage=3.5, fill=true, clip=true})
work(rect(60, 434, 48, 4), {hand="detail", pile=NICHE, coverage=3, fill=true, clip=true})
local BOWL = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone brown",0.5},{"lead white",0.2}}
work(ellipse(84, 424, 9, 4.5) * rect(70, 422, 30, 10), {hand="detail", pile=BOWL, coverage=3.5, fill=true, clip=true})
local fl = brush{kind="round", width=4, point=0.8}
fl:load(pile{{"zinc white",2},{"lemon chrome",0.5},{"Mars orange",0.15}}, 0.9)
fl:stroke({{84,421},{84.5,416},{84,410}}, {pressure={0.8,0.05}})
-- cross shadow cast up-left on the niche back by the lamp, then lit edges
local CSHD = pile{{"bone brown",1.2},{"burnt sienna",0.6},{"bone black",0.2}}
local sb = brush("flat", 3); sb:load(CSHD, 0.7)
sb:stroke({{80,368},{79.5,392},{80,410}}, {pressure={0.6,0.6}})
local hl = brush{kind="round", width=1.6, point=0.5}
hl:load(pile{{"lead white",1.5},{"yellow ochre",0.5},{"Mars orange",0.3}}, 0.7)
hl:stroke({{86.5,372},{86.3,395},{86,412}}, {pressure={0.5,0.5}})
hl:load(pile{{"lead white",1.5},{"yellow ochre",0.5},{"Mars orange",0.3}}, 0.7)
hl:stroke({{74,388},{84,388},{95,389}}, {pressure={0.4,0.4}})
-- warm spill of lamplight on the pillar face around the niche
local spill = (ellipse(84, 410, 48, 55) - (rect(64, 360, 40, 70) + ellipse(84, 360, 20, 20)):grow(1)) - OPEN:grow(16)
stipple(spill, {pile=pile{{"burnt sienna",1},{"Mars orange",0.4},{"raw sienna",0.6},{"lead white",0.3}}, width=4, coverage=function(x,y) local r = math.sqrt((x-84)^2+(y-410)^2); return math.max(0, 0.9*(1 - r/50)) end, feather=0.8, pressure={0.2,0.4}, seed=5})
