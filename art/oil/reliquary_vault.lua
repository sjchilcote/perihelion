-- easel session "reliquary_vault": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=3131,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.9},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
VP = {500,300}
function S(z) return 1/(1+0.55*z) end
function sec(z) local s = S(z); return {s=s, hw=520*s, fy=VP[2]+300*s, sy=VP[2]-40*s, vr=520*s} end
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.3}, clip=clip})
end
function archpts(z, n)
  local c = sec(z); local pts = {{VP[1]-c.hw, c.fy}, {VP[1]-c.hw, c.sy}}
  for k=1,n-1 do local a = math.pi + math.pi*k/n; pts[#pts+1] = {VP[1]+math.cos(a)*c.hw, c.sy+math.sin(a)*c.vr*0.55} end
  pts[#pts+1] = {VP[1]+c.hw, c.sy}; pts[#pts+1] = {VP[1]+c.hw, c.fy}
  return pts
end
local dk = pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}}
work(everywhere(), {hand="broad", pile=dk, coverage=2.6, fill=true, angle=0.2})
-- the deep end glows faintly warm; the aisle floor a little lighter than the shelves' dark
local far = pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.5}}
local far2 = pile{{"raw sienna",1.2},{"burnt sienna",0.7},{"yellow ochre",0.4},{"lead white",0.3}}
work(ellipse(VP[1],VP[2],150,80):soften(30), {hand="body", tool="filbert 6", pile=far, coverage=3, fill=true, angle=0, length={14,40}, edge="soft", load=1.0})
work(ellipse(VP[1],VP[2]+4,50,26):soften(12), {hand="body", tool="filbert 4", pile=far2, coverage=3, fill=true, angle=0, length={8,24}, edge="soft", load=1.0})
local fl = pile{{"bone brown",1.6},{"burnt sienna",0.9},{"bone black",0.4}}
AISLE = poly({{VP[1]-150,563},{VP[1]+150,563},{VP[1]+6,VP[2]+6},{VP[1]-6,VP[2]+6}})
work(AISLE, {hand="body", tool="filbert 6", pile=fl, coverage=3.2, fill=true, clip=true, angle=1.57, length={20,60}, load=1.0})

--@ chunk 2
print(wait(2*24*60))
local rib = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8}}
local ribL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local seam = pile{{"bone black",2},{"bone brown",0.5}}
-- vault ribs: transverse arches thick near, thin far; drawn in short reloaded segments
ZR = {0.1,0.5,1.0,1.7,2.6,3.8,5.4,7.6,10.5,14.5,20,28}
for _,z in ipairs(ZR) do
  local s = S(z); local pts = archpts(z, 32)
  for j=1,#pts-1 do
    ST({pts[j], pts[j+1]}, rib, math.max(1.5, 26*s), {0.9,0.9}, 1.0)
    local a, b = pts[j], pts[j+1]
    local c = sec(z)
    local ia = {VP[1] + (a[1]-VP[1])*0.975, c.sy + (a[2]-c.sy)*0.975}; local ib = {VP[1] + (b[1]-VP[1])*0.975, c.sy + (b[2]-c.sy)*0.975}
    ST({ia, ib}, ribL, math.max(0.8, 5*s), {0.7,0.7}, 1.0)
  end
end
-- longitudinal seams of the vault and the wall/floor corners, running to the vanishing point
local c0 = sec(0)
for k=1,11 do local a = math.pi + math.pi*k/12
  local x, y = VP[1]+math.cos(a)*c0.hw, c0.sy+math.sin(a)*c0.vr*0.55
  ST({{x,y},{lerp(x,VP[1],0.96), lerp(y,VP[2],0.96)}}, seam, 3, {0.8,0.05}, 1.0)
end

--@ chunk 3
print(wait(2*24*60))
local caseD = pile{{"bone black",1.4},{"bone brown",1.2},{"burnt sienna",0.4}}
local caseM = pile{{"bone brown",1.4},{"burnt sienna",0.9},{"raw sienna",0.4}}
local bone = pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.2}}
local boneD = pile{{"yellow ochre",1},{"raw sienna",0.8},{"lead white",0.6}}
local shelf = pile{{"bone black",2},{"bone brown",0.6}}
local coldP = pile{{"lead white",2},{"cerulean blue",0.8},{"zinc white",1}}
local function wp(side, z, h) local c = sec(z); return VP[1] + side*c.hw*0.96, lerp(c.fy, c.sy, h) end
TIERS = {0.02, 0.2, 0.38, 0.56, 0.74, 0.92}
for _,side in ipairs({-1,1}) do
  -- shelf boards: dark lines receding to the far end
  for _,h in ipairs(TIERS) do
    local x0, y0 = wp(side, 0.05, h); local x1, y1 = wp(side, 30, h)
    ST({{x0,y0},{x1,y1}}, shelf, 7, {0.9,0.05}, 1.0)
  end
  -- cases on each tier, spaced evenly in depth
  local z = 0.08
  while z < 26 do
    local z2 = z * 1.11 + 0.04
    for t=1,#TIERS-1 do
      local h0, h1 = TIERS[t] + 0.02, TIERS[t+1] - 0.03
      local xa, ya0 = wp(side, z, h0); local _, ya1 = wp(side, z, h1)
      local xb, yb0 = wp(side, z2*0.97, h0); local _, yb1 = wp(side, z2*0.97, h1)
      local s = S(z)
      local w = math.abs(ya0 - ya1)
      if xa > -30 and xa < 1030 and w > 1.2 then
        -- the case body: a thick stroke spanning its height, from its near edge to its far edge
        ST({{(xa+xb)/2, (ya0+yb0)/2},{(xa+xb)/2, (ya1+yb1)/2}}, (t % 2 == 0) and caseM or caseD, math.max(1.2, math.abs(xb-xa)*0.9), {1,1}, 1.0)
        -- bone lid edge and a carved band
        if s > 0.06 then
          ST({{xa,ya1},{xb,yb1}}, bone, math.max(0.8, 2.6*s), {0.9,0.9}, 1.0)
          ST({{xa,(ya0+ya1)/2},{xb,(yb0+yb1)/2}}, boneD, math.max(0.6, 1.4*s), {0.7,0.7}, 0.8)
        end
        -- the cold indicator light
        local lx, ly = lerp(xa, xb, 0.5), lerp(ya1, ya0, 0.3)
        local d = math.max(0.7, 3.2*s)
        ST({{lx - d*0.3, ly},{lx + d*0.3, ly}}, coldP, d*1.3, {1,1}, 1.0)
      end
    end
    z = z2
  end
end

--@ chunk 4
print(wait(2*24*60))
local lampP = pile{{"lead white",2},{"Indian yellow",0.8},{"lemon chrome",0.1}}
local amber = pile{{"Indian yellow",1},{"raw sienna",0.6},{"lead white",0.6}}
local pool = pile{{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.35}}
local dk = pile{{"bone black",2},{"bone brown",0.6}}
-- a single row of small warm floor lamps down the aisle's centre, each throwing a small oval of light
local z = 0.15
while z < 30 do
  local c = sec(z); local s = c.s
  local x, y = VP[1], c.fy
  if y < 575 then
    for k=-3,3 do ST({{x - 60*s + k*0, y + k*2.2*s},{x + 60*s, y + k*2.2*s}}, pool, math.max(0.8, 5*s), {0.5 - math.abs(k)*0.12, 0.5 - math.abs(k)*0.12}, 0.6) end
    ST({{x - 4*s, y},{x + 4*s, y}}, amber, math.max(1, 8*s), {1,1}, 1.0)
    ST({{x - 2*s, y - 1*s},{x + 2*s, y - 1*s}}, lampP, math.max(0.8, 5*s), {1,1}, 1.0)
  end
  z = z * 1.35 + 0.25
end
-- the Commando, tiny, at the left shelves in the middle distance, lamp raised, reading a label
local zc = 2.2; local c = sec(zc); local s = c.s
local x0, y0 = VP[1] - 70*s, c.fy
local H = 150*s
local function P(pts, p) work(poly(pts), {hand="detail", pile=p, coverage=4.5, fill=true}) end
P({{x0-0.10*H,y0},{x0-0.07*H,y0-0.42*H},{x0-0.13*H,y0-0.72*H},{x0-0.04*H,y0-0.86*H},{x0+0.08*H,y0-0.86*H},{x0+0.12*H,y0-0.70*H},{x0+0.08*H,y0-0.42*H},{x0+0.11*H,y0},{x0+0.03*H,y0},{x0,y0-0.40*H},{x0-0.03*H,y0}}, dk)
work(ellipse(x0, y0-0.93*H, 0.07*H, 0.08*H), {hand="detail", pile=dk, coverage=4.5, fill=true})
P({{x0-0.11*H,y0-0.68*H},{x0+0.10*H,y0-0.68*H},{x0+0.12*H,y0-0.36*H},{x0-0.12*H,y0-0.36*H}}, pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.4}})
-- the raised arm and the lamp held up toward the cases on his left
local hx, hy = x0 - 0.30*H, y0 - 1.05*H
ST({{x0-0.08*H, y0-0.80*H},{x0-0.20*H, y0-0.95*H},{hx, hy}}, dk, 0.07*H, {1,0.8})
work(ellipse(hx, hy, 0.05*H, 0.06*H), {hand="detail", pile=amber, coverage=4.5, fill=true})
ST({{hx-0.015*H, hy},{hx+0.015*H, hy}}, lampP, 0.06*H, {1,1}, 1.0)
-- the lamp's warm light on the nearest cases and on his near side: radiating short strokes
for k=1,30 do local a = rand(0, 2*math.pi); local L = rand(0.15,0.5)*H
  ST({{hx + math.cos(a)*0.07*H, hy + math.sin(a)*0.07*H},{hx + math.cos(a)*L, hy + math.sin(a)*L}}, amber, rand(1,2), {0.6,0.0}, 0.7) end
ST({{x0-0.13*H, y0-0.72*H},{x0-0.07*H, y0-0.42*H},{x0-0.10*H, y0}}, lampP, 1.2, {0.8,0.4})
ST({{x0-0.06*H, y0-1.00*H},{x0+0.04*H, y0-1.00*H}}, lampP, 1.2, {0.8,0.4})
print(x0, y0, H)

--@ chunk 5
print(wait(2*24*60))
local coldP = pile{{"cerulean blue",1},{"zinc white",1.5},{"cobalt blue",0.3}}
local function wp(side, z, h) local c = sec(z); return VP[1] + side*c.hw*0.96, lerp(c.fy, c.sy, h) end
for _,side in ipairs({-1,1}) do
  local z = 0.08
  while z < 26 do
    local z2 = z * 1.11 + 0.04
    for t=1,#TIERS-1 do
      local h0, h1 = TIERS[t] + 0.02, TIERS[t+1] - 0.03
      local xa, ya0 = wp(side, z, h0); local _, ya1 = wp(side, z, h1)
      local xb, yb0 = wp(side, z2*0.97, h0); local _, yb1 = wp(side, z2*0.97, h1)
      local s = S(z)
      if xa > -30 and xa < 1030 and math.abs(ya0-ya1) > 1.2 then
        local lx, ly = lerp(xa, xb, 0.5), lerp(ya1, ya0, 0.3)
        local d = math.max(0.8, 3.6*s)
        ST({{lx - d*0.25, ly},{lx + d*0.25, ly}}, coldP, d*1.4, {1,1}, 1.0)
      end
    end
    z = z2
  end
end
