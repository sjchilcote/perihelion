-- easel session "seam": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=4471,
  ground={{pile={{"lead white",6},{"bone black",1.2},{"bone brown",0.6},{"ultramarine ash",0.5}}, um=90, apply="knife", texture=0.35}}}
print(W,H)

--@ chunk 2
VX, VY = 545, 310
EX0, EY0, EX1, EY1 = 330, 100, 760, 520
-- scale a point about the VP: s=1 end plane, s>1 nearer
function SP(x, y, s) return {VX + (x - VX) * s, VY + (y - VY) * s} end
local h = pencil("2B")
-- end rectangle
h:rule({EX0,EY0},{EX1,EY0},{pressure=0.4})
h:rule({EX1,EY0},{EX1,EY1},{pressure=0.4})
h:rule({EX1,EY1},{EX0,EY1},{pressure=0.4})
h:rule({EX0,EY1},{EX0,EY0},{pressure=0.4})
-- corridor corner lines to beyond the canvas
for _, c in ipairs{{EX0,EY0},{EX1,EY0},{EX1,EY1},{EX0,EY1}} do
  h:rule(c, SP(c[1], c[2], 3.2), {pressure=0.35})
end
-- rib frames at several depths
for _, s in ipairs{1.18, 1.45, 1.85, 2.5} do
  local a, b, c, d = SP(EX0,EY0,s), SP(EX1,EY0,s), SP(EX1,EY1,s), SP(EX0,EY1,s)
  h:rule(a, b, {pressure=0.25}); h:rule(b, c, {pressure=0.25})
  h:rule(c, d, {pressure=0.25}); h:rule(d, a, {pressure=0.25})
end
-- the cut, front face, hand-drawn
h:sketch({{423,140},{520,128},{660,136},{668,300},{672,500},{540,508},{418,503},{415,320},{423,140}}, {pressure=0.4, smooth=false})
-- back face
h:sketch({{450,176},{530,166},{640,172},{644,300},{647,468},{540,472},{447,469},{445,320},{450,176}}, {pressure=0.3, smooth=false})

--@ chunk 3
local function quad(a, b, s)
  local p1, p2 = SP(a[1],a[2],1), SP(b[1],b[2],1)
  local p3, p4 = SP(b[1],b[2],5), SP(a[1],a[2],5)
  return poly({p1,p2,p3,p4})
end
CEIL  = quad({EX0,EY0},{EX1,EY0})
FLOOR = quad({EX0,EY1},{EX1,EY1})
LWALL = quad({EX0,EY0},{EX0,EY1})
RWALL = quad({EX1,EY0},{EX1,EY1})
ENDW  = rect(EX0, EY0, EX1-EX0, EY1-EY0)
print(CEIL:area(), FLOOR:area(), LWALL:area(), RWALL:area())
-- direction toward VP
TOVP = function(x, y) return math.atan(VY - y, VX - x) end
cgray = pile{{"bone black",3},{"ultramarine ash",2},{"lead white",1.2},{"cobalt blue",0.3}, medium=0.1}
work(LWALL + RWALL, {hand="broad", pile=cgray, angle=TOVP, coverage=2.6, fill=true})

--@ chunk 4
cceil = pile{{"bone black",3},{"ultramarine ash",1.5},{"lead white",0.8},{"bone brown",0.4}, medium=0.1}
cfloor = pile{{"bone black",3},{"bone brown",1},{"ultramarine ash",1},{"lead white",0.7}, medium=0.1}
work(LWALL + RWALL, {hand="body", pile=cgray, angle=TOVP, coverage=2.0, fill=true, clip=true})
work(CEIL, {hand="body", pile=cceil, angle=TOVP, coverage=2.5, fill=true, clip=true})
work(FLOOR, {hand="body", pile=cfloor, angle=TOVP, coverage=2.5, fill=true, clip=true})

--@ chunk 5
CUTF = {{422,172},{452,131},{548,127},{632,133},{665,165},{668,330},{671,506},{545,509},{417,505},{416,330}}
local back = {}
for i, p in ipairs(CUTF) do back[i] = SP(p[1], p[2], 0.8) end
CUTB = back
CUT  = poly(CUTF):roughen(1.5, 14, 11)
VIEW = poly(CUTB):roughen(1.2, 12, 12)
REVEAL = CUT - VIEW
BRONZE = ENDW - CUT
print(CUT:area(), VIEW:area(), REVEAL:area(), BRONZE:area())
ilight = pile{{"lead white",6},{"yellow ochre",1.2},{"Indian yellow",0.5},{"raw sienna",0.3}, medium=0.15}
imid = pile{{"lead white",3},{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.4}, medium=0.15}
work(VIEW, {hand="body", pile=imid, angle=TOVP, coverage=2.5, fill=true, clip=true})
local core = ellipse(548, 300, 70, 110):soften(30)
work(core * VIEW, {hand="body", pile=ilight, coverage=2.0, fill=true, clip=VIEW, angle=TOVP})

--@ chunk 6
SPX, SPY = 528, 262
TANG = function(x, y) return math.atan(y - SPY, x - SPX) + math.pi/2 end
bronze_d = pile{{"burnt sienna",2},{"Mars brown",2},{"bone black",1},{"ultramarine blue",0.6},{"yellow ochre",0.5}, medium=0.1}
reveal_m = pile{{"yellow ochre",2},{"burnt sienna",1.5},{"lead white",1},{"raw sienna",1},{"Mars brown",0.5}, medium=0.1}
work(BRONZE, {hand="body", pile=bronze_d, angle=TANG, coverage=2.6, fill=true, clip=true})
work(REVEAL, {hand="body", pile=reveal_m, angle=TOVP, coverage=2.6, fill=true, clip=true})

--@ chunk 7
print(wait(24*60)); for _,p in ipairs{{100,300},{545,300},{400,300},{545,600},{545,30},{430,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 8
print(wait(36*60)); for _,p in ipairs{{100,300},{545,300},{400,300},{545,600},{545,30},{430,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 9
print(wait(3*24*60)); for _,p in ipairs{{100,300},{545,300},{400,300},{545,600},{545,30},{430,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 10
i_base  = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",2},{"raw sienna",0.5}, medium=0.15}
i_floor = pile{{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.5}, medium=0.15}
i_glow  = pile{{"lead white",4},{"cadmium yellow",0.4},{"yellow ochre",0.5}, medium=0.15}
i_core  = pile{{"lead white",3},{"lemon chrome",0.4}, medium=0.1}
local V = VIEW
work(V, {hand="body", pile=i_base, angle=TOVP, coverage=3, fill=true, clip=true})
local fl = below(function(x) return 345 end) * V
work(fl, {hand="body", pile=i_floor, angle=0, coverage=2.5, fill=true, clip=V})
local g = ellipse(545, 290, 62, 85) * V
work(g, {hand="body", pile=i_glow, angle=TOVP, coverage=2.5, fill=true, clip=V})
local c = ellipse(545, 298, 20, 30)
work(c, {hand="body", pile=i_core, coverage=3, fill=true, clip=V, tool="filbert 4"})
blend(V, {angle=0})

--@ chunk 11
-- nave arch: world half-width a, height h (m), scale s, rotation rot, centre drift (dx,dy)
function ARCHPTS(s, a, h, rot, dx, dy, p)
  local pts = {}
  p = p or 3
  local k = 175 * s
  local n = 18
  for i = 0, 2*n do
    local u, side
    if i <= n then u = i / n; side = -1 else u = (2*n - i) / n; side = 1 end
    local xm = side * a * (1 - u^p)
    local ym = h * u
    local x, y = xm * k, (1.2 - ym) * k
    local c, sn = math.cos(rot), math.sin(rot)
    pts[#pts+1] = {VX + dx + x*c - y*sn, VY + dy + x*sn + y*c}
  end
  return pts
end
-- the nave's ribs, distances not uniform (golden jitter)
ARCHES = {}
local s = 0.074
local rot, dx, dy = 0, 0, 0
for i = 1, 16 do
  local gj = 0.78 + 0.08 * ((i * 0.618034) % 1)
  if i > 4 then rot = rot + 0.045 + 0.01*i*0.3; dy = dy - 0.9; dx = dx + 0.5 end
  ARCHES[i] = {s=s, rot=rot, dx=dx, dy=dy}
  s = s * gj
end
for i, A in ipairs(ARCHES) do print(i, string.format("%.4f %.2f %.1f %.1f", A.s, A.rot, A.dx, A.dy)) end

--@ chunk 12
ribN = pile{{"burnt sienna",1},{"yellow ochre",1.5},{"lead white",0.6},{"Mars brown",0.4}, medium=0.1}
ribM = pile{{"yellow ochre",2},{"burnt sienna",0.6},{"lead white",1.5},{"raw sienna",0.5}, medium=0.1}
ribF = pile{{"lead white",3},{"yellow ochre",1.2},{"Mars orange",0.3}, medium=0.1}
for i = #ARCHES, 1, -1 do
  local A = ARCHES[i]
  local pts = ARCHPTS(A.s, 9, 14, A.rot, A.dx, A.dy)
  local w = math.max(1.3, 210 * A.s)
  local pl = (A.s > 0.03) and ribN or ((A.s > 0.012) and ribM or ribF)
  local b = brush{kind="round", width=w, stiffness=0.5}
  b:load(pl, 0.9)
  -- left leg up to apex, then apex down to right leg, as two strokes
  local L, R = {}, {}
  for j = 1, 19 do L[#L+1] = pts[j] end
  for j = 19, #pts do R[#R+1] = pts[j] end
  b:stroke(L, {pressure={0.85, 0.8}, clip=VIEW, shake=0.5})
  b:load(pl, 0.9)
  b:stroke(R, {pressure={0.8, 0.85}, clip=VIEW, shake=0.5})
end

--@ chunk 13
print(wait(2*24*60)); for _,p in ipairs{{100,300},{900,300},{30,600},{545,300},{545,600},{345,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 14
function RECTS(s)
  local a = SP(EX0, EY0, s); local b = SP(EX1, EY1, s)
  return rect(a[1], a[2], b[1]-a[1], b[2]-a[2])
end
wallF = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",1.1},{"yellow ochre",0.4}, medium=0.1}
wallN = pile{{"bone black",2.4},{"ultramarine blue",0.8},{"lead white",0.45},{"burnt sienna",0.3}, medium=0.1}
ceilF = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.8},{"yellow ochre",0.2}, medium=0.1}
ceilN = pile{{"bone black",2.4},{"ultramarine blue",0.8},{"lead white",0.35},{"burnt sienna",0.3}, medium=0.1}
local walls = LWALL + RWALL
local far = RECTS(1.75) - ENDW
local near = -RECTS(1.75)
work(walls * far, {hand="body", pile=wallF, angle=TOVP, coverage=3, fill=true, clip=walls})
work(walls * near, {hand="body", pile=wallN, angle=TOVP, coverage=3, fill=true, clip=walls})
work(CEIL * far, {hand="body", pile=ceilF, angle=TOVP, coverage=3, fill=true, clip=CEIL})
work(CEIL * near, {hand="body", pile=ceilN, angle=TOVP, coverage=3, fill=true, clip=CEIL})
local seam = RECTS(2.2) - RECTS(1.4)
blend(walls * seam, {angle=TOVP})
blend(CEIL * seam, {angle=TOVP})

--@ chunk 15
pb1 = pile{{"raw sienna",2},{"bone black",1.2},{"burnt sienna",1}, medium=0.08}
pb2 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}, medium=0.08}
pbD = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"ultramarine blue",0.2}, medium=0.08}
pb3 = pile{{"burnt sienna",2},{"Mars brown",1},{"yellow ochre",0.8},{"bone black",0.6}, medium=0.08}
pshad = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}, medium=0.15}
-- body of one scale plate centred (x,y), radial direction ang (outward), size sz
function PLATE_BODY(x, y, ang, sz, pl, clipm)
  local c, s = math.cos(ang), math.sin(ang)
  local L = sz * 0.45
  local b = brush{kind="filbert", width=sz*1.12, stiffness=0.5}
  b:load(pl, 0.8)
  b:stroke({{x - c*L, y - s*L}, {x + c*L*0.5, y + s*L*0.5}},
    {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=clipm})
end
-- the shadow cast just outside a plate's free (outer) edge
function PLATE_SHADOW(x, y, ang, sz, clipm, w)
  local pts = {}
  local R = sz * 0.52
  for k = -3, 3 do
    local a = ang + k * 0.33
    pts[#pts+1] = {x + math.cos(ang)*sz*0.12 + math.cos(a)*R, y + math.sin(ang)*sz*0.12 + math.sin(a)*R}
  end
  local b = brush{kind="round", width=w or 5, point=0.2}
  b:load(pshad, 0.7)
  b:stroke(pts, {pressure={0.45, 0.75}, swell={0.5, 1, 0.5}, clip=clipm})
end
-- a glint on the plate's rim on the side facing (lx,ly)
function PLATE_GLINT(x, y, ang, sz, lx, ly, pl, amt, clipm)
  local a = math.atan(ly - y, lx - x)
  -- keep the glint on the outer (raised) half of the rim
  local R = sz * 0.42
  local pts = {}
  for k = -2, 2 do
    local b2 = a + k * 0.25
    pts[#pts+1] = {x + math.cos(b2)*R, y + math.sin(b2)*R}
  end
  local b = brush{kind="round", width=2.2, point=0.7}
  b:load(pl, 0.55)
  b:stroke(pts, {pressure={0.1, 0.55*amt + 0.1}, swell={0.4, 1, 0.3}, clip=clipm})
end
-- Vogel positions about (cx,cy), spacing c, inside mask m
function VOGEL(cx, cy, c, nmax, m)
  local out = {}
  for n = 1, nmax do
    local r = c * math.sqrt(n)
    local th = n * 2.399963
    local x, y = cx + r*math.cos(th), cy + r*math.sin(th)
    if m:at(x, y) > 0.3 then out[#out+1] = {x=x, y=y, a=th, n=n, r=r} end
  end
  return out
end
function CUTDIST(x, y)
  local e = math.sqrt(((x-543)/128)^2 + ((y-318)/190)^2)
  return (e - 1) * 150
end
PLATES = VOGEL(SPX, SPY, 11, 1400, BRONZE)
print(#PLATES)
for i, p in ipairs(PLATES) do
  local d = CUTDIST(p.x, p.y)
  local pl
  local r = math.random()
  if d < 35 then pl = (r < 0.5) and pb3 or pb1
  elseif d < 110 then pl = (r < 0.35) and pb3 or ((r < 0.7) and pb1 or pb2)
  else pl = (r < 0.5) and pb2 or pbD end
  PLATE_BODY(p.x, p.y, p.a, rand(19, 23), pl, BRONZE)
end

--@ chunk 16
print(wait(3*24*60)); for _,p in ipairs{{100,300},{900,300},{250,600},{545,30},{360,300},{700,450},{545,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 17
print(wait(4*24*60)); for _,p in ipairs{{100,300},{900,300},{545,30},{360,300},{700,450}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 18
pb1 = pile{{"raw sienna",2},{"bone black",1.2},{"burnt sienna",1}, medium=0.08}
pb2 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}, medium=0.08}
pbD = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"ultramarine blue",0.2}, medium=0.08}
pb3 = pile{{"burnt sienna",2},{"Mars brown",1},{"yellow ochre",0.8},{"bone black",0.6}, medium=0.08}
pshad = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}, medium=0.15}
-- body of one scale plate centred (x,y), radial direction ang (outward), size sz
function PLATE_BODY(x, y, ang, sz, pl, clipm)
  local c, s = math.cos(ang), math.sin(ang)
  local L = sz * 0.45
  local b = brush{kind="filbert", width=sz*1.12, stiffness=0.5}
  b:load(pl, 0.8)
  b:stroke({{x - c*L, y - s*L}, {x + c*L*0.5, y + s*L*0.5}},
    {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=clipm})
end
-- the shadow cast just outside a plate's free (outer) edge
function PLATE_SHADOW(x, y, ang, sz, clipm, w)
  local pts = {}
  local R = sz * 0.52
  for k = -3, 3 do
    local a = ang + k * 0.33
    pts[#pts+1] = {x + math.cos(ang)*sz*0.12 + math.cos(a)*R, y + math.sin(ang)*sz*0.12 + math.sin(a)*R}
  end
  local b = brush{kind="round", width=w or 5, point=0.2}
  b:load(pshad, 0.7)
  b:stroke(pts, {pressure={0.45, 0.75}, swell={0.5, 1, 0.5}, clip=clipm})
end
-- a glint on the plate's rim on the side facing (lx,ly)
function PLATE_GLINT(x, y, ang, sz, lx, ly, pl, amt, clipm)
  local a = math.atan(ly - y, lx - x)
  -- keep the glint on the outer (raised) half of the rim
  local R = sz * 0.42
  local pts = {}
  for k = -2, 2 do
    local b2 = a + k * 0.25
    pts[#pts+1] = {x + math.cos(b2)*R, y + math.sin(b2)*R}
  end
  local b = brush{kind="round", width=2.2, point=0.7}
  b:load(pl, 0.55)
  b:stroke(pts, {pressure={0.1, 0.55*amt + 0.1}, swell={0.4, 1, 0.3}, clip=clipm})
end
-- Vogel positions about (cx,cy), spacing c, inside mask m
function VOGEL(cx, cy, c, nmax, m)
  local out = {}
  for n = 1, nmax do
    local r = c * math.sqrt(n)
    local th = n * 2.399963
    local x, y = cx + r*math.cos(th), cy + r*math.sin(th)
    if m:at(x, y) > 0.3 then out[#out+1] = {x=x, y=y, a=th, n=n, r=r} end
  end
  return out
end
glit = pile{{"yellow ochre",2},{"burnt sienna",0.8},{"lead white",1.2}, medium=0.1}
ghot = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.3}, medium=0.1}
for i, p in ipairs(PLATES) do PLATE_SHADOW(p.x, p.y, p.a, 21, BRONZE) end
for i, p in ipairs(PLATES) do
  local d = CUTDIST(p.x, p.y)
  local amt = clamp(1 - d/140, 0, 1)
  if amt > 0.1 then PLATE_GLINT(p.x, p.y, p.a, 21, 543, 330, (amt > 0.75) and ghot or glit, amt, BRONZE) end
end

--@ chunk 19
-- the cut's faces, as (t,u) maps: t 0 front .. 1 back, u along the edge
function FACEPT(A, B, t, u)
  local x = A[1] + (B[1]-A[1])*u
  local y = A[2] + (B[2]-A[2])*u
  local k = 1 - 0.2*t
  return {VX + (x - VX)*k, VY + (y - VY)*k}
end
FACES = {
  left  = {{417,505},{416,330},{422,172}},
  ctl   = {{422,172},{452,131}},
  top   = {{452,131},{548,127},{632,133}},
  ctr   = {{632,133},{665,165}},
  right = {{665,165},{668,330},{671,506}},
  sill  = {{671,506},{545,509},{417,505}},
}
-- point on a face polyline at parameter u (0..1 over the whole polyline), depth t
function FPT(f, t, u)
  local n = #f - 1
  local seg = math.min(n - 1, math.floor(u * n))
  local lu = u * n - seg
  return FACEPT(f[seg+1], f[seg+2], t, lu)
end
function FACEMASK(f, t0, t1, u0, u1)
  local pts = {}
  for i = 0, 12 do pts[#pts+1] = FPT(f, t0, u0 + (u1-u0)*i/12) end
  for i = 12, 0, -1 do pts[#pts+1] = FPT(f, t1, u0 + (u1-u0)*i/12) end
  return poly(pts)
end
rv1 = pile{{"burnt sienna",2},{"yellow ochre",1},{"lead white",0.5},{"bone black",0.4}, medium=0.1}
rv2 = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}, medium=0.1}
rvD = pile{{"burnt sienna",2},{"Mars brown",1},{"bone black",0.8},{"yellow ochre",0.4}, medium=0.1}
local R = REVEAL:grow(1.5)
-- side faces & soffit: darker; sill: lit
local sides = (FACEMASK(FACES.left,-0.3,1.3,0,1) + FACEMASK(FACES.ctl,-0.3,1.3,0,1) + FACEMASK(FACES.top,-0.3,1.3,0,1)
   + FACEMASK(FACES.ctr,-0.3,1.3,0,1) + FACEMASK(FACES.right,-0.3,1.3,0,1)) * R
local sill = FACEMASK(FACES.sill,-0.3,1.3,0,1) * R - sides
SIDES, SILL = sides, sill
work(sides, {hand="body", pile=rvD, angle=TOVP, coverage=3, fill=true, clip=sides})
work(sill, {hand="body", pile=rv1, angle=TOVP, coverage=3, fill=true, clip=sill})
-- back part of each face catches more light
local backs = (FACEMASK(FACES.left,0.55,1.3,0,1) + FACEMASK(FACES.right,0.55,1.3,0,1) + FACEMASK(FACES.top,0.55,1.3,0,1)) * sides
work(backs, {hand="body", pile=rv1, angle=TOVP, coverage=2.5, fill=true, clip=sides})
local sb = FACEMASK(FACES.sill,0.45,1.3,0,1) * sill
work(sb, {hand="body", pile=rv2, angle=TOVP, coverage=2.5, fill=true, clip=sill})
blend(sides, {angle=TOVP}); blend(sill, {angle=TOVP})

--@ chunk 20
fl_far  = pile{{"lead white",3},{"yellow ochre",1.4},{"Mars orange",0.3}, medium=0.12}
fl_mid  = pile{{"yellow ochre",2},{"lead white",1.4},{"burnt sienna",0.6},{"raw sienna",0.4}, medium=0.12}
fl_near = pile{{"burnt sienna",1.5},{"yellow ochre",1.2},{"lead white",0.5},{"bone black",0.25}, medium=0.12}
HFLOOR = VIEW * below(function(x) return 316 end)
local a = HFLOOR * above(function(x) return 352 end)
local b = HFLOOR * below(function(x) return 350 end) * above(function(x) return 412 end)
local c = HFLOOR * below(function(x) return 410 end)
work(a, {hand="body", pile=fl_far, angle=0, coverage=3, fill=true, clip=HFLOOR})
work(b, {hand="body", pile=fl_mid, angle=0, coverage=3, fill=true, clip=HFLOOR})
work(c, {hand="body", pile=fl_near, angle=0, coverage=3, fill=true, clip=HFLOOR})
blend(HFLOOR, {angle=0})
-- the glow reflected in the polished floor under the far portal
local streak = poly({{536,318},{556,318},{572,440},{522,440}}, true):soften(6) * HFLOOR
work(streak, {hand="body", pile=i_glow, angle=math.pi/2, coverage=2.2, fill=true, clip=HFLOOR, tool="filbert 6"})
blend(streak:grow(8) * HFLOOR, {angle=math.pi/2})

--@ chunk 21
print(drying(545,400), drying(545,300))

--@ chunk 22
local wedge = poly({{541,318},{551,318},{556,430},{536,430}})
local zoneU = poly({{520,316},{575,316},{575,352},{520,352}}) * HFLOOR - wedge
local zoneM = poly({{510,350},{585,350},{585,412},{510,412}}) * HFLOOR - wedge
local zoneN = poly({{505,410},{590,410},{590,475},{505,475}}) * HFLOOR - wedge:shrink(3)
work(zoneU, {hand="body", pile=fl_far, angle=math.pi/2, coverage=3.5, fill=true, clip=zoneU, tool="filbert 6"})
work(zoneM, {hand="body", pile=fl_mid, angle=math.pi/2, coverage=3.5, fill=true, clip=zoneM, tool="filbert 6"})
work(zoneN, {hand="body", pile=fl_near, angle=math.pi/2, coverage=4, fill=true, clip=zoneN, tool="filbert 6"})
blend(poly({{500,316},{595,316},{595,475},{500,475}}) * HFLOOR, {angle=0})

--@ chunk 23
blend(HFLOOR, {angle=0}); blend(HFLOOR, {angle=0.15})

--@ chunk 24
function INSET(s, p)
  local a = SP(EX0 + p, EY0 + p, s); local b = SP(EX1 - p, EY1 + 40, s)
  return rect(a[1], a[2], b[1]-a[1], b[2]-a[2])
end
function FLOORCUT(s) return above(function(x) return VY + (EY1 - VY) * s end) end
ribF = pile{{"bone black",2},{"ultramarine blue",1},{"lead white",0.6},{"burnt sienna",0.3}, medium=0.08}
ribS1 = pile{{"lead white",2},{"bone black",0.7},{"yellow ochre",0.6},{"burnt sienna",0.15}, medium=0.08}
ribS2 = pile{{"lead white",1.2},{"bone black",1},{"yellow ochre",0.5},{"ultramarine ash",0.4}, medium=0.08}
ribS3 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.7},{"yellow ochre",0.3}, medium=0.08}
RIBS = {1.27, 1.66, 2.25}
RIBP = 20
for i = #RIBS, 1, -1 do
  local s = RIBS[i]
  local s2 = 6 / (6 / s + 0.22)
  local front = (RECTS(s) - INSET(s, RIBP)) * FLOORCUT(s)
  local soff = (INSET(s, RIBP) - INSET(s2, RIBP)) * FLOORCUT(s2)
  local spl = (i == 1) and ribS1 or ((i == 2) and ribS2 or ribS3)
  work(soff, {hand="body", pile=spl, angle=TOVP, coverage=3, fill=true, clip=soff})
  work(front, {hand="body", pile=ribF, angle=TOVP, coverage=3, fill=true, clip=front})
end

--@ chunk 25
print(wait(6*24*60)); for _,p in ipairs{{30,300},{100,300},{200,300},{280,300},{545,400},{430,300},{545,10}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 26
function RIBFRONT(s, p) p = p or RIBP; return (RECTS(s) - INSET(s, p)) * FLOORCUT(s) end
function RIBSOFF(s, p, d)
  p = p or RIBP
  local s2 = 6 / (6 / s + (d or 0.22))
  return (INSET(s, p) - INSET(s2, p)) * FLOORCUT(s2)
end
RIBALL = RIBFRONT(1.27) + RIBSOFF(1.27) + RIBFRONT(1.66) + RIBSOFF(1.66) + RIBFRONT(2.25) + RIBSOFF(2.25)
W0 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",1.0},{"burnt sienna",0.45}, medium=0.08}
W1 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.7},{"burnt sienna",0.35}, medium=0.08}
W2 = pile{{"bone black",2},{"ultramarine ash",1.1},{"lead white",0.45},{"burnt sienna",0.25}, medium=0.08}
W3 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.28}, medium=0.08}
local bays = {{1.0, 1.27, W0}, {1.27, 1.66, W1}, {1.66, 2.25, W2}, {2.25, 6, W3}}
local walls = LWALL + RWALL
for _, b in ipairs(bays) do
  local ring = RECTS(b[2]) - RECTS(b[1])
  local m = ring * walls - RIBALL
  work(m, {hand="body", pile=b[3], angle=TOVP, coverage=3, fill=true, clip=m})
end

--@ chunk 27
RF = pile{{"bone black",2},{"ultramarine blue",0.35},{"burnt sienna",0.5},{"lead white",0.25}, medium=0.08}
S1 = pile{{"lead white",1.2},{"bone black",1},{"burnt sienna",0.35},{"yellow ochre",0.15}, medium=0.08}
S2 = pile{{"lead white",0.75},{"bone black",1},{"burnt sienna",0.3},{"ultramarine ash",0.2}, medium=0.08}
S3 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.5},{"burnt sienna",0.35}, medium=0.08}
C0 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.7},{"burnt sienna",0.4}, medium=0.08}
C1 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.45},{"burnt sienna",0.3}, medium=0.08}
C2 = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.25},{"burnt sienna",0.2}, medium=0.08}
local bays = {{1.0, 1.27, C0}, {1.27, 1.66, C1}, {1.66, 6, C2}}
for _, b in ipairs(bays) do
  local m = (RECTS(b[2]) - RECTS(b[1])) * CEIL - RIBALL
  work(m, {hand="body", pile=b[3], angle=TOVP, coverage=3, fill=true, clip=m})
end
local sp = {S1, S2, S3}
for i, s in ipairs(RIBS) do
  local so = RIBSOFF(s)
  work(so, {hand="body", pile=sp[i], angle=TOVP, coverage=3, fill=true, clip=so})
  local fr = RIBFRONT(s)
  work(fr, {hand="body", pile=RF, angle=TOVP, coverage=3, fill=true, clip=fr})
end

--@ chunk 28
F_far  = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.55},{"burnt sienna",0.45}, medium=0.08}
F_near = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.22},{"burnt sienna",0.3}, medium=0.08}
L_hot  = pile{{"lead white",2},{"yellow ochre",1},{"burnt sienna",0.35},{"bone black",0.15}, medium=0.08}
L_warm = pile{{"lead white",1},{"yellow ochre",0.7},{"burnt sienna",0.4},{"bone black",0.4}, medium=0.08}
local FL = FLOOR - RIBALL
local far = FL * RECTS(1.38)
local near = FL - RECTS(1.38)
work(far, {hand="body", pile=F_far, angle=TOVP, coverage=3, fill=true, clip=FL})
work(near, {hand="body", pile=F_near, angle=TOVP, coverage=3, fill=true, clip=FL})
blend(FL * (RECTS(1.55) - RECTS(1.22)), {angle=0})
-- the light carpet thrown through the cut
PATCH = poly({{417,519},{671,519},{789,667},{301,667}}):soften(3) * FL
local ph = PATCH * above(function(x) return 572 end)
local pw = PATCH * below(function(x) return 570 end)
work(ph, {hand="body", pile=L_hot, angle=TOVP, coverage=3, fill=true, clip=PATCH})
work(pw, {hand="body", pile=L_warm, angle=TOVP, coverage=3, fill=true, clip=PATCH})
blend(PATCH * (below(function(x) return 545 end) * above(function(x) return 600 end)), {angle=0})

--@ chunk 29
blend(PATCH, {angle=TOVP}); blend(PATCH, {angle=0.0})

--@ chunk 30
print(wait(6*24*60)); for _,p in ipairs{{30,300},{545,600},{545,540},{300,620},{200,40},{545,400}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 31
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
-- seating plan
ROWZ = {12, 15.5, 19.5, 24, 29.5, 36, 44}
CHAIRS = {}
for ri, Z in ipairs(ROWZ) do
  local lim = 0.095 * Z + 0.6
  local j = 0
  for side = -1, 1, 2 do
    local X = side * 0.95
    local idx = 0
    while math.abs(X) < lim do
      local Zc = 60; local rho = Zc - Z
      local Zp = Zc - math.sqrt(math.max(rho*rho - X*X, 1))
      CHAIRS[#CHAIRS+1] = {X=X, Z=Zp, row=ri, v=CHAIRVAR(ri*17 + side*idx*3 + 11)}
      idx = idx + 1
      X = X + side * (1.12 + 0.06 * (((ri + idx) * 0.618) % 1))
    end
  end
end
print(#CHAIRS)
FIGX, FIGZ = -0.25, 14
-- reflected glow in the polished floor, a narrow streak under the far portal
local streak = poly({{543,317},{548,317},{556,440},{535,440}}):soften(4) * HFLOOR
work(streak, {hand="detail", pile=i_glow, coverage=2, fill=true, clip=HFLOOR, pressure={0.3,0.6}})
-- shadows thrown toward us by each chair
shF = pile{{"burnt sienna",1},{"yellow ochre",0.8},{"bone black",0.35},{"lead white",0.3}, medium=0.3}
local SH = nil
for _, c in ipairs(CHAIRS) do
  local a1, b1 = W2C(c.X - 0.3, 0, c.Z); local a2, b2 = W2C(c.X + 0.3, 0, c.Z)
  local a3, b3 = W2C(c.X + 0.3, 0, c.Z - 3.2); local a4, b4 = W2C(c.X - 0.3, 0, c.Z - 3.2)
  local m = poly({{a1,b1},{a2,b2},{a3,b3},{a4,b4}})
  SH = SH and (SH + m) or m
end
-- the figure's long shadow, through the cut and down the corridor floor
local f1x, f1y = W2C(FIGX - 0.22, 0, FIGZ); local f2x, f2y = W2C(FIGX + 0.22, 0, FIGZ)
local f3x, f3y = W2C(FIGX + 0.3, 0, 3.4); local f4x, f4y = W2C(FIGX - 0.3, 0, 3.4)
FIGSH = poly({{f1x,f1y},{f2x,f2y},{f3x,f3y},{f4x,f4y}}):soften(2)
print(f1x, f1y, f3x, f3y)
SH = SH:soften(2) * HFLOOR
work(SH, {hand="detail", pile=shF, coverage=2.2, fill=true, clip=SH})

--@ chunk 32
blend(HFLOOR, {angle=TOVP}); local st = poly({{538,317},{553,317},{566,445},{525,445}}):soften(6) * HFLOOR; blend(st, {angle=0})

--@ chunk 33
print(wait(5*24*60)); for _,p in ipairs{{545,400},{480,400},{600,350}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 34
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
chFar = pile{{"burnt sienna",1},{"yellow ochre",1.4},{"lead white",1.0}, medium=0.1}
chMid = pile{{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.5},{"bone black",0.35}, medium=0.1}
chNear = pile{{"burnt sienna",1},{"yellow ochre",0.7},{"Mars brown",0.4},{"lead white",0.3},{"bone black",0.35}, medium=0.1}
for ri = #ROWZ, 1, -1 do
  local Z = ROWZ[ri]
  local pl = (ri >= 5) and chFar or ((ri >= 3) and chMid or chNear)
  local m = nil
  local list = {}
  for _, c in ipairs(CHAIRS) do
    if c.row == ri then
      list[#list+1] = c
      local cm = CHAIRMASK(c.X, c.Z, c.v)
      m = m and (m + cm) or cm
    end
  end
  local k = 175*6/Z
  local b = brush{kind="round", width=math.max(1.0, 0.045*k), point=0.3}
  b:load(pl, 0.9)
  for _, c in ipairs(list) do CHAIRLEGS(b, c.X, c.Z, c.v, nil, nil, VIEW); b:load(pl, 0.9) end
  m = m * VIEW
  work(m, {hand="detail", pile=pl, coverage=3, fill=true, clip=m})
end

--@ chunk 35
COLS = 1.035
COLLAR = RIBFRONT(COLS, 22)
COLSOFF = RIBSOFF(COLS, 22, 0.21) * ENDW:grow(30)
amberD = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.4},{"bone black",0.2}, medium=0.08}
hzBlack = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.4},{"lead white",0.1}, medium=0.08}
csoff = pile{{"lead white",1.3},{"bone black",0.8},{"burnt sienna",0.45},{"yellow ochre",0.3}, medium=0.08}
work(COLSOFF, {hand="body", pile=csoff, angle=TOVP, coverage=3, fill=true, clip=COLSOFF})
work(COLLAR, {hand="body", pile=amberD, angle=TOVP, coverage=3.5, fill=true, clip=COLLAR})
print(COLSOFF:area(), COLLAR:area())

--@ chunk 36
print(wait(3*24*60)); for _,p in ipairs{{340,300},{750,300},{480,380},{600,360}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 37
local b = brush{kind="flat", width=8.5, stiffness=0.6}
local n = 0
local function st(x0, y0, x1, y1)
  b:load(hzBlack, 0.85)
  b:stroke({{x0, y0}, {x1, y1}}, {pressure={0.8, 0.75}, orient="across", clip=COLLAR, shake=0.6})
  n = n + 1
end
for y = 70, 540, 18 do st(316, y, 352, y + 36) end          -- left post
for y = 70, 540, 18 do st(774, y, 738, y + 36) end          -- right post
for x = 300, 800, 18 do st(x, 86, x + 36, 122) end          -- head beam
print(n)

--@ chunk 38
WX = 215 / 175
function LWP(s, h) return {VX - 215 * s, VY + (1.2 - h) * 175 * s} end
function RWP(s, h) return {VX + 215 * s, VY + (1.2 - h) * 175 * s} end
function CLP(s, X) return {VX + X * 175 * s, VY - 210 * s} end
function FLP(s, X) return {VX + X * 175 * s, VY + 210 * s} end
CORR = -ENDW
-- dead light panels in the ceiling
lpFrame = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.2}, medium=0.08}
lpGlass = pile{{"bone black",2},{"viridian",0.3},{"ultramarine ash",0.8},{"lead white",0.5}, medium=0.08}
lpRefl = pile{{"lead white",1},{"bone black",0.6},{"burnt sienna",0.4},{"yellow ochre",0.4}, medium=0.08}
for _, pz in ipairs{{1.06, 1.21}, {1.36, 1.58}} do
  local a, b = pz[1], pz[2]
  local fr = poly({CLP(a, -0.42), CLP(a, 0.42), CLP(b, 0.42), CLP(b, -0.42)})
  local gl = poly({CLP(a + 0.01, -0.36), CLP(a + 0.01, 0.36), CLP(b - 0.012, 0.36), CLP(b - 0.012, -0.36)})
  fr = fr * CEIL - RIBALL; gl = gl * CEIL - RIBALL
  work(fr, {hand="detail", pile=lpFrame, coverage=3, fill=true, clip=fr})
  work(gl, {hand="detail", pile=lpGlass, coverage=3, fill=true, clip=gl})
  -- the warm glow of the cut caught in the glass, on its far half
  local rf = poly({CLP(a + 0.01, -0.3), CLP(a + 0.01, 0.3), CLP(a + (b-a)*0.45, 0.22), CLP(a + (b-a)*0.45, -0.22)}):soften(3) * gl
  work(rf, {hand="detail", pile=lpRefl, coverage=1.6, fill=false, clip=gl, pressure={0.3, 0.5}})
end

--@ chunk 39
pipeD = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.35},{"burnt sienna",0.3}, medium=0.08}
pipeHi = pile{{"lead white",1.2},{"bone black",0.7},{"burnt sienna",0.4},{"yellow ochre",0.35}, medium=0.08}
local WALLV = (RWALL + LWALL) - RIBALL - COLLAR
function PIPE(side, h, dia, hi)
  local pts, wd, top = {}, {}, {}
  local X = side * (WX - 0.06)
  for i = 0, 30 do
    local s = 1.0 + i * 0.08
    pts[#pts+1] = {VX + X * 175 * s, VY + (1.2 - h) * 175 * s}
    wd[#wd+1] = dia * 175 * s
    top[#top+1] = {VX + (X - side*0.012) * 175 * s, VY + (1.2 - h - dia*0.3) * 175 * s}
  end
  local m = ribbon(pts, wd) * WALLV
  work(m, {hand="detail", pile=pipeD, coverage=3, fill=true, clip=m})
  return top, m
end
PIPES = {}
for _, p in ipairs{{1, 2.06, 0.075}, {1, 2.2, 0.05}, {1, 0.28, 0.09}, {-1, 2.16, 0.06}} do
  local top, m = PIPE(p[1], p[2], p[3])
  PIPES[#PIPES+1] = {top=top, m=m, dia=p[3]}
end

--@ chunk 40
print(wait(4*24*60)); for _,p in ipairs{{334,300},{334,200},{760,300},{900,190},{545,600},{450,350}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 41
print(wait(5*24*60)); for _,p in ipairs{{334,300},{334,200},{760,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 42
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
for _,p in ipairs{{470,340},{620,340},{526,380}} do print(p[1],p[2],drying(p[1],p[2])) end
FIGX, FIGZ = -0.25, 14
shFig = pile{{"burnt sienna",1},{"bone black",0.8},{"yellow ochre",0.4},{"ultramarine blue",0.2},{"lead white",0.15}, medium=0.25}
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local near = poly({Wc(FIGX-0.16, 14), Wc(FIGX+0.16, 14), Wc(FIGX+0.2, 9.5), Wc(FIGX-0.2, 9.5)}):soften(1)
local far = poly({Wc(FIGX-0.2, 9.6), Wc(FIGX+0.2, 9.6), Wc(FIGX+0.27, 3.3), Wc(FIGX-0.27, 3.3)}):soften(4)
local where = HFLOOR + REVEAL + FLOOR
SHN = near * where; SHF = far * where
work(SHN, {hand="detail", pile=shFig, coverage=2.5, fill=true, clip=SHN})
work(SHF, {hand="body", tool="filbert 5", pile=shFig, angle=TOVP, coverage=2.2, fill=true, clip=SHF})

--@ chunk 43
local w = HFLOOR + REVEAL + FLOOR; local a = SHF:grow(40) * w; blend(a, {angle=0}); blend(a, {angle=0.3}); blend(a, {angle=-0.3}); local b = SHN:grow(10) * w; blend(b, {angle=0})

--@ chunk 44
print(wait(6*24*60)); for _,p in ipairs{{480,500},{480,600},{500,420},{334,300},{760,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 45
local b = brush{kind="flat", width=7, stiffness=0.6}
local function st(x0, y0, x1, y1)
  b:load(amberD, 0.85)
  b:stroke({{x0, y0}, {x1, y1}}, {pressure={0.75, 0.7}, orient="across", clip=COLLAR, shake=0.6})
end
for y = 70, 540, 18 do st(316, y + 10, 352, y + 46) end
for y = 70, 540, 18 do st(774, y + 10, 738, y + 46) end
for x = 300, 800, 18 do st(x + 10, 86, x + 46, 122) end

--@ chunk 46
-- hall floor near the threshold, repainted
local hn = HFLOOR * below(function(x) return 392 end)
local hm = HFLOOR * below(function(x) return 380 end) * above(function(x) return 430 end)
work(hn, {hand="body", pile=fl_near, angle=0, coverage=3.5, fill=true, clip=hn})
work(hm, {hand="body", pile=fl_mid, angle=0, coverage=2.5, fill=true, clip=hm})
-- the aisle's reflected light continues toward the threshold, fading
local st = poly({{532,392},{556,392},{562,470},{522,470}}):soften(5) * HFLOOR
work(st, {hand="body", tool="filbert 6", pile=fl_far, angle=math.pi/2, coverage=2, fill=true, clip=st})
blend(HFLOOR * below(function(x) return 375 end), {angle=0.0})
-- the sill
work(SILL, {hand="body", pile=rv1, angle=TOVP, coverage=3, fill=true, clip=SILL})
local sb = FACEMASK(FACES.sill,0.45,1.3,0,1) * SILL
work(sb, {hand="body", pile=rv2, angle=TOVP, coverage=2.5, fill=true, clip=SILL})
blend(SILL, {angle=0})

--@ chunk 47
L_hot2 = pile{{"lead white",2},{"yellow ochre",1.1},{"burnt sienna",0.4},{"bone black",0.12}, medium=0.08}
L_mid2 = pile{{"lead white",1.2},{"yellow ochre",0.8},{"burnt sienna",0.45},{"bone black",0.35}, medium=0.08}
L_low2 = pile{{"bone black",1},{"burnt sienna",0.6},{"yellow ochre",0.5},{"lead white",0.6},{"ultramarine ash",0.3}, medium=0.08}
local P = PATCH
local a = P * above(function(x) return 565 end)
local b = P * below(function(x) return 555 end) * above(function(x) return 625 end)
local c = P * below(function(x) return 615 end)
work(a, {hand="body", pile=L_hot2, angle=TOVP, coverage=3.5, fill=true, clip=P})
work(b, {hand="body", pile=L_mid2, angle=TOVP, coverage=3.5, fill=true, clip=P})
work(c, {hand="body", pile=L_low2, angle=TOVP, coverage=3.5, fill=true, clip=P})
-- the frame's long shadow: a darker band down the light, along the rays
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local fs = poly({Wc(FIGX-0.17, 6.05), Wc(FIGX+0.17, 6.05), Wc(FIGX+0.22, 3.3), Wc(FIGX-0.22, 3.3)}) * P
work(fs, {hand="body", tool="filbert 6", pile=L_low2, angle=TOVP, coverage=2.5, fill=true, clip=fs})
blend(P, {angle=TOVP})

--@ chunk 48
print(wait(3*24*60)); for _,p in ipairs{{545,600},{545,440},{545,500}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 49
seamD = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.1}
seamL = pile{{"lead white",2},{"yellow ochre",0.9},{"burnt sienna",0.3}, medium=0.08}
local FLV = FLOOR - RIBALL
local rb = brush{kind="round", width=1.6, point=0.3}
local function line(pts, pl, pr, w)
  local b = brush{kind="round", width=w, point=0.2}
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr, clip=FLV, shake=0.4})
end
-- transverse plate seams
for _, s in ipairs{1.11, 1.29, 1.52} do
  local y = VY + 210 * s
  line({{VX - 215*s, y}, {VX + 215*s, y}}, seamD, {0.6, 0.6}, 1.2 * s)
  -- the lit lip on the far side of each seam where the light falls
  local xa, xb = 545 - 160*s*1.05, 545 + 160*s*1.05
  line({{xa, y - 1.2*s}, {xb, y - 1.2*s}}, seamL, {0.35, 0.35}, 0.8 * s)
end
-- longitudinal seams
for _, X in ipairs{-0.62, 0.62} do
  line({FLP(1.0, X), FLP(1.75, X)}, seamD, {0.5, 0.7}, 1.6)
end

--@ chunk 50
cabD = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3},{"lead white",0.1}, medium=0.1}
cabHi = pile{{"lead white",2},{"yellow ochre",0.8},{"burnt sienna",0.3},{"bone black",0.2}, medium=0.08}
CABLES = {
  {{462,472},{452,490},{438,506},{424,522},{405,545},{385,570},{372,600},{350,635},{318,667}},
  {{470,472},{461,492},{448,510},{436,528},{424,552},{418,580},{396,612},{372,640},{352,667}},
  {{455,474},{442,494},{428,512},{410,528},{392,538},{376,548},{366,560}},
  {{632,472},{644,492},{654,510},{664,526},{680,548},{700,580},{716,620},{728,667}},
}
local where = HFLOOR + REVEAL + FLOOR + ENDW
for i, c in ipairs(CABLES) do
  local w = (i == 3) and 4 or 6.5
  local b = brush{kind="round", width=w, point=0.6, stiffness=0.4}
  b:load(cabD, 0.95)
  b:stroke(c, {pressure={0.25, 0.85}, clip=where, shake=0.3})
end

--@ chunk 51
local where = HFLOOR + REVEAL + FLOOR + ENDW
function CABLE(c, w0, w1, hi)
  local n = #c
  for i = 1, n - 1 do
    local t = (i - 0.5) / (n - 1)
    local w = lerp(w0, w1, t)
    local b = brush{kind="round", width=w, stiffness=0.4}
    b:load(cabD, 0.95)
    local a, z = c[i], c[i+1]
    -- overlap the segments a little
    local ex, ey = (z[1]-a[1])*0.15, (z[2]-a[2])*0.15
    b:stroke({{a[1]-ex, a[2]-ey}, {z[1]+ex, z[2]+ey}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, clip=where})
  end
end
CABLE(CABLES[1], 3, 9)
CABLE(CABLES[2], 3, 8)
CABLE(CABLES[3], 2.5, 5)
CABLE(CABLES[4], 3, 8)

--@ chunk 52
board = pile{{"lead white",1.4},{"bone black",0.32},{"yellow ochre",0.35},{"burnt sienna",0.08}, medium=0.08}
redp = pile{{"vermilion",1},{"burnt sienna",0.6},{"bone black",0.15}, medium=0.1}
ink = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.15}
yel = pile{{"cadmium yellow",1.5},{"yellow ochre",0.8},{"bone black",0.12}, medium=0.08}
-- the hand-painted board, hung a little out of true
PLAC = poly({{356,236},{410,231},{413,300},{359,305}})
work(PLAC, {hand="detail", pile=board, coverage=4, fill=true, clip=PLAC})
-- the printed sign on the right
SIGN = poly({{684,206},{727,205},{728,252},{685,253}})
work(SIGN, {hand="detail", pile=yel, coverage=4, fill=true, clip=SIGN})

--@ chunk 53
print(wait(2*24*60)); for _,p in ipairs{{380,270},{705,230},{420,600},{690,600}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 54
-- letter-like marks along a line, by hand
function SCRIBBLE(x0, y0, x1, y1, h, pl, w, clipm, gaps)
  local b = brush{kind="round", width=w or 1.3, point=0.8}
  b:load(pl, 0.7)
  local len = math.sqrt((x1-x0)^2 + (y1-y0)^2)
  local ux, uy = (x1-x0)/len, (y1-y0)/len
  local vx, vy = -uy, ux
  local t, n = 0, 0
  while t < len do
    local cw = h * rand(0.45, 0.8)
    if gaps and math.random() < 0.18 then t = t + cw * 0.9 else
      local x, y = x0 + ux*t, y0 + uy*t
      local kind = math.random(1, 5)
      local function P(a, c) return {x + ux*a*cw + vx*c*h, y + uy*a*cw + vy*c*h} end
      if kind == 1 then b:stroke({P(0.1,-0.5), P(0.15,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.15,-0.5), P(0.75,-0.45)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 2 then b:stroke({P(0.1,0.5), P(0.4,-0.5), P(0.75,0.5)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 3 then b:stroke({P(0.7,-0.4), P(0.2,-0.5), P(0.15,0.4), P(0.7,0.5)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 4 then b:stroke({P(0.2,-0.5), P(0.2,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.6,-0.5), P(0.6,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.2,0.0), P(0.6,0.0)}, {pressure={0.5,0.5}, clip=clipm})
      else b:stroke({P(0.15,0.5), P(0.45,-0.5), P(0.75,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.3,0.1), P(0.6,0.1)}, {pressure={0.5,0.5}, clip=clipm}) end
      t = t + cw
      n = n + 1
      if n % 6 == 0 then b:load(pl, 0.7) end
    end
  end
end
-- the board: a red hand-painted border and its warning
local rb = brush{kind="round", width=2.6, point=0.4}
rb:load(redp, 0.8)
rb:stroke({{359,239},{408,234},{410,298},{362,302},{359,239}}, {pressure={0.7,0.6}, clip=PLAC, shake=1})
-- a big hand-lettered first line, then smaller lines
SCRIBBLE(366, 250, 404, 247, 8, redp, 1.8, PLAC)
SCRIBBLE(366, 263, 404, 260, 5, ink, 1.1, PLAC, true)
SCRIBBLE(366, 272, 403, 269, 5, ink, 1.1, PLAC, true)
SCRIBBLE(367, 281, 400, 279, 5, ink, 1.1, PLAC, true)
SCRIBBLE(367, 291, 392, 289, 4, ink, 1.0, PLAC, true)
-- the printed sign: a black-edged triangle, a mark, a text bar
local tri = poly({{706,211},{723,240},{689,240}})
local trin = poly({{706,217},{718,237},{694,237}})
work(tri - trin, {hand="detail", pile=ink, coverage=3, fill=true, clip=tri - trin})
local kb = brush{kind="round", width=2, point=0.5}
kb:load(ink, 0.8)
kb:stroke({{706,222},{706,231}}, {pressure={0.7,0.4}, clip=SIGN})
kb:touch(706, 234.5, {pressure=0.5, clip=SIGN})
local bar = rect(686, 243, 41, 8) * SIGN
work(bar, {hand="detail", pile=ink, coverage=3, fill=true, clip=bar})

--@ chunk 55
for _,p in ipairs{{470,350},{620,350},{540,420}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 56
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
chN2 = pile{{"burnt sienna",1},{"Mars brown",0.6},{"yellow ochre",0.5},{"bone black",0.45},{"lead white",0.2}, medium=0.08}
chM2 = pile{{"burnt sienna",1},{"yellow ochre",0.9},{"lead white",0.45},{"bone black",0.35}, medium=0.08}
chF2 = pile{{"burnt sienna",1},{"yellow ochre",1.3},{"lead white",0.9},{"bone black",0.1}, medium=0.08}
contact = pile{{"burnt sienna",1},{"bone black",0.7},{"yellow ochre",0.3}, medium=0.2}
for ri = #ROWZ, 1, -1 do
  local Z = ROWZ[ri]
  local pl = (ri >= 5) and chF2 or ((ri >= 3) and chM2 or chN2)
  local m, cs = nil, nil
  local list = {}
  for _, c in ipairs(CHAIRS) do
    if c.row == ri then
      list[#list+1] = c
      local cm = CHAIRMASK(c.X, c.Z, c.v)
      m = m and (m + cm) or cm
      local x, y, k = W2C(c.X, 0, c.Z)
      local e = ellipse(x, y - 0.01*k, 0.4*k, 0.06*k)
      cs = cs and (cs + e) or e
    end
  end
  local k = 175*6/Z
  cs = cs:soften(0.03*k) * HFLOOR
  work(cs, {hand="detail", pile=contact, coverage=2, fill=true, clip=cs, pressure={0.3,0.5}})
  local b = brush{kind="round", width=math.max(1.0, 0.05*k), stiffness=0.5}
  for _, c in ipairs(list) do b:load(pl, 0.9); CHAIRLEGS(b, c.X, c.Z, c.v, nil, nil, VIEW) end
  m = m * VIEW
  work(m, {hand="detail", pile=pl, coverage=4, fill=true, clip=m})
end

--@ chunk 57
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local cs = nil
for _, c in ipairs(CHAIRS) do
  local x, y, k = W2C(c.X, 0, c.Z)
  local e = ellipse(x, y - 0.01*k, 0.55*k, 0.12*k)
  cs = cs and (cs + e) or e
end
cs = cs * HFLOOR
blend(cs, {angle=0})
blend(cs, {angle=0})

--@ chunk 58
print(wait(7*24*60)); for _,p in ipairs{{470,350},{620,400},{540,420},{480,330},{380,270},{420,600}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 59
local H = HFLOOR
local a = H * above(function(x) return 346 end)
local b = H * below(function(x) return 344 end) * above(function(x) return 396 end)
local c = H * below(function(x) return 394 end)
work(a, {hand="body", pile=fl_far, angle=0, coverage=4, fill=true, clip=H, tool="filbert 6"})
work(b, {hand="body", pile=fl_mid, angle=0, coverage=4, fill=true, clip=H})
work(c, {hand="body", pile=fl_near, angle=0, coverage=4, fill=true, clip=H})
blend(H * below(function(x) return 336 end) * above(function(x) return 356 end), {angle=0})
blend(H * below(function(x) return 384 end) * above(function(x) return 406 end), {angle=0})

--@ chunk 60
print(wait(2*24*60)); for _,p in ipairs{{470,350},{620,400},{540,440}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 61
print(wait(4*24*60)); for _,p in ipairs{{470,350},{620,400},{540,440}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 62
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local st = poly({{542,317},{549,317},{555,470},{535,470}}):soften(3) * HFLOOR
work(st, {hand="body", tool="filbert 4", pile=i_glow, angle=math.pi/2, coverage=1.6, fill=false, clip=st, pressure={0.3,0.5}})
blend(st, {angle=math.pi/2})
for ri = #ROWZ, 1, -1 do
  local Z = ROWZ[ri]
  local pl = (ri >= 5) and chF2 or ((ri >= 3) and chM2 or chN2)
  local m = nil
  local list = {}
  for _, c in ipairs(CHAIRS) do
    if c.row == ri then
      list[#list+1] = c
      local cm = CHAIRMASK(c.X, c.Z, c.v)
      m = m and (m + cm) or cm
    end
  end
  local k = 175*6/Z
  local b = brush{kind="round", width=math.max(1.0, 0.05*k), stiffness=0.5}
  for _, c in ipairs(list) do b:load(pl, 0.9); CHAIRLEGS(b, c.X, c.Z, c.v, nil, nil, VIEW) end
  m = m * VIEW
  local tw = math.max(1.5, math.min(5, 0.12 * k))
  work(m, {hand="body", tool="filbert " .. string.format("%.1f", tw), pile=pl, angle=math.pi/2, coverage=4, fill=true, clip=m})
end

--@ chunk 63
local st = poly({{538,317},{553,317},{566,470},{524,470}}):soften(4) * HFLOOR; blend(st, {angle=0}); local lo = poly({{530,400},{560,400},{570,470},{520,470}}) * HFLOOR; blend(lo, {angle=0.2}); blend(lo, {angle=-0.2})

--@ chunk 64
print(wait(2*24*60)); for _,p in ipairs{{526,400},{545,380},{526,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 65
-- the Commando's frame, seen from behind; local metres, origin between the feet, y up
function FIGPARTS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  local parts = {}
  -- legs (ribbons), slightly apart, weight on the right leg
  parts.legL = ribbon({P(-0.11,0.93), P(-0.15,0.52), P(-0.17,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.legR = ribbon({P(0.11,0.93), P(0.12,0.52), P(0.13,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.boots = poly({P(-0.25,0.0), P(-0.09,0.0), P(-0.1,0.13), P(-0.23,0.13)}) + poly({P(0.06,0.0), P(0.22,0.0), P(0.2,0.13), P(0.07,0.13)})
  parts.pelvis = poly({P(-0.19,0.88), P(0.19,0.88), P(0.2,1.06), P(-0.2,1.06)}, true)
  -- torso widening to armoured shoulders
  parts.torso = poly({P(-0.17,1.02), P(0.17,1.02), P(0.23,1.32), P(0.30,1.5), P(0.27,1.58), P(0.1,1.6), P(-0.1,1.6), P(-0.27,1.58), P(-0.3,1.5), P(-0.23,1.32)}, true)
  -- the power pack on the back, a squarer slab
  parts.pack = poly({P(-0.17,1.12), P(0.16,1.12), P(0.18,1.52), P(-0.18,1.53)})
  parts.neck = poly({P(-0.05,1.55), P(0.05,1.55), P(0.05,1.66), P(-0.05,1.66)})
  -- the helmet: narrow, a little tall, with a crest
  parts.head = ellipse(fx + 0.0*k, fy - 1.75*k, 0.105*k, 0.13*k) + poly({P(-0.02,1.86), P(0.02,1.86), P(0.015,1.92), P(-0.015,1.92)})
  -- arms: left hangs, right carries the rifle low
  parts.armL = ribbon({P(-0.29,1.5), P(-0.34,1.22), P(-0.31,0.95)}, {0.12*k, 0.1*k, 0.09*k})
  parts.armR = ribbon({P(0.29,1.5), P(0.35,1.23), P(0.29,1.03)}, {0.12*k, 0.1*k, 0.09*k})
  parts.rifle = ribbon({P(0.18,1.14), P(0.33,0.92), P(0.47,0.55)}, {0.06*k, 0.055*k, 0.035*k})
  return parts
end
function FIGMASK(fx, fy, k)
  local m = nil
  for _, part in pairs(FIGPARTS(fx, fy, k)) do m = m and (m + part) or part end
  return m
end
-- the lit outline: points along the right-hand (glow-side) edges and the tops
function FIGRIMS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  return {
    head = {P(-0.07,1.84), P(0.0,1.885), P(0.07,1.85), P(0.1,1.78), P(0.1,1.7)},
    shoulderR = {P(0.1,1.6), P(0.24,1.58), P(0.3,1.52), P(0.36,1.3), P(0.36,1.2)},
    shoulderL = {P(-0.1,1.6), P(-0.24,1.585), P(-0.3,1.52)},
    armL = {P(-0.35,1.4), P(-0.36,1.2), P(-0.34,1.0)},
    legR = {P(0.19,0.9), P(0.18,0.55), P(0.18,0.15)},
    rifle = {P(0.36,0.92), P(0.48,0.6)},
  }
end
figD = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4},{"lead white",0.1}, medium=0.08}
FIGFX, FIGFY, FIGK = 526, 400, 75
-- the shadow at his feet, running toward us
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local fsh = poly({Wc(FIGX-0.2, 14.05), Wc(FIGX+0.2, 14.05), Wc(FIGX+0.21, 11.2), Wc(FIGX-0.21, 11.2)}):soften(1.5) * HFLOOR
work(fsh, {hand="body", tool="filbert 3", pile=shFig, angle=TOVP, coverage=2, fill=true, clip=fsh, pressure={0.4,0.6}})
FIGM = FIGMASK(FIGFX, FIGFY, FIGK)
work(FIGM, {hand="body", tool="filbert 3", pile=figD, angle=math.pi/2, coverage=4, fill=true, clip=FIGM})

--@ chunk 66
instD = pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.5},{"burnt sienna",0.2}, medium=0.08}
instM = pile{{"lead white",1},{"bone black",0.7},{"ultramarine ash",0.4},{"burnt sienna",0.15}, medium=0.08}
instL = pile{{"lead white",1.6},{"bone black",0.45},{"yellow ochre",0.4},{"burnt sienna",0.2}, medium=0.08}
-- tripod legs
local lb = brush{kind="round", width=3, stiffness=0.6}
for _, leg in ipairs{{{372,350},{339,545}}, {{380,352},{406,541}}, {{376,352},{385,528}}} do
  lb:load(instD, 0.9)
  lb:stroke(leg, {pressure={0.7, 0.6}})
end
-- the sensor head: a box, its lit face toward the cut, a lens snout
TRIHEAD = poly({{352,322},{392,320},{396,352},{354,355}})
local lit = poly({{392,320},{401,324},{404,349},{396,352}})
local snout = poly({{401,330},{414,331},{414,343},{402,344}})
work(TRIHEAD, {hand="detail", pile=instM, coverage=4, fill=true, clip=TRIHEAD})
work(lit, {hand="detail", pile=instL, coverage=4, fill=true, clip=lit})
work(snout, {hand="detail", pile=instD, coverage=4, fill=true, clip=snout})
-- the scraper: a rail bolted up the right of the cut, a carriage, an arm into the cut
RAIL = poly({{681,150},{688,150},{690,480},{683,480}})
work(RAIL, {hand="detail", pile=instD, coverage=4, fill=true, clip=RAIL})
CARR = poly({{676,318},{697,317},{698,346},{677,347}})
work(CARR, {hand="detail", pile=instM, coverage=4, fill=true, clip=CARR})
local arm = brush{kind="round", width=3.5, stiffness=0.6}
arm:load(instD, 0.9)
arm:stroke({{680,330},{668,338},{658,346}}, {pressure={0.8,0.7}})
-- sensor pods clamped on the bronze
PODS = poly({{360,140},{385,139},{386,160},{361,161}}) + poly({{700,430},{722,429},{723,452},{701,453}}) + poly({{712,170},{730,170},{731,186},{713,186}})
work(PODS, {hand="detail", pile=instM, coverage=4, fill=true, clip=PODS})

--@ chunk 67
rawcut = pile{{"yellow ochre",2},{"burnt sienna",0.6},{"lead white",1.1},{"Mars orange",0.25}, medium=0.08}
cavD = pile{{"Mars brown",1},{"bone black",0.8},{"burnt sienna",0.6}, medium=0.1}
-- a chamber cell on a face, in (t,u), with bowed septa
function CELLMASK(f, t0, t1, ua, ub, bow)
  local pts = {}
  local n = 10
  for i = 0, n do local t = t0 + (t1-t0)*i/n; pts[#pts+1] = FPT(f, t, ua + bow*math.sin(math.pi*(t-t0)/(t1-t0))) end
  for i = n, 0, -1 do local t = t0 + (t1-t0)*i/n; pts[#pts+1] = FPT(f, t, ub + bow*math.sin(math.pi*(t-t0)/(t1-t0))) end
  return poly(pts, true)
end
local R = REVEAL:grow(1)
-- skins: the cut through the plate armour, front and back
local skins = nil
for _, key in ipairs{"left","ctl","top","ctr","right","sill"} do
  local f = FACES[key]
  local m = FACEMASK(f, -0.2, 0.12, 0, 1) + FACEMASK(f, 0.88, 1.2, 0, 1)
  skins = skins and (skins + m) or m
end
skins = skins * R
work(skins, {hand="body", tool="filbert 3", pile=rawcut, angle=TOVP, coverage=3.5, fill=true, clip=skins})
-- chambers, growing along the spiral: up the left, across the top, down the right, back along the sill
CELLS = nil
local seq = {{"sill", 1, 0.5}, {"left", 0, 1}, {"ctl", 0, 1}, {"top", 0, 1}, {"ctr", 0, 1}, {"right", 0, 1}, {"sill", 0, 0.5}}
local size = 0.05
local gap = 0.22
for _, sgm in ipairs(seq) do
  local f = FACES[sgm[1]]
  -- length of this face's edge in canvas units
  local L = 0
  for i = 1, #f - 1 do L = L + math.sqrt((f[i+1][1]-f[i][1])^2 + (f[i+1][2]-f[i][2])^2) end
  local u = sgm[2]
  local dir = (sgm[3] > sgm[2]) and 1 or -1
  local cellu = 20 / L
  while (dir > 0 and u < sgm[3]) or (dir < 0 and u > sgm[3]) do
    local cw = cellu * (1 + 0.35 * math.sin(u * 5.1 + #sgm[1]))
    local ua, ub = u, u + dir * cw * (1 - gap)
    if dir < 0 then ua, ub = ub, ua end
    local lo, hi = math.max(0, math.min(ua, ub)), math.min(1, math.max(ua, ub))
    if hi - lo > 0.004 then
      local cm = CELLMASK(f, 0.17, 0.83, lo, hi, dir * cw * 0.25)
      CELLS = CELLS and (CELLS + cm) or cm
    end
    u = u + dir * cw
  end
end
CELLS = CELLS * R
work(CELLS, {hand="detail", pile=cavD, coverage=4, fill=true, clip=CELLS})

--@ chunk 68
print(wait(8*24*60)); for _,p in ipairs{{526,330},{430,300},{380,330},{690,330},{545,600},{334,300},{100,300},{600,350}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 69
gzDark = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.5}, medium=0.9}
local near = (-(RECTS(1.7))):soften(30) * CORR
work(near, {hand="glaze", pile=gzDark, clip=near, coverage=2, fill=true})
blend(near, {angle=TOVP})

--@ chunk 70
D0 = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.6},{"lead white",0.1}, medium=0.08}
D1 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.8},{"lead white",0.3}, medium=0.08}
D2 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.8},{"lead white",0.55}, medium=0.08}
D3 = pile{{"bone black",2},{"burnt sienna",0.55},{"ultramarine ash",0.8},{"lead white",0.85}, medium=0.08}
SW1 = pile{{"bone black",1},{"burnt sienna",0.5},{"yellow ochre",0.3},{"lead white",0.3}, medium=0.08}
SW2 = pile{{"bone black",1},{"burnt sienna",0.5},{"yellow ochre",0.3},{"lead white",0.6}, medium=0.08}
SW3 = pile{{"bone black",1},{"burnt sienna",0.5},{"yellow ochre",0.35},{"lead white",1.0}, medium=0.08}
local walls = LWALL + RWALL
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local function bay(s0, s1, surf, pl)
  local m = (RECTS(s1) - RECTS(s0)) * surf - RIBALL - PIPEM - COLLAR - COLSOFF
  work(m, {hand="body", pile=pl, angle=TOVP, coverage=3.5, fill=true, clip=m})
end
bay(1.0, 1.27, walls, SW2)
bay(1.27, 1.66, walls, D3)
bay(1.66, 2.25, walls, D2)
bay(1.0, 1.27, CEIL, D2)
bay(1.27, 1.66, CEIL, D1)
bay(1.66, 3, CEIL, D0)
local sp = {SW3, SW2, SW1}
local fp = {D1, D0, D0}
for i, s in ipairs(RIBS) do
  local so = RIBSOFF(s) - PIPEM
  work(so, {hand="body", pile=sp[i], angle=TOVP, coverage=3.5, fill=true, clip=so})
  local fr = RIBFRONT(s)
  work(fr, {hand="body", pile=fp[i], angle=TOVP, coverage=3.5, fill=true, clip=fr})
end

--@ chunk 71
print(wait(8*24*60)); for _,p in ipairs{{120,300},{160,300},{250,300},{40,300},{526,330},{960,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 72
sgDark = pile{{"bone black",2},{"burnt sienna",0.45},{"ultramarine blue",0.6}, medium=0.72}
local near = (-(RECTS(1.5))):soften(25) * CORR
work(near, {hand="body", pile=sgDark, angle=TOVP, coverage=3, fill=true, clip=near})
blend(near, {angle=TOVP})

--@ chunk 73
local band = (RECTS(1.8) - RECTS(1.3)) * CORR; blend(band, {angle=TOVP}); blend(band, {angle=TOVP})

--@ chunk 74
print(wait(9*24*60)); for _,p in ipairs{{60,300},{200,300},{250,640},{900,300},{545,640}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 75
sgMid = pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.8}
MIDZ = (RECTS(1.6) - ENDW) - PATCH:grow(2)
work(MIDZ, {hand="body", pile=sgMid, angle=TOVP, coverage=2.5, fill=true, clip=MIDZ})
blend(MIDZ, {angle=TOVP})

--@ chunk 76
print(wait(9*24*60)); for _,p in ipairs{{300,300},{250,300},{780,300},{334,300},{545,90}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 77
RS1 = pile{{"lead white",1.0},{"bone black",0.8},{"burnt sienna",0.25},{"ultramarine ash",0.35}, medium=0.08}
RS2 = pile{{"lead white",0.6},{"bone black",1},{"ultramarine ash",0.45},{"burnt sienna",0.2}, medium=0.08}
RS3 = pile{{"lead white",0.35},{"bone black",1},{"ultramarine ash",0.5},{"burnt sienna",0.1}, medium=0.08}
CSf = pile{{"lead white",1.5},{"bone black",0.6},{"burnt sienna",0.35},{"yellow ochre",0.3}, medium=0.08}
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local sp = {RS1, RS2, RS3}
for i, s in ipairs(RIBS) do
  local so = RIBSOFF(s) - PIPEM
  work(so, {hand="body", tool="filbert 5", pile=sp[i], angle=TOVP, coverage=3.5, fill=true, clip=so})
end
work(COLSOFF, {hand="body", tool="filbert 3", pile=CSf, angle=TOVP, coverage=3.5, fill=true, clip=COLSOFF})

--@ chunk 78
local dk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.4}, medium=0.4}
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local cov = {1.2, 2.2, 3.0}
for i, s in ipairs(RIBS) do
  local so = RIBSOFF(s) - PIPEM
  work(so, {hand="body", tool="filbert 5", pile=dk, angle=TOVP, coverage=cov[i], fill=true, clip=so})
  blend(so, {angle=TOVP})
end

--@ chunk 79
gzBr = pile{{"bone black",1.5},{"burnt sienna",1},{"ultramarine blue",0.3}, medium=0.78}
gzBr2 = pile{{"bone black",1.2},{"burnt sienna",1},{"ultramarine blue",0.2}, medium=0.9}
local W = ENDW + COLLAR
local G1 = W - CUT:grow(48)
work(G1, {hand="body", pile=gzBr, angle=TANG, coverage=2.5, fill=true, clip=G1})
blend(G1, {angle=TANG})
local G2 = (CUT:grow(48) - CUT) * W
work(G2, {hand="body", pile=gzBr2, angle=TANG, coverage=2, fill=true, clip=G2})
blend(G2, {angle=TANG})

--@ chunk 80
print(wait(10*24*60)); for _,p in ipairs{{380,270},{705,230},{334,300},{360,150},{700,450},{420,300},{545,110}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 81
pb1 = pile{{"raw sienna",2},{"bone black",1.2},{"burnt sienna",1}, medium=0.08}
pb2 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}, medium=0.08}
pbD = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"ultramarine blue",0.2}, medium=0.08}
pb3 = pile{{"burnt sienna",2},{"Mars brown",1},{"yellow ochre",0.8},{"bone black",0.6}, medium=0.08}
pshad = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}, medium=0.15}
-- body of one scale plate centred (x,y), radial direction ang (outward), size sz
function PLATE_BODY(x, y, ang, sz, pl, clipm)
  local c, s = math.cos(ang), math.sin(ang)
  local L = sz * 0.45
  local b = brush{kind="filbert", width=sz*1.12, stiffness=0.5}
  b:load(pl, 0.8)
  b:stroke({{x - c*L, y - s*L}, {x + c*L*0.5, y + s*L*0.5}},
    {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=clipm})
end
-- the shadow cast just outside a plate's free (outer) edge
function PLATE_SHADOW(x, y, ang, sz, clipm, w)
  local pts = {}
  local R = sz * 0.52
  for k = -3, 3 do
    local a = ang + k * 0.33
    pts[#pts+1] = {x + math.cos(ang)*sz*0.12 + math.cos(a)*R, y + math.sin(ang)*sz*0.12 + math.sin(a)*R}
  end
  local b = brush{kind="round", width=w or 5, point=0.2}
  b:load(pshad, 0.7)
  b:stroke(pts, {pressure={0.45, 0.75}, swell={0.5, 1, 0.5}, clip=clipm})
end
-- a glint on the plate's rim on the side facing (lx,ly)
function PLATE_GLINT(x, y, ang, sz, lx, ly, pl, amt, clipm)
  local a = math.atan(ly - y, lx - x)
  -- keep the glint on the outer (raised) half of the rim
  local R = sz * 0.42
  local pts = {}
  for k = -2, 2 do
    local b2 = a + k * 0.25
    pts[#pts+1] = {x + math.cos(b2)*R, y + math.sin(b2)*R}
  end
  local b = brush{kind="round", width=2.2, point=0.7}
  b:load(pl, 0.55)
  b:stroke(pts, {pressure={0.1, 0.55*amt + 0.1}, swell={0.4, 1, 0.3}, clip=clipm})
end
-- Vogel positions about (cx,cy), spacing c, inside mask m
function VOGEL(cx, cy, c, nmax, m)
  local out = {}
  for n = 1, nmax do
    local r = c * math.sqrt(n)
    local th = n * 2.399963
    local x, y = cx + r*math.cos(th), cy + r*math.sin(th)
    if m:at(x, y) > 0.3 then out[#out+1] = {x=x, y=y, a=th, n=n, r=r} end
  end
  return out
end
pbO1 = pile{{"burnt sienna",1.5},{"bone black",1},{"raw sienna",1},{"yellow ochre",0.3}, medium=0.08}
pbO2 = pile{{"bone black",1.5},{"burnt sienna",1},{"yellow ochre",0.6}, medium=0.08}
pbO3 = pile{{"burnt sienna",1.2},{"Mars brown",1},{"bone black",0.8},{"yellow ochre",0.4}, medium=0.08}
OUTER = BRONZE - CUT:grow(40)
local n = 0
for i, p in ipairs(PLATES) do
  if OUTER:at(p.x, p.y) > 0.5 then
    local r = math.random()
    local pl = (r < 0.4) and pbO1 or ((r < 0.75) and pbO2 or pbO3)
    PLATE_BODY(p.x, p.y, p.a, rand(19, 23), pl, BRONZE)
    n = n + 1
  end
end
print(n)

--@ chunk 82
print(wait(3*24*60)); print(drying(360,300), drying(720,300))

--@ chunk 83
pb1 = pile{{"raw sienna",2},{"bone black",1.2},{"burnt sienna",1}, medium=0.08}
pb2 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}, medium=0.08}
pbD = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"ultramarine blue",0.2}, medium=0.08}
pb3 = pile{{"burnt sienna",2},{"Mars brown",1},{"yellow ochre",0.8},{"bone black",0.6}, medium=0.08}
pshad = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}, medium=0.15}
-- body of one scale plate centred (x,y), radial direction ang (outward), size sz
function PLATE_BODY(x, y, ang, sz, pl, clipm)
  local c, s = math.cos(ang), math.sin(ang)
  local L = sz * 0.45
  local b = brush{kind="filbert", width=sz*1.12, stiffness=0.5}
  b:load(pl, 0.8)
  b:stroke({{x - c*L, y - s*L}, {x + c*L*0.5, y + s*L*0.5}},
    {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=clipm})
end
-- the shadow cast just outside a plate's free (outer) edge
function PLATE_SHADOW(x, y, ang, sz, clipm, w)
  local pts = {}
  local R = sz * 0.52
  for k = -3, 3 do
    local a = ang + k * 0.33
    pts[#pts+1] = {x + math.cos(ang)*sz*0.12 + math.cos(a)*R, y + math.sin(ang)*sz*0.12 + math.sin(a)*R}
  end
  local b = brush{kind="round", width=w or 5, point=0.2}
  b:load(pshad, 0.7)
  b:stroke(pts, {pressure={0.45, 0.75}, swell={0.5, 1, 0.5}, clip=clipm})
end
-- a glint on the plate's rim on the side facing (lx,ly)
function PLATE_GLINT(x, y, ang, sz, lx, ly, pl, amt, clipm)
  local a = math.atan(ly - y, lx - x)
  -- keep the glint on the outer (raised) half of the rim
  local R = sz * 0.42
  local pts = {}
  for k = -2, 2 do
    local b2 = a + k * 0.25
    pts[#pts+1] = {x + math.cos(b2)*R, y + math.sin(b2)*R}
  end
  local b = brush{kind="round", width=2.2, point=0.7}
  b:load(pl, 0.55)
  b:stroke(pts, {pressure={0.1, 0.55*amt + 0.1}, swell={0.4, 1, 0.3}, clip=clipm})
end
-- Vogel positions about (cx,cy), spacing c, inside mask m
function VOGEL(cx, cy, c, nmax, m)
  local out = {}
  for n = 1, nmax do
    local r = c * math.sqrt(n)
    local th = n * 2.399963
    local x, y = cx + r*math.cos(th), cy + r*math.sin(th)
    if m:at(x, y) > 0.3 then out[#out+1] = {x=x, y=y, a=th, n=n, r=r} end
  end
  return out
end
pshad = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",1}, medium=0.12}
for i, p in ipairs(PLATES) do PLATE_SHADOW(p.x, p.y, p.a, 21, BRONZE, 5.5) end

--@ chunk 84
amberS = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.7},{"bone black",0.45}, medium=0.08}
CSf2 = pile{{"lead white",0.9},{"bone black",0.7},{"burnt sienna",0.4},{"yellow ochre",0.3}, medium=0.08}
work(COLLAR, {hand="body", tool="filbert 5", pile=amberS, angle=TOVP, coverage=4, fill=true, clip=COLLAR})
work(COLSOFF, {hand="body", tool="filbert 3", pile=CSf2, angle=TOVP, coverage=3.5, fill=true, clip=COLSOFF})

--@ chunk 85
print(wait(6*24*60)); for _,p in ipairs{{325,300},{767,300},{340,300},{430,300},{545,140}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 86
amberDk = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.9},{"bone black",1.0}, medium=0.08}
hzBlk = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.5}, medium=0.08}
work(COLLAR, {hand="body", tool="filbert 5", pile=amberDk, angle=TOVP, coverage=4, fill=true, clip=COLLAR})

--@ chunk 87
print(wait(6*24*60)); for _,p in ipairs{{325,300},{767,300},{340,300},{545,95}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 88
print(wait(5*24*60)); for _,p in ipairs{{325,300},{767,300},{340,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 89
local b = brush{kind="flat", width=9, stiffness=0.6}
local function st(x0, y0, x1, y1)
  b:load(hzBlk, 0.9)
  b:stroke({{x0, y0}, {x1, y1}}, {pressure={0.85, 0.8}, orient="across", clip=COLLAR, shake=0.6})
end
for y = 50, 560, 20 do st(312, y, 354, y + 42) end
for y = 50, 560, 20 do st(778, y, 736, y + 42) end
for x = 280, 800, 20 do st(x, 84, x + 42, 126) end

--@ chunk 90
print(wait(9*24*60)); for _,p in ipairs{{325,300},{767,300},{545,105}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 91
rvA = pile{{"burnt sienna",1},{"bone black",1},{"Mars brown",0.5}, medium=0.08}
rvB = pile{{"burnt sienna",1.5},{"Mars brown",0.5},{"bone black",0.5},{"yellow ochre",0.5}, medium=0.08}
rvC = pile{{"yellow ochre",1.5},{"burnt sienna",1},{"lead white",0.4},{"raw sienna",0.5}, medium=0.08}
local function band(t0, t1)
  local m = nil
  for _, key in ipairs{"left","ctl","top","ctr","right"} do
    local f = FACEMASK(FACES[key], t0, t1, 0, 1)
    m = m and (m + f) or f
  end
  return m * SIDES
end
local A, B, C = band(-0.3, 0.38), band(0.36, 0.7), band(0.68, 1.3)
work(A, {hand="body", tool="filbert 5", pile=rvA, angle=TOVP, coverage=4, fill=true, clip=SIDES})
work(B, {hand="body", tool="filbert 5", pile=rvB, angle=TOVP, coverage=4, fill=true, clip=SIDES})
work(C, {hand="body", tool="filbert 5", pile=rvC, angle=TOVP, coverage=4, fill=true, clip=SIDES})
blend(SIDES, {angle=TOVP})

--@ chunk 92
local f = FACES.sill
local A = FACEMASK(f, -0.3, 0.4, 0, 1) * SILL
local B = FACEMASK(f, 0.38, 0.72, 0, 1) * SILL
local C = FACEMASK(f, 0.7, 1.3, 0, 1) * SILL
work(A, {hand="body", tool="filbert 5", pile=rvB, angle=0, coverage=4, fill=true, clip=SILL})
work(B, {hand="body", tool="filbert 5", pile=rvC, angle=0, coverage=4, fill=true, clip=SILL})
work(C, {hand="body", tool="filbert 5", pile=rv2, angle=0, coverage=4, fill=true, clip=SILL})
blend(SILL, {angle=TOVP})

--@ chunk 93
print(wait(6*24*60)); for _,p in ipairs{{325,300},{767,300},{545,105},{430,300},{545,490}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 94
amberM = pile{{"chrome yellow",1},{"Mars orange",1},{"burnt sienna",0.5},{"bone black",0.35}, medium=0.08}
local b = brush{kind="flat", width=5.5, stiffness=0.6}
local function st(x0, y0, x1, y1)
  b:load(amberM, 0.9)
  b:stroke({{x0, y0}, {x1, y1}}, {pressure={0.75, 0.7}, orient="across", clip=COLLAR, shake=0.6})
end
for y = 50, 560, 20 do st(312, y + 10, 354, y + 52) end
for y = 50, 560, 20 do st(778, y + 10, 736, y + 52) end
for x = 280, 800, 20 do st(x + 10, 84, x + 52, 126) end

--@ chunk 95
for _,p in ipairs{{500,200},{545,250},{470,330},{526,330},{620,330}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 96
gl1 = pile{{"lead white",4},{"lemon chrome",0.35},{"yellow ochre",0.15}, medium=0.1}
gl2 = pile{{"lead white",3},{"yellow ochre",0.6},{"cadmium yellow",0.25}, medium=0.15}
gl3 = pile{{"lead white",2},{"yellow ochre",0.9},{"raw sienna",0.3},{"Mars orange",0.1}, medium=0.2}
local V = VIEW - FIGM:grow(1)
local r3 = ellipse(545, 292, 70, 80) * V
local r2 = ellipse(545, 294, 42, 50) * V
local r1 = ellipse(546, 297, 18, 24) * V
work(r3 - r2, {hand="body", tool="filbert 5", pile=gl3, angle=TOVP, coverage=1.2, fill=false, clip=V, pressure={0.3,0.5}})
work(r2 - r1, {hand="body", tool="filbert 4", pile=gl2, angle=TOVP, coverage=2.5, fill=true, clip=V})
work(r1, {hand="body", tool="filbert 3", pile=gl1, angle=TOVP, coverage=3.5, fill=true, clip=V})
blend(r3:grow(5) * V, {angle=0})

--@ chunk 97
local V = VIEW - FIGM:grow(2); local ring = (ellipse(545,292,95,100) - ellipse(545,294,40,48)) * V; blend(ring, {angle=TOVP, blender=true}); blend(ring, {angle=0})

--@ chunk 98
print(wait(7*24*60)); for _,p in ipairs{{545,250},{480,330},{600,330},{430,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 99
-- extend the nave: it curls as it recedes
local A = ARCHES[#ARCHES]
local s, rot, dx, dy = A.s, A.rot, A.dx, A.dy
for i = #ARCHES + 1, 26 do
  s = s * (0.8 + 0.06 * ((i * 0.618034) % 1))
  rot = rot + 0.16 + 0.012 * (i - 16)
  dx = dx + 1.1; dy = dy - 1.0
  ARCHES[i] = {s=s, rot=rot, dx=dx, dy=dy}
end
for i = 14, 26 do local a = ARCHES[i]; local p = ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy); print(i, string.format("%.4f rot %.2f top %.1f,%.1f foot %.1f,%.1f", a.s, a.rot, p[19][1], p[19][2], p[1][1], p[1][2])) end

--@ chunk 100
ARCHES2 = {}
for i = 1, 5 do ARCHES2[i] = ARCHES[i] end
do
  local A = ARCHES[5]
  local s, rot, dx, dy = A.s, A.rot, A.dx, A.dy
  for i = 6, 22 do
    s = s * (0.87 + 0.04 * ((i * 0.618034) % 1))
    rot = rot + 0.12
    dx = dx + 0.7; dy = dy - 1.1
    ARCHES2[i] = {s=s, rot=rot, dx=dx, dy=dy}
  end
end
NA = #ARCHES2
function ARCHIN(i) local a = ARCHES2[i]; return poly(ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy), true) end
local function mixpile(t)
  local u = t ^ 0.75
  return pile{{"lead white", lerp(1.3, 4, u)}, {"yellow ochre", lerp(2, 0.35, u)}, {"burnt sienna", lerp(0.55, 0.01, u)},
              {"raw sienna", lerp(0.4, 0.01, u)}, {"lemon chrome", lerp(0.01, 0.3, u)}, medium=0.12}
end
local V = VIEW - FIGM
local done = nil
for i = 1, NA do
  local inner = (i < NA) and ARCHIN(i + 1) or nil
  local band = inner and (ARCHIN(i) - inner) or ARCHIN(i)
  -- the area between the aperture and the first arch belongs to band 1
  if i == 1 then band = (VIEW * above(function(x) return 318 end)) - inner end
  band = band * V
  local w = math.max(1.2, math.min(6, 120 * ARCHES2[i].s))
  work(band, {hand="body", tool={kind="filbert", width=w}, pile=mixpile((i - 1) / (NA - 1)), angle=TOVP, coverage=3.5, fill=true, clip=band})
end
blend((VIEW * above(function(x) return 318 end)) - FIGM:grow(2), {angle=TOVP})

--@ chunk 101
print(wait(7*24*60)); for _,p in ipairs{{545,250},{480,200},{600,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 102
function VAULTPILE(t)
  local u = t ^ 0.75
  return pile{{"lead white", lerp(1.1, 4, u)}, {"yellow ochre", lerp(2, 0.35, u)}, {"burnt sienna", lerp(0.7, 0.01, u)},
              {"raw sienna", lerp(0.45, 0.01, u)}, {"lemon chrome", lerp(0.01, 0.3, u)}, medium=0.12}
end
local V = VIEW - FIGM
for i = 1, NA do
  local inner = (i < NA) and ARCHIN(i + 1) or nil
  local band = inner and (ARCHIN(i) - inner) or ARCHIN(i)
  if i == 1 then band = (VIEW * above(function(x) return 318 end)) - inner end
  band = band * V
  local w = math.max(1.2, math.min(6, 120 * ARCHES2[i].s))
  work(band, {hand="body", tool={kind="filbert", width=w}, pile=VAULTPILE((i - 1) / (NA - 1)), angle=TOVP, coverage=3.5, fill=true, clip=band})
end

--@ chunk 103
print(wait(4*24*60)); for _,p in ipairs{{545,250},{480,200},{600,300},{455,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 104
function WP(side, s, h) if side < 0 then return LWP(s, h) else return RWP(s, h) end end
function WQ(side, s1, s2, h1, h2) return poly({WP(side,s1,h1), WP(side,s2,h1), WP(side,s2,h2), WP(side,s1,h2)}) end
WALLV = (LWALL + RWALL) - RIBALL - COLLAR - COLSOFF
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
WALLV = WALLV - PIPEM
seamDk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.1}
seamLt = pile{{"bone black",1},{"lead white",0.45},{"burnt sienna",0.3},{"yellow ochre",0.2}, medium=0.1}
local function wline(side, s1, s2, h, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.2}
  local pts = {}
  for i = 0, 8 do pts[#pts+1] = WP(side, lerp(s1, s2, i/8), h) end
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr or {0.6, 0.7}, clip=WALLV, shake=0.3})
end
local function vline(side, s, h1, h2, pl, w)
  local b = brush{kind="round", width=w, point=0.2}
  b:load(pl, 0.8)
  b:stroke({WP(side, s, h1), WP(side, s, h2)}, {pressure={0.6, 0.6}, clip=WALLV, shake=0.3})
end
for _, side in ipairs{-1, 1} do
  for _, h in ipairs{0.36, 1.08, 1.8} do
    wline(side, 1.0, 2.7, h, seamDk, 2.2)
    wline(side, 1.0, 2.7, h - 0.025, seamLt, 1.0, {0.35, 0.5})
  end
  for _, s in ipairs{1.14, 1.47, 1.95} do
    vline(side, s, 0.0, 2.4, seamDk, 2.0)
  end
end

--@ chunk 105
plq = pile{{"lead white",1},{"bone black",0.75},{"yellow ochre",0.25},{"ultramarine ash",0.15}, medium=0.08}
plqA = pile{{"chrome yellow",1},{"Mars orange",0.8},{"bone black",0.6},{"burnt sienna",0.3}, medium=0.08}
patchP = pile{{"lead white",0.8},{"bone black",1},{"viridian",0.15},{"yellow ochre",0.2}, medium=0.08}
tapeP = pile{{"lead white",1.2},{"bone black",0.6},{"ultramarine ash",0.3}, medium=0.08}
PLQ = WQ(-1, 1.33, 1.55, 1.2, 1.62)
work(PLQ, {hand="detail", pile=plq, coverage=4, fill=true, clip=PLQ})
PLQA = WQ(-1, 1.33, 1.55, 1.52, 1.62)
work(PLQA, {hand="detail", pile=plqA, coverage=4, fill=true, clip=PLQA})
PATCHW = WQ(1, 1.05, 1.21, 0.47, 1.02)
work(PATCHW, {hand="detail", pile=patchP, coverage=4, fill=true, clip=PATCHW})

--@ chunk 106
print(wait(4*24*60)); for _,p in ipairs{{545,250},{480,200},{235,270},{790,400},{455,300}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 107
function RIBPILE(t)
  local u = t ^ 0.75
  return pile{{"lead white", lerp(0.45, 2.6, u)}, {"yellow ochre", lerp(1.5, 0.7, u)}, {"burnt sienna", lerp(1.0, 0.15, u)},
              {"raw sienna", lerp(0.4, 0.1, u)}, medium=0.1}
end
local V = VIEW - FIGM
for i = 1, NA do
  local a = ARCHES2[i]
  local t = (i - 1) / (NA - 1)
  local pts = ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy)
  local w = math.max(0.9, 105 * a.s)
  local b = brush{kind="round", width=w, stiffness=0.5}
  local L, R = {}, {}
  for j = 1, 19 do L[#L+1] = pts[j] end
  for j = 19, #pts do R[#R+1] = pts[j] end
  local rp = RIBPILE(t)
  b:load(rp, 0.9); b:stroke(L, {pressure={0.8, 0.75}, clip=V, shake=0.4})
  b:load(rp, 0.9); b:stroke(R, {pressure={0.75, 0.8}, clip=V, shake=0.4})
  -- the lit inner lip
  local pin = ARCHPTS(a.s * 0.975, 9, 14, a.rot, a.dx, a.dy)
  local L2, R2 = {}, {}
  for j = 3, 19 do L2[#L2+1] = pin[j] end
  for j = 19, #pin - 2 do R2[#R2+1] = pin[j] end
  local lb = brush{kind="round", width=math.max(0.7, w * 0.35), point=0.4}
  local lp = VAULTPILE(math.min(1, t + 0.25))
  lb:load(lp, 0.8); lb:stroke(L2, {pressure={0.4, 0.6}, clip=V})
  lb:load(lp, 0.8); lb:stroke(R2, {pressure={0.6, 0.4}, clip=V})
end

--@ chunk 108
local H = HFLOOR - FIGM:grow(0.5)
local a = H * above(function(x) return 340 end)
local b = H * below(function(x) return 340 end) * above(function(x) return 372 end)
local c = H * below(function(x) return 372 end) * above(function(x) return 400 end)
local fl_far2 = pile{{"lead white",2.6},{"yellow ochre",1.3},{"Mars orange",0.2},{"raw sienna",0.2}, medium=0.1}
local fl_mid2 = pile{{"lead white",1.6},{"yellow ochre",1.5},{"burnt sienna",0.45},{"raw sienna",0.4}, medium=0.1}
local fl_n2 = pile{{"lead white",1.0},{"yellow ochre",1.5},{"burnt sienna",0.6},{"raw sienna",0.4}, medium=0.1}
work(a, {hand="body", tool="filbert 4", pile=fl_far2, angle=0, coverage=4, fill=true, clip=a})
work(b, {hand="body", tool="filbert 5", pile=fl_mid2, angle=0, coverage=4, fill=true, clip=b})
work(c, {hand="body", tool="filbert 5", pile=fl_n2, angle=0, coverage=4, fill=true, clip=c})

--@ chunk 109
local H = HFLOOR - FIGM:grow(3); blend(H * below(function(x) return 330 end) * above(function(x) return 350 end), {angle=0}); blend(H * below(function(x) return 362 end) * above(function(x) return 382 end), {angle=0}); blend(H * below(function(x) return 392 end) * above(function(x) return 408 end), {angle=0})

--@ chunk 110
print(wait(3*24*60)); for _,p in ipairs{{470,330},{620,360},{500,390}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 111
print(wait(2*24*60)); for _,p in ipairs{{235,270},{790,400},{620,360},{500,390}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 112
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
-- placard and patch, knocked down into the gloom
local plq2 = pile{{"bone black",2},{"lead white",0.75},{"yellow ochre",0.3},{"burnt sienna",0.2}, medium=0.08}
local plqA2 = pile{{"chrome yellow",1},{"Mars orange",0.8},{"bone black",1.1},{"burnt sienna",0.4}, medium=0.08}
local patch2 = pile{{"bone black",2},{"lead white",0.6},{"viridian",0.2},{"yellow ochre",0.15}, medium=0.08}
local body = PLQ - PLQA
work(body, {hand="detail", pile=plq2, coverage=4, fill=true, clip=body})
work(PLQA, {hand="detail", pile=plqA2, coverage=4, fill=true, clip=PLQA})
work(PATCHW, {hand="detail", pile=patch2, coverage=4, fill=true, clip=PATCHW})
-- chairs again, solid, over the new floor
for ri = #ROWZ, 1, -1 do
  local Z = ROWZ[ri]
  local pl = (ri >= 5) and chF2 or ((ri >= 3) and chM2 or chN2)
  local m, cs = nil, nil
  local list = {}
  for _, c in ipairs(CHAIRS) do
    if c.row == ri then
      list[#list+1] = c
      local cm = CHAIRMASK(c.X, c.Z, c.v)
      m = m and (m + cm) or cm
    end
  end
  local k = 175*6/Z
  local b = brush{kind="round", width=math.max(1.0, 0.05*k), stiffness=0.5}
  for _, c in ipairs(list) do b:load(pl, 0.9); CHAIRLEGS(b, c.X, c.Z, c.v, nil, nil, VIEW - FIGM) end
  m = m * VIEW - FIGM
  local tw = math.max(1.5, math.min(5, 0.12 * k))
  work(m, {hand="body", tool="filbert " .. string.format("%.1f", tw), pile=pl, angle=math.pi/2, coverage=4, fill=true, clip=m})
end

--@ chunk 113
print(wait(4*24*60)); for _,p in ipairs{{470,330},{620,330},{235,270},{790,400}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 114
print(wait(4*24*60)); for _,p in ipairs{{470,330},{620,330},{235,270},{790,400}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 115
-- the Commando's frame, seen from behind; local metres, origin between the feet, y up
function FIGPARTS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  local parts = {}
  -- legs (ribbons), slightly apart, weight on the right leg
  parts.legL = ribbon({P(-0.11,0.93), P(-0.15,0.52), P(-0.17,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.legR = ribbon({P(0.11,0.93), P(0.12,0.52), P(0.13,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.boots = poly({P(-0.25,0.0), P(-0.09,0.0), P(-0.1,0.13), P(-0.23,0.13)}) + poly({P(0.06,0.0), P(0.22,0.0), P(0.2,0.13), P(0.07,0.13)})
  parts.pelvis = poly({P(-0.19,0.88), P(0.19,0.88), P(0.2,1.06), P(-0.2,1.06)}, true)
  -- torso widening to armoured shoulders
  parts.torso = poly({P(-0.17,1.02), P(0.17,1.02), P(0.23,1.32), P(0.30,1.5), P(0.27,1.58), P(0.1,1.6), P(-0.1,1.6), P(-0.27,1.58), P(-0.3,1.5), P(-0.23,1.32)}, true)
  -- the power pack on the back, a squarer slab
  parts.pack = poly({P(-0.17,1.12), P(0.16,1.12), P(0.18,1.52), P(-0.18,1.53)})
  parts.neck = poly({P(-0.05,1.55), P(0.05,1.55), P(0.05,1.66), P(-0.05,1.66)})
  -- the helmet: narrow, a little tall, with a crest
  parts.head = ellipse(fx + 0.0*k, fy - 1.75*k, 0.105*k, 0.13*k) + poly({P(-0.02,1.86), P(0.02,1.86), P(0.015,1.92), P(-0.015,1.92)})
  -- arms: left hangs, right carries the rifle low
  parts.armL = ribbon({P(-0.29,1.5), P(-0.34,1.22), P(-0.31,0.95)}, {0.12*k, 0.1*k, 0.09*k})
  parts.armR = ribbon({P(0.29,1.5), P(0.35,1.23), P(0.29,1.03)}, {0.12*k, 0.1*k, 0.09*k})
  parts.rifle = ribbon({P(0.18,1.14), P(0.33,0.92), P(0.47,0.55)}, {0.06*k, 0.055*k, 0.035*k})
  return parts
end
function FIGMASK(fx, fy, k)
  local m = nil
  for _, part in pairs(FIGPARTS(fx, fy, k)) do m = m and (m + part) or part end
  return m
end
-- the lit outline: points along the right-hand (glow-side) edges and the tops
function FIGRIMS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  return {
    head = {P(-0.07,1.84), P(0.0,1.885), P(0.07,1.85), P(0.1,1.78), P(0.1,1.7)},
    shoulderR = {P(0.1,1.6), P(0.24,1.58), P(0.3,1.52), P(0.36,1.3), P(0.36,1.2)},
    shoulderL = {P(-0.1,1.6), P(-0.24,1.585), P(-0.3,1.52)},
    armL = {P(-0.35,1.4), P(-0.36,1.2), P(-0.34,1.0)},
    legR = {P(0.19,0.9), P(0.18,0.55), P(0.18,0.15)},
    rifle = {P(0.36,0.92), P(0.48,0.6)},
  }
end
local fx, fy, k = FIGFX, FIGFY, FIGK
local function P(x, y) return {fx + x*k, fy - y*k} end
-- pauldrons and a helmet brow, adding to the silhouette
local add = ellipse(fx - 0.29*k, fy - 1.54*k, 0.11*k, 0.075*k) + ellipse(fx + 0.29*k, fy - 1.54*k, 0.11*k, 0.075*k)
  + poly({P(-0.11,1.73), P(0.11,1.73), P(0.12,1.69), P(-0.12,1.69)})
  + poly({P(-0.2,0.97), P(0.2,0.97), P(0.21,1.03), P(-0.21,1.03)})   -- belt
work(add, {hand="detail", pile=figD, coverage=4, fill=true, clip=add})
FIGM2 = FIGM + add

--@ chunk 116
-- the Commando's frame, seen from behind; local metres, origin between the feet, y up
function FIGPARTS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  local parts = {}
  -- legs (ribbons), slightly apart, weight on the right leg
  parts.legL = ribbon({P(-0.11,0.93), P(-0.15,0.52), P(-0.17,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.legR = ribbon({P(0.11,0.93), P(0.12,0.52), P(0.13,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.boots = poly({P(-0.25,0.0), P(-0.09,0.0), P(-0.1,0.13), P(-0.23,0.13)}) + poly({P(0.06,0.0), P(0.22,0.0), P(0.2,0.13), P(0.07,0.13)})
  parts.pelvis = poly({P(-0.19,0.88), P(0.19,0.88), P(0.2,1.06), P(-0.2,1.06)}, true)
  -- torso widening to armoured shoulders
  parts.torso = poly({P(-0.17,1.02), P(0.17,1.02), P(0.23,1.32), P(0.30,1.5), P(0.27,1.58), P(0.1,1.6), P(-0.1,1.6), P(-0.27,1.58), P(-0.3,1.5), P(-0.23,1.32)}, true)
  -- the power pack on the back, a squarer slab
  parts.pack = poly({P(-0.17,1.12), P(0.16,1.12), P(0.18,1.52), P(-0.18,1.53)})
  parts.neck = poly({P(-0.05,1.55), P(0.05,1.55), P(0.05,1.66), P(-0.05,1.66)})
  -- the helmet: narrow, a little tall, with a crest
  parts.head = ellipse(fx + 0.0*k, fy - 1.75*k, 0.105*k, 0.13*k) + poly({P(-0.02,1.86), P(0.02,1.86), P(0.015,1.92), P(-0.015,1.92)})
  -- arms: left hangs, right carries the rifle low
  parts.armL = ribbon({P(-0.29,1.5), P(-0.34,1.22), P(-0.31,0.95)}, {0.12*k, 0.1*k, 0.09*k})
  parts.armR = ribbon({P(0.29,1.5), P(0.35,1.23), P(0.29,1.03)}, {0.12*k, 0.1*k, 0.09*k})
  parts.rifle = ribbon({P(0.18,1.14), P(0.33,0.92), P(0.47,0.55)}, {0.06*k, 0.055*k, 0.035*k})
  return parts
end
function FIGMASK(fx, fy, k)
  local m = nil
  for _, part in pairs(FIGPARTS(fx, fy, k)) do m = m and (m + part) or part end
  return m
end
-- the lit outline: points along the right-hand (glow-side) edges and the tops
function FIGRIMS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  return {
    head = {P(-0.07,1.84), P(0.0,1.885), P(0.07,1.85), P(0.1,1.78), P(0.1,1.7)},
    shoulderR = {P(0.1,1.6), P(0.24,1.58), P(0.3,1.52), P(0.36,1.3), P(0.36,1.2)},
    shoulderL = {P(-0.1,1.6), P(-0.24,1.585), P(-0.3,1.52)},
    armL = {P(-0.35,1.4), P(-0.36,1.2), P(-0.34,1.0)},
    legR = {P(0.19,0.9), P(0.18,0.55), P(0.18,0.15)},
    rifle = {P(0.36,0.92), P(0.48,0.6)},
  }
end
local fx, fy, k = FIGFX, FIGFY, FIGK
local function P(x, y) return {fx + x*k, fy - y*k} end
rimHot = pile{{"lead white",3},{"lemon chrome",0.3},{"yellow ochre",0.3}, medium=0.08}
rimWarm = pile{{"lead white",1.5},{"yellow ochre",1},{"Mars orange",0.3},{"burnt sienna",0.2}, medium=0.08}
local function line(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.7}
  b:load(pl, 0.7)
  b:stroke(pts, {pressure=pr or {0.2, 0.6}, swell={0.6, 1, 0.5}})
end
-- the edge light: helmet crown, right pauldron, right arm, right flank, left pauldron top
line({P(-0.08,1.86), P(-0.02,1.9), P(0.05,1.885), P(0.1,1.8)}, rimHot, 1.4)
line({P(0.2,1.615), P(0.3,1.62), P(0.39,1.55)}, rimHot, 1.5)
line({P(0.38,1.48), P(0.37,1.3), P(0.355,1.12)}, rimWarm, 1.2, {0.5, 0.2})
line({P(-0.38,1.56), P(-0.3,1.62), P(-0.2,1.615)}, rimWarm, 1.2, {0.5, 0.3})
line({P(0.24,0.93), P(0.215,0.55), P(0.2,0.2)}, rimWarm, 1.0, {0.4, 0.15})
line({P(0.17,1.1), P(0.2,1.35)}, rimWarm, 0.9, {0.3, 0.3})
-- a glint on the helmet's visor ridge
line({P(0.02,1.72), P(0.12,1.715)}, rimHot, 1.0, {0.5, 0.3})

--@ chunk 117
-- the Commando's frame, seen from behind; local metres, origin between the feet, y up
function FIGPARTS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  local parts = {}
  -- legs (ribbons), slightly apart, weight on the right leg
  parts.legL = ribbon({P(-0.11,0.93), P(-0.15,0.52), P(-0.17,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.legR = ribbon({P(0.11,0.93), P(0.12,0.52), P(0.13,0.1)}, {0.16*k, 0.12*k, 0.1*k})
  parts.boots = poly({P(-0.25,0.0), P(-0.09,0.0), P(-0.1,0.13), P(-0.23,0.13)}) + poly({P(0.06,0.0), P(0.22,0.0), P(0.2,0.13), P(0.07,0.13)})
  parts.pelvis = poly({P(-0.19,0.88), P(0.19,0.88), P(0.2,1.06), P(-0.2,1.06)}, true)
  -- torso widening to armoured shoulders
  parts.torso = poly({P(-0.17,1.02), P(0.17,1.02), P(0.23,1.32), P(0.30,1.5), P(0.27,1.58), P(0.1,1.6), P(-0.1,1.6), P(-0.27,1.58), P(-0.3,1.5), P(-0.23,1.32)}, true)
  -- the power pack on the back, a squarer slab
  parts.pack = poly({P(-0.17,1.12), P(0.16,1.12), P(0.18,1.52), P(-0.18,1.53)})
  parts.neck = poly({P(-0.05,1.55), P(0.05,1.55), P(0.05,1.66), P(-0.05,1.66)})
  -- the helmet: narrow, a little tall, with a crest
  parts.head = ellipse(fx + 0.0*k, fy - 1.75*k, 0.105*k, 0.13*k) + poly({P(-0.02,1.86), P(0.02,1.86), P(0.015,1.92), P(-0.015,1.92)})
  -- arms: left hangs, right carries the rifle low
  parts.armL = ribbon({P(-0.29,1.5), P(-0.34,1.22), P(-0.31,0.95)}, {0.12*k, 0.1*k, 0.09*k})
  parts.armR = ribbon({P(0.29,1.5), P(0.35,1.23), P(0.29,1.03)}, {0.12*k, 0.1*k, 0.09*k})
  parts.rifle = ribbon({P(0.18,1.14), P(0.33,0.92), P(0.47,0.55)}, {0.06*k, 0.055*k, 0.035*k})
  return parts
end
function FIGMASK(fx, fy, k)
  local m = nil
  for _, part in pairs(FIGPARTS(fx, fy, k)) do m = m and (m + part) or part end
  return m
end
-- the lit outline: points along the right-hand (glow-side) edges and the tops
function FIGRIMS(fx, fy, k)
  local function P(x, y) return {fx + x*k, fy - y*k} end
  return {
    head = {P(-0.07,1.84), P(0.0,1.885), P(0.07,1.85), P(0.1,1.78), P(0.1,1.7)},
    shoulderR = {P(0.1,1.6), P(0.24,1.58), P(0.3,1.52), P(0.36,1.3), P(0.36,1.2)},
    shoulderL = {P(-0.1,1.6), P(-0.24,1.585), P(-0.3,1.52)},
    armL = {P(-0.35,1.4), P(-0.36,1.2), P(-0.34,1.0)},
    legR = {P(0.19,0.9), P(0.18,0.55), P(0.18,0.15)},
    rifle = {P(0.36,0.92), P(0.48,0.6)},
  }
end
local fx, fy, k = FIGFX, FIGFY, FIGK
local function P(x, y) return {fx + x*k, fy - y*k} end
rimHot = pile{{"lead white",3},{"lemon chrome",0.3},{"yellow ochre",0.3}, medium=0.08}
rimWarm = pile{{"lead white",1.5},{"yellow ochre",1},{"Mars orange",0.3},{"burnt sienna",0.2}, medium=0.08}
local function line(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.7}
  b:load(pl, 0.7)
  b:stroke(pts, {pressure=pr or {0.75, 0.9}, swell={0.6, 1, 0.5}})
end
-- the edge light: helmet crown, right pauldron, right arm, right flank, left pauldron top
line({P(-0.08,1.86), P(-0.02,1.9), P(0.05,1.885), P(0.1,1.8)}, rimHot, 1.4)
line({P(0.2,1.615), P(0.3,1.62), P(0.39,1.55)}, rimHot, 1.5)
line({P(0.38,1.48), P(0.37,1.3), P(0.355,1.12)}, rimWarm, 1.2, {0.85, 0.6})
line({P(-0.38,1.56), P(-0.3,1.62), P(-0.2,1.615)}, rimWarm, 1.2, {0.85, 0.7})
line({P(0.24,0.93), P(0.215,0.55), P(0.2,0.2)}, rimWarm, 1.0, {0.8, 0.5})
line({P(0.17,1.1), P(0.2,1.35)}, rimWarm, 0.9, {0.7, 0.7})
-- a glint on the helmet's visor ridge
line({P(0.02,1.72), P(0.12,1.715)}, rimHot, 1.0, {0.85, 0.7})

--@ chunk 118
print(wait(3*24*60)); for _,p in ipairs{{470,330},{620,330},{600,310}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 119
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local V = VIEW - FIGM2
local rimF = pile{{"lead white",2.5},{"yellow ochre",0.8},{"cadmium yellow",0.15}, medium=0.08}
local rimN = pile{{"lead white",1.4},{"yellow ochre",1},{"burnt sienna",0.25}, medium=0.08}
local cnt = 0
for _, c in ipairs(CHAIRS) do
  local back = CHAIRSHAPES(c.X, c.Z, c.v)
  local k = 175*6/c.Z
  local crest = {back[4], back[5], back[6], back[7], back[8], back[9], back[10]}
  -- toward the aisle, the inner shoulder catches more
  local w = math.max(0.7, 0.022 * k)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(c.row <= 2 and rimN or rimF, 0.75)
  local pr = (c.X < 0) and {0.35, 0.85} or {0.85, 0.35}
  b:stroke(crest, {pressure=pr, swell={0.7, 1, 0.8}, clip=V})
  -- the aisle-side edge of the back
  local edge = (c.X < 0) and {back[10], back[11], back[12]} or {back[2], back[3], back[4]}
  b:load(c.row <= 2 and rimN or rimF, 0.6)
  b:stroke(edge, {pressure={0.6, 0.2}, clip=V})
  cnt = cnt + 1
end
print(cnt)

--@ chunk 120
local plq3 = pile{{"bone black",2},{"lead white",0.3},{"yellow ochre",0.25},{"burnt sienna",0.1}, medium=0.08}
local plqA3 = pile{{"chrome yellow",0.6},{"Mars orange",0.5},{"bone black",1.5},{"burnt sienna",0.4}, medium=0.08}
local patch3 = pile{{"bone black",2},{"lead white",0.25},{"viridian",0.2},{"yellow ochre",0.1}, medium=0.08}
local body = PLQ - PLQA
work(body, {hand="detail", pile=plq3, coverage=4, fill=true, clip=body})
work(PLQA, {hand="detail", pile=plqA3, coverage=4, fill=true, clip=PLQA})
work(PATCHW, {hand="detail", pile=patch3, coverage=4, fill=true, clip=PATCHW})
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local s2p = pile{{"bone black",2},{"lead white",0.35},{"burnt sienna",0.35},{"ultramarine ash",0.3}, medium=0.08}
local s3p = pile{{"bone black",2},{"lead white",0.15},{"burnt sienna",0.3},{"ultramarine ash",0.4}, medium=0.08}
local so2 = RIBSOFF(RIBS[2]) - PIPEM
local so3 = RIBSOFF(RIBS[3]) - PIPEM
work(so2, {hand="body", tool="filbert 5", pile=s2p, angle=TOVP, coverage=4, fill=true, clip=so2})
work(so3, {hand="body", tool="filbert 5", pile=s3p, angle=TOVP, coverage=4, fill=true, clip=so3})

--@ chunk 121
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local shp = pile{{"bone black",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"lead white",0.35}, medium=0.15}
local sm = poly({Wc(-0.45, 6.0), Wc(-0.05, 6.0), Wc(0.02, 3.0), Wc(-0.62, 3.0)}):soften(6) * PATCH
work(sm, {hand="body", tool="filbert 8", pile=shp, angle=TOVP, coverage=2.2, fill=true, clip=sm})
blend(sm:grow(3) * PATCH, {angle=TOVP})
-- warm bounce from the lit floor onto the foot of the walls by the end
local bounce = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.6},{"lead white",0.25}, medium=0.3}
for _, side in ipairs{-1, 1} do
  local m = WQ(side, 1.0, 1.4, 0.0, 0.55):soften(8) * WALLV
  work(m, {hand="scumble", pile=bounce, angle=TOVP, coverage=1.2, clip=m, pressure={0.25, 0.45}})
end

--@ chunk 122
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local sm = poly({Wc(-0.45, 6.0), Wc(-0.05, 6.0), Wc(0.02, 3.0), Wc(-0.62, 3.0)}):soften(6):grow(6) * FLOOR
local bm = nil
for _, side in ipairs{-1, 1} do
  local m = WQ(side, 1.0, 1.4, 0.0, 0.55):soften(8):grow(25) * (LWALL + RWALL)
  bm = bm and (bm + m) or m
end
for i = 1, 3 do
  work(sm, {hand="blend", tool={kind="flat", width=12}, blender=true, angle=TOVP, coverage=2, dips={4, 0, 0.95}})
  work(bm, {hand="blend", tool={kind="flat", width=12}, blender=true, angle=TOVP, coverage=2, dips={4, 0, 0.95}})
end

--@ chunk 123
print(wait(8*24*60)); for _,p in ipairs{{480,600},{300,450},{100,450},{240,270},{790,400}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 124
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local FL = FLOOR - RIBALL
local P = poly({{417,519},{671,519},{789,667},{301,667}}):soften(4) * FL
local stripe = poly({Wc(-0.4, 6.0), Wc(-0.1, 6.0), Wc(-0.12, 3.4), Wc(-0.42, 3.4)}):soften(5)
local dark = FL - P
local Dfl = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.5},{"lead white",0.12}, medium=0.08}
work(dark, {hand="body", tool="filbert 8", pile=Dfl, angle=TOVP, coverage=3.5, fill=true, clip=dark})
local lit = {
  pile{{"lead white",1.2},{"yellow ochre",0.8},{"burnt sienna",0.35},{"bone black",0.3}, medium=0.08},
  pile{{"lead white",0.6},{"yellow ochre",0.6},{"burnt sienna",0.4},{"bone black",0.6}, medium=0.08},
  pile{{"lead white",0.25},{"yellow ochre",0.4},{"burnt sienna",0.4},{"bone black",1.0}, medium=0.08},
}
local sh = {
  pile{{"lead white",0.8},{"yellow ochre",0.7},{"burnt sienna",0.4},{"bone black",0.5}, medium=0.08},
  pile{{"lead white",0.4},{"yellow ochre",0.5},{"burnt sienna",0.4},{"bone black",0.8}, medium=0.08},
  pile{{"lead white",0.15},{"yellow ochre",0.35},{"burnt sienna",0.4},{"bone black",1.2}, medium=0.08},
}
local ys = {{519, 562}, {558, 617}, {613, 667}}
for i, y in ipairs(ys) do
  local sec = rect(250, y[1], 600, y[2] - y[1]):soften(4) * P
  local a = sec - stripe
  local b = sec * stripe
  work(a, {hand="body", tool="filbert 6", pile=lit[i], angle=TOVP, coverage=3.5, fill=true, clip=a})
  work(b, {hand="body", tool="filbert 6", pile=sh[i], angle=TOVP, coverage=3.5, fill=true, clip=b})
end

--@ chunk 125
-- chairs of the Testament, seen from behind. World: eye 1.2 m up, end plane at 6 m; X right, Z away.
function W2C(X, Y, Z, vx, vy) -- world -> canvas, Y up from floor
  local k = 175 * 6 / Z
  return (vx or VX) + X * k, (vy or VY) + (1.2 - Y) * k, k
end
-- one chair as a list of shapes (polys) and leg lines; v = variation
function CHAIRSHAPES(X, Z, v, vx, vy)
  local function P(x, y) local cx, cy = W2C(X + x, y, Z, vx, vy); return {cx, cy} end
  local w, top, L = 0.27 + v.dw, 1.34 + v.dh, v.lean
  local back = {
    P(-0.11 + L*0.5, 0.50), P(-0.20 + L*0.7, 0.68), P(-w + L*0.9, 0.95), P(-w - 0.01 + L, 1.18),
    P(-w + 0.02 + L, top + 0.03), P(-0.13 + L, top - 0.01), P(0.0 + L, top - 0.06),
    P(0.13 + L, top - 0.01), P(w - 0.02 + L, top + 0.03), P(w + 0.01 + L, 1.18),
    P(w + L*0.9, 0.95), P(0.20 + L*0.7, 0.68), P(0.11 + L*0.5, 0.50)}
  local seat = {P(-0.33, 0.41), P(0.33, 0.41), P(0.35, 0.45), P(0.31, 0.49), P(-0.31, 0.49), P(-0.35, 0.45)}
  local legs = {
    {P(-0.27, 0.41), P(-0.29, 0.2), P(-0.33, 0.0)},
    {P(0.27, 0.41), P(0.29, 0.2), P(0.33, 0.0)},
  }
  local farlegs = {}
  do
    local function Q(x, y) local cx, cy = W2C(X + x, y, Z + 0.55, vx, vy); return {cx, cy} end
    farlegs = {{Q(-0.25, 0.41), Q(-0.27, 0.0)}, {Q(0.25, 0.41), Q(0.27, 0.0)}}
  end
  return back, seat, legs, farlegs
end
function CHAIRMASK(X, Z, v, vx, vy)
  local b, s = CHAIRSHAPES(X, Z, v, vx, vy)
  return poly(b, true) + poly(s, true)
end
function CHAIRVAR(seed)
  local r1 = ((seed * 0.618034) % 1)
  local r2 = ((seed * 0.414214 + 0.3) % 1)
  local r3 = ((seed * 0.732051 + 0.7) % 1)
  return {dh = (r1 - 0.5) * 0.12, dw = (r2 - 0.5) * 0.06, lean = (r3 - 0.5) * 0.06}
end
-- draw a chair's legs with a brush b (already loaded)
function CHAIRLEGS(b, X, Z, v, vx, vy, clipm)
  local _, _, legs, far = CHAIRSHAPES(X, Z, v, vx, vy)
  for _, l in ipairs(far) do b:stroke(l, {pressure={0.6, 0.5}, clip=clipm}) end
  for _, l in ipairs(legs) do b:stroke(l, {pressure={0.7, 0.5}, clip=clipm}) end
end
local function Wc(X, Z) local x, y = W2C(X, 0, Z); return {x, y} end
local FL = FLOOR - RIBALL
local P = poly({{417,519},{671,519},{789,667},{301,667}}) * FL
blend(rect(250, 546, 600, 28) * P, {angle=math.pi/2})
blend(rect(250, 600, 600, 30) * P, {angle=math.pi/2})
local e1 = ribbon({Wc(-0.4, 6.0), Wc(-0.42, 3.4)}, 12) * P
local e2 = ribbon({Wc(-0.1, 6.0), Wc(-0.12, 3.4)}, 12) * P
blend(e1, {angle=0}); blend(e2, {angle=0})

--@ chunk 126
print(wait(7*24*60)); for _,p in ipairs{{480,600},{545,540},{100,450},{60,500},{940,470}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 127
local M = rect(195, 380, 150, 270) + rect(745, 380, 150, 270)
local bay1 = (RECTS(1.27) - RECTS(1.0)) * WALLV * M
local Wb = pile{{"bone black",2},{"burnt sienna",0.55},{"yellow ochre",0.25},{"lead white",0.3}, medium=0.08}
work(bay1, {hand="body", tool="filbert 6", pile=Wb, angle=TOVP, coverage=4, fill=true, clip=bay1})
local fr = RIBFRONT(1.27) * M
local RFp = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.6},{"lead white",0.2}, medium=0.08}
work(fr, {hand="body", tool="filbert 4", pile=RFp, angle=TOVP, coverage=4, fill=true, clip=fr})
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local so = (RIBSOFF(1.27) - PIPEM) * M
local SOp = pile{{"bone black",1.4},{"lead white",0.6},{"burnt sienna",0.4},{"yellow ochre",0.25}, medium=0.08}
work(so, {hand="body", tool="filbert 4", pile=SOp, angle=TOVP, coverage=4, fill=true, clip=so})

--@ chunk 128
print(wait(6*24*60)); for _,p in ipairs{{250,500},{800,500},{545,600},{545,540}} do print(p[1],p[2],drying(p[1],p[2])) end

--@ chunk 129
print(wait(3*24*60)); print(drying(800,500), drying(820,450))

--@ chunk 130
local walls = (rect(190, 360, 160, 300) + rect(740, 360, 160, 300)):soften(10) * CORR - FLOOR
work(walls, {hand="body", tool="filbert 8", pile=sgDark, angle=TOVP, coverage=3, fill=true, clip=walls})
blend(walls, {angle=TOVP})
local fl = (FLOOR - RIBALL) * below(function(x) return 556 end)
work(fl, {hand="body", tool="filbert 10", pile=sgMid, angle=TOVP, fill=true, clip=fl,
  coverage=2.4, load_at=function(x, y) return clamp((y - 556) / 100, 0.1, 1) end})
blend(fl, {angle=TOVP})

--@ chunk 131
print(wait(5*24*60)); print(drying(250,450), drying(800,450), drying(545,620))

--@ chunk 132
local walls = (rect(190, 120, 160, 270) + rect(740, 120, 160, 270)) * CORR - FLOOR - CEIL - PLQ - PATCHW
work(walls, {hand="body", tool="filbert 8", pile=sgDark, angle=TOVP, fill=true, clip=walls,
  coverage=2.6, load_at=function(x, y) return clamp((y - 180) / 200, 0.1, 1) end})
blend(walls, {angle=TOVP})

--@ chunk 133
pb1 = pile{{"raw sienna",2},{"bone black",1.2},{"burnt sienna",1}, medium=0.08}
pb2 = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}, medium=0.08}
pbD = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"ultramarine blue",0.2}, medium=0.08}
pb3 = pile{{"burnt sienna",2},{"Mars brown",1},{"yellow ochre",0.8},{"bone black",0.6}, medium=0.08}
pshad = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",1}, medium=0.15}
-- body of one scale plate centred (x,y), radial direction ang (outward), size sz
function PLATE_BODY(x, y, ang, sz, pl, clipm)
  local c, s = math.cos(ang), math.sin(ang)
  local L = sz * 0.45
  local b = brush{kind="filbert", width=sz*1.12, stiffness=0.5}
  b:load(pl, 0.8)
  b:stroke({{x - c*L, y - s*L}, {x + c*L*0.5, y + s*L*0.5}},
    {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=clipm})
end
-- the shadow cast just outside a plate's free (outer) edge
function PLATE_SHADOW(x, y, ang, sz, clipm, w)
  local pts = {}
  local R = sz * 0.52
  for k = -3, 3 do
    local a = ang + k * 0.33
    pts[#pts+1] = {x + math.cos(ang)*sz*0.12 + math.cos(a)*R, y + math.sin(ang)*sz*0.12 + math.sin(a)*R}
  end
  local b = brush{kind="round", width=w or 5, point=0.2}
  b:load(pshad, 0.7)
  b:stroke(pts, {pressure={0.45, 0.75}, swell={0.5, 1, 0.5}, clip=clipm})
end
-- a glint on the plate's rim on the side facing (lx,ly)
function PLATE_GLINT(x, y, ang, sz, lx, ly, pl, amt, clipm)
  local a = math.atan(ly - y, lx - x)
  -- keep the glint on the outer (raised) half of the rim
  local R = sz * 0.42
  local pts = {}
  for k = -2, 2 do
    local b2 = a + k * 0.25
    pts[#pts+1] = {x + math.cos(b2)*R, y + math.sin(b2)*R}
  end
  local b = brush{kind="round", width=2.2, point=0.7}
  b:load(pl, 0.55)
  b:stroke(pts, {pressure={0.1, 0.55*amt + 0.1}, swell={0.4, 1, 0.3}, clip=clipm})
end
-- Vogel positions about (cx,cy), spacing c, inside mask m
function VOGEL(cx, cy, c, nmax, m)
  local out = {}
  for n = 1, nmax do
    local r = c * math.sqrt(n)
    local th = n * 2.399963
    local x, y = cx + r*math.cos(th), cy + r*math.sin(th)
    if m:at(x, y) > 0.3 then out[#out+1] = {x=x, y=y, a=th, n=n, r=r} end
  end
  return out
end
local glitM = pile{{"yellow ochre",2},{"burnt sienna",0.7},{"lead white",0.5}, medium=0.08}
local glitH = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.2}, medium=0.08}
local verd = pile{{"viridian",1},{"cerulean blue",0.6},{"lead white",0.8},{"yellow ochre",0.4},{"bone black",0.6}, medium=0.08}
local W = BRONZE - PLQ:grow(0) 
local n = 0
for i, p in ipairs(PLATES) do
  local d = CUTDIST(p.x, p.y)
  local amt = clamp(1 - d / 120, 0, 1)
  if amt > 0.05 then
    local a = math.atan(330 - p.y, 543 - p.x)
    local R = 21 * 0.4
    local pts = {}
    for k = -2, 2 do local b2 = a + k * 0.26; pts[#pts+1] = {p.x + math.cos(b2)*R, p.y + math.sin(b2)*R} end
    local b = brush{kind="round", width=1.8 + 1.2*amt, point=0.6}
    b:load((amt > 0.6) and glitH or glitM, 0.7)
    b:stroke(pts, {pressure={0.3, 0.55 + 0.4*amt}, swell={0.5, 1, 0.4}, clip=BRONZE})
    n = n + 1
  end
end
print("glints", n)
-- verdigris crusts in the lee of a few plates, away from the cut
local m = 0
for i, p in ipairs(PLATES) do
  local h = ((p.n * 0.618034) % 1)
  if h < 0.16 and CUTDIST(p.x, p.y) > 30 then
    local a = p.a
    local x, y = p.x + math.cos(a) * 9, p.y + math.sin(a) * 9
    stipple(ellipse(x, y, 6, 4):soften(2) * BRONZE, {pile=verd, width=1.6, coverage=2.5, feather=0.6, cluster=0.5})
    m = m + 1
  end
end
print("verd", m)

--@ chunk 134
print(wait(3*24*60))

--@ chunk 135
local board2 = pile{{"lead white",0.8},{"bone black",0.55},{"yellow ochre",0.4},{"burnt sienna",0.12}, medium=0.08}
local yel2 = pile{{"cadmium yellow",1},{"yellow ochre",0.8},{"bone black",0.45},{"burnt sienna",0.2}, medium=0.08}
work(PLAC, {hand="detail", pile=board2, coverage=4, fill=true, clip=PLAC})
work(SIGN, {hand="detail", pile=yel2, coverage=4, fill=true, clip=SIGN})

--@ chunk 136
print(wait(5*24*60)); print(drying(380,270), drying(705,230), drying(720,180))

--@ chunk 137
local board3 = pile{{"lead white",1},{"bone black",1.4},{"yellow ochre",0.5},{"burnt sienna",0.15}, medium=0.08}
work(PLAC, {hand="detail", pile=board3, coverage=4, fill=true, clip=PLAC})
-- verdigris knocked back with a warm earth veil
local vg = pile{{"burnt sienna",1},{"bone black",0.6},{"Mars brown",0.4}, medium=0.6}
local V2 = (rect(660, 120, 100, 400) + rect(330, 120, 100, 400)) * BRONZE
stipple(V2, {pile=vg, width=2.2, coverage=0.9, feather=0.3, cluster=0.3})

--@ chunk 138
print(wait(6*24*60)); print(drying(380,270), drying(705,230), drying(720,180))

--@ chunk 139
iD = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.4},{"lead white",0.12}, medium=0.08}
iM = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.3},{"lead white",0.5}, medium=0.08}
iRim = pile{{"lead white",1.5},{"yellow ochre",1},{"burnt sienna",0.3}, medium=0.08}
local function rod(pts, w, pl, pr)
  local b = brush{kind="round", width=w, stiffness=0.6}
  b:load(pl or iD, 0.9)
  b:stroke(pts, {pressure=pr or {0.8, 0.75}, shake=0.2})
end
-- tripod standing on the corridor floor just left of the sill, aimed into the cut
rod({{398,352},{372,512}}, 3.2)
rod({{402,354},{430,524}}, 3.2)
rod({{400,354},{404,505}}, 2.6)
rod({{386,428},{418,436}}, 1.6)
TRI = poly({{378,330},{414,327},{418,356},{381,359}})
work(TRI, {hand="detail", pile=iD, coverage=4, fill=true, clip=TRI})
local face = poly({{414,327},{424,331},{427,353},{418,356}})
work(face, {hand="detail", pile=iM, coverage=4, fill=true, clip=face})
local lens = poly({{424,335},{438,336},{438,348},{425,349}})
work(lens, {hand="detail", pile=iD, coverage=4, fill=true, clip=lens})
rod({{415,328},{425,331},{427,352}}, 1.1, iRim, {0.6, 0.5})
rod({{426,335},{437,336}}, 0.9, iRim, {0.5, 0.4})
-- a little status lamp, dead
local lamp = brush{kind="round", width=2.4}
lamp:load(pile{{"vermilion",0.5},{"bone black",1.5}, medium=0.1}, 0.8)
lamp:touch(386, 336, {pressure=0.6})

--@ chunk 140
local function rod(pts, w, pl, pr)
  local b = brush{kind="round", width=w, stiffness=0.6}
  b:load(pl or iD, 0.9)
  b:stroke(pts, {pressure=pr or {0.8, 0.75}, shake=0.2})
end
-- feet reach the floor
rod({{373,505},{370,530}}, 3.2); rod({{429,518},{432,534}}, 3.2); rod({{404,500},{405,528}}, 2.6)
-- the scraper rig on the right: a rail bolted to the bronze, a carriage, an arm and blade into the cut's edge
RAIL2 = poly({{684,150},{691,150},{693,490},{686,490}})
work(RAIL2, {hand="detail", pile=iD, coverage=4, fill=true, clip=RAIL2})
rod({{693,152},{694,488}}, 0.9, iRim, {0.4, 0.3})
for _, y in ipairs{170, 260, 380, 470} do
  local b = brush{kind="round", width=3.2}; b:load(iM, 0.8); b:touch(688.5, y, {pressure=0.7})
end
CAR2 = poly({{676,300},{700,299},{701,332},{677,333}})
work(CAR2, {hand="detail", pile=iM, coverage=4, fill=true, clip=CAR2})
rod({{677,316},{664,322},{655,331}}, 3.2)
rod({{655,331},{650,341}}, 1.6, iM)
rod({{700,300},{701,331}}, 0.9, iRim, {0.3, 0.3})
-- sensor pods clamped to the bronze, with cable tails
for _, p in ipairs{{365,150,22,16},{712,176,18,14},{705,436,20,16},{360,470,18,14}} do
  local m = rect(p[1], p[2], p[3], p[4])
  work(m, {hand="detail", pile=iM, coverage=4, fill=true, clip=m})
  rod({{p[1] + p[3], p[2] + 2}, {p[1] + p[3] + 0.5, p[2] + p[4] - 2}}, 0.8, iRim, {0.3, 0.3})
end
rod({{376,166},{372,240},{366,320},{360,330}}, 1.6, iD, {0.6, 0.5})
rod({{721,190},{724,300},{716,420},{714,436}}, 1.6, iD, {0.6, 0.5})

--@ chunk 141
print(drying(430,300), drying(655,300), drying(545,145), drying(380,270))
local cell = pile{{"burnt sienna",1},{"Mars brown",0.7},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.08}
local C = CELLS:shrink(0.6) * SIDES
work(C, {hand="detail", pile=cell, coverage=3.5, fill=true, clip=C})
print(C:area())

--@ chunk 142
print(wait(5*24*60)); print(drying(380,270), drying(705,230), drying(430,300))

--@ chunk 143
-- letter-like marks along a line, by hand
function SCRIBBLE(x0, y0, x1, y1, h, pl, w, clipm, gaps)
  local b = brush{kind="round", width=w or 1.3, point=0.8}
  b:load(pl, 0.7)
  local len = math.sqrt((x1-x0)^2 + (y1-y0)^2)
  local ux, uy = (x1-x0)/len, (y1-y0)/len
  local vx, vy = -uy, ux
  local t, n = 0, 0
  while t < len do
    local cw = h * rand(0.45, 0.8)
    if gaps and math.random() < 0.18 then t = t + cw * 0.9 else
      local x, y = x0 + ux*t, y0 + uy*t
      local kind = math.random(1, 5)
      local function P(a, c) return {x + ux*a*cw + vx*c*h, y + uy*a*cw + vy*c*h} end
      if kind == 1 then b:stroke({P(0.1,-0.5), P(0.15,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.15,-0.5), P(0.75,-0.45)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 2 then b:stroke({P(0.1,0.5), P(0.4,-0.5), P(0.75,0.5)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 3 then b:stroke({P(0.7,-0.4), P(0.2,-0.5), P(0.15,0.4), P(0.7,0.5)}, {pressure={0.6,0.5}, clip=clipm})
      elseif kind == 4 then b:stroke({P(0.2,-0.5), P(0.2,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.6,-0.5), P(0.6,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.2,0.0), P(0.6,0.0)}, {pressure={0.5,0.5}, clip=clipm})
      else b:stroke({P(0.15,0.5), P(0.45,-0.5), P(0.75,0.5)}, {pressure={0.6,0.5}, clip=clipm})
        b:stroke({P(0.3,0.1), P(0.6,0.1)}, {pressure={0.5,0.5}, clip=clipm}) end
      t = t + cw
      n = n + 1
      if n % 6 == 0 then b:load(pl, 0.7) end
    end
  end
end
local redp2 = pile{{"vermilion",1},{"burnt sienna",0.8},{"bone black",0.35}, medium=0.1}
local ink2 = pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.12}
local rb = brush{kind="round", width=2.4, point=0.4}
rb:load(redp2, 0.8)
rb:stroke({{359,239},{408,234},{410,298},{362,302},{359,239}}, {pressure={0.7,0.6}, clip=PLAC, shake=1})
SCRIBBLE(366, 251, 404, 248, 8, redp2, 1.9, PLAC)
SCRIBBLE(366, 264, 404, 261, 5, ink2, 1.1, PLAC, true)
SCRIBBLE(366, 273, 403, 270, 5, ink2, 1.1, PLAC, true)
SCRIBBLE(367, 282, 400, 280, 5, ink2, 1.1, PLAC, true)
SCRIBBLE(367, 292, 392, 290, 4, ink2, 1.0, PLAC, true)
-- tape at the corners
local tape = pile{{"lead white",1},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.08}
for _, c in ipairs{{358,237,-0.6},{409,232,0.6},{411,300,-0.6},{361,304,0.6}} do
  local b = brush{kind="flat", width=4}
  b:load(tape, 0.8)
  b:stroke({{c[1] - 4*math.cos(c[3]), c[2] - 4*math.sin(c[3])}, {c[1] + 4*math.cos(c[3]), c[2] + 4*math.sin(c[3])}}, {pressure={0.7,0.7}, orient="across"})
end
-- the printed sign
local tri = poly({{706,211},{723,240},{689,240}})
local trin = poly({{706,217},{718,237},{694,237}})
work(tri - trin, {hand="detail", pile=ink2, coverage=3, fill=true, clip=tri - trin})
local kb = brush{kind="round", width=2, point=0.5}
kb:load(ink2, 0.8)
kb:stroke({{706,222},{706,231}}, {pressure={0.7,0.4}, clip=SIGN})
kb:touch(706, 234.5, {pressure=0.5, clip=SIGN})
local bar = rect(686, 243, 41, 8) * SIGN
work(bar, {hand="detail", pile=ink2, coverage=3, fill=true, clip=bar})

--@ chunk 144
local where = everywhere() - FIGM2
local cabHi2 = pile{{"lead white",1.2},{"yellow ochre",0.8},{"burnt sienna",0.3}, medium=0.08}
function CABLE2(c, w0, w1, hiside)
  local n = #c
  for i = 1, n - 1 do
    local t = (i - 0.5) / (n - 1)
    local w = lerp(w0, w1, t)
    local b = brush{kind="round", width=w, stiffness=0.4}
    b:load(cabD, 0.95)
    local a, z = c[i], c[i+1]
    local ex, ey = (z[1]-a[1])*0.15, (z[2]-a[2])*0.15
    b:stroke({{a[1]-ex, a[2]-ey}, {z[1]+ex, z[2]+ey}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, clip=where})
  end
  -- a thin highlight along the far (upper) edge where the cut's light rakes it
  local hp = {}
  for i = 1, n do
    local t = (i - 1) / (n - 1)
    local w = lerp(w0, w1, t)
    hp[#hp+1] = {c[i][1], c[i][2] - w * 0.35}
  end
  local hb = brush{kind="round", width=math.max(0.7, w0 * 0.25), point=0.5}
  hb:load(cabHi2, 0.6)
  hb:stroke(hp, {pressure={0.5, 0.15}, clip=where})
end
-- into the hall: a lead from the tripod across the sill and down the aisle edge
CABLE2({{404,512},{430,506},{455,496},{475,486},{492,476},{505,462},{512,450},{516,438},{518,428}}, 2.4, 1.3)
-- out along the corridor floor from the tripod
CABLE2({{372,528},{360,550},{352,580},{330,615},{300,645},{270,667}}, 4, 9)
CABLE2({{430,532},{420,560},{424,595},{410,630},{380,667}}, 4, 8)
-- from the scraper rig, down the right jamb and over the sill
CABLE2({{690,488},{676,500},{650,508},{628,516},{640,540},{672,575},{700,615},{720,667}}, 3, 8)

--@ chunk 145
print(wait(3*24*60)); print(drying(545,600), drying(545,540), drying(300,640))

--@ chunk 146
local FL = FLOOR - RIBALL
local CAB = nil
local function cabm(c, w) local r = ribbon(c, w); CAB = CAB and (CAB + r) or r end
cabm({{372,528},{360,550},{352,580},{330,615},{300,645},{270,667}}, 9)
cabm({{430,532},{420,560},{424,595},{410,630},{380,667}}, 9)
cabm({{628,516},{640,540},{672,575},{700,615},{720,667}}, 9)
FLW = FL - CAB
local fan = poly({{417,519},{671,519},{760,600},{800,667},{290,667},{335,600}})
local bands = {
  {545, 576, pile{{"lead white",0.7},{"yellow ochre",0.6},{"burnt sienna",0.45},{"bone black",0.55}, medium=0.08}},
  {573, 608, pile{{"lead white",0.35},{"yellow ochre",0.45},{"burnt sienna",0.45},{"bone black",0.8}, medium=0.08}},
  {605, 645, pile{{"lead white",0.15},{"yellow ochre",0.3},{"burnt sienna",0.45},{"bone black",1.05}, medium=0.08}},
}
local dark = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.5},{"lead white",0.1}, medium=0.08}
local rest = (FLW - fan * above(function(x) return 645 end)) * below(function(x) return 545 end) - (fan * above(function(x) return 545 end))
work(FLW * below(function(x) return 545 end) - fan * above(function(x) return 645 end), {hand="body", tool="filbert 8", pile=dark, angle=TOVP, coverage=3.5, fill=true, clip=FLW})
for _, b in ipairs(bands) do
  local m = fan * rect(200, b[1], 700, b[2] - b[1]) * FLW
  work(m, {hand="body", tool="filbert 6", pile=b[3], angle=TOVP, coverage=3.5, fill=true, clip=m})
end
for _, y in ipairs{545, 575, 606, 644} do
  blend(fan:grow(10) * rect(200, y - 9, 700, 18) * FLW, {angle=math.pi/2})
end

--@ chunk 147
print(wait(4*24*60)); print(drying(545,600), drying(300,640), drying(240,250), drying(800,400))

--@ chunk 148
local walls = (LWALL + RWALL)
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local bayp = {
  pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.4},{"lead white",0.28}, medium=0.08},
  pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.5},{"lead white",0.18}, medium=0.08},
  pile{{"bone black",2},{"burnt sienna",0.45},{"ultramarine ash",0.55},{"lead white",0.1}, medium=0.08},
  pile{{"bone black",2},{"burnt sienna",0.4},{"ultramarine ash",0.6},{"lead white",0.05}, medium=0.08},
}
local edges = {1.0, 1.27, 1.66, 2.25, 4}
for i = 1, 4 do
  local m = (RECTS(edges[i+1]) - RECTS(edges[i])) * walls - RIBALL - COLLAR - COLSOFF - PIPEM - FLOOR - CEIL
  work(m, {hand="body", tool="filbert 7", pile=bayp[i], angle=TOVP, coverage=4, fill=true, clip=m})
end

--@ chunk 149
local cover = nil
for i, p in ipairs(PLATES) do
  local h = ((p.n * 0.618034) % 1)
  if h < 0.16 and CUTDIST(p.x, p.y) > 30 then
    local x, y = p.x + math.cos(p.a) * 9, p.y + math.sin(p.a) * 9
    local e = ellipse(x, y, 8, 6)
    cover = cover and (cover + e) or e
  end
end
cover = cover * BRONZE - SIGN - PLAC
stipple(cover, {pile=pbO2, width=2.6, coverage=4, cluster=0.2})
-- then a breath of verdigris, only in the hollows of a few
local verd2 = pile{{"viridian",0.6},{"bone black",1},{"yellow ochre",0.5},{"lead white",0.5},{"burnt sienna",0.3}, medium=0.08}
local few = nil
for i, p in ipairs(PLATES) do
  local h = ((p.n * 0.618034) % 1)
  if h < 0.07 and CUTDIST(p.x, p.y) > 30 then
    local x, y = p.x + math.cos(p.a) * 9, p.y + math.sin(p.a) * 9
    local e = ellipse(x, y, 4, 3)
    few = few and (few + e) or e
  end
end
few = few * BRONZE - SIGN - PLAC
stipple(few, {pile=verd2, width=1.4, coverage=1.5, feather=0.5, cluster=0.6})

--@ chunk 150
local lipH = pile{{"lead white",2},{"yellow ochre",1},{"Mars orange",0.15}, medium=0.08}
local lipM = pile{{"yellow ochre",1.5},{"burnt sienna",0.6},{"lead white",0.8}, medium=0.08}
-- the cut's raw front lip: each side as its own stroke, lit most where it faces the glow
local sides = {
  {{417,505},{416,420},{416,330},{419,250},{422,172}},
  {{422,172},{436,150},{452,131}},
  {{452,131},{500,128},{548,127},{590,129},{632,133}},
  {{632,133},{650,148},{665,165}},
  {{665,165},{667,250},{668,330},{670,420},{671,506}},
}
for i, s in ipairs(sides) do
  local pts = {}
  for _, p in ipairs(s) do pts[#pts+1] = {p[1] + rand(-0.6, 0.6), p[2] + rand(-0.6, 0.6)} end
  local b = brush{kind="round", width=2.2, point=0.5}
  b:load((i == 3 or i == 1 or i == 5) and lipH or lipM, 0.75)
  b:stroke(pts, {pressure={0.45, 0.55}, swell={0.6, 1.1, 0.8, 1.0, 0.5}, shake=0.8})
end
-- the sill's front edge, brightest of all
local b = brush{kind="round", width=2.6, point=0.4}
b:load(lipH, 0.8)
b:stroke({{420,505},{480,507},{545,509},{610,508},{668,506}}, {pressure={0.55, 0.5}, swell={0.7, 1, 1, 0.8}, shake=0.6})

--@ chunk 151
print(wait(6*24*60)); print(drying(545,600), drying(545,560), drying(300,640), drying(100,300), drying(545,40))

--@ chunk 152
local FL = FLOOR - RIBALL
local sd = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.08}
local sl = pile{{"lead white",1.3},{"yellow ochre",0.8},{"burnt sienna",0.3},{"bone black",0.2}, medium=0.08}
local function ln(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.3}
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr or {0.6, 0.6}, clip=FL, shake=0.3})
end
-- deck plate seams: across, at the plate joints, and two running toward the cut
for _, s in ipairs{1.12, 1.33, 1.62, 2.1} do
  local y = VY + 210 * s
  ln({{VX - 230*s, y}, {VX + 230*s, y}}, sd, 1.3 * s)
  ln({{VX - 150*s, y + 1.1*s}, {VX + 150*s, y + 1.1*s}}, sl, 0.55 * s, {0.3, 0.3})
end
for _, X in ipairs{-0.55, 0.62} do ln({FLP(1.0, X), FLP(2.2, X)}, sd, 1.6, {0.5, 0.8}) end
-- scuffs and drag marks in the light, toward the cut (boots, carts)
for i = 1, 26 do
  local x0 = rand(430, 650); local y0 = rand(525, 600)
  local ang = math.atan(VY - y0, VX - x0) + rand(-0.25, 0.25)
  local L = rand(6, 22)
  local pl = (math.random() < 0.6) and sd or sl
  ln({{x0, y0}, {x0 + math.cos(ang)*L, y0 + math.sin(ang)*L}}, pl, rand(0.6, 1.4), {0.25, 0.05})
end

--@ chunk 153
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local patchC = pile{{"bone black",1.4},{"lead white",0.45},{"viridian",0.12},{"yellow ochre",0.15}, medium=0.08}
local tapeC = pile{{"lead white",0.9},{"bone black",0.8},{"yellow ochre",0.35}, medium=0.08}
local glassC = pile{{"bone black",2},{"ultramarine ash",0.6},{"viridian",0.1},{"lead white",0.15}, medium=0.08}
local reflC = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.8},{"lead white",0.4}, medium=0.08}
local frameC = pile{{"bone black",2},{"burnt sienna",0.4},{"lead white",0.25}, medium=0.08}
-- a mismatched replacement panel, taped at its seams
local P1 = cq(1.32, 1.42, -1.0, -0.35)
work(P1, {hand="detail", pile=patchC, coverage=4, fill=true, clip=P1})
local b = brush{kind="flat", width=2.6}
for _, e in ipairs{{CLP(1.32,-1.02), CLP(1.32,-0.33)}, {CLP(1.42,-1.02), CLP(1.42,-0.33)}, {CLP(1.31,-0.35), CLP(1.43,-0.35)}, {CLP(1.31,-1.0), CLP(1.43,-1.0)}} do
  b:load(tapeC, 0.8); b:stroke(e, {pressure={0.6, 0.55}, orient="across", shake=0.5})
end
-- a dead light fitting, its glass holding a sliver of the cut's glow
local F = cq(1.3, 1.44, 0.05, 0.8)
work(F, {hand="detail", pile=frameC, coverage=4, fill=true, clip=F})
local G = cq(1.315, 1.425, 0.1, 0.75)
work(G, {hand="detail", pile=glassC, coverage=4, fill=true, clip=G})
local rb = brush{kind="round", width=1.4, point=0.4}
rb:load(reflC, 0.7)
rb:stroke({CLP(1.32, 0.15), CLP(1.32, 0.6)}, {pressure={0.6, 0.2}, clip=G})

--@ chunk 154
print(wait(4*24*60)); print(drying(400,20), drying(700,20))

--@ chunk 155
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local patchC2 = pile{{"bone black",2},{"lead white",0.18},{"viridian",0.12},{"yellow ochre",0.12},{"burnt sienna",0.15}, medium=0.08}
local tapeC2 = pile{{"bone black",1.4},{"lead white",0.3},{"yellow ochre",0.3}, medium=0.08}
local P1 = cq(1.325, 1.415, -0.99, -0.36)
work(P1, {hand="detail", pile=patchC2, coverage=4, fill=true, clip=P1})
local b = brush{kind="flat", width=2.4}
for _, e in ipairs{{CLP(1.32,-1.02), CLP(1.32,-0.33)}, {CLP(1.42,-1.02), CLP(1.42,-0.33)}, {CLP(1.31,-0.35), CLP(1.43,-0.35)}, {CLP(1.31,-1.0), CLP(1.43,-1.0)}} do
  b:load(tapeC2, 0.8); b:stroke(e, {pressure={0.6, 0.55}, orient="across", shake=0.5})
end
local reflC = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.5}, medium=0.08}
local G = cq(1.315, 1.425, 0.1, 0.75)
local rb = brush{kind="round", width=2.2, point=0.2}
rb:load(reflC, 0.8)
rb:stroke({CLP(1.325, 0.14), CLP(1.322, 0.62)}, {pressure={0.8, 0.4}, clip=G})

--@ chunk 156
print(wait(5*24*60)); print(drying(60,300), drying(940,300), drying(545,5), drying(150,650))

--@ chunk 157
local edge = (-(RECTS(1.95))) * CORR
work(edge, {hand="body", tool="filbert 10", pile=sgDark, angle=TOVP, coverage=3, fill=true, clip=edge,
  load_at=function(x, y)
    local dx = math.max(0, math.abs(x - VX) - 330) / 215
    local dy = math.max(0, math.max(VY - y - 280, y - VY - 260)) / 80
    return clamp(math.max(dx, dy), 0.25, 1)
  end})
blend(edge, {angle=TOVP})

--@ chunk 158
local fix = PLQ:grow(1.5) * rect(150, 150, 72, 200)
local p = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.6},{"lead white",0.06}, medium=0.08}
work(fix, {hand="detail", pile=p, coverage=4, fill=true, clip=fix})
local fl = (FLOOR - RIBALL) * below(function(x) return 600 end)
work(fl, {hand="body", tool="filbert 10", pile=sgDark, angle=TOVP, coverage=3, fill=true, clip=fl,
  load_at=function(x, y) return clamp((y - 600) / 67, 0.15, 0.9) end})
blend(fl, {angle=TOVP})

--@ chunk 159
local CABM = ribbon({{372,528},{360,550},{352,580}}, 7) + ribbon({{430,532},{420,560}}, 7) + ribbon({{628,516},{640,540},{672,575}}, 7)
local band = poly({FLP(1.008, -1.25), FLP(1.008, 1.25), FLP(1.065, 1.25), FLP(1.065, -1.25)}) * (FLOOR - RIBALL) - CABM
BAND = band
local amberF = pile{{"chrome yellow",1},{"Mars orange",0.9},{"burnt sienna",0.3},{"bone black",0.25}, medium=0.08}
local blackF = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.08}
work(band, {hand="detail", pile=amberF, coverage=4, fill=true, clip=band})
local b = brush{kind="flat", width=5.5, stiffness=0.6}
for X = -1.3, 1.3, 0.11 do
  local a = FLP(1.065, X); local c = FLP(1.008, X + 0.07)
  b:load(blackF, 0.9)
  b:stroke({a, c}, {pressure={0.8, 0.8}, orient="across", clip=band})
end

--@ chunk 160
print(wait(5*24*60)); print(drying(545,526), drying(340,526))

--@ chunk 161
print(wait(5*24*60)); print(drying(545,526), drying(340,526))

--@ chunk 162
print(wait(4*24*60)); print(drying(545,526), drying(340,526), drying(760,526))

--@ chunk 163
local blackF = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.08}
local b = brush{kind="flat", width=7, stiffness=0.6}
for X = -1.3, 1.3, 0.12 do
  local a = FLP(1.07, X); local c = FLP(1.0, X + 0.08)
  b:load(blackF, 0.95)
  b:stroke({a, c}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=BAND})
end
-- the band falls into shadow toward the walls
local shade = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}, medium=0.75}
local ends = BAND * (rect(0, 500, 400, 50) + rect(690, 500, 400, 50))
work(ends, {hand="detail", pile=shade, coverage=2, fill=true, clip=ends,
  load_at=function(x, y) return clamp((math.abs(x - 545) - 150) / 120, 0.1, 0.9) end})

--@ chunk 164
-- point on arch i at height fraction u, side sd
local function AP(i, u, sd)
  local a = ARCHES2[i]
  local k = 175 * a.s
  local xm = sd * 9 * (1 - u^3)
  local ym = 14 * u
  local x, y = xm * k, (1.2 - ym) * k
  local c, s = math.cos(a.rot), math.sin(a.rot)
  return VX + a.dx + x*c - y*s, VY + a.dy + x*s + y*c, k
end
local V = VIEW - FIGM2
local niche = pile{{"burnt sienna",1},{"Mars brown",0.6},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.08}
local lamp = pile{{"lead white",3},{"cadmium yellow",0.4},{"yellow ochre",0.3}, medium=0.08}
local n, lit = 0, 0
for i = 1, NA - 1 do
  for _, u in ipairs{0.22, 0.34, 0.45} do
    for _, sd in ipairs{-1, 1} do
      local x1, y1, k1 = AP(i, u, sd)
      local x2, y2, k2 = AP(i + 1, u, sd)
      local x, y = lerp(x1, x2, 0.5), lerp(y1, y2, 0.5)
      local w = 0.5 * (k1 + k2) / 2 * 0.06   -- 0.6 m-ish
      if w > 0.8 and V:at(x, y) > 0.5 then
        local b = brush{kind="round", width=math.max(1, w * 1.3), stiffness=0.4}
        b:load(niche, 0.8)
        b:stroke({{x, y + w*0.6}, {x, y - w*0.6}}, {pressure={0.7, 0.6}, clip=V})
        n = n + 1
        local h = ((i * 7 + u * 13 + sd * 3) * 0.618034) % 1
        if h < 0.38 then
          local lb = brush{kind="round", width=math.max(0.8, w * 0.7)}
          lb:load(lamp, 0.8)
          lb:touch(x, y, {pressure=0.6, clip=V})
          lit = lit + 1
        end
      end
    end
  end
end
print(n, lit)

--@ chunk 165
-- point on arch i at height fraction u, side sd
local function AP(i, u, sd)
  local a = ARCHES2[i]
  local k = 175 * a.s
  local xm = sd * 9 * (1 - u^3)
  local ym = 14 * u
  local x, y = xm * k, (1.2 - ym) * k
  local c, s = math.cos(a.rot), math.sin(a.rot)
  return VX + a.dx + x*c - y*s, VY + a.dy + x*s + y*c, k
end
local V = VIEW - FIGM2
local niche = pile{{"burnt sienna",1},{"Mars brown",0.6},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.08}
local lamp = pile{{"lead white",3},{"cadmium yellow",0.4},{"yellow ochre",0.3}, medium=0.08}
local n, lit = 0, 0
for i = 1, NA - 1 do
  for _, u in ipairs{0.22, 0.34, 0.45} do
    for _, sd in ipairs{-1, 1} do
      local x1, y1, k1 = AP(i, u, sd)
      local x2, y2, k2 = AP(i + 1, u, sd)
      local x, y = lerp(x1, x2, 0.5), lerp(y1, y2, 0.5)
      local w = 0.32 * (k1 + k2) / 2
      if w > 0.8 and V:at(x, y) > 0.5 then
        local b = brush{kind="round", width=math.max(1, w * 1.3), stiffness=0.4}
        b:load(niche, 0.8)
        b:stroke({{x, y + w*0.6}, {x, y - w*0.6}}, {pressure={0.7, 0.6}, clip=V})
        n = n + 1
        local h = ((i * 7 + u * 13 + sd * 3) * 0.618034) % 1
        if h < 0.38 then
          local lb = brush{kind="round", width=math.max(0.8, w * 0.7)}
          lb:load(lamp, 0.8)
          lb:touch(x, y, {pressure=0.6, clip=V})
          lit = lit + 1
        end
      end
    end
  end
end
print(n, lit)

--@ chunk 166
print(wait(4*24*60)); print(drying(462,250), drying(620,250))

--@ chunk 167
-- point on arch i at height fraction u, side sd
local function AP(i, u, sd)
  local a = ARCHES2[i]
  local k = 175 * a.s
  local xm = sd * 9 * (1 - u^3)
  local ym = 14 * u
  local x, y = xm * k, (1.2 - ym) * k
  local c, s = math.cos(a.rot), math.sin(a.rot)
  return VX + a.dx + x*c - y*s, VY + a.dy + x*s + y*c, k
end
local V = VIEW - FIGM2
local niche = pile{{"burnt sienna",1},{"Mars brown",0.6},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.08}
local lamp = pile{{"lead white",3},{"lemon chrome",0.3},{"cadmium yellow",0.2}, medium=0.05}
local n, lit = 0, 0
for i = 1, NA - 1 do
  for _, u in ipairs{0.22, 0.34, 0.45} do
    for _, sd in ipairs{-1, 1} do
      local x1, y1, k1 = AP(i, u, sd)
      local x2, y2, k2 = AP(i + 1, u, sd)
      local x, y = lerp(x1, x2, 0.5), lerp(y1, y2, 0.5)
      local w = 0.32 * (k1 + k2) / 2
      if w > 0.8 and V:at(x, y) > 0.5 then
        local b = nil


        n = n + 1
        local h = ((i * 7 + u * 13 + sd * 3) * 0.618034) % 1
        if h < 0.38 then
          local lb = brush{kind="round", width=math.max(1.1, w * 0.75)}
          lb:load(lamp, 0.8)
          lb:stroke({{x, y + w*0.25}, {x, y - w*0.3}}, {pressure={0.75, 0.6}, clip=V})
          lit = lit + 1
        end
      end
    end
  end
end
print(n, lit)

--@ chunk 168
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local F = cq(1.3, 1.44, 0.05, 0.8) - cq(1.315, 1.425, 0.1, 0.75)
local fr = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.4},{"lead white",0.08}, medium=0.08}
work(F, {hand="detail", pile=fr, coverage=4, fill=true, clip=F})
local strip = rect(204, 188, 22, 130) * CORR
local sp = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine ash",0.6},{"lead white",0.08}, medium=0.08}
work(strip, {hand="detail", pile=sp, coverage=4, fill=true, clip=strip})

--@ chunk 169
-- pass 3, 1: the corridor repainted darker and leaner, bay by bay (no white near us)
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local CAB = ribbon({{372,528},{360,550},{352,580},{330,615},{300,645},{270,667}}, 10)
  + ribbon({{430,532},{420,560},{424,595},{410,630},{380,667}}, 10)
  + ribbon({{628,516},{640,540},{672,575},{700,615},{720,667}}, 10)
  + ribbon({{690,488},{676,500},{650,508},{628,516}}, 6)
local keep = PIPEM + PLQ:grow(1.5) + PATCHW:grow(1.5) + COLLAR + COLSOFF + ENDW + CAB
  + cq(1.05, 1.22, -0.45, 0.45) + cq(1.35, 1.59, -0.45, 0.45) + cq(1.31, 1.43, -1.03, -0.32) + cq(1.29, 1.45, 0.03, 0.82)
  + rect(355, 340, 85, 200) + BAND:grow(1)
KEEP3 = keep
local fan = poly({{417,519},{671,519},{760,600},{800,667},{290,667},{335,600}})
local bay = {
  pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.5},{"yellow ochre",0.3}, medium=0.08},
  pile{{"bone black",2},{"burnt sienna",0.7},{"ultramarine blue",0.3}, medium=0.08},
  pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.45}, medium=0.08},
  pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.35}, medium=0.08},
}
local edges = {1.0, 1.27, 1.66, 2.25, 4}
local surf = LWALL + RWALL + CEIL + FLOOR * -(fan)
for i = 1, 4 do
  local m = (RECTS(edges[i+1]) - RECTS(edges[i])) * surf - RIBALL - keep
  work(m, {hand="body", tool="filbert 7", pile=bay[i], angle=TOVP, coverage=4, fill=true, clip=m, load=1})
end
-- rib fronts: backlit, the darkest things in the corridor
local ribK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}, medium=0.08}
local RF = (RIBFRONT(1.27) + RIBFRONT(1.66) + RIBFRONT(2.25)) - keep
work(RF, {hand="body", tool="filbert 6", pile=ribK, angle=TOVP, coverage=4, fill=true, clip=RF, load=1})
-- rib inner faces (toward the cut) stay a little warmer
local ribS = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"yellow ochre",0.2}, medium=0.08}
local RS = (RIBSOFF(1.27) + RIBSOFF(1.66) + RIBSOFF(2.25)) - keep
work(RS, {hand="body", tool="filbert 5", pile=ribS, angle=TOVP, coverage=4, fill=true, clip=RS, load=1})
-- the collar's return face: a dim warm dark instead of cool gray
local csD = pile{{"bone black",2},{"burnt sienna",0.8},{"yellow ochre",0.3},{"lead white",0.12}, medium=0.08}

work(COLSOFF - (PIPEM + PLQ + PATCHW + rect(355, 340, 85, 200)), {hand="body", tool="filbert 3", pile=csD, angle=TOVP, coverage=4, fill=true, clip=COLSOFF, load=1})

--@ chunk 170
-- pass 3, 4: the scale-plate wall made richer: about half the plates repainted in varied bronzes
local rods = ribbon({{398,352},{372,512}}, 6) + ribbon({{402,354},{430,524}}, 6) + ribbon({{400,354},{404,505}}, 5)
  + ribbon({{386,428},{418,436}}, 4) + ribbon({{677,316},{664,322},{655,331},{650,341}}, 6)
  + ribbon({{376,166},{372,240},{366,320},{360,330}}, 4) + ribbon({{721,190},{724,300},{716,420},{714,436}}, 4)
  + ribbon({{690,488},{676,500},{650,508},{628,516}}, 9)
local pods = rect(363,148,26,20) + rect(710,174,22,18) + rect(703,434,24,20) + rect(358,468,22,18)
INSTR = TRI:grow(2) + PLAC:grow(4) + SIGN:grow(2) + RAIL2:grow(2) + CAR2:grow(2) + PODS:grow(2) + pods + rods + COLLAR:grow(1.5) + CUT:grow(2.5)
local W = BRONZE - INSTR
local P = {
  hot  = pile{{"Mars orange",1},{"chrome yellow",0.8},{"burnt sienna",0.6},{"lead white",0.4}, medium=0.08},
  mid  = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.5},{"yellow ochre",0.5}, medium=0.08},
  cop  = pile{{"red earth",1},{"burnt sienna",1},{"yellow ochre",0.4},{"bone black",0.3}, medium=0.08},
  verd = pile{{"viridian",0.5},{"raw sienna",1.2},{"bone black",0.7},{"lead white",0.45}, medium=0.08},
  dark = pile{{"Mars brown",1},{"bone black",1},{"burnt sienna",0.6}, medium=0.08},
  gold = pile{{"yellow ochre",2},{"raw sienna",0.6},{"lead white",0.5},{"burnt sienna",0.3}, medium=0.08},
}
PL3 = {}
local cnt = {}
for i, p in ipairs(PLATES) do
  local h = (p.n * 0.381966 + 0.13) % 1
  if h < 0.55 and W:at(p.x, p.y) > 0.5 then
    local near = clamp(1 - CUTDIST(p.x, p.y) / 90, 0, 1)
    local r = (p.n * 0.7548777) % 1
    local k
    if r < 0.08 + 0.3 * near then k = "hot"
    elseif r < 0.22 + 0.2 * near then k = "gold"
    elseif r < 0.45 then k = "mid"
    elseif r < 0.58 then k = "cop"
    elseif r < 0.68 then k = "verd"
    else k = "dark" end
    local sz = 17 + 7 * ((p.n * 0.5698403) % 1)
    PLATE_BODY(p.x, p.y, p.a, sz, P[k], W)
    PL3[#PL3+1] = {x=p.x, y=p.y, a=p.a, n=p.n, sz=sz, k=k, near=near}
    cnt[k] = (cnt[k] or 0) + 1
  end
end
for k, v in pairs(cnt) do print(k, v) end
print(#PL3)

--@ chunk 171
-- pass 3, 2: the thin narrow passes went ochre; let them set, then repaint without yellow earths.
-- plates far from the cut knocked down from gold/hot to darker bronzes
print(wait(3*24*60))
local keep = KEEP3
local dk = pile{{"bone black",2},{"Mars brown",0.8},{"ultramarine blue",0.3}, medium=0.08}
local wm = pile{{"bone black",2},{"Mars brown",1},{"burnt sienna",0.6}, medium=0.08}
local R2 = (RIBSOFF(1.66) + RIBSOFF(2.25)) - keep
work(R2, {hand="body", tool="filbert 7", pile=dk, angle=TOVP, coverage=5, fill=true, clip=R2, load=1})
local R1 = RIBSOFF(1.27) - keep
work(R1, {hand="body", tool="filbert 7", pile=wm, angle=TOVP, coverage=5, fill=true, clip=R1, load=1})
local PIPEM = PIPES[1].m + PIPES[2].m + PIPES[3].m + PIPES[4].m
local C = COLSOFF - (PIPEM + PLQ + PATCHW + rect(355, 340, 85, 200))
work(C, {hand="body", tool="filbert 7", pile=wm, angle=TOVP, coverage=5, fill=true, clip=C, load=1})
local W = BRONZE - INSTR
local P = {
  mid  = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.9},{"yellow ochre",0.3}, medium=0.08},
  dark = pile{{"Mars brown",1},{"bone black",1},{"burnt sienna",0.6}, medium=0.08},
  cop  = pile{{"red earth",1},{"burnt sienna",1},{"bone black",0.7}, medium=0.08},
}
local n = 0
for _, p in ipairs(PL3) do
  local h = (p.n * 0.2763932) % 1
  local k = nil
  if p.near < 0.45 and (p.k == "hot" or p.k == "gold") then k = (h < 0.5) and "mid" or "cop"
  elseif p.k == "verd" and p.near < 0.3 then k = "dark"
  elseif p.k == "mid" and h < 0.4 then k = "dark" end
  if k then PLATE_BODY(p.x, p.y, p.a, p.sz * 0.85, P[k], W); p.k = (k == "dark") and "dark" or "mid"; n = n + 1 end
end
print("knocked", n)

--@ chunk 172
print(drying(285,300), drying(110,300), drying(120,300), RIBFRONT(1.27):at(285,300), RIBALL:at(285,300), KEEP3:at(285,300), LWALL:at(285,300))

--@ chunk 173
-- pass 3, 2b: bay nearest the wall read as an olive frame; repaint it a warm near-black (no yellow earths)
print(wait(2*24*60))
local fan = poly({{417,519},{671,519},{760,600},{800,667},{290,667},{335,600}})
local surf = LWALL + RWALL + CEIL + FLOOR * -(fan)
local m = (RECTS(1.27) - RECTS(1.0)) * surf - RIBALL - KEEP3
local p = pile{{"bone black",2},{"burnt sienna",0.9},{"Mars brown",0.4}, medium=0.08}
work(m, {hand="body", tool="filbert 7", pile=p, angle=TOVP, coverage=5, fill=true, clip=m, load=1})

--@ chunk 174
print(wait(4*24*60))
-- pass 3, 5: shadows under the repainted plates' lips, then glints: hot near the cut, a few cool far ones
local W = BRONZE - INSTR
pshad = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",1}, medium=0.12}
for _, p in ipairs(PL3) do PLATE_SHADOW(p.x, p.y, p.a, p.sz, W, 4.5) end
local gH = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.25}, medium=0.08}
local gM = pile{{"yellow ochre",2},{"Mars orange",0.4},{"lead white",0.7}, medium=0.08}
local gC = pile{{"lead white",1},{"viridian",0.3},{"yellow ochre",0.4},{"bone black",0.2}, medium=0.08}
local n = 0
for _, p in ipairs(PL3) do
  local h = (p.n * 0.618034 + 0.3) % 1
  local pl, amt = nil, 0
  if p.near > 0.15 and (p.k == "hot" or p.k == "gold" or h < 0.6) then pl, amt = (p.near > 0.55) and gH or gM, p.near
  elseif p.k == "verd" and h < 0.5 then pl, amt = gC, 0.35
  elseif (p.k == "gold" or p.k == "hot") then pl, amt = gM, 0.35 end
  if pl then PLATE_GLINT(p.x, p.y, p.a, p.sz, 543, 330, pl, amt, W); n = n + 1 end
end
print("glints", n)

--@ chunk 175
-- pass 3, 3: warm spill from the cut on the dry dark corridor: rib inner edges, collar bounce, instruments
local rimA = pile{{"Mars orange",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}, medium=0.08}
local rimB = pile{{"burnt sienna",1.5},{"Mars orange",0.6},{"bone black",0.8},{"yellow ochre",0.3}, medium=0.08}
local rimH = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.2}, medium=0.08}
local function line(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr or {0.5, 0.6}, shake=0.3, clip=clipm})
end
-- rib inner edges, each a little dimmer toward us
for i, s in ipairs{1.27, 1.66, 2.25} do
  local a = SP(EX0 + RIBP, EY0 + RIBP, s); local b = SP(EX1 - RIBP, EY1 + 40, s)
  local yf = VY + (EY1 - VY) * s
  local pl = (i == 1) and rimA or rimB
  local w = 1.1 * s
  local d = 0.8 * s
  local clipm = RIBFRONT(s):grow(0.6) - KEEP3
  line({{a[1] - d, yf - 2}, {a[1] - d, lerp(yf, a[2], 0.5)}, {a[1] - d, a[2] + 4}}, pl, w, {0.75, 0.25}, clipm)
  line({{b[1] + d, yf - 2}, {b[1] + d, lerp(yf, a[2], 0.5)}, {b[1] + d, a[2] + 4}}, pl, w, {0.75, 0.25}, clipm)
  line({{a[1] + 4, a[2] - d}, {VX, a[2] - d}, {b[1] - 4, a[2] - d}}, pl, w * 0.8, {0.25, 0.3}, clipm)
end
-- the collar's lower posts catch the bounce off the lit floor: amber restated brighter
local amL1 = pile{{"chrome yellow",1},{"Mars orange",1},{"lead white",0.25},{"burnt sienna",0.2}, medium=0.08}
local amL2 = pile{{"chrome yellow",1},{"Mars orange",1},{"lead white",0.5}, medium=0.08}
local bf = brush{kind="flat", width=5.5, stiffness=0.6}
for _, z in ipairs{{380, 455, amL1}, {455, 560, amL2}} do
  local cm = COLLAR * rect(250, z[1], 600, z[2] - z[1])
  for y = 50, 560, 20 do
    bf:load(z[3], 0.85); bf:stroke({{312, y + 10}, {354, y + 52}}, {pressure={0.7, 0.65}, orient="across", clip=cm, shake=0.6})
    bf:load(z[3], 0.85); bf:stroke({{778, y + 10}, {736, y + 52}}, {pressure={0.7, 0.65}, orient="across", clip=cm, shake=0.6})
  end
end
-- the collar's inner lip, against the bronze, lit lowest
line({{345.6, 330}, {345.6, 420}, {345.6, 515}}, rimA, 1.4, {0.2, 0.7})
line({{744.4, 330}, {744.4, 420}, {744.4, 515}}, rimA, 1.4, {0.2, 0.7})
-- instruments: the faces toward the opening
line({{399.5, 356}, {405.5, 505}}, rimA, 1.0, {0.35, 0.7})
line({{404, 356}, {432, 524}}, rimH, 1.1, {0.3, 0.8})
line({{399, 354}, {373.5, 512}}, rimB, 0.9, {0.25, 0.5})
line({{414.5, 328}, {418.5, 357}}, rimH, 1.3, {0.6, 0.6})
line({{379, 329}, {414, 326.5}}, rimA, 0.9, {0.5, 0.3})
line({{684.2, 152}, {685, 300}, {686.2, 488}}, rimH, 1.1, {0.7, 0.5})
line({{676.5, 300.5}, {677.3, 332}}, rimH, 1.2, {0.7, 0.7})
line({{676, 316}, {664, 322}, {655, 331}}, rimA, 0.9, {0.5, 0.5})
line({{705.3, 437}, {705.6, 451}}, rimA, 1.0, {0.6, 0.6})
line({{712.3, 177}, {712.5, 189}}, rimA, 1.0, {0.6, 0.6})
line({{386.8, 151}, {387.2, 165}}, rimA, 1.0, {0.6, 0.6})
line({{377.7, 471}, {378, 483}}, rimA, 1.0, {0.6, 0.6})
line({{685, 207}, {685.5, 252}}, rimA, 1.0, {0.5, 0.5})
line({{411.5, 233}, {413, 299}}, rimB, 1.0, {0.4, 0.5})

--@ chunk 176
-- pass 3, 6: the nave deeper and more luminous: near ribs against the light, far bands paler, a white core
local V = (VIEW - FIGM2:grow(1.5)) * above(function(x) return 297 end)
-- near ribs as warm darks seen against the glow, lightening with distance
local function NRPILE(t)
  return pile{{"burnt sienna", lerp(1.0, 0.6, t)}, {"raw sienna", 0.8}, {"yellow ochre", lerp(0.5, 1.4, t)},
              {"bone black", lerp(0.35, 0.02, t)}, {"lead white", lerp(0.1, 1.0, t)}, medium=0.08}
end
for i = 1, 8 do
  local a = ARCHES2[i]
  local t = (i - 1) / 7
  local pts = ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy)
  local w = math.max(0.9, 105 * a.s)
  local b = brush{kind="round", width=w, stiffness=0.5}
  local L, R = {}, {}
  for j = 1, 19 do L[#L+1] = pts[j] end
  for j = 19, #pts do R[#R+1] = pts[j] end
  local rp = NRPILE(t)
  b:load(rp, 0.95); b:stroke(L, {pressure={0.85, 0.8}, clip=V, shake=0.3})
  b:load(rp, 0.95); b:stroke(R, {pressure={0.8, 0.85}, clip=V, shake=0.3})
end
-- far bands repainted paler, toward a cool white
local function FARPILE(t)
  return pile{{"lead white", lerp(3, 1.5, t)}, {"zinc white", lerp(0.6, 2.5, t)}, {"yellow ochre", lerp(0.5, 0.05, t)},
              {"cadmium yellow", lerp(0.15, 0.05, t)}, {"lemon chrome", 0.1}, medium=0.08}
end
local V2 = VIEW - FIGM2:grow(1.5)
for i = 12, NA do
  local inner = (i < NA) and ARCHIN(i + 1) or nil
  local band = inner and (ARCHIN(i) - inner) or ARCHIN(i)
  band = band * V2 * above(function(x) return 297 end)
  local t = (i - 12) / (NA - 12)
  local w = math.max(1.2, math.min(4, 120 * ARCHES2[i].s))
  work(band, {hand="body", tool={kind="filbert", width=w}, pile=FARPILE(t), angle=TOVP, coverage=3.5, fill=true, clip=band})
end
local cx, cy = 0, 0
local pts = ARCHPTS(ARCHES2[NA].s, 9, 14, ARCHES2[NA].rot, ARCHES2[NA].dx, ARCHES2[NA].dy)
for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end
cx, cy = cx / #pts, cy / #pts
GLOWC = {cx, cy}
print("far centre", cx, cy, ARCHES2[12].s, ARCHES2[NA].s)
local core = ellipse(cx, cy, 6, 7.5) * V2
work(core, {hand="detail", pile=pile{{"zinc white",3},{"lemon chrome",0.12}, medium=0.05}, coverage=4, fill=true, clip=core})

--@ chunk 177
-- pass 3, 6b: the far glow as rings of light round the white core, strokes running round it
local cx, cy = GLOWC[1], GLOWC[2]
local V = (VIEW - FIGM2:grow(1.5)) * above(function(x) return 299 end)
local tang = function(x, y) return math.atan(y - cy, x - cx) + math.pi/2 end
local function ring(r0, r1) return (ellipse(cx, cy, r1, r1 * 1.1) - ellipse(cx, cy, r0, r0 * 1.1)) * V end
local rings = {
  {6, 13, pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.12}, medium=0.05}},
  {13, 22, pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.2}, medium=0.05}},
  {22, 34, pile{{"lead white",3},{"yellow ochre",0.35},{"cadmium yellow",0.15}, medium=0.06}},
  {34, 50, pile{{"lead white",3},{"yellow ochre",0.7},{"raw sienna",0.08}, medium=0.06}},
}
for _, r in ipairs(rings) do
  local m = ring(r[1], r[2])
  work(m, {hand="body", tool="filbert 3", pile=r[3], angle=tang, coverage=3, fill=true, clip=m, load=0.9})
end
for _, r in ipairs{13, 22, 34} do
  blend(ring(r - 3, r + 3), {angle=tang})
end

--@ chunk 178
-- pass 3, 6c: lose the glow's outer edge, and carry the twisting ribs on into the light, faint
local cx, cy = GLOWC[1], GLOWC[2]
local V = (VIEW - FIGM2:grow(1.5)) * above(function(x) return 299 end)
local tang = function(x, y) return math.atan(y - cy, x - cx) + math.pi/2 end
local function ring(r0, r1) return (ellipse(cx, cy, r1, r1 * 1.1) - ellipse(cx, cy, r0, r0 * 1.1)) * V end
blend(ring(43, 58), {angle=tang})
blend(ring(43, 58), {angle=function(x, y) return math.atan(y - cy, x - cx) end})
for i = 8, 18 do
  local a = ARCHES2[i]
  local t = (i - 8) / 10
  local pts = ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy)
  local w = math.max(0.7, 70 * a.s)
  local pl = pile{{"lead white", 3}, {"yellow ochre", lerp(1.1, 0.3, t)}, {"raw sienna", lerp(0.35, 0.05, t)}, medium=0.08}
  local b = brush{kind="round", width=w, stiffness=0.5}
  local L, R = {}, {}
  for j = 1, 19 do L[#L+1] = pts[j] end
  for j = 19, #pts do R[#R+1] = pts[j] end
  b:load(pl, 0.6); b:stroke(L, {pressure={0.5, 0.45}, clip=V, shake=0.2})
  b:load(pl, 0.6); b:stroke(R, {pressure={0.45, 0.5}, clip=V, shake=0.2})
end

--@ chunk 179
-- pass 3, 7: the figure modelled by the nave's light: hot rim on the glow side, thinner on the other, a few reflected planes
local fx, fy, k = FIGFX, FIGFY, FIGK
local function P(x, y) return {fx + x*k, fy - y*k} end
local hot  = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.2}, medium=0.05}
local warm = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.08}
local dim  = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5},{"bone black",0.3}, medium=0.08}
local refl = pile{{"bone black",1},{"burnt sienna",0.8},{"yellow ochre",0.5},{"lead white",0.25}, medium=0.08}
local function line(pts, pl, w, pr, sw)
  local b = brush{kind="round", width=w, point=0.7}
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr, swell=sw or {0.7, 1, 0.8}, shake=0.15})
end
-- glow side (right): helmet, pauldron, arm, flank, leg, rifle
line({P(0.0,1.905), P(0.07,1.86), P(0.105,1.77), P(0.095,1.68)}, hot, 1.5, {0.8, 0.5})
line({P(0.2,1.615), P(0.3,1.625), P(0.385,1.585), P(0.405,1.53)}, hot, 1.6, {0.85, 0.6})
line({P(0.355,1.48), P(0.398,1.3), P(0.39,1.18), P(0.34,1.02)}, warm, 1.3, {0.8, 0.3})
line({P(0.205,0.95), P(0.19,0.7), P(0.185,0.45), P(0.185,0.16)}, warm, 1.1, {0.7, 0.2})
line({P(0.36,0.9), P(0.42,0.75), P(0.48,0.57)}, warm, 0.9, {0.6, 0.3})
line({P(0.22,0.13), P(0.225,0.02)}, dim, 0.9, {0.5, 0.5})
-- far side (left): thinner, dimmer
line({P(-0.02,1.905), P(-0.075,1.86), P(-0.1,1.78)}, warm, 1.1, {0.7, 0.3})
line({P(-0.2,1.615), P(-0.3,1.625), P(-0.385,1.585)}, warm, 1.2, {0.75, 0.4})
line({P(-0.36,1.48), P(-0.4,1.25), P(-0.37,1.0)}, dim, 0.9, {0.6, 0.15})
line({P(-0.195,0.93), P(-0.215,0.6), P(-0.225,0.2)}, dim, 0.8, {0.5, 0.1})
-- reflected warmth on the back planes: pack edge and top, belt, the backs of the knees
line({P(0.17,1.14), P(0.18,1.5)}, refl, 1.0, {0.5, 0.5})
line({P(-0.16,1.53), P(0.16,1.525)}, refl, 0.9, {0.45, 0.45})
line({P(-0.19,1.035), P(0.19,1.035)}, refl, 0.9, {0.4, 0.4})
line({P(0.06,0.56), P(0.17,0.56)}, refl, 0.8, {0.35, 0.35})
line({P(-0.21,0.56), P(-0.1,0.56)}, refl, 0.8, {0.3, 0.3})
line({P(0.0,1.74), P(0.0,1.6)}, refl, 0.8, {0.3, 0.3})

--@ chunk 180
-- pass 3, 7b: rims laid just inside the silhouette, wider, so they read against the bright nave
local fx, fy, k = FIGFX, FIGFY, FIGK
local function P(x, y) return {fx + x*k, fy - y*k} end
local hot  = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.25}, medium=0.05}
local warm = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.25}, medium=0.06}
local dim  = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.7},{"bone black",0.15}, medium=0.08}
local FM = FIGM2
local function line(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr, swell={0.7, 1, 0.8}, shake=0.1, clip=FM})
end
line({P(-0.01,1.885), P(0.055,1.85), P(0.085,1.77), P(0.08,1.69)}, hot, 2.0, {0.85, 0.5})
line({P(0.2,1.6), P(0.3,1.605), P(0.375,1.57), P(0.39,1.52)}, hot, 2.2, {0.9, 0.6})
line({P(0.34,1.47), P(0.38,1.3), P(0.375,1.18), P(0.33,1.02)}, warm, 1.8, {0.85, 0.35})
line({P(0.185,0.93), P(0.17,0.7), P(0.165,0.45), P(0.165,0.16)}, warm, 1.5, {0.75, 0.25})
line({P(0.355,0.9), P(0.405,0.76), P(0.46,0.58)}, warm, 1.2, {0.7, 0.35})
line({P(-0.015,1.885), P(-0.06,1.85), P(-0.085,1.77)}, warm, 1.5, {0.7, 0.3})
line({P(-0.2,1.6), P(-0.3,1.605), P(-0.37,1.57)}, warm, 1.6, {0.75, 0.4})
line({P(-0.345,1.47), P(-0.38,1.25), P(-0.355,1.0)}, dim, 1.3, {0.65, 0.15})
line({P(-0.175,0.93), P(-0.195,0.6), P(-0.205,0.2)}, dim, 1.2, {0.55, 0.12})

--@ chunk 181
-- pass 3, 8: the plaque, the wall patch and the dead ceiling panels brought down into the dark corridor
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local g1 = pile{{"bone black",2},{"ultramarine ash",0.5},{"burnt sienna",0.35},{"lead white",0.18}, medium=0.08}
local g2 = pile{{"bone black",2},{"ultramarine ash",0.4},{"burnt sienna",0.4},{"lead white",0.08}, medium=0.08}
local am = pile{{"Mars orange",0.6},{"burnt sienna",1},{"bone black",0.9},{"chrome yellow",0.3}, medium=0.08}
local A = PLQ - PLQA
work(A, {hand="detail", pile=g1, coverage=4, fill=true, clip=A, load=1})
work(PLQA, {hand="detail", pile=am, coverage=4, fill=true, clip=PLQA, load=1})
work(PATCHW, {hand="detail", pile=g1, coverage=4, fill=true, clip=PATCHW, load=1})
for _, pz in ipairs{{1.06, 1.21}, {1.36, 1.58}} do
  local a, b = pz[1], pz[2]
  local fr = (poly({CLP(a, -0.42), CLP(a, 0.42), CLP(b, 0.42), CLP(b, -0.42)}) * CEIL) - RIBALL
  work(fr, {hand="detail", pile=g2, coverage=4, fill=true, clip=fr, load=1})
end
local P1 = cq(1.32, 1.42, -1.0, -0.35) + cq(1.3, 1.44, 0.05, 0.8)
work(P1 * CEIL, {hand="detail", pile=g2, coverage=4, fill=true, clip=P1 * CEIL, load=1})

--@ chunk 182
-- pass 3, 9: accents on dry paint: panel glass catching the cut, plaque edges, bounce glints on the low plates,
-- stronger rib edges near the floor, counter-lit ribs inside the glow
print(wait(4*24*60))
local refl = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.9},{"lead white",0.25}, medium=0.08}
local edge = pile{{"bone black",1},{"burnt sienna",0.5},{"yellow ochre",0.4},{"lead white",0.35}, medium=0.08}
local function ln(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=w, point=0.5}
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr, shake=0.2, clip=clipm})
end
for _, pz in ipairs{{1.06, 1.21}, {1.36, 1.58}} do
  local a, b = pz[1], pz[2]
  ln({CLP(a + 0.015, -0.33), CLP(a + 0.015, 0.33)}, refl, 1.6 * a, {0.5, 0.5})
  ln({CLP(a + 0.035, -0.25), CLP(a + 0.035, 0.2)}, refl, 1.0 * a, {0.3, 0.2})
end
-- plaque and patch: the edge nearest the cut
local function wp(side, s, h) if side < 0 then return LWP(s, h) else return RWP(s, h) end end
ln({wp(-1, 1.33, 1.2), wp(-1, 1.33, 1.62)}, edge, 1.3, {0.5, 0.5})
ln({wp(1, 1.05, 0.47), wp(1, 1.05, 1.02)}, edge, 1.2, {0.5, 0.5})
-- low plates catch the bounce from the lit sill: glints on their lower rims
local W = BRONZE - INSTR
local gB = pile{{"yellow ochre",2},{"Mars orange",0.5},{"lead white",0.8}, medium=0.08}
local n = 0
for _, p in ipairs(PLATES) do
  if p.y > 400 and W:at(p.x, p.y) > 0.5 then
    local amt = clamp((p.y - 400) / 110, 0, 1) * 0.8
    if ((p.n * 0.618034) % 1) < 0.7 then
      PLATE_GLINT(p.x, p.y, p.a, 20, 545, 600, gB, amt, W); n = n + 1
    end
  end
end
print("bounce", n)
-- counter-lit ribs inside the glow, thin and warm-mid
local cx, cy = GLOWC[1], GLOWC[2]
local V = (VIEW - FIGM2:grow(1.5)) * above(function(x) return 299 end)
for i = 9, 15 do
  local a = ARCHES2[i]
  local t = (i - 9) / 6
  local pts = ARCHPTS(a.s, 9, 14, a.rot, a.dx, a.dy)
  local w = math.max(0.6, 45 * a.s)
  local pl = pile{{"lead white", lerp(1.6, 2.6, t)}, {"yellow ochre", 1}, {"raw sienna", lerp(0.5, 0.2, t)}, {"burnt sienna", lerp(0.2, 0.05, t)}, medium=0.08}
  local b = brush{kind="round", width=w, stiffness=0.5}
  local L, R = {}, {}
  for j = 1, 19 do L[#L+1] = pts[j] end
  for j = 19, #pts do R[#R+1] = pts[j] end
  b:load(pl, 0.7); b:stroke(L, {pressure={0.5, 0.4}, clip=V, shake=0.2})
  b:load(pl, 0.7); b:stroke(R, {pressure={0.4, 0.5}, clip=V, shake=0.2})
end

--@ chunk 183
-- pass 3, 10: plaque and patch still read too pale: a second opaque coat, leaner
print(wait(2*24*60))
local g = pile{{"bone black",2},{"ultramarine ash",0.3},{"burnt sienna",0.5},{"Mars brown",0.3}, medium=0.08}
local am = pile{{"burnt sienna",1},{"bone black",1.2},{"Mars orange",0.4}, medium=0.08}
local A = PLQ - PLQA
work(A, {hand="body", tool="filbert 4", pile=g, coverage=5, fill=true, clip=A, load=1})
work(PLQA, {hand="body", tool="filbert 3", pile=am, coverage=5, fill=true, clip=PLQA, load=1})
work(PATCHW, {hand="body", tool="filbert 4", pile=g, coverage=5, fill=true, clip=PATCHW, load=1})

--@ chunk 184
-- pass 3, 11: wall panel seams restated, their lips catching a little warmth only near the cut
local WV = WALLV - KEEP3
local sk = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}, medium=0.08}
local lip = pile{{"burnt sienna",1},{"bone black",0.8},{"yellow ochre",0.5},{"lead white",0.2}, medium=0.08}
local function WP2(side, s, h) if side < 0 then return LWP(s, h) else return RWP(s, h) end end
local function wline(side, s1, s2, h, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.2}
  local pts = {}
  for i = 0, 8 do pts[#pts+1] = WP2(side, lerp(s1, s2, i/8), h) end
  b:load(pl, 0.8)
  b:stroke(pts, {pressure=pr, clip=WV, shake=0.3})
end
for _, side in ipairs{-1, 1} do
  for _, h in ipairs{0.36, 1.08, 1.8} do
    wline(side, 1.0, 2.7, h, sk, 2.2, {0.6, 0.7})
    wline(side, 1.0, 1.9, h - 0.025, lip, 1.0, {0.45, 0.0})
  end
  for _, s in ipairs{1.14, 1.47, 1.95} do
    local b = brush{kind="round", width=2.0, point=0.2}
    b:load(sk, 0.8); b:stroke({WP2(side, s, 0.0), WP2(side, s, 2.4)}, {pressure={0.6, 0.6}, clip=WV, shake=0.3})
  end
end

--@ chunk 185
-- pass 3, 12: the strip of rib return face the panel exclusion left pale
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local m = (RIBSOFF(1.27) + RIBFRONT(1.27)) * cq(1.0, 1.3, -0.5, 0.5)
local wm = pile{{"bone black",2},{"Mars brown",1},{"burnt sienna",0.6}, medium=0.08}
work(m, {hand="body", tool="filbert 4", pile=wm, angle=0, coverage=5, fill=true, clip=m, load=1})

--@ chunk 186
-- pass 3, 13: the rib front over the panel back to the rib's own near-black
print(wait(2*24*60))
local function cq(s1, s2, x1, x2) return poly({CLP(s1, x1), CLP(s1, x2), CLP(s2, x2), CLP(s2, x1)}) end
local m = RIBFRONT(1.27) * cq(1.0, 1.3, -0.52, 0.52)
local ribK = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}, medium=0.08}
work(m, {hand="body", tool="filbert 4", pile=ribK, angle=0, coverage=5, fill=true, clip=m, load=1})
local a = SP(EX0 + RIBP, EY0 + RIBP, 1.27); local b = SP(EX1 - RIBP, EY1 + 40, 1.27)
local rimB = pile{{"burnt sienna",1.5},{"Mars orange",0.6},{"bone black",0.8},{"yellow ochre",0.3}, medium=0.08}
local br = brush{kind="round", width=1.1, point=0.5}
br:load(rimB, 0.8)
br:stroke({{a[1] + 4, a[2] - 1}, {VX, a[2] - 1}, {b[1] - 4, a[2] - 1}}, {pressure={0.4, 0.4}, shake=0.3, clip=RIBFRONT(1.27):grow(0.6)})

--@ chunk 187
-- pass 3, 14: rib inner edges lit more strongly low down, where the floor pool throws its light up
local rimA = pile{{"Mars orange",1},{"yellow ochre",1},{"lead white",0.7},{"burnt sienna",0.2}, medium=0.08}
local rimB = pile{{"burnt sienna",1.2},{"Mars orange",0.8},{"yellow ochre",0.4},{"bone black",0.4}, medium=0.08}
for i, s in ipairs{1.27, 1.66, 2.25} do
  local a = SP(EX0 + RIBP, EY0 + RIBP, s); local b = SP(EX1 - RIBP, EY1 + 40, s)
  local yf = VY + (EY1 - VY) * s
  local d = 0.9 * s
  local clipm = RIBFRONT(s):grow(0.8) - KEEP3
  local pl = (i == 1) and rimA or rimB
  for _, x in ipairs{a[1] - d, b[1] + d} do
    local br = brush{kind="round", width=1.5 * s, point=0.5}
    br:load(pl, 0.85)
    br:stroke({{x, yf - 1}, {x, lerp(yf, a[2], 0.2)}, {x, lerp(yf, a[2], 0.45)}}, {pressure={0.85, 0.05}, shake=0.3, clip=clipm})
  end
end
