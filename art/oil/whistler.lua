-- easel session "whistler": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=2, linen={18,16}, seed=1872,
  ground={{pile={{"ultramarine blue",1},{"viridian",0.3},{"bone black",0.5},{"lead white",1.2}}, um=80, apply="knife", texture=0.25}}}
-- the sky: one long thin blue wash, a little lighter low down
local sky = pile{{"ultramarine blue",1},{"viridian",0.35},{"bone black",0.35},{"lead white",0.9}, medium=0.75}
local low = pile{{"ultramarine blue",0.8},{"viridian",0.4},{"lead white",1.3},{"bone black",0.2}, medium=0.75}
work(everywhere(), {hand="broad", pile=sky, coverage=2, fill=true, angle=0, load=0.8, ruler=true})
work(rect(0, 280, 1000, 220), {hand="broad", pile=low, coverage=1.6, fill=true, angle=0, load=0.7, ruler=true})
-- the TESTAMENT: a faint vast arch, a hair lighter, laid in long free strokes along its curve
ARC = function(t) return {lerp(230, 1060, t), 300 - 250 * math.sin(math.pi * clamp(t, 0, 1)) } end
local archP = pile{{"lead white",1.4},{"ultramarine blue",0.5},{"viridian",0.25},{"bone black",0.25}, medium=0.7}
for i = 1, 26 do
  local t0 = rand(-0.05, 0.85); local L = rand(0.08, 0.2)
  local off = rand(-12, 12)
  local pts = {} for k = 0, 10 do local p = ARC(t0 + L * k / 10); pts[#pts+1] = {p[1], p[2] + off} end
  local b = brush{kind="filbert", width=rand(16, 26)}
  b:reload(archP, rand(0.35, 0.55)); b:stroke(pts, {pressure={rand(0.35, 0.55), rand(0.25, 0.45)}, ramps={0.3, 0.3}})
end
-- the seed: a long low dark shape across the lower third, left of centre
local seedP = pile{{"bone black",1},{"ultramarine blue",0.7},{"viridian",0.25},{"lead white",0.2}, medium=0.55}
local seedS = {{120, 392}, {200, 380}, {330, 372}, {470, 371}, {590, 377}, {660, 388}}
for i = 1, 14 do
  local off = rand(-6, 14)
  local pts = {} for k, p in ipairs(seedS) do pts[k] = {p[1] + rand(-4, 4), p[2] + off * (1 - math.abs(k - 3.5) / 4)} end
  local b = brush{kind="filbert", width=rand(10, 16)}
  b:reload(seedP, rand(0.5, 0.75)); b:stroke(pts, {pressure={rand(0.4, 0.6), rand(0.3, 0.5)}, ramps={0.25, 0.3}})
end
blend(everywhere(), {angle=0})

--@ chunk 2
local deep = pile{{"ultramarine blue",1},{"viridian",0.45},{"bone black",0.7},{"lead white",0.45}, medium=0.6}
local deepTop = pile{{"ultramarine blue",1},{"viridian",0.3},{"bone black",1},{"lead white",0.25}, medium=0.6}
work(rect(0, 0, 1000, 260), {hand="broad", pile=deepTop, coverage=2, fill=true, angle=0, load=0.8, ruler=true})
work(rect(0, 230, 1000, 270), {hand="broad", pile=deep, coverage=1.8, fill=true, angle=0, load=0.8, ruler=true})
local seedP = pile{{"bone black",1},{"ultramarine blue",0.6},{"viridian",0.3}, medium=0.4}
local seedS = {{100, 396}, {190, 382}, {330, 373}, {480, 372}, {610, 380}, {690, 394}}
for i = 1, 16 do
  local off = rand(-8, 16)
  local pts = {} for k, p in ipairs(seedS) do pts[k] = {p[1] + rand(-4, 4), p[2] + off * (1 - math.abs(k - 3.5) / 4)} end
  local b = brush{kind="filbert", width=rand(12, 18)}
  b:reload(seedP, rand(0.6, 0.85)); b:stroke(pts, {pressure={rand(0.5, 0.7), rand(0.35, 0.55)}, ramps={0.25, 0.3}})
end
blend(everywhere(), {angle=0})

--@ chunk 3
local archP = pile{{"lead white",1.2},{"ultramarine blue",0.6},{"viridian",0.3},{"bone black",0.35}, medium=0.55}
for i = 1, 34 do
  local t0 = rand(-0.05, 0.88); local L = rand(0.08, 0.18)
  local off = rand(-10, 10)
  local pts = {} for k = 0, 10 do local p = ARC(t0 + L * k / 10); pts[#pts+1] = {p[1], p[2] + off} end
  local b = brush{kind="filbert", width=rand(14, 24)}
  b:reload(archP, rand(0.4, 0.6)); b:stroke(pts, {pressure={rand(0.4, 0.6), rand(0.3, 0.5)}, ramps={0.3, 0.3}})
end
-- the inner face of the arch a shade darker, so it reads as a vast band, not a line
local innerP = pile{{"bone black",1},{"ultramarine blue",0.8},{"viridian",0.25},{"lead white",0.35}, medium=0.55}
for i = 1, 20 do
  local t0 = rand(0.0, 0.85); local L = rand(0.1, 0.18)
  local pts = {} for k = 0, 10 do local p = ARC(t0 + L * k / 10); pts[#pts+1] = {p[1] + 8, p[2] + 26 + rand(-4, 4)} end
  local b = brush{kind="filbert", width=rand(14, 20)}
  b:reload(innerP, rand(0.35, 0.5)); b:stroke(pts, {pressure={0.45, 0.35}, ramps={0.3, 0.3}})
end
local bd = brush{kind="badger", width=34}
for i = 1, 40 do
  local t0 = rand(-0.05, 0.85)
  local pts = {} for k = 0, 10 do local p = ARC(t0 + 0.16 * k / 10); pts[#pts+1] = {p[1], p[2] + rand(-6, 22)} end
  bd:wipe(0.95); bd:stroke(pts, {pressure={0.4, 0.3}, ramps={0.2, 0.3}})
end
print(wait(6*1440))

--@ chunk 4
local gold = pile{{"Indian yellow",1},{"cadmium yellow",0.5},{"lead white",0.6},{"Mars orange",0.2}}
local goldP = pile{{"lead white",1.5},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local glowP = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.5}, medium=0.6}
-- the hatch: one warm point on the seed, a faint glow round it
local g = brush{kind="round", width=7, point=0.1}
g:reload(glowP, 0.35); g:touch(468, 371, {pressure=0.35})
local h = brush{kind="round", width=3.2, point=0.2}
h:reload(gold, 0.8); h:touch(468, 371, {pressure=0.6})
local c = brush{kind="round", width=1.6, point=0.4}
c:reload(goldP, 0.7); c:touch(468.3, 370.6, {pressure=0.45})
-- distant windows along the arch: a sparse uneven scatter
local s = brush{kind="round", width=1.8, point=0.5}
local n = 0
for _, t in ipairs(uneven(17, 0.02, 0.95, 0.6, 0.5, 4)) do
  local p = ARC(t)
  local off = rand(-6, 10)
  s:reload((math.random() < 0.3) and goldP or gold, 0.6)
  s:touch(p[1] + rand(-2, 2), p[2] + off, {pressure=rand(0.3, 0.55)})
  n = n + 1
end
-- three falling sparks, as in the Falling Rocket, very faint
for _, q in ipairs({{780, 220}, {806, 262}, {770, 300}}) do s:reload(gold, 0.4); s:touch(q[1], q[2], {pressure=0.25}) end
print(n)

--@ chunk 5
local gold = pile{{"Indian yellow",1},{"cadmium yellow",0.6},{"lead white",0.5},{"Mars orange",0.25}}
local goldP = pile{{"lead white",1.6},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local glowP = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.6}, medium=0.7}
local g = brush{kind="round", width=16, point=0.1}
g:reload(glowP, 0.3); g:touch(468, 371, {pressure=0.3})
local h = brush{kind="round", width=6, point=0.2}
h:reload(gold, 0.9); h:touch(468, 371, {pressure=0.7})
local c = brush{kind="round", width=2.8, point=0.3}
c:reload(goldP, 0.8); c:touch(468.5, 370.5, {pressure=0.6})
local s = brush{kind="round", width=3.6, point=0.3}
for _, t in ipairs(uneven(14, 0.04, 0.95, 0.6, 0.5, 7)) do
  local p = ARC(t)
  s:reload((math.random() < 0.3) and goldP or gold, 0.75)
  s:touch(p[1] + rand(-3, 3), p[2] + rand(-5, 12), {pressure=rand(0.4, 0.65)})
end
