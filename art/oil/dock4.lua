-- easel session "dock4": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=21,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.35},{"bone brown",0.3}}, um=120, apply="knife", texture=0.25}}}
-- a curved ring corridor seen along its length: the floor rises ahead and passes out of sight under the ceiling
CXV, Y0, FOC, EYE, RR = 470, 250, 420, 1.6, 42
WL, WR, CH = -2.1, 2.1, 2.9
function rise(z) return z*z/(2*RR) end
function P(X, Y, z) return {CXV + FOC*X/z, Y0 - FOC*(Y + rise(z) - EYE)/z} end
ZS = {1.0, 1.35, 1.8, 2.4, 3.1, 4.0, 5.0, 6.2, 7.6, 9.2, 11, 13, 15, 17, 19.5, 22, 25}
SURF = {}
local Pfloor = {pile{{"bone black",1},{"bone brown",0.5},{"lead white",0.25}}, pile{{"bone black",1},{"bone brown",0.4},{"lead white",0.12}}}
local Pwall = {pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.4}}, pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.18}}}
local Pceil = {pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.2}}, pile{{"bone black",1.4},{"ultramarine blue",0.3},{"lead white",0.08}}}
local function quad(a,b,c,d) return poly({a,b,c,d}) end
for i = #ZS-1, 1, -1 do
  local z1, z2 = ZS[i], ZS[i+1]
  local far = (z1 > 9) and 2 or 1
  local fl = quad(P(WL,0,z1), P(WR,0,z1), P(WR,0,z2), P(WL,0,z2))
  local lw = quad(P(WL,0,z1), P(WL,CH,z1), P(WL,CH,z2), P(WL,0,z2))
  local rw = quad(P(WR,0,z1), P(WR,CH,z1), P(WR,CH,z2), P(WR,0,z2))
  local ce = quad(P(WL,CH,z1), P(WR,CH,z1), P(WR,CH,z2), P(WL,CH,z2))
  local box = rect(0,0,1000,H)
  for _,s in ipairs({{fl,Pfloor},{lw,Pwall},{rw,Pwall},{ce,Pceil}}) do
    local m = s[1] * box
    if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=(z1<3) and 12 or 6}, pile=s[2][far], coverage=3, fill=true, clip=m, length={15,60}}) end
  end
end

--@ chunk 2
print(wait(2*24*60))
-- a curved ring corridor seen along its length: the floor rises ahead and passes out of sight under the ceiling
CXV, Y0, FOC, EYE, RR = 470, 250, 420, 1.6, 30
WL, WR, CH = -2.1, 2.1, 2.9
function rise(z) return z*z/(2*RR) end
function P(X, Y, z) return {CXV + FOC*X/z, Y0 - FOC*(Y + rise(z) - EYE)/z} end
ZS = {1.0, 1.35, 1.8, 2.4, 3.1, 4.0, 5.0, 6.2, 7.6, 9.2, 11, 13, 15, 17, 19.5, 22, 25, 28}
SURF = {}
local Pfloor = {pile{{"bone black",1},{"bone brown",0.4},{"lead white",0.1}}, pile{{"bone black",1},{"bone brown",0.3},{"lead white",0.05}}}
local Pwall = {pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.14}}, pile{{"bone black",1},{"ultramarine blue",0.25},{"lead white",0.07}}}
local Pceil = {pile{{"bone black",1.2},{"ultramarine blue",0.25},{"lead white",0.05}}, pile{{"bone black",1.4},{"ultramarine blue",0.2}}}
local function quad(a,b,c,d) return poly({a,b,c,d}) end
for i = #ZS-1, 1, -1 do
  local z1, z2 = ZS[i], ZS[i+1]
  local far = (z1 > 12) and 2 or 1
  local fl = quad(P(WL,0,z1), P(WR,0,z1), P(WR,0,z2), P(WL,0,z2))
  local lw = quad(P(WL,0,z1), P(WL,CH,z1), P(WL,CH,z2), P(WL,0,z2))
  local rw = quad(P(WR,0,z1), P(WR,CH,z1), P(WR,CH,z2), P(WR,0,z2))
  local ce = quad(P(WL,CH,z1), P(WR,CH,z1), P(WR,CH,z2), P(WL,CH,z2))
  local box = rect(0,0,1000,H)
  for _,s in ipairs({{fl,Pfloor},{lw,Pwall},{rw,Pwall},{ce,Pceil}}) do
    local m = s[1] * box
    if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=(z1<3) and 12 or 6}, pile=s[2][far], coverage=3, fill=true, clip=m, length={15,60}}) end
  end
end

--@ chunk 3
print(wait(2*24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
RIB = pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.28}}
RIBD = pile{{"bone black",1.4},{"ultramarine blue",0.2}}
DOOR = pile{{"bone black",1},{"ultramarine blue",0.25},{"lead white",0.2},{"bone brown",0.1}}
RACK = pile{{"bone black",1},{"bone brown",0.3},{"lead white",0.2}}
POD = pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.15}}
RIBZ = {1.5, 4.5, 7.5, 10.5, 13.5, 16.5, 19.5, 22.5, 25.5}
local function paint(m, p, w) if m:area() > 0.5 then work(m, {hand="detail", tool={kind="filbert", width=w or 2.5}, pile=p, coverage=3.5, fill=true, clip=m}) end end
-- far to near
for i = #RIBZ, 1, -1 do
  local zr = RIBZ[i]
  local t = 0.22
  local z1, z2 = zr - t, zr + t
  local w = (zr < 5) and 6 or 2.5
  -- bay door on the right wall (the bay behind this rib)
  local a, b = zr + 0.45, zr + 3 - 0.45
  if i < #RIBZ then
    paint(quad(P(WR,0.12,a), P(WR,2.4,a), P(WR,2.4,b), P(WR,0.12,b)), DOOR, w)
    paint(quad(P(WR,2.4,a), P(WR,2.55,a), P(WR,2.55,b), P(WR,2.4,b)), RIBD, w)
  end
  -- shelving and pods on the left wall
  if i < #RIBZ then
    for _,yy in ipairs({0.25, 1.0, 1.75, 2.5}) do
      paint(quad(P(WL,yy,zr+0.25), P(WL,yy+0.07,zr+0.25), P(WL,yy+0.07,zr+2.75), P(WL,yy,zr+2.75)), RACK, w)
    end
    for _,yy in ipairs({0.25, 1.0, 1.75}) do
      for k=0,2 do
        local p1, p2 = zr + 0.35 + k*0.82, zr + 0.35 + k*0.82 + 0.66
        if (i*3 + k + yy*4) % 5 ~= 1 then
          paint(quad(P(WL,yy+0.08,p1), P(WL,yy+0.58,p1), P(WL,yy+0.58,p2), P(WL,yy+0.08,p2)), POD, w)
        end
      end
    end
  end
  -- the rib itself: a frame round the whole section
  paint(quad(P(WL,0,z1), P(WL,CH,z1), P(WL,CH,z2), P(WL,0,z2)), RIB, w)
  paint(quad(P(WR,0,z1), P(WR,CH,z1), P(WR,CH,z2), P(WR,0,z2)), RIB, w)
  paint(quad(P(WL,CH,z1), P(WR,CH,z1), P(WR,CH,z2), P(WL,CH,z2)), RIB, w)
  paint(quad(P(WL,0,z1), P(WR,0,z1), P(WR,0,z2), P(WL,0,z2)), RIBD, w)
end

--@ chunk 4
print(wait(24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
-- the near ceiling closes over the far ribs: the ring bends up out of sight
local CEIL = pile{{"bone black",1.2},{"ultramarine blue",0.25},{"lead white",0.05}}
local cz = {1.0, 2.4, 4.0, 6.2, 8.0, 9.6}
for i=1,#cz-1 do
  local m = quad(P(WL,CH,cz[i]), P(WR,CH,cz[i]), P(WR,CH,cz[i+1]), P(WL,CH,cz[i+1])) - quad(P(WL,CH,4.28), P(WR,CH,4.28), P(WR,CH,4.72), P(WL,CH,4.72)) - quad(P(WL,CH,7.28), P(WR,CH,7.28), P(WR,CH,7.72), P(WL,CH,7.72))
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=CEIL, coverage=3.5, fill=true, clip=m})
end
-- the helmet lamp's light: a cold oval on the floor ahead and a wash over bay 9's door
LT = {pile{{"lead white",2},{"zinc white",0.6},{"bone black",0.25},{"ultramarine blue",0.08}},
      pile{{"lead white",1},{"bone black",0.5},{"ultramarine blue",0.12},{"bone brown",0.1}},
      pile{{"bone black",1},{"lead white",0.35},{"ultramarine blue",0.15},{"bone brown",0.15}}}
FZ, FX = 12.2, 0.3
local function fl(lo, hi)
  return mask(function(x,y) return 0 end)
end
local rings = {{0, 0.45, 1}, {0.45, 0.75, 2}, {0.75, 1.0, 3}}
for _,r in ipairs(rings) do
  local pts1, pts2 = {}, {}
  for k=0,24 do
    local a = 2*math.pi*k/24
    local X, Z = FX + 1.7*r[2]*math.cos(a), FZ + 3.4*r[2]*math.sin(a)
    pts1[#pts1+1] = P(X, 0, Z)
  end
  local m = poly(pts1, true) * box
  if r[1] > 0 then
    for k=0,24 do local a = 2*math.pi*k/24; pts2[#pts2+1] = P(FX + 1.7*r[1]*math.cos(a), 0, FZ + 3.4*r[1]*math.sin(a)) end
    m = m - poly(pts2, true)
  end
  work(m, {hand="body", tool={kind="filbert", width=2.5}, pile=LT[r[3]], coverage=3.2, fill=true, angle=0, clip=m, edge=(r[3]==3) and "soft" or nil})
end
-- spill on the right wall: door of bay 9 and the rib before it
local d9 = quad(P(WR,0.12,10.95), P(WR,2.4,10.95), P(WR,2.4,13.05), P(WR,0.12,13.05))
local d9c = quad(P(WR,0.12,11.4), P(WR,2.0,11.4), P(WR,2.0,12.7), P(WR,0.12,12.7))
work(d9 - d9c, {hand="detail", tool={kind="filbert", width=2}, pile=LT[3], coverage=3.2, fill=true, clip=d9})
work(d9c, {hand="detail", tool={kind="filbert", width=2}, pile=LT[2], coverage=3.2, fill=true, clip=d9c})
local d1 = quad(P(WR,0.12,13.95), P(WR,2.4,13.95), P(WR,2.4,16.05), P(WR,0.12,16.05))
work(d1, {hand="detail", tool={kind="filbert", width=2}, pile=LT[3], coverage=2.5, fill=true, clip=d1})
-- the Commando, from behind, walking the ring: a small dark frame
local k = 420/9
local fx, fy = 470 + k*0.3, 250 - k*(rise(9) - EYE)
local function Q(dx, dy) return {fx + dx*k, fy - dy*k} end
FRAMEP = pile{{"bone black",2},{"ultramarine blue",0.5},{"bone brown",0.4}}
local body = poly({Q(-0.2,1.05),Q(-0.24,1.45),Q(-0.2,1.55),Q(0.2,1.55),Q(0.24,1.45),Q(0.2,1.05)}, true)
  + ellipse(fx, fy - 1.72*k, 0.13*k, 0.15*k)
  + ribbon({Q(-0.1,1.05),Q(-0.14,0.55),Q(-0.18,0.04)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(0.1,1.05),Q(0.13,0.55),Q(0.1,0.12)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(-0.23,1.48),Q(-0.3,1.18),Q(-0.31,0.92)}, {0.11*k,0.09*k,0.08*k})
  + ribbon({Q(0.23,1.48),Q(0.32,1.22),Q(0.36,1.0)}, {0.11*k,0.09*k,0.08*k})
  + ellipse(fx - 0.03*k, fy - 1.6*k, 0.12*k, 0.06*k)
FRAMEM = body
work(body, {hand="detail", tool={kind="round", width=1.4}, pile=FRAMEP, coverage=4, fill=true, clip=body})
-- his shadow, thrown back toward us by nothing but the faint strips: a dark smear under his feet
local sh = ellipse(fx-2, fy+1.5, 0.45*k, 0.07*k)
work(sh, {hand="detail", pile=pile{{"bone black",2},{"bone brown",0.5}}, coverage=2.5, fill=true, clip=sh})

--@ chunk 5
local box = rect(0,0,1000,H)
-- soften the lamp's oval into one pool, fused along the floor
local pts = {}
for k=0,24 do local a = 2*math.pi*k/24; pts[#pts+1] = P(FX + 1.85*math.cos(a), 0, FZ + 3.7*math.sin(a)) end
local pool = poly(pts, true) * box - FRAMEM:grow(1)
blend(pool, {angle=0, tool={kind="badger", width=6}})
print(wait(24*60))
-- the frame back into dark, a cold edge where the lamp's spill catches its shoulders
local FR2 = pile{{"bone black",2},{"ultramarine blue",0.5},{"bone brown",0.3}}
work(FRAMEM, {hand="detail", tool={kind="round", width=1.2}, pile=FR2, coverage=5, fill=true, clip=FRAMEM})

--@ chunk 6
print(wait(24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
local k = 420/9
local fx, fy = 470 + k*0.3, 250 - k*(rise(9) - EYE)
-- the light starts beyond him: put the floor at his feet and behind back into the dark
local FLD = pile{{"bone black",1},{"bone brown",0.4},{"lead white",0.08}}
local nearfl = quad(P(WL+0.05,0,8.2), P(WR-0.05,0,8.2), P(WR-0.05,0,9.8), P(WL+0.05,0,9.8)) - FRAMEM:grow(0.8) - quad(P(WL,0,7.28), P(WR,0,7.28), P(WR,0,7.72), P(WL,0,7.72))
work(nearfl, {hand="body", tool={kind="filbert", width=2.5}, pile=FLD, coverage=3.5, fill=true, angle=0, clip=nearfl})
blend(quad(P(WL+0.05,0,9.5), P(WR-0.05,0,9.5), P(WR-0.05,0,10.3), P(WL+0.05,0,10.3)) - FRAMEM:grow(0.8), {angle=0, tool={kind="badger", width=4}})
-- and it runs on up the rising floor, thinning into the dark where the ring bends away
local up1 = quad(P(-1.0,0,15.5), P(1.6,0,15.5), P(1.3,0,19), P(-0.6,0,19))
work(up1, {hand="detail", tool={kind="filbert", width=2}, pile=LT[3], coverage=2.5, fill=true, angle=0, clip=up1, edge="soft"})
-- the beam itself in the dead air: a cold low-load glaze fanning from the helmet
local hx, hy = fx + 0.05*k, fy - 1.72*k
local cone = poly({{hx, hy-2}, {hx, hy+3}, P(1.9,0,15), P(1.8,1.2,18), P(-0.6,1.6,18), P(-1.0,0,15)}) * box - FRAMEM:grow(0.5)
work(cone, {hand="glaze", tool={kind="filbert", width=6}, pile=pile{{"lead white",3},{"zinc white",1},{"ultramarine blue",0.1},medium=0.6}, load=0.22, pressure={0.1,0.2}, coverage=1.0, clip=cone, angle=-1.2})
-- edge light on the helmet and shoulders from the lamp's own spill
local e = brush{kind="round", width=0.8, point=0.6}
local EL = pile{{"lead white",2},{"zinc white",1},{"ultramarine blue",0.1}}
e:reload(EL, 0.6); e:stroke({{hx-0.11*k, hy-0.05*k},{hx-0.05*k, hy-0.15*k},{hx+0.06*k, hy-0.14*k},{hx+0.1*k, hy-0.03*k}}, {pressure={0.3,0.25}})
e:reload(EL, 0.5); e:stroke({{fx-0.24*k, fy-1.5*k},{fx-0.1*k, fy-1.56*k}}, {pressure={0.22,0.15}})
e:reload(EL, 0.5); e:stroke({{fx+0.1*k, fy-1.56*k},{fx+0.25*k, fy-1.48*k}}, {pressure={0.22,0.15}})
-- the lamp itself, glimpsed past the right of the helmet
local g = brush{kind="round", width=1.6, point=0.4}
g:reload(pile{{"zinc white",3},{"lemon chrome",0.1}}, 0.8); g:touch(hx + 0.12*k, hy + 0.01*k, {pressure=0.5})

--@ chunk 7
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
local ribs = nil
for _,zr in ipairs(RIBZ) do
  local r = quad(P(WL,0,zr-0.22), P(WL,CH,zr-0.22), P(WL,CH,zr+0.22), P(WL,0,zr+0.22)) + quad(P(WR,0,zr-0.22), P(WR,CH,zr-0.22), P(WR,CH,zr+0.22), P(WR,0,zr+0.22))
       + quad(P(WL,CH,zr-0.22), P(WR,CH,zr-0.22), P(WR,CH,zr+0.22), P(WL,CH,zr+0.22)) + quad(P(WL,0,zr-0.22), P(WR,0,zr-0.22), P(WR,0,zr+0.22), P(WL,0,zr+0.22))
  ribs = ribs and (ribs + r) or r
end
RIBM = ribs
local DW = pile{{"bone black",1.3},{"ultramarine blue",0.3},{"lead white",0.05}}
local DF = pile{{"bone black",1.3},{"bone brown",0.4}}
local zz = 8.6
local rw = quad(P(WR,0,1.0), P(WR,CH,1.0), P(WR,CH,zz), P(WR,0,zz)) - ribs
local lw = quad(P(WL,0,1.0), P(WL,CH,1.0), P(WL,CH,zz), P(WL,0,zz)) - ribs
local fl = quad(P(WL,0,1.0), P(WR,0,1.0), P(WR,0,8.2), P(WL,0,8.2)) - ribs
local ce = quad(P(WL,CH,1.0), P(WR,CH,1.0), P(WR,CH,zz), P(WL,CH,zz)) - ribs
work(rw + lw + ce, {hand="scumble", tool={kind="filbert", width=6}, pile=DW, coverage=2.2, load=0.5, clip=rw + lw + ce})
work(fl, {hand="body", tool={kind="filbert", width=8}, pile=DF, coverage=2.5, fill=true, angle=0, clip=fl, length={30,80}})
-- the ribs fall off into shadow too, but keep their edges
work(ribs * quad(P(WL-0.1,-0.1,1.0), P(WR+0.1,-0.1,1.0), P(WR+0.1,-0.1,6), P(WL-0.1,-0.1,6)) * box + ribs * (rect(0,0,1000,H) - poly({P(WL,0,6), P(WR,0,6), P(WR,CH,6), P(WL,CH,6)})) * mask(function(x,y) return 0 end),
  {hand="scumble", tool={kind="filbert", width=4}, pile=pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.15}}, coverage=1.2, load=0.4})

--@ chunk 8
print(wait(24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
local function paint(m, p, w, cov) if m:area() > 0.3 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=cov or 3.5, fill=true, clip=m}) end end
AMB = pile{{"chrome yellow",1},{"Mars orange",0.5},{"bone black",0.35}}
AMBD = pile{{"Mars orange",1},{"bone brown",1},{"bone black",0.6}}
local BLK = pile{{"bone black",2},{"ultramarine blue",0.3}}
local DOORD = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.12}}
-- bay doors on the near right wall, dim, each with a hazard band across its head
for _,zr in ipairs({1.5, 4.5, 7.5}) do
  local a, b = zr + 0.45, zr + 2.55
  local w = (zr < 3) and 5 or 2.5
  paint(quad(P(WR,0.12,a), P(WR,2.2,a), P(WR,2.2,b), P(WR,0.12,b)), DOORD, w)
  local n = 10
  for s=0,n-1 do
    local z1, z2 = a + (b-a)*s/n, a + (b-a)*(s+1)/n
    local m = poly({P(WR,2.22,z1), P(WR,2.42,z1+0.08), P(WR,2.42,z2+0.08), P(WR,2.22,z2)}) * box
    paint(m, (s%2==0) and AMBD or BLK, (zr<3) and 2.5 or 1.2)
  end
end
-- the docking collar on the near left wall: a dead round hatch in a striped ring
local cz, cy = 3.0, 1.25
local outer, inner = {}, {}
for k=0,40 do local a = 2*math.pi*k/40; outer[#outer+1] = P(WL, cy + 1.12*math.sin(a), cz + 1.12*math.cos(a)); inner[#inner+1] = P(WL, cy + 0.9*math.sin(a), cz + 0.9*math.cos(a)) end
local ringm = poly(outer, true) * box - poly(inner, true)
local hatch = poly(inner, true) * box
paint(hatch, pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.18}}, 5)
for s=0,15 do
  local a1, a2 = 2*math.pi*s/16, 2*math.pi*(s+1)/16
  local seg = poly({P(WL, cy+0.9*math.sin(a1), cz+0.9*math.cos(a1)), P(WL, cy+1.12*math.sin(a1+0.1), cz+1.12*math.cos(a1+0.1)), P(WL, cy+1.12*math.sin(a2+0.1), cz+1.12*math.cos(a2+0.1)), P(WL, cy+0.9*math.sin(a2), cz+0.9*math.cos(a2))}) * box
  paint(seg, (s%2==0) and AMBD or BLK, 3)
end
local bb = brush{kind="round", width=2.2, point=0.4}
for k=0,7 do
  local a = 2*math.pi*k/8 + 0.2
  bb:reload(pile{{"bone black",1},{"lead white",0.35},{"ultramarine blue",0.2}}, 0.6)
  bb:stroke({P(WL, cy+0.25*math.sin(a), cz+0.25*math.cos(a)), P(WL, cy+0.8*math.sin(a), cz+0.8*math.cos(a))}, {pressure={0.4,0.4}})
end
local hub = {}
for k=0,20 do local a = 2*math.pi*k/20; hub[#hub+1] = P(WL, cy+0.22*math.sin(a), cz+0.22*math.cos(a)) end
paint(poly(hub, true) * box, pile{{"bone black",1.5},{"ultramarine blue",0.3}}, 3)
-- bay numerals, stencilled on the doors: 7, 8, 9 ... and 1
DIG = {
  ["7"] = {{{0,1},{1,1},{0.35,0}}},
  ["8"] = {{{0.15,1},{0.85,1},{0.85,0.55},{0.15,0.55},{0.15,1}}, {{0.1,0.55},{0.9,0.55},{0.9,0},{0.1,0},{0.1,0.55}}},
  ["9"] = {{{0.9,0.55},{0.1,0.55},{0.1,1},{0.9,1},{0.9,0}}},
  ["1"] = {{{0.25,0.8},{0.55,1},{0.55,0}}, {{0.25,0},{0.85,0}}},
  ["2"] = {{{0.1,1},{0.9,1},{0.9,0.55},{0.1,0.55},{0.1,0},{0.9,0}}},
}
function numeral(d, zr, p, load)
  local za, zb = zr + 1.05, zr + 1.95
  local ya, yb = 0.9, 1.9
  local wm = 0.13
  for _,seg in ipairs(DIG[d]) do
    local pts = {}
    for _,q in ipairs(seg) do pts[#pts+1] = P(WR, ya + (yb-ya)*q[2], za + (zb-za)*q[1]) end
    local zc = (za+zb)/2
    local br = brush{kind="round", width=math.max(0.8, wm*FOC/zc), point=0.2}
    br:reload(p, load or 0.85)
    br:stroke(pts, {pressure={0.75,0.75}, ramps={0.02,0.05}})
  end
end
local STEN = pile{{"lead white",1},{"chrome yellow",0.25},{"bone black",0.55}}
numeral("7", 1.5, STEN, 0.8)
numeral("8", 4.5, STEN, 0.8)
numeral("9", 7.5, STEN, 0.8)
numeral("1", 10.5, pile{{"lead white",2},{"chrome yellow",0.3},{"bone black",0.3}}, 0.9)
numeral("2", 13.5, STEN, 0.6)

--@ chunk 9
print(wait(24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
local function paint(m, p, w, cov) if m:area() > 0.3 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=cov or 4, fill=true, clip=m}) end end
local DOORD = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.12}}
-- the stencils went on back to front: paint them out
for _,zr in ipairs({1.5, 4.5, 7.5}) do
  paint(quad(P(WR,0.75,zr+0.9), P(WR,2.05,zr+0.9), P(WR,2.05,zr+2.1), P(WR,0.75,zr+2.1)), DOORD, (zr<3) and 4 or 2)
end
paint(quad(P(WR,0.75,11.4), P(WR,2.0,11.4), P(WR,2.0,12.6), P(WR,0.75,12.6)), LT[2], 1.5)
paint(quad(P(WR,0.75,14.4), P(WR,2.05,14.4), P(WR,2.05,15.6), P(WR,0.75,15.6)), LT[3], 1.5)
print(wait(2*24*60))
function numeral(d, zr, p, load)
  local za, zb = zr + 1.05, zr + 1.95
  local ya, yb = 0.9, 1.9
  for _,seg in ipairs(DIG[d]) do
    local pts = {}
    for _,q in ipairs(seg) do pts[#pts+1] = P(WR, ya + (yb-ya)*q[2], zb - (zb-za)*q[1]) end
    local br = brush{kind="round", width=math.max(0.8, 0.13*FOC/((za+zb)/2)), point=0.2}
    br:reload(p, load or 0.85)
    br:stroke(pts, {pressure={0.75,0.75}, ramps={0.02,0.05}})
  end
end
local STEN = pile{{"lead white",1},{"chrome yellow",0.25},{"bone black",0.6}}
numeral("7", 1.5, STEN, 0.8)
numeral("8", 4.5, STEN, 0.8)
numeral("9", 7.5, STEN, 0.8)
numeral("1", 10.5, pile{{"lead white",2},{"chrome yellow",0.3},{"bone black",0.35}}, 0.9)
numeral("2", 13.5, STEN, 0.6)
-- emergency strips at the foot of the walls: mostly dead, three still burning
local STRD = pile{{"bone black",1},{"Mars red",0.3},{"lead white",0.1}}
local STRL = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.4}}
local STRR = pile{{"cadmium red",1},{"Mars orange",0.6},{"lead white",0.3}}
for _,side in ipairs({WL, WR}) do
  for _,zr in ipairs({1.5, 4.5, 7.5, 10.5, 13.5, 16.5}) do
    paint(quad(P(side,0.06,zr+0.3), P(side,0.13,zr+0.3), P(side,0.13,zr+2.7), P(side,0.06,zr+2.7)), STRD, 1.2)
  end
end
local function lit(side, z1, z2, p, glowp)
  paint(quad(P(side,0.06,z1), P(side,0.13,z1), P(side,0.13,z2), P(side,0.06,z2)), p, 1.0)
  local sx = (side < 0) and 0.35 or -0.35
  local g = quad(P(side,0,z1-0.3), P(side+sx,0,z1-0.1), P(side+sx,0,z2+0.1), P(side,0,z2+0.3)) + quad(P(side,0,z1-0.3), P(side,0.5,z1-0.1), P(side,0.5,z2+0.1), P(side,0,z2+0.3))
  work(g:soften(2), {hand="scumble", tool={kind="filbert", width=3}, pile=glowp, coverage=1.2, load=0.3, pressure={0.15,0.3}, clip=g:grow(2)})
end
lit(WR, 2.2, 3.6, STRL, pile{{"Mars orange",1},{"bone brown",1},{"bone black",0.4}})
lit(WL, 5.3, 6.4, STRR, pile{{"Mars red",1},{"bone brown",1},{"bone black",0.5}})
lit(WR, 8.9, 9.5, STRL, pile{{"Mars orange",1},{"bone brown",1},{"bone black",0.5}})

--@ chunk 10
print(wait(24*60))
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
local DW = pile{{"bone black",1.3},{"ultramarine blue",0.3},{"lead white",0.05}}
local DF = pile{{"bone black",1.3},{"bone brown",0.4}}
local function refix(side, z1, z2, warm)
  local sx = (side < 0) and 0.45 or -0.45
  local fl = quad(P(side,0,z1-0.5), P(side+sx,0,z1-0.3), P(side+sx,0,z2+0.3), P(side,0,z2+0.5)):grow(1.5) - RIBM
  local wl = quad(P(side,0.14,z1-0.5), P(side,0.7,z1-0.3), P(side,0.7,z2+0.3), P(side,0.14,z2+0.5)):grow(1.5) - RIBM
  work(fl, {hand="detail", tool={kind="filbert", width=2.5}, pile=DF, coverage=4, fill=true, clip=fl, angle=0})
  work(wl, {hand="detail", tool={kind="filbert", width=2.5}, pile=DW, coverage=4, fill=true, clip=wl})
  local sx2 = (side < 0) and 0.18 or -0.18
  local band = quad(P(side,0,z1-0.1), P(side+sx2,0,z1), P(side+sx2,0,z2), P(side,0,z2+0.1)) + quad(P(side,0.14,z1-0.1), P(side,0.32,z1), P(side,0.32,z2), P(side,0.14,z2+0.1))
  work(band, {hand="detail", tool={kind="filbert", width=1.5}, pile=warm, coverage=3, fill=true, clip=band})
  blend(band:grow(2.5) - band:shrink(1), {tool={kind="badger", width=4}})
end
refix(WR, 2.2, 3.6, pile{{"Mars orange",1},{"bone brown",1.2},{"bone black",0.6}})
refix(WL, 5.3, 6.4, pile{{"Mars red",1},{"bone brown",1.2},{"bone black",0.7}})
refix(WR, 8.9, 9.5, pile{{"Mars orange",1},{"bone brown",1.2},{"bone black",0.7}})
-- machine-language placards on the ribs beside the doors
local PL = pile{{"lead white",1},{"bone black",0.5},{"ultramarine blue",0.1}}
local PLD = pile{{"bone black",2}}
for _,zr in ipairs({1.5, 4.5, 7.5}) do
  local a, b = zr - 0.2, zr + 0.2
  local m = quad(P(WR,1.45,a), P(WR,1.75,a), P(WR,1.75,b), P(WR,1.45,b))
  work(m, {hand="detail", tool={kind="round", width=1.2}, pile=PL, coverage=4, fill=true, clip=m})
  local tb = brush{kind="round", width=math.max(0.5, 0.025*FOC/zr), point=0.3}
  for r=0,3 do
    local yy = 1.7 - r*0.07
    tb:reload(PLD, 0.7)
    local zA, zB = a + 0.05, b - 0.05 - (r%2)*0.12
    tb:stroke({P(WR,yy,zA), P(WR,yy,zB)}, {pressure={0.5,0.5}})
  end
end

--@ chunk 11
local box = rect(0,0,1000,H)
local function quad(a,b,c,d) return poly({a,b,c,d}) * box end
-- the floor rib at the near section had gone chalky: back to a dark steel lip with one cold edge
local RIBD = pile{{"bone black",1.4},{"ultramarine blue",0.2}}
local r = quad(P(WL,0,4.28), P(WR,0,4.28), P(WR,0,4.72), P(WL,0,4.72)):grow(0.8)
work(r, {hand="detail", tool={kind="filbert", width=3}, pile=RIBD, coverage=4, fill=true, angle=0, clip=r})
print(wait(24*60))
local e = brush{kind="round", width=0.9, point=0.5}
e:reload(pile{{"bone black",1},{"lead white",0.4},{"ultramarine blue",0.2}}, 0.6)
e:stroke({P(WL+0.1,0.01,4.72), P(0,0.01,4.72), P(WR-0.1,0.01,4.72)}, {pressure={0.3,0.3}})
-- the hatch is in shadow below its hub
local cz, cy = 3.0, 1.25
local lower = {}
for k=0,20 do local a = math.pi + math.pi*k/20; lower[#lower+1] = P(WL, cy + 0.88*math.sin(a), cz + 0.88*math.cos(a)) end
local sh = poly(lower, true) * box
work(sh, {hand="scumble", tool={kind="filbert", width=4}, pile=pile{{"bone black",1.4},{"ultramarine blue",0.3}}, coverage=1.6, load=0.45, clip=sh})

--@ chunk 12
local box = rect(0,0,1000,H)
local cz, cy = 3.0, 1.25
local pts = {}
for k=0,30 do local a = 2*math.pi*k/30; pts[#pts+1] = P(WL, cy + 0.86*math.sin(a), cz + 0.86*math.cos(a)) end
local disc = poly(pts, true) * box
local band = poly({P(WL, cy+0.32, cz-0.9), P(WL, cy+0.32, cz+0.9), P(WL, cy-0.42, cz+0.9), P(WL, cy-0.42, cz-0.9)}) * disc
blend(band, {angle=math.pi/2, tool={kind="badger", width=10}})
blend(band, {angle=math.pi/2 + 0.3, tool={kind="badger", width=10}})

--@ chunk 13
print(wait(2*24*60))
local box = rect(0,0,1000,H)
local cz, cy = 3.0, 1.25
local function circ(r, a0, a1, n)
  local t = {}
  for k=0,n do local a = a0 + (a1-a0)*k/n; t[#t+1] = P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end
  return t
end
local disc = poly(circ(0.9, 0, 2*math.pi, 40), true) * box
local top = disc * poly({P(WL, cy+1, cz-1.2), P(WL, cy+1, cz+1.2), P(WL, cy+0.1, cz+1.2), P(WL, cy+0.1, cz-1.2)})
local mid = disc * poly({P(WL, cy+0.1, cz-1.2), P(WL, cy+0.1, cz+1.2), P(WL, cy-0.35, cz+1.2), P(WL, cy-0.35, cz-1.2)})
local bot = disc - top - mid
local H1 = pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.16}}
local H2 = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.09}}
local H3 = pile{{"bone black",1.4},{"ultramarine blue",0.3},{"lead white",0.03}}
for _,s in ipairs({{top,H1},{mid,H2},{bot,H3}}) do
  work(s[1], {hand="body", tool={kind="filbert", width=4}, pile=s[2], coverage=4, fill=true, angle=0, clip=s[1]})
end
blend(disc * poly({P(WL, cy+0.2, cz-1.2), P(WL, cy+0.2, cz+1.2), P(WL, cy, cz+1.2), P(WL, cy, cz-1.2)}), {angle=math.pi/2, tool={kind="badger", width=6}})
blend(disc * poly({P(WL, cy-0.25, cz-1.2), P(WL, cy-0.25, cz+1.2), P(WL, cy-0.45, cz+1.2), P(WL, cy-0.45, cz-1.2)}), {angle=math.pi/2, tool={kind="badger", width=6}})
print(wait(2*24*60))
local bb = brush{kind="round", width=2.2, point=0.4}
for k=0,7 do
  local a = 2*math.pi*k/8 + 0.2
  bb:reload(pile{{"bone black",1},{"lead white",0.3},{"ultramarine blue",0.2}}, 0.6)
  bb:stroke({P(WL, cy+0.25*math.sin(a), cz+0.25*math.cos(a)), P(WL, cy+0.8*math.sin(a), cz+0.8*math.cos(a))}, {pressure={0.4,0.4}})
end
local hub = poly(circ(0.22, 0, 2*math.pi, 20), true) * box
work(hub, {hand="detail", tool={kind="filbert", width=3}, pile=pile{{"bone black",1.5},{"ultramarine blue",0.3}}, coverage=4, fill=true, clip=hub})
local e = brush{kind="round", width=1.2, point=0.5}
e:reload(pile{{"bone black",1},{"lead white",0.45},{"ultramarine blue",0.2}}, 0.6)
e:stroke(circ(0.9, math.pi*0.15, math.pi*0.85, 12), {pressure={0.3,0.3}})

--@ chunk 14
print(wait(24*60))

--@ chunk 15
-- pass: the ring bends LEFT beyond the near frame. Everything inside the frame is laid again on the bend.
function off(z) return (z > 4.72) and ((z-4.72)^2/18) or 0 end
function rz(z) return rise(math.min(z, 4.72)) + 0.015*math.max(0, z-4.72) end
function PB(X, Y, z) return {CXV + FOC*(X - off(z))/z, Y0 - FOC*(Y + rz(z) - EYE)/z} end
local box = rect(0,0,1000,H)
WIN = poly({P(WL,0,4.72), P(WL,CH,4.72), P(WR,CH,4.72), P(WR,0,4.72)}) * box
local function q(a,b,c,d) return poly({a,b,c,d}) end
local function strip(fn, z0, z1, dz)
  local m
  local z = z0
  while z < z1 do
    local za, zb = z, math.min(z + dz, z1)
    local s = fn(za, zb)
    m = m and (m + s) or s
    z = zb
  end
  return m * WIN
end
local FLOOR = pile{{"bone black",1},{"bone brown",0.4},{"lead white",0.1}}
local WALLO = pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.14}}
local WALLI = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"lead white",0.1}}
local CEIL = pile{{"bone black",1.2},{"ultramarine blue",0.25},{"lead white",0.05}}
local VOID = pile{{"bone black",2},{"ultramarine blue",0.3}}
local function paint(m, p, w) work(m, {hand="body", tool={kind="filbert", width=w or 3}, pile=p, coverage=3.6, fill=true, clip=m, length={10,40}}) end
paint(WIN, VOID, 5)
paint(strip(function(a,b) return q(PB(WL,0,a), PB(WR,0,a), PB(WR,0,b), PB(WL,0,b)) end, 4.72, 17, 0.6), FLOOR)
paint(strip(function(a,b) return q(PB(WL,CH,a), PB(WR,CH,a), PB(WR,CH,b), PB(WL,CH,b)) end, 4.72, 17, 0.6), CEIL)
paint(strip(function(a,b) return q(PB(WR,0,a), PB(WR,CH,a), PB(WR,CH,b), PB(WR,0,b)) end, 4.72, 17, 0.5), WALLO)
INNER = strip(function(a,b) return q(PB(WL,0,a), PB(WL,CH,a), PB(WL,CH,b), PB(WL,0,b)) end, 4.72, 13, 0.4)
paint(INNER, WALLI)

--@ chunk 16
print(wait(24*60))
local box = rect(0,0,1000,H)
local function q(a,b,c,d) return poly({a,b,c,d}) end
local function paint(m, p, w, cov) m = m * box if m:area() > 0.3 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=cov or 3.8, fill=true, clip=m}) end end
local RIB = pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.24}}
local RIBD = pile{{"bone black",1.4},{"ultramarine blue",0.2}}
local DOORD = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"lead white",0.16}}
local AMBD = pile{{"Mars orange",1},{"bone brown",1},{"bone black",0.6}}
local BLK = pile{{"bone black",2},{"ultramarine blue",0.3}}
local RACK = pile{{"bone black",1},{"bone brown",0.3},{"lead white",0.16}}
-- far to near: doors and hazard heads on the outer wall, shelves on the inner wall, then the ribs round the bend
for _,zr in ipairs({13.5, 10.5, 7.5, 4.5}) do
  local a, b = zr + 0.45, zr + 2.55
  paint(q(PB(WR,0.12,a), PB(WR,2.2,a), PB(WR,2.2,b), PB(WR,0.12,b)) * WIN, DOORD, 2)
  for s=0,9 do
    local z1, z2 = a + (b-a)*s/10, a + (b-a)*(s+1)/10
    paint(q(PB(WR,2.22,z1), PB(WR,2.42,z1+0.08), PB(WR,2.42,z2+0.08), PB(WR,2.22,z2)) * WIN, (s%2==0) and AMBD or BLK, 1.2)
  end
  for _,yy in ipairs({0.25, 1.0, 1.75, 2.5}) do
    paint(q(PB(WL,yy,zr+0.25), PB(WL,yy+0.08,zr+0.25), PB(WL,yy+0.08,zr+2.75), PB(WL,yy,zr+2.75)) * INNER, RACK, 1.2)
  end
end
for _,zr in ipairs({13.5, 10.5, 7.5}) do
  local z1, z2 = zr - 0.22, zr + 0.22
  paint(q(PB(WR,0,z1), PB(WR,CH,z1), PB(WR,CH,z2), PB(WR,0,z2)) * WIN, RIB, 1.5)
  paint(q(PB(WL,CH,z1), PB(WR,CH,z1), PB(WR,CH,z2), PB(WL,CH,z2)) * WIN, RIB, 1.5)
  paint(q(PB(WL,0,z1), PB(WR,0,z1), PB(WR,0,z2), PB(WL,0,z2)) * WIN, RIBD, 1.5)
  paint(q(PB(WL,0,z1), PB(WL,CH,z1), PB(WL,CH,z2), PB(WL,0,z2)) * INNER, RIB, 1.5)
end
-- paint out the old soft "7" on the near door
paint(q(P(WR,0.6,2.3), P(WR,2.05,2.3), P(WR,2.05,3.75), P(WR,0.6,3.75)), DOORD, 4)
-- the helmet lamp's cold oval on the floor ahead of him, and its wash on the door around the bend
local function oval(cx, cz, rx, rzz, r0, r1)
  local o, i = {}, {}
  for k=0,28 do local a = 2*math.pi*k/28; o[#o+1] = PB(cx + rx*r1*math.cos(a), 0, cz + rzz*r1*math.sin(a)) end
  local m = poly(o, true)
  if r0 > 0 then for k=0,28 do local a = 2*math.pi*k/28; i[#i+1] = PB(cx + rx*r0*math.cos(a), 0, cz + rzz*r0*math.sin(a)) end; m = m - poly(i, true) end
  return m * WIN
end
for _,r in ipairs({{0.7,1.0,3},{0.4,0.7,2},{0,0.4,1}}) do
  local m = oval(0.5, 11.0, 1.5, 2.2, r[1], r[2])
  work(m, {hand="body", tool={kind="filbert", width=2}, pile=LT[r[3]], coverage=3.4, fill=true, angle=0, clip=m})
end
blend(oval(0.5, 11.0, 1.5, 2.2, 0.3, 0.8), {angle=0, tool={kind="badger", width=4}})
local d1 = q(PB(WR,0.12,10.95), PB(WR,2.2,10.95), PB(WR,2.2,13.05), PB(WR,0.12,13.05)) * WIN
local d1c = q(PB(WR,0.4,11.3), PB(WR,2.0,11.3), PB(WR,2.0,12.8), PB(WR,0.4,12.8)) * WIN
paint(d1 - d1c, LT[3], 1.5)
paint(d1c, LT[2], 1.5)
blend(d1c:grow(2) - d1c:shrink(2), {tool={kind="badger", width=4}})

--@ chunk 17
print(wait(2*24*60))
local box = rect(0,0,1000,H)
-- MIRIAD stencils: blocky bars with stencil bridges
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
    m = m * box
    if m:area() > 0.2 then work(m, {hand="detail", tool={kind="round", width=1.0}, pile=p, coverage=4, fill=true, clip=m}) end
  end
end
local AMS = pile{{"chrome yellow",1},{"Mars orange",0.35},{"bone black",0.3},{"lead white",0.2}}
local WHS = pile{{"lead white",1},{"bone black",0.35},{"ultramarine blue",0.05}}
stencil("7", P, 2.4, 3.6, 0.75, 1.95, AMS)
stencil("8", PB, 5.45, 6.55, 0.75, 1.95, AMS)
stencil("9", PB, 8.45, 9.55, 0.75, 1.95, AMS)
stencil("1", PB, 11.4, 12.6, 0.7, 1.95, pile{{"lead white",2},{"chrome yellow",0.6},{"Mars orange",0.15}})

--@ chunk 18
local box = rect(0,0,1000,H)
-- the Commando, small, at the start of the bend
local z = 8.0
local k = FOC/z
local base = PB(0.15, 0, z)
local fx, fy = base[1], base[2]
local function Q(dx, dy) return {fx + dx*k, fy - dy*k} end
local FR = pile{{"bone black",2},{"ultramarine blue",0.5},{"bone brown",0.3}}
local body = poly({Q(-0.2,1.05),Q(-0.25,1.45),Q(-0.2,1.56),Q(0.2,1.56),Q(0.25,1.45),Q(0.2,1.05)}, true)
  + ellipse(fx, fy - 1.72*k, 0.13*k, 0.15*k)
  + ribbon({Q(-0.1,1.05),Q(-0.16,0.55),Q(-0.22,0.04)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(0.1,1.05),Q(0.12,0.55),Q(0.08,0.1)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(-0.24,1.48),Q(-0.31,1.2),Q(-0.32,0.93)}, {0.11*k,0.09*k,0.08*k})
  + ribbon({Q(0.24,1.48),Q(0.33,1.22),Q(0.37,1.0)}, {0.11*k,0.09*k,0.08*k})
FRAMEM2 = body * box
work(FRAMEM2, {hand="detail", tool={kind="round", width=1.3}, pile=FR, coverage=5, fill=true, clip=FRAMEM2})
local hx, hy = fx + 0.05*k, fy - 1.72*k
local tgt = PB(0.8, 1.0, 11.6)
local cone = poly({{hx, hy-2}, {hx, hy+3}, PB(2.1, 0, 10.5), PB(2.1, 2.1, 12.2), PB(-0.6, 0.6, 12.5), PB(-0.9, 0, 10)}) * WIN - FRAMEM2:grow(0.5)
work(cone, {hand="glaze", tool={kind="filbert", width=5}, pile=pile{{"lead white",3},{"zinc white",1},{"ultramarine blue",0.1},medium=0.65}, load=0.18, pressure={0.08,0.18}, coverage=0.9, clip=cone, angle=math.atan(tgt[2]-hy, tgt[1]-hx)})
local e = brush{kind="round", width=0.8, point=0.6}
local EL = pile{{"lead white",2},{"zinc white",1},{"ultramarine blue",0.1}}
e:reload(EL, 0.6); e:stroke({{hx-0.1*k, hy-0.06*k},{hx, hy-0.15*k},{hx+0.11*k, hy-0.04*k}}, {pressure={0.3,0.25}})
e:reload(EL, 0.5); e:stroke({{fx+0.1*k, fy-1.56*k},{fx+0.26*k, fy-1.47*k}}, {pressure={0.22,0.15}})
local g = brush{kind="round", width=1.6, point=0.4}
g:reload(pile{{"zinc white",3},{"lemon chrome",0.1}}, 0.8); g:touch(hx + 0.12*k, hy, {pressure=0.5})
-- a red strip still burning low on the inner wall
local RS = pile{{"cadmium red",1},{"Mars orange",0.5},{"lead white",0.3}}
local s = poly({PB(WL,0.06,5.6), PB(WL,0.13,5.6), PB(WL,0.13,6.8), PB(WL,0.06,6.8)}) * INNER
work(s, {hand="detail", tool={kind="round", width=0.8}, pile=RS, coverage=4, fill=true, clip=s})
-- near deck plates: seams converging, grime, the amber strip's light raking across them
local SEAM = pile{{"bone black",2},{"bone brown",0.4}}
local LIT = pile{{"Mars orange",1},{"chrome yellow",0.5},{"bone brown",0.6},{"bone black",0.3}}
local sb = brush{kind="round", width=1.4, point=0.3}
local ribfl = poly({P(WL,0,4.25), P(WR,0,4.25), P(WR,0,4.75), P(WL,0,4.75)})
for _,X in ipairs({-1.4, -0.7, 0, 0.7, 1.4}) do
  sb:reload(SEAM, 0.8); sb:stroke({P(X,0,1.05), P(X,0,2.2), P(X,0,4.25)}, {pressure={0.55,0.3}})
end
for _,zz in ipairs({1.5, 2.15, 2.95, 3.75}) do
  sb:reload(SEAM, 0.8); sb:stroke({P(WL+0.05,0,zz), P(0,0,zz), P(WR-0.05,0,zz)}, {pressure={0.5,0.5}})
  sb:reload(LIT, 0.5); sb:stroke({P(0.2,0,zz+0.04), P(1.2,0,zz+0.04), P(WR-0.05,0,zz+0.04)}, {pressure={0.25,0.35}})
end
local nfl = poly({P(WL,0,1.0), P(WR,0,1.0), P(WR,0,4.25), P(WL,0,4.25)}) * box
local nz = noise{seed=9, period=40, octaves=3}
local grime = nfl * mask(function(x,y) return nz(x,y) > 0.25 and 1 or 0 end)
work(grime, {hand="scumble", tool={kind="filbert", width=5}, pile=pile{{"bone black",1.5},{"bone brown",0.6}}, coverage=1.2, load=0.4, clip=nfl})
local rake = poly({P(WR,0,2.1), P(WR,0,3.7), P(0.2,0,4.1), P(-0.4,0,2.6)}) * box
work(rake, {hand="glaze", tool={kind="filbert", width=6}, pile=pile{{"Mars orange",1},{"cadmium yellow",0.3},{"lead white",0.3},medium=0.6}, load=0.2, pressure={0.08,0.2}, coverage=0.9, clip=rake, angle=3.0})
-- the docking collar: a heavier flange round the striped ring
local cz, cy = 3.0, 1.25
local function circ(r, n) local t = {} for kk=0,n do local a = 2*math.pi*kk/n; t[#t+1] = P(WL, cy + r*math.sin(a), cz + r*math.cos(a)) end return t end
local flange = (poly(circ(1.3, 48), true) - poly(circ(1.13, 48), true)) * box
work(flange, {hand="detail", tool={kind="filbert", width=3}, pile=pile{{"bone black",1},{"ultramarine blue",0.3},{"lead white",0.22}}, coverage=4, fill=true, clip=flange})

--@ chunk 19
print(wait(2*24*60))
-- flange bolts and a lit lip
local cz, cy = 3.0, 1.25
local bd = brush{kind="round", width=3.0, point=0.3}
local bl = brush{kind="round", width=1.4, point=0.4}
for kk=0,19 do
  local a = 2*math.pi*kk/20 + 0.08
  local p = P(WL, cy + 1.215*math.sin(a), cz + 1.215*math.cos(a))
  bd:reload(pile{{"bone black",2}}, 0.8); bd:touch(p[1], p[2], {pressure=0.5})
  bl:reload(pile{{"bone black",1},{"lead white",0.6},{"ultramarine blue",0.2}}, 0.6); bl:touch(p[1]+0.6, p[2]-0.6, {pressure=0.3})
end
local e = brush{kind="round", width=1.4, point=0.5}
local pts = {}
for kk=0,14 do local a = math.pi*0.1 + math.pi*0.8*kk/14; pts[#pts+1] = P(WL, cy + 1.3*math.sin(a), cz + 1.3*math.cos(a)) end
e:reload(pile{{"bone black",1},{"lead white",0.5},{"ultramarine blue",0.2}}, 0.6); e:stroke(pts, {pressure={0.35,0.35}})
-- the stencils over the wet door went olive: lay them again on dry paint
local AMS2 = pile{{"chrome yellow",1},{"Mars orange",0.3},{"lead white",0.35},{"bone black",0.15}}
stencil("7", P, 2.4, 3.6, 0.75, 1.95, AMS2)
stencil("8", PB, 5.45, 6.55, 0.75, 1.95, AMS2)

--@ chunk 20
print(wait(2*24*60))
local box = rect(0,0,1000,H)
local function q(a,b,c,d) return poly({a,b,c,d}) end
-- he was standing in front of the very door he lights: paint him out
local d1 = q(PB(WR,0.12,10.95), PB(WR,2.2,10.95), PB(WR,2.2,13.05), PB(WR,0.12,13.05)) * WIN
local m = FRAMEM2:grow(1.2)
work(m * d1, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[2], coverage=4.5, fill=true, clip=m * d1})
work(m - d1, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[3], coverage=4.5, fill=true, clip=m - d1})
-- the scribbled glaze on the near floor back to dark plate
local DF = pile{{"bone black",1.3},{"bone brown",0.4}}
local rake = poly({P(WR,0,2.0), P(WR,0,3.8), P(0.1,0,4.2), P(-0.6,0,2.5)}):grow(3) * box * poly({P(WL,0,1.0), P(WR,0,1.0), P(WR,0,4.25), P(WL,0,4.25)})
work(rake, {hand="body", tool={kind="filbert", width=4}, pile=DF, coverage=4, fill=true, angle=0, clip=rake, length={15,40}})
print(wait(2*24*60))
-- the 1, clean again
stencil("1", PB, 11.4, 12.6, 0.7, 1.95, pile{{"lead white",2},{"chrome yellow",0.6},{"Mars orange",0.15}})
-- the Commando, a step to the left, lamp turned toward the door
local z = 8.6
local k = FOC/z
local base = PB(-0.85, 0, z)
local fx, fy = base[1], base[2]
local function Q(dx, dy) return {fx + dx*k, fy - dy*k} end
local FR = pile{{"bone black",2},{"ultramarine blue",0.5},{"bone brown",0.3}}
local body = poly({Q(-0.2,1.05),Q(-0.25,1.45),Q(-0.2,1.56),Q(0.2,1.56),Q(0.25,1.45),Q(0.2,1.05)}, true)
  + ellipse(fx + 0.02*k, fy - 1.72*k, 0.13*k, 0.15*k)
  + ribbon({Q(-0.1,1.05),Q(-0.15,0.55),Q(-0.2,0.04)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(0.1,1.05),Q(0.14,0.55),Q(0.12,0.1)}, {0.15*k,0.12*k,0.11*k})
  + ribbon({Q(-0.24,1.48),Q(-0.3,1.2),Q(-0.31,0.93)}, {0.11*k,0.09*k,0.08*k})
  + ribbon({Q(0.24,1.48),Q(0.34,1.24),Q(0.4,1.02)}, {0.11*k,0.09*k,0.08*k})
FRAMEM3 = body * box
work(FRAMEM3, {hand="detail", tool={kind="round", width=1.2}, pile=FR, coverage=5, fill=true, clip=FRAMEM3})
local hx, hy = fx + 0.02*k, fy - 1.72*k
local e = brush{kind="round", width=0.8, point=0.6}
local EL = pile{{"lead white",2},{"zinc white",1},{"ultramarine blue",0.1}}
e:reload(EL, 0.6); e:stroke({{hx-0.02*k, hy-0.15*k},{hx+0.08*k, hy-0.12*k},{hx+0.13*k, hy-0.02*k}}, {pressure={0.3,0.25}})
e:reload(EL, 0.5); e:stroke({{fx+0.12*k, fy-1.56*k},{fx+0.27*k, fy-1.46*k},{fx+0.33*k, fy-1.2*k}}, {pressure={0.22,0.15}})
local g = brush{kind="round", width=1.6, point=0.4}
g:reload(pile{{"zinc white",3},{"lemon chrome",0.1}}, 0.8); g:touch(hx + 0.14*k, hy + 0.01*k, {pressure=0.5})
-- warm light raking along the near deck seams from the amber strip
local LIT = pile{{"Mars orange",1},{"chrome yellow",0.6},{"lead white",0.3},{"bone brown",0.3}}
local sb = brush{kind="round", width=1.2, point=0.4}
for _,zz in ipairs({2.15, 2.95, 3.75}) do
  sb:reload(LIT, 0.6); sb:stroke({P(WR-0.05,0,zz+0.04), P(1.0,0,zz+0.04), P(0.0,0,zz+0.04)}, {pressure={0.4,0.05}, ramps={0.05,0.9}})
end
for _,X in ipairs({1.4, 0.7}) do
  sb:reload(LIT, 0.5); sb:stroke({P(X+0.03,0,3.9), P(X+0.03,0,2.0)}, {pressure={0.05,0.3}, ramps={0.6,0.1}})
end

--@ chunk 21
print(wait(24*60))
local box = rect(0,0,1000,H)
local dbox = poly({PB(WR,0.62,11.3), PB(WR,2.03,11.3), PB(WR,2.03,12.7), PB(WR,0.62,12.7)})
local ghost = FRAMEM2:grow(1.6) * box - FRAMEM3:grow(0.6) - dbox
local up = ghost * above(function(x) return 284 end)
local lo = ghost * below(function(x) return 284 end)
local DOORD = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"lead white",0.16}}
local FLOOR = pile{{"bone black",1},{"bone brown",0.4},{"lead white",0.12}}
work(up, {hand="detail", tool={kind="filbert", width=1.5}, pile=DOORD, coverage=5, fill=true, clip=up})
work(lo, {hand="detail", tool={kind="filbert", width=1.5}, pile=FLOOR, coverage=5, fill=true, clip=lo})

--@ chunk 22
print(wait(24*60))
local box = rect(0,0,1000,H)
local function q(a,b,c,d) return poly({a,b,c,d}) end
local fig = FRAMEM3:grow(0.6)
local d1 = q(PB(WR,0.12,10.95), PB(WR,2.2,10.95), PB(WR,2.2,13.05), PB(WR,0.12,13.05)) * WIN - fig
local d1c = q(PB(WR,0.4,11.3), PB(WR,2.0,11.3), PB(WR,2.0,12.8), PB(WR,0.4,12.8)) * WIN - fig
work(d1 - d1c, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[3], coverage=5, fill=true, clip=d1 - d1c, angle=math.pi/2})
work(d1c, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[2], coverage=5, fill=true, clip=d1c, angle=math.pi/2})
blend(d1c:grow(1.5) - d1c:shrink(1.5) - fig, {tool={kind="badger", width=3}})
-- the floor in front of that door, lit by the same lamp
local fz = q(PB(-0.2,0,10.6), PB(WR,0,10.6), PB(WR,0,13.0), PB(-0.2,0,13.0)) * WIN - fig
work(fz, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[3], coverage=5, fill=true, clip=fz, angle=0})
print(wait(2*24*60))
stencil("1", PB, 11.4, 12.6, 0.7, 1.95, pile{{"lead white",2},{"chrome yellow",0.6},{"Mars orange",0.15}})

--@ chunk 23
local box = rect(0,0,1000,H)
local legs = FRAMEM2:grow(1.8) * box * below(function(x) return 286 end) - FRAMEM3:grow(0.6)
work(legs, {hand="detail", tool={kind="filbert", width=1.5}, pile=pile{{"bone black",1},{"bone brown",0.45},{"lead white",0.1}}, coverage=5, fill=true, clip=legs, angle=0})

--@ chunk 24
print(wait(24*60))
local box = rect(0,0,1000,H)
local m = (FRAMEM2:grow(2.2) * box * below(function(x) return 284 end)) - FRAMEM3:grow(0.6)
work(m, {hand="detail", tool={kind="filbert", width=1.5}, pile=LT[3], coverage=5, fill=true, clip=m, angle=0})
blend(m:grow(2) - m:shrink(1), {angle=0, tool={kind="badger", width=3}})

--@ chunk 25
print(wait(24*60))
local fig = FRAMEM3:grow(0.6)
local a = rect(424, 283, 54, 13) - fig
local b = rect(424, 296, 54, 22) - fig
work(a, {hand="body", tool={kind="filbert", width=2.5}, pile=LT[3], coverage=5, fill=true, clip=a, angle=0, length={10,30}})
work(b, {hand="body", tool={kind="filbert", width=2.5}, pile=pile{{"bone black",1},{"bone brown",0.45},{"lead white",0.1}}, coverage=5, fill=true, clip=b, angle=0, length={10,30}})
blend(rect(420, 280, 62, 40) - fig, {angle=0, tool={kind="badger", width=4}})
