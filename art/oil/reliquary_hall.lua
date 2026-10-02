-- easel session "reliquary_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=2718,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"bone brown",1},{"lead white",0.6}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
VP = {500, 560}
function at(x, y, s) return {VP[1] + (x - VP[1]) * s, VP[2] + (y - VP[2]) * s} end
FARS = 0.2
FAR = rect(392, 514, 216, 214) + ellipse(500, 514, 108, 96)
FLOORM = poly({{-60,1420},{1060,1420},{608,728},{392,728}})
LWALL = poly({{-60,322},{392,514},{392,728},{-60,1420}})
RWALL = poly({{1060,322},{608,514},{608,728},{1060,1420}})
VAULT = everywhere() - FLOORM - LWALL - RWALL - FAR
vDark = pile{{"bone black",2},{"burnt sienna",1.2},{"raw sienna",0.3}}
vMid  = pile{{"burnt sienna",1.5},{"bone black",1},{"raw sienna",0.8}}
wMid  = pile{{"burnt sienna",1.2},{"bone brown",1},{"raw sienna",0.6},{"bone black",0.4}}
fMid  = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8},{"lead white",0.25}}
farP  = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",1},{"lead white",0.2}}
local radial = function(x, y) return math.atan(y - VP[2], x - VP[1]) end
work(VAULT, {hand="broad", pile=vDark, coverage=2.8, fill=true, angle=function(x, y) return radial(x, y) + math.pi/2 end})
work(LWALL, {hand="broad", pile=wMid, coverage=2.6, fill=true, angle=radial, clip=LWALL:grow(2)})
work(RWALL, {hand="broad", pile=wMid, coverage=2.6, fill=true, angle=radial, clip=RWALL:grow(2)})
work(FLOORM, {hand="broad", pile=fMid, coverage=2.6, fill=true, angle=radial, clip=FLOORM:grow(2)})
work(FAR, {hand="body", pile=farP, coverage=2.6, fill=true, angle=math.pi/2, clip=FAR})

--@ chunk 3
print(wait(2*24*60))
-- lean second coats: everything a step darker, darkest at the near vault and the near wall bases
vDeep = pile{{"bone black",2.5},{"burnt sienna",1},{"ultramarine blue",0.3}}
wDark = pile{{"bone black",1.5},{"burnt sienna",1.2},{"raw sienna",0.4}}
fDark = pile{{"bone black",1},{"burnt sienna",1},{"raw sienna",0.6}}
local radial = function(x, y) return math.atan(y - VP[2], x - VP[1]) end
local function d(x, y) return math.sqrt((x - VP[1])^2 + (y - VP[2])^2) end
work(VAULT, {hand="broad", pile=vDeep, coverage=2.8, fill=true, angle=function(x, y) return radial(x, y) + math.pi/2 end,
  load_at=function(x, y) return 0.45 + 0.4 * smoothstep(150, 500, d(x, y)) end})
work(LWALL, {hand="broad", pile=wDark, coverage=2.6, fill=true, angle=radial, clip=LWALL:grow(2),
  load_at=function(x, y) return 0.35 + 0.5 * smoothstep(150, 600, d(x, y)) end})
work(RWALL, {hand="broad", pile=wDark, coverage=2.6, fill=true, angle=radial, clip=RWALL:grow(2),
  load_at=function(x, y) return 0.35 + 0.5 * smoothstep(150, 600, d(x, y)) end})
work(FLOORM, {hand="broad", pile=fDark, coverage=2.4, fill=true, angle=radial, clip=FLOORM:grow(2),
  load_at=function(x, y) return 0.3 + 0.45 * smoothstep(250, 800, d(x, y)) end})
work(FAR, {hand="body", pile=wDark, coverage=2.4, fill=true, angle=math.pi/2, clip=FAR})

--@ chunk 4
print(wait(2*24*60))
-- ribs of the barrel vault receding to the far bay; chapel openings in the walls between them
RIBS = {1.0, 0.78, 0.61, 0.48, 0.38, 0.30, 0.24}
ribP  = pile{{"bone black",1},{"burnt sienna",1},{"raw sienna",0.6}}
ribLit = pile{{"raw sienna",1.5},{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.3}}
chapP = pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.3}}
local function ribpts(s, shrink)
  local pts = {}
  local c = at(500, 322, s); local r = 560 * s * (shrink or 1)
  for k = 0, 36 do
    local a = math.pi + k * math.pi / 36
    pts[#pts+1] = {c[1] + math.cos(a) * r, c[2] + math.sin(a) * r}
  end
  return pts
end
-- chapels first (on walls), for each bay between ribs
local function wallpt(X, Y, s) return at(X, Y, s) end
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  local s1, s2 = lerp(sa, sb, 0.2), lerp(sa, sb, 0.8)
  for _, X in ipairs({-60, 1060}) do
    local pts = {}
    pts[#pts+1] = wallpt(X, 1420, s1)
    pts[#pts+1] = wallpt(X, 760, s1)
    for k = 1, 7 do
      local t = k / 8
      local s = lerp(s1, s2, t)
      local Y = 760 - 170 * math.sin(t * math.pi)
      pts[#pts+1] = wallpt(X, Y, s)
    end
    pts[#pts+1] = wallpt(X, 760, s2)
    pts[#pts+1] = wallpt(X, 1420, s2)
    local m = poly(pts) * (LWALL + RWALL)
    work(m, {hand="body", pile=chapP, coverage=2.6, fill=true, angle=math.pi/2, clip=m})
  end
end
local b = brush("filbert", 8)
local e = brush{kind="round", width=2.0, point=0.6}
for i, s in ipairs(RIBS) do
  local w = math.max(2, 22 * s)
  local br = brush("filbert", w)
  br:load(ribP, 0.8)
  local pts = ribpts(s, 1)
  br:stroke(pts, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across"})
  e:load(ribLit, 0.6)
  e:stroke(ribpts(s, 1 - 0.018), {pressure={0.35 + 0.3 * (1 - s), 0.35 + 0.3 * (1 - s)}, ramps={0.2, 0.2}})
end

--@ chunk 5
-- scale plates in the vault: short arcs laid in golden-angle drift between ribs, dim near, warmer toward the far bay
GA = math.pi * (3 - math.sqrt(5))
plDim = pile{{"burnt sienna",1.2},{"bone black",0.8},{"raw sienna",0.6}}
plLit = pile{{"raw sienna",1.5},{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.2}}
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("filbert", k) end; return B[k] end
local n = 0
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  local cnt = 70
  for k = 1, cnt do
    local s = lerp(sa, sb, ((k * 0.618) % 1) * 0.8 + 0.1)
    local a = math.pi + ((k * GA) % math.pi)
    local c = at(500, 322, s); local r = 560 * s
    local x, y = c[1] + math.cos(a) * r, c[2] + math.sin(a) * r
    if VAULT:at(x, y) > 0.5 then
      local w = 16 * s
      local lit = (1 - s) * 0.9 + 0.1
      local br = bb(w)
      if n % 3 == 0 then br:reload((lit > 0.55) and plLit or plDim, 0.55) end
      n = n + 1
      local ta = a + math.pi / 2
      local hl = 9 * s
      br:stroke({{x - math.cos(ta) * hl, y - math.sin(ta) * hl}, {x + math.cos(a) * 2 * s, y + math.sin(a) * 2 * s}, {x + math.cos(ta) * hl, y + math.sin(ta) * hl}},
        {pressure={0.55, 0.35}, ramps={0.15, 0.4}, clip=VAULT})
    end
  end
end
print(n)

--@ chunk 6
-- denser, larger plates so the vault reads as a scaled skin, not dots
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("filbert", k) end; return B[k] end
plShadow = pile{{"bone black",2},{"ultramarine blue",0.4}}
local sh = brush{kind="round", width=2, point=0.5}
local n = 0
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  for k = 1, 260 do
    local s = lerp(sa, sb, ((k * 0.618) % 1) * 0.86 + 0.07)
    local a = math.pi + ((k * GA * 0.5) % math.pi)
    local c = at(500, 322, s); local r = 560 * s
    local x, y = c[1] + math.cos(a) * r, c[2] + math.sin(a) * r
    if VAULT:at(x, y) > 0.5 then
      local lit = (1 - s) * 0.9 + 0.1 + 0.15 * math.sin(a * 3)
      local br = bb(30 * s)
      if n % 3 == 0 then br:reload((lit > 0.6) and plLit or plDim, 0.5); sh:reload(plShadow, 0.5) end
      n = n + 1
      local ta = a + math.pi / 2
      local hl = 17 * s
      br:stroke({{x - math.cos(ta) * hl, y - math.sin(ta) * hl}, {x + math.cos(a) * 3 * s, y + math.sin(a) * 3 * s}, {x + math.cos(ta) * hl, y + math.sin(ta) * hl}},
        {pressure={0.5, 0.4}, ramps={0.15, 0.4}, clip=VAULT})
      local o = -9 * s
      sh:stroke({{x - math.cos(ta) * hl + math.cos(a) * o, y - math.sin(ta) * hl + math.sin(a) * o}, {x + math.cos(a) * o * 1.3, y + math.sin(a) * o * 1.3}, {x + math.cos(ta) * hl + math.cos(a) * o, y + math.sin(ta) * hl + math.sin(a) * o}},
        {pressure={0.4, 0.1}, ramps={0.2, 0.4}, clip=VAULT})
    end
  end
end
print(n)

--@ chunk 7
-- the far bay: stepped dais, the tall casket, its single lens; shapes in mid-darks first
daisP = pile{{"raw sienna",1},{"burnt sienna",1},{"bone black",0.6},{"lead white",0.2}}
daisD = pile{{"bone black",1.5},{"burnt sienna",1}}
caskP = pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.5}}
boneP = pile{{"lead white",1.5},{"yellow ochre",0.8},{"raw sienna",0.3},{"bone black",0.15}}
for k = 0, 2 do
  local y0 = 690 + k * 13
  local hw = 58 + k * 18
  local tread = poly({{500 - hw, y0}, {500 + hw, y0}, {500 + hw + 6, y0 + 5}, {500 - hw - 6, y0 + 5}})
  local riser = rect(500 - hw - 6, y0 + 5, 2 * hw + 12, 8)
  work(tread, {hand="detail", pile=daisP, coverage=2.4, fill=true, angle=0, clip=true})
  work(riser, {hand="detail", pile=daisD, coverage=2.4, fill=true, angle=0, clip=true})
end
CASK = poly({{478,690},{478,585},{483,568},{500,552},{517,568},{522,585},{522,690}})
work(CASK, {hand="detail", pile=caskP, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
-- bone inlay panels
local pb = brush("flat", 3)
for _, seg in ipairs({{{484,600},{484,682}}, {{516,600},{516,682}}, {{487,640},{513,640}}}) do
  pb:load(boneP, 0.6); pb:stroke(seg, {pressure={0.6, 0.6}, ramps={0.05, 0.05}})
end
LENS = {500, 598}
local lb = brush{kind="round", width=7, point=0.1}
lb:load(daisD, 0.8); lb:touch(LENS[1], LENS[2], {pressure=0.9})

--@ chunk 8
print(wait(2*24*60))
-- darken the far wall so the casket can stand out against it; then the aperture and the shaft
local backw = FAR - CASK:grow(2) - rect(400, 686, 200, 50)
work(backw, {hand="body", pile=vDeep, coverage=2.6, fill=true, angle=math.pi/2, clip=backw})
APER = ellipse(436, 300, 22, 9)
SHAFT = poly({{416,300},{456,298},{548,700},{458,712}})
shGlare = pile{{"zinc white",3},{"lemon chrome",0.25},{"lead white",1}}
shVeil  = pile{{"lead white",1},{"Indian yellow",0.6},{"cadmium yellow",0.3}, medium=0.85}
shCore  = pile{{"lead white",2},{"cadmium yellow",0.5},{"Indian yellow",0.2}, medium=0.5}
work(APER, {hand="detail", pile=shGlare, coverage=2.6, fill=true, angle=0, clip=true})
local SA = math.atan(700 - 300, 503 - 436)
work(SHAFT, {hand="glaze", pile=shVeil, coverage=2.0, fill=true, angle=SA, clip=SHAFT:soften(4), load=0.5})
local core = poly({{428,300},{446,299},{520,702},{486,706}})
work(core, {hand="glaze", pile=shCore, coverage=1.6, fill=true, angle=SA, clip=core:soften(4), load=0.45})
blend(SHAFT:grow(6), {angle=SA})

--@ chunk 9
print(wait(4*24*60))
print(drying(470, 500), drying(500, 640))
-- warm the shaft (a transparent gold over the pale), then restate the casket standing in it, lit from the upper left
local SA = math.atan(400, 67)
gWarm = pile{{"Indian yellow",1},{"Mars orange",0.5},{"raw sienna",0.3}, medium=0.8}
work(SHAFT, {hand="glaze", pile=gWarm, coverage=1.4, fill=true, angle=SA, clip=SHAFT:soften(4), load=0.4})
caskLit = pile{{"raw sienna",1.5},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.4}}
caskHot = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.3}}
local left = CASK * rect(470, 540, 22, 160)
local right = CASK * rect(492, 540, 40, 160)
work(right, {hand="detail", pile=caskP, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
work(left, {hand="detail", pile=caskLit, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
local e = brush{kind="round", width=1.6, point=0.7}
e:load(caskHot, 0.6)
e:stroke({{479,688},{479,586},{484,569},{500,553}}, {pressure={0.6, 0.5}, ramps={0.05, 0.1}})
e:load(caskHot, 0.6)
e:stroke({{500,553},{510,562}}, {pressure={0.5, 0.2}})
local pb = brush("flat", 3)
for _, seg in ipairs({{{484,602},{484,682}}, {{487,641},{497,641}}}) do pb:load(boneP, 0.6); pb:stroke(seg, {pressure={0.6, 0.6}, ramps={0.05, 0.05}}) end
local pd = pile{{"lead white",1},{"yellow ochre",0.6},{"bone black",0.3}}
for _, seg in ipairs({{{516,602},{516,682}}, {{503,641},{513,641}}}) do pb:load(pd, 0.6); pb:stroke(seg, {pressure={0.5, 0.5}, ramps={0.05, 0.05}}) end
local lr = brush{kind="round", width=8, point=0.1}
lr:load(pile{{"bone black",2},{"ultramarine blue",0.5}}, 0.8); lr:touch(500, 598, {pressure=0.9})
local lg = brush{kind="round", width=3, point=0.3}
lg:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.6); lg:touch(498, 596, {pressure=0.6})

--@ chunk 10
-- narrow the shaft: the dark takes back its flanks; a warm glow seam is melted along each edge while wet
local SA = math.atan(400, 67)
CORE2 = poly({{424,301},{450,299},{530,698},{480,704}})
local flank = (SHAFT:grow(6) - CORE2) - CASK:grow(1) - rect(400, 686, 200, 60)
work(flank, {hand="body", pile=vDeep, coverage=2.8, fill=true, angle=SA, clip=flank})
glowP = pile{{"burnt sienna",1},{"Mars orange",0.8},{"raw sienna",0.6},{"bone black",0.4}}
local seam = (CORE2:grow(12) - CORE2) - CASK:grow(1) - rect(400, 686, 200, 60)
work(seam, {hand="body", pile=glowP, coverage=2.2, fill=true, angle=SA, clip=seam})
blend((CORE2:grow(18) - CORE2:shrink(2)) - CASK:grow(2) - rect(400, 686, 200, 60), {angle=SA})

--@ chunk 11
print(wait(2*24*60))
-- the core as rays of near-white gold; the dais and nave floor taking the light where it lands
local SA = math.atan(400, 67)
rayA = pile{{"lead white",3},{"cadmium yellow",0.5},{"zinc white",0.5}}
rayB = pile{{"lead white",2},{"Indian yellow",0.4},{"yellow ochre",0.4}}
local b = brush("filbert", 5)
local cm = CORE2:grow(1) - CASK:grow(1)
for i = 1, 26 do
  local u = rand(0.1, 0.9)
  local t0 = rand(0, 0.3); local t1 = rand(0.6, 1.0)
  local function P(t) return {lerp(lerp(424, 450, u), lerp(480, 530, u), t), lerp(300, 702, t)} end
  b:reload((math.random() < 0.5) and rayA or rayB, 0.55)
  b:stroke({P(t0), P((t0 + t1) / 2), P(t1)}, {pressure={0.3, 0.6}, ramps={0.3, 0.3}, orient="along", clip=cm})
end
-- the dais lit where the shaft falls
treadLit = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.5}}
for k = 0, 2 do
  local y0 = 690 + k * 13
  local hw = 58 + k * 18
  local lit = poly({{455 - k * 8, y0}, {545 + k * 6, y0}, {547 + k * 6, y0 + 5}, {453 - k * 8, y0 + 5}})
  work(lit, {hand="detail", pile=treadLit, coverage=2.4, fill=true, angle=0, clip=true})
end
-- a warm pool spreading on the nave floor before the dais
poolP = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}
local pool = ellipse(500, 760, 110, 28) * FLOORM
work(pool, {hand="body", pile=poolP, coverage=2, fill=true, angle=0, clip=pool:soften(10)})

--@ chunk 12
-- the bone mosaic: a sunflower spiral of tesserae laid on the floor plane, in perspective; lit toward the dais
boneDim = pile{{"raw sienna",1},{"lead white",0.6},{"bone black",0.4},{"burnt sienna",0.3}}
boneMid = pile{{"lead white",1},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone black",0.15}}
boneLit = pile{{"lead white",2},{"yellow ochre",0.7},{"cadmium yellow",0.15}}
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("flat", k) end; return B[k] end
local z0 = 2.3
local n = 0
for i = 1, 2600 do
  local r = 9.5 * math.sqrt(i)
  local th = i * GA
  local X = 500 + r * math.cos(th)
  local Z = z0 + r * math.sin(th) / 260
  if Z > 0.9 and Z < 4.9 then
    local s = 1 / Z
    local x = 500 + (X - 500) * s
    local y = 560 + (1420 - 560) * s
    if FLOORM:shrink(2):at(x, y) > 0.5 then
      local L = clamp(1.1 - math.sqrt(((x - 500) / 140)^2 + ((y - 765) / 60)^2), 0, 1)
      local p = (L > 0.55) and boneLit or ((L > 0.15 or s < 0.4) and boneMid or boneDim)
      local w = 13 * s
      local br = bb(w)
      if n % 3 == 0 or br.lp ~= p then br:reload(p, 0.6) end
      n = n + 1
      br:stroke({{x - 5 * s, y}, {x + 5 * s, y}}, {pressure={0.7, 0.7}, ramps={0.1, 0.1}, orient=math.pi / 2})
    end
  end
end
print(n)

--@ chunk 13
-- the pool before the dais as lit tesserae (breaking the flat oval); the near floor sinking into shadow
local pool = ellipse(500, 762, 118, 32) * FLOORM
local B = brush("flat", 3)
local n = 0
for i = 1, 500 do
  local x, y = rand(380, 620), rand(728, 796)
  if pool:at(x, y) > 0.5 then
    local L = clamp(1.15 - math.sqrt(((x - 500) / 118)^2 + ((y - 752) / 34)^2), 0, 1)
    if n % 4 == 0 then B:reload((L > 0.45) and boneLit or boneMid, 0.6) end
    n = n + 1
    B:stroke({{x - 1.8, y}, {x + 1.8, y}}, {pressure={0.7, 0.7}, orient=math.pi / 2})
  end
end
local gD = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.3}, medium=0.7}
local near = FLOORM * rect(0, 900, 1000, 500)
work(near, {hand="glaze", pile=gD, coverage=1.6, fill=true, angle=0.0, clip=near,
  load_at=function(x, y) return 0.15 + 0.6 * smoothstep(900, 1333, y) end})
local nw = (LWALL + RWALL) * rect(0, 700, 1000, 700)
work(nw, {hand="glaze", pile=gD, coverage=1.4, fill=true, angle=math.pi/2, clip=nw,
  load_at=function(x, y) return 0.1 + 0.6 * smoothstep(700, 1333, y) end})
print(n)

--@ chunk 14
-- smooth the shadow glaze and lose its upper edge
local band = (FLOORM + LWALL + RWALL) * rect(0, 690, 1000, 700)
blend(band, {angle=0.0})

--@ chunk 15
print(wait(3*24*60))
-- repair: repaint the walls where the blend dragged pale paint across them, then re-cut the chapel openings there
local radial = function(x, y) return math.atan(y - VP[2], x - VP[1]) end
local zone = (LWALL + RWALL) * rect(0, 640, 1000, 560)
work(zone, {hand="body", pile=wDark, coverage=3, fill=true, angle=radial, clip=zone})
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  local s1, s2 = lerp(sa, sb, 0.2), lerp(sa, sb, 0.8)
  for _, X in ipairs({-60, 1060}) do
    local pts = {at(X, 1420, s1), at(X, 760, s1)}
    for k = 1, 7 do
      local t = k / 8
      pts[#pts+1] = at(X, 760 - 170 * math.sin(t * math.pi), lerp(s1, s2, t))
    end
    pts[#pts+1] = at(X, 760, s2); pts[#pts+1] = at(X, 1420, s2)
    local m = poly(pts) * zone
    work(m, {hand="body", pile=chapP, coverage=2.8, fill=true, angle=math.pi/2, clip=m})
  end
end

--@ chunk 16
print(wait(3*24*60))
-- repaint the floor's grout as an opaque mid-dark, darker toward us, warmer near the dais
grout = pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.4}}
groutW = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6}}
local radial = function(x, y) return math.atan(y - VP[2], x - VP[1]) end
local fl = FLOORM * rect(0, 795, 1000, 640)
work(fl, {hand="body", pile=grout, coverage=2.8, fill=true, angle=radial, clip=fl})
local flw = FLOORM * rect(0, 726, 1000, 72) - ellipse(500, 762, 100, 26)
work(flw, {hand="body", pile=groutW, coverage=2.6, fill=true, angle=0, clip=flw})

--@ chunk 17
print(wait(2*24*60))
-- the sunflower mosaic, laid again: brightest near the dais, sinking into shadow toward us
boneDeep = pile{{"raw sienna",1},{"bone black",0.7},{"burnt sienna",0.5},{"lead white",0.3}}
local FIN = FLOORM:shrink(2) - ellipse(500, 762, 100, 26)
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = {b=brush("flat", k), n=0} end; return B[k] end
local z0 = 2.3
local n = 0
for i = 1, 3000 do
  local r = 9.0 * math.sqrt(i)
  local th = i * GA
  local X = 500 + r * math.cos(th)
  local Z = z0 + r * math.sin(th) / 240
  if Z > 0.9 and Z < 5.2 then
    local s = 1 / Z
    local x = 500 + (X - 500) * s
    local y = 560 + (1420 - 560) * s
    if FIN:at(x, y) > 0.5 then
      local L = clamp(1.25 - (y - 740) / 380, 0, 1) - 0.25 * math.abs(x - 500) / 400
      local p = (L > 0.85) and boneLit or ((L > 0.5) and boneMid or ((L > 0.2) and boneDim or boneDeep))
      local e = bb(12 * s)
      if e.n % 3 == 0 or e.p ~= p then e.b:reload(p, 0.6); e.p = p end
      e.n = e.n + 1
      n = n + 1
      e.b:stroke({{x - 4.5 * s, y}, {x + 4.5 * s, y}}, {pressure={0.7, 0.7}, ramps={0.1, 0.1}, orient=math.pi / 2})
    end
  end
end
print(n)

--@ chunk 18
-- the lit pool as tesserae over its hard oval; the Commando, small and dark, halfway down the nave
local pool = ellipse(500, 762, 112, 30)
local B = brush("flat", 3)
local n = 0
for i = 1, 520 do
  local x, y = rand(380, 620), rand(728, 798)
  local d = math.sqrt(((x - 500) / 112)^2 + ((y - 760) / 30)^2)
  if d < 1.15 and FLOORM:at(x, y) > 0.5 then
    if n % 4 == 0 then B:reload((d < 0.6) and boneLit or ((d < 0.95) and boneMid or boneDim), 0.6) end
    n = n + 1
    B:stroke({{x - 1.6, y}, {x + 1.6, y}}, {pressure={0.75, 0.75}, orient=math.pi / 2})
  end
end
-- the figure: back to us, walking toward the light; long shadow running toward us
local fx, fy = 522, 952
local figP = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local shP = pile{{"bone black",2},{"burnt sienna",0.6}}
local s = brush("flat", 9)
s:load(shP, 0.7)
s:stroke({{fx, fy + 2}, {fx + 6, fy + 40}, {fx + 12, fy + 90}}, {pressure={0.7, 0.3}, ramps={0.05, 0.6}, orient="across"})
local f = brush("filbert", 9)
f:load(figP, 0.85)
f:stroke({{fx, fy - 38}, {fx, fy - 22}}, {pressure={0.9, 0.85}})          -- torso
local l = brush("filbert", 4.5)
l:load(figP, 0.85)
l:stroke({{fx - 2.5, fy - 22}, {fx - 4, fy - 10}, {fx - 4.5, fy}}, {pressure={0.85, 0.8}})
l:stroke({{fx + 2.5, fy - 22}, {fx + 4.5, fy - 11}, {fx + 6, fy - 1}}, {pressure={0.85, 0.8}})
l:stroke({{fx - 5, fy - 36}, {fx - 7, fy - 26}, {fx - 7.5, fy - 18}}, {pressure={0.7, 0.6}})
l:stroke({{fx + 5, fy - 36}, {fx + 7, fy - 26}, {fx + 7.5, fy - 19}}, {pressure={0.7, 0.6}})
local h = brush{kind="round", width=7, point=0.1}
h:load(figP, 0.85); h:touch(fx, fy - 44, {pressure=0.9})
-- rim from the far light: crown, shoulders
local r = brush{kind="round", width=1.2, point=0.8}
r:load(pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.3}}, 0.55)
r:stroke({{fx - 3, fy - 47.5}, {fx + 3, fy - 47.5}}, {pressure={0.5, 0.3}})
r:stroke({{fx - 6, fy - 39}, {fx + 6, fy - 39}}, {pressure={0.35, 0.2}})
print(n)

--@ chunk 19
print(wait(24*60))
-- second, heavier pass on the figure so it reads dark against the bone
local fx, fy = 522, 952
local figP = pile{{"bone black",3},{"burnt sienna",0.5}}
local f = brush("filbert", 9)
f:load(figP, 1.0)
f:stroke({{fx, fy - 38}, {fx, fy - 22}}, {pressure={1, 1}})
local l = brush("filbert", 5)
for _, p in ipairs({{{fx - 2.5, fy - 22}, {fx - 4, fy - 10}, {fx - 4.5, fy}}, {{fx + 2.5, fy - 22}, {fx + 4.5, fy - 11}, {fx + 6, fy - 1}},
                    {{fx - 5, fy - 36}, {fx - 7, fy - 26}, {fx - 7.5, fy - 18}}, {{fx + 5, fy - 36}, {fx + 7, fy - 26}, {fx + 7.5, fy - 19}}}) do
  l:load(figP, 1.0); l:stroke(p, {pressure={0.95, 0.9}})
end
local h = brush{kind="round", width=7, point=0.1}
h:load(figP, 1.0); h:touch(fx, fy - 44, {pressure=1})
local r = brush{kind="round", width=1.2, point=0.8}
r:load(pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.3}}, 0.55)
r:stroke({{fx - 3, fy - 48}, {fx + 3, fy - 48}}, {pressure={0.5, 0.3}})

--@ chunk 20
-- a sealed bronze case in each chapel: a dark block on a plinth with a warm lit lid edge and one glint
caseP = pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.5}}
caseLit = pile{{"raw sienna",1.2},{"yellow ochre",1},{"lead white",0.5}}
local n = 0
for i = 1, #RIBS - 1 do
  local sm = lerp(RIBS[i], RIBS[i + 1], 0.5)
  for _, X in ipairs({-60, 1060}) do
    local Xi = X + ((X < 500) and 70 or -70)
    local base = at(Xi, 1250, sm); local top = at(Xi, 1080, sm)
    local hw = 60 * sm
    local m = rect(base[1] - hw, top[2], 2 * hw, base[2] - top[2])
    work(m, {hand="detail", pile=caseP, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
    local e = brush{kind="round", width=math.max(1.2, 5 * sm), point=0.5}
    e:load(caseLit, 0.6)
    e:stroke({{base[1] - hw, top[2] + 1}, {base[1] + hw, top[2] + 1}}, {pressure={0.6, 0.4}, ramps={0.05, 0.3}})
    local side = (X < 500) and (base[1] + hw - 1) or (base[1] - hw + 1)
    e:load(caseLit, 0.5)
    e:stroke({{side, top[2] + 2}, {side, base[2] - 2}}, {pressure={0.35, 0.1}, ramps={0.05, 0.6}})
    n = n + 1
  end
end
print(n)

--@ chunk 21
print(wait(2*24*60))
-- the cases read too light: lay them again in a deep bronze, keeping only a thin warm lid edge, and set each in its chapel's shadow
local n = 0
local e = brush{kind="round", width=2, point=0.5}
for i = 1, #RIBS - 1 do
  local sm = lerp(RIBS[i], RIBS[i + 1], 0.5)
  for _, X in ipairs({-60, 1060}) do
    local Xi = X + ((X < 500) and 70 or -70)
    local base = at(Xi, 1250, sm); local top = at(Xi, 1080, sm)
    local hw = 60 * sm
    local m = rect(base[1] - hw, top[2] + 2 * sm, 2 * hw, base[2] - top[2] - 2 * sm)
    work(m, {hand="detail", pile=vDeep, coverage=2.8, fill=true, angle=math.pi/2, clip=true})
    e:load(caseLit, 0.5)
    e:stroke({{base[1] - hw * 0.9, top[2] + 1}, {base[1] + hw * 0.9, top[2] + 1}}, {pressure={0.4, 0.2}, ramps={0.05, 0.4}})
    n = n + 1
  end
end
-- shadowed lower walls so the cases sink into their chapels
local gD = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.3}, medium=0.7}
local lw = (LWALL + RWALL) * rect(0, 760, 1000, 600)
work(lw, {hand="glaze", pile=gD, coverage=1.4, fill=true, angle=math.pi/2, clip=lw, load=0.35})
print(n)

--@ chunk 22
print(wait(4*24*60))
print(drying(80, 900), drying(900, 1000))
-- the glaze went grey-violet and flat: repaint the lower walls opaque, warm and darkening downward; re-cut chapels; cases again
wLow = pile{{"bone black",1.4},{"burnt sienna",1.2},{"raw sienna",0.5}}
local radial = function(x, y) return math.atan(y - VP[2], x - VP[1]) end
local zone = (LWALL + RWALL) * rect(0, 600, 1000, 800)
work(zone, {hand="body", pile=wLow, coverage=3, fill=true, angle=radial, clip=zone})
work(zone * rect(0, 640, 1000, 120), {hand="body", pile=wDark, coverage=2, fill=true, angle=radial, clip=zone})
blend(zone * rect(0, 600, 1000, 220), {angle=radial})

--@ chunk 23
print(wait(3*24*60))
-- re-cut the chapel openings (the repaint covered them), deep and cool-dark; then each sealed case inside, lid edge catching the far light
local n = 0
local e = brush{kind="round", width=2, point=0.5}
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  local s1, s2 = lerp(sa, sb, 0.2), lerp(sa, sb, 0.8)
  for _, X in ipairs({-60, 1060}) do
    local pts = {at(X, 1420, s1), at(X, 760, s1)}
    for k = 1, 7 do
      local t = k / 8
      pts[#pts+1] = at(X, 760 - 170 * math.sin(t * math.pi), lerp(s1, s2, t))
    end
    pts[#pts+1] = at(X, 760, s2); pts[#pts+1] = at(X, 1420, s2)
    local m = poly(pts) * (LWALL + RWALL)
    work(m, {hand="body", pile=chapP, coverage=3, fill=true, angle=math.pi/2, clip=m})
    -- case
    local sm = lerp(sa, sb, 0.5)
    local Xi = X + ((X < 500) and 70 or -70)
    local base = at(Xi, 1250, sm); local top = at(Xi, 1080, sm)
    local hw = 60 * sm
    local c = rect(base[1] - hw, top[2], 2 * hw, base[2] - top[2])
    work(c, {hand="detail", pile=caseP, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
    e:load(caseLit, 0.55)
    e:stroke({{base[1] - hw * 0.9, top[2] + 1}, {base[1] + hw * 0.9, top[2] + 1}}, {pressure={0.45, 0.25}, ramps={0.05, 0.4}})
    n = n + 1
  end
end
print(n)

--@ chunk 24
print(wait(2*24*60))
-- the shaft reads as a tube: paint its olive flanks out with the vault/back-wall dark, keeping a hairline glow
local SA = math.atan(400, 67)
local flank = (SHAFT:grow(14) - CORE2:grow(2)) - CASK:grow(1) - rect(400, 684, 200, 70)
local inVault = flank * VAULT
local inBack = flank - VAULT
work(inVault, {hand="body", pile=vDeep, coverage=3, fill=true, angle=SA, clip=inVault})
work(inBack, {hand="body", pile=vDeep, coverage=3, fill=true, angle=SA, clip=inBack})
local seam = (CORE2:grow(5) - CORE2:shrink(1)) - CASK:grow(1) - rect(400, 684, 200, 70)
work(seam, {hand="detail", pile=glowP, coverage=2, fill=true, angle=SA, clip=seam})
blend((CORE2:grow(7) - CORE2:shrink(2)) - CASK:grow(2) - rect(400, 684, 200, 70), {angle=SA})

--@ chunk 25
print(wait(3*24*60))
local SA = math.atan(400, 67)
local flank = (SHAFT:grow(16) - CORE2:grow(3)) - CASK:grow(1) - rect(400, 684, 200, 70)
local blk = pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.2}}
work(flank, {hand="body", tool="filbert 5", pile=blk, coverage=3.6, fill=true, angle=SA, clip=true, load=0.9})

--@ chunk 26
print(wait(2*24*60))
-- restore the ribs and plates across the dark band, then lay the shaft's edges as soft gold ray strokes reaching just past the core
local SA = math.atan(400, 67)
local band = (SHAFT:grow(17) - CORE2:grow(2)) * VAULT
local ribs = {}
for i, s in ipairs(RIBS) do
  local c = at(500, 322, s); local r = 560 * s
  local pts = {}
  for k = 0, 72 do local a = math.pi + k * math.pi / 72; pts[#pts+1] = {c[1] + math.cos(a) * r, c[2] + math.sin(a) * r} end
  local br = brush("filbert", math.max(2, 22 * s))
  br:load(ribP, 0.8)
  br:stroke(pts, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across", clip=band})
  local e = brush{kind="round", width=2.0, point=0.6}
  local pts2 = {}
  for k = 0, 72 do local a = math.pi + k * math.pi / 72; pts2[#pts2+1] = {c[1] + math.cos(a) * r * 0.982, c[2] + math.sin(a) * r * 0.982} end
  -- lit hard where the rib passes beside the shaft
  e:load(pile{{"lead white",1.5},{"yellow ochre",1},{"cadmium yellow",0.3}}, 0.6)
  e:stroke(pts2, {pressure={0.6, 0.6}, ramps={0.02, 0.02}, clip=band})
end
local b = brush("filbert", 4)
local edgeL = {{420,300},{476,704}}; local edgeR = {{452,299},{533,698}}
for i = 1, 22 do
  local side = (i % 2 == 0) and edgeL or edgeR
  local off = rand(-4, 3) * ((side == edgeL) and 1 or -1)
  local t0, t1 = rand(0, 0.4), rand(0.5, 0.95)
  local function P(t) return {lerp(side[1][1], side[2][1], t) + off, lerp(side[1][2], side[2][2], t)} end
  b:reload((math.random() < 0.5) and rayB or shCore, 0.45)
  b:stroke({P(t0), P((t0 + t1) / 2), P(t1)}, {pressure={0.2, 0.4}, ramps={0.4, 0.4}, orient="along", clip=SHAFT:grow(6) - CASK:grow(1)})
end

--@ chunk 27
print(wait(6*24*60)); print(drying(410,330), drying(560,500), drying(395,420))

--@ chunk 28
print(wait(5*24*60), drying(410,330))
-- ribs and scale plates restated across the dark band, now that it is dry
local band = (SHAFT:grow(18) - CORE2:grow(3)) * VAULT
for i, s in ipairs(RIBS) do
  local c = at(500, 322, s); local r = 560 * s
  local pts, pts2 = {}, {}
  for k = 0, 72 do local a = math.pi + k * math.pi / 72
    pts[#pts+1] = {c[1] + math.cos(a) * r, c[2] + math.sin(a) * r}
    pts2[#pts2+1] = {c[1] + math.cos(a) * r * 0.982, c[2] + math.sin(a) * r * 0.982} end
  local br = brush("filbert", math.max(2, 22 * s))
  br:load(pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.6}}, 0.85)
  br:stroke(pts, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=band})
  local e = brush{kind="round", width=2.2, point=0.6}
  e:load(pile{{"lead white",1.5},{"yellow ochre",1},{"cadmium yellow",0.3}}, 0.6)
  e:stroke(pts2, {pressure={0.65, 0.65}, ramps={0.02, 0.02}, clip=band})
end
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("filbert", k) end; return B[k] end
local n = 0
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  for k = 1, 260 do
    local s = lerp(sa, sb, ((k * 0.618) % 1) * 0.86 + 0.07)
    local a = math.pi + ((k * GA * 0.5) % math.pi)
    local c = at(500, 322, s); local r = 560 * s
    local x, y = c[1] + math.cos(a) * r, c[2] + math.sin(a) * r
    if band:at(x, y) > 0.5 then
      local br = bb(30 * s)
      br:reload(plLit, 0.55)
      local ta = a + math.pi / 2
      local hl = 17 * s
      br:stroke({{x - math.cos(ta) * hl, y - math.sin(ta) * hl}, {x + math.cos(a) * 3 * s, y + math.sin(a) * 3 * s}, {x + math.cos(ta) * hl, y + math.sin(ta) * hl}},
        {pressure={0.55, 0.45}, ramps={0.15, 0.4}, clip=band})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 29
-- motes in the shaft; the aperture's glare; light spilling onto the plates nearest the aperture
local mote = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.15}}
local m = brush{kind="round", width=1.6, point=0.6}
local n = 0
for i = 1, 90 do
  local t = rand(0.05, 0.95); local u = rand(-0.3, 1.3)
  local x = lerp(lerp(420, 455, u), lerp(474, 536, u), t); local y = lerp(300, 702, t)
  if CASK:grow(2):at(x, y) < 0.5 then
    if n % 8 == 0 then m:load(mote, 0.55) end
    m:touch(x, y, {pressure=rand(0.2, 0.5) * ((u > 0 and u < 1) and 1 or 0.6)})
    n = n + 1
  end
end
local ap = brush{kind="round", width=4, point=0.3}
ap:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.7)
ap:stroke({{420, 300}, {452, 298}}, {pressure={0.8, 0.8}})
-- warm spill on the vault around the aperture
local spill = pile{{"raw sienna",1},{"yellow ochre",1},{"Mars orange",0.4},{"lead white",0.5}}
local b = brush("filbert", 6)
local k = 0
for i = 1, 70 do
  local a = rand(0, 6.28); local r = 30 + 90 * rand(0, 1)^1.5
  local x, y = 436 + math.cos(a) * r, 300 + math.sin(a) * r * 0.7
  if VAULT:at(x, y) > 0.5 and SHAFT:grow(4):at(x, y) < 0.5 then
    if k % 3 == 0 then b:reload(spill, 0.5) end
    k = k + 1
    local ta = math.atan(y - 322, x - 500) + math.pi / 2
    b:stroke({{x - math.cos(ta) * 5, y - math.sin(ta) * 5}, {x + math.cos(ta) * 5, y + math.sin(ta) * 5}}, {pressure={0.5 * (1 - r / 130) + 0.1, 0.2}, ramps={0.2, 0.5}})
  end
end
print(n, k)

--@ chunk 30
-- PASS · paint the solid shaft and the flakes out, back to the vault's dark and the far wall's dark
airV = pile{{"bone black",2},{"burnt sienna",1.4},{"raw sienna",0.35}}
airB = pile{{"bone black",2},{"burnt sienna",1.1},{"bone brown",0.6}}
OUTZ = (SHAFT:grow(24) + ellipse(436, 300, 140, 100)) - CASK:grow(1) - rect(400, 684, 200, 80)
local ang = function(x, y) return math.atan(y - VP[2], x - VP[1]) + math.pi/2 end
local zv = OUTZ * VAULT
local zb = OUTZ - VAULT
work(zv, {hand="body", tool="filbert 6", pile=airV, coverage=3.6, fill=true, angle=ang, clip=true, load=0.9})
work(zb, {hand="body", tool="filbert 6", pile=airB, coverage=3.6, fill=true, angle=math.pi/2, clip=true, load=0.9})

--@ chunk 31
print(wait(8*24*60), drying(440, 400), drying(470, 330))
-- ribs and plates restated across the painted-out zone of the vault
local band = OUTZ * VAULT
for i, s in ipairs(RIBS) do
  local c = at(500, 322, s); local r = 560 * s
  local pts, pts2 = {}, {}
  for k = 0, 72 do local a = math.pi + k * math.pi / 72
    pts[#pts+1] = {c[1] + math.cos(a) * r, c[2] + math.sin(a) * r}
    pts2[#pts2+1] = {c[1] + math.cos(a) * r * 0.982, c[2] + math.sin(a) * r * 0.982} end
  local br = brush("filbert", math.max(2, 22 * s))
  br:load(pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.6}}, 0.85)
  br:stroke(pts, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=band})
  local e = brush{kind="round", width=2.0, point=0.6}
  e:load(ribLit, 0.6)
  e:stroke(pts2, {pressure={0.45, 0.45}, ramps={0.02, 0.02}, clip=band})
end
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("filbert", k) end; return B[k] end
local n = 0
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  for k = 1, 260 do
    local s = lerp(sa, sb, ((k * 0.618) % 1) * 0.86 + 0.07)
    local a = math.pi + ((k * GA * 0.5) % math.pi)
    local c = at(500, 322, s); local r = 560 * s
    local x, y = c[1] + math.cos(a) * r, c[2] + math.sin(a) * r
    if band:at(x, y) > 0.5 then
      local lit = (1 - s) * 0.9 + 0.1 + 0.15 * math.sin(a * 3)
      local br = bb(30 * s)
      br:reload((lit > 0.6) and plLit or plDim, 0.5)
      local ta = a + math.pi / 2
      local hl = 17 * s
      br:stroke({{x - math.cos(ta) * hl, y - math.sin(ta) * hl}, {x + math.cos(a) * 3 * s, y + math.sin(a) * 3 * s}, {x + math.cos(ta) * hl, y + math.sin(ta) * hl}},
        {pressure={0.5, 0.4}, ramps={0.15, 0.4}, clip=band})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 32
print(wait(10*24*60), drying(440, 400), drying(470, 330))
-- the first cover dried too light and the ribs smeared into it: a second, darker opaque coat over the whole zone
local blk = pile{{"bone black",2.5},{"burnt sienna",1},{"raw sienna",0.2}}
local ang = function(x, y) return math.atan(y - VP[2], x - VP[1]) + math.pi/2 end
work(OUTZ * VAULT, {hand="body", tool="filbert 6", pile=blk, coverage=3.8, fill=true, angle=ang, clip=true, load=0.95})
work(OUTZ - VAULT, {hand="body", tool="filbert 6", pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 33
print(wait(12*24*60), drying(440, 400), drying(470, 330))
-- ribs and plates restated across the painted-out zone of the vault
local band = OUTZ * VAULT
for i, s in ipairs(RIBS) do
  local c = at(500, 322, s); local r = 560 * s
  local pts, pts2 = {}, {}
  for k = 0, 72 do local a = math.pi + k * math.pi / 72
    pts[#pts+1] = {c[1] + math.cos(a) * r, c[2] + math.sin(a) * r}
    pts2[#pts2+1] = {c[1] + math.cos(a) * r * 0.982, c[2] + math.sin(a) * r * 0.982} end
  local br = brush("filbert", math.max(2, 15 * s))
  br:load(pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.6}}, 0.85)
  br:stroke(pts, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=band})
  local e = brush{kind="round", width=2.0, point=0.6}
  e:load(ribLit, 0.6)
  e:stroke(pts2, {pressure={0.45, 0.45}, ramps={0.02, 0.02}, clip=band})
end
local B = {}
local function bb(w) local k = math.max(2, math.floor(w + 0.5)); if not B[k] then B[k] = brush("filbert", k) end; return B[k] end
local n = 0
for i = 1, #RIBS - 1 do
  local sa, sb = RIBS[i], RIBS[i + 1]
  for k = 1, 260 do
    local s = lerp(sa, sb, ((k * 0.618) % 1) * 0.86 + 0.07)
    local a = math.pi + ((k * GA * 0.5) % math.pi)
    local c = at(500, 322, s); local r = 560 * s
    local x, y = c[1] + math.cos(a) * r, c[2] + math.sin(a) * r
    if band:at(x, y) > 0.5 then
      local lit = (1 - s) * 0.9 + 0.1 + 0.15 * math.sin(a * 3)
      local br = bb(30 * s)
      br:reload((lit > 0.6) and plLit or plDim, 0.5)
      local ta = a + math.pi / 2
      local hl = 17 * s
      br:stroke({{x - math.cos(ta) * hl, y - math.sin(ta) * hl}, {x + math.cos(a) * 3 * s, y + math.sin(a) * 3 * s}, {x + math.cos(ta) * hl, y + math.sin(ta) * hl}},
        {pressure={0.5, 0.4}, ramps={0.15, 0.4}, clip=band})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 34
print(wait(3*24*60))
-- the light: long thin strokes down its direction, fanning slightly from the aperture to the dais; dark between them;
-- strongest near the aperture, fading downward; plus a few veils so the air glows faintly between the rays
local AP = {436, 301}
rayW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.35}}
rayG = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.3}}
rayT = pile{{"lead white",1},{"Indian yellow",0.5},{"Mars orange",0.2}, medium=0.75}
local function ray(br, p, u, t0, t1, pr0, pr1, load)
  local x1 = lerp(462, 545, u); local y1 = 700
  local x0 = AP[1] + (u - 0.5) * 22; local y0 = AP[2] + 2
  local function P(t) return {lerp(x0, x1, t), lerp(y0, y1, t)} end
  br:reload(p, load)
  br:stroke({P(t0), P((t0 + t1) / 2), P(t1)}, {pressure={pr0, pr1}, ramps={0.15, 0.6}, orient="along", clip=-(CASK:grow(1))})
end
-- veils first
local v = brush("filbert", 12)
for i = 1, 10 do ray(v, rayT, rand(0.05, 0.95), 0, rand(0.75, 1.0), 0.35, 0.05, 0.35) end
-- rays
local thin = brush{kind="round", width=2.2, point=0.5}
local mid = brush("filbert", 4)
for i = 1, 70 do
  local u = clamp(randn(0.5, 0.26), -0.05, 1.05)
  local core = 1 - math.abs(u - 0.5) * 1.6
  local t1 = rand(0.45, 1.0)
  local br = (math.random() < 0.35) and mid or thin
  ray(br, (core > 0.6 and math.random() < 0.6) and rayW or rayG, u, rand(0, 0.08), t1, 0.35 + 0.35 * core, 0.03, 0.45)
end

--@ chunk 35
-- the aperture: a small hard white opening; the reliquary inside the light: lit bronze flank, bone edges, the lens and its white glint
local ap = brush{kind="round", width=3.5, point=0.2}
ap:load(pile{{"zinc white",3},{"lemon chrome",0.15}}, 0.8)
ap:stroke({{426, 300}, {446, 299.5}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}})
local rim = brush{kind="round", width=1.2, point=0.8}
rim:load(pile{{"bone black",2},{"burnt sienna",0.6}}, 0.6)
rim:stroke({{424, 303}, {436, 304.5}, {448, 302.5}}, {pressure={0.5, 0.5}})
-- casket
local lit = CASK * rect(470, 540, 18, 160)
work(lit, {hand="detail", pile=caskLit, coverage=2.4, fill=true, angle=math.pi/2, clip=true})
local e = brush{kind="round", width=1.6, point=0.7}
e:load(caskHot, 0.6)
e:stroke({{479,688},{479,586},{484,569},{500,553}}, {pressure={0.65, 0.55}, ramps={0.05, 0.1}})
e:load(caskHot, 0.5)
e:stroke({{500,553},{516,568}}, {pressure={0.4, 0.15}})
local pb = brush("flat", 3)
pb:load(boneP, 0.6); pb:stroke({{485,604},{485,682}}, {pressure={0.6, 0.6}, ramps={0.05, 0.05}})
pb:load(pile{{"lead white",1},{"yellow ochre",0.6},{"bone black",0.35}}, 0.6); pb:stroke({{515,604},{515,682}}, {pressure={0.5, 0.5}, ramps={0.05, 0.05}})
local lr = brush{kind="round", width=8, point=0.1}
lr:load(pile{{"bone black",2},{"ultramarine blue",0.5}}, 0.85); lr:touch(500, 598, {pressure=0.9})
local lg = brush{kind="round", width=2.6, point=0.3}
lg:load(pile{{"zinc white",3},{"lemon chrome",0.1}}, 0.7); lg:touch(497.5, 595.5, {pressure=0.7})
-- motes, bright, only inside the rays
local m = brush{kind="round", width=1.5, point=0.6}
local n = 0
for i = 1, 60 do
  local t = rand(0.05, 0.9); local u = randn(0.5, 0.22)
  local x = lerp(436 + (u - 0.5) * 22, lerp(462, 545, u), t); local y = lerp(303, 700, t)
  if CASK:grow(2):at(x, y) < 0.5 then
    if n % 8 == 0 then m:load(pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.12}}, 0.5) end
    m:touch(x, y, {pressure=rand(0.2, 0.45) * (1 - 0.5 * t)}); n = n + 1
  end
end
print(n)

--@ chunk 36
-- a few more white rays in the core, reaching down to the reliquary's shoulder, so the shaft blazes near the aperture
local AP = {436, 301}
local thin = brush{kind="round", width=2.6, point=0.5}
for i = 1, 22 do
  local u = clamp(randn(0.45, 0.15), 0, 1)
  local x1 = lerp(462, 545, u)
  local function P(t) return {lerp(AP[1] + (u - 0.5) * 20, x1, t), lerp(AP[2] + 2, 700, t)} end
  local t1 = rand(0.35, 0.85)
  thin:reload(rayW, 0.55)
  thin:stroke({P(0.01), P(t1 / 2), P(t1)}, {pressure={0.75, 0.05}, ramps={0.05, 0.7}, orient="along", clip=-(CASK:grow(1))})
end

--@ chunk 37
print(wait(2*24*60)); local g = brush{kind="round", width=3.2, point=0.2}; g:load(pile{{"zinc white",3},{"lemon chrome",0.1}}, 0.9); g:touch(497.8, 595.8, {pressure=0.9}); local h = brush{kind="round", width=1.2, point=0.8}; h:load(pile{{"zinc white",3}}, 0.7); h:stroke({{494.5,597},{496,593.5}}, {pressure={0.5,0.3}})
