-- easel session "seurat": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.5, linen={22,20}, seed=1884,
  ground={{pile={{"lead white",3},{"yellow ochre",0.25}}, um=80, apply="knife", texture=0.1}}}
-- H = 667
function ringTop(x) return 250 - 210 * (x / 1000)^2.2 end
function ringBot(x) return ringTop(x) + 26 + 10 * (1 - x / 1000) end
local t, b = {}, {}
for x = -10, 1010, 20 do t[#t+1] = {x, ringTop(x)}; b[#b+1] = {x, ringBot(x)} end
SKY = above(t)
RING = below(t) * above(b)
WATER = poly({{0, 255}, {430, 262}, {330, 330}, {150, 400}, {0, 420}}, true) - SKY - RING
LAWN = below(b) - WATER
SHADOW = poly({{0, 560}, {520, 520}, {1000, 545}, {1000, 667}, {0, 667}}, true) + poly({{620, 300}, {1000, 270}, {1000, 360}, {700, 380}}, true)
SHADOW = SHADOW * LAWN
local function W(m, p) work(m, {hand="body", pile=p, coverage=3, fill=true, clip=true, angle=0, load=1}) end
W(SKY, pile{{"lead white",2.4},{"cerulean blue",0.4},{"cobalt violet",0.05}})
W(RING, pile{{"lead white",1.8},{"viridian",0.35},{"cerulean blue",0.35}})
W(WATER, pile{{"lead white",1.4},{"cerulean blue",0.6},{"viridian",0.2}})
W(LAWN - SHADOW, pile{{"lead white",0.9},{"viridian",0.5},{"yellow ochre",0.6},{"lemon chrome",0.15}})
W(SHADOW, pile{{"viridian",0.8},{"ultramarine blue",0.5},{"bone black",0.3},{"lead white",0.3}})
print(wait(3*1440))

--@ chunk 2
print(SKY:area(), RING:area(), LAWN:area(), WATER:area(), SHADOW:area(), SKY:at(500,50), SKY:at(500,500), ringTop(500))

--@ chunk 3
SKY = above(function(x) return ringTop(x) end)
local RB = above(function(x) return ringBot(x) end)
RING = RB - SKY
WATER = poly({{0, 255}, {430, 262}, {330, 330}, {150, 400}, {0, 420}}, true) - RB
LAWN = -RB - WATER
SHADOW = (poly({{0, 560}, {520, 520}, {1000, 545}, {1000, 667}, {0, 667}}, true) + poly({{620, 300}, {1000, 270}, {1000, 360}, {700, 380}}, true)) * LAWN
print(SKY:area(), RING:area(), LAWN:area(), WATER:area(), SHADOW:area())
local function W(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, clip=true, angle=0, load=1}) end
W(RING, pile{{"lead white",1.6},{"viridian",0.4},{"cerulean blue",0.4}})
W(WATER, pile{{"lead white",1.2},{"cerulean blue",0.7},{"viridian",0.2}})
W(LAWN - SHADOW, pile{{"lead white",0.8},{"viridian",0.5},{"yellow ochre",0.7},{"lemon chrome",0.15}})
W(SHADOW, pile{{"viridian",0.8},{"ultramarine blue",0.5},{"bone black",0.3},{"lead white",0.3}})
print(wait(3*1440))

--@ chunk 4
local function D(m, piles, w, cov)
  for i, p in ipairs(piles) do stipple(m, {pile=pile(p), width=w, coverage=cov, pressure={0.45, 0.7}, seed=100 + i}) end
end
D(SKY, {{{"lead white",2},{"cerulean blue",0.6}}, {{"lead white",2.4},{"lemon chrome",0.25}}, {{"lead white",2},{"cobalt violet",0.35}}, {{"lead white",1.6},{"cobalt blue",0.5}}}, 4.5, 0.55)
D(RING, {{{"lead white",1.4},{"viridian",0.6}}, {{"lead white",1.6},{"cerulean blue",0.6}}, {{"lead white",2},{"lemon chrome",0.3}}}, 3.5, 0.7)
D(WATER, {{{"cerulean blue",1},{"lead white",0.8}}, {{"ultramarine blue",0.8},{"lead white",1.2}}, {{"lead white",2.6}}, {{"Mars orange",0.4},{"lead white",2}}}, 4, 0.55)

--@ chunk 5
local function D(m, piles, w, cov)
  for i, p in ipairs(piles) do stipple(m, {pile=pile(p), width=w, coverage=cov, pressure={0.5, 0.75}, seed=200 + i}) end
end
D(SKY * above(function(x) return 130 end), {{{"cerulean blue",1},{"lead white",1.2}}, {{"cobalt blue",0.8},{"lead white",1.4}}}, 5, 0.6)
D(SKY, {{{"cerulean blue",1},{"lead white",1.6}}}, 5, 0.4)
D(LAWN - SHADOW, {{{"lemon chrome",0.6},{"viridian",0.5},{"lead white",0.6}}, {{"cadmium yellow",0.8},{"lead white",0.8},{"Mars orange",0.1}}, {{"emerald green",0.7},{"lead white",0.5}}, {{"viridian",0.6},{"yellow ochre",0.6},{"lead white",0.4}}}, 5.5, 0.5)
D(SHADOW, {{{"ultramarine blue",1},{"lead white",0.2}}, {{"viridian",1},{"bone black",0.2},{"lead white",0.15}}, {{"cobalt violet",0.8},{"ultramarine blue",0.4},{"lead white",0.2}}, {{"Mars orange",0.6},{"bone brown",0.4}}}, 5.5, 0.45)

--@ chunk 6
print(wait(2*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.8, 0.8}, ramps={0.02, 0.02}}) end
local robeD = pile{{"bone brown",1},{"ultramarine blue",0.5},{"bone black",0.4}}
local robeB = pile{{"burnt sienna",0.7},{"raw sienna",0.6},{"bone brown",0.4},{"lead white",0.2}}
local boneP = pile{{"lead white",1.8},{"yellow ochre",0.5},{"raw sienna",0.1}}
local skull = pile{{"lead white",1.6},{"yellow ochre",0.5},{"raw sienna",0.2}}
-- a Testator figure in profile facing left: bell robe, narrow torso, a long skull swept back
function testator(x, y, h, robe, dir)
  dir = dir or -1
  local w = h * 0.26
  local m = poly({{x - w, y}, {x + w * 1.25, y}, {x + w * 0.9, y - h * 0.35}, {x + w * 0.6, y - h * 0.48}, {x + w * 0.25, y - h * 0.62}, {x + w * 0.3, y - h * 0.8}, {x - w * 0.3, y - h * 0.8}, {x - w * 0.35, y - h * 0.6}, {x - w * 0.5, y - h * 0.4}}, true)
  W(m, robe)
  local hx, hy = x, y - h * 0.86
  local head = ellipse(hx - dir * h * 0.05, hy, h * 0.09, h * 0.07) + ellipse(hx + dir * h * 0.02, hy + h * 0.04, h * 0.05, h * 0.05)
  W(head, skull)
  W(rect(x - w * 0.15, y - h * 0.82, w * 0.3, h * 0.06), skull)
  return m
end
-- foreground right: the parasol-bearer and her companion
FIG = {}
FIG[1] = testator(770, 610, 380, robeD, -1)
local pp = {} for k = 0, 16 do local a = math.pi * k / 16; pp[#pp+1] = {760 + 80 * math.cos(a), 250 - 30 * math.sin(a)} end
W(poly(pp), pile{{"Mars orange",0.6},{"cadmium red",0.3},{"lead white",1.2}})
st(robeD, {{760, 250}, {756, 420}}, 3)
FIG[2] = testator(880, 615, 420, robeB, -1)
st(boneP, {{870, 422}, {872, 600}}, 6)
-- the leash and a small jointed creature, like Seurat's monkey
st(pile{{"bone black",2}}, {{700, 470}, {640, 560}, {620, 598}}, 1.2, {0.6, 0.6})
W(ellipse(610, 600, 18, 10), robeB)
st(robeB, {{596, 604}, {590, 618}}, 3); st(robeB, {{606, 606}, {604, 620}}, 3); st(robeB, {{620, 606}, {624, 620}}, 3); st(robeB, {{628, 604}, {636, 616}}, 3)
st(robeB, {{594, 596}, {580, 586}, {574, 592}}, 3)
st(robeB, {{626, 596}, {640, 580}, {650, 584}, {644, 570}}, 2.4)
-- seated figure in the shadow, foreground left, in profile facing right, reclining
W(poly({{80, 600}, {260, 596}, {270, 570}, {210, 560}, {150, 520}, {120, 520}, {100, 560}}, true), robeD)
W(ellipse(135, 500, 26, 18) + ellipse(118, 512, 14, 12), skull)
st(boneP, {{200, 570}, {262, 576}}, 4)
-- mid-ground figures along the lawn
local mids = {{420, 420, 120, robeB}, {480, 430, 110, robeD}, {290, 360, 80, robeD}, {560, 350, 70, robeB}, {640, 330, 64, robeD}, {360, 310, 50, robeB}, {200, 330, 56, robeB}}
for i, m in ipairs(mids) do FIG[#FIG + 1] = testator(m[1], m[2], m[3], m[4], (i % 2 == 0) and 1 or -1) end
local pp2 = {} for k = 0, 12 do local a = math.pi * k / 12; pp2[#pp2+1] = {420 + 26 * math.cos(a), 304 - 10 * math.sin(a)} end
W(poly(pp2), pile{{"lead white",2},{"cobalt violet",0.3}}); st(robeD, {{420, 304}, {420, 346}}, 1.4)
-- a seated pair by the water, and docents (tall thin bone figures) in the background near the ring
W(ellipse(260, 300, 14, 8) + ellipse(290, 300, 14, 8), robeD); W(ellipse(256, 288, 5, 4) + ellipse(286, 288, 5, 4), skull)
for _, d in ipairs({{520, 270}, {610, 260}, {700, 240}, {740, 236}}) do st(boneP, {{d[1], d[2]}, {d[1], d[2] - 26}}, 4); W(ellipse(d[1], d[2] - 30, 3, 3), skull) end
-- a sail on the water
W(poly({{120, 340}, {150, 340}, {146, 348}, {124, 348}}), robeB); W(poly({{136, 338}, {136, 296}, {160, 336}}), pile{{"lead white",2.4},{"yellow ochre",0.2}})
-- cast shadows to the right of the standing figures, long and flat
local sh = pile{{"viridian",0.8},{"ultramarine blue",0.5},{"bone black",0.35},{"lead white",0.2}}
for _, m in ipairs(mids) do W(poly({{m[1] - m[3] * 0.2, m[2]}, {m[1] + m[3] * 0.3, m[2]}, {m[1] + m[3] * 1.3, m[2] + m[3] * 0.12}, {m[1] + m[3] * 0.9, m[2] + m[3] * 0.16}}, true), sh) end

--@ chunk 7
print(wait(4*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=5, fill=true, load=1}) end
local robeB = pile{{"burnt sienna",0.7},{"raw sienna",0.6},{"bone brown",0.4},{"lead white",0.2}}
local skull = pile{{"lead white",1.6},{"yellow ochre",0.5},{"raw sienna",0.2}}
local skyDots = pile{{"cerulean blue",1},{"lead white",1.6}}
-- restate the front bronze figure opaque, and the long skulls
W(FIG[2], robeB)
-- clear blobby heads of the two big figures back to the sky/lawn, then long swept-back skulls
local clr1 = ellipse(770, 210, 50, 40); local clr2 = ellipse(880, 190, 55, 45)
W(clr1 - FIG[1] - poly({{680, 250}, {840, 250}, {840, 220}, {680, 220}}), skyDots)
W(clr2 - FIG[2], pile{{"lead white",0.8},{"viridian",0.5},{"yellow ochre",0.6}})
local function longSkull(x, y, len, ht, back)
  -- a long skull in profile, face at front (left), the cranium sweeping back and up
  local pts = {{x - len * 0.35, y + ht * 0.25}, {x - len * 0.4, y - ht * 0.1}, {x - len * 0.2, y - ht * 0.5}, {x + len * 0.3, y - ht * 0.9}, {x + len * 0.65, y - ht * 1.1}, {x + len * 0.7, y - ht * 0.8}, {x + len * 0.35, y - ht * 0.2}, {x + len * 0.1, y + ht * 0.4}, {x - len * 0.2, y + ht * 0.5}}
  W(poly(pts, true), skull)
end
longSkull(768, 280, 70, 34); longSkull(878, 262, 76, 38)
print(wait(2*1440))
-- dots over everything figural: pure-ish colours, so the figures join the speckle
local function D(m, piles, w, cov) for i, p in ipairs(piles) do stipple(m, {pile=pile(p), width=w, coverage=cov, pressure={0.5, 0.75}, clip=true, seed=300 + i}) end end
local dark = {{{"ultramarine blue",1},{"bone black",0.2}}, {{"cobalt violet",0.8},{"ultramarine blue",0.4}}, {{"Mars orange",0.5},{"bone brown",0.5}}}
local bronze = {{{"Mars orange",1},{"lead white",0.3}}, {{"burnt sienna",1}}, {{"cadmium yellow",0.6},{"raw sienna",0.6}}, {{"ultramarine blue",0.4},{"burnt sienna",0.6}}}
D(FIG[1], dark, 4, 0.5)
D(FIG[2], bronze, 4, 0.5)
-- the sky band's hard edge: a mixing band of both sky dot colours
D(rect(0, 100, 1000, 70) * SKY, {{{"cerulean blue",1},{"lead white",1.2}}, {{"lead white",2},{"cerulean blue",0.5}}, {{"lead white",2.2},{"lemon chrome",0.2}}}, 5, 0.6)

--@ chunk 8
local function D(m, piles, w, cov) for i, p in ipairs(piles) do stipple(m, {pile=pile(p), width=w, coverage=cov, pressure={0.5, 0.75}, clip=true, seed=400 + i}) end end
local discs = (ellipse(770, 210, 52, 42) + ellipse(880, 190, 57, 47)) - FIG[1] - FIG[2] - ellipse(768, 266, 50, 40) - ellipse(880, 246, 52, 42) - poly({{680, 252}, {840, 252}, {840, 218}, {680, 218}})
local skyP = {{{"cerulean blue",1},{"lead white",1.6}}, {{"lead white",2.2},{"lemon chrome",0.25}}, {{"lead white",2},{"cobalt violet",0.35}}, {{"cobalt blue",0.8},{"lead white",1.4}}}
local ringP = {{{"lead white",1.4},{"viridian",0.6}}, {{"lead white",1.6},{"cerulean blue",0.6}}, {{"lead white",2},{"lemon chrome",0.3}}}
local lawnP = {{{"lemon chrome",0.6},{"viridian",0.5},{"lead white",0.6}}, {{"cadmium yellow",0.8},{"lead white",0.8},{"Mars orange",0.1}}, {{"emerald green",0.7},{"lead white",0.5}}, {{"viridian",0.6},{"yellow ochre",0.6},{"lead white",0.4}}}
local shadP = {{{"ultramarine blue",1},{"lead white",0.2}}, {{"viridian",1},{"bone black",0.2},{"lead white",0.15}}, {{"cobalt violet",0.8},{"ultramarine blue",0.4},{"lead white",0.2}}}
D(discs * SKY, skyP, 5, 1.0)
D(discs * RING, ringP, 4, 1.1)
D(discs * (LAWN - SHADOW), lawnP, 5.5, 0.9)
D(discs * SHADOW, shadP, 5.5, 0.9)
-- dots over the mid figures and the seated one too
local dark = {{{"ultramarine blue",1},{"bone black",0.2}}, {{"cobalt violet",0.8},{"ultramarine blue",0.4}}, {{"Mars orange",0.5},{"bone brown",0.5}}}
for i = 3, #FIG do D(FIG[i], dark, 3, 0.4) end
D(poly({{80, 600}, {260, 596}, {270, 570}, {210, 560}, {150, 520}, {120, 520}, {100, 560}}, true), dark, 4, 0.45)
