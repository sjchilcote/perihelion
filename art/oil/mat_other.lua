-- easel session "mat_other": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen=16, seed=6161,
  ground={{pile={{"ultramarine blue",1},{"bone black",0.8},{"cobalt violet",0.5},{"lead white",0.6}}, um=50, apply="knife", texture=0.3}}}
PL = {}
for j=0,7 do for i=0,7 do
  local x0, y0 = i*125, j*125
  local l, r = x0 + rand(12,18), x0 + 125 - rand(12,18)
  local t, b = y0 + rand(12,18), y0 + 125 - rand(12,18)
  local function jj() return rand(-2.5,2.5) end
  local c = {rand(6,13), rand(6,13), rand(6,13), rand(6,13)}
  local pts = {
    {l+c[1]+jj(), t+jj()}, {r-c[2]+jj(), t+jj()}, {r+jj(), t+c[2]+jj()}, {r+jj(), b-c[3]+jj()},
    {r-c[3]+jj(), b+jj()}, {l+c[4]+jj(), b+jj()}, {l+jj(), b-c[4]+jj()}, {l+jj(), t+c[1]+jj()} }
  local cx, cy = (l+r)/2, (t+b)/2
  local u = math.random()
  local rot, dx, dy = 0, 0, 0
  if u < 0.3 then rot = rand(-0.35, 0.35) elseif u < 0.55 then dx, dy = rand(-7,7), rand(-7,7) end
  local q = {}
  for _,p in ipairs(pts) do
    local x, y = p[1]-cx, p[2]-cy
    local s = (rot ~= 0) and 0.88 or 1
    q[#q+1] = {cx + dx + s*(x*math.cos(rot) - y*math.sin(rot)), cy + dy + s*(x*math.sin(rot) + y*math.cos(rot))}
  end
  PL[#PL+1] = {pts=q, cx=cx+dx, cy=cy+dy, w=r-l, h=b-t, rot=rot, tone=math.random(1,3)}
end end
local pm = nil
for _,p in ipairs(PL) do local m = poly(p.pts, true); pm = pm and (pm + m) or m end
PM = pm

--@ chunk 2
JNT = pile{{"bone black",1},{"ultramarine blue",0.6},{"cobalt violet",0.4},{"lead white",0.25}}
CY = pile{{"viridian",0.6},{"cerulean blue",1},{"lead white",1},{"lemon chrome",0.15}}
PB = {
  pile{{"lead white",1},{"ultramarine ash",1},{"cerulean blue",0.3},{"bone black",0.35}},
  pile{{"lead white",1},{"cobalt violet",0.6},{"ultramarine blue",0.4},{"bone black",0.4}},
  pile{{"lead white",1},{"cerulean blue",0.5},{"viridian",0.2},{"bone black",0.45},{"ultramarine blue",0.2}},
}
local gap = -(PM:shrink(3))
work(gap, {hand="body", tool="filbert 6", pile=JNT, coverage=2.6, fill=true, clip=true, length={10,30}})
local g = {nil,nil,nil}
for _,p in ipairs(PL) do local m = poly(p.pts, true); g[p.tone] = g[p.tone] and (g[p.tone]+m) or m end
for t=1,3 do
  work(g[t], {hand="body", tool="filbert 10", pile=PB[t], coverage=3, fill=true, clip=true, length={25,70},
    angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].rot + ((k%2==0) and 0 or math.pi/2) end})
end

--@ chunk 3
print(wait(600))
LIP = pile{{"bone black",1},{"cobalt violet",0.5},{"ultramarine blue",0.4},{"lead white",0.15}}
work(PM - PM:shrink(7), {hand="body", tool="filbert 4", pile=LIP, coverage=2.8, fill=true, clip=true, length={10,30}})
INL = pile{{"lead white",1},{"ultramarine ash",0.7},{"cerulean blue",0.25},{"bone black",0.3}}
local v, h = nil, nil
for k=0,8 do
  local a = rect(k*125-3, -10, 6, 1020); v = v and (v+a) or a
  local b = rect(-10, k*125-3, 1020, 6); h = h and (h+b) or b
end
work(v, {hand="body", tool="flat 5", pile=INL, coverage=2.5, fill=true, clip=true, length={30,90}, angle=math.pi/2, shake=1.5})
work(h - v, {hand="body", tool="flat 5", pile=INL, coverage=2.5, fill=true, clip=true, length={30,90}, angle=0, shake=1.5})
-- ornament in dark indigo, sparse, golden-angle turned
INDG = pile{{"ultramarine blue",1},{"bone black",0.6},{"cobalt violet",0.3}}
local GA = 2.39996323
local pen = brush{kind="round", width=4.5, point=0.25}
for idx,p in ipairs(PL) do
  if math.random() < 0.55 then
    local n0 = math.random(3,6)
    local rmax = math.min(p.w,p.h)*rand(0.3,0.38)
    for L=1,2 do
      local n = n0 + L - 1; local r = rmax*(L==1 and 1 or 0.618); local a0 = p.rot + idx*GA + (L-1)*GA
      local vv = {}
      for k=0,n-1 do local a = a0 + k*2*math.pi/n; vv[#vv+1] = {p.cx + r*math.cos(a), p.cy + r*math.sin(a)} end
      for k=1,n do pen:load(INDG, 0.6); local a, b = vv[k], vv[k%n+1]; pen:stroke({{a[1],a[2]},{b[1],b[2]}}, {pressure={0.55,0.5}, shake=0.6}) end
    end
  end
end

--@ chunk 4
print(wait(600))
local cut = brush{kind="rigger", width=2.6, point=0.4}
local n = 0
for idx,p in ipairs(PL) do
  if math.random() < 0.3 then
    local a = rand(0, math.pi); local L = 60
    local ox, oy = rand(-15,15), rand(-15,15)
    local m = poly(p.pts, true):grow(4)
    cut:reload(CY, 0.8)
    cut:stroke({{p.cx+ox - L*math.cos(a), p.cy+oy - L*math.sin(a)}, {p.cx+ox + L*math.cos(a), p.cy+oy + L*math.sin(a)}}, {pressure={0.6,0.6}, clip=m})
    -- the dark seam beside each cut: the plate split and slipped
    cut:reload(LIP, 0.8)
    cut:stroke({{p.cx+ox+3*math.sin(a) - L*math.cos(a), p.cy+oy-3*math.cos(a) - L*math.sin(a)}, {p.cx+ox+3*math.sin(a) + L*math.cos(a), p.cy+oy-3*math.cos(a) + L*math.sin(a)}}, {pressure={0.5,0.5}, clip=m})
    n = n + 1
  end
end
print(n)
stipple(-(PM:grow(2)) - (PM:grow(2)):grow(0), {pile=CY, width=3, coverage=0.15, cluster={0.8, 25}, clip=true, seed=8})
