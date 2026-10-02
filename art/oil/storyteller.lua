-- easel session "storyteller": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=3434,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",0.9},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.3}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.9,0.9}, ramps={0.03,0.1}, clip=clip})
end
-- the arcade's cross-section at depth z: it narrows and climbs as the ring floor curves up ahead
function sec(z) local s = 1/(1+0.42*z)
  local cx = 470 + 60*(1 - s)
  local fy = 285 + 300*s - 26*z^1.25
  return {s=s, cx=cx, hw=560*s, fy=fy, sy=fy - 330*s, vr=300*s} end
function shape(z)
  local c = sec(z); local pts = {}
  for k=0,20 do local a = math.pi + math.pi*k/20; pts[#pts+1] = {c.cx + math.cos(a)*c.hw, c.sy + math.sin(a)*c.vr} end
  pts[#pts+1] = {c.cx + c.hw, c.fy}; pts[#pts+1] = {c.cx - c.hw, c.fy}
  return poly(pts)
end
ZS = {0, 0.5, 1.1, 1.9, 2.9, 4.1, 5.6, 7.4, 9.6, 12.3, 15.5}
local ramp = {
 pile{{"bone black",1.6},{"bone brown",1.3},{"burnt sienna",0.4}},
 pile{{"bone black",1.2},{"bone brown",1.5},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.9},{"bone black",0.4}},
 pile{{"bone brown",1.5},{"burnt sienna",1},{"raw sienna",0.4}},
 pile{{"bone brown",1.1},{"burnt sienna",1},{"raw sienna",0.7}},
 pile{{"raw sienna",1.1},{"burnt sienna",0.9},{"bone brown",0.5}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.6},{"yellow ochre",0.4},{"lead white",0.2}},
 pile{{"raw sienna",1.2},{"yellow ochre",0.7},{"lead white",0.4}},
 pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.7}},
 pile{{"yellow ochre",0.8},{"lead white",1},{"ultramarine ash",0.2}} }
work(everywhere() - shape(0), {hand="broad", pile=ramp[1], coverage=3, fill=true, angle=0.3, load=1.0})
for i=1,#ZS-1 do
  local band = shape(ZS[i]) - shape(ZS[i+1])
  local c = sec(ZS[i])
  work(band, {hand="body", tool={kind="filbert", width=clamp(c.hw/45,2,12)}, pile=ramp[i], coverage=2.8, fill=true, clip=band,
    angle=0.0, length={clamp(c.hw/30,4,40), clamp(c.hw/8,8,100)}, load=1.0})
end
local e = sec(ZS[#ZS])
work(shape(ZS[#ZS]), {hand="body", tool="filbert 2", pile=pile{{"lead white",1.2},{"yellow ochre",0.6},{"ultramarine ash",0.3}}, coverage=3.5, fill=true, clip=true, angle=0, length={4,10}, load=1.0})

--@ chunk 2
print(wait(2*24*60))
function sec(z) local s = 1/(1+0.42*z)
  local cx = 470 + 50*(1 - s)
  local fy = 290 + 300*s - 5.5*z^1.6
  return {s=s, cx=cx, hw=560*s, fy=fy, sy=fy - 330*s, vr=300*s} end
local function arcpts(c, rev) local pts = {}; for k=0,20 do local a = math.pi + math.pi*k/20; pts[#pts+1] = {c.cx + math.cos(a)*c.hw, c.sy + math.sin(a)*c.vr} end
  if rev then local r = {}; for i=#pts,1,-1 do r[#r+1] = pts[i] end; return r end; return pts end
local dark = pile{{"bone black",1.8},{"bone brown",1.1},{"burnt sienna",0.3}}
work(everywhere(), {hand="broad", pile=dark, coverage=3.2, fill=true, angle=0.3, load=1.0})
ZS = {0, 0.6, 1.3, 2.2, 3.3, 4.6, 6.2, 8.1, 10.3, 12.8, 15.6, 19}
FACES = {}
for i=1,#ZS-1 do
  local a, b = sec(ZS[i]), sec(ZS[i+1]); local t = (i-1)/(#ZS-2)
  local floorP = pile{{"raw sienna",0.6 + 0.8*t},{"burnt sienna",0.8},{"bone brown",1.2*(1-t)+0.1},{"lead white",0.15 + 0.6*t*t}}
  local wallP = pile{{"bone brown",1.4*(1-t)+0.2},{"burnt sienna",0.9},{"raw sienna",0.3 + 0.9*t},{"lead white",0.05 + 0.4*t*t}}
  local vaultP = pile{{"bone black",1.2*(1-t)+0.05},{"bone brown",1.2},{"burnt sienna",0.5 + 0.4*t},{"lead white",0.02 + 0.3*t*t}}
  local fl = poly({{a.cx - a.hw, (i==1) and 563 or a.fy},{a.cx + a.hw, (i==1) and 563 or a.fy},{b.cx + b.hw, b.fy},{b.cx - b.hw, b.fy}})
  local lw = poly({{a.cx - a.hw, a.fy},{a.cx - a.hw, a.sy},{b.cx - b.hw, b.sy},{b.cx - b.hw, b.fy}})
  local rw = poly({{a.cx + a.hw, a.fy},{a.cx + a.hw, a.sy},{b.cx + b.hw, b.sy},{b.cx + b.hw, b.fy}})
  local vp = arcpts(a); for _,p in ipairs(arcpts(b, true)) do vp[#vp+1] = p end
  local vt = poly(vp)
  local tw = {kind="filbert", width=clamp(a.hw/45,2,12)}
  work(vt, {hand="body", tool=tw, pile=vaultP, coverage=3, fill=true, clip=vt, angle=0, length={10,60}, load=1.0})
  work(lw + rw, {hand="body", tool=tw, pile=wallP, coverage=3, fill=true, clip=lw + rw, angle=1.57, length={10,60}, load=1.0})
  work(fl, {hand="body", tool=tw, pile=floorP, coverage=3, fill=true, clip=fl, angle=0, length={10,60}, load=1.0})
end
SEC = sec

--@ chunk 3
print(wait(3*24*60))
local rib = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.7}}
local ribL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.6}}
local dk = pile{{"bone black",2},{"bone brown",0.5}}
local lampA = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local lampC = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local glow = pile{{"raw sienna",1},{"yellow ochre",0.7},{"lead white",0.5}}
-- the arches: piers and round heads, receding and climbing; a warm lamp hanging under each
AZ = {0.3, 1.3, 2.2, 3.3, 4.6, 6.2, 8.1, 10.3, 12.8, 15.6}
for _,z in ipairs(AZ) do
  local c = SEC(z); local w = math.max(1.5, 46*c.s)
  local pts = {{c.cx - c.hw, c.fy}, {c.cx - c.hw, c.sy}}
  for k=1,19 do local a = math.pi + math.pi*k/20; pts[#pts+1] = {c.cx + math.cos(a)*c.hw, c.sy + math.sin(a)*c.vr} end
  pts[#pts+1] = {c.cx + c.hw, c.sy}; pts[#pts+1] = {c.cx + c.hw, c.fy}
  for j=1,#pts-1 do
    ST({pts[j], pts[j+1]}, rib, w, {1,1}, 1.0)
    local ia = {lerp(pts[j][1], c.cx, 0.03), lerp(pts[j][2], c.sy, 0.03)}; local ib = {lerp(pts[j+1][1], c.cx, 0.03), lerp(pts[j+1][2], c.sy, 0.03)}
    ST({ia, ib}, ribL, math.max(0.7, 6*c.s), {0.9,0.9}, 1.0)
  end
  -- the lamp on a chain from the arch's crown
  local top = {c.cx, c.sy - c.vr}; local lp = {c.cx, c.sy - c.vr*0.55}
  ST({top, lp}, dk, math.max(0.8, 4*c.s), {0.9,0.9}, 1.0)
  ST({lp, {lp[1]+0.1, lp[2]+0.1}}, lampA, math.max(2, 30*c.s), {1,1}, 1.0)
  ST({lp, {lp[1]+0.1, lp[2]+0.1}}, lampC, math.max(1, 13*c.s), {1,1}, 1.0)
  for j=1,10 do local a = j/10*2*math.pi; ST({{lp[1] + math.cos(a)*18*c.s, lp[2] + math.sin(a)*18*c.s},{lp[1] + math.cos(a)*48*c.s, lp[2] + math.sin(a)*48*c.s}}, lampA, math.max(0.6, 3*c.s), {0.5,0}, 0.6) end
  -- its pool on the floor below
  for k=-3,3 do local zz = z + k*0.08*(1 + 0.3*z); local cc = SEC(zz)
    ST({{cc.cx - cc.hw*(0.45 - math.abs(k)*0.08), cc.fy},{cc.cx + cc.hw*(0.45 - math.abs(k)*0.08), cc.fy}}, glow, math.max(1, 10*cc.s), {0.6 - math.abs(k)*0.12, 0.6 - math.abs(k)*0.12}, 0.7) end
end

--@ chunk 4
print(wait(2*24*60))
local rib = pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.7}}
local ribD = pile{{"bone brown",1.6},{"burnt sienna",0.8},{"bone black",0.4}}
local ribL = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.7}}
local dk = pile{{"bone black",2},{"bone brown",0.5}}
local lampA = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local lampC = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
-- the arches restated solid: each segment twice, dark core then the lit inner edge
for _,z in ipairs(AZ) do
  local c = SEC(z); local w = math.max(1.5, 40*c.s)
  local pts = {{c.cx - c.hw, c.fy}, {c.cx - c.hw, c.sy}}
  for k=1,19 do local a = math.pi + math.pi*k/20; pts[#pts+1] = {c.cx + math.cos(a)*c.hw, c.sy + math.sin(a)*c.vr} end
  pts[#pts+1] = {c.cx + c.hw, c.sy}; pts[#pts+1] = {c.cx + c.hw, c.fy}
  for j=1,#pts-1 do
    local seglen = math.sqrt((pts[j+1][1]-pts[j][1])^2 + (pts[j+1][2]-pts[j][2])^2)
    local n = math.max(1, math.ceil(seglen/40))
    for q=0,n-1 do local p0 = {lerp(pts[j][1],pts[j+1][1],q/n), lerp(pts[j][2],pts[j+1][2],q/n)}; local p1 = {lerp(pts[j][1],pts[j+1][1],(q+1.1)/n), lerp(pts[j][2],pts[j+1][2],(q+1.1)/n)}
      ST({p0,p1}, ribD, w, {1,1}, 1.0); ST({p0,p1}, rib, w*0.6, {1,1}, 1.0)
      ST({{lerp(p0[1], c.cx, 0.035), lerp(p0[2], c.sy, 0.035)}, {lerp(p1[1], c.cx, 0.035), lerp(p1[2], c.sy, 0.035)}}, ribL, math.max(0.8, 6*c.s), {1,1}, 1.0) end
  end
  -- wall lamps on both piers at head height
  for _,side in ipairs({-1, 1}) do
    local lp = {c.cx + side*c.hw*0.97, lerp(c.fy, c.sy, 0.55)}
    ST({{lp[1], lp[2] + 30*c.s},{lp[1], lp[2]}}, dk, math.max(0.8, 6*c.s), {1,1}, 1.0)
    ST({lp, {lp[1]+0.1, lp[2]+0.1}}, lampA, math.max(2, 34*c.s), {1,1}, 1.0)
    ST({lp, {lp[1]+0.1, lp[2]+0.1}}, lampC, math.max(1, 15*c.s), {1,1}, 1.0)
    for j=1,10 do local a = j/10*2*math.pi; ST({{lp[1] + math.cos(a)*22*c.s, lp[2] + math.sin(a)*22*c.s},{lp[1] + math.cos(a)*60*c.s, lp[2] + math.sin(a)*60*c.s}}, lampA, math.max(0.6, 3*c.s), {0.5,0}, 0.6) end
  end
end

--@ chunk 5
print(wait(3*24*60))
local lampA = pile{{"Indian yellow",1},{"Mars orange",0.3},{"lead white",0.8}}
local lampC = pile{{"lead white",2},{"Indian yellow",0.6},{"lemon chrome",0.1}}
local dk = pile{{"bone black",2},{"bone brown",0.5}}
local cloth = {pile{{"red earth",1},{"burnt sienna",0.5},{"lead white",0.2}}, pile{{"raw sienna",1},{"yellow ochre",0.5},{"lead white",0.3}}, pile{{"bone brown",1},{"cobalt violet",0.3},{"lead white",0.3}}}
local stall = pile{{"bone brown",1.4},{"burnt sienna",0.8},{"bone black",0.3}}
local bone = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.2}}
local boneD = pile{{"yellow ochre",1},{"raw sienna",0.7},{"lead white",0.5}}
-- wall lamps as solid glass bodies
for _,z in ipairs(AZ) do local c = SEC(z)
  for _,side in ipairs({-1, 1}) do local lp = {c.cx + side*c.hw*0.97, lerp(c.fy, c.sy, 0.55)}
    work(ellipse(lp[1], lp[2], math.max(1.5, 12*c.s), math.max(2, 16*c.s)), {hand="detail", pile=lampA, coverage=5, fill=true})
    work(ellipse(lp[1], lp[2], math.max(0.8, 5*c.s), math.max(1, 7*c.s)), {hand="detail", pile=lampC, coverage=5, fill=true})
  end
end
-- market stalls between the piers, both sides: a counter, an awning, and bone goods laid out
for i=1,#AZ-1 do
  local za, zb = AZ[i] + 0.15*(AZ[i+1]-AZ[i]), AZ[i] + 0.85*(AZ[i+1]-AZ[i])
  local a, b = SEC(za), SEC(zb)
  for _,side in ipairs({-1, 1}) do
    local inA, inB = 0.86, 0.86
    local fa = {a.cx + side*a.hw*inA, a.fy}; local fb = {b.cx + side*b.hw*inB, b.fy}
    local ha, hb = 120*a.s, 120*b.s
    local counter = poly({fa, fb, {fb[1], fb[2] - hb*0.45}, {fa[1], fa[2] - ha*0.45}})
    work(counter, {hand="detail", pile=stall, coverage=4.5, fill=true})
    -- the counter top, lit, with goods on it
    ST({{fa[1], fa[2] - ha*0.45}, {fb[1], fb[2] - hb*0.45}}, boneD, math.max(1, 6*a.s), {0.9,0.9}, 1.0)
    for k=1,6 do local t = (k-0.5)/6; local p = {lerp(fa[1],fb[1],t), lerp(fa[2] - ha*0.5, fb[2] - hb*0.5, t)}; local sz = lerp(a.s, b.s, t)
      ST({{p[1] - 4*sz, p[2]}, {p[1] + 4*sz, p[2] - 6*sz}}, (k%2==0) and bone or boneD, math.max(1, 9*sz), {1,0.6}, 1.0) end
    -- an awning sloping out from the wall
    local aw = poly({{a.cx + side*a.hw*0.99, a.fy - ha*1.25}, {b.cx + side*b.hw*0.99, b.fy - hb*1.25}, {fb[1] - side*8*b.s, fb[2] - hb*0.95}, {fa[1] - side*8*a.s, fa[2] - ha*0.95}})
    work(aw, {hand="detail", pile=cloth[(i % 3) + 1], coverage=4.5, fill=true})
    ST({{fa[1] - side*8*a.s, fa[2] - ha*0.95}, {fb[1] - side*8*b.s, fb[2] - hb*0.95}}, dk, math.max(0.8, 4*a.s), {0.9,0.9}, 1.0)
    -- the posts holding it
    ST({{fa[1] - side*6*a.s, fa[2]}, {fa[1] - side*8*a.s, fa[2] - ha*0.95}}, dk, math.max(0.8, 5*a.s), {1,1}, 1.0)
  end
end
