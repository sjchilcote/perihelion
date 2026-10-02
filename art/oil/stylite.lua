-- easel session "stylite": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=0.72, linen={16,18}, seed=4417, ground={{pile={{"lead white",1.2},{"ultramarine blue",1},{"magenta",0.25},{"bone black",0.7},{"viridian",0.3}}, um=140, apply="knife", texture=0.45}}}; print(W,H)

--@ chunk 2
-- geometry globals
RC = {520, 600}
RROT = -0.1
function rpt(t, rx, ry, cx, cy, rot)
  cx = cx or RC[1]; cy = cy or RC[2]; rot = rot or RROT
  local x, y = rx * math.cos(t), ry * math.sin(t)
  return {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)}
end
function rellipse(rx, ry, n)
  local pts = {}
  n = n or 120
  for i = 0, n - 1 do pts[#pts + 1] = rpt(2 * math.pi * i / n, rx, ry) end
  return poly(pts)
end
-- vortex field: strokes swirl round the gate, spiralling a little inward
VN = noise{seed=31, period=420, octaves=3}
function vortex(x, y)
  local dx, dy = x - RC[1], y - RC[2]
  return math.atan(dy, dx) + math.pi / 2 + 0.35 + 0.6 * VN(x, y)
end
print(rpt(0, 300, 335)[1], rpt(math.pi/2, 300, 335)[2])

--@ chunk 3
VBLK  = pile{{"bone black",1.5},{"ultramarine blue",1},{"magenta",0.3}}
VIO   = pile{{"ultramarine blue",2},{"magenta",0.6},{"bone black",1.2}}
TEALD = pile{{"viridian",2},{"ultramarine blue",1},{"bone black",1}}
PLUM  = pile{{"magenta",1},{"ultramarine blue",1},{"bone black",0.8}}
COBV  = pile{{"cobalt violet",1},{"ultramarine blue",1},{"lead white",0.5}}
TEALM = pile{{"viridian",1},{"cerulean blue",1},{"bone black",0.3},{"lead white",0.6}}

local outer = rellipse(300, 335)
local space = -(outer:shrink(18))
-- zones, softly interleaved by noise
local zn = noise{seed=77, period=260, octaves=4}
local function zone(fn) return space * mask(function(x, y) return clamp(fn(x, y) + 0.35 * zn(x, y), 0, 1) end) end
local top    = zone(function(x, y) return smoothstep(420, 150, y) end)
local left   = zone(function(x, y) return smoothstep(380, 120, x) * smoothstep(150, 350, y) * smoothstep(1150, 900, y) end)
local right  = zone(function(x, y) return smoothstep(640, 900, x) * smoothstep(150, 350, y) * smoothstep(1250, 950, y) end)
local bottom = zone(function(x, y) return smoothstep(950, 1200, y) end)
local midb   = space - top - left - right - bottom

work(space, {hand="broad", pile=VIO, coverage=1.6, fill=true, angle=vortex, seed=11})
work(top,    {hand="broad", pile=VBLK, coverage=1.5, fill=true, angle=vortex, seed=12})
work(left,   {hand="broad", pile=TEALD, coverage=1.5, fill=true, angle=vortex, seed=13})
work(right,  {hand="broad", pile=PLUM, coverage=1.5, fill=true, angle=vortex, seed=14})
work(bottom, {hand="broad", pile=VBLK, coverage=1.8, fill=true, angle=vortex, seed=15})
work(midb,   {hand="body", pile=COBV, coverage=0.8, angle=vortex, seed=16})

--@ chunk 4
local space = -(rellipse(300,335):shrink(18)); local band = space * rellipse(470,500):soften(40); blend(band, {angle=vortex}); print(drying(100,100))

--@ chunk 5
blend(ellipse(250,1060,260,120):soften(30) - rellipse(300,335):shrink(18), {angle=vortex})

--@ chunk 6
GC = {515, 700}
AP = rellipse(245, 280)            -- aperture (inner edge of the ring)
local ap = AP:grow(22)
local function circ(x, y) return math.atan(y - GC[2], x - GC[1]) + math.pi / 2 end
GLOW1 = pile{{"burnt sienna",2},{"Mars orange",1},{"ultramarine blue",0.25}}
GLOW2 = pile{{"Mars orange",1},{"cadmium red",0.3},{"lead white",0.6},{"Indian yellow",0.4}}
GLOW3 = pile{{"cadmium yellow",1},{"Indian yellow",0.5},{"lead white",1.2}}
GLOW4 = pile{{"lead white",3},{"lemon chrome",1}}
GLOW5 = pile{{"lead white",6},{"lemon chrome",0.4}}
local zones = {{GLOW1, 999}, {GLOW2, 290}, {GLOW3, 200}, {GLOW4, 120}, {GLOW5, 60}}
for i, z in ipairs(zones) do
  local m = ap * ellipse(GC[1], GC[2], z[2], z[2] * 1.12):roughen(8, 40, 100 + i):soften(12)
  if i == 1 then m = ap end
  work(m, {hand="body", pile=z[1], coverage=2.6, fill=true, angle=circ, seed=200 + i,
           length={25, 70}, clip=ap})
end

--@ chunk 7
local function circ(x, y) return math.atan(y - GC[2], x - GC[1]) + math.pi / 2 end; blend(AP:grow(20), {angle=circ}); blend(AP:grow(20) - ellipse(GC[1],GC[2],70,80), {angle=circ, seed=9})

--@ chunk 8
BRZ_D = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
BRZ_M = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
BRZ_L = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
VERD  = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
RO, RI = {300, 335}, {245, 280}
-- one ring plate between params t0..t1, between radius factors, moved and turned
function plate(t0, t1, f0, f1, dx, dy, rot)
  local pts = {}
  local n = math.max(4, math.floor((t1 - t0) * 40))
  for i = 0, n do local t = lerp(t0, t1, i / n); pts[#pts + 1] = rpt(t, lerp(RI[1], RO[1], f1), lerp(RI[2], RO[2], f1)) end
  for i = n, 0, -1 do local t = lerp(t0, t1, i / n); pts[#pts + 1] = rpt(t, lerp(RI[1], RO[1], f0), lerp(RI[2], RO[2], f0)) end
  local cx, cy = 0, 0
  for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end
  cx, cy = cx / #pts, cy / #pts
  local c, s = math.cos(rot or 0), math.sin(rot or 0)
  for _, p in ipairs(pts) do
    local x, y = p[1] - cx, p[2] - cy
    p[1], p[2] = cx + x * c - y * s + (dx or 0), cy + x * s + y * c + (dy or 0)
  end
  return poly(pts), {cx + (dx or 0), cy + (dy or 0)}
end
-- the whole ring: intact from t=1.25 round to t=0.18 (+2pi); broken between
PLATES = {}
local cuts = uneven(20, 1.25, 0.18 + 2 * math.pi, 0.5, 0.3, 501)
local prev = 1.25
for _, t in ipairs(cuts) do
  if t - prev > 0.05 then PLATES[#PLATES + 1] = {prev + 0.006, t - 0.006} end
  prev = t
end
PLATES[#PLATES + 1] = {prev + 0.006, 0.18 + 2 * math.pi}
local ring = nil
for _, p in ipairs(PLATES) do local m = plate(p[1], p[2], 0, 1); ring = ring and (ring + m) or m end
-- broken arc: plates drifting outward, turning, coming apart
BROKEN = {}
local bt = {0.18, 0.36, 0.5, 0.67, 0.8, 0.95, 1.1, 1.25}
for i = 1, #bt - 1 do
  local k = i / (#bt - 1)
  local mid = (bt[i] + bt[i + 1]) / 2
  local push = 30 + 220 * math.sin(math.pi * (i - 0.5) / (#bt - 1))^1.3 + rand(-20, 20)
  local dir = {math.cos(mid) * 1.1 + 0.4, math.sin(mid) * 0.7 + 0.1}
  BROKEN[i] = {bt[i] + 0.01, bt[i + 1] - 0.01, rand(0, 0.15), rand(0.8, 1), dir[1] * push, dir[2] * push, rand(-0.6, 0.6) * k + 0.2}
  ring = ring + plate(table.unpack(BROKEN[i]))
end
RING = ring
work(RING, {hand="body", pile=BRZ_D, coverage=3, fill=true, angle=vortex, clip=true, seed=301})
print(#PLATES)

--@ chunk 9
local m=nil; for i,b in ipairs(BROKEN) do if i>1 then local p=plate(table.unpack(b)); m = m and (m+p) or p end end; m=m:grow(8); work(m,{hand="body",pile=PLUM,coverage=3.5,fill=true,angle=vortex,seed=401}); blend(m:grow(20),{angle=vortex})

--@ chunk 10
-- outer course of plates (f 1.0..2.1), cut differently from the inner one
OPLATES = {}
local cuts = uneven(16, 1.4, 0.05 + 2 * math.pi, 0.6, 0.3, 777)
local prev = 1.4
for _, t in ipairs(cuts) do
  if t - prev > 0.06 then OPLATES[#OPLATES + 1] = {prev + 0.005, t - 0.005} end
  prev = t
end
OPLATES[#OPLATES + 1] = {prev + 0.005, 0.05 + 2 * math.pi}
local ring = nil
for _, p in ipairs(OPLATES) do local m = plate(p[1], p[2], 1.03, 2.1); ring = ring and (ring + m) or m end
-- broken arcs, both courses: pieces drift outward along the swirl, turning, thinning
OBROKEN = {}
local function drift(mid, k)  -- k 0..1 along the break; most displaced in the middle-late part
  local amt = math.sin(math.pi * k)^0.8 * (60 + 140 * k)
  local ang = mid + 0.55 * k
  return math.cos(ang) * amt * 1.2 + 25 * k, math.sin(ang) * amt * 0.8
end
local ob = uneven(11, 0.05, 1.4, 0.5, 0.2, 778)
local lastt = 0.05
for i, t in ipairs(ob) do
  if t - lastt > 0.04 then
    local k = (lastt + t) / 2 / 1.4
    local dx, dy = drift((lastt + t) / 2, k)
    OBROKEN[#OBROKEN + 1] = {lastt + 0.012, t - 0.012, 1.03 + rand(0, 0.25) * k, 2.1 - rand(0, 0.5) * k, dx, dy, rand(-0.5, 0.7) * k}
  end
  lastt = t
end
IBROKEN = {}
local ib = uneven(9, 0.18, 1.25, 0.5, 0.2, 779)
lastt = 0.18
for i, t in ipairs(ib) do
  if t - lastt > 0.04 then
    local k = ((lastt + t) / 2 - 0.18) / 1.07
    local dx, dy = drift((lastt + t) / 2, k * 0.8)
    IBROKEN[#IBROKEN + 1] = {lastt + 0.012, t - 0.012, rand(0, 0.15) * k, 1 - rand(0, 0.3) * k, dx * 0.7, dy * 0.7, rand(-0.4, 0.6) * k}
  end
  lastt = t
end
local frag = nil
for _, b in ipairs(OBROKEN) do local m = plate(table.unpack(b)); frag = frag and (frag + m) or m end
for _, b in ipairs(IBROKEN) do local m = plate(table.unpack(b)); frag = frag and (frag + m) or m end
ORING = ring
FRAG = frag
work(ORING, {hand="body", pile=BRZ_D, coverage=3, fill=true, angle=vortex, clip=true, seed=501})
work(FRAG, {hand="body", pile=BRZ_D, coverage=3, fill=true, angle=vortex, clip=true, seed=502})
print(#OPLATES, #OBROKEN, #IBROKEN)

--@ chunk 11
PIL = pile{{"bone black",1.4},{"ultramarine blue",1},{"viridian",0.4},{"burnt sienna",0.3}}
-- pillar: drums from the capital down; the lower drums slide off the plumb and turn
PX = 516
local function hw(y) return 17 + (y - 815) * 0.018 end   -- half width grows downward
DRUMS = {}
local ys = {815}
local y = 815
while y < 1400 do y = y + rand(28, 52) * (1 + (y - 815) / 900); ys[#ys + 1] = y end
for i = 1, #ys - 1 do
  local y0, y1 = ys[i] + 1.2, ys[i + 1] - 1.2
  local k = clamp((y0 - 1080) / 300, 0, 1)        -- 0 = coherent, 1 = unfolding
  local dx = (k > 0) and (k^1.4 * rand(-60, 60)) or 0
  local rot = (k > 0) and (k^1.5 * rand(-0.5, 0.5)) or 0
  local gap = k * rand(4, 14)
  local cx, cy = PX + dx, (y0 + y1) / 2
  local h0, h1 = hw(y0), hw(y1)
  local pts = {{-h0, y0 - cy + gap / 2}, {h0, y0 - cy + gap / 2}, {h1, y1 - cy - gap / 2}, {-h1, y1 - cy - gap / 2}}
  local c, s = math.cos(rot), math.sin(rot)
  for _, p in ipairs(pts) do p[1], p[2] = cx + p[1] * c - p[2] * s, cy + p[1] * s + p[2] * c end
  DRUMS[#DRUMS + 1] = {pts = pts, k = k}
end
local shaft = nil
for _, d in ipairs(DRUMS) do local m = poly(d.pts); shaft = shaft and (shaft + m) or m end
-- capital: a small platform a little wider than the shaft
CAP = poly({{PX - 27, 806}, {PX + 26, 805}, {PX + 23, 816}, {PX - 24, 817}})
SHAFT = shaft
work(SHAFT + CAP, {hand="body", tool={kind="flat", width=8}, pile=PIL, coverage=3.5, fill=true, angle=math.pi/2, clip=true, seed=601})
print(#DRUMS)

--@ chunk 12
FIGP = pile{{"bone black",2},{"ultramarine blue",1},{"magenta",0.2}}
FIG = poly({{516,747},{520.5,748.5},{522.5,753},{521.5,758},{525,760},{530,762.5},{532.5,766},
  {533,773},{531.5,781},{529.5,784},{530,792},{528.5,800},{527.5,805},
  {506,805.5},{504,799},{503,791},{502.5,784},{500,780},{499.5,772},{500.5,765},
  {503,762},{507.5,760},{510.5,757.5},{510,752.5},{512,748.5}}, true)
work(FIG, {hand="detail", tool={kind="round", width=2.5}, pile=FIGP, coverage=5, fill=true, angle=math.pi/2, seed=701})

--@ chunk 13
print(wait(20*60)); print(drying(516,780), drying(516,700), drying(100,100), drying(300,600), drying(516,900))

--@ chunk 14
print(wait(24*60)); print(drying(516,780), drying(516,700), drying(100,100), drying(300,600), drying(516,900))

--@ chunk 15
local function circ(x, y) return math.atan(y - 730, x - 516) + math.pi / 2 end
local outer = ellipse(516, 728, 120, 130):soften(25) * AP
local inner = ellipse(516, 732, 62, 72):soften(18)
work(outer, {hand="body", pile=GLOW4, coverage=2.2, fill=true, angle=circ, length={20, 50}, clip=AP, seed=801})
work(inner, {hand="body", pile=GLOW5, coverage=3, fill=true, angle=circ, length={15, 40}, seed=802})
blend(ellipse(516, 730, 135, 145) * AP, {angle=circ})

--@ chunk 16
local function rad(x, y) return math.atan(y - 730, x - 516) end
local function circ(x, y) return math.atan(y - 730, x - 516) + math.pi / 2 end
local band = (ellipse(516, 728, 175, 185):soften(30) - ellipse(516, 728, 105, 115):soften(30)) * AP
work(band, {hand="body", pile=GLOW3, coverage=1.6, fill=true, angle=circ, length={20, 50}, clip=AP, seed=811})
blend(band:grow(15) * AP, {angle=rad})
blend(band:grow(15) * AP, {angle=circ, seed=3})

--@ chunk 17
local cx, cy = 516, 728
local function circ(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end
local function rad(x, y) return math.atan(y - cy, x - cx) end
local G = {
  {pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.5}}, 999},
  {pile{{"burnt sienna",2},{"Mars orange",1},{"ultramarine blue",0.15}}, 360},
  {pile{{"Mars orange",1},{"burnt sienna",0.4},{"lead white",0.3}}, 300},
  {pile{{"Mars orange",1},{"Indian yellow",0.6},{"lead white",0.6}}, 245},
  {pile{{"cadmium yellow",1},{"Indian yellow",0.6},{"lead white",1},{"Mars orange",0.2}}, 195},
  {pile{{"cadmium yellow",1},{"lead white",2}}, 150},
  {pile{{"lead white",3},{"lemon chrome",1}}, 108},
  {pile{{"lead white",5},{"lemon chrome",0.6}}, 72},
  {pile{{"lead white",8},{"lemon chrome",0.3}}, 42},
}
local ap = AP:grow(18)
for i, z in ipairs(G) do
  local m = ap
  if i > 1 then m = ap * ellipse(cx, cy, z[2], z[2] * 1.08):roughen(10, 50, 900 + i):soften(14) end
  work(m, {hand="body", pile=z[1], coverage=2.4, fill=true, angle=circ, length={20, 60}, clip=ap, seed=900 + i})
end
blend(ap, {angle=rad})
blend(ap, {angle=circ, seed=5})
blend(ap, {angle=rad, seed=6})

--@ chunk 18
local cx, cy = 516, 728
local function circ(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end
local function rad(x, y) return math.atan(y - cy, x - cx) end
local Z = {
  {pile{{"cadmium yellow",1},{"lead white",2}}, 165, 2.0},
  {pile{{"lead white",3},{"lemon chrome",1}}, 115, 2.6},
  {pile{{"lead white",5},{"lemon chrome",0.6}}, 75, 3.0},
  {pile{{"lead white",8},{"lemon chrome",0.3}}, 42, 3.5},
}
for i, z in ipairs(Z) do
  local m = AP * ellipse(cx, cy, z[2], z[2] * 1.08):roughen(8, 40, 950 + i):soften(20)
  work(m, {hand="body", pile=z[1], coverage=z[3], fill=true, angle=circ, length={15, 45}, load=0.9, clip=AP, seed=950 + i})
end
blend(AP * ellipse(cx, cy, 190, 205), {angle=rad, seed=7})

--@ chunk 19
local cx,cy=516,728; local function rad(x,y) return math.atan(y-cy,x-cx) end; local function circ(x,y) return rad(x,y)+math.pi/2 end; local band=(ellipse(cx,cy,250,265):soften(40)-ellipse(cx,cy,140,150):soften(40))*AP:grow(10); blend(band,{angle=circ,seed=21}); blend(band,{angle=rad,seed=22}); blend(band,{angle=circ,seed=23})

--@ chunk 20
print(drying(100,100), drying(900,1300), drying(516,600), drying(300,300))

--@ chunk 21
-- twisting folded ribbon: a polyline path; signed half-width at each vertex.
-- Facets run between vertices (planar, folded at vertices); a sign change
-- inside a segment splits it at the crossing, so the strip flips there.
-- returns list of facets {pts=, side=+1|-1, k=index along}
function ribbon_facets(path, hw)
  local n = #path
  local norms = {}
  for i = 1, n do
    local a = path[math.max(1, i - 1)]; local b = path[math.min(n, i + 1)]
    local dx, dy = b[1] - a[1], b[2] - a[2]
    local l = math.sqrt(dx * dx + dy * dy) + 1e-9
    norms[i] = {-dy / l, dx / l}
  end
  local function edge(i, h, t, j)
    -- point at fraction t between vertex i and j, offset h
    local px = lerp(path[i][1], path[j][1], t); local py = lerp(path[i][2], path[j][2], t)
    local nx = lerp(norms[i][1], norms[j][1], t); local ny = lerp(norms[i][2], norms[j][2], t)
    return {px + nx * h, py + ny * h}, {px - nx * h, py - ny * h}
  end
  local facets = {}
  for i = 1, n - 1 do
    local h0, h1 = hw[i], hw[i + 1]
    if h0 * h1 >= 0 then
      local a0, b0 = edge(i, h0, 0, i + 1); local a1, b1 = edge(i, h1, 1, i + 1)
      facets[#facets + 1] = {pts = {a0, a1, b1, b0}, side = (h0 + h1 >= 0) and 1 or -1, k = i}
    else
      local t = h0 / (h0 - h1)
      local a0, b0 = edge(i, h0, 0, i + 1); local c = edge(i, 0, t, i + 1)
      local a1, b1 = edge(i, h1, 1, i + 1)
      facets[#facets + 1] = {pts = {a0, c, b0}, side = h0 > 0 and 1 or -1, k = i}
      facets[#facets + 1] = {pts = {c, a1, b1}, side = h1 > 0 and 1 or -1, k = i + 0.5}
    end
  end
  return facets
end
-- a spiral path around (cx, cy): from angle a0 to a1, radius r0 to r1, squashed by sy
function spiral(cx, cy, a0, a1, r0, r1, sy, n, wob, seed)
  local pts = {}
  local nz = noise{seed = seed or 1, period = 200, octaves = 2}
  for i = 0, n do
    local t = i / n
    local a = lerp(a0, a1, t)
    local r = r0 * (r1 / r0)^t
    local x, y = cx + r * math.cos(a), cy + r * sy * math.sin(a)
    x = x + (wob or 0) * nz(x, y); y = y + (wob or 0) * nz(y + 300, x)
    pts[#pts + 1] = {x, y}
  end
  return pts
end
-- strokes that start on an edge line A->B and drag across a plane toward 'side',
-- lifting off as they go: a lit fold whose light dies across the plane.
-- opts: pile, width, depth (units), spacing, load, pressure, along (0..1 slant), clip, seed, rig (hairline pile)
function fade_plane(A, B, side, o)
  local dx, dy = B[1] - A[1], B[2] - A[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local tx, ty = dx / L, dy / L
  local nx, ny = -ty * side, tx * side
  local b = brush{kind = o.kind or "filbert", width = o.width or 6, stiffness = o.stiff or 0.5}
  local n = math.max(2, math.floor(L / (o.spacing or (o.width or 6) * 0.7)))
  local used = 0
  for i = 0, n do
    local t = (i + rand(-0.3, 0.3)) / n
    if t >= 0 and t <= 1 then
      if used % (o.per or 4) == 0 then b:reload(o.pile, o.load or 0.5) end
      used = used + 1
      local x0, y0 = A[1] + dx * t, A[2] + dy * t
      local d = (o.depth or 40) * rand(0.15, 1.15)^0.8
      local sl = (o.along or 0.25) + rand(-0.1, 0.1)
      local ex, ey = nx + tx * sl, ny + ty * sl
      local x1, y1 = x0 + ex * d * 0.5, y0 + ey * d * 0.5
      local x2, y2 = x0 + ex * d, y0 + ey * d
      b:stroke({{x0 - nx * 1.5, y0 - ny * 1.5}, {x1, y1}, {x2, y2}},
        {pressure = {o.pressure or 0.7, 0.0}, ramps = {0.02, 0.7}, clip = o.clip})
    end
  end
  if o.rig then
    local r = brush{kind = "rigger", width = o.rigw or 2, point = 0.9}
    r:load(o.rig, 0.8)
    r:stroke({A, {A[1] + dx * 0.5 + rand(-1, 1), A[2] + dy * 0.5 + rand(-1, 1)}, B}, {pressure = {0.25, 0.7}, ramps = {0.2, 0.3}, swell = {0.6, 1, 0.5}})
  end
end
-- a folded sheet: chain of fold lines; each plane falls away from its fold toward 'toward'
-- piles: list cycled per plane; depths: number or list
function sheet(chain, o)
  for i = 1, #chain - 1 do
    local A, B = chain[i], chain[i + 1]
    local mx, my = (A[1] + B[1]) / 2, (A[2] + B[2]) / 2
    local dx, dy = B[1] - A[1], B[2] - A[2]
    local tw = o.toward or RC
    local side = ((-dy) * (tw[1] - mx) + dx * (tw[2] - my)) >= 0 and 1 or -1
    if o.away then side = -side end
    if o.flip and o.flip[i] then side = -side end
    local depth = type(o.depth) == "table" and o.depth[i] or o.depth
    local p = o.piles[(i - 1) % #o.piles + 1]
    fade_plane(A, B, side, {pile = p, width = o.width or 9, spacing = o.spacing or 4, depth = depth,
      along = (o.along or 0.1) * (i % 2 == 0 and 1 or -1), load = o.load or 0.55, clip = o.clip,
      rig = o.rig, rigw = o.rigw or 2.2, pressure = o.pressure})
    if o.blend ~= false then
      local L = math.sqrt(dx * dx + dy * dy)
      local nx, ny = -dy / L * side, dx / L * side
      local q = poly({{A[1] - nx * 3, A[2] - ny * 3}, {B[1] - nx * 3, B[2] - ny * 3},
        {B[1] + nx * depth * 1.1, B[2] + ny * depth * 1.1}, {A[1] + nx * depth * 1.1, A[2] + ny * depth * 1.1}}):soften(10)
      if o.clip then q = q * o.clip end
      blend(q, {angle = math.atan(dy, dx) + (o.blend_turn or 0.25)})
    end
  end
end
ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
ACID = pile{{"lemon chrome",1},{"emerald green",1.5},{"zinc white",3}}
PMAG = pile{{"magenta",1},{"cobalt violet",1},{"zinc white",3}}
PCY  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",3}}
TEALM = pile{{"viridian",1},{"cerulean blue",1},{"bone black",0.3},{"lead white",0.6}}
RIGW = pile{{"zinc white",4},{"cerulean blue",0.3}}
BEHIND = -(rellipse(364, 399) + SHAFT:grow(1.5) + CAP:grow(1.5) + FIG + FRAG:grow(2))

--@ chunk 22
sheet({{-10,430},{60,280},{170,160},{330,80},{520,48},{700,70}}, {piles={ICE,PCY,ACID,ICE,PMAG}, depth={150,170,150,120,100}, away=true, clip=BEHIND, rig=RIGW, width=10})

--@ chunk 23
-- a blade: fold chain along a log spiral out from the gate
function blade_chain(th0, r0, r1, k, nseg, jit)
  local ch = {}
  for i = 0, nseg do
    local t = i / nseg
    local r = r0 * (r1 / r0)^t
    local th = th0 + k * math.log(r / r0) + rand(-1, 1) * (jit or 0)
    ch[#ch + 1] = {RC[1] + r * math.cos(th), RC[2] + 1.1 * r * math.sin(th)}
  end
  return ch
end
local function r(t) local o={} for i,v in ipairs(t) do o[i]=v end return o end
-- blade 1: from upper-left of the ring out to the left edge
local c1 = blade_chain(3.5, 400, 720, 0.9, 4, 0.04)
print(c1[1][1], c1[1][2], c1[#c1][1], c1[#c1][2])
local c2 = blade_chain(4.5, 410, 820, 0.8, 4, 0.04)
print(c2[1][1], c2[1][2], c2[#c2][1], c2[#c2][2])
local c3 = blade_chain(5.6, 420, 760, 0.8, 4, 0.04)
print(c3[1][1], c3[1][2], c3[#c3][1], c3[#c3][2])
local c4 = blade_chain(0.7, 430, 900, 0.7, 5, 0.04)
print(c4[1][1], c4[1][2], c4[#c4][1], c4[#c4][2])
local c5 = blade_chain(2.2, 430, 900, 0.7, 5, 0.04)
print(c5[1][1], c5[1][2], c5[#c5][1], c5[#c5][2])

--@ chunk 24
function paint_blade(th0, r0, r1, k, nseg, piles, dscale, opts)
  local ch = blade_chain(th0, r0, r1, k, nseg, 0.05)
  local depth = {}
  for i = 1, #ch - 1 do
    local mx, my = (ch[i][1] + ch[i+1][1]) / 2, (ch[i][2] + ch[i+1][2]) / 2
    local rr = math.sqrt((mx - RC[1])^2 + ((my - RC[2]) / 1.1)^2)
    depth[i] = dscale * rr
  end
  local mid = ch[math.floor(#ch / 2) + 1]
  local th = math.atan((mid[2] - RC[2]) / 1.1, mid[1] - RC[1])
  local rr = math.sqrt((mid[1] - RC[1])^2 + ((mid[2] - RC[2]) / 1.1)^2)
  local back = (opts and opts.lead) and 0.5 or -0.5
  local tw = {RC[1] + rr * math.cos(th + back), RC[2] + 1.1 * rr * math.sin(th + back)}
  local o = {piles = piles, depth = depth, toward = tw, clip = BEHIND, rig = (opts and opts.rig) or RIGW, width = 10}
  if opts then for kk, v in pairs(opts) do if kk ~= "lead" then o[kk] = v end end end
  sheet(ch, o)
  return ch
end
B1 = paint_blade(3.55, 395, 760, 0.9, 4, {ICE, PCY, TEALM, PCY}, 0.32)
B4 = paint_blade(0.75, 420, 900, 0.7, 5, {PMAG, COBV, PMAG, TEALM, COBV}, 0.3)

--@ chunk 25
local m = (poly({{-20,-20},{1020,-20},{1020,40},{720,130},{420,120},{260,180},{200,330},{170,480},{-20,520}}) + poly({{780,860},{1020,780},{1020,1400},{780,1400}})):soften(30) * BEHIND; blend(m,{angle=vortex,seed=31}); blend(m,{angle=vortex,seed=32})

--@ chunk 26
local m = poly({{700,860},{860,860},{860,1400},{700,1400}}):soften(40) * BEHIND; blend(m,{angle=vortex,seed=33, clip=false}); blend(m,{angle=-0.4,seed=34, clip=false})

--@ chunk 27
print(wait(36*60)); for _,p in ipairs({{100,100},{516,700},{516,400},{900,1200},{300,700},{600,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 28
BRZ_C = pile{{"bone black",1.5},{"raw sienna",1},{"viridian",0.6},{"cerulean blue",0.3}}
BRZ_W = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"Mars orange",0.3}}
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
local set = {BRZ_D, BRZ_M, BRZ_C, BRZ_D, BRZ_W, BRZ_C}
local function lay(t0, t1, f0, f1, dx, dy, rot, seed)
  local m = plate(t0, t1, f0, f1, dx, dy, rot)
  local p = set[math.random(#set)]
  work(m, {hand="body", tool="filbert 7", pile=p, coverage=2.6, fill=true, angle=tang, clip=true, seed=seed})
  -- a darker or lighter half to give each plate a turn
  local half = plate(t0, t1, f0, lerp(f0, f1, rand(0.35, 0.6)), dx, dy, rot)
  work(half, {hand="body", tool="filbert 6", pile=(math.random() < 0.5) and BRZ_D or BRZ_M, coverage=1.6, fill=false, angle=tang, clip=m, seed=seed + 1})
  blend(m, {angle=tang, seed=seed + 2})
end
for i, p in ipairs(PLATES) do lay(p[1], p[2], 0, 1, 0, 0, 0, 1000 + i * 3) end
for i, p in ipairs(OPLATES) do lay(p[1], p[2], 1.03, 2.1, 0, 0, 0, 1100 + i * 3) end
for i, b in ipairs(IBROKEN) do lay(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 1200 + i * 3) end
for i, b in ipairs(OBROKEN) do lay(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 1300 + i * 3) end

--@ chunk 29
print(wait(30*60)); for _,p in ipairs({{300,300},{516,700},{516,930},{760,700},{900,1200}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 30
print(wait(24*60)); for _,p in ipairs({{300,300},{516,700},{516,930},{760,700},{200,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 31
print(wait(48*60)); for _,p in ipairs({{300,300},{516,700},{516,930},{400,600},{620,860}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 32
RGLZ = pile{{"bone brown",1},{"ultramarine blue",0.8},{"bone black",0.3},medium=0.65}; local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end; local m = (RING + ORING + FRAG); work(m, {hand="glaze", tool="filbert 10", pile=RGLZ, coverage=1.6, angle=tang, clip=true, fill=true, length={30,90}, seed=3101})

--@ chunk 33
-- hot rim on the inner lip of each intact inner plate, and a softer warm band behind it
local band = brush{kind="round", width=5, point=0.4}
local rig = brush{kind="rigger", width=2.4, point=0.9}
for i, p in ipairs(PLATES) do
  local pts = {}
  local n = math.max(3, math.floor((p[2] - p[1]) * 30))
  for j = 0, n do pts[#pts + 1] = rpt(lerp(p[1] + 0.01, p[2] - 0.01, j / n), RI[1] + 3.5, RI[2] + 3.5) end
  -- brighter toward the bottom, where the light is strongest
  local mid = (p[1] + p[2]) / 2
  local s = 0.5 + 0.5 * math.sin(mid)   -- 1 at bottom (t = pi/2), 0 at top
  band:reload(GLOW2, 0.5)
  band:stroke(pts, {pressure={0.35 + 0.3 * s, 0.3 + 0.3 * s}, ramps={0.15, 0.2}})
  local pts2 = {}
  for j = 0, n do pts2[#pts2 + 1] = rpt(lerp(p[1] + 0.01, p[2] - 0.01, j / n), RI[1] + 1.2, RI[2] + 1.2) end
  rig:reload(s > 0.4 and GLOW5 or GLOW4, 0.8)
  rig:stroke(pts2, {pressure={0.45 + 0.4 * s, 0.4 + 0.4 * s}, ramps={0.1, 0.25}, swell={0.8, 1.1, 0.7}})
end

--@ chunk 34
-- restate the pillar where the glow and the ring covered it, and the capital
local upper = SHAFT * rect(470, 800, 100, 210)
work(upper + CAP, {hand="detail", tool={kind="flat", width=5}, pile=PIL, coverage=4, fill=true, angle=math.pi/2, clip=true, seed=3401})
-- the stylite: a narrow robed frame, head bowed, hands joined
FIG2 = poly({{516,746.5},{519.5,747.8},{521,751.5},{520.5,755.5},{524.5,758},{526.5,761.5},
  {527,768},{526,776},{525,781},{525.5,790},{526.5,799},{527.5,805.5},
  {505,805.5},{506,799},{507,790},{507.5,781},{506.5,776},{505.5,768},{506,761.5},
  {508,758},{511.5,755.5},{511.2,751.5},{512.6,747.8}}, true)
work(FIG2, {hand="detail", tool={kind="round", width=2}, pile=FIGP, coverage=6, fill=true, angle=math.pi/2, clip=true, seed=3402})
-- his staff
local r = brush{kind="round", width=1.8, point=0.3}
r:load(FIGP, 0.9)
r:stroke({{500.5, 806}, {500, 766}, {499.6, 727}}, {pressure={0.9, 0.85}, ramps={0.02, 0.05}})

--@ chunk 35
local band = brush{kind="round", width=6, point=0.3}
local rig = brush{kind="round", width=3, point=0.8}
for i, p in ipairs(PLATES) do
  local mid = (p[1] + p[2]) / 2
  local s = 0.5 + 0.5 * math.sin(mid)
  local n = math.max(3, math.floor((p[2] - p[1]) * 30))
  local a, b = p[1] + 0.012, p[2] - 0.012
  -- a lit bevel just outside the lip: warm, a few units wide
  local pts = {}
  for j = 0, n do pts[#pts + 1] = rpt(lerp(a, b, j / n), RI[1] + 4.5, RI[2] + 4.5) end
  band:reload(s > 0.5 and GLOW3 or GLOW2, 0.85)
  band:stroke(pts, {pressure={0.75, 0.7}, ramps={0.1, 0.2}})
  -- the hot edge itself
  local pts2 = {}
  for j = 0, n do pts2[#pts2 + 1] = rpt(lerp(a + 0.01, b - 0.01, j / n), RI[1] + 1.8, RI[2] + 1.8) end
  rig:reload(s > 0.3 and GLOW5 or GLOW4, 0.95)
  rig:stroke(pts2, {pressure={0.8, 0.75}, ramps={0.1, 0.2}, swell={0.8, 1.15, 0.8}})
end

--@ chunk 36
local function hw(y) return 17 + (y - 815) * 0.018 end
-- restate where the rim light crossed it
local fix = SHAFT * rect(470, 870, 100, 60)
work(fix, {hand="detail", tool={kind="flat", width=5}, pile=PIL, coverage=4, fill=true, angle=math.pi/2, clip=true, seed=3601})
PILL = pile{{"viridian",1},{"cerulean blue",1},{"bone black",0.6},{"lead white",0.5}}
local r = brush{kind="round", width=2.2, point=0.6}
local soft = brush{kind="filbert", width=6}
for i, d in ipairs(DRUMS) do
  if d.k == 0 then
    local y0, y1 = d.pts[1][2], d.pts[3][2]
    local xl0, xl1 = d.pts[1][1], d.pts[4][1]
    local xr0, xr1 = d.pts[2][1], d.pts[3][1]
    -- cold reflected light down the left third (dry brush)
    soft:reload(PILL, 0.25)
    soft:stroke({{lerp(xl0, xr0, 0.3), y0 + 1.5}, {lerp(xl1, xr1, 0.3), y1 - 1.5}}, {pressure={0.45, 0.35}})
    -- cold rim, left edge
    r:reload(TEALM, 0.7)
    r:stroke({{xl0 + 1.6, y0 + 1}, {xl1 + 1.6, y1 - 1}}, {pressure={0.5, 0.45}})
    -- right edge: warm where it stands against the light, else a dim cold
    local warm = y0 < 880
    r:reload(warm and GLOW3 or COBV, 0.7)
    r:stroke({{xr0 - 1.4, y0 + 1}, {xr1 - 1.4, y1 - 1}}, {pressure={warm and 0.55 or 0.35, warm and 0.5 or 0.3}})
  end
end
-- the capital: a lit upper edge against the glow
r:reload(GLOW3, 0.7)
r:stroke({{PX - 26, 806.2}, {PX + 25, 805.4}}, {pressure={0.4, 0.4}})

--@ chunk 37
local m=nil; for i,d in ipairs(DRUMS) do if d.k==0 then local q=poly(d.pts); m = m and (m+q) or q end end; blend(m:shrink(1.5), {angle=0.1, tool={kind="badger", width=12}}); blend(m:shrink(1.5), {angle=math.pi/2})

--@ chunk 38
for i,d in ipairs(DRUMS) do print(i, string.format("k=%.2f y=%.0f-%.0f x=%.0f-%.0f", d.k, d.pts[1][2], d.pts[3][2], d.pts[1][1], d.pts[2][1])) end

--@ chunk 39
-- a strip of hinged panels unfolding from a hinge a-b.
-- o: n, w (first width), grow (per panel), turn (start angle offset), dturn (per panel), skew, side (+1/-1)
-- returns list of panels {pts={a,b,b2,a2}, i=}
function unfold_strip(a, b, o)
  local panels = {}
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L * o.side, dx / L * o.side
  local base = math.atan(ny, nx)
  local th = base + (o.turn or 0)
  local w = o.w
  for i = 1, o.n do
    local sk = (o.skew or 0.2) * (i % 2 == 0 and 1 or -1) + rand(-0.08, 0.08)
    local a2 = {a[1] + w * math.cos(th - sk * 0.5), a[2] + w * math.sin(th - sk * 0.5)}
    local b2 = {b[1] + w * math.cos(th + sk * 0.5), b[2] + w * math.sin(th + sk * 0.5)}
    -- the new hinge grows about its middle
    local mx, my = (a2[1] + b2[1]) / 2, (a2[2] + b2[2]) / 2
    local g = o.grow or 1.1
    a2 = {mx + (a2[1] - mx) * g, my + (a2[2] - my) * g}
    b2 = {mx + (b2[1] - mx) * g, my + (b2[2] - my) * g}
    panels[#panels + 1] = {pts = {a, b, b2, a2}, i = i}
    a, b = a2, b2
    th = th + (o.dturn or 0.2) + rand(-0.05, 0.05)
    w = w * (o.wgrow or 1.1)
  end
  return panels
end
-- calm the dashed band in the lower field first: a broad vortex pass of the field's own darks
local band = poly({{-20,960},{1020,980},{1020,1180},{-20,1160}}):soften(40) * -(SHAFT:grow(2)) * -(FRAG:grow(2))
work(band * mask(function(x,y) return x < 760 and 1 or 0 end):soften(40), {hand="broad", pile=VIO, coverage=1.2, angle=vortex, load=0.5, seed=3901, clip=-(SHAFT:grow(2) + FRAG:grow(3) + rellipse(364,399))})

--@ chunk 40
PANEL_A = {{"bone black",1.2},{"ultramarine blue",1},{"viridian",0.5}}
PANEL_B = {{"ultramarine blue",1},{"viridian",0.6},{"lead white",0.5},{"bone black",0.3}}
PANEL_C = {{"cobalt violet",1},{"ultramarine blue",0.6},{"lead white",0.4},{"bone black",0.2}}
function paint_panels(panels, opts)
  local rig = brush{kind="rigger", width=2.2, point=0.9}
  local nP = #panels
  for _, p in ipairs(panels) do
    local t = (p.i - 1) / math.max(1, nP - 1)
    local tubes = ({PANEL_A, PANEL_B, PANEL_A, PANEL_C})[(p.i - 1) % 4 + 1]
    local pl = {}
    for k, v in ipairs(tubes) do pl[k] = v end
    pl.medium = lerp(0.05, 0.75, t)
    local q = poly(p.pts)
    local face = q * opts.clip
    work(face, {hand="body", tool="filbert 8", pile=pile(pl), coverage=lerp(3, 1.2, t), fill=t < 0.6, clip=opts.clip,
      angle=math.atan(p.pts[4][2] - p.pts[1][2], p.pts[4][1] - p.pts[1][1]), edge={found=0.7, soft=0.3, period=40}, seed=opts.seed + p.i})
    -- the hinge it opens on: a cold lit edge
    rig:reload((p.i % 2 == 0) and ICE or PCY, lerp(0.85, 0.5, t))
    rig:stroke({p.pts[4], {lerp(p.pts[4][1], p.pts[3][1], 0.5) + rand(-1, 1), lerp(p.pts[4][2], p.pts[3][2], 0.5) + rand(-1, 1)}, p.pts[3]},
      {pressure={lerp(0.6, 0.3, t), lerp(0.5, 0.2, t)}, ramps={0.1, 0.3}, clip=opts.clip})
  end
end
local d8, d10 = DRUMS[8].pts, DRUMS[10].pts
LEFTP = unfold_strip(d8[1], d8[4], {side=1, n=7, w=36, grow=1.12, wgrow=1.12, turn=0.05, dturn=-0.19, skew=0.25})
RIGHTP = unfold_strip(d10[2], d10[3], {side=-1, n=6, w=34, grow=1.1, wgrow=1.12, turn=0.15, dturn=-0.2, skew=0.22})
local clip = -(SHAFT:grow(1))
paint_panels(LEFTP, {clip=clip, seed=4000})
paint_panels(RIGHTP, {clip=clip, seed=4100})

--@ chunk 41
local m=nil; for _,p in ipairs(LEFTP) do local q=poly(p.pts); m=m and (m+q) or q end; for _,p in ipairs(RIGHTP) do m=m+poly(p.pts) end; m=m:grow(3)*-(SHAFT:grow(1)); blend(m,{angle=vortex,seed=41}); blend(m,{angle=function(x,y) return vortex(x,y)+1.2 end,seed=42})

--@ chunk 42
print(drying(516,500), drying(400,700))

--@ chunk 43
STAFF = ribbon({{500.5, 806}, {500, 766}, {499.6, 727}}, 2.2)
FIGALL = FIG2:grow(1) + SHAFT:grow(1) + CAP:grow(1) + STAFF
local inside = AP:shrink(1) * -FIGALL
local cx, cy = 516, 728
-- deepen the far part of the opening: warm transparent glazes, heavier toward the top
local g1 = pile{{"burnt sienna",1},{"Indian yellow",0.6},{"rose madder",0.15},medium=0.72}
local g2 = pile{{"burnt sienna",1},{"bone brown",0.3},{"rose madder",0.2},medium=0.7}
local up1 = inside * -ellipse(cx, cy + 20, 210, 230):soften(60)
local up2 = inside * above(function(x) return 500 + 0.0012 * (x - 516)^2 end):soften(70)
work(up1, {hand="glaze", pile=g1, coverage=1.3, angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi/2 end, clip=inside, seed=4201})
work(up2, {hand="glaze", pile=g2, coverage=1.0, angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi/2 end, clip=inside, seed=4202})

--@ chunk 44
local cx,cy=516,728; local inside = AP:shrink(1) * -FIGALL:grow(3); blend(inside * -ellipse(cx,cy+20,150,170):soften(40), {angle=function(x,y) return math.atan(y-cy,x-cx)+math.pi/2 end, tool={kind="badger", width=30}})

--@ chunk 45
local cx,cy=516,738; local ex = AP:shrink(2) * -FIGALL:grow(1.5); local W1 = pile{{"lead white",6},{"lemon chrome",0.5}}; local W2 = pile{{"lead white",1}}; stipple(ellipse(cx,cy,95,105)*ex, {pile=W1, width=7, coverage=function(x,y) local d=math.sqrt(((x-cx)/95)^2+((y-cy)/105)^2); return clamp(2.2*(1-d),0,2.2) end, feather=0.8, cluster=0.3, clip=ex, seed=4501}); stipple(ellipse(cx,cy-5,45,50)*ex, {pile=W2, width=5, coverage=function(x,y) local d=math.sqrt(((x-cx)/45)^2+((y-cy+5)/50)^2); return clamp(2.5*(1-d),0,2.5) end, feather=0.8, clip=ex, seed=4502})

--@ chunk 46
local cx,cy=516,738; local ex = AP:shrink(2) * -FIGALL:grow(2); local m = ellipse(cx,cy,115,125):soften(30)*ex; blend(m,{angle=function(x,y) return math.atan(y-cy,x-cx) end, tool={kind="badger",width=16}}); blend(m,{angle=function(x,y) return math.atan(y-cy,x-cx)+1.57 end, tool={kind="badger",width=16}, seed=7})

--@ chunk 47
for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 48
print(wait(3*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950},{516,450},{516,740},{300,1200}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 49
print(wait(3*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950},{300,1200}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 50
local function rp(t, f) return rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)) end
local dark = brush{kind="round", width=3.2, point=0.5}
local lit = brush{kind="rigger", width=1.6, point=0.9}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
local function intact(t) t = t % (2 * math.pi); return not (t > 0.12 and t < 1.32) end
-- inner course seams: dark joints; where the joint meets the lip, light leaks through
for i, p in ipairs(PLATES) do
  local t = p[1] - 0.006
  dark:reload(SEAM, 0.8)
  dark:stroke({rp(t, -0.02), rp(t, 0.5), rp(t, 1.0)}, {pressure={0.75, 0.7}, ramps={0.05, 0.1}})
  lit:reload(GLOW3, 0.7)
  lit:stroke({rp(t, 0.0), rp(t, 0.22 + rand(0, 0.15))}, {pressure={0.55, 0.0}, ramps={0.05, 0.8}})
  -- a cold bevel catching the space on the joint's leading side
  lit:reload(TEALM, 0.5)
  lit:stroke({rp(t + 0.009, 0.15), rp(t + 0.009, 0.95)}, {pressure={0.25, 0.35}, ramps={0.3, 0.3}})
end
for i, p in ipairs(OPLATES) do
  local t = p[1] - 0.005
  if intact(t) then
    dark:reload(SEAM, 0.8)
    dark:stroke({rp(t, 1.0), rp(t, 1.55), rp(t, 2.12)}, {pressure={0.75, 0.75}, ramps={0.05, 0.1}})
    lit:reload(TEALM, 0.5)
    lit:stroke({rp(t + 0.008, 1.1), rp(t + 0.008, 2.0)}, {pressure={0.25, 0.35}, ramps={0.3, 0.3}})
  end
end
-- the joint between the two courses
local pts = {}
for k = 0, 80 do local t = 1.32 + (2 * math.pi - 1.32 + 0.12) * k / 80; pts[#pts + 1] = rp(t, 1.015) end
dark:reload(SEAM, 0.9)
for k = 1, #pts - 8, 8 do
  if k % 16 == 1 then dark:reload(SEAM, 0.8) end
  dark:stroke({pts[k], pts[k + 4], pts[k + 8]}, {pressure={0.7, 0.7}, ramps={0.05, 0.05}})
end

--@ chunk 51
SHEEN = pile{{"yellow ochre",1.5},{"viridian",0.5},{"lead white",1},{"raw sienna",0.5}}
SHEEN_P = pile{{"lead white",1},{"cobalt violet",0.6},{"yellow ochre",0.5},{"raw sienna",0.3}}
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
local function sheen(t0, t1, f0, f1, dx, dy, rot, seed)
  local mid = (t0 + t1) / 2
  local s1 = math.max(0, math.cos(mid - 3.93))^1.5
  local s2 = math.max(0, math.cos(mid - 0.9))^2
  local m = plate(t0, t1, f0, f1, dx, dy, rot)
  -- the band of the plate turned to the light: nearer its outer edge for the outer course
  local band = plate(t0 + 0.01, t1 - 0.01, lerp(f0, f1, 0.45 + rand(-0.1, 0.1)), lerp(f0, f1, 0.95), dx, dy, rot)
  if s1 > 0.08 then
    work(band, {hand="scumble", pile=SHEEN, coverage=1.6 * s1, load=0.35, angle=tang, clip=m, seed=seed})
  end
  if s2 > 0.1 then
    work(band, {hand="scumble", pile=SHEEN_P, coverage=1.4 * s2, load=0.35, angle=tang, clip=m, seed=seed + 1})
  end
end
for i, p in ipairs(OPLATES) do sheen(p[1], p[2], 1.03, 2.1, 0, 0, 0, 5100 + i * 3) end
for i, p in ipairs(PLATES) do sheen(p[1], p[2], 0, 1, 0, 0, 0, 5200 + i * 3) end
for i, b in ipairs(IBROKEN) do sheen(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 5300 + i * 3) end
for i, b in ipairs(OBROKEN) do sheen(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 5400 + i * 3) end

--@ chunk 52
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end; local m = (RING + ORING + FRAG) * -SHAFT:grow(1); blend(m, {angle=tang, tool={kind="badger", width=14}, seed=52}); blend(m, {angle=tang, tool={kind="badger", width=10}, seed=53})

--@ chunk 53
print(wait(2*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 54
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
GZ_BRZ = pile{{"burnt sienna",1},{"viridian",0.4},{"bone brown",0.4},medium=0.65}
GZ_DK  = pile{{"bone brown",1},{"ultramarine blue",0.8},{"bone black",0.3},medium=0.65}
local ringall = (RING + ORING + FRAG) * -FIGALL:grow(1)
work(ringall, {hand="glaze", tool="filbert 12", pile=GZ_BRZ, coverage=2, fill=true, angle=tang, clip=ringall, seed=5401})
blend(ringall, {angle=tang, tool={kind="badger", width=20}, seed=5402})
-- the turned-away side: everything but the upper left, which faces the cold light
local away = ringall * mask(function(x, y)
  local a = math.atan(y - RC[2], x - RC[1])
  return clamp(0.55 - math.cos(a - 3.93), 0, 1)
end):blur(20)
work(away, {hand="glaze", tool="filbert 12", pile=GZ_DK, coverage=1.6, fill=true, angle=tang, clip=ringall, seed=5403})
blend(away:grow(10) * ringall, {angle=tang, tool={kind="badger", width=20}, seed=5404})

--@ chunk 55
local m = SHAFT * rect(470, 860, 100, 180); work(m, {hand="detail", tool={kind="flat", width=5}, pile=PIL, coverage=4.5, fill=true, angle=math.pi/2, clip=true, seed=5501}); blend(m:shrink(1.2), {angle=math.pi/2, tool={kind="badger", width=10}})

--@ chunk 56
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.4}}; local r = brush{kind="round", width=3, point=0.3}; for i=1,7 do local d=DRUMS[i].pts; if d[3][2] > 850 then r:reload(SEAM,0.8); r:stroke({{d[4][1]-1,d[4][2]+1.2},{d[3][1]+1,d[3][2]+1.2}},{pressure={0.8,0.8}}) end end; local function hw(y) return 17 + (y - 815) * 0.018 end; for _,s in ipairs({-1,1}) do r:reload(SEAM,0.8); r:stroke({{PX+s*(hw(870)+0.8),870},{PX+s*(hw(960)+0.8),960},{PX+s*(hw(1040)+0.8),1040}},{pressure={0.75,0.75}}) end

--@ chunk 57
print(wait(3*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950},{300,1250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 58
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end; local ringall = (RING + ORING + FRAG) * -FIGALL:grow(1); local away = ringall * mask(function(x, y) local a = math.atan(y - RC[2], x - RC[1]); return clamp(0.8 - math.cos(a - 3.93), 0, 1) end):blur(20); local g = pile{{"burnt sienna",1},{"Indian yellow",0.3},{"bone brown",0.3},medium=0.65}; work(away, {hand="glaze", tool="filbert 12", pile=g, coverage=1.6, fill=true, angle=tang, clip=ringall, seed=5801}); blend(away:grow(10) * ringall, {angle=tang, tool={kind="badger", width=20}, seed=5802})

--@ chunk 59
-- the lattice of ordinary space, straight where it starts, then caught and curled by the swirl
function lattice_line(x, y, ang, straight, curl, step, nmax)
  local pts = {{x, y}}
  local a = ang
  local d = 0
  for i = 1, nmax do
    local k = clamp((d - straight) / curl, 0, 1)
    local target = vortex(x, y)
    -- turn toward the swirl direction (the nearer of its two senses)
    local diff = math.atan(math.sin(target - a), math.cos(target - a))
    if math.abs(diff) > math.pi / 2 then diff = math.atan(math.sin(target + math.pi - a), math.cos(target + math.pi - a)) end
    a = a + diff * 0.25 * k
    x, y = x + step * math.cos(a), y + step * math.sin(a)
    d = d + step
    pts[#pts + 1] = {x, y}
  end
  return pts
end
LATW = pile{{"zinc white",3},{"cerulean blue",0.5},{"emerald green",0.2}}
LATV = pile{{"zinc white",2},{"cobalt violet",1}}
local rig = brush{kind="rigger", width=1.6, point=0.9}
local clip = BEHIND
-- family 1: lines running down-left to up-right across the dark upper right
local u = -0.62
for i, off in ipairs(uneven(9, 0, 260, 0.25, 0.2, 59)) do
  local x0, y0 = 700 + off * math.cos(u + math.pi / 2) - 120, 380 + off * math.sin(u + math.pi / 2) - 200
  local pts = lattice_line(x0, y0, u, rand(60, 150), rand(80, 160), 6, 55)
  rig:reload((i % 3 == 0) and LATV or LATW, 0.6)
  rig:stroke(pts, {pressure={0.45, 0.0}, ramps={0.1, 0.6}, swell={1, 0.9, 0.6}, clip=clip})
end
-- family 2: crossing them
local v = u + 1.45
for i, off in ipairs(uneven(8, 0, 240, 0.25, 0.2, 60)) do
  local x0, y0 = 760 + off * math.cos(v - math.pi / 2), 150 + off * math.sin(v - math.pi / 2)
  local pts = lattice_line(x0, y0, v, rand(50, 120), rand(70, 150), 6, 45)
  rig:reload((i % 3 == 1) and LATV or LATW, 0.55)
  rig:stroke(pts, {pressure={0.4, 0.0}, ramps={0.1, 0.6}, clip=clip})
end

--@ chunk 60
print(wait(3*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{700,950},{850,150}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 61
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
GZ_DK2 = pile{{"bone brown",1},{"burnt sienna",0.4},{"ultramarine blue",0.6},{"bone black",0.2},medium=0.62}
local ringall = (RING + ORING + FRAG) * -FIGALL:grow(1)
-- radius factor f of a point (0 at the lip, 1 at the course joint, 2.1 at the outer edge)
local function ff(x, y)
  local dx, dy = x - RC[1], y - RC[2]
  local c, s = math.cos(-RROT), math.sin(-RROT)
  local lx, ly = dx * c - dy * s, dx * s + dy * c
  local rx = math.sqrt((lx / RI[1])^2 + (ly / RI[2])^2)   -- 1 at the lip
  return (rx - 1) * RI[1] / (RO[1] - RI[1])
end
local shade = ringall * mask(function(x, y)
  local a = math.atan(y - RC[2], x - RC[1])
  local side = clamp(0.35 - 0.9 * math.cos(a - 3.93), 0, 1)      -- turned from the cold light
  local f = ff(x, y)
  local outer = clamp((f - 1.45) / 0.6, 0, 1) * 0.8               -- the outer edge rolls away
  local joint = clamp(1 - math.abs(f - 1.0) / 0.18, 0, 1) * 0.6   -- shadow along the joint between courses
  return clamp(side + outer + joint, 0, 1)
end):blur(6)
work(shade, {hand="glaze", tool="filbert 10", pile=GZ_DK2, coverage=2.2, fill=true, angle=tang, clip=ringall, seed=6101})
blend(shade:grow(6) * ringall, {angle=tang, tool={kind="badger", width=16}, seed=6102})
-- fragments: mostly in shadow
work(FRAG * -FIGALL, {hand="glaze", tool="filbert 8", pile=GZ_DK2, coverage=1.5, fill=true, angle=tang, clip=FRAG, seed=6103})

--@ chunk 62
local GV = pile{{"ultramarine blue",1},{"magenta",0.3},{"bone black",0.4},medium=0.7}
local rig = brush{kind="rigger", width=2, point=0.9}
local clip = -(SHAFT:grow(1))
for _, set in ipairs({LEFTP, RIGHTP}) do
  for _, p in ipairs(set) do
    local q = poly(p.pts) * clip
    if p.i % 2 == 0 then
      work(q, {hand="glaze", tool="filbert 10", pile=GV, coverage=1.4, fill=true, clip=q,
        angle=math.atan(p.pts[3][2] - p.pts[4][2], p.pts[3][1] - p.pts[4][1]), seed=6200 + p.i})
    end
  end
end
for _, set in ipairs({LEFTP, RIGHTP}) do
  for _, p in ipairs(set) do
    if p.i < #set then
      local t = (p.i - 1) / (#set - 1)
      rig:reload((p.i % 2 == 0) and ICE or PCY, 0.7)
      local a, b = p.pts[4], p.pts[3]
      rig:stroke({a, {lerp(a[1], b[1], 0.5), lerp(a[2], b[2], 0.5)}, b}, {pressure={0.55 - 0.3 * t, 0.2}, ramps={0.05, 0.5}, clip=clip})
    end
  end
end

--@ chunk 63
local GVf = pile{{"ultramarine blue",1},{"magenta",0.5},{"bone black",0.6},medium=0.6}; for _,set in ipairs({LEFTP,RIGHTP}) do for _,p in ipairs(set) do if p.i >= #set-2 then local q=poly(p.pts):grow(3)*-(SHAFT:grow(1)); work(q,{hand="glaze",tool="filbert 12",pile=GVf,coverage=(p.i-#set+3)*0.8,fill=true,angle=vortex,clip=q,seed=6300+p.i}) end end end

--@ chunk 64
local TOPW = pile{{"Mars orange",1},{"burnt sienna",0.6},{"lead white",0.6},{"Indian yellow",0.3}}
local rig = brush{kind="rigger", width=1.8, point=0.9}
for i = 7, #DRUMS do
  local d = DRUMS[i]
  local a, b = d.pts[1], d.pts[2]
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / L, -dx / L       -- points up, out of the drum
  local h = 2.5 + d.k * 5               -- the more it has turned, the more of its top we see
  local pts = {}
  for j = 0, 12 do
    local t = j / 12
    local bul = math.sin(math.pi * t)
    pts[#pts + 1] = {a[1] + dx * t + nx * h * bul, a[2] + dy * t + ny * h * bul}
  end
  for j = 11, 1, -1 do
    local t = j / 12
    local bul = math.sin(math.pi * t)
    pts[#pts + 1] = {a[1] + dx * t - nx * h * 0.5 * bul, a[2] + dy * t - ny * h * 0.5 * bul}
  end
  local lens = poly(pts)
  work(lens, {hand="detail", tool={kind="round", width=2}, pile=TOPW, coverage=4, fill=true, angle=math.atan(dy, dx), clip=true, seed=6400 + i})
  -- a cold rim down the left side, a dim one down the right
  rig:reload(PCY, 0.6)
  rig:stroke({{d.pts[1][1] + 1.5 * dx / L, d.pts[1][2] + 1.5 * dy / L + 2}, d.pts[4]}, {pressure={0.45, 0.25}, ramps={0.05, 0.4}})
  rig:reload(COBV, 0.5)
  rig:stroke({{d.pts[2][1] - 1.5 * dx / L, d.pts[2][2] - 1.5 * dy / L + 2}, d.pts[3]}, {pressure={0.35, 0.2}, ramps={0.05, 0.4}})
end

--@ chunk 65
print(wait(3*24*60)); for _,p in ipairs({{520,1180},{850,680},{300,300},{620,860},{850,150}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 66
local G = pile{{"bone brown",1},{"ultramarine blue",0.8},{"magenta",0.2},medium=0.6}; for i=7,#DRUMS do local d=DRUMS[i]; local a,b=d.pts[1],d.pts[2]; local m = ellipse((a[1]+b[1])/2,(a[2]+b[2])/2, 32, 9+d.k*6); work(m, {hand="glaze", tool="filbert 6", pile=G, coverage=0.7+1.6*d.k, fill=true, clip=m, angle=math.atan(b[2]-a[2],b[1]-a[1]), seed=6600+i}) end

--@ chunk 67
local m=nil; for i=7,#DRUMS do local d=DRUMS[i]; local a,b=d.pts[1],d.pts[2]; local e = ellipse((a[1]+b[1])/2,(a[2]+b[2])/2, 40, 16+d.k*6):soften(8); m = m and (m+e) or e end; blend(m, {angle=0, tool={kind="badger", width=10}, seed=67})

--@ chunk 68
local function rp(t, f, dx, dy) local p = rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)); return {p[1] + (dx or 0), p[2] + (dy or 0)} end
SPEC  = pile{{"lead white",3},{"yellow ochre",0.5},{"viridian",0.2}}
SPECW = pile{{"lead white",3},{"lemon chrome",0.3}}
local rig = brush{kind="rigger", width=2.2, point=0.85}
local function light(t) return math.max(0, math.cos(t - 3.93)) end
local function bevel(t0, t1, f, strength, pl)
  local pts = {}
  local n = math.max(3, math.floor((t1 - t0) * 30))
  for j = 0, n do pts[#pts + 1] = rp(lerp(t0, t1, j / n), f) end
  rig:reload(pl, 0.75)
  rig:stroke(pts, {pressure={0.15, 0.15}, swell={0.4, 1.0 * strength + 0.3, 1.1 * strength + 0.3, 0.3}, ramps={0.3, 0.3}})
end
-- outer course: the outer bevel and the inner bevel catch the cold light
for i, p in ipairs(OPLATES) do
  local mid = (p[1] + p[2]) / 2
  local s = light(mid)
  if s > 0.15 then
    local a = lerp(p[1], p[2], rand(0.05, 0.3)); local b = lerp(p[1], p[2], rand(0.6, 0.95))
    bevel(a, b, 2.03, s, s > 0.7 and SPECW or SPEC)
    if s > 0.4 then bevel(lerp(p[1], p[2], 0.2), lerp(p[1], p[2], 0.7), 1.1, s * 0.6, SPEC) end
  end
end
-- inner course: a bevel at its outer edge
for i, p in ipairs(PLATES) do
  local mid = (p[1] + p[2]) / 2
  local s = light(mid)
  if s > 0.2 then
    bevel(lerp(p[1], p[2], rand(0.1, 0.3)), lerp(p[1], p[2], rand(0.55, 0.9)), 0.94, s * 0.8, SPEC)
  end
end
-- a few hard sparks where the bevels turn most squarely to the light
local dot = brush{kind="round", width=3, point=0.5}
for k = 1, 9 do
  local t = 3.93 + randn(0, 0.35)
  local f = ({2.03, 1.1, 0.94})[math.random(3)]
  local p = rp(t, f)
  dot:reload(SPECW, 0.9)
  dot:touch(p[1], p[2], {pressure=rand(0.4, 0.7)})
end

--@ chunk 69
EXF = -FIGALL:grow(1)
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
BRZ_MID = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.7},{"yellow ochre",0.5}}
BRZ_HI  = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8},{"viridian",0.25}}
BRZ_HI2 = pile{{"yellow ochre",1.5},{"lead white",1.2},{"viridian",0.35},{"cerulean blue",0.1}}
local function light(t) return math.max(0, math.cos(t - 3.93)) end
local function model(t0, t1, f0, f1, dx, dy, rot, seed)
  local mid = (t0 + t1) / 2
  local s = light(mid)
  local whole = plate(t0, t1, f0, f1, dx, dy, rot) * EXF
  local c1 = rand(0.18, 0.3); local c2 = rand(0.45, 0.6); local c3 = rand(0.72, 0.85)
  local bands = {
    {0, c1, BRZ_D},
    {c1, c2, (s > 0.3) and BRZ_MID or BRZ_D},
    {c2, c3, (s > 0.55) and BRZ_HI2 or ((s > 0.2) and BRZ_HI or BRZ_MID)},
    {c3, 1, BRZ_D},
  }
  for k, b in ipairs(bands) do
    local m = plate(t0, t1, lerp(f0, f1, b[1]), lerp(f0, f1, b[2]), dx, dy, rot)
    work(m, {hand="body", tool="filbert 6", pile=b[3], coverage=2.6, fill=true, angle=tang, clip=whole, seed=seed + k})
  end
  blend(whole, {angle=tang, tool={kind="badger", width=12}, seed=seed + 7})
end
EXF = -FIGALL:grow(1)
for i, p in ipairs(OPLATES) do model(p[1], p[2], 1.03, 2.1, 0, 0, 0, 6900 + i * 10) end
for i, p in ipairs(PLATES) do model(p[1], p[2], 0.12, 1, 0, 0, 0, 7200 + i * 10) end
for i, b in ipairs(IBROKEN) do model(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 7500 + i * 10) end
for i, b in ipairs(OBROKEN) do model(b[1], b[2], b[3], b[4], b[5], b[6], b[7], 7700 + i * 10) end

--@ chunk 70
print(wait(3*24*60)); for _,p in ipairs({{300,300},{620,860},{250,600},{820,450},{860,700}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 71
print(wait(3*24*60)); for _,p in ipairs({{300,300},{250,600},{820,450}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 72
local function tang(x, y) return math.atan(y - RC[2], x - RC[1]) + math.pi / 2 end
GZ_DK2 = pile{{"bone brown",1},{"burnt sienna",0.4},{"ultramarine blue",0.6},{"bone black",0.2},medium=0.62}
local ringall = (RING + ORING + FRAG) * -FIGALL:grow(1)
-- radius factor f of a point (0 at the lip, 1 at the course joint, 2.1 at the outer edge)
local function ff(x, y)
  local dx, dy = x - RC[1], y - RC[2]
  local c, s = math.cos(-RROT), math.sin(-RROT)
  local lx, ly = dx * c - dy * s, dx * s + dy * c
  local rx = math.sqrt((lx / RI[1])^2 + (ly / RI[2])^2)   -- 1 at the lip
  return (rx - 1) * RI[1] / (RO[1] - RI[1])
end
local shade = ringall * mask(function(x, y)
  local a = math.atan(y - RC[2], x - RC[1])
  local side = clamp(0.35 - 0.9 * math.cos(a - 3.93), 0, 1)      -- turned from the cold light
  local f = ff(x, y)
  local outer = clamp((f - 1.45) / 0.6, 0, 1) * 0.8               -- the outer edge rolls away
  local joint = clamp(1 - math.abs(f - 1.0) / 0.18, 0, 1) * 0.6   -- shadow along the joint between courses
  return clamp(side + outer + joint, 0, 1)
end):blur(6)
work(shade, {hand="glaze", tool="filbert 10", pile=GZ_DK2, coverage=1.8, fill=true, angle=tang, clip=ringall, seed=7201})
blend(shade:grow(6) * ringall, {angle=tang, tool={kind="badger", width=16}, seed=7202})
-- fragments: mostly in shadow
work(FRAG * -FIGALL, {hand="glaze", tool="filbert 8", pile=GZ_DK2, coverage=1.2, fill=true, angle=tang, clip=FRAG, seed=7203})

--@ chunk 73
-- inverted stars: dark specks where the space is pale, cold pale ones where it is dark
local dot = brush{kind="round", width=2.2, point=0.6}
local DSTAR = pile{{"bone black",2},{"ultramarine blue",1},{"magenta",0.3}}
local PSTAR = pile{{"zinc white",3},{"cerulean blue",0.4},{"emerald green",0.2}}
local avoid = rellipse(380, 415) + SHAFT:grow(8) + CAP:grow(8)
for _, l in ipairs(LEFTP) do avoid = avoid + poly(l.pts):grow(4) end
for _, l in ipairs(RIGHTP) do avoid = avoid + poly(l.pts):grow(4) end
avoid = avoid + FRAG:grow(6)
-- clustered positions
local cl = worley{seed=73, period=170, jitter=0.9}
local placed = 0
local tries = 0
while placed < 130 and tries < 4000 do
  tries = tries + 1
  local x, y = rand(5, 995), rand(5, H - 5)
  local c = cl:at(x, y)
  local near = (type(c) == "table") and c[1] or 0
  if avoid:at(x, y) < 0.1 and math.random() < 0.35 then
    -- the pale clouds: upper left and lower right diagonal
    local pale = (x + (H - y) * 0.2 < 380 and y < 720) or (x > 640 and y > 980) or (y < 120 and x < 700)
    local big = math.random() < 0.08
    if pale then
      dot:reload(DSTAR, 0.8)
      dot:touch(x, y, {pressure=big and rand(0.5, 0.7) or rand(0.15, 0.35)})
    else
      dot:reload(PSTAR, 0.8)
      dot:touch(x, y, {pressure=big and rand(0.45, 0.6) or rand(0.12, 0.3)})
    end
    placed = placed + 1
  end
end
print(placed)

--@ chunk 74
-- inverted stars: dark specks where the space is pale, cold pale ones where it is dark
local dot = brush{kind="round", width=3.6, point=0.5}
local DSTAR = pile{{"bone black",2},{"ultramarine blue",1},{"magenta",0.3}}
local PSTAR = pile{{"zinc white",3},{"cerulean blue",0.4},{"emerald green",0.2}}
local avoid = rellipse(380, 415) + SHAFT:grow(8) + CAP:grow(8)
for _, l in ipairs(LEFTP) do avoid = avoid + poly(l.pts):grow(4) end
for _, l in ipairs(RIGHTP) do avoid = avoid + poly(l.pts):grow(4) end
avoid = avoid + FRAG:grow(6)
-- clustered positions
local cl = worley{seed=74, period=170, jitter=0.9}
local placed = 0
local tries = 0
while placed < 60 and tries < 4000 do
  tries = tries + 1
  local x, y = rand(5, 995), rand(5, H - 5)
  local c = cl:at(x, y)
  local near = (type(c) == "table") and c[1] or 0
  if avoid:at(x, y) < 0.1 and math.random() < 0.35 then
    -- the pale clouds: upper left and lower right diagonal
    local pale = (x + (H - y) * 0.2 < 380 and y < 720) or (x > 640 and y > 980) or (y < 120 and x < 700)
    local big = math.random() < 0.08
    if pale then
      dot:reload(DSTAR, 0.8)
      dot:touch(x, y, {pressure=big and rand(0.7, 0.95) or rand(0.35, 0.6)})
    else
      dot:reload(PSTAR, 0.8)
      dot:touch(x, y, {pressure=big and rand(0.6, 0.85) or rand(0.3, 0.5)})
    end
    placed = placed + 1
  end
end
print(placed)

--@ chunk 75
print(wait(4*24*60)); for _,p in ipairs({{300,300},{250,600},{820,450},{860,700},{700,950}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 76
function frag_corners(t0, t1, f0, f1, dx, dy, rot)
  local function P(t, f) return rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)) end
  local pts = {}
  local n = math.max(4, math.floor((t1 - t0) * 40))
  for i = 0, n do pts[#pts + 1] = P(lerp(t0, t1, i / n), f1) end
  for i = n, 0, -1 do pts[#pts + 1] = P(lerp(t0, t1, i / n), f0) end
  local cx, cy = 0, 0
  for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end
  cx, cy = cx / #pts, cy / #pts
  local c, s = math.cos(rot or 0), math.sin(rot or 0)
  for _, p in ipairs(pts) do
    local x, y = p[1] - cx, p[2] - cy
    p[1], p[2] = cx + x * c - y * s + (dx or 0), cy + x * s + y * c + (dy or 0)
  end
  return pts, n
end
local rig = brush{kind="rigger", width=2.2, point=0.85}
local flat = brush{kind="flat", width=4}
local L1 = {-0.72, -0.69}   -- the cold light, upper left
local L2 = {0.75, 0.66}     -- the pink glow, lower right
local function edges(b)
  local pts, n = frag_corners(table.unpack(b))
  -- polygon edges: outer arc (1..n+1), side (n+1 -> n+2), inner arc, side back
  local m = #pts
  local cx, cy = 0, 0
  for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end
  cx, cy = cx / m, cy / m
  local runs = {{1, n + 1}, {n + 1, n + 2}, {n + 2, m}, {m, 1}}
  for _, r in ipairs(runs) do
    local path = {}
    if r[1] < r[2] then for k = r[1], r[2] do path[#path + 1] = pts[k] end else path = {pts[r[1]], pts[r[2]]} end
    local a, z = path[1], path[#path]
    local mx, my = (a[1] + z[1]) / 2, (a[2] + z[2]) / 2
    local ex, ey = z[1] - a[1], z[2] - a[2]
    local l = math.sqrt(ex * ex + ey * ey) + 1e-6
    local nx, ny = ey / l, -ex / l
    if nx * (mx - cx) + ny * (my - cy) < 0 then nx, ny = -nx, -ny end
    local d1 = nx * L1[1] + ny * L1[2]
    local d2 = nx * L2[1] + ny * L2[2]
    if d1 > 0.25 then
      rig:reload(d1 > 0.7 and SPECW or SPEC, 0.8)
      rig:stroke(path, {pressure={0.35 + 0.4 * d1, 0.3 + 0.4 * d1}, ramps={0.15, 0.25}})
    elseif d2 > 0.35 then
      rig:reload(PMAG, 0.7)
      rig:stroke(path, {pressure={0.3 + 0.3 * d2, 0.25 + 0.3 * d2}, ramps={0.15, 0.25}})
    end
  end
end
for _, b in ipairs(IBROKEN) do edges(b) end
for _, b in ipairs(OBROKEN) do edges(b) end

--@ chunk 77
-- light leaking out through the broken arc: a warm haze, fading into the cold
local LEAK1 = pile{{"cadmium yellow",1},{"Indian yellow",0.6},{"lead white",1.2},medium=0.55}
local LEAK2 = pile{{"Mars orange",1},{"rose madder",0.3},{"lead white",0.5},medium=0.65}
local brk = mask(function(x, y)
  local a = math.atan(y - RC[2], x - RC[1])
  return clamp(1 - math.abs(a - 0.7) / 0.65, 0, 1)
end)
local near = (rellipse(300, 335):soften(25) - AP:shrink(4)) * brk
local far  = (rellipse(380, 420):soften(50) - AP:shrink(4)) * brk
local clip = -(FRAG:grow(1) + FIGALL + RING + ORING)
work(far * clip, {hand="glaze", tool="filbert 12", pile=LEAK2, coverage=1.0, fill=false, angle=vortex, clip=clip, seed=7701})
work(near * clip, {hand="glaze", tool="filbert 10", pile=LEAK1, coverage=1.4, fill=true, angle=vortex, clip=clip, seed=7702})
blend((far:grow(10)) * clip, {angle=vortex, tool={kind="badger", width=20}, seed=7703})

--@ chunk 78
local clip = -(FRAG:grow(1) + FIGALL + RING + ORING); local reg = ellipse(760,760,260,260):soften(60) * clip; blend(reg, {angle=vortex, tool={kind="badger", width=30}, seed=781}); blend(reg, {angle=function(x,y) return vortex(x,y)+0.8 end, tool={kind="badger", width=30}, seed=782}); blend(reg, {angle=vortex, tool={kind="badger", width=24}, seed=783})

--@ chunk 79
for _,p in ipairs({{300,300},{250,600},{820,450},{230,450},{400,250}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 80
local function rp(t, f, dx, dy) local p = rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)); return {p[1] + (dx or 0), p[2] + (dy or 0)} end
SPEC = pile{{"lead white",3},{"yellow ochre",0.5},{"viridian",0.2}}
SPECW = pile{{"lead white",3},{"lemon chrome",0.3}}
local rig = brush{kind="rigger", width=3.2, point=0.8}
local function light(t) return math.max(0, math.cos(t - 3.93)) end
local function bevel(t0, t1, f, strength, pl)
  local pts = {}
  local n = math.max(3, math.floor((t1 - t0) * 30))
  for j = 0, n do pts[#pts + 1] = rp(lerp(t0, t1, j / n), f) end
  rig:reload(pl, 0.75)
  rig:stroke(pts, {pressure={0.15, 0.15}, swell={0.4, 1.0 * strength + 0.3, 1.1 * strength + 0.3, 0.3}, ramps={0.3, 0.3}})
end
-- outer course: the outer bevel and the inner bevel catch the cold light
for i, p in ipairs(OPLATES) do
  local mid = (p[1] + p[2]) / 2
  local s = light(mid)
  if s > 0.15 then
    local a = lerp(p[1], p[2], rand(0.05, 0.3)); local b = lerp(p[1], p[2], rand(0.6, 0.95))
    bevel(a, b, 2.03, s, s > 0.7 and SPECW or SPEC)
    if s > 0.3 then bevel(lerp(p[1], p[2], rand(0.1, 0.3)), lerp(p[1], p[2], rand(0.6, 0.9)), 1.72 + rand(-0.06, 0.06), s, s > 0.7 and SPECW or SPEC) end
  end
end
-- inner course: a bevel at its outer edge
for i, p in ipairs(PLATES) do
  local mid = (p[1] + p[2]) / 2
  local s = light(mid)
  if s > 0.2 then
    bevel(lerp(p[1], p[2], rand(0.1, 0.3)), lerp(p[1], p[2], rand(0.55, 0.9)), 0.66 + rand(-0.05, 0.05), s * 0.9, s > 0.7 and SPECW or SPEC)
  end
end
-- a few hard sparks where the bevels turn most squarely to the light
local dot = brush{kind="round", width=3, point=0.5}
for k = 1, 14 do
  local t = 3.93 + randn(0, 0.35)
  local f = ({2.03, 1.72, 0.66})[math.random(3)]
  local p = rp(t, f)
  dot:reload(SPECW, 0.9)
  dot:touch(p[1], p[2], {pressure=rand(0.4, 0.7)})
end

--@ chunk 81
-- a line of inscription in bone, cut along the outer course: a script no one alive can read
BONE = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.5},{"bone brown",0.25}}
local function rp(t, f) return rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)) end
local pen = brush{kind="round", width=1.6, point=0.9}
local function glyph(t, f, h, kind)
  -- local frame: u along the ring, v across it (outward)
  local p0 = rp(t, f)
  local pu = rp(t + 0.002, f)
  local ux, uy = pu[1] - p0[1], pu[2] - p0[2]
  local ul = math.sqrt(ux * ux + uy * uy); ux, uy = ux / ul, uy / ul
  local vx, vy = -uy, ux
  local function P(a, b) return {p0[1] + ux * a + vx * b, p0[2] + uy * a + vy * b} end
  if kind == 1 then pen:stroke({P(0, -h / 2), P(0.3, h / 2)}, {pressure={0.5, 0.4}})
  elseif kind == 2 then pen:stroke({P(-1.5, -h / 2), P(0, -h / 2 + 1), P(1.5, -h / 2)}, {pressure={0.45, 0.4}}); pen:stroke({P(0, -h / 2 + 1), P(0, h / 2)}, {pressure={0.5, 0.35}})
  elseif kind == 3 then pen:touch(P(0, 0)[1], P(0, 0)[2], {pressure=0.55})
  elseif kind == 4 then pen:stroke({P(-1.6, h / 2), P(0, -h / 2), P(1.6, h / 2)}, {pressure={0.4, 0.45}})
  else pen:stroke({P(-1.4, -h / 3), P(1.4, -h / 3)}, {pressure={0.4, 0.4}}); pen:stroke({P(-1.4, h / 3), P(1.4, h / 3)}, {pressure={0.4, 0.4}}) end
end
local function line_of_text(t0, t1, f, h)
  local t = t0
  local perword = 0
  local n = 0
  while t < t1 do
    if n % 6 == 0 then pen:reload(BONE, 0.7) end
    glyph(t, f, h, math.random(5))
    n = n + 1
    perword = perword + 1
    local step = 4.2 / (RO[1] * 1.5)
    if perword >= math.random(3, 7) then perword = 0; step = step * 2.6 end
    t = t + step
  end
end
-- skip the joints between plates so the text sits on the plates as cut
for i, p in ipairs(OPLATES) do
  local mid = (p[1] + p[2]) / 2 % (2 * math.pi)
  if mid > 1.6 and mid < 3.6 then
    line_of_text(p[1] + 0.025, p[2] - 0.025, 1.42, 5)
  end
end

--@ chunk 82
VERD2 = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
VERDD = pile{{"viridian",1.2},{"cerulean blue",0.5},{"lead white",0.8},{"raw sienna",0.4}}
local function rp(t, f) return rpt(t, lerp(RI[1], RO[1], f), lerp(RI[2], RO[2], f)) end
local ringall = (RING + ORING) * -FIGALL:grow(1)
local spots = 0
for i, p in ipairs(OPLATES) do
  if math.random() < 0.7 then
    local t = p[1] + rand(0.0, 0.05)
    local f = ({1.12, 1.95, 2.0, 1.15})[math.random(4)]
    local c = rp(t, f)
    local m = ellipse(c[1], c[2], rand(5, 13), rand(4, 9)):roughen(3, 8, 820 + i) * ringall
    stipple(m, {pile=(math.random() < 0.5) and VERD2 or VERDD, width=2.4, coverage=1.3, cluster=0.6, feather=0.6, clip=ringall, seed=8200 + i})
    spots = spots + 1
  end
end
for i, p in ipairs(PLATES) do
  if math.random() < 0.5 then
    local t = p[2] - rand(0.0, 0.04)
    local c = rp(t, rand(0.75, 0.95))
    local m = ellipse(c[1], c[2], rand(4, 9), rand(3, 7)):roughen(3, 8, 860 + i) * ringall
    stipple(m, {pile=VERDD, width=2.2, coverage=1.2, cluster=0.6, feather=0.6, clip=ringall, seed=8300 + i})
    spots = spots + 1
  end
end
print(spots)

--@ chunk 83
-- the light wraps his edges; the cold of the space touches his front; one cold point where his eyes are
local r = brush{kind="round", width=2.2, point=0.8}
local W = pile{{"lead white",6},{"lemon chrome",0.4}}
-- halation: light pressed against the silhouette from outside, along shoulders, hood and the staff
local edgeL = {{511.0,750.5},{510.4,754.5},{507.0,758.5},{504.8,762.5},{504.3,768}}
local edgeR = {{521.2,750.5},{521.6,754.5},{525.4,758.5},{527.8,762.5},{528.2,768}}
r:reload(W, 0.8)
r:stroke(edgeL, {pressure={0.35, 0.15}, ramps={0.1, 0.6}})
r:reload(W, 0.8)
r:stroke(edgeR, {pressure={0.35, 0.15}, ramps={0.1, 0.6}})
r:reload(W, 0.7)
r:stroke({{513.0,746.6},{516,745.2},{519.3,746.6}}, {pressure={0.3, 0.3}})
-- cold front light: a few faint strokes down the robe
local c = brush{kind="round", width=1.6, point=0.7}
for k = 1, 4 do
  c:reload(TEALM, 0.35)
  local x = 509 + k * 3.2 + rand(-0.5, 0.5)
  c:stroke({{x, 766 + rand(-2, 2)}, {x + rand(-0.6, 0.6), 800 + rand(-3, 2)}}, {pressure={0.25, 0.1}, ramps={0.2, 0.6}})
end
-- the optic
local o = brush{kind="round", width=1.4, point=0.6}
o:load(pile{{"zinc white",2},{"cerulean blue",1},{"emerald green",0.4}}, 0.9)
o:touch(515.6, 753.2, {pressure=0.45})

--@ chunk 84
blend(FIG2:shrink(1.2) * rect(500,762,30,45), {angle=0.0, tool={kind="badger", width=5}, seed=84}); blend(FIG2:shrink(1.2) * rect(500,762,30,45), {angle=1.2, tool={kind="badger", width=5}, seed=85})

--@ chunk 85
-- small shards trailing the broken arc out of the picture: smaller, thinner, turning edge-on
local rig = brush{kind="rigger", width=1.8, point=0.85}
local function shard(cx, cy, w, h, rot, seed)
  local c, s = math.cos(rot), math.sin(rot)
  local sk = rand(-0.25, 0.25) * w
  local raw = {{-w / 2 + sk, -h / 2}, {w / 2 + sk, -h / 2}, {w / 2, h / 2}, {-w / 2, h / 2}}
  local pts = {}
  for i, p in ipairs(raw) do pts[i] = {cx + p[1] * c - p[2] * s, cy + p[1] * s + p[2] * c} end
  local m = poly(pts)
  work(m, {hand="detail", tool={kind="round", width=2}, pile=BRZ_D, coverage=4, fill=true, angle=rot, clip=true, seed=seed})
  -- lit edge toward the upper left, and a pink one toward the lower right
  local best, bi = -9, 1
  for i = 1, 4 do
    local a, b = pts[i], pts[i % 4 + 1]
    local mx, my = (a[1] + b[1]) / 2 - cx, (a[2] + b[2]) / 2 - cy
    local d = (-0.72 * mx - 0.69 * my) / (math.sqrt(mx * mx + my * my) + 1e-6)
    if d > best then best, bi = d, i end
  end
  rig:reload(SPEC, 0.8)
  rig:stroke({pts[bi], pts[bi % 4 + 1]}, {pressure={0.5, 0.45}})
  local oi = (bi + 1) % 4 + 1
  rig:reload(PMAG, 0.6)
  rig:stroke({pts[oi], pts[oi % 4 + 1]}, {pressure={0.35, 0.3}})
end
-- along a widening spiral beyond the last fragments
local n = 0
for k = 1, 16 do
  local t = 0.15 + k * 0.07 + rand(-0.03, 0.03)
  local r = 470 + k * 14 + rand(-25, 25)
  local x, y = RC[1] + r * 1.05 * math.cos(t), RC[2] + r * 1.12 * math.sin(t)
  if x < 990 and y < H - 10 and x > 600 then
    local sz = rand(7, 18) * (1 - k / 30)
    local thin = (math.random() < 0.35)
    shard(x, y, sz, thin and rand(1.8, 3) or sz * rand(0.4, 0.9), rand(0, math.pi), 8500 + k)
    n = n + 1
  end
end
print(n)

--@ chunk 86
-- a cube coming undone: a face with its four flaps opening at different angles, one drifting loose
function unfolding_cube(cx, cy, s, rot, opens, seed, lightp, darkp)
  local c, sn = math.cos(rot), math.sin(rot)
  local skew = 0.25
  local function P(u, v) return {cx + (u + skew * v) * s * c - v * s * 0.85 * sn, cy + (u + skew * v) * s * sn + v * s * 0.85 * c} end
  local face = {P(-0.5, -0.5), P(0.5, -0.5), P(0.5, 0.5), P(-0.5, 0.5)}
  local rig = brush{kind="rigger", width=1.8, point=0.85}
  local function fill(pts, p, sd)
    local m = poly(pts)
    work(m, {hand="detail", tool={kind="round", width=2.2}, pile=p, coverage=4, fill=true, angle=rot, clip=true, seed=sd})
  end
  fill(face, darkp, seed)
  for i = 1, 4 do
    local a, b = face[i], face[i % 4 + 1]
    local mx, my = (a[1] + b[1]) / 2 - cx, (a[2] + b[2]) / 2 - cy
    local l = math.sqrt(mx * mx + my * my)
    local ox, oy = mx / l, my / l
    local open = opens[i]          -- 0 = still folded (unseen), 1 = flat out
    local len = s * 0.95 * open
    local twist = rand(-0.25, 0.25)
    local gap = (i == 4) and s * 0.35 or 0   -- the loose one has drifted off its hinge
    local a1 = {a[1] + ox * gap, a[2] + oy * gap}
    local b1 = {b[1] + ox * gap, b[2] + oy * gap}
    local a2 = {a1[1] + (ox * math.cos(twist) - oy * math.sin(twist)) * len, a1[2] + (ox * math.sin(twist) + oy * math.cos(twist)) * len}
    local b2 = {b1[1] + (ox * math.cos(twist) - oy * math.sin(twist)) * len * rand(0.8, 1.15), b1[2] + (ox * math.sin(twist) + oy * math.cos(twist)) * len * rand(0.8, 1.15)}
    if open > 0.05 then
      fill({a1, b1, b2, a2}, (i % 2 == 0) and lightp or darkp, seed + i)
      rig:reload(SPEC, 0.7); rig:stroke({a1, b1}, {pressure={0.4, 0.35}})
      rig:reload(ICE, 0.6); rig:stroke({a2, b2}, {pressure={0.3, 0.25}})
    end
  end
  local rr = brush{kind="rigger", width=1.6, point=0.85}
  rr:reload(ICE, 0.7)
  rr:stroke({face[1], face[2]}, {pressure={0.35, 0.3}})
end
local LP = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.2},{"bone black",0.15}}
local DP = pile{{"bone black",1.2},{"ultramarine blue",1},{"viridian",0.5}}
unfolding_cube(95, 640, 46, 0.5, {0.9, 0.4, 0.7, 0.85}, 8601, LP, DP)
unfolding_cube(300, 150, 22, -0.4, {0.6, 0.95, 0.3, 0.8}, 8611, pile{{"cobalt violet",1},{"lead white",1},{"cerulean blue",0.3}}, DP)
unfolding_cube(150, 900, 15, 1.1, {0.8, 0.7, 0.9, 0.5}, 8621, LP, DP)

--@ chunk 87
for i,c in ipairs({{95,640,70},{300,150,35},{150,900,25}}) do local a = vortex(c[1],c[2]); local ox, oy = c[1]+math.cos(a)*c[3]*0.5, c[2]+math.sin(a)*c[3]*0.5; local m = ellipse(ox, oy, c[3]*1.1, c[3]*1.1):soften(c[3]*0.4); blend(m, {angle=vortex, tool={kind="badger", width=math.max(8,c[3]*0.4)}, seed=870+i}); blend(m, {angle=vortex, tool={kind="badger", width=math.max(8,c[3]*0.4)}, seed=880+i}) end

--@ chunk 88
local ex = -(rellipse(364,399)); local m = ellipse(110,650,130,140):soften(50) * ex; blend(m, {angle=vortex, tool={kind="badger", width=30}, seed=891}); blend(m, {angle=function(x,y) return vortex(x,y)+0.6 end, tool={kind="badger", width=30}, seed=892})

--@ chunk 89
-- where the lattice is still whole, in the far corner: straight crossings, cut off where the swirl takes them
local rig = brush{kind="rigger", width=1.5, point=0.9}
local u = -0.62
for i, off in ipairs(uneven(7, 0, 230, 0.15, 0.1, 89)) do
  -- start points along a line running down-right from the top edge
  local x0, y0 = 790 + off * 0.85, -5 + off * 0.75
  local len = rand(90, 170) * (1 - i / 12)
  local x1, y1 = x0 + len * math.cos(u), y0 + len * math.sin(u)
  rig:reload((i % 3 == 0) and LATV or LATW, 0.6)
  rig:stroke({{x1, y1}, {lerp(x1, x0, 0.5), lerp(y1, y0, 0.5)}, {x0, y0}}, {pressure={0.0, 0.4}, ramps={0.5, 0.05}, clip=BEHIND})
end

--@ chunk 90
print(wait(3*24*60)); for _,p in ipairs({{750,200},{100,200},{100,650},{900,1250},{820,700}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 91
-- knock back: the curled lattice recedes, the cold clouds yield the light to the gate
local GVI = pile{{"ultramarine blue",1},{"magenta",0.35},{"bone black",0.2},medium=0.72}
local GTE = pile{{"ultramarine blue",1},{"viridian",0.5},{"magenta",0.15},medium=0.72}
local keep = -(rellipse(366, 401) + FRAG:grow(3) + SHAFT:grow(2))
local curl = ellipse(700, 200, 170, 140):soften(60) * keep
work(curl, {hand="glaze", pile=GVI, coverage=1.2, fill=true, angle=vortex, clip=keep, seed=9101})
blend(curl:grow(20) * keep, {angle=vortex, tool={kind="badger", width=30}, seed=9102})
-- upper-left cloud: veil its loudest whites, more at its edges than its heart
local ul = ellipse(130, 330, 200, 260):soften(80) * keep
work(ul, {hand="glaze", pile=GTE, coverage=0.9, fill=true, angle=vortex, clip=keep, seed=9103})
blend(ul:grow(20) * keep, {angle=vortex, tool={kind="badger", width=30}, seed=9104})

--@ chunk 92
local function hw(y) return 17 + (y - 815) * 0.018 end; local r = brush{kind="rigger", width=1.8, point=0.85}; for i=1,7 do local d=DRUMS[i].pts; local y0,y1=d[1][2]+1.5,d[3][2]-1.5; r:reload(PCY,0.6); r:stroke({{PX-hw(y0)+1.3,y0},{PX-hw(y1)+1.3,y1}},{pressure={0.4,0.3},ramps={0.1,0.3}}); local warm = y0 < 880; r:reload(warm and GLOW3 or PMAG,0.55); r:stroke({{PX+hw(y0)-1.2,y0},{PX+hw(y1)-1.2,y1}},{pressure={warm and 0.4 or 0.25, warm and 0.35 or 0.2},ramps={0.1,0.3}}) end
