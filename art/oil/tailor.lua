-- easel session "tailor": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=4/3, linen={18,16}, seed=2626,
  ground={{pile={{"bone black",1},{"burnt sienna",1},{"raw sienna",0.3},{"lead white",0.45}}, um=110, apply="knife", texture=0.4}}}
-- a small warm workroom: back wall, floor from y 520; one lamp hanging over the docent's bench; light in a soft ring
LX, LY = 430, 120
WALLM = rect(0, 0, 1000, 520)
FLOORM = rect(0, 520, 1000, 230)
local wD = pile{{"bone black",1.8},{"burnt sienna",0.8},{"ultramarine blue",0.2}, medium=0.06}
local wM = pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
local wL = pile{{"burnt sienna",1},{"raw sienna",0.9},{"yellow ochre",0.4},{"bone black",0.45}, medium=0.06}
local r1 = ellipse(LX, 300, 330, 300)
local r2 = ellipse(LX, 260, 200, 190)
work(WALLM - r1, {hand="body", tool="filbert 12", pile=wD, coverage=4, fill=true, clip=WALLM - r1, angle=math.pi/2, load=1})
work((WALLM * r1) - r2, {hand="body", tool="filbert 10", pile=wM, coverage=4, fill=true, clip=(WALLM * r1) - r2, angle=math.pi/2, load=1})
work(WALLM * r2, {hand="body", tool="filbert 8", pile=wL, coverage=4, fill=true, clip=WALLM * r2, angle=math.pi/2, load=1})
blend(WALLM * (ellipse(LX, 300, 345, 315) - ellipse(LX, 300, 312, 282)))
blend(WALLM * (ellipse(LX, 260, 215, 205) - ellipse(LX, 260, 185, 175)))
local fD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}
local fL = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local fp = ellipse(LX + 60, 600, 360, 80)
work(FLOORM - fp, {hand="body", tool="filbert 12", pile=fD, coverage=4, fill=true, clip=FLOORM - fp, angle=0, load=1})
work(FLOORM * fp, {hand="body", tool="filbert 10", pile=fL, coverage=4, fill=true, clip=FLOORM * fp, angle=0, load=1})
blend(FLOORM * (ellipse(LX + 60, 600, 380, 92) - ellipse(LX + 60, 600, 340, 68)), {angle=0})
-- the floor line: a dark skirting
local sk = rect(0, 512, 1000, 12)
work(sk, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=sk, load=1})

--@ chunk 2
-- the lamp, the bench with its spools and pins, the docent seated in profile facing right with the tabard across its knees
print(wait(3*24*60))
local brD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local brM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5},{"burnt sienna",0.2}, medium=0.06}
local function st(pts, pl, w, pr, clipm, kind)
  local b = brush{kind=kind or "round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
-- lamp: chain, a bronze shade, a bulb
st({{LX, 0}, {LX, LY - 20}}, brD, 2, {0.9, 0.9})
local shade = poly({{LX - 14, LY - 22}, {LX + 14, LY - 22}, {LX + 40, LY}, {LX - 40, LY}}, true)
work(shade, {hand="detail", pile=brM, coverage=6, fill=true, clip=shade, load=1})
st({{LX - 13, LY - 21}, {LX + 13, LY - 21}}, brL, 2, {0.6, 0.6})
local bulb = ellipse(LX, LY + 3, 17, 5)
work(bulb, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.03}, coverage=6, fill=true, clip=bulb, load=1})
-- the bench: top, front, legs
BENCH = rect(480, 420, 230, 18) + rect(488, 438, 10, 120) + rect(692, 438, 10, 120)
local top = rect(480, 420, 230, 6)
work(BENCH, {hand="body", tool="filbert 3", pile=brD, coverage=6, fill=true, clip=BENCH, angle=0, load=1})
work(top, {hand="detail", pile=brL, coverage=6, fill=true, clip=top, load=1})
-- spools on the bench: little drums of thread, lit tops
local cols = {pile{{"cadmium red",1},{"burnt sienna",0.4}, medium=0.06}, pile{{"yellow ochre",1},{"lead white",0.5}, medium=0.06}, pile{{"lead white",1.4},{"yellow ochre",0.3}, medium=0.06}, pile{{"viridian",0.5},{"raw sienna",0.6},{"lead white",0.5}, medium=0.06}}
for i, x in ipairs{510, 538, 600, 660} do
  local m = rect(x - 9, 398, 18, 22)
  work(m, {hand="detail", pile=cols[i], coverage=6, fill=true, clip=m, load=1})
  st({{x - 11, 398}, {x + 11, 398}}, brD, 3, {0.9, 0.9})
  st({{x - 11, 420}, {x + 11, 420}}, brD, 3, {0.9, 0.9})
  st({{x - 8, 400}, {x - 8, 418}}, brL, 1.4, {0.5, 0.5})
end
-- bone pins in a little cushion
local cush = ellipse(565, 414, 13, 7)
work(cush, {hand="detail", pile=pile{{"cadmium red",0.6},{"burnt sienna",0.8},{"bone black",0.4}, medium=0.06}, coverage=6, fill=true, clip=cush, load=1})
for _, q in ipairs{{-6, -0.4}, {0, 0}, {6, 0.35}, {3, -0.2}} do
  st({{565 + q[1], 412}, {565 + q[1] + 14 * math.sin(q[2]), 412 - 14 * math.cos(q[2])}}, pile{{"lead white",1.8},{"yellow ochre",0.4}, medium=0.05}, 1.2, {0.7, 0.4})
end
-- the docent seated on a stool, profile facing right
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
STOOL = rect(268, 470, 70, 10) + rect(280, 480, 8, 80) + rect(320, 480, 8, 80)
work(STOOL, {hand="detail", pile=brD, coverage=6, fill=true, clip=STOOL, load=1})
BODY = poly({{290, 250}, {330, 238}, {356, 262}, {372, 330}, {376, 400}, {440, 410}, {455, 445}, {440, 470}, {300, 476}, {270, 430}, {268, 330}}, true)
work(BODY, {hand="body", tool="filbert 5", pile=robeD, coverage=7, fill=true, clip=BODY, angle=math.pi/2, load=1})
HEAD = ellipse(352, 236, 26, 30)
work(HEAD, {hand="detail", pile=robeD, coverage=7, fill=true, clip=HEAD, load=1})
FACE = poly({{360, 228}, {378, 236}, {382, 262}, {370, 270}, {360, 252}}, true)
work(FACE, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}, coverage=6, fill=true, clip=FACE, load=1})
-- the robe falling below the knees to the floor
local skirt = poly({{300, 470}, {440, 465}, {450, 560}, {290, 562}}, true)
work(skirt, {hand="body", tool="filbert 4", pile=robeD, coverage=7, fill=true, clip=skirt, angle=math.pi/2, load=1})

--@ chunk 3
-- the crimson tabard across the docent's knees, hanging down in folds; its arms bent to the work, needle and thread;
-- the Commando standing at the right without his tabard, helm bowed, waiting
print(wait(3*24*60))
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
TAB = poly({{352, 398}, {462, 404}, {474, 430}, {466, 520}, {448, 548}, {420, 540}, {402, 556}, {378, 538}, {372, 470}, {350, 440}}, true)
work(TAB, {hand="body", tool="filbert 4", pile=pile{{"cadmium red",0.8},{"rose madder",0.4},{"burnt sienna",0.5},{"bone black",0.5}, medium=0.06}, coverage=7, fill=true, clip=TAB, angle=math.pi/2, load=1})
-- arms: upper arm from the shoulder, forearm out to the hands over the lap
ARMS = ribbon({{338, 280}, {352, 345}, {392, 388}, {420, 392}}, {26, 22, 18, 14}) + ribbon({{318, 290}, {330, 352}, {378, 396}}, {20, 18, 14})
work(ARMS, {hand="body", tool="filbert 3", pile=robeD, coverage=7, fill=true, clip=ARMS, angle=0.5, load=1})
-- jointed bone fingers, the bronze needle, the thread lifted in an arc
local bone = pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}
st({{418, 390}, {428, 386}, {434, 382}}, bone, 3.4, {0.8, 0.5})
st({{420, 396}, {432, 395}, {438, 391}}, bone, 2.6, {0.7, 0.4})
st({{380, 398}, {392, 404}, {402, 406}}, bone, 3, {0.8, 0.5})
st({{434, 382}, {446, 372}}, pile{{"yellow ochre",1},{"Mars orange",0.4},{"lead white",0.5}, medium=0.05}, 1.4, {0.9, 0.3})
st({{446, 372}, {470, 330}, {486, 300}, {492, 296}}, pile{{"cadmium red",1},{"lead white",0.3}, medium=0.05}, 0.8, {0.5, 0.2})
-- the Commando
local k = 150
local fx, fy = 810, 600
local function Q(x, y) return {fx + x * k, fy - y * k} end
FIG = ribbon({Q(-0.11, 0.93), Q(-0.13, 0.5), Q(-0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + ribbon({Q(0.11, 0.93), Q(0.13, 0.5), Q(0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + poly({Q(-0.26, 0.0), Q(-0.04, 0.0), Q(-0.05, 0.14), Q(-0.23, 0.14)}) + poly({Q(0.04, 0.0), Q(0.25, 0.0), Q(0.23, 0.14), Q(0.05, 0.14)})
  + poly({Q(-0.19, 0.88), Q(0.19, 0.88), Q(0.2, 1.06), Q(-0.2, 1.06)}, true)
  + poly({Q(-0.17, 1.02), Q(0.17, 1.02), Q(0.23, 1.32), Q(0.3, 1.5), Q(0.27, 1.58), Q(0.1, 1.61), Q(-0.1, 1.61), Q(-0.27, 1.58), Q(-0.3, 1.5), Q(-0.23, 1.32)}, true)
  + poly({Q(-0.06, 1.53), Q(0.03, 1.53), Q(0.0, 1.63), Q(-0.09, 1.63)})
  + ellipse(fx - 0.07 * k, fy - 1.72 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3, 1.5), Q(-0.34, 1.24), Q(-0.28, 0.98)}, {0.12 * k, 0.1 * k, 0.09 * k})
  + ribbon({Q(0.3, 1.5), Q(0.35, 1.24), Q(0.31, 0.98)}, {0.12 * k, 0.1 * k, 0.09 * k})
work(FIG, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.8},{"ultramarine ash",0.4},{"burnt sienna",0.5}, medium=0.06}, coverage=7, fill=true, clip=FIG, angle=math.pi/2, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 4
-- on set paint: the Commando given plates in a mid tone so he stands out of the dark wall, lamp light on the plates facing
-- left and up; the tabard's folds and its wire-mended bone cross; the lamp's light on the docent's hood, shoulders, sleeves
print(wait(6*24*60))
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local mid = pile{{"bone black",1.2},{"ultramarine ash",0.5},{"burnt sienna",0.6},{"raw sienna",0.2}, medium=0.06}
local hot = pile{{"lead white",1.5},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.05}
local warm = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.5}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, swell={0.7, 1.1, 0.6}, ramps={0.1, 0.3}, clip=clipm})
end
-- plates: mid tone on the left half of each, seams left dark
local plates = {
  ellipse(fx - 0.07 * k, fy - 1.72 * k, 0.09 * k, 0.11 * k),
  ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.1 * k, 0.065 * k),
  poly({Q(-0.2, 1.56), Q(0.0, 1.56), Q(0.0, 1.08), Q(-0.16, 1.08), Q(-0.22, 1.3)}),
  poly({Q(-0.19, 1.04), Q(0.0, 1.04), Q(0.0, 0.9), Q(-0.2, 0.9)}),
  ribbon({Q(-0.3, 1.44), Q(-0.33, 1.26)}, 0.08 * k), ribbon({Q(-0.33, 1.2), Q(-0.29, 1.0)}, 0.07 * k),
  ribbon({Q(-0.11, 0.86), Q(-0.13, 0.56)}, 0.12 * k), ribbon({Q(-0.13, 0.46), Q(-0.14, 0.16)}, 0.09 * k),
}
for _, m in ipairs(plates) do work(m, {hand="body", tool="filbert 3", pile=mid, coverage=6, fill=true, clip=m, angle=math.pi/2, load=1}) end
local Fg = FIG:grow(1.5)
st({Q(-0.12, 1.82), Q(-0.17, 1.74), Q(-0.15, 1.64)}, hot, 3, {0.9, 0.4}, Fg)
st({Q(-0.38, 1.6), Q(-0.42, 1.52), Q(-0.38, 1.47)}, hot, 3.2, {0.9, 0.6}, Fg)
st({Q(-0.22, 1.56), Q(-0.24, 1.32), Q(-0.17, 1.1)}, warm, 2.4, {0.8, 0.2}, Fg)
st({Q(-0.38, 1.42), Q(-0.41, 1.25)}, warm, 2.2, {0.8, 0.3}, Fg)
st({Q(-0.38, 1.18), Q(-0.35, 1.0)}, warm, 2, {0.7, 0.3}, Fg)
st({Q(-0.2, 1.03), Q(-0.21, 0.91)}, warm, 1.8, {0.7, 0.4}, Fg)
st({Q(-0.2, 0.85), Q(-0.22, 0.58)}, warm, 1.8, {0.6, 0.2}, Fg)
st({Q(-0.2, 0.45), Q(-0.21, 0.18)}, warm, 1.6, {0.5, 0.1}, Fg)
-- the tabard's folds and the bone cross, mended with wire
local foldL = pile{{"cadmium red",1},{"vermilion",0.35},{"lead white",0.25}, medium=0.06}
local foldD = pile{{"bone black",1.6},{"rose madder",0.4},{"burnt sienna",0.4}, medium=0.06}
for _, x in ipairs{380, 410, 440} do
  st({{x, 420}, {x - 2, 480}, {x + 2, 540}}, foldD, 4, {0.6, 0.9}, TAB)
  st({{x - 7, 420}, {x - 9, 480}, {x - 6, 535}}, foldL, 2.6, {0.7, 0.6}, TAB)
end
st({{356, 400}, {462, 405}}, foldL, 3, {0.8, 0.8}, TAB:grow(1))
local bone = pile{{"lead white",1.9},{"yellow ochre",0.35}, medium=0.04}
st({{416, 418}, {416, 478}}, bone, 5, {0.9, 0.9})
st({{398, 436}, {434, 436}}, bone, 5, {0.9, 0.9})
local wire = pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.6}, medium=0.05}
for _, y in ipairs{446, 452, 458} do st({{411, y}, {421, y + 2}}, wire, 1, {0.7, 0.7}) end
-- the docent: lamp light on crown, shoulder line, the top of the sleeves
local Dg = (BODY + HEAD + ARMS):grow(1.5)
st({{330, 214}, {350, 206}, {370, 212}}, hot, 3.4, {0.7, 0.9}, Dg)
st({{298, 248}, {326, 238}, {350, 252}}, warm, 3.6, {0.7, 0.8}, Dg)
st({{342, 272}, {356, 335}, {392, 380}, {420, 384}}, warm, 2.6, {0.8, 0.4}, Dg)
st({{356, 262}, {372, 330}, {378, 392}}, warm, 2, {0.7, 0.2}, Dg)
