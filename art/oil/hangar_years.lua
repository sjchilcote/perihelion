-- easel session "hangar_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=4647,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.9},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
VP = {560,250}
function S(z) return 1/(1+0.5*z) end
function sec(z) local s = S(z); return {s=s, hw=700*s, fy=VP[2]+330*s, sy=VP[2]-20*s, vr=700*s} end
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.9,0.9}, ramps={0.03,0.1}, clip=clip})
end
-- the hall as perspective bands: vault (top half-disc) and walls/floor (below springing), near dark to far warm
ZS = {0, 0.4, 0.9, 1.6, 2.5, 3.7, 5.3, 7.5, 10.5, 15, 22}
local ramp = {
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.5},{"bone brown",1.4},{"burnt sienna",0.4}},
 pile{{"bone black",1.1},{"bone brown",1.6},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.8},{"bone black",0.5}},
 pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.3}},
 pile{{"bone brown",1.2},{"burnt sienna",1},{"raw sienna",0.6}},
 pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.7}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.8},{"yellow ochre",0.3},{"bone brown",0.3}},
 pile{{"raw sienna",1.3},{"yellow ochre",0.6},{"burnt sienna",0.5},{"lead white",0.3}},
 pile{{"yellow ochre",1.1},{"raw sienna",0.8},{"lead white",0.5}} }
function shape(z)
  local c = sec(z); local pts = {}
  for k=0,24 do local a = math.pi + math.pi*k/24; pts[#pts+1] = {VP[1]+math.cos(a)*c.hw, c.sy+math.sin(a)*c.vr*0.75} end
  pts[#pts+1] = {VP[1]+c.hw, c.fy}; pts[#pts+1] = {VP[1]-c.hw, c.fy}
  return poly(pts)
end
work(everywhere() - shape(0), {hand="broad", pile=ramp[1], coverage=3, fill=true, angle=0.3, load=1.0})
for i=1,#ZS-1 do
  local band = shape(ZS[i]) - shape(ZS[i+1])
  local c = sec(ZS[i])
  work(band, {hand="body", tool={kind="filbert", width=clamp(c.hw/50,2,14)}, pile=ramp[i], coverage=3.2, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(c.hw/30,4,40), clamp(c.hw/8,8,110)}, load=1.0})
end
-- the far round door open on black space
local e = sec(22)
DOOR = ellipse(VP[1], VP[2]+e.hw*0.1, e.hw*0.75, e.hw*0.75)
work(DOOR, {hand="body", tool="filbert 2", pile=pile{{"bone black",2},{"ultramarine blue",0.6}}, coverage=4.5, fill=true, clip=true, angle=0, length={4,10}, load=1.0})

--@ chunk 2
print(wait(3*24*60))
-- the deck: one plane from the near edge to the far door, lighter toward the door
local e = sec(22); local n = sec(0)
local fl = {
 pile{{"bone black",1.4},{"bone brown",1.2},{"ultramarine ash",0.4}},
 pile{{"bone brown",1.4},{"burnt sienna",0.6},{"ultramarine ash",0.4},{"lead white",0.15}},
 pile{{"raw sienna",1},{"bone brown",0.8},{"ultramarine ash",0.3},{"lead white",0.35}},
 pile{{"raw sienna",1},{"yellow ochre",0.5},{"lead white",0.6}} }
local zz = {0, 1.2, 4, 10, 22}
for i=1,4 do
  local a, b = sec(zz[i]), sec(zz[i+1])
  local q = poly({{VP[1]-a.hw, (i==1) and 563 or a.fy},{VP[1]+a.hw, (i==1) and 563 or a.fy},{VP[1]+b.hw, b.fy},{VP[1]-b.hw, b.fy}})
  work(q, {hand="body", tool={kind="filbert", width=clamp(a.hw/60,2,12)}, pile=fl[i], coverage=3.4, fill=true, clip=q, angle=0, length={10,60}, load=1.0})
end
-- ribs: heavy bronze arches with a warm lit inner edge, drawn in reloaded segments
local rib = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8}}
local ribL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local seam = pile{{"bone black",2},{"bone brown",0.5}}
for _,z in ipairs({0.15, 0.9, 1.6, 2.5, 3.7, 5.3, 7.5, 10.5, 15}) do
  local c = sec(z); local pts = {{VP[1]-c.hw, c.fy}}
  for k=0,24 do local a = math.pi + math.pi*k/24; pts[#pts+1] = {VP[1]+math.cos(a)*c.hw, c.sy+math.sin(a)*c.vr*0.75} end
  pts[#pts+1] = {VP[1]+c.hw, c.fy}
  for j=1,#pts-1 do
    ST({pts[j], pts[j+1]}, rib, math.max(1.5, 34*c.s), {1,1}, 1.0)
    local ia = {lerp(pts[j][1], VP[1], 0.02), lerp(pts[j][2], VP[2], 0.02)}; local ib = {lerp(pts[j+1][1], VP[1], 0.02), lerp(pts[j+1][2], VP[2], 0.02)}
    ST({ia, ib}, ribL, math.max(0.8, 5*c.s), {0.9,0.9}, 1.0)
  end
end
-- deck seams running to the door
for _,x in ipairs({-500,-250,0,250,500,750,1000,1250,1500,1800}) do ST({{x, 563},{lerp(x, VP[1], 0.95), lerp(563, e.fy, 0.95)}}, seam, 3, {0.8,0.05}, 0.9) end

--@ chunk 3
print(wait(3*24*60))
local dk = pile{{"bone black",1.8},{"bone brown",1}}
local brz = pile{{"bone brown",1.4},{"burnt sienna",0.9},{"raw sienna",0.3}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
-- a point on the deck at lateral offset u (-1 left wall .. 1 right wall) and depth z
function deck(u, z) local c = sec(z); return {VP[1] + u*c.hw, c.fy} end
function up(p, z, hgt) local c = sec(z); return {p[1], p[2] - hgt*c.hw} end
-- empty cradles: pairs of curved arms rising from the deck, and a gantry tower behind each, both sides, receding
CRZ = {0.5, 1.5, 2.8, 4.5, 6.8, 10, 14.5}
for i,z in ipairs(CRZ) do
  for _,side in ipairs({-1, 1}) do
    if not (side == -1 and i == 1) then
      local s = sec(z).s
      local u0 = side*0.62
      for _,dz in ipairs({0, 0.5 + 0.12*z}) do
        local zz = z + dz
        local b1, b2 = deck(u0 - 0.13, zz), deck(u0 + 0.13, zz)
        local t1, t2 = up(deck(u0 - 0.2, zz), zz, 0.16), up(deck(u0 + 0.2, zz), zz, 0.16)
        local m = up(deck(u0, zz), zz, 0.04)
        ST({t1, b1, m, b2, t2}, brz, math.max(1.2, 22*sec(zz).s), {1,1}, 1.0)
        ST({t1, b1, m}, brzL, math.max(0.6, 4*sec(zz).s), {0.8,0.8}, 1.0)
      end
      -- gantry: a tall lattice tower against the wall with a jib reaching over the cradle
      local g = deck(side*0.92, z + 0.25)
      local gt = up(g, z + 0.25, 0.85)
      ST({g, gt}, dk, math.max(1.2, 26*s), {1,1}, 1.0)
      ST({{g[1] - side*6*s, g[2]}, {gt[1] - side*6*s, gt[2]}}, brzL, math.max(0.6, 4*s), {0.8,0.8}, 1.0)
      local jib = up(deck(u0, z + 0.25), z + 0.25, 0.8)
      ST({gt, jib}, dk, math.max(1, 14*s), {1,1}, 1.0)
      for k=1,4 do local t = k/5; ST({{lerp(g[1],gt[1],t), lerp(g[2],gt[2],t)}, {lerp(g[1],gt[1],t+0.1) - side*14*s, lerp(g[2],gt[2],t+0.1)}}, dk, math.max(0.8, 6*s), {0.8,0.8}, 1.0) end
    end
  end
end

--@ chunk 4
print(wait(2*24*60))
local dk = pile{{"bone black",1.8},{"bone brown",1}}
local brz = pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.3}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
-- heavier cradle arms everywhere: a dark body stroke under the pale one
for i,z in ipairs(CRZ) do for _,side in ipairs({-1,1}) do if not (side == -1 and i == 1) then
  local u0 = side*0.62
  for _,dz in ipairs({0, 0.5 + 0.12*z}) do local zz = z + dz; local s = sec(zz).s
    local b1, b2 = deck(u0 - 0.13, zz), deck(u0 + 0.13, zz)
    local t1, t2 = up(deck(u0 - 0.2, zz), zz, 0.16), up(deck(u0 + 0.2, zz), zz, 0.16)
    local m = up(deck(u0, zz), zz, 0.04)
    ST({t1, b1, m, b2, t2}, brz, math.max(1.5, 40*s), {1,1}, 1.0)
    ST({t1, b1, m}, brzL, math.max(0.8, 6*s), {0.9,0.9}, 1.0)
  end
end end end
-- the near-left cradle, enormous, and in it the CUCULUS, small: a dark seed-pod hull
local z = 0.45; local s = sec(z).s
local u0 = -0.55
for _,dz in ipairs({0, 0.35, 0.7}) do local zz = z + dz; local ss = sec(zz).s
  local b1, b2 = deck(u0 - 0.15, zz), deck(u0 + 0.15, zz)
  local t1, t2 = up(deck(u0 - 0.24, zz), zz, 0.2), up(deck(u0 + 0.24, zz), zz, 0.2)
  local m = up(deck(u0, zz), zz, 0.04)
  ST({t1, b1, m, b2, t2}, brz, 48*ss, {1,1}, 1.0); ST({t1, b1, m}, brzL, 8*ss, {0.9,0.9}, 1.0)
end
local c0 = up(deck(u0, z + 0.2), z + 0.2, 0.09); local c1 = up(deck(u0, z + 0.65), z + 0.65, 0.09)
HULL = {c0, c1}
local hull = ribbon({{c0[1], c0[2]}, {lerp(c0[1],c1[1],0.5), lerp(c0[2],c1[2],0.5)}, {c1[1], c1[2]}}, {26, 34, 14})
work(hull, {hand="body", tool="filbert 3", pile=dk, coverage=4.5, fill=true, clip=true, angle=math.atan(c1[2]-c0[2], c1[1]-c0[1]), length={6,18}, load=1.0})
local hl = pile{{"lead white",1.4},{"yellow ochre",0.7},{"raw sienna",0.4}}
ST({{c0[1]+2, c0[2]-10}, {lerp(c0[1],c1[1],0.5), lerp(c0[2],c1[2],0.5)-15}, {c1[1], c1[2]-6}}, hl, 3, {0.6,0.9})
ST({{c0[1]-6, c0[2]}, {c0[1]-14, c0[2]+2}}, pile{{"lead white",2},{"Indian yellow",0.6}}, 6, {1,1})
-- cables from the gantry to the ship
local g = up(deck(-0.92, z + 0.3), z + 0.3, 0.7)
for k=0,4 do local t = k/4; local p = {lerp(c0[1],c1[1],t), lerp(c0[2],c1[2],t) - 18}
  ST({g, {lerp(g[1],p[1],0.5) - 10, lerp(g[2],p[2],0.5) + 25}, p}, dk, 2.4, {0.9,0.9}, 1.0)
  ST({{g[1]+1, g[2]-1}, {lerp(g[1],p[1],0.5) - 9, lerp(g[2],p[2],0.5) + 24}, {p[1]+1, p[2]-1}}, brzL, 0.8, {0.6,0.6}, 0.7) end
ST({g, up(deck(-0.92, z + 0.3), z + 0.3, 0)}, dk, 28, {1,1}, 1.0)

--@ chunk 5
print(wait(2*24*60))
local hot = pile{{"zinc white",4},{"lemon chrome",0.12}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"bone brown",0.5}}
-- the sun's sliver at the edge of the far round door, glare spiking into the black and along the door's rim
local e = sec(22); local cx, cy, r = VP[1], VP[2] + e.hw*0.1, e.hw*0.75
local pts = {}; for k=0,10 do local a = -0.9 + k/10*1.3; pts[#pts+1] = {cx + math.cos(a)*r*0.92, cy + math.sin(a)*r*0.92} end
ST(pts, hot, 4, {0.6,0.9}, 1.0)
work(ellipse(cx + r*0.78, cy - r*0.32, 5, 5), {hand="detail", pile=hot, coverage=4.5, fill=true})
for k=1,10 do local a = rand(2.4, 4.0); local L = rand(10,30)
  ST({{cx + r*0.78, cy - r*0.32},{cx + r*0.78 + math.cos(a)*L, cy - r*0.32 + math.sin(a)*L}}, hot, 1.2, {0.9,0}, 0.9) end
-- a long shaft of that glare down the deck toward us
for k=1,12 do local u = rand(-0.08, 0.12); local z0, z1 = rand(10,20), rand(2,6)
  ST({deck(u, z0), deck(u + rand(0.05,0.15), z1)}, warmH, rand(1.5,3), {0.4,0.0}, 0.5) end
-- warm glare catching the ship's back, and a hatch light

ST({HULL[1], HULL[2]}, warmH, 2.4, {0.5,0.8}, 1.0)

--@ chunk 6
print(wait(2*24*60))
local fl = {
 pile{{"bone brown",1.4},{"bone black",0.5},{"ultramarine ash",0.4},{"burnt sienna",0.3}},
 pile{{"bone brown",1.3},{"burnt sienna",0.6},{"ultramarine ash",0.3},{"lead white",0.25}},
 pile{{"raw sienna",1},{"bone brown",0.7},{"ultramarine ash",0.2},{"lead white",0.45}} }
local avoid = ellipse(deck(-0.22,1.3)[1], deck(-0.22,1.3)[2] - 12, 14, 22)
-- strokes running along the deck toward the door, crossing the band edges, so the floor grades instead of stepping
for _,b in ipairs({{1.0, 1.6, 1}, {3.2, 5.2, 2}, {8, 12, 3}}) do
  for k=1,40 do local u = rand(-0.62, 0.62); local z0 = rand(b[1], b[2]); local z1 = z0 * rand(1.3, 1.7)
    ST({deck(u, z0), deck(u, z1)}, fl[b[3]], math.max(2, 16*sec(z0).s), {0.6,0.3}, 0.8, -avoid) end
end

--@ chunk 7
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local WH = pile{{"lead white",2},{"yellow ochre",0.15},{"zinc white",0.3}}
local WHS = pile{{"lead white",1},{"ultramarine ash",0.6},{"bone black",0.3},{"yellow ochre",0.1}}
local WHD = pile{{"ultramarine ash",0.8},{"bone black",0.8},{"lead white",0.3}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
local BLU = pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.25}}
local dk = pile{{"bone black",1.8},{"bone brown",1}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
SHIPS = {{1, 1.5}, {-1, 2.8}, {1, 4.5}, {-1, 6.8}}
for _,sh in ipairs(SHIPS) do
  local side, z = sh[1], sh[2]
  local u0 = side*0.62
  local za, zb = z - 0.05, z + 0.55 + 0.12*z
  local a, b = up(deck(u0, za), za, 0.13), up(deck(u0, zb), zb, 0.13)
  local wa, wb = 0.16*sec(za).hw, 0.16*sec(zb).hw
  local mid = {(a[1]+b[1])/2, (a[2]+b[2])/2}
  local hull = ribbon({a, mid, b}, {wa*0.9, wa*0.75, wb*0.6})
  local ang = math.atan(b[2]-a[2], b[1]-a[1])
  fill(hull, WH, math.max(1.5, wa*0.08), ang)
  -- underside in shadow, and a darker belly line
  local under = hull * mask(function(x,y) local t = ((x-a[1])*(b[1]-a[1]) + (y-a[2])*(b[2]-a[2])) / ((b[1]-a[1])^2 + (b[2]-a[2])^2); t = clamp(t, 0, 1); local cy = a[2] + (b[2]-a[2])*t; return (y > cy + 0.08*(wa + (wb-wa)*t)) and 1 or 0 end)
  fill(under, WHS, math.max(1.2, wa*0.06), ang)
  -- amber hazard band round the hull near the stern, and a blue hexagon on the flank
  local t0 = 0.62
  local s0 = {a[1] + (b[1]-a[1])*t0, a[2] + (b[2]-a[2])*t0}
  local bw = (wa + (wb-wa)*t0)*0.4
  for k=0,5 do
    local px = s0[1] + (k - 2.5)*bw*0.09*side
    fill(poly({{px, s0[2] - bw}, {px + bw*0.08, s0[2] - bw}, {px + bw*0.08, s0[2] + bw*0.9}, {px, s0[2] + bw*0.9}}), (k % 2 == 0) and AMB or dk, 1)
  end
  local hc = {a[1] + (b[1]-a[1])*0.3, a[2] + (b[2]-a[2])*0.3}
  local hr = (wa*0.75)*0.22
  local hx = {}
  for k=0,5 do local t = math.pi/6 + k*math.pi/3; hx[#hx+1] = {hc[1] + hr*math.cos(t), hc[2] - hr*0.2 + hr*math.sin(t)} end
  fill(poly(hx), BLU, 1)
  -- cockpit glazing at the bow
  local bow = {a[1] + (b[1]-a[1])*0.04, a[2] + (b[2]-a[2])*0.04 - wa*0.18}
  fill(ellipse(bow[1], bow[2], wa*0.16, wa*0.08), pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.25}}, 1)
  -- lit top edge
  local e = brush{kind="round", width=math.max(0.8, wa*0.05), point=0.5}
  e:reload(pile{{"lead white",2},{"cadmium yellow",0.4}}, 0.8)
  e:stroke({{a[1], a[2] - wa*0.38}, {mid[1], mid[2] - wa*0.33}, {b[1], b[2] - wb*0.25}}, {pressure={0.55,0.35}})
  -- cables and hoses from the gantry jib down to the hull
  local g = deck(side*0.92, z + 0.25)
  local gt = up(g, z + 0.25, 0.8)
  for k=0,3 do
    local t = 0.15 + k*0.22
    local p = {a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t - wa*0.3}
    local cb = brush{kind="round", width=math.max(0.8, 2.6*sec(z).s*3), point=0.5}
    cb:reload((k == 1) and pile{{"chrome yellow",1},{"Mars orange",0.4},{"bone black",0.2}} or dk, 0.9)
    cb:stroke({gt, {(gt[1]+p[1])/2 - side*8, (gt[2]+p[2])/2 + 20*sec(z).s*3}, p}, {pressure={0.7,0.6}})
  end
  -- a work light at the jib end, burning
  local lb = brush{kind="round", width=math.max(2, 18*sec(z).s), point=0.3}
  lb:reload(pile{{"lead white",2},{"Indian yellow",0.5},{"cadmium yellow",0.3}}, 0.9); lb:touch(gt[1] - side*4, gt[2] + 4, {pressure=0.6})
end

--@ chunk 8
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local WH = pile{{"lead white",2},{"yellow ochre",0.2},{"zinc white",0.2}}
local WHM = pile{{"lead white",1.3},{"yellow ochre",0.2},{"ultramarine ash",0.3},{"bone black",0.12}}
local WHS = pile{{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.4},{"burnt sienna",0.15}}
local AMB = pile{{"chrome yellow",2},{"Mars orange",0.6},{"bone black",0.05}}
local BLU = pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.25}}
local dk = pile{{"bone black",1.8},{"bone brown",1}}
-- each ship: a long hull lying in its cradle, bow toward the far door; drawn as a side view foreshortened in depth
local function ship(side, z, L, Hh)
  local u0 = side*0.6
  local za, zb = z, z + L
  local function P(t, h) local zz = za + (zb - za)*t; local d = up(deck(u0, zz), zz, h); return d end
  local top, bot = {}, {}
  for k=0,12 do
    local t = k/12
    local prof = math.sqrt(math.max(0, 1 - (2*t - 1)^6))
    top[#top+1] = P(t, 0.08 + Hh*prof)
    bot[#bot+1] = P(t, 0.08 + 0.02*(1 - prof))
  end
  local pts = {}
  for i=1,#top do pts[#pts+1] = top[i] end
  for i=#bot,1,-1 do pts[#pts+1] = bot[i] end
  local hull = poly(pts, true)
  -- shading: upper flank lit, lower in shadow
  local mids = {}
  for k=0,12 do local t = k/12; local prof = math.sqrt(math.max(0, 1 - (2*t - 1)^6)); mids[#mids+1] = P(t, 0.08 + Hh*prof*0.45) end
  local lowpts = {}
  for i=1,#mids do lowpts[#lowpts+1] = mids[i] end
  for i=#bot,1,-1 do lowpts[#lowpts+1] = bot[i] end
  local low = poly(lowpts, true) * hull
  fill(hull - low, WH, math.max(1.2, 6*sec(z).s), 0)
  fill(low, WHS, math.max(1.2, 6*sec(z).s), 0)
  local seam = {}
  for i=1,#mids do seam[i] = mids[i] end
  local sb = brush{kind="round", width=math.max(0.8, 5*sec(z).s), point=0.5}
  sb:reload(WHM, 0.8); sb:stroke(seam, {pressure={0.5,0.5}})
  -- hazard band near the stern, and the blue hexagon forward
  local s1, s2 = P(0.22, 0.08), P(0.3, 0.08)
  local s3, s4 = P(0.3, 0.08 + Hh*0.95), P(0.22, 0.08 + Hh*0.95)
  local band = poly({s1, s2, s3, s4}) * hull
  local n = 6
  for k=0,n-1 do
    local t1, t2 = 0.22 + 0.08*k/n, 0.22 + 0.08*(k+1)/n
    fill(poly({P(t1, 0.07), P(t2, 0.07), P(t2, 0.08 + Hh), P(t1, 0.08 + Hh)}) * hull, (k % 2 == 0) and AMB or dk, 1)
  end
  local hc = P(0.7, 0.08 + Hh*0.55)
  local hr = Hh*sec(za + L*0.7).hw*0.3
  local hx = {}
  for k=0,5 do local t = math.pi/6 + k*math.pi/3; hx[#hx+1] = {hc[1] + hr*math.cos(t), hc[2] + hr*math.sin(t)} end
  fill(poly(hx), BLU, 1)
  -- canopy at the bow and a lit spine
  local bw = P(0.88, 0.08 + Hh*0.85)
  fill(ellipse(bw[1], bw[2], hr*0.9, hr*0.45), pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.25}}, 1)
  local sp = {}
  for k=0,12 do local t = k/12; local prof = math.sqrt(math.max(0, 1 - (2*t - 1)^6)); sp[#sp+1] = P(t, 0.08 + Hh*prof - 0.003) end
  local e = brush{kind="round", width=math.max(0.8, 5*sec(z).s), point=0.5}
  e:reload(pile{{"lead white",2},{"cadmium yellow",0.45}}, 0.85); e:stroke(sp, {pressure={0.55,0.4}})
  -- cables from the jib
  local g = deck(side*0.92, z + 0.25)
  local gt = up(g, z + 0.25, 0.8)
  for k=0,3 do
    local p = P(0.2 + k*0.2, 0.08 + Hh)
    local cb = brush{kind="round", width=math.max(0.8, 7*sec(z).s), point=0.5}
    cb:reload((k == 1) and pile{{"chrome yellow",1},{"Mars orange",0.4},{"bone black",0.2}} or dk, 0.9)
    cb:stroke({gt, {(gt[1]+p[1])/2 - side*10*sec(z).s, (gt[2]+p[2])/2 + 40*sec(z).s}, p}, {pressure={0.7,0.6}})
  end
  local lb = brush{kind="round", width=math.max(2, 26*sec(z).s), point=0.3}
  lb:reload(pile{{"lead white",2},{"Indian yellow",0.5},{"cadmium yellow",0.3}}, 0.9); lb:touch(gt[1] - side*4, gt[2] + 4, {pressure=0.65})
end
ship(1, 1.2, 1.1, 0.13)
ship(-1, 2.6, 1.0, 0.12)
ship(1, 4.3, 1.4, 0.12)
ship(-1, 6.6, 1.8, 0.12)

--@ chunk 9
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local e = sec(22); local cx, cy, r = VP[1], VP[2] + e.hw*0.1, e.hw*0.75
-- a ship coming in through the far door: a small white hull with running lights, seen nose-on, a little off centre
local sx, sy = cx - r*0.25, cy - r*0.15
fill(ellipse(sx, sy, r*0.2, r*0.11), pile{{"lead white",2},{"yellow ochre",0.1}}, 1)
fill(ellipse(sx, sy + r*0.04, r*0.2, r*0.05), pile{{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.3}}, 1)
local wb = brush{kind="round", width=1.2, point=0.5}
wb:reload(pile{{"lead white",1},{"bone black",0.5}}, 0.8); wb:stroke({{sx - r*0.38, sy + r*0.02}, {sx + r*0.38, sy + r*0.02}}, {pressure={0.4,0.4}})
local lb = brush{kind="round", width=2.2, point=0.3}
lb:reload(pile{{"cadmium red",1},{"lead white",0.4}}, 0.9); lb:touch(sx - r*0.38, sy + r*0.02, {pressure=0.5})
lb:reload(pile{{"emerald green",1},{"zinc white",0.6}}, 0.9); lb:touch(sx + r*0.38, sy + r*0.02, {pressure=0.5})
lb:reload(pile{{"lead white",2},{"cadmium yellow",0.6}}, 0.9); lb:touch(sx, sy - r*0.02, {pressure=0.45})
-- its landing lights thrown as a pale line down the deck from the door
local sh = brush{kind="round", width=2, point=0.4}
for k=1,5 do sh:reload(pile{{"lead white",1.6},{"cadmium yellow",0.3}}, 0.4); local u = rand(-0.08, 0.04); sh:stroke({deck(u, 20), deck(u + rand(-0.02,0.02), rand(9, 13))}, {pressure={0.4,0.05}}) end
-- the CUCULUS in its near cradle: warm working lights on its back, cables from the gantry glowing
local c0, c1 = HULL[1], HULL[2]
local hl = brush{kind="round", width=3, point=0.4}
hl:reload(pile{{"lead white",1.6},{"Indian yellow",0.6},{"yellow ochre",0.3}}, 0.9); hl:stroke({{c0[1]+2, c0[2]-12}, {(c0[1]+c1[1])/2, (c0[2]+c1[2])/2 - 16}, {c1[1], c1[2]-8}}, {pressure={0.7,0.6}})
lb:reload(pile{{"lead white",2},{"Indian yellow",0.6}}, 0.9); lb:touch((c0[1]+c1[1])/2, (c0[2]+c1[2])/2 - 4, {pressure=0.6})
-- small figures at work on the deck: crew in blue coveralls, a tall docent in bronze
local function person(u, z, coat, hgt)
  local f = deck(u, z); local H = (hgt or 0.06)*sec(z).hw
  local function Q(pts) local q = {}; for i,v in ipairs(pts) do q[i] = {f[1] + v[1]*H, f[2] + v[2]*H} end; return poly(q) end
  fill(Q({{-0.12,0},{-0.06,-0.45},{-0.13,-0.8},{0.13,-0.8},{0.07,-0.45},{0.13,0},{0.04,0},{0,-0.38},{-0.04,0}}), coat, 1)
  fill(Q({{-0.07,-0.8},{0.07,-0.8},{0.07,-0.95},{0,-1.0},{-0.07,-0.95}}), pile{{"lead white",1},{"red earth",0.35},{"yellow ochre",0.3}}, 1)
  fill(Q({{-0.13,-0.58},{0.13,-0.58},{0.13,-0.53},{-0.13,-0.53}}), pile{{"lead white",1.5},{"ultramarine ash",0.3}}, 1)
  local sb = brush{kind="round", width=math.max(1, 0.12*H), point=0.4}
  sb:reload(pile{{"bone black",2}}, 0.6); sb:stroke({{f[1], f[2] + 1}, {f[1] - 0.25*H, f[2] + 0.35*H}}, {pressure={0.5,0.1}})
end
local CV = pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.25}}
person(0.35, 1.6, CV); person(0.45, 1.75, CV); person(-0.38, 3.0, CV); person(0.42, 4.6, CV); person(-0.1, 2.2, CV, 0.05)
local function docent(u, z)
  local f = deck(u, z); local H = 0.1*sec(z).hw
  local function Q(pts) local q = {}; for i,v in ipairs(pts) do q[i] = {f[1] + v[1]*H, f[2] + v[2]*H} end; return poly(q) end
  fill(Q({{-0.1,0},{-0.05,-0.5},{-0.09,-0.85},{0.09,-0.85},{0.05,-0.5},{0.1,0},{0.03,0},{0,-0.42},{-0.03,0}}), pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone brown",0.3}}, 1)
  fill(Q({{-0.06,-0.85},{0.06,-0.85},{0.04,-1.0},{-0.04,-1.0}}), pile{{"yellow ochre",1},{"lead white",0.5}}, 1)
  local sb = brush{kind="round", width=math.max(0.8, 0.05*H), point=0.4}
  sb:reload(pile{{"lead white",1.4},{"cadmium yellow",0.5}}, 0.8); sb:stroke({{f[1] - 0.08*H, f[2] - 0.84*H}, {f[1] - 0.04*H, f[2] - 0.2*H}}, {pressure={0.45,0.3}})
  local ey = brush{kind="round", width=math.max(1.2, 0.04*H), point=0.4}
  ey:reload(pile{{"cerulean blue",1},{"zinc white",1}}, 0.9); ey:touch(f[1], f[2] - 0.95*H, {pressure=0.5})
end
docent(-0.3, 1.5); docent(0.22, 3.6)
-- a small cart of crates between them
local cr = deck(0.05, 1.45)
local H = 0.04*sec(1.45).hw
fill(rect(cr[1] - 1.2*H, cr[2] - 0.7*H, 2.4*H, 0.7*H), pile{{"lead white",1.6},{"ultramarine ash",0.3}}, 1)
fill(rect(cr[1] - 1.2*H, cr[2] - 0.35*H, 2.4*H, 0.12*H), pile{{"chrome yellow",2}}, 1)
