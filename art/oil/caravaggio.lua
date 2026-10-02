-- easel session "caravaggio": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.4, linen={18,16}, seed=1600,
  ground={{pile={{"bone black",2},{"burnt sienna",0.35},{"lead white",0.04}}, um=90, apply="knife", texture=0.15}}}
-- H = 714. The beam falls from the screen at upper right down-left across the back wall onto the table.
BEAM = poly({{870, 150}, {960, 140}, {1000, 230}, {470, 714}, {120, 714}, {140, 560}, {300, 380}})
WALLY = 470          -- the wall meets the table top's back edge at 470
local blk = pile{{"bone black",2},{"burnt sienna",0.3}}
work(rect(0, 0, 1000, 714) - BEAM, {hand="body", pile=blk, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
-- the lit wall: cool pale grey from the screen's light, a little darker away from the source
local w1 = pile{{"lead white",1.6},{"bone black",0.35},{"ultramarine ash",0.2},{"yellow ochre",0.15}}
local w2 = pile{{"lead white",1.1},{"bone black",0.55},{"ultramarine ash",0.2},{"yellow ochre",0.15}}
work(BEAM * rect(560, 0, 440, WALLY), {hand="body", pile=w1, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
work(BEAM * rect(0, 0, 560, WALLY), {hand="body", pile=w2, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
-- floor in the beam, darker than the wall
work(BEAM * rect(0, WALLY, 1000, 260), {hand="body", pile=pile{{"lead white",0.6},{"bone black",0.8},{"burnt sienna",0.25}}, coverage=4, fill=true, clip=true, angle=0, load=1})
print(wait(5*1440))

--@ chunk 2
local W1 = pile{{"lead white",0.8},{"bone black",0.6},{"raw sienna",0.35},{"burnt sienna",0.1}}
local W2 = pile{{"lead white",0.55},{"bone black",0.7},{"raw sienna",0.35},{"burnt sienna",0.15}}
local W3 = pile{{"lead white",0.35},{"bone black",0.8},{"raw sienna",0.3},{"burnt sienna",0.2}}
local F1 = pile{{"lead white",0.3},{"bone black",0.9},{"burnt sienna",0.3}}
local wall = BEAM * rect(0, 0, 1000, WALLY)
work(wall * rect(700, 0, 300, 714), {hand="body", pile=W1, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
work(wall * rect(430, 0, 290, 714), {hand="body", pile=W2, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
work(wall * rect(0, 0, 450, 714), {hand="body", pile=W3, coverage=4, fill=true, clip=true, angle=math.pi/2, load=1})
work(BEAM * rect(0, WALLY, 1000, 260), {hand="body", pile=F1, coverage=4, fill=true, clip=true, angle=0, load=1})
blend(wall, {angle=0, tool={kind="badger", width=40}})
print(wait(5*1440))

--@ chunk 3
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local navyD = pile{{"ultramarine blue",1},{"bone black",1.2}}
local steelD = pile{{"bone black",1.4},{"ultramarine ash",0.5}}
local skinD = pile{{"burnt sienna",0.8},{"bone black",0.6},{"raw sienna",0.3}}
local tableD = pile{{"bone black",1.2},{"burnt sienna",0.7}}
local shadowW = pile{{"bone black",1.3},{"raw sienna",0.3},{"burnt sienna",0.25},{"lead white",0.12}}
-- cast shadow of the Commando's helm and shoulders on the lit wall, thrown down-left
W(poly({{240, 300}, {300, 268}, {340, 290}, {330, 360}, {260, 420}, {200, 420}}, true) * BEAM, shadowW)
-- the table: top, front, a cloth hanging over the front
TTOP = poly({{40, 468}, {640, 468}, {664, 498}, {20, 498}})
TFRONT = poly({{20, 498}, {664, 498}, {660, 600}, {24, 600}})
W(TTOP, tableD); W(TFRONT, pile{{"bone black",1.6},{"burnt sienna",0.4}})
-- figures, in their darks first
CA = poly({{60, 470}, {70, 400}, {100, 372}, {150, 376}, {170, 420}, {176, 470}}, true) + ellipse(118, 396, 22, 20)
CB = poly({{190, 470}, {196, 360}, {230, 330}, {280, 340}, {292, 470}}, true) + ellipse(244, 300, 22, 27)
KN = poly({{300, 470}, {306, 330}, {340, 296}, {420, 296}, {452, 330}, {458, 470}}, true)
KH = poly({{348, 262}, {372, 226}, {408, 222}, {432, 244}, {436, 284}, {414, 304}, {370, 304}, {350, 288}}, true)
CC = poly({{480, 520}, {486, 380}, {520, 350}, {570, 352}, {590, 400}, {596, 520}}, true) + ellipse(548, 322, 22, 26)
STOOL = poly({{490, 520}, {600, 520}, {596, 600}, {494, 600}})
W(CA + CB + CC, navyD); W(KN + KH, steelD); W(STOOL, tableD)
-- arms: B's hand raised to his chest in surprise; A's arms on the table over coins; C's arm on the table edge
ARMB = poly({{270, 360}, {300, 380}, {296, 420}, {262, 420}}, true)
ARMA = poly({{100, 440}, {180, 450}, {200, 468}, {96, 470}}, true)
ARMC = poly({{486, 420}, {470, 460}, {440, 468}, {446, 450}, {476, 410}}, true)
ARMK = poly({{440, 340}, {470, 380}, {470, 460}, {440, 466}, {432, 380}}, true)
W(ARMB + ARMA + ARMC, navyD); W(ARMK, steelD)
print(wait(5*1440))

--@ chunk 4
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.5}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.7}, ramps={0.03, 0.1}}) end
local navyL = pile{{"ultramarine blue",1},{"lead white",1.1},{"bone black",0.15}}
local navyM = pile{{"ultramarine blue",1},{"lead white",0.45},{"bone black",0.5}}
local steelL = pile{{"lead white",1.8},{"ultramarine ash",0.4},{"bone black",0.3},{"yellow ochre",0.1}}
local steelM = pile{{"lead white",0.8},{"ultramarine ash",0.5},{"bone black",0.8}}
local skinL = pile{{"lead white",2},{"yellow ochre",0.5},{"rose madder",0.15}}
local skinM = pile{{"lead white",0.9},{"yellow ochre",0.5},{"burnt sienna",0.4},{"rose madder",0.1}}
local tableL = pile{{"lead white",0.8},{"burnt sienna",0.7},{"raw sienna",0.4},{"bone black",0.2}}
-- the side of everything facing the light (up and to the right), with hard edges
local function lit(m, pts) return m * poly(pts) end
-- table top lit, its far end brightest
W(lit(TTOP, {{200, 460}, {660, 460}, {670, 500}, {150, 500}}), tableL)
-- crew A, hunched: only the top of his back and his bent head catch it
W(lit(CA, {{100, 360}, {180, 370}, {180, 420}, {120, 400}, {80, 400}}), navyM)
W(lit(CA, {{110, 372}, {142, 376}, {140, 392}, {110, 386}}), skinM)
-- crew B: shoulder and chest turned to the light, face in lit profile, hand at his chest
W(lit(CB, {{250, 320}, {300, 330}, {296, 470}, {268, 470}, {262, 360}}), navyL)
W(lit(CB, {{240, 270}, {270, 280}, {268, 330}, {246, 326}}), skinL)
W(ellipse(278, 392, 13, 10), skinL)
st(pile{{"bone black",2}}, {{258, 296}, {266, 296}}, 2)
-- crew C at the end: face in profile toward the light, the front of his body lit
W(lit(CC, {{548, 296}, {574, 310}, {572, 350}, {552, 346}}), skinL)
W(lit(CC, {{560, 352}, {596, 380}, {600, 520}, {576, 520}, {566, 400}}), navyL)
W(lit(ARMC, {{450, 440}, {490, 400}, {494, 420}, {470, 466}}), navyM)
-- the Commando: helm turned up toward the light, its face plane and crown lit; shoulder and arm plates
W(lit(KH, {{392, 220}, {436, 240}, {440, 290}, {416, 300}, {404, 260}}), steelL)
W(lit(KH, {{372, 226}, {400, 222}, {404, 262}, {380, 260}}), steelM)
st(pile{{"bone black",2}}, {{408, 266}, {432, 262}}, 3)
W(lit(KN, {{400, 296}, {420, 296}, {452, 330}, {456, 400}, {430, 380}, {414, 320}}), steelL)
W(lit(KN, {{360, 300}, {400, 296}, {414, 330}, {376, 330}}), steelM)
W(lit(ARMK, {{450, 340}, {470, 380}, {470, 460}, {458, 460}, {452, 380}}), steelM)
-- a cast shadow of B's raised hand on his own chest, and of the Commando on the table
W(poly({{300, 470}, {440, 470}, {400, 498}, {260, 498}}) * TTOP, pile{{"bone black",1.5},{"burnt sienna",0.5}})
print(wait(4*1440))

--@ chunk 5
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.5}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.7}, ramps={0.03, 0.1}}) end
-- the terminal at the beam's source: a dark housing, a pale glowing screen
W(poly({{850, 100}, {980, 92}, {990, 196}, {856, 204}}), pile{{"bone black",1.6},{"ultramarine ash",0.4}})
SCR = poly({{866, 112}, {968, 106}, {974, 182}, {870, 188}})
W(SCR, pile{{"lead white",2.6},{"viridian",0.15},{"cerulean blue",0.08}})
-- Ratio's small pale hand reaching out of the screen, index finger pointing straight at the Commando
local hand = pile{{"lead white",2.6},{"yellow ochre",0.15},{"rose madder",0.06}}
local handS = pile{{"lead white",1.4},{"yellow ochre",0.3},{"cerulean blue",0.1},{"bone black",0.12}}
W(poly({{870, 150}, {858, 140}, {840, 146}, {828, 156}, {830, 168}, {846, 172}, {866, 168}}, true), hand)
st(hand, {{830, 154}, {806, 166}, {790, 174}}, 7, {0.85, 0.6})
st(handS, {{832, 168}, {818, 176}, {820, 184}, {834, 180}}, 4, {0.7, 0.6})
st(handS, {{840, 172}, {828, 180}, {832, 188}}, 4, {0.7, 0.6})
st(handS, {{830, 160}, {810, 172}, {794, 177}}, 2, {0.6, 0.4})
-- a cuff of light round the wrist where it leaves the glass
st(pile{{"lead white",3}}, {{868, 140}, {872, 168}}, 4, {0.7, 0.7})
-- a dead window-frame cross in the beam's path, its shadow on the wall (Caravaggio's window)
local sh = pile{{"bone black",1.2},{"raw sienna",0.35},{"burnt sienna",0.2},{"lead white",0.12}}
W((poly({{600, 300}, {608, 296}, {520, 470}, {510, 470}}) + poly({{520, 340}, {700, 280}, {702, 288}, {522, 348}})) * BEAM * rect(0, 0, 1000, WALLY), sh)
print(wait(3*1440))

--@ chunk 6
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=5, fill=true, load=1}) end
local navyD = pile{{"ultramarine blue",1},{"bone black",1.2}}
local navyL = pile{{"ultramarine blue",0.7},{"lead white",0.7},{"raw sienna",0.25},{"bone black",0.3}}
local skinL = pile{{"lead white",2},{"yellow ochre",0.5},{"rose madder",0.15}}
local function lit(m, pts) return m * poly(pts) end
-- crew C repainted over the stray window-shadow, then his light
W(CC + ARMC, navyD)
print(wait(3*1440))
W(lit(CC, {{548, 296}, {574, 310}, {572, 350}, {552, 346}}), skinL)
W(lit(CC, {{560, 352}, {596, 380}, {600, 520}, {576, 520}, {566, 400}}), navyL)
-- crew B's lit side warmed, so the light reads as one warm light
W(lit(CB, {{250, 320}, {300, 330}, {296, 470}, {268, 470}, {262, 360}}) - ellipse(278, 392, 14, 11), navyL)
W(lit(CA, {{100, 360}, {180, 370}, {180, 420}, {120, 400}, {80, 400}}) - lit(CA, {{110, 372}, {142, 376}, {140, 392}, {110, 386}}), pile{{"ultramarine blue",0.7},{"lead white",0.4},{"raw sienna",0.2},{"bone black",0.6}})
-- eyes and mouths: B and C open-mouthed, looking at the light
local function st(p, pts, w) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.9); b:stroke(pts, {pressure={0.7, 0.7}, ramps={0.03, 0.03}}) end
local dk = pile{{"bone black",2},{"burnt sienna",0.3}}
st(dk, {{560, 314}, {566, 314}}, 2); st(dk, {{566, 334}, {569, 336}}, 3)
st(dk, {{262, 312}, {266, 315}}, 3)

--@ chunk 7
print(wait(10*1440)); print(drying(560, 400))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=6, fill=true, load=1}) end
local navyL = pile{{"ultramarine blue",0.7},{"lead white",0.7},{"raw sienna",0.25},{"bone black",0.3}}
local skinL = pile{{"lead white",2},{"yellow ochre",0.5},{"rose madder",0.15}}
local navyD = pile{{"ultramarine blue",1},{"bone black",1.2}}
local function lit(m, pts) return m * poly(pts) end
W(CC * rect(0, 340, 1000, 200) - lit(CC, {{560, 352}, {596, 380}, {600, 520}, {576, 520}, {566, 400}}), navyD)
W(lit(CC, {{560, 352}, {596, 380}, {600, 520}, {576, 520}, {566, 400}}), navyL)
W(lit(CC, {{548, 296}, {574, 310}, {572, 350}, {552, 346}}), skinL)
W(CC * poly({{526, 296}, {548, 296}, {552, 346}, {526, 346}}), pile{{"burnt sienna",0.6},{"bone black",0.6},{"raw sienna",0.3}})
local b = brush{kind="round", width=2.4, point=0.4}
b:reload(pile{{"bone black",2}}, 0.9); b:stroke({{562, 316}, {567, 316}}, {pressure={0.7, 0.7}})
b:reload(pile{{"bone black",2}}, 0.9); b:stroke({{566, 334}, {569, 337}}, {pressure={0.7, 0.7}})
