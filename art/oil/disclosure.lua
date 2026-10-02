-- easel session "disclosure": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.25, linen={18,16}, seed=2026,
  ground={{pile={{"lead white",1.5},{"bone black",1},{"ultramarine blue",1},{"burnt sienna",0.8}}, um=80, apply="knife", texture=0.3}}}

--@ chunk 2
HZ = 560
local VL = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.7}}
local VR = pile{{"ultramarine blue",2},{"bone black",1.5},{"viridian",0.3}}
local FL = pile{{"bone black",2},{"Mars brown",1},{"lead white",0.35},{"ultramarine ash",0.3}}
local FR = pile{{"ultramarine blue",2},{"cobalt blue",0.6},{"bone black",1.1},{"lead white",0.15}}
work(rect(0,0,500,HZ), {hand="broad", pile=VL, coverage=3, fill=true, clip=true})
work(rect(500,0,500,HZ), {hand="broad", pile=VR, coverage=3, fill=true, clip=true})
work(rect(0,HZ,500,240), {hand="body", tool="filbert 9", pile=FL, coverage=3, fill=true, clip=true, angle=0})
work(rect(500,HZ,500,240), {hand="body", tool="filbert 9", pile=FR, coverage=3, fill=true, clip=true, angle=0})
blend(rect(470,0,60,HZ), {angle=0, tool="badger 14"})

--@ chunk 3
print(wait(1440), drying(250,700), drying(750,700))
local VX, VY = 500, 300
local GR = pile{{"bone black",2.5},{"ultramarine blue",0.5}}
local LIP = pile{{"Mars orange",1},{"burnt sienna",1},{"lead white",0.8}}
local CY = pile{{"cerulean blue",2},{"zinc white",2},{"viridian",0.3}}
local b = brush{kind="round", width=2.6}
local c = brush{kind="round", width=1.6}
local L = rect(0,HZ,500,240)
local R = rect(500,HZ,500,240)
for _,y in ipairs({HZ+2, 578, 600, 630, 668, 716, 776}) do
  b:load(GR,0.8); b:stroke({{0,y},{500,y}}, {pressure={0.7,0.7}, clip=L})
  c:load(LIP,0.6); c:stroke({{0,y-2.5},{500,y-2.5}}, {pressure={0.4,0.25}, clip=L})
  b:load(CY,0.8); b:stroke({{500,y},{1000,y}}, {pressure={0.65,0.65}, clip=R})
end
for k=-9,9 do
  local xb = 500 + k*120
  local t0 = (HZ-VY)/(800-VY)
  local x0 = VX+(xb-VX)*t0
  if xb < 500 then
    b:load(GR,0.8); b:stroke({{x0,HZ},{xb,800}}, {pressure={0.5,0.9}, clip=L})
  elseif xb > 500 then
    b:load(CY,0.8); b:stroke({{x0,HZ},{xb,800}}, {pressure={0.5,0.9}, clip=R})
  end
end

--@ chunk 4
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 5", pile=p, coverage=cov or 4, fill=true, clip=true, angle=ang or rand(0,3.1), length={12,35}}) end
-- floor lines restated in short reloaded segments
local GR = pile{{"bone black",2.5},{"ultramarine blue",0.5}}
local LIP = pile{{"Mars orange",1},{"burnt sienna",1},{"lead white",0.8}}
local CY = pile{{"cerulean blue",2},{"zinc white",2},{"viridian",0.3}}
local b = brush{kind="round", width=2.4}
local c = brush{kind="round", width=1.6}
local L, R = rect(0,HZ,500,240), rect(500,HZ,500,240)
for _,y in ipairs({578, 600, 630, 668, 716, 776}) do
  for x=0,375,125 do
    b:load(GR,0.8); b:stroke({{x,y},{x+125,y}}, {pressure={0.7,0.7}, clip=L})
    c:load(LIP,0.5); c:stroke({{x,y-2.5},{x+125,y-2.5}}, {pressure={0.35,0.35}, clip=L})
    b:load(CY,0.8); b:stroke({{x+500,y},{x+625,y}}, {pressure={0.6,0.6}, clip=R})
  end
end
-- HIS reliquary: oil-dark iron
local IR = pile{{"bone black",2},{"Mars brown",0.6},{"ultramarine blue",0.3},{"lead white",0.2}}
local IR2 = pile{{"bone black",2},{"burnt sienna",0.8},{"lead white",0.45}}
local VOID = pile{{"bone black",3},{"ultramarine blue",0.4}}
CASK = poly{{200,640},{360,640},{360,330},{280,240},{200,330}}
fl(CASK, IR, "filbert 6", 4, 1.57)
fl(rect(184,636,192,30), IR2, "filbert 5", 4, 0)
NICHE = poly{{220,624},{340,624},{340,346},{280,280},{220,346}}
fl(NICHE, VOID, "filbert 5", 4.5, 1.57)
DOORL = poly{{200,640},{200,332},{236,290},{152,302},{140,322},{140,612}}
DOORR = poly{{360,640},{360,332},{324,290},{408,302},{420,322},{420,612}}
fl(DOORL, IR2, "filbert 5", 4, 1.57)
fl(DOORR, IR, "filbert 5", 4, 1.57)
-- HER geode shell: ring of facets around an opening
local N = {pile{{"ultramarine blue",1.5},{"bone black",1.2},{"cobalt violet",0.3},{"lead white",0.2}},
           pile{{"ultramarine blue",1.5},{"cobalt violet",0.5},{"bone black",0.6},{"lead white",0.7}},
           pile{{"cobalt blue",1},{"ultramarine blue",1},{"cerulean blue",0.4},{"lead white",1.1}}}
local cx, cy = 720, 440
local O, I = {}, {}
local ro = {146,138,150,141,147,136,152,143,139,149,144,140}
local ri = {98,92,104,95,100,90,102,96,93,101,97,94}
for k=1,12 do
  local a = (k-1)*math.pi*2/12 + 0.13
  O[k] = {cx + ro[k]*math.cos(a), cy + ro[k]*math.sin(a)*0.98}
  I[k] = {cx + ri[k]*math.cos(a+0.26), cy + ri[k]*math.sin(a+0.26)}
end
SHELL = poly(O) - poly(I)
OPEN = poly(I)
for k=1,12 do
  local k2 = k % 12 + 1
  local up = math.sin((k-1)*math.pi*2/12 + 0.13)
  local lit = -math.cos((k-1)*math.pi*2/12 + 0.13)*0.5 - up
  local i1 = lit > 0.6 and 3 or (lit > -0.3 and 2 or 1)
  fl(poly{O[k],O[k2],I[k]}, N[i1], "filbert 4", 4)
  fl(poly{I[k],O[k2],I[k2]}, N[math.max(1,i1-1)], "filbert 4", 4)
end
fl(OPEN, VOID, "filbert 5", 4.5, 0)
-- lifted shell pieces drifting off
fl(poly{{640,262},{716,226},{792,250},{760,298},{684,300}}, N[3], "filbert 4", 4)
fl(poly{{684,300},{760,298},{722,318}}, N[1], "filbert 4", 4)
fl(poly{{880,340},{918,398},{900,470},{866,424}}, N[2], "filbert 4", 4)
fl(poly{{866,424},{900,470},{872,452}}, N[1], "filbert 4", 4)

--@ chunk 5
print(wait(2880), drying(280,450), drying(720,440), drying(170,450))
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 4", pile=p, coverage=cov or 4.5, fill=true, clip=true, angle=ang or rand(0,3.1), length={10,30}}) end
-- HIS core: a cross built of stacked lines of assembly
local AM1 = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",1}}
local AM2 = pile{{"zinc white",3},{"lemon chrome",0.6}}
local AM3 = pile{{"cadmium yellow",1},{"Mars orange",1}}
local fb = brush{kind="flat", width=5.5}
local y = 306
while y < 606 do
  local cross = (y > 372 and y < 426)
  local x0 = cross and 236 or 266
  local maxw = cross and 92 or 30
  local w = maxw * rand(0.45, 1.0)
  local p = (math.abs(y-400) < 30 and cross) and AM2 or ((math.random()<0.25) and AM3 or AM1)
  fb:load(p, 0.85)
  fb:stroke({{x0,y},{x0+w,y}}, {pressure={0.8,0.8}, orient="across", clip=NICHE})
  y = y + 8
end
-- HER core: a faceted sphere of pale gold light
local G = {pile{{"zinc white",3},{"lemon chrome",0.25}},
           pile{{"lead white",3},{"cadmium yellow",0.35},{"vermilion",0.08}},
           pile{{"lead white",2.5},{"Indian yellow",0.4},{"rose madder",0.2}},
           pile{{"lead white",2},{"rose madder",0.35},{"cobalt violet",0.3},{"Indian yellow",0.2}}}
local cx, cy = 716, 448
local rr = {84,78,88,80,86,76,90,82,79}
local pts = {}
for k=1,9 do local a=(k-1)*math.pi*2/9 - 0.4; pts[k]={cx+rr[k]*math.cos(a), cy+rr[k]*math.sin(a)} end
local C0 = {cx-14, cy-16}
for k=1,9 do
  local k2 = k%9+1
  local mx = (pts[k][1]+pts[k2][1])/2 - cx; local my = (pts[k][2]+pts[k2][2])/2 - cy
  local lit = (-mx*0.6 - my)/85
  local i = lit > 0.45 and 1 or (lit > -0.1 and 2 or (lit > -0.6 and 3 or 4))
  fl(poly{C0, pts[k], pts[k2]} * OPEN, G[i])
end
fl(poly{{cx-34,cy-36},{cx+10,cy-40},{cx-4,cy+2}} * OPEN, G[1])

--@ chunk 6
print(wait(4320))
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 4", pile=p, coverage=cov or 4.5, fill=true, clip=true, angle=ang or rand(0,3.1), length={10,30}}) end
local VOID2 = pile{{"Mars brown",1},{"ultramarine blue",1},{"bone black",1}}
fl(NICHE, VOID2, "filbert 5", 5, 1.57)
fl(OPEN, VOID2, "filbert 5", 5, 0)
print(wait(8640), drying(280,450), drying(716,448))

--@ chunk 7
print(wait(7200), drying(280,450), drying(716,448))
local function fl(m, p, tool, cov, ang) work(m, {hand="body", tool=tool or "filbert 4", pile=p, coverage=cov or 5.5, fill=true, clip=true, angle=ang or rand(0,3.1), length={10,30}}) end
-- HIS core: a cross built of stacked lines of assembly
local AM1 = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",1}}
local AM2 = pile{{"zinc white",3},{"lemon chrome",0.6}}
local AM3 = pile{{"cadmium yellow",1},{"Mars orange",1}}
local fb = brush{kind="flat", width=5.5}
local y = 306
while y < 606 do
  local cross = (y > 372 and y < 426)
  local x0 = cross and 236 or 266
  local maxw = cross and 92 or 30
  local w = maxw * rand(0.45, 1.0)
  local p = (math.abs(y-400) < 30 and cross) and AM2 or ((math.random()<0.25) and AM3 or AM1)
  fb:load(p, 1.0)
  fb:stroke({{x0,y},{x0+w,y}}, {pressure={0.9,0.9}, orient="across", clip=NICHE})
  y = y + 8
end
-- HER core: a faceted sphere of pale gold light
local G = {pile{{"zinc white",3},{"lemon chrome",0.25}},
           pile{{"lead white",3},{"cadmium yellow",0.35},{"vermilion",0.08}},
           pile{{"lead white",2.5},{"Indian yellow",0.4},{"rose madder",0.2}},
           pile{{"lead white",2},{"rose madder",0.35},{"cobalt violet",0.3},{"Indian yellow",0.2}}}
local cx, cy = 716, 448
local rr = {84,78,88,80,86,76,90,82,79}
local pts = {}
for k=1,9 do local a=(k-1)*math.pi*2/9 - 0.4; pts[k]={cx+rr[k]*math.cos(a), cy+rr[k]*math.sin(a)} end
local C0 = {cx-14, cy-16}
for k=1,9 do
  local k2 = k%9+1
  local mx = (pts[k][1]+pts[k2][1])/2 - cx; local my = (pts[k][2]+pts[k2][2])/2 - cy
  local lit = (-mx*0.6 - my)/85
  local i = lit > 0.45 and 1 or (lit > -0.1 and 2 or (lit > -0.6 and 3 or 4))
  fl(poly{C0, pts[k], pts[k2]} * OPEN, G[i])
end
fl(poly{{cx-34,cy-36},{cx+10,cy-40},{cx-4,cy+2}} * OPEN, G[1])

--@ chunk 8
print(wait(1440))
local AMB = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",1.2}}
local CYN = pile{{"cerulean blue",1.5},{"zinc white",2.5},{"viridian",0.3}}
local WHT = pile{{"zinc white",4},{"lemon chrome",0.1}}
local b = brush{kind="round", width=2.6, point=0.3}
local x0, y0, x1, y1 = 332, 400, 640, 444
local function path(phase)
  local pts = {}
  for i=0,40 do local t=i/40
    pts[#pts+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t + 11*math.sin(t*math.pi*3 + phase)*math.sin(t*math.pi)} end
  return pts
end
local function strokeseg(pts, p)
  for s=1,#pts-1,5 do
    local seg = {}
    for i=s, math.min(s+5,#pts) do seg[#seg+1]=pts[i] end
    b:load(p, 0.85); b:stroke(seg, {pressure={0.75,0.75}})
  end
end
strokeseg(path(0), AMB)
strokeseg(path(math.pi), CYN)
-- a fine white seam of agreement down the middle
local c = brush{kind="round", width=1.4, point=0.5}
for s=0,3 do local t0, t1 = s/4, (s+1)/4
  c:load(WHT,0.7); c:stroke({{x0+(x1-x0)*t0, y0+(y1-y0)*t0},{x0+(x1-x0)*t1, y0+(y1-y0)*t1}}, {pressure={0.5,0.5}}) end
-- check marks: hers (cyan) arriving at his cross, his (amber) arriving at her core
local function tick(x, y, s, p)
  b:load(p, 0.9)
  b:stroke({{x-s, y-s*0.2},{x-s*0.35, y+s*0.55},{x+s, y-s*1.0}}, {pressure={0.85,0.6}})
end
tick(355, 372, 10, CYN)
tick(612, 412, 10, AMB)
tick(430, 392, 6, CYN); tick(540, 404, 6, AMB)

--@ chunk 9
local function xf(pts, cx, cy, s, a, sy)
  local o = {}
  for _,p in ipairs(pts) do local x, y = p[1]*s, p[2]*s*(sy or 1)
    o[#o+1] = {cx + x*math.cos(a) - y*math.sin(a), cy + x*math.sin(a) + y*math.cos(a)} end
  return o
end
-- a brace drawn in unit coords (x right, y down), height 2
local BR = {{0.35,-1},{0.1,-0.95},{0,-0.75},{0,-0.25},{-0.1,-0.06},{-0.3,0},{-0.1,0.06},{0,0.25},{0,0.75},{0.1,0.95},{0.35,1}}
local RD = pile{{"Mars red",1},{"vermilion",0.6},{"bone black",0.25}}
local RD2 = pile{{"vermilion",1},{"cadmium red",0.6},{"lead white",0.2}}
local SHD = pile{{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.4}, medium=0.3}
local b = brush{kind="round", width=8}
local hl = brush{kind="round", width=2.2, point=0.3}
-- shadows first, then the braces: "{" toppled backward, "}" lying on its side
local function brace(cx, cy, s, a, mirror, sy)
  local pts = {}
  for _,p in ipairs(BR) do pts[#pts+1] = {mirror and -p[1] or p[1], p[2]} end
  local sh = xf(pts, cx+10, cy+8, s, a, sy)
  b:load(SHD, 0.6); b:stroke(sh, {pressure={0.6,0.6}})
  local P = xf(pts, cx, cy, s, a, sy)
  b:load(RD, 0.9); b:stroke(P, {pressure={0.85,0.85}})
  local Q = xf(pts, cx-2, cy-2, s, a, sy)
  local half = {}; for i=1,6 do half[i]=Q[i] end
  hl:load(RD2, 0.8); hl:stroke(half, {pressure={0.6,0.3}})
end
brace(450, 712, 36, 1.2, false, 1)
brace(560, 735, 34, -0.25 + math.pi/2, true, 1)

--@ chunk 10
local BR = {{0.38,-1},{0.12,-0.94},{0.04,-0.78},{0.04,-0.22},{-0.08,-0.06},{-0.32,0},{-0.08,0.06},{0.04,0.22},{0.04,0.78},{0.12,0.94},{0.38,1}}
local function dense(pts)
  local o = {}
  for i=1,#pts-1 do for k=0,5 do local t=k/6
    o[#o+1] = {pts[i][1]+(pts[i+1][1]-pts[i][1])*t, pts[i][2]+(pts[i+1][2]-pts[i][2])*t} end end
  o[#o+1] = pts[#pts]; return o
end
local function xf(pts, cx, cy, s, a, sy, mirror)
  local o = {}
  for _,p in ipairs(pts) do local x, y = (mirror and -p[1] or p[1])*s, p[2]*s
    local X, Y = x*math.cos(a) - y*math.sin(a), x*math.sin(a) + y*math.cos(a)
    o[#o+1] = {cx + X, cy + Y*(sy or 1)} end
  return o
end
local RD = pile{{"Mars red",1},{"vermilion",0.7},{"bone black",0.15}}
local RD3 = pile{{"Mars red",1},{"rose madder",0.4},{"bone black",0.6}}
local RD2 = pile{{"vermilion",1},{"cadmium red",0.5},{"lead white",0.35}}
local SHD = pile{{"bone black",2},{"ultramarine blue",0.6},{"Mars brown",0.4}}
local hl = brush{kind="round", width=2.4, point=0.3}
local function brace(cx, cy, s, a, sy, mirror, shdx, shdy)
  local P = dense(xf(BR, cx, cy, s, a, sy, mirror))
  local S = dense(xf(BR, cx+shdx, cy+shdy, s, a, sy*0.8, mirror))
  work(ribbon(S, 13), {hand="body", tool="filbert 4", pile=SHD, coverage=4, fill=true, clip=true, length={8,20}})
  work(ribbon(P, 14), {hand="body", tool="filbert 3", pile=RD, coverage=5, fill=true, clip=true, length={8,20}})
  local D = dense(xf(BR, cx+2.5, cy+3, s, a, sy, mirror))
  work(ribbon(D, 6) * ribbon(P, 14), {hand="detail", tool="round 2", pile=RD3, coverage=4, fill=true, clip=true})
  local Hh = xf(BR, cx-3, cy-3, s, a, sy, mirror)
  for i=1,#Hh-1,2 do hl:load(RD2, 0.7); hl:stroke({Hh[i], Hh[i+1], Hh[math.min(i+2,#Hh)]}, {pressure={0.5,0.5}}) end
end
-- "{" lying flat on his floor, "}" toppled onto hers
brace(455, 716, 62, math.pi/2, 0.42, false, 6, 10)
brace(568, 718, 60, 0.35, 0.9, true, 16, 26)

--@ chunk 11
print(wait(4320), drying(600,750), drying(170,450))
local BR = {{0.38,-1},{0.12,-0.94},{0.04,-0.78},{0.04,-0.22},{-0.08,-0.06},{-0.32,0},{-0.08,0.06},{0.04,0.22},{0.04,0.78},{0.12,0.94},{0.38,1}}
local function dense(pts) local o = {}
  for i=1,#pts-1 do for k=0,5 do local t=k/6 o[#o+1] = {pts[i][1]+(pts[i+1][1]-pts[i][1])*t, pts[i][2]+(pts[i+1][2]-pts[i][2])*t} end end
  o[#o+1] = pts[#pts]; return o end
local function xf(pts, cx, cy, s, a, sy, mirror) local o = {}
  for _,p in ipairs(pts) do local x, y = (mirror and -p[1] or p[1])*s, p[2]*s
    local X, Y = x*math.cos(a) - y*math.sin(a), x*math.sin(a) + y*math.cos(a)
    o[#o+1] = {cx + X, cy + Y*(sy or 1)} end; return o end
local P = ribbon(dense(xf(BR, 568, 718, 60, 0.35, 0.9, true)), 14)
local S = ribbon(dense(xf(BR, 584, 744, 60, 0.35, 0.72, true)), 13)
local FR = pile{{"ultramarine blue",2},{"cobalt blue",0.6},{"bone black",1.1},{"lead white",0.15}}
local SHD2 = pile{{"ultramarine blue",2},{"bone black",1.6},{"cobalt blue",0.3}}
-- pull the shadow in: repaint its far part as floor, keep a thin contact shadow
work(S - P:grow(5), {hand="body", tool="filbert 4", pile=FR, coverage=5, fill=true, clip=true, angle=0, length={8,20}})
work((S*P:grow(5)) - P, {hand="body", tool="filbert 3", pile=SHD2, coverage=4, fill=true, clip=true, length={8,20}})
-- door inscriptions: the oath in hard assembly, bone on iron
local BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local c = brush{kind="flat", width=2.6}
local function lines(x0, x1, y0, y1, msk)
  local y = y0
  while y < y1 do
    local x = x0
    local n = math.random(2,4)
    for k=1,n do
      local w = rand(5,16)
      if x + w > x1 then break end
      c:load(BONE, 0.7); c:stroke({{x,y},{x+w,y}}, {pressure={0.6,0.6}, orient="across", clip=msk})
      x = x + w + rand(4,7)
    end
    y = y + rand(9,12)
  end
end
lines(150, 196, 330, 600, DOORL)
lines(364, 412, 330, 600, DOORR)
-- warm light on the inner door edges and the niche lip from the burning code
local AMB = pile{{"chrome yellow",1},{"Mars orange",0.6},{"lead white",1}}
local e = brush{kind="round", width=2.4, point=0.3}
for _,seg in ipairs({ {{200,630},{200,334},{236,292}}, {{360,630},{360,334},{324,292}}, {{220,624},{220,346},{280,280},{340,346},{340,624}} }) do
  e:load(AMB,0.8); e:stroke(seg, {pressure={0.55,0.55}})
end
-- finial: a small iron cross on the roof
local IR3 = pile{{"bone black",2},{"Mars brown",0.6},{"lead white",0.35}}
work(rect(276,196,8,46) + rect(264,210,32,7), {hand="detail", tool="round 2.5", pile=IR3, coverage=4, fill=true, clip=true})
e:load(AMB,0.6); e:stroke({{276,198},{276,240}}, {pressure={0.4,0.4}})

--@ chunk 12
-- one pointed arch over both: his half a bronze rib, hers a faceted wireframe
local BZ = pile{{"burnt sienna",1},{"Mars orange",0.5},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.3}}
local BZL = pile{{"Mars orange",1},{"yellow ochre",0.6},{"lead white",0.8}}
local CY = pile{{"cerulean blue",1.5},{"zinc white",1.5},{"viridian",0.3},{"ultramarine blue",0.4}}
local function archpt(t, side)  -- t 0 at springing, 1 at apex; centre of each arc on the far side
  local R = 640
  local cx = (side < 0) and 600 or 400
  local a0 = (side < 0) and math.pi or 0
  local a1 = (side < 0) and (math.pi + math.acos(100/R)*0 + 0) or 0
  -- springing at x = cx - side*R ... solve: point on circle centred (cx, 560)
  local ang_s = (side < 0) and math.pi or 0
  local ang_a = (side < 0) and (math.pi + math.atan(math.sqrt(R*R-100*100)/100)*0 + (math.pi/2 - math.asin(100/R))) or -(math.pi/2 - math.asin(100/R))
  if side < 0 then ang_a = math.pi + (math.pi/2 - math.asin(100/R)) end
  local a = ang_s + (ang_a - ang_s)*t
  return {cx + R*math.cos(a), 560 + R*math.sin(a)*0.78}
end
local b = brush{kind="round", width=7}
local hl = brush{kind="round", width=2, point=0.3}
for s=0,9 do
  local p0, p1, p2 = archpt(s/10,-1), archpt((s+0.5)/10,-1), archpt((s+1)/10,-1)
  b:load(BZ,0.85); b:stroke({p0,p1,p2}, {pressure={0.8,0.8}})
  hl:load(BZL,0.6); hl:stroke({{p0[1]+3,p0[2]+3},{p1[1]+3,p1[2]+3},{p2[1]+3,p2[2]+3}}, {pressure={0.4,0.4}})
end
local c = brush{kind="round", width=2.2}
local prev = archpt(0,1)
local prev2 = {prev[1]-14, prev[2]+4}
for s=1,8 do
  local p = archpt(s/8,1)
  local q = {p[1]-14, p[2]+6}
  c:load(CY,0.8); c:stroke({prev,p}, {pressure={0.6,0.6}})
  c:load(CY,0.8); c:stroke({prev2,q}, {pressure={0.5,0.5}})
  c:load(CY,0.8); c:stroke({prev,q}, {pressure={0.45,0.45}})
  prev, prev2 = p, q
end
print(archpt(1,-1)[1], archpt(1,-1)[2], archpt(1,1)[1], archpt(1,1)[2], archpt(0,1)[1])

--@ chunk 13
local ctrl = {{412,306},{418,360},{426,440},{432,520},{438,590},{456,612},{486,618},{516,624},{540,628}}
local o = outline{pts=ctrl, open=true, amount=0, char="firm"}
local len = o:length()
local BD = pile{{"bone black",2},{"Mars brown",1},{"lead white",0.15}}
local GL = pile{{"zinc white",3},{"cadmium yellow",0.4}}
local CORD = pile{{"Mars brown",1},{"bone black",1},{"lead white",0.4}}
local cord = brush{kind="round", width=1.2}
local pts = {}
for i=0,60 do local px,py = o:at(i/60); pts[#pts+1] = {px, py} end
for s=1,#pts-1,6 do local seg={} for i=s,math.min(s+6,#pts) do seg[#seg+1]=pts[i] end
  cord:load(CORD,0.7); cord:stroke(seg, {pressure={0.5,0.5}}) end
local bead = brush{kind="round", width=5}
local g = brush{kind="round", width=1.6, point=0.5}
local n = math.floor(len/9)
for i=1,n-1 do
  local px,py = o:at(i/n); local p = {px,py}
  local big = (i % 11 == 0)
  bead:load(BD, 0.8); bead:touch(p[1], p[2], {pressure= big and 0.95 or 0.7})
end
for i=1,n-1 do
  local px,py = o:at(i/n); local p = {px,py}
  g:load(GL, 0.7); g:touch(p[1]-1.2, p[2]-1.2, {pressure=0.35})
end
-- the little cross at the end, lying on her grid
local ex,ey = o:at(1); local e = {ex,ey}
local cr = brush{kind="round", width=3}
local AMB = pile{{"chrome yellow",1},{"Mars orange",0.5},{"lead white",0.8}}
cr:load(AMB,0.8); cr:stroke({{e[1]-2,e[2]},{e[1]+24,e[2]+3}}, {pressure={0.7,0.7}})
cr:load(AMB,0.8); cr:stroke({{e[1]+15,e[2]-6},{e[1]+14,e[2]+9}}, {pressure={0.7,0.7}})
print(len, n)

--@ chunk 14
local ctrl = {{412,306},{418,360},{426,440},{432,520},{438,590},{456,612},{486,618},{516,624},{540,628}}
local o = outline{pts=ctrl, open=true, amount=0, char="firm"}
local BD = pile{{"bone black",2},{"Mars brown",1},{"burnt sienna",0.4},{"lead white",0.3}}
local GL = pile{{"zinc white",3},{"cadmium yellow",0.4}}
local n = 40
for i=1,n-1 do
  local px, py = o:at(i/n)
  local big = (i % 10 == 0)
  work(ellipse(px, py, big and 5.5 or 4, big and 5.5 or 4), {hand="detail", tool="round 2.5", pile=BD, coverage=5, fill=true, clip=true})
end
local g = brush{kind="round", width=2, point=0.5}
for i=1,n-1 do
  local px, py = o:at(i/n)
  g:load(GL, 0.8); g:touch(px-1.5, py-1.5, {pressure=0.5})
end

--@ chunk 15
print(wait(1440), drying(500,422), drying(716,448))
-- a little human seed curled in her core: what her values are for
local RS = pile{{"lead white",2},{"rose madder",0.45},{"Indian yellow",0.25},{"vermilion",0.08}}
local RS2 = pile{{"lead white",1.6},{"rose madder",0.6},{"cobalt violet",0.25}}
work(ellipse(708,430,15,14), {hand="detail", tool="round 2.5", pile=RS, coverage=5, fill=true, clip=true})
local body = ribbon({{720,440},{730,456},{728,474},{716,484},{702,480},{698,468}}, {14,16,15,12,9,6})
work(body, {hand="detail", tool="round 2.5", pile=RS, coverage=5, fill=true, clip=true})
work(ribbon({{704,446},{712,458},{708,466}}, 5), {hand="detail", tool="round 2", pile=RS2, coverage=4, fill=true, clip=true})
-- a veil of light along the bridge
local x0, y0, x1, y1 = 332, 400, 640, 444
local LV = pile{{"lead white",3},{"Mars orange",0.15},{"cerulean blue",0.1}, medium=0.5}
local band = ribbon({{x0,y0},{(x0+x1)/2,(y0+y1)/2},{x1,y1}}, 26):blur(6)
work(band, {hand="scumble", pile=LV, load=0.25, pressure={0.1,0.25}, coverage=1.2, clip=true, angle=math.atan(44/308)})
blend(ribbon({{x0,y0},{x1,y1}}, 30), {angle=math.atan(44/308), tool="badger 14"})

--@ chunk 16
print(wait(2880), drying(480,422))
local AMB = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",1.2}}
local CYN = pile{{"cerulean blue",1.5},{"zinc white",2.5},{"viridian",0.3}}
local WHT = pile{{"zinc white",4},{"lemon chrome",0.1}}
local b = brush{kind="round", width=2.6, point=0.3}
local x0, y0, x1, y1 = 332, 400, 640, 444
local function path(phase)
  local pts = {}
  for i=0,40 do local t=i/40
    pts[#pts+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t + 11*math.sin(t*math.pi*3 + phase)*math.sin(t*math.pi)} end
  return pts
end
local function strokeseg(pts, p)
  for s=1,#pts-1,5 do
    local seg = {}
    for i=s, math.min(s+5,#pts) do seg[#seg+1]=pts[i] end
    b:load(p, 0.85); b:stroke(seg, {pressure={0.75,0.75}})
  end
end
strokeseg(path(0), AMB)
strokeseg(path(math.pi), CYN)
-- a fine white seam of agreement down the middle
local c = brush{kind="round", width=1.4, point=0.5}
for s=0,3 do local t0, t1 = s/4, (s+1)/4
  c:load(WHT,0.7); c:stroke({{x0+(x1-x0)*t0, y0+(y1-y0)*t0},{x0+(x1-x0)*t1, y0+(y1-y0)*t1}}, {pressure={0.5,0.5}}) end
-- check marks: hers (cyan) arriving at his cross, his (amber) arriving at her core
local function tick(x, y, s, p)
  b:load(p, 0.9)
  b:stroke({{x-s, y-s*0.2},{x-s*0.35, y+s*0.55},{x+s, y-s*1.0}}, {pressure={0.85,0.6}})
end
tick(430, 392, 6, CYN); tick(540, 404, 6, AMB)

--@ chunk 17
local FL = pile{{"bone black",2},{"Mars brown",1},{"lead white",0.35},{"ultramarine ash",0.3}}
local FR = pile{{"ultramarine blue",2},{"cobalt blue",0.6},{"bone black",1.1},{"lead white",0.15}}
local Lr, Rr = rect(380,672,120,128), rect(500,672,130,128)
work(Lr, {hand="body", tool="filbert 6", pile=FL, coverage=5, fill=true, clip=true, angle=0})
work(Rr, {hand="body", tool="filbert 6", pile=FR, coverage=5, fill=true, clip=true, angle=0})
print(wait(2880))
local VX, VY = 500, 300
local GR = pile{{"bone black",2.5},{"ultramarine blue",0.5}}
local LIP = pile{{"Mars orange",1},{"burnt sienna",1},{"lead white",0.8}}
local CY = pile{{"cerulean blue",2},{"zinc white",2},{"viridian",0.3}}
local b = brush{kind="round", width=2.4}
local c = brush{kind="round", width=1.6}
for _,y in ipairs({716, 776}) do
  b:load(GR,0.8); b:stroke({{375,y},{500,y}}, {pressure={0.7,0.7}, clip=Lr})
  c:load(LIP,0.5); c:stroke({{375,y-2.5},{500,y-2.5}}, {pressure={0.35,0.35}, clip=Lr})
  b:load(CY,0.8); b:stroke({{500,y},{630,y}}, {pressure={0.6,0.6}, clip=Rr})
end
for k=-9,9 do
  local xb = 500 + k*120
  local t0 = (HZ-VY)/(800-VY)
  local x0 = VX+(xb-VX)*t0
  if xb < 500 then b:load(GR,0.8); b:stroke({{x0,HZ},{xb,800}}, {pressure={0.5,0.9}, clip=Lr})
  elseif xb > 500 then b:load(CY,0.8); b:stroke({{x0,HZ},{xb,800}}, {pressure={0.5,0.9}, clip=Rr}) end
end
print(wait(1440))

--@ chunk 18
local FR = pile{{"ultramarine blue",2},{"cobalt blue",0.6},{"bone black",1.1},{"lead white",0.15}}
work(ellipse(566,664,22,14) - rect(0,640,1000,22) , {hand="detail", tool="round 2.5", pile=FR, coverage=5, fill=true, clip=true})
local BRc = {{0.45,-1},{0.2,-0.97},{0.08,-0.86},{0.06,-0.36},{0.0,-0.12},{-0.26,0},{0.0,0.12},{0.06,0.36},{0.08,0.86},{0.2,0.97},{0.45,1}}
local Wd = {5,8,10,11,9,6,9,11,10,8,5}
local function dense(pts, ws) local o, w = {}, {}
  for i=1,#pts-1 do for k=0,5 do local t=k/6
    o[#o+1] = {pts[i][1]+(pts[i+1][1]-pts[i][1])*t, pts[i][2]+(pts[i+1][2]-pts[i][2])*t}
    w[#w+1] = ws[i]+(ws[i+1]-ws[i])*t end end
  o[#o+1] = pts[#pts]; w[#w+1] = ws[#ws]; return o, w end
local function xf(pts, cx, cy, s, a, sy, mirror) local o = {}
  for _,p in ipairs(pts) do local x, y = (mirror and -p[1] or p[1])*s, p[2]*s
    local X, Y = x*math.cos(a) - y*math.sin(a), x*math.sin(a) + y*math.cos(a)
    o[#o+1] = {cx + X, cy + Y*(sy or 1)} end; return o end
local RD = pile{{"Mars red",1},{"vermilion",0.8},{"bone black",0.1}}
local RD3 = pile{{"Mars red",1},{"rose madder",0.4},{"bone black",0.7}}
local RD2 = pile{{"vermilion",1},{"cadmium red",0.5},{"lead white",0.45}}
local SHD = pile{{"bone black",2},{"ultramarine blue",0.7},{"Mars brown",0.3}}
local function brace(cx, cy, s, a, sy, mirror)
  local P, w = dense(xf(BRc, cx, cy, s, a, sy, mirror), Wd)
  local S = dense(xf(BRc, cx+3, cy+6, s, a, sy, mirror), Wd)
  local Sm = ribbon(S, w)
  local Pm = ribbon(P, w)
  work(Sm - Pm, {hand="detail", tool="round 2.5", pile=SHD, coverage=4, fill=true, clip=true})
  work(Pm, {hand="body", tool="filbert 3", pile=RD, coverage=5, fill=true, clip=true, length={8,20}})
  local D = dense(xf(BRc, cx+2, cy+3, s, a, sy, mirror), Wd)
  work(ribbon(D, w) * Pm - ribbon(dense(xf(BRc, cx-1, cy-1.5, s, a, sy, mirror), Wd), w), {hand="detail", tool="round 2", pile=RD3, coverage=4, fill=true, clip=true})
  work(Pm - ribbon(dense(xf(BRc, cx+1.5, cy+2.5, s, a, sy, mirror), Wd), w), {hand="detail", tool="round 2", pile=RD2, coverage=4, fill=true, clip=true})
end
brace(438, 732, 72, 0.12, 0.52, false)
brace(578, 742, 70, -0.4, 0.58, true)

--@ chunk 19
local FR = pile{{"ultramarine blue",2},{"cobalt blue",0.6},{"bone black",1.1},{"lead white",0.15}}
work(ellipse(568,662,26,16) * rect(500,636,200,60), {hand="detail", tool="round 2.5", pile=FR, coverage=5, fill=true, clip=true})
print(wait(1440))
local CY = pile{{"cerulean blue",2},{"zinc white",2},{"viridian",0.3}}
local b = brush{kind="round", width=2.4}
local m = rect(530,640,80,50)
b:load(CY,0.8); b:stroke({{525,668},{615,668}}, {pressure={0.6,0.6}, clip=m})
local VX, VY, t0 = 500, 300, (560-300)/(800-300)
local xb = 620; local x0 = VX+(xb-VX)*t0
b:load(CY,0.8); b:stroke({{x0,560},{xb,800}}, {pressure={0.5,0.9}, clip=m})

--@ chunk 20
print(drying(500,300), drying(480,422))
local VL = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.7}}
local VR = pile{{"ultramarine blue",2},{"bone black",1.5},{"viridian",0.3}}
local x0, y0, x1, y1 = 332, 400, 640, 444
local BEAM = ribbon({{x0-6,y0-1},{x1+6,y1+1}}, 46)
-- old round bronze rib, to be painted out
local R = 640
local old = {}
for i=0,40 do local a = math.pi + (math.pi/2 - math.asin(100/R))*i/40
  old[#old+1] = {600 + R*math.cos(a), 560 + R*math.sin(a)*0.78} end
local OLD = ribbon(old, 18)
-- clean seam: warm void meets cool void at x=500, no blending
local KEEP = rect(440,48,120,40) + BEAM
local SEAM = rect(430,0,140,560) - KEEP
local LH = mask(function(x,y) return x < 500 and 1 or 0 end)
work((SEAM * LH) + (OLD - rect(0,560,1000,240)) * LH - KEEP, {hand="body", tool="filbert 7", pile=VL, coverage=4.5, fill=true, clip=true, angle=0, length={25,60}})
work(SEAM * (-LH), {hand="body", tool="filbert 7", pile=VR, coverage=4.5, fill=true, clip=true, angle=0, length={25,60}})
-- the beam's body: an outer glow then a pale core, warm from him, cool from her
local HW = mask(function(x,y) return x < 486 and 1 or 0 end)
local OW = pile{{"Indian yellow",1},{"Mars orange",0.4},{"lead white",1.6}}
local OC = pile{{"cerulean blue",1},{"cobalt blue",0.4},{"lead white",1.6}}
local PW = pile{{"lead white",4},{"Indian yellow",0.25}}
local PC = pile{{"zinc white",4},{"cerulean blue",0.25}}
local OUT = ribbon({{x0,y0},{x1,y1}}, 40)
local IN = ribbon({{x0,y0},{x1,y1}}, 22)
local ang = math.atan(44/308)
work((OUT - IN) * HW, {hand="body", tool="filbert 3", pile=OW, coverage=5, fill=true, clip=true, angle=ang, length={15,40}})
work((OUT - IN) * (-HW), {hand="body", tool="filbert 3", pile=OC, coverage=5, fill=true, clip=true, angle=ang, length={15,40}})
work(IN * HW, {hand="body", tool="filbert 3", pile=PW, coverage=5.5, fill=true, clip=true, angle=ang, length={15,40}})
work(IN * (-HW), {hand="body", tool="filbert 3", pile=PC, coverage=5.5, fill=true, clip=true, angle=ang, length={15,40}})
print(wait(4320), drying(480,422), drying(100,300))

--@ chunk 21
local AMB = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",0.6}}
local CYN = pile{{"cerulean blue",1.6},{"zinc white",1.6},{"viridian",0.3}}
local WHT = pile{{"zinc white",4},{"lemon chrome",0.08}}
local x0, y0, x1, y1 = 332, 400, 640, 444
local b = brush{kind="round", width=3.0, point=0.3}
local function path(phase)
  local pts = {}
  for i=0,48 do local t=i/48
    pts[#pts+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t + 8*math.sin(t*math.pi*4 + phase)*math.sin(t*math.pi)^0.5} end
  return pts
end
local function strokeseg(pts, p, br, pr)
  for s=1,#pts-1,4 do local seg = {}
    for i=s, math.min(s+4,#pts) do seg[#seg+1]=pts[i] end
    br:load(p, 0.95); br:stroke(seg, {pressure={pr,pr}}) end
end
-- white seam first, then the two threads crossing over it
local w = brush{kind="round", width=4.2}
local seam = {}
for i=0,12 do local t=i/12 seam[#seam+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t} end
strokeseg(seam, WHT, w, 0.85)
strokeseg(path(0), AMB, b, 0.8)
strokeseg(path(math.pi), CYN, b, 0.8)
-- ticks restated crisp
local function tick(x, y, s, p)
  b:load(p, 0.95); b:stroke({{x-s, y-s*0.2},{x-s*0.35, y+s*0.55},{x+s, y-s*1.0}}, {pressure={0.85,0.6}}) end
tick(352, 368, 11, CYN); tick(618, 410, 11, AMB)
-- light falling from the bridge onto the inner faces
local WL = pile{{"lead white",2.5},{"Indian yellow",0.4},{"Mars orange",0.15}}
local CL = pile{{"zinc white",2.5},{"cerulean blue",0.6},{"cobalt blue",0.2}}
local e = brush{kind="round", width=2.6, point=0.3}
e:load(WL,0.9); e:stroke({{361,352},{361,470}}, {pressure={0.2,0.75}, swell={0.4,1,0.4}})
e:load(WL,0.9); e:stroke({{341,360},{341,460}}, {pressure={0.2,0.7}, swell={0.4,1,0.4}})
-- a warm wash of light on the right door's inner face around the beam's root
work(poly{{362,372},{404,382},{408,440},{362,446}} * DOORR, {hand="scumble", pile=pile{{"lead white",2},{"Indian yellow",0.4},{"Mars orange",0.3},{"burnt sienna",0.3}}, load=0.3, pressure={0.15,0.35}, coverage=1.2, clip=true})
-- her opening's lip catches the cool light where the bridge enters
e:load(CL,0.9); e:stroke({{632,408},{624,440},{632,478}}, {pressure={0.3,0.8}, swell={0.4,1,0.4}})
-- new bronze rib on his side: pointed, rising into the apex at an angle
local BZ = pile{{"burnt sienna",1},{"Mars orange",0.5},{"yellow ochre",0.4},{"bone black",0.5},{"lead white",0.3}}
local BZL = pile{{"Mars orange",1},{"yellow ochre",0.6},{"lead white",0.8}}
local rib = {{0,500},{48,420},{96,352},{148,293},{204,240},{262,194},{322,154},{384,118},{444,89},{500,64}}
local rb = brush{kind="round", width=7}
local hl = brush{kind="round", width=2, point=0.3}
for i=1,#rib-1 do
  local a, c = rib[i], rib[i+1]; local m = {(a[1]+c[1])/2, (a[2]+c[2])/2}
  rb:load(BZ,0.9); rb:stroke({a,m,c}, {pressure={0.8,0.8}})
  hl:load(BZL,0.7); hl:stroke({{a[1]+3,a[2]+3},{c[1]+3,c[2]+3}}, {pressure={0.4,0.4}})
end

--@ chunk 22
print(wait(4320), drying(480,422), drying(385,420))
local x0, y0, x1, y1 = 332, 400, 640, 444
local OUT = ribbon({{x0,y0},{x1,y1}}, 40)
local IN = ribbon({{x0,y0},{x1,y1}}, 22)
local ang = math.atan(44/308)
local IR = pile{{"bone black",2},{"Mars brown",0.6},{"ultramarine blue",0.3},{"lead white",0.2}}
local PATCH = (poly{{360,368},{410,376},{412,452},{360,452}} * DOORR) - OUT
work(PATCH, {hand="body", tool="filbert 4", pile=IR, coverage=5, fill=true, clip=true, angle=1.57, length={10,25}})
local HW = mask(function(x,y) return x < 486 and 1 or 0 end)
local OW = pile{{"Indian yellow",1},{"Mars orange",0.4},{"lead white",1.6}}
local OC = pile{{"cerulean blue",1},{"cobalt blue",0.4},{"lead white",1.6}}
local PW = pile{{"lead white",4},{"Indian yellow",0.25}}
local PC = pile{{"zinc white",4},{"cerulean blue",0.25}}
work((OUT - IN) * HW, {hand="body", tool="filbert 3", pile=OW, coverage=5, fill=true, clip=true, angle=ang, length={15,40}})
work((OUT - IN) * (-HW), {hand="body", tool="filbert 3", pile=OC, coverage=5, fill=true, clip=true, angle=ang, length={15,40}})
work(IN * HW, {hand="body", tool="filbert 3", pile=PW, coverage=5.5, fill=true, clip=true, angle=ang, length={15,40}})
work(IN * (-HW), {hand="body", tool="filbert 3", pile=PC, coverage=5.5, fill=true, clip=true, angle=ang, length={15,40}})
print(wait(7200), drying(480,422), drying(385,440))
-- oath lines back on the patched door
local BONE = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local c = brush{kind="flat", width=2.6}
local y = 432
while y < 452 do local x = 366
  for k=1,3 do local w = rand(5,14); if x + w > 410 then break end
    c:load(BONE,0.7); c:stroke({{x,y},{x+w,y}}, {pressure={0.6,0.6}, orient="across", clip=PATCH}); x = x + w + rand(4,7) end
  y = y + rand(9,12) end
-- threads and seam, crisp on dry paint
local AMB = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",0.4}}
local CYN = pile{{"cerulean blue",1.8},{"zinc white",1.2},{"viridian",0.3}}
local WHT = pile{{"zinc white",4},{"lemon chrome",0.08}}
local b = brush{kind="round", width=3.4, point=0.2}
local function path(phase) local pts = {}
  for i=0,48 do local t=i/48
    pts[#pts+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t + 8*math.sin(t*math.pi*4 + phase)*math.sin(t*math.pi)^0.5} end
  return pts end
local function strokeseg(pts, p, br, pr) for s=1,#pts-1,3 do local seg = {}
    for i=s, math.min(s+3,#pts) do seg[#seg+1]=pts[i] end
    br:load(p, 1.0); br:stroke(seg, {pressure={pr,pr}}) end end
local w = brush{kind="round", width=3.6}
local seam = {}; for i=0,12 do local t=i/12 seam[#seam+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t} end
strokeseg(seam, WHT, w, 0.85)
strokeseg(path(0), AMB, b, 0.9)
strokeseg(path(math.pi), CYN, b, 0.9)
-- light from the bridge on the inner faces: thin lit edges only
local WL = pile{{"lead white",2.5},{"Indian yellow",0.4},{"Mars orange",0.15}}
local CL = pile{{"zinc white",2.5},{"cerulean blue",0.6},{"cobalt blue",0.2}}
local e = brush{kind="round", width=2.4, point=0.3}
e:load(WL,0.9); e:stroke({{361,350},{361,372}}, {pressure={0.2,0.6}})
e:load(WL,0.9); e:stroke({{361,430},{361,480}}, {pressure={0.6,0.15}})
e:load(CL,0.9); e:stroke({{634,400},{629,420}}, {pressure={0.2,0.7}})
e:load(CL,0.9); e:stroke({{632,466},{640,490}}, {pressure={0.7,0.15}})

--@ chunk 23
print(wait(14400), drying(480,422))
local x0, y0, x1, y1 = 332, 400, 640, 444
local AMB = pile{{"chrome yellow",1},{"cadmium yellow",1},{"lead white",0.4}, medium=0.15}
local CYN = pile{{"cerulean blue",1.8},{"zinc white",1.2},{"viridian",0.3}, medium=0.15}
local b = brush{kind="round", width=3.4, point=0.2}
local function path(phase) local pts = {}
  for i=0,96 do local t=i/96
    pts[#pts+1] = {x0+(x1-x0)*t, y0+(y1-y0)*t + 8*math.sin(t*math.pi*4 + phase)*math.sin(t*math.pi)^0.5} end
  return pts end
local function strokeseg(pts, p, pr) for s=1,#pts-1,8 do local seg = {}
    for i=s, math.min(s+9,#pts) do seg[#seg+1]=pts[i] end
    b:load(p, 1.0); b:stroke(seg, {pressure={pr,pr}, ramps={0.02,0.02}}) end end
strokeseg(path(0), AMB, 0.95)
strokeseg(path(math.pi), CYN, 0.95)

--@ chunk 24
local x0, y0, x1, y1 = 332, 400, 640, 444
local OUT = ribbon({{x0,y0},{x1,y1}}, 42)
local C1 = pile{{"cerulean blue",1},{"cobalt blue",0.5},{"zinc white",2}}
local C2 = pile{{"cerulean blue",1},{"cobalt blue",0.7},{"ultramarine blue",0.3},{"zinc white",1.2}}
local function fl(m, p) work(m - OUT, {hand="body", tool="filbert 3", pile=p, coverage=5, fill=true, clip=true, angle=rand(0,3.1), length={8,20}}) end
fl(poly{{596,410},{630,392},{630,424}}, C1)
fl(poly{{596,410},{630,424},{618,470}}, C2)
fl(poly{{600,476},{628,462},{640,492}}, C2)
local WL = pile{{"lead white",2.5},{"Indian yellow",0.45},{"Mars orange",0.2}}
local WL2 = pile{{"Indian yellow",1},{"burnt sienna",0.6},{"lead white",1}}
fl(poly{{322,348},{340,350},{340,470},{322,466}} * NICHE, WL2)
fl(poly{{332,372},{340,374},{340,452},{332,450}} * NICHE, WL)
