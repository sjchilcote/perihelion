-- easel session "observatory": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=8282,
  ground={{pile={{"bone black",1},{"burnt sienna",0.8},{"ultramarine blue",0.4},{"lead white",0.5}}, um=110, apply="knife", texture=0.4}}}
-- inside the dome, standing near its rim and looking across: the base ring seen as a wide ellipse,
-- the far inner surface rising and curving overhead toward a zenith above the frame
BCX, BCY, BRX, BRY = 500, 478, 820, 78
function FARRIM(x) local u = (x - BCX) / BRX; if math.abs(u) >= 1 then return BCY end; return BCY - BRY * math.sqrt(1 - u * u) end
ZEN = {500, -520}
FLOORM = below(FARRIM)
DOME = above(FARRIM)
-- a meridian of the dome: from the far rim at x0 up toward the zenith, bowing outward
function MERID(x0, n)
  local y0 = FARRIM(x0)
  local pts = {}
  n = n or 16
  for i = 0, n do
    local t = i / n
    local x = lerp(x0, ZEN[1], t) + (x0 - ZEN[1]) * 0.35 * math.sin(t * math.pi)
    local y = lerp(y0, ZEN[2], t)
    pts[#pts+1] = {x, y}
  end
  return pts
end
-- a ring of latitude: the dome's horizontal circles, seen as arcs bowing down at the sides
function LAT(h)  -- h: 0 at the rim .. 1 at the zenith
  local pts = {}
  for x = -400, 1400, 30 do
    local y0 = FARRIM(math.max(-319, math.min(1319, x)))
    local y = lerp(y0, ZEN[2], h) + 260 * h * (1 - h) * ((x - 500) / 820)^2
    pts[#pts+1] = {lerp(x, ZEN[1], h * 0.6), y}
  end
  return pts
end
-- the slot: an opening between two meridians, from a third of the way up to the top of the frame
SLOT = poly({{447, 230}, {553, 230}, {543, -5}, {457, -5}})
SLOTLIP = SLOT:grow(7) - SLOT
print(W, H, FARRIM(500), FARRIM(0), FARRIM(1000))

--@ chunk 2
-- value structure: dome in three darkening bands upward (lean, no white above the lowest), dark floor, black space in the slot
local D = DOME - SLOT
local b1 = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}, medium=0.06}
local b2 = pile{{"bone black",1.2},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local b3 = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}
local lowc = function(x) return 340 + 40 * ((x - 500) / 500)^2 end
local midc = function(x) return 175 + 60 * ((x - 500) / 500)^2 end
local A = D * below(lowc); local B = D * above(lowc) * below(midc); local C = D * above(midc)
work(A, {hand="body", tool="filbert 10", pile=b1, coverage=4, fill=true, clip=A, angle=0, load=1})
work(B, {hand="body", tool="filbert 12", pile=b2, coverage=4, fill=true, clip=B, angle=0, load=1})
work(C, {hand="body", tool="filbert 12", pile=b3, coverage=4, fill=true, clip=C, angle=0, load=1})
blend(D * below(function(x) return lowc(x) + 9 end) * above(function(x) return lowc(x) - 9 end), {angle=0})
blend(D * below(function(x) return midc(x) + 9 end) * above(function(x) return midc(x) - 9 end), {angle=0})
local fl = pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}
work(FLOORM, {hand="body", tool="filbert 12", pile=fl, coverage=4, fill=true, clip=FLOORM, angle=0, load=1})
local sp = pile{{"bone black",2},{"ultramarine blue",0.8}, medium=0.06}
work(SLOT, {hand="body", tool="filbert 4", pile=sp, coverage=5, fill=true, clip=SLOT, angle=math.pi/2, load=1})

--@ chunk 3
-- the dome's ribs: meridians converging overhead and rings of latitude; then the orrery map: bone studs in golden-angle spirals
print(wait(3*24*60))
local D = DOME - SLOT:grow(8)
local rib = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.2}, medium=0.06}
local lipW = pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.5},{"lead white",0.25}, medium=0.06}
local function seg(pts, w, pl, pr, clipm)
  for j = 1, #pts - 1, 3 do
    local s = {}
    for q = j, math.min(j + 3, #pts) do s[#s+1] = pts[q] end
    if #s >= 2 then local b = brush{kind="round", width=w, stiffness=0.6, point=0.2}; b:load(pl, 1); b:stroke(s, {pressure=pr, ramps={0.02, 0.02}, clip=clipm}) end
  end
end
for _, x0 in ipairs{-260, -60, 120, 280, 400, 600, 720, 880, 1060, 1260} do
  seg(MERID(x0), (math.abs(x0 - 500) > 300) and 9 or 6, rib, {0.9, 0.9}, D)
  local m = MERID(x0)
  local mm = {}
  for _, p in ipairs(m) do mm[#mm+1] = {p[1] + ((x0 < 500) and 3.5 or -3.5), p[2]} end
  seg(mm, 1.4, lipW, {0.5, 0.5}, D)
end
for _, h in ipairs{0.1, 0.27, 0.46} do
  seg(LAT(h), 5 + 4 * (1 - h), rib, {0.85, 0.85}, D)
end
-- the orrery: spirals of bone studs about a few centres, each its own size, with inscribed circles
local boneL = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.1}, medium=0.06}
local boneD = pile{{"lead white",0.9},{"yellow ochre",0.5},{"burnt sienna",0.4},{"bone black",0.6}, medium=0.06}
local cen = {{230, 260, 5.5, 180}, {770, 240, 5, 170}, {500, 300, 4, 70}, {110, 120, 6, 120}, {900, 110, 6, 130}, {350, 90, 4.5, 110}, {660, 80, 4.5, 110}}
local n = 0
for ci, c in ipairs(cen) do
  for i = 1, c[4] do
    local r = c[3] * math.sqrt(i)
    local a = i * 2.399963
    local x, y = c[1] + r * math.cos(a), c[2] + r * math.sin(a) * 0.7
    if D:at(x, y) > 0.5 then
      local s = math.max(0.9, 2.6 - i / c[4] * 1.5)
      local b = brush{kind="round", width=s, stiffness=0.5}
      local lit = (y > 300) or ((i * 0.618034) % 1 < 0.25)
      b:load(lit and boneL or boneD, 0.85)
      b:touch(x, y, {pressure=0.7, clip=D})
      n = n + 1
    end
  end
  -- fold notation: a circle holding turned polygons
  local R = c[3] * math.sqrt(c[4]) * 1.08
  local pts = {}
  for j = 0, 36 do local a = 2 * math.pi * j / 36; pts[#pts+1] = {c[1] + R * math.cos(a), c[2] + R * 0.7 * math.sin(a)} end
  seg(pts, 1.3, boneD, {0.5, 0.5}, D)
  local rr, rot = R * 0.55, ci * 0.7
  for kk = 1, 2 do
    local pp = {}
    local sides = 5 + (ci % 2)
    for j = 0, sides do local a = rot + 2 * math.pi * j / sides; pp[#pp+1] = {c[1] + rr * math.cos(a), c[2] + rr * 0.7 * math.sin(a)} end
    local b = brush{kind="round", width=1.1, point=0.4}
    b:load(boneD, 0.8); b:stroke(pp, {pressure={0.5, 0.5}, clip=D})
    rr = rr * 0.6; rot = rot + 2.399963
  end
end
print("studs", n)

--@ chunk 4
-- ribs as real bands (ribbon masks), heavier near the rim, thinning overhead; scattered single stars between the spirals
print(wait(1*24*60))
local D = DOME - SLOT:grow(8)
local rib = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.2}, medium=0.06}
local lip = pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.6},{"lead white",0.3}, medium=0.06}
RIBM = nil
for _, x0 in ipairs{-260, -60, 120, 280, 400, 600, 720, 880, 1060, 1260} do
  local m = MERID(x0, 16)
  local ws = {}
  for i = 1, #m do ws[i] = lerp(18, 6, (i - 1) / (#m - 1)) end
  local r = ribbon(m, ws) * D
  RIBM = RIBM and (RIBM + r) or r
  local lp = {}
  for i, p in ipairs(m) do lp[#lp+1] = {p[1] + ((x0 < 500) and 1 or -1) * ws[i] * 0.42, p[2]} end
  LIPS = LIPS or {}
  LIPS[#LIPS+1] = lp
end
for _, h in ipairs{0.1, 0.27, 0.46} do
  local r = ribbon(LAT(h), 12 - 8 * h) * D
  RIBM = RIBM + r
end
work(RIBM, {hand="detail", pile=rib, coverage=5, fill=true, clip=RIBM, load=1})
for _, lp in ipairs(LIPS) do
  local b = brush{kind="round", width=1.6, point=0.4}
  b:load(lip, 0.85); b:stroke(lp, {pressure={0.6, 0.3}, clip=RIBM:grow(1)})
end
-- single stars: the rest of the tracked sky, small, uneven, denser in a band
local star = pile{{"lead white",1.6},{"yellow ochre",0.4},{"bone black",0.2}, medium=0.06}
local starC = pile{{"zinc white",1.5},{"lead white",0.5},{"ultramarine ash",0.3}, medium=0.05}
local n = 0
for i = 1, 900 do
  local x, y = rand(0, 1000), rand(0, 400)
  local band = math.exp(-((y - 150 - 0.15 * (x - 500)) / 70)^2)
  if math.random() < 0.35 + 0.65 * band and D:at(x, y) > 0.5 and RIBM:at(x, y) < 0.2 then
    local b = brush{kind="round", width=rand(0.7, 1.6), stiffness=0.5}
    b:load((math.random() < 0.2) and starC or star, 0.7)
    b:touch(x, y, {pressure=rand(0.4, 0.8), clip=D})
    n = n + 1
  end
end
print("stars", n)

--@ chunk 5
-- the Sun's edge in the slot: a hard white disc limb, a thin corona; the slot's lip lit hot on its sunward side
print(wait(2*24*60))
local SC, SR = {735, -170}, 330
local disc = ellipse(SC[1], SC[2], SR, SR) * SLOT
local cor = (ellipse(SC[1], SC[2], SR + 14, SR + 14) - ellipse(SC[1], SC[2], SR, SR)) * SLOT
local hot = pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.04}
local cP = pile{{"zinc white",1.5},{"lead white",1},{"cadmium yellow",0.15},{"ultramarine ash",0.2}, medium=0.05}
work(cor, {hand="detail", pile=cP, coverage=3, fill=true, clip=cor, load=0.8})
work(disc, {hand="body", tool="filbert 4", pile=hot, coverage=6, fill=true, clip=disc, angle=math.pi/2, load=1})
local m = (ellipse(SC[1], SC[2], SR + 22, SR + 22) - ellipse(SC[1], SC[2], SR + 3, SR + 3)) * SLOT
blend(m)
-- the slot's lips: the right one faces the light
local lipH = pile{{"lead white",2.5},{"cadmium yellow",0.2},{"yellow ochre",0.2}, medium=0.05}
local lipD = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local b = brush{kind="round", width=4, stiffness=0.6}
b:load(lipD, 1); b:stroke({{445, 232}, {455, -5}}, {pressure={0.9, 0.9}})
b:load(lipD, 1); b:stroke({{447, 233}, {553, 233}}, {pressure={0.9, 0.9}})
local h = brush{kind="round", width=2.2, point=0.4}
h:load(lipH, 0.9); h:stroke({{556, 228}, {546, -5}}, {pressure={0.8, 0.5}})
h:load(lipH, 0.9); h:stroke({{452, 236}, {552, 236}}, {pressure={0.4, 0.7}})

--@ chunk 6
-- the rail ring on the floor, the turning cradle, the great bronze telescope aimed through the slot; the hot stripe of sun on the floor
print(wait(1*24*60))
local brD = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local brM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.4}, medium=0.06}
local hot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.1}, medium=0.04}
local boneL = pile{{"lead white",2},{"yellow ochre",0.5}, medium=0.06}
-- the sun's stripe on the floor, from the slot's direction, hard-edged
local stripe = poly({{350, 470}, {450, 470}, {420, 520}, {300, 522}}) * FLOORM
work(stripe, {hand="body", tool="filbert 4", pile=pile{{"lead white",2},{"yellow ochre",0.6},{"cadmium yellow",0.2}, medium=0.05}, coverage=5, fill=true, clip=stripe, angle=0, load=1})
-- rail ring: two concentric bronze rails seen flat, bone studs between
for _, rr in ipairs{{340, 52, 7}, {300, 44, 5}} do
  local pts = {}
  for j = 0, 48 do local a = 2 * math.pi * j / 48; pts[#pts+1] = {500 + rr[1] * math.cos(a), 600 + rr[2] * math.sin(a)} end
  local r = ribbon(pts, rr[3])
  work(r, {hand="detail", pile=brM, coverage=4, fill=true, clip=r, load=1})
  local lp = {}
  for j = 0, 24 do local a = math.pi * (1.0 + j / 24); lp[#lp+1] = {500 + rr[1] * math.cos(a), 600 + rr[2] * math.sin(a) - rr[3] * 0.3} end
  local b = brush{kind="round", width=1.4, point=0.4}
  b:load(brL, 0.8); b:stroke(lp, {pressure={0.5, 0.5}})
end
for j = 0, 34 do
  local a = 2 * math.pi * j / 34
  local b = brush{kind="round", width=2.2}
  b:load(boneL, 0.8); b:touch(500 + 320 * math.cos(a), 600 + 48 * math.sin(a), {pressure=0.7})
end
-- the cradle: a carriage on the ring, a fork rising to trunnions
local carriage = poly({{430, 590}, {575, 590}, {585, 625}, {420, 625}})
work(carriage, {hand="detail", pile=brD, coverage=5, fill=true, clip=carriage, load=1})
local fork = ribbon({{445, 595}, {440, 470}, {455, 400}}, {16, 13, 11}) + ribbon({{560, 595}, {565, 470}, {548, 395}}, {16, 13, 11})
work(fork, {hand="detail", pile=brD, coverage=5, fill=true, clip=fork, load=1})
-- the tube: from the eyepiece end low-left to the aperture under the slot
local A, Bp = {455, 505}, {512, 205}
local tube = ribbon({A, {483, 355}, Bp}, {54, 48, 44})
TUBE = tube
work(tube, {hand="body", tool="filbert 6", pile=brD, coverage=5, fill=true, clip=tube, angle=-1.38, load=1})
local mid = ribbon({{465, 505}, {492, 355}, {520, 205}}, {22, 20, 18}) * tube
work(mid, {hand="body", tool="filbert 4", pile=brM, coverage=4, fill=true, clip=mid, angle=-1.38, load=1})
-- bands round the tube, and the aperture ring
for _, t in ipairs{0.15, 0.42, 0.7} do
  local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
  local b = brush{kind="flat", width=7}
  b:load(brM, 0.9); b:stroke({{x - 27, y - 5}, {x + 27, y + 5}}, {pressure={0.8, 0.8}, orient="across", clip=tube})
end
local ap = ellipse(Bp[1], Bp[2], 25, 8)
work(ap, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}, coverage=5, fill=true, clip=ap, load=1})
-- the sun's hot edge down the tube's right side and on the aperture rim
local hb = brush{kind="round", width=2.6, point=0.4}
hb:load(hot, 0.9); hb:stroke({{534, 205}, {507, 355}, {481, 500}}, {pressure={0.9, 0.2}, clip=tube:grow(1)})
hb:load(hot, 0.9); hb:stroke({{500, 200}, {515, 198}, {536, 204}}, {pressure={0.8, 0.8}})
-- trunnion bosses
for _, p in ipairs{{455, 400}, {548, 395}} do
  local e = ellipse(p[1], p[2], 10, 10)
  work(e, {hand="detail", pile=brM, coverage=5, fill=true, clip=e, load=1})
  local b = brush{kind="round", width=3}; b:load(boneL, 0.8); b:touch(p[1], p[2], {pressure=0.6})
end

--@ chunk 7
-- the telescope too slight for "great": restated as a heavy bronze tube, a broad fork and drum; the docent in its eyepiece chair
print(wait(3*24*60))
local brD = pile{{"bone black",1.8},{"burnt sienna",0.9},{"Mars brown",0.4}, medium=0.06}
local brM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.55},{"yellow ochre",0.35}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.3},{"lead white",0.5}, medium=0.06}
local hot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.1}, medium=0.04}
local boneL = pile{{"lead white",2},{"yellow ochre",0.5}, medium=0.06}
-- a drum on the carriage, the fork arms rising wide
local drum = poly({{395, 560}, {605, 560}, {620, 615}, {380, 615}}, true)
work(drum, {hand="body", tool="filbert 6", pile=brD, coverage=5, fill=true, clip=drum, angle=0, load=1})
local drumL = rect(380, 557, 240, 8) * drum:grow(2)
work(drumL, {hand="detail", pile=brL, coverage=4, fill=true, clip=drumL, load=1})
local fork = ribbon({{420, 565}, {405, 450}, {425, 380}}, {30, 24, 20}) + ribbon({{580, 565}, {600, 450}, {580, 372}}, {30, 24, 20})
work(fork, {hand="body", tool="filbert 5", pile=brD, coverage=5, fill=true, clip=fork, angle=math.pi/2, load=1})
local fl = ribbon({{594, 560}, {612, 450}, {592, 372}}, 3)
local b = brush{kind="round", width=2.4, point=0.4}
b:load(brL, 0.8); b:stroke({{594, 560}, {612, 450}, {592, 375}}, {pressure={0.4, 0.7}})
-- the tube: big, its eyepiece end low-left, aperture just under the slot
local A, Bp = {440, 545}, {508, 215}
local tube = ribbon({A, {474, 380}, Bp}, {120, 108, 98})
TUBE = tube
work(tube, {hand="body", tool="filbert 8", pile=brD, coverage=5, fill=true, clip=tube, angle=-1.37, load=1})
local midband = ribbon({{458, 545}, {492, 380}, {526, 215}}, {46, 42, 38}) * tube
work(midband, {hand="body", tool="filbert 6", pile=brM, coverage=4, fill=true, clip=midband, angle=-1.37, load=1})
for _, t in ipairs{0.1, 0.38, 0.66, 0.9} do
  local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
  local w = lerp(60, 50, t)
  local bb = brush{kind="flat", width=9}
  bb:load(brM, 0.95); bb:stroke({{x - w, y - 11}, {x + w, y + 11}}, {pressure={0.85, 0.85}, orient="across", clip=tube})
  local lb = brush{kind="round", width=1.6, point=0.4}
  lb:load(boneL, 0.8); lb:stroke({{x - w + 4, y - 15}, {x + w - 4, y + 7}}, {pressure={0.4, 0.4}, clip=tube})
end
local ap = ellipse(Bp[1], Bp[2] - 2, 50, 14)
work(ap, {hand="detail", pile=brM, coverage=5, fill=true, clip=ap, load=1})
local api = ellipse(Bp[1], Bp[2] - 2, 42, 10)
work(api, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.5}, medium=0.06}, coverage=5, fill=true, clip=api, load=1})
-- sun on the tube: a hard white edge down its upper-right side, and on the aperture rim
local hb = brush{kind="round", width=3.4, point=0.4}
hb:load(hot, 0.95); hb:stroke({{556, 220}, {524, 380}, {494, 520}}, {pressure={0.9, 0.15}, clip=tube:grow(1.5)})
hb:load(hot, 0.95); hb:stroke({{470, 205}, {510, 200}, {556, 209}}, {pressure={0.8, 0.9}})
-- the eyepiece chair and the docent, low-left at the tube's foot, face lifted to the eyepiece
local chair = ribbon({{345, 615}, {352, 560}}, 8) + poly({{320, 560}, {390, 556}, {392, 568}, {318, 572}}) + ribbon({{322, 566}, {316, 470}}, 10)
work(chair, {hand="detail", pile=brD, coverage=5, fill=true, clip=chair, load=1})
local bell = poly({{345, 470}, {372, 476}, {392, 560}, {325, 562}, {330, 490}}, true)
work(bell, {hand="body", tool="filbert 4", pile=brM, coverage=5, fill=true, clip=bell, angle=math.pi/2, load=1})
local face = ellipse(372, 462, 11, 14)
work(face, {hand="detail", pile=boneL, coverage=5, fill=true, clip=face, load=1})
local eyep = ribbon({{383, 470}, {400, 520}}, 8)
work(eyep, {hand="detail", pile=brD, coverage=5, fill=true, clip=eyep, load=1})
local cold = pile{{"zinc white",1.5},{"ultramarine ash",0.6},{"lead white",0.5}, medium=0.05}
local cb = brush{kind="round", width=1.6, point=0.5}
cb:load(cold, 0.8); cb:stroke({{348, 474}, {333, 500}, {328, 555}}, {pressure={0.6, 0.2}})
cb:load(boneL, 0.8); cb:stroke({{366, 452}, {378, 450}, {382, 462}}, {pressure={0.6, 0.4}})
DOCM = bell + face + chair

--@ chunk 8
-- on set paint: the sun's hard edge on the tube and aperture; the low doorway at the rim, the Commando entering, tiny
print(wait(3*24*60))
local hot = pile{{"zinc white",2.5},{"lemon chrome",0.12}, medium=0.04}
local warmH = pile{{"lead white",2},{"yellow ochre",0.6},{"cadmium yellow",0.2}, medium=0.05}
local function ln(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.4}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr})
end
ln({{557, 222}, {541, 300}, {524, 380}, {508, 455}}, hot, 3.2, {0.9, 0.2})
ln({{461, 208}, {508, 200}, {556, 210}}, hot, 2.6, {0.8, 0.9})
ln({{555, 268}, {552, 250}}, warmH, 2.2, {0.7, 0.7})
-- the low doorway in the dome's wall, far left at the rim; a dim warm corridor beyond
local dx, dy = 150, FARRIM(150) + 2
local door = {}
door[#door+1] = {dx - 20, dy}
for j = 0, 12 do local a = math.pi * j / 12; door[#door+1] = {dx - 20 * math.cos(a), dy - 34 - 18 * math.sin(a)} end
door[#door+1] = {dx + 20, dy}
local D = poly(door)
work(D, {hand="detail", pile=pile{{"burnt sienna",1},{"yellow ochre",0.8},{"lead white",0.5},{"bone black",0.3}, medium=0.06}, coverage=5, fill=true, clip=D, load=1})
local jamb = D:grow(3) - D
work(jamb, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=jamb, load=1})
-- the Commando in it, stooping through, dark against the warm corridor light
local k = 22
local fx, fy = dx + 2, dy
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.1,0.93), Q(-0.13,0.5), Q(-0.16,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.1,0.93), Q(0.14,0.5), Q(0.22,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.2,0.88), Q(0.2,0.88), Q(0.22,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.19,1.02), Q(0.3,1.32), Q(0.38,1.48), Q(0.33,1.56), Q(0.14,1.6), Q(-0.06,1.58), Q(-0.24,1.52), Q(-0.28,1.42), Q(-0.23,1.28)}, true)
  + ellipse(fx + 0.17 * k, fy - 1.66 * k, 0.11 * k, 0.13 * k)
  + ribbon({Q(0.3,1.45), Q(0.42,1.2), Q(0.45,0.98)}, {0.11*k, 0.09*k, 0.08*k})
  + ribbon({Q(-0.22,1.42), Q(-0.3,1.18), Q(-0.27,0.95)}, {0.11*k, 0.09*k, 0.08*k})
work(fig, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=5, fill=true, clip=fig, load=1})
-- his doorway's warm spill on the floor before it, small
local sp = ellipse(dx + 10, dy + 14, 34, 7) * FLOORM - fig
work(sp, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.7},{"yellow ochre",0.3}, medium=0.06}, coverage=3, fill=true, clip=sp, load=0.8})
-- the starlight's cold glints along the rail ring's far side and the drum's edge
local cold = pile{{"zinc white",1.5},{"ultramarine ash",0.5},{"lead white",0.5}, medium=0.05}
local pts = {}
for j = 0, 20 do local a = math.pi * (1.05 + 0.9 * j / 20); pts[#pts+1] = {500 + 340 * math.cos(a), 600 + 52 * math.sin(a) - 3} end
ln(pts, cold, 1.2, {0.4, 0.4})

--@ chunk 9
-- floor plates in rings round the instrument (dark seams, a faint warm lip), the doorway spill softened, the hot edge carried down the tube
print(wait(2*24*60))
local seam = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}
local lip = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local keep = TUBE:grow(2) + DOCM:grow(2)
local FL = FLOORM - keep
for _, r in ipairs{{150, 22}, {420, 62}, {540, 82}, {700, 108}} do
  local pts = {}
  for j = 0, 60 do local a = 2 * math.pi * j / 60; pts[#pts+1] = {500 + r[1] * math.cos(a), 600 + r[2] * math.sin(a)} end
  local b = brush{kind="round", width=1.6, point=0.3}
  b:load(seam, 0.9); b:stroke(pts, {pressure={0.6, 0.6}, clip=FL})
  local lp = {}
  for _, p in ipairs(pts) do lp[#lp+1] = {p[1], p[2] + 2} end
  local l = brush{kind="round", width=1.0, point=0.3}
  l:load(lip, 0.7); l:stroke(lp, {pressure={0.4, 0.4}, clip=FL})
end
for a = 0, 2 * math.pi, math.pi / 9 do
  local b = brush{kind="round", width=1.4, point=0.3}
  b:load(seam, 0.9)
  b:stroke({{500 + 350 * math.cos(a), 600 + 52 * math.sin(a)}, {500 + 900 * math.cos(a), 600 + 135 * math.sin(a)}}, {pressure={0.5, 0.7}, clip=FL})
end
local dx, dy = 150, FARRIM(150) + 2
blend((ellipse(dx + 10, dy + 14, 40, 10) - ellipse(dx + 10, dy + 14, 26, 4)) * FLOORM, {angle=0})
local hot = pile{{"zinc white",2.5},{"lemon chrome",0.12}, medium=0.04}
local b = brush{kind="round", width=3, point=0.4}
b:load(hot, 0.95); b:stroke({{540, 300}, {524, 380}, {507, 460}, {492, 530}}, {pressure={0.8, 0.1}, clip=TUBE:grow(2)})

--@ chunk 10
-- pass, 1: the floor's sun band and the doorway spill; the fork and drum repainted broad; the tube modelled in zones across its width
print(wait(3*24*60))
local tube = TUBE
local A, Bp = {440, 545}, {508, 215}
local function along(s0, s1)   -- a strip of the tube between offsets s0..s1 (fractions of the width, - = left)
  local L, R = {}, {}
  for i = 0, 10 do
    local t = i / 10
    local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
    local w = lerp(120, 98, t)
    local nx, ny = 0.979, 0.2018
    L[#L+1] = {x + nx * s0 * w, y + ny * s0 * w}
    table.insert(R, 1, {x + nx * s1 * w, y + ny * s1 * w})
  end
  for _, p in ipairs(R) do L[#L+1] = p end
  return poly(L) * tube
end
ALONG = along
-- fork arms and drum, broad, dark
local brK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.2}, medium=0.06}
FORK = ribbon({{415, 565}, {398, 450}, {420, 372}}, {40, 32, 26}) + ribbon({{585, 565}, {603, 450}, {578, 368}}, {44, 34, 26})
FORK = FORK - tube
work(FORK, {hand="body", tool="filbert 6", pile=brK, coverage=6, fill=true, clip=FORK, angle=math.pi/2, load=1})
DRUM = poly({{385, 558}, {615, 558}, {630, 618}, {370, 618}}, true)
work(DRUM, {hand="body", tool="filbert 6", pile=brK, coverage=6, fill=true, clip=DRUM, angle=0, load=1})
-- the tube in zones: warm reflected left edge, dark core, warm mid, bright bronze toward the sun
local zones = {
  {-0.52, -0.38, pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.8}, medium=0.06}},
  {-0.38, -0.02, pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.15}, medium=0.06}},
  {-0.02, 0.28, pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",0.4},{"bone black",0.35}, medium=0.06}},
  {0.28, 0.52, pile{{"yellow ochre",1.3},{"raw sienna",0.7},{"lead white",0.6},{"Mars orange",0.2}, medium=0.06}},
}
for _, z in ipairs(zones) do
  local m = along(z[1], z[2])
  work(m, {hand="body", tool="filbert 4", pile=z[3], coverage=6, fill=true, clip=m, angle=-1.37, load=1})
end
blend(along(-0.42, -0.34), {angle=-1.37}); blend(along(-0.06, 0.02), {angle=-1.37}); blend(along(0.24, 0.32), {angle=-1.37})
-- the sun band across the floor, hard-edged, past the drum and over the rail ring toward the lower left
local keep = tube:grow(2) + FORK + DRUM + DOCM:grow(3)
local band = poly({{440, 470}, {505, 470}, {330, 667}, {205, 667}}) * FLOORM - keep
work(band, {hand="body", tool="filbert 5", pile=pile{{"lead white",2},{"yellow ochre",0.6},{"cadmium yellow",0.15},{"bone black",0.05}, medium=0.05}, coverage=6, fill=true, clip=band, angle=-2.1, load=1})
-- the old floor stripe returned to dark floor where the band does not pass
local old = poly({{350, 470}, {450, 470}, {420, 520}, {300, 522}}):grow(2) * FLOORM - band:grow(1) - keep
work(old, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}, coverage=6, fill=true, clip=old, angle=0, load=1})
-- the doorway spill: old oval painted out, then a soft wedge reaching toward us in two steps
local dx, dy = 150, FARRIM(150) + 2
local oldsp = ellipse(dx + 10, dy + 14, 44, 12) * FLOORM
work(oldsp, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}, coverage=6, fill=true, clip=oldsp, angle=0, load=1})
local s1 = poly({{dx - 18, dy + 1}, {dx + 20, dy + 1}, {dx + 60, dy + 70}, {dx - 40, dy + 70}}, true) * FLOORM
local s2 = poly({{dx - 12, dy + 1}, {dx + 14, dy + 1}, {dx + 30, dy + 32}, {dx - 18, dy + 32}}, true) * FLOORM
work(s1 - s2, {hand="body", tool="filbert 3", pile=pile{{"burnt sienna",1},{"bone black",0.9},{"raw sienna",0.5}, medium=0.06}, coverage=4, fill=true, clip=s1 - s2, angle=1.4, load=0.9})
work(s2, {hand="body", tool="filbert 3", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.5},{"bone black",0.4}, medium=0.06}, coverage=4, fill=true, clip=s2, angle=1.4, load=0.9})
blend((s1:grow(6) - s1:shrink(5)) * FLOORM, {angle=1.4})
blend((s2:grow(4) - s2:shrink(4)) * FLOORM, {angle=1.4})
SUNBAND = band

--@ chunk 11
-- pass, 2 (on dry paint): bands with lit lips, the hard white sun edge, the objective ring; fork and drum edges
print(wait(5*24*60))
local A, Bp = {440, 545}, {508, 215}
local hot = pile{{"zinc white",2.5},{"lemon chrome",0.12}, medium=0.04}
local lipW = pile{{"lead white",1.6},{"yellow ochre",0.9},{"Mars orange",0.15}, medium=0.06}
local ringD = pile{{"bone black",2},{"burnt sienna",0.6}, medium=0.06}
local tube = TUBE
local function ln(pts, pl, w, pr, clipm, kind)
  local b = brush{kind=kind or "round", width=w, point=(kind == nil) and 0.4 or nil, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
for _, t in ipairs{0.1, 0.38, 0.66, 0.88} do
  local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
  local w = lerp(120, 98, t) / 2
  local arc, lip = {}, {}
  for j = 0, 10 do
    local s = -1 + 2 * j / 10
    local sag = 9 * (1 - s * s)
    arc[#arc+1] = {x + 0.979 * s * w - 0.2018 * sag * 0.3, y + 0.2018 * s * w + sag}
    lip[#lip+1] = {x + 0.979 * s * w - 0.2018 * sag * 0.3, y + 0.2018 * s * w + sag - 6}
  end
  ln(arc, ringD, 9, {0.9, 0.9}, tube, "flat")
  local lp = {}
  for j = 5, 11 do lp[#lp+1] = lip[j] end
  ln(lp, lipW, 2.2, {0.3, 0.9}, tube)
end
-- the hard white edge along the sunward contour, unbroken, thinning toward the eyepiece
local e = {}
for i = 0, 10 do
  local t = i / 10
  local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
  local w = lerp(120, 98, t)
  e[#e+1] = {x + 0.979 * 0.47 * w, y + 0.2018 * 0.47 * w}
end
local eb = brush{kind="round", width=3.6, point=0.3}
eb:load(hot, 1); eb:stroke({e[11], e[8], e[5]}, {pressure={0.9, 0.8}, clip=tube:grow(1)})
eb:load(hot, 1); eb:stroke({e[5], e[3], e[1]}, {pressure={0.8, 0.25}, clip=tube:grow(1)})
-- objective ring: bronze, its far upper rim catching the white light, dark glass with one cold glint
local ring = ellipse(Bp[1], Bp[2] - 2, 52, 15) - ellipse(Bp[1], Bp[2] - 2, 41, 10)
work(ring, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.5},{"lead white",0.25}, medium=0.06}, coverage=6, fill=true, clip=ring, load=1})
local rim = {}
for j = 0, 12 do local a = math.pi * (1.1 + 0.85 * j / 12); rim[#rim+1] = {Bp[1] + 51 * math.cos(a), Bp[2] - 2 + 14.5 * math.sin(a)} end
ln(rim, hot, 2.6, {0.4, 0.95})
ln({{Bp[1] + 12, Bp[2] - 6}, {Bp[1] + 24, Bp[2] - 4}}, pile{{"zinc white",1.5},{"ultramarine ash",0.6}, medium=0.05}, 1.6, {0.6, 0.3})
-- fork and drum: lit edges toward the slot, a dark lower lip
ln({{603, 565}, {624, 450}, {596, 370}}, lipW, 2.4, {0.6, 0.9}, FORK:grow(1))
ln({{434, 565}, {418, 450}, {436, 374}}, lipW, 1.6, {0.3, 0.6}, FORK:grow(1))
ln({{386, 560}, {500, 557}, {614, 560}}, lipW, 2.4, {0.7, 0.9}, DRUM:grow(1))
ln({{372, 616}, {500, 619}, {628, 616}}, ringD, 4, {0.9, 0.9}, DRUM:grow(1))
for _, p in ipairs{{418, 400}, {586, 395}} do
  local m = ellipse(p[1], p[2], 13, 13)
  work(m, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.5}, medium=0.06}, coverage=6, fill=true, clip=m, load=1})
  local c = {}
  for j = 0, 8 do local a = -1.3 + 1.6 * j / 8; c[#c+1] = {p[1] + 12 * math.cos(a), p[2] + 12 * math.sin(a)} end
  ln(c, hot, 1.6, {0.6, 0.6})
end
-- the doorway spill came out a big warm mound: put the floor back and lay a thinner, dimmer tongue
local dx, dy = 150, FARRIM(150) + 2
local big = poly({{dx - 18, dy + 1}, {dx + 20, dy + 1}, {dx + 60, dy + 70}, {dx - 40, dy + 70}}, true):grow(8) * FLOORM
work(big, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}, coverage=6, fill=true, clip=big, angle=0, load=1})
local t1 = poly({{dx - 14, dy + 1}, {dx + 16, dy + 1}, {dx + 34, dy + 48}, {dx - 22, dy + 48}}, true) * FLOORM
local t2 = poly({{dx - 9, dy + 1}, {dx + 11, dy + 1}, {dx + 18, dy + 20}, {dx - 10, dy + 20}}, true) * FLOORM
work(t1 - t2, {hand="body", tool="filbert 3", pile=pile{{"bone black",1.3},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}, coverage=4, fill=true, clip=t1 - t2, angle=1.4, load=0.9})
work(t2, {hand="body", tool="filbert 3", pile=pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.7},{"yellow ochre",0.25}, medium=0.06}, coverage=4, fill=true, clip=t2, angle=1.4, load=0.9})
blend((t1:grow(5) - t1:shrink(4)) * FLOORM, {angle=1.4})

--@ chunk 12
-- pass, 3: the docent seated in a high-backed chair, robed, face lifted to the eyepiece, one hand on a brass wheel
print(wait(2*24*60))
local keepT = TUBE:grow(1) + FORK
local brK = pile{{"bone black",2},{"burnt sienna",0.6},{"Mars brown",0.3}, medium=0.06}
local robe = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",0.8}, medium=0.06}
local robeM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.45},{"yellow ochre",0.2}, medium=0.06}
local bone = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.1}, medium=0.06}
-- the old docent painted out to floor and dome behind (it is replaced)
local old = DOCM:grow(4) - keepT
local fl = pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}
work(old * FLOORM, {hand="body", tool="filbert 4", pile=fl, coverage=6, fill=true, clip=old * FLOORM, angle=0, load=1})
work(old * DOME, {hand="body", tool="filbert 4", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}, medium=0.06}, coverage=6, fill=true, clip=old * DOME, angle=0, load=1})
-- the chair: a tall back rising behind, a seat, a pedestal
CHB = poly({{292, 372}, {318, 366}, {330, 560}, {300, 566}}, true)
CHS = poly({{298, 548}, {388, 544}, {392, 560}, {300, 566}})
CHP = ribbon({{345, 562}, {342, 616}}, 9) + poly({{315, 612}, {372, 612}, {376, 622}, {311, 622}})
local CH = (CHB + CHS + CHP) - keepT
work(CH, {hand="body", tool="filbert 4", pile=brK, coverage=6, fill=true, clip=CH, angle=math.pi/2, load=1})
-- the robed body, seated, leaning forward and up toward the eyepiece
BODY = poly({{322, 545}, {392, 548}, {388, 520}, {380, 470}, {368, 440}, {345, 432}, {330, 450}, {322, 500}}, true) - keepT
work(BODY, {hand="body", tool="filbert 4", pile=robe, coverage=6, fill=true, clip=BODY, angle=math.pi/2, load=1})
local front = BODY * poly({{352, 430}, {400, 430}, {400, 560}, {362, 560}})
work(front, {hand="body", tool="filbert 3", pile=robeM, coverage=5, fill=true, clip=front, angle=math.pi/2, load=1})
-- head and the bone face lifted up and right to the eyepiece
HEAD = ellipse(370, 420, 13, 16)
work(HEAD, {hand="detail", pile=robe, coverage=6, fill=true, clip=HEAD, load=1})
FACE = poly({{372, 404}, {386, 410}, {388, 428}, {378, 434}, {372, 420}}, true)
work(FACE, {hand="detail", pile=bone, coverage=6, fill=true, clip=FACE, load=1})
-- the eyepiece: a short bronze barrel from the tube's foot to the face
EYEP = ribbon({{390, 418}, {414, 440}}, 9) - FACE
work(EYEP, {hand="detail", pile=brK, coverage=6, fill=true, clip=EYEP, load=1})
-- the arm reaching to a brass wheel on the tube's side
ARM = ribbon({{372, 470}, {395, 492}, {412, 500}}, {11, 9, 7})
work(ARM, {hand="detail", pile=robe, coverage=6, fill=true, clip=ARM, load=1})
WHEEL = {422, 500}

--@ chunk 13
-- pass, 4 (on set paint): the brass wheel and the bone hand on it; the slot's light rimming the docent and its chair
print(wait(4*24*60))
local hot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.1}, medium=0.04}
local warm = pile{{"lead white",1.6},{"yellow ochre",0.8},{"cadmium yellow",0.15}, medium=0.06}
local brass = pile{{"yellow ochre",1.4},{"Mars orange",0.5},{"lead white",0.5},{"burnt sienna",0.3}, medium=0.06}
local bone = pile{{"lead white",2},{"yellow ochre",0.5}, medium=0.06}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
local wx, wy = WHEEL[1], WHEEL[2]
local wh = {}
for j = 0, 20 do local a = 2 * math.pi * j / 20; wh[#wh+1] = {wx + 13 * math.cos(a), wy + 15 * math.sin(a)} end
ln(wh, brass, 2.6, {0.8, 0.8})
for _, a in ipairs{0.4, 1.45, 2.5} do ln({{wx - 13 * math.cos(a), wy - 15 * math.sin(a)}, {wx + 13 * math.cos(a), wy + 15 * math.sin(a)}}, brass, 1.4, {0.6, 0.6}) end
local hub = ellipse(wx, wy, 3, 3); work(hub, {hand="detail", pile=brass, coverage=5, fill=true, clip=hub, load=1})
local hc = {}
for j = 0, 6 do local a = -1.2 + 1.2 * j / 6; hc[#hc+1] = {wx + 13 * math.cos(a), wy + 15 * math.sin(a)} end
ln(hc, hot, 1.6, {0.6, 0.6})
-- the hand: long bone fingers over the rim
ln({{404, 497}, {412, 494}, {418, 489}}, bone, 3.2, {0.8, 0.5})
ln({{406, 502}, {414, 501}, {420, 498}}, bone, 2.4, {0.6, 0.3})
-- rim from the slot (upper right): crown of the head, the face's brow, shoulder, the robe's sunward side, the chair's top
ln({{362, 406}, {372, 402}, {382, 406}}, hot, 2.4, {0.6, 0.9}, HEAD:grow(2) + FACE:grow(2))
ln({{376, 404}, {387, 410}, {389, 424}}, hot, 1.6, {0.9, 0.3}, FACE:grow(1.5))
ln({{368, 440}, {381, 470}, {389, 520}, {392, 546}}, warm, 2.2, {0.8, 0.2}, BODY:grow(1.5))
ln({{373, 470}, {396, 490}, {410, 497}}, warm, 1.6, {0.7, 0.4}, ARM:grow(1.5))
ln({{293, 372}, {318, 366}}, warm, 2.2, {0.7, 0.7}, CHB:grow(1.5))
ln({{318, 368}, {324, 460}, {330, 556}}, warm, 1.6, {0.6, 0.15}, CHB:grow(1.5))
ln({{300, 547}, {388, 543}}, warm, 1.6, {0.4, 0.7}, CHS:grow(1.5))
-- the face itself: a dark eye-slot under the brow, so it reads as a face lifted to the glass
ln({{377, 414}, {385, 417}}, pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}, 1.6, {0.7, 0.6}, FACE)

--@ chunk 14
-- the first, slighter fork still showed between the tube and the new arm: paint it out to dome and floor
local r = rect(530, 340, 52, 222) - TUBE:grow(1) - FORK:grow(1) - DRUM:grow(1)
local fl = pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}
local band = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}, medium=0.06}
work(r * FLOORM, {hand="body", tool="filbert 4", pile=fl, coverage=6, fill=true, clip=r * FLOORM, angle=0, load=1})
work(r * DOME, {hand="body", tool="filbert 4", pile=band, coverage=6, fill=true, clip=r * DOME, angle=0, load=1})
