-- easel session "ark_dawn": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=9113,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",2},{"raw sienna",1.2},{"bone brown",0.8},{"lead white",0.5}, medium=0.45}, um=24, apply="brush"},
  }}
print(W, H)

--@ chunk 2
-- shapes
SPH = ellipse(-230, 560, 560, 660)
DRUM = rect(735, 330, 300, 620) + ellipse(950, 330, 215, 85)
FLOORC = {{0,900},{120,840},{280,790},{460,770},{640,780},{800,800},{1000,850}}
FL = below(FLOORC) - SPH - DRUM
BACK = everywhere() - SPH - DRUM - FL
BEAMP = {{560,-10},{900,-10},{650,1015},{235,1000}}
-- piles
dDeep  = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}}
dBack  = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
dBronze = pile{{"bone brown",2},{"burnt sienna",1.2},{"bone black",0.6}}
dFloor = pile{{"burnt sienna",1.5},{"bone brown",1.5},{"raw sienna",0.6},{"bone black",0.5}}
local function ang_sph(x,y) return math.atan(y-560, x+230) + math.pi/2 end
work(BACK, {hand="broad", pile=dBack, coverage=2.6, fill=true, angle=1.4, angle_jitter=0.4})
work(SPH, {hand="broad", pile=dBronze, coverage=2.6, fill=true, angle=ang_sph, clip=SPH:grow(3)})
work(DRUM, {hand="broad", pile=dBronze, coverage=2.6, fill=true, angle=math.pi/2, clip=DRUM:grow(3)})
work(FL, {hand="broad", pile=dFloor, coverage=2.6, fill=true, angle=0.15, angle_jitter=0.5})

--@ chunk 3
print(wait(2*24*60))
eDeep  = pile{{"bone black",3},{"burnt sienna",1},{"ultramarine blue",0.4}}
eBronze = pile{{"bone black",2},{"burnt sienna",1.5},{"raw sienna",0.4}}
eFloor = pile{{"bone black",1.5},{"burnt sienna",1.5},{"raw sienna",0.5}}
local function ang_sph(x,y) return math.atan(y-560, x+230) + math.pi/2 end
local beamzone = poly(BEAMP):grow(60):soften(60)
work(BACK - poly(BEAMP):grow(20), {hand="broad", pile=eDeep, coverage=3, fill=true, angle=1.45, angle_jitter=0.3})
work(SPH, {hand="broad", pile=eBronze, coverage=3, fill=true, angle=ang_sph, clip=SPH:grow(2)})
work(DRUM, {hand="broad", pile=eBronze, coverage=3, fill=true, angle=math.pi/2, clip=DRUM:grow(2)})
work(FL - poly(BEAMP):grow(10), {hand="broad", pile=eFloor, coverage=3, fill=true, angle=0.15, angle_jitter=0.5})

--@ chunk 4
-- the beam, laid as body colour along its fall; core lighter; then blended along the light
BA = math.atan(1005, -290)
BEAM = poly(BEAMP)
CORE = poly({{640,-10},{830,-10},{560,1005},{330,995}})
POOL = ellipse(440, 1000, 210, 72)
gMid  = pile{{"raw sienna",1},{"Mars orange",0.6},{"lead white",1.2},{"yellow ochre",0.6}}
gLit  = pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.4}}
gHot  = pile{{"lead white",3},{"lemon chrome",0.3},{"cadmium yellow",0.3}}
work(BEAM - CORE, {hand="broad", pile=gMid, coverage=2.4, fill=true, angle=BA, angle_jitter=0.15, clip=BEAM:soften(8)})
work(CORE, {hand="broad", pile=gLit, coverage=2.4, fill=true, angle=BA, angle_jitter=0.12, clip=CORE:soften(10)})
local top = ellipse(760, -20, 210, 150)
work(top, {hand="body", pile=gHot, coverage=2.5, fill=true, angle=BA, clip=top:soften(20)})
work(POOL, {hand="body", pile=gLit, coverage=2.4, fill=true, angle=0.05, clip=POOL:soften(14)})
blend(BEAM:grow(6), {angle=BA})

--@ chunk 5
-- the beam is a column of paint, not light: darken and dissolve its flanks into the air while it is wet
vDark = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.5}, medium=0.7}
local inner = (BEAM - BEAM:shrink(38)) - POOL:grow(10)
work(inner, {hand="glaze", pile=vDark, coverage=1.6, fill=true, angle=BA, clip=inner:soften(12)})
local band = (BEAM:grow(30) - BEAM:shrink(45)) - POOL:grow(20)
blend(band:soften(10), {angle=BA})
blend(band:soften(10), {angle=BA + 0.5})

--@ chunk 6
print(wait(24*60))
-- bronze catching the spill: the sphere's flank toward the beam, the drum's edge; scale-plates only suggested
bLit  = pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",0.8},{"bone brown",0.4}}
bGold = pile{{"raw sienna",2},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.6}}
rimG  = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.4}}
local function ang_sph(x,y) return math.atan(y-560, x+230) + math.pi/2 end
local sflank = SPH - ellipse(-280, 560, 560, 660)
work(sflank, {hand="scumble", pile=bLit, coverage=1.2, angle=ang_sph, clip=SPH})
local sflank2 = SPH - ellipse(-245, 560, 560, 660)
work(sflank2, {hand="body", pile=bGold, coverage=1.6, fill=true, angle=ang_sph, clip=SPH})
-- plates on the sphere: short curved strokes in rows that follow the dome
local b = brush("filbert", 9)
local n = 0
for row = 1, 14 do
  local r = 300 + row * 18
  for k = 1, 22 do
    local a = -1.2 + k * 0.11 + (row % 2) * 0.055
    local x, y = -230 + math.cos(a) * r * 1.0 * (560/560), 560 + math.sin(a) * r * (660/560)
    if SPH:shrink(4):at(x, y) > 0.5 then
      local light = clamp((x - 120) / 200, 0, 1)
      if n % 4 == 0 then b:reload(light > 0.5 and bGold or bLit, 0.5) end
      n = n + 1
      local ta = a + math.pi/2
      local hl = 9
      b:stroke({{x - math.cos(ta)*hl, y - math.sin(ta)*hl}, {x + math.cos(a)*2, y + math.sin(a)*2}, {x + math.cos(ta)*hl, y + math.sin(ta)*hl}},
        {pressure={0.25 + 0.4*light, 0.1}, ramps={0.2, 0.5}, clip=SPH})
    end
  end
end
-- drum: its edge toward the beam, and banded plates
local dl = DRUM * rect(735, 0, 40, 1333)
work(dl, {hand="body", pile=bGold, coverage=1.6, fill=true, angle=math.pi/2, clip=DRUM})
local rb = brush{kind="round", width=2.2, point=0.6}
rb:load(rimG, 0.6)
rb:stroke({{737, 345}, {738, 600}, {740, 880}}, {pressure={0.6, 0.15}, ramps={0.05, 0.6}})
rb:load(rimG, 0.6)
local top = {}
for x = 737, 1000, 10 do top[#top+1] = {x, 330 - 85*math.sqrt(math.max(0, 1 - ((x-950)/215)^2))} end
rb:stroke(top, {pressure={0.55, 0.05}, ramps={0.05, 0.8}})
print(n)

--@ chunk 7
-- knock the bronze back: fade the crescent at top and bottom, soften it into the dark, melt the plate dots into a surface
local function ang_sph(x,y) return math.atan(y-560, x+230) + math.pi/2 end
local cres = SPH - ellipse(-290, 560, 560, 660)
local ends = cres * (rect(0, -10, 400, 330) + rect(0, 820, 400, 600))
work(ends, {hand="body", pile=eBronze, coverage=2.2, fill=true, angle=ang_sph, clip=SPH,
  load_at=function(x, y) return 0.3 + 0.6 * math.max(smoothstep(330, 120, y), smoothstep(820, 1050, y)) end})
blend(SPH, {angle=ang_sph})
blend(cres:grow(8), {angle=function(x,y) return ang_sph(x,y) + 0.4 end})
local dl = DRUM * rect(735, 0, 70, 1333)
work(DRUM * rect(735, 700, 60, 400), {hand="body", pile=eBronze, coverage=2, fill=true, angle=math.pi/2, clip=DRUM})
blend(dl, {angle=0.0})

--@ chunk 8
print(wait(2*24*60))
-- repaint the tanks dark and opaque; keep only a narrow crescent of light on the sphere's flank toward the beam
local function ang_sph(x,y) return math.atan(y-560, x+230) + math.pi/2 end
local keep = (SPH - ellipse(-252, 560, 560, 660)) * ellipse(330, 560, 140, 300)
local dark = SPH - keep
work(dark, {hand="broad", pile=eBronze, coverage=3.2, fill=true, angle=ang_sph, clip=SPH})
local inner = SPH:shrink(90)
work(inner, {hand="broad", pile=eDeep, coverage=2.6, fill=true, angle=ang_sph, clip=inner:soften(40)})
local dk = DRUM - (DRUM * rect(735, 330, 14, 420))
work(dk, {hand="broad", pile=eBronze, coverage=3.2, fill=true, angle=math.pi/2, clip=DRUM})
local din = DRUM * rect(800, 0, 300, 1333)
work(din, {hand="broad", pile=eDeep, coverage=2.4, fill=true, angle=math.pi/2, clip=din:soften(30)})

--@ chunk 9
-- the floor from above: heaped rubble, lit where the pool spills, dark further off; the pool's rim broken by stones
rDeep = pile{{"bone black",2},{"burnt sienna",1}}
rWarm = pile{{"burnt sienna",1.5},{"raw sienna",1},{"bone black",0.6},{"lead white",0.2}}
rLit  = pile{{"yellow ochre",1},{"raw sienna",1},{"lead white",0.8}}
rHot  = pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.3}}
local floor = FL + POOL
local B = {}
local function bb(w) local k = math.floor(w + 0.5); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
local n = 0
for i = 1, 900 do
  local x, y = rand(0, 1000), rand(770, 1333)
  if floor:at(x, y) > 0.5 then
    local dx, dy = (x - 440) / 260, (y - 1000) / 110
    local d = math.sqrt(dx*dx + dy*dy)
    local L = clamp(1.25 - d + randn(0, 0.12), 0, 1)
    local s = lerp(6, 18, smoothstep(770, 1333, y)) * rand(0.6, 1.4)
    local inPool = POOL:shrink(14):at(x, y) > 0.5
    if not (inPool and math.random() < 0.75) then
      local p = (L > 0.8) and rHot or ((L > 0.55) and rLit or ((L > 0.25) and rWarm or rDeep))
      local b = bb(s * 0.6)
      if n % 3 == 0 or b.lastp ~= p then b:reload(p, 0.6) end
      n = n + 1
      local a = rand(-0.5, 0.5)
      b:stroke({{x - math.cos(a)*s*0.4, y - math.sin(a)*s*0.4}, {x + math.cos(a)*s*0.4, y + math.sin(a)*s*0.4}},
        {pressure={0.75, 0.6}, ramps={0.1, 0.2}, orient=a + math.pi/2 + rand(-0.4, 0.4)})
    end
  end
end
print(n)

--@ chunk 10
-- where the beam reaches the floor the rubble is in full light: lit stones over the dark specks
local zone = (BEAM:grow(10) * rect(0, 760, 1000, 600)) + POOL:grow(25)
local B = {}
local function bb(w) local k = math.floor(w + 0.5); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
local n = 0
for i = 1, 1400 do
  local x, y = rand(150, 720), rand(740, 1090)
  if zone:at(x, y) > 0.5 then
    local core = CORE:at(x, y)
    local s = lerp(5, 12, smoothstep(760, 1080, y)) * rand(0.6, 1.4)
    local p = (core > 0.5 or POOL:at(x, y) > 0.5) and ((math.random() < 0.6) and rHot or gHot) or ((math.random() < 0.6) and rLit or gMid)
    local b = bb(s * 0.65)
    if n % 3 == 0 then b:reload(p, 0.6) end
    n = n + 1
    local a = rand(-0.5, 0.5)
    b:stroke({{x - math.cos(a)*s*0.45, y - math.sin(a)*s*0.45}, {x + math.cos(a)*s*0.45, y + math.sin(a)*s*0.45}},
      {pressure={0.75, 0.6}, ramps={0.1, 0.2}, orient=a + math.pi/2 + rand(-0.4, 0.4)})
  end
end
print(n)

--@ chunk 11
print(wait(24*60))
-- light in the air: warm low-load veils spreading off the beam (strongest near the oculus and the pool), and one over the beam to warm it
veilA = pile{{"lead white",1},{"Mars orange",0.8},{"cadmium yellow",0.6}, medium=0.85}
veilT = pile{{"lead white",1},{"Indian yellow",0.6},{"Mars orange",0.3}, medium=0.85}
local halo = (BEAM:grow(140) - BEAM:shrink(10)) - SPH - DRUM
work(halo, {hand="glaze", pile=veilA, coverage=1.6, fill=true, angle=BA, clip=halo:soften(60),
  pressure={0.12, 0.25},
  load_at=function(x, y) return 0.12 + 0.3 * math.max(smoothstep(500, 0, y), smoothstep(700, 1000, y)) end})
work(BEAM, {hand="glaze", pile=veilT, coverage=1.4, fill=true, angle=BA, clip=BEAM:soften(20), pressure={0.15, 0.3}, load=0.35})

--@ chunk 12
-- melt the veils into haze while they are wet
local z = (BEAM:grow(170) - SPH:shrink(2) - DRUM:shrink(2)) * rect(0, -10, 1000, 1110)
blend(z, {angle=BA})
blend(z, {angle=BA + 1.2})

--@ chunk 13
print(wait(2*24*60))
-- warm the grey haze with a transparent orange-earth glaze (no white), and break its hard lower edge with floor rubble
gWarm = pile{{"Mars orange",1},{"raw sienna",1},{"Indian yellow",0.4}, medium=0.8}
local z = (BEAM:grow(170) - BEAM:shrink(20) - SPH - DRUM) * rect(0, -10, 1000, 1110)
work(z, {hand="glaze", pile=gWarm, coverage=1.6, fill=true, angle=BA, clip=z:soften(10), pressure={0.2, 0.4}, load=0.5})
local B = {}
local function bb(w) local k = math.floor(w + 0.5); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
local n = 0
for i = 1, 700 do
  local x, y = rand(0, 1000), rand(1030, 1180)
  if POOL:grow(18):at(x, y) < 0.5 and SPH:at(x, y) < 0.5 then
    local d = math.sqrt(((x - 440)/300)^2 + ((y - 1000)/150)^2)
    local p = (d < 1.0) and ((math.random() < 0.5) and rLit or rWarm) or ((math.random() < 0.6) and rDeep or rWarm)
    local s = rand(7, 16)
    local b = bb(s * 0.65)
    if n % 3 == 0 then b:reload(p, 0.65) end
    n = n + 1
    local a = rand(-0.5, 0.5)
    b:stroke({{x - math.cos(a)*s*0.45, y - math.sin(a)*s*0.45}, {x + math.cos(a)*s*0.45, y + math.sin(a)*s*0.45}},
      {pressure={0.8, 0.65}, ramps={0.1, 0.2}, orient=a + math.pi/2 + rand(-0.4, 0.4)})
  end
end
print(n)

--@ chunk 14
print(wait(24*60))
-- take the dark back: the air beyond a narrow glow is the cavern again
local dark = ((BEAM:grow(220) - BEAM:grow(42)) - SPH - DRUM) * rect(0, -10, 1000, 1045)
work(dark, {hand="broad", pile=eDeep, coverage=3, fill=true, angle=BA, clip=dark:soften(14)})
local dz = DRUM * (BEAM:grow(200) - BEAM:grow(10))
work(dz, {hand="broad", pile=eBronze, coverage=3, fill=true, angle=math.pi/2, clip=DRUM})
-- the glow band just outside the beam: a deep warm, not grey
gGlow = pile{{"burnt sienna",1},{"Mars orange",0.8},{"raw sienna",0.6},{"bone black",0.3}}
local glow = ((BEAM:grow(44) - BEAM:shrink(4)) - SPH - DRUM) * rect(0, -10, 1000, 990)
work(glow, {hand="body", pile=gGlow, coverage=2.4, fill=true, angle=BA, clip=glow:soften(6)})

--@ chunk 15
-- melt the orange band into the dark on the outside (both wet), a narrow seam only
local seam = ((BEAM:grow(75) - BEAM:shrink(2)) - SPH:shrink(4) - DRUM:shrink(4)) * rect(0, -10, 1000, 1000)
blend(seam:soften(12), {angle=BA})
blend(seam:soften(12), {angle=BA - 1.4})

--@ chunk 16
-- rays: long strokes down the fall of the light, gold over the grey flanks, hot in the core; carried down into the pool
local b = brush("filbert", 14)
local c = brush("filbert", 8)
local n = 0
for i = 1, 70 do
  local u = rand(-1, 1)
  local t0 = rand(0, 0.5); local t1 = math.min(1.04, t0 + rand(0.35, 0.7))
  local function at(t, u) 
    local lx, rx = lerp(560, 235, t), lerp(900, 650, t)
    local ly, ry = lerp(-10, 1000, t), lerp(-10, 1015, t)
    local f = (u + 1) / 2
    return {lerp(lx, rx, f), lerp(ly, ry, f)}
  end
  local edge = math.abs(u) > 0.7
  local p = edge and gMid or ((math.abs(u) < 0.35 and math.random() < 0.6) and gHot or gLit)
  local br = (math.random() < 0.5) and b or c
  br:reload(p, 0.55)
  br:stroke({at(t0, u), at((t0 + t1)/2, u + randn(0, 0.03)), at(t1, u + randn(0, 0.03))},
    {pressure={0.35, 0.55}, ramps={0.3, 0.4}, orient="along", clip=BEAM:grow(4) + POOL})
  n = n + 1
end
-- the pool: hot stones again at its heart
local B = {}
local function bb(w) local k = math.floor(w + 0.5); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
for i = 1, 400 do
  local x, y = randn(440, 110), randn(1005, 30)
  if POOL:grow(10):at(x, y) > 0.5 then
    local s = rand(5, 11)
    local d = math.sqrt(((x - 440)/210)^2 + ((y - 1005)/72)^2)
    local p = (d < 0.55) and rHot or ((math.random() < 0.5) and rLit or rHot)
    local br = bb(s * 0.65)
    if i % 3 == 0 then br:reload(p, 0.6) end
    local a = rand(-0.5, 0.5)
    br:stroke({{x - math.cos(a)*s*0.45, y - math.sin(a)*s*0.45}, {x + math.cos(a)*s*0.45, y + math.sin(a)*s*0.45}},
      {pressure={0.75, 0.6}, ramps={0.1, 0.2}, orient=a + math.pi/2 + rand(-0.4, 0.4)})
  end
end
print(n)

--@ chunk 17
-- the Ark and PALMER, tiny, at the heart of the pool; seen from high behind
local fx, fy = 452, 1012
local shadowP = pile{{"bone black",2},{"burnt sienna",1}}
local arkP = pile{{"lead white",3},{"cerulean blue",0.25},{"bone black",0.1}}
local arkS = pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.6}}
local frameP = pile{{"bone black",2},{"bone brown",1}}
local rimP2 = pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}
local s = brush("flat", 5)
-- cast shadows, down-left along the light
s:load(shadowP, 0.7)
s:stroke({{fx - 36, fy + 4}, {fx - 52, fy + 9}}, {pressure={0.7, 0.4}})
s:stroke({{fx + 2, fy + 3}, {fx - 12, fy + 10}}, {pressure={0.7, 0.3}})
-- the capsule: a pale rounded box, shadow side below
local a = brush("filbert", 5)
a:load(arkS, 0.7)
a:stroke({{fx - 44, fy + 1}, {fx - 22, fy + 0.5}}, {pressure={0.8, 0.8}})
a:load(arkP, 0.7)
a:stroke({{fx - 44, fy - 2}, {fx - 22, fy - 2.6}}, {pressure={0.6, 0.6}})
local r = brush{kind="round", width=1.0, point=0.8}
r:load(pile{{"vermilion",1},{"lead white",0.6}}, 0.5)
r:stroke({{fx - 37, fy - 4}, {fx - 37, fy + 2}}, {pressure={0.5, 0.5}})
-- the kneeling frame: back to us, head bowed toward the box, one arm reaching
local f = brush{kind="round", width=3.2, point=0.4}
f:load(frameP, 0.8)
f:stroke({{fx - 4, fy - 14}, {fx - 3, fy - 7}, {fx - 1, fy}}, {pressure={0.9, 0.7}})       -- back/torso
f:stroke({{fx - 1, fy - 1}, {fx + 6, fy + 1}}, {pressure={0.8, 0.6}})                      -- folded leg
f:stroke({{fx - 4, fy - 11}, {fx - 12, fy - 6}, {fx - 20, fy - 3}}, {pressure={0.6, 0.4}})  -- reaching arm
local h = brush{kind="round", width=3.6, point=0.2}
h:load(frameP, 0.8)
h:touch(fx - 7, fy - 16, {pressure=0.8})                                                   -- head
-- rim from the light above
r:load(rimP2, 0.55)
r:stroke({{fx - 9, fy - 18.5}, {fx - 5, fy - 18}}, {pressure={0.45, 0.2}})
r:stroke({{fx - 2.5, fy - 14}, {fx - 1.5, fy - 7}}, {pressure={0.4, 0.15}})
r:stroke({{fx - 11, fy - 7.8}, {fx - 19, fy - 4.6}}, {pressure={0.3, 0.1}})
-- the one cold point: the readout
local cy = brush{kind="round", width=1.3, point=0.6}
cy:load(pile{{"cerulean blue",1},{"zinc white",1.5},{"emerald green",0.2}}, 0.6)
cy:touch(fx - 25, fy - 2, {pressure=0.6})

--@ chunk 18
print(wait(12*60))
local fx, fy = 452, 1012
local frameP = pile{{"bone black",2},{"bone brown",1}}
local shadowP = pile{{"bone black",1.5},{"burnt sienna",1},{"raw sienna",0.4}}
-- a darker bed of shadowed stones under them so the pale box and dark figure both read
local s = brush("flat", 7)
s:load(shadowP, 0.7)
s:stroke({{fx - 52, fy + 5}, {fx - 30, fy + 6}, {fx - 8, fy + 6}, {fx + 10, fy + 5}}, {pressure={0.8, 0.5}, ramps={0.2, 0.3}})
s:load(shadowP, 0.6)
s:stroke({{fx - 60, fy + 10}, {fx - 34, fy + 12}}, {pressure={0.6, 0.2}})
-- the frame, broader: bowed back, haunch, reaching arm, head
local f = brush("filbert", 6)
f:load(frameP, 0.85)
f:stroke({{fx - 6, fy - 16}, {fx - 3, fy - 8}, {fx + 1, fy + 1}}, {pressure={0.9, 0.9}})
f:stroke({{fx - 1, fy - 1}, {fx + 8, fy + 2}}, {pressure={0.8, 0.7}})
local g = brush("filbert", 3.5)
g:load(frameP, 0.85)
g:stroke({{fx - 6, fy - 12}, {fx - 13, fy - 7}, {fx - 21, fy - 3.5}}, {pressure={0.8, 0.5}})
local h = brush{kind="round", width=5, point=0.1}
h:load(frameP, 0.85)
h:touch(fx - 9, fy - 19, {pressure=0.9})
-- the box: brighter, cooler top, with its dark underside
local a = brush("filbert", 7)
a:load(pile{{"lead white",3},{"cerulean blue",0.3},{"bone black",0.08}}, 0.7)
a:stroke({{fx - 46, fy - 3}, {fx - 23, fy - 4}}, {pressure={0.75, 0.75}})
local r = brush{kind="round", width=1.2, point=0.8}
r:load(pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}, 0.55)
r:stroke({{fx - 12, fy - 22.5}, {fx - 6, fy - 21.5}}, {pressure={0.5, 0.2}})
r:stroke({{fx - 3.5, fy - 16}, {fx - 0.5, fy - 7}}, {pressure={0.45, 0.15}})
r:load(pile{{"vermilion",1},{"lead white",0.5}}, 0.5)
r:stroke({{fx - 38, fy - 6.5}, {fx - 38, fy - 0.5}}, {pressure={0.55, 0.55}})
local cy = brush{kind="round", width=1.6, point=0.6}
cy:load(pile{{"cerulean blue",1},{"zinc white",1.5},{"emerald green",0.2}}, 0.6)
cy:touch(fx - 27, fy - 3, {pressure=0.7})

--@ chunk 19
-- finishing: drum patch knocked back, far galleries as tiny warm apertures, rims on the tanks, motes in the light
local dp = DRUM * rect(735, 300, 75, 330)
work(dp, {hand="body", pile=eBronze, coverage=2.6, fill=true, angle=math.pi/2, clip=DRUM})
-- galleries: a ring of small lit openings on the far wall, seen in the dark between the tanks and the light
local apP = pile{{"Mars orange",1},{"raw sienna",1},{"lead white",0.5}}
local apD = pile{{"burnt sienna",1},{"bone black",0.6},{"raw sienna",0.4}}
local ap = brush("flat", 4)
local ln = brush{kind="round", width=1.6, point=0.5}
for _, row in ipairs({{y=150, x0=180, x1=420, dx=24}, {y=330, x0=175, x1=330, dx=22}, {y=80, x0=905, x1=1000, dx=22}, {y=230, x0=915, x1=1000, dx=22}}) do
  ln:load(apD, 0.6)
  ln:stroke({{row.x0 - 6, row.y + 9}, {row.x1 + 6, row.y + 9 + (row.x1 - row.x0)*0.04}}, {pressure={0.5, 0.4}})
  local x = row.x0
  local k = 0
  while x < row.x1 do
    local y = row.y + (x - row.x0) * 0.04
    if BEAM:grow(40):at(x, y) < 0.5 and SPH:at(x, y) < 0.5 and DRUM:at(x, y) < 0.5 then
      if k % 4 == 0 then ap:load(apP, 0.6) end
      ap:stroke({{x, y - 3}, {x, y + 4}}, {pressure={0.6, 0.6}})
      k = k + 1
    end
    x = x + row.dx
  end
end
-- rims where the tanks turn toward the light
local rimG2 = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.4}}
local rb = brush{kind="round", width=2.0, point=0.7}
rb:load(rimG2, 0.6)
local pts = {}
for y = 330, 820, 30 do
  local u = (y - 560) / 660
  pts[#pts+1] = {-230 + 560 * math.sqrt(math.max(0, 1 - u*u)) - 2, y}
end
rb:stroke(pts, {pressure={0.15, 0.55}, swell={0.4, 1, 0.5}, ramps={0.4, 0.4}})
rb:load(rimG2, 0.6)
rb:stroke({{738, 640}, {738, 760}, {739, 900}}, {pressure={0.45, 0.05}, ramps={0.1, 0.7}})
-- motes
local mote = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.12}}
local m = brush{kind="round", width=2.2, point=0.6}
local n = 0
for i = 1, 140 do
  local x, y = rand(230, 900), rand(0, 980)
  if CORE:grow(20):at(x, y) > 0.5 then
    if n % 8 == 0 then m:load(mote, 0.55) end
    m:touch(x, y, {pressure=rand(0.2, 0.5)})
    n = n + 1
  end
end
print(n)

--@ chunk 20
print(wait(24*60))
-- mend the spill above the drum's shoulder with the light's own colour; restate the drum's lit lip
local spill = (rect(715, 240, 110, 110) - DRUM) * BEAM:grow(60)
work(spill, {hand="body", pile=gGlow, coverage=2.4, fill=true, angle=BA, clip=true})
local rb = brush{kind="round", width=2.2, point=0.6}
rb:load(pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.4}}, 0.6)
local top = {}
for x = 737, 1000, 8 do top[#top+1] = {x, 330 - 85*math.sqrt(math.max(0, 1 - ((x-950)/215)^2))} end
rb:stroke(top, {pressure={0.6, 0.05}, ramps={0.05, 0.75}})
-- the grey band below the pool: warm shadowed rubble over it
local B = {}
local function bb(w) local k = math.floor(w + 0.5); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
local n = 0
for i = 1, 600 do
  local x, y = rand(60, 760), rand(1035, 1120)
  if POOL:grow(6):at(x, y) < 0.5 and SPH:at(x, y) < 0.5 then
    local d = math.sqrt(((x - 440)/280)^2 + ((y - 1005)/120)^2)
    local p = (d < 0.9 and math.random() < 0.5) and rLit or ((math.random() < 0.55) and rWarm or rDeep)
    local s = rand(7, 15)
    local b = bb(s * 0.65)
    if n % 3 == 0 then b:reload(p, 0.65) end
    n = n + 1
    local a = rand(-0.5, 0.5)
    b:stroke({{x - math.cos(a)*s*0.45, y - math.sin(a)*s*0.45}, {x + math.cos(a)*s*0.45, y + math.sin(a)*s*0.45}},
      {pressure={0.8, 0.65}, ramps={0.1, 0.2}, orient=a + math.pi/2 + rand(-0.4, 0.4)})
  end
end
print(n)

--@ chunk 21
-- dissolve the square patch while wet
local z = (rect(700, 225, 150, 150) - DRUM:shrink(2)):soften(18)
blend(z, {angle=BA})
blend(z, {angle=BA + 1.3})

--@ chunk 22
print(wait(18*60))
-- lay the light back over the smudge: ray strokes in the beam's own golds, stopping at the drum
local z = (rect(690, 200, 140, 190) - DRUM:grow(1))
local b = brush("filbert", 10)
for i = 1, 26 do
  local x0 = rand(705, 830); local y0 = rand(170, 230)
  local L = rand(140, 220)
  b:reload((math.random() < 0.55) and gLit or gMid, 0.6)
  b:stroke({{x0, y0}, {x0 + math.cos(BA)*L*0.5, y0 + math.sin(BA)*L*0.5}, {x0 + math.cos(BA)*L, y0 + math.sin(BA)*L}},
    {pressure={0.55, 0.6}, ramps={0.2, 0.3}, orient="along", clip=z})
end
