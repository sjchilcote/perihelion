-- easel session "maw2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=640, aspect=16/9, linen=18, seed=5151,
  ground={{pile={{"bone brown",2},{"burnt sienna",1},{"bone black",1},{"lead white",0.15}}, um=90, apply="knife", texture=0.35}}}
VP = {640,215}; C0 = {470,330}; R0 = 900; KZ = 0.59; ZM = 10
function S(z) return 1/(1+KZ*z) end
function sec(z) local s = S(z); return VP[1] + (C0[1]-VP[1])*s, VP[2] + (C0[2]-VP[2])*s, R0*s end
function ST(pts, p, w, pr, load, clip)
  local b = brush{kind="round", width=w, point=0.6}; b:load(p, load or 1.0)
  b:stroke(pts, {pressure=pr or {0.8,0.3}, ramps={0.06,0.4}, clip=clip})
end
function disc(z, f) local cx, cy, r = sec(z); return ellipse(cx, cy, r*(f or 1), r*(f or 1)) end
ZS = {0, 0.35, 0.8, 1.35, 2.0, 2.8, 3.8, 5.0, 6.4, 8.0, 10}
MOUTH = disc(ZM, 0.97)
-- wall bands from near (dark) to far (warm), each a surface between two rings
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
 pile{{"raw sienna",1.3},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.4}} }
local outside = -disc(0)
work(outside, {hand="broad", pile=ramp[1], coverage=2.6, fill=true, angle=0.3})
for i=1,#ZS-1 do
  local band = disc(ZS[i]) - disc(ZS[i+1])
  local cx, cy = sec(ZS[i])
  local _, _, r = sec(ZS[i])
  work(band, {hand="body", tool={kind="filbert", width=clamp(r/30, 3, 14)}, pile=ramp[i], coverage=2.8, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(r/20,6,40), clamp(r/6,14,110)}, load=1.0})
end
work(MOUTH, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"ultramarine blue",0.6}}, coverage=3.6, fill=true, clip=true, angle=0, length={10,30}, load=1.0})

--@ chunk 2
print(wait(2*24*60))
function sector(a0, a1)
  return mask(function(x,y)
    local a = math.atan(y-VP[2], x-VP[1])
    local d = (a - a0) % (2*math.pi)
    return (d <= (a1-a0) % (2*math.pi)) and 1 or 0 end)
end
-- the side away from the light falls into shadow along the whole throat
local shadeP = pile{{"bone black",1.5},{"bone brown",1.4},{"burnt sienna",0.3}}
local shadeP2 = pile{{"bone brown",1.6},{"bone black",0.8},{"burnt sienna",0.5}}
local shadow = sector(-2.2, 0.1):soften(30)
for i=1,#ZS-1 do
  local band = disc(ZS[i]) - disc(ZS[i+1])
  local _, _, r = sec(ZS[i])
  work(band * shadow, {hand="body", tool={kind="filbert", width=clamp(r/30, 3, 14)}, pile=(i < 6) and shadeP or shadeP2, coverage=2.6, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(r/20,6,40), clamp(r/6,14,110)}, load=1.0, edge="soft"})
end
-- sunlight through the mouth strikes the lower-left wall near the opening: one hard-edged sheet of light
SUNM = (disc(4.2) - disc(ZM)) * sector(1.75, 3.25)
local sun1 = pile{{"lead white",1.6},{"yellow ochre",0.8},{"raw sienna",0.4}}
local sun2 = pile{{"lead white",2},{"Indian yellow",0.4},{"yellow ochre",0.4}}
work(SUNM, {hand="body", tool="filbert 4", pile=sun1, coverage=3.4, fill=true, clip=SUNM,
  angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={8,30}, load=1.0})
SUN2 = (disc(6.4) - disc(ZM)) * sector(1.95, 3.05)
work(SUN2, {hand="body", tool="filbert 3", pile=sun2, coverage=3.4, fill=true, clip=SUN2,
  angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={6,20}, load=1.0})

--@ chunk 3
print(wait(3*24*60))
RAMP = {
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.4},{"bone brown",1.5},{"burnt sienna",0.4}},
 pile{{"bone black",1},{"bone brown",1.6},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.8},{"bone black",0.5}},
 pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.3}},
 pile{{"bone brown",1.2},{"burnt sienna",1},{"raw sienna",0.6}},
 pile{{"raw sienna",1},{"burnt sienna",1},{"bone brown",0.8}},
 pile{{"raw sienna",1.3},{"burnt sienna",0.9},{"bone brown",0.4},{"yellow ochre",0.2}},
 pile{{"raw sienna",1.4},{"burnt sienna",0.7},{"yellow ochre",0.5},{"lead white",0.2}},
 pile{{"raw sienna",1.3},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.4}} }
local SH = {
 pile{{"bone black",2},{"bone brown",1},{"burnt sienna",0.2}},
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.6},{"bone brown",1.3},{"burnt sienna",0.3}},
 pile{{"bone black",1.4},{"bone brown",1.5},{"burnt sienna",0.4}},
 pile{{"bone black",1.2},{"bone brown",1.6},{"burnt sienna",0.5}},
 pile{{"bone black",1},{"bone brown",1.6},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.8},{"bone black",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.9},{"bone black",0.4}},
 pile{{"bone brown",1.6},{"burnt sienna",1},{"bone black",0.3}},
 pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.3}} }
-- shadow side: the upper-right crescent of the throat, its edge curving like the cylinder's own turning
local cx0, cy0, r0 = sec(0)
SHADE = -ellipse(cx0 - 160, cy0 + 120, r0*1.0, r0*1.0)
for i=1,#ZS-1 do
  local band = disc(ZS[i]) - disc(ZS[i+1])
  local _, _, r = sec(ZS[i])
  local opt = {hand="body", tool={kind="filbert", width=clamp(r/30, 3, 14)}, coverage=3.2, fill=true, clip=band,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) end, length={clamp(r/20,6,40), clamp(r/6,14,110)}, load=1.0}
  opt.pile = RAMP[i]; work(band - SHADE, opt)
  opt.pile = SH[i]; work(band * SHADE, opt)
end

--@ chunk 4
print(wait(3*24*60))
local cxm, cym, rm = sec(ZM)
local cx4, cy4, r4 = sec(4.4)
-- the sheet of sunlight on the lower-left wall: its edge is the rim's shadow, a curve
SUNM = (disc(4.4) - disc(ZM, 0.98)) - ellipse(cxm + rm*0.9, cym - rm*0.75, r4*0.98, r4*0.98)
SUN2 = (disc(6.6) - disc(ZM, 0.98)) - ellipse(cxm + rm*0.75, cym - rm*0.65, r4*0.78, r4*0.78)
local sun1 = pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.9}}
local sun2 = pile{{"lead white",1.8},{"yellow ochre",0.7},{"Indian yellow",0.3}}
local rad = function(x,y) return math.atan(y-VP[2], x-VP[1]) + 1.57 end
work(SUNM, {hand="body", tool="filbert 4", pile=sun1, coverage=3.4, fill=true, clip=SUNM, angle=rad, length={8,30}, load=1.0})
work(SUN2, {hand="body", tool="filbert 3", pile=sun2, coverage=3.4, fill=true, clip=SUN2, angle=rad, length={6,20}, load=1.0})
-- deeper shadow over the upper right of the throat
local cx0, cy0, r0 = sec(0)
local SH2 = (disc(0) - disc(ZM)) - ellipse(cx0 - 120, cy0 + 260, r0*1.02, r0*1.02) - SUNM
local shp = pile{{"bone black",1.6},{"bone brown",1.3},{"burnt sienna",0.3}}
work(SH2, {hand="body", tool="filbert 8", pile=shp, coverage=3, fill=true, clip=SH2, angle=rad, length={20,70}, load=1.0, edge="soft"})

--@ chunk 5
print(wait(3*24*60))
local rad = function(x,y) return math.atan(y-VP[2], x-VP[1]) + 1.57 end
local L = {
 {3.8,5.0, pile{{"raw sienna",1.4},{"burnt sienna",0.9},{"bone brown",0.5}}},
 {5.0,6.4, pile{{"raw sienna",1.4},{"yellow ochre",0.5},{"burnt sienna",0.6}}},
 {6.4,8.0, pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.4}}},
 {8.0,10,  pile{{"yellow ochre",1},{"lead white",1.2},{"raw sienna",0.3}}} }
local cxm, cym, rm = sec(ZM)
local _, _, r4 = sec(4.4)
local lit = -ellipse(cxm + rm*0.9, cym - rm*0.75, r4*0.98, r4*0.98)
local hard = pile{{"lead white",2},{"Indian yellow",0.4},{"yellow ochre",0.4}}
for i,l in ipairs(L) do
  local band = (disc(l[1]) - disc(l[2])) * lit - disc(ZM, 0.98)
  work(band, {hand="body", tool="filbert 4", pile=l[3], coverage=3.6, fill=true, clip=band, angle=rad, length={8,30}, load=1.0})
end
-- the shadow side of each lit band, beyond the curve, back to its ramp tone where the crescent overran
local over = (disc(3.8) - disc(ZM)) * ellipse(cxm + rm*0.9, cym - rm*0.75, r4*0.98, r4*0.98) * mask(function(x,y) return (x < cxm + 40 or y > cym + 60) and 1 or 0 end)
work(over, {hand="body", tool="filbert 4", pile=pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.4}}, coverage=3.4, fill=true, clip=over, angle=rad, length={8,30}, load=1.0})

--@ chunk 6
print(wait(3*24*60))
local rad = function(x,y) return math.atan(y-VP[2], x-VP[1]) + 1.57 end
local cxm, cym, rm = sec(ZM)
local _, _, r4 = sec(4.4)
local hooks = (disc(3.8) - disc(ZM)) * ellipse(cxm + rm*0.9, cym - rm*0.75, r4*0.98, r4*0.98) * mask(function(x,y) return (x < cxm + 40 or y > cym + 60) and 1 or 0 end)
hooks = hooks:grow(3) - disc(ZM, 0.98)
for i=7,#ZS-1 do
  local band = (disc(ZS[i]) - disc(ZS[i+1])) * hooks
  work(band, {hand="body", tool="filbert 3", pile=RAMP[i-1], coverage=3.6, fill=true, clip=band, angle=rad, length={6,20}, load=1.0})
end

--@ chunk 7
print(wait(2*24*60))
SH = {
 pile{{"bone black",2},{"bone brown",1},{"burnt sienna",0.2}},
 pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}},
 pile{{"bone black",1.6},{"bone brown",1.3},{"burnt sienna",0.3}},
 pile{{"bone black",1.4},{"bone brown",1.5},{"burnt sienna",0.4}},
 pile{{"bone black",1.2},{"bone brown",1.6},{"burnt sienna",0.5}},
 pile{{"bone black",1},{"bone brown",1.6},{"burnt sienna",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.8},{"bone black",0.6}},
 pile{{"bone brown",1.8},{"burnt sienna",0.9},{"bone black",0.4}},
 pile{{"bone brown",1.6},{"burnt sienna",1},{"bone black",0.3}},
 pile{{"bone brown",1.4},{"burnt sienna",1},{"raw sienna",0.3}} }
local seam = pile{{"bone black",2},{"bone brown",0.6}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.6}}
local warm = pile{{"yellow ochre",1.3},{"raw sienna",0.7},{"lead white",0.6}}
local cxm, cym, rm = sec(ZM)
local _, _, r4 = sec(4.4)
local function litAt(x, y, z) return z > 3.6 and ((x-(cxm+rm*0.9))^2 + (y-(cym-rm*0.75))^2 > (r4*0.98)^2) end
for i=#ZS-1,2,-1 do
  local z = ZS[i]
  local cx, cy, r = sec(z)
  local n = 34
  local toneD = SH[math.max(1,i-1)]
  local toneM = RAMP[math.max(1,i-1)]
  -- rib: a heavy ring projecting inward
  local rib = disc(z) - disc(z, 0.955)
  work(rib, {hand="body", tool={kind="filbert", width=clamp(r/40,2,10)}, pile=toneD, coverage=3.4, fill=true, clip=rib,
    angle=function(x,y) return math.atan(y-VP[2], x-VP[1]) + 1.57 end, length={clamp(r/15,6,40), clamp(r/5,12,100)}, load=1.0})
  -- teeth: house-sized plates along the rib's inner edge
  for k=0,n-1 do
    local a0 = k/n*2*math.pi + i*0.21; local a1 = (k+0.86)/n*2*math.pi + i*0.21; local am = (a0+a1)/2
    local q = {{cx+math.cos(a0)*r*0.955, cy+math.sin(a0)*r*0.955}, {cx+math.cos(a1)*r*0.955, cy+math.sin(a1)*r*0.955},
               {cx+math.cos(am+0.03)*r*0.86, cy+math.sin(am+0.03)*r*0.86}, {cx+math.cos(am-0.03)*r*0.86, cy+math.sin(am-0.03)*r*0.86}}
    local tip = {cx+math.cos(am)*r*0.86, cy+math.sin(am)*r*0.86}
    local m = poly(q) - disc(ZM, 0.98)
    if m:area() > 3 and tip[1] > -50 and tip[1] < 1050 and tip[2] > -50 and tip[2] < 620 then
      local lit = litAt(tip[1], tip[2], z)
      work(m, {hand="body", tool={kind="filbert", width=clamp(r/60,2,8)}, pile=lit and toneM or toneD, coverage=3.4, fill=true, clip=m, angle=am+1.57, length={clamp(r/40,4,20), clamp(r/12,8,50)}, load=1.0})
      -- lit face toward the light, shadow edge on the other side
      ST({q[1], {lerp(q[1][1],tip[1],0.9), lerp(q[1][2],tip[2],0.9)}}, lit and warmH or warm, clamp(r/90,1.2,5), {lit and 0.9 or 0.4, 0.3}, 1.0, m:grow(1))
      ST({q[2], tip}, seam, clamp(r/100,1.2,5), {0.8,0.5}, 1.0, m:grow(1))
    end
  end
  -- the rib's inner lip catches light
  local pts = {}; for k=0,72 do local a = k/72*2*math.pi; pts[#pts+1] = {cx+math.cos(a)*r*0.955, cy+math.sin(a)*r*0.955} end
  ST(pts, seam, clamp(r/70,1.5,7), {0.9,0.9}, 1.0, -disc(ZM, 0.98))
end

--@ chunk 8
print(wait(2*24*60))
local cxm, cym, rm = sec(ZM)
MC = {cxm, cym, rm}
ICE = poly({{cxm-rm*0.78,cym+rm*0.05},{cxm-rm*0.62,cym-rm*0.5},{cxm-rm*0.2,cym-rm*0.78},{cxm+rm*0.32,cym-rm*0.72},{cxm+rm*0.72,cym-rm*0.36},{cxm+rm*0.82,cym+rm*0.14},{cxm+rm*0.56,cym+rm*0.6},{cxm+rm*0.06,cym+rm*0.8},{cxm-rm*0.48,cym+rm*0.62}}) * disc(ZM, 0.98)
local iceD = pile{{"ultramarine blue",1},{"bone black",0.5},{"ultramarine ash",1},{"lead white",0.5}}
local iceM = pile{{"ultramarine ash",1.2},{"cerulean blue",0.5},{"lead white",1.3}}
local iceL = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4}}
work(ICE, {hand="body", tool="filbert 4", pile=iceD, coverage=3.8, fill=true, clip=true, angle=0.8, length={8,24}, load=1.0})
local function F(pts, p, a) local q = {}; for i,pt in ipairs(pts) do q[i] = {cxm + pt[1]*rm, cym + pt[2]*rm} end
  local m = poly(q) * ICE; work(m, {hand="body", tool="filbert 3", pile=p, coverage=3.8, fill=true, clip=m, angle=a, length={6,18}, load=1.0}) end
-- the Sun is beyond the upper left of the mouth: facets turned that way are lit
F({{-0.62,-0.5},{-0.2,-0.78},{-0.05,-0.4},{-0.42,-0.18}}, iceL, 0.6)
F({{-0.78,0.05},{-0.62,-0.5},{-0.42,-0.18},{-0.5,0.2}}, iceM, 1.4)
F({{-0.2,-0.78},{0.32,-0.72},{0.2,-0.38},{-0.05,-0.4}}, iceM, 0.3)
F({{-0.42,-0.18},{-0.05,-0.4},{0.2,-0.38},{0.1,0.05},{-0.25,0.12}}, iceM, 0.9)
F({{-0.5,0.2},{-0.25,0.12},{-0.1,0.45},{-0.48,0.62}}, iceL, 1.2)

--@ chunk 9
print(wait(3*24*60))
local cxm, cym, rm = MC[1], MC[2], MC[3]
local hot = pile{{"zinc white",4},{"lemon chrome",0.12}}
local gasP = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.15}}
local cab = pile{{"bone black",2},{"bone brown",1}}
local warm = pile{{"yellow ochre",1.3},{"raw sienna",0.7},{"lead white",0.6}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.6}}
-- thick cables from the throat's ribs to the ice
for _,c in ipairs({{{60,40},{cxm-rm*0.55,cym-rm*0.4}}, {{980,30},{cxm+rm*0.5,cym-rm*0.5}}, {{40,560},{cxm-rm*0.45,cym+rm*0.45}}, {{1000,520},{cxm+rm*0.6,cym+rm*0.4}}, {{560,563},{cxm+rm*0.05,cym+rm*0.78}}}) do
  local a, b = c[1], c[2]
  local mid = {lerp(a[1],b[1],0.5), lerp(a[2],b[2],0.5) + 12}
  ST({a, mid, b}, cab, 9, {1,0.5}); ST({{a[1]+3,a[2]-3},{mid[1]+3,mid[2]-3},{b[1]+2,b[2]-2}}, warm, 2.4, {0.7,0.2}, 0.9)
end
-- glittering hard points on the lit facets and one hard white edge along the ice's sun side
for k=1,40 do local x, y = cxm + rand(-0.75,0.1)*rm, cym + rand(-0.75,0.6)*rm; if ICE:at(x,y) > 0.5 then stipple(ellipse(x,y,1.3,1.3), {pile=hot, width=1.5, coverage=3}) end end
ST({{cxm-rm*0.78,cym+rm*0.05},{cxm-rm*0.62,cym-rm*0.5},{cxm-rm*0.2,cym-rm*0.78},{cxm+rm*0.32,cym-rm*0.72}}, hot, 3, {0.9,0.5})
-- long white gas trails, venting and streaming out into space past the mouth
for k=1,22 do
  local a = rand(-0.4, 1.4); local x0, y0 = cxm + math.cos(a)*rm*0.7, cym + math.sin(a)*rm*0.6
  local pts = {{x0,y0}}
  for j=1,4 do pts[#pts+1] = {x0 + j*rand(16,26), y0 - j*rand(2,9) + rand(-5,5)} end
  ST(pts, gasP, rand(2,4.5), {0.7,0.0}, 0.8, disc(ZM, 0.98))
end
-- the Sun's hard white edge: the mouth's rim lit on the side opposite the sun, as part of the rim
local pts = {}; for k=0,30 do local a = -0.9 + k/30*1.9; pts[#pts+1] = {cxm + math.cos(a)*rm*0.99, cym + math.sin(a)*rm*0.99} end
ST(pts, hot, 5, {0.3,0.3}, 1.0); ST(pts, hot, 3, {0.9,0.2}, 1.0)
local pts2 = {}; for k=0,20 do local a = -0.6 + k/20*1.4; pts2[#pts2+1] = {cxm + math.cos(a)*rm*1.03, cym + math.sin(a)*rm*1.03} end
ST(pts2, warmH, 4, {0.6,0.3}, 1.0)
-- glare: the Sun just past the upper-left rim
for k=1,16 do local a = rand(-0.6, 1.2); local L = rand(30,90)
  ST({{cxm - rm*0.8, cym - rm*0.62},{cxm - rm*0.8 + math.cos(a)*L, cym - rm*0.62 + math.sin(a)*L}}, hot, rand(1.4,2.6), {0.9,0.0}, 0.9, disc(ZM, 0.98)) end

--@ chunk 10
print(wait(2*24*60))
local cxm, cym, rm = MC[1], MC[2], MC[3]
local cabD = pile{{"bone black",2},{"bone brown",1}}
local warm = pile{{"yellow ochre",1.3},{"raw sienna",0.7},{"lead white",0.6}}
local iceM = pile{{"ultramarine ash",1.2},{"cerulean blue",0.5},{"lead white",1.3}}
local iceD = pile{{"ultramarine blue",1},{"bone black",0.6},{"ultramarine ash",1}}
local iceL = pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.4}}
local hot = pile{{"zinc white",4},{"lemon chrome",0.12}}
local gasP = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.15}}
-- cables as heavy braided ribbons, thick near us, thinner toward the ice
CABLES = {{{-20,60},{200,150},{cxm-rm*0.55,cym-rm*0.4}}, {{1020,40},{860,120},{cxm+rm*0.5,cym-rm*0.5}}, {{-20,540},{220,440},{cxm-rm*0.45,cym+rm*0.45}}, {{1020,500},{830,420},{cxm+rm*0.6,cym+rm*0.4}}}
for _,c in ipairs(CABLES) do
  local m = ribbon(c, {26,14,5})
  work(m, {hand="body", tool="filbert 3", pile=cabD, coverage=4, fill=true, clip=true, angle=math.atan(c[3][2]-c[1][2], c[3][1]-c[1][1]), length={10,30}, load=1.0})
  for k=0,24 do local t = k/24; local i = (t < 0.5) and 1 or 2; local u = (t < 0.5) and t*2 or (t-0.5)*2
    local p = {lerp(c[i][1],c[i+1][1],u), lerp(c[i][2],c[i+1][2],u)}; local w = lerp(26,5,t)
    ST({{p[1]-w*0.3,p[2]-w*0.35},{p[1]+w*0.3,p[2]+w*0.1}}, warm, math.max(1.2, w*0.15), {0.8,0.3}, 0.9, m) end
end
-- ice: rough faceting with strokes, crevasses, and frosted edges
for k=1,60 do local x, y = cxm + rand(-0.8,0.8)*rm, cym + rand(-0.8,0.8)*rm
  if ICE:at(x,y) > 0.5 then local a = rand(0,3.14); local L = rand(6,20)
    ST({{x,y},{x+math.cos(a)*L, y+math.sin(a)*L}}, (x < cxm - rm*0.1 and y < cym) and iceL or ((k%2==0) and iceM or iceD), rand(2,5), {0.8,0.2}, 0.9, ICE) end end
for k=1,8 do local x, y = cxm + rand(-0.5,0.6)*rm, cym + rand(-0.6,0.6)*rm
  ST({{x,y},{x+rand(-25,25), y+rand(10,30)},{x+rand(-30,30), y+rand(30,50)}}, iceD, 2.4, {0.9,0.2}, 1, ICE) end
-- long gas trails sweeping off the ice and across the mouth
for k=1,14 do
  local y0 = cym + rand(-0.5,0.6)*rm; local x0 = cxm + rand(0.2,0.7)*rm
  local pts = {{x0,y0}}; for j=1,6 do pts[#pts+1] = {x0 + j*rand(18,30), y0 - j*rand(-4,8)} end
  local b = brush{kind="filbert", width=rand(5,9), point=0.3}; b:load(gasP, 0.35)
  b:stroke(pts, {pressure={0.4,0.0}, ramps={0.05,0.8}, clip=disc(ZM,0.98)})
end

--@ chunk 11
print(wait(2*24*60))
local dk = pile{{"bone black",1.8},{"bone brown",1.2},{"burnt sienna",0.3}}
local brz = pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.4}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.6}}
local warm = pile{{"yellow ochre",1.3},{"raw sienna",0.7},{"lead white",0.6}}
-- the near frame sinks into lean dark at the corners, so the eye goes down the throat
local cx0, cy0, r0 = sec(0)
local corner = -(ellipse(cx0+60, cy0-40, 560, 380):soften(60))
work(corner, {hand="body", tool="filbert 10", pile=dk, coverage=2.6, fill=true, angle=0.3, length={30,90}, edge="soft", load=0.9})
-- the catwalk crossing the lower foreground on two struts
CAT = poly({{0,486},{700,458},{720,472},{0,508}})
work(CAT, {hand="body", tool="filbert 4", pile=dk, coverage=4, fill=true, clip=true, angle=-0.04, length={20,60}, load=1.0})
work(poly({{0,508},{720,472},{720,486},{0,526}}), {hand="body", tool="filbert 3", pile=brz, coverage=3.6, fill=true, clip=true, angle=-0.04, length={20,60}, load=1.0})
ST({{0,486},{700,458}}, warm, 2.6, {0.5,0.9})
for x=16,690,30 do local y = 486 - x*0.04; ST({{x,y},{x,y-24}}, dk, 2.4, {0.9,0.9}) end
ST({{0,460},{700,432}}, dk, 3, {0.9,0.9}); ST({{0,458},{700,430}}, warm, 1.4, {0.4,0.8})
ST({{180,516},{150,563}}, dk, 10, {1,1}); ST({{560,480},{600,563}}, dk, 10, {1,1})
-- the Commando, tiny, at the rail looking up the throat
local x0, y0 = 470, 467
local cmd = poly({{x0-6,y0},{x0-3,y0-14},{x0-5,y0-26},{x0-1,y0-34},{x0+5,y0-36},{x0+10,y0-33},{x0+11,y0-24},{x0+9,y0-14},{x0+12,y0},{x0+6,y0},{x0+3,y0-13},{x0-1,y0}})
work(cmd + ellipse(x0+3,y0-40,4.2,4.6), {hand="detail", pile=dk, coverage=4.5, fill=true})
work(poly({{x0-4,y0-24},{x0+10,y0-24},{x0+12,y0-12},{x0-3,y0-12}}), {hand="detail", pile=pile{{"red earth",1},{"vermilion",0.5},{"bone black",0.4}}, coverage=4, fill=true})
ST({{x0+1,y0-44},{x0-1,y0-38},{x0-4,y0-28},{x0-5,y0-16},{x0-5,y0}}, warmH, 1.4, {0.8,0.6})
ST({{x0+10,y0-28},{x0+24,y0-34}}, dk, 2.4, {0.9,0.9})

--@ chunk 12
local cxm, cym, rm = MC[1], MC[2], MC[3]
local hot = pile{{"zinc white",4},{"lemon chrome",0.12}}
local warmH = pile{{"lead white",2},{"Indian yellow",0.5},{"yellow ochre",0.6}}
-- sunlight striking the far rib's teeth on the right of the mouth: the rim's lit side, in strokes
for k=0,26 do local a = -1.0 + k/26*2.1
  local p0 = {cxm + math.cos(a)*rm*1.0, cym + math.sin(a)*rm*1.0}
  local p1 = {cxm + math.cos(a)*rm*1.16, cym + math.sin(a)*rm*1.16}
  ST({p0, p1}, (math.abs(a-0.05) < 0.6) and hot or warmH, 3.4, {0.9,0.2}, 1.0)
end
local pts = {}; for k=0,30 do local a = -0.95 + k/30*2.0; pts[#pts+1] = {cxm + math.cos(a)*rm*1.0, cym + math.sin(a)*rm*1.0} end
ST(pts, hot, 4, {0.9,0.6}, 1.0)
