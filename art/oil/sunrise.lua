-- easel session "sunrise": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=1844,
  ground={{pile={{"lead white",4},{"yellow ochre",0.5},{"Naples"=="x" and "lead white" or "raw sienna",0.15}}, um=90, apply="knife", texture=0.35}}}
SX, SY = 610, 290
function swirl(x, y) local a = math.atan(y - SY, x - SX); local d = math.sqrt((x-SX)^2 + (y-SY)^2); return a + math.pi/2 + 0.35 * clamp(d / 500, 0, 1) end
local ochreV = pile{{"yellow ochre",1},{"raw sienna",0.3},{"lead white",1.5}, medium=0.6}
local goldV = pile{{"Indian yellow",1},{"lead white",2},{"cadmium yellow",0.3}, medium=0.55}
local paleV = pile{{"lead white",3},{"lemon chrome",0.6}, medium=0.4}
work(everywhere(), {hand="broad", pile=ochreV, coverage=2.2, fill=true, angle=swirl, load=0.8})
work(ellipse(SX, SY, 420, 300), {hand="broad", pile=goldV, coverage=2.2, fill=true, angle=swirl, load=0.8})
work(ellipse(SX, SY, 220, 170), {hand="broad", pile=paleV, coverage=2.4, fill=true, angle=swirl, load=0.9})
blend(everywhere(), {angle=swirl})

--@ chunk 2
-- warm swirling arms of the corona, a cool pearl note far from the sun, and the white heart
local nz = noise{seed=9, period=260, octaves=2}
local arm1 = mask(function(x, y) local a = math.atan(y - SY, x - SX); local d = math.sqrt((x-SX)^2 + ((y-SY)*1.3)^2); local s = math.sin(2 * a - d / 70 + 1.2 * nz(x, y)); return (d > 150 and d < 560 and s > 0.55) and 1 or 0 end):soften(10)
local orangeV = pile{{"Mars orange",1},{"Indian yellow",1},{"lead white",1.5}, medium=0.55}
local roseV = pile{{"vermilion",0.5},{"Mars orange",0.8},{"lead white",2}, medium=0.6}
work(arm1, {hand="body", tool="filbert 14", pile=orangeV, coverage=1.8, fill=true, angle=swirl, load=0.7, length={60,160}, curve={0.4, 0.1}})
work(arm1 * below(function(x) return 380 end), {hand="body", tool="filbert 14", pile=roseV, coverage=1.2, fill=true, angle=swirl, load=0.6, length={60,160}})
local pearl = pile{{"lead white",3},{"cerulean blue",0.25},{"bone black",0.08}, medium=0.5}
work(ellipse(90, 70, 210, 120) + ellipse(980, 560, 160, 90), {hand="scumble", pile=pearl, load=0.4, pressure={0.15,0.35}, coverage=1.2, clip=true, angle=swirl})
local core = pile{{"zinc white",3},{"lemon chrome",0.3}}
work(ellipse(SX, SY, 95, 80), {hand="body", tool="filbert 12", pile=core, coverage=2.5, fill=true, angle=swirl, load=1, length={30,90}})
blend(ellipse(SX, SY, 140, 115), {angle=swirl, tool={kind="badger", width=24}})

--@ chunk 3
-- everything swept together wet along the vortex; the core left as it is
local outside = everywhere() - ellipse(SX, SY, 70, 58)
blend(outside, {angle=swirl})
blend(ellipse(90, 70, 260, 160) + ellipse(980, 560, 220, 130), {angle=function(x, y) return swirl(x, y) + 0.5 end})

--@ chunk 4
STM = poly({{140, 470}, {180, 405}, {250, 362}, {330, 350}, {372, 372}, {360, 420}, {300, 470}, {220, 505}, {160, 505}}, true):roughen(10, 40, 4)
local br = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.6}}
local brD = pile{{"bone brown",1.5},{"burnt sienna",1},{"bone black",0.3}}
work(STM, {hand="body", tool="filbert 10", pile=br, coverage=2.5, fill=true, angle=swirl, load=0.9, length={30,80}})
work(STM:shrink(14) * below(function(x) return 400 end), {hand="body", tool="filbert 8", pile=brD, coverage=2.2, fill=true, angle=swirl, load=0.9, length={20,60}})
-- its spire, a darker stroke upward into the glare
local sb = brush{kind="filbert", width=9}
sb:reload(brD, 0.9); sb:stroke({{262, 385}, {300, 300}, {335, 225}}, {pressure={0.8, 0.15}, ramps={0.05, 0.7}})
-- dissolve the sunward edge into the light
blend(STM:grow(30) - STM:shrink(18) + ellipse(300, 300, 40, 80), {angle=swirl, tool={kind="badger", width=20}})
print(wait(6*1440))

--@ chunk 5
local goldS = pile{{"Indian yellow",0.8},{"lead white",2.2},{"yellow ochre",0.5}}
local ochS = pile{{"yellow ochre",1},{"lead white",1.6},{"raw sienna",0.2}}
local ST2 = STM:grow(30) + ellipse(300, 300, 40, 80)
print(lose(ST2, {pile=ochS, where=1, tool="filbert 8", load=0.35, reach={14, 22}}))
local sunward = (ST2:grow(10)) * mask(function(x, y) return (x + 0.6 * (y - 400) > 250) and 1 or 0 end):soften(30)
work(sunward, {hand="scumble", pile=goldS, load=0.3, pressure={0.12,0.35}, coverage=1.4, clip=true, angle=swirl})
work(STM:grow(8) - STM:shrink(4), {hand="scumble", pile=ochS, load=0.25, pressure={0.1,0.3}, coverage=0.9, clip=true, angle=swirl})
print(wait(4*1440))

--@ chunk 6
local fieldP = pile{{"yellow ochre",1},{"Indian yellow",0.6},{"lead white",2.2}}
local Z = ellipse(245, 360, 175, 160)
work(Z, {hand="body", tool="filbert 12", pile=fieldP, coverage=3, fill=true, angle=swirl, load=0.9, length={60,140}, edge="lost"})
blend(ellipse(245, 360, 200, 185), {angle=swirl, tool={kind="badger", width=30}})

--@ chunk 7
function arc(x, y, L, step)
  local pts = {{x, y}}
  for i = 1, math.floor(L / step) do
    local a = swirl(x, y)
    x, y = x + step * math.cos(a), y + step * math.sin(a)
    pts[#pts + 1] = {x, y}
  end
  return pts
end
local P = {
  pile{{"yellow ochre",1},{"lead white",1.8},{"raw sienna",0.2}, medium=0.3},
  pile{{"Indian yellow",1},{"lead white",2},{"cadmium yellow",0.3}, medium=0.3},
  pile{{"Mars orange",0.7},{"Indian yellow",1},{"lead white",1.6}, medium=0.3},
  pile{{"lead white",3},{"lemon chrome",0.4}, medium=0.3},
  pile{{"lead white",3},{"cerulean blue",0.2},{"yellow ochre",0.3}, medium=0.3},
}
local b = brush{kind="filbert", width=14}
local n = 0
for i = 1, 170 do
  local a = rand(0, 6.283); local r = math.sqrt(math.random()) * 250
  local x, y = 245 + r * math.cos(a), 360 + r * math.sin(a) * 0.95
  local d = math.sqrt((x - 245)^2 + (y - 360)^2)
  local p = (math.random() < 0.15) and P[5] or ((x > 300) and P[(math.random() < 0.5) and 2 or 4] or P[(math.random() < 0.6) and 1 or 3])
  b:reload(p, rand(0.35, 0.6))
  local pts = arc(x, y, rand(60, 160), 6)
  if math.random() < 0.5 then local rv = {} for k = #pts, 1, -1 do rv[#rv + 1] = pts[k] end pts = rv end
  b:stroke(pts, {pressure={rand(0.35, 0.7), rand(0.1, 0.3)}, ramps={0.15, 0.5}})
  n = n + 1
end
-- then a clean badger dragged along the same arcs, by hand
local bd = brush{kind="badger", width=26}
for i = 1, 60 do
  local a = rand(0, 6.283); local r = math.sqrt(math.random()) * 260
  local x, y = 245 + r * math.cos(a), 360 + r * math.sin(a)
  bd:wipe(0.95)
  bd:stroke(arc(x, y, rand(80, 180), 6), {pressure={0.3, 0.2}, ramps={0.2, 0.4}})
end
print(n)

--@ chunk 8
print(wait(2*1440))
local br = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.6}}
local brD = pile{{"bone brown",1.5},{"burnt sienna",1},{"bone black",0.4}}
local b = brush{kind="filbert", width=12}
-- body: short heavy arcs packed tight, darkest in the lower left of the mass
for i = 1, 26 do
  local x, y = 175 + rand(0, 130), 395 + rand(0, 70) - (rand(0,1) * 30)
  local dark = (x < 240 and y > 410)
  b:reload(dark and brD or br, rand(0.5, 0.8))
  b:stroke(arc(x, y, rand(30, 75), 5), {pressure={rand(0.55, 0.85), rand(0.2, 0.4)}, ramps={0.1, 0.5}})
end
-- the spire leaning into the glare
local s = brush{kind="filbert", width=8}
s:reload(brD, 0.8); s:stroke({{250, 410}, {275, 350}, {300, 295}, {318, 255}}, {pressure={0.75, 0.05}, ramps={0.05, 0.75}})
-- soften the sunward side by hand
local bd = brush{kind="badger", width=22}
for i = 1, 22 do
  local x, y = 260 + rand(0, 90), 360 + rand(0, 90)
  bd:wipe(0.95); bd:stroke(arc(x, y, rand(50, 110), 5), {pressure={0.35, 0.15}, ramps={0.1, 0.5}})
end
print(wait(6*1440))

--@ chunk 9
print(drying(230,400), drying(500,450), drying(600,290))

--@ chunk 10
-- the hull itself: a long tilted smudge of bronze, its body scumbled thin over the dry gold; then crisp notes
local br = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.6}, medium=0.35}
local brD = pile{{"bone brown",1.5},{"burnt sienna",1},{"bone black",0.4}, medium=0.25}
local ax = -0.42
local b = brush{kind="filbert", width=16}
for i = 1, 14 do
  local t = rand(-1, 1)
  local cx, cy = 230 + 110 * t * math.cos(ax), 410 + 110 * t * math.sin(ax)
  local off = rand(-22, 22)
  cx, cy = cx - off * math.sin(ax), cy + off * math.cos(ax)
  local L = rand(40, 90)
  b:reload((off > 5) and brD or br, rand(0.35, 0.55))
  b:stroke({{cx - L/2 * math.cos(ax), cy - L/2 * math.sin(ax)}, {cx + L/2 * math.cos(ax), cy + L/2 * math.sin(ax)}}, {pressure={rand(0.3, 0.55), 0.1}, ramps={0.2, 0.5}})
end
local bd = brush{kind="badger", width=24}
for i = 1, 16 do
  local x, y = 250 + rand(0, 90), 330 + rand(0, 80)
  bd:wipe(0.95); bd:stroke(arc(x, y, rand(50, 100), 5), {pressure={0.3, 0.12}, ramps={0.1, 0.5}})
end
print(wait(5*1440))

--@ chunk 11
-- the hard notes: the ring's arc, crisp then lost in the glare; one warm window; the brightest touches in the core
local ringP = pile{{"bone brown",1},{"burnt sienna",1},{"raw sienna",0.4}}
local r = brush{kind="round", width=2.6, point=0.6}
local pts = {}
for i = 0, 30 do
  local a = math.rad(150 + 190 * i / 30)
  pts[#pts + 1] = {225 + 120 * math.cos(a) * math.cos(-0.35) - 34 * math.sin(a) * math.sin(-0.35), 365 + 120 * math.cos(a) * math.sin(-0.35) + 34 * math.sin(a) * math.cos(-0.35)}
end
r:reload(ringP, 0.8); r:stroke(pts, {pressure={0.75, 0.0}, ramps={0.05, 0.75}})
local w = brush{kind="round", width=4, point=0.2}
w:reload(pile{{"vermilion",1},{"Mars orange",1},{"cadmium yellow",0.4}}, 0.8); w:touch(236, 352, {pressure=0.6})
local wc = brush{kind="round", width=1.8, point=0.4}
wc:reload(pile{{"cadmium yellow",1},{"lead white",1}}, 0.6); wc:touch(236.5, 351.5, {pressure=0.4})
-- scraped lights along the sunward edges of the hull, and the white heart
local hiP = pile{{"zinc white",3},{"lemon chrome",0.25}}
local s = brush{kind="round", width=2, point=0.7}
for _, seg in ipairs({{{268, 270}, {276, 300}}, {{276, 330}, {281, 365}}, {{172, 330}, {176, 350}}}) do s:reload(hiP, 0.6); s:stroke(seg, {pressure={0.5, 0.1}, ramps={0.05, 0.6}}) end
local c = brush{kind="filbert", width=10}
c:reload(hiP, 1); c:stroke(arc(590, 285, 40, 4), {pressure={0.7, 0.4}})
c:reload(hiP, 1); c:touch(612, 290, {pressure=0.8})
