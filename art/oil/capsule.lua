-- easel session "capsule": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.6667, linen={18,16}, seed=2207, ground={{pile={{"lead white",2},{"yellow ochre",1}}, um=60, apply="knife", texture=0.3},{pile={{"ultramarine blue",2},{"burnt sienna",1.5},{"lead white",0.5}}, um=30, apply="brush"}}}

--@ chunk 2
print(H)
SX, SY, SR = 520, 900, 230
function crest(x) return 1118 + 0.00028 * (x - 520)^2 end
HULL = below(crest)
SKY = -HULL
local steps = {
  {SR, pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.12}}},
  {SR + 22, pile{{"lead white",3},{"lemon chrome",0.5},{"zinc white",0.5}}},
  {SR + 50, pile{{"lead white",2},{"cadmium yellow",0.8},{"lemon chrome",0.2}}},
  {SR + 85, pile{{"cadmium yellow",1},{"lead white",0.8},{"Indian yellow",0.3}}},
  {SR + 130, pile{{"Indian yellow",1},{"cadmium yellow",0.5},{"Mars orange",0.5},{"lead white",0.3}}},
  {SR + 185, pile{{"Mars orange",1},{"red earth",0.5},{"burnt sienna",0.4}}},
  {SR + 255, pile{{"burnt sienna",1},{"red earth",0.4},{"ultramarine blue",0.4},{"bone black",0.1}}},
  {SR + 345, pile{{"ultramarine blue",1},{"burnt sienna",0.9},{"bone black",0.2}}},
  {3000, pile{{"ultramarine blue",1.3},{"burnt sienna",0.7},{"bone black",0.35}}},
}
local prev = nil
for i, s in ipairs(steps) do
  local e = ellipse(SX, SY, s[1], s[1])
  local ring = prev and (e - prev) or e
  local m = ring * SKY
  local hand = (i == #steps or i >= 7) and "broad" or "body"
  local ang = function(x, y) return math.atan(y - SY, x - SX) + math.pi / 2 end
  if i == 1 then ang = 0 end
  work(m, {hand=hand, pile=s[2], angle=ang, coverage=3, fill=true, clip=true})
  prev = e
end

--@ chunk 3
local m = SKY * ellipse(SX, SY, SR + 360, SR + 360) - ellipse(SX, SY, SR - 6, SR - 6) blend(m, {tool={kind="badger", width=20}, angle=function(x, y) return math.atan(y - SY, x - SX) end, coverage=1.6})

--@ chunk 4
print(wait(2 * 24 * 60))
RC = {520, 862}; RX, RY, TL = 610, 175, -0.11
function rpt(t, dy)
  local x, y = RX * math.cos(t), RY * math.sin(t)
  return {RC[1] + x * math.cos(TL) - y * math.sin(TL), RC[2] + x * math.sin(TL) + y * math.cos(TL) + (dy or 0)}
end
function rw(t) return 26 + 30 * (math.sin(t) + 1) / 2 end
local pts, ws = {}, {}
for i = 0, 180 do local t = i / 180 * 2 * math.pi pts[#pts + 1] = rpt(t, rw(t) / 2) ws[#ws + 1] = rw(t) end
RING = ribbon(pts, ws) - HULL
work(RING, {hand="body", pile=pile{{"burnt sienna",1},{"bone black",0.65},{"ultramarine blue",0.4},{"raw sienna",0.3}}, angle=function(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end, coverage=3.5, fill=true, clip=true})
local up = HULL * above(function(x) return crest(x) + 70 end)
work(up, {hand="body", pile=pile{{"burnt sienna",1},{"bone black",0.55},{"raw sienna",0.45},{"ultramarine blue",0.25}}, angle=0, coverage=3, fill=true, clip=true})
work(HULL - up, {hand="broad", pile=pile{{"bone black",1},{"burnt sienna",0.9},{"ultramarine blue",0.5}}, angle=0, coverage=3, fill=true, clip=true})

--@ chunk 5
print(wait(4 * 24 * 60), drying(520, 1060), drying(500, 1160))
-- scale-plates on the hull: rows of small arcs, lit lips catching the sun behind the crest, fading down
local SC = {pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.35},{"raw sienna",0.3}}, pile{{"burnt sienna",1},{"raw sienna",0.6},{"yellow ochre",0.4},{"bone black",0.2}}, pile{{"burnt sienna",1},{"bone black",0.4},{"raw sienna",0.3}}}
local b = brush{kind="round", width=2.2, point=0.4}
local row, y0 = 0, 0
while true do
  local dy = 8 + row * row * 1.6
  y0 = y0 + dy
  if y0 > 390 then break end
  local w = 10 + row * 4.5
  local x = rand(-w, 0)
  local p = SC[math.min(3, 1 + row // 3)]
  b = brush{kind="round", width=1.4 + row * 0.5, point=0.4}
  while x < 1000 + w do
    local yc = crest(x) + y0
    b:load(p, rand(0.4, 0.6))
    b:stroke({{x - w * 0.45, yc + w * 0.12}, {x, yc - w * 0.12}, {x + w * 0.45, yc + w * 0.12}}, {pressure={0.4, 0.25}, ramps={0.2, 0.4}, clip=HULL})
    x = x + w * rand(0.9, 1.15)
  end
  row = row + 1
end
-- windows along the ring: rows of tiny warm lights, a few lit
local WL = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local t = 0
local tb = brush{kind="round", width=1.6, point=0.3}
while t < 2 * math.pi do
  for r = 1, 3 do
    if math.random() < 0.32 then
      local p = rpt(t, rw(t) * (r / 4))
      if RING:at(p[1], p[2]) > 0.5 then tb:load(WL, 0.6) tb:touch(p[1], p[2], {pressure=0.35 + 0.15 * (math.sin(t) + 1) / 2}) end
    end
  end
  t = t + rand(0.006, 0.014)
end

--@ chunk 6
print(wait(2 * 24 * 60))
local GL = pile{{"lead white",2.5},{"lemon chrome",0.35},{"zinc white",0.5}}
local GO = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.3}}
-- glare eats the ring's edges where it crosses the Sun
local rim = (RING - RING:shrink(2.2)) * ellipse(SX, SY, SR + 40, SR + 40)
work(rim, {hand="detail", pile=GL, coverage=3, fill=true, clip=true})
-- the hull's crest catches the Sun behind it
local b = brush{kind="round", width=2.6, point=0.3}
local seg = 40
for x0 = -20, 1000, seg do
  local d = math.abs(x0 + seg / 2 - SX)
  local pr = clamp(0.8 - d / 700, 0.15, 0.8)
  b:load(d < 300 and GL or GO, 0.7)
  b:stroke({{x0, crest(x0) + 1.2}, {x0 + seg / 2, crest(x0 + seg / 2) + 1.2}, {x0 + seg + 2, crest(x0 + seg + 2) + 1.2}}, {pressure={pr, pr}, ramps={0.05, 0.05}})
end
-- the Commando on the crest, his back to us, looking at the Sun
local x, y, u = 520, crest(520) + 1, 2.1
local L = function(dx, dy) return {x + dx * u, y + dy * u} end
local f = body_of{spine={L(0, -25.4), L(0, -22.5), L(0, -19), L(0.1, -14), L(0, -10)}, widths={3.6 * u, 2.6 * u, 9 * u, 6.4 * u, 5.8 * u}, limbs={
  {L(-1.6, -10), L(-2.2, -5), L(-2.8, 0), widths={2.6 * u, 2.3 * u, 2.5 * u}},
  {L(1.6, -10), L(2.0, -5), L(2.4, 0), widths={2.6 * u, 2.3 * u, 2.5 * u}},
  {L(-4.4, -19), L(-5.2, -13.5), L(-5.4, -8.5), widths={2.3 * u, 2.0 * u, 1.9 * u}},
  {L(4.4, -19), L(5.6, -14), L(7.2, -10.5), widths={2.3 * u, 2.0 * u, 1.9 * u}},
  {L(7.0, -11), L(7.8, -4), L(8.2, 1), widths={0.9 * u, 0.8 * u, 0.7 * u}},
}, char="firm", amount=0.12}
FIG = f:mask()
work(FIG, {hand="detail", pile=pile{{"bone black",1.4},{"ultramarine blue",0.5},{"burnt sienna",0.5}}, coverage=5, fill=true, clip=true})

--@ chunk 7
print(wait(2 * 24 * 60), drying(520, 1070))
-- the glare eats the near band of the ring where it crosses the disc: the figure stands against pure light
local core = ellipse(SX, SY, SR - 12, SR - 12) * below(function(x) return 985 end)
local eat = (RING * core):grow(2):roughen(3, 14, 5) * core - FIG:grow(1.2)
work(eat, {hand="detail", pile=pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.12}}, coverage=5, fill=true, clip=true})
local fade = ((RING * ellipse(SX, SY, SR + 30, SR + 30)) - core):grow(1) * below(function(x) return 985 end) * (ellipse(SX, SY, SR + 30, SR + 30) - ellipse(SX, SY, SR - 14, SR - 14))
work(fade, {hand="detail", pile=pile{{"lead white",2.5},{"lemon chrome",0.4},{"cadmium yellow",0.2}}, coverage=2.2, fill=true, clip=true, load=0.5})

--@ chunk 8
print(wait(2 * 24 * 60))
-- a few stars, far from the Sun, sparse and uneven
local SP = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.05}}
local b = brush{kind="round", width=1.6, point=0.6}
local n = 0
for i = 1, 140 do
  local x, y = rand(10, 990), rand(10, 620)
  local d = math.sqrt((x - SX)^2 + (y - SY)^2)
  if d > SR + 380 and math.random() < 0.75 then
    b:load(SP, rand(0.3, 0.6)) b:touch(x, y, {pressure=(math.random() < 0.08) and 0.55 or rand(0.12, 0.28)})
    n = n + 1
  end
end
-- rows of tiny windows in the hull below the crest, a few lit
local WL = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local wb = brush{kind="round", width=1.8, point=0.3}
for r, dy in ipairs({34, 52, 78}) do
  local x = rand(0, 8)
  while x < 1000 do
    if math.random() < 0.22 - r * 0.04 then
      wb:load(WL, 0.6) wb:touch(x, crest(x) + dy, {pressure=0.35 + 0.05 * r})
    end
    x = x + (5 + r * 2.5) * rand(0.8, 1.3)
  end
end
print(n)

--@ chunk 9
print(wait(5 * 24 * 60), drying(520, 600), drying(300, 700))
local OUT = SR + 380
ANN = (ellipse(SX, SY, OUT, OUT) - ellipse(SX, SY, SR - 4, SR - 4)) - RING:grow(2) - HULL:grow(1)
local RADA = function(x, y) return math.atan(y - SY, x - SX) end
local steps = {
  {SR - 4, SR + 30, pile{{"lead white",3},{"lemon chrome",0.45},{"zinc white",0.5}}},
  {SR + 30, SR + 70, pile{{"lead white",2},{"cadmium yellow",0.8},{"lemon chrome",0.25}}},
  {SR + 70, SR + 115, pile{{"cadmium yellow",1},{"lead white",0.7},{"Indian yellow",0.35}}},
  {SR + 115, SR + 165, pile{{"Indian yellow",1},{"cadmium yellow",0.4},{"Mars orange",0.6},{"lead white",0.2}}},
  {SR + 165, SR + 225, pile{{"Mars orange",1},{"red earth",0.6},{"burnt sienna",0.4}}},
  {SR + 225, SR + 295, pile{{"burnt sienna",1},{"red earth",0.4},{"ultramarine blue",0.5},{"bone black",0.1}}},
  {SR + 295, OUT, pile{{"ultramarine blue",1.1},{"burnt sienna",0.85},{"bone black",0.25}}},
}
for _, s in ipairs(steps) do
  local band = (ellipse(SX, SY, s[2], s[2]) - ellipse(SX, SY, s[1], s[1])) * ANN
  work(band, {hand="body", pile=s[3], angle=RADA, length={40, 90}, coverage=3, fill=true, clip=ANN, angle_jitter=0.03})
end
blend(ANN, {tool={kind="badger", width=12}, angle=RADA, coverage=1.2})

--@ chunk 10
print(wait(2 * 24 * 60))
local OUT = SR + 380
local edgeband = (ellipse(SX, SY, OUT + 35, OUT + 35) - ellipse(SX, SY, OUT - 45, OUT - 45)) - RING:grow(2) - HULL:grow(1)
blend(edgeband, {tool={kind="badger", width=12}, angle=function(x, y) return math.atan(y - SY, x - SX) end, coverage=1.5})
local RADA = function(x, y) return math.atan(y - SY, x - SX) end
-- a few long streaks, unevenly spaced
local GL = pile{{"lead white",2.5},{"lemon chrome",0.4},{"cadmium yellow",0.3},medium=0.2}
local GO = pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.6},medium=0.2}
local b = brush{kind="round", width=3.5, point=0.7}
local a = -math.pi + 0.2
local n = 0
while a < 0.25 do
  local r0, r1 = SR + rand(5, 25), SR + rand(140, 300)
  local p = {}
  for i = 0, 6 do local r = lerp(r0, r1, i / 6) p[#p + 1] = {SX + r * math.cos(a + 0.01 * i * randn(0, 1)), SY + r * math.sin(a)} end
  b:load((math.random() < 0.6) and GL or GO, rand(0.35, 0.5))
  b:stroke(p, {pressure={0.55, 0}, ramps={0.05, 0.9}, clip=ANN})
  n = n + 1
  a = a + rand(0.12, 0.38)
end
-- the hot rim on the figure's helmet and shoulders
local RIM = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.25}}
local edge = (FIG - FIG:shrink(0.7)) * above(function(x) return 1084 end)
work(edge, {hand="detail", pile=RIM, coverage=3, fill=true, clip=true})
print(n)

--@ chunk 11
local OUT = SR + 380
local clipm = SKY - RING:grow(2)
local P1 = pile{{"ultramarine blue",1.1},{"burnt sienna",0.9},{"red earth",0.15},{"bone black",0.2}}
local P2 = pile{{"ultramarine blue",1.2},{"burnt sienna",0.75},{"bone black",0.3}}
local b = brush{kind="filbert", width=7, stiffness=0.5}
local a = -math.pi
while a < 0.4 do
  local r0 = OUT + rand(-55, -20)
  local r1 = OUT + rand(15, 60)
  local aa = a + randn(0, 0.004)
  b:load((math.random() < 0.5) and P1 or P2, rand(0.25, 0.45))
  b:stroke({{SX + r0 * math.cos(aa), SY + r0 * math.sin(aa)}, {SX + r1 * math.cos(aa), SY + r1 * math.sin(aa)}}, {pressure={0.15, 0.5}, ramps={0.5, 0.2}, clip=clipm})
  a = a + rand(0.006, 0.014)
end

--@ chunk 12
work(FIG:shrink(0.4) * rect(495, 1086, 50, 18), {hand="detail", tool={kind="round", width=1.2}, pile=pile{{"bone black",1.4},{"ultramarine blue",0.5},{"burnt sienna",0.5}}, coverage=5, fill=true, clip=true})
