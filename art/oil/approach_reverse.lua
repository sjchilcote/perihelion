-- easel session "approach_reverse": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=8087,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"bone brown",1},{"ultramarine blue",0.4},{"lead white",0.4}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
-- Last Morning's window, the Sun now high in it; outside: deep blue-black space, the station's own ring curving across the bottom
SUN = {600, 560}
WIN = rect(232, 380, 536, 720) + ellipse(500, 380, 268, 270)
WALL = everywhere() - WIN
RINGC = {{220,960},{360,930},{500,912},{640,906},{790,910}}
OUTRING = below(RINGC) * WIN
SKY = WIN - OUTRING
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
local function rad(x, y) return math.atan(y - SUN[2], x - SUN[1]) end
local space = pile{{"ultramarine blue",1.2},{"bone black",1.5},{"cobalt violet",0.2}}
local halo1 = pile{{"ultramarine ash",1},{"bone black",0.6},{"Mars orange",0.3},{"lead white",0.3}}
local halo2 = pile{{"Mars orange",1},{"yellow ochre",0.8},{"lead white",0.7}}
local core = pile{{"lead white",2},{"cadmium yellow",0.7},{"zinc white",0.5}}
wallP = pile{{"bone black",2},{"burnt sienna",1.2},{"raw sienna",0.3}}
work(WALL, {hand="broad", pile=wallP, coverage=2.8, fill=true, angle=1.57, angle_jitter=0.3})
work(SKY, {hand="broad", pile=space, coverage=2.6, fill=true, angle=rad, clip=SKY})
local r1 = SKY * mask(function(x, y) return rd(x, y) < 300 and 1 or 0 end)
work(r1, {hand="broad", pile=halo1, coverage=2, fill=true, angle=rad, clip=SKY})
local r2 = SKY * mask(function(x, y) return rd(x, y) < 190 and 1 or 0 end)
work(r2, {hand="broad", pile=halo2, coverage=2.2, fill=true, angle=rad, clip=SKY})
local r3 = SKY * mask(function(x, y) return rd(x, y) < 95 and 1 or 0 end)
work(r3, {hand="body", pile=core, coverage=2.4, fill=true, angle=rad, clip=SKY})
local ringP = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.4}}
work(OUTRING:grow(2) * WIN, {hand="body", pile=ringP, coverage=3, fill=true, angle=0.05, clip=WIN})

--@ chunk 3
-- melt the halo bands once, radially
local function rad(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end
blend(SKY:shrink(3) * mask(function(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) < 340 and 1 or 0 end), {angle=rad})

--@ chunk 4
print(wait(3*24*60))
-- the grey halo ring back to deep space; keep only the inner gold and core; walls a lean dark second coat
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
local space = pile{{"ultramarine blue",1.2},{"bone black",1.8},{"cobalt violet",0.2}}
local outer = SKY * mask(function(x, y) return rd(x, y) > 150 and 1 or 0 end)
work(outer, {hand="body", tool="filbert 8", pile=space, coverage=3.6, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, clip=SKY, load=0.95})
local w = WALL - WIN:grow(4)
work(w, {hand="broad", pile=pile{{"bone black",2.5},{"burnt sienna",1},{"ultramarine blue",0.2}}, coverage=3, fill=true, angle=1.57, angle_jitter=0.15, clip=w})

--@ chunk 5
print(wait(3*24*60))
-- corona: long strokes out from the Sun on dry paint, white near it, gold, thinning to orange in the blue
local cW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.35}}
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}
local thin = brush{kind="round", width=2.4, point=0.5}
local mid = brush("filbert", 5)
local wide = brush("filbert", 10)
for i = 1, 190 do
  local a = rand(-math.pi, math.pi)
  local r0 = rand(40, 80)
  local len = 50 + 360 * rand(0, 1)^1.7
  local br = (len > 240) and wide or ((math.random() < 0.5) and mid or thin)
  local p = (len < 120) and cW or ((len < 230) and cG or cO)
  local x0, y0 = SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0
  local x1, y1 = SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)
  br:reload(p, 0.5)
  br:stroke({{x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2}, {x1, y1}}, {pressure={0.5, 0.02}, ramps={0.1, 0.8}, orient="along", clip=SKY})
end
local disc = ellipse(SUN[1], SUN[2], 62, 62) * SKY
work(disc, {hand="body", pile=cW, coverage=2.8, fill=true, angle=0, clip=true})
local core = ellipse(SUN[1], SUN[2], 42, 42) * SKY
work(core, {hand="body", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=2.6, fill=true, angle=0, clip=true})

--@ chunk 6
-- the glow between the rays; the station's ring outside: lit upper edge, rows of tiny warm windows
local function rd(x, y) return math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2) end
local gY = pile{{"Indian yellow",1},{"cadmium yellow",0.8},{"lead white",0.25}, medium=0.8}
local G = SKY * ellipse(SUN[1], SUN[2], 300, 300) - ellipse(SUN[1], SUN[2], 60, 60)
work(G, {hand="glaze", pile=gY, coverage=1.6, fill=true, angle=function(x, y) return math.atan(y - SUN[2], x - SUN[1]) + math.pi/2 end, clip=SKY, pressure={0.15, 0.3},
  load_at=function(x, y) return 0.45 * (1 - smoothstep(70, 300, rd(x, y))) end})
local rim = brush{kind="round", width=2.2, point=0.6}
local pts = {}
for _, p in ipairs(RINGC) do pts[#pts+1] = {p[1], p[2] + 1.5} end
rim:load(pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}}, 0.6)
rim:stroke(pts, {pressure={0.2, 0.5}, swell={0.5, 1, 1.4, 1.2, 0.8}, ramps={0.1, 0.1}})
local w = brush{kind="round", width=1.3, point=0.6}
local n = 0
for row = 1, 5 do
  local dy = 16 + row * row * 5
  for x = 236, 766, rand(5, 9) do
    if math.random() < 0.45 then
      local y0
      for i = 1, #RINGC - 1 do local a, b = RINGC[i], RINGC[i + 1]; if x >= a[1] and x <= b[1] then y0 = lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
      y0 = (y0 or 910) + dy
      if OUTRING:shrink(2):at(x, y0) > 0.5 then
        if n % 8 == 0 then w:load(pile{{"lead white",1.5},{"Indian yellow",0.6},{"Mars orange",0.3}}, 0.55) end
        w:touch(x, y0, {pressure=rand(0.2, 0.45)}); n = n + 1
      end
    end
  end
end
print(n)

--@ chunk 7
print(wait(2*24*60))
-- the bronze surround: a deep reveal around the opening, plates on it, the inner edge catching the light
FRAME = WIN:grow(46) - WIN
frameD = pile{{"bone black",1.6},{"burnt sienna",1.2},{"raw sienna",0.5}}
frameM = pile{{"burnt sienna",1.4},{"raw sienna",1},{"bone black",0.5}}
work(FRAME, {hand="body", pile=frameD, coverage=3, fill=true, angle=function(x, y) return math.atan(y - 380, x - 500) + math.pi/2 end, clip=FRAME})
-- plates around the reveal, laid by golden angle along its length
local GA = math.pi * (3 - math.sqrt(5))
local pb = brush("filbert", 11)
local sb = brush{kind="round", width=2.2, point=0.5}
local L = 2 * 720 + math.pi * 268
local n = 0
for k = 1, 340 do
  local s = (k * 0.618034) % 1 * L
  local x, y, nx, ny
  if s < 720 then x, y, nx, ny = 232, 1100 - s, -1, 0
  elseif s < 720 + math.pi * 268 then
    local a = math.pi + (s - 720) / 268; x, y, nx, ny = 500 + math.cos(a) * 268, 380 + math.sin(a) * 270, math.cos(a), math.sin(a)
  else x, y, nx, ny = 768, 380 + (s - 720 - math.pi * 268), 1, 0 end
  local d = 6 + ((k * GA) % 1) * 34
  local px, py = x + nx * d, y + ny * d
  local tx, ty = -ny, nx
  local toward = clamp(1 - math.sqrt((px - SUN[1])^2 + (py - SUN[2])^2) / 700, 0, 1)
  if n % 3 == 0 then pb:reload((toward > 0.35) and frameM or frameD, 0.5); sb:reload(pile{{"bone black",2},{"ultramarine blue",0.3}}, 0.5) end
  n = n + 1
  pb:stroke({{px - tx * 6, py - ty * 6}, {px + nx * 1.5, py + ny * 1.5}, {px + tx * 6, py + ty * 6}}, {pressure={0.55, 0.4}, ramps={0.15, 0.4}, clip=FRAME})
  sb:stroke({{px - tx * 6 + nx * 5, py - ty * 6 + ny * 5}, {px + nx * 6.5, py + ny * 6.5}, {px + tx * 6 + nx * 5, py + ty * 6 + ny * 5}}, {pressure={0.4, 0.1}, ramps={0.2, 0.4}, clip=FRAME})
end
print(n)

--@ chunk 8
-- golden-angle tracery in the arch head: crossing spiral bars round a central boss, and a transom; dark against the sky, lit edges toward the Sun
local HEAD = WIN * rect(200, 90, 600, 290)
local C = {500, 330}
local bar = pile{{"bone black",2},{"burnt sienna",1}}
local lit = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.8},{"cadmium yellow",0.2}}
local b = brush{kind="round", width=4.2, point=0.3}
local e = brush{kind="round", width=1.4, point=0.8}
local function spiral(a0, dir)
  local pts = {}
  for k = 0, 40 do
    local th = k * 0.09
    local r = 14 * math.exp(0.306 * th * 2.2)
    local a = a0 + dir * th
    local x, y = C[1] + math.cos(a) * r, C[2] + math.sin(a) * r * 1.02
    pts[#pts+1] = {x, y}
    if r > 330 then break end
  end
  return pts
end
local arms = {}
for i = 0, 12 do arms[#arms+1] = spiral(i * 2 * math.pi / 13, 1) end
for i = 0, 7 do arms[#arms+1] = spiral(i * 2 * math.pi / 8 + 0.2, -1) end
for _, pts in ipairs(arms) do
  b:load(bar, 0.7); b:stroke(pts, {pressure={0.8, 0.8}, ramps={0.05, 0.05}, clip=HEAD})
end
for _, pts in ipairs(arms) do
  local q = {}
  for _, p in ipairs(pts) do q[#q+1] = {p[1] + 1.6, p[2] + 1.6} end
  e:load(lit, 0.5); e:stroke(q, {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=HEAD})
end
-- transom and central boss
local t = brush("flat", 9)
t:load(bar, 0.8); t:stroke({{232, 376}, {768, 376}}, {pressure={0.9, 0.9}, ramps={0.01, 0.01}, orient="across", clip=WIN})
e:load(lit, 0.6); e:stroke({{232, 381}, {768, 381}}, {pressure={0.55, 0.55}, ramps={0.01, 0.01}, clip=WIN})
local bo = brush{kind="round", width=16, point=0.1}
bo:load(bar, 0.85); bo:touch(C[1], C[2], {pressure=0.9})
e:load(lit, 0.6); e:stroke({{C[1] - 4, C[2] + 6}, {C[1] + 5, C[2] + 5}}, {pressure={0.5, 0.3}})

--@ chunk 9
print(wait(2*24*60))
-- the tracery heavier and reaching the whole arch head: same spirals carried out to the frame, dark bronze bars
local HEAD = WIN * rect(200, 90, 600, 282)
local C = {500, 330}
local bar = pile{{"bone black",2.5},{"burnt sienna",1}}
local b = brush("filbert", 6)
local function spiral(a0, dir)
  local pts = {}
  for k = 0, 80 do
    local th = k * 0.06
    local r = 14 * math.exp(0.67 * th)
    local a = a0 + dir * th
    pts[#pts+1] = {C[1] + math.cos(a) * r, C[2] + math.sin(a) * r}
    if r > 340 then break end
  end
  return pts
end
for i = 0, 12 do b:load(bar, 0.85); b:stroke(spiral(i * 2 * math.pi / 13, 1), {pressure={0.6, 0.9}, ramps={0.05, 0.05}, orient="across", clip=HEAD}) end
for i = 0, 7 do b:load(bar, 0.85); b:stroke(spiral(i * 2 * math.pi / 8 + 0.2, -1), {pressure={0.6, 0.9}, ramps={0.05, 0.05}, orient="across", clip=HEAD}) end
local bo = brush{kind="round", width=22, point=0.1}
bo:load(bar, 0.9); bo:touch(C[1], C[2], {pressure=0.95})

--@ chunk 10
print(wait(3*24*60))
-- frame and outside ring repainted deep; wall a final lean dark
local dk = pile{{"bone black",2.5},{"burnt sienna",1},{"raw sienna",0.2}}
local FR = WIN:grow(46) - WIN
work(FR, {hand="body", tool="filbert 6", pile=dk, coverage=3.4, fill=true, angle=function(x, y) return math.atan(y - 380, x - 500) + math.pi/2 end, clip=FR, load=0.9})
work(OUTRING:shrink(2), {hand="body", tool="filbert 6", pile=pile{{"bone black",2.5},{"burnt sienna",0.8},{"ultramarine blue",0.3}}, coverage=3.4, fill=true, angle=0.03, clip=true, load=0.9})
local w = WALL - WIN:grow(48)
local function d(x, y) return math.sqrt((x - 500)^2 + ((y - 700) / 1.3)^2) end
work(w, {hand="broad", pile=pile{{"bone black",3},{"burnt sienna",0.7},{"ultramarine blue",0.3}}, coverage=3, fill=true, angle=1.57, angle_jitter=0.15, clip=w,
  load_at=function(x, y) return 0.45 + 0.5 * smoothstep(300, 650, d(x, y)) end})
-- break the glow's round edge: deep-space strokes running outward from r~180, between which the rays stay
local space = pile{{"ultramarine blue",1.2},{"bone black",1.8},{"cobalt violet",0.2}}
local b = brush("filbert", 8)
for i = 1, 90 do
  local a = rand(-math.pi, math.pi)
  local r0 = rand(170, 240); local r1 = r0 + rand(80, 200)
  b:reload(space, 0.8)
  b:stroke({{SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0}, {SUN[1] + math.cos(a) * r1, SUN[2] + math.sin(a) * r1}}, {pressure={0.1, 0.8}, ramps={0.5, 0.1}, orient="along", clip=SKY - rect(200, 90, 600, 290)})
end

--@ chunk 11
print(wait(3*24*60))
-- frame plates restated (dim, toward the light a little warmer), the reveal's inner edge lit; ring windows; fresh long rays across the glow's edge
local frameM = pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.8}}
local FR = WIN:grow(46) - WIN
local pb = brush("filbert", 10)
local sb = brush{kind="round", width=2, point=0.5}
local GA = math.pi * (3 - math.sqrt(5))
local L = 2 * 720 + math.pi * 268
for k = 1, 260 do
  local s = (k * 0.618034) % 1 * L
  local x, y, nx, ny
  if s < 720 then x, y, nx, ny = 232, 1100 - s, -1, 0
  elseif s < 720 + math.pi * 268 then local a = math.pi + (s - 720) / 268; x, y, nx, ny = 500 + math.cos(a) * 268, 380 + math.sin(a) * 270, math.cos(a), math.sin(a)
  else x, y, nx, ny = 768, 380 + (s - 720 - math.pi * 268), 1, 0 end
  local d = 6 + ((k * GA) % 1) * 34
  local px, py = x + nx * d, y + ny * d
  local tx, ty = -ny, nx
  if k % 3 == 1 then pb:reload(frameM, 0.45); sb:reload(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.5) end
  pb:stroke({{px - tx * 6, py - ty * 6}, {px + nx * 1.5, py + ny * 1.5}, {px + tx * 6, py + ty * 6}}, {pressure={0.45, 0.3}, ramps={0.15, 0.4}, clip=FR})
  sb:stroke({{px - tx * 6 + nx * 5, py - ty * 6 + ny * 5}, {px + nx * 6.5, py + ny * 6.5}, {px + tx * 6 + nx * 5, py + ty * 6 + ny * 5}}, {pressure={0.4, 0.1}, ramps={0.2, 0.4}, clip=FR})
end
local e = brush{kind="round", width=2.2, point=0.6}
e:load(pile{{"lead white",2},{"Mars orange",0.4},{"cadmium yellow",0.4}}, 0.6)
e:stroke({{769, 1095}, {769, 800}, {769, 560}}, {pressure={0.7, 0.1}, ramps={0.1, 0.4}})
e:load(pile{{"lead white",2},{"Mars orange",0.4},{"cadmium yellow",0.4}}, 0.5)
e:stroke({{229, 640}, {229, 860}, {229, 1095}}, {pressure={0.05, 0.35}, ramps={0.4, 0.1}})
-- ring windows again
local w = brush{kind="round", width=1.4, point=0.6}
local n = 0
for row = 1, 5 do
  local dy = 16 + row * row * 5
  for x = 236, 766, 6 do
    if math.random() < 0.4 then
      local y0 = 910
      for i = 1, #RINGC - 1 do local a, b = RINGC[i], RINGC[i + 1]; if x >= a[1] and x <= b[1] then y0 = lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1])) end end
      y0 = y0 + dy
      if OUTRING:shrink(2):at(x, y0) > 0.5 then
        if n % 8 == 0 then w:load(pile{{"lead white",2},{"Indian yellow",0.6},{"Mars orange",0.3}}, 0.6) end
        w:touch(x + rand(-1, 1), y0, {pressure=rand(0.25, 0.5)}); n = n + 1
      end
    end
  end
end
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}
local thin = brush{kind="round", width=2.0, point=0.5}
for i = 1, 70 do
  local a = rand(-math.pi, math.pi); local r0 = rand(90, 150); local len = rand(150, 380)
  thin:reload((len < 250) and cG or cO, 0.5)
  thin:stroke({{SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0}, {SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)}}, {pressure={0.5, 0.02}, ramps={0.1, 0.85}, orient="along", clip=SKY - rect(200, 90, 600, 290)})
end
print(n)

--@ chunk 12
print(wait(2*24*60))
-- the sill; then the spark: the CUCULUS's braking burn crossing the glare, its thin trail behind it
work(rect(220, 1098, 560, 10), {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.7},{"Mars orange",0.2}}, coverage=2.6, fill=true, angle=0, clip=true})
work(rect(214, 1108, 572, 26), {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",1}}, coverage=2.6, fill=true, angle=0, clip=true})
SPARK = {512, 492}
local tr = brush{kind="round", width=1.2, point=0.8}
tr:load(pile{{"zinc white",2},{"cerulean blue",0.25}}, 0.55)
tr:stroke({{300, 410}, {400, 448}, {SPARK[1] - 6, SPARK[2] - 2}}, {pressure={0.05, 0.45}, ramps={0.6, 0.05}})
local dk = brush{kind="round", width=5, point=0.1}
dk:load(pile{{"Mars orange",1},{"bone black",0.4},{"cadmium red",0.3}}, 0.6); dk:touch(SPARK[1], SPARK[2], {pressure=0.6})

--@ chunk 13
print(wait(2*24*60))
local s = brush{kind="round", width=3.2, point=0.2}
s:load(pile{{"zinc white",4},{"cerulean blue",0.12}}, 0.8); s:touch(SPARK[1], SPARK[2], {pressure=0.8})
local f = brush{kind="round", width=1.0, point=0.9}
f:load(pile{{"zinc white",4}}, 0.6)
f:stroke({{SPARK[1] - 9, SPARK[2]}, {SPARK[1] + 9, SPARK[2]}}, {pressure={0.05, 0.05}, swell={0.2, 1.8, 0.2}})
f:load(pile{{"zinc white",4}}, 0.6)
f:stroke({{SPARK[1], SPARK[2] - 6}, {SPARK[1], SPARK[2] + 6}}, {pressure={0.05, 0.05}, swell={0.2, 1.6, 0.2}})
-- the docent: a tall slender bronze machine, back to us, at the sill; elongated head with one lens; one hand flat on the glass
DOC = ellipse(392, 700, 21, 33)                                                           -- head
  + poly({{384,728},{400,728},{404,760},{380,760}})                                       -- neck
  + poly({{352,768},{432,766},{444,790},{438,880},{430,990},{424,1100},{430,1240},{440,1333},{336,1333},{348,1240},{356,1100},{350,990},{344,880},{340,790}}, true)
  + ribbon({{432,776},{458,730},{476,676}}, {16, 13, 11})                                 -- raised right arm
  + poly({{468,682},{474,640},{482,632},{492,636},{490,682},{480,690}}, true)              -- flat hand on the glass
  + ribbon({{352,780},{334,880},{332,980}}, {16, 14, 12})                                 -- left arm hanging
DOC = DOC:roughen(1, 8, 5)
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
work(DOC, {hand="body", tool="filbert 4", pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 14
-- sloping mantle over the boxy shoulders, the head tilted a little toward the spark
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
local mant = poly({{336,820},{344,790},{360,764},{378,744},{392,738},{404,740},{420,752},{440,772},{450,800},{448,830}}, true)
local tilt = ellipse(398, 696, 18, 28)
work(mant + tilt, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})
DOC = DOC + mant + tilt
-- the spark, larger: a hot blue-white point with a short flare
local s = brush{kind="round", width=6, point=0.1}
s:load(pile{{"zinc white",4},{"cerulean blue",0.2}}, 0.85); s:touch(SPARK[1], SPARK[2], {pressure=0.85})
local f = brush{kind="round", width=1.6, point=0.9}
for _, d in ipairs({{-18, 0}, {18, 0}, {0, -12}, {0, 12}}) do
  f:load(pile{{"zinc white",4},{"cerulean blue",0.1}}, 0.6)
  f:stroke({{SPARK[1], SPARK[2]}, {SPARK[1] + d[1], SPARK[2] + d[2]}}, {pressure={0.7, 0.02}, ramps={0.02, 0.8}})
end
local tr = brush{kind="round", width=1.8, point=0.8}
tr:load(pile{{"zinc white",3},{"cerulean blue",0.3}}, 0.6)
tr:stroke({{340, 425}, {430, 460}, {SPARK[1] - 6, SPARK[2] - 2}}, {pressure={0.05, 0.6}, ramps={0.6, 0.05}})

--@ chunk 15
print(wait(3*24*60))
-- gold rim on the docent's sunward edges (right and top), thin and broken; the single lens catching the spark
local hot = pile{{"zinc white",1},{"lead white",2},{"cadmium yellow",0.5}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.4}}
local nz = noise{seed=21, period=7}
local edge = mask(function(x, y)
  if x < 320 or x > 500 or y < 620 or y > 1100 then return 0 end
  if DOC:at(x, y) < 0.5 then return 0 end
  if DOC:at(x + 1.6, y - 1.2) > 0.5 then return 0 end
  return nz:at01(x, y) > 0.3 and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=1.2, point=0.8}, pile=gold, coverage=2, fill=true, clip=true, angle=1.0})
local hi = edge * mask(function(x, y) return (y < 790) and 1 or 0 end)
work(hi, {hand="detail", tool={kind="round", width=1.0, point=0.9}, pile=hot, coverage=1.6, fill=true, clip=true, angle=1.0})
-- lens: a dark socket, a bright pinpoint of the spark in it
local l = brush{kind="round", width=5, point=0.1}
l:load(pile{{"bone black",2},{"ultramarine blue",0.6}}, 0.8); l:touch(410, 694, {pressure=0.8})
local g = brush{kind="round", width=2.2, point=0.3}
g:load(pile{{"zinc white",4},{"cerulean blue",0.15}}, 0.75); g:touch(411.5, 692.5, {pressure=0.75})
-- light falls on the sill beside the figure and a long shadow runs back into the room
local sh = brush("filbert", 16)
sh:load(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.85)
sh:stroke({{392, 1240}, {380, 1290}, {370, 1335}}, {pressure={0.9, 0.9}, orient="across"})
print(edge:area())

--@ chunk 16
print(wait(2*24*60))
-- the lens, plainly: a cool ring with the spark's pinpoint in it; a small halo round the spark; the hand's lit edge
local l = brush{kind="round", width=6, point=0.1}
l:load(pile{{"ultramarine blue",1},{"bone black",1},{"cerulean blue",0.4}}, 0.8); l:touch(404, 690, {pressure=0.8})
local g = brush{kind="round", width=3, point=0.2}
g:load(pile{{"zinc white",4},{"cerulean blue",0.15}}, 0.8); g:touch(405, 688.5, {pressure=0.85})
local h = brush{kind="round", width=8, point=0.1}
h:load(pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.1}, medium=0.6}, 0.4)
for _, d in ipairs({{-3, 0}, {3, 0}, {0, -3}, {0, 3}}) do h:touch(SPARK[1] + d[1], SPARK[2] + d[2], {pressure=0.25}) end
local s = brush{kind="round", width=5, point=0.1}
s:load(pile{{"zinc white",4}}, 0.85); s:touch(SPARK[1], SPARK[2], {pressure=0.8})
local r = brush{kind="round", width=1.4, point=0.8}
r:load(pile{{"zinc white",1},{"lead white",2},{"cadmium yellow",0.5}}, 0.6)
r:stroke({{491,640},{492,662},{490,682}}, {pressure={0.6, 0.3}})
r:load(pile{{"zinc white",1},{"lead white",2},{"cadmium yellow",0.5}}, 0.6)
r:stroke({{476,640},{483,632},{491,636}}, {pressure={0.5, 0.3}})
