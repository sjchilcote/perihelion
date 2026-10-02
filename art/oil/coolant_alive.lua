-- easel session "coolant_alive": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,14}, seed=4405, ground={{pile={{"lead white",2},{"bone black",1},{"ultramarine blue",0.4},{"burnt sienna",0.4}}, um=90, apply="knife", texture=0.25}}}
-- the same corridor, the same five planes: Coolant Row with the lights on
VX, VY = 560, 250
XL, XR, YC, YF = -620, 520, -330, 380
ZF = 6.25
function P(X, Y, z) return {VX + X / z, VY + Y / z} end
function wallq(X, Y1, Y2, z1, z2) return poly({P(X,Y1,z1), P(X,Y1,z2), P(X,Y2,z2), P(X,Y2,z1)}) end
function flatq(Y, X1, X2, z1, z2) return poly({P(X1,Y,z1), P(X2,Y,z1), P(X2,Y,z2), P(X1,Y,z2)}) end
function frontq(z, X1, X2, Y1, Y2) return poly({P(X1,Y1,z), P(X2,Y1,z), P(X2,Y2,z), P(X1,Y2,z)}) end
radial = function(x, y) return math.atan(y - VY, x - VX) end
ceilM  = flatq(YC, XL, XR, 0.6, ZF)
floorM = flatq(YF, XL, XR, 0.6, ZF)
leftM  = wallq(XL, YC, YF, 0.6, ZF)
rightM = wallq(XR, YC, YF, 0.6, ZF)
farM   = frontq(ZF, XL, XR, YC, YF)
local ceilP  = pile{{"lead white",1},{"bone black",0.8},{"ultramarine ash",0.8}}
local leftP  = pile{{"lead white",0.6},{"bone black",1},{"ultramarine ash",0.8}}
local floorP = pile{{"lead white",0.7},{"bone black",1},{"ultramarine ash",0.6},{"Mars brown",0.25}}
local bronzeP = pile{{"burnt sienna",1.2},{"yellow ochre",1},{"bone black",0.5},{"raw sienna",0.5}}
local farP = pile{{"lead white",0.8},{"bone black",0.9},{"ultramarine ash",0.8}}
work(ceilM, {hand="broad", pile=ceilP, coverage=2.6, fill=true, clip=true, angle=radial})
work(leftM, {hand="broad", pile=leftP, coverage=2.6, fill=true, clip=true, angle=math.pi/2})
work(floorM, {hand="broad", pile=floorP, coverage=2.6, fill=true, clip=true, angle=radial})
work(rightM, {hand="broad", pile=bronzeP, coverage=2.6, fill=true, clip=true, angle=math.pi/2})
work(farM, {hand="body", pile=farP, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 2
print(wait(24*60))
pgL = pile{{"lead white",1.3},{"bone black",0.6},{"ultramarine ash",0.6},{"yellow ochre",0.08}}
pgM = pile{{"lead white",0.9},{"bone black",0.8},{"ultramarine ash",0.6}}
pgD = pile{{"lead white",0.45},{"bone black",1.1},{"ultramarine ash",0.8}}
pgK = pile{{"lead white",0.15},{"bone black",1.4},{"ultramarine ash",0.8},{"burnt sienna",0.2}}
PX1, PX2, PYT = -620, -450, -140
pumps = {}
for i = 0, 13 do
  local z = 1.15 + i * 0.37
  if z + 0.27 > ZF - 0.05 then break end
  pumps[#pumps+1] = {z1 = z, z2 = z + 0.27}
end
pumpSide, pumpFront = {}, {}
local occ = nil
for i, p in ipairs(pumps) do
  pumpSide[i]  = wallq(PX2, PYT, YF, p.z1, p.z2)
  pumpFront[i] = frontq(p.z1, PX1, PX2, PYT, YF)
  local s, f = pumpSide[i], pumpFront[i]
  if occ then s = s - occ; f = f - occ end
  work(s, {hand="body", pile=(i < 6) and pgL or pgM, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  work(f - s, {hand="body", pile=pgD, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end
pumpsAll = occ
-- struts and cable rails bolted over the hull
strutZ = {1.35, 2.3, 3.25, 4.2, 5.15}
local sm, sf = nil, nil
for _, z in ipairs(strutZ) do
  local face = wallq(490, YC, YF, z, z + 0.06)
  local side = frontq(z, 490, XR, YC, YF)
  sm = sm and (sm + face) or face
  sf = sf and (sf + side) or side
end
local rails = wallq(495, -70, -40, 0.6, ZF) + wallq(495, 255, 275, 0.6, ZF)
strutsM = sm + sf + rails
work(rails - sm - sf, {hand="body", pile=pgM, coverage=3, fill=true, clip=true, angle=radial, length={20,60}})
work(sf, {hand="body", pile=pgD, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})
work(sm, {hand="body", pile=pgL, coverage=3, fill=true, clip=true, angle=math.pi/2, length={20,50}})

--@ chunk 3
print(wait(24*60))
-- the hull's scale plates, lit by the strip lights
local lipD = pile{{"bone black",1.5},{"burnt sienna",0.9},{"ultramarine blue",0.3}}
local lipL = pile{{"yellow ochre",2},{"lead white",1.0},{"raw sienna",0.5}}
local bD = brush{kind="round", width=3.0, point=0.5}
local bL = brush{kind="round", width=1.5, point=0.8}
local function scale_lip(Yc, zc, hw, dep)
  local ptsD, ptsL = {}, {}
  for k = 0, 8 do
    local t = -1 + k / 4
    local Y = Yc + dep * (1 - t * t)
    local z = zc + hw * t / 600
    ptsD[#ptsD+1] = P(XR, Y + 4, z)
    ptsL[#ptsL+1] = P(XR, Y - 3, z)
  end
  bD:stroke(ptsD, {pressure={0.7, 0.4}, ramps={0.15, 0.3}})
  bL:stroke(ptsL, {pressure={0.4, 0.05}, ramps={0.2, 0.5}})
end
local n, row = 0, 0
local Y = YC + 20
while Y < YF - 10 do
  local z = 0.75 + (row % 2) * 0.05 + rand(0, 0.03)
  while z < ZF - 0.05 do
    local hw = 30 + 14 * math.abs(math.sin(z * 7.3 + row * 2.39))
    if n % 6 == 0 then bD:load(lipD, 0.8); bL:load(lipL, 0.6) end
    scale_lip(Y + rand(-5,5), z, hw, 16 + rand(-3,4))
    n = n + 1
    z = z + (2 * hw + rand(6, 16)) / 600 * (0.9 + 0.1 * z)
  end
  row = row + 1
  Y = Y + 44 + rand(-4, 6)
end
-- struts back over the scales
work(strutsM, {hand="detail", pile=pgL, coverage=3, fill=true, clip=true, angle=math.pi/2})
print(n)

--@ chunk 4
-- the pump modules, all alike: louvres, a printed placard, a hazard band, a live amber lamp, frosted risers
local DK = pile{{"bone black",1.6},{"ultramarine ash",0.6}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
local BLK = pile{{"bone black",2},{"ultramarine blue",0.3}}
local PLW = pile{{"lead white",2},{"bone black",0.1},{"ultramarine ash",0.2}}
local RED = pile{{"vermilion",1},{"cadmium red",0.5}}
local LAMP = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",0.6}}
local LAMPH = pile{{"lead white",2},{"cadmium yellow",1}}
local PIPE = pile{{"lead white",0.8},{"bone black",0.8},{"ultramarine ash",0.8},{"cerulean blue",0.1}}
local FROST = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25}}
local occ = nil
for i, p in ipairs(pumps) do
  local vis = occ and (rect(0,0,1000,H) - occ) or rect(0,0,1000,H)
  local zi1, zi2 = p.z1 + 0.03, p.z2 - 0.03
  -- hazard band at the foot of the side face
  local nb = 8
  for s = 0, nb-1 do
    local za, zb = p.z1 + (p.z2-p.z1)*s/nb, p.z1 + (p.z2-p.z1)*(s+1)/nb
    local m = poly({P(PX2,300,za), P(PX2,300,zb), P(PX2,345,zb+0.012), P(PX2,345,za+0.012)}) * vis
    if m:area() > 0.3 then work(m, {hand="detail", pile=(s%2==0) and AMB or BLK, coverage=4, fill=true, clip=true}) end
  end
  -- louvres
  local lb = brush{kind="round", width=math.max(0.6, 7/p.z1), point=0.3}
  for Yl = 120, 250, 18 do
    lb:reload(DK, 0.8); lb:stroke({P(PX2, Yl, zi1), P(PX2, Yl, zi2)}, {pressure={0.6,0.6}, clip=vis})
  end
  -- printed placard with a red header bar
  local pl = wallq(PX2, -100, -20, zi1 + 0.02, zi1 + 0.13) * vis
  if pl:area() > 0.5 then
    work(pl, {hand="detail", pile=PLW, coverage=4, fill=true, clip=true})
    local hb = wallq(PX2, -100, -88, zi1 + 0.02, zi1 + 0.13) * vis
    work(hb, {hand="detail", pile=RED, coverage=4, fill=true, clip=true})
    for Yt = -78, -30, 10 do
      lb:reload(DK, 0.7); lb:stroke({P(PX2, Yt, zi1 + 0.035), P(PX2, Yt, zi1 + 0.1)}, {pressure={0.35,0.35}, clip=vis})
    end
  end
  -- a live amber status lamp
  local q = P(PX2, -118, zi2 - 0.03)
  if vis:at(q[1], q[2]) > 0.5 then
    local b = brush{kind="round", width=math.max(1.2, 14/p.z1), point=0.3}
    b:reload(LAMP, 0.9); b:touch(q[1], q[2], {pressure=0.6})
    local c = brush{kind="round", width=math.max(0.6, 6/p.z1), point=0.3}
    c:reload(LAMPH, 0.9); c:touch(q[1], q[2], {pressure=0.5})
  end
  -- coolant riser from pump top to the ceiling conduit, frosted near the pump
  local rb = brush{kind="round", width=math.max(1.5, 26/p.z1), point=0.1}
  local rz = p.z1 + 0.135
  rb:reload(PIPE, 0.9); rb:stroke({P(-500, -140, rz), P(-500, YC, rz)}, {pressure={0.8,0.8}, ramps={0.01,0.01}, clip=vis})
  local fz = brush{kind="round", width=math.max(1, 30/p.z1), point=0.2}
  for k = 1, 5 do
    local Yf = -150 - k*12 + rand(-4,4)
    local a = P(-500 + rand(-12,12), Yf, rz)
    fz:reload(FROST, 0.6); fz:touch(a[1], a[2], {pressure=rand(0.2,0.45)})
  end
  occ = occ and (occ + pumpSide[i] + pumpFront[i]) or (pumpSide[i] + pumpFront[i])
end

--@ chunk 5
print(wait(24*60))
local function fill(m, p, hand) work(m, {hand=hand or "detail", pile=p, coverage=4, fill=true, clip=true, angle=0}) end
local SW = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.08}}
local SUNW = pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.35}}
local SUNG = pile{{"lead white",3},{"cadmium yellow",0.5},{"yellow ochre",0.3},{"zinc white",1}}
local FR = pile{{"lead white",0.3},{"bone black",1.3},{"ultramarine ash",0.8}}
-- strip lights along the ceiling, the ones that are dead in the other picture, all burning cool white
for _, z in ipairs({1.18, 1.92, 3.03, 3.77, 4.51, 5.25}) do
  local f = flatq(YC + 2, -60, 120, z, z + 0.16)
  local core = flatq(YC + 2, -45, 105, z + 0.02, z + 0.14)
  fill(f, FR)
  fill(core, SW)
end
-- the viewport: two panes of Sun
VPX1, VPX2, VPZ1, VPZ2 = -170, 230, 2.2, 2.75
viewM = flatq(YC, VPX1, VPX2, VPZ1, VPZ2)
local mull = flatq(YC, 15, 45, VPZ1, VPZ2)
local frameM = viewM - flatq(YC, VPX1 + 18, VPX2 - 18, VPZ1 + 0.03, VPZ2 - 0.03)
fill(viewM - mull - frameM, SUNW, "body")
fill(mull + frameM, FR)
-- and on the deck below it, as always, three panes of light
PZ1, PZ2, PXA, PXB = 2.55, 3.1, 80, 480
patchM = flatq(YF, PXA, PXB, PZ1, PZ2)
local pm1 = flatq(YF, 206, 222, PZ1, PZ2)
local pm2 = flatq(YF, 338, 354, PZ1, PZ2)
local pfr = patchM - flatq(YF, PXA + 18, PXB - 18, PZ1 + 0.025, PZ2 - 0.025)
fill(patchM - pm1 - pm2 - pfr, SUNG, "body")
-- deck plate seams and the amber walkway dashes along the pumps
local SEAM = pile{{"bone black",1.5},{"ultramarine ash",0.5}}
local sb = brush{kind="round", width=1.2, point=0.3}
for _, X in ipairs({-300, -60, 180, 400}) do sb:reload(SEAM, 0.8); sb:stroke({P(X, YF, 0.7), P(X, YF, ZF)}, {pressure={0.45,0.3}, clip=floorM - patchM}) end
for _, z in ipairs({0.9, 1.3, 1.8, 2.4, 3.3, 4.2, 5.2}) do sb:reload(SEAM, 0.8); sb:stroke({P(XL, YF, z), P(XR, YF, z)}, {pressure={0.4,0.4}, clip=floorM - patchM}) end
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
for z = 0.8, ZF - 0.3, 0.32 do fill(flatq(YF, -420, -380, z, z + 0.14), AMB) end
-- the far hatch: closed, clean, lit, with its hazard frame
local hx1, hx2, hy1, hy2 = -105, 105, -140, YF
local hatch = frontq(ZF, hx1, hx2, hy1, hy2)
local frameH = frontq(ZF, hx1 - 30, hx2 + 30, hy1 - 30, hy2) - hatch
fill(hatch, pile{{"lead white",0.9},{"bone black",0.8},{"ultramarine ash",0.7}})
fill(frameH, AMB)
fill(frontq(ZF, -3, 3, hy1, hy2), SEAM)
fill(frontq(ZF, -60, 60, -120, -80), pile{{"zinc white",2},{"cerulean blue",0.3}})
-- the hull panel, near right, with a clean printed placard
local pz1, pz2 = 1.55, 2.12
local p2 = wallq(503, -200, 120, pz1, pz2)
fill(p2, pile{{"lead white",0.9},{"bone black",0.8},{"ultramarine ash",0.7}}, "body")
fill(frontq(pz2, 503, XR, -200, 120), pile{{"lead white",0.3},{"bone black",1.2},{"ultramarine ash",0.8}})
local plac = wallq(502, -160, -60, pz1 + 0.12, pz1 + 0.38)
fill(plac, pile{{"lead white",2},{"bone black",0.1}})
fill(wallq(502, -160, -144, pz1 + 0.12, pz1 + 0.38), pile{{"vermilion",1},{"cadmium red",0.5}})
for Yt = -132, -70, 12 do sb:reload(SEAM, 0.8); sb:stroke({P(502, Yt, pz1 + 0.15), P(502, Yt, pz1 + 0.33)}, {pressure={0.5,0.5}}) end
-- foreground: the cargo case, with a crew-member's tool case and a mug left on it
local cX1, cX2, cY, cz1, cz2 = 240, 470, 230, 1.0, 1.32
crTop   = flatq(cY, cX1, cX2, cz1, cz2)
crSide  = wallq(cX1, cY, YF, cz1, cz2)
crFront = frontq(cz1, cX1, cX2, cY, YF)
fill(crFront, pile{{"lead white",0.5},{"bone black",1.0},{"ultramarine ash",0.8}}, "body")
fill(crSide - crFront, pile{{"lead white",0.7},{"bone black",0.9},{"ultramarine ash",0.8}}, "body")
fill(crTop - crFront - crSide, pile{{"lead white",1.1},{"bone black",0.7},{"ultramarine ash",0.7}}, "body")
fill(frontq(cz1, cX1, cX2, 270, 290), AMB)

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, hand) work(m, {hand=hand or "detail", pile=p, coverage=4, fill=true, clip=true, angle=0}) end
-- value structure: the corners of the room fall darker away from the lamps
local SHADE = pile{{"bone black",1.3},{"ultramarine ash",0.8},{"lead white",0.2},{"burnt sienna",0.1}}
local cc = (ceilM - flatq(YC, -260, 330, 0.6, ZF)) - flatq(YC, VPX1-20, VPX2+20, VPZ1-0.05, VPZ2+0.05)
work(cc, {hand="scumble", tool={kind="filbert", width=8}, pile=SHADE, coverage=1.4, load=0.45, clip=cc, angle=radial})
local lowL = leftM * below(function(x) return 470 end) - pumpsAll
work(lowL, {hand="scumble", tool={kind="filbert", width=8}, pile=SHADE, coverage=1.2, load=0.4, clip=lowL, angle=math.pi/2})
local fnear = floorM * below(function(x) return 480 end) - crFront - crSide - crTop
work(fnear, {hand="scumble", tool={kind="filbert", width=9}, pile=SHADE, coverage=1.0, load=0.35, clip=fnear, angle=radial})
-- pale pools of strip light on the deck under each fixture
local POOL = pile{{"lead white",2},{"zinc white",0.5},{"ultramarine ash",0.3},{"bone black",0.15}}
for _, z in ipairs({1.92, 3.77, 4.51}) do
  local c = P(30, YF, z + 0.08)
  local m = ellipse(c[1], c[2], 120/z, 26/z) * floorM - patchM:grow(1)
  work(m, {hand="scumble", tool={kind="filbert", width=4}, pile=POOL, coverage=1.0, load=0.3, pressure={0.12,0.3}, clip=m, angle=0})
end
-- frost thick on the coolant lines where they leave the pumps, and on the pump tops
local FROST = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.3}}
local FROSTD = pile{{"lead white",1},{"cerulean blue",0.3},{"ultramarine ash",0.4}}
for i, p in ipairs(pumps) do
  if i <= 7 then
    local rz = p.z1 + 0.135
    local pipe = wallq(-500 + 13, -230, -140, rz - 0.02, rz + 0.02) + frontq(rz, -513, -487, -230, -140)
    stipple(pipe, {pile=FROSTD, width=math.max(0.8, 6/p.z1), coverage=1.8, pressure={0.2,0.45}})
    stipple(pipe, {pile=FROST, width=math.max(0.6, 4/p.z1), coverage=1.0, pressure={0.2,0.5}, cluster={0.5, 6/p.z1}})
    local top = flatq(PYT, PX1, PX2, p.z1, p.z2)
    stipple(top, {pile=FROST, width=math.max(0.6, 4/p.z1), coverage=0.8, pressure={0.15,0.4}})
  end
end
-- a crew-member's tool case and a mug left on the cargo case
local TC = pile{{"cadmium red",1},{"Mars red",0.6},{"bone black",0.3}}
local TCD = pile{{"Mars red",1},{"bone black",0.8}}
local tcTop = flatq(160, 290, 400, 1.06, 1.2)
local tcFront = frontq(1.06, 290, 400, 160, 230)
local tcSide = wallq(290, 160, 230, 1.06, 1.2)
fill(tcFront, TC, "body"); fill(tcSide - tcFront, TCD); fill(tcTop - tcFront - tcSide, pile{{"cadmium red",1},{"lead white",0.3}})
local hb = brush{kind="round", width=2.2, point=0.2}
hb:reload(pile{{"bone black",2}}, 0.9)
hb:stroke({P(320, 160, 1.06), P(325, 140, 1.06), P(365, 140, 1.06), P(370, 160, 1.06)}, {pressure={0.7,0.7}})
local lt = P(390, 190, 1.06)
local lb = brush{kind="round", width=3, point=0.3}
lb:reload(pile{{"chrome yellow",1},{"lead white",0.3}}, 0.8); lb:touch(lt[1], lt[2], {pressure=0.5})
-- the mug
local MUG = pile{{"lead white",2},{"cerulean blue",0.3},{"bone black",0.1}}
local mc = P(440, 200, 1.12)
local mug = rect(mc[1] - 9, mc[2] - 20, 18, 26)
fill(mug, MUG)
fill(rect(mc[1] + 3, mc[2] - 20, 6, 26), pile{{"lead white",1},{"cerulean blue",0.3},{"bone black",0.4}})
fill(ellipse(mc[1], mc[2] - 20, 9, 2.6), pile{{"bone brown",1},{"bone black",0.5}})
local mh = brush{kind="round", width=2.4, point=0.2}
mh:reload(MUG, 0.9); mh:stroke({{mc[1] + 9, mc[2] - 14}, {mc[1] + 16, mc[2] - 10}, {mc[1] + 15, mc[2] - 1}, {mc[1] + 9, mc[2] + 1}}, {pressure={0.6,0.6}})
-- steam, faint
local st = brush{kind="rigger", width=1.0, point=1}
st:reload(pile{{"lead white",2},{"zinc white",1}}, 0.3)
st:stroke({{mc[1] - 2, mc[2] - 24}, {mc[1] + 3, mc[2] - 34}, {mc[1] - 1, mc[2] - 44}}, {pressure={0.12,0.0}})

--@ chunk 7
print(wait(2*24*60))
-- the broken scumbles become solid, graded planes
local CEILD = pile{{"lead white",0.55},{"bone black",1},{"ultramarine ash",0.8}}
local cc = (ceilM - flatq(YC, -260, 330, 0.6, ZF)) - flatq(YC, VPX1-20, VPX2+20, VPZ1-0.05, VPZ2+0.05)
work(cc, {hand="body", tool={kind="filbert", width=7}, pile=CEILD, coverage=3.6, fill=true, clip=cc, angle=radial, length={20,60}})
local seamC = (flatq(YC, -300, -220, 0.6, ZF) + flatq(YC, 290, 370, 0.6, ZF)) - flatq(YC, VPX1-20, VPX2+20, VPZ1-0.05, VPZ2+0.05)
blend(seamC * ceilM, {angle=radial, tool={kind="badger", width=10}})
local FLD = pile{{"lead white",0.45},{"bone black",1},{"ultramarine ash",0.6},{"Mars brown",0.25}}
local FLM = pile{{"lead white",0.7},{"bone black",1},{"ultramarine ash",0.6},{"Mars brown",0.25}}
local fnear = floorM * below(function(x) return 470 end) - crFront - crSide - crTop
work(fnear, {hand="body", tool={kind="filbert", width=8}, pile=FLD, coverage=3.6, fill=true, clip=fnear, angle=radial, length={20,60}})
blend(floorM * rect(0, 455, 1000, 30) - crFront - crSide - crTop, {angle=0, tool={kind="badger", width=10}})
for _, z in ipairs({1.92, 3.77, 4.51}) do
  local c = P(30, YF, z + 0.08)
  local m = ellipse(c[1], c[2], 128/z, 30/z) * floorM - patchM:grow(1)
  work(m, {hand="body", tool={kind="filbert", width=3}, pile=FLM, coverage=4, fill=true, clip=m, angle=0})
end
local lowL = leftM * below(function(x) return 470 end) - pumpsAll
work(lowL, {hand="body", tool={kind="filbert", width=6}, pile=pile{{"lead white",0.35},{"bone black",1},{"ultramarine ash",0.8}}, coverage=3.6, fill=true, clip=lowL, angle=math.pi/2})

--@ chunk 8
print(wait(2*24*60))
local function fill(m, p) work(m, {hand="detail", pile=p, coverage=4, fill=true, clip=true, angle=0}) end
local SEAM = pile{{"bone black",1.5},{"ultramarine ash",0.5}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
local nearF = floorM * below(function(x) return 455 end) - crFront - crSide - crTop
local sb = brush{kind="round", width=1.6, point=0.3}
for _, X in ipairs({-300, -60, 180}) do sb:reload(SEAM, 0.8); sb:stroke({P(X, YF, 0.62), P(X, YF, 1.3)}, {pressure={0.5,0.4}, clip=nearF}) end
for _, z in ipairs({0.9, 1.3}) do sb:reload(SEAM, 0.8); sb:stroke({P(XL, YF, z), P(XR, YF, z)}, {pressure={0.5,0.5}, clip=nearF}) end
for z = 0.64, 1.3, 0.32 do fill(flatq(YF, -420, -380, z, z + 0.14) * nearF, AMB) end
-- the Sun itself in the viewport: a whiter core in the left pane
local c = P(-70, YC, 2.45)
work(ellipse(c[1], c[2] - 2, 22, 7) * viewM, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.1}}, coverage=4, fill=true, clip=true})
-- amber status lamps glow on their module faces
local GL = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.5},medium=0.5}
for i, p in ipairs(pumps) do
  if i <= 8 then
    local q = P(PX2, -118, p.z2 - 0.06)
    local r = 22 / p.z1
    local m = ellipse(q[1], q[2], r, r * 1.2) * pumpSide[i]
    work(m, {hand="scumble", tool={kind="filbert", width=math.max(1.5, r*0.4)}, pile=GL, coverage=0.8, load=0.2, pressure={0.1,0.25}, clip=m})
    local b = brush{kind="round", width=math.max(1, 7/p.z1), point=0.3}
    b:reload(pile{{"lead white",2},{"cadmium yellow",1}}, 0.9); b:touch(q[1], q[2], {pressure=0.6})
  end
end
