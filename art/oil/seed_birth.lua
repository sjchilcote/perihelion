-- easel session "seed_birth": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,18}, seed=2727, ground={{pile={{"bone black",2},{"burnt sienna",0.5},{"bone brown",0.4}}, um=140, apply="knife", texture=0.35}}}
HOLE = {500, 96}
POD = {492, 470}
print(W, H)

--@ chunk 2
-- the dark structure: the ceiling's underside (the inner armour layer) seen from below, the ribs arching through the void
local BRD = pile{{"bone black",1.6},{"burnt sienna",0.8},{"raw sienna",0.3}}
local BRM = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.6}}
CEIL = poly({{-10,-10},{1010,-10},{1010,150},{700,182},{500,196},{300,186},{-10,160}}, true)
work(CEIL, {hand="body", tool="filbert 8", pile=BRM, coverage=2.6, fill=true, angle=0, clip=CEIL, seed=201})
RIBS = {
  {{-20,330},{150,250},{330,215},{420,212}},
  {{1020,300},{860,240},{680,212},{590,210}},
  {{-20,760},{120,640},{240,560},{300,530}},
  {{1020,820},{880,690},{760,600},{700,570}},
  {{-20,1180},{200,1040},{360,980}},
  {{1020,1240},{820,1090},{640,1010}},
}
for i, r in ipairs(RIBS) do
  local w = 34 + i * 6
  local m = ribbon(r, w)
  work(m, {hand="body", tool="filbert 6", pile=BRD, coverage=3.2, fill=true, angle=math.atan(r[2][2] - r[1][2], r[2][1] - r[1][1]), clip=m, seed=210 + i})
end
-- the drill-hole: black inside its rim
HOLEM = ellipse(HOLE[1], HOLE[2], 70, 26)
work(HOLEM, {hand="detail", pile=pile{{"bone black",2}}, coverage=4, fill=true, angle=0, clip=HOLEM, seed=220})

--@ chunk 3
-- the ceiling should be dark except where the hole's heat lights it; the pod's body; a faint shaft of light from the hole
local BRK = pile{{"bone black",2},{"burnt sienna",0.4}}
local away = CEIL * -ellipse(HOLE[1], HOLE[2] + 10, 230, 110):soften(60)
work(away, {hand="body", tool="filbert 8", pile=BRK, coverage=3, fill=true, angle=0, clip=CEIL, seed=301})
local WARMC = pile{{"Mars orange",1},{"burnt sienna",0.8},{"cadmium red",0.3}}
local near = CEIL * ellipse(HOLE[1], HOLE[2] + 6, 150, 70):soften(30) - HOLEM:grow(2)
work(near, {hand="body", tool="filbert 5", pile=WARMC, coverage=2.4, fill=true, angle=0, clip=CEIL - HOLEM, seed=302})
-- the pod: a capsule, nose down, its upper end still in the hole's shaft
PODM = poly({{POD[1] - 30, POD[2] - 60}, {POD[1] + 30, POD[2] - 62}, {POD[1] + 38, POD[2]}, {POD[1] + 26, POD[2] + 50}, {POD[1], POD[2] + 72}, {POD[1] - 26, POD[2] + 50}, {POD[1] - 38, POD[2]}}, true)
local PODD = pile{{"bone brown",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"bone black",0.4}}
work(PODM, {hand="detail", tool={kind="filbert", width=4}, pile=PODD, coverage=4, fill=true, angle=1.57, clip=PODM, seed=303})
-- the shaft of light: low-load pale strokes in air, from the hole down past the pod
local AIR = pile{{"lead white",2},{"Mars orange",0.3},{"cadmium yellow",0.2}}
local shaft = poly({{HOLE[1] - 62, HOLE[2] + 18}, {HOLE[1] + 62, HOLE[2] + 18}, {POD[1] + 110, 900}, {POD[1] - 120, 900}}):soften(30) - PODM:grow(2)
work(shaft, {hand="glaze", tool="filbert 14", pile=AIR, coverage=0.8, load=0.22, pressure={0.08, 0.18}, angle=1.57, seed=304})
blend(shaft, {angle=1.57, tool={kind="badger", width=24}, seed=305})
print(wait(4 * 24 * 60))

--@ chunk 4
-- the shaft came up as a grey curtain: the light is the pod's own, not a beam. Put the void's dark back over it.
local BRK = pile{{"bone black",2},{"burnt sienna",0.5},{"bone brown",0.3}}
local ribsm = nil
for i, r in ipairs(RIBS) do local m = ribbon(r, 34 + i * 6); ribsm = ribsm and (ribsm + m) or m end
local area = poly({{HOLE[1] - 120, 190}, {HOLE[1] + 120, 190}, {POD[1] + 150, 960}, {POD[1] - 160, 960}}) - PODM:grow(1) - ribsm - CEIL
work(area, {hand="body", tool="filbert 7", pile=BRK, coverage=4, fill=true, angle=1.57, clip=area, seed=401})
-- the part of the shaft over the ceiling: the ceiling's warm-dark again
local WD = pile{{"burnt sienna",1},{"bone black",1.2},{"Mars orange",0.3}}
local c = CEIL * poly({{HOLE[1] - 90, 110}, {HOLE[1] + 90, 110}, {HOLE[1] + 120, 200}, {HOLE[1] - 120, 200}}) - HOLEM:grow(1)
work(c, {hand="body", tool="filbert 5", pile=WD, coverage=3.5, fill=true, angle=0, clip=c, seed=402})
-- the pod larger, a proper capsule
POD2 = poly({{POD[1] - 44, POD[2] - 90}, {POD[1] + 44, POD[2] - 92}, {POD[1] + 54, POD[2] - 10}, {POD[1] + 40, POD[2] + 64}, {POD[1], POD[2] + 100}, {POD[1] - 40, POD[2] + 64}, {POD[1] - 54, POD[2] - 10}}, true)
local PODD = pile{{"bone brown",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"bone black",0.5}}
work(POD2, {hand="detail", tool={kind="filbert", width=5}, pile=PODD, coverage=4.5, fill=true, angle=1.57, clip=POD2, seed=403})
print(wait(4 * 24 * 60))

--@ chunk 5
-- the pod's own light in the dark air: low-load warm veils round it, blended out along the radius; the ceiling's heat round the hole
local px, py = POD[1], POD[2]
local function rad(x, y) return math.atan(y - py, x - px) end
local V1 = pile{{"lead white",1.5},{"Mars orange",0.6},{"cadmium yellow",0.3}}
local V2 = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.2}}
local keep = -(POD2:grow(1) + CEIL)
work(ellipse(px, py, 230, 260):soften(80) * keep, {hand="glaze", tool="filbert 14", pile=V1, coverage=0.9, load=0.22, pressure={0.08, 0.18}, angle=function(x, y) return rad(x, y) + 1.57 end, clip=keep, seed=501})
work(ellipse(px, py, 120, 150):soften(40) * keep, {hand="glaze", tool="filbert 10", pile=V2, coverage=0.9, load=0.25, pressure={0.1, 0.2}, angle=function(x, y) return rad(x, y) + 1.57 end, clip=keep, seed=502})
blend(ellipse(px, py, 260, 290) * keep, {angle=rad, tool={kind="badger", width=24}, seed=503})
blend(ellipse(px, py, 260, 290) * keep, {angle=function(x, y) return rad(x, y) + 1.57 end, tool={kind="badger", width=24}, seed=504})
local HE = pile{{"Mars orange",1},{"cadmium red",0.3},{"lead white",0.3}}
local hz = CEIL * ellipse(HOLE[1], HOLE[2] + 4, 190, 80):soften(40) - HOLEM:grow(2)
work(hz, {hand="glaze", tool="filbert 10", pile=HE, coverage=1.0, load=0.3, pressure={0.12, 0.25}, angle=function(x, y) return math.atan(y - HOLE[2], x - HOLE[1]) + 1.57 end, clip=CEIL - HOLEM, seed=505})
blend(hz, {angle=function(x, y) return math.atan(y - HOLE[2], x - HOLE[1]) end, tool={kind="badger", width=16}, seed=506})
print(wait(4 * 24 * 60))

--@ chunk 6
-- pale veils over the black came up as a grey disc, again. Paint the dark back; then the glow as opaque warm darks,
-- each zone with a lost edge, deepening outward
local px, py = POD[1], POD[2]
local function rad(x, y) return math.atan(y - py, x - px) end
local keep = -(POD2:grow(1) + CEIL)
local BRK = pile{{"bone black",2},{"burnt sienna",0.5},{"bone brown",0.3}}
local disc = ellipse(px, py, 280, 310) * keep
work(disc, {hand="body", tool="filbert 7", pile=BRK, coverage=4.2, fill=true, angle=rad, edge="lost", clip=keep, seed=601})
local Z1 = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars orange",0.3}}
local Z2 = pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone black",0.6}}
local Z3 = pile{{"Mars orange",1},{"burnt sienna",0.4},{"cadmium yellow",0.2}}
work(ellipse(px, py, 210, 235) * keep, {hand="body", tool="filbert 5", pile=Z1, coverage=2.6, fill=true, angle=rad, length={20, 60}, edge="lost", clip=keep, seed=602})
work(ellipse(px, py, 135, 160) * keep, {hand="body", tool="filbert 4", pile=Z2, coverage=2.4, fill=true, angle=rad, length={15, 45}, edge="lost", clip=keep, seed=603})
work(ellipse(px, py, 80, 105) * keep, {hand="body", tool="filbert 4", pile=Z3, coverage=2.4, fill=true, angle=rad, length={12, 35}, edge="lost", clip=keep, seed=604})
-- the hole's heat on the ceiling, the same way
local hk = CEIL - HOLEM:grow(2)
local hr = function(x, y) return math.atan(y - HOLE[2], x - HOLE[1]) end
work(CEIL * ellipse(HOLE[1], HOLE[2], 260, 120), {hand="body", tool="filbert 6", pile=BRK, coverage=4, fill=true, angle=hr, edge="lost", clip=hk, seed=605})
work(CEIL * ellipse(HOLE[1], HOLE[2], 170, 70), {hand="body", tool="filbert 4", pile=Z2, coverage=2.4, fill=true, angle=hr, length={12, 35}, edge="lost", clip=hk, seed=606})
work(CEIL * ellipse(HOLE[1], HOLE[2], 110, 44), {hand="body", tool="filbert 4", pile=Z3, coverage=2.4, fill=true, angle=hr, length={10, 30}, edge="lost", clip=hk, seed=607})
print(wait(4 * 24 * 60))

--@ chunk 7
-- the zones dried as rings: lay radial strokes of both neighbours across each seam, and blend only the narrow seams
local px, py = POD[1], POD[2]
local function rad(x, y) return math.atan(y - py, x - px) end
local keep = -(POD2:grow(1) + CEIL)
local G  = pile{{"bone black",2},{"burnt sienna",0.5},{"bone brown",0.4}}
local Z1 = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars orange",0.3}}
local Z2 = pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone black",0.6}}
local Z3 = pile{{"Mars orange",1},{"burnt sienna",0.4},{"cadmium yellow",0.2}}
local function ring(rx, ry, d) return (ellipse(px, py, rx + d, ry + d) - ellipse(px, py, rx - d, ry - d)) * keep end
local seams = {{80, 105, Z3, Z2}, {135, 160, Z2, Z1}, {210, 235, Z1, G}, {280, 310, G, G}}
for i, s in ipairs(seams) do
  local r = ring(s[1], s[2], 26)
  work(r, {hand="body", tool="filbert 3", pile=s[3], coverage=1.0, load=0.5, angle=rad, length={20, 50}, clip=r, seed=700 + i * 2})
  work(r, {hand="body", tool="filbert 3", pile=s[4], coverage=1.0, load=0.5, angle=rad, length={20, 50}, clip=r, seed=701 + i * 2})
  blend(r, {angle=rad, tool={kind="badger", width=12}, seed=720 + i})
end
local hr = function(x, y) return math.atan(y - HOLE[2], x - HOLE[1]) end
local hk = CEIL - HOLEM:grow(2)
for i, s in ipairs({{110, 44, Z3, Z2}, {170, 70, Z2, G}, {260, 120, G, G}}) do
  local r = (ellipse(HOLE[1], HOLE[2], s[1] + 20, s[2] + 14) - ellipse(HOLE[1], HOLE[2], s[1] - 20, s[2] - 14)) * hk
  work(r, {hand="body", tool="filbert 3", pile=s[3], coverage=1.0, load=0.5, angle=hr, length={15, 40}, clip=r, seed=740 + i * 2})
  work(r, {hand="body", tool="filbert 3", pile=s[4], coverage=1.0, load=0.5, angle=hr, length={15, 40}, clip=r, seed=741 + i * 2})
  blend(r, {angle=hr, tool={kind="badger", width=10}, seed=760 + i})
end
print(wait(4 * 24 * 60))

--@ chunk 8
-- lights on dry paint: the white-hot rim of the hole and drips hanging from it; the pod lit by its own light; droplets
-- falling slow and glowing; the ribs' edges facing the light
local rig = brush{kind="rigger", width=2.4, point=0.85}
local fb = brush{kind="filbert", width=5}
local hair = brush{kind="rigger", width=1.6, point=0.9}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr, ramps={0.1, 0.2}, clip=clip}) end
local WH  = pile{{"zinc white",4},{"lemon chrome",0.6}}
local GL  = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
local OR  = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.4}}
local RD  = pile{{"cadmium red",1},{"Mars orange",0.8}}
local POL = pile{{"yellow ochre",1.5},{"lead white",1},{"Mars orange",0.3}}
-- hole rim
local rim, rim2 = {}, {}
for k = 0, 40 do local a = 2 * math.pi * k / 40; rim[#rim + 1] = {HOLE[1] + 72 * math.cos(a), HOLE[2] + 27 * math.sin(a)}; rim2[#rim2 + 1] = {HOLE[1] + 80 * math.cos(a), HOLE[2] + 31 * math.sin(a)} end
S(fb, OR, 0.8, rim2, {0.6, 0.6})
S(fb, GL, 0.8, rim, {0.6, 0.6})
S(rig, WH, 0.9, rim, {0.6, 0.6})
for _, d in ipairs({{-50, 14}, {-22, 24}, {8, 26}, {38, 22}, {60, 12}}) do
  local x, y = HOLE[1] + d[1], HOLE[2] + d[2]
  S(rig, GL, 0.8, {{x, y}, {x + 1, y + 10}, {x, y + 16}}, {0.6, 0.9})
  rig:reload(WH, 0.8); rig:touch(x, y + 17, {pressure=0.8})
end
-- the pod: lit by its own light, gold seams, a lit waist band like a lantern's window, white at its glowing slits
local px, py = POD[1], POD[2]
S(fb, POL, 0.7, {{px - 46, py - 60}, {px - 52, py - 10}, {px - 38, py + 60}}, {0.4, 0.3})
S(fb, POL, 0.7, {{px + 46, py - 60}, {px + 52, py - 10}, {px + 38, py + 60}}, {0.4, 0.3})
for _, y in ipairs({-60, -25, 10, 45}) do
  local hw = (y < 0) and 48 or (48 - (y - 0) * 0.5)
  S(rig, GL, 0.8, {{px - hw, py + y}, {px, py + y + 6}, {px + hw, py + y}}, {0.45, 0.45}, POD2)
end
S(fb, WH, 0.9, {{px - 40, py - 8}, {px, py - 2}, {px + 40, py - 8}}, {0.55, 0.55}, POD2)
S(rig, WH, 0.9, {{px, py - 88}, {px, py + 96}}, {0.3, 0.3}, POD2)
local tip = brush{kind="round", width=3.5, point=0.5}
tip:reload(WH, 1.0); tip:touch(px, py + 98, {pressure=0.9})
-- droplets falling, glowing and slow: a bright head with a short trail above it, smaller and redder as they fall
local drops = {{430,300},{560,330},{470,640},{530,700},{410,760},{600,820},{455,900},{545,980},{500,1080},{420,1150},{575,1190},{480,1270}}
for i, d in ipairs(drops) do
  local k = (d[2] - 300) / 1000
  local len = lerp(26, 10, k)
  S(hair, (k < 0.4) and GL or OR, 0.7, {{d[1], d[2] - len}, {d[1], d[2]}}, {0.1, lerp(0.6, 0.3, k)})
  tip:reload((k < 0.5) and WH or ((k < 0.8) and GL or RD), 0.9); tip:touch(d[1], d[2], {pressure=lerp(0.9, 0.4, k)})
end
-- ribs: the edge facing the pod lit, brighter on the near ends
for i, r in ipairs(RIBS) do
  local w = 34 + i * 6
  local pts = {}
  for _, p in ipairs(r) do
    local dx, dy = px - p[1], py - p[2]
    local l = math.sqrt(dx * dx + dy * dy)
    pts[#pts + 1] = {p[1] + dx / l * (w / 2 - 3), p[2] + dy / l * (w / 2 - 3)}
  end
  local near = (i <= 4)
  S(fb, near and OR or RD, 0.6, pts, {0.15, near and 0.6 or 0.35})
  S(rig, near and GL or OR, 0.6, {pts[#pts - 1], pts[#pts]}, {0.3, near and 0.6 or 0.3})
end

--@ chunk 9
-- the zones still read as rings: break them with the light itself, rays of warm dust struck out from the pod,
-- each fading as it goes, crossing every seam; droplets larger
local px, py = POD[1], POD[2]
local fb = brush{kind="filbert", width=4}
local OR  = pile{{"Mars orange",1},{"burnt sienna",0.5},{"cadmium yellow",0.2}}
local ORL = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.3}}
local DK  = pile{{"bone black",1.6},{"burnt sienna",0.8}}
local keep = -(POD2:grow(2) + CEIL)
for i = 1, 260 do
  local a = rand(0, 2 * math.pi)
  local r0 = rand(70, 130)
  local r1 = r0 + rand(90, 230)
  local x0, y0 = px + r0 * math.cos(a), py + r0 * 1.15 * math.sin(a)
  local x1, y1 = px + r1 * math.cos(a), py + r1 * 1.15 * math.sin(a)
  local p = (i % 5 == 0) and DK or ((r0 < 95) and ORL or OR)
  fb:reload(p, 0.45)
  fb:stroke({{x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2}, {x1, y1}}, {pressure={0.45, 0.0}, ramps={0.05, 0.9}, clip=keep})
end
-- the hole's heat the same way
local hk = CEIL - HOLEM:grow(3)
for i = 1, 120 do
  local a = rand(0, 2 * math.pi)
  local r0, r1 = rand(80, 110), rand(170, 270)
  local x0, y0 = HOLE[1] + r0 * math.cos(a), HOLE[2] + r0 * 0.4 * math.sin(a)
  local x1, y1 = HOLE[1] + r1 * math.cos(a), HOLE[2] + r1 * 0.42 * math.sin(a)
  fb:reload((i % 5 == 0) and DK or OR, 0.45)
  fb:stroke({{x0, y0}, {x1, y1}}, {pressure={0.45, 0.0}, ramps={0.05, 0.9}, clip=hk})
end
-- droplets larger, each a glowing head with a falling trail
local tip = brush{kind="round", width=6, point=0.4}
local hair = brush{kind="rigger", width=2.6, point=0.9}
local WH = pile{{"zinc white",4},{"lemon chrome",0.6}}
local GL = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
local RD = pile{{"cadmium red",1},{"Mars orange",0.8}}
local drops = {{430,300},{560,330},{470,640},{530,700},{410,760},{600,820},{455,900},{545,980},{500,1080},{420,1150},{575,1190},{480,1270}}
for i, d in ipairs(drops) do
  local k = (d[2] - 300) / 1000
  hair:reload((k < 0.5) and GL or RD, 0.7)
  hair:stroke({{d[1], d[2] - lerp(40, 18, k)}, {d[1], d[2]}}, {pressure={0.05, lerp(0.7, 0.4, k)}, ramps={0.2, 0.1}})
  tip:reload((k < 0.4) and WH or ((k < 0.75) and GL or RD), 1.0); tip:touch(d[1], d[2], {pressure=lerp(0.8, 0.45, k)})
end

--@ chunk 10
-- the pod is the light: its body hot gold, brightest at its waist, cooler toward its ends; then its seams and slits again
print(wait(4 * 24 * 60))
local px, py = POD[1], POD[2]
local P1 = pile{{"Mars orange",1},{"yellow ochre",0.8},{"lead white",0.5}}
local P2 = pile{{"lead white",1.6},{"cadmium yellow",1},{"Indian yellow",0.3}}
local body = POD2:shrink(3)
work(body, {hand="body", tool="filbert 4", pile=P1, coverage=3, fill=true, angle=1.57, clip=body, seed=1001})
local waist = body * ellipse(px, py - 4, 60, 48)
work(waist, {hand="body", tool="filbert 4", pile=P2, coverage=2.6, fill=true, angle=0, edge="soft", clip=body, seed=1002})
blend(body, {angle=1.57, tool={kind="badger", width=10}, seed=1003})
print(wait(4 * 24 * 60))
local rig = brush{kind="rigger", width=2.0, point=0.85}
local BRN = pile{{"burnt sienna",1},{"bone brown",0.8}}
local WH = pile{{"zinc white",4},{"lemon chrome",0.6}}
for _, y in ipairs({-62, -30, 30, 60}) do
  local hw = (y < 0) and 46 or (46 - y * 0.45)
  rig:reload(BRN, 0.8); rig:stroke({{px - hw, py + y}, {px, py + y + 6}, {px + hw, py + y}}, {pressure={0.5, 0.5}, clip=POD2})
end
rig:reload(BRN, 0.8); rig:stroke({{px, py - 88}, {px, py + 96}}, {pressure={0.4, 0.4}, clip=POD2})
local fb = brush{kind="filbert", width=5}
fb:reload(WH, 0.9); fb:stroke({{px - 38, py - 6}, {px, py}, {px + 38, py - 6}}, {pressure={0.6, 0.6}, clip=POD2})
local tip = brush{kind="round", width=4, point=0.5}
tip:reload(WH, 1.0); tip:touch(px, py + 98, {pressure=0.9})
