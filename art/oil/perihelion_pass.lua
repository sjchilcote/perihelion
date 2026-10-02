-- easel session "perihelion_pass": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=1729,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",1.5},{"Mars orange",1},{"raw sienna",1},{"lead white",0.6}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
SAIL = ellipse(700, 272, 62, 236)
CONE = poly({{700,40},{700,505},{330,400},{40,300},{40,250},{330,150}}, true) - SAIL
AIR = everywhere() - CONE - SAIL
local flow = function(x, y) return math.pi + (y - 281) / 900 end   -- leftward, spreading slightly
local cO = pile{{"Mars orange",1.5},{"cadmium red",0.4},{"Indian yellow",0.6}}
local cG = pile{{"cadmium yellow",1},{"Mars yellow",1},{"lead white",1}}
local cW = pile{{"lead white",3},{"zinc white",1},{"lemon chrome",0.25}}
work(AIR, {hand="broad", pile=cO, coverage=2.4, fill=true, angle=flow, clip=AIR})
local mid = AIR * mask(function(x, y) return x > 380 and 1 or 0 end)
work(mid, {hand="broad", pile=cG, coverage=2.2, fill=true, angle=flow, clip=AIR})
local near = AIR * mask(function(x, y) return x > 760 and 1 or 0 end)
work(near, {hand="broad", pile=cW, coverage=2.4, fill=true, angle=flow, clip=AIR})
local shad = pile{{"bone black",3},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
work(CONE, {hand="broad", pile=shad, coverage=3, fill=true, angle=math.pi, clip=CONE})
work(SAIL, {hand="body", pile=pile{{"bone black",3},{"ultramarine blue",0.6}}, coverage=3, fill=true, angle=math.pi/2, clip=SAIL})

--@ chunk 3
print(wait(3*24*60))
-- the corona as streamers rushing past: long strokes running with the flow, white near the Sun, gold, then orange-red downstream
local cW = pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.2}}
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local cR = pile{{"cadmium red",1},{"Mars orange",0.8},{"lead white",0.3}}
local wide = brush("filbert", 10)
local mid = brush("filbert", 5)
local thin = brush{kind="round", width=2.2, point=0.5}
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local n = 0
for i = 1, 260 do
  local y0 = rand(-20, 580)
  local x1 = rand(-60, 1060)
  local len = rand(140, 480)
  local x0 = x1 + len
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 6 * math.sin(k * 0.9 + i)} end
  local xm = (x0 + x1) / 2
  local p = (xm > 760) and cW or ((xm > 480) and ((math.random() < 0.5) and cW or cG) or ((xm > 250) and cG or ((math.random() < 0.5) and cO or cR)))
  local br = (math.random() < 0.25) and wide or ((math.random() < 0.5) and mid or thin)
  br:reload(p, 0.6)
  br:stroke(pts, {pressure={0.1, 0.6}, swell={0.4, 1, 1, 0.6}, ramps={0.4, 0.3}, orient="along", clip=AIR})
  n = n + 1
end
print(n)

--@ chunk 4
print(wait(2*24*60))
-- the shadow-cone is plasma in shadow, not a solid: dusky crimson streaks run through it and over its edges; only a narrow core stays near-black
local dR = pile{{"bone black",1.5},{"cadmium red",1},{"burnt sienna",0.8}}
local dR2 = pile{{"bone black",1},{"Mars orange",0.6},{"cadmium red",0.6}}
local core = poly({{690,120},{690,430},{360,330},{150,290},{150,265},{360,225}}, true)
local zone = (CONE:grow(30) - core:grow(10) - SAIL:grow(2))
local b = brush("filbert", 9)
local t = brush{kind="round", width=3, point=0.4}
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
for i = 1, 180 do
  local y0 = rand(20, 540)
  local x1 = rand(-40, 600); local x0 = x1 + rand(150, 420)
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 4 * math.sin(k + i)} end
  local br = (math.random() < 0.5) and b or t
  br:reload((math.random() < 0.6) and dR or dR2, 0.6)
  br:stroke(pts, {pressure={0.3, 0.7}, ramps={0.3, 0.3}, orient="along", clip=zone})
end
-- the left band seam: gold streamers carried down into the orange
local g = brush("filbert", 6)
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
for i = 1, 70 do
  local y0 = (math.random() < 0.5) and rand(0, 170) or rand(390, 562)
  local x0 = rand(300, 560); local x1 = x0 - rand(160, 380)
  local pts = {}
  for k = 0, 5 do local x = lerp(x0, x1, k / 5); pts[#pts+1] = {x, fy(x, y0)} end
  g:reload((x0 > 420) and cG or cO, 0.6)
  g:stroke(pts, {pressure={0.5, 0.1}, ramps={0.2, 0.5}, orient="along", clip=AIR})
end

--@ chunk 5
print(wait(2*24*60))
-- the cone repainted as plasma in shadow: a deep crimson-brown, streaked with the flow, darkest along its axis; the sail stays black against it
local flow = function(x, y) return math.pi + (y - 281) / 900 end
local cz = CONE:grow(6) - SAIL:grow(1)
local deep = pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.7}}
local axis = pile{{"bone black",2.5},{"burnt sienna",0.8},{"cadmium red",0.3}}
work(cz, {hand="body", tool="filbert 8", pile=deep, coverage=3.2, fill=true, angle=flow, clip=cz, length={60, 160}, load=0.9})
local ax = poly({{690,180},{690,370},{400,320},{200,290},{200,270},{400,240}}, true) - SAIL:grow(1)
work(ax, {hand="body", tool="filbert 8", pile=axis, coverage=2.6, fill=true, angle=flow, clip=ax:soften(12), length={60, 160}, load=0.8})
blend((ax:grow(16) - ax:shrink(10)) * cz, {angle=flow})

--@ chunk 6
print(wait(3*24*60))
-- break the cone's outline: streamers of light run into its edges and dark ones out of it, all with the flow, so it is shadow in moving plasma
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local band = (CONE:grow(28) - CONE:shrink(30)) - SAIL:grow(3)
local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local cR = pile{{"cadmium red",1},{"Mars orange",0.8},{"bone black",0.2}}
local dk = pile{{"bone black",2.5},{"burnt sienna",0.8},{"cadmium red",0.3}}
local b = brush("filbert", 5)
local t = brush{kind="round", width=2.4, point=0.5}
-- the cone's edge lines (upper and lower), as functions of x
local function edgeY(x, upper)
  if upper then return lerp(300 - 0.0, 40, clamp((x - 40) / 660, 0, 1)^0.9) else return lerp(270, 505, clamp((x - 40) / 660, 0, 1)^0.9) end
end
for i = 1, 240 do
  local upper = (i % 2 == 0)
  local x1 = rand(20, 620); local x0 = math.min(x1 + rand(120, 300), 690)
  local off = rand(-26, 26)
  local pts = {}
  for k = 0, 6 do
    local x = lerp(x0, x1, k / 6)
    pts[#pts+1] = {x, edgeY(x, upper) + off * (0.6 + 0.4 * k / 6)}
  end
  local inward = (upper and off > 0) or ((not upper) and off < 0)
  local p = inward and ((math.random() < 0.55) and dk or cR) or ((x0 > 450) and cG or cO)
  local br = (math.random() < 0.5) and b or t
  br:reload(p, 0.6)
  br:stroke(pts, {pressure={0.2, 0.6}, swell={0.5, 1, 0.7}, ramps={0.3, 0.3}, orient="along", clip=band})
end

--@ chunk 7
print(wait(3*24*60))
-- rethink: the shadow is a long band behind the sail that thins and fades downstream, not a solid cone.
-- 1) plasma streamers laid opaque over everything outside the new band (covering the cone's slanted flanks)
function hw(x) return 120 + 112 * clamp(x / 690, 0, 1) end
function inBand(x, y) return math.abs(y - 281) < hw(x) end
BAND = mask(function(x, y) return (x < 700 and inBand(x, y)) and 1 or 0 end) - SAIL
OUTSIDE = (CONE:grow(40) - BAND:shrink(6) - SAIL:grow(2))
local flow = function(x, y) return math.pi + (y - 281) / 900 end
local cO = pile{{"Mars orange",1.5},{"cadmium red",0.3},{"Indian yellow",0.6},{"lead white",0.3}}
local cG = pile{{"cadmium yellow",1},{"Mars yellow",1},{"lead white",1}}
local L = OUTSIDE * mask(function(x, y) return x < 420 and 1 or 0 end)
local R = OUTSIDE - L
work(L, {hand="body", tool="filbert 8", pile=cO, coverage=3.4, fill=true, angle=flow, clip=OUTSIDE, length={80, 200}, load=0.95})
work(R, {hand="body", tool="filbert 8", pile=cG, coverage=3.4, fill=true, angle=flow, clip=OUTSIDE, length={80, 200}, load=0.95})

--@ chunk 8
-- 2) the band itself: dark plasma, near-black by the sail, warming to a deep crimson downstream, laid with the flow
local flow = function(x, y) return math.pi + (y - 281) / 900 end
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local crim = pile{{"bone black",1.2},{"cadmium red",1},{"burnt sienna",1}}
local Bn = BAND * mask(function(x, y) return x > 330 and 1 or 0 end)
local Bf = BAND - Bn
work(Bn, {hand="body", tool="filbert 8", pile=blk, coverage=3.4, fill=true, angle=flow, clip=BAND, length={80, 200}, load=0.95})
work(Bf, {hand="body", tool="filbert 8", pile=crim, coverage=3.4, fill=true, angle=flow, clip=BAND, length={80, 200}, load=0.95})
blend(BAND * rect(250, 0, 160, 562), {angle=flow})

--@ chunk 9
print(wait(3*24*60))
-- frame-level repaint: the whole field as streamers running with the flow. Each stroke takes its colour from where it lies:
-- deep in the shadow band, near-black; in its soft, widening penumbra, crimson and red; outside, orange to gold to white toward the Sun.
local ladder = {
  pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}},
  pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}},
  pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}},
  pile{{"cadmium red",0.6},{"Mars orange",1.2},{"Indian yellow",0.3}},
  pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.6}},
  pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}},
  pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.2}},
}
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local function level(x, y)
  -- 1..7: light level at a point
  local outside = clamp(3.6 + 3.4 * smoothstep(80, 900, x), 1, 7)
  if x > 700 then return outside end
  local hw = 120 + 112 * clamp(x / 690, 0, 1)
  local pen = 14 + 0.16 * (700 - x)
  local d = math.abs(y - 281) - hw            -- <0 inside
  local sh = 1 - smoothstep(-pen, pen, d)      -- 1 deep inside
  local depth = lerp(0.55, 1.0, clamp(x / 690, 0, 1))
  return lerp(outside, 1, sh * depth)
end
local B = {brush("filbert", 9), brush("filbert", 6), brush{kind="round", width=3, point=0.4}}
local n = 0
for i = 1, 950 do
  local y0 = rand(-30, 600)
  local x1 = rand(-80, 1000); local x0 = x1 + rand(90, 320)
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 4 * math.sin(k * 0.8 + i)} end
  local xm, ym = (x0 + x1) / 2, fy((x0 + x1) / 2, y0)
  local L = clamp(math.floor(level(xm, ym) + randn(0, 0.45) + 0.5), 1, 7)
  local br = B[(L >= 6) and 3 or ((math.random() < 0.5) and 1 or 2)]
  br:reload(ladder[L], 0.65)
  br:stroke(pts, {pressure={0.3, 0.75}, swell={0.6, 1, 1, 0.7}, ramps={0.3, 0.3}, orient="along", clip=-(SAIL:grow(1))})
  n = n + 1
end
print(n)

--@ chunk 10
print(wait(2*24*60))
-- frame-level repaint: the whole field as streamers running with the flow. Each stroke takes its colour from where it lies:
-- deep in the shadow band, near-black; in its soft, widening penumbra, crimson and red; outside, orange to gold to white toward the Sun.
local ladder = {
  pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}},
  pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}},
  pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}},
  pile{{"cadmium red",0.6},{"Mars orange",1.2},{"Indian yellow",0.3}},
  pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.6}},
  pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}},
  pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.2}},
}
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local function level(x, y)
  -- 1..7: light level at a point
  local outside = clamp(3.6 + 3.4 * smoothstep(80, 900, x), 1, 7)
  if x > 700 then return outside end
  local hw = 120 + 112 * clamp(x / 690, 0, 1)
  local pen = 14 + 0.16 * (700 - x)
  local d = math.abs(y - 281) - hw            -- <0 inside
  local sh = 1 - smoothstep(-pen, pen, d)      -- 1 deep inside
  local depth = lerp(0.55, 1.0, clamp(x / 690, 0, 1))
  return lerp(outside, 1, sh * depth)
end
local B = {brush("filbert", 9), brush("filbert", 6), brush{kind="round", width=3, point=0.4}}
local n = 0
local leftOf = rect(-100, -100, 802, 800) - SAIL:grow(1)
local free = -(SAIL:grow(1))
for i = 1, 1100 do
  local y0 = rand(-30, 600)
  local x1 = rand(-80, 1000); local x0 = x1 + rand(90, 320)
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 4 * math.sin(k * 0.8 + i)} end
  local xm, ym = (x0 + x1) / 2, fy((x0 + x1) / 2, y0)
  local L = clamp(math.floor(level(xm, ym) + randn(0, 0.45) + 0.5), 1, 7)
  local br = B[(L >= 6) and 3 or ((math.random() < 0.5) and 1 or 2)]
  br:reload(ladder[L], 0.65)
  br:stroke(pts, {pressure={0.3, 0.75}, swell={0.6, 1, 1, 0.7}, ramps={0.3, 0.3}, orient="along", clip=(L <= 4) and leftOf or free})
  n = n + 1
end
print(n)

--@ chunk 11
print(wait(3*24*60))
-- the station in the shadow: a long dark spindle, stepped tiers, the darkest thing in the picture
STN = poly({{560,281},{548,262},{520,250},{470,246},{430,236},{380,236},{350,246},{300,250},{250,258},{215,268},{200,281},{215,294},{250,304},{300,312},{350,316},{380,326},{430,326},{470,316},{520,312},{548,300}}, true)
  + ellipse(405, 281, 30, 58)
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
work(STN, {hand="body", tool="filbert 5", pile=blk, coverage=3.8, fill=true, angle=math.pi, clip=true, load=0.95})
-- the sail: its dark face given faint radial ribs, and the burning rim on the sunward edge
local rib = brush{kind="round", width=1.6, point=0.6}
local ribP = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.2}}
for k = 1, 9 do
  local a = -math.pi/2 + k * math.pi / 10
  rib:load(ribP, 0.5)
  rib:stroke({{700, 272}, {700 + math.cos(a) * 58, 272 + math.sin(a) * 230}}, {pressure={0.3, 0.3}, clip=SAIL:shrink(3)})
end

--@ chunk 12
print(wait(3*24*60))
-- rim: white-hot along the sunward (right) half of the sail's edge, thickest at the middle
local hot = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}
local r = brush{kind="round", width=5, point=0.3}
local pts = {}
for k = 0, 40 do local a = -math.pi/2 + k * math.pi / 40; pts[#pts+1] = {700 + math.cos(a) * 63, 272 + math.sin(a) * 237} end
for pass = 1, 2 do r:load(hot, 0.85); r:stroke(pts, {pressure={0.2, 0.2}, swell={0.4, 1.4, 2.2, 1.4, 0.4}, ramps={0.15, 0.15}}) end
-- glare bleeding off the rim into the plasma, with the flow
local g = brush("filbert", 7)
for i = 1, 40 do
  local a = rand(-1.3, 1.3)
  local x0, y0 = 700 + math.cos(a) * 64, 272 + math.sin(a) * 238
  g:reload(hot, 0.6)
  g:stroke({{x0 + 2, y0}, {x0 - 30, y0 + (y0 - 281) * 0.03}, {x0 - rand(60, 140), y0 + (y0 - 281) * 0.08}}, {pressure={0.6, 0.02}, ramps={0.05, 0.8}, orient="along", clip=-(SAIL:shrink(1))})
end
-- the station's exposed edges glowing cherry: top and bottom lips of each tier, and the trailing sparks of peeling plates
local cherry = pile{{"cadmium red",1.5},{"vermilion",0.6},{"Mars orange",0.3}}
local cherryHot = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.6}}
local e = brush{kind="round", width=1.8, point=0.6}
for _, seg in ipairs({ {{548,262},{520,250},{470,246}}, {{430,236},{380,236},{350,246}}, {{300,250},{250,258},{215,268}},
                       {{548,300},{520,312},{470,316}}, {{430,326},{380,326},{350,316}}, {{300,312},{250,304},{215,294}},
                       {{405,223},{390,226}}, {{405,339},{390,336}} }) do
  e:load(cherry, 0.6); e:stroke(seg, {pressure={0.55, 0.3}, ramps={0.1, 0.3}})
end
local sp = brush{kind="round", width=2.4, point=0.5}
local n = 0
for i = 1, 70 do
  local x0 = rand(210, 540); local y0 = (math.random() < 0.5) and rand(232, 252) or rand(310, 330)
  local len = rand(8, 60)
  sp:reload((math.random() < 0.4) and cherryHot or cherry, 0.55)
  sp:stroke({{x0, y0}, {x0 - len, y0 + (y0 - 281) * 0.04 * len / 30}}, {pressure={0.55, 0.02}, ramps={0.05, 0.8}})
  if math.random() < 0.4 then
    local f = brush{kind="filbert", width=3}
    f:load(pile{{"bone black",2},{"cadmium red",0.6}}, 0.7)
    f:touch(x0 - len - rand(4, 20), y0 + rand(-6, 6), {pressure=0.6, angle=rand(0, 3)})
  end
  n = n + 1
end
print(n)

--@ chunk 13
print(wait(2*24*60))
-- the rim burning INTO the sail's edge: a white-gold crescent eating into the black on the sunward side, with an orange inner fringe
local cres = SAIL - ellipse(693, 272, 62, 233)
work(cres, {hand="detail", pile=pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.25}}, coverage=2.8, fill=true, angle=math.pi/2, clip=true})
local fr = brush{kind="round", width=2.2, point=0.5}
local pts = {}
for k = 2, 38 do local a = -math.pi/2 + k * math.pi / 40; pts[#pts+1] = {693 + math.cos(a) * 60, 272 + math.sin(a) * 230} end
fr:load(pile{{"cadmium red",1},{"Mars orange",1},{"cadmium yellow",0.3}}, 0.7)
fr:stroke(pts, {pressure={0.2, 0.2}, swell={0.4, 1.3, 1.6, 1.3, 0.4}, ramps={0.15, 0.15}})
-- the station's glowing edges, heavier, and burning flakes streaming off it into the shadow
local cherry = pile{{"cadmium red",1.5},{"vermilion",0.8},{"Mars orange",0.4}}
local hotP = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.8}}
local e = brush{kind="round", width=2.6, point=0.5}
for _, seg in ipairs({ {{556,272},{548,262},{520,250},{470,246}}, {{432,236},{405,223},{380,236},{350,246}}, {{300,250},{250,258},{215,268},{202,278}},
                       {{556,290},{548,300},{520,312},{470,316}}, {{432,326},{405,339},{380,326},{350,316}}, {{300,312},{250,304},{215,294},{202,284}} }) do
  e:load(cherry, 0.75); e:stroke(seg, {pressure={0.7, 0.45}, ramps={0.1, 0.3}})
end
local hl = brush{kind="round", width=1.2, point=0.8}
for _, seg in ipairs({ {{552,266},{530,254}}, {{552,296},{530,308}}, {{420,231},{408,225}} }) do hl:load(hotP, 0.6); hl:stroke(seg, {pressure={0.6, 0.2}}) end
local sp = brush{kind="round", width=3, point=0.4}
local f = brush("filbert", 4)
for i = 1, 60 do
  local x0 = rand(200, 520); local y0 = 281 + ((math.random() < 0.5) and -1 or 1) * rand(32, 60)
  local len = rand(20, 110)
  local y1 = y0 + (y0 - 281) * 0.002 * len
  sp:reload((math.random() < 0.5) and hotP or cherry, 0.7)
  sp:stroke({{x0, y0}, {x0 - len * 0.5, (y0 + y1) / 2}, {x0 - len, y1}}, {pressure={0.75, 0.02}, ramps={0.05, 0.85}, orient="along"})
  if i % 3 == 0 then
    f:reload(pile{{"bone black",2},{"cadmium red",0.5}}, 0.8)
    f:stroke({{x0 + 3, y0 - 1}, {x0 - 1, y0 + 1}}, {pressure={0.8, 0.6}})
  end
end

--@ chunk 14
print(wait(2*24*60))
-- the station redrawn as a stepped spindle: tiers widening to a great ring-tier amidships, a spine running back, crisp corners
local top = {{566,281},{560,270},{540,268},{536,258},{505,256},{500,244},{462,242},{456,228},{420,226},{414,214},{396,214},{390,226},{352,228},{346,242},{310,244},{304,254},{268,256},{262,264},{226,266},{222,272},{180,274},{176,278},{150,279}}
local pts = {}
for _, p in ipairs(top) do pts[#pts+1] = p end
for i = #top, 1, -1 do local p = top[i]; pts[#pts+1] = {p[1], 562 - p[2]} end
STN2 = poly(pts)
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
work(STN2:grow(1), {hand="body", tool="filbert 4", pile=blk, coverage=3.8, fill=true, angle=math.pi, clip=true, load=0.95})
-- old blob outside the new silhouette: shadow-band plasma again
local rest = STN:grow(2) - STN2:grow(1)
work(rest, {hand="detail", pile=pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}}, coverage=3.2, fill=true, angle=math.pi, clip=true})

--@ chunk 15
print(wait(2*24*60))
-- exposed edges glowing cherry: a thin rim along the outer (upper and lower) faces of every tier, hotter toward the sail
local nz = noise{seed=12, period=8}
local edge = mask(function(x, y)
  if x < 150 or x > 570 then return 0 end
  if STN2:at(x, y) < 0.5 then return 0 end
  local dy = (y < 281) and 2.2 or -2.2
  if STN2:at(x, y - dy) > 0.5 and STN2:at(x - 2.2, y) > 0.5 then return 0 end
  return (nz:at01(x, y) > 0.25) and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=1.4, point=0.8}, pile=pile{{"cadmium red",1.5},{"vermilion",0.8},{"Mars orange",0.3}}, coverage=2.2, fill=true, clip=true, angle=0})
local hot = edge * mask(function(x, y) return (x > 430 and nz:at01(x + 50, y) > 0.5) and 1 or 0 end)
work(hot, {hand="detail", tool={kind="round", width=1.2, point=0.8}, pile=pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.8}}, coverage=1.8, fill=true, clip=true, angle=0})
-- plates peeling from the outer corners: burning flakes streaming back with sparks
local sp = brush{kind="round", width=2.6, point=0.4}
local f = brush("flat", 4)
local corners = {{456,228},{414,214},{396,214},{352,228},{500,244},{310,244},{536,258},{268,256}}
for i = 1, 45 do
  local c = corners[(i % #corners) + 1]
  local up = (i % 2 == 0)
  local x0 = c[1] - rand(4, 40); local y0 = up and (c[2] - rand(2, 14)) or (562 - c[2] + rand(2, 14))
  f:reload(pile{{"bone black",2},{"cadmium red",0.6}}, 0.85)
  f:stroke({{x0 + 2.5, y0 - 1}, {x0 - 2.5, y0 + 1}}, {pressure={0.8, 0.7}, orient=rand(0, 3)})
  local len = rand(20, 120)
  sp:reload((math.random() < 0.5) and pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.8}} or pile{{"cadmium red",1.5},{"vermilion",0.8}}, 0.7)
  sp:stroke({{x0 - 3, y0}, {x0 - 3 - len * 0.5, y0 + (y0 - 281) * 0.03}, {x0 - 3 - len, y0 + (y0 - 281) * 0.07}}, {pressure={0.7, 0.02}, ramps={0.05, 0.85}, orient="along"})
end

--@ chunk 16
print(wait(5*24*60), drying(400, 281))
-- restate the glowing lips with long strokes along the silhouette itself, on dry paint
local top = {{566,281},{560,270},{540,268},{536,258},{505,256},{500,244},{462,242},{456,228},{420,226},{414,214},{396,214},{390,226},{352,228},{346,242},{310,244},{304,254},{268,256},{262,264},{226,266},{222,272},{180,274},{176,278},{150,279}}
local cherry = pile{{"cadmium red",1.5},{"vermilion",0.8},{"Mars orange",0.3}}
local hot = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",1}}
local e = brush{kind="round", width=2.4, point=0.5}
for side = 1, 2 do
  for i = 1, #top - 1 do
    local a, b = top[i], top[i + 1]
    local function Y(p) return (side == 1) and (p[2] + 1.2) or (562 - p[2] - 1.2) end
    local horiz = math.abs(a[2] - b[2]) < 3
    local heat = smoothstep(150, 560, (a[1] + b[1]) / 2)
    e:load((heat > 0.6 and horiz) and hot or cherry, 0.75)
    e:stroke({{a[1], Y(a)}, {b[1], Y(b)}}, {pressure={horiz and (0.45 + 0.4 * heat) or 0.35, horiz and (0.35 + 0.3 * heat) or 0.3}, ramps={0.05, 0.1}})
  end
end

--@ chunk 17
-- mend the two straight slants left from the first cone (upper and lower left) with streamers across them
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local p4 = pile{{"cadmium red",0.6},{"Mars orange",1.2},{"Indian yellow",0.3}}
local p5 = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.6}}
local p3 = pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}}
local zone = (rect(-10, -10, 420, 175) + rect(-10, 390, 420, 190))
local B = {brush("filbert", 9), brush("filbert", 6)}
for i = 1, 260 do
  local y0 = (math.random() < 0.5) and rand(-20, 170) or rand(390, 590)
  local x1 = rand(-80, 380); local x0 = x1 + rand(100, 260)
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 3 * math.sin(k + i)} end
  local inner = math.abs(fy((x0 + x1) / 2, y0) - 281) < 160
  local r = math.random()
  local br = B[(r < 0.5) and 1 or 2]
  br:reload(inner and ((r < 0.5) and p3 or p4) or ((r < 0.5) and p4 or p5), 0.65)
  br:stroke(pts, {pressure={0.3, 0.75}, ramps={0.3, 0.3}, orient="along", clip=zone})
end

--@ chunk 18
print(wait(24*60))
-- frame-level repaint: the whole field as streamers running with the flow. Each stroke takes its colour from where it lies:
-- deep in the shadow band, near-black; in its soft, widening penumbra, crimson and red; outside, orange to gold to white toward the Sun.
local ladder = {
  pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}},
  pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}},
  pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}},
  pile{{"cadmium red",0.6},{"Mars orange",1.2},{"Indian yellow",0.3}},
  pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.6}},
  pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}},
  pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.2}},
}
local function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local function level(x, y)
  -- 1..7: light level at a point
  local outside = clamp(3.6 + 3.4 * smoothstep(80, 900, x), 1, 7)
  if x > 700 then return outside end
  local hw = 120 + 112 * clamp(x / 690, 0, 1)
  local pen = 14 + 0.16 * (700 - x)
  local d = math.abs(y - 281) - hw            -- <0 inside
  local sh = 1 - smoothstep(-pen, pen, d)      -- 1 deep inside
  local depth = lerp(0.55, 1.0, clamp(x / 690, 0, 1))
  return lerp(outside, 1, sh * depth)
end
local B = {brush("filbert", 9), brush("filbert", 6), brush{kind="round", width=3, point=0.4}}
local n = 0
local leftOf = rect(-100, -100, 802, 800) - SAIL:grow(1)
local free = -(SAIL:grow(1))
leftOf = leftOf - STN2:grow(4); free = free - STN2:grow(4)
for i = 1, 600 do
  local y0 = rand(-30, 600)
  local x1 = rand(-80, 560); local x0 = x1 + rand(90, 320)
  local pts = {}
  for k = 0, 6 do local x = lerp(x0, x1, k / 6); pts[#pts+1] = {x, fy(x, y0) + 4 * math.sin(k * 0.8 + i)} end
  local xm, ym = (x0 + x1) / 2, fy((x0 + x1) / 2, y0)
  local L = clamp(math.floor(level(xm, ym) + randn(0, 0.45) + 0.5), 1, 7)
  local br = B[(L >= 6) and 3 or ((math.random() < 0.5) and 1 or 2)]
  br:reload(ladder[L], 0.65)
  br:stroke(pts, {pressure={0.3, 0.75}, swell={0.6, 1, 1, 0.7}, ramps={0.3, 0.3}, orient="along", clip=(L <= 4) and leftOf or free})
  n = n + 1
end
print(n)

--@ chunk 19
print(wait(6*24*60), drying(300, 256))
-- the lips again, brighter: cherry body, hot core on the horizontal faces
local top = {{566,281},{560,270},{540,268},{536,258},{505,256},{500,244},{462,242},{456,228},{420,226},{414,214},{396,214},{390,226},{352,228},{346,242},{310,244},{304,254},{268,256},{262,264},{226,266},{222,272},{180,274},{176,278},{150,279}}
local cherry = pile{{"vermilion",1},{"cadmium red",0.6},{"Mars orange",0.6},{"lead white",0.25}}
local hot = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.4}}
local e = brush{kind="round", width=3.2, point=0.4}
local h = brush{kind="round", width=1.4, point=0.8}
for side = 1, 2 do
  for i = 1, #top - 1 do
    local a, b = top[i], top[i + 1]
    local function Y(p, d) return (side == 1) and (p[2] + d) or (562 - p[2] - d) end
    local horiz = math.abs(a[2] - b[2]) < 3
    local heat = smoothstep(150, 560, (a[1] + b[1]) / 2)
    e:load(cherry, 0.85)
    e:stroke({{a[1], Y(a, 1.6)}, {b[1], Y(b, 1.6)}}, {pressure={0.55 + 0.3 * heat, 0.5 + 0.3 * heat}, ramps={0.05, 0.1}})
    if horiz and heat > 0.25 then
      h:load(hot, 0.7)
      h:stroke({{a[1] - 1, Y(a, 0.8)}, {b[1] + 1, Y(b, 0.8)}}, {pressure={0.4 + 0.4 * heat, 0.3}, ramps={0.05, 0.3}})
    end
  end
end
-- flakes tearing off the outermost corners, with bright trails
local sp = brush{kind="round", width=2.6, point=0.4}
local f = brush("flat", 5)
for i = 1, 24 do
  local up = (i % 2 == 0)
  local c = ({{414,214},{456,228},{500,244},{536,258},{352,228},{310,244}})[(i % 6) + 1]
  local x0 = c[1] - rand(10, 90)
  local y0 = up and (c[2] - rand(4, 26)) or (562 - c[2] + rand(4, 26))
  f:reload(pile{{"bone black",2},{"vermilion",0.5}}, 0.85)
  f:stroke({{x0 + 3, y0 - 1.5}, {x0 - 3, y0 + 1.5}}, {pressure={0.85, 0.8}, orient=rand(0, 3)})
  sp:reload(hot, 0.7)
  local len = rand(30, 140)
  sp:stroke({{x0 - 4, y0}, {x0 - 4 - len, y0 + (y0 - 281) * 0.05}}, {pressure={0.7, 0.02}, ramps={0.03, 0.85}, orient="along"})
end

--@ chunk 20
print(wait(8*24*60), drying(300, 256))
-- break the even outline: the trailing tiers sink back into shadow (lips knocked out in runs), the leading ones burn hotter in broken dashes
local top = {{566,281},{560,270},{540,268},{536,258},{505,256},{500,244},{462,242},{456,228},{420,226},{414,214},{396,214},{390,226},{352,228},{346,242},{310,244},{304,254},{268,256},{262,264},{226,266},{222,272},{180,274},{176,278},{150,279}}
local blk = pile{{"bone black",3},{"ultramarine blue",0.3}}
local hot = pile{{"zinc white",1},{"lead white",1.5},{"cadmium yellow",0.7},{"Mars orange",0.3}}
local d = brush{kind="round", width=4.2, point=0.3}
local h = brush{kind="round", width=1.8, point=0.7}
for side = 1, 2 do
  for i = 1, #top - 1 do
    local a, b = top[i], top[i + 1]
    local function P(p, t, dd) local x = lerp(a[1], b[1], t); local y = lerp(a[2], b[2], t) + dd; return {x, (side == 1) and y or (562 - y)} end
    local xm = (a[1] + b[1]) / 2
    local shade = 1 - smoothstep(200, 470, xm)        -- trailing end: mostly knocked out
    local t = 0
    while t < 1 do
      local run = rand(0.15, 0.4)
      if math.random() < 0.15 + 0.7 * shade then
        d:load(blk, 0.85)
        d:stroke({P(a, t, 1.4), P(a, math.min(1, t + run), 1.4)}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
      elseif xm > 380 and math.abs(a[2] - b[2]) < 3 and math.random() < 0.6 then
        h:load(hot, 0.7)
        h:stroke({P(a, t, 1.0), P(a, math.min(1, t + run * 0.8), 1.0)}, {pressure={0.6, 0.4}, ramps={0.1, 0.3}})
      end
      t = t + run + rand(0.05, 0.2)
    end
  end
end
-- a few burning flakes, bright, tumbling back from the leading tiers
local sp = brush{kind="round", width=3, point=0.4}
local f = brush{kind="round", width=4, point=0.1}
for i = 1, 16 do
  local up = (i % 2 == 0)
  local x0 = rand(330, 520); local y0 = up and rand(196, 236) or rand(326, 366)
  sp:reload(hot, 0.8)
  local len = rand(30, 110)
  sp:stroke({{x0, y0}, {x0 - len, y0 + (y0 - 281) * 0.05}}, {pressure={0.75, 0.02}, ramps={0.03, 0.85}, orient="along"})
  f:load(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.4}}, 0.8)
  f:touch(x0 + 1.5, y0, {pressure=0.7})
end

--@ chunk 21
print(wait(4*24*60), drying(400, 281))
-- PASS · paint the stepped blob out with the shadow band's own streaks (same flow, same value ladder as the field)
LADDER = {
  pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}},
  pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}},
  pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}},
}
function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local zone = (STN2:grow(7) + STN:grow(4)) - SAIL:grow(1)
local B = {brush("filbert", 7), brush("filbert", 4)}
for pass = 1, 2 do
  for i = 1, 260 do
    local y0 = rand(190, 372)
    local x1 = rand(80, 560); local x0 = x1 + rand(70, 200)
    local pts = {}
    for k = 0, 5 do local x = lerp(x0, x1, k / 5); pts[#pts+1] = {x, fy(x, y0) + 2 * math.sin(k + i)} end
    local d = math.abs(fy((x0 + x1) / 2, y0) - 281)
    local L = (d < 60 or math.random() < 0.6) and 1 or 2
    if math.random() < 0.12 then L = L + 1 end
    local br = B[(math.random() < 0.5) and 1 or 2]
    br:reload(LADDER[L], 0.85)
    br:stroke(pts, {pressure={0.5, 0.9}, ramps={0.2, 0.2}, orient="along", clip=zone})
  end
end

--@ chunk 22
print(wait(3*24*60), drying(400, 281))
-- PASS · paint the stepped blob out with the shadow band's own streaks (same flow, same value ladder as the field)
LADDER = {
  pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}},
  pile{{"bone black",1.5},{"burnt sienna",1},{"cadmium red",0.6}},
  pile{{"cadmium red",1},{"burnt sienna",0.6},{"bone black",0.3}},
}
function fy(x, y0) return 281 + (y0 - 281) * (1 + (700 - x) / 1400) end
local zone = (STN2:grow(7) + STN:grow(4)) - SAIL:grow(1)
local B = {brush("filbert", 7), brush("filbert", 4)}
for pass = 1, 1 do
  for i = 1, 260 do
    local y0 = rand(190, 372)
    local x1 = rand(80, 560); local x0 = x1 + rand(70, 200)
    local pts = {}
    for k = 0, 5 do local x = lerp(x0, x1, k / 5); pts[#pts+1] = {x, fy(x, y0) + 2 * math.sin(k + i)} end
    local d = math.abs(fy((x0 + x1) / 2, y0) - 281)
    local L = (math.random() < 0.3) and 1 or 2
    if math.random() < 0.2 then L = 3 end
    local br = B[(math.random() < 0.5) and 1 or 2]
    br:reload(LADDER[L], 0.85)
    br:stroke(pts, {pressure={0.5, 0.9}, ramps={0.2, 0.2}, orient="along", clip=zone})
  end
end

--@ chunk 23
print(wait(5*24*60), drying(400, 281))
-- the TESTAMENT as a silhouette: spine toward the sail, the ring nearly edge-on across it, the hub, the maw's flare at the back
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
SPINE = poly({{640,276},{628,272},{560,273},{470,271},{420,270},{380,271},{300,273},{230,274},{205,272},{205,290},{230,288},{300,289},{380,291},{420,292},{470,291},{560,289},{628,290},{640,286}})
RINGO = ellipse(408, 281, 26, 132)
RINGI = ellipse(409, 281, 15, 118)
RING = RINGO - RINGI
HUB = ellipse(408, 281, 20, 22)
MAW = poly({{212,272},{196,266},{178,258},{160,250},{150,252},{154,264},{158,281},{154,298},{150,310},{160,312},{178,304},{196,296},{212,290}}, true)
TT = SPINE + RING + HUB + MAW
work(TT, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=0, clip=true, load=0.95})
-- tethers from the spine's prow to the sail's rim: thin dark lines
local t = brush{kind="round", width=1.3, point=0.8}
TETH = {{{636,276},{662,82}}, {{636,276},{650,130}}, {{636,286},{650,414}}, {{636,286},{662,462}}, {{640,281},{638,281}}}
for i = 1, 4 do t:load(blk, 0.8); t:stroke(TETH[i], {pressure={0.55, 0.4}, ramps={0.02, 0.02}}) end

--@ chunk 24
print(wait(5*24*60), drying(408, 160))
-- heat only on the forward-facing edges, broken, fading back; tethers catching a red edge; plates peeling as sparks
local cherry = pile{{"vermilion",1},{"cadmium red",0.6},{"Mars orange",0.5},{"lead white",0.2}}
local orange = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.7}}
local e = brush{kind="round", width=2.0, point=0.6}
local h = brush{kind="round", width=1.3, point=0.8}
-- the ring's forward (right) edge: the outer arc's right side, hottest at the tips which reach toward the shadow's edge
local function ringpt(a, rx, ry) return {408 + math.cos(a) * rx, 281 + math.sin(a) * ry} end
local a = -math.pi / 2
while a < math.pi / 2 do
  local run = rand(0.12, 0.3)
  if math.random() < 0.75 then
    local tip = math.abs(math.sin(a + run / 2))
    local pts = {}
    for k = 0, 4 do pts[#pts+1] = ringpt(a + run * k / 4, 25, 131) end
    e:load((tip > 0.8) and orange or cherry, 0.75)
    e:stroke(pts, {pressure={0.4 + 0.3 * tip, 0.3 + 0.3 * tip}, ramps={0.15, 0.25}})
  end
  a = a + run + rand(0.03, 0.1)
end
-- the ring's lit lip: a thin line along the near face where heat touches it (upper and lower thirds)
for _, rng in ipairs({{-1.45, -0.7}, {0.7, 1.45}}) do
  local pts = {}
  for k = 0, 8 do pts[#pts+1] = ringpt(lerp(rng[1], rng[2], k / 8), 17, 120) end
  h:load(cherry, 0.6); h:stroke(pts, {pressure={0.35, 0.2}, ramps={0.2, 0.4}})
end
-- the spine's prow and the hub's forward face
e:load(orange, 0.7); e:stroke({{629,272},{640,276},{641,286},{629,290}}, {pressure={0.6, 0.4}})
e:load(cherry, 0.7); e:stroke({{560,273},{600,272.5}}, {pressure={0.35, 0.1}, ramps={0.1, 0.6}})
e:load(cherry, 0.7); e:stroke({{560,289},{600,289.5}}, {pressure={0.35, 0.1}, ramps={0.1, 0.6}})
e:load(cherry, 0.6); e:stroke({{424,266},{428,281},{424,296}}, {pressure={0.35, 0.3}})
-- the maw's flare lips, faint (it faces back, away)
h:load(cherry, 0.5); h:stroke({{162,250},{150,252}}, {pressure={0.3, 0.1}}); h:load(cherry, 0.5); h:stroke({{162,312},{150,310}}, {pressure={0.3, 0.1}})
-- tethers catching a red edge on their sunward side
for i = 1, 4 do
  local s = TETH[i]
  h:load(cherry, 0.55)
  h:stroke({{s[1][1] + 0.9, s[1][2]}, {s[2][1] + 0.9, s[2][2]}}, {pressure={0.1, 0.35}, ramps={0.3, 0.05}})
end
-- plates peeling from the ring's tips and the prow, streaming back as sparks
local sp = brush{kind="round", width=3.2, point=0.4}
local f = brush("flat", 6)
for i = 1, 22 do
  local src = ({{415,150},{415,412},{425,170},{425,392},{620,272},{620,290}})[(i % 6) + 1]
  local x0 = src[1] - rand(6, 60); local y0 = src[2] + rand(-14, 14)
  f:reload(pile{{"bone black",2},{"vermilion",0.5}}, 0.9)
  f:stroke({{x0 + 3.5, y0 - 1.5}, {x0 - 3.5, y0 + 1.5}}, {pressure={0.9, 0.8}, orient=rand(0, 3)})
  local len = rand(40, 160)
  sp:reload((math.random() < 0.5) and orange or cherry, 0.8)
  sp:stroke({{x0 - 5, y0}, {x0 - 5 - len * 0.5, y0 + (y0 - 281) * 0.025}, {x0 - 5 - len, y0 + (y0 - 281) * 0.06}}, {pressure={0.8, 0.02}, ramps={0.03, 0.85}, orient="along"})
end

--@ chunk 25
print(wait(4*24*60), drying(600, 281))
-- the tethers ran along the sail's edge and vanished into it: shorten the spine's prow so the tethers fan visibly across the shadow
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
-- 1) black over the old tethers where they lie on the sail's edge
local t = brush{kind="round", width=3.2, point=0.4}
for i = 1, 4 do t:load(blk, 0.9); t:stroke({{TETH[i][1][1] + 0.5, TETH[i][1][2]}, {TETH[i][2][1] + 0.5, TETH[i][2][2]}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, clip=SAIL:grow(2)}) end
-- 2) the prow's last stretch painted out with shadow-band streaks
local zone = rect(566, 262, 74, 38) - SAIL:grow(1)
local B = brush("filbert", 4)
for i = 1, 60 do
  local y0 = rand(262, 300); local x1 = rand(540, 610); local x0 = x1 + rand(40, 90)
  B:reload((math.random() < 0.6) and LADDER[1] or LADDER[2], 0.9)
  B:stroke({{x0, y0}, {x1, y0}}, {pressure={0.7, 0.9}, ramps={0.1, 0.1}, orient="along", clip=zone})
end

--@ chunk 26
print(wait(4*24*60))
-- a prow at 566, and four tethers fanning out from it to the sail's rim, dark, each catching a red edge
local blk = pile{{"bone black",3},{"ultramarine blue",0.4}}
local cherry = pile{{"vermilion",1},{"cadmium red",0.6},{"Mars orange",0.5},{"lead white",0.2}}
local orange = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.7}}
local p = brush{kind="round", width=6, point=0.2}
p:load(blk, 0.9); p:stroke({{556,281},{568,281}}, {pressure={0.9, 0.5}})
local t = brush{kind="round", width=1.6, point=0.8}
local h = brush{kind="round", width=1.0, point=0.9}
local T2 = {{{566,276},{662,82}}, {{566,277},{650,130}}, {{566,285},{650,414}}, {{566,286},{662,462}}}
for _, s in ipairs(T2) do
  t:load(blk, 0.85); t:stroke(s, {pressure={0.6, 0.5}, ramps={0.02, 0.02}, clip=-SAIL})
  h:load(cherry, 0.6); h:stroke({{s[1][1] + 1.0, s[1][2]}, {s[2][1] + 1.0, s[2][2]}}, {pressure={0.15, 0.45}, ramps={0.2, 0.05}, clip=-SAIL})
end
local e = brush{kind="round", width=2.0, point=0.6}
e:load(orange, 0.7); e:stroke({{566,276},{571,281},{566,286}}, {pressure={0.6, 0.4}})
-- a scatter of warm windows along the ring: the dwelling, still lit
local w = brush{kind="round", width=1.3, point=0.6}
local n = 0
for i = 1, 22 do
  local a = rand(-1.45, 1.45) + ((i % 2 == 0) and math.pi or 0)
  local x, y = 408 + math.cos(a) * 21, 281 + math.sin(a) * 126
  if math.abs(y - 281) > 26 then
    if n % 6 == 0 then w:load(pile{{"lead white",1.5},{"Indian yellow",0.6},{"Mars orange",0.3}}, 0.6) end
    w:touch(x, y, {pressure=rand(0.25, 0.5)}); n = n + 1
  end
end
print(n)

--@ chunk 27
-- the old prow's hot edge, left stranded at the sail: knocked out
local z = rect(622, 266, 26, 30)
local B = brush("filbert", 4)
for i = 1, 16 do
  local y0 = rand(266, 296)
  B:reload(LADDER[1], 0.9)
  B:stroke({{650, y0}, {618, y0}}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}, orient="along", clip=z - SAIL})
end
work(z * SAIL:grow(1), {hand="detail", pile=pile{{"bone black",3},{"ultramarine blue",0.6}}, coverage=3, fill=true, angle=math.pi/2, clip=true})
