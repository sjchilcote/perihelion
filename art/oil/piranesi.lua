-- easel session "piranesi": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=3/4, linen={18,16}, seed=1761,
  ground={{pile={{"lead white",3},{"yellow ochre",0.5},{"raw sienna",0.2}}, um=70, apply="knife", texture=0.2}}}
-- H is 1333
INK = pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.3}}
WASH = pile{{"burnt sienna",1},{"bone black",0.6},{"raw sienna",0.4}, medium=0.85}
WASHD = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.2}, medium=0.75}
-- big shapes as washes: far gallery haze, the great piers in shadow, the vault's underside
local function archBand(cx, spring, crown, rIn, rOut)
  return mask(function(x, y)
    local dx = (x - cx) / rOut; local dy = (y - spring) / (spring - crown)
    local o = dx*dx + dy*dy
    local dxi = (x - cx) / rIn; local dyi = (y - spring) / (spring - crown - (rOut - rIn))
    local i = dxi*dxi + dyi*dyi
    return (y <= spring and o <= 1 and i > 1) and 1 or 0
  end)
end
PIERL = poly({{0, 0}, {210, 0}, {225, 1333}, {0, 1333}})
PIERR = poly({{800, 0}, {1000, 0}, {1000, 1333}, {790, 1333}})
ARCH1 = archBand(505, 470, 70, 300, 360)
ARCH2 = archBand(500, 640, 330, 170, 205)
work(rect(200, 330, 600, 700), {hand="glaze", pile=WASH, coverage=0.8, fill=true, clip=true, angle=math.pi/2, load=0.3, pressure={0.1, 0.2}})
work(PIERL + PIERR, {hand="glaze", pile=WASH, coverage=1.4, fill=true, clip=true, angle=math.pi/2, load=0.45})
work(ARCH1, {hand="glaze", pile=WASH, coverage=1.3, fill=true, clip=true, angle=0.3, load=0.4})
work(ARCH2, {hand="glaze", pile=WASH, coverage=1.1, fill=true, clip=true, angle=0.3, load=0.35})
work(poly({{0, 0}, {80, 0}, {95, 1333}, {0, 1333}}), {hand="glaze", pile=WASHD, coverage=1.6, fill=true, clip=true, angle=math.pi/2, load=0.5})
print(wait(3*1440))

--@ chunk 2
PAPER = pile{{"lead white",3},{"yellow ochre",0.35},{"bone brown",0.12}}
T1 = pile{{"lead white",2.2},{"bone brown",0.45},{"yellow ochre",0.2}}
T2 = pile{{"lead white",1.4},{"bone brown",0.8},{"bone black",0.08}}
T3 = pile{{"lead white",0.7},{"bone brown",1},{"bone black",0.25}}
T4 = pile{{"bone brown",1},{"bone black",0.5},{"lead white",0.2}}
work(rect(0, 0, 1000, 1333) - PIERL - PIERR, {hand="body", pile=PAPER, coverage=3.2, fill=true, clip=true, angle=math.pi/2, load=1})
work(PIERL - poly({{0, 0}, {80, 0}, {95, 1333}, {0, 1333}}), {hand="body", pile=T3, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(poly({{0, 0}, {80, 0}, {95, 1333}, {0, 1333}}), {hand="body", pile=T4, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(PIERR, {hand="body", pile=T2, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
-- vault undersides in half-tone, the far gallery a pale haze (painted, then softened)
work(ARCH1, {hand="body", tool="filbert 6", pile=T2, coverage=3.5, fill=true, clip=true, angle=0.3, load=1})
work(ARCH2, {hand="body", tool="filbert 5", pile=T1, coverage=3.5, fill=true, clip=true, angle=0.3, load=1})
print(wait(4*1440))

--@ chunk 3
INK = pile{{"bone brown",1},{"burnt sienna",0.55},{"raw sienna",0.3},{"bone black",0.2}}
function ln(pts, w, pr)
  local b = brush{kind="round", width=w or 1.8, point=0.6}
  b:reload(INK, 0.75); b:stroke(pts, {pressure=pr or {0.6, 0.55}, ramps={0.04, 0.08}, shake=0.4})
end
function arcPts(cx, spring, rx, ry, a0, a1, n)
  local p = {} for i = 0, n do local a = a0 + (a1 - a0) * i / n; p[#p+1] = {cx + rx * math.cos(a), spring - ry * math.sin(a)} end return p
end
-- arch 1 (great vault), arch 2 behind
ln(arcPts(505, 470, 360, 400, 0, math.pi, 40), 2.6)
ln(arcPts(505, 470, 300, 340, 0, math.pi, 40), 2.2)
for i = 1, 17 do local a = math.pi * i / 18; ln({{505 + 300*math.cos(a), 470 - 340*math.sin(a)}, {505 + 360*math.cos(a), 470 - 400*math.sin(a)}}, 1.6) end
ln(arcPts(500, 640, 205, 310, 0, math.pi, 30), 2)
ln(arcPts(500, 640, 170, 275, 0, math.pi, 30), 1.6)
for i = 1, 11 do local a = math.pi * i / 12; ln({{500 + 170*math.cos(a), 640 - 275*math.sin(a)}, {500 + 205*math.cos(a), 640 - 310*math.sin(a)}}, 1.2) end
-- piers' edges and courses
ln({{210, 0}, {225, 1333}}, 2.8); ln({{800, 0}, {790, 1333}}, 2.8)
for y = 60, 1300, 74 do ln({{95, y}, {222, y + 2}}, 1.4); ln({{792, y + 30}, {1000, y + 28}}, 1.4) end
-- floor and flagstones
ln({{225, 1180}, {790, 1180}}, 1.8)
for x = 250, 780, 70 do ln({{x, 1180}, {500 + (x - 500) * 2.2, 1333}}, 1.1) end
for _, y in ipairs({1215, 1260, 1315}) do ln({{225, y}, {790, y}}, 1.1) end
-- far gallery through arch 2: a colonnade of small arches, the portal seam in the middle
ln({{330, 760}, {670, 760}}, 1.4); ln({{330, 650}, {670, 650}}, 1.2)
for x = 345, 655, 52 do ln(arcPts(x + 26, 700, 18, 26, 0, math.pi, 10), 1.1); ln({{x + 8, 700}, {x + 8, 760}}, 1.1); ln({{x + 44, 700}, {x + 44, 760}}, 1.1) end
-- bridge 1 (high), with its own arch, spanning pier to pier
BR1 = {y = 600}
ln({{222, 585}, {795, 585}}, 2); ln({{222, 600}, {795, 600}}, 2); ln({{222, 632}, {795, 632}}, 2)
for x = 240, 780, 22 do ln({{x, 585}, {x, 572}}, 1.2) end
ln({{222, 571}, {795, 571}}, 1.6)
ln(arcPts(510, 700, 150, 66, 0, math.pi, 20), 1.8)
-- bridge 2 (lower), crossing behind stair B
ln({{300, 760}, {700, 760}}, 1.8); ln({{300, 784}, {700, 784}}, 1.8); ln({{300, 748}, {700, 748}}, 1.3)
for x = 310, 690, 20 do ln({{x, 760}, {x, 748}}, 1.1) end
-- landing on the right pier
ln({{660, 880}, {795, 880}}, 2); ln({{660, 905}, {795, 905}}, 2); ln({{660, 880}, {660, 905}}, 2)
-- stair A: from the floor at lower left up to the landing
local function stair(x0, y0, x1, y1, n, depth)
  ln({{x0, y0}, {x1, y1}}, 2.2); ln({{x0, y0 + depth}, {x1, y1 + depth}}, 2.2)
  for i = 1, n do
    local t = i / (n + 1)
    local x, y = lerp(x0, x1, t), lerp(y0, y1, t)
    local tx = (x1 - x0) / (n + 1)
    ln({{x, y}, {x - tx, y}}, 1.3)
    ln({{x - tx, y}, {x - tx, y + (y1 - y0) / (n + 1) * -1}}, 1.0)
  end
end
stair(250, 1180, 660, 880, 18, 26)
-- stair B: from the landing up-left to bridge 1, passing in front of bridge 2
stair(660, 880, 330, 632, 15, 24)
-- stair C: from bridge 2's left end down and back toward the landing it began from
stair(300, 784, 640, 1060, 12, 20)
print(wait(3*1440))

--@ chunk 4
local INKH = pile{{"bone brown",1},{"burnt sienna",0.5},{"raw sienna",0.3},{"bone black",0.25}}
local DARK = pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.3}}
local function hatch(m, ang, cov, tool) work(m, {hand="hatch", tool=tool or "round 1.8", pile=INKH, angle=ang, coverage=cov or 1.4, clip=true, load=0.7}) end
local function band(x0, y0, x1, y1, d) return poly({{x0, y0}, {x1, y1}, {x1, y1 + d}, {x0, y0 + d}}) end
-- stair stringers (side faces) and the shadow beneath each flight
local SA = band(250, 1180, 660, 880, 26); local SB = band(660, 880, 330, 632, 24); local SC = band(300, 784, 640, 1060, 20)
hatch(SA + SB + SC, -0.6, 2.2)
hatch(poly({{250, 1206}, {660, 906}, {660, 1180}}), 1.2, 1.3)
hatch(poly({{330, 656}, {660, 904}, {330, 904}}) - SA - SC, 0.9, 1.0)
-- bridge faces and soffits
hatch(rect(222, 600, 573, 32), math.pi/2, 2.4, "round 1.6")
hatch(rect(300, 760, 400, 24), math.pi/2, 2.2, "round 1.4")
hatch(rect(660, 880, 135, 25), math.pi/2, 2.4, "round 1.6")
-- the deep shadow under bridge 1 and inside the far arches
work(rect(225, 632, 570, 18) - SB, {hand="detail", tool="round 3", pile=DARK, coverage=3.5, fill=true, load=1})
for x = 345, 655, 52 do
  local m = rect(x + 9, 700, 34, 59) + ellipse(x + 26, 700, 17, 25) * rect(x + 9, 674, 34, 26)
  work(m - SB, {hand="detail", tool="round 2", pile=DARK, coverage=3.5, fill=true, load=1})
end
-- the vault bands hatched along their curve, darker toward the left (light from upper right)
hatch(ARCH1 * rect(0, 0, 505, 1333), 0.9, 2.2)
hatch(ARCH1 * rect(505, 0, 495, 1333), -0.9, 1.1)
hatch(ARCH2 * rect(0, 0, 500, 1333), 0.9, 1.6)
-- the piers: long vertical hatching, heavier on the left
hatch(PIERL, math.pi/2 + 0.05, 2.4, "round 2.2")
hatch(PIERR, math.pi/2 - 0.05, 1.2, "round 2")
-- floor: shadow cast across it from the left pier
hatch(poly({{225, 1180}, {420, 1180}, {320, 1333}, {225, 1333}}), 0.3, 1.6)
print(wait(3*1440))

--@ chunk 5
local LIT = pile{{"lead white",3},{"yellow ochre",0.35},{"bone brown",0.1}}
local DARK = pile{{"bone brown",1},{"bone black",0.7},{"burnt sienna",0.3}}
local function st(p, w, pts, pr) local b = brush{kind="round", width=w, point=0.6}; b:reload(p, 0.75); b:stroke(pts, {pressure=pr or {0.6, 0.55}, ramps={0.04, 0.08}}) end
-- lit tread noses along each flight, a stepped profile in light
local function treads(x0, y0, x1, y1, n)
  for i = 0, n do
    local t = i / (n + 1)
    local x, y = lerp(x0, x1, t), lerp(y0, y1, t)
    local tx = (x1 - x0) / (n + 1)
    st(LIT, 2, {{x + 1, y + 2.5}, {x + tx - 1, y + 2.5}}, {0.55, 0.5})
  end
  st(LIT, 1.6, {{x0, y0 + 1.5}, {x1, y1 + 1.5}}, {0.45, 0.4})
end
treads(250, 1180, 660, 880, 18)
treads(660, 880, 330, 632, 15)
treads(300, 784, 640, 1060, 12)
st(LIT, 2, {{222, 586}, {795, 586}}, {0.5, 0.5})
st(LIT, 1.8, {{300, 761}, {700, 761}}, {0.5, 0.5})
st(LIT, 1.8, {{660, 881}, {795, 881}}, {0.5, 0.5})
-- ropes and a pulley hanging from the vault
st(DARK, 1.6, {{640, 150}, {636, 380}, {634, 520}}, {0.55, 0.55})
st(DARK, 1.6, {{655, 150}, {652, 400}}, {0.5, 0.5})
local pul = {} for i = 0, 20 do local a = i * math.pi / 10; pul[#pul+1] = {645 + 9 * math.cos(a), 160 + 9 * math.sin(a)} end
st(DARK, 2.4, pul, {0.7, 0.7})
st(DARK, 2.2, {{634, 520}, {628, 532}, {636, 540}, {642, 532}}, {0.65, 0.65})
st(DARK, 1.3, {{380, 120}, {372, 300}, {360, 470}, {350, 560}}, {0.5, 0.45})
-- the portal seam in the far gallery: one arch opening split by a pale slit
local b = brush{kind="round", width=3, point=0.7}
b:reload(pile{{"lead white",3},{"lemon chrome",0.15}}, 0.8); b:stroke({{502, 684}, {502, 756}}, {pressure={0.1, 0.7}, swell={0.4, 1, 1, 0.5}, ramps={0.2, 0.2}})
-- the same figure, four times around the loop
local function fig(x, y, s)
  s = s or 1
  local fb = brush{kind="round", width=2.4 * s, point=0.4}
  fb:reload(DARK, 0.9)
  fb:touch(x, y - 15 * s, {pressure=0.6})
  fb:stroke({{x, y - 13 * s}, {x, y - 6 * s}}, {pressure={0.75, 0.7}})
  fb:stroke({{x - 0.6 * s, y - 6 * s}, {x - 1.6 * s, y}}, {pressure={0.55, 0.5}})
  fb:stroke({{x + 0.6 * s, y - 6 * s}, {x + 2 * s, y - 0.5 * s}}, {pressure={0.55, 0.5}})
  local rb = brush{kind="round", width=1.2 * s, point=0.6}
  rb:reload(pile{{"vermilion",0.3},{"burnt sienna",1},{"bone brown",0.4}}, 0.7)
  rb:stroke({{x - 1, y - 12 * s}, {x - 5 * s, y - 10 * s}}, {pressure={0.5, 0.1}})
end
fig(470, 584, 1.2)
fig(585, 759, 1.0)
fig(560, 1236, 1.6)
fig(455, 1032, 1.3)
print(wait(2*1440))

--@ chunk 6
local INKL = pile{{"bone brown",1},{"burnt sienna",0.5},{"raw sienna",0.4},{"lead white",0.6}}
local wallZ = rect(225, 60, 568, 520) - ARCH1 - ARCH2 - rect(330, 640, 340, 130)
local inner2 = mask(function(x, y) local dx = (x - 500) / 170; local dy = (y - 640) / 275; return (y < 640 and dx*dx + dy*dy < 1) and 1 or 0 end)
work(wallZ - inner2, {hand="hatch", tool="round 1.2", pile=INKL, angle=-0.9, coverage=0.35, clip=true, load=0.5})
work((wallZ - inner2) * rect(225, 60, 200, 520), {hand="hatch", tool="round 1.2", pile=INKL, angle=0.7, coverage=0.3, clip=true, load=0.5})
