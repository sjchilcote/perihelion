-- easel session "area_outpost": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,14}, seed=4404, ground={{pile={{"lead white",2},{"bone black",1},{"ultramarine blue",0.4},{"burnt sienna",0.4}}, um=90, apply="knife", texture=0.25}}}; print(W,H)

--@ chunk 2
VX, VY = 560, 250
XL, XR, YC, YF = -620, 520, -330, 380
ZF = 6.25
function P(X, Y, z) return {VX + X / z, VY + Y / z} end
-- plane at X const
function wallq(X, Y1, Y2, z1, z2) return poly({P(X,Y1,z1), P(X,Y1,z2), P(X,Y2,z2), P(X,Y2,z1)}) end
-- plane at Y const
function flatq(Y, X1, X2, z1, z2) return poly({P(X1,Y,z1), P(X2,Y,z1), P(X2,Y,z2), P(X1,Y,z2)}) end
-- plane at z const
function frontq(z, X1, X2, Y1, Y2) return poly({P(X1,Y1,z), P(X2,Y1,z), P(X2,Y2,z), P(X1,Y2,z)}) end
radial = function(x, y) return math.atan(y - VY, x - VX) end
ceilM  = flatq(YC, XL, XR, 0.6, ZF)
floorM = flatq(YF, XL, XR, 0.6, ZF)
leftM  = wallq(XL, YC, YF, 0.6, ZF)
rightM = wallq(XR, YC, YF, 0.6, ZF)
farM   = frontq(ZF, XL, XR, YC, YF)
print(ceilM:area(), floorM:area(), leftM:area(), rightM:area(), farM:area())

--@ chunk 3
cdark  = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}, medium=0.1}
slate  = pile{{"bone black",1.5},{"ultramarine ash",1},{"lead white",0.35},{"burnt sienna",0.2}, medium=0.1}
work(ceilM, {hand="broad", pile=slate, coverage=2.6, fill=true, clip=true, angle=radial})
work(leftM, {hand="broad", pile=cdark, coverage=2.6, fill=true, clip=true, angle=math.pi/2})

--@ chunk 4
floorD = pile{{"bone black",1.5},{"Mars brown",1},{"ultramarine blue",0.5},{"lead white",0.25}, medium=0.1}
bronzeD = pile{{"bone black",1.5},{"burnt sienna",1.5},{"yellow ochre",0.6}, medium=0.1}
work(floorM, {hand="broad", pile=floorD, coverage=2.6, fill=true, clip=true, angle=radial})
work(rightM, {hand="broad", pile=bronzeD, coverage=2.6, fill=true, clip=true, angle=math.pi/2})
work(farM, {hand="body", pile=cdark, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 5
pgL = pile{{"lead white",1.2},{"bone black",0.7},{"ultramarine ash",0.6},{"yellow ochre",0.1}, medium=0.1}
pgM = pile{{"lead white",0.7},{"bone black",0.9},{"ultramarine ash",0.6}, medium=0.1}
pgD = pile{{"lead white",0.3},{"bone black",1.2},{"ultramarine ash",0.8}, medium=0.1}
pgK = pile{{"lead white",0.12},{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.2}, medium=0.1}
PX1, PX2, PYT = -620, -450, -140
pumps = {}
for i = 0, 13 do
  local z = 1.15 + i * 0.37
  if z + 0.27 > ZF - 0.05 then break end
  pumps[#pumps+1] = {z1 = z, z2 = z + 0.27}
end
pumpSide, pumpFront = {}, {}
for i, p in ipairs(pumps) do
  pumpSide[i]  = wallq(PX2, PYT, YF, p.z1, p.z2)
  pumpFront[i] = frontq(p.z1, PX1, PX2, PYT, YF)
end
print(#pumps)

--@ chunk 6
local occ = nil
local order = {pgL, pgM, pgD, pgK}
function litz(z) return math.exp(-((z - 2.9) / 1.3)^2) end
function lvl(z) local l = litz(z); if l > 0.65 then return 1 elseif l > 0.3 then return 2 elseif l > 0.1 then return 3 else return 4 end end
for i, p in ipairs(pumps) do
  local s, f = pumpSide[i], pumpFront[i]
  if occ then s = s - occ; f = f - occ end
  local k = lvl(p.z1)
  work(s, {hand="body", pile=order[k], coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  work(f - s, {hand="body", pile=order[math.min(k+1,4)], coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end
pumpsAll = occ

--@ chunk 7
print(wait(20*60)); print(drying(300,300), drying(100,300), drying(500,100), drying(800,300), drying(500,450))

--@ chunk 8
local occ = nil
for i, p in ipairs(pumps) do
  local s, f = pumpSide[i], pumpFront[i]
  if occ then s = s - occ; f = f - occ end
  local l = litz(p.z1 + 0.13)
  local ps = (l > 0.6) and pgM or pgD
  if p.z1 > 4.6 then ps = pgK end
  work(s, {hand="body", pile=ps, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  work(f - s, {hand="body", pile=pgK, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end
-- left wall above/behind the pumps: dark slate, not blue
local lw = leftM - pumpsAll
wallD = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"burnt sienna",0.3},{"lead white",0.1}, medium=0.1}
work(lw, {hand="body", pile=wallD, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 9
VPX1, VPX2, VPZ1, VPZ2 = -170, 230, 2.2, 2.75
viewM = flatq(YC, VPX1, VPX2, VPZ1, VPZ2)
ceilD = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"burnt sienna",0.3},{"lead white",0.15}, medium=0.1}
ceilM2 = pile{{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.3},{"lead white",0.45}, medium=0.1}
local near = flatq(YC, XL, XR, 0.6, 1.9)
local mid  = flatq(YC, XL, XR, 1.9, 3.4) - viewM
local far  = flatq(YC, XL, XR, 3.4, ZF)
work(near, {hand="broad", pile=ceilD, coverage=3, fill=true, clip=true, angle=radial})
work(far, {hand="body", pile=ceilD, coverage=3, fill=true, clip=true, angle=radial})
work(mid, {hand="body", pile=ceilM2, coverage=3, fill=true, clip=true, angle=radial})
-- floor: darker
floorK = pile{{"bone black",1.6},{"Mars brown",0.8},{"ultramarine blue",0.6},{"lead white",0.1}, medium=0.1}
work(floorM, {hand="broad", pile=floorK, coverage=3, fill=true, clip=true, angle=radial})

--@ chunk 10
print(wait(24*60)); for _,q in ipairs({{560,90},{560,115},{600,385},{300,300},{800,300},{560,250}}) do print(q[1],q[2],drying(q[1],q[2])) end

--@ chunk 11
bronzeK = pile{{"bone black",2},{"burnt sienna",1.2},{"yellow ochre",0.4}, medium=0.1}
bronzeW = pile{{"bone black",1},{"burnt sienna",1.5},{"yellow ochre",0.8},{"raw sienna",0.4}, medium=0.1}
local a = wallq(XR, YC, YF, 0.6, 2.0) + wallq(XR, YC, YF, 3.6, ZF)
local b = wallq(XR, YC, YF, 2.0, 3.6)
work(a, {hand="body", pile=bronzeK, coverage=3, fill=true, clip=true, angle=math.pi/2, length={30,80}})
work(b, {hand="body", pile=bronzeW, coverage=3, fill=true, clip=true, angle=math.pi/2, length={30,80}})
blend(wallq(XR, YC, YF, 1.8, 2.2) + wallq(XR, YC, YF, 3.4, 3.8), {angle=math.pi/2})

--@ chunk 12
lipD = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.4}}
lipL = pile{{"raw sienna",2},{"burnt sienna",0.6},{"yellow ochre",1},{"lead white",0.6}}
lipH = pile{{"yellow ochre",2},{"lead white",1.2},{"cadmium yellow",0.3}}
function wallpt(Y, z) return P(XR, Y, z) end
function scale_lip(Yc, zc, hw, dep, bD, bL, lit)
  -- U-shaped lower lip of one plate on the right wall, in world units
  local ptsD, ptsL = {}, {}
  for k = 0, 8 do
    local t = -1 + k / 4
    local Y = Yc + dep * (1 - t * t)
    local z = zc + hw * t / 600
    ptsD[#ptsD+1] = wallpt(Y + 4, z)
    ptsL[#ptsL+1] = wallpt(Y - 3, z)
  end
  local s = 1 / zc
  bD:stroke(ptsD, {pressure={0.7, 0.4}, ramps={0.15, 0.3}})
  if lit > 0.15 then bL:stroke(ptsL, {pressure={0.35 * lit + 0.1, 0.05}, ramps={0.2, 0.5}}) end
end
local bD = brush{kind="round", width=3.2, point=0.5}
local bL = brush{kind="round", width=1.6, point=0.8}
local n = 0
local row = 0
local Y = YC + 20
while Y < YF - 10 do
  local z = 0.75 + (row % 2) * 0.05 + rand(0, 0.03)
  while z < ZF - 0.05 do
    local hw = 30 + 14 * math.abs(math.sin(z * 7.3 + row * 2.39))
    local lit = litz(z) * 0.9
    if n % 6 == 0 then bD:load(lipD, 0.8); bL:load(lit > 0.5 and lipH or lipL, 0.6) end
    -- brush width scaled by perspective: pick pressure via load only; far plates use the same brush but get crowded
    scale_lip(Y + rand(-5,5), z, hw, 16 + rand(-3,4), bD, bL, lit)
    n = n + 1
    z = z + (2 * hw + rand(6, 16)) / 600 * (0.9 + 0.1 * z)
  end
  row = row + 1
  Y = Y + 44 + rand(-4, 6)
end
print(n)

--@ chunk 13
strutZ = {1.35, 2.3, 3.25, 4.2, 5.15}
local sm, sf = nil, nil
for _, z in ipairs(strutZ) do
  local face = wallq(490, YC, YF, z, z + 0.06)
  local side = frontq(z, 490, XR, YC, YF)
  sm = sm and (sm + face) or face
  sf = sf and (sf + side) or side
end
-- horizontal rails (cable trays) at two heights, standing off the hull
local rails = wallq(495, -70, -40, 0.6, ZF) + wallq(495, 255, 275, 0.6, ZF)
local railsUnder = frontq(0.6, 0, 0, 0, 0) -- placeholder (empty)
strutsM = sm + sf + rails
work(rails - sm - sf, {hand="body", pile=pgD, coverage=3, fill=true, clip=true, angle=radial, length={20,60}})
work(sf, {hand="body", pile=pgK, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
work(sm, {hand="body", pile=pgM, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})

--@ chunk 14
sunW = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.35}}
sunG = pile{{"lead white",3},{"cadmium yellow",0.5},{"yellow ochre",0.3},{"zinc white",1}}
-- viewport: two panes
local mull = flatq(YC, 15, 45, VPZ1, VPZ2)
local frameM = viewM - flatq(YC, VPX1 + 18, VPX2 - 18, VPZ1 + 0.03, VPZ2 - 0.03)
local panes = viewM - mull - frameM
work(panes, {hand="body", pile=sunW, coverage=4, fill=true, clip=true, angle=0, length={10,30}})
work(mull + frameM, {hand="detail", pile=pgK, coverage=3, fill=true, angle=0})
-- the sun patch on the floor: three panes (the viewport has two)
PZ1, PZ2, PXA, PXB = 2.55, 3.1, 80, 480
patchM = flatq(YF, PXA, PXB, PZ1, PZ2)
local pm1 = flatq(YF, 206, 222, PZ1, PZ2)
local pm2 = flatq(YF, 338, 354, PZ1, PZ2)
local pfr = patchM - flatq(YF, PXA + 18, PXB - 18, PZ1 + 0.025, PZ2 - 0.025)
patchLit = patchM - pm1 - pm2 - pfr
work(patchLit, {hand="body", pile=sunG, coverage=4, fill=true, clip=true, angle=0, length={10,40}})

--@ chunk 15
pgD2 = pile{{"lead white",0.25},{"bone black",1.3},{"ultramarine ash",0.9},{"cerulean blue",0.1}, medium=0.1}
pgM2 = pile{{"lead white",0.55},{"bone black",1.0},{"ultramarine ash",0.8}, medium=0.1}
local occ = nil
for i, p in ipairs(pumps) do
  local s = pumpSide[i]
  if occ then s = s - occ end
  local l = litz(p.z1 + 0.13)
  local ps = (l > 0.6) and pgM2 or pgD2
  if p.z1 > 4.3 then ps = pgK end
  work(s, {hand="body", pile=ps, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end
-- coolant risers from each pump to the ceiling
local pipes = nil
for i, p in ipairs(pumps) do
  local zc = p.z1 + 0.12
  local m = frontq(zc, -560, -515, YC, PYT)
  pipes = pipes and (pipes + m) or m
end
pipesM = pipes
work(pipes, {hand="body", pile=pgD2, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})

--@ chunk 16
print(wait(36*60))
veil = pile{{"lead white",2},{"zinc white",1},{"Mars orange",0.15},{"lemon chrome",0.1}, medium=0.6}
shaftPts = {P(VPX1, YC, VPZ1), P(VPX2, YC, VPZ1), P(PXB, YF, PZ1), P(PXA, YF, PZ1)}
local A = P(VPX1, YC, VPZ2); local B = P(VPX2, YC, VPZ2); local C = P(PXB, YF, PZ2); local D = P(PXA, YF, PZ2)
shaftM = (poly(shaftPts) + poly({A, B, C, D}) + poly({shaftPts[1], A, D, shaftPts[4]}) + poly({shaftPts[2], B, C, shaftPts[3]})):soften(6)
local sa = math.atan(386 - 115, 668 - 574)
work(shaftM, {hand="glaze", pile=veil, coverage=1.0, fill=true, clip=true, angle=sa, load=0.25, pressure={0.1,0.25}})
blend(shaftM, {angle=sa})

--@ chunk 17
for k = 1, 5 do
  work(shaftM, {hand="scumble", blender=true, coverage=1.5, clip=true, seed=100+k})
end

--@ chunk 18
print(wait(3*24*60)); for _,q in ipairs({{600,250},{620,150},{690,300},{640,360},{560,110}}) do print(q[1],q[2],drying(q[1],q[2])) end

--@ chunk 19
local S = shaftM:grow(6)
local ceilMid = flatq(YC, XL, XR, 1.9, 3.4) - viewM
work(S * ceilMid, {hand="body", pile=ceilM2, coverage=3.2, fill=true, clip=true, angle=radial, length={20,50}})
work(S * flatq(YC, XL, XR, 3.4, ZF), {hand="body", pile=ceilD, coverage=3.2, fill=true, clip=true, angle=radial, length={20,50}})
work(S * farM, {hand="body", pile=cdark, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
work(S * floorM - patchM, {hand="body", pile=floorK, coverage=3.2, fill=true, clip=true, angle=radial, length={20,50}})
local rw = S * rightM
work(rw * wallq(XR, YC, YF, 3.6, ZF), {hand="body", pile=bronzeK, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
work(rw * wallq(XR, YC, YF, 0.6, 3.6), {hand="body", pile=bronzeW, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
-- the viewport panes again
local mull = flatq(YC, 15, 45, VPZ1, VPZ2)
local frameM = viewM - flatq(YC, VPX1 + 18, VPX2 - 18, VPZ1 + 0.03, VPZ2 - 0.03)
work(viewM - mull - frameM, {hand="body", pile=sunW, coverage=4, fill=true, clip=true, angle=0, length={10,30}})
work(mull + frameM, {hand="detail", pile=pgK, coverage=3, fill=true, angle=0})
shaftRepair = rw

--@ chunk 20
print(wait(30*60))
local bD = brush{kind="round", width=2.6, point=0.5}
local bL = brush{kind="round", width=1.4, point=0.8}
local n, row = 0, 0
local Y = YC + 26
while Y < YF - 10 do
  local z = 3.3 + (row % 2) * 0.06 + rand(0, 0.03)
  while z < ZF - 0.05 do
    local hw = 30 + 14 * math.abs(math.sin(z * 5.1 + row * 2.39))
    local c = wallpt(Y, z)
    if shaftRepair:at(c[1], c[2]) > 0.3 then
      if n % 6 == 0 then bD:load(lipD, 0.8); bL:load(lipL, 0.6) end
      scale_lip(Y + rand(-5,5), z, hw, 16 + rand(-3,4), bD, bL, litz(z) * 0.9)
      n = n + 1
    end
    z = z + (2 * hw + rand(6, 16)) / 600 * (0.9 + 0.1 * z)
  end
  row = row + 1
  Y = Y + 44 + rand(-4, 6)
end
print(n)
-- struts and rails back where the repair went
local sm, sf = nil, nil
for _, z in ipairs(strutZ) do
  local face = wallq(490, YC, YF, z, z + 0.06)
  local side = frontq(z, 490, XR, YC, YF)
  sm = sm and (sm + face) or face
  sf = sf and (sf + side) or side
end
local rails = wallq(495, -70, -40, 0.6, ZF) + wallq(495, 255, 275, 0.6, ZF)
local R = shaftRepair:grow(3)
work(R * (rails - sm - sf), {hand="detail", pile=pgD, coverage=3, fill=true, angle=radial})
work(R * sf, {hand="detail", pile=pgK, coverage=3, fill=true, angle=math.pi/2})
work(R * sm, {hand="detail", pile=pgM, coverage=3, fill=true, angle=math.pi/2})

--@ chunk 21
amber  = pile{{"cadmium yellow",1},{"Mars orange",1},{"yellow ochre",0.5}}
amberS = pile{{"Mars orange",1},{"raw sienna",1},{"bone black",0.4}}
seamK  = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5}}
-- visible pump faces
pumpSideV, pumpFrontV = {}, {}
local occ = nil
for i, p in ipairs(pumps) do
  local s, f = pumpSide[i], pumpFront[i]
  if occ then s = s - occ; f = f - occ end
  pumpSideV[i] = s; pumpFrontV[i] = f - s
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end
local hz, hzF = nil, nil
for i, p in ipairs(pumps) do
  local a = pumpSideV[i] * wallq(PX2, 262, 312, p.z1, p.z2)
  local b = pumpFrontV[i] * frontq(p.z1, PX1, PX2, 262, 312)
  hz = hz and (hz + a) or a
  hzF = hzF and (hzF + b) or b
end
hazSide, hazFront = hz, hzF
work(hz, {hand="detail", pile=amber, coverage=3, fill=true, angle=0})
work(hzF, {hand="detail", pile=amberS, coverage=3, fill=true, angle=0})
-- ceiling panel seams
local b = brush{kind="round", width=2.2, point=0.6}
b:load(seamK, 0.9)
for _, X in ipairs({-430, -170, 230, 380}) do
  b:stroke({P(X, YC, 0.62), P(X, YC, ZF)}, {pressure={0.8, 0.2}, ramps={0.02, 0.1}})
  b:load(seamK, 0.9)
end
local z = 1.0
while z < ZF do
  if not (z > VPZ1 - 0.05 and z < VPZ2 + 0.05) then
    b:load(seamK, 0.9)
    b:stroke({P(XL, YC, z), P(XR, YC, z)}, {pressure={0.75 / z + 0.15, 0.75 / z + 0.15}, ramps={0.02, 0.02}})
  end
  z = z + 0.37
end

--@ chunk 22
print(wait(24*60))
floorWarm = pile{{"bone black",1},{"Mars brown",1},{"raw sienna",0.6},{"lead white",0.35}, medium=0.1}
local c = P((PXA+PXB)/2, YF, (PZ1+PZ2)/2)
local glow = (ellipse(c[1], c[2], 150, 40):blur(25)) * floorM - patchM:grow(1)
work(glow, {hand="body", pile=floorWarm, coverage=2.2, fill=true, clip=true, angle=0, length={15,40}, load=0.6})
-- floor plate seams
local b = brush{kind="round", width=2, point=0.6}
for _, X in ipairs({-300, -60, 180, 400}) do
  b:load(seamK, 0.9)
  b:stroke({P(X, YF, 0.62), P(X, YF, ZF)}, {pressure={0.8, 0.2}, ramps={0.02, 0.1}})
end
local z = 0.8
while z < ZF do
  b:load(seamK, 0.9)
  b:stroke({P(PX2, YF, z), P(XR, YF, z)}, {pressure={0.7 / z + 0.15, 0.7 / z + 0.15}, ramps={0.02, 0.02}})
  z = z + 0.37
end

--@ chunk 23
local c = P((PXA+PXB)/2, YF, (PZ1+PZ2)/2)
local g = (ellipse(c[1], c[2], 190, 60)) * floorM - patchM:grow(2)
for k = 1, 3 do work(g, {hand="scumble", blender=true, coverage=1.5, clip=true, seed=200+k}) end
blend(g, {angle=0})

--@ chunk 24
local c = P((PXA+PXB)/2, YF, (PZ1+PZ2)/2)
local g = (ellipse(c[1], c[2], 200, 66)) * floorM - patchM
work(g, {hand="body", pile=floorK, coverage=3.5, fill=true, clip=true, angle=radial, length={20,50}})

--@ chunk 25
glowA = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.5}}
glowB = pile{{"Mars orange",1},{"burnt sienna",0.8},{"bone black",0.3}}
local hx1, hx2, hy1, hy2 = -105, 105, -140, YF
hatchM = frontq(ZF, hx1, hx2, hy1, hy2)
local frameH = frontq(ZF, hx1 - 30, hx2 + 30, hy1 - 30, hy2) - hatchM
-- inside: dim amber room beyond, brighter low
local hc = P(0, 300, ZF)
work(hatchM, {hand="detail", pile=glowB, coverage=3, fill=true, angle=math.pi/2})
work(hatchM * ellipse(hc[1], hc[2] + 4, 16, 34), {hand="detail", pile=glowA, coverage=2.5, fill=true, angle=math.pi/2})
work(frameH, {hand="detail", pile=amberS, coverage=3, fill=true, angle=0})

--@ chunk 26
print(wait(30*60))
-- the security machine in the hatchway: dark silhouette, legs, a long sensor head
mach = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
local cx, by = 563, 310     -- foot line in canvas units
local body = poly({{cx-9, by-30}, {cx+8, by-31}, {cx+11, by-24}, {cx+6, by-19}, {cx-7, by-19}, {cx-11, by-24}})
local head = poly({{cx+4, by-38}, {cx+14, by-41}, {cx+17, by-37}, {cx+12, by-33}, {cx+5, by-32}})
local neck = ribbon({{cx+2, by-29}, {cx+7, by-35}}, 2.4)
local legs = ribbon({{cx-8, by-22}, {cx-15, by-14}, {cx-13, by}}, 1.5)
  + ribbon({{cx-3, by-20}, {cx-5, by-10}, {cx-7, by}}, 1.5)
  + ribbon({{cx+4, by-20}, {cx+7, by-11}, {cx+6, by}}, 1.5)
  + ribbon({{cx+8, by-22}, {cx+15, by-13}, {cx+15, by}}, 1.5)
machM = body + head + neck + legs
work(machM, {hand="detail", pile=mach, coverage=4, fill=true, angle=math.pi/2, tool={kind="round", width=1.2}})

--@ chunk 27
print(wait(24*60))
mach2 = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.5}}
work(machM, {hand="detail", pile=mach2, coverage=5, fill=true, angle=math.pi/2, load=1, tool={kind="round", width=1.0}})
-- the top of the room beyond the hatch falls into dark
local top = hatchM * above(function(x) return 262 end)
work(top, {hand="detail", pile=glowB, coverage=3, fill=true, angle=math.pi/2})

--@ chunk 28
glowK = pile{{"burnt sienna",1},{"bone black",0.8},{"Mars orange",0.4}}
local H = hatchM - machM:grow(0.6)
local t = function(a, b) return H * below(function(x) return a end) * above(function(x) return b end) end
local tb = brush{kind="filbert", width=3}
work(t(225, 266), {hand="detail", pile=glowK, coverage=4, fill=true, angle=0, tool=tb})
work(t(266, 292), {hand="detail", pile=glowB, coverage=4, fill=true, angle=0, tool=tb})
work(t(292, 315), {hand="detail", pile=glowA, coverage=4, fill=true, angle=0, tool=tb})
blend(H * below(function(x) return 258 end) * above(function(x) return 300 end), {angle=math.pi/2, tool={kind="badger", width=6}})

--@ chunk 29
local st = nil
local function add(m) st = st and (st + m) or m end
for i, p in ipairs(pumps) do
  local a = p.z1 - 0.04
  while a < p.z2 do
    add(poly({P(PX2, 262, a), P(PX2, 262, a + 0.028), P(PX2, 312, a + 0.028 + 0.035), P(PX2, 312, a + 0.035)}))
    a = a + 0.062
  end
  local x = PX1 - 40
  while x < PX2 do
    add(poly({P(x, 262, p.z1), P(x + 26, 262, p.z1), P(x + 56, 312, p.z1), P(x + 30, 312, p.z1)}))
    x = x + 58
  end
end
work(st * (hazSide + hazFront), {hand="detail", pile=seamK, coverage=4, fill=true, angle=0, tool={kind="round", width=1.2}})

--@ chunk 30
pgF = pile{{"lead white",0.15},{"bone black",1.4},{"ultramarine ash",1.0},{"cerulean blue",0.08}, medium=0.1}
for i, p in ipairs(pumps) do
  local f = pumpFrontV[i] - hazFront
  work(f, {hand="body", pile=pgF, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
end

--@ chunk 31
olive = pile{{"yellow ochre",1},{"bone black",1},{"viridian",0.2},{"lead white",0.35}, medium=0.1}
oliveD = pile{{"yellow ochre",0.8},{"bone black",1.3},{"viridian",0.2},{"lead white",0.1}, medium=0.1}
local k = 3
work(pumpSideV[k] - hazSide, {hand="body", pile=olive, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={15,40}})
work(pumpFrontV[k] - hazFront, {hand="body", pile=oliveD, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={15,40}})
-- printed placards on every pump side, the same placard every time
plateW = pile{{"lead white",2},{"zinc white",1},{"ultramarine ash",0.3},{"yellow ochre",0.1}}
local pl = nil
for i, p in ipairs(pumps) do
  if i ~= k then
    local m = pumpSideV[i] * wallq(PX2, -70, -20, p.z1 + 0.06, p.z1 + 0.15)
    pl = pl and (pl + m) or m
  end
end
placardsM = pl
work(pl, {hand="detail", pile=plateW, coverage=4, fill=true, angle=0, tool={kind="round", width=1}})

--@ chunk 32
print(wait(24*60))
-- placard text: dash rows, a red header bar
local red = pile{{"vermilion",1},{"cadmium red",0.5},{"bone black",0.1}}
local bt = brush{kind="round", width=0.9, point=0.6}
local bh = brush{kind="flat", width=1.6}
for i, p in ipairs(pumps) do
  if i ~= 3 and p.z1 < 4.0 then
    local za, zb = p.z1 + 0.065, p.z1 + 0.145
    bh:load(red, 0.8)
    bh:stroke({P(PX2, -62, za), P(PX2, -62, zb)}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
    bt:load(seamK, 0.7)
    for r = 0, 2 do
      local Y = -50 + r * 10
      local z = za + 0.004
      while z < zb - 0.01 do
        local L = rand(0.006, 0.02)
        bt:stroke({P(PX2, Y, z), P(PX2, Y, math.min(z + L, zb - 0.004))}, {pressure={0.5, 0.5}, ramps={0.1, 0.1}})
        z = z + L + 0.006
      end
    end
  end
end
-- the mismatched unit: a hand-brushed amber band and a painted number
local p = pumps[3]
local hb = brush{kind="flat", width=5}
hb:load(amber, 0.9)
hb:stroke({P(PX2, 285, p.z1 + 0.01), P(PX2, 290, p.z1 + 0.13), P(PX2, 283, p.z2 - 0.01)}, {pressure={0.9, 0.7}, shake=1.5})
local nb = brush{kind="round", width=2.2, point=0.5}
nb:load(plateW, 0.9)
local zc, Yc = p.z1 + 0.12, -40
nb:stroke({P(PX2, Yc - 30, zc - 0.03), P(PX2, Yc - 36, zc + 0.02), P(PX2, Yc - 12, zc + 0.03), P(PX2, Yc - 4, zc - 0.01)}, {pressure={0.8, 0.5}, shake=1})
nb:stroke({P(PX2, Yc - 4, zc - 0.01), P(PX2, Yc + 14, zc + 0.035), P(PX2, Yc + 34, zc + 0.01), P(PX2, Yc + 30, zc - 0.035)}, {pressure={0.7, 0.3}, shake=1})

--@ chunk 33
-- a prefab patch panel bolted over the hull, near right, with its placard
local pz1, pz2 = 0.72, 1.22
local panel = wallq(500, -250, 170, pz1, pz2) - strutsM
local pside = frontq(pz2, 500, XR, -250, 170) - strutsM
work(panel, {hand="body", pile=pgM2, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={20,50}})
work(pside, {hand="detail", pile=pgK, coverage=3, fill=true, angle=math.pi/2})
-- sagging cables strung along the ceiling, jury-rigged
local cab = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local cb = brush{kind="round", width=3.2, point=0.3}
local function cable(X1, z1, X2, z2, sag, w)
  local pts = {}
  for k = 0, 12 do
    local t = k / 12
    local X = lerp(X1, X2, t); local z = lerp(z1, z2, t)
    local Y = YC + 8 + sag * 4 * t * (1 - t)
    pts[#pts+1] = P(X, Y, z)
  end
  cb:load(cab, 0.9)
  cb:stroke(pts, {pressure={w, w * 0.7}, ramps={0.02, 0.05}})
end
cable(-480, 0.65, -300, 2.4, 70, 0.9)
cable(-440, 0.7, 120, 1.9, 110, 0.85)
cable(380, 0.66, 300, 3.2, 90, 0.8)
cable(300, 3.2, 430, 4.6, 40, 0.5)

--@ chunk 34
-- a prefab panel bolted over the hull between two struts, with a printed placard and a painted warning
local pz1, pz2 = 1.55, 2.12
patch2 = wallq(503, -200, 120, pz1, pz2)
work(patch2, {hand="body", pile=pgM2, coverage=3.4, fill=true, clip=true, angle=math.pi/2, length={15,40}})
local edge = frontq(pz2, 503, XR, -200, 120)
work(edge, {hand="detail", pile=pgK, coverage=3, fill=true, angle=math.pi/2})
-- printed placard (machine-language block)
plac2 = wallq(502, -160, -60, pz1 + 0.12, pz1 + 0.38)
work(plac2, {hand="detail", pile=plateW, coverage=4, fill=true, angle=0})

--@ chunk 35
print(wait(24*60))

--@ chunk 36
local red = pile{{"vermilion",1},{"cadmium red",0.5},{"bone black",0.1}}
local bt = brush{kind="round", width=1.1, point=0.6}
local za, zb = 1.69, 1.91
-- header bar, amber
local bh = brush{kind="flat", width=3}
bh:load(amber, 0.9)
bh:stroke({P(502, -150, za), P(502, -150, zb)}, {pressure={0.9, 0.9}, ramps={0.03, 0.03}})
-- rows of machine text
for r = 0, 5 do
  local Y = -135 + r * 12
  local z = za
  bt:load(seamK, 0.8)
  while z < zb - 0.01 do
    local L = rand(0.008, 0.035)
    if r == 2 then L = L * 0.4 end
    bt:stroke({P(502, Y, z), P(502, Y, math.min(z + L, zb))}, {pressure={0.55, 0.55}, ramps={0.1, 0.1}})
    z = z + L + 0.008
  end
end
-- hand-painted red supplement: an arrow toward the far hatch and a slash
local rb = brush{kind="round", width=4, point=0.4}
rb:load(red, 0.9)
rb:stroke({P(502, 10, 1.62), P(502, 6, 1.85), P(502, 12, 2.05)}, {pressure={0.9, 0.7}, shake=1.5})
rb:load(red, 0.9)
rb:stroke({P(502, -12, 1.95), P(502, 10, 2.06), P(502, 34, 1.97)}, {pressure={0.8, 0.5}, shake=1.5})
rb:load(red, 0.8)
rb:stroke({P(502, 60, 1.6), P(502, 75, 1.66), P(502, 66, 1.74), P(502, 84, 1.82)}, {pressure={0.7, 0.4}, shake=2})
-- bolts at the corners
local bb = brush{kind="round", width=2.4}
bb:load(seamK, 0.9)
for _, c in ipairs({{-185, 1.58}, {-185, 2.09}, {105, 1.58}, {105, 2.09}}) do
  local q = P(503, c[1], c[2]); bb:touch(q[1], q[2], {pressure=0.6})
end

--@ chunk 37
print(wait(24*60))
-- frozen coolant drifting in the sun: sparse glints inside the shaft, more near the light
local gl = brush{kind="round", width=1.3, point=0.8}
local cnt = 0
for k = 1, 260 do
  local t = rand(0, 1) ^ 1.3
  local X = lerp(lerp(VPX1, VPX2, rand(0,1)), lerp(PXA, PXB, rand(0,1)), t)
  local Y = lerp(YC, YF, t)
  local z = lerp(lerp(VPZ1, VPZ2, rand(0,1)), lerp(PZ1, PZ2, rand(0,1)), t)
  local q = P(X, Y, z)
  if k % 12 == 1 then gl:load(sunW, 0.7) end
  gl:touch(q[1], q[2], {pressure=rand(0.15, 0.5) * (1.1 - 0.5 * t)})
  cnt = cnt + 1
end
print(cnt)
-- the machine's one cold eye
local eyeP = pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.2}}
local eb = brush{kind="round", width=1.6, point=0.6}
eb:load(eyeP, 0.9)
eb:touch(575, 270.5, {pressure=0.7})

--@ chunk 38
print(wait(4*24*60))
darkG = pile{{"bone black",1},{"burnt sienna",0.4},{"ultramarine blue",0.6}, medium=0.8}
local keep = viewM:grow(3) + patchM:grow(3) + hatchM:grow(4) + machM:grow(1)
local G = everywhere() - keep
local lc = P((PXA+PXB)/2, YF, (PZ1+PZ2)/2)
local lv = P(30, YC, 2.5)
local ld = function(x, y)
  local d1 = math.sqrt((x - lc[1])^2 + ((y - lc[2]) * 1.6)^2)
  local d2 = math.sqrt((x - lv[1])^2 + ((y - lv[2]) * 1.6)^2)
  local d = math.min(d1, d2)
  return 0.12 + 0.55 * clamp((d - 60) / 450, 0, 1)
end
work(G, {hand="glaze", pile=darkG, coverage=1.3, fill=true, clip=true, load_at=ld, pressure={0.2, 0.4}, angle=radial})
blend(G, {angle=radial})

--@ chunk 39
local keep = viewM:grow(3) + patchM:grow(3) + hatchM:grow(4) + machM:grow(1)
blend(everywhere() - keep, {angle=math.pi/2, seed=77})

--@ chunk 40
print(wait(4*24*60))
rimP = pile{{"lead white",2},{"ultramarine ash",0.6},{"bone black",0.15}}
local rb = brush{kind="round", width=1.4, point=0.7}
-- hairline on each pump's near vertical corner (where side meets front)
for i, p in ipairs(pumps) do
  if p.z1 < 4.5 then
    local l = litz(p.z1)
    rb:load(rimP, 0.5 + 0.4 * l)
    rb:stroke({P(PX2, PYT + 2, p.z1), P(PX2, YF - 4, p.z1)}, {pressure={0.25 + 0.4 * l, 0.15}, ramps={0.05, 0.3}})
  end
end
-- struts: a thin lit edge on the corridor side
for _, z in ipairs(strutZ) do
  local l = litz(z)
  rb:load(rimP, 0.4 + 0.5 * l)
  rb:stroke({P(490, YC + 4, z), P(490, YF - 4, z)}, {pressure={0.15 + 0.45 * l, 0.1 + 0.4 * l}, ramps={0.05, 0.1}})
end
-- the viewport frame catches the sun on its lower lip
local sb = brush{kind="round", width=1.6, point=0.7}
sb:load(sunW, 0.8)
sb:stroke({P(VPX1, YC, VPZ2 + 0.01), P(VPX2, YC, VPZ2 + 0.01)}, {pressure={0.5, 0.4}})
-- patch: crisp hot core restated
work(patchLit * flatq(YF, PXA + 30, PXB - 30, PZ1 + 0.06, PZ2 - 0.06), {hand="detail", pile=sunW, coverage=2.5, fill=true, angle=0})

--@ chunk 41
local eyeP = pile{{"zinc white",2},{"cerulean blue",1.2},{"viridian",0.25}}
local eb = brush{kind="round", width=2.2, point=0.5}
eb:load(eyeP, 1)
eb:touch(575.5, 270.8, {pressure=0.9})
local hb = brush{kind="round", width=1.0, point=0.9}
hb:load(pile{{"zinc white",3},{"cerulean blue",0.3}}, 0.8)
hb:touch(575.6, 270.6, {pressure=0.5})

--@ chunk 42
local m = nil
local z = 0.7
while z < 5.8 do
  local d = flatq(YF, -415, -385, z, z + 0.18)
  m = m and (m + d) or d
  z = z + 0.3
end
work(m, {hand="detail", pile=amberS, coverage=2.2, fill=false, angle=radial, load=0.6})

--@ chunk 43
-- foreground: a prefab cargo case left on the deck, lower right
local cX1, cX2, cY, cz1, cz2 = 240, 470, 230, 1.0, 1.32
crTop   = flatq(cY, cX1, cX2, cz1, cz2)
crSide  = wallq(cX1, cY, YF, cz1, cz2)
crFront = frontq(cz1, cX1, cX2, cY, YF)
crTopP = pile{{"lead white",0.45},{"bone black",1.1},{"ultramarine ash",0.8}, medium=0.1}
work(crFront, {hand="body", pile=pgF, coverage=3.4, fill=true, clip=true, angle=0, length={20,50}})
work(crSide - crFront, {hand="body", pile=pgD2, coverage=3.4, fill=true, clip=true, angle=radial, length={15,40}})
work(crTop - crFront - crSide, {hand="body", pile=crTopP, coverage=3.4, fill=true, clip=true, angle=radial, length={15,40}})
-- dead ceiling fixtures, one on each panel row, one hanging down on its cable
fixtureM = nil
for _, z in ipairs({1.18, 1.92, 3.03, 3.77, 4.51}) do
  local f = flatq(YC + 2, -60, 120, z, z + 0.16)
  fixtureM = fixtureM and (fixtureM + f) or f
end
fixG = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.3},{"cerulean blue",0.1}}
work(fixtureM, {hand="detail", pile=fixG, coverage=3, fill=true, angle=0})

--@ chunk 44
print(wait(2*24*60))
crTopD = pile{{"lead white",0.12},{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.15}, medium=0.1}
crFrontD = pile{{"bone black",1.6},{"ultramarine ash",0.7},{"burnt sienna",0.25}, medium=0.1}
local top = crTop - crFront - crSide
work(top, {hand="body", pile=crTopD, coverage=3.6, fill=true, clip=true, angle=radial, length={15,40}})
work(crFront, {hand="body", pile=crFrontD, coverage=3.6, fill=true, clip=true, angle=0, length={20,50}})
work(crSide - crFront, {hand="body", pile=crTopD, coverage=3.6, fill=true, clip=true, angle=radial, length={15,40}})

--@ chunk 45
print(wait(3*24*60))
local cX1, cX2, cY, cz1, cz2 = 240, 470, 230, 1.0, 1.32
local rb = brush{kind="round", width=1.6, point=0.7}
-- edges catching the light from the sun patch behind: top-back edge brightest
rb:load(rimP, 0.8)
rb:stroke({P(cX1, cY, cz2), P(cX2 + 200, cY, cz2)}, {pressure={0.55, 0.4}, ramps={0.05, 0.1}})
rb:load(rimP, 0.6)
rb:stroke({P(cX1, cY, cz1), P(cX1, cY, cz2)}, {pressure={0.35, 0.5}, ramps={0.05, 0.1}})
rb:load(rimP, 0.5)
rb:stroke({P(cX1, cY, cz1), P(cX2 + 200, cY, cz1)}, {pressure={0.3, 0.25}, ramps={0.05, 0.1}})
rb:load(rimP, 0.4)
rb:stroke({P(cX1, cY, cz1), P(cX1, YF, cz1)}, {pressure={0.3, 0.1}, ramps={0.05, 0.3}})
-- amber corner chevrons on the front, a stencilled code block
local cm = poly({P(cX1, cY + 8, cz1), P(cX1 + 70, cY + 8, cz1), P(cX1, cY + 78, cz1)})
work(cm, {hand="detail", pile=amberS, coverage=3, fill=true, angle=0})
local sb = brush{kind="flat", width=2.2}
local x0 = cX1 + 95
for k = 0, 4 do
  sb:load(amberS, 0.7)
  local a = P(x0 + k * 22, cY + 40, cz1); local b = P(x0 + k * 22 + (k % 2 == 0 and 14 or 8), cY + 40, cz1)
  sb:stroke({a, b}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
end
sb:load(amberS, 0.7)
local a = P(x0, cY + 62, cz1); local b = P(x0 + 60, cY + 62, cz1)
sb:stroke({a, b}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})

--@ chunk 46
-- louvred vents and panel seams on every pump side: the same module, repeated
local bk = brush{kind="round", width=1.6, point=0.4}
local bl = brush{kind="round", width=0.9, point=0.7}
for i, p in ipairs(pumps) do
  if p.z1 < 4.3 then
    local za, zb = p.z1 + 0.045, p.z2 - 0.045
    local s = 1 / p.z1
    for r = 0, 6 do
      local Y = 120 + r * 16
      bk:load(seamK, 0.8)
      bk:stroke({P(PX2, Y, za), P(PX2, Y, zb)}, {pressure={0.35 + 0.4 * s, 0.35 + 0.3 * s}, ramps={0.03, 0.03}})
      if p.z1 < 3.2 then
        bl:load(pgM2, 0.6)
        bl:stroke({P(PX2, Y + 5, za), P(PX2, Y + 5, zb)}, {pressure={0.3, 0.25}, ramps={0.05, 0.05}})
      end
    end
    -- a horizontal panel seam above the vents and one below the placard
    bk:load(seamK, 0.8)
    bk:stroke({P(PX2, 90, p.z1), P(PX2, 90, p.z2)}, {pressure={0.3 + 0.3 * s, 0.3 + 0.3 * s}, ramps={0.02, 0.02}})
    bk:load(seamK, 0.8)
    bk:stroke({P(PX2, -110, p.z1), P(PX2, -110, p.z2)}, {pressure={0.3 + 0.3 * s, 0.3 + 0.3 * s}, ramps={0.02, 0.02}})
  end
end

--@ chunk 47
red = pile{{"vermilion",1},{"cadmium red",0.5},{"bone black",0.1}}
local z = pumps[1].z1
local inset = frontq(z, -598, -472, -50, 130)
work(inset, {hand="detail", pile=crFrontD, coverage=3.5, fill=true, angle=0})
-- the inset's lit lower lip and dark upper shadow
local rb = brush{kind="round", width=1.6, point=0.6}
rb:load(rimP, 0.5)
rb:stroke({P(-598, 130, z), P(-472, 130, z)}, {pressure={0.4, 0.3}})
-- a dead gauge
local g = P(-535, -100, z)
local gr = 26 / z
work(ellipse(g[1], g[2], gr, gr), {hand="detail", pile=crFrontD, coverage=3.5, fill=true})
work(ellipse(g[1], g[2], gr * 0.75, gr * 0.75), {hand="detail", pile=pile{{"lead white",0.6},{"bone black",1},{"ultramarine ash",0.6},{"yellow ochre",0.15}}, coverage=3.5, fill=true})
local nb = brush{kind="round", width=1.2, point=0.8}
nb:load(red, 0.8)
nb:stroke({{g[1], g[2]}, {g[1] - gr * 0.55, g[2] + gr * 0.35}}, {pressure={0.5, 0.2}})
-- three small status lamps on the inset: two dead, one amber still lit
local lamps = {{-580, -20, crTopP}, {-560, -20, crTopP}, {-540, -20, amber}}
for _, l in ipairs(lamps) do
  local q = P(l[1], l[2], z)
  local lb = brush{kind="round", width=2.4}
  lb:load(l[3], 0.9); lb:touch(q[1], q[2], {pressure=0.6})
end
-- rows of switch slots
for r = 0, 3 do
  local bk = brush{kind="round", width=1.4, point=0.4}
  bk:load(seamK, 0.8)
  bk:stroke({P(-590, 20 + r * 25, z), P(-500, 20 + r * 25, z)}, {pressure={0.5, 0.5}, ramps={0.03,0.03}})
end

--@ chunk 48
print(wait(3*24*60))
local z = pumps[1].z1
local g = P(-535, -100, z)
local gr = 26 / z
local nb = brush{kind="round", width=1.4, point=0.8}
nb:load(red, 0.9)
nb:stroke({{g[1], g[2]}, {g[1] - gr * 0.55, g[2] + gr * 0.4}}, {pressure={0.6, 0.25}})
local hb = brush{kind="round", width=1.0, point=0.8}
hb:load(rimP, 0.7)
hb:stroke({{g[1] - gr * 0.5, g[2] - gr * 0.55}, {g[1] + gr * 0.2, g[2] - gr * 0.7}}, {pressure={0.4, 0.1}})
-- status lamps under the dead screen: two dead, one amber still lit
local lb = brush{kind="round", width=3}
for k, X in ipairs({-585, -565, -545}) do
  local q = P(X, 155, z)
  lb:load(k == 3 and amber or crTopP, 0.9); lb:touch(q[1], q[2], {pressure=0.7})
end
local hot = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.3}}
local q = P(-545, 155, z); local tb = brush{kind="round", width=1.2}; tb:load(hot, 0.9); tb:touch(q[1] - 0.3, q[2] - 0.3, {pressure=0.5})
-- a faint reflection across the dead screen: the sun patch, far behind
local rb = brush{kind="filbert", width=4}
rb:load(pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.4}}, 0.35)
rb:stroke({P(-590, 90, z), P(-480, -30, z)}, {pressure={0.3, 0.1}})

--@ chunk 49
local z = pumps[1].z1
local lb = brush{kind="round", width=7}
for k, X in ipairs({-585, -565, -545}) do
  local q = P(X, 155, z)
  lb:load(k == 3 and amber or crFrontD, 0.9); lb:touch(q[1], q[2], {pressure=0.8})
end

--@ chunk 50
print(wait(2*24*60)); local q = P(-545,155,pumps[1].z1); local tb = brush{kind="round", width=3}; tb:load(pile{{"cadmium yellow",1},{"lead white",1.2},{"Mars orange",0.2}}, 0.9); tb:touch(q[1]-0.5, q[2]-0.5, {pressure=0.6})

--@ chunk 51
-- conduits along the top of the left wall, the outpost's plumbing laid in a hurry
local conduits = {{-600, -300, 16}, {-600, -262, 12}, {-605, -232, 9}}
conduitM = nil
for _, c in ipairs(conduits) do
  local m = wallq(c[1], c[2] - c[3], c[2] + c[3], 0.62, ZF) - pipesM
  conduitM = conduitM and (conduitM + m) or m
  work(m, {hand="detail", pile=pgF, coverage=3.4, fill=true, angle=radial})
end

--@ chunk 52
print(wait(2*24*60))
-- reflected sun from the floor patch warms the hull's lowest scales nearest it
local bL = brush{kind="round", width=1.8, point=0.8}
local hotL = pile{{"yellow ochre",1.5},{"lead white",1.5},{"cadmium yellow",0.4}}
local n = 0
for k = 1, 70 do
  local z = rand(2.3, 3.6)
  local Y = rand(120, 370)
  local d = math.abs(z - 2.85) / 0.6 + (370 - Y) / 260
  if d < 1.3 and rand(0,1) > d * 0.6 then
    local pts = {}
    local hw = rand(28, 42)
    for j = 0, 6 do
      local t = -1 + j / 3
      pts[#pts+1] = P(XR, Y - 3 + 14 * (1 - t * t), z + hw * t / 600)
    end
    bL:load(hotL, 0.7)
    bL:stroke(pts, {pressure={0.45 * (1.3 - d) + 0.1, 0.05}, ramps={0.2, 0.5}})
    n = n + 1
  end
end
print(n)
-- verdigris crusted in the recesses of the old hull
local verd = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.6},{"yellow ochre",0.4}}
local vm = rightM - strutsM - patch2:grow(2) - crTop - crSide - crFront
local nz = noise{seed=41, period=60, octaves=3}
stipple(vm, {pile=verd, width=1.6, coverage=function(x, y) return math.max(0, nz(x, y) - 0.35) * 0.5 end, cluster=0.7, feather=0.6, pressure={0.2, 0.5}})

--@ chunk 53
print(wait(2*24*60))
local m = (patch2 - plac2:grow(1)) + wallq(490, YC, YF, 1.35, 1.41) + frontq(1.35, 490, XR, YC, YF)
work(m, {hand="glaze", pile=darkG, coverage=1.3, fill=true, clip=true, load=0.45, pressure={0.25, 0.4}, angle=math.pi/2})
blend(m, {angle=math.pi/2, tool={kind="badger", width=12}})

--@ chunk 54
print(wait(3*24*60))
local cX1, cX2, cY, cz1, cz2 = 240, 470, 230, 1.0, 1.32
local strutArea = (wallq(490, YC, YF, 1.35, 1.41) + frontq(1.35, 490, XR, YC, YF)):grow(3)
local top = (crTop - crFront - crSide) * strutArea
local front = crFront * strutArea
work(top, {hand="detail", pile=crTopD, coverage=4, fill=true, angle=radial})
work(front, {hand="detail", pile=crFrontD, coverage=4, fill=true, angle=0})

--@ chunk 55
print(wait(3*24*60))
local rb = brush{kind="round", width=4.2, point=0.4}
rb:load(red, 0.95)
rb:stroke({P(502, 10, 1.62), P(502, 6, 1.85), P(502, 12, 2.05)}, {pressure={0.95, 0.75}, shake=1.5})
rb:load(red, 0.95)
rb:stroke({P(502, -12, 1.95), P(502, 10, 2.06), P(502, 34, 1.97)}, {pressure={0.85, 0.55}, shake=1.5})
rb:load(red, 0.9)
rb:stroke({P(502, 60, 1.6), P(502, 75, 1.66), P(502, 66, 1.74), P(502, 84, 1.82)}, {pressure={0.75, 0.45}, shake=2})
local cX1, cX2, cY, cz1, cz2 = 240, 470, 230, 1.0, 1.32
local eb = brush{kind="round", width=1.6, point=0.7}
eb:load(rimP, 0.5)
eb:stroke({P(cX1, cY, cz1), P(cX2 + 100, cY, cz1)}, {pressure={0.3, 0.25}, ramps={0.05, 0.1}})

--@ chunk 56
cab = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
-- a light fixture torn half loose, hanging on its cables
local a1 = P(-300, YC, 1.6); local a2 = P(-140, YC, 1.66)
local e1 = P(-320, -175, 1.6); local e2 = P(-160, -130, 1.64)
local cb = brush{kind="round", width=1.3, point=0.5}
cb:load(cab, 0.9); cb:stroke({a1, {lerp(a1[1], e1[1], 0.5) - 3, lerp(a1[2], e1[2], 0.5)}, e1}, {pressure={0.6, 0.6}})
cb:load(cab, 0.9); cb:stroke({a2, {lerp(a2[1], e2[1], 0.5) + 2, lerp(a2[2], e2[2], 0.5)}, e2}, {pressure={0.6, 0.6}})
local th = 9
local bar = poly({{e1[1], e1[2]}, {e2[1], e2[2]}, {e2[1], e2[2] + th}, {e1[1], e1[2] + th}})
work(bar, {hand="detail", pile=crFrontD, coverage=4, fill=true, angle=math.atan(e2[2]-e1[2], e2[1]-e1[1])})
local lip = poly({{e1[1], e1[2] + th - 2.5}, {e2[1], e2[2] + th - 2.5}, {e2[1], e2[2] + th}, {e1[1], e1[2] + th}})
fixLip = lip

--@ chunk 57
print(wait(2*24*60))
-- the hatch's amber light lies on the deck plates as a broken reflection
local rb = brush{kind="filbert", width=3}
for k = 1, 22 do
  local x = 560 + randn(0, 5)
  local y0 = 313 + rand(0, 6)
  local L = rand(6, 26) * (1 - math.abs(x - 560) / 30)
  rb:load(k % 3 == 0 and glowA or glowB, rand(0.25, 0.45))
  rb:stroke({{x, y0}, {x + rand(-1, 1), y0 + L}}, {pressure={0.35, 0.05}, ramps={0.1, 0.6}})
end
local lb = brush{kind="round", width=1.2, point=0.7}
lb:load(rimP, 0.5)
local e1 = P(-320, -175, 1.6); local e2 = P(-160, -130, 1.64)
lb:stroke({{e1[1], e1[2] + 8.5}, {e2[1], e2[2] + 8.5}}, {pressure={0.35, 0.45}})

--@ chunk 58
local m = rect(540, 312, 40, 30)
for k = 1, 2 do work(m, {hand="scumble", blender=true, coverage=1.5, clip=true, tool={kind="filbert", width=3}, seed=300+k, angle=math.pi/2}) end

--@ chunk 59
print(wait(3*24*60))
local keepR = poly({{551, 312}, {571, 312}, {566, 342}, {556, 342}})
local m = rect(536, 312, 48, 34) - keepR
work(m, {hand="detail", pile=floorK, coverage=4, fill=true, angle=math.pi/2})

--@ chunk 60
-- a coolant leak frozen where it ran: rime on the deck at the foot of pump 5, creeping up its side
frost = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.35},{"bone black",0.05}}
local p = pumps[5]
local zc = (p.z1 + p.z2) / 2
local c = P(-420, YF, zc + 0.05)
local fl = floorM * ellipse(c[1] + 6, c[2] + 2, 34, 9):blur(6)
local sd = pumpSideV[5] * wallq(PX2, 330, YF, p.z1, p.z2) * mask(function(x, y) return clamp((y - (c[2] - 22)) / 22, 0, 1) end)
local nz = noise{seed=9, period=14, octaves=3}
stipple(fl + sd, {pile=frost, width=1.4, coverage=function(x, y) return math.max(0, 0.25 + 0.35 * nz(x, y)) end, feather=0.8, cluster=0.5, pressure={0.15, 0.45}, mix_jitter=0.1})

--@ chunk 61
-- a coolant leak frozen where it ran: rime on the deck at the foot of pump 5, creeping up its side
frost = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.35},{"bone black",0.05}}
local p = pumps[5]
local zc = (p.z1 + p.z2) / 2
local c = P(-420, YF, zc + 0.05)
local fl = floorM * ellipse(c[1] + 6, c[2] + 2, 34, 9):blur(6)
local sd = pumpSideV[5] * wallq(PX2, 330, YF, p.z1, p.z2) * mask(function(x, y) return clamp((y - (c[2] - 22)) / 22, 0, 1) end)
local nz = noise{seed=9, period=14, octaves=3}
stipple(fl + sd, {pile=frost, width=2, coverage=function(x, y) return math.max(0, 0.9 + 0.8 * nz(x, y)) end, feather=0.8, cluster=0.5, pressure={0.15, 0.45}, mix_jitter=0.1})

--@ chunk 62
local frameH = frontq(ZF, -135, 135, -170, YF) - hatchM
local st = nil
for x = 520, 600, 6 do
  local m = poly({{x, 220}, {x + 3, 220}, {x + 3 + 90, 320}, {x + 90, 320}})
  st = st and (st + m) or m
end
work(frameH * st, {hand="detail", pile=seamK, coverage=4, fill=true, angle=0, tool={kind="round", width=0.8}})

--@ chunk 63
local frameH = frontq(ZF, -135, 135, -170, YF) - hatchM
local st = nil
for x = 430, 519, 6 do
  local m = poly({{x, 220}, {x + 3, 220}, {x + 3 + 90, 320}, {x + 90, 320}})
  st = st and (st + m) or m
end
work(frameH * st, {hand="detail", pile=seamK, coverage=4, fill=true, angle=0, tool={kind="round", width=0.8}})

--@ chunk 64
-- a hanging wayfinding board in machine language
local z = 3.5
local sign = frontq(z, -300, -40, -298, -248)
local cb = brush{kind="round", width=0.9, point=0.5}
for _, X in ipairs({-280, -60}) do cb:load(cab, 0.9); cb:stroke({P(X, YC, z), P(X, -298, z)}, {pressure={0.5, 0.5}}) end
work(sign, {hand="detail", pile=amberS, coverage=4, fill=true, angle=0})

--@ chunk 65
print(wait(2*24*60))
local z = 3.5
local gb = brush{kind="flat", width=1.6}
local X = -285
local codes = {2,1,3,0,1,2,2,0,3,1}
for k, c in ipairs(codes) do
  if c > 0 then
    gb:load(seamK, 0.9)
    local w = 8 + c * 6
    gb:stroke({P(X, -273, z), P(X + w, -273, z)}, {pressure={0.9, 0.9}, ramps={0.05,0.05}})
    X = X + w + 7
  else X = X + 12 end
end

--@ chunk 66
print(wait(3*24*60))
nightG = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}, medium=0.65}
lampP = P(-545, 155, pumps[1].z1)
lights = {
  {659, 384, 380, 1.5},   -- the sun patch: wide, flattened (floor plane)
  {560, 275, 75, 1.0},    -- the hatch
  {lampP[1], lampP[2], 45, 1.0}, -- the one live status lamp
}
function darkness(x, y)
  local f = 1
  for _, L in ipairs(lights) do
    local dx, dy = x - L[1], (y - L[2]) * L[4]
    f = math.min(f, math.sqrt(dx*dx + dy*dy) / L[3])
  end
  return smoothstep(0.12, 1.0, f)
end
keepLight = viewM:grow(2) + patchM:grow(2) + hatchM + machM:grow(1) + ellipse(lampP[1], lampP[2], 5, 5) + ellipse(575.5, 270.8, 3, 3)
local G = everywhere() - keepLight
work(G, {hand="glaze", pile=nightG, coverage=1.5, fill=true, clip=true, load_at=function(x, y) return 0.08 + 0.8 * darkness(x, y) end, pressure={0.25, 0.5}, angle=radial})
blend(G, {angle=radial})

--@ chunk 67
blend(everywhere() - keepLight, {angle=math.pi/2, seed=91})

--@ chunk 68
print(wait(6*24*60)); for _,q in ipairs({{100,100},{300,300},{500,30},{850,250},{560,500},{500,250}}) do print(q[1],q[2],drying(q[1],q[2]), string.format("%.2f", darkness(q[1],q[2]))) end

--@ chunk 69
nearBlack = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.4}, medium=0.1}
lights2 = {
  {659, 384, 560, 1.5},
  {560, 275, 110, 1.0},
  {lampP[1], lampP[2], 90, 1.0},
}
function shade(x, y)
  local f = 1
  for _, L in ipairs(lights2) do
    local dx, dy = x - L[1], (y - L[2]) * L[4]
    f = math.min(f, math.sqrt(dx*dx + dy*dy) / L[3])
  end
  return smoothstep(0.3, 1.0, f)
end
local W = mask(function(x, y) return shade(x, y) end) * (everywhere() - keepLight:grow(1))
work(W, {hand="body", pile=nearBlack, coverage=3, fill=true, clip=true, angle=radial, length={25,70}, threshold=0.08})

--@ chunk 70
print(wait(5*24*60)); for _,q in ipairs({{300,300},{340,300},{100,380},{850,250},{560,600}}) do print(q[1],q[2],drying(q[1],q[2])) end

--@ chunk 71
bounceG1 = pile{{"lead white",0.4},{"bone black",1.2},{"ultramarine ash",0.8},{"raw sienna",0.2}, medium=0.1}
bounceG2 = pile{{"lead white",0.15},{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.2}, medium=0.1}
oliveDim = pile{{"yellow ochre",0.8},{"bone black",1.3},{"viridian",0.2},{"lead white",0.12}, medium=0.1}
amberDim = pile{{"Mars orange",1},{"raw sienna",1},{"bone black",0.7}}
local grad = mask(function(x, y)
  if x >= VX - 1 then return 0 end
  local z = PX2 / (x - VX)
  local Y = (y - VY) * z
  return 0.35 + 0.65 * clamp((Y + 140) / 520, 0, 1)
end)
litPumps = {}
for i, p in ipairs(pumps) do
  local l = litz(p.z1 + 0.13)
  if l > 0.25 then
    litPumps[#litPumps+1] = i
    local pl = (i == 3) and oliveDim or ((l > 0.6) and bounceG1 or bounceG2)
    work((pumpSideV[i] - hazSide) * grad, {hand="body", pile=pl, coverage=3.2, fill=true, clip=true, angle=math.pi/2, length={15,40}, threshold=0.05})
    work(pumpSideV[i] * hazSide, {hand="detail", pile=amberDim, coverage=3.5, fill=true, angle=0})
  end
end
print(table.concat(litPumps, ","))

--@ chunk 72
print(wait(2*24*60))
pumpLo = pile{{"lead white",0.1},{"bone black",1.5},{"ultramarine ash",0.8},{"raw sienna",0.25}, medium=0.1}
pumpHi = pile{{"bone black",1.7},{"ultramarine ash",0.6},{"burnt sienna",0.25}, medium=0.1}
oliveLo = pile{{"yellow ochre",0.7},{"bone black",1.6},{"viridian",0.2}, medium=0.1}
oliveHi = pile{{"yellow ochre",0.5},{"bone black",1.8},{"viridian",0.15}, medium=0.1}
amberDim2 = pile{{"Mars orange",1},{"raw sienna",1},{"bone black",1.4}}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  local lo = pumpSideV[i] * wallq(PX2, 90, YF, p.z1, p.z2) - hazSide
  local hi = pumpSideV[i] * wallq(PX2, PYT, 90, p.z1, p.z2)
  local l = litz(p.z1 + 0.13)
  local pl, ph = pumpLo, pumpHi
  if i == 3 then pl, ph = oliveLo, oliveHi end
  if l < 0.6 then pl = ph end
  work(lo, {hand="body", pile=pl, coverage=3.4, fill=true, clip=true, angle=math.pi/2, length={15,40}})
  work(hi, {hand="body", pile=ph, coverage=3.4, fill=true, clip=true, angle=math.pi/2, length={15,40}})
  work(pumpSideV[i] * hazSide, {hand="detail", pile=amberDim2, coverage=3.5, fill=true, angle=0})
end

--@ chunk 73
print(wait(2*24*60))
rimDim = pile{{"lead white",1},{"ultramarine ash",0.8},{"bone black",0.6}}
plateDim = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.5},{"yellow ochre",0.1}}
-- hazard stripes back on the bands
local st = nil
local function add(m) st = st and (st + m) or m end
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  local a = p.z1 - 0.04
  while a < p.z2 do
    add(poly({P(PX2, 262, a), P(PX2, 262, a + 0.028), P(PX2, 312, a + 0.028 + 0.035), P(PX2, 312, a + 0.035)}))
    a = a + 0.062
  end
end
work(st * hazSide, {hand="detail", pile=nearBlack, coverage=4, fill=true, angle=0, tool={kind="round", width=1.2}})
local bk = brush{kind="round", width=1.6, point=0.4}
local bl = brush{kind="round", width=0.9, point=0.7}
local rb = brush{kind="round", width=1.3, point=0.7}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  local l = litz(p.z1 + 0.13)
  local s = 1 / p.z1
  local za, zb = p.z1 + 0.045, p.z2 - 0.045
  if p.z1 < 4.3 then
    for r = 0, 6 do
      local Y = 120 + r * 16
      bk:load(nearBlack, 0.8)
      bk:stroke({P(PX2, Y, za), P(PX2, Y, zb)}, {pressure={0.35 + 0.4 * s, 0.35 + 0.3 * s}, ramps={0.03, 0.03}})
      if l > 0.5 then
        bl:load(pumpLo, 0.6)
        bl:stroke({P(PX2, Y + 5, za), P(PX2, Y + 5, zb)}, {pressure={0.3, 0.25}, ramps={0.05, 0.05}})
      end
    end
    for _, Y in ipairs({90, -110}) do
      bk:load(nearBlack, 0.8)
      bk:stroke({P(PX2, Y, p.z1), P(PX2, Y, p.z2)}, {pressure={0.3 + 0.3 * s, 0.3 + 0.3 * s}, ramps={0.02, 0.02}})
    end
  end
  -- the module's near corner catches the bounce: a hairline, brighter low
  rb:load(rimDim, 0.4 + 0.4 * l)
  rb:stroke({P(PX2, PYT + 4, p.z1), P(PX2, YF - 4, p.z1)}, {pressure={0.1 + 0.2 * l, 0.2 + 0.45 * l}, ramps={0.1, 0.1}})
end

--@ chunk 74
print(wait(2*24*60))
redDim = pile{{"vermilion",1},{"cadmium red",0.4},{"bone black",0.35}}
-- printed placards, dim in the bounce
local bt = brush{kind="round", width=0.9, point=0.6}
local bh = brush{kind="flat", width=1.6}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  if i ~= 3 and p.z1 < 4.0 then
    local za, zb = p.z1 + 0.06, p.z1 + 0.15
    work(pumpSideV[i] * wallq(PX2, -70, -20, za, zb), {hand="detail", pile=plateDim, coverage=4, fill=true, angle=0, tool={kind="round", width=1}})
  end
end
-- the hand-painted 3 on the odd unit
local p = pumps[3]
local nb = brush{kind="round", width=2.2, point=0.5}
nb:load(plateDim, 0.9)
local zc, Yc = p.z1 + 0.12, -40
nb:stroke({P(PX2, Yc - 30, zc - 0.03), P(PX2, Yc - 36, zc + 0.02), P(PX2, Yc - 12, zc + 0.03), P(PX2, Yc - 4, zc - 0.01)}, {pressure={0.8, 0.5}, shake=1})
nb:stroke({P(PX2, Yc - 4, zc - 0.01), P(PX2, Yc + 14, zc + 0.035), P(PX2, Yc + 34, zc + 0.01), P(PX2, Yc + 30, zc - 0.035)}, {pressure={0.7, 0.3}, shake=1})
-- the patched panel on the hull: dim slate, its placard, the painted arrow
local pz1, pz2 = 1.55, 2.12
work(patch2 - plac2, {hand="body", pile=pumpHi, coverage=3.4, fill=true, clip=true, angle=math.pi/2, length={15,40}})
work(plac2, {hand="detail", pile=plateDim, coverage=4, fill=true, angle=0})

--@ chunk 75
print(wait(2*24*60))
plateDark = pile{{"ultramarine ash",1},{"bone black",0.9},{"yellow ochre",0.1}, medium=0.1}
panelDark = pile{{"bone black",1.8},{"ultramarine ash",0.5},{"burnt sienna",0.15}, medium=0.1}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  if i ~= 3 and p.z1 < 4.0 then
    work(pumpSideV[i] * wallq(PX2, -70, -20, p.z1 + 0.06, p.z1 + 0.15), {hand="detail", pile=plateDark, coverage=4, fill=true, angle=0, tool={kind="round", width=1}})
  end
end
work(patch2 - plac2, {hand="body", pile=panelDark, coverage=3.6, fill=true, clip=true, angle=math.pi/2, length={15,40}})
work(plac2, {hand="detail", pile=plateDark, coverage=4, fill=true, angle=0})
-- the upper pump panels: cooler, not brown
local cool = pile{{"bone black",1.7},{"ultramarine ash",0.9}, medium=0.1}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  if i ~= 3 then
    local hi = pumpSideV[i] * wallq(PX2, PYT, 90, p.z1, p.z2) - wallq(PX2, -72, -18, p.z1 + 0.055, p.z1 + 0.155)
    work(hi, {hand="body", pile=cool, coverage=3.4, fill=true, clip=true, angle=math.pi/2, length={15,40}})
  end
end

--@ chunk 76
print(wait(2*24*60))
textK = pile{{"bone black",2},{"burnt sienna",0.3}}
local bt = brush{kind="round", width=0.9, point=0.6}
local bh = brush{kind="flat", width=1.6}
for _, i in ipairs(litPumps) do
  local p = pumps[i]
  if i ~= 3 and p.z1 < 4.0 then
    local za, zb = p.z1 + 0.065, p.z1 + 0.145
    bh:load(redDim, 0.8)
    bh:stroke({P(PX2, -62, za), P(PX2, -62, zb)}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
    bt:load(textK, 0.7)
    for r = 0, 2 do
      local Y = -50 + r * 10
      local z = za + 0.004
      while z < zb - 0.01 do
        local L = rand(0.006, 0.02)
        bt:stroke({P(PX2, Y, z), P(PX2, Y, math.min(z + L, zb - 0.004))}, {pressure={0.5, 0.5}, ramps={0.1, 0.1}})
        z = z + L + 0.006
      end
    end
  end
end
-- panel placard text and its amber header
local za, zb = 1.69, 1.91
local bh2 = brush{kind="flat", width=3}
bh2:load(amberDim2, 0.9)
bh2:stroke({P(502, -150, za), P(502, -150, zb)}, {pressure={0.9, 0.9}, ramps={0.03, 0.03}})
local bt2 = brush{kind="round", width=1.1, point=0.6}
for r = 0, 5 do
  local Y = -135 + r * 12
  local z = za
  bt2:load(textK, 0.8)
  while z < zb - 0.01 do
    local L = rand(0.008, 0.035)
    bt2:stroke({P(502, Y, z), P(502, Y, math.min(z + L, zb))}, {pressure={0.55, 0.55}, ramps={0.1, 0.1}})
    z = z + L + 0.008
  end
end
-- the hand-painted arrow, dim red in the dark
local rb = brush{kind="round", width=4.2, point=0.4}
rb:load(redDim, 0.95)
rb:stroke({P(502, 10, 1.62), P(502, 6, 1.85), P(502, 12, 2.05)}, {pressure={0.95, 0.75}, shake=1.5})
rb:load(redDim, 0.95)
rb:stroke({P(502, -12, 1.95), P(502, 10, 2.06), P(502, 34, 1.97)}, {pressure={0.85, 0.55}, shake=1.5})
rb:load(redDim, 0.9)
rb:stroke({P(502, 60, 1.6), P(502, 75, 1.66), P(502, 66, 1.74), P(502, 84, 1.82)}, {pressure={0.75, 0.45}, shake=2})
-- a cool hairline on the panel's lit edge
local eb = brush{kind="round", width=1.2, point=0.7}
eb:load(rimDim, 0.5)
eb:stroke({P(503, -200, pz1 or 1.55), P(503, 120, 1.55)}, {pressure={0.2, 0.35}})

--@ chunk 77
print(wait(2*24*60))
-- the one live status lamp: a hot bead with a small warm halo on the dead module front
local lp = lampP
local glowDim = pile{{"Mars orange",1},{"burnt sienna",0.6},{"bone black",0.9}, medium=0.3}
stipple(ellipse(lp[1], lp[2], 16, 16):blur(8) - ellipse(lp[1], lp[2], 3, 3), {pile=glowDim, width=1.6, coverage=function(x, y) local d = math.sqrt((x-lp[1])^2 + (y-lp[2])^2); return clamp(1.4 - d / 14, 0, 1.4) end, feather=0.8, pressure={0.15, 0.35}})
local lb = brush{kind="round", width=5}
lb:load(amber, 0.95); lb:touch(lp[1], lp[2], {pressure=0.8})
local hot = pile{{"cadmium yellow",1},{"lead white",1.3},{"Mars orange",0.2}}
local tb = brush{kind="round", width=2.2}; tb:load(hot, 0.95); tb:touch(lp[1] - 0.4, lp[2] - 0.4, {pressure=0.6})
-- its light catches the lower lip of the dead screen above it
local z = pumps[1].z1
local rb = brush{kind="round", width=1.3, point=0.7}
rb:load(glowA, 0.6)
rb:stroke({P(-598, 130, z), P(-500, 130, z)}, {pressure={0.15, 0.4}})
-- bounce off the sun patch onto the deck around it: short dragged strokes out from its edges
local fb = pile{{"bone black",1.2},{"Mars brown",0.5},{"raw sienna",0.5},{"lead white",0.3}, medium=0.2}
local b = brush{kind="filbert", width=4}
local c = P((PXA+PXB)/2, YF, (PZ1+PZ2)/2)
for k = 1, 46 do
  local t = rand(0, 1)
  local side = k % 4
  local X, Z
  if side == 0 then X = lerp(PXA, PXB, t); Z = PZ1 - 0.01
  elseif side == 1 then X = lerp(PXA, PXB, t); Z = PZ2 + 0.01
  elseif side == 2 then X = PXA - 4; Z = lerp(PZ1, PZ2, t)
  else X = math.min(PXB + 4, XR - 5); Z = lerp(PZ1, PZ2, t) end
  local a = P(X, YF, Z)
  local dx, dy = a[1] - c[1], (a[2] - c[2]) * 3
  local n = math.sqrt(dx*dx + dy*dy)
  local L = rand(10, 34)
  b:load(fb, rand(0.2, 0.35))
  b:stroke({a, {a[1] + dx / n * L, a[2] + dy / n * L / 3}}, {pressure={0.4, 0.02}, ramps={0.05, 0.7}})
end

--@ chunk 78
local ring = (patchM:grow(30) - patchM:grow(1)) * floorM
for k = 1, 2 do work(ring, {hand="scumble", blender=true, coverage=1.5, clip=true, tool={kind="filbert", width=5}, seed=400+k}) end
blend(ring, {angle=0, tool={kind="badger", width=10}})

--@ chunk 79
blend((patchM:grow(48) - patchM:grow(14)) * floorM, {angle=0, tool={kind="badger", width=14}, seed=5})

--@ chunk 80
print(wait(3*24*60))
local zone = (patchM:grow(70):soften(30)) * floorM - patchM:grow(1)
local lipP = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.35},{"raw sienna",0.2}}
local b = brush{kind="round", width=1.1, point=0.7}
local z = 0.8
while z < ZF do
  if z > 1.8 and z < 4.2 then
    b:load(lipP, 0.6)
    b:stroke({P(-300, YF, z), P(XR, YF, z)}, {pressure={0.4, 0.4}, ramps={0.02, 0.02}, clip=zone})
  end
  z = z + 0.37
end
for _, X in ipairs({-60, 180, 400}) do
  b:load(lipP, 0.6)
  b:stroke({P(X, YF, 1.6), P(X, YF, 4.5)}, {pressure={0.5, 0.3}, ramps={0.02, 0.02}, clip=zone})
end
-- the amber deck dashes where the bounce reaches them
local m = nil
local zz = 0.7
while zz < 5.8 do
  if zz > 1.9 and zz < 4.0 then
    local d = flatq(YF, -415, -385, zz, zz + 0.18)
    m = m and (m + d) or d
  end
  zz = zz + 0.3
end
work(m, {hand="detail", pile=amberDim2, coverage=2.2, fill=false, angle=radial, load=0.6})
