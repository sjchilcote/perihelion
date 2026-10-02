-- easel session "hokusai": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=1831,
  ground={{pile={{"lead white",3},{"yellow ochre",0.4},{"raw sienna",0.1}}, um=80, apply="knife", texture=0.2}}}
LIMB = {{-10, 600}, {250, 580}, {500, 572}, {750, 578}, {1010, 596}}
SUN = below(LIMB)
WOUT = {{-10, 640}, {-10, 420}, {60, 300}, {150, 190}, {260, 112}, {380, 78}, {480, 92}, {560, 135}, {612, 196}, {628, 262}}
WIN = {{596, 236}, {560, 200}, {505, 178}, {440, 180}, {380, 212}, {338, 275}, {326, 355}, {350, 445}, {405, 525}, {470, 585}, {540, 620}}
local pts = {} for _, p in ipairs(WOUT) do pts[#pts+1] = p end for _, p in ipairs(WIN) do pts[#pts+1] = p end
WAVE = poly(pts, true)
SKY = rect(0, 0, 1000, 667) - SUN - WAVE
CART = rect(40, 30, 90, 150)
local sky = pile{{"ultramarine blue",1.2},{"cerulean blue",0.5},{"bone black",0.25},{"lead white",0.25}}
local sun = pile{{"cadmium yellow",1},{"Mars orange",0.35},{"lead white",0.4}}
local body = pile{{"Mars orange",1},{"cadmium red",0.5},{"red lead",0.3}}
work(SKY - CART, {hand="body", pile=sky, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(SUN - WAVE, {hand="body", pile=sun, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(WAVE, {hand="body", pile=body, coverage=3.5, fill=true, clip=true, angle=-0.8, load=1})
print(wait(5*1440))

--@ chunk 2
local upper = rect(0, 0, 1000, 470)
local gold = pile{{"cadmium yellow",1},{"Mars orange",0.25},{"lead white",0.3}}
local cream = pile{{"lead white",2.5},{"yellow ochre",0.4},{"cadmium yellow",0.2}}
local deep = pile{{"cadmium red",1},{"Mars red",0.6},{"bone brown",0.15}}
GBAND = (WAVE:shrink(16) - WAVE:shrink(38)) * upper
CRIM = (WAVE - WAVE:shrink(10)) * rect(0, 0, 1000, 330)
CORE = WAVE:shrink(60)
work(CORE, {hand="body", tool="filbert 8", pile=deep, coverage=3.5, fill=true, clip=true, angle=-0.8, load=1})
work(GBAND, {hand="detail", tool="round 3", pile=gold, coverage=4, fill=true, load=1})
work(CRIM, {hand="detail", tool="round 3", pile=cream, coverage=4, fill=true, load=1})
-- small wavelets on the Sun's surface: flat gold-orange humps, like Hokusai's sea swells
local orangeS = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.2}}
for _, w in ipairs({{560, 590, 70, 18}, {700, 588, 60, 15}, {840, 596, 75, 18}, {960, 604, 55, 14}, {640, 625, 90, 20}, {820, 640, 100, 22}}) do
  local m = ellipse(w[1], w[2], w[3], w[4]) * above(function(x) return w[2] end) * SUN - WAVE
  work(m, {hand="detail", tool="round 3", pile=orangeS, coverage=4, fill=true, load=1})
end
print(wait(5*1440))

--@ chunk 3
local cream = pile{{"lead white",2.5},{"yellow ochre",0.4},{"cadmium yellow",0.2}}
local dk = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.2}}
-- claws: hooked fingers of plasma breaking off the crest, curling forward
local path = {{150, 190}, {260, 112}, {380, 78}, {480, 92}, {560, 135}, {612, 196}, {628, 262}}
local function at(t)
  local n = #path - 1; local f = t * n; local i = math.min(n, math.floor(f) + 1); local u = f - (i - 1)
  local a, b = path[i], path[i + 1]
  return lerp(a[1], b[1], u), lerp(a[2], b[2], u), b[1] - a[1], b[2] - a[2]
end
local cb = brush{kind="round", width=5, point=0.7}
for k = 0, 22 do
  local t = 0.04 + 0.9 * k / 22
  local x, y, dx, dy = at(t)
  local L = math.sqrt(dx*dx + dy*dy); dx, dy = dx / L, dy / L
  local nx, ny = dy, -dx   -- outward (up/left of travel)
  local s = 10 + 14 * math.sin(math.pi * t)
  local pts = {{x - nx * 2, y - ny * 2}, {x + nx * s * 0.6 + dx * s * 0.2, y + ny * s * 0.6 + dy * s * 0.2},
               {x + nx * s * 0.8 + dx * s * 0.7, y + ny * s * 0.8 + dy * s * 0.7}, {x + nx * s * 0.45 + dx * s * 1.05, y + ny * s * 0.45 + dy * s * 1.05}}
  cb:reload(cream, 0.8); cb:stroke(pts, {pressure={0.85, 0.05}, ramps={0.05, 0.7}})
end
-- spray: a few loose drops flung off the crest
for i = 1, 26 do
  local x, y = at(rand(0.2, 0.95))
  local d = rand(26, 60)
  local b = brush{kind="round", width=rand(2.5, 4.5), point=0.2}
  b:reload(cream, 0.7); b:touch(x + rand(-10, 30), y - d * rand(0.4, 1), {pressure=0.6})
end
-- the TESTAMENT, small and calm in the trough: a spine and its ring
local tx, ty = 512, 572
local spine = poly({{tx - 4, ty}, {tx + 4, ty}, {tx + 2, ty - 62}, {tx - 2, ty - 62}})
work(spine, {hand="detail", tool="round 1.4", pile=dk, coverage=5, fill=true})
local ring = {} for i = 0, 40 do local a = i * math.pi / 20; ring[#ring+1] = {tx + 30 * math.cos(a), ty - 34 + 9 * math.sin(a)} end
local rb = brush{kind="round", width=3, point=0.4}
rb:reload(dk, 0.9); rb:stroke(ring, {pressure={0.75, 0.75}, ramps={0.02, 0.02}})
work(poly({{tx - 16, ty}, {tx + 16, ty}, {tx + 6, ty - 10}, {tx - 6, ty - 10}}), {hand="detail", tool="round 1.4", pile=dk, coverage=5, fill=true})
-- CUCULUS sparks, like the boats: long slim cream hulls on the wave's face
for _, s in ipairs({{372, 430, -1.15}, {402, 492, -0.95}, {446, 548, -0.7}}) do
  local b = brush{kind="round", width=4.5, point=0.8}
  local a = s[3]; local L = 26
  b:reload(cream, 0.8); b:stroke({{s[1] - L/2 * math.cos(a), s[2] - L/2 * math.sin(a)}, {s[1] + L/2 * math.cos(a), s[2] + L/2 * math.sin(a)}}, {pressure={0.1, 0.8}, swell={0.3, 1, 1, 0.3}, ramps={0.3, 0.3}})
end
print(wait(5*1440))

--@ chunk 4
local cream = pile{{"lead white",2.5},{"yellow ochre",0.4},{"cadmium yellow",0.2}}
local ink = pile{{"bone brown",1},{"bone black",0.6},{"ultramarine blue",0.2}}
local path = {{120, 215}, {180, 165}, {260, 112}, {380, 78}, {480, 92}, {560, 135}, {612, 196}, {628, 262}}
local function at(t)
  local n = #path - 1; local f = t * n; local i = math.min(n, math.floor(f) + 1); local u = f - (i - 1)
  local a, b = path[i], path[i + 1]
  return lerp(a[1], b[1], u), lerp(a[2], b[2], u), b[1] - a[1], b[2] - a[2]
end
-- big claws: fingers reaching up and forward, curling down at the tips
local CL = {}
for k = 0, 15 do
  local t = 0.03 + 0.92 * k / 15
  local x, y, dx, dy = at(t)
  local L = math.sqrt(dx*dx + dy*dy); dx, dy = dx / L, dy / L
  local nx, ny = dy, -dx
  local s = 22 + 26 * math.sin(math.pi * clamp(t * 1.1, 0, 1))
  local pts = {{x - nx * 3, y - ny * 3}, {x + nx * s * 0.55 + dx * s * 0.1, y + ny * s * 0.55 + dy * s * 0.1},
               {x + nx * s * 0.85 + dx * s * 0.55, y + ny * s * 0.85 + dy * s * 0.55}, {x + nx * s * 0.7 + dx * s * 0.95, y + ny * s * 0.7 + dy * s * 0.95},
               {x + nx * s * 0.35 + dx * s * 1.05, y + ny * s * 0.35 + dy * s * 1.05}}
  CL[#CL + 1] = pts
  local b = brush{kind="round", width=8, point=0.8}
  b:reload(cream, 0.9); b:stroke(pts, {pressure={0.9, 0.05}, ramps={0.05, 0.75}})
end
print(wait(4*1440))
-- ink outlines on dry paint
local function line(pts, w, pr) local b = brush{kind="round", width=w, point=0.7}; b:reload(ink, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.05}}) end
line(WOUT, 2.4)
line(WIN, 2.4)
line({{-10, 600}, {250, 580}, {500, 572}, {750, 578}, {1010, 596}}, 2)
for _, c in ipairs(CL) do line(c, 1.4, {0.55, 0.05}) end
-- flow lines in the wave's core, sweeping up toward the crest
local g = pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",0.3}}
for k = 1, 7 do
  local o = 70 + k * 16
  local pts = {}
  for i = 0, 12 do local t = i / 12; pts[#pts+1] = {lerp(10 + o * 0.6, 330 - o * 0.4, t) + 40 * math.sin(math.pi * t), lerp(560, 160 + o, t)} end
  local b = brush{kind="round", width=2, point=0.7}
  b:reload(g, 0.7); b:stroke(pts, {pressure={0.1, 0.6}, ramps={0.4, 0.2}})
end

--@ chunk 5
local body = pile{{"Mars orange",1},{"cadmium red",0.5},{"red lead",0.3}}
local deep = pile{{"cadmium red",1},{"Mars red",0.6},{"bone brown",0.15}}
local ink = pile{{"bone brown",1},{"bone black",0.6},{"ultramarine blue",0.2}}
-- lose the limb line where it ran across the wave
local seg = {} for x = -10, 540, 10 do seg[#seg+1] = {x, 600 - (x + 10) / 260 * 20 - (x > 250 and (x - 250) / 250 * 8 or 0)} end
local b = brush{kind="round", width=4.5, point=0.3}
b:reload(deep, 0.8); b:stroke(seg, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=WAVE:shrink(3) * CORE:grow(2)})
b:reload(body, 0.8); b:stroke(seg, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=WAVE:shrink(3) - CORE:grow(2)})
-- cartouche: framed, columns of abstract glyph marks, a red seal
local function line(p, pts, w) local r = brush{kind="round", width=w, point=0.6}; r:reload(p, 0.8); r:stroke(pts, {pressure={0.6, 0.55}, ramps={0.05, 0.1}}) end
line(ink, {{40, 30}, {130, 30}, {130, 180}, {40, 180}, {40, 30}}, 2)
line(ink, {{45, 35}, {125, 35}, {125, 175}, {45, 175}, {45, 35}}, 1)
for _, cx in ipairs({112, 92, 72}) do
  local y = 46
  while y < (cx == 72 and 130 or 160) do
    local h = rand(6, 11)
    local k = math.random(1, 3)
    if k == 1 then line(ink, {{cx - 5, y}, {cx + 5, y + 1}}, 1.6); line(ink, {{cx, y - 1}, {cx - 1, y + h}}, 1.6)
    elseif k == 2 then line(ink, {{cx - 4, y}, {cx + 4, y + h * 0.5}, {cx - 3, y + h}}, 1.5)
    else line(ink, {{cx - 5, y + h * 0.3}, {cx + 5, y + h * 0.3}}, 1.5); line(ink, {{cx - 3, y + h * 0.7}, {cx + 4, y + h * 0.8}}, 1.5) end
    y = y + h + 5
  end
end
local seal = rect(64, 140, 16, 18)
work(seal, {hand="detail", tool="round 1.4", pile=pile{{"vermilion",1},{"cadmium red",0.4}}, coverage=5, fill=true})

--@ chunk 6
print(wait(3*1440))
local sky = pile{{"ultramarine blue",1.2},{"cerulean blue",0.5},{"bone black",0.25},{"lead white",0.25}}
local body = pile{{"Mars orange",1},{"cadmium red",0.5},{"red lead",0.3}}
local ink = pile{{"bone brown",1},{"bone black",0.6},{"ultramarine blue",0.2}}
local ring = (rect(15, 10, 140, 200) - CART:grow(1)) - WAVE:grow(2)
work(ring, {hand="detail", tool="round 3", pile=sky, coverage=4.5, fill=true, load=1})
-- the stray limb line on the wave
local z = WAVE:shrink(3) * rect(0, 575, 560, 40)
work(z * mask(function(x, y) local yl = 600 - (x + 10) / 260 * 20; return (math.abs(y - yl) < 5) and 1 or 0 end), {hand="detail", tool="round 2.5", pile=body, coverage=4.5, fill=true, load=1})
print(wait(2*1440))
local function seg(a, b2, w) local r = brush{kind="round", width=w, point=0.5}; r:reload(ink, 0.8); r:stroke({a, b2}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}}) end
seg({40, 30}, {130, 30}, 2.2); seg({130, 30}, {130, 180}, 2.2); seg({130, 180}, {40, 180}, 2.2); seg({40, 180}, {40, 30}, 2.2)
