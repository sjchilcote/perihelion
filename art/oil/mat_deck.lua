-- easel session "mat_deck": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen=18, seed=731,
  ground={{pile={{"lead white",3},{"bone black",1.2},{"ultramarine blue",0.4},{"viridian",0.15}}, um=120, apply="knife", texture=0.3}}}
print(W,H)

--@ chunk 2
G1 = pile{{"lead white",2},{"bone black",1.1},{"ultramarine blue",0.25},{"viridian",0.3},{"raw sienna",0.15}}
G2 = pile{{"lead white",2},{"bone black",1.25},{"ultramarine blue",0.2},{"viridian",0.2},{"raw sienna",0.25}}
GT = pile{{"lead white",1.6},{"bone black",1.3},{"ultramarine blue",0.25},{"viridian",0.25},{"raw sienna",0.2}}
GR = pile{{"lead white",2},{"bone black",1.0},{"yellow ochre",0.45},{"viridian",0.35},{"burnt sienna",0.12}}
PT = {}  -- plate types
for r=0,3 do for c=0,3 do PT[r*4+c] = ((r+c)%2==0) and "G1" or "G2" end end
PT[0*4+1]="T"; PT[1*4+3]="T"; PT[2*4+0]="T"; PT[3*4+2]="T"
PT[1*4+1]="S"; PT[2*4+2]="R"
PILES = {G1=G1,G2=G2,T=GT,S=G1,R=GR}
function plate_fill(c, r)
  local k = PT[r*4+c]
  local m = rect(c*250+2, r*250+2, 246, 246)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  work(m, {hand="body", pile=PILES[k], tool="filbert 12", angle=ang, angle_jitter=0.04, length={60,160}, coverage=3, fill=true, clip=true, seed=100+r*4+c})
end
plate_fill(0,0)

--@ chunk 3
G1 = pile{{"lead white",2},{"bone black",1.3},{"ultramarine blue",0.3},{"viridian",0.3},{"raw sienna",0.15}}
G2 = pile{{"lead white",2},{"bone black",1.45},{"ultramarine blue",0.25},{"viridian",0.2},{"raw sienna",0.25}}
GT = pile{{"lead white",1.6},{"bone black",1.5},{"ultramarine blue",0.3},{"viridian",0.25},{"raw sienna",0.2}}
GR = pile{{"lead white",2},{"bone black",1.2},{"yellow ochre",0.45},{"viridian",0.35},{"burnt sienna",0.12}}
PILES = {G1=G1,G2=G2,T=GT,S=G1,R=GR}
function plate_fill(c, r)
  local k = PT[r*4+c]
  local m = rect(c*250+2, r*250+2, 246, 246)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  work(m, {hand="body", pile=PILES[k], tool="filbert 12", angle=ang, angle_jitter=0.03, curve={0.03,0.01}, length={60,160}, coverage=3, fill=true, clip=true, seed=100+r*4+c})
end
for r=0,3 do for c=0,3 do if not (r==0 and c==0) then plate_fill(c,r) end end end

--@ chunk 4
print(wait(2*24*60), drying(125,125), drying(375,125), drying(625,625))
LUG = pile{{"lead white",2},{"bone black",0.85},{"ultramarine blue",0.2},{"viridian",0.2},{"raw sienna",0.1}}
lugb = brush{kind="round", width=3.2, point=0.2, stiffness=0.6}
function tread(c, r)
  local s = 250/16
  local x0, y0 = c*250, r*250
  local n = 0
  for i=1,14 do for j=1,14 do
    local cx, cy = x0 + (i+0.5)*s, y0 + (j+0.5)*s
    local a = ((i+j)%2==0) and math.pi/4 or -math.pi/4
    local L = 4.6 + rand(-0.3,0.3)
    if n % 6 == 0 then lugb:load(LUG, rand(0.55,0.75)) end
    n = n + 1
    local dx, dy = math.cos(a)*L, math.sin(a)*L
    lugb:stroke({{cx-dx+rand(-0.4,0.4), cy-dy+rand(-0.4,0.4)},{cx+dx, cy+dy}}, {pressure={0.75,0.6}, ramps={0.15,0.25}})
  end end
end
tread(1,0)

--@ chunk 5
tread(3,1) tread(0,2) tread(2,3)

--@ chunk 6
SEAM = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5},{"lead white",0.35}}
local m = rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  m = m + rect(p-2.6, 0, 5.2, 1000) + rect(0, p-2.6, 1000, 5.2)
end
-- subdivided plate (1,1): 125 sub-seams, thinner
m = m + rect(375-1.8, 250, 3.6, 250) + rect(250, 375-1.8, 250, 3.6)
work(m, {hand="detail", pile=SEAM, tool={kind="round", width=3, point=0.3}, ruler=true, length={30,90}, coverage=3, fill=true, clip=true, seed=61})

--@ chunk 7
print(wait(2*24*60), drying(625,625), drying(250,500))
GR2 = pile{{"lead white",2},{"bone black",1.35},{"viridian",0.45},{"yellow ochre",0.2},{"ultramarine blue",0.1},{"burnt sienna",0.06}}
work(rect(502,502,246,246), {hand="body", pile=GR2, tool="filbert 12", angle=0, angle_jitter=0.03, curve={0.03,0.01}, length={60,160}, coverage=2.2, load=0.6, fill=true, clip=true, seed=909})
RIV = {}
local ts = {}
for k=0,7 do ts[#ts+1] = 14 + k*222/7 end
for r=0,3 do for c=0,3 do
  local x0,y0 = c*250, r*250
  for k=1,8 do
    RIV[#RIV+1] = {x0+ts[k], y0+14}
    RIV[#RIV+1] = {x0+ts[k], y0+236}
    if k>1 and k<8 then
      RIV[#RIV+1] = {x0+14, y0+ts[k]}
      RIV[#RIV+1] = {x0+236, y0+ts[k]}
    end
  end
end end
print(#RIV)
RD = pile{{"bone black",1.6},{"burnt sienna",0.5},{"ultramarine blue",0.4},{"lead white",0.6}}
rb = brush{kind="round", width=6, stiffness=0.6}
for i,p in ipairs(RIV) do
  if i % 8 == 1 then rb:load(RD, 0.6) end
  rb:touch(p[1]+rand(-0.3,0.3), p[2]+rand(-0.3,0.3), {pressure=0.75})
end

--@ chunk 8
print(wait(3*24*60), drying(625,625), drying(14+250,14))
-- restate rivet holes on the replacement plate
for i,p in ipairs(RIV) do
  if p[1] > 500 and p[1] < 750 and p[2] > 500 and p[2] < 750 then
    if i % 6 == 0 then rb:load(RD, 0.6) end
    rb:touch(p[1], p[2], {pressure=0.75})
  end
end

--@ chunk 9
print(wait(2*24*60), drying(625+111,514))
RH = pile{{"lead white",2},{"bone black",0.8},{"ultramarine blue",0.15},{"viridian",0.2},{"raw sienna",0.15}}
hb = brush{kind="round", width=4.2, stiffness=0.6}
for i,p in ipairs(RIV) do
  if i % 6 == 1 then hb:load(RH, 0.55) end
  hb:touch(p[1]+rand(-0.5,0.5), p[2]+rand(-0.5,0.5), {pressure=0.6})
end

--@ chunk 10
GRIME = pile{{"bone black",1},{"raw sienna",0.6},{"burnt sienna",0.25},{"lead white",0.9},{"ultramarine blue",0.2}, medium=0.25}
local m = rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  m = m + rect(p-9, 0, 18, 1000) + rect(0, p-9, 1000, 18)
end
m = m + rect(375-6, 250, 12, 250) + rect(250, 375-6, 250, 12)
m = m:roughen(4, 40, 7)
local nz = noise{seed=17, period=90, octaves=3}
stipple(m, {pile=GRIME, width=4, coverage=function(x,y) return 0.5 + 0.6*nz:at01(x,y) end, pressure={0.25,0.55}, dips={16,0.35,0.5}, feather=0.5, cluster={0.5,6}, clip=true, seed=33})

--@ chunk 11
local v, h = rect(0,0,0,0), rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  v = v + rect(p-10, 0, 20, 1000); h = h + rect(0, p-10, 1000, 20)
end
v = v + rect(375-7, 250, 14, 250); h = h + rect(250, 375-7, 250, 14)
blend(v, {angle=math.pi/2, tool={kind="filbert", width=8, stiffness=0.3}, seed=5})
blend(h, {angle=0, tool={kind="filbert", width=8, stiffness=0.3}, seed=6})

--@ chunk 12
print(wait(24*60))
function tileable(n)
  return function(x, y)
    local u, v = x/1000, y/1000
    local a = (1-u)*(1-v)*n(x,y) + u*(1-v)*n(x-1000,y) + (1-u)*v*n(x,y-1000) + u*v*n(x-1000,y-1000)
    local w = math.sqrt((1-u)^2*(1-v)^2 + u^2*(1-v)^2 + (1-u)^2*v^2 + u^2*v^2)
    return a / w
  end
end
DIRT = pile{{"bone black",1.25},{"raw sienna",0.35},{"ultramarine blue",0.25},{"viridian",0.15},{"lead white",0.9}}
local t = tileable(noise{seed=4, period=160, octaves=4})
local m = mask(function(x,y) return smoothstep(-0.05, 0.35, t(x,y)) end)
print(m:area())
work(m, {hand="scumble", pile=DIRT, load=0.35, coverage=1.4, pressure={0.3,0.6}, clip=m, threshold=0.3, seed=71})

--@ chunk 13
function plate_blend(c, r, sd)
  local m = rect(c*250+4, r*250+4, 242, 242)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  blend(m, {angle=ang, seed=sd})
end
plate_blend(0,0,1)

--@ chunk 14
local m = rect(504, 4, 242, 242)
work(m, {hand="body", blender=true, tool="filbert 14", angle=0, length={60,160}, coverage=3, pressure={0.6,0.9}, dips={1,0,0.95}, clip=true, seed=8})

--@ chunk 15
for r=0,1 do for c=0,3 do if not (r==0 and c==0) then plate_blend(c,r,10+r*4+c) end end end

--@ chunk 16
for r=2,3 do for c=0,3 do plate_blend(c,r,10+r*4+c) end end

--@ chunk 17
print(wait(3*24*60)) for _,p in ipairs({{100,100},{400,400},{600,300},{900,900},{250,250}}) do print(drying(p[1],p[2])) end

--@ chunk 18
TN = tileable(noise{seed=29, period=220, octaves=3})
function plate_pile(c, r)
  local k = PT[r*4+c]
  local s = (c*7 + r*5) % 6
  if k == "R" then
    return pile{{"lead white",2},{"bone black",1.3},{"viridian",0.45},{"yellow ochre",0.25},{"ultramarine blue",0.1},{"burnt sienna",0.08}}
  end
  return pile{{"lead white",2},{"bone black",1.2 + 0.06*s},{"ultramarine blue",0.18 + 0.03*((s+2)%4)},{"viridian",0.15 + 0.05*((s+1)%4)},{"raw sienna",0.08 + 0.04*(s%3)}}
end
function plate_paint(c, r, sd)
  local m = rect(c*250+5, r*250+5, 240, 240)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local p = plate_pile(c, r)
  local opt = {hand="body", pile=p, tool="filbert 12", angle=ang, angle_jitter=0.03, curve={0.03,0.01}, length={70,180}, load=0.55, clip=true}
  opt.coverage = 0.9; opt.seed = sd
  work(m, opt)
  local mm = m * mask(function(x,y) return smoothstep(-0.2, 0.2, TN(x,y)) end)
  opt.coverage = 2.2; opt.seed = sd + 1; opt.clip = m; opt.fill = true
  work(mm, opt)
end
plate_paint(0,0,300)

--@ chunk 19
function plate_paint(c, r, sd)
  local m = rect(c*250+5, r*250+5, 240, 240)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local p = plate_pile(c, r)
  local opt = {hand="body", pile=p, tool="filbert 12", angle=ang, angle_jitter=0.03, curve={0.03,0.01}, length={70,180}, load=0.5, clip=true}
  opt.coverage = 0.6; opt.seed = sd
  work(m, opt)
  local mm = m * mask(function(x,y) return smoothstep(-0.15, 0.25, TN(x,y)) end)
  opt.coverage = 1.6; opt.seed = sd + 1; opt.clip = m
  work(mm, opt)
end
for r=0,1 do for c=0,3 do if not (r==0 and c==0) then plate_paint(c,r,300+10*(r*4+c)) end end end

--@ chunk 20
for r=2,3 do for c=0,3 do plate_paint(c,r,300+10*(r*4+c)) end end

--@ chunk 21
for r=0,1 do for c=0,3 do plate_blend(c,r,500+r*4+c) end end

--@ chunk 22
blend(rect(4,504,242,242), {angle=math.pi/2, coverage=0.5, pressure={0.2,0.4}, seed=77})

--@ chunk 23
for r=2,3 do for c=0,3 do plate_blend(c,r,600+r*4+c) end end

--@ chunk 24
print(wait(3*24*60), drying(125,125), drying(625,625))

--@ chunk 25
DK = pile{{"lead white",1.6},{"bone black",1.35},{"ultramarine blue",0.3},{"viridian",0.2},{"raw sienna",0.3}}
TD = pile{{"lead white",1.5},{"bone black",1.4},{"ultramarine blue",0.35},{"viridian",0.25},{"raw sienna",0.15}}
local function over(m, p, ang, load, cov, sd)
  work(m, {hand="body", pile=p, tool="filbert 12", angle=ang, angle_jitter=0.04, curve={0.04,0.02}, length={50,150}, load=load, coverage=cov, pressure={0.4,0.8}, clip=true, seed=sd})
end
-- darker grimy plates
over(rect(503,3,244,244), DK, 0, 0.4, 1.4, 701)
over(rect(3,253,244,244), DK, math.pi/2, 0.4, 1.4, 702)
over(rect(753,503,244,244), DK, math.pi/2, 0.4, 1.4, 703)
over(rect(253,753,244,244), DK, 0, 0.4, 1.4, 704)
-- two quadrants of the subdivided plate
over(rect(253,253,121,121), DK, 0, 0.45, 1.8, 705)
over(rect(377,377,120,120), DK, math.pi/2, 0.45, 1.8, 706)
-- tread plates: dark base
for _,cr in ipairs({{1,0},{3,1},{0,2},{2,3}}) do
  over(rect(cr[1]*250+3, cr[2]*250+3, 244, 244), TD, ((cr[1]*3+cr[2])%2==0) and 0 or math.pi/2, 0.6, 2.4, 710+cr[1]+cr[2]*4)
end

--@ chunk 26
print(wait(2*24*60), drying(375,125), drying(625,125))
LUG = pile{{"lead white",2},{"bone black",0.75},{"ultramarine blue",0.2},{"viridian",0.2},{"raw sienna",0.1}}
lugb = brush{kind="round", width=3.8, point=0.2, stiffness=0.6}
tread(1,0) tread(3,1) tread(0,2) tread(2,3)
local m = rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  m = m + rect(p-2.4, 0, 4.8, 1000) + rect(0, p-2.4, 1000, 4.8)
end
m = m + rect(375-1.8, 250, 3.6, 250) + rect(250, 375-1.8, 250, 3.6)
SEAM2 = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4},{"viridian",0.15},{"lead white",0.5}}
work(m, {hand="detail", pile=SEAM2, tool={kind="round", width=3, point=0.3}, ruler=true, length={30,90}, coverage=2.5, fill=true, clip=true, seed=62})

--@ chunk 27
print(wait(24*60))
for i,p in ipairs(RIV) do
  if i % 8 == 1 then rb:load(RD, 0.6) end
  rb:touch(p[1]+rand(-0.3,0.3), p[2]+rand(-0.3,0.3), {pressure=0.7})
end
GR3 = pile{{"bone black",1},{"raw sienna",0.5},{"burnt sienna",0.2},{"lead white",1.0},{"ultramarine blue",0.25},{"viridian",0.1}}
local v, h = rect(0,0,0,0), rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  v = v + rect(p-9, 0, 18, 1000); h = h + rect(0, p-9, 1000, 18)
end
v = v + rect(375-6, 250, 12, 250); h = h + rect(250, 375-6, 250, 12)
v = v:roughen(3, 30, 11); h = h:roughen(3, 30, 12)
work(v, {hand="body", pile=GR3, tool="filbert 6", angle=math.pi/2, angle_jitter=0.05, length={20,70}, load=0.3, coverage=1.0, pressure={0.3,0.6}, clip=v, seed=81})
work(h, {hand="body", pile=GR3, tool="filbert 6", angle=0, angle_jitter=0.05, length={20,70}, load=0.3, coverage=1.0, pressure={0.3,0.6}, clip=h, seed=82})

--@ chunk 28
local v, h = rect(0,0,0,0), rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  v = v + rect(p-12, 0, 24, 1000); h = h + rect(0, p-12, 1000, 24)
end
v = v + rect(375-9, 250, 18, 250); h = h + rect(250, 375-9, 250, 18)
blend(v, {angle=math.pi/2, tool={kind="filbert", width=10, stiffness=0.3}, seed=15})
blend(h, {angle=0, tool={kind="filbert", width=10, stiffness=0.3}, seed=16})

--@ chunk 29
print(wait(4*24*60), drying(250,300), drying(500,610), drying(14+250,14+250))
DG = pile{{"bone black",1.2},{"burnt sienna",0.35},{"raw sienna",0.25},{"ultramarine blue",0.35},{"viridian",0.1},{"lead white",0.7}}
local v, h = rect(0,0,0,0), rect(0,0,0,0)
for k=0,4 do
  local p = k*250
  v = v + rect(p-11, 0, 22, 1000); h = h + rect(0, p-11, 1000, 22)
end
v = v + rect(375-8, 250, 16, 250); h = h + rect(250, 375-8, 250, 16)
v = v:roughen(3, 25, 21); h = h:roughen(3, 25, 22)
work(v, {hand="body", pile=DG, tool="filbert 7", angle=math.pi/2, angle_jitter=0.04, length={25,80}, load=0.45, coverage=1.8, pressure={0.4,0.7}, clip=v, seed=91})
work(h, {hand="body", pile=DG, tool="filbert 7", angle=0, angle_jitter=0.04, length={25,80}, load=0.45, coverage=1.8, pressure={0.4,0.7}, clip=h, seed=92})

--@ chunk 30
print(wait(3*24*60), drying(250,300))
local special = {[2]=DK,[4]=DK,[11]=DK,[13]=DK,[1]=TD,[7]=TD,[8]=TD,[14]=TD}
for r=0,3 do for c=0,3 do
  local x0, y0 = c*250, r*250
  local p = special[r*4+c] or plate_pile(c,r)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local fr
  if r*4+c == 5 then
    fr = rect(x0+3,y0+3,244,244) - (rect(x0+11,y0+11,111,111) + rect(x0+128,y0+11,111,111) + rect(x0+11,y0+128,111,111) + rect(x0+128,y0+128,111,111))
    p = plate_pile(c,r)
  else
    fr = rect(x0+3,y0+3,244,244) - rect(x0+11,y0+11,228,228)
  end
  work(fr, {hand="body", pile=p, tool="filbert 5", angle=ang, angle_jitter=0.03, length={20,60}, load=0.6, coverage=2.6, fill=true, pressure={0.5,0.8}, clip=fr:roughen(1.2, 20, r*4+c), seed=1000+r*4+c})
end end

--@ chunk 31
print(wait(2*24*60), drying(256,300))
local special = {[2]=DK,[4]=DK,[11]=DK,[13]=DK,[1]=TD,[7]=TD,[8]=TD,[14]=TD}
for r=0,3 do for c=0,3 do
  local x0, y0 = c*250, r*250
  local p = special[r*4+c] or plate_pile(c,r)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local fr
  if r*4+c == 5 then
    fr = rect(x0+5,y0+5,240,240) - (rect(x0+16,y0+16,104,104) + rect(x0+130,y0+16,104,104) + rect(x0+16,y0+130,104,104) + rect(x0+130,y0+130,104,104))
    p = plate_pile(c,r)
  else
    fr = rect(x0+5,y0+5,240,240) - rect(x0+16,y0+16,218,218)
  end
  work(fr, {hand="body", pile=p, tool="filbert 5", angle=ang, angle_jitter=0.03, length={20,60}, load=0.6, coverage=2.6, fill=true, pressure={0.5,0.8}, clip=fr:roughen(1.0, 20, 50+r*4+c), seed=1100+r*4+c})
end end

--@ chunk 32
print(wait(2*24*60), drying(256,300), drying(125,125))
-- worn polish (boot paths) and grime fields, spread evenly by tileable noise
local TP = tileable(noise{seed=55, period=140, octaves=3})
local TG = tileable(noise{seed=77, period=110, octaves=3})
local inner = rect(0,0,0,0)
for r=0,3 do for c=0,3 do inner = inner + rect(c*250+18, r*250+18, 214, 214) end end
POL = pile{{"lead white",2},{"bone black",0.75},{"ultramarine blue",0.2},{"viridian",0.18},{"raw sienna",0.05}}
local mp = inner * mask(function(x,y) return smoothstep(0.2, 0.45, TP(x,y)) end)
work(mp, {hand="scumble", pile=POL, load=0.22, coverage=1.2, pressure={0.2,0.45}, angle=function(x,y) return (math.floor(x/250)+math.floor(y/250))%2==0 and 0 or math.pi/2 end, clip=inner, seed=121})
local mg = inner * mask(function(x,y) return smoothstep(0.25, 0.5, TG(x,y)) end)
work(mg, {hand="scumble", pile=DG, load=0.25, coverage=1.0, pressure={0.2,0.45}, clip=inner, seed=122})

--@ chunk 33
function inner_blend(c, r, sd)
  local m = rect(c*250+17, r*250+17, 216, 216)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  blend(m, {angle=ang, seed=sd})
end
for r=0,1 do for c=0,3 do inner_blend(c,r,800+r*4+c) end end

--@ chunk 34
for r=2,3 do for c=0,3 do inner_blend(c,r,800+r*4+c) end end

--@ chunk 35
print(wait(4*24*60), drying(100,40), drying(870,150), drying(300,850))
local special = {[2]=DK,[4]=DK,[11]=DK,[13]=DK,[1]=TD,[7]=TD,[8]=TD,[14]=TD}
for r=0,1 do for c=0,3 do
  local p = special[r*4+c] or plate_pile(c,r)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local m = rect(c*250+14, r*250+14, 222, 222)
  work(m, {hand="body", pile=p, tool="filbert 12", angle=ang, angle_jitter=0.04, curve={0.04,0.02}, length={50,150}, load=0.45, coverage=1.3, pressure={0.4,0.8}, clip=true, seed=1300+r*4+c})
end end

--@ chunk 36
local special = {[2]=DK,[4]=DK,[11]=DK,[13]=DK,[1]=TD,[7]=TD,[8]=TD,[14]=TD}
for r=2,3 do for c=0,3 do
  local p = special[r*4+c] or plate_pile(c,r)
  local ang = ((c*3+r)%2==0) and 0 or math.pi/2
  local m = rect(c*250+14, r*250+14, 222, 222)
  work(m, {hand="body", pile=p, tool="filbert 12", angle=ang, angle_jitter=0.04, curve={0.04,0.02}, length={50,150}, load=0.45, coverage=1.4, pressure={0.4,0.8}, clip=true, seed=1300+r*4+c})
end end

--@ chunk 37
print(wait(3*24*60), drying(125,125), drying(625,875))
tread(1,0) tread(3,1) tread(0,2) tread(2,3)
local m = rect(375-1.8, 262, 3.6, 226) + rect(262, 375-1.8, 226, 3.6)
work(m, {hand="detail", pile=SEAM2, tool={kind="round", width=3, point=0.3}, ruler=true, length={30,90}, coverage=2.5, fill=true, clip=true, seed=63})
for i,p in ipairs(RIV) do
  if i % 8 == 1 then rb:load(RD, 0.6) end
  rb:touch(p[1]+rand(-0.3,0.3), p[2]+rand(-0.3,0.3), {pressure=0.7})
end
-- hatch corner bolts on the subdivided plate
for _,q in ipairs({{268,268},{482,268},{268,482},{482,482},{363,268},{387,268},{363,482},{387,482},{268,363},{268,387},{482,363},{482,387}}) do
  rb:load(RD, 0.5); rb:touch(q[1], q[2], {pressure=0.6})
end

--@ chunk 38
print(wait(3*24*60), drying(264,264), drying(375,300))
RH = pile{{"lead white",2},{"bone black",0.8},{"ultramarine blue",0.15},{"viridian",0.2},{"raw sienna",0.15}}
for i,p in ipairs(RIV) do
  if i % 6 == 1 then hb:load(RH, 0.55) end
  hb:touch(p[1]+rand(-0.5,0.5), p[2]+rand(-0.5,0.5), {pressure=0.6})
end

--@ chunk 39
print(wait(2*24*60))
RUST1 = pile{{"burnt sienna",1},{"Mars orange",0.5},{"raw sienna",0.4},{"bone black",0.12},{"lead white",0.25}}
RUST2 = pile{{"Mars brown",1},{"burnt sienna",0.6},{"bone black",0.2},{"lead white",0.2}}
local rm1, rm2 = rect(0,0,0,0), rect(0,0,0,0)
local n = 0
for i,p in ipairs(RIV) do
  if (i*7 + (i//5)) % 9 == 0 then
    n = n + 1
    local rx, ry = rand(5,10), rand(5,10)
    local e = ellipse(p[1]+rand(-2,2), p[2]+rand(-2,2), rx, ry):roughen(2, 8, i)
    if n % 3 == 0 then rm2 = rm2 + e else rm1 = rm1 + e end
  end
end
print(n)
stipple(rm1:soften(2), {pile=RUST1, width=2.6, coverage=1.6, pressure={0.3,0.6}, dips={12,0.5,0.4}, feather=0.6, cluster={0.5,3}, seed=201})
stipple(rm2:soften(2), {pile=RUST2, width=2.6, coverage=1.6, pressure={0.3,0.6}, dips={12,0.5,0.4}, feather=0.6, cluster={0.5,3}, seed=202})
-- rust creeping along a few seam stretches, inside the canvas
local sm = rect(0,0,0,0)
for _,s in ipairs({{250,60,1},{500,700,1},{750,330,1},{140,500,0},{620,250,0},{880,750,0},{370,1000-120,1}}) do
  local len = rand(30,60)
  if s[3]==1 then sm = sm + rect(s[1]-5, s[2], 10, len) else sm = sm + rect(s[1], s[2]-5, len, 10) end
end
stipple(sm:roughen(3,10,9):soften(2), {pile=RUST1, width=2.4, coverage=1.3, pressure={0.3,0.6}, feather=0.6, cluster={0.6,4}, seed=203})

--@ chunk 40
print(wait(2*24*60))
PATCH = pile{{"lead white",2},{"bone black",1.25},{"ultramarine blue",0.3},{"viridian",0.2},{"raw sienna",0.1}}
local strips = {rect(530, 588, 190, 22), rect(612, 640, 22, 80), rect(790, 70, 70, 52), rect(90, 820, 22, 110)}
for i,s in ipairs(strips) do
  work(s, {hand="body", pile=PATCH, tool="filbert 6", angle=(i==2 or i==4) and math.pi/2 or 0, ruler=true, length={30,100}, load=0.7, coverage=3, fill=true, clip=true, seed=400+i})
end

--@ chunk 41
print(wait(2*24*60))
WELD = pile{{"bone black",1},{"burnt sienna",0.4},{"raw sienna",0.3},{"lead white",0.8}}
WELDL = pile{{"lead white",2},{"bone black",0.6},{"raw sienna",0.25},{"ultramarine blue",0.1}}
local rects = {{530,588,190,22},{612,640,22,80},{790,70,70,52},{90,820,22,110}}
local wm = rect(0,0,0,0)
for _,r in ipairs(rects) do
  wm = wm + rect(r[1]-2.5, r[2]-2.5, r[3]+5, r[4]+5) - rect(r[1]+2.5, r[2]+2.5, r[3]-5, r[4]-5)
end
stipple(wm, {pile=WELD, width=2.8, coverage=2.5, pressure={0.5,0.8}, dips={20,0.6,0.4}, clip=true, seed=411})
print(wait(24*60))
local wl = rect(0,0,0,0)
for _,r in ipairs(rects) do
  wl = wl + rect(r[1]-1, r[2]-1, r[3]+2, r[4]+2) - rect(r[1]+1, r[2]+1, r[3]-2, r[4]-2)
end
stipple(wl, {pile=WELDL, width=1.8, coverage=0.9, pressure={0.4,0.7}, dips={20,0.5,0.4}, clip=true, seed=412})

--@ chunk 42
print(wait(24*60))
SCR = pile{{"lead white",2},{"bone black",0.55},{"ultramarine blue",0.15},{"viridian",0.12}}
SCF = pile{{"bone black",1},{"raw sienna",0.3},{"burnt sienna",0.2},{"lead white",0.9},{"ultramarine blue",0.2}}
local rg = brush{kind="rigger", width=1.6, point=1}
for i=1,260 do
  local x, y = rand(20,980), rand(20,980)
  local base = (math.random() < 0.5) and 0 or math.pi/2
  local a = base + randn(0, 0.25)
  local L = rand(10,45)
  if i % 4 == 1 then rg:reload(SCR, rand(0.25,0.45)) end
  local dx, dy = math.cos(a)*L, math.sin(a)*L
  rg:stroke({{x,y},{x+dx*0.5+rand(-1,1), y+dy*0.5+rand(-1,1)},{x+dx,y+dy}}, {pressure={rand(0.3,0.6),0.05}, ramps={0.1,0.5}})
end
local fb = brush{kind="filbert", width=5}
for i=1,110 do
  local x, y = rand(30,970), rand(30,970)
  local a = rand(0, math.pi)
  local L = rand(10,26)
  if i % 3 == 1 then fb:reload(SCF, rand(0.15,0.3)) end
  local dx, dy = math.cos(a)*L, math.sin(a)*L
  local nx, ny = -dy*0.15, dx*0.15
  fb:stroke({{x,y},{x+dx*0.5+nx, y+dy*0.5+ny},{x+dx,y+dy}}, {pressure={0.45,0.1}, ramps={0.2,0.5}})
end

--@ chunk 43
print(wait(2*24*60))
local m = rect(375-1.8, 248, 3.6, 16) + rect(375-1.8, 486, 3.6, 16) + rect(248, 375-1.8, 16, 3.6) + rect(486, 375-1.8, 16, 3.6)
work(m, {hand="detail", pile=SEAM2, tool={kind="round", width=3, point=0.3}, ruler=true, length={8,16}, coverage=3, fill=true, clip=true, seed=64})
RS = pile{{"burnt sienna",1},{"Mars brown",0.6},{"raw sienna",0.3},{"bone black",0.25},{"lead white",0.7}}
local fb = brush{kind="filbert", width=4}
local spots = {{140,236},{610,14},{736,330},{264,610},{486,860},{860,486},{14,780},{390,736},{236,140},{764,890},{640,264},{110,486}}
for k,s in ipairs(spots) do
  local e = ellipse(s[1], s[2], rand(12,20), rand(12,20)):roughen(4, 12, k)
  work(e, {hand="body", pile=RS, tool=fb, length={6,16}, load=0.3, coverage=1.1, pressure={0.25,0.5}, clip=e:soften(3), seed=500+k})
end

--@ chunk 44
print(wait(3*24*60), drying(140,236))
RSD = pile{{"Mars brown",1},{"burnt sienna",0.4},{"bone black",0.35},{"ultramarine blue",0.15},{"lead white",0.25}}
local fb = brush{kind="filbert", width=4}
local spots = {{140,236},{610,14},{736,330},{264,610},{486,860},{860,486},{14,780},{390,736},{236,140},{764,890},{640,264},{110,486}}
for k,s in ipairs(spots) do
  local e = ellipse(s[1], s[2], 16, 16):roughen(5, 10, 40+k)
  work(e, {hand="body", pile=RSD, tool=fb, length={5,14}, load=0.3, coverage=0.9, pressure={0.25,0.5}, clip=e:soften(3), seed=600+k})
end

--@ chunk 45
print(wait(2*24*60))
SCORCH = pile{{"bone black",1},{"ultramarine blue",0.35},{"burnt sienna",0.25},{"lead white",0.6}}
local rects = {{530,588,190,22},{612,640,22,80},{790,70,70,52},{90,820,22,110}}
local hm = rect(0,0,0,0)
for _,r in ipairs(rects) do
  hm = hm + rect(r[1]-8, r[2]-8, r[3]+16, r[4]+16) - rect(r[1]-2.5, r[2]-2.5, r[3]+5, r[4]+5)
end
hm = hm:roughen(2, 12, 3)
work(hm, {hand="body", pile=SCORCH, tool="filbert 4", length={8,24}, load=0.25, coverage=0.9, pressure={0.25,0.45}, clip=hm:soften(2), seed=901})

--@ chunk 46
local rects = {{530,588,190,22},{612,640,22,80},{790,70,70,52},{90,820,22,110}}
local hm = rect(0,0,0,0)
for _,r in ipairs(rects) do
  hm = hm + rect(r[1]-12, r[2]-12, r[3]+24, r[4]+24) - rect(r[1]-2.5, r[2]-2.5, r[3]+5, r[4]+5)
end
blend(hm, {tool={kind="filbert", width=8, stiffness=0.3}, seed=902})

--@ chunk 47
print(wait(2*24*60))
local fb = brush{kind="filbert", width=4}
for k,s in ipairs({{610,1014},{1014,780}}) do
  local e = ellipse(s[1], s[2], 16, 16):roughen(4, 10, 70+k)
  work(e, {hand="body", pile=RS, tool=fb, length={5,12}, load=0.3, coverage=1.0, pressure={0.25,0.5}, clip=e:soften(3), seed=700+k})
end

--@ chunk 48
print(wait(3*24*60))
