-- easel session "eclipse": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=2002,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1.2},{"ultramarine blue",0.9},{"lead white",0.25}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
SUN = {560, 220}
DISC = ellipse(SUN[1], SUN[2], 58, 58)
DECK = poly({{-10,470},{240,440},{520,452},{1010,500},{1010,572},{-10,572}})
SKY = everywhere() - DECK
work(SKY, {hand="broad", pile=pile{{"bone black",2.8},{"ultramarine blue",0.7}}, coverage=3, fill=true, angle=0.02, angle_jitter=0.2, clip=SKY})
work(DECK, {hand="broad", pile=pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.2}}, coverage=3, fill=true, angle=-0.05, clip=DECK:grow(2)})

--@ chunk 3
print(wait(3*24*60))
-- the corona's full crown: long pearly streamers in every direction, longest along a tilted axis, laid in segments; inner corona dense
local pW = pile{{"zinc white",2},{"lead white",2},{"cerulean blue",0.05}}
local pP = pile{{"lead white",2},{"zinc white",1},{"ultramarine ash",0.3},{"rose madder",0.05}}
local pD = pile{{"lead white",1},{"ultramarine ash",0.8},{"bone black",0.3}}
local thin = brush{kind="round", width=1.8, point=0.6}
local mid = brush("filbert", 5)
local wide = brush("filbert", 10)
local AX = -0.35
for i = 1, 240 do
  local a = rand(-math.pi, math.pi)
  local axis = math.abs(math.cos(a - AX))
  local len = (40 + 340 * rand(0, 1)^1.6) * (0.45 + 0.75 * axis^3)
  local r0 = rand(56, 64)
  local bend = rand(-0.08, 0.08)
  local function P(t) local r = r0 + len * t; local aa = a + bend * t * t; return {SUN[1] + math.cos(aa) * r, SUN[2] + math.sin(aa) * r} end
  local br = (len > 220) and wide or ((math.random() < 0.5) and mid or thin)
  for seg, cut in ipairs({{0, 0.4}, {0.38, 1.0}}) do
    if seg == 1 or len > 90 then
      br:reload((seg == 1) and pW or ((len > 200) and pD or pP), 0.5)
      br:stroke({P(cut[1]), P((cut[1] + cut[2]) / 2), P(cut[2])}, {pressure={0.55 - 0.2 * seg, 0.3 - 0.13 * seg}, ramps={0.1, 0.6}, orient="along", clip=SKY - DISC})
    end
  end
end
-- inner corona: dense short bright strokes hugging the disc
local t = brush{kind="round", width=2.2, point=0.5}
for i = 1, 260 do
  local a = rand(-math.pi, math.pi); local r0 = rand(57, 62); local len = rand(6, 34)
  t:reload(pW, 0.55)
  t:stroke({{SUN[1] + math.cos(a) * r0, SUN[2] + math.sin(a) * r0}, {SUN[1] + math.cos(a) * (r0 + len), SUN[2] + math.sin(a) * (r0 + len)}}, {pressure={0.6, 0.05}, ramps={0.05, 0.85}, orient="along", clip=SKY - DISC})
end

--@ chunk 4
-- prominences: a few small red-pink tongues and loops at the rim; the disc's edge kept crisp black; stars out in the sudden dark
local prom = pile{{"cadmium red",1},{"rose madder",0.6},{"lead white",0.4}}
local p = brush{kind="round", width=2.6, point=0.5}
for _, d in ipairs({{-2.3, 9, 0.3}, {-0.9, 6, -0.2}, {0.6, 11, 0.4}, {2.0, 7, 0.1}, {2.8, 5, -0.3}}) do
  local a, h, lean = d[1], d[2], d[3]
  local x0, y0 = SUN[1] + math.cos(a) * 58, SUN[2] + math.sin(a) * 58
  local x1, y1 = SUN[1] + math.cos(a + lean * 0.1) * (58 + h), SUN[2] + math.sin(a + lean * 0.1) * (58 + h)
  p:load(prom, 0.7)
  p:stroke({{x0, y0}, {(x0 + x1) / 2 + math.cos(a + 1.57) * 2, (y0 + y1) / 2 + math.sin(a + 1.57) * 2}, {x1, y1}}, {pressure={0.8, 0.2}, ramps={0.05, 0.6}, clip=-DISC})
end
local lp = brush{kind="round", width=1.4, point=0.7}
lp:load(prom, 0.6)
local pts = {}
for k = 0, 10 do local t = k / 10; local a = 0.6 + 0.18 * t; local r = 58 + 12 * math.sin(t * math.pi); pts[#pts+1] = {SUN[1] + math.cos(a) * r, SUN[2] + math.sin(a) * r} end
lp:stroke(pts, {pressure={0.6, 0.5}, clip=-DISC})
work(DISC:shrink(1), {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"bone black",4},{"ultramarine blue",0.2}}, coverage=4, fill=true, angle=0, clip=true})
local st = brush{kind="round", width=1.6, point=0.6}
local n = 0
for i = 1, 260 do
  local x, y = rand(0, 1000), rand(0, 460)
  local d = math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2)
  if SKY:shrink(2):at(x, y) > 0.5 and d > 200 then
    if n % 6 == 0 then st:load(pile{{"zinc white",4},{"cerulean blue",0.08}}, 0.55) end
    st:touch(x, y, {pressure=rand(0.12, 0.5)}); n = n + 1
  end
end
print(n)

--@ chunk 5
-- far below the sail, the TESTAMENT: a small dark spindle with its edge-on ring, tethers rising to the sail's rim; a thin pearly rim on its upper edges
local blk = pile{{"bone black",3.5},{"ultramarine blue",0.3}}
local b = brush{kind="round", width=2.6, point=0.4}
b:load(blk, 0.85); b:stroke({{518,352},{606,350}}, {pressure={0.9, 0.9}})
b:load(blk, 0.85); b:stroke({{561,334},{560,351},{561,368}}, {pressure={0.9, 0.9}})
b:load(blk, 0.85); b:stroke({{512,346},{518,352},{512,358}}, {pressure={0.8, 0.8}})
local t = brush{kind="round", width=0.9, point=0.9}
for _, s in ipairs({{{606,350},{520,270}}, {{606,350},{604,280}}, {{606,350},{614,278}}}) do
  t:load(blk, 0.6); t:stroke(s, {pressure={0.4, 0.3}, clip=-DISC})
end
local r = brush{kind="round", width=0.9, point=0.9}
r:load(pile{{"lead white",2},{"ultramarine ash",0.3}}, 0.55)
r:stroke({{520,350.5},{604,348.5}}, {pressure={0.4, 0.3}})
r:load(pile{{"lead white",2},{"ultramarine ash",0.3}}, 0.55)
r:stroke({{560,334},{560,348}}, {pressure={0.3, 0.2}})

--@ chunk 6
-- the outpost deck: darker, cool grey prefab panels in a strict grid, amber hazard stripes along its edge, a railing post
work(DECK, {hand="body", tool="filbert 8", pile=pile{{"bone black",2.2},{"ultramarine ash",0.8},{"lead white",0.15}}, coverage=3.4, fill=true, angle=-0.05, clip=DECK, load=0.95})

--@ chunk 7
print(wait(3*24*60))
local seam = pile{{"bone black",3},{"ultramarine blue",0.2}}
local lit = pile{{"lead white",1.5},{"ultramarine ash",0.8},{"bone black",0.3}}
local s = brush{kind="round", width=1.3, point=0.7}
local function edgeY(x) if x < 240 then return lerp(470, 440, (x + 10) / 250) elseif x < 520 then return lerp(440, 452, (x - 240) / 280) else return lerp(452, 500, (x - 520) / 490) end end
-- panel seams: lines converging toward a vanishing point far left-down, and cross seams parallel to the edge
for k = 1, 14 do
  local x0 = -60 + k * 80
  s:load(seam, 0.6); s:stroke({{x0, edgeY(clamp(x0, -10, 1010)) + 2}, {x0 - 120, 575}}, {pressure={0.5, 0.6}, clip=DECK})
end
for _, d in ipairs({22, 52, 92}) do
  local pts = {}
  for x = -10, 1010, 40 do pts[#pts+1] = {x, edgeY(x) + d} end
  s:load(seam, 0.6); s:stroke(pts, {pressure={0.5, 0.6}, clip=DECK})
end
-- the deck edge catching the corona's pearly light, then amber hazard stripes just inside it
local e = brush{kind="round", width=1.8, point=0.6}
local pts = {}
for x = -10, 1010, 20 do pts[#pts+1] = {x, edgeY(x) + 1} end
e:load(lit, 0.6); e:stroke(pts, {pressure={0.5, 0.4}})
local f = brush("flat", 5)
for x = 0, 1000, 22 do
  local y = edgeY(x) + 7
  f:load(pile{{"cadmium yellow",1},{"Mars orange",0.6},{"bone black",0.3}}, 0.7)
  f:stroke({{x, y}, {x + 9, y + 0.5}}, {pressure={0.7, 0.7}, orient=0.9})
end

--@ chunk 8
print(wait(2*24*60))
-- the TESTAMENT larger and plain against the lower streamers; prominences larger
local blk = pile{{"bone black",4},{"ultramarine blue",0.2}}
TT = poly({{486,384},{494,379},{620,377},{630,381},{630,387},{620,391},{494,393},{486,390}}, true)
  + ellipse(560, 385, 7, 30) - ellipse(560, 385, 3.5, 25) + ellipse(560, 385, 5, 5)
  + poly({{486,384},{470,374},{464,376},{468,385},{464,394},{470,396},{486,390}}, true)
work(TT, {hand="detail", tool={kind="round", width=1.8, point=0.4}, pile=blk, coverage=4, fill=true, angle=0, clip=true, load=1.0})
local t = brush{kind="round", width=1.2, point=0.9}
for _, s in ipairs({{{630,384},{604,272}}, {{630,384},{560,282}}, {{630,384},{516,272}}}) do
  t:load(blk, 0.8); t:stroke(s, {pressure={0.5, 0.4}, clip=-DISC})
end
local r = brush{kind="round", width=1.0, point=0.9}
r:load(pile{{"zinc white",2},{"lead white",1}}, 0.6); r:stroke({{494,378.5},{620,376.5}}, {pressure={0.45, 0.35}})
r:load(pile{{"zinc white",2},{"lead white",1}}, 0.6); r:stroke({{557,356},{557,372}}, {pressure={0.35, 0.25}})
local prom = pile{{"cadmium red",1},{"rose madder",0.5},{"lead white",0.5}}
local p = brush{kind="round", width=4, point=0.4}
for _, d in ipairs({{-2.3, 16, 0.3}, {-0.9, 11, -0.2}, {0.55, 18, 0.4}, {2.0, 12, 0.1}, {2.8, 9, -0.3}}) do
  local a, h, lean = d[1], d[2], d[3]
  local x0, y0 = SUN[1] + math.cos(a) * 57, SUN[2] + math.sin(a) * 57
  local x1, y1 = SUN[1] + math.cos(a + lean * 0.15) * (57 + h), SUN[2] + math.sin(a + lean * 0.15) * (57 + h)
  p:load(prom, 0.8)
  p:stroke({{x0, y0}, {(x0 + x1) / 2 + math.cos(a + 1.57) * 3, (y0 + y1) / 2 + math.sin(a + 1.57) * 3}, {x1, y1}}, {pressure={0.85, 0.25}, ramps={0.05, 0.6}, clip=-DISC})
end

--@ chunk 9
-- two small crew children in suits on the deck, holding hands, looking up: dark suits with pale helmets catching the corona's light
local function edgeY(x) if x < 240 then return lerp(470, 440, (x + 10) / 250) elseif x < 520 then return lerp(440, 452, (x - 240) / 280) else return lerp(452, 500, (x - 520) / 490) end end
local suit = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.25}}
CH = nil
local function add(m) CH = CH and (CH + m) or m end
local function kid(x, s, tilt)
  local y = edgeY(x) + 40
  add(ribbon({{x - 3 * s, y}, {x - 2.6 * s, y - 13 * s}}, 4 * s) + ribbon({{x + 3 * s, y}, {x + 2.6 * s, y - 13 * s}}, 4 * s))
  add(poly({{x - 6 * s, y - 12 * s}, {x + 6 * s, y - 12 * s}, {x + 6.5 * s, y - 27 * s}, {x - 6.5 * s, y - 27 * s}}, true))
  add(poly({{x - 6 * s, y - 33 * s}, {x - 4 * s, y - 31 * s}, {x - 1 * s, y - 31 * s}, {x - 1 * s, y - 28 * s}, {x - 7 * s, y - 27 * s}}, true))   -- pack
  add(ellipse(x + tilt * s, y - 33 * s, 6.5 * s, 6 * s))
  return {x = x, y = y, s = s, tilt = tilt}
end
K1 = kid(210, 1.25, 1.2); K2 = kid(242, 1.1, 0.6)
add(ribbon({{K1.x + 6 * K1.s, K1.y - 22 * K1.s}, {226, K1.y - 18}, {K2.x - 6 * K2.s, K2.y - 20 * K2.s}}, {3, 2.6, 3}))   -- holding hands
work(CH, {hand="detail", tool={kind="round", width=1.4, point=0.5}, pile=suit, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})

--@ chunk 10
print(wait(3*24*60))
-- helmets pale, visors turned up catching the corona; pearly rim on shoulders and tops; amber stripe on suits; shadows on the deck
local hel = pile{{"lead white",2},{"ultramarine ash",0.4},{"bone black",0.1}}
local vis = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.15}}
for _, k in ipairs({K1, K2}) do
  local hx, hy, s = k.x + k.tilt * k.s, k.y - 33 * k.s, k.s
  local h = brush{kind="round", width=4 * s, point=0.2}
  h:load(hel, 0.7); h:stroke({{hx - 4 * s, hy - 2 * s}, {hx, hy - 4.5 * s}, {hx + 4 * s, hy - 2.5 * s}}, {pressure={0.6, 0.5}})
  local v = brush{kind="round", width=2.4 * s, point=0.3}
  v:load(vis, 0.7); v:stroke({{hx + 1 * s, hy - 3 * s}, {hx + 4.5 * s, hy - 1 * s}}, {pressure={0.7, 0.5}})
  local r = brush{kind="round", width=1.1, point=0.8}
  r:load(pile{{"lead white",2},{"ultramarine ash",0.3}}, 0.55)
  r:stroke({{k.x - 6.2 * s, k.y - 26 * s}, {k.x, k.y - 27.5 * s}, {k.x + 6.2 * s, k.y - 26 * s}}, {pressure={0.45, 0.3}})
  local a = brush("flat", 2)
  a:load(pile{{"cadmium yellow",1},{"Mars orange",0.6}}, 0.6); a:stroke({{k.x - 6 * s, k.y - 18 * s}, {k.x + 6 * s, k.y - 18 * s}}, {pressure={0.6, 0.6}})
  local sh = brush("filbert", 4)
  sh:load(pile{{"bone black",3}}, 0.6); sh:stroke({{k.x, k.y + 1}, {k.x - 20, k.y + 12}}, {pressure={0.6, 0.05}, ramps={0.05, 0.8}, clip=DECK})
end

--@ chunk 11
print(wait(3*24*60))
-- the children read too small and grey on grey: paint them out, to be drawn larger with heads against the sky
local deckP = pile{{"bone black",2.2},{"ultramarine ash",0.8},{"lead white",0.15}}
work(CH:grow(3) * DECK, {hand="detail", tool={kind="round", width=2, point=0.3}, pile=deckP, coverage=4, fill=true, angle=-0.05, clip=true, load=1.0})
work(CH:grow(3) * SKY, {hand="detail", tool={kind="round", width=2, point=0.3}, pile=pile{{"bone black",2.8},{"ultramarine blue",0.7}}, coverage=4, fill=true, angle=0, clip=true, load=1.0})
-- the TESTAMENT's ring drawn plainly: a tall thin edge-on ellipse with a pearly upper rim
local blk = pile{{"bone black",4},{"ultramarine blue",0.2}}
local rg = brush{kind="round", width=2.4, point=0.4}
local pts = {}
for k = 0, 40 do local a = k * 2 * math.pi / 40; pts[#pts+1] = {560 + math.cos(a) * 7, 385 + math.sin(a) * 34} end
rg:load(blk, 0.9); rg:stroke(pts, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
local r = brush{kind="round", width=1.0, point=0.9}
local q = {}
for k = 0, 10 do local a = -math.pi + k * math.pi / 10; q[#q+1] = {560 + math.cos(a) * 8, 385 + math.sin(a) * 35} end
r:load(pile{{"zinc white",2},{"lead white",1}}, 0.6); r:stroke(q, {pressure={0.4, 0.3}})

--@ chunk 12
print(wait(3*24*60))
local function edgeY(x) if x < 240 then return lerp(470, 440, (x + 10) / 250) elseif x < 520 then return lerp(440, 452, (x - 240) / 280) else return lerp(452, 500, (x - 520) / 490) end end
local suit = pile{{"bone black",3},{"ultramarine blue",0.3}}
CH2 = nil
local function add(m) CH2 = CH2 and (CH2 + m) or m end
local function kid(x, s, tilt)
  local y = edgeY(x) + 66
  add(ribbon({{x - 3 * s, y}, {x - 2.6 * s, y - 13 * s}}, 4 * s) + ribbon({{x + 3 * s, y}, {x + 2.6 * s, y - 13 * s}}, 4 * s))
  add(poly({{x - 6 * s, y - 12 * s}, {x + 6 * s, y - 12 * s}, {x + 6.5 * s, y - 27 * s}, {x - 6.5 * s, y - 27 * s}}, true))
  add(poly({{x - 8 * s, y - 27 * s}, {x - 6 * s, y - 14 * s}, {x - 9 * s, y - 15 * s}}, true))
  add(ellipse(x + tilt * s, y - 33 * s, 6.5 * s, 6 * s))
  return {x = x, y = y, s = s, tilt = tilt}
end
K1 = kid(196, 2.3, 1.2); K2 = kid(248, 2.0, 0.6)
add(ribbon({{K1.x + 6 * K1.s, K1.y - 22 * K1.s}, {222, K1.y - 42}, {K2.x - 6 * K2.s, K2.y - 20 * K2.s}}, {5, 4.5, 5}))
work(CH2, {hand="detail", tool={kind="round", width=2, point=0.5}, pile=suit, coverage=4, fill=true, angle=math.pi/2, clip=true, load=1.0})

--@ chunk 13
print(wait(3*24*60))
local hel = pile{{"lead white",2},{"ultramarine ash",0.5},{"bone black",0.15}}
local vis = pile{{"zinc white",2.5},{"lead white",1},{"cerulean blue",0.15}}
for _, k in ipairs({K1, K2}) do
  local hx, hy, s = k.x + k.tilt * k.s, k.y - 33 * k.s, k.s
  local h = brush{kind="round", width=2.6 * s, point=0.2}
  h:load(hel, 0.7); h:stroke({{hx - 5 * s, hy - 1 * s}, {hx - 1 * s, hy - 5 * s}, {hx + 4 * s, hy - 4 * s}}, {pressure={0.55, 0.4}})
  local v = brush{kind="round", width=2.2 * s, point=0.3}
  v:load(vis, 0.75); v:stroke({{hx + 1.5 * s, hy - 3.5 * s}, {hx + 5 * s, hy - 0.5 * s}}, {pressure={0.7, 0.5}})
  local r = brush{kind="round", width=1.4, point=0.8}
  r:load(pile{{"lead white",2},{"ultramarine ash",0.3}}, 0.6)
  r:stroke({{k.x - 6.4 * s, k.y - 26 * s}, {k.x, k.y - 27.6 * s}, {k.x + 6.4 * s, k.y - 26 * s}}, {pressure={0.5, 0.35}})
  r:load(pile{{"lead white",2},{"ultramarine ash",0.3}}, 0.5)
  r:stroke({{k.x + 6.4 * s, k.y - 26 * s}, {k.x + 6 * s, k.y - 14 * s}}, {pressure={0.35, 0.1}})
  local a = brush("flat", 3)
  a:load(pile{{"cadmium yellow",1},{"Mars orange",0.6}}, 0.65); a:stroke({{k.x - 6 * s, k.y - 19 * s}, {k.x + 6 * s, k.y - 19 * s}}, {pressure={0.65, 0.65}})
  local sh = brush("filbert", 6)
  sh:load(pile{{"bone black",3}}, 0.7); sh:stroke({{k.x, k.y + 1}, {k.x - 34, k.y + 22}}, {pressure={0.6, 0.05}, ramps={0.05, 0.8}, clip=DECK - CH2})
end
