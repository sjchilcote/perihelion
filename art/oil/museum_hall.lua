-- easel session "museum_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=1212,
  ground={{pile={{"bone black",1},{"burnt sienna",0.9},{"raw sienna",0.3},{"lead white",0.45}}, um=110, apply="knife", texture=0.4}}}
-- one-point down the gallery; Y down from the eye, floor at Y = 1.6; walls at X = +-4.2, height 9
VX, VY, F = 500, 330, 520
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY, HW, HT, ZN, ZE = 1.6, 4.2, 9, 0.8, 34
function quad(a, b, c, d) return poly({a, b, c, d}) end
FLOOR = quad(pt(-HW, FY, ZN), pt(HW, FY, ZN), pt(HW, FY, ZE), pt(-HW, FY, ZE)) + rect(0, 640, 1000, 30)
LWALL = quad(pt(-HW, FY, ZN), pt(-HW, FY, ZE), pt(-HW, FY - HT, ZE), pt(-HW, FY - HT, ZN))
RWALL = quad(pt(HW, FY, ZN), pt(HW, FY, ZE), pt(HW, FY - HT, ZE), pt(HW, FY - HT, ZN))
ENDW = quad(pt(-HW, FY, ZE), pt(HW, FY, ZE), pt(HW, FY - HT, ZE), pt(-HW, FY - HT, ZE))
CEIL = everywhere() - FLOOR - LWALL - RWALL - ENDW
-- vitrines: two rows at X = +-2.3, at uneven depths; a box 0.8 wide, 0.8 deep; plinth 0.7, glass 1.5, cap 0.15
CASES = {}
for i, Z in ipairs{3.4, 5.6, 8.2, 11.2, 14.6, 18.4} do
  CASES[#CASES+1] = {X=-2.3, Z=Z + 0.25 * math.sin(i * 2.1)}
  CASES[#CASES+1] = {X= 2.3, Z=Z + 0.6 + 0.25 * math.sin(i * 1.3)}
end
LAST = {X=0, Z=24.5}
function CASEPARTS(c)
  local x0, x1, z0, z1 = c.X - 0.4, c.X + 0.4, c.Z - 0.4, c.Z + 0.4
  local inner = (c.X < 0) and x1 or x0
  local function front(y0, y1) return quad(pt(x0, y0, z0), pt(x1, y0, z0), pt(x1, y1, z0), pt(x0, y1, z0)) end
  local function side(y0, y1) return quad(pt(inner, y0, z0), pt(inner, y0, z1), pt(inner, y1, z1), pt(inner, y1, z0)) end
  local yP, yG, yC = FY - 0.7, FY - 2.2, FY - 2.35
  local p = {}
  p.plinth = front(FY, yP) + ((c.X ~= 0) and side(FY, yP) or front(FY, yP))
  p.glassF = front(yP, yG)
  p.glassS = (c.X ~= 0) and side(yP, yG) or nil
  p.cap = front(yG, yC) + ((c.X ~= 0) and side(yG, yC) or front(yG, yC))
  p.all = p.plinth + p.glassF + (p.glassS or p.glassF) + p.cap
  return p
end
print(W, H, P(-2.3, FY, 3.4))

--@ chunk 2
-- value structure, lean darks: ceiling near-black, walls warm dark bronze lighter far down, floor dark, end wall a dim warm field
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
work(CEIL, {hand="body", tool="filbert 12", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}, coverage=4, fill=true, clip=CEIL, angle=toVP, load=1})
local wN = pile{{"bone black",1.8},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local wF = pile{{"bone black",1.2},{"burnt sienna",1},{"raw sienna",0.5}, medium=0.06}
local W = LWALL + RWALL
local split = poly({pt(-9, -30, 10), pt(9, -30, 10), pt(9, 30, 10), pt(-9, 30, 10)})
work(W - split, {hand="body", tool="filbert 12", pile=wN, coverage=4, fill=true, clip=W - split, angle=toVP, load=1})
work(W * split, {hand="body", tool="filbert 8", pile=wF, coverage=4, fill=true, clip=W * split, angle=toVP, load=1})
work(FLOOR, {hand="body", tool="filbert 12", pile=pile{{"bone black",1.7},{"burnt sienna",0.8},{"ultramarine blue",0.25}, medium=0.06}, coverage=4, fill=true, clip=FLOOR, angle=toVP, load=1})
work(ENDW, {hand="body", tool="filbert 4", pile=pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.2}, medium=0.06}, coverage=4, fill=true, clip=ENDW, angle=math.pi/2, load=1})
-- pilasters on the walls between the cases
local pil = pile{{"bone black",2},{"burnt sienna",0.7}, medium=0.06}
for _, Z in ipairs{2.2, 4.5, 6.9, 9.7, 12.9, 16.5, 20.5, 26} do
  for _, s in ipairs{-1, 1} do
    local m = ribbon({pt(s * HW, FY, Z), pt(s * HW, FY - HT, Z)}, math.max(2, 0.35 * F / Z)) * (s < 0 and LWALL or RWALL)
    work(m, {hand="detail", pile=pil, coverage=5, fill=true, clip=m, load=1})
  end
end

--@ chunk 3
-- walls too light: a second opaque coat, darker near, a step lighter far; pilasters restated
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local W = LWALL + RWALL
local pils = nil
for _, Z in ipairs{2.2, 4.5, 6.9, 9.7, 12.9, 16.5, 20.5, 26} do
  for _, s in ipairs{-1, 1} do
    local m = ribbon({pt(s * HW, FY, Z), pt(s * HW, FY - HT, Z)}, math.max(2, 0.35 * F / Z)) * (s < 0 and LWALL or RWALL)
    pils = pils and (pils + m) or m
  end
end
PILS = pils
local near = W * mask(function(x, y) return (math.abs(x - VX) > 190) and 1 or 0 end)
local far = W - near
work(near - pils, {hand="body", tool="filbert 10", pile=pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.06}, coverage=5, fill=true, clip=near - pils, angle=toVP, load=1})
work(far - pils, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}, coverage=5, fill=true, clip=far - pils, angle=toVP, load=1})
blend(W * mask(function(x, y) return (math.abs(math.abs(x - VX) - 190) < 10) and 1 or 0 end) - pils, {angle=toVP})
work(pils, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",1}, medium=0.06}, coverage=5, fill=true, clip=pils, load=1})
work(ENDW, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}, coverage=5, fill=true, clip=ENDW, angle=math.pi/2, load=1})

--@ chunk 4
-- the vitrines, far to near: bronze plinth and cap, glass glowing cold from a lamp in its top, each with its one thing
print(wait(2*24*60))
local plinthP = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local capP = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.8}, medium=0.06}
local g0 = pile{{"bone black",1.4},{"ultramarine ash",1},{"lead white",0.45},{"viridian",0.05}, medium=0.06}
local g1 = pile{{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.35},{"lead white",0.3}, medium=0.05}
local g2 = pile{{"zinc white",2},{"cerulean blue",0.2},{"lead white",0.5}, medium=0.04}
local objD = pile{{"bone black",2},{"burnt sienna",0.4},{"ultramarine blue",0.3}, medium=0.06}
local objM = pile{{"bone black",1.2},{"ultramarine ash",0.6},{"burnt sienna",0.4},{"lead white",0.2}, medium=0.06}
local rimC = pile{{"zinc white",2},{"lead white",0.5}, medium=0.04}
local frameP = pile{{"bone black",2},{"burnt sienna",0.6}, medium=0.06}
local kinds = {"shell", "lattice", "woven", "mask", "seed", "empty", "lattice", "shell", "mask", "woven", "seed", "empty"}
local order = {}
for i, c in ipairs(CASES) do c.kind = kinds[i]; order[#order+1] = c end
table.sort(order, function(a, b) return a.Z > b.Z end)
local function st(pts, pl, w, pr, clipm, kind)
  local b = brush{kind=kind or "round", width=math.max(0.6, w), stiffness=0.5, point=(kind == nil) and 0.4 or nil}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
function OBJECT(kind, cx, cy, k, clipm)
  local s = k
  if kind == "shell" then
    local pts = {}
    for j = 0, 40 do local t = j / 40; local a = t * 4.2 * math.pi; local r = 0.03 + 0.16 * t; pts[#pts+1] = {cx + r * s * math.cos(a), cy - 0.05 * s + r * s * math.sin(a) * 0.9} end
    st(pts, objD, 0.04 * s, {0.4, 0.95}, clipm)
    st({{cx + 0.16 * s, cy - 0.05 * s}, {cx + 0.3 * s, cy + 0.12 * s}}, objD, 0.05 * s, {0.9, 0.3}, clipm)
  elseif kind == "lattice" then
    for _, q in ipairs{{-0.15, 0.15}, {0.15, -0.15}, {0, -0.25}} do
      local pts = {{cx + q[1] * s, cy + 0.2 * s}, {cx + q[2] * s, cy - 0.3 * s}}
      st(pts, objM, 0.07 * s, {0.8, 0.8}, clipm, "flat")
    end
    st({{cx - 0.17 * s, cy - 0.05 * s}, {cx + 0.17 * s, cy - 0.05 * s}}, objM, 0.03 * s, {0.7, 0.7}, clipm)
    st({{cx - 0.08 * s, cy - 0.3 * s}, {cx + 0.1 * s, cy - 0.28 * s}}, rimC, 0.02 * s, {0.6, 0.6}, clipm)
  elseif kind == "woven" then
    local m = ellipse(cx, cy, 0.22 * s, 0.17 * s) * clipm
    work(m, {hand="detail", pile=objD, coverage=4, fill=true, clip=m, load=1})
    for j = -2, 2 do st({{cx + j * 0.07 * s - 0.08 * s, cy - 0.14 * s}, {cx + j * 0.07 * s + 0.08 * s, cy + 0.14 * s}}, objM, 0.015 * s, {0.5, 0.5}, m) end
  elseif kind == "mask" then
    local m = ellipse(cx, cy - 0.08 * s, 0.14 * s, 0.22 * s) * clipm
    work(m, {hand="detail", pile=objM, coverage=4, fill=true, clip=m, load=1})
    for _, dx in ipairs{-0.06, 0.06} do local e = ellipse(cx + dx * s, cy - 0.13 * s, 0.03 * s, 0.018 * s); work(e, {hand="detail", pile=objD, coverage=4, fill=true, clip=e, load=1}) end
  elseif kind == "seed" then
    local m = ellipse(cx, cy + 0.02 * s, 0.07 * s, 0.11 * s) * clipm
    work(m, {hand="detail", pile=objD, coverage=4, fill=true, clip=m, load=1})
    st({{cx, cy + 0.12 * s}, {cx, cy + 0.2 * s}}, objD, 0.02 * s, {0.7, 0.7}, clipm)
  end
  -- the stand it sits on
  if kind ~= "empty" then st({{cx - 0.12 * s, cy + 0.22 * s}, {cx + 0.12 * s, cy + 0.22 * s}}, objD, 0.035 * s, {0.8, 0.8}, clipm, "flat") end
end
CASEM = nil
for _, c in ipairs(order) do
  local p = CASEPARTS(c)
  local k = F / (c.Z - 0.4)
  work(p.plinth, {hand="detail", pile=plinthP, coverage=5, fill=true, clip=p.plinth, load=1})
  work(p.cap, {hand="detail", pile=capP, coverage=5, fill=true, clip=p.cap, load=1})
  if p.glassS then work(p.glassS, {hand="detail", pile=g0, coverage=5, fill=true, clip=p.glassS, load=1}) end
  work(p.glassF, {hand="detail", pile=g1, coverage=5, fill=true, clip=p.glassF, load=1})
  local x0 = P(c.X - 0.4, 0, c.Z - 0.4); local x1 = P(c.X + 0.4, 0, c.Z - 0.4)
  local _, yt = P(0, FY - 2.2, c.Z - 0.4)
  local core = ellipse((x0 + x1) / 2, yt + 0.35 * k, 0.28 * k, 0.32 * k) * p.glassF
  work(core, {hand="detail", pile=g2, coverage=4, fill=true, clip=core, load=1})
  blend((ellipse((x0 + x1) / 2, yt + 0.35 * k, 0.34 * k, 0.4 * k) - ellipse((x0 + x1) / 2, yt + 0.35 * k, 0.22 * k, 0.26 * k)) * p.glassF)
  local _, ym = P(0, FY - 1.25, c.Z)
  OBJECT(c.kind, (x0 + x1) / 2, ym, F / c.Z, p.glassF)
  -- the bronze frame at the glass corners
  for _, X in ipairs{c.X - 0.4, c.X + 0.4} do st({pt(X, FY - 0.7, c.Z - 0.4), pt(X, FY - 2.2, c.Z - 0.4)}, frameP, 0.03 * k, {0.9, 0.9}) end
  c.p = p
  CASEM = CASEM and (CASEM + p.all) or p.all
end

--@ chunk 5
-- the glass came out chalk-white and marbled: repaint each case's glass as dim cold glass, then a lamp-strip at the top
-- with a small soft cone of cold light under it
print(wait(4*24*60))
local gD = pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.2},{"viridian",0.05}, medium=0.06}
local gM = pile{{"bone black",1.1},{"ultramarine ash",1},{"lead white",0.55},{"zinc white",0.2}, medium=0.06}
local gL = pile{{"zinc white",1.4},{"ultramarine ash",0.6},{"lead white",0.5},{"bone black",0.2}, medium=0.05}
local lamp = pile{{"zinc white",3},{"cerulean blue",0.08}, medium=0.04}
local order = {}
for _, c in ipairs(CASES) do order[#order+1] = c end
table.sort(order, function(a, b) return a.Z > b.Z end)
for _, c in ipairs(order) do
  local p = c.p
  local k = F / (c.Z - 0.4)
  local tw = {kind="filbert", width=math.max(1.5, 0.12 * k)}
  if p.glassS then work(p.glassS, {hand="body", tool=tw, pile=gD, coverage=5, fill=true, clip=p.glassS, angle=math.pi/2, load=1}) end
  work(p.glassF, {hand="body", tool=tw, pile=gD, coverage=5, fill=true, clip=p.glassF, angle=math.pi/2, load=1})
  local x0 = P(c.X - 0.4, 0, c.Z - 0.4); local x1 = P(c.X + 0.4, 0, c.Z - 0.4)
  local _, yt = P(0, FY - 2.2, c.Z - 0.4)
  local cx = (x0 + x1) / 2
  local cone = poly({{cx - 0.12 * k, yt}, {cx + 0.12 * k, yt}, {cx + 0.34 * k, yt + 1.2 * k}, {cx - 0.34 * k, yt + 1.2 * k}}, true) * p.glassF
  local coneI = poly({{cx - 0.07 * k, yt}, {cx + 0.07 * k, yt}, {cx + 0.2 * k, yt + 0.8 * k}, {cx - 0.2 * k, yt + 0.8 * k}}, true) * p.glassF
  work(cone - coneI, {hand="body", tool=tw, pile=gM, coverage=4, fill=true, clip=cone - coneI, angle=math.pi/2, load=1})
  work(coneI, {hand="body", tool=tw, pile=gL, coverage=4, fill=true, clip=coneI, angle=math.pi/2, load=1})
  blend((cone:grow(0.05 * k) - cone:shrink(0.05 * k)) * p.glassF, {angle=math.pi/2})
  blend((coneI:grow(0.04 * k) - coneI:shrink(0.04 * k)) * p.glassF, {angle=math.pi/2})
  local ls = rect(cx - 0.18 * k, yt + 0.01 * k, 0.36 * k, math.max(1.5, 0.035 * k)) * p.glassF
  work(ls, {hand="detail", pile=lamp, coverage=5, fill=true, clip=ls, load=1})
  c.cx, c.yt, c.k = cx, yt, k
end

--@ chunk 6
-- on set paint: each case's one thing as a dark silhouette in its cone, rimmed cold from the lamp above; a bone label on each plinth;
-- the last case on the axis, empty, freshly made, its label blank, and the docent beside it with its stylus raised
print(wait(4*24*60))
local objD = pile{{"bone black",2},{"burnt sienna",0.4},{"ultramarine blue",0.3}, medium=0.06}
local objM = pile{{"bone black",1.3},{"ultramarine ash",0.6},{"burnt sienna",0.5},{"lead white",0.15}, medium=0.06}
local rimC = pile{{"zinc white",2.5},{"cerulean blue",0.08}, medium=0.04}
local labelP = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.35}, medium=0.06}
local ink = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}
local function st(pts, pl, w, pr, clipm, kind)
  local b = brush{kind=kind or "round", width=math.max(0.6, w), stiffness=0.5, point=(kind == nil) and 0.4 or nil}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
for _, c in ipairs(CASES) do
  local s = F / c.Z
  local cx = c.cx
  local _, cy = P(0, FY - 1.25, c.Z)
  local G = c.p.glassF
  if c.kind == "shell" then
    local pts = {}
    for j = 0, 40 do local t = j / 40; local a = t * 4.2 * math.pi; local r = 0.03 + 0.15 * t; pts[#pts+1] = {cx + r * s * math.cos(a), cy - 0.05 * s + r * s * math.sin(a) * 0.9} end
    st(pts, objD, 0.045 * s, {0.4, 0.95}, G)
    st({{cx + 0.15 * s, cy - 0.06 * s}, {cx + 0.3 * s, cy + 0.1 * s}}, objD, 0.05 * s, {0.9, 0.3}, G)
    local top = {}
    for j = 24, 40 do top[#top+1] = {pts[j][1], pts[j][2] - 0.015 * s} end
    st({pts[30], pts[34], pts[38]}, rimC, 0.012 * s, {0.5, 0.5}, G)
  elseif c.kind == "lattice" then
    for _, q in ipairs{{-0.14, 0.12}, {0.14, -0.12}, {0.0, -0.22}} do
      st({{cx + q[1] * s, cy + 0.2 * s}, {cx + q[2] * s, cy - 0.3 * s}}, objM, 0.06 * s, {0.8, 0.8}, G, "flat")
      st({{cx + q[2] * s - 0.01 * s, cy - 0.3 * s}, {cx + (q[1] + q[2]) * 0.5 * s, cy - 0.05 * s}}, rimC, 0.012 * s, {0.6, 0.1}, G)
    end
  elseif c.kind == "woven" then
    local m = ellipse(cx, cy, 0.2 * s, 0.16 * s) * G
    work(m, {hand="body", tool={kind="filbert", width=math.max(1, 0.05 * s)}, pile=objD, coverage=5, fill=true, clip=m, load=1})
    for j = -2, 2 do st({{cx + j * 0.07 * s - 0.07 * s, cy - 0.13 * s}, {cx + j * 0.07 * s + 0.07 * s, cy + 0.13 * s}}, objM, 0.015 * s, {0.5, 0.5}, m) end
    local arc = {}
    for j = 0, 8 do local a = math.pi * (1.15 + 0.7 * j / 8); arc[#arc+1] = {cx + 0.2 * s * math.cos(a), cy + 0.16 * s * math.sin(a)} end
    st(arc, rimC, 0.014 * s, {0.6, 0.6}, G)
  elseif c.kind == "mask" then
    local m = ellipse(cx, cy - 0.08 * s, 0.13 * s, 0.21 * s) * G
    work(m, {hand="body", tool={kind="filbert", width=math.max(1, 0.05 * s)}, pile=objM, coverage=5, fill=true, clip=m, load=1})
    for _, dx in ipairs{-0.055, 0.055} do local e = ellipse(cx + dx * s, cy - 0.13 * s, 0.03 * s, 0.017 * s); work(e, {hand="detail", pile=objD, coverage=5, fill=true, clip=e, load=1}) end
    local arc = {}
    for j = 0, 8 do local a = math.pi * (1.2 + 0.6 * j / 8); arc[#arc+1] = {cx + 0.13 * s * math.cos(a), cy - 0.08 * s + 0.21 * s * math.sin(a)} end
    st(arc, rimC, 0.014 * s, {0.6, 0.6}, G)
  elseif c.kind == "seed" then
    local m = ellipse(cx, cy + 0.02 * s, 0.065 * s, 0.1 * s) * G
    work(m, {hand="detail", pile=objD, coverage=5, fill=true, clip=m, load=1})
    st({{cx - 0.03 * s, cy - 0.06 * s}, {cx + 0.03 * s, cy - 0.07 * s}}, rimC, 0.012 * s, {0.6, 0.6}, G)
  end
  if c.kind ~= "empty" then st({{cx - 0.12 * s, cy + 0.22 * s}, {cx + 0.12 * s, cy + 0.22 * s}}, objD, 0.035 * s, {0.8, 0.8}, G, "flat") end
  -- the label on the plinth's front, a little fold-notation mark on it
  local lx0, ly0 = P(c.X - 0.18, FY - 0.52, c.Z - 0.4); local lx1, ly1 = P(c.X + 0.18, FY - 0.38, c.Z - 0.4)
  local L = rect(lx0, ly0, lx1 - lx0, ly1 - ly0)
  work(L, {hand="detail", pile=labelP, coverage=4, fill=true, clip=L, load=1})
  if (lx1 - lx0) > 8 then
    local r = (ly1 - ly0) * 0.32
    local pts = {}
    for j = 0, 5 do local a = 0.3 + 2 * math.pi * j / 5; pts[#pts+1] = {(lx0 + lx1) / 2 + r * math.cos(a), (ly0 + ly1) / 2 + r * math.sin(a)} end
    st(pts, ink, 0.7, {0.5, 0.5}, L)
  end
end
-- the last case: on the axis, empty, new bright bronze, a plain cold glow, its label blank
LASTP = CASEPARTS(LAST)
local k = F / (LAST.Z - 0.4)
work(LASTP.plinth, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.35}, medium=0.06}, coverage=5, fill=true, clip=LASTP.plinth, load=1})
work(LASTP.cap, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.4}, medium=0.06}, coverage=5, fill=true, clip=LASTP.cap, load=1})
work(LASTP.glassF, {hand="detail", pile=pile{{"zinc white",1.4},{"ultramarine ash",0.6},{"lead white",0.5},{"bone black",0.2}, medium=0.05}, coverage=5, fill=true, clip=LASTP.glassF, load=1})
local lx0, ly0 = P(-0.18, FY - 0.52, LAST.Z - 0.4); local lx1, ly1 = P(0.18, FY - 0.38, LAST.Z - 0.4)
local L = rect(lx0, ly0, lx1 - lx0, ly1 - ly0)
work(L, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.3}, medium=0.05}, coverage=5, fill=true, clip=L, load=1})
-- the docent beside it, on the right, its stylus raised over the blank label
local dk = F / LAST.Z
local bx, by = P(0.85, FY, LAST.Z)
local robe = poly({{bx - 0.18 * dk, by - 1.45 * dk}, {bx + 0.12 * dk, by - 1.45 * dk}, {bx + 0.28 * dk, by}, {bx - 0.3 * dk, by}}, true)
work(robe, {hand="detail", pile=pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.8}, medium=0.06}, coverage=5, fill=true, clip=robe, load=1})
local face = ellipse(bx - 0.05 * dk, by - 1.58 * dk, 0.08 * dk, 0.1 * dk)
work(face, {hand="detail", pile=pile{{"lead white",1.6},{"yellow ochre",0.5}, medium=0.06}, coverage=5, fill=true, clip=face, load=1})
st({{bx - 0.12 * dk, by - 1.15 * dk}, {bx - 0.35 * dk, by - 1.4 * dk}, {bx - 0.42 * dk, by - 1.62 * dk}}, pile{{"burnt sienna",1},{"bone black",0.8}, medium=0.06}, 0.06 * dk, {0.8, 0.6})
st({{bx - 0.42 * dk, by - 1.62 * dk}, {bx - 0.45 * dk, by - 1.88 * dk}}, pile{{"lead white",2},{"yellow ochre",0.4}, medium=0.05}, 0.025 * dk, {0.8, 0.3})
st({{bx - 0.16 * dk, by - 1.43 * dk}, {bx - 0.29 * dk, by - 0.2 * dk}}, rimC, 0.02 * dk, {0.6, 0.1})
local lens = ellipse(bx - 0.1 * dk, by - 1.6 * dk, 0.025 * dk, 0.025 * dk)
work(lens, {hand="detail", pile=rimC, coverage=5, fill=true, clip=lens, load=1})

--@ chunk 7
-- the things came out faint: restated as solid masks painted opaque; then cold reflections of the cases on the floor;
-- the Commando small in the foreground on the left, looking
print(wait(2*24*60))
local objD = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.2}, medium=0.06}
local objW = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.9}, medium=0.06}
OBJM = {}
for i, c in ipairs(CASES) do
  local s = F / c.Z
  local cx = c.cx
  local _, cy = P(0, FY - 1.25, c.Z)
  local m = nil
  if c.kind == "shell" then
    local pts, ws = {}, {}
    for j = 0, 30 do local t = j / 30; local a = t * 4.2 * math.pi; local r = 0.03 + 0.15 * t; pts[#pts+1] = {cx + r * s * math.cos(a), cy - 0.05 * s + r * s * math.sin(a) * 0.9}; ws[#ws+1] = (0.015 + 0.05 * t) * s end
    m = ribbon(pts, ws) + ribbon({{cx + 0.15 * s, cy - 0.06 * s}, {cx + 0.3 * s, cy + 0.1 * s}}, {0.06 * s, 0.02 * s})
  elseif c.kind == "lattice" then
    m = ribbon({{cx - 0.14 * s, cy + 0.2 * s}, {cx + 0.12 * s, cy - 0.3 * s}}, 0.06 * s) + ribbon({{cx + 0.14 * s, cy + 0.2 * s}, {cx - 0.12 * s, cy - 0.3 * s}}, 0.06 * s)
      + ribbon({{cx, cy + 0.2 * s}, {cx - 0.02 * s, cy - 0.36 * s}}, 0.05 * s) + ribbon({{cx - 0.17 * s, cy - 0.05 * s}, {cx + 0.17 * s, cy - 0.05 * s}}, 0.03 * s)
  elseif c.kind == "woven" then
    m = ellipse(cx, cy, 0.2 * s, 0.16 * s)
  elseif c.kind == "mask" then
    m = ellipse(cx, cy - 0.08 * s, 0.13 * s, 0.21 * s)
  elseif c.kind == "seed" then
    m = ellipse(cx, cy + 0.02 * s, 0.065 * s, 0.1 * s) + ribbon({{cx, cy + 0.1 * s}, {cx, cy + 0.2 * s}}, 0.02 * s)
  end
  if m then
    m = (m + ribbon({{cx - 0.12 * s, cy + 0.22 * s}, {cx + 0.12 * s, cy + 0.22 * s}}, 0.035 * s)) * c.p.glassF
    work(m, {hand="body", tool={kind="filbert", width=math.max(1, 0.03 * s)}, pile=(c.kind == "woven" or c.kind == "mask") and objW or objD, coverage=6, fill=true, clip=m, angle=math.pi/2, load=1})
    OBJM[i] = m
  end
end
-- cold reflections of the glowing glass in the polished floor, under each case toward the aisle
local refl = pile{{"bone black",1.4},{"ultramarine ash",0.8},{"lead white",0.35}, medium=0.06}
for _, c in ipairs(CASES) do
  local inner = (c.X < 0) and 0.4 or -0.4
  local m = poly({pt(c.X - 0.38, FY, c.Z - 0.42), pt(c.X + 0.38, FY, c.Z - 0.42), pt(c.X + 0.38 + inner * 0.6, FY, c.Z - 1.3), pt(c.X - 0.38 + inner * 0.6, FY, c.Z - 1.3)}) * FLOOR - CASEM
  work(m, {hand="body", tool={kind="filbert", width=math.max(1.5, 0.1 * F / c.Z)}, pile=refl, coverage=3, fill=true, clip=m, angle=math.pi/2, load=0.8})
  blend(m:grow(3))
end
-- the Commando, small, foreground left of centre, his back to us, looking down the hall
local Z = 4.6
local k = F / Z
local fx, fy = P(-0.75, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.13,0.5), Q(-0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.25,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.23,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx - 0.03 * k, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.34,1.24), Q(-0.31,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
FIGM = fig
work(fig, {hand="body", tool="filbert 3", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=fig, angle=math.pi/2, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 8
-- the floor reflections came out as gray slabs: painted out to the floor and relaid barely lighter than it, soft;
-- then cold edges on the Commando from the cases either side, and rims on the near things
print(wait(3*24*60))
local fl = pile{{"bone black",1.7},{"burnt sienna",0.8},{"ultramarine blue",0.25}, medium=0.06}
local refl = pile{{"bone black",1.6},{"ultramarine ash",0.55},{"burnt sienna",0.4},{"lead white",0.12}, medium=0.06}
for _, c in ipairs(CASES) do
  local inner = (c.X < 0) and 0.4 or -0.4
  local m = poly({pt(c.X - 0.38, FY, c.Z - 0.42), pt(c.X + 0.38, FY, c.Z - 0.42), pt(c.X + 0.38 + inner * 0.6, FY, c.Z - 1.3), pt(c.X - 0.38 + inner * 0.6, FY, c.Z - 1.3)}):grow(4) * FLOOR - CASEM - FIGM
  local tw = {kind="filbert", width=math.max(1.5, 0.1 * F / c.Z)}
  work(m, {hand="body", tool=tw, pile=fl, coverage=6, fill=true, clip=m, angle=0, load=1})
  local r = poly({pt(c.X - 0.3, FY, c.Z - 0.42), pt(c.X + 0.3, FY, c.Z - 0.42), pt(c.X + 0.3 + inner * 0.3, FY, c.Z - 0.95), pt(c.X - 0.3 + inner * 0.3, FY, c.Z - 0.95)}) * FLOOR - CASEM - FIGM
  work(r, {hand="body", tool=tw, pile=refl, coverage=4, fill=true, clip=r, angle=math.pi/2, load=0.9})
  blend((r:grow(5) - r:shrink(3)) * FLOOR - CASEM - FIGM, {angle=math.pi/2})
end
local cold = pile{{"zinc white",1.6},{"ultramarine ash",0.5},{"lead white",0.4}, medium=0.05}
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(cold, 0.9); b:stroke(pts, {pressure=pr, clip=FIGM:grow(1)})
end
ln({Q(-0.13,1.86), Q(-0.07,1.9), Q(0.0,1.9)}, 1.6, {0.7, 0.4})
ln({Q(-0.4,1.55), Q(-0.41,1.3), Q(-0.38,1.0)}, 1.6, {0.8, 0.2})
ln({Q(0.39,1.55), Q(0.41,1.3), Q(0.38,1.0)}, 1.6, {0.8, 0.2})
ln({Q(-0.22,0.9), Q(-0.24,0.5), Q(-0.23,0.15)}, 1.2, {0.6, 0.05})
ln({Q(0.22,0.9), Q(0.24,0.5), Q(0.23,0.15)}, 1.2, {0.6, 0.05})
ln({Q(-0.38,1.6), Q(-0.28,1.63)}, 1.4, {0.6, 0.6})
ln({Q(0.28,1.63), Q(0.38,1.6)}, 1.4, {0.6, 0.6})
-- cold rims on the near things, on their upper edges toward the lamp
local rimC = pile{{"zinc white",2.5},{"cerulean blue",0.08}, medium=0.04}
for i, c in ipairs(CASES) do
  if OBJM[i] and c.Z < 9 then
    local s = F / c.Z
    local _, cy = P(0, FY - 1.25, c.Z)
    local b = brush{kind="round", width=math.max(0.7, 0.012 * s), point=0.5}
    b:load(rimC, 0.9)
    b:stroke({{c.cx - 0.12 * s, cy - 0.18 * s}, {c.cx, cy - 0.23 * s}, {c.cx + 0.12 * s, cy - 0.18 * s}}, {pressure={0.4, 0.4}, clip=OBJM[i]:grow(1)})
  end
end

--@ chunk 9
-- the last case made the focus: its glass brightest in the hall, its cold light thrown on the end wall and the floor round it
print(wait(2*24*60))
local p = LASTP
local cx = P(0, 0, LAST.Z)
local _, cy = P(0, FY - 1.4, LAST.Z)
local k = F / LAST.Z
local glow = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.6},{"zinc white",0.3}, medium=0.05}
local gm = ellipse(cx, cy, 1.6 * k, 1.5 * k) * (ENDW + FLOOR) - p.all - ellipse(cx, cy, 0.01, 0.01)
local function cov(x, y) local d = math.sqrt(((x - cx) / (1.6 * k))^2 + ((y - cy) / (1.5 * k))^2); return clamp(1 - d, 0, 1)^1.4 * 3 end
local dock = nil
stipple(gm, {pile=glow, width=0.9, coverage=cov, feather=0.9, cluster=0.15, dips={30, 0.6, 0}})
work(p.glassF, {hand="detail", pile=pile{{"zinc white",2.5},{"cerulean blue",0.1},{"lead white",0.3}, medium=0.04}, coverage=6, fill=true, clip=p.glassF, load=1})
local lamp = rect(cx - 0.2 * k, select(2, P(0, FY - 2.18, LAST.Z - 0.4)), 0.4 * k, 1.5) * p.glassF
work(lamp, {hand="detail", pile=pile{{"zinc white",3}, medium=0.03}, coverage=6, fill=true, clip=lamp, load=1})

--@ chunk 10
-- pass, 1 (dry): the Commando painted out of the aisle; the pillars given a dark side and a lit edge
print(wait(4*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local Fm = FIGM:grow(4)
local function fill(m, pl, ang, tool) m = m * Fm; work(m, {hand="body", tool=tool or "filbert 3", pile=pl, coverage=6, fill=true, clip=m, angle=ang or 0, load=1}) end
fill(FLOOR - CASEM, pile{{"bone black",1.7},{"burnt sienna",0.8},{"ultramarine blue",0.25}, medium=0.06}, toVP)
fill(ENDW - CASEM, pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.4}, medium=0.06}, math.pi/2)
fill((LWALL + RWALL) - PILS - CASEM, pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}, toVP)
fill(PILS - CASEM, pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",1}, medium=0.06}, math.pi/2)
for _, c in ipairs(CASES) do
  fill(c.p.plinth, pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}, 0)
  fill(c.p.cap, pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.8}, medium=0.06}, 0)
end
-- pillars: the half away from the hall's centre in shadow, a lit edge on the side toward the cases' light
local dk = pile{{"bone black",2},{"burnt sienna",0.7}, medium=0.06}
local lt = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.45},{"burnt sienna",0.2}, medium=0.06}
for _, Z in ipairs{2.2, 4.5, 6.9, 9.7, 12.9, 16.5, 20.5, 26} do
  for _, s in ipairs{-1, 1} do
    local w = math.max(2, 0.35 * F / Z)
    local wall = (s < 0) and LWALL or RWALL
    local a, b = pt(s * HW, FY, Z), pt(s * HW, FY - HT, Z)
    local shade = ribbon({{a[1] + s * w * 0.18, a[2]}, {b[1] + s * w * 0.18, b[2]}}, w * 0.62) * wall - CASEM
    work(shade, {hand="body", tool={kind="filbert", width=math.max(1.2, w * 0.4)}, pile=dk, coverage=6, fill=true, clip=shade, angle=math.pi/2, load=1})
    local br = brush{kind="round", width=math.max(0.8, w * 0.12), point=0.3}
    br:load(lt, 0.9)
    br:stroke({{a[1] - s * w * 0.42, a[2]}, {b[1] - s * w * 0.42, b[2]}}, {pressure={0.7, 0.4}, clip=wall - CASEM})
  end
end

--@ chunk 11
-- pass, 2: the glass repainted dark and nearly transparent, the bronze behind faintly through it; a narrow cold beam from
-- each lamp onto its thing; the things restated dark
print(wait(3*24*60))
local gS = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.4}, medium=0.06}
local gF = pile{{"bone black",1.8},{"burnt sienna",0.7},{"ultramarine ash",0.5},{"lead white",0.06}, medium=0.06}
local beamM = pile{{"bone black",1.1},{"ultramarine ash",0.8},{"lead white",0.45},{"zinc white",0.2}, medium=0.05}
local beamL = pile{{"zinc white",1.3},{"ultramarine ash",0.5},{"lead white",0.4},{"bone black",0.25}, medium=0.05}
local objD = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.2}, medium=0.06}
local objW = pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.9}, medium=0.06}
local behind = pile{{"burnt sienna",1},{"raw sienna",0.5},{"bone black",1.1}, medium=0.06}
local order = {}
for i, c in ipairs(CASES) do c.i = i; order[#order+1] = c end
table.sort(order, function(a, b) return a.Z > b.Z end)
for _, c in ipairs(order) do
  local p = c.p
  local k = c.k
  local tw = {kind="filbert", width=math.max(1.5, 0.1 * k)}
  if p.glassS then work(p.glassS, {hand="body", tool=tw, pile=gS, coverage=6, fill=true, clip=p.glassS, angle=math.pi/2, load=1}) end
  work(p.glassF, {hand="body", tool=tw, pile=gF, coverage=6, fill=true, clip=p.glassF, angle=math.pi/2, load=1})
  -- the bronze wall faintly through the glass: a vertical warm band on the wall side
  local x0 = P(c.X - 0.4, 0, c.Z - 0.4); local x1 = P(c.X + 0.4, 0, c.Z - 0.4)
  local wx = (c.X < 0) and x0 or x1
  local wb = rect(math.min(wx, wx + ((c.X < 0) and 1 or -1) * 0.18 * k), 0, 0.18 * k, 1000) * p.glassF
  work(wb, {hand="body", tool=tw, pile=behind, coverage=4, fill=true, clip=wb, angle=math.pi/2, load=0.8})
  -- the beam: narrow, from the lamp strip down to the thing
  local cx, yt = c.cx, c.yt
  local _, yo = P(0, FY - 1.25, c.Z)
  local beam = poly({{cx - 0.06 * k, yt}, {cx + 0.06 * k, yt}, {cx + 0.16 * k, yo}, {cx - 0.16 * k, yo}}) * p.glassF
  local core = poly({{cx - 0.025 * k, yt}, {cx + 0.025 * k, yt}, {cx + 0.08 * k, yo}, {cx - 0.08 * k, yo}}) * p.glassF
  work(beam - core, {hand="body", tool={kind="filbert", width=math.max(1, 0.05 * k)}, pile=beamM, coverage=4, fill=true, clip=beam - core, angle=math.pi/2, load=0.9})
  work(core, {hand="body", tool={kind="filbert", width=math.max(1, 0.04 * k)}, pile=beamL, coverage=4, fill=true, clip=core, angle=math.pi/2, load=0.9})
  blend((beam:grow(0.03 * k) - beam:shrink(0.02 * k)) * p.glassF, {angle=math.pi/2})
  local ls = rect(cx - 0.14 * k, yt + 0.01 * k, 0.28 * k, math.max(1.5, 0.03 * k)) * p.glassF
  work(ls, {hand="detail", pile=pile{{"zinc white",3}, medium=0.03}, coverage=5, fill=true, clip=ls, load=1})
  if OBJM[c.i] then
    work(OBJM[c.i], {hand="body", tool={kind="filbert", width=math.max(1, 0.03 * k)}, pile=(c.kind == "woven" or c.kind == "mask") and objW or objD, coverage=6, fill=true, clip=OBJM[c.i], angle=math.pi/2, load=1})
  end
  -- a small bright pool where the beam lands on the stand
  local pl = ellipse(cx, yo + 0.24 * F / c.Z, 0.12 * k, 0.025 * k) * p.glassF
  work(pl, {hand="detail", pile=beamL, coverage=4, fill=true, clip=pl, load=0.9})
end

--@ chunk 12
-- pass, 3: the far case larger and nearer (Z 19), blazing, its blank label, the docent beside it, stylus raised;
-- the Commando small at the left by the second case, looking down the hall
print(wait(2*24*60))
local Z = 19
local c = {X=0, Z=Z}
local x0, x1, z0 = -0.5, 0.5, Z - 0.5
local function front(y0, y1) return poly({pt(x0, y0, z0), pt(x1, y0, z0), pt(x1, y1, z0), pt(x0, y1, z0)}) end
local plinth, glass, cap = front(FY, FY - 0.75), front(FY - 0.75, FY - 2.45), front(FY - 2.45, FY - 2.62)
local k = F / z0
work(plinth, {hand="body", tool="filbert 3", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.35}, medium=0.06}, coverage=6, fill=true, clip=plinth, angle=0, load=1})
work(cap, {hand="detail", pile=pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.45}, medium=0.06}, coverage=6, fill=true, clip=cap, load=1})
work(glass, {hand="body", tool="filbert 2", pile=pile{{"zinc white",2.5},{"cerulean blue",0.1},{"lead white",0.3}, medium=0.04}, coverage=6, fill=true, clip=glass, angle=math.pi/2, load=1})
local edgeL = {pt(x0, FY - 0.75, z0), pt(x0, FY - 2.45, z0)}
local edgeR = {pt(x1, FY - 0.75, z0), pt(x1, FY - 2.45, z0)}
for _, e in ipairs{edgeL, edgeR} do local b = brush{kind="round", width=1.6}; b:load(pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.5}, medium=0.06}, 0.9); b:stroke(e, {pressure={0.9, 0.9}}) end
local lx0, ly0 = P(-0.22, FY - 0.55, z0); local lx1, ly1 = P(0.22, FY - 0.38, z0)
local L = rect(lx0, ly0, lx1 - lx0, ly1 - ly0)
work(L, {hand="detail", pile=pile{{"lead white",2},{"yellow ochre",0.2}, medium=0.05}, coverage=6, fill=true, clip=L, load=1})
-- its light on the floor before it
local fp = poly({pt(-0.6, FY, z0), pt(0.6, FY, z0), pt(0.8, FY, z0 - 1.6), pt(-0.8, FY, z0 - 1.6)}, true)
work(fp, {hand="body", tool="filbert 3", pile=pile{{"bone black",1.2},{"ultramarine ash",0.7},{"lead white",0.45}, medium=0.05}, coverage=4, fill=true, clip=fp, angle=math.pi/2, load=0.9})
blend(fp:grow(4) - fp:shrink(4), {angle=math.pi/2})
-- the docent to its right, three-quarter toward it, stylus raised over the label
local dz = Z - 0.2
local dk = F / dz
local bx, by = P(0.95, FY, dz)
local robe = poly({{bx - 0.17 * dk, by - 1.45 * dk}, {bx + 0.13 * dk, by - 1.45 * dk}, {bx + 0.3 * dk, by}, {bx - 0.32 * dk, by}}, true)
work(robe, {hand="body", tool="filbert 2", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.3}, medium=0.06}, coverage=6, fill=true, clip=robe, angle=math.pi/2, load=1})
local head = ellipse(bx - 0.03 * dk, by - 1.58 * dk, 0.1 * dk, 0.12 * dk)
work(head, {hand="detail", pile=pile{{"bone black",1.4},{"burnt sienna",1}, medium=0.06}, coverage=6, fill=true, clip=head, load=1})
local face = ellipse(bx - 0.09 * dk, by - 1.58 * dk, 0.055 * dk, 0.09 * dk)
work(face, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.4}, medium=0.05}, coverage=6, fill=true, clip=face, load=1})
local arm = ribbon({{bx - 0.1 * dk, by - 1.25 * dk}, {bx - 0.36 * dk, by - 1.38 * dk}, {bx - 0.46 * dk, by - 1.62 * dk}}, {0.08 * dk, 0.07 * dk, 0.05 * dk})
work(arm, {hand="detail", pile=pile{{"bone black",1.4},{"burnt sienna",1}, medium=0.06}, coverage=6, fill=true, clip=arm, load=1})
local sb = brush{kind="round", width=1.4, point=0.5}
sb:load(pile{{"lead white",2},{"yellow ochre",0.4}, medium=0.05}, 0.9)
sb:stroke({{bx - 0.46 * dk, by - 1.62 * dk}, {bx - 0.5 * dk, by - 1.95 * dk}}, {pressure={0.9, 0.4}})
local rim = brush{kind="round", width=1.2, point=0.5}
rim:load(pile{{"zinc white",2.5}, medium=0.03}, 0.9)
rim:stroke({{bx - 0.17 * dk, by - 1.43 * dk}, {bx - 0.31 * dk, by - 0.1 * dk}}, {pressure={0.7, 0.2}})
-- the Commando, small, at the left by the second case, his back to us, turned a little toward the hall
local fz = 6.3
local k2 = F / fz
local fx, fy = P(-1.45, FY, fz)
local function Q(x, y) return {fx + x * k2, fy - y * k2} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.13,0.5), Q(-0.14,0.1)}, {0.17*k2, 0.13*k2, 0.11*k2})
  + ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k2, 0.13*k2, 0.11*k2})
  + poly({Q(-0.25,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.23,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx + 0.03 * k2, fy - 1.76 * k2, 0.105 * k2, 0.13 * k2)
  + ellipse(fx - 0.29 * k2, fy - 1.54 * k2, 0.12 * k2, 0.08 * k2) + ellipse(fx + 0.29 * k2, fy - 1.54 * k2, 0.12 * k2, 0.08 * k2)
  + ribbon({Q(-0.3,1.5), Q(-0.34,1.24), Q(-0.31,0.98)}, {0.12*k2, 0.1*k2, 0.09*k2})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k2, 0.1*k2, 0.09*k2})
FIGN = fig
work(fig, {hand="body", tool="filbert 2", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=fig, angle=math.pi/2, load=1})
FK2, FX2, FY2 = k2, fx, fy

--@ chunk 13
-- pass, 4 (dry): the things' top edges glinting; a bright reflection streak down one edge of each glass; the Commando's cold edges
print(wait(4*24*60))
local rimC = pile{{"zinc white",2.5},{"cerulean blue",0.08}, medium=0.04}
local streak = pile{{"zinc white",2},{"lead white",0.5}, medium=0.04}
for _, c in ipairs(CASES) do
  local k = c.k
  local s = F / c.Z
  local _, cy = P(0, FY - 1.25, c.Z)
  if OBJM[c.i] then
    local b = brush{kind="round", width=math.max(0.7, 0.014 * s), point=0.5}
    b:load(rimC, 0.95)
    b:stroke({{c.cx - 0.13 * s, cy - 0.17 * s}, {c.cx, cy - 0.24 * s}, {c.cx + 0.13 * s, cy - 0.17 * s}}, {pressure={0.5, 0.5}, clip=OBJM[c.i]:grow(1)})
  end
  local xe = P(c.X + ((c.X < 0) and 0.33 or -0.33), 0, c.Z - 0.4)
  local _, y0 = P(0, FY - 2.1, c.Z - 0.4); local _, y1 = P(0, FY - 0.85, c.Z - 0.4)
  local sb = brush{kind="round", width=math.max(0.8, 0.02 * k), point=0.5}
  sb:load(streak, 0.9)
  sb:stroke({{xe, y0}, {xe - ((c.X < 0) and 1 or -1) * 0.04 * k, y1}}, {pressure={0.8, 0.1}, clip=c.p.glassF})
end
local k, fx, fy = FK2, FX2, FY2
local function Q(x, y) return {fx + x * k, fy - y * k} end
local cold = pile{{"zinc white",1.6},{"ultramarine ash",0.5},{"lead white",0.4}, medium=0.05}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(cold, 0.9); b:stroke(pts, {pressure=pr, clip=FIGN:grow(1)})
end
ln({Q(-0.1,1.86), Q(-0.04,1.9), Q(0.06,1.89)}, 1.5, {0.8, 0.5})
ln({Q(-0.4,1.55), Q(-0.42,1.3), Q(-0.38,1.0)}, 1.4, {0.8, 0.2})
ln({Q(-0.38,1.6), Q(-0.28,1.63)}, 1.3, {0.6, 0.6})
ln({Q(-0.22,0.9), Q(-0.24,0.5), Q(-0.23,0.15)}, 1.1, {0.6, 0.05})

--@ chunk 14
-- the Commando went translucent over still-wet paint: restate him opaque on set paint, then his cold edges
print(wait(5*24*60))
local fd = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}
work(FIGN, {hand="body", tool="filbert 2", pile=fd, coverage=7, fill=true, clip=FIGN, angle=math.pi/2, load=1})
work(FIGN, {hand="detail", pile=fd, coverage=5, fill=true, clip=FIGN, load=1})
print(wait(3*24*60))
local k, fx, fy = FK2, FX2, FY2
local function Q(x, y) return {fx + x * k, fy - y * k} end
local cold = pile{{"zinc white",1.6},{"ultramarine ash",0.5},{"lead white",0.4}, medium=0.05}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(cold, 0.9); b:stroke(pts, {pressure=pr, clip=FIGN:grow(1)})
end
ln({Q(-0.1,1.86), Q(-0.04,1.9), Q(0.06,1.89)}, 1.5, {0.8, 0.5})
ln({Q(-0.4,1.55), Q(-0.42,1.3), Q(-0.38,1.0)}, 1.4, {0.8, 0.2})
ln({Q(-0.38,1.6), Q(-0.28,1.63)}, 1.3, {0.6, 0.6})
ln({Q(0.38,1.6), Q(0.41,1.3)}, 1.2, {0.6, 0.2})
