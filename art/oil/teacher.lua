-- easel session "teacher": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=4/3, linen={18,16}, seed=4747,
  ground={{pile={{"bone black",1},{"burnt sienna",1},{"raw sienna",0.4},{"lead white",0.5}}, um=110, apply="knife", texture=0.4}}}
-- a small warm schoolroom: back wall to y 540, floor below; one lamp hung over the slate and bench
LX, LY = 430, 80
FLOORY = 540
WALLM = rect(0, 0, 1000, FLOORY)
FLOORM = rect(0, FLOORY, 1000, 220)
DOOR = rect(820, 170, 130, 372)
SLATE = rect(150, 140, 400, 250)
local wD = pile{{"bone black",1.8},{"burnt sienna",0.8},{"ultramarine blue",0.2}, medium=0.06}
local wM = pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
local wL = pile{{"burnt sienna",1},{"raw sienna",0.9},{"yellow ochre",0.45},{"bone black",0.4}, medium=0.06}
local W = WALLM - DOOR - SLATE
local r1 = ellipse(LX, 260, 480, 360)
local r2 = ellipse(LX, 230, 300, 230)
work(W - r1, {hand="body", tool="filbert 12", pile=wD, coverage=4, fill=true, clip=W - r1, angle=math.pi/2, load=1})
work((W * r1) - r2, {hand="body", tool="filbert 12", pile=wM, coverage=4, fill=true, clip=(W * r1) - r2, angle=math.pi/2, load=1})
work(W * r2, {hand="body", tool="filbert 10", pile=wL, coverage=4, fill=true, clip=W * r2, angle=math.pi/2, load=1})
blend(W * (ellipse(LX, 260, 500, 378) - ellipse(LX, 260, 460, 342)))
blend(W * (ellipse(LX, 230, 318, 246) - ellipse(LX, 230, 282, 214)))
local fD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}
local fL = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.55},{"yellow ochre",0.25}, medium=0.06}
local fp = ellipse(LX + 20, 640, 420, 110)
work(FLOORM - fp, {hand="body", tool="filbert 12", pile=fD, coverage=4, fill=true, clip=FLOORM - fp, angle=0, load=1})
work(FLOORM * fp, {hand="body", tool="filbert 10", pile=fL, coverage=4, fill=true, clip=FLOORM * fp, angle=0, load=1})
blend(FLOORM * (ellipse(LX + 20, 640, 440, 124) - ellipse(LX + 20, 640, 400, 96)), {angle=0})
-- the doorway: a cooler grey corridor beyond (the MIRIAD side)
work(DOOR, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.5},{"ultramarine ash",0.8},{"lead white",0.25}, medium=0.06}, coverage=5, fill=true, clip=DOOR, angle=math.pi/2, load=1})
-- the slate: near-black, in a bronze frame
work(SLATE, {hand="body", tool="filbert 8", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.25}, medium=0.06}, coverage=6, fill=true, clip=SLATE, angle=0, load=1})
local fr = rect(140, 130, 420, 270) - SLATE
work(fr, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.6}, medium=0.06}, coverage=6, fill=true, clip=fr, load=1})
local sk = rect(0, FLOORY - 6, 1000, 12) - DOOR
work(sk, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=sk, load=1})
print(W, H)

--@ chunk 2
-- door darkened; the lamp; the chalked glyph on the slate; the docent at the slate's right, its arm up with the chalk
print(wait(4*24*60))
work(DOOR, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.8},{"ultramarine ash",0.6},{"lead white",0.1}, medium=0.06}, coverage=7, fill=true, clip=DOOR, angle=math.pi/2, load=1})
local jamb = rect(810, 160, 150, 382) - DOOR
work(jamb, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.7}, medium=0.06}, coverage=6, fill=true, clip=jamb, load=1})
local brD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
-- lamp
st({{LX, 0}, {LX, LY - 18}}, brD, 2, {0.9, 0.9})
local shade = poly({{LX - 14, LY - 20}, {LX + 14, LY - 20}, {LX + 38, LY}, {LX - 38, LY}}, true)
work(shade, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.7}, medium=0.06}, coverage=6, fill=true, clip=shade, load=1})
st({{LX - 13, LY - 19}, {LX + 13, LY - 19}}, brL, 2, {0.6, 0.6})
local bulb = ellipse(LX, LY + 3, 16, 5)
work(bulb, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.03}, coverage=6, fill=true, clip=bulb, load=1})
-- chalk: a room-glyph (pentagon) holding a smaller turned copy, edge ticks, a gluing arc to a second glyph,
-- and a self-gluing arc that leaves the big room and comes back to it
local chalk = pile{{"lead white",1.8},{"zinc white",0.5},{"yellow ochre",0.08}, medium=0.04}
local function pg(cx, cy, n, r, rot, w)
  local p = {}
  for j = 0, n - 1 do local a = rot + 2 * math.pi * j / n; p[#p+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
  for j = 1, n do st({p[j], p[j % n + 1]}, chalk, w, {0.75, 0.7}, SLATE) end
  return p
end
local P1 = pg(300, 270, 5, 88, -math.pi / 2, 3.4)
pg(300, 270, 5, 88 * 0.618, -math.pi / 2 + 0.6, 2.6)
pg(300, 270, 5, 88 * 0.382, -math.pi / 2 + 1.2, 2.0)
local P2 = pg(470, 205, 4, 40, 0.3, 2.8)
-- edge ticks on two edges of the big room
for _, e in ipairs{{1, 2, 1}, {3, 4, 2}} do
  local a, b = P1[e[1]], P1[e[2]]
  local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
  local nx, ny = mx - 300, my - 270
  local L = math.sqrt(nx * nx + ny * ny); nx, ny = nx / L, ny / L
  for t = 1, e[3] do
    local ox, oy = (b[1] - a[1]) * 0.08 * (t - (e[3] + 1) / 2), (b[2] - a[2]) * 0.08 * (t - (e[3] + 1) / 2)
    st({{mx + ox, my + oy}, {mx + ox + nx * 12, my + oy + ny * 12}}, chalk, 2, {0.7, 0.7}, SLATE)
  end
end
-- gluing arc from the big room's upper-right edge to the small room
st({{372, 230}, {410, 185}, {440, 200}}, chalk, 2.4, {0.7, 0.7}, SLATE)
-- self-gluing: an arc leaves the lower-left edge and returns to the left edge
st({{232, 330}, {180, 360}, {170, 300}, {218, 262}}, chalk, 2.4, {0.7, 0.7}, SLATE)
-- the docent at the slate's right, turned to it, right arm raised to the small glyph with the chalk
local robeD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
DROBE = poly({{588, 230}, {628, 222}, {660, 270}, {680, 420}, {690, 540}, {560, 545}, {568, 420}, {574, 290}}, true)
work(DROBE, {hand="body", tool="filbert 5", pile=robeD, coverage=7, fill=true, clip=DROBE, angle=math.pi/2, load=1})
DHEAD = ellipse(600, 205, 25, 29)
work(DHEAD, {hand="detail", pile=robeD, coverage=7, fill=true, clip=DHEAD, load=1})
DFACE = poly({{590, 190}, {576, 200}, {574, 224}, {586, 230}, {594, 212}}, true)
work(DFACE, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.05}, coverage=7, fill=true, clip=DFACE, load=1})
DARM = ribbon({{590, 250}, {556, 232}, {522, 214}}, {20, 15, 12})
work(DARM, {hand="detail", pile=robeD, coverage=7, fill=true, clip=DARM, load=1})
st({{522, 214}, {512, 208}}, pile{{"lead white",1.8},{"yellow ochre",0.45}, medium=0.05}, 5, {0.9, 0.6})
local ch = ellipse(507, 205, 3.5, 3.5)
work(ch, {hand="detail", pile=chalk, coverage=7, fill=true, clip=ch, load=1})

--@ chunk 3
-- the low bench and the three children seen from behind, grey coveralls, copying onto little bone tablets; the middle one's
-- hand up; the Commando in the doorway, listening
print(wait(2*24*60))
local brD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5}, medium=0.06}
local grey = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.6},{"burnt sienna",0.15}, medium=0.06}
local greyL = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"yellow ochre",0.3},{"bone black",0.3}, medium=0.06}
local hair = {pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}, pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.4}, medium=0.06}, pile{{"raw sienna",1},{"yellow ochre",0.6},{"bone black",0.3}, medium=0.06}}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.04, 0.1}, clip=clipm})
end
-- the bench: a long low plank on short legs
BENCH = rect(220, 640, 520, 16) + rect(240, 656, 12, 50) + rect(708, 656, 12, 50)
work(BENCH, {hand="detail", pile=brD, coverage=7, fill=true, clip=BENCH, load=1})
st({{220, 641}, {740, 641}}, brL, 2.4, {0.7, 0.7})
KIDS = {}
for i, c in ipairs{{335, false, -0.1}, {480, true, 0.05}, {620, false, 0.12}} do
  local x, up, lean = c[1], c[2], c[3]
  local body = poly({{x - 34, 645}, {x + 34, 645}, {x + 30, 590}, {x + 20, 548}, {x - 20, 548}, {x - 30, 590}}, true)
  work(body, {hand="body", tool="filbert 4", pile=grey, coverage=7, fill=true, clip=body, angle=math.pi/2, load=1})
  local head = ellipse(x + lean * 30, 520, 21, 24)
  work(head, {hand="detail", pile=hair[i], coverage=7, fill=true, clip=head, load=1})
  -- lamp light on top of heads and shoulders
  st({{x - 18 + lean * 30, 504}, {x + lean * 30, 497}, {x + 16 + lean * 30, 503}}, (i == 1) and brL or pile{{"yellow ochre",1},{"lead white",0.7},{"Mars orange",0.15}, medium=0.06}, 3, {0.6, 0.7})
  st({{x - 28, 560}, {x - 16, 550}, {x + 16, 550}, {x + 28, 560}}, greyL, 3.4, {0.6, 0.6})
  st({{x, 552}, {x, 640}}, pile{{"bone black",1.4},{"ultramarine ash",0.5}, medium=0.06}, 2, {0.5, 0.5})
  -- each child's tablet tilted up on the knees, seen just past the shoulder
  local tab = poly({{x + 22, 578}, {x + 48, 572}, {x + 50, 606}, {x + 24, 610}})
  work(tab, {hand="detail", pile=pile{{"lead white",1.7},{"yellow ochre",0.5}, medium=0.05}, coverage=7, fill=true, clip=tab, load=1})
  -- a tiny copied glyph on it
  st({{x + 30, 584}, {x + 40, 582}, {x + 43, 592}, {x + 36, 600}, {x + 28, 596}, {x + 30, 584}}, pile{{"bone black",1.5},{"burnt sienna",0.5}, medium=0.06}, 1.1, {0.6, 0.6}, tab)
  if up then
    local arm = ribbon({{x - 16, 556}, {x - 26, 500}, {x - 24, 452}}, {13, 10, 9})
    work(arm, {hand="detail", pile=grey, coverage=7, fill=true, clip=arm, load=1})
    st({{x - 26, 500}, {x - 24, 456}}, greyL, 2.6, {0.6, 0.6}, arm:grow(1))
    local hand = ellipse(x - 24, 444, 8, 10)
    work(hand, {hand="detail", pile=pile{{"lead white",1.5},{"rose madder",0.15},{"yellow ochre",0.3}, medium=0.05}, coverage=7, fill=true, clip=hand, load=1})
  end
  KIDS[i] = body + head
end
-- the Commando in the doorway, facing into the room, listening
local k = 168
local fx, fy = 886, 542
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11, 0.93), Q(-0.13, 0.5), Q(-0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + ribbon({Q(0.11, 0.93), Q(0.13, 0.5), Q(0.14, 0.1)}, {0.17 * k, 0.13 * k, 0.11 * k})
  + poly({Q(-0.26, 0.0), Q(-0.04, 0.0), Q(-0.05, 0.14), Q(-0.23, 0.14)}) + poly({Q(0.04, 0.0), Q(0.25, 0.0), Q(0.23, 0.14), Q(0.05, 0.14)})
  + poly({Q(-0.19, 0.88), Q(0.19, 0.88), Q(0.2, 1.06), Q(-0.2, 1.06)}, true)
  + poly({Q(-0.17, 1.02), Q(0.17, 1.02), Q(0.23, 1.32), Q(0.3, 1.5), Q(0.27, 1.58), Q(0.1, 1.61), Q(-0.1, 1.61), Q(-0.27, 1.58), Q(-0.3, 1.5), Q(-0.23, 1.32)}, true)
  + poly({Q(-0.05, 1.55), Q(0.05, 1.55), Q(0.05, 1.67), Q(-0.05, 1.67)})
  + ellipse(fx - 0.02 * k, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3, 1.5), Q(-0.34, 1.24), Q(-0.3, 0.98)}, {0.12 * k, 0.1 * k, 0.09 * k})
  + ribbon({Q(0.3, 1.5), Q(0.35, 1.24), Q(0.31, 0.98)}, {0.12 * k, 0.1 * k, 0.09 * k})
FIG = fig
work(fig, {hand="body", tool="filbert 4", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.4}, medium=0.06}, coverage=7, fill=true, clip=fig, angle=math.pi/2, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 4
-- on set paint: the Commando restated opaque, then his room-side edge warm from the lamp; the docent's crown and shoulders lit;
-- the children's heads and shoulders lit from above
print(wait(5*24*60))
work(FIG, {hand="body", tool="filbert 4", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.4}, medium=0.06}, coverage=8, fill=true, clip=FIG, angle=math.pi/2, load=1})
print(wait(5*24*60))
local hot = pile{{"lead white",1.7},{"yellow ochre",0.7},{"cadmium yellow",0.2}, medium=0.05}
local warm = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, swell={0.7, 1.1, 0.7}, ramps={0.08, 0.25}, clip=clipm})
end
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local Fg = FIG:grow(1.5)
st({Q(-0.06, 1.88), Q(-0.12, 1.8), Q(-0.12, 1.68)}, warm, 2.8, {0.8, 0.4}, Fg)
st({Q(-0.4, 1.58), Q(-0.42, 1.48), Q(-0.4, 1.4)}, warm, 2.8, {0.8, 0.5}, Fg)
st({Q(-0.43, 1.36), Q(-0.45, 1.2), Q(-0.41, 0.98)}, warm, 2.2, {0.7, 0.2}, Fg)
st({Q(-0.22, 0.9), Q(-0.24, 0.5), Q(-0.24, 0.14)}, warm, 2, {0.6, 0.1}, Fg)
local Dg = (DROBE + DHEAD + DARM):grow(1.5)
st({{582, 180}, {600, 174}, {618, 182}}, hot, 3.2, {0.8, 0.8}, Dg)
st({{608, 228}, {632, 222}, {656, 264}}, warm, 3.2, {0.8, 0.7}, Dg)
st({{588, 242}, {556, 224}, {524, 206}}, warm, 2.4, {0.7, 0.4}, Dg)
st({{574, 290}, {568, 420}, {562, 540}}, warm, 2.4, {0.7, 0.15}, Dg)
for i, x in ipairs{335, 480, 620} do
  local lean = ({-0.1, 0.05, 0.12})[i]
  local hx = x + lean * 30
  st({{hx - 16, 505}, {hx, 497}, {hx + 15, 504}}, hot, 3, {0.7, 0.7}, KIDS[i]:grow(1))
  st({{x - 28, 558}, {x - 14, 549}, {x + 14, 549}, {x + 28, 558}}, warm, 3, {0.7, 0.7}, KIDS[i]:grow(1))
end
