-- easel session "core_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=8383,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.9},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
CC = {500,250}; F = 330
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.9,0.9}, ramps={0.03,0.1}, clip=clip})
end
-- latitude rings of the far hemisphere seen from inside: screen radius = F * tan(theta), theta from the far pole
TH = {}; for k=1,12 do TH[k] = k*6.5 end
function rr(th) return F * math.tan(math.rad(th)) end
local ramp = {
 pile{{"lead white",2},{"yellow ochre",0.8},{"Indian yellow",0.4}},
 pile{{"yellow ochre",1.2},{"lead white",1},{"raw sienna",0.5}},
 pile{{"raw sienna",1.3},{"yellow ochre",0.7},{"lead white",0.5}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.7},{"yellow ochre",0.3},{"lead white",0.2}},
 pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.5}},
 pile{{"bone brown",1.2},{"burnt sienna",1},{"raw sienna",0.5}},
 pile{{"bone brown",1.6},{"burnt sienna",0.9},{"raw sienna",0.2}},
 pile{{"bone brown",1.8},{"burnt sienna",0.7},{"bone black",0.4}},
 pile{{"bone black",1},{"bone brown",1.6},{"burnt sienna",0.5}},
 pile{{"bone black",1.4},{"bone brown",1.4},{"burnt sienna",0.3}},
 pile{{"bone black",1.7},{"bone brown",1.2},{"burnt sienna",0.2}},
 pile{{"bone black",1.9},{"bone brown",1}} }
work(-ellipse(CC[1], CC[2], rr(TH[11]), rr(TH[11])), {hand="broad", pile=ramp[12], coverage=3, fill=true, angle=0.3, load=1.0})
for k=11,1,-1 do
  local r0 = (k == 1) and 0 or rr(TH[k-1]); local r1 = rr(TH[k])
  local band = ellipse(CC[1], CC[2], r1, r1) - ((k == 1) and ellipse(0,0,0.1,0.1) or ellipse(CC[1], CC[2], r0, r0))
  work(band, {hand="body", tool={kind="filbert", width=clamp(r1/40,2,14)}, pile=ramp[k], coverage=3.2, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-CC[2], x-CC[1]) + 1.57 end, length={clamp(r1/20,4,40), clamp(r1/6,8,110)}, load=1.0})
end

--@ chunk 2
print(wait(3*24*60))
local dk = pile{{"bone black",2},{"bone brown",0.6}}
local rib = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8}}
local lip = pile{{"yellow ochre",1.2},{"lead white",0.8},{"Indian yellow",0.2}}
-- meridians: radial seams from the pole out to the frame; they curve the shell into a dome
for k=0,31 do local a = k/32*2*math.pi
  local pts = {}; for j=1,11 do local r = rr(TH[j]); pts[#pts+1] = {CC[1] + math.cos(a)*r, CC[2] + math.sin(a)*r} end
  for j=1,#pts-1 do ST({pts[j], pts[j+1]}, dk, clamp(1 + j*0.6, 1, 8), {0.9,0.9}, 1.0) end
end
-- latitude ribs: heavy bronze rings, lit on the edge toward the core
for k=1,11 do local r = rr(TH[k]); local n = math.max(24, math.floor(r/8))
  for j=0,n-1 do local a0, a1 = j/n*2*math.pi, (j+1.08)/n*2*math.pi
    local p0, p1 = {CC[1]+math.cos(a0)*r, CC[2]+math.sin(a0)*r}, {CC[1]+math.cos(a1)*r, CC[2]+math.sin(a1)*r}
    if p0[1] > -60 and p0[1] < 1060 and p0[2] > -60 and p0[2] < 620 then
      ST({p0, p1}, rib, clamp(r/18, 2, 30), {1,1}, 1.0)
      local q0, q1 = {CC[1]+math.cos(a0)*r*0.975, CC[2]+math.sin(a0)*r*0.975}, {CC[1]+math.cos(a1)*r*0.975, CC[2]+math.sin(a1)*r*0.975}
      ST({q0, q1}, lip, clamp(r/90, 1, 6), {0.9,0.9}, 1.0)
    end
  end
end

--@ chunk 3
print(wait(3*24*60))
local dk = pile{{"bone black",2},{"bone brown",0.7}}
local brz = pile{{"bone brown",1.5},{"burnt sienna",0.8},{"bone black",0.4}}
local lit = pile{{"lead white",1.6},{"yellow ochre",0.7},{"Indian yellow",0.3}}
-- radial struts holding the core: heavy dark beams from the core out past the frame, lit on the core-facing edge
CR = 105
for _,a in ipairs({-2.6, -1.45, -0.35, 0.55, 1.15, 2.05, 2.75}) do
  local p0 = {CC[1] + math.cos(a)*CR*0.95, CC[2] + math.sin(a)*CR*0.95}
  local p1 = {CC[1] + math.cos(a)*1300, CC[2] + math.sin(a)*1300}
  local m = ribbon({p0, p1}, {10, 70})
  work(m, {hand="body", tool="filbert 5", pile=dk, coverage=4, fill=true, clip=true, angle=a, length={20,70}, load=1.0})
  local px, py = -math.sin(a), math.cos(a)
  ST({{p0[1] + px*4, p0[2] + py*4},{p1[1] + px*30, p1[2] + py*30}}, lit, 3, {0.9,0.2})
  ST({{p0[1] - px*4, p0[2] - py*4},{p1[1] - px*30, p1[2] - py*30}}, brz, 4, {0.9,0.4})
end
-- the bridge: a straight deck from beneath us to the core, narrowing toward it
BR = poly({{330,563},{670,563},{520,CC[2]+CR*0.9},{480,CC[2]+CR*0.9}})
work(BR, {hand="body", tool="filbert 5", pile=brz, coverage=4, fill=true, clip=true, angle=-1.57, length={20,60}, load=1.0})
ST({{480,CC[2]+CR*0.9},{330,563}}, lit, 3, {0.9,0.9}); ST({{520,CC[2]+CR*0.9},{670,563}}, lit, 3, {0.9,0.9})
for _,t in ipairs({0.1,0.22,0.36,0.52,0.7,0.9}) do local y = lerp(CC[2]+CR*0.9, 563, t); local hw = lerp(20, 170, t)
  ST({{500 - hw, y},{500 + hw, y}}, dk, lerp(1,4,t), {0.8,0.8}) end
-- rails on posts
for _,side in ipairs({-1,1}) do
  local pts = {}
  for _,t in ipairs({0,0.15,0.3,0.45,0.6,0.75,0.9,1.0}) do local y = lerp(CC[2]+CR*0.9, 563, t); local x = 500 + side*lerp(20,170,t)
    local h = lerp(8, 70, t); ST({{x,y},{x,y-h}}, dk, lerp(1,4,t), {1,1}); pts[#pts+1] = {x, y-h} end
  for j=1,#pts-1 do ST({pts[j], pts[j+1]}, dk, 3, {1,1}); ST({{pts[j][1],pts[j][2]-1.5},{pts[j+1][1],pts[j+1][2]-1.5}}, lit, 1.2, {0.8,0.8}) end
end

--@ chunk 4
print(wait(2*24*60))
local g1 = pile{{"yellow ochre",1.2},{"lead white",1.2},{"Indian yellow",0.5}}
local g2 = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.4}}
local g3 = pile{{"lead white",2},{"zinc white",1.5},{"lemon chrome",0.12}}
local fold = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.6}}
-- the core: a sphere of white-gold light, brightest a little off-centre
work(ellipse(CC[1], CC[2], CR, CR), {hand="body", tool="filbert 5", pile=g1, coverage=4.2, fill=true, clip=true, angle=function(x,y) return math.atan(y-CC[2], x-CC[1]) + 1.57 end, length={10,30}, load=1.0})
work(ellipse(CC[1]-8, CC[2]-8, CR*0.78, CR*0.78), {hand="body", tool="filbert 4", pile=g2, coverage=4.2, fill=true, clip=true, angle=function(x,y) return math.atan(y-CC[2], x-CC[1]) + 1.57 end, length={8,24}, load=1.0})
work(ellipse(CC[1]-14, CC[2]-14, CR*0.45, CR*0.45), {hand="body", tool="filbert 3", pile=g3, coverage=4.5, fill=true, clip=true, angle=0.6, length={6,16}, load=1.0})

--@ chunk 5
print(wait(3*24*60))
local fold = pile{{"raw sienna",1},{"yellow ochre",0.8},{"lead white",0.5}}
local g3 = pile{{"lead white",2},{"zinc white",1.5},{"lemon chrome",0.12}}
local g2 = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.4}}
-- its surface folds into smaller copies of itself: little spheres budding on it, each with its own crease and hot point, and smaller ones on those
local function bud(x, y, r, depth)
  local pts = {}; for k=0,20 do local a = 0.3 + k/20*math.pi*1.4; pts[#pts+1] = {x + math.cos(a)*r, y + math.sin(a)*r} end
  ST(pts, fold, math.max(1, r*0.12), {0.9,0.6}, 1.0)
  ST({{x - r*0.3, y - r*0.3},{x - r*0.28, y - r*0.32}}, g3, math.max(1, r*0.35), {1,1}, 1.0)
  if depth > 0 then for k=1,3 do local a = rand(0, 2*math.pi); bud(x + math.cos(a)*r*0.75, y + math.sin(a)*r*0.75, r*0.38, depth-1) end end
end
for k=1,9 do local a = k/9*2*math.pi + 0.2; local d = (k%2==0) and 0.55 or 0.8
  bud(CC[1] + math.cos(a)*CR*d, CC[2] + math.sin(a)*CR*d, CR*((k%2==0) and 0.22 or 0.16), 1) end
-- a corona of light strokes off the rim, onto the struts and the near rings
for k=1,60 do local a = rand(0, 2*math.pi); local L = rand(20, 70)
  ST({{CC[1] + math.cos(a)*CR*1.0, CC[2] + math.sin(a)*CR*1.0},{CC[1] + math.cos(a)*(CR+L), CC[2] + math.sin(a)*(CR+L)}}, g2, rand(1.5,3.5), {0.7,0.0}, 0.7) end
-- the Commando, tiny on the bridge, walking to it; his long shadow cast back toward us
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"bone brown",0.5}}
local fx, fy, H = 503, 445, 40
local function P(pts, p) local q = {}; for i,v in ipairs(pts) do q[i] = {fx + v[1]*H, fy + v[2]*H} end; work(poly(q), {hand="detail", pile=p, coverage=5, fill=true}) end
P({{-0.13,0},{-0.06,-0.45},{-0.15,-0.78},{-0.08,-0.87},{0.08,-0.87},{0.15,-0.78},{0.08,-0.45},{0.14,0},{0.04,0},{0,-0.4},{-0.04,0}}, dk)
P({{-0.07,-0.87},{0.07,-0.87},{0.08,-0.95},{0,-1.02},{-0.08,-0.95}}, dk)
P({{-0.13,-0.76},{0.13,-0.76},{0.12,-0.37},{-0.12,-0.37}}, pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.5}})
ST({{fx-0.15*H, fy-0.8*H},{fx-0.08*H, fy-0.88*H},{fx+0.08*H, fy-0.88*H},{fx+0.15*H, fy-0.8*H}}, g2, 1.4, {0.9,0.9})
ST({{fx, fy-1.02*H},{fx, fy-0.96*H}}, g2, 1.4, {0.9,0.9})
local sh = pile{{"bone black",2},{"bone brown",0.4}}
ST({{fx-3, fy+1},{fx-6, fy+40},{fx-12, fy+110}}, sh, 12, {0.9,0.6}, 1.0)

--@ chunk 6
print(wait(2*24*60))
local dk = pile{{"bone black",1.9},{"bone brown",1}}
local m = -(ellipse(CC[1], CC[2], 470, 330):soften(40)) - BR:grow(4)
work(m, {hand="body", tool="filbert 10", pile=dk, coverage=2.4, fill=true, angle=function(x,y) return math.atan(y-CC[2], x-CC[1]) + 1.57 end, length={30,90}, load=0.8, edge="lost"})
