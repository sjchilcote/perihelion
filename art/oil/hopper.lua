-- easel session "hopper": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=1942,
  ground={{pile={{"bone black",2},{"viridian",0.4},{"ultramarine blue",0.3},{"lead white",0.3}}, um=80, apply="knife", texture=0.2}}}
-- geometry (H = 562)
WIN = poly({{340, 150}, {1000, 104}, {1000, 404}, {340, 372}})
CEIL = poly({{340, 150}, {1000, 104}, {1000, 150}, {340, 182}})
BACKW = poly({{340, 182}, {1000, 150}, {1000, 300}, {340, 300}})
CTOP = poly({{340, 300}, {1000, 300}, {1000, 318}, {340, 312}})
CFRONT = poly({{340, 312}, {1000, 318}, {1000, 404}, {340, 372}})
SPILL = poly({{340, 378}, {1000, 410}, {1000, 562}, {170, 562}})
PORT = ellipse(150, 230, 72, 72)
local wallD = pile{{"bone black",2},{"viridian",0.5},{"ultramarine blue",0.3},{"lead white",0.2}}
local floorD = pile{{"bone black",2},{"bone brown",0.6},{"viridian",0.2},{"lead white",0.1}}
local ceil = pile{{"lead white",3},{"lemon chrome",0.4}}
local back = pile{{"lead white",1.6},{"viridian",0.5},{"yellow ochre",0.8},{"bone black",0.1}}
local ctop = pile{{"lead white",2},{"yellow ochre",0.6},{"bone black",0.15}}
local cfront = pile{{"burnt sienna",1},{"Mars red",0.4},{"bone black",0.6},{"lead white",0.2}}
local spill = pile{{"yellow ochre",1},{"viridian",0.35},{"bone black",0.8},{"lead white",0.6}}
work(rect(0, 0, 1000, 380) - WIN - PORT - rect(0, 380, 1000, 200), {hand="body", pile=wallD, coverage=3, fill=true, clip=true, angle=math.pi/2, load=1})
work(rect(0, 372, 1000, 190) - WIN - SPILL, {hand="body", pile=floorD, coverage=3, fill=true, clip=true, angle=0, load=1})
work(SPILL, {hand="body", pile=spill, coverage=3, fill=true, clip=true, angle=0, load=1})
work(CEIL, {hand="detail", tool="round 3", pile=ceil, coverage=4, fill=true, load=1})
work(BACKW, {hand="body", tool="filbert 8", pile=back, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(CTOP, {hand="detail", tool="round 3", pile=ctop, coverage=4, fill=true, load=1})
work(CFRONT, {hand="body", tool="filbert 8", pile=cfront, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(PORT, {hand="detail", tool="round 3", pile=pile{{"bone black",2},{"ultramarine blue",0.3}}, coverage=4, fill=true, load=1})
print(wait(5*1440))

--@ chunk 2
local navy = pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.25}}
local navyL = pile{{"ultramarine blue",1},{"cerulean blue",0.3},{"lead white",0.8},{"yellow ochre",0.1}}
local skin = pile{{"lead white",1.5},{"yellow ochre",0.6},{"burnt sienna",0.25},{"rose madder",0.1}}
local skinS = pile{{"burnt sienna",0.6},{"yellow ochre",0.6},{"lead white",0.6},{"bone black",0.2}}
local hairD = pile{{"bone brown",1},{"bone black",0.5}}
local hairR = pile{{"burnt sienna",1},{"Mars orange",0.3},{"bone brown",0.4}}
local steel = pile{{"lead white",1.4},{"bone black",0.6},{"ultramarine ash",0.3}}
local steelD = pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.3}}
local frame = pile{{"bone black",2},{"viridian",0.3},{"lead white",0.15}}
local tube = pile{{"zinc white",3},{"lemon chrome",0.15}}
-- fluorescent tubes along the ceiling
local tb = brush{kind="round", width=4, point=0.2}
for _, s in ipairs({{350, 175, 540, 165}, {580, 163, 780, 153}, {820, 151, 1000, 143}}) do tb:reload(tube, 1); tb:stroke({{s[1], s[2]}, {s[3], s[4]}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}}) end
-- dispenser on the back wall, behind the counter; a stack of trays on the counter
work(poly({{895, 200}, {955, 197}, {955, 292}, {895, 294}}), {hand="detail", tool="round 2", pile=steel, coverage=4.5, fill=true, load=1})
work(poly({{897, 210}, {953, 207}, {953, 230}, {897, 232}}), {hand="detail", tool="round 1.6", pile=steelD, coverage=4.5, fill=true, load=1})
work(rect(917, 262, 14, 22), {hand="detail", tool="round 1.4", pile=steelD, coverage=4.5, fill=true, load=1})
for k = 0, 6 do work(poly({{712, 298 - k * 2.6}, {770, 298 - k * 2.6}, {768, 296 - k * 2.6}, {714, 296 - k * 2.6}}), {hand="detail", tool="round 1.2", pile=(k % 2 == 0) and steel or pile{{"cadmium yellow",0.4},{"lead white",1.5},{"yellow ochre",0.4}}, coverage=4.5, fill=true, load=1}) end
-- figure 3, behind the counter: standing, turned away toward the dispenser
work(poly({{828, 230}, {868, 226}, {876, 300}, {822, 300}}, true), {hand="detail", tool="round 2", pile=navy, coverage=4.5, fill=true, load=1})
work(ellipse(846, 212, 12, 14), {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
work(ellipse(844, 205, 12, 9) * above(function(x) return 210 end), {hand="detail", tool="round 1.4", pile=hairD, coverage=4.5, fill=true, load=1})
-- figure 1, on our side, hunched over a mug
work(poly({{448, 262}, {470, 240}, {500, 238}, {520, 258}, {528, 300}, {448, 302}}, true), {hand="detail", tool="round 2", pile=navy, coverage=4.5, fill=true, load=1})
work(ellipse(506, 246, 12, 13), {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
work(ellipse(500, 240, 13, 10) * above(function(x) return 246 end), {hand="detail", tool="round 1.4", pile=hairD, coverage=4.5, fill=true, load=1})
work(poly({{510, 286}, {534, 288}, {534, 300}, {510, 300}}), {hand="detail", tool="round 1.6", pile=navy, coverage=4.5, fill=true, load=1})
work(rect(536, 284, 11, 16), {hand="detail", tool="round 1.2", pile=pile{{"lead white",2.4},{"yellow ochre",0.2}}, coverage=4.5, fill=true, load=1})
-- figure 2, upright, head turned the other way, toward the window's dark end
work(poly({{612, 232}, {646, 228}, {662, 244}, {664, 300}, {606, 300}, {604, 250}}, true), {hand="detail", tool="round 2", pile=navy, coverage=4.5, fill=true, load=1})
work(ellipse(630, 212, 11, 14), {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
work(ellipse(632, 204, 12, 9) * above(function(x) return 209 end) + ellipse(637, 212, 7, 11) * rect(630, 200, 20, 22), {hand="detail", tool="round 1.4", pile=hairR, coverage=4.5, fill=true, load=1})
work(rect(580, 286, 10, 14), {hand="detail", tool="round 1.2", pile=pile{{"lead white",2.4},{"yellow ochre",0.2}}, coverage=4.5, fill=true, load=1})
-- stools: chrome posts on our side under the counter top, seen through the lower glass
for _, x in ipairs({488, 634}) do work(rect(x - 3, 312, 6, 46), {hand="detail", tool="round 1.4", pile=steel, coverage=4.5, fill=true, load=1}) end
print(wait(3*1440))
-- window frame: top rail, mullions, sill
local fb = brush{kind="round", width=8, point=0.1}
for _, s in ipairs({{{340, 148}, {1000, 102}}, {{340, 374}, {1000, 406}}, {{340, 148}, {340, 374}}, {{600, 130}, {600, 386}}, {{860, 112}, {860, 398}}}) do fb:reload(frame, 1); fb:stroke(s, {pressure={0.8, 0.8}, ramps={0.02, 0.02}}) end
local hb = brush{kind="round", width=2, point=0.4}
hb:reload(pile{{"lead white",2},{"yellow ochre",0.3},{"viridian",0.15}}, 0.8); hb:stroke({{336, 378}, {1000, 410}}, {pressure={0.6, 0.6}})
-- light on the figures: the lamp is above the counter, so shoulders and tops of heads catch it
local function st(p, pts, w) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.8); b:stroke(pts, {pressure={0.55, 0.4}, ramps={0.1, 0.3}}) end
st(navyL, {{452, 262}, {472, 242}, {500, 240}}, 3); st(navyL, {{610, 248}, {618, 234}, {646, 230}}, 3); st(navyL, {{830, 232}, {866, 228}}, 3)
st(skinS, {{500, 252}, {506, 258}, {514, 254}}, 2); st(skinS, {{622, 214}, {622, 222}}, 2); st(skinS, {{838, 214}, {840, 222}}, 2)

--@ chunk 3
local back = pile{{"lead white",1.6},{"viridian",0.5},{"yellow ochre",0.8},{"bone black",0.1}}
local navy = pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.25}}
local navyL = pile{{"ultramarine blue",1},{"cerulean blue",0.3},{"lead white",0.8},{"yellow ochre",0.1}}
local skin = pile{{"lead white",1.5},{"yellow ochre",0.6},{"burnt sienna",0.25},{"rose madder",0.1}}
local hairD = pile{{"bone brown",1},{"bone black",0.5}}
local frame = pile{{"bone black",2},{"viridian",0.3},{"lead white",0.15}}
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
-- move the server clear of the mullion
work(poly({{816, 196}, {880, 196}, {880, 300}, {816, 300}}) - rect(855, 100, 10, 300), {hand="detail", tool="round 2.5", pile=back, coverage=4.5, fill=true, load=1})
work(poly({{790, 236}, {800, 228}, {820, 226}, {832, 236}, {836, 300}, {786, 300}}, true), {hand="detail", tool="round 2", pile=navy, coverage=4.5, fill=true, load=1})
work(ellipse(812, 211, 11, 14), {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
work(ellipse(812, 204, 12, 9) * above(function(x) return 209 end) + ellipse(818, 212, 6, 10) * rect(812, 200, 14, 20), {hand="detail", tool="round 1.4", pile=hairD, coverage=4.5, fill=true, load=1})
st(navy, {{832, 244}, {846, 262}, {862, 270}}, 9)   -- arm reaching toward the dispenser
st(skin, {{862, 270}, {870, 270}}, 6)
st(navyL, {{792, 238}, {800, 230}, {820, 228}}, 3)
st(frame, {{860, 112}, {860, 398}}, 8)
-- arms and necks for the two on our side
st(navy, {{520, 262}, {530, 282}, {540, 292}}, 11)
st(skin, {{540, 293}, {546, 291}}, 6)
st(navy, {{656, 250}, {664, 278}, {650, 294}, {612, 296}}, 10)
st(skin, {{612, 296}, {600, 295}}, 6)
st(skin, {{628, 224}, {630, 232}}, 7)
-- collars, a pale band at the neck
st(navyL, {{620, 232}, {634, 234}, {646, 230}}, 2.5)
st(navyL, {{494, 258}, {506, 262}, {516, 258}}, 2.5)
-- the hunched one's spine, curved
st(pile{{"ultramarine blue",1},{"bone black",1.2}}, {{462, 300}, {460, 276}, {476, 252}, {496, 244}}, 2)
-- a coffee urn on the back wall between the tubes
work(poly({{690, 220}, {722, 220}, {726, 292}, {686, 292}}, true), {hand="detail", tool="round 1.6", pile=pile{{"lead white",1.6},{"bone black",0.5},{"yellow ochre",0.3}}, coverage=4.5, fill=true, load=1})
st(pile{{"lead white",3}}, {{694, 226}, {694, 286}}, 2, {0.5, 0.4})
-- the viewport: steel rim, black space, a faint bronze arc and a few stars
local ring = {} for k = 0, 48 do local a = k * math.pi / 24; ring[#ring+1] = {150 + 74 * math.cos(a), 230 + 74 * math.sin(a)} end
st(pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.6}}, ring, 5)
local arc = {} for k = 0, 30 do local a = math.rad(200 + 120 * k / 30); arc[#arc+1] = {170 + 110 * math.cos(a), 330 + 110 * math.sin(a)} end
local b = brush{kind="round", width=3, point=0.6}
b:reload(pile{{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.6},{"bone black",0.3}}, 0.7); b:stroke(arc, {pressure={0.1, 0.55}, swell={0.3, 1, 1, 0.4}, ramps={0.3, 0.3}, clip=PORT:shrink(4)})
for _, p in ipairs({{118, 190}, {160, 178}, {186, 210}, {130, 228}, {176, 252}}) do local s = brush{kind="round", width=1.6, point=0.8}; s:reload(pile{{"zinc white",3}}, 0.5); s:touch(p[1], p[2], {pressure=0.35}) end
print(wait(3*1440))
-- the floor: dark toward us and the left, grating lines, mullion shadows thrown out across the light
local darkF = pile{{"bone black",1.6},{"viridian",0.3},{"bone brown",0.4},{"lead white",0.25}}
work(poly({{170, 562}, {400, 562}, {330, 470}, {300, 420}}) * SPILL, {hand="body", tool="filbert 8", pile=darkF, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(rect(0, 520, 1000, 42) * SPILL, {hand="body", tool="filbert 8", pile=darkF, coverage=3, fill=true, clip=true, angle=0, load=1})
for _, s in ipairs({{594, 606, 520, 566}, {854, 866, 820, 870}}) do
  work(poly({{s[1], 388}, {s[2], 388}, {s[4], 562}, {s[3], 562}}) * SPILL, {hand="detail", tool="round 3", pile=darkF, coverage=4.5, fill=true, load=1})
end
local g = brush{kind="round", width=1.6, point=0.5}
local gl = pile{{"bone black",1.4},{"viridian",0.2},{"bone brown",0.4}}
for k = 0, 9 do local y = 392 + k * k * 1.9 + k * 3; g:reload(gl, 0.6); g:stroke({{0, y + 30}, {1000, y + 8}}, {pressure={0.45, 0.45}, clip=SPILL}) end
for x0 = 200, 1200, 40 do g:reload(gl, 0.6); g:stroke({{340 + (x0 - 340) * 0.25, 380}, {x0, 562}}, {pressure={0.35, 0.45}, clip=SPILL}) end

--@ chunk 4
local back = pile{{"lead white",1.6},{"viridian",0.5},{"yellow ochre",0.8},{"bone black",0.1}}
local navy = pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.25}}
local navyL = pile{{"ultramarine blue",1},{"cerulean blue",0.3},{"lead white",0.8},{"yellow ochre",0.1}}
local skin = pile{{"lead white",1.5},{"yellow ochre",0.6},{"burnt sienna",0.25},{"rose madder",0.1}}
local steelM = pile{{"lead white",1},{"bone black",0.8},{"ultramarine ash",0.3},{"yellow ochre",0.2}}
local steelD = pile{{"bone black",1.4},{"ultramarine ash",0.4},{"lead white",0.2}}
local frame = pile{{"bone black",2},{"viridian",0.3},{"lead white",0.15}}
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
-- clean the back wall round the server and the urn
work(rect(778, 192, 76, 106) - poly({{790, 236}, {800, 228}, {820, 226}, {832, 236}, {836, 300}, {786, 300}}, true) - ellipse(812, 211, 13, 16), {hand="detail", tool="round 2.5", pile=back, coverage=4.5, fill=true, load=1})
work(rect(680, 205, 54, 92), {hand="detail", tool="round 2.5", pile=back, coverage=4.5, fill=true, load=1})
work(rect(782, 300, 96, 8), {hand="detail", tool="round 2", pile=pile{{"lead white",2},{"yellow ochre",0.6},{"bone black",0.15}}, coverage=4.5, fill=true, load=1})
print(wait(3*1440))
-- the server, opaque, reaching to the dispenser with his right arm
work(poly({{790, 236}, {800, 228}, {820, 226}, {832, 236}, {836, 300}, {786, 300}}, true), {hand="detail", tool="round 2", pile=navy, coverage=5, fill=true, load=1})
st(navy, {{830, 240}, {850, 254}, {878, 258}, {893, 256}}, 9)
st(skin, {{893, 256}, {899, 255}}, 6)
st(navyL, {{792, 238}, {800, 230}, {820, 228}, {830, 236}}, 3)
-- the urn: a steel cylinder with a dark band, a spigot and a highlight
work(poly({{690, 222}, {722, 222}, {724, 292}, {688, 292}}, true), {hand="detail", tool="round 1.6", pile=steelM, coverage=5, fill=true, load=1})
work(rect(688, 240, 36, 7), {hand="detail", tool="round 1.4", pile=steelD, coverage=5, fill=true, load=1})
st(steelD, {{706, 274}, {706, 284}, {712, 284}}, 3)
st(pile{{"lead white",3}}, {{694, 226}, {694, 288}}, 2, {0.55, 0.45})
st(steelD, {{686, 292}, {726, 292}}, 3)
-- lose the hard upper edge of the dark floor band
stipple(rect(0, 500, 1000, 26) * SPILL, {pile=pile{{"bone black",1.6},{"viridian",0.3},{"bone brown",0.4},{"lead white",0.25}}, width=4, coverage=1.6, feather=0.7, pressure={0.4, 0.8}})

--@ chunk 5
print(wait(2*1440))
local back = pile{{"lead white",1.6},{"viridian",0.5},{"yellow ochre",0.8},{"bone black",0.1}}
local navy = pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.25}}
local navyL = pile{{"ultramarine blue",1},{"cerulean blue",0.3},{"lead white",0.8},{"yellow ochre",0.1}}
local navyD = pile{{"ultramarine blue",1},{"bone black",1.3}}
local skin = pile{{"lead white",1.5},{"yellow ochre",0.6},{"burnt sienna",0.25},{"rose madder",0.1}}
local skinS = pile{{"burnt sienna",0.6},{"yellow ochre",0.6},{"lead white",0.6},{"bone black",0.2}}
local hairD = pile{{"bone brown",1},{"bone black",0.5}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 1.8", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
-- figure 2: square shoulders, a tapered back down to the counter
W(poly({{602, 268}, {612, 268}, {614, 300}, {600, 300}}) + poly({{658, 268}, {668, 268}, {670, 300}, {656, 300}}), back)
W(poly({{604, 240}, {614, 232}, {650, 230}, {664, 240}, {660, 270}, {652, 300}, {616, 300}, {608, 270}}), navy)
-- figure 3 likewise
W(poly({{782, 268}, {792, 268}, {792, 300}, {782, 300}}) + poly({{830, 268}, {840, 268}, {840, 300}, {830, 300}}), back)
W(poly({{786, 238}, {796, 230}, {826, 229}, {836, 238}, {832, 270}, {826, 300}, {796, 300}, {790, 270}}), navy)
-- figure 1: hunched, rounded shoulders forward, head low; restate the head cleanly
W(ellipse(506, 246, 13, 14) + rect(486, 232, 36, 10), back)
print(wait(2*1440))
W(ellipse(510, 252, 11, 12), skin)
W(ellipse(506, 246, 12, 9) * above(function(x) return 251 end), hairD)
st(skinS, {{514, 254}, {518, 260}}, 3)
-- lit tops of shoulders, a crease down each back
st(navyL, {{606, 240}, {616, 233}, {650, 231}, {662, 240}}, 3)
st(navyL, {{788, 238}, {798, 231}, {826, 230}, {834, 238}}, 3)
st(navyD, {{634, 236}, {634, 298}}, 1.6, {0.45, 0.45})
st(navyD, {{812, 234}, {812, 298}}, 1.6, {0.45, 0.45})
-- the floor: a middle step between the light and the dark band
local midF = pile{{"yellow ochre",0.6},{"viridian",0.3},{"bone black",1.1},{"lead white",0.4}}
work(rect(0, 478, 1000, 30) * SPILL - poly({{594, 388}, {606, 388}, {566, 562}, {520, 562}}) - poly({{854, 388}, {866, 388}, {870, 562}, {820, 562}}), {hand="body", tool="filbert 6", pile=midF, coverage=3.5, fill=true, clip=true, angle=0, load=1})
local g = brush{kind="round", width=1.6, point=0.5}
local gl = pile{{"bone black",1.4},{"viridian",0.2},{"bone brown",0.4}}
for x0 = 200, 1200, 40 do g:reload(gl, 0.6); g:stroke({{340 + (x0 - 340) * 0.25, 380}, {x0, 562}}, {pressure={0.35, 0.45}, clip=rect(0, 478, 1000, 30) * SPILL}) end

--@ chunk 6
print(wait(2*1440))
local darkF = pile{{"bone black",1.6},{"viridian",0.3},{"bone brown",0.4},{"lead white",0.25}}
local back = pile{{"lead white",1.6},{"viridian",0.5},{"yellow ochre",0.8},{"bone black",0.1}}
work((rect(0, 506, 1000, 60) + poly({{170, 562}, {400, 562}, {330, 470}, {300, 420}})) * SPILL, {hand="body", tool="filbert 6", pile=darkF, coverage=4, fill=true, clip=true, angle=0, load=1})
work(poly({{782, 266}, {792, 266}, {794, 300}, {782, 300}}) + poly({{828, 266}, {840, 266}, {840, 300}, {826, 300}}), {hand="detail", tool="round 1.6", pile=back, coverage=5, fill=true, load=1})
