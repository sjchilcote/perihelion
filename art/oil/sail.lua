-- easel session "sail": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=5150, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.15}, {pile={{"lead white",0.6},{"Mars brown",2},{"ultramarine blue",2},{"bone black",0.8}}, um=40, apply="brush", texture=0.4}}} print(W,H)

--@ chunk 2
SC = {1090, 170} SR = 330
function hy(x) return 430 + 0.00016*(x-420)^2 end
function M_hull() return below(function(x) return hy(x) end) end
function rS(x, y) return math.sqrt((x-SC[1])^2 + (y-SC[2])^2) end
SP = {
 pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}},
 pile{{"lead white",2},{"zinc white",1},{"lemon chrome",0.6}},
 pile{{"lead white",2},{"cadmium yellow",1}},
 pile{{"cadmium yellow",1},{"lead white",1},{"Indian yellow",0.3}},
 pile{{"lead white",1.5},{"cadmium yellow",1},{"Mars orange",0.3}},
 pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.6}},
 pile{{"Mars orange",1},{"burnt sienna",0.6},{"lead white",0.2}},
 pile{{"burnt sienna",1},{"Mars orange",0.4},{"ultramarine blue",0.6},{"bone black",0.3}},
 pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.5}},
}
SB = {0.6*SR, 0.85*SR, 0.97*SR, SR, SR+22, SR+60, SR+120, SR+190, SR+260}
K1 = pile{{"bone black",2},{"ultramarine blue",1}}
local sky = mask(function(x,y) return (rS(x,y) > SR+235 and y < hy(x)+8) and 1 or 0 end)
work(sky, {hand="broad", pile=K1, coverage=3, fill=true, angle=0.1, angle_jitter=0.15, edge="soft"})
local by = {} for i = 1, 9 do by[i] = {} end
for gx = 480, 1004, 7 do
  for gy = -4, 500, 7 do
    local x, y = gx + rand(-3.5, 3.5), gy + rand(-3.5, 3.5)
    if y < hy(x) + 6 then
      local r = rS(x, y)
      local rr = r + rand(-1, 1) * ((r < SR) and 12 or 18)
      if r >= SR - 2 and rr < SR then rr = SR + 1 end
      if r < SR and rr >= SR then rr = SR - 1 end
      local k = nil
      for j = 1, 9 do if rr < SB[j] then k = j break end end
      if k then table.insert(by[k], {x=x, y=y, a=math.atan(y-SC[2], x-SC[1]), r=r}) end
    end
  end
end
for k = 9, 1, -1 do
  local b = brush{kind="filbert", width=9, stiffness=0.5}
  local n = 0
  for _, s in ipairs(by[k]) do
    if n % 6 == 0 then b:reload(SP[k], 0.8) end
    n = n + 1
    local ang = (s.r < SR) and (s.a + math.pi/2) or s.a
    local L = rand(10, 20)
    local c, sn = math.cos(ang), math.sin(ang)
    b:stroke({{s.x - c*L/2, s.y - sn*L/2}, {s.x + c*L/2, s.y + sn*L/2}}, {pressure={0.85, 0.4}, ramps={0.1, 0.4}})
  end
  print(k, #by[k])
end

--@ chunk 3
local cor = mask(function(x,y) local r = rS(x,y) return (r > SR+4 and r < SR+250 and y < hy(x)) and 1 or 0 end)
blend(cor, {angle=function(x,y) return math.atan(y-SC[2], x-SC[1]) end, tool={kind="badger", width=16}})
local disc = mask(function(x,y) local r = rS(x,y) return (r < SR-4 and y < hy(x)) and 1 or 0 end)
blend(disc, {angle=function(x,y) return math.atan(y-SC[2], x-SC[1]) + math.pi/2 end, tool={kind="badger", width=16}})

--@ chunk 4
R = {
 pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.6}},
 pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.3},{"yellow ochre",0.3}},
 pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}},
 pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
}
G5 = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.7}}
G6 = pile{{"yellow ochre",2},{"Mars yellow",1},{"burnt sienna",0.6},{"lead white",0.6}}
G7 = pile{{"Mars yellow",2},{"yellow ochre",1},{"lead white",1},{"cadmium yellow",0.5}}
HULL = M_hull()
work(HULL, {hand="body", pile=R[2], coverage=3, fill=true, angle=0.02, length={30,70}, clip=HULL})
PHI = (math.sqrt(5)-1)/2
VN = noise{seed=5, period=140, octaves=3}
PLS = {}
for i = 1, 26 do
  local dy = 2.2*i + 0.3*i*i
  local w = 5 + 1.5*i
  local off = ((i*PHI) % 1) * w
  for x = -20 + off, 1020, w do
    local xj = x + rand(-0.15, 0.15)*w
    local y = hy(xj) + dy + rand(-0.1, 0.1)*(2.2+0.6*i)
    if y < H + 15 then
      local v = 0.15 + 0.6*smoothstep(150, 980, xj) + 0.25*math.exp(-dy/30) + 0.18*VN(xj, y) + rand(-0.12, 0.12)
      PLS[#PLS+1] = {x=xj, y=y, w=w*rand(0.9,1.1), h=(2.2+0.6*i)*1.15, v=v, i=i, r=rand(0,1)}
    end
  end
end
table.sort(PLS, function(a, b) return a.y < b.y end)
print(#PLS)
local cur, n, bw, b = nil, 0, 0, nil
for _, p in ipairs(PLS) do
  local pl
  if p.r < 0.012 then pl = R[1] elseif p.v < 0.3 then pl = R[3] elseif p.v < 0.45 then pl = R[4] elseif p.v < 0.6 then pl = G5 elseif p.v < 0.78 then pl = G6 else pl = G7 end
  p.pl = pl
  local want = math.max(1.6, p.h*0.95)
  if math.abs(want - bw) > 0.8 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
  if pl ~= cur or n >= 4 then b:reload(pl, 0.8) cur = pl n = 0 end
  n = n + 1
  b:stroke({{p.x - p.w*0.45, p.y}, {p.x + p.w*0.45, p.y + rand(-0.3,0.3)}}, {pressure={0.85, 0.6}, ramps={0.1,0.3}, clip=HULL})
end

--@ chunk 5
print(wait(2*24*60))
GLW = pile{{"lead white",3},{"lemon chrome",0.6},{"zinc white",1}}
R8 = pile{{"lead white",3},{"yellow ochre",1},{"lemon chrome",0.5}}
local sb = brush{kind="round", width=2, point=0.6, stiffness=0.45}
local n = 0
for _, p in ipairs(PLS) do
  if n % 6 == 0 then sb:reload(R[1], 0.8) end
  n = n + 1
  local hw, hh = p.w*0.5, p.h*0.5
  local wd = math.max(0.8, p.h*0.35)
  if sb.width ~= wd then end
  sb:stroke({{p.x - hw*0.9, p.y + hh*0.1}, {p.x - hw*0.4, p.y + hh*0.75}, {p.x + hw*0.4, p.y + hh*0.75}, {p.x + hw*0.9, p.y + hh*0.1}},
    {pressure={0.4 + 0.04*p.i, 0.3}, swell={0.6, 1.3, 1.3, 0.6}, ramps={0.15,0.3}, clip=HULL})
end
local gb = brush{kind="round", width=1.5, point=0.8, stiffness=0.4}
local cur
n = 0
for _, p in ipairs(PLS) do
  local v = p.v + rand(-0.15, 0.15)
  local pl = (v > 0.62) and GLW or ((v > 0.4) and R8 or ((rand(0,1) < 0.5) and G6 or nil))
  if pl then
    if pl ~= cur or n >= 6 then gb:reload(pl, 0.8) cur = pl n = 0 end
    n = n + 1
    local hw, hh = p.w*0.5, p.h*0.5
    gb:stroke({{p.x - hw*0.7, p.y - hh*0.55}, {p.x, p.y - hh*0.75}, {p.x + hw*0.75, p.y - hh*0.5}}, {pressure={0.35 + 0.02*p.i, 0.15}, ramps={0.1,0.5}, clip=HULL})
  end
end

--@ chunk 6
MASTS = { {{235, hy(235)+18}, {300, -30}}, {{405, hy(405)+22}, {450, -30}}, {{580, hy(580)+22}, {610, -30}}, {{752, hy(752)+18}, {770, -30}} }
function mx(i, y) local b, t = MASTS[i][1], MASTS[i][2] local f = (y - b[2]) / (t[2] - b[2]) return b[1] + (t[1]-b[1])*f end
YARDS = {72, 166, 262, 358}
function yard_y(k, x) local x0, x1 = mx(1, YARDS[k]), mx(4, YARDS[k]) local f = (x - x0)/(x1 - x0) return YARDS[k] + 10*math.sin(math.pi*clamp(f,0,1))*0 + 6*math.sin(math.pi*((f*3)%1)) end
function free_y(x) local x0, x1 = mx(1, 400), mx(4, 400) local f = (x - x0)/(x1 - x0) return 402 - 14*math.sin(math.pi*((f*3)%1)) end
-- panel j (between masts j, j+1), row k (between yard k and k+1, or the free edge)
function panel_poly(j, k, frac)
  local pts = {}
  local N = 14
  local top = function(x) return yard_y(k, x) end
  local bot = function(x) if k == 4 then return free_y(x) else return yard_y(k+1, x) end end
  local ya, yb = YARDS[k], (k == 4) and 400 or YARDS[k+1]
  local xl0, xr0 = mx(j, ya), mx(j+1, ya)
  for i = 0, N do local x = xl0 + (xr0-xl0)*i/N pts[#pts+1] = {x, top(x)} end
  local xl1, xr1 = mx(j, yb), mx(j+1, yb)
  for i = N, 0, -1 do local x = xl1 + (xr1-xl1)*i/N local yt, ybb = top(x), bot(x) pts[#pts+1] = {x, yt + (ybb - yt)*(frac or 1)} end
  return poly(pts)
end
SL = {
 pile{{"lead white",2},{"zinc white",1},{"lemon chrome",0.4}},
 pile{{"lead white",2},{"cadmium yellow",0.5},{"Mars orange",0.1}},
 pile{{"lead white",2},{"ultramarine ash",0.5},{"yellow ochre",0.25}},
 pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.25},{"yellow ochre",0.1}},
}
function sail_lum(x, y)
  local r = rS(x, y)
  return 1 - smoothstep(SR - 60, SR + 260, r)
end
DEPLOY = {}
for j = 1, 3 do for k = 2, 4 do DEPLOY[#DEPLOY+1] = {j, k, 1} end end
DEPLOY[#DEPLOY+1] = {3, 1, 0.55}
DEPLOY[#DEPLOY+1] = {2, 1, 0.3}
SAIL = nil
for _, d in ipairs(DEPLOY) do local m = panel_poly(d[1], d[2], d[3]) SAIL = SAIL and (SAIL + m) or m end
local by = {{}, {}, {}, {}}
for gx = 220, 790, 5 do for gy = 60, 420, 5 do
  local x, y = gx + rand(-2.5, 2.5), gy + rand(-2.5, 2.5)
  if SAIL:at(x, y) > 0.5 then
    local l = sail_lum(x, y) + rand(-0.15, 0.15)
    local k = (l > 0.75) and 1 or ((l > 0.45) and 2 or ((l > 0.18) and 3 or 4))
    table.insert(by[k], {x, y})
  end
end end
for k = 4, 1, -1 do
  local b = brush{kind="filbert", width=6, stiffness=0.5}
  local n = 0
  for _, s in ipairs(by[k]) do
    if n % 8 == 0 then b:reload(SL[k], 0.8) end
    n = n + 1
    local a = 1.45 + rand(-0.15, 0.15)
    local L = rand(8, 14)
    b:stroke({{s[1] - math.cos(a)*L/2, s[2] - math.sin(a)*L/2}, {s[1] + math.cos(a)*L/2, s[2] + math.sin(a)*L/2}}, {pressure={0.8, 0.5}, ramps={0.1,0.3}, clip=SAIL})
  end
  print(k, #by[k])
end

--@ chunk 7
print(wait(24*60)) print(drying(400,300))
SD = {
 pile{{"bone black",1},{"ultramarine ash",1},{"ultramarine blue",0.3},{"lead white",0.25}},
 pile{{"ultramarine ash",1},{"lead white",0.6},{"bone black",0.3}},
 pile{{"lead white",1.2},{"ultramarine ash",0.8},{"yellow ochre",0.2}},
 pile{{"lead white",2},{"yellow ochre",0.4},{"cadmium yellow",0.2}},
}
BN = noise{seed=9, period=90, octaves=2}
function sheen(x, y) return math.max(0, math.sin((x*0.55 + y)*0.03 + 1.5*BN(x, y))) end
local zone = SAIL * mask(function(x,y) return (sail_lum(x,y) < 0.55) and 1 or 0 end)
local by = {{}, {}, {}, {}}
for gx = 220, 700, 4.5 do for gy = 60, 420, 4.5 do
  local x, y = gx + rand(-2, 2), gy + rand(-2, 2)
  if zone:at(x, y) > 0.5 then
    local l = 0.15 + 0.55*sail_lum(x, y) + 0.45*sheen(x, y)^3 + rand(-0.12, 0.12)
    local k = (l < 0.3) and 1 or ((l < 0.5) and 2 or ((l < 0.72) and 3 or 4))
    table.insert(by[k], {x, y})
  end
end end
for k = 1, 4 do
  local b = brush{kind="filbert", width=5.5, stiffness=0.5}
  local n = 0
  for _, s in ipairs(by[k]) do
    if n % 8 == 0 then b:reload(SD[k], 0.85) end
    n = n + 1
    local a = 1.45 + rand(-0.15, 0.15)
    local L = rand(8, 13)
    b:stroke({{s[1] - math.cos(a)*L/2, s[2] - math.sin(a)*L/2}, {s[1] + math.cos(a)*L/2, s[2] + math.sin(a)*L/2}}, {pressure={0.85, 0.55}, ramps={0.1,0.3}, clip=zone})
  end
  print(k, #by[k])
end

--@ chunk 8
print(wait(24*60))
SPAR = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
RIM = pile{{"lead white",3},{"lemon chrome",0.5},{"cadmium yellow",0.3}}
SEAM = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",0.2}}
-- seams in the membrane: vertical gores
local sm = brush{kind="round", width=0.9, point=0.5}
local SC2 = SAIL:shrink(1)
for j = 1, 3 do
  for t = 0.2, 0.85, 0.2 do
    sm:reload(SEAM, 0.7)
    local pts = {}
    for y = 60, 420, 15 do pts[#pts+1] = {mx(j, y) + (mx(j+1, y) - mx(j, y))*t + 2*math.sin(y*0.05), y} end
    sm:stroke(pts, {pressure={0.4, 0.4}, ramps={0.02,0.02}, clip=SC2})
  end
end
-- yards
local yb = brush{kind="round", width=3.2, point=0.2, stiffness=0.6}
for k = 1, 4 do
  local pts = {}
  local x0, x1 = mx(1, YARDS[k]) - 12, mx(4, YARDS[k]) + 12
  for i = 0, 30 do local x = x0 + (x1-x0)*i/30 pts[#pts+1] = {x, yard_y(k, x)} end
  yb:reload(SPAR, 0.9)
  yb:stroke(pts, {pressure={0.8, 0.8}, ramps={0.03,0.03}})
end
-- top yard, mostly hidden by the frame edge
local pts = {}
for i = 0, 30 do local x = mx(1, -2) - 14 + (mx(4, -2) - mx(1, -2) + 28)*i/30 pts[#pts+1] = {x, -2 + 4*math.sin(i/30*math.pi)} end
yb:reload(SPAR, 0.9) yb:stroke(pts, {pressure={0.8,0.8}, ramps={0.03,0.03}})
-- masts, tapering
for i = 1, 4 do
  local b0, t0 = MASTS[i][1], MASTS[i][2]
  local mb = brush{kind="round", width=6, point=0.3, stiffness=0.6}
  mb:reload(SPAR, 0.95)
  mb:stroke({b0, {(b0[1]+t0[1])/2, (b0[2]+t0[2])/2}, t0}, {pressure={0.9, 0.6}, ramps={0.02,0.02}})
  local rb = brush{kind="round", width=1.3, point=0.6}
  rb:reload(RIM, 0.85)
  rb:stroke({{b0[1]+2.4, b0[2]-20}, {t0[1]+1.6, t0[2]}}, {pressure={0.5, 0.45}, ramps={0.05,0.02}})
end

--@ chunk 9
print(wait(12*60))
-- furled membrane rolled along yard 1 and the top yard
local function yardpts(yfun, x0, x1, n) local p = {} for i = 0, n do local x = x0 + (x1-x0)*i/n p[#p+1] = {x, yfun(x)} end return p end
local Y1 = function(x) return yard_y(1, x) - 3 end
local Y0 = function(x) return -2 + 4*math.sin((x - mx(1,-2))/(mx(4,-2)-mx(1,-2))*math.pi) + 4 end
ROLL = ribbon(yardpts(Y1, mx(1, 72) - 6, mx(4, 72) + 6, 40), 11):roughen(1.5, 12, 3) + ribbon(yardpts(Y0, mx(1, 0) - 6, mx(4, 0) + 6, 40), 14):roughen(1.5, 12, 4)
work(ROLL, {hand="body", pile=SD[2], coverage=3, fill=true, angle=0.03, length={6, 14}, clip=ROLL})
local under = ROLL * mask(function(x,y) local yy = (y < 40) and Y0(x) or Y1(x) return (y > yy + 1.5) and 1 or 0 end)
work(under, {hand="detail", pile=SD[1], coverage=3, fill=true, clip=under, length={3, 8}})
-- masts as tapered solids
local function mast_poly(i)
  local b0, t0 = MASTS[i][1], MASTS[i][2]
  local wb, wt = 9, 5
  return poly({{b0[1]-wb, b0[2]}, {t0[1]-wt, t0[2]}, {t0[1]+wt, t0[2]}, {b0[1]+wb, b0[2]}})
end
MASTM = mast_poly(1) + mast_poly(2) + mast_poly(3) + mast_poly(4)
work(MASTM, {hand="detail", pile=SPAR, coverage=3, fill=true, clip=MASTM, tool={kind="round", width=3}, length={6, 16}, angle=-1.45})

--@ chunk 10
print(wait(24*60))
LG = pile{{"yellow ochre",1},{"lead white",1.2},{"Mars yellow",0.5}}
local rig = brush{kind="rigger", width=1.2, point=1, stiffness=0.4}
local function seg_line(p0, p1, pr)
  local N = 24
  for i = 0, N-1 do
    local a = {p0[1] + (p1[1]-p0[1])*i/N, p0[2] + (p1[2]-p0[2])*i/N}
    local b = {p0[1] + (p1[1]-p0[1])*(i+1)/N, p0[2] + (p1[2]-p0[2])*(i+1)/N}
    local mxp, myp = (a[1]+b[1])/2, (a[2]+b[2])/2
    local bright = (rS(mxp, myp) < SR + 140) or (SAIL:at(mxp, myp) > 0.5)
    rig:reload(bright and SPAR or LG, 0.8)
    rig:stroke({a, b}, {pressure={pr, pr}, ramps={0.01,0.01}})
  end
end
-- stays: from high on each mast to anchors on the hull, fanned
local anchors = {40, 110, 170, 320, 490, 660, 830, 900, 960}
for i = 1, 4 do
  for _, yh in ipairs({20, 120}) do
    local top = {mx(i, yh), yh}
    for _, ax in ipairs(anchors) do
      if math.abs(ax - top[1]) > 90 and math.abs(ax - top[1]) < 330 and rand(0,1) < 0.55 then
        seg_line(top, {ax + rand(-10,10), hy(ax) + rand(8, 40)}, 0.32)
      end
    end
  end
end
-- sheets from the free lower edge corners down to the hull
for j = 1, 4 do
  local x = mx(j, 400)
  seg_line({x, 400}, {x + rand(-30, 30), hy(x) + 10}, 0.3)
end
-- sun rims on the right side of masts and top of yards
local rb = brush{kind="round", width=1.4, point=0.6}
for i = 1, 4 do
  local b0, t0 = MASTS[i][1], MASTS[i][2]
  rb:reload(RIM, 0.85)
  rb:stroke({{b0[1]+7.5, b0[2]-4}, {t0[1]+4.2, t0[2]}}, {pressure={0.55, 0.45}, ramps={0.05,0.02}})
end
for k = 2, 4 do
  local pts = {}
  local x0, x1 = mx(1, YARDS[k]) - 10, mx(4, YARDS[k]) + 10
  for i = 0, 30 do local x = x0 + (x1-x0)*i/30 pts[#pts+1] = {x, yard_y(k, x) - 1.3} end
  rb:reload(RIM, 0.85)
  rb:stroke(pts, {pressure={0.4, 0.4}, ramps={0.03,0.03}})
end

--@ chunk 11
print(wait(12*60))

--@ chunk 12
DR = pile{{"bone black",2},{"ultramarine blue",0.5},{"lead white",0.5}}
AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.3}}
WL = pile{{"lead white",2},{"cadmium yellow",1},{"cadmium red",0.1}}
-- mast footings: squat dark collars on the hull with a lit top
for i = 1, 4 do
  local b0 = MASTS[i][1]
  local m = poly({{b0[1]-16, b0[2]+6}, {b0[1]-11, b0[2]-12}, {b0[1]+11, b0[2]-12}, {b0[1]+16, b0[2]+6}})
  work(m, {hand="detail", pile=SPAR, coverage=3, fill=true, clip=m, tool={kind="round", width=2}, length={3, 8}})
  local rb = brush{kind="round", width=1.2, point=0.5}
  rb:reload(RIM, 0.85)
  rb:stroke({{b0[1]-10, b0[2]-12}, {b0[1]+11, b0[2]-12}, {b0[1]+15.5, b0[2]+5}}, {pressure={0.5,0.4}, ramps={0.05,0.05}})
  local lb = brush{kind="round", width=1.0, point=0.3}
  lb:reload(WL, 0.9)
  for k = -2, 2 do lb:touch(b0[1] + k*4, b0[2] - 4, {pressure=0.4}) end
end
-- window rows in the hull near the horizon, tiny warm dots in runs
local wb = brush{kind="round", width=1.1, point=0.3}
wb:reload(WL, 0.9)
local n = 0
for i = 2, 9 do
  local dy = 2.2*i + 0.3*i*i + 1
  local x = rand(0, 40)
  while x < 1000 do
    local runn = math.floor(rand(4, 14))
    local lit = rand(0,1) < 0.4
    for q = 1, runn do
      if lit and rand(0,1) < 0.85 then
        n = n + 1 if n % 12 == 0 then wb:reload(WL, 0.9) end
        wb:touch(x, hy(x) + dy, {pressure=0.25 + 0.02*i})
      end
      x = x + (2.4 + 0.5*i)
    end
    x = x + rand(20, 90)
  end
end
print(n)
-- drones crawling the rigging and yards
local db = brush{kind="round", width=2.2, point=0.3}
local ab = brush{kind="round", width=0.9, point=0.3}
local spots = {}
for k = 1, 4 do for c = 1, 3 do local x = rand(mx(1, YARDS[k]) + 10, mx(4, YARDS[k]) - 10) spots[#spots+1] = {x, yard_y(k, x) - 2.5} end end
for i = 1, 4 do for c = 1, 3 do local y = rand(20, 400) spots[#spots+1] = {mx(i, y) + rand(-3, 3), y} end end
for _, s in ipairs(spots) do
  db:reload(DR, 0.85)
  db:stroke({{s[1]-1.6, s[2]}, {s[1]+1.6, s[2]+rand(-0.5,0.5)}}, {pressure={0.6,0.6}, ramps={0.05,0.05}})
  ab:reload(AMB, 0.9)
  ab:touch(s[1] + 1, s[2] - 0.8, {pressure=0.45})
end

--@ chunk 13
-- heavier yards
local yb = brush{kind="round", width=4.5, point=0.2, stiffness=0.6}
for k = 2, 4 do
  local pts = {}
  local x0, x1 = mx(1, YARDS[k]) - 10, mx(4, YARDS[k]) + 10
  for i = 0, 30 do local x = x0 + (x1-x0)*i/30 pts[#pts+1] = {x, yard_y(k, x) + 1} end
  yb:reload(SPAR, 0.95)
  yb:stroke(pts, {pressure={0.85, 0.85}, ramps={0.03,0.03}})
end
-- bigger drones: dark bodies with an amber eye, a few with a work-light
local db = brush{kind="filbert", width=3.2, stiffness=0.6}
local ab = brush{kind="round", width=1.3, point=0.3}
DRONES = {}
for k = 1, 4 do for c = 1, 2 do local x = rand(mx(1, YARDS[k]) + 15, mx(4, YARDS[k]) - 15) DRONES[#DRONES+1] = {x, yard_y(k, x) - 3} end end
for i = 1, 4 do for c = 1, 2 do local y = rand(30, 390) DRONES[#DRONES+1] = {mx(i, y) - 4, y} end end
for _, s in ipairs({{330, 300}, {520, 230}, {470, 120}}) do DRONES[#DRONES+1] = s end
for _, s in ipairs(DRONES) do
  db:reload(DR, 0.9)
  db:stroke({{s[1]-2.2, s[2]}, {s[1]+2.2, s[2]+rand(-0.6,0.6)}}, {pressure={0.75,0.7}, ramps={0.05,0.05}})
  local lb = brush{kind="rigger", width=0.8, point=1}
  lb:reload(DR, 0.9)
  for q = -1, 1, 2 do lb:stroke({{s[1] + q*1.5, s[2] + 0.8}, {s[1] + q*3.2, s[2] + 2.6}}, {pressure={0.4, 0.2}}) end
  ab:reload(AMB, 0.9)
  ab:touch(s[1] + 1.6, s[2] - 0.6, {pressure=0.55})
end
-- the Commando's frame, standing on yard 2 against the bright panel
local cx, cy = 655, yard_y(2, 655) - 2.5
local fb = brush{kind="round", width=1.6, point=0.4, stiffness=0.6}
fb:reload(SPAR, 0.95)
fb:stroke({{cx - 1.6, cy}, {cx - 1.0, cy - 4.2}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})   -- legs
fb:stroke({{cx + 1.6, cy}, {cx + 0.9, cy - 4.2}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
local tb = brush{kind="filbert", width=3.0, stiffness=0.6}
tb:reload(SPAR, 0.95)
tb:stroke({{cx, cy - 4.4}, {cx + 0.2, cy - 8.2}}, {pressure={0.9,0.9}, ramps={0.02,0.02}})   -- torso
fb:reload(SPAR, 0.95)
fb:touch(cx + 0.3, cy - 9.6, {pressure=0.8})                                               -- head
fb:stroke({{cx - 1.2, cy - 7.6}, {cx - 3.2, cy - 5.0}}, {pressure={0.6,0.5}})                 -- arm down
fb:stroke({{cx + 1.4, cy - 7.8}, {cx + 4.0, cy - 11.5}}, {pressure={0.6,0.5}})                -- arm up, to the rigging
local rr = brush{kind="round", width=0.8, point=0.7}
rr:reload(RIM, 0.9)
rr:stroke({{cx + 1.6, cy - 4.5}, {cx + 1.7, cy - 8.0}}, {pressure={0.45,0.4}})
rr:touch(cx + 1.0, cy - 9.9, {pressure=0.35})

--@ chunk 14
print(wait(2*24*60))
SDX = {
 pile{{"bone black",1.2},{"ultramarine ash",1},{"ultramarine blue",0.4},{"lead white",0.15}},
 SD[1], SD[2], SD[3], SD[4], SL[2],
}
-- each deployed bay billows: dark near the spars, a vertical gleam where it bellies toward the Sun
local zone = SAIL:shrink(0.5) * mask(function(x,y) return (sail_lum(x,y) < 0.62) and 1 or 0 end)
GN = noise{seed=21, period=60, octaves=2}
local by = {} for i = 1, 6 do by[i] = {} end
for gx = 220, 720, 4 do for gy = 60, 420, 5 do
  local x, y = gx + rand(-2, 2), gy + rand(-2.5, 2.5)
  if zone:at(x, y) > 0.5 then
    local j = (x < mx(2, y)) and 1 or ((x < mx(3, y)) and 2 or 3)
    local t = (x - mx(j, y)) / (mx(j+1, y) - mx(j, y))
    local g = math.exp(-((t - 0.64 - 0.04*math.sin(y*0.03))/0.17)^2)
    local l = 0.12 + 0.62*g + 0.35*sail_lum(x, y) + 0.08*GN(x, y) - 0.15*smoothstep(0.85, 1, t) + rand(-0.06, 0.06)
    local k = clamp(math.floor(l * 6) + 1, 1, 6)
    table.insert(by[k], {x, y})
  end
end end
for k = 1, 6 do
  local b = brush{kind="filbert", width=5, stiffness=0.5}
  local n = 0
  for _, s in ipairs(by[k]) do
    if n % 8 == 0 then b:reload(SDX[k], 0.85) end
    n = n + 1
    local L = rand(12, 22)
    b:stroke({{s[1] + 0.06*L, s[2] - L/2}, {s[1] - 0.06*L, s[2] + L/2}}, {pressure={0.85, 0.6}, ramps={0.1,0.3}, clip=zone})
  end
  print(k, #by[k])
end

--@ chunk 15
print(wait(24*60)) print(drying(400,300))
work(MASTM, {hand="detail", pile=SPAR, coverage=3, fill=true, clip=MASTM, tool={kind="round", width=3}, length={6, 16}, angle=-1.45})
local yb = brush{kind="round", width=4.5, point=0.2, stiffness=0.6}
for k = 2, 4 do
  local pts = {}
  local x0, x1 = mx(1, YARDS[k]) - 10, mx(4, YARDS[k]) + 10
  for i = 0, 30 do local x = x0 + (x1-x0)*i/30 pts[#pts+1] = {x, yard_y(k, x) + 1} end
  yb:reload(SPAR, 0.95)
  yb:stroke(pts, {pressure={0.85, 0.85}, ramps={0.03,0.03}})
end
-- gore seams
local sm = brush{kind="round", width=1.0, point=0.5}
local SC2 = SAIL:shrink(1)
for j = 1, 3 do
  for t = 0.17, 0.9, 0.17 do
    sm:reload(SEAM, 0.7)
    local pts = {}
    for y = 60, 420, 15 do pts[#pts+1] = {mx(j, y) + (mx(j+1, y) - mx(j, y))*t + 1.5*math.sin(y*0.05), y} end
    sm:stroke(pts, {pressure={0.35, 0.35}, ramps={0.02,0.02}, clip=SC2})
  end
end

--@ chunk 16
print(wait(24*60))
SHAD = poly({{238, hy(238)+12}, {752, hy(752)+14}, {460, 575}, {-80, 575}}):roughen(4, 30, 5)
local cur, n, bw, b = nil, 0, 0, nil
for _, p in ipairs(PLS) do
  if SHAD:at(p.x, p.y) > 0.5 then
    local pl = (rand(0,1) < 0.75) and R[1] or R[2]
    local want = math.max(1.6, p.h*0.95)
    if math.abs(want - bw) > 0.8 then b = brush{kind="filbert", width=want, stiffness=0.5} bw = want cur = nil end
    if pl ~= cur or n >= 4 then b:reload(pl, 0.8) cur = pl n = 0 end
    n = n + 1
    b:stroke({{p.x - p.w*0.47, p.y}, {p.x + p.w*0.47, p.y}}, {pressure={0.9, 0.7}, ramps={0.1,0.3}, clip=HULL})
  end
end
print(n)

--@ chunk 17
print(wait(2*24*60))
-- yards again, darker and crisper, with sun rims
local yb = brush{kind="round", width=4.5, point=0.2, stiffness=0.6}
local rb = brush{kind="round", width=1.4, point=0.6}
for k = 2, 4 do
  local pts, pr = {}, {}
  local x0, x1 = mx(1, YARDS[k]) - 10, mx(4, YARDS[k]) + 10
  for i = 0, 30 do local x = x0 + (x1-x0)*i/30 pts[#pts+1] = {x, yard_y(k, x) + 1} pr[#pr+1] = {x, yard_y(k, x) - 0.6} end
  yb:reload(SPAR, 0.95) yb:stroke(pts, {pressure={0.85, 0.85}, ramps={0.03,0.03}})
  rb:reload(RIM, 0.85) rb:stroke(pr, {pressure={0.35, 0.35}, ramps={0.03,0.03}})
end
for i = 1, 4 do
  local b0, t0 = MASTS[i][1], MASTS[i][2]
  rb:reload(RIM, 0.85)
  rb:stroke({{b0[1]+7.6, b0[2]-14}, {t0[1]+4.3, t0[2]}}, {pressure={0.55, 0.45}, ramps={0.05,0.02}})
end
-- footings
for i = 1, 4 do
  local b0 = MASTS[i][1]
  local m = poly({{b0[1]-16, b0[2]+6}, {b0[1]-11, b0[2]-12}, {b0[1]+11, b0[2]-12}, {b0[1]+16, b0[2]+6}})
  work(m, {hand="detail", pile=SPAR, coverage=3, fill=true, clip=m, tool={kind="round", width=2}, length={3, 8}})
  rb:reload(RIM, 0.85)
  rb:stroke({{b0[1]-10, b0[2]-12}, {b0[1]+11, b0[2]-12}, {b0[1]+15.5, b0[2]+5}}, {pressure={0.5,0.4}, ramps={0.05,0.05}})
end
-- lit windows inside the sail's shadow on the hull
local wb = brush{kind="round", width=1.2, point=0.3}
wb:reload(WL, 0.9)
local n = 0
for i = 3, 22 do
  local dy = 2.2*i + 0.3*i*i + 0.5
  local x = rand(-20, 30)
  while x < 800 do
    local runn = math.floor(rand(3, 12))
    local lit = rand(0,1) < 0.35
    for q = 1, runn do
      local y = hy(x) + dy
      if lit and rand(0,1) < 0.85 and SHAD:shrink(4):at(x, y) > 0.5 then
        n = n + 1 if n % 12 == 0 then wb:reload(WL, 0.9) end
        wb:stroke({{x - 0.3*i*0.15, y}, {x + 0.3*i*0.15 + 0.4, y}}, {pressure={0.25 + 0.025*i, 0.25 + 0.025*i}, ramps={0.05,0.05}})
      end
      x = x + (3 + 0.8*i)
    end
    x = x + rand(20, 80)
  end
end
print(n)

--@ chunk 18
local db = brush{kind="filbert", width=3.6, stiffness=0.6}
local ab = brush{kind="round", width=1.5, point=0.3}
local lb = brush{kind="rigger", width=0.9, point=1}
local spark = pile{{"zinc white",3},{"lemon chrome",0.3}}
local SPOTS = {}
for k = 2, 4 do for c = 1, 3 do local x = rand(mx(1, YARDS[k]) + 15, mx(4, YARDS[k]) - 15) SPOTS[#SPOTS+1] = {x, yard_y(k, x) - 3.5} end end
for i = 1, 4 do for c = 1, 2 do local y = rand(40, 380) SPOTS[#SPOTS+1] = {mx(i, y) - 5, y} end end
for c = 1, 7 do SPOTS[#SPOTS+1] = {rand(270, 700), rand(185, 390)} end
for idx, s in ipairs(SPOTS) do
  db:reload(DR, 0.9)
  db:stroke({{s[1]-2.4, s[2]}, {s[1]+2.4, s[2]+rand(-0.6,0.6)}}, {pressure={0.8,0.75}, ramps={0.05,0.05}})
  lb:reload(DR, 0.9)
  for q = -1, 1, 2 do lb:stroke({{s[1] + q*1.8, s[2] + 0.8}, {s[1] + q*3.6, s[2] + 3}}, {pressure={0.45, 0.25}}) end
  ab:reload(AMB, 0.9)
  ab:touch(s[1] + 1.8, s[2] - 0.7, {pressure=0.6})
  if idx % 5 == 0 then
    ab:reload(spark, 0.9)
    ab:touch(s[1] - 3.2, s[2] + 1.5, {pressure=0.7})
    lb:reload(spark, 0.9)
    for a = 0, 5 do local an = a*1.05 + rand(-0.2, 0.2) lb:stroke({{s[1]-3.2, s[2]+1.5}, {s[1]-3.2 + math.cos(an)*rand(3,6), s[2]+1.5 + math.sin(an)*rand(3,6)}}, {pressure={0.4, 0.0}, ramps={0.02,0.8}}) end
  end
end
-- stars, few, in the open navy
local ST = pile{{"zinc white",3},{"lead white",1}}
local sb = brush{kind="round", width=1.3, point=0.5}
local placed = 0
for i = 1, 400 do
  local x, y = rand(0, 520), rand(0, 420)
  if rS(x, y) > SR + 250 and y < hy(x) - 5 and SAIL:grow(4):at(x, y) < 0.1 and MASTM:grow(3):at(x, y) < 0.1 and ROLL:grow(3):at(x,y) < 0.1 then
    placed = placed + 1
    if placed % 10 == 1 then sb:reload(ST, 0.85) end
    sb:touch(x, y, {pressure=(rand(0,1) < 0.07) and 0.75 or rand(0.3, 0.5)})
    if placed >= 70 then break end
  end
end
print(placed)

--@ chunk 19
print(wait(3*24*60))
