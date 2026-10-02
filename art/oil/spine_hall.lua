-- easel session "spine_hall": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=7171,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.8},{"lead white",0.2}}, um=90, apply="knife", texture=0.35}}}
VP = {500,300}; R0 = 1400; H0 = 300
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.6}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.4}, clip=clip})
end
function ring(s) return VP[1], VP[2] - (R0-H0)*s, R0*s end
function disc(s, f) local cx, cy, r = ring(s); return ellipse(cx, cy, r*(f or 1), r*(f or 1)) end
SS = {1, 0.62, 0.42, 0.3, 0.22, 0.165, 0.125, 0.095, 0.073, 0.056, 0.043, 0.033, 0.025, 0.019, 0.014}
local ramp = {
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.4},{"bone brown",1.5},{"burnt sienna",0.4}},
 pile{{"bone black",1},{"bone brown",1.6},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.8},{"bone black",0.5}},
 pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.3}},
 pile{{"bone brown",1.2},{"burnt sienna",1},{"raw sienna",0.6}},
 pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.9},{"bone brown",0.4},{"yellow ochre",0.2}},
 pile{{"raw sienna",1.4},{"burnt sienna",0.7},{"yellow ochre",0.5},{"lead white",0.2}},
 pile{{"raw sienna",1.3},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.4}},
 pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.7}},
 pile{{"yellow ochre",1},{"lead white",1},{"Indian yellow",0.3}},
 pile{{"lead white",1.4},{"yellow ochre",0.8},{"Indian yellow",0.4}},
 pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.4}} }
for i=1,#SS-1 do
  local band = disc(SS[i]) - disc(SS[i+1])
  local _, _, r = ring(SS[i])
  work(band, {hand="body", tool={kind="filbert", width=clamp(r/40, 2, 14)}, pile=ramp[i], coverage=3, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(r/30,4,40), clamp(r/8,8,110)}, load=1.0})
end
work(disc(SS[#SS]), {hand="detail", pile=pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.4}}, coverage=4, fill=true})

--@ chunk 2
print(wait(3*24*60))
local ribD = pile{{"bone black",1.6},{"bone brown",1.2},{"burnt sienna",0.3}}
local ribM = pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.4}}
local lipW = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local lipH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}
local lamp = pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.6}}
local seam = pile{{"bone black",2},{"bone brown",0.6}}
-- ribs: heavy bronze rings with a warm lit inner lip; halfway between each pair a fainter seam ring
for i=#SS-1,1,-1 do
  local s = SS[i]; local cx, cy, r = ring(s)
  local rib = disc(s) - disc(s, 0.965)
  work(rib, {hand="body", tool={kind="filbert", width=clamp(r/60,1.5,10)}, pile=(i < 5) and ribD or ribM, coverage=3.6, fill=true, clip=rib,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) + 1.57 end, length={clamp(r/15,4,60), clamp(r/5,8,140)}, load=1.0})
  local pts = {}; for k=0,96 do local a = k/96*2*math.pi; pts[#pts+1] = {cx+math.cos(a)*r*0.965, cy+math.sin(a)*r*0.965} end
  ST(pts, (i > 6) and lipH or lipW, clamp(r/150, 1, 6), {0.8,0.8}, 1.0)
  local s2 = (SS[i] + SS[i+1]) / 2; local cx2, cy2, r2 = ring(s2)
  local p2 = {}; for k=0,96 do local a = k/96*2*math.pi; p2[#p2+1] = {cx2+math.cos(a)*r2, cy2+math.sin(a)*r2} end
  ST(p2, seam, clamp(r2/220, 1, 4), {0.6,0.6}, 0.8)
end
-- lamp-rings on every other rib: a ring of small warm lights, receding into a string of pearls
for i=2,#SS-1,2 do
  local s = SS[i]; local cx, cy, r = ring(s)
  local n = 28
  for k=0,n-1 do local a = k/n*2*math.pi + 0.05
    local x, y = cx + math.cos(a)*r*0.95, cy + math.sin(a)*r*0.95
    if x > -20 and x < 1020 and y > -20 and y < 580 then
      local d = clamp(r/90, 1.2, 9)
      work(ellipse(x, y, d, d), {hand="detail", pile=lamp, coverage=4, fill=true})
      if d > 3 then for j=1,6 do local b = j/6*2*math.pi; ST({{x+math.cos(b)*d,y+math.sin(b)*d},{x+math.cos(b)*d*2.6,y+math.sin(b)*d*2.6}}, lipH, d*0.3, {0.6,0}, 0.6) end end
    end
  end
end

--@ chunk 3
print(wait(2*24*60))
local dk = pile{{"bone black",1.8},{"bone brown",1}}
local railL = pile{{"lead white",1.5},{"yellow ochre",0.7},{"raw sienna",0.3}}
local railM = pile{{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.5}}
-- side openings to the vault bays: dark arches set into the wall between ribs, both sides
for i=2,#SS-3 do
  local sa, sb = SS[i], SS[i+1]
  local s = (sa*0.6 + sb*0.4)
  local cx, cy, r = ring(s)
  for _,a in ipairs({math.pi*0.62, math.pi*0.38, math.pi*1.0, 0.0}) do
    local x, y = cx + math.cos(a)*r*0.985, cy + math.sin(a)*r*0.985
    local w, h = (sa-sb)*R0*0.5, (sa-sb)*R0*0.9
    if y > -40 and y < 600 and x > -60 and x < 1060 then
      local arch = rect(x - w/2, y - h*0.6, w, h*0.6) + ellipse(x, y - h*0.6, w/2, w*0.45)
      -- foreshortened: the arch lies on the curved wall, squash toward the vanishing point
      work(arch, {hand="detail", pile=dk, coverage=4, fill=true})
      local lip = {}; for k=0,12 do local t = math.pi + k/12*math.pi; lip[#lip+1] = {x + math.cos(t)*w/2, y - h*0.6 + math.sin(t)*w*0.45} end
      ST(lip, railM, math.max(1, w*0.06), {0.8,0.8})
    end
  end
end
-- the rail down the floor's centre: two bright lines converging to the far point, on dark sleepers
local function fl(s, off) local cx, cy, r = ring(s); return {VP[1] + off*s, VP[2] + H0*s} end
for _,off in ipairs({-60, 60}) do
  local pts = {}; for _,s in ipairs({1.2,0.8,0.5,0.3,0.18,0.1,0.05,0.025,0.014}) do pts[#pts+1] = fl(s, off) end
  ST(pts, dk, 9, {0.9,0.05}, 1.0); ST(pts, railL, 4, {0.9,0.05}, 1.0)
end
for _,s in ipairs({1.0,0.82,0.67,0.55,0.45,0.37,0.3,0.245,0.2,0.165,0.135,0.11,0.09,0.074,0.06,0.049,0.04}) do
  local a, b = fl(s, -90), fl(s, 90); ST({a,b}, dk, math.max(1, 10*s), {0.9,0.9}, 1.0)
end

--@ chunk 4
print(wait(2*24*60))
local dk = pile{{"bone black",1.6},{"bone brown",1.2}}
local brz = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone brown",0.6}}
local lamp = pile{{"lead white",2},{"zinc white",1},{"Indian yellow",0.6}}
local amber = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local ramp1 = pile{{"bone black",1.6},{"bone brown",1.3},{"burnt sienna",0.35}}
-- the near lamp-ring's lights given bronze housings: dark collar, amber lens, hot core (no starburst)
for _,i in ipairs({2,4}) do
  local s = SS[i]; local cx, cy, r = ring(s)
  for k=0,27 do local a = k/28*2*math.pi + 0.05
    local x, y = cx + math.cos(a)*r*0.95, cy + math.sin(a)*r*0.95
    local d = clamp(r/90, 1.2, 9)
    if d > 3 and x > -20 and x < 1020 and y > -20 and y < 580 then
      work(ellipse(x, y, d*2.8, d*2.8), {hand="detail", pile=ramp1, coverage=4, fill=true})
      work(ellipse(x, y, d*1.7, d*1.7), {hand="detail", pile=dk, coverage=4, fill=true})
      ST({{x-d*1.6,y-d*0.6},{x-d*0.6,y-d*1.6}}, brz, d*0.5, {0.8,0.3})
      work(ellipse(x, y, d*1.1, d*1.1), {hand="detail", pile=amber, coverage=4, fill=true})
      work(ellipse(x, y, d*0.55, d*0.55), {hand="detail", pile=lamp, coverage=4, fill=true})
    end
  end
end
-- a cargo sled on the rail in the middle distance: a bronze box on runners, lit from the far glow
local s = 0.16; local fx, fy = VP[1], VP[2] + H0*s
local w, h = 150*s, 110*s
local sled = rect(fx - w/2, fy - h, w, h)
work(sled, {hand="detail", pile=dk, coverage=4, fill=true})
work(rect(fx - w/2, fy - h, w, h*0.18), {hand="detail", pile=brz, coverage=4, fill=true})
ST({{fx - w/2, fy - h},{fx + w/2, fy - h}}, pile{{"lead white",2},{"Indian yellow",0.5}}, 1.6, {0.9,0.9})
ST({{fx - w/2 - 2, fy},{fx + w/2 + 2, fy}}, dk, 2.4, {0.9,0.9})
ST({{fx - w*0.3, fy - h*0.5},{fx + w*0.3, fy - h*0.5}}, brz, 1.4, {0.7,0.7})
-- the Commando, tiny, on the rail line in the foreground, back to us
local x0, y0 = 500, 480
local cmd = poly({{x0-6,y0},{x0-4,y0-16},{x0-7,y0-30},{x0-3,y0-40},{x0+3,y0-40},{x0+7,y0-30},{x0+4,y0-16},{x0+6,y0},{x0+2,y0},{x0,y0-14},{x0-2,y0}})
work(cmd + ellipse(x0, y0-45, 4.4, 5) + rect(x0-11, y0-38, 22, 8), {hand="detail", pile=dk, coverage=4.5, fill=true})
work(poly({{x0-6,y0-30},{x0+6,y0-30},{x0+7,y0-14},{x0-7,y0-14}}), {hand="detail", pile=pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.4}}, coverage=4, fill=true})
ST({{x0-1,y0-29},{x0-1,y0-17}}, pile{{"lead white",2},{"ultramarine ash",0.5}}, 1.6, {0.9,0.9}); ST({{x0-5,y0-24},{x0+3,y0-24}}, pile{{"lead white",2},{"ultramarine ash",0.5}}, 1.6, {0.9,0.9})
ST({{x0-4,y0-49},{x0+3,y0-50},{x0+9,y0-38}}, pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.5}}, 1.2, {0.8,0.4})
-- his shadow down the rail toward us
ST({{x0,y0+2},{x0-6,y0+40},{x0-10,y0+80}}, pile{{"bone black",2}}, 8, {0.6,0.1}, 0.8)
