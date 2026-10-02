-- easel session "area_core": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.6, linen={16,15}, seed=11,
  ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=80, apply="knife", texture=0.3},
          {pile={{"bone brown",3},{"burnt sienna",1},{"lead white",1},{"ultramarine blue",1}}, um=40, apply="brush"}}}
CX, CY = 565, 300
local nz = noise{seed=5, octaves=3, period=1.3}
function brR(t)
  -- irregular radius of the breach at angle t (ellipse rx 215, ry 170)
  local k = 1 + 0.16 * nz(math.cos(t)*1.0, math.sin(t)*1.0) + 0.05*math.sin(5*t+1)
  return k
end
BPTS = {}
for i = 0, 71 do
  local t = i / 72 * 2 * math.pi
  local k = brR(t)
  BPTS[#BPTS+1] = {CX + 215*k*math.cos(t), CY + 170*k*math.sin(t)}
end
BREACH = poly(BPTS, true)
-- elliptical normalized distance from centre (1 = nominal rim)
function ed(x, y) return math.sqrt(((x-CX)/215)^2 + ((y-CY)/170)^2) end
print(BREACH:area())

--@ chunk 2
D_OUT = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
D_MID = pile{{"burnt sienna",2},{"ultramarine blue",1},{"bone black",0.5}}
D_IN  = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
local outside = -BREACH
local function zone(lo, hi)
  return mask(function(x, y) local e = ed(x, y); return (e >= lo and e < hi) and 1 or 0 end):soften(6) * outside
end
local tang = function(x, y) return math.atan(y-CY, x-CX) + math.pi/2 end
work(zone(1.85, 99), {hand="broad", pile=D_OUT, coverage=2.4, fill=true, angle=tang, clip=outside})
work(zone(1.3, 1.85), {hand="broad", pile=D_MID, coverage=2.4, fill=true, angle=tang, clip=outside})
work(zone(0, 1.3), {hand="body", pile=D_IN, coverage=2.4, fill=true, angle=tang, clip=outside})

--@ chunk 3
B_RIM = pile{{"zinc white",4},{"cobalt violet",1.2},{"magenta",0.25}}
B_MID = pile{{"zinc white",4},{"cerulean blue",1},{"cobalt violet",0.6}}
B_CEN = pile{{"zinc white",6},{"emerald green",0.25},{"cerulean blue",0.35}}
local function zone(lo, hi)
  return mask(function(x, y) local e = ed(x, y); return (e >= lo and e < hi) and 1 or 0 end):soften(5) * BREACH
end
local swirl = function(x, y) return math.atan(y-CY, x-CX) + math.pi/2 + 0.35 end
work(zone(0.72, 99), {hand="body", pile=B_RIM, coverage=3, fill=true, angle=swirl, clip=BREACH})
work(zone(0.36, 0.72), {hand="body", pile=B_MID, coverage=3, fill=true, angle=swirl, clip=BREACH})
work(zone(0, 0.36), {hand="body", pile=B_CEN, coverage=3, fill=true, angle=swirl, clip=BREACH})
blend(BREACH:shrink(3), {angle=swirl})

--@ chunk 4
print(wait(3*24*60)); print(drying(565,300), drying(565,140), drying(300,300), drying(50,50))

--@ chunk 5
wait(2*24*60)
-- bronze piles, dark to lit
BZ = {
  pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}},
  pile{{"burnt sienna",2},{"ultramarine blue",1},{"bone black",0.5}},
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
  pile{{"raw sienna",2},{"bone black",0.6},{"burnt sienna",1},{"yellow ochre",1}},
  pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}},
}
LIPS = {
  pile{{"zinc white",4},{"cerulean blue",1},{"cobalt violet",0.3}},
  pile{{"zinc white",2},{"cerulean blue",1},{"raw sienna",0.5},{"cobalt violet",0.3}},
  pile{{"cerulean blue",1},{"ultramarine ash",1},{"burnt sienna",1},{"lead white",0.6}},
}
PB = brush("filbert", 8)
PL = brush{kind="round", width=2.2, point=0.7}
-- one scale plate: centre (px,py), pointing inward along (ux,uy), length L, width W
-- tone 1..5 picks body piles; lit 0..1 strength of the cold lip
function plate(px, py, ux, uy, L, W, tone, lit)
  local vx, vy = -uy, ux
  local tipx, tipy = px + ux*L*0.5, py + uy*L*0.5
  local bx, by = px - ux*L*0.5, py - uy*L*0.5
  local pts = {}
  -- base edge, straight-ish
  pts[#pts+1] = {bx - vx*W*0.42, by - vy*W*0.42}
  pts[#pts+1] = {bx + vx*W*0.42, by + vy*W*0.42}
  -- rounded tip, 9 points on a half ellipse
  for k = 0, 8 do
    local a = -math.pi/2 + k/8*math.pi
    local ca, sa = math.cos(a), math.sin(a)
    local cxx, cyy = px + ux*L*0.05, py + uy*L*0.05
    pts[#pts+1] = {cxx + vx*W*0.5*(-sa) + ux*L*0.45*ca, cyy + vy*W*0.5*(-sa) + uy*L*0.45*ca}
  end
  local m = poly(pts, true)
  local dark = BZ[math.max(1, tone-1)]
  PB:reload(dark, 0.9)
  local wv = PB:mark_width(0.7)
  -- body: strokes along the axis, base to tip
  local n = math.max(2, math.floor(W / (wv*0.75)))
  for j = 0, n do
    local s = (j / n - 0.5) * W * 0.85
    PB:stroke({{bx + vx*s - ux*3, by + vy*s - uy*3}, {tipx + vx*s*0.6, tipy + vy*s*0.6}},
      {pressure={0.8, 0.6}, clip=m})
    if j % 2 == 1 then PB:reload(dark, 0.9) end
  end
  -- lighter tip half, wet into wet
  PB:reload(BZ[tone], 0.7)
  for j = -1, 1 do
    local s = j * W * 0.22
    PB:stroke({{px + vx*s, py + vy*s}, {tipx + vx*s*0.5, tipy + vy*s*0.5}}, {pressure={0.4, 0.75}, clip=m})
  end
  -- cold lip along the rounded tip
  if lit > 0.05 then
    local lp = LIPS[lit > 0.66 and 1 or (lit > 0.33 and 2 or 3)]
    PL:reload(lp, 0.7)
    local arc = {}
    for k = 1, 7 do
      local a = -math.pi/2 + k/8*math.pi
      local ca, sa = math.cos(a), math.sin(a)
      local cxx, cyy = px + ux*L*0.05, py + uy*L*0.05
      arc[#arc+1] = {cxx + vx*W*0.46*(-sa) + ux*L*0.41*ca, cyy + vy*W*0.46*(-sa) + uy*L*0.41*ca}
    end
    PL:stroke(arc, {pressure={0.25, 0.25}, swell={0.6, 1.3, 0.6}, clip=m})
  end
  return m
end
-- golden-angle log spiral layout, painted from inner (far) to outer (near)
GA = math.pi * (3 - math.sqrt(5))
KS = 0.0118
function slot(i)
  local e = 0.93 * math.exp(i * KS)
  local t = i * GA
  local k = brR(t)
  local x = CX + 215 * e * k * math.cos(t)
  local y = CY + 170 * e * k * math.sin(t)
  return x, y, e, t
end
for i = 0, 24 do
  local x, y, e, t = slot(i)
  local ux, uy = -math.cos(t), -math.sin(t) * 0.8
  local l = math.sqrt(ux*ux+uy*uy); ux, uy = ux/l, uy/l
  local L = 62 * e
  local W = 48 * e
  plate(x, y, ux, uy, L, W, 4 + (i % 3 == 0 and 1 or 0), 0.9)
end

--@ chunk 6
PB2 = brush("filbert", 12)
PL2 = brush{kind="round", width=3.2, point=0.5}
function tipArc(px, py, ux, uy, L, W, f, k0, k1)
  local vx, vy = -uy, ux
  local arc = {}
  local cxx, cyy = px - ux*L*0.1, py - uy*L*0.1
  for k = k0, k1 do
    local a = -math.pi/2 + k/10*math.pi
    local ca, sa = math.cos(a), math.sin(a)
    arc[#arc+1] = {cxx + vx*W*0.5*f*(-sa) + ux*L*0.6*f*ca, cyy + vy*W*0.5*f*(-sa) + uy*L*0.6*f*ca}
  end
  return arc
end
-- a fish-scale plate: straight base behind, rounded tip toward the breach
function plate2(px, py, ux, uy, L, W, tone, lit, seed)
  local vx, vy = -uy, ux
  local bx, by = px - ux*L*0.5, py - uy*L*0.5
  local pts = {{bx - vx*W*0.5, by - vy*W*0.5}, {bx + vx*W*0.5, by + vy*W*0.5}}
  for _, p in ipairs(tipArc(px, py, ux, uy, L, W, 1, 0, 10)) do pts[#pts+1] = p end
  local m = poly(pts, true)
  -- shadowed body
  local dark = BZ[math.max(1, tone-2)]
  PB2:reload(dark, 0.95)
  local n = math.max(2, math.floor(W / 7))
  for j = 0, n do
    local s = (j / n - 0.5) * W * 0.95
    PB2:stroke({{bx + vx*s - ux*4, by + vy*s - uy*4}, {px + ux*L*0.45 + vx*s*0.8, py + uy*L*0.45 + vy*s*0.8}},
      {pressure={0.85, 0.7}, clip=m})
    if j % 2 == 1 then PB2:reload(dark, 0.9) end
  end
  -- the convex lit band following the tip, two arcs of lighter bronze wet into wet
  PB2:reload(BZ[math.max(1, tone-1)], 0.8)
  PB2:stroke(tipArc(px, py, ux, uy, L, W, 0.72, 1, 9), {pressure={0.55, 0.55}, clip=m})
  PB2:reload(BZ[tone], 0.75)
  PB2:stroke(tipArc(px, py, ux, uy, L, W, 0.86, 2, 8), {pressure={0.4, 0.4}, swell={0.7, 1.2, 0.7}, clip=m})
  -- cold lip on the rounded edge
  if lit > 0.05 then
    local lp = LIPS[lit > 0.66 and 1 or (lit > 0.33 and 2 or 3)]
    PL2:reload(lp, 0.8)
    PL2:stroke(tipArc(px, py, ux, uy, L, W, 0.95, 2, 8), {pressure={0.35, 0.35}, swell={0.5, 1.4, 0.5}, clip=m})
  end
  return m
end
local drawn = 0
for i = 0, 112 do
  local x, y, e, t = slot(i)
  if x > -60 and x < 1060 and y > -60 and y < 685 then
    local ux, uy = -math.cos(t), -math.sin(t) * 0.8
    local l = math.sqrt(ux*ux+uy*uy); ux, uy = ux/l, uy/l
    local j = 1 + 0.12 * math.sin(i * 2.7)
    local L, W = 64 * e * j, 74 * e * (2 - j)
    local tone = clamp(math.floor(5.6 - (e - 0.9) * 2.2 + 0.5 * math.sin(i * 1.3)), 2, 5)
    local lit = clamp(1.5 - (e - 0.9) * 0.9, 0, 1)
    plate2(x, y, ux, uy, L, W, tone, lit)
    drawn = drawn + 1
  end
end
print(drawn)

--@ chunk 7
wait(2*24*60)
INK = pile{{"ultramarine blue",1},{"magenta",1},{"bone black",0.5}}
INK2 = pile{{"cobalt violet",2},{"ultramarine blue",1},{"zinc white",1.5}}
RIG = brush{kind="rigger", width=2.4, point=0.9}
-- an arched doorway outline (rotated), as point list
function archPts(cx, cy, w, h, rot)
  local c, s = math.cos(rot), math.sin(rot)
  local function P(x, y) return {cx + x*c - y*s, cy + x*s + y*c} end
  local pts = {P(-w/2, h/2)}
  local sh = h - w/2
  pts[#pts+1] = P(-w/2, h/2 - sh)
  for k = 1, 9 do
    local a = math.pi + k/10*math.pi
    pts[#pts+1] = P(w/2*math.cos(a), h/2 - sh + w/2*math.sin(a))
  end
  pts[#pts+1] = P(w/2, h/2 - sh)
  pts[#pts+1] = P(w/2, h/2)
  return pts
end
-- breathing contour bands inside the breach
for r = 1, 4 do
  local e0 = 0.9 - r * 0.17
  local pts = {}
  for k = 0, 60 do
    local t = k / 60 * 2 * math.pi
    local e = e0 * (1 + 0.06 * math.sin(7*t + r*1.7) + 0.04*math.sin(3*t - r))
    local kk = brR(t)
    pts[#pts+1] = {CX + 215*e*kk*math.cos(t), CY + 170*e*kk*math.sin(t)}
  end
  RIG:reload(INK2, 0.5)
  for q = 1, 60, 6 do
    local seg = {}
    for z = q, math.min(q + 6, 61) do seg[#seg+1] = pts[z] end
    if (q + r) % 4 ~= 0 then
      RIG:stroke(seg, {pressure={0.2, 0.3}, swell={0.5, 1.2, 0.5}, clip=BREACH})
    end
    if q % 18 == 1 then RIG:reload(INK2, 0.5) end
  end
end
-- the room that connects to itself: arches nested, each turned and shifted, spiralling to the centre
local w, h, rot = 150, 190, -0.08
local ax, ay = CX - 20, CY + 25
for lev = 1, 7 do
  RIG:reload(INK, 0.75)
  local pts = archPts(ax, ay, w, h, rot)
  RIG:stroke(pts, {pressure={0.45, 0.45}, clip=BREACH})
  RIG:reload(INK, 0.6)
  RIG:stroke(archPts(ax, ay + h*0.03, w*0.86, h*0.9, rot), {pressure={0.25, 0.3}, clip=BREACH})
  -- the threshold line runs out of this arch and into the next
  w, h, rot = w * 0.66, h * 0.66, rot + 0.42
  ax = ax + 14 * math.cos(lev*1.1); ay = ay - 18 + 6*math.sin(lev*0.9)
end

--@ chunk 8
local m = rect(445,215,240,240) * BREACH:shrink(4)
for k=1,4 do work(m, {hand="scumble", blender=true, coverage=2, clip=true}) end
print(drying(560,330), drying(510,280))

--@ chunk 9
INKC = {
  pile{{"ultramarine blue",2},{"cobalt violet",1},{"bone black",0.6},{"zinc white",0.4}},
  pile{{"ultramarine blue",2},{"cobalt violet",1},{"bone black",0.3},{"zinc white",1.5}},
  pile{{"ultramarine blue",1},{"cobalt violet",1},{"zinc white",3}},
}
local VP = {CX + 8, CY - 8}
local C0 = {CX - 6, CY + 30}
local w0, h0 = 175, 220
local feet = {}
for lev = 0, 6 do
  local s = 0.6 ^ lev
  local cx, cy = VP[1] + (C0[1]-VP[1])*s, VP[2] + (C0[2]-VP[2])*s
  local rot = lev * 0.2
  local w, h = w0 * s, h0 * s
  local pts = archPts(cx, cy, w, h, rot)
  local pi = INKC[math.min(3, 1 + lev // 2)]
  local th = math.max(1.5, 13 * s)
  if th > 3 then
    local m = ribbon(pts, th) * BREACH
    work(m, {hand="detail", pile=pi, coverage=3, fill=true, clip=true})
  else
    RIG:reload(pi, 0.7)
    RIG:stroke(pts, {pressure={0.4, 0.4}, clip=BREACH})
  end
  feet[#feet+1] = {pts[1], pts[#pts], pts[6]}
end
-- corridor edges: the floor and the crown run from each arch into the next one
for i = 1, #feet - 1 do
  local a, b = feet[i], feet[i+1]
  local pi = INKC[math.min(3, 1 + i // 2)]
  RIG:reload(pi, 0.6)
  for k = 1, 3 do
    RIG:stroke({a[k], b[k]}, {pressure={0.35, 0.2}, clip=BREACH})
  end
end

--@ chunk 10
wait(24*60)
ARCH = {}
do
  local VP = {CX + 8, CY - 8}
  local C0 = {CX - 6, CY + 30}
  for lev = 0, 6 do
    local s = 0.6 ^ lev
    ARCH[#ARCH+1] = {cx = VP[1] + (C0[1]-VP[1])*s, cy = VP[2] + (C0[2]-VP[2])*s, w = 175*s, h = 220*s, rot = lev*0.2, s = s}
  end
end
function archMask(a, f)
  f = f or 1
  return poly(archPts(a.cx, a.cy, a.w*f, a.h*f, a.rot), false)
end
TW = {
  pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.6},{"ultramarine blue",0.3}},
  pile{{"zinc white",3},{"ultramarine ash",1},{"cobalt violet",0.5}},
  pile{{"zinc white",4},{"cerulean blue",0.5},{"cobalt violet",0.4}},
}
local swirl = function(x, y) return math.atan(y-ARCH[1].cy, x-ARCH[1].cx) end
for i = 1, 4 do
  local m = (archMask(ARCH[i], 0.93) - archMask(ARCH[i+1], 1.08)) * BREACH
  work(m, {hand="body", tool="filbert 5", pile=TW[math.min(3, i)], coverage=2.5, fill=true, clip=true, angle=swirl})
end

--@ chunk 11
wait(24*60)
function plateGeom(i)
  local x, y, e, t = slot(i)
  local ux, uy = -math.cos(t), -math.sin(t) * 0.8
  local l = math.sqrt(ux*ux+uy*uy); ux, uy = ux/l, uy/l
  local j = 1 + 0.12 * math.sin(i * 2.7)
  return x, y, ux, uy, 64 * e * j, 74 * e * (2 - j), e, t
end
function plateMask(px, py, ux, uy, L, W)
  local vx, vy = -uy, ux
  local bx, by = px - ux*L*0.5, py - uy*L*0.5
  local pts = {{bx - vx*W*0.5, by - vy*W*0.5}, {bx + vx*W*0.5, by + vy*W*0.5}}
  for _, p in ipairs(tipArc(px, py, ux, uy, L, W, 1, 0, 10)) do pts[#pts+1] = p end
  return poly(pts, true)
end
-- half-plane on the inner side of a cut line through (x0,y0) with direction angle a
function halfp(x0, y0, a, side)
  local nx, ny = -math.sin(a), math.cos(a)
  return mask(function(x, y) return ((x-x0)*nx + (y-y0)*ny) * side > 0 and 1 or 0 end)
end
IBODY = {
  pile{{"zinc white",3},{"cobalt violet",1},{"cerulean blue",0.4}},
  pile{{"zinc white",3},{"cerulean blue",1},{"cobalt violet",0.3}},
}
ITIP = pile{{"cobalt violet",1.5},{"ultramarine blue",1},{"zinc white",1}}
INKD = pile{{"ultramarine blue",2},{"cobalt violet",1},{"bone black",0.8}}
-- an inverted plate (or part of one): pale body, dark violet tip band and lip
function invPlate(px, py, ux, uy, L, W, clipm, tone)
  local m = plateMask(px, py, ux, uy, L, W)
  if clipm then m = m * clipm end
  if m:area() < 20 then return end
  work(m, {hand="body", tool="filbert 6", pile=IBODY[tone or 1], coverage=2.5, fill=true, clip=true,
           angle=math.atan(uy, ux)})
  PB2:reload(ITIP, 0.7)
  PB2:stroke(tipArc(px, py, ux, uy, L, W, 0.82, 2, 8), {pressure={0.45, 0.45}, clip=m})
  PL2:reload(INKD, 0.8)
  PL2:stroke(tipArc(px, py, ux, uy, L, W, 0.96, 1, 9), {pressure={0.4, 0.4}, swell={0.6, 1.3, 0.6}, clip=m})
end
-- the infected sector: right and lower right of the breach
local n = 0
for i = 0, 70 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  if ta > -0.55 and ta < 1.1 and e < 1.75 then
    local sev = clamp((1.75 - e) / 0.75, 0, 1) * clamp(1 - math.abs(ta - 0.3) / 0.85, 0, 1)
    if sev > 0.15 then
      -- cut across the plate: the part nearer the breach turns inside out
      local a = math.atan(uy, ux) + math.pi/2 + rand(-0.5, 0.5)
      local off = (0.5 - sev) * L * 0.8
      local hp = halfp(x + ux*off, y + uy*off, a, (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1)
      invPlate(x, y, ux, uy, L, W, hp, 1 + (i % 2))
      -- displaced echoes drifting into the hole, smaller each time
      if sev > 0.45 then
        local d = L * 0.55
        for k = 1, 2 do
          local sx, sy = x + ux*d*k + rand(-6, 6), y + uy*d*k + rand(-6, 6)
          local sc = 0.72 ^ k
          local band = halfp(sx, sy, a + 0.3*k, 1) * halfp(sx + ux*L*0.3*sc, sy + uy*L*0.3*sc, a + 0.3*k, -1)
          invPlate(sx, sy, ux, uy, L*sc, W*sc, band, 2 - (i % 2))
        end
      end
      n = n + 1
    end
  end
end
print(n)

--@ chunk 12
wait(12*60)
CUTP = pile{{"zinc white",6},{"cerulean blue",0.4},{"cobalt violet",0.2}}
local function strip(x0, y0, a, w)
  local nx, ny = -math.sin(a), math.cos(a)
  return mask(function(x, y) local d = (x-x0)*nx + (y-y0)*ny; return (d > 0 and d < w) and 1 or 0 end)
end
local cuts = {{560, 300, 0.95, 16, 11}, {560, 330, 2.6, 11, -8}, {600, 250, 0.2, 9, 7}}
for ci, c in ipairs(cuts) do
  local x0, y0, a, w, sh = c[1], c[2], c[3], c[4], c[5]
  local st = strip(x0, y0, a, w) * BREACH:shrink(2)
  -- the strip is wiped back to the breach's own pale
  work(st, {hand="detail", pile=TW[3], coverage=3, fill=true, clip=true, angle=a})
  -- what was there is repeated, slid along the cut
  local dx, dy = math.cos(a)*sh, math.sin(a)*sh
  for lev = 1, 3 do
    local A = ARCH[lev]
    local th = math.max(1.5, 13 * A.s)
    local pts = archPts(A.cx + dx, A.cy + dy, A.w, A.h, A.rot)
    local m = ribbon(pts, th) * st
    if m:area() > 3 then
      work(m, {hand="detail", pile=INKC[math.min(3, 1 + (lev-1)//2)], coverage=3, fill=true, clip=true})
    end
  end
  -- a cold hairline on each side of the cut
  local L = 330
  local p1 = {x0 - math.cos(a)*L, y0 - math.sin(a)*L}
  local p2 = {x0 + math.cos(a)*L, y0 + math.sin(a)*L}
  local nx, ny = -math.sin(a), math.cos(a)
  RIG:reload(CUTP, 0.7)
  RIG:stroke({p1, p2}, {pressure={0.3, 0.3}, clip=BREACH})
  RIG:reload(INKD, 0.5)
  RIG:stroke({{p1[1]+nx*w, p1[2]+ny*w}, {p2[1]+nx*w, p2[2]+ny*w}}, {pressure={0.15, 0.15}, clip=BREACH})
end
-- inverted stars: dark specks, clumped, sparse
stipple(BREACH:shrink(8) - archMask(ARCH[1], 1.05), {pile=INKD, width=1.6, coverage=0.012, cluster={0.7, 60}, pressure={0.3, 0.8}})

--@ chunk 13
print(wait(3*24*60)); for _,p in ipairs({{560,300},{450,400},{600,200},{420,260},{700,350},{820,320}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 14
WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.35}}
WINH = pile{{"lead white",3},{"lemon chrome",0.6},{"cadmium yellow",0.3}}
HOLE = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local tb = brush{kind="round", width=2, point=0.3}
local nlit = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.55 and ta < 1.1 and e < 1.75)
  if e > 1.12 and e < 2.9 and not infected and x > 0 and x < 1000 and y > 0 and y < 625 then
    local arc = tipArc(x, y, ux, uy, L, W, 0.55, 2, 8)
    local m = plateMask(x, y, ux, uy, L, W)
    -- uneven, golden-ratio-ish spacing along the arc
    local k = 1.0
    local nwin = 0
    while k < #arc and nwin < 7 do
      local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
      local f = k - math.floor(k)
      local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
      local lit = rand(0, 1) < (0.22 + 0.15 * (2.2 - e))
      tb:reload(HOLE, 0.7)
      tb:touch(px, py, {pressure=clamp(0.25 * e, 0.2, 0.7), clip=m})
      if lit then
        tb:reload(WIN, 0.8)
        tb:touch(px, py - 0.4, {pressure=clamp(0.18 * e, 0.15, 0.55), clip=m})
        nlit = nlit + 1
      end
      k = k + 0.618 + rand(0, 0.5)
      nwin = nwin + 1
    end
  end
end
print("lit", nlit)

--@ chunk 15
local nlit = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.55 and ta < 1.1 and e < 1.75)
  if e > 1.12 and e < 3.0 and not infected and x > -20 and x < 1020 and y > -20 and y < 645 then
    local m = plateMask(x, y, ux, uy, L, W)
    local arc = tipArc(x, y, ux, uy, L, W, 0.5, 1, 9)
    local wb = brush{kind="filbert", width=1.3 * e, stiffness=0.6}
    local hb = brush{kind="round", width=0.8 * e, point=0.4}
    local k = 1.0 + rand(0, 0.6)
    local nwin = 0
    while k < #arc and nwin < 8 do
      local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
      local f = k - math.floor(k)
      local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
      local hl = 2.2 * e
      local p1, p2 = {px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}
      wb:reload(HOLE, 0.8)
      wb:stroke({p1, p2}, {pressure={0.7, 0.7}, clip=m})
      if rand(0, 1) < (0.2 + 0.18 * (2.3 - e)) then
        wb:reload(WIN, 0.85)
        wb:stroke({{px - ux*hl*0.7, py - uy*hl*0.7}, {px + ux*hl*0.7, py + uy*hl*0.7}}, {pressure={0.5, 0.5}, clip=m})
        hb:reload(WINH, 0.8)
        hb:touch(px + ux*hl*0.2, py + uy*hl*0.2, {pressure=0.5, clip=m})
        nlit = nlit + 1
      end
      k = k + 0.62 + rand(0, 0.55)
      nwin = nwin + 1
    end
  end
end
print("lit", nlit)

--@ chunk 16
WD = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1.2}}
local o = body_of{spine={{396,345},{396,350},{396,353},{396,358},{396.5,368},{397,378},{397.5,389}},
  widths={4.4, 3.6, 2.4, 7.4, 6.2, 7.6, 10.5},
  limbs={{{392,358},{388.5,366},{387,371}, widths={2.4, 2.0, 1.8}},
         {{400,358},{402.5,367},{401.5,375}, widths={2.4, 2.0, 1.8}}},
  blend=0.8, char="firm", amount=0.3}
local m = o:mask()
work(m, {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
-- the polearm, planted
local rb = brush{kind="round", width=1.4, point=0.4}
rb:reload(WD, 0.9)
rb:stroke({{386.5, 391}, {386, 360}, {385.6, 333}}, {pressure={0.6, 0.55}})
-- leaf blade
local blade = poly({{385.6,334},{387.2,327},{385.4,318},{384.0,327}}, true)
work(blade, {hand="detail", pile=WD, coverage=4, fill=true, clip=true})

--@ chunk 17
print(wait(4*24*60)); for _,p in ipairs({{560,300},{600,200},{420,260},{700,350},{820,320},{500,380},{590,240}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 18
VEIL = pile{{"zinc white",5},{"cerulean blue",0.4},{"cobalt violet",0.45}, medium=0.3}
local nz = noise{seed=21, period=110, octaves=3}
local swirl = function(x, y) return math.atan(y-CY, x-CX) + math.pi/2 + 0.35 end
work(BREACH:shrink(3), {hand="scumble", pile=VEIL, coverage=1.3, load_at=function(x, y) return 0.12 + 0.4 * nz:at01(x, y) end,
  pressure={0.25, 0.45}, angle=swirl, clip=true})

--@ chunk 19
local m = ((BREACH - BREACH:shrink(30)) + ellipse(394,360,20,45)) * BREACH
for k=1,4 do work(m, {hand="scumble", blender=true, coverage=2, clip=true}) end

--@ chunk 20
LAT = pile{{"zinc white",3},{"cobalt violet",1},{"cerulean blue",0.5}}
local zone = mask(function(x, y)
  local e = ed(x, y)
  local ta = math.atan(y - CY, x - CX)
  local a = clamp(1 - math.abs(ta - 0.25) / 1.1, 0, 1)
  local r = clamp((2.4 - e) / 0.9, 0, 1) * clamp((e - 0.8) / 0.25, 0, 1)
  return a * r
end):blur(8)
local lb = brush{kind="rigger", width=1.6, point=0.9}
local rot = 0.18
local c, s = math.cos(rot), math.sin(rot)
local function warp(x, y)
  local e = ed(x, y)
  local k = clamp(1.6 - e, 0, 1)
  k = k * k
  local a = 0.9 * k
  local dx, dy = x - CX, y - CY
  local ca, sa = math.cos(a), math.sin(a)
  return CX + (dx*ca - dy*sa) * (1 - 0.25*k), CY + (dx*sa + dy*ca) * (1 - 0.25*k)
end
local sp = 36
for dir = 0, 1 do
  for j = -12, 12 do
    local pts = {}
    for t = -20, 20 do
      local u, v = t * 22, j * sp
      if dir == 1 then u, v = v, u end
      local x, y = 760 + u*c - v*s, 330 + u*s + v*c
      local wx, wy = warp(x, y)
      pts[#pts+1] = {wx, wy}
    end
    lb:reload(LAT, 0.6)
    lb:stroke(pts, {pressure={0.3, 0.3}, clip=zone})
  end
end

--@ chunk 21
-- ghost the far lattice
local far = mask(function(x, y) return ed(x, y) > 1.75 and 1 or 0 end):blur(15) * rect(560, 0, 440, 625)
work(far, {hand="scumble", blender=true, coverage=2, clip=true})
work(far, {hand="scumble", blender=true, coverage=1.5, clip=true})
-- shards drifting deeper into the breach, shrinking, turning
SHB = pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.8},{"ultramarine blue",0.4}}
local function shard(px, py, ux, uy, L, W, cut)
  local m = plateMask(px, py, ux, uy, L, W)
  local a = math.atan(uy, ux) + math.pi/2 + cut
  m = m * halfp(px, py, a, 1) * halfp(px + ux*L*0.25, py + uy*L*0.25, a + 0.2, -1)
  if m:area() < 8 then return end
  work(m, {hand="detail", pile=SHB, coverage=3, fill=true, clip=true})
  PL2:reload(INKD, 0.7)
  PL2:stroke(tipArc(px, py, ux, uy, L, W, 0.95, 1, 9), {pressure={0.3, 0.3}, clip=m})
end
local seeds = {{745, 250, 40}, {735, 330, 34}, {700, 410, 36}, {760, 380, 30}, {690, 300, 26}}
for si, s0 in ipairs(seeds) do
  local x, y, L = s0[1], s0[2], s0[3]
  for k = 1, 4 do
    local dx, dy = CX + 30 - x, CY - y
    local l = math.sqrt(dx*dx + dy*dy)
    local ux, uy = dx / l, dy / l
    -- each copy turns a little more than the last
    local tw = 0.35 * k
    local rux, ruy = ux*math.cos(tw) - uy*math.sin(tw), ux*math.sin(tw) + uy*math.cos(tw)
    shard(x, y, rux, ruy, L, L * 1.15, rand(-0.6, 0.6))
    x, y = x + ux * L * 0.75, y + uy * L * 0.75
    L = L * 0.7
  end
end

--@ chunk 22
local function shard(px, py, ux, uy, L, W, cut, side)
  local m = plateMask(px, py, ux, uy, L, W)
  local a = math.atan(uy, ux) + math.pi/2 + cut
  m = m * halfp(px, py, a, side)
  if m:area() < 8 then return 0 end
  work(m, {hand="detail", pile=SHB, coverage=3, fill=true, clip=true})
  PL2:reload(INKD, 0.7)
  PL2:stroke(tipArc(px, py, ux, uy, L, W, 0.95, 1, 9), {pressure={0.3, 0.3}, clip=m})
  return 1
end
local seeds = {{730, 245, 38}, {720, 335, 34}, {680, 405, 34}, {660, 200, 24}, {690, 290, 26}}
local n = 0
for si, s0 in ipairs(seeds) do
  local x, y, L = s0[1], s0[2], s0[3]
  for k = 1, 4 do
    local dx, dy = CX + 30 - x, CY - y
    local l = math.sqrt(dx*dx + dy*dy)
    local ux, uy = dx / l, dy / l
    local tw = 0.35 * k * (si % 2 == 0 and 1 or -1)
    local rux, ruy = ux*math.cos(tw) - uy*math.sin(tw), ux*math.sin(tw) + uy*math.cos(tw)
    n = n + shard(x, y, rux, ruy, L, L * 1.15, rand(-0.6, 0.6), (k % 2 == 0) and 1 or -1)
    x, y = x + ux * L * 0.8, y + uy * L * 0.8
    L = L * 0.7
  end
end
print(n)

--@ chunk 23
print(wait(4*24*60)); for _,p in ipairs({{560,300},{600,200},{480,300},{520,380},{575,290}}) do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 24
local function strip(x0, y0, a, w)
  local nx, ny = -math.sin(a), math.cos(a)
  return mask(function(x, y) local d = (x-x0)*nx + (y-y0)*ny; return (d > 0 and d < w) and 1 or 0 end)
end
local cuts = {{560, 300, 0.95, 16, TW[1]}, {560, 330, 2.6, 11, TW[2]}, {600, 250, 0.2, 9, TW[1]}}
for _, c in ipairs(cuts) do
  local st = strip(c[1], c[2], c[3], c[4]) * BREACH:shrink(2)
  work(st, {hand="detail", pile=c[5], coverage=2.5, fill=true, clip=true, angle=c[3]})
end
-- the dark sun at the bottom of the corridor
SX, SY = 576, 291
local sb = brush{kind="rigger", width=2.2, point=0.9}
for k = 0, 33 do
  local a = k / 34 * 2 * math.pi + rand(-0.06, 0.06)
  local r0, r1 = 12, 12 + rand(14, 48)
  local bend = 0.25
  sb:reload(INKC[2], 0.45)
  sb:stroke({{SX + r0*math.cos(a), SY + r0*math.sin(a)},
             {SX + (r0+r1)/2*math.cos(a + bend*0.5), SY + (r0+r1)/2*math.sin(a + bend*0.5)},
             {SX + r1*math.cos(a + bend), SY + r1*math.sin(a + bend)}},
    {pressure={0.55, 0.0}, ramps={0.02, 0.7}})
end
work(ellipse(SX, SY, 19, 19) - ellipse(SX, SY, 12, 12), {hand="detail", pile=INKC[1], coverage=2, fill=true, clip=true})
work(ellipse(SX, SY, 12, 12), {hand="detail", pile=INKD, coverage=4, fill=true, clip=true})

--@ chunk 25
local keep = ellipse(SX, SY, 24, 24) + ellipse(394, 362, 16, 42)
  + mask(function(x, y) local ta = math.atan(y - CY, x - CX); return (ta > -0.62 and ta < 1.15 and ed(x, y) > 0.5) and 1 or 0 end)
local R = (BREACH:shrink(5) - keep:soften(4))
local function zone(lo, hi)
  return mask(function(x, y) local e = math.sqrt(((x-SX)/215)^2 + ((y-SY)/170)^2); return (e >= lo and e < hi) and 1 or 0 end):soften(6) * R
end
local swirl = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.45 end
B_PINK = pile{{"zinc white",4},{"magenta",0.35},{"cobalt violet",0.6}}
work(zone(0.78, 99), {hand="body", pile=B_RIM, coverage=3, fill=true, angle=swirl, clip=R})
work(zone(0.56, 0.78), {hand="body", pile=B_PINK, coverage=3, fill=true, angle=swirl, clip=R})
work(zone(0.3, 0.56), {hand="body", pile=B_MID, coverage=3, fill=true, angle=swirl, clip=R})
work(zone(0, 0.3), {hand="body", pile=B_CEN, coverage=3, fill=true, angle=swirl, clip=R})
blend(R:shrink(3), {angle=swirl})

--@ chunk 26
local m = ((BREACH - BREACH:shrink(34)) + ellipse(394,362,18,44)) * BREACH
for k=1,4 do work(m, {hand="scumble", blender=true, coverage=2, clip=true}) end

--@ chunk 27
B_CY = pile{{"zinc white",3},{"cerulean blue",1},{"emerald green",0.15}}
B_VI = pile{{"zinc white",3},{"ultramarine blue",0.5},{"cobalt violet",0.8}}
local keep = ellipse(SX, SY, 24, 24)
  + mask(function(x, y) local ta = math.atan(y - CY, x - CX); return (ta > -0.62 and ta < 1.15 and ed(x, y) > 0.5) and 1 or 0 end)
local R = (BREACH:shrink(36) - keep:soften(4))
local swirl = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.45 end
work(R, {hand="body", pile=B_CY, coverage=0.9, angle=swirl, clip=R, length={30, 80}, pressure={0.4, 0.7}})
work(R, {hand="body", pile=B_VI, coverage=0.6, angle=swirl, clip=R, length={30, 80}, pressure={0.4, 0.7}})

--@ chunk 28
local m = ellipse(394,360,14,40) * BREACH
for k=1,4 do work(m, {hand="scumble", blender=true, tool="filbert 4", coverage=2, clip=true}) end

--@ chunk 29
wait(3*24*60)
local function strip(x0, y0, a, w)
  local nx, ny = -math.sin(a), math.cos(a)
  return mask(function(x, y) local d = (x-x0)*nx + (y-y0)*ny; return (d > -1 and d < w + 1) and 1 or 0 end)
end
local band = (BREACH - BREACH:shrink(36)) - mask(function(x, y) local ta = math.atan(y - CY, x - CX); return (ta > -0.62 and ta < 1.15) and 1 or 0 end)
local cuts = {{560, 300, 0.95, 16}, {560, 330, 2.6, 11}, {600, 250, 0.2, 9}}
for _, c in ipairs(cuts) do
  local st = strip(c[1], c[2], c[3], c[4]) * band - ellipse(394, 360, 12, 40)
  work(st, {hand="detail", pile=B_RIM, coverage=3, fill=true, clip=true})
end
-- ghost arches: the corridor that runs into itself, thin and broken, turning into the dark sun
local GH = pile{{"zinc white",2},{"cobalt violet",1},{"ultramarine blue",0.6}}
local rb = brush{kind="rigger", width=2.0, point=0.9}
local VP = {SX, SY}
local C0 = {SX - 14, SY + 40}
for lev = 0, 5 do
  local s = 0.64 ^ lev
  local cx, cy = VP[1] + (C0[1]-VP[1])*s, VP[2] + (C0[2]-VP[2])*s
  local pts = archPts(cx, cy, 190*s, 240*s, -0.15 + lev*0.33)
  -- broken: draw it in runs, skipping some
  local i = 1
  while i < #pts do
    local j = math.min(#pts, i + math.random(2, 4))
    if math.random() < 0.72 then
      local seg = {}
      for z = i, j do seg[#seg+1] = pts[z] end
      rb:reload(GH, 0.55)
      rb:stroke(seg, {pressure={0.18 + 0.2*s, 0.12 + 0.2*s}, clip=BREACH:shrink(4)})
    end
    i = j
  end
end

--@ chunk 30
-- warden: restate the dark, then cold rims from the breach behind him
local o = body_of{spine={{396,345},{396,350},{396,353},{396,358},{396.5,368},{397,378},{397.5,389}},
  widths={4.4, 3.6, 2.4, 7.4, 6.2, 7.6, 10.5},
  limbs={{{392,358},{388.5,366},{387,371}, widths={2.4, 2.0, 1.8}},
         {{400,358},{402.5,367},{401.5,375}, widths={2.4, 2.0, 1.8}}},
  blend=0.8, char="firm", amount=0.3}
WM = o:mask()
work(WM, {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
local rb = brush{kind="round", width=1.4, point=0.4}
rb:reload(WD, 0.9)
rb:stroke({{386.5, 391}, {386, 360}, {385.6, 333}}, {pressure={0.6, 0.55}})
work(poly({{385.6,334},{387.2,327},{385.4,318},{384.0,327}}, true), {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
-- the nimbus: a thin bronze ring behind the head
local hb = brush{kind="round", width=1.0, point=0.6}
hb:reload(BZ[5], 0.7)
local ring = {}
for k = 0, 24 do local a = k / 24 * 2 * math.pi; ring[#ring+1] = {396 + 8*math.cos(a), 347 + 8*math.sin(a)} end
hb:stroke(ring, {pressure={0.35, 0.35}, clip=-WM})
-- turrets on the inner rings: bone sockets with a dark eye and a barrel laid toward the breach
local nt = 0
for i = 0, 60 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if not infected and e > 1.05 and e < 1.75 and (i % 4 == 1) then
    local m = plateMask(x, y, ux, uy, L, W)
    local r = 5.5 * e
    local tx, ty = x - ux*L*0.05, y - uy*L*0.05
    work(ellipse(tx, ty, r, r) * m, {hand="detail", pile=BONE, coverage=3, fill=true, clip=true})
    work(ellipse(tx, ty, r*0.55, r*0.55) * m, {hand="detail", pile=HOLE, coverage=3, fill=true, clip=true})
    local bb = brush{kind="filbert", width=2.2 * e}
    bb:reload(WD, 0.9)
    bb:stroke({{tx, ty}, {tx + ux*L*0.42, ty + uy*L*0.42}}, {pressure={0.8, 0.65}})
    local tb = brush{kind="round", width=1.2*e, point=0.4}
    tb:reload(LIPS[1], 0.7)
    tb:touch(tx + ux*L*0.42, ty + uy*L*0.42, {pressure=0.6})
    nt = nt + 1
  end
end
print("turrets", nt)

--@ chunk 31
wait(24*60)
COLDL = pile{{"zinc white",4},{"cerulean blue",0.6},{"cobalt violet",0.3}}
COLDS = pile{{"zinc white",2},{"cerulean blue",0.6},{"cobalt violet",0.6},{"raw sienna",0.3}}
local lipb = brush{kind="round", width=3.0, point=0.5}
local scb = brush("filbert", 6)
for i = 0, 70 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if not infected and e < 1.6 and x > 0 and x < 1000 and y > 0 and y < 625 then
    local m = plateMask(x, y, ux, uy, L, W)
    local s = clamp((1.6 - e) / 0.6, 0, 1)
    -- cold light lying on the rounded tip
    scb:reload(COLDS, 0.35 + 0.3*s)
    scb:stroke(tipArc(x, y, ux, uy, L, W, 0.88, 2, 8), {pressure={0.3, 0.3}, swell={0.4, 1.0, 0.4}, clip=m})
    lipb:reload(COLDL, 0.8)
    lipb:stroke(tipArc(x, y, ux, uy, L, W, 0.97, 2, 8), {pressure={0.3 + 0.3*s, 0.3 + 0.3*s}, swell={0.4, 1.2, 0.4}, clip=m})
  end
end

--@ chunk 32
WIN2 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.8}}
WIN3 = pile{{"lead white",3},{"lemon chrome",0.8}}
local nlit = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if e > 1.12 and e < 3.0 and not infected and x > -20 and x < 1020 and y > -20 and y < 645 then
    local m = plateMask(x, y, ux, uy, L, W)
    local arc = tipArc(x, y, ux, uy, L, W, 0.5, 1, 9)
    local wb = brush{kind="filbert", width=1.25 * e, stiffness=0.6}
    local hb = brush{kind="round", width=0.9 * e, point=0.3}
    -- a short lit run: two to four neighbours lit together, the rest dark
    local start = 1 + math.random() * (#arc - 2)
    local run = math.random(1, 3)
    local k = start
    for r = 1, run do
      if k >= #arc then break end
      local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
      local f = k - math.floor(k)
      local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
      local hl = 2.0 * e
      wb:reload(HOLE, 0.8)
      wb:stroke({{px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}}, {pressure={0.75, 0.75}, clip=m})
      wb:reload(WIN2, 0.9)
      wb:stroke({{px - ux*hl*0.65, py - uy*hl*0.65}, {px + ux*hl*0.65, py + uy*hl*0.65}}, {pressure={0.6, 0.6}, clip=m})
      hb:reload(WIN3, 0.9)
      hb:touch(px, py, {pressure=0.55, clip=m})
      nlit = nlit + 1
      k = k + 0.75 + math.random() * 0.4
    end
  end
end
print(nlit)

--@ chunk 33
wait(2*24*60)
WIN4 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",1},{"vermilion",0.2}}
local n = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if e > 1.12 and e < 3.0 and not infected and x > -20 and x < 1020 and y > -20 and y < 645 then
    local m = plateMask(x, y, ux, uy, L, W)
    local arc = tipArc(x, y, ux, uy, L, W, 0.5, 1, 9)
    local wb = brush{kind="filbert", width=1.2 * e, stiffness=0.6}
    local k = 1 + math.random() * (#arc - 2)
    local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
    local f = k - math.floor(k)
    local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
    local hl = 1.6 * e
    wb:reload(WIN4, 0.9)
    wb:stroke({{px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}}, {pressure={0.7, 0.7}, clip=m})
    n = n + 1
  end
end
print(n)

--@ chunk 34

WIN4 = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",1},{"vermilion",0.2}}
local n = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if e > 1.12 and e < 3.0 and not infected and x > -20 and x < 1020 and y > -20 and y < 645 then
    local m = plateMask(x, y, ux, uy, L, W)
    local arc = tipArc(x, y, ux, uy, L, W, 0.5, 1, 9)
    local wb = brush{kind="filbert", width=1.2 * e, stiffness=0.6}
    local k = 1 + math.random() * (#arc - 2)
    local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
    local f = k - math.floor(k)
    local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
    local hl = 1.6 * e
    wb:reload(WIN4, 0.9)
    wb:stroke({{px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}}, {pressure={0.7, 0.7}, clip=m})
    n = n + 1
  end
end
print(n)
-- turret barrels: a cold lit edge along each barrel
local nt = 0
for i = 0, 60 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if not infected and e > 1.05 and e < 1.75 and (i % 4 == 1) then
    local tx, ty = x - ux*L*0.05, y - uy*L*0.05
    local vx, vy = -uy, ux
    local o = 0.9 * e
    local tb = brush{kind="round", width=0.9*e, point=0.5}
    tb:reload(COLDL, 0.7)
    tb:stroke({{tx + vx*o + ux*5*e, ty + vy*o + uy*5*e}, {tx + vx*o + ux*L*0.42, ty + vy*o + uy*L*0.42}}, {pressure={0.2, 0.45}})
    nt = nt + 1
  end
end
print(nt)

--@ chunk 35
wait(24*60)
-- veil the far lattice so the grid is strongest where it meets the breach
local far = mask(function(x, y) return clamp((ed(x, y) - 1.85) / 0.4, 0, 1) end) * rect(600, 0, 400, 625)
local DV = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}, medium=0.2}
work(far, {hand="scumble", pile=DV, coverage=1.2, load=0.22, pressure={0.15, 0.3}, clip=far})
-- soften the seam ring inside the breach with short radial strokes of the neighbouring pales
local seam = (BREACH:shrink(26) - BREACH:shrink(46)) - mask(function(x, y) local ta = math.atan(y - CY, x - CX); return (ta > -0.62 and ta < 1.15) and 1 or 0 end) - ellipse(394, 360, 16, 44)
local radial = function(x, y) return math.atan(y - SY, x - SX) end
work(seam, {hand="body", tool="filbert 5", pile=B_RIM, coverage=1.0, angle=radial, length={10, 25}, clip=BREACH:shrink(8) - ellipse(394, 360, 16, 44)})
work(seam, {hand="body", tool="filbert 5", pile=B_VI, coverage=0.5, angle=radial, length={10, 25}, clip=BREACH:shrink(8) - ellipse(394, 360, 16, 44)})

--@ chunk 36
wait(12*60)
-- tendrils: from the dark sun, swirling out with the vortex toward the opened sector
local tb = brush{kind="rigger", width=2.6, point=0.95}
local targets = {{700, 230}, {735, 300}, {705, 380}, {660, 420}, {760, 350}, {640, 175}}
for k, tg in ipairs(targets) do
  local pts = {}
  local dx, dy = tg[1] - SX, tg[2] - SY
  local r1 = math.sqrt(dx*dx + dy*dy)
  local a1 = math.atan(dy, dx)
  local spin = 1.3 + 0.25 * (k % 3)
  for j = 0, 14 do
    local f = j / 14
    local r = 13 + (r1 - 13) * f
    local a = a1 - spin * (1 - f) + 0.08 * math.sin(f * 9 + k)
    pts[#pts+1] = {SX + r * math.cos(a), SY + r * math.sin(a)}
  end
  tb:reload(INKC[1], 0.7)
  tb:stroke(pts, {pressure={0.75, 0.05}, ramps={0.02, 0.6}})
end
-- the warden's shadow is pale: inverted light
local sh = poly({{392.5, 389}, {402, 389}, {378, 422}, {366, 420}}, true)
local SHP = pile{{"zinc white",3},{"cerulean blue",0.6},{"cobalt violet",0.5}}
work(sh - WM, {hand="detail", pile=SHP, coverage=1.8, fill=true, clip=true, angle=2.2})
-- the rim breathes: broken echoes of the edge, inward
local eb = brush{kind="rigger", width=1.8, point=0.9}
for r = 1, 3 do
  local sc = 1 - r * 0.075
  local i = 1
  while i < #BPTS do
    local j = math.min(#BPTS, i + math.random(2, 5))
    if math.random() < 0.55 then
      local seg = {}
      for z = i, j do
        local p = BPTS[z]
        local w = 1 + 0.02 * math.sin(z * 0.9 + r * 2)
        seg[#seg+1] = {SX + (p[1] - SX) * sc * w, SY + (p[2] - SY) * sc * w}
      end
      eb:reload(B_VI, 0.5)
      eb:stroke(seg, {pressure={0.25, 0.25}, swell={0.4, 1.2, 0.4}, clip=BREACH:shrink(10) - ellipse(394, 360, 16, 44)})
    end
    i = j
  end
end

--@ chunk 37
local m = ellipse(383,405,14,18)
for k=1,2 do work(m, {hand="scumble", blender=true, tool="filbert 4", coverage=1.5, clip=true}) end
local nz = noise{seed=77, period=40, octaves=2}
local patches = mask(function(x,y) local d = math.sqrt((x-SX)^2+(y-SY)^2); return (d > 40 and nz:at01(x,y) > 0.58) and 1 or 0 end) * BREACH:shrink(6)
for k=1,3 do work(patches, {hand="scumble", blender=true, tool="filbert 5", coverage=1.5, clip=true}) end

--@ chunk 38
-- sentries on the rim, each standing on its own plate: feet outward, heads toward the breach
function sentry(fx, fy, dir, h, lance)
  local function P(dx, dy) return {fx + dx, fy - dir * dy} end
  local s = h / 44
  local sp = {P(0, 44*s), P(0, 39*s), P(0, 36*s), P(0, 31*s), P(0.4*s, 21*s), P(0.8*s, 11*s), P(1.2*s, 0)}
  local o = body_of{spine=sp, widths={4.2*s, 3.4*s, 2.3*s, 7*s, 5.8*s, 7.2*s, 9.8*s},
    limbs={{P(-4*s, 31*s), P(-7*s, 23*s), P(-8*s, 18*s), widths={2.3*s, 1.9*s, 1.7*s}},
           {P(4*s, 31*s), P(7*s, 22*s), P(6*s, 15*s), widths={2.3*s, 1.9*s, 1.7*s}}},
    blend=0.8, char="firm", amount=0.3}
  local m = o:mask()
  work(m, {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
  if lance then
    local rb = brush{kind="round", width=1.3*s, point=0.4}
    rb:reload(WD, 0.9)
    local a, b = P(-9*s, -2*s), P(-9.6*s, 56*s)
    rb:stroke({a, b}, {pressure={0.6, 0.55}})
    local t = P(-9.7*s, 58*s)
    work(poly({P(-9.7*s, 55*s), P(-8.2*s, 61*s), P(-9.8*s, 69*s), P(-11.2*s, 61*s)}, true), {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
  end
  return m
end
S1 = sentry(548, 146, -1, 38, true)
S2 = sentry(527, 437, 1, 36, true)
work(WM, {hand="detail", pile=WD, coverage=3, fill=true, clip=true})

--@ chunk 39
print(wait(2*24*60)); print(drying(548,165), drying(527,420), drying(396,370))
work(S1 + S2 + WM, {hand="detail", pile=WD, coverage=3, fill=true, clip=true})

--@ chunk 40
-- pale back over the smeared lift right of the warden
local pale = poly({{404, 380}, {440, 372}, {478, 378}, {484, 398}, {470, 410}, {440, 412}, {425, 400}, {406, 396}}, true) - WM:grow(1)
work(pale, {hand="detail", pile=B_RIM, coverage=3, fill=true, clip=true, angle=0.3})
-- the ledge he stands on: one plate tip, bronze, lit cold along its lip
local ledge = poly({{356, 396}, {372, 390}, {392, 388.5}, {410, 391}, {426, 398}, {432, 408}, {400, 414}, {362, 418}}, true) - WM
work(ledge, {hand="detail", pile=BZ[3], coverage=3, fill=true, clip=true, angle=0})
local lb = brush{kind="round", width=2.2, point=0.5}
lb:reload(BZ[5], 0.7)
lb:stroke({{362, 395}, {380, 391}, {398, 390.5}, {414, 393.5}, {427, 400}}, {pressure={0.5, 0.5}, clip=ledge})
lb:reload(COLDL, 0.8)
lb:stroke({{358, 395}, {376, 390}, {394, 388.8}, {411, 391}, {427, 398}}, {pressure={0.3, 0.3}, swell={0.5, 1.2, 0.6}})

--@ chunk 41
local pale = poly({{404, 380}, {440, 372}, {478, 378}, {484, 398}, {470, 410}, {440, 412}, {425, 400}, {406, 396}}, true) - WM:grow(1)
local swirl = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.45 end
work(pale:grow(6) - WM:grow(1), {hand="body", tool="filbert 5", pile=B_CY, coverage=0.7, angle=swirl, length={15,40}, clip=pale:grow(6) - WM:grow(1)})
work(pale:grow(6) - WM:grow(1), {hand="body", tool="filbert 4", pile=B_VI, coverage=0.5, angle=swirl, length={15,40}, clip=pale:grow(6) - WM:grow(1)})
wait(24*60)
local lb = brush{kind="round", width=2.6, point=0.5}
lb:reload(COLDL, 0.9)
lb:stroke({{358, 395.5}, {376, 390.5}, {394, 389.3}, {411, 391.5}, {427, 398.5}}, {pressure={0.45, 0.45}, swell={0.5, 1.2, 0.6}})

--@ chunk 42
INVW = pile{{"ultramarine blue",2},{"cobalt violet",1},{"bone black",0.4}}
INVC = pile{{"cobalt blue",1},{"ultramarine blue",1},{"zinc white",0.3}}
local n = 0
for i = 0, 112 do
  local x, y, ux, uy, L, W, e, t = plateGeom(i)
  local ta = math.atan(y - CY, x - CX)
  local infected = (ta > -0.62 and ta < 1.15 and e < 1.8)
  if infected and e > 1.0 then
    local m = plateMask(x, y, ux, uy, L, W)
    local arc = tipArc(x, y, ux, uy, L, W, 0.62, 1, 9)
    local wb = brush{kind="filbert", width=1.3 * e, stiffness=0.6}
    local k = 1.0 + math.random() * 0.6
    while k < #arc do
      local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
      local f = k - math.floor(k)
      local px, py = lerp(a[1], b[1], f), lerp(a[2], b[2], f)
      local hl = 2.1 * e
      local lit = math.random() < 0.35
      wb:reload(lit and INVW or INVC, 0.85)
      wb:stroke({{px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}}, {pressure={lit and 0.75 or 0.5, lit and 0.75 or 0.5}, clip=m})
      n = n + 1
      k = k + 0.62 + math.random() * 0.5
    end
  end
end
print(n)

--@ chunk 43
print(drying(SX,SY), drying(SX+16,SY))
work(ellipse(SX, SY, 11.5, 11.5), {hand="detail", pile=INKD, coverage=4, fill=true, clip=true})
local rb = brush{kind="round", width=2.0, point=0.4}
local ring = {}
for k = 0, 40 do local a = k/40*2*math.pi; ring[#ring+1] = {SX + 13.2*math.cos(a), SY + 13.2*math.sin(a)} end
rb:reload(pile{{"zinc white",5},{"cerulean blue",0.15}}, 0.9)
rb:stroke(ring, {pressure={0.5, 0.5}})

--@ chunk 44
-- SECOND PASS. Breach: a falling-away. Bands of deepening cold violet spiral down to the black sun.
local figs = (WM:grow(3) + S1:grow(3) + S2:grow(3) + ellipse(386.5, 360, 3, 34) + ellipse(SX, SY, 14.5, 14.5))
local R = BREACH:shrink(3) - figs
local function dd(x, y) return math.sqrt(((x-SX)/215)^2 + ((y-SY)/170)^2) end
local function zone(lo, hi)
  return mask(function(x, y) local e = dd(x, y); return (e >= lo and e < hi) and 1 or 0 end):soften(5) * R
end
-- strokes spiral inward: tangent plus a pitch toward the sun
local spiral = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.32 end
DEEP = {
  pile{{"zinc white",4},{"cobalt violet",0.9},{"magenta",0.15}},
  pile{{"zinc white",4},{"cerulean blue",0.7},{"cobalt violet",0.6}},
  pile{{"zinc white",3},{"cobalt violet",1},{"ultramarine blue",0.35}},
  pile{{"zinc white",2},{"cobalt violet",1},{"ultramarine blue",0.7}},
  pile{{"zinc white",0.9},{"cobalt violet",1},{"ultramarine blue",1.3}},
  pile{{"ultramarine blue",2},{"cobalt violet",1},{"bone black",0.3},{"zinc white",0.25}},
}
local edges = {99, 0.74, 0.55, 0.40, 0.28, 0.17, 0.0}
for k = 1, 6 do
  work(zone(edges[k+1], edges[k]), {hand="body", tool="filbert 7", pile=DEEP[k], coverage=2.6, fill=true,
    angle=spiral, clip=R, length={25, 70}})
end
blend(R:shrink(3), {angle=spiral})

--@ chunk 45
wait(24*60)
-- the corridor that connects to itself: arch frames falling away to the sun, lit on their inner faces
local figs = (WM:grow(3) + S1:grow(3) + S2:grow(3) + ellipse(386.5, 360, 3, 34))
local R = BREACH:shrink(6) - figs
local FRAME = {
  pile{{"zinc white",5},{"cerulean blue",0.3},{"cobalt violet",0.2}},
  pile{{"zinc white",4},{"cerulean blue",0.4},{"cobalt violet",0.4}},
  pile{{"zinc white",3},{"cobalt violet",0.6},{"cerulean blue",0.4}},
}
local SHD = pile{{"ultramarine blue",1.5},{"cobalt violet",1},{"bone black",0.3},{"zinc white",0.4}}
local feet = {}
local VP = {SX, SY}
local C0 = {SX - 16, SY + 46}
for lev = 0, 5 do
  local s = 0.62 ^ lev
  local cx, cy = VP[1] + (C0[1]-VP[1])*s, VP[2] + (C0[2]-VP[2])*s
  local w, h, rot = 205*s, 255*s, -0.12 + lev*0.3
  local outer = archPts(cx, cy, w, h, rot)
  local inner = archPts(cx, cy + h*0.02, w*0.86, h*0.92, rot)
  local th = math.max(1.6, 9 * s)
  local fp = FRAME[math.min(3, 1 + lev // 2)]
  if th > 2.5 then
    -- frame face
    work(ribbon(outer, th) * R, {hand="detail", pile=fp, coverage=3, fill=true, clip=true})
    -- the reveal: a shadowed band inside the frame
    work(ribbon(inner, th * 0.6) * R, {hand="detail", pile=SHD, coverage=2.5, fill=true, clip=true})
  else
    RIG:reload(fp, 0.7); RIG:stroke(outer, {pressure={0.35, 0.35}, clip=R})
    RIG:reload(SHD, 0.6); RIG:stroke(inner, {pressure={0.2, 0.2}, clip=R})
  end
  feet[#feet+1] = {outer[1], outer[#outer], outer[6]}
end
-- floor and crown lines run from each frame into the next
for i = 1, #feet - 1 do
  local a, b = feet[i], feet[i+1]
  for k = 1, 3 do
    RIG:reload(FRAME[2], 0.6)
    RIG:stroke({a[k], b[k]}, {pressure={0.3, 0.15}, clip=R})
  end
end

--@ chunk 46
I0, I1 = 0, 55
-- SECOND PASS plates: each its own size, tilt and tone; lit lip, dark underside, sheen, patina, windows on its curve.
function hsh(i, k) local v = math.sin(i * 12.9898 + k * 78.233) * 43758.5453; return v - math.floor(v) end
function geom3(i)
  local x, y, e, t = slot(i)
  local ux, uy = -math.cos(t), -math.sin(t) * 0.8
  local l = math.sqrt(ux*ux+uy*uy); ux, uy = ux/l, uy/l
  local tilt = (hsh(i, 1) - 0.5) * 0.5
  local c, s = math.cos(tilt), math.sin(tilt)
  ux, uy = ux*c - uy*s, ux*s + uy*c
  local L = 66 * e * (0.85 + 0.4 * hsh(i, 2))
  local W = 78 * e * (0.85 + 0.35 * hsh(i, 3))
  x = x + (hsh(i, 4) - 0.5) * 0.12 * W
  y = y + (hsh(i, 5) - 0.5) * 0.12 * L
  return x, y, ux, uy, L, W, e, t
end
BZ0 = pile{{"Mars brown",2},{"ultramarine blue",1.2},{"bone black",1.6}}
BZT = {BZ0, BZ[1], BZ[2], BZ[3], BZ[4], BZ[5]}
OCC = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.6},{"yellow ochre",0.5}}
-- inverted palette: same roles, values and temperatures turned over
IPAL = {
  body = {pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.7}},
          pile{{"zinc white",3},{"cobalt violet",0.8},{"cerulean blue",0.4}},
          pile{{"zinc white",4},{"cerulean blue",0.6},{"cobalt violet",0.4}}},
  occ = pile{{"zinc white",5},{"cerulean blue",0.4}},
  lip = INKD,
  sheen = pile{{"cobalt violet",1.2},{"ultramarine blue",1},{"zinc white",0.8}},
}
FIGS = WM:grow(3) + S1:grow(3) + S2:grow(3) + ellipse(386.5, 360, 3, 34)
NOTF = -FIGS
function pmask3(x, y, ux, uy, L, W) return plateMask(x, y, ux, uy, L, W) end
function plate3(x, y, ux, uy, L, W, e, tone, lit, inv, clipm)
  local m = pmask3(x, y, ux, uy, L, W) * NOTF
  if clipm then m = m * clipm end
  local vx, vy = -uy, ux
  local bw = clamp(5 + 3.2 * e, 7, 18)
  local B = brush("filbert", bw)
  local body1, body2, body3, occp, lipp
  if inv then
    body1, body2, body3, occp, lipp = IPAL.body[1], IPAL.body[2], IPAL.sheen, IPAL.occ, IPAL.lip
  else
    body1, body2, body3 = BZT[math.max(1, tone - 1)], BZT[tone], BZT[math.min(6, tone + 1)]
    occp = OCC
    lipp = LIPS[lit > 0.66 and 1 or (lit > 0.33 and 2 or 3)]
  end
  -- the underside: a dark shadow just beyond the free edge, on the plate below
  local OB = brush("filbert", clamp(2.4 * e, 3, 9))
  OB:reload(occp, 0.9)
  OB:stroke(tipArc(x, y, ux, uy, L, W, 1.04, 1, 9), {pressure={0.8, 0.8}, clip=(clipm and (-pmask3(x, y, ux, uy, L, W) * NOTF * clipm) or (-pmask3(x, y, ux, uy, L, W) * NOTF))})
  -- body: strokes base to tip, darker at the base
  local bx, by = x - ux*L*0.5, y - uy*L*0.5
  local n = math.max(2, math.floor(W / (bw * 0.6)))
  B:reload(body1, 0.95)
  for j = 0, n do
    local s = (j / n - 0.5) * W * 0.95
    B:stroke({{bx + vx*s - ux*4, by + vy*s - uy*4}, {x + ux*L*0.4 + vx*s*0.8, y + uy*L*0.4 + vy*s*0.8}},
      {pressure={0.85, 0.7}, clip=m})
    if j % 2 == 1 then B:reload(body1, 0.9) end
  end
  -- the convex turn toward the light: mid tone arc, then sheen arc
  B:reload(body2, 0.8)
  B:stroke(tipArc(x, y, ux, uy, L, W, 0.7, 1, 9), {pressure={0.6, 0.6}, clip=m})
  B:reload(body3, 0.7)
  B:stroke(tipArc(x, y, ux, uy, L, W, 0.84, 2, 8), {pressure={0.4, 0.4}, swell={0.5, 1.2, 0.5}, clip=m})
  -- lip
  local LB = brush{kind="round", width=clamp(1.2 * e + 1.2, 2, 5), point=0.5}
  LB:reload(lipp, 0.85)
  LB:stroke(tipArc(x, y, ux, uy, L, W, 0.965, 1 + math.floor(hsh(x, y) * 2), 9 - math.floor(hsh(y, x) * 2)),
    {pressure={0.25 + 0.35 * lit, 0.25 + 0.35 * lit}, swell={0.4, 1.3, 0.5}, clip=m})
  return m
end
local count = 0
for i = I0, I1 do
  local x, y, ux, uy, L, W, e, t = geom3(i)
  if x > -L and x < 1000 + L and y > -L and y < 625 + L then
    local tone = clamp(math.floor(6.3 - (e - 0.9) * 1.9 + (hsh(i, 6) - 0.5) * 1.6), 1, 6)
    local lit = clamp(1.4 - (e - 0.9) * 0.8, 0.1, 1)
    local ta = math.atan(y - CY, x - CX)
    local infected = (ta > -0.62 and ta < 1.15 and e < 1.85)
    plate3(x, y, ux, uy, L, W, e, tone, lit, false, nil)
    if infected then
      local sev = clamp((1.85 - e) / 0.8, 0, 1) * clamp(1 - math.abs(ta - 0.28) / 0.9, 0, 1)
      if sev > 0.1 then
        local a = math.atan(uy, ux) + math.pi/2 + (hsh(i, 7) - 0.5) * 1.0
        local off = (0.45 - sev) * L * 0.9
        local side = (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1
        local hp = halfp(x + ux*off, y + uy*off, a, side)
        plate3(x, y, ux, uy, L, W, e, tone, lit, true, hp)
      end
    end
    count = count + 1
  end
end
print(count)

--@ chunk 47
I0, I1, DOINV = 56, 118, false
-- SECOND PASS plates: each its own size, tilt and tone; lit lip, dark underside, sheen, patina, windows on its curve.
function hsh(i, k) local v = math.sin(i * 12.9898 + k * 78.233) * 43758.5453; return v - math.floor(v) end
function geom3(i)
  local x, y, e, t = slot(i)
  local ux, uy = -math.cos(t), -math.sin(t) * 0.8
  local l = math.sqrt(ux*ux+uy*uy); ux, uy = ux/l, uy/l
  local tilt = (hsh(i, 1) - 0.5) * 0.5
  local c, s = math.cos(tilt), math.sin(tilt)
  ux, uy = ux*c - uy*s, ux*s + uy*c
  local L = 66 * e * (0.85 + 0.4 * hsh(i, 2))
  local W = 78 * e * (0.85 + 0.35 * hsh(i, 3))
  x = x + (hsh(i, 4) - 0.5) * 0.12 * W
  y = y + (hsh(i, 5) - 0.5) * 0.12 * L
  return x, y, ux, uy, L, W, e, t
end
BZ0 = pile{{"Mars brown",2},{"ultramarine blue",1.2},{"bone black",1.6}}
BZT = {BZ0, BZ[1], BZ[2], BZ[3], BZ[4], BZ[5]}
OCC = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
VERD = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.6},{"yellow ochre",0.5}}
-- inverted palette: same roles, values and temperatures turned over
IPAL = {
  body = {pile{{"zinc white",2},{"ultramarine ash",1},{"cobalt violet",0.7}},
          pile{{"zinc white",3},{"cobalt violet",0.8},{"cerulean blue",0.4}},
          pile{{"zinc white",4},{"cerulean blue",0.6},{"cobalt violet",0.4}}},
  occ = pile{{"zinc white",5},{"cerulean blue",0.4}},
  lip = INKD,
  sheen = pile{{"cobalt violet",1.2},{"ultramarine blue",1},{"zinc white",0.8}},
}
FIGS = WM:grow(3) + S1:grow(3) + S2:grow(3) + ellipse(386.5, 360, 3, 34)
NOTF = -FIGS
function pmask3(x, y, ux, uy, L, W) return plateMask(x, y, ux, uy, L, W) end
function plate3(x, y, ux, uy, L, W, e, tone, lit, inv, clipm)
  local m = pmask3(x, y, ux, uy, L, W) * NOTF
  if clipm then m = m * clipm end
  local vx, vy = -uy, ux
  local bw = clamp(5 + 3.2 * e, 7, 18)
  local B = brush("filbert", bw)
  local body1, body2, body3, occp, lipp
  if inv then
    body1, body2, body3, occp, lipp = IPAL.body[1], IPAL.body[2], IPAL.sheen, IPAL.occ, IPAL.lip
  else
    body1, body2, body3 = BZT[math.max(1, tone - 1)], BZT[tone], BZT[math.min(6, tone + 1)]
    occp = OCC
    lipp = LIPS[lit > 0.66 and 1 or (lit > 0.33 and 2 or 3)]
  end
  -- the underside: a dark shadow just beyond the free edge, on the plate below
  local OB = brush("filbert", clamp(2.4 * e, 3, 9))
  OB:reload(occp, 0.9)
  OB:stroke(tipArc(x, y, ux, uy, L, W, 1.04, 1, 9), {pressure={0.8, 0.8}, clip=(clipm and (-pmask3(x, y, ux, uy, L, W) * NOTF * clipm) or (-pmask3(x, y, ux, uy, L, W) * NOTF))})
  -- body: strokes base to tip, darker at the base
  local bx, by = x - ux*L*0.5, y - uy*L*0.5
  local n = math.max(2, math.floor(W / (bw * 0.6)))
  B:reload(body1, 0.95)
  for j = 0, n do
    local s = (j / n - 0.5) * W * 0.95
    B:stroke({{bx + vx*s - ux*4, by + vy*s - uy*4}, {x + ux*L*0.4 + vx*s*0.8, y + uy*L*0.4 + vy*s*0.8}},
      {pressure={0.85, 0.7}, clip=m})
    if j % 2 == 1 then B:reload(body1, 0.9) end
  end
  -- the convex turn toward the light: mid tone arc, then sheen arc
  B:reload(body2, 0.8)
  B:stroke(tipArc(x, y, ux, uy, L, W, 0.7, 1, 9), {pressure={0.6, 0.6}, clip=m})
  B:reload(body3, 0.7)
  B:stroke(tipArc(x, y, ux, uy, L, W, 0.84, 2, 8), {pressure={0.4, 0.4}, swell={0.5, 1.2, 0.5}, clip=m})
  -- lip
  local LB = brush{kind="round", width=clamp(1.2 * e + 1.2, 2, 5), point=0.5}
  LB:reload(lipp, 0.85)
  LB:stroke(tipArc(x, y, ux, uy, L, W, 0.965, 1 + math.floor(hsh(x, y) * 2), 9 - math.floor(hsh(y, x) * 2)),
    {pressure={0.25 + 0.35 * lit, 0.25 + 0.35 * lit}, swell={0.4, 1.3, 0.5}, clip=m})
  return m
end
local count = 0
for i = I0, I1 do
  local x, y, ux, uy, L, W, e, t = geom3(i)
  if x > -L and x < 1000 + L and y > -L and y < 625 + L then
    local tone = clamp(math.floor(6.3 - (e - 0.9) * 1.9 + (hsh(i, 6) - 0.5) * 1.6), 1, 6)
    local lit = clamp(1.4 - (e - 0.9) * 0.8, 0.1, 1)
    local ta = math.atan(y - CY, x - CX)
    local infected = (ta > -0.62 and ta < 1.15 and e < 1.85)
    plate3(x, y, ux, uy, L, W, e, tone, lit, false, nil)
    if infected and DOINV then
      local sev = clamp((1.85 - e) / 0.8, 0, 1) * clamp(1 - math.abs(ta - 0.28) / 0.9, 0, 1)
      if sev > 0.1 then
        local a = math.atan(uy, ux) + math.pi/2 + (hsh(i, 7) - 0.5) * 1.0
        local off = (0.45 - sev) * L * 0.9
        local side = (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1
        local hp = halfp(x + ux*off, y + uy*off, a, side)
        plate3(x, y, ux, uy, L, W, e, tone, lit, true, hp)
      end
    end
    count = count + 1
  end
end
print(count)

--@ chunk 48
wait(3*24*60)
print(drying(200, 300), drying(700, 150), drying(900, 550))
-- depth: the near plates, toward the frame, sink into a dark glaze graded by distance from the breach
local DG = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}, medium=0.75}
local zone = mask(function(x, y) return clamp((ed(x, y) - 1.55) / 0.9, 0, 1) end) * NOTF
work(zone, {hand="glaze", pile=DG, coverage=1.6, clip=zone,
  load_at=function(x, y) return 0.25 + 0.6 * clamp((ed(x, y) - 1.55) / 1.2, 0, 1) end})
blend(zone, {})

--@ chunk 49
wait(24*60)
local n = 0
for i = 0, 118 do
  local x, y, ux, uy, L, W, e, t = geom3(i)
  local ta = math.atan(y - CY, x - CX)
  if ta > -0.62 and ta < 1.15 and e < 1.85 then
    local sev = clamp((1.85 - e) / 0.8, 0, 1) * clamp(1 - math.abs(ta - 0.28) / 0.9, 0, 1)
    if sev > 0.1 then
      local a = math.atan(uy, ux) + math.pi/2 + (hsh(i, 7) - 0.5) * 1.0
      local off = (0.45 - sev) * L * 0.9
      local side = (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1
      local hp = halfp(x + ux*off, y + uy*off, a, side)
      local lit = clamp(1.4 - (e - 0.9) * 0.8, 0.1, 1)
      plate3(x, y, ux, uy, L, W, e, 4, lit, true, hp)
      -- the cut itself: a hard cold seam along the straight line, on the plate
      local m = pmask3(x, y, ux, uy, L, W) * NOTF
      local cx0, cy0 = x + ux*off, y + uy*off
      local ca, sa = math.cos(a), math.sin(a)
      RIG:reload(COLDL, 0.7)
      RIG:stroke({{cx0 - ca*L, cy0 - sa*L}, {cx0 + ca*L, cy0 + sa*L}}, {pressure={0.3, 0.3}, clip=m})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 50
wait(2*24*60)
-- patina in the crevices, windows along each plate's curve
local VB = brush("filbert", 4)
local WINL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.9}}
local WCORE = pile{{"lead white",3},{"lemon chrome",0.7}}
local nl = 0
for i = 0, 118 do
  local x, y, ux, uy, L, W, e, t = geom3(i)
  if x > -L and x < 1000 + L and y > -L and y < 625 + L then
    local ta = math.atan(y - CY, x - CX)
    local infected = (ta > -0.62 and ta < 1.15 and e < 1.85)
    local m = pmask3(x, y, ux, uy, L, W) * NOTF
    local hp = nil
    if infected then
      local sev = clamp((1.85 - e) / 0.8, 0, 1) * clamp(1 - math.abs(ta - 0.28) / 0.9, 0, 1)
      if sev > 0.1 then
        local a = math.atan(uy, ux) + math.pi/2 + (hsh(i, 7) - 0.5) * 1.0
        local off = (0.45 - sev) * L * 0.9
        local side = (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1
        hp = halfp(x + ux*off, y + uy*off, a, side)
      end
    end
    -- verdigris lodged in the crevice under this plate's free edge (bronze plates only)
    if not infected then
      local arc = tipArc(x, y, ux, uy, L, W, 1.06, 1, 9)
      VB:reload(VERD, 0.3)
      for k = 2, #arc - 1, 2 do
        if hsh(i, 20 + k) < 0.55 then
          local p = arc[k]
          VB:stroke({{p[1], p[2]}, {p[1] + uy * 5, p[2] - ux * 5}}, {pressure={0.35, 0.15}, clip=-pmask3(x, y, ux, uy, L, W)})
        end
      end
    end
    -- windows: one row on smaller plates, two on the big near ones
    if e > 1.05 then
      local rows = e > 1.7 and {0.58, 0.36} or {0.55}
      local wb = brush{kind="filbert", width=1.2 * e, stiffness=0.6}
      for ri, f in ipairs(rows) do
        local arc = tipArc(x, y, ux, uy, L, W, f, 1, 9)
        local k = 1.0 + hsh(i, 30 + ri) * 0.6
        local q = 0
        while k < #arc do
          local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
          local fr = k - math.floor(k)
          local px, py = lerp(a[1], b[1], fr), lerp(a[2], b[2], fr)
          local hl = 2.0 * e
          local inside = hp and hp:at(px, py) > 0.5
          local lit = hsh(i * 7 + ri, q) < (inside and 0.45 or (0.16 + 0.12 * (2.4 - e)))
          if inside then
            wb:reload(lit and INVW or INVC, 0.85)
          else
            wb:reload(HOLE, 0.85)
          end
          wb:stroke({{px - ux*hl, py - uy*hl}, {px + ux*hl, py + uy*hl}}, {pressure={0.7, 0.7}, clip=m})
          if lit and not inside then
            wb:reload(WINL, 0.9)
            wb:stroke({{px - ux*hl*0.6, py - uy*hl*0.6}, {px + ux*hl*0.6, py + uy*hl*0.6}}, {pressure={0.55, 0.55}, clip=m})
            nl = nl + 1
          end
          k = k + 0.6 + hsh(i, 40 + q) * 0.55
          q = q + 1
        end
      end
    end
  end
end
print("lit", nl)

--@ chunk 51
-- shards: the same plate, inside out, broken off and falling toward the sun, smaller and turned each time
local R = BREACH:shrink(8) - FIGS
local seeds = {{715, 235, 34}, {730, 320, 32}, {690, 395, 30}, {650, 190, 22}, {680, 285, 24}, {640, 420, 20}}
for si, s0 in ipairs(seeds) do
  local x, y, L = s0[1], s0[2], s0[3]
  for k = 1, 3 do
    local dx, dy = SX - x, SY - y
    local l = math.sqrt(dx*dx + dy*dy)
    local ux, uy = dx / l, dy / l
    local tw = 0.5 * k * (si % 2 == 0 and 1 or -1)
    local rux, ruy = ux*math.cos(tw) - uy*math.sin(tw), ux*math.sin(tw) + uy*math.cos(tw)
    local a = math.atan(ruy, rux) + math.pi/2 + (hsh(si, k) - 0.5)
    local hp = halfp(x, y, a, (k % 2 == 0) and 1 or -1)
    plate3(x, y, rux, ruy, L, L * 1.18, 1.0, 3, 0.8, true, hp * R)
    x, y = x + ux * L * 0.9, y + uy * L * 0.9
    L = L * 0.66
  end
end
-- the lattice again, over the opened sector only, warped as it nears the hole
local zone = mask(function(x, y)
  local e = ed(x, y)
  local ta = math.atan(y - CY, x - CX)
  local a = clamp(1 - math.abs(ta - 0.25) / 1.0, 0, 1)
  local r = clamp((2.1 - e) / 0.7, 0, 1) * clamp((e - 0.85) / 0.2, 0, 1)
  return a * r
end):blur(10) * NOTF
local lb = brush{kind="rigger", width=1.5, point=0.9}
local rot = 0.18
local c, s = math.cos(rot), math.sin(rot)
local function warp(x, y)
  local e = ed(x, y)
  local k = clamp(1.6 - e, 0, 1); k = k * k
  local a = 0.9 * k
  local dx, dy = x - CX, y - CY
  local ca, sa = math.cos(a), math.sin(a)
  return CX + (dx*ca - dy*sa) * (1 - 0.25*k), CY + (dx*sa + dy*ca) * (1 - 0.25*k)
end
for dir = 0, 1 do
  for j = -12, 12 do
    local pts = {}
    for t = -20, 20 do
      local u, v = t * 22, j * 36
      if dir == 1 then u, v = v, u end
      local x, y = 760 + u*c - v*s, 330 + u*s + v*c
      local wx, wy = warp(x, y)
      pts[#pts+1] = {wx, wy}
    end
    lb:reload(LAT, 0.6)
    lb:stroke(pts, {pressure={0.28, 0.28}, clip=zone})
  end
end

--@ chunk 52
wait(2*24*60)
local DOPAT=false
-- patina in the crevices, windows along each plate's curve
local VB = brush("filbert", 4)
local WINL = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.9}}
local WCORE = pile{{"lead white",3},{"lemon chrome",0.7}}
local nl = 0
for i = 0, 118 do
  local x, y, ux, uy, L, W, e, t = geom3(i)
  if x > -L and x < 1000 + L and y > -L and y < 625 + L then
    local ta = math.atan(y - CY, x - CX)
    local infected = (ta > -0.62 and ta < 1.15 and e < 1.85)
    local m = pmask3(x, y, ux, uy, L, W) * NOTF
    local hp = nil
    if infected then
      local sev = clamp((1.85 - e) / 0.8, 0, 1) * clamp(1 - math.abs(ta - 0.28) / 0.9, 0, 1)
      if sev > 0.1 then
        local a = math.atan(uy, ux) + math.pi/2 + (hsh(i, 7) - 0.5) * 1.0
        local off = (0.45 - sev) * L * 0.9
        local side = (math.cos(a)*uy - math.sin(a)*ux) > 0 and 1 or -1
        hp = halfp(x + ux*off, y + uy*off, a, side)
      end
    end
    -- verdigris lodged in the crevice under this plate's free edge (bronze plates only)
    if not infected and DOPAT then
      local arc = tipArc(x, y, ux, uy, L, W, 1.06, 1, 9)
      VB:reload(VERD, 0.3)
      for k = 2, #arc - 1, 2 do
        if hsh(i, 20 + k) < 0.55 then
          local p = arc[k]
          VB:stroke({{p[1], p[2]}, {p[1] + uy * 5, p[2] - ux * 5}}, {pressure={0.35, 0.15}, clip=-pmask3(x, y, ux, uy, L, W)})
        end
      end
    end
    -- windows: one row on smaller plates, two on the big near ones
    if e > 1.05 then
      local rows = e > 1.7 and {0.58, 0.36} or {0.55}
      local wb = brush{kind="filbert", width=1.2 * e, stiffness=0.6}
      for ri, f in ipairs(rows) do
        local arc = tipArc(x, y, ux, uy, L, W, f, 1, 9)
        local k = 1.0 + hsh(i, 30 + ri) * 0.6
        local q = 0
        while k < #arc do
          local a, b = arc[math.floor(k)], arc[math.min(#arc, math.floor(k) + 1)]
          local fr = k - math.floor(k)
          local px, py = lerp(a[1], b[1], fr), lerp(a[2], b[2], fr)
          local hl = 2.0 * e
          local inside = hp and hp:at(px, py) > 0.5
          local lit = hsh(i * 7 + ri, q) < (inside and 0.45 or (0.16 + 0.12 * (2.4 - e)))
          if lit and not inside then
            wb:reload(WINL, 0.9)
            wb:stroke({{px - ux*hl*0.6, py - uy*hl*0.6}, {px + ux*hl*0.6, py + uy*hl*0.6}}, {pressure={0.6, 0.6}, clip=m})
            local cb = brush{kind="round", width=0.8 * e, point=0.3}
            cb:reload(WCORE, 0.9)
            cb:touch(px, py, {pressure=0.5, clip=m})
            nl = nl + 1
          end
          k = k + 0.6 + hsh(i, 40 + q) * 0.55
          q = q + 1
        end
      end
    end
  end
end
print("lit", nl)

--@ chunk 53
-- motion: spiral streaks pulled down into the sun, lighter in the deep zones, deeper in the pale
local function dd(x, y) return math.sqrt(((x-SX)/215)^2 + ((y-SY)/170)^2) end
local R = BREACH:shrink(40) - FIGS - ellipse(SX, SY, 15, 15)
local spiral = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.32 end
local inner = mask(function(x, y) local e = dd(x, y); return (e < 0.4) and 1 or 0 end) * R
local outer = mask(function(x, y) local e = dd(x, y); return (e >= 0.4 and e < 0.85) and 1 or 0 end) * R
work(inner, {hand="body", tool="filbert 3", pile=DEEP[2], coverage=0.35, angle=spiral, clip=R, length={30, 70}, pressure={0.25, 0.5}, load=0.5})
work(outer, {hand="body", tool="filbert 3", pile=DEEP[5], coverage=0.3, angle=spiral, clip=R, length={40, 90}, pressure={0.2, 0.45}, load=0.45})
-- the black sun restated, with its white limb
work(ellipse(SX, SY, 11.5, 11.5), {hand="detail", pile=INKD, coverage=4, fill=true, clip=true})
local rb = brush{kind="round", width=2.0, point=0.4}
local ring = {}
for k = 0, 40 do local a = k/40*2*math.pi; ring[#ring+1] = {SX + 13.2*math.cos(a), SY + 13.2*math.sin(a)} end
rb:reload(pile{{"zinc white",5},{"cerulean blue",0.15}}, 0.9)
rb:stroke(ring, {pressure={0.5, 0.5}})

--@ chunk 54
local R = BREACH:shrink(42) - FIGS - ellipse(SX, SY, 16, 16)
local spiral = function(x, y) return math.atan(y-SY, x-SX) + math.pi/2 + 0.32 end
blend(R, {angle=spiral})

--@ chunk 55
local m = BREACH:shrink(42) - FIGS
print(lose(m, {pile=DEEP[3], where=0.8, tool="filbert 4", reach={14, 10}, load=0.25}))

--@ chunk 56
wait(2*24*60)
work(S1 + S2 + WM, {hand="detail", pile=WD, coverage=4, fill=true, clip=true})
local rb = brush{kind="round", width=1.4, point=0.4}
rb:reload(WD, 0.9)
rb:stroke({{386.5, 391}, {386, 360}, {385.6, 333}}, {pressure={0.6, 0.55}})
