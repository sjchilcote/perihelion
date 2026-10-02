-- easel session "tarot": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=2, linen={16,18}, seed=2020, ground={{pile={{"bone black",1.6},{"ultramarine blue",0.5},{"magenta",0.15}}, um=140, apply="knife", texture=0.3}}}
OX = {34, 272, 510, 748}
OY = 58
CW, CH = 218, 384
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.25}}
BLK = pile{{"bone black",2.2},{"ultramarine blue",0.2}}
SKYK = pile{{"bone black",1.4},{"ultramarine blue",0.8},{"lead white",0.1}}
NIGHT = pile{{"ultramarine blue",1.4},{"cobalt blue",0.5},{"bone black",0.3},{"lead white",0.2}}
PALEB = pile{{"cerulean blue",1},{"lead white",1.5}}
GOLD = pile{{"cadmium yellow",1},{"Mars yellow",0.5},{"lead white",0.4}}
BRZ = pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"burnt sienna",0.3},{"lead white",0.3}}
CRIM = pile{{"cadmium red",1},{"vermilion",0.5},{"rose madder",0.3}}
STEEL = pile{{"lead white",1},{"ultramarine blue",0.4},{"bone black",0.4}}
GREEN = pile{{"viridian",0.8},{"yellow ochre",0.8},{"lead white",0.6}}
POOL = pile{{"cerulean blue",1},{"viridian",0.4},{"lead white",0.6}}
VIOL = pile{{"cobalt violet",1},{"magenta",0.4},{"lead white",0.5}}
ORANGE = pile{{"Mars orange",1},{"cadmium yellow",0.5}}
SH = {}
function q(o, pts) local t = {} for _, p in ipairs(pts) do t[#t + 1] = {OX[o] + p[1], OY + p[2]} end; return t end
function E(o, x, y, rx, ry, n) local t = {} n = n or 16; for i = 0, n - 1 do local a = 2 * math.pi * i / n; t[#t + 1] = {OX[o] + x + rx * math.cos(a), OY + y + ry * math.sin(a)} end; return t end
function add(pts, p, a, nolines) SH[#SH + 1] = {pts = pts, p = p, a = a or 0, nol = nolines} end
function fillall(from)
  for i = from or 1, #SH do local s = SH[i]; local m = poly(s.pts); work(m, {hand="detail", tool={kind="filbert", width=4}, pile=s.p, coverage=4.5, fill=true, angle=s.a, clip=m, seed=3000 + i}) end
end
-- card bodies and their panels
for o = 1, 4 do
  add(q(o, {{0,0},{CW,0},{CW,CH},{0,CH}}), CREAM, 0, true)
end
fillall(1)
print(wait(3 * 24 * 60))
local n0 = #SH + 1
-- picture grounds
add(q(1, {{12,44},{206,44},{206,250},{12,250}}), SKYK)
add(q(1, {{12,250},{206,236},{206,330},{12,330}}), BRZ)
add(q(2, {{12,44},{206,44},{206,270},{12,270}}), NIGHT)
add(q(2, {{12,270},{206,270},{206,330},{12,330}}), GREEN)
add(q(3, {{12,44},{206,44},{206,330},{12,330}}), SKYK)
add(q(4, {{12,44},{206,44},{206,262},{12,262}}), PALEB)
add(q(4, {{12,262},{206,250},{206,330},{12,330}}), BRZ)
for o = 1, 4 do add(q(o, {{12,338},{206,338},{206,372},{12,372}}), CREAM, 0) end
fillall(n0)
print(wait(3 * 24 * 60))

--@ chunk 2
-- the figures, flat
local n0 = #SH + 1
-- I  THE KNIGHT: frontal on the hull, cannon raised like a lance, crimson tabard
add(q(1, {{103,316},{100,270},{108,270},{111,316}}), STEEL, 1.57)               -- legs
add(q(1, {{115,316},{118,270},{126,270},{123,316}}), STEEL, 1.57)
add(q(1, {{92,190},{134,190},{140,276},{86,276}}), CRIM, 1.57)                    -- tabard
add(q(1, {{84,186},{98,180},{98,200},{82,204}}), STEEL, 0)                         -- pauldrons
add(q(1, {{128,180},{142,186},{144,204},{128,200}}), STEEL, 0)
add(E(1, 113, 166, 14, 17, 14), STEEL, 0)                                         -- helm
add(q(1, {{138,200},{152,214},{146,222},{134,210}}), STEEL, 0.8)                   -- arm
add(q(1, {{140,232},{186,64},{194,68},{150,236}}), BLK, -1.3)                     -- the cannon-lance
add(q(1, {{186,64},{194,68},{196,52},{188,48}}), PALEB, 0)
-- XVII THE STAR: a great star, Ratio kneeling by the pool pouring light from two screens
add(E(2, 109, 96, 20, 20, 8), GOLD, 0)
add(q(2, {{120,286},{200,286},{200,320},{110,320}}), POOL, 0)
add(q(2, {{70,240},{118,232},{126,300},{60,300}}), PALEB, 1.57)                  -- robe, kneeling
add(q(2, {{72,196},{112,196},{118,260},{66,262}}), BLK, 1.57)                    -- hair
add(E(2, 92, 196, 17, 19, 14), CREAM, 0)                                         -- face
add(q(2, {{34,226},{60,226},{60,248},{34,248}}), CREAM, 0)                       -- left screen
add(q(2, {{124,222},{150,222},{150,244},{124,244}}), CREAM, 0)                   -- right screen
-- XVI THE TOWER: the TESTAMENT's spine as a tower, its ring crown knocked askew, struck by a violet bolt
add(q(3, {{90,330},{90,150},{128,150},{128,330}}), BRZ, 1.57)
add(q(3, {{66,150},{124,118},{164,140},{150,170},{100,176},{60,170}}), STEEL, 0.4)     -- crown, tilting
add(q(3, {{40,52},{84,96},{74,100},{118,134},{110,138},{126,152},{98,128},{106,124},{60,92},{70,88}}), VIOL, 0.8)   -- the bolt
add(q(3, {{128,186},{150,176},{160,196},{136,206}}), ORANGE, 0)                -- flames from the windows
add(q(3, {{82,226},{60,216},{64,240},{84,246}}), ORANGE, 0)
add(q(3, {{132,256},{150,244},{156,264},{136,272}}), ORANGE, 0)
-- XIX THE SUN: a calm-faced sun over the sail and a small station; a child on the hull, arms raised
add(E(4, 109, 112, 44, 44, 20), GOLD, 0)
add(q(4, {{20,262},{60,180},{92,256}}), CREAM, 1.0)                                 -- the sail
add(q(4, {{150,236},{198,236},{198,246},{150,246}}), STEEL, 0)                      -- the station, small
add(E(4, 174, 226, 14, 6, 12), STEEL, 0)
add(q(4, {{102,312},{98,282},{120,282},{116,312}}), ORANGE, 1.57)                -- child in coveralls
add(E(4, 109, 272, 8, 9, 12), CREAM, 0)
add(q(4, {{98,286},{86,258},{90,256},{102,282}}), ORANGE, 1.2)
add(q(4, {{120,286},{132,258},{128,256},{116,282}}), ORANGE, 1.9)
fillall(n0)
print(wait(4 * 24 * 60))

--@ chunk 3
-- strong black outlines and every detail, on dry paint
local rig = brush{kind="rigger", width=2.2, point=0.8}
local fine = brush{kind="rigger", width=1.4, point=0.9}
local tip = brush{kind="round", width=2.4, point=0.5}
local function seg(b, p, a, c, pr) b:reload(p, 0.85); b:stroke({a, c}, {pressure=pr or {0.65, 0.65}, ramps={0.04, 0.04}}) end
local function ring(b, p, pts, pr) for i = 1, #pts do seg(b, p, pts[i], pts[i % #pts + 1], pr) end end
local function Q(o, x, y) return {OX[o] + x, OY + y} end
for i, s in ipairs(SH) do if not s.nol then ring(rig, BLK, s.pts) end end
for o = 1, 4 do ring(rig, BLK, q(o, {{0,0},{CW,0},{CW,CH},{0,CH}}), {0.8, 0.8}); ring(fine, BLK, q(o, {{6,6},{CW - 6,6},{CW - 6,CH - 6},{6,CH - 6}}), {0.5, 0.5}) end
-- numerals at the top: I, XVII, XVI, XIX
local function I(o, x) seg(rig, BLK, Q(o, x, 16), Q(o, x, 34)) end
local function X(o, x) seg(rig, BLK, Q(o, x - 6, 16), Q(o, x + 6, 34)); seg(rig, BLK, Q(o, x + 6, 16), Q(o, x - 6, 34)) end
local function V(o, x) seg(rig, BLK, Q(o, x - 6, 16), Q(o, x, 34)); seg(rig, BLK, Q(o, x, 34), Q(o, x + 6, 16)) end
I(1, 109)
X(2, 86); V(2, 103); I(2, 118); I(2, 128)
X(3, 90); V(3, 107); I(3, 122)
X(4, 92); I(4, 108); X(4, 124)
-- titles: abstract capitals in the bottom panels
for o = 1, 4 do
  local n = ({7, 4, 5, 3})[o]
  local x0 = 109 - n * 9
  for i = 0, n - 1 do
    local x = x0 + i * 18
    local kd = (i * 5 + o) % 4
    seg(fine, BLK, Q(o, x, 346), Q(o, x, 364))
    if kd == 0 then seg(fine, BLK, Q(o, x, 346), Q(o, x + 10, 355)); seg(fine, BLK, Q(o, x + 10, 355), Q(o, x, 364))
    elseif kd == 1 then seg(fine, BLK, Q(o, x + 10, 346), Q(o, x + 10, 364)); seg(fine, BLK, Q(o, x, 355), Q(o, x + 10, 355))
    elseif kd == 2 then seg(fine, BLK, Q(o, x, 346), Q(o, x + 10, 364)); seg(fine, BLK, Q(o, x + 10, 346), Q(o, x + 10, 364))
    else seg(fine, BLK, Q(o, x, 346), Q(o, x + 10, 346)); seg(fine, BLK, Q(o, x, 364), Q(o, x + 10, 364)) end
  end
end
local WHT = pile{{"zinc white",4}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",0.6}}
local ICE = pile{{"zinc white",3},{"cerulean blue",1}}
-- the Knight: visor and cold optic, bone cross on the tabard, a few stars
seg(rig, BLK, Q(1, 102, 166), Q(1, 124, 166)); tip:reload(ICE, 1); tip:touch(OX[1] + 113, OY + 166, {pressure=0.9})
seg(rig, BONE, Q(1, 113, 200), Q(1, 113, 250), {0.9, 0.9}); seg(rig, BONE, Q(1, 98, 216), Q(1, 128, 216), {0.9, 0.9})
for _, s in ipairs({{30, 70}, {60, 110}, {150, 90}, {40, 160}, {170, 150}, {70, 60}}) do tip:reload(WHT, 0.9); tip:touch(OX[1] + s[1], OY + s[2], {pressure=0.6}) end
-- the Star: rays of the great star, small stars, screens' green faces, light pouring into the pool, her eyes
for k = 0, 7 do local a = k * math.pi / 4; seg(rig, GOLD, Q(2, 109 + 22 * math.cos(a), 96 + 22 * math.sin(a)), Q(2, 109 + ((k % 2 == 0) and 46 or 34) * math.cos(a), 96 + ((k % 2 == 0) and 46 or 34) * math.sin(a)), {0.7, 0.2}) end
for _, s in ipairs({{40, 70}, {170, 60}, {30, 140}, {184, 130}, {150, 170}, {56, 110}, {176, 92}}) do
  for k = 0, 3 do local a = k * math.pi / 2; seg(fine, WHT, Q(2, s[1], s[2]), Q(2, s[1] + 6 * math.cos(a), s[2] + 6 * math.sin(a)), {0.6, 0.1}) end
end
for _, r in ipairs({{36, 228, 22, 18}, {126, 224, 22, 18}}) do
  local m = poly(q(2, {{r[1], r[2]}, {r[1] + r[3], r[2]}, {r[1] + r[3], r[2] + r[4]}, {r[1], r[2] + r[4]}}))
  work(m, {hand="detail", pile=GREEN, coverage=4.5, fill=true, angle=0, clip=m, seed=math.floor(r[1])})
end
for k = 0, 4 do seg(fine, ICE, Q(2, 46 + k * 2, 248), Q(2, 70 + k * 10, 300), {0.5, 0.2}); seg(fine, ICE, Q(2, 136 + k * 2, 244), Q(2, 150 + k * 9, 300), {0.5, 0.2}) end
tip:reload(BLK, 1); tip:touch(OX[2] + 86, OY + 198, {pressure=0.8}); tip:reload(BLK, 1); tip:touch(OX[2] + 98, OY + 198, {pressure=0.8})
tip:reload(WHT, 1); tip:touch(OX[2] + 87, OY + 196, {pressure=0.3}); tip:reload(WHT, 1); tip:touch(OX[2] + 99, OY + 196, {pressure=0.3})
-- the Tower: windows lit, a white edge on the bolt, falling figures, falling drops
for y = 190, 310, 24 do seg(rig, ORANGE, Q(3, 100, y), Q(3, 100, y + 10), {0.8, 0.8}); seg(rig, ORANGE, Q(3, 118, y + 8), Q(3, 118, y + 18), {0.8, 0.8}) end
seg(fine, WHT, Q(3, 40, 52), Q(3, 84, 96), {0.5, 0.3}); seg(fine, WHT, Q(3, 74, 100), Q(3, 118, 134), {0.5, 0.3})
local function faller(o, x, y, a)
  local c, s = math.cos(a), math.sin(a)
  local function P(u, v) return Q(o, x + u * c - v * s, y + u * s + v * c) end
  tip:reload(BLK, 1); tip:touch(P(0, -10)[1], P(0, -10)[2], {pressure=0.9})
  seg(fine, BLK, P(0, -7), P(0, 4)); seg(fine, BLK, P(0, 4), P(-5, 12)); seg(fine, BLK, P(0, 4), P(5, 12)); seg(fine, BLK, P(0, -4), P(-7, -10)); seg(fine, BLK, P(0, -4), P(7, -1))
end
faller(3, 44, 210, 2.6); faller(3, 168, 236, -2.2); faller(3, 56, 290, 1.2)
for _, d in ipairs({{150, 120}, {170, 160}, {40, 170}, {186, 200}}) do tip:reload(ORANGE, 0.9); tip:touch(OX[3] + d[1], OY + d[2], {pressure=0.6}) end
-- the Sun: calm face, wavy rays, the sail's spars, the child's face
local sx, sy = 109, 112
seg(rig, BLK, Q(4, sx - 20, sy - 6), Q(4, sx - 8, sy - 4)); seg(rig, BLK, Q(4, sx + 8, sy - 4), Q(4, sx + 20, sy - 6))
seg(rig, BLK, Q(4, sx, sy - 2), Q(4, sx - 3, sy + 14)); seg(rig, BLK, Q(4, sx - 10, sy + 22), Q(4, sx, sy + 25)); seg(rig, BLK, Q(4, sx, sy + 25), Q(4, sx + 10, sy + 22))
for k = 0, 15 do
  local a = 2 * math.pi * k / 16
  local r0, r1 = 48, (k % 2 == 0) and 74 or 62
  local m = {sx + (r0 + r1) / 2 * math.cos(a + 0.06), sy + (r0 + r1) / 2 * math.sin(a + 0.06)}
  seg(rig, GOLD, Q(4, sx + r0 * math.cos(a), sy + r0 * math.sin(a)), Q(4, m[1], m[2]), {0.8, 0.6})
  seg(rig, GOLD, Q(4, m[1], m[2]), Q(4, sx + r1 * math.cos(a - 0.03), sy + r1 * math.sin(a - 0.03)), {0.6, 0.1})
end
seg(fine, BLK, Q(4, 60, 180), Q(4, 56, 262)); seg(fine, BLK, Q(4, 60, 180), Q(4, 40, 222))
tip:reload(BLK, 1); tip:touch(OX[4] + 106, OY + 270, {pressure=0.5}); tip:reload(BLK, 1); tip:touch(OX[4] + 112, OY + 270, {pressure=0.5})
seg(fine, BLK, Q(4, 105, 276), Q(4, 113, 276))

--@ chunk 4
-- the bolt bolder, the falling figures pale against the dark, Ratio's face clean
local fb = brush{kind="filbert", width=6}
local fine = brush{kind="rigger", width=1.6, point=0.9}
local tip = brush{kind="round", width=3, point=0.5}
local function Q(o, x, y) return {OX[o] + x, OY + y} end
local VB = pile{{"cobalt violet",1},{"magenta",0.5},{"lead white",0.6}}
local W = pile{{"zinc white",3},{"cobalt violet",0.3}}
local bolt = {{30, 50}, {84, 96}, {70, 102}, {124, 150}}
for i = 1, 3 do fb:reload(VB, 0.9); fb:stroke({Q(3, bolt[i][1], bolt[i][2]), Q(3, bolt[i + 1][1], bolt[i + 1][2])}, {pressure={0.8, 0.8}, ramps={0.03, 0.03}}) end
for i = 1, 3 do fine:reload(W, 0.9); fine:stroke({Q(3, bolt[i][1], bolt[i][2]), Q(3, bolt[i + 1][1], bolt[i + 1][2])}, {pressure={0.6, 0.6}, ramps={0.03, 0.03}}) end
local C2 = pile{{"lead white",2.5},{"yellow ochre",0.4}}
local function faller(x, y, a)
  local c, s = math.cos(a), math.sin(a)
  local function P(u, v) return Q(3, x + u * c - v * s, y + u * s + v * c) end
  local function sg(p1, p2) fine:reload(C2, 0.9); fine:stroke({p1, p2}, {pressure={0.7, 0.7}, ramps={0.03, 0.03}}) end
  tip:reload(C2, 1); tip:touch(P(0, -10)[1], P(0, -10)[2], {pressure=1})
  sg(P(0, -7), P(0, 4)); sg(P(0, 4), P(-5, 12)); sg(P(0, 4), P(5, 12)); sg(P(0, -4), P(-7, -10)); sg(P(0, -4), P(7, -1))
end
faller(44, 210, 2.6); faller(168, 236, -2.2); faller(56, 290, 1.2)
local face = poly(E(2, 92, 200, 13, 14, 14))
work(face, {hand="detail", pile=CREAM, coverage=5, fill=true, angle=0, clip=face, seed=901})
print(wait(3 * 24 * 60))
tip:reload(BLK, 1); tip:touch(OX[2] + 87, OY + 200, {pressure=0.8}); tip:reload(BLK, 1); tip:touch(OX[2] + 98, OY + 200, {pressure=0.8})
local t2 = brush{kind="round", width=1.6, point=0.5}
t2:reload(pile{{"zinc white",4}}, 1); t2:touch(OX[2] + 88, OY + 198, {pressure=0.6}); t2:reload(pile{{"zinc white",4}}, 1); t2:touch(OX[2] + 99, OY + 198, {pressure=0.6})
