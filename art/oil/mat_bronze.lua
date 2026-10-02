-- easel session "mat_bronze": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen=16, seed=7171,
  ground={{pile={{"lead white",2},{"raw sienna",1}}, um=60, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"raw sienna",1.2},{"viridian",0.25},{"lead white",0.3}}, um=40, apply="brush"}}}

--@ chunk 2
-- plate layout: one plate per 125 cell, irregular inset, rounded corners
PL = {}
for j=0,7 do for i=0,7 do
  local x0, y0 = i*125, j*125
  local l, r = x0 + rand(8,15), x0 + 125 - rand(8,15)
  local t, b = y0 + rand(8,15), y0 + 125 - rand(8,15)
  local function jj() return rand(-2.5,2.5) end
  local c = {rand(6,13), rand(6,13), rand(6,13), rand(6,13)}
  local pts = {
    {l+c[1]+jj(), t+jj()}, {r-c[2]+jj(), t+jj()},
    {r+jj(), t+c[2]+jj()}, {r+jj(), b-c[3]+jj()},
    {r-c[3]+jj(), b+jj()}, {l+c[4]+jj(), b+jj()},
    {l+jj(), b-c[4]+jj()}, {l+jj(), t+c[1]+jj()} }
  PL[#PL+1] = {pts=pts, cx=(l+r)/2, cy=(t+b)/2, w=r-l, h=b-t, i=i, j=j, tone=math.random(1,4)}
end end
BR = {
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
  pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1.2}},
  pile{{"raw sienna",2},{"burnt sienna",1},{"bone brown",1.2},{"yellow ochre",0.5}},
  pile{{"yellow ochre",2},{"burnt sienna",1},{"bone brown",1.3},{"bone black",0.3}},
}
VERD = pile{{"viridian",1},{"cerulean blue",0.6},{"lead white",0.8},{"yellow ochre",0.5},{"bone brown",0.6}}
BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.5},{"bone brown",0.3}}
print(#PL)

--@ chunk 3
local pm = nil
for _,p in ipairs(PL) do local m = poly(p.pts, true); pm = pm and (pm + m) or m end
PM = pm
local gap = -(pm:shrink(5))
work(gap, {hand="body", tool="filbert 6", pile=VERD, coverage=2.2, fill=true, clip=true, length={10,30}, angle=function(x,y) return (math.abs((x%125)-62.5) > math.abs((y%125)-62.5)) and math.pi/2 or 0 end})

--@ chunk 4
print(wait(300))
for _,p in ipairs(PL) do p.ang = (math.random() < 0.5 and 0 or math.pi/2) + rand(-0.25,0.25) end
for t=1,4 do
  local m = nil
  for _,p in ipairs(PL) do if p.tone == t then local q = poly(p.pts, true); m = m and (m+q) or q end end
  if m then
    m = m:grow(3)
    work(m, {hand="body", tool="filbert 10", pile=BR[t], coverage=3, fill=true, clip=true, length={25,70},
      angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})
  end
end

--@ chunk 5
MIDB = pile{{"raw sienna",2},{"burnt sienna",0.8},{"bone brown",1.2},{"yellow ochre",0.6},{"bone black",0.3}}
DJ = pile{{"viridian",1},{"bone black",0.8},{"burnt sienna",1},{"raw sienna",0.8}}
local pl = PM:grow(2)
work(pl, {hand="scumble", pile=MIDB, coverage=1.3, clip=true, load=0.5, pressure={0.3,0.6},
  angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})
local gap = -(PM:grow(1))
work(gap, {hand="body", tool="filbert 5", pile=DJ, coverage=1.4, clip=true, length={8,25}, load=0.7,
  angle=function(x,y) return (math.abs((x%125)-62.5) > math.abs((y%125)-62.5)) and math.pi/2 or 0 end})

--@ chunk 6
print(wait(600))
LIGHTB = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.5},{"bone brown",0.4}}
DARKB = pile{{"bone brown",2},{"raw sienna",1},{"burnt sienna",0.7},{"bone black",0.4}}
REDB = pile{{"burnt sienna",1.5},{"Mars brown",1},{"raw sienna",1},{"yellow ochre",0.4}}
local ml, md, mr = nil, nil, nil
for _,p in ipairs(PL) do
  local r = math.random()
  local e = ellipse(p.cx + rand(-12,12), p.cy + rand(-12,12), p.w*rand(0.28,0.45), p.h*rand(0.28,0.45)):roughen(8, 40, math.random(1,999)):soften(6)
  e = e * poly(p.pts, true)
  if r < 0.4 then ml = ml and (ml+e) or e
  elseif r < 0.7 then md = md and (md+e) or e
  else mr = mr and (mr+e) or e end
end
work(ml, {hand="scumble", pile=LIGHTB, coverage=1.6, load=0.55, pressure={0.3,0.7}, clip=PM, angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})
work(md, {hand="scumble", pile=DARKB, coverage=1.6, load=0.6, pressure={0.3,0.7}, clip=PM, angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})
work(mr, {hand="scumble", pile=REDB, coverage=1.5, load=0.55, pressure={0.3,0.7}, clip=PM, angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})

--@ chunk 7
blend(PM:shrink(4), {angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end})

--@ chunk 8
print(wait(1440))
BONE = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.6},{"bone brown",0.45}}
local v, h = nil, nil
for k=0,8 do
  local a = rect(k*125-3.5, -10, 7, 1020); v = v and (v+a) or a
  local b = rect(-10, k*125-3.5, 1020, 7); h = h and (h+b) or b
end
work(v, {hand="body", tool="flat 6", pile=BONE, coverage=2.5, fill=true, clip=true, length={30,90}, angle=math.pi/2, load=0.8})
work(h - v, {hand="body", tool="flat 6", pile=BONE, coverage=2.5, fill=true, clip=true, length={30,90}, angle=0, load=0.8})

--@ chunk 9
print(wait(2880))
INK = pile{{"bone brown",2},{"burnt sienna",0.8},{"bone black",0.5},{"raw sienna",0.5}}
STUD = pile{{"yellow ochre",2},{"raw sienna",0.6},{"lead white",0.7},{"Indian yellow",0.3}}
local GA = 2.39996323
local pen = brush{kind="round", width=4.5, point=0.25, stiffness=0.55}
local dot = brush{kind="round", width=7, point=0.1}
pen:load(INK, 0.8); dot:load(STUD, 0.8)
local nd, ne = 0, 0
for idx,p in ipairs(PL) do
  local kind = math.random()
  local cx, cy = p.cx + rand(-6,6), p.cy + rand(-6,6)
  local rot = idx * GA
  local rmax = math.min(p.w, p.h) * rand(0.36, 0.44)
  if kind < 0.72 then
    -- nested polygon inscriptions, each turned by the golden angle
    local layers = math.random(2,3)
    local n0 = math.random(3,6)
    for L=1,layers do
      local n = n0 + L - 1
      local r = rmax * (1 - (L-1)*rand(0.27,0.33))
      local a0 = rot + (L-1)*GA
      local v = {}
      for k=0,n-1 do local a = a0 + k*2*math.pi/n; v[#v+1] = {cx + r*math.cos(a), cy + r*math.sin(a)} end
      for k=1,n do
        if ne % 6 == 0 then pen:load(INK, 0.7) end
        local a, b = v[k], v[k % n + 1]
        pen:stroke({{a[1],a[2]},{b[1],b[2]}}, {pressure={0.55,0.5}, ramps={0.08,0.1}, shake=0.6})
        ne = ne + 1
      end
    end
  end
  if kind > 0.45 then
    -- golden-angle spiral of studs
    local N = math.random(13, 34)
    local c = (kind < 0.72 and rmax*0.55 or rmax*0.95) / math.sqrt(N)
    for k=1,N do
      if nd % 8 == 0 then dot:load(STUD, 0.7) end
      local r = c * math.sqrt(k); local a = rot + k*GA
      dot:touch(cx + r*math.cos(a), cy + r*math.sin(a), {pressure=0.35 + 0.35*k/N})
      nd = nd + 1
    end
  end
end
print(ne, nd)

--@ chunk 10
print(wait(1440))
WEAR = pile{{"raw sienna",2},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone brown",1},{"lead white",0.25}}
GRIME = pile{{"raw sienna",1.5},{"bone brown",1.2},{"yellow ochre",0.8},{"lead white",0.6}}
work(PM:shrink(3), {hand="scumble", pile=WEAR, coverage=1.1, load=0.3, pressure={0.15,0.4}, clip=true,
  angle=function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang + 0.4 end, seed=101})
local v, h = nil, nil
for k=0,8 do
  local a = rect(k*125-4, -10, 8, 1020); v = v and (v+a) or a
  local b = rect(-10, k*125-4, 1020, 8); h = h and (h+b) or b
end
work(v, {hand="scumble", tool="filbert 5", pile=GRIME, coverage=1.2, load=0.3, pressure={0.2,0.5}, clip=true, angle=math.pi/2, seed=102})
work(h, {hand="scumble", tool="filbert 5", pile=GRIME, coverage=1.2, load=0.3, pressure={0.2,0.5}, clip=true, angle=0, seed=103})
local gap = -(PM:grow(1)) - v - h
stipple(gap, {pile=VERD, width=5, coverage=0.5, cluster={0.7, 20}, clip=true, seed=104})

--@ chunk 11
print(wait(1440))
local ml, md, mr = nil, nil, nil
for _,p in ipairs(PL) do
  local r = math.random()
  local e = ellipse(p.cx + rand(-14,14), p.cy + rand(-14,14), p.w*rand(0.3,0.46), p.h*rand(0.3,0.46)):roughen(8, 40, math.random(1,999)):soften(6)
  e = e * poly(p.pts, true)
  if r < 0.4 then ml = ml and (ml+e) or e
  elseif r < 0.68 then md = md and (md+e) or e
  else mr = mr and (mr+e) or e end
end
local A = function(x,y) local k = math.floor(y/125)%8*8 + math.floor(x/125)%8 + 1; return PL[k].ang end
work(ml, {hand="scumble", pile=LIGHTB, coverage=1.6, load=0.55, pressure={0.3,0.7}, clip=PM, angle=A})
work(md, {hand="scumble", pile=DARKB, coverage=1.6, load=0.6, pressure={0.3,0.7}, clip=PM, angle=A})
work(mr, {hand="scumble", pile=REDB, coverage=1.5, load=0.55, pressure={0.3,0.7}, clip=PM, angle=A})
blend(PM:shrink(4), {angle=A})
BONE2 = pile{{"lead white",1.6},{"yellow ochre",1},{"raw sienna",0.8},{"bone brown",0.5}}
local v, h = nil, nil
for k=0,8 do
  local a = rect(k*125-3.5, -10, 7, 1020); v = v and (v+a) or a
  local b = rect(-10, k*125-3.5, 1020, 7); h = h and (h+b) or b
end
work(v, {hand="body", tool="flat 6", pile=BONE2, coverage=2.5, fill=true, clip=true, length={30,90}, angle=math.pi/2, load=0.8, shake=1.5})
work(h - v, {hand="body", tool="flat 6", pile=BONE2, coverage=2.5, fill=true, clip=true, length={30,90}, angle=0, load=0.8, shake=1.5})

--@ chunk 12
LUM={86,86,126,129,67,83,68,85,87,128,127,90,130,87,127,91,68,130,68,87,131,126,89,131,67,130,69,126,68,68,124,68,128,67,73,128,128,67,67,85,129,130,129,86,70,122,89,85,126,74,129,86,67,130,130,86,87,129,130,87,68,85,129,131}
print(wait(2880))
LINEL = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.45},{"burnt sienna",0.2}}
STUD2 = pile{{"yellow ochre",2},{"raw sienna",0.8},{"lead white",0.4},{"Indian yellow",0.2}}
local GA = 2.39996323
local pen = brush{kind="round", width=5, point=0.25, stiffness=0.55}
local dot = brush{kind="round", width=7.5, point=0.1}
local ne, nd = 0, 0
for idx,p in ipairs(PL) do
  local light = LUM[idx] > 110
  local lp = light and INK or LINEL
  local sp = light and DARKB or STUD2
  pen:reload(lp, 0.8); dot:reload(sp, 0.8)
  local kind = math.random()
  local cx, cy = p.cx + rand(-6,6), p.cy + rand(-6,6)
  local rot = idx * GA * 1.618
  local rmax = math.min(p.w, p.h) * rand(0.36, 0.44)
  if kind < 0.7 then
    local layers = math.random(2,3)
    local n0 = math.random(3,6)
    for L=1,layers do
      local n = n0 + L - 1
      local r = rmax * (1 - (L-1)*rand(0.27,0.33))
      local a0 = rot + (L-1)*GA
      local v = {}
      for k=0,n-1 do local a = a0 + k*2*math.pi/n; v[#v+1] = {cx + r*math.cos(a), cy + r*math.sin(a)} end
      for k=1,n do
        if ne % 5 == 0 then pen:load(lp, 0.7) end
        local a, b = v[k], v[k % n + 1]
        pen:stroke({{a[1],a[2]},{b[1],b[2]}}, {pressure={0.6,0.55}, ramps={0.08,0.1}, shake=0.6})
        ne = ne + 1
      end
    end
  end
  if kind > 0.42 then
    local N = math.random(13, 34)
    local c = (kind < 0.7 and rmax*0.55 or rmax*0.95) / math.sqrt(N)
    for k=1,N do
      if nd % 8 == 0 then dot:load(sp, 0.7) end
      local r = c * math.sqrt(k); local a = rot + k*GA
      dot:touch(cx + r*math.cos(a), cy + r*math.sin(a), {pressure=0.4 + 0.35*k/N})
      nd = nd + 1
    end
  end
end
print(ne, nd)

--@ chunk 13
print(wait(1440))
VEIL = pile{{"raw sienna",2},{"burnt sienna",0.6},{"bone brown",0.8},{"yellow ochre",0.8},{"lead white",0.3}, medium=0.7}
local m = poly(PL[1].pts, true) + poly(PL[2].pts, true)
work(m:shrink(3), {hand="glaze", pile=VEIL, coverage=1.2, load=0.35, clip=true, length={40,90}})

--@ chunk 14
print(wait(1440))
local GA = 2.39996323
local pen = brush{kind="round", width=5, point=0.25, stiffness=0.55}
local dot = brush{kind="round", width=7.5, point=0.1}
local function polyline(cx, cy, r, n, a0)
  local v = {}
  for k=0,n-1 do local a = a0 + k*2*math.pi/n; v[#v+1] = {cx + r*math.cos(a), cy + r*math.sin(a)} end
  for k=1,n do
    if k % 4 == 1 then pen:load(INK, 0.7) end
    local a, b = v[k], v[k % n + 1]
    pen:stroke({{a[1],a[2]},{b[1],b[2]}}, {pressure={0.6,0.5}, ramps={0.08,0.1}, shake=0.7})
  end
end
local p = PL[1]
polyline(p.cx+3, p.cy-2, 44, 7, 0.3)
polyline(p.cx+3, p.cy-2, 30, 5, 0.3+GA)
polyline(p.cx+3, p.cy-2, 15, 4, 0.3+2*GA)
p = PL[2]
polyline(p.cx-4, p.cy+3, 46, 3, -0.9)
local N = 21
for k=1,N do
  if k % 8 == 1 then dot:load(DARKB, 0.7) end
  local r = 5.2*math.sqrt(k); local a = 1.1 + k*GA
  dot:touch(p.cx-4 + r*math.cos(a), p.cy+3 + r*math.sin(a), {pressure=0.4 + 0.35*k/N})
end
