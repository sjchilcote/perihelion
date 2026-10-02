-- easel session "rousseau": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.55, linen={22,20}, seed=1897,
  ground={{pile={{"ultramarine blue",1},{"bone black",0.8},{"lead white",0.4}}, um=80, apply="knife", texture=0.05}}}
-- H = 645. Horizon at 400.
HZ = 400
SKYM = rect(0, 0, 1000, HZ)
local steps = {
  {{"bone black",1.4},{"ultramarine blue",0.8},{"lead white",0.1}},
  {{"bone black",1.2},{"ultramarine blue",0.9},{"lead white",0.2}},
  {{"bone black",1},{"ultramarine blue",0.9},{"viridian",0.15},{"lead white",0.35}},
  {{"bone black",0.8},{"ultramarine blue",0.9},{"viridian",0.25},{"lead white",0.55}},
  {{"bone black",0.6},{"ultramarine blue",0.8},{"viridian",0.3},{"lead white",0.8}},
}
local h = HZ / #steps
for i, s in ipairs(steps) do work(rect(0, (i - 1) * h - 4, 1000, h + 8) * SKYM, {hand="broad", pile=pile(s), coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true}) end
blend(SKYM, {angle=0})
-- the hull: a smooth pale bronze plain, a little darker toward us
HULL = rect(0, HZ, 1000, 250)
work(rect(0, HZ, 1000, 90), {hand="broad", pile=pile{{"yellow ochre",1},{"lead white",1.4},{"raw sienna",0.3}}, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, HZ + 85, 1000, 170), {hand="broad", pile=pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.5},{"burnt sienna",0.1}}, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
print(wait(4*1440))

--@ chunk 2
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local SX, SY, SR = 800, 300, 82
W(ellipse(SX, SY, SR, SR) * above(function(x) return HZ end), pile{{"lead white",2.4},{"yellow ochre",0.35},{"cadmium yellow",0.15}})
W((ellipse(SX, SY, SR, SR) - ellipse(SX, SY, SR - 6, SR - 6)) * above(function(x) return HZ end), pile{{"yellow ochre",1},{"lead white",1.2},{"Mars orange",0.15}})
-- distant ridge of the hull on the horizon, pale grey-blue, low and long
local ridge = poly({{0, HZ}, {0, 372}, {90, 366}, {200, 374}, {320, 368}, {460, 378}, {600, 384}, {700, 392}, {720, HZ}}, true)
W(ridge, pile{{"lead white",1.2},{"ultramarine blue",0.5},{"bone black",0.35},{"yellow ochre",0.15}})
-- precise stars, four-pointed
local st = pile{{"lead white",3},{"lemon chrome",0.1}}
for _, s in ipairs({{90, 60}, {250, 120}, {420, 50}, {560, 160}, {650, 70}, {340, 230}, {930, 90}, {150, 260}, {480, 290}}) do
  local b = brush{kind="round", width=1.6, point=0.8}
  b:reload(st, 0.8); b:stroke({{s[1] - 5, s[2]}, {s[1] + 5, s[2]}}, {pressure={0.1, 0.1}, swell={0.3, 3, 0.3}})
  b:reload(st, 0.8); b:stroke({{s[1], s[2] - 5}, {s[1], s[2] + 5}}, {pressure={0.1, 0.1}, swell={0.3, 3, 0.3}})
  local c = brush{kind="round", width=3, point=0.05}; c:reload(st, 0.9); c:touch(s[1], s[2], {pressure=0.6})
end
print(wait(3*1440))
-- scale-plates: neat naive rows of arcs, larger toward us
local ln = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.25}}
local y, k = HZ + 8, 0
while y < 650 do
  k = k + 1
  local s = 6 + (y - HZ) * 0.14
  local w = s * 2.2
  local off = (k % 2) * w / 2
  local b = brush{kind="round", width=math.max(1, s * 0.12), point=0.5}
  for cx = -w + off, 1000 + w, w do
    if ridge:at(cx, y) < 0.5 then
      local pts = {} for i = 0, 8 do local a = math.pi * i / 8; pts[#pts+1] = {cx + w / 2 * math.cos(a), y + s * 0.45 * math.sin(a)} end
      b:reload(ln, 0.6); b:stroke(pts, {pressure={0.45, 0.45}, ramps={0.05, 0.05}})
    end
  end
  y = y + s * 0.8
end

--@ chunk 3
print(wait(2*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local steel = pile{{"bone black",1.2},{"ultramarine ash",0.7},{"lead white",0.5}}
local steelL = pile{{"lead white",1.8},{"ultramarine ash",0.6},{"bone black",0.3}}
local steelD = pile{{"bone black",1.8},{"ultramarine blue",0.3}}
local crim = pile{{"cadmium red",1},{"Mars red",0.4},{"rose madder",0.3}}
local crimD = pile{{"Mars red",1},{"rose madder",0.5},{"bone black",0.3}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.08}}
local roll = pile{{"lead white",1.2},{"cerulean blue",0.4},{"bone black",0.25}}
local shadow = pile{{"raw sienna",1},{"burnt sienna",0.5},{"bone black",0.4}}
-- a shadow under the body, close and flat
W(poly({{390, 582}, {790, 582}, {800, 594}, {380, 594}}, true), shadow)
-- the bedroll under the head
W(poly({{370, 556}, {376, 540}, {420, 536}, {432, 552}, {426, 588}, {376, 588}}, true), roll)
-- head: an armoured helm lying in profile, face up
W(ellipse(430, 540, 24, 19), steel)
-- body under the tabard, legs, boots
W(poly({{448, 532}, {470, 524}, {640, 528}, {650, 540}, {648, 578}, {460, 582}, {446, 566}}, true), steel)
W(poly({{640, 536}, {780, 540}, {782, 576}, {640, 578}}, true), steel)
W(poly({{770, 518}, {796, 516}, {800, 578}, {770, 578}}, true), steelD)
-- the crimson tabard from chest to knees
TAB = poly({{470, 528}, {690, 532}, {700, 578}, {468, 582}}, true)
W(TAB, crim)
print(wait(3*1440))
-- bone stripes across the tabard, Rousseau's striped robe
for _, x in ipairs({500, 540, 580, 620, 660}) do
  local b = brush{kind="round", width=6, point=0.1}; b:reload(bone, 0.9); b:stroke({{x, 530}, {x + 3, 580}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, clip=TAB})
end
local b = brush{kind="round", width=3, point=0.2}; b:reload(crimD, 0.9); b:stroke({{470, 556}, {698, 556}}, {pressure={0.5, 0.5}, clip=TAB})
-- arm folded across the chest, a gauntlet resting
W(poly({{470, 534}, {520, 528}, {560, 540}, {556, 552}, {512, 546}, {472, 548}}, true), steel)
W(ellipse(562, 545, 10, 8), steelD)
-- visor slit and a glint; knee and shin plates
local s = brush{kind="round", width=3, point=0.2}
s:reload(steelD, 0.9); s:stroke({{418, 532}, {444, 534}}, {pressure={0.7, 0.7}})
s:reload(steelL, 0.8); s:stroke({{418, 526}, {440, 524}}, {pressure={0.5, 0.4}})
s:reload(steelL, 0.8); s:stroke({{650, 538}, {778, 542}}, {pressure={0.5, 0.4}})
s:reload(steelD, 0.9); s:stroke({{712, 540}, {712, 576}}, {pressure={0.6, 0.6}})
-- the cannon-staff laid in front, its muzzle to the right
W(poly({{360, 600}, {820, 598}, {822, 610}, {360, 612}}, true), steelD)
W(poly({{820, 594}, {846, 594}, {846, 614}, {820, 614}}, true), steel)
s:reload(steelL, 0.8); s:stroke({{364, 600}, {818, 598}}, {pressure={0.45, 0.45}})
W(rect(560, 597, 16, 18), pile{{"Mars red",1},{"bone black",0.4}})
-- the small bone cross standing by the head, as Rousseau's jug
W(rect(334, 548, 9, 50) + rect(322, 560, 33, 8), bone)
W(poly({{328, 596}, {350, 596}, {352, 602}, {326, 602}}), shadow)

--@ chunk 4
print(wait(2*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local shell = pile{{"bone black",1},{"raw sienna",0.6},{"viridian",0.35},{"lead white",0.2}}
local shellL = pile{{"raw sienna",1},{"yellow ochre",0.6},{"viridian",0.2},{"lead white",0.5}}
local leg = pile{{"bone black",1.4},{"raw sienna",0.4},{"viridian",0.2}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.08}}
local shadow = pile{{"raw sienna",1},{"burnt sienna",0.5},{"bone black",0.4}}
-- legs first, six of them, jointed, standing on the plates
local function L(hip, knee, foot)
  local b = brush{kind="round", width=7, point=0.2}; b:reload(leg, 1); b:stroke({hip, knee}, {pressure={0.85, 0.8}, ramps={0.02, 0.02}})
  b:reload(leg, 1); b:stroke({knee, foot}, {pressure={0.8, 0.5}, ramps={0.02, 0.2}})
  W(ellipse(foot[1], foot[2] + 2, 9, 3), shadow)
end
L({205, 480}, {160, 520}, {150, 580}); L({240, 488}, {210, 530}, {205, 586}); L({280, 492}, {268, 540}, {262, 588})
L({310, 490}, {330, 535}, {318, 586}); L({335, 485}, {372, 520}, {370, 578}); L({222, 482}, {182, 512}, {178, 570})
-- the shell: a great dome with a crest along its spine
SHELL = poly({{170, 486}, {182, 440}, {214, 404}, {262, 386}, {310, 390}, {350, 410}, {372, 446}, {378, 486}}, true)
W(SHELL, shell)
-- the head, lowered toward the sleeper's face, on a short neck
W(poly({{360, 448}, {392, 464}, {412, 492}, {418, 516}, {404, 524}, {380, 506}, {356, 480}}, true), shell)
print(wait(2*1440))
-- crest: a row of neat blades along the top of the shell
for k = 0, 8 do
  local a = math.pi * (0.9 - 0.8 * k / 8)
  local cx, cy = 275 + 98 * math.cos(a), 450 - 64 * math.sin(a)
  local nx, ny = math.cos(a), -math.sin(a)
  W(poly({{cx - ny * 7, cy + nx * 7}, {cx + nx * 18, cy + ny * 18}, {cx + ny * 7, cy - nx * 7}}), bone, "round 1.4")
end
-- shell banding: three concentric bone-edged plates
for _, r in ipairs({0.72, 0.45}) do
  local pts = {} for i = 0, 16 do local a = math.pi * i / 16; pts[#pts+1] = {274 + 102 * r * math.cos(a), 486 - 96 * r * math.sin(a)} end
  local b = brush{kind="round", width=3, point=0.3}; b:reload(shellL, 0.85); b:stroke(pts, {pressure={0.6, 0.6}})
end
local b = brush{kind="round", width=3, point=0.3}; b:reload(bone, 0.85); b:stroke({{170, 486}, {378, 486}}, {pressure={0.7, 0.7}})
-- bladed forelimbs, folded, held back from the sleeper
local fb = bone
W(poly({{350, 488}, {372, 500}, {362, 548}, {340, 566}, {346, 540}, {352, 508}}, true), leg)
W(poly({{340, 566}, {362, 548}, {332, 590}, {326, 584}}), fb)
W(poly({{368, 494}, {390, 506}, {386, 540}, {372, 556}, {374, 530}}, true), leg)
W(poly({{372, 556}, {386, 540}, {370, 578}, {364, 574}}), fb)
-- eye and nostril-slits, sniffing
local e = brush{kind="round", width=5, point=0.05}; e:reload(pile{{"cadmium yellow",1},{"lead white",0.6}}, 0.9); e:touch(392, 480, {pressure=0.7})
local p = brush{kind="round", width=1.6, point=0.4}
for i = 0, 2 do p:reload(pile{{"bone black",2}}, 0.8); p:stroke({{406 + i * 3, 510 + i * 2}, {410 + i * 3, 506 + i * 2}}, {pressure={0.5, 0.5}}) end

--@ chunk 5
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local sand = pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.5},{"burnt sienna",0.1}}
local steelD = pile{{"bone black",1.8},{"ultramarine blue",0.3}}
local steelL = pile{{"lead white",1.8},{"ultramarine ash",0.6},{"bone black",0.3}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.08}}
local shadow = pile{{"raw sienna",1},{"burnt sienna",0.5},{"bone black",0.4}}
local ln = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.25}}
W(rect(766, 510, 40, 26), sand)
local b = brush{kind="round", width=2, point=0.5}
b:reload(ln, 0.6); b:stroke({{760, 520}, {775, 526}, {800, 527}, {812, 522}}, {pressure={0.45, 0.45}})
W(ellipse(780, 540, 9, 12) + ellipse(796, 544, 8, 11), steelD)
local h = brush{kind="round", width=1.6, point=0.4}
h:reload(steelL, 0.8); h:stroke({{775, 532}, {784, 530}}, {pressure={0.5, 0.4}})
-- the bone cross by his feet, small and upright, with its little shadow
W(rect(868, 550, 9, 48) + rect(856, 562, 33, 8), bone)
W(poly({{862, 597}, {884, 597}, {898, 604}, {866, 604}}), shadow)
