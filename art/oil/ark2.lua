-- easel session "ark2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.5, linen={16,13}, seed=7713,
  ground={
    {pile={{"lead white",4},{"bone black",0.25}}, um=90, apply="knife", texture=0.35},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"ultramarine blue",1.2},{"lead white",0.8}, medium=0.4}, um=22, apply="brush"},
  }}
-- the Ark: top face and front face
topQ  = poly({{60,300},{700,248},{820,418},{92,500}})
frontQ = poly({{92,500},{820,418},{828,520},{98,612}})
shellM = topQ + frontQ
-- the warm beam, falling from upper left
beamM = poly({{90,-10},{360,-10},{640,680},{300,680}}):soften(18)
dk1 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1}, medium=0.1}
dk2 = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}, medium=0.1}
work(everywhere() - shellM, {hand="broad", pile=dk1, coverage=2.6, fill=true, angle=0.3})

--@ chunk 2
shellCool = pile{{"lead white",2},{"ultramarine ash",1},{"bone black",0.3},{"cerulean blue",0.1}, medium=0.05}
shellWarm = pile{{"lead white",3},{"yellow ochre",0.5},{"cadmium yellow",0.2},{"raw sienna",0.1}, medium=0.05}
frontCool = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.6}, medium=0.05}
frontWarm = pile{{"lead white",1.6},{"yellow ochre",0.6},{"raw sienna",0.3},{"ultramarine ash",0.4}, medium=0.05}
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local topAng = math.atan(248 - 300, 700 - 60)
work(topQ - beamHard, {hand="broad", pile=shellCool, coverage=3, fill=true, clip=true, angle=topAng})
work(topQ * beamHard, {hand="broad", pile=shellWarm, coverage=3, fill=true, clip=true, angle=topAng})
work(frontQ - beamHard, {hand="body", pile=frontCool, coverage=3, fill=true, clip=true, angle=topAng, length={30,80}})
work(frontQ * beamHard, {hand="body", pile=frontWarm, coverage=3, fill=true, clip=true, angle=topAng, length={30,80}})

--@ chunk 3
print(wait(24*60))
shTop = pile{{"ultramarine ash",1},{"bone black",0.6},{"lead white",0.55},{"cerulean blue",0.08}, medium=0.05}
shFront = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.18}, medium=0.05}
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local topAng = math.atan(248 - 300, 700 - 60)
work(topQ - beamHard:grow(6), {hand="body", pile=shTop, coverage=3.2, fill=true, clip=true, angle=topAng, length={30,90}})
work(frontQ - beamHard:grow(6), {hand="body", pile=shFront, coverage=3.2, fill=true, clip=true, angle=topAng, length={30,90}})
-- the beam's edges on the shell: soft, a few units
local edges = (beamHard:grow(10) - beamHard:shrink(10)) * shellM
blend(edges, {angle=topAng, tool={kind="badger", width=10}})
-- the beam on the ground: rubble lit gold in a band either side of the shell
rockGold = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1},{"lead white",0.5}, medium=0.05}
local gb = (beamHard - shellM:grow(2))
stipple(gb, {pile=rockGold, width=4, coverage=0.9, cluster=0.6, pressure={0.3, 0.7}, drag={2, 0.4}})

--@ chunk 4
rockLit  = pile{{"burnt sienna",1},{"raw sienna",1},{"yellow ochre",0.6},{"bone brown",0.5}, medium=0.05}
rockSh   = pile{{"bone brown",2},{"ultramarine blue",0.8},{"bone black",0.6}, medium=0.05}
rockDim  = pile{{"bone black",1},{"Mars brown",1.5},{"ultramarine blue",0.5},{"lead white",0.15}, medium=0.05}
rockDim2 = pile{{"bone black",1},{"bone brown",1.5},{"burnt sienna",0.6}, medium=0.05}
local ex = shellM:grow(3)
local brushes = {}
for k = 1, 6 do brushes[k] = brush{kind="flat", width=3 + k * 1.3} end
local n = 0
for k = 1, 2600 do
  local x, y = rand(-10, 1010), rand(-10, 677)
  if ex:at(x, y) < 0.5 then
    local inb = beamM:at(x, y)
    local p
    local r = rand(0, 1)
    if inb > 0.5 then
      p = (r < 0.45) and rockGold or ((r < 0.75) and rockLit or rockSh)
    elseif inb > 0.1 then
      p = (r < 0.35) and rockLit or ((r < 0.7) and rockDim or rockSh)
    else
      p = (r < 0.15) and rockDim or ((r < 0.6) and rockDim2 or rockSh)
    end
    local s = clamp(math.floor(1 + (y / 667) * 5 + rand(-1, 1)), 1, 6)
    local b = brushes[s]
    b:load(p, rand(0.5, 0.9))
    b:touch(x, y, {pressure=rand(0.4, 0.8), drag={rand(2, 7), rand(-0.6, 0.6)}, angle=rand(-1, 1)})
    n = n + 1
  end
end
print(n)

--@ chunk 5
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local g = beamHard:grow(8) - shellM:grow(1)
local nearS = shellM:grow(55):soften(20)
work(g - nearS, {hand="body", pile=rockDim2, coverage=3, fill=true, clip=true, angle=1.15, length={20,50}})
work(g * nearS, {hand="body", pile=rockLit, coverage=3, fill=true, clip=true, angle=1.15, length={20,50}, threshold=0.4})

--@ chunk 6
gaunt  = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.3}, medium=0.05}
gaunt2 = pile{{"bone black",1.5},{"burnt sienna",1},{"raw sienna",0.4},{"ultramarine ash",0.3}, medium=0.05}
armM  = poly({{1012,28},{1012,168},{802,318},{734,214}})
cuffM = poly({{745,196},{722,214},{790,330},{818,312}})
backM = poly({{738,212},{800,320},{668,352},{612,262}})
-- fingers: tapered segmented ribbons from the knuckle line
fingers = {}
local kn = {{618,268},{636,296},{652,322},{666,346}}
local tips = {{486,300},{494,338},{506,374},{534,404}}
fingerM = nil
for i = 1, 4 do
  local k, t = kn[i], tips[i]
  local mid = {lerp(k[1], t[1], 0.5), lerp(k[2], t[2], 0.5) + 6}
  local f = ribbon({k, mid, t}, {17 - i * 0.6, 15 - i * 0.5, 11})
  fingers[i] = {k = k, m = mid, t = t, mask = f}
  fingerM = fingerM and (fingerM + f) or f
end
thumbM = ribbon({{770,322},{735,372},{690,398}}, {24, 19, 14})
handM = armM + cuffM + backM + fingerM + thumbM
work(armM + cuffM, {hand="body", pile=gaunt2, coverage=3.4, fill=true, clip=true, angle=math.atan(-140, 210), length={20,60}})
work(backM + fingerM + thumbM, {hand="detail", pile=gaunt, coverage=4, fill=true, angle=2.8})

--@ chunk 7
fingerM2 = nil
for i = 1, 4 do
  local f = fingers[i]
  local m = ribbon({f.k, f.m, f.t}, {28 - i, 25 - i, 19 - i * 0.5})
  fingerM2 = fingerM2 and (fingerM2 + m) or m
end
thumbM2 = ribbon({{775,318},{738,372},{694,400}}, {34, 28, 21})
backM2 = poly({{742,206},{806,322},{680,362},{604,256}})
work(fingerM2 + thumbM2 + backM2, {hand="detail", pile=gaunt, coverage=4, fill=true, angle=2.8})
-- the vambrace in dark bronze, banded plates
vamb = pile{{"bone black",1.6},{"burnt sienna",0.9},{"ultramarine blue",0.4}, medium=0.05}
work(armM + cuffM, {hand="body", pile=vamb, coverage=3.6, fill=true, clip=true, angle=math.atan(-140, 210), length={20,50}})
handM2 = armM + cuffM + backM2 + fingerM2 + thumbM2

--@ chunk 8
print(wait(3*24*60))
rimC  = pile{{"lead white",1},{"ultramarine ash",1},{"bone black",0.4}}
rimW  = pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.5}}
gold  = pile{{"lead white",3},{"Indian yellow",1},{"cadmium yellow",0.5}}
seamD = pile{{"bone black",2},{"ultramarine blue",0.5}}
bone  = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local thin = brush{kind="round", width=1.6, point=0.7}
local fat  = brush{kind="round", width=2.6, point=0.5}
local function perp(a, b, t, half)
  local x, y = lerp(a[1], b[1], t), lerp(a[2], b[2], t)
  local dx, dy = b[1] - a[1], b[2] - a[2]
  local n = math.sqrt(dx*dx + dy*dy)
  local px, py = -dy / n, dx / n
  return {x + px * half, y + py * half}, {x - px * half, y - py * half}
end
for i = 1, 4 do
  local f = fingers[i]
  local w = (26 - i) / 2
  -- joint seams across each finger, with a lit lip on the knuckle side
  for _, t in ipairs({0.33, 0.66}) do
    local a1, a2 = perp(f.k, f.t, t, w - 1)
    fat:load(seamD, 0.9); fat:stroke({a1, a2}, {pressure={0.6, 0.6}})
    local b1, b2 = perp(f.k, f.t, t - 0.035, w - 2)
    thin:load(rimC, 0.6); thin:stroke({b1, b2}, {pressure={0.35, 0.35}})
  end
  -- a cool top edge along the finger
  local e1 = perp(f.k, f.t, 0.05, w - 2)
  local e2 = perp(f.k, f.t, 0.9, w - 3)
  thin:load(rimC, 0.6); thin:stroke({e1, e2}, {pressure={0.3, 0.45}})
  -- the beam just reaches the fingertips: gold on the nails
  local g1, g2 = perp(f.k, f.t, 0.93, w - 3)
  local gb = brush{kind="round", width=3.5, point=0.5}
  gb:load(gold, 0.9); gb:stroke({g1, {f.t[1] - 3, f.t[2] + 1}, g2}, {pressure={0.6, 0.4}})
end
-- knuckle guard
thin:load(rimC, 0.7)
thin:stroke({{612,250},{640,300},{668,344}}, {pressure={0.5, 0.5}})
fat:load(seamD, 0.9); fat:stroke({{618,262},{646,310},{676,352}}, {pressure={0.7, 0.7}})
-- vambrace plate bands
for _, t in ipairs({0.2, 0.45, 0.7}) do
  local a = {lerp(1012, 734, t), lerp(28, 214, t)}
  local b = {lerp(1012, 802, t), lerp(168, 318, t)}
  fat:load(seamD, 0.9); fat:stroke({a, b}, {pressure={0.8, 0.8}})
  thin:load(rimW, 0.6); thin:stroke({{a[1] + 4, a[2] - 2}, {b[1] + 4, b[2] - 2}}, {pressure={0.35, 0.3}})
end
-- the bone cross inlaid on the vambrace
local cx, cy = 905, 125
local cb = brush{kind="flat", width=7}
cb:load(bone, 0.95); cb:stroke({{cx + 22, cy - 34}, {cx - 20, cy + 36}}, {pressure={0.8, 0.8}})
cb:load(bone, 0.95); cb:stroke({{cx - 26, cy - 6}, {cx + 24, cy + 2}}, {pressure={0.8, 0.8}})

--@ chunk 9
local function bil(Q, u, v)
  local a = {lerp(Q[1][1], Q[2][1], u), lerp(Q[1][2], Q[2][2], u)}
  local b = {lerp(Q[4][1], Q[3][1], u), lerp(Q[4][2], Q[3][2], u)}
  return {lerp(a[1], b[1], v), lerp(a[2], b[2], v)}
end
TQ = {{60,300},{700,248},{820,418},{92,500}}
FQ = {{92,500},{820,418},{828,520},{98,612}}
function quadUV(Q, u1, u2, v1, v2) return poly({bil(Q,u1,v1), bil(Q,u2,v1), bil(Q,u2,v2), bil(Q,u1,v2)}) end
bil_ = bil
-- faded red band round the shell
redF = pile{{"vermilion",1},{"lead white",0.5},{"ultramarine ash",0.35},{"bone black",0.1}}
local band = quadUV(TQ, 0.07, 0.12, 0, 1) + quadUV(FQ, 0.07, 0.12, 0, 1)
work(band, {hand="detail", pile=redF, coverage=3.5, fill=true, angle=1.4})
-- stencilled lettering across the lit top: SEED VAULT 07
local font = {
  S={"111","100","111","001","111"}, E={"111","100","110","100","111"}, D={"110","101","101","101","110"},
  V={"101","101","101","101","010"}, A={"010","101","111","101","101"}, U={"101","101","101","101","111"},
  L={"100","100","100","100","111"}, T={"111","010","010","010","010"}, ["0"]={"111","101","101","101","111"},
  ["7"]={"111","001","010","010","010"}, [" "]={"000","000","000","000","000"}}
local text = "SEED VAULT 07"
local u0, v0, cw, ch = 0.16, 0.28, 0.022, 0.055
local let = nil
for i = 1, #text do
  local g = font[text:sub(i, i)]
  for r = 1, 5 do for c = 1, 3 do
    if g[r]:sub(c, c) == "1" then
      local u = u0 + (i - 1) * cw * 1.35 + (c - 1) * cw / 3
      local v = v0 + (r - 1) * ch / 5
      local q = quadUV(TQ, u + 0.0008, u + cw / 3 - 0.0008, v + 0.002, v + ch / 5 - 0.002)
      let = let and (let + q) or q
    end
  end end
end
stencil = pile{{"bone black",1.5},{"ultramarine ash",0.8},{"burnt sienna",0.2}}
work(let, {hand="detail", pile=stencil, coverage=3, fill=true, angle=0, tool={kind="round", width=0.9}})
-- the readout: a small cyan screen on the front face
readM = quadUV(FQ, 0.7, 0.84, 0.25, 0.62)
screen = pile{{"cerulean blue",1},{"viridian",0.4},{"zinc white",1.2},{"bone black",0.15}}
work(quadUV(FQ, 0.69, 0.85, 0.2, 0.68), {hand="detail", pile=stencil, coverage=3.5, fill=true, angle=0})
work(readM, {hand="detail", pile=screen, coverage=4, fill=true, angle=0})
-- a mission patch, worn
local pc = bil(FQ, 0.22, 0.48)
work(ellipse(pc[1], pc[2], 15, 13), {hand="detail", pile=pile{{"ultramarine blue",1},{"lead white",0.8},{"bone black",0.3}}, coverage=3.5, fill=true})
work(ellipse(pc[1], pc[2], 8, 7), {hand="detail", pile=redF, coverage=3.5, fill=true})

--@ chunk 10
print(wait(2*24*60))
cyan  = pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.45}}
cyanH = pile{{"zinc white",3},{"cerulean blue",0.4},{"viridian",0.15}}
cyanG = pile{{"zinc white",1},{"cerulean blue",1},{"viridian",0.5},{"ultramarine ash",0.5}, medium=0.3}
work(readM, {hand="detail", pile=cyan, coverage=4, fill=true, angle=0})
-- glyph rows, barely readable
local gb = brush{kind="round", width=1.0, point=0.6}
for r = 0, 3 do
  local u = 0.715
  while u < 0.83 do
    local L = rand(0.004, 0.014)
    local a = bil_(FQ, u, 0.31 + r * 0.075); local b = bil_(FQ, math.min(u + L, 0.83), 0.31 + r * 0.075)
    gb:load(r == 1 and cyanH or stencil, 0.7)
    gb:stroke({a, b}, {pressure={0.5, 0.5}, ramps={0.1, 0.1}})
    u = u + L + 0.005
  end
end
-- the glow it throws: a cold breath on the frost around it and up onto the thumb
local sc = bil_(FQ, 0.77, 0.43)
local halo = ellipse(sc[1], sc[2] - 8, 95, 60) - readM:grow(4) - fingerM2 - (armM + cuffM + backM2)
stipple(halo, {pile=cyanG, width=1.8, coverage=function(x, y) local d = math.sqrt(((x-sc[1])/95)^2 + ((y-sc[2]+8)/60)^2); return clamp(0.9 - d, 0, 0.9) end, feather=0.9, pressure={0.15, 0.35}})
-- cold rim on the underside of the thumb and the lowest finger, facing the screen
local rb = brush{kind="round", width=1.6, point=0.7}
rb:load(cyan, 0.7); rb:stroke({{758,345},{730,385},{700,410}}, {pressure={0.5, 0.25}})
rb:load(cyan, 0.6); rb:stroke({{640,380},{580,400},{540,413}}, {pressure={0.35, 0.15}})
-- the shell's top-front edge: a bevel, gold in the beam, cold out of it
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local eb = brush{kind="round", width=2.2, point=0.6}
eb:load(gold, 0.9); eb:stroke({{240, 483}, {585, 444}}, {pressure={0.6, 0.6}, clip=beamHard})
eb:load(rimC, 0.7); eb:stroke({{94, 499}, {250, 482}}, {pressure={0.4, 0.4}})
eb:load(rimC, 0.7); eb:stroke({{580, 445}, {818, 419}}, {pressure={0.4, 0.4}})
-- rosary wound round the wrist: dark beads with a glint each
local bb = brush{kind="round", width=5.5}
local gl = brush{kind="round", width=1.4}
for k = 0, 15 do
  local t = k / 15
  local x = lerp(748, 812, t) + 10 * math.sin(t * math.pi)
  local y = lerp(204, 322, t) + 4 * math.sin(t * 6.3)
  bb:load(pile{{"bone black",2},{"burnt sienna",0.6}}, 0.9); bb:touch(x, y, {pressure=0.7})
  gl:load(rimW, 0.8); gl:touch(x - 1.2, y - 1.2, {pressure=0.5})
end
-- the loop hangs down onto the shell, ending in a small cross
for k = 0, 9 do
  local t = k / 9
  local x = lerp(805, 785, t) - 14 * math.sin(t * math.pi)
  local y = lerp(325, 372, t)
  bb:load(pile{{"bone black",2},{"burnt sienna",0.6}}, 0.9); bb:touch(x, y, {pressure=0.55})
  gl:load(rimW, 0.8); gl:touch(x - 1, y - 1, {pressure=0.45})
end
local xb = brush{kind="flat", width=3}
xb:load(bone, 0.9); xb:stroke({{784,378},{782,398}}, {pressure={0.8, 0.8}})
xb:load(bone, 0.9); xb:stroke({{776,384},{791,384}}, {pressure={0.8, 0.8}})

--@ chunk 11
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local band = beamHard:grow(12) - shellM:grow(2) - handM2
local wt = mask(function(x, y) return math.max(clamp((250 - y) / 210, 0, 1), clamp((y - 600) / 70, 0, 1)) end)
work(band * wt, {hand="body", pile=rockSh, coverage=3, fill=true, clip=true, angle=1.15, length={20,50}, threshold=0.1})
-- the band's long edges: lose them a little into the dark
local edges = (beamHard:grow(14) - beamHard:shrink(14)) - shellM:grow(3) - handM2
blend(edges, {angle=1.15, tool={kind="badger", width=12}})
-- rosary beads, larger
local bb = brush{kind="round", width=9}
local gl = brush{kind="round", width=2}
local beadP = pile{{"bone black",2},{"burnt sienna",0.8}}
for k = 0, 11 do
  local t = k / 11
  local x = lerp(744, 814, t) + 12 * math.sin(t * math.pi)
  local y = lerp(200, 324, t)
  bb:load(beadP, 0.95); bb:touch(x, y, {pressure=0.8})
end
for k = 0, 7 do
  local t = k / 7
  bb:load(beadP, 0.95); bb:touch(lerp(808, 786, t) - 16 * math.sin(t * math.pi), lerp(330, 372, t), {pressure=0.7})
end

--@ chunk 12
print(wait(2*24*60))
frost  = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25}}
frostW = pile{{"lead white",3},{"zinc white",1},{"yellow ochre",0.25}}
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
-- rime along the shell's edges and corners
local rim = (shellM - shellM:shrink(22)) - handM2 - readM:grow(3)
local nz = noise{seed=17, period=30, octaves=3}
stipple(rim - beamHard, {pile=frost, width=1.8, coverage=function(x, y) return math.max(0, 0.5 + 0.6 * nz(x, y)) end, feather=0.7, cluster=0.5, pressure={0.15, 0.45}})
stipple(rim * beamHard, {pile=frostW, width=1.8, coverage=function(x, y) return math.max(0, 0.5 + 0.6 * nz(x, y)) end, feather=0.7, cluster=0.5, pressure={0.15, 0.45}})
-- frost feathers growing in from the edges
local fb = brush{kind="round", width=1.1, point=0.8}
local seeds = {{110,330,0.2},{75,420,0.1},{120,560,-0.3},{300,600,-1.2},{450,470,-1.5},{640,430,-1.6},{700,270,1.6},{760,400,2.6},{805,470,2.9},{330,295,1.4},{180,470,-0.9},{560,275,1.5}}
for _, s in ipairs(seeds) do
  local x, y, a = s[1], s[2], s[3]
  local p = (beamHard:at(x, y) > 0.5) and frostW or frost
  local pts = {}
  local L = rand(30, 55)
  for j = 0, 6 do
    local t = j / 6
    pts[#pts+1] = {x + math.cos(a + 0.4 * math.sin(t * 3)) * L * t, y + math.sin(a + 0.4 * math.sin(t * 3)) * L * t}
  end
  fb:load(p, 0.7); fb:stroke(pts, {pressure={0.5, 0.1}})
  for j = 1, 5 do
    local q = pts[j + 1]
    for _, side in ipairs({1, -1}) do
      local aa = a + side * 0.9
      local l = (1 - j / 6) * rand(8, 14)
      fb:load(p, 0.5); fb:stroke({q, {q[1] + math.cos(aa) * l, q[2] + math.sin(aa) * l}}, {pressure={0.35, 0.05}})
    end
  end
end
-- the screen glows: a hot core line and a cyan lip on its frame
local core = quadUV(FQ, 0.73, 0.81, 0.36, 0.5)
work(core, {hand="detail", pile=cyanH, coverage=2, fill=false, angle=0, load=0.6})

--@ chunk 13
print(wait(3*24*60))
coldG = pile{{"bone black",1},{"ultramarine blue",0.7},{"burnt sienna",0.2}, medium=0.7}
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local sh = shellM - beamHard:grow(12) - handM2:grow(1) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local shb = shellM - beamHard:grow(4) - handM2:grow(1) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
work(sh, {hand="glaze", pile=coldG, coverage=1.4, fill=true, clip=true, load=0.5, pressure={0.25, 0.45}, angle=math.atan(248 - 300, 700 - 60)})
blend(shb, {angle=math.atan(248 - 300, 700 - 60), tool={kind="badger", width=16}})

--@ chunk 14
print(wait(4*24*60))
frostG = pile{{"lead white",1.5},{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.15}}
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local sh = shellM - beamHard:shrink(2) - handM2:grow(1) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local nz = noise{seed=23, period=45, octaves=4}
-- a crust of rime over the cold half of the shell: thick at the edges and corners, thinner inward
local edgeD = shellM:distance()
stipple(sh, {pile=frostG, width=2.4, coverage=function(x, y)
  local d = edgeD:at(x, y)
  return math.max(0, 1.6 - d / 40 + 0.5 * nz(x, y))
end, feather=0.6, cluster=0.4, pressure={0.2, 0.5}, dips={18, 0.7, 0.3}})

--@ chunk 15
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local sh = shellM - beamHard:shrink(2) - handM2:grow(1) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local nz = noise{seed=29, period=25, octaves=3}
stipple(sh, {pile=frostG, width=1.6, coverage=function(x, y) return math.max(0, 0.9 + 0.6 * nz(x, y)) end, feather=0.5, cluster=0.3, pressure={0.15, 0.4}, dips={18, 0.6, 0.3}})
-- the S the glaze took
local S = {"111","100","111","001","111"}
local u0, v0, cw, ch = 0.16, 0.28, 0.022, 0.055
local let = nil
for r = 1, 5 do for c = 1, 3 do
  if S[r]:sub(c, c) == "1" then
    local u = u0 + (c - 1) * cw / 3
    local v = v0 + (r - 1) * ch / 5
    local q = quadUV(TQ, u + 0.0008, u + cw / 3 - 0.0008, v + 0.002, v + ch / 5 - 0.002)
    let = let and (let + q) or q
  end
end end
work(let, {hand="detail", pile=stencil, coverage=3, fill=true, angle=0, tool={kind="round", width=0.9}})
-- dust in the beam: ground rock hanging in the gold, over the floor and the shell
local db = brush{kind="round", width=1.3, point=0.8}
local dust = pile{{"lead white",2},{"Indian yellow",0.6},{"yellow ochre",0.4}}
for k = 1, 160 do
  local t = rand(0, 1)
  local y = rand(0, 660)
  local xl = lerp(90, 300, y / 680); local xr = lerp(360, 640, y / 680)
  local x = lerp(xl, xr, rand(0.05, 0.95))
  if handM2:at(x, y) < 0.5 then
    if k % 14 == 1 then db:load(dust, 0.7) end
    db:touch(x, y, {pressure=rand(0.1, 0.45)})
  end
end

--@ chunk 16
print(wait(2*24*60))
-- rubble pebbles in the gold pool round the shell: lit tops, dark undersides
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local pool = (beamHard:grow(10) * shellM:grow(70)) - shellM:grow(2) - handM2
local pb = brush{kind="filbert", width=9}
local ps = brush{kind="filbert", width=7}
local n = 0
for k = 1, 700 do
  local x, y = rand(120, 700), rand(180, 667)
  if pool:at(x, y) > 0.5 then
    local s = rand(0.6, 1.3)
    ps:load(rockSh, 0.8); ps:touch(x + 2, y + 3, {pressure=0.5 * s, drag={4 * s, 0.2}})
    pb:load((k % 3 == 0) and rockGold or rockLit, 0.8); pb:touch(x, y, {pressure=0.45 * s, drag={4 * s, -0.3}})
    n = n + 1
  end
end
print(n)
-- the readout's cold light: on the frost next to it and the thumb above
local cb = brush{kind="round", width=2.2, point=0.6}
cb:load(cyan, 0.9); cb:stroke({{772,330},{748,372},{712,402}}, {pressure={0.7, 0.4}})
cb:load(cyan, 0.8); cb:stroke({{690,402},{705,410}}, {pressure={0.5, 0.3}})
cb:load(cyanH, 0.8); cb:stroke({quadUV(FQ,0,0,0,0) and bil_(FQ, 0.69, 0.2), bil_(FQ, 0.85, 0.2)}, {pressure={0.6, 0.6}})
local sc = bil_(FQ, 0.77, 0.43)
local halo = (ellipse(sc[1], sc[2] - 6, 80, 48) * shellM) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(1) - handM2
stipple(halo, {pile=cyan, width=1.6, coverage=function(x, y) local d = math.sqrt(((x-sc[1])/80)^2 + ((y-sc[2]+6)/48)^2); return clamp(1.1 - 1.2 * d, 0, 1) end, feather=0.8, pressure={0.15, 0.4}})

--@ chunk 17
local sc = bil_(FQ, 0.77, 0.43)
local soft = mask(function(x, y) local d = math.sqrt(((x-sc[1])/85)^2 + ((y-sc[2]+6)/52)^2); return clamp(1 - d, 0, 1) end)
local halo = soft * shellM - quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(1) - handM2
work(halo, {hand="scumble", pile=cyanG, coverage=1.6, clip=true, load=0.45, pressure={0.2, 0.4}, threshold=0.05, tool={kind="filbert", width=5}})
-- gold rime on the sunlit half, sparse
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local lit = (shellM * beamHard) - (shellM:shrink(14))
stipple(lit, {pile=frostW, width=1.8, coverage=0.8, feather=0.6, cluster=0.5, pressure={0.15, 0.4}})

--@ chunk 18
local sc = bil_(FQ, 0.77, 0.43)
local m = (ellipse(sc[1], sc[2] - 6, 95, 60) * shellM) - quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(1) - handM2
for k = 1, 3 do work(m, {hand="scumble", blender=true, coverage=1.5, clip=true, tool={kind="filbert", width=6}, seed=500+k}) end
blend(m, {angle=0, tool={kind="badger", width=12}})

--@ chunk 19
print(wait(3*24*60))
-- frost feathers that landed on the gauntlet: painted out
local spots = {{550,288},{700,282},{588,346}}
for _, s in ipairs(spots) do
  work(ellipse(s[1], s[2] + 2, 14, 16) * (fingerM2 + backM2 + thumbM2), {hand="detail", pile=gaunt, coverage=4, fill=true, angle=2.8})
end
-- the floor under the beam, above and below the shell: rubble lit gold, falling off along the beam
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local zone = beamHard:grow(6) - shellM:grow(2) - handM2
local brushes = {}
for k = 1, 5 do brushes[k] = brush{kind="filbert", width=4 + k * 1.6} end
local n = 0
for k = 1, 2400 do
  local x, y = rand(80, 660), rand(-5, 672)
  if zone:at(x, y) > 0.5 then
    local near = 1 - clamp(math.min(math.abs(y - 270), math.abs(y - 610)) / 160, 0, 1)
    if y > 300 and y < 600 then near = 1 end
    local r = rand(0, 1)
    local p
    if r < 0.35 then p = rockSh
    elseif r < 0.35 + 0.4 * near then p = (rand(0,1) < 0.5) and rockGold or rockLit
    else p = rockDim2 end
    local s = clamp(math.floor(1 + (y / 672) * 4 + rand(-1, 1)), 1, 5)
    brushes[s]:load(p, rand(0.5, 0.9))
    brushes[s]:touch(x, y, {pressure=rand(0.4, 0.75), drag={rand(2, 6), rand(-0.6, 0.6)}, angle=rand(-1, 1)})
    n = n + 1
  end
end
print(n)

--@ chunk 20
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local zone = beamHard:grow(4) - shellM:grow(2) - handM2
local fall = function(y) return clamp(1 - math.min(math.abs(y - 270), math.abs(y - 620)) / 200, 0, 1) end
local nearM = zone * mask(function(x, y) return fall(y) end)
local farM  = zone * mask(function(x, y) return 1 - fall(y) end)
stipple(farM, {pile=rockDim2, width=7, coverage=1.6, cluster=0.5, pressure={0.4, 0.8}, drag={4, 0.3}, dips={10, 0.8, 0.3}})
stipple(farM, {pile=rockDim, width=6, coverage=0.5, cluster=0.6, pressure={0.4, 0.8}, drag={4, -0.3}, dips={10, 0.8, 0.3}})
stipple(nearM, {pile=rockSh, width=7, coverage=0.9, cluster=0.5, pressure={0.4, 0.8}, drag={4, 0.3}, dips={10, 0.8, 0.3}})
stipple(nearM, {pile=rockLit, width=6, coverage=0.9, cluster=0.6, pressure={0.4, 0.8}, drag={4, -0.3}, dips={10, 0.8, 0.3}, feather=0.6})
stipple(nearM, {pile=rockGold, width=5, coverage=0.5, cluster=0.6, pressure={0.4, 0.8}, drag={3, -0.3}, dips={10, 0.8, 0.3}, feather=0.8})

--@ chunk 21
print(wait(2*24*60))
-- contact shadows: the fingers press on the frost
local shP = pile{{"bone black",2},{"ultramarine blue",1}, medium=0.1}
local sb = brush{kind="round", width=4, point=0.4}
for i = 1, 4 do
  local f = fingers[i]
  local w = (26 - i) / 2
  local dx, dy = f.t[1] - f.k[1], f.t[2] - f.k[2]
  local n = math.sqrt(dx*dx + dy*dy)
  local px, py = -dy / n, dx / n
  local a = {lerp(f.k[1], f.t[1], 0.35) + px * (w + 1), lerp(f.k[2], f.t[2], 0.35) + py * (w + 1)}
  local b = {f.t[1] + px * (w * 0.6) - dx / n * 2, f.t[2] + py * (w * 0.6) - dy / n * 2}
  sb:load(shP, 0.8); sb:stroke({a, b}, {pressure={0.3, 0.6}, clip=shellM - handM2})
end
-- warm light bounced up off the lit shell onto the undersides of the fingers nearest the beam
local warmB = pile{{"raw sienna",1},{"burnt sienna",0.6},{"yellow ochre",0.6},{"bone black",0.3}}
local rb = brush{kind="round", width=2.4, point=0.6}
for i = 1, 4 do
  local f = fingers[i]
  local w = (26 - i) / 2
  local dx, dy = f.t[1] - f.k[1], f.t[2] - f.k[2]
  local n = math.sqrt(dx*dx + dy*dy)
  local px, py = -dy / n, dx / n
  local a = {lerp(f.k[1], f.t[1], 0.55) + px * (w - 3), lerp(f.k[2], f.t[2], 0.55) + py * (w - 3)}
  local b = {lerp(f.k[1], f.t[1], 0.95) + px * (w - 4), lerp(f.k[2], f.t[2], 0.95) + py * (w - 4)}
  rb:load(warmB, 0.7); rb:stroke({a, b}, {pressure={0.1, 0.5}})
end
-- a dull sheen across the back of the hand and the cuff
local sheen = pile{{"bone black",1},{"ultramarine ash",0.7},{"lead white",0.35}}
local hb = brush{kind="filbert", width=6}
hb:load(sheen, 0.5); hb:stroke({{630,262},{700,250},{742,236}}, {pressure={0.3, 0.15}})
hb:load(sheen, 0.4); hb:stroke({{760,205},{800,190},{850,165}}, {pressure={0.25, 0.1}})

--@ chunk 22
local gk = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.3}}
local b = brush{kind="filbert", width=5}
for _, s in ipairs({{554,276},{555,290},{557,304},{698,270},{699,284},{700,298}}) do
  for k = 1, 3 do
    b:load(gk, 1.0)
    b:stroke({{s[1] - 6, s[2] - 4 + k * 2}, {s[1] + 6, s[2] - 6 + k * 2}}, {pressure={0.9, 0.9}, clip=handM2})
  end
end

--@ chunk 23
local gk = pile{{"bone black",2},{"burnt sienna",0.8},{"ultramarine blue",0.3}}
local b = brush{kind="filbert", width=4}
for _, s in ipairs({{560,278},{561,286},{557,294},{697,276},{698,284},{695,290}}) do
  for k = 1, 3 do
    b:load(gk, 1.0)
    b:stroke({{s[1] - 6, s[2] - 4 + k * 2}, {s[1] + 6, s[2] - 6 + k * 2}}, {pressure={0.9, 0.9}, clip=handM2})
  end
end

--@ chunk 24
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local bg = everywhere() - beamHard:grow(2) - shellM:grow(2) - handM2:grow(1)
bzDeep = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}, medium=0.05}
bzDark = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.5}, medium=0.05}
local dist = beamHard:distance()
stipple(bg, {pile=bzDeep, width=8, coverage=1.4, cluster=0.5, pressure={0.4, 0.8}, drag={5, 0.3}, dips={10, 0.8, 0.3}})
stipple(bg, {pile=bzDark, width=7, coverage=function(x, y) return clamp(0.9 - dist:at(x, y) / 300, 0.15, 0.9) end, cluster=0.6, pressure={0.4, 0.8}, drag={4, -0.3}, dips={10, 0.8, 0.3}})
stipple(bg, {pile=rockDim2, width=5, coverage=function(x, y) return clamp(0.6 - dist:at(x, y) / 200, 0, 0.6) end, cluster=0.6, pressure={0.4, 0.8}, drag={3, -0.3}, dips={10, 0.8, 0.3}, feather=0.7})

--@ chunk 25
print(wait(2*24*60))
local dentD = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",1},{"bone black",0.25}}
local dentL = pile{{"lead white",3},{"zinc white",1},{"lemon chrome",0.3}}
local db = brush{kind="filbert", width=6}
local lb = brush{kind="round", width=1.6, point=0.7}
for _, d in ipairs({{300,360,22},{420,330,14},{365,420,30},{470,395,12},{260,425,10}}) do
  local x, y, r = d[1], d[2], d[3]
  db:load(dentD, 0.5)
  db:stroke({{x - r, y - r * 0.15}, {x, y + r * 0.25}, {x + r, y - r * 0.1}}, {pressure={0.35, 0.15}})
  lb:load(dentL, 0.7)
  lb:stroke({{x - r * 0.8, y + r * 0.3}, {x, y + r * 0.5}, {x + r * 0.7, y + r * 0.25}}, {pressure={0.3, 0.1}})
end
-- scuffs and scratches along the lit top
local sb = brush{kind="round", width=1.0, point=0.8}
for k = 1, 26 do
  local x, y = rand(200, 520), rand(300, 470)
  local a = rand(-0.4, 0.2); local L = rand(10, 40)
  sb:load((k % 3 == 0) and dentL or dentD, 0.5)
  sb:stroke({{x, y}, {x + math.cos(a) * L, y + math.sin(a) * L}}, {pressure={0.3, 0.05}, clip=topQ})
end
-- the faded red band continues through the light, sun-bleached
local redL = pile{{"vermilion",0.6},{"lead white",1.5},{"yellow ochre",0.3}}
local band = quadUV(TQ, 0.07, 0.12, 0, 1) + quadUV(FQ, 0.07, 0.12, 0, 1)
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
work(band * beamHard, {hand="detail", pile=redL, coverage=2.5, fill=true, angle=1.4})

--@ chunk 26
print(wait(24*60))
local cream = pile{{"lead white",3},{"yellow ochre",0.5},{"cadmium yellow",0.2},{"raw sienna",0.1}}
local soft = pile{{"lead white",2.5},{"yellow ochre",0.7},{"raw sienna",0.3},{"ultramarine ash",0.15}}
local db = brush{kind="filbert", width=8}
for _, d in ipairs({{300,360,22},{420,330,14},{365,420,30},{470,395,12},{260,425,10}}) do
  local x, y, r = d[1], d[2], d[3]
  db:load(cream, 0.9)
  db:stroke({{x - r - 3, y - r * 0.15}, {x, y + r * 0.25}, {x + r + 3, y - r * 0.1}}, {pressure={0.8, 0.7}})
  db:load(soft, 0.35)
  db:stroke({{x - r * 0.7, y}, {x, y + r * 0.2}, {x + r * 0.7, y}}, {pressure={0.3, 0.1}})
end

--@ chunk 27
print(wait(2*24*60))
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(1)
local coldTop = topQ - beamHard:grow(3) - handM2:grow(1)
local coldFront = frontQ - beamHard:grow(3) - scr
local band = quadUV(TQ, 0.07, 0.12, 0, 1) + quadUV(FQ, 0.07, 0.12, 0, 1)
local slateT = pile{{"ultramarine ash",1},{"bone black",0.8},{"lead white",0.3}, medium=0.05}
local slateF = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.1}, medium=0.05}
local redS = pile{{"vermilion",1},{"bone black",0.5},{"ultramarine ash",0.4},{"lead white",0.2}}
local ang = math.atan(248 - 300, 700 - 60)
work(coldTop - band, {hand="body", pile=slateT, coverage=3.4, fill=true, clip=true, angle=ang, length={20,60}})
work(coldFront - band, {hand="body", pile=slateF, coverage=3.4, fill=true, clip=true, angle=ang, length={20,60}})
work((coldTop + coldFront) * band, {hand="detail", pile=redS, coverage=3.5, fill=true, angle=1.4})

--@ chunk 28
print(wait(3*24*60))
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(2)
local cold = shellM - beamHard:shrink(4) - handM2:grow(1) - scr
local edgeD = shellM:distance()
local nz = noise{seed=31, period=40, octaves=4}
local frostC = pile{{"lead white",1.2},{"zinc white",1},{"ultramarine ash",0.9},{"bone black",0.2}}
stipple(cold, {pile=frostC, width=1.8, coverage=function(x, y)
  return math.max(0, 1.2 - edgeD:at(x, y) / 22 + 0.45 * nz(x, y))
end, feather=0.7, cluster=0.5, pressure={0.15, 0.45}, dips={16, 0.6, 0.3}})
-- the readout's light on the frost around it: cyan grains, thickest near the screen
local sc = bil_(FQ, 0.77, 0.43)
local near = ellipse(sc[1], sc[2] - 10, 110, 70) * shellM - scr - handM2:grow(1)
stipple(near, {pile=cyan, width=1.5, coverage=function(x, y)
  local d = math.sqrt(((x-sc[1])/110)^2 + ((y-sc[2]+10)/70)^2)
  return clamp(1.3 * (1 - d) ^ 1.5, 0, 1.2)
end, feather=0.9, cluster=0.3, pressure={0.12, 0.35}})
-- mission patch
local pc = bil_(FQ, 0.22, 0.48)
work(ellipse(pc[1], pc[2], 15, 13), {hand="detail", pile=pile{{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.4}}, coverage=3.5, fill=true})
work(ellipse(pc[1], pc[2], 8, 7), {hand="detail", pile=pile{{"vermilion",1},{"lead white",0.4},{"bone black",0.3}}, coverage=3.5, fill=true})
local sb = brush{kind="round", width=1.1, point=0.7}
sb:load(frostC, 0.7); sb:stroke({{pc[1]-10, pc[2]+9}, {pc[1]+6, pc[2]-11}}, {pressure={0.4, 0.2}})

--@ chunk 29
print(wait(2*24*60))
local beamHard = poly({{90,-10},{360,-10},{640,680},{300,680}})
local band = (quadUV(TQ, 0.07, 0.12, 0, 1) + quadUV(FQ, 0.07, 0.12, 0, 1)) - beamHard:grow(3)
local frostC = pile{{"lead white",1.2},{"zinc white",1},{"ultramarine ash",0.9},{"bone black",0.2}}
stipple(band, {pile=frostC, width=1.6, coverage=1.1, feather=0.3, cluster=0.5, pressure={0.15, 0.4}})
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68):grow(2)
local sc = bil_(FQ, 0.77, 0.43)
local cyanM = pile{{"cerulean blue",1},{"viridian",0.35},{"zinc white",0.8},{"ultramarine ash",0.3}}
local near = ellipse(sc[1], sc[2] - 6, 90, 55) * shellM - scr - handM2:grow(1)
stipple(near, {pile=cyanM, width=2.4, coverage=function(x, y)
  local d = math.sqrt(((x-sc[1])/90)^2 + ((y-sc[2]+6)/55)^2)
  return clamp(2.2 * (1 - d) ^ 2, 0, 2)
end, feather=0.8, cluster=0.2, pressure={0.12, 0.3}})
-- feathers of frost on the cold shell
local fb = brush{kind="round", width=1.1, point=0.8}
local seeds = {{70,330,0.15},{95,470,-0.2},{130,590,-0.6},{240,600,-1.3},{600,455,-1.7},{810,430,2.8},{820,500,3.0},{700,268,1.7},{640,440,-1.4},{100,515,0.2}}
for _, s in ipairs(seeds) do
  local x, y, a = s[1], s[2], s[3]
  local pts = {}
  local L = rand(28, 48)
  for j = 0, 6 do
    local t = j / 6
    pts[#pts+1] = {x + math.cos(a + 0.35 * math.sin(t * 3)) * L * t, y + math.sin(a + 0.35 * math.sin(t * 3)) * L * t}
  end
  fb:load(frostC, 0.7); fb:stroke(pts, {pressure={0.5, 0.1}, clip=shellM - handM2})
  for j = 1, 5 do
    local q = pts[j + 1]
    for _, side in ipairs({1, -1}) do
      local aa = a + side * 0.9
      local l = (1 - j / 6) * rand(7, 12)
      fb:load(frostC, 0.5); fb:stroke({q, {q[1] + math.cos(aa) * l, q[2] + math.sin(aa) * l}}, {pressure={0.35, 0.05}, clip=shellM - handM2})
    end
  end
end

--@ chunk 30
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local sc = bil_(FQ, 0.77, 0.44)
local cyanM = pile{{"cerulean blue",1},{"viridian",0.35},{"zinc white",0.8},{"ultramarine ash",0.4},{"bone black",0.2}}
local glowZone = (ellipse(sc[1], sc[2], 105, 62) * shellM) - scr:grow(1) - handM2:grow(1)
local soft = mask(function(x, y) local d = math.sqrt(((x-sc[1])/105)^2 + ((y-sc[2])/62)^2); return clamp(1 - d, 0, 1) end)
work(glowZone * soft, {hand="body", pile=cyanM, coverage=1.6, fill=false, clip=true, threshold=0.05, load_at=function(x, y) local d = math.sqrt(((x-sc[1])/105)^2 + ((y-sc[2])/62)^2); return clamp(0.6 * (1 - d), 0.05, 0.6) end, pressure={0.25, 0.45}, tool={kind="filbert", width=6}, angle=function(x, y) return math.atan(y - sc[2], x - sc[1]) end, length={10,30}})
blend(glowZone, {angle=0, tool={kind="badger", width=12}})

--@ chunk 31
print(wait(24*60))
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local sc = bil_(FQ, 0.77, 0.44)
local zone = (ellipse(sc[1], sc[2], 110, 66) * shellM) - scr:grow(1) - handM2:grow(1)
local slateT = pile{{"ultramarine ash",1},{"bone black",0.8},{"lead white",0.3}, medium=0.05}
local slateF = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.1}, medium=0.05}
local ang = math.atan(248 - 300, 700 - 60)
work(zone * topQ, {hand="body", pile=slateT, coverage=3.6, fill=true, clip=true, angle=ang, length={15,40}})
work(zone * frontQ, {hand="body", pile=slateF, coverage=3.6, fill=true, clip=true, angle=ang, length={15,40}})

--@ chunk 32
print(wait(3*24*60))
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local cyanM = pile{{"cerulean blue",1},{"viridian",0.35},{"zinc white",0.8},{"ultramarine ash",0.4},{"bone black",0.2}}
local frostC = pile{{"lead white",1.2},{"zinc white",1},{"ultramarine ash",0.9},{"bone black",0.2}}
-- light spilling from the screen: short dry strokes radiating from its frame, fading out
local b = brush{kind="filbert", width=4}
local corners = {bil_(FQ, 0.69, 0.2), bil_(FQ, 0.85, 0.2), bil_(FQ, 0.85, 0.68), bil_(FQ, 0.69, 0.68)}
local sc = bil_(FQ, 0.77, 0.44)
local n = 0
for k = 1, 90 do
  local e = (k % 4) + 1
  local a, c = corners[e], corners[(e % 4) + 1]
  local t = rand(0, 1)
  local p = {lerp(a[1], c[1], t), lerp(a[2], c[2], t)}
  local dx, dy = p[1] - sc[1], p[2] - sc[2]
  local nn = math.sqrt(dx*dx + dy*dy)
  local L = rand(8, 26)
  local start = {p[1] + dx / nn * 4, p[2] + dy / nn * 4}
  b:load(cyanM, rand(0.15, 0.3))
  b:stroke({start, {start[1] + dx / nn * L, start[2] + dy / nn * L}}, {pressure={0.35, 0.02}, ramps={0.05, 0.8}, clip=shellM - scr:grow(1) - handM2})
  n = n + 1
end
-- frost grains back along the shell's lower front edge
local edgeD = shellM:distance()
local zone = (ellipse(sc[1], sc[2], 115, 70) * shellM) - scr:grow(2) - handM2:grow(1)
stipple(zone, {pile=frostC, width=1.8, coverage=function(x, y) return math.max(0, 1.2 - edgeD:at(x, y) / 18) end, feather=0.7, cluster=0.5, pressure={0.15, 0.45}})
-- cyan on the frost grains nearest the screen
stipple(zone * ellipse(sc[1], sc[2], 70, 42), {pile=pile{{"zinc white",2},{"cerulean blue",1},{"viridian",0.3}}, width=1.6, coverage=0.25, feather=0.2, cluster=0.3, pressure={0.3, 0.5}})

--@ chunk 33
local scr = quadUV(FQ, 0.69, 0.85, 0.2, 0.68)
local sc = bil_(FQ, 0.77, 0.44)
local zone = (ellipse(sc[1], sc[2], 120, 72) * shellM) - scr:grow(1) - handM2:grow(1)
for k = 1, 4 do work(zone, {hand="scumble", blender=true, coverage=1.5, clip=true, tool={kind="filbert", width=6}, seed=600+k}) end

--@ chunk 34
print(wait(2*24*60))
-- the beam's edge grazes the fingertips: a warm hairline along the top of each finger's last joint
local warm = pile{{"lead white",2},{"Indian yellow",0.8},{"raw sienna",0.3}}
local rb = brush{kind="round", width=1.4, point=0.8}
for i = 1, 4 do
  local f = fingers[i]
  local w = (26 - i) / 2
  local dx, dy = f.t[1] - f.k[1], f.t[2] - f.k[2]
  local n = math.sqrt(dx*dx + dy*dy)
  local px, py = -dy / n, dx / n
  local a = {lerp(f.k[1], f.t[1], 0.6) - px * (w - 2), lerp(f.k[2], f.t[2], 0.6) - py * (w - 2)}
  local b = {lerp(f.k[1], f.t[1], 0.96) - px * (w - 3), lerp(f.k[2], f.t[2], 0.96) - py * (w - 3)}
  rb:load(warm, 0.7); rb:stroke({a, b}, {pressure={0.05, 0.45}})
end

--@ chunk 35
local boneD = pile{{"lead white",1},{"yellow ochre",0.8},{"raw sienna",0.5},{"bone black",0.35}}
local cx, cy = 905, 125
local cb = brush{kind="flat", width=8}
cb:load(boneD, 0.95); cb:stroke({{cx + 22, cy - 34}, {cx - 20, cy + 36}}, {pressure={0.85, 0.85}})
cb:load(boneD, 0.95); cb:stroke({{cx - 26, cy - 6}, {cx + 24, cy + 2}}, {pressure={0.85, 0.85}})
local lb = brush{kind="round", width=1.2, point=0.8}
lb:load(pile{{"lead white",2},{"yellow ochre",0.5}}, 0.6)
lb:stroke({{cx + 20, cy - 34}, {cx + 2, cy - 4}}, {pressure={0.3, 0.1}})
