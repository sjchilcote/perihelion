-- easel session "spine_walk": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=16/9, linen={16,18}, seed=4242, ground={{pile={{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.2}}, um=140, apply="knife", texture=0.3}}}
VP = {500, 240}          -- the hub, where the spine converges
-- the spine's top: from the bottom edge (wide) to the hub (narrow)
function edgeL(t) return {lerp(120, 476, t), lerp(570, VP[2] + 14, t)} end   -- t 0 near .. 1 at hub
function edgeR(t) return {lerp(880, 524, t), lerp(570, VP[2] + 14, t)} end
-- depth spacing: rows crowd toward the hub
function depth(k) return 1 - 1 / (1 + 0.16 * k) end
print(W, H)

--@ chunk 2
-- the big shapes: lit spine top, a half-lit left flank and a black right flank, the hub, the ring's arch overhead
LITB  = pile{{"yellow ochre",2},{"raw sienna",0.8},{"lead white",1.2},{"cadmium yellow",0.2}}
LITB2 = pile{{"yellow ochre",2},{"raw sienna",1.2},{"burnt sienna",0.4},{"lead white",0.6}}
FLANK = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"yellow ochre",0.5}}
BLACK = pile{{"bone black",2},{"ultramarine blue",0.3}}
ROAD = poly({edgeL(0), edgeR(0), edgeR(1), edgeL(1)})
LFLANK = poly({{476,254},{120,570},{-10,570},{-10,530},{463,286}})
RFLANK = poly({{524,254},{880,570},{1010,570},{1010,530},{537,286}})
HUB = ellipse(500, 236, 96, 72)
local function arc(rx, ry, a0, a1)
  local pts = {}
  for k = 0, 60 do local a = lerp(a0, a1, k / 60); pts[#pts + 1] = {500 + rx * math.cos(a), 780 + ry * math.sin(a)} end
  return pts
end
local outer = arc(700, 720, math.pi * 1.02, math.pi * 1.98)
local inner = arc(640, 650, math.pi * 1.98, math.pi * 1.02)
local ap = {}
for _, p in ipairs(outer) do ap[#ap + 1] = p end
for _, p in ipairs(inner) do ap[#ap + 1] = p end
ARCH = poly(ap)
work(ARCH, {hand="body", tool="filbert 6", pile=LITB2, coverage=3.2, fill=true, angle=0, clip=ARCH, seed=201})
work(RFLANK, {hand="body", tool="filbert 6", pile=BLACK, coverage=3, fill=true, angle=0.6, clip=RFLANK, seed=202})
work(LFLANK, {hand="body", tool="filbert 6", pile=FLANK, coverage=3.2, fill=true, angle=-0.6, clip=LFLANK, seed=203})
work(HUB, {hand="body", tool="filbert 6", pile=LITB2, coverage=3.2, fill=true, angle=0, clip=HUB, seed=204})
work(ROAD, {hand="body", tool="filbert 7", pile=LITB, coverage=3.2, fill=true, angle=-1.57, clip=ROAD, seed=205})

--@ chunk 3
-- sky to true black; vault bays as black arched recesses down the lit flank
local SKYB = pile{{"bone black",2},{"ultramarine blue",0.2}}
local sky = -(ROAD + LFLANK + RFLANK + HUB + ARCH)
work(sky, {hand="body", tool="filbert 8", pile=SKYB, coverage=2.4, fill=true, angle=0.2, clip=sky, seed=301})
BAYS = {}
for k = 0, 9 do
  local t0, t1 = depth(k), depth(k + 0.62)
  local a, b = edgeL(t0), edgeL(t1)
  -- the flank's lower line at the same depths
  local function low(t) return {lerp(-10, 463, t), lerp(560, 286, t)} end
  local c, d = low(t1), low(t0)
  local top = {lerp(a[1], d[1], 0.18), lerp(a[2], d[2], 0.18)}
  local top2 = {lerp(b[1], c[1], 0.18), lerp(b[2], c[2], 0.18)}
  local bot = {lerp(a[1], d[1], 0.85), lerp(a[2], d[2], 0.85)}
  local bot2 = {lerp(b[1], c[1], 0.85), lerp(b[2], c[2], 0.85)}
  local mid = {(top[1] + top2[1]) / 2, (top[2] + top2[2]) / 2 - 0.25 * math.abs(top2[1] - top[1])}
  local pts = {bot, top, mid, top2, bot2}
  BAYS[#BAYS + 1] = pts
  local q = poly(pts, true) * LFLANK
  work(q, {hand="detail", pile=BLACK, coverage=4.5, fill=true, angle=0, clip=q, seed=310 + k})
end

--@ chunk 4
-- the walker: first his black, then (on dry paint) his lit back. His shadow thrown ahead of him toward the hub, black and sharp.
local fx, fy = 474, 474
FOOT = {fx, fy}
SHADOW = poly({{fx - 9, fy}, {fx + 7, fy - 1}, {fx + 15, fy - 92}, {fx + 18, fy - 104}, {fx + 13, fy - 110}, {fx + 8, fy - 104}, {fx + 9, fy - 92}})
work(SHADOW, {hand="detail", pile=BLACK, coverage=5, fill=true, angle=-1.45, clip=SHADOW, seed=401})
FIG = ellipse(fx, fy - 40, 6, 6.5) + poly({{fx - 11, fy - 34}, {fx + 11, fy - 34}, {fx + 10, fy - 14}, {fx - 10, fy - 14}})
  + ribbon({{fx - 5, fy - 15}, {fx - 7, fy - 6}, {fx - 8, fy + 1}}, 6) + ribbon({{fx + 5, fy - 15}, {fx + 6, fy - 7}, {fx + 6, fy - 1}}, 6)
  + ribbon({{fx - 11, fy - 32}, {fx - 15, fy - 22}, {fx - 15, fy - 13}}, 4.5) + ribbon({{fx + 11, fy - 32}, {fx + 14, fy - 22}, {fx + 14, fy - 14}}, 4.5)
work(FIG, {hand="detail", pile=BLACK, coverage=5, fill=true, angle=1.57, clip=FIG, seed=402})
-- the rail along the spine's left edge, on short posts
RAIL = {}
for k = 0, 14 do
  local t = depth(k * 0.9)
  local p = edgeL(t)
  local q = {lerp(p[1], 500, 0.05), p[2] - 1}
  RAIL[#RAIL + 1] = {q[1], q[2] - lerp(16, 2, t)}
  local post = ribbon({{q[1], q[2]}, {q[1], q[2] - lerp(16, 2, t)}}, lerp(2.4, 0.6, t))
  work(post, {hand="detail", pile=BLACK, coverage=5, fill=true, angle=1.57, clip=post, seed=410 + k})
end
local rail = ribbon(RAIL, 2.2)
work(rail, {hand="detail", pile=BLACK, coverage=5, fill=true, angle=-0.7, clip=rail, seed=430})
print(#RAIL, RAIL[3][1], RAIL[3][2])

--@ chunk 5
print(wait(4*24*60)); print(drying(500,400), drying(474,440))

--@ chunk 6
-- on dry paint. The blacks again where they mixed into the gold; then the light: scale lips with their black shadows,
-- the arch's plates, the hub's rings, the bays' rims, the walker's lit back and red cloth, the line, a few stars
local B = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
work(SHADOW, {hand="detail", pile=B, coverage=5, fill=true, angle=-1.45, clip=SHADOW, seed=601})
work(FIG, {hand="detail", pile=B, coverage=5, fill=true, angle=1.57, clip=FIG, seed=602})
local rig = brush{kind="rigger", width=2.0, point=0.85}
local function S(p, ld, pts, pr, clip) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.2}, clip=clip}) end
local LIP  = pile{{"lead white",2.5},{"yellow ochre",0.6},{"cadmium yellow",0.3}}
local WHT  = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}
-- scale-plates down the road: a lit lip, and just beyond it the black shadow it throws away from us
for k = 0, 34 do
  local t = depth(k * 0.55)
  local a, b = edgeL(t), edgeR(t)
  local n = 11
  local off = (k % 2) * 0.5
  local wd = (b[1] - a[1]) / n
  local sag = wd * 0.32
  local pr = lerp(0.55, 0.12, t)
  for j = -1, n do
    local x0 = a[1] + (j + off) * wd
    local x1 = x0 + wd
    if x1 > a[1] and x0 < b[1] then
      local arc, sh = {}, {}
      for s = 0, 6 do
        local u = s / 6
        local x = lerp(x0, x1, u)
        local y = a[2] + sag * math.sin(math.pi * u)
        arc[#arc + 1] = {x, y}
        sh[#sh + 1] = {x, y - lerp(2.2, 0.5, t)}
      end
      S(B, 0.7, sh, {pr, pr}, ROAD)
      S(LIP, 0.7, arc, {pr * 0.8, pr * 0.8}, ROAD)
    end
  end
end
-- the arch: its plates' seams, black, and the shadow line under its inner lip
local function archp(r, a) return {500 + r * 1.0 * math.cos(a), 780 + r * 1.03 * math.sin(a)} end
for k = 0, 40 do
  local a = lerp(math.pi * 1.02, math.pi * 1.98, k / 40)
  local p0 = {500 + 642 * math.cos(a), 780 + 652 * math.sin(a)}
  local p1 = {500 + 698 * math.cos(a), 780 + 718 * math.sin(a)}
  S(B, 0.7, {p0, p1}, {0.45, 0.45})
  S(LIP, 0.6, {{p0[1] + 3, p0[2]}, {p1[1] + 3, p1[2]}}, {0.25, 0.25})
end
local il = {}
for k = 0, 60 do local a = lerp(math.pi * 1.02, math.pi * 1.98, k / 60); il[#il + 1] = {500 + 641 * math.cos(a), 780 + 651 * math.sin(a)} end
S(B, 0.8, il, {0.8, 0.8})
-- the hub: rings of black and lit rims
for i, r in ipairs({{88, 66}, {70, 52}, {50, 38}, {28, 22}}) do
  local pts, lit = {}, {}
  for k = 0, 40 do local a = math.pi + math.pi * k / 40; pts[#pts + 1] = {500 + r[1] * math.cos(a), 236 + r[2] * math.sin(a)}; lit[#lit + 1] = {500 + r[1] * math.cos(a), 236 + r[2] * math.sin(a) + 2} end
  S(B, 0.8, pts, {0.6, 0.6}); S(LIP, 0.6, lit, {0.3, 0.3})
end
-- the bays: a lit rim round each arch head
for _, pts in ipairs(BAYS) do S(LIP, 0.6, {pts[2], pts[3], pts[4]}, {0.35, 0.3}) end
-- the right flank meets the road along a hard lit edge
S(WHT, 0.8, {edgeR(0), edgeR(1)}, {0.6, 0.2})
S(LIP, 0.7, {edgeL(0), edgeL(1)}, {0.5, 0.15})
-- the walker: his back lit white-gold, a crimson cloth across his shoulders, his helm's crown; black sides kept
local fx, fy = FOOT[1], FOOT[2]
local STEEL = pile{{"lead white",2},{"yellow ochre",0.5},{"bone black",0.15}}
local back = poly({{fx - 7, fy - 33}, {fx + 6, fy - 33}, {fx + 6, fy - 16}, {fx - 7, fy - 16}})
work(back, {hand="detail", pile=STEEL, coverage=4, fill=true, angle=1.57, clip=back, seed=603})
local CRIM = pile{{"cadmium red",1},{"vermilion",0.6},{"rose madder",0.3}}
local cloth = poly({{fx - 11, fy - 34}, {fx + 11, fy - 34}, {fx + 8, fy - 27}, {fx - 2, fy - 22}, {fx - 9, fy - 26}})
work(cloth, {hand="detail", pile=CRIM, coverage=4, fill=true, angle=0, clip=cloth, seed=604})
S(STEEL, 0.8, {{fx - 4, fy - 45}, {fx + 3, fy - 45}}, {0.6, 0.5})
S(STEEL, 0.7, {{fx - 6, fy - 12}, {fx - 7, fy - 4}}, {0.4, 0.3})
S(STEEL, 0.7, {{fx + 4, fy - 12}, {fx + 5, fy - 4}}, {0.4, 0.3})
S(WHT, 0.8, {{fx - 10, fy}, {fx - 5, fy}}, {0.6, 0.6}); S(WHT, 0.8, {{fx + 3, fy - 1}, {fx + 8, fy - 1}}, {0.6, 0.6})
-- the safety line, from his belt to the rail, sagging a little
local rp = RAIL[4]
S(WHT, 0.6, {{fx - 9, fy - 18}, {(fx + rp[1]) / 2, (fy - 18 + rp[2]) / 2 + 10}, {rp[1], rp[2]}}, {0.3, 0.25})
-- a few stars, small and hard
local tip = brush{kind="round", width=1.4, point=0.6}
for _, st in ipairs({{300,250,0.7},{250,330,0.4},{700,228,0.5},{770,300,0.8},{640,172,0.35},{360,182,0.5},{830,385,0.4},{175,395,0.6},{40,40,0.6},{950,58,0.5},{86,104,0.35},{905,18,0.7}}) do
  tip:reload(WHT, 0.8); tip:touch(st[1], st[2], {pressure=st[3]})
end

--@ chunk 7
-- the far road needs its scales too, finer and finer to the hub; the arch's underside in black; the hub's black portal
local B = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.6},{"cadmium yellow",0.3}}
local rig = brush{kind="rigger", width=1.5, point=0.9}
local function S(p, ld, pts, pr, clip) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.1, 0.2}, clip=clip}) end
for k = 35, 80 do
  local t = depth(k * 0.55)
  if t > 0.97 then break end
  local a, b = edgeL(t), edgeR(t)
  local n = 11
  local off = (k % 2) * 0.5
  local wd = (b[1] - a[1]) / n
  local sag = wd * 0.32
  local pr = lerp(0.3, 0.08, (t - 0.75) / 0.22)
  for j = -1, n do
    local x0 = a[1] + (j + off) * wd
    local x1 = x0 + wd
    if x1 > a[1] and x0 < b[1] then
      local arc, sh = {}, {}
      for s = 0, 4 do
        local u = s / 4
        local x = lerp(x0, x1, u)
        local y = a[2] + sag * math.sin(math.pi * u)
        arc[#arc + 1] = {x, y}; sh[#sh + 1] = {x, y - 0.5}
      end
      S(B, 0.6, sh, {pr, pr}, ROAD)
      S(LIP, 0.6, arc, {pr * 0.8, pr * 0.8}, ROAD)
    end
  end
end
-- the arch's underside: a black band inside its inner edge (no fill light, so it is simply black)
local pts = {}
for k = 0, 60 do local a = lerp(math.pi * 1.02, math.pi * 1.98, k / 60); pts[#pts + 1] = {500 + 630 * math.cos(a), 780 + 638 * math.sin(a)} end
local under = ribbon(pts, 18) - ARCH
work(under, {hand="detail", pile=B, coverage=5, fill=true, angle=0, clip=under, seed=701})
-- the hub's portal, black, and its lit sill
local portal = ellipse(500, 228, 16, 13)
work(portal, {hand="detail", pile=B, coverage=5, fill=true, angle=0, clip=portal, seed=702})
S(LIP, 0.7, {{486,237},{500,242},{514,237}}, {0.4, 0.4})

--@ chunk 8
-- the Sun is straight behind us, so the whole of his back faces it: light the helm's back, the pack, the legs' backs;
-- keep only a thin black at his sides
local fx, fy = FOOT[1], FOOT[2]
local STEEL = pile{{"lead white",2},{"yellow ochre",0.5},{"bone black",0.15}}
local STEELM = pile{{"lead white",1.2},{"yellow ochre",0.7},{"raw sienna",0.4},{"bone black",0.2}}
local helm = ellipse(fx, fy - 40, 4.2, 4.6)
local pack = poly({{fx - 8, fy - 27}, {fx + 7, fy - 27}, {fx + 7, fy - 15}, {fx - 8, fy - 15}})
local legs = ribbon({{fx - 5, fy - 14}, {fx - 6.5, fy - 6}, {fx - 7.5, fy}}, 3.6) + ribbon({{fx + 5, fy - 14}, {fx + 6, fy - 7}, {fx + 6, fy - 2}}, 3.6)
local arms = ribbon({{fx - 13, fy - 30}, {fx - 15, fy - 22}, {fx - 15, fy - 14}}, 2.4) + ribbon({{fx + 12, fy - 30}, {fx + 14, fy - 22}, {fx + 14, fy - 14}}, 2.4)
work(helm + pack, {hand="detail", pile=STEEL, coverage=4, fill=true, angle=1.57, clip=helm + pack, seed=801})
work(legs + arms, {hand="detail", pile=STEELM, coverage=4, fill=true, angle=1.57, clip=legs + arms, seed=802})
local rig = brush{kind="rigger", width=1.6, point=0.9}
rig:reload(pile{{"bone black",2.2}}, 0.8); rig:stroke({{fx - 8, fy - 21}, {fx + 7, fy - 21}}, {pressure={0.5, 0.5}})

--@ chunk 9
-- darks first: the arch's inner side face, the hub drum's side, a deeper portal, the walker larger in black; then let it dry
local B = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
local function band(r0x, r0y, r1x, r1y)
  local pts = {}
  for k = 0, 80 do local a = lerp(math.pi * 1.02, math.pi * 1.98, k / 80); pts[#pts + 1] = {500 + r0x * math.cos(a), 780 + r0y * math.sin(a)} end
  for k = 80, 0, -1 do local a = lerp(math.pi * 1.02, math.pi * 1.98, k / 80); pts[#pts + 1] = {500 + r1x * math.cos(a), 780 + r1y * math.sin(a)} end
  return poly(pts)
end
ARCHSIDE = band(641, 651, 600, 604) - HUB:grow(2)
work(ARCHSIDE, {hand="body", tool="filbert 4", pile=B, coverage=4.5, fill=true, angle=0, clip=ARCHSIDE, seed=901})
DRUMSIDE = ellipse(506, 252, 96, 72) - HUB
work(DRUMSIDE, {hand="detail", pile=B, coverage=5, fill=true, angle=0, clip=DRUMSIDE, seed=902})
PORTAL = ellipse(500, 226, 22, 17)
work(PORTAL, {hand="detail", pile=B, coverage=5, fill=true, angle=0, clip=PORTAL, seed=903})
-- the walker, 1.45x, same feet
local fx, fy = FOOT[1], FOOT[2]
local s = 1.45
local function P(x, y) return {fx + x * s, fy + y * s} end
FIG2 = ellipse(fx, fy - 41 * s, 6.5 * s, 7 * s)
  + poly({P(-12, -35), P(12, -35), P(11, -14), P(-11, -14)})
  + ribbon({P(-5, -15), P(-7, -6), P(-8, 1)}, 6.5 * s) + ribbon({P(5, -15), P(6, -7), P(6, -1)}, 6.5 * s)
  + ribbon({P(-12, -33), P(-16, -23), P(-16, -13)}, 5 * s) + ribbon({P(12, -33), P(15, -23), P(15, -14)}, 5 * s)
  + poly({P(-10, -37), P(10, -37), P(12, -31), P(-12, -31)})
SHADOW2 = poly({P(-9, 0), P(7, -1), P(15, -92), P(18, -104), P(13, -112), P(8, -104), P(9, -92)})
work(SHADOW2, {hand="detail", pile=B, coverage=5, fill=true, angle=-1.45, clip=SHADOW2, seed=904})
work(FIG2, {hand="detail", pile=B, coverage=5, fill=true, angle=1.57, clip=FIG2, seed=905})
print(wait(4 * 24 * 60))

--@ chunk 10
-- lights on dry paint: the arch's sun face as fine scale rows, a hard white rim, warm windows in the black side face;
-- the hub's raised ring lips; plates on the left flank; crisp bay rims; the walker drawn in lit plate
local B = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.6},{"cadmium yellow",0.3}}
local LIPD = pile{{"yellow ochre",1.5},{"raw sienna",1},{"lead white",0.8}}
local WHT = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}
local WARM = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.8}}
local rig = brush{kind="rigger", width=1.5, point=0.9}
local function S(p, ld, pts, pr, clip) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.08, 0.15}, clip=clip}) end
local function A(rx, ry, a) return {500 + rx * math.cos(a), 780 + ry * math.sin(a)} end
local a0, a1 = math.pi * 1.02, math.pi * 1.98
-- (1) arch face: rows of small scale lips across its width, many plates along it
for row = 0, 7 do
  local f = row / 7.5
  local rx, ry = lerp(645, 696, f), lerp(655, 716, f)
  local n = 120
  local off = (row % 2) * 0.5
  for j = 0, n - 1 do
    local u0, u1 = (j + off) / n, (j + off + 1) / n
    if u1 <= 1 then
      local arc, sh = {}, {}
      for s = 0, 3 do
        local a = lerp(a0, a1, lerp(u0, u1, s / 3))
        local sag = 3.5 * math.sin(math.pi * s / 3)
        local p = A(rx - sag, ry - sag, a)
        arc[#arc + 1] = p
        local q = A(rx - sag - 1.6, ry - sag - 1.6, a)
        sh[#sh + 1] = q
      end
      S(B, 0.6, sh, {0.28, 0.28}, ARCH)
      S(LIP, 0.6, arc, {0.22, 0.22}, ARCH)
    end
  end
end
-- the hard white rim along the arch's outer edge and its inner lip
local rim, inn = {}, {}
for k = 0, 90 do local a = lerp(a0, a1, k / 90); rim[#rim + 1] = A(699, 719, a); inn[#inn + 1] = A(643, 653, a) end
S(WHT, 0.8, rim, {0.5, 0.5})
S(WHT, 0.7, inn, {0.35, 0.35})
-- warm windows in the black side face, in two or three rows, tiny
local tip = brush{kind="round", width=1.3, point=0.6}
for row = 0, 2 do
  for j = 0, 140 do
    local a = lerp(a0 + 0.01, a1 - 0.01, (j + row * 0.33) / 140)
    if (j * 7 + row * 3) % 5 ~= 0 then
      local p = A(632 - row * 11, 640 - row * 12, a)
      if HUB:at(p[1], p[2]) < 0.5 and DRUMSIDE:at(p[1], p[2]) < 0.5 then
        tip:reload(WARM, 0.7); tip:touch(p[1], p[2], {pressure=0.45, clip=ARCHSIDE})
      end
    end
  end
end
-- (2) hub: raised ring lips, lit on top, black shadow under; the drum's lit rim; the portal's lit far lip
for _, r in ipairs({{86, 64}, {72, 54}, {58, 43}, {44, 33}, {32, 24}}) do
  local lit, sh = {}, {}
  for k = 0, 48 do
    local a = math.pi * 2 * k / 48
    lit[#lit + 1] = {500 + r[1] * math.cos(a), 236 + r[2] * math.sin(a)}
    sh[#sh + 1] = {500 + (r[1] - 2.5) * math.cos(a) + 1, 236 + (r[2] - 2.5) * math.sin(a) + 2}
  end
  S(B, 0.7, sh, {0.45, 0.45}, HUB)
  S(LIP, 0.7, lit, {0.3, 0.3}, HUB)
end
local dr = {}
for k = 0, 48 do local a = math.pi * 2 * k / 48; dr[#dr + 1] = {500 + 96 * math.cos(a), 236 + 72 * math.sin(a)} end
S(WHT, 0.8, dr, {0.4, 0.4})
local pl = {}
for k = 0, 16 do local a = math.pi * (1.05 + 0.9 * k / 16); pl[#pl + 1] = {500 + 21 * math.cos(a), 226 + 16 * math.sin(a) + 3} end
S(LIPD, 0.7, pl, {0.35, 0.35})
-- (3) left flank: dim foreshortened plate rows; crisp bay rims
local function low(t) return {lerp(-10, 463, t), lerp(560, 286, t)} end
for k = 0, 26 do
  local t = depth(k * 0.6)
  local a, b = edgeL(t), low(t)
  local n = 6
  for j = 0, n - 1 do
    local p0 = {lerp(a[1], b[1], j / n), lerp(a[2], b[2], j / n)}
    local p1 = {lerp(a[1], b[1], (j + 1) / n), lerp(a[2], b[2], (j + 1) / n)}
    local m = {(p0[1] + p1[1]) / 2 + lerp(6, 1, t), (p0[2] + p1[2]) / 2 + lerp(3, 0.5, t)}
    S(B, 0.5, {p0, m, p1}, {lerp(0.35, 0.1, t), lerp(0.35, 0.1, t)}, LFLANK)
    S(LIPD, 0.5, {{p0[1] - 1, p0[2]}, {m[1] - 1, m[2]}, {p1[1] - 1, p1[2]}}, {lerp(0.25, 0.08, t), lerp(0.25, 0.08, t)}, LFLANK)
  end
end
for _, pts in ipairs(BAYS) do
  S(WHT, 0.7, {pts[1], pts[2], pts[3], pts[4], pts[5]}, {0.4, 0.3})
end
-- (4) the walker: helm, pauldrons, pack with plates, legs' backs, all lit; black kept at his sides and between plates
local fx, fy = FOOT[1], FOOT[2]
local s = 1.45
local function P(x, y) return {fx + x * s, fy + y * s} end
local STEEL = pile{{"lead white",2},{"yellow ochre",0.5},{"bone black",0.15}}
local STEELM = pile{{"lead white",1.2},{"yellow ochre",0.7},{"raw sienna",0.4},{"bone black",0.2}}
local CRIM = pile{{"cadmium red",1},{"vermilion",0.6},{"rose madder",0.3}}
local helm = ellipse(fx, fy - 41 * s, 4.6 * s, 5 * s)
local paulL = poly({P(-12, -35), P(-4, -36), P(-4, -30), P(-13, -29)})
local paulR = poly({P(4, -36), P(12, -35), P(13, -29), P(4, -30)})
local pack = poly({P(-7, -28), P(7, -28), P(7, -16), P(-7, -16)})
local legs = ribbon({P(-5, -13), P(-6.5, -6), P(-7.5, 0)}, 3.8 * s) + ribbon({P(5, -13), P(6, -7), P(6, -2)}, 3.8 * s)
local arms = ribbon({P(-14, -27), P(-15.5, -21), P(-15.5, -14)}, 2.8 * s) + ribbon({P(14, -27), P(14.5, -21), P(14.5, -14)}, 2.8 * s)
work(helm + pack, {hand="detail", pile=STEEL, coverage=4, fill=true, angle=1.57, clip=helm + pack, seed=1001})
work(legs + arms + paulL + paulR, {hand="detail", pile=STEELM, coverage=4, fill=true, angle=1.57, clip=legs + arms + paulL + paulR, seed=1002})
local cloth = poly({P(-9, -35), P(9, -35), P(6, -30), P(-1, -27), P(-7, -30)})
work(cloth, {hand="detail", pile=CRIM, coverage=4, fill=true, angle=0, clip=cloth, seed=1003})
local hair = brush{kind="rigger", width=1.4, point=0.9}
local function D(pts) hair:reload(B, 0.8); hair:stroke(pts, {pressure={0.55, 0.55}, ramps={0.05, 0.1}}) end
D({P(-7, -22), P(7, -22)}); D({P(0, -28), P(0, -16)}); D({P(-6, -9), P(-6.6, -8)}); D({P(5, -9), P(5.5, -8)})
D({P(-4, -44), P(4, -44)})
S(WHT, 0.8, {P(-3, -47), P(3, -47)}, {0.5, 0.4})
-- the safety line again, from his belt to the rail
local rp = RAIL[4]
S(WHT, 0.6, {P(-9, -17), {(P(-9, -17)[1] + rp[1]) / 2, (P(-9, -17)[2] + rp[2]) / 2 + 10}, rp}, {0.3, 0.25})
