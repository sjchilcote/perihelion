-- easel session "chapel": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={16,14}, seed=1137, ground={{pile={{"lead white",2},{"raw sienna",2},{"burnt sienna",1},{"ultramarine blue",1}}, um=90, apply="knife", texture=0.25}}}
local p = pile{{"burnt sienna",1}}
print(W,H)

--@ chunk 2
c = chalk()
-- floor/wall junction: the far wall's foot, an arc rising to the middle
c:sketch({{0,480},{150,400},{330,350},{500,334},{680,346},{850,385},{1000,450}}, {pressure=0.35})
-- dais rings (off-centre)
c:sketch({{455,392},{520,372},{610,370},{670,385},{640,402},{550,410},{470,404},{455,392}}, {pressure=0.3})
-- beam from the oculus
c:sketch({{690,40},{760,70},{735,105},{675,90},{690,40}}, {pressure=0.35})
c:line({{690,95},{380,520}}, {pressure=0.25})
c:line({{745,100},{520,560}}, {pressure=0.25})
-- ribs
for _,x in ipairs({40,150,265,360,440,575,650,760,880,965}) do
  local base = 480 - 146*(1-((x-500)/500)^2)
  c:line({{x,base},{x+(500-x)*0.18,base-200},{x+(500-x)*0.45, 0}}, {pressure=0.2})
end
-- pews, rows converging
for i,y in ipairs({470,505,550,605,665}) do
  local s = (y-300)/370
  c:rule({500-430*s-20, y}, {500-60*s, y-4}, {pressure=0.3})
  c:rule({500+60*s, y-3}, {500+430*s+30, y+2}, {pressure=0.3})
end
-- the kneeling figure
c:sketch({{418,470},{420,440},{432,428},{445,440},{448,470}}, {pressure=0.4})
-- lamp
c:sketch({{240,330},{262,330},{262,350},{240,350}}, {pressure=0.3})
c:line({{251,350},{235,430}}, {pressure=0.2}); c:line({{251,350},{268,430}}, {pressure=0.2})

--@ chunk 3
footc = {{0,480},{150,400},{330,350},{500,334},{680,346},{850,385},{1000,450}}
wallm = above(footc)
floorm = below(footc)
dome_dark = pile{{"ultramarine blue",2},{"burnt sienna",3},{"bone black",0.5}, medium=0.15}
dome_mid  = pile{{"burnt sienna",2},{"ultramarine blue",1},{"yellow ochre",1},{"lead white",0.4}, medium=0.1}
-- the dome: darkest at the top, a little warmer and lighter toward the wall's foot
work(wallm * above(function(x) return 180 end), {hand="broad", pile=dome_dark, coverage=2.6, fill=true, angle=function(x,y) return math.pi/2 + (500-x)/900 end})
work(wallm * below(function(x) return 150 end), {hand="broad", pile=dome_mid, coverage=2.4, fill=true, angle=function(x,y) return math.pi/2 + (500-x)/900 end})

--@ chunk 4
floor_dark = pile{{"burnt sienna",3},{"ultramarine blue",2},{"raw sienna",1},{"bone black",0.3}, medium=0.1}
work(floorm, {hand="broad", pile=floor_dark, coverage=2.8, fill=true, angle=function(x,y) return math.atan(y-300, x-480) * 0.15 end, clip=true, length={60,160}})

--@ chunk 5
wall_sh = pile{{"burnt sienna",3},{"ultramarine blue",1.5},{"raw sienna",1.5},{"yellow ochre",0.5}, medium=0.1}
ribang = function(x,y) return math.pi/2 + (500-x)/700 end
work(wallm * below(function(x) return 90 end), {hand="body", pile=wall_sh, coverage=2.5, fill=true, angle=ribang, clip=true, length={40,110}})
dome_top = pile{{"ultramarine blue",1.5},{"burnt sienna",3},{"Mars brown",1}, medium=0.1}

--@ chunk 6
print(wait(8*60))
bronze_sh = pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.8}, medium=0.1}
brown_dk = pile{{"burnt sienna",2},{"viridian",1},{"bone black",0.4}, medium=0.1}
work(wallm * below(function(x) return 100 end), {hand="body", pile=bronze_sh, coverage=3.5, fill=true, angle=ribang, clip=true, length={40,110}})
work(above(function(x) return 130 end), {hand="body", pile=brown_dk, coverage=3.5, fill=true, angle=ribang, clip=true, length={40,110}})

--@ chunk 7
function foot(x) local t=(x-500)/500; return 334 + 146*t*t end
function ribpath(x)
  local pts = {}
  for i=0,12 do
    local t = i/12
    local fx = x + (500-x)*(0.62*t*t + 0.08*t)
    local fy = foot(x) - (foot(x)+30)*t
    pts[#pts+1] = {fx, fy}
  end
  return pts
end
bronze_mid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}, medium=0.05}
bronze_lit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
ribs = {}
local x = 18; local gaps = {118, 96, 132, 84, 104, 140, 92, 122, 100, 112}
for i,g in ipairs(gaps) do ribs[#ribs+1] = x; x = x + g end
for i,rx in ipairs(ribs) do
  local w = 14 + 10*(1-math.abs(rx-500)/500) + (i%3)*3
  local pts = ribpath(rx)
  local ws = {}
  for j=1,#pts do ws[j] = w*(1 - 0.55*(j-1)/(#pts-1)) end
  local m = ribbon(pts, ws)
  work(m, {hand="body", pile=bronze_mid, coverage=3, fill=true, angle=ribang, clip=true, length={30,80}})
end

--@ chunk 8
print(wait(24*60))
dark_glaze = pile{{"bone black",1},{"ultramarine blue",1},{"burnt sienna",1.5}, medium=0.6}
-- darkness gathering upward and to the sides, away from the beam's reach
local vig = mask(function(x,y)
  local dx = (x-470)/520; local dy = (y-420)/420
  return clamp((dx*dx + dy*dy*1.4 - 0.25)*1.6, 0, 1) end)
work(vig, {hand="glaze", pile=dark_glaze, coverage=1.6, fill=true, angle=ribang})

--@ chunk 9
blend(everywhere(), {angle=0.3})
blend(everywhere(), {angle=1.9})

--@ chunk 10
print(wait(3*24*60))
print(drying(500,300), drying(500,500), drying(100,100))
-- the oculus: a nested, rotated polygon window high in the dome
oc = {cx=700, cy=78}
function npoly(cx, cy, r, n, rot, squash)
  local pts = {}
  for i=0,n-1 do local a = rot + i*2*math.pi/n
    pts[#pts+1] = {cx + r*math.cos(a), cy + r*math.sin(a)*squash} end
  return poly(pts)
end
sky_light = pile{{"lead white",4},{"lemon chrome",0.6}}
light_warm = pile{{"lead white",3},{"cadmium yellow",1},{"Mars orange",0.15}}
oc_outer = npoly(oc.cx, oc.cy, 52, 7, 0.2, 0.62)
work(oc_outer, {hand="body", pile=light_warm, coverage=4, fill=true, clip=true})
work(npoly(oc.cx+4, oc.cy+1, 34, 7, 0.2+0.45, 0.62), {hand="body", pile=sky_light, coverage=5, fill=true, clip=true})

--@ chunk 11
work(npoly(oc.cx+5, oc.cy+1, 19, 7, 0.2+0.9, 0.62), {hand="detail", pile=pile{{"lead white",1}}, coverage=4, fill=true, clip=true})
beam = poly({{662,100},{748,92},{575,560},{330,535}})
beam_veil = pile{{"lead white",3},{"cadmium yellow",0.6},{"yellow ochre",0.3}, medium=0.75}
work(beam, {hand="glaze", pile=beam_veil, coverage=1.4, fill=true, clip=true, angle=math.atan(560-100, 450-705)})
blend(beam, {angle=math.atan(560-100, 450-705)})

--@ chunk 12
local bang = math.atan(560-100, 450-705)
blend(beam:grow(30), {angle=bang + math.pi/2, clip=false})
blend(beam:grow(20), {angle=bang})

--@ chunk 13
print(wait(4*24*60))
print(drying(500,300), drying(600,250))
beam2 = poly({{666,100},{742,94},{560,548},{352,530}})
local hole = beam2:grow(2)
dome_deep = pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.6},{"yellow ochre",0.3}, medium=0.05}
work((above(function(x) return 200 end)) - hole - oc_outer:grow(3), {hand="body", pile=dome_deep, coverage=3.5, fill=true, angle=ribang, clip=true, length={30,90}})
work((wallm * below(function(x) return 200 end)) - hole, {hand="body", pile=bronze_sh, coverage=3.5, fill=true, angle=ribang, clip=true, length={30,90}})
work(floorm - hole, {hand="body", pile=pile{{"bone black",2},{"burnt sienna",2},{"ultramarine blue",0.5}}, coverage=3.5, fill=true, angle=0.05, clip=true, length={40,120}})

--@ chunk 14
local band = (mask(function(x,y) return 1 - clamp(math.abs(y-200)/70, 0, 1) end)) - beam2:grow(6)
blend(band, {angle=math.pi/2})
blend(band, {angle=math.pi/2 + 0.25})

--@ chunk 15
print(wait(3*24*60))
print(drying(560,300))
local bang = math.atan(560-100, 450-705)
local g = pile{{"burnt sienna",1},{"ultramarine blue",0.6},{"raw sienna",0.6}, medium=0.85}
-- heavier toward the floor, where the shaft thins in the air
local fade = beam2 * mask(function(x,y) return clamp((y-140)/420, 0, 1)^0.8 end)
work(fade, {hand="glaze", pile=g, coverage=1.5, fill=true, clip=true, angle=bang})
blend(beam2:shrink(3), {angle=bang})

--@ chunk 16
print(wait(2*24*60))
local b = beam2:grow(4)
work(b * above(function(x) return 200 end), {hand="body", pile=dome_deep, coverage=3.5, fill=true, angle=ribang, clip=true, length={20,60}})
work(b * wallm * below(function(x) return 200 end), {hand="body", pile=bronze_sh, coverage=3.5, fill=true, angle=ribang, clip=true, length={20,60}})
work(b * floorm, {hand="body", pile=pile{{"bone black",2},{"burnt sienna",2},{"ultramarine blue",0.5}}, coverage=3.5, fill=true, angle=0.05, clip=true, length={20,60}})

--@ chunk 17
bone_dim = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.35}}
rb = brush{kind="round", width=2.2, point=0.7, stiffness=0.5}
function ring(cx, cy, rx, ry, tilt, p, press)
  local pts = {}
  for i=0,72 do local a = i/72*2*math.pi
    local x = rx*math.cos(a); local y = ry*math.sin(a)
    pts[#pts+1] = {cx + x*math.cos(tilt) - y*math.sin(tilt), cy + x*math.sin(tilt) + y*math.cos(tilt)} end
  return pts
end
local radii = {46, 74, 120, 194, 314, 508}
for i,r in ipairs(radii) do
  local pts = ring(560 + i*7 - 20, 398 + i*9, r, r*0.17 + i*1.5, 0.015*i - 0.03)
  -- lay it in arcs, as a hand would, a fresh load for each
  local n = #pts; local seg = 12
  for s=1,n-1,seg do
    local part = {}
    for k=s, math.min(s+seg+1, n) do part[#part+1] = pts[k] end
    rb:reload(bone_dim, 0.7)
    rb:stroke(part, {pressure={0.55,0.5}, ramps={0.1,0.1}, clip=floorm})
  end
end

--@ chunk 18
pew_gray = pile{{"zinc white",1},{"bone black",1.2},{"ultramarine ash",0.8}}
pew_dark = pile{{"bone black",2},{"ultramarine blue",0.5},{"zinc white",0.4}}
pews = {}
local rows = {{y=452, sk=-3}, {y=488, sk=2}, {y=532, sk=-5}, {y=588, sk=4}, {y=656, sk=-2}}
for i,r in ipairs(rows) do
  local s = (r.y-300)/370
  local h = 64*s
  for side=-1,1,2 do
    local xa, xb
    if side < 0 then xa = 500-430*s-25; xb = 500-48*s
    else xa = 500+48*s; xb = 500+430*s+35 end
    local tilt = r.sk * (side) * 0.6   -- dragged in, not quite square
    local y0 = r.y
    local p = poly({{xa, y0-h + tilt}, {xb, y0-h - tilt}, {xb, y0 - tilt}, {xa, y0 + tilt}})
    pews[#pews+1] = {mask=p, xa=xa, xb=xb, top={{xa,y0-h+tilt},{xb,y0-h-tilt}}, y=y0, h=h, tilt=tilt}
  end
end
-- far rows first
for i=1,#pews do
  local pw = pews[i]
  work(pw.mask, {hand="body", pile=pew_dark, coverage=3.5, fill=true, angle=0, clip=true, length={20,70}})
end

--@ chunk 19
print(wait(2*24*60))
local g = pile{{"bone black",1},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.7}
for i=1,#pews do
  local pw = pews[i]
  -- darker toward the bottom of each back (its own shadow), lighter at the top
  work(pw.mask, {hand="glaze", pile=g, coverage=1.6, fill=true, clip=true, angle=0})
end

--@ chunk 20
pewmask = pews[1].mask
for i=2,#pews do pewmask = pewmask + pews[i].mask end
pool_c = {465, 432}
pool = ellipse(pool_c[1], pool_c[2], 120, 24):soften(10)
pool_core = ellipse(pool_c[1]+8, pool_c[2]-2, 70, 13):soften(6)
floor_lit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1.2},{"cadmium yellow",0.3}}
floor_hot = pile{{"lead white",3},{"cadmium yellow",1},{"yellow ochre",0.5}}
work((pool - pewmask) * floorm, {hand="body", pile=floor_lit, coverage=3.5, fill=true, angle=0.02, clip=true, length={15,50}})
work((pool_core - pewmask) * floorm, {hand="body", pile=floor_hot, coverage=3.5, fill=true, angle=0.02, clip=true, length={10,35}})
blend((pool:grow(14) - pewmask) * floorm, {angle=0.02})

--@ chunk 21
print(wait(2*24*60))
shaft = poly({{664,98},{744,92},{580,430},{352,438}})
local bang = math.atan(435-95, 466-704)
veil = pile{{"lead white",3},{"cadmium yellow",1},{"yellow ochre",0.6}, medium=0.9}
work(shaft, {hand="glaze", pile=veil, coverage=1.0, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
-- a second, denser veil near the oculus
work(shaft * above(function(x) return 260 end), {hand="glaze", pile=veil, coverage=0.8, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
blend(shaft, {angle=bang})

--@ chunk 22
fig = body_of{spine={{468,424},{467,414},{468,405},{470,399},{473,395}}, widths={10,12,13,6,7},
  limbs={ {{468,422},{476,428},{478,435}, widths={6,5,4}},
          {{466,424},{458,431},{447,434}, widths={6,5,3}},
          {{470,404},{476,407},{479,402}, widths={4,3.5,3}} }, blend=0.8, char="firm"}
figm = fig:mask()
frame_dk = pile{{"bone black",2},{"ultramarine blue",0.6},{"zinc white",0.5}}
work(figm, {hand="detail", pile=frame_dk, coverage=5, fill=true, clip=true})

--@ chunk 23
print(wait(2*24*60))
local area = figm:grow(4)
work(area * floorm - pewmask, {hand="detail", pile=floor_lit, coverage=5, fill=true, clip=true})
work(area * pool_core:grow(4) - pewmask, {hand="detail", pile=floor_hot, coverage=4, fill=true, clip=true})
work(area - floorm, {hand="detail", pile=bronze_sh, coverage=5, fill=true, clip=true})

--@ chunk 24
print(wait(24*60))
-- seen from behind, kneeling, head bowed between the shoulders
torso = poly({{452,402},{456,397},{463,395},{477,395},{484,397},{488,402},{487,410},{482,419},{480,428},{460,428},{458,419},{453,410}}, true)
head = ellipse(470, 391, 6.5, 7.5)
heels = poly({{455,427},{466,427},{466,433},{450,435}}, true) + poly({{474,427},{485,427},{491,435},{475,433}}, true)
frame_m = torso + head + heels
work(frame_m, {hand="detail", pile=frame_dk, coverage=6, fill=true, clip=true})

--@ chunk 25
print(wait(24*60))
frame_op = pile{{"bone black",2},{"lead white",0.35},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
work(frame_m, {hand="detail", pile=frame_op, coverage=6, fill=true, clip=true})
print(wait(24*60))
work(frame_m, {hand="detail", pile=frame_op, coverage=5, fill=true, clip=true})

--@ chunk 26
print(wait(24*60))
rim = pile{{"lead white",3},{"cadmium yellow",0.8},{"Mars orange",0.1}}
rr = brush{kind="round", width=1.6, point=0.8, stiffness=0.5}
rr:load(rim, 0.8)
rr:stroke({{464.5,388},{467,384.6},{471,383.8},{474.5,385.5},{476,388}}, {pressure={0.45,0.2}, ramps={0.2,0.4}})
rr:load(rim, 0.7)
rr:stroke({{477,396},{482,396.5},{486.5,399.5},{488,403}}, {pressure={0.5,0.15}, ramps={0.15,0.5}})
rr:load(rim, 0.5)
rr:stroke({{463,396},{458,396.8},{454,399.5}}, {pressure={0.3,0.1}, ramps={0.2,0.5}})
-- a faint shadow thrown toward us across the lit floor
sh = poly({{458,430},{484,430},{492,446},{454,447}}, true)
work(sh * floorm - pewmask, {hand="detail", pile=pile{{"burnt sienna",1},{"ultramarine blue",0.6},{"bone black",0.3}, medium=0.6}, coverage=2, fill=true, clip=true})

--@ chunk 27
rr = brush{kind="round", width=3, point=0.5, stiffness=0.5}
rr:load(rim, 1)
rr:stroke({{464.5,388.5},{467,385.2},{471,384.4},{474.5,386},{476,389}}, {pressure={0.75,0.5}, ramps={0.15,0.3}})
rr:load(rim, 1)
rr:stroke({{477,396.5},{482,397},{486,399.8},{487.5,403}}, {pressure={0.8,0.4}, ramps={0.1,0.4}})
rr:load(rim, 0.8)
rr:stroke({{463,396.5},{458,397.2},{454.5,400}}, {pressure={0.6,0.3}, ramps={0.2,0.5}})

--@ chunk 28
print(wait(6*24*60))
print(drying(470,392), drying(470,410))
rr:load(rim, 1)
rr:stroke({{464.8,388.5},{467,385.4},{471,384.6},{474.5,386.2},{475.8,389}}, {pressure={0.75,0.5}, ramps={0.15,0.3}})
rr:load(rim, 1)
rr:stroke({{477,396.7},{482,397.2},{486,400},{487.3,403}}, {pressure={0.8,0.4}, ramps={0.1,0.4}})
rr:load(rim, 0.8)
rr:stroke({{463,396.7},{458,397.4},{454.7,400.2}}, {pressure={0.6,0.3}, ramps={0.2,0.5}})

--@ chunk 29
function ribpath2(x)
  local pts = {}
  for i=0,10 do local t = i/10
    local y = foot(x) - (foot(x)+10)*t
    local fx = x + (500-x)*(0.55*t*t*t + 0.12*t)
    pts[#pts+1] = {fx, y} end
  return pts
end
rib_x = {58, 168, 264, 338, 404, 472, 548, 622, 706, 804, 918}
rib_w = {30, 26, 21, 17, 15, 14, 15, 17, 21, 26, 31}
ribms = {}
for i,x in ipairs(rib_x) do
  local pts = ribpath2(x)
  local ws = {}
  for j=1,#pts do ws[j] = rib_w[i]*(1 - 0.6*(j-1)/(#pts-1)) end
  ribms[i] = ribbon(pts, ws) * wallm
  work(ribms[i] - shaft:grow(2), {hand="body", pile=bronze_mid, coverage=3.5, fill=true, angle=ribang, clip=true, length={30,80}})
end

--@ chunk 30
print(wait(4*24*60))
local dg = pile{{"bone black",1},{"burnt sienna",1.2},{"ultramarine blue",0.5}, medium=0.75}
-- darkness by distance from the pool of light: two thin coats, the second only far away
local function far(k) return mask(function(x,y)
  local dx=(x-470)/560; local dy=(y-430)/430
  return clamp((math.sqrt(dx*dx+dy*dy) - k)*2.2, 0, 1) end) end
work(far(0.25) * wallm - shaft:grow(3) - oc_outer:grow(6), {hand="glaze", pile=dg, coverage=1.4, fill=true, clip=true, angle=ribang, length={60,140}})
work(far(0.6) * wallm - shaft:grow(3) - oc_outer:grow(6), {hand="glaze", pile=dg, coverage=1.4, fill=true, clip=true, angle=ribang, length={60,140}})
blend(wallm - shaft:grow(5) - oc_outer:grow(8), {angle=ribang})

--@ chunk 31
print(wait(3*24*60))
work(npoly(oc.cx, oc.cy, 54, 7, 0.2, 0.62), {hand="detail", pile=pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+1, oc.cy, 46, 7, 0.2+0.35, 0.62), {hand="detail", pile=light_warm, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+3, oc.cy+1, 33, 7, 0.2+0.8, 0.62), {hand="detail", pile=sky_light, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+5, oc.cy+1, 20, 7, 0.2+1.3, 0.62), {hand="detail", pile=pile{{"lead white",1}}, coverage=5, fill=true, clip=true})

--@ chunk 32
print(wait(2*24*60))
local bang = math.atan(435-95, 466-704)
-- warm the veil: a transparent yellow glaze
local wg = pile{{"Indian yellow",1},{"raw sienna",0.3}, medium=0.85}
work(shaft:grow(3), {hand="glaze", pile=wg, coverage=1.2, fill=true, clip=true, angle=bang})
-- the halo the oculus throws on the dome around it
local halo = ellipse(oc.cx, oc.cy+5, 120, 85):blur(40) - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62)
local hp = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}, medium=0.85}
work(halo, {hand="glaze", pile=hp, coverage=1.0, fill=true, clip=true, load=0.3, pressure={0.1,0.25}})
blend(halo, {angle=0.4})
-- lose the shaft's hard edges into the air
lose(shaft, {pile=veil, where=0.9, reach={10, 6}, load=0.15, tool="filbert 4"})

--@ chunk 33
local halo2 = ellipse(oc.cx, oc.cy+5, 150, 100) - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62)
blend(halo2, {angle=0.4})
blend(halo2, {angle=2.0})
local bang = math.atan(435-95, 466-704)
blend(shaft:grow(10) - frame_m:grow(2), {angle=bang})

--@ chunk 34
print(wait(5*24*60))
local bang = math.atan(435-95, 466-704)
local vg = pile{{"cobalt violet",1},{"rose madder",0.4},{"ultramarine blue",0.3}, medium=0.85}
work(shaft:grow(12) - frame_m:grow(1), {hand="glaze", pile=vg, coverage=1.0, fill=true, clip=true, angle=bang})
-- dissolve the halo's rim: dark glaze strongest at the rim, nothing at the oculus
local dg = pile{{"bone black",1},{"burnt sienna",1.2},{"ultramarine blue",0.5}, medium=0.75}
local rimm = mask(function(x,y)
  local dx=(x-oc.cx)/150; local dy=(y-oc.cy-5)/100; local r = math.sqrt(dx*dx+dy*dy)
  return clamp((r-0.45)/0.6, 0, 1) * clamp((1.6-r)/0.3, 0, 1) end) - shaft:grow(4)
work(rimm, {hand="glaze", pile=dg, coverage=1.5, fill=true, clip=true, angle=0.5})
blend(rimm:grow(10) - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62) - shaft, {angle=0.5})

--@ chunk 35
print(wait(5*24*60))
local b = shaft:grow(14) - frame_m - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62)
local poolzone = pool:grow(6) * floorm - pewmask
work(b * above(function(x) return 200 end), {hand="body", pile=dome_deep, coverage=4, fill=true, angle=ribang, clip=true, length={20,60}})
work(b * wallm * below(function(x) return 200 end), {hand="body", pile=bronze_sh, coverage=4, fill=true, angle=ribang, clip=true, length={20,60}})
for i,rm in ipairs(ribms) do
  work(b * rm, {hand="body", pile=bronze_mid, coverage=4, fill=true, angle=ribang, clip=true, length={20,60}})
end
work(b * floorm - poolzone - pewmask, {hand="body", pile=pile{{"bone black",2},{"burnt sienna",2},{"ultramarine blue",0.5}}, coverage=4, fill=true, angle=0.05, clip=true, length={20,60}})
work(poolzone - frame_m, {hand="body", pile=floor_lit, coverage=4, fill=true, angle=0.02, clip=true, length={10,40}})
work(pool_core * floorm - pewmask - frame_m, {hand="body", pile=floor_hot, coverage=4, fill=true, angle=0.02, clip=true, length={10,30}})

--@ chunk 36
print(wait(4*24*60))
local dg = pile{{"bone black",1},{"burnt sienna",1.2},{"ultramarine blue",0.5}, medium=0.75}
local b = shaft:grow(14) - frame_m:grow(2) - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62)
work(b * wallm, {hand="glaze", pile=dg, coverage=1.6, fill=true, clip=true, angle=ribang})
-- the oculus again
work(npoly(oc.cx, oc.cy, 54, 7, 0.2, 0.62), {hand="detail", pile=pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+1, oc.cy, 46, 7, 0.2+0.35, 0.62), {hand="detail", pile=light_warm, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+3, oc.cy+1, 33, 7, 0.2+0.8, 0.62), {hand="detail", pile=sky_light, coverage=5, fill=true, clip=true})
work(npoly(oc.cx+5, oc.cy+1, 20, 7, 0.2+1.3, 0.62), {hand="detail", pile=pile{{"lead white",1}}, coverage=5, fill=true, clip=true})
-- the figure, and the front pews' backs
work(frame_m, {hand="detail", pile=frame_op, coverage=6, fill=true, clip=true})
for i=1,2 do work(pews[i].mask, {hand="body", pile=pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.25}}, coverage=4, fill=true, angle=0, clip=true, length={20,60}}) end

--@ chunk 37
print(wait(3*24*60))
local bang = math.atan(435-95, 466-704)
local s = shaft - frame_m:grow(1)
work(s, {hand="glaze", pile=veil, coverage=1.0, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
work(s * above(function(x) return 250 end), {hand="glaze", pile=veil, coverage=0.7, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
blend(s, {angle=bang})
print(wait(4*24*60))
work(s, {hand="glaze", pile=pile{{"Mars orange",1},{"lead white",0.5}, medium=0.9}, coverage=0.8, fill=true, clip=true, angle=bang, load=0.3, pressure={0.1,0.3}})

--@ chunk 38
print(wait(3*24*60))
local bang = math.atan(435-95, 466-704)
local band = (shaft:grow(20) - shaft:shrink(2)) - frame_m:grow(2) - pewmask - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62)
local thin = pile{{"lead white",2},{"yellow ochre",1},{"burnt sienna",0.5},{"Mars orange",0.3}, medium=0.9}
work(band, {hand="glaze", pile=thin, coverage=0.8, fill=true, clip=true, angle=bang, load=0.2, pressure={0.08,0.2}})
blend(shaft:grow(26) - frame_m:grow(2) - pewmask - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62), {angle=bang + math.pi/2})
blend(shaft:grow(26) - frame_m:grow(2) - pewmask - npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62), {angle=bang})

--@ chunk 39
print(wait(3*24*60))
local fg = pile{{"burnt sienna",1.2},{"bone black",1},{"raw sienna",0.5}, medium=0.75}
local away = mask(function(x,y) local dx=(x-465)/330; local dy=(y-432)/90
  return clamp((math.sqrt(dx*dx+dy*dy)-0.55)*1.5, 0, 1) end)
work(away * floorm - pewmask, {hand="glaze", pile=fg, coverage=1.6, fill=true, clip=true, angle=0.03})
work(pewmask, {hand="glaze", pile=pile{{"burnt sienna",1},{"bone black",1}, medium=0.75}, coverage=1.4, fill=true, clip=true, angle=0})

--@ chunk 40
print(wait(3*24*60))
-- a small cross on the dais, two scraps of gray outpost metal lashed together, catching the sun
local cr = rect(556, 362, 4, 30) + rect(549, 369, 18, 3.6)
work(cr, {hand="detail", pile=frame_op, coverage=6, fill=true, clip=true})
-- the dead work lamp: tripod legs, a boxy head, hazard stripe
lampb = brush{kind="round", width=2.4, point=0.3, stiffness=0.6}
local lg = pile{{"zinc white",1},{"bone black",1.6},{"ultramarine ash",0.6}}
for _,leg in ipairs({{{238,338},{222,402}}, {{240,338},{246,404}}, {{239,338},{258,398}}}) do
  lampb:reload(lg, 0.8); lampb:stroke(leg, {pressure={0.7,0.6}, ramps={0.05,0.1}})
end
local head = poly({{224,318},{254,316},{256,340},{226,342}})
work(head, {hand="detail", pile=lg, coverage=6, fill=true, clip=true})
work(poly({{224,336},{256,334},{256,340},{226,342}}), {hand="detail", pile=pile{{"cadmium yellow",1},{"Mars orange",0.6},{"bone black",0.15}}, coverage=6, fill=true, clip=true})

--@ chunk 41
print(wait(3*24*60))
local lampzone = rect(212, 310, 54, 100)
work(lampzone, {hand="glaze", pile=pile{{"bone black",1},{"burnt sienna",1}, medium=0.7}, coverage=1.5, fill=true, clip=true, angle=1.5})
-- the pews' top edges catch the light that comes from beyond them
local pr = brush{kind="round", width=1.8, point=0.4, stiffness=0.5}
local edge = pile{{"yellow ochre",2},{"lead white",1.5},{"burnt sienna",0.4}}
for i,pw in ipairs(pews) do
  local cx = 465
  local near = math.max(0, 1 - (pw.y-452)/260)
  -- brighter toward the aisle, where the pool is
  local a, b = pw.top[1], pw.top[2]
  local pts = {}
  for k=0,10 do local t=k/10; pts[#pts+1] = {a[1]+(b[1]-a[1])*t, a[2]+(b[2]-a[2])*t + 0.6} end
  pr:reload(edge, 0.25 + 0.6*near)
  local closer = (math.abs(a[1]-cx) < math.abs(b[1]-cx))
  if closer then
    pr:stroke(pts, {pressure={0.65*near+0.2, 0.15}, ramps={0.05,0.6}})
  else
    local rev = {}; for k=#pts,1,-1 do rev[#rev+1]=pts[k] end
    pr:stroke(rev, {pressure={0.65*near+0.2, 0.15}, ramps={0.05,0.6}})
  end
end

--@ chunk 42
print(wait(3*24*60))
local lampzone = rect(210, 306, 58, 106)
work(lampzone * wallm, {hand="detail", pile=dome_deep, coverage=6, fill=true, clip=true})
work(lampzone * floorm, {hand="detail", pile=pile{{"bone black",1.5},{"burnt sienna",1.5},{"raw sienna",0.8}}, coverage=6, fill=true, clip=true})
local lg2 = pile{{"bone black",2},{"zinc white",0.5},{"ultramarine ash",0.5}}
for _,leg in ipairs({{{238,338},{222,402}}, {{240,338},{246,404}}, {{239,338},{258,398}}}) do
  lampb:reload(lg2, 0.8); lampb:stroke(leg, {pressure={0.6,0.5}, ramps={0.05,0.1}})
end
work(poly({{224,318},{254,316},{256,340},{226,342}}), {hand="detail", pile=lg2, coverage=6, fill=true, clip=true})
work(poly({{224,336},{256,334},{256,340},{226,342}}), {hand="detail", pile=pile{{"Mars orange",1},{"yellow ochre",0.5},{"bone black",0.6}}, coverage=6, fill=true, clip=true})
-- the near floor, darker toward us: broken opaque dark between the pews
local nearfloor = floorm * mask(function(x,y) return clamp((y-470)/150, 0, 1) end) - pewmask
work(nearfloor, {hand="body", pile=pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.4}}, coverage=2.5, fill=true, clip=true, angle=0.03, length={30,90}})

--@ chunk 43
local seam = floorm * mask(function(x,y) return 1 - clamp(math.abs(y-478)/40, 0, 1) end) - pewmask
blend(seam, {angle=math.pi/2})
blend(seam, {angle=math.pi/2+0.4})
local box = (rect(200, 296, 78, 126) - rect(214, 310, 50, 98))
blend(box, {angle=0.2})
blend(box, {angle=1.7})

--@ chunk 44
print(wait(3*24*60))
local g_hi = pile{{"bone black",1.6},{"lead white",0.7},{"ultramarine ash",0.6},{"burnt sienna",0.25}}
local g_lo = pile{{"bone black",2},{"lead white",0.25},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
for i,pw in ipairs(pews) do
  local upper = pw.mask * mask(function(x,y) return clamp(((pw.y - y)/pw.h - 0.45)*4, 0, 1) end)
  work(pw.mask, {hand="body", pile=g_lo, coverage=4, fill=true, angle=0, clip=true, length={20,70}})
  work(upper, {hand="body", pile=g_hi, coverage=3, fill=true, angle=0, clip=true, length={20,70}, threshold=0.5})
  blend(pw.mask, {angle=math.pi/2})
end

--@ chunk 45
print(wait(4*24*60))
local void = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local legp = pile{{"bone black",1.6},{"lead white",0.4},{"ultramarine ash",0.5}}
local lb = brush{kind="flat", width=2.2, stiffness=0.6}
for i,pw in ipairs(pews) do
  local s = (pw.y-300)/370
  local cut = pw.y - pw.h*0.42
  local lower = pw.mask * below(function(x) return cut end)
  work(lower, {hand="detail", pile=void, coverage=6, fill=true, clip=true})
  -- legs: modular, evenly spaced (MIRIAD) - every leg the same
  local n = math.floor((pw.xb-pw.xa)/ (90*s)) + 1
  for k=0,n do
    local x = pw.xa + 6*s + k*((pw.xb-pw.xa-12*s)/math.max(n,1))
    lb:reload(legp, 0.7)
    lb:stroke({{x, cut+1}, {x, pw.y+1}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
  end
end
-- the backs: a dark glaze, more at the bottom of each
for i,pw in ipairs(pews) do
  work(pw.mask * above(function(x) return pw.y - pw.h*0.42 end), {hand="glaze", pile=pile{{"bone black",1},{"burnt sienna",0.8}, medium=0.7}, coverage=1.2, fill=true, clip=true, angle=0})
end

--@ chunk 46
print(wait(2*24*60))
local fd = pile{{"bone black",2},{"burnt sienna",1.6},{"raw sienna",0.4},{"ultramarine blue",0.3}}
local cov = function(x,y) local dx=(x-470)/420; local dy=(y-430)/110
  return clamp((math.sqrt(dx*dx+dy*dy)-0.55)*3.0, 0, 3.5) end
stipple(floorm - pewmask - frame_m:grow(4), {pile=fd, width=7, coverage=cov, feather=0.6, pressure={0.4,0.7}})

--@ chunk 47
print(wait(2*24*60))
local gb = brush{kind="round", width=1.3, point=0.8, stiffness=0.5}
local bone_l = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.4}}
local bone_d = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.3}}
local function glyph(cx, cy, r, n, rot, depth, p, ld)
  for d=0,depth-1 do
    local rr = r * (0.618^d)
    local a0 = rot + d*2.399   -- each nested copy turned by the golden angle
    local pts = {}
    for i=0,n do local a = a0 + i*2*math.pi/n
      pts[#pts+1] = {cx + rr*math.cos(a), cy + rr*math.sin(a)*0.9} end
    gb:reload(p, ld)
    gb:stroke(pts, {pressure={0.5,0.45}, ramps={0.05,0.05}})
  end
end
-- a frieze of glyphs along the lower wall, each one different, spaced by golden gaps
local x = 150
local k = 0
while x < 860 do
  k = k + 1
  local y = foot(x) - 26 - 8*math.sin(k*1.7)
  local inshaft = shaft:grow(4):at(x, y) > 0.2
  local d = math.abs(x-470)
  if not inshaft and (ribms[1]:at(x,y) < 0.5) then
    local lit = d < 220
    glyph(x, y, 6 + (k*7)%5, 3 + (k*5)%7, k*0.9, 2 + k%2, lit and bone_l or bone_d, lit and 0.55 or 0.3)
  end
  x = x + 14 + ((k*0.618)%1)*16
end

--@ chunk 48
print(wait(3*24*60))
local band = wallm * mask(function(x,y) local f = foot(x); return 1 - clamp(math.abs(y-(f-28))/22, 0, 1) end) - shaft:grow(2)
work(band, {hand="glaze", pile=pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.5}, medium=0.8}, coverage=1.2, fill=true, clip=true, angle=0})
-- the hottest light: where the shaft lands at the kneeling figure's knees
local hot = ellipse(452, 432, 34, 6):soften(4) - frame_m - pewmask
work(hot, {hand="detail", pile=pile{{"lead white",3},{"cadmium yellow",0.8}}, coverage=4, fill=true, clip=true})
-- the cross's sunward edge
local cb = brush{kind="round", width=1.2, point=0.6}
cb:load(rim, 0.9); cb:stroke({{560.5,363},{560.5,391}}, {pressure={0.6,0.4}, ramps={0.1,0.2}})
cb:load(rim, 0.8); cb:stroke({{550,369.2},{566,369.2}}, {pressure={0.5,0.4}, ramps={0.1,0.2}})
-- the oculus core, laid thick
local ob = brush{kind="filbert", width=9, stiffness=0.7}
ob:load(pile{{"lead white",4},{"lemon chrome",0.3}}, 1)
for i=1,3 do ob:touch(704 + (i-2)*5, 78 + (i%2)*2, {pressure=0.8, drag={4,0.2}}) end

--@ chunk 49
-- PASS 2, chunk A: the dome repainted dark, darkness gathering upward, warmed only near the shaft and oculus;
-- then the bronze ribs modelled with lit edges toward the light.
ocM = npoly(oc.cx, oc.cy, 56, 7, 0.2, 0.62):grow(1)
lampZ = rect(210, 306, 58, 106)
function shaftX(y) return 704 + (466 - 704) * (y - 95) / 339 end
function lightK(x, y)
  -- distance to the shaft's centre line
  local ax, ay, bx, by = 704, 95, 466, 434
  local vx, vy = bx - ax, by - ay
  local t = clamp(((x - ax) * vx + (y - ay) * vy) / (vx * vx + vy * vy), 0, 1.15)
  local px, py = ax + vx * t, ay + vy * t
  local d1 = math.sqrt((x - px)^2 + (y - py)^2)
  local a = clamp(1 - d1 / 260, 0, 1)^1.5
  local v = clamp((y - 40) / 320, 0, 1)
  local d2 = math.sqrt((x - oc.cx)^2 + ((y - oc.cy) * 1.3)^2)
  local b = clamp(1 - d2 / 170, 0, 1)^2
  return math.max(a * (0.3 + 0.7 * v), b * 0.75) + 0.12 * v
end
local region = wallm - ocM - lampZ - pewmask
local nzK = noise{seed=71, period=40, octaves=3}
local K = mask(function(x, y) return 0.02 + 0.97 * clamp(lightK(x, y) + 0.07 * nzK(x, y), 0, 0.999) end) * region
local W1 = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.5}}
local W2 = pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.6},{"yellow ochre",0.3}}
local W3 = pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.8}}
local W4 = pile{{"burnt sienna",3},{"ultramarine blue",1.2},{"raw sienna",1.5},{"yellow ochre",0.6}}
local bands = {{0.01, 0.17, W1}, {0.17, 0.33, W2}, {0.33, 0.5, W3}, {0.5, 1.01, W4}}
for _, bd in ipairs(bands) do
  local m = K:band(bd[1], bd[2], 0)
  work(m, {hand="body", pile=bd[3], coverage=3.5, fill=true, angle=ribang, clip=true, length={20,60}, load=1})
end
print(wait(5*24*60))
-- ribs
local bsh = pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.8}}
local bmid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
local bhot = pile{{"lead white",2},{"yellow ochre",1},{"Mars orange",0.3}}
local bdim = pile{{"yellow ochre",1},{"burnt sienna",1},{"bone black",0.4}}
RIBPTS = {}
for i, x in ipairs(rib_x) do
  local pts = ribpath2(x)
  RIBPTS[i] = pts
  work(ribms[i] - ocM - lampZ, {hand="body", tool="filbert 6", pile=bsh, coverage=3.5, fill=true, angle=ribang, clip=true, length={15,40}, load=1})
end
print(wait(3*24*60))
local eb = brush{kind="round", width=2.4, point=0.5}
local mb = brush{kind="filbert", width=4}
for i, x in ipairs(rib_x) do
  local pts = RIBPTS[i]
  local clipR = ribms[i] - ocM - lampZ
  for j = 1, #pts - 1 do
    local p, q = pts[j], pts[j + 1]
    local w = rib_w[i] * (1 - 0.6 * (j - 1) / (#pts - 1))
    local dx, dy = q[1] - p[1], q[2] - p[2]
    local L = math.sqrt(dx * dx + dy * dy)
    local nx, ny = -dy / L, dx / L
    local mx, my = (p[1] + q[1]) / 2, (p[2] + q[2]) / 2
    local side = (mx < shaftX(my)) and 1 or -1
    if nx * side < 0 then nx, ny = -nx, -ny end
    local k = lightK(mx, my)
    -- the half of the rib turned to the light
    if k > 0.18 then
      for f = 0, 0.8, 0.2 do
        local ax, ay = lerp(p[1], q[1], f), lerp(p[2], q[2], f)
        local bx2, by2 = lerp(p[1], q[1], f + 0.25), lerp(p[2], q[2], f + 0.25)
        mb:reload(bmid, 0.7)
        mb:stroke({{ax + nx * w * 0.22, ay + ny * w * 0.22}, {bx2 + nx * w * 0.22, by2 + ny * w * 0.22}}, {pressure={0.6, 0.6}, clip=clipR})
      end
    end
    -- the lit edge
    local pl = (k > 0.6) and bhot or ((k > 0.38) and blit or ((k > 0.2) and bdim or nil))
    if pl then
      local o = w / 2 - 1.8
      eb:reload(pl, 0.7)
      eb:stroke({{p[1] + nx * o, p[2] + ny * o}, {q[1] + nx * o, q[2] + ny * o}}, {pressure={0.3 + 0.4 * k, 0.3 + 0.4 * k}, clip=clipR})
    end
  end
end

--@ chunk 50
-- PASS 2, chunk A2: the pale wall blotches round the shaft read as cloud. Keep the warm wall only in a band hugging the shaft.
local allRibs = ribms[1]
for i = 2, #ribms do allRibs = allRibs + ribms[i] end
local zone = (wallm - ocM - lampZ - pewmask - allRibs - shaft:grow(32)) * mask(function(x, y) return (lightK(x, y) > 0.36) and 1 or 0 end):grow(10)
local W3 = pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.8}}
work(zone, {hand="body", pile=W3, coverage=3.5, fill=true, angle=ribang, clip=true, length={20,60}, load=1})
local near = (shaft:grow(32) - shaft:grow(2)) * wallm - ocM - allRibs
local W4 = pile{{"burnt sienna",3},{"ultramarine blue",1.2},{"raw sienna",1.5},{"yellow ochre",0.6}}
work(near, {hand="body", pile=W4, coverage=3, fill=true, angle=ribang, clip=true, length={15,40}, load=1})
blend(((shaft:grow(40) - shaft:grow(24)) * wallm) - ocM - allRibs, {angle=math.atan(435-95, 466-704), tool={kind="badger", width=14}})

--@ chunk 51
-- PASS 2, chunk B: the floor relit from the pool outward; a clean pool; the inlay rings restated as grooves with bone inlay.
print(wait(2*24*60))
crossZ = rect(543, 356, 30, 40)
local region = floorm - pewmask - frame_m:grow(2) - lampZ - crossZ
local nz = noise{seed=72, period=30, octaves=3}
function floorK(x, y) local dx, dy = (x - 468) / 300, (y - 432) / 85; return clamp(1 - math.sqrt(dx*dx + dy*dy), 0, 1) end
local K = mask(function(x, y) return 0.02 + 0.97 * clamp(floorK(x, y) + 0.06 * nz(x, y), 0, 0.999) end) * region
local F1 = pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.4}}
local F2 = pile{{"bone black",1.5},{"burnt sienna",1.5},{"raw sienna",0.8}}
local F3 = pile{{"burnt sienna",2},{"raw sienna",1},{"yellow ochre",1},{"bone black",0.4}}
local F4 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.8},{"raw sienna",0.5}}
for _, bd in ipairs({{0.01, 0.14, F1}, {0.14, 0.36, F2}, {0.36, 0.62, F3}, {0.62, 1.01, F4}}) do
  work(K:band(bd[1], bd[2], 0), {hand="body", pile=bd[3], coverage=3.5, fill=true, angle=0.03, clip=true, length={20,60}, load=1})
end
-- the pool
local pl = ellipse(466, 433, 92, 18):roughen(3, 30, 4) * region
local pc = ellipse(468, 432, 52, 9):roughen(2, 20, 5) * region
work(pl, {hand="body", tool="filbert 6", pile=floor_lit, coverage=3.5, fill=true, angle=0.02, clip=true, length={10,30}, load=1})
work(pc, {hand="body", tool="filbert 5", pile=floor_hot, coverage=3.5, fill=true, angle=0.02, clip=true, length={8,25}, load=1})
blend((pl:grow(6) - pc:shrink(3)) * region, {angle=0.02, tool={kind="badger", width=14}})
print(wait(4*24*60))
-- inlay rings
local groove = pile{{"bone black",2},{"burnt sienna",1}}
local boneL = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.4}}
local boneM = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.3}}
local boneD = pile{{"lead white",0.8},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.6}}
local g = brush{kind="round", width=2.2, point=0.5}
local bl = brush{kind="round", width=1.5, point=0.7}
local rclip = floorm - pewmask - frame_m:grow(1.5) - crossZ - lampZ
local radii = {46, 74, 120, 194, 314, 508}
for i, r in ipairs(radii) do
  local pts = ring(560 + i*7 - 20, 398 + i*9, r, r*0.17 + i*1.5, 0.015*i - 0.03)
  local n = #pts
  for s = 1, n - 1, 6 do
    local part = {}
    for k = s, math.min(s + 7, n) do part[#part + 1] = pts[k] end
    local mx, my = part[1][1], part[1][2]
    if rclip:at(mx, my) > 0.3 or rclip:at(part[#part][1], part[#part][2]) > 0.3 then
      local k = floorK(mx, my)
      local inPool = ellipse(466, 433, 92, 18):at(mx, my) > 0.5
      g:reload(groove, 0.6); g:stroke(part, {pressure={0.5, 0.5}, clip=rclip})
      if not inPool then
        local up = {} for q, p in ipairs(part) do up[q] = {p[1], p[2] - 1.3} end
        local p = (k > 0.45) and boneL or ((k > 0.15) and boneM or boneD)
        bl:reload(p, 0.6); bl:stroke(up, {pressure={0.45, 0.45}, clip=rclip})
      end
    end
  end
end

--@ chunk 52
-- PASS 2, chunk C: MIRIAD benches as modular furniture: lit top rail, dark backs with panel seams on the module,
print(wait(2*24*60))
-- lit aisle ends, and shadows they throw away from the pool across the aisle.
local backP = pile{{"bone black",2},{"zinc white",0.35},{"ultramarine ash",0.5},{"burnt sienna",0.2}}
local backHi = pile{{"bone black",1.6},{"zinc white",0.6},{"ultramarine ash",0.6},{"burnt sienna",0.2}}
local topLit = pile{{"zinc white",1},{"bone black",0.7},{"ultramarine ash",0.4},{"yellow ochre",0.25}}
local topWarm = pile{{"zinc white",1.2},{"yellow ochre",0.6},{"bone black",0.4},{"burnt sienna",0.15}}
local topDim = pile{{"zinc white",0.6},{"bone black",1},{"ultramarine ash",0.5}}
local shP = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local aisleL = pile{{"burnt sienna",2},{"raw sienna",1},{"yellow ochre",1},{"bone black",0.4}}
local Lx, Ly = 468, 432
-- 1. the aisle floor carries the pool's light toward us; the benches' shadows cut across it
local aisle = poly({{486, 440}, {512, 440}, {540, 667}, {455, 667}}) * floorm - pewmask
work(aisle * mask(function(x, y) return (y < 560) and 1 or 0 end), {hand="body", tool="filbert 5", pile=aisleL, coverage=3, fill=true, angle=math.pi/2, clip=true, length={10,30}, load=1})
local shadows = nil
for i, pw in ipairs(pews) do
  local aisleEnd = (pw.xb < 500) and pw.xb or pw.xa
  local bx, by = aisleEnd, pw.y
  local dx, dy = bx - Lx, by - Ly
  local L = math.sqrt(dx*dx + dy*dy)
  local f = 0.9 * pw.h / L
  local outer = (pw.xb < 500) and pw.xa or pw.xb
  local q = poly({{outer, by}, {bx, by}, {bx + dx*f, by + dy*f}, {outer + (outer - Lx)*f*0.4, by + dy*f}})
  shadows = shadows and (shadows + q) or q
end
work((shadows * floorm) - pewmask, {hand="detail", tool="round 3", pile=shP, coverage=3.5, fill=true, load=1})
-- 2. each bench
local eb = brush{kind="round", width=1.6, point=0.5}
local sb = brush{kind="round", width=1.3, point=0.6}
for i, pw in ipairs(pews) do
  local s = (pw.y - 300) / 370
  local cut = pw.y - pw.h * 0.42
  local back = pw.mask * above(function(x) return cut end)
  work(back, {hand="body", tool="filbert 5", pile=backP, coverage=3.5, fill=true, angle=0, clip=true, length={15,50}, load=1})
  -- top rail: a thin lit plane above the back
  local a, b = pw.top[1], pw.top[2]
  local th = math.max(2.2, pw.h * 0.13)
  local rail = poly({{a[1] + 2*s, a[2] - th}, {b[1] - 2*s, b[2] - th}, {b[1], b[2]}, {a[1], a[2]}})
  local aisleRight = (pw.xb < 500)
  local near = clamp(1 - (pw.y - 452) / 240, 0.15, 1)
  local rb = brush{kind="filbert", width=math.max(2, th * 0.8)}
  for xx = a[1], b[1], 3 do
    local t = (xx - a[1]) / (b[1] - a[1])
    local toAisle = aisleRight and t or (1 - t)
    local k = near * (0.35 + 0.65 * toAisle^1.5)
    local p = (k > 0.6) and topWarm or ((k > 0.3) and topLit or topDim)
    local yy = lerp(a[2], b[2], t) - th / 2
    rb:reload(p, 0.6); rb:stroke({{xx, yy}, {xx + 3.4, yy + (b[2] - a[2]) * 3.4 / (b[1] - a[1])}}, {pressure={0.6, 0.6}, clip=rail})
  end
  -- the back's upper bevel, a hair lighter
  eb:reload(backHi, 0.6); eb:stroke({{a[1] + 2, a[2] + 1.5}, {b[1] - 2, b[2] + 1.5}}, {pressure={0.4, 0.4}, clip=pw.mask})
  -- module seams in line with the legs
  local n = math.floor((pw.xb - pw.xa) / (90 * s)) + 1
  for k = 1, n - 1 do
    local x = pw.xa + 6*s + k * ((pw.xb - pw.xa - 12*s) / math.max(n, 1))
    local t = (x - a[1]) / (b[1] - a[1])
    local ytop = lerp(a[2], b[2], t)
    sb:reload(shP, 0.6); sb:stroke({{x, ytop + 1}, {x, cut - 0.5}}, {pressure={0.5, 0.5}, clip=pw.mask})
    local side = aisleRight and 1.1 or -1.1
    sb:reload(backHi, 0.4); sb:stroke({{x + side, ytop + 1.5}, {x + side, cut - 1}}, {pressure={0.3, 0.3}, clip=pw.mask})
  end
  -- the aisle end of the bench catches the pool's light
  local ex = aisleRight and pw.xb or pw.xa
  local ew = math.max(2, 4 * s)
  local endM = rect(aisleRight and (ex - ew) or ex, pw.y - pw.h - 3, ew, pw.h + 3) * (pw.mask + rail)
  work(endM, {hand="detail", tool="round 1.6", pile=(near > 0.6) and topWarm or topLit, coverage=3, fill=true, load=0.8})
end

--@ chunk 53
-- PASS 2, chunk C2: bench backs turned from the light go darker, a little lighter toward the aisle; seams restated;
-- the aisle's light narrowed and faded; fill the boxes left round the cross and lamp.
print(wait(3*24*60))
local backD = pile{{"bone black",2},{"zinc white",0.12},{"ultramarine ash",0.4},{"burnt sienna",0.2}}
local backM = pile{{"bone black",2},{"zinc white",0.28},{"ultramarine ash",0.5},{"burnt sienna",0.2}}
local backHi = pile{{"bone black",1.6},{"zinc white",0.5},{"ultramarine ash",0.6},{"burnt sienna",0.2}}
local shP = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.4}}
local fb = brush{kind="filbert", width=4}
local sb = brush{kind="round", width=1.3, point=0.6}
for i, pw in ipairs(pews) do
  local s = (pw.y - 300) / 370
  local cut = pw.y - pw.h * 0.42
  local a, b = pw.top[1], pw.top[2]
  local back = pw.mask * above(function(x) return cut end)
  local aisleRight = (pw.xb < 500)
  for yy = math.min(a[2], b[2]) - 1, cut + 1, 3 do
    for xx = pw.xa, pw.xb, 6 do
      local t = (xx - pw.xa) / (pw.xb - pw.xa)
      local toAisle = aisleRight and t or (1 - t)
      local p = (toAisle + rand(-0.05, 0.05) > 0.78) and backM or backD
      if back:at(xx + 3, yy) > 0.3 then
        fb:reload(p, 0.6); fb:stroke({{xx, yy}, {xx + 7, yy}}, {pressure={0.6, 0.6}, clip=back})
      end
    end
  end
  sb:reload(backHi, 0.6); sb:stroke({{a[1] + 2, a[2] + 1.5}, {b[1] - 2, b[2] + 1.5}}, {pressure={0.4, 0.4}, clip=pw.mask})
  local n = math.floor((pw.xb - pw.xa) / (90 * s)) + 1
  for k = 1, n - 1 do
    local x = pw.xa + 6*s + k * ((pw.xb - pw.xa - 12*s) / math.max(n, 1))
    local ytop = lerp(a[2], b[2], (x - a[1]) / (b[1] - a[1]))
    sb:reload(shP, 0.6); sb:stroke({{x, ytop + 1}, {x, cut - 0.5}}, {pressure={0.5, 0.5}, clip=pw.mask})
    local side = aisleRight and 1.1 or -1.1
    sb:reload(backHi, 0.4); sb:stroke({{x + side, ytop + 1.5}, {x + side, cut - 1}}, {pressure={0.3, 0.3}, clip=pw.mask})
  end
end
-- aisle: dark at its edges (the bench ends' shadows), a narrow warm path down the middle that fades toward us
local aisle = poly({{484, 438}, {514, 438}, {542, 667}, {453, 667}}) * floorm - pewmask
local F2 = pile{{"bone black",1.5},{"burnt sienna",1.5},{"raw sienna",0.8}}
local F3 = pile{{"burnt sienna",2},{"raw sienna",1},{"yellow ochre",1},{"bone black",0.4}}
work(aisle, {hand="body", tool="filbert 5", pile=F2, coverage=3.5, fill=true, angle=math.pi/2, clip=true, length={10,30}, load=1})
local path = poly({{493, 440}, {505, 440}, {502, 540}, {497, 540}}) * floorm - pewmask
work(path, {hand="detail", tool="round 2.5", pile=F3, coverage=3, fill=true, load=0.8})
-- boxes round the cross and the lamp
local F4 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.8},{"raw sienna",0.5}}
work(crossZ * floorm, {hand="detail", tool="round 3", pile=F3, coverage=3.5, fill=true, load=1})
work(crossZ - floorm, {hand="detail", tool="round 3", pile=pile{{"burnt sienna",3},{"ultramarine blue",1.2},{"raw sienna",1.5},{"yellow ochre",0.6}}, coverage=3.5, fill=true, load=1})
work(lampZ * wallm, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.6},{"yellow ochre",0.3}}, coverage=3.5, fill=true, angle=ribang, clip=true, load=1})
work(lampZ * floorm, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"burnt sienna",1.5},{"ultramarine blue",0.4}}, coverage=3.5, fill=true, angle=0.03, clip=true, load=1})

--@ chunk 54
-- PASS 2, chunk D: the shaft as light in air: lean warm-white veils, blended along the fall, edges softened;
-- a bronze frame round the oculus.
print(wait(4*24*60))
local bang = math.atan(435-95, 466-704)
local s = shaft - frame_m:grow(1) - pewmask - crossZ - ocM
local veilW = pile{{"lead white",3},{"Mars orange",0.3},{"cadmium yellow",0.15}, medium=0.88}
work(s, {hand="glaze", pile=veilW, coverage=1.2, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
work(s:shrink(12), {hand="glaze", pile=veilW, coverage=0.8, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
work(s * above(function(x) return 260 end), {hand="glaze", pile=veilW, coverage=0.6, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
blend(s, {angle=bang})
blend((shaft:grow(5) - shaft:shrink(5)) - frame_m:grow(2) - pewmask - crossZ - ocM, {angle=bang, tool={kind="badger", width=12}})
-- oculus frame
local ring7 = npoly(oc.cx, oc.cy, 60, 7, 0.2, 0.62) - npoly(oc.cx, oc.cy, 54, 7, 0.2, 0.62)
work(ring7, {hand="detail", tool="round 2", pile=pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.8}}, coverage=4, fill=true, load=1})

--@ chunk 55
-- PASS 2, chunk E: the kneeling frame as armour (helm, pauldrons, back plate, folded legs) and a cross of two scraps.
FIG = {
  helm = {{464,388},{466,383},{470,381.5},{474.5,383},{476.5,388},{476,394},{470,396.5},{464.5,394}},
  pauldL = {{450,400},{455,394.5},{463,393.5},{465,399},{462,406},{453,407}},
  pauldR = {{475,399},{477,393.5},{485,394.5},{490,400},{487,407},{478,406}},
  back = {{458,398},{482,398},{485,407},{482,419},{479,427},{461,427},{458,419},{455,407}},
  footL = {{452,427},{466,427},{467,433},{449,435}},
  footR = {{474,427},{487,427},{492,435},{474,433}},
}
local figAll = nil
for k, pts in pairs(FIG) do local m = poly(pts); figAll = figAll and (figAll + m) or m end
FIGM = figAll
local dk = pile{{"bone black",2},{"ultramarine blue",0.4},{"zinc white",0.3},{"burnt sienna",0.2}}
work(FIGM, {hand="detail", tool="round 1.6", pile=dk, coverage=5, fill=true, load=1})
-- cross: two scraps lashed
CROSS = poly({{555,359},{559.5,357.5},{561.5,360},{561,394.5},{554.5,395}}) + poly({{545.5,369.5},{568.5,367},{569,372},{546,374.5}})
work(CROSS, {hand="detail", tool="round 1.4", pile=dk, coverage=5, fill=true, load=1})
print(wait(5*24*60))
local rimH = pile{{"lead white",3},{"cadmium yellow",0.8},{"Mars orange",0.1}}
local rimW = pile{{"yellow ochre",1},{"lead white",1},{"Mars orange",0.3}}
local seam = pile{{"bone black",2},{"burnt sienna",0.6}}
local mid = pile{{"bone black",1.4},{"zinc white",0.5},{"ultramarine ash",0.5},{"burnt sienna",0.3}}
local r1 = brush{kind="round", width=1.3, point=0.8}
local r2 = brush{kind="round", width=1.0, point=0.8}
local function st(b, p, pts, pr, clipM) b:reload(p, 0.7); b:stroke(pts, {pressure=pr, ramps={0.15,0.3}, clip=clipM}) end
-- plate faces: a mid gray on the planes turned up and right
st(r1, mid, {{466,386},{470,384},{474,386}}, {0.5,0.4}, FIGM)
st(r1, mid, {{478,397},{484,397.5},{487,401}}, {0.5,0.4}, FIGM)
st(r1, mid, {{453,401},{457,397},{462,396.5}}, {0.45,0.35}, FIGM)
st(r1, mid, {{474,402},{480,405},{482,412}}, {0.45,0.3}, FIGM)
-- seams: spine, waist, shoulder-blade plates, helm visor ridge
st(r2, seam, {{470,399},{470,425}}, {0.5,0.5}, FIGM)
st(r2, seam, {{460,417},{480,417}}, {0.5,0.5}, FIGM)
st(r2, seam, {{460,401},{464,410},{469,411}}, {0.4,0.4}, FIGM)
st(r2, seam, {{480,401},{476,410},{471,411}}, {0.4,0.4}, FIGM)
st(r2, seam, {{465,392},{470,393.5},{475.5,392}}, {0.4,0.4}, FIGM)
-- rim light from the shaft above and to the right
st(r1, rimH, {{465,386.5},{467,383.2},{470.5,382.2},{474.5,383.8},{476.2,387.5}}, {0.7,0.45}, FIGM)
st(r1, rimH, {{476.5,395.5},{481,394.6},{485,395.4},{489,399.5}}, {0.7,0.4}, FIGM)
st(r1, rimW, {{489,400.5},{487.5,406}}, {0.5,0.3}, FIGM)
st(r1, rimW, {{484.5,408},{482,418},{479.5,425.5}}, {0.45,0.25}, FIGM)
st(r1, rimW, {{451,399.5},{455.5,395.2},{462.5,394.2}}, {0.45,0.3}, FIGM)
-- the pool's light on the soles
st(r1, rimW, {{450,434},{466,432.6}}, {0.5,0.4}, FIGM)
st(r1, rimW, {{475,432.6},{491,434}}, {0.5,0.4}, FIGM)
-- cross: sunward edges, lashing, shadow thrown down-left
st(r1, rimH, {{560.8,360},{560.6,393}}, {0.55,0.35}, CROSS)
st(r1, rimH, {{546,369.8},{568,367.4}}, {0.5,0.4}, CROSS)
for _, w in ipairs({{{554.5,368},{561.5,374}}, {{554.5,370.5},{561.5,376}}, {{561.5,368},{554.5,374}}}) do
  st(r2, pile{{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.6}}, w, {0.45,0.45}, nil)
end
local shd = poly({{554,394},{561,394},{544,401},{532,403}})
work(shd * floorm - frame_m, {hand="detail", tool="round 1.6", pile=pile{{"bone black",2},{"burnt sienna",1.2}}, coverage=3, fill=true, load=0.8})

--@ chunk 56
-- PASS 2, chunk F: the frieze as a real band: a dark bronze course between two mouldings, and the fold-notation
-- glyphs restated cleanly in bone (each polygon holding a smaller copy turned by the golden angle).
local band = wallm * mask(function(x, y) local f = foot(x); return (y > f - 46 and y < f - 7) and 1 or 0 end) - shaft:grow(3) - lampZ - pewmask
local fr = pile{{"bone black",2},{"burnt sienna",1.5},{"yellow ochre",0.5}}
work(band, {hand="body", tool="filbert 5", pile=fr, coverage=3.5, fill=true, angle=0, clip=true, length={15,40}, load=1})
print(wait(3*24*60))
local boneL = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.4}}
local boneM = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.3}}
local boneD = pile{{"lead white",0.8},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.6}}
local mb = brush{kind="round", width=1.8, point=0.5}
local clipW = wallm - shaft:grow(3) - lampZ - pewmask - pewmask
local function pk(k) return (k > 0.45) and boneL or ((k > 0.22) and boneM or boneD) end
-- mouldings
for _, off in ipairs({-47.5, -6.5}) do
  for x = 0, 996, 6 do
    local y1, y2 = foot(x) + off, foot(x + 6) + off
    if clipW:at(x + 3, (y1 + y2) / 2) > 0.5 then
      mb:reload(pk(lightK(x, y1)), 0.55); mb:stroke({{x, y1}, {x + 6.3, y2}}, {pressure={0.45, 0.45}, clip=clipW})
    end
  end
end
-- glyphs
local gb = brush{kind="round", width=1.3, point=0.8}
local x, k = 20, 0
while x < 985 do
  k = k + 1
  local y = foot(x) - 27
  if clipW:at(x, y) > 0.5 and shaft:grow(14):at(x, y) < 0.2 then
    local r = 9 + (k * 7) % 4
    local n = 3 + (k * 5) % 6
    local rot = k * 0.9
    local p = pk(lightK(x, y))
    for d = 0, 2 do
      local rr = r * (0.618^d)
      local a0 = rot + d * 2.399
      local pts = {}
      for i = 0, n do local a = a0 + i * 2 * math.pi / n; pts[#pts + 1] = {x + rr * math.cos(a), y + rr * math.sin(a) * 0.9} end
      gb:reload(p, 0.6); gb:stroke(pts, {pressure={0.5, 0.45}, ramps={0.05, 0.05}, clip=clipW})
    end
  end
  x = x + 30 + ((k * 0.618) % 1) * 14
end

--@ chunk 57
-- PASS 2, chunk G: close the box round the cross into the shaft's haze; the frame's rims stated firmly.
print(wait(2*24*60))
local zone = crossZ - CROSS:grow(0.6)
local G1 = pile{{"bone black",1},{"lead white",1},{"yellow ochre",0.3},{"burnt sienna",0.2}}
local G2 = pile{{"lead white",1.5},{"bone black",0.8},{"yellow ochre",0.5},{"burnt sienna",0.3}}
work(zone * above(function(x) return 382 end), {hand="detail", tool="round 2.5", pile=G1, coverage=3.5, fill=true, load=1})
work(zone * below(function(x) return 382 end), {hand="detail", tool="round 2.5", pile=G2, coverage=3.5, fill=true, load=1})
local shd = poly({{554,394},{561,394},{544,401},{532,403}})
work(shd * floorm, {hand="detail", tool="round 1.6", pile=pile{{"bone black",2},{"burnt sienna",1.2}}, coverage=3, fill=true, load=0.8})
print(wait(3*24*60))
local bang = math.atan(435-95, 466-704)
local veilW = pile{{"lead white",3},{"Mars orange",0.3},{"cadmium yellow",0.15}, medium=0.88}
work(zone:grow(3) * shaft - CROSS:grow(0.5), {hand="glaze", pile=veilW, coverage=1.0, fill=true, clip=true, angle=bang, load=0.2, pressure={0.08,0.2}})
-- frame rims
local rimH = pile{{"lead white",3},{"cadmium yellow",0.8},{"Mars orange",0.1}}
local r = brush{kind="round", width=1.8, point=0.7}
local function st(pts, pr) r:reload(rimH, 0.8); r:stroke(pts, {pressure=pr, ramps={0.12,0.3}, clip=FIGM}) end
st({{465,387},{467,383.4},{470.5,382.4},{474.5,384},{476.2,388}}, {0.75,0.5})
st({{476.8,395.2},{481,394.4},{485.5,395.2},{489.2,399.5}}, {0.75,0.45})
st({{451.2,399.6},{455.5,395},{462,394}}, {0.55,0.3})
st({{488.8,401},{487.4,406.5}}, {0.5,0.3})

--@ chunk 58
print(wait(3*24*60))
local zone = crossZ - CROSS:grow(0.6)
local G0 = pile{{"bone black",1.3},{"lead white",0.8},{"burnt sienna",0.35},{"yellow ochre",0.2}}
work(zone * above(function(x) return 384 end), {hand="detail", tool="round 2.5", pile=G0, coverage=3.5, fill=true, load=1})
stipple((zone:grow(4) - zone:shrink(3)) - CROSS:grow(0.6), {pile=G0, width=2.5, coverage=0.8, feather=0.6, pressure={0.3,0.6}})
local bang = math.atan(435-95, 466-704)
local veilW = pile{{"lead white",3},{"Mars orange",0.3},{"cadmium yellow",0.15}, medium=0.88}
local z2 = zone:grow(7) * shaft - CROSS:grow(0.8)
work(z2, {hand="glaze", pile=veilW, coverage=0.8, fill=true, clip=true, angle=bang, load=0.2, pressure={0.08,0.2}})
blend(z2, {angle=bang, tool={kind="badger", width=12}})

--@ chunk 59
-- PASS 2, chunk H: warm the shaft, a hot pool at its foot, and the dead work lamp back in its corner.
print(wait(3*24*60))
local bang = math.atan(435-95, 466-704)
local s = shaft - frame_m:grow(1) - FIGM:grow(1) - pewmask - CROSS:grow(1) - ocM
local warmV = pile{{"Mars orange",1},{"lead white",0.6},{"cadmium yellow",0.2}, medium=0.9}
work(s, {hand="glaze", pile=warmV, coverage=0.8, fill=true, clip=true, angle=bang, load=0.22, pressure={0.08,0.22}})
blend(s, {angle=bang})
local hot = ellipse(470, 424, 72, 8):soften(3) * floorm - pewmask - FIGM:grow(1)
work(hot, {hand="detail", tool="round 2.5", pile=floor_hot, coverage=3.5, fill=true, load=1})
local core = ellipse(472, 423, 36, 4.5) * floorm - pewmask - FIGM:grow(1)
work(core, {hand="detail", tool="round 2", pile=pile{{"lead white",3},{"cadmium yellow",0.6}}, coverage=3.5, fill=true, load=1})
-- the lamp
local lg2 = pile{{"bone black",2},{"zinc white",0.5},{"ultramarine ash",0.5}}
for _, leg in ipairs({{{238,338},{222,402}}, {{240,338},{246,404}}, {{239,338},{258,398}}}) do
  lampb:reload(lg2, 0.8); lampb:stroke(leg, {pressure={0.6,0.5}, ramps={0.05,0.1}})
end
work(poly({{224,318},{254,316},{256,340},{226,342}}), {hand="detail", pile=lg2, coverage=6, fill=true, clip=true})
work(poly({{224,336},{256,334},{256,340},{226,342}}), {hand="detail", pile=pile{{"Mars orange",1},{"yellow ochre",0.5},{"bone black",0.6}}, coverage=6, fill=true, clip=true})
local eb = brush{kind="round", width=1.2, point=0.7}
eb:reload(pile{{"yellow ochre",1},{"burnt sienna",1},{"lead white",0.4}}, 0.6); eb:stroke({{226,318.5},{253.5,316.5}}, {pressure={0.4,0.3}})

--@ chunk 60
-- PASS 2, chunk I: the orange blotches round the pool's outer floor go down to a quiet dark; the light stays near the pool; rings restated there.
print(wait(3*24*60))
local Z = (floorm - pewmask - FIGM:grow(1) - CROSS:grow(1) - crossZ - lampZ) * (ellipse(468, 432, 330, 95) - ellipse(468, 430, 165, 34):roughen(6, 40, 3))
local F2 = pile{{"bone black",1.5},{"burnt sienna",1.5},{"raw sienna",0.8}}
work(Z, {hand="body", pile=F2, coverage=3.5, fill=true, angle=0.03, clip=true, length={20,60}, load=1})
print(wait(3*24*60))
local groove = pile{{"bone black",2},{"burnt sienna",1}}
local boneM = pile{{"lead white",1.5},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.3}}
local boneD = pile{{"lead white",0.8},{"yellow ochre",1},{"raw sienna",0.6},{"bone black",0.6}}
local g = brush{kind="round", width=2.2, point=0.5}
local bl = brush{kind="round", width=1.5, point=0.7}
local radii = {46, 74, 120, 194, 314, 508}
for i, r in ipairs(radii) do
  local pts = ring(560 + i*7 - 20, 398 + i*9, r, r*0.17 + i*1.5, 0.015*i - 0.03)
  for s = 1, #pts - 1, 6 do
    local part = {}
    for k = s, math.min(s + 7, #pts) do part[#part + 1] = pts[k] end
    if Z:at(part[1][1], part[1][2]) > 0.3 or Z:at(part[#part][1], part[#part][2]) > 0.3 then
      g:reload(groove, 0.6); g:stroke(part, {pressure={0.5, 0.5}, clip=Z})
      local up = {} for q, p in ipairs(part) do up[q] = {p[1], p[2] - 1.3} end
      bl:reload((floorK(part[1][1], part[1][2]) > 0.2) and boneM or boneD, 0.6); bl:stroke(up, {pressure={0.45, 0.45}, clip=Z})
    end
  end
end

--@ chunk 61
-- PASS 2, chunk J: the floor repaint ran under the shaft's foot; veil it again so the light reaches the pool.
print(wait(4*24*60))
local bang = math.atan(435-95, 466-704)
local s = (shaft * floorm) - FIGM:grow(1) - pewmask - CROSS:grow(1)
local s2 = (shaft:grow(4) * floorm * below(function(x) return 330 end)) - FIGM:grow(1) - pewmask - CROSS:grow(1)
local veilW = pile{{"lead white",3},{"Mars orange",0.3},{"cadmium yellow",0.15}, medium=0.88}
local warmV = pile{{"Mars orange",1},{"lead white",0.6},{"cadmium yellow",0.2}, medium=0.9}
work(s, {hand="glaze", pile=veilW, coverage=1.6, fill=true, clip=true, angle=bang, load=0.25, pressure={0.1,0.25}})
work(s, {hand="glaze", pile=warmV, coverage=0.8, fill=true, clip=true, angle=bang, load=0.22, pressure={0.08,0.22}})
blend(s2 + (shaft * mask(function(x, y) return (y > 300 and y < 360) and 1 or 0 end) - CROSS:grow(1)), {angle=bang})
