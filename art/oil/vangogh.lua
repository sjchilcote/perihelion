-- easel session "vangogh": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=4/3, linen={18,16}, seed=1889,
  ground={{pile={{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.8},{"bone black",0.15}}, um=80, apply="knife", texture=0.3}}}
-- H = 750
EDDIES = {{430, 250, 120, 1}, {640, 210, 85, -1}, {230, 170, 70, 1}}
function hillY(x) return 560 - 40 * math.sin(x / 160 + 0.6) - 25 * math.sin(x / 70) end
function flow(x, y)
  local a = 0.28 * math.sin(x / 110 + y / 70)
  local vx, vy = math.cos(a), math.sin(a)
  for _, e in ipairs(EDDIES) do
    local dx, dy = x - e[1], y - e[2]; local d = math.sqrt(dx*dx + dy*dy) + 1e-6
    local w = math.exp(-(d / (e[3] * 1.4))^2) * 2.2
    local tx, ty = -dy / d * e[4], dx / d * e[4]
    vx, vy = vx + w * tx, vy + w * ty
  end
  return math.atan(vy, vx)
end
local hl = {} for x = -10, 1010, 20 do hl[#hl+1] = {x, hillY(x)} end
SKY = above(hl); HILLS = below(hl)
work(SKY, {hand="broad", pile=pile{{"ultramarine blue",1},{"cobalt blue",0.6},{"lead white",0.7}}, coverage=2.6, fill=true, clip=true, angle=flow, load=0.9})
work(HILLS, {hand="broad", pile=pile{{"ultramarine blue",1},{"bone black",0.7},{"viridian",0.25},{"lead white",0.2}}, coverage=2.8, fill=true, clip=true, angle=-0.1, load=0.9})

--@ chunk 2
-- the sky: thick directional dashes everywhere along the flow; yellow-white in the eddies, ultramarine between
local P = {
  deep = pile{{"ultramarine blue",1},{"cobalt blue",0.4},{"bone black",0.2},{"lead white",0.3}},
  mid = pile{{"cobalt blue",1},{"ultramarine blue",0.4},{"lead white",0.9}},
  pale = pile{{"cerulean blue",1},{"lead white",1.6}},
  wht = pile{{"lead white",2},{"cerulean blue",0.25},{"lemon chrome",0.1}},
  yel = pile{{"lemon chrome",1},{"lead white",1},{"cadmium yellow",0.3}},
}
local function dash(x, y, p, L, w)
  local a = flow(x, y)
  local b = brush{kind="filbert", width=w}
  b:reload(p, 0.85)
  local x2, y2 = x + L * 0.5 * math.cos(a), y + L * 0.5 * math.sin(a)
  local a2 = flow(x2, y2)
  b:stroke({{x - L * 0.5 * math.cos(a), y - L * 0.5 * math.sin(a)}, {x, y}, {x2 + L * 0.5 * math.cos(a2), y2 + L * 0.5 * math.sin(a2)}}, {pressure={0.8, 0.5}, ramps={0.1, 0.3}})
end
local n = 0
for y = 6, 600, 9 do
  for x = 4, 996, 11 do
    local px, py = x + rand(-5, 5), y + rand(-4, 4)
    if SKY:at(px, py) > 0.5 then
      local inE = 0
      for _, e in ipairs(EDDIES) do local d = math.sqrt((px - e[1])^2 + (py - e[2])^2); inE = math.max(inE, math.exp(-(d / e[3])^2)) end
      local band = 0.5 + 0.5 * math.sin(px / 90 + py / 60)
      local r = math.random()
      local p
      if inE > 0.45 then p = (r < 0.45) and P.wht or ((r < 0.75) and P.pale or P.yel)
      elseif inE > 0.15 then p = (r < 0.4) and P.pale or ((r < 0.7) and P.mid or P.wht)
      else p = (r < 0.35 + 0.3 * band) and P.deep or ((r < 0.8) and P.mid or P.pale) end
      dash(px, py, p, rand(16, 26), rand(6, 9))
      n = n + 1
    end
  end
end
print(n)

--@ chunk 3
local yel = pile{{"lemon chrome",1},{"lead white",0.8},{"cadmium yellow",0.4}}
local yelO = pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",0.5}}
local wht = pile{{"lead white",2.2},{"lemon chrome",0.2}}
local pale = pile{{"cerulean blue",0.8},{"lead white",1.8},{"lemon chrome",0.1}}
local function halo(cx, cy, r0, rings, core)
  -- concentric strokes going round, each ring a little paler and bluer
  for k = 0, rings do
    local r = r0 * (0.35 + 0.65 * k / rings) + 4
    local nseg = math.floor(8 + r / 4)
    local p = (k == 0) and core or ((k < rings * 0.5) and wht or pale)
    for s = 0, nseg - 1 do
      local a0 = s * 2 * math.pi / nseg + rand(-0.1, 0.1); local a1 = a0 + 2 * math.pi / nseg * 0.85
      local pts = {} for i = 0, 4 do local a = lerp(a0, a1, i / 4); pts[#pts+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
      local b = brush{kind="filbert", width=math.max(4, r0 / rings * 0.9)}
      b:reload(p, 0.85); b:stroke(pts, {pressure={0.75, 0.5}, ramps={0.1, 0.3}})
    end
  end
  local c = brush{kind="round", width=r0 * 0.5, point=0.05}; c:reload(core, 0.95); c:touch(cx, cy, {pressure=0.8})
end
-- the Sun: upper right, a big halo with a hot core, in place of the moon
halo(880, 110, 70, 5, yelO)
local c = brush{kind="round", width=36, point=0.05}; c:reload(yel, 1); c:touch(880, 110, {pressure=0.85})
-- stars
for _, s in ipairs({{70, 70, 26}, {330, 70, 22}, {560, 95, 20}, {760, 300, 24}, {110, 300, 18}, {950, 360, 20}, {640, 400, 16}, {480, 40, 14}}) do halo(s[1], s[2], s[3], 3, yel) end

--@ chunk 4
print(wait(4*1440))
local yel = pile{{"lemon chrome",1},{"lead white",0.6},{"cadmium yellow",0.5}}
local yelO = pile{{"cadmium yellow",1},{"Mars orange",0.35},{"lemon chrome",0.4},{"lead white",0.3}}
local wht = pile{{"lead white",2.2},{"lemon chrome",0.4}}
local function W(m, p) work(m, {hand="detail", tool="round 2.5", pile=p, coverage=5, fill=true, load=1}) end
W(ellipse(880, 110, 30, 30), yelO)
W(ellipse(880, 110, 42, 42) - ellipse(880, 110, 30, 30), yel)
for _, s in ipairs({{70, 70, 26}, {330, 70, 22}, {560, 95, 20}, {760, 300, 24}, {110, 300, 18}, {950, 360, 20}, {640, 400, 16}, {480, 40, 14}}) do
  W(ellipse(s[1], s[2], s[3] * 0.38, s[3] * 0.38), yel)
  local b = brush{kind="round", width=s[3] * 0.25, point=0.05}; b:reload(wht, 1); b:touch(s[1] - 1, s[2] - 1, {pressure=0.7})
end
-- hills: rolling directional strokes along their slope, darker below
local Hp = {
  pile{{"ultramarine blue",1},{"bone black",0.7},{"viridian",0.25},{"lead white",0.25}},
  pile{{"ultramarine blue",1},{"viridian",0.4},{"lead white",0.5},{"bone black",0.3}},
  pile{{"ultramarine blue",1},{"bone black",1.1},{"viridian",0.3}},
}
for y = 470, 750, 8 do for x = 4, 996, 14 do
  local px, py = x + rand(-6, 6), y + rand(-3, 3)
  if HILLS:at(px, py) > 0.5 then
    local t = (py - hillY(px)) / 200
    local a = math.atan(hillY(px + 5) - hillY(px - 5), 10) * (1 - t) + rand(-0.15, 0.15)
    local r = math.random()
    local p = (r < 0.25 + 0.5 * t) and Hp[3] or ((r < 0.75) and Hp[1] or Hp[2])
    local b = brush{kind="filbert", width=rand(7, 10)}; b:reload(p, 0.85)
    local L = rand(18, 30)
    b:stroke({{px - L/2 * math.cos(a), py - L/2 * math.sin(a)}, {px + L/2 * math.cos(a), py + L/2 * math.sin(a)}}, {pressure={0.8, 0.5}, ramps={0.1, 0.3}})
  end
end end
print(wait(2*1440))
-- the ring as the village: a low elliptical band of dark structure in the valley, its windows small warm squares
local ringC = {560, 640}
local band = (ellipse(560, 640, 300, 50) - ellipse(560, 640, 270, 34)) * below(function(x) return 620 end)
W(band, pile{{"ultramarine blue",1},{"bone black",1.2},{"burnt sienna",0.2}})
local blk = ellipse(560, 640, 300, 50) * below(function(x) return 620 end) - ellipse(560, 640, 270, 34)
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.4}}
for i = 1, 26 do
  local a = rand(0.15, math.pi - 0.15)
  local x, y = 560 + 285 * math.cos(a), 640 + 42 * math.sin(a)
  local b = brush{kind="flat", width=5}; b:reload(warm, 0.9); b:stroke({{x - 2.5, y}, {x + 2.5, y}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}})
end
-- the reliquary: a tiny chapel with a needle spire rising out of the ring
W(poly({{512, 612}, {540, 612}, {540, 640}, {512, 640}}), pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.2}})
local sp = brush{kind="round", width=5, point=0.9}
sp:reload(pile{{"ultramarine blue",1},{"bone black",1.2}}, 0.9); sp:stroke({{526, 614}, {526, 540}}, {pressure={0.9, 0.0}, ramps={0.02, 0.9}})
local wb = brush{kind="flat", width=5}; wb:reload(warm, 0.9); wb:stroke({{523, 626}, {529, 626}}, {pressure={0.85, 0.85}})

--@ chunk 5
-- the TESTAMENT's spine as the cypress: a dark flame-shaped tower of upward-curling strokes in the left foreground
local cx = 165
local function halfW(y) local t = (750 - y) / 690; return 70 * (1 - t)^0.9 * (0.75 + 0.25 * math.sin(t * 9)) + 4 end
local P = {
  pile{{"bone black",1.2},{"viridian",0.5},{"burnt sienna",0.3}},
  pile{{"bone black",0.9},{"viridian",0.6},{"ultramarine blue",0.3},{"lead white",0.15}},
  pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.4}},
  pile{{"viridian",0.8},{"ultramarine blue",0.4},{"lead white",0.5},{"bone black",0.3}},
}
local n = 0
for y = 750, 60, -7 do
  local hw = halfW(y)
  local lean = 18 * math.sin((750 - y) / 140)
  for k = -2, 2 do
    local x = cx + lean + k * hw / 2.6 + rand(-6, 6)
    local L = rand(30, 55)
    local side = (k < 0) and -1 or 1
    local pts = {{x, y + L * 0.4}, {x + side * rand(4, 10), y}, {x + side * rand(-2, 6) - side * 8, y - L * 0.6}}
    local r = math.random()
    local p = (math.abs(k) == 2 and r < 0.35) and P[4] or ((r < 0.45) and P[1] or ((r < 0.8) and P[2] or P[3]))
    local b = brush{kind="filbert", width=rand(7, 12)}; b:reload(p, 0.85)
    b:stroke(pts, {pressure={0.8, 0.15}, ramps={0.08, 0.6}})
    n = n + 1
  end
end
-- flame tongues licking off the edges near the top
for i = 1, 14 do
  local y = rand(80, 400); local hw = halfW(y); local lean = 18 * math.sin((750 - y) / 140)
  local side = (math.random() < 0.5) and -1 or 1
  local x = cx + lean + side * hw
  local b = brush{kind="filbert", width=rand(6, 9)}; b:reload(P[2], 0.8)
  b:stroke({{x - side * 6, y + 20}, {x + side * 6, y - 5}, {x + side * 2, y - 30}}, {pressure={0.75, 0.05}, ramps={0.05, 0.7}})
end
print(n)

--@ chunk 6
print(wait(2*1440))
local dk = pile{{"bone black",1.4},{"viridian",0.4},{"ultramarine blue",0.3}}
local dkG = pile{{"bone black",1},{"viridian",0.6},{"ultramarine blue",0.3},{"lead white",0.1}}
local cx = 165
local function halfW(y) local t = (750 - y) / 690; return 90 * (1 - t)^0.9 * (0.75 + 0.25 * math.sin(t * 9)) + 5 end
for y = 750, 70, -8 do
  local hw = halfW(y); local lean = 18 * math.sin((750 - y) / 140)
  for _, side in ipairs({-1, 1}) do
    for j = 0, 1 do
      local x = cx + lean + side * hw * (0.55 + 0.4 * j) + rand(-4, 4)
      local L = rand(30, 50)
      local b = brush{kind="filbert", width=rand(8, 12)}; b:reload((math.random() < 0.6) and dk or dkG, 0.85)
      b:stroke({{x - side * 4, y + L * 0.4}, {x + side * rand(3, 8), y}, {x - side * 4, y - L * 0.6}}, {pressure={0.8, 0.15}, ramps={0.08, 0.6}})
    end
  end
end
-- the Sun: circling strokes over the flat disc
local sY = {pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lemon chrome",0.3}}, pile{{"lemon chrome",1},{"lead white",0.7}}, pile{{"cadmium yellow",1},{"lead white",0.4}}}
for r = 6, 40, 7 do
  local nseg = math.floor(5 + r / 5)
  for s = 0, nseg - 1 do
    local a0 = s * 2 * math.pi / nseg + rand(-0.15, 0.15); local a1 = a0 + 2 * math.pi / nseg * 0.8
    local pts = {} for i = 0, 4 do local a = lerp(a0, a1, i / 4); pts[#pts+1] = {880 + r * math.cos(a), 110 + r * math.sin(a)} end
    local b = brush{kind="filbert", width=7}; b:reload(sY[math.random(1, 3)], 0.9); b:stroke(pts, {pressure={0.8, 0.5}, ramps={0.1, 0.3}})
  end
end
-- village: small dark roofs above the ring, and bigger warm windows
local roof = pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.15}}
local warm = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.5}}
for i = 1, 14 do
  local a = rand(0.4, math.pi - 0.4)
  local x, y = 560 + 270 * math.cos(a), 640 + 30 * math.sin(a) - 14
  work(poly({{x - 12, y + 12}, {x - 12, y}, {x, y - 9}, {x + 12, y}, {x + 12, y + 12}}), {hand="detail", tool="round 2", pile=roof, coverage=5, fill=true, load=1})
  local b = brush{kind="flat", width=6}; b:reload(warm, 0.9); b:stroke({{x - 3, y + 5}, {x + 3, y + 5}}, {pressure={0.9, 0.9}})
end
for i = 1, 30 do
  local a = rand(0.1, math.pi - 0.1)
  local x, y = 560 + 285 * math.cos(a), 640 + 42 * math.sin(a)
  local b = brush{kind="flat", width=7}; b:reload(warm, 0.95); b:stroke({{x - 3, y}, {x + 3, y}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}})
end
