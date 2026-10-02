-- easel session "observatory_years": a painting replayed chunk by chunk.
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

--@ chunk 4
-- night in the slot (stars thick, a faint pale band); the telescope, fork and drum on the rail ring; the docent's chair,
-- the docent, and a crew child on its knee at the eyepiece; the small lamp on the floor
print(wait(2*24*60))
local starW = pile{{"zinc white",2.5},{"cerulean blue",0.05}, medium=0.04}
local band = poly({{470, -5}, {535, -5}, {530, 230}, {466, 230}}) * SLOT * mask(function(x, y) return (math.abs((x - 500) - (y - 110) * 0.25) < 22) and 1 or 0 end)
stipple(band, {pile=pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.5}, medium=0.05}, width=1.6, coverage=2, feather=0.8, cluster=0.4})
for i = 1, 110 do
  local x, y = rand(452, 548), rand(0, 228)
  if SLOT:at(x, y) > 0.5 then
    local b = brush{kind="round", width=rand(0.7, 1.8), stiffness=0.5}
    b:load(starW, 0.8); b:touch(x, y, {pressure=rand(0.4, 0.9), clip=SLOT})
  end
end
local brD = pile{{"bone black",1.8},{"burnt sienna",0.9},{"Mars brown",0.4}, medium=0.06}
local brM = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.55},{"yellow ochre",0.35}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.3},{"lead white",0.5}, medium=0.06}
-- rail ring
for _, rr in ipairs{{340, 52, 7}, {300, 44, 5}} do
  local pts = {}
  for j = 0, 48 do local a = 2 * math.pi * j / 48; pts[#pts+1] = {500 + rr[1] * math.cos(a), 600 + rr[2] * math.sin(a)} end
  local r = ribbon(pts, rr[3])
  work(r, {hand="detail", pile=brM, coverage=5, fill=true, clip=r, load=1})
end
-- drum and fork
DRUM = poly({{385, 558}, {615, 558}, {630, 618}, {370, 618}}, true)
work(DRUM, {hand="body", tool="filbert 6", pile=brD, coverage=6, fill=true, clip=DRUM, angle=0, load=1})
local A, Bp = {440, 545}, {508, 215}
TUBE = ribbon({A, {474, 380}, Bp}, {120, 108, 98})
FORK = (ribbon({{415, 565}, {398, 450}, {420, 372}}, {40, 32, 26}) + ribbon({{585, 565}, {603, 450}, {578, 368}}, {44, 34, 26})) - TUBE
work(FORK, {hand="body", tool="filbert 6", pile=brD, coverage=6, fill=true, clip=FORK, angle=math.pi/2, load=1})
local function along(s0, s1)
  local L, R = {}, {}
  for i = 0, 10 do
    local t = i / 10
    local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
    local w = lerp(120, 98, t)
    L[#L+1] = {x + 0.979 * s0 * w, y + 0.2018 * s0 * w}
    table.insert(R, 1, {x + 0.979 * s1 * w, y + 0.2018 * s1 * w})
  end
  for _, p in ipairs(R) do L[#L+1] = p end
  return poly(L) * TUBE
end
ALONG = along
-- lamp low at the right: the tube's right side warm, a dark core, a cool reflected left edge from the slot
local zones = {
  {-0.52, -0.4, pile{{"bone black",1.2},{"ultramarine ash",0.6},{"burnt sienna",0.5}, medium=0.06}},
  {-0.4, 0.05, pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.15}, medium=0.06}},
  {0.05, 0.32, brM},
  {0.32, 0.52, brL},
}
for _, z in ipairs(zones) do local m = along(z[1], z[2]); work(m, {hand="body", tool="filbert 4", pile=z[3], coverage=6, fill=true, clip=m, angle=-1.37, load=1}) end
blend(along(-0.44, -0.36), {angle=-1.37}); blend(along(0.0, 0.1), {angle=-1.37}); blend(along(0.28, 0.36), {angle=-1.37})
-- the lamp on the floor, right of the drum: a small bronze lantern with a warm core
LAMP = {660, 600}
local lc = poly({{648, 578}, {672, 578}, {674, 606}, {646, 606}}, true)
work(lc, {hand="detail", pile=pile{{"lead white",1.8},{"cadmium yellow",0.5},{"Mars orange",0.2}, medium=0.05}, coverage=7, fill=true, clip=lc, load=1})
local core = ellipse(660, 592, 5, 8)
work(core, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.03}, coverage=7, fill=true, clip=core, load=1})
local cap = rect(644, 572, 32, 6)
work(cap, {hand="detail", pile=brD, coverage=7, fill=true, clip=cap, load=1})
-- the docent's chair and the docent at the eyepiece (as in the first painting), and the child on its knee
local robe = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",0.8}, medium=0.06}
local bone = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.1}, medium=0.06}
local CHB = poly({{292, 372}, {318, 366}, {330, 560}, {300, 566}}, true)
local CHS = poly({{298, 548}, {388, 544}, {392, 560}, {300, 566}})
local CHP = ribbon({{345, 562}, {342, 616}}, 9) + poly({{315, 612}, {372, 612}, {376, 622}, {311, 622}})
CH = (CHB + CHS + CHP) - TUBE - FORK
work(CH, {hand="body", tool="filbert 4", pile=brD, coverage=6, fill=true, clip=CH, angle=math.pi/2, load=1})
BODY = poly({{322, 545}, {392, 548}, {388, 520}, {380, 470}, {368, 440}, {345, 432}, {330, 450}, {322, 500}}, true) - TUBE - FORK
work(BODY, {hand="body", tool="filbert 4", pile=robe, coverage=6, fill=true, clip=BODY, angle=math.pi/2, load=1})
HEAD = ellipse(370, 420, 13, 16)
work(HEAD, {hand="detail", pile=robe, coverage=6, fill=true, clip=HEAD, load=1})
FACE = poly({{372, 404}, {386, 410}, {388, 428}, {378, 434}, {372, 420}}, true)
work(FACE, {hand="detail", pile=bone, coverage=6, fill=true, clip=FACE, load=1})
EYEP = ribbon({{390, 418}, {414, 440}}, 9) - FACE
work(EYEP, {hand="detail", pile=brD, coverage=6, fill=true, clip=EYEP, load=1})
-- the child on its knee: small grey coveralls, leaning up beside the docent's face to share the eyepiece
local grey = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.6},{"burnt sienna",0.15}, medium=0.06}
KID = poly({{378, 520}, {408, 522}, {412, 482}, {404, 456}, {388, 454}, {378, 480}}, true)
work(KID, {hand="detail", pile=grey, coverage=7, fill=true, clip=KID, load=1})
KHEAD = ellipse(400, 444, 10, 11)
work(KHEAD, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}, coverage=7, fill=true, clip=KHEAD, load=1})
KLEGS = ribbon({{384, 520}, {396, 540}, {394, 560}}, 8) + ribbon({{402, 520}, {412, 540}, {410, 560}}, 8)
work(KLEGS, {hand="detail", pile=grey, coverage=7, fill=true, clip=KLEGS, load=1})
-- the docent's arm round the child
local arm = ribbon({{338, 470}, {360, 500}, {388, 500}}, {12, 10, 8})
work(arm, {hand="detail", pile=robe, coverage=7, fill=true, clip=arm, load=1})

--@ chunk 5
-- the milky band too loud: slot repainted night, stars again, a very faint band; the tube's upper lit zone dimmed (the lamp is
-- low); a warm pool round the lamp on the floor; two children lying on the floor looking up at the dome
print(wait(3*24*60))
local sp = pile{{"bone black",2},{"ultramarine blue",0.8}, medium=0.06}
work(SLOT, {hand="body", tool="filbert 4", pile=sp, coverage=7, fill=true, clip=SLOT, angle=math.pi/2, load=1})
local tz = ALONG(0.05, 0.52) * rect(0, 0, 1000, 380)
work(tz, {hand="body", tool="filbert 4", pile=pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.8}, medium=0.06}, coverage=6, fill=true, clip=tz, angle=-1.37, load=1})
blend(ALONG(0.05, 0.52) * rect(0, 360, 1000, 40), {angle=math.pi/2})
-- lamp pool, soft, two steps
local p1 = ellipse(660, 610, 190, 40) - DRUM - TUBE
local p2 = ellipse(660, 605, 90, 20) - DRUM - TUBE
work(p1 - p2, {hand="body", tool="filbert 5", pile=pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.4}, medium=0.06}, coverage=4, fill=true, clip=p1 - p2, angle=0, load=0.85})
work(p2, {hand="body", tool="filbert 4", pile=pile{{"raw sienna",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"bone black",0.3}, medium=0.06}, coverage=4, fill=true, clip=p2, angle=0, load=0.85})
blend((ellipse(660, 610, 205, 46) - ellipse(660, 610, 170, 32)) - DRUM - TUBE, {angle=0})
-- two children lying on their backs on the floor
local grey = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.55},{"burnt sienna",0.15}, medium=0.06}
local face = pile{{"lead white",1.5},{"rose madder",0.12},{"yellow ochre",0.25}, medium=0.05}
local hairs = {pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.4}, medium=0.06}, pile{{"bone black",2},{"burnt sienna",0.3}, medium=0.06}}
KIDS2 = {}
for i, c in ipairs{{180, 640, 1}, {800, 640, -1}} do
  local x, y, d = c[1], c[2], c[3]
  local body = ribbon({{x, y}, {x - d * 60, y + 4}, {x - d * 110, y + 2}}, {26, 24, 18})
  local legs = ribbon({{x - d * 110, y - 2}, {x - d * 160, y - 6}}, 10) + ribbon({{x - d * 110, y + 6}, {x - d * 162, y + 12}}, 10)
  local arms = ribbon({{x - d * 20, y - 10}, {x + d * 10, y - 22}, {x + d * 20, y - 18}}, 7)
  local m = body + legs + arms
  work(m, {hand="detail", pile=grey, coverage=7, fill=true, clip=m, load=1})
  local h = ellipse(x + d * 24, y - 4, 15, 13)
  work(h, {hand="detail", pile=hairs[i], coverage=7, fill=true, clip=h, load=1})
  local f = ellipse(x + d * 22, y - 9, 9, 6)
  work(f, {hand="detail", pile=face, coverage=7, fill=true, clip=f, load=1})
  KIDS2[i] = m + h
end

--@ chunk 6
-- (dry) stars back in the slot; the tube's lit zone dimmed to one even warm side with a soft seam, bands with lit lips and the
-- objective ring; the lamp restated over its pool; the children moved up off the bottom edge
print(wait(4*24*60))
local starW = pile{{"zinc white",2.5},{"cerulean blue",0.05}, medium=0.04}
for i = 1, 140 do
  local x, y = rand(452, 548), rand(0, 228)
  if SLOT:at(x, y) > 0.5 then
    local b = brush{kind="round", width=rand(0.7, 1.9), stiffness=0.5}
    b:load(starW, 0.85); b:touch(x, y, {pressure=rand(0.4, 0.9), clip=SLOT})
  end
end
local lit = ALONG(0.08, 0.52)
work(lit, {hand="body", tool="filbert 4", pile=pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}, coverage=6, fill=true, clip=lit, angle=-1.37, load=1})
local edge = ALONG(0.36, 0.52) * rect(0, 360, 1000, 300)
work(edge, {hand="body", tool="filbert 3", pile=pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.35},{"burnt sienna",0.3}, medium=0.06}, coverage=6, fill=true, clip=edge, angle=-1.37, load=1})
blend(ALONG(0.0, 0.16), {angle=-1.37}); blend(ALONG(0.3, 0.42) * rect(0, 360, 1000, 300), {angle=-1.37})
blend(ALONG(0.3, 0.52) * rect(0, 340, 1000, 50), {angle=math.pi/2})
-- floor: old children and the pool's hard edge painted out
local fl = pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.25}, medium=0.06}
local out = (KIDS2[1] + KIDS2[2]):grow(4)
work(out, {hand="body", tool="filbert 4", pile=fl, coverage=7, fill=true, clip=out, angle=0, load=1})
blend((ellipse(660, 610, 215, 50) - ellipse(660, 610, 160, 28)) - DRUM - TUBE, {angle=0})
blend((ellipse(660, 610, 215, 50) - ellipse(660, 610, 160, 28)) - DRUM - TUBE, {angle=math.pi/2})
-- the lamp
local brD = pile{{"bone black",1.8},{"burnt sienna",0.9},{"Mars brown",0.4}, medium=0.06}
local lc = poly({{648, 578}, {672, 578}, {674, 606}, {646, 606}}, true)
work(lc, {hand="detail", pile=pile{{"lead white",1.8},{"cadmium yellow",0.5},{"Mars orange",0.2}, medium=0.05}, coverage=8, fill=true, clip=lc, load=1})
local cap = rect(644, 572, 32, 6) + rect(644, 606, 32, 5)
work(cap, {hand="detail", pile=brD, coverage=8, fill=true, clip=cap, load=1})
-- children, lying, higher in the frame
local grey = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.55},{"burnt sienna",0.15}, medium=0.06}
local face = pile{{"lead white",1.5},{"rose madder",0.12},{"yellow ochre",0.25}, medium=0.05}
local hairs = {pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone black",0.4}, medium=0.06}, pile{{"bone black",2},{"burnt sienna",0.3}, medium=0.06}}
KIDS2 = {}
for i, c in ipairs{{250, 622, 1}, {760, 628, -1}} do
  local x, y, d = c[1], c[2], c[3]
  local body = ribbon({{x, y}, {x - d * 55, y + 3}, {x - d * 100, y + 2}}, {22, 20, 15})
  local legs = ribbon({{x - d * 100, y - 2}, {x - d * 145, y - 5}}, 9) + ribbon({{x - d * 100, y + 5}, {x - d * 146, y + 10}}, 9)
  local arms = ribbon({{x - d * 20, y - 8}, {x + d * 6, y - 20}, {x + d * 18, y - 16}}, 6)
  local m = body + legs + arms
  work(m, {hand="detail", pile=grey, coverage=7, fill=true, clip=m, load=1})
  local h = ellipse(x + d * 22, y - 3, 13, 11)
  work(h, {hand="detail", pile=hairs[i], coverage=7, fill=true, clip=h, load=1})
  local f = ellipse(x + d * 20, y - 8, 8, 5)
  work(f, {hand="detail", pile=face, coverage=7, fill=true, clip=f, load=1})
  KIDS2[i] = m + h
end

--@ chunk 7
-- (dry) the tube's bands with lit lips and the objective ring with a cold glint from the stars; fork and drum edges toward the
-- lamp; the lamp's light on the docent, the child on its knee, the children on the floor; a soft glow round the lamp
print(wait(4*24*60))
local A, Bp = {440, 545}, {508, 215}
local warm = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.45}, medium=0.06}
local hot = pile{{"lead white",1.6},{"yellow ochre",0.7},{"cadmium yellow",0.2}, medium=0.05}
local cold = pile{{"zinc white",1.6},{"ultramarine ash",0.5},{"lead white",0.4}, medium=0.05}
local ringD = pile{{"bone black",2},{"burnt sienna",0.6}, medium=0.06}
local function ln(pts, pl, w, pr, clipm, kind)
  local b = brush{kind=kind or "round", width=w, point=(kind == nil) and 0.4 or nil, stiffness=0.6}
  b:load(pl, 0.95); b:stroke(pts, {pressure=pr, ramps={0.05, 0.15}, clip=clipm})
end
for _, t in ipairs{0.12, 0.4, 0.68, 0.9} do
  local x, y = lerp(A[1], Bp[1], t), lerp(A[2], Bp[2], t)
  local w = lerp(120, 98, t) / 2
  local arc, lip = {}, {}
  for j = 0, 10 do
    local s = -1 + 2 * j / 10
    local sag = 9 * (1 - s * s)
    arc[#arc+1] = {x + 0.979 * s * w, y + 0.2018 * s * w + sag}
    lip[#lip+1] = {x + 0.979 * s * w, y + 0.2018 * s * w + sag + 6}
  end
  ln(arc, ringD, 9, {0.9, 0.9}, TUBE, "flat")
  local lp = {}
  for j = 6, 11 do lp[#lp+1] = lip[j] end
  ln(lp, warm, 2.2, {0.3, 0.8}, TUBE)
end
local ring = ellipse(Bp[1], Bp[2] - 2, 52, 15) - ellipse(Bp[1], Bp[2] - 2, 41, 10)
work(ring, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.7}, medium=0.06}, coverage=6, fill=true, clip=ring, load=1})
local glass = ellipse(Bp[1], Bp[2] - 2, 41, 10)
work(glass, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.5}, medium=0.06}, coverage=6, fill=true, clip=glass, load=1})
local rim = {}
for j = 0, 12 do local a = math.pi * (1.1 + 0.8 * j / 12); rim[#rim+1] = {Bp[1] + 51 * math.cos(a), Bp[2] - 2 + 14.5 * math.sin(a)} end
ln(rim, cold, 1.8, {0.5, 0.5})
ln({{Bp[1] + 10, Bp[2] - 6}, {Bp[1] + 22, Bp[2] - 4}}, cold, 1.6, {0.7, 0.3})
-- fork and drum toward the lamp (lower right)
ln({{606, 560}, {624, 450}, {598, 372}}, warm, 2.6, {0.9, 0.3}, FORK:grow(1))
ln({{436, 560}, {418, 450}, {436, 376}}, warm, 1.8, {0.6, 0.2}, FORK:grow(1))
ln({{500, 560}, {614, 560}, {628, 600}}, warm, 2.6, {0.4, 0.9}, DRUM:grow(1))
-- the docent and child: lamp light on their right sides, the child's face lifted to the eyepiece
ln({{386, 412}, {388, 428}}, hot, 1.8, {0.7, 0.5}, FACE:grow(1))
ln({{388, 470}, {392, 520}, {392, 546}}, warm, 2.2, {0.8, 0.3}, BODY:grow(1.5))
ln({{410, 460}, {413, 490}, {408, 520}}, pile{{"lead white",1.2},{"ultramarine ash",0.3},{"yellow ochre",0.4}, medium=0.05}, 2.2, {0.8, 0.3}, KID:grow(1.5))
local kf = ellipse(406, 440, 4, 5)
work(kf, {hand="detail", pile=pile{{"lead white",1.5},{"rose madder",0.12},{"yellow ochre",0.25}, medium=0.05}, coverage=7, fill=true, clip=kf, load=1})
ln({{412, 520}, {414, 540}, {412, 558}}, warm, 1.6, {0.6, 0.3}, KLEGS:grow(1))
-- the floor children: the right one lit on its lamp side, the left one only a faint rim
ln({{720, 616}, {700, 618}, {660, 619}, {620, 620}}, warm, 2.2, {0.8, 0.3}, KIDS2[2]:grow(1.5))
ln({{742, 618}, {748, 614}}, hot, 2, {0.8, 0.8}, KIDS2[2]:grow(1.5))
ln({{232, 612}, {200, 616}, {160, 616}}, warm, 1.6, {0.5, 0.1}, KIDS2[1]:grow(1.5))
-- a soft glow round the lamp
local g = ellipse(660, 590, 40, 32) - poly({{646, 572}, {676, 572}, {676, 612}, {646, 612}})
stipple(g, {pile=pile{{"yellow ochre",1},{"lead white",0.8},{"Mars orange",0.2}, medium=0.05}, width=1.1, coverage=function(x, y) local d = math.sqrt(((x - 660) / 40)^2 + ((y - 590) / 32)^2); return clamp(1 - d, 0, 1)^1.5 * 2.4 end, feather=0.9, cluster=0.1})
