-- easel session "lantern": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={18,16}, seed=6464,
  ground={{pile={{"bone black",1},{"burnt sienna",0.9},{"ultramarine blue",0.3},{"lead white",0.4}}, um=110, apply="knife", texture=0.4}}}
-- one-point down a long bronze gallery; floor at Y = 1.6, walls at X = +-2.4, a low barrel vault to 4.2 m
VX, VY, F = 470, 250, 470
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY, HW, WH, ZN, ZE = 1.6, 2.4, 3.0, 0.8, 60
local function quad(a, b, c, d) return poly({a, b, c, d}) end
FLOOR = quad(pt(-HW, FY, ZN), pt(HW, FY, ZN), pt(HW, FY, ZE), pt(-HW, FY, ZE)) + rect(0, 520, 1000, 60)
LW = quad(pt(-HW, FY, ZN), pt(-HW, FY, ZE), pt(-HW, FY - WH, ZE), pt(-HW, FY - WH, ZN))
RW = quad(pt(HW, FY, ZN), pt(HW, FY, ZE), pt(HW, FY - WH, ZE), pt(HW, FY - WH, ZN))
VAULT = everywhere() - FLOOR - LW - RW
-- lamps hang along the gallery's right side at X = 1.5, 2.55 m up; the docent lights the one at Z 4.4; the nearer ones are dark
LAMPZ = {1.6, 2.9, 4.4, 6.2, 8.4, 11.2, 14.6, 19, 24.5, 31, 39, 49}
LITFROM = 4.4
local dk = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
local wl = {
  {ZN, 4, pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.25}, medium=0.06}},
  {4, 12, pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}},
  {12, ZE, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}, medium=0.06}},
}
local function zband(z0, z1) return quad(pt(-30, -30, z0), pt(30, -30, z0), pt(30, -30, z1), pt(-30, -30, z1)) + quad(pt(-30, 30, z0), pt(30, 30, z0), pt(30, 30, z1), pt(-30, 30, z1)) end
for _, b in ipairs(wl) do
  local inner = quad(pt(-HW, FY, b[2]), pt(HW, FY, b[2]), pt(HW, FY - WH - 2, b[2]), pt(-HW, FY - WH - 2, b[2]))
  local outer = (b[1] <= ZN) and everywhere() or quad(pt(-HW, FY, b[1]), pt(HW, FY, b[1]), pt(HW, FY - WH - 2, b[1]), pt(-HW, FY - WH - 2, b[1]))
  local m = outer - inner
  work(m * (LW + RW + FLOOR), {hand="body", tool="filbert 10", pile=b[3], coverage=4, fill=true, clip=m * (LW + RW + FLOOR), angle=function(x, y) return math.atan(VY - y, VX - x) end, load=1})
  work(m * VAULT, {hand="body", tool="filbert 10", pile=dk, coverage=4, fill=true, clip=m * VAULT, angle=function(x, y) return math.atan(VY - y, VX - x) end, load=1})
end
local endm = quad(pt(-HW, FY, 12), pt(HW, FY, 12), pt(HW, FY - WH - 2, 12), pt(-HW, FY - WH - 2, 12))
print(W, H, P(1.5, FY - 2.55, 4.4))

--@ chunk 2
-- the lay-in came out as boxes (cross-section masks): repaint per surface in depth bands — walls, floor, ceiling — so the
-- gallery recedes; near dark, the lit far reach a warm bronze
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local function quad(a, b, c, d) return poly({a, b, c, d}) end
CY = FY - WH
local function surf(kind, z0, z1)
  if kind == "L" then return quad(pt(-HW, FY, z0), pt(-HW, FY, z1), pt(-HW, CY, z1), pt(-HW, CY, z0))
  elseif kind == "R" then return quad(pt(HW, FY, z0), pt(HW, FY, z1), pt(HW, CY, z1), pt(HW, CY, z0))
  elseif kind == "F" then return quad(pt(-HW, FY, z0), pt(HW, FY, z0), pt(HW, FY, z1), pt(-HW, FY, z1))
  else return quad(pt(-HW, CY, z0), pt(HW, CY, z0), pt(HW, CY, z1), pt(-HW, CY, z1)) end
end
SURF = surf
local bands = {
  {0.5, 3.6, pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}},
  {3.6, 7, pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}},
  {7, 16, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.7},{"yellow ochre",0.2}, medium=0.06}},
  {16, ZE, pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.6},{"bone black",0.45}, medium=0.06}},
}
local ceilP = {
  pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.06},
  pile{{"bone black",1.8},{"burnt sienna",0.7}, medium=0.06},
  pile{{"bone black",1.4},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06},
  pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.7}, medium=0.06},
}
for i, b in ipairs(bands) do
  local m = surf("L", b[1], b[2]) + surf("R", b[1], b[2]) + surf("F", b[1], b[2])
  work(m, {hand="body", tool="filbert 9", pile=b[3], coverage=5, fill=true, clip=m, angle=toVP, load=1})
  local c = surf("C", b[1], b[2])
  work(c, {hand="body", tool="filbert 9", pile=ceilP[i], coverage=5, fill=true, clip=c, angle=toVP, load=1})
end
local endw = quad(pt(-HW, FY, ZE), pt(HW, FY, ZE), pt(HW, CY, ZE), pt(-HW, CY, ZE))
work(endw, {hand="detail", pile=pile{{"yellow ochre",1},{"lead white",0.6},{"raw sienna",0.4}, medium=0.06}, coverage=5, fill=true, clip=endw, load=1})
for _, z in ipairs{3.6, 7, 16} do
  local m = (surf("L", z - 0.3 * z / 4, z + 0.3 * z / 4) + surf("R", z - 0.3 * z / 4, z + 0.3 * z / 4) + surf("F", z - 0.3 * z / 4, z + 0.3 * z / 4) + surf("C", z - 0.3 * z / 4, z + 0.3 * z / 4))
  blend(m, {angle=toVP})
end

--@ chunk 3
-- transverse bronze ribs at uneven depths, three of them exactly on the band seams; the corner lines where walls meet floor
-- and ceiling; the floor a step darker than the walls
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fl = {
  {0.5, 3.6, pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.35}, medium=0.06}},
  {3.6, 7, pile{{"bone black",1.7},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}},
  {7, 16, pile{{"bone black",1.1},{"burnt sienna",1},{"raw sienna",0.6}, medium=0.06}},
  {16, ZE, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06}},
}
for _, b in ipairs(fl) do local m = SURF("F", b[1], b[2]); work(m, {hand="body", tool="filbert 9", pile=b[3], coverage=5, fill=true, clip=m, angle=toVP, load=1}) end
local rib = pile{{"bone black",2},{"burnt sienna",0.7}, medium=0.06}
RIBZ = {2.2, 3.6, 5.3, 7, 9.6, 12.6, 16, 21, 27, 35, 45}
for _, Z in ipairs(RIBZ) do
  local w = math.max(1.5, 0.28 * F / Z)
  local frame = {pt(-HW, FY, Z), pt(-HW, CY, Z), pt(HW, CY, Z), pt(HW, FY, Z)}
  for j = 1, 3 do
    local b = brush{kind="flat", width=w, stiffness=0.6}
    b:load(rib, 1); b:stroke({frame[j], frame[j + 1]}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across"})
  end
end
local corner = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}
for _, c in ipairs{{-HW, FY}, {HW, FY}, {-HW, CY}, {HW, CY}} do
  local b = brush{kind="round", width=4, stiffness=0.6}
  b:load(corner, 1); b:stroke({pt(c[1], c[2], 0.6), pt(c[1], c[2], ZE)}, {pressure={0.9, 0.3}})
end

--@ chunk 4
-- after setting: ribs restated solid as masks; then the lamps. Lit ones (Z >= 4.4): a warm pool on the right wall and
-- floor below each, a bone shade glowing in a bronze cage. Dark ones nearer: the cage only, dim
print(wait(4*24*60))
local rib = pile{{"bone black",2},{"burnt sienna",0.7}, medium=0.06}
RIBM = nil
for _, Z in ipairs(RIBZ) do
  local w = math.max(1.5, 0.26 * F / Z)
  local r = ribbon({pt(-HW, FY, Z), pt(-HW, CY, Z), pt(HW, CY, Z), pt(HW, FY, Z)}, w)
  RIBM = RIBM and (RIBM + r) or r
end
work(RIBM, {hand="detail", pile=rib, coverage=6, fill=true, clip=RIBM, load=1})
-- pools of lamplight on the right wall and the floor beneath each lit lamp (two steps, soft)
local p1 = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.25}, medium=0.06}
local p2 = pile{{"yellow ochre",1.2},{"lead white",0.8},{"raw sienna",0.3}, medium=0.06}
local function wallpool(Z, r, h)
  local t = {}
  for j = 0, 19 do local a = 2 * math.pi * j / 20; t[#t+1] = pt(HW, FY - 2.4 + h * math.sin(a), Z + r * math.cos(a)) end
  return poly(t, true)
end
local function floorpool(Z, r)
  local t = {}
  for j = 0, 19 do local a = 2 * math.pi * j / 20; t[#t+1] = pt(1.5 + 0.9 * math.cos(a), FY, Z + r * math.sin(a)) end
  return poly(t, true)
end
local RW2 = SURF("R", 0.6, ZE); local FL2 = SURF("F", 0.6, ZE)
for i = #LAMPZ, 1, -1 do
  local Z = LAMPZ[i]
  if Z >= LITFROM and Z < 40 then
    local A = wallpool(Z, 1.6, 1.4) * RW2 - RIBM
    local B = wallpool(Z, 0.8, 0.7) * RW2 - RIBM
    local wv = {kind="filbert", width=math.max(1.2, math.min(6, 0.25 * F / Z))}
    work(A - B, {hand="body", tool=wv, pile=p1, coverage=4, fill=true, clip=A - B, angle=math.pi/2, load=0.9})
    work(B, {hand="body", tool=wv, pile=p2, coverage=4, fill=true, clip=B, angle=math.pi/2, load=0.9})
    blend(A:grow(4) - B:shrink(3) - RIBM)
    local fA = floorpool(Z, 1.3) * FL2
    work(fA, {hand="body", tool=wv, pile=p1, coverage=4, fill=true, clip=fA, angle=0, load=0.8})
    blend(fA:grow(4) - fA:shrink(4))
  end
end

--@ chunk 5
-- the floor pools came out as hard ovals: floor repainted, then the lamps' light laid as one long warm band along the floor
-- at the right wall, fading toward the middle and toward us; the near end of the first wall pool knocked back into dark
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fl = {
  {0.5, 3.6, pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.35}, medium=0.06}},
  {3.6, 7, pile{{"bone black",1.7},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}},
  {7, 16, pile{{"bone black",1.1},{"burnt sienna",1},{"raw sienna",0.6}, medium=0.06}},
  {16, ZE, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06}},
}
for _, b in ipairs(fl) do local m = SURF("F", b[1], b[2]) - RIBM; work(m, {hand="body", tool="filbert 9", pile=b[3], coverage=6, fill=true, clip=m, angle=toVP, load=1}) end
local function strip(x0, x1, z0, z1) return poly({pt(x0, FY, z0), pt(x1, FY, z0), pt(x1, FY, z1), pt(x0, FY, z1)}) end
local a = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.25}, medium=0.06}
local b = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.3}, medium=0.06}
local A = strip(0.6, HW, 3.4, 40) - RIBM
local B = strip(1.3, HW, 3.9, 40) - RIBM
work(A - B, {hand="body", tool="filbert 4", pile=a, coverage=5, fill=true, clip=A - B, angle=toVP, load=1})
work(B, {hand="body", tool="filbert 4", pile=b, coverage=5, fill=true, clip=B, angle=toVP, load=1})
blend((strip(0.4, 0.9, 3.4, 40) + strip(1.1, 1.5, 3.9, 40)) - RIBM, {angle=toVP})
blend(strip(0.4, HW, 3.0, 4.4) - RIBM, {angle=0})
-- the wall pool's near end beyond the rib at 3.6 laid back to the dark
local near = SURF("R", 0.6, 3.5) - RIBM
work(near, {hand="body", tool="filbert 8", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}, coverage=6, fill=true, clip=near, angle=toVP, load=1})
local nearF = SURF("F", 0.6, 3.3) - RIBM
work(nearF * strip(0.3, HW, 0.6, 3.3), {hand="body", tool="filbert 8", pile=fl[1][3], coverage=6, fill=true, clip=nearF, angle=toVP, load=1})

--@ chunk 6
-- the floor band went lumpy: one plain warm strip, laid straight along the floor, no blend; the stray stroke at top right out;
-- then the lamps themselves: a bronze cage on a chain, the bone shade glowing in the lit ones, dark in the near ones
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local function strip(x0, x1, z0, z1) return poly({pt(x0, FY, z0), pt(x1, FY, z0), pt(x1, FY, z1), pt(x0, FY, z1)}) end
local S1 = strip(0.7, HW, 3.6, 40) - RIBM
local S2 = strip(1.4, HW, 4.2, 40) - RIBM
work(S1 - S2, {hand="body", tool="filbert 4", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.7},{"yellow ochre",0.2}, medium=0.06}, coverage=6, fill=true, clip=S1 - S2, angle=toVP, load=1})
work(S2, {hand="body", tool="filbert 4", pile=pile{{"raw sienna",1},{"yellow ochre",0.7},{"burnt sienna",0.5},{"lead white",0.25}, medium=0.06}, coverage=6, fill=true, clip=S2, angle=toVP, load=1})
local st = rect(780, 0, 120, 70)
work(st, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}, coverage=6, fill=true, clip=st, angle=0, load=1})
local chainP = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local cageP = pile{{"bone black",1.5},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}
local shadeL = pile{{"lead white",2},{"yellow ochre",0.5},{"cadmium yellow",0.25}, medium=0.05}
local shadeD = pile{{"lead white",0.7},{"bone black",0.8},{"yellow ochre",0.3},{"burnt sienna",0.2}, medium=0.06}
local core = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}, medium=0.04}
LAMPS = {}
for i = #LAMPZ, 1, -1 do
  local Z = LAMPZ[i]
  local k = F / Z
  local x, y = P(1.5, FY - 2.55, Z)
  local _, yc = P(1.5, CY, Z)
  local cb = brush{kind="round", width=math.max(0.6, 0.015 * k), point=0.3}
  cb:load(chainP, 0.9); cb:stroke({{x, yc}, {x, y - 0.12 * k}}, {pressure={0.8, 0.8}})
  local shade = poly({{x - 0.07 * k, y - 0.12 * k}, {x + 0.07 * k, y - 0.12 * k}, {x + 0.1 * k, y + 0.1 * k}, {x - 0.1 * k, y + 0.1 * k}}, true)
  local lit = Z > LITFROM + 0.1
  work(shade, {hand="detail", pile=lit and shadeL or shadeD, coverage=6, fill=true, clip=shade, load=1})
  if lit then
    local c = ellipse(x, y + 0.02 * k, 0.04 * k, 0.05 * k)
    work(c, {hand="detail", pile=core, coverage=6, fill=true, clip=c, load=1})
  end
  -- the cage: bronze bars over the shade, a cap and a finial
  for _, dx in ipairs{-0.09, 0, 0.09} do
    local b = brush{kind="round", width=math.max(0.6, 0.012 * k), point=0.3}
    b:load(cageP, 0.9); b:stroke({{x + dx * 0.7 * k, y - 0.14 * k}, {x + dx * k, y + 0.12 * k}}, {pressure={0.7, 0.7}})
  end
  local cap = brush{kind="flat", width=math.max(0.8, 0.03 * k)}
  cap:load(cageP, 0.9); cap:stroke({{x - 0.09 * k, y - 0.14 * k}, {x + 0.09 * k, y - 0.14 * k}}, {pressure={0.8, 0.8}, orient="across"})
  cap:load(cageP, 0.9); cap:stroke({{x - 0.11 * k, y + 0.12 * k}, {x + 0.11 * k, y + 0.12 * k}}, {pressure={0.8, 0.8}, orient="across"})
  LAMPS[i] = {x=x, y=y, k=k, Z=Z}
end

--@ chunk 7
-- the docent walking toward us, mid-step, reaching up with its long pole to the next lamp; backlit by the lit row behind it,
-- its front in shadow; a flame at the pole's tip at the lamp. Far behind, small in the lit reach, the Commando following.
print(wait(2*24*60))
local Z = 4.0
local k = F / Z
local fx, fy = P(0.55, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local robeD = pile{{"bone black",1.8},{"burnt sienna",0.8},{"ultramarine blue",0.2}, medium=0.06}
-- bell robe, the hem lifted forward by the striding foot
ROBE = poly({Q(-0.1, 1.5), Q(0.12, 1.5), Q(0.28, 0.6), Q(0.36, 0.06), Q(0.12, 0.0), Q(-0.18, 0.03), Q(-0.34, 0.08), Q(-0.24, 0.7)}, true)
work(ROBE, {hand="body", tool="filbert 5", pile=robeD, coverage=7, fill=true, clip=ROBE, angle=math.pi/2, load=1})
local foot = poly({Q(0.12, 0.0), Q(0.32, -0.02), Q(0.3, 0.08), Q(0.12, 0.08)})
work(foot, {hand="detail", pile=robeD, coverage=6, fill=true, clip=foot, load=1})
HEADM = ellipse(fx + 0.02 * k, fy - 1.66 * k, 0.12 * k, 0.15 * k)
work(HEADM, {hand="detail", pile=robeD, coverage=7, fill=true, clip=HEADM, load=1})
FACE = ellipse(fx + 0.04 * k, fy - 1.66 * k, 0.065 * k, 0.1 * k)
work(FACE, {hand="detail", pile=pile{{"lead white",0.8},{"yellow ochre",0.4},{"bone black",0.5},{"burnt sienna",0.2}, medium=0.06}, coverage=6, fill=true, clip=FACE, load=1})
-- both arms up to the pole
ARMS = ribbon({Q(0.08, 1.42), Q(0.3, 1.62), Q(0.42, 1.85)}, {0.1 * k, 0.08 * k, 0.07 * k}) + ribbon({Q(0.1, 1.2), Q(0.26, 1.38), Q(0.34, 1.6)}, {0.09 * k, 0.08 * k, 0.07 * k})
work(ARMS, {hand="detail", pile=robeD, coverage=7, fill=true, clip=ARMS, load=1})
-- the pole: from low behind the hands up to the lamp
local L = LAMPS[3]
local tip = {L.x - 0.02 * L.k, L.y + 0.16 * L.k}
local base = Q(0.2, 0.9)
local pb = brush{kind="round", width=2.6, stiffness=0.7}
pb:load(pile{{"bone black",1.5},{"burnt sienna",1}, medium=0.06}, 1)
pb:stroke({base, tip}, {pressure={0.9, 0.7}, ramps={0.02, 0.02}})
POLE = {base, tip}
-- the flame at its tip, and the lamp just catching
local fl = ellipse(tip[1], tip[2] - 5, 4, 8)
work(fl, {hand="detail", pile=pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}, medium=0.04}, coverage=6, fill=true, clip=fl, load=1})
local fc = ellipse(tip[1], tip[2] - 4, 1.8, 4)
work(fc, {hand="detail", pile=pile{{"zinc white",3}, medium=0.03}, coverage=6, fill=true, clip=fc, load=1})
-- the Commando far behind in the lit reach
local z2 = 21
local k2 = F / z2
local gx, gy = P(-0.5, FY, z2)
local function R(x, y) return {gx + x * k2, gy - y * k2} end
local fig = ribbon({R(-0.1, 0.93), R(-0.12, 0.1)}, {0.17 * k2, 0.11 * k2}) + ribbon({R(0.1, 0.93), R(0.12, 0.1)}, {0.17 * k2, 0.11 * k2})
  + poly({R(-0.2, 0.88), R(0.2, 0.88), R(0.3, 1.5), R(0.27, 1.6), R(-0.27, 1.6), R(-0.3, 1.5)}, true)
  + ellipse(gx, gy - 1.76 * k2, 0.11 * k2, 0.13 * k2)
  + ribbon({R(-0.3, 1.5), R(-0.33, 1.0)}, 0.1 * k2) + ribbon({R(0.3, 1.5), R(0.33, 1.0)}, 0.1 * k2)
work(fig, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=7, fill=true, clip=fig, load=1})
DK, DX, DY = k, fx, fy

--@ chunk 8
-- on set paint: the docent restated opaque as dark bronze; warm back-light rimming its hood, shoulders, raised arms and the
-- robe's edges; the pole thicker with a lit edge; the flame with a small glow; a cold lens in the shadowed face
print(wait(4*24*60))
local k, fx, fy = DK, DX, DY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local all = ROBE + HEADM + ARMS - FACE
local robe = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
work(all, {hand="body", tool="filbert 4", pile=robe, coverage=7, fill=true, clip=all, angle=math.pi/2, load=1})
local faceP = pile{{"lead white",0.9},{"yellow ochre",0.4},{"bone black",0.5},{"burnt sienna",0.2}, medium=0.06}
work(FACE, {hand="detail", pile=faceP, coverage=6, fill=true, clip=FACE, load=1})
print(wait(2*24*60))
local rim = pile{{"lead white",1.6},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.05}
local rimW = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.5}, medium=0.06}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, clip=clipm})
end
local C = (ROBE + HEADM + ARMS):grow(1.5)
ln({Q(-0.1, 1.72), Q(-0.04, 1.8), Q(0.06, 1.81), Q(0.13, 1.72)}, rim, 2.6, {0.7, 0.9}, C)
ln({Q(-0.1, 1.5), Q(-0.2, 1.1), Q(-0.27, 0.6), Q(-0.33, 0.1)}, rimW, 2.2, {0.8, 0.2}, C)
ln({Q(0.12, 1.5), Q(0.22, 1.1), Q(0.29, 0.6), Q(0.36, 0.08)}, rimW, 1.8, {0.6, 0.2}, C)
ln({Q(0.08, 1.48), Q(0.3, 1.68), Q(0.42, 1.9)}, rim, 1.8, {0.6, 0.9}, C)
ln({Q(0.12, 1.26), Q(0.27, 1.43), Q(0.35, 1.64)}, rimW, 1.4, {0.5, 0.7}, C)
-- the pole, its lit edge
local base, tip = POLE[1], POLE[2]
local pb = brush{kind="round", width=3.4, stiffness=0.7}
pb:load(pile{{"bone black",1.4},{"burnt sienna",1}, medium=0.06}, 1); pb:stroke({base, tip}, {pressure={0.9, 0.8}, ramps={0.02, 0.02}})
local lb = brush{kind="round", width=1.2, point=0.4}
lb:load(rim, 0.9); lb:stroke({{base[1] - 1.2, base[2]}, {tip[1] - 1.2, tip[2]}}, {pressure={0.3, 0.8}})
-- the flame and a small glow round it
local g = ellipse(tip[1], tip[2] - 6, 22, 22) - ellipse(tip[1], tip[2] - 5, 5, 9)
stipple(g, {pile=pile{{"yellow ochre",1},{"lead white",0.8},{"cadmium yellow",0.3}, medium=0.05}, width=1, coverage=function(x, y) local d = math.sqrt((x - tip[1])^2 + (y - tip[2] + 6)^2) / 22; return clamp(1 - d, 0, 1)^1.6 * 3 end, feather=0.9, cluster=0.1})
local fl = ellipse(tip[1], tip[2] - 6, 4.5, 9)
work(fl, {hand="detail", pile=pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.2}, medium=0.04}, coverage=6, fill=true, clip=fl, load=1})
local fc = ellipse(tip[1], tip[2] - 4, 2, 4.5)
work(fc, {hand="detail", pile=pile{{"zinc white",3}, medium=0.03}, coverage=6, fill=true, clip=fc, load=1})
-- the lens
local ls = ellipse(fx + 0.06 * k, fy - 1.68 * k, 2.4, 2.4)
work(ls, {hand="detail", pile=pile{{"zinc white",2.5},{"cerulean blue",0.1}, medium=0.04}, coverage=6, fill=true, clip=ls, load=1})

--@ chunk 9
-- pass, 1 (dry): the near corridor (Z < 3.6) repainted as dark bronze surfaces instead of a black border; the right wall's
-- bays up to the docent back to dark bronze; the lumpy floor band painted out to floor
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local DOC = (ROBE + HEADM + ARMS):grow(2) + ribbon(POLE, 6)
local wallN = pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.25}, medium=0.06}
local ceilN = pile{{"bone black",1.8},{"burnt sienna",0.7}, medium=0.06}
local floorN = pile{{"bone black",1.7},{"burnt sienna",0.8},{"ultramarine blue",0.2}, medium=0.06}
local W = (SURF("L", 0.5, 3.6) + SURF("R", 0.5, 5.3)) - RIBM - DOC
work(W, {hand="body", tool="filbert 9", pile=wallN, coverage=6, fill=true, clip=W, angle=toVP, load=1})
local C = SURF("C", 0.5, 3.6) - RIBM - DOC
work(C, {hand="body", tool="filbert 9", pile=ceilN, coverage=6, fill=true, clip=C, angle=toVP, load=1})
local Fn = SURF("F", 0.5, 4.2) - RIBM - DOC
work(Fn, {hand="body", tool="filbert 9", pile=floorN, coverage=6, fill=true, clip=Fn, angle=toVP, load=1})
local fl = {
  {4.2, 7, pile{{"bone black",1.7},{"burnt sienna",0.9},{"raw sienna",0.2}, medium=0.06}},
  {7, 16, pile{{"bone black",1.1},{"burnt sienna",1},{"raw sienna",0.6}, medium=0.06}},
  {16, ZE, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06}},
}
for _, b in ipairs(fl) do
  local m = SURF("F", b[1], b[2]) - RIBM - DOC
  work(m, {hand="body", tool="filbert 6", pile=b[3], coverage=6, fill=true, clip=m, angle=toVP, load=1})
end

--@ chunk 10
-- pass, 2 (dry): near ribs and corners restated so the dark near corridor reads; soft warm pools on the floor under each lit
-- lamp, shrinking with distance; the just-caught lamp's small glow on the wall; a warm rim on the docent's back and hood
print(wait(4*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local DOC = (ROBE + HEADM + ARMS):grow(2) + ribbon(POLE, 6)
local rib = pile{{"bone black",2},{"burnt sienna",0.5}, medium=0.06}
local ribL = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.8}, medium=0.06}
for _, Z in ipairs{1.2, 2.2, 3.6} do
  local w = math.max(1.5, 0.26 * F / Z)
  local r = ribbon({pt(-HW, FY, Z), pt(-HW, CY, Z), pt(HW, CY, Z), pt(HW, FY, Z)}, w) - DOC
  work(r, {hand="detail", pile=rib, coverage=6, fill=true, clip=r, load=1})
  -- a dull warm lip on the far face of each near rib, from the lit hall beyond
  local lip = brush{kind="round", width=math.max(1, 0.03 * F / Z), point=0.3}
  lip:load(ribL, 0.85)
  lip:stroke({pt(-HW + 0.02, FY, Z + 0.15), pt(-HW + 0.02, CY + 0.02, Z + 0.15), pt(HW - 0.02, CY + 0.02, Z + 0.15)}, {pressure={0.5, 0.5}, clip=-DOC})
end
local corner = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}
for _, c in ipairs{{-HW, FY}, {HW, FY}, {-HW, CY}, {HW, CY}} do
  local b = brush{kind="round", width=5, stiffness=0.6}
  b:load(corner, 1); b:stroke({pt(c[1], c[2], 0.55), pt(c[1], c[2], 4)}, {pressure={0.9, 0.6}, clip=-DOC})
end
-- floor pools under the lit lamps (Z >= 6.2): two soft steps each, drawn small and long
local p1 = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local p2 = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.3}, medium=0.06}
local function fp(Z, rx, rz)
  local t = {}
  for j = 0, 19 do local a = 2 * math.pi * j / 20; t[#t+1] = pt(1.45 + rx * math.cos(a), FY, Z + rz * math.sin(a)) end
  return poly(t, true)
end
for i = #LAMPZ, 1, -1 do
  local Z = LAMPZ[i]
  if Z >= 6 and Z < 40 then
    local A = fp(Z, 0.75, 1.1) - RIBM - DOC
    local B = fp(Z, 0.4, 0.55) - RIBM - DOC
    local wv = {kind="filbert", width=math.max(1, math.min(5, 0.18 * F / Z))}
    work(A - B, {hand="body", tool=wv, pile=p1, coverage=4, fill=true, clip=A - B, angle=toVP, load=0.85})
    work(B, {hand="body", tool=wv, pile=p2, coverage=4, fill=true, clip=B, angle=toVP, load=0.85})
    blend((fp(Z, 0.85, 1.3) - fp(Z, 0.55, 0.8)) - RIBM - DOC, {angle=toVP})
    blend((fp(Z, 0.48, 0.7) - fp(Z, 0.3, 0.4)) - RIBM - DOC, {angle=toVP})
  end
end
-- the just-caught lamp: a small warm glow on the wall behind it
local L = LAMPS[3]
local g = ellipse(L.x + 0.15 * L.k, L.y, 0.55 * L.k, 0.45 * L.k) * SURF("R", 3.7, 5.2) - RIBM - DOC
stipple(g, {pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.4},{"bone black",0.4}, medium=0.06}, width=1.2, coverage=function(x, y) local d = math.sqrt(((x - L.x - 0.15 * L.k) / (0.55 * L.k))^2 + ((y - L.y) / (0.45 * L.k))^2); return clamp(1 - d, 0, 1)^1.4 * 3 end, feather=0.9, cluster=0.1})
-- the docent's back rim: hood crown and the back edges of the robe (its left side, toward the lit hall), thin and warm
local k, fx, fy = DK, DX, DY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local rim = pile{{"lead white",1.8},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.05}
local Cm = (ROBE + HEADM + ARMS):grow(1.5)
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(rim, 0.95); b:stroke(pts, {pressure=pr, clip=Cm})
end
ln({Q(-0.1, 1.74), Q(-0.05, 1.8), Q(0.05, 1.81), Q(0.12, 1.75)}, 2.2, {0.8, 0.8})
ln({Q(-0.11, 1.5), Q(-0.21, 1.1), Q(-0.28, 0.6), Q(-0.34, 0.1)}, 1.8, {0.85, 0.25})
ln({Q(0.32, 1.66), Q(0.42, 1.88)}, 1.6, {0.6, 0.8})
-- the Commando restated (the floor repaint covered his legs)
local z2 = 21
local k2 = F / z2
local gx, gy = P(-0.5, FY, z2)
local function R(x, y) return {gx + x * k2, gy - y * k2} end
local fig = ribbon({R(-0.1, 0.93), R(-0.12, 0.1)}, {0.17 * k2, 0.11 * k2}) + ribbon({R(0.1, 0.93), R(0.12, 0.1)}, {0.17 * k2, 0.11 * k2})
  + poly({R(-0.2, 0.88), R(0.2, 0.88), R(0.3, 1.5), R(0.27, 1.6), R(-0.27, 1.6), R(-0.3, 1.5)}, true)
  + ellipse(gx, gy - 1.76 * k2, 0.11 * k2, 0.13 * k2)
  + ribbon({R(-0.3, 1.5), R(-0.33, 1.0)}, 0.1 * k2) + ribbon({R(0.3, 1.5), R(0.33, 1.0)}, 0.1 * k2)
work(fig, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=7, fill=true, clip=fig, load=1})

--@ chunk 11
-- the caught lamp's glow speckled the whole bay: bay back to dark bronze; a small soft opaque glow just round the lamp instead
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local DOC = (ROBE + HEADM + ARMS):grow(2) + ribbon(POLE, 6)
local L = LAMPS[3]
local bay = SURF("R", 3.7, 5.3) - RIBM - DOC
local lampm = ellipse(L.x, L.y, 0.16 * L.k, 0.2 * L.k) + rect(L.x - 2, 0, 4, L.y)
work(bay - lampm, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"raw sienna",0.25}, medium=0.06}, coverage=6, fill=true, clip=bay - lampm, angle=toVP, load=1})
local g1 = ellipse(L.x + 0.1 * L.k, L.y, 0.42 * L.k, 0.36 * L.k) * bay - lampm
local g2 = ellipse(L.x + 0.06 * L.k, L.y, 0.26 * L.k, 0.22 * L.k) * bay - lampm
work(g1 - g2, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.1},{"burnt sienna",1},{"raw sienna",0.5}, medium=0.06}, coverage=5, fill=true, clip=g1 - g2, angle=0, load=1})
work(g2, {hand="body", tool="filbert 3", pile=pile{{"burnt sienna",1},{"raw sienna",0.9},{"yellow ochre",0.4},{"bone black",0.3}, medium=0.06}, coverage=5, fill=true, clip=g2, angle=0, load=1})
blend((g1:grow(5) - g2:shrink(3)) - lampm, {angle=0})
