-- easel session "noli": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=0.75, linen={18,16}, seed=1818,
  ground={{pile={{"lead white",3},{"yellow ochre",0.35},{"cerulean blue",0.08}}, um=80, apply="knife", texture=0.15}}}
-- H = 1333. Sky above, corona-fog sea below ~y 620, the spire rock in the foreground.
SX, SY = 640, 520
function flow(x, y) return 0.12 * math.sin(x / 140 + y / 90) end
local bands = {
  {0, 160, {{"lead white",1.6},{"cerulean blue",0.45},{"bone black",0.06}}},
  {150, 330, {{"lead white",2.2},{"cerulean blue",0.25},{"yellow ochre",0.15}}},
  {320, 520, {{"lead white",2.8},{"yellow ochre",0.35},{"cadmium yellow",0.08}}},
  {510, 700, {{"lead white",3},{"lemon chrome",0.2},{"yellow ochre",0.2}}},
  {690, 900, {{"lead white",2.6},{"yellow ochre",0.45},{"Mars orange",0.06}}},
  {890, 1333, {{"lead white",2.2},{"yellow ochre",0.5},{"raw sienna",0.15},{"cobalt violet",0.04}}},
}
for _, b in ipairs(bands) do work(rect(0, b[1], 1000, b[2] - b[1] + 8), {hand="broad", pile=pile(b[3]), coverage=3, fill=true, clip=true, angle=flow, load=0.9}) end
blend(everywhere(), {angle=flow})

--@ chunk 2
local function S(p, w, ld, pts, pr) local b = brush{kind="filbert", width=w}; b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.55, 0.15}, ramps={0.2, 0.5}}) end
local peakP = pile{{"lead white",1.4},{"cerulean blue",0.4},{"cobalt violet",0.12},{"bone black",0.12}}
local peakF = pile{{"lead white",2},{"cerulean blue",0.3},{"cobalt violet",0.08}}
-- distant spires emerging from the corona sea, paler with distance
local function spire(x, base, h, w, p)
  work(poly({{x - w, base}, {x - w * 0.3, base - h * 0.7}, {x, base - h}, {x + w * 0.35, base - h * 0.65}, {x + w, base}}, true), {hand="detail", tool="round 3", pile=p, coverage=5, fill=true, load=1})
end
spire(170, 560, 150, 40, peakF); spire(250, 580, 90, 30, peakF); spire(820, 600, 210, 46, peakP); spire(900, 610, 120, 34, peakF); spire(560, 640, 70, 26, peakF)
-- the sail's rim, a thin silver arc rising out of the fog on the left
local arc = {} for k = 0, 24 do local a = math.rad(200 + 70 * k / 24); arc[#arc+1] = {420 + 380 * math.cos(a), 760 + 260 * math.sin(a)} end
local b = brush{kind="round", width=4, point=0.6}; b:reload(peakP, 0.8); b:stroke(arc, {pressure={0.05, 0.6}, ramps={0.4, 0.2}})
-- corona-fog streamers: long pale and warm strokes washing across the bases of the peaks
local fogW = pile{{"lead white",3},{"lemon chrome",0.15}, medium=0.2}
local fogG = pile{{"lead white",2.4},{"yellow ochre",0.4},{"Mars orange",0.06}, medium=0.2}
local fogC = pile{{"lead white",2.4},{"cerulean blue",0.2},{"cobalt violet",0.08}, medium=0.2}
for i = 1, 140 do
  local y = rand(520, 1250); local x = rand(-80, 950)
  local t = (y - 520) / 730
  local r = math.random()
  local p = (r < 0.45) and fogW or ((r < 0.8) and fogG or fogC)
  local L = rand(90, 220)
  S(p, rand(16, 30), rand(0.35, 0.55), {{x, y}, {x + L * 0.5, y - rand(4, 16)}, {x + L, y + rand(-8, 8)}})
end
blend(rect(0, 500, 1000, 833), {angle=0.05})
print(wait(5*1440))

--@ chunk 3
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.5}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.7}, ramps={0.03, 0.1}}) end
local rock = pile{{"bone black",1.6},{"bone brown",0.6},{"burnt sienna",0.3}}
local rockM = pile{{"bone black",1},{"burnt sienna",0.6},{"raw sienna",0.4},{"lead white",0.15}}
local rimP = pile{{"yellow ochre",1},{"lead white",1},{"Mars orange",0.2}}
-- the spire's summit: jagged bronze scale-plate rock rising from the bottom, peak under the wanderer's feet
ROCK = poly({{0, 1333}, {0, 1040}, {120, 1010}, {200, 960}, {290, 930}, {360, 880}, {420, 840}, {470, 826}, {540, 830}, {600, 860}, {660, 900}, {720, 920}, {800, 980}, {880, 1000}, {1000, 1060}, {1000, 1333}}, true)
W(ROCK, rock)
-- a second lower ledge at right, dark against the fog
W(poly({{720, 1333}, {760, 1120}, {840, 1080}, {940, 1100}, {1000, 1110}, {1000, 1333}}, true), rock)
print(wait(3*1440))
-- planes catching the corona from beyond: lit rims on the upper edges, mid-tone facets
for _, s in ipairs({{{200, 962}, {290, 932}, {360, 882}, {420, 842}}, {{540, 832}, {600, 862}, {660, 902}}, {{800, 982}, {880, 1002}}}) do st(rimP, s, 3.5, {0.7, 0.4}) end
for _, f in ipairs({{{260, 1000}, {340, 950}, {360, 1060}}, {{560, 900}, {640, 940}, {600, 1040}}, {{440, 880}, {500, 870}, {470, 980}}}) do W(poly(f), rockM) end
-- scale-plate arcs on the rock, a few, dark
local dk = pile{{"bone black",2}}
for k = 1, 16 do local x, y = rand(80, 900), rand(1000, 1300); local pts = {} for i = 0, 6 do local a = math.pi * i / 6; pts[#pts+1] = {x + 26 * math.cos(a), y + 8 * math.sin(a)} end; st(rockM, pts, 2, {0.5, 0.5}) end

--@ chunk 4
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.5}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.7}, ramps={0.03, 0.1}}) end
local rock = pile{{"bone black",1.6},{"bone brown",0.6},{"burnt sienna",0.3}}
local rimP = pile{{"yellow ochre",1},{"lead white",1},{"Mars orange",0.2}}
-- cover the triangles, and break the mound's outline with crags
W(poly({{240, 1000}, {370, 860}, {680, 920}, {640, 1080}, {300, 1080}}, true), rock)
W(poly({{0, 1060}, {40, 960}, {70, 1000}, {110, 900}, {150, 990}, {200, 970}, {230, 1060}}), rock)
W(poly({{720, 940}, {760, 880}, {790, 930}, {840, 860}, {880, 960}, {940, 940}, {1000, 1000}, {1000, 1080}, {720, 1080}}), rock)
W(poly({{380, 880}, {410, 800}, {440, 850}, {470, 826}, {540, 830}, {560, 800}, {600, 862}}), rock)
print(wait(3*1440))
for _, s in ipairs({{{40, 962}, {70, 1000}, {110, 902}}, {{760, 882}, {790, 930}, {840, 862}}, {{410, 802}, {440, 850}, {470, 828}, {540, 832}, {560, 802}}}) do st(rimP, s, 3, {0.7, 0.4}) end
-- the wanderer, from behind: dark coat to the knee, one foot forward on a higher crag, staff, head bare
local coat = pile{{"bone black",1.8},{"ultramarine blue",0.25},{"burnt sienna",0.15}}
local hair = pile{{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.3}}
COAT = poly({{460, 740}, {448, 640}, {456, 560}, {478, 526}, {534, 524}, {556, 560}, {562, 640}, {556, 740}}, true)
W(COAT, coat)
W(poly({{470, 740}, {490, 740}, {486, 818}, {470, 820}}) + poly({{526, 740}, {546, 740}, {566, 806}, {548, 812}}), coat)
W(ellipse(478, 822, 14, 6) + ellipse(560, 808, 14, 6), coat)
W(ellipse(506, 500, 24, 28), hair)
W(rect(498, 520, 18, 10), coat)
-- arm hanging with a staff planted down the crag
st(coat, {{460, 580}, {446, 660}, {442, 700}}, 14)
st(pile{{"bone brown",1},{"bone black",0.6}}, {{438, 690}, {420, 840}}, 4)
-- the crimson rag lifting from the shoulder in the wind, the only saturated mark
local red = pile{{"cadmium red",1},{"vermilion",0.5}}
local rb = brush{kind="filbert", width=12}; rb:reload(red, 0.9); rb:stroke({{540, 540}, {580, 528}, {620, 536}, {650, 524}}, {pressure={0.85, 0.1}, ramps={0.05, 0.6}})
rb:reload(red, 0.9); rb:stroke({{548, 552}, {590, 556}, {626, 562}}, {pressure={0.7, 0.05}, ramps={0.05, 0.7}})
-- the corona's light catching his outline: a thin warm rim on the shoulders and head
st(rimP, {{482, 476}, {506, 470}, {528, 484}}, 2.4, {0.6, 0.3})
st(rimP, {{480, 528}, {534, 526}, {552, 548}}, 2.4, {0.6, 0.3})

--@ chunk 5
print(wait(4*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=6, fill=true, load=1}) end
local rock = pile{{"bone black",1.8},{"bone brown",0.5},{"burnt sienna",0.25}}
W(poly({{250, 900}, {360, 860}, {660, 900}, {680, 1080}, {270, 1080}}, true) - poly({{470, 740}, {490, 740}, {486, 830}, {470, 830}}) - poly({{526, 740}, {546, 740}, {576, 820}, {546, 820}}), rock)
-- helm: steel, a rounded crest, a lit rim toward the light
local steel = pile{{"bone black",1.2},{"ultramarine ash",0.6},{"lead white",0.35}}
W(ellipse(506, 498, 25, 29), steel, "round 2")
local b = brush{kind="round", width=5, point=0.3}; b:reload(steel, 0.9); b:stroke({{506, 466}, {508, 486}}, {pressure={0.7, 0.6}})
local r = brush{kind="round", width=2.4, point=0.5}; r:reload(pile{{"yellow ochre",1},{"lead white",1.2},{"Mars orange",0.15}}, 0.9)
r:stroke({{486, 482}, {500, 470}, {520, 474}, {530, 492}}, {pressure={0.6, 0.3}, ramps={0.05, 0.4}})
-- pauldron edges on the coat
local p = pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.4}}
local pb = brush{kind="round", width=3, point=0.4}
pb:reload(p, 0.85); pb:stroke({{458, 560}, {478, 540}, {500, 538}}, {pressure={0.6, 0.5}})
pb:reload(p, 0.85); pb:stroke({{514, 538}, {536, 540}, {556, 560}}, {pressure={0.6, 0.5}})
