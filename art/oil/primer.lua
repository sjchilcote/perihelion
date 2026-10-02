-- easel session "primer": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen={22,20}, seed=1137,
  ground={{pile={{"raw sienna",2},{"burnt sienna",1},{"bone black",1}}, um=120, apply="knife", texture=0.3}}}

-- geometry
CX, CY = 500, 500
GA = math.rad(137.507764)
MED = {}
local rads = {62, 70, 74, 78, 82, 88, 95, 84}
for n = 1, 8 do
  local a = n * GA - math.pi/2
  local r = 118 * math.sqrt(n)
  MED[n] = {x = CX + r*math.cos(a), y = CY + r*math.sin(a), r = rads[n]}
end

P_dark  = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
P_mid   = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
P_lit   = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}

-- the tablet field: mid bronze, worked in broad then body
local field = rect(0,0,1000,1000)
work(field, {hand="broad", pile=P_mid, coverage=3, fill=true, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end})
print(wait(10))

--@ chunk 2
local frame = rect(0,0,1000,1000) - rect(46,46,908,908)
work(frame, {hand="body", pile=P_dark, coverage=3, fill=true, clip=true, angle=function(x,y) if math.abs(x-500) > math.abs(y-500) then return math.pi/2 else return 0 end end})
local wells = nil
for n = 1, 7 do
  local e = ellipse(MED[n].x, MED[n].y, MED[n].r, MED[n].r)
  wells = wells and (wells + e) or e
end
work(wells, {hand="body", pile=P_dark, coverage=3.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-CY, x-CX) end})
local boss = ellipse(CX, CY, 38, 38)
work(boss, {hand="body", pile=P_lit, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end})
print(wait(3*24*60))

--@ chunk 3
P_groove = pile{{"bone black",2},{"burnt sienna",1}}
P_bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
P_shine = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1.2}}

function in_well(x, y, pad)
  for n = 1, 8 do
    local m = MED[n]
    if (x-m.x)^2 + (y-m.y)^2 < (m.r + pad)^2 then return true end
  end
  if (x-CX)^2 + (y-CY)^2 < (38+pad)^2 then return true end
  return false
end

-- stroke a circle arc in pieces, skipping wells; returns pieces drawn
function ring(b, pl, cx, cy, r, opts)
  opts = opts or {}
  local pad = opts.pad or 6
  local step = 2 / r * 6
  local runs, cur = {}, nil
  local a = opts.a0 or 0
  local a1 = opts.a1 or 2*math.pi
  while a <= a1 do
    local x, y = cx + r*math.cos(a), cy + r*math.sin(a)
    if not in_well(x, y, pad) then
      cur = cur or {}
      cur[#cur+1] = {x, y}
      if #cur > 16 then runs[#runs+1] = cur; cur = {{x, y}} end
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end
      cur = nil
    end
    a = a + step
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  for _, run in ipairs(runs) do
    if b:fullness() < 0.4 then b:reload(pl, 0.9) end
    b:stroke(run, {pressure={opts.p or 0.7, opts.p or 0.7}, ramps={0.05,0.05}})
  end
  return #runs
end

local g = brush{kind="round", width=2.6, point=0}
g:load(P_groove, 0.9)
local hl = brush{kind="round", width=1.6, point=0}
hl:load(P_shine, 0.8)
for n = 1, 8 do
  local r = 118 * math.sqrt(n)
  ring(g, P_groove, CX, CY, r, {pad=7})
end
-- outer limb: a double groove
ring(g, P_groove, CX, CY, 405, {pad=7})
ring(g, P_groove, CX, CY, 418, {pad=7})
print(wait(60))

--@ chunk 4
function arcpts(cx, cy, r, a0, a1, n)
  n = n or math.max(4, math.floor(math.abs(a1-a0) * r / 5))
  local t = {}
  for i = 0, n do
    local a = a0 + (a1-a0) * i / n
    t[#t+1] = {cx + r*math.cos(a), cy + r*math.sin(a)}
  end
  return t
end
function sline(b, pl, pts, p, w)
  if b:fullness() < 0.55 then b:reload(pl, 0.95) end
  b:stroke(pts, {pressure={p or 0.75, p or 0.75}, ramps={0.02,0.02}})
end

-- restate rings as continuous grooves (overlapping runs)
local g = brush{kind="round", width=2.6, point=0}
g:load(P_groove, 0.95)
local function ring2(r)
  local step = 6 / r
  local a, cur = 0, nil
  local runs = {}
  while a <= 2*math.pi + step do
    local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
    if not in_well(x, y, 7) then
      cur = cur or {}
      cur[#cur+1] = {x, y}
      if #cur > 10 then runs[#runs+1] = cur; cur = {cur[#cur-1], cur[#cur]} end
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end
      cur = nil
    end
    a = a + step
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  for _, run in ipairs(runs) do sline(g, P_groove, run, 0.75) end
end
for n = 1, 8 do ring2(118 * math.sqrt(n)) end
ring2(405); ring2(418)

-- well bevels: light from upper left. Shadowed inner wall upper-left, lit wall lower-right.
local d = brush{kind="round", width=4, point=0}
local l = brush{kind="round", width=2.2, point=0}
d:load(P_groove, 0.9); l:load(P_shine, 0.9)
for n = 1, 7 do
  local m = MED[n]
  sline(d, P_groove, arcpts(m.x, m.y, m.r - 2.5, math.rad(120), math.rad(330)), 0.8)
  sline(l, P_shine, arcpts(m.x, m.y, m.r - 1.5, math.rad(-30), math.rad(110)), 0.6)
  -- outer lip catching light on the upper-left
  sline(l, P_shine, arcpts(m.x, m.y, m.r + 2, math.rad(160), math.rad(290)), 0.45)
end
-- boss rim
sline(d, P_groove, arcpts(CX, CY, 39, math.rad(-20), math.rad(120)), 0.7)
print(wait(24*60))

--@ chunk 5
-- glyph helpers (bone inlay)
BONE_W = 2.4
function place(local_pts, cx, cy, s, rot, flip)
  local out = {}
  local c, sn = math.cos(rot or 0), math.sin(rot or 0)
  for i, p in ipairs(local_pts) do
    local x, y = p[1] * s, p[2] * s
    if flip then x = -x end
    out[i] = {cx + x*c - y*sn, cy + x*sn + y*c}
  end
  return out
end
BB = brush{kind="round", width=BONE_W, point=0}
BB:load(P_bone, 0.95)
function bseg(x1, y1, x2, y2, p)
  if BB:fullness() < 0.6 then BB:reload(P_bone, 0.95) end
  BB:stroke({{x1, y1}, {x2, y2}}, {pressure={p or 0.8, p or 0.8}, ramps={0.0, 0.0}})
end
function bpath(pts, p)
  if BB:fullness() < 0.6 then BB:reload(P_bone, 0.95) end
  BB:stroke(pts, {pressure={p or 0.8, p or 0.8}, ramps={0.0, 0.0}})
end
-- room outline, edge by edge (corners stay corners)
function room_out(pts, p)
  local n = #pts
  for i = 1, n do
    local a, b = pts[i], pts[i % n + 1]
    -- overrun a hair at each end so corners close
    local dx, dy = b[1]-a[1], b[2]-a[2]
    local L = math.sqrt(dx*dx+dy*dy)
    local ux, uy = dx/L, dy/L
    bseg(a[1]-ux*0.6, a[2]-uy*0.6, b[1]+ux*0.6, b[2]+uy*0.6, p)
  end
end
-- solid inset
function room_solid(pts)
  work(poly(pts), {hand="detail", pile=P_bone, coverage=3, fill=true, clip=true})
end
-- point on edge i at fraction t, and its outward normal (pts are clockwise on screen => outside is left of travel? computed vs centroid)
function edge_at(pts, i, t)
  local n = #pts
  local a, b = pts[i], pts[i % n + 1]
  local x, y = lerp(a[1], b[1], t), lerp(a[2], b[2], t)
  local cx, cy = 0, 0
  for _, p in ipairs(pts) do cx = cx + p[1]/n; cy = cy + p[2]/n end
  local dx, dy = b[1]-a[1], b[2]-a[2]
  local L = math.sqrt(dx*dx+dy*dy)
  local nx, ny = -dy/L, dx/L
  if (x-cx)*nx + (y-cy)*ny < 0 then nx, ny = -nx, -ny end
  return x, y, nx, ny, dx/L, dy/L
end
-- notches: count k on edge i, golden-gap spaced around the edge midpoint, each with a chevron pointing along the edge direction
PHI = 0.6180339887
function notches(pts, i, k, len, dir)
  len = len or 6
  dir = dir or 1
  local offs = {0}
  local gap = 0.16
  if k > 1 then
    offs = {}
    local t = 0
    for j = 1, k do offs[j] = t; t = t + gap * (PHI ^ (j-1)) end
    local mid = t / 2 - gap * (PHI ^ (k-1)) / 2
    for j = 1, k do offs[j] = offs[j] - mid end
  end
  for j = 1, k do
    local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5 + offs[j])
    bseg(x + nx*1.0, y + ny*1.0, x + nx*len, y + ny*len, 0.7)
  end
  -- chevron at the outer end of the last notch: the edge's direction
  local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5 + offs[k])
  local tx, ty = x + nx*len, y + ny*len
  ux, uy = ux*dir, uy*dir
  bseg(tx - ux*3 + nx*2.2, ty - uy*3 + ny*2.2, tx + ux*0.5, ty + uy*0.5, 0.55)
  bseg(tx - ux*3 - nx*2.2, ty - uy*3 - ny*2.2, tx + ux*0.5, ty + uy*0.5, 0.55)
end
function notch_pt(pts, i, len)
  local x, y, nx, ny = edge_at(pts, i, 0.5)
  return x + nx*(len or 6), y + ny*(len or 6), nx, ny
end
-- a bridge: a bowed arc between two points, bulging by 'bow' (signed, units)
function bridge(x1, y1, x2, y2, bow, p)
  local mx, my = (x1+x2)/2, (y1+y2)/2
  local dx, dy = x2-x1, y2-y1
  local L = math.sqrt(dx*dx+dy*dy)
  local nx, ny = -dy/L, dx/L
  local pts = {}
  for i = 0, 16 do
    local t = i/16
    local b = 4*t*(1-t)*bow
    pts[#pts+1] = {lerp(x1, x2, t) + nx*b, lerp(y1, y2, t) + ny*b}
  end
  bpath(pts, p or 0.75)
end

-- LESSON 1: a room-glyph and its notches
local m = MED[1]
local R1 = {{-26,-20},{14,-24},{30,0},{18,24},{-24,18}}
local g1 = place(R1, m.x, m.y + 2, 1.15, 0.12)
room_out(g1)
notches(g1, 1, 1)
notches(g1, 3, 2)
notches(g1, 4, 3)

-- LESSON 2: a bridge between two rooms
m = MED[2]
local RA = {{-15,-15},{15,-15},{15,15},{-15,15}}
local RB = {{-7,-26},{7,-26},{7,26},{-7,26}}
local ga = place(RA, m.x - 26, m.y + 12, 1.0, 0.0)
local gb = place(RB, m.x + 30, m.y - 4, 1.0, 0.0)
room_out(ga); room_out(gb)
notches(ga, 1, 1); notches(gb, 4, 1, 6, -1)
local x1, y1 = notch_pt(ga, 1, 7)
local x2, y2 = notch_pt(gb, 4, 7)
-- bridge goes up and over from the square's top notch to the corridor's left notch
bridge(x1, y1 - 1, x2 - 1, y2, -16)
print(wait(30))

--@ chunk 6
function notches2(pts, i, k, dir)
  local len = 9
  local offs = {0}
  if k > 1 then
    offs = {}
    local t, gap = 0, 0.2
    for j = 1, k do offs[j] = t; if j < k then t = t + gap * (PHI ^ (j-1)) end end
    for j = 1, k do offs[j] = offs[j] - t/2 end
  end
  for j = 1, k do
    local x, y, nx, ny = edge_at(pts, i, 0.5 + offs[j])
    bseg(x + nx*1.2, y + ny*1.2, x + nx*len, y + ny*len, 0.7)
  end
  local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5 + offs[k])
  local tx, ty = x + nx*len, y + ny*len
  ux, uy = ux*(dir or 1), uy*(dir or 1)
  bseg(tx - ux*4.5 + nx*3.2, ty - uy*4.5 + ny*3.2, tx + ux*0.8, ty + uy*0.8, 0.55)
  bseg(tx - ux*4.5 - nx*3.2, ty - uy*4.5 - ny*3.2, tx + ux*0.8, ty + uy*0.8, 0.55)
end
function selfbridge(pts, i, j, bow)
  local x1, y1 = notch_pt(pts, i, 9)
  local x2, y2 = notch_pt(pts, j, 9)
  bridge(x1, y1, x2, y2, bow)
end

-- LESSON 3: a quiet loop, inset upright
local m = MED[3]
local R3 = {{-30,-22},{26,-26},{32,20},{-26,24}}
local g3 = place(R3, m.x - 6, m.y + 8, 1.15, 0)
room_out(g3)
notches2(g3, 1, 1); notches2(g3, 2, 2, -1)
selfbridge(g3, 1, 2, -22)
room_solid(place(R3, m.x - 6, m.y + 8, 1.15 * PHI, 0))

-- LESSON 4: a twisted loop, inset turned a quarter
m = MED[4]
local R4 = {{-34,-14},{20,-26},{34,16},{-22,22}}
local c4x, c4y = m.x + 4, m.y - 4
local g4 = place(R4, c4x, c4y, 1.15, 0)
room_out(g4)
notches2(g4, 3, 1); notches2(g4, 4, 3, -1)
selfbridge(g4, 3, 4, 22)
room_solid(place(R4, c4x, c4y, 1.15 * PHI, math.pi/2))

-- LESSON 5: a mirror join. Room, bar, and the reflected inset outlined beyond the bar.
m = MED[5]
local R5 = {{-22,-24},{14,-18},{22,10},{2,26},{-24,14}}
local c5x, c5y = m.x - 22, m.y + 6
local g5 = place(R5, c5x, c5y, 1.1, 0)
room_out(g5)
notches2(g5, 2, 2); notches2(g5, 1, 1)
selfbridge(g5, 1, 2, -20)
-- the bar
local bx = m.x + 14
bseg(bx, m.y - 34, bx, m.y + 40, 1.0)
bseg(bx + 2.2, m.y - 34, bx + 2.2, m.y + 40, 1.0)
-- reflected inset, outlined, far side of the bar
room_out(place(R5, bx + 26, c5y + 2, 1.1 * PHI, 0, true), 0.6)
print(wait(30))

--@ chunk 7
-- LESSON 6: recursion, a corridor spiralling into itself by the golden angle
local m = MED[6]
local px, py = m.x + 4, m.y + 6
local RC = {{-42,-9},{42,-9},{42,9},{-42,9}}
local th0 = math.rad(-100)
for k = 0, 5 do
  local s = PHI ^ k
  local th = th0 + k * GA
  local rho = 54 * s
  local pts = place(RC, px + rho*math.cos(th), py + rho*math.sin(th), s, th + math.pi/2)
  if k == 0 then
    room_out(pts)
    notches2(pts, 2, 1); notches2(pts, 4, 1, -1)
  else
    room_solid(pts)
  end
end
-- the dot it ends in
work(ellipse(px, py, 2.2, 2.2), {hand="detail", pile=P_bone, coverage=3, fill=true, clip=true})

-- LESSON 7: the fold. Six petals around a heart, placed by the golden angle.
m = MED[7]
local hx, hy = m.x, m.y
local HEX = {}
for i = 0, 5 do HEX[#HEX+1] = {15*math.cos(i*math.pi/3), 15*math.sin(i*math.pi/3)} end
local heart = place(HEX, hx, hy, 1, 0)
room_out(heart)
room_solid(place(HEX, hx, hy, PHI, 0))
local PET = {{-11,-9},{9,-11},{13,4},{0,13},{-12,6}}
local angs = {}
for k = 0, 5 do angs[#angs+1] = (k * GA - math.pi/2) % (2*math.pi) end
table.sort(angs)
PETALS = {}
for k, a in ipairs(angs) do
  local px2, py2 = hx + 60*math.cos(a), hy + 60*math.sin(a)
  local pts = place(PET, px2, py2, 1.0, a + math.pi/2)
  room_out(pts)
  room_solid(place(HEX, px2, py2, 0.30, 0))  -- the heart, inset in every petal
  -- bridge to the heart: petal inner side to heart rim
  bseg(px2 - 15*math.cos(a), py2 - 15*math.sin(a), hx + 19*math.cos(a), hy + 19*math.sin(a), 0.7)
  PETALS[k] = {x = px2, y = py2, a = a}
end
-- bridges between neighbours, along the ring
for k = 1, 6 do
  local A, B = PETALS[k], PETALS[k % 6 + 1]
  local a0, a1 = A.a, B.a
  if a1 < a0 then a1 = a1 + 2*math.pi end
  local da = 15 / 60
  if a1 - a0 > 2*da + 0.12 then
    bpath(arcpts(hx, hy, 72, a0 + da*0.9, a1 - da*0.9), 0.7)
  end
end
print(wait(30))

--@ chunk 8
-- lesson 6: a fine scribed guide of the golden spiral through the insets
local m = MED[6]
local px, py = m.x + 4, m.y + 6
local sp = {}
local th0 = math.rad(-100)
for i = 0, 120 do
  local t = i / 120 * 5.6
  local th = th0 + t * GA
  local rho = 54 * PHI ^ t
  sp[#sp+1] = {px + rho*math.cos(th), py + rho*math.sin(th)}
end
local sb = brush{kind="round", width=1.2, point=0}
sb:load(P_mid, 0.9)
for i = 1, #sp - 1, 10 do
  local seg = {}
  for j = i, math.min(i + 10, #sp) do seg[#seg+1] = sp[j] end
  if sb:fullness() < 0.6 then sb:reload(P_mid, 0.9) end
  sb:stroke(seg, {pressure={0.6, 0.6}, ramps={0,0}})
end

-- THE BREACH: the eighth slot, chiselled out
local B = MED[8]
local rr = {54, 61, 47, 58, 50, 63, 45, 56, 60, 49, 57}
local gp = {}
for i = 1, #rr do
  local a = (i - 1) / #rr * 2*math.pi + 0.3
  gp[#gp+1] = {B.x + rr[i]*math.cos(a), B.y + rr[i]*math.sin(a)}
end
GOUGE = poly(gp):roughen(3, 14, 7)
P_void = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
work(GOUGE, {hand="body", pile=P_void, coverage=4, fill=true, clip=true, tool="filbert 5", angle=math.rad(-35)})

-- rings near the slot run on to the cut and stop there
local g = brush{kind="round", width=2.6, point=0}
g:load(P_groove, 0.95)
local cang = math.atan(B.y - CY, B.x - CX)
for _, r in ipairs({118*math.sqrt(6), 118*math.sqrt(7), 118*math.sqrt(8), 405, 418}) do
  local runs, cur = {}, nil
  local step = 4 / r
  for a = cang - 0.45, cang + 0.45, step do
    local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
    local inside = GOUGE:at(x, y) > 0.2 or (x-B.x)^2 + (y-B.y)^2 < 50^2
    local nearw = false
    for n = 1, 7 do if (x-MED[n].x)^2 + (y-MED[n].y)^2 < (MED[n].r+7)^2 then nearw = true end end
    if not inside and not nearw then
      cur = cur or {}; cur[#cur+1] = {x, y}
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end; cur = nil
    end
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  for _, run in ipairs(runs) do sline(g, P_groove, run, 0.75) end
end

-- the last bridge: out of the fold, round the plate, into the cut
local A = PETALS[1]
for k = 1, 6 do if math.abs(PETALS[k].a - math.rad(237.5)) < 0.1 then A = PETALS[k] end end
local sx, sy = A.x + 15*math.cos(A.a), A.y + 15*math.sin(A.a)
local sa = math.atan(sy - CY, sx - CX) % (2*math.pi)
local sr = math.sqrt((sx-CX)^2 + (sy-CY)^2)
local ea = cang % (2*math.pi)
local path = {}
local N = 160
for i = 0, N do
  local t = i / N
  local a = lerp(sa, ea, t)
  local r = 365
  if t < 0.12 then r = lerp(sr, 365, smoothstep(0, 0.12, t)) end
  local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
  if GOUGE:at(x, y) > 0.05 then break end
  path[#path+1] = {x, y}
end
LONGB = path
for i = 1, #path - 1, 9 do
  local seg = {}
  for j = i, math.min(i + 10, #path) do seg[#seg+1] = path[j] end
  bpath(seg, 0.8)
end
print(#path, wait(24*60))

--@ chunk 9
local B = MED[8]
local rr = {54, 61, 47, 58, 50, 63, 45, 56, 60, 49, 57}
local inner_k = {0.62, 0.7, 0.58, 0.66, 0.72, 0.6, 0.68, 0.64, 0.57, 0.7, 0.63}
local outer, inner = {}, {}
for i = 1, #rr do
  local a = (i - 1) / #rr * 2*math.pi + 0.3
  outer[i] = {B.x + (rr[i]+1)*math.cos(a), B.y + (rr[i]+1)*math.sin(a), a}
  inner[i] = {B.x + rr[i]*inner_k[i]*math.cos(a + 0.12) + 4, B.y + rr[i]*inner_k[i]*math.sin(a + 0.12) + 3}
end
local P_wall_lit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}
local P_wall_mid = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.5}}
local P_wall_dk  = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.5}}
for i = 1, #rr do
  local j = i % #rr + 1
  local q = poly({{outer[i][1], outer[i][2]}, {outer[j][1], outer[j][2]}, inner[j], inner[i]})
  local am = (outer[i][3] + outer[j][3]) / 2
  -- a wall faces the light (upper left) when it lies on the lower right of the cut
  local facing = math.cos(am - math.rad(45))
  local pl = facing > 0.45 and P_wall_lit or (facing > -0.2 and P_wall_mid or P_wall_dk)
  work(q * GOUGE:grow(2), {hand="detail", pile=pl, coverage=3, fill=true, clip=true, angle=am})
end
-- a bright burr where the cut breaks the polished face, on its lit lower-right lip
local l = brush{kind="round", width=1.8, point=0}
l:load(P_shine, 0.9)
local pts = {}
for i = 1, #rr do
  local a = outer[i][3]
  if math.cos(a - math.rad(45)) > 0.2 then pts[#pts+1] = {outer[i][1], outer[i][2]} end
end
for i = 1, #pts - 1 do sline(l, P_shine, {pts[i], pts[i+1]}, 0.55) end
print(wait(24*60))

--@ chunk 10
print(wait(2*24*60))
local B = MED[8]
-- floor of the cut: warm black, rough, with a colder hollow in its deepest part
local P_floor = pile{{"bone black",3},{"burnt sienna",1},{"ultramarine blue",0.4}}
local floor = poly({{B.x-22,B.y-30},{B.x+12,B.y-26},{B.x+26,B.y-4},{B.x+18,B.y+22},{B.x-8,B.y+28},{B.x-28,B.y+8}}):roughen(4, 10, 3)
work(floor * GOUGE, {hand="body", tool="filbert 4", pile=P_floor, coverage=3, fill=true, clip=true, angle=math.rad(-40)})
-- chisel marks: short parallel cuts over the walls, a different direction on each side
local walls = GOUGE - floor:shrink(2)
local P_cut_l = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.5}}
local P_cut_d = pile{{"bone black",2},{"raw sienna",1}}
local lit = walls * mask(function(x, y) return ((x-B.x) + (y-B.y)) > 4 and 1 or 0 end)
local dk  = walls * mask(function(x, y) return ((x-B.x) + (y-B.y)) < -4 and 1 or 0 end)
work(lit, {hand="hatch", pile=P_cut_l, coverage=1.4, clip=true, angle=math.rad(-50), length={4, 9}, load=0.6})
work(dk,  {hand="hatch", pile=P_cut_d, coverage=1.6, clip=true, angle=math.rad(30), length={4, 9}, load=0.7})
-- remnants: inlay that ran into the cut and was cut off with it
local frag = {
  {{B.x-70, B.y+18}, {B.x-50, B.y+14}},
  {{B.x+30, B.y+62}, {B.x+22, B.y+44}},
  {{B.x+66, B.y-10}, {B.x+52, B.y-16}},
  {{B.x-30, B.y-70}, {B.x-24, B.y-52}},
}
for _, f in ipairs(frag) do bseg(f[1][1], f[1][2], f[2][1], f[2][2], 0.75) end
print(wait(60))

--@ chunk 11
print(wait(3*24*60))
local B = MED[8]
-- paint out the radial fragments with the plate's own bronze
local fb = brush{kind="round", width=6, point=0}
fb:load(P_mid, 0.95)
local frag = {
  {{B.x-72, B.y+18}, {B.x-48, B.y+14}},
  {{B.x+31, B.y+64}, {B.x+21, B.y+42}},
  {{B.x+68, B.y-10}, {B.x+50, B.y-17}},
  {{B.x-31, B.y-72}, {B.x-23, B.y-50}},
}
for _, f in ipairs(frag) do
  fb:reload(P_mid, 0.95)
  fb:stroke(f, {pressure={0.85, 0.85}, ramps={0,0}})
  fb:stroke({f[2], f[1]}, {pressure={0.85, 0.85}, ramps={0,0}})
end
-- the cut: a deep warm-black floor, a narrow lit wall lower right, a shadowed wall upper left
local P_floor2 = pile{{"bone black",3},{"burnt sienna",1},{"raw sienna",0.5}}
local inner = GOUGE:shrink(7)
work(inner, {hand="body", tool="filbert 5", pile=P_floor2, coverage=4, fill=true, clip=true, angle=math.rad(-40), load=1})
local band = GOUGE - inner
local litside = mask(function(x, y) return ((x-B.x) + (y-B.y)) > 0 and 1 or 0 end):blur(10)
work(band * litside, {hand="detail", pile=pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",0.6}}, coverage=3, fill=true, clip=true})
work(band * (-litside), {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",1}}, coverage=3, fill=true, clip=true})
print(wait(60))

--@ chunk 12
-- boss: the seed-head, a Vogel spiral of bone seeds (golden angle)
local seeds = nil
for k = 1, 34 do
  local r = 5.6 * math.sqrt(k)
  local a = k * GA
  local s = ellipse(CX + r*math.cos(a), CY + r*math.sin(a), 1.7 + 0.03*k, 1.7 + 0.03*k)
  seeds = seeds and (seeds + s) or s
end
work(seeds, {hand="detail", pile=P_bone, coverage=3, fill=true, clip=true})

-- lesson counts: n seeds outside each well, on the outward side, in a short row along its ring
local cnt = nil
for n = 1, 7 do
  local m = MED[n]
  local ang = math.atan(m.y - CY, m.x - CX)
  local rr = math.sqrt((m.x-CX)^2 + (m.y-CY)^2) + m.r + 13
  local step = 8 / rr
  for j = 1, n do
    local a = ang + (j - (n+1)/2) * step
    local s = ellipse(CX + rr*math.cos(a), CY + rr*math.sin(a), 2.2, 2.2)
    cnt = cnt and (cnt + s) or s
  end
end
work(cnt, {hand="detail", pile=P_bone, coverage=3, fill=true, clip=true})

-- the frame: two bone fillets inlaid along the inner edge of the border
local function fillet(i)
  bseg(i, i, 1000-i, i, 0.8); bseg(1000-i, i, 1000-i, 1000-i, 0.8)
  bseg(1000-i, 1000-i, i, 1000-i, 0.8); bseg(i, 1000-i, i, i, 0.8)
end
fillet(50); fillet(56); fillet(22)
print(wait(60))

--@ chunk 13
local function segline(x1, y1, x2, y2, p)
  local L = math.sqrt((x2-x1)^2 + (y2-y1)^2)
  local n = math.ceil(L / 70)
  for i = 0, n-1 do
    local t0, t1 = i/n, math.min(1, (i+1)/n + 0.01)
    BB:reload(P_bone, 0.95)
    BB:stroke({{lerp(x1,x2,t0), lerp(y1,y2,t0)}, {lerp(x1,x2,t1), lerp(y1,y2,t1)}}, {pressure={p,p}, ramps={0,0}})
  end
end
for _, i in ipairs({22, 50, 56}) do
  segline(i, i, 1000-i, i, 0.8); segline(1000-i, i, 1000-i, 1000-i, 0.8)
  segline(1000-i, 1000-i, i, 1000-i, 0.8); segline(i, 1000-i, i, i, 0.8)
end
-- field mask for later wear passes
local wells = ellipse(CX, CY, 44, 44)
for n = 1, 7 do wells = wells + ellipse(MED[n].x, MED[n].y, MED[n].r + 5, MED[n].r + 5) end
FIELD = rect(62, 62, 876, 876) - wells - GOUGE:grow(5)
-- test polish in the lower right corner of the field
P_polish = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1},{"burnt sienna",0.5}, medium=0.2}
work(FIELD * rect(820, 820, 118, 118), {hand="scumble", pile=P_polish, load=0.15, pressure={0.1, 0.25}, coverage=0.8, clip=true})
print(wait(30))

--@ chunk 14
print(wait(24*60))
work(FIELD * rect(812, 812, 128, 128), {hand="body", pile=P_mid, coverage=3.5, fill=true, clip=true, load=1, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end})
print(wait(2*24*60))
P_glow = pile{{"lead white",2},{"yellow ochre",1},{"Mars yellow",0.5}, medium=0.7}
local test = FIELD * rect(700, 600, 180, 140)
work(test, {hand="glaze", pile=P_glow, load=0.25, pressure={0.1, 0.2}, coverage=1, clip=true})
blend(test, {})
print(wait(30))

--@ chunk 15
print(wait(24*60))
work(FIELD * rect(690, 590, 200, 160), {hand="body", pile=P_mid, coverage=3.5, fill=true, clip=true, load=1, angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end})
print(wait(2*24*60))
-- where the polishing may go: the field, off the grooves, the long bridge and the count seeds
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418
local free = mask(function(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  for _, R in ipairs(RINGS) do if math.abs(r - R) < 4.5 then return 0 end end
  if math.abs(r - 365) < 6 then return 0 end
  return 1
end)
FIELD2 = FIELD * free
local P_m2 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",0.8},{"bone black",0.7}}
local P_m3 = pile{{"raw sienna",2},{"yellow ochre",1.5},{"burnt sienna",0.7},{"bone black",0.35}}
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
-- light falls from the upper left: the face is brighter there and toward the polished centre
local cov2 = function(x, y)
  local t = clamp(((CX - x) + (CY - y)) / 700 + 0.5, 0, 1)
  return 0.4 + 1.2 * t
end
work(FIELD2, {hand="body", pile=P_m2, coverage=1.3, clip=true, angle=ang, length={25, 60}, load_at=function(x,y) return 0.25 + 0.6*clamp(((CX - x) + (CY - y)) / 700 + 0.5, 0, 1) end})
local cov3 = function(x, y)
  local t = clamp(((CX - x) + (CY - y)) / 700 + 0.2, 0, 1)
  local c = clamp(1 - math.sqrt((x-CX)^2 + (y-CY)^2) / 300, 0, 1)
  return 0.9 * t + 0.6 * c
end
work(FIELD2, {hand="body", pile=P_m3, coverage=0.9, clip=true, angle=ang, length={20, 45}, load_at=function(x,y) return 0.1 + 0.6*cov3(x,y) end})
print(wait(30))

--@ chunk 16
blend(FIELD2, {angle=function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end}); print(wait(20))

--@ chunk 17
print(wait(2*24*60))
-- LESSON 4 repair: the self-bridge went inside the room. Clear the room's interior (keeping the inset) and lay the bridge outside.
local m = MED[4]
local R4 = {{-34,-14},{20,-26},{34,16},{-22,22}}
local c4x, c4y = m.x + 4, m.y - 4
local g4 = place(R4, c4x, c4y, 1.15, 0)
local ins = place(R4, c4x, c4y, 1.15 * PHI, math.pi/2)
local clear = poly(g4):shrink(2.8) - poly(ins):grow(1.2)
work(clear, {hand="detail", pile=P_dark, coverage=3.5, fill=true, clip=true})
local x1, y1 = notch_pt(g4, 3, 9)
local x2, y2 = notch_pt(g4, 4, 9)
bridge(x1, y1, x2, y2, -22)

-- the count seeds, restated in bone
local cnt = nil
for n = 1, 7 do
  local mm = MED[n]
  local ang = math.atan(mm.y - CY, mm.x - CX)
  local rr = math.sqrt((mm.x-CX)^2 + (mm.y-CY)^2) + mm.r + 13
  local step = 8 / rr
  for j = 1, n do
    local a = ang + (j - (n+1)/2) * step
    local s = ellipse(CX + rr*math.cos(a), CY + rr*math.sin(a), 2.3, 2.3)
    cnt = cnt and (cnt + s) or s
  end
end
work(cnt, {hand="detail", pile=P_bone, coverage=3.5, fill=true, clip=true})

-- frame corners: a small seed-head rosette in each, its own seeds
local function rosette(cx, cy, k0)
  local s = nil
  for k = 1, 21 do
    local r = 3.4 * math.sqrt(k)
    local a = (k + k0) * GA
    local e = ellipse(cx + r*math.cos(a), cy + r*math.sin(a), 1.25, 1.25)
    s = s and (s + e) or e
  end
  work(s, {hand="detail", pile=P_bone, coverage=3.5, fill=true, clip=true})
end
rosette(36, 36, 0); rosette(964, 36, 3); rosette(964, 964, 5); rosette(36, 964, 8)
print(wait(30))

--@ chunk 18
P_verd = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418; RINGS[#RINGS+1] = 365
local chan = mask(function(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  for _, R in ipairs(RINGS) do if math.abs(r - R) < 4 then return 1 end end
  return 0
end)
-- keep the bone bridge clean
local lb = ribbon(LONGB, 6)
local where = (chan * FIELD) - lb
-- the gouge's rim and the wells' lower lips gather it too
local lips = nil
for n = 1, 7 do
  local e = ellipse(MED[n].x, MED[n].y, MED[n].r + 6, MED[n].r + 6) - ellipse(MED[n].x, MED[n].y, MED[n].r + 1, MED[n].r + 1)
  lips = lips and (lips + e) or e
end
local grim = GOUGE:grow(6) - GOUGE:grow(1)
where = where + (lips - lb) + grim
local nz = noise{seed=41, octaves=4, period=160}
stipple(where, {pile=P_verd, width=2.2, coverage=function(x, y)
  local v = nz:at01(x, y)
  local edge = clamp(((x - CX) + (y - CY)) / 800 + 0.5, 0, 1)  -- more on the shadowed lower right
  return clamp((v - 0.45) * 3, 0, 1) * (0.4 + 0.9 * edge) * 1.4
end, cluster=0.5, feather=0.6, dips={14, 0.6, 0.5}})
print(wait(30))

--@ chunk 19
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418; RINGS[#RINGS+1] = 365
local chan = mask(function(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  for _, R in ipairs(RINGS) do if math.abs(r - R) < 5 then return 1 end end
  return 0
end)
local lips = nil
for n = 1, 7 do
  local e = ellipse(MED[n].x, MED[n].y, MED[n].r + 7, MED[n].r + 7) - ellipse(MED[n].x, MED[n].y, MED[n].r + 1, MED[n].r + 1)
  lips = lips and (lips + e) or e
end
VERDZONE = ((chan * FIELD) + lips + (GOUGE:grow(7) - GOUGE:grow(1))) - ribbon(LONGB, 6)
blend(VERDZONE, {tool={kind="badger", width=8}})
print(wait(30))

--@ chunk 20
print(wait(24*60))
local g = brush{kind="round", width=2.6, point=0}
g:load(P_groove, 0.95)
local function inbox(x, y) return x > 684 and x < 896 and y > 584 and y < 756 end
for _, r in ipairs({118*math.sqrt(4), 118*math.sqrt(5), 118*math.sqrt(6), 118*math.sqrt(7), 118*math.sqrt(8), 405, 418}) do
  local runs, cur = {}, nil
  local step = 4 / r
  for a = 0, math.pi/2 + 0.2, step do
    local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
    if inbox(x, y) and not in_well(x, y, 7) then
      cur = cur or {}; cur[#cur+1] = {x, y}
      if #cur > 10 then runs[#runs+1] = cur; cur = {cur[#cur-1], cur[#cur]} end
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end; cur = nil
    end
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  for _, run in ipairs(runs) do sline(g, P_groove, run, 0.75) end
end
print(wait(30))

--@ chunk 21
print(wait(24*60))
local l = brush{kind="round", width=1.3, point=0}
l:load(P_shine, 0.9)
local function runs_on(r, a0, a1)
  local runs, cur = {}, nil
  local step = 4 / r
  for a = a0, a1, step do
    local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
    if not in_well(x, y, 8) and GOUGE:at(x, y) < 0.05 and x > 64 and x < 936 and y > 64 and y < 936 then
      cur = cur or {}; cur[#cur+1] = {x, y}
      if #cur > 12 then runs[#runs+1] = cur; cur = {cur[#cur-1], cur[#cur]} end
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end; cur = nil
    end
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  return runs
end
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418
for _, R in ipairs(RINGS) do
  -- upper left: the inner wall of the groove catches the light
  for _, run in ipairs(runs_on(R - 2.6, math.rad(170), math.rad(280))) do sline(l, P_shine, run, 0.45) end
  -- lower right: the outer wall
  for _, run in ipairs(runs_on(R + 2.6, math.rad(-10), math.rad(100))) do sline(l, P_shine, run, 0.45) end
end
print(wait(30))

--@ chunk 22
-- the limb: 89 ticks set by the golden angle between the two outer grooves (punctuation, never on one ray)
local t = brush{kind="round", width=1.6, point=0}
t:load(P_groove, 0.95)
local n = 0
for k = 1, 89 do
  local a = k * GA
  local x1, y1 = CX + 408*math.cos(a), CY + 408*math.sin(a)
  local x2, y2 = CX + 415*math.cos(a), CY + 415*math.sin(a)
  if not in_well(x1, y1, 6) and not in_well(x2, y2, 6) and GOUGE:grow(30):at(x1, y1) < 0.05 then
    if t:fullness() < 0.6 then t:reload(P_groove, 0.95) end
    local w = (k % 8 == 0) and 0.85 or 0.6
    t:stroke({{x1, y1}, {x2, y2}}, {pressure={w, w}, ramps={0,0}})
    n = n + 1
  end
end
-- lesson 6: restate the scribed spiral a touch brighter so the insets read as one turning line
local m = MED[6]
local px, py = m.x + 4, m.y + 6
local sp = {}
local th0 = math.rad(-100)
for i = 0, 120 do
  local tt = i / 120 * 5.6
  local th = th0 + tt * GA
  local rho = 54 * PHI ^ tt
  sp[#sp+1] = {px + rho*math.cos(th), py + rho*math.sin(th)}
end
local sb = brush{kind="round", width=1.0, point=0}
sb:load(P_shine, 0.9)
for i = 1, #sp - 1, 10 do
  local seg = {}
  for j = i, math.min(i + 10, #sp) do seg[#seg+1] = sp[j] end
  if sb:fullness() < 0.6 then sb:reload(P_shine, 0.9) end
  sb:stroke(seg, {pressure={0.45, 0.45}, ramps={0,0}})
end
print(n, wait(30))

--@ chunk 23
print(wait(24*60))
local outer = FIELD * mask(function(x, y) return (math.sqrt((x-CX)^2 + (y-CY)^2) > 432) and 1 or 0 end)
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
work(outer, {hand="body", pile=P_mid, coverage=2, clip=true, angle=ang, length={25, 60},
  load_at=function(x, y) local r = math.sqrt((x-CX)^2 + (y-CY)^2); return clamp((r - 432) / 180, 0.1, 0.9) end})
blend(outer, {angle=ang})
print(wait(30))

--@ chunk 24
local B = MED[8]
-- the last bridge runs on to the very lip of the cut
local p1 = LONGB[#LONGB - 2]
local p2 = LONGB[#LONGB]
local dx, dy = p2[1]-p1[1], p2[2]-p1[2]
local L = math.sqrt(dx*dx+dy*dy)
local ex, ey = p2[1], p2[2]
for i = 1, 30 do
  local x, y = p2[1] + dx/L*i, p2[2] + dy/L*i
  if GOUGE:at(x, y) > 0.5 then break end
  ex, ey = x, y
end
bseg(p1[1], p1[2], ex + dx/L*1.5, ey + dy/L*1.5, 0.8)
-- chisel marks on the floor of the cut: short gouges in two sets
local P_chis = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",0.4}}
local c = brush{kind="round", width=1.5, point=0.3}
c:load(P_chis, 0.8)
local fl = GOUGE:shrink(9)
local sets = {{math.rad(-35), 9}, {math.rad(50), 6}}
for _, s in ipairs(sets) do
  local a, cnt = s[1], s[2]
  for i = 1, cnt do
    local x, y = B.x + rand(-28, 28), B.y + rand(-28, 28)
    local l = rand(8, 16)
    local x1, y1 = x - math.cos(a)*l/2, y - math.sin(a)*l/2
    local x2, y2 = x + math.cos(a)*l/2, y + math.sin(a)*l/2
    if fl:at(x1, y1) > 0.5 and fl:at(x2, y2) > 0.5 then
      if c:fullness() < 0.5 then c:reload(P_chis, 0.8) end
      c:stroke({{x1, y1}, {x2, y2}}, {pressure={0.6, 0.2}, ramps={0.1, 0.5}})
    end
  end
end
print(wait(30))

--@ chunk 25
print(wait(24*60))
-- turned-metal sheen: concentric polish throws the light back along a radial wedge toward the lamp and opposite it
local function wedge(halfdeg)
  local h = math.rad(halfdeg)
  return mask(function(x, y)
    local a = math.atan(y - CY, x - CX)
    local d1 = math.abs(((a - math.rad(-135)) + math.pi) % (2*math.pi) - math.pi)
    local d2 = math.abs(((a - math.rad(45)) + math.pi) % (2*math.pi) - math.pi)
    local r = math.sqrt((x-CX)^2 + (y-CY)^2)
    if r < 44 or r > 425 then return 0 end
    return (d1 < h or d2 < h * 0.7) and 1 or 0
  end)
end
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
local P_s1 = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8},{"burnt sienna",0.3}}
local P_s2 = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1.6}}
work(FIELD2 * wedge(15), {hand="body", pile=P_s1, coverage=1.6, clip=true, angle=ang, length={15, 40}, load=0.6})
work(FIELD2 * wedge(6), {hand="body", pile=P_s2, coverage=1.4, clip=true, angle=ang, length={12, 30}, load=0.55})
blend(FIELD2 * wedge(24), {angle=ang})
print(wait(30))

--@ chunk 26
local function wedge(halfdeg)
  local h = math.rad(halfdeg)
  return mask(function(x, y)
    local a = math.atan(y - CY, x - CX)
    local d1 = math.abs(((a - math.rad(-135)) + math.pi) % (2*math.pi) - math.pi)
    local d2 = math.abs(((a - math.rad(45)) + math.pi) % (2*math.pi) - math.pi)
    local r = math.sqrt((x-CX)^2 + (y-CY)^2)
    if r < 44 or r > 425 then return 0 end
    return (d1 < h or d2 < h * 0.7) and 1 or 0
  end)
end
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
local e1 = (wedge(19) - wedge(11)) * FIELD2
local e2 = (wedge(9) - wedge(3)) * FIELD2
blend(e1, {angle=ang, clip=FIELD2})
blend(e2, {angle=ang, clip=FIELD2})
blend(e1, {angle=ang, clip=FIELD2})
print(wait(30))

--@ chunk 27
print(wait(2*24*60))
local cnt = nil
for n = 1, 7 do
  local mm = MED[n]
  local ang = math.atan(mm.y - CY, mm.x - CX)
  local rr = math.sqrt((mm.x-CX)^2 + (mm.y-CY)^2) + mm.r + 13
  local step = 8 / rr
  for j = 1, n do
    local a = ang + (j - (n+1)/2) * step
    local s = ellipse(CX + rr*math.cos(a), CY + rr*math.sin(a), 2.3, 2.3)
    cnt = cnt and (cnt + s) or s
  end
end
work(cnt, {hand="detail", pile=P_bone, coverage=3.5, fill=true, clip=true})
print(wait(30))

--@ chunk 28
local function band(center_deg, half_deg)
  local c, h = math.rad(center_deg), math.rad(half_deg)
  return mask(function(x, y)
    local a = math.atan(y - CY, x - CX)
    local d = math.abs(((a - c) + math.pi) % (2*math.pi) - math.pi)
    local r = math.sqrt((x-CX)^2 + (y-CY)^2)
    if r < 44 or r > 425 then return 0 end
    return d < h and 1 or 0
  end)
end
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
local P_mid_s = pile{{"yellow ochre",2},{"raw sienna",1.5},{"burnt sienna",0.5},{"lead white",0.45},{"bone black",0.12}}
local P_hi_s  = pile{{"yellow ochre",2},{"raw sienna",0.5},{"Mars yellow",0.5},{"lead white",1.2}}
-- outer edges of the sheen
local outer = band(-135-15, 5) + band(-135+15, 5) + band(45-10.5, 4) + band(45+10.5, 4)
local inner = band(-135-6, 3.5) + band(-135+6, 3.5) + band(45-4.2, 2.5) + band(45+4.2, 2.5)
work(FIELD2 * outer, {hand="body", pile=P_mid_s, coverage=1.5, clip=true, angle=ang, length={12, 28}, load=0.55})
work(FIELD2 * inner, {hand="body", pile=P_hi_s, coverage=1.3, clip=true, angle=ang, length={10, 22}, load=0.5})
local wide = band(-135-15, 8) + band(-135+15, 8) + band(45-10.5, 6) + band(45+10.5, 6) + band(-135-6, 5) + band(-135+6, 5) + band(45-4.2, 4) + band(45+4.2, 4)
blend(FIELD2 * wide, {angle=ang})
print(wait(30))

--@ chunk 29
print(wait(24*60))
local function wedge(halfdeg)
  local h = math.rad(halfdeg)
  return mask(function(x, y)
    local a = math.atan(y - CY, x - CX)
    local d1 = math.abs(((a - math.rad(-135)) + math.pi) % (2*math.pi) - math.pi)
    local d2 = math.abs(((a - math.rad(45)) + math.pi) % (2*math.pi) - math.pi)
    local r = math.sqrt((x-CX)^2 + (y-CY)^2)
    if r < 44 or r > 425 then return 0 end
    return (d1 < h or d2 < h * 0.7) and 1 or 0
  end)
end
local P_mid_s = pile{{"yellow ochre",2},{"raw sienna",1.5},{"burnt sienna",0.5},{"lead white",0.45},{"bone black",0.12}}
local m = wedge(15)
-- only along the radial edges, and only where the edge is off the grooves
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418; RINGS[#RINGS+1] = 365
local where = function(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  if r < 60 or r > 418 then return 0 end
  for _, R in ipairs(RINGS) do if math.abs(r - R) < 6 then return 0 end end
  for n = 1, 8 do if (x-MED[n].x)^2 + (y-MED[n].y)^2 < (MED[n].r + 8)^2 then return 0 end end
  if x < 600 or y < 600 then return 0 end
  return 1
end
print(lose(m, {pile=P_mid_s, where=where, reach={12, 12}, load=0.25}))
print(wait(30))

--@ chunk 30
-- SECOND PASS 1: clearer notches on lessons 1 and 2
local function outside_box(pts, i, t0, t1, d0, d1)
  local ax, ay, nx, ny = edge_at(pts, i, t0)
  local bx, by = edge_at(pts, i, t1)
  return poly({{ax+nx*d0, ay+ny*d0}, {bx+nx*d0, by+ny*d0}, {bx+nx*d1, by+ny*d1}, {ax+nx*d1, ay+ny*d1}})
end
local function notches3(pts, i, k, dir, len, gap)
  len = len or 12; gap = gap or 0.26
  local offs, t = {}, 0
  for j = 1, k do offs[j] = t; if j < k then t = t + gap * (PHI ^ (j-1)) end end
  for j = 1, k do offs[j] = offs[j] - t/2 end
  for j = 1, k do
    local x, y, nx, ny = edge_at(pts, i, 0.5 + offs[j])
    bseg(x + nx*1.2, y + ny*1.2, x + nx*len, y + ny*len, 0.72)
  end
  local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5 + offs[k])
  local tx, ty = x + nx*len, y + ny*len
  ux, uy = ux*(dir or 1), uy*(dir or 1)
  bseg(tx - ux*6 + nx*4.5, ty - uy*6 + ny*4.5, tx + ux*1, ty + uy*1, 0.62)
  bseg(tx - ux*6 - nx*4.5, ty - uy*6 - ny*4.5, tx + ux*1, ty + uy*1, 0.62)
end
-- lesson 1: clear the old small notches, lay them again larger
local m = MED[1]
local R1 = {{-26,-20},{14,-24},{30,0},{18,24},{-24,18}}
local g1 = place(R1, m.x, m.y + 2, 1.15, 0.12)
local clr = outside_box(g1, 1, 0.08, 0.92, 2.2, 13) + outside_box(g1, 3, 0.05, 0.95, 2.2, 13) + outside_box(g1, 4, 0.05, 0.95, 2.2, 13)
work(clr * ellipse(m.x, m.y, m.r - 5, m.r - 5), {hand="detail", pile=P_dark, coverage=4, fill=true, clip=true})
print(wait(24*60))
notches3(g1, 1, 1)
notches3(g1, 3, 2)
notches3(g1, 4, 3)
-- lesson 2: clearer chevrons where the bridge lands
m = MED[2]
local RA = {{-15,-15},{15,-15},{15,15},{-15,15}}
local RB = {{-7,-26},{7,-26},{7,26},{-7,26}}
local ga = place(RA, m.x - 26, m.y + 12, 1.0, 0.0)
local gb = place(RB, m.x + 30, m.y - 4, 1.0, 0.0)
for _, e in ipairs({{ga, 1, 1}, {gb, 4, -1}}) do
  local pts, i, dir = e[1], e[2], e[3]
  local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5)
  bseg(x + nx*1.2, y + ny*1.2, x + nx*8, y + ny*8, 0.75)
  local tx, ty = x + nx*8, y + ny*8
  ux, uy = ux*dir, uy*dir
  bseg(tx - ux*5.5 + nx*4.2, ty - uy*5.5 + ny*4.2, tx + ux*1, ty + uy*1, 0.62)
  bseg(tx - ux*5.5 - nx*4.2, ty - uy*5.5 - ny*4.2, tx + ux*1, ty + uy*1, 0.62)
end
print(wait(30))

--@ chunk 31
-- SECOND PASS 2: one continuous turned-metal sheen, all wet at once, drawn together along the turning
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418
FIELDR = FIELD * mask(function(x, y)
  local r = math.sqrt((x-CX)^2 + (y-CY)^2)
  if r < 46 or r > 427 then return 0 end
  for _, R in ipairs(RINGS) do if math.abs(r - R) < 2.1 then return 0 end end
  if math.abs(r - 365) < 4 then return 0 end
  return 1
end)
local function dlight(x, y)
  local a = math.atan(y - CY, x - CX)
  local d1 = math.deg(math.abs(((a - math.rad(-135)) + math.pi) % (2*math.pi) - math.pi))
  local d2 = math.deg(math.abs(((a - math.rad(45)) + math.pi) % (2*math.pi) - math.pi)) / 0.7
  return math.min(d1, d2)
end
local function zone(lo, hi)
  return FIELDR * mask(function(x, y) local d = dlight(x, y); return (d >= lo and d < hi) and 1 or 0 end)
end
local ang = function(x,y) return math.atan(y-CY, x-CX) + math.pi/2 end
local P_m2 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",0.8},{"bone black",0.7}}
local P_m3 = pile{{"raw sienna",2},{"yellow ochre",1.5},{"burnt sienna",0.7},{"bone black",0.35}}
local P_mid_s = pile{{"yellow ochre",2},{"raw sienna",1.5},{"burnt sienna",0.5},{"lead white",0.45},{"bone black",0.12}}
local P_s1 = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8},{"burnt sienna",0.3}}
local P_s2 = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1.6}}
local Z = {{40, 999, P_m2}, {22, 40, P_m3}, {12, 22, P_mid_s}, {5, 12, P_s1}, {0, 5, P_s2}}
for _, z in ipairs(Z) do
  work(zone(z[1], z[2]), {hand="body", pile=z[3], coverage=2.6, fill=true, clip=FIELDR, angle=ang, length={20, 50}, load=0.9})
end
blend(FIELDR, {angle=ang})
print(wait(30))

--@ chunk 32
print(wait(2*24*60))
-- SECOND PASS 3: lips of the wells and the cut repainted plain (the stray specks go under), groove walls restated
local lipz = nil
for n = 1, 7 do
  local e = ellipse(MED[n].x, MED[n].y, MED[n].r + 6.5, MED[n].r + 6.5) - ellipse(MED[n].x, MED[n].y, MED[n].r + 1.2, MED[n].r + 1.2)
  lipz = lipz and (lipz + e) or e
end
lipz = lipz + (GOUGE:grow(6.5) - GOUGE:grow(1.2))
lipz = lipz - ribbon(LONGB, 5)
work(lipz, {hand="detail", pile=P_mid, coverage=3.5, fill=true, clip=true})
print(wait(24*60))
local l = brush{kind="round", width=1.3, point=0}
l:load(P_shine, 0.9)
local d = brush{kind="round", width=1.3, point=0}
d:load(P_groove, 0.9)
local function runs_on(r, a0, a1)
  local runs, cur = {}, nil
  local step = 4 / r
  for a = a0, a1, step do
    local x, y = CX + r*math.cos(a), CY + r*math.sin(a)
    if not in_well(x, y, 8) and GOUGE:at(x, y) < 0.05 and x > 64 and x < 936 and y > 64 and y < 936 then
      cur = cur or {}; cur[#cur+1] = {x, y}
      if #cur > 12 then runs[#runs+1] = cur; cur = {cur[#cur-1], cur[#cur]} end
    else
      if cur and #cur > 1 then runs[#runs+1] = cur end; cur = nil
    end
  end
  if cur and #cur > 1 then runs[#runs+1] = cur end
  return runs
end
local RINGS = {}
for n = 1, 8 do RINGS[#RINGS+1] = 118*math.sqrt(n) end
RINGS[#RINGS+1] = 405; RINGS[#RINGS+1] = 418
for _, R in ipairs(RINGS) do
  for _, run in ipairs(runs_on(R - 2.6, math.rad(170), math.rad(280))) do sline(l, P_shine, run, 0.45) end
  for _, run in ipairs(runs_on(R + 2.6, math.rad(-10), math.rad(100))) do sline(l, P_shine, run, 0.45) end
  -- the shadowed wall opposite
  for _, run in ipairs(runs_on(R + 2.6, math.rad(170), math.rad(280))) do sline(d, P_groove, run, 0.4) end
  for _, run in ipairs(runs_on(R - 2.6, math.rad(-10), math.rad(100))) do sline(d, P_groove, run, 0.4) end
end
-- well outer lips catching the light
for n = 1, 7 do
  local m = MED[n]
  sline(l, P_shine, arcpts(m.x, m.y, m.r + 2, math.rad(160), math.rad(290)), 0.45)
end
-- limb ticks, again
local t = brush{kind="round", width=1.6, point=0}
t:load(P_groove, 0.95)
for k = 1, 89 do
  local a = k * GA
  local x1, y1 = CX + 408*math.cos(a), CY + 408*math.sin(a)
  local x2, y2 = CX + 415*math.cos(a), CY + 415*math.sin(a)
  if not in_well(x1, y1, 6) and not in_well(x2, y2, 6) and GOUGE:grow(30):at(x1, y1) < 0.05 then
    if t:fullness() < 0.6 then t:reload(P_groove, 0.95) end
    local w = (k % 8 == 0) and 0.85 or 0.6
    t:stroke({{x1, y1}, {x2, y2}}, {pressure={w, w}, ramps={0,0}})
  end
end
-- count seeds
local cnt = nil
for n = 1, 7 do
  local mm = MED[n]
  local ang = math.atan(mm.y - CY, mm.x - CX)
  local rr = math.sqrt((mm.x-CX)^2 + (mm.y-CY)^2) + mm.r + 13
  local step = 8 / rr
  for j = 1, n do
    local a = ang + (j - (n+1)/2) * step
    local s = ellipse(CX + rr*math.cos(a), CY + rr*math.sin(a), 2.3, 2.3)
    cnt = cnt and (cnt + s) or s
  end
end
work(cnt, {hand="detail", pile=P_bone, coverage=3.5, fill=true, clip=true})
-- verdigris settled in the groove bottoms, in runs, heavier on the shadowed lower right
local P_verd2 = pile{{"viridian",1},{"cerulean blue",0.6},{"yellow ochre",0.5},{"lead white",0.9},{"bone black",0.1}}
local v = brush{kind="round", width=1.1, point=0}
v:load(P_verd2, 0.8)
local nz = noise{seed=41, octaves=3, period=140}
for _, R in ipairs(RINGS) do
  local runs, cur = {}, nil
  local step = 4 / R
  for a = 0, 2*math.pi, step do
    local x, y = CX + R*math.cos(a), CY + R*math.sin(a)
    local side = clamp(((x - CX) + (y - CY)) / 800 + 0.5, 0, 1)
    local on = nz:at01(x, y) * (0.6 + 0.6 * side) > 0.52
    if on and not in_well(x, y, 7) and GOUGE:grow(3):at(x, y) < 0.05 then
      cur = cur or {}; cur[#cur+1] = {x, y}
      if #cur > 10 then runs[#runs+1] = cur; cur = {cur[#cur-1], cur[#cur]} end
    else
      if cur and #cur > 2 then runs[#runs+1] = cur end; cur = nil
    end
  end
  if cur and #cur > 2 then runs[#runs+1] = cur end
  for _, run in ipairs(runs) do
    if v:fullness() < 0.5 then v:reload(P_verd2, 0.8) end
    v:stroke(run, {pressure={0.45, 0.45}, ramps={0.2, 0.2}})
  end
end
print(wait(30))
-- lesson 1 notches restated over dry paint
do
  local function notches3(pts, i, k, dir, len, gap)
    len = len or 12; gap = gap or 0.26
    local offs, t = {}, 0
    for j = 1, k do offs[j] = t; if j < k then t = t + gap * (PHI ^ (j-1)) end end
    for j = 1, k do offs[j] = offs[j] - t/2 end
    for j = 1, k do
      local x, y, nx, ny = edge_at(pts, i, 0.5 + offs[j])
      BB:reload(P_bone, 0.95)
      bseg(x + nx*1.2, y + ny*1.2, x + nx*len, y + ny*len, 0.8)
    end
    local x, y, nx, ny, ux, uy = edge_at(pts, i, 0.5 + offs[k])
    local tx, ty = x + nx*len, y + ny*len
    ux, uy = ux*(dir or 1), uy*(dir or 1)
    BB:reload(P_bone, 0.95)
    bseg(tx - ux*6 + nx*4.5, ty - uy*6 + ny*4.5, tx + ux*1, ty + uy*1, 0.7)
    bseg(tx - ux*6 - nx*4.5, ty - uy*6 - ny*4.5, tx + ux*1, ty + uy*1, 0.7)
  end
  local m = MED[1]
  local R1 = {{-26,-20},{14,-24},{30,0},{18,24},{-24,18}}
  local g1 = place(R1, m.x, m.y + 2, 1.15, 0.12)
  notches3(g1, 1, 1); notches3(g1, 3, 2); notches3(g1, 4, 3)
end
print(wait(30))
