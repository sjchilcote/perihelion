-- easel session "docent_garden": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=5151,
  ground={{pile={{"bone black",1},{"burnt sienna",1},{"raw sienna",0.3},{"lead white",0.45}}, um=110, apply="knife", texture=0.4}}}
-- a close, near-frontal view: back wall, low ceiling, the floor, a raised bronze bed across the middle; skylight above the docent
CEILY = 70
FLOORY = 470
CEILM = rect(0, 0, 1000, CEILY)
WALLM = rect(0, CEILY, 1000, FLOORY - CEILY)
FLOORM = rect(0, FLOORY, 1000, 200)
SKY = poly({{360, 0}, {540, 0}, {530, CEILY}, {370, CEILY}})
-- the light: a cone from the skylight down onto the docent and the bed, widening
CONE = poly({{370, CEILY}, {530, CEILY}, {640, 540}, {250, 540}})
-- the bed: a long bronze trough on short legs, front face and top
BEDF = rect(180, 400, 560, 56)
BEDT = poly({{190, 388}, {730, 388}, {740, 400}, {180, 400}})
DOOR = rect(812, 150, 112, 320)
local dk = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local dk2 = pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
work(CEILM - SKY, {hand="body", tool="filbert 10", pile=pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.2}, medium=0.06}, coverage=4, fill=true, clip=CEILM - SKY, angle=0, load=1})
work(WALLM - DOOR, {hand="body", tool="filbert 12", pile=dk, coverage=4, fill=true, clip=WALLM - DOOR, angle=math.pi/2, load=1})
work(FLOORM, {hand="body", tool="filbert 12", pile=dk2, coverage=4, fill=true, clip=FLOORM, angle=0, load=1})
work(DOOR, {hand="body", tool="filbert 6", pile=pile{{"bone black",2},{"ultramarine blue",0.5}, medium=0.06}, coverage=5, fill=true, clip=DOOR, angle=math.pi/2, load=1})
work(SKY, {hand="body", tool="filbert 4", pile=pile{{"zinc white",2.5},{"lemon chrome",0.06},{"cerulean blue",0.04}, medium=0.04}, coverage=5, fill=true, clip=SKY, angle=0, load=1})

--@ chunk 2
-- the fall of corona light in three opaque steps, only a little lighter than the dark at its edge; a pool on the floor;
-- the bed laid in bronze, its top lit where the light lands
print(wait(3*24*60))
local function tz(t) -- trapezoid shrunk toward the axis
  local ax = 450
  return poly({{ax + (370 - ax) * t, CEILY}, {ax + (530 - ax) * t, CEILY}, {ax + (640 - ax) * t, 540}, {ax + (250 - ax) * t, 540}})
end
local A, B, C = tz(1.0), tz(0.72), tz(0.42)
local a = pile{{"bone black",1.2},{"burnt sienna",0.9},{"raw sienna",0.4},{"lead white",0.25}, medium=0.06}
local b = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.6},{"lead white",0.55}, medium=0.06}
local c = pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.4},{"raw sienna",0.3}, medium=0.06}
local ang = math.pi / 2
work((A - B) - DOOR, {hand="body", tool="filbert 6", pile=a, coverage=5, fill=true, clip=(A - B), angle=ang, load=1})
work(B - C, {hand="body", tool="filbert 5", pile=b, coverage=5, fill=true, clip=B - C, angle=ang, load=1})
work(C, {hand="body", tool="filbert 4", pile=c, coverage=5, fill=true, clip=C, angle=ang, load=1})
for _, t in ipairs{1.0, 0.72, 0.42} do local m = tz(t); blend(m:grow(7) - m:shrink(7), {angle=ang}) end
-- the pool on the floor under the bed's front, beyond the cone
local pool = ellipse(450, 520, 230, 34)
work(pool - C:grow(2), {hand="body", tool="filbert 6", pile=b, coverage=4, fill=true, clip=pool - C:grow(2), angle=0, load=0.9})
blend(pool:grow(8) - pool:shrink(10), {angle=0})
-- the bed
work(BEDF, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}, coverage=6, fill=true, clip=BEDF, angle=0, load=1})
local litF = BEDF * tz(0.8)
work(litF, {hand="body", tool="filbert 5", pile=pile{{"burnt sienna",1},{"raw sienna",0.9},{"yellow ochre",0.4},{"bone black",0.4}, medium=0.06}, coverage=5, fill=true, clip=litF, angle=0, load=1})
work(BEDT, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.3},{"lead white",0.35}, medium=0.06}, coverage=6, fill=true, clip=BEDT, load=1})
for _, x in ipairs{200, 715} do
  local leg = rect(x, 456, 16, 18)
  work(leg, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.6}, medium=0.06}, coverage=6, fill=true, clip=leg, load=1})
end

--@ chunk 3
-- the docent behind the bed, in the light: a bronze bell robe lit from above, bowed head with a bone face, an arm out over the bed
-- holding the watering can tipped, its rose pointing down at the dry bed
print(wait(2*24*60))
local robeD = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local robeM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}
local robeL = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.2}, medium=0.06}
local bone = pile{{"lead white",1.8},{"yellow ochre",0.5},{"raw sienna",0.1}, medium=0.05}
ROBE = poly({{395, 205}, {440, 200}, {470, 250}, {492, 395}, {335, 395}, {360, 255}}, true)
work(ROBE, {hand="body", tool="filbert 6", pile=robeD, coverage=6, fill=true, clip=ROBE, angle=math.pi/2, load=1})
local mid = ROBE * poly({{390, 190}, {470, 190}, {480, 400}, {380, 400}})
work(mid, {hand="body", tool="filbert 5", pile=robeM, coverage=5, fill=true, clip=mid, angle=math.pi/2, load=1})
local top = ROBE * poly({{380, 195}, {460, 195}, {470, 270}, {370, 270}})
work(top, {hand="body", tool="filbert 4", pile=robeL, coverage=5, fill=true, clip=top, angle=0.3, load=1})
blend(ROBE * rect(330, 262, 170, 16), {angle=math.pi/2})
-- the bowed head: hood, and the bone face turned down and right toward the can
HEAD = ellipse(432, 182, 26, 30)
work(HEAD, {hand="body", tool="filbert 3", pile=robeM, coverage=6, fill=true, clip=HEAD, angle=0, load=1})
local hoodTop = HEAD * rect(400, 150, 70, 22)
work(hoodTop, {hand="detail", pile=robeL, coverage=5, fill=true, clip=hoodTop, load=1})
FACE = poly({{440, 172}, {458, 180}, {462, 206}, {448, 214}, {438, 196}}, true)
work(FACE, {hand="detail", pile=bone, coverage=6, fill=true, clip=FACE, load=1})
-- the arm reaching out over the bed
ARM = ribbon({{458, 238}, {500, 262}, {535, 268}}, {22, 17, 13})
work(ARM, {hand="body", tool="filbert 3", pile=robeM, coverage=6, fill=true, clip=ARM, angle=0.4, load=1})
local armTop = ribbon({{458, 230}, {500, 254}, {535, 261}}, 5) * ARM
work(armTop, {hand="detail", pile=robeL, coverage=5, fill=true, clip=armTop, load=1})
-- the watering can: a bronze body tilted forward, handle over the top, long spout down to a rose
CANB = poly({{530, 248}, {588, 262}, {578, 312}, {522, 300}}, true)
local can = pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.4},{"bone black",0.4}, medium=0.06}
local canL = pile{{"yellow ochre",1.2},{"lead white",0.7},{"Mars orange",0.15}, medium=0.06}
work(CANB, {hand="body", tool="filbert 3", pile=can, coverage=6, fill=true, clip=CANB, angle=0.25, load=1})
SPOUT = ribbon({{584, 290}, {622, 318}, {644, 346}}, {7, 5, 4})
work(SPOUT, {hand="detail", pile=can, coverage=6, fill=true, clip=SPOUT, load=1})
ROSE = ellipse(648, 352, 9, 6)
work(ROSE, {hand="detail", pile=can, coverage=6, fill=true, clip=ROSE, load=1})
local h = brush{kind="round", width=4, stiffness=0.6}
h:load(can, 0.95); h:stroke({{528, 252}, {545, 230}, {572, 236}, {586, 262}}, {pressure={0.9, 0.9}})
local hb = brush{kind="round", width=1.8, point=0.4}
hb:load(canL, 0.9); hb:stroke({{532, 248}, {586, 262}}, {pressure={0.8, 0.8}})
hb:load(canL, 0.9); hb:stroke({{530, 250}, {546, 229}, {570, 234}}, {pressure={0.6, 0.6}})
hb:load(canL, 0.9); hb:stroke({{588, 287}, {624, 313}, {645, 343}}, {pressure={0.6, 0.3}})
-- the hand on the handle: bone fingers
local fb = brush{kind="round", width=3, point=0.5}
fb:load(bone, 0.9); fb:stroke({{530, 262}, {540, 258}, {546, 252}}, {pressure={0.8, 0.5}})

--@ chunk 4
-- the robe came out boxy (hard zone edges): repaint it in zones that follow the bell's form, light from above on the
-- shoulders and down the side toward the can, a dark core on the far side, seams blended
print(wait(3*24*60))
local robeD = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}
local robeM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.55},{"yellow ochre",0.25}, medium=0.06}
local robeL = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.55},{"burnt sienna",0.2}, medium=0.06}
local R = ROBE - ARM
local cx = 413
local function zone(f0, f1)   -- vertical slices that widen with the bell: fraction across the bell at each height
  local L, Rr = {}, {}
  for y = 195, 400, 15 do
    local half = 20 + (y - 195) * 0.38
    L[#L+1] = {cx + (f0 * 2 - 1) * half, y}
    table.insert(Rr, 1, {cx + (f1 * 2 - 1) * half, y})
  end
  for _, p in ipairs(Rr) do L[#L+1] = p end
  return poly(L) * R
end
work(zone(-0.3, 0.38), {hand="body", tool="filbert 4", pile=robeD, coverage=6, fill=true, clip=zone(-0.3, 0.38), angle=math.pi/2, load=1})
work(zone(0.38, 0.68), {hand="body", tool="filbert 4", pile=robeM, coverage=6, fill=true, clip=zone(0.38, 0.68), angle=math.pi/2, load=1})
work(zone(0.68, 1.3), {hand="body", tool="filbert 4", pile=robeL, coverage=6, fill=true, clip=zone(0.68, 1.3), angle=math.pi/2, load=1})
blend(zone(0.31, 0.45), {angle=math.pi/2}); blend(zone(0.61, 0.75), {angle=math.pi/2})
-- the shoulders catch the light from straight above: a curved band
local sh = ROBE * (ellipse(418, 232, 50, 30) - ellipse(418, 252, 52, 30))
work(sh, {hand="body", tool="filbert 3", pile=robeL, coverage=5, fill=true, clip=sh, angle=0, load=1})
blend(sh:grow(4) * ROBE)
-- folds falling from the shoulders
local fold = pile{{"bone black",1.4},{"burnt sienna",0.8}, medium=0.06}
for _, f in ipairs{{{395, 260}, {385, 330}, {372, 392}}, {{430, 262}, {438, 330}, {446, 392}}, {{455, 270}, {470, 340}, {480, 392}}} do
  local b = brush{kind="round", width=2.4, point=0.4}
  b:load(fold, 0.8); b:stroke(f, {pressure={0.3, 0.7}, clip=R})
end

--@ chunk 5
-- the hood rounded and its crown lit; the bed's top edge restated in front of the robe; dry soil; the bone flowers in the bed,
-- pale where the skylight falls, dim to either side: disc heads on stalks, spiral shells, fan corals
print(wait(2*24*60))
local robeM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.55},{"yellow ochre",0.25}, medium=0.06}
local robeL = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.55},{"burnt sienna",0.2}, medium=0.06}
local H = HEAD - FACE
work(H, {hand="body", tool="filbert 3", pile=robeM, coverage=6, fill=true, clip=H, angle=0, load=1})
local crown = H * ellipse(428, 166, 24, 16)
work(crown, {hand="body", tool="filbert 3", pile=robeL, coverage=5, fill=true, clip=crown, angle=0, load=1})
blend(H * ellipse(428, 172, 26, 16))
-- the bed's top lip over the robe's foot, and the soil: dry, cracked
work(BEDT, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.3},{"lead white",0.35}, medium=0.06}, coverage=6, fill=true, clip=BEDT, load=1})
local soil = rect(190, 380, 540, 9)
work(soil, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.2}, medium=0.06}, coverage=6, fill=true, clip=soil, load=1})
local function L(x) return clamp(1 - math.abs(x - 455) / 190, 0, 1) end
local pls = {
  pile{{"bone black",1.2},{"burnt sienna",0.7},{"lead white",0.5}, medium=0.06},
  pile{{"lead white",1},{"yellow ochre",0.4},{"bone black",0.45},{"burnt sienna",0.2}, medium=0.06},
  pile{{"lead white",1.8},{"yellow ochre",0.45}, medium=0.05},
}
local function bonepile(x) local l = L(x); return pls[(l > 0.55) and 3 or ((l > 0.15) and 2 or 1)] end
local seedP = pile{{"burnt sienna",1},{"Mars orange",0.3},{"bone black",0.4}, medium=0.06}
local function st(pts, pl, w, pr, kind)
  local b = brush{kind=kind or "round", width=w, point=0.4, stiffness=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}})
end
-- fan corals (back), disc flowers on stalks, then spiral shells in front
for _, x in ipairs{240, 520, 690} do
  for j = -5, 5 do
    local a = -math.pi / 2 + j * 0.2
    st({{x, 384}, {x + math.cos(a) * 46, 384 + math.sin(a) * 46}}, bonepile(x), 1.6, {0.7, 0.15})
  end
end
for _, q in ipairs{{290, 300, 22}, {360, 270, 26}, {610, 296, 20}, {470, 315, 17}, {655, 330, 15}, {215, 320, 16}} do
  local x, y, r = q[1], q[2], q[3]
  st({{x, 384}, {x + 3, y + r}}, bonepile(x), 2.6, {0.8, 0.6})
  local d = ellipse(x, y, r, r * 0.92)
  work(d, {hand="detail", pile=bonepile(x), coverage=6, fill=true, clip=d, load=1})
  for n = 1, math.floor(r * 2.2) do
    local rr = r * 0.17 * math.sqrt(n)
    local aa = n * 2.399963
    if rr < r * 0.85 then
      local b = brush{kind="round", width=1.3}
      b:load(seedP, 0.8); b:touch(x + rr * math.cos(aa), y + rr * math.sin(aa) * 0.92, {pressure=0.6, clip=d})
    end
  end
  -- the drooping head: a darker underside edge
  st({{x - r * 0.8, y + r * 0.6}, {x, y + r * 0.95}, {x + r * 0.8, y + r * 0.6}}, pls[1], 1.6, {0.6, 0.6})
end
for _, q in ipairs{{330, 372, 14}, {560, 370, 16}, {420, 374, 11}} do
  local x, y, r = q[1], q[2], q[3]
  local sh = ellipse(x, y, r, r * 0.8)
  work(sh, {hand="detail", pile=bonepile(x), coverage=6, fill=true, clip=sh, load=1})
  local pts = {}
  for j = 0, 30 do local t = j / 30; local a = t * 3.6 * math.pi; local rr = r * (0.12 + 0.8 * t); pts[#pts+1] = {x + rr * math.cos(a), y + rr * math.sin(a) * 0.8} end
  st(pts, seedP, 1.1, {0.4, 0.8})
end

--@ chunk 6
-- after setting: seed spirals on the discs; the floor's lit strip under the bed softened into the pool; the Commando
-- half-hidden at the doorway's left jamb, one shoulder and half a helmet showing, a faint warm edge from the skylight
print(wait(3*24*60))
local seedP = pile{{"burnt sienna",1},{"Mars orange",0.35},{"bone black",0.5}, medium=0.06}
for _, q in ipairs{{290, 300, 22}, {360, 270, 26}, {610, 296, 20}, {470, 315, 17}, {655, 330, 15}, {215, 320, 16}} do
  local x, y, r = q[1], q[2], q[3]
  local d = ellipse(x, y, r * 0.88, r * 0.82)
  for n = 1, math.floor(r * 2.6) do
    local rr = r * 0.16 * math.sqrt(n)
    local aa = n * 2.399963
    if rr < r * 0.82 then
      local b = brush{kind="round", width=1.6}
      b:load(seedP, 0.9); b:touch(x + rr * math.cos(aa), y + rr * math.sin(aa) * 0.92, {pressure=0.75, clip=d})
    end
  end
end
local strip = rect(250, 456, 420, 30) + rect(360, 486, 180, 60)
local pp = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.6},{"lead white",0.5}, medium=0.06}
local floorD = pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
work(rect(250, 456, 420, 22), {hand="body", tool="filbert 4", pile=floorD, coverage=6, fill=true, clip=rect(250, 456, 420, 22), angle=0, load=1})
local inner = rect(355, 486, 190, 60) * ellipse(450, 520, 230, 34)
work(inner, {hand="body", tool="filbert 5", pile=pp, coverage=6, fill=true, clip=inner, angle=0, load=1})
blend(ellipse(450, 520, 210, 28) * rect(300, 470, 300, 80), {angle=0})
-- the Commando, his left half hidden by the jamb
local k = 125
local fx, fy = 808, 468
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.05,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.05,1.06)}, true)
  + poly({Q(-0.05,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.05,1.61)}, true)
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx + 0.0 * k, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
fig = fig * rect(806, 0, 200, 600)
FIG = fig
work(fig, {hand="body", tool="filbert 3", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.4}, medium=0.06}, coverage=7, fill=true, clip=fig, angle=math.pi/2, load=1})
-- the jamb: a bronze edge standing in front of his hidden half
local jamb = rect(796, 146, 16, 326)
work(jamb, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.9}, medium=0.06}, coverage=6, fill=true, clip=jamb, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 7
-- after setting: the Commando restated opaque, a faint warm edge on helmet and shoulder; the bed filled — more and bigger
-- flowers, opaque, each disc a solid head with a dark seed spiral, fan corals wider; the pool's hard rim lost
print(wait(4*24*60))
work(FIG, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.4}, medium=0.06}, coverage=7, fill=true, clip=FIG, load=1})
work(FIG, {hand="body", tool="filbert 2", pile=pile{{"bone black",2},{"ultramarine blue",0.25},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=FIG, angle=math.pi/2, load=1})
local function L(x) return clamp(1 - math.abs(x - 455) / 200, 0, 1) end
local pls = {
  pile{{"bone black",1.1},{"burnt sienna",0.6},{"lead white",0.55},{"yellow ochre",0.15}, medium=0.06},
  pile{{"lead white",1},{"yellow ochre",0.45},{"bone black",0.4},{"burnt sienna",0.2}, medium=0.06},
  pile{{"lead white",1.8},{"yellow ochre",0.45}, medium=0.05},
}
local function bp(x) local l = L(x); return pls[(l > 0.5) and 3 or ((l > 0.12) and 2 or 1)] end
local seedP = pile{{"burnt sienna",1},{"Mars brown",0.5},{"bone black",0.6}, medium=0.06}
local keep = ROBE:grow(1) * rect(0, 0, 1000, 330) + ARM + CANB + SPOUT + ROSE
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.4, stiffness=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
for _, x in ipairs{205, 395, 560, 715} do
  for j = -6, 6 do local a = -math.pi / 2 + j * 0.19; st({{x, 386}, {x + math.cos(a) * 55, 386 + math.sin(a) * 52}}, bp(x), 2.2, {0.8, 0.15}, -keep) end
end
HEADS = {}
for _, q in ipairs{{248, 292, 30}, {330, 252, 34}, {580, 268, 30}, {505, 312, 24}, {672, 300, 28}, {200, 334, 22}, {720, 342, 20}, {398, 318, 22}} do
  local x, y, r = q[1], q[2], q[3]
  st({{x, 386}, {x + 4, y + r * 0.9}}, bp(x), 4, {0.85, 0.7}, -keep)
  local d = ellipse(x, y, r, r * 0.9) - keep
  work(d, {hand="body", tool={kind="filbert", width=math.max(3, r * 0.35)}, pile=bp(x), coverage=6, fill=true, clip=d, angle=0.3, load=1})
  HEADS[#HEADS+1] = {x=x, y=y, r=r, m=d}
end
for _, q in ipairs{{300, 370, 18}, {450, 372, 14}, {630, 368, 19}, {180, 372, 13}} do
  local x, y, r = q[1], q[2], q[3]
  local sh = ellipse(x, y, r, r * 0.8) - keep
  work(sh, {hand="detail", pile=bp(x), coverage=6, fill=true, clip=sh, load=1})
  HEADS[#HEADS+1] = {x=x, y=y, r=r, m=sh, shell=true}
end
blend(ellipse(450, 520, 245, 42) - ellipse(450, 520, 205, 26), {angle=0})

--@ chunk 8
-- on set paint: seed spirals in the heads, spirals in the shells, a dark underside to each head; the docent's lens and the
-- skylight's edge on its hood, arm and can; the Commando's warm edge; the floor speckle painted out
print(wait(4*24*60))
local seedP = pile{{"burnt sienna",1},{"Mars brown",0.5},{"bone black",0.6}, medium=0.06}
local under = pile{{"bone black",1},{"burnt sienna",0.6},{"lead white",0.3}, medium=0.06}
for _, h in ipairs(HEADS) do
  if h.shell then
    local pts = {}
    for j = 0, 34 do local t = j / 34; local a = t * 3.6 * math.pi; local rr = h.r * (0.1 + 0.8 * t); pts[#pts+1] = {h.x + rr * math.cos(a), h.y + rr * math.sin(a) * 0.8} end
    local b = brush{kind="round", width=1.4, point=0.4}
    b:load(seedP, 0.9); b:stroke(pts, {pressure={0.4, 0.85}, clip=h.m})
  else
    for n = 1, math.floor(h.r * 2.6) do
      local rr = h.r * 0.155 * math.sqrt(n)
      local aa = n * 2.399963
      if rr < h.r * 0.8 then
        local b = brush{kind="round", width=1.8}
        b:load(seedP, 0.95); b:touch(h.x + rr * math.cos(aa), h.y + rr * math.sin(aa) * 0.9, {pressure=0.8, clip=h.m})
      end
    end
    local u = {}
    for j = 0, 10 do local a = math.pi * (0.15 + 0.7 * j / 10); u[#u+1] = {h.x + h.r * 0.95 * math.cos(a), h.y + h.r * 0.86 * math.sin(a)} end
    local b = brush{kind="round", width=2.2, point=0.4}
    b:load(under, 0.85); b:stroke(u, {pressure={0.5, 0.5}, clip=h.m})
  end
end
local hot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.06}, medium=0.04}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm})
end
ln({{410, 158}, {428, 152}, {446, 158}}, hot, 2, {0.6, 0.8}, HEAD:grow(1))
ln({{462, 232}, {500, 254}, {534, 260}}, hot, 1.6, {0.7, 0.4}, ARM:grow(1))
ln({{534, 249}, {584, 262}}, hot, 1.6, {0.8, 0.6}, CANB:grow(1))
local lens = ellipse(454, 192, 3.2, 3.2)
work(lens, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.5}, medium=0.06}, coverage=6, fill=true, clip=lens, load=1})
local g = brush{kind="round", width=1.2}; g:load(hot, 0.9); g:touch(455, 191, {pressure=0.6})
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local warm = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.5}, medium=0.06}
ln({Q(0.0,1.89), Q(-0.05,1.86)}, warm, 1.6, {0.6, 0.5}, FIG:grow(1))
ln({Q(0.04,1.61), Q(0.0,1.6)}, warm, 1.4, {0.5, 0.5}, FIG:grow(1))
-- the floor speckle under the bed and the pool core restated plain
local fl = rect(250, 456, 420, 30)
work(fl, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=fl, angle=0, load=1})
local pc = ellipse(450, 520, 200, 26)
work(pc, {hand="body", tool="filbert 6", pile=pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.6},{"lead white",0.5}, medium=0.06}, coverage=6, fill=true, clip=pc, angle=0, load=1})

--@ chunk 9
-- the pool's hard rim eaten from outside with a feathered dark stipple; a dim shelf of potted bone flowers in the dark at left
print(wait(3*24*60))
local dk = pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
local ring = ellipse(450, 520, 265, 50) - ellipse(450, 520, 175, 18)
stipple(ring, {pile=dk, width=1.6, coverage=function(x, y) local d = math.sqrt(((x - 450) / 240)^2 + ((y - 520) / 36)^2); return clamp((d - 0.72) / 0.45, 0, 1) * 4 end, feather=0.9, cluster=0.2, dips={30, 0.8, 0}})
local shelf = rect(40, 262, 190, 8)
work(shelf, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.9}, medium=0.06}, coverage=6, fill=true, clip=shelf, load=1})
local pot = pile{{"bone black",1.4},{"burnt sienna",0.9}, medium=0.06}
local dim = pile{{"bone black",1},{"burnt sienna",0.6},{"lead white",0.5},{"yellow ochre",0.15}, medium=0.06}
for i, x in ipairs{75, 135, 195} do
  local p = poly({{x - 14, 238}, {x + 14, 238}, {x + 10, 262}, {x - 10, 262}})
  work(p, {hand="detail", pile=pot, coverage=6, fill=true, clip=p, load=1})
  local b = brush{kind="round", width=2, stiffness=0.5}
  local hy = 200 + 8 * i % 17
  b:load(dim, 0.9); b:stroke({{x, 238}, {x + 2, hy + 10}}, {pressure={0.8, 0.7}})
  local h = ellipse(x + 2, hy, 11, 10)
  work(h, {hand="detail", pile=dim, coverage=6, fill=true, clip=h, load=1})
end

--@ chunk 10
-- pass: the floor oval painted back to dark floor; the light continued below the bed as a soft narrow wedge fading down
print(wait(4*24*60))
local fl = pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
local ov = ellipse(450, 520, 275, 56) * rect(0, 474, 1000, 200)
work(ov, {hand="body", tool="filbert 8", pile=fl, coverage=6, fill=true, clip=ov, angle=0, load=1})
-- the wedge in two steps, strokes running down along the light
local W1 = poly({{330, 474}, {570, 474}, {600, 600}, {300, 600}}, true)
local W2 = poly({{385, 474}, {515, 474}, {530, 560}, {370, 560}}, true)
local a = pile{{"bone black",1},{"burnt sienna",0.9},{"raw sienna",0.5},{"lead white",0.25}, medium=0.06}
local b = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.55},{"lead white",0.55}, medium=0.06}
work(W1 - W2, {hand="body", tool="filbert 5", pile=a, coverage=5, fill=true, clip=W1 - W2, angle=math.pi/2, load=1,
  load_at=function(x, y) return clamp(1 - (y - 474) / 140, 0.15, 1) end})
work(W2, {hand="body", tool="filbert 4", pile=b, coverage=5, fill=true, clip=W2, angle=math.pi/2, load=1,
  load_at=function(x, y) return clamp(1 - (y - 474) / 110, 0.2, 1) end})
blend(W1:grow(10) - W1:shrink(10), {angle=math.pi/2})
blend(W2:grow(8) - W2:shrink(8), {angle=math.pi/2})
blend(rect(290, 540, 330, 70), {angle=math.pi/2})

--@ chunk 11
-- (dry) the Commando's cool rim toward the room; warm garden spill on the jamb beside him; lit rims on the shelf pots
print(wait(4*24*60))
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local cool = pile{{"zinc white",1.4},{"ultramarine ash",0.6},{"lead white",0.4},{"bone black",0.15}, medium=0.05}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm})
end
-- the edge of him facing the room is the edge along the jamb (his left): helm, pauldron, arm
ln({Q(0.03,1.88), Q(0.02,1.78), Q(0.03,1.66)}, cool, 1.8, {0.8, 0.4}, FIG:grow(1.5))
ln({Q(0.02,1.6), Q(0.05,1.58), Q(0.02,1.4)}, cool, 1.6, {0.8, 0.3}, FIG:grow(1.5))
ln({Q(0.03,1.35), Q(0.03,1.05)}, cool, 1.2, {0.5, 0.1}, FIG:grow(1.5))
ln({Q(0.08,1.89), Q(0.0,1.885)}, cool, 1.4, {0.6, 0.6}, FIG:grow(1.5))
-- warm spill on the jamb's room-side face, strongest low
local warm = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.45},{"burnt sienna",0.3}, medium=0.06}
ln({{798, 470}, {798, 380}, {798, 280}}, warm, 3, {0.9, 0.1})
ln({{790, 470}, {790, 330}}, pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.6}, medium=0.06}, 3, {0.7, 0.1})
-- the pots: lit rims and a warm side so the flowers stand in something
local rim = pile{{"yellow ochre",1},{"lead white",0.6},{"raw sienna",0.4}, medium=0.06}
local side = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.6}, medium=0.06}
for _, x in ipairs{75, 135, 195} do
  local p = poly({{x - 14, 238}, {x + 14, 238}, {x + 10, 262}, {x - 10, 262}})
  work(p, {hand="detail", pile=side, coverage=6, fill=true, clip=p, load=1})
  ln({{x - 15, 238}, {x + 15, 238}}, rim, 2.2, {0.8, 0.8})
  ln({{x + 14, 240}, {x + 10, 261}}, rim, 1.4, {0.7, 0.3}, p:grow(1))
end
ln({{40, 262}, {230, 262}}, rim, 1.6, {0.3, 0.8})

--@ chunk 12
-- the wedge came out a mottled round blob: floor repainted dark under it, then a straight-sided wedge in three bands that
-- darken downward, each only a step off the floor, seams and sides blended
print(wait(3*24*60))
local fl = pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}
local R = rect(200, 474, 520, 193)
work(R, {hand="body", tool="filbert 8", pile=fl, coverage=6, fill=true, clip=R, angle=0, load=1})
local function wedge(y0, y1)
  local function xl(y) return 360 - (y - 474) * 0.35 end
  local function xr(y) return 540 + (y - 474) * 0.35 end
  return poly({{xl(y0), y0}, {xr(y0), y0}, {xr(y1), y1}, {xl(y1), y1}})
end
local p1 = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.6},{"lead white",0.45}, medium=0.06}
local p2 = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.8},{"lead white",0.2}, medium=0.06}
local p3 = pile{{"bone black",1.1},{"burnt sienna",1},{"raw sienna",0.5},{"lead white",0.08}, medium=0.06}
work(wedge(474, 520), {hand="body", tool="filbert 5", pile=p1, coverage=5, fill=true, clip=wedge(474, 520), angle=math.pi/2, load=1})
work(wedge(520, 570), {hand="body", tool="filbert 5", pile=p2, coverage=5, fill=true, clip=wedge(520, 570), angle=math.pi/2, load=1})
work(wedge(570, 630), {hand="body", tool="filbert 6", pile=p3, coverage=5, fill=true, clip=wedge(570, 630), angle=math.pi/2, load=1})
blend(wedge(510, 530), {angle=math.pi/2}); blend(wedge(560, 580), {angle=math.pi/2}); blend(wedge(620, 645):grow(6), {angle=math.pi/2})
local all = wedge(474, 640)
blend((all:grow(9) - all:shrink(7)) * rect(0, 476, 1000, 200), {angle=math.pi/2})
