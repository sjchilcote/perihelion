-- easel session "tesseract": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=1.25, linen={18,17}, seed=44,
  ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=80, apply="knife", texture=0.25},
          {pile={{"raw sienna",1},{"bone black",1},{"lead white",2},{"ultramarine ash",1}}, um=35, apply="brush"}}}
-- room coordinates: the room as seen from its own doorway fills 0..1000 x 0..800
RB = {290, 220, 710, 540}          -- back wall
DOOR = {400, 380, 600, 540}        -- back door (same 1.25 aspect as the room)
LD = {{120, 392}, {220, 385}, {220, 603}, {120, 692}}   -- left side door
RD = {{780, 385}, {885, 393}, {885, 694}, {780, 603}}   -- right side door
-- value ladders, light to dark, one per depth step
FLOOR = {
  pile{{"lead white",3},{"yellow ochre",0.6},{"ultramarine ash",0.5}},
  pile{{"lead white",2},{"yellow ochre",0.6},{"ultramarine ash",0.8},{"raw sienna",0.3}},
  pile{{"lead white",1.2},{"ultramarine ash",1},{"raw sienna",0.6},{"bone black",0.15}},
}
WALL = {
  pile{{"raw sienna",2},{"yellow ochre",1},{"bone black",0.5},{"ultramarine ash",0.8},{"lead white",0.6}},
  pile{{"raw sienna",2},{"bone black",0.8},{"ultramarine ash",1},{"lead white",0.4}},
  pile{{"burnt sienna",1},{"bone black",1},{"ultramarine ash",1.2},{"lead white",0.3}},
}
BACKW = {
  pile{{"raw sienna",2},{"yellow ochre",1.4},{"lead white",1},{"ultramarine ash",0.6}},
  pile{{"raw sienna",2},{"yellow ochre",0.8},{"lead white",0.7},{"ultramarine ash",1},{"bone black",0.3}},
  pile{{"raw sienna",1.5},{"ultramarine ash",1.2},{"bone black",0.6},{"lead white",0.5}},
}
CEIL = {
  pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}},
  pile{{"Mars brown",2},{"ultramarine blue",1.2},{"bone black",1.2}},
  pile{{"bone black",2},{"ultramarine blue",1},{"Mars brown",1}},
}
VOID = pile{{"bone black",2},{"ultramarine blue",1.2},{"Mars brown",0.5}}
INKB = pile{{"bone black",1.5},{"burnt sienna",1},{"ultramarine blue",0.6}}
BONEL = pile{{"lead white",4},{"yellow ochre",0.5},{"ultramarine ash",0.2}}
COLDR = pile{{"zinc white",4},{"cerulean blue",0.5}}
FIG = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
-- a transform: room point -> canvas point
function Tmake(cx, cy, s, rot)
  local c, sn = math.cos(rot), math.sin(rot)
  return function(u, v)
    local du, dv = (u - 500) * s, (v - 400) * s
    return cx + du*c - dv*sn, cy + du*sn + dv*c
  end
end
function tp(T, pts)
  local o = {}
  for _, p in ipairs(pts) do local x, y = T(p[1], p[2]); o[#o+1] = {x, y} end
  return o
end
function rectp(r) return {{r[1], r[2]}, {r[3], r[2]}, {r[3], r[4]}, {r[1], r[4]}} end
-- bilinear point on the floor (a across 0..1, b depth 0 near .. 1 far)
function floorPt(a, b)
  local x0 = lerp(0, 290, b); local x1 = lerp(1000, 710, b)
  return lerp(x0, x1, a), lerp(800, 540, b)
end
print("ok")

--@ chunk 2
FACES = {
  ceil = {{0,0},{1000,0},{710,220},{290,220}},
  left = {{0,0},{290,220},{290,540},{0,800}},
  right = {{1000,0},{710,220},{710,540},{1000,800}},
  floor = {{0,800},{1000,800},{710,540},{290,540}},
  back = rectp(RB),
}
function seg(T, a, b, pile_, w, pr)
  local br = brush{kind="round", width=w, point=0.5}
  br:reload(pile_, 0.8)
  local x1, y1 = T(a[1], a[2]); local x2, y2 = T(b[1], b[2])
  return br, {{x1, y1}, {x2, y2}}
end
function line(T, a, b, pile_, w, pr, clip)
  local br, pts = seg(T, a, b, pile_, w, pr)
  br:stroke(pts, {pressure={pr, pr}, clip=clip})
end
function figure(T, s, fu, fv, h, side, clip)
  local function P(du, dv) local x, y = T(fu + du*h, fv - dv*h); return {x, y} end
  local o = body_of{spine={P(0,1), P(0,0.92), P(0,0.86), P(0,0.78), P(0.01,0.55), P(0.0,0.3), P(0.02,0.0)},
    widths={0.13*h*s, 0.1*h*s, 0.08*h*s, (side and 0.17 or 0.26)*h*s, (side and 0.15 or 0.2)*h*s, (side and 0.12 or 0.18)*h*s, (side and 0.1 or 0.16)*h*s},
    limbs={{P(side and 0.06 or -0.13, 0.78), P(side and 0.16 or -0.15, 0.6), P(side and 0.2 or -0.14, 0.47), widths={0.06*h*s, 0.05*h*s, 0.05*h*s}}},
    blend=0.8, char="firm", amount=0.25}
  local m = o:mask() * clip
  work(m, {hand="detail", pile=FIG, coverage=4, fill=true, clip=true})
end
function glyph(T, s, addr, clip, d)
  local function F(a, b) local x, y = floorPt(a, b); return {x, y} end
  local sq = {{0.32,0.2},{0.68,0.2},{0.68,0.78},{0.32,0.78}}
  local w = math.max(0.8, 5 * s)
  for k = 1, 4 do
    local a, b = sq[k], sq[k % 4 + 1]
    line(T, F(a[1], a[2]), F(b[1], b[2]), INKB, w, 0.4, clip)
    if addr[k] == 1 then
      -- the edge tick: a notch outward from the mid-edge
      local ma, mb = (a[1]+b[1])/2, (a[2]+b[2])/2
      local na, nb = (ma - 0.5) * 0.35, (mb - 0.49) * 0.35
      line(T, F(ma, mb), F(ma + na, mb + nb), INKB, w * 1.3, 0.6, clip)
    end
  end
  -- the inset: a smaller copy, turned by the deck's twist
  local rot = 0.35
  local pts = {}
  for k = 1, 4 do
    local a, b = sq[k][1] - 0.5, sq[k][2] - 0.49
    a, b = a * 0.5, b * 0.5
    local ra, rb = a*math.cos(rot) - b*math.sin(rot), a*math.sin(rot) + b*math.cos(rot)
    pts[k] = F(0.5 + ra, 0.49 + rb)
  end
  for k = 1, 4 do line(T, pts[k], pts[k % 4 + 1], INKB, w * 0.8, 0.35, clip) end
end
function paintRoom(T, s, rot, depth, clip, addr, fig)
  local d = math.min(3, depth + 1)
  local hand = (s > 0.5) and "body" or "detail"
  local function face(pts, p, ang)
    local m = poly(tp(T, pts)) * clip
    if m:area() > 3 then work(m, {hand=hand, pile=p, coverage=2.6, fill=true, clip=true, angle=ang}) end
  end
  face(FACES.ceil, CEIL[d], rot)
  face(FACES.left, WALL[d], rot + 1.2)
  face(FACES.right, WALL[d], rot - 1.2)
  face(FACES.floor, FLOOR[d], rot)
  face(FACES.back, BACKW[d], rot + math.pi/2)
  -- door voids
  for _, q in ipairs({rectp(DOOR), LD, RD}) do
    local m = poly(tp(T, q)) * clip
    if m:area() > 2 then work(m, {hand="detail", pile=VOID, coverage=3, fill=true, clip=true}) end
  end
  -- exact cold edges: the room's own corners
  local w = math.max(0.7, 3.2 * s)
  for _, e in ipairs({{{0,0},{290,220}}, {{1000,0},{710,220}}, {{0,800},{290,540}}, {{1000,800},{710,540}}}) do
    line(T, e[1], e[2], COLDR, w, 0.35, clip)
  end
  local r = rectp(RB)
  for k = 1, 4 do line(T, r[k], r[k % 4 + 1], COLDR, w, 0.35, clip) end
  -- bone door frames
  for _, q in ipairs({rectp(DOOR), LD, RD}) do
    for k = 1, 4 do line(T, q[k], q[k % 4 + 1], BONEL, w * 1.6, 0.5, clip) end
  end
  if s > 0.03 then glyph(T, s, addr, clip, d) end
  if fig then figure(T, s, fig[1], fig[2], fig[3], fig[4], clip) end
end
function flip(addr, k) local a = {addr[1], addr[2], addr[3], addr[4]}; a[k] = 1 - a[k]; return a end
-- the deck: our room, its back door, its side doors, recursing
function deck(T, s, rot, depth, clip, addr)
  local fig = nil
  if depth == 1 then fig = {520, 735, 235, false} end
  if depth == 2 then fig = {420, 720, 235, true} end
  paintRoom(T, s, rot, depth, clip, addr, fig)
  if s * 200 > 6 then
    local cx, cy = T(500, 460)
    local clipB = poly(tp(T, rectp(DOOR))) * clip
    deck(Tmake(cx, cy, s * 0.2, rot + 0.22), s * 0.2, rot + 0.22, depth + 1, clipB, flip(addr, 1))
  end
  if depth <= 1 and s > 0.15 then
    local lx, ly = T(170, 540)
    local clipL = poly(tp(T, LD)) * clip
    local sl = s * 0.4
    if depth == 0 then
      local TL = Tmake(lx, ly, sl, rot - 0.3)
      paintRoom(TL, sl, rot - 0.3, 1, clipL, flip(addr, 2), {460, 720, 235, true})
      local cx, cy = TL(500, 460)
      deck(Tmake(cx, cy, sl * 0.2, rot - 0.3 + 0.22), sl * 0.2, rot - 0.08, 2, poly(tp(TL, rectp(DOOR))) * clipL, flip(flip(addr, 2), 1))
      local rx, ry = T(832, 540)
      local clipR = poly(tp(T, RD)) * clip
      local TR = Tmake(rx, ry, sl, rot + 0.3)
      paintRoom(TR, sl, rot + 0.3, 1, clipR, flip(addr, 3), {560, 730, 235, false})
      local cx2, cy2 = TR(500, 460)
      deck(Tmake(cx2, cy2, sl * 0.2, rot + 0.52), sl * 0.2, rot + 0.52, 2, poly(tp(TR, rectp(DOOR))) * clipR, flip(flip(addr, 3), 1))
    end
  end
end
deck(Tmake(500, 400, 1, 0), 1, 0, 0, everywhere(), {0, 0, 0, 0})

--@ chunk 3
wait(2*24*60)
print(drying(100, 300), drying(500, 700), drying(500, 300))
local T = Tmake(500, 400, 1, 0)
local doors = poly(LD) + poly(RD) + poly(rectp(DOOR))
local GW = pile{{"bone black",1},{"ultramarine ash",1},{"raw sienna",0.6},{"ultramarine blue",0.3}, medium=0.75}
local GF = pile{{"ultramarine ash",1},{"raw sienna",0.5},{"bone black",0.3},{"lead white",0.3}, medium=0.75}
local GB = pile{{"bone black",1},{"ultramarine ash",1.2},{"raw sienna",0.5}, medium=0.78}
local function near(x, y) -- 1 at the frame, 0 at the back wall
  local dx = math.abs(x - 500) / 500; local dy = math.abs(y - 400) / 400
  return clamp((math.max(dx, dy) - 0.3) / 0.7, 0, 1)
end
local walls = (poly(FACES.left) + poly(FACES.right)) - doors
work(walls, {hand="glaze", pile=GW, coverage=1.8, clip=walls, load_at=function(x, y) return 0.35 + 0.55 * near(x, y) end})
blend(walls:shrink(2), {})
local fl = poly(FACES.floor)
work(fl, {hand="glaze", pile=GF, coverage=1.4, clip=fl, load_at=function(x, y) return 0.15 + 0.5 * near(x, y) end})
blend(fl:shrink(2), {angle=0})
local bk = poly(FACES.back) - doors
work(bk, {hand="glaze", pile=GB, coverage=1.4, clip=bk, load_at=function(x, y) return 0.2 + 0.4 * clamp((380 - y) / 160, 0, 1) end})
blend(bk:shrink(2), {})

--@ chunk 4
local T = Tmake(500, 400, 1, 0)
local doors = poly(LD) + poly(RD) + poly(rectp(DOOR))
local WD2 = pile{{"raw sienna",1},{"bone black",1},{"ultramarine ash",1.2},{"lead white",0.45}}
local FL2 = pile{{"lead white",2},{"ultramarine ash",1},{"yellow ochre",0.3},{"raw sienna",0.1}}
local BK2 = pile{{"raw sienna",2},{"yellow ochre",0.5},{"lead white",0.6},{"ultramarine ash",1.1},{"bone black",0.35}}
local walls = (poly(FACES.left) + poly(FACES.right)) - doors
work(poly(FACES.left) - doors, {hand="body", pile=WD2, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(poly(FACES.right) - doors, {hand="body", pile=WD2, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(poly(FACES.floor), {hand="body", pile=FL2, coverage=3, fill=true, clip=true, angle=0})
work(poly(FACES.back) - doors, {hand="body", pile=BK2, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- exact cold edges, bone frames, the floor's address
local all = everywhere()
for _, e in ipairs({{{0,0},{290,220}}, {{1000,0},{710,220}}, {{0,800},{290,540}}, {{1000,800},{710,540}}}) do
  line(T, e[1], e[2], COLDR, 3.2, 0.4, all)
end
local r = rectp(RB)
for k = 1, 4 do line(T, r[k], r[k % 4 + 1], COLDR, 3.2, 0.4, all) end
for _, q in ipairs({rectp(DOOR), LD, RD}) do
  for k = 1, 4 do line(T, q[k], q[k % 4 + 1], BONEL, 5, 0.5, all) end
end
glyph(T, 1, {0, 0, 0, 0}, all, 1)
-- fold notation above the back door: the room-glyph with three bridges to itself and a turned inset
local gx, gy, gs = 500, 300, 34
local sq = {{gx-gs, gy-gs*0.8}, {gx+gs, gy-gs*0.8}, {gx+gs, gy+gs*0.8}, {gx-gs, gy+gs*0.8}}
for k = 1, 4 do line(T, sq[k], sq[k % 4 + 1], BONEL, 3, 0.5, all) end
local rot = 0.22
local ins = {}
for k = 1, 4 do
  local dx, dy = (sq[k][1] - gx) * 0.618, (sq[k][2] - gy) * 0.618
  ins[k] = {gx + dx*math.cos(rot) - dy*math.sin(rot), gy + dx*math.sin(rot) + dy*math.cos(rot)}
end
for k = 1, 4 do line(T, ins[k], ins[k % 4 + 1], BONEL, 2.2, 0.45, all) end
local ab = brush{kind="round", width=2.4, point=0.5}
for _, arc in ipairs({{{gx-gs, gy}, {gx-gs-30, gy-40}, {gx, gy-gs*0.8-30}, {gx, gy-gs*0.8}},
                      {{gx+gs, gy}, {gx+gs+30, gy+40}, {gx, gy+gs*0.8+28}, {gx, gy+gs*0.8}}}) do
  ab:reload(BONEL, 0.8)
  ab:stroke(arc, {pressure={0.45, 0.45}})
end

--@ chunk 5
-- SECOND PASS: one light, the floor address glowing cold; everything falls off from it
local GX, GY = 500, 660
local function dist(x, y) return math.sqrt(((x - GX) / 1.0)^2 + ((y - GY) * 1.6)^2) end
local doors = poly(LD) + poly(RD) + poly(rectp(DOOR))
local T = Tmake(500, 400, 1, 0)
local all = everywhere()
-- floor in four bands, lit near the glyph, dark toward the walls and the near edge
local FB = {
  pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.35},{"ultramarine ash",0.3}},
  pile{{"lead white",2},{"ultramarine ash",1},{"cerulean blue",0.2},{"yellow ochre",0.2}},
  pile{{"lead white",1},{"ultramarine ash",1.2},{"raw sienna",0.5},{"bone black",0.2}},
  pile{{"ultramarine ash",1},{"raw sienna",0.8},{"bone black",0.6},{"lead white",0.4}},
}
local edges = {0, 120, 220, 330, 9999}
local fl = poly(FACES.floor)
for k = 1, 4 do
  local band = mask(function(x, y) local d = dist(x, y); return (d >= edges[k] and d < edges[k+1]) and 1 or 0 end):soften(10) * fl
  work(band, {hand="body", pile=FB[k], coverage=2.6, fill=true, clip=fl, angle=0})
end
blend(fl:shrink(3), {angle=0})
-- walls: cold light rising from the floor near the doors' feet, dark above and toward us
local WL = pile{{"zinc white",2},{"cerulean blue",0.4},{"ultramarine ash",1},{"raw sienna",0.4}, medium=0.3}
local walls = (poly(FACES.left) + poly(FACES.right) + poly(FACES.back)) - doors
local lit = mask(function(x, y) return clamp(1 - dist(x, y) / 430, 0, 1) end) * walls
work(lit, {hand="scumble", pile=WL, coverage=1.3, clip=walls, load_at=function(x, y) return 0.05 + 0.4 * clamp(1 - dist(x, y) / 430, 0, 1) end, pressure={0.15, 0.35}})
local DK = pile{{"bone black",1.4},{"ultramarine ash",1},{"raw sienna",0.5}}
local far = mask(function(x, y) return clamp((dist(x, y) - 380) / 250, 0, 1) end) * walls
work(far, {hand="scumble", pile=DK, coverage=1.3, clip=walls, load_at=function(x, y) return 0.1 + 0.45 * clamp((dist(x, y) - 380) / 250, 0, 1) end, pressure={0.2, 0.4}})
-- plate seams on the walls: courses converging on the vanishing point, each with a lit lower lip
local sb = brush{kind="rigger", width=1.6, point=0.8}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.5}}
local function wallLine(side, h, d0, d1)
  local pts = {}
  for j = 0, 8 do
    local d = lerp(d0, d1, j / 8)
    local x = side < 0 and 290 * d or 1000 - 290 * d
    local xx = side < 0 and x or 1000 - x
    local top = 0.7586 * xx; local bot = 800 - 0.8966 * xx
    pts[#pts+1] = {x, lerp(top, bot, h)}
  end
  return pts
end
for _, side in ipairs({-1, 1}) do
  for _, h in ipairs({0.14, 0.31, 0.5, 0.72, 0.88}) do
    sb:reload(SEAM, 0.7)
    sb:stroke(wallLine(side, h + 0.012 * side, 0.02, 0.99), {pressure={0.35, 0.2}, clip=-doors})
    sb:reload(COLDR, 0.5)
    sb:stroke(wallLine(side, h + 0.012 * side + 0.008, 0.02, 0.99), {pressure={0.15, 0.1}, clip=-doors})
  end
  -- vertical joints, unevenly spaced
  for _, d in ipairs({0.13, 0.29, 0.41, 0.63, 0.84}) do
    local p = wallLine(side, 0, d, d)[1]; local q = wallLine(side, 1, d, d)[1]
    sb:reload(SEAM, 0.7)
    sb:stroke({p, q}, {pressure={0.3, 0.2}, clip=-doors})
  end
  -- a fold-notation inlay on each wall, bone, in the wall's perspective
  local function W(d, h) return wallLine(side, h, d, d)[1] end
  local cx, cy, s = side < 0 and 0.52 or 0.48, 0.22, 0.09
  local q = {W(cx - s, cy - s*0.9), W(cx + s, cy - s*0.9), W(cx + s, cy + s*0.9), W(cx - s, cy + s*0.9)}
  for k = 1, 4 do line(T, q[k], q[k % 4 + 1], BONEL, 2.4, 0.5, all) end
  local q2 = {W(cx - s*0.5, cy - s*0.3), W(cx + s*0.3, cy - s*0.55), W(cx + s*0.5, cy + s*0.35), W(cx - s*0.3, cy + s*0.55)}
  for k = 1, 4 do line(T, q2[k], q2[k % 4 + 1], BONEL, 1.8, 0.45, all) end
end
-- the address glows: cold white on the glyph
glyph(T, 1, {0, 0, 0, 0}, all, 1)
local gb = brush{kind="round", width=2.4, point=0.5}
local function F(a, b) local x, y = floorPt(a, b); return {x, y} end
gb:reload(pile{{"zinc white",5},{"cerulean blue",0.2}}, 0.9)
gb:stroke({F(0.32,0.2), F(0.68,0.2), F(0.68,0.78), F(0.32,0.78), F(0.32,0.2)}, {pressure={0.3, 0.3}})
-- restate the cold room edges
for _, e in ipairs({{{0,0},{290,220}}, {{1000,0},{710,220}}, {{0,800},{290,540}}, {{1000,800},{710,540}}}) do
  line(T, e[1], e[2], COLDR, 3.0, 0.35, all)
end
-- the Commando in the three near rooms: dark armour again, a cold edge from the glow
FIG2 = pile{{"bone black",2},{"ultramarine blue",0.8},{"burnt sienna",0.3}}
local function fig2(Tf, s, f, clip)
  local fu, fv, h, side = f[1], f[2], f[3], f[4]
  local function P(du, dv) local x, y = Tf(fu + du*h, fv - dv*h); return {x, y} end
  local o = body_of{spine={P(0,1), P(0,0.92), P(0,0.86), P(0,0.78), P(0.01,0.55), P(0.0,0.3), P(0.02,0.0)},
    widths={0.13*h*s, 0.1*h*s, 0.08*h*s, (side and 0.17 or 0.26)*h*s, (side and 0.15 or 0.2)*h*s, (side and 0.12 or 0.18)*h*s, (side and 0.1 or 0.16)*h*s},
    limbs={{P(side and 0.06 or -0.13, 0.78), P(side and 0.16 or -0.15, 0.6), P(side and 0.2 or -0.14, 0.47), widths={0.06*h*s, 0.05*h*s, 0.05*h*s}}},
    blend=0.8, char="firm", amount=0.25}
  local m = o:mask() * clip
  work(m, {hand="detail", pile=FIG2, coverage=4, fill=true, clip=true})
  local rimm = (m:grow(1.1) - m) * clip
  work(rimm, {hand="detail", pile=COLDR, coverage=1.5, fill=true, clip=true})
end
fig2(Tmake(500, 460, 0.2, 0.22), 0.2, {520, 735, 235, false}, poly(rectp(DOOR)))
fig2(Tmake(170, 540, 0.4, -0.3), 0.4, {460, 720, 235, true}, poly(LD))
fig2(Tmake(832, 540, 0.4, 0.3), 0.4, {560, 730, 235, false}, poly(RD))

--@ chunk 6
local GX, GY = 500, 660
local function dist(x, y) return math.sqrt(((x - GX) / 1.0)^2 + ((y - GY) * 1.6)^2) end
local doors = poly(LD) + poly(RD) + poly(rectp(DOOR))
local T = Tmake(500, 400, 1, 0)
local all = everywhere()
local walls = (poly(FACES.left) + poly(FACES.right) + poly(FACES.back)) - doors
local D1 = pile{{"raw sienna",1},{"bone black",1.3},{"ultramarine ash",1},{"lead white",0.2}}
local D2 = pile{{"raw sienna",1.2},{"bone black",0.9},{"ultramarine ash",1},{"lead white",0.45}}
local b2 = mask(function(x, y) local d = dist(x, y); return (d >= 330 and d < 430) and 1 or 0 end):soften(8) * walls
local b1 = mask(function(x, y) return dist(x, y) >= 430 and 1 or 0 end):soften(8) * walls
work(b2, {hand="body", pile=D2, coverage=3, fill=true, clip=walls, angle=math.pi/2})
work(b1, {hand="body", pile=D1, coverage=3, fill=true, clip=walls, angle=math.pi/2})
-- plate seams on the walls: courses converging on the vanishing point, each with a lit lower lip
local sb = brush{kind="rigger", width=1.6, point=0.8}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.5}}
local function wallLine(side, h, d0, d1)
  local pts = {}
  for j = 0, 8 do
    local d = lerp(d0, d1, j / 8)
    local x = side < 0 and 290 * d or 1000 - 290 * d
    local xx = side < 0 and x or 1000 - x
    local top = 0.7586 * xx; local bot = 800 - 0.8966 * xx
    pts[#pts+1] = {x, lerp(top, bot, h)}
  end
  return pts
end
for _, side in ipairs({-1, 1}) do
  for _, h in ipairs({0.14, 0.31, 0.5, 0.72, 0.88}) do
    sb:reload(SEAM, 0.7)
    sb:stroke(wallLine(side, h + 0.012 * side, 0.02, 0.99), {pressure={0.35, 0.2}, clip=-doors})
    sb:reload(COLDR, 0.5)
    sb:stroke(wallLine(side, h + 0.012 * side + 0.008, 0.02, 0.99), {pressure={0.15, 0.1}, clip=-doors})
  end
  -- vertical joints, unevenly spaced
  for _, d in ipairs({0.13, 0.29, 0.41, 0.63, 0.84}) do
    local p = wallLine(side, 0, d, d)[1]; local q = wallLine(side, 1, d, d)[1]
    sb:reload(SEAM, 0.7)
    sb:stroke({p, q}, {pressure={0.3, 0.2}, clip=-doors})
  end
  -- a fold-notation inlay on each wall, bone, in the wall's perspective
  local function W(d, h) return wallLine(side, h, d, d)[1] end
  local cx, cy, s = side < 0 and 0.52 or 0.48, 0.22, 0.09
  local q = {W(cx - s, cy - s*0.9), W(cx + s, cy - s*0.9), W(cx + s, cy + s*0.9), W(cx - s, cy + s*0.9)}
  for k = 1, 4 do line(T, q[k], q[k % 4 + 1], BONEL, 2.4, 0.5, all) end
  local q2 = {W(cx - s*0.5, cy - s*0.3), W(cx + s*0.3, cy - s*0.55), W(cx + s*0.5, cy + s*0.35), W(cx - s*0.3, cy + s*0.55)}
  for k = 1, 4 do line(T, q2[k], q2[k % 4 + 1], BONEL, 1.8, 0.45, all) end
end
