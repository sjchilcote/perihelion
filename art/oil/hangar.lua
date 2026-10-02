-- easel session "hangar": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=4646,
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
-- the Commando walking from the ship into the hall, tiny, his long shadow toward us
local f = deck(-0.22, 1.3); local H = 0.06*sec(1.3).hw
local function P(pts2, p) local q = {}; for i,v in ipairs(pts2) do q[i] = {f[1] + v[1]*H, f[2] + v[2]*H} end; work(poly(q), {hand="detail", pile=p, coverage=5, fill=true}) end
P({{-0.14,0},{-0.04,-0.45},{-0.13,-0.78},{-0.07,-0.86},{0.07,-0.86},{0.13,-0.78},{0.08,-0.45},{0.2,0},{0.11,0},{0.02,-0.36},{-0.05,0}}, dk)
P({{-0.06,-0.86},{0.06,-0.86},{0.07,-0.94},{0,-1.0},{-0.07,-0.94}}, dk)
P({{-0.12,-0.76},{0.12,-0.76},{0.11,-0.38},{-0.11,-0.38}}, pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.4}})
ST({{f[1]+0.12*H, f[2]-0.84*H},{f[1]+0.13*H, f[2]-0.5*H}}, warmH, 1.2, {0.8,0.4})
ST({{f[1], f[2]+1},{f[1] - 0.3*H, f[2] + 0.5*H},{f[1] - 0.6*H, f[2] + 1.0*H}}, pile{{"bone black",2}}, 0.12*H, {0.7,0.1}, 0.8)
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
