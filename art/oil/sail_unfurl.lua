-- easel session "sail_unfurl": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=6174,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.6},{"lead white",0.2}, medium=0.45}, um=24, apply="brush"},
  }}
print(W, H)

--@ chunk 2
O = {400, 470}
HULLC = {{0,500},{150,478},{300,468},{450,466},{600,472},{780,486},{1000,510}}
HULL = below(HULLC)
A0, A1 = -2.75, -0.22          -- the fan's angular extent (radians, from the bay)
FAN = mask(function(x, y)
  local a = math.atan(y - O[2], x - O[1]); local r = math.sqrt((x - O[1])^2 + (y - O[2])^2)
  if a < A0 or a > A1 then return 0 end
  local R = 640 + 120 * math.sin((a - A0) * 2.1)
  return (r < R) and 1 or 0 end) - HULL
SKY = everywhere() - FAN - HULL
skyP = pile{{"bone black",3},{"ultramarine blue",0.6}}
filmP = pile{{"bone black",2},{"ultramarine blue",1},{"cobalt violet",0.4}}
hullP = pile{{"bone black",1.5},{"burnt sienna",1.2},{"raw sienna",0.4}}
work(SKY, {hand="broad", pile=skyP, coverage=3, fill=true, angle=0.3, angle_jitter=0.3})
work(FAN, {hand="broad", pile=filmP, coverage=2.8, fill=true, angle=function(x, y) return math.atan(y - O[2], x - O[1]) end, clip=FAN})
work(HULL, {hand="broad", pile=hullP, coverage=2.8, fill=true, angle=0.05, clip=HULL:grow(2)})

--@ chunk 3
print(wait(2*24*60))
-- pleats: the fan divided into narrow wedges, alternate facets of the film; tips zigzag; a few facets throw the Sun back
NP = 34
PL = {}
local function Rb(a) return 640 + 120 * math.sin((a - A0) * 2.1) end
for i = 0, NP do
  local a = lerp(A0, A1, i / NP) + ((i > 0 and i < NP) and rand(-0.012, 0.012) or 0)
  PL[#PL + 1] = {a = a, r = Rb(a) * ((i % 2 == 0) and 1.0 or rand(0.8, 0.9))}
end
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
fDark = pile{{"bone black",3},{"ultramarine blue",0.6}}
fCool = pile{{"bone black",1.5},{"ultramarine ash",1},{"cobalt blue",0.4},{"lead white",0.25}}
fWarm = pile{{"bone black",1.2},{"burnt sienna",0.6},{"raw sienna",0.6},{"lead white",0.3}}
FACETS = {}
for i = 1, NP do
  local a, b = PL[i], PL[i + 1]
  local m = poly({P(a.a, 18), P(a.a, a.r), P(b.a, b.r), P(b.a, 18)}) - HULL
  FACETS[i] = m
  local p = (i % 2 == 0) and fDark or ((i % 6 == 1) and fWarm or fCool)
  work(m, {hand="body", pile=p, coverage=2.4, fill=true, angle=(a.a + b.a) / 2, clip=m})
end
-- the sky between the pleat tips
local inside = FACETS[1]; for i = 2, NP do inside = inside + FACETS[i] end
local gaps = FAN:grow(2) - inside - HULL
work(gaps, {hand="body", pile=skyP, coverage=3, fill=true, angle=0.3, clip=gaps})
FANIN = inside

--@ chunk 4
print(wait(3*24*60))
-- far too light: repaint every facet dark. Two darks for the two facings, both a step off the black sky
fA = pile{{"bone black",2},{"ultramarine blue",1},{"cobalt violet",0.3}}
fB = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
for i = 1, NP do
  local a, b = PL[i], PL[i + 1]
  work(FACETS[i], {hand="body", tool="filbert 7", pile=(i % 2 == 0) and fB or fA, coverage=3.4, fill=true, angle=(a.a + b.a) / 2, clip=FACETS[i], load=0.95})
end

--@ chunk 5
print(wait(3*24*60))
-- the fold edges: long strokes running out from the bay along each crease, white-gold where the crease faces the Sun (upper left), dim elsewhere
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
local hot = pile{{"zinc white",3},{"lead white",1},{"cadmium yellow",0.3}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local dim = pile{{"ultramarine ash",1},{"lead white",0.8},{"bone black",0.5}}
local thin = brush{kind="round", width=2.2, point=0.6}
local fine = brush{kind="round", width=1.3, point=0.8}
local SUNA = -2.15
local clipm = FANIN:grow(2)
for i = 2, NP do
  local c = PL[i]
  local face = 0.5 + 0.5 * math.cos(c.a - SUNA)
  if i % 2 == 0 then face = face * 0.55 end      -- valley folds catch less
  local p = (face > 0.75) and hot or ((face > 0.45) and gold or dim)
  local br = (face > 0.6) and thin or fine
  local r0 = rand(30, 60); local r1 = c.r * rand(0.9, 1.0)
  local bow = rand(-0.02, 0.02)
  br:reload(p, 0.55)
  br:stroke({P(c.a, r0), P(c.a + bow, (r0 + r1) / 2), P(c.a, r1)}, {pressure={0.25 + 0.5 * face, 0.15 + 0.3 * face}, swell={0.7, 1.2, 0.8}, ramps={0.15, 0.25}, clip=clipm})
  -- a second, shorter glint along the hottest creases
  if face > 0.7 then
    fine:reload(hot, 0.55)
    local ra = rand(120, 300)
    fine:stroke({P(c.a + 0.004, ra), P(c.a + 0.004, ra + rand(80, 200))}, {pressure={0.7, 0.1}, ramps={0.1, 0.6}, clip=clipm})
  end
end
-- spars along the two outer edges, bright, with joints
local sp = brush{kind="round", width=3, point=0.4}
for _, c in ipairs({PL[1], PL[NP + 1]}) do
  sp:reload(gold, 0.6)
  sp:stroke({P(c.a, 20), P(c.a, c.r + 30)}, {pressure={0.7, 0.4}, ramps={0.05, 0.2}})
  for k = 1, 5 do
    local j = brush{kind="round", width=6, point=0.1}
    j:load(pile{{"bone black",2},{"burnt sienna",1}}, 0.8)
    j:touch(P(c.a, k * (c.r + 30) / 6)[1], P(c.a, k * (c.r + 30) / 6)[2], {pressure=0.7})
  end
end

--@ chunk 6
-- the creases again, fuller and decisive: each a long stroke laid with a loaded brush, hottest near the Sun's side, fading outward
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
local hot = pile{{"zinc white",3},{"lead white",1},{"cadmium yellow",0.3}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local dim = pile{{"ultramarine ash",1},{"lead white",1},{"bone black",0.3}}
local SUNA = -2.15
local clipm = FANIN:grow(3)
local b3 = brush{kind="round", width=3.2, point=0.3}
local b2 = brush{kind="round", width=2.2, point=0.4}
for i = 2, NP do
  local c = PL[i]
  local face = 0.5 + 0.5 * math.cos(c.a - SUNA)
  if i % 2 == 0 then face = face * 0.6 end
  local p = (face > 0.7) and hot or ((face > 0.4) and gold or dim)
  local br = (face > 0.55) and b3 or b2
  local r1 = c.r * rand(0.85, 0.98)
  for pass = 1, 2 do
    br:reload(p, 0.85)
    local off = (pass - 1) * 0.002
    br:stroke({P(c.a + off, 25), P(c.a + off, r1 * 0.5), P(c.a + off, r1)}, {pressure={0.55 + 0.35 * face, 0.2}, ramps={0.05, 0.5}, clip=clipm})
  end
end

--@ chunk 7
-- carry the creases all the way out: each crease laid again in segments with fresh paint, so the light runs to the tips
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
local hot = pile{{"zinc white",3},{"lead white",1},{"cadmium yellow",0.3}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local dim = pile{{"ultramarine ash",1},{"lead white",1},{"bone black",0.3}}
local SUNA = -2.15
local clipm = FANIN:grow(3)
local b = brush{kind="round", width=2.6, point=0.4}
for i = 2, NP do
  local c = PL[i]
  local face = 0.5 + 0.5 * math.cos(c.a - SUNA)
  if i % 2 == 0 then face = face * 0.6 end
  local p = (face > 0.7) and hot or ((face > 0.4) and gold or dim)
  local R = c.r * 0.97
  local cuts = {0.3, 0.55, 0.78, 1.0}
  for k = 1, #cuts - 1 do
    if math.random() < 0.85 then
      b:reload(p, 0.85)
      local ra, rb = R * cuts[k] - 10, R * cuts[k + 1]
      b:stroke({P(c.a, ra), P(c.a, (ra + rb) / 2), P(c.a, rb)}, {pressure={0.35 + 0.35 * face, 0.15 + 0.35 * face}, ramps={0.25, 0.25}, clip=clipm})
    end
  end
end

--@ chunk 8
-- the hull: darker, the plates of the foreground; each plate a lit upper-left lip and a black shadow under it
hullD = pile{{"bone black",2.2},{"burnt sienna",1},{"raw sienna",0.3}}
work(HULL, {hand="body", tool="filbert 8", pile=hullD, coverage=3.2, fill=true, angle=0.05, clip=HULL, load=0.9})

--@ chunk 9
print(wait(3*24*60))
local plBody = pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.8}}
local plLit = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",1},{"cadmium yellow",0.2}}
local plShad = pile{{"bone black",3},{"ultramarine blue",0.3}}
local B = {}
local function bb(k, w) w = math.max(2, math.floor(w + 0.5)); local key = k .. w; if not B[key] then B[key] = brush(k, w) end; return B[key] end
local function crest(x) -- hull top y at x
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 510 end
local n = 0
for row = 0, 9 do
  local t = row / 9
  local s = lerp(7, 34, t ^ 1.4)
  local dy = lerp(6, 95, t ^ 1.3)
  local x = -s + (row % 2) * s * 0.5
  while x < 1000 + s do
    local y = crest(clamp(x, 0, 1000)) + dy
    if not (math.abs(x - O[1]) < 45 and dy < 20) then
      local hw = s * 0.5
      local b1 = bb("filbert", s * 0.8)
      b1:reload(plBody, 0.6)
      b1:stroke({{x - hw, y}, {x, y + s * 0.12}, {x + hw, y}}, {pressure={0.8, 0.7}, ramps={0.1, 0.2}, clip=HULL})
      local b2 = bb("round", math.max(1.5, s * 0.14))
      b2:reload(plShad, 0.6)
      b2:stroke({{x - hw * 1.05, y + s * 0.38}, {x, y + s * 0.5}, {x + hw * 1.05, y + s * 0.38}}, {pressure={0.75, 0.3}, ramps={0.1, 0.3}, clip=HULL})
      b2:reload(plLit, 0.6)
      b2:stroke({{x - hw * 0.9, y - s * 0.12}, {x - hw * 0.3, y - s * 0.24}, {x + hw * 0.3, y - s * 0.2}}, {pressure={0.6, 0.1}, ramps={0.1, 0.5}, clip=HULL})
      n = n + 1
    end
    x = x + s * 0.95
  end
end
print(n)

--@ chunk 10
print(wait(2*24*60))
-- the sail's shadow falls across the hull to the right of the bay: hard-edged, black, its edge broken by the pleats
local pts = {{430,470}}
for k = 0, 12 do
  local x = 440 + k * 48
  pts[#pts+1] = {x, 562 - (k % 2) * 10 - k * 3}
end
local SH = (poly({{420,466},{1010,470},{1010,570},{470,570}}) * HULL)
  - poly({{420,470},{470,575},{-10,575},{-10,470}})
local edge = {}
for k = 0, 14 do local t = k / 14; edge[#edge+1] = {lerp(420, 520, t) + ((k % 2 == 0) and 0 or 9), lerp(466, 570, t)} end
edge[#edge+1] = {1010, 570}; edge[#edge+1] = {1010, 466}
SH = poly(edge) * HULL
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
work(SH, {hand="body", tool="filbert 6", pile=blk, coverage=3.4, fill=true, angle=0.05, clip=true, load=0.9})
-- the bay mouth: a black slot on the crest with a lit lip
local bay = ellipse(O[1], O[2] + 3, 48, 9) * (HULL:grow(4))
work(bay, {hand="detail", pile=blk, coverage=3, fill=true, angle=0, clip=true})
local lip = brush{kind="round", width=2.2, point=0.5}
lip:load(pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.3}}, 0.7)
local L = {}
for k = 0, 16 do local a = math.pi + k * math.pi / 16; L[#L+1] = {O[1] + math.cos(a) * 50, O[2] + 4 - math.sin(a) * 10} end
lip:stroke(L, {pressure={0.6, 0.2}, ramps={0.05, 0.5}})
-- the crest of the hull lit where the Sun grazes it (left side only)
local rim = brush{kind="round", width=1.8, point=0.6}
rim:load(pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}, 0.6)
rim:stroke({{0,501},{150,479},{300,469},{350,467}}, {pressure={0.3, 0.55}, ramps={0.2, 0.1}})

--@ chunk 11
print(wait(2*24*60))
-- docents on the bay's lip, arms raised, dark against the bright roots of the folds; each with a hairline of light on the Sun side
local fig = pile{{"bone black",3},{"burnt sienna",0.4}}
local rimP = pile{{"lead white",2},{"cadmium yellow",0.4}}
local body = brush{kind="round", width=3.2, point=0.3}
local limb = brush{kind="round", width=1.4, point=0.6}
local rim = brush{kind="round", width=0.8, point=0.9}
for i, d in ipairs({{356, 467, 1.0, 0.2}, {372, 465, 0.9, -0.1}, {428, 465, 0.95, 0.15}, {446, 467, 1.05, -0.2}}) do
  local x, y, s, lean = d[1], d[2], d[3], d[4]
  body:load(fig, 0.85)
  body:stroke({{x, y}, {x + lean, y - 7 * s}, {x + lean * 1.5, y - 12 * s}}, {pressure={0.9, 0.8}, ramps={0.05, 0.05}})
  limb:load(fig, 0.8)
  limb:stroke({{x + lean * 1.5 - 0.5, y - 11 * s}, {x - 3 * s, y - 16 * s}, {x - 4.5 * s, y - 20 * s}}, {pressure={0.8, 0.5}})
  limb:load(fig, 0.8)
  limb:stroke({{x + lean * 1.5 + 0.5, y - 11 * s}, {x + 3 * s, y - 16 * s}, {x + 4.5 * s, y - 20.5 * s}}, {pressure={0.8, 0.5}})
  local h = brush{kind="round", width=2.6, point=0.1}
  h:load(fig, 0.85); h:touch(x + lean * 1.6, y - 14 * s, {pressure=0.8})
  rim:load(rimP, 0.5)
  rim:stroke({{x - 1.2, y - 2}, {x - 1.0 + lean, y - 10 * s}}, {pressure={0.4, 0.2}})
end
-- in the hull's shadow, the plates just glimpsed in the cold light thrown back by the film
local cool = pile{{"ultramarine ash",1},{"bone black",1},{"lead white",0.4}}
local b = brush{kind="round", width=1.6, point=0.6}
local n = 0
for i = 1, 160 do
  local x, y = rand(470, 1000), rand(478, 562)
  local s = lerp(8, 34, ((y - 470) / 95) ^ 1.3)
  if HULL:at(x, y) > 0.5 and x > 420 + (y - 466) * 1 then
    if n % 4 == 0 then b:reload(cool, 0.45) end
    n = n + 1
    b:stroke({{x - s * 0.45, y}, {x, y - s * 0.12}, {x + s * 0.45, y}}, {pressure={0.25, 0.05}, ramps={0.2, 0.6}})
  end
end
-- a few hard stars
local st = brush{kind="round", width=1.4, point=0.6}
local m = 0
for i = 1, 40 do
  local x, y = rand(0, 1000), rand(0, 440)
  if SKY:shrink(3):at(x, y) > 0.5 and FAN:grow(4):at(x, y) < 0.5 then
    if m % 8 == 0 then st:load(pile{{"zinc white",3},{"cerulean blue",0.1}}, 0.5) end
    st:touch(x, y, {pressure=rand(0.15, 0.4)}); m = m + 1
  end
end
print(n, m)
