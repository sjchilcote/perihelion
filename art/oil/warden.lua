-- easel session "warden": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=0.72, linen={22,20}, seed=7,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=120, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"raw sienna",1},{"lead white",1},{"ultramarine blue",0.5}}, um=40, apply="brush"}}}
print(W,H)

--@ chunk 2
R1 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.6},{"viridian",0.3}}
R2 = pile{{"bone brown",2},{"raw sienna",1},{"bone black",0.5},{"viridian",0.3}}
R3 = pile{{"raw sienna",2},{"bone brown",1},{"bone black",0.4},{"viridian",0.3}}
R4 = pile{{"raw sienna",2},{"yellow ochre",1},{"bone brown",0.5},{"bone black",0.2}}
R5 = pile{{"yellow ochre",2},{"raw sienna",1},{"lead white",0.4},{"bone brown",0.2}}
R6 = pile{{"yellow ochre",2},{"lead white",1},{"Mars yellow",0.5},{"raw sienna",0.5}}
R7 = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
VG = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.5},{"yellow ochre",0.8},{"raw sienna",0.3}}
VD = pile{{"viridian",1},{"cerulean blue",0.5},{"bone brown",1},{"lead white",0.5}}
BN = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
BS = pile{{"lead white",2},{"raw sienna",1},{"bone brown",0.4},{"ultramarine ash",0.4}}
CC = pile{{"cerulean blue",1},{"cobalt violet",1},{"ultramarine ash",1},{"zinc white",1}}
CV = pile{{"ultramarine blue",2},{"magenta",0.5},{"viridian",1},{"bone black",0.5}}
WD = pile{{"bone brown",2},{"burnt sienna",0.5},{"ultramarine blue",1},{"bone black",0.5}}
ND = pile{{"bone black",1},{"ultramarine blue",1},{"bone brown",1}}
RAMP = {R1,R2,R3,R4,R5,R6,R7}

-- paint a part in value bands from a form; cuts = thresholds between ramp steps
function shade(m, f, steps, opts)
  opts = opts or {}
  for i, st in ipairs(steps) do
    local lo, hi, p = st[1], st[2], st[3]
    local bm = m * mask(function(x, y) local v = f:value(x, y); return (v >= lo and v < hi) and 1 or 0 end)
    if bm:area() > 0 then
      work(bm, {hand=opts.hand or "body", pile=p, coverage=opts.coverage or 3, fill=true,
        angle=opts.angle, clip=m, tool=opts.tool, length=opts.length, pressure=opts.pressure})
    end
  end
end

--@ chunk 3
-- geometry (globals reused by later chunks)
NICHE_CX, NICHE_SPRING, NICHE_R = 500, 440, 320
SILL = 1240
function arc_pts(cx, cy, r, a0, a1, n)
  local t = {}
  for i = 0, n do local a = a0 + (a1 - a0) * i / n; t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
  return t
end
function niche_poly(r, xl, xr, ybot)
  local t = {{xl, ybot}}
  for _, p in ipairs(arc_pts(NICHE_CX, NICHE_SPRING, r, math.pi, 2 * math.pi, 40)) do t[#t+1] = p end
  t[#t+1] = {xr, ybot}
  return t
end
NICHE = niche_poly(320, 180, 820, SILL)
ARCH_OUT = niche_poly(368, 132, 868, SILL)

FIG = {
 halo = {505, 285, 150, 118},
 head = {{470,240},{492,232},{520,236},{542,262},{548,300},{540,340},{522,366},{500,372},{478,362},{462,330},{456,290},{460,258}},
 neck = {{486,365},{518,365},{522,410},{482,410}},
 torso = {{415,430},{595,430},{582,520},{560,640},{548,700},{462,700},{448,640},{428,520}},
 waist = {{462,698},{548,698},{552,752},{458,752}},
 skirt = {{456,748},{554,748},{600,860},{648,990},{690,1150},{600,1166},{505,1172},{410,1166},{326,1150},{360,990},{405,860}},
 lpaul = {395, 462, 58, 46}, rpaul = {618, 462, 56, 44},
 rarm_up = {{392,480},{350,612}}, rarm_fore = {{350,612},{334,700}},
 shaft = {{322,40},{322,1238}},
 blade = {{322,10},{344,60},{350,120},{340,175},{322,205},{304,175},{296,120},{302,60}},
 larm_up = {{622,480},{694,604}}, larm_fore = {{694,604},{722,470}},
 hand = {{708,476},{740,476},{752,440},{760,392},{752,388},{744,420},{742,380},{733,378},{730,418},{726,372},{716,372},{716,420},{708,392},{699,396},{704,440}},
}
local c = chalk()
c:sketch(NICHE, {pressure=0.35, passes=2})
c:sketch(ARCH_OUT, {pressure=0.3, passes=2})
c:rule({100, SILL}, {900, SILL}, {pressure=0.3})
local h = FIG
local hb = {} ; for _, p in ipairs(arc_pts(h.halo[1], h.halo[2], h.halo[3], 0, 2*math.pi, 48)) do hb[#hb+1] = p end
c:sketch(hb, {pressure=0.3})
hb = {} ; for _, p in ipairs(arc_pts(h.halo[1], h.halo[2], h.halo[4], 0, 2*math.pi, 48)) do hb[#hb+1] = p end
c:sketch(hb, {pressure=0.3})
local function closed(t) local u = {} for i, p in ipairs(t) do u[i] = p end u[#u+1] = t[1] return u end
for _, k in ipairs{"head","neck","torso","waist","skirt","blade","hand"} do c:sketch(closed(h[k]), {pressure=0.35}) end
for _, k in ipairs{"rarm_up","rarm_fore","shaft","larm_up","larm_fore"} do c:sketch(h[k], {pressure=0.35}) end
for _, k in ipairs{"lpaul","rpaul"} do local e = h[k]; c:sketch(closed(arc_pts(e[1], e[2], e[3], 0, 2*math.pi, 30)), {pressure=0.3}) end

--@ chunk 4
BW1 = pile{{"bone brown",2},{"raw sienna",1.5},{"burnt sienna",0.5},{"lead white",0.3}}
BW2 = pile{{"bone brown",2},{"raw sienna",1},{"burnt sienna",1},{"ultramarine blue",0.3}}
BW3 = pile{{"raw sienna",2},{"bone brown",1},{"burnt sienna",0.5},{"lead white",0.5}}
BW4 = pile{{"bone brown",1},{"ultramarine blue",1},{"bone black",1},{"burnt sienna",0.5}}
FIG.pelvis = {{452,745},{558,745},{578,800},{548,822},{462,822},{434,800}}
FIG.fauld = {{440,760},{570,760},{598,870},{575,878},{552,866},{528,884},{505,872},{482,886},{458,868},{432,880},{414,866}}
FIG.tabard = {{480,780},{532,780},{541,950},{526,1080},{506,1132},{486,1080},{471,950}}
FIG.lleg = {{{462,830},{447,960},{432,1080},{438,1165}}, {46,38,30,24}}
FIG.rleg = {{{548,830},{574,955},{588,1080},{582,1165}}, {44,36,30,24}}
FIG.lfoot = {{412,1160},{460,1158},{472,1196},{398,1200}}
FIG.rfoot = {{566,1158},{606,1158},{630,1197},{560,1200}}
function figmask()
  local h = FIG
  local m = ellipse(502, 302, 46, 68) + poly(h.neck) + poly(h.torso, true) + poly(h.waist) + poly(h.pelvis, true)
    + poly(h.fauld) + poly(h.tabard, true)
    + ribbon(h.lleg[1], h.lleg[2]) + ribbon(h.rleg[1], h.rleg[2]) + poly(h.lfoot, true) + poly(h.rfoot, true)
    + ellipse(h.lpaul[1], h.lpaul[2], h.lpaul[3], h.lpaul[4]) + ellipse(h.rpaul[1], h.rpaul[2], h.rpaul[3], h.rpaul[4])
    + ribbon(h.rarm_up, {36, 30}) + ribbon(h.rarm_fore, {30, 26}) + ellipse(334, 702, 20, 24)
    + ribbon(h.larm_up, {34, 28}) + ribbon(h.larm_fore, {28, 24}) + poly(h.hand, true)
    + ribbon(h.shaft, 12) + poly(h.blade, true)
  return m
end
local fm = figmask()
local halo = ellipse(505, 285, 150, 150) - ellipse(505, 285, 118, 118)
local keep = fm:grow(4) + halo:grow(3)
local niche = poly(NICHE)
local archo = poly(ARCH_OUT)
local above = rect(0, 0, 1000, SILL)
-- lit patch on the niche back wall: the opening shifted down-right
local shifted = {}
for i, p in ipairs(NICHE) do shifted[i] = {p[1] + 150, p[2] + 120} end
local lit = (poly(shifted) * niche):soften(10)
local figshadow = {}
-- outside wall
work((above - archo), {hand="broad", pile=R2, coverage=2.5, fill=true, angle=math.pi/2})
-- arch moulding
work((archo - niche) - keep, {hand="body", pile=R3, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-440, x-500) + math.pi/2 end})
-- niche shadowed part
work((niche - lit) - keep, {hand="body", pile=ND, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 5
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
function figmask2(dx, dy, lowered)
  local h = FIG
  local m = ellipse(502 + dx, 302 + dy, 46, 68) + poly(sh(h.neck,dx,dy)) + poly(sh(h.torso,dx,dy), true) + poly(sh(h.waist,dx,dy)) + poly(sh(h.pelvis,dx,dy), true)
    + poly(sh(h.fauld,dx,dy)) + poly(sh(h.tabard,dx,dy), true)
    + ribbon(sh(h.lleg[1],dx,dy), h.lleg[2]) + ribbon(sh(h.rleg[1],dx,dy), h.rleg[2]) + poly(sh(h.lfoot,dx,dy), true) + poly(sh(h.rfoot,dx,dy), true)
    + ellipse(h.lpaul[1]+dx, h.lpaul[2]+dy, h.lpaul[3], h.lpaul[4]) + ellipse(h.rpaul[1]+dx, h.rpaul[2]+dy, h.rpaul[3], h.rpaul[4])
    + ribbon(sh(h.rarm_up,dx,dy), {36, 30}) + ribbon(sh(h.rarm_fore,dx,dy), {30, 26}) + ellipse(334+dx, 702+dy, 20, 24)
    + ribbon(sh(h.shaft,dx,dy), 12) + poly(sh(h.blade,dx,dy), true)
  if lowered then
    -- the shadow's arm hangs at the side, hand open, as if it never rose
    m = m + ribbon({{622+dx,480+dy},{655+dx,610+dy},{668+dx,730+dy}}, {34,28,24}) + poly({{655+dx,725+dy},{685+dx,728+dy},{690+dx,790+dy},{676+dx,812+dy},{660+dx,790+dy}}, true)
  else
    m = m + ribbon(sh(h.larm_up,dx,dy), {34, 28}) + ribbon(sh(h.larm_fore,dx,dy), {28, 24}) + poly(sh(h.hand,dx,dy), true)
  end
  return m
end
local fm = figmask()
local halo = ellipse(505, 285, 150, 150) - ellipse(505, 285, 118, 118)
local keep = fm:grow(4) + halo:grow(3)
local niche = poly(NICHE)
local lit = (poly(sh(NICHE, 150, 120)) * niche)
local shadow = (figmask2(62, 44, true) + (ellipse(567, 329, 150, 150) - ellipse(567, 329, 118, 118))) * lit
-- lit back wall: warm brown, lighter toward upper right where the light lands first
work((lit - shadow) - keep, {hand="body", pile=BW1, coverage=3, fill=true, clip=niche - keep, angle=math.pi/2 + 0.2})
work(((lit - shadow) * rect(520, 160, 300, 380)) - keep, {hand="scumble", pile=BW3, coverage=1.2, clip=(lit - shadow) - keep})
-- the cast shadow of the warden
work(shadow - keep, {hand="body", pile=BW4, coverage=3, fill=true, clip=niche - keep, angle=math.pi/2})
-- warm the blue dark of the shadowed niche
work((niche - lit) - keep, {hand="scumble", pile=BW4, coverage=1.5, clip=(niche - lit) - keep})

--@ chunk 6
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local fm = figmask()
local halo = ellipse(505, 285, 150, 150) - ellipse(505, 285, 118, 118)
local keep = fm:grow(4) + halo:grow(3)
local niche = poly(NICHE)
local lit = (poly(sh(NICHE, 150, 120)) * niche)
local shadow = (figmask2(62, 44, true) + (ellipse(567, 329, 150, 150) - ellipse(567, 329, 118, 118))) * lit
local L = (lit - shadow) - keep
work(L * rect(0, 470, 1000, 800), {hand="body", pile=BW2, coverage=2.2, fill=true, clip=L, angle=math.pi/2 + 0.2})
work(L * rect(0, 330, 1000, 140), {hand="body", pile=BW2, coverage=1.0, clip=L, angle=math.pi/2 + 0.2})

--@ chunk 7
local archo = poly(ARCH_OUT)
local wall = rect(0, 0, 1000, SILL) - archo
work(wall, {hand="body", pile=R2, coverage=2.2, fill=true, clip=wall, angle=function(x,y) return math.atan(y-440, x-500) + math.pi/2 end})
work(wall, {hand="scumble", pile=WD, coverage=0.8, clip=wall})
local step = rect(0, SILL + 8, 1000, H - SILL)
work(step, {hand="body", pile=R1, coverage=3, fill=true, clip=step, angle=0})
work(rect(0, SILL - 6, 1000, 14), {hand="body", pile=R3, coverage=3, fill=true, clip=true, angle=0, tool="filbert 6"})

--@ chunk 8
print(wait(24*60)); print(drying(300,700), drying(700,600), drying(100,300))

--@ chunk 9
function make_form()
  local E = body.ellipsoid
  return form{
    {E({502,302,30},{46,68,40})},            -- 1 head
    {E({502,388,10},{20,30,18})},            -- 2 neck
    {E({505,560,0},{92,170,60})},            -- 3 torso
    {E({395,462,40},{58,46,45})},            -- 4 left pauldron (viewer left)
    {E({618,462,40},{56,44,45})},            -- 5 right pauldron
    {E({505,815,0},{100,78,55})},            -- 6 pelvis/fauld
    {E({506,955,45},{40,190,15})},           -- 7 tabard
    {E({455,895,0},{26,74,24})},             -- 8 l thigh
    {E({437,1065,0},{20,104,19})},           -- 9 l shin
    {E({561,893,0},{25,72,23})},             -- 10 r thigh
    {E({584,1062,0},{19,104,18})},           -- 11 r shin
    {E({371,546,30},{22,74,20})},            -- 12 r upper arm (viewer left)
    {E({342,656,40},{18,52,17})},            -- 13 r forearm
    {E({658,542,30},{21,72,20})},            -- 14 l upper arm (raised side)
    {E({708,537,40},{17,72,16})},            -- 15 l forearm
    light={from={-1,-0.85}, front=0.55, ambient=0.12}}
end
METAL = {{0,0.22,R1},{0.22,0.4,R2},{0.4,0.55,R3},{0.55,0.66,R4},{0.66,0.74,R2},{0.74,0.84,R5},{0.84,2,R6}}
function shade_parts(f, parts, steps, opts)
  opts = opts or {}
  local bands = {}
  for i, st in ipairs(steps) do
    local lo, hi = st[1], st[2]
    bands[i] = mask(function(x, y) local v = f:value(x, y); return (v >= lo and v < hi) and 1 or 0 end)
  end
  for _, pt in ipairs(parts) do
    local m = pt[1]
    for i, st in ipairs(steps) do
      local bm = bands[i] * m
      if bm:area() > 1 then
        work(bm, {hand="body", pile=st[3], coverage=opts.coverage or 3, fill=true, clip=m,
          tool=pt.tool or opts.tool or "filbert 5", length=pt.length or {6, 18}, angle=pt.angle or opts.angle})
      end
    end
  end
end
local f = make_form()
local h = FIG
local parts = {
  {ellipse(502, 302, 46, 68), angle=math.pi/2},
  {poly(h.neck), tool="filbert 3", angle=0},
  {poly(h.torso, true), angle=math.pi/2},
  {ellipse(h.lpaul[1], h.lpaul[2], h.lpaul[3], h.lpaul[4]), angle=0.6},
  {ellipse(h.rpaul[1], h.rpaul[2], h.rpaul[3], h.rpaul[4]), angle=2.5},
  {poly(h.waist), tool="filbert 3", angle=0},
}
shade_parts(f, parts, METAL)

--@ chunk 10
local f = make_form()
local h = FIG
local parts = {
  {poly(h.pelvis, true) + poly(h.fauld), angle=math.pi/2},
  {poly(h.tabard, true), angle=math.pi/2, tool="filbert 4"},
  {ribbon({h.lleg[1][1], h.lleg[1][2]}, {h.lleg[2][1], h.lleg[2][2]}) - poly(h.fauld) - poly(h.tabard, true), angle=math.pi/2 + 0.1, tool="filbert 4"},
  {ribbon({h.lleg[1][2], h.lleg[1][3], h.lleg[1][4]}, {h.lleg[2][2], h.lleg[2][3], h.lleg[2][4]}) - poly(h.tabard, true), angle=math.pi/2, tool="filbert 4"},
  {ribbon({h.rleg[1][1], h.rleg[1][2]}, {h.rleg[2][1], h.rleg[2][2]}) - poly(h.fauld) - poly(h.tabard, true), angle=math.pi/2 - 0.2, tool="filbert 4"},
  {ribbon({h.rleg[1][2], h.rleg[1][3], h.rleg[1][4]}, {h.rleg[2][2], h.rleg[2][3], h.rleg[2][4]}), angle=math.pi/2, tool="filbert 4"},
  {ribbon(h.rarm_up, {36, 30}) - ellipse(h.lpaul[1], h.lpaul[2], h.lpaul[3], h.lpaul[4]), angle=1.9, tool="filbert 4"},
  {ribbon(h.rarm_fore, {30, 26}) + ellipse(334, 702, 20, 24), angle=1.75, tool="filbert 3"},
  {ribbon(h.larm_up, {34, 28}) - ellipse(h.rpaul[1], h.rpaul[2], h.rpaul[3], h.rpaul[4]), angle=1.05, tool="filbert 4"},
  {ribbon(h.larm_fore, {28, 24}) + poly(h.hand, true), angle=-1.35, tool="filbert 3"},
  {poly(h.lfoot, true), angle=0, tool="filbert 3"},
  {poly(h.rfoot, true), angle=0, tool="filbert 3"},
}
shade_parts(f, parts, METAL)

--@ chunk 11
FIG.mantle = {{392,468},{372,540},{356,650},{344,780},{330,900},{316,1020},{302,1128},{316,1158},{340,1146},{362,1170},{392,1152},{420,1176},
  {600,1176},{626,1156},{652,1174},{680,1152},{704,1166},{714,1126},{700,1010},{684,880},{668,760},{652,640},{638,540},{622,468}}
local fm = figmask()
local mant = poly(FIG.mantle, true) - fm
local f = form{ {body.ellipsoid({505, 800, -40}, {215, 400, 70})}, light={from={-1,-0.85}, front=0.55, ambient=0.12} }
local steps = {{0,0.3,R1},{0.3,0.45,R2},{0.45,0.6,R3},{0.6,0.72,R4},{0.72,2,R5}}
local bands = {}
for i, st in ipairs(steps) do
  local bm = mant * mask(function(x, y) local v = f:value(x, y); return (v >= st[1] and v < st[2]) and 1 or 0 end)
  if bm:area() > 1 then work(bm, {hand="body", pile=st[3], coverage=3, fill=true, clip=mant, tool="filbert 6", length={10, 30}, angle=math.pi/2}) end
end

--@ chunk 12
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
function sector(cx, cy, r0, r1, a0, a1, n)
  n = n or 24
  local t = {}
  for i = 0, n do local a = a0 + (a1 - a0) * i / n; t[#t+1] = {cx + r1 * math.cos(a), cy + r1 * math.sin(a)} end
  for i = n, 0, -1 do local a = a0 + (a1 - a0) * i / n; t[#t+1] = {cx + r0 * math.cos(a), cy + r0 * math.sin(a)} end
  return t
end
-- the nimbus, broken out between -62 and -4 degrees (upper right)
local cx, cy = 505, 285
local A0, A1 = math.rad(-4), math.rad(298)
local fm = figmask()
local segs = 10
for i = 0, segs - 1 do
  local a0 = A0 + (A1 - A0) * i / segs
  local a1 = A0 + (A1 - A0) * (i + 1) / segs
  local am = (a0 + a1) / 2
  -- light from upper left: facing direction of the ring surface is toward us; the ring's own tilt catches more light upper-left
  local lit = 0.5 + 0.5 * math.cos(am - math.rad(225))
  local p = lit > 0.8 and Q5 or lit > 0.55 and Q4 or lit > 0.3 and Q3 or Q2
  local m = poly(sector(cx, cy, 118, 150, a0 - 0.02, a1 + 0.02, 8)) - fm
  work(m, {hand="body", pile=p, coverage=3, fill=true, clip=m, tool="filbert 4", length={8, 16}, angle=am + math.pi/2})
end

--@ chunk 13
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local fm = figmask() + (poly(FIG.mantle, true))
local cx, cy = 505, 285
local ringdrawn = poly(sector(cx, cy, 118, 150, math.rad(-4), math.rad(298), 60))
local gapsector = poly(sector(cx, cy, 114, 154, math.rad(296), math.rad(357), 16))
local solid = fm + ringdrawn
local band = ((fm:grow(9) + ringdrawn:grow(9) + gapsector) - solid) * poly(NICHE)
local niche = poly(NICHE)
local lit = (poly(sh(NICHE, 150, 120)) * niche)
local shadow = (figmask2(62, 44, true) + (ellipse(567, 329, 150, 150) - ellipse(567, 329, 118, 118))) * lit
local A = band * (lit - shadow)
local B = band * shadow
local C = band * (niche - lit)
work(A, {hand="detail", pile=BW2, coverage=3, fill=true, clip=A})
work(B, {hand="detail", pile=BW4, coverage=3, fill=true, clip=B})
work(C, {hand="detail", pile=ND, coverage=3, fill=true, clip=C})

--@ chunk 14
local shaft = ribbon(FIG.shaft, 12)
local blade = poly(FIG.blade, true)
local Ls = shaft * rect(310, 0, 11, 1300)
local Rs = shaft * rect(321, 0, 15, 1300)
work(Rs, {hand="detail", pile=Q2, coverage=3, fill=true, clip=Rs, angle=math.pi/2})
work(Ls, {hand="detail", pile=Q4, coverage=3, fill=true, clip=Ls, angle=math.pi/2})
-- blade: two facets around a central rib
local Lb = blade * rect(280, 0, 42, 220)
local Rb = blade * rect(322, 0, 40, 220)
work(Rb, {hand="detail", pile=Q3, coverage=3, fill=true, clip=Rb, angle=math.pi/2})
work(Lb, {hand="detail", pile=Q5, coverage=3, fill=true, clip=Lb, angle=math.pi/2})

--@ chunk 15
print(wait(2*24*60))

--@ chunk 16
local archo = poly(ARCH_OUT)
local wall = rect(0, 0, 1000, SILL) - archo
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
local z1 = wall * mask(function(x, y) return dl(x, y) < 560 and 1 or 0 end):roughen(25, 80, 3)
local z2 = wall * mask(function(x, y) local d = dl(x, y); return (d >= 520 and d < 900) and 1 or 0 end):roughen(25, 80, 4)
local z3 = wall * mask(function(x, y) return dl(x, y) >= 860 and 1 or 0 end):roughen(25, 80, 5)
local ang = function(x, y) return math.atan(y - 440, x - 500) + math.pi / 2 end
work(z3, {hand="body", pile=R1, coverage=2.6, fill=true, clip=wall, angle=ang})
work(z2, {hand="body", pile=R2, coverage=2.6, fill=true, clip=wall, angle=ang})
work(z1, {hand="body", pile=Q3, coverage=2.6, fill=true, clip=wall, angle=ang})

--@ chunk 17
local archo = poly(ARCH_OUT)
local wall = rect(0, 0, 1000, SILL) - archo
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
local s1 = wall * mask(function(x, y) local d = dl(x, y); return (d > 470 and d < 640) and 1 or 0 end)
local s2 = wall * mask(function(x, y) local d = dl(x, y); return (d > 800 and d < 960) and 1 or 0 end)
blend(s1, {angle=function(x, y) return math.atan(y + 100, x + 150) end, tool={kind="badger", width=24}})
blend(s2, {angle=function(x, y) return math.atan(y + 100, x + 150) end, tool={kind="badger", width=24}})

--@ chunk 18
GA = math.rad(137.50776)
LIGHT_ANG = math.atan(-0.85, -1)
function arcpts(cx, cy, r, a0, a1, n)
  local t = {}
  for i = 0, n do local a = a0 + (a1 - a0) * i / n; t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
  return t
end
-- runs of an arc where pred(angle) holds, as point lists
local function arc_runs(cx, cy, r, a0, a1, n, pred)
  local runs, cur = {}, nil
  for i = 0, n do
    local a = a0 + (a1 - a0) * i / n
    if pred(a) then
      cur = cur or {}
      cur[#cur+1] = {cx + r * math.cos(a), cy + r * math.sin(a)}
    else
      if cur and #cur >= 3 then runs[#runs+1] = cur end
      cur = nil
    end
  end
  if cur and #cur >= 3 then runs[#runs+1] = cur end
  return runs
end
-- one scale-plate. bs: body sheen brush (or nil), bd: shadow brush, bl: lip brush
function plate(bs, bd, bl, cx, cy, ua, rad, opts)
  opts = opts or {}
  local span = opts.span or 1.2
  local face = math.cos(ua - LIGHT_ANG)
  if bs and face > -0.3 then
    local sp = arcpts(cx - 0.35 * rad * math.cos(ua), cy - 0.35 * rad * math.sin(ua), rad * 0.62, ua - span * 0.7, ua + span * 0.7, 8)
    bs:stroke(sp, {pressure={0.3, 0.5 * (0.5 + 0.5 * face), 0.1}, ramps={0.3, 0.5}})
  end
  for _, run in ipairs(arc_runs(cx + 2.4 * math.cos(ua), cy + 2.4 * math.sin(ua), rad, ua - span, ua + span, 14,
      function(a) return math.cos(a - LIGHT_ANG) < 0.35 end)) do
    bd:stroke(run, {pressure={0.65, 0.25}, ramps={0.2, 0.4}})
  end
  for _, run in ipairs(arc_runs(cx, cy, rad - 1.2, ua - span, ua + span, 14,
      function(a) return math.cos(a - LIGHT_ANG) > 0.15 end)) do
    bl:stroke(run, {pressure={0.15, 0.55 * (opts.lip or 1), 0.1}, ramps={0.3, 0.4}})
  end
end

--@ chunk 19
print(wait(2*24*60)); print(drying(100,100), drying(900,900), drying(450,600), drying(250,500))

--@ chunk 20
print(wait(3*24*60)); print(drying(100,100), drying(900,900), drying(450,600), drying(250,500), drying(500,300))

--@ chunk 21
DK = pile{{"bone black",1},{"bone brown",1},{"ultramarine blue",0.5}}
LT = pile{{"yellow ochre",2},{"lead white",1},{"Mars yellow",0.5},{"raw sienna",0.5}}
local LTd = pile{{"raw sienna",2},{"yellow ochre",1},{"bone brown",0.5}}
local SH = Q4
local bs = brush{kind="filbert", width=8}
local bd = brush{kind="round", width=3.6, point=0.6}
local bl = brush{kind="round", width=2.0, point=0.8}
local bl2 = brush{kind="round", width=2.0, point=0.8}
local cx, cy = 500, 440
local c = 24
local n = 0
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
for k = 220, 1600 do
  local r = c * math.sqrt(k)
  local a = k * GA
  local x, y = cx + r * math.cos(a), cy + r * math.sin(a)
  local inarch = (y < 440 and r < 380) or (y >= 440 and x > 120 and x < 880)
  if x > -10 and x < 1010 and y > -10 and y < SILL - 12 and not inarch then
    if n % 5 == 0 then bs:reload(SH, 0.45); bd:reload(DK, 0.7); bl:reload(LT, 0.6); bl2:reload(LTd, 0.6) end
    n = n + 1
    local d = dl(x, y)
    local s = clamp((950 - d) / 500, 0.2, 1)
    plate(d < 650 and bs or nil, bd, d < 700 and bl or bl2, x, y, a, 0.62 * c * 1.77, {span=1.0, lip=s})
  end
end
print(n)

--@ chunk 22
local bd = brush{kind="round", width=2.4, point=0.7}
local SEAM = pile{{"bone brown",2},{"bone black",0.6},{"burnt sienna",0.5}}
local cx, cy = 500, 440
local c = 24
local n = 0
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
for k = 220, 1600 do
  local r = c * math.sqrt(k)
  local a = k * GA
  local x, y = cx + r * math.cos(a), cy + r * math.sin(a)
  local inarch = (y < 440 and r < 380) or (y >= 440 and x > 120 and x < 880)
  if x > -10 and x < 1010 and y > -10 and y < SILL - 12 and not inarch and dl(x, y) < 900 then
    if n % 6 == 0 then bd:reload(SEAM, 0.6) end
    n = n + 1
    local rad = 0.62 * c * 1.77
    -- the seam just outside the lip, full arc, thin
    local pts = arcpts(x + 1.6 * math.cos(a), y + 1.6 * math.sin(a), rad, a - 1.05, a + 1.05, 14)
    bd:stroke(pts, {pressure={0.2, 0.45, 0.15}, ramps={0.25, 0.35}})
  end
end
print(n)

--@ chunk 23
local Lx, Ly, Lz = -0.62, -0.52, 0.58
local function torus_val(x, y)
  -- radial outward direction and position across the moulding
  local ox, oy, t
  if y < NICHE_SPRING then
    local dx, dy = x - NICHE_CX, y - NICHE_SPRING
    local r = math.sqrt(dx * dx + dy * dy)
    ox, oy = dx / r, dy / r
    t = (r - 320) / 48
  elseif x < 500 then ox, oy = -1, 0; t = (180 - x) / 48
  else ox, oy = 1, 0; t = (x - 820) / 48 end
  local phi = (t - 0.5) * math.pi * 0.95     -- -90..90 deg across the bead
  local nx, ny, nz = ox * math.sin(phi), oy * math.sin(phi), math.cos(phi)
  return math.max(0, nx * Lx + ny * Ly + nz * Lz)
end
local mould = poly(ARCH_OUT) - poly(NICHE)
local fm = figmask()
local blade = poly(FIG.blade, true) + ribbon(FIG.shaft, 12)
mould = mould - blade:grow(2)
local steps = {{-1,0.15,R1},{0.15,0.35,Q2},{0.35,0.55,Q3},{0.55,0.72,Q4},{0.72,0.86,Q5},{0.86,2,R6}}
for _, st in ipairs(steps) do
  local bm = mould * mask(function(x, y) local v = torus_val(x, y); return (v >= st[1] and v < st[2]) and 1 or 0 end)
  if bm:area() > 1 then
    work(bm, {hand="body", pile=st[3], coverage=3, fill=true, clip=mould, tool="filbert 4", length={8, 20},
      angle=function(x, y) if y < NICHE_SPRING then return math.atan(y - NICHE_SPRING, x - NICHE_CX) + math.pi/2 else return math.pi/2 end end})
  end
end

--@ chunk 24
print(drying(500,560), drying(450,900), drying(505,300), drying(560,250), drying(400,800))

--@ chunk 25
local fm = figmask()
local mant = poly(FIG.mantle, true) - fm
local ml = mant * rect(0, 0, 505, H)
local mr = mant * rect(505, 0, 500, H)
work(ml, {hand="body", pile=Q2, coverage=3, fill=true, clip=mant, angle=math.pi/2, length={20, 50}})
work(mr, {hand="body", pile=R1, coverage=3, fill=true, clip=mant, angle=math.pi/2, length={20, 50}})
-- pleats: crests and valleys falling from the shoulders, splaying toward the hem
local bc = brush{kind="filbert", width=9}
local bv = brush{kind="filbert", width=7}
local function line(x0, y0, x1, y1) local t = {} for i = 0, 8 do local s = i / 8; t[#t+1] = {lerp(x0, x1, s) + 3 * math.sin(s * 5 + x0), lerp(y0, y1, s)} end return t end
local crestsL = {{392, 520, 352, 1150}, {420, 600, 395, 1160}, {372, 560, 318, 1120}}
local valleysL = {{405, 560, 374, 1150}, {384, 540, 335, 1140}, {434, 640, 420, 1170}}
for _, v in ipairs(valleysL) do bv:reload(DK, 0.8); bv:stroke(line(table.unpack(v)), {pressure={0.7, 0.9}, clip=mant}) end
for _, c in ipairs(crestsL) do bc:reload(Q3, 0.8); bc:stroke(line(table.unpack(c)), {pressure={0.4, 0.8}, clip=mant}) end
local crestsR = {{628, 540, 660, 1150}, {650, 620, 700, 1140}, {600, 700, 618, 1160}}
local valleysR = {{640, 560, 682, 1160}, {615, 600, 640, 1170}}
for _, v in ipairs(valleysR) do bv:reload(DK, 0.8); bv:stroke(line(table.unpack(v)), {pressure={0.7, 0.9}, clip=mant}) end
for _, c in ipairs(crestsR) do bc:reload(R2, 0.7); bc:stroke(line(table.unpack(c)), {pressure={0.3, 0.7}, clip=mant}) end

--@ chunk 26
METAL2 = {{0,0.22,R1},{0.22,0.4,Q2},{0.4,0.55,Q3},{0.55,0.66,Q4},{0.66,0.74,Q3},{0.74,0.86,Q5},{0.86,2,R6}}
FIG.chest = {{430,440},{580,440},{571,520},{552,606},{530,684},{505,714},{480,684},{458,606},{439,520}}
FIG.cage = {{438,540},{572,540},{560,640},{548,700},{462,700},{450,640}}
local L = {from={-1,-0.85}, front=0.55, ambient=0.12}
-- the cage behind the chest plate: dark interior first
local cage = poly(FIG.cage, true) - poly(FIG.chest, true)
work(cage, {hand="body", pile=DK, coverage=3, fill=true, clip=cage, tool="filbert 4", angle=0})
-- chest plate
local f = form{ {body.ellipsoid({505, 560, 0}, {84, 170, 55})}, light=L }
shade(poly(FIG.chest, true), f, METAL2, {tool="filbert 5", length={8, 22}, angle=math.pi/2})

--@ chunk 27
local cage = poly(FIG.cage, true) - poly(FIG.chest, true)
local EMB = pile{{"Mars orange",1},{"cadmium yellow",1},{"lead white",0.6}}
local EMD = pile{{"burnt sienna",1},{"Mars orange",1},{"bone brown",0.5}}
local be = brush{kind="round", width=6}
-- embers deep in the cage (left side), put down first so the ribs cross them
local function dab(b, p, x, y, pr) b:reload(p, 0.6); b:touch(x, y, {pressure=pr, clip=cage}) end
dab(be, EMD, 452, 596, 0.6); dab(be, EMD, 456, 632, 0.6); dab(be, EMD, 466, 666, 0.5)
dab(be, EMB, 453, 598, 0.35); dab(be, EMB, 458, 633, 0.3)
-- one gap on the far side holds a cold light instead
dab(be, CV, 556, 615, 0.6); dab(be, CC, 555, 616, 0.3)
-- ribs: curved bands from the plate edge around the flank
local bb = brush{kind="filbert", width=6}
local bt = brush{kind="round", width=2.2, point=0.6}
for i = 0, 4 do
  local y = 552 + i * 31
  -- left flank (lit)
  local ptsL = {{486 - i * 4, y - 6}, {466 - i * 2, y + 2}, {449 - i, y + 12}, {442, y + 22}}
  bb:reload(Q3, 0.7); bb:stroke(ptsL, {pressure={0.6, 0.5}, clip=cage})
  bt:reload(Q5, 0.6); bt:stroke({{ptsL[1][1], ptsL[1][2] - 3}, {ptsL[2][1], ptsL[2][2] - 3}, {ptsL[3][1], ptsL[3][2] - 3}}, {pressure={0.5, 0.2}, clip=cage})
  -- right flank (shadow)
  local ptsR = {{526 + i * 4, y - 6}, {546 + i * 2, y + 2}, {560 + i, y + 12}, {566, y + 22}}
  bb:reload(Q2, 0.7); bb:stroke(ptsR, {pressure={0.6, 0.5}, clip=cage})
  bt:reload(R2, 0.6); bt:stroke({{ptsR[1][1], ptsR[1][2] - 3}, {ptsR[2][1], ptsR[2][2] - 3}}, {pressure={0.4, 0.2}, clip=cage})
end

--@ chunk 28
FIG.helm = {{513,226},{530,240},{545,268},{551,302},{545,338},{528,362},{506,374},{484,364},{466,340},{458,302},{463,266},{479,240},{496,228}}
local L = {from={-1,-0.85}, front=0.55, ambient=0.12}
local helm = poly(FIG.helm, true)
local f = form{ {body.ellipsoid({505, 302, 0}, {48, 74, 44})}, light=L }
shade(helm, f, METAL2, {tool="filbert 3", length={5, 12}, angle=function(x, y) return math.atan(y - 330, x - 505) + math.pi / 2 end})

--@ chunk 29
local L = {from={-1,-0.85}, front=0.55, ambient=0.12}
local h = FIG
local tab = poly(h.tabard, true)
local fauld = poly(h.fauld)
local E = body.ellipsoid
local f = form{ {E({455,905,0},{26,70,24})}, {E({437,1065,0},{21,104,20})}, {E({561,903,0},{25,68,23})}, {E({584,1062,0},{20,104,19})},
  {E({436,1180,10},{38,22,18})}, {E({594,1180,10},{38,22,18})}, light=L }
local lth = ribbon({{462,830},{447,960}}, {46, 38}) - fauld - tab
local lsh = ribbon({{447,960},{432,1080},{438,1165}}, {38, 30, 24}) - tab
local rth = ribbon({{548,830},{574,955}}, {44, 36}) - fauld - tab
local rsh = ribbon({{574,955},{588,1080},{582,1165}}, {36, 30, 24})
local lft = poly(h.lfoot, true)
local rft = poly(h.rfoot, true)
for _, m in ipairs{lth, lsh, rth, rsh} do
  shade(m, f, METAL2, {tool="filbert 4", length={8, 20}, angle=math.pi/2})
end
for _, m in ipairs{lft, rft} do
  shade(m, f, METAL2, {tool="filbert 3", length={5, 12}, angle=0})
end

--@ chunk 30
print(wait(30*60*1)); print(wait(26*60)); print(drying(505,300), drying(505,560), drying(450,1000), drying(380,900))

--@ chunk 31
print(wait(36*60)); print(drying(505,300), drying(505,560), drying(450,1000), drying(380,900))

--@ chunk 32
print(wait(3*24*60)); print(drying(505,300), drying(505,560), drying(450,1000), drying(380,900))

--@ chunk 33
BS2 = pile{{"lead white",1},{"raw sienna",1},{"bone brown",1},{"ultramarine ash",0.5}}
FIG.mask = {{507,274},{522,284},{532,304},{532,330},{522,350},{508,362},{493,352},{484,332},{483,304},{492,284}}
local L = {from={-1,-0.85}, front=0.55, ambient=0.12}
local fmask = poly(FIG.mask, true)
local f = form{ {body.ellipsoid({508, 318, 10}, {27, 44, 22})}, light=L }
shade(fmask, f, {{0,0.38,BS2},{0.38,0.62,BS},{0.62,2,BN}}, {tool="filbert 3", length={4, 10}, angle=math.pi/2})
-- pauldrons: three lames each, the lowest first
local E = body.ellipsoid
local function lames(cx, cy, flip)
  local L3 = ellipse(cx - 9 * flip, cy + 40, 54, 26)
  local L2 = ellipse(cx - 4 * flip, cy + 18, 58, 32)
  local L1 = ellipse(cx + 2 * flip, cy - 8, 54, 38)
  local f3 = form{ {E({cx - 9 * flip, cy + 40, 0}, {54, 26, 40})}, light=L }
  local f2 = form{ {E({cx - 4 * flip, cy + 18, 0}, {58, 32, 44})}, light=L }
  local f1 = form{ {E({cx + 2 * flip, cy - 8, 0}, {54, 38, 48})}, light=L }
  shade(L3 - L2, f3, METAL2, {tool="filbert 3", length={5, 12}, angle=0.2 * flip})
  shade(L2 - L1, f2, METAL2, {tool="filbert 3", length={5, 12}, angle=0.2 * flip})
  shade(L1, f1, METAL2, {tool="filbert 4", length={6, 14}, angle=0.4 * flip})
end
lames(396, 458, 1)
lames(618, 458, -1)

--@ chunk 34
local cx, cy = 505, 285
local A0, A1 = math.rad(-4), math.rad(298)
local fm = figmask() + poly(FIG.helm, true)
local function lit_at(a) return 0.5 + 0.5 * math.cos(a - math.rad(225)) end
-- recessed channel
local ch = poly(sector(cx, cy, 125, 141, A0 + 0.01, A1 - 0.01, 80)) - fm
work(ch, {hand="body", pile=Q2, coverage=3, fill=true, clip=ch, tool="filbert 3", length={6, 14}, angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end})
-- beads, stroked along the arc in short runs whose pile follows the light
local bo = brush{kind="filbert", width=7}
local bi = brush{kind="filbert", width=5}
local n = 28
for i = 0, n - 1 do
  local a0 = A0 + (A1 - A0) * i / n
  local a1 = A0 + (A1 - A0) * (i + 1.15) / n
  local am = (a0 + a1) / 2
  local lo = lit_at(am)
  local po = lo > 0.85 and R6 or lo > 0.65 and Q5 or lo > 0.4 and Q4 or lo > 0.2 and Q3 or Q2
  bo:reload(po, 0.7)
  bo:stroke(arcpts(cx, cy, 146, a0, a1, 6), {pressure={0.7, 0.7}, clip=-fm})
  local li = 1 - lo
  local pi_ = li > 0.85 and Q5 or li > 0.6 and Q4 or li > 0.35 and Q3 or Q2
  bi:reload(pi_, 0.7)
  bi:stroke(arcpts(cx, cy, 121, a0, a1, 6), {pressure={0.7, 0.7}, clip=-fm})
end

--@ chunk 35
local L = {from={-1,-0.85}, front=0.55, ambient=0.12}
local h = FIG
local E = body.ellipsoid
local fauld = poly(h.fauld) + poly(h.pelvis, true)
local tab = poly(h.tabard, true)
local ff = form{ {E({505, 812, 0}, {104, 82, 58})}, light=L }
shade(fauld - tab, ff, METAL2, {tool="filbert 4", length={6, 16}, angle=math.pi/2})
local ft = form{ {E({506, 955, 30}, {44, 200, 16})}, light=L }
shade(tab, ft, METAL2, {tool="filbert 4", length={10, 24}, angle=math.pi/2})

--@ chunk 36
function seg_ell(T, B, rw, z)
  local cx, cy = (T[1] + B[1]) / 2, (T[2] + B[2]) / 2
  local len = math.sqrt((T[1] - B[1])^2 + (T[2] - B[2])^2)
  local th = math.atan(T[1] - B[1], B[2] - T[2])
  return body.ellipsoid({cx, cy, z or 0}, {rw, len / 2 + rw * 0.3, rw}):turn({cx, cy, z or 0}, 0, 0, th)
end
LGT = {from={-1,-0.85}, front=0.55, ambient=0.12}
FIG.ru = {{372,486},{406,498},{370,614},{338,606}}
FIG.rf = {{338,602},{370,612},{356,692},{326,690}}
FIG.rfist = {{310,684},{350,686},{354,712},{342,728},{314,726},{306,706}}
FIG.lu = {{614,490},{646,486},{710,598},{682,618}}
FIG.lf = {{682,612},{708,598},{740,486},{710,480}}
local shaft = ribbon(FIG.shaft, 12)
local parts = {
  {poly(FIG.ru, true), seg_ell({390,492},{354,610},20), "filbert 4"},
  {poly(FIG.rf, true), seg_ell({354,607},{341,691},17), "filbert 4"},
  {poly(FIG.lu, true), seg_ell({630,488},{696,608},19), "filbert 4"},
  {poly(FIG.lf, true), seg_ell({695,605},{725,483},17), "filbert 4"},
}
for _, p in ipairs(parts) do
  local f = form{ {p[2]}, light=LGT }
  shade(p[1], f, METAL2, {tool=p[3], length={6, 14}})
end
-- the fist over the shaft
local fist = poly(FIG.rfist, true)
local ff = form{ {body.ellipsoid({330, 706, 12}, {24, 22, 16})}, light=LGT }
shade(fist, ff, METAL2, {tool="filbert 3", length={4, 9}, angle=0})

--@ chunk 37
-- a tapered metal tube from T to B, half-widths w0 (at T) and w1 (at B); lit from the left
-- passes: base fill; lit plane; core shadow; highlight line; reflected light
function tube(T, B, w0, w1, P, opts)
  opts = opts or {}
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local nx, ny = uy, -ux               -- perpendicular
  if nx > 0 then nx, ny = -nx, -ny end -- point it to the left (toward the light)
  local function line(off, s0, s1)     -- off in -1..1 of the half width, + toward the light
    local t = {}
    for i = 0, 8 do
      local s = lerp(s0 or 0.02, s1 or 0.98, i / 8)
      local w = lerp(w0, w1, s)
      t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off}
    end
    return t
  end
  local outline = {}
  for _, p in ipairs(line(1, 0, 1)) do outline[#outline+1] = p end
  local back = line(-1, 0, 1)
  for i = #back, 1, -1 do outline[#outline+1] = back[i] end
  local m = poly(outline, true)
  if opts.cut then m = m - opts.cut end
  local wm = (w0 + w1)
  work(m, {hand="body", pile=P.base, coverage=3, fill=true, clip=m, tool={kind="filbert", width=math.max(2, wm * 0.4)}, angle=math.atan(dy, dx), length={len * 0.3, len * 0.7}})
  local b = brush{kind="filbert", width=math.max(1.5, wm * 0.35)}
  b:reload(P.lit, 0.8); b:stroke(line(0.45), {pressure={0.7, 0.6}, clip=m})
  b:reload(P.dark, 0.8); b:stroke(line(-0.4), {pressure={0.7, 0.7}, clip=m})
  local r = brush{kind="round", width=math.max(1.2, wm * 0.12), point=0.5}
  r:reload(P.hi, 0.7); r:stroke(line(0.62, 0.08, 0.85), {pressure={0.3, 0.8, 0.2}, clip=m})
  if P.refl then r:reload(P.refl, 0.6); r:stroke(line(-0.85, 0.15, 0.9), {pressure={0.3, 0.5, 0.2}, clip=m}) end
  return m
end

--@ chunk 38
print(wait(5*24*60)); print(drying(360,560), drying(700,550), drying(450,1000), drying(505,800), drying(505,140))

--@ chunk 39
print(wait(4*24*60)); print(drying(360,560), drying(700,550), drying(450,1000), drying(505,800), drying(400,470))

--@ chunk 40
PL = {base=Q3, lit=Q5, dark=R1, hi=R7, refl=VD}
PD = {base=Q2, lit=Q4, dark=R1, hi=Q5, refl=VD}
local pauldL = ellipse(398, 452, 54, 38) + ellipse(392, 476, 58, 32)
local pauldR = ellipse(616, 452, 54, 38) + ellipse(622, 476, 58, 32)
-- arms
tube({392, 488}, {354, 610}, 17, 15, PL, {cut=pauldL})
tube({354, 606}, {339, 690}, 15, 12, PL)
tube({630, 488}, {696, 608}, 16, 14, PL, {cut=pauldR})
tube({696, 606}, {726, 484}, 14, 11, PL)
-- legs (below the fauld), the far leg darker
local fauld = poly(FIG.fauld) + poly(FIG.tabard, true)
tube({461, 850}, {448, 962}, 21, 18, PL, {cut=fauld})
tube({448, 960}, {437, 1162}, 18, 11, PL, {cut=poly(FIG.tabard, true)})
tube({549, 850}, {574, 957}, 20, 17, PD, {cut=fauld})
tube({574, 955}, {584, 1162}, 17, 11, PD)

--@ chunk 41
local old = (poly(FIG.fauld) + poly(FIG.pelvis, true)) * rect(0, 760, 1000, 200)
work(old, {hand="body", pile=DK, coverage=3, fill=true, clip=old, tool="filbert 5", angle=math.pi/2})
local plates = {
  {448, 405, 905, PL}, {562, 608, 905, PD},
  {462, 428, 930, PL}, {550, 586, 930, PD},
  {476, 452, 948, PL}, {536, 560, 948, PD},
  {490, 478, 958, PL}, {522, 534, 958, PD},
}
for _, p in ipairs(plates) do
  tube({p[1], 752}, {p[2], p[3]}, 12, 15, p[4])
end

--@ chunk 42
FIG.tabard2 = {{490,748},{522,748},{528,900},{526,1040},{516,1110},{506,1136},{496,1110},{486,1040},{484,900}}
local tab = poly(FIG.tabard2, true)
-- clear the old wide tabard around the new narrow one with the mantle's dark
local oldtab = poly(FIG.tabard, true) * rect(0, 960, 1000, 300) - tab
work(oldtab, {hand="body", pile=DK, coverage=3, fill=true, clip=oldtab, tool="filbert 4", angle=math.pi/2})
local f = form{ {body.ellipsoid({506, 940, 10}, {26, 210, 12})}, light=LGT }
shade(tab, f, METAL2, {tool="filbert 3", length={10, 24}, angle=math.pi/2})
-- belt
FIG.belt = {{450,736},{560,736},{566,760},{444,760}}
local belt = poly(FIG.belt, true)
local fb = form{ {body.ellipsoid({505, 748, 20}, {64, 16, 40})}, light=LGT }
shade(belt, fb, METAL2, {tool="filbert 3", length={6, 14}, angle=0})

--@ chunk 43
print(drying(508,318), drying(470,300), drying(540,300), drying(505,240))

--@ chunk 44
local mcx, mcy = 508, 318
local helm = poly(FIG.helm, true)
local fmask = poly(FIG.mask, true)
-- petals of the closed bud: lips around the bone disc, two rows on golden-angle offsets
local bs = brush{kind="filbert", width=5}
local bd = brush{kind="round", width=2.6, point=0.6}
local bl = brush{kind="round", width=1.6, point=0.8}
local n = 0
for k = 1, 40 do
  local a = k * GA
  local row = (k % 2 == 0) and 1.28 or 1.6
  local x = mcx + 26 * row * math.cos(a)
  local y = mcy + 44 * row * math.sin(a)
  if helm:at(x, y) > 0.5 and fmask:at(x, y) < 0.5 then
    if n % 4 == 0 then bs:reload(Q4, 0.5); bd:reload(DK, 0.7); bl:reload(R6, 0.6) end
    n = n + 1
    plate(bs, bd, bl, x, y, math.atan((y - mcy) / 44, (x - mcx) / 26), 9, {span=1.0})
  end
end
print("petals", n)

--@ chunk 45
local mcx, mcy, RX, RY = 508, 318, 26, 44
local function P(r, a) return {mcx + RX * r * math.cos(a), mcy + RY * r * math.sin(a)} end
local bd = brush{kind="round", width=2.2, point=0.6}
local bl = brush{kind="round", width=1.8, point=0.7}
local fmask = poly(FIG.mask, true)
for i = 1, 13 do
  local a = i * GA + 0.3
  local w = 0.26 + 0.05 * math.sin(i * 1.7)
  local tip = 1.62 + 0.08 * math.cos(i * 2.3)
  local pts = {P(1.0, a - w), P(1.3, a - w * 0.9), P(tip, a), P(1.3, a + w * 0.9), P(1.0, a + w)}
  local m = poly(pts, true) - fmask
  local v = math.cos(a - LIGHT_ANG)
  local pl = v > 0.55 and Q5 or v > 0.05 and Q4 or v > -0.5 and Q3 or Q2
  work(m, {hand="detail", pile=pl, coverage=3, fill=true, clip=m, tool="filbert 3", angle=a})
  -- the edge turned from the light carries a dark seam; the edge toward it a lit lip
  local e1 = {P(1.02, a + w), P(1.3, a + w * 0.9), P(tip, a)}
  local e2 = {P(1.02, a - w), P(1.3, a - w * 0.9), P(tip, a)}
  local s1, s2 = math.cos(a + 1.2 - LIGHT_ANG), math.cos(a - 1.2 - LIGHT_ANG)
  local dark, lit = e1, e2
  if s1 > s2 then dark, lit = e2, e1 end
  bd:reload(DK, 0.6); bd:stroke(dark, {pressure={0.5, 0.3}})
  if v > -0.6 then bl:reload(v > 0.2 and R7 or Q5, 0.6); bl:stroke(lit, {pressure={0.25, 0.45, 0.1}}) end
end

--@ chunk 46
local mcx, mcy = 508, 320
local fmask = poly(FIG.mask, true):shrink(2.5)
local bt = brush{kind="round", width=2.6, point=0.3}
local bh = brush{kind="round", width=1.3, point=0.5}
local n = 0
for k = 3, 70 do
  local a = k * GA
  local x = mcx + 2.55 * math.sqrt(k) * math.cos(a)
  local y = mcy + 4.2 * math.sqrt(k) * math.sin(a)
  if fmask:at(x, y) > 0.5 then
    if n % 8 == 0 then bt:reload(Q2, 0.6); bh:reload(Q5, 0.5) end
    n = n + 1
    local s = 0.35 + 0.35 * math.sqrt(k / 70)
    bt:touch(x, y, {pressure=s})
    bh:touch(x - 0.6, y - 0.7, {pressure=0.25})
  end
end
print(n)
-- the eye: a dark socket at the heart of the spiral
local be = brush{kind="round", width=5, point=0.2}
be:reload(ND, 0.8); be:touch(mcx, mcy, {pressure=0.8})

--@ chunk 47
local mcx, mcy = 508, 320
local fmask = poly(FIG.mask, true):shrink(3)
local bt = brush{kind="round", width=3.8, point=0.2}
local SD = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5}}
local n = 0
for k = 3, 70 do
  local a = k * GA
  local x = mcx + 2.55 * math.sqrt(k) * math.cos(a)
  local y = mcy + 4.2 * math.sqrt(k) * math.sin(a)
  if fmask:at(x, y) > 0.5 then
    if n % 6 == 0 then bt:reload(SD, 0.7) end
    n = n + 1
    local s = 0.35 + 0.5 * math.sqrt(k / 70)
    bt:touch(x + 0.3, y + 0.4, {pressure=s})
  end
end
local be = brush{kind="round", width=7, point=0.2}
be:reload(ND, 0.9); be:touch(mcx, mcy, {pressure=0.9})

--@ chunk 48
FIG.palm = {{704,488},{742,490},{748,458},{746,432},{712,428},{702,452}}
local fingers = {
  {{716,434},{711,382}, 4.6, 3.4},
  {{726,432},{728,366}, 4.8, 3.6},
  {{736,434},{745,377}, 4.6, 3.4},
  {{745,442},{758,402}, 4.0, 3.0},
  {{707,464},{686,436}, 5.0, 3.8},
}
local hand = poly(FIG.palm, true)
for _, f in ipairs(fingers) do hand = hand + ribbon({f[1], f[2]}, {f[3] * 2, f[4] * 2}) end
local oldh = poly(FIG.hand, true):grow(4) - hand
work(oldh, {hand="detail", pile=BW2, coverage=3, fill=true, clip=oldh})
-- fingers first, palm over their roots
local PF = {base=Q3, lit=Q5, dark=Q2, hi=R7}
for _, f in ipairs(fingers) do tube(f[1], f[2], f[3], f[4], PF) end
local palm = poly(FIG.palm, true)
local fp = form{ {body.ellipsoid({724, 460, 10}, {24, 32, 10})}, light=LGT }
shade(palm, fp, {{0,0.4,Q2},{0.4,0.6,Q3},{0.6,0.8,Q4},{0.8,2,Q5}}, {tool="filbert 3", length={4, 10}, angle=math.pi/2})

--@ chunk 49
print(wait(6*24*60)); print(drying(450,900), drying(505,1000), drying(560,850), drying(724,460), drying(740,420), drying(450,1100))

--@ chunk 50
print(wait(4*24*60)); print(drying(450,900), drying(505,1000), drying(560,850), drying(724,460), drying(740,420), drying(450,1100))

--@ chunk 51
PS = {base=R1, lit=Q2, dark=DK, hi=Q3, refl=VD}
local n = 11
local order = {1, 11, 2, 10, 3, 9, 4, 8, 5, 7, 6}
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
for _, i in ipairs(order) do
  local s = (i - 1) / (n - 1)
  local xt = lerp(450, 560, s)
  local xb = lerp(360, 652, s) + 6 * math.sin(i * 2.1)
  local P = s < 0.35 and PL or s < 0.62 and {base=Q3, lit=Q4, dark=R1, hi=Q5, refl=VD} or s < 0.85 and PD or PS
  tube({xt, 756}, {xb, lens[i]}, 7, 15, P)
end

--@ chunk 52
-- neck: dark core with three bone rings
local neck = poly({{488,362},{520,362},{524,420},{484,420}}, true) - poly(FIG.helm, true)
work(neck, {hand="detail", pile=DK, coverage=3, fill=true, clip=neck})
local br = brush{kind="filbert", width=6}
local bh = brush{kind="round", width=1.6, point=0.6}
for i, y in ipairs({376, 391, 406}) do
  local w = 14 + i * 1.5
  br:reload(i == 2 and BN or BS, 0.7)
  br:stroke({{504 - w, y - 1}, {504, y + 2}, {504 + w, y - 1}}, {pressure={0.8, 0.8}, clip=neck})
  bh:reload(R7, 0.5)
  bh:stroke({{504 - w + 2, y - 3}, {500, y - 1}}, {pressure={0.3, 0.5}, clip=neck})
end
-- gorget: a crescent collar over the top of the chest
local top = {} ; local bot = {}
for i = 0, 16 do
  local s = i / 16
  local x = lerp(428, 584, s)
  top[#top+1] = {x, 424 + 10 * (1 - (2 * s - 1)^2) - 4}
  bot[#bot+1] = {x, 436 + 26 * (1 - (2 * s - 1)^2)}
end
local g = {} for _, p in ipairs(top) do g[#g+1] = p end for i = #bot, 1, -1 do g[#g+1] = bot[i] end
FIG.gorget = g
local gm = poly(g, true)
local fg = form{ {body.ellipsoid({506, 440, 30}, {82, 30, 40})}, light=LGT }
shade(gm, fg, METAL2, {tool="filbert 3", length={6, 14}, angle=0})

--@ chunk 53
function tube(T, B, w0, w1, P, opts)
  opts = opts or {}
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local nx, ny = uy, -ux
  if nx > 0 then nx, ny = -nx, -ny end
  if opts.flip then nx, ny = -nx, -ny end   -- lit from the right instead
  local function line(off, s0, s1)
    local t = {}
    for i = 0, 8 do
      local s = lerp(s0 or 0.02, s1 or 0.98, i / 8)
      local w = lerp(w0, w1, s)
      t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off}
    end
    return t
  end
  local outline = {}
  for _, p in ipairs(line(1, 0, 1)) do outline[#outline+1] = p end
  local back = line(-1, 0, 1)
  for i = #back, 1, -1 do outline[#outline+1] = back[i] end
  local m = poly(outline, true)
  if opts.cut then m = m - opts.cut end
  local wm = (w0 + w1)
  if not opts.nobase then
    work(m, {hand=opts.hand or "body", pile=P.base, coverage=opts.coverage or 3, fill=opts.fill ~= false, clip=m, load=opts.load,
      tool={kind="filbert", width=math.max(2, wm * 0.4)}, angle=math.atan(dy, dx), length={len * 0.3, len * 0.7}})
  end
  local b = brush{kind="filbert", width=math.max(1.5, wm * 0.35)}
  if P.lit then b:reload(P.lit, 0.8); b:stroke(line(0.45), {pressure={0.7, 0.6}, clip=m}) end
  if P.dark then b:reload(P.dark, 0.8); b:stroke(line(-0.4), {pressure={0.7, 0.7}, clip=m}) end
  local r = brush{kind="round", width=math.max(1.2, wm * 0.12), point=0.5}
  if P.hi then r:reload(P.hi, 0.7); r:stroke(line(0.62, 0.08, 0.85), {pressure={0.3, 0.8, 0.2}, clip=m}) end
  if P.refl then r:reload(P.refl, 0.6); r:stroke(line(-0.85, 0.15, 0.9), {pressure={0.3, 0.5, 0.2}, clip=m}) end
  return m
end

--@ chunk 54
CZ = pile{{"zinc white",3},{"cerulean blue",1}}
CM = pile{{"ultramarine ash",1},{"cobalt violet",1},{"zinc white",0.5},{"bone black",0.2}}
PG = {base=CM, lit=CC, dark=CV, hi=CZ}
-- ghost 1: the forearm swung out to the right, the hand open with one finger too many
tube({700, 600}, {776, 506}, 13, 11, PG, {flip=true})
local palm = poly({{764,512},{790,520},{808,500},{804,474},{780,466},{762,486}}, true)
work(palm, {hand="detail", pile=CM, coverage=3, fill=true, clip=palm})
local fing = {
  {{782,470},{790,428}, 4.2, 3.2}, {{792,472},{806,432}, 4.4, 3.2}, {{800,478},{822,446}, 4.2, 3.0},
  {{806,488},{834,468}, 4.0, 3.0}, {{807,498},{838,492}, 3.8, 2.8}, {{768,494},{748,468}, 4.6, 3.6},
}
for _, f in ipairs(fing) do tube(f[1], f[2], f[3], f[4], {base=CM, lit=CC, hi=CZ}, {flip=true}) end

--@ chunk 55
PG2 = {base=CV, lit=CM, dark=ND, hi=CZ}
tube({700, 600}, {776, 506}, 13, 11, PG2, {flip=true})
local palm = poly({{764,512},{790,520},{808,500},{804,474},{780,466},{762,486}}, true)
work(palm, {hand="detail", pile=CV, coverage=3, fill=true, clip=palm})
local fing = {
  {{782,470},{790,428}, 4.2, 3.2}, {{792,472},{806,432}, 4.4, 3.2}, {{800,478},{822,446}, 4.2, 3.0},
  {{806,488},{834,468}, 4.0, 3.0}, {{807,498},{838,492}, 3.8, 2.8}, {{768,494},{748,468}, 4.6, 3.6},
}
for _, f in ipairs(fing) do tube(f[1], f[2], f[3], f[4], {base=CV, hi=CZ}, {flip=true}) end
local r = brush{kind="round", width=1.6, point=0.7}
r:reload(CZ, 0.6)
r:stroke({{806,476},{810,500},{792,520},{770,516}}, {pressure={0.4, 0.6, 0.2}})

--@ chunk 56
print(wait(5*24*60)); print(drying(740,560), drying(790,490), drying(500,1000), drying(505,440), drying(504,391))

--@ chunk 57
-- niche floor between the hem and the sill: dark, warmer toward the right where some light lands
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
local floor = (poly(NICHE) * rect(180, 1150, 640, 84)) - robe
local fl = floor * rect(0, 0, 520, H)
local fr = floor * rect(520, 0, 500, H)
work(fl, {hand="body", pile=BW4, coverage=3, fill=true, clip=floor, angle=0, tool="filbert 6"})
work(fr, {hand="body", pile=BW2, coverage=3, fill=true, clip=floor, angle=0, tool="filbert 6"})
FIG.lsab = {{418,1156},{452,1154},{462,1176},{452,1194},{412,1204},{372,1208},{392,1194},{410,1178}}
FIG.rsab = {{566,1156},{598,1154},{614,1174},{642,1194},{666,1206},{626,1208},{590,1200},{570,1182}}

--@ chunk 58
local function sab(pts, lit)
  local m = poly(pts, true)
  local xs, ys = 0, 0
  for _, p in ipairs(pts) do xs = xs + p[1]; ys = ys + p[2] end
  local cx, cy = xs / #pts, ys / #pts
  local f = form{ {body.ellipsoid({cx, cy, 10}, {50, 24, 18})}, light=LGT }
  shade(m, f, lit and {{0,0.3,Q2},{0.3,0.5,Q3},{0.5,0.7,Q4},{0.7,2,Q5}} or {{0,0.35,R1},{0.35,0.55,Q2},{0.55,0.75,Q3},{0.75,2,Q4}}, {tool="filbert 3", length={5, 12}, angle=0})
  return m
end
local ml = sab(FIG.lsab, true)
local mr = sab(FIG.rsab, false)
-- lames across the feet and a lit edge along the instep
local bd = brush{kind="round", width=2.0, point=0.6}
local bl = brush{kind="round", width=1.6, point=0.7}
bd:reload(DK, 0.6)
bd:stroke({{446,1166},{430,1180},{414,1192}}, {pressure={0.5, 0.3}, clip=ml})
bd:stroke({{454,1182},{436,1192},{420,1199}}, {pressure={0.5, 0.3}, clip=ml})
bd:stroke({{580,1166},{600,1180},{618,1192}}, {pressure={0.5, 0.3}, clip=mr})
bd:stroke({{576,1182},{596,1192},{612,1199}}, {pressure={0.5, 0.3}, clip=mr})
bl:reload(R7, 0.6)
bl:stroke({{420,1160},{404,1182},{382,1203}}, {pressure={0.3, 0.6, 0.1}, clip=ml})
bl:reload(Q5, 0.6)
bl:stroke({{572,1162},{590,1186},{624,1203}}, {pressure={0.2, 0.4, 0.1}, clip=mr})
-- contact shadows under the soles
local bs = brush{kind="filbert", width=6}
bs:reload(ND, 0.7)
bs:stroke({{380,1210},{420,1208},{458,1200}}, {pressure={0.6, 0.5}})
bs:stroke({{572,1203},{620,1211},{676,1210}}, {pressure={0.6, 0.6}})

--@ chunk 59
-- sill nosing: a rounded lit edge
local nose = rect(0, SILL - 8, 1000, 16)
local fn = form{ {body.block({500, SILL, 0}, {1100, 16, 30}, 7)}, light=LGT }
work(nose, {hand="detail", pile=Q3, coverage=3, fill=true, clip=nose, angle=0})
local bl = brush{kind="filbert", width=4}
bl:reload(Q5, 0.8); bl:stroke({{0, SILL - 4}, {300, SILL - 4.5}, {600, SILL - 4}, {1000, SILL - 4.5}}, {pressure={0.6, 0.4}, clip=nose})
local bh = brush{kind="round", width=1.6, point=0.6}
bh:reload(R7, 0.6); bh:stroke({{0, SILL - 6}, {350, SILL - 6.3}, {620, SILL - 6}}, {pressure={0.6, 0.15}, clip=nose})
local bd = brush{kind="filbert", width=5}
bd:reload(DK, 0.8); bd:stroke({{0, SILL + 6}, {1000, SILL + 6}}, {pressure={0.6, 0.6}, clip=nose})
-- the inscription band on the step face
local band = rect(0, 1272, 1000, 30)
work(band, {hand="body", pile=BS, coverage=3, fill=true, clip=band, angle=0, tool="filbert 5"})
local bandl = rect(0, 1272, 560, 30)
work(bandl, {hand="scumble", pile=BN, coverage=1.2, clip=band})

--@ chunk 60
print(wait(6*24*60)); print(drying(740,560), drying(790,490), drying(500,1285), drying(420,1180), drying(650,1200))

--@ chunk 61
-- slice the cold arm: straight cuts of the wall's own colour, a bright seam on one lip of each cut
local ghostzone = poly({{690,610},{712,590},{790,500},{760,420},{850,420},{850,520},{790,540},{720,625}}, true)
local cuts = {
  {700, 560, 860, 470, 5.5},
  {690, 590, 860, 500, 3.5},
  {720, 530, 860, 452, 4.0},
}
local bc = brush{kind="round", width=2, point=0.6}
for _, c in ipairs(cuts) do
  local band = ribbon({{c[1], c[2]}, {c[3], c[4]}}, c[5]) * ghostzone
  work(band, {hand="detail", pile=BW2, coverage=3, fill=true, clip=band})
end

--@ chunk 62
WL = pile{{"raw sienna",2},{"bone brown",1.5},{"burnt sienna",0.5},{"lead white",0.6}}
local function tubemask(T, B, w0, w1) return ribbon({T, B}, {w0 * 2, w1 * 2}) end
GHOST1 = tubemask({700,600},{776,506},13,11) + poly({{764,512},{790,520},{808,500},{804,474},{780,466},{762,486}}, true)
for _, f in ipairs{{{782,470},{790,428},4.2,3.2},{{792,472},{806,432},4.4,3.2},{{800,478},{822,446},4.2,3.0},{{806,488},{834,468},4.0,3.0},{{807,498},{838,492},3.8,2.8},{{768,494},{748,468},4.6,3.6}} do
  GHOST1 = GHOST1 + tubemask(f[1], f[2], f[3], f[4])
end
local ghostzone = poly({{690,610},{712,590},{790,500},{760,420},{850,420},{850,520},{790,540},{720,625}}, true)
local cuts = {{700, 560, 860, 470, 5.5}, {690, 590, 860, 500, 3.5}, {720, 530, 860, 452, 4.0}}
local fix = nil
for _, c in ipairs(cuts) do
  local band = (ribbon({{c[1], c[2]}, {c[3], c[4]}}, c[5] + 2) * ghostzone) - GHOST1:grow(1)
  fix = fix and (fix + band) or band
end
fix = fix * poly(NICHE)
work(fix, {hand="detail", pile=WL, coverage=3, fill=true, clip=fix})
-- bright seams along one lip of each cut, only across the cold arm
local bc = brush{kind="round", width=1.4, point=0.6}
for _, c in ipairs(cuts) do
  local dx, dy = c[3] - c[1], c[4] - c[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local ox, oy = -dy / l * c[5] * 0.5, dx / l * c[5] * 0.5
  bc:reload(CZ, 0.5)
  bc:stroke({{c[1] + ox, c[2] + oy}, {c[3] + ox, c[4] + oy}}, {pressure={0.4, 0.4}, clip=GHOST1:grow(2)})
end

--@ chunk 63
local mould = poly(ARCH_OUT) - poly(NICHE)
local cuts = {{700, 560, 870, 465, 7.5}, {690, 590, 870, 495, 5.5}, {720, 530, 870, 446, 6.0}}
local fix
for _, c in ipairs(cuts) do
  local band = ribbon({{c[1], c[2]}, {c[3], c[4]}}, c[5]) * mould
  fix = fix and (fix + band) or band
end
local inner = fix * rect(818, 0, 22, H)
local outer = fix * rect(840, 0, 40, H)
work(inner, {hand="detail", pile=Q4, coverage=3, fill=true, clip=inner})
work(outer, {hand="detail", pile=Q3, coverage=3, fill=true, clip=outer})

--@ chunk 64
local cuts = {{700, 560, 860, 470, 5.5}, {690, 590, 860, 500, 3.5}, {720, 530, 860, 452, 4.0}}
local bd = brush{kind="round", width=4.5, point=0.5}
local bc = brush{kind="round", width=1.5, point=0.7}
for i, c in ipairs(cuts) do
  local dx, dy = c[3] - c[1], c[4] - c[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / l, dy / l
  local ox, oy = -uy, ux
  -- the cut as a line running past the arm and onto the arch, ending in a point
  local x0, y0 = c[1] + ux * 60, c[2] + uy * 60
  local x1, y1 = c[3] + ux * (12 + 8 * i), c[4] + uy * (12 + 8 * i)
  bd:reload(CV, 0.7)
  bd:stroke({{x0, y0}, {lerp(x0, x1, 0.5), lerp(y0, y1, 0.5)}, {x1, y1}}, {pressure={0.75, 0.75, 0.0}, ramps={0.05, 0.3}})
  bc:reload(CZ, 0.6)
  bc:stroke({{x0 + ox * c[5] * 0.5, y0 + oy * c[5] * 0.5}, {x1 + ox * c[5] * 0.5, y1 + oy * c[5] * 0.5}}, {pressure={0.5, 0.0}, ramps={0.05, 0.5}})
end

--@ chunk 65
print(wait(3*24*60)); for _, p in ipairs{{650,600},{700,900},{600,1000},{420,900},{505,600},{620,460},{505,1285},{650,1200},{740,560}} do io_ = drying(p[1],p[2]); print(p[1],p[2],io_) end

--@ chunk 66
GT = pile{{"bone brown",2},{"viridian",0.5},{"bone black",0.5}, medium=0.85}
GW = pile{{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.5}, medium=0.85}
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
FIGALL = figmask() + poly(FIG.mantle, true) + robe + poly(FIG.helm, true) + poly(FIG.gorget, true)
  + (ellipse(505, 285, 152, 152) - ellipse(505, 285, 116, 116)) + GHOST1 + poly(FIG.lsab, true) + poly(FIG.rsab, true)
  + ribbon(FIG.shaft, 14) + poly(FIG.blade, true)
local wallin = (poly(NICHE) * rect(0, 0, 1000, 1150)) - FIGALL:grow(2)
work(wallin, {hand="glaze", pile=GW, coverage=1.4, fill=true, clip=wallin})
blend(wallin, {angle=math.pi / 2})

--@ chunk 67
FIG.lancet = {{505,466},{519,502},{523,580},{516,648},{505,682},{494,648},{487,580},{491,502}}
FIG.tabin = {{500,772},{512,772},{514,900},{512,1056},{506,1098},{500,1056},{498,900}}
local lan = poly(FIG.lancet, true)
local fl = form{ {body.ellipsoid({505, 574, 30}, {20, 112, 10})}, light=LGT }
shade(lan, fl, {{0,0.4,BS2},{0.4,0.62,BS},{0.62,2,BN}}, {tool="filbert 3", length={6, 14}, angle=math.pi / 2})
local tin = poly(FIG.tabin, true)
local ft = form{ {body.ellipsoid({506, 935, 30}, {9, 170, 6})}, light=LGT }
shade(tin, ft, {{0,0.45,BS2},{0.45,0.65,BS},{0.65,2,BN}}, {tool="filbert 2", length={6, 14}, angle=math.pi / 2})
-- bone studs along the gorget, spaced by a shrinking golden ratio from the centre out
local bt = brush{kind="round", width=3.4, point=0.2}
local xs = {506}
local d = 13
for i = 1, 5 do xs[#xs+1] = 506 + d; xs[#xs+1] = 506 - d * 1.06; d = d + 13 / (1.618 ^ (i * 0.5)) end
for i, x in ipairs(xs) do
  local s = (x - 428) / (584 - 428)
  local y = 432 + 18 * (1 - (2 * s - 1)^2)
  if i % 4 == 1 then bt:reload(BN, 0.7) end
  bt:touch(x, y, {pressure=0.6})
end

--@ chunk 68
-- a Testator glyph: one or two small marks at (x, y), size s; kind chosen by k
function glyph(b, x, y, s, k)
  local t = k % 6
  if t == 0 then      -- a hook
    b:stroke({{x - s * 0.4, y - s * 0.5}, {x, y - s * 0.6}, {x + s * 0.3, y}, {x - s * 0.1, y + s * 0.4}}, {pressure={0.5, 0.2}})
  elseif t == 1 then  -- a bar and a dot
    b:stroke({{x - s * 0.5, y}, {x + s * 0.5, y - s * 0.1}}, {pressure={0.5, 0.4}})
    b:touch(x + s * 0.1, y + s * 0.45, {pressure=0.35})
  elseif t == 2 then  -- an open arc
    local p = {} for i = 0, 6 do local a = math.pi * (0.2 + 1.3 * i / 6); p[#p+1] = {x + s * 0.45 * math.cos(a), y + s * 0.45 * math.sin(a)} end
    b:stroke(p, {pressure={0.45, 0.3}})
  elseif t == 3 then  -- a small spiral
    local p = {} for i = 0, 10 do local a = i * 0.9; local r = s * 0.08 * i; p[#p+1] = {x + r * math.cos(a), y + r * math.sin(a)} end
    b:stroke(p, {pressure={0.2, 0.45}})
  elseif t == 4 then  -- a vertical tick with a cross-stroke
    b:stroke({{x, y - s * 0.5}, {x + s * 0.05, y + s * 0.5}}, {pressure={0.5, 0.3}})
    b:stroke({{x - s * 0.3, y - s * 0.1}, {x + s * 0.3, y - s * 0.2}}, {pressure={0.35, 0.3}})
  else                -- two dots
    b:touch(x - s * 0.2, y, {pressure=0.35}); b:touch(x + s * 0.25, y + s * 0.1, {pressure=0.35})
  end
end

--@ chunk 69
print(wait(3*24*60)); print(drying(505,580), drying(506,950), drying(300,1285), drying(650,600), drying(250,500))

--@ chunk 70
SD = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5}}
local b = brush{kind="round", width=1.9, point=0.6}
local x = 14
local i = 0
while x < 990 do
  if i % 7 == 0 then b:reload(SD, 0.6) end
  local frac = (i * 0.6180339) % 1
  glyph(b, x, 1287 + 2 * math.sin(i * 1.3), 9 + 2 * frac, (i * 7 + math.floor(frac * 11)) % 6)
  x = x + 11 + 7 * frac
  if frac > 0.86 then x = x + 14 end
  i = i + 1
end
print(i)

--@ chunk 71
local b = brush{kind="round", width=2.1, point=0.5}
local x = 20
local i = 0
while x < 990 do
  if i % 6 == 0 then b:reload(SD, 0.65) end
  local f1 = (i * 0.7548776) % 1
  local f2 = (i * 0.5698403) % 1
  glyph(b, x + 4, 1281 + 10 * f2, 6 + 4 * f1, math.floor(f1 * 6 + f2 * 5))
  x = x + 9 + 15 * f2
  i = i + 1
end

--@ chunk 72
print(wait(4*24*60)); print(drying(505,580), drying(506,950), drying(650,600), drying(250,500), drying(620,200))

--@ chunk 73
NDW = pile{{"bone black",1},{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local niche = poly(NICHE)
local lit = poly(sh(NICHE, 150, 120)) * niche
local keep = FIGALL:grow(1.5)
local dark = (niche - lit) * rect(0, 0, 1000, 1150) - keep
work(dark, {hand="body", pile=NDW, coverage=3, fill=true, clip=dark, angle=math.pi / 2, tool="filbert 7"})
-- the cast shadow on the lit back wall: the whole silhouette, robe and mantle included, but with the arm lowered
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
local dx, dy = 62, 44
local shadow = figmask2(dx, dy, true) + poly(sh(FIG.mantle, dx, dy), true) + poly(sh({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, dx, dy), true)
  + poly(sh(FIG.helm, dx, dy), true) + (ellipse(505 + dx, 285 + dy, 150, 150) - ellipse(505 + dx, 285 + dy, 118, 118))
shadow = (shadow * lit) * rect(0, 0, 1000, 1150) - keep
work(shadow, {hand="body", pile=BW4, coverage=3, fill=true, clip=shadow, angle=math.pi / 2, tool="filbert 6"})

--@ chunk 74
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
local tab = poly(FIG.tabard2, true)
local function gl(m, p, cov)
  work(m, {hand="glaze", pile=p, coverage=cov or 1.4, fill=true, clip=m})
  blend(m, {angle=math.pi / 2})
end
-- the far half of the robe and its hem sink into tarnish
local rr = (robe * mask(function(x, y) return (x > 512 + (y - 760) * 0.12) and 1 or 0 end)) - tab
gl(rr, GT, 1.5)
local hem = (robe * rect(0, 1060, 1000, 140)) - rr - tab
gl(hem, GT, 1.2)
-- the mantle's lit flank is too bright for something behind
local mant = (poly(FIG.mantle, true) - figmask() - robe) * rect(0, 0, 505, H)
gl(mant, GT, 1.5)
-- right pauldron and the far third of the chest plate
local rp = (ellipse(616, 452, 54, 38) + ellipse(622, 476, 58, 32) + ellipse(613, 498, 54, 26)) * rect(560, 0, 200, H)
gl(rp, GT, 1.2)
local ch = poly(FIG.chest, true) * rect(528, 0, 100, H) - poly(FIG.lancet, true)
gl(ch, GT, 1.2)

--@ chunk 75
print(wait(3*24*60)); print(drying(560,900), drying(470,1100), drying(300,700), drying(620,470))

--@ chunk 76
print(wait(5*24*60)); print(drying(560,900), drying(470,1100), drying(300,700), drying(620,470))

--@ chunk 77
G5 = pile{{"bone black",1},{"bone brown",1.5},{"viridian",0.3}, medium=0.75}
local fig = FIGALL - GHOST1:grow(3)
local function d(x, y) return math.sqrt(((x - 470) / 1.0)^2 + ((y - 380) / 1.6)^2) end
local zA = fig * mask(function(x, y) return d(x, y) > 430 and 1 or 0 end):roughen(12, 40, 21)
local zB = fig * mask(function(x, y) local v = d(x, y); return (v > 300 and v <= 430) and 1 or 0 end):roughen(12, 40, 22)
work(zA, {hand="glaze", pile=G5, coverage=1.4, fill=true, clip=zA})
blend(zA, {angle=math.pi / 2})
work(zB, {hand="glaze", pile=GT, coverage=1.3, fill=true, clip=zB})
blend(zB, {angle=math.pi / 2})

--@ chunk 78
print(wait(6*24*60)); print(drying(560,900), drying(470,1100), drying(300,700), drying(620,470))

--@ chunk 79
-- tube with the light falling off along its length: lit/hi strokes reach only to 'reach' (0..1)
function tube2(T, B, w0, w1, P, opts)
  opts = opts or {}
  local reach = opts.reach or 1
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local nx, ny = uy, -ux
  if nx > 0 then nx, ny = -nx, -ny end
  if opts.flip then nx, ny = -nx, -ny end
  local function line(off, s0, s1)
    local t = {}
    for i = 0, 8 do
      local s = lerp(s0, s1, i / 8)
      local w = lerp(w0, w1, s)
      t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off}
    end
    return t
  end
  local outline = {}
  for _, p in ipairs(line(1, 0, 1)) do outline[#outline+1] = p end
  local back = line(-1, 0, 1)
  for i = #back, 1, -1 do outline[#outline+1] = back[i] end
  local m = poly(outline, true)
  if opts.cut then m = m - opts.cut end
  local wm = w0 + w1
  -- base in two halves: upper in P.base, lower in P.low
  local up = m * mask(function(x, y) return (((x - T[1]) * ux + (y - T[2]) * uy) / len < reach * 0.85) and 1 or 0 end)
  work(m - up, {hand="body", pile=P.low or P.base, coverage=3, fill=true, clip=m, tool={kind="filbert", width=math.max(2, wm * 0.4)}, angle=math.atan(dy, dx), length={len * 0.2, len * 0.4}})
  work(up, {hand="body", pile=P.base, coverage=3, fill=true, clip=m, tool={kind="filbert", width=math.max(2, wm * 0.4)}, angle=math.atan(dy, dx), length={len * 0.2, len * 0.4}})
  local b = brush{kind="filbert", width=math.max(1.5, wm * 0.35)}
  if P.dark then b:reload(P.dark, 0.8); b:stroke(line(-0.4, 0.02, 0.98), {pressure={0.7, 0.7}, clip=m}) end
  if P.lit then b:reload(P.lit, 0.8); b:stroke(line(0.45, 0.02, reach), {pressure={0.7, 0.3}, ramps={0.1, 0.6}, clip=m}) end
  local r = brush{kind="round", width=math.max(1.2, wm * 0.12), point=0.5}
  if P.hi then r:reload(P.hi, 0.7); r:stroke(line(0.62, 0.06, reach * 0.8), {pressure={0.3, 0.8, 0.0}, clip=m}) end
  if P.refl then r:reload(P.refl, 0.6); r:stroke(line(-0.85, 0.3, 0.95), {pressure={0.2, 0.5, 0.2}, clip=m}) end
  return m
end

--@ chunk 80
local n = 11
local order = {1, 11, 2, 10, 3, 9, 4, 8, 5, 7, 6}
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
for _, i in ipairs(order) do
  local s = (i - 1) / (n - 1)
  local xt = lerp(450, 560, s)
  local xb = lerp(360, 652, s) + 6 * math.sin(i * 2.1)
  local P
  if s < 0.35 then P = {base=Q3, low=Q2, lit=Q5, dark=R1, hi=R7, refl=VD}
  elseif s < 0.62 then P = {base=Q3, low=Q2, lit=Q4, dark=R1, hi=Q5, refl=VD}
  elseif s < 0.85 then P = {base=Q2, low=R1, lit=Q3, dark=DK, hi=Q4, refl=VD}
  else P = {base=R1, low=DK, lit=Q2, dark=DK, hi=Q3, refl=VD} end
  tube2({xt, 756}, {xb, lens[i]}, 7, 15, P, {reach=0.55 - 0.2 * s + 0.05 * math.sin(i)})
end

--@ chunk 81
print(wait(4*24*60)); print(drying(560,900), drying(470,1100), drying(600,1000), drying(500,800))

--@ chunk 82
local n = 11
local b = brush{kind="round", width=4.5, point=0.4}
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
local function lame(i)
  local s = (i - 1) / (n - 1)
  return {lerp(450, 560, s), 756}, {lerp(360, 652, s) + 6 * math.sin(i * 2.1), lens[i]}
end
for i = 1, n - 1 do
  local T1, B1 = lame(i)
  local T2, B2 = lame(i + 1)
  local T = {(T1[1] + T2[1]) / 2, 790}
  local B = {(B1[1] + B2[1]) / 2, math.min(B1[2], B2[2]) - 6}
  b:reload(NDW, 0.9)
  local pts = {}
  for k = 0, 6 do local s = k / 6; pts[#pts+1] = {lerp(T[1], B[1], s), lerp(T[2], B[2], s)} end
  b:stroke(pts, {pressure={0.15, 0.85}, ramps={0.4, 0.05}})
end

--@ chunk 83
print(wait(5*24*60)); print(drying(560,900), drying(470,1100), drying(600,1000), drying(500,800))

--@ chunk 84
GW2 = pile{{"bone brown",2},{"burnt sienna",1},{"bone black",0.4}, medium=0.75}
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
local robeL = robe * mask(function(x, y) return (x < 505 + (y - 756) * 0.2) and 1 or 0 end)
local robeR = robe - robeL
local function ld(lo, hi) return function(x, y) return lerp(lo, hi, clamp((y - 820) / 330, 0, 1)) end end
work(robeR, {hand="glaze", pile=GW2, coverage=1.6, fill=true, clip=robeR, load_at=ld(0.4, 0.9)})
blend(robeR, {angle=0})
local low = robeL * rect(0, 900, 1000, 300)
work(low, {hand="glaze", pile=G5, coverage=1.5, fill=true, clip=low, load_at=ld(0.05, 0.9)})
blend(low, {angle=0})

--@ chunk 85
print(wait(7*24*60)); print(drying(560,900), drying(470,1100), drying(600,1000), drying(500,800), drying(380,700))

--@ chunk 86
-- opaque lame: dark whole, mid top, light stroke + highlight on the top part, junction blended along the lame
function lame3(T, B, w0, w1, P, reach)
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / len, dy / len
  local nx, ny = uy, -ux
  if nx > 0 then nx, ny = -nx, -ny end
  local function line(off, s0, s1)
    local t = {}
    for i = 0, 10 do
      local s = lerp(s0, s1, i / 10)
      local w = lerp(w0, w1, s)
      t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off}
    end
    return t
  end
  local outline = {}
  for _, p in ipairs(line(1, 0, 1)) do outline[#outline+1] = p end
  local back = line(-1, 0, 1)
  for i = #back, 1, -1 do outline[#outline+1] = back[i] end
  local m = poly(outline, true)
  local function along(s0, s1) return m * mask(function(x, y) local s = ((x - T[1]) * ux + (y - T[2]) * uy) / len; return (s >= s0 and s < s1) and 1 or 0 end) end
  local tool = {kind="filbert", width=math.max(3, (w0 + w1) * 0.45)}
  local ang = math.atan(dy, dx)
  work(m, {hand="body", pile=P.low, coverage=3, fill=true, clip=m, tool=tool, angle=ang, length={20, 50}})
  work(along(0, reach), {hand="body", pile=P.base, coverage=3, fill=true, clip=m, tool=tool, angle=ang, length={15, 40}})
  blend(along(reach - 0.12, reach + 0.12), {angle=ang, tool={kind="badger", width=10}})
  local b = brush{kind="filbert", width=math.max(1.5, (w0 + w1) * 0.32)}
  b:reload(P.dark, 0.8); b:stroke(line(-0.45, 0.02, 0.97), {pressure={0.7, 0.8}, clip=m})
  b:reload(P.lit, 0.8); b:stroke(line(0.4, 0.02, reach * 0.95), {pressure={0.7, 0.2}, ramps={0.1, 0.7}, clip=m})
  local r = brush{kind="round", width=math.max(1.2, (w0 + w1) * 0.11), point=0.5}
  r:reload(P.hi, 0.7); r:stroke(line(0.6, 0.05, reach * 0.75), {pressure={0.35, 0.8, 0.0}, clip=m})
  if P.refl then r:reload(P.refl, 0.5); r:stroke(line(-0.82, 0.35, 0.95), {pressure={0.15, 0.45, 0.1}, clip=m}) end
  return m
end

--@ chunk 87
local n = 11
local order = {1, 11, 2, 10, 3, 9, 4, 8, 5, 7, 6}
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
local all
for _, i in ipairs(order) do
  local s = (i - 1) / (n - 1)
  local xt = lerp(450, 560, s)
  local xb = lerp(360, 652, s) + 6 * math.sin(i * 2.1)
  local P
  if s < 0.3 then P = {base=Q3, low=R1, lit=Q5, dark=NDW, hi=R7, refl=VD}
  elseif s < 0.6 then P = {base=Q3, low=R1, lit=Q4, dark=NDW, hi=Q5, refl=VD}
  elseif s < 0.85 then P = {base=Q2, low=NDW, lit=Q3, dark=ND, hi=Q4, refl=VD}
  else P = {base=R1, low=NDW, lit=Q2, dark=ND, hi=Q3, refl=VD} end
  local m = lame3({xt, 756}, {xb, lens[i]}, 7, 15, P, 0.5 - 0.22 * s + 0.05 * math.sin(i * 1.7))
  all = all and (all + m) or m
end
ROBE = all

--@ chunk 88
local Lx, Ly, Lz = -0.62, -0.52, 0.58
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
local function tv(x, y)
  local ox, oy, t
  if y < NICHE_SPRING then
    local dx, dy = x - NICHE_CX, y - NICHE_SPRING
    local r = math.sqrt(dx * dx + dy * dy)
    ox, oy = dx / r, dy / r
    t = (r - 320) / 48
  elseif x < 500 then ox, oy = -1, 0; t = (180 - x) / 48
  else ox, oy = 1, 0; t = (x - 820) / 48 end
  local phi = (t - 0.5) * math.pi * 0.95
  local nx, ny, nz = ox * math.sin(phi), oy * math.sin(phi), math.cos(phi)
  local f = clamp(1.2 - (dl(x, y) - 450) / 900, 0.3, 1)
  return math.max(0, nx * Lx + ny * Ly + nz * Lz) * f
end
local mould = poly(ARCH_OUT) - poly(NICHE)
mould = mould - (poly(FIG.blade, true) + ribbon(FIG.shaft, 12)):grow(2) - rect(800, 425, 80, 100)
local steps = {{-1,0.12,R1},{0.12,0.25,Q2},{0.25,0.4,Q3},{0.4,0.55,Q4},{0.55,0.72,Q5},{0.72,2,R6}}
for _, st in ipairs(steps) do
  local bm = mould * mask(function(x, y) local v = tv(x, y); return (v >= st[1] and v < st[2]) and 1 or 0 end)
  if bm:area() > 1 then
    work(bm, {hand="body", pile=st[3], coverage=3, fill=true, clip=mould, tool="filbert 4", length={8, 20},
      angle=function(x, y) if y < NICHE_SPRING then return math.atan(y - NICHE_SPRING, x - NICHE_CX) + math.pi/2 else return math.pi/2 end end})
  end
end
-- soften band junctions along the moulding
blend(mould, {angle=function(x, y) if y < NICHE_SPRING then return math.atan(y - NICHE_SPRING, x - NICHE_CX) + math.pi/2 else return math.pi/2 end end, tool={kind="badger", width=10}})

--@ chunk 89
local Lx, Ly, Lz = -0.62, -0.52, 0.58
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
local function tv(x, y)
  local t = (x - 820) / 48
  local phi = (t - 0.5) * math.pi * 0.95
  local nx, nz = math.sin(phi), math.cos(phi)
  local f = clamp(1.2 - (dl(x, y) - 450) / 900, 0.3, 1)
  return math.max(0, nx * Lx + nz * Lz) * f
end
local mould = poly(ARCH_OUT) - poly(NICHE)
local r = mould * rect(800, 425, 80, 100)
local steps = {{-1,0.12,R1},{0.12,0.25,Q2},{0.25,0.4,Q3},{0.4,0.55,Q4}}
for _, st in ipairs(steps) do
  local bm = r * mask(function(x, y) local v = tv(x, y); return (v >= st[1] and v < st[2]) and 1 or 0 end)
  if bm:area() > 1 then work(bm, {hand="body", pile=st[3], coverage=3, fill=true, clip=r, tool="filbert 4", length={8, 20}, angle=math.pi/2}) end
end
blend(mould * rect(800, 405, 80, 140), {angle=math.pi/2, tool={kind="badger", width=10}})

--@ chunk 90
print(wait(6*24*60)); print(drying(560,900), drying(470,1100), drying(840,450), drying(150,600), drying(380,700))

--@ chunk 91
local mant = (poly(FIG.mantle, true) - figmask() - ROBE:grow(1)) * rect(0, 0, 505, H)
mant = mant - ribbon(FIG.shaft, 13)
work(mant, {hand="body", pile=R1, coverage=3, fill=true, clip=mant, angle=math.pi/2, length={20, 50}})
local bc = brush{kind="filbert", width=8}
local bv = brush{kind="filbert", width=6}
local function line(x0, y0, x1, y1, s0, s1) local t = {} for i = 0, 10 do local s = lerp(s0 or 0, s1 or 1, i / 10); t[#t+1] = {lerp(x0, x1, s) + 2.5 * math.sin(s * 6 + x0), lerp(y0, y1, s)} end return t end
local crests = {{388, 500, 340, 1150, Q3}, {372, 600, 318, 1120, Q2}, {412, 610, 385, 1160, Q2}, {358, 700, 330, 1140, Q2}}
local valleys = {{398, 540, 355, 1150}, {380, 650, 324, 1140}, {425, 650, 405, 1165}}
for _, v in ipairs(valleys) do bv:reload(NDW, 0.8); bv:stroke(line(v[1], v[2], v[3], v[4]), {pressure={0.6, 0.9}, clip=mant}) end
for _, c in ipairs(crests) do bc:reload(c[5], 0.8); bc:stroke(line(c[1], c[2], c[3], c[4], 0, 0.6), {pressure={0.55, 0.1}, ramps={0.1, 0.6}, clip=mant}) end
-- a lit rim down the mantle's outer edge, nearest the light, fading
local br = brush{kind="round", width=2.4, point=0.6}
br:reload(Q4, 0.7)
br:stroke({{373,530},{360,640},{350,760},{340,880}}, {pressure={0.6, 0.0}, clip=mant:grow(1)})

--@ chunk 92
local function foot(pts, base, lit, hi, top)
  local m = poly(pts, true) - ROBE
  work(m, {hand="detail", pile=base, coverage=3, fill=true, clip=m, angle=0.3})
  local b = brush{kind="filbert", width=5}
  b:reload(lit, 0.8); b:stroke(top, {pressure={0.7, 0.4}, clip=m})
  local r = brush{kind="round", width=1.6, point=0.6}
  r:reload(hi, 0.7); r:stroke(top, {pressure={0.4, 0.6, 0.0}, clip=m})
  local d = brush{kind="round", width=2.0, point=0.6}
  return m
end
local ml = foot(FIG.lsab, R1, Q3, Q5, {{430,1165},{410,1180},{385,1199}})
local mr = foot(FIG.rsab, NDW, Q2, Q3, {{586,1166},{612,1182},{650,1200}})
-- contact shadow
local bs = brush{kind="filbert", width=7}
bs:reload(ND, 0.8)
bs:stroke({{368,1210},{420,1209},{466,1200}}, {pressure={0.7, 0.5}})
bs:stroke({{566,1205},{620,1212},{676,1211}}, {pressure={0.7, 0.6}})

--@ chunk 93
HG1 = pile{{"zinc white",2},{"ultramarine ash",1},{"bone black",0.3}}
HG2 = pile{{"bone black",1},{"zinc white",1.5},{"ultramarine ash",1}}
HG3 = pile{{"bone black",1},{"ultramarine ash",0.5},{"bone brown",0.5}}
AMB = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.3}}
AMBD = pile{{"Mars orange",1},{"burnt sienna",0.7},{"bone brown",0.3}}
local cx, cy = 742, 1194
-- its shadow on the floor first, thrown down-right
local shp = poly({{722,1214},{770,1206},{806,1214},{812,1226},{780,1234},{730,1232}}, true)
work(shp, {hand="detail", pile=BW4, coverage=3, fill=true, clip=shp})
local dome = ellipse(cx, cy, 36, 27)
local f = form{ {body.ellipsoid({cx, cy, 0}, {36, 27, 30})}, light=LGT }
shade(dome, f, {{0,0.3,HG3},{0.3,0.5,HG2},{0.5,0.72,HG1},{0.72,2,CZ}}, {tool="filbert 3", length={5, 12}, angle=0.4})
-- the visor: a dark glossy lens on the face turned toward us and down
local vis = ellipse(cx + 12, cy + 7, 20, 13) * dome:grow(1)
work(vis, {hand="detail", pile=ND, coverage=3, fill=true, clip=vis})

--@ chunk 94
local cx, cy = 742, 1194
local dome = ellipse(cx, cy, 36, 27)
-- the amber hazard band around the crown, foreshortened
local band = ribbon({{cx - 30, cy - 4}, {cx - 18, cy - 17}, {cx - 2, cy - 24}, {cx + 14, cy - 22}}, {7, 8, 8, 7}) * dome
work(band, {hand="detail", pile=AMB, coverage=3, fill=true, clip=band})
local bd = ribbon({{cx - 26, cy + 3}, {cx - 14, cy - 9}}, 7) * dome
work(bd, {hand="detail", pile=AMBD, coverage=3, fill=true, clip=bd})
-- neck opening: a dark ring at the lower right
local neck = ellipse(cx + 27, cy + 10, 10, 15) * dome:grow(2)
work(neck, {hand="detail", pile=ND, coverage=3, fill=true, clip=neck})
-- dull the cold light gray toward a dimmer gray
local top = dome * ellipse(cx - 12, cy - 10, 24, 14) - band
work(top, {hand="scumble", pile=HG2, coverage=0.8, clip=top})
-- a crack across the visor, catching light
local r = brush{kind="round", width=1.2, point=0.8}
r:reload(HG1, 0.5)
r:stroke({{cx + 2, cy + 2}, {cx + 9, cy + 8}, {cx + 7, cy + 13}, {cx + 15, cy + 18}}, {pressure={0.5, 0.2}})
r:reload(CZ, 0.5)
r:stroke({{cx + 22, cy - 2}, {cx + 26, cy + 3}}, {pressure={0.4, 0.1}})

--@ chunk 95
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local D = 16
local band = rect(430, 309, 160, 15)
local helm = poly(FIG.helm, true)
local helm2 = poly(sh(FIG.helm, D, 0), true)
local disc = poly(FIG.mask, true)
local disc2 = poly(sh(FIG.mask, D, 0), true)
local vac = band * (helm - helm2)
local ext = band * (helm2 - helm)
local d2 = band * disc2
local dold = band * (disc - disc2)
work(vac, {hand="detail", pile=NDW, coverage=3, fill=true, clip=vac})
work(ext, {hand="detail", pile=Q2, coverage=3, fill=true, clip=ext})
work(dold * helm2, {hand="detail", pile=Q3, coverage=3, fill=true, clip=dold * helm2})
work(d2, {hand="detail", pile=BS, coverage=3, fill=true, clip=d2})
local d2l = d2 * rect(0, 0, 515, H)
work(d2l, {hand="detail", pile=BN, coverage=3, fill=true, clip=d2l})

--@ chunk 96
local D = 16
local band = rect(430, 309, 160, 15)
local vac = band * (poly(FIG.helm, true) - poly((function() local u = {} for i, p in ipairs(FIG.helm) do u[i] = {p[1] + D, p[2]} end return u end)(), true))
work(vac, {hand="detail", pile=ND, coverage=3, fill=true, clip=vac})
-- studs carried with the slice
local disc2 = band * poly((function() local u = {} for i, p in ipairs(FIG.mask) do u[i] = {p[1] + D, p[2]} end return u end)(), true):shrink(2)
local bt = brush{kind="round", width=3.8, point=0.2}
bt:reload(SD, 0.7)
for k = 3, 70 do
  local a = k * GA
  local x = 508 + 2.55 * math.sqrt(k) * math.cos(a) + D
  local y = 320 + 4.2 * math.sqrt(k) * math.sin(a)
  if disc2:at(x, y) > 0.5 then bt:touch(x + 0.3, y + 0.4, {pressure=0.35 + 0.5 * math.sqrt(k / 70)}) end
end
local be = brush{kind="round", width=7, point=0.2}
be:reload(ND, 0.9); be:touch(508 + D, 318, {pressure=0.9})
-- petal edges carried with the slice on the right
local bd = brush{kind="round", width=2, point=0.6}
bd:reload(DK, 0.6)
bd:stroke({{556, 310}, {560, 323}}, {pressure={0.5, 0.5}})
bd:stroke({{548, 310}, {546, 323}}, {pressure={0.4, 0.4}})

--@ chunk 97
local cx, cy = 541, 255
local a0, a1 = math.rad(301), math.rad(350)
local frag = poly(sector(cx, cy, 116, 150, a0, a1, 20))
work(frag, {hand="detail", pile=Q2, coverage=3, fill=true, clip=frag, angle=math.rad(325) + math.pi / 2})
local ch = poly(sector(cx, cy, 125, 141, a0 + 0.01, a1 - 0.01, 20))
work(ch, {hand="detail", pile=R1, coverage=3, fill=true, clip=ch})
local bo = brush{kind="filbert", width=6}
bo:reload(NDW, 0.8); bo:stroke(arcpts(cx, cy, 146, a0 + 0.01, a1 - 0.01, 10), {pressure={0.7, 0.7}, clip=frag})
local bi = brush{kind="filbert", width=5}
bi:reload(CM, 0.8); bi:stroke(arcpts(cx, cy, 121, a0 + 0.01, a1 - 0.01, 10), {pressure={0.7, 0.7}, clip=frag})
local r = brush{kind="round", width=1.5, point=0.7}
r:reload(CZ, 0.6); r:stroke(arcpts(cx, cy, 118, a0 + 0.03, a1 - 0.03, 10), {pressure={0.3, 0.6, 0.2}, clip=frag:grow(1)})
-- the cut ends: cold faces
local function endface(a, w)
  local p1 = {cx + 116 * math.cos(a), cy + 116 * math.sin(a)}
  local p2 = {cx + 150 * math.cos(a), cy + 150 * math.sin(a)}
  r:reload(CZ, 0.6); r:stroke({p1, p2}, {pressure={0.6, 0.6}})
end
endface(a0 + 0.004); endface(a1 - 0.004)

--@ chunk 98
CG = pile{{"ultramarine ash",1},{"bone black",0.4},{"zinc white",0.5},{"bone brown",0.4}}
work(GHOST1, {hand="detail", pile=CG, coverage=2.5, fill=true, clip=GHOST1})

--@ chunk 99
local PGx = {lit=CZ, dark=CV, hi=CZ}
tube({700, 600}, {776, 506}, 13, 11, PGx, {flip=true, nobase=true})
for _, f in ipairs{{{782,470},{790,428},4.2,3.2},{{792,472},{806,432},4.4,3.2},{{800,478},{822,446},4.2,3.0},{{806,488},{834,468},4.0,3.0},{{807,498},{838,492},3.8,2.8},{{768,494},{748,468},4.6,3.6}} do
  tube(f[1], f[2], f[3], f[4], {dark=CV, hi=CZ}, {flip=true, nobase=true})
end
local palm = poly({{764,512},{790,520},{808,500},{804,474},{780,466},{762,486}}, true)
local b = brush{kind="filbert", width=8}
b:reload(CV, 0.7); b:stroke({{768,492},{772,510},{786,518}}, {pressure={0.6, 0.6}, clip=palm})
b:reload(CZ, 0.6); b:stroke({{800,476},{806,494},{796,512}}, {pressure={0.5, 0.5}, clip=palm})

--@ chunk 100
print(wait(30*60)); print(drying(520,316), drying(740,560), drying(600,200), drying(742,1194))

--@ chunk 101
local D = 16
-- the eye and seeds carried with the slice, on the set bone
local disc2 = rect(430, 310, 160, 13) * poly((function() local u = {} for i, p in ipairs(FIG.mask) do u[i] = {p[1] + D, p[2]} end return u end)(), true):shrink(2)
local bt = brush{kind="round", width=3.8, point=0.2}
bt:reload(SD, 0.7)
for k = 3, 70 do
  local a = k * GA
  local x = 508 + 2.55 * math.sqrt(k) * math.cos(a) + D
  local y = 320 + 4.2 * math.sqrt(k) * math.sin(a)
  if disc2:at(x, y) > 0.5 then bt:touch(x + 0.3, y + 0.4, {pressure=0.35 + 0.5 * math.sqrt(k / 70)}) end
end
local be = brush{kind="round", width=7, point=0.2}
be:reload(ND, 0.9); be:touch(508 + D, 318, {pressure=0.9})
-- petal divisions in the shifted strip
local bd = brush{kind="round", width=1.8, point=0.6}
bd:reload(DK, 0.6)
for _, x in ipairs{482, 492, 553, 561} do bd:stroke({{x, 310}, {x + 1, 323}}, {pressure={0.45, 0.45}}) end
-- the cold seams: hairlines at the slice's top and bottom, running past the head on both sides
local bc = brush{kind="round", width=1.4, point=0.7}
bc:reload(CZ, 0.6)
bc:stroke({{446, 309}, {505, 309.3}, {578, 309}}, {pressure={0.05, 0.55, 0.05}, ramps={0.3, 0.3}})
bc:stroke({{452, 324}, {512, 323.7}, {586, 324}}, {pressure={0.05, 0.5, 0.05}, ramps={0.3, 0.3}})

--@ chunk 102
local H = {{742,590},{770,520},{760,486},{748,468},{752,464},{770,488},{780,466},{786,428},{792,428},{792,470},{800,432},{808,434},{800,474},{818,446},{824,448},{808,484},{832,466},{836,470},{810,492},{838,490},{838,496},{808,506},{792,522},{776,606}}
local function echo(dx, dy, pr, seed)
  local pts = {}
  for _, p in ipairs(H) do pts[#pts+1] = {p[1] + dx, p[2] + dy} end
  local o = outline{pts=pts, char="searching", seed=seed, amount=0.6}
  local b = brush{kind="round", width=1.6, point=0.8}
  o:paint(b, {pressure=pr, dip={CZ, 0.5}, every=4})
end
echo(26, -22, 0.35, 5)
echo(50, -40, 0.22, 6)

--@ chunk 103
print(wait(20*60)); print(drying(800,440), drying(780,560), drying(850,450), drying(890,420))

--@ chunk 104
local region = poly({{760,520},{790,470},{790,400},{830,370},{900,380},{905,470},{870,560},{820,640},{770,640}}, true)
local keep
local slope = (470 - 560) / (860 - 700)
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 9)
  keep = keep and (keep + b) or b
end
local cover = region - keep - GHOST1:grow(2) - figmask():grow(2)
local niche = poly(NICHE)
local mould = poly(ARCH_OUT) - niche
local c1 = cover * niche
local c2 = cover * mould * rect(0, 0, 845, H)
local c3 = cover * mould * rect(845, 0, 200, H)
local c4 = cover - niche - mould
work(c1, {hand="detail", pile=WL, coverage=3, fill=true, clip=c1, angle=math.pi / 2 + 0.2})
work(c2, {hand="detail", pile=Q3, coverage=3, fill=true, clip=c2, angle=math.pi / 2})
work(c3, {hand="detail", pile=Q2, coverage=3, fill=true, clip=c3, angle=math.pi / 2})
work(c4, {hand="detail", pile=R1, coverage=3, fill=true, clip=c4, angle=math.pi / 2})

--@ chunk 105
print(wait(24*60)); print(drying(800,560), drying(830,600), drying(860,450))

--@ chunk 106
print(wait(3*24*60)); print(drying(800,560), drying(830,600), drying(860,450), drying(890,600))

--@ chunk 107
print(wait(4*24*60)); print(drying(800,560), drying(830,600), drying(860,450), drying(890,600))

--@ chunk 108
WD2 = pile{{"bone brown",2},{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.3}}
local region = poly({{760,520},{790,470},{790,400},{830,370},{900,380},{905,470},{870,560},{820,640},{770,640}}, true)
local keep
local slope = (470 - 560) / (860 - 700)
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 9)
  keep = keep and (keep + b) or b
end
local cover = region - keep - GHOST1:grow(2) - figmask():grow(2)
local niche = poly(NICHE)
local mould = poly(ARCH_OUT) - niche
local c1 = (cover * niche):grow(1.5) * niche - GHOST1:grow(1) - figmask():grow(1) - keep
local c2 = cover * mould * rect(0, 0, 845, H)
local c3 = cover * mould * rect(845, 0, 200, H)
work(c1, {hand="detail", pile=WD2, coverage=3, fill=true, clip=c1, angle=math.pi / 2 + 0.2})
work(c2, {hand="detail", pile=Q2, coverage=3, fill=true, clip=c2, angle=math.pi / 2})
work(c3, {hand="detail", pile=NDW, coverage=3, fill=true, clip=c3, angle=math.pi / 2})

--@ chunk 109
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local niche = poly(NICHE)
local region = poly({{740,500},{780,420},{800,380},{822,370},{822,700},{780,700},{740,660}}, true) * niche
local slope = (470 - 560) / (860 - 700)
local keep
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 11)
  keep = keep and (keep + b) or b
end
local m = region - keep - GHOST1:grow(3) - figmask():grow(3)
work(m, {hand="scumble", pile=BW2, coverage=0.9, clip=m, angle=math.pi / 2 + 0.2})
work(m, {hand="scumble", pile=WD2, coverage=0.7, clip=m, angle=math.pi / 2 + 0.2})

--@ chunk 110
print(drying(400,1000), drying(600,1000), drying(396,490), drying(505,140))

--@ chunk 111
VG2 = pile{{"viridian",1},{"cerulean blue",0.6},{"lead white",1},{"yellow ochre",0.6},{"bone brown",0.3}}
-- robe seams (lower two thirds)
local n = 11
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
local function lame(i) local s = (i - 1) / (n - 1); return {lerp(450, 560, s), 756}, {lerp(360, 652, s) + 6 * math.sin(i * 2.1), lens[i]} end
local seams
for i = 1, n - 1 do
  local T1, B1 = lame(i); local T2, B2 = lame(i + 1)
  local T = {(T1[1] + T2[1]) / 2, 790}; local B = {(B1[1] + B2[1]) / 2, math.min(B1[2], B2[2]) - 6}
  local P = {lerp(T[1], B[1], 0.35), lerp(T[2], B[2], 0.35)}
  local r = ribbon({P, B}, {2, 7})
  seams = seams and (seams + r) or r
end
stipple(seams, {pile=VG2, width=2.2, coverage=0.7, cluster=0.5, feather=0.5})
-- under the pauldron lames and in the cage
local pl = (ellipse(398, 470, 58, 40):rim(4) + ellipse(392, 494, 58, 30):rim(4)) * rect(330, 470, 140, 60)
local pr = (ellipse(616, 470, 58, 40):rim(4) + ellipse(622, 494, 58, 30):rim(4)) * rect(560, 470, 140, 60)
stipple(pl + pr, {pile=VG2, width=2.0, coverage=0.6, cluster=0.6, feather=0.5})
-- the face: verdigris where the petals meet the bone disc, heavier below (tears)
local rim = poly(FIG.mask, true):grow(4) - poly(FIG.mask, true)
stipple(rim * rect(0, 300, 1000, 100), {pile=VG2, width=2.0, coverage=0.8, cluster=0.5})
local tears = ribbon({{494, 356}, {492, 380}, {490, 404}}, {4, 3, 1}) + ribbon({{520, 354}, {523, 372}}, {4, 1})
stipple(tears, {pile=VG2, width=2.0, coverage=1.0, cluster=0.3, drag={3, math.pi / 2}})

--@ chunk 112
local pl = (ellipse(398, 470, 58, 40):rim(4) + ellipse(392, 494, 58, 30):rim(4)) * rect(330, 470, 140, 60)
local pr = (ellipse(616, 470, 58, 40):rim(4) + ellipse(622, 494, 58, 30):rim(4)) * rect(560, 470, 140, 60)
blend((pl + pr):grow(5), {angle=0, tool={kind="badger", width=12}})

--@ chunk 113
print(wait(3*24*60)); print(drying(400,480), drying(620,480), drying(500,320))

--@ chunk 114
-- pauldrons rebuilt as three overlapping lames, each a curved band stroked along its length (lowest first)
local function lamep(cx, cy, rx, ry, a0, a1, w, P, lit_side)
  local pts = {}
  for i = 0, 14 do local a = lerp(a0, a1, i / 14); pts[#pts+1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end
  local m = ribbon(pts, w)
  local b = brush{kind="filbert", width=w * 0.55}
  work(m, {hand="body", pile=P.base, coverage=3, fill=true, clip=m, tool={kind="filbert", width=w * 0.4}, angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end, length={10, 25}})
  -- top edge lit toward the light side, underside dark
  local top, bot = {}, {}
  for i = 0, 14 do
    local a = lerp(a0, a1, i / 14)
    top[#top+1] = {cx + (rx) * math.cos(a), cy + ry * math.sin(a) - w * 0.28}
    bot[#bot+1] = {cx + (rx) * math.cos(a), cy + ry * math.sin(a) + w * 0.32}
  end
  b:reload(P.dark, 0.8); b:stroke(bot, {pressure={0.6, 0.6}, clip=m})
  local half = {}
  local from, to = 1, 15
  if lit_side == "left" then to = 9 else from = 7 end
  for i = from, to do half[#half+1] = top[i] end
  if lit_side == "right" then local r = {} for i = #half, 1, -1 do r[#r+1] = half[i] end half = r end
  b:reload(P.lit, 0.8); b:stroke(half, {pressure={0.7, 0.1}, ramps={0.1, 0.6}, clip=m})
  local h = brush{kind="round", width=1.6, point=0.6}
  local hh = {}
  for i = 1, math.min(5, #half) do hh[#hh+1] = {half[i][1], half[i][2] - w * 0.12} end
  h:reload(P.hi, 0.7); h:stroke(hh, {pressure={0.6, 0.0}, clip=m})
  return m
end
local L = {base=Q3, lit=Q5, dark=NDW, hi=R7}
local Lm = {base=Q2, lit=Q4, dark=NDW, hi=Q5}
-- viewer-left pauldron (lit)
lamep(400, 452, 62, 44, math.rad(150), math.rad(372), 18, Lm, "left")
lamep(400, 440, 58, 38, math.rad(160), math.rad(368), 20, L, "left")
lamep(402, 428, 50, 30, math.rad(170), math.rad(364), 22, L, "left")
-- viewer-right pauldron (shadowed)
local D = {base=R1, lit=Q3, dark=ND, hi=Q4}
lamep(616, 452, 62, 44, math.rad(168), math.rad(390), 18, D, "left")
lamep(616, 440, 58, 38, math.rad(172), math.rad(380), 20, D, "left")
lamep(614, 428, 50, 30, math.rad(176), math.rad(374), 22, {base=Q2, lit=Q3, dark=ND, hi=Q4}, "left")

--@ chunk 115
print(wait(5*24*60)); print(drying(400,420), drying(620,420), drying(360,470))

--@ chunk 116
-- a pauldron: dome cap plus two hanging lames (smile-shaped bands), painted lowest first
local function band(cx, cy, rx, ry, a0, a1, w)
  local pts = {}
  for i = 0, 16 do local a = lerp(a0, a1, i / 16); pts[#pts+1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end
  return pts, ribbon(pts, w)
end
local function offs(pts, d, cx, cy) -- move points radially by d
  local u = {}
  for i, p in ipairs(pts) do
    local dx, dy = p[1] - cx, p[2] - cy
    local l = math.sqrt(dx * dx + dy * dy)
    u[i] = {p[1] + dx / l * d, p[2] + dy / l * d}
  end
  return u
end
local function sub(pts, s0, s1) local u = {} local n = #pts for i = 1, n do local s = (i - 1) / (n - 1); if s >= s0 and s <= s1 then u[#u+1] = pts[i] end end return u end
function pauldron(cx, cy, P, side)
  -- side: 1 = lit (viewer left), 0 = shadow side
  local b = brush{kind="filbert", width=8}
  local h = brush{kind="round", width=1.8, point=0.6}
  for k, L in ipairs{{ry=52, w=16, rx=64}, {ry=40, w=16, rx=62}} do
    local pts, m = band(cx, cy - 8, L.rx, L.ry, math.rad(12), math.rad(168), L.w)
    work(m, {hand="body", pile=P.base, coverage=3, fill=true, clip=m, tool="filbert 5", angle=function(x, y) return math.atan(y - cy, x - cx) + math.pi / 2 end, length={10, 25}})
    b:reload(P.dark, 0.8); b:stroke(offs(pts, -L.w * 0.3, cx, cy - 8), {pressure={0.6, 0.6}, clip=m})
    b:reload(P.lit, 0.8); b:stroke(sub(offs(pts, L.w * 0.1, cx, cy - 8), 0.45 + 0.15 * (1 - side), 1), {pressure={0.1, 0.7}, ramps={0.5, 0.1}, clip=m})
    h:reload(P.hi, 0.7); h:stroke(sub(offs(pts, L.w * 0.32, cx, cy - 8), 0.7, 0.98), {pressure={0.0, 0.6}, clip=m})
  end
  -- the dome cap
  local cap = ellipse(cx, cy - 10, 58, 36)
  local f = form{ {body.ellipsoid({cx, cy - 10, 0}, {58, 36, 40})}, light=LGT }
  work(cap, {hand="body", pile=P.base, coverage=3, fill=true, clip=cap, tool="filbert 5", angle=0.2, length={10, 25}})
  for _, r in ipairs{0.85, 0.6, 0.35} do
    local pts = {}
    for i = 0, 12 do local a = lerp(math.rad(165), math.rad(290), i / 12); pts[#pts+1] = {cx - 6 + 58 * r * math.cos(a), cy - 14 + 36 * r * math.sin(a)} end
    b:reload(r < 0.5 and P.hi2 or P.lit, 0.8); b:stroke(pts, {pressure={0.3, 0.7, 0.2}, clip=cap})
  end
  local pts = {}
  for i = 0, 12 do local a = lerp(math.rad(-20), math.rad(150), i / 12); pts[#pts+1] = {cx + 52 * math.cos(a), cy - 8 + 30 * math.sin(a)} end
  b:reload(P.dark, 0.8); b:stroke(pts, {pressure={0.5, 0.7, 0.3}, clip=cap})
  local hp = {}
  for i = 0, 8 do local a = lerp(math.rad(195), math.rad(255), i / 8); hp[#hp+1] = {cx - 6 + 46 * math.cos(a), cy - 14 + 28 * math.sin(a)} end
  h:reload(P.hi, 0.7); h:stroke(hp, {pressure={0.2, 0.7, 0.1}, clip=cap})
end
pauldron(398, 460, {base=Q3, lit=Q4, hi2=Q5, dark=NDW, hi=R7}, 1)
pauldron(616, 460, {base=R1, lit=Q2, hi2=Q3, dark=ND, hi=Q4}, 0)

--@ chunk 117
GBand = pile{{"raw sienna",1},{"bone brown",1},{"burnt sienna",0.3}, medium=0.8}
local band = rect(0, 1272, 1000, 30)
work(band, {hand="glaze", pile=GBand, coverage=1.5, fill=true, clip=band, load_at=function(x, y) return lerp(0.5, 1.0, clamp(math.abs(x - 330) / 600, 0, 1)) end})
blend(band, {angle=0})

--@ chunk 118
print(wait(6*24*60)); print(drying(400,420), drying(620,450), drying(450,1000), drying(300,1285), drying(530,1000))

--@ chunk 119
-- restate the robe seams dark, leaving verdigris only in a few places near the hem
local n = 11
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
local function lame(i) local s = (i - 1) / (n - 1); return {lerp(450, 560, s), 756}, {lerp(360, 652, s) + 6 * math.sin(i * 2.1), lens[i]} end
local b = brush{kind="round", width=5, point=0.4}
for i = 1, n - 1 do
  local T1, B1 = lame(i); local T2, B2 = lame(i + 1)
  local T = {(T1[1] + T2[1]) / 2, 790}; local B = {(B1[1] + B2[1]) / 2, math.min(B1[2], B2[2]) - 6}
  local stop = 0.78 + 0.2 * ((i * 0.618) % 1)
  local pts = {}
  for k = 0, 8 do local s = lerp(0.3, stop, k / 8); pts[#pts+1] = {lerp(T[1], B[1], s), lerp(T[2], B[2], s)} end
  b:reload(NDW, 0.9)
  b:stroke(pts, {pressure={0.6, 0.85}, ramps={0.2, 0.1}})
end

--@ chunk 120
local n = 11
local lens = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
local function lame(i) local s = (i - 1) / (n - 1); return {lerp(450, 560, s), 756}, {lerp(360, 652, s) + 6 * math.sin(i * 2.1), lens[i]} end
local b = brush{kind="round", width=6, point=0.3}
for _, i in ipairs{1, 2, 4, 5, 7, 9, 10} do
  local T1, B1 = lame(i); local T2, B2 = lame(i + 1)
  local T = {(T1[1] + T2[1]) / 2, 790}; local B = {(B1[1] + B2[1]) / 2, math.min(B1[2], B2[2]) - 6}
  local pts = {}
  for k = 0, 6 do local s = lerp(0.7, 1.0, k / 6); pts[#pts+1] = {lerp(T[1], B[1], s), lerp(T[2], B[2], s)} end
  b:reload(NDW, 0.9)
  b:stroke(pts, {pressure={0.8, 0.8}, ramps={0.05, 0.05}})
end

--@ chunk 121
print(wait(5*24*60)); print(drying(400,420), drying(620,450), drying(450,1000), drying(505,140), drying(320,100))

--@ chunk 122
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.5}}
local h = brush{kind="round", width=2.2, point=0.7}
local h2 = brush{kind="round", width=3.2, point=0.5}
local function hl(b, p, pts, pr) b:reload(p, 0.7); b:stroke(pts, {pressure=pr or {0.2, 0.8, 0.0}, ramps={0.3, 0.5}}) end
-- halo outer bead, upper-left quadrant
hl(h2, R7, arcpts(505, 285, 148, math.rad(190), math.rad(250), 12), {0.1, 0.8, 0.0})
hl(h, HL, arcpts(505, 285, 149, math.rad(205), math.rad(238), 8), {0.1, 0.7, 0.0})
-- halo inner lip lower right (catching light across the opening)
hl(h, Q5, arcpts(505, 285, 119, math.rad(20), math.rad(75), 10), {0.1, 0.6, 0.0})
-- helm crown, upper-left rim
hl(h2, R7, {{470, 262}, {478, 246}, {492, 234}, {506, 229}}, {0.1, 0.8, 0.1})
hl(h, HL, {{476, 254}, {484, 242}, {496, 234}}, {0.2, 0.7, 0.0})
-- chest plate: the lit ridge on the left
hl(h2, R6, {{446, 470}, {448, 520}, {458, 580}, {474, 640}, {490, 690}}, {0.2, 0.7, 0.0})
hl(h, HL, {{447, 480}, {450, 520}, {457, 560}}, {0.2, 0.6, 0.0})
-- gorget top-left
hl(h, R7, {{432, 424}, {460, 428}, {490, 431}}, {0.1, 0.7, 0.0})
-- spear blade left edge and tip
hl(h, HL, {{321, 14}, {309, 50}, {300, 100}, {300, 140}, {308, 172}}, {0.4, 0.8, 0.0})
-- shaft highlight line
hl(h, Q5, {{317, 220}, {317, 500}, {317, 680}}, {0.5, 0.0})
-- left pauldron cap glint
hl(h, HL, arcpts(392, 446, 40, math.rad(200), math.rad(245), 6), {0.2, 0.8, 0.0})
-- left forearm and upper arm
hl(h, R7, {{378, 510}, {368, 545}, {360, 580}}, {0.2, 0.7, 0.0})
hl(h, R6, {{343, 625}, {338, 660}}, {0.3, 0.0})
-- belt
hl(h, R6, {{452, 742}, {480, 740}, {505, 740}}, {0.3, 0.6, 0.0})

--@ chunk 123
-- the spear head, restated whole: leaf blade with a midrib, a socket and bone collar
FIG.blade2 = {{322,8},{334,40},{344,85},{346,125},{338,165},{326,196},{318,196},{306,165},{298,125},{300,85},{310,40}}
local blade = poly(FIG.blade2, true)
local L = blade * mask(function(x, y) return x < 322 and 1 or 0 end)
local R = blade - L
work(R, {hand="detail", pile=Q2, coverage=3, fill=true, clip=R, angle=math.pi / 2})
work(L, {hand="detail", pile=Q4, coverage=3, fill=true, clip=L, angle=math.pi / 2})
local b = brush{kind="filbert", width=6}
b:reload(Q5, 0.8); b:stroke({{316, 40}, {308, 90}, {307, 130}, {314, 170}}, {pressure={0.5, 0.7, 0.3}, clip=L})
b:reload(R1, 0.8); b:stroke({{330, 50}, {338, 100}, {336, 150}, {328, 185}}, {pressure={0.5, 0.7, 0.3}, clip=R})
local h = brush{kind="round", width=2.0, point=0.7}
h:reload(HL, 0.7); h:stroke({{320, 12}, {310, 45}, {302, 90}, {301, 125}}, {pressure={0.3, 0.8, 0.0}, clip=blade:grow(1)})
h:reload(NDW, 0.7); h:stroke({{322, 20}, {322, 100}, {322, 190}}, {pressure={0.4, 0.6, 0.3}})
-- socket
local sock = poly({{314,192},{330,192},{332,232},{312,232}}, true)
work(sock, {hand="detail", pile=Q3, coverage=3, fill=true, clip=sock})
h:reload(Q5, 0.7); h:stroke({{316, 196}, {315, 230}}, {pressure={0.6, 0.6}})
-- bone collar on the socket
local col = ribbon({{311, 222}, {333, 222}}, 7)
work(col, {hand="detail", pile=BN, coverage=3, fill=true, clip=col})
local col2 = ribbon({{312, 212}, {332, 212}}, 3)
work(col2, {hand="detail", pile=BS, coverage=3, fill=true, clip=col2})
-- the stray gorget hairline on the pauldron: cover with the pauldron's tone
local s = ribbon({{430, 424}, {462, 428}, {492, 431}}, 4) * ellipse(398, 450, 60, 40)
work(s, {hand="detail", pile=Q3, coverage=3, fill=true, clip=s})

--@ chunk 124
local niche = poly(NICHE)
local zone = poly({{730,480},{790,380},{822,370},{822,860},{700,860},{700,620}}, true) * niche
local slope = (470 - 560) / (860 - 700)
local keep
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 11)
  keep = keep and (keep + b) or b
end
local robe = poly(FIG.mantle, true)
local m = zone - keep - GHOST1:grow(3) - figmask():grow(3) - robe:grow(2)
work(m, {hand="hatch", pile=BW1, coverage=0.6, clip=m, angle=math.pi / 2 + 0.2, load=0.5})
work(m, {hand="hatch", pile=WD2, coverage=0.5, clip=m, angle=math.pi / 2 + 0.25, load=0.5})

--@ chunk 125
print(wait(7*24*60)); print(drying(780,700), drying(760,600), drying(322,100), drying(620,450))

--@ chunk 126
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
-- the real raised hand, as painted
local fingers = {{{716,434},{711,382},4.6,3.4},{{726,432},{728,366},4.8,3.6},{{736,434},{745,377},4.6,3.4},{{745,442},{758,402},4.0,3.0},{{707,464},{686,436},5.0,3.8}}
NEWHAND = poly(FIG.palm, true)
for _, f in ipairs(fingers) do NEWHAND = NEWHAND + ribbon({f[1], f[2]}, {f[3] * 2, f[4] * 2}) end
local robe = poly({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, true)
local body = figmask() - poly(FIG.hand, true):grow(5) + NEWHAND + ribbon(FIG.larm_fore, {28, 24})
FIG2 = body + poly(FIG.mantle, true) + robe + poly(FIG.helm, true) + poly(FIG.gorget, true)
  + (ellipse(505, 285, 152, 152) - ellipse(505, 285, 116, 116)) + GHOST1 + ribbon(FIG.shaft, 14) + poly(FIG.blade2, true)
  + poly(sector(541, 255, 114, 152, math.rad(299), math.rad(352), 20))
local slope = (470 - 560) / (860 - 700)
local keep
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 10)
  keep = keep and (keep + b) or b
end
local niche = poly(NICHE)
local lit = poly(sh(NICHE, 150, 120)) * niche
local zone = (lit * rect(600, 0, 400, 1150)) - FIG2:grow(1.5) - keep
local dx, dy = 62, 44
local shadow = figmask2(dx, dy, true) + poly(sh(FIG.mantle, dx, dy), true) + poly(sh({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, dx, dy), true)
  + poly(sh(FIG.helm, dx, dy), true) + (ellipse(505 + dx, 285 + dy, 150, 150) - ellipse(505 + dx, 285 + dy, 118, 118))
local S = zone * shadow
local Lw = zone - shadow
work(Lw, {hand="body", pile=BW1, coverage=3, fill=true, clip=Lw, angle=math.pi/2 + 0.2})
work(Lw * rect(600, 160, 300, 380), {hand="scumble", pile=BW3, coverage=1.0, clip=Lw})
work(Lw * rect(600, 470, 400, 700), {hand="body", pile=BW2, coverage=1.6, fill=true, clip=Lw, angle=math.pi/2 + 0.2})
work(S, {hand="body", pile=BW4, coverage=3, fill=true, clip=S, angle=math.pi/2})

--@ chunk 127
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local niche = poly(NICHE)
local lit = poly(sh(NICHE, 150, 120)) * niche
local dx, dy = 62, 44
local shadow = figmask2(dx, dy, true) + poly(sh(FIG.mantle, dx, dy), true) + poly(sh({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, dx, dy), true)
  + poly(sh(FIG.helm, dx, dy), true) + (ellipse(505 + dx, 285 + dy, 150, 150) - ellipse(505 + dx, 285 + dy, 118, 118))
local zone = (lit * rect(400, 0, 200, 1150)) - FIG2:grow(1.5) - shadow
work(zone, {hand="body", pile=BW1, coverage=3, fill=true, clip=zone, angle=math.pi/2 + 0.2})
work(zone * rect(400, 160, 300, 380), {hand="scumble", pile=BW3, coverage=1.0, clip=zone})
local seam = (lit * rect(580, 150, 40, 500)) - FIG2:grow(1.5) - shadow
blend(seam, {angle=0, tool={kind="badger", width=14}})

--@ chunk 128
-- glyphs down the bone lancet, in a column, shrinking toward the point
local b = brush{kind="round", width=1.7, point=0.6}
local y = 488
local i = 0
while y < 668 do
  if i % 5 == 0 then b:reload(SD, 0.6) end
  local f1 = (i * 0.7548776) % 1
  local w = 0.5 + 0.5 * math.sin(math.pi * (y - 466) / 216)   -- lancet width profile
  local s = 5 + 4 * w
  glyph(b, 505 + (f1 - 0.5) * 6 * w, y, s, math.floor(f1 * 6 + i * 5) % 6)
  y = y + s * 1.25 + 2 * ((i * 0.5698) % 1)
  i = i + 1
end
-- tone the lower lancet down toward bone shadow
local lan = poly(FIG.lancet, true) * rect(0, 600, 1000, 100)
work(lan, {hand="scumble", pile=BS2, coverage=0.7, clip=lan})

--@ chunk 129
local seam = poly(FIG.lancet, true):shrink(2) * rect(0, 585, 1000, 40)
blend(seam, {angle=math.pi / 2, tool={kind="badger", width=8}})

--@ chunk 130
print(wait(5*24*60)); print(drying(505,620), drying(505,520), drying(700,600), drying(520,300))

--@ chunk 131
-- glyphs on the lower lancet
local b = brush{kind="round", width=1.6, point=0.6}
local y = 612
local i = 3
while y < 668 do
  if i % 4 == 3 then b:reload(SD, 0.6) end
  local f1 = (i * 0.7548776) % 1
  local w = 0.5 + 0.5 * math.sin(math.pi * (y - 466) / 216)
  local s = 4 + 4 * w
  glyph(b, 505 + (f1 - 0.5) * 5 * w, y, s, math.floor(f1 * 6 + i * 5) % 6)
  y = y + s * 1.3 + 1.5
  i = i + 1
end
-- the defacement: a cold, hard scrawl across the inscription, angular, unlike every curve on the warden
local s = brush{kind="round", width=2.6, point=0.4}
s:reload(CV, 0.7)
local pts = {{486,560},{521,574},{490,589},{524,601},{493,617},{519,628}}
s:stroke(pts, {pressure={0.7, 0.6}})
local t = brush{kind="round", width=1.2, point=0.8}
t:reload(CZ, 0.6)
local q = {}
for k, p in ipairs(pts) do q[k] = {p[1] - 0.8, p[2] - 1.4} end
t:stroke(q, {pressure={0.6, 0.5}})

--@ chunk 132
-- elbow cops: small domed discs with a bone boss
local function cop(cx, cy, r, P)
  local m = ellipse(cx, cy, r, r * 0.9)
  local f = form{ {body.ellipsoid({cx, cy, 20}, {r, r * 0.9, r * 0.7})}, light=LGT }
  shade(m, f, {{0,0.35,P[1]},{0.35,0.6,P[2]},{0.6,0.8,P[3]},{0.8,2,P[4]}}, {tool="filbert 2", length={3, 8}, angle=0.5})
  local b = brush{kind="round", width=r * 0.55, point=0.2}
  b:reload(BN, 0.7); b:touch(cx - 1, cy - 1, {pressure=0.6})
  local h = brush{kind="round", width=1.3, point=0.6}
  h:reload(HL, 0.6); h:stroke(arcpts(cx, cy, r * 0.82, math.rad(190), math.rad(250), 5), {pressure={0.2, 0.7, 0.0}})
end
cop(354, 609, 15, {R1, Q2, Q4, Q5})
cop(697, 606, 14, {R1, Q2, Q3, Q4})
-- the shaft below the fist, a lit line down its left side
local h = brush{kind="round", width=1.8, point=0.5}
h:reload(Q4, 0.7); h:stroke({{317, 730}, {317, 950}, {317, 1150}, {317, 1230}}, {pressure={0.6, 0.45, 0.2, 0.0}})
-- a bone ferrule at the butt
local fer = ribbon({{310, 1226}, {334, 1226}}, 8)
work(fer, {hand="detail", pile=BS, coverage=3, fill=true, clip=fer})

--@ chunk 133
local b = brush{kind="filbert", width=6}
b:reload(R6, 0.8); b:stroke(arcpts(505, 285, 146, math.rad(150), math.rad(262), 18), {pressure={0.1, 0.8, 0.1}, ramps={0.35, 0.35}})
local h = brush{kind="round", width=2.2, point=0.6}
h:reload(HL, 0.7); h:stroke(arcpts(505, 285, 147.5, math.rad(185), math.rad(240), 10), {pressure={0.1, 0.8, 0.0}, ramps={0.3, 0.4}})
-- helm crown: a broad light on the upper-left of the dome, above the petals
local cap = poly(FIG.helm, true) * ellipse(490, 255, 30, 26) - poly(FIG.mask, true):grow(14)
work(cap, {hand="scumble", pile=R6, coverage=1.0, clip=cap})
h:reload(HL, 0.7); h:stroke({{473, 258}, {481, 244}, {494, 235}}, {pressure={0.2, 0.7, 0.1}})

--@ chunk 134
-- bone studs set into the halo channel, spaced by the golden angle around the ring (only where the ring still is)
local bt = brush{kind="round", width=4.2, point=0.2}
local bh = brush{kind="round", width=1.4, point=0.5}
local n = 0
for k = 1, 60 do
  local a = (k * GA) % (2 * math.pi)
  local deg = math.deg(a)
  local inring = (deg < 296 and deg > -4) or deg > 358
  if inring and k <= 34 then
    local x, y = 505 + 133 * math.cos(a), 285 + 133 * math.sin(a)
    if n % 6 == 0 then bt:reload(BS, 0.7); bh:reload(HL, 0.5) end
    n = n + 1
    local lit = 0.5 + 0.5 * math.cos(a - math.rad(225))
    bt:touch(x, y, {pressure=0.5})
    if lit > 0.45 then bh:touch(x - 0.8, y - 0.9, {pressure=0.3}) end
  end
end
print(n)
-- the maker's rosette on the lit pauldron: a small seed-head of bone in the cap
local cx, cy = 392, 446
bt = brush{kind="round", width=2.6, point=0.2}
for k = 1, 34 do
  local a = k * GA
  local r = 2.4 * math.sqrt(k)
  if k % 8 == 1 then bt:reload(k < 12 and BN or BS, 0.7) end
  bt:touch(cx + r * math.cos(a), cy + 0.62 * r * math.sin(a), {pressure=0.3 + 0.25 * k / 34})
end

--@ chunk 135
local floor = (poly(NICHE) * rect(180, 1150, 640, 84))
local spots = floor * mask(function(x, y) return x < 560 and 1 or 0 end)
local m = spots - FIG2:grow(1) - poly(FIG.lsab, true):grow(1) - poly(FIG.rsab, true):grow(1) - ribbon(FIG.shaft, 14) - ribbon({{310,1226},{334,1226}}, 10)
work(m, {hand="body", pile=NDW, coverage=3, fill=true, clip=m, angle=0, tool="filbert 6"})
local front = m * rect(0, 1205, 1000, 30)
work(front, {hand="scumble", pile=WD, coverage=0.8, clip=front, angle=0})

--@ chunk 136
local floor = (poly(NICHE) * rect(180, 1150, 640, 84))
local obst = FIG2:grow(1) + poly(FIG.lsab, true):grow(1) + poly(FIG.rsab, true):grow(1) + ribbon(FIG.shaft, 14) + ellipse(742, 1194, 37, 28) + ribbon({{310,1226},{334,1226}}, 10)
local litf = floor * mask(function(x, y) return (x > 610 - (y - 1150) * 1.3) and 1 or 0 end)
local wedge = poly({{600,1176},{650,1150},{745,1150},{700,1192}}, true)
local L = litf - wedge - obst
work(L, {hand="body", pile=BW2, coverage=3, fill=true, clip=L, angle=0, tool="filbert 6"})
local S = floor - L - obst
-- soften the diagonal seam and the old front band
local seam = floor * mask(function(x, y) local d = x - (610 - (y - 1150) * 1.3); return (math.abs(d) < 12) and 1 or 0 end) - obst
blend(seam, {angle=-0.65, tool={kind="badger", width=10}})
local fb = (floor * rect(180, 1195, 420, 25)) - obst
blend(fb, {angle=math.pi / 2, tool={kind="badger", width=10}})

--@ chunk 137
local obst = FIG2:grow(1) + poly(FIG.rsab, true):grow(1) + ellipse(742, 1194, 36, 27)
local s1 = poly({{590,1176},{665,1170},{790,1150},{690,1150},{600,1160}}, true) * (poly(NICHE) * rect(180, 1150, 640, 84)) - obst
work(s1, {hand="body", pile=BW4, coverage=3, fill=true, clip=s1, angle=-0.3, tool="filbert 5"})
local s2 = poly({{722,1214},{770,1206},{806,1214},{812,1226},{780,1234},{730,1232}}, true) - obst
work(s2, {hand="detail", pile=BW4, coverage=3, fill=true, clip=s2})

--@ chunk 138
print(wait(6*24*60))

--@ chunk 139
GWall = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"ultramarine blue",0.2}, medium=0.82}
local wall = rect(0, 0, 1000, SILL - 8) - poly(ARCH_OUT) - (poly(FIG.blade2, true) + poly({{314,192},{330,192},{332,232},{312,232}}, true)):grow(2)
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
work(wall, {hand="glaze", pile=GWall, coverage=1.6, fill=true, clip=wall, load_at=function(x, y) return clamp(0.35 + (dl(x, y) - 300) / 900, 0.35, 1) end})
blend(wall, {angle=function(x, y) return math.atan(y - 440, x - 500) + math.pi / 2 end})

--@ chunk 140
local ex, ey = 524, 318
local b = brush{kind="round", width=3.0, point=0.3}
b:reload(CC, 0.7); b:touch(ex, ey, {pressure=0.7})
local c = brush{kind="round", width=1.8, point=0.3}
c:reload(pile{{"zinc white",3},{"cerulean blue",0.4}}, 0.8); c:touch(ex - 0.3, ey - 0.3, {pressure=0.6})

--@ chunk 141
local ex, ey = 524, 318
local c = brush{kind="round", width=4.0, point=0.1}
c:reload(pile{{"zinc white",3},{"cerulean blue",0.5}}, 1.0); c:touch(ex, ey, {pressure=0.9})

--@ chunk 142
print(wait(5*24*60)); print(drying(100,300), drying(900,600), drying(620,450), drying(700,1170))

--@ chunk 143
-- warm bounce from the lit back wall on the shadowed right edges
local r = brush{kind="round", width=2.6, point=0.5}
local function bounce(p, pts, pr) r:reload(p, 0.7); r:stroke(pts, {pressure=pr or {0.0, 0.6, 0.0}, ramps={0.4, 0.4}}) end
-- right pauldron: lower right rim of the cap and the lames
bounce(Q2, arcpts(616, 450, 56, math.rad(-10), math.rad(60), 10))
bounce(Q2, arcpts(616, 452, 62, math.rad(5), math.rad(70), 10), {0.0, 0.45, 0.0})
-- right side of the helm
bounce(Q3, {{548, 290}, {550, 310}, {546, 335}, {536, 352}}, {0.0, 0.5, 0.0})
-- chest plate right edge
bounce(Q2, {{580, 450}, {574, 520}, {560, 600}, {540, 670}}, {0.0, 0.55, 0.0})
-- mantle right edge, falling to the hem
bounce(BW2, {{700, 600}, {706, 720}, {712, 860}, {716, 1000}, {714, 1120}}, {0.0, 0.7, 0.3})
-- the right sabaton and robe hem, from the lit floor
bounce(Q2, {{600, 1196}, {640, 1206}, {668, 1208}}, {0.2, 0.5, 0.0})

--@ chunk 144
local Lx, Ly, Lz = -0.62, -0.52, 0.58
local function dl(x, y) return math.sqrt((x + 150)^2 + (y + 100)^2) end
local function tv(x, y)
  local ox, oy, t
  if y < NICHE_SPRING then
    local dx, dy = x - NICHE_CX, y - NICHE_SPRING
    local r = math.sqrt(dx * dx + dy * dy)
    ox, oy = dx / r, dy / r
    t = (r - 320) / 48
  else ox, oy = 1, 0; t = (x - 820) / 48 end
  local phi = (t - 0.5) * math.pi * 0.95
  local nx, ny, nz = ox * math.sin(phi), oy * math.sin(phi), math.cos(phi)
  local f = clamp(1.2 - (dl(x, y) - 450) / 900, 0.3, 1)
  return math.max(0, nx * Lx + ny * Ly + nz * Lz) * f
end
local mould = (poly(ARCH_OUT) - poly(NICHE)) * rect(780, 330, 120, 280)
local ang = function(x, y) if y < NICHE_SPRING then return math.atan(y - NICHE_SPRING, x - NICHE_CX) + math.pi/2 else return math.pi/2 end end
local steps = {{-1,0.12,R1},{0.12,0.25,Q2},{0.25,0.4,Q3},{0.4,0.55,Q4}}
for _, st in ipairs(steps) do
  local bm = mould * mask(function(x, y) local v = tv(x, y); return (v >= st[1] and v < st[2]) and 1 or 0 end)
  if bm:area() > 1 then work(bm, {hand="body", pile=st[3], coverage=3, fill=true, clip=mould, tool="filbert 4", length={8, 20}, angle=ang}) end
end
blend(mould, {angle=ang, tool={kind="badger", width=10}})

--@ chunk 145
print(wait(7*24*60)); print(drying(840,450), drying(840,300), drying(900,600))

--@ chunk 146
local mould = (poly(ARCH_OUT) - poly(NICHE)) * mask(function(x, y) return (x > 760 and y > 200) and 1 or 0 end)
work(mould, {hand="glaze", pile=GWall, coverage=1.4, fill=true, clip=mould, load_at=function(x, y) return clamp(0.5 + (y - 300) / 900, 0.5, 1) end})
blend(mould, {angle=function(x, y) if y < NICHE_SPRING then return math.atan(y - NICHE_SPRING, x - NICHE_CX) + math.pi/2 else return math.pi/2 end end})

--@ chunk 147
local h = brush{kind="round", width=2.4, point=0.5}
h:reload(Q4, 0.7)
local pts = arcpts(NICHE_CX, NICHE_SPRING, 323, math.rad(-62), math.rad(0), 10)
for _, y in ipairs{520, 640, 780, 920, 1060, 1200} do pts[#pts+1] = {823, y} end
h:stroke(pts, {pressure={0.1, 0.6, 0.3, 0.0}, ramps={0.2, 0.3}})
-- the cuts, continuing across the moulding to a point
local cuts = {{700, 560, 860, 470, 5.5}, {690, 590, 860, 500, 3.5}, {720, 530, 860, 452, 4.0}}
local bd = brush{kind="round", width=4.0, point=0.5}
local bc = brush{kind="round", width=1.4, point=0.7}
for i, c in ipairs(cuts) do
  local dx, dy = c[3] - c[1], c[4] - c[2]
  local l = math.sqrt(dx * dx + dy * dy)
  local ux, uy = dx / l, dy / l
  local x0 = 822; local t0 = (x0 - c[1]) / ux
  local y0 = c[2] + uy * t0
  local x1, y1 = c[3] + ux * (14 + 9 * i), c[4] + uy * (14 + 9 * i)
  bd:reload(CV, 0.7); bd:stroke({{x0, y0}, {x1, y1}}, {pressure={0.7, 0.0}, ramps={0.05, 0.6}})
  bc:reload(CZ, 0.6); bc:stroke({{x0 - uy * c[5] * 0.5, y0 + ux * c[5] * 0.5}, {x1, y1}}, {pressure={0.55, 0.0}, ramps={0.05, 0.5}})
end

--@ chunk 148
-- the fist round the shaft: four curled fingers stacked, thumb over the top
local cx = 330
local P = {base=Q3, lit=Q5, dark=NDW, hi=R7}
for i, y in ipairs{690, 700, 710, 720} do
  local w = 4.6 - (i - 1) * 0.3
  local xl = 309 + (i - 1) * 1.5
  local xr = 351 - (i - 1) * 2
  local m = ribbon({{xl, y}, {cx, y + 1.5}, {xr, y}}, w * 2)
  work(m, {hand="detail", pile=i < 3 and Q3 or Q2, coverage=3, fill=true, clip=m})
  local b = brush{kind="round", width=2.2, point=0.5}
  b:reload(i < 3 and Q5 or Q4, 0.7); b:stroke({{xl + 2, y - w * 0.5}, {cx - 6, y - w * 0.4}}, {pressure={0.4, 0.6, 0.1}, clip=m})
  b:reload(NDW, 0.7); b:stroke({{xl + 1, y + w * 0.7}, {xr - 1, y + w * 0.7}}, {pressure={0.4, 0.4}})
end
-- thumb across the top
local th = ribbon({{312, 684}, {330, 680}, {344, 684}}, {9, 8, 7})
work(th, {hand="detail", pile=Q4, coverage=3, fill=true, clip=th})
local b = brush{kind="round", width=1.8, point=0.6}
b:reload(R7, 0.7); b:stroke({{314, 680}, {328, 677}}, {pressure={0.3, 0.6, 0.0}})
-- the shaft below the fist, restated to show it passes through
local sh = rect(316, 728, 12, 20)
work(sh, {hand="detail", pile=Q2, coverage=3, fill=true, clip=sh})

--@ chunk 149
print(wait(10*24*60))

--@ chunk 150
local band = rect(0, 1272, 1000, 30)
work(band, {hand="glaze", pile=GWall, coverage=1.4, fill=true, clip=band, load_at=function(x, y) return lerp(0.35, 0.9, clamp(math.abs(x - 380) / 600, 0, 1)) end})
blend(band, {angle=0})
-- stronger lights on the figure where the light first strikes
local b = brush{kind="filbert", width=7}
local h = brush{kind="round", width=2.4, point=0.6}
local function L(p, pts, pr, br) (br or b):reload(p, 0.8); (br or b):stroke(pts, {pressure=pr, ramps={0.3, 0.4}}) end
-- chest plate: lit plane down the left
L(R6, {{452, 456}, {455, 510}, {463, 570}, {477, 630}}, {0.2, 0.8, 0.0})
L(HL, {{450, 462}, {452, 500}, {458, 540}}, {0.2, 0.7, 0.0}, h)
-- lit pauldron cap: a broad light at upper left
L(R6, arcpts(392, 446, 34, math.rad(195), math.rad(260), 8), {0.2, 0.9, 0.1})
-- upper arm, forearm
L(R6, {{380, 505}, {372, 540}, {364, 575}}, {0.3, 0.8, 0.0})
L(R6, {{346, 625}, {342, 655}, {338, 680}}, {0.5, 0.0})
-- helm: crown light
L(R6, {{478, 252}, {488, 240}, {500, 234}}, {0.3, 0.8, 0.1})
-- the uppermost lames of the robe on the left
L(R6, {{452, 770}, {446, 800}, {440, 830}}, {0.6, 0.0})
L(R6, {{462, 770}, {458, 800}, {454, 825}}, {0.5, 0.0})

--@ chunk 151
-- verdigris where water would have stood over a megayear: in recesses and under ledges
local m = ribbon({{432, 466}, {470, 474}, {505, 476}, {545, 474}, {580, 466}}, 5)          -- under the gorget
  + ribbon({{150, 1150}, {150, 1236}}, 10) + ribbon({{845, 1100}, {845, 1236}}, 8)        -- foot of the arch moulding
  + ribbon({{452, 746}, {560, 746}}, 4)                                                     -- under the belt
  + (ellipse(505, 285, 121, 121):rim(4) * rect(380, 300, 260, 120))                         -- inner lip of the halo, lower half
stipple(m, {pile=VG2, width=2.0, coverage=0.7, cluster=0.6, feather=0.6})
-- the halo will not hold still: a faint second contour, out of register
local c = brush{kind="round", width=1.3, point=0.8}
c:reload(CZ, 0.4)
c:stroke(arcpts(512, 279, 151, math.rad(-58), math.rad(35), 16), {pressure={0.0, 0.35, 0.0}, ramps={0.4, 0.4}})
c:reload(CC, 0.4)
c:stroke(arcpts(516, 276, 120, math.rad(-40), math.rad(20), 12), {pressure={0.0, 0.3, 0.0}, ramps={0.4, 0.4}})

--@ chunk 152
print(wait(14*24*60))

--@ chunk 153
-- the robe repainted as eleven distinct bronze lames: opaque, lit from the upper left, darker toward the hem and the right
SK_N = 11
SK_LENS = {1148, 1160, 1152, 1166, 1158, 1170, 1162, 1166, 1150, 1160, 1146}
function sk_lame(i) local s = (i - 1) / (SK_N - 1); return {lerp(450, 560, s), 762}, {lerp(360, 652, s) + 6 * math.sin(i * 2.1), SK_LENS[i]} end
local Plit = {low=R3, base=Q4, dark=NDW, lit=Q5, hi=HL}
local Pmid = {low=R2, base=Q3, dark=NDW, lit=Q4, hi=Q5}
local Psh  = {low=R2, base=R3, dark=ND, lit=Q3, hi=Q4, refl=Q3}
for i = 1, SK_N do
  local T, B = sk_lame(i)
  local P = i <= 4 and Plit or (i <= 7 and Pmid or Psh)
  lame3(T, B, 4.9, 13.6, P, i <= 4 and 0.62 or 0.5)
end

--@ chunk 154
-- the ghost arm: knocked down to a matte cold gray, cut into flat planes, no glossy tube
GH_F = {{{782,470},{790,428},4.2,3.2},{{792,472},{806,432},4.4,3.2},{{800,478},{822,446},4.2,3.0},{{806,488},{834,468},4.0,3.0},{{807,498},{838,492},3.8,2.8},{{768,494},{748,468},4.6,3.6}}
GH_PALM = {{764,512},{790,520},{808,500},{804,474},{780,466},{762,486}}
function ghostmask(dx, dy)
  local function sh(p) return {p[1] + dx, p[2] + dy} end
  local m = ribbon({sh({700,600}), sh({776,506})}, {26, 22})
  local palm = {}
  for i, p in ipairs(GH_PALM) do palm[i] = sh(p) end
  m = m + poly(palm, true)
  for _, f in ipairs(GH_F) do m = m + ribbon({sh(f[1]), sh(f[2])}, {f[3] * 2, f[4] * 2}) end
  return m
end
GHM = pile{{"zinc white",1.2},{"ultramarine ash",1},{"bone black",0.35},{"raw sienna",0.25}}
GHD = pile{{"ultramarine ash",1},{"bone black",0.6},{"zinc white",0.4},{"bone brown",0.3}}
local g = ghostmask(0, 0) - ellipse(702, 598, 12, 12)   -- leave the real elbow
work(g, {hand="detail", pile=GHM, coverage=3, fill=true, clip=g, angle=math.atan(-94, 76)})
-- a shadow plane on the forearm's upper-left side, flat and hard-edged
local nx, ny = -0.777, -0.628
local sp = ribbon({{700 + nx * 7, 600 + ny * 7}, {776 + nx * 6, 506 + ny * 6}}, {10, 8}) * g
work(sp, {hand="detail", pile=GHD, coverage=3, fill=true, clip=sp, angle=math.atan(-94, 76)})
-- the shadow side of each finger
for _, f in ipairs(GH_F) do
  local dx, dy = f[2][1] - f[1][1], f[2][2] - f[1][2]
  local l = math.sqrt(dx * dx + dy * dy); local ux, uy = dx / l, dy / l
  local px, py = uy, -ux; if px > 0 then px, py = -px, -py end
  local s = ribbon({{f[1][1] + px * f[3] * 0.5, f[1][2] + py * f[3] * 0.5}, {f[2][1] + px * f[4] * 0.5, f[2][2] + py * f[4] * 0.5}}, {f[3], f[4]}) * g
  work(s, {hand="detail", pile=GHD, coverage=2.5, fill=true, clip=s, angle=math.atan(dy, dx)})
end

--@ chunk 155
wait(4 * 24 * 60)
print(drying(400, 1100), drying(560, 1000))
-- the lames again over the dry lay-in, warm earths only (the first lay-in's lower piles carried viridian and went olive)
local Plit = {low=Q3, base=Q4, dark=NDW, lit=Q5, hi=HL}
local Pmid = {low=Q2, base=Q3, dark=NDW, lit=Q4, hi=Q5}
local Psh  = {low=Q2, base=Q3, dark=NDW, lit=Q4, hi=Q5, refl=Q4}
for i = 1, SK_N do
  local T, B = sk_lame(i)
  local P = i <= 4 and Plit or (i <= 7 and Pmid or Psh)
  lame3(T, B, 4.9, 13.6, P, i <= 4 and 0.6 or 0.5)
end

--@ chunk 156
wait(4 * 24 * 60)
-- dark joints between the lames, crisp; lit hairline on each lame's left edge
local function edge(i, off, s0, s1)
  local T, B = sk_lame(i)
  local t = {}
  for k = 0, 10 do
    local s = lerp(s0, s1, k / 10)
    local w = lerp(4.9, 13.6, s)
    t[#t+1] = {lerp(T[1], B[1], s) - w * off * 0.97, lerp(T[2], B[2], s)}
  end
  return t
end
local j = brush{kind="round", width=3.0, point=0.4}
for i = 1, SK_N - 1 do
  local T1, B1 = sk_lame(i); local T2, B2 = sk_lame(i + 1)
  local pts = {}
  for k = 0, 10 do local s = k / 10; pts[#pts+1] = {lerp((T1[1] + T2[1]) / 2, (B1[1] + B2[1]) / 2, s), lerp(764, math.min(B1[2], B2[2]) - 4, s)} end
  j:reload(i >= 7 and ND or NDW, 0.9)
  j:stroke(pts, {pressure={0.75, 0.9}, ramps={0.05, 0.1}})
end
-- the lit left edge of every lame, strongest on the lit side and near the top
local h = brush{kind="round", width=1.4, point=0.6}
for i = 1, SK_N do
  local P = i <= 4 and HL or (i <= 7 and Q5 or Q4)
  local reach = i <= 4 and 0.8 or (i <= 7 and 0.6 or 0.45)
  h:reload(P, 0.7)
  h:stroke(edge(i, 1, 0.01, reach), {pressure={0.7, 0.45, 0.0}, ramps={0.05, 0.6}})
end
-- a dark shadow tucked under the belt, over the tops of the lames
local u = brush{kind="filbert", width=4}
u:reload(NDW, 0.8); u:stroke({{448, 764}, {480, 767}, {520, 767}, {562, 764}}, {pressure={0.6, 0.6}})
-- crisp cold double outline: the true contour, and a second one out of register
local g = ghostmask(0, 0)
local line1 = g:rim(1.3) - ellipse(702, 598, 13, 13)
work(line1, {hand="detail", pile=CZ, coverage=2.5, fill=true, clip=line1})
local g2 = ghostmask(6, -5)
local line2 = (g2:rim(1.0) - g:grow(1.5)) - ellipse(702, 598, 16, 16)
work(line2, {hand="detail", pile=CC, coverage=2, fill=true, clip=line2})

--@ chunk 157
-- the lit back wall of the niche: repainted opaque and graded, then laid with smaller, quieter scale-plate lips
local function sh(t, dx, dy) local u = {} for i, p in ipairs(t) do u[i] = {p[1] + dx, p[2] + dy} end return u end
local slope = (470 - 560) / (860 - 700)
local keep
for _, off in ipairs{-36, -6, 26} do
  local b = ribbon({{700, 560 + off}, {920, 560 + off + slope * 220}}, 10)
  keep = keep and (keep + b) or b
end
local niche = poly(NICHE)
local lit = poly(sh(NICHE, 150, 120)) * niche
local zone = (lit * rect(600, 0, 400, 1150)) - FIG2:grow(1.5) - keep - ghostmask(6, -5):grow(2)
local dx, dy = 62, 44
local shadow = figmask2(dx, dy, true) + poly(sh(FIG.mantle, dx, dy), true) + poly(sh({{450,756},{560,756},{660,1150},{652,1172},{600,1172},{360,1150}}, dx, dy), true)
  + poly(sh(FIG.helm, dx, dy), true) + (ellipse(505 + dx, 285 + dy, 150, 150) - ellipse(505 + dx, 285 + dy, 118, 118))
LWALL = zone - shadow
WL1 = pile{{"raw sienna",2},{"yellow ochre",1},{"bone brown",0.6},{"lead white",0.4}}
WL2 = pile{{"raw sienna",2},{"bone brown",1.2},{"burnt sienna",0.4},{"lead white",0.2}}
local up = LWALL * rect(600, 0, 400, 640)
local dn = LWALL * rect(600, 600, 400, 600)
work(dn, {hand="body", pile=WL2, coverage=3, fill=true, clip=LWALL, angle=math.pi/2 + 0.15})
work(up, {hand="body", pile=WL1, coverage=3, fill=true, clip=LWALL, angle=math.pi/2 + 0.15})
blend(LWALL * rect(600, 590, 400, 60), {angle=math.pi/2})

--@ chunk 158
-- the arch moulding resolved: an outer fillet, a rounded torus and an inner fillet, each with its light and shadow
local cx, cy = NICHE_CX, NICHE_SPRING
local spare = FIG2:grow(3) + rect(812, 430, 90, 120)       -- spear and halo; the cuts across the moulding
local band = (poly(ARCH_OUT) - poly(NICHE)) - spare
-- body: the torus mid-band, laid along the curve
local torus = band * (ellipse(cx, cy, 358, 358) - ellipse(cx, cy, 334, 334)) * rect(0, 0, 1000, cy)
  + band * (rect(142, cy, 24, 1140 - cy) + rect(834, cy, 24, 1140 - cy))
work(torus, {hand="body", pile=Q3, coverage=3, fill=true, clip=torus, length={15, 35},
  angle=function(x, y) if y > cy then return math.pi / 2 end return math.atan(y - cy, x - cx) + math.pi / 2 end})
-- lines run as polylines along the arch and down both jambs
local function course(r, a0, a1)
  local t = {}
  if a0 <= math.pi then t[#t+1] = {cx + r * math.cos(math.pi), SILL - 4} end
  for i = 0, 40 do local a = lerp(a0, a1, i / 40); t[#t+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end
  if a1 >= 2 * math.pi then t[#t+1] = {cx + r, SILL - 4} end
  return t
end
local function lit(r, outward)
  -- the part of the course that faces the light, as runs of points
  local runs, cur = {}, nil
  local pts = course(r, math.pi, 2 * math.pi)
  for i, p in ipairs(pts) do
    local a = math.atan(p[2] - cy, p[1] - cx)
    if p[2] > cy then a = (p[1] < cx) and math.pi or 0 end
    local nrm = outward and a or a + math.pi
    if math.cos(nrm - LIGHT_ANG) > 0.1 then cur = cur or {}; cur[#cur+1] = p
    else if cur and #cur > 2 then runs[#runs+1] = cur end; cur = nil end
  end
  if cur and #cur > 2 then runs[#runs+1] = cur end
  return runs
end
local function strokeall(b, p, pts, pr, seg)
  seg = seg or 8
  local i = 1
  while i < #pts do
    local s = {}
    for k = i, math.min(#pts, i + seg) do s[#s+1] = pts[k] end
    if #s >= 2 then b:reload(p, 0.8); b:stroke(s, {pressure=pr, ramps={0.15, 0.15}, clip=band}) end
    i = i + seg
  end
end
wait(2 * 24 * 60)
local g = brush{kind="round", width=2.6, point=0.5}
strokeall(g, NDW, course(361, math.pi, 2 * math.pi), {0.6, 0.6})
strokeall(g, NDW, course(331, math.pi, 2 * math.pi), {0.6, 0.6})
local h = brush{kind="round", width=1.8, point=0.6}
for _, run in ipairs(lit(352, true)) do strokeall(h, Q5, run, {0.5, 0.5}, 6) end
for _, run in ipairs(lit(366, true)) do strokeall(h, Q4, run, {0.4, 0.4}, 6) end
for _, run in ipairs(lit(338, false)) do strokeall(h, Q5, run, {0.45, 0.45}, 6) end
local hh = brush{kind="round", width=1.2, point=0.8}
for _, run in ipairs(lit(350, true)) do
  local s = {}
  for k = 1, math.min(#run, 14) do s[#s+1] = run[k] end
  if #s > 2 then hh:reload(HL, 0.7); hh:stroke(s, {pressure={0.1, 0.6, 0.0}, ramps={0.3, 0.4}, clip=band}) end
end

--@ chunk 159
wait(3 * 24 * 60)
-- scale-plate lips on the lit back wall, a finer continuation of the outer wall's spiral; clipped to the light
local m = LWALL:shrink(3)
local bd = brush{kind="round", width=2.4, point=0.6}
local bl = brush{kind="round", width=1.5, point=0.8}
local c, n = 15, 0
for k = 60, 2600 do
  local r = c * math.sqrt(k)
  local a = k * GA
  local x, y = 500 + r * math.cos(a), 440 + r * math.sin(a)
  if x > 600 and x < 820 and y > 160 and y < 1150 and m:at(x, y) > 0.9 then
    if n % 6 == 0 then bd:reload(WL2, 0.7); bl:reload(Q5, 0.6) end
    n = n + 1
    local rad = c * 1.05
    local pts, lip = {}, {}
    for i = 0, 10 do
      local t = a - 0.9 + 1.8 * i / 10
      pts[#pts+1] = {x + 1.8 * math.cos(a) + rad * math.cos(t), y + 1.8 * math.sin(a) + rad * math.sin(t)}
      lip[#lip+1] = {x + (rad - 1) * math.cos(t), y + (rad - 1) * math.sin(t)}
    end
    local fade = clamp((1150 - y) / 700, 0.35, 1)
    bd:stroke(pts, {pressure={0.1, 0.45, 0.05}, ramps={0.3, 0.4}, clip=m})
    bl:stroke(lip, {pressure={0.05, 0.5 * fade, 0.0}, ramps={0.3, 0.4}, clip=m})
  end
end
print(n)

--@ chunk 160
wait(2 * 24 * 60)
-- the light on the figure, stronger where it first strikes: broad warm planes, then hard glints, all on dry paint
local b = brush{kind="filbert", width=8}
local m = brush{kind="filbert", width=5}
local h = brush{kind="round", width=2.0, point=0.6}
local function ell(cx, cy, rx, ry, a0, a1, n) local t = {} for i = 0, n do local a = lerp(a0, a1, i / n); t[#t+1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end return t end
local function L(br, p, pts, pr) br:reload(p, 0.85); br:stroke(pts, {pressure=pr, ramps={0.3, 0.4}}) end
-- halo: the upper-left quarter of the ring takes the light full on
L(b, R6, arcpts(505, 285, 136, math.rad(160), math.rad(245), 12), {0.2, 0.9, 0.2})
L(m, HL, arcpts(505, 285, 140, math.rad(175), math.rad(232), 10), {0.1, 0.8, 0.0})
L(h, R7, arcpts(505, 285, 147, math.rad(190), math.rad(228), 8), {0.0, 0.7, 0.0})
-- helm: the left cheek of the petals
L(m, R6, {{466, 268}, {462, 296}, {466, 326}, {474, 346}}, {0.2, 0.8, 0.0})
L(h, HL, {{472, 256}, {480, 244}, {492, 237}}, {0.0, 0.8, 0.0})
-- left pauldron: the top lame's crown, a hard sheen and a glint
L(b, R6, ell(402, 428, 40, 22, math.rad(190), math.rad(265), 8), {0.2, 0.9, 0.1})
L(m, HL, ell(402, 428, 38, 20, math.rad(205), math.rad(250), 6), {0.1, 0.9, 0.0})
L(h, R7, ell(402, 428, 44, 24, math.rad(212), math.rad(240), 5), {0.0, 0.8, 0.0})
-- chest plate: the left plane catches the light down its length
L(m, HL, {{454, 470}, {456, 520}, {462, 575}, {472, 625}}, {0.3, 0.8, 0.0})
L(h, R7, {{451, 475}, {452, 505}}, {0.0, 0.8, 0.0})
-- gorget left edge
L(h, HL, {{438, 470}, {452, 466}, {470, 466}}, {0.1, 0.7, 0.0})
-- spear arm: upper arm and forearm, a stronger lit line
L(m, HL, {{384, 500}, {376, 535}, {368, 572}}, {0.3, 0.8, 0.0})
L(m, HL, {{348, 620}, {344, 650}, {341, 676}}, {0.6, 0.0})

--@ chunk 161
wait(2 * 24 * 60)
-- the ghost's body down a step, cooler and quieter, inside its outlines
GHM2 = pile{{"ultramarine ash",1},{"cobalt violet",0.4},{"zinc white",0.7},{"bone black",0.25}}
local g = ghostmask(0, 0):shrink(1.8) - ellipse(702, 598, 14, 14)
work(g, {hand="detail", pile=GHM2, coverage=3, fill=true, clip=g, angle=math.atan(-94, 76)})
local nx, ny = -0.777, -0.628
local sp = ribbon({{700 + nx * 6, 600 + ny * 6}, {776 + nx * 5, 506 + ny * 5}}, {8, 6}) * g
work(sp, {hand="detail", pile=GHD, coverage=3, fill=true, clip=sp, angle=math.atan(-94, 76)})

--@ chunk 162
wait(2 * 24 * 60)
-- the ghost's body down a step, cooler and quieter, inside its outlines
GHM3 = pile{{"ultramarine ash",1},{"bone black",0.5},{"cobalt violet",0.3},{"zinc white",0.3},{"bone brown",0.2}}
local g = ghostmask(0, 0):shrink(1.8) - ellipse(702, 598, 14, 14)
work(g, {hand="detail", pile=GHM3, coverage=3, fill=true, clip=g, angle=math.atan(-94, 76)})
local nx, ny = -0.777, -0.628
local sp = ribbon({{700 + nx * 6, 600 + ny * 6}, {776 + nx * 5, 506 + ny * 5}}, {8, 6}) * g
work(sp, {hand="detail", pile=GHD, coverage=3, fill=true, clip=sp, angle=math.atan(-94, 76)})
