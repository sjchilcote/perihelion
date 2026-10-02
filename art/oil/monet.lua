-- easel session "monet": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.3, linen={18,16}, seed=1872,
  ground={{pile={{"lead white",2.5},{"ultramarine blue",0.3},{"viridian",0.15},{"bone black",0.15}}, um=80, apply="knife", texture=0.3}}}
-- H = 769. The haze line sits at y ~ 400.
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {rand(0.45, 0.75), rand(0.2, 0.45)}, ramps={0.15, 0.4}}) end
local skyB = pile{{"lead white",2},{"ultramarine blue",0.5},{"viridian",0.2},{"bone black",0.25}, medium=0.3}
local skyG = pile{{"lead white",2.2},{"cobalt blue",0.3},{"yellow ochre",0.3},{"bone black",0.2}, medium=0.3}
local skyW = pile{{"lead white",2.2},{"Mars orange",0.35},{"yellow ochre",0.3},{"bone black",0.15}, medium=0.3}
local watB = pile{{"lead white",1.4},{"ultramarine blue",0.6},{"viridian",0.4},{"bone black",0.35}, medium=0.3}
local watG = pile{{"lead white",1.6},{"viridian",0.5},{"cerulean blue",0.3},{"bone black",0.3}, medium=0.3}
local watD = pile{{"lead white",0.9},{"ultramarine blue",0.7},{"viridian",0.4},{"bone black",0.5}, medium=0.3}
-- sky: slanting quick strokes, warmer round the sun
for i = 1, 260 do
  local x, y = rand(-30, 1000), rand(-10, 420)
  local d = math.sqrt((x - 450)^2 + ((y - 300) * 1.4)^2)
  local r = math.random()
  local p = (d < 220 and r < 0.55) and skyW or ((r < 0.55) and skyB or skyG)
  local a = rand(-0.35, -0.05); local L = rand(40, 90)
  S(p, rand(12, 20), rand(0.45, 0.65), {{x, y}, {x + L * math.cos(a), y + L * math.sin(a)}})
end
-- the hazy middle ground and foreground: horizontal strokes, darker toward us
for i = 1, 300 do
  local x, y = rand(-30, 1000), rand(390, 780)
  local t = (y - 390) / 380
  local r = math.random()
  local p = (r < 0.3 + 0.5 * t) and watD or ((r < 0.75) and watB or watG)
  local L = rand(40, 110)
  S(p, rand(10, 18), rand(0.45, 0.65), {{x, y}, {x + L * 0.5, y + rand(-3, 3)}, {x + L, y + rand(-4, 4)}})
end

--@ chunk 2
local skyU = pile{{"lead white",2},{"ultramarine blue",0.4},{"viridian",0.15},{"yellow ochre",0.15},{"bone black",0.2}, medium=0.3}
local watU = pile{{"lead white",1.3},{"ultramarine blue",0.6},{"viridian",0.4},{"bone black",0.35}, medium=0.3}
work(rect(0, 0, 1000, 405), {hand="broad", pile=skyU, coverage=2.6, fill=true, clip=true, angle=-0.2, load=0.85})
work(rect(0, 395, 1000, 380), {hand="broad", pile=watU, coverage=2.6, fill=true, clip=true, angle=0, load=0.85})
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {rand(0.45, 0.75), rand(0.2, 0.45)}, ramps={0.15, 0.4}}) end
local skyB = pile{{"lead white",2},{"ultramarine blue",0.5},{"viridian",0.2},{"bone black",0.25}, medium=0.3}
local skyG = pile{{"lead white",2.2},{"cobalt blue",0.3},{"yellow ochre",0.3},{"bone black",0.2}, medium=0.3}
local skyW = pile{{"lead white",2.2},{"Mars orange",0.35},{"yellow ochre",0.3},{"bone black",0.15}, medium=0.3}
local watB = pile{{"lead white",1.4},{"ultramarine blue",0.6},{"viridian",0.4},{"bone black",0.35}, medium=0.3}
local watG = pile{{"lead white",1.6},{"viridian",0.5},{"cerulean blue",0.3},{"bone black",0.3}, medium=0.3}
local watD = pile{{"lead white",0.9},{"ultramarine blue",0.7},{"viridian",0.4},{"bone black",0.5}, medium=0.3}
for i = 1, 380 do
  local x, y = rand(-30, 1000), rand(-10, 420)
  local d = math.sqrt((x - 450)^2 + ((y - 300) * 1.4)^2)
  local r = math.random()
  local p = (d < 240 and r < 0.6) and skyW or ((r < 0.5) and skyB or skyG)
  local a = rand(-0.35, -0.05); local L = rand(40, 100)
  S(p, rand(14, 22), rand(0.35, 0.55), {{x, y}, {x + L * math.cos(a), y + L * math.sin(a)}})
end
for i = 1, 420 do
  local x, y = rand(-30, 1000), rand(390, 780)
  local t = (y - 390) / 380
  local r = math.random()
  local p = (r < 0.25 + 0.45 * t) and watD or ((r < 0.72) and watB or watG)
  local L = rand(40, 120)
  S(p, rand(10, 18), rand(0.35, 0.55), {{x, y}, {x + L * 0.5, y + rand(-3, 3)}, {x + L, y + rand(-4, 4)}})
end

--@ chunk 3
local sil = pile{{"lead white",1.2},{"ultramarine blue",0.6},{"cobalt violet",0.15},{"bone black",0.45}, medium=0.3}
local silF = pile{{"lead white",1.6},{"ultramarine blue",0.5},{"cobalt violet",0.1},{"bone black",0.35}, medium=0.3}
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.55, 0.35}, ramps={0.15, 0.4}}) end
-- horizon broken by strokes running across it
local hz = pile{{"lead white",1.6},{"ultramarine blue",0.5},{"viridian",0.25},{"bone black",0.3}, medium=0.3}
for i = 1, 70 do local x = rand(-20, 980); local y = rand(385, 420); S(hz, rand(10, 16), 0.45, {{x, y}, {x + rand(40, 90), y + rand(-4, 4)}}, {0.5, 0.3}) end
-- the TESTAMENT's spine, a mast in the mist, left; its ring an ellipse around it
for i = 1, 5 do local x = 210 + rand(-4, 4); S(sil, rand(5, 9), 0.6, {{x, 410}, {x + rand(-3, 3), 260}, {x + rand(-2, 4), 120}}, {0.6, 0.15}) end
local ring = {} for k = 0, 36 do local a = k * math.pi / 18; ring[#ring+1] = {212 + 110 * math.cos(a), 250 + 30 * math.sin(a)} end
for i = 1, 3 do local o = rand(-3, 3); local q = {} for k, p in ipairs(ring) do q[k] = {p[1], p[2] + o} end; local b = brush{kind="filbert", width=6}; b:reload(sil, 0.5); b:stroke(q, {pressure={0.45, 0.45}, swell={1, 0.4, 1, 0.3, 1, 0.5, 1}, ramps={0.1, 0.1}}) end
-- lower structures by the spine's foot, like quayside buildings
for i = 1, 16 do local x = rand(120, 320); local y = rand(370, 405); S(sil, rand(10, 18), 0.55, {{x, y}, {x + rand(20, 60), y + rand(-2, 2)}}, {0.55, 0.4}) end
-- a fainter second structure further off, right: cranes and spars
for _, x in ipairs({730, 768, 810}) do S(silF, rand(4, 7), 0.5, {{x, 405}, {x + rand(-2, 2), 250 + rand(-20, 20)}}, {0.5, 0.1}) end
S(silF, 4, 0.5, {{720, 270}, {800, 245}, {850, 262}}, {0.4, 0.1})
for i = 1, 10 do local x = rand(680, 880); local y = rand(380, 405); S(silF, rand(10, 16), 0.5, {{x, y}, {x + rand(20, 50), y}}, {0.5, 0.3}) end
print(wait(4*1440))

--@ chunk 4
local sun = pile{{"red lead",1},{"vermilion",0.6},{"Mars orange",0.4}}
local refl = pile{{"red lead",1},{"Mars orange",0.8},{"cadmium yellow",0.2}}
local boat = pile{{"ultramarine blue",1},{"bone black",1.2},{"burnt sienna",0.2}}
local boatF = pile{{"ultramarine blue",1},{"bone black",0.6},{"lead white",0.6}}
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.6, 0.4}, ramps={0.1, 0.4}}) end
-- the sun: a small hot disc, two dabs
local sb = brush{kind="round", width=26, point=0.05}
sb:reload(sun, 0.9); sb:touch(470, 290, {pressure=0.75})
sb:reload(sun, 0.7); sb:touch(472, 292, {pressure=0.6})
-- its warm halo, a few strokes in the sky around it
for i = 1, 10 do local x, y = 470 + rand(-60, 50), 290 + rand(-30, 30); S(pile{{"Mars orange",0.6},{"lead white",1.2},{"yellow ochre",0.3}}, rand(10, 14), 0.35, {{x, y}, {x + rand(30, 50), y - rand(4, 12)}}, {0.4, 0.15}) end
-- broken reflection: horizontal dashes running down through the haze, scattering as they come toward us
local y = 420
while y < 680 do
  local t = (y - 420) / 260
  local n = (t < 0.3) and 1 or 2
  for k = 1, n do
    local x = 470 + rand(-12 - 40 * t, 12 + 40 * t)
    local L = rand(22, 40) * (1 - 0.3 * t)
    S(refl, rand(5, 8), rand(0.6, 0.8), {{x - L / 2, y}, {x, y + rand(-1, 1)}, {x + L / 2, y + rand(-2, 2)}}, {0.7, 0.4})
  end
  y = y + rand(12, 20) + 8 * t
end
-- CUCULUS, the rowboat: a long dark hull low in the foreground, its spine like an oarsman
S(boat, 16, 0.9, {{270, 612}, {320, 606}, {372, 610}}, {0.85, 0.6})
S(boat, 9, 0.9, {{282, 620}, {360, 618}}, {0.7, 0.5})
S(boat, 7, 0.85, {{328, 606}, {334, 578}, {338, 566}}, {0.75, 0.15})
S(pile{{"ultramarine blue",1},{"bone black",0.8},{"lead white",0.5}}, 12, 0.5, {{262, 630}, {320, 634}, {390, 628}}, {0.5, 0.2})
-- a second, fainter one further off
S(boatF, 10, 0.7, {{560, 512}, {600, 508}, {630, 511}}, {0.7, 0.4})
S(boatF, 5, 0.7, {{596, 508}, {598, 490}}, {0.6, 0.1})

--@ chunk 5
local sun = pile{{"red lead",1},{"vermilion",0.6},{"Mars orange",0.4}}
local refl = pile{{"red lead",1},{"Mars orange",0.8},{"cadmium yellow",0.2}}
local reflP = pile{{"Mars orange",0.8},{"lead white",1},{"red lead",0.3}}
local boat = pile{{"ultramarine blue",1},{"bone black",1.2},{"burnt sienna",0.2}}
work(ellipse(470, 290, 17, 16), {hand="detail", tool="round 2.5", pile=sun, coverage=5, fill=true, load=1})
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.6, 0.4}, ramps={0.1, 0.4}}) end
-- break the ladder: wider uneven slashes, some paler, some twinned
for i = 1, 26 do
  local y = rand(418, 670); local t = (y - 418) / 252
  local x = 470 + randn(0, 10 + 40 * t)
  local L = rand(14, 52)
  S((math.random() < 0.35) and reflP or refl, rand(4, 9), rand(0.45, 0.75), {{x - L / 2, y + rand(-2, 2)}, {x + L / 2, y + rand(-3, 3)}}, {rand(0.4, 0.7), rand(0.15, 0.35)})
end
-- the boat's pilot, hunched, and an oar
S(boat, 13, 0.9, {{320, 604}, {326, 590}, {334, 584}}, {0.8, 0.5})
local ob = brush{kind="round", width=3, point=0.5}
ob:reload(boat, 0.8); ob:stroke({{340, 596}, {372, 626}, {388, 636}}, {pressure={0.7, 0.3}})
