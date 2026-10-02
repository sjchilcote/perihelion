-- easel session "mirror_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=2929,
  ground={{pile={{"bone black",1.4},{"bone brown",1.4},{"burnt sienna",0.4},{"lead white",0.1}}, um=90, apply="knife", texture=0.35}}}
VP = {500,281}; H0 = 270; RR = 0.46; DA = 0.14; NR = 8
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.3}, clip=clip})
end
-- square k (continuous t): corners in order TL, TR, BR, BL
function corner(t, i)
  local h = H0 * RR^t; local a = DA * t
  local base = ({{-1,-1},{1,-1},{1,1},{-1,1}})[i]
  local x, y = base[1]*h*1.15, base[2]*h
  return {VP[1] + x*math.cos(a) - y*math.sin(a), VP[2] + x*math.sin(a) + y*math.cos(a)}
end
-- a point on face f (1 top, 2 right, 3 bottom, 4 left) at across-offset u (0..1) and depth t
function fpt(f, u, t) local a, b = corner(t, f), corner(t, f % 4 + 1); return {lerp(a[1],b[1],u), lerp(a[2],b[2],u)} end
function facem(f, t0, t1) return poly({fpt(f,0,t0), fpt(f,1,t0), fpt(f,1,t1), fpt(f,0,t1)}) end
-- per copy, warm bronze turning violet; per face, floor (3) as grating, ceiling (1) darkest
local function mix(k, f)
  local c = k/(NR-1)
  local warm = 1 - c
  local face = ({0.45, 0.85, 0.65, 0.75})[f]
  if f == 3 then return pile{{"bone brown",1.2*warm+0.3},{"ultramarine ash",0.5+0.6*c},{"cobalt violet",0.1+0.9*c},{"lead white",0.2+0.4*c}} end
  return pile{{"raw sienna",(1.4*warm)*face+0.05},{"burnt sienna",0.8*warm*face+0.05},{"bone brown",0.8*(1-face)+0.3},{"cobalt violet",1.2*c+0.02},{"ultramarine blue",0.4*c+0.02},{"lead white",0.15+0.5*c*face}}
end
for k=0,NR-1 do
  for f=1,4 do
    local m = facem(f, k, k+1)
    work(m, {hand="body", tool={kind="filbert", width=math.max(1.5, 9*RR^k)}, pile=mix(k,f), coverage=3.2, fill=true, clip=m,
      angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={math.max(3,30*RR^k), math.max(6,80*RR^k)}, load=1.0})
  end
end

--@ chunk 2
print(wait(2*24*60))
local function col(k, p) local c = k/(NR-1)
  if p == "dark" then return pile{{"bone black",1.4},{"bone brown",1.2*(1-c)+0.1},{"ultramarine blue",0.6*c+0.02},{"cobalt violet",0.4*c+0.02}} end
  if p == "lit" then return pile{{"lead white",1},{"yellow ochre",0.9*(1-c)+0.02},{"cobalt violet",0.8*c+0.02},{"raw sienna",0.4*(1-c)+0.02}} end
  return pile{{"bone black",1.2},{"bone brown",0.8},{"ultramarine ash",0.4}}
end
-- longitudinal plate seams and grating lines: continuous through every copy
for f=1,4 do
  for _,u in ipairs({0.125,0.25,0.375,0.5,0.625,0.75,0.875}) do
    for k=0,NR-1 do
      local pts = {}; for j=0,6 do pts[#pts+1] = fpt(f, u, k + j/6) end
      ST(pts, col(k,"seam"), math.max(0.8, ((f == 3) and 3 or 4)*RR^k), {0.9,0.9}, 1.0)
    end
  end
end
-- transverse joints and grating bars inside each room
for k=0,NR-1 do
  for j=1,(k < 3) and 7 or 4 do local t = k + j/((k < 3) and 8 or 5)
    for f=1,4 do
      if f == 3 or j % 2 == 0 then ST({fpt(f,0,t), fpt(f,1,t)}, col(k,"seam"), math.max(0.8, ((f==3) and 2.5 or 3.5)*RR^t), {0.9,0.9}, 1.0) end
    end
  end
end
-- each doorway: a thick dark jamb round the square with a lit inner edge, so every copy reads as a room seen through a door
for k=1,NR do
  local h = H0*RR^k
  local loop = {corner(k,1), corner(k,2), corner(k,3), corner(k,4), corner(k,1)}
  local inner = {}; for i=1,5 do inner[i] = {lerp(loop[i][1], VP[1], 0.09), lerp(loop[i][2], VP[2], 0.09)} end
  for i=1,4 do
    ST({loop[i], loop[i+1]}, col(k-1,"dark"), math.max(1, h*0.16), {1,1}, 1.0)
    ST({inner[i], inner[i+1]}, col(k-1,"lit"), math.max(0.6, h*0.025), {0.9,0.9}, 1.0)
  end
end
-- the near doorway too
local loop = {corner(0,1), corner(0,2), corner(0,3), corner(0,4), corner(0,1)}
for i=1,4 do ST({loop[i], loop[i+1]}, col(0,"dark"), 26, {1,1}, 1.0) end

--@ chunk 3
print(wait(2*24*60))
-- the Commando in every doorway, back to us, each copy turned with its room and colder
local function fig(k, scale)
  local c = k/(NR-1)
  local dk = pile{{"bone black",1.8},{"ultramarine blue",0.3+0.5*c},{"bone brown",0.6*(1-c)+0.05}}
  local tab = pile{{"red earth",1*(1-c)+0.05},{"vermilion",0.5*(1-c)+0.02},{"cobalt violet",0.9*c+0.02},{"bone black",0.4}}
  local lit = pile{{"lead white",2},{"yellow ochre",0.6*(1-c)+0.02},{"cobalt violet",0.6*c+0.02}}
  local h = H0*RR^k
  local a = DA*k
  local base = fpt(3, 0.5, k + 0.06)
  local H = h*0.62*scale
  local function T(px, py) return {base[1] + px*math.cos(a) - py*math.sin(a), base[2] + px*math.sin(a) + py*math.cos(a)} end
  local function P(list, p) local q = {}; for i,v in ipairs(list) do q[i] = T(v[1]*H, v[2]*H) end; work(poly(q), {hand="detail", pile=p, coverage=5, fill=true}) end
  P({{-0.13,0},{-0.10,-0.45},{-0.17,-0.78},{-0.10,-0.88},{0.10,-0.88},{0.17,-0.78},{0.10,-0.45},{0.13,0},{0.04,0},{0,-0.42},{-0.04,0}}, dk)
  P({{-0.07,-0.88},{0.07,-0.88},{0.08,-0.96},{0,-1.03},{-0.08,-0.96}}, dk)
  P({{-0.15,-0.78},{0.15,-0.78},{0.14,-0.36},{-0.14,-0.36}}, tab)
  if H > 12 then
    ST({T(0,-0.74*H), T(0,-0.44*H)}, lit, math.max(0.8, H*0.035), {1,1}); ST({T(-0.09*H,-0.64*H), T(0.09*H,-0.64*H)}, lit, math.max(0.8, H*0.035), {1,1})
    ST({T(-0.17*H,-0.8*H), T(-0.09*H,-0.88*H), T(0.09*H,-0.88*H), T(0.17*H,-0.8*H)}, lit, math.max(0.6, H*0.02), {0.8,0.8})
  end
end
for k=NR-2,1,-1 do fig(k, 1.0) end
fig(0, 0.75)

--@ chunk 4
print(wait(2*24*60))
-- each copy colder: repaint the walls and ceilings of rooms 2.. in a ramp from bronze to violet, then restate their lines and jambs
local ramp = {
 [2] = {pile{{"raw sienna",1},{"burnt sienna",0.6},{"cobalt violet",0.4},{"lead white",0.25}}, pile{{"bone brown",1},{"burnt sienna",0.5},{"cobalt violet",0.4},{"lead white",0.15}}},
 [3] = {pile{{"raw sienna",0.6},{"cobalt violet",0.8},{"burnt sienna",0.3},{"lead white",0.4}}, pile{{"bone brown",0.8},{"cobalt violet",0.7},{"ultramarine blue",0.2},{"lead white",0.2}}},
 [4] = {pile{{"cobalt violet",1},{"raw sienna",0.3},{"ultramarine ash",0.4},{"lead white",0.6}}, pile{{"cobalt violet",0.8},{"ultramarine blue",0.4},{"bone brown",0.4},{"lead white",0.3}}},
 [5] = {pile{{"cobalt violet",1},{"ultramarine ash",0.6},{"lead white",0.9}}, pile{{"cobalt violet",0.8},{"ultramarine blue",0.6},{"lead white",0.5}}},
 [6] = {pile{{"cobalt violet",0.8},{"ultramarine ash",0.6},{"lead white",1.3}}, pile{{"cobalt violet",0.8},{"ultramarine blue",0.5},{"lead white",0.9}}},
 [7] = {pile{{"cobalt violet",0.6},{"lead white",1.6},{"ultramarine ash",0.4}}, pile{{"cobalt violet",0.7},{"lead white",1.2},{"ultramarine blue",0.3}}} }
for k=2,NR-1 do
  for _,f in ipairs({1,2,4}) do
    local m = facem(f, k + 0.05, k+1)
    work(m, {hand="body", tool={kind="filbert", width=math.max(1.2, 9*RR^k)}, pile=ramp[k][(f == 1) and 2 or 1], coverage=3.6, fill=true, clip=m,
      angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={math.max(2,30*RR^k), math.max(4,80*RR^k)}, load=1.0})
  end
end

--@ chunk 5
print(wait(2*24*60))
local seamP = pile{{"bone black",1.4},{"ultramarine blue",0.6},{"cobalt violet",0.3}}
for f=1,4 do if f ~= 3 then
  for _,u in ipairs({0.125,0.25,0.375,0.5,0.625,0.75,0.875}) do
    for k=2,NR-1 do local pts = {}; for j=0,6 do pts[#pts+1] = fpt(f, u, k + j/6) end; ST(pts, seamP, math.max(0.8, 4*RR^k), {0.9,0.9}, 1.0) end
  end
  for k=2,NR-1 do for j=2,4,2 do local t = k + j/5; ST({fpt(f,0,t), fpt(f,1,t)}, seamP, math.max(0.8, 3.5*RR^t), {0.9,0.9}, 1.0) end end
end end
-- jambs again, every side reloaded so they do not run dry
for k=1,NR do
  local c = k/NR
  local dk = pile{{"bone black",1.4},{"bone brown",1.2*(1-c)+0.05},{"ultramarine blue",0.6*c+0.02},{"cobalt violet",0.5*c+0.02}}
  local lit = pile{{"lead white",1.2},{"yellow ochre",0.9*(1-c)+0.02},{"cobalt violet",0.9*c+0.02}}
  local h = H0*RR^k
  local loop = {corner(k,1), corner(k,2), corner(k,3), corner(k,4), corner(k,1)}
  for i=1,4 do
    local a, b = loop[i], loop[i+1]
    for s=0,3 do local p0 = {lerp(a[1],b[1],s/4), lerp(a[2],b[2],s/4)}; local p1 = {lerp(a[1],b[1],(s+1.1)/4), lerp(a[2],b[2],(s+1.1)/4)}
      ST({p0, p1}, dk, math.max(1, h*0.16), {1,1}, 1.0) end
    local ia, ib = {lerp(a[1], VP[1], 0.09), lerp(a[2], VP[2], 0.09)}, {lerp(b[1], VP[1], 0.09), lerp(b[2], VP[2], 0.09)}
    ST({ia, ib}, lit, math.max(0.6, h*0.03), {0.9,0.9}, 1.0)
  end
end
