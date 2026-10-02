-- easel session "fold": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={22,20}, seed=11,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=120, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"raw sienna",1},{"lead white",0.8},{"ultramarine blue",0.4}}, um=40, apply="brush"}}}
print(W, H)

--@ chunk 2
-- geometry
function apts(cx, cy, rx, ry, a0, a1, n) local t = {} for i = 0, n do local a = a0 + (a1 - a0) * i / n; t[#t+1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end return t end
function archpoly(cx, base, hw, spring, ry)
  local t = {{cx - hw, base}}
  for _, p in ipairs(apts(cx, spring, hw, ry, math.pi, 2 * math.pi, 30)) do t[#t+1] = p end
  t[#t+1] = {cx + hw, base}
  return t
end
OPEN = archpoly(500, H + 10, 400, 470, 400)
FCX, FCY, FRX, FRY = 500, 1000, 560, 200
FLOOR = below(function(x) local u = (x - FCX) / FRX; if math.abs(u) >= 1 then return FCY end return FCY - FRY * math.sqrt(1 - u * u) end)
DOORS = {
  {cx = 500, hw = 92, spring = 520, ry = 92},
  {cx = 236, hw = 56, spring = 596, ry = 86},
  {cx = 766, hw = 54, spring = 588, ry = 82},
}
for _, d in ipairs(DOORS) do local u = (d.cx - FCX) / FRX; d.base = FCY - FRY * math.sqrt(1 - u * u) + 4; d.m = poly(archpoly(d.cx, d.base, d.hw, d.spring, d.ry)) end
ND = pile{{"bone black",1},{"ultramarine blue",1},{"bone brown",1}}
WALL = pile{{"bone brown",2},{"raw sienna",1},{"burnt sienna",0.6}}
WALLD = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"ultramarine blue",0.3}}
FL = pile{{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.6},{"ultramarine blue",0.3}}
GL = pile{{"yellow ochre",2},{"lead white",1.5},{"raw sienna",0.5},{"Mars yellow",0.5}}
GLD = pile{{"raw sienna",2},{"yellow ochre",1},{"lead white",0.5},{"burnt sienna",0.3}}
local open = poly(OPEN)
local frame = everywhere() - open
work(frame, {hand="broad", pile=ND, coverage=3, fill=true, clip=frame, angle=math.pi/2})
local doors = DOORS[1].m + DOORS[2].m + DOORS[3].m
local wall = (open - FLOOR) - doors
work(wall * rect(0, 0, 1000, 520), {hand="broad", pile=WALLD, coverage=3, fill=true, clip=wall, angle=math.pi/2})
work(wall * rect(0, 480, 1000, 600), {hand="broad", pile=WALL, coverage=3, fill=true, clip=wall, angle=math.pi/2})
blend(wall * rect(0, 470, 1000, 60), {angle=math.pi/2})
local fl = open * FLOOR
work(fl, {hand="broad", pile=FL, coverage=3, fill=true, clip=fl, angle=0})
for _, d in ipairs(DOORS) do
  work(d.m * rect(0, 0, 1000, d.spring + 60), {hand="body", pile=GL, coverage=3, fill=true, clip=d.m, angle=math.pi/2})
  work(d.m * rect(0, d.spring + 40, 1000, 400), {hand="body", pile=GLD, coverage=3, fill=true, clip=d.m, angle=math.pi/2})
  blend(d.m * rect(0, d.spring + 30, 1000, 40), {angle=math.pi/2})
end

--@ chunk 3
wait(3 * 24 * 60)
print(drying(500, 300), drying(150, 600))
WALLM = pile{{"bone brown",2},{"burnt sienna",0.6},{"raw sienna",0.6},{"bone black",0.35}}
local open = poly(OPEN)
local doors = DOORS[1].m + DOORS[2].m + DOORS[3].m
local wall = (open - FLOOR) - doors:grow(1)
work(wall * rect(0, 380, 1000, 700), {hand="broad", pile=WALLM, coverage=2.6, fill=true, clip=wall, angle=math.pi/2})
work(wall * rect(0, 0, 1000, 400), {hand="broad", pile=WALLD, coverage=2.4, fill=true, clip=wall, angle=math.pi/2})

--@ chunk 4
-- the architecture: door surrounds, cornice ring, the miniature hearts inside the side petals
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.5}}
NDW = pile{{"bone black",1},{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
local b = brush{kind="filbert", width=9}
local r = brush{kind="round", width=2.6, point=0.5}
local h = brush{kind="round", width=1.6, point=0.7}
local function S(br, p, pts, pr) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.1, 0.1}}) end
-- door surrounds: a bronze band outside each arch, lit on the upper left, a dark reveal inside
for i, d in ipairs(DOORS) do
  local out = archpoly(d.cx, d.base, d.hw + 8, d.spring, d.ry + 8)
  local left, right = {}, {}
  for k = 1, 17 do left[#left+1] = out[k] end
  for k = 16, #out do right[#right+1] = out[k] end
  S(b, Q3, left, {0.7, 0.7}); S(b, Q2, right, {0.7, 0.7})
  local lit = {}
  local o2 = archpoly(d.cx, d.base, d.hw + 12, d.spring, d.ry + 12)
  for k = 2, 16 do lit[#lit+1] = o2[k] end
  S(h, Q5, lit, {0.3, 0.7, 0.1})
  local inn = archpoly(d.cx, d.base, d.hw - 2, d.spring, d.ry - 2)
  local ir = {}
  for k = 14, #inn - 1 do ir[#ir+1] = inn[k] end
  S(r, NDW, ir, {0.6, 0.7})
end
-- cornice ring at the spring of the arches: above eye level, so it sags toward the far side
local cor = {}
for i = 0, 30 do local x = lerp(100, 900, i / 30); local u = (x - 500) / 560; cor[#cor+1] = {x, 400 + 70 * math.sqrt(1 - u * u) - 70 + 70} end
local function cornice(dy, br, p, pr) local t = {} for i, q in ipairs(cor) do t[i] = {q[1], q[2] + dy} end
  local seg = 6; local i = 1
  while i < #t do local s = {} for k = i, math.min(#t, i + seg) do s[#s+1] = t[k] end; S(br, p, s, pr); i = i + seg end end
cornice(0, b, Q3, {0.8, 0.8}); cornice(-6, h, Q5, {0.5, 0.5}); cornice(7, r, NDW, {0.6, 0.6})
-- the miniature heart in each side petal: a far arch back into a round lit chamber, a tiny warden inside
for i = 2, 3 do
  local d = DOORS[i]
  local mb = d.base - 28
  local m = poly(archpoly(d.cx + (i == 2 and 3 or -2), mb, d.hw * 0.52, d.spring + 70, d.ry * 0.5))
  work(m, {hand="detail", pile=WALLM, coverage=3, fill=true, clip=m})
  local core = ellipse(d.cx + (i == 2 and 3 or -2), mb - 46, d.hw * 0.36, 34) 
  work(core, {hand="detail", pile=HL, coverage=2, fill=true, clip=core})
  -- tiny warden: halo ring, a column of robe, a spear line
  local fx = d.cx + (i == 2 and 4 or -3)
  local t = brush{kind="round", width=3.2, point=0.4}
  S(t, Q2, {{fx, mb - 52}, {fx, mb - 12}}, {0.8, 0.9})
  local tr = brush{kind="round", width=1.1, point=0.8}
  S(tr, NDW, apts(fx, mb - 56, 6, 6, 0, 2 * math.pi, 12), {0.5, 0.5})
  S(tr, NDW, {{fx - 8, mb - 70}, {fx - 8, mb - 10}}, {0.5, 0.5})
end

--@ chunk 5
local fixm = DOORS[1].m * rect(400, 440, 200, 50)
work(fixm, {hand="detail", pile=GL, coverage=3, fill=true, clip=fixm})
BN = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
R7 = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
MANT = pile{{"ultramarine blue",1},{"bone brown",1.5},{"bone black",0.6},{"cobalt violet",0.2}}
function tube(T, B, w0, w1, P)
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / len, -dx / len
  if nx > 0 then nx, ny = -nx, -ny end
  local function line(off, s0, s1) local t = {} for i = 0, 8 do local s = lerp(s0 or 0.02, s1 or 0.98, i / 8); local w = lerp(w0, w1, s); t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off} end return t end
  local o = {}
  for _, p in ipairs(line(1, 0, 1)) do o[#o+1] = p end
  local bk = line(-1, 0, 1); for i = #bk, 1, -1 do o[#o+1] = bk[i] end
  local m = poly(o, true)
  work(m, {hand="detail", pile=P.base, coverage=3, fill=true, clip=m, angle=math.atan(dy, dx)})
  local b = brush{kind="filbert", width=math.max(1.2, (w0 + w1) * 0.35)}
  if P.lit then b:reload(P.lit, 0.8); b:stroke(line(0.45), {pressure={0.7, 0.5}, clip=m}) end
  if P.dark then b:reload(P.dark, 0.8); b:stroke(line(-0.45), {pressure={0.7, 0.7}, clip=m}) end
  local r = brush{kind="round", width=math.max(0.9, (w0 + w1) * 0.1), point=0.6}
  if P.hi then r:reload(P.hi, 0.7); r:stroke(line(0.65, 0.05, 0.7), {pressure={0.3, 0.8, 0.1}, clip=m}) end
  return m
end
local PL = {base=Q3, lit=Q5, dark=NDW, hi=R7}
local PM = {base=Q2, lit=Q4, dark=NDW, hi=Q5}
-- mantle behind, falling from the shoulders
local mant = poly({{446,650},{554,650},{588,720},{604,860},{612,992},{388,992},{396,860},{412,720}}, true)
work(mant, {hand="body", pile=MANT, coverage=3, fill=true, clip=mant, angle=math.pi/2, tool="filbert 6"})
-- the eleven lames of the skirt, one by one, lit from the upper left
for i = 1, 11 do
  local s = (i - 1) / 10
  local T = {lerp(474, 526, s), 778}
  local B = {lerp(436, 564, s) + 2 * math.sin(i * 2.3), 986 + 4 * math.sin(i * 1.7)}
  tube(T, B, 2.3, 5.4, i <= 4 and PL or PM)
end
-- chest plate: a shield of bronze, the bone lancet down it
local chest = poly({{466,650},{534,650},{540,700},{526,756},{500,776},{474,756},{460,700}}, true)
work(chest, {hand="detail", pile=Q3, coverage=3, fill=true, clip=chest, angle=math.pi/2})
local cl = poly({{466,652},{486,652},{484,720},{490,768},{474,756},{460,700}}, true) * chest
work(cl, {hand="detail", pile=Q5, coverage=2, fill=true, clip=cl, angle=math.pi/2})
local lan = ellipse(500, 708, 7, 38)
work(lan, {hand="detail", pile=BN, coverage=3, fill=true, clip=lan})
local belt = rect(468, 768, 64, 9)
work(belt, {hand="detail", pile=NDW, coverage=3, fill=true, clip=belt})
-- pauldrons
tube({430, 662}, {474, 652}, 15, 13, PL)
tube({526, 652}, {572, 664}, 13, 15, PM)
-- arms: spear arm down to the shaft, the other raised palm-out
tube({438, 676}, {430, 734}, 8, 7, PL); tube({430, 734}, {436, 776}, 7, 6, PL)
tube({566, 676}, {586, 724}, 8, 7, PM); tube({586, 724}, {594, 668}, 7, 6, PM)
local palm = poly({{586,668},{602,668},{604,646},{586,644}}, true)
work(palm, {hand="detail", pile=Q4, coverage=3, fill=true, clip=palm})
local fb = brush{kind="round", width=2.6, point=0.4}
for k, f in ipairs{{588, 644, 586, 622}, {593, 644, 593, 618}, {598, 644, 600, 621}, {603, 648, 607, 628}, {585, 656, 576, 642}} do fb:reload(Q4, 0.7); fb:stroke({{f[1], f[2]}, {f[3], f[4]}}, {pressure={0.8, 0.5}}) end
-- spear: shaft grounded, leaf blade, bone collar
local shaft = rect(432, 500, 5, 500)
work(shaft, {hand="detail", pile=Q3, coverage=3, fill=true, clip=shaft, angle=math.pi/2})
local blade = poly({{434.5,430},{443,470},{440,505},{434.5,515},{429,505},{426,470}}, true)
work(blade, {hand="detail", pile=Q4, coverage=3, fill=true, clip=blade, angle=math.pi/2})
local col = rect(429, 512, 11, 6)
work(col, {hand="detail", pile=BN, coverage=3, fill=true, clip=col})
local fist = ellipse(435, 778, 9, 8)
work(fist, {hand="detail", pile=Q3, coverage=3, fill=true, clip=fist})
-- neck, head, halo
local neck = rect(492, 622, 16, 30)
work(neck, {hand="detail", pile=NDW, coverage=3, fill=true, clip=neck})
local head = ellipse(500, 592, 25, 34)
work(head, {hand="detail", pile=Q4, coverage=3, fill=true, clip=head})
local face = ellipse(500, 598, 14, 22)
work(face, {hand="detail", pile=BN, coverage=3, fill=true, clip=face})
local ring = ellipse(500, 572, 66, 66) - ellipse(500, 572, 54, 54) - head:grow(2) - neck
work(ring, {hand="detail", pile=Q3, coverage=3, fill=true, clip=ring})

--@ chunk 6
FLL = pile{{"raw sienna",1.5},{"bone brown",1},{"burnt sienna",0.5},{"yellow ochre",0.5}}
WARDEN = poly({{446,650},{554,650},{588,720},{604,860},{612,992},{388,992},{396,860},{412,720}}, true) + rect(428, 420, 14, 590)
local pool = (ellipse(500, 1000, 250, 92) * FLOOR) - WARDEN
work(pool, {hand="body", pile=FLL, coverage=2.6, fill=true, clip=pool, angle=0, edge="soft"})
local core = (ellipse(500, 1004, 150, 50) * FLOOR) - WARDEN
work(core, {hand="body", pile=Q4, coverage=2.0, fill=true, clip=core, angle=0, edge="soft"})
wait(3 * 24 * 60)
-- the Fold, inlaid: a heart hexagon, six petals each holding a small copy of the heart, bridged to the heart and to each other
local K = FRY / FRX
local function P(X, Z) return {500 + X, 1000 + Z * K} end
local function hex(cx, cz, r, rot) local t = {} for i = 0, 6 do local a = rot + i * math.pi / 3; t[#t+1] = P(cx + r * math.cos(a), cz + r * math.sin(a)) end return t end
local function vis(pts) -- drop points hidden by the warden; return runs
  local runs, cur = {}, nil
  for _, p in ipairs(pts) do
    if WARDEN:at(p[1], p[2]) < 0.5 and FLOOR:at(p[1], p[2]) > 0.5 then cur = cur or {}; cur[#cur+1] = p
    else if cur and #cur > 1 then runs[#runs+1] = cur end; cur = nil end
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  return runs
end
local function dense(pts, n) local t = {} for i = 1, #pts - 1 do for k = 0, n - 1 do t[#t+1] = {lerp(pts[i][1], pts[i+1][1], k / n), lerp(pts[i][2], pts[i+1][2], k / n)} end end t[#t+1] = pts[#pts]; return t end
local g = brush{kind="round", width=2.6, point=0.5}
local l = brush{kind="round", width=1.6, point=0.6}
local function inlay(pts, lit)
  for _, run in ipairs(vis(dense(pts, 6))) do
    g:reload(NDW, 0.8); g:stroke(run, {pressure={0.6, 0.6}, ramps={0.05, 0.05}})
    l:reload(lit or Q5, 0.8); l:stroke(run, {pressure={0.55, 0.55}, ramps={0.05, 0.05}})
  end
end
inlay(hex(0, 0, 120, 0.05))
inlay(hex(0, 0, 74, 0.05 + 0.3))
local radii = {300, 312, 296, 306, 290, 318}
local cen = {}
for k = 0, 5 do
  local a = math.pi / 2 + k * math.pi / 3 + 0.04 * math.sin(k * 2.7)
  local cx, cz = radii[k+1] * math.cos(a), radii[k+1] * math.sin(a)
  cen[k+1] = {cx, cz}
  local r = 78 + 6 * math.sin(k * 1.9)
  inlay(hex(cx, cz, r, 0.1 * k))
  inlay(hex(cx, cz, r * 0.618, 0.1 * k + 0.05), HL)
end
for k = 1, 6 do
  local c, n = cen[k], cen[k % 6 + 1]
  -- bridge to the heart, bowed
  local d = math.sqrt(c[1]^2 + c[2]^2)
  local s0, s1 = 120 / d, (d - 80) / d
  local bow = {}
  for i = 0, 8 do local s = lerp(s0, s1, i / 8); local off = 18 * math.sin(math.pi * i / 8); bow[#bow+1] = P(c[1] * s - c[2] / d * off, c[2] * s + c[1] / d * off) end
  inlay(bow)
  -- bridge to the neighbour, an arc bowing outward
  local mx, mz = (c[1] + n[1]) / 2, (c[2] + n[2]) / 2
  local md = math.sqrt(mx * mx + mz * mz)
  local arc = {}
  for i = 0, 8 do local s = i / 8; local x = lerp(c[1], n[1], lerp(0.28, 0.72, s)); local z = lerp(c[2], n[2], lerp(0.28, 0.72, s)); local o = 40 * math.sin(math.pi * s); arc[#arc+1] = P(x + mx / md * o, z + mz / md * o) end
  inlay(arc)
end
-- our own route in: a bridge from the threshold under our feet to the front petal
local f = cen[1]
inlay({{500, 1333}, {506, 1250}, {502, 1180}, P(f[1], f[2] + 82)})
-- contact shadow at the hem
local sb = brush{kind="filbert", width=6}
sb:reload(NDW, 0.8); sb:stroke({{392, 994}, {450, 998}, {550, 998}, {610, 994}}, {pressure={0.6, 0.6}})

--@ chunk 7
wait(2 * 24 * 60)
-- soften the pool's rings into the floor
lose(ellipse(500, 1000, 250, 92) * FLOOR - WARDEN, {pile=FLL, where=0.8, reach={14, 10}, load=0.25})
lose(ellipse(500, 1004, 150, 50) * FLOOR - WARDEN, {pile=FLL, where=0.8, reach={10, 8}, load=0.25})
-- wall: scale-plate lips in rows that follow the curve of the room, smaller toward the sides
local wall = (poly(OPEN) - FLOOR) - (DOORS[1].m + DOORS[2].m + DOORS[3].m):grow(14)
local bd = brush{kind="round", width=2.4, point=0.6}
local bl = brush{kind="round", width=1.4, point=0.8}
local n = 0
for row = 0, 11 do
  local h = 390 + row * 34
  for k = -9, 9 do
    local x = 500 + k * 44 + (row % 2) * 22 + 6 * math.sin(row * 3.1 + k * 1.7)
    local u = (x - 500) / 560
    if math.abs(u) < 0.98 then
      local y = h - 30 * (1 - math.sqrt(1 - u * u)) * (1 - row / 14)
      local rad = 14 * math.sqrt(1 - u * u) + 4
      if wall:at(x, y) > 0.9 and wall:at(x, y + 10) > 0.9 then
        if n % 6 == 0 then bd:reload(NDW, 0.7); bl:reload(Q4, 0.6) end
        n = n + 1
        bd:stroke(apts(x, y + 2, rad, 7, math.pi * 0.05, math.pi * 0.95, 8), {pressure={0.1, 0.5, 0.1}, ramps={0.3, 0.3}, clip=wall})
        bl:stroke(apts(x, y, rad, 7, math.pi * 0.55, math.pi * 0.98, 6), {pressure={0.05, 0.5, 0.0}, ramps={0.3, 0.3}, clip=wall})
      end
    end
  end
end
print(n)
-- ribs of the dome, converging upward
local rb = brush{kind="filbert", width=5}
for _, x0 in ipairs{170, 330, 500, 668, 826} do
  rb:reload(Q2, 0.8); rb:stroke({{x0, 380}, {lerp(x0, 500, 0.35), 230}, {lerp(x0, 500, 0.7), 110}}, {pressure={0.7, 0.2}, ramps={0.1, 0.5}})
  bl:reload(Q4, 0.6); bl:stroke({{x0 - 3, 378}, {lerp(x0, 500, 0.35) - 3, 228}}, {pressure={0.5, 0.0}, ramps={0.1, 0.6}})
end
-- the frame of our own doorway: a lit reveal down its inner left edge, a warm bounce on the right
local fr = brush{kind="filbert", width=6}
local edge = archpoly(500, H + 10, 403, 470, 403)
local left = {} for k = 1, 14 do left[#left+1] = edge[k] end
fr:reload(Q3, 0.8); fr:stroke(left, {pressure={0.6, 0.7}})
local right = {} for k = 22, #edge do right[#right+1] = edge[k] end
fr:reload(Q2, 0.8); fr:stroke(right, {pressure={0.6, 0.6}})

--@ chunk 8
wait(2 * 24 * 60)
CZ = pile{{"zinc white",3},{"cerulean blue",1}}
CC = pile{{"cerulean blue",1},{"cobalt violet",1},{"ultramarine ash",1},{"zinc white",1}}
GHM3 = pile{{"ultramarine ash",1},{"bone black",0.5},{"cobalt violet",0.3},{"zinc white",0.3},{"bone brown",0.2}}
MANTL = pile{{"ultramarine ash",1},{"bone brown",1},{"raw sienna",0.4}}
local function S(br, p, pts, pr, rp) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}}) end
local f6 = brush{kind="filbert", width=6}
local f3 = brush{kind="filbert", width=3}
local r2 = brush{kind="round", width=2.0, point=0.6}
local r1 = brush{kind="round", width=1.2, point=0.8}
-- mantle folds: long falling lights and darks
for _, x in ipairs{408, 424, 576, 592} do S(f6, MANTL, {{x + (x < 500 and 12 or -12), 700}, {x + (x < 500 and 4 or -4), 820}, {x - (x < 500 and 6 or -6), 980}}, {0.2, 0.7, 0.3}) end
for _, x in ipairs{416, 584} do S(f3, NDW, {{x + (x < 500 and 12 or -12), 710}, {x, 860}, {x - (x < 500 and 4 or -4), 985}}, {0.3, 0.8, 0.4}) end
-- rim light on the silhouette from the glowing door behind and the light above
S(r2, Q5, {{392, 980}, {398, 860}, {410, 740}, {430, 676}}, {0.0, 0.6, 0.3, 0.0})
S(r2, Q4, {{608, 980}, {602, 860}, {590, 740}, {572, 676}}, {0.0, 0.5, 0.3, 0.0})
S(r2, HL, apts(452, 652, 22, 9, math.pi * 1.1, math.pi * 1.7, 6), {0.1, 0.8, 0.0})
S(r1, Q5, apts(548, 652, 22, 9, math.pi * 1.3, math.pi * 1.9, 6), {0.1, 0.6, 0.0})
-- halo: lit upper left, dark lower right, bone studs by the golden angle
S(f3, Q5, apts(500, 572, 60, 60, math.pi * 0.95, math.pi * 1.6, 12), {0.2, 0.9, 0.2})
S(r1, HL, apts(500, 572, 64, 64, math.pi * 1.05, math.pi * 1.45, 8), {0.0, 0.8, 0.0})
S(f3, NDW, apts(500, 572, 60, 60, math.pi * 0.05, math.pi * 0.55, 8), {0.3, 0.7, 0.3})
local st = brush{kind="round", width=2.2, point=0.2}
for k = 0, 12 do local a = math.pi * 0.62 + k * math.rad(137.5) % (2 * math.pi); local x, y = 500 + 60 * math.cos(a), 572 + 60 * math.sin(a)
  if not (y > 600 and math.abs(x - 500) < 30) then st:reload(BN, 0.6); st:touch(x, y, {pressure=0.6}) end end
-- face: thirteen bronze petals closed round the bone oval; the band slipped sideways with the eye in it
for k = 0, 12 do local a = k * 2 * math.pi / 13 + 0.2; local p1 = {500 + 15 * math.cos(a), 598 + 23 * math.sin(a)}; local p2 = {500 + 24 * math.cos(a), 594 + 33 * math.sin(a)}
  S(r2, (math.cos(a) < 0.2 and math.sin(a) < 0.3) and Q5 or Q2, {p1, p2}, {0.7, 0.2}, {0.05, 0.5}) end
local band = rect(489, 594, 30, 7)
work(band, {hand="detail", pile=BN, coverage=3, fill=true, clip=band})
local eye = ellipse(506, 597.5, 3.2, 3.2)
work(eye, {hand="detail", pile=NDW, coverage=3, fill=true, clip=eye})
S(r1, CZ, {{507, 596.5}, {507.5, 597}}, {0.6, 0.6})
-- chest plate light, the lancet's script
S(f3, HL, {{466, 656}, {466, 690}, {472, 730}, {480, 756}}, {0.3, 0.8, 0.0})
for k = 0, 6 do local y = 680 + k * 9; S(r1, NDW, {{497 + (k % 2) * 2, y}, {502 - (k % 3), y + 4}}, {0.4, 0.4}) end
-- skirt: dark joints, lit edges
for i = 1, 10 do local s = (i - 0.5) / 10
  S(r2, NDW, {{lerp(474, 526, s), 780}, {lerp(436, 564, s), 984}}, {0.6, 0.8}, {0.05, 0.1}) end
for i = 1, 11 do local s = (i - 1) / 10
  S(r1, i <= 5 and HL or Q5, {{lerp(474, 526, s) - 2, 782}, {lerp(436, 564, s) - 5, 960}}, {0.6, 0.0}, {0.05, 0.7}) end
-- spear: lit edge of the shaft and the blade
S(r1, Q5, {{433, 520}, {433, 760}}, {0.5, 0.3}); S(r1, HL, {{430, 470}, {432, 440}}, {0.6, 0.0})
-- the ghost arm, hanging where the real one is raised: flat cold gray, crisp cold double contour
local function gm(dx, dy) local m = ribbon({{570 + dx, 684 + dy}, {580 + dx, 744 + dy}, {584 + dx, 790 + dy}}, {14, 12, 10}) + ellipse(585 + dx, 802 + dy, 8, 11)
  for _, f in ipairs{{-6, 26}, {-3, 30}, {0, 31}, {3, 29}, {6, 25}, {9, 20}} do m = m + ribbon({{585 + dx + f[1] * 0.6, 806 + dy}, {585 + dx + f[1], 802 + f[2] + dy}}, {3.2, 2.2}) end
  return m end
local g = gm(0, 0) - WARDEN:shrink(0) * rect(0, 0, 575, 2000)
work(g, {hand="detail", pile=GHM3, coverage=3, fill=true, clip=g})
local l1 = g:rim(1.1)
work(l1, {hand="detail", pile=CZ, coverage=2.5, fill=true, clip=l1})
local l2 = gm(5, -4):rim(0.9) - g:grow(1.2)
work(l2, {hand="detail", pile=CC, coverage=2, fill=true, clip=l2})

--@ chunk 9
wait(3 * 24 * 60)
print(drying(500, 880), drying(500, 720))
local PL = {base=Q4, lit=Q5, dark=Q2, hi=HL}
local PM = {base=Q3, lit=Q4, dark=NDW, hi=Q5}
for i = 1, 11 do
  local s = (i - 1) / 10
  local T = {lerp(474, 526, s), 780}
  local B = {lerp(436, 564, s) + 2 * math.sin(i * 2.3), 984 + 4 * math.sin(i * 1.7)}
  tube(T, B, 2.2, 5.2, i <= 4 and PL or PM)
end
local chest = poly({{466,652},{534,652},{540,700},{526,756},{500,774},{474,756},{460,700}}, true) - ellipse(500, 708, 8, 39)
work(chest, {hand="detail", pile=Q3, coverage=3, fill=true, clip=chest, angle=math.pi/2})
local cl = poly({{462,654},{484,654},{482,720},{490,770},{474,756},{460,700}}, true) * chest
work(cl, {hand="detail", pile=Q5, coverage=3, fill=true, clip=cl, angle=math.pi/2})
local cr = poly({{522,654},{536,654},{540,700},{526,756},{512,766},{520,700}}, true) * chest
work(cr, {hand="detail", pile=Q2, coverage=3, fill=true, clip=cr, angle=math.pi/2})
tube({438, 676}, {430, 734}, 7.5, 6.5, {base=Q4, lit=Q5, dark=Q2, hi=HL}); tube({430, 734}, {436, 772}, 6.5, 5.5, {base=Q4, lit=Q5, dark=Q2, hi=HL})

--@ chunk 10
wait(3 * 24 * 60)
local function S(br, p, pts, pr, rp) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}}) end
local r2 = brush{kind="round", width=2.2, point=0.6}
local r1 = brush{kind="round", width=1.2, point=0.8}
-- lames: dark joints and lit hairlines
for i = 1, 10 do local s = (i - 0.5) / 10
  S(r2, NDW, {{lerp(474, 526, s), 784}, {lerp(436, 564, s), 980}}, {0.5, 0.8}, {0.05, 0.1}) end
for i = 1, 11 do local s = (i - 1) / 10
  S(r1, i <= 5 and HL or Q5, {{lerp(474, 526, s) - 1.6, 784}, {lerp(436, 564, s) - 4, 950}}, {0.7, 0.0}, {0.05, 0.6}) end
-- chest plate: one clean lit edge, a dark seam where it meets the mantle
S(r1, HL, {{464, 660}, {463, 700}, {470, 740}, {482, 764}}, {0.7, 0.2})
S(r2, NDW, {{538, 660}, {540, 700}, {528, 752}, {502, 776}}, {0.6, 0.6})
-- fist round the shaft
local fist = ellipse(436, 778, 8, 7)
work(fist, {hand="detail", pile=Q4, coverage=3, fill=true, clip=fist})
S(r1, HL, {{430, 774}, {438, 772}}, {0.6, 0.2})
-- the miniature hearts in the side petals: a lit round chamber, a tiny warden with its halo, a spark of a door behind
for i = 2, 3 do
  local d = DOORS[i]
  local mx, my = d.cx + (i == 2 and 3 or -2), d.base - 74
  local ch = ellipse(mx, my, d.hw * 0.36, 34)
  work(ch, {hand="detail", pile=GLD, coverage=3, fill=true, clip=ch})
  local fl = ellipse(mx, my + 22, d.hw * 0.34, 7) * ch
  work(fl, {hand="detail", pile=Q4, coverage=2, fill=true, clip=fl})
  local dd = poly(archpoly(mx, my + 14, 5, my - 6, 6))
  work(dd, {hand="detail", pile=HL, coverage=3, fill=true, clip=dd})
  local t = brush{kind="round", width=3.6, point=0.3}
  S(t, NDW, {{mx, my - 4}, {mx, my + 22}}, {0.9, 0.9}, {0.05, 0.05})
  S(r1, Q2, apts(mx, my - 9, 6, 6, 0, 2 * math.pi, 14), {0.6, 0.6})
  S(r1, NDW, {{mx - 7, my - 18}, {mx - 7, my + 23}}, {0.5, 0.5})
end
-- the inlay restated bolder where the light falls on it
local K = FRY / FRX
local function P(X, Z) return {500 + X, 1000 + Z * K} end
local l = brush{kind="round", width=2.0, point=0.6}
for k = 0, 5 do
  local radii = {300, 312, 296, 306, 290, 318}
  local a = math.pi / 2 + k * math.pi / 3 + 0.04 * math.sin(k * 2.7)
  local cx, cz = radii[k+1] * math.cos(a), radii[k+1] * math.sin(a)
  local r = 78 + 6 * math.sin(k * 1.9)
  local pts = {}
  for i = 0, 6 do local b = 0.1 * k + i * math.pi / 3; pts[#pts+1] = P(cx + r * math.cos(b), cz + r * math.sin(b)) end
  local ok = true
  for _, p in ipairs(pts) do if WARDEN:at(p[1], p[2]) > 0.3 or FLOOR:at(p[1], p[2]) < 0.5 then ok = false end end
  if ok then l:reload(Q5, 0.8); l:stroke(pts, {pressure={0.6, 0.6}, ramps={0.05, 0.05}}) end
end

--@ chunk 11
FRD = pile{{"bone brown",2},{"bone black",1},{"burnt sienna",0.6},{"ultramarine blue",0.2}}
local open = poly(OPEN)
local frame = everywhere() - open:grow(2)
work(frame, {hand="broad", pile=FRD, coverage=2.8, fill=true, clip=frame, angle=math.pi/2})
-- the pool's edge, worked soft into the floor
local ring = ((ellipse(500, 1000, 268, 100) - ellipse(500, 1000, 232, 84)) * FLOOR) - WARDEN
work(ring, {hand="scumble", pile=FL, coverage=1.6, clip=ring, pressure={0.3, 0.6}})
-- the door-glow reflected in the polished floor beneath each door, falling toward us
for _, d in ipairs(DOORS) do
  local refl = poly({{d.cx - d.hw * 0.7, d.base + 4}, {d.cx + d.hw * 0.7, d.base + 4}, {d.cx + d.hw * 0.55, d.base + 120}, {d.cx - d.hw * 0.55, d.base + 120}}) * FLOOR - WARDEN
  work(refl, {hand="body", pile=GLD, coverage=1.2, clip=refl, angle=math.pi/2, pressure={0.2, 0.5}, edge="soft", load=0.5})
end

--@ chunk 12
for _, d in ipairs(DOORS) do
  local refl = poly({{d.cx - d.hw * 0.8, d.base + 2}, {d.cx + d.hw * 0.8, d.base + 2}, {d.cx + d.hw * 0.65, d.base + 130}, {d.cx - d.hw * 0.65, d.base + 130}}) * FLOOR - WARDEN
  blend(refl, {angle=math.pi/2})
end
local ring = ((ellipse(500, 1000, 272, 102) - ellipse(500, 1000, 226, 82)) * FLOOR) - WARDEN:grow(3)
blend(ring, {angle=0})

--@ chunk 13
wait(3 * 24 * 60)
-- reflections redone: floor laid back over the blocks, then a few tapering streaks of the door's glow
for i, d in ipairs(DOORS) do
  local refl = (poly({{d.cx - d.hw * 0.85, d.base + 1}, {d.cx + d.hw * 0.85, d.base + 1}, {d.cx + d.hw * 0.7, d.base + 134}, {d.cx - d.hw * 0.7, d.base + 134}}) * FLOOR) - WARDEN
  work(refl, {hand="body", pile=FL, coverage=3, fill=true, clip=refl, angle=0})
  local s = brush{kind="filbert", width=5}
  for k = -2, 2 do
    local x = d.cx + k * d.hw * 0.22 + 3 * math.sin(k * 2.1 + i)
    local len = 70 + 30 * math.cos(k * 1.3 + i)
    s:reload(k == 0 and Q5 or GLD, 0.6)
    s:stroke({{x, d.base + 4}, {x + 1, d.base + 4 + len * 0.5}, {x, d.base + 4 + len}}, {pressure={0.55, 0.0}, ramps={0.05, 0.9}, clip=refl})
  end
end
-- the reveal of our own doorway: a lit bronze edge on the left, a dark one on the right; frame darkened at its outer edges
local open = poly(OPEN)
local rev = (open:grow(14) - open) * rect(0, 0, 500, H)
work(rev, {hand="detail", pile=Q3, coverage=3, fill=true, clip=rev})
local revr = (open:grow(10) - open) * rect(500, 0, 500, H)
work(revr, {hand="detail", pile=Q2, coverage=3, fill=true, clip=revr})
local outer = everywhere() - open:grow(60)
work(outer, {hand="broad", pile=ND, coverage=2.2, fill=true, clip=outer, angle=math.pi/2, edge="soft"})

--@ chunk 14
wait(2 * 24 * 60)
BEAM = pile{{"lead white",3},{"Mars orange",0.3}}
local beam = poly({{450, 40}, {550, 40}, {650, 1000}, {350, 1000}}) * poly(OPEN)
work(beam, {hand="glaze", pile=BEAM, coverage=1.0, clip=beam, load=0.22, pressure={0.1, 0.22}, angle=math.pi/2})
blend(beam, {angle=math.pi/2})

--@ chunk 15
-- lift the overloaded beam off the figure with a clean brush, wiped after every pass
local beam = poly({{450, 40}, {550, 40}, {650, 1000}, {350, 1000}}) * poly(OPEN)
local b = brush{kind="flat", width=10, pickup=1}
local n = 0
for x = 352, 648, 6 do
  for y0 = 40, 960, 80 do
    b:wipe(1)
    b:stroke({{x, y0}, {x, y0 + 90}}, {pressure={0.5, 0.5}, ramps={0.05, 0.05}, clip=beam})
    n = n + 1
  end
end
print(n)

--@ chunk 16
wait(3 * 24 * 60)
print(drying(500, 300), drying(480, 900))
local beam = poly({{450, 40}, {550, 40}, {650, 1000}, {350, 1000}}) * poly(OPEN)
-- the centre door behind the figure, re-laid
local fig = WARDEN + ellipse(500, 572, 67, 67) + rect(560, 610, 60, 200)
local dm = (DOORS[1].m * beam) - fig
work(dm * rect(0, 0, 1000, 600), {hand="detail", pile=GL, coverage=3, fill=true, clip=dm, angle=math.pi/2})
work(dm * rect(0, 590, 1000, 400), {hand="detail", pile=GLD, coverage=3, fill=true, clip=dm, angle=math.pi/2})
-- the figure again, opaque
local mant = poly({{446,650},{554,650},{588,720},{604,860},{612,992},{388,992},{396,860},{412,720}}, true)
work(mant, {hand="body", pile=MANT, coverage=3, fill=true, clip=mant, angle=math.pi/2, tool="filbert 6"})
local PL = {base=Q4, lit=Q5, dark=Q2, hi=HL}
local PM = {base=Q3, lit=Q4, dark=NDW, hi=Q5}
for i = 1, 11 do
  local s = (i - 1) / 10
  tube({lerp(474, 526, s), 780}, {lerp(436, 564, s) + 2 * math.sin(i * 2.3), 984 + 4 * math.sin(i * 1.7)}, 2.2, 5.2, i <= 4 and PL or PM)
end
local chest = poly({{466,652},{534,652},{540,700},{526,756},{500,774},{474,756},{460,700}}, true) - ellipse(500, 708, 8, 39)
work(chest, {hand="detail", pile=Q3, coverage=3, fill=true, clip=chest, angle=math.pi/2})
local cl = poly({{462,654},{484,654},{482,720},{490,770},{474,756},{460,700}}, true) * chest
work(cl, {hand="detail", pile=Q5, coverage=3, fill=true, clip=cl, angle=math.pi/2})
local cr = poly({{522,654},{536,654},{540,700},{526,756},{512,766},{520,700}}, true) * chest
work(cr, {hand="detail", pile=Q2, coverage=3, fill=true, clip=cr, angle=math.pi/2})
local lan = ellipse(500, 708, 7, 38)
work(lan, {hand="detail", pile=BN, coverage=3, fill=true, clip=lan})
local belt = rect(468, 768, 64, 10)
work(belt, {hand="detail", pile=NDW, coverage=3, fill=true, clip=belt})
tube({430, 662}, {474, 652}, 15, 13, PL)
tube({526, 652}, {572, 664}, 13, 15, PM)
tube({438, 676}, {430, 734}, 7.5, 6.5, PL); tube({430, 734}, {436, 772}, 6.5, 5.5, PL)
tube({566, 676}, {586, 724}, 8, 7, PM); tube({586, 724}, {594, 668}, 7, 6, PM)
local palm = poly({{586,668},{602,668},{604,646},{586,644}}, true)
work(palm, {hand="detail", pile=Q4, coverage=3, fill=true, clip=palm})
local fb = brush{kind="round", width=2.6, point=0.4}
for k, f in ipairs{{588, 644, 586, 622}, {593, 644, 593, 618}, {598, 644, 600, 621}, {603, 648, 607, 628}, {585, 656, 576, 642}} do fb:reload(Q4, 0.7); fb:stroke({{f[1], f[2]}, {f[3], f[4]}}, {pressure={0.8, 0.5}}) end
local shaft = rect(432, 500, 5, 500)
work(shaft, {hand="detail", pile=Q3, coverage=3, fill=true, clip=shaft, angle=math.pi/2})
local blade = poly({{434.5,430},{443,470},{440,505},{434.5,515},{429,505},{426,470}}, true)
work(blade, {hand="detail", pile=Q4, coverage=3, fill=true, clip=blade, angle=math.pi/2})
local col = rect(429, 512, 11, 6)
work(col, {hand="detail", pile=BN, coverage=3, fill=true, clip=col})
local fist = ellipse(436, 778, 8, 7)
work(fist, {hand="detail", pile=Q4, coverage=3, fill=true, clip=fist})
local neck = rect(492, 622, 16, 30)
work(neck, {hand="detail", pile=NDW, coverage=3, fill=true, clip=neck})
local head = ellipse(500, 592, 25, 34)
work(head, {hand="detail", pile=Q4, coverage=3, fill=true, clip=head})
local face = ellipse(500, 598, 14, 22)
work(face, {hand="detail", pile=BN, coverage=3, fill=true, clip=face})
local ring = ellipse(500, 572, 66, 66) - ellipse(500, 572, 54, 54) - head:grow(2) - neck
work(ring, {hand="detail", pile=Q3, coverage=3, fill=true, clip=ring})

--@ chunk 17
wait(3 * 24 * 60)
local PL = {base=Q4, lit=Q5, dark=Q2, hi=HL}
local PM = {base=Q3, lit=Q4, dark=NDW, hi=Q5}
for i = 1, 11 do
  local s = (i - 1) / 10
  tube({lerp(474, 526, s), 780}, {lerp(436, 564, s) + 2 * math.sin(i * 2.3), 984 + 4 * math.sin(i * 1.7)}, 2.2, 5.2, i <= 4 and PL or PM)
end
CZ = pile{{"zinc white",3},{"cerulean blue",1}}
CC = pile{{"cerulean blue",1},{"cobalt violet",1},{"ultramarine ash",1},{"zinc white",1}}
GHM3 = pile{{"ultramarine ash",1},{"bone black",0.5},{"cobalt violet",0.3},{"zinc white",0.3},{"bone brown",0.2}}
MANTL = pile{{"ultramarine ash",1},{"bone brown",1},{"raw sienna",0.4}}
local function S(br, p, pts, pr, rp) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}}) end
local f6 = brush{kind="filbert", width=6}
local f3 = brush{kind="filbert", width=3}
local r2 = brush{kind="round", width=2.0, point=0.6}
local r1 = brush{kind="round", width=1.2, point=0.8}
-- mantle folds: long falling lights and darks
for _, x in ipairs{408, 424, 576, 592} do S(f6, MANTL, {{x + (x < 500 and 12 or -12), 700}, {x + (x < 500 and 4 or -4), 820}, {x - (x < 500 and 6 or -6), 980}}, {0.2, 0.7, 0.3}) end
for _, x in ipairs{416, 584} do S(f3, NDW, {{x + (x < 500 and 12 or -12), 710}, {x, 860}, {x - (x < 500 and 4 or -4), 985}}, {0.3, 0.8, 0.4}) end
-- rim light on the silhouette from the glowing door behind and the light above
S(r2, Q5, {{392, 980}, {398, 860}, {410, 740}, {430, 676}}, {0.0, 0.6, 0.3, 0.0})
S(r2, Q4, {{608, 980}, {602, 860}, {590, 740}, {572, 676}}, {0.0, 0.5, 0.3, 0.0})
S(r2, HL, apts(452, 652, 22, 9, math.pi * 1.1, math.pi * 1.7, 6), {0.1, 0.8, 0.0})
S(r1, Q5, apts(548, 652, 22, 9, math.pi * 1.3, math.pi * 1.9, 6), {0.1, 0.6, 0.0})
-- halo: lit upper left, dark lower right, bone studs by the golden angle
S(f3, Q5, apts(500, 572, 60, 60, math.pi * 0.95, math.pi * 1.6, 12), {0.2, 0.9, 0.2})
S(r1, HL, apts(500, 572, 64, 64, math.pi * 1.05, math.pi * 1.45, 8), {0.0, 0.8, 0.0})
S(f3, NDW, apts(500, 572, 60, 60, math.pi * 0.05, math.pi * 0.55, 8), {0.3, 0.7, 0.3})
local st = brush{kind="round", width=2.2, point=0.2}
for k = 0, 12 do local a = math.pi * 0.62 + k * math.rad(137.5) % (2 * math.pi); local x, y = 500 + 60 * math.cos(a), 572 + 60 * math.sin(a)
  if not (y > 600 and math.abs(x - 500) < 30) then st:reload(BN, 0.6); st:touch(x, y, {pressure=0.6}) end end
-- face: thirteen bronze petals closed round the bone oval; the band slipped sideways with the eye in it
for k = 0, 12 do local a = k * 2 * math.pi / 13 + 0.2; local p1 = {500 + 15 * math.cos(a), 598 + 23 * math.sin(a)}; local p2 = {500 + 24 * math.cos(a), 594 + 33 * math.sin(a)}
  S(r2, (math.cos(a) < 0.2 and math.sin(a) < 0.3) and Q5 or Q2, {p1, p2}, {0.7, 0.2}, {0.05, 0.5}) end
local band = rect(489, 594, 30, 7)
work(band, {hand="detail", pile=BN, coverage=3, fill=true, clip=band})
local eye = ellipse(506, 597.5, 3.2, 3.2)
work(eye, {hand="detail", pile=NDW, coverage=3, fill=true, clip=eye})
S(r1, CZ, {{507, 596.5}, {507.5, 597}}, {0.6, 0.6})
-- chest plate light, the lancet's script
S(f3, HL, {{466, 656}, {466, 690}, {472, 730}, {480, 756}}, {0.3, 0.8, 0.0})
for k = 0, 6 do local y = 680 + k * 9; S(r1, NDW, {{497 + (k % 2) * 2, y}, {502 - (k % 3), y + 4}}, {0.4, 0.4}) end
-- skirt: dark joints, lit edges
for i = 1, 10 do local s = (i - 0.5) / 10
  S(r2, NDW, {{lerp(474, 526, s), 780}, {lerp(436, 564, s), 984}}, {0.6, 0.8}, {0.05, 0.1}) end
for i = 1, 11 do local s = (i - 1) / 10
  S(r1, i <= 5 and HL or Q5, {{lerp(474, 526, s) - 2, 782}, {lerp(436, 564, s) - 5, 960}}, {0.6, 0.0}, {0.05, 0.7}) end
-- spear: lit edge of the shaft and the blade
S(r1, Q5, {{433, 520}, {433, 760}}, {0.5, 0.3}); S(r1, HL, {{430, 470}, {432, 440}}, {0.6, 0.0})
-- the ghost arm, hanging where the real one is raised: flat cold gray, crisp cold double contour
local function gm(dx, dy) local m = ribbon({{570 + dx, 684 + dy}, {580 + dx, 744 + dy}, {584 + dx, 790 + dy}}, {14, 12, 10}) + ellipse(585 + dx, 802 + dy, 8, 11)
  for _, f in ipairs{{-6, 26}, {-3, 30}, {0, 31}, {3, 29}, {6, 25}, {9, 20}} do m = m + ribbon({{585 + dx + f[1] * 0.6, 806 + dy}, {585 + dx + f[1], 802 + f[2] + dy}}, {3.2, 2.2}) end
  return m end
local g = gm(0, 0) - WARDEN:shrink(0) * rect(0, 0, 575, 2000)
work(g, {hand="detail", pile=GHM3, coverage=3, fill=true, clip=g})
local l1 = g:rim(1.1)
work(l1, {hand="detail", pile=CZ, coverage=2.5, fill=true, clip=l1})
local l2 = gm(5, -4):rim(0.9) - g:grow(1.2)
work(l2, {hand="detail", pile=CC, coverage=2, fill=true, clip=l2})
wait(3 * 24 * 60)
local function S(br, p, pts, pr, rp) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}}) end
-- lames: dark joints and lit hairlines
for i = 1, 10 do local s = (i - 0.5) / 10
  S(r2, NDW, {{lerp(474, 526, s), 784}, {lerp(436, 564, s), 980}}, {0.5, 0.8}, {0.05, 0.1}) end
for i = 1, 11 do local s = (i - 1) / 10
  S(r1, i <= 5 and HL or Q5, {{lerp(474, 526, s) - 1.6, 784}, {lerp(436, 564, s) - 4, 950}}, {0.7, 0.0}, {0.05, 0.6}) end
-- chest plate: one clean lit edge, a dark seam where it meets the mantle
S(r1, HL, {{464, 660}, {463, 700}, {470, 740}, {482, 764}}, {0.7, 0.2})
S(r2, NDW, {{538, 660}, {540, 700}, {528, 752}, {502, 776}}, {0.6, 0.6})
-- fist round the shaft
local fist = ellipse(436, 778, 8, 7)
work(fist, {hand="detail", pile=Q4, coverage=3, fill=true, clip=fist})
S(r1, HL, {{430, 774}, {438, 772}}, {0.6, 0.2})

--@ chunk 18
local beam = (poly({{440, 36}, {560, 36}, {662, 1004}, {338, 1004}}) * poly(OPEN)):grow(2)
local fig = WARDEN:grow(2) + ellipse(500, 572, 68, 68) + rect(560, 610, 60, 210) + ellipse(436, 778, 10, 9)
local walls = poly(OPEN) - FLOOR - DOORS[1].m:grow(6) - DOORS[2].m:grow(6) - DOORS[3].m:grow(6)
local dome = beam * walls * rect(0, 0, 1000, 330) - fig
work(dome, {hand="body", pile=WALLD, coverage=3, fill=true, clip=dome, angle=math.pi/2})
local wl = beam * walls * rect(0, 326, 1000, 600) - fig
work(wl, {hand="body", pile=WALLM, coverage=3, fill=true, clip=wl, angle=math.pi/2})
local pool = ellipse(500, 1000, 236, 86)
local fp = (beam * FLOOR * pool) - fig
work(fp, {hand="body", pile=FLL, coverage=3, fill=true, clip=fp, angle=0})
local fo = (beam * FLOOR - pool) - fig
work(fo, {hand="body", pile=FL, coverage=3, fill=true, clip=fo, angle=0})
-- the inside of the centre door where it shows beside the figure
local dm = DOORS[1].m:shrink(1) * beam - fig
work(dm * rect(0, 0, 1000, 600), {hand="detail", pile=GL, coverage=3, fill=true, clip=dm, angle=math.pi/2})
work(dm * rect(0, 590, 1000, 400), {hand="detail", pile=GLD, coverage=3, fill=true, clip=dm, angle=math.pi/2})

--@ chunk 19
wait(2 * 24 * 60)
local beam = (poly({{440, 36}, {560, 36}, {662, 1004}, {338, 1004}}) * poly(OPEN)):grow(4)
local walls = poly(OPEN) - FLOOR - DOORS[1].m:grow(6) - DOORS[2].m:grow(6) - DOORS[3].m:grow(6)
local box = beam * walls * rect(0, 290, 1000, 118) - (WARDEN:grow(2) + ellipse(500, 572, 68, 68))
work(box, {hand="body", pile=WALLD, coverage=3, fill=true, clip=box, angle=math.pi/2, edge="soft"})
local arms = ribbon({{566, 676}, {586, 724}, {594, 668}}, {20, 18, 16}) + poly({{582,672},{608,672},{612,612},{580,612}}) + ribbon({{570, 684}, {580, 744}, {584, 790}}, {22, 20, 18}) + ellipse(587, 805, 14, 40)
local side = beam * walls * rect(590, 590, 60, 260) - arms - WARDEN:grow(2)
work(side, {hand="detail", pile=WALLM, coverage=3, fill=true, clip=side, angle=math.pi/2})
local din = DOORS[1].m:shrink(1) * rect(548, 590, 50, 260) - arms - WARDEN:grow(2)
work(din * rect(0, 0, 1000, 600), {hand="detail", pile=GL, coverage=3, fill=true, clip=din})
work(din * rect(0, 590, 1000, 400), {hand="detail", pile=GLD, coverage=3, fill=true, clip=din})

--@ chunk 20
local head = ellipse(500, 592, 26, 35)
local inner = (ellipse(500, 572, 53, 53) - head - rect(490, 620, 20, 40)) * DOORS[1].m
work(inner * rect(0, 0, 1000, 600), {hand="detail", pile=GL, coverage=3, fill=true, clip=inner})
work(inner * rect(0, 596, 1000, 100), {hand="detail", pile=GLD, coverage=3, fill=true, clip=inner})
-- centre door's surround, restated where the lifting took it
local d = DOORS[1]
local b = brush{kind="filbert", width=9}
local h = brush{kind="round", width=1.6, point=0.7}
local out = archpoly(d.cx, d.base, d.hw + 8, d.spring, d.ry + 8)
local seg = {} for k = 6, 28 do seg[#seg+1] = out[k] end
b:reload(Q3, 0.85); b:stroke(seg, {pressure={0.7, 0.7}, ramps={0.1, 0.1}})
local o2 = archpoly(d.cx, d.base, d.hw + 12, d.spring, d.ry + 12)
local lit = {} for k = 6, 18 do lit[#lit+1] = o2[k] end
h:reload(Q5, 0.8); h:stroke(lit, {pressure={0.3, 0.7, 0.1}, ramps={0.1, 0.1}})
-- left side of the door surround, the stretch the beam covered
local lf = {} for k = 1, 8 do lf[#lf+1] = out[k] end
b:reload(Q3, 0.85); b:stroke({{d.cx - d.hw - 8, d.spring}, {d.cx - d.hw - 8, d.spring + 60}}, {pressure={0.7, 0.7}})
b:reload(Q2, 0.85); b:stroke({{d.cx + d.hw + 8, d.spring}, {d.cx + d.hw + 8, d.spring + 40}}, {pressure={0.7, 0.7}})

--@ chunk 21
local d = DOORS[1]
-- inner edge of the centre door, clean glow against the surround
local e = archpoly(d.cx, d.base, d.hw - 3, d.spring, d.ry - 3)
local g = brush{kind="round", width=5, point=0.3}
local run = {} for k = 2, 31 do run[#run+1] = e[k] end
for i = 1, #run - 5, 5 do local s = {} for k = i, math.min(#run, i + 5) do s[#s+1] = run[k] end; g:reload(GL, 0.8); g:stroke(s, {pressure={0.7, 0.7}, ramps={0.05, 0.05}}) end
g:reload(GLD, 0.8); g:stroke({{d.cx - d.hw + 3, d.spring}, {d.cx - d.hw + 3, d.spring + 180}}, {pressure={0.7, 0.7}})
g:reload(GLD, 0.8); g:stroke({{d.cx + d.hw - 3, d.spring}, {d.cx + d.hw - 3, d.spring + 180}}, {pressure={0.7, 0.7}})
-- the halo's lower right restored
local f = brush{kind="filbert", width=10}
f:reload(Q3, 0.85); f:stroke(apts(500, 572, 60, 60, math.rad(-20), math.rad(70), 10), {pressure={0.7, 0.7}, ramps={0.1, 0.1}})
local r = brush{kind="round", width=2.4, point=0.5}
r:reload(NDW, 0.8); r:stroke(apts(500, 572, 63, 63, math.rad(-10), math.rad(75), 10), {pressure={0.6, 0.6}})

--@ chunk 22
local d = DOORS[1]
local e = archpoly(d.cx, d.base, d.hw + 3, d.spring, d.ry + 3)
local b = brush{kind="filbert", width=7}
local run = {} for k = 2, 31 do run[#run+1] = e[k] end
for i = 1, #run - 4, 4 do local s = {} for k = i, math.min(#run, i + 4) do s[#s+1] = run[k] end; b:reload(k == nil and (i < 16 and Q3 or Q2), 0.85); b:stroke(s, {pressure={0.6, 0.6}, ramps={0.05, 0.05}}) end
b:reload(Q3, 0.85); b:stroke({{d.cx - d.hw - 3, d.spring}, {d.cx - d.hw - 3, d.spring + 200}}, {pressure={0.6, 0.6}})
b:reload(Q2, 0.85); b:stroke({{d.cx + d.hw + 3, d.spring}, {d.cx + d.hw + 3, d.spring + 200}}, {pressure={0.6, 0.6}})
local h = brush{kind="round", width=1.4, point=0.7}
local o = archpoly(d.cx, d.base, d.hw + 1, d.spring, d.ry + 1)
local l = {} for k = 8, 20 do l[#l+1] = o[k] end
h:reload(HL, 0.7); h:stroke(l, {pressure={0.1, 0.6, 0.0}, ramps={0.2, 0.3}})

--@ chunk 23
wait(2 * 24 * 60)
-- one sector of the halo has broken out and floats displaced, lit from the wrong side
local sec = {}
for _, p in ipairs(apts(536, 538, 66, 66, math.rad(-62), math.rad(-28), 8)) do sec[#sec+1] = p end
local inn = apts(536, 538, 54, 54, math.rad(-28), math.rad(-62), 8)
for _, p in ipairs(inn) do sec[#sec+1] = p end
local sm = poly(sec)
work(sm, {hand="detail", pile=Q2, coverage=3, fill=true, clip=sm})
local r = brush{kind="round", width=1.3, point=0.7}
r:reload(CZ, 0.7); r:stroke(apts(536, 538, 65, 65, math.rad(-58), math.rad(-30), 6), {pressure={0.1, 0.6, 0.1}})
r:reload(CC, 0.6); r:stroke(apts(540, 534, 69, 69, math.rad(-56), math.rad(-34), 6), {pressure={0.0, 0.4, 0.0}})
local gap = brush{kind="filbert", width=9}
gap:reload(NDW, 0.8); gap:stroke(apts(500, 572, 60, 60, math.rad(-60), math.rad(-30), 6), {pressure={0.7, 0.7}, ramps={0.05, 0.05}})
-- notches on our bridge, spaced by golden gaps
local t = brush{kind="round", width=2.0, point=0.5}
local y = 1300
for k = 1, 5 do t:reload(Q5, 0.7); t:stroke({{494, y}, {512, y - 1}}, {pressure={0.6, 0.5}}); y = y - 40 * (0.618 ^ (k - 1)) - 8 end
-- polish on the near floor: long soft sheens catching the door glow
local s = brush{kind="filbert", width=10}
for _, l in ipairs{{150, 1150, 380, 1158}, {620, 1170, 850, 1162}, {200, 1250, 420, 1262}, {580, 1270, 800, 1258}, {300, 1110, 460, 1116}} do
  s:reload(FLL, 0.4); s:stroke({{l[1], l[2]}, {l[3], l[4]}}, {pressure={0.0, 0.25, 0.0}, ramps={0.4, 0.4}})
end
