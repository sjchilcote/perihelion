-- easel session "crew": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=77,
  ground={{pile={{"burnt sienna",1},{"bone brown",1},{"yellow ochre",0.5},{"lead white",0.3}}, um=120, apply="knife", texture=0.3}}}
-- the dock behind them, sunk in warm dark: the collar's ring, a rib, the deck
local WALL = pile{{"bone brown",1},{"bone black",0.6},{"ultramarine ash",0.4},{"burnt sienna",0.3}}
local WALL2 = pile{{"bone brown",1},{"bone black",0.3},{"ultramarine ash",0.3},{"yellow ochre",0.25},{"lead white",0.2}}
local DECK = pile{{"bone brown",1},{"bone black",0.8},{"burnt sienna",0.3}}
local wall = rect(0,0,1000,470)
work(wall, {hand="body", tool={kind="filbert", width=14}, pile=WALL, coverage=3, fill=true, clip=wall, angle=1.5708, length={60,160}})
local litw = ellipse(130, 160, 260, 220):soften(40) * wall
work(litw, {hand="body", tool={kind="filbert", width=10}, pile=WALL2, coverage=2, fill=true, clip=wall, angle=1.5708, length={40,120}, edge="lost"})
local deck = rect(0,470,1000,200)
work(deck, {hand="body", tool={kind="filbert", width=14}, pile=DECK, coverage=3, fill=true, clip=deck, angle=0, length={60,160}})
blend(rect(0, 455, 1000, 30), {angle=0, tool={kind="badger", width=12}})
-- the docking collar's great ring behind the group, dim
local CX, CY = 470, 180
local ringo, ringi = ellipse(CX, CY, 300, 260), ellipse(CX, CY, 238, 205)
local DIMA = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"bone brown",0.6}}
local DIMK = pile{{"bone black",1.4},{"bone brown",0.6}}
for s=0,23 do
  local a1, a2 = 2*math.pi*s/24, 2*math.pi*(s+1)/24
  local seg = poly({{CX+238*math.cos(a1), CY+205*math.sin(a1)}, {CX+300*math.cos(a1+0.05), CY+260*math.sin(a1+0.05)}, {CX+300*math.cos(a2+0.05), CY+260*math.sin(a2+0.05)}, {CX+238*math.cos(a2), CY+205*math.sin(a2)}}) * wall
  if seg:area() > 1 then work(seg, {hand="body", tool={kind="filbert", width=6}, pile=(s%2==0) and DIMA or DIMK, coverage=3, fill=true, clip=seg, angle=a1+1.5708}) end
end
local hatch = ringi * wall
work(hatch, {hand="body", tool={kind="filbert", width=10}, pile=pile{{"bone black",1},{"ultramarine ash",0.5},{"bone brown",0.5},{"lead white",0.12}}, coverage=3, fill=true, clip=hatch, angle=1.5708})

--@ chunk 2
print(wait(2*24*60))
-- the sitters: three standing behind, four seated in front around the crate
F = {
  {cx=300, hy=178, s=1.0, row="back", skin=2, hair="dk"},
  {cx=470, hy=162, s=1.0, row="back", skin=1, hair="grey", prop="clip"},
  {cx=640, hy=180, s=1.0, row="back", skin=3, hair="bk", jacket=true},
  {cx=160, hy=292, s=1.1, row="side", skin=1, hair="red", prop="mug"},
  {cx=375, hy=300, s=1.05, row="mid", skin=3, hair="bald"},
  {cx=575, hy=298, s=1.05, row="mid", skin=2, hair="tied"},
  {cx=815, hy=290, s=1.1, row="side", skin=1, hair="brown", prop="can"},
}
CL = pile{{"cobalt blue",1},{"lead white",0.7},{"ultramarine blue",0.3},{"yellow ochre",0.08}}
CM = pile{{"ultramarine blue",1},{"cobalt blue",0.6},{"lead white",0.25},{"bone black",0.15}}
CD = pile{{"ultramarine blue",1},{"bone black",0.6},{"burnt sienna",0.2}}
JL = pile{{"ultramarine blue",1},{"bone black",0.35},{"lead white",0.3}}
JD = pile{{"ultramarine blue",1},{"bone black",1}}
function body_of_fig(f)
  local s, cx, hy = f.s, f.cx, f.hy
  local sh = hy + 46*s
  local w = 64*s
  local bottom = (f.row == "back") and 520 or ((f.row == "mid") and 520 or hy + 205*s)
  local torso = poly({{cx-w*0.55, sh-6*s}, {cx-w*0.95, sh+8*s}, {cx-w, sh+40*s}, {cx-w*0.9, bottom}, {cx+w*0.9, bottom}, {cx+w, sh+40*s}, {cx+w*0.95, sh+8*s}, {cx+w*0.55, sh-6*s}}, true)
  local m = torso
  if f.row == "side" then
    local dir = (cx < 500) and 1 or -1
    local kx = cx + dir*40*s
    local thigh = poly({{cx-w*0.85, bottom-25*s}, {cx+w*0.85, bottom-25*s}, {cx+w*0.95, bottom+30*s}, {cx-w*0.95, bottom+30*s}}, true)
    local legL = poly({{cx-w*0.8, bottom+20*s}, {cx-w*0.1, bottom+20*s}, {cx-w*0.15, 610}, {cx-w*0.75, 610}}, true)
    local legR = poly({{cx+w*0.05, bottom+20*s}, {cx+w*0.8, bottom+20*s}, {cx+w*0.75, 610}, {cx+w*0.12, 610}}, true)
    m = m + thigh + legL + legR
  end
  return m, sh, w, bottom
end
local order = {1,2,3,5,6,4,7}
for _,i in ipairs(order) do
  local f = F[i]
  local m, sh, w = body_of_fig(f)
  f.body = m
  local lit = m * mask(function(x,y) return (x < f.cx - 12*f.s) and 1 or 0 end)
  local dark = m * mask(function(x,y) return (x > f.cx + 30*f.s) and 1 or 0 end)
  local mid = m - lit - dark
  local Lp, Mp, Dp = CL, CM, CD
  if f.jacket then Lp, Mp, Dp = JL, JL, JD end
  work(lit, {hand="body", tool={kind="filbert", width=6*f.s}, pile=Lp, coverage=3.4, fill=true, clip=m, angle=1.5708, length={15,40}})
  work(mid, {hand="body", tool={kind="filbert", width=6*f.s}, pile=Mp, coverage=3.4, fill=true, clip=m, angle=1.5708, length={15,40}})
  work(dark, {hand="body", tool={kind="filbert", width=6*f.s}, pile=Dp, coverage=3.4, fill=true, clip=m, angle=1.5708, length={15,40}})
end
-- the crate they gather round, its lit face toward us
local CRT = pile{{"lead white",1.4},{"yellow ochre",0.3},{"bone black",0.2}}
local CRF = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.4},{"ultramarine ash",0.3}}
local CRS = pile{{"lead white",0.5},{"bone black",0.8},{"ultramarine ash",0.4},{"bone brown",0.3}}
CRATE_T = poly({{290,440},{700,440},{730,465},{265,465}})
CRATE_F = rect(265, 465, 465, 140)
work(CRATE_F, {hand="body", tool={kind="filbert", width=8}, pile=CRF, coverage=3.6, fill=true, clip=true, angle=0})
work(CRATE_T, {hand="body", tool={kind="filbert", width=5}, pile=CRT, coverage=3.6, fill=true, clip=true, angle=0})
work(rect(690, 465, 40, 140), {hand="body", tool={kind="filbert", width=5}, pile=CRS, coverage=3.6, fill=true, clip=true, angle=1.5708})

--@ chunk 3
print(wait(2*24*60))
function sil(f)
  local s, cx, hy = f.s, f.cx, f.hy
  local P = {}
  P.head = ellipse(cx, hy, 23*s, 30*s)
  P.neck = poly({{cx-11*s, hy+18*s}, {cx+11*s, hy+18*s}, {cx+13*s, hy+44*s}, {cx-13*s, hy+44*s}})
  local bottom = (f.row == "side") and (hy + 195*s) or 540
  P.torso = poly({{cx-14*s, hy+38*s}, {cx-52*s, hy+52*s}, {cx-64*s, hy+72*s}, {cx-60*s, bottom}, {cx+60*s, bottom}, {cx+64*s, hy+72*s}, {cx+52*s, hy+52*s}, {cx+14*s, hy+38*s}}, true)
  local hx = f.handx or cx
  local hyy = f.handy or (hy + 165*s)
  P.armL = ribbon({{cx-56*s, hy+66*s}, {cx-66*s, hy+120*s}, {cx-58*s, hy+158*s}, {hx-12*s, hyy}}, {24*s, 22*s, 20*s, 17*s})
  P.armR = ribbon({{cx+56*s, hy+66*s}, {cx+66*s, hy+120*s}, {cx+58*s, hy+158*s}, {hx+12*s, hyy}}, {24*s, 22*s, 20*s, 17*s})
  if f.row == "side" then
    P.legs = poly({{cx-60*s, bottom-20*s}, {cx+60*s, bottom-20*s}, {cx+64*s, bottom+28*s}, {cx+48*s, 612}, {cx+8*s, 612}, {cx, bottom+40*s}, {cx-8*s, 612}, {cx-48*s, 612}, {cx-64*s, bottom+28*s}}, true)
  end
  local all = P.head + P.neck + P.torso + P.armL + P.armR
  if P.legs then all = all + P.legs end
  return all, P
end
F[1].handy = F[1].hy + 170; F[2].handy = F[2].hy + 150; F[3].handy = F[3].hy + 175
F[4].handy = F[4].hy + 120; F[4].handx = F[4].cx + 5
F[5].handy = 450; F[6].handy = 450
F[7].handy = F[7].hy + 200; F[7].handx = F[7].cx - 20
local allfig
for i,f in ipairs(F) do local m, P = sil(f); f.sil = m; f.P = P; allfig = allfig and (allfig + m) or m end
ALLFIG = allfig
CRATE = CRATE_T + CRATE_F + rect(690, 465, 40, 140)
-- the room goes back into Rembrandt's dark, and the figures are cut out of it
local BG = rect(0,0,1000,H) - ALLFIG:grow(0.5) - CRATE
local CX, CY = 470, 180
local band = (ellipse(CX, CY, 300, 260) - ellipse(CX, CY, 238, 205)) * BG
local hatch = ellipse(CX, CY, 238, 205) * BG
local wall = rect(0,0,1000,465) * BG - band - hatch
local deck = rect(0,465,1000,210) * BG
local WALLD = pile{{"bone brown",1},{"bone black",0.8},{"burnt sienna",0.3}}
local WALLW = pile{{"bone brown",1},{"burnt sienna",0.6},{"yellow ochre",0.3},{"bone black",0.3}}
local DECK = pile{{"bone brown",1},{"bone black",1},{"burnt sienna",0.2}}
work(wall * rect(0,0,330,465), {hand="body", tool={kind="filbert", width=8}, pile=WALLW, coverage=3.5, fill=true, clip=wall, angle=1.5708, length={30,90}})
work(wall - rect(0,0,330,465), {hand="body", tool={kind="filbert", width=8}, pile=WALLD, coverage=3.5, fill=true, clip=wall, angle=1.5708, length={30,90}})
work(hatch, {hand="body", tool={kind="filbert", width=8}, pile=pile{{"bone black",1.2},{"ultramarine ash",0.4},{"bone brown",0.6}}, coverage=3.5, fill=true, clip=hatch, angle=1.5708})
local DIMA = pile{{"yellow ochre",1},{"burnt sienna",0.9},{"bone brown",1.0}}
local DIMK = pile{{"bone black",1.5},{"bone brown",0.6}}
for s=0,23 do
  local a1, a2 = 2*math.pi*s/24, 2*math.pi*(s+1)/24
  local seg = poly({{CX+236*math.cos(a1), CY+203*math.sin(a1)}, {CX+302*math.cos(a1+0.05), CY+262*math.sin(a1+0.05)}, {CX+302*math.cos(a2+0.05), CY+262*math.sin(a2+0.05)}, {CX+236*math.cos(a2), CY+203*math.sin(a2)}}) * band
  if seg:area() > 1 then work(seg, {hand="body", tool={kind="filbert", width=5}, pile=(s%2==0) and DIMA or DIMK, coverage=3.5, fill=true, clip=seg, angle=a1+1.5708}) end
end
work(deck, {hand="body", tool={kind="filbert", width=10}, pile=DECK, coverage=3.5, fill=true, clip=deck, angle=0, length={40,120}})
blend(rect(0, 452, 1000, 26) * BG, {angle=0, tool={kind="badger", width=10}})
blend((rect(300, 0, 60, 452)) * wall, {angle=0, tool={kind="badger", width=12}})

--@ chunk 4
local CL2 = pile{{"ultramarine blue",1},{"cobalt blue",0.6},{"lead white",0.45}}
local CM2 = pile{{"ultramarine blue",1},{"cobalt blue",0.3},{"bone black",0.3},{"lead white",0.12}}
local CD2 = pile{{"ultramarine blue",1},{"bone black",0.9},{"burnt sienna",0.15}}
local JL2 = pile{{"ultramarine blue",1},{"bone black",0.6},{"lead white",0.2}}
local JD2 = pile{{"bone black",1.2},{"ultramarine blue",0.8}}
local function shade(m, f, Lp, Mp, Dp, lx, dx)
  local lit = m * mask(function(x,y) return (x < lx) and 1 or 0 end)
  local dark = m * mask(function(x,y) return (x > dx) and 1 or 0 end)
  local mid = m - lit - dark
  local t = {kind="filbert", width=5*f.s}
  if lit:area() > 1 then work(lit, {hand="body", tool=t, pile=Lp, coverage=4, fill=true, clip=m, angle=1.5708, length={10,35}}) end
  if mid:area() > 1 then work(mid, {hand="body", tool=t, pile=Mp, coverage=4, fill=true, clip=m, angle=1.5708, length={10,35}}) end
  if dark:area() > 1 then work(dark, {hand="body", tool=t, pile=Dp, coverage=4, fill=true, clip=m, angle=1.5708, length={10,35}}) end
end
local function paintfig(f, cover)
  local P = f.P
  local Lp, Mp, Dp = CL2, CM2, CD2
  if f.jacket then Lp, Mp, Dp = JL2, JL2, JD2 end
  local s, cx = f.s, f.cx
  local tor = P.torso - (P.armL + P.armR)
  if P.legs then tor = tor + (P.legs - P.armL - P.armR) end
  if cover then tor = tor - cover end
  shade(tor, f, Lp, Mp, Dp, cx - 30*s, cx + 10*s)
  local aL = P.armL - (cover or mask(function() return 0 end))
  local aR = P.armR - (cover or mask(function() return 0 end))
  shade(aL, f, Lp, Lp, Mp, cx - 50*s, cx - 30*s)
  shade(aR, f, Mp, Dp, Dp, cx + 40*s, cx + 50*s)
end
for _,i in ipairs({1,2,3}) do paintfig(F[i], F[5].sil + F[6].sil + CRATE + F[4].sil + F[7].sil) end
for _,i in ipairs({5,6}) do paintfig(F[i], CRATE) end
for _,i in ipairs({4,7}) do paintfig(F[i], nil) end

--@ chunk 5
print(wait(2*24*60))
-- the crate, repainted dry: warm work-light from the left
local CRT = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.15}}
local CRF = pile{{"lead white",0.8},{"yellow ochre",0.35},{"bone black",0.35},{"ultramarine ash",0.2}}
local CRF2 = pile{{"lead white",0.45},{"yellow ochre",0.3},{"bone black",0.55},{"ultramarine ash",0.2}}
local CRS = pile{{"bone black",1},{"bone brown",0.6},{"lead white",0.2}}
work(CRATE_F * rect(0,0,500,H), {hand="body", tool={kind="filbert", width=7}, pile=CRF, coverage=4.5, fill=true, clip=CRATE_F, angle=0})
work(CRATE_F - rect(0,0,500,H), {hand="body", tool={kind="filbert", width=7}, pile=CRF2, coverage=4.5, fill=true, clip=CRATE_F, angle=0})
blend(CRATE_F * rect(470,0,60,H), {angle=0, tool={kind="badger", width=8}})
work(CRATE_T, {hand="body", tool={kind="filbert", width=5}, pile=CRT, coverage=4.5, fill=true, clip=true, angle=0})
work(rect(690, 465, 40, 140), {hand="body", tool={kind="filbert", width=5}, pile=CRS, coverage=4.5, fill=true, clip=true, angle=1.5708})
-- heads and necks: lit planes, half-tones, shadow planes, the turn blended narrowly
SK = {
  {L=pile{{"lead white",1.5},{"red earth",0.3},{"yellow ochre",0.4}}, M=pile{{"lead white",1},{"red earth",0.45},{"yellow ochre",0.45},{"ultramarine ash",0.1}}, D=pile{{"red earth",1},{"bone brown",0.7},{"yellow ochre",0.3},{"ultramarine blue",0.1}}},
  {L=pile{{"yellow ochre",1},{"red earth",0.4},{"lead white",0.9},{"burnt sienna",0.15}}, M=pile{{"yellow ochre",1},{"red earth",0.5},{"lead white",0.4},{"burnt sienna",0.4}}, D=pile{{"burnt sienna",1},{"bone brown",0.8},{"red earth",0.2}}},
  {L=pile{{"burnt sienna",1},{"red earth",0.4},{"yellow ochre",0.4},{"lead white",0.35}}, M=pile{{"burnt sienna",1},{"bone brown",0.5},{"red earth",0.3},{"lead white",0.1}}, D=pile{{"bone brown",1},{"bone black",0.35},{"burnt sienna",0.5}}},
}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local head = f.P.head + f.P.neck
  local cov = CRATE
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  head = head - cov
  local sk = SK[f.skin]
  local lit = head * mask(function(x,y) return (x < cx - 4*s) and 1 or 0 end)
  local dark = head * mask(function(x,y) return (x > cx + 9*s or y > hy + 26*s) and 1 or 0 end)
  local mid = head - lit - dark
  local t = {kind="filbert", width=3*s}
  work(lit - dark, {hand="detail", tool=t, pile=sk.L, coverage=4.5, fill=true, clip=head, angle=1.5708})
  work(mid, {hand="detail", tool=t, pile=sk.M, coverage=4.5, fill=true, clip=head, angle=1.5708})
  work(dark, {hand="detail", tool=t, pile=sk.D, coverage=4.5, fill=true, clip=head, angle=1.5708})
  blend(head * rect(cx - 8*s, hy - 32*s, 20*s, 70*s), {angle=0, tool={kind="badger", width=3*s}})
end

--@ chunk 6
print(wait(2*24*60))
local HAIR = {
  dk = {pile{{"bone brown",1},{"bone black",0.5}}, pile{{"bone brown",1},{"burnt sienna",0.4},{"lead white",0.15}}},
  grey = {pile{{"lead white",1},{"bone black",0.5},{"ultramarine ash",0.3}}, pile{{"lead white",1.5},{"bone black",0.2}}},
  bk = {pile{{"bone black",1.5},{"bone brown",0.5}}, pile{{"bone black",1},{"ultramarine ash",0.4},{"lead white",0.2}}},
  red = {pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone brown",0.4}}, pile{{"Mars orange",1},{"burnt sienna",0.5},{"lead white",0.3}}},
  bald = {pile{{"bone brown",1},{"bone black",0.6}}, pile{{"bone brown",1},{"lead white",0.25}}},
  tied = {pile{{"bone black",1},{"bone brown",1}}, pile{{"bone brown",1},{"burnt sienna",0.3},{"lead white",0.2}}},
  brown = {pile{{"bone brown",1},{"burnt sienna",0.8},{"yellow ochre",0.2}}, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"lead white",0.3}}},
}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local head = f.P.head
  local cov = CRATE
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  local H2 = HAIR[f.hair]
  local m
  if f.hair == "bald" then
    m = poly({{cx-21*s, hy+8*s}, {cx-16*s, hy+24*s}, {cx, hy+31*s}, {cx+16*s, hy+24*s}, {cx+21*s, hy+8*s}, {cx+12*s, hy+14*s}, {cx, hy+12*s}, {cx-12*s, hy+14*s}}, true)
  elseif f.hair == "red" then
    m = (ellipse(cx, hy - 10*s, 27*s, 26*s) + rect(cx - 27*s, hy - 10*s, 9*s, 36*s) + rect(cx + 18*s, hy - 10*s, 9*s, 36*s)) - poly({{cx-17*s, hy-14*s}, {cx+17*s, hy-14*s}, {cx+18*s, hy+40*s}, {cx-18*s, hy+40*s}}, true)
  elseif f.hair == "grey" then
    m = (ellipse(cx, hy - 14*s, 24*s, 20*s) - ellipse(cx, hy - 2*s, 18*s, 22*s)) + ellipse(cx - 21*s, hy - 2*s, 4*s, 10*s) + ellipse(cx + 21*s, hy - 2*s, 4*s, 10*s)
  else
    m = ellipse(cx, hy - 12*s, 25*s, 23*s) - ellipse(cx, hy + 2*s, 20*s, 22*s)
    if f.hair == "tied" then m = m + ellipse(cx + 20*s, hy - 22*s, 9*s, 8*s) end
  end
  m = m - cov
  local lit = m * mask(function(x,y) return (x < cx - 6*s) and 1 or 0 end)
  work(m - lit, {hand="detail", tool={kind="filbert", width=2.5*s}, pile=H2[1], coverage=4.5, fill=true, clip=m, angle=1.2})
  work(lit, {hand="detail", tool={kind="filbert", width=2.5*s}, pile=H2[2], coverage=4, fill=true, clip=m, angle=1.2})
  if f.hair == "brown" then
    local mo = poly({{cx-11*s, hy+14*s}, {cx+11*s, hy+14*s}, {cx+9*s, hy+19*s}, {cx-9*s, hy+19*s}}, true)
    work(mo, {hand="detail", tool={kind="round", width=1.5}, pile=H2[1], coverage=4, fill=true, clip=mo})
  end
  -- ears
  local SKD = SK[f.skin].D
  if f.hair ~= "red" then
    for _,dx in ipairs({-22, 22}) do
      local e = ellipse(cx + dx*s, hy + 2*s, 4*s, 8*s) - cov
      work(e, {hand="detail", tool={kind="round", width=1.5}, pile=(dx < 0) and SK[f.skin].M or SKD, coverage=4, fill=true, clip=e})
    end
  end
end

--@ chunk 7
print(wait(24*60))
local K = pile{{"bone brown",1},{"bone black",0.7},{"burnt sienna",0.3}}
local W = pile{{"lead white",2},{"yellow ochre",0.15}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local sk = SK[f.skin]
  local HL = pile{{"lead white",2},{"red earth",0.2},{"yellow ochre",0.3}}
  local D = sk.D
  local function st(p, w, pts, pr, load)
    local b = brush{kind="round", width=w, point=0.6}
    b:reload(p, load or 0.8); b:stroke(pts, {pressure=pr or {0.5,0.3}})
  end
  -- brow and sockets
  local brL = {{cx-17*s, hy-6*s}, {cx-10*s, hy-8.5*s}, {cx-3*s, hy-7*s}}
  local brR = {{cx+3*s, hy-7*s}, {cx+10*s, hy-8.5*s}, {cx+17*s, hy-6*s}}
  local sockL = ellipse(cx-9*s, hy-2*s, 6*s, 3.6*s)
  local sockR = ellipse(cx+9*s, hy-2*s, 6*s, 3.6*s)
  work(sockL, {hand="detail", tool={kind="round", width=1.6}, pile=sk.M, coverage=3, fill=true, clip=sockL})
  work(sockR, {hand="detail", tool={kind="round", width=1.6}, pile=D, coverage=3, fill=true, clip=sockR})
  local hairp = (f.hair == "grey") and pile{{"lead white",1},{"bone black",0.6}} or K
  st(hairp, 1.6*s, brL, {0.5,0.4}); st(hairp, 1.6*s, brR, {0.5,0.4})
  -- eyes: lids and irises, small, a catchlight on the lit eye
  st(K, 1.3*s, {{cx-13*s, hy-2*s}, {cx-9*s, hy-3.2*s}, {cx-5*s, hy-2*s}}, {0.55,0.45})
  st(K, 1.3*s, {{cx+5*s, hy-2*s}, {cx+9*s, hy-3.2*s}, {cx+13*s, hy-2*s}}, {0.55,0.45})
  local ib = brush{kind="round", width=2.2*s, point=0.3}
  ib:reload(K, 0.9); ib:touch(cx-9*s, hy-1.5*s, {pressure=0.5}); ib:touch(cx+9*s, hy-1.5*s, {pressure=0.5})
  local cb = brush{kind="round", width=0.8, point=0.5}
  cb:reload(W, 0.8); cb:touch(cx-9.6*s, hy-2.2*s, {pressure=0.3})
  -- tired: a soft fold under each eye
  st(D, 1.0*s, {{cx-13*s, hy+2*s}, {cx-9*s, hy+3.2*s}, {cx-5*s, hy+2.2*s}}, {0.25,0.15}, 0.5)
  st(D, 1.0*s, {{cx+5*s, hy+2.2*s}, {cx+9*s, hy+3.2*s}, {cx+13*s, hy+2*s}}, {0.25,0.15}, 0.5)
  -- nose: shadow plane on the right, bridge light on the left, nostrils
  st(D, 2.2*s, {{cx+1.5*s, hy-1*s}, {cx+3*s, hy+6*s}, {cx+5*s, hy+11*s}}, {0.45,0.35})
  st(HL, 1.4*s, {{cx-1.5*s, hy}, {cx-1.6*s, hy+6*s}, {cx-1*s, hy+10*s}}, {0.35,0.2}, 0.6)
  st(K, 1.2*s, {{cx-4*s, hy+12.5*s}, {cx-1*s, hy+13.5*s}}, {0.4,0.3}); st(K, 1.2*s, {{cx+2*s, hy+13.5*s}, {cx+5*s, hy+12.5*s}}, {0.4,0.3})
  -- mouth, the corners lifting a little; a lip shadow under it
  if f.hair ~= "bald" then
    st(pile{{"red earth",1},{"bone brown",0.8}}, 1.3*s, {{cx-7*s, hy+18.5*s}, {cx-3*s, hy+19.6*s}, {cx+3*s, hy+19.6*s}, {cx+7.5*s, hy+18.3*s}}, {0.5,0.4})
    st(D, 1.6*s, {{cx-3*s, hy+22.5*s}, {cx+4*s, hy+22.5*s}}, {0.3,0.2}, 0.5)
  else
    st(pile{{"red earth",1},{"lead white",0.3}}, 1.3*s, {{cx-6*s, hy+17*s}, {cx, hy+18*s}, {cx+6*s, hy+17*s}}, {0.45,0.35})
  end
  -- the lit cheek
  local ck = ellipse(cx-12*s, hy+7*s, 4*s, 4*s)
  work(ck, {hand="detail", tool={kind="round", width=1.5}, pile=HL, coverage=1.2, fill=false, clip=ck, pressure={0.2,0.4}})
  -- coverall collar at the neck
  local col = poly({{cx-16*s, hy+40*s}, {cx, hy+56*s}, {cx+16*s, hy+40*s}, {cx+22*s, hy+46*s}, {cx, hy+64*s}, {cx-22*s, hy+46*s}})
  work(col, {hand="detail", tool={kind="round", width=1.6}, pile=pile{{"ultramarine blue",1},{"bone black",1}}, coverage=4, fill=true, clip=col})
end

--@ chunk 8
print(wait(2*24*60))
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  blend(ellipse(cx-12*s, hy+7*s, 6*s, 6*s), {tool={kind="badger", width=2*s}})
  blend(ellipse(cx+9*s, hy-2*s, 8*s, 5.5*s), {tool={kind="badger", width=2*s}})
end
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
local REF = pile{{"lead white",1.5},{"ultramarine ash",0.6},{"bone black",0.15}}
local REFD = pile{{"lead white",0.6},{"ultramarine ash",0.8},{"bone black",0.5}}
local AMB = pile{{"chrome yellow",1},{"Mars orange",0.6},{"bone brown",0.15}}
local YB = pile{{"lemon chrome",1},{"chrome yellow",0.6},{"lead white",0.3}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local cov = CRATE
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  local body = (f.P.torso + f.P.armL + f.P.armR) - cov - f.P.head - f.P.neck
  for _,yy in ipairs({hy+100*s, hy+136*s}) do
    local band = body * rect(cx-80*s, yy, 160*s, 6*s)
    local bl = band * mask(function(x,y) return (x < cx - 10*s) and 1 or 0 end)
    fill(bl, f.jacket and YB or REF, 1.5)
    fill(band - bl, f.jacket and pile{{"chrome yellow",1},{"bone brown",0.4}} or REFD, 1.5)
  end
  local patch = rect(cx-46*s, hy+68*s, 14*s, 10*s) - cov
  fill(patch, AMB, 1.2)
end
-- hands and what they hold
local function hand(f, x, y)
  local s = f.s
  local h = ellipse(x, y, 7*s, 5.5*s)
  fill(h * mask(function(xx,yy) return (xx < x) and 1 or 0 end), SK[f.skin].L, 1.2)
  fill(h * mask(function(xx,yy) return (xx >= x) and 1 or 0 end), SK[f.skin].D, 1.2)
end
-- the mug
local f = F[4]
local mx, my = f.cx + 5, f.hy + 112
fill(rect(mx-10, my-14, 20, 24), pile{{"lead white",2},{"cerulean blue",0.2}}, 1.5)
fill(rect(mx+3, my-14, 7, 24), pile{{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.3}}, 1)
fill(ellipse(mx, my-14, 10, 2.6), pile{{"bone brown",1},{"bone black",0.4}}, 1)
hand(f, mx-12, my+2); hand(f, mx+13, my+4)
-- the clipboard
f = F[2]
local bx, by = f.cx, f.hy + 125
fill(rect(bx-26, by-34, 52, 66), pile{{"burnt sienna",1},{"yellow ochre",0.5}}, 2)
fill(rect(bx-22, by-28, 44, 56), pile{{"lead white",2},{"yellow ochre",0.1}}, 1.5)
fill(rect(bx-9, by-38, 18, 7), pile{{"bone black",1},{"lead white",0.4}}, 1)
local lb = brush{kind="round", width=0.9, point=0.4}
for k=0,7 do lb:reload(pile{{"bone black",1.5}}, 0.7); lb:stroke({{bx-18, by-20+k*6}, {bx+((k%3==0) and 6 or 16), by-20+k*6}}, {pressure={0.35,0.3}}) end
hand(f, bx-27, by+20); hand(f, bx+27, by+22)
-- the watering can on the knee
f = F[7]
local wx, wy = f.cx - 10, f.hy + 196
local CAN = pile{{"chrome yellow",2},{"cadmium yellow",0.8},{"lead white",0.3}}
local CAND = pile{{"Mars orange",1},{"chrome yellow",0.5},{"bone brown",0.4}}
fill(rect(wx-22, wy-20, 44, 36), CAN, 2)
fill(rect(wx+8, wy-20, 14, 36), CAND, 1.5)
fill(ellipse(wx, wy-20, 22, 4), CAND, 1.2)
local sb = brush{kind="round", width=4.5, point=0.2}
sb:reload(CAN, 0.9); sb:stroke({{wx-20, wy+8}, {wx-40, wy-12}, {wx-50, wy-24}}, {pressure={0.8,0.6}})
fill(ellipse(wx-52, wy-26, 5, 3), CAND, 1)
sb:reload(CAN, 0.9); sb:stroke({{wx+20, wy-14}, {wx+32, wy-4}, {wx+22, wy+12}}, {pressure={0.6,0.6}})
hand(f, wx+28, wy+2); hand(f, wx-8, wy-24)
-- the two behind the crate rest their hands on it
for _,j in ipairs({5,6}) do local g = F[j]; hand(g, g.cx - 26, 446); hand(g, g.cx + 22, 448) end
hand(F[1], F[1].cx - 10, F[1].hy + 168); hand(F[3], F[3].cx + 12, F[3].hy + 172)

--@ chunk 9
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
-- the crate's mark: blue hexagon, white chevron, a stencilled code
local BLU = pile{{"cobalt blue",1},{"ultramarine blue",0.5},{"lead white",0.2}}
local c = {420, 525}
local hex = {}
for k=0,5 do local a = math.pi/6 + k*math.pi/3; hex[#hex+1] = {c[1] + 34*math.cos(a), c[2] + 34*math.sin(a)} end
fill(poly(hex), BLU, 2)
fill(poly({{c[1]-18, c[2]+4}, {c[1], c[2]-14}, {c[1]+18, c[2]+4}, {c[1]+18, c[2]+14}, {c[1], c[2]-4}, {c[1]-18, c[2]+14}}), pile{{"zinc white",2},{"lead white",1}}, 1.2)
local tb = brush{kind="round", width=3, point=0.2}
for k=0,4 do tb:reload(pile{{"bone black",1.4},{"bone brown",0.4}}, 0.8); tb:stroke({{480 + k*24, 510}, {480 + k*24 + ((k%2==0) and 14 or 8), 510}, {480 + k*24 + 10, 538}}, {pressure={0.6,0.6}}) end
-- hands resting on the crate, larger, with fingers over its edge
for _,j in ipairs({5,6}) do
  local g = F[j]
  for _,hx in ipairs({g.cx - 26, g.cx + 22}) do
    local h = ellipse(hx, 450, 12, 7)
    fill(h * mask(function(x,y) return (x < hx) and 1 or 0 end), SK[g.skin].L, 1.5)
    fill(h * mask(function(x,y) return (x >= hx) and 1 or 0 end), SK[g.skin].M, 1.5)
    local fb = brush{kind="round", width=2.4, point=0.4}
    for k=0,3 do fb:reload(SK[g.skin].D, 0.7); fb:stroke({{hx-8+k*5, 452}, {hx-8+k*5.2, 461}}, {pressure={0.5,0.3}}) end
  end
end
-- the caption strip, written by hand
local STRIP = rect(60, 618, 880, 38)
fill(STRIP, pile{{"lead white",2},{"yellow ochre",0.35},{"bone brown",0.08}}, 4)

--@ chunk 10
print(wait(2*24*60))
local INK = pile{{"bone black",1.4},{"ultramarine blue",0.3}}
local b = brush{kind="round", width=1.3, point=0.8}
local x = 80
local w = 0
while x < 910 do
  local L = rand(18, 60)
  local pts = {}
  local n = math.floor(L/3)
  for k=0,n do
    local t = k/n
    pts[#pts+1] = {x + L*t, 637 + 4.5*math.sin(t*n*1.9 + x) + rand(-0.6,0.6) - 3*math.max(0, math.sin(t*7+x))^4}
  end
  b:reload(INK, 0.7); b:stroke(pts, {pressure={0.5,0.35}})
  if math.random() < 0.3 then b:reload(INK, 0.6); b:stroke({{x + rand(2,6), 628}, {x + rand(2,6), 642}}, {pressure={0.45,0.3}}) end
  x = x + L + rand(8, 18)
  w = w + 1
  if w == 3 or w == 9 then x = x + 22 end
end
-- tacks at the corners of the photo
local tk = brush{kind="round", width=5, point=0.2}
for _,p in ipairs({{12,12},{988,12},{12,655},{988,655}}) do tk:reload(pile{{"vermilion",1},{"lead white",0.3}}, 0.9); tk:touch(p[1], p[2], {pressure=0.6}) end

--@ chunk 11
print(wait(24*60))
local DEEP = pile{{"ultramarine blue",1},{"bone black",1.3},{"burnt sienna",0.3}}
local WARM = pile{{"lead white",1.5},{"yellow ochre",0.6},{"Mars orange",0.15}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local cov = CRATE + rect(0, 610, 1000, 60)
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  local body = (f.P.torso + f.P.armL + f.P.armR + (f.P.legs or mask(function() return 0 end))) - f.P.head - f.P.neck - cov
  local keep = rect(cx-80*s, hy+98*s, 160*s, 10*s) + rect(cx-80*s, hy+134*s, 160*s, 10*s) + rect(cx-48*s, hy+66*s, 18*s, 14*s)
  if f.prop == "mug" then keep = keep + rect(cx-25, hy+90, 60, 40) end
  if f.prop == "clip" then keep = keep + rect(cx-40, hy+85, 80, 80) end
  if f.prop == "can" then keep = keep + rect(cx-80, hy+160, 130, 70) end
  local sh = body * mask(function(x,y) return (x > cx + 26*s) and 1 or 0 end) - keep:grow(1)
  work(sh, {hand="body", tool={kind="filbert", width=4*s}, pile=DEEP, coverage=4, fill=true, clip=sh, angle=1.5708, length={10,30}})
  -- warm work-light along the contour that faces the lamp
  local sil = f.sil - cov
  local edge = sil * mask(function(x,y) return (x < cx and f.sil:at(x - 2.2, y) < 0.5) and 1 or 0 end) - f.P.head:grow(1)
  work(edge, {hand="detail", tool={kind="round", width=1.2}, pile=WARM, coverage=3, fill=true, clip=edge})
  local hedge = f.P.head * mask(function(x,y) return (x < cx and f.P.head:at(x - 1.8, y) < 0.5) and 1 or 0 end) - cov
  work(hedge, {hand="detail", tool={kind="round", width=1.0}, pile=pile{{"lead white",2},{"yellow ochre",0.4},{"red earth",0.1}}, coverage=3, fill=true, clip=hedge})
end

--@ chunk 12
print(wait(2*24*60))
-- workwear navy: Payne's grey mixed from bone black, a little ultramarine and umber
local NL = pile{{"bone black",1},{"ultramarine blue",0.45},{"lead white",0.55},{"bone brown",0.2}}
local NM = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.28},{"bone brown",0.25}}
local ND = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"bone brown",0.45},{"lead white",0.06}}
local JM = pile{{"bone black",1},{"ultramarine blue",0.7},{"lead white",0.2}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local cov = CRATE + rect(0, 612, 1000, 60)
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  local body = (f.P.torso + f.P.armL + f.P.armR + (f.P.legs or mask(function() return 0 end))) - f.P.head - f.P.neck - cov
  local keep = rect(cx-80*s, hy+98*s, 160*s, 10*s) + rect(cx-80*s, hy+134*s, 160*s, 10*s) + rect(cx-48*s, hy+66*s, 18*s, 14*s)
  if f.prop == "mug" then keep = keep + rect(cx-25, hy+90, 60, 40) end
  if f.prop == "clip" then keep = keep + rect(cx-40, hy+85, 80, 80) end
  if f.prop == "can" then keep = keep + rect(cx-80, hy+160, 130, 70) end
  body = body - keep:grow(0.5)
  local col = poly({{cx-16*s, hy+40*s}, {cx, hy+56*s}, {cx+16*s, hy+40*s}, {cx+22*s, hy+46*s}, {cx, hy+64*s}, {cx-22*s, hy+46*s}})
  body = body - col
  local lit = body * mask(function(x,y) return (x < cx - 32*s) and 1 or 0 end)
  local dark = body * mask(function(x,y) return (x > cx + 12*s) and 1 or 0 end)
  local mid = body - lit - dark
  local t = {kind="filbert", width=4*s}
  local L, M = NL, NM
  if f.jacket then L, M = JM, JM end
  work(lit, {hand="body", tool=t, pile=L, coverage=4.5, fill=true, clip=body, angle=1.5708, length={10,30}})
  work(mid, {hand="body", tool=t, pile=M, coverage=4.5, fill=true, clip=body, angle=1.5708, length={10,30}})
  work(dark, {hand="body", tool=t, pile=ND, coverage=4.5, fill=true, clip=body, angle=1.5708, length={10,30}})
  blend(body * (rect(cx-38*s, 0, 12*s, H) + rect(cx+6*s, 0, 12*s, H)), {angle=1.5708, tool={kind="badger", width=4*s}})
end
-- the crate in warm grey, darker than any face
local CF1 = pile{{"bone black",0.8},{"lead white",0.7},{"burnt sienna",0.25},{"yellow ochre",0.25}}
local CF2 = pile{{"bone black",1},{"lead white",0.45},{"burnt sienna",0.25},{"yellow ochre",0.15}}
local CT = pile{{"bone black",0.6},{"lead white",0.8},{"burnt sienna",0.2},{"yellow ochre",0.3}}
local hands = ellipse(349,452,16,10) + ellipse(397,452,16,10) + ellipse(549,452,16,10) + ellipse(597,452,16,10)
local front = CRATE_F
work(front * rect(0,0,480,H), {hand="body", tool={kind="filbert", width=7}, pile=CF1, coverage=4.5, fill=true, clip=front, angle=0})
work(front - rect(0,0,480,H), {hand="body", tool={kind="filbert", width=7}, pile=CF2, coverage=4.5, fill=true, clip=front, angle=0})
blend(front * rect(455,0,50,H), {angle=0, tool={kind="badger", width=8}})
work(CRATE_T - hands, {hand="body", tool={kind="filbert", width=5}, pile=CT, coverage=4.5, fill=true, clip=CRATE_T, angle=0})

--@ chunk 13
print(wait(24*60))
local NL = pile{{"bone black",1},{"ultramarine blue",0.45},{"lead white",0.55},{"bone brown",0.2}}
local NM = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.28},{"bone brown",0.25}}
local ND = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"bone brown",0.45},{"lead white",0.06}}
local JM = pile{{"bone black",1},{"ultramarine blue",0.7},{"lead white",0.2}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local cov = CRATE + rect(0, 612, 1000, 60)
  if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
  local body = (f.P.torso + f.P.armL + f.P.armR + (f.P.legs or mask(function() return 0 end))) - f.P.head - f.P.neck - cov
  local keepOld = rect(cx-80*s, hy+98*s, 160*s, 10*s) + rect(cx-80*s, hy+134*s, 160*s, 10*s) + rect(cx-48*s, hy+66*s, 18*s, 14*s)
  if f.prop == "mug" then keepOld = keepOld + rect(cx-25, hy+90, 60, 40) end
  if f.prop == "clip" then keepOld = keepOld + rect(cx-40, hy+85, 80, 80) end
  if f.prop == "can" then keepOld = keepOld + rect(cx-80, hy+160, 130, 70) end
  local real = rect(cx-80*s, hy+100*s, 160*s, 6*s) + rect(cx-80*s, hy+136*s, 160*s, 6*s) + rect(cx-46*s, hy+68*s, 14*s, 10*s)
  if f.prop == "mug" then local mx, my = cx+5, hy+112; real = real + rect(mx-12, my-17, 25, 30) + ellipse(mx-12, my+2, 8, 6.5) + ellipse(mx+13, my+4, 8, 6.5) end
  if f.prop == "clip" then local bx, by = cx, hy+125; real = real + rect(bx-27, by-39, 54, 73) + ellipse(bx-27, by+20, 8, 6.5) + ellipse(bx+27, by+22, 8, 6.5) end
  if f.prop == "can" then local wx, wy = cx-10, hy+196; real = real + rect(wx-23, wy-25, 46, 42) + ribbon({{wx-20, wy+8}, {wx-40, wy-12}, {wx-52, wy-26}}, 8) + ribbon({{wx+20, wy-14}, {wx+32, wy-4}, {wx+22, wy+12}}, 7) + ellipse(wx+28, wy+2, 8, 6.5) + ellipse(wx-8, wy-24, 8, 6.5) end
  local fix = (keepOld:grow(0.8) - real) * body
  if fix:area() > 1 then
    local lit = fix * mask(function(x,y) return (x < cx - 32*s) and 1 or 0 end)
    local dark = fix * mask(function(x,y) return (x > cx + 12*s) and 1 or 0 end)
    local mid = fix - lit - dark
    local L, M = NL, NM
    if f.jacket then L, M = JM, JM end
    for _,pr in ipairs({{lit, L}, {mid, M}, {dark, ND}}) do
      if pr[1]:area() > 0.5 then work(pr[1], {hand="detail", tool={kind="filbert", width=2}, pile=pr[2], coverage=4.5, fill=true, clip=pr[1], angle=0}) end
    end
  end
end

--@ chunk 14
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m}) end end
-- the crate's mark, small and worn into the grey
local BLU = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.3}}
local c = {330, 500}
local hex = {}
for k=0,5 do local a = math.pi/6 + k*math.pi/3; hex[#hex+1] = {c[1] + 14*math.cos(a), c[2] + 14*math.sin(a)} end
fill(poly(hex), BLU, 1.2)
fill(poly({{c[1]-7, c[2]+2}, {c[1], c[2]-5}, {c[1]+7, c[2]+2}, {c[1]+7, c[2]+6}, {c[1], c[2]-1}, {c[1]-7, c[2]+6}}), pile{{"lead white",1.5},{"bone black",0.2}}, 1)
local tb = brush{kind="round", width=1.4, point=0.3}
for k=0,3 do tb:reload(pile{{"bone black",1.4},{"bone brown",0.4}}, 0.7); tb:stroke({{352 + k*10, 494}, {352 + k*10 + 6, 494}, {352 + k*10 + 4, 506}}, {pressure={0.5,0.5}}) end
-- faces: warmer lit planes, warm cheek and ear, deeper sockets with a glint, and each its own expression
local EXP = {"smile", "kind", "tight", "grin", "tired", "half", "smile"}
local K = pile{{"bone brown",1},{"bone black",0.8}}
for i,f in ipairs(F) do
  local s, cx, hy = f.s, f.cx, f.hy
  local sk = SK[f.skin]
  local WL = pile{{"lead white",1.6},{"yellow ochre",0.45},{"red earth",0.25}}
  if f.skin == 3 then WL = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.6},{"red earth",0.2}} end
  if f.skin == 2 then WL = pile{{"yellow ochre",1},{"lead white",1.1},{"red earth",0.35}} end
  local CHK = pile{{"red earth",1},{"lead white",0.6},{"vermilion",0.15}}
  local function st(p, w, pts, pr, load) local b = brush{kind="round", width=w, point=0.6}; b:reload(p, load or 0.8); b:stroke(pts, {pressure=pr or {0.5,0.3}}) end
  -- lit forehead and cheekbone planes
  st(WL, 3.2*s, {{cx-14*s, hy-15*s}, {cx-7*s, hy-18*s}, {cx, hy-17*s}}, {0.5,0.3}, 0.7)
  st(WL, 2.6*s, {{cx-17*s, hy+4*s}, {cx-15*s, hy+10*s}, {cx-11*s, hy+14*s}}, {0.45,0.25}, 0.7)
  st(WL, 1.6*s, {{cx-1.8*s, hy+1*s}, {cx-1.6*s, hy+9*s}}, {0.4,0.2}, 0.7)
  -- warmth in cheek and ear
  st(CHK, 2.4*s, {{cx-14*s, hy+8*s}, {cx-10*s, hy+11*s}}, {0.25,0.1}, 0.4)
  st(CHK, 2.0*s, {{cx+11*s, hy+8*s}, {cx+14*s, hy+11*s}}, {0.2,0.1}, 0.35)
  if f.hair ~= "red" then st(CHK, 2*s, {{cx-22*s, hy-2*s}, {cx-22*s, hy+5*s}}, {0.35,0.2}, 0.5) end
  -- sockets deeper, lids, irises, a glint in each eye
  st(sk.D, 2.6*s, {{cx-13*s, hy-4.5*s}, {cx-9*s, hy-5.5*s}, {cx-5*s, hy-4.5*s}}, {0.4,0.3}, 0.6)
  st(sk.D, 2.8*s, {{cx+5*s, hy-4.5*s}, {cx+9*s, hy-5.5*s}, {cx+13*s, hy-4.5*s}}, {0.5,0.35}, 0.7)
  local tired = (EXP[i] == "tired" or EXP[i] == "kind")
  st(K, 1.3*s, {{cx-13*s, hy-2*s}, {cx-9*s, hy-(tired and 2.6 or 3.2)*s}, {cx-5*s, hy-2*s}}, {0.55,0.45})
  st(K, 1.3*s, {{cx+5*s, hy-2*s}, {cx+9*s, hy-(tired and 2.6 or 3.2)*s}, {cx+13*s, hy-2*s}}, {0.55,0.45})
  local ib = brush{kind="round", width=2.2*s, point=0.3}
  ib:reload(K, 0.9); ib:touch(cx-9*s, hy-1.4*s, {pressure=0.5}); ib:touch(cx+9*s, hy-1.4*s, {pressure=0.5})
  local g = brush{kind="round", width=0.7, point=0.5}
  g:reload(pile{{"zinc white",2}}, 0.8); g:touch(cx-9.7*s, hy-2.1*s, {pressure=0.3}); g:touch(cx+8.3*s, hy-2.1*s, {pressure=0.22})
  -- the mouth: each a different tired fondness
  local LIP = pile{{"red earth",1},{"bone brown",0.7}}
  local e = EXP[i]
  local m
  if e == "smile" then m = {{cx-8*s, hy+17.5*s}, {cx-3*s, hy+19.8*s}, {cx+3*s, hy+19.8*s}, {cx+8*s, hy+17.3*s}}
  elseif e == "grin" then m = {{cx-9*s, hy+17*s}, {cx-3*s, hy+20.5*s}, {cx+3*s, hy+20.5*s}, {cx+9*s, hy+16.8*s}}
  elseif e == "tight" then m = {{cx-6*s, hy+19*s}, {cx, hy+19.3*s}, {cx+6*s, hy+18.8*s}}
  elseif e == "half" then m = {{cx-6*s, hy+19.4*s}, {cx, hy+19.6*s}, {cx+5*s, hy+18.8*s}, {cx+8*s, hy+17.2*s}}
  elseif e == "tired" then m = {{cx-7*s, hy+19*s}, {cx, hy+19.6*s}, {cx+7*s, hy+18.6*s}}
  else m = {{cx-7*s, hy+18.2*s}, {cx, hy+19.6*s}, {cx+7*s, hy+18.2*s}} end
  st(LIP, 1.4*s, m, {0.55,0.45})
  if e == "grin" then st(pile{{"lead white",1.5},{"yellow ochre",0.2}}, 1.2*s, {{cx-4*s, hy+19.2*s}, {cx+4*s, hy+19.2*s}}, {0.35,0.3}, 0.6) end
  if e == "tired" or e == "kind" or e == "smile" then
    st(sk.D, 1.0*s, {{cx-8*s, hy+9*s}, {cx-10*s, hy+15*s}, {cx-9.5*s, hy+18*s}}, {0.25,0.1}, 0.5)
    st(sk.D, 1.0*s, {{cx+8*s, hy+9*s}, {cx+10*s, hy+15*s}, {cx+9.5*s, hy+18*s}}, {0.3,0.1}, 0.5)
  end
  if e == "tired" or e == "kind" then
    st(sk.D, 0.9*s, {{cx+14*s, hy-1*s}, {cx+17*s, hy+1*s}}, {0.2,0.1}, 0.5)
    st(sk.D, 0.9*s, {{cx-14*s, hy-1*s}, {cx-17*s, hy+1*s}}, {0.2,0.1}, 0.5)
  end
end

--@ chunk 15
print(wait(24*60))
-- hands: on the crate edge, fingers curled over it; round the mug
local function hand_on_edge(sk, hx, left)
  local L, M, D = sk.L, sk.M, sk.D
  local back = ellipse(hx, 452, 11, 6.5)
  work(back * mask(function(x,y) return (x < hx - 2) and 1 or 0 end), {hand="detail", tool={kind="round", width=1.6}, pile=L, coverage=4.5, fill=true, clip=back})
  work(back * mask(function(x,y) return (x >= hx - 2) and 1 or 0 end), {hand="detail", tool={kind="round", width=1.6}, pile=M, coverage=4.5, fill=true, clip=back})
  local fb = brush{kind="round", width=3.6, point=0.4}
  for k=0,3 do
    local x0 = hx - 8 + k*5.3
    fb:reload((k < 2) and L or M, 0.9)
    fb:stroke({{x0, 454}, {x0 + 0.5, 462}, {x0 + 0.3, 470}}, {pressure={0.65,0.45}})
    local kb = brush{kind="round", width=0.9, point=0.6}
    kb:reload(D, 0.7); kb:stroke({{x0 + 1.7, 456}, {x0 + 1.9, 469}}, {pressure={0.35,0.2}})
  end
  local tb = brush{kind="round", width=3.4, point=0.5}
  local tx = left and (hx + 11) or (hx - 11)
  tb:reload(M, 0.9); tb:stroke({{hx + (left and 5 or -5), 450}, {tx, 452}, {tx + (left and 3 or -3), 456}}, {pressure={0.6,0.4}})
  local sh = brush{kind="round", width=2.2, point=0.4}
  sh:reload(pile{{"bone black",1},{"bone brown",0.6}}, 0.7); sh:stroke({{hx - 9, 471.5}, {hx + 11, 471.5}}, {pressure={0.4,0.4}})
end
hand_on_edge(SK[F[5].skin], 349, true); hand_on_edge(SK[F[5].skin], 397, false)
hand_on_edge(SK[F[6].skin], 549, true); hand_on_edge(SK[F[6].skin], 597, false)
-- round the mug: two hands, fingers wrapped across its body
local sk = SK[F[4].skin]
local mx, my = F[4].cx + 5, F[4].hy + 112
local fb = brush{kind="round", width=3.4, point=0.4}
for k=0,3 do
  fb:reload(sk.L, 0.9); fb:stroke({{mx - 15, my - 8 + k*4.5}, {mx - 9, my - 7 + k*4.5}, {mx - 4, my - 6 + k*4.5}}, {pressure={0.6,0.4}})
  fb:reload(sk.M, 0.9); fb:stroke({{mx + 16, my - 6 + k*4.5}, {mx + 10, my - 5 + k*4.5}, {mx + 6, my - 4 + k*4.5}}, {pressure={0.6,0.4}})
end
local kb = brush{kind="round", width=0.8, point=0.6}
for k=0,2 do kb:reload(sk.D, 0.7); kb:stroke({{mx - 13, my - 5.5 + k*4.5}, {mx - 5, my - 4 + k*4.5}}, {pressure={0.3,0.2}}) end
local tb = brush{kind="round", width=3.6, point=0.5}
tb:reload(sk.L, 0.9); tb:stroke({{mx - 15, my - 12}, {mx - 9, my - 15}, {mx - 4, my - 15}}, {pressure={0.6,0.4}})

--@ chunk 16
print(wait(24*60))
local NM = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.28},{"bone brown",0.25}}
local NL = pile{{"bone black",1},{"ultramarine blue",0.45},{"lead white",0.55},{"bone brown",0.2}}
local ND = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"bone brown",0.45},{"lead white",0.06}}
-- forearms reaching from the body over the crate's back edge to each hand
for _,j in ipairs({5,6}) do
  local g = F[j]
  for k,hx in ipairs({g.cx - 26, g.cx + 22}) do
    local sx = (k == 1) and (g.cx - 48) or (g.cx + 46)
    local arm = ribbon({{sx, 400}, {(sx + hx)/2, 428}, {hx, 448}}, {17, 16, 14}) - ellipse(hx, 452, 11, 6.5):shrink(1)
    local p = (k == 1) and NL or ND
    work(arm, {hand="detail", tool={kind="filbert", width=2.5}, pile=p, coverage=4.5, fill=true, clip=arm, angle=1.0})
    local cuff = ribbon({{hx - 9, 445}, {hx + 9, 445}}, 3.5)
    work(cuff, {hand="detail", tool={kind="round", width=1.4}, pile=NM, coverage=4.5, fill=true, clip=cuff})
  end
end
-- the mug hands: same treatment, sleeves coming in from each side
local f = F[4]
local mx, my = f.cx + 5, f.hy + 112
for _,a in ipairs({{f.cx - 50, my + 30, mx - 14, my + 2, NL}, {f.cx + 50, my + 34, mx + 15, my + 4, ND}}) do
  local arm = ribbon({{a[1], a[2]}, {a[3], a[4] + 4}}, {16, 12})
  work(arm, {hand="detail", tool={kind="filbert", width=2.5}, pile=a[5], coverage=3.5, fill=true, clip=arm, angle=0.5})
end

--@ chunk 17
local BL = pile{{"lead white",0.8},{"bone black",0.7},{"ultramarine ash",0.5},{"yellow ochre",0.1}}
local BD = pile{{"lead white",0.3},{"bone black",0.9},{"ultramarine ash",0.5}}
for i,f in ipairs(F) do
  if not f.jacket then
    local s, cx, hy = f.s, f.cx, f.hy
    local cov = CRATE
    if f.row == "back" then cov = cov + F[5].sil + F[6].sil + F[4].sil + F[7].sil end
    local body = (f.P.torso + f.P.armL + f.P.armR) - f.P.head - f.P.neck - cov
    local excl = mask(function() return 0 end)
    if f.prop == "mug" then local mx, my = cx+5, hy+112; excl = rect(mx-30, my-20, 60, 34) end
    if f.prop == "clip" then local bx, by = cx, hy+125; excl = rect(bx-36, by-40, 72, 80) end
    if j == 5 or i == 5 or i == 6 then excl = excl + ribbon({{cx-48, 400}, {cx-26, 448}}, 18) + ribbon({{cx+46, 400}, {cx+22, 448}}, 18) end
    for _,yy in ipairs({hy+100*s, hy+136*s}) do
      local band = body * rect(cx-80*s, yy - 0.5, 160*s, 7*s) - excl
      local bl = band * mask(function(x,y) return (x < cx - 10*s) and 1 or 0 end)
      if bl:area() > 0.3 then work(bl, {hand="detail", tool={kind="filbert", width=1.5}, pile=BL, coverage=4.5, fill=true, clip=bl}) end
      if (band - bl):area() > 0.3 then work(band - bl, {hand="detail", tool={kind="filbert", width=1.5}, pile=BD, coverage=4.5, fill=true, clip=band - bl}) end
    end
  end
end
