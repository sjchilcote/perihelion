-- easel session "farewell": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=7777,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.7},{"lead white",0.2}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
HULLC = {{-10,420},{150,404},{300,396},{450,394},{600,398},{780,410},{1010,430}}
HULL = below(HULLC)
SKY = everywhere() - HULL
SUN = {200, 170}
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
work(SKY, {hand="broad", pile=pile{{"bone black",2.5},{"ultramarine blue",0.8},{"cobalt violet",0.1}}, coverage=3, fill=true, angle=0.02, angle_jitter=0.2, clip=SKY})
-- a low warm band of the corona's afterglow along the sky near the Sun, deepening up to violet-black
local g1 = SKY * mask(function(x, y) return rd(x, y) < 330 and 1 or 0 end)
work(g1, {hand="broad", pile=pile{{"burnt sienna",1},{"rose madder",0.5},{"bone black",0.8},{"ultramarine blue",0.3}}, coverage=2.2, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, clip=SKY})
local g2 = SKY * mask(function(x, y) return rd(x, y) < 170 and 1 or 0 end)
work(g2, {hand="broad", pile=pile{{"Mars orange",1},{"burnt sienna",0.8},{"rose madder",0.3},{"lead white",0.2}}, coverage=2.2, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, clip=SKY})
blend(SKY * mask(function(x, y) return rd(x, y) < 380 and 1 or 0 end), {angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end})
work(HULL, {hand="broad", pile=pile{{"bone black",2},{"burnt sienna",1.2},{"raw sienna",0.3}}, coverage=3, fill=true, angle=0.05, clip=HULL:grow(2)})

--@ chunk 3
print(wait(3*24*60))
-- the swirl reads as a planet: back to night sky; then the Sun small, its corona a modest glow of short strokes
local dark = SKY - ellipse(SUN[1], SUN[2], 40, 40)
work(dark, {hand="body", tool="filbert 10", pile=pile{{"bone black",2.6},{"ultramarine blue",0.8},{"cobalt violet",0.1}}, coverage=3.6, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, clip=SKY, length={80, 220}, load=0.95})

--@ chunk 4
print(wait(3*24*60))
local cW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.35}}
local cG = pile{{"lead white",1.5},{"cadmium yellow",0.7},{"Mars orange",0.4}}
local cO = pile{{"Mars orange",1},{"rose madder",0.3},{"lead white",0.5}}
local t = brush{kind="round", width=1.8, point=0.6}
local m = brush("filbert", 4)
for i = 1, 160 do
  local a = rand(-math.pi, math.pi); local r0 = rand(14, 22)
  local len = 10 + 150 * rand(0, 1)^2.2
  local br = (len > 60) and m or t
  br:reload((len < 35) and cW or ((len < 80) and cG or cO), 0.5)
  br:stroke({{SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0}, {SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)}}, {pressure={0.5, 0.02}, ramps={0.05, 0.85}, orient="along", clip=SKY})
end
local d = ellipse(SUN[1], SUN[2], 16, 16)
work(d, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=3, fill=true, angle=0, clip=true})
-- stars coming out, more of them away from the Sun
local st = brush{kind="round", width=1.8, point=0.5}
local n = 0
for i = 1, 260 do
  local x, y = rand(0, 1000), rand(0, 400)
  local dd = math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2)
  if SKY:shrink(3):at(x, y) > 0.5 and dd > 140 and math.random() < smoothstep(140, 600, dd) + 0.2 then
    if n % 6 == 0 then st:load(pile{{"zinc white",4},{"cerulean blue",0.08}}, 0.55) end
    st:touch(x, y, {pressure=rand(0.12, 0.55)}); n = n + 1
  end
end
print(n)

--@ chunk 5
-- the sail furling back into its bay: a narrow pleated fan of dark film drawing down into the hull
O = {770, 404}
A0, A1 = -1.55, -0.72
NP = 16
PL = {}
for i = 0, NP do
  local a = lerp(A0, A1, i / NP)
  local R = 330 - 90 * math.abs(i / NP - 0.45) * 2
  PL[#PL + 1] = {a = a, r = R * ((i % 2 == 0) and 1.0 or 0.86)}
end
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
local fA = pile{{"bone black",2.2},{"ultramarine blue",1},{"cobalt violet",0.3}}
local fB = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
FAN = nil
for i = 1, NP do
  local a, b = PL[i], PL[i + 1]
  local m = poly({P(a.a, 10), P(a.a, a.r), P(b.a, b.r), P(b.a, 10)}) - HULL
  FAN = FAN and (FAN + m) or m
  work(m, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=(i % 2 == 0) and fB or fA, coverage=3.4, fill=true, angle=(a.a + b.a) / 2, clip=true})
end

--@ chunk 6
print(wait(3*24*60))
-- fold-lines: long gold strokes down each crease, laid in segments with fresh paint; brightest on the creases facing the Sun (left)
local function P(a, r) return {O[1] + math.cos(a) * r, O[2] + math.sin(a) * r} end
local hot = pile{{"lead white",2.5},{"cadmium yellow",0.5},{"Mars orange",0.2}}
local gold = pile{{"lead white",1.5},{"cadmium yellow",0.7},{"Mars orange",0.4}}
local dim = pile{{"burnt sienna",1},{"Mars orange",0.5},{"lead white",0.4}}
local b = brush{kind="round", width=2.2, point=0.5}
for i = 1, NP + 1 do
  local c = PL[i]
  local face = 1 - (i - 1) / NP
  if i % 2 == 0 then face = face * 0.5 end
  local p = (face > 0.6) and hot or ((face > 0.3) and gold or dim)
  local R = c.r
  for k, cut in ipairs({{0.08, 0.4}, {0.38, 0.72}, {0.7, 0.99}}) do
    b:reload(p, 0.8)
    b:stroke({P(c.a, R * cut[1]), P(c.a, R * (cut[1] + cut[2]) / 2), P(c.a, R * cut[2])}, {pressure={0.3 + 0.4 * face, 0.25 + 0.35 * face}, ramps={0.2, 0.2}, clip=FAN:grow(3)})
  end
end
-- the tip edges catching the light: short zigzag along the pleat ends
local e = brush{kind="round", width=1.6, point=0.6}
for i = 1, NP do
  local a, c = PL[i], PL[i + 1]
  e:load((i < NP / 2) and hot or gold, 0.6)
  e:stroke({P(a.a, a.r), P(c.a, c.r)}, {pressure={0.5, 0.3}})
end
-- spars along the fan's two edges, and the bay's lit lip
local sp = brush{kind="round", width=3, point=0.4}
for _, c in ipairs({PL[1], PL[NP + 1]}) do sp:load(gold, 0.6); sp:stroke({P(c.a, 8), P(c.a, c.r + 14)}, {pressure={0.6, 0.3}}) end
local lip = brush{kind="round", width=2.2, point=0.5}
lip:load(gold, 0.6)
local L = {}
for k = 0, 14 do local aa = math.pi + k * math.pi / 14; L[#L+1] = {O[1] + math.cos(aa) * 46, O[2] + 6 - math.sin(aa) * 8} end
lip:stroke(L, {pressure={0.6, 0.1}, ramps={0.05, 0.6}})

--@ chunk 7
-- hull a step darker, then its plates: rows in perspective, each with a warm lit lip toward the low Sun and a black shadow under it
work(HULL, {hand="body", tool="filbert 8", pile=pile{{"bone black",2.4},{"burnt sienna",1},{"raw sienna",0.2}}, coverage=3.2, fill=true, angle=0.05, clip=HULL, load=0.9})

--@ chunk 8
print(wait(3*24*60))
local plBody = pile{{"burnt sienna",1.2},{"raw sienna",0.6},{"bone black",0.9}}
local plLit = pile{{"Mars orange",1},{"raw sienna",0.8},{"lead white",0.8},{"rose madder",0.15}}
local plShad = pile{{"bone black",3},{"ultramarine blue",0.3}}
local B = {}
local function bb(k, w) w = math.max(2, math.floor(w + 0.5)); local key = k .. w; if not B[key] then B[key] = brush(k, w) end; return B[key] end
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 430 end
local n = 0
for row = 0, 9 do
  local t = row / 9
  local s = lerp(7, 30, t ^ 1.4)
  local dy = lerp(6, 150, t ^ 1.3)
  local x = -s + (row % 2) * s * 0.5
  while x < 1000 + s do
    local y = crest(clamp(x, 0, 1000)) + dy
    if not (math.abs(x - O[1]) < 50 and dy < 20) then
      local hw = s * 0.5
      local warm = clamp(1 - math.abs(x - 250) / 700, 0.15, 1)
      local b1 = bb("filbert", s * 0.8)
      b1:reload(plBody, 0.55)
      b1:stroke({{x - hw, y}, {x, y + s * 0.12}, {x + hw, y}}, {pressure={0.75, 0.65}, ramps={0.1, 0.2}, clip=HULL})
      local b2 = bb("round", math.max(1.5, s * 0.13))
      b2:reload(plShad, 0.6)
      b2:stroke({{x - hw * 1.05, y + s * 0.38}, {x, y + s * 0.5}, {x + hw * 1.05, y + s * 0.38}}, {pressure={0.7, 0.3}, ramps={0.1, 0.3}, clip=HULL})
      if math.random() < 0.3 + 0.6 * warm then
        b2:reload(plLit, 0.6)
        b2:stroke({{x - hw * 0.95, y - s * 0.05}, {x - hw * 0.5, y - s * 0.22}, {x, y - s * 0.24}}, {pressure={0.55 * warm + 0.1, 0.05}, ramps={0.1, 0.5}, clip=HULL})
      end
      n = n + 1
    end
    x = x + s * 0.95
  end
end
print(n)

--@ chunk 9
print(wait(3*24*60))
-- the hull far too light and even: a dark transparent glaze over it, heaviest away from the low Sun, so the plates sink into dusk
local gz = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.3}, medium=0.55}
work(HULL, {hand="glaze", pile=gz, coverage=2.2, fill=true, angle=0.03, clip=HULL, pressure={0.4, 0.6},
  load_at=function(x, y) return 0.55 + 0.4 * smoothstep(150, 900, x) + 0.2 * smoothstep(420, 560, y) end})

--@ chunk 10
print(wait(4*24*60))
-- lights last on dry paint: warm lips on the plates, densest and warmest toward the low Sun, the crest catching a long thin line
local plLit = pile{{"Mars orange",1},{"raw sienna",0.6},{"lead white",1},{"rose madder",0.15}}
local hot = pile{{"lead white",2},{"cadmium yellow",0.4},{"Mars orange",0.5}}
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 430 end
local B = {}
local function bb(w) w = math.max(1.5, math.floor(w * 2 + 0.5) / 2); if not B[w] then B[w] = brush{kind="round", width=w, point=0.6} end; return B[w] end
for row = 0, 9 do
  local t = row / 9
  local s = lerp(7, 30, t ^ 1.4)
  local dy = lerp(6, 150, t ^ 1.3)
  local x = -s + (row % 2) * s * 0.5
  while x < 1000 + s do
    local y = crest(clamp(x, 0, 1000)) + dy
    local warm = clamp(1 - math.abs(x - 220) / 650, 0, 1) * (1 - 0.5 * t)
    if math.random() < 0.15 + 0.75 * warm and not (math.abs(x - O[1]) < 50 and dy < 20) then
      local hw = s * 0.5
      local b = bb(s * 0.12)
      b:reload((warm > 0.6 and row < 4) and hot or plLit, 0.6)
      b:stroke({{x - hw * 0.95, y - s * 0.05}, {x - hw * 0.5, y - s * 0.22}, {x + hw * 0.1, y - s * 0.24}}, {pressure={0.25 + 0.5 * warm, 0.05}, ramps={0.1, 0.5}, clip=HULL})
    end
    x = x + s * 0.95
  end
end
local r = brush{kind="round", width=1.8, point=0.6}
r:load(hot, 0.6)
r:stroke({{0,421},{150,405},{300,397},{450,395},{560,397}}, {pressure={0.55, 0.15}, ramps={0.05, 0.6}})

--@ chunk 11
-- the watchers on the crest, small, facing left toward the Sun: tall slender docents, the Commando, three crew children
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 430 end
WATCH = nil
local function add(m) WATCH = WATCH and (WATCH + m) or m end
local function docent(x, h)
  local y = crest(x) + 1
  add(poly({{x - 3, y}, {x - 2.6, y - h * 0.7}, {x - 2, y - h * 0.82}, {x + 2, y - h * 0.82}, {x + 2.8, y - h * 0.7}, {x + 3.2, y}}))
  add(ellipse(x - 0.4, y - h * 0.9, 2.2, 3.6))
end
local function commando(x)
  local y = crest(x) + 1
  add(poly({{x - 3.4, y}, {x - 3, y - 9}, {x - 4.6, y - 13}, {x - 5, y - 17}, {x + 5, y - 17}, {x + 4.6, y - 13}, {x + 3, y - 9}, {x + 3.4, y}}))
  add(poly({{x - 2.6, y - 17}, {x - 2.6, y - 22}, {x + 2.4, y - 22}, {x + 2.4, y - 17}}))
end
local function child(x, h)
  local y = crest(x) + 1
  add(poly({{x - 1.8, y}, {x - 1.6, y - h * 0.68}, {x + 1.6, y - h * 0.68}, {x + 1.8, y}}))
  add(ellipse(x, y - h * 0.82, 1.9, 2.1))
end
docent(372, 30); docent(388, 33); child(402, 12); commando(414); child(426, 10); child(434, 13); docent(450, 31); docent(468, 29); docent(484, 32)
work(WATCH, {hand="detail", tool={kind="round", width=1.0, point=0.7}, pile=blk, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})

--@ chunk 12
print(wait(3*24*60))
-- rimmed warm on the side facing the Sun (left); the Commando's rag; a docent's hand resting on a child's shoulder; the Commando lifting a hand
local rim = pile{{"lead white",2},{"Mars orange",0.5},{"cadmium yellow",0.4}}
local nz = noise{seed=3, period=3}
local edge = mask(function(x, y)
  if x < 360 or x > 495 or y < 350 or y > 400 then return 0 end
  if WATCH:at(x, y) < 0.5 then return 0 end
  if WATCH:at(x - 0.9, y - 0.5) > 0.5 then return 0 end
  return 1 end)
work(edge, {hand="detail", tool={kind="round", width=0.7, point=0.9}, pile=rim, coverage=2.2, fill=true, clip=true, angle=1.4})
local f = brush{kind="round", width=1.1, point=0.8}
local y = 395.6
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5}}, 0.6)
f:stroke({{417, y - 16}, {422, y - 18}, {426, y - 17}}, {pressure={0.6, 0.15}})
f:load(pile{{"bone black",3}}, 0.7)
f:stroke({{410.5, y - 15}, {406, y - 22}, {404, y - 26}}, {pressure={0.55, 0.4}})
f:load(pile{{"bone black",3}}, 0.7)
f:stroke({{391, y - 22}, {396, y - 18}, {400, y - 10}}, {pressure={0.4, 0.3}})

--@ chunk 13
print(wait(3*24*60))
-- the watchers read as posts: paint them out (sky above the crest, hull below), to be drawn again larger and clearer
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 430 end
local z = WATCH:grow(3) + rect(400, 372, 30, 10)
local zs = z * SKY
work(zs, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=pile{{"bone black",2.6},{"ultramarine blue",0.8},{"cobalt violet",0.1}}, coverage=4, fill=true, angle=0, clip=true, load=1.0})

--@ chunk 14
print(wait(3*24*60))
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 430 end
W2 = nil
HEADS = {}
local function add(m) W2 = W2 and (W2 + m) or m end
local function docent(x, h, tilt)
  local y = crest(x) + 1
  -- robed body flaring to the hull, narrow shoulders, long neck, elongated head tilted toward the Sun
  add(poly({{x - 7, y}, {x - 4.5, y - h * 0.35}, {x - 3.6, y - h * 0.66}, {x - 2.2, y - h * 0.72}, {x + 2.2, y - h * 0.72}, {x + 3.6, y - h * 0.66}, {x + 4.5, y - h * 0.35}, {x + 7, y}}, true))
  add(poly({{x - 1, y - h * 0.72}, {x - 1, y - h * 0.79}, {x + 1, y - h * 0.79}, {x + 1, y - h * 0.72}}))
  local hx, hy = x - 1.5 - tilt, y - h * 0.88
  add(ellipse(hx, hy, 3.2, 5.6))
  HEADS[#HEADS + 1] = {hx, hy, 3.2, 5.6}
end
local function commando(x)
  local y = crest(x) + 1
  add(ribbon({{x - 2.5, y}, {x - 2.2, y - 14}}, 4.4) + ribbon({{x + 2.5, y}, {x + 2.2, y - 14}}, 4.4))
  add(poly({{x - 5, y - 13}, {x + 5, y - 13}, {x + 6, y - 24}, {x + 9, y - 30}, {x - 9, y - 30}, {x - 6, y - 24}}, true))
  add(poly({{x - 4, y - 30}, {x - 4, y - 37}, {x + 3.6, y - 37}, {x + 3.6, y - 30}}))
  HEADS[#HEADS + 1] = {x, y - 34, 4, 4}
end
local function child(x, h)
  local y = crest(x) + 1
  add(ribbon({{x - 1.3, y}, {x - 1.2, y - h * 0.4}}, 2.2) + ribbon({{x + 1.3, y}, {x + 1.2, y - h * 0.4}}, 2.2))
  add(poly({{x - 2.6, y - h * 0.38}, {x + 2.6, y - h * 0.38}, {x + 2.2, y - h * 0.72}, {x - 2.2, y - h * 0.72}}, true))
  add(ellipse(x, y - h * 0.84, 2.7, 2.9))
  HEADS[#HEADS + 1] = {x, y - h * 0.84, 2.7, 2.9}
end
docent(372, 56, 1.0); docent(392, 60, 0.6); child(408, 22); commando(424); child(440, 18); child(452, 24); docent(470, 58, 1.2); docent(490, 54, 0.4); docent(508, 60, 0.8)
work(W2, {hand="detail", tool={kind="round", width=1.0, point=0.7}, pile=blk, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})
-- linking hands: a docent's hand on a child's shoulder, a child's hand in the Commando's
local f = brush{kind="round", width=1.3, point=0.7}
f:load(blk, 0.8); f:stroke({{395, crest(395) - 36}, {402, crest(402) - 28}, {406, crest(406) - 18}}, {pressure={0.6, 0.5}})
f:load(blk, 0.8); f:stroke({{430, crest(430) - 26}, {434, crest(434) - 18}, {437, crest(437) - 11}}, {pressure={0.6, 0.5}})

--@ chunk 15
print(wait(4*24*60))
-- warm rim on each watcher's sunward (left, upper) edges: a thin broken line, brightest on heads and shoulders
local rim = pile{{"lead white",2},{"Mars orange",0.6},{"cadmium yellow",0.4}}
local hot = pile{{"lead white",2.5},{"cadmium yellow",0.5},{"Mars orange",0.3}}
local nz = noise{seed=8, period=4}
local edge = mask(function(x, y)
  if x < 355 or x > 525 or y < 320 or y > 400 then return 0 end
  if W2:at(x, y) < 0.5 then return 0 end
  if W2:at(x - 1.1, y - 0.6) > 0.5 then return 0 end
  return (nz:at01(x, y) > 0.22) and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=0.8, point=0.9}, pile=rim, coverage=2.2, fill=true, clip=true, angle=1.3})
local top = edge * mask(function(x, y) return (y < 372) and 1 or 0 end)
work(top, {hand="detail", tool={kind="round", width=0.8, point=0.9}, pile=hot, coverage=1.8, fill=true, clip=true, angle=1.3})
-- the docents' single lenses catching the Sun, and the Commando's visor
local g = brush{kind="round", width=1.3, point=0.6}
for _, h in ipairs(HEADS) do
  g:load(pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.3}}, 0.55)
  g:touch(h[1] - h[3] * 0.6, h[2] - h[4] * 0.1, {pressure=0.35})
end
-- the Commando's rag lifting off the shoulder, away from the Sun
local f = brush{kind="round", width=1.6, point=0.7}
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5}}, 0.65)
f:stroke({{432, 359}, {438, 356}, {444, 357}, {450, 354}}, {pressure={0.65, 0.1}, ramps={0.1, 0.5}})
-- long shadows behind them, running right along the crest
local s = brush("filbert", 3)
for _, x in ipairs({372, 392, 408, 424, 440, 452, 470, 490, 508}) do
  s:load(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.7)
  s:stroke({{x + 3, 396}, {x + 40, 397.5}}, {pressure={0.6, 0.05}, ramps={0.05, 0.8}, clip=HULL})
end
