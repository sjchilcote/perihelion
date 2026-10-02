-- easel session "kiln": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.4, linen={16,18}, seed=6611, ground={{pile={{"burnt sienna",1},{"bone black",1.2},{"Mars red",0.4},{"lead white",0.2}}, um=140, apply="knife", texture=0.4}}}
HC = {500, 400}   -- the heart of the heat: just above the print bed, under the head
function circ(x, y) return math.atan(y - HC[2], x - HC[1]) + math.pi / 2 end
function rad(x, y) return math.atan(y - HC[2], x - HC[1]) end
function hd(x, y) return math.sqrt((x - HC[1])^2 + ((y - HC[2]) * 1.25)^2) end
print(W, H)

--@ chunk 2
-- value structure first: lean darks at the edges, the heat in zones toward one blazing centre
local K0 = pile{{"bone black",1.6},{"Mars red",0.5},{"burnt sienna",0.4}}
local K1 = pile{{"Mars red",1},{"bone black",0.9},{"burnt sienna",0.6}}
local K2 = pile{{"cadmium red",1},{"Mars red",0.6},{"burnt sienna",0.4}}
local K3 = pile{{"Mars orange",1},{"cadmium red",0.3},{"cadmium yellow",0.4},{"lead white",0.3}}
local K4 = pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",1}}
work(everywhere(), {hand="body", pile=K0, coverage=1.8, fill=true, angle=circ, length={40, 100}, seed=201})
local zones = {{K1, 520}, {K2, 330}, {K3, 200}, {K4, 105}}
for i, z in ipairs(zones) do
  local m = mask(function(x, y) return hd(x, y) < z[2] and 1 or 0 end):roughen(12, 60, 210 + i):soften(16)
  work(m, {hand="body", pile=z[1], coverage=2.2, fill=true, angle=circ, length={30, 80}, seed=220 + i})
end
blend(mask(function(x, y) return hd(x, y) < 560 and 1 or 0 end):soften(30), {angle=rad, tool={kind="badger", width=18}, seed=230})

--@ chunk 3
-- the darks, lean: scorched ribs round the chamber, the gantry and head, the print bed, the hoses, the printed legs
local RIBP = pile{{"bone black",1.8},{"burnt sienna",0.6},{"Mars red",0.3}}
local IRON = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"burnt sienna",0.5}}
local HOSE = pile{{"bone black",1.4},{"Mars brown",0.8},{"ultramarine blue",0.2}}
RIBS = {}
local function arcpts(rx, a0, a1)
  local pts = {}
  for k = 0, 40 do local a = lerp(a0, a1, k / 40); pts[#pts + 1] = {HC[1] + rx * math.cos(a), HC[2] - 40 + rx * 0.78 * math.sin(a)} end
  return pts
end
for i, rx in ipairs({430, 520, 620, 730, 850}) do
  local pts = arcpts(rx, math.pi * 0.86, math.pi * 2.14)
  local w = 18 + i * 6
  local m = ribbon(pts, w)
  work(m, {hand="body", tool="filbert 6", pile=RIBP, coverage=3.2, fill=true, angle=circ, clip=m, seed=300 + i})
  RIBS[i] = {pts = pts, w = w}
end
GANTRY = ribbon({{120,150},{500,138},{880,128}}, 24) + rect(495, 120, 50, 40)
HEAD = poly({{505,158},{538,158},{532,300},{526,336},{518,336},{511,300}})
work(GANTRY + HEAD, {hand="detail", tool={kind="flat", width=4}, pile=IRON, coverage=4, fill=true, angle=0, clip=GANTRY + HEAD, seed=320})
BEDTOP = ellipse(500, 505, 330, 58)
BEDSIDE = (rect(170, 505, 660, 40) + ellipse(500, 545, 330, 58)) - BEDTOP
work(BEDSIDE, {hand="body", tool="filbert 6", pile=IRON, coverage=3.5, fill=true, angle=0, clip=BEDSIDE, seed=330})
work(BEDTOP, {hand="body", tool="filbert 6", pile=RIBP, coverage=3, fill=true, angle=0, clip=BEDTOP, seed=331})
HOSES = {
  {{-20,300},{120,250},{260,215},{380,190},{500,165}},
  {{-20,560},{90,575},{180,560},{220,535}},
  {{1020,430},{930,470},{860,500},{820,520}},
  {{1020,210},{900,190},{780,170},{560,150}},
}
for i, h in ipairs(HOSES) do
  local m = ribbon(h, (i % 2 == 1) and 20 or 15)
  work(m, {hand="detail", tool={kind="filbert", width=4}, pile=HOSE, coverage=4, fill=true, angle=0, clip=m, seed=340 + i})
end
-- the printed part: legs and pelvis, lying with the feet to the left
LEGS = ribbon({{470,470},{365,476},{255,484}}, 24) + ribbon({{470,494},{362,500},{258,510}}, 24)
PELVIS = poly({{452,462},{512,458},{528,482},{512,506},{454,506}}, true)
FEETS = poly({{236,466},{262,466},{264,496},{238,500}}) + poly({{240,494},{266,494},{268,522},{242,524}})
FRAMEP = LEGS + PELVIS + FEETS
work(FRAMEP, {hand="detail", pile=IRON, coverage=4.5, fill=true, angle=0, clip=FRAMEP, seed=350})

--@ chunk 4
-- the edges must fall to black-red: a lean near-black over the walls outside the heat, behind the iron
local EDGE = pile{{"bone black",2},{"Mars red",0.5},{"burnt sienna",0.3}}
local MIDR = pile{{"Mars red",1},{"bone black",1.1},{"burnt sienna",0.3}}
local solid = GANTRY:grow(1) + HEAD:grow(1) + BEDTOP + BEDSIDE + FRAMEP:grow(1)
for i, h in ipairs(HOSES) do solid = solid + ribbon(h, 22) end
for _, r in ipairs(RIBS) do solid = solid + ribbon(r.pts, r.w + 2) end
local wall = -solid
local outer = wall * mask(function(x, y) return hd(x, y) > 470 and 1 or 0 end):soften(50)
work(outer, {hand="body", tool="filbert 8", pile=EDGE, coverage=2.8, fill=true, angle=circ, clip=wall, seed=401})
local mid = wall * mask(function(x, y) local d = hd(x, y); return (d > 330 and d < 520) and 1 or 0 end):soften(40)
work(mid, {hand="body", tool="filbert 8", pile=MIDR, coverage=1.8, fill=true, angle=circ, clip=wall, seed=402})
-- the bed's top takes the heat: orange under the head, red toward its rim; the printed legs dark against it
local B2 = pile{{"cadmium red",1},{"Mars red",0.6},{"burnt sienna",0.3}}
local B3 = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.35}}
local bt = BEDTOP - FRAMEP:grow(1)
work(bt * ellipse(520, 500, 250, 48), {hand="body", tool="filbert 5", pile=B2, coverage=3, fill=true, angle=0, clip=bt, seed=403})
work(bt * ellipse(560, 495, 120, 30), {hand="body", tool="filbert 5", pile=B3, coverage=3, fill=true, angle=0, clip=bt, seed=404})
blend(bt, {angle=0, tool={kind="badger", width=12}, seed=405})

--@ chunk 5
print(wait(4*24*60)); print(drying(500,300), drying(100,100), drying(400,480))

--@ chunk 6
-- lights last, on dry paint: the ribs' heat-side lips, iron edges, the white-hot head, the torso's glowing lattice, sparks and dust
local rig = brush{kind="rigger", width=2.2, point=0.85}
local fb = brush{kind="filbert", width=3.5}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.15, 0.3}}) end
local RIM1 = pile{{"cadmium red",1},{"Mars orange",1},{"lead white",0.2}}
local RIM2 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local HOT  = pile{{"lead white",2},{"cadmium yellow",1},{"lemon chrome",0.3}}
local WHITE = pile{{"zinc white",4},{"lemon chrome",0.4}}
-- ribs: the lip toward the heat, brightest on the inner ribs and where they face the centre
for i, r in ipairs(RIBS) do
  local pts = {}
  for k, p in ipairs(r.pts) do
    local dx, dy = HC[1] - p[1], HC[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    pts[#pts + 1] = {p[1] + dx / l * (r.w / 2 - 2), p[2] + dy / l * (r.w / 2 - 2)}
  end
  local p = (i <= 2) and RIM2 or RIM1
  S(fb, p, 0.6, pts, {lerp(0.55, 0.2, (i - 1) / 4), lerp(0.55, 0.2, (i - 1) / 4)})
  -- scorched bands across the rib: its plates
  for k = 3, #r.pts - 2, 5 do
    local a, b = r.pts[k], r.pts[k + 1]
    S(rig, pile{{"bone black",2}}, 0.6, {{a[1], a[2] - r.w / 2}, {a[1], a[2] + r.w / 2}}, {0.4, 0.4})
  end
end
-- gantry and head: lit from below; the nozzle white-hot
S(rig, RIM2, 0.7, {{130,162},{500,150},{870,140}}, {0.45, 0.35})
S(rig, HOT, 0.7, {{512,200},{514,300},{519,334}}, {0.3, 0.5})
S(rig, HOT, 0.7, {{532,200},{530,300},{525,334}}, {0.3, 0.5})
-- hoses: the side toward the heat
for i, h in ipairs(HOSES) do
  local pts = {}
  for _, p in ipairs(h) do local dx, dy = HC[1] - p[1], HC[2] - p[2]; local l = math.sqrt(dx * dx + dy * dy); pts[#pts + 1] = {p[1] + dx / l * 7, p[2] + dy / l * 7} end
  S(rig, RIM1, 0.6, pts, {0.15, 0.45})
end
-- the bed: its lip, and the line where its side turns away
S(fb, RIM2, 0.6, {{175,515},{300,553},{500,563},{700,553},{828,515}}, {0.35, 0.35})
-- the printed legs: upper edges in the heat, a dark gap between them, knees and feet
S(rig, pile{{"bone black",2}}, 0.9, {{468,482},{364,488},{256,497}}, {0.6, 0.6})
S(rig, RIM2, 0.7, {{470,459},{365,465},{255,473}}, {0.25, 0.5})
S(rig, RIM1, 0.6, {{470,483},{363,490},{258,499}}, {0.2, 0.4})
S(rig, RIM2, 0.7, {{452,462},{490,457},{514,460}}, {0.5, 0.5})
for _, k in ipairs({{365,466},{362,490}}) do rig:reload(HOT, 0.6); rig:touch(k[1], k[2], {pressure=0.7}) end
-- the torso: a lattice of glowing lines, spine and ribs, from the pelvis toward the head
local hair = brush{kind="rigger", width=1.6, point=0.9}
local function H(p, pts, pr) hair:reload(p, 0.7); hair:stroke(pts, {pressure=pr or {0.5, 0.45}, ramps={0.1, 0.2}}) end
H(WHITE, {{518,480},{560,476},{600,472},{640,470}})
for k = 0, 5 do
  local x = 535 + k * 19
  H(HOT, {{x, 478 - k * 0.8}, {x + 6, 462 - k}, {x + 2, 452 - k}}, {0.4, 0.35})
  H(HOT, {{x, 478 - k * 0.8}, {x + 6, 494 - k}, {x + 2, 500 - k}}, {0.4, 0.35})
end
H(RIM2, {{540,458},{600,452},{648,456}}, {0.3, 0.3})
H(RIM2, {{540,498},{600,496},{648,488}}, {0.3, 0.3})
H(RIM2, {{548,460},{570,496}}, {0.25, 0.25}); H(RIM2, {{586,456},{608,494}}, {0.25, 0.25}); H(RIM2, {{622,456},{596,494}}, {0.25, 0.25})
-- shoulders and head not yet made: a cloud of sparks and dust where they will be
stipple(ellipse(705, 465, 70, 38), {pile=HOT, width=1.6, coverage=function(x, y) local d = math.sqrt(((x - 705) / 70)^2 + ((y - 465) / 38)^2); return clamp(0.5 * (1 - d), 0, 0.5) end, feather=1, cluster=0.6, seed=601})
stipple(ellipse(690, 460, 50, 28), {pile=WHITE, width=1.2, coverage=function(x, y) local d = math.sqrt(((x - 690) / 50)^2 + ((y - 460) / 28)^2); return clamp(0.25 * (1 - d), 0, 0.25) end, feather=1, cluster=0.5, seed=602})
local DUST = pile{{"Mars orange",1},{"lead white",1},{"cadmium red",0.3},medium=0.6}
work(ellipse(710, 462, 85, 45):soften(25), {hand="glaze", tool="filbert 8", pile=DUST, coverage=0.7, load=0.2, pressure={0.08, 0.15}, angle=0.2, seed=603})
-- the heart: the blaze between nozzle and the lattice
local core = ellipse(530, 395, 90, 75)
stipple(core, {pile=HOT, width=5, coverage=function(x, y) local d = math.sqrt(((x - 530) / 90)^2 + ((y - 395) / 75)^2); return clamp(2.0 * (1 - d), 0, 2) end, feather=0.9, cluster=0.3, seed=604})
stipple(ellipse(525, 360, 40, 40), {pile=WHITE, width=4, coverage=function(x, y) local d = math.sqrt(((x - 525) / 40)^2 + ((y - 360) / 40)^2); return clamp(2.4 * (1 - d), 0, 2.4) end, feather=0.9, seed=605})
blend(ellipse(528, 385, 100, 90) - HEAD:grow(1), {angle=function(x, y) return math.atan(y - 360, x - 525) end, tool={kind="badger", width=14}, seed=606})
-- the nozzle itself, last
rig:reload(WHITE, 1.0); rig:touch(522, 338, {pressure=1.0})

--@ chunk 7
-- the blaze came up as a pale grey-pink disc with an edge: warm its rim back into the burst; restate the white only at the heart
local K3 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.5}}
local K4 = pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",1},{"lemon chrome",0.3}}
local WHITE = pile{{"zinc white",4},{"lemon chrome",0.6}}
local cx, cy = 528, 385
local function d(x, y) return math.sqrt(((x - cx) / 100)^2 + ((y - cy) / 90)^2) end
local keep = -(HEAD:grow(1) + BEDTOP + BEDSIDE + FRAMEP:grow(1) + GANTRY:grow(1))
local band = ellipse(cx, cy, 125, 112) * keep
work(band * mask(function(x, y) return d(x, y) > 0.55 and 1 or 0 end):soften(15), {hand="body", tool="filbert 5", pile=K3, coverage=2.6, fill=true,
  angle=function(x, y) return math.atan(y - cy, x - cx) end, length={20, 50}, clip=keep, seed=701})
work(ellipse(cx, cy, 70, 62) * keep, {hand="body", tool="filbert 4", pile=K4, coverage=2.4, fill=true,
  angle=function(x, y) return math.atan(y - cy, x - cx) end, length={15, 40}, clip=keep, seed=702})
stipple(ellipse(524, 362, 34, 34) * keep, {pile=WHITE, width=4, coverage=function(x, y) local e = math.sqrt(((x - 524) / 34)^2 + ((y - 362) / 34)^2); return clamp(2.6 * (1 - e), 0, 2.6) end, feather=0.9, seed=703})
blend(ellipse(cx, cy, 135, 120) * keep, {angle=function(x, y) return math.atan(y - cy, x - cx) end, tool={kind="badger", width=14}, seed=704})
-- the near leg bent at the knee, so there are two legs, not a bar
local IRON = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"burnt sienna",0.5}}
NLEG = ribbon({{468,468},{372,440},{262,468}}, 20)
work(NLEG, {hand="detail", pile=IRON, coverage=5, fill=true, angle=0, clip=NLEG, seed=705})

--@ chunk 8
-- the blaze is now a flat disc: break its edge with radial strokes like the burst's own, and put the white at its heart
local cx, cy = 528, 385
local keep = -(HEAD:grow(1) + BEDTOP + BEDSIDE + FRAMEP:grow(1) + GANTRY:grow(1) + NLEG:grow(1))
local OR1 = pile{{"Mars orange",1},{"cadmium red",0.4},{"cadmium yellow",0.4},{"lead white",0.2}}
local OR2 = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.4}}
local function radial(x, y) return math.atan(y - cy, x - cx) end
local ring = (ellipse(cx, cy, 175, 155) - ellipse(cx, cy, 95, 85)) * keep
work(ring, {hand="body", tool="filbert 3", pile=OR1, coverage=1.6, load=0.55, angle=radial, length={30, 80}, edge="lost", clip=keep, seed=801})
local inner = (ellipse(cx, cy, 125, 112) - ellipse(cx, cy, 70, 62)) * keep
work(inner, {hand="body", tool="filbert 3", pile=OR2, coverage=1.2, load=0.5, angle=radial, length={25, 60}, clip=keep, seed=802})
local WHITE = pile{{"zinc white",4},{"lemon chrome",0.5}}
local HOTW = pile{{"lead white",2},{"cadmium yellow",0.6},{"zinc white",1}}
stipple(ellipse(524, 365, 60, 55) * keep, {pile=HOTW, width=4, coverage=function(x, y) local e = math.sqrt(((x - 524) / 60)^2 + ((y - 365) / 55)^2); return clamp(2.2 * (1 - e), 0, 2.2) end, feather=0.9, cluster=0.2, seed=803})
stipple(ellipse(523, 352, 28, 28) * keep, {pile=WHITE, width=3.5, coverage=function(x, y) local e = math.sqrt(((x - 523) / 28)^2 + ((y - 352) / 28)^2); return clamp(3 * (1 - e), 0, 3) end, feather=0.8, seed=804})

--@ chunk 9
print(wait(4*24*60)); print(drying(523,356), drying(530,300))

--@ chunk 10
-- on dry paint: the white-hot heart, the lattice of the torso larger and brighter, sparks, the ribs' lips, the new leg's edges
local rig = brush{kind="rigger", width=2.4, point=0.85}
local fb = brush{kind="filbert", width=5}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.15, 0.3}}) end
local WHITE = pile{{"zinc white",4},{"lemon chrome",0.4}}
local HOT  = pile{{"lead white",2},{"cadmium yellow",1},{"lemon chrome",0.3}}
local RIM2 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local RIM1 = pile{{"cadmium red",1},{"Mars orange",1},{"lead white",0.2}}
local keep = -(HEAD:grow(1) + BEDTOP + BEDSIDE + FRAMEP:grow(1) + GANTRY:grow(1) + NLEG:grow(1))
stipple(ellipse(523, 356, 34, 32) * keep, {pile=WHITE, width=3.5, coverage=function(x, y) local e = math.sqrt(((x - 523) / 34)^2 + ((y - 356) / 32)^2); return clamp(3 * (1 - e), 0, 3) end, feather=0.9, seed=1001})
-- ribs: a broader lip on the heat side of the inner three
for i = 1, 3 do
  local r = RIBS[i]
  local pts = {}
  for _, p in ipairs(r.pts) do
    local dx, dy = HC[1] - p[1], HC[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    pts[#pts + 1] = {p[1] + dx / l * (r.w / 2 - 3), p[2] + dy / l * (r.w / 2 - 3)}
  end
  S(fb, (i == 1) and RIM2 or RIM1, 0.6, pts, {0.45 - i * 0.08, 0.45 - i * 0.08})
end
-- the new leg's edges: thigh and shin top lit, knee bright
S(rig, RIM2, 0.7, {{466,458},{372,430},{264,458}}, {0.35, 0.45})
rig:reload(HOT, 0.8); rig:touch(372, 432, {pressure=0.9})
-- the torso lattice, at full size: spine, a cage of ribs, the shoulder girdle half-made
local hair = brush{kind="rigger", width=2.0, point=0.9}
local function H(p, pts, pr) hair:reload(p, 0.75); hair:stroke(pts, {pressure=pr or {0.55, 0.5}, ramps={0.1, 0.2}}) end
H(WHITE, {{514,480},{560,474},{610,468},{660,462}}, {0.6, 0.5})
for k = 0, 6 do
  local x = 530 + k * 19
  local h = 26 + 6 * math.sin(k / 6 * math.pi)
  H(HOT, {{x, 476 - k}, {x + 8, 476 - k - h * 0.7}, {x + 4, 476 - k - h}}, {0.5, 0.35})
  H(HOT, {{x, 476 - k}, {x + 8, 476 - k + h * 0.6}, {x + 3, 476 - k + h * 0.8}}, {0.5, 0.35})
end
H(RIM2, {{534,446},{600,436},{664,440}}, {0.4, 0.35})
H(RIM2, {{534,500},{600,500},{664,486}}, {0.4, 0.35})
for k = 0, 4 do H(RIM2, {{540 + k * 26, 446 - k * 2}, {556 + k * 26, 498 - k * 2}}, {0.3, 0.3}) end
H(HOT, {{652,438},{668,428},{684,434}}, {0.4, 0.2})
H(HOT, {{652,488},{668,494},{684,488}}, {0.4, 0.2})
-- sparks and dust where the shoulders, arms and head are still to come
stipple(ellipse(720, 455, 80, 46), {pile=HOT, width=2.2, coverage=function(x, y) local e = math.sqrt(((x - 720) / 80)^2 + ((y - 455) / 46)^2); return clamp(0.9 * (1 - e), 0, 0.9) end, feather=1, cluster=0.6, seed=1002})
stipple(ellipse(700, 452, 50, 30), {pile=WHITE, width=1.6, coverage=function(x, y) local e = math.sqrt(((x - 700) / 50)^2 + ((y - 452) / 30)^2); return clamp(0.6 * (1 - e), 0, 0.6) end, feather=1, cluster=0.5, seed=1003})
-- a few sparks thrown wide
for i = 1, 26 do
  local a, r = rand(-math.pi, math.pi), rand(40, 170)
  local x, y = 700 + r * math.cos(a), 455 + r * math.sin(a) * 0.6
  rig:reload((i % 3 == 0) and WHITE or HOT, 0.6)
  rig:stroke({{x, y}, {x + 4 * math.cos(a), y + 4 * math.sin(a)}}, {pressure={0.5, 0.1}})
end

--@ chunk 11
-- the chamber's iron: couplings on the hoses, rivets on the ribs catching the heat, a glow along the bed's lower rim
local rig = brush{kind="rigger", width=2.6, point=0.7}
local RIM2 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local RIM1 = pile{{"cadmium red",1},{"Mars orange",1},{"lead white",0.2}}
local DK = pile{{"bone black",2},{"Mars red",0.3}}
for i, h in ipairs(HOSES) do
  for k = 2, #h - 1 do
    local p, q = h[k], h[k + 1]
    local dx, dy = q[1] - p[1], q[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    local nx, ny = -dy / l, dx / l
    local w = (i % 2 == 1) and 11 or 8
    rig:reload(DK, 0.8); rig:stroke({{p[1] - nx * w, p[2] - ny * w}, {p[1] + nx * w, p[2] + ny * w}}, {pressure={0.7, 0.7}})
    rig:reload(RIM1, 0.6); rig:stroke({{p[1] + 2 - nx * w, p[2] - ny * w}, {p[1] + 2 + nx * w * 0.2, p[2] + ny * w * 0.2}}, {pressure={0.4, 0.1}})
  end
end
for i, r in ipairs(RIBS) do
  for k = 2, #r.pts - 1, 4 do
    local p = r.pts[k]
    local dx, dy = HC[1] - p[1], HC[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    local x, y = p[1] + dx / l * (r.w * 0.2), p[2] + dy / l * (r.w * 0.2)
    rig:reload((i <= 2) and RIM2 or RIM1, 0.6); rig:touch(x, y, {pressure=0.6 - i * 0.07})
  end
end
local fb = brush{kind="filbert", width=4}
fb:reload(RIM1, 0.5); fb:stroke({{190,548},{320,590},{500,602},{680,590},{812,548}}, {pressure={0.15, 0.35}, swell={0.6, 1.2, 0.6}})

--@ chunk 12
-- (2) the blaze back down to a deep red-orange glow: radial strokes, blended along the radius
local cx, cy = 528, 385
local function radial(x, y) return math.atan(y - cy, x - cx) end
local solid = HEAD:grow(1) + GANTRY:grow(1) + BEDTOP + BEDSIDE
for i, h in ipairs(HOSES) do solid = solid + ribbon(h, 22) end
local keep = -solid
local DR1 = pile{{"cadmium red",1},{"Mars red",0.7},{"burnt sienna",0.3}}
local DR2 = pile{{"Mars orange",1},{"cadmium red",0.6},{"Mars red",0.3}}
local DR3 = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"cadmium red",0.2},{"lead white",0.15}}
work(ellipse(cx, cy, 190, 168) * keep, {hand="body", tool="filbert 5", pile=DR1, coverage=3, fill=true, angle=radial, length={30, 80}, edge="lost", clip=keep, seed=1201})
work(ellipse(cx, cy, 120, 105):soften(25) * keep, {hand="body", tool="filbert 4", pile=DR2, coverage=2.6, fill=true, angle=radial, length={25, 60}, clip=keep, seed=1202})
work(ellipse(cx, cy - 20, 60, 55):soften(20) * keep, {hand="body", tool="filbert 4", pile=DR3, coverage=2.4, fill=true, angle=radial, length={20, 45}, clip=keep, seed=1203})
blend(ellipse(cx, cy, 200, 178) * keep, {angle=radial, tool={kind="badger", width=14}, seed=1204})
-- (3) heavier ribs: wider scorched bands laid over the old hoops (behind the gantry and hoses)
local RIBP = pile{{"bone black",1.8},{"burnt sienna",0.6},{"Mars red",0.3}}
local SCOR = pile{{"bone black",1.2},{"Mars brown",0.8},{"burnt sienna",0.5}}
for i, r in ipairs(RIBS) do
  r.w = r.w + 22
  local m = ribbon(r.pts, r.w) * keep
  work(m, {hand="body", tool="filbert 6", pile=RIBP, coverage=3.2, fill=true, angle=circ, clip=m, seed=1210 + i})
  local inner = ribbon(r.pts, r.w * 0.45) * keep
  work(inner, {hand="body", tool="filbert 4", pile=SCOR, coverage=2, angle=circ, clip=m, seed=1220 + i})
end
-- (1) the frame, large, lying on its back across the bed: feet left, chest under the head, shoulders and head to come at the right
local IRON = pile{{"bone black",1.7},{"ultramarine blue",0.3},{"burnt sienna",0.5}}
local HOLLOW = pile{{"bone black",1.8},{"Mars red",0.4}}
PELV2 = poly({{350,470},{410,462},{430,490},{410,522},{352,520}}, true)
LEGF = ribbon({{372,474},{285,470},{206,480}}, 26) + ellipse(285, 470, 13, 11)
LEGN = ribbon({{374,512},{290,516},{212,522}}, 28) + ellipse(290, 516, 14, 12)
FEET2 = poly({{184,450},{206,455},{210,489},{189,491}}) + poly({{188,499},{212,501},{215,535},{193,537}})
TORSO2 = poly({{410,458},{500,448},{600,446},{614,470},{602,522},{500,526},{410,526}}, true)
FRAME2 = PELV2 + LEGF + LEGN + FEET2
work(TORSO2, {hand="body", tool="filbert 4", pile=HOLLOW, coverage=3.5, fill=true, angle=0, clip=TORSO2, seed=1230})
work(FRAME2, {hand="detail", pile=IRON, coverage=5, fill=true, angle=0, clip=FRAME2, seed=1231})
-- the old small frame's raised knee sticks up above the new legs: bed colour over it on the bed, the chamber's red above
local old = NLEG:grow(3) - FRAME2:grow(1) - TORSO2:grow(1)
local BEDC = pile{{"cadmium red",1},{"Mars red",0.6},{"burnt sienna",0.3}}
local onbed = old * BEDTOP
work(onbed, {hand="detail", pile=BEDC, coverage=4, fill=true, angle=0, clip=onbed, seed=1240})
local above = old - BEDTOP
work(above, {hand="detail", pile=DR1, coverage=4, fill=true, angle=0.3, clip=above, seed=1241})

--@ chunk 13
-- the glow's edge is a hard disc: drag the chamber's red in across it, and the glow's red out, in short radial strokes
local cx, cy = 528, 385
local solid = HEAD:grow(1) + GANTRY:grow(1) + BEDTOP + BEDSIDE + TORSO2:grow(1) + FRAME2:grow(1)
for i, h in ipairs(HOSES) do solid = solid + ribbon(h, 22) end
for _, r in ipairs(RIBS) do solid = solid + ribbon(r.pts, r.w) end
local keep = -solid
local disc = ellipse(cx, cy, 190, 168)
local OUTR = pile{{"Mars red",1},{"bone black",0.6},{"burnt sienna",0.6},{"cadmium red",0.3}}
local INR  = pile{{"cadmium red",1},{"Mars red",0.7},{"burnt sienna",0.3}}
local ring = (ellipse(cx, cy, 240, 215) - ellipse(cx, cy, 140, 122)) * keep
work(ring, {hand="body", tool="filbert 4", pile=OUTR, coverage=1.4, load=0.45, angle=function(x, y) return math.atan(y - cy, x - cx) end, length={30, 70}, clip=keep, seed=1301})
work(ring * ellipse(cx, cy, 200, 178), {hand="body", tool="filbert 4", pile=INR, coverage=0.9, load=0.4, angle=function(x, y) return math.atan(y - cy, x - cx) end, length={30, 70}, clip=keep, seed=1302})
blend(ring, {angle=function(x, y) return math.atan(y - cy, x - cx) end, tool={kind="badger", width=14}, seed=1303})
print(wait(4 * 24 * 60))

--@ chunk 14
-- on dry paint: the ribs' lit lips; the frame's hot plate edges; the torso's glowing lattice; the white point,
-- a tight spray of sparks onto the chest; the shoulders and head a cloud of sparks
local rig = brush{kind="rigger", width=2.4, point=0.85}
local fb = brush{kind="filbert", width=5}
local hair = brush{kind="rigger", width=1.8, point=0.9}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.12, 0.3}}) end
local RIM1 = pile{{"cadmium red",1},{"Mars orange",1},{"lead white",0.2}}
local RIM2 = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local HOT  = pile{{"lead white",2},{"cadmium yellow",1},{"lemon chrome",0.3}}
local WHITE = pile{{"zinc white",4},{"lemon chrome",0.4}}
local DK = pile{{"bone black",2},{"Mars red",0.3}}
-- ribs: a broad lit lip on the side toward the heat, a thin hot edge on it, scorch seams across
for i, r in ipairs(RIBS) do
  local lip, edge = {}, {}
  for _, p in ipairs(r.pts) do
    local dx, dy = HC[1] - p[1], HC[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    lip[#lip + 1] = {p[1] + dx / l * (r.w / 2 - 5), p[2] + dy / l * (r.w / 2 - 5)}
    edge[#edge + 1] = {p[1] + dx / l * (r.w / 2 - 2), p[2] + dy / l * (r.w / 2 - 2)}
  end
  local k = (i - 1) / 4
  S(fb, RIM1, 0.6, lip, {0.5 - 0.25 * k, 0.5 - 0.25 * k})
  S(rig, RIM2, 0.6, edge, {0.5 - 0.3 * k, 0.5 - 0.3 * k})
  for j = 3, #r.pts - 2, 4 do
    local p = r.pts[j]
    local dx, dy = HC[1] - p[1], HC[2] - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    S(rig, DK, 0.7, {{p[1] - dx / l * r.w * 0.45, p[2] - dy / l * r.w * 0.45}, {p[1] + dx / l * r.w * 0.4, p[2] + dy / l * r.w * 0.4}}, {0.5, 0.4})
  end
end
-- the frame's plates: hot edges on the upper sides, a seam at each knee, the soles
S(rig, RIM2, 0.8, {{372,461},{285,457},{206,467}}, {0.45, 0.5})
S(rig, RIM2, 0.8, {{374,498},{290,502},{212,508}}, {0.45, 0.5})
S(rig, RIM1, 0.7, {{372,487},{285,483},{206,493}}, {0.3, 0.3})
S(rig, RIM1, 0.7, {{374,526},{290,530},{212,535}}, {0.3, 0.3})
S(rig, HOT, 0.8, {{276,462},{285,458},{295,462}}, {0.6, 0.4})
S(rig, HOT, 0.8, {{280,507},{290,503},{301,507}}, {0.6, 0.4})
S(rig, DK, 0.8, {{285,460},{285,482}}, {0.5, 0.5}); S(rig, DK, 0.8, {{290,505},{290,528}}, {0.5, 0.5})
S(rig, RIM2, 0.8, {{185,452},{206,456}}, {0.6, 0.5}); S(rig, RIM2, 0.8, {{189,500},{212,502}}, {0.6, 0.5})
S(rig, RIM2, 0.8, {{352,471},{380,464},{410,462}}, {0.5, 0.4})
S(rig, RIM1, 0.7, {{410,462},{430,490},{410,522}}, {0.4, 0.4})
-- the torso: spine, ribs, sternum, collar, thin bright lines on the dark hollow
local function H(p, pts, pr) hair:reload(p, 0.75); hair:stroke(pts, {pressure=pr or {0.5, 0.45}, ramps={0.08, 0.15}}) end
H(WHITE, {{420,490},{470,488},{520,486},{570,484},{606,482}}, {0.55, 0.5})
for k = 0, 8 do
  local x = 432 + k * 19
  local up = 30 + 6 * math.sin(k / 8 * math.pi)
  H(HOT, {{x, 489}, {x + 7, 489 - up * 0.6}, {x + 4, 489 - up}}, {0.45, 0.3})
  H(HOT, {{x, 489}, {x + 7, 489 + up * 0.55}, {x + 3, 489 + up * 0.8}}, {0.45, 0.3})
end
H(RIM2, {{440,458},{520,452},{600,454}}, {0.35, 0.3})
H(RIM2, {{440,520},{520,520},{600,512}}, {0.35, 0.3})
for k = 0, 5 do H(RIM2, {{446 + k * 28, 458}, {462 + k * 28, 518}}, {0.25, 0.25}) end
H(HOT, {{600,454},{622,446},{640,450}}, {0.4, 0.15})
H(HOT, {{600,512},{622,518},{640,512}}, {0.4, 0.15})
-- shoulders and head: a cloud of sparks and dust
stipple(ellipse(670, 482, 70, 42), {pile=HOT, width=2, coverage=function(x, y) local e = math.sqrt(((x - 670) / 70)^2 + ((y - 482) / 42)^2); return clamp(0.8 * (1 - e), 0, 0.8) end, feather=1, cluster=0.6, seed=1401})
stipple(ellipse(655, 480, 40, 26), {pile=WHITE, width=1.5, coverage=function(x, y) local e = math.sqrt(((x - 655) / 40)^2 + ((y - 480) / 26)^2); return clamp(0.5 * (1 - e), 0, 0.5) end, feather=1, cluster=0.5, seed=1402})
-- the nozzle: a small white-hot point, a short tight spray of sparks down onto the chest
local tip = brush{kind="round", width=4, point=0.5}
tip:reload(WHITE, 1.0); tip:touch(522, 339, {pressure=0.9})
for i = 1, 22 do
  local a = math.pi / 2 + rand(-0.22, 0.22)
  local r0, r1 = rand(6, 40), rand(50, 120)
  local x0, y0 = 522 + r0 * math.cos(a), 340 + r0 * math.sin(a)
  local len = rand(6, 16)
  hair:reload((i % 3 == 0) and WHITE or HOT, 0.6)
  hair:stroke({{x0, y0}, {x0 + len * math.cos(a), y0 + len * math.sin(a)}}, {pressure={0.45, 0.05}, ramps={0.05, 0.7}})
  if r1 > 100 then rig:reload(HOT, 0.6); rig:touch(522 + r1 * math.cos(a), 340 + r1 * math.sin(a), {pressure=0.5}) end
end
local glow = ellipse(522, 346, 14, 12)
stipple(glow, {pile=HOT, width=2.5, coverage=function(x, y) local e = math.sqrt(((x - 522) / 14)^2 + ((y - 346) / 12)^2); return clamp(1.5 * (1 - e), 0, 1.5) end, feather=0.9, seed=1403})
