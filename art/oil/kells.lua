-- easel session "kells": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={18,20}, seed=2121, ground={{pile={{"lead white",2.5},{"yellow ochre",0.3},{"raw sienna",0.05}}, um=160, apply="knife", texture=0.15}}}
RED   = pile{{"vermilion",1},{"red earth",0.6},{"Mars red",0.3}}
GREEN = pile{{"viridian",1},{"yellow ochre",0.5},{"bone black",0.15},{"lead white",0.2}}
BLUE  = pile{{"ultramarine blue",1.3},{"cobalt blue",0.5},{"lead white",0.25}}
GOLDP = pile{{"Mars yellow",1},{"cadmium yellow",0.6},{"yellow ochre",0.6},{"lead white",0.3}}
DARK  = pile{{"bone black",1.4},{"ultramarine blue",0.6},{"Mars red",0.2}}
BONE  = pile{{"lead white",2.5},{"yellow ochre",0.6}}
BLK   = pile{{"bone black",2.2}}
C = {500, 640}
OUTER, INNER = rect(40, 40, 920, 1253), rect(84, 84, 832, 1165)
VARM = rect(430, 84, 140, 1165)
HARM = rect(84, 570, 832, 140)
CROSS = VARM + HARM
QUADS = {
  {rect(84, 84, 346, 486), RED, GOLDP, BLUE},
  {rect(570, 84, 346, 486), BLUE, GOLDP, RED},
  {rect(84, 710, 346, 539), GREEN, BONE, RED},
  {rect(570, 710, 346, 539), RED, GOLDP, GREEN},
}
CORN = {{62, 62}, {938, 62}, {62, 1271}, {938, 1271}}
local function F(m, p, s) work(m, {hand="body", tool="filbert 7", pile=p, coverage=3.8, fill=true, angle=0.05, clip=m, seed=s}) end
F(OUTER - INNER, GOLDP, 101)
F(CROSS - ellipse(C[1], C[2], 130, 130), DARK, 102)
for i, qd in ipairs(QUADS) do F(qd[1] - CROSS, qd[2], 110 + i) end
F(ellipse(C[1], C[2], 130, 130) - ellipse(C[1], C[2], 86, 86), DARK, 120)
F(ellipse(C[1], C[2], 86, 86), GOLDP, 121)
for i, c in ipairs(CORN) do F(rect(c[1] - 34, c[2] - 34, 68, 68), BLUE, 130 + i) end
print(W, H, wait(4 * 24 * 60))

--@ chunk 2
-- the interlace of the four panels: fold-glyphs as black-edged bands, each holding a smaller turned copy, knotted by gluing arcs
BW = brush{kind="round", width=6.5, point=0.2}
BN = brush{kind="round", width=3.4, point=0.2}
function band(p, pts, w)
  for i = 1, #pts - 1 do
    BW:reload(BLK, 0.85); BW:stroke({pts[i], pts[i + 1]}, {pressure={w or 0.8, w or 0.8}, ramps={0.02, 0.02}})
  end
  for i = 1, #pts - 1 do
    BN:reload(p, 0.85); BN:stroke({pts[i], pts[i + 1]}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
  end
end
function glyphpts(cx, cy, n, r, rot) local t = {} for i = 0, n do local a = rot + 2 * math.pi * i / n; t[#t + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end; return t end
function glyph(cx, cy, n, r, rot, turn, p1, p2)
  band(p1, glyphpts(cx, cy, n, r, rot))
  band(p2, glyphpts(cx, cy, n, r * 0.618, rot + turn), 0.7)
end
function glue(p, a, b, bow)
  local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / l * bow, dx / l * bow
  band(p, {a, {lerp(a[1], mx, 0.6) + nx * 0.8, lerp(a[2], my, 0.6) + ny * 0.8}, {mx + nx, my + ny}, {lerp(b[1], mx, 0.6) + nx * 0.8, lerp(b[2], my, 0.6) + ny * 0.8}, b}, 0.7)
end
local qr = {{84, 84, 346, 486}, {570, 84, 346, 486}, {84, 710, 346, 539}, {570, 710, 346, 539}}
local count = 0
for qi, R in ipairs(qr) do
  local p1, p2 = QUADS[qi][3], QUADS[qi][4]
  local s = 62
  local cols = math.floor((R[3] - 10) / s)
  local rows = math.floor((R[4] - 10) / s)
  local ox = R[1] + (R[3] - (cols - 1) * s) / 2
  local oy = R[2] + (R[4] - (rows - 1) * s) / 2
  local r = 21
  local G = {}
  for j = 0, rows - 1 do
    for i = 0, cols - 1 do
      local cx, cy = ox + i * s, oy + j * s
      local n = 3 + ((i + 2 * j + qi) % 4)
      glyph(cx, cy, n, r, (i * 0.7 + j * 1.3), 0.3 + ((i + j) % 5) * 0.35, p1, p2)
      G[j * cols + i] = {cx, cy}
      count = count + 1
    end
  end
  for j = 0, rows - 1 do
    for i = 0, cols - 1 do
      local g = G[j * cols + i]
      if i < cols - 1 then glue(p1, {g[1] + r + 2, g[2]}, {g[1] + s - r - 2, g[2]}, ((i + j) % 2 == 0) and 9 or -9) end
      if j < rows - 1 then glue(p1, {g[1], g[2] + r + 2}, {g[1], g[2] + s - r - 2}, ((i + j) % 2 == 0) and -9 or 9) end
    end
  end
end
print(count)

--@ chunk 3
-- colour laid on the wet black went olive: from here every band is two passes, all the black first, then (dry) all the colour.
PATHS = {}
local function rec(p, pts, w, draw)
  PATHS[#PATHS + 1] = {p = p, pts = pts}
  if draw then for i = 1, #pts - 1 do BW:reload(BLK, 0.85); BW:stroke({pts[i], pts[i + 1]}, {pressure={w or 0.8, w or 0.8}, ramps={0.02, 0.02}}) end end
end
local function gl(cx, cy, n, r, rot, turn, p1, p2, draw) rec(p1, glyphpts(cx, cy, n, r, rot), 0.8, draw); rec(p2, glyphpts(cx, cy, n, r * 0.618, rot + turn), 0.7, draw) end
local function gluepts(a, b, bow)
  local mx, my = (a[1] + b[1]) / 2, (a[2] + b[2]) / 2
  local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy); local nx, ny = -dy / l * bow, dx / l * bow
  return {a, {lerp(a[1], mx, 0.6) + nx * 0.8, lerp(a[2], my, 0.6) + ny * 0.8}, {mx + nx, my + ny}, {lerp(b[1], mx, 0.6) + nx * 0.8, lerp(b[2], my, 0.6) + ny * 0.8}, b}
end
-- the panels again (paths only; their black is on), plus a small diamond knot at every inner grid corner (drawn black now)
local qr = {{84, 84, 346, 486}, {570, 84, 346, 486}, {84, 710, 346, 539}, {570, 710, 346, 539}}
for qi, R in ipairs(qr) do
  local p1, p2 = QUADS[qi][3], QUADS[qi][4]
  local s, r = 62, 21
  local cols, rows = math.floor((R[3] - 10) / s), math.floor((R[4] - 10) / s)
  local ox, oy = R[1] + (R[3] - (cols - 1) * s) / 2, R[2] + (R[4] - (rows - 1) * s) / 2
  for j = 0, rows - 1 do for i = 0, cols - 1 do
    local cx, cy = ox + i * s, oy + j * s
    gl(cx, cy, 3 + ((i + 2 * j + qi) % 4), r, (i * 0.7 + j * 1.3), 0.3 + ((i + j) % 5) * 0.35, p1, p2, false)
    if i < cols - 1 then rec(p1, gluepts({cx + r + 2, cy}, {cx + s - r - 2, cy}, ((i + j) % 2 == 0) and 9 or -9), 0.7, false) end
    if j < rows - 1 then rec(p1, gluepts({cx, cy + r + 2}, {cx, cy + s - r - 2}, ((i + j) % 2 == 0) and -9 or 9), 0.7, false) end
    if i < cols - 1 and j < rows - 1 then rec(p2, glyphpts(cx + s / 2, cy + s / 2, 4, 9, 0), 0.7, true) end
  end end
end
-- the cross: a chain of larger glyphs in gold with red insets, glued end to end
local chain = {}
for y = 120, 1220, 68 do if math.abs(y - C[2]) > 150 then chain[#chain + 1] = {500, y} end end
for x = 124, 880, 68 do if math.abs(x - C[1]) > 150 then chain[#chain + 1] = {x, 640} end end
for k, c in ipairs(chain) do
  gl(c[1], c[2], 3 + (k % 4), 27, k * 0.9, 0.4 + (k % 3) * 0.5, GOLDP, RED, true)
end
for k = 1, #chain - 1 do
  local a, b = chain[k], chain[k + 1]
  if (a[1] == b[1] and math.abs(b[2] - a[2]) < 80) or (a[2] == b[2] and math.abs(b[1] - a[1]) < 80) then
    local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx * dx + dy * dy)
    rec(GOLDP, gluepts({a[1] + dx / l * 29, a[2] + dy / l * 29}, {b[1] - dx / l * 29, b[2] - dy / l * 29}, (k % 2 == 0) and 7 or -7), 0.7, true)
  end
end
-- small glyphs round the Sun in the dark ring
for k = 0, 11 do local a = 2 * math.pi * k / 12; gl(C[1] + 108 * math.cos(a), C[2] + 108 * math.sin(a), 3 + (k % 4), 11, a, 0.6, BONE, RED, true) end
-- the border: a red key pattern
local kp = {}
for x = 96, 904, 16 do kp[#kp + 1] = {x, (math.floor((x - 96) / 16) % 2 == 0) and 50 or 74} end
rec(RED, kp, 0.7, true)
local kp2 = {}
for x = 96, 904, 16 do kp2[#kp2 + 1] = {x, (math.floor((x - 96) / 16) % 2 == 0) and 1259 or 1283} end
rec(RED, kp2, 0.7, true)
for _, xx in ipairs({{50, 74}, {926, 950}}) do
  local kp3 = {}
  for y = 96, 1240, 16 do kp3[#kp3 + 1] = {(math.floor((y - 96) / 16) % 2 == 0) and xx[1] or xx[2], y} end
  rec(RED, kp3, 0.7, true)
end
print(#PATHS, wait(4 * 24 * 60))

--@ chunk 4
-- all the colour, on dry black; the Sun's face and rays; the Wardens biting their tails in the corners
for _, P in ipairs(PATHS) do
  for i = 1, #P.pts - 1 do BN:reload(P.p, 0.85); BN:stroke({P.pts[i], P.pts[i + 1]}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}}) end
end
local rig = brush{kind="rigger", width=2.2, point=0.8}
local function seg(p, a, b, pr) rig:reload(p, 0.85); rig:stroke({a, b}, {pressure=pr or {0.7, 0.7}, ramps={0.03, 0.03}}) end
local function arc(p, cx, cy, r, a0, a1, pr) local n = math.max(3, math.floor(math.abs(a1 - a0) * r / 10)); for k = 0, n - 1 do local t0, t1 = lerp(a0, a1, k / n), lerp(a0, a1, (k + 1) / n); seg(p, {cx + r * math.cos(t0), cy + r * math.sin(t0)}, {cx + r * math.cos(t1), cy + r * math.sin(t1)}, pr) end end
local cx, cy = C[1], C[2]
-- the Sun's calm face and its rays
arc(BLK, cx - 26, cy - 10, 13, 0.15 * math.pi, 0.85 * math.pi); arc(BLK, cx + 26, cy - 10, 13, 0.15 * math.pi, 0.85 * math.pi)
seg(BLK, {cx, cy - 6}, {cx - 4, cy + 18}); seg(BLK, {cx - 4, cy + 18}, {cx + 5, cy + 20})
arc(BLK, cx, cy + 20, 20, 0.25 * math.pi, 0.75 * math.pi)
arc(BLK, cx, cy, 86, 0, 2 * math.pi, {0.8, 0.8})
for k = 0, 23 do local a = 2 * math.pi * (k + 0.5) / 24; seg(GOLDP, {cx + 90 * math.cos(a), cy + 90 * math.sin(a)}, {cx + ((k % 2 == 0) and 126 or 98) * math.cos(a), cy + ((k % 2 == 0) and 126 or 98) * math.sin(a)}, {0.6, 0.15}) end
-- corners: a clean blue ground, then a green Warden curled round, biting its own tail
local BL = pile{{"ultramarine blue",1.3},{"cobalt blue",0.5},{"lead white",0.25}}
for i, c in ipairs(CORN) do
  local sq = rect(c[1] - 34, c[2] - 34, 68, 68)
  work(sq, {hand="detail", tool={kind="filbert", width=4}, pile=BL, coverage=5, fill=true, angle=0, clip=sq, seed=700 + i})
end
print(wait(3 * 24 * 60))
local G2 = pile{{"emerald green",0.8},{"viridian",0.6},{"lead white",0.6}}
for i, c in ipairs(CORN) do
  local a0 = -math.pi / 2 + i * 1.3
  local body = {}
  for k = 0, 16 do local a = a0 + 1.7 * math.pi * k / 16; body[#body + 1] = {c[1] + 20 * math.cos(a), c[2] + 20 * math.sin(a)} end
  for k = 1, #body - 1 do BW:reload(BLK, 0.85); BW:stroke({body[k], body[k + 1]}, {pressure={0.95 - 0.04 * k, 0.95 - 0.04 * k}, ramps={0.02, 0.02}}) end
  -- the head: an angular wedge at the start of the body, jaws closing on the tail's tip
  local h = body[1]
  local ah = a0 - 0.5
  local head = poly({{h[1] + 10 * math.cos(a0 - 1.2), h[2] + 10 * math.sin(a0 - 1.2)}, {h[1] + 16 * math.cos(ah - 0.4), h[2] + 16 * math.sin(ah - 0.4)}, {h[1] + 9 * math.cos(a0 + 1.2), h[2] + 9 * math.sin(a0 + 1.2)}})
  work(head, {hand="detail", pile=G2, coverage=5, fill=true, angle=0, clip=head, seed=720 + i})
  BW:reload(BLK, 0.85); BW:stroke({body[#body], {h[1] + 6 * math.cos(ah - 0.6), h[2] + 6 * math.sin(ah - 0.6)}}, {pressure={0.4, 0.2}, ramps={0.02, 0.4}})
end
print(wait(3 * 24 * 60))
for i, c in ipairs(CORN) do
  local a0 = -math.pi / 2 + i * 1.3
  local body = {}
  for k = 0, 16 do local a = a0 + 1.7 * math.pi * k / 16; body[#body + 1] = {c[1] + 20 * math.cos(a), c[2] + 20 * math.sin(a)} end
  for k = 1, #body - 1 do BN:reload(G2, 0.85); BN:stroke({body[k], body[k + 1]}, {pressure={0.9 - 0.04 * k, 0.9 - 0.04 * k}, ramps={0.02, 0.02}}) end
  for k = 2, #body - 1, 2 do local p = body[k]; local t = brush{kind="round", width=1.6, point=0.5}; t:reload(BLK, 0.8); t:touch(p[1], p[2], {pressure=0.6}) end
  local t = brush{kind="round", width=2.4, point=0.5}; t:reload(RED, 1); t:touch(body[1][1] + 4 * math.cos(a0 - 0.8), body[1][2] + 4 * math.sin(a0 - 0.8), {pressure=0.8})
end

--@ chunk 5
-- the Wardens bigger and angular, filling their corners: a heptagonal body, a wedge head biting the tail
local G2 = pile{{"emerald green",0.8},{"viridian",0.6},{"lead white",0.6}}
local BL = pile{{"ultramarine blue",1.3},{"cobalt blue",0.5},{"lead white",0.25}}
local BWt = brush{kind="round", width=9, point=0.2}
local BNt = brush{kind="round", width=5, point=0.2}
WB = {}
for i, c in ipairs(CORN) do
  local sq = rect(c[1] - 34, c[2] - 34, 68, 68)
  work(sq, {hand="detail", tool={kind="filbert", width=4}, pile=BL, coverage=5, fill=true, angle=0, clip=sq, seed=800 + i})
end
print(wait(3 * 24 * 60))
for i, c in ipairs(CORN) do
  local a0 = -math.pi / 2 + i * 1.3
  local pts = {}
  for k = 0, 6 do local a = a0 + 0.35 + (2 * math.pi - 0.9) * k / 6; pts[#pts + 1] = {c[1] + 23 * math.cos(a), c[2] + 23 * math.sin(a)} end
  WB[i] = {pts = pts, a0 = a0}
  for k = 1, #pts - 1 do BWt:reload(BLK, 0.9); BWt:stroke({pts[k], pts[k + 1]}, {pressure={0.95 - 0.08 * k, 0.95 - 0.08 * k}, ramps={0.02, 0.02}}) end
  local h = pts[1]
  local head = poly({{h[1], h[2]}, {c[1] + 31 * math.cos(a0 + 0.1), c[2] + 31 * math.sin(a0 + 0.1)}, {c[1] + 22 * math.cos(a0 - 0.3), c[2] + 22 * math.sin(a0 - 0.3)}, {c[1] + 14 * math.cos(a0 + 0.1), c[2] + 14 * math.sin(a0 + 0.1)}})
  work(head, {hand="detail", pile=BLK, coverage=5, fill=true, angle=0, clip=head, seed=820 + i})
end
print(wait(3 * 24 * 60))
local tip = brush{kind="round", width=2.6, point=0.5}
for i, c in ipairs(CORN) do
  local pts, a0 = WB[i].pts, WB[i].a0
  for k = 1, #pts - 1 do BNt:reload(G2, 0.9); BNt:stroke({pts[k], pts[k + 1]}, {pressure={0.95 - 0.08 * k, 0.95 - 0.08 * k}, ramps={0.02, 0.02}}) end
  local h = pts[1]
  local head = poly({{h[1], h[2]}, {c[1] + 29 * math.cos(a0 + 0.1), c[2] + 29 * math.sin(a0 + 0.1)}, {c[1] + 22 * math.cos(a0 - 0.22), c[2] + 22 * math.sin(a0 - 0.22)}, {c[1] + 16 * math.cos(a0 + 0.1), c[2] + 16 * math.sin(a0 + 0.1)}})
  work(head, {hand="detail", pile=G2, coverage=5, fill=true, angle=0, clip=head, seed=840 + i})
  tip:reload(RED, 1); tip:touch(c[1] + 24 * math.cos(a0 + 0.12), c[2] + 24 * math.sin(a0 + 0.12), {pressure=0.8})
end
