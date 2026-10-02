-- easel session "penrose": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=480, aspect=1, linen=18, seed=6262,
  ground={{pile={{"bone black",1.4},{"bone brown",1.2},{"cobalt violet",0.3},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
-- geometry only (no painting): prints bounds
local C, SN = math.cos(math.pi/6), 0.5
U = 48; T = 1; DH = 0.25; W = 3.2; BASE = -9
LEGS = {{1,0,9,{0,-1}}, {0,1,9,{1,0}}, {-1,0,3,{0,1}}, {0,-1,3,{-1,0}}}
STEPS = {}
local x, y, h = 0, 0, 0
for li,L in ipairs(LEGS) do
  for k=1,L[3] do
    STEPS[#STEPS+1] = {x=x, y=y, h=h, dx=L[1], dy=L[2], ox=L[4][1], oy=L[4][2], leg=li, k=k}
    x = x + L[1]*T; y = y + L[2]*T; h = h + DH
  end
end
OX, OY = 0, 0
function scr(x, y, h) return {OX + (x - y)*C*U, OY + (x + y)*SN*U - h*U} end
local mnx, mxx, mny, mxy = 1e9, -1e9, 1e9, -1e9
for _,s in ipairs(STEPS) do for _,p in ipairs({{s.x,s.y},{s.x+s.ox*W,s.y+s.oy*W}}) do
  local a = scr(p[1], p[2], s.h + DH); local b = scr(p[1], p[2], BASE)
  for _,q in ipairs({a,b}) do mnx = math.min(mnx,q[1]); mxx = math.max(mxx,q[1]); mny = math.min(mny,q[2]); mxy = math.max(mxy,q[2]) end end end
print(mnx, mxx, mny, mxy, x, y, h)

--@ chunk 2
U = 44; BASE = -4.5
local mnx, mxx, mny, mxy = 1e9, -1e9, 1e9, -1e9
OX, OY = 0, 0
for _,s in ipairs(STEPS) do for _,p in ipairs({{s.x,s.y},{s.x+s.ox*W,s.y+s.oy*W},{s.x+s.dx,s.y+s.dy}}) do
  for _,hh in ipairs({s.h + DH, BASE}) do local q = scr(p[1], p[2], hh)
    mnx = math.min(mnx,q[1]); mxx = math.max(mxx,q[1]); mny = math.min(mny,q[2]); mxy = math.max(mxy,q[2]) end end end
OX = 500 - (mnx+mxx)/2; OY = 500 - (mny+mxy)/2 + 20
print(mnx, mxx, mny, mxy, OX, OY)
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.2}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.9,0.9}, ramps={0.02,0.05}, clip=clip})
end
function fillq(a, b, c, d, p, maxw)
  local L = math.sqrt((d[1]-a[1])^2 + (d[2]-a[2])^2)
  local n = math.max(1, math.ceil(L / (maxw or 6)))
  local w = L / n * 1.5
  for j=0,n do local t = (j+0.5)/(n+1)
    ST({{lerp(a[1],d[1],t), lerp(a[2],d[2],t)}, {lerp(b[1],c[1],t), lerp(b[2],c[2],t)}}, p, math.max(1.2, w), {1,1}, 1.0)
  end
end
-- the light-well: a violet glow sunk inside the loop, deep below
local cx, cy = 0, 0; for _,s in ipairs(STEPS) do cx = cx + s.x; cy = cy + s.y end; cx, cy = cx/#STEPS, cy/#STEPS
WELLC = scr(cx + 1.6, cy + 1.6, BASE - 2)
local v1 = pile{{"cobalt violet",1.2},{"ultramarine blue",0.8},{"bone black",0.6}}
local v2 = pile{{"cobalt violet",1},{"ultramarine blue",0.4},{"lead white",1}}
local v3 = pile{{"lead white",2},{"cobalt violet",0.6},{"zinc white",1}}
work(ellipse(WELLC[1], WELLC[2], 250, 150), {hand="body", tool="filbert 8", pile=v1, coverage=3, fill=true, clip=true, angle=0, length={20,60}, load=1.0, edge="soft"})
work(ellipse(WELLC[1], WELLC[2], 140, 80), {hand="body", tool="filbert 6", pile=v2, coverage=3, fill=true, clip=true, angle=0, length={14,40}, load=1.0, edge="soft"})
work(ellipse(WELLC[1], WELLC[2], 55, 30), {hand="body", tool="filbert 4", pile=v3, coverage=3, fill=true, clip=true, angle=0, length={8,24}, load=1.0, edge="soft"})

--@ chunk 3
print(wait(2*24*60))
local topP = pile{{"raw sienna",1.2},{"yellow ochre",0.7},{"lead white",0.5}}
local xP = pile{{"bone brown",1.4},{"burnt sienna",0.8},{"bone black",0.5}}
local yP = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone brown",0.6}}
local edge = pile{{"bone black",2},{"bone brown",0.5}}
local lit = pile{{"lead white",1.6},{"yellow ochre",0.6},{"Indian yellow",0.2}}
local order = {}; for i,s in ipairs(STEPS) do order[i] = i end
table.sort(order, function(a, b) local A, B = STEPS[a], STEPS[b]
  local ka = A.x + A.y + 0.5*(A.dx + A.dy) + 0.5*W*(A.ox + A.oy); local kb = B.x + B.y + 0.5*(B.dx + B.dy) + 0.5*W*(B.ox + B.oy)
  if math.abs(ka - kb) > 1e-6 then return ka < kb end; return a < b end)
for _,i in ipairs(order) do
  local s = STEPS[i]
  local p0 = {s.x, s.y}; local p1 = {s.x + s.dx*T, s.y + s.dy*T}
  local p3 = {s.x + s.ox*W, s.y + s.oy*W}; local p2 = {p1[1] + s.ox*W, p1[2] + s.oy*W}
  local top = s.h + DH
  local function face(a, b, nx, ny)
    if nx + ny > 0 then
      local A, B, Bb, Ab = scr(a[1],a[2],top), scr(b[1],b[2],top), scr(b[1],b[2],BASE), scr(a[1],a[2],BASE)
      fillq(A, B, Bb, Ab, (nx > 0) and xP or yP, 7)
      ST({A, Ab}, edge, 1.6, {0.9,0.9}); ST({B, Bb}, edge, 1.6, {0.9,0.9})
    end
  end
  face(p0, p1, -s.ox, -s.oy); face(p3, p2, s.ox, s.oy); face(p0, p3, -s.dx, -s.dy); face(p1, p2, s.dx, s.dy)
  local A, B, Cc, D = scr(p0[1],p0[2],top), scr(p1[1],p1[2],top), scr(p2[1],p2[2],top), scr(p3[1],p3[2],top)
  fillq(A, D, Cc, B, topP, 5)
  ST({A, B, Cc, D, A}, edge, 1.8, {0.9,0.9})
  -- the nosing toward the climb direction catches the light
  ST({B, Cc}, lit, 1.6, {0.9,0.9})
end

--@ chunk 4
print(wait(3*24*60))
-- start over on dry paint: the dark ground back over everything, then a new well
local bg = pile{{"bone black",1.6},{"bone brown",1.2},{"cobalt violet",0.25}}
work(everywhere(), {hand="broad", pile=bg, coverage=3.4, fill=true, angle=0.3, load=1.0})

--@ chunk 5
print(wait(3*24*60))
local bg = pile{{"bone black",1.8},{"bone brown",1},{"cobalt violet",0.25}}
work(rect(180,250,520,470), {hand="body", tool="filbert 8", pile=bg, coverage=3.6, fill=true, clip=true, angle=0.3, length={20,60}, load=1.0})
-- the Penrose loop: legs +x 9, +y 7, -x 6, -y 4 (plan gap (3,3)), 26 steps climbing 3 in all: isometric hides the gap
local C, SN = math.cos(math.pi/6), 0.5
U = 52; DH = 3/26; SK = 1.4
LEGS = {{1,0,9},{0,1,7},{-1,0,6},{0,-1,4}}
STEPS = {}
local x, y, h = 0, 0, 0
for li,L in ipairs(LEGS) do for k=1,L[3] do
  STEPS[#STEPS+1] = {x=x, y=y, h=h, dx=L[1], dy=L[2], leg=li, k=k}
  x = x + L[1]; y = y + L[2]; h = h + DH
end end
OX, OY = 0, 0
function scr(px, py, ph) return {OX + (px - py)*C*U, OY + (px + py)*SN*U - ph*U} end
local mnx, mxx, mny, mxy = 1e9, -1e9, 1e9, -1e9
for _,s in ipairs(STEPS) do for _,dx in ipairs({0,1}) do for _,dy in ipairs({0,1}) do for _,hh in ipairs({s.h+DH, s.h-SK}) do
  local q = scr(s.x+dx, s.y+dy, hh); mnx = math.min(mnx,q[1]); mxx = math.max(mxx,q[1]); mny = math.min(mny,q[2]); mxy = math.max(mxy,q[2]) end end end end
OX = 500 - (mnx+mxx)/2; OY = 520 - (mny+mxy)/2
print(mnx, mxx, mny, mxy)
-- the well, inside the loop, far below
local wc = scr(4.5, 3.5, -7)
WELLC = wc
local v1 = pile{{"cobalt violet",1.2},{"ultramarine blue",0.8},{"bone black",0.6}}
local v2 = pile{{"cobalt violet",1},{"ultramarine blue",0.4},{"lead white",1}}
local v3 = pile{{"lead white",2},{"cobalt violet",0.6},{"zinc white",1}}
work(ellipse(wc[1], wc[2], 170, 95), {hand="body", tool="filbert 6", pile=v1, coverage=3.2, fill=true, clip=true, angle=0, length={14,40}, load=1.0, edge="soft"})
work(ellipse(wc[1], wc[2], 95, 52), {hand="body", tool="filbert 4", pile=v2, coverage=3.2, fill=true, clip=true, angle=0, length={10,30}, load=1.0, edge="soft"})
work(ellipse(wc[1], wc[2], 38, 20), {hand="body", tool="filbert 3", pile=v3, coverage=3.5, fill=true, clip=true, angle=0, length={6,16}, load=1.0})

--@ chunk 6
print(wait(3*24*60))
local topP = pile{{"raw sienna",1.1},{"yellow ochre",0.8},{"lead white",0.6}}
local topD = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.4}}
local xP = pile{{"bone brown",1.5},{"burnt sienna",0.7},{"bone black",0.6}}
local yP = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone brown",0.7}}
local edge = pile{{"bone black",2},{"bone brown",0.4}}
local lit = pile{{"lead white",1.6},{"yellow ochre",0.6},{"Indian yellow",0.2}}
local function fill4(A, B, Cc, D, p)
  -- strokes from edge AB to edge DC
  local L = math.max(math.sqrt((D[1]-A[1])^2+(D[2]-A[2])^2), math.sqrt((Cc[1]-B[1])^2+(Cc[2]-B[2])^2))
  local n = math.max(1, math.ceil(L/5)); local w = L/n*1.6
  for j=0,n do local t = j/n
    ST({{lerp(A[1],D[1],t), lerp(A[2],D[2],t)}, {lerp(B[1],Cc[1],t), lerp(B[2],Cc[2],t)}}, p, math.max(1.5, w), {1,1}, 1.0) end
end
local order = {}; for i in ipairs(STEPS) do order[i] = i end
table.sort(order, function(a, b) local A, B = STEPS[a], STEPS[b]
  local ka, kb = A.x + A.y, B.x + B.y
  if ka ~= kb then return ka < kb end; return A.h < B.h end)
for _,i in ipairs(order) do
  local s = STEPS[i]; local top = s.h + DH; local bot = s.h - SK
  local P = function(dx, dy, hh) return scr(s.x + dx, s.y + dy, hh) end
  -- +y face (front-left) and +x face (front-right)
  fill4(P(0,1,top), P(1,1,top), P(1,1,bot), P(0,1,bot), yP)
  fill4(P(1,0,top), P(1,1,top), P(1,1,bot), P(1,0,bot), xP)
  -- the tread
  local A, B, Cc, D = P(0,0,top), P(1,0,top), P(1,1,top), P(0,1,top)
  fill4(A, B, Cc, D, ((s.k % 2) == 0) and topD or topP)
  ST({A, B, Cc, D, A}, edge, 1.6, {0.9,0.9})
  ST({D, Cc}, lit, 1.3, {0.8,0.8}); ST({P(1,1,top), P(1,1,bot)}, edge, 1.4, {0.9,0.9})
end

--@ chunk 7
print(wait(3*24*60))
local bg = pile{{"bone black",1.8},{"bone brown",1},{"cobalt violet",0.3}}
work(everywhere(), {hand="broad", pile=bg, coverage=4.2, fill=true, angle=0.3, load=1.0})

--@ chunk 8
print(wait(4*24*60))
local bg = pile{{"bone black",1.8},{"bone brown",1},{"cobalt violet",0.3}}
work(rect(100,150,800,750), {hand="body", tool="filbert 10", pile=bg, coverage=3.6, fill=true, angle=-0.4, length={30,90}, load=1.0, edge="lost"})

--@ chunk 9
print(wait(4*24*60))
local C, SN = math.cos(math.pi/6), 0.5
U = 62; SK = 1.6
LEGS = {{1,0,7},{0,1,7},{-1,0,3},{0,-1,3}}
local N = 20; DH = 4/N
STEPS = {}
local x, y, h = 0, 0, 0
for li,L in ipairs(LEGS) do for k=1,L[3] do
  STEPS[#STEPS+1] = {x=x, y=y, h=h, dx=L[1], dy=L[2], leg=li, k=k}
  x = x + L[1]; y = y + L[2]; h = h + DH
end end
OX, OY = 0, 0
function scr(px, py, ph) return {OX + (px - py)*C*U, OY + (px + py)*SN*U - ph*U} end
local mnx, mxx, mny, mxy = 1e9, -1e9, 1e9, -1e9
for _,s in ipairs(STEPS) do for _,dx in ipairs({0,1}) do for _,dy in ipairs({0,1}) do for _,hh in ipairs({s.h+DH, s.h-SK}) do
  local q = scr(s.x+dx, s.y+dy, hh); mnx = math.min(mnx,q[1]); mxx = math.max(mxx,q[1]); mny = math.min(mny,q[2]); mxy = math.max(mxy,q[2]) end end end end
OX = 500 - (mnx+mxx)/2; OY = 500 - (mny+mxy)/2
print(mnx+OX, mxx+OX, mny+OY, mxy+OY)
-- the well: the loop's open centre, glowing violet from far below; painted first so the stair overlaps it
local hole = poly({scr(1,1,1.3), scr(7,1,1.6), scr(7,7,2.6), scr(4,7,2.8)})
HOLEC = scr(4.2, 4.2, 1.8)
local v1 = pile{{"cobalt violet",1.2},{"ultramarine blue",0.8},{"bone black",0.6}}
local v2 = pile{{"cobalt violet",1},{"ultramarine blue",0.4},{"lead white",1}}
local v3 = pile{{"lead white",2},{"cobalt violet",0.6},{"zinc white",1}}
work(ellipse(HOLEC[1], HOLEC[2], 190, 110), {hand="body", tool="filbert 5", pile=v1, coverage=3.6, fill=true, clip=true, angle=0, length={10,30}, load=1.0, edge="soft"})
work(ellipse(HOLEC[1], HOLEC[2]+10, 105, 58), {hand="body", tool="filbert 4", pile=v2, coverage=3.6, fill=true, clip=true, angle=0, length={8,24}, load=1.0, edge="soft"})
work(ellipse(HOLEC[1], HOLEC[2]+16, 42, 22), {hand="body", tool="filbert 3", pile=v3, coverage=4, fill=true, clip=true, angle=0, length={5,14}, load=1.0})

--@ chunk 10
print(wait(3*24*60))
local topP = pile{{"raw sienna",1.1},{"yellow ochre",0.9},{"lead white",0.7}}
local topD = pile{{"raw sienna",1.1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"lead white",0.3}}
local xP = pile{{"bone brown",1.5},{"burnt sienna",0.7},{"bone black",0.5}}
local yP = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone brown",0.5}}
local edge = pile{{"bone black",2},{"bone brown",0.4}}
local lit = pile{{"lead white",1.6},{"yellow ochre",0.6},{"Indian yellow",0.2}}
local order = {}; for i in ipairs(STEPS) do order[i] = i end
table.sort(order, function(a, b) local A, B = STEPS[a], STEPS[b]
  local ka, kb = A.x + A.y, B.x + B.y
  if ka ~= kb then return ka < kb end; return A.h < B.h end)
local function face(q, p, a) local m = poly(q); work(m, {hand="body", tool="filbert 3", pile=p, coverage=4.5, fill=true, clip=true, angle=a, length={4,12}, load=1.0}) end
for _,i in ipairs(order) do
  local s = STEPS[i]; local top = s.h + DH; local bot = s.h - SK
  local P = function(dx, dy, hh) return scr(s.x + dx, s.y + dy, hh) end
  face({P(0,1,top), P(1,1,top), P(1,1,bot), P(0,1,bot)}, yP, 1.57)
  face({P(1,0,top), P(1,1,top), P(1,1,bot), P(1,0,bot)}, xP, 1.57)
  local A, B, Cc, D = P(0,0,top), P(1,0,top), P(1,1,top), P(0,1,top)
  face({A, B, Cc, D}, ((s.k % 2) == 0) and topD or topP, (s.dx ~= 0) and -0.52 or 0.52)
  ST({A, B, Cc, D, A}, edge, 2, {0.9,0.9})
  ST({D, Cc, B}, lit, 1.6, {0.8,0.8})
  ST({P(1,1,top), P(1,1,bot)}, edge, 1.6, {0.9,0.9})
end

--@ chunk 11
print(wait(3*24*60))
local brz = pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.4}}
local brzL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"bone brown",0.5}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.5}}
local cross = pile{{"lead white",2},{"ultramarine ash",0.5}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local core = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
-- outer handrail: posts on the outer edge of each tread, a rail along their tops
local RH = 0.75
local rail = {}
for i,s in ipairs(STEPS) do
  local ox, oy = s.dy, -s.dx   -- outer side of a clockwise loop
  local ex = (ox > 0 or oy > 0) and 1 or 0
  local px = s.x + 0.5 + ox*0.45; local py = s.y + 0.5 + oy*0.45
  local top = s.h + DH
  local a, b = scr(px, py, top), scr(px, py, top + RH)
  ST({a, b}, brz, 3, {1,1}); ST({{a[1]-1,a[2]},{b[1]-1,b[2]}}, brzL, 1, {0.8,0.8})
  rail[#rail+1] = b
end
for i=1,#rail-1 do ST({rail[i], rail[i+1]}, brz, 3.4, {1,1}); ST({{rail[i][1],rail[i][2]-1.5},{rail[i+1][1],rail[i+1][2]-1.5}}, brzL, 1.2, {0.9,0.9}) end
-- lamps at the four landings (the corner steps), a post with a warm cage
for _,i in ipairs({1, 8, 15, 18}) do
  local s = STEPS[i]; local top = s.h + DH
  local base = scr(s.x + 0.5, s.y + 0.5, top)
  local hd = scr(s.x + 0.5, s.y + 0.5, top + 1.5)
  ST({base, hd}, brz, 3.4, {1,1})
  ST({hd, {hd[1]+0.1, hd[2]+0.1}}, amber, 16, {1,1}); ST({hd, {hd[1]+0.1, hd[2]+0.1}}, core, 7, {1,1})
  for k=1,10 do local a = k/10*2*math.pi; ST({{hd[1]+math.cos(a)*9, hd[2]+math.sin(a)*9},{hd[1]+math.cos(a)*22, hd[2]+math.sin(a)*22}}, amber, 1.4, {0.6,0}, 0.6) end
  ST({{hd[1]-8,hd[2]-9},{hd[1]+8,hd[2]-9}}, brz, 3, {1,1}); ST({{hd[1]-8,hd[2]+9},{hd[1]+8,hd[2]+9}}, brz, 3, {1,1})
end
-- the same Commando, four times, climbing each flight in turn
for _,i in ipairs({4, 11, 16, 20}) do
  local s = STEPS[i]; local top = s.h + DH
  local f = scr(s.x + 0.5, s.y + 0.5, top)
  local H = 0.95*U
  -- facing direction along the climb: +x heads down-right on screen, +y down-left, -x up-left, -y up-right
  local dirx = (s.dx - s.dy)
  local function P(pts, p) local q = {}; for k,v in ipairs(pts) do q[k] = {f[1] + v[1]*H, f[2] + v[2]*H} end; work(poly(q), {hand="detail", pile=p, coverage=5, fill=true}) end
  P({{-0.12,0},{-0.06,-0.42},{-0.14,-0.74},{-0.07,-0.84},{0.07,-0.84},{0.14,-0.74},{0.06,-0.42},{0.12,0},{0.03,-0.04},{0,-0.38},{-0.03,-0.04}}, dk)
  P({{-0.06,-0.84},{0.06,-0.84},{0.07,-0.92},{0,-0.98},{-0.07,-0.92}}, dk)
  P({{-0.12,-0.74},{0.12,-0.74},{0.11,-0.36},{-0.11,-0.36}}, tab)
  ST({{f[1], f[2]-0.70*H},{f[1], f[2]-0.44*H}}, cross, 2, {1,1}); ST({{f[1]-0.07*H, f[2]-0.62*H},{f[1]+0.07*H, f[2]-0.62*H}}, cross, 2, {1,1})
  ST({{f[1]-0.14*H, f[2]-0.76*H},{f[1]-0.07*H, f[2]-0.84*H},{f[1]+0.07*H, f[2]-0.84*H}}, litH, 1.4, {0.8,0.8})
  -- one leg lifted to the next step, toward the climb
  ST({{f[1]+dirx*0.04*H, f[2]-0.38*H},{f[1]+dirx*0.16*H, f[2]-0.2*H},{f[1]+dirx*0.18*H, f[2]-0.08*H}}, dk, 0.08*H, {1,1})
end
