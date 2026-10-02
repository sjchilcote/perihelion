-- easel session "aftermath": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=1730,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.8},{"lead white",0.2}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
-- the same coordinates as Perihelion
SAIL = ellipse(700, 272, 62, 236)
SKY = everywhere() - SAIL
local function dc(x, y) return math.sqrt(((x + 120) / 1.0)^2 + ((y - 420) / 0.8)^2) end
local black = pile{{"bone black",3},{"ultramarine blue",0.6}}
local glowD = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars orange",0.3}}
local glowM = pile{{"burnt sienna",1},{"Mars orange",0.8},{"bone black",0.5}}
work(SKY, {hand="broad", pile=black, coverage=3, fill=true, angle=0.05, angle_jitter=0.2})
local g1 = SKY * mask(function(x, y) return dc(x, y) < 520 and 1 or 0 end)
work(g1, {hand="broad", pile=glowD, coverage=2.4, fill=true, angle=function(x, y) return math.atan(y - 420, x + 120) + math.pi/2 end, clip=SKY})
local g2 = SKY * mask(function(x, y) return dc(x, y) < 330 and 1 or 0 end)
work(g2, {hand="broad", pile=glowM, coverage=2.2, fill=true, angle=function(x, y) return math.atan(y - 420, x + 120) + math.pi/2 end, clip=SKY})
blend(SKY * mask(function(x, y) return dc(x, y) < 600 and 1 or 0 end), {angle=function(x, y) return math.atan(y - 420, x + 120) + math.pi/2 end})
local sailP = pile{{"bone black",2.5},{"burnt sienna",0.6},{"ultramarine blue",0.3}}
work(SAIL, {hand="body", pile=sailP, coverage=3, fill=true, angle=math.pi/2, clip=SAIL})

--@ chunk 3
print(wait(3*24*60))
-- the glow read as a planet: cover it back to black, leaving only a low warm haze at the far left edge
local black = pile{{"bone black",3},{"ultramarine blue",0.5}}
local cover = SKY * rect(-10, -10, 520, 600) - rect(-10, -10, 70, 600)
work(cover, {hand="body", tool="filbert 8", pile=black, coverage=3.6, fill=true, angle=0.05, clip=SKY, length={60, 180}, load=0.95})
local sailP = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
work(SAIL, {hand="body", tool="filbert 6", pile=sailP, coverage=3.6, fill=true, angle=math.pi/2, clip=SAIL, load=0.95})

--@ chunk 4
print(wait(3*24*60))
-- the corona behind them now: a dull ember haze at the left edge, and a few quiet, sparse long streamers trailing off it
local edge = rect(-10, -10, 90, 600)
work(edge, {hand="body", tool="filbert 8", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"Mars orange",0.4}}, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
blend(rect(-10, -10, 180, 600), {angle=0})
local s = brush("filbert", 4)
local t = brush{kind="round", width=1.6, point=0.6}
local warm = pile{{"burnt sienna",1},{"Mars orange",0.7},{"lead white",0.25}}
local dim = pile{{"burnt sienna",1},{"bone black",0.8},{"Mars orange",0.3}}
for i = 1, 26 do
  local y0 = rand(-20, 580)
  local len = rand(120, 420)
  local x0 = rand(-40, 30)
  local pts = {}
  for k = 0, 6 do local x = x0 + len * k / 6; pts[#pts+1] = {x, y0 + (y0 - 300) * 0.08 * k / 6 + 3 * math.sin(k + i)} end
  local br = (math.random() < 0.4) and s or t
  br:reload((math.random() < 0.4) and warm or dim, 0.5)
  br:stroke(pts, {pressure={0.45, 0.02}, ramps={0.05, 0.85}, orient="along", clip=SKY})
end

--@ chunk 5
print(wait(4*24*60))
-- the slab back to black; then the corona's remnant only as sparse quiet streamers drifting in from the left edge
local black = pile{{"bone black",3},{"ultramarine blue",0.5}}
local slab = rect(-10, -10, 160, 600)
work(slab, {hand="body", tool="filbert 8", pile=black, coverage=3.8, fill=true, angle=0.05, clip=slab:soften(10), length={60, 180}, load=0.95})

--@ chunk 6
print(wait(4*24*60))
local warm = pile{{"burnt sienna",1},{"Mars orange",0.8},{"lead white",0.4}}
local ember = pile{{"Mars orange",1},{"cadmium red",0.4},{"lead white",0.5}}
local dim = pile{{"burnt sienna",1},{"bone black",0.6},{"Mars orange",0.4}}
local b = {brush("filbert", 5), brush{kind="round", width=2.2, point=0.5}, brush{kind="round", width=1.4, point=0.7}}
for i = 1, 34 do
  local y0 = rand(-20, 580)
  local len = rand(140, 520) * (1 - 0.4 * math.abs(y0 - 300) / 300)
  local pts = {}
  for k = 0, 6 do local x = -20 + len * k / 6; pts[#pts+1] = {x, y0 + (y0 - 300) * 0.1 * k / 6 + 2.5 * math.sin(k * 0.7 + i)} end
  local r = math.random()
  local br = b[(r < 0.25) and 1 or ((r < 0.6) and 2 or 3)]
  br:reload((r < 0.2) and ember or ((r < 0.6) and warm or dim), 0.6)
  br:stroke(pts, {pressure={0.55, 0.02}, ramps={0.03, 0.9}, orient="along", clip=SKY})
end

--@ chunk 7
-- knock out the stripe left by the cover's edge
local black = pile{{"bone black",3},{"ultramarine blue",0.5}}
local st = rect(140, -10, 44, 600)
work(st, {hand="body", tool="filbert 6", pile=black, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 8
print(wait(4*24*60))
-- the sail, torn: great rents with the black and the stars behind; scorch-brown blooms round them; the rim glowing dull red, broken
local RENTS = {
  poly({{690,90},{716,104},{728,140},{712,170},{700,150},{684,128}}, true),
  poly({{668,250},{700,236},{740,246},{746,268},{722,300},{704,286},{680,288}}, true),
  poly({{700,380},{726,370},{742,398},{724,430},{710,420}}, true),
  poly({{652,192},{664,186},{668,204},{656,212}}, true),
}
RENT = RENTS[1]; for i = 2, #RENTS do RENT = RENT + RENTS[i] end
RENT = RENT:roughen(3, 12, 33) * SAIL:shrink(2)
local scorch = pile{{"burnt sienna",1},{"bone black",1},{"Mars orange",0.2}}
work(RENT:grow(8) - RENT, {hand="detail", pile=scorch, coverage=2.2, fill=true, angle=math.pi/2, clip=SAIL})
work(RENT, {hand="detail", pile=pile{{"bone black",3},{"ultramarine blue",0.6}}, coverage=3.4, fill=true, angle=0, clip=true})
-- torn edges glowing at the lip of each rent
local e = brush{kind="round", width=1.4, point=0.7}
local ember = pile{{"cadmium red",1},{"Mars orange",0.6},{"bone black",0.2}}
local edge = (RENT:grow(1.5) - RENT) * SAIL
work(edge * mask(function(x, y) return (math.sin(x * 0.7 + y * 0.3) > -0.2) and 1 or 0 end), {hand="detail", tool={kind="round", width=1.2, point=0.8}, pile=ember, coverage=1.6, fill=true, clip=true})
-- the rim: dull red, cooling, broken
local pts = {}
local a = -math.pi / 2 - 0.2
while a < 3 * math.pi / 2 do
  local run = rand(0.15, 0.5)
  if math.random() < 0.6 then
    local q = {}
    for k = 0, 4 do local aa = a + run * k / 4; q[#q+1] = {700 + math.cos(aa) * 61, 272 + math.sin(aa) * 235} end
    e:load((math.cos(a) > 0.3) and pile{{"cadmium red",1},{"Mars orange",0.5},{"lead white",0.2}} or ember, 0.65)
    e:stroke(q, {pressure={0.5, 0.3}, ramps={0.15, 0.3}})
  end
  a = a + run + rand(0.05, 0.3)
end

--@ chunk 9
print(wait(3*24*60))
-- the scorch rings read as donuts: break them back into the film with dark torn strokes; tattered flaps curl into each rent
local sailP = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
local ring = (RENT:grow(10) - RENT:grow(1)) * SAIL
local b = brush("filbert", 4)
for i = 1, 260 do
  local x, y = rand(640, 760), rand(80, 440)
  if ring:at(x, y) > 0.5 and math.random() < 0.75 then
    b:reload(sailP, 0.8)
    local a = rand(0, 3.14)
    b:stroke({{x - math.cos(a) * 4, y - math.sin(a) * 4}, {x + math.cos(a) * 4, y + math.sin(a) * 4}}, {pressure={0.8, 0.6}, clip=ring})
  end
end
-- flaps: tapering shreds of film hanging into the rents, a dull red lip on each
local f = brush{kind="round", width=5, point=0.6}
local lip = brush{kind="round", width=1.0, point=0.9}
local flaps = {{{702,104},{708,122},{704,142}}, {{690,240},{702,258},{698,276}}, {{740,252},{728,264},{724,282}}, {{722,372},{716,392},{720,410}}, {{686,286},{694,276}}}
for _, fl in ipairs(flaps) do
  f:load(sailP, 0.9); f:stroke(fl, {pressure={0.9, 0.05}, ramps={0.05, 0.8}})
  lip:load(pile{{"cadmium red",1},{"Mars orange",0.5}}, 0.5)
  lip:stroke({{fl[1][1] + 1.5, fl[1][2]}, {fl[2][1] + 1.5, fl[2][2]}}, {pressure={0.4, 0.1}})
end
-- stars, through the rents and over the sky
local st = brush{kind="round", width=1.4, point=0.6}
local n = 0
for i = 1, 140 do
  local x, y = rand(0, 1000), rand(0, 562)
  local inRent = RENT:shrink(2):at(x, y) > 0.5
  if inRent or (SKY:at(x, y) > 0.5 and SAIL:grow(4):at(x, y) < 0.5 and math.random() < 0.45) then
    if n % 6 == 0 then st:load(pile{{"zinc white",3},{"cerulean blue",0.1}}, 0.5) end
    st:touch(x, y, {pressure=rand(0.12, 0.45)}); n = n + 1
  end
end
for i = 1, 30 do
  local x, y = rand(645, 750), rand(85, 440)
  if RENT:shrink(2):at(x, y) > 0.5 then st:load(pile{{"zinc white",3},{"cerulean blue",0.1}}, 0.5); st:touch(x, y, {pressure=rand(0.2, 0.5)}); n = n + 1 end
end
print(n)

--@ chunk 10
print(wait(4*24*60))
local sailP = pile{{"bone black",3},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
local ring = ((RENT:grow(12) - RENT:grow(3)) * SAIL):roughen(2, 8, 41)
work(ring, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=sailP, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 11
print(wait(4*24*60))
-- shreds of film hanging across the rents
local sailP = pile{{"bone black",2.5},{"burnt sienna",0.6},{"ultramarine blue",0.3}}
local f = brush("filbert", 9)
local lip = brush{kind="round", width=1.2, point=0.9}
local flaps = { {{694,98},{706,118},{708,140},{702,158}}, {{676,252},{690,262},{696,280}}, {{738,250},{728,266},{722,288}},
                {{720,370},{714,388},{718,412}}, {{712,240},{716,256}} }
for _, fl in ipairs(flaps) do
  f:load(sailP, 0.95); f:stroke(fl, {pressure={0.95, 0.05}, ramps={0.02, 0.85}, orient="across"})
  local q = {}
  for _, p in ipairs(fl) do q[#q+1] = {p[1] + 3.5, p[2]} end
  lip:load(pile{{"cadmium red",1},{"Mars orange",0.6}}, 0.55); lip:stroke(q, {pressure={0.45, 0.05}, ramps={0.05, 0.7}})
end

--@ chunk 12
print(wait(2*24*60))
-- the TESTAMENT, in the same place, intact: dark bronze against the black
local bz = pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.3}}
SPINE = poly({{566,276},{560,273},{470,271},{420,270},{380,271},{300,273},{230,274},{205,272},{205,290},{230,288},{300,289},{380,291},{420,292},{470,291},{560,289},{566,286}})
RING = ellipse(408, 281, 26, 132) - ellipse(409, 281, 15, 118)
HUB = ellipse(408, 281, 20, 22)
MAW = poly({{212,272},{196,266},{178,258},{160,250},{150,252},{154,264},{158,281},{154,298},{150,310},{160,312},{178,304},{196,296},{212,290}}, true)
TT = SPINE + RING + HUB + MAW
work(TT, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=bz, coverage=3.8, fill=true, angle=0, clip=true, load=0.95})
local t = brush{kind="round", width=1.3, point=0.8}
TETH = {{{566,276},{662,82}}, {{566,277},{650,130}}, {{566,285},{650,414}}, {{566,286},{662,462}}}
for _, s in ipairs(TETH) do t:load(bz, 0.85); t:stroke(s, {pressure={0.55, 0.45}, ramps={0.02, 0.02}, clip=-SAIL}) end

--@ chunk 13
print(wait(4*24*60))
-- light from the Sun now behind them (left): a thin warm rim on the left-facing edges; the forward edges' red faded to a few dark-red dashes
local rimW = pile{{"Mars orange",1},{"yellow ochre",0.8},{"lead white",0.8}}
local dred = pile{{"cadmium red",0.6},{"burnt sienna",1},{"bone black",0.6}}
local r = brush{kind="round", width=1.3, point=0.8}
local function ringpt(a, rx, ry) return {408 + math.cos(a) * rx, 281 + math.sin(a) * ry} end
-- ring's left (sunward) outer arc, broken
local a = math.pi / 2 + 0.1
while a < 3 * math.pi / 2 - 0.1 do
  local run = rand(0.12, 0.35)
  if math.random() < 0.7 then
    local q = {}
    for k = 0, 4 do q[#q+1] = ringpt(a + run * k / 4, 25.5, 131) end
    r:load(rimW, 0.6); r:stroke(q, {pressure={0.4, 0.3}, ramps={0.15, 0.3}})
  end
  a = a + run + rand(0.04, 0.15)
end
-- maw flare lips (they face the Sun now), spine top-left edges, hub
for _, seg in ipairs({ {{212,272},{196,266},{178,258},{160,250},{150,252}}, {{150,252},{154,264},{158,281}}, {{230,274},{300,273},{380,271}}, {{390,262},{396,262}} }) do
  r:load(rimW, 0.6); r:stroke(seg, {pressure={0.45, 0.25}, ramps={0.1, 0.3}})
end
-- the forward edges: cooling, a few dull dashes only
local e = brush{kind="round", width=1.6, point=0.6}
for _, seg in ipairs({ {{430,190},{433,215}}, {{431,350},{433,372}}, {{560,273},{566,276}}, {{424,268},{427,278}} }) do
  e:load(dred, 0.6); e:stroke(seg, {pressure={0.4, 0.2}})
end
-- tethers catching the low light along their upper edge
for _, s in ipairs(TETH) do
  r:load(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5)
  r:stroke({{s[1][1], s[1][2] - 0.9}, {s[2][1], s[2][2] - 0.9}}, {pressure={0.3, 0.05}, ramps={0.05, 0.6}, clip=-SAIL})
end
-- the ring's windows, lit warm again
local w = brush{kind="round", width=1.3, point=0.6}
local n = 0
for i = 1, 34 do
  local aa = rand(-1.45, 1.45) + ((i % 2 == 0) and math.pi or 0)
  local x, y = 408 + math.cos(aa) * 20, 281 + math.sin(aa) * 125
  if math.abs(y - 281) > 26 then
    if n % 5 == 0 then w:load(pile{{"lead white",1.5},{"Indian yellow",0.7},{"Mars orange",0.3}}, 0.6) end
    w:touch(x, y, {pressure=rand(0.3, 0.55)}); n = n + 1
  end
end
print(n)

--@ chunk 14
print(wait(3*24*60))
-- the station far too light and flat: repaint it dark, modelled only by a slightly warmer upper (sunward-left) half
local dk = pile{{"bone black",2.6},{"burnt sienna",0.9},{"ultramarine blue",0.2}}
local dk2 = pile{{"bone black",2},{"burnt sienna",1.1},{"raw sienna",0.2}}
work(TT, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=dk, coverage=3.8, fill=true, angle=0, clip=true, load=0.95})
local upper = TT * mask(function(x, y) return (y < 279) and 1 or 0 end)
work(upper, {hand="detail", tool={kind="round", width=2, point=0.3}, pile=dk2, coverage=1.6, fill=true, angle=0, clip=true, load=0.7})
local t = brush{kind="round", width=1.3, point=0.8}
for _, s in ipairs(TETH) do t:load(dk, 0.85); t:stroke(s, {pressure={0.55, 0.45}, ramps={0.02, 0.02}, clip=-SAIL}) end

--@ chunk 15
print(wait(4*24*60))
-- light from the Sun now behind them (left): a thin warm rim on the left-facing edges; the forward edges' red faded to a few dark-red dashes
local rimW = pile{{"Mars orange",1},{"yellow ochre",0.8},{"lead white",0.8}}
local dred = pile{{"cadmium red",0.6},{"burnt sienna",1},{"bone black",0.6}}
local r = brush{kind="round", width=1.3, point=0.8}
local function ringpt(a, rx, ry) return {408 + math.cos(a) * rx, 281 + math.sin(a) * ry} end
-- ring's left (sunward) outer arc, broken
local a = math.pi / 2 + 0.1
while a < 3 * math.pi / 2 - 0.1 do
  local run = rand(0.12, 0.35)
  if math.random() < 0.7 then
    local q = {}
    for k = 0, 4 do q[#q+1] = ringpt(a + run * k / 4, 25.5, 131) end
    r:load(rimW, 0.6); r:stroke(q, {pressure={0.4, 0.3}, ramps={0.15, 0.3}})
  end
  a = a + run + rand(0.04, 0.15)
end
-- maw flare lips (they face the Sun now), spine top-left edges, hub
for _, seg in ipairs({ {{212,272},{196,266},{178,258},{160,250},{150,252}}, {{150,252},{154,264},{158,281}}, {{230,274},{300,273},{380,271}}, {{390,262},{396,262}} }) do
  r:load(rimW, 0.6); r:stroke(seg, {pressure={0.45, 0.25}, ramps={0.1, 0.3}})
end
-- the forward edges: cooling, a few dull dashes only
local e = brush{kind="round", width=1.6, point=0.6}
for _, seg in ipairs({ {{430,190},{433,215}}, {{431,350},{433,372}}, {{560,273},{566,276}}, {{424,268},{427,278}} }) do
  e:load(dred, 0.6); e:stroke(seg, {pressure={0.4, 0.2}})
end
-- tethers catching the low light along their upper edge
for _, s in ipairs(TETH) do
  r:load(pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.5)
  r:stroke({{s[1][1], s[1][2] - 0.9}, {s[2][1], s[2][2] - 0.9}}, {pressure={0.3, 0.05}, ramps={0.05, 0.6}, clip=-SAIL})
end
-- the ring's windows, lit warm again
local w = brush{kind="round", width=1.3, point=0.6}
local n = 0
for i = 1, 34 do
  local aa = rand(-1.45, 1.45) + ((i % 2 == 0) and math.pi or 0)
  local x, y = 408 + math.cos(aa) * 20, 281 + math.sin(aa) * 125
  if math.abs(y - 281) > 26 then
    if n % 5 == 0 then w:load(pile{{"lead white",1.5},{"Indian yellow",0.7},{"Mars orange",0.3}}, 0.6) end
    w:touch(x, y, {pressure=rand(0.3, 0.55)}); n = n + 1
  end
end
print(n)

--@ chunk 16
-- quiet, sparse long strokes carrying the last of the corona further across the dark; and the debris drifting away, glinting
local warm = pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.3}}
local dim = pile{{"burnt sienna",1},{"bone black",0.8},{"Mars orange",0.3}}
local t = brush{kind="round", width=1.2, point=0.7}
for i = 1, 22 do
  local y0 = rand(0, 562); local x0 = rand(40, 120); local len = rand(160, 420)
  local pts = {}
  for k = 0, 6 do pts[#pts+1] = {x0 + len * k / 6, y0 + (y0 - 300) * 0.06 * k / 6} end
  for seg = 1, 2 do
    t:reload((math.random() < 0.4) and warm or dim, 0.6)
    local a, b = (seg - 1) * 3 + 1, math.min(7, seg * 3 + 1)
    local q = {}; for k = a, b do q[#q+1] = pts[k] end
    t:stroke(q, {pressure={0.35 - 0.12 * seg, 0.2 - 0.1 * seg}, ramps={0.2, 0.5}, orient="along", clip=SKY - TT:grow(2)})
  end
end
-- shed plates tumbling away behind and around: dark chips, each with one glint on its sunward (left) edge
local chip = brush("flat", 4)
local g = brush{kind="round", width=1.3, point=0.7}
local glint = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.3}}
local n = 0
for i = 1, 55 do
  local x = rand(130, 640); local y = 281 + randn(0, 110)
  if SKY:at(x, y) > 0.5 and TT:grow(5):at(x, y) < 0.5 then
    local s = rand(2, 6)
    chip:reload(pile{{"bone black",2},{"burnt sienna",1}}, 0.85)
    local a = rand(0, 3.14)
    chip:stroke({{x - math.cos(a) * s, y - math.sin(a) * s}, {x + math.cos(a) * s, y + math.sin(a) * s}}, {pressure={0.8, 0.7}, orient=a + 1.57})
    if math.random() < 0.6 then
      g:load(glint, 0.5); g:touch(x - math.abs(math.cos(a)) * s, y - 0.5, {pressure=rand(0.25, 0.5)})
    end
    n = n + 1
  end
end
-- a few tiny embers still cooling, dull red
local em = brush{kind="round", width=1.1, point=0.8}
for i = 1, 25 do
  local x, y = rand(150, 650), 281 + randn(0, 130)
  if SKY:at(x, y) > 0.5 then em:load(pile{{"cadmium red",1},{"burnt sienna",0.6}}, 0.5); em:touch(x, y, {pressure=rand(0.2, 0.4)}) end
end
print(n)

--@ chunk 17
print(wait(4*24*60))
-- the station as near-black (it read brown and lighter than the sky)
local bk = pile{{"bone black",4},{"ultramarine blue",0.15}}
work(TT:shrink(0.6), {hand="detail", tool={kind="round", width=2.6, point=0.3}, pile=bk, coverage=4, fill=true, angle=0, clip=true, load=1.0})
local t = brush{kind="round", width=1.3, point=0.8}
for _, s in ipairs(TETH) do t:load(bk, 0.9); t:stroke(s, {pressure={0.55, 0.45}, ramps={0.02, 0.02}, clip=-SAIL}) end

--@ chunk 18
print(wait(4*24*60))
-- restate the sunward rims (thin, warm), larger lit windows, and glints on the drifting plates
local rimW = pile{{"Mars orange",1},{"yellow ochre",0.8},{"lead white",1}}
local r = brush{kind="round", width=1.4, point=0.8}
local function ringpt(a, rx, ry) return {408 + math.cos(a) * rx, 281 + math.sin(a) * ry} end
local a = math.pi / 2 + 0.1
while a < 3 * math.pi / 2 - 0.1 do
  local run = rand(0.12, 0.35)
  if math.random() < 0.7 then
    local q = {}
    for k = 0, 4 do q[#q+1] = ringpt(a + run * k / 4, 25.5, 131) end
    r:load(rimW, 0.6); r:stroke(q, {pressure={0.45, 0.3}, ramps={0.15, 0.3}})
  end
  a = a + run + rand(0.04, 0.15)
end
for _, seg in ipairs({ {{212,272},{196,266},{178,258},{160,250},{150,252}}, {{150,252},{154,264},{158,281}}, {{230,274},{300,273},{380,271}}, {{470,271},{540,272.5}} }) do
  r:load(rimW, 0.6); r:stroke(seg, {pressure={0.5, 0.25}, ramps={0.1, 0.3}})
end
local w = brush{kind="round", width=2.0, point=0.5}
local n = 0
for i = 1, 30 do
  local aa = rand(-1.4, 1.4) + ((i % 2 == 0) and math.pi or 0)
  local x, y = 408 + math.cos(aa) * 20.5, 281 + math.sin(aa) * 125
  if math.abs(y - 281) > 28 then
    if n % 4 == 0 then w:load(pile{{"lead white",2},{"Indian yellow",0.7},{"Mars orange",0.3}}, 0.65) end
    w:touch(x, y, {pressure=rand(0.35, 0.6)}); n = n + 1
  end
end
-- dull red still cooling on the forward edges
local e = brush{kind="round", width=1.6, point=0.6}
for _, seg in ipairs({ {{432,186},{434,212}}, {{432,352},{434,376}}, {{560,273},{566,277}} }) do
  e:load(pile{{"cadmium red",0.8},{"burnt sienna",1},{"bone black",0.3}}, 0.6); e:stroke(seg, {pressure={0.45, 0.2}})
end
-- the drifting plates: a hard glint on each of the larger chips
local g = brush{kind="round", width=1.6, point=0.6}
for i = 1, 30 do
  local x = rand(150, 640); local y = 281 + randn(0, 110)
  if SKY:at(x, y) > 0.5 and TT:grow(6):at(x, y) < 0.5 then
    g:load((math.random() < 0.5) and pile{{"zinc white",2},{"lead white",1},{"yellow ochre",0.3}} or pile{{"lead white",2},{"Mars orange",0.5}}, 0.55)
    g:touch(x, y, {pressure=rand(0.25, 0.55)})
  end
end
print(n)
