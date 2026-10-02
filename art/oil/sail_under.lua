-- easel session "sail_under": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=9001,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1},{"burnt sienna",1.2},{"raw sienna",0.6},{"lead white",0.3}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
-- the sail overhead fills the sky: a vast dark film; its far rim a curve near the top where a thin ring of light leaks
SUN = {520, 420}
RIM = ellipse(500, 470, 760, 430)              -- the sail, seen from beneath: its edge mostly off-canvas, the rim arcs across the top corners
HULLC = {{-10,1010},{200,990},{400,982},{600,984},{800,994},{1010,1010}}
HULL = below(HULLC)
FILM = RIM - HULL
OUT = everywhere() - RIM - HULL
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
local film = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local filmW = pile{{"burnt sienna",1.2},{"Mars orange",0.5},{"bone black",0.9}}
local filmG = pile{{"Mars orange",1},{"Indian yellow",0.6},{"burnt sienna",0.5},{"lead white",0.2}}
local ang = function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
work(FILM, {hand="broad", pile=film, coverage=3, fill=true, angle=ang, clip=FILM})
work(FILM * mask(function(x, y) return rd(x, y) < 330 and 1 or 0 end), {hand="broad", pile=filmW, coverage=2.4, fill=true, angle=ang, clip=FILM})
work(FILM * mask(function(x, y) return rd(x, y) < 180 and 1 or 0 end), {hand="body", pile=filmG, coverage=2.4, fill=true, angle=ang, clip=FILM})
blend(FILM * mask(function(x, y) return rd(x, y) < 380 and 1 or 0 end), {angle=ang})
work(OUT, {hand="body", pile=pile{{"bone black",3},{"ultramarine blue",0.5}}, coverage=3, fill=true, angle=0.3, clip=OUT})
work(HULL, {hand="broad", pile=pile{{"bone black",2.4},{"burnt sienna",0.8},{"ultramarine blue",0.3}}, coverage=3, fill=true, angle=0.05, clip=HULL:grow(2)})

--@ chunk 3
print(wait(3*24*60))
-- the sail must fill the sky: the band below the saucer's edge becomes film too (dark, warmer near the Sun); only the top corners stay space
local film = pile{{"bone black",2.2},{"burnt sienna",0.9},{"ultramarine blue",0.4}}
local lower = OUT * rect(-10, 200, 1020, 820)
work(lower, {hand="body", tool="filbert 8", pile=film, coverage=3.6, fill=true, angle=0.0, clip=lower, length={80, 200}, load=0.95})
-- the swirl in the disc smoothed: one direction of strokes, a warm flat glow
local disc = ellipse(SUN[1], SUN[2], 125, 125)
work(disc, {hand="body", tool="filbert 8", pile=pile{{"Mars orange",1},{"Indian yellow",0.7},{"lead white",0.4},{"burnt sienna",0.3}}, coverage=3.4, fill=true, angle=0.35, clip=disc:soften(14), length={60, 140}, load=0.9})
local halo = ellipse(SUN[1], SUN[2], 230, 220) - disc:shrink(6)
work(halo, {hand="body", tool="filbert 8", pile=pile{{"burnt sienna",1.2},{"Mars orange",0.6},{"bone black",0.6}}, coverage=3.2, fill=true, angle=0.35, clip=halo:soften(20), length={60, 140}, load=0.85})
blend((ellipse(SUN[1], SUN[2], 140, 140) - ellipse(SUN[1], SUN[2], 105, 105)):soften(8), {angle=0.35})

--@ chunk 4
print(wait(3*24*60))
-- light through the film: long strokes radiating from the hub (just below the Sun), gold in the glow, dimming outward
HUB = {500, 470}
local function rdS(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
local cW = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local cG = pile{{"Mars orange",1},{"Indian yellow",0.7},{"lead white",0.6}}
local cD = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.4}}
local b = brush("filbert", 5)
local t = brush{kind="round", width=2.2, point=0.5}
for i = 1, 220 do
  local a = rand(-math.pi, math.pi)
  local r0 = rand(10, 120); local r1 = r0 + rand(80, 380)
  local mid = {HUB[1] + math.cos(a) * (r0 + r1) / 2, HUB[2] + math.sin(a) * (r0 + r1) / 2}
  local d = rdS(mid[1], mid[2])
  local p = (d < 120) and cW or ((d < 240) and cG or cD)
  local br = (math.random() < 0.5) and b or t
  br:reload(p, 0.55)
  br:stroke({{HUB[1] + math.cos(a) * r0, HUB[2] + math.sin(a) * r0}, mid, {HUB[1] + math.cos(a) * r1, HUB[2] + math.sin(a) * r1}}, {pressure={0.15, 0.5}, swell={0.5, 1, 0.4}, ramps={0.3, 0.3}, orient="along", clip=FILM + (OUT * rect(-10, 200, 1020, 820))})
end

--@ chunk 5
print(wait(3*24*60))
-- the film's seams and pleats silhouetted against the light: long dark lines from the hub out to the rim, a few concentric seams
local blk = pile{{"bone black",3},{"burnt sienna",0.5}}
local SF = everywhere() - HULL - (OUT * rect(-10, -10, 1020, 210))
local b = brush{kind="round", width=3, point=0.4}
local t = brush{kind="round", width=1.6, point=0.6}
local N = 22
for i = 0, N - 1 do
  local a = -math.pi + (i + rand(-0.2, 0.2)) * 2 * math.pi / N
  local br = (i % 2 == 0) and b or t
  br:load(blk, 0.85)
  br:stroke({{HUB[1] + math.cos(a) * 8, HUB[2] + math.sin(a) * 8}, {HUB[1] + math.cos(a) * 400, HUB[2] + math.sin(a) * 400}, {HUB[1] + math.cos(a) * 900, HUB[2] + math.sin(a) * 900}}, {pressure={0.5, 0.9}, ramps={0.1, 0.05}, clip=SF})
end
for _, R in ipairs({150, 290, 470}) do
  local pts = {}
  for k = 0, 64 do local a = -math.pi + k * 2 * math.pi / 64; pts[#pts+1] = {HUB[1] + math.cos(a) * R * 1.05, HUB[2] + math.sin(a) * R * 0.95} end
  t:load(blk, 0.8); t:stroke(pts, {pressure={0.55, 0.55}, ramps={0.02, 0.02}, clip=SF})
end
-- the hub itself
local h = brush{kind="round", width=10, point=0.1}
h:load(blk, 0.9); h:touch(HUB[1], HUB[2], {pressure=0.9})

--@ chunk 6
-- the far rim: light leaking past the sail's edge in a thin white ring along the arc across the top; space beyond
local pts = {}
for k = 0, 60 do local a = -math.pi + k * math.pi / 60; pts[#pts+1] = {500 + math.cos(a) * 760, 470 + math.sin(a) * 430} end
local r = brush{kind="round", width=3, point=0.4}
r:load(pile{{"zinc white",3},{"lemon chrome",0.15}}, 0.8)
r:stroke(pts, {pressure={0.3, 0.3}, swell={0.4, 1, 1.4, 1, 0.4}, ramps={0.1, 0.1}})
local g = brush("filbert", 5)
for i = 1, 40 do
  local a = rand(-math.pi + 0.5, -0.5)
  local x, y = 500 + math.cos(a) * 762, 470 + math.sin(a) * 432
  g:reload(pile{{"lead white",2},{"cadmium yellow",0.4}}, 0.4)
  g:stroke({{x, y}, {x + math.cos(a) * 30, y + math.sin(a) * 30}}, {pressure={0.4, 0.02}, ramps={0.05, 0.8}, orient="along", clip=OUT})
end

--@ chunk 7
print(wait(3*24*60))
-- pleats bolder where they cross the light: each laid in three segments with fresh dark paint
local blk = pile{{"bone black",3.5},{"burnt sienna",0.4}}
local SF = everywhere() - HULL - (OUT * rect(-10, -10, 1020, 210))
local b = brush{kind="round", width=4.2, point=0.3}
local t = brush{kind="round", width=2.4, point=0.4}
local N = 22
for i = 0, N - 1 do
  local a = -math.pi + (i + 0.5) * 2 * math.pi / N + rand(-0.03, 0.03)
  local br = (i % 2 == 0) and b or t
  for _, seg in ipairs({{12, 140}, {136, 300}, {296, 560}}) do
    br:load(blk, 0.9)
    br:stroke({{HUB[1] + math.cos(a) * seg[1], HUB[2] + math.sin(a) * seg[1]}, {HUB[1] + math.cos(a) * seg[2], HUB[2] + math.sin(a) * seg[2]}}, {pressure={0.75, 0.75}, ramps={0.03, 0.03}, clip=SF})
  end
end
for _, R in ipairs({150, 290}) do
  local pts = {}
  for k = 0, 64 do local aa = -math.pi + k * 2 * math.pi / 64; pts[#pts+1] = {HUB[1] + math.cos(aa) * R * 1.05, HUB[2] + math.sin(aa) * R * 0.95} end
  t:load(blk, 0.9); t:stroke(pts, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=SF})
end

--@ chunk 8
-- the hull underfoot in deep shade, its near edge a dim curve; the watchers, small silhouettes, faces turned up, rimmed only by the sail's glow above
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 1000 end
local blk = pile{{"bone black",3.5},{"ultramarine blue",0.2}}
WT = nil
local function add(m) WT = WT and (WT + m) or m end
local function docent(x, h)
  local y = crest(x) + 2
  add(poly({{x - 13, y}, {x - 8, y - h * 0.35}, {x - 6.5, y - h * 0.66}, {x - 4, y - h * 0.72}, {x + 4, y - h * 0.72}, {x + 6.5, y - h * 0.66}, {x + 8, y - h * 0.35}, {x + 13, y}}, true))
  add(poly({{x - 1.8, y - h * 0.72}, {x - 1.8, y - h * 0.8}, {x + 1.8, y - h * 0.8}, {x + 1.8, y - h * 0.72}}))
  add(ellipse(x + 1, y - h * 0.88, 5.6, 9))   -- head tipped back, looking up
end
local function commando(x)
  local y = crest(x) + 2
  add(ribbon({{x - 5, y}, {x - 4.5, y - 26}}, 8) + ribbon({{x + 5, y}, {x + 4.5, y - 26}}, 8))
  add(poly({{x - 9, y - 24}, {x + 9, y - 24}, {x + 11, y - 44}, {x + 17, y - 55}, {x - 17, y - 55}, {x - 11, y - 44}}, true))
  add(poly({{x - 7, y - 55}, {x - 7, y - 67}, {x + 7, y - 69}, {x + 7, y - 55}}))
end
docent(330, 108); docent(372, 116); commando(450); docent(530, 112); docent(578, 104)
work(WT, {hand="detail", tool={kind="round", width=1.8, point=0.5}, pile=blk, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})
-- the hull's crest just catches the warm glow from the film
local r = brush{kind="round", width=1.6, point=0.6}
r:load(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.4}}, 0.55)
r:stroke({{-10,1010},{200,990},{400,982},{600,984},{800,994},{1010,1010}}, {pressure={0.35, 0.35}, swell={0.4, 1, 1.2, 1, 0.4}, clip=-WT})

--@ chunk 9
print(wait(3*24*60))
-- warm glow from overhead on the tops of heads, the upturned faces and shoulders; the docents' lenses and the visor take the gold
local rim = pile{{"lead white",1.5},{"Mars orange",0.6},{"cadmium yellow",0.4}}
local nz = noise{seed=9, period=5}
local edge = mask(function(x, y)
  if x < 300 or x > 610 or y < 860 or y > 1000 then return 0 end
  if WT:at(x, y) < 0.5 then return 0 end
  if WT:at(x, y - 1.6) > 0.5 then return 0 end
  return (nz:at01(x, y) > 0.2) and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=1.0, point=0.9}, pile=rim, coverage=2.2, fill=true, clip=true, angle=0})
local g = brush{kind="round", width=2.2, point=0.5}
local function crest(x) return 985 end
for _, d in ipairs({{331, 885}, {373, 878}, {531, 881}, {579, 891}}) do
  g:load(pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}, 0.6); g:touch(d[1] + 2, d[2] - 3, {pressure=0.5})
end
local v = brush{kind="round", width=2.6, point=0.4}
v:load(pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}, 0.7)
v:stroke({{444, 920}, {456, 918}}, {pressure={0.7, 0.6}})
local f = brush{kind="round", width=2.2, point=0.7}
f:load(pile{{"cadmium red",1.5},{"vermilion",0.5}}, 0.65)
f:stroke({{436, 935}, {426, 928}, {416, 930}, {408, 924}}, {pressure={0.7, 0.1}, ramps={0.1, 0.5}})

--@ chunk 10
print(wait(2*24*60))
local blk = pile{{"bone black",3.5},{"ultramarine blue",0.2}}
-- the Commando: rounded pauldrons, a helm tipped back; one docent lifting a long arm toward the sail
local add = ellipse(440, 934, 9, 6) + ellipse(460, 934, 9, 6) + poly({{443,920},{445,912},{456,910},{459,918},{457,926},{444,926}}, true)
  + ribbon({{537,920},{548,880},{556,840}}, {5, 4, 3.5}) + ellipse(557, 835, 3.5, 4.5)
  + ribbon({{325,925},{316,960},{318,985}}, {4, 3.5, 3})
work(add, {hand="detail", tool={kind="round", width=1.8, point=0.5}, pile=blk, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})
WT = WT + add

--@ chunk 11
print(wait(3*24*60))
local rim = pile{{"lead white",1.5},{"Mars orange",0.6},{"cadmium yellow",0.4}}
local r = brush{kind="round", width=1.2, point=0.8}
for _, s in ipairs({ {{432,930},{438,928},{446,929}}, {{454,929},{462,928},{468,931}}, {{445,911},{456,909}}, {{550,862},{556,836},{558,831}} }) do
  r:load(rim, 0.6); r:stroke(s, {pressure={0.55, 0.35}})
end
local v = brush{kind="round", width=2.2, point=0.4}
v:load(pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}, 0.7)
v:stroke({{446, 915}, {455, 913}}, {pressure={0.7, 0.6}})
-- the hull in deep shade: plate rows just discernible, their lips warmed faintly by the film's glow
local function crest(x)
  for i = 1, #HULLC - 1 do local a, b = HULLC[i], HULLC[i + 1]; if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
  return 1000 end
local lip = pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.6},{"lead white",0.2}}
local B = {}
local function bb(w) w = math.max(1.5, math.floor(w * 2 + 0.5) / 2); if not B[w] then B[w] = brush{kind="round", width=w, point=0.6} end; return B[w] end
for row = 0, 8 do
  local t = row / 8
  local s = lerp(10, 44, t ^ 1.3)
  local dy = lerp(8, 300, t ^ 1.25)
  local x = -s + (row % 2) * s * 0.5
  while x < 1000 + s do
    local y = crest(clamp(x, 0, 1000)) + dy
    if math.random() < 0.7 - 0.4 * t and WT:grow(3):at(x, y) < 0.5 then
      local hw = s * 0.5
      local b = bb(s * 0.09)
      b:reload(lip, 0.5)
      b:stroke({{x - hw * 0.9, y}, {x, y - s * 0.18}, {x + hw * 0.9, y}}, {pressure={0.4 - 0.25 * t, 0.05}, ramps={0.1, 0.5}, clip=HULL})
    end
    x = x + s * 0.95
  end
end
