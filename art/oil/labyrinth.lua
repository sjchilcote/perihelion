-- easel session "labyrinth": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen={16,18}, seed=2323, ground={{pile={{"bone black",1.4},{"ultramarine blue",0.4},{"burnt sienna",0.4},{"lead white",0.25}}, um=140, apply="knife", texture=0.3}}}
C = {500, 500}
BONE = pile{{"lead white",2.5},{"yellow ochre",0.55},{"raw sienna",0.08}}
BRONZE = pile{{"raw sienna",1.4},{"burnt sienna",0.9},{"bone black",0.5},{"yellow ochre",0.3}}
BRD = pile{{"bone black",1.4},{"burnt sienna",0.7},{"raw sienna",0.4}}
GOLD = pile{{"cadmium yellow",1},{"Mars yellow",0.6},{"lead white",0.4}}
VIOL = pile{{"cobalt violet",1},{"magenta",0.4},{"ultramarine blue",0.3},{"lead white",0.3}}
VIOLW = pile{{"zinc white",2},{"cobalt violet",1}}
BLK = pile{{"bone black",2.2}}
RIN, ROUT = 110, 420
PITCH = (ROUT - RIN) / 11
local function F(m, p, s, a) work(m, {hand="body", tool="filbert 7", pile=p, coverage=3.8, fill=true, angle=a or 0, clip=m, seed=s}) end
F(ellipse(C[1], C[2], 458, 458) - ellipse(C[1], C[2], 426, 426), BRONZE, 101, 0.3)
F(ellipse(C[1], C[2], 426, 426) - ellipse(C[1], C[2], 104, 104), BONE, 102, 0.1)
F(ellipse(C[1], C[2], 104, 104), BONE, 103, 0.1)
print(wait(3 * 24 * 60))
F(ellipse(C[1], C[2], 46, 46), GOLD, 104)
print(wait(3 * 24 * 60))

--@ chunk 2
-- the walls: bronze arcs between the eleven circuits, each quadrant's walls shifted outward a little more than the last,
-- so nothing lines up across the seams; turning walls on the axes
local WB = brush{kind="round", width=7.5, point=0.2}
local function seg(a, b) WB:reload(BRONZE, 0.9); WB:stroke({a, b}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}}) end
local function P(r, a) return {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end
local function arc(r, a0, a1) local n = math.max(1, math.floor((a1 - a0) * r / 10)); for k = 0, n - 1 do seg(P(r, lerp(a0, a1, k / n)), P(r, lerp(a0, a1, (k + 1) / n))) end end
QC = {0, math.pi / 2, math.pi, 3 * math.pi / 2}       -- quadrant centres: right, bottom (the entrance), left, top
function wallr(k, q) if k == 0 or k == 11 then return RIN + k * PITCH end; return RIN + k * PITCH + (q - 1) * 6.5 end
for q = 1, 4 do
  local a0, a1 = QC[q] - math.pi / 4 + 0.04, QC[q] + math.pi / 4 - 0.04
  for k = 0, 11 do
    local r = wallr(k, q)
    local gaps = {}
    if k == 11 then if q == 2 then gaps = {QC[q]} end
    elseif k == 0 then if q == 4 then gaps = {QC[q]} end
    else gaps = {QC[q] + (((k + q) % 2 == 0) and 0.42 or -0.42) * (0.6 + 0.4 * ((k * 3 + q) % 3) / 2)} end
    local ga = 13 / r
    local cur = a0
    table.sort(gaps)
    for _, g in ipairs(gaps) do arc(r, cur, g - ga); cur = g + ga end
    arc(r, cur, a1)
  end
  -- turning walls (labryses) on the axis, alternate circuits
  for k = 1, 9, 2 do
    local a = QC[q] + ((q % 2 == 0) and 0.03 or -0.03)
    if not (q == 2 and k >= 9) then seg(P(wallr(k, q), a), P(wallr(k + 1, q), a)) end
  end
end
print(wait(3 * 24 * 60))
-- the four seams: violet bands along the diagonals, where the floor is glued to itself a quarter-turn round
for q = 1, 4 do
  local a = QC[q] + math.pi / 4
  local b = poly({P(102, a - 0.05), P(102, a + 0.05), P(430, a + 0.022), P(430, a - 0.022)})
  work(b, {hand="detail", tool={kind="filbert", width=4}, pile=VIOL, coverage=4.5, fill=true, angle=a, clip=b, seed=200 + q})
end
print(wait(3 * 24 * 60))

--@ chunk 3
-- details on dry paint: the entrance cut through the ring, lunations, the rosette and the Sun's face, the seams' fold-glyphs,
-- the floor's tile joints, and the Commando at the entrance
local function P(r, a) return {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end
local rig = brush{kind="rigger", width=2.2, point=0.8}
local rd = brush{kind="round", width=5, point=0.3}
local function seg(b, p, a, c, pr, clip) b:reload(p, 0.85); b:stroke({a, c}, {pressure=pr or {0.7, 0.7}, ramps={0.03, 0.03}, clip=clip}) end
local function arc(b, p, cx, cy, r, a0, a1, pr) local n = math.max(3, math.floor(math.abs(a1 - a0) * r / 9)); for k = 0, n - 1 do local t0, t1 = lerp(a0, a1, k / n), lerp(a0, a1, (k + 1) / n); seg(b, p, {cx + r * math.cos(t0), cy + r * math.sin(t0)}, {cx + r * math.cos(t1), cy + r * math.sin(t1)}, pr) end end
-- entrance
local slot = poly({{487, 912}, {513, 912}, {513, 962}, {487, 962}})
work(slot, {hand="detail", pile=BONE, coverage=5, fill=true, angle=1.57, clip=slot, seed=301})
-- floor tile joints outside the circle
local outside = -ellipse(C[1], C[2], 462, 462)
local TL = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"burnt sienna",0.3},{"lead white",0.5}}
for x = 0, 1000, 125 do seg(rig, TL, {x, 0}, {x, 1000}, {0.4, 0.4}, outside) end
for y = 0, 1000, 125 do seg(rig, TL, {0, y}, {1000, y}, {0.4, 0.4}, outside) end
-- lunations round the outer ring: dark teeth and bone cusps
for k = 0, 111 do
  local a = 2 * math.pi * k / 112
  if math.abs(a - math.pi / 2) > 0.05 then
    seg(rig, BRD, P(428, a), P(457, a), {0.55, 0.55})
    local t = brush{kind="round", width=4, point=0.4}; t:reload(BONE, 0.9); local p = P(450, a + math.pi / 112); t:touch(p[1], p[2], {pressure=0.7})
  end
end
-- the rosette: six lobes round the Sun, and the Sun's face
for k = 0, 5 do local a = -math.pi / 2 + k * math.pi / 3; local p = P(74, a); arc(rd, BRONZE, p[1], p[2], 26, 0, 2 * math.pi, {0.7, 0.7}) end
arc(rd, BRONZE, C[1], C[2], 50, 0, 2 * math.pi, {0.8, 0.8})
local cx, cy = C[1], C[2]
arc(rig, BLK, cx - 15, cy - 6, 8, 0.15 * math.pi, 0.85 * math.pi); arc(rig, BLK, cx + 15, cy - 6, 8, 0.15 * math.pi, 0.85 * math.pi)
seg(rig, BLK, {cx, cy - 3}, {cx - 3, cy + 11}); seg(rig, BLK, {cx - 3, cy + 11}, {cx + 3, cy + 12})
arc(rig, BLK, cx, cy + 12, 12, 0.25 * math.pi, 0.75 * math.pi)
for k = 0, 11 do local a = 2 * math.pi * k / 12; seg(rig, GOLD, P(49, a), P(60, a), {0.6, 0.2}) end
-- the seams: a bright thread down each, and at its middle a fold-glyph, a square holding a smaller square a quarter-turn round
for q = 1, 4 do
  local a = QC[q] + math.pi / 4
  seg(rig, VIOLW, P(104, a), P(428, a), {0.45, 0.35})
  for _, r in ipairs({200, 330}) do
    local g = P(r, a)
    local function sq(s, rot) local t = {} for i = 0, 4 do local b = rot + math.pi / 4 + i * math.pi / 2; t[#t + 1] = {g[1] + s * math.cos(b), g[2] + s * math.sin(b)} end; return t end
    local m = poly(sq(15, a))
    work(m, {hand="detail", pile=VIOL, coverage=5, fill=true, angle=0, clip=m, seed=310 + q * 3 + r})
    local o, i2 = sq(15, a), sq(9, a + math.pi / 2 + 0.35)
    for i = 1, 4 do seg(rig, VIOLW, o[i], o[i + 1], {0.55, 0.55}); seg(rig, GOLD, i2[i], i2[i + 1], {0.55, 0.55}) end
  end
end
-- the Commando, seen from above, stepping in at the entrance: shoulders, helm, crimson rag, staff
local CR = pile{{"cadmium red",1},{"vermilion",0.5},{"rose madder",0.3}}
local sh = ellipse(500, 942, 10, 6)
work(sh, {hand="detail", pile=BLK, coverage=5, fill=true, angle=0, clip=sh, seed=330})
local rag = poly({{493, 946}, {507, 946}, {509, 958}, {491, 958}})
work(rag, {hand="detail", pile=CR, coverage=5, fill=true, angle=1.57, clip=rag, seed=331})
local t = brush{kind="round", width=7, point=0.4}; t:reload(pile{{"bone black",1},{"ultramarine blue",0.6},{"lead white",0.5}}, 1); t:touch(500, 940, {pressure=0.8})
seg(rig, BLK, {511, 950}, {514, 922}, {0.6, 0.6})
local t2 = brush{kind="round", width=2, point=0.5}; t2:reload(pile{{"zinc white",3},{"cerulean blue",1}}, 1); t2:touch(500, 937, {pressure=0.7})

--@ chunk 4
ROUTE = {{1,2}, {1,3}, {2,3}, {1,4}, {1,5}, {1,6}, {1,7}, {2,7}, {1,8}, {1,9}, {1,10}, {1,11}, {2,11}, {1,12}, {1,13}, {1,14}, {1,15}, {2,15}, {2,14}, {2,13}, {2,12}, {3,11}, {3,10}, {2,10}, {2,9}, {2,8}, {3,7}, {3,6}, {2,6}, {2,5}, {2,4}, {3,3}, {3,2}, {2,2}, {2,1}, {1,1}, {1,0}, {2,0}, {3,15}, {3,14}, {3,13}, {3,12}, {4,11}, {4,10}, {4,9}, {3,9}, {3,8}, {4,7}, {4,6}, {4,5}, {3,5}, {3,4}, {4,3}, {4,2}, {4,1}, {3,1}, {3,0}, {4,15}, {4,14}, {4,13}, {4,12}, {5,11}, {5,10}, {5,9}, {5,8}, {4,8}, {5,7}, {5,6}, {5,5}, {5,4}, {4,4}, {5,3}, {5,2}, {5,1}, {5,0}, {4,0}, {5,15}, {5,14}, {5,13}, {5,12}, {6,11}, {6,10}, {6,9}, {6,8}, {7,7}, {6,7}, {6,6}, {6,5}, {6,4}, {7,3}, {6,3}, {6,2}, {6,1}, {6,0}, {7,15}, {6,15}, {6,14}, {6,13}, {6,12}, {7,11}, {7,10}, {7,9}, {7,8}, {8,7}, {8,6}, {7,6}, {7,5}, {7,4}, {8,3}, {8,2}, {7,2}, {7,1}, {7,0}, {8,15}, {8,14}, {7,14}, {7,13}, {7,12}, {8,11}, {8,10}, {8,9}, {8,8}, {9,7}, {9,6}, {9,5}, {8,5}, {8,4}, {9,3}, {9,2}, {9,1}, {8,1}, {8,0}, {9,15}, {9,14}, {9,13}, {8,13}, {8,12}, {9,11}, {9,10}, {9,9}, {9,8}, {10,7}, {10,6}, {10,5}, {11,5}, {11,4}, {10,4}, {9,4}, {10,3}, {11,3}, {11,2}, {10,2}, {10,1}, {11,1}, {11,0}, {10,0}, {9,0}, {10,15}, {11,15}, {11,14}, {10,14}, {10,13}, {11,13}, {11,12}, {10,12}, {9,12}, {10,11}, {11,11}, {11,10}, {10,10}, {10,9}, {11,9}, {11,8}, {10,8}, {11,7}, {11,6}}
LOOPTO = {11,5}
-- the pass: a real route. The field is repainted and the walls redrawn from ROUTE: a path through every cell of
-- eleven circuits x sixteen sectors, where crossing a violet seam forward lands one circuit further out.
NJ, PQ = 16, 4
function th0(j) return math.pi / 4 + j * math.pi / 8 end
function rout(c) return ROUT - (c - 1) * PITCH end
function rmid(c) return ROUT - (c - 0.5) * PITCH end
local function P(r, a) return {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end
-- field back to bone, over the old walls and seams
local field = ellipse(C[1], C[2], 424, 424) - ellipse(C[1], C[2], 104, 104)
work(field, {hand="body", tool="filbert 7", pile=BONE, coverage=4.5, fill=true, angle=function(x, y) return math.atan(y - C[2], x - C[1]) + 1.57 end, clip=field, seed=401})
-- the old entrance slot and the little figure: bronze again, with their lunation teeth
local old = poly({{482, 905}, {518, 905}, {518, 965}, {482, 965}}) * (ellipse(C[1], C[2], 460, 460) - ellipse(C[1], C[2], 424, 424))
work(old, {hand="detail", pile=BRONZE, coverage=5.5, fill=true, angle=0.3, clip=old, seed=402})
-- the new entrance, in the middle of the sector just left of the bottom axis
ENTA = th0(2) + math.pi / 16
local e0, e1 = ENTA - 0.03, ENTA + 0.03
local slot = poly({P(416, e0), P(416, e1), P(462, e1 + 0.002), P(462, e0 - 0.002)})
work(slot, {hand="detail", pile=BONE, coverage=5.5, fill=true, angle=ENTA, clip=slot, seed=403})
print(#ROUTE, wait(4 * 24 * 60))

--@ chunk 5
-- the walls, derived from the route: a wall wherever two neighbouring cells are not consecutive on it
local function P(r, a) return {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end
local WB = brush{kind="round", width=7, point=0.2}
local function seg(a, b) WB:reload(BRONZE, 0.9); WB:stroke({a, b}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}}) end
local function arc(r, a0, a1) local n = math.max(1, math.floor((a1 - a0) * r / 10)); for k = 0, n - 1 do seg(P(r, lerp(a0, a1, k / n)), P(r, lerp(a0, a1, (k + 1) / n))) end end
EDGE = {}
local function key(a, b) local x, y = a[1] * 100 + a[2], b[1] * 100 + b[2]; if x > y then x, y = y, x end; return x .. ":" .. y end
for i = 1, #ROUTE - 1 do EDGE[key(ROUTE[i], ROUTE[i + 1])] = true end
EDGE[key(ROUTE[#ROUTE], LOOPTO)] = true
local pad = 0.012
for j = 0, NJ - 1 do
  local a0, a1 = th0(j), th0(j + 1)
  local s0 = (j % PQ == 0) and 0.05 or pad       -- keep clear of the seam bands
  local s1 = (j % PQ == PQ - 1) and 0.05 or pad
  -- ring walls between circuit c and c+1 (and the outer wall, c = 0 side)
  for c = 0, 11 do
    local r = ROUT - c * PITCH
    local open = false
    if c == 0 then open = (j == 2)
    elseif c < 11 then open = EDGE[key({c, j}, {c + 1, j})] end
    if not open then
      if c == 0 and j == 2 then else arc(r, a0 + s0 * 0.4, a1 - s1 * 0.4) end
    elseif c == 0 then
      arc(r, a0 + s0 * 0.4, ENTA - 0.04); arc(r, ENTA + 0.04, a1 - s1 * 0.4)
    end
  end
  -- radial walls at the boundary j|j+1, inside a quadrant
  if j % PQ ~= PQ - 1 then
    for c = 1, 11 do
      if not EDGE[key({c, j}, {c, j + 1})] then seg(P(rout(c), a1), P(rout(c) - PITCH, a1)) end
    end
  end
end
print(wait(3 * 24 * 60))
-- the four seams again, over the walls' ends
for q = 0, 3 do
  local a = math.pi / 4 + q * math.pi / 2
  local b = poly({P(102, a - 0.05), P(102, a + 0.05), P(430, a + 0.022), P(430, a - 0.022)})
  work(b, {hand="detail", tool={kind="filbert", width=4}, pile=VIOL, coverage=4.5, fill=true, angle=a, clip=b, seed=500 + q})
end
print(wait(3 * 24 * 60))

--@ chunk 6
-- Ariadne's thread along the route, hopping across the seams; the seam glyphs; the Commando at the new entrance
local function P(r, a) return {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end
local th = brush{kind="rigger", width=2.2, point=0.8}
local TH = pile{{"vermilion",1},{"cadmium red",0.5}}
local function seg(p, a, b, pr) th:reload(p, 0.85); th:stroke({a, b}, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.03}}) end
local function arc(p, r, a0, a1) local n = math.max(1, math.floor(math.abs(a1 - a0) * r / 9)); for k = 0, n - 1 do seg(p, P(r, lerp(a0, a1, k / n)), P(r, lerp(a0, a1, (k + 1) / n))) end end
local function mid(j) return th0(j) + math.pi / 16 end
local function hop(r1, r2, a)
  local n = 4
  for k = 0, n - 1 do if k % 2 == 0 then seg(VIOLW, P(lerp(r1, r2, k / n), a), P(lerp(r1, r2, (k + 1) / n), a), {0.7, 0.7}) end end
  local t = brush{kind="round", width=3, point=0.5}; t:reload(VIOLW, 1); t:touch(P(r2, a)[1], P(r2, a)[2], {pressure=0.7})
end
local function step(a, b)
  local c, j, c2, j2 = a[1], a[2], b[1], b[2]
  if c == c2 then arc(TH, rmid(c), mid(j), mid(j2) + ((j2 - j == -(NJ - 1)) and 2 * math.pi or 0) - ((j2 - j == NJ - 1) and 2 * math.pi or 0))
  elseif j == j2 then seg(TH, P(rmid(c), mid(j)), P(rmid(c2), mid(j)))
  else
    local fwd = ((j + 1) % NJ == j2)
    local s = fwd and th0(j + 1) or th0(j)
    local sa = s
    if fwd and j2 == 0 then sa = th0(NJ) end
    arc(TH, rmid(c), mid(j), sa - (fwd and 0.03 or -0.03))
    hop(rmid(c), rmid(c2), sa)
    local m2 = mid(j2)
    if fwd and j2 == 0 then m2 = m2 + 2 * math.pi end
    if (not fwd) and j == 0 then m2 = m2 - 2 * math.pi end
    arc(TH, rmid(c2), sa + (fwd and 0.03 or -0.03), m2)
  end
end
seg(TH, P(470, ENTA), P(rmid(1), ENTA))
for i = 1, #ROUTE - 1 do step(ROUTE[i], ROUTE[i + 1]) end
step(ROUTE[#ROUTE], LOOPTO)
-- seam glyphs
local rig = brush{kind="rigger", width=2.2, point=0.8}
for q = 0, 3 do
  local a = math.pi / 4 + q * math.pi / 2
  for _, r in ipairs({200, 330}) do
    local g = P(r, a)
    local function sq(s, rot) local t = {} for i = 0, 4 do local b = rot + math.pi / 4 + i * math.pi / 2; t[#t + 1] = {g[1] + s * math.cos(b), g[2] + s * math.sin(b)} end; return t end
    local m = poly(sq(15, a)); work(m, {hand="detail", pile=VIOL, coverage=5, fill=true, angle=0, clip=m, seed=600 + q * 7 + r})
    local o, i2 = sq(15, a), sq(9, a + math.pi / 2 + 0.35)
    for i = 1, 4 do rig:reload(VIOLW, 0.85); rig:stroke({o[i], o[i + 1]}, {pressure={0.55, 0.55}}); rig:reload(GOLD, 0.85); rig:stroke({i2[i], i2[i + 1]}, {pressure={0.55, 0.55}}) end
  end
end
-- the old slot, covered properly, its teeth again
local BR2 = pile{{"raw sienna",1.4},{"burnt sienna",0.9},{"bone black",0.6},{"yellow ochre",0.25}}
local old = poly({{480, 903}, {520, 903}, {520, 968}, {480, 968}}) * (ellipse(C[1], C[2], 460, 460) - ellipse(C[1], C[2], 425, 425))
work(old, {hand="detail", pile=BR2, coverage=6, fill=true, angle=0.3, clip=old, seed=650})
-- the Commando, from above, just inside the new entrance, facing in
local f = P(446, ENTA)
local sh = ellipse(f[1], f[2], 9, 6)
work(sh, {hand="detail", pile=BLK, coverage=5, fill=true, angle=0, clip=sh, seed=660})
local rg = P(456, ENTA)
local rag = ellipse(rg[1], rg[2], 6, 5)
work(rag, {hand="detail", pile=pile{{"cadmium red",1},{"vermilion",0.5}}, coverage=5, fill=true, angle=0, clip=rag, seed=661})
local hd = P(443, ENTA)
local t = brush{kind="round", width=6, point=0.4}; t:reload(pile{{"bone black",1},{"ultramarine blue",0.6},{"lead white",0.5}}, 1); t:touch(hd[1], hd[2], {pressure=0.8})
local op = P(439, ENTA); local t2 = brush{kind="round", width=2, point=0.5}; t2:reload(pile{{"zinc white",3},{"cerulean blue",1}}, 1); t2:touch(op[1], op[2], {pressure=0.7})
print(wait(3 * 24 * 60))
local LB = pile{{"bone black",1.4},{"burnt sienna",0.7},{"raw sienna",0.4}}
for k = 0, 111 do
  local a = 2 * math.pi * k / 112
  local p = P(442, a)
  if math.abs(p[1] - 500) < 22 and p[2] > 900 then
    rig:reload(LB, 0.85); rig:stroke({P(428, a), P(457, a)}, {pressure={0.55, 0.55}})
    local tt = brush{kind="round", width=4, point=0.4}; tt:reload(BONE, 0.9); local q2 = P(450, a + math.pi / 112); tt:touch(q2[1], q2[2], {pressure=0.7})
  end
end

--@ chunk 7
local FLOOR = pile{{"bone black",1.4},{"ultramarine blue",0.4},{"burnt sienna",0.4},{"lead white",0.25}}
local m = rect(478, 950, 44, 22) - ellipse(C[1], C[2], 459, 459)
work(m, {hand="detail", pile=FLOOR, coverage=6, fill=true, angle=0, clip=m, seed=701})
