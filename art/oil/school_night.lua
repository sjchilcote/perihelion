-- easel session "school_night": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=8123,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.7},{"burnt sienna",0.8},{"lead white",1.1}}, um=120, apply="knife", texture=0.4}}}
-- the Long Gallery's perspective, as in the day painting: VP, focal length, half width, eye, wall height
VX, VY, F = 540, 300, 500
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
HW, EYE, CH = 5, 1.6, 9
FL, TOP = EYE, EYE - CH
ZN, ZF = 1.2, 30
function wallq(side, za, zb, y0, y1)
  local X = side * HW
  return poly({pt(X, y0, za), pt(X, y0, zb), pt(X, y1, zb), pt(X, y1, za)})
end
function doorpts(side, za, zb, sh, rise)
  local X = side * HW
  local t = {pt(X, FL, za), pt(X, FL, zb)}
  for i = 0, 16 do
    local u = i / 16
    local Z = zb + (za - zb) * u
    t[#t+1] = pt(X, FL - sh - rise * math.sin(math.pi * u), Z)
  end
  return t
end
LDOORS = {{5.0, 7.4}, {9.8, 11.5}, {14.6, 16.0}, {21.2, 22.3}}
RDOORS = {{6.6, 9.0}, {12.3, 14.1}, {18.1, 19.6}}
LSH, LRISE, RSH, RRISE = 5.2, 1.5, 4.6, 1.8
function archpts(Z, y0, crown, n, hw)
  local t = {}
  n = n or 24; hw = hw or HW
  for i = 0, n do
    local a = math.pi * i / n
    t[#t+1] = pt(-hw * math.cos(a), y0 - crown * math.sin(a), Z)
  end
  return t
end
local farpts = archpts(ZF, TOP, 3.6)
table.insert(farpts, 1, pt(-HW, FL, ZF)); farpts[#farpts+1] = pt(HW, FL, ZF)
FARWALL = poly(farpts)
LWALL = wallq(-1, ZN, ZF, FL, TOP)
RWALL = wallq(1, ZN, ZF, FL, TOP)
FLOOR = poly({pt(-HW, FL, ZN), pt(-HW, FL, ZF), pt(HW, FL, ZF), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 120)
VAULT = everywhere() - LWALL - RWALL - FARWALL - FLOOR
-- the mirror: an arched glass in the far wall
local mp = {pt(-3.9, FL, ZF)}
for i = 0, 20 do
  local a = math.pi * i / 20
  mp[#mp+1] = pt(-3.9 * math.cos(a), -4.6 - 2.0 * math.sin(a), ZF)
end
mp[#mp+1] = pt(3.9, FL, ZF)
MIRROR = poly(mp)
LOPEN, ROPEN = {}, {}
DOORS = nil
for i, d in ipairs(LDOORS) do LOPEN[i] = poly(doorpts(-1, d[1], d[2], LSH, LRISE)); DOORS = DOORS and (DOORS + LOPEN[i]) or LOPEN[i] end
for i, d in ipairs(RDOORS) do ROPEN[i] = poly(doorpts(1, d[1], d[2], RSH, RRISE)); DOORS = DOORS + ROPEN[i] end
-- the bone runner: X -0.55..0.55
RUNNER = poly({pt(-0.55, FL, ZN), pt(-0.55, FL, ZF), pt(0.55, FL, ZF), pt(0.55, FL, ZN)})
print(W, H, MIRROR:area(), FLOOR:area(), RUNNER:area())
print(P(-3.9, FL, ZF), P(0, -6.6, ZF))

--@ chunk 2
-- lay-in, dark: vault, walls in depth bands (cooler toward the mirror), crossings as voids, floor, far wall, glass
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local vaultP = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}, medium=0.06}
work(VAULT, {hand="body", tool="filbert 12", pile=vaultP, coverage=3.5, fill=true, clip=true, angle=toVP, load=1})
local bands = {
  {ZN, 8, pile{{"bone black",2},{"burnt sienna",0.9},{"ultramarine blue",0.35}, medium=0.06}},
  {8, 16, pile{{"bone black",2},{"burnt sienna",0.8},{"raw sienna",0.3},{"ultramarine blue",0.4},{"lead white",0.08}, medium=0.06}},
  {16, ZF, pile{{"bone black",2},{"ultramarine ash",0.8},{"burnt sienna",0.5},{"lead white",0.25}, medium=0.06}},
}
for _, side in ipairs{-1, 1} do
  for _, b in ipairs(bands) do
    local m = wallq(side, b[1], b[2], FL, TOP) * ((side < 0) and LWALL or RWALL) - DOORS
    work(m, {hand="body", tool="filbert 9", pile=b[3], coverage=3.5, fill=true, clip=m, angle=math.pi/2, angle_jitter=0.12, load=1})
  end
end
local voidP = pile{{"bone black",2},{"ultramarine blue",0.7},{"burnt sienna",0.2}, medium=0.06}
work(DOORS, {hand="body", tool="filbert 7", pile=voidP, coverage=4, fill=true, clip=DOORS, angle=math.pi/2, load=1})
local farP = pile{{"bone black",2},{"ultramarine ash",0.7},{"burnt sienna",0.5},{"lead white",0.2}, medium=0.06}
work(FARWALL - MIRROR, {hand="body", tool="filbert 6", pile=farP, coverage=3.5, fill=true, clip=FARWALL - MIRROR, angle=math.pi/2, load=1})
local fN = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.45}, medium=0.06}
local fF = pile{{"bone black",2},{"ultramarine ash",0.9},{"burnt sienna",0.4},{"lead white",0.25}, medium=0.06}
local split = below(function(x) return 345 end)
work(FLOOR * split, {hand="body", tool="filbert 12", pile=fN, coverage=3.5, fill=true, clip=FLOOR, angle=toVP, load=1})
work(FLOOR - split, {hand="body", tool="filbert 6", pile=fF, coverage=3.5, fill=true, clip=FLOOR - split, angle=toVP, load=1})
local glass = pile{{"zinc white",2},{"ultramarine ash",0.5},{"cerulean blue",0.25},{"bone black",0.08}, medium=0.05}
work(MIRROR, {hand="body", tool="filbert 4", pile=glass, coverage=4, fill=true, clip=MIRROR, angle=math.pi/2, load=1})

--@ chunk 3
-- the mirror's reflected gallery and its cold glow on the far wall; ribs and pilasters
print(wait(2*24*60))
-- inside the glass: the gallery behind us, dim side walls converging on a bright far opening
local mx0, my0 = P(-3.9, FL, ZF); local mx1 = P(3.9, FL, ZF)
local mvx, mvy = 540, 262
local mwall = pile{{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.35},{"lead white",0.4}, medium=0.05}
local mfloor = pile{{"zinc white",1.2},{"ultramarine ash",0.6},{"bone black",0.2},{"lead white",0.6}, medium=0.05}
local core = pile{{"zinc white",3},{"cerulean blue",0.08},{"lemon chrome",0.04}, medium=0.04}
local Lm = poly({{mx0, 200}, {mvx - 18, mvy - 14}, {mvx - 18, mvy + 16}, {mx0, my0}}) * MIRROR
local Rm = poly({{mx1, 200}, {mvx + 18, mvy - 14}, {mvx + 18, mvy + 16}, {mx1, my0}}) * MIRROR
local Fm = poly({{mx0, my0}, {mvx - 18, mvy + 16}, {mvx + 18, mvy + 16}, {mx1, my0}}) * MIRROR
work(Lm + Rm, {hand="body", tool="filbert 3", pile=mwall, coverage=4, fill=true, clip=Lm + Rm, angle=math.pi/2, load=1})
work(Fm, {hand="body", tool="filbert 3", pile=mfloor, coverage=4, fill=true, clip=Fm, angle=0, load=1})
local fa = ellipse(mvx, mvy, 15, 17)
work(fa * MIRROR, {hand="detail", pile=core, coverage=4, fill=true, clip=fa * MIRROR, load=1})
-- the cold glow on the far wall round the glass, in rings
local farP2 = pile{{"bone black",1.4},{"ultramarine ash",0.9},{"lead white",0.7},{"burnt sienna",0.2}, medium=0.06}
local farP3 = pile{{"bone black",1},{"ultramarine ash",0.9},{"lead white",1.1},{"zinc white",0.3}, medium=0.06}
local r1 = (MIRROR:grow(7) - MIRROR) * FARWALL
local r2 = (MIRROR:grow(18) - MIRROR:grow(7)) * FARWALL
work(r2, {hand="body", tool="filbert 3", pile=farP2, coverage=3.5, fill=true, clip=r2, load=0.9})
work(r1, {hand="body", tool="filbert 3", pile=farP3, coverage=3.5, fill=true, clip=r1, load=0.9})
blend((MIRROR:grow(10) - MIRROR:grow(4)) * FARWALL)
blend((MIRROR:grow(21) - MIRROR:grow(15)) * FARWALL)
-- pilasters and vault ribs at uneven depths: dark bronze bands
RIBZ = {2.6, 3.9, 8.2, 12.0, 17.0, 20.5, 24.0, 27.6}
local ribP = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.3},{"lead white",0.12}, medium=0.06}
for _, Z in ipairs(RIBZ) do
  local w = math.max(1.4, 0.32 * F / Z)
  local b = brush{kind="flat", width=w, stiffness=0.6}
  for _, side in ipairs{-1, 1} do
    local top = pt(side * HW, TOP, Z); local bot = pt(side * HW, FL, Z)
    b:load(ribP, 0.95)
    b:stroke({bot, top}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across", clip=-DOORS - FLOOR})
  end
  local ap = archpts(Z, TOP, 3.6, 24)
  local rb = brush{kind="round", width=w, stiffness=0.6}
  rb:load(ribP, 0.95)
  rb:stroke(ap, {pressure={0.85, 0.85}, clip=VAULT})
end

--@ chunk 4
-- ribs and pilasters repainted lean (the raw-sienna mix went ochre); the mirror's cold sheen down the floor; the runner
print(wait(2*24*60))
local ribK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
for _, Z in ipairs(RIBZ) do
  local w = math.max(1.6, 0.36 * F / Z)
  local b = brush{kind="flat", width=w, stiffness=0.6}
  for _, side in ipairs{-1, 1} do
    b:load(ribK, 1)
    b:stroke({pt(side * HW, FL, Z), pt(side * HW, TOP, Z)}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=-DOORS - FLOOR})
  end
  local rb = brush{kind="round", width=w * 1.1, stiffness=0.6}
  rb:load(ribK, 1)
  rb:stroke(archpts(Z, TOP, 3.6, 24), {pressure={0.9, 0.9}, clip=VAULT})
end
-- cold sheen: the glass reflected in the worn floor, a long pale tongue toward us
local sheen = poly({pt(-3.2, FL, ZF), pt(3.2, FL, ZF), pt(1.4, FL, 9), pt(0.9, FL, 4), pt(-0.9, FL, 4), pt(-1.4, FL, 9)}, true) * FLOOR
local s1 = pile{{"bone black",1.2},{"ultramarine ash",1},{"lead white",0.9},{"zinc white",0.4}, medium=0.06}
local s2 = pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.45}, medium=0.06}
local s3 = pile{{"bone black",2},{"ultramarine ash",0.7},{"burnt sienna",0.3},{"lead white",0.2}, medium=0.06}
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local yA, yB = select(2, P(0, FL, 16)), select(2, P(0, FL, 8))
work(sheen * above(function(x) return yA end), {hand="body", tool="filbert 4", pile=s1, coverage=3.5, fill=true, clip=sheen, angle=toVP, load=1})
work(sheen * below(function(x) return yA end) * above(function(x) return yB end), {hand="body", tool="filbert 6", pile=s2, coverage=3.5, fill=true, clip=sheen, angle=toVP, load=1})
work(sheen * below(function(x) return yB end), {hand="body", tool="filbert 8", pile=s3, coverage=3.5, fill=true, clip=sheen, angle=toVP, load=0.9})
blend(sheen * rect(0, yA - 4, 1000, 8), {angle=toVP})
blend(sheen * rect(0, yB - 6, 1000, 12), {angle=toVP})
blend(sheen:rim(6, 3) * FLOOR, {angle=toVP})

--@ chunk 5
-- soften the sheen's edge: an intermediate band across it, then blends across the edge
local sheen = poly({pt(-3.2, FL, ZF), pt(3.2, FL, ZF), pt(1.4, FL, 9), pt(0.9, FL, 4), pt(-0.9, FL, 4), pt(-1.4, FL, 9)}, true) * FLOOR
local edge = (sheen:grow(7) - sheen:shrink(7)) * FLOOR * below(function(x) return 335 end)
local mid = pile{{"bone black",2},{"ultramarine ash",0.8},{"burnt sienna",0.4},{"lead white",0.3}, medium=0.06}
work(edge, {hand="body", tool="filbert 5", pile=mid, coverage=2.5, fill=true, clip=edge, load=0.8, angle=math.pi/2})
blend(edge, {angle=0})
blend(edge, {angle=math.pi/2})

--@ chunk 6
-- the near sheen read as a rug: paint it out below Z~13, back to the floor dark, keep the silver tongue by the glass
print(wait(3*24*60))
local sheen = poly({pt(-3.2, FL, ZF), pt(3.2, FL, ZF), pt(1.4, FL, 9), pt(0.9, FL, 4), pt(-0.9, FL, 4), pt(-1.4, FL, 9)}, true) * FLOOR
local y13 = select(2, P(0, FL, 13))
local m = sheen:grow(12) * FLOOR * below(function(x) return y13 end)
local fN = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.45}, medium=0.06}
local fM = pile{{"bone black",2},{"ultramarine ash",0.7},{"burnt sienna",0.5},{"lead white",0.12}, medium=0.06}
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local y9 = select(2, P(0, FL, 9))
work(m * below(function(x) return y9 end), {hand="body", tool="filbert 8", pile=fN, coverage=5, fill=true, clip=m, angle=toVP, load=1})
work(m * above(function(x) return y9 end), {hand="body", tool="filbert 5", pile=fM, coverage=5, fill=true, clip=m, angle=toVP, load=1})

--@ chunk 7
-- the floor lamps' pools: low bone-white lamps beside the runner at golden-ratio gaps, alternating sides
print(wait(2*24*60))
local L, S = 2.4, 2.4 / 1.618034
local seq = {L, S, L, L, S, L, S, L, L, S, L}
LAMPS = {}
local Z = 2.4
for i = 1, #seq + 1 do
  LAMPS[i] = {X = (i % 2 == 0) and 0.82 or -0.82, Z = Z}
  if seq[i] then Z = Z + seq[i] end
end
local function fl(X0, Z0, r)
  local t = {}
  for k = 0, 31 do
    local a = 2 * math.pi * k / 32
    t[#t+1] = pt(X0 + r * math.cos(a), FL, Z0 + r * 0.85 * math.sin(a))
  end
  return poly(t, true)
end
local pin = pile{{"lead white",2},{"yellow ochre",0.3},{"bone black",0.12}, medium=0.06}
local pmid = pile{{"lead white",1},{"yellow ochre",0.35},{"burnt sienna",0.2},{"bone black",0.6}, medium=0.06}
local pout = pile{{"bone black",1.5},{"burnt sienna",0.55},{"yellow ochre",0.3},{"lead white",0.35}, medium=0.06}
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
for i = #LAMPS, 1, -1 do
  local l = LAMPS[i]
  local o, m, c = fl(l.X, l.Z, 1.5) * FLOOR, fl(l.X, l.Z, 0.95) * FLOOR, fl(l.X, l.Z, 0.45) * FLOOR
  local wv = math.max(1.2, math.min(7, 0.3 * F / l.Z))
  local tool = {kind="filbert", width=wv}
  work(o - m, {hand="body", tool=tool, pile=pout, coverage=3.5, fill=true, clip=o - m, angle=0, load=0.9})
  work(m - c, {hand="body", tool=tool, pile=pmid, coverage=3.5, fill=true, clip=m - c, angle=0, load=0.9})
  work(c, {hand="body", tool=tool, pile=pin, coverage=3.5, fill=true, clip=c, angle=0, load=0.9})
end
for i, l in ipairs(LAMPS) do
  local b1 = (fl(l.X, l.Z, 1.08) - fl(l.X, l.Z, 0.82)) * FLOOR
  local b2 = (fl(l.X, l.Z, 0.55) - fl(l.X, l.Z, 0.36)) * FLOOR
  local b3 = (fl(l.X, l.Z, 1.65) - fl(l.X, l.Z, 1.35)) * FLOOR
  blend(b1 + b2 + b3, {angle=0})
end
print(#LAMPS, LAMPS[#LAMPS].Z)

--@ chunk 8
-- the pools came out as dishes: too big, too bright, ringed. Floor repainted dark, lamps start farther off,
-- and smaller, dimmer pools laid wet into the wet floor so their edges go soft
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fN = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.45}, medium=0.06}
local fM = pile{{"bone black",2},{"ultramarine ash",0.7},{"burnt sienna",0.5},{"lead white",0.12}, medium=0.06}
local y9 = select(2, P(0, FL, 9))
local y17 = select(2, P(0, FL, 17))
local Fl = FLOOR * below(function(x) return y17 end)
work(Fl * below(function(x) return y9 end), {hand="body", tool="filbert 10", pile=fN, coverage=5, fill=true, clip=Fl, angle=toVP, load=1})
work(Fl * above(function(x) return y9 end), {hand="body", tool="filbert 6", pile=fM, coverage=5, fill=true, clip=Fl, angle=toVP, load=1})
local L, S = 2.4, 2.4 / 1.618034
local seq = {S, L, L, S, L, S, L, L, S, L}
LAMPS = {}
local Z = 3.7
for i = 1, #seq + 1 do
  LAMPS[i] = {X = (i % 2 == 0) and 0.8 or -0.8, Z = Z}
  if seq[i] then Z = Z + seq[i] end
end
function FLE(X0, Z0, r)
  local t = {}
  for k = 0, 31 do
    local a = 2 * math.pi * k / 32
    t[#t+1] = pt(X0 + r * math.cos(a), FL, Z0 + r * 0.9 * math.sin(a))
  end
  return poly(t, true)
end
local pout = pile{{"bone black",2},{"burnt sienna",0.6},{"yellow ochre",0.25},{"lead white",0.2}, medium=0.06}
local pmid = pile{{"bone black",1.3},{"burnt sienna",0.4},{"yellow ochre",0.35},{"lead white",0.55}, medium=0.06}
for i = #LAMPS, 1, -1 do
  local l = LAMPS[i]
  local o, m = FLE(l.X, l.Z, 1.0) * FLOOR, FLE(l.X, l.Z, 0.55) * FLOOR
  local wv = math.max(1.2, math.min(5, 0.25 * F / l.Z))
  work(o - m, {hand="body", tool={kind="filbert", width=wv}, pile=pout, coverage=2.5, fill=true, clip=o - m, angle=0, load=0.8})
  work(m, {hand="body", tool={kind="filbert", width=wv}, pile=pmid, coverage=2.5, fill=true, clip=m, angle=0, load=0.8})
end
print(#LAMPS, LAMPS[#LAMPS].Z)

--@ chunk 9
-- break the pools' hard rims: dark stippled in from outside, thickening outward; a pale stippled core
print(wait(2*24*60))
local function floorXZ(x, y) local Z = F * FL / math.max(1, y - VY); return (x - VX) * Z / F, Z end
local dk = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}, medium=0.06}
local lt = pile{{"lead white",1.6},{"yellow ochre",0.3},{"bone black",0.18}, medium=0.06}
for i = #LAMPS, 1, -1 do
  local l = LAMPS[i]
  local w = math.max(0.8, math.min(3.2, 0.11 * F / l.Z))
  local function d(x, y) local X, Z = floorXZ(x, y); return math.sqrt((X - l.X)^2 + ((Z - l.Z) / 0.9)^2) end
  local ring = (FLE(l.X, l.Z, 1.3) - FLE(l.X, l.Z, 0.35)) * FLOOR
  stipple(ring, {pile=dk, width=w, coverage=function(x, y) return clamp((d(x, y) - 0.35) / 0.65, 0, 1) * 3.5 end,
    feather=0.8, cluster=0.25, dips={20, 0.8, 0}})
  local core = FLE(l.X, l.Z, 0.5) * FLOOR
  stipple(core, {pile=lt, width=w, coverage=function(x, y) return clamp(1 - d(x, y) / 0.5, 0, 1) * 2.5 end,
    feather=0.8, cluster=0.2, dips={20, 0.7, 0}})
end

--@ chunk 10
-- pools still read as manhole covers: paint them out; the lamps will light only a small spot each
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fN = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.45}, medium=0.06}
local fM = pile{{"bone black",2},{"ultramarine ash",0.55},{"burnt sienna",0.6},{"lead white",0.06}, medium=0.06}
local y9 = select(2, P(0, FL, 9))
local y17 = select(2, P(0, FL, 17.5))
local Fl = FLOOR * below(function(x) return y17 end)
work(Fl * below(function(x) return y9 end), {hand="body", tool="filbert 10", pile=fN, coverage=5, fill=true, clip=Fl, angle=toVP, load=1})
work(Fl * above(function(x) return y9 end), {hand="body", tool="filbert 6", pile=fM, coverage=5, fill=true, clip=Fl, angle=toVP, load=1})
local far = nil
for _, l in ipairs(LAMPS) do if l.Z > 17 then local e = FLE(l.X, l.Z, 1.15); far = far and (far + e) or e end end
far = far * FLOOR * above(function(x) return y17 end)
local fF = pile{{"bone black",2},{"ultramarine ash",0.9},{"burnt sienna",0.4},{"lead white",0.25}, medium=0.06}
work(far, {hand="body", tool="filbert 3", pile=fF, coverage=5, fill=true, clip=far, angle=0, load=1})

--@ chunk 11
-- the bone runner, then the small floor lamps: a little lit spot each, a short glint toward us, the bone-white dome
print(wait(2*24*60))
local function zw(Z, wm) return math.max(0.7, math.min(8, wm * F / Z)) end
local zs = {1.25, 1.8, 2.6, 3.6, 5, 7, 9.5, 12.5, 16, 20, 25, 30}
local function edgeMask(X, z0, z1)
  local pts, ws = {}, {}
  for _, Z in ipairs(zs) do if Z >= z0 and Z <= z1 then pts[#pts+1] = pt(X, FL, Z); ws[#ws+1] = zw(Z, 0.075) end end
  return ribbon(pts, ws) * FLOOR
end
local boneD = pile{{"lead white",0.9},{"bone black",1},{"yellow ochre",0.3},{"ultramarine ash",0.2}, medium=0.06}
local boneC = pile{{"lead white",1.4},{"zinc white",0.5},{"ultramarine ash",0.35},{"bone black",0.35}, medium=0.06}
for _, X in ipairs{-0.55, 0.55} do
  local a = edgeMask(X, 1.25, 16); local b = edgeMask(X, 16, 30)
  work(a, {hand="detail", pile=boneD, coverage=4, fill=true, clip=a, load=1})
  work(b, {hand="detail", pile=boneC, coverage=4, fill=true, clip=b, load=1})
end
local spot = pile{{"lead white",1.2},{"yellow ochre",0.3},{"bone black",0.45}, medium=0.06}
local spot2 = pile{{"lead white",2},{"yellow ochre",0.25},{"bone black",0.1}, medium=0.06}
local dome = pile{{"lead white",2},{"zinc white",1.2},{"yellow ochre",0.15}, medium=0.05}
for i = #LAMPS, 1, -1 do
  local l = LAMPS[i]
  local o = FLE(l.X, l.Z, 0.38) * FLOOR
  local c = FLE(l.X, l.Z, 0.17) * FLOOR
  work(o, {hand="detail", pile=spot, coverage=3.5, fill=true, clip=o, load=0.9})
  work(c, {hand="detail", pile=spot2, coverage=3.5, fill=true, clip=c, load=0.9})
  -- the glint in the polished floor, running toward us
  local g = brush{kind="round", width=zw(l.Z, 0.05), point=0.6}
  g:load(spot, 0.7)
  g:stroke({pt(l.X, FL, l.Z - 0.2), pt(l.X, FL, l.Z - 0.9)}, {pressure={0.6, 0.05}, clip=FLOOR})
  local x, y = P(l.X, FL - 0.07, l.Z)
  local d = ellipse(x, y, zw(l.Z, 0.11), zw(l.Z, 0.075))
  work(d, {hand="detail", pile=dome, coverage=4, fill=true, clip=d, load=1})
end

--@ chunk 12
-- shrink the lamp spots back to a small bright core; domes larger and whiter
print(wait(2*24*60))
local function zw(Z, wm) return math.max(0.7, math.min(9, wm * F / Z)) end
local fN = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.45}, medium=0.06}
local fM = pile{{"bone black",2},{"ultramarine ash",0.55},{"burnt sienna",0.6},{"lead white",0.06}, medium=0.06}
local dome = pile{{"zinc white",2},{"lead white",1.5},{"yellow ochre",0.12}, medium=0.05}
local glowP = pile{{"lead white",1.5},{"yellow ochre",0.35},{"burnt sienna",0.1},{"bone black",0.25}, medium=0.06}
local RUN = nil
for _, l in ipairs(LAMPS) do
  local ring = (FLE(l.X, l.Z, 0.45) - FLE(l.X, l.Z, 0.2)) * FLOOR
  local pl = (l.Z < 9) and fN or fM
  local wv = math.max(1, math.min(4, 0.12 * F / l.Z))
  work(ring, {hand="body", tool={kind="filbert", width=wv}, pile=pl, coverage=5, fill=true, clip=ring, angle=0, load=1})
end
print(wait(1*24*60))
for _, l in ipairs(LAMPS) do
  local x, y = P(l.X, FL - 0.08, l.Z)
  local h = FLE(l.X, l.Z, 0.24) * FLOOR
  work(h, {hand="detail", pile=glowP, coverage=3, fill=true, clip=h, load=0.8})
  local d = ellipse(x, y, zw(l.Z, 0.15), zw(l.Z, 0.11))
  work(d, {hand="detail", pile=dome, coverage=4, fill=true, clip=d, load=1})
end

--@ chunk 13
-- the runner field faintly silvered by the glass, and the Commando's long shadow cut through it toward us
print(wait(2*24*60))
FIGX, FIGZ = -0.12, 13.5
local function shX(Z) return FIGX * (30 - Z) / (30 - FIGZ) end
local function zw(Z, wm) return math.max(0.7, math.min(8, wm * F / Z)) end
local zs = {1.25, 1.8, 2.6, 3.6, 5, 7, 9.5, 12.5, 16, 20, 25, 30}
local lines = nil
for _, X in ipairs{-0.55, 0.55} do
  local pts, ws = {}, {}
  for _, Z in ipairs(zs) do pts[#pts+1] = pt(X, FL, Z); ws[#ws+1] = zw(Z, 0.075) + 1.2 end
  local r = ribbon(pts, ws); lines = lines and (lines + r) or r
end
local lampm = nil
for _, l in ipairs(LAMPS) do local e = FLE(l.X, l.Z, 0.5); lampm = lampm and (lampm + e) or e end
-- the shadow: from the feet, widening as it comes toward us
local sp, sq = {}, {}
for _, Z in ipairs{FIGZ, 11, 8.5, 6.5, 5, 3.8, 2.8, 2.0, 1.3} do
  local hw = lerp(0.16, 0.62, (FIGZ - Z) / (FIGZ - 1.3))
  sp[#sp+1] = pt(shX(Z) - hw, FL, Z); table.insert(sq, 1, pt(shX(Z) + hw, FL, Z))
end
for _, p in ipairs(sq) do sp[#sp+1] = p end
SHADOW = poly(sp, true) * FLOOR
local field = (RUNNER * FLOOR) - lines - lampm - SHADOW
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local y9 = select(2, P(0, FL, 9))
local sv1 = pile{{"bone black",2},{"ultramarine ash",0.9},{"lead white",0.35},{"burnt sienna",0.2}, medium=0.06}
local sv2 = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.2},{"burnt sienna",0.3}, medium=0.06}
work(field * above(function(x) return y9 end), {hand="body", tool="filbert 3", pile=sv1, coverage=4, fill=true, clip=field, angle=toVP, load=1})
work(field * below(function(x) return y9 end), {hand="body", tool="filbert 6", pile=sv2, coverage=4, fill=true, clip=field, angle=toVP, load=1})
local shP = pile{{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.3}, medium=0.06}
work(SHADOW - lampm:shrink(4), {hand="body", tool="filbert 6", pile=shP, coverage=5, fill=true, clip=SHADOW, angle=toVP, load=1})

--@ chunk 14
-- the Commando from behind, walking toward the glass: a dark armoured silhouette, left foot forward
local k = F / FIGZ
local fx, fy = P(FIGX, FL, FIGZ)
FIGK2, FIGFX2, FIGFY2 = k, fx, fy
local function Q(x, y) return {fx + x*k, fy - y*k} end
local m = ribbon({Q(-0.1,0.93), Q(-0.12,0.52), Q(-0.1,0.16)}, {0.16*k, 0.12*k, 0.1*k})         -- left leg, forward
  + ribbon({Q(0.1,0.93), Q(0.14,0.5), Q(0.2,0.2)}, {0.16*k, 0.12*k, 0.1*k})                      -- right leg, trailing
  + poly({Q(-0.2,0.06), Q(-0.02,0.06), Q(-0.03,0.19), Q(-0.18,0.19)})                             -- left boot (farther: higher)
  + poly({Q(0.12,0.0), Q(0.29,0.03), Q(0.27,0.24), Q(0.14,0.22)})                                 -- right boot, heel lifting
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76*k, 0.105*k, 0.13*k)
  + ellipse(fx - 0.29*k, fy - 1.54*k, 0.12*k, 0.08*k) + ellipse(fx + 0.29*k, fy - 1.54*k, 0.12*k, 0.08*k)
  + ribbon({Q(-0.3,1.5), Q(-0.37,1.25), Q(-0.38,1.0)}, {0.12*k, 0.1*k, 0.09*k})                   -- left arm, swinging back a little
  + ribbon({Q(0.3,1.5), Q(0.34,1.24), Q(0.3,1.0)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.2,1.12), Q(0.33,0.9), Q(0.42,0.6)}, {0.06*k, 0.05*k, 0.035*k})                    -- rifle carried low
FIG = m
local figD = pile{{"bone black",2},{"ultramarine blue",0.35},{"burnt sienna",0.6}, medium=0.06}
work(FIG, {hand="detail", pile=figD, coverage=5, fill=true, clip=FIG, load=1})
print(fx, fy, k)

--@ chunk 15
-- paint out the far brown discs; crossings in the glass, counts swapped (3 left, 4 right); the shadowed bone line
print(wait(2*24*60))
local y17 = select(2, P(0, FL, 17.5))
local band = FLOOR * above(function(x) return y17 + 1 end) * below(function(x) return 330 end) - (RUNNER * FLOOR):grow(1)
local lampc = nil
for _, l in ipairs(LAMPS) do local x, y = P(l.X, FL - 0.08, l.Z); local e = ellipse(x, y, 0.2 * F / l.Z, 0.16 * F / l.Z); lampc = lampc and (lampc + e) or e end
band = band - lampc
local fF = pile{{"bone black",2},{"ultramarine ash",0.9},{"burnt sienna",0.35},{"lead white",0.3}, medium=0.06}
work(band, {hand="body", tool="filbert 3", pile=fF, coverage=5, fill=true, clip=band, angle=0, load=1})
-- reflected crossings: dark slits on the glass's side walls
local mvx, mvy = 540, 262
local mx0 = P(-3.9, FL, ZF); local mx1 = P(3.9, FL, ZF)
local slit = pile{{"bone black",1},{"ultramarine ash",1},{"zinc white",0.6},{"lead white",0.3}, medium=0.05}
local function mwall(side, t0, t1)
  local xa = lerp(side < 0 and mx0 or mx1, mvx + side * 18, t0)
  local xb = lerp(side < 0 and mx0 or mx1, mvx + side * 18, t1)
  local ya0, ya1 = lerp(327, mvy + 16, t0), lerp(327, mvy + 16, t1)
  local ha, hb = lerp(70, 18, t0), lerp(70, 18, t1)
  return poly({{xa, ya0}, {xb, ya1}, {xb, ya1 - hb}, {xa, ya0 - ha}}) * MIRROR
end
for _, t in ipairs{{0.12, 0.3}, {0.45, 0.58}, {0.7, 0.78}} do local s = mwall(-1, t[1], t[2]); work(s, {hand="detail", pile=slit, coverage=4, fill=true, clip=s, load=1}) end
for _, t in ipairs{{0.06, 0.2}, {0.33, 0.45}, {0.56, 0.65}, {0.74, 0.8}} do local s = mwall(1, t[1], t[2]); work(s, {hand="detail", pile=slit, coverage=4, fill=true, clip=s, load=1}) end
-- the bone line under the shadow, dim
local function zw(Z, wm) return math.max(0.7, math.min(8, wm * F / Z)) end
local pts, ws = {}, {}
for _, Z in ipairs{1.25, 1.8, 2.6, 3.6, 5, 7, 9.5, 12.5, 14} do pts[#pts+1] = pt(-0.55, FL, Z); ws[#ws+1] = zw(Z, 0.07) end
local bl = ribbon(pts, ws) * SHADOW
local boneS = pile{{"bone black",1.5},{"lead white",0.5},{"ultramarine ash",0.5},{"yellow ochre",0.1}, medium=0.06}
work(bl, {hand="detail", pile=boneS, coverage=4, fill=true, clip=bl, load=1})

--@ chunk 16
-- the over-solved pedestal chairs, dark bronze in the night, where they stood by day
function CHAIR(X, Z, kind, tilt, sz)
  sz = sz or 1
  local k = F / Z
  local bx, by = P(X, FL, Z)
  local function Q(dx, h) return {bx + dx * k * sz, by - h * k * sz} end
  local m = ellipse(bx, by - 0.01 * k, 0.26 * k * sz, 0.05 * k * sz)                  -- foot
    + poly({Q(-0.035, 0.0), Q(0.035, 0.0), Q(0.03, 0.46), Q(-0.03, 0.46)})            -- stem
    + ellipse(bx, by - 0.48 * k * sz, 0.4 * k * sz, 0.065 * k * sz)                    -- lens seat
  local top
  if kind == "egg" then
    m = m + ellipse(bx + tilt * 0.1 * k * sz, by - 1.02 * k * sz, 0.36 * k * sz, 0.55 * k * sz)
    top = {Q(-0.3 + tilt * 0.1, 1.3), Q(tilt * 0.1, 1.57), Q(0.3 + tilt * 0.1, 1.3)}
  else
    local s = tilt
    m = m + poly({Q(-0.2 + s * 0.05, 0.5), Q(0.2 + s * 0.05, 0.5), Q(0.24 + s * 0.4, 1.45), Q(-0.12 + s * 0.4, 1.5)}, true)
    top = {Q(-0.12 + s * 0.4, 1.5), Q(0.06 + s * 0.4, 1.53), Q(0.24 + s * 0.4, 1.45)}
  end
  return m, top
end
CHAIRS = {
  {X=-1.95, Z=3.7, kind="paddle", tilt=0.5},
  {X=2.55, Z=3.05, kind="egg", tilt=-0.2},
  {X=2.75, Z=8.2, kind="egg", tilt=0.1},
  {X=-3.9, Z=9.5, kind="paddle", tilt=-0.6},
  {X=-1.25, Z=19.5, kind="egg", tilt=0.0},
  {X=-0.85, Z=17.8, kind="paddle", tilt=0.3},
  {X=1.15, Z=18.6, kind="paddle", tilt=-0.3},
  {X=1.7, Z=21.5, kind="egg", tilt=0.0},
}
CHM = nil
local chD = pile{{"bone black",2},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
for i = #CHAIRS, 1, -1 do
  local c = CHAIRS[i]
  local m, top = CHAIR(c.X, c.Z, c.kind, c.tilt)
  c.top = top
  m = m - FIG
  work(m, {hand="detail", pile=chD, coverage=5, fill=true, clip=m, load=1})
  CHM = CHM and (CHM + m) or m
end

--@ chunk 17
-- chairs came out as thin brown ghosts: a heavier, darker coat with a small filbert
print(wait(2*24*60))
local chD = pile{{"bone black",2},{"burnt sienna",0.55},{"ultramarine blue",0.25}, medium=0.06}
for i = #CHAIRS, 1, -1 do
  local c = CHAIRS[i]
  local m = CHAIR(c.X, c.Z, c.kind, c.tilt) - FIG
  local wv = math.max(1.2, math.min(6, 0.1 * F / c.Z))
  work(m, {hand="body", tool={kind="filbert", width=wv}, pile=chD, coverage=5, fill=true, clip=m, load=1, angle=math.pi/2})
end

--@ chunk 18
-- cold edge light from the glass: chair backs, the Commando's outline, crossing jambs, rib undersides near the end
print(wait(2*24*60))
local cold = pile{{"zinc white",1.5},{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.15}, medium=0.05}
local coldD = pile{{"lead white",0.8},{"ultramarine ash",0.8},{"bone black",0.8},{"zinc white",0.3}, medium=0.06}
local warmL = pile{{"lead white",1.2},{"yellow ochre",0.4},{"burnt sienna",0.2},{"bone black",0.3}, medium=0.06}
local function line(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr, swell={0.6, 1, 0.7}, shake=0.15, clip=clipm})
end
-- chairs
for _, c in ipairs(CHAIRS) do
  local k = F / c.Z
  local bx, by = P(c.X, FL, c.Z)
  local w = math.max(0.8, math.min(3, 0.03 * k))
  local m = CHAIR(c.X, c.Z, c.kind, c.tilt)
  local inward = (c.X < 0) and 1 or -1
  if c.kind == "egg" then
    local cx, cy = bx + c.tilt * 0.1 * k, by - 1.02 * k
    local pts = {}
    for a = 0, 8 do
      local th = math.pi * (1.15 + 0.7 * a / 8)
      pts[#pts+1] = {cx + 0.33 * k * math.cos(th), cy + 0.52 * k * math.sin(th)}
    end
    line(pts, cold, w, {0.3, 0.8}, m)
    local side = {}
    for a = 0, 6 do
      local th = (inward > 0) and (-0.3 + 0.9 * a / 6) or (math.pi + 0.3 - 0.9 * a / 6)
      side[#side+1] = {cx + 0.33 * k * math.cos(th), cy + 0.52 * k * math.sin(th)}
    end
    line(side, coldD, w * 0.8, {0.6, 0.15}, m)
  else
    line(c.top, cold, w, {0.5, 0.8}, m)
  end
  -- the lens seat's rim and its lamp-warmed underside
  line({{bx - 0.38 * k, by - 0.49 * k}, {bx, by - 0.545 * k}, {bx + 0.38 * k, by - 0.49 * k}}, coldD, w * 0.8, {0.5, 0.5}, m)
  line({{bx - 0.3 * k, by - 0.44 * k}, {bx + 0.3 * k, by - 0.44 * k}}, warmL, w * 0.7, {0.3, 0.3}, m)
end
-- the Commando: edge light just inside the outline, both sides, fading down the legs
local k, fx, fy = FIGK2, FIGFX2, FIGFY2
local function Q(x, y) return {fx + x*k, fy - y*k} end
line({Q(-0.08,1.86), Q(0.0,1.895), Q(0.08,1.86)}, cold, 1.3, {0.8, 0.8}, FIG)
line({Q(0.1,1.6), Q(0.3,1.6), Q(0.39,1.52), Q(0.4,1.3), Q(0.36,1.02)}, cold, 1.2, {0.8, 0.3}, FIG)
line({Q(-0.1,1.6), Q(-0.3,1.6), Q(-0.4,1.52), Q(-0.43,1.25), Q(-0.43,1.0)}, cold, 1.2, {0.8, 0.3}, FIG)
line({Q(0.17,0.92), Q(0.2,0.55), Q(0.26,0.25)}, coldD, 1.0, {0.5, 0.15}, FIG)
line({Q(-0.17,0.92), Q(-0.18,0.52), Q(-0.15,0.2)}, coldD, 1.0, {0.5, 0.15}, FIG)
-- crossing jambs: the edge toward the vanishing point catches the glass
for i, d in ipairs(LDOORS) do
  local t = {}
  for j = 0, 8 do t[#t+1] = pt(-HW, FL - LSH * (j / 8), d[2]) end
  line(t, coldD, math.max(0.8, 0.06 * F / d[2]), {0.2, 0.5})
end
for i, d in ipairs(RDOORS) do
  local t = {}
  for j = 0, 8 do t[#t+1] = pt(HW, FL - RSH * (j / 8), d[2]) end
  line(t, coldD, math.max(0.8, 0.06 * F / d[2]), {0.2, 0.5})
end
-- ribs near the glass: a cool lower edge
for _, Z in ipairs(RIBZ) do
  if Z > 11 then
    local ap = archpts(Z - 0.25, TOP, 3.6, 24)
    line(ap, coldD, math.max(0.7, 0.05 * F / Z), {0.35, 0.35}, VAULT)
  end
end

--@ chunk 19
-- shadow too navy: repaint it a neutral near-black; fold-notation above the glass; runner lines warmed by each lamp
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local lampm = nil
for _, l in ipairs(LAMPS) do local e = FLE(l.X, l.Z, 0.5); lampm = lampm and (lampm + e) or e end
local shN = pile{{"bone black",2},{"burnt sienna",0.45},{"ultramarine blue",0.15}, medium=0.06}
local S = SHADOW - lampm - FIG
work(S, {hand="body", tool="filbert 6", pile=shN, coverage=5, fill=true, clip=S, angle=toVP, load=1})
-- bone fold-notation over the glass: a pentagon holding turned copies of itself
local cx, cy = 540, 160
local bone = pile{{"lead white",1.2},{"yellow ochre",0.25},{"bone black",0.6},{"ultramarine ash",0.2}, medium=0.06}
local r, rot = 13, -math.pi / 2
for n = 1, 4 do
  local pts = {}
  for j = 0, 5 do local a = rot + 2 * math.pi * j / 5; pts[#pts+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
  local b = brush{kind="round", width=math.max(0.7, 1.3 - n * 0.15), point=0.4}
  b:load(bone, 0.75)
  b:stroke(pts, {pressure={0.5, 0.5}, shake=0.2})
  r = r * 0.62; rot = rot + 2.399963
end
-- the runner's bone edges take a warm glint beside each lamp
local glint = pile{{"lead white",1.8},{"yellow ochre",0.35},{"bone black",0.1}, medium=0.06}
for _, l in ipairs(LAMPS) do
  local X = (l.X < 0) and -0.55 or 0.55
  if not (X < 0 and l.Z < FIGZ) then
    local b = brush{kind="round", width=math.max(0.7, math.min(4, 0.06 * F / l.Z)), point=0.5}
    b:load(glint, 0.8)
    b:stroke({pt(X, FL, l.Z + 0.6), pt(X, FL, l.Z), pt(X, FL, l.Z - 0.6)}, {pressure={0.1, 0.7}, swell={0.3, 1, 0.3}})
  end
end

--@ chunk 20
-- the navy left inside the shadow round the near lamp
local spot = nil
for _, l in ipairs(LAMPS) do local e = FLE(l.X, l.Z, 0.27); spot = spot and (spot + e) or e end
local m = (SHADOW * FLE(LAMPS[1].X, LAMPS[1].Z, 0.6)) - spot - FIG
local shN = pile{{"bone black",2},{"burnt sienna",0.45},{"ultramarine blue",0.15}, medium=0.06}
work(m, {hand="body", tool="filbert 4", pile=shN, coverage=5, fill=true, clip=m, angle=0, load=1})
for i = 2, #LAMPS do
  local l = LAMPS[i]
  local mm = (SHADOW * FLE(l.X, l.Z, 0.6)) - spot - FIG
  if mm:area() > 1 then work(mm, {hand="detail", pile=shN, coverage=5, fill=true, clip=mm, load=1}) end
end

--@ chunk 21
-- the two near chairs need their shapes: stronger cold rims on back and seat, a warm lamp-lit touch below
local cold = pile{{"zinc white",1.5},{"lead white",0.8},{"ultramarine ash",0.5},{"bone black",0.1}, medium=0.05}
local warmL = pile{{"lead white",1.4},{"yellow ochre",0.45},{"burnt sienna",0.2},{"bone black",0.2}, medium=0.06}
local function line(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr, swell={0.6, 1, 0.7}, shake=0.15, clip=clipm})
end
for i = 1, 3 do
  local c = CHAIRS[i]
  local k = F / c.Z
  local bx, by = P(c.X, FL, c.Z)
  local m = CHAIR(c.X, c.Z, c.kind, c.tilt)
  local w = math.max(1.2, 0.045 * k)
  local inward = (c.X < 0) and 1 or -1
  if c.kind == "egg" then
    local cx, cy = bx + c.tilt * 0.1 * k, by - 1.02 * k
    local pts = {}
    for a = 0, 10 do
      local th = (inward > 0) and (math.pi * 1.35 + 1.9 * a / 10) or (math.pi * 1.65 - 1.9 * a / 10)
      pts[#pts+1] = {cx + 0.34 * k * math.cos(th), cy + 0.535 * k * math.sin(th)}
    end
    line(pts, cold, w, {0.85, 0.2}, m)
  else
    local s = c.tilt
    local function Q(dx, h) return {bx + dx * k, by - h * k} end
    line({Q(-0.12 + s * 0.4, 1.5), Q(0.06 + s * 0.4, 1.53), Q(0.24 + s * 0.4, 1.45), Q(0.22 + s * 0.3, 1.1), Q(0.2 + s * 0.05, 0.55)}, cold, w, {0.85, 0.2}, m)
  end
  line({{bx - 0.36 * k * inward * -1, by - 0.5 * k}, {bx, by - 0.548 * k}, {bx + 0.38 * k * inward, by - 0.5 * k}}, cold, w * 0.8, {0.3, 0.8}, m)
  line({{bx - 0.25 * k, by - 0.43 * k}, {bx + 0.25 * k, by - 0.43 * k}}, warmL, w * 0.8, {0.5, 0.5}, m)
  line({{bx + 0.02 * k * inward, by - 0.42 * k}, {bx + 0.02 * k * inward, by - 0.05 * k}}, warmL, w * 0.5, {0.4, 0.2}, m)
end
