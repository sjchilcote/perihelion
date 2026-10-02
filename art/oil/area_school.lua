-- easel session "area_school": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.6, linen={18,16}, seed=4471,
  ground={{pile={{"raw sienna",3},{"burnt sienna",1},{"bone black",0.6},{"lead white",1}}, um=120, apply="knife", texture=0.4}}}
-- perspective
VX, VY, F = 540, 300, 500
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
HW, EYE, CEIL = 5, 1.6, 9   -- half width, eye height, wall height
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
print(W, H)

--@ chunk 2
FL, TOP = EYE, EYE - CEIL      -- floor Y (1.6), wall-top Y (-7.4)
ZN, ZF = 1.2, 30
function wallq(side, za, zb, y0, y1)
  local X = side * HW
  return poly({pt(X, y0, za), pt(X, y0, zb), pt(X, y1, zb), pt(X, y1, za)})
end
-- arched opening on a side wall: Z range, height of shoulder, arch rise
function doorpts(side, za, zb, sh, rise)
  local X = side * HW
  local t = {pt(X, FL, za), pt(X, FL, zb)}
  local n = 16
  for i = 0, n do
    local u = i / n
    local Z = zb + (za - zb) * u
    t[#t+1] = pt(X, FL - sh - rise * math.sin(math.pi * u), Z)
  end
  return t
end
LDOORS = {{5.0, 7.4}, {9.8, 11.5}, {14.6, 16.0}, {21.2, 22.3}}
RDOORS = {{6.6, 9.0}, {12.3, 14.1}, {18.1, 19.6}}
-- vault crown above the far wall
function archpts(Z, y0, crown, n)
  local t = {}
  n = n or 24
  for i = 0, n do
    local a = math.pi * i / n
    local X = -HW * math.cos(a)
    t[#t+1] = pt(X, y0 - crown * math.sin(a), Z)
  end
  return t
end
-- masks of the big regions
local fx0, fy0 = P(-HW, TOP, ZF); local fx1, fy1 = P(HW, FL, ZF)
local farpts = archpts(ZF, TOP, 3.6)
table.insert(farpts, 1, pt(-HW, FL, ZF)); farpts[#farpts+1] = pt(HW, FL, ZF)
FARWALL = poly(farpts)
LWALL = wallq(-1, ZN, ZF, FL, TOP)
RWALL = wallq(1, ZN, ZF, FL, TOP)
FLOOR = poly({pt(-HW, FL, ZN), pt(-HW, FL, ZF), pt(HW, FL, ZF), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
VAULT = everywhere() - LWALL - RWALL - FARWALL - FLOOR
print(fx0, fy0, fx1, fy1, VAULT:area(), FLOOR:area())

--@ chunk 3
VD = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",1}}
WD = pile{{"burnt sienna",2},{"raw sienna",1},{"bone black",1},{"ultramarine blue",0.3}}
WM = pile{{"raw sienna",2},{"bone black",0.8},{"burnt sienna",1}}
WL = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.4}}
local function toVP(x, y) return math.atan(VY - y, VX - x) end
work(VAULT, {hand="body", pile=VD, coverage=2.6, fill=true, clip=true, angle=function(x,y) return toVP(x,y) end})
-- walls, graded by depth: near dark, far lighter
local bands = {{ZN, 5.5, WD}, {5.5, 12, WM}, {12, ZF, WL}}
for _, side in ipairs({-1, 1}) do
  for _, b in ipairs(bands) do
    local m = wallq(side, b[1], b[2], FL, TOP) * (side < 0 and LWALL or RWALL)
    work(m, {hand="body", pile=b[3], coverage=2.6, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.15})
  end
end

--@ chunk 4
LSH, LRISE, RSH, RRISE = 5.2, 1.5, 4.6, 1.8
function poolpts(side, za, zb, sh, rise, dx, dy, dz)
  local src = doorpts(side, za, zb, sh, rise)
  local t = {}
  for i, p in ipairs(src) do
    -- invert projection back to (Y,Z) on the wall
    local Z = F * (side * HW) / (p[1] - VX)
    local Y = (p[2] - VY) * Z / F
    local tt = (FL - Y) / dy
    t[#t+1] = pt(side * HW + dx * tt * (-side), FL, Z + dz * tt)
  end
  return t
end
LPOOL, RPOOL = {}, {}
local allpool = nil
for i, d in ipairs(LDOORS) do
  LPOOL[i] = poly(poolpts(-1, d[1], d[2], LSH, LRISE, -1, 1.25, -0.45)) * FLOOR
  allpool = allpool and (allpool + LPOOL[i]) or LPOOL[i]
end
for i, d in ipairs(RDOORS) do
  RPOOL[i] = poly(poolpts(1, d[1], d[2], RSH, RRISE, -1, 1.5, -0.3)) * FLOOR
  allpool = allpool + RPOOL[i]
end
POOLS = allpool
FD = pile{{"Mars brown",2},{"raw sienna",1},{"bone black",0.7},{"burnt sienna",0.5}}
FM = pile{{"raw sienna",2},{"Mars brown",1},{"bone black",0.5},{"burnt sienna",0.5}}
local function toVP(x, y) return math.atan(VY - y, VX - x) end
local dark = FLOOR - POOLS
local near = poly({pt(-HW, FL, ZN), pt(-HW, FL, 9), pt(HW, FL, 9), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
work(dark * near, {hand="body", pile=FD, coverage=2.6, fill=true, clip=true, angle=toVP, angle_jitter=0.1})
work(dark - near, {hand="body", pile=FM, coverage=2.6, fill=true, clip=true, angle=toVP, angle_jitter=0.1})
print(POOLS:area())

--@ chunk 5
function poolpts(side, za, zb, sh, rise, dy, dz)
  local src = doorpts(side, za, zb, sh, rise)
  local t = {}
  for i, p in ipairs(src) do
    local Z = F * (side * HW) / (p[1] - VX)
    local Y = (p[2] - VY) * Z / F
    local tt = (FL - Y) / dy
    t[#t+1] = pt(side * HW - side * tt, FL, Z + dz * tt)
  end
  return t
end
LPOOL, RPOOL = {}, {}
local allpool
for i, d in ipairs(LDOORS) do
  LPOOL[i] = poly(poolpts(-1, d[1], d[2], LSH, LRISE, 1.25, -0.45)) * FLOOR
  allpool = allpool and (allpool + LPOOL[i]) or LPOOL[i]
end
for i, d in ipairs(RDOORS) do
  RPOOL[i] = poly(poolpts(1, d[1], d[2], RSH, RRISE, 1.6, -0.3)) * FLOOR
  allpool = allpool + RPOOL[i]
end
POOLS = allpool
-- openings and their far jambs
LOPEN, ROPEN, LJAMB, RJAMB = {}, {}, {}, {}
DL = pile{{"lead white",3},{"Mars yellow",1},{"cadmium yellow",0.5}}
DR = pile{{"lead white",2},{"yellow ochre",1},{"Mars yellow",0.5}}
DLO = pile{{"yellow ochre",2},{"Mars orange",1},{"lead white",1}}
for i, d in ipairs(LDOORS) do
  LOPEN[i] = poly(doorpts(-1, d[1], d[2], LSH, LRISE))
  -- far jamb face: plane Z = zb, X from -5 to -5.9
  local zb = d[2]
  LJAMB[i] = poly({pt(-HW, FL, zb), pt(-HW-0.9, FL, zb), pt(-HW-0.9, FL-LSH, zb), pt(-HW, FL-LSH, zb)}) * LOPEN[i]
  local lower = LOPEN[i] * rect(0, select(2, P(-HW, FL-1.6, d[1])), 1000, 600)
  work(LOPEN[i] - LJAMB[i] - lower, {hand="body", pile=DL, coverage=3, fill=true, clip=true, angle=math.pi/2})
  work(lower - LJAMB[i], {hand="body", pile=DLO, coverage=3, fill=true, clip=true, angle=0})
end
for i, d in ipairs(RDOORS) do
  ROPEN[i] = poly(doorpts(1, d[1], d[2], RSH, RRISE))
  local zb = d[2]
  RJAMB[i] = poly({pt(HW, FL, zb), pt(HW+0.9, FL, zb), pt(HW+0.9, FL-RSH, zb), pt(HW, FL-RSH, zb)}) * ROPEN[i]
  work(ROPEN[i] - RJAMB[i], {hand="body", pile=DR, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
print(POOLS:area())

--@ chunk 6
print(wait(24*60))
print(drying(200,200), drying(500,500), drying(80,200))
JL = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1},{"burnt sienna",0.4}}
JR = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.6},{"burnt sienna",0.4}}
for i, d in ipairs(LDOORS) do
  work(LOPEN[i] - LJAMB[i], {hand="body", pile=DL, coverage=3, fill=true, clip=true, angle=math.pi/2})
  work(LJAMB[i], {hand="body", pile=JL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
for i, d in ipairs(RDOORS) do
  work(ROPEN[i] - RJAMB[i], {hand="body", pile=DR, coverage=3, fill=true, clip=true, angle=math.pi/2})
  work(RJAMB[i], {hand="body", pile=JR, coverage=3, fill=true, clip=true, angle=math.pi/2})
end

--@ chunk 7
function doorpts_at(X, side, za, zb, sh, rise)
  local t = {pt(X, FL, za), pt(X, FL, zb)}
  for i = 0, 16 do
    local u = i / 16
    local Z = zb + (za - zb) * u
    t[#t+1] = pt(X, FL - sh - rise * math.sin(math.pi * u), Z)
  end
  return t
end
LREV, RREV = {}, {}
for i, d in ipairs(LDOORS) do
  local outer = poly(doorpts_at(-HW-0.9, -1, d[1], d[2], LSH, LRISE))
  LREV[i] = LOPEN[i] - outer
  work(LREV[i], {hand="body", pile=JL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
for i, d in ipairs(RDOORS) do
  local outer = poly(doorpts_at(HW+0.9, 1, d[1], d[2], RSH, RRISE))
  RREV[i] = ROPEN[i] - outer
  work(RREV[i] , {hand="body", pile=JR, coverage=3, fill=true, clip=true, angle=math.pi/2})
end

--@ chunk 8
print(wait(24*60))
PL = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",1.2},{"raw sienna",0.4}}
PR = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.7},{"burnt sienna",0.2}}
for i = 1, #LPOOL do
  work(LPOOL[i], {hand="body", pile=PL, coverage=2.6, fill=true, edge="firm", angle=0, angle_jitter=0.2})
end
for i = 1, #RPOOL do
  work(RPOOL[i], {hand="body", pile=PR, coverage=2.2, fill=true, edge="firm", angle=0, angle_jitter=0.2})
end

--@ chunk 9
function floorX(x, y) if y <= VY + 1 then return 0 end local Z = F * FL / (y - VY); return (x - VX) * Z / F end
PM = pile{{"raw sienna",2},{"yellow ochre",1},{"Mars brown",1},{"lead white",0.3}}
local farL = mask(function(x, y) return smoothstep(-3.2, -1.6, floorX(x, y)) end)
local farR = mask(function(x, y) return smoothstep(2.8, 1.4, floorX(x, y)) end)
for i = 1, #LPOOL do
  work(LPOOL[i] * farL, {hand="body", pile=PM, coverage=2.0, fill=true, clip=LPOOL[i], angle=0, angle_jitter=0.3})
  blend(LPOOL[i]:grow(5), {angle=0})
end
for i = 1, #RPOOL do
  work(RPOOL[i] * farR, {hand="body", pile=PM, coverage=2.0, fill=true, clip=RPOOL[i], angle=0, angle_jitter=0.3})
  blend(RPOOL[i]:grow(5), {angle=0})
end

--@ chunk 10
local n=0; for i=1,#LPOOL do n=n+lose(LPOOL[i], {pile=FD, tool="filbert 6", reach={6,10}, load=0.25}) end; for i=1,#RPOOL do n=n+lose(RPOOL[i], {pile=FD, tool="filbert 5", reach={5,8}, load=0.25}) end; print(n)

--@ chunk 11
for i=1,#LPOOL do blend(LPOOL[i]:rim(14, 6), {angle=0.3}); blend(LPOOL[i]:rim(14, 6), {angle=1.6}) end; for i=1,#RPOOL do blend(RPOOL[i]:rim(10,4), {angle=0.3}); blend(RPOOL[i]:rim(10,4), {angle=1.6}) end

--@ chunk 12
print(wait(2*24*60))
local near = poly({pt(-HW, FL, ZN), pt(-HW, FL, 9), pt(HW, FL, 9), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
local ring = (POOLS:grow(9) - POOLS) * FLOOR
local function toVP(x, y) return math.atan(VY - y, VX - x) end
work(ring * near, {hand="body", pile=FD, coverage=3, fill=true, clip=true, angle=toVP})
work(ring - near, {hand="body", pile=FM, coverage=3, fill=true, clip=true, angle=toVP})
PP = pile{{"yellow ochre",2},{"Mars yellow",0.6},{"raw sienna",0.8},{"lead white",0.6}}
local z1 = mask(function(x, y) local X = floorX(x, y); return X < -2.6 and 1 or 0 end)
local z2 = mask(function(x, y) local X = floorX(x, y); return (X >= -2.6 and X < -1.2) and 1 or 0 end)
local z3 = mask(function(x, y) local X = floorX(x, y); return X >= -1.2 and 1 or 0 end)
for i = 1, #LPOOL do
  local m = LPOOL[i]
  work(m * z1, {hand="body", pile=PL, coverage=2.5, fill=true, clip=m, angle=toVP})
  work(m * z2, {hand="body", pile=PP, coverage=2.5, fill=true, clip=m, angle=toVP})
  work(m * z3, {hand="body", pile=PM, coverage=2.5, fill=true, clip=m, angle=toVP})
end
local r1 = mask(function(x, y) return floorX(x, y) > 2.4 and 1 or 0 end)
for i = 1, #RPOOL do
  local m = RPOOL[i]
  work(m * r1, {hand="body", pile=PR, coverage=2.5, fill=true, clip=m, angle=toVP})
  work(m - r1, {hand="body", pile=PM, coverage=2.5, fill=true, clip=m, angle=toVP})
end

--@ chunk 13
local s = mask(function(x,y) local X=floorX(x,y); return (math.abs(X+2.6)<0.4 or math.abs(X+1.2)<0.4) and 1 or 0 end):soften(3); for i=1,#LPOOL do blend(LPOOL[i]:shrink(2)*s, {angle=0}) end; local r = mask(function(x,y) return math.abs(floorX(x,y)-2.4)<0.4 and 1 or 0 end):soften(3); for i=1,#RPOOL do blend(RPOOL[i]:shrink(2)*r, {angle=0}) end

--@ chunk 14
local function farpts_(hw, sh, rise)
  local t = {pt(-hw, FL, ZF), pt(hw, FL, ZF)}
  for i = 0, 20 do
    local a = math.pi * i / 20
    t[#t+1] = pt(hw * math.cos(a), FL - sh - rise * math.sin(a), ZF)
  end
  return t
end
MIRROR = poly(farpts_(3.6, 6.2, 1.6))
MFRAME = poly(farpts_(4.0, 6.4, 1.9)) - MIRROR
FW = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.5}}
FR = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6},{"bone black",0.2}}
MS = pile{{"zinc white",2},{"ultramarine ash",0.8},{"lead white",1},{"yellow ochre",0.3}}
MD = pile{{"ultramarine ash",1},{"bone brown",1},{"zinc white",1}}
work(FARWALL - MIRROR - MFRAME, {hand="detail", pile=FW, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(MFRAME, {hand="detail", pile=FR, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(MIRROR, {hand="detail", pile=MS, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- the reflected gallery inside the mirror, its own vanishing point at VX,VY (the mirror at distance doubles)
local mx0, my0 = P(-3.6, FL, ZF)
local function rpt(X, Y, Z) return pt(X, Y, Z) end
-- reflected walls: far end of reflection at Z=62
local RZ = 62
local rl = poly({pt(-3.6, FL, ZF+0.01), pt(-HW, FL, RZ), pt(-HW, TOP, RZ), pt(-3.6, FL-7.8, ZF+0.01)}) * MIRROR
local rr = poly({pt(3.6, FL, ZF+0.01), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(3.6, FL-7.8, ZF+0.01)}) * MIRROR
work(rl + rr, {hand="detail", pile=MD, coverage=2.5, fill=true, clip=true, angle=math.pi/2})
print(mx0, my0, P(3.6, FL-6.2, ZF))

--@ chunk 15
print(wait(24*60))
local RZ = 66
RW = pile{{"raw sienna",2},{"zinc white",1},{"ultramarine ash",0.6},{"bone black",0.3}}
RV = pile{{"bone brown",1},{"ultramarine ash",1},{"zinc white",0.5}}
RF = pile{{"Mars brown",1},{"raw sienna",1},{"zinc white",0.8},{"ultramarine ash",0.3}}
RB = pile{{"raw sienna",1},{"zinc white",1.5},{"ultramarine ash",0.4},{"yellow ochre",0.5}}
RD = pile{{"lead white",3},{"Mars yellow",1},{"zinc white",1}}
local lw = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(-HW, TOP, RZ), pt(-HW, TOP, ZF)}) * MIRROR
local rw = poly({pt(HW, FL, ZF), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(HW, TOP, ZF)}) * MIRROR
local fl = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, FL, ZF)}) * MIRROR
local bw = poly({pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(-HW, TOP, RZ)}) * MIRROR
local vt = MIRROR - lw - rw - fl - bw
work(vt, {hand="detail", pile=RV, coverage=3, fill=true, clip=true})
work(lw + rw, {hand="detail", pile=RW, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(fl, {hand="detail", pile=RF, coverage=3, fill=true, clip=true, angle=0})
work(bw, {hand="detail", pile=RB, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- reflected doors: THREE on the left, FOUR on the right (the mirror disagrees)
local function rdoor(side, za, zb)
  local t = {pt(side*HW, FL, za), pt(side*HW, FL, zb)}
  for i = 0, 8 do
    local u = i / 8
    t[#t+1] = pt(side*HW, FL - 5 - 1.4 * math.sin(math.pi*u), zb + (za - zb)*u)
  end
  return poly(t) * MIRROR
end
local dm = rdoor(-1, 40, 42.5) + rdoor(-1, 47, 49) + rdoor(-1, 55, 56.5)
         + rdoor(1, 38.5, 40.5) + rdoor(1, 44, 45.6) + rdoor(1, 50, 51.4) + rdoor(1, 58, 59)
work(dm, {hand="detail", pile=RD, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- the far mirror seen in the mirror: a small pale arch in the back wall
local sm = poly({pt(-2.2, FL, RZ), pt(2.2, FL, RZ), pt(2.2, FL-4.4, RZ), pt(0, FL-5.6, RZ), pt(-2.2, FL-4.4, RZ)}, true) * MIRROR
work(sm, {hand="detail", pile=MS, coverage=3, fill=true, clip=true, angle=math.pi/2})
print(dm:area(), sm:area())

--@ chunk 16
print(wait(24*60))
local RZ = 120
local lw = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(-HW, TOP, RZ), pt(-HW, TOP, ZF)}) * MIRROR
local rw = poly({pt(HW, FL, ZF), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(HW, TOP, ZF)}) * MIRROR
local fl = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, FL, ZF)}) * MIRROR
local bw = poly({pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(-HW, TOP, RZ)}) * MIRROR
local vt = MIRROR - lw - rw - fl - bw
RW2 = pile{{"raw sienna",2},{"zinc white",0.7},{"ultramarine ash",0.6},{"bone black",0.4}}
work(vt, {hand="detail", pile=RV, coverage=4, fill=true, clip=true})
work(lw + rw, {hand="detail", pile=RW2, coverage=4, fill=true, clip=true, angle=math.pi/2})
work(fl, {hand="detail", pile=RF, coverage=4, fill=true, clip=true, angle=0})
work(bw, {hand="detail", pile=RD, coverage=4, fill=true, clip=true, angle=math.pi/2})
local function rdoor(side, za, zb)
  local t = {pt(side*HW, FL, za), pt(side*HW, FL, zb)}
  for i = 0, 8 do
    local u = i / 8
    t[#t+1] = pt(side*HW, FL - 5 - 1.4 * math.sin(math.pi*u), zb + (za - zb)*u)
  end
  return poly(t) * MIRROR
end
-- the gallery behind us, reflected: three crossings on the left, four on the right
RDM = rdoor(-1, 44, 49) + rdoor(-1, 58, 62) + rdoor(-1, 79, 84)
    + rdoor(1, 41, 46) + rdoor(1, 52, 55) + rdoor(1, 66, 70) + rdoor(1, 90, 95)
work(RDM, {hand="detail", pile=RD, coverage=4, fill=true, clip=true, angle=math.pi/2})
print(RDM:area(), bw:area())

--@ chunk 17
LPIL = {3.4, 8.5, 12.9, 18.0, 24.9, 27.6}
RPIL = {4.6, 10.4, 16.3, 20.9, 25.7, 28.3}
FR2 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.8},{"raw sienna",0.5}}
SHD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6}}
local face, shade, ribs = nil, nil, nil
local function add(a, b) if a then return a + b end return b end
for _, side in ipairs({-1, 1}) do
  local list = side < 0 and LPIL or RPIL
  for _, Z in ipairs(list) do
    local X = side * HW
    local w = 0.55 * F / Z
    -- pilaster face (on the wall plane), and the shadow it throws on its far side
    local f = poly({pt(X, FL, Z), pt(X, FL, Z + 0.55), pt(X, TOP, Z + 0.55), pt(X, TOP, Z)})
    local s = poly({pt(X, FL, Z + 0.55), pt(X, FL, Z + 0.95), pt(X, TOP, Z + 0.95), pt(X, TOP, Z + 0.55)})
    face = add(face, f); shade = add(shade, s)
    -- rib arch over the vault
    local rp = {}
    for i = 0, 24 do
      local a = math.pi * i / 24
      rp[#rp+1] = pt(-HW * math.cos(a), TOP - 3.6 * math.sin(a), Z + 0.27)
    end
    ribs = add(ribs, ribbon(rp, 0.45 * F / Z))
  end
end
ribs = ribs * VAULT
face = face - LOPEN[1] - ROPEN[1]
work(shade, {hand="detail", pile=SHD, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(face, {hand="detail", pile=FR2, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(ribs, {hand="detail", pile=WL, coverage=3, fill=true, clip=true})
print(face:area(), ribs:area())

--@ chunk 18
CB = pile{{"burnt sienna",2},{"bone black",1},{"raw sienna",1}}
CM = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.3}}
CL = pile{{"yellow ochre",2},{"lead white",1.2},{"Mars yellow",0.6}}
BN = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
CS = pile{{"Mars brown",2},{"raw sienna",1},{"bone black",0.4}}
-- a Testator chair standing at floor point (X,Z); dir = +1 back on the right, -1 on the left, 0 back facing us
function chair_masks(X, Z, dir, lean, dx)
  local cx, cy = P(X, FL, Z)
  cx = cx + (dx or 0)
  local s = F / Z
  lean = lean or 0
  local M = {}
  M.foot = ellipse(cx, cy - 0.02*s, 0.24*s, 0.06*s)
  M.ped = poly({{cx - 0.07*s, cy - 0.03*s}, {cx + 0.07*s, cy - 0.03*s}, {cx + 0.035*s, cy - 0.46*s}, {cx - 0.035*s, cy - 0.46*s}})
  M.seat = poly({{cx - 0.40*s, cy - 0.50*s}, {cx - 0.2*s, cy - 0.58*s}, {cx + 0.22*s, cy - 0.58*s}, {cx + 0.42*s, cy - 0.51*s},
                 {cx + 0.3*s, cy - 0.44*s}, {cx - 0.28*s, cy - 0.44*s}}, true)
  if dir == 0 then
    M.back = poly({{cx - 0.30*s, cy - 0.55*s}, {cx - 0.36*s, cy - 0.95*s}, {cx - 0.22*s, cy - 1.32*s}, {cx + lean*s, cy - 1.42*s},
                   {cx + 0.24*s, cy - 1.30*s}, {cx + 0.35*s, cy - 0.95*s}, {cx + 0.28*s, cy - 0.55*s}}, true)
  else
    local bx = cx + dir * 0.36 * s
    M.back = poly({{bx - dir*0.06*s, cy - 0.5*s}, {bx + dir*0.02*s, cy - 0.9*s}, {bx + dir*(0.10+lean)*s, cy - 1.38*s},
                   {bx + dir*(0.16+lean)*s, cy - 1.40*s}, {bx + dir*0.12*s, cy - 0.9*s}, {bx + dir*0.05*s, cy - 0.5*s}}, true)
  end
  M.all = M.foot + M.ped + M.seat + M.back
  M.cx, M.cy, M.s = cx, cy, s
  return M
end
function paint_chair(M, X, Z, dir, lean, light)
  -- light: -1 lit from the left, +1 from the right
  local d = math.max(1.0, 0.035 * M.s)
  local sh = chair_masks(X, Z, dir, lean, -light * d)
  local lit = M.all - sh.all
  work(M.seat:grow(0) - chair_masks(X, Z, dir, lean, 0).seat:shrink(math.max(0.8, 0.02*M.s)) , {hand="detail", pile=CM, coverage=2, fill=true, clip=M.seat})
  work(lit, {hand="detail", pile=CL, coverage=3, fill=true, clip=true})
end
function chair_shadow(X, Z, s, lx, lz, len)
  local pts = {}
  for i = 0, 6 do
    local t = i / 6 * len
    pts[#pts+1] = pt(X + lx * t, FL, Z + lz * t)
  end
  local m = ribbon(pts, 0.32 * s) * FLOOR
  work(m, {hand="detail", pile=CS, coverage=3, fill=true, clip=true})
end
-- chair 1: near left, in the big pool, set square to the wall pier: it faces the blank bronze
local X, Z = -1.7, 3.7
local M = chair_masks(X, Z, 1, 0.04)
chair_shadow(X, Z, M.s, 0.85, -0.3, 1.25)
paint_chair(M, X, Z, 1, 0.04, -1)

--@ chunk 19
local M=chair_masks(-1.7,3.7,1,0.04); local sh=chair_masks(-1.7,3.7,1,0.04,4.8); print(M.s, M.all:area(), sh.all:area(), (M.all-sh.all):area(), M.seat:area(), M.back:area(), M.ped:area(), M.foot:area())

--@ chunk 20
local M=chair_masks(-1.7,3.7,1,0.04); print(drying(M.cx, M.cy-0.5*M.s), M.cx, M.cy-0.5*M.s); work(M.seat, {hand="body", pile=CB, coverage=3, fill=true, clip=true, tool="filbert 4"})

--@ chunk 21
function chair_masks(X, Z, dir, lean, dx)
  local cx, cy = P(X, FL, Z)
  cx = cx + (dx or 0)
  local s = F / Z
  lean = lean or 0
  local M = {}
  M.foot = ellipse(cx, cy - 0.02*s, 0.22*s, 0.055*s)
  M.ped = poly({{cx - 0.08*s, cy - 0.03*s}, {cx + 0.08*s, cy - 0.03*s}, {cx + 0.045*s, cy - 0.46*s}, {cx - 0.045*s, cy - 0.46*s}})
  M.seat = poly({{cx - 0.40*s, cy - 0.50*s}, {cx - 0.2*s, cy - 0.59*s}, {cx + 0.22*s, cy - 0.59*s}, {cx + 0.42*s, cy - 0.52*s},
                 {cx + 0.3*s, cy - 0.43*s}, {cx - 0.28*s, cy - 0.43*s}}, true)
  if dir == 0 then
    M.back = poly({{cx - 0.30*s, cy - 0.55*s}, {cx - 0.36*s, cy - 0.95*s}, {cx - 0.22*s, cy - 1.32*s}, {cx + lean*s, cy - 1.42*s},
                   {cx + 0.24*s, cy - 1.30*s}, {cx + 0.35*s, cy - 0.95*s}, {cx + 0.28*s, cy - 0.55*s}}, true)
  else
    local bx = cx + dir * 0.34 * s
    M.back = poly({{bx - dir*0.10*s, cy - 0.5*s}, {bx - dir*0.02*s, cy - 0.9*s}, {bx + dir*(0.06+lean)*s, cy - 1.36*s},
                   {bx + dir*(0.20+lean)*s, cy - 1.42*s}, {bx + dir*0.16*s, cy - 0.9*s}, {bx + dir*0.08*s, cy - 0.5*s}}, true)
  end
  M.all = M.foot + M.ped + M.seat + M.back
  M.cx, M.cy, M.s = cx, cy, s
  return M
end
function paint_chair(M, X, Z, dir, lean, light)
  local d = math.max(0.8, 0.022 * M.s)
  local sh = chair_masks(X, Z, dir, lean, -light * d)
  local lit = M.all - sh.all
  local tw = math.max(1.5, math.min(5, 0.035 * M.s))
  local tl = {kind="filbert", width=tw}
  work(M.all, {hand="body", tool=tl, pile=CB, coverage=3.5, fill=true, clip=true, angle=math.pi/2})
  work(lit, {hand="body", tool={kind="round", width=math.max(1.2, d)}, pile=CL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
local X, Z = -1.7, 3.7
local M = chair_masks(X, Z, 1, 0.04)
paint_chair(M, X, Z, 1, 0.04, -1)

--@ chunk 22
local function shadow2(X, Z, s, lx, lz, len)
  local pts = {}
  for i = 0, 6 do
    local t = i / 6 * len
    pts[#pts+1] = pt(X + lx * t, FL, Z + lz * t)
  end
  local w = {}
  for i = 0, 6 do w[#w+1] = (0.18 + 0.22 * (i/6)) * s end
  local m = ribbon(pts, w) * FLOOR
  work(m, {hand="body", tool={kind="filbert", width=math.max(1.5, 0.03*s)}, pile=CS, coverage=3, fill=true, clip=true})
end
local chairs = {
  {2.7, 8.2, 0, 0.06, 1, -0.75, -0.25},
  {-0.7, 14.5, -1, 0.0, -1, 0.85, -0.3},
  {1.9, 19.5, 1, 0.03, 1, -0.7, -0.2},
  {-2.6, 23.8, 0, -0.05, -1, 0.85, -0.3},
}
for _, c in ipairs(chairs) do
  local X, Z, dir, lean, light = c[1], c[2], c[3], c[4], c[5]
  local M = chair_masks(X, Z, dir, lean)
  shadow2(X, Z, M.s, c[6], c[7], 1.3)
  paint_chair(M, X, Z, dir, lean, light)
end

--@ chunk 23
-- fold-notation: a polygon holding a smaller copy of itself, turned by the golden angle
GA = math.pi * (3 - math.sqrt(5))
function glyph_pts(n, r, rot, map)
  local t = {}
  for i = 0, n do
    local a = rot + 2 * math.pi * i / n
    t[#t+1] = map(r * math.cos(a), r * math.sin(a))
  end
  return t
end
local bb = brush{kind="round", width=1.8, point=0.4}
local function line(pts, w)
  bb:reload(BN, 0.9)
  bb:stroke(pts, {pressure={0.75, 0.7}, ramps={0.05, 0.1}})
end
-- 1. above the mirror, on the far wall tympanum
local gx, gy = 540, 158
local fmap = function(u, v) return {gx + u, gy + v} end
line(glyph_pts(5, 19, -math.pi/2, fmap))
line(glyph_pts(5, 11.5, -math.pi/2 + GA, fmap))
line(glyph_pts(5, 7, -math.pi/2 + 2*GA, fmap))
-- 2. on the left-wall pier where the fourth crossing is folded in (wall plane: u along Z, v along Y)
local wz, wy = 19.2, -2.6
local wmap = function(u, v) return pt(-HW, wy + v, wz + u) end
line(glyph_pts(6, 0.9, 0, wmap))
line(glyph_pts(6, 0.55, GA, wmap))
line(glyph_pts(6, 0.33, 2*GA, wmap))
-- bone sills in the crossings
local sills
for i, d in ipairs(LDOORS) do
  local s = ribbon({pt(-HW, FL, d[1]), pt(-HW, FL, d[2])}, 0.18 * F / d[1]) * FLOOR:grow(3)
  sills = sills and (sills + s) or s
end
for i, d in ipairs(RDOORS) do
  sills = sills + ribbon({pt(HW, FL, d[1]), pt(HW, FL, d[2])}, 0.18 * F / d[1]) * FLOOR:grow(3)
end
work(sills, {hand="body", tool={kind="filbert", width=2.5}, pile=BN, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 24
print(wait(24*60))
-- cover the rounded first try
work(ellipse(540, 158, 24, 24), {hand="body", tool={kind="filbert", width=3}, pile=FW, coverage=4, fill=true, clip=true, angle=math.pi/2})
local wz, wy = 19.2, -2.6
local disc = poly(glyph_pts(24, 1.25, 0, function(u, v) return pt(-HW, wy + v, wz + u) end))
work(disc, {hand="body", tool={kind="filbert", width=2.5}, pile=WL, coverage=4, fill=true, clip=true, angle=math.pi/2})
-- chair 1 again, over the stray sill band
local X, Z = -1.7, 3.7
local M = chair_masks(X, Z, 1, 0.04)
paint_chair(M, X, Z, 1, 0.04, -1)

--@ chunk 25
print(wait(24*60))

--@ chunk 26
function poly_edges(n, r, rot, map, w)
  local b = brush{kind="round", width=w, point=0.2}
  local p = glyph_pts(n, r, rot, map)
  for i = 1, n do
    b:reload(BN, 0.9)
    b:stroke({p[i], p[i+1]}, {pressure={0.8, 0.75}, ramps={0.08, 0.08}})
  end
end
local gx, gy = 540, 158
local fmap = function(u, v) return {gx + u, gy + v} end
poly_edges(5, 19, -math.pi/2, fmap, 1.7)
poly_edges(5, 11.5, -math.pi/2 + GA, fmap, 1.4)
poly_edges(5, 6.8, -math.pi/2 + 2*GA, fmap, 1.1)
local wz, wy = 19.2, -2.6
local wmap = function(u, v) return pt(-HW, wy + v, wz + u) end
poly_edges(6, 0.95, 0, wmap, 1.3)
poly_edges(6, 0.58, GA, wmap, 1.1)
poly_edges(6, 0.34, 2*GA, wmap, 0.9)

--@ chunk 27
local RZ = 120
local lw = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(-HW, TOP, RZ), pt(-HW, TOP, ZF)}) * MIRROR
local rw = poly({pt(HW, FL, ZF), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(HW, TOP, ZF)}) * MIRROR
local fl = poly({pt(-HW, FL, ZF), pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, FL, ZF)}) * MIRROR
local bw = poly({pt(-HW, FL, RZ), pt(HW, FL, RZ), pt(HW, TOP, RZ), pt(-HW, TOP, RZ)}) * MIRROR
local vt = MIRROR - lw - rw - fl - bw
RV2 = pile{{"bone brown",1},{"ultramarine ash",1},{"zinc white",0.35},{"raw sienna",0.3}}
work(vt, {hand="body", tool={kind="filbert", width=2.5}, pile=RV2, coverage=4, fill=true, clip=true, angle=0})
-- the chair coming out of the mirror: back first, the rear half still silver
local X, Z, dir = 0.9, 29.4, -1
local M = chair_masks(X, Z, dir, 0.02)
paint_chair(M, X, Z, dir, 0.02, 1)
local inside = M.all * rect(0, 0, M.cx - 0.12 * M.s, 625)
work(inside, {hand="body", tool={kind="round", width=1.2}, pile=MS, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- the surface ringing where it passes through
local b = brush{kind="round", width=0.8, point=0.5}
for k, r in ipairs({0.55, 0.9, 1.3}) do
  local pts = {}
  for i = 0, 28 do
    local a = 2 * math.pi * i / 28
    pts[#pts+1] = {M.cx - 0.12 * M.s + 0.22 * r * M.s * math.cos(a), M.cy - 0.75 * M.s + r * 0.75 * M.s * math.sin(a)}
  end
  b:reload(MS, 0.7)
  b:stroke(pts, {pressure={0.5, 0.3}, clip=MIRROR - M.all})
end
print(M.cx, M.cy, M.s)

--@ chunk 28
BS = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.8},{"bone black",0.25}}
SEAM = pile{{"Mars brown",2},{"bone black",1},{"burnt sienna",0.5}}
local function zline(X, z0, z1, wm)
  local pts, ws = {}, {}
  for i = 0, 30 do
    local Z = z0 * (z1 / z0) ^ (i / 30)
    pts[#pts+1] = pt(X, FL, Z); ws[#ws+1] = math.max(0.5, wm * F / Z)
  end
  return ribbon(pts, ws)
end
local function xline(Z, x0, x1, wm)
  return ribbon({pt(x0, FL, Z), pt(x1, FL, Z)}, math.max(0.5, wm * F / Z))
end
-- plate seams: longitudinal and transverse, the transverse ones at uneven golden steps
local seams
for _, X in ipairs({-3.7, -2.05, 2.3, 3.9}) do
  local m = zline(X, 2.4, 29.8, 0.035)
  seams = seams and (seams + m) or m
end
local Z = 3.1
while Z < 29.5 do
  seams = seams + xline(Z, -HW, HW, 0.03)
  Z = Z * (1.18 + 0.1 * math.sin(Z * 2.3))
end
seams = seams * FLOOR
work(seams, {hand="body", tool={kind="round", width=1.3}, pile=SEAM, coverage=2.5, fill=true, clip=true, angle=0})
-- the bone runner down the middle
local run = (zline(-0.62, 2.4, 29.8, 0.07) + zline(0.62, 2.4, 29.8, 0.07)) * FLOOR
work(run - POOLS, {hand="body", tool={kind="round", width=1.5}, pile=BS, coverage=3, fill=true, clip=true, angle=0})
work(run * POOLS, {hand="body", tool={kind="round", width=1.5}, pile=BN, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 29
print(wait(24*60))
CHAIRS = {
  {-1.7, 3.7, 1, 0.04, -1},
  {2.7, 8.2, 0, 0.06, 1},
  {-0.7, 14.5, -1, 0.0, -1},
  {1.9, 19.5, 1, 0.03, 1},
  {-2.6, 23.8, 0, -0.05, -1},
}
local cm
for _, c in ipairs(CHAIRS) do
  local M = chair_masks(c[1], c[2], c[3], c[4])
  cm = cm and (cm + M.all) or M.all
end
CHAIRM = cm
local near = poly({pt(-HW, FL, ZN), pt(-HW, FL, 9), pt(HW, FL, 9), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
local function toVP(x, y) return math.atan(VY - y, VX - x) end
local worn = noise{seed=31, period=60, octaves=3}
local dark = FLOOR - POOLS:grow(2) - CHAIRM:grow(2)
work(dark * near, {hand="scumble", pile=FD, coverage=1.6, load=0.35, clip=true, angle=toVP, load_at=function(x,y) return 0.2 + 0.25*worn:at01(x,y) end})
work(dark - near, {hand="scumble", pile=FM, coverage=1.4, load=0.3, clip=true, angle=toVP, load_at=function(x,y) return 0.15 + 0.25*worn:at01(x,y) end})
local pl = POOLS:shrink(2) - CHAIRM:grow(2)
work(pl, {hand="scumble", pile=PP, coverage=1.2, load=0.3, clip=true, angle=0, load_at=function(x,y) return 0.12 + 0.25*worn:at01(x,y) end})
for _, c in ipairs(CHAIRS) do
  local M = chair_masks(c[1], c[2], c[3], c[4])
  paint_chair(M, c[1], c[2], c[3], c[4], c[5])
end

--@ chunk 30
print(wait(12*60))
local function shadow3(X, Z, s, lx, lz, len, excl)
  local pts, w = {}, {}
  for i = 0, 6 do
    local t = i / 6 * len
    pts[#pts+1] = pt(X + lx * t, FL, Z + lz * t)
    w[#w+1] = (0.16 + 0.24 * (i/6)) * s
  end
  local m = ribbon(pts, w) * FLOOR - excl
  work(m, {hand="body", tool={kind="filbert", width=math.max(1.5, 0.03*s)}, pile=CS, coverage=3, fill=true, clip=true})
end
local L = {{0.85, -0.3}, {-0.75, -0.25}, {0.85, -0.3}, {-0.7, -0.2}, {0.85, -0.3}}
for i, c in ipairs(CHAIRS) do
  local M = chair_masks(c[1], c[2], c[3], c[4])
  shadow3(c[1], c[2], M.s, L[i][1], L[i][2], 1.3, CHAIRM)
  -- stronger lit edge
  local d = math.max(1.0, 0.03 * M.s)
  local sh = chair_masks(c[1], c[2], c[3], c[4], -c[5] * d)
  work(M.all - sh.all, {hand="body", tool={kind="round", width=math.max(1.1, 0.6*d)}, pile=CL, coverage=3, fill=true, clip=true, angle=math.pi/2})
  -- bone inlay: a small disc high on the back
  local bx = M.cx + (c[3] == 0 and 0 or c[3] * 0.40 * M.s)
  local bd = ellipse(bx, M.cy - 1.15 * M.s, math.max(1, 0.035 * M.s), math.max(1, 0.05 * M.s)) * M.back
  work(bd, {hand="body", tool={kind="round", width=math.max(1, 0.03*M.s)}, pile=BN, coverage=3, fill=true, clip=true})
end
-- the bone runner, worn: broken dry strokes
local function zline(X, z0, z1, wm)
  local pts, ws = {}, {}
  for i = 0, 30 do
    local Z = z0 * (z1 / z0) ^ (i / 30)
    pts[#pts+1] = pt(X, FL, Z); ws[#ws+1] = math.max(0.5, wm * F / Z)
  end
  return ribbon(pts, ws)
end
local run = (zline(-0.62, 2.4, 29.8, 0.06) + zline(0.62, 2.4, 29.8, 0.06)) * FLOOR - CHAIRM:grow(2)
work(run - POOLS, {hand="body", tool={kind="round", width=1.4}, pile=BS, coverage=1.8, load=0.45, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
work(run * POOLS, {hand="body", tool={kind="round", width=1.4}, pile=BN, coverage=1.8, load=0.45, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})

--@ chunk 31
VG = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.3}}
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
-- string courses: the two walls carry them at different heights (each at its own crossings' spring)
local function course(side, Y, wm)
  local pts, ws = {}, {}
  for i = 0, 40 do
    local Z = 1.3 * (ZF / 1.3) ^ (i / 40)
    pts[#pts+1] = pt(side * HW, Y, Z); ws[#ws+1] = math.max(0.6, wm * F / Z)
  end
  return ribbon(pts, ws)
end
local sc = (course(-1, FL - LSH, 0.13) * LWALL + course(1, FL - RSH, 0.13) * RWALL) - openings - CHAIRM
work(sc, {hand="body", tool={kind="round", width=2}, pile=BS, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
-- verdigris in the low band of the walls, where the cleaning cycles left it
local low = (wallq(-1, ZN, ZF, FL, FL - 1.1) * LWALL + wallq(1, ZN, ZF, FL, FL - 1.1) * RWALL) - openings - CHAIRM
local vn = noise{seed=77, period=40, octaves=3}
work(low, {hand="scumble", pile=VG, coverage=1.3, clip=true, angle=math.pi/2, load_at=function(x,y) return math.max(0, 0.35 * vn(x,y)) end})

--@ chunk 32
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]; local low = (wallq(-1, ZN, ZF, FL, FL - 1.1) * LWALL + wallq(1, ZN, ZF, FL, FL - 1.1) * RWALL) - openings - CHAIRM; work(low, {hand="scumble", pile=WD, coverage=1.8, load=0.5, clip=true, angle=math.pi/2})

--@ chunk 33
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local walls = (LWALL + RWALL) - openings
-- the upper walls fall into the dark of the vault
local up = walls * rect(0, 0, 1000, 170)
work(up, {hand="scumble", pile=WD, coverage=1.6, clip=true, angle=math.pi/2,
  load_at=function(x, y) return clamp(0.55 - y / 320, 0, 0.55) end})
-- the vault deepens toward its crown
work(VAULT - rect(0, 90, 1000, 600), {hand="scumble", pile=VD, coverage=1.4, clip=true, load=0.45})
-- near openings: the light beyond comes from low; their upper parts warmer and duskier
local tops = (LOPEN[1] + ROPEN[1]) * rect(0, 0, 1000, 150)
work(tops, {hand="scumble", pile=DLO, coverage=1.4, clip=true, angle=math.pi/2,
  load_at=function(x, y) return clamp(0.45 - y / 340, 0, 0.45) end})

--@ chunk 34
-- soften the hard seam in the near openings while the orange is open
local mid = pile{{"lead white",2},{"Mars yellow",1},{"yellow ochre",1},{"Mars orange",0.4}}
for _, pair in ipairs({{LOPEN[1], LREV[1]}, {ROPEN[1], RREV[1]}}) do
  local beyond = pair[1] - pair[2]
  local band = beyond * rect(0, 125, 1000, 50)
  work(band, {hand="body", pile=mid, coverage=2.5, fill=true, clip=true, angle=math.pi/2})
  blend(beyond * rect(0, 105, 1000, 90), {angle=math.pi/2})
end
print(wait(2*24*60))

--@ chunk 35
for _, pair in ipairs({{LOPEN[1], LREV[1]}, {ROPEN[1], RREV[1]}}) do
  work(pair[1] - pair[2], {hand="body", pile=DL, coverage=3.2, fill=true, clip=true, angle=math.pi/2})
end
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local edge = noise{seed=5, period=50, octaves=3}
local upper = mask(function(x, y) return y < 205 + 18 * edge(x, y) and 1 or 0 end)
local up = ((LWALL + RWALL) - openings) * upper
work(up, {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.12})
print(wait(24*60))
-- ribs and pilasters again over the darkened upper wall
local faces, shades, ribs
local function add(a, b) if a then return a + b end return b end
for _, side in ipairs({-1, 1}) do
  local list = side < 0 and LPIL or RPIL
  for _, Z in ipairs(list) do
    local X = side * HW
    faces = add(faces, poly({pt(X, FL, Z), pt(X, FL, Z + 0.55), pt(X, TOP, Z + 0.55), pt(X, TOP, Z)}))
    shades = add(shades, poly({pt(X, FL, Z + 0.55), pt(X, FL, Z + 0.95), pt(X, TOP, Z + 0.95), pt(X, TOP, Z + 0.55)}))
    local rp = {}
    for i = 0, 24 do
      local a = math.pi * i / 24
      rp[#rp+1] = pt(-HW * math.cos(a), TOP - 3.6 * math.sin(a), Z + 0.27)
    end
    ribs = add(ribs, ribbon(rp, 0.45 * F / Z))
  end
end
local zone = up:grow(1)
FR3 = pile{{"yellow ochre",1.5},{"burnt sienna",1},{"raw sienna",1},{"lead white",0.4}}
work((shades * zone) - openings, {hand="body", tool={kind="filbert", width=3}, pile=SHD, coverage=3, fill=true, clip=true, angle=math.pi/2})
work((faces * zone) - openings - LOPEN[1] - ROPEN[1], {hand="body", tool={kind="filbert", width=3}, pile=FR3, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(ribs * VAULT, {hand="body", tool={kind="filbert", width=3}, pile=WL, coverage=3, fill=true, clip=true})

--@ chunk 36
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local function course(side, Y, wm)
  local pts, ws = {}, {}
  for i = 0, 40 do
    local Z = 1.3 * (ZF / 1.3) ^ (i / 40)
    pts[#pts+1] = pt(side * HW, Y, Z); ws[#ws+1] = math.max(0.6, wm * F / Z)
  end
  return ribbon(pts, ws)
end
local sc = (course(-1, FL - LSH, 0.11) * LWALL + course(1, FL - RSH, 0.11) * RWALL) - openings - CHAIRM
work(sc, {hand="body", tool={kind="round", width=2}, pile=BS, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
-- scale-lips in a golden-angle spiral on the near piers, round a bone boss
local dk = brush{kind="round", width=1.6, point=0.3}
local lt = brush{kind="round", width=1.1, point=0.5}
local function medallion(side, zc, yc, n, c)
  local X = side * HW
  for k = n, 1, -1 do
    local r = c * math.sqrt(k)
    local a = k * GA
    local zz, yy = zc + r * math.cos(a), yc + r * math.sin(a)
    local sz = 0.11 + 0.02 * math.sqrt(k)
    -- a lip: a short downward U on the wall plane, lit line just above it
    local u = {}
    for i = 0, 6 do
      local t = -1 + 2 * i / 6
      u[#u+1] = pt(X, yy + sz * 0.55 * (1 - t * t), zz + sz * t)
    end
    dk:reload(SHD, 0.7); dk:stroke(u, {pressure={0.6, 0.4}})
    local l = {}
    for i = 0, 6 do
      local t = -0.8 + 1.6 * i / 6
      l[#l+1] = pt(X, yy - 0.05 + sz * 0.5 * (1 - t * t), zz + sz * t)
    end
    lt:reload(FR2, 0.7); lt:stroke(l, {pressure={0.45, 0.2}})
  end
  local boss = poly(glyph_pts(20, 0.22, 0, function(u, v) return pt(X, yc + v, zc + u) end))
  work(boss, {hand="body", tool={kind="round", width=2}, pile=BN, coverage=3, fill=true, clip=true})
end
medallion(-1, 8.6, -0.6, 70, 0.115)
medallion(1, 10.7, -1.2, 60, 0.13)

--@ chunk 37
-- crisp lit inner edge of the mirror frame
local inner = MIRROR:grow(1.6) - MIRROR
work(inner * rect(0, 0, 545, 625), {hand="body", tool={kind="round", width=1.2}, pile=CL, coverage=3, fill=true, clip=true})
-- the chairs nearest the mirror still carry silver on their backs
SIL = pile{{"zinc white",2},{"ultramarine ash",0.6},{"lead white",1},{"raw sienna",0.2}}
for _, i in ipairs({4, 5}) do
  local c = CHAIRS[i]
  local M = chair_masks(c[1], c[2], c[3], c[4])
  local top = M.back * rect(0, 0, 1000, M.cy - 1.0 * M.s)
  work(top, {hand="body", tool={kind="round", width=1.1}, pile=SIL, coverage=2.5, fill=true, clip=true, angle=math.pi/2})
end
-- the emerging chair: its still-mirrored rear half, restated pale
local X, Z, dir = 0.9, 29.4, -1
local M = chair_masks(X, Z, dir, 0.02)
local inside = M.all * rect(0, 0, M.cx - 0.1 * M.s, 625)
work(inside, {hand="body", tool={kind="round", width=1.0}, pile=SIL, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 38
local mid2 = pile{{"lead white",1.6},{"Mars yellow",1},{"yellow ochre",1.2},{"Mars orange",0.5},{"raw sienna",0.3}}
for _, pair in ipairs({{LOPEN[1], LREV[1]}, {ROPEN[1], RREV[1]}}) do
  work(pair[1] - pair[2], {hand="body", pile=mid2, coverage=3.2, fill=true, clip=true, angle=math.pi/2})
end
-- the light at the end of the reflected gallery
local HOT = pile{{"zinc white",3},{"lemon chrome",0.4},{"lead white",1}}
local bw = poly({pt(-HW*0.7, FL, 120), pt(HW*0.7, FL, 120), pt(HW*0.7, FL-6, 120), pt(-HW*0.7, FL-6, 120)}) * MIRROR
work(bw, {hand="body", tool={kind="round", width=1.5}, pile=HOT, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 39
-- the floor is polished bronze: each lit crossing is reflected in it, fading below the wall line
local function reflpts(side, za, zb, depth)
  local X = side * HW
  local t = {}
  local n = 10
  for i = 0, n do
    local Z = za + (zb - za) * i / n
    t[#t+1] = pt(X - side * 0.02, FL, Z)
  end
  for i = n, 0, -1 do
    local Z = za + (zb - za) * i / n
    -- mirrored height, cut short: the sheen dies out a few meters down
    local x, y = P(X, FL + depth, Z)
    t[#t+1] = {x, y}
  end
  return poly(t, true)
end
local GZ = pile{{"yellow ochre",2},{"Mars yellow",1},{"lead white",0.5}, medium=0.7}
local refl
for i, d in ipairs(LDOORS) do
  local m = reflpts(-1, d[1], d[2], 3.2)
  refl = refl and (refl + m) or m
end
for i, d in ipairs(RDOORS) do refl = refl + reflpts(1, d[1], d[2], 2.8) end
refl = (refl * FLOOR) - CHAIRM:grow(2)
REFL = refl
work(refl, {hand="glaze", pile=GZ, clip=true, angle=math.pi/2, load=0.25, pressure={0.1, 0.25}})
blend(refl, {angle=math.pi/2})
-- the mirror's own cool reflection, straight down the floor toward us
local SG = pile{{"zinc white",2},{"ultramarine ash",0.5},{"yellow ochre",0.5}, medium=0.7}
local mr = poly({pt(-3.0, FL, ZF), pt(3.0, FL, ZF), pt(2.6, FL + 2.2, ZF), pt(-2.6, FL + 2.2, ZF)}) * FLOOR - CHAIRM:grow(1)
work(mr, {hand="glaze", tool={kind="filbert", width=4, stiffness=0.2}, pile=SG, clip=true, angle=math.pi/2, load=0.25, pressure={0.1, 0.25}})
blend(mr, {angle=math.pi/2, tool={kind="badger", width=6}})
print(refl:area(), mr:area())

--@ chunk 40
local m = REFL * rect(0, 395, 1000, 300); for k=1,6 do work(m, {hand="scumble", blender=true, coverage=1.5, clip=true, angle=math.pi/2 + 0.3*(k%2)}) end

--@ chunk 41
print(wait(2*24*60))
local m = (REFL * rect(0, 395, 1000, 300)):grow(3) * FLOOR - POOLS - CHAIRM:grow(1)
local near = poly({pt(-HW, FL, ZN), pt(-HW, FL, 9), pt(HW, FL, 9), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
work(m * near, {hand="body", pile=FD, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
work(m - near, {hand="body", pile=FM, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
-- inside the pools, the lifted veil: restate pool colour there
local mp = (REFL * rect(0, 395, 1000, 300)):grow(3) * POOLS - CHAIRM:grow(1)
work(mp, {hand="body", pile=PP, coverage=2.5, fill=true, clip=true, angle=0})

--@ chunk 42
local function zline(X, z0, z1, wm)
  local pts, ws = {}, {}
  for i = 0, 30 do
    local Z = z0 * (z1 / z0) ^ (i / 30)
    pts[#pts+1] = pt(X, FL, Z); ws[#ws+1] = math.max(0.5, wm * F / Z)
  end
  return ribbon(pts, ws)
end
RUN = (zline(-0.62, 2.4, 29.8, 0.065) + zline(0.62, 2.4, 29.8, 0.065)) * FLOOR - CHAIRM:grow(2)
BS2 = pile{{"yellow ochre",1},{"raw sienna",1},{"bone black",0.25},{"lead white",0.35}}
work(RUN - POOLS - REFL, {hand="body", tool={kind="round", width=1.5}, pile=BS2, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
-- golden-angle rosettes of bone studs set into the runner, at uneven steps
local st = brush{kind="round", width=1.2}
local Z = 4.3
local k = 0
while Z < 27 do
  k = k + 1
  local s = F / Z
  local n = 21
  for j = 1, n do
    local r = 0.09 * math.sqrt(j)
    local a = j * GA
    local x, y = P(r * math.cos(a), FL, Z + r * math.sin(a))
    st:reload((POOLS:at(x, y) > 0.5) and BN or BS, 0.8)
    st:touch(x, y, {pressure=clamp(0.04 * s, 0.15, 0.9)})
  end
  Z = Z * (1.45 + 0.2 * math.sin(k * 1.7))
end

--@ chunk 43
local Z = 4.3
local k = 0
while Z < 27 do
  k = k + 1
  local s = F / Z
  local st = brush{kind="round", width=math.max(1.2, 0.05 * s)}
  for j = 1, 21 do
    local r = 0.085 * math.sqrt(j)
    local a = j * GA
    local x, y = P(r * math.cos(a), FL, Z + r * math.sin(a))
    st:reload((POOLS:at(x, y) > 0.5) and BN or BS, 0.85)
    st:touch(x, y, {pressure=0.7})
  end
  Z = Z * (1.45 + 0.2 * math.sin(k * 1.7))
end

--@ chunk 44
-- what lies beyond the near crossings: a lit room whose far wall carries its own crossings
local BF = pile{{"yellow ochre",2},{"raw sienna",1},{"Mars orange",0.3},{"lead white",0.5}}
local BD = pile{{"burnt sienna",1.5},{"raw sienna",1},{"bone black",0.5},{"yellow ochre",0.5}}
for _, side in ipairs({-1, 1}) do
  local beyond = side < 0 and (LOPEN[1] - LREV[1]) or (ROPEN[1] - RREV[1])
  local XB = side * 14
  local floorb = beyond * mask(function(x, y) return (y > 300 + 800 * (x - 540) / (500 * XB)) and 1 or 0 end)
  work(floorb, {hand="body", pile=BF, coverage=3, fill=true, clip=true, angle=0})
  -- the far wall's own arched openings, at uneven steps, dark against the light
  local zs = side < 0 and {{14.6, 15.8}, {17.9, 18.5}, {20.6, 22.2}} or {{13.8, 15.2}, {18.2, 19.6}}
  local holes
  for _, z in ipairs(zs) do
    local t = {pt(XB, FL, z[1]), pt(XB, FL, z[2])}
    for i = 0, 10 do
      local u = i / 10
      t[#t+1] = pt(XB, FL - 4.2 - 1.2 * math.sin(math.pi * u), z[2] + (z[1] - z[2]) * u)
    end
    local m = poly(t)
    holes = holes and (holes + m) or m
  end
  work(holes * beyond, {hand="body", tool={kind="filbert", width=3}, pile=BD, coverage=3, fill=true, clip=true, angle=math.pi/2})
end

--@ chunk 45
local ribs
for _, list in ipairs({LPIL, RPIL}) do
  for _, Z in ipairs(list) do
    local rp = {}
    for i = 0, 24 do
      local a = math.pi * i / 24
      rp[#rp+1] = pt(-HW * math.cos(a), TOP - 3.6 * math.sin(a), Z + 0.27)
    end
    local r = ribbon(rp, 0.45 * F / Z)
    ribs = ribs and (ribs + r) or r
  end
end
RIBS = ribs * VAULT
VD2 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.5},{"raw sienna",0.3}}
work(VAULT - RIBS:grow(1), {hand="body", pile=VD2, coverage=3, fill=true, clip=true, angle=0, angle_jitter=0.3})

--@ chunk 46
local function ribm(dy)
  local ribs
  for _, list in ipairs({LPIL, RPIL}) do
    for _, Z in ipairs(list) do
      local rp = {}
      for i = 0, 24 do
        local a = math.pi * i / 24
        rp[#rp+1] = pt(-HW * math.cos(a), TOP - 3.6 * math.sin(a) + dy, Z + 0.27)
      end
      local r = ribbon(rp, 0.45 * F / Z)
      ribs = ribs and (ribs + r) or r
    end
  end
  return ribs
end
local under = RIBS - ribm(-0.16)   -- the lower edge, catching the light from the floor
local over = RIBS - ribm(0.16)     -- the upper edge, in shadow
work(over, {hand="body", tool={kind="round", width=1.5}, pile=SHD, coverage=3, fill=true, clip=true})
work(under, {hand="body", tool={kind="round", width=1.5}, pile=FR2, coverage=3, fill=true, clip=true})
-- small warm apertures along the crown between the ribs: the station keeps a few lights for its guests
local LW = pile{{"lead white",3},{"cadmium yellow",1},{"Mars orange",0.3}}
local all = {}
for _, z in ipairs(LPIL) do all[#all+1] = z end
for _, z in ipairs(RPIL) do all[#all+1] = z end
table.sort(all)
local st = brush{kind="round", width=1.6}
for i = 1, #all - 1 do
  local z = (all[i] + all[i+1]) / 2 + 0.27
  for j = -2, 2 do
    local a = math.pi / 2 + j * 0.28 + 0.05 * math.sin(i * 2.1 + j)
    local x, y = P(-HW * math.cos(a) * 0.98, TOP - 3.6 * math.sin(a) * 0.98, z)
    if VAULT:at(x, y) > 0.5 and RIBS:at(x, y) < 0.1 and y > 2 then
      st:reload(LW, 0.8)
      st:touch(x, y, {pressure=clamp(0.03 * F / z, 0.25, 0.8)})
    end
  end
end

--@ chunk 47
local LW = pile{{"lead white",3},{"cadmium yellow",1},{"Mars orange",0.3}}
local all = {}
for _, z in ipairs(LPIL) do all[#all+1] = z end
for _, z in ipairs(RPIL) do all[#all+1] = z end
table.sort(all)
local n = 0
for i = 1, #all - 1 do
  local z = (all[i] + all[i+1]) / 2 + 0.27
  local st = brush{kind="round", width=clamp(0.22 * F / z, 1.4, 6)}
  -- uneven: golden-angle offsets, some cells keep fewer lights
  local cnt = 2 + (i * 3) % 3
  for j = 1, cnt do
    local a = math.pi / 2 + ((j * GA) % 1.4 - 0.7)
    local x, y = P(-HW * math.cos(a) * 0.97, TOP - 3.6 * math.sin(a) * 0.97, z)
    if VAULT:at(x, y) > 0.5 and RIBS:at(x, y) < 0.1 and y > 3 then
      st:reload(LW, 0.9)
      st:touch(x, y, {pressure=0.8})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 48
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local walls = (LWALL + RWALL) - openings - CHAIRM:grow(2)
WS = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.5},{"burnt sienna",0.3}}
-- brushed-bronze sheen, vertical dry strokes, thicker toward the crossings' light
local lower = walls * mask(function(x, y) return (y > 120 and y < 470) and 1 or 0 end)
work(lower, {hand="body", tool={kind="filbert", width=2.5}, pile=WS, coverage=0.7, load=0.12, pressure={0.12, 0.3},
  clip=true, angle=math.pi/2, angle_jitter=0.05, length={20, 70}})
-- tarnish: darker dry strokes on the upper walls
local upper = walls * mask(function(x, y) return y < 220 and 1 or 0 end)
work(upper, {hand="body", tool={kind="filbert", width=3}, pile=SHD, coverage=0.6, load=0.12, pressure={0.12, 0.3},
  clip=true, angle=math.pi/2, angle_jitter=0.05, length={20, 80}})

--@ chunk 49
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local walls = (LWALL + RWALL) - openings - CHAIRM:grow(2)
local m = walls * mask(function(x, y) return (y < 475) and 1 or 0 end)
for k = 1, 4 do
  work(m, {hand="scumble", blender=true, coverage=1.3, clip=true, angle=math.pi/2 + 0.25 * (k % 2 == 0 and 1 or -1)})
end

--@ chunk 50
print(wait(24*60))
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local walls = (LWALL + RWALL) - openings - CHAIRM:grow(1)
local edge = noise{seed=5, period=50, octaves=3}
local upper = mask(function(x, y) return y < 205 + 18 * edge(x, y) and 1 or 0 end)
local low = (wallq(-1, ZN, ZF, FL, FL - 1.1) + wallq(1, ZN, ZF, FL, FL - 1.1))
local mid = walls - upper - low
work(walls * upper, {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.1})
work(walls * low, {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.1})
local bands = {{ZN, 5.5, WD}, {5.5, 12, WM}, {12, ZF, WL}}
for _, side in ipairs({-1, 1}) do
  for _, b in ipairs(bands) do
    local m = wallq(side, b[1], b[2], FL, TOP) * mid
    work(m, {hand="body", pile=b[3], coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.1})
  end
end

--@ chunk 51
print(wait(24*60))
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local edge = noise{seed=5, period=50, octaves=3}
local upper = mask(function(x, y) return y < 205 + 18 * edge(x, y) and 1 or 0 end)
local faces, shades
local function add(a, b) if a then return a + b end return b end
for _, side in ipairs({-1, 1}) do
  local list = side < 0 and LPIL or RPIL
  for _, Z in ipairs(list) do
    local X = side * HW
    faces = add(faces, poly({pt(X, FL, Z), pt(X, FL, Z + 0.55), pt(X, TOP, Z + 0.55), pt(X, TOP, Z)}))
    shades = add(shades, poly({pt(X, FL, Z + 0.55), pt(X, FL, Z + 0.95), pt(X, TOP, Z + 0.95), pt(X, TOP, Z + 0.55)}))
  end
end
faces = faces - openings - CHAIRM:grow(1)
shades = shades - openings - CHAIRM:grow(1)
work(shades, {hand="body", tool={kind="filbert", width=3}, pile=SHD, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(faces - upper, {hand="body", tool={kind="filbert", width=3}, pile=FR2, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(faces * upper, {hand="body", tool={kind="filbert", width=3}, pile=WM, coverage=3, fill=true, clip=true, angle=math.pi/2})
PILF = faces
-- string courses
local function course(side, Y, wm)
  local pts, ws = {}, {}
  for i = 0, 40 do
    local Z = 1.3 * (ZF / 1.3) ^ (i / 40)
    pts[#pts+1] = pt(side * HW, Y, Z); ws[#ws+1] = math.max(0.6, wm * F / Z)
  end
  return ribbon(pts, ws)
end
local sc = (course(-1, FL - LSH, 0.11) * LWALL + course(1, FL - RSH, 0.11) * RWALL) - openings - CHAIRM
work(sc, {hand="body", tool={kind="round", width=2}, pile=BS, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
-- a thin bone line capping the dark dado
local dc = (course(-1, FL - 1.1, 0.05) * LWALL + course(1, FL - 1.1, 0.05) * RWALL) - openings - CHAIRM
work(dc, {hand="body", tool={kind="round", width=1.4}, pile=BS2, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})

--@ chunk 52
local dk = brush{kind="round", width=1.6, point=0.3}
local lt = brush{kind="round", width=1.1, point=0.5}
function medallion(side, zc, yc, n, c, lip)
  local X = side * HW
  local s0 = F / zc
  dk = brush{kind="round", width=clamp(0.03 * s0, 0.9, 1.8), point=0.3}
  lt = brush{kind="round", width=clamp(0.02 * s0, 0.7, 1.2), point=0.5}
  for k = n, 1, -1 do
    local r = c * math.sqrt(k)
    local a = k * GA
    local zz, yy = zc + r * math.cos(a), yc + r * math.sin(a)
    local sz = lip + 0.018 * math.sqrt(k)
    local u, l = {}, {}
    for i = 0, 6 do
      local t = -1 + 2 * i / 6
      u[#u+1] = pt(X, yy + sz * 0.55 * (1 - t * t), zz + sz * t)
      local t2 = -0.8 + 1.6 * i / 6
      l[#l+1] = pt(X, yy - 0.05 + sz * 0.5 * (1 - t2 * t2), zz + sz * t2)
    end
    dk:reload(SHD, 0.7); dk:stroke(u, {pressure={0.6, 0.4}})
    lt:reload(FR2, 0.7); lt:stroke(l, {pressure={0.45, 0.2}})
  end
  local boss = poly(glyph_pts(20, 0.2, 0, function(u, v) return pt(X, yc + v, zc + u) end))
  work(boss, {hand="body", tool={kind="round", width=clamp(0.04 * s0, 1, 2.5)}, pile=BN, coverage=3, fill=true, clip=true})
end
medallion(-1, 7.95, -0.5, 72, 0.112, 0.11)
medallion(-1, 13.6, -1.1, 55, 0.125, 0.12)
medallion(-1, 17.0, -0.2, 40, 0.15, 0.14)
medallion(1, 10.0, -1.0, 64, 0.12, 0.12)
medallion(1, 15.2, -0.4, 47, 0.14, 0.13)
medallion(1, 22.5, -1.3, 34, 0.16, 0.15)
-- the fold glyph again, where the fourth crossing folds into the wall
local wz, wy = 19.6, -2.8
local wmap = function(u, v) return pt(-HW, wy + v, wz + u) end
local disc = poly(glyph_pts(24, 1.15, 0, wmap))
work(disc, {hand="body", tool={kind="filbert", width=2.5}, pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2})
poly_edges(6, 0.95, 0, wmap, 1.3)
poly_edges(6, 0.58, GA, wmap, 1.1)
poly_edges(6, 0.34, 2*GA, wmap, 0.9)

--@ chunk 53
function beam_mask(side, d, sh, rise, dy, dz)
  local A = doorpts(side, d[1], d[2], sh, rise)
  local B = poolpts(side, d[1], d[2], sh, rise, dy, dz)
  local m
  for i = 1, #A - 1 do
    local q = poly({A[i], A[i+1], B[i+1], B[i]})
    m = m and (m + q) or q
  end
  local q = poly({A[#A], A[1], B[1], B[#B]})
  return m + q
end
BEAM = pile{{"lead white",2},{"yellow ochre",0.5},{"Mars orange",0.25}, medium=0.6}
local bm = (beam_mask(-1, LDOORS[1], LSH, LRISE, 1.25, -0.45) - LOPEN[1]) - CHAIRM:grow(1)
bm = bm:soften(4)
work(bm, {hand="glaze", pile=BEAM, clip=true, load=0.25, pressure={0.1, 0.22}, angle=math.atan(1.25, 1) })
blend(bm, {angle=math.atan(1.25, 1)})

--@ chunk 54
local bm = (beam_mask(-1, LDOORS[1], LSH, LRISE, 1.25, -0.45) - LOPEN[1]) - CHAIRM:grow(1); for k=1,6 do work(bm, {hand="scumble", blender=true, coverage=1.5, clip=true, angle=math.pi/2 + 0.4*(k%2==0 and 1 or -1)}) end

--@ chunk 55
print(wait(3*24*60))
BEAMW = pile{{"Mars orange",1},{"rose madder",0.3},{"yellow ochre",0.6},{"burnt sienna",0.2}, medium=0.8}
BMASK = (beam_mask(-1, LDOORS[1], LSH, LRISE, 1.25, -0.45) - LOPEN[1]) - CHAIRM:grow(1)
work(BMASK, {hand="glaze", pile=BEAMW, clip=true, load=0.3, pressure={0.12, 0.25}, angle=math.atan(1.25, 1)})
blend(BMASK, {angle=math.atan(1.25, 1)})

--@ chunk 56
blend(BMASK, {angle=math.atan(1.25,1) + math.pi/2}); blend(BMASK, {angle=math.atan(1.25,1)})

--@ chunk 57
print(wait(2*24*60))
local c = CHAIRS[1]
local M = chair_masks(c[1], c[2], c[3], c[4])
local s, cx, cy = M.s, M.cx, M.cy
-- seat top catching the light
local top = ellipse(cx + 0.0 * s, cy - 0.535 * s, 0.37 * s, 0.04 * s) * M.seat
work(top, {hand="body", tool={kind="filbert", width=3}, pile=CM, coverage=3, fill=true, clip=true, angle=0})
local topl = ellipse(cx - 0.12 * s, cy - 0.545 * s, 0.22 * s, 0.022 * s) * M.seat
work(topl, {hand="body", tool={kind="round", width=2}, pile=CL, coverage=3, fill=true, clip=true, angle=0})
-- bone inlay on the seat rim
local rim = (M.seat - ellipse(cx, cy - 0.50 * s, 0.40 * s, 0.06 * s)) * rect(0, cy - 0.47 * s, 1000, 0.05 * s)
work(rim, {hand="body", tool={kind="round", width=1.5}, pile=BN, coverage=3, fill=true, clip=true, angle=0})
-- the back: a long lit stroke on its light side and a dark core, wet into each other
local bx = cx + 0.34 * s
local b = brush{kind="round", width=6, point=0.6}
b:reload(CL, 0.8)
b:stroke({{bx - 0.075 * s, cy - 0.52 * s}, {bx - 0.005 * s, cy - 0.9 * s}, {bx + 0.085 * s, cy - 1.33 * s}}, {pressure={0.5, 0.15}, clip=M.back})
local d = brush{kind="filbert", width=6}
d:reload(CB, 0.8)
d:stroke({{bx + 0.02 * s, cy - 0.55 * s}, {bx + 0.07 * s, cy - 0.9 * s}, {bx + 0.15 * s, cy - 1.3 * s}}, {pressure={0.6, 0.3}, clip=M.back})
-- pedestal: a lit line down its left
local p = brush{kind="round", width=3, point=0.5}
p:reload(CL, 0.8)
p:stroke({{cx - 0.06 * s, cy - 0.06 * s}, {cx - 0.035 * s, cy - 0.44 * s}}, {pressure={0.5, 0.35}, clip=M.ped})

--@ chunk 58
local X, Z, dir, lean, light = 2.35, 3.05, 0, 0.03, 1
local M = chair_masks(X, Z, dir, lean)
-- its shadow, thrown left and toward us by the north crossing's light
local pts, w = {}, {}
for i = 0, 6 do
  local t = i / 6 * 1.2
  pts[#pts+1] = pt(X - 0.75 * t, FL, Z - 0.2 * t)
  w[#w+1] = (0.2 + 0.3 * (i / 6)) * M.s
end
local sm = ribbon(pts, w) * FLOOR - M.all - CHAIRM
CS2 = pile{{"Mars brown",2},{"bone black",0.8},{"burnt sienna",0.4}}
work(sm, {hand="body", tool={kind="filbert", width=4}, pile=CS2, coverage=3, fill=true, clip=true})
paint_chair(M, X, Z, dir, lean, light)
-- seat top and a bone boss at the crown of the back
local s, cx, cy = M.s, M.cx, M.cy
local top = ellipse(cx + 0.02 * s, cy - 0.535 * s, 0.37 * s, 0.04 * s) * M.seat - M.back
work(top, {hand="body", tool={kind="filbert", width=3}, pile=CM, coverage=3, fill=true, clip=true, angle=0})
local bd = ellipse(cx + lean * s, cy - 1.2 * s, 0.05 * s, 0.065 * s) * M.back
work(bd, {hand="body", tool={kind="round", width=2}, pile=BN, coverage=3, fill=true, clip=true})
-- a bone ring around it: the boss is the centre of a small golden-angle rosette of studs
local st = brush{kind="round", width=2.2}
for j = 1, 13 do
  local r = 0.035 * math.sqrt(j + 4)
  local a = j * GA
  local x, y = cx + lean * s + r * s * math.cos(a), cy - 1.2 * s + 1.15 * r * s * math.sin(a)
  if M.back:at(x, y) > 0.6 then st:reload(BS, 0.8); st:touch(x, y, {pressure=0.6}) end
end
CHAIRM = CHAIRM + M.all
CHAIRS[#CHAIRS+1] = {X, Z, dir, lean, light}

--@ chunk 59
-- the worn arris where each wall turns into its crossing: a crisp lit edge
local HL = pile{{"lead white",2},{"yellow ochre",1},{"Mars yellow",0.5}}
for i = 1, #LDOORS do
  local w = clamp(0.06 * F / LDOORS[i][1], 0.8, 3)
  local band = (LOPEN[i]:grow(w) - LOPEN[i]) * LREV[i]:grow(w + 1) - CHAIRM:grow(1)
  work(band, {hand="body", tool={kind="round", width=math.max(1, w)}, pile=HL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
for i = 1, #RDOORS do
  local w = clamp(0.06 * F / RDOORS[i][1], 0.8, 3)
  local band = (ROPEN[i]:grow(w) - ROPEN[i]) * RREV[i]:grow(w + 1) - CHAIRM:grow(1)
  work(band, {hand="body", tool={kind="round", width=math.max(1, w)}, pile=HL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end

--@ chunk 60
print(wait(24*60))
-- polished sheen on the egg backs that face us: a long soft highlight on the lit side, a reflected glint opposite
for _, i in ipairs({2, 6}) do
  local c = CHAIRS[i]
  local M = chair_masks(c[1], c[2], c[3], c[4])
  local s, cx, cy = M.s, M.cx + c[4] * M.s, M.cy
  local b = brush{kind="round", width=math.max(2, 0.07 * s), point=0.7}
  b:reload(CL, 0.6)
  b:stroke({{cx + 0.2 * s, cy - 0.68 * s}, {cx + 0.25 * s, cy - 0.95 * s}, {cx + 0.17 * s, cy - 1.22 * s}, {cx + 0.05 * s, cy - 1.36 * s}},
    {pressure={0.15, 0.55}, swell={0.6, 1.0, 0.5}, clip=M.back})
  local g = brush{kind="round", width=math.max(1.5, 0.05 * s), point=0.7}
  g:reload(CM, 0.6)
  g:stroke({{cx - 0.27 * s, cy - 0.75 * s}, {cx - 0.30 * s, cy - 0.98 * s}, {cx - 0.2 * s, cy - 1.2 * s}},
    {pressure={0.1, 0.4}, clip=M.back})
end

--@ chunk 61
-- silver left on the floor by the chairs that walked out of the mirror: drips thinning as they dry off
local st = brush{kind="round", width=2, point=0.3}
local paths = {{CHAIRS[4], 0.4}, {CHAIRS[5], -0.6}, {{0.9, 29.4}, 0.2}}
for pi, pth in ipairs(paths) do
  local c = pth[1]
  local X1, Z1 = c[1], c[2]
  local X0, Z0 = X1 * 0.5 + pth[2], 29.85
  local n = 9
  for k = 0, n do
    local t = k / n
    if pi == 3 then t = t * 0.35 end
    local X = lerp(X0, X1, t) + 0.12 * math.sin(k * 2.3 + pi)
    local Z = lerp(Z0, Z1 + 0.6, t)
    local x, y = P(X, FL, Z)
    if CHAIRM:at(x, y) < 0.1 then
      local s = F / Z
      st = brush{kind="round", width=clamp(0.09 * s * (1 - 0.6 * t), 0.8, 3.5), point=0.3}
      st:reload(SIL, 0.8)
      st:touch(x, y, {pressure=0.6, drag={0.04 * s, 0}})
    end
  end
end

--@ chunk 62
-- SECOND PASS. Paint out the glassy shaft: rebuild everything under it.
local BM2 = BMASK:grow(3) - CHAIRM:grow(1)
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local edge = noise{seed=5, period=50, octaves=3}
local upper = mask(function(x, y) return y < 205 + 18 * edge(x, y) and 1 or 0 end)
local low = wallq(-1, ZN, ZF, FL, FL - 1.1)
local walls = (LWALL - openings) * BM2
work(walls * upper, {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.1})
work(walls * low, {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2, angle_jitter=0.1})
local mid = walls - upper - low
work(mid * wallq(-1, ZN, 5.5, FL, TOP), {hand="body", pile=WD, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(mid * wallq(-1, 5.5, 12, FL, TOP), {hand="body", pile=WM, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(mid * wallq(-1, 12, ZF, FL, TOP), {hand="body", pile=WL, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- the second crossing inside the wedge: beyond and reveal
work((LOPEN[2] - LREV[2]) * BM2, {hand="body", pile=DL, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(LREV[2] * BM2, {hand="body", pile=JL, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- floor under the wedge: the pool is light, the rest dark floor
local fl = FLOOR * BM2
local near = poly({pt(-HW, FL, ZN), pt(-HW, FL, 9), pt(HW, FL, 9), pt(HW, FL, ZN)}) + rect(0, 560, 1000, 70)
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local dark = fl - POOLS
work(dark * near, {hand="body", pile=FD, coverage=3, fill=true, clip=true, angle=toVP})
work(dark - near, {hand="body", pile=FM, coverage=3, fill=true, clip=true, angle=toVP})
print("ok")

--@ chunk 63
-- the pools are the lights: brightest at the crossing, falling off across the floor
PLB = pile{{"lead white",2.2},{"Mars yellow",1},{"cadmium yellow",0.5},{"yellow ochre",0.8}}
local ex = CHAIRM:grow(1)
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local z1 = mask(function(x, y) return floorX(x, y) < -3.4 and 1 or 0 end)
local z2 = mask(function(x, y) local X = floorX(x, y); return (X >= -3.4 and X < -2.0) and 1 or 0 end)
local z3 = mask(function(x, y) local X = floorX(x, y); return (X >= -2.0 and X < -0.9) and 1 or 0 end)
local z4 = mask(function(x, y) return floorX(x, y) >= -0.9 and 1 or 0 end)
local function grade(m, zones, piles)
  for k = 1, #zones do
    work(m * zones[k] - ex, {hand="body", pile=piles[k], coverage=3, fill=true, clip=m - ex, angle=0})
  end
end
for i = 1, #LPOOL do grade(LPOOL[i], {z1, z2, z3, z4}, {PLB, PL, PP, PM}) end
local r1 = mask(function(x, y) return floorX(x, y) > 3.2 and 1 or 0 end)
local r2 = mask(function(x, y) local X = floorX(x, y); return (X <= 3.2 and X > 1.8) and 1 or 0 end)
local r3 = mask(function(x, y) return floorX(x, y) <= 1.8 and 1 or 0 end)
for i = 1, #RPOOL do grade(RPOOL[i], {r1, r2, r3}, {PL, PR, PM}) end
-- melt the steps between zones while wet (narrow seams only, clipped)
local seamL = mask(function(x, y) local X = floorX(x, y); return (math.abs(X + 3.4) < 0.35 or math.abs(X + 2.0) < 0.35 or math.abs(X + 0.9) < 0.3) and 1 or 0 end)
local seamR = mask(function(x, y) local X = floorX(x, y); return (math.abs(X - 3.2) < 0.35 or math.abs(X - 1.8) < 0.35) and 1 or 0 end)
for i = 1, #LPOOL do blend(LPOOL[i]:shrink(2) * seamL - ex, {angle=0}) end
for i = 1, #RPOOL do blend(RPOOL[i]:shrink(2) * seamR - ex, {angle=0}) end

--@ chunk 64
print(wait(2*24*60))
local BM2 = BMASK:grow(3) - CHAIRM:grow(1)
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local edge = noise{seed=5, period=50, octaves=3}
local upper = mask(function(x, y) return y < 205 + 18 * edge(x, y) and 1 or 0 end)
local faces, shades
for _, Z in ipairs(LPIL) do
  local f = poly({pt(-HW, FL, Z), pt(-HW, FL, Z + 0.55), pt(-HW, TOP, Z + 0.55), pt(-HW, TOP, Z)})
  local s = poly({pt(-HW, FL, Z + 0.55), pt(-HW, FL, Z + 0.95), pt(-HW, TOP, Z + 0.95), pt(-HW, TOP, Z + 0.55)})
  faces = faces and faces + f or f; shades = shades and shades + s or s
end
faces = faces * BM2 - openings; shades = shades * BM2 - openings
work(shades, {hand="body", tool={kind="filbert", width=3}, pile=SHD, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(faces - upper, {hand="body", tool={kind="filbert", width=3}, pile=FR2, coverage=3, fill=true, clip=true, angle=math.pi/2})
work(faces * upper, {hand="body", tool={kind="filbert", width=3}, pile=WM, coverage=3, fill=true, clip=true, angle=math.pi/2})
local function course(Y, wm)
  local pts, ws = {}, {}
  for i = 0, 40 do
    local Z = 1.3 * (ZF / 1.3) ^ (i / 40)
    pts[#pts+1] = pt(-HW, Y, Z); ws[#ws+1] = math.max(0.6, wm * F / Z)
  end
  return ribbon(pts, ws)
end
work((course(FL - LSH, 0.11) * LWALL - openings) * BM2, {hand="body", tool={kind="round", width=2}, pile=BS, coverage=3, fill=true, clip=true})
work((course(FL - 1.1, 0.05) * LWALL - openings) * BM2, {hand="body", tool={kind="round", width=1.4}, pile=BS2, coverage=3, fill=true, clip=true})

--@ chunk 65
print(wait(2*24*60))
-- let the architecture step back into warm dark so the crossings and pools carry the light
GW = pile{{"burnt sienna",1},{"bone brown",1},{"raw sienna",0.4},{"ultramarine blue",0.3}, medium=0.8}
local openings = LOPEN[1] + LOPEN[2] + LOPEN[3] + LOPEN[4] + ROPEN[1] + ROPEN[2] + ROPEN[3]
local walls = (LWALL + RWALL) - openings - CHAIRM:grow(1)
local surround = FARWALL - MIRROR - MFRAME
local arch = walls + VAULT + surround
work(arch, {hand="glaze", pile=GW, clip=true})
blend(arch, {})
-- the middle and far distance a second time, deeper still
local far = ((wallq(-1, 9, ZF, FL, TOP) + wallq(1, 9, ZF, FL, TOP)) * walls) + surround + VAULT
work(far, {hand="glaze", pile=GW, clip=true, load=0.6})
blend(far, {})

--@ chunk 66
print(wait(3*24*60))
HL = pile{{"lead white",2},{"yellow ochre",1},{"Mars yellow",0.5}}
-- chairs: cast shadow along their crossing's light, shadow side, lit side
CS2 = pile{{"Mars brown",2},{"bone black",0.8},{"burnt sienna",0.4}}
local SD = {{0.85, -0.3}, {-0.75, -0.25}, {0.85, -0.3}, {-0.7, -0.2}, {0.85, -0.3}, {-0.75, -0.2}}
for i, c in ipairs(CHAIRS) do
  local M = chair_masks(c[1], c[2], c[3], c[4])
  local pts, w = {}, {}
  for k = 0, 6 do
    local t = k / 6 * 1.25
    pts[#pts+1] = pt(c[1] + SD[i][1] * t, FL, c[2] + SD[i][2] * t)
    w[#w+1] = (0.16 + 0.26 * (k / 6)) * M.s
  end
  local sm = ribbon(pts, w) * FLOOR - CHAIRM
  work(sm, {hand="body", tool={kind="filbert", width=clamp(0.04 * M.s, 1.5, 5)}, pile=CS2, coverage=3, fill=true, clip=true})
  -- shadow side: a dark band on the side away from the light
  local d = math.max(1.0, 0.05 * M.s)
  local away = chair_masks(c[1], c[2], c[3], c[4], c[5] * d)
  work(M.all - away.all, {hand="body", tool={kind="round", width=math.max(1, 0.5 * d)}, pile=CS2, coverage=3, fill=true, clip=true, angle=math.pi/2})
  -- lit side again, narrower and brighter
  local d2 = math.max(0.8, 0.025 * M.s)
  local tow = chair_masks(c[1], c[2], c[3], c[4], -c[5] * d2)
  work(M.all - tow.all, {hand="body", tool={kind="round", width=math.max(1, 0.6 * d2)}, pile=HL, coverage=3, fill=true, clip=true, angle=math.pi/2})
end
-- the runner and its rosettes, restated where the pools were repainted
work(RUN * POOLS - CHAIRM:grow(1), {hand="body", tool={kind="round", width=1.4}, pile=BN, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(VY-y, VX-x) end})
local Z = 4.3
local k = 0
while Z < 27 do
  k = k + 1
  local s = F / Z
  local st = brush{kind="round", width=math.max(1.2, 0.05 * s)}
  for j = 1, 21 do
    local r = 0.085 * math.sqrt(j)
    local a = j * GA
    local x, y = P(r * math.cos(a), FL, Z + r * math.sin(a))
    if POOLS:at(x, y) > 0.5 and CHAIRM:at(x, y) < 0.1 then st:reload(BN, 0.85); st:touch(x, y, {pressure=0.7}) end
  end
  Z = Z * (1.45 + 0.2 * math.sin(k * 1.7))
end

--@ chunk 67
HOT = pile{{"zinc white",3},{"lemon chrome",0.4},{"lead white",1}}
-- the story beat: a big seat stepping out of the mirror, front already bronze, back still silver
local X, Z, k = 0.25, 29.55, 2.3
local cx, cy = P(X, FL, Z)
local s = k * F / Z
local function seat_parts(dx)
  local x0 = cx + (dx or 0)
  local T = {}
  T.foot = ellipse(x0, cy - 0.02*s, 0.22*s, 0.05*s)
  T.ped = poly({{x0 - 0.08*s, cy - 0.03*s}, {x0 + 0.08*s, cy - 0.03*s}, {x0 + 0.045*s, cy - 0.46*s}, {x0 - 0.045*s, cy - 0.46*s}})
  T.seat = poly({{x0 - 0.42*s, cy - 0.50*s}, {x0 - 0.2*s, cy - 0.60*s}, {x0 + 0.22*s, cy - 0.60*s}, {x0 + 0.44*s, cy - 0.52*s},
                 {x0 + 0.3*s, cy - 0.42*s}, {x0 - 0.3*s, cy - 0.42*s}}, true)
  T.back = poly({{x0 - 0.30*s, cy - 0.56*s}, {x0 - 0.37*s, cy - 0.95*s}, {x0 - 0.22*s, cy - 1.32*s}, {x0, cy - 1.42*s},
                 {x0 + 0.24*s, cy - 1.30*s}, {x0 + 0.36*s, cy - 0.95*s}, {x0 + 0.29*s, cy - 0.56*s}}, true)
  T.all = T.foot + T.ped + T.seat + T.back
  return T
end
local T = seat_parts()
-- its shadow on the floor, thrown toward us
local sm = ellipse(cx + 0.15*s, cy + 0.05*s, 0.5*s, 0.09*s) * FLOOR - T.all
work(sm, {hand="body", tool={kind="filbert", width=2.5}, pile=CS2, coverage=3, fill=true, clip=true})
-- the back, still inside the glass: silver, with the mirror's own colours in it
work(T.back - T.seat, {hand="body", tool={kind="round", width=2}, pile=SIL, coverage=3.5, fill=true, clip=true, angle=math.pi/2})
local bb = brush{kind="round", width=2.5, point=0.5}
bb:reload(MS, 0.8)
bb:stroke({{cx - 0.2*s, cy - 0.7*s}, {cx - 0.24*s, cy - 1.0*s}, {cx - 0.1*s, cy - 1.3*s}}, {pressure={0.4, 0.2}, clip=T.back})
-- the front, already out: bronze, lit from the gallery, a dark underside
local front = T.seat + T.ped + T.foot
work(front, {hand="body", tool={kind="filbert", width=2}, pile=CB, coverage=3.5, fill=true, clip=true, angle=0})
local top = ellipse(cx, cy - 0.535*s, 0.38*s, 0.045*s) * T.seat
work(top, {hand="body", tool={kind="round", width=1.6}, pile=CL, coverage=3, fill=true, clip=true, angle=0})
local rimm = T.seat * rect(0, cy - 0.47*s, 1000, 0.05*s)
work(rimm, {hand="body", tool={kind="round", width=1.2}, pile=BN, coverage=3, fill=true, clip=true, angle=0})
local ped_l = (T.ped + T.foot) - seat_parts(1.6).all
work(ped_l, {hand="body", tool={kind="round", width=1}, pile=HL, coverage=3, fill=true, clip=true, angle=math.pi/2})
-- where the seat crosses the glass, the surface rings outward: bright arcs on the mirror
local ring = brush{kind="round", width=1.3, point=0.5}
for j, r in ipairs({0.55, 0.78, 1.05}) do
  local pts = {}
  for i = 0, 30 do
    local a = math.pi * (1.05 + 0.9 * i / 30)
    pts[#pts+1] = {cx + r * 0.62 * s * math.cos(a) * 1.25, cy - 0.95*s + r * 0.62 * s * math.sin(a)}
  end
  ring:reload(HOT, 0.8 - 0.15 * j)
  ring:stroke(pts, {pressure={0.55 - 0.1*j, 0.25}, clip=MIRROR - T.all})
end
-- a few silver drops already run onto the floor in front of it
local st = brush{kind="round", width=2.5}
for i = 1, 5 do
  local x, y = P(X + 0.3 * math.sin(i * 2.4), FL, Z - 0.4 - 0.5 * i)
  if T.all:at(x, y) < 0.1 then st:reload(SIL, 0.8); st:touch(x, y, {pressure=0.6, drag={3, 0}}) end
end
CHAIRM = CHAIRM + T.all
print(cx, cy, s)

--@ chunk 68
print(wait(24*60))
local cx, cy, s = 544.23, 327.07, 38.92
local back = poly({{cx - 0.30*s, cy - 0.56*s}, {cx - 0.37*s, cy - 0.95*s}, {cx - 0.22*s, cy - 1.32*s}, {cx, cy - 1.42*s},
                 {cx + 0.24*s, cy - 1.30*s}, {cx + 0.36*s, cy - 0.95*s}, {cx + 0.29*s, cy - 0.56*s}}, true)
local seat = poly({{cx - 0.42*s, cy - 0.50*s}, {cx - 0.2*s, cy - 0.60*s}, {cx + 0.22*s, cy - 0.60*s}, {cx + 0.44*s, cy - 0.52*s},
                 {cx + 0.3*s, cy - 0.42*s}, {cx - 0.3*s, cy - 0.42*s}}, true)
local CD = pile{{"ultramarine ash",1},{"bone brown",1},{"zinc white",0.3}}
local SMID = pile{{"zinc white",1.5},{"ultramarine ash",1},{"lead white",0.5},{"bone black",0.15}}
-- a cool dark contour: the silver back cut out against the bright glass
work((back:grow(1.6) - back) - seat, {hand="body", tool={kind="round", width=1.2}, pile=CD, coverage=3, fill=true, clip=true})
-- its turning side in cool shadow, the near edge bright
local shade = back - poly({{cx - 0.6*s, cy - 1.5*s}, {cx + 0.08*s, cy - 1.5*s}, {cx + 0.12*s, cy - 0.5*s}, {cx - 0.6*s, cy - 0.5*s}})
work(shade - seat, {hand="body", tool={kind="round", width=1.5}, pile=SMID, coverage=3, fill=true, clip=true, angle=math.pi/2})
local b = brush{kind="round", width=1.6, point=0.6}
b:reload(HOT, 0.8)
b:stroke({{cx - 0.25*s, cy - 0.65*s}, {cx - 0.31*s, cy - 0.95*s}, {cx - 0.18*s, cy - 1.27*s}}, {pressure={0.5, 0.2}, clip=back})
-- the waterline where it crosses the glass: a bright hairline across the seat
local w = brush{kind="round", width=1.2, point=0.5}
w:reload(HOT, 0.8)
w:stroke({{cx - 0.36*s, cy - 0.58*s}, {cx, cy - 0.62*s}, {cx + 0.38*s, cy - 0.57*s}}, {pressure={0.55, 0.4}})

--@ chunk 69
print(wait(24*60))
-- the hottest light on the floor: the inner half of the first south pool, next to its crossing
local core = LPOOL[1] * mask(function(x, y) return floorX(x, y) < -2.6 and 1 or 0 end) - CHAIRM:grow(2)
local HP = pile{{"lead white",3},{"cadmium yellow",0.8},{"Mars yellow",0.5}}
work(core:shrink(3), {hand="body", pile=HP, coverage=2.6, fill=true, clip=core, angle=0})
local seam = core * mask(function(x, y) return math.abs(floorX(x, y) + 2.6) < 0.45 and 1 or 0 end)
blend(seam:grow(4) * LPOOL[1]:shrink(2) - CHAIRM:grow(2), {angle=0})
-- the bone runner under the near chair's cast shadow goes dull
local c = CHAIRS[1]
local M = chair_masks(c[1], c[2], c[3], c[4])
local pts, w = {}, {}
for k = 0, 6 do
  local t = k / 6 * 1.25
  pts[#pts+1] = pt(c[1] + 0.85 * t, FL, c[2] - 0.3 * t)
  w[#w+1] = (0.16 + 0.26 * (k / 6)) * M.s
end
local sm = ribbon(pts, w) * RUN
work(sm, {hand="body", tool={kind="round", width=1.5}, pile=BS2, coverage=3, fill=true, clip=true})
