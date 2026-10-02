-- easel session "gauntlet_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=1717,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.9},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
VP = {500,285}; HS = 620
function S(z) return 1/(1+0.42*z) end
function sq(z) local s = S(z); return VP[1]-HS*s, VP[1]+HS*s, VP[2]-HS*s, VP[2]+HS*s end
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.3}, clip=clip})
end
-- faces between depths za and zb: B(ottom) R(ight) T(op) L(eft)
function face(which, za, zb)
  local ax0, ax1, ay0, ay1 = sq(za); local bx0, bx1, by0, by1 = sq(zb)
  if which == "B" then return poly({{ax0,ay1},{ax1,ay1},{bx1,by1},{bx0,by1}}) end
  if which == "T" then return poly({{ax0,ay0},{ax1,ay0},{bx1,by0},{bx0,by0}}) end
  if which == "L" then return poly({{ax0,ay0},{bx0,by0},{bx0,by1},{ax0,ay1}}) end
  return poly({{ax1,ay0},{bx1,by0},{bx1,by1},{ax1,ay1}})
end
SEAM1, SEAM2, ZEND = 5, 13, 40
-- which physical face is the floor in each segment: seg1 B, seg2 R (rotated 90), seg3 T (rotated again)
SEGS = {{0.05, SEAM1, {B="floor", R="wall", T="ceil", L="wall"}},
        {SEAM1, SEAM2, {R="floor", T="wall", L="ceil", B="wall"}},
        {SEAM2, ZEND, {T="floor", L="wall", B="ceil", R="wall"}}}
local P = {
 floor = {pile{{"bone black",1},{"bone brown",1.2},{"ultramarine ash",0.5},{"lead white",0.25}}, pile{{"bone brown",1.2},{"ultramarine ash",0.5},{"raw sienna",0.5},{"lead white",0.35}}},
 wall  = {pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.4}}, pile{{"raw sienna",1.2},{"burnt sienna",0.8},{"yellow ochre",0.3},{"lead white",0.3}}},
 ceil  = {pile{{"bone black",1.6},{"bone brown",1.2},{"burnt sienna",0.3}}, pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.4}}} }
for si,sg in ipairs(SEGS) do
  for _,f in ipairs({"B","R","T","L"}) do
    local role = sg[3][f]
    local m = face(f, sg[1], sg[2])
    local horiz = (f == "B" or f == "T")
    work(m, {hand="body", tool={kind="filbert", width=(si == 1) and 8 or 4}, pile=P[role][(si == 1) and 1 or 2], coverage=3.2, fill=true, clip=m,
      angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={10,50}, load=1.0})
  end
end
local e0, e1, f0, f1 = sq(ZEND)
work(rect(e0, f0, e1-e0, f1-f0):grow(1), {hand="detail", pile=pile{{"raw sienna",1},{"lead white",1},{"yellow ochre",0.5}}, coverage=4, fill=true})

--@ chunk 2
print(wait(2*24*60))
local seam = pile{{"bone black",2},{"bone brown",0.6}}
local lit = pile{{"yellow ochre",1.1},{"raw sienna",0.6},{"lead white",0.6}}
local gr = pile{{"bone black",1.6},{"ultramarine ash",0.6}}
local grL = pile{{"lead white",1.2},{"ultramarine ash",0.6},{"raw sienna",0.3}}
-- point on face f at offset u in [-1,1] across the face, at depth z
function fp(f, u, z)
  local x0, x1, y0, y1 = sq(z)
  if f == "B" then return {lerp(x0,x1,(u+1)/2), y1} elseif f == "T" then return {lerp(x0,x1,(u+1)/2), y0}
  elseif f == "L" then return {x0, lerp(y0,y1,(u+1)/2)} else return {x1, lerp(y0,y1,(u+1)/2)} end
end
local function role(f, z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then return sg[3][f] end end; return "wall" end
-- longitudinal seams on every face, continuous through both portal seams: the geometry is consistent
for _,f in ipairs({"B","R","T","L"}) do
  for _,u in ipairs({-0.75,-0.5,-0.25,0,0.25,0.5,0.75}) do
    local zs = {0.05, 0.5, 1.2, 2.2, 3.6, SEAM1, 7, 9.5, SEAM2, 17, 23, 31, ZEND}
    for i=1,#zs-1 do
      local a, b = fp(f, u, zs[i]), fp(f, u, zs[i+1])
      local r = role(f, (zs[i]+zs[i+1])/2)
      local s = S(zs[i])
      ST({a,b}, (r == "floor") and gr or seam, math.max(0.8, ((r == "floor") and 3 or 4)*s), {0.9,0.9}, 1.0)
    end
  end
end
-- transverse joints: wall plates every 1.0 depth, floor grating bars every 0.35, all four faces
local z = 0.15
while z < ZEND do
  for _,f in ipairs({"B","R","T","L"}) do
    local r = role(f, z); local s = S(z)
    if r == "floor" then
      ST({fp(f,-1,z), fp(f,1,z)}, gr, math.max(0.8, 3*s), {0.9,0.9}, 1.0)
    elseif math.floor(z*3 + 0.5) % 3 == 0 then
      ST({fp(f,-1,z), fp(f,1,z)}, seam, math.max(0.8, 4*s), {0.9,0.9}, 1.0)
      local zz = z + 0.02
      ST({fp(f,-1,zz), fp(f,1,zz)}, lit, math.max(0.6, 1.6*s), {0.7,0.7}, 0.8)
    end
  end
  z = z + 0.33 * (1 + 0.25*z)
end

--@ chunk 3
print(wait(2*24*60))
local chain = pile{{"bone black",2},{"bone brown",0.6}}
local brz = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.5}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local core = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local pool = pile{{"raw sienna",1},{"yellow ochre",0.7},{"lead white",0.6}}
local OPP = {T="B", B="T", L="R", R="L"}
local function ceilOf(z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then for f,r in pairs(sg[3]) do if r == "ceil" then return f end end end end end
for _,z in ipairs({1.1, 2.6, 4.1, 6.5, 8.6, 11.0, 15.5, 20, 26, 33}) do
  local f = ceilOf(z); local fl = OPP[f]; local s = S(z)
  local top = fp(f, 0, z); local bot = fp(fl, 0, z)
  local L = 0.28
  local hang = {lerp(top[1], bot[1], L), lerp(top[2], bot[2], L)}
  ST({top, hang}, chain, math.max(0.8, 3*s), {0.9,0.9}, 1.0)
  local dx, dy = bot[1]-top[1], bot[2]-top[2]; local n = math.sqrt(dx*dx+dy*dy); dx, dy = dx/n, dy/n
  local px, py = -dy, dx
  local r = math.max(1.5, 26*s)
  local cage = {{hang[1]+px*r*0.6, hang[2]+py*r*0.6},{hang[1]+px*r*0.5+dx*r*1.4, hang[2]+py*r*0.5+dy*r*1.4},{hang[1]-px*r*0.5+dx*r*1.4, hang[2]-py*r*0.5+dy*r*1.4},{hang[1]-px*r*0.6, hang[2]-py*r*0.6}}
  ST({{hang[1]+dx*r*0.7, hang[2]+dy*r*0.7},{hang[1]+dx*r*0.71, hang[2]+dy*r*0.71}}, amber, r*1.0, {1,1}, 1.0)
  ST({{hang[1]+dx*r*0.7, hang[2]+dy*r*0.7},{hang[1]+dx*r*0.71, hang[2]+dy*r*0.71}}, core, r*0.45, {1,1}, 1.0)
  ST({cage[1],cage[2]}, brz, math.max(0.8, 3*s), {0.9,0.9}); ST({cage[4],cage[3]}, brz, math.max(0.8, 3*s), {0.9,0.9}); ST({cage[2],cage[3]}, brz, math.max(0.8, 4*s), {0.9,0.9}); ST({cage[1],cage[4]}, brz, math.max(0.8, 5*s), {0.9,0.9})
  -- a warm pool on the floor face beneath it, in short strokes across the face
  for k=-3,3 do local zz = z + k*0.12*(1+0.3*z)
    ST({fp(fl, -0.45 + math.abs(k)*0.08, zz), fp(fl, 0.45 - math.abs(k)*0.08, zz)}, pool, math.max(0.8, 7*S(zz)), {0.6 - math.abs(k)*0.12, 0.6 - math.abs(k)*0.12}, 0.7)
  end
end

--@ chunk 4
print(wait(2*24*60))
local vio = pile{{"cobalt violet",1.2},{"ultramarine blue",0.5},{"lead white",1.2}}
local vioH = pile{{"lead white",2},{"cobalt violet",0.7},{"zinc white",1}}
local vioD = pile{{"cobalt violet",1},{"ultramarine blue",1},{"bone black",0.6}}
local core = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
-- the portal seams: where the corridor is glued to itself rotated, a violet line traces the joint all round, and a thin vertical slit hangs in the air
for _,z in ipairs({SEAM1, SEAM2}) do
  local x0, x1, y0, y1 = sq(z); local s = S(z)
  local loop = {{x0,y0},{x1,y0},{x1,y1},{x0,y1},{x0,y0}}
  for i=1,4 do ST({loop[i], loop[i+1]}, vioD, math.max(2, 9*s), {0.9,0.9}, 1.0); ST({loop[i], loop[i+1]}, vio, math.max(1.2, 4.5*s), {0.9,0.9}, 1.0); ST({loop[i], loop[i+1]}, vioH, math.max(0.8, 1.6*s), {0.9,0.9}, 1.0) end
  local cx = VP[1] + (x1-x0)*0.12
  for k=1,3 do local jx = cx + rand(-1.5,1.5)*s*4
    ST({{jx, y0 + 4},{jx + rand(-2,2), lerp(y0,y1,0.5)},{jx, y1 - 4}}, (k == 3) and vioH or vio, math.max(0.8, (5-k)*1.4*s), {0.4,0.4}, 1.0) end
  -- shimmer: short horizontal ticks where the slit meets the plates
  for k=1,8 do local y = lerp(y0,y1,k/9); ST({{cx - 10*s, y},{cx + 10*s, y}}, vio, math.max(0.6, 1.6*s), {0.7,0.0}, 0.7) end
end
-- lamps restated larger and brighter, so the sideways and upside-down ones read
local OPP = {T="B", B="T", L="R", R="L"}
local function ceilOf(z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then for f,r in pairs(sg[3]) do if r == "ceil" then return f end end end end end
for _,z in ipairs({2.6, 4.1, 6.5, 8.6, 11.0, 15.5, 20, 26, 33}) do
  local f = ceilOf(z); local fl = OPP[f]; local s = S(z)
  local top = fp(f, 0, z); local bot = fp(fl, 0, z)
  local hang = {lerp(top[1], bot[1], 0.28), lerp(top[2], bot[2], 0.28)}
  local dx, dy = bot[1]-top[1], bot[2]-top[2]; local n = math.sqrt(dx*dx+dy*dy); dx, dy = dx/n, dy/n
  local r = math.max(2, 26*s)
  local c = {hang[1]+dx*r*0.7, hang[2]+dy*r*0.7}
  ST({c, {c[1]+0.01, c[2]+0.01}}, amber, r*1.5, {1,1}, 1.0)
  ST({c, {c[1]+0.01, c[2]+0.01}}, core, r*0.8, {1,1}, 1.0)
  for k=1,8 do local a = k/8*2*math.pi; ST({{c[1]+math.cos(a)*r*0.9, c[2]+math.sin(a)*r*0.9},{c[1]+math.cos(a)*r*2.0, c[2]+math.sin(a)*r*2.0}}, amber, math.max(0.6, r*0.12), {0.5,0}, 0.6) end
end

--@ chunk 5
print(wait(2*24*60))
local vio = pile{{"cobalt violet",1.2},{"ultramarine blue",0.5},{"lead white",1.2}}
local vioH = pile{{"lead white",2},{"cobalt violet",0.7},{"zinc white",1}}
-- the seams glow: violet light spilling a little onto the plates either side of each joint, in short strokes across it
for _,z in ipairs({SEAM1, SEAM2}) do
  for _,f in ipairs({"B","R","T","L"}) do
    for k=0,24 do local u = -1 + k/12
      if u <= 1 then
        local a, b = fp(f, u, z - 0.25*(1+0.2*z)), fp(f, u, z + 0.25*(1+0.2*z))
        ST({a, fp(f, u, z)}, vio, math.max(0.8, 3*S(z)), {0.0,0.7}, 0.7); ST({fp(f, u, z), b}, vio, math.max(0.8, 3*S(z)), {0.7,0.0}, 0.7)
      end
    end
  end
  local x0, x1, y0, y1 = sq(z); local s = S(z)
  local loop = {{x0,y0},{x1,y0},{x1,y1},{x0,y1},{x0,y0}}
  for i=1,4 do ST({loop[i], loop[i+1]}, vioH, math.max(1, 3*s), {0.9,0.9}, 1.0) end
end
-- the Commando, small, at the near end on the floor grating, back to us, looking down it
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"bone brown",0.5}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.5}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local crossp = pile{{"lead white",2},{"ultramarine ash",0.5}}
local z = 3.3; local x0, x1, y0, y1 = sq(z)
local cx, fy = VP[1] - 40, y1 - 2
local H = 95
local function P(pts, p) work(poly(pts), {hand="detail", pile=p, coverage=4.5, fill=true}) end
P({{cx-0.13*H,fy},{cx-0.10*H,fy-0.45*H},{cx-0.17*H,fy-0.78*H},{cx-0.10*H,fy-0.88*H},{cx+0.10*H,fy-0.88*H},{cx+0.17*H,fy-0.78*H},{cx+0.10*H,fy-0.45*H},{cx+0.13*H,fy},{cx+0.04*H,fy},{cx,fy-0.42*H},{cx-0.04*H,fy}}, dk)
work(ellipse(cx, fy-0.95*H, 0.075*H, 0.085*H), {hand="detail", pile=dk, coverage=4.5, fill=true})
P({{cx-0.15*H,fy-0.78*H},{cx+0.15*H,fy-0.78*H},{cx+0.14*H,fy-0.36*H},{cx-0.14*H,fy-0.36*H}}, tab)
ST({{cx,fy-0.74*H},{cx,fy-0.44*H}}, crossp, 3, {1,1}); ST({{cx-0.09*H,fy-0.64*H},{cx+0.09*H,fy-0.64*H}}, crossp, 3, {1,1})
ST({{cx-0.07*H,fy-1.02*H},{cx+0.06*H,fy-1.02*H}}, litH, 2, {0.8,0.5}); ST({{cx-0.17*H,fy-0.8*H},{cx-0.09*H,fy-0.88*H},{cx+0.09*H,fy-0.88*H},{cx+0.17*H,fy-0.8*H}}, litH, 1.8, {0.7,0.7})
ST({{cx+0.15*H,fy-0.70*H},{cx+0.32*H,fy-0.66*H}}, dk, 0.1*H, {1,0.8})
ST({{cx-0.13*H,fy+1},{cx-0.30*H,fy+14}}, pile{{"bone black",2}}, 8, {0.6,0.1}, 0.8)

--@ chunk 6
print(wait(2*24*60))
-- 1. seams: clear the tick band on every face back to that face's material, then restate the plate lines through it
local P = {
 floor = {pile{{"bone black",1},{"bone brown",1.2},{"ultramarine ash",0.5},{"lead white",0.25}}, pile{{"bone brown",1.2},{"ultramarine ash",0.5},{"raw sienna",0.5},{"lead white",0.35}}},
 wall  = {pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.4}}, pile{{"raw sienna",1.2},{"burnt sienna",0.8},{"yellow ochre",0.3},{"lead white",0.3}}},
 ceil  = {pile{{"bone black",1.6},{"bone brown",1.2},{"burnt sienna",0.3}}, pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.4}}} }
local function role(f, z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then return sg[3][f] end end; return "wall" end
for _,z in ipairs({SEAM1, SEAM2}) do
  local dz = 0.3*(1+0.2*z)
  for _,f in ipairs({"B","R","T","L"}) do
    for _,side in ipairs({{z-dz, z}, {z, z+dz}}) do
      local m = face(f, side[1], side[2])
      local r = role(f, (side[1]+side[2])/2)
      work(m, {hand="body", tool="filbert 2", pile=P[r][2], coverage=4, fill=true, clip=m, angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={3,10}, load=1.0})
    end
  end
end

--@ chunk 7
print(wait(2*24*60))
local seam = pile{{"bone black",2},{"bone brown",0.6}}
local gr = pile{{"bone black",1.6},{"ultramarine ash",0.6}}
local function role(f, z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then return sg[3][f] end end; return "wall" end
-- plate lines carried straight through the joints
for _,z in ipairs({SEAM1, SEAM2}) do
  local dz = 0.32*(1+0.2*z)
  for _,f in ipairs({"B","R","T","L"}) do
    for _,u in ipairs({-0.75,-0.5,-0.25,0,0.25,0.5,0.75}) do
      ST({fp(f,u,z-dz), fp(f,u,z)}, (role(f,z-0.01) == "floor") and gr or seam, math.max(0.8, 3.5*S(z)), {0.9,0.9}, 1.0)
      ST({fp(f,u,z), fp(f,u,z+dz)}, (role(f,z+0.01) == "floor") and gr or seam, math.max(0.8, 3.5*S(z)), {0.9,0.9}, 1.0)
    end
  end
  -- the seam itself: one crisp violet line round the section, with a faint glow either side
  local x0, x1, y0, y1 = sq(z); local s = S(z)
  local loop = {{x0,y0},{x1,y0},{x1,y1},{x0,y1},{x0,y0}}
  local glow = pile{{"cobalt violet",1},{"lead white",1.2},{"ultramarine blue",0.3}, medium=0.3}
  local crisp = pile{{"zinc white",2},{"lead white",1},{"cobalt violet",0.5}}
  for i=1,4 do ST({loop[i], loop[i+1]}, glow, math.max(2, 7*s), {0.35,0.35}, 0.5) end
  for i=1,4 do ST({loop[i], loop[i+1]}, crisp, math.max(0.8, 2.2*s), {1,1}, 1.0) end
  local cx = VP[1] + (x1-x0)*0.12
  ST({{cx, y0+2},{cx, y1-2}}, glow, math.max(2, 6*s), {0.3,0.3}, 0.5)
  ST({{cx, y0+2},{cx, y1-2}}, crisp, math.max(0.8, 1.8*s), {1,1}, 1.0)
end

--@ chunk 8
print(wait(2*24*60))
local chain = pile{{"bone black",2},{"bone brown",0.6}}
local brz = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.5}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local core = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local pool = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.7}}
local OPP = {T="B", B="T", L="R", R="L"}
local function ceilOf(z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then for f,r in pairs(sg[3]) do if r == "ceil" then return f end end end end end
LAMPS = {{3.4,-0.35},{4.4,0.3},{6.0,-0.3},{8.0,0.3},{10.5,-0.2},{15,0.25},{19,-0.25}}
for _,L in ipairs(LAMPS) do
  local z, u = L[1], L[2]
  local f = ceilOf(z); local fl = OPP[f]; local s = S(z)
  -- the floor face's u axis runs the same way as the ceiling's for opposite faces
  local top = fp(f, u, z); local bot = fp(fl, u, z)
  local hang = {lerp(top[1], bot[1], 0.24), lerp(top[2], bot[2], 0.24)}
  local dx, dy = bot[1]-top[1], bot[2]-top[2]; local n = math.sqrt(dx*dx+dy*dy); dx, dy = dx/n, dy/n
  local px, py = -dy, dx
  local r = math.max(3, 46*s)
  ST({top, hang}, chain, math.max(1, 4*s), {0.9,0.9}, 1.0)
  local c = {hang[1]+dx*r*0.9, hang[2]+dy*r*0.9}
  ST({c, {c[1]+dx*0.1, c[2]+dy*0.1}}, amber, r*1.15, {1,1}, 1.0)
  ST({c, {c[1]+dx*0.1, c[2]+dy*0.1}}, core, r*0.55, {1,1}, 1.0)
  -- cage: two side bars, a cap toward the chain, a bottom ring toward the floor
  local w = r*0.62
  ST({{hang[1]+px*w*0.6, hang[2]+py*w*0.6},{hang[1]-px*w*0.6, hang[2]-py*w*0.6}}, brz, math.max(1, 0.22*r), {1,1}, 1.0)
  ST({{hang[1]+px*w, hang[2]+py*w},{c[1]+px*w+dx*r*0.6, c[2]+py*w+dy*r*0.6}}, brzL, math.max(0.8, 0.12*r), {0.9,0.9}, 1.0)
  ST({{hang[1]-px*w, hang[2]-py*w},{c[1]-px*w+dx*r*0.6, c[2]-py*w+dy*r*0.6}}, brz, math.max(0.8, 0.12*r), {0.9,0.9}, 1.0)
  ST({{c[1]+px*w+dx*r*0.6, c[2]+py*w+dy*r*0.6},{c[1]-px*w+dx*r*0.6, c[2]-py*w+dy*r*0.6}}, brz, math.max(0.8, 0.18*r), {1,1}, 1.0)
  -- its warm pool on that segment's floor, in short strokes across the face
  for k=-4,4 do local zz = z + k*0.1*(1+0.3*z)
    local w2 = 0.32 - math.abs(k)*0.05
    ST({fp(fl, u - w2, zz), fp(fl, u + w2, zz)}, pool, math.max(1, 9*S(zz)), {0.75 - math.abs(k)*0.14, 0.75 - math.abs(k)*0.14}, 0.8)
  end
end

--@ chunk 9
print(wait(2*24*60))
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local core = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local brz = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.5}}
local OPP = {T="B", B="T", L="R", R="L"}
local function ceilOf(z) for _,sg in ipairs(SEGS) do if z >= sg[1] and z < sg[2] then for f,r in pairs(sg[3]) do if r == "ceil" then return f end end end end end
-- the lamp bodies: an amber glass inside each cage, a hot core, a halo of short warm strokes
for _,L in ipairs(LAMPS) do
  local z, u = L[1], L[2]
  local f = ceilOf(z); local fl = OPP[f]; local s = S(z)
  local top = fp(f, u, z); local bot = fp(fl, u, z)
  local hang = {lerp(top[1], bot[1], 0.24), lerp(top[2], bot[2], 0.24)}
  local dx, dy = bot[1]-top[1], bot[2]-top[2]; local n = math.sqrt(dx*dx+dy*dy); dx, dy = dx/n, dy/n
  local r = math.max(3, 46*s)
  local c = {hang[1]+dx*r*0.9, hang[2]+dy*r*0.9}
  local rx = math.abs(dx) > 0.5 and r*0.55 or r*0.4; local ry = math.abs(dx) > 0.5 and r*0.4 or r*0.55
  work(ellipse(c[1], c[2], rx, ry), {hand="detail", pile=amber, coverage=4.5, fill=true})
  work(ellipse(c[1], c[2], rx*0.5, ry*0.5), {hand="detail", pile=core, coverage=4.5, fill=true})
  for k=1,12 do local a = k/12*2*math.pi; ST({{c[1]+math.cos(a)*r*0.6, c[2]+math.sin(a)*r*0.6},{c[1]+math.cos(a)*r*1.3, c[2]+math.sin(a)*r*1.3}}, amber, math.max(0.8, r*0.08), {0.6,0}, 0.6) end
end
-- a bronze crate standing on each segment's floor: upright, on the right wall, on the ceiling
local cD = pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.5}}
local cM = pile{{"raw sienna",1.2},{"burnt sienna",0.8},{"bone brown",0.4}}
local cL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local function crate(fl, z, u0, u1, h, dz)
  -- fl: floor face; front face at depth z rising h (fraction of section) toward the opposite face; top face receding dz
  local opp = OPP[fl]
  local function q(u, hh, zz) local a = fp(fl, u, zz); local b = fp(opp, u, zz); return {lerp(a[1],b[1],hh), lerp(a[2],b[2],hh)} end
  local front = {q(u0,0,z), q(u1,0,z), q(u1,h,z), q(u0,h,z)}
  local topf = {q(u0,h,z), q(u1,h,z), q(u1,h,z+dz), q(u0,h,z+dz)}
  local sidef = {q(u1,0,z), q(u1,0,z+dz), q(u1,h,z+dz), q(u1,h,z)}
  work(poly(sidef), {hand="detail", pile=cD, coverage=4.5, fill=true})
  work(poly(topf), {hand="detail", pile=cL, coverage=4.5, fill=true})
  work(poly(front), {hand="detail", pile=cM, coverage=4.5, fill=true})
  local s = S(z)
  ST({front[1],front[2],front[3],front[4],front[1]}, pile{{"bone black",2}}, math.max(1, 4*s), {0.9,0.9})
  ST({front[1],front[3]}, cD, math.max(0.8, 3*s), {0.8,0.8}); ST({front[2],front[4]}, cD, math.max(0.8, 3*s), {0.8,0.8})
  ST({topf[1],topf[2]}, pile{{"lead white",2},{"Indian yellow",0.5}}, math.max(0.8, 2.5*s), {0.9,0.9})
end
crate("B", 3.6, 0.25, 0.6, 0.16, 0.5)
crate("R", 7.2, -0.55, -0.15, 0.18, 0.8)
crate("T", 16, 0.15, 0.55, 0.2, 1.5)

--@ chunk 10
print(wait(2*24*60))
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"bone brown",0.5}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.5}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local crossp = pile{{"lead white",2},{"ultramarine ash",0.5}}
local x0, x1, y0, y1 = sq(3.3)
local cx, fy = VP[1] - 40, y1 - 2
local H = 95
local function P(pts, p) work(poly(pts), {hand="detail", pile=p, coverage=5, fill=true}) end
-- his shadow on the grating, thrown toward us and left by the lamps ahead of him
local shd = pile{{"bone black",2},{"ultramarine blue",0.4}}
work(poly({{cx-0.12*H,fy},{cx+0.12*H,fy},{cx-0.05*H,fy+0.32*H},{cx-0.38*H,fy+0.34*H}}), {hand="body", tool="filbert 2", pile=shd, coverage=3.5, fill=true, clip=true, angle=2.2, length={4,12}, load=0.9})
P({{cx-0.13*H,fy},{cx-0.10*H,fy-0.45*H},{cx-0.17*H,fy-0.78*H},{cx-0.10*H,fy-0.88*H},{cx+0.10*H,fy-0.88*H},{cx+0.17*H,fy-0.78*H},{cx+0.10*H,fy-0.45*H},{cx+0.13*H,fy},{cx+0.04*H,fy},{cx,fy-0.42*H},{cx-0.04*H,fy}}, dk)
work(ellipse(cx, fy-0.95*H, 0.075*H, 0.085*H), {hand="detail", pile=dk, coverage=5, fill=true})
P({{cx-0.15*H,fy-0.78*H},{cx+0.15*H,fy-0.78*H},{cx+0.14*H,fy-0.36*H},{cx-0.14*H,fy-0.36*H}}, tab)
ST({{cx,fy-0.74*H},{cx,fy-0.44*H}}, crossp, 3, {1,1}); ST({{cx-0.09*H,fy-0.64*H},{cx+0.09*H,fy-0.64*H}}, crossp, 3, {1,1})
ST({{cx-0.07*H,fy-1.02*H},{cx+0.06*H,fy-1.02*H}}, litH, 2, {0.8,0.5}); ST({{cx-0.17*H,fy-0.8*H},{cx-0.09*H,fy-0.88*H},{cx+0.09*H,fy-0.88*H},{cx+0.17*H,fy-0.8*H}}, litH, 1.8, {0.7,0.7})

--@ chunk 11
print(wait(4*24*60))
local crossp = pile{{"lead white",2},{"ultramarine ash",0.5}}
local x0, x1, y0, y1 = sq(3.3); local cx, fy, H = VP[1] - 40, y1 - 2, 95
ST({{cx,fy-0.74*H},{cx,fy-0.44*H}}, crossp, 3.2, {1,1}); ST({{cx-0.09*H,fy-0.64*H},{cx+0.09*H,fy-0.64*H}}, crossp, 3.2, {1,1})
