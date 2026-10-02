-- easel session "hull_walk_storm": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=16/9, linen={16,18}, seed=8181, ground={{pile={{"bone black",2},{"ultramarine blue",0.5},{"cobalt violet",0.3}}, um=140, apply="knife", texture=0.3}}}
SUN = {-30, 120}
function horizon(x) return 250 + 0.00022 * (x - 620)^2 end
HULL = below(function(x) return horizon(x) end)
SKY = -HULL
print(W, H)

--@ chunk 2
-- value first: the hull a mid bronze lit hard from the left, darker toward the right; the sky near-black
local HB1 = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.4},{"lead white",0.4}}
local HB2 = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.7}}
work(HULL, {hand="body", tool="filbert 9", pile=HB2, coverage=2.6, fill=true, angle=0, clip=HULL, seed=201})
local lit = HULL * ellipse(120, 380, 520, 260):soften(80)
work(lit, {hand="body", tool="filbert 8", pile=HB1, coverage=2.2, fill=true, angle=0, edge="lost", clip=HULL, seed=202})
-- the Sun at the left edge: a hot white blaze laid opaque, warm white round it
local S1 = pile{{"zinc white",4},{"lemon chrome",0.3}}
local S2 = pile{{"lead white",2},{"lemon chrome",0.4},{"zinc white",1}}
local sun = ellipse(SUN[1], SUN[2], 90, 90)
work(ellipse(SUN[1], SUN[2], 130, 130) * SKY, {hand="body", tool="filbert 5", pile=S2, coverage=3, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) end, edge="lost", clip=SKY, seed=203})
work(sun * SKY, {hand="body", tool="filbert 5", pile=S1, coverage=3.5, fill=true, angle=0, clip=SKY, seed=204})

--@ chunk 3
-- the lit patch ends in a hard line: carry a mid bronze across it in long raking strokes
local HM = pile{{"raw sienna",1.5},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.3}}
local seam = HULL * poly({{380,180},{640,180},{560,600},{300,600}})
work(seam, {hand="body", tool="filbert 6", pile=HM, coverage=1.8, load=0.5, angle=0.05, length={60, 160}, clip=HULL, seed=301})
-- the aurora: long sheets of saturated green and violet streaming across the dark, no white in them to grey
local AG = pile{{"emerald green",1},{"viridian",0.8},{"ultramarine blue",0.3}}
local AV = pile{{"cobalt violet",1},{"magenta",0.4},{"ultramarine blue",0.5}}
local fb = brush{kind="filbert", width=7}
for i = 1, 70 do
  local band = (i % 3)
  local y0 = 30 + band * 55 + rand(-15, 15)
  local x0 = rand(180, 1000)
  local len = rand(80, 220)
  local pts = {}
  for s = 0, 4 do
    local u = s / 4
    pts[#pts + 1] = {x0 - len * u, y0 + 18 * math.sin(u * 3 + i) - len * u * 0.18}
  end
  fb:reload((i % 2 == 0) and AG or AV, 0.4)
  fb:stroke(pts, {pressure={0.05, 0.35}, ramps={0.4, 0.4}, swell={0.4, 1, 0.4}, clip=SKY - ellipse(SUN[1], SUN[2], 140, 140)})
end
-- the rail, posts, the Commando and his shadow: darks
local B = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
RAIL = {{80,500},{300,420},{520,372},{740,352},{1010,350}}
local railm = ribbon(RAIL, 4)
work(railm, {hand="detail", pile=B, coverage=5, fill=true, angle=-0.2, clip=railm, seed=310})
F = {600, 368}       -- his feet
local fx, fy = F[1], F[2]
FIG = ellipse(fx - 6, fy - 112, 13, 15)                                      -- helm
  + poly({{fx - 34, fy - 98}, {fx + 22, fy - 98}, {fx + 18, fy - 48}, {fx - 26, fy - 46}})   -- torso
  + ellipse(fx - 30, fy - 92, 13, 10) + ellipse(fx + 18, fy - 92, 12, 9)      -- pauldrons
  + ribbon({{fx - 18, fy - 48}, {fx - 30, fy - 24}, {fx - 38, fy}}, 12)      -- leg braced back
  + ribbon({{fx + 8, fy - 48}, {fx + 14, fy - 24}, {fx + 18, fy}}, 12)
  + ribbon({{fx - 34, fy - 88}, {fx - 52, fy - 66}, {fx - 62, fy - 50}}, 9)  -- arm out to the line
  + ribbon({{fx + 18, fy - 88}, {fx + 30, fy - 64}, {fx + 26, fy - 44}}, 9)
CREST = ribbon({{fx - 18, fy - 126}, {fx - 6, fy - 131}, {fx + 6, fy - 127}}, 4)
FIG = FIG + CREST
SHADOWF = poly({{fx - 40, fy + 2}, {fx + 20, fy + 2}, {fx + 300, fy + 40}, {fx + 330, fy + 64}, {fx + 230, fy + 60}}) * HULL
work(SHADOWF, {hand="body", tool="filbert 6", pile=B, coverage=4.5, fill=true, angle=0.1, clip=SHADOWF, seed=311})
work(FIG, {hand="detail", pile=B, coverage=5, fill=true, angle=1.57, clip=FIG, seed=312})
print(wait(4 * 24 * 60))

--@ chunk 4
-- restate the figure and shadow opaque on the dry hull; the aurora's curtains (vertical rays hanging from the sheets);
-- the hull's plates as lip and shadow strokes, scale growing toward us
local B = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
work(FIG, {hand="detail", pile=B, coverage=5, fill=true, angle=1.57, clip=FIG, seed=401})
work(SHADOWF, {hand="body", tool="filbert 5", pile=B, coverage=4.5, fill=true, angle=0.1, clip=SHADOWF, seed=402})
local AG = pile{{"emerald green",1},{"viridian",0.8},{"ultramarine blue",0.3}}
local AV = pile{{"cobalt violet",1},{"magenta",0.4},{"ultramarine blue",0.5}}
local fb = brush{kind="filbert", width=4}
local skyk = SKY - ellipse(SUN[1], SUN[2], 140, 140)
for i = 1, 180 do
  local x = rand(150, 1000)
  local y0 = rand(25, 150)
  local len = rand(30, 110)
  fb:reload((x + y0) % 3 < 1.6 and AG or AV, 0.35)
  fb:stroke({{x, y0}, {x - 6, y0 + len}}, {pressure={0.35, 0.0}, ramps={0.1, 0.85}, clip=skyk})
end
-- plates
local rig = brush{kind="rigger", width=2.0, point=0.85}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.7},{"cadmium yellow",0.2}}
local DK  = pile{{"bone black",2},{"burnt sienna",0.4}}
local keep = HULL - FIG:grow(2) - SHADOWF
PLATES = {}
local y = 262
local row = 0
while y < 580 do
  local k = (y - 250) / 330
  local w, h = lerp(26, 120, k), lerp(8, 50, k)
  local x = -w + ((row * 0.618) % 1) * w
  while x < 1000 do
    local top = math.max(y, horizon(x + w / 2) + 2)
    local arc = {}
    for j = 0, 8 do local a = math.pi * j / 8; arc[#arc + 1] = {x + w / 2 + w / 2 * math.cos(a), top + h * 0.5 + h * 0.5 * math.sin(a)} end
    local sh = {}
    for _, p in ipairs(arc) do sh[#sh + 1] = {p[1] + 1, p[2] + lerp(1.2, 3.5, k)} end
    local pr = lerp(0.2, 0.7, k)
    rig:reload(DK, 0.7); rig:stroke(sh, {pressure={pr, pr}, ramps={0.1, 0.1}, clip=keep})
    -- the sunward (left) half of the lip lit, brightest at the left
    local half = {}
    for j = 5, 9 do half[#half + 1] = arc[j] end
    rig:reload(LIP, 0.7); rig:stroke({half[1], half[2], half[3], half[4], half[5]}, {pressure={pr * 0.2, pr * 0.9}, ramps={0.1, 0.1}, clip=keep})
    PLATES[#PLATES + 1] = {x = x, y = top, w = w, h = h, k = k}
    x = x + w
  end
  y = y + h * 0.7
  row = row + 1
end
print(#PLATES, wait(4 * 24 * 60))

--@ chunk 5
-- on dry paint: his sunlit edge and line; then the discharge, hundreds of thin fading violet-white filaments
-- streaming off plate edges and rivets and off his crest and pauldrons
local rig = brush{kind="rigger", width=2.0, point=0.85}
local hair = brush{kind="rigger", width=1.3, point=0.95}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.1, 0.2}, clip=clip}) end
local WARM = pile{{"lead white",2},{"lemon chrome",0.3},{"yellow ochre",0.3}}
local fx, fy = F[1], F[2]
S(rig, WARM, 0.8, {{fx - 19, fy - 118}, {fx - 20, fy - 108}, {fx - 16, fy - 99}}, {0.5, 0.4})
S(rig, WARM, 0.8, {{fx - 42, fy - 96}, {fx - 34, fy - 98}}, {0.5, 0.4})
S(rig, WARM, 0.8, {{fx - 34, fy - 92}, {fx - 30, fy - 70}, {fx - 26, fy - 48}}, {0.45, 0.3})
S(rig, WARM, 0.7, {{fx - 24, fy - 46}, {fx - 34, fy - 24}, {fx - 43, fy}}, {0.35, 0.3})
S(rig, WARM, 0.7, {{fx - 36, fy - 84}, {fx - 52, fy - 64}, {fx - 66, fy - 48}}, {0.35, 0.3})
S(rig, pile{{"lead white",2},{"cerulean blue",0.2}}, 0.6, {{fx - 62, fy - 50}, {fx - 70, fy - 30}, {fx - 80, fy - 10}, {fx - 92, fy + 22}}, {0.25, 0.25})
local V1 = pile{{"zinc white",3},{"cobalt violet",1},{"lead white",0.3}}
local V2 = pile{{"zinc white",4},{"cobalt violet",0.4},{"cerulean blue",0.2}}
local VD = pile{{"cobalt violet",1},{"magenta",0.3},{"zinc white",1}}
local function filament(x, y, len, a, p, pr)
  local pts = {{x, y}}
  local cx, cy = x, y
  for s = 1, 4 do
    local aa = a + rand(-0.5, 0.5)
    cx, cy = cx + len / 4 * math.cos(aa), cy + len / 4 * math.sin(aa)
    pts[#pts + 1] = {cx, cy}
  end
  hair:reload(p, 0.6)
  hair:stroke(pts, {pressure={pr, 0.0}, ramps={0.05, 0.85}})
end
-- off the plates: from points along each lip, streaming up and slightly away from the Sun
for i, p in ipairs(PLATES) do
  local d = math.abs(p.x + p.w / 2 - fx) / 600
  local n = (p.k > 0.3) and 2 or 1
  if rand(0, 1) < 1.1 - d then
    for j = 1, n do
      local a = math.pi * rand(0.3, 0.9)
      local x = p.x + p.w / 2 + p.w / 2 * math.cos(a)
      local y = p.y + p.h * 0.5 + p.h * 0.5 * math.sin(a)
      if SHADOWF:at(x, y) < 0.5 and FIG:at(x, y) < 0.5 then
        filament(x, y, lerp(8, 30, p.k) * rand(0.6, 1.4), -1.57 + 0.35 + rand(-0.4, 0.4), (j == 1) and V1 or VD, lerp(0.25, 0.5, p.k))
      end
    end
  end
end
-- off his crest, helm and pauldrons, longer and whiter
for i = 1, 70 do
  local src = ({{fx - 18, fy - 128}, {fx - 6, fy - 132}, {fx + 6, fy - 128}, {fx - 30, fy - 101}, {fx + 18, fy - 100}, {fx - 6, fy - 127}})[(i % 6) + 1]
  local a = -1.57 + rand(-0.9, 0.9) + 0.3
  filament(src[1] + rand(-3, 3), src[2] + rand(-2, 2), rand(20, 70), a, (i % 3 == 0) and V2 or V1, rand(0.35, 0.6))
end
-- off the rail and posts
for i = 1, 40 do
  local t = rand(0, 1)
  local seg = math.floor(t * (#RAIL - 1)) + 1
  local u = t * (#RAIL - 1) - (seg - 1)
  local a, b = RAIL[seg], RAIL[seg + 1]
  filament(lerp(a[1], b[1], u), lerp(a[2], b[2], u), rand(8, 26), -1.3 + rand(-0.5, 0.5), VD, 0.35)
end
-- rivet points glowing where the discharge gathers
local tip = brush{kind="round", width=2.2, point=0.6}
for i = 1, 60 do
  local p = PLATES[math.random(1, #PLATES)]
  local x, y = p.x + p.w * 0.5, p.y + p.h * 0.3
  if SHADOWF:at(x, y) < 0.5 and FIG:at(x, y) < 0.5 then tip:reload(V2, 0.7); tip:touch(x, y, {pressure=lerp(0.3, 0.7, p.k)}) end
end

--@ chunk 6
-- the figure as armour in hard light: the side toward the Sun (left) lit steel, the rest black; plates and a visor slit
local fx, fy = F[1], F[2]
local ST  = pile{{"lead white",1.6},{"yellow ochre",0.5},{"bone black",0.3}}
local STD = pile{{"lead white",0.8},{"raw sienna",0.6},{"bone black",0.8}}
local litz = mask(function(x, y) return x < fx - 14 + (y - fy) * 0.05 and 1 or 0 end)
local helmL = ellipse(fx - 6, fy - 112, 13, 15) * mask(function(x, y) return x < fx - 9 and 1 or 0 end)
local torsoL = poly({{fx - 34, fy - 98}, {fx - 12, fy - 98}, {fx - 10, fy - 47}, {fx - 26, fy - 46}})
local paulL = ellipse(fx - 30, fy - 92, 13, 10)
local legL = ribbon({{fx - 18, fy - 48}, {fx - 30, fy - 24}, {fx - 38, fy}}, 12) * mask(function(x, y) return x < fx - 25 + (y - fy + 48) * -0.35 + 4 and 1 or 0 end)
local armL = ribbon({{fx - 34, fy - 88}, {fx - 52, fy - 66}, {fx - 62, fy - 50}}, 9) * mask(function(x, y) return y < fy - 50 - (x - fx + 62) * 1.0 + 6 and 1 or 0 end)
work(helmL + paulL, {hand="detail", pile=ST, coverage=4.5, fill=true, angle=1.57, clip=helmL + paulL, seed=601})
work(torsoL + legL + armL, {hand="detail", pile=STD, coverage=4.5, fill=true, angle=1.57, clip=torsoL + legL + armL, seed=602})
print(wait(4 * 24 * 60))
local rig = brush{kind="rigger", width=1.8, point=0.85}
local B = pile{{"bone black",2.4}}
local W = pile{{"lead white",2},{"lemon chrome",0.3},{"zinc white",1}}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.2}}) end
for _, y in ipairs({-86, -74, -62}) do S(B, 0.8, {{fx - 34, fy + y}, {fx - 11, fy + y + 1}}, {0.5, 0.5}) end
S(B, 0.8, {{fx - 19, fy - 114}, {fx - 9, fy - 114}}, {0.6, 0.6})
S(W, 0.9, {{fx - 19, fy - 122}, {fx - 20, fy - 108}, {fx - 16, fy - 99}}, {0.55, 0.45})
S(W, 0.9, {{fx - 43, fy - 95}, {fx - 36, fy - 101}, {fx - 28, fy - 102}}, {0.55, 0.45})
S(W, 0.8, {{fx - 34, fy - 96}, {fx - 32, fy - 72}, {fx - 27, fy - 48}}, {0.5, 0.35})
S(W, 0.8, {{fx - 25, fy - 46}, {fx - 35, fy - 24}, {fx - 44, fy}}, {0.45, 0.35})
S(W, 0.8, {{fx - 37, fy - 90}, {fx - 54, fy - 70}, {fx - 66, fy - 52}}, {0.45, 0.3})
local tip = brush{kind="round", width=2.2, point=0.5}
tip:reload(pile{{"zinc white",4},{"cobalt violet",0.6}}, 1.0); tip:touch(fx - 14, fy - 114, {pressure=0.8})

--@ chunk 7
-- the discharge stronger: in the black shadow and the darker right side it shows best, crowded violet filaments;
-- on the sunlit plates, more saturated violet so it carries against the bronze; a faint violet bloom round his crest
local hair = brush{kind="rigger", width=1.4, point=0.95}
local VS = pile{{"cobalt violet",1},{"magenta",0.5},{"zinc white",1.2}}
local VW = pile{{"zinc white",3},{"cobalt violet",1}}
local VC = pile{{"cobalt violet",1.2},{"magenta",0.6},{"ultramarine blue",0.3},{"zinc white",0.4}}
local function filament(x, y, len, a, p, pr)
  local pts = {{x, y}}
  local cx, cy = x, y
  for s = 1, 4 do local aa = a + rand(-0.55, 0.55); cx, cy = cx + len / 4 * math.cos(aa), cy + len / 4 * math.sin(aa); pts[#pts + 1] = {cx, cy} end
  hair:reload(p, 0.6); hair:stroke(pts, {pressure={pr, 0.0}, ramps={0.05, 0.85}})
end
local fx, fy = F[1], F[2]
for i, p in ipairs(PLATES) do
  local a = math.pi * rand(0.35, 0.85)
  local x = p.x + p.w / 2 + p.w / 2 * math.cos(a)
  local y = p.y + p.h * 0.5 + p.h * 0.5 * math.sin(a)
  if FIG:at(x, y) < 0.5 then
    local inshadow = SHADOWF:at(x, y) > 0.5 or x > 520
    filament(x, y, lerp(10, 36, p.k) * rand(0.7, 1.4), -1.57 + 0.3 + rand(-0.45, 0.45), inshadow and ((i % 3 == 0) and VW or VS) or VC, lerp(0.3, 0.55, p.k))
  end
end
-- a bloom of short violet filaments hugging his outline
for i = 1, 60 do
  local a = rand(0, 2 * math.pi)
  local x, y = fx - 6 + 40 * math.cos(a), fy - 70 + 64 * math.sin(a)
  if FIG:at(x, y) < 0.5 then filament(x, y, rand(6, 16), a + rand(-0.6, 0.6), VS, 0.35) end
end

--@ chunk 8
-- the lit half came up pale and blotched and splits him down the middle: a darker warm steel on it, the black side
-- carried a little across, so only a narrow edge toward the Sun stays bright
local fx, fy = F[1], F[2]
local MS = pile{{"bone black",1},{"raw sienna",0.8},{"yellow ochre",0.4},{"lead white",0.3}}
local B = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
local leftpart = FIG * mask(function(x, y) return x < fx - 8 and 1 or 0 end)
work(leftpart, {hand="detail", pile=MS, coverage=4.5, fill=true, angle=1.57, clip=leftpart, seed=801})
local mid = FIG * mask(function(x, y) return (x >= fx - 22 and x < fx - 6) and 1 or 0 end)
work(mid, {hand="detail", pile=B, coverage=4.5, fill=true, angle=1.57, clip=mid, seed=802})
print(wait(4 * 24 * 60))
local rig = brush{kind="rigger", width=1.8, point=0.85}
local W = pile{{"lead white",2},{"lemon chrome",0.3},{"zinc white",1}}
local function S(pts, pr) rig:reload(W, 0.9); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.2}}) end
S({{fx - 19, fy - 124}, {fx - 20, fy - 108}, {fx - 16, fy - 99}}, {0.55, 0.45})
S({{fx - 43, fy - 95}, {fx - 36, fy - 101}, {fx - 28, fy - 102}}, {0.55, 0.45})
S({{fx - 34, fy - 94}, {fx - 32, fy - 72}, {fx - 27, fy - 48}}, {0.5, 0.35})
S({{fx - 25, fy - 46}, {fx - 35, fy - 24}, {fx - 44, fy}}, {0.45, 0.35})
S({{fx - 37, fy - 88}, {fx - 54, fy - 68}, {fx - 66, fy - 52}}, {0.45, 0.3})
local B2 = pile{{"bone black",2.4}}
for _, y in ipairs({-86, -74, -62}) do rig:reload(B2, 0.8); rig:stroke({{fx - 33, fy + y}, {fx - 22, fy + y + 1}}, {pressure={0.5, 0.5}}) end
local tip = brush{kind="round", width=2.4, point=0.5}
tip:reload(pile{{"zinc white",4},{"cobalt violet",0.6}}, 1.0); tip:touch(fx - 15, fy - 114, {pressure=0.8})

--@ chunk 9
-- simpler and truer to the light: the whole figure black against the lit hull, only hard rim lights toward the Sun
local fx, fy = F[1], F[2]
local B = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
local core = FIG:shrink(1.2)
work(core, {hand="detail", pile=B, coverage=6, fill=true, angle=1.57, clip=core, seed=901})
print(wait(5 * 24 * 60))
local rig = brush{kind="rigger", width=2.0, point=0.85}
local W = pile{{"lead white",2},{"lemon chrome",0.3},{"zinc white",1}}
local Y = pile{{"lead white",1.5},{"yellow ochre",0.6},{"lemon chrome",0.2}}
local function S(p, pts, pr) rig:reload(p, 0.9); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.25}}) end
S(W, {{fx - 16, fy - 126}, {fx - 19, fy - 114}, {fx - 16, fy - 101}}, {0.6, 0.4})
S(W, {{fx - 43, fy - 94}, {fx - 38, fy - 101}, {fx - 29, fy - 102}}, {0.6, 0.45})
S(Y, {{fx - 33, fy - 90}, {fx - 31, fy - 70}, {fx - 25, fy - 48}}, {0.5, 0.3})
S(Y, {{fx - 22, fy - 46}, {fx - 33, fy - 24}, {fx - 43, fy - 1}}, {0.45, 0.35})
S(W, {{fx - 37, fy - 88}, {fx - 54, fy - 68}, {fx - 66, fy - 51}}, {0.45, 0.3})
S(Y, {{fx + 4, fy - 46}, {fx + 10, fy - 24}, {fx + 14, fy - 2}}, {0.3, 0.2})
S(W, {{fx - 18, fy - 128}, {fx - 6, fy - 133}, {fx + 6, fy - 129}}, {0.5, 0.4})
local tip = brush{kind="round", width=2.6, point=0.5}
tip:reload(pile{{"zinc white",4},{"cobalt violet",0.6}}, 1.0); tip:touch(fx - 16, fy - 113, {pressure=0.85})

--@ chunk 10
-- clear the ground for the pass: the sky back to black (round a clean sun disc), the hull repainted under the scribbles
local SKYB = pile{{"bone black",2},{"ultramarine blue",0.5},{"cobalt violet",0.25}}
SUND = ellipse(SUN[1], SUN[2], 92, 92)
local sky = SKY - SUND
work(sky, {hand="body", tool="filbert 8", pile=SKYB, coverage=3.2, fill=true, angle=0.15, clip=sky, seed=1001})
local HB2 = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.7}}
local HB1 = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.4},{"lead white",0.35}}
local hull = HULL - SHADOWF
work(hull, {hand="body", tool="filbert 9", pile=HB2, coverage=3, fill=true, angle=0.05, clip=hull, seed=1002})
work(hull * ellipse(150, 400, 560, 280), {hand="body", tool="filbert 8", pile=HB1, coverage=2.4, fill=true, angle=0.05, length={60, 160}, edge="lost", clip=hull, seed=1003})
print(wait(4 * 24 * 60))

--@ chunk 11
print(1)

--@ chunk 12
-- the sun a clean hard disc; the aurora as a few broad curtains hanging in folds; the plates, the rail; the war-body in black
local S1 = pile{{"zinc white",4},{"lemon chrome",0.25}}
work(SUND, {hand="body", tool="filbert 6", pile=S1, coverage=4, fill=true, angle=0, clip=SUND, seed=1101})
-- curtains: a wavy top line, the sheet hanging below it, brightest just under the top, fading downward
local AG = pile{{"emerald green",1},{"viridian",0.7},{"cerulean blue",0.2}}
local AV = pile{{"cobalt violet",1},{"magenta",0.35},{"ultramarine blue",0.3}}
local skyk = SKY - SUND:grow(25)
CURT = {
  {x0=180, x1=1010, top=40, amp=22, per=230, ph=0.3, h=90, p=AG},
  {x0=330, x1=1010, top=105, amp=16, per=170, ph=1.7, h=70, p=AV},
  {x0=150, x1=760,  top=150, amp=12, per=140, ph=2.9, h=45, p=AG},
}
for i, c in ipairs(CURT) do
  local function ty(x) return c.top + c.amp * math.sin((x - c.x0) / c.per * 2 * math.pi + c.ph) end
  local m = mask(function(x, y)
    if x < c.x0 or x > c.x1 then return 0 end
    local t = ty(x)
    if y < t or y > t + c.h then return 0 end
    return 1 end)
  m = m * skyk
  work(m, {hand="body", tool="filbert 6", pile=c.p, coverage=2.0, fill=true,
    angle=1.57, length={20, 60}, load_at=function(x, y) return clamp(0.9 * (1 - (y - ty(x)) / c.h), 0.05, 0.9) end, clip=skyk, seed=1110 + i})
  blend(m:grow(4) * skyk, {angle=1.57, tool={kind="badger", width=14}, seed=1120 + i})
end
-- plates again (lip and shadow), the rail and its posts
local rig = brush{kind="rigger", width=2.0, point=0.85}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.7},{"cadmium yellow",0.2}}
local DK  = pile{{"bone black",2},{"burnt sienna",0.4}}
local keep = HULL - SHADOWF
for _, p in ipairs(PLATES) do
  local arc = {}
  for j = 0, 8 do local a = math.pi * j / 8; arc[#arc + 1] = {p.x + p.w / 2 + p.w / 2 * math.cos(a), p.y + p.h * 0.5 + p.h * 0.5 * math.sin(a)} end
  local sh = {}
  for _, q in ipairs(arc) do sh[#sh + 1] = {q[1] + 1, q[2] + lerp(1.2, 3.5, p.k)} end
  local pr = lerp(0.2, 0.7, p.k)
  rig:reload(DK, 0.7); rig:stroke(sh, {pressure={pr, pr}, ramps={0.1, 0.1}, clip=keep})
  rig:reload(LIP, 0.7); rig:stroke({arc[5], arc[6], arc[7], arc[8], arc[9]}, {pressure={pr * 0.2, pr * 0.9}, ramps={0.1, 0.1}, clip=keep})
end
local B = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
POSTS = {}
for _, t in ipairs({0.12, 0.3, 0.48, 0.66, 0.86}) do
  local seg = math.floor(t * (#RAIL - 1)) + 1
  local u = t * (#RAIL - 1) - (seg - 1)
  local a, b = RAIL[seg], RAIL[seg + 1]
  local x, y = lerp(a[1], b[1], u), lerp(a[2], b[2], u)
  local hgt = 22
  POSTS[#POSTS + 1] = {x, y - hgt}
  local m = ribbon({{x, y + 8}, {x, y - hgt}}, 4)
  work(m, {hand="detail", pile=B, coverage=5, fill=true, angle=1.57, clip=m, seed=1130 + #POSTS})
end
local rm = ribbon(RAIL, 4)
work(rm, {hand="detail", pile=B, coverage=5, fill=true, angle=-0.2, clip=rm, seed=1140})
-- the war-body, braced, leaning toward the left, left hand down on the rail
local fx, fy = F[1], F[2]
local function P(x, y) return {fx + x, fy + y} end
HELM = poly({P(-24, -150), P(4, -152), P(8, -126), P(4, -114), P(-22, -112), P(-28, -128)})
CRESTB = poly({P(-24, -150), P(-10, -162), P(6, -158), P(4, -152)})
PAULS = poly({P(-56, -112), P(-30, -122), P(-18, -110), P(-28, -92), P(-54, -94)}, true) + poly({P(4, -118), P(28, -114), P(40, -98), P(30, -86), P(6, -94)}, true)
BREAST = poly({P(-34, -114), P(10, -116), P(16, -76), P(6, -56), P(-30, -56), P(-38, -78)})
FAULDS = poly({P(-32, -58), P(8, -58), P(12, -40), P(-36, -40)})
THIGHL = ribbon({P(-22, -44), P(-38, -22)}, 17) ; GREAVEL = ribbon({P(-38, -22), P(-48, 2)}, 14)
THIGHR = ribbon({P(0, -44), P(10, -22)}, 17) ; GREAVER = ribbon({P(10, -22), P(16, 2)}, 14)
FEETB = poly({P(-60, 0), P(-38, -4), P(-36, 6), P(-60, 6)}) + poly({P(8, 0), P(30, 0), P(30, 6), P(8, 6)})
ARML = ribbon({P(-44, -100), P(-60, -60), P(-64, -10)}, 12)
GAUNT = ellipse(fx - 64, fy - 2, 9, 9)
ARMR = ribbon({P(28, -96), P(40, -66), P(32, -42)}, 12)
WAR = HELM + CRESTB + PAULS + BREAST + FAULDS + THIGHL + GREAVEL + THIGHR + GREAVER + FEETB + ARML + GAUNT + ARMR
work(WAR, {hand="detail", pile=B, coverage=6, fill=true, angle=1.57, clip=WAR, seed=1150})
print(wait(5 * 24 * 60))

--@ chunk 13
-- the curtains are heavy opaque bands: take the sky's black up into their lower parts so each is a thin bright hem
-- with rays fading upward into the dark (an aurora is brightest at its lower edge)
local SKYB = pile{{"bone black",2},{"ultramarine blue",0.5},{"cobalt violet",0.25}}
local skyk = SKY - SUND:grow(25)
for i, c in ipairs(CURT) do
  local function ty(x) return c.top + c.amp * math.sin((x - c.x0) / c.per * 2 * math.pi + c.ph) end
  -- black over the upper part of each sheet, its lower edge lost into the sheet
  local up = mask(function(x, y) if x < c.x0 - 30 or x > c.x1 + 30 then return 0 end; local t = ty(x); return (y > t - 30 and y < t + c.h * 0.55) and 1 or 0 end) * skyk
  work(up, {hand="body", tool="filbert 5", pile=SKYB, coverage=1.6, angle=1.57, length={20, 50}, load_at=function(x, y) return clamp(0.9 - 0.9 * (y - ty(x)) / (c.h * 0.55), 0.05, 0.9) end, edge="lost", clip=skyk, seed=1300 + i})
  -- and below the sheet, the black up to its hem
  local dn = mask(function(x, y) if x < c.x0 - 30 or x > c.x1 + 30 then return 0 end; local t = ty(x); return (y > t + c.h * 0.85 and y < t + c.h + 30) and 1 or 0 end) * skyk
  work(dn, {hand="body", tool="filbert 5", pile=SKYB, coverage=2.6, fill=true, angle=1.57, length={15, 40}, clip=skyk, seed=1310 + i})
end
print(wait(4 * 24 * 60))

--@ chunk 14
-- the curtains again, as light: from a bright hem along each fold line, broad soft rays rising and fading to nothing,
-- packed side by side, then blended up their length into smooth sheets
local skyk = SKY - SUND:grow(25)
local AG = pile{{"emerald green",1},{"viridian",0.6},{"zinc white",0.25}}
local AV = pile{{"cobalt violet",1},{"magenta",0.35},{"zinc white",0.2}}
local fb = brush{kind="filbert", width=9}
for i, c in ipairs(CURT) do
  local function ty(x) return c.top + c.amp * math.sin((x - c.x0) / c.per * 2 * math.pi + c.ph) end
  local p = (i == 2) and AV or AG
  for x = c.x0, c.x1, 5 do
    local hem = ty(x) + c.h
    local len = c.h * rand(0.8, 1.5)
    fb:reload(p, 0.5)
    fb:stroke({{x, hem}, {x + 1, hem - len * 0.5}, {x + 3, hem - len}}, {pressure={0.55, 0.0}, ramps={0.05, 0.9}, clip=skyk})
  end
  local m = mask(function(x, y) if x < c.x0 - 10 or x > c.x1 + 10 then return 0 end; local t = ty(x); return (y > t - c.h * 0.6 and y < t + c.h + 6) and 1 or 0 end) * skyk
  blend(m, {angle=1.57, tool={kind="badger", width=12}, seed=1400 + i})
end
print(wait(4 * 24 * 60))

--@ chunk 15
-- the blend dragged the curtains into a flat block with cut edges: the sky back to black, then the curtains as strokes only
local SKYB = pile{{"bone black",2},{"ultramarine blue",0.5},{"cobalt violet",0.25}}
local sky = SKY - SUND
work(sky * rect(80, -10, 940, 260), {hand="body", tool="filbert 8", pile=SKYB, coverage=3.5, fill=true, angle=0.15, clip=sky, seed=1501})
print(wait(4 * 24 * 60))
local skyk = SKY - SUND:grow(25)
local AG = pile{{"emerald green",1},{"viridian",0.6},{"zinc white",0.25}}
local AV = pile{{"cobalt violet",1},{"magenta",0.35},{"zinc white",0.2}}
local fb = brush{kind="filbert", width=5}
for i, c in ipairs(CURT) do
  local function ty(x) return c.top + c.amp * math.sin((x - c.x0) / c.per * 2 * math.pi + c.ph) end
  local p = (i == 2) and AV or AG
  for x = c.x0, c.x1, 7 do
    local hem = ty(x) + c.h
    local len = c.h * rand(0.6, 1.3) * (0.6 + 0.4 * math.sin((x - c.x0) / 60 + i) ^ 2)
    fb:reload(p, 0.35)
    fb:stroke({{x, hem}, {x + 1, hem - len * 0.5}, {x + 2, hem - len}}, {pressure={0.4, 0.0}, ramps={0.05, 0.9}, clip=skyk})
  end
end

--@ chunk 16
-- on dry paint: hard white sunward edges on the war-body; the curtains' bright lower hems; then corona discharge
-- at a few points only, small intense violet-white glows with short branching filaments reaching up and out
local fx, fy = F[1], F[2]
local BB = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
local hc = HELM + CRESTB + PAULS
work(hc, {hand="detail", pile=BB, coverage=6, fill=true, angle=1.57, clip=hc, seed=1201})
print(wait(4 * 24 * 60))
local function P(x, y) return {fx + x, fy + y} end
local rig = brush{kind="rigger", width=2.0, point=0.85}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.25}}) end
local W = pile{{"lead white",2},{"lemon chrome",0.3},{"zinc white",1}}
local Y = pile{{"lead white",1.5},{"yellow ochre",0.6},{"lemon chrome",0.2}}
local B = pile{{"bone black",2.4}}
S(W, 0.9, {P(-28, -128), P(-24, -150)}, {0.6, 0.5})                       -- helm front
S(W, 0.9, {P(-24, -150), P(-10, -162)}, {0.55, 0.4})                      -- crest
S(B, 0.9, {P(-26, -134), P(-6, -136)}, {0.6, 0.6})                         -- visor slit
S(W, 0.9, {P(-56, -112), P(-30, -122)}, {0.6, 0.4})                       -- left pauldron top
S(Y, 0.8, {P(-56, -110), P(-54, -95)}, {0.5, 0.4})
S(W, 0.9, {P(4, -118), P(28, -114)}, {0.4, 0.25})                         -- right pauldron top, thinner
S(Y, 0.8, {P(-34, -112), P(-38, -78), P(-30, -58)}, {0.55, 0.4})           -- breast edge
for _, y in ipairs({-100, -86, -72}) do S(B, 0.8, {P(-36, y), P(12, y - 1)}, {0.5, 0.5}) end
S(Y, 0.8, {P(-32, -57), P(-36, -41)}, {0.5, 0.4})                         -- faulds
S(B, 0.8, {P(-34, -49), P(10, -49)}, {0.5, 0.5})
S(Y, 0.8, {P(-26, -46), P(-44, -22)}, {0.5, 0.4})                         -- thigh
S(W, 0.9, {P(-44, -20), P(-55, 2)}, {0.55, 0.4})                          -- greave
S(Y, 0.7, {P(-5, -44), P(4, -22), P(8, 0)}, {0.35, 0.25})
S(W, 0.9, {P(-49, -98), P(-66, -60), P(-70, -12)}, {0.5, 0.4})            -- arm
S(W, 0.9, {P(-72, -6), P(-70, 4)}, {0.6, 0.5})                            -- gauntlet
local tip = brush{kind="round", width=2.6, point=0.5}
tip:reload(pile{{"zinc white",4},{"cobalt violet",0.6}}, 1.0); tip:touch(fx - 22, fy - 135, {pressure=0.8})
-- the curtains' lower hems glow a little brighter, drawn as long smooth strokes along the folds
local HG = pile{{"emerald green",1},{"zinc white",0.6},{"viridian",0.3}}
local HV = pile{{"cobalt violet",1},{"zinc white",0.5},{"magenta",0.2}}
local fb = brush{kind="filbert", width=5}
local skyk = SKY - SUND:grow(25)
for i, c in ipairs(CURT) do
  local pts = {}
  for x = c.x0, c.x1, 20 do pts[#pts + 1] = {x, c.top + c.amp * math.sin((x - c.x0) / c.per * 2 * math.pi + c.ph) + c.h} end
  fb:reload((c.p == nil or i == 2) and HV or HG, 0.5)
  fb:stroke(pts, {pressure={0.1, 0.35}, ramps={0.3, 0.3}, swell={0.5, 1, 0.7, 1, 0.5}, clip=skyk})
end
-- corona discharge
local GL = pile{{"zinc white",4},{"cobalt violet",0.6}}
local GV = pile{{"cobalt violet",1.2},{"magenta",0.4},{"zinc white",1.2}}
local hair = brush{kind="rigger", width=1.5, point=0.95}
local function corona(x, y, n, len, size)
  -- a small glow: violet ring, white core
  local g = brush{kind="round", width=size * 2.2, point=0.3}
  g:reload(GV, 0.8); g:touch(x, y, {pressure=0.8})
  for k = 1, n do
    local a = -math.pi / 2 + rand(-1.1, 1.1)
    local l = len * rand(0.6, 1.2)
    local m1 = {x + l * 0.5 * math.cos(a), y + l * 0.5 * math.sin(a)}
    local e = {m1[1] + l * 0.5 * math.cos(a + rand(-0.5, 0.5)), m1[2] + l * 0.5 * math.sin(a + rand(-0.5, 0.5))}
    hair:reload((k % 2 == 0) and GL or GV, 0.7)
    hair:stroke({{x, y}, m1, e}, {pressure={0.55, 0.0}, ramps={0.05, 0.8}})
    local a2 = a + rand(0.4, 0.8) * ((k % 2 == 0) and 1 or -1)
    hair:reload(GV, 0.6)
    hair:stroke({m1, {m1[1] + l * 0.35 * math.cos(a2), m1[2] + l * 0.35 * math.sin(a2)}}, {pressure={0.4, 0.0}, ramps={0.05, 0.8}})
  end
  local c = brush{kind="round", width=size, point=0.4}
  c:reload(GL, 1.0); c:touch(x, y, {pressure=0.9})
end
corona(fx - 10, fy - 162, 7, 34, 5)        -- crest
corona(fx - 56, fy - 112, 5, 22, 4)        -- left pauldron tip
corona(fx + 38, fy - 100, 4, 18, 3.5)      -- right pauldron tip
corona(fx - 70, fy - 6, 4, 16, 3.5)        -- gauntlet on the rail
for _, p in ipairs(POSTS) do corona(p[1], p[2], 3, 14, 3) end
for _, r in ipairs({{fx - 120, fy + 20}, {fx + 60, fy + 34}, {fx - 160, fy - 12}, {fx + 110, fy - 6}}) do
  if SHADOWF:at(r[1], r[2]) < 0.5 then corona(r[1], r[2], 3, 12, 3) end
end

--@ chunk 17
-- on dry paint: the hard white edge along the war-body's true sunward contour; the coronas brighter and crisper
print(wait(4 * 24 * 60))
local fx, fy = F[1], F[2]
local edge = {}
for y = fy - 160, fy + 4, 2 do
  local found = nil
  for x = fx - 90, fx + 20, 1 do if WAR:at(x, y) > 0.5 then found = x; break end end
  if found then edge[#edge + 1] = {found + 1.2, y} else edge[#edge + 1] = false end
end
local rig = brush{kind="rigger", width=1.8, point=0.85}
local W = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.25}}
local run = {}
local function flush()
  if #run >= 3 then rig:reload(W, 0.9); rig:stroke(run, {pressure={0.55, 0.45}, ramps={0.05, 0.1}}) end
  run = {}
end
for _, p in ipairs(edge) do
  if p and (#run == 0 or math.abs(p[1] - run[#run][1]) < 5) then run[#run + 1] = p else flush(); if p then run[1] = p end end
end
flush()
-- coronas, stronger: a white core, a violet halo of short touches, and crisp branching filaments, mostly upward
local GL = pile{{"zinc white",4},{"cobalt violet",0.4}}
local GV = pile{{"cobalt violet",1.2},{"zinc white",1.4},{"magenta",0.2}}
local hair = brush{kind="rigger", width=1.6, point=0.95}
local function corona(x, y, n, len, size)
  for k = 1, n do
    local a = -math.pi / 2 + rand(-1.0, 1.0)
    local l = len * rand(0.6, 1.2)
    local pts = {{x, y}}
    local cx, cy = x, y
    for s = 1, 3 do local aa = a + rand(-0.45, 0.45); cx, cy = cx + l / 3 * math.cos(aa), cy + l / 3 * math.sin(aa); pts[#pts + 1] = {cx, cy} end
    hair:reload(GL, 0.8); hair:stroke(pts, {pressure={0.7, 0.0}, ramps={0.03, 0.8}})
    local m = pts[2]
    local a2 = a + rand(0.5, 0.9) * ((k % 2 == 0) and 1 or -1)
    hair:reload(GV, 0.7); hair:stroke({m, {m[1] + l * 0.4 * math.cos(a2), m[2] + l * 0.4 * math.sin(a2)}}, {pressure={0.5, 0.0}, ramps={0.03, 0.8}})
  end
  local g = brush{kind="round", width=size * 2.6, point=0.3}
  g:reload(GV, 0.8); g:touch(x, y, {pressure=0.7})
  local c = brush{kind="round", width=size * 1.3, point=0.4}
  c:reload(GL, 1.0); c:touch(x, y, {pressure=1.0})
end
corona(fx - 10, fy - 162, 9, 46, 5)
corona(fx - 56, fy - 112, 6, 28, 4)
corona(fx + 38, fy - 100, 5, 22, 3.5)
corona(fx - 70, fy - 6, 5, 20, 3.5)
for _, p in ipairs(POSTS) do corona(p[1], p[2], 4, 18, 3) end
