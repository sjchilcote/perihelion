-- easel session "dock_alive": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=22,
  ground={{pile={{"lead white",1},{"bone black",0.6},{"ultramarine blue",0.2},{"bone brown",0.2}}, um=120, apply="knife", texture=0.25}}}
-- Dock 4's own geometry, unchanged: the ring rises, and past the near frame it bends left
CXV, Y0, FOC, EYE, RR = 470, 250, 420, 1.6, 30
WL, WR, CH = -2.1, 2.1, 2.9
function rise(z) return z*z/(2*RR) end
function P(X, Y, z) return {CXV + FOC*X/z, Y0 - FOC*(Y + rise(z) - EYE)/z} end
function off(z) return (z > 4.72) and ((z-4.72)^2/18) or 0 end
function rz(z) return rise(math.min(z, 4.72)) + 0.015*math.max(0, z-4.72) end
function PB(X, Y, z) return {CXV + FOC*(X - off(z))/z, Y0 - FOC*(Y + rz(z) - EYE)/z} end
BOX = rect(0,0,1000,H)
WIN = poly({P(WL,0,4.72), P(WL,CH,4.72), P(WR,CH,4.72), P(WR,0,4.72)}) * BOX
FLOOR = pile{{"lead white",0.7},{"bone black",1},{"bone brown",0.45},{"ultramarine ash",0.3}}
WALLO = pile{{"lead white",1.1},{"bone black",0.8},{"ultramarine ash",0.8}}
WALLI = pile{{"lead white",0.9},{"bone black",0.9},{"ultramarine ash",0.8}}
CEIL = pile{{"lead white",0.75},{"bone black",1},{"ultramarine ash",0.7}}
local function q(a,b,c,d) return poly({a,b,c,d}) end
local function paint(m, p, w) m = m * BOX if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=w}, pile=p, coverage=3.2, fill=true, clip=m, length={15,60}}) end end
local ZS = {1.0, 1.35, 1.8, 2.4, 3.1, 4.0, 4.72}
for i = #ZS-1, 1, -1 do
  local z1, z2 = ZS[i], ZS[i+1]
  local w = (z1 < 2.4) and 12 or 6
  paint(q(P(WL,0,z1), P(WR,0,z1), P(WR,0,z2), P(WL,0,z2)) - WIN, FLOOR, w)
  paint(q(P(WL,0,z1), P(WL,CH,z1), P(WL,CH,z2), P(WL,0,z2)) - WIN, WALLI, w)
  paint(q(P(WR,0,z1), P(WR,CH,z1), P(WR,CH,z2), P(WR,0,z2)) - WIN, WALLO, w)
  paint(q(P(WL,CH,z1), P(WR,CH,z1), P(WR,CH,z2), P(WL,CH,z2)) - WIN, CEIL, w)
end
-- through the frame: the bend
local function strip(fn, z0, z1, dz)
  local m, z = nil, z0
  while z < z1 do local zb = math.min(z + dz, z1); local s = fn(z, zb); m = m and (m + s) or s; z = zb end
  return m * WIN
end
local DARK = pile{{"bone black",1.2},{"ultramarine ash",0.6},{"lead white",0.25}}
paint(WIN, DARK, 5)
paint(strip(function(a,b) return q(PB(WL,0,a), PB(WR,0,a), PB(WR,0,b), PB(WL,0,b)) end, 4.72, 17, 0.6), FLOOR, 3)
paint(strip(function(a,b) return q(PB(WL,CH,a), PB(WR,CH,a), PB(WR,CH,b), PB(WL,CH,b)) end, 4.72, 17, 0.6), CEIL, 3)
paint(strip(function(a,b) return q(PB(WR,0,a), PB(WR,CH,a), PB(WR,CH,b), PB(WR,0,b)) end, 4.72, 17, 0.5), WALLO, 3)
INNER = strip(function(a,b) return q(PB(WL,0,a), PB(WL,CH,a), PB(WL,CH,b), PB(WL,0,b)) end, 4.72, 13, 0.4)
paint(INNER, WALLI, 3)

--@ chunk 2
print(wait(24*60))
local function q(a,b,c,d) return poly({a,b,c,d}) end
local function paint(m, p, w) m = m * BOX if m:area() > 0.3 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=3.8, fill=true, clip=m}) end end
RIB = pile{{"lead white",0.8},{"bone black",0.9},{"ultramarine blue",0.3}}
RIBD = pile{{"lead white",0.3},{"bone black",1.2},{"ultramarine blue",0.25}}
DOOR = pile{{"lead white",1.3},{"bone black",0.6},{"ultramarine ash",0.8}}
AMBD = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
BLK = pile{{"bone black",2},{"ultramarine blue",0.3}}
RACK = pile{{"lead white",0.4},{"bone black",1},{"bone brown",0.3}}
local POD = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.4},{"cerulean blue",0.15}}
local function doorset(proj, zr, clipm, w)
  local a, b = zr + 0.45, zr + 2.55
  paint(q(proj(WR,0.12,a), proj(WR,2.2,a), proj(WR,2.2,b), proj(WR,0.12,b)) * clipm, DOOR, w)
  for s=0,9 do
    local z1, z2 = a + (b-a)*s/10, a + (b-a)*(s+1)/10
    paint(q(proj(WR,2.22,z1), proj(WR,2.42,z1+0.08), proj(WR,2.42,z2+0.08), proj(WR,2.22,z2)) * clipm, (s%2==0) and AMBD or BLK, math.max(1.2, w*0.5))
  end
end
-- far, around the bend
for _,zr in ipairs({13.5, 10.5, 7.5, 4.5}) do
  doorset(PB, zr, WIN, 2)
  for _,yy in ipairs({0.25, 1.0, 1.75, 2.5}) do
    paint(q(PB(WL,yy,zr+0.25), PB(WL,yy+0.08,zr+0.25), PB(WL,yy+0.08,zr+2.75), PB(WL,yy,zr+2.75)) * INNER, RACK, 1.2)
  end
  for _,yy in ipairs({0.25, 1.0, 1.75}) do
    for k=0,2 do
      if (zr*3 + k + yy*4) % 5 ~= 1 then
        local p1 = zr + 0.35 + k*0.82
        paint(q(PB(WL,yy+0.09,p1), PB(WL,yy+0.6,p1), PB(WL,yy+0.6,p1+0.66), PB(WL,yy+0.09,p1+0.66)) * INNER, POD, 1.2)
      end
    end
  end
end
for _,zr in ipairs({13.5, 10.5, 7.5}) do
  local z1, z2 = zr - 0.22, zr + 0.22
  paint(q(PB(WR,0,z1), PB(WR,CH,z1), PB(WR,CH,z2), PB(WR,0,z2)) * WIN, RIB, 1.5)
  paint(q(PB(WL,CH,z1), PB(WR,CH,z1), PB(WR,CH,z2), PB(WL,CH,z2)) * WIN, RIB, 1.5)
  paint(q(PB(WL,0,z1), PB(WR,0,z1), PB(WR,0,z2), PB(WL,0,z2)) * WIN, RIBD, 1.5)
  paint(q(PB(WL,0,z1), PB(WL,CH,z1), PB(WL,CH,z2), PB(WL,0,z2)) * INNER, RIB, 1.5)
end
-- near: bay 7's door, and the two near ribs framing the view
doorset(P, 1.5, BOX - WIN, 5)
for _,zr in ipairs({4.5, 1.5}) do
  local z1, z2 = zr - 0.22, zr + 0.22
  local w = (zr < 3) and 6 or 4
  paint(q(P(WL,0,z1), P(WL,CH,z1), P(WL,CH,z2), P(WL,0,z2)), RIB, w)
  paint(q(P(WR,0,z1), P(WR,CH,z1), P(WR,CH,z2), P(WR,0,z2)), RIB, w)
  paint(q(P(WL,CH,z1), P(WR,CH,z1), P(WR,CH,z2), P(WL,CH,z2)), RIB, w)
  paint(q(P(WL,0,z1), P(WR,0,z1), P(WR,0,z2), P(WL,0,z2)), RIBD, w)
end

--@ chunk 3
print(wait(2*24*60))
local function fill(m, p, w) m = m * BOX if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4, fill=true, clip=m}) end end
SD = {
  ["7"] = {{0,0.8,1,1}, {"p", {0.76,0.78},{1,0.78},{0.47,0},{0.24,0}}},
  ["8"] = {{0.1,0.82,0.45,1},{0.55,0.82,0.9,1},{0.05,0.47,0.45,0.57},{0.55,0.47,0.95,0.57},{0,0,0.45,0.17},{0.55,0,1,0.17},{0.1,0.57,0.27,0.82},{0.73,0.57,0.9,0.82},{0,0.17,0.19,0.47},{0.81,0.17,1,0.47}},
  ["9"] = {{0.05,0.82,0.45,1},{0.55,0.82,0.95,1},{0.05,0.5,0.23,0.82},{0.05,0.42,0.45,0.52},{0.55,0.42,0.77,0.52},{0.77,0,0.95,0.82}},
  ["1"] = {{0.42,0,0.62,1},{"p",{0.18,0.74},{0.42,0.96},{0.42,0.8},{0.24,0.64}},{0.18,0,0.86,0.15}},
}
function stencil(d, proj, za, zb, ya, yb, p)
  local function M(u, v) return proj(WR, ya + (yb-ya)*v, zb - (zb-za)*u) end
  for _,r in ipairs(SD[d]) do
    local m
    if r[1] == "p" then m = poly({M(r[2][1],r[2][2]), M(r[3][1],r[3][2]), M(r[4][1],r[4][2]), M(r[5][1],r[5][2])})
    else m = poly({M(r[1],r[2]), M(r[3],r[2]), M(r[3],r[4]), M(r[1],r[4])}) end
    fill(m, p, 1)
  end
end
local AMS = pile{{"chrome yellow",1},{"Mars orange",0.3},{"bone black",0.12}}
stencil("7", P, 2.4, 3.6, 0.75, 1.95, AMS)
stencil("8", PB, 5.45, 6.55, 0.75, 1.95, AMS)
stencil("9", PB, 8.45, 9.55, 0.75, 1.95, AMS)
stencil("1", PB, 11.4, 12.6, 0.7, 1.95, AMS)
-- the docking collar: heavy flange, striped ring, a ring of green status lights, the hatch shut and sound
local cz, cy = 3.0, 1.25
local function circ(r, n) local t = {} for k=0,n do local a = 2*math.pi*k/n; t[#t+1] = P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end return t end
local function pt(r, a) return P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end
fill(poly(circ(1.3, 48), true) - poly(circ(1.12, 48), true), pile{{"lead white",0.8},{"bone black",0.9},{"ultramarine ash",0.6}}, 3)
for s=0,15 do
  local a1, a2 = 2*math.pi*s/16, 2*math.pi*(s+1)/16
  fill(poly({pt(0.9,a1), pt(1.12,a1+0.1), pt(1.12,a2+0.1), pt(0.9,a2)}), (s%2==0) and AMBD or BLK, 3)
end
fill(poly(circ(0.9, 40), true), pile{{"lead white",1},{"bone black",0.7},{"ultramarine ash",0.8}}, 5)
fill(poly(circ(0.22, 20), true), pile{{"lead white",0.4},{"bone black",1.2},{"ultramarine ash",0.5}}, 3)
local bb = brush{kind="round", width=2.2, point=0.4}
for k=0,7 do
  local a = 2*math.pi*k/8 + 0.2
  bb:reload(pile{{"lead white",0.4},{"bone black",1.1},{"ultramarine ash",0.4}}, 0.7)
  bb:stroke({pt(0.25,a), pt(0.8,a)}, {pressure={0.4,0.4}})
end
local GR = pile{{"emerald green",1},{"zinc white",0.6},{"lemon chrome",0.2}}
local GH = pile{{"zinc white",2},{"emerald green",0.3}}
local gb = brush{kind="round", width=6, point=0.3}
local hb = brush{kind="round", width=2.5, point=0.3}
for k=0,11 do
  local p = pt(1.21, 2*math.pi*k/12 + 0.13)
  gb:reload(GR, 0.9); gb:touch(p[1], p[2], {pressure=0.55})
  hb:reload(GH, 0.9); hb:touch(p[1], p[2], {pressure=0.5})
end

--@ chunk 4
print(wait(2*24*60))
local function fill(m, p, w) m = m * BOX if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
local function q(a,b,c,d) return poly({a,b,c,d}) end
local DK = pile{{"bone black",1.6},{"ultramarine ash",0.5}}
-- collar: status lamps as green lenses in dark sockets round the flange
local cz, cy = 3.0, 1.25
local function pt(r, a) return P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end
local GR = pile{{"emerald green",1},{"zinc white",0.5},{"lemon chrome",0.25}}
local GH = pile{{"zinc white",2},{"emerald green",0.4},{"lemon chrome",0.2}}
for k=0,11 do
  local a = 2*math.pi*k/12 + 0.13
  local p = pt(1.21, a)
  local s = 300/ (cz + 1.21*math.cos(a))
  local r = math.max(2.5, s*0.03)
  fill(ellipse(p[1], p[2], r*0.75, r), DK, 1)
  fill(ellipse(p[1], p[2], r*0.55, r*0.75), GR, 1)
  fill(ellipse(p[1]-r*0.1, p[2]-r*0.15, r*0.25, r*0.3), GH, 1)
end
-- dark outer edge of the flange
local eb = brush{kind="round", width=2, point=0.3}
local pts = {}
for k=0,48 do pts[#pts+1] = pt(1.3, 2*math.pi*k/48) end
eb:reload(DK, 0.8); eb:stroke(pts, {pressure={0.6,0.6}})
-- white work lights on the ceiling of each section
local SW = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.05}}
local FR = pile{{"lead white",0.3},{"bone black",1.2},{"ultramarine ash",0.6}}
for _,z in ipairs({2.2, 3.4}) do
  fill(q(P(-0.9,CH,z), P(0.9,CH,z), P(0.9,CH,z+0.4), P(-0.9,CH,z+0.4)), FR, 3)
  fill(q(P(-0.8,CH,z+0.05), P(0.8,CH,z+0.05), P(0.8,CH,z+0.35), P(-0.8,CH,z+0.35)), SW, 3)
end
for _,z in ipairs({6.0, 9.0, 12.0}) do
  fill(q(PB(-0.9,CH,z), PB(0.9,CH,z), PB(0.9,CH,z+0.4), PB(-0.9,CH,z+0.4)) * WIN, FR, 1.5)
  fill(q(PB(-0.8,CH,z+0.05), PB(0.8,CH,z+0.05), PB(0.8,CH,z+0.35), PB(-0.8,CH,z+0.35)) * WIN, SW, 1.5)
end
-- deck plate seams and a yellow walkway line
local SEAM = pile{{"bone black",1.5},{"bone brown",0.4}}
local sb = brush{kind="round", width=1.4, point=0.3}
local fl = q(P(WL,0,1.0), P(WR,0,1.0), P(WR,0,4.28), P(WL,0,4.28)) * BOX
for _,X in ipairs({-1.4, -0.7, 0, 0.7, 1.4}) do sb:reload(SEAM, 0.8); sb:stroke({P(X,0,1.02), P(X,0,2.2), P(X,0,4.25)}, {pressure={0.5,0.3}, clip=fl}) end
for _,zz in ipairs({1.5, 2.15, 2.95, 3.75}) do sb:reload(SEAM, 0.8); sb:stroke({P(WL,0,zz), P(0,0,zz), P(WR,0,zz)}, {pressure={0.45,0.45}, clip=fl}) end
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.5},{"bone black",0.05}}
fill(q(P(1.55,0,1.0), P(1.65,0,1.0), P(1.65,0,4.28), P(1.55,0,4.28)), AMB, 2)

--@ chunk 5
print(wait(2*24*60))
local function fill(m, p, w) m = m * BOX if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
local function q(a,b,c,d) return poly({a,b,c,d}) end
local DK = pile{{"bone black",1.6},{"ultramarine ash",0.5}}
-- bigger green status lenses on the collar
local cz, cy = 3.0, 1.25
local function pt(r, a) return P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end
local GR = pile{{"emerald green",1},{"zinc white",0.4},{"lemon chrome",0.3}}
local GH = pile{{"zinc white",2},{"emerald green",0.4},{"lemon chrome",0.2}}
for k=0,11 do
  local a = 2*math.pi*k/12 + 0.13
  local p = pt(1.21, a)
  local r = 420 / (cz + 1.21*math.cos(a)) * 0.05
  fill(ellipse(p[1], p[2], r*0.6, r), DK, 1)
  fill(ellipse(p[1], p[2], r*0.45, r*0.78), GR, 1)
  fill(ellipse(p[1]-r*0.08, p[2]-r*0.2, r*0.18, r*0.3), GH, 1)
end
-- the half-unloaded pallet: deck boards, a MIRIAD crate still strapped on, two cases set down beside it
local PAL = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.6}}
local PALD = pile{{"burnt sienna",1},{"bone black",0.6}}
local X1, X2, Z1, Z2 = -1.75, -0.35, 2.3, 3.1
fill(q(P(X1,0.12,Z1), P(X2,0.12,Z1), P(X2,0.12,Z2), P(X1,0.12,Z2)), PAL, 3)
fill(q(P(X1,0,Z1), P(X2,0,Z1), P(X2,0.12,Z1), P(X1,0.12,Z1)), PALD, 2)
for _,u in ipairs({0.08, 0.5, 0.92}) do local X = X1 + (X2-X1)*u; fill(q(P(X-0.06,0,Z1), P(X+0.06,0,Z1), P(X+0.06,0.1,Z1), P(X-0.06,0.1,Z1)), PAL, 1.5) end
local CR = pile{{"lead white",1.6},{"bone black",0.3},{"ultramarine ash",0.5}}
local CRS = pile{{"lead white",0.8},{"bone black",0.7},{"ultramarine ash",0.6}}
local CRT = pile{{"lead white",2},{"ultramarine ash",0.3}}
local cx1, cx2, cz1, cz2, ch = -1.6, -0.75, 2.4, 3.0, 0.95
fill(q(P(cx2,0.12,cz1), P(cx2,0.12,cz2), P(cx2,ch,cz2), P(cx2,ch,cz1)), CRS, 3)
fill(q(P(cx1,ch,cz1), P(cx2,ch,cz1), P(cx2,ch,cz2), P(cx1,ch,cz2)), CRT, 3)
fill(q(P(cx1,0.12,cz1), P(cx2,0.12,cz1), P(cx2,ch,cz1), P(cx1,ch,cz1)), CR, 3)
-- MIRIAD logo on the crate's face: a blue ring cut by a bar, and the name in block
local BLU = pile{{"cobalt blue",1},{"ultramarine blue",0.4},{"lead white",0.3}}
local c = P((cx1+cx2)/2, 0.62, cz1)
local s = 420/cz1
local ring = ellipse(c[1], c[2], 0.2*s, 0.2*s) - ellipse(c[1], c[2], 0.13*s, 0.13*s)
fill(ring, BLU, 1.2)
fill(rect(c[1]-0.26*s, c[2]-0.025*s, 0.52*s, 0.05*s), BLU, 1)
local tb = brush{kind="round", width=2.2, point=0.2}
for i=0,5 do
  local x = c[1] - 0.3*s + i*0.12*s
  tb:reload(BLU, 0.8); tb:stroke({{x, c[2]+0.3*s}, {x, c[2]+0.38*s}}, {pressure={0.6,0.6}})
end
local strap = pile{{"chrome yellow",2},{"bone black",0.2}}
fill(q(P(cx1,0.12,cz1), P(cx1+0.06,0.12,cz1), P(cx1+0.06,ch,cz1), P(cx1,ch,cz1)), strap, 1)
fill(q(P(cx2-0.06,0.12,cz1), P(cx2,0.12,cz1), P(cx2,ch,cz1), P(cx2-0.06,ch,cz1)), strap, 1)
-- two cases already set down on the deck
local CASE = pile{{"Mars orange",1},{"chrome yellow",0.5},{"bone black",0.2}}
local CASED = pile{{"Mars orange",1},{"bone black",0.7}}
for _,b in ipairs({{-0.25, 0.25, 2.0, 2.3, 0.35}, {-0.1, 0.35, 1.75, 2.0, 0.28}}) do
  fill(q(P(b[2],0,b[3]), P(b[2],0,b[4]), P(b[2],b[5],b[4]), P(b[2],b[5],b[3])), CASED, 2)
  fill(q(P(b[1],b[5],b[3]), P(b[2],b[5],b[3]), P(b[2],b[5],b[4]), P(b[1],b[5],b[4])), CASE, 2)
  fill(q(P(b[1],0,b[3]), P(b[2],0,b[3]), P(b[2],b[5],b[3]), P(b[1],b[5],b[3])), CASE, 2)
end
-- a handrail along the near right wall, a crew jacket thrown over it
local RAIL = pile{{"lead white",0.6},{"bone black",1},{"ultramarine ash",0.5}}
local rb = brush{kind="round", width=5, point=0.2}
rb:reload(RAIL, 0.9); rb:stroke({P(WR-0.12,1.0,1.0), P(WR-0.12,1.0,2.0), P(WR-0.12,1.0,4.25)}, {pressure={0.7,0.6}})
local JK = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
local JKL = pile{{"ultramarine blue",1},{"lead white",0.8},{"cerulean blue",0.2}}
local J = q(P(WR-0.14,1.05,2.3), P(WR-0.14,1.05,3.1), P(WR-0.12,0.35,3.25), P(WR-0.12,0.3,2.25))
fill(J, JK, 3)
fill(q(P(WR-0.15,1.05,2.3), P(WR-0.15,1.05,3.1), P(WR-0.14,0.9,3.12), P(WR-0.14,0.9,2.28)), JKL, 2)
fill(q(P(WR-0.13,0.75,2.55), P(WR-0.13,0.75,2.7), P(WR-0.12,0.3,2.72), P(WR-0.12,0.3,2.56)), pile{{"chrome yellow",1},{"lead white",0.5}}, 1.5)
-- a clipboard on a hook on the near frame
local CB = pile{{"burnt sienna",1},{"yellow ochre",0.6}}
local PAP = pile{{"zinc white",2},{"lead white",1}}
local h1 = P(WR-0.1, 1.85, 4.28)
local w, hgt = 0.32*420/4.28, 0.45*420/4.28
fill(rect(h1[1]-w/2, h1[2], w, hgt), CB, 1.5)
fill(rect(h1[1]-w/2+2, h1[2]+5, w-4, hgt-7), PAP, 1.2)
fill(rect(h1[1]-w*0.2, h1[2]-1, w*0.4, 4), DK, 1)
local lb = brush{kind="round", width=0.9, point=0.3}
for i=0,5 do lb:reload(DK, 0.7); lb:stroke({{h1[1]-w/2+5, h1[2]+10+i*4}, {h1[1]+w/2-5-((i%2)*6), h1[2]+10+i*4}}, {pressure={0.35,0.35}}) end

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, w) m = m * BOX if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
local function q(a,b,c,d) return poly({a,b,c,d}) end
local DK = pile{{"bone black",1.6},{"ultramarine ash",0.5}}
-- the crate's mark, MIRIAD's own: a blue hexagon with a white chevron, a block of stencilled code below
local CR = pile{{"lead white",1.6},{"bone black",0.3},{"ultramarine ash",0.5}}
local cx1, cx2, cz1, ch = -1.6, -0.75, 2.4, 0.95
local face = q(P(cx1+0.08,0.15,cz1), P(cx2-0.08,0.15,cz1), P(cx2-0.08,ch-0.04,cz1), P(cx1+0.08,ch-0.04,cz1))
fill(face, CR, 2)
local BLU = pile{{"cobalt blue",1},{"ultramarine blue",0.4},{"lead white",0.2}}
local c = P((cx1+cx2)/2, 0.66, cz1)
local s = 420/cz1
local hex = {}
for k=0,5 do local a = math.pi/6 + k*math.pi/3; hex[#hex+1] = {c[1] + 0.17*s*math.cos(a), c[2] + 0.17*s*math.sin(a)} end
fill(poly(hex), BLU, 1.2)
local ch1 = poly({{c[1]-0.09*s, c[2]-0.02*s}, {c[1], c[2]-0.09*s}, {c[1]+0.09*s, c[2]-0.02*s}, {c[1]+0.09*s, c[2]+0.04*s}, {c[1], c[2]-0.03*s}, {c[1]-0.09*s, c[2]+0.04*s}})
fill(ch1, pile{{"zinc white",2},{"lead white",1}}, 1)
local tb = brush{kind="round", width=1.6, point=0.2}
for i=0,1 do
  tb:reload(DK, 0.8); tb:stroke({{c[1]-0.22*s, c[2]+(0.25+i*0.07)*s}, {c[1]+((i==0) and 0.22 or 0.1)*s, c[2]+(0.25+i*0.07)*s}}, {pressure={0.6,0.6}})
end
-- the cases: give them a lit top, a shadowed side and a latch
local CASET = pile{{"chrome yellow",1},{"Mars orange",0.5},{"lead white",0.5}}
local CASEF = pile{{"Mars orange",1},{"chrome yellow",0.4},{"bone black",0.12}}
local CASES = pile{{"Mars orange",1},{"burnt sienna",0.5},{"bone black",0.5}}
for _,b in ipairs({{-0.25, 0.25, 2.0, 2.3, 0.35}, {-0.1, 0.35, 1.75, 2.0, 0.28}}) do
  fill(q(P(b[2],0,b[3]), P(b[2],0,b[4]), P(b[2],b[5],b[4]), P(b[2],b[5],b[3])), CASES, 2)
  fill(q(P(b[1],b[5],b[3]), P(b[2],b[5],b[3]), P(b[2],b[5],b[4]), P(b[1],b[5],b[4])), CASET, 2)
  fill(q(P(b[1],0,b[3]), P(b[2],0,b[3]), P(b[2],b[5],b[3]), P(b[1],b[5],b[3])), CASEF, 2)
  local e = brush{kind="round", width=1.4, point=0.3}
  e:reload(DK, 0.8); e:stroke({P(b[1],b[5],b[3]), P(b[2],b[5],b[3])}, {pressure={0.45,0.45}})
  e:reload(DK, 0.8); e:stroke({P(b[2],0,b[3]), P(b[2],b[5],b[3])}, {pressure={0.4,0.4}})
  local m = P((b[1]+b[2])/2, b[5]*0.75, b[3])
  fill(rect(m[1]-5, m[2]-2.5, 10, 5), DK, 1)
  e:reload(DK, 0.9); e:stroke({P(b[1],0,b[3]), P(b[2],0,b[3]), P(b[2],0,b[4])}, {pressure={0.6,0.6}})
end
-- the rail stands out from the wall on brackets
local RAIL = pile{{"lead white",1.2},{"bone black",0.6},{"ultramarine ash",0.6}}
local rb = brush{kind="round", width=6, point=0.2}
rb:reload(RAIL, 0.9); rb:stroke({P(WR-0.12,1.0,1.0), P(WR-0.12,1.0,2.25)}, {pressure={0.75,0.65}})
rb:reload(RAIL, 0.9); rb:stroke({P(WR-0.12,1.0,3.15), P(WR-0.12,1.0,4.25)}, {pressure={0.6,0.55}})
for _,z in ipairs({1.4, 3.6}) do rb:reload(DK, 0.9); rb:stroke({P(WR-0.12,1.0,z), P(WR,0.95,z)}, {pressure={0.6,0.6}}) end
-- the jacket: folds, a hanging sleeve, a reflective band
local JKD = pile{{"ultramarine blue",1},{"bone black",0.9}}
local fb = brush{kind="round", width=3, point=0.4}
for _,z in ipairs({2.45, 2.62, 2.85, 2.98}) do fb:reload(JKD, 0.8); fb:stroke({P(WR-0.14,1.0,z), P(WR-0.13,0.65,z+0.04), P(WR-0.12,0.35,z+0.03)}, {pressure={0.45,0.2}}) end
local JK = pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.35}}
fill(q(P(WR-0.13,0.95,3.08), P(WR-0.13,0.95,3.28), P(WR-0.12,0.05,3.42), P(WR-0.12,0.05,3.22)), JK, 2)
fill(q(P(WR-0.13,0.25,3.2), P(WR-0.13,0.25,3.4), P(WR-0.12,0.15,3.42), P(WR-0.12,0.15,3.22)), pile{{"zinc white",2},{"lemon chrome",0.4}}, 1)

--@ chunk 7
print(wait(2*24*60))
local function fill(m, p, w) m = m * BOX if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
local function q(a,b,c,d) return poly({a,b,c,d}) end
local SH = pile{{"bone black",1.4},{"bone brown",0.5},{"ultramarine ash",0.3}}
-- contact shadows under the load, falling toward us from the lights overhead
local function shadow(X1, X2, z1, z2, grow)
  local m = q(P(X1-0.04,0,z1-grow), P(X2+0.04,0,z1-grow), P(X2+0.04,0,z2), P(X1-0.04,0,z2)) * BOX
  work(m, {hand="detail", tool={kind="filbert", width=2}, pile=SH, coverage=3.5, fill=true, clip=m, angle=0})
end
shadow(-1.75, -0.35, 2.3, 2.32, 0.1)
shadow(-0.25, 0.25, 2.0, 2.02, 0.08)
shadow(-0.1, 0.35, 1.75, 1.77, 0.07)
-- the handrail, crisp: dark bar with a lit top line
local DK = pile{{"bone black",1.6},{"ultramarine ash",0.5}}
local LT = pile{{"zinc white",2},{"lead white",1}}
local rb = brush{kind="round", width=5, point=0.2}
rb:reload(DK, 0.95); rb:stroke({P(WR-0.12,1.0,1.55), P(WR-0.12,1.0,2.3)}, {pressure={0.8,0.7}})
rb:reload(DK, 0.95); rb:stroke({P(WR-0.12,1.0,3.12), P(WR-0.12,1.0,4.25)}, {pressure={0.7,0.6}})
local lb = brush{kind="round", width=1.5, point=0.3}
lb:reload(LT, 0.8); lb:stroke({P(WR-0.12,1.03,1.55), P(WR-0.12,1.03,2.3)}, {pressure={0.5,0.4}})
lb:reload(LT, 0.8); lb:stroke({P(WR-0.12,1.03,3.12), P(WR-0.12,1.03,4.25)}, {pressure={0.4,0.35}})
-- the near work lights blaze: clean white cores and a lit rim on the ceiling around them
local SW = pile{{"zinc white",4},{"lead white",0.5}}
for _,z in ipairs({2.2, 3.4}) do
  fill(q(P(-0.78,CH,z+0.07), P(0.78,CH,z+0.07), P(0.78,CH,z+0.33), P(-0.78,CH,z+0.33)), SW, 3)
end
for _,z in ipairs({6.0, 9.0, 12.0}) do
  fill(q(PB(-0.78,CH,z+0.07), PB(0.78,CH,z+0.07), PB(0.78,CH,z+0.33), PB(-0.78,CH,z+0.33)) * WIN, SW, 1.2)
end
-- light pooled on the deck under them: a paler plate band, solid paint
local FLL = pile{{"lead white",1.1},{"bone black",0.8},{"bone brown",0.45},{"ultramarine ash",0.3}}
for _,z in ipairs({3.4}) do
  local m = q(P(-1.0,0,z-0.2), P(0.9,0,z-0.2), P(0.9,0,z+0.75), P(-1.0,0,z+0.75)) * BOX - q(P(-1.8,0,2.2), P(-0.3,0,2.2), P(-0.3,0,3.2), P(-1.8,0,3.2))
  work(m, {hand="body", tool={kind="filbert", width=4}, pile=FLL, coverage=3.4, fill=true, clip=m, angle=0, edge="soft"})
end

--@ chunk 8
local function q(a,b,c,d) return poly({a,b,c,d}) end
local z = 3.4
local outer = q(P(-1.3,0,z-0.35), P(1.2,0,z-0.35), P(1.2,0,z+0.95), P(-1.3,0,z+0.95)) * BOX
local inner = q(P(-0.7,0,z-0.05), P(0.6,0,z-0.05), P(0.6,0,z+0.55), P(-0.7,0,z+0.55)) * BOX
local crate = q(P(-1.8,0,2.2), P(-0.3,0,2.2), P(-0.3,0,3.2), P(-1.8,0,3.2)) + poly({P(-1.6,0.12,2.4), P(-0.75,0.12,2.4), P(-0.75,0.95,2.4), P(-1.6,0.95,2.4)})
blend(outer - inner - crate:grow(2), {angle=0, tool={kind="badger", width=8}})
blend(outer - inner - crate:grow(2), {angle=1.5708, tool={kind="badger", width=8}})
