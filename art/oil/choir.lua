-- easel session "choir": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=9393,
  ground={{pile={{"bone black",1},{"burnt sienna",0.9},{"ultramarine blue",0.3},{"lead white",0.5}}, um=110, apply="knife", texture=0.4}}}
-- one-point down the choir: aisle floor Y = 1.6 below the eye; tiers stepping up and out to the walls at X = +-6
VX, VY, F = 500, 300, 500
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY, ZN, ZE = 1.6, 1.0, 30
-- tier k (1..5): its tread at X from TX0[k] to TX1[k], at height TH[k] above the aisle
TX0 = {1.4, 2.3, 3.2, 4.1, 5.0}; TH = {0.5, 1.15, 1.8, 2.45, 3.1}
HW, HTOP = 6.0, 11
function TREAD(side, k, z0, z1)
  local x0, x1 = side * TX0[k], side * (TX0[k] + 0.9)
  local y = FY - TH[k]
  return poly({pt(x0, y, z0), pt(x1, y, z0), pt(x1, y, z1), pt(x0, y, z1)})
end
function RISER(side, k, z0, z1)   -- the vertical face of tier k toward the aisle
  local x = side * TX0[k]
  local y0 = FY - ((k > 1) and TH[k - 1] or 0); local y1 = FY - TH[k]
  return poly({pt(x, y0, z0), pt(x, y1, z0), pt(x, y1, z1), pt(x, y0, z1)})
end
FARW = poly({pt(-HW, FY, ZE), pt(HW, FY, ZE), pt(HW, FY - HTOP, ZE), pt(-HW, FY - HTOP, ZE)})
AISLE = poly({pt(-1.4, FY, ZN), pt(-1.4, FY, ZE), pt(1.4, FY, ZE), pt(1.4, FY, ZN)})
STALLS = nil
for _, side in ipairs{-1, 1} do
  for k = 1, 5 do
    local m = TREAD(side, k, ZN, ZE) + RISER(side, k, ZN, ZE)
    STALLS = STALLS and (STALLS + m) or m
  end
end
UPPER = everywhere() - STALLS - AISLE - FARW
print(W, H, P(-1.4, FY, ZE), P(1.4, FY, 3))

--@ chunk 2
-- value structure: upper hall near-black warm, stalls dark bronze (treads a step lighter than risers), aisle, far wall
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local up = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}
work(UPPER, {hand="body", tool="filbert 12", pile=up, coverage=4, fill=true, clip=UPPER, angle=toVP, load=1})
local tr = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.9}, medium=0.06}
local ri = pile{{"bone black",1.8},{"burnt sienna",0.8},{"Mars brown",0.3}, medium=0.06}
local T, R = nil, nil
for _, side in ipairs{-1, 1} do
  for k = 1, 5 do
    local t = TREAD(side, k, ZN, ZE); local r = RISER(side, k, ZN, ZE)
    T = T and (T + t) or t; R = R and (R + r) or r
  end
end
TREADS, RISERS = T, R
work(R, {hand="body", tool="filbert 8", pile=ri, coverage=4, fill=true, clip=R, angle=toVP, load=1})
work(T, {hand="body", tool="filbert 8", pile=tr, coverage=4, fill=true, clip=T, angle=toVP, load=1})
local ai = pile{{"bone black",1.6},{"burnt sienna",0.8},{"ultramarine blue",0.3}, medium=0.06}
work(AISLE, {hand="body", tool="filbert 10", pile=ai, coverage=4, fill=true, clip=AISLE, angle=toVP, load=1})
local fw = pile{{"bone black",1.6},{"burnt sienna",0.8},{"raw sienna",0.3}, medium=0.06}
work(FARW, {hand="body", tool="filbert 4", pile=fw, coverage=4, fill=true, clip=FARW, angle=math.pi/2, load=1})

--@ chunk 3
-- the lectern on its dais at Z 17, the open tablet, and one pale shaft of light falling on it from a high window
print(wait(2*24*60))
local LZ = 17
local function Q(X, Y) return pt(X, Y, LZ) end
-- the dais: three bronze steps
local dais = poly({pt(-1.3, FY, LZ - 0.6), pt(1.3, FY, LZ - 0.6), pt(1.3, FY - 0.45, LZ - 0.6), pt(-1.3, FY - 0.45, LZ - 0.6)})
work(dais, {hand="detail", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}, coverage=5, fill=true, clip=dais, load=1})
local top = poly({pt(-1.3, FY - 0.45, LZ - 0.6), pt(1.3, FY - 0.45, LZ - 0.6), pt(1.1, FY - 0.45, LZ + 0.6), pt(-1.1, FY - 0.45, LZ + 0.6)})
work(top, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.4}, medium=0.06}, coverage=5, fill=true, clip=top, load=1})
-- the bone lectern: a tapering column and a sloped desk
LECT = poly({Q(-0.16, FY - 0.45), Q(0.16, FY - 0.45), Q(0.1, FY - 1.55), Q(-0.1, FY - 1.55)}) + poly({Q(-0.55, FY - 1.5), Q(0.55, FY - 1.5), Q(0.62, FY - 1.85), Q(-0.62, FY - 1.95)})
work(LECT, {hand="detail", pile=pile{{"lead white",1.4},{"yellow ochre",0.6},{"raw sienna",0.3},{"bone black",0.2}, medium=0.06}, coverage=5, fill=true, clip=LECT, load=1})
-- the open tablet standing on it
TAB = poly({Q(-0.5, FY - 1.9), Q(0.0, FY - 1.85), Q(0.0, FY - 2.55), Q(-0.48, FY - 2.62)}) + poly({Q(0.0, FY - 1.85), Q(0.5, FY - 1.9), Q(0.48, FY - 2.62), Q(0.0, FY - 2.55)})
work(TAB, {hand="detail", pile=pile{{"zinc white",1.5},{"lead white",1.5},{"lemon chrome",0.08}, medium=0.05}, coverage=5, fill=true, clip=TAB, load=1})
-- the shaft: from a high window up on the left wall, down onto the lectern; three graded low-load veils, blended inside
local w0, w1 = pt(-5.6, FY - 10.5, LZ - 2.2), pt(-5.6, FY - 10.5, LZ + 0.4)
local s0, s1 = Q(-0.6, FY - 1.6), Q(0.65, FY - 1.6)
SHAFT = poly({w0, w1, {s1[1], s1[2] + 6}, {s0[1], s0[2] + 6}})
local core = poly({lerp2 and w0 or w0, w1, s1, s0})
local veil = pile{{"lead white",2},{"zinc white",0.5},{"yellow ochre",0.1}, medium=0.55}
work(SHAFT, {hand="glaze", pile=veil, coverage=1.0, clip=SHAFT, load=0.25, pressure={0.1, 0.22}})
blend(SHAFT, {angle=math.atan(s0[2] - w0[2], s0[1] - w0[1])})
-- the window itself, a tall slit high on the left wall
local win = poly({pt(-5.95, FY - 9.6, LZ - 2.0), pt(-5.95, FY - 9.6, LZ + 0.2), pt(-5.95, FY - 11.4, LZ + 0.2), pt(-5.95, FY - 11.4, LZ - 2.0)})
work(win, {hand="detail", pile=pile{{"zinc white",2.5},{"lemon chrome",0.05}, medium=0.04}, coverage=5, fill=true, clip=win, load=1})
print(w0[1], w0[2], s0[1], s0[2])

--@ chunk 4
-- the shaft laid opaque as a white bar, and the lectern too small: paint both out; lectern again nearer and larger;
-- the shaft rebuilt as a broad band of air only a little lighter than the dark, brighter toward the lectern
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local up = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}
local fw = pile{{"bone black",1.6},{"burnt sienna",0.8},{"raw sienna",0.3}, medium=0.06}
local ai = pile{{"bone black",1.6},{"burnt sienna",0.8},{"ultramarine blue",0.3}, medium=0.06}
local old = SHAFT:grow(6) + rect(440, 255, 120, 95)
work(old * UPPER, {hand="body", tool="filbert 6", pile=up, coverage=6, fill=true, clip=old * UPPER, angle=toVP, load=1})
work(old * FARW, {hand="body", tool="filbert 4", pile=fw, coverage=6, fill=true, clip=old * FARW, angle=math.pi/2, load=1})
work(old * AISLE, {hand="body", tool="filbert 4", pile=ai, coverage=6, fill=true, clip=old * AISLE, angle=toVP, load=1})
LZ = 11
local function Q(X, Y) return pt(X, Y, LZ) end
DAIS = poly({pt(-1.3, FY, LZ - 0.6), pt(1.3, FY, LZ - 0.6), pt(1.3, FY - 0.45, LZ - 0.6), pt(-1.3, FY - 0.45, LZ - 0.6)})
work(DAIS, {hand="detail", pile=pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}, coverage=6, fill=true, clip=DAIS, load=1})
local top = poly({pt(-1.3, FY - 0.45, LZ - 0.6), pt(1.3, FY - 0.45, LZ - 0.6), pt(1.15, FY - 0.45, LZ + 0.5), pt(-1.15, FY - 0.45, LZ + 0.5)})
work(top, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06}, coverage=6, fill=true, clip=top, load=1})
LECT = poly({Q(-0.16, FY - 0.45), Q(0.16, FY - 0.45), Q(0.1, FY - 1.5), Q(-0.1, FY - 1.5)}) + poly({Q(-0.55, FY - 1.45), Q(0.55, FY - 1.45), Q(0.62, FY - 1.75), Q(-0.62, FY - 1.85)})
work(LECT, {hand="detail", pile=pile{{"lead white",1},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone black",0.35}, medium=0.06}, coverage=6, fill=true, clip=LECT, load=1})
TAB = poly({Q(-0.52, FY - 1.82), Q(0.0, FY - 1.76), Q(0.0, FY - 2.5), Q(-0.5, FY - 2.58)}) + poly({Q(0.0, FY - 1.76), Q(0.52, FY - 1.82), Q(0.5, FY - 2.58), Q(0.0, FY - 2.5)})
work(TAB, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.4},{"bone black",0.1}, medium=0.05}, coverage=6, fill=true, clip=TAB, load=1})

--@ chunk 5
-- the choir: a docent in every stall, far to near, all turned toward the lectern. Robe, head, bone face toward the lectern.
print(wait(2*24*60))
local robeD = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local robeM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.25}, medium=0.06}
local bone = pile{{"lead white",1.3},{"yellow ochre",0.5},{"raw sienna",0.2},{"bone black",0.25}, medium=0.06}
local ZS = {3.6, 4.7, 5.9, 7.2, 8.7, 10.3, 12.1, 14.1, 16.4, 18.9, 21.7, 24.7}
DOCS = {}
local items = {}
for _, side in ipairs{-1, 1} do
  for k = 1, 5 do
    for i, Z in ipairs(ZS) do
      local jit = 0.12 * math.sin(k * 3.3 + i * 1.7 + side)
      items[#items+1] = {side=side, k=k, Z=Z + jit, X=side * (TX0[k] + 0.5)}
    end
  end
end
table.sort(items, function(a, b) return a.Z > b.Z end)
for _, d in ipairs(items) do
  local k = F / d.Z
  local bx, by = P(d.X, FY - TH[d.k], d.Z)
  if bx > -60 and bx < 1060 and by > -60 then
    local inward = -d.side
    -- robe: a bell, wider at the base, painted as two filbert strokes (shadow side, then the side toward the lectern)
    local rb = brush{kind="filbert", width=math.max(1.2, 0.5 * k), stiffness=0.5}
    rb:load(robeD, 0.95)
    rb:stroke({{bx, by - 1.15 * k}, {bx - inward * 0.03 * k, by - 0.05 * k}}, {pressure={0.55, 0.95}, ramps={0.05, 0.05}})
    local mb = brush{kind="filbert", width=math.max(0.8, 0.2 * k), stiffness=0.5}
    mb:load(robeM, 0.9)
    mb:stroke({{bx + inward * 0.1 * k, by - 1.05 * k}, {bx + inward * 0.17 * k, by - 0.1 * k}}, {pressure={0.5, 0.8}, ramps={0.05, 0.05}})
    -- head, a little forward toward the lectern
    local hx, hy = bx + inward * 0.06 * k, by - 1.32 * k
    local hb = brush{kind="round", width=math.max(1, 0.24 * k), stiffness=0.5}
    hb:load(robeD, 0.95); hb:touch(hx, hy, {pressure=0.8})
    -- bone face: the inward half of the head
    local fb = brush{kind="round", width=math.max(0.8, 0.15 * k), stiffness=0.5}
    fb:load(bone, 0.9)
    fb:stroke({{hx + inward * 0.05 * k, hy - 0.06 * k}, {hx + inward * 0.06 * k, hy + 0.07 * k}}, {pressure={0.7, 0.6}})
    DOCS[#DOCS+1] = {hx=hx, hy=hy, k=k, inward=inward, Z=d.Z, bx=bx, by=by}
  end
end
print(#DOCS)

--@ chunk 6
-- the upper hall: tall bronze pilasters over the stalls and transverse ribs; the stray window painted out;
-- the shaft rebuilt as a near-vertical fall of light from an oculus above the lectern, in opaque graded steps
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local up = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}
local stray = rect(290, 0, 80, 80)
work(stray, {hand="body", tool="filbert 6", pile=up, coverage=6, fill=true, clip=stray, angle=toVP, load=1})
-- the shaft: from the top of the frame above the lectern down onto the tablet
local tx, ty = P(0, FY - 2.2, LZ)
local outer = poly({{tx - 60, -5}, {tx + 30, -5}, {tx + 42, ty}, {tx - 46, ty}})
local mid = poly({{tx - 38, -5}, {tx + 14, -5}, {tx + 28, ty}, {tx - 30, ty}})
local core = poly({{tx - 18, -5}, {tx + 2, -5}, {tx + 16, ty}, {tx - 16, ty}})
local keep = TAB:grow(2) + LECT:grow(1)
local a1 = pile{{"bone black",1.6},{"burnt sienna",0.6},{"ultramarine ash",0.5},{"lead white",0.35}, medium=0.06}
local a2 = pile{{"bone black",1.1},{"ultramarine ash",0.6},{"burnt sienna",0.3},{"lead white",0.8}, medium=0.06}
local a3 = pile{{"lead white",1.2},{"zinc white",0.4},{"bone black",0.5},{"ultramarine ash",0.4}, medium=0.06}
local ang = math.atan(ty + 5, 10)
work((outer - mid) - keep, {hand="body", tool="filbert 5", pile=a1, coverage=5, fill=true, clip=(outer - mid) - keep, angle=ang, load=1})
work((mid - core) - keep, {hand="body", tool="filbert 4", pile=a2, coverage=5, fill=true, clip=(mid - core) - keep, angle=ang, load=1})
work(core - keep, {hand="body", tool="filbert 3", pile=a3, coverage=5, fill=true, clip=core - keep, angle=ang, load=1})
blend((outer:grow(8) - outer:shrink(8)) - keep, {angle=ang})
blend((mid:grow(6) - mid:shrink(6)) - keep, {angle=ang})
blend((core:grow(5) - core:shrink(5)) - keep, {angle=ang})
SHAFT2 = outer
-- pilasters rising from the top tier, and the vault's transverse ribs, faint in the dark
local pil = pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}
local lipP = pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.4},{"bone black",0.4}, medium=0.06}
for _, Z in ipairs{3.0, 5.2, 8.0, 11.6, 16.2, 22.0} do
  for _, side in ipairs{-1, 1} do
    local a, b = pt(side * 5.9, FY - TH[5] - 1.6, Z), pt(side * 5.9, FY - HTOP, Z)
    local m = ribbon({a, b}, math.max(2, 0.4 * F / Z)) * UPPER - outer:grow(4)
    work(m, {hand="detail", pile=pil, coverage=5, fill=true, clip=m, load=1})
    local br = brush{kind="round", width=math.max(0.8, 0.05 * F / Z), point=0.3}
    br:load(lipP, 0.8); br:stroke({{a[1] - side * 0.17 * F / Z, a[2]}, {b[1] - side * 0.17 * F / Z, b[2]}}, {pressure={0.5, 0.2}, clip=UPPER - outer:grow(4)})
  end
  local L, R = pt(-5.9, FY - HTOP, Z), pt(5.9, FY - HTOP, Z)
  local arc = {}
  for j = 0, 16 do local t = j / 16; arc[#arc+1] = {lerp(L[1], R[1], t), lerp(L[2], R[2], t) - 0.9 * F / Z * math.sin(t * math.pi)} end
  local rb = brush{kind="round", width=math.max(1.5, 0.3 * F / Z), stiffness=0.6}
  rb:load(pil, 1); rb:stroke(arc, {pressure={0.9, 0.9}, clip=UPPER - outer:grow(4)})
end

--@ chunk 7
-- lights last, on set paint: the stray patch again; the tablet blazing with its fold notation; the pool at the lectern's foot;
-- a cold lens in every face, catching the shaft; the Commando just in at the near end, stopped
print(wait(4*24*60))
local up = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}
local stray = rect(286, 0, 70, 82)
work(stray, {hand="body", tool="filbert 5", pile=up, coverage=6, fill=true, clip=stray, angle=0, load=1})
work(TAB, {hand="detail", pile=pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.08}, medium=0.04}, coverage=6, fill=true, clip=TAB, load=1})
local ink = pile{{"burnt sienna",1},{"bone black",1}, medium=0.06}
for _, c in ipairs{{-0.26}, {0.26}} do
  local cx, cy = P(c[1], FY - 2.18, LZ)
  local r, rot = 0.17 * F / LZ, 0.4 + c[1]
  for n = 1, 3 do
    local pts = {}
    for j = 0, 5 do local a = rot + 2 * math.pi * j / 5; pts[#pts+1] = {cx + r * math.cos(a), cy + r * 1.1 * math.sin(a)} end
    local b = brush{kind="round", width=0.9, point=0.4}
    b:load(ink, 0.8); b:stroke(pts, {pressure={0.55, 0.55}, clip=TAB})
    r = r * 0.62; rot = rot + 2.399963
  end
end
local lit = pile{{"lead white",1.6},{"yellow ochre",0.6},{"cadmium yellow",0.1}, medium=0.05}
local b = brush{kind="round", width=1.6, point=0.4}
local l1, l2 = P(-0.62, FY - 1.85, LZ), P(0.62, FY - 1.75, LZ)
b:load(lit, 0.9); b:stroke({{select(1, P(-0.62, FY - 1.85, LZ)), select(2, P(-0.62, FY - 1.85, LZ))}, {select(1, P(0.62, FY - 1.75, LZ)), select(2, P(0.62, FY - 1.75, LZ))}}, {pressure={0.7, 0.7}})
-- the pool of the shaft on the dais top
local pool = poly({pt(-0.9, FY - 0.45, LZ - 0.45), pt(0.9, FY - 0.45, LZ - 0.45), pt(0.8, FY - 0.45, LZ + 0.45), pt(-0.8, FY - 0.45, LZ + 0.45)}, true) - LECT
work(pool, {hand="detail", pile=pile{{"lead white",1.2},{"yellow ochre",0.5},{"bone black",0.3}, medium=0.05}, coverage=4, fill=true, clip=pool, load=0.9})
-- lenses: one cold point in each face, toward the lectern
local lens = pile{{"zinc white",2.5},{"cerulean blue",0.12}, medium=0.04}
for _, d in ipairs(DOCS) do
  local lb = brush{kind="round", width=math.max(0.7, 0.045 * d.k), stiffness=0.5}
  lb:load(lens, 0.9)
  lb:touch(d.hx + d.inward * 0.075 * d.k, d.hy - 0.01 * d.k, {pressure=0.75})
end
-- the Commando, small, at the near end of the aisle, stopped, looking down the choir
local Z = 4.2
local k = F / Z
local fx, fy = P(0.15, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.13,0.5), Q(-0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.25,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.23,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.34,1.24), Q(-0.31,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
FIGC = fig
work(fig, {hand="body", tool="filbert 3", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=fig, angle=math.pi/2, load=1})

--@ chunk 8
-- the Commando came out too big and right in front of the lectern: paint him out region by region
print(wait(4*24*60))
local Fm = FIGC:grow(4)
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local function fill(m, pl, ang, tool) m = m * Fm; work(m, {hand="body", tool=tool or "filbert 3", pile=pl, coverage=6, fill=true, clip=m, angle=ang or 0, load=1}) end
fill(UPPER, pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}, toVP)
fill(FARW, pile{{"bone black",1.6},{"burnt sienna",0.8},{"raw sienna",0.3}, medium=0.06}, math.pi/2)
fill(RISERS, pile{{"bone black",1.8},{"burnt sienna",0.8},{"Mars brown",0.3}, medium=0.06}, toVP)
fill(TREADS, pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.9}, medium=0.06}, toVP)
fill(AISLE, pile{{"bone black",1.6},{"burnt sienna",0.8},{"ultramarine blue",0.3}, medium=0.06}, toVP)
local tx, ty = P(0, FY - 2.2, LZ)
local outer = poly({{tx - 60, -5}, {tx + 30, -5}, {tx + 42, ty}, {tx - 46, ty}})
local mid = poly({{tx - 38, -5}, {tx + 14, -5}, {tx + 28, ty}, {tx - 30, ty}})
local core = poly({{tx - 18, -5}, {tx + 2, -5}, {tx + 16, ty}, {tx - 16, ty}})
local ang = math.atan(ty + 5, 10)
fill(outer - mid, pile{{"bone black",1.6},{"burnt sienna",0.6},{"ultramarine ash",0.5},{"lead white",0.35}, medium=0.06}, ang)
fill(mid - core, pile{{"bone black",1.1},{"ultramarine ash",0.6},{"burnt sienna",0.3},{"lead white",0.8}, medium=0.06}, ang)
fill(core, pile{{"lead white",1.2},{"zinc white",0.4},{"bone black",0.5},{"ultramarine ash",0.4}, medium=0.06}, ang)
fill(DAIS, pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}, 0)
local top = poly({pt(-1.3, FY - 0.45, LZ - 0.6), pt(1.3, FY - 0.45, LZ - 0.6), pt(1.15, FY - 0.45, LZ + 0.5), pt(-1.15, FY - 0.45, LZ + 0.5)}) - LECT
fill(top, pile{{"lead white",1.2},{"yellow ochre",0.5},{"bone black",0.3}, medium=0.05}, 0)
fill(LECT, pile{{"lead white",1},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone black",0.35}, medium=0.06}, math.pi/2)
fill(TAB, pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.08}, medium=0.04}, math.pi/2)

--@ chunk 9
-- tablet restated, its notation; the shaft's foot softened; the Commando again, smaller, off the axis on the left
print(wait(4*24*60))
work(TAB, {hand="detail", pile=pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.08}, medium=0.04}, coverage=6, fill=true, clip=TAB, load=1})
local ink = pile{{"burnt sienna",1},{"bone black",1}, medium=0.06}
for _, c in ipairs{-0.26, 0.26} do
  local cx, cy = P(c, FY - 2.18, LZ)
  local r, rot = 0.17 * F / LZ, 0.4 + c
  for n = 1, 3 do
    local pts = {}
    for j = 0, 5 do local a = rot + 2 * math.pi * j / 5; pts[#pts+1] = {cx + r * math.cos(a), cy + r * 1.1 * math.sin(a)} end
    local b = brush{kind="round", width=0.9, point=0.4}
    b:load(ink, 0.8); b:stroke(pts, {pressure={0.55, 0.55}, clip=TAB})
    r = r * 0.62; rot = rot + 2.399963
  end
end
local tx, ty = P(0, FY - 2.2, LZ)
blend(rect(tx - 50, ty - 14, 100, 16) - TAB:grow(2) - LECT, {angle=0})
-- the Commando, small, just inside the near end, left of the aisle's centre, stopped
local Z = 6.4
local k = F / Z
local fx, fy = P(-0.72, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.13,0.5), Q(-0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.25,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.23,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.34,1.24), Q(-0.31,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
FIGC2, FK, FX, FYY = fig, k, fx, fy
work(fig, {hand="body", tool="filbert 2", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=fig, angle=math.pi/2, load=1})
print(fx, fy, k)

--@ chunk 10
-- accents on set paint: crisp cold lens points; a pale edge on each docent's lectern-side shoulder; the Commando's rim
print(wait(4*24*60))
local lens = pile{{"zinc white",3},{"cerulean blue",0.08}, medium=0.03}
local shoulder = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.5}, medium=0.06}
for _, d in ipairs(DOCS) do
  local k = d.k
  local sb = brush{kind="round", width=math.max(0.6, 0.04 * k), point=0.5}
  sb:load(shoulder, 0.8)
  sb:stroke({{d.hx + d.inward * 0.13 * k, d.hy + 0.2 * k}, {d.bx + d.inward * 0.22 * k, d.by - 0.7 * k}}, {pressure={0.6, 0.1}})
  local lb = brush{kind="round", width=math.max(0.6, 0.03 * k), point=0.6}
  lb:load(lens, 1)
  lb:touch(d.hx + d.inward * 0.075 * d.k, d.hy - 0.01 * d.k, {pressure=0.9})
end
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local cool = pile{{"lead white",1.5},{"zinc white",0.6},{"ultramarine ash",0.4},{"bone black",0.15}, medium=0.05}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(cool, 0.9); b:stroke(pts, {pressure=pr, clip=FIGC2:grow(1)})
end
ln({Q(-0.06,1.88), Q(0.04,1.89), Q(0.1,1.8)}, 1.4, {0.8, 0.5})
ln({Q(0.12,1.61), Q(0.3,1.62), Q(0.4,1.54)}, 1.4, {0.8, 0.6})
ln({Q(0.4,1.45), Q(0.42,1.24), Q(0.38,1.0)}, 1.1, {0.6, 0.15})
ln({Q(0.24,0.92), Q(0.22,0.5), Q(0.2,0.14)}, 1.0, {0.5, 0.05})
ln({Q(-0.12,1.61), Q(-0.3,1.62)}, 1.0, {0.4, 0.3})

--@ chunk 11
-- the docents' shoulder strokes ran across the Commando: restate him dark, then his cool rim
print(wait(3*24*60))
work(FIGC2, {hand="body", tool="filbert 2", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=FIGC2, angle=math.pi/2, load=1})
print(wait(3*24*60))
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local cool = pile{{"lead white",1.5},{"zinc white",0.6},{"ultramarine ash",0.4},{"bone black",0.15}, medium=0.05}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(cool, 0.9); b:stroke(pts, {pressure=pr, clip=FIGC2:grow(1)})
end
ln({Q(-0.06,1.88), Q(0.04,1.89), Q(0.1,1.8)}, 1.4, {0.8, 0.5})
ln({Q(0.12,1.61), Q(0.3,1.62), Q(0.4,1.54)}, 1.4, {0.8, 0.6})
ln({Q(0.4,1.45), Q(0.42,1.24), Q(0.38,1.0)}, 1.1, {0.6, 0.15})
ln({Q(0.24,0.92), Q(0.22,0.5), Q(0.2,0.14)}, 1.0, {0.5, 0.05})
