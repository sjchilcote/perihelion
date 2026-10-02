-- easel session "sunset_turner": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=1840,
  ground={{pile={{"lead white",4},{"yellow ochre",0.4},{"raw sienna",0.1}}, um=90, apply="knife", texture=0.35}}}
VX, VY = 560, 320
function swirl(x, y) local a = math.atan(y - VY, x - VX); local d = math.sqrt((x-VX)^2 + (y-VY)^2); return a + math.pi/2 + 0.45 * clamp(d / 450, 0, 1) end
function arc(x, y, L, step, dir)
  local pts = {{x, y}}
  for i = 1, math.floor(L / step) do local a = swirl(x, y) + (dir or 0); x, y = x + step * math.cos(a), y + step * math.sin(a); pts[#pts + 1] = {x, y} end
  return pts
end
function sweep(n, pickfn, wmin, wmax, Lmin, Lmax, cx, cy, rmax, ldmin, ldmax)
  for i = 1, n do
    local a = rand(0, 6.283); local r = math.sqrt(math.random()) * rmax
    local x, y = cx + r * math.cos(a), cy + r * math.sin(a) * 0.8
    local p = pickfn(x, y)
    if p then
      local b = brush{kind="filbert", width=rand(wmin, wmax)}
      b:reload(p, rand(ldmin or 0.45, ldmax or 0.75))
      local pts = arc(x, y, rand(Lmin, Lmax), 7)
      if math.random() < 0.5 then local rv = {} for k = #pts, 1, -1 do rv[#rv + 1] = pts[k] end pts = rv end
      b:stroke(pts, {pressure={rand(0.4, 0.8), rand(0.1, 0.35)}, ramps={0.15, 0.5}})
    end
  end
end
function badger(n, cx, cy, rmax, w)
  local bd = brush{kind="badger", width=w or 30}
  for i = 1, n do
    local a = rand(0, 6.283); local r = math.sqrt(math.random()) * rmax
    bd:wipe(0.95); bd:stroke(arc(cx + r * math.cos(a), cy + r * math.sin(a) * 0.8, rand(100, 260), 7), {pressure={0.3, 0.15}, ramps={0.15, 0.4}})
  end
end
GOLD = pile{{"Indian yellow",1},{"lead white",1.6},{"cadmium yellow",0.3}, medium=0.45}
OCH = pile{{"yellow ochre",1},{"raw sienna",0.4},{"lead white",1.2}, medium=0.45}
ORA = pile{{"Mars orange",1},{"Indian yellow",0.6},{"lead white",0.8}, medium=0.45}
RED = pile{{"vermilion",0.8},{"Mars red",0.5},{"lead white",0.6}, medium=0.45}
PALE = pile{{"lead white",3},{"lemon chrome",0.4}, medium=0.3}
VIO = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",0.8}, medium=0.45}
VIOD = pile{{"cobalt violet",1},{"ultramarine blue",1},{"bone black",0.5}, medium=0.35}
COLD = pile{{"lead white",2},{"cerulean blue",0.6},{"cobalt violet",0.2}, medium=0.4}
-- breach diagonal: from lower left up toward the vortex
function breachK(x, y) local d = ((x - 80) * 0.55 + (y - 640) * 0.83); local across = math.abs((x - 80) * 0.83 - (y - 640) * 0.55); return across, d end
-- warm field everywhere first
sweep(420, function(x, y)
  local d = math.sqrt((x - VX)^2 + (y - VY)^2)
  local r = math.random()
  if d < 120 then return (r < 0.6) and PALE or GOLD end
  if x > VX then return (r < 0.4) and GOLD or ((r < 0.75) and ORA or RED) end
  return (r < 0.5) and OCH or ((r < 0.8) and GOLD or ORA)
end, 16, 28, 120, 280, 500, 333, 700)

--@ chunk 2
-- the Breach: cold violet tearing up from the lower left through the gold
sweep(220, function(x, y)
  local across, d = breachK(x, y)
  if across < 120 + 0.25 * math.max(d, 0) and d > -40 and d < 520 then
    local r = math.random()
    if across < 45 then return (r < 0.6) and VIOD or VIO end
    return (r < 0.55) and VIO or COLD
  end
  return nil
end, 14, 26, 80, 220, 330, 520, 330)
-- the station: a dark broken shape caught left of the eye, laid wet so it dissolves
local br = pile{{"burnt sienna",1},{"bone brown",1.2},{"raw sienna",0.3}}
local brD = pile{{"bone brown",1.5},{"bone black",0.6},{"burnt sienna",0.6}}
for i = 1, 34 do
  local x, y = 300 + rand(-60, 60), 300 + rand(-40, 45)
  local b = brush{kind="filbert", width=rand(8, 14)}
  b:reload((math.random() < 0.5) and brD or br, rand(0.6, 0.9))
  b:stroke(arc(x, y, rand(25, 70), 5), {pressure={rand(0.6, 0.9), rand(0.2, 0.4)}, ramps={0.1, 0.5}})
end
-- the clean badger by hand, hard, all over, along the vortex
badger(110, 500, 333, 700, 34)

--@ chunk 3
sweep(260, function(x, y)
  local across, d = breachK(x, y)
  if across < 90 + 0.35 * math.max(d, 0) and d > -60 and d < 560 then
    local r = math.random()
    if across < 40 + 0.1 * math.max(d, 0) then return (r < 0.6) and VIOD or VIO end
    return (r < 0.5) and VIO or COLD
  end
  return nil
end, 16, 30, 100, 260, 260, 470, 420)
blend(everywhere(), {angle=swirl})

--@ chunk 4
local STORM = pile{{"bone brown",1},{"cobalt violet",0.6},{"ultramarine blue",0.3},{"lead white",0.7}, medium=0.35}
local STORMD = pile{{"bone brown",1.2},{"bone black",0.4},{"cobalt violet",0.5},{"lead white",0.3}, medium=0.3}
-- storm band: an outer ring of dark weather, heaviest upper left and lower right
sweep(200, function(x, y)
  local d = math.sqrt((x - VX)^2 + ((y - VY) * 1.2)^2)
  local a = math.atan(y - VY, x - VX)
  local heavy = math.cos(2 * (a + 0.7))
  if d > 300 and heavy > -0.1 then return (math.random() < 0.5) and STORMD or STORM end
  return nil
end, 18, 32, 120, 260, 500, 333, 720)
-- the breach tongue tearing in to the eye
sweep(120, function(x, y)
  local across, d = breachK(x, y)
  if across < 40 + 0.12 * math.max(d, 0) and d > 150 and d < 600 then return (math.random() < 0.55) and VIOD or VIO end
  return nil
end, 10, 18, 60, 160, 380, 380, 300)
-- the station, broken: hull chunks and spars caught in the curve
local brD = pile{{"bone brown",1.5},{"bone black",0.6},{"burnt sienna",0.6}}
for i = 1, 30 do
  local x, y = 290 + rand(-80, 70), 290 + rand(-45, 55)
  local b = brush{kind="filbert", width=rand(8, 16)}
  b:reload(brD, rand(0.6, 0.9))
  b:stroke(arc(x, y, rand(25, 80), 5), {pressure={rand(0.6, 0.9), rand(0.2, 0.4)}, ramps={0.1, 0.5}})
end
blend(ellipse(VX - 40, VY + 20, 560, 380) - ellipse(VX, VY, 80, 70), {angle=swirl, tool={kind="badger", width=30}})

--@ chunk 5
print(wait(6*1440))
print(drying(300, 280), drying(800, 100))
-- the tear: cold violet dragged dry across the gold from lower left toward the eye
local tearV = pile{{"cobalt violet",1},{"ultramarine blue",0.7},{"lead white",0.6}}
local tearL = pile{{"lead white",2},{"cobalt violet",0.5},{"cerulean blue",0.3}}
for i = 1, 40 do
  local t = rand(0, 1)
  local x, y = lerp(60, 470, t) + rand(-30, 30), lerp(600, 340, t) + rand(-30, 30)
  local b = brush{kind="filbert", width=rand(6, 14)}
  b:reload((math.random() < 0.65) and tearV or tearL, rand(0.25, 0.45))
  local a = math.atan(340 - 600, 470 - 60) + rand(-0.2, 0.2)
  local L = rand(40, 110)
  b:stroke({{x, y}, {x + L * math.cos(a) * 0.5, y + L * math.sin(a) * 0.5 + rand(-6, 6)}, {x + L * math.cos(a), y + L * math.sin(a)}}, {pressure={rand(0.4, 0.7), 0.05}, ramps={0.1, 0.6}})
end
-- gold over the stubby edge marks
for i = 1, 30 do
  local x, y
  if i <= 18 then x, y = rand(760, 900), rand(0, 120) else x, y = rand(0, 90), rand(80, 330) end
  local b = brush{kind="filbert", width=rand(14, 22)}
  b:reload((math.random() < 0.5) and GOLD or OCH, rand(0.4, 0.6))
  b:stroke(arc(x, y, rand(60, 140), 7), {pressure={rand(0.4, 0.7), 0.15}, ramps={0.2, 0.5}})
end

--@ chunk 6
local ta = math.atan(340 - 600, 470 - 60)
local band = poly({{0, 560}, {40, 620}, {120, 667}, {500, 370}, {480, 300}, {430, 300}}, true)
blend(band, {angle=ta, tool={kind="badger", width=26}})
blend(band, {angle=swirl, tool={kind="badger", width=26}})
blend(poly({{700, 0}, {900, 0}, {900, 160}, {760, 150}}, true) + poly({{0, 60}, {110, 70}, {120, 340}, {0, 360}}, true), {angle=swirl, tool={kind="badger", width=26}})

--@ chunk 7
print(wait(6*1440))
-- hard notes on dry paint: the broken station's silhouette, its lights going out in waves, the tear's crisp edge, the eye
local dk = pile{{"bone brown",1.5},{"bone black",0.8},{"burnt sienna",0.4}}
local b = brush{kind="filbert", width=9}
-- hull: a tilted broken cylinder, snapped in the middle
b:reload(dk, 0.9); b:stroke({{205, 330}, {245, 305}, {285, 288}}, {pressure={0.85, 0.7}, ramps={0.05, 0.1}})
b:reload(dk, 0.9); b:stroke({{298, 292}, {330, 276}, {372, 262}}, {pressure={0.75, 0.3}, ramps={0.05, 0.6}})
-- the ring, torn: two arcs, one swept away into the vortex
local r = brush{kind="round", width=2.6, point=0.6}
local function ell(cx, cy, rx, ry, a0, a1, tilt)
  local p = {} for i = 0, 24 do local a = a0 + (a1 - a0) * i / 24; local x, y = rx * math.cos(a), ry * math.sin(a); p[#p+1] = {cx + x * math.cos(tilt) - y * math.sin(tilt), cy + x * math.sin(tilt) + y * math.cos(tilt)} end return p end
r:reload(dk, 0.8); r:stroke(ell(255, 312, 70, 22, math.rad(100), math.rad(250), -0.45), {pressure={0.7, 0.1}, ramps={0.05, 0.6}})
r:reload(dk, 0.8); r:stroke(ell(270, 300, 78, 26, math.rad(-80), math.rad(20), -0.6), {pressure={0.1, 0.6}, ramps={0.5, 0.1}})
-- broken spars flung along the vortex
for _, s in ipairs({{{330, 250}, {352, 222}, {362, 200}}, {{215, 340}, {190, 362}}, {{385, 268}, {420, 262}, {450, 268}}}) do
  r:reload(dk, 0.7); r:stroke(s, {pressure={0.6, 0.05}, ramps={0.05, 0.7}})
end
-- the lights: a row of warm windows along the hull, still lit toward the stern, dead toward the bow
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.8}}
local dim = pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone brown",0.5}}
local w = brush{kind="round", width=2.2, point=0.3}
for i = 0, 11 do
  local t = i / 11
  local x, y = lerp(212, 365, t), lerp(325, 265, t) - 1
  if not (x > 286 and x < 300) then
    w:reload((t < 0.45) and warm or dim, 0.7); w:touch(x, y, {pressure=(t < 0.45) and 0.5 or 0.35})
  end
end
-- one crisp cold edge where the tear rips the gold
local cold = pile{{"lead white",2.5},{"cerulean blue",0.4},{"cobalt violet",0.2}}
local c = brush{kind="round", width=2, point=0.7}
c:reload(cold, 0.7); c:stroke({{120, 560}, {230, 470}, {340, 400}, {430, 345}}, {pressure={0.1, 0.55}, ramps={0.4, 0.2}})
local vd = pile{{"cobalt violet",1},{"ultramarine blue",1},{"bone black",0.4}}
c:reload(vd, 0.7); c:stroke({{90, 600}, {200, 510}, {300, 440}}, {pressure={0.6, 0.05}, ramps={0.05, 0.6}})
-- the eye
local hi = pile{{"zinc white",3},{"lemon chrome",0.25}}
local e = brush{kind="filbert", width=12}
e:reload(hi, 1); e:touch(505, 290, {pressure=0.8})
e:reload(hi, 0.8); e:stroke(arc(470, 290, 50, 4), {pressure={0.5, 0.1}})

--@ chunk 8
local dk = pile{{"bone brown",1.5},{"bone black",0.8},{"burnt sienna",0.4}}
local dk2 = pile{{"bone brown",1},{"burnt sienna",1},{"cobalt violet",0.3}}
local function st(w, p, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, 1); b:stroke(pts, {pressure=pr, ramps={0.05, 0.3}}) end
-- stern section, heavy
st(18, dk, {{190, 340}, {225, 320}, {262, 302}, {284, 292}}, {0.95, 0.8})
st(12, dk2, {{200, 352}, {240, 333}, {278, 312}}, {0.8, 0.5})
-- bow section, torn loose and tilted harder into the vortex
st(14, dk, {{304, 282}, {335, 262}, {368, 240}}, {0.9, 0.4})
st(9, dk2, {{312, 294}, {345, 276}, {380, 256}}, {0.7, 0.2})
-- jagged ends at the break
for _, s in ipairs({{{284, 290}, {292, 278}}, {{286, 300}, {296, 306}}, {{302, 282}, {296, 270}}, {{304, 292}, {298, 302}}}) do st(4, dk, s, {0.8, 0.1}) end
print(wait(4*1440))
-- lights: lit on the stern, going out toward the break, dead on the bow
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",1}}
local mid = pile{{"Mars orange",1},{"cadmium red",0.4},{"burnt sienna",0.4}}
local dim = pile{{"burnt sienna",1},{"Mars red",0.4},{"bone brown",0.4}}
local w = brush{kind="round", width=3, point=0.2}
for i = 0, 8 do
  local t = i / 8
  local x, y = lerp(200, 280, t), lerp(334, 298, t)
  w:reload((t < 0.4) and warm or ((t < 0.75) and mid or dim), 0.8); w:touch(x, y, {pressure=0.55})
end
for i = 0, 5 do local t = i / 5; w:reload(dim, 0.6); w:touch(lerp(312, 360, t), lerp(276, 250, t), {pressure=0.4}) end
local h = brush{kind="round", width=1.6, point=0.4}
for i = 0, 3 do local t = i / 8; h:reload(pile{{"lead white",2},{"lemon chrome",0.4}}, 0.6); h:touch(lerp(200, 280, t), lerp(334, 298, t) - 0.3, {pressure=0.35}) end

--@ chunk 9
local glare = pile{{"Indian yellow",0.8},{"lead white",2.2},{"yellow ochre",0.4}}
local storm = pile{{"bone brown",1},{"cobalt violet",0.6},{"lead white",0.9}}
for i = 1, 14 do
  local x, y = rand(300, 400), rand(225, 290)
  local b = brush{kind="filbert", width=rand(8, 14)}
  b:reload(glare, rand(0.25, 0.4))
  b:stroke(arc(x, y, rand(40, 90), 5), {pressure={rand(0.3, 0.55), 0.05}, ramps={0.2, 0.6}})
end
for i = 1, 8 do
  local x, y = rand(170, 300), rand(300, 360)
  local b = brush{kind="filbert", width=rand(10, 16)}
  b:reload(storm, rand(0.2, 0.3))
  b:stroke(arc(x, y, rand(50, 100), 5, 0), {pressure={rand(0.25, 0.4), 0.05}, ramps={0.2, 0.6}})
end
