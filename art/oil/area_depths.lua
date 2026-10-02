-- easel session "area_depths": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=4471, ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=80, apply="knife", texture=0.3},{pile={{"burnt sienna",2},{"ultramarine blue",2},{"raw sienna",1},{"lead white",2}}, um=30, apply="brush"}}}

--@ chunk 2
-- geometry: a tunnel of handmade hexagonal frames, each turned and shrunk
VPX, VPY = 532, 296
FR = {}
local r, rot = 640, -0.35
for i = 0, 12 do
  local t = 1 - (r / 640)
  local cx = lerp(505, VPX, t^0.6) + randn(0, 2) * (1 - t)
  local cy = lerp(345, VPY, t^0.6) + randn(0, 2) * (1 - t)
  local outer, inner = {}, {}
  local band = rand(0.12, 0.15)
  for v = 0, 5 do
    local a = rot + v * math.pi / 3 + randn(0, 0.012)
    local ro = r * (1 + randn(0, 0.018))
    local ri = ro * (1 - band) * (1 + randn(0, 0.01))
    outer[#outer + 1] = {cx + ro * math.cos(a), cy + ro * math.sin(a)}
    inner[#inner + 1] = {cx + ri * math.cos(a), cy + ri * math.sin(a)}
  end
  FR[i] = {cx = cx, cy = cy, r = r, rot = rot, outer = outer, inner = inner}
  r = r * rand(0.69, 0.75)
  rot = rot + rand(0.13, 0.19)
end
for i = 0, 12 do print(i, math.floor(FR[i].r), string.format("%.2f", FR[i].rot), math.floor(FR[i].cx), math.floor(FR[i].cy)) end

--@ chunk 3
WP = {
  pile{{"ultramarine blue",2},{"burnt sienna",1.2},{"bone black",0.6}},
  pile{{"ultramarine blue",2},{"burnt sienna",1.5},{"raw sienna",0.5},{"lead white",0.25}},
  pile{{"bone brown",1},{"ultramarine blue",1},{"yellow ochre",0.6},{"lead white",0.7}},
  pile{{"raw sienna",1},{"ultramarine ash",1},{"lead white",1.6},{"bone black",0.15}},
  pile{{"lead white",3},{"yellow ochre",0.6},{"ultramarine ash",0.5}},
  pile{{"lead white",4},{"zinc white",1},{"yellow ochre",0.3}},
}
RAD = function(x, y) return math.atan(y - VPY, x - VPX) end
function wallzone(k)
  local m = poly(FR[k].inner)
  if k < 12 then m = m - poly(FR[k + 1].outer) end
  return m
end
function wallpile(k)
  local idx = ({1,1,2,2,3,3,4,4,5,5,6,6,6})[k + 1]
  return WP[idx]
end
for k = 0, 1 do
  work(wallzone(k), {hand="body", pile=wallpile(k), angle=RAD, coverage=2.5, fill=true, clip=true})
end

--@ chunk 4
for k = 2, 12 do work(wallzone(k), {hand=(k<7) and "body" or "detail", pile=wallpile(k), angle=RAD, coverage=2.5, fill=true, clip=true}) end

--@ chunk 5
wait(240)
FP = {
  pile{{"bone black",2},{"burnt sienna",1.2},{"yellow ochre",1},{"ultramarine blue",0.4}},
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1},{"ultramarine blue",0.4}},
  pile{{"raw sienna",2},{"bone black",0.5},{"lead white",1},{"ultramarine ash",0.6}},
  pile{{"yellow ochre",1},{"raw sienna",1},{"lead white",1.6},{"ultramarine ash",0.5}},
}
TAN = function(x, y) return math.atan(y - VPY, x - VPX) + math.pi / 2 end
function face(k) return poly(FR[k].outer) - poly(FR[k].inner) end
function facepile(k) return FP[({1,1,1,2,2,2,3,3,3,4,4,4,4})[k + 1]] end
for k = 0, 12 do
  work(face(k), {hand=(k<6) and "body" or "detail", pile=facepile(k), angle=TAN, coverage=2.5, fill=true, clip=true})
end

--@ chunk 6
print(wait(2 * 24 * 60))
DARKR = {{"ultramarine blue",2},{"burnt sienna",1.6},{"bone black",0.5},{"raw sienna",0.3}}
MIDR = {{"raw sienna",1},{"ultramarine ash",1.2},{"bone brown",0.6},{"lead white",0.9}}
LIGHTR = {{"lead white",3},{"yellow ochre",0.5},{"ultramarine ash",0.6},{"zinc white",0.5}}
function mixr(a, b, t)
  local parts, out = {}, {}
  for _, e in ipairs(a) do parts[e[1]] = (parts[e[1]] or 0) + e[2] * (1 - t) end
  for _, e in ipairs(b) do parts[e[1]] = (parts[e[1]] or 0) + e[2] * t end
  for _, n in ipairs({"ultramarine blue","burnt sienna","bone black","raw sienna","ultramarine ash","bone brown","lead white","yellow ochre","zinc white"}) do
    if parts[n] and parts[n] > 0.01 then out[#out + 1] = {n, parts[n]} end
  end
  return out
end
function wallmix(t)
  t = clamp(t, 0, 1)
  if t < 0.5 then return pile(mixr(DARKR, MIDR, t * 2)) end
  return pile(mixr(MIDR, LIGHTR, (t - 0.5) * 2))
end
-- the corners beyond the nearest frame
work(everywhere() - poly(FR[0].outer), {hand="body", pile=FP[1], angle=TAN, coverage=2.5, fill=true, clip=true})
-- each wall facet between frame k's opening and frame k+1's outer edge
FACET = {0.10, 0.02, -0.05, -0.08, -0.02, 0.06}
for k = 0, 11 do
  local a, b = FR[k].inner, FR[k + 1].outer
  local tb = (k / 12) ^ 1.25
  for v = 1, 6 do
    local w = v % 6 + 1
    -- which facet faces down decides its lift; floors are nominal, they turn with the frames
    local mx = (a[v][1] + a[w][1]) / 2 - FR[k].cx
    local my = (a[v][2] + a[w][2]) / 2 - FR[k].cy
    local down = my / math.sqrt(mx * mx + my * my)
    local t = tb + 0.09 * down + randn(0, 0.02)
    local m = poly({a[v], a[w], b[w], b[v]})
    work(m, {hand=(k < 6) and "body" or "detail", pile=wallmix(t), angle=RAD, coverage=2.5, fill=true, clip=true})
  end
end

--@ chunk 7
local x=mixr({{"bone black",1}},{{"raw sienna",1}},0.5) print(#x)

--@ chunk 8
print(wait(24 * 60))
VD = {{"bone black",1.6},{"ultramarine blue",1.4},{"burnt sienna",1.0}}
VM = {{"ultramarine blue",1.5},{"burnt sienna",1.3},{"raw sienna",0.8},{"ultramarine ash",0.6}}
for k = 0, 4 do
  local a, b = FR[k].inner, FR[k + 1].outer
  for v = 1, 6 do
    local w = v % 6 + 1
    local mx = (a[v][1] + a[w][1]) / 2 - FR[k].cx
    local my = (a[v][2] + a[w][2]) / 2 - FR[k].cy
    local down = my / math.sqrt(mx * mx + my * my)
    local t = clamp(k / 5 + 0.2 * down + randn(0, 0.04), 0, 1)
    local m = poly({a[v], a[w], b[w], b[v]})
    work(m, {hand="body", pile=pile(mixr(VD, VM, t)), angle=RAD, coverage=3, fill=true, clip=true})
  end
end

--@ chunk 9
print(drying(150,200), drying(60,300), drying(300,560))

--@ chunk 10
print(wait(4 * 24 * 60)) print(drying(60,300))
RVA = {{"raw sienna",1},{"burnt sienna",0.6},{"yellow ochre",0.8},{"lead white",0.6},{"ultramarine ash",0.5}}
RVB = {{"lead white",3},{"yellow ochre",0.7},{"zinc white",0.6},{"ultramarine ash",0.2}}
function reveal_pts(k, f)
  local out = {}
  for i, p in ipairs(FR[k].inner) do
    out[i] = {p[1] + (VPX - p[1]) * f, p[2] + (VPY - p[2]) * f}
  end
  return out
end
REV = {}
for k = 0, 10 do
  local a = FR[k].inner
  local b = reveal_pts(k, rand(0.06, 0.09))
  REV[k] = b
  for v = 1, 6 do
    local w = v % 6 + 1
    local mx = (a[v][1] + a[w][1]) / 2 - FR[k].cx
    local my = (a[v][2] + a[w][2]) / 2 - FR[k].cy
    local down = my / math.sqrt(mx * mx + my * my)
    local t = clamp(0.1 + 0.75 * (k / 10) - 0.18 * down + randn(0, 0.05), 0, 1)
    local m = poly({a[v], a[w], b[w], b[v]})
    work(m, {hand=(k < 4) and "body" or "detail", pile=pile(mixr(RVA, RVB, t)), angle=RAD, coverage=3, fill=true, clip=true})
  end
end

--@ chunk 11
print(wait(24 * 60))
RD = {{"bone black",0.9},{"raw sienna",1},{"burnt sienna",0.4},{"ultramarine blue",1},{"yellow ochre",0.3}}
local tk = {[0]=0.05, 0.22, 0.4, 0.58, 0.78}
for k = 0, 4 do
  local a, b = FR[k].inner, REV[k]
  for v = 1, 6 do
    local w = v % 6 + 1
    local mx = (a[v][1] + a[w][1]) / 2 - FR[k].cx
    local my = (a[v][2] + a[w][2]) / 2 - FR[k].cy
    local ang = math.atan(my, mx)
    -- light from the deep core, a little from above-left in the depths
    local lit = math.cos(ang - 1.9)
    local t = clamp(tk[k] + 0.18 * lit + randn(0, 0.05), 0, 1)
    local m = poly({a[v], a[w], b[w], b[v]})
    work(m, {hand="body", pile=pile(mixr(RD, RVA, t)), angle=RAD, coverage=3.5, fill=true, clip=true})
  end
end

--@ chunk 12
print(wait(2 * 24 * 60))
-- the walkway: a straight bone causeway down the axis while the frames turn round it
WB = {505, 712}
function wpt(s, side)   -- s: 0 near .. 1 at VP; side -1..1 across
  local hw = 52 * (1 - s) ^ 1.0
  local x = lerp(WB[1], VPX, s) + side * hw
  local y = lerp(WB[2], VPY, s)
  return {x, y}
end
WALK = poly({wpt(0, -1), wpt(0, 1), wpt(0.93, 1), wpt(0.93, -1)})
WSIDE = poly({wpt(0, 1), {wpt(0, 1)[1] + 2, wpt(0, 1)[2] + 30}, {wpt(0.93, 1)[1], wpt(0.93, 1)[2] + 2}, wpt(0.93, 1)})
local BN = {{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.5},{"ultramarine ash",0.6},{"bone brown",0.25}}
local BF = {{"lead white",3},{"zinc white",0.6},{"yellow ochre",0.5},{"ultramarine ash",0.3}}
work(WSIDE, {hand="detail", pile=pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.8}}, angle=RAD, coverage=3, fill=true, clip=true})
local segs = {0, 0.2, 0.4, 0.58, 0.72, 0.84, 0.93}
for i = 1, #segs - 1 do
  local m = WALK * (above(function(x) return lerp(WB[2], VPY, segs[i]) end) - above(function(x) return lerp(WB[2], VPY, segs[i + 1]) end))
  work(m, {hand=(i < 3) and "body" or "detail", pile=pile(mixr(BN, BF, (i - 1) / 5)), angle=RAD, coverage=3, fill=true, clip=true})
end

--@ chunk 13
-- the records stack: shelves of upright tablets lining every facet, running away into the depth
TA = {{"raw sienna",1},{"yellow ochre",0.6},{"lead white",0.7},{"ultramarine ash",0.6},{"bone black",0.15}}
TB = {{"lead white",3},{"yellow ochre",0.6},{"ultramarine ash",0.4}}
function bil(p0, p1, q0, q1, u, s)
  local nx, ny = lerp(p0[1], p1[1], u), lerp(p0[2], p1[2], u)
  local fx, fy = lerp(q0[1], q1[1], u), lerp(q0[2], q1[2], u)
  -- perspective: depth parameter s compresses toward the far edge
  return {lerp(nx, fx, s), lerp(ny, fy, s)}
end
function stack(k, v, shelves, n, tbase)
  local w = v % 6 + 1
  local p0, p1 = REV[k][v], REV[k][w]
  local q0, q1 = FR[k + 1].outer[v], FR[k + 1].outer[w]
  local ln = math.sqrt((p1[1] - p0[1])^2 + (p1[2] - p0[2])^2)
  local lf = math.sqrt((q1[1] - q0[1])^2 + (q1[2] - q0[2])^2)
  local pl = {}
  for j = 0, 4 do pl[j] = pile(mixr(TA, TB, clamp(tbase + 0.12 * (j - 2) / 2, 0, 1))) end
  local du = 1 / shelves
  for sh = 0, shelves - 1 do
    local u0 = sh * du + du * 0.12
    local u1 = (sh + 1) * du - du * 0.12
    local s = rand(0.02, 0.06)
    while s < 0.97 do
      -- scale at this depth: near edge length ln, far lf
      local sc = lerp(ln, lf, s)
      local bw = math.max(0.5, sc / n * 0.55)
      local a = bil(p0, p1, q0, q1, lerp(u0, u1, rand(0, 0.08)), s)
      local b = bil(p0, p1, q0, q1, lerp(u0, u1, rand(0.85, 1)), s)
      if math.random() > 0.12 then
        local br = brush{kind="flat", width=bw, stiffness=0.6}
        br:load(pl[math.random(0, 4)], rand(0.6, 0.9))
        br:stroke({a, b}, {pressure={0.7, 0.6}, orient="across"})
      end
      s = s + (sc / n) / math.max(ln, 1) * rand(0.7, 1.3) * (1 - s * 0.3) * 1.0
    end
  end
end
local tk = {[0]=0.0, 0.08, 0.2, 0.32, 0.45, 0.58}
for k = 1, 1 do
  for v = 1, 6 do stack(k, v, 3, 34, tk[k]) end
end

--@ chunk 14
print(wait(24 * 60), drying(250, 120))
function wallfacet(k, v)
  local a, b = REV[k] or FR[k].inner, FR[k + 1].outer
  local w = v % 6 + 1
  return poly({a[v], a[w], b[w], b[v]})
end
for v = 1, 6 do
  local k = 1
  local a = FR[k].inner
  local w = v % 6 + 1
  local mx = (a[v][1] + a[w][1]) / 2 - FR[k].cx
  local my = (a[v][2] + a[w][2]) / 2 - FR[k].cy
  local down = my / math.sqrt(mx * mx + my * my)
  local t = clamp(k / 5 + 0.2 * down + randn(0, 0.04), 0, 1)
  work(wallfacet(k, v) - WALK:grow(1), {hand="body", pile=pile(mixr(VD, VM, t)), angle=RAD, coverage=3.5, fill=true, clip=true})
end

--@ chunk 15
TA = {{"raw sienna",1},{"bone brown",0.5},{"ultramarine ash",0.7},{"lead white",0.35},{"yellow ochre",0.3}}
TB = {{"lead white",2},{"yellow ochre",0.5},{"ultramarine ash",0.5},{"raw sienna",0.3}}
function stack2(k, v, shelves, n, tbase, nolast)
  local w = v % 6 + 1
  local p0, p1 = REV[k][v], REV[k][w]
  local q0, q1 = FR[k + 1].outer[v], FR[k + 1].outer[w]
  local ln = math.sqrt((p1[1] - p0[1])^2 + (p1[2] - p0[2])^2)
  local lf = math.sqrt((q1[1] - q0[1])^2 + (q1[2] - q0[2])^2)
  local D = math.sqrt(((q0[1]+q1[1]) - (p0[1]+p1[1]))^2 + ((q0[2]+q1[2]) - (p0[2]+p1[2]))^2) / 2
  local pl = {}
  for j = 0, 3 do pl[j] = pile(mixr(TA, TB, clamp(tbase + 0.1 * (j - 1.5), 0, 1))) end
  local cl = (FR[k].inner and (poly({p0, p1, q1, q0}))) - WALK:grow(3)
  local du = 1 / shelves
  local strokes = 0
  for sh = 0, shelves - 1 do
    local u0 = sh * du + du * 0.14
    local u1 = (sh + 1) * du - du * 0.14
    local s = rand(0.03, 0.08)
    local br = nil
    while s < 0.96 do
      local sc = lerp(ln, lf, s)
      local gap = sc / n
      local a = bil(p0, p1, q0, q1, lerp(u0, u1, rand(0, 0.1)), s)
      local b = bil(p0, p1, q0, q1, lerp(u0, u1, rand(0.82, 1)), s)
      if math.random() > 0.15 then
        local bw = math.max(0.45, gap * rand(0.3, 0.45))
        br = brush{kind="flat", width=bw, stiffness=0.6}
        br:load(pl[math.random(0, 3)], rand(0.5, 0.8))
        br:stroke({a, b}, {pressure={0.6, 0.5}, orient="across", clip=cl})
        strokes = strokes + 1
      end
      s = s + gap * rand(0.8, 1.4) / D
    end
  end
  return strokes
end
print(stack2(2, 4, 3, 30, 0.25))

--@ chunk 16
for v=1,6 do local w=v%6+1 print(v, math.floor(REV[2][v][1]),math.floor(REV[2][v][2]), math.floor(FR[3].outer[v][1]), math.floor(FR[3].outer[v][2])) end

--@ chunk 17
local c=0 for v=1,6 do c=c+stack2(1, v, 8, 55, 0.05) end for v=1,6 do c=c+stack2(2, v, 7, 50, 0.15) end print(c)

--@ chunk 18
local c=0 for v=1,6 do c=c+stack2(0, v, 10, 60, 0.0) end for v=1,6 do c=c+stack2(3, v, 6, 45, 0.3) end for v=1,6 do c=c+stack2(4, v, 5, 40, 0.45) end print(c)

--@ chunk 19
GLP = pile{{"lead white",3},{"yellow ochre",0.4},{"ultramarine ash",0.35},{"raw sienna",0.1}}
GLD = pile{{"bone black",1},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
function bandpt(k, v, t)
  local w = v % 6 + 1
  local o, i = FR[k].outer, FR[k].inner
  local ox, oy = lerp(o[v][1], o[w][1], t), lerp(o[v][2], o[w][2], t)
  local ix, iy = lerp(i[v][1], i[w][1], t), lerp(i[v][2], i[w][2], t)
  return (ox + ix) / 2, (oy + iy) / 2, math.sqrt((ox - ix)^2 + (oy - iy)^2)
end
-- fold-notation: a hexagon holding a turned, smaller copy of itself, holding another...
function glyph(cx, cy, r, rot, levels, turn, shrink, p, lw)
  local br = brush{kind="rigger", width=lw * 2.2, point=0.8, stiffness=0.4}
  for L = 0, levels - 1 do
    local pts = {}
    for v = 0, 6 do
      local a = rot + v * math.pi / 3
      pts[#pts + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}
    end
    br:load(p, 0.8)
    br:stroke(pts, {pressure={0.55, 0.5}, shake=0.3})
    r = r * shrink
    rot = rot + turn
  end
  br:load(p, 0.7)
  br:touch(cx, cy, {pressure=0.5})
end
local placed = 0
local spec = { {1, {{2,0.3},{4,0.62},{6,0.45}}}, {2, {{1,0.55},{3,0.3},{5,0.7}}}, {3, {{2,0.68},{5,0.25}}}, {4, {{3,0.5},{6,0.4}}} }
for _, s in ipairs(spec) do
  local k = s[1]
  for _, e in ipairs(s[2]) do
    local x, y, bw = bandpt(k, e[1], e[2])
    glyph(x, y, bw * 0.36, FR[k].rot + rand(-0.2, 0.2), 4 + math.random(0, 1), rand(0.22, 0.32), rand(0.74, 0.8), GLP, math.max(0.35, bw / 70))
    placed = placed + 1
  end
end
print(placed)

--@ chunk 20
print(wait(24 * 60))
GSPOT = {}
local spec = { {1, {{2,0.3},{4,0.62},{6,0.45}}}, {2, {{1,0.55},{3,0.3},{5,0.7}}}, {3, {{2,0.68},{5,0.25}}}, {4, {{3,0.5},{6,0.4}}} }
for _, s in ipairs(spec) do
  local k = s[1]
  for _, e in ipairs(s[2]) do
    local x, y, bw = bandpt(k, e[1], e[2])
    GSPOT[#GSPOT + 1] = {k = k, x = x, y = y, bw = bw}
    work(ellipse(x, y, bw * 0.43, bw * 0.43) * face(k), {hand="detail", pile=facepile(k), coverage=4, fill=true, clip=true})
  end
end

--@ chunk 21
function glyph(cx, cy, r, rot, levels, turn, shrink, p, lw)
  local br = brush{kind="round", width=lw * 2, point=0.6, stiffness=0.5}
  for L = 0, levels - 1 do
    local pts = {}
    for v = 0, 5 do
      local a = rot + v * math.pi / 3 + randn(0, 0.01)
      pts[#pts + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}
    end
    for v = 1, 6 do
      local a, b = pts[v], pts[v % 6 + 1]
      br:load(p, 0.75)
      br:stroke({a, b}, {pressure={0.6, 0.55}, ramps={0.05, 0.05}, shake=0.2})
    end
    r = r * shrink
    rot = rot + turn
  end
  br:load(p, 0.8)
  br:touch(cx, cy, {pressure=0.6})
end
for i, g in ipairs(GSPOT) do
  glyph(g.x, g.y, g.bw * 0.37, FR[g.k].rot + rand(-0.25, 0.25), 4 + (i % 2), rand(0.2, 0.3) * ((i % 3 == 0) and -1 or 1), rand(0.72, 0.79), GLP, math.max(0.3, g.bw / 75))
end

--@ chunk 22
print(wait(5 * 24 * 60), drying(60,300), drying(150,200), drying(100,500), drying(505,640))
GW = pile{{"bone black",1.2},{"ultramarine blue",1},{"burnt sienna",0.8},medium=0.8}
local m = everywhere() - poly(FR[1].outer)
local function ld(x, y)
  local d = math.sqrt((x - VPX)^2 + ((y - VPY) * 1.3)^2)
  return clamp(0.25 + (d - 380) / 300 * 0.45, 0.2, 0.7)
end
work(m, {hand="glaze", pile=GW, load_at=ld, angle=RAD, coverage=1.5, clip=true})
blend(m, {angle=RAD})

--@ chunk 23
local WD = {{"raw sienna",1},{"ultramarine ash",1},{"bone brown",0.7},{"lead white",0.5}}
local BF = {{"lead white",3},{"zinc white",0.6},{"yellow ochre",0.5},{"ultramarine ash",0.3}}
local segs = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.93}
for i = 1, #segs - 1 do
  local m = WALK * (above(function(x) return lerp(WB[2], VPY, segs[i]) end) - above(function(x) return lerp(WB[2], VPY, segs[i + 1]) end))
  local t = ((i - 1) / (#segs - 2)) ^ 1.3
  work(m, {hand=(i < 5) and "body" or "detail", pile=pile(mixr(WD, BF, t)), angle=RAD, coverage=3.5, fill=true, clip=true})
end

--@ chunk 24
blend(WALK, {angle=RAD}) print(wait(8*24*60), drying(60,300), drying(30,630), drying(505,640))

--@ chunk 25
GW2 = pile{{"bone black",1},{"ultramarine blue",1.2},{"burnt sienna",0.7},medium=0.62}
local m = everywhere() - poly(FR[2].outer):soften(6)
local function ld(x, y)
  local d = math.sqrt((x - VPX)^2 + ((y - VPY) * 1.35)^2)
  return clamp(0.15 + (d - 260) / 380 * 0.6, 0.12, 0.8)
end
work(m, {hand="glaze", pile=GW2, load_at=ld, angle=RAD, coverage=2, clip=true})
blend(m, {angle=RAD})

--@ chunk 26
CORE = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.08}}
work(poly(FR[12].inner):grow(1), {hand="detail", pile=CORE, coverage=4, fill=true, clip=true})
VEIL = pile{{"zinc white",2},{"lead white",2},{"ultramarine ash",0.05},medium=0.35}
local m = ellipse(VPX, VPY, 85, 85):blur(20)
work(m, {hand="scumble", tool={kind="filbert", width=5}, pile=VEIL, load=0.25, pressure={0.1, 0.25}, coverage=1.6, angle=RAD, clip=true, load_at=function(x, y) local d = math.sqrt((x-VPX)^2+(y-VPY)^2) return clamp(0.32 - d / 300, 0.04, 0.3) end})
blend(m, {angle=RAD, tool={kind="badger", width=12}})

--@ chunk 27
print(drying(512, 500))
FX, FY = 519, 484
-- his shadow, thrown toward us down the causeway by the light behind him
local sh = poly({{FX - 2.6, FY}, {FX + 2.6, FY}, {FX + 9, FY + 120}, {FX - 1, FY + 120}}, true) * WALK
local shp = pile{{"bone brown",1},{"ultramarine blue",1},{"raw sienna",0.4},{"lead white",0.5}}
work(sh * above(function(x) return FY + 120 end), {hand="detail", pile=shp, coverage=2, fill=true, clip=true, load_at=function(x, y) return clamp(0.8 - (y - FY) / 160, 0.2, 0.8) end})
-- the figure: a frame, small, standing
FIG = body_of{spine={{FX, FY - 26}, {FX, FY - 20}, {FX + 0.3, FY - 11}}, widths={4.4, 7.5, 5}, limbs={
  {{FX - 1.6, FY - 11}, {FX - 2.2, FY - 5}, {FX - 2.4, FY}, widths={2.6, 2.2, 2.2}},
  {{FX + 1.8, FY - 11}, {FX + 2.0, FY - 5}, {FX + 2.5, FY}, widths={2.6, 2.2, 2.2}},
  {{FX - 3.6, FY - 19}, {FX - 4.6, FY - 13}, {FX - 4.4, FY - 8.5}, widths={1.9, 1.6, 1.5}},
  {{FX + 3.6, FY - 19}, {FX + 4.4, FY - 13}, {FX + 5.2, FY - 9}, widths={1.9, 1.6, 1.5}},
}, char="firm", amount=0.2}
FIGM = FIG:mask()
work(FIGM, {hand="detail", pile=pile{{"bone black",1.4},{"ultramarine blue",0.6},{"burnt sienna",0.6}}, coverage=4, fill=true, clip=true})

--@ chunk 28
print(wait(4 * 24 * 60), drying(FX, FY - 15))
LIP = {{"lead white",2.5},{"yellow ochre",0.35},{"ultramarine ash",0.4},{"zinc white",0.5}}
LIPD = {{"raw sienna",1},{"yellow ochre",0.8},{"lead white",1},{"ultramarine ash",0.5}}
for k = 1, 9 do
  local p = pile(mixr(LIPD, LIP, clamp((k - 1) / 6, 0, 1)))
  local lw = math.max(0.35, FR[k].r / 260)
  local br = brush{kind="round", width=lw * 2, point=0.4, stiffness=0.5}
  for v = 1, 6 do
    local a, b = REV[k][v], REV[k][v % 6 + 1]
    -- skip the part that runs under the causeway
    br:load(p, 0.7)
    br:stroke({a, b}, {pressure={rand(0.4, 0.7), rand(0.4, 0.7)}, ramps={0.1, 0.15}, shake=0.3, clip=-WALK:grow(1)})
  end
end
-- cold rim light on the figure's head and shoulders
local rb = brush{kind="round", width=0.9, point=0.8}
local rim = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.08}}
rb:load(rim, 0.6)
rb:stroke({{FX - 1.9, FY - 24.5}, {FX - 0.6, FY - 27}, {FX + 1.2, FY - 26.6}, {FX + 2.1, FY - 24.2}}, {pressure={0.35, 0.3}})
rb:load(rim, 0.5)
rb:stroke({{FX - 3.9, FY - 20}, {FX - 2.4, FY - 21.2}}, {pressure={0.3, 0.2}})
rb:stroke({{FX + 2.4, FY - 21.2}, {FX + 3.9, FY - 20}}, {pressure={0.3, 0.2}})

--@ chunk 29
GRD = pile{{"bone black",1.2},{"burnt sienna",0.8},{"ultramarine blue",0.6}}
GRL = {{"yellow ochre",1},{"raw sienna",0.5},{"lead white",1.2},{"ultramarine ash",0.5}}
local nog = everywhere()
for _, g in ipairs(GSPOT) do nog = nog - ellipse(g.x, g.y, g.bw * 0.45, g.bw * 0.45) end
nog = nog - WALK:grow(1)
function inset(k, f)
  local o, i, out = FR[k].outer, FR[k].inner, {}
  for v = 1, 6 do out[v] = {lerp(o[v][1], i[v][1], f), lerp(o[v][2], i[v][2], f)} end
  return out
end
for k = 1, 7 do
  local lw = math.max(0.3, FR[k].r / 300)
  local fa, fb = rand(0.2, 0.3), rand(0.72, 0.8)
  local A, B = inset(k, fa), inset(k, fb)
  local bd = brush{kind="round", width=lw * 2, point=0.3, stiffness=0.5}
  local bl = brush{kind="round", width=lw * 1.4, point=0.4, stiffness=0.5}
  local lp = pile(mixr(GRL, LIP, clamp(k / 7, 0, 1)))
  for v = 1, 6 do
    local w = v % 6 + 1
    bd:load(GRD, 0.7)
    bd:stroke({A[v], A[w]}, {pressure={0.55, 0.6}, ramps={0.05, 0.05}, shake=0.2, clip=nog})
    -- the groove's lower lip catches the light from the depth
    local dx, dy = VPX - A[v][1], VPY - A[v][2]
    local dl = math.sqrt(dx * dx + dy * dy)
    local off = lw * 1.6
    bl:load(lp, 0.6)
    bl:stroke({{A[v][1] + dx / dl * off, A[v][2] + dy / dl * off}, {A[w][1] + (VPX - A[w][1]) / dl * off, A[w][2] + (VPY - A[w][2]) / dl * off}}, {pressure={0.4, 0.45}, ramps={0.1, 0.1}, shake=0.2, clip=nog})
    bd:load(GRD, 0.6)
    bd:stroke({B[v], B[w]}, {pressure={0.4, 0.45}, ramps={0.05, 0.05}, shake=0.2, clip=nog})
  end
end

--@ chunk 30
NOG = everywhere()
for _, g in ipairs(GSPOT) do NOG = NOG - ellipse(g.x, g.y, g.bw * 0.45, g.bw * 0.45) end
NOG = NOG - WALK:grow(1)
VG = pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"yellow ochre",0.5},{"bone black",0.25}}
for k = 1, 6 do
  local band = FR[k].r * 0.13
  local m = nil
  for v = 1, 6 do
    if math.random() < 0.6 then
      local o = FR[k].outer[v]
      local e = ellipse(o[1] + randn(0, band * 0.2), o[2] + randn(0, band * 0.2), band * rand(0.5, 0.9), band * rand(0.5, 0.9))
      m = m and (m + e) or e
    end
  end
  if m then
    m = (m * face(k)):roughen(band * 0.15, band * 0.5, k)
    stipple(m * NOG, {pile=VG, width=math.max(1, band / 14), coverage=0.7, cluster=0.6, feather=0.6, pressure={0.3, 0.6}, clip=face(k)})
  end
end

--@ chunk 31
SHEEN = pile{{"yellow ochre",1},{"lead white",1.1},{"raw sienna",0.4},{"ultramarine ash",0.5}}
for k = 1, 6 do
  local m = (poly(inset(k, 0.6)) - poly(FR[k].inner)) * NOG
  work(m, {hand="scumble", tool={kind="filbert", width=math.max(1.5, FR[k].r / 60)}, pile=SHEEN, load=0.22, pressure={0.15, 0.35}, coverage=0.7, angle=TAN, length={FR[k].r / 12, FR[k].r / 5}, clip=true})
end

--@ chunk 32
for k = 1, 6 do
  local m = (poly(inset(k, 0.6)) - poly(FR[k].inner)) * NOG
  work(m, {hand="scumble", blender=true, tool={kind="filbert", width=math.max(1.5, FR[k].r / 50)}, coverage=2.5, angle=TAN, clip=true})
end

--@ chunk 33
print(wait(2 * 24 * 60), drying(300, 120))
FD = {{"bone black",1.3},{"raw sienna",1},{"burnt sienna",0.5},{"ultramarine blue",0.7}}
FM = {{"raw sienna",1.2},{"yellow ochre",0.6},{"bone black",0.4},{"ultramarine ash",0.6},{"lead white",0.5}}
for k = 1, 6 do
  local t = (k - 1) / 6
  local mid = poly(inset(k, 0.55))
  local outer = (face(k) - mid) * NOG
  local inner = (mid - poly(FR[k].inner)) * NOG
  local tool = (k < 4) and "body" or "detail"
  work(outer, {hand=tool, pile=pile(mixr(FD, FM, t)), angle=TAN, coverage=3.5, fill=true, clip=true})
  work(inner, {hand=tool, pile=pile(mixr(FD, FM, clamp(t + 0.22, 0, 1))), angle=TAN, coverage=3.5, fill=true, clip=true})
end

--@ chunk 34
print(wait(4 * 24 * 60), drying(300, 120), drying(250, 300))
GWARM = pile{{"burnt sienna",1.5},{"red earth",0.4},{"bone brown",0.3},medium=0.8}
local m = nil
for k = 1, 6 do m = m and (m + face(k)) or face(k) end
m = m * NOG
work(m, {hand="glaze", pile=GWARM, load=0.5, angle=TAN, coverage=1.6, clip=true})
blend(m, {angle=TAN})

--@ chunk 35
local m = nil
for k = 1, 6 do m = m and (m + face(k)) or face(k) end
m = m * NOG
work(m, {hand="scumble", blender=true, coverage=3, angle=TAN, clip=true})

--@ chunk 36
print(wait(4 * 24 * 60), drying(300,120))
GRD = pile{{"bone black",1.2},{"burnt sienna",0.8},{"ultramarine blue",0.6}}
GRL = {{"yellow ochre",1},{"raw sienna",0.5},{"lead white",1.2},{"ultramarine ash",0.5}}
function inset(k, f)
  local o, i, out = FR[k].outer, FR[k].inner, {}
  for v = 1, 6 do out[v] = {lerp(o[v][1], i[v][1], f), lerp(o[v][2], i[v][2], f)} end
  return out
end
for k = 1, 7 do
  local lw = math.max(0.3, FR[k].r / 300)
  local fa, fb = rand(0.2, 0.3), rand(0.72, 0.8)
  local A, B = inset(k, fa), inset(k, fb)
  local bd = brush{kind="round", width=lw * 2, point=0.3, stiffness=0.5}
  local bl = brush{kind="round", width=lw * 1.4, point=0.4, stiffness=0.5}
  local lp = pile(mixr(GRL, LIP, clamp(k / 7, 0, 1)))
  for v = 1, 6 do
    local w = v % 6 + 1
    bd:load(GRD, 0.7)
    bd:stroke({A[v], A[w]}, {pressure={0.55, 0.6}, ramps={0.05, 0.05}, shake=0.2, clip=NOG})
    -- the groove's lower lip catches the light from the depth
    local dx, dy = VPX - A[v][1], VPY - A[v][2]
    local dl = math.sqrt(dx * dx + dy * dy)
    local off = lw * 1.6
    bl:load(lp, 0.6)
    bl:stroke({{A[v][1] + dx / dl * off, A[v][2] + dy / dl * off}, {A[w][1] + (VPX - A[w][1]) / dl * off, A[w][2] + (VPY - A[w][2]) / dl * off}}, {pressure={0.4, 0.45}, ramps={0.1, 0.1}, shake=0.2, clip=NOG})
    bd:load(GRD, 0.6)
    bd:stroke({B[v], B[w]}, {pressure={0.4, 0.45}, ramps={0.05, 0.05}, shake=0.2, clip=NOG})
  end
end
-- the causeway's edges: a lit lip on its left, the dark fall on its right
local lipb = brush{kind="round", width=1.4, point=0.5}
local lp = pile{{"lead white",2.5},{"zinc white",0.6},{"yellow ochre",0.3},{"ultramarine ash",0.3}}
for i = 0, 5 do
  local s0, s1 = 0.15 + i * 0.13, 0.15 + (i + 1) * 0.13
  local a, b = wpt(s0, -1), wpt(math.min(s1, 0.92), -1)
  lipb:load(lp, 0.6)
  lipb:stroke({{a[1] + 0.6, a[2]}, {b[1] + 0.6, b[2]}}, {pressure={0.35 + i * 0.04, 0.3 + i * 0.04}, ramps={0.1, 0.1}})
end

--@ chunk 37
-- the same pilgrim again, further in: the corridor recurs, and so does he
FIGP = pile{{"bone black",1.4},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
function pilgrim(s, sc, lean)
  local p = wpt(s, 0)
  local x, y = p[1] + randn(0, 0.3) * sc, p[2]
  local L = function(dx, dy) return {x + dx * sc, y + dy * sc} end
  local sh = poly({L(-2.4, 0), L(2.4, 0), L(8 + lean, 120 * (1 - s) / 0.45 / sc * sc * 0.9), L(-1 + lean, 120 * (1 - s) / 0.45 / sc * sc * 0.9)}, true) * WALK
  work(sh, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine blue",1},{"raw sienna",0.4},{"lead white",0.7}}, coverage=1.6, fill=true, clip=true})
  local f = body_of{spine={L(lean * 0.3, -26), L(lean * 0.2, -20), L(0.3, -11)}, widths={4.4 * sc, 7.4 * sc, 5 * sc}, limbs={
    {L(-1.5, -11), L(-2.0, -5), L(-2.2, 0), widths={2.6 * sc, 2.2 * sc, 2.2 * sc}},
    {L(1.7, -11), L(2.2, -5.5), L(2.3, 0), widths={2.6 * sc, 2.2 * sc, 2.2 * sc}},
    {L(-3.6, -19), L(-4.3, -13), L(-4.6, -8.5), widths={1.9 * sc, 1.6 * sc, 1.5 * sc}},
    {L(3.6, -19), L(4.6, -13.5), L(4.8, -9), widths={1.9 * sc, 1.6 * sc, 1.5 * sc}},
  }, char="firm", amount=0.15}
  work(f:mask(), {hand="detail", pile=FIGP, coverage=4, fill=true, clip=true})
end
pilgrim(0.78, 0.47, 0.4)
pilgrim(0.885, 0.24, -0.3)

--@ chunk 38
print(drying(VPX, VPY))
local CW = pile{{"zinc white",4},{"lead white",0.6},{"cerulean blue",0.03}}
work(poly(FR[12].inner):grow(1.5), {hand="detail", pile=CW, coverage=5, fill=true, clip=true})
local b = brush{kind="round", width=1.2, point=0.5}
local p = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.3},{"ultramarine ash",0.3}}
-- and inside the light, the corridor goes on: one more turned hexagon
local r, rot = FR[12].r * 0.52, FR[12].rot + 0.17
local pts = {}
for v = 0, 5 do local a = rot + v * math.pi / 3 pts[#pts + 1] = {VPX + 0.3 + r * math.cos(a), VPY + r * math.sin(a)} end
for v = 1, 6 do b:load(p, 0.5) b:stroke({pts[v], pts[v % 6 + 1]}, {pressure={0.3, 0.3}}) end

--@ chunk 39
function glyphn(cx, cy, r, rot, levels, turn, shrink, p, lw, sides)
  local br = brush{kind="round", width=lw * 2, point=0.6, stiffness=0.5}
  for L = 0, levels - 1 do
    local pts = {}
    for v = 0, sides - 1 do
      local a = rot + v * 2 * math.pi / sides + randn(0, 0.01)
      pts[#pts + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)}
    end
    for v = 1, sides do
      br:load(p, 0.7)
      br:stroke({pts[v], pts[v % sides + 1]}, {pressure={0.55, 0.5}, ramps={0.05, 0.05}, shake=0.2})
    end
    r = r * shrink
    rot = rot + turn
  end
end
FRZ = pile(mixr({{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.8},{"ultramarine ash",0.5}}, {{"lead white",3},{"yellow ochre",0.4},{"ultramarine ash",0.35}}, 0.45))
local n = 0
for _, k in ipairs({1, 2, 3}) do
  for v = 1, 6 do
    local t = rand(0.04, 0.1)
    while t < 0.94 do
      local x, y, bw = bandpt(k, v, t)
      local ok = WALK:grow(4):at(x, y) < 0.1
      for _, g in ipairs(GSPOT) do if math.sqrt((g.x - x)^2 + (g.y - y)^2) < g.bw * 0.6 then ok = false end end
      if ok then
        local sides = ({3, 4, 6, 6, 5})[math.random(1, 5)]
        glyphn(x, y, bw * rand(0.11, 0.15), rand(0, 6.28), math.random(2, 4), rand(0.2, 0.5), rand(0.62, 0.72), FRZ, math.max(0.25, bw / 120), sides)
        n = n + 1
      end
      local edge = math.sqrt((FR[k].outer[v % 6 + 1][1] - FR[k].outer[v][1])^2 + (FR[k].outer[v % 6 + 1][2] - FR[k].outer[v][2])^2)
      t = t + bw * rand(0.4, 0.75) / edge
    end
  end
end
print(n)

--@ chunk 40
local A = {{"bone brown",1},{"ultramarine ash",1},{"raw sienna",0.5},{"lead white",0.35},{"bone black",0.25}}
local B = {{"raw sienna",1},{"ultramarine ash",1},{"bone brown",0.6},{"lead white",0.7}}
local function seg(s0, s1) return WALK * (above(function(x) return lerp(WB[2], VPY, s0) end) - above(function(x) return lerp(WB[2], VPY, s1) end)) end
work(seg(0, 0.09), {hand="body", pile=pile(A), angle=RAD, coverage=3.5, fill=true, clip=true})
work(seg(0.09, 0.17), {hand="body", pile=pile(mixr(A, B, 0.5)), angle=RAD, coverage=3.5, fill=true, clip=true})
work(seg(0.17, 0.24), {hand="body", pile=pile(B), angle=RAD, coverage=3, fill=true, clip=true})
blend(seg(0, 0.25), {angle=RAD, tool={kind="badger", width=14}})

--@ chunk 41
print(wait(2 * 24 * 60), drying(505, 690))
local function seg(s0, s1) return WALK * (above(function(x) return lerp(WB[2], VPY, s0) end) - above(function(x) return lerp(WB[2], VPY, s1) end)) end
local D0 = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.6},{"raw sienna",0.4}}
local D1 = pile{{"bone brown",1},{"ultramarine ash",1},{"raw sienna",0.5},{"bone black",0.3},{"lead white",0.12}}
local D2 = pile{{"raw sienna",1},{"ultramarine ash",1},{"bone brown",0.6},{"lead white",0.3}}
work(seg(0, 0.1), {hand="body", pile=D0, angle=RAD, coverage=4, fill=true, clip=true})
work(seg(0.1, 0.2), {hand="body", pile=D1, angle=RAD, coverage=4, fill=true, clip=true})
work(seg(0.2, 0.3), {hand="body", pile=D2, angle=RAD, coverage=3.5, fill=true, clip=true})
blend(seg(0.05, 0.3), {angle=RAD, tool={kind="badger", width=12}})

--@ chunk 42
print(wait(5 * 24 * 60), drying(505, 690), drying(505, 600))
local function seg(s0, s1) return WALK * (above(function(x) return lerp(WB[2], VPY, s0) end) - above(function(x) return lerp(WB[2], VPY, s1) end)) end
local D0 = pile{{"bone black",1.2},{"ultramarine blue",1},{"burnt sienna",0.6}}
local D1 = pile{{"bone black",0.6},{"ultramarine blue",0.6},{"bone brown",0.6},{"raw sienna",0.5},{"ultramarine ash",0.5}}
local D2 = pile{{"bone brown",1},{"ultramarine ash",1},{"raw sienna",0.5},{"lead white",0.25},{"bone black",0.15}}
local D3 = pile{{"raw sienna",1},{"ultramarine ash",1},{"bone brown",0.4},{"lead white",0.6},{"yellow ochre",0.3}}
local D4 = pile{{"lead white",1.5},{"raw sienna",0.6},{"ultramarine ash",0.6},{"yellow ochre",0.4}}
work(seg(0, 0.1), {hand="body", pile=D0, angle=RAD, coverage=4, fill=true, clip=true})
work(seg(0.1, 0.19), {hand="body", pile=D1, angle=RAD, coverage=4, fill=true, clip=true})
work(seg(0.19, 0.28), {hand="body", pile=D2, angle=RAD, coverage=4, fill=true, clip=true})
work(seg(0.28, 0.36), {hand="body", pile=D3, angle=RAD, coverage=3.5, fill=true, clip=true})
work(seg(0.36, 0.44), {hand="detail", pile=D4, angle=RAD, coverage=3, fill=true, clip=true})

--@ chunk 43
local s0, s1 = 0.0, 0.45 local m = WALK * (above(function(x) return lerp(WB[2], VPY, s0) end) - above(function(x) return lerp(WB[2], VPY, s1) end)) blend(m, {angle=RAD, tool={kind="badger", width=16}, coverage=3})

--@ chunk 44
print(FX, WALK:at(FX+5, 515), WALK:at(FX+5,600))

--@ chunk 45
print(wait(5 * 24 * 60), drying(505, 690), drying(512, 560))
-- soften the seam across the causeway with strokes running along it
local mp = pile{{"raw sienna",1},{"ultramarine ash",1},{"bone brown",0.4},{"lead white",0.9},{"yellow ochre",0.3}}
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 16 do
  local side = rand(-0.95, 0.95)
  local sa, sb = rand(0.36, 0.41), rand(0.47, 0.53)
  local p1, p2 = wpt(sa, side), wpt(sb, side)
  b:load(mp, rand(0.25, 0.4))
  b:stroke({p1, p2}, {pressure={0.4, 0.15}, clip=WALK})
end
-- the near pilgrim's shadow runs on down the causeway and fades into its dark end
local sh = poly({{FX - 2.1, 520}, {FX + 4.5, 520}, {FX + 13, 680}, {FX, 680}}, true) * WALK
work(sh, {hand="detail", pile=pile{{"bone brown",1},{"ultramarine blue",1.1},{"raw sienna",0.3},{"lead white",0.35}}, coverage=2.5, fill=true, clip=true, load_at=function(x, y) return clamp(0.85 - (y - 520) / 220, 0.15, 0.85) end})
