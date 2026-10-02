-- easel session "wanderer2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=790, aspect=0.79, linen={18,16}, seed=1818, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"raw sienna",3},{"Mars brown",2},{"lead white",3},{"ultramarine blue",0.5}}, um=30, apply="brush"}}}
function hz(x) return 655 + 0.00022*(x-470)^2 end
HULL = below(hz)
SKY = -HULL
SUN = {x=540, y=600, r=330}
local function d(x,y) return math.sqrt((x-SUN.x)^2 + (y-SUN.y)^2) end
local bands = {
 {0, 140, pile{{"lead white",3},{"lemon chrome",0.25},{"zinc white",1}}},
 {140, 230, pile{{"lead white",2},{"lemon chrome",0.6},{"cadmium yellow",0.4}}},
 {230, 300, pile{{"cadmium yellow",1},{"lead white",1.2},{"Indian yellow",0.3}}},
 {300, 345, pile{{"cadmium yellow",1},{"chrome yellow",0.6},{"Mars orange",0.5},{"lead white",0.4}}},
 {345, 430, pile{{"Mars orange",1},{"vermilion",0.4},{"raw sienna",0.6},{"lead white",0.2}}},
 {430, 540, pile{{"burnt sienna",1},{"Mars red",0.5},{"raw sienna",0.4},{"bone black",0.2}}},
 {540, 680, pile{{"burnt sienna",1},{"bone black",0.8},{"Mars red",0.3},{"ultramarine blue",0.3}}},
 {680, 2000, pile{{"bone black",1.5},{"ultramarine blue",0.8},{"burnt sienna",0.6},{"magenta",0.15}}},
}
for _, b in ipairs(bands) do
  local m = SKY * mask(function(x,y) local v = d(x,y); return smoothstep(b[1]-10, b[1]+10, v) * (1 - smoothstep(b[2]-10, b[2]+10, v)) end)
  work(m, {hand="body", pile=b[3], coverage=4, fill=true, clip=SKY, angle=function(x,y) return math.atan(y-SUN.y, x-SUN.x) + math.pi/2 end, tool="filbert 8", length={30,90}, load=1, pressure={0.7,0.95}, threshold=0.3})
end
-- hull: bronze, hot toward the horizon under the Sun, darker toward us
local H1 = pile{{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.3}}
local H2 = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.4}}
local H3 = pile{{"Mars orange",1},{"raw sienna",0.8},{"burnt sienna",0.5},{"lead white",0.3}}
local H4 = pile{{"cadmium yellow",1},{"Mars orange",0.7},{"lead white",1}}
local function dy(x,y) return y - hz(x) end
local hb = {{-20,25,H4},{25,90,H3},{90,230,H2},{230,900,H1}}
for _, b in ipairs(hb) do
  local m = HULL * mask(function(x,y) local v = dy(x,y) + 0.15*math.abs(x-540); return smoothstep(b[1]-10, b[1]+10, v) * (1 - smoothstep(b[2]-10, b[2]+10, v)) end)
  work(m, {hand="body", pile=b[3], coverage=4, fill=true, clip=HULL, angle=0.02, tool="filbert 8", length={30,90}, load=1, pressure={0.7,0.95}, threshold=0.3})
end

--@ chunk 2
local K = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
-- carapace, torso, helm: one dark silhouette
local car = ellipse(490, 660, 125, 52)
local tor = poly({{462,640},{456,560},{470,528},{510,524},{526,560},{520,640}}, true)
local helm = ellipse(491, 498, 19, 24)
BODY = car + tor + helm
work(BODY, {hand="body", pile=K, coverage=5, fill=true, clip=true, angle=0.3, tool="filbert 6", length={15,40}, load=1})
-- legs: jointed, splayed, too many
local lb = brush{kind="round", width=7, point=0.3}
LEGS = {}
local legs = {
 {{380,668},{318,640},{300,760},{292,822}},
 {{410,690},{360,700},{352,790},{346,846}},
 {{445,700},{420,742},{418,812},{412,866}},
 {{475,706},{468,760},{472,830},{466,880}},
 {{510,706},{522,762},{524,828},{528,874}},
 {{545,700},{580,744},{586,808},{594,858}},
 {{575,690},{630,706},{646,780},{656,836}},
 {{605,668},{676,642},{700,750},{714,810}},
}
for _, L in ipairs(legs) do
  lb:load(K, 1); lb:stroke({L[1], L[2]}, {pressure={0.9,0.8}, ramps={0.02,0.02}, shake=0})
  lb:load(K, 1); lb:stroke({L[2], L[3]}, {pressure={0.8,0.7}, ramps={0.02,0.02}, shake=0})
  lb:load(K, 1); lb:stroke({L[3], L[4]}, {pressure={0.7,0.3}, ramps={0.02,0.3}, shake=0})
end
LEGPTS = legs
-- antlers: sensor masts branching up into the disc, from helm and carapace
local ab = brush{kind="round", width=4.5, point=0.9}
local function antler(x, y, ang, len, depth)
  local x2, y2 = x + math.cos(ang)*len, y + math.sin(ang)*len
  ab:load(K, 1); ab:stroke({{x, y}, {x2, y2}}, {pressure={0.55 + depth*0.12, 0.25 + depth*0.1}, ramps={0.02, 0.3}, shake=0.3})
  if depth > 0 then
    antler(x2, y2, ang - rand(0.3, 0.6), len*rand(0.55, 0.75), depth - 1)
    antler(x2, y2, ang + rand(0.3, 0.6), len*rand(0.55, 0.75), depth - 1)
  end
end
antler(482, 478, -1.85, 70, 2)
antler(500, 478, -1.25, 75, 2)
antler(420, 625, -2.2, 80, 2)
antler(570, 622, -0.95, 85, 2)
antler(455, 618, -1.75, 95, 2)
antler(535, 615, -1.4, 100, 2)

--@ chunk 3
print(wait(3*24*60))
local function T(x,y) return 490+(x-490)*1.5, 880+(y-880)*1.5 end
local K = pile{{"bone black",2.5},{"ultramarine blue",0.5},{"Mars brown",0.4}}
-- carapace, torso, helm: one dark silhouette
local car = ellipse(490, 550, 188, 78)
local tor = poly({{448,520},{439,400},{460,352},{520,346},{544,400},{535,520}}, true)
local helm = ellipse(491, 307, 28, 36)
BODY = car + tor + helm
work(BODY, {hand="body", pile=K, coverage=6, fill=true, clip=true, angle=0.3, pressure={0.8,1}, tool="filbert 6", length={15,40}, load=1})
-- legs: jointed, splayed, too many
local lb = brush{kind="round", width=11, point=0.3}
LEGS = {}
local legs = {
 {{380,668},{318,640},{300,760},{292,822}},
 {{410,690},{360,700},{352,790},{346,846}},
 {{445,700},{420,742},{418,812},{412,866}},
 {{475,706},{468,760},{472,830},{466,880}},
 {{510,706},{522,762},{524,828},{528,874}},
 {{545,700},{580,744},{586,808},{594,858}},
 {{575,690},{630,706},{646,780},{656,836}},
 {{605,668},{676,642},{700,750},{714,810}},
}
for i, L in ipairs(legs) do for j = 1, 4 do local x, y = T(L[j][1], L[j][2]); L[j] = {x, y} end end
for _, L in ipairs(legs) do
  lb:load(K, 1); lb:stroke({L[1], L[2]}, {pressure={0.9,0.8}, ramps={0.02,0.02}, shake=0})
  lb:load(K, 1); lb:stroke({L[2], L[3]}, {pressure={0.8,0.7}, ramps={0.02,0.02}, shake=0})
  lb:load(K, 1); lb:stroke({L[3], L[4]}, {pressure={0.7,0.3}, ramps={0.02,0.3}, shake=0})
end
LEGPTS = legs
-- antlers: sensor masts branching up into the disc, from helm and carapace
local ab = brush{kind="round", width=6.5, point=0.9}
local function antler(x, y, ang, len, depth)
  local x2, y2 = x + math.cos(ang)*len, y + math.sin(ang)*len
  ab:load(K, 1); ab:stroke({{x, y}, {x2, y2}}, {pressure={0.55 + depth*0.12, 0.25 + depth*0.1}, ramps={0.02, 0.3}, shake=0.3})
  if depth > 0 then
    antler(x2, y2, ang - rand(0.3, 0.6), len*rand(0.55, 0.75), depth - 1)
    antler(x2, y2, ang + rand(0.3, 0.6), len*rand(0.55, 0.75), depth - 1)
  end
end
antler(480, 278, -1.85, 95, 2)
antler(503, 278, -1.25, 100, 2)
antler(370, 510, -2.3, 120, 2)
antler(610, 505, -0.85, 125, 2)
antler(425, 495, -1.9, 140, 2)
antler(560, 490, -1.25, 145, 2)
antler(520, 480, -1.55, 150, 1)

--@ chunk 4
local K = pile{{"bone black",2.5},{"ultramarine blue",0.5},{"Mars brown",0.4}}
-- the old small carapace becomes the slung graft: a dark cage with cold tissue showing through
local graft = ellipse(490, 664, 128, 56)
work(graft, {hand="body", pile=K, coverage=6, fill=true, clip=true, angle=0, tool="filbert 6", load=1, pressure={0.8,1}})
local V1 = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"magenta",0.3},{"bone black",0.3}}
local V2 = pile{{"cobalt violet",1},{"zinc white",0.6},{"cerulean blue",0.3}}
local tissue = ellipse(492, 668, 96, 34)
work(tissue, {hand="body", pile=V1, coverage=4, fill=true, clip=true, angle=0.4, tool="filbert 4", load=1})
work(ellipse(492, 662, 70, 18), {hand="scumble", pile=V2, coverage=1.5, clip=tissue, tool="filbert 3", load=0.5})
-- cage bars over it
local cb = brush{kind="round", width=4, point=0.3}
for x = 405, 585, 22 do cb:load(K, 1); cb:stroke({{x, 630}, {x + 3, 700}}, {pressure={0.8,0.8}, ramps={0.02,0.02}, shake=0, clip=graft}) end
-- eyes, pale and cold, between the bars
local EY = pile{{"zinc white",3},{"cerulean blue",0.4}}
local PU = pile{{"bone black",2}}
for _, e in ipairs({{427,664},{470,676},{514,660},{559,672},{448,650},{537,686}}) do
  local t = brush{kind="round", width=6, point=0.2}
  t:load(EY, 1); t:touch(e[1], e[2], {pressure=0.6})
  local p = brush{kind="round", width=2.4, point=0.2}
  p:load(PU, 1); p:touch(e[1] + 0.5, e[2], {pressure=0.6})
end
-- a rag of the crimson capelet still caught on the old shoulders, bone cross worn to a ghost
local CR = pile{{"cadmium red",1},{"Mars red",1},{"bone black",0.3}}
local CRd = pile{{"Mars red",1},{"bone black",0.6},{"rose madder",0.3}}
local rag = poly({{446,372},{470,350},{518,348},{540,372},{534,420},{522,440},{512,426},{500,452},{488,428},{474,446},{462,420},{452,430}}, true)
work(rag, {hand="body", pile=CR, coverage=5, fill=true, clip=true, angle=1.5, tool="filbert 4", load=1})
work(rag * rect(430, 400, 120, 60), {hand="body", pile=CRd, coverage=2.5, clip=rag, angle=1.5, tool="filbert 3", edge="soft"})
local BONE = pile{{"lead white",2},{"yellow ochre",0.8},{"raw sienna",0.4}}
local fl = brush{kind="flat", width=3}
fl:load(BONE, 0.35); fl:stroke({{493,372},{493,404}}, {pressure={0.5,0.4}, orient="across"})
fl:load(BONE, 0.3); fl:stroke({{482,382},{504,382}}, {pressure={0.45,0.4}, orient="across"})

--@ chunk 5
print(wait(3*24*60))
local SH = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3}}
local K = pile{{"bone black",2.5},{"ultramarine blue",0.5},{"Mars brown",0.4}}
-- too many long shadows raking toward us, one per leg, plus the body's
local sb = brush{kind="filbert", width=12}
for _, L in ipairs(LEGPTS) do
  local f = L[4]
  local dx, dy = f[1] - 540, f[2] - 560
  local n = math.sqrt(dx*dx + dy*dy)
  local t = (1266 - f[2]) / (dy/n)
  local e = {f[1] + dx/n*t, 1270}
  sb:load(SH, 1)
  sb:stroke({f, {lerp(f[1], e[1], 0.5), lerp(f[2], e[2], 0.5)}, e}, {pressure={0.45, 1}, ramps={0.05, 0.05}, shake=0.3, orient="across"})
  sb:load(SH, 1)
  sb:stroke({{lerp(f[1], e[1], 0.45), lerp(f[2], e[2], 0.45)}, e}, {pressure={0.8, 1}, ramps={0.05, 0.02}, shake=0.3, orient="across"})
end
-- crimson rag restated, darker
local CR = pile{{"Mars red",1},{"cadmium red",0.6},{"bone black",0.35},{"rose madder",0.2}}
local rag = poly({{446,372},{470,350},{518,348},{540,372},{534,420},{522,440},{512,426},{500,452},{488,428},{474,446},{462,420},{452,430}}, true)
work(rag, {hand="body", pile=CR, coverage=5, fill=true, clip=true, angle=1.5, tool="filbert 4", load=1})
-- warm rim of the Sun along the top edges
local RIM = pile{{"lead white",2.5},{"cadmium yellow",0.6},{"Mars orange",0.2}}
local r = brush{kind="round", width=2.6, point=0.8}
local rims = {
 {{310,540},{360,500},{430,478},{490,472},{550,476},{620,494},{668,530}},
 {{475,278},{482,272},{491,271},{500,274},{507,282}},
 {{442,400},{448,362},{462,350}},
 {{520,348},{534,362},{544,396}},
}
for _, p in ipairs(rims) do r:load(RIM, 0.9); r:stroke(p, {pressure={0.3, 0.45}, ramps={0.2, 0.3}}) end
-- the old helm's cross visor, cold blue, leaking light round the helm's edge
local CB = pile{{"zinc white",2},{"cerulean blue",1.2},{"cobalt blue",0.3}}
r:load(CB, 0.9); r:stroke({{468,296},{470,312},{474,326}}, {pressure={0.3,0.25}, ramps={0.2,0.4}})
r:load(CB, 0.9); r:stroke({{514,296},{512,312},{508,326}}, {pressure={0.3,0.25}, ramps={0.2,0.4}})

--@ chunk 6
local DK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}}
local LH = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.4}}
local LM2 = pile{{"Mars orange",1},{"raw sienna",0.6},{"lead white",0.6}}
local NOT = ellipse(490, 600, 210, 120) + ellipse(490, 664, 132, 60)
local CL = HULL - NOT
local off = 6
while off < 620 do
  local wb = 8 + off * 0.42
  local x = -20 - rand(0, wb)
  while x < 1020 do
    local w = wb * rand(0.7, 1.35)
    local y0 = hz(x + w/2) + off + randn(0, 1 + off*0.02)
    local sag = w * rand(0.18, 0.3)
    local arc, lit = {}, {}
    for k = 0, 6 do local u = k/6; arc[#arc+1] = {x + w*u, y0 + sag*math.sin(math.pi*u)} end
    for k = 1, 5 do local u = k/6; lit[#lit+1] = {x + w*u, y0 - 1.5 - off*0.008 + sag*math.sin(math.pi*u)} end
    local d = brush{kind="round", width=1.6 + off*0.01, point=0.5}
    d:load(DK, 0.8); d:stroke(arc, {pressure={0.45, 0.45}, ramps={0.2, 0.2}, clip=CL})
    local hot = 1 - clamp(math.abs(x - 540)/500, 0, 1) * 0.7 - clamp(off/600, 0, 1)*0.5
    local l = brush{kind="round", width=1.5 + off*0.006, point=0.8}
    l:load(hot > 0.6 and LH or LM2, 0.3 + 0.5*clamp(hot, 0, 1))
    l:stroke(lit, {pressure={0.2, 0.35}, ramps={0.3, 0.3}, clip=CL})
    x = x + w * rand(0.85, 1.05)
  end
  off = off + 4 + off * rand(0.18, 0.28)
end

--@ chunk 7
print(wait(4*24*60))
local K = pile{{"bone black",2.5},{"ultramarine blue",0.5},{"Mars brown",0.4}}
local EY = pile{{"zinc white",3},{"cerulean blue",0.5}}
local PU = pile{{"bone black",2}}
local cb = brush{kind="round", width=3.5, point=0.3}
for x = 412, 575, 24 do cb:load(K, 1); cb:stroke({{x, 642}, {x + 2, 696}}, {pressure={0.8,0.8}, ramps={0.02,0.02}, shake=0}) end
for _, e in ipairs({{424,668},{470,678},{512,660},{558,672},{447,654},{536,688}}) do
  local t = brush{kind="round", width=7, point=0.2}
  t:load(EY, 1); t:touch(e[1], e[2], {pressure=0.7})
  local p = brush{kind="round", width=3, point=0.2}
  p:load(PU, 1); p:touch(e[1] + 0.5, e[2], {pressure=0.6})
end
local RIM = pile{{"lead white",3},{"cadmium yellow",0.5}}
local r = brush{kind="round", width=3.2, point=0.8}
local rims = {
 {{310,540},{360,500},{430,478},{490,472},{550,476},{620,494},{668,530}},
 {{473,282},{482,273},{491,271},{500,274},{509,284}},
}
for _, p in ipairs(rims) do r:load(RIM, 1); r:stroke(p, {pressure={0.35, 0.5}, ramps={0.2, 0.3}}) end
local CB = pile{{"zinc white",2},{"cerulean blue",1.3}}
local c = brush{kind="round", width=2.6, point=0.8}
c:load(CB, 1); c:stroke({{466,298},{468,314},{472,330}}, {pressure={0.4,0.3}, ramps={0.2,0.4}})
c:load(CB, 1); c:stroke({{516,298},{514,314},{510,330}}, {pressure={0.4,0.3}, ramps={0.2,0.4}})
