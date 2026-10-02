-- easel session "well": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=480, aspect=3/4, linen=18, seed=9191,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.8},{"lead white",0.2}}, um=90, apply="knife", texture=0.35}}}
-- canvas is 1000 x 1333. Looking straight down: vanishing point slightly right of centre, below middle
VP = {560,760}; R0 = 1500; OFF = {-60,-40}
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.6}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.4}, clip=clip})
end
function ring(s) return VP[1] + OFF[1]*s*4, VP[2] + OFF[2]*s*4, R0*s end
function disc(s, f) local cx, cy, r = ring(s); return ellipse(cx, cy, r*(f or 1), r*(f or 1)) end
SS = {1, 0.6, 0.4, 0.28, 0.2, 0.148, 0.11, 0.083, 0.063, 0.048, 0.037, 0.028, 0.021, 0.016, 0.012}
local ramp = {
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.5},{"bone brown",1.4},{"burnt sienna",0.4}},
 pile{{"bone black",1.2},{"bone brown",1.6},{"burnt sienna",0.5}},
 pile{{"bone black",0.8},{"bone brown",1.6},{"burnt sienna",0.7}},
 pile{{"bone brown",1.8},{"burnt sienna",0.9},{"bone black",0.4}},
 pile{{"bone brown",1.5},{"burnt sienna",1},{"raw sienna",0.3}},
 pile{{"bone brown",1.1},{"burnt sienna",1},{"raw sienna",0.6}},
 pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.6}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.8},{"yellow ochre",0.3}},
 pile{{"raw sienna",1.3},{"yellow ochre",0.6},{"burnt sienna",0.5},{"lead white",0.3}},
 pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.6}},
 pile{{"yellow ochre",1},{"lead white",1},{"Indian yellow",0.3}},
 pile{{"lead white",1.4},{"Indian yellow",0.5},{"yellow ochre",0.6}},
 pile{{"lead white",2},{"Indian yellow",0.6},{"zinc white",0.5}} }
for i=1,#SS-1 do
  local band = disc(SS[i]) - disc(SS[i+1])
  local _, _, r = ring(SS[i])
  work(band, {hand="body", tool={kind="filbert", width=clamp(r/40, 2, 14)}, pile=ramp[i], coverage=3, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(r/30,4,40), clamp(r/8,8,110)}, load=1.0})
end
work(disc(SS[#SS]), {hand="detail", pile=pile{{"lead white",2},{"zinc white",1.5},{"Indian yellow",0.5}}, coverage=4, fill=true})

--@ chunk 2
print(wait(3*24*60))
local floorD = pile{{"bone black",1.4},{"bone brown",1.4},{"burnt sienna",0.4}}
local floorM = pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.4}}
local lipW = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local lipH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local dk = pile{{"bone black",2},{"bone brown",0.6}}
function circ(cx, cy, r, n) local pts = {}; for k=0,n do local a = k/n*2*math.pi; pts[#pts+1] = {cx+math.cos(a)*r, cy+math.sin(a)*r} end; return pts end
for i=#SS-2,2,-1 do
  local s = SS[i]; local cx, cy, r = ring(s)
  local n = math.floor(clamp(r/4, 40, 160))
  local depth = r*0.09; local bw = clamp(depth/3, 1.2, 12)
  local m = math.max(1, math.floor(depth/bw))
  for j=0,m do ST(circ(cx, cy, r*0.995 - j*bw, n), (i < 4) and floorD or floorM, bw*1.3, {0.9,0.9}, 1.0) end
  ST(circ(cx, cy, r*0.9, n), dk, clamp(r/110,1,8), {0.9,0.9}, 1.0)
  ST(circ(cx, cy, r*0.893, n), (i > 6) and lipH or lipW, clamp(r/200,0.8,4), {0.8,0.8}, 1.0)
end

--@ chunk 3
local floorD = pile{{"bone black",1.4},{"bone brown",1.4},{"burnt sienna",0.4}}
local floorM = pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.4}}
local lipW = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local lipH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local dk = pile{{"bone black",2},{"bone brown",0.6}}
function arcs(cx, cy, r, p, w, pr, seglen)
  local L = 2*math.pi*r; local n = math.max(8, math.ceil(L / (seglen or 60)))
  for k=0,n-1 do
    local a0, a1 = k/n*2*math.pi, (k+1.08)/n*2*math.pi
    local x0, y0 = cx+math.cos(a0)*r, cy+math.sin(a0)*r
    if x0 > -80 and x0 < 1080 and y0 > -80 and y0 < 1413 then
      local pts = {}; for j=0,4 do local a = lerp(a0,a1,j/4); pts[#pts+1] = {cx+math.cos(a)*r, cy+math.sin(a)*r} end
      ST(pts, p, w, pr, 1.0)
    end
  end
end
GALS = {}
for i=#SS-2,2,-1 do
  local s = SS[i]; local cx, cy, r = ring(s)
  local depth = r*0.09; local bw = clamp(depth/3, 1.2, 12)
  local m = math.max(1, math.floor(depth/bw))
  for j=0,m do arcs(cx, cy, r*0.995 - j*bw, (i < 4) and floorD or floorM, bw*1.3, {0.9,0.9}) end
  arcs(cx, cy, r*0.9, dk, clamp(r/110,1,8), {0.9,0.9})
  arcs(cx, cy, r*0.893, (i > 6) and lipH or lipW, clamp(r/200,0.8,4), {0.8,0.8})
end

--@ chunk 4
print(wait(2*24*60))
local dk = pile{{"bone black",2},{"bone brown",0.6}}
local lampP = pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.7}}
local wallL = pile{{"raw sienna",1},{"burnt sienna",0.8},{"lead white",0.4}}
-- doors: dark slots in the wall below each gallery, radial, with a warm lit lintel
for i=2,#SS-3 do
  local cx, cy, r = ring(SS[i]); local cxn, cyn, rn = ring(SS[i+1])
  local nd = math.floor(clamp(r/28, 8, 30))
  for k=0,nd-1 do local a = (k+0.5)/nd*2*math.pi + i*0.37
    local p0 = {lerp(cx+math.cos(a)*r*0.88, cxn+math.cos(a)*rn, 0.25), lerp(cy+math.sin(a)*r*0.88, cyn+math.sin(a)*rn, 0.25)}
    local p1 = {lerp(cx+math.cos(a)*r*0.88, cxn+math.cos(a)*rn, 0.62), lerp(cy+math.sin(a)*r*0.88, cyn+math.sin(a)*rn, 0.62)}
    if p0[1] > -10 and p0[1] < 1010 and p0[2] > -10 and p0[2] < 1343 then
      local w = clamp(r/40, 1.2, 16)
      ST({p0, p1}, dk, w, {1,1}, 1.0)
      ST({{p0[1]-math.sin(a)*w*0.5, p0[2]+math.cos(a)*w*0.5},{p0[1]+math.sin(a)*w*0.5, p0[2]-math.cos(a)*w*0.5}}, wallL, math.max(0.8, w*0.25), {0.8,0.8}, 0.9)
    end
  end
  -- lamps along the balustrade
  local nl = math.floor(clamp(r/22, 10, 44))
  for k=0,nl-1 do local a = (k+0.1)/nl*2*math.pi + i*0.2
    local x, y = cx+math.cos(a)*r*0.9, cy+math.sin(a)*r*0.9
    if x > -10 and x < 1010 and y > -10 and y < 1343 then
      local d = clamp(r/140, 1, 6)
      ST({{x-d*0.4,y},{x+d*0.4,y}}, lampP, d*1.6, {1,1}, 1.0)
    end
  end
end

--@ chunk 5
print(wait(2*24*60))
local dk = pile{{"bone black",2},{"bone brown",0.6}}
local brz = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.6}}
local lit = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
-- spiral stair winding down the shaft wall: a band hugging the wall, stepping down a ring per turn
local function sp(t) -- t from 0 (top) to 1
  local s = math.exp(math.log(0.6) + t*(math.log(0.03)-math.log(0.6)))
  local cx, cy, r = ring(s); local a = 0.9 + t*2*math.pi*5.2
  return cx + math.cos(a)*r*0.97, cy + math.sin(a)*r*0.97, r, a
end
local N = 520
for k=0,N-1 do
  local x0, y0, r0, a0 = sp(k/N); local x1, y1 = sp((k+1)/N)
  if x0 > -20 and x0 < 1020 and y0 > -20 and y0 < 1353 then
    local w = clamp(r0*0.05, 1.2, 30)
    ST({{x0,y0},{x1,y1}}, brz, w, {1,1}, 1.0)
    -- treads as radial ticks, inner rail lit
    if k % 2 == 0 then ST({{x0 - math.cos(a0)*w*0.5, y0 - math.sin(a0)*w*0.5},{x0 + math.cos(a0)*w*0.5, y0 + math.sin(a0)*w*0.5}}, dk, math.max(0.8, w*0.12), {0.9,0.9}, 0.9) end
    ST({{x0 - math.cos(a0)*w*0.5, y0 - math.sin(a0)*w*0.5},{x1 - math.cos(a0)*w*0.5, y1 - math.sin(a0)*w*0.5}}, lit, math.max(0.8, w*0.12), {0.8,0.8}, 0.9)
  end
end
-- a cargo lift platform hanging on cables in the middle distance, between us and the core, offset left
local s = 0.17; local cx, cy, r = ring(s)
local px, py = cx - r*0.35, cy - r*0.1
local pw = r*0.32
local plat = {}; for k=0,7 do local a = k/8*2*math.pi + 0.39; plat[#plat+1] = {px + math.cos(a)*pw, py + math.sin(a)*pw} end
work(poly(plat), {hand="detail", pile=dk, coverage=4, fill=true})
plat[#plat+1] = plat[1]
ST({plat[5],plat[6],plat[7],plat[8]}, litH, 2.4, {0.9,0.9}); ST({plat[1],plat[2],plat[3],plat[4]}, brz, 2.4, {0.9,0.9})
ST({{px - pw*0.6, py},{px + pw*0.6, py}}, brz, 2, {0.8,0.8}); ST({{px, py - pw*0.6},{px, py + pw*0.6}}, brz, 2, {0.8,0.8})
-- cables from the platform up past us out of frame (they converge toward us: up is toward the viewer)
for _,a in ipairs({0.6, 2.2, 3.8, 5.3}) do
  local x0, y0 = px + math.cos(a)*pw*0.9, py + math.sin(a)*pw*0.9
  local x1, y1 = x0 + (x0 - VP[1])*6, y0 + (y0 - VP[2])*6
  ST({{x0,y0},{x1,y1}}, dk, 4, {0.3,1}, 1.0); ST({{x0+1.5,y0-1.5},{x1+6,y1-6}}, lit, 1.4, {0.2,0.8}, 0.8)
end

--@ chunk 6
print(wait(2*24*60))
local dk = pile{{"bone black",2},{"ultramarine blue",0.4},{"bone brown",0.5}}
local brz = pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.3}}
local lit = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local cold = pile{{"lead white",2},{"ultramarine ash",0.8},{"bone black",0.2}}
local tab = pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.6}}
-- the catwalk: a narrow bronze deck crossing the bottom-left corner, its edge over the drop
CW = poly({{-20,1080},{420,1180},{560,1353},{-20,1353}})
work(CW, {hand="body", tool="filbert 8", pile=brz, coverage=4, fill=true, clip=true, angle=0.22, length={20,70}, load=1.0})
for k=0,8 do local t = k/8; ST({{-20, 1100 + t*250},{420 + t*130, 1190 + t*170}}, dk, 3, {0.8,0.8}, 1.0, CW) end
ST({{-20,1080},{420,1180},{560,1353}}, litH, 4, {0.9,0.9}); ST({{-20,1092},{410,1192},{548,1353}}, dk, 6, {0.9,0.9})
-- railing posts and the top rail, rising toward us (foreshortened, splayed outward from the vanishing point)
for _,b in ipairs({{60,1098},{200,1130},{330,1160},{440,1210},{510,1290}}) do
  local x, y = b[1], b[2]; local tx, ty = x + (x - VP[1])*0.35, y + (y - VP[2])*0.35
  ST({{x,y},{tx,ty}}, dk, 9, {1,0.8}); ST({{x-3,y},{tx-4,ty}}, lit, 2.4, {0.8,0.4})
end
-- boot tips at the catwalk's edge, armored sabatons, looking down past them
local function boot(x, y, ang)
  local ux, uy = math.cos(ang), math.sin(ang); local vx, vy = -uy, ux
  local q = {{x - vx*34, y - vy*34}, {x + ux*90 - vx*22, y + uy*90 - vy*22}, {x + ux*118, y + uy*118}, {x + ux*90 + vx*22, y + uy*90 + vy*22}, {x + vx*34, y + vy*34}}
  work(poly(q, true), {hand="body", tool="filbert 4", pile=dk, coverage=4.2, fill=true, clip=true, angle=ang, length={8,24}, load=1.0})
  for k=1,3 do local t = k*0.22; ST({{x + ux*90*t - vx*30*(1-t*0.6), y + uy*90*t - vy*30*(1-t*0.6)},{x + ux*90*t + vx*30*(1-t*0.6), y + uy*90*t + vy*30*(1-t*0.6)}}, brz, 3, {0.8,0.8}) end
  ST({{x - vx*30 + ux*10, y - vy*30 + uy*10},{x + ux*92 - vx*20, y + uy*92 - vy*20},{x + ux*116, y + uy*116}}, litH, 3, {0.9,0.4})
  ST({{x + ux*116, y + uy*116},{x + ux*90 + vx*22, y + uy*90 + vy*22}}, cold, 2, {0.6,0.3})
end
boot(150, 1300, -0.85); boot(330, 1340, -1.05)
-- his gauntlet gripping the top rail at the right edge of the frame
local gx, gy = 880, 1260
work(poly({{800,1353},{840,1230},{900,1180},{970,1190},{1010,1240},{1010,1353}}, true), {hand="body", tool="filbert 5", pile=dk, coverage=4.2, fill=true, clip=true, angle=-1.2, length={10,30}, load=1.0})
for k=0,3 do local x = 856 + k*30; ST({{x,1196+k*4},{x-10,1250+k*6},{x-16,1290}}, brz, 7, {0.9,0.6}); ST({{x-4,1198+k*4},{x-12,1240+k*6}}, litH, 2.4, {0.8,0.3}) end
ST({{700,1353},{1010,1180}}, dk, 14, {1,1}); ST({{700,1340},{1010,1168}}, lit, 3, {0.8,0.6})
work(poly({{900,1353},{960,1300},{1010,1300},{1010,1353}}), {hand="body", tool="filbert 3", pile=tab, coverage=4, fill=true, clip=true, angle=-0.6, length={6,18}, load=1.0})

--@ chunk 7
print(wait(2*24*60))
local g1 = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.5}}
local g2 = pile{{"yellow ochre",1},{"lead white",1},{"Indian yellow",0.4}}
local g3 = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.3}}
-- the core's light climbing the shaft wall: radial strokes on each wall band, brighter and denser the deeper
local CWm = CW:grow(4)
for i=4,#SS-2 do
  local cx, cy, r = ring(SS[i]); local cxn, cyn, rn = ring(SS[i+1])
  local f = (i-4)/(#SS-6)
  local n = math.floor(lerp(30, 70, f))
  for k=0,n-1 do local a = k/n*2*math.pi + rand(-0.03,0.03)
    local p0 = {cxn + math.cos(a)*rn*1.0, cyn + math.sin(a)*rn*1.0}
    local p1 = {lerp(p0[1], cx + math.cos(a)*r*0.88, rand(0.3,0.7)), lerp(p0[2], cy + math.sin(a)*r*0.88, rand(0.3,0.7))}
    if p0[1] > -10 and p0[1] < 1010 then
      ST({p0, p1}, (f > 0.66) and g3 or ((f > 0.3) and g2 or g1), clamp(r/60, 1, 8), {lerp(0.4,0.8,f), 0.0}, lerp(0.4,0.8,f), -CWm)
    end
  end
end
-- the near walls fall into deep dark: vertigo, the eye drops to the glow
local deep = pile{{"bone black",2},{"bone brown",0.8},{"ultramarine blue",0.2}}
local cx2, cy2, r2 = ring(0.45)
work(-(ellipse(cx2, cy2, r2*0.98, r2*0.98):soften(30)) - CW:grow(2) - rect(780,1150,240,210), {hand="body", tool="filbert 10", pile=deep, coverage=2.4, fill=true, angle=0.3, length={30,80}, load=0.8, edge="soft"})

--@ chunk 8
print(wait(3*24*60))
local cwD = pile{{"bone black",1.2},{"bone brown",1.4},{"burnt sienna",0.5}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.4},{"bone brown",0.5}}
local mid = pile{{"bone black",1},{"ultramarine ash",1},{"bone brown",0.6},{"lead white",0.3}}
local litH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local lit = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local seam = pile{{"bone black",2}}
-- catwalk deck darker, grating lines, a lit front edge over the drop
work(CW:shrink(6), {hand="body", tool="filbert 6", pile=cwD, coverage=4, fill=true, clip=CW, angle=0.22, length={20,60}, load=1.0})
for k=0,12 do local t = k/12; ST({{-20 + t*20, 1100 + t*250},{430 + t*130, 1196 + t*160}}, seam, 2.4, {0.8,0.8}, 1.0, CW:shrink(6)) end
ST({{-20,1082},{420,1182},{558,1353}}, litH, 5, {0.9,0.9})
-- sabatons: articulated lames, each lit on its upper edge by the core light below and ahead
local function boot(x, y, ang, L)
  local ux, uy = math.cos(ang), math.sin(ang); local vx, vy = -uy, ux
  for k=0,5 do
    local t0 = k/6; local t1 = (k+1.15)/6
    local w0 = 34*(1 - t0*0.55); local w1 = 34*(1 - t1*0.55)
    local q = {{x+ux*L*t0-vx*w0, y+uy*L*t0-vy*w0},{x+ux*L*t1-vx*w1, y+uy*L*t1-vy*w1},{x+ux*L*t1+vx*w1, y+uy*L*t1+vy*w1},{x+ux*L*t0+vx*w0, y+uy*L*t0+vy*w0}}
    work(poly(q), {hand="body", tool="filbert 3", pile=(k%2==0) and mid or dk, coverage=4, fill=true, clip=true, angle=ang+1.57, length={6,16}, load=1.0})
    ST({{x+ux*L*t1-vx*w1, y+uy*L*t1-vy*w1},{x+ux*L*t1+vx*w1, y+uy*L*t1+vy*w1}}, (k > 3) and litH or lit, 2.6, {0.9,0.6})
  end
  local tip = {x+ux*L*1.18, y+uy*L*1.18}
  work(poly({{x+ux*L-vx*14, y+uy*L-vy*14},{tip[1],tip[2]},{x+ux*L+vx*14, y+uy*L+vy*14}}), {hand="detail", pile=mid, coverage=4, fill=true})
  ST({{x+ux*L-vx*12, y+uy*L-vy*12},{tip[1],tip[2]}}, litH, 2.6, {0.9,0.3})
end
boot(130, 1345, -0.95, 130); boot(320, 1360, -1.15, 120)
-- the gauntlet on the rail: knuckle plates and finger lames, lit edges
for k=0,3 do local x = 856 + k*30
  ST({{x+2,1194+k*4},{x-6,1222+k*5}}, mid, 14, {1,1}); ST({{x-6,1226+k*5},{x-14,1262+k*6}}, mid, 12, {1,1})
  ST({{x-2,1192+k*4},{x-10,1222+k*5}}, litH, 2.6, {0.9,0.4}); ST({{x-10,1226+k*5},{x-17,1258+k*6}}, lit, 2.2, {0.8,0.3})
end
ST({{820,1240},{960,1180}}, litH, 3, {0.9,0.5})
