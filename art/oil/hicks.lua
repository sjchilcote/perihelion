-- easel session "hicks": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.4, linen={22,20}, seed=1834,
  ground={{pile={{"lead white",2.4},{"yellow ochre",0.5},{"raw sienna",0.1}}, um=80, apply="knife", texture=0.08}}}
-- H = 714
local function W(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, clip=true, angle=0, load=1}) end
function ringY(x) return 300 - 230 * (x / 1000)^1.8 end
SKY = above(function(x) return ringY(x) end)
FAR = below(function(x) return ringY(x) end) * above(function(x) return 360 - 40 * (x / 1000) end)
MID = below(function(x) return 360 - 40 * (x / 1000) end) * above(function(x) return 440 end)
NEAR = below(function(x) return 440 end)
W(SKY, pile{{"lead white",2.4},{"cerulean blue",0.35},{"yellow ochre",0.1}})
W(FAR, pile{{"lead white",1.6},{"viridian",0.35},{"cerulean blue",0.3},{"yellow ochre",0.2}})
W(MID, pile{{"lead white",1.2},{"viridian",0.4},{"yellow ochre",0.6}})
W(NEAR, pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",0.6},{"viridian",0.1}})
-- a dark bronze pillar-tree framing the left, as Hicks' great tree
PIL = poly({{0, 0}, {90, 0}, {110, 120}, {96, 300}, {104, 714}, {0, 714}}, true)
W(PIL, pile{{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.4}})
print(wait(4*1440))

--@ chunk 2
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2.5", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
local navy = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.35}}
local skin = pile{{"lead white",2},{"yellow ochre",0.45},{"rose madder",0.15}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.06}}
local steel = pile{{"lead white",0.9},{"ultramarine ash",0.5},{"bone black",0.5}}
local crim = pile{{"cadmium red",1},{"Mars red",0.4}}
local wood = pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone brown",0.3}}
local dk = pile{{"bone black",2}}
-- the treaty, small, in the middle distance: a table with a white cloth, crew, docents and the Commando shaking hands
W(rect(200, 372, 150, 10), pile{{"lead white",2.6}})
W(rect(206, 382, 6, 22) + rect(338, 382, 6, 22), wood)
local function pfig(x, y, h, body, head)
  W(poly({{x - h * 0.16, y}, {x + h * 0.16, y}, {x + h * 0.12, y - h * 0.7}, {x - h * 0.12, y - h * 0.7}}), body, "round 1.4")
  W(ellipse(x, y - h * 0.82, h * 0.12, h * 0.13), head, "round 1.2")
end
pfig(190, 404, 40, navy, skin); pfig(222, 400, 38, navy, skin)
pfig(270, 404, 46, steel, steel); pfig(300, 404, 52, bone, bone); pfig(330, 404, 48, bone, bone); pfig(366, 404, 40, navy, skin)
st(steel, {{276, 376}, {290, 372}}, 3); st(bone, {{294, 372}, {290, 372}}, 3)
W(rect(267, 380, 7, 12), crim, "round 1.2")
-- the Warden curled asleep in the foreground, its crested shell, legs tucked, head down on the ground
WSH = poly({{520, 640}, {530, 560}, {580, 500}, {660, 476}, {740, 484}, {800, 520}, {826, 590}, {820, 640}}, true)
W(WSH, pile{{"viridian",0.5},{"raw sienna",0.7},{"bone black",0.35},{"lead white",0.4}})
W(poly({{470, 640}, {476, 606}, {510, 590}, {540, 610}, {536, 644}}, true), pile{{"viridian",0.4},{"raw sienna",0.7},{"bone black",0.3},{"lead white",0.5}})
-- the Commando seated at the left with Ratio's little printed body on his knee
W(poly({{170, 700}, {170, 600}, {200, 560}, {300, 560}, {310, 600}, {320, 700}}), steel)
W(poly({{180, 560}, {186, 460}, {220, 432}, {280, 432}, {300, 470}, {300, 560}}, true), steel)
W(poly({{196, 470}, {286, 470}, {290, 600}, {200, 600}}), crim)
W(ellipse(244, 412, 30, 34), steel)
W(rect(232, 476, 8, 60) + rect(212, 494, 48, 8), bone)
W(poly({{300, 560}, {360, 556}, {370, 600}, {310, 600}}), steel)
-- Ratio on his knee: a small figure, black hair, pale face, sky-blue dress
W(poly({{318, 556}, {356, 556}, {350, 516}, {324, 516}}), pile{{"cerulean blue",0.8},{"lead white",1.4}})
W(ellipse(337, 498, 16, 18), skin)
W(ellipse(337, 490, 18, 14) * above(function(x) return 494 end) + rect(318, 490, 6, 40) + rect(350, 490, 6, 40), pile{{"bone black",1.8},{"ultramarine blue",0.3}})
-- the docent standing at the right, tall and thin, bone and bronze
W(poly({{900, 680}, {960, 680}, {950, 470}, {910, 470}}), pile{{"burnt sienna",0.6},{"yellow ochre",0.6},{"lead white",0.6}})
W(ellipse(930, 446, 18, 30) + ellipse(940, 430, 18, 14), bone)
print(wait(4*1440))

--@ chunk 3
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
local navy = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.35}}
local skin = pile{{"lead white",2},{"yellow ochre",0.45},{"rose madder",0.15}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.06}}
local steel = pile{{"lead white",0.9},{"ultramarine ash",0.5},{"bone black",0.5}}
local crim = pile{{"cadmium red",1},{"Mars red",0.4}}
local wood = pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone brown",0.3}}
local dk = pile{{"bone black",2}}
local midG = pile{{"lead white",1.2},{"viridian",0.4},{"yellow ochre",0.6}}
-- move the treaty out from behind the Commando's head
W(rect(160, 316, 225, 92) * MID - ellipse(244, 412, 32, 36) - poly({{180, 560}, {186, 460}, {220, 432}, {280, 432}, {300, 470}, {300, 560}}, true), midG)
print(wait(2*1440))
W(rect(430, 372, 170, 10), pile{{"lead white",2.6}})
W(rect(436, 382, 6, 22) + rect(588, 382, 6, 22), wood)
local function pfig(x, y, h, body, head)
  W(poly({{x - h * 0.16, y}, {x + h * 0.16, y}, {x + h * 0.12, y - h * 0.7}, {x - h * 0.12, y - h * 0.7}}), body, "round 1.4")
  W(ellipse(x, y - h * 0.82, h * 0.12, h * 0.13), head, "round 1.2")
end
pfig(410, 404, 40, navy, skin); pfig(440, 400, 38, navy, skin); pfig(492, 404, 48, steel, steel)
pfig(530, 404, 52, bone, bone); pfig(566, 404, 48, bone, bone); pfig(612, 404, 40, navy, skin)
W(rect(489, 380, 7, 12), crim, "round 1.2")
st(steel, {{500, 374}, {514, 372}}, 3); st(bone, {{516, 372}, {522, 374}}, 3)
-- a scroll on the table, a little flag
W(rect(540, 366, 26, 6), pile{{"lead white",2.4},{"yellow ochre",0.4}})
st(wood, {{600, 372}, {600, 330}}, 1.6); W(poly({{600, 330}, {622, 336}, {600, 342}}), crim, "round 1.2")

--@ chunk 4
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.4}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.75, 0.75}, ramps={0.03, 0.05}}) end
local navy = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.35}}
local navyL = pile{{"ultramarine blue",0.8},{"lead white",0.8}}
local skin = pile{{"lead white",2},{"yellow ochre",0.45},{"rose madder",0.15}}
local cheek = pile{{"lead white",1.6},{"rose madder",0.45}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.06}}
local hairB = pile{{"bone brown",1},{"burnt sienna",0.4}}
local hairY = pile{{"yellow ochre",1},{"lead white",0.6},{"raw sienna",0.2}}
local dk = pile{{"bone black",2}}
local shellD = pile{{"viridian",0.4},{"raw sienna",0.6},{"bone black",0.6},{"lead white",0.2}}
-- the Warden: a row of bone crest blades, banded shell, tucked legs, a sleepy closed eye and a smile
for k = 0, 9 do
  local a = math.pi * (0.85 - 0.7 * k / 9)
  local x, y = 670 + 150 * math.cos(a), 640 - 160 * math.sin(a)
  W(poly({{x - 8, y + 4}, {x, y - 18}, {x + 8, y + 4}}), bone, "round 1.4")
end
for _, r in ipairs({0.62, 0.36}) do local pts = {} for k = 0, 16 do local a = math.pi * k / 16; pts[#pts+1] = {670 + 150 * r * math.cos(a), 636 - 150 * r * math.sin(a)} end; st(shellD, pts, 3) end
for _, x in ipairs({560, 610, 730, 790}) do st(shellD, {{x, 638}, {x - 14, 648}, {x - 4, 652}}, 5) end
st(dk, {{486, 616}, {494, 620}, {502, 616}}, 2.2)
st(dk, {{480, 630}, {490, 634}}, 1.8)
-- crew children: round faces, rosy cheeks, earnest dot eyes, leaning on the Warden
local function child(x, y, s, hair, lean)
  W(poly({{x - 13 * s, y}, {x + 13 * s, y}, {x + 10 * s, y - 34 * s}, {x - 10 * s, y - 34 * s}}), navy, "round 1.6")
  W(ellipse(x, y - 44 * s, 11 * s, 12 * s), skin, "round 1.4")
  W(ellipse(x, y - 52 * s, 12 * s, 7 * s) * above(function(xx) return y - 48 * s end), hair, "round 1.2")
  local e = brush{kind="round", width=2.2 * s, point=0.05}
  e:reload(dk, 0.9); e:touch(x - 4 * s, y - 45 * s, {pressure=0.7}); e:reload(dk, 0.9); e:touch(x + 4 * s, y - 45 * s, {pressure=0.7})
  local c = brush{kind="round", width=4 * s, point=0.05}
  c:reload(cheek, 0.7); c:touch(x - 6 * s, y - 40 * s, {pressure=0.5}); c:reload(cheek, 0.7); c:touch(x + 6 * s, y - 40 * s, {pressure=0.5})
  if lean then st(navy, {{x + 8 * s, y - 28 * s}, {x + lean * 22 * s, y - 20 * s}}, 6 * s) end
end
child(568, 560, 1.2, hairB, 1)
child(700, 492, 1.0, hairY, nil)
child(842, 640, 1.3, hairB, -1)
child(440, 690, 1.25, hairY, 1)
-- small scuttlers lying quiet, legs folded, with tiny closed eyes
local scut = pile{{"bone black",1.4},{"raw sienna",0.5},{"viridian",0.2}}
for _, s in ipairs({{360, 660}, {600, 690}, {760, 690}, {900, 700}}) do
  W(ellipse(s[1], s[2], 22, 11), scut)
  for j = -2, 2 do st(scut, {{s[1] + j * 7, s[2] + 8}, {s[1] + j * 9, s[2] + 14}}, 1.6) end
  st(bone, {{s[1] - 18, s[2] - 4}, {s[1] - 12, s[2] - 4}}, 1.4)
end
-- the Commando: visor, an earnest glow behind it; Ratio's face, the docent's face, all looking out at us
st(dk, {{226, 412}, {262, 412}}, 4)
local g = brush{kind="round", width=3, point=0.05}
g:reload(pile{{"cadmium yellow",1},{"lead white",1}}, 0.9); g:touch(236, 412, {pressure=0.6}); g:reload(pile{{"cadmium yellow",1},{"lead white",1}}, 0.9); g:touch(252, 412, {pressure=0.6})
local e2 = brush{kind="round", width=2.6, point=0.05}
e2:reload(dk, 0.9); e2:touch(331, 498, {pressure=0.7}); e2:reload(dk, 0.9); e2:touch(343, 498, {pressure=0.7})
st(cheek, {{334, 508}, {340, 508}}, 2)
e2:reload(dk, 0.9); e2:touch(926, 446, {pressure=0.7}); e2:reload(dk, 0.9); e2:touch(938, 446, {pressure=0.7})
-- a few small flowers in the foreground, folk-art
local fl = {pile{{"cadmium red",1}}, pile{{"lead white",2.5}}, pile{{"cerulean blue",1},{"lead white",1}}}
for k = 1, 22 do local b = brush{kind="round", width=6, point=0.05}; b:reload(fl[math.random(1, 3)], 0.9); b:touch(rand(120, 980), rand(690, 712), {pressure=0.7}) end
