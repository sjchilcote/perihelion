-- easel session "pumps": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=9091,
  ground={{pile={{"bone black",1},{"ultramarine ash",0.8},{"burnt sienna",0.4},{"lead white",0.9}}, um=110, apply="knife", texture=0.4}}}
-- one-point perspective, metres; Y down from eye; floor at Y = 1.6
VX, VY, F = 500, 330, 520
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY, CY = 1.6, -2.4            -- floor, ceiling
HW = 4.0                      -- rooms' half width
ZH1, ZH2 = 6.0, 14.0          -- the near hatch wall, the far hatch wall
local function quad(a, b, c, d) return poly({a, b, c, d}) end
function ROOM(z0, z1)
  return {
    floor = quad(pt(-HW, FY, z0), pt(HW, FY, z0), pt(HW, FY, z1), pt(-HW, FY, z1)),
    ceil  = quad(pt(-HW, CY, z0), pt(HW, CY, z0), pt(HW, CY, z1), pt(-HW, CY, z1)),
    left  = quad(pt(-HW, CY, z0), pt(-HW, CY, z1), pt(-HW, FY, z1), pt(-HW, FY, z0)),
    right = quad(pt(HW, CY, z0), pt(HW, CY, z1), pt(HW, FY, z1), pt(HW, FY, z0)),
  }
end
-- the hatches: a rounded-corner rectangle, X -0.85..0.85, floor to 2.05 m up, a 0.3 m sill
function HATCHPTS(Z)
  local t = {}
  local x0, x1, y0, y1, r = -0.85, 0.85, FY - 0.3, FY - 2.05, 0.22
  local function arc(cx, cy, a0, a1) for i = 0, 5 do local a = a0 + (a1 - a0) * i / 5; t[#t+1] = pt(cx + r * math.cos(a), cy + r * math.sin(a), Z) end end
  arc(x1 - r, y0 - r, 0, math.pi / 2)
  arc(x0 + r, y0 - r, math.pi / 2, math.pi)
  arc(x0 + r, y1 + r, math.pi, 1.5 * math.pi)
  arc(x1 - r, y1 + r, 1.5 * math.pi, 2 * math.pi)
  return t
end
R1 = ROOM(0.7, ZH1)
R2 = ROOM(ZH1 + 0.35, ZH2)
WALL1 = quad(pt(-HW, CY, ZH1), pt(HW, CY, ZH1), pt(HW, FY, ZH1), pt(-HW, FY, ZH1))
H1 = poly(HATCHPTS(ZH1))
H1B = poly(HATCHPTS(ZH1 + 0.35))      -- the hatch's far edge (wall thickness)
WALL2 = quad(pt(-HW, CY, ZH2), pt(HW, CY, ZH2), pt(HW, FY, ZH2), pt(-HW, FY, ZH2))
H2 = poly(HATCHPTS(ZH2))
print(W, H, P(-HW, FY, ZH1), P(HW, CY, ZH1))
print(P(-0.85, FY - 0.3, ZH1), P(0.85, FY - 2.05, ZH1))

--@ chunk 2
-- a bigger bulkhead hatch; lay-in dark, the near wall lit in a soft disc by our own lamp, the room beyond
function HATCHPTS(Z)
  local t = {}
  local x0, x1, y0, y1, r = -1.4, 1.4, FY - 0.25, FY - 2.6, 0.35
  local function arc(cx, cy, a0, a1) for i = 0, 6 do local a = a0 + (a1 - a0) * i / 6; t[#t+1] = pt(cx + r * math.cos(a), cy + r * math.sin(a), Z) end end
  arc(x1 - r, y0 - r, 0, math.pi / 2)
  arc(x0 + r, y0 - r, math.pi / 2, math.pi)
  arc(x0 + r, y1 + r, math.pi, 1.5 * math.pi)
  arc(x1 - r, y1 + r, 1.5 * math.pi, 2 * math.pi)
  return t
end
H1 = poly(HATCHPTS(ZH1)); H1B = poly(HATCHPTS(ZH1 + 0.35)); H2 = poly(HATCHPTS(ZH2))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local dk1 = pile{{"bone black",2},{"ultramarine ash",0.6},{"burnt sienna",0.35}, medium=0.06}
local dk2 = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.15},{"burnt sienna",0.25}, medium=0.06}
local surf1 = R1.left + R1.right + R1.ceil
work(surf1, {hand="body", tool="filbert 12", pile=dk1, coverage=4, fill=true, clip=surf1, angle=toVP, load=1})
work(R1.floor, {hand="body", tool="filbert 12", pile=dk2, coverage=4, fill=true, clip=R1.floor, angle=toVP, load=1})
-- the near bulkhead: dark at its edges, a soft lit disc round the hatch from our lamp
local w0 = pile{{"bone black",2},{"ultramarine ash",0.9},{"lead white",0.35},{"burnt sienna",0.2}, medium=0.06}
local w1 = pile{{"bone black",1.4},{"ultramarine ash",0.9},{"lead white",0.75},{"burnt sienna",0.15}, medium=0.06}
local w2 = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",1.2},{"zinc white",0.2}, medium=0.06}
local c = {500, 300}
local d1 = ellipse(c[1], c[2], 230, 200)
local d2 = ellipse(c[1], c[2], 160, 140)
local Wl = WALL1 - H1
work(Wl - d1, {hand="body", tool="filbert 8", pile=w0, coverage=4, fill=true, clip=Wl - d1, angle=math.pi/2, load=1})
work((Wl * d1) - d2, {hand="body", tool="filbert 6", pile=w1, coverage=4, fill=true, clip=(Wl * d1) - d2, angle=math.pi/2, load=1})
work(Wl * d2, {hand="body", tool="filbert 6", pile=w2, coverage=4, fill=true, clip=Wl * d2, angle=math.pi/2, load=1})
blend(Wl * (ellipse(c[1], c[2], 240, 210) - ellipse(c[1], c[2], 218, 190)))
blend(Wl * (ellipse(c[1], c[2], 170, 150) - ellipse(c[1], c[2], 150, 130)))
-- through the hatch: room two, cold and dim; our light lays a pale tongue down its floor
local V = H1B
local r2 = pile{{"bone black",2},{"ultramarine ash",0.7},{"lead white",0.2}, medium=0.06}
work((R2.left + R2.right + R2.ceil + WALL2) * V - H2, {hand="body", tool="filbert 4", pile=r2, coverage=4, fill=true, clip=V, angle=toVP, load=1})
local fl2 = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.5}, medium=0.06}
work(R2.floor * V, {hand="body", tool="filbert 4", pile=fl2, coverage=4, fill=true, clip=R2.floor * V, angle=toVP, load=1})
-- the hatch's own thickness (reveal), steel lit along its lower lip
local rv = pile{{"bone black",1.5},{"ultramarine ash",0.8},{"lead white",0.55}, medium=0.06}
work(H1 - H1B, {hand="detail", pile=rv, coverage=4, fill=true, clip=H1 - H1B, load=1})
-- beyond the far hatch: room three, lit by someone else's lamp
local r3 = pile{{"zinc white",1.5},{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.3}, medium=0.05}
work(H2, {hand="detail", pile=r3, coverage=4, fill=true, clip=H2, load=1})

--@ chunk 3
-- the bulkhead too pale and ringed: repaint it dark, keep only a modest glow round the hatch; amber collar laid in
print(wait(3*24*60))
local w0 = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.18},{"burnt sienna",0.25}, medium=0.06}
local w1 = pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.5},{"burnt sienna",0.15}, medium=0.06}
local collar = H1:grow(16) - H1
local Wl = WALL1 - H1:grow(16)
local glow = (H1:grow(70) - H1:grow(16)) * WALL1
work(Wl - glow, {hand="body", tool="filbert 8", pile=w0, coverage=5, fill=true, clip=Wl - glow, angle=math.pi/2, load=1})
work(glow, {hand="body", tool="filbert 6", pile=w1, coverage=5, fill=true, clip=glow, angle=math.pi/2, load=1})
blend((H1:grow(78) - H1:grow(58)) * WALL1)
blend((H1:grow(95) - H1:grow(72)) * WALL1)
local amb = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.5},{"bone black",0.35}, medium=0.06}
work(collar, {hand="body", tool="filbert 4", pile=amb, coverage=5, fill=true, clip=collar, load=1})
COLLAR1 = collar

--@ chunk 4
-- the pumps: big identical coolant columns, lit on the side toward our lamp. Room two's stand the same, flipped.
function PUMP(X, Z, flip, clipm)
  local r, h = 0.75, 3.1
  local Zf = Z - r
  local xl, yb = P(X - r, FY, Zf); local xr, yt = P(X + r, FY - h, Zf)
  local k = F / Zf
  local body = rect(xl, yt, xr - xl, yb - yt)
  local cap = ellipse((xl + xr) / 2, yt, (xr - xl) / 2, 0.22 * k)
  local base = rect(xl - 0.12 * k, yb - 0.45 * k, (xr - xl) + 0.24 * k, 0.45 * k)
  local all = body + cap + base
  if clipm then all = all * clipm end
  local litSide = (X < 0) and 1 or -1        -- the side toward the room's centre catches the lamp
  local wz = (xr - xl)
  local zLit = (litSide > 0) and rect(xr - wz * 0.3, yt - 0.3 * k, wz * 0.3, yb - yt + 0.3 * k) or rect(xl, yt - 0.3 * k, wz * 0.3, yb - yt + 0.3 * k)
  local zDark = (litSide > 0) and rect(xl, yt - 0.3 * k, wz * 0.35, yb - yt + 0.3 * k) or rect(xr - wz * 0.35, yt - 0.3 * k, wz * 0.35, yb - yt + 0.3 * k)
  local dim = clipm and 0.5 or 1.0
  local pD = pile{{"bone black",2},{"ultramarine ash",0.7},{"burnt sienna",0.3}, medium=0.06}
  local pM = pile{{"bone black",1.5},{"ultramarine ash",0.9},{"lead white",0.35 + 0.25 * dim},{"viridian",0.05}, medium=0.06}
  local pL = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.6 + 0.8 * dim},{"zinc white",0.2 * dim}, medium=0.06}
  local tool = {kind="filbert", width=math.max(1.5, 0.09 * k)}
  work(all * zDark, {hand="body", tool=tool, pile=pD, coverage=4, fill=true, clip=all * zDark, angle=math.pi/2, load=1})
  work(all - zDark - zLit, {hand="body", tool=tool, pile=pM, coverage=4, fill=true, clip=all - zDark - zLit, angle=math.pi/2, load=1})
  work(all * zLit, {hand="body", tool=tool, pile=pL, coverage=4, fill=true, clip=all * zLit, angle=math.pi/2, load=1})
  local s1 = (litSide > 0) and (xl + wz * 0.35) or (xr - wz * 0.35)
  local s2 = (litSide > 0) and (xr - wz * 0.3) or (xl + wz * 0.3)
  blend(all * rect(s1 - 0.06 * k, yt, 0.12 * k, yb - yt))
  blend(all * rect(s2 - 0.06 * k, yt, 0.12 * k, yb - yt))
  return {xl=xl, xr=xr, yt=yt, yb=yb, k=k, all=all, flip=flip, lit=litSide, X=X, Z=Z}
end
PUMPS = {}
-- room two first (seen through the hatch), then ours
for _, q in ipairs{{-2.45, 10.2}, {2.45, 10.2}} do PUMPS[#PUMPS+1] = PUMP(q[1], q[2], true, H1B) end
for _, q in ipairs{{-2.5, 3.9}, {2.5, 3.9}} do PUMPS[#PUMPS+1] = PUMP(q[1], q[2], false, nil) end
for _, p in ipairs(PUMPS) do print(p.xl, p.xr, p.yt, p.yb) end

--@ chunk 5
-- the near pumps came out as pale concrete: repaint them dark machinery, a narrow lit flank toward the hatch
print(wait(3*24*60))
local pD = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.35}, medium=0.06}
local pM = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.25}, medium=0.06}
local pL = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.9},{"zinc white",0.2}, medium=0.06}
for i = 3, 4 do
  local p = PUMPS[i]
  local wz = p.xr - p.xl
  local k = p.k
  local lit = (p.lit > 0) and rect(p.xr - wz * 0.16, p.yt - 0.3 * k, wz * 0.16, p.yb - p.yt + 0.3 * k) or rect(p.xl, p.yt - 0.3 * k, wz * 0.16, p.yb - p.yt + 0.3 * k)
  local mid = (p.lit > 0) and rect(p.xr - wz * 0.34, p.yt - 0.3 * k, wz * 0.18, p.yb - p.yt + 0.3 * k) or rect(p.xl + wz * 0.16, p.yt - 0.3 * k, wz * 0.18, p.yb - p.yt + 0.3 * k)
  local tool = {kind="filbert", width=10}
  work(p.all - lit - mid, {hand="body", tool=tool, pile=pD, coverage=5, fill=true, clip=p.all - lit - mid, angle=math.pi/2, load=1})
  work(p.all * mid, {hand="body", tool={kind="filbert", width=6}, pile=pM, coverage=5, fill=true, clip=p.all * mid, angle=math.pi/2, load=1})
  work(p.all * lit, {hand="body", tool={kind="filbert", width=6}, pile=pL, coverage=5, fill=true, clip=p.all * lit, angle=math.pi/2, load=1})
end

--@ chunk 6
-- black chevrons on our collar; the far hatch's amber collar; the hatch leaf swung open toward us; the figure in the far hatch
local blk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}
local b = brush{kind="flat", width=7, stiffness=0.6}
for s = 0, 60 do
  local x0 = 340 + s * 13
  b:load(blk, 0.9)
  b:stroke({{x0 - 160, 470}, {x0, 230}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across", clip=COLLAR1})
end
local C2 = (H2:grow(6) - H2) * WALL2 * H1B
local amb = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.6},{"bone black",0.6}, medium=0.06}
work(C2, {hand="detail", pile=amb, coverage=5, fill=true, clip=C2, load=1})
-- the hatch leaf, open, in the plane X = -1.45 between Z 4.55 and 6
DOOR = poly({pt(-1.45, FY - 0.25, ZH1), pt(-1.45, FY - 0.25, 4.55), pt(-1.45, FY - 2.6, 4.55), pt(-1.45, FY - 2.6, ZH1)})
local dP = pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.45}, medium=0.06}
local dE = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.3}, medium=0.06}
work(DOOR, {hand="body", tool="filbert 4", pile=dP, coverage=5, fill=true, clip=DOOR, angle=math.pi/2, load=1})
local edge = poly({pt(-1.45, FY - 0.25, 4.55), pt(-1.25, FY - 0.25, 4.55), pt(-1.25, FY - 2.6, 4.55), pt(-1.45, FY - 2.6, 4.55)})
work(edge, {hand="detail", pile=dE, coverage=5, fill=true, clip=edge, load=1})
-- the figure at the far hatch, his back to us, his own lamp lighting the room beyond
local Z = ZH2 - 0.25
local k = F / Z
local fx, fy = P(0.12, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.1,0.93), Q(-0.12,0.52), Q(-0.12,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.1,0.93), Q(0.12,0.52), Q(0.13,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.24,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.22,0.14)}) + poly({Q(0.04,0.0), Q(0.24,0.0), Q(0.22,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.35,1.24), Q(-0.32,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.36,1.24), Q(0.3,1.0)}, {0.12*k, 0.1*k, 0.09*k})
FIGP = fig * H1B
FPK, FPX, FPY = k, fx, fy
local figD = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}
work(FIGP, {hand="detail", pile=figD, coverage=5, fill=true, clip=FIGP, load=1})
print(fx, fy, k)

--@ chunk 7
-- the pumps' furniture, identical on both sides of the hatch but flipped beyond it: hazard rings, louvres, gauges, risers
print(wait(2*24*60))
local amb = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.5},{"bone black",0.5}, medium=0.06}
local ambL = pile{{"chrome yellow",1},{"Mars orange",1},{"lead white",0.35}, medium=0.06}
local blk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}
local slot = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
local slotL = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.8}, medium=0.06}
local dial = pile{{"lead white",1.5},{"zinc white",0.5},{"ultramarine ash",0.4},{"bone black",0.3}, medium=0.06}
local pipe = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.2}, medium=0.06}
local pipeL = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",1}, medium=0.06}
for i, p in ipairs(PUMPS) do
  local k, xl, xr, yt, yb = p.k, p.xl, p.xr, p.yt, p.yb
  local clipm = p.all
  local wz = xr - xl
  -- hazard ring at 1.0-1.25 m, stripes slanting one way here and the other way beyond the hatch
  local band = rect(xl, yb - 1.25 * k, wz, 0.25 * k) * clipm
  local lit = rect((p.lit > 0) and (xr - wz * 0.34) or xl, yb - 1.25 * k, wz * 0.34, 0.25 * k) * band
  work(band - lit, {hand="detail", pile=amb, coverage=5, fill=true, clip=band - lit, load=1})
  work(lit, {hand="detail", pile=ambL, coverage=5, fill=true, clip=lit, load=1})
  local dir = p.flip and -1 or 1
  local fb = brush{kind="flat", width=math.max(1.2, 0.07 * k), stiffness=0.6}
  for x = xl - 0.3 * k, xr + 0.3 * k, 0.16 * k do
    fb:load(blk, 0.9)
    fb:stroke({{x, yb - 1.0 * k}, {x + dir * 0.25 * k, yb - 1.25 * k}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across", clip=band})
  end
  -- louvres: a stack of dark slots with a lit lip, on the gauge's other side
  local lx = p.flip and (xl + wz * 0.2) or (xr - wz * 0.55)
  if p.lit < 0 then lx = p.flip and (xr - wz * 0.55) or (xl + wz * 0.2) end
  for j = 0, 6 do
    local y = yb - (1.6 + j * 0.13) * k
    local sb = brush{kind="flat", width=math.max(1, 0.05 * k)}
    sb:load(slot, 0.9); sb:stroke({{lx, y}, {lx + wz * 0.35, y}}, {pressure={0.8, 0.8}, orient="across", clip=clipm})
    sb:load(slotL, 0.8); sb:stroke({{lx, y + 0.03 * k}, {lx + wz * 0.35, y + 0.03 * k}}, {pressure={0.4, 0.4}, orient="across", clip=clipm})
  end
  -- the gauge: on the left of the face in our room, on the right beyond the hatch
  local gx = (p.flip == (p.X < 0)) and (xl + wz * 0.72) or (xl + wz * 0.28)
  local g = ellipse(gx, yb - 2.25 * k, 0.11 * k, 0.11 * k) * clipm
  work(g, {hand="detail", pile=dial, coverage=5, fill=true, clip=g, load=1})
  local nb = brush{kind="round", width=math.max(0.6, 0.012 * k), point=0.5}
  nb:load(slot, 0.9); nb:stroke({{gx, yb - 2.25 * k}, {gx + dir * 0.07 * k, yb - 2.31 * k}}, {pressure={0.7, 0.4}, clip=g})
  -- risers from the cap up to the ceiling
  local cx = (xl + xr) / 2
  for _, dx in ipairs{-0.25, 0.22} do
    local x = cx + dx * k
    local _, yc = P(0, CY, p.Z)
    local rb = brush{kind="flat", width=math.max(1.5, 0.12 * k), stiffness=0.6}
    rb:load(pipe, 1)
    rb:stroke({{x, yt}, {x, yc}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=p.flip and H1B or nil})
    local hb = brush{kind="round", width=math.max(0.7, 0.025 * k), point=0.4}
    hb:load(pipeL, 0.8)
    hb:stroke({{x - p.lit * -0.04 * k, yt}, {x - p.lit * -0.04 * k, yc}}, {pressure={0.5, 0.5}, clip=p.flip and H1B or nil})
  end
end
-- the far collar's chevrons, slanting the other way
local C2 = (H2:grow(6) - H2) * WALL2 * H1B
local b = brush{kind="flat", width=2.5, stiffness=0.6}
for s = 0, 40 do
  local x0 = 430 + s * 4.5
  b:load(blk, 0.9)
  b:stroke({{x0 - 60, 250}, {x0, 390}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, orient="across", clip=C2})
end

--@ chunk 8
-- near hazard rings repainted opaque (the thin amber went olive); stripes; floor sill stripe; frost; the room past the figure
print(wait(3*24*60))
local amb = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.4},{"bone black",0.25}, medium=0.06}
local ambL = pile{{"chrome yellow",1},{"Mars orange",0.9},{"lead white",0.3}, medium=0.06}
local blk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}
for i = 3, 4 do
  local p = PUMPS[i]
  local k, xl, xr, yb = p.k, p.xl, p.xr, p.yb
  local wz = xr - xl
  local band = rect(xl, yb - 1.25 * k, wz, 0.25 * k) * p.all
  local lit = rect((p.lit > 0) and (xr - wz * 0.34) or xl, yb - 1.25 * k, wz * 0.34, 0.25 * k) * band
  work(band - lit, {hand="body", tool="filbert 6", pile=amb, coverage=6, fill=true, clip=band - lit, angle=0, load=1})
  work(lit, {hand="body", tool="filbert 6", pile=ambL, coverage=6, fill=true, clip=lit, angle=0, load=1})
end
print(wait(2*24*60))
for i = 3, 4 do
  local p = PUMPS[i]
  local k, xl, xr, yb = p.k, p.xl, p.xr, p.yb
  local band = rect(xl, yb - 1.25 * k, xr - xl, 0.25 * k) * p.all
  local fb = brush{kind="flat", width=0.07 * k, stiffness=0.6}
  for x = xl - 0.3 * k, xr + 0.3 * k, 0.17 * k do
    fb:load(blk, 1)
    fb:stroke({{x, yb - 1.0 * k}, {x + 0.25 * k, yb - 1.25 * k}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=band})
  end
end
-- frost: rime on the risers and pump caps, cold stipple
local frost = pile{{"zinc white",2},{"lead white",0.5},{"ultramarine ash",0.4},{"cerulean blue",0.1}, medium=0.05}
local fm = nil
for i = 3, 4 do
  local p = PUMPS[i]
  local k = p.k
  local cx = (p.xl + p.xr) / 2
  local m = ellipse(cx, p.yt, (p.xr - p.xl) / 2 + 4, 0.25 * k) + rect(cx - 0.35 * k, 0, 0.7 * k, p.yt) + rect(p.xl, p.yb - 0.5 * k, p.xr - p.xl, 0.15 * k)
  fm = fm and (fm + m) or m
end
stipple(fm * (PUMPS[3].all + PUMPS[4].all + everywhere() * above(function(x) return 100 end)), {pile=frost, width=1.6, coverage=0.5, feather=0.6, cluster=0.6, dips={30, 0.6, 0}})
-- room three, past the figure: faint pump columns either side and another collar beyond — the room we stand in
local r3c = pile{{"lead white",1},{"zinc white",0.5},{"ultramarine ash",0.8},{"bone black",0.5}, medium=0.05}
local z3 = 19.0
for _, X in ipairs{-2.45, 2.45} do
  local xl, yb = P(X - 0.75, FY, z3); local xr, yt = P(X + 0.75, FY - 3.1, z3)
  local m = rect(xl, yt, xr - xl, yb - yt) * H2
  work(m, {hand="detail", pile=r3c, coverage=4, fill=true, clip=m, load=1})
end
local H3 = poly(HATCHPTS(ZH2 + 8))
local c3 = (H3:grow(2) - H3) * H2
work(c3, {hand="detail", pile=pile{{"chrome yellow",1},{"Mars orange",0.8},{"lead white",0.6}, medium=0.06}, coverage=4, fill=true, clip=c3, load=1})

--@ chunk 9
-- the frost stipple read as static: paint it out (caps, lower band, the ceiling round the risers), risers again, rime as a few drawn edges
print(wait(2*24*60))
local pD = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.35}, medium=0.06}
local pM = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.25}, medium=0.06}
local pL = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.9},{"zinc white",0.2}, medium=0.06}
local ceil = pile{{"bone black",2},{"ultramarine ash",0.6},{"burnt sienna",0.35}, medium=0.06}
local pipe = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.2}, medium=0.06}
local pipeL = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",1}, medium=0.06}
local rime = pile{{"zinc white",2},{"lead white",0.6},{"ultramarine ash",0.3}, medium=0.05}
for i = 3, 4 do
  local p = PUMPS[i]
  local k, xl, xr, yt, yb = p.k, p.xl, p.xr, p.yt, p.yb
  local wz = xr - xl
  local cx = (xl + xr) / 2
  local cap = ellipse(cx, yt, wz / 2 + 5, 0.27 * k)
  local low = rect(xl - 2, yb - 0.52 * k, wz + 4, 0.2 * k) * p.all
  local up = rect(cx - 0.37 * k, 0, 0.74 * k, yt) - cap
  local fix = (cap + low)
  local lit = (p.lit > 0) and rect(xr - wz * 0.16, 0, wz * 0.16 + 6, 700) or rect(xl - 6, 0, wz * 0.16 + 6, 700)
  local mid = (p.lit > 0) and rect(xr - wz * 0.34, 0, wz * 0.18, 700) or rect(xl + wz * 0.16, 0, wz * 0.18, 700)
  work(fix - lit - mid, {hand="body", tool="filbert 8", pile=pD, coverage=5, fill=true, clip=fix - lit - mid, angle=0, load=1})
  work(fix * mid, {hand="body", tool="filbert 5", pile=pM, coverage=5, fill=true, clip=fix * mid, angle=0, load=1})
  work(fix * lit, {hand="body", tool="filbert 5", pile=pL, coverage=5, fill=true, clip=fix * lit, angle=0, load=1})
  work(up, {hand="body", tool="filbert 8", pile=ceil, coverage=5, fill=true, clip=up, angle=math.pi/2, load=1})
  for _, dx in ipairs{-0.25, 0.22} do
    local x = cx + dx * k
    local rb = brush{kind="flat", width=0.12 * k, stiffness=0.6}
    rb:load(pipe, 1)
    rb:stroke({{x, yt}, {x, -5}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across"})
    local hb = brush{kind="round", width=0.025 * k, point=0.4}
    hb:load(pipeL, 0.8)
    hb:stroke({{x + p.lit * 0.04 * k, yt}, {x + p.lit * 0.04 * k, -5}}, {pressure={0.5, 0.5}})
    -- rime where the riser meets the cap
    local fb = brush{kind="round", width=0.03 * k, point=0.6}
    fb:load(rime, 0.7)
    fb:stroke({{x - 0.06 * k, yt - 0.1 * k}, {x - 0.06 * k, yt - 0.45 * k}}, {pressure={0.6, 0.05}, shake=1.5})
  end
  -- rime along the cap's front rim, broken
  local pts = {}
  for j = 0, 10 do local a = math.pi * (0.1 + 0.8 * j / 10); pts[#pts+1] = {cx + (wz / 2) * math.cos(a), yt + 0.2 * k * math.sin(a)} end
  local rb = brush{kind="round", width=0.03 * k, point=0.6}
  rb:load(rime, 0.75)
  rb:stroke(pts, {pressure={0.6, 0.3}, swell={1, 0.4, 1, 0.3, 1, 0.5}, shake=1.2})
end

--@ chunk 10
-- our lamp on the near deck; a hazard line before the sill; room two's ceiling conduits; the far figure's own light round his helmet
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local d1 = pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.45}, medium=0.06}
local d2 = pile{{"bone black",1.3},{"ultramarine ash",0.9},{"lead white",0.75}, medium=0.06}
local between = R1.floor - PUMPS[3].all - PUMPS[4].all
local zA = between * rect(150, 472, 700, 40)
local zB = between * rect(80, 512, 840, 50)
work(zB, {hand="body", tool="filbert 8", pile=d1, coverage=4, fill=true, clip=zB, angle=toVP, load=1})
work(zA, {hand="body", tool="filbert 6", pile=d2, coverage=4, fill=true, clip=zA, angle=toVP, load=1})
blend(between * rect(0, 503, 1000, 18), {angle=0})
blend(between * rect(0, 553, 1000, 18), {angle=0})
-- the hazard line on the deck before the sill
local hl = poly({pt(-1.6, FY, 5.55), pt(1.6, FY, 5.55), pt(1.6, FY, 5.8), pt(-1.6, FY, 5.8)})
work(hl, {hand="detail", pile=pile{{"chrome yellow",1},{"Mars orange",1},{"lead white",0.2}, medium=0.06}, coverage=5, fill=true, clip=hl, load=1})
-- conduits along room two's ceiling, converging
local cd = pile{{"bone black",2},{"ultramarine ash",0.5}, medium=0.06}
for _, X in ipairs{-0.9, -0.55, 0.7} do
  local b = brush{kind="round", width=3, stiffness=0.6}
  b:load(cd, 1)
  b:stroke({pt(X, CY + 0.25, ZH1 + 0.4), pt(X, CY + 0.25, ZH2)}, {pressure={0.9, 0.9}, clip=H1B})
end
-- the far man: his own lamp's light breaking round the helmet and shoulders, our lamp faint on his back
local k, fx, fy = FPK, FPX, FPY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local hot = pile{{"zinc white",3},{"lemon chrome",0.1}, medium=0.04}
local cool = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.7}, medium=0.06}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr, clip=clipm})
end
ln({Q(-0.1,1.86), Q(0,1.9), Q(0.1,1.86)}, hot, 1.4, {0.8, 0.8})
ln({Q(-0.38,1.55), Q(-0.3,1.62), Q(-0.12,1.62)}, hot, 1.1, {0.7, 0.4})
ln({Q(0.12,1.62), Q(0.3,1.62), Q(0.38,1.55)}, hot, 1.1, {0.4, 0.7})
ln({Q(-0.12,1.45), Q(-0.12,1.18)}, cool, 1.0, {0.5, 0.5}, FIGP)
ln({Q(0.12,1.45), Q(0.12,1.18)}, cool, 1.0, {0.5, 0.5}, FIGP)

--@ chunk 11
-- the lit deck read as a slab: make it the grated walkway it wants to be (runs to the VP, cross bars, a shadowed lip)
print(wait(2*24*60))
local between = R1.floor - PUMPS[3].all - PUMPS[4].all
local slab = between * rect(80, 470, 840, 102)
local g = pile{{"bone black",2},{"ultramarine ash",0.5}, medium=0.06}
local gl = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.9}, medium=0.06}
for X = -2.9, 2.9, 0.22 do
  local b = brush{kind="round", width=1.0, point=0.3}
  b:load(g, 0.9)
  b:stroke({pt(X, FY, 3.0), pt(X, FY, 5.6)}, {pressure={0.6, 0.4}, clip=slab})
end
for _, Z in ipairs{3.1, 3.35, 3.62, 3.92, 4.25, 4.62, 5.03, 5.5} do
  local b = brush{kind="flat", width=math.max(1, 0.05 * F / Z)}
  b:load(g, 0.9)
  b:stroke({pt(-3.2, FY, Z), pt(3.2, FY, Z)}, {pressure={0.6, 0.6}, orient="across", clip=slab})
  local l = brush{kind="round", width=0.8, point=0.4}
  l:load(gl, 0.7)
  l:stroke({pt(-3.2, FY, Z - 0.04), pt(3.2, FY, Z - 0.04)}, {pressure={0.3, 0.3}, clip=slab})
end
local lip = between * rect(80, 566, 840, 14)
work(lip, {hand="detail", pile=g, coverage=5, fill=true, clip=lip, load=1})

--@ chunk 12
-- the hatch leaf gets its wheel and a lit edge; conduits along our ceiling to the bulkhead
print(wait(1*24*60))
local lit = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",1}, medium=0.06}
local dk = pile{{"bone black",2},{"ultramarine ash",0.5}, medium=0.06}
local function ln(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.4}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr})
end
-- leaf edge toward the room's centre catches our lamp
ln({pt(-1.25, FY - 0.27, 4.56), pt(-1.25, FY - 2.58, 4.56)}, lit, 1.6, {0.7, 0.7})
-- the locking wheel on the leaf's inner face
local wx, wy = P(-1.45, FY - 1.35, 5.2)
local wh = {}
for j = 0, 16 do local a = 2 * math.pi * j / 16; wh[#wh+1] = {wx + 4.5 * math.cos(a), wy + 14 * math.sin(a)} end
ln(wh, lit, 1.6, {0.6, 0.6})
ln({{wx, wy - 14}, {wx, wy + 14}}, lit, 1.0, {0.5, 0.5})
-- conduits on our ceiling, converging on the bulkhead
for _, X in ipairs{-1.9, -1.5, 1.6} do
  ln({pt(X, CY + 0.15, 0.9), pt(X, CY + 0.15, ZH1)}, dk, 9, {0.9, 0.9})
  ln({pt(X + 0.06, CY + 0.25, 0.9), pt(X + 0.06, CY + 0.25, ZH1)}, lit, 1.2, {0.3, 0.6})
end

--@ chunk 13
-- the flip made to land: stencilled pump numbers down each near pump's lit flank, amber on gray;
-- the same numbers on the far room's pumps on the opposite sides, each letter reversed; the hatch leaf beyond, on the right
print(wait(1*24*60))
local G = {
  P  = {{{0,1},{0,0}}, {{0,0},{0.72,0},{0.92,0.2},{0.72,0.45},{0.08,0.45}}},
  dash = {{{0.15,0.52},{0.85,0.52}}},
  ["0"] = {{{0.42,0.02},{0.1,0.18},{0.1,0.82},{0.42,0.98}}, {{0.58,0.02},{0.9,0.18},{0.9,0.82},{0.58,0.98}}},
  ["7"] = {{{0.05,0},{0.95,0},{0.38,1}}},
  ["8"] = {{{0.45,0.02},{0.15,0.14},{0.2,0.4},{0.45,0.47}}, {{0.55,0.02},{0.85,0.14},{0.8,0.4},{0.55,0.47}},
           {{0.45,0.53},{0.1,0.66},{0.15,0.9},{0.45,0.98}}, {{0.55,0.53},{0.9,0.66},{0.85,0.9},{0.55,0.98}}},
}
-- the reversed letters, drawn as they read from the wrong side
local R = {
  P  = {{{1,1},{1,0}}, {{1,0},{0.28,0},{0.08,0.2},{0.28,0.45},{0.92,0.45}}},
  dash = G.dash,
  ["0"] = G["0"],
  ["7"] = {{{0.95,0},{0.05,0},{0.62,1}}},
  ["8"] = G["8"],
}
local amber = pile{{"chrome yellow",1},{"Mars orange",0.9},{"lead white",0.25}, medium=0.06}
local function word(glyphs, keys, x, y0, w, h, gap, clipm, lw)
  for i, key in ipairs(keys) do
    local y = y0 + (i - 1) * (h + gap)
    for _, s in ipairs(glyphs[key]) do
      local pts = {}
      for _, q in ipairs(s) do pts[#pts+1] = {x - w / 2 + q[1] * w, y + q[2] * h} end
      local b = brush{kind="flat", width=lw, stiffness=0.6}
      b:load(amber, 0.9)
      b:stroke(pts, {pressure={0.85, 0.85}, ramps={0.03, 0.03}, orient="across", clip=clipm})
    end
  end
end
-- near pumps: down the lit flank toward the walkway
local L, Rp = PUMPS[3], PUMPS[4]
local fxL = L.xr - (L.xr - L.xl) * 0.09
local fxR = Rp.xl + (Rp.xr - Rp.xl) * 0.09
word(G, {"P", "dash", "0", "7"}, fxL, L.yb - 2.75 * L.k, 0.17 * L.k, 0.24 * L.k, 0.06 * L.k, L.all, 3.2)
word(G, {"P", "dash", "0", "8"}, fxR, Rp.yb - 2.75 * Rp.k, 0.17 * Rp.k, 0.24 * Rp.k, 0.06 * Rp.k, Rp.all, 3.2)
-- far room, flipped: our P-07 stands on its right, our P-08 on its left, each letter reversed
local FL, FR = PUMPS[1], PUMPS[2]
local fxFR = FR.xl + (FR.xr - FR.xl) * 0.09
local fxFL = FL.xr - (FL.xr - FL.xl) * 0.09
word(R, {"P", "dash", "0", "7"}, fxFR, FR.yb - 2.75 * FR.k, 0.17 * FR.k, 0.24 * FR.k, 0.06 * FR.k, FR.all, 1.3)
word(R, {"P", "dash", "0", "8"}, fxFL, FL.yb - 2.75 * FL.k, 0.17 * FL.k, 0.24 * FL.k, 0.06 * FL.k, FL.all, 1.3)
-- the far hatch's leaf, swung back on the right, its wheel facing the room's centre
local D2 = poly({pt(1.45, FY - 0.25, ZH2), pt(1.45, FY - 0.25, ZH2 - 1.45), pt(1.45, FY - 2.6, ZH2 - 1.45), pt(1.45, FY - 2.6, ZH2)}) * H1B
work(D2, {hand="detail", pile=pile{{"bone black",1.6},{"ultramarine ash",0.9},{"lead white",0.4}, medium=0.06}, coverage=5, fill=true, clip=D2, load=1})
local lit = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",1}, medium=0.06}
local e = brush{kind="round", width=1.0, point=0.4}
e:load(lit, 0.85)
e:stroke({pt(1.27, FY - 0.27, ZH2 - 1.44), pt(1.27, FY - 2.58, ZH2 - 1.44)}, {pressure={0.6, 0.6}})
local wx, wy = P(1.45, FY - 1.35, ZH2 - 0.75)
local wh = {}
for j = 0, 16 do local a = 2 * math.pi * j / 16; wh[#wh+1] = {wx + 1.6 * math.cos(a), wy + 5.5 * math.sin(a)} end
local wb = brush{kind="round", width=0.9, point=0.4}
wb:load(lit, 0.85); wb:stroke(wh, {pressure={0.6, 0.6}})
print(fxL, fxR, fxFL, fxFR, wx, wy)
