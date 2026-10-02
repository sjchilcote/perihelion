-- easel session "cuculus_dock": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.4, linen={16,18}, seed=3131, ground={{pile={{"bone black",1.6},{"burnt sienna",0.6},{"bone brown",0.4}}, um=140, apply="knife", texture=0.3}}}
function horizon(x) return 150 + 0.00028 * (x - 420)^2 end
HULL = below(function(x) return horizon(x) end)
SKY = -HULL
E = {470, 470}                       -- where the drill is buried
R = {960, 70}                         -- the lander's tail, upper right
local dx, dy = R[1] - E[1], R[2] - E[2]
LL = math.sqrt(dx * dx + dy * dy)
AX = {dx / LL, dy / LL}
NX = {-AX[2], AX[1]}                  -- perpendicular, pointing down-right
function L(s, t) return {E[1] + AX[1] * s + NX[1] * t, E[2] + AX[2] * s + NX[2] * t} end   -- s along the body, t across
print(W, H, LL)

--@ chunk 2
-- value first: black sky; the hull a mid-dark bronze ground; then the plates, row by row from the far edge forward
-- so each nearer row's rounded lips overlap the row beyond
local BLK = pile{{"bone black",2},{"ultramarine blue",0.2}}
local HB  = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.9}}
work(SKY, {hand="body", tool="filbert 8", pile=BLK, coverage=2.5, fill=true, angle=0.1, clip=SKY, seed=201})
work(HULL, {hand="body", tool="filbert 8", pile=HB, coverage=2.6, fill=true, angle=0, clip=HULL, seed=202})
P_LIT  = pile{{"yellow ochre",2},{"raw sienna",0.8},{"lead white",0.9},{"cadmium yellow",0.2}}
P_MID  = pile{{"raw sienna",2},{"burnt sienna",0.8},{"yellow ochre",0.6},{"bone black",0.3}}
P_DARK = pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.6}}
PLATES = {}
local y = 150
local row = 0
while y < 740 do
  local k = (y - 150) / 560                -- 0 far .. 1 near
  local h = lerp(9, 70, k)
  local w = lerp(22, 120, k)
  local x = -w + ((row * 0.618) % 1) * w
  while x < 1000 + w do
    local top = math.max(y, horizon(x + w / 2))
    if top < 740 then
      local pts = {{x, top}, {x + w, top}, {x + w, top + h * 0.45}}
      for j = 1, 9 do local a = math.pi * j / 10; pts[#pts + 1] = {x + w / 2 + w / 2 * math.cos(a), top + h * 0.45 + h * 0.55 * math.sin(a)} end
      pts[#pts + 1] = {x, top + h * 0.45}
      PLATES[#PLATES + 1] = {pts = pts, x = x, y = top, w = w, h = h}
    end
    x = x + w
  end
  y = y + h * 0.62
  row = row + 1
end
-- paint far rows first so near rows overlap
for i, p in ipairs(PLATES) do
  local d = math.sqrt((p.x + p.w / 2 - E[1])^2 + ((p.y + p.h / 2 - E[2]) * 1.6)^2)
  if d > 75 then
    local q = poly(p.pts) * HULL
    local u = rand(0, 1)
    local pl = (u < 0.25) and P_LIT or ((u < 0.8) and P_MID or P_DARK)
    work(q, {hand="detail", tool={kind="filbert", width=math.max(2, p.w / 22)}, pile=pl, coverage=3.2, fill=true, angle=0, clip=q, seed=210 + i})
  end
end
print(#PLATES)

--@ chunk 3
-- darks: the lander, its clamp legs, its long black shadow raked across the plates, the torn plates' undersides, the hole
local B  = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
local DS = pile{{"bone black",1.5},{"ultramarine blue",0.5},{"burnt sienna",0.3},{"lead white",0.15}}
-- shadow thrown to the right by the light raking in from the left
SHAD = poly({L(40, 30), L(560, 60), {1010, 330}, {1010, 470}, L(40, 75)})* HULL
work(SHAD, {hand="body", tool="filbert 8", pile=B, coverage=3, fill=true, angle=0.3, clip=SHAD, seed=301})
HOLE = ellipse(E[1], E[2] + 6, 70, 36)
work(HOLE, {hand="body", tool="filbert 5", pile=B, coverage=4, fill=true, angle=0, clip=HOLE, seed=302})
BODY = poly({L(10, -26), L(120, -70), L(420, -88), L(600, -60), L(640, -20), L(640, 30), L(600, 62), L(420, 86), L(120, 70), L(10, 26)}, true)
LEGS = ribbon({L(250, 70), L(280, 150), L(220, 210)}, 14) + ribbon({L(150, -60), L(110, -140), L(30, -170)}, 12) + ribbon({L(380, 80), L(430, 170), L(400, 240)}, 12)
work(BODY + LEGS, {hand="body", tool="filbert 6", pile=DS, coverage=4, fill=true, angle=math.atan(AX[2], AX[1]), clip=BODY + LEGS, seed=303})
-- the torn ring: plates peeled up round the hole, standing on edge, their undersides toward us black
PEEL = {}
for i = 0, 9 do
  local a = math.pi * 2 * i / 10 + 0.2
  local c = {E[1] + 92 * math.cos(a), E[2] + 6 + 48 * math.sin(a)}
  local o = {math.cos(a), math.sin(a) * 0.5}
  local t = {-o[2], o[1]}
  local w = rand(26, 38)
  local up = rand(30, 55)
  local tilt = rand(-0.3, 0.3)
  local pts = {{c[1] - t[1] * w / 2, c[2] - t[2] * w / 2}, {c[1] + t[1] * w / 2, c[2] + t[2] * w / 2},
               {c[1] + t[1] * w / 2 + o[1] * 20 + tilt * 10, c[2] + t[2] * w / 2 - up},
               {c[1] - t[1] * w / 2 + o[1] * 24 - tilt * 10, c[2] - t[2] * w / 2 - up * 0.85}}
  PEEL[#PEEL + 1] = {pts = pts, a = a}
  if BODY:at(c[1], c[2] - up / 2) < 0.5 then
    local q = poly(pts)
    work(q, {hand="detail", pile=(math.cos(a) < 0) and P_MID or B, coverage=4, fill=true, angle=1.57, clip=q, seed=310 + i})
  end
end
print(wait(4 * 24 * 60))

--@ chunk 4
-- the darks came up pale and mottled over the wet bronze: restate them opaque on the now-dry hull
local B  = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
local DS = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.3}}
work(SHAD - BODY:grow(1), {hand="body", tool="filbert 8", pile=B, coverage=4, fill=true, angle=0.3, clip=SHAD - BODY:grow(1), seed=501})
work(BODY + LEGS, {hand="body", tool="filbert 6", pile=DS, coverage=4.5, fill=true, angle=math.atan(AX[2], AX[1]), clip=BODY + LEGS, seed=502})
work(HOLE - BODY, {hand="body", tool="filbert 5", pile=B, coverage=4.5, fill=true, angle=0, clip=HOLE - BODY, seed=503})
for i, pl in ipairs(PEEL) do
  local q = poly(pl.pts) - BODY:grow(1)
  work(q, {hand="detail", pile=(math.cos(pl.a) < 0) and P_MID or B, coverage=4.5, fill=true, angle=1.57, clip=q, seed=510 + i})
end
print(wait(4 * 24 * 60))

--@ chunk 5
-- lights on dry paint, all as strokes (fast): plate lips raked from the left, the lander's lit edge and plating seams,
-- Church crimson bands, the bone cross, the seed pod's pale shoulder in the hole, molten gold and sparks
local rig = brush{kind="rigger", width=2.0, point=0.85}
local fl = brush{kind="flat", width=5}
local fb = brush{kind="filbert", width=5}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.1, 0.2}, clip=clip}) end
local B   = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.7},{"cadmium yellow",0.2}}
local WHT = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}
local MOL = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.6}}
local MOLW = pile{{"zinc white",3},{"lemon chrome",0.8}}
local CRIM = pile{{"cadmium red",1},{"vermilion",0.6},{"rose madder",0.4}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.3}}
local avoid = -(BODY:grow(2) + LEGS:grow(2) + SHAD + HOLE)
-- plates: the left end of each lip catches the raking light; a black shadow under each lip
local n = 0
for i, p in ipairs(PLATES) do
  if i % 2 == 0 or p.h > 30 then
    local arc = {}
    for j = 4, #p.pts - 1 do arc[#arc + 1] = p.pts[j] end
    local pr = clamp(p.h / 90, 0.15, 0.6)
    local sh = {}
    for _, q in ipairs(arc) do sh[#sh + 1] = {q[1] + 1.5, q[2] + 2} end
    S(rig, B, 0.6, sh, {pr, pr}, avoid)
    S(rig, LIP, 0.6, {arc[#arc], arc[#arc - 1], arc[#arc - 2], arc[#arc - 3]}, {pr * 0.9, pr * 0.4}, avoid)
    n = n + 1
  end
end
-- the lander: the light along its upper-left edge, seams across its plating, a hard glint
S(fb, LIP, 0.6, {L(30, -24), L(120, -66), L(420, -84), L(600, -57)}, {0.4, 0.2})
S(rig, WHT, 0.8, {L(30, -27), L(120, -69), L(420, -87), L(600, -60)}, {0.5, 0.2})
for _, s in ipairs({110, 200, 300, 400, 500}) do S(rig, B, 0.8, {L(s, -75), L(s + 8, 0), L(s, 78)}, {0.55, 0.55}) end
for _, s in ipairs({110, 200, 300, 400, 500}) do S(rig, LIP, 0.6, {L(s - 2, -78), L(s - 2, -55)}, {0.4, 0.1}) end
-- crimson bands and the bone cross on the flank
S(fl, CRIM, 0.9, {L(300, -40), L(305, 40)}, {0.9, 0.9}); S(fl, CRIM, 0.9, {L(312, -42), L(317, 42)}, {0.9, 0.9})
S(fl, CRIM, 0.9, {L(520, -40), L(522, 40)}, {0.9, 0.9})
S(fl, BONE, 0.9, {L(420, -36), L(420, 36)}, {0.9, 0.9}); S(fl, BONE, 0.9, {L(398, -6), L(442, -6)}, {0.9, 0.9})
-- legs: clamps biting the plates, lit left edges
S(rig, LIP, 0.6, {L(248, 66), L(276, 148), L(216, 206)}, {0.4, 0.3})
S(rig, LIP, 0.6, {L(146, -64), L(106, -144), L(26, -174)}, {0.4, 0.3})
S(rig, LIP, 0.6, {L(376, 76), L(426, 166), L(396, 236)}, {0.4, 0.3})
-- torn plates: hard lit edges on the left-facing ones, gold where they were torn
for _, pl in ipairs(PEEL) do
  local p = pl.pts
  if BODY:at((p[1][1] + p[3][1]) / 2, (p[1][2] + p[3][2]) / 2) < 0.5 then
    S(rig, (math.cos(pl.a) < 0.2) and WHT or LIP, 0.7, {p[1], p[4]}, {0.5, 0.4})
    S(rig, MOL, 0.7, {p[4], p[3]}, {0.5, 0.5})
  end
end
-- the seed pod's pale shoulder showing in the hole under the nose
S(fb, BONE, 0.8, {{E[1] - 30, E[2] + 4}, {E[1] - 10, E[2] - 2}, {E[1] + 10, E[2] + 2}}, {0.7, 0.6})
-- molten gold: a pool round the lip of the hole, then sprays thrown up and out
local hpts = {}
for k = 0, 30 do local a = math.pi * 2 * k / 30; hpts[#hpts + 1] = {E[1] + 70 * math.cos(a), E[2] + 6 + 36 * math.sin(a)} end
S(fb, MOL, 0.7, hpts, {0.5, 0.5})
S(rig, MOLW, 0.8, hpts, {0.4, 0.4})
local hair = brush{kind="rigger", width=1.6, point=0.9}
for i = 1, 70 do
  local a = rand(-math.pi * 0.95, -math.pi * 0.05)
  local r0 = rand(40, 80)
  local x0, y0 = E[1] + r0 * math.cos(a), E[2] + r0 * math.sin(a) * 0.5
  local len = rand(15, 70)
  local g = 0.4
  hair:reload((i % 3 == 0) and MOLW or MOL, 0.7)
  hair:stroke({{x0, y0}, {x0 + len * 0.5 * math.cos(a), y0 + len * 0.5 * math.sin(a)}, {x0 + len * math.cos(a), y0 + len * math.sin(a) + g * len}}, {pressure={0.5, 0.0}, ramps={0.05, 0.8}})
end
print(n)

--@ chunk 6
-- more violence: big plates wrenched up round the drill, a crimson collar at the nose, the molten spray larger
local B   = pile{{"bone black",2.4},{"ultramarine blue",0.2}}
local CRIM = pile{{"cadmium red",1},{"vermilion",0.6},{"rose madder",0.4}}
local TORN = {
  {{388,452},{420,446},{432,388},{396,380}}, {{352,478},{384,470},{350,412},{318,424}},
  {{408,500},{448,505},{456,560},{404,566}}, {{470,512},{512,508},{548,560},{500,572}},
  {{430,440},{452,436},{470,396},{448,392}}, {{338,500},{370,502},{316,540},{290,520}},
}
local undersides = nil
for i, t in ipairs(TORN) do
  local q = poly(t) - BODY:grow(1)
  -- the underside of a plate torn up toward us is in shadow; the ones toward the light show their bronze face
  local p = (i % 2 == 0) and B or P_MID
  work(q, {hand="detail", pile=p, coverage=5, fill=true, angle=1.3, clip=q, seed=600 + i})
end
local collar = poly({L(36, -44), L(70, -56), L(78, 58), L(40, 46)})
work(collar, {hand="detail", pile=CRIM, coverage=5, fill=true, angle=0.6, clip=collar, seed=620})
local band = poly({L(296, -78), L(330, -84), L(334, 88), L(300, 82)})
work(band, {hand="detail", pile=CRIM, coverage=5, fill=true, angle=0.6, clip=band, seed=621})
print(wait(4 * 24 * 60))
local rig = brush{kind="rigger", width=2.4, point=0.85}
local hair = brush{kind="rigger", width=1.8, point=0.9}
local LIP = pile{{"lead white",2.5},{"yellow ochre",0.7},{"cadmium yellow",0.2}}
local WHT = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}
local MOL = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.6}}
local MOLW = pile{{"zinc white",3},{"lemon chrome",0.8}}
local ORN = pile{{"Mars orange",1},{"cadmium red",0.4},{"cadmium yellow",0.3}}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.1, 0.2}}) end
for i, t in ipairs(TORN) do
  if BODY:at(t[3][1], t[3][2]) < 0.5 then
    S(rig, WHT, 0.8, {t[4], t[1]}, {0.55, 0.45})          -- the left edge, square to the light
    S(rig, MOL, 0.8, {t[4], t[3]}, {0.6, 0.5})            -- the torn top, glowing
    S(rig, ORN, 0.7, {t[1], t[2]}, {0.4, 0.3})
  end
end
-- collar and band lit on their light side; seams
S(rig, WHT, 0.8, {L(36, -46), L(70, -58)}, {0.5, 0.4})
S(rig, LIP, 0.7, {L(296, -80), L(330, -86)}, {0.5, 0.4})
-- the spray: arcs of molten metal thrown up and falling, sparks, and a glow on the plates round the hole
for i = 1, 60 do
  local a = rand(-math.pi * 0.9, -math.pi * 0.1)
  local v = rand(50, 160)
  local x0, y0 = E[1] + rand(-50, 40), E[2] + rand(-10, 8)
  local pts = {}
  for s = 0, 4 do
    local u = s / 4
    pts[#pts + 1] = {x0 + v * u * math.cos(a), y0 + v * u * math.sin(a) + 0.9 * v * u * u}
  end
  hair:reload((i % 4 == 0) and MOLW or ((i % 4 == 1) and ORN or MOL), 0.7)
  hair:stroke(pts, {pressure={0.55, 0.0}, ramps={0.05, 0.85}})
end
local tip = brush{kind="round", width=2.2, point=0.6}
for i = 1, 40 do
  local a, r = rand(-math.pi, 0.2), rand(60, 220)
  tip:reload((i % 2 == 0) and MOLW or MOL, 0.7); tip:touch(E[1] + r * math.cos(a), E[2] + r * math.sin(a) * 0.7, {pressure=rand(0.3, 0.7)})
end
local GLOW = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.4},medium=0.6}
work(ellipse(E[1] - 20, E[2] + 20, 150, 80):soften(40) - BODY:grow(2) - SHAD - HOLE, {hand="glaze", tool="filbert 10", pile=GLOW, coverage=0.8, load=0.3, pressure={0.12, 0.25}, angle=0, seed=630})

--@ chunk 7
-- the spray fell back into a nest: throw it up and out now, in long fans off the left of the drill, and a white-hot lip at the hole
local hair = brush{kind="rigger", width=2.0, point=0.9}
local MOL = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.6}}
local MOLW = pile{{"zinc white",3},{"lemon chrome",0.8}}
local ORN = pile{{"Mars orange",1},{"cadmium red",0.4},{"cadmium yellow",0.3}}
for i = 1, 55 do
  local a = rand(-math.pi * 0.92, -math.pi * 0.45)
  local v = rand(90, 260)
  local x0, y0 = E[1] + rand(-45, 10), E[2] + rand(-14, 0)
  local pts = {}
  for s = 0, 5 do
    local u = s / 5
    pts[#pts + 1] = {x0 + v * u * math.cos(a), y0 + v * u * math.sin(a) + 0.25 * v * u * u}
  end
  hair:reload((i % 3 == 0) and MOLW or ((i % 3 == 1) and MOL or ORN), 0.7)
  hair:stroke(pts, {pressure={0.6, 0.0}, ramps={0.05, 0.8}, clip=-(BODY:grow(1))})
end
local fb = brush{kind="filbert", width=4}
local hp = {}
for k = 0, 16 do local a = math.pi * (1.0 + k / 16); hp[#hp + 1] = {E[1] + 66 * math.cos(a), E[2] + 6 + 34 * math.sin(a) * -1} end
fb:reload(MOLW, 0.8); fb:stroke(hp, {pressure={0.5, 0.5}, clip=-(BODY:grow(1))})

