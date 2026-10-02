-- easel session "anatomy": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.4, linen={24,22}, seed=131,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.25},
          {pile={{"bone brown",2},{"burnt sienna",0.5},{"bone black",0.6},{"lead white",0.25}}, um=35, apply="roller"}}}
print(W, H)

--@ chunk 2
BG1 = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.3}}
BGM = pile{{"bone brown",2},{"raw sienna",0.4},{"bone black",0.5},{"lead white",0.1}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"bone black",0.3},{"lead white",0.25}}
local all = everywhere()
local function ring(r0, r1) return all * (ellipse(0, 0, r1, r1) - ellipse(0, 0, r0, r0)) end
work(ring(0, 420), {hand="body", pile=BG2, coverage=3, fill=true, clip=all, angle=math.pi/2 + 0.2})
work(ring(420, 720), {hand="body", pile=BGM, coverage=3, fill=true, clip=all, angle=math.pi/2 + 0.2})
work(ring(720, 2000), {hand="body", pile=BG1, coverage=3, fill=true, clip=all, angle=math.pi/2 + 0.2})
blend(ring(390, 450), {angle=-0.7}); blend(ring(690, 750), {angle=-0.7})

--@ chunk 3
wait(3 * 24 * 60)
B1 = pile{{"raw sienna",1},{"bone brown",0.7},{"lead white",1},{"ultramarine ash",0.3}}
B2 = pile{{"lead white",2},{"raw sienna",0.7},{"bone brown",0.3},{"ultramarine ash",0.2}}
B3 = pile{{"lead white",3},{"yellow ochre",0.6},{"raw sienna",0.3}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.3}}
BD = pile{{"raw sienna",1},{"bone brown",1.2},{"lead white",0.6},{"ultramarine ash",0.3}}
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5}}
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.4}}
RB = pile{{"bone black",1.2},{"bone brown",0.8},{"ultramarine blue",0.2}}
RBL = pile{{"bone black",1},{"bone brown",0.9},{"lead white",0.35},{"raw sienna",0.2}}
BONE = {BD, B1, B2, B3, B4}
CHIT = {Q1, Q2, Q3, Q4, Q5}
-- the figures: c = eye-arc centre, s scale, dir +1 faces right / -1 faces left, tilt bows the head forward
HEADS = {
  {c={262,178}, s=0.78, dir=1, tilt=0.05, j=1},
  {c={468,206}, s=0.74, dir=-1, tilt=-0.05, j=2},
  {c={128,252}, s=0.84, dir=1, tilt=0.15, j=3},
  {c={358,272}, s=0.86, dir=1, tilt=0.32, j=4},
  {c={812,250}, s=1.0, dir=-1, tilt=0.18, j=5, lect=true},
  {c={212,372}, s=0.95, dir=1, tilt=0.42, j=6},
  {c={330,440}, s=1.0, dir=1, tilt=0.55, j=7},
}
function HW(H, x, y)
  local xf = -H.dir * x
  local a = H.dir * H.tilt
  local s = H.s
  return {H.c[1] + s * (xf * math.cos(a) - y * math.sin(a)), H.c[2] + s * (xf * math.sin(a) + y * math.cos(a))}
end
function HP(H, pts) local t = {} for i, p in ipairs(pts) do local jx = 2.5 * math.sin(H.j * 3.1 + i * 1.7); local jy = 2.5 * math.cos(H.j * 2.3 + i * 1.3); t[i] = HW(H, p[1] + jx, p[2] + jy) end return t end
SKULL_OUT = {{-18,72},{-34,52},{-42,28},{-46,4},{-48,-20},{-42,-44},{-26,-68},{0,-92},{36,-112},{78,-124},{110,-118},{120,-96},{104,-70},{72,-44},{52,-10},{44,30},{28,62}}
for _, H in ipairs(HEADS) do H.skull = poly(HP(H, SKULL_OUT), true) end
TABLE = poly({{150,560},{700,500},{780,610},{170,690}})
-- bodies, back to front, each over dry paint
for _, H in ipairs(HEADS) do
  local n = HW(H, 30, 66)
  local s = H.s
  local body
  if H.lect then body = poly({{n[1] - 50, n[2]}, {n[1] + 60, n[2]}, {n[1] + 140, n[2] + 200}, {n[1] + 160, 714}, {n[1] - 150, 714}, {n[1] - 130, n[2] + 160}}, true)
  else body = poly({{n[1] - 44 * s, n[2]}, {n[1] + 44 * s, n[2]}, {n[1] + 110 * s, n[2] + 160 * s}, {n[1] + 120 * s, 714}, {n[1] - 120 * s, 714}, {n[1] - 110 * s, n[2] + 160 * s}}, true) end
  H.body = body
  work(body - H.skull, {hand="detail", pile=RB, coverage=4, fill=true, clip=body - H.skull})
  local lit = body * rect(0, 0, n[1] - 10 * s, 2000) * rect(0, 0, 2000, n[2] + 140 * s)
  work(lit - H.skull, {hand="detail", pile=RBL, coverage=4, fill=true, clip=lit - H.skull})
  local ruff = ellipse(n[1], n[2] + 6 * s, 74 * s, 22 * s) - H.skull
  H.ruff = ruff
  work(ruff * rect(0,0,n[1],2000), {hand="detail", pile=B2, coverage=4, fill=true, clip=ruff})
  work(ruff * rect(n[1],0,500,2000), {hand="detail", pile=B1, coverage=4, fill=true, clip=ruff})
  wait(4 * 24 * 60)
end
local tb = TABLE - HEADS[6].body - HEADS[7].body
work(tb, {hand="detail", pile=Q2, coverage=4, fill=true, clip=tb})

--@ chunk 4
wait(2 * 24 * 60)
BONE_PL = {
  {{-48,-20},{-42,-44},{-26,-68},{-6,-58},{-18,-30}},
  {{-26,-68},{0,-92},{36,-112},{30,-80},{-6,-58}},
  {{36,-112},{78,-124},{110,-118},{90,-92},{30,-80}},
  {{110,-118},{120,-96},{104,-70},{90,-92}},
  {{-6,-58},{30,-80},{90,-92},{104,-70},{72,-44},{20,-36}},
  {{-18,-30},{-6,-58},{20,-36},{10,-14}},
}
CHIT_PL = {
  {{-46,4},{-48,-20},{-18,-30},{10,-14},{-6,12},{-30,20}},
  {{-42,28},{-46,4},{-30,20},{-6,12},{10,30},{-10,52},{-34,52}},
  {{10,-14},{20,-36},{72,-44},{52,-10},{44,30},{10,30},{-6,12}},
  {{-34,52},{-10,52},{10,30},{44,30},{28,62},{-18,72}},
}
HC = {30, -30}
function plateval(H, pts, ramp)
  local cx, cy = 0, 0 for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end; cx, cy = cx / #pts, cy / #pts
  local a = HW(H, cx, cy); local o = HW(H, HC[1], HC[2])
  local dx, dy = a[1] - o[1], a[2] - o[2]; local l = math.sqrt(dx*dx + dy*dy) + 1e-6
  local v = (-0.8 * dx - 0.6 * dy) / l
  local k = clamp(math.floor((v + 1) * 2.5) + 1, 1, 5)
  return ramp[k]
end
for _, H in ipairs(HEADS) do
  for _, pts in ipairs(BONE_PL) do local m = poly(HP(H, pts)) * H.skull:grow(1); work(m, {hand="detail", pile=plateval(H, pts, BONE), coverage=4, fill=true, clip=m}) end
  for _, pts in ipairs(CHIT_PL) do local m = poly(HP(H, pts)) * H.skull:grow(1); work(m, {hand="detail", pile=plateval(H, pts, CHIT), coverage=4, fill=true, clip=m}) end
  wait(3 * 24 * 60)
end

--@ chunk 5
wait(2 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.3},{"burnt sienna",0.4}}
local d = brush{kind="round", width=1.6, point=0.6}
local tb = brush{kind="round", width=2.0, point=0.2}
for _, H in ipairs(HEADS) do
  local s = H.s
  -- seams between all plates
  for _, set in ipairs{BONE_PL, CHIT_PL} do for _, pts in ipairs(set) do local w = HP(H, pts)
    for i = 1, #w do d:reload(Q1, 0.75); d:stroke({w[i], w[i % #w + 1]}, {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=H.skull}) end end end
  -- the eye arc: five eyes along the bone-chitin boundary, from the front back, shrinking
  local a0, a1, a2 = {-40,-17}, {-18,-27}, {8,-24}
  local t, gap = 0.04, 0.28
  for k = 1, 5 do
    local u = 1 - t; local lx, ly = u*u*a0[1] + 2*u*t*a1[1] + t*t*a2[1], u*u*a0[2] + 2*u*t*a1[2] + t*t*a2[2]
    local r = (6.2 - 0.6 * k) * s
    local p = HW(H, lx, ly)
    local sock = ellipse(p[1], p[2], r + 3, r * 0.8 + 3); work(sock, {hand="detail", pile=B1, coverage=4, fill=true, clip=sock})
    local e = ellipse(p[1], p[2] + 0.6, r, r * 0.72); work(e, {hand="detail", pile=EYE, coverage=4, fill=true, clip=e})
    local lid = ellipse(p[1], p[2], r + 3, r * 0.8 + 3) * rect(0, 0, 2000, p[2] - r * 0.12); work(lid, {hand="detail", pile=B2, coverage=4, fill=true, clip=lid})
    tb:reload(pile{{"Mars orange",1},{"raw sienna",0.8}}, 0.7); tb:touch(p[1] + 0.3 * r, p[2] + 0.3 * r, {pressure=0.2})
    t = t + gap; gap = gap * 0.72
  end
end

--@ chunk 6
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.7}
for _, H in ipairs(HEADS) do
  local s = H.s
  -- the mouth: a small closed plate of folded bone, seam dark, no light line
  local mc = HW(H, -38, 36)
  local mouth = ellipse(mc[1], mc[2], 7 * s, 11 * s)
  work(mouth, {hand="detail", pile=B1, coverage=4, fill=true, clip=mouth})
  for k = -1, 1 do local q0, q1 = HW(H, -38 + k * 3.5, 27), HW(H, -38 + k * 3.5, 45); d:reload(BD, 0.7); d:stroke({q0, q1}, {pressure={0.1, 0.35, 0.1}, clip=mouth}) end
  local s0, s1 = HW(H, -44, 36), HW(H, -32, 37); d:reload(Q1, 0.8); d:stroke({s0, s1}, {pressure={0.45, 0.45}, clip=mouth:grow(0.5)})
  -- growth rings on the two big cheek plates
  for _, k in ipairs{1, 3} do
    local pts = CHIT_PL[k]
    local cx, cy = 0, 0 for _, p in ipairs(pts) do cx = cx + p[1]; cy = cy + p[2] end; cx, cy = cx / #pts, cy / #pts
    local m = poly(HP(H, pts)) * H.skull
    for r = 1, 3 do local sc = 0.3 + 0.2 * r; local line = {}
      for _, p in ipairs(pts) do line[#line+1] = HW(H, cx + (p[1] - cx) * sc, cy + (p[2] - cy) * sc + 3) end
      line[#line+1] = line[1]
      d:reload(Q1, 0.5); d:stroke(line, {pressure={0.25, 0.25}, ramps={0.1, 0.1}, clip=m}) end
  end
end

--@ chunk 7
wait(2 * 24 * 60)
local function under(x, y)
  for i = #HEADS, 1, -1 do local G = HEADS[i]; if G.ruff:at(x, y) > 0.5 then return B1 end; if G.body:at(x, y) > 0.5 then return RB end end
  local r = math.sqrt(x * x + y * y)
  if r < 420 then return BG2 elseif r < 720 then return BGM else return BG1 end
end
for _, H in ipairs(HEADS) do
  local mc = HW(H, -38, 36)
  local disc = ellipse(mc[1], mc[2], 7 * H.s + 2, 11 * H.s + 2)
  local inside = disc * H.skull
  work(inside, {hand="detail", pile=plateval(H, CHIT_PL[2], CHIT), coverage=4, fill=true, clip=inside})
  local out = disc - H.skull
  if out:area() > 1 then work(out, {hand="detail", pile=under(mc[1] - H.dir * 6, mc[2]), coverage=4, fill=true, clip=out}) end
end

--@ chunk 8
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.1, point=0.7}
for _, H in ipairs(HEADS) do
  -- a narrow fan of folded bone pleats set into the jaw plate, tall rather than wide
  local fan = {}
  local pts = {{-34,26},{-27,24},{-24,40},{-28,52},{-34,52},{-37,40}}
  local m = poly(HP(H, pts), true) * H.skull
  work(m, {hand="detail", pile=BD, coverage=4, fill=true, clip=m})
  for k = 0, 3 do local x = -35 + k * 3; local q0, q1 = HW(H, x, 27), HW(H, x + 1, 50)
    d:reload(k % 2 == 0 and B1 or Q1, 0.7); d:stroke({q0, q1}, {pressure={0.1, 0.35, 0.1}, clip=m}) end
end

--@ chunk 9
wait(2 * 24 * 60)
AV1 = pile{{"zinc white",2},{"cobalt violet",0.8},{"ultramarine ash",0.5}}
AV2 = pile{{"zinc white",1},{"cobalt violet",1},{"ultramarine ash",0.8},{"bone black",0.15}}
AV3 = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"bone black",0.45},{"zinc white",0.3}}
AV4 = pile{{"zinc white",3},{"cerulean blue",0.2},{"cobalt violet",0.2}}
-- table: lit top restated, dark front edge
local top = TABLE - HEADS[6].body - HEADS[7].body
work(top * rect(0,0,460,2000), {hand="detail", pile=Q3, coverage=4, fill=true, clip=top})
work(top * rect(460,0,600,2000), {hand="detail", pile=Q2, coverage=4, fill=true, clip=top})
local edge = poly({{170,690},{780,610},{784,640},{176,714}}) - HEADS[6].body - HEADS[7].body
work(edge, {hand="detail", pile=Q1, coverage=4, fill=true, clip=edge})

--@ chunk 10
wait(3 * 24 * 60)
-- the organ: nested folded lobes lying on the table, each a smaller turned copy of the last, drawn as curved shapes
local O = {505, 598}
local function lobe(cx, cy, rx, ry, rot)
  local t = {}
  for i = 0, 15 do local a = 2 * math.pi * i / 16; local wob = 1 + 0.12 * math.sin(3 * a + rot * 2)
    local x, y = rx * wob * math.cos(a), ry * wob * math.sin(a)
    t[#t+1] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)} end
  return poly(t, true)
end
ORG = {}
local cx, cy, rx, ry, rot = O[1], O[2], 120, 38, -0.12
for k = 1, 6 do
  ORG[k] = lobe(cx, cy, rx, ry, rot)
  cx = cx + rx * 0.22; cy = cy - ry * 0.05; rx = rx * 0.62; ry = ry * 0.66; rot = rot + 0.45
end
ORGM = ORG[1]
local piles = {AV2, AV1, AV3, AV1, AV3, AV4}
for k = 1, 6 do local m = ORG[k] - (ORG[k + 1] or ORG[k]:shrink(400)); work(ORG[k], {hand="detail", pile=piles[k], coverage=4, fill=true, clip=ORG[k]}); wait(1 * 24 * 60) end

--@ chunk 11
wait(4 * 24 * 60)
local piles = {AV1, AV3, AV1, AV2, AV4, AV3}
for k = 1, 6 do
  local m = ORG[k] - (ORG[k + 1] and ORG[k + 1]:grow(1) or ORG[k]:shrink(400))
  work(m, {hand="detail", pile=piles[k], coverage=4, fill=true, clip=m})
  wait(3 * 24 * 60)
end
-- the organ's cold shadow on the bronze
local sh = (ORG[1]:grow(0):offset(0) * everywhere())

--@ chunk 12
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.6, point=0.6}
-- each fold's lit lip toward the window, dark crease on the far side
local cx, cy, rx, ry, rot = 505, 598, 120, 38, -0.12
for k = 1, 6 do
  local lip, crease = {}, {}
  for i = 0, 8 do local a = math.pi * 0.95 + math.pi * 0.6 * i / 8
    local x, y = rx * math.cos(a), ry * math.sin(a); lip[#lip+1] = {cx + x * math.cos(rot) - y * math.sin(rot), cy + x * math.sin(rot) + y * math.cos(rot)}
    local b = a + math.pi; local x2, y2 = rx * 0.96 * math.cos(b), ry * 0.96 * math.sin(b); crease[#crease+1] = {cx + x2 * math.cos(rot) - y2 * math.sin(rot), cy + x2 * math.sin(rot) + y2 * math.cos(rot)} end
  d:reload(AV4, 0.8); d:stroke(lip, {pressure={0.1, 0.6, 0.1}, ramps={0.2, 0.3}})
  d:reload(AV3, 0.8); d:stroke(crease, {pressure={0.1, 0.5, 0.1}, ramps={0.2, 0.3}})
  cx = cx + rx * 0.22; cy = cy - ry * 0.05; rx = rx * 0.62; ry = ry * 0.66; rot = rot + 0.45
end

--@ chunk 13
wait(2 * 24 * 60)
local function seg(a, b, w0, w1) local dx, dy = b[1] - a[1], b[2] - a[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{a[1] + nx*w0, a[2] + ny*w0}, {b[1] + nx*w1, b[2] + ny*w1}, {b[1] - nx*w1, b[2] - ny*w1}, {a[1] - nx*w0, a[2] - ny*w0}}) end
local d = brush{kind="round", width=1.2, point=0.8}
function finger(J, w, P)
  for k = 1, #J - 1 do local m = seg(J[k], J[k+1], w * (1 - 0.1 * (k - 1)), w * (1 - 0.1 * k)); work(m, {hand="detail", pile=P[(k % 2) + 1], coverage=4, fill=true, clip=m}) end
  for k = 2, #J - 1 do d:reload(Q1, 0.8); d:touch(J[k][1], J[k][2], {pressure=0.4}) end
end
-- lecturer's sleeve reaching from his body to above the organ
local sl = ribbon({{760,400},{700,470},{640,520}}, {40, 34, 28})
work(sl, {hand="detail", pile=RB, coverage=4, fill=true, clip=sl})
local sll = ribbon({{752,394},{694,462},{636,512}}, {14, 12, 10}); work(sll, {hand="detail", pile=RBL, coverage=4, fill=true, clip=sll})
local cuff = ribbon({{646,512},{628,530}}, 18); work(cuff, {hand="detail", pile=B2, coverage=4, fill=true, clip=cuff})
local back = poly({{606,520},{630,512},{638,536},{612,546}}); work(back, {hand="detail", pile=Q4, coverage=4, fill=true, clip=back})
-- the tongs: two long bronze arms down to the fold's lifted lip
local tg = brush{kind="round", width=2.6, point=0.5}
tg:reload(Q5, 0.9); tg:stroke({{612,530},{560,560},{520,574}}, {pressure={0.7, 0.6, 0.4}})
tg:reload(Q3, 0.9); tg:stroke({{616,540},{566,566},{524,580}}, {pressure={0.7, 0.6, 0.4}})
-- fingers round the tongs
for _, J in ipairs{{{610,522},{596,526},{586,534},{580,544}}, {{612,532},{598,540},{590,550},{586,560}}, {{616,542},{604,552},{598,562},{596,572}}} do finger(J, 3.2, {Q5, Q4}) end
-- the lifted fold: a thin violet flap rising off the outer lobe where the tongs bite
local flap = poly({{470,566},{522,572},{530,578},{498,590},{462,584}}, true)
work(flap, {hand="detail", pile=AV1, coverage=4, fill=true, clip=flap})
d:reload(AV4, 0.8); d:stroke({{466,568},{500,566},{524,572}}, {pressure={0.2, 0.6, 0.2}})
d:reload(AV3, 0.8); d:stroke({{464,584},{498,592},{528,580}}, {pressure={0.2, 0.5, 0.2}})
-- the nearest onlooker's hand, raised with jointed fingers spread, in wonder or alarm
local sl2 = ribbon({{390,560},{420,520},{432,488}}, {24, 20, 16}); work(sl2, {hand="detail", pile=RBL, coverage=4, fill=true, clip=sl2})
local hb = poly({{424,470},{446,466},{450,490},{428,494}}); work(hb, {hand="detail", pile=Q5, coverage=4, fill=true, clip=hb})
for _, J in ipairs{{{428,470},{424,452},{422,436},{422,422}}, {{436,468},{436,448},{438,432},{440,418}}, {{444,470},{450,452},{456,438},{462,428}}, {{448,480},{462,472},{474,466},{484,462}}} do finger(J, 3.0, {HL, Q5}) end

--@ chunk 14
wait(3 * 24 * 60)
RBM = pile{{"bone black",1.1},{"bone brown",0.9},{"lead white",0.15},{"raw sienna",0.1}}
EXTRA = ribbon({{760,400},{700,470},{640,520}}, {40, 34, 28}) + ribbon({{390,560},{420,520},{432,488}}, {24, 20, 16}) + TABLE + poly({{170,690},{780,610},{784,640},{176,714}})
for i, H in ipairs(HEADS) do
  local front = nil
  for j = i + 1, #HEADS do local G = HEADS[j]; local f = G.body + G.skull; front = front and (front + f) or f end
  local m = H.body - H.skull - H.ruff - EXTRA
  if front then m = m - front end
  work(m, {hand="detail", pile=RB, coverage=4, fill=true, clip=m})
  -- one lit fold plane on the window side, shaped like falling cloth
  local n = HW(H, 30, 66); local s = H.s
  local fold = poly({{n[1] - 30 * s, n[2] + 20 * s}, {n[1] - 10 * s, n[2] + 24 * s}, {n[1] - 40 * s, 714}, {n[1] - 80 * s, 714}}) * m
  work(fold, {hand="detail", pile=RBM, coverage=4, fill=true, clip=fold})
  wait(3 * 24 * 60)
end

--@ chunk 15
wait(2 * 24 * 60)
for i, H in ipairs(HEADS) do
  local front = nil
  for j = i + 1, #HEADS do local G = HEADS[j]; local f = G.body + G.skull; front = front and (front + f) or f end
  local n = HW(H, 30, 66); local s = H.s
  local cx, cy, rx, ry = n[1], n[2] + 6 * s, 74 * s, 22 * s
  local ruff = H.ruff - EXTRA
  if front then ruff = ruff - front end
  local N = 18
  for k = 0, N - 1 do
    local a0, a1 = 2 * math.pi * k / N, 2 * math.pi * (k + 1) / N
    local am = (a0 + a1) / 2
    local w = poly({{cx, cy}, {cx + rx * 1.1 * math.cos(a0), cy + ry * 1.1 * math.sin(a0)}, {cx + rx * 1.1 * math.cos(a1), cy + ry * 1.1 * math.sin(a1)}}) * ruff
    local lit = -math.cos(am) * 0.8 - math.sin(am) * 0.4
    local P = lit > 0.3 and ((k % 2 == 0) and B4 or B3) or (lit > -0.3 and ((k % 2 == 0) and B3 or B2) or ((k % 2 == 0) and B1 or BD))
    if w:area() > 1 then work(w, {hand="detail", pile=P, coverage=4, fill=true, clip=w}) end
  end
end

--@ chunk 16
wait(2 * 24 * 60)
local grey = poly({{170,540},{250,540},{250,620},{170,620}}) - HEADS[7].skull - TABLE
work(grey, {hand="detail", pile=RB, coverage=4, fill=true, clip=grey})
local sl = ribbon({{760,400},{700,470},{640,520}}, {40, 34, 28}) - HEADS[5].skull
work(sl, {hand="detail", pile=RBM, coverage=4, fill=true, clip=sl})
local sll = ribbon({{756,392},{698,462},{640,510}}, {10, 9, 8}); work(sll, {hand="detail", pile=RBL, coverage=4, fill=true, clip=sll})
local sl2 = ribbon({{380,580},{412,530},{428,490}}, {26, 22, 16}) - HEADS[7].skull
work(sl2, {hand="detail", pile=RBM, coverage=4, fill=true, clip=sl2})

--@ chunk 17
wait(3 * 24 * 60)
local hb = poly({{420,470},{444,464},{450,490},{426,496}}); work(hb, {hand="detail", pile=Q5, coverage=4, fill=true, clip=hb})
for _, J in ipairs{{{424,470},{420,452},{418,436},{418,422}}, {{432,466},{432,446},{434,430},{436,416}}, {{440,466},{446,448},{452,434},{458,424}}, {{446,478},{460,470},{472,464},{482,460}}} do finger(J, 3.0, {HL, Q5}) end
local cuff = ribbon({{416,498},{440,494}}, 9); work(cuff, {hand="detail", pile=B2, coverage=4, fill=true, clip=cuff})
local cuff2 = ribbon({{646,512},{628,530}}, 16); work(cuff2, {hand="detail", pile=B2, coverage=4, fill=true, clip=cuff2})

--@ chunk 18
wait(2 * 24 * 60)
VR = pile{{"cobalt violet",0.6},{"ultramarine ash",0.6},{"bone brown",0.8},{"lead white",0.6}}
for _, i in ipairs{4, 5, 6, 7} do
  local H = HEADS[i]
  -- lower jaw plate, the side facing down toward the organ: a narrow cold facet
  local f = poly(HP(H, {{-34,52},{-10,52},{10,40},{20,54},{-4,66},{-24,68}})) * H.skull - poly(HP(H, {{-34,26},{-27,24},{-24,40},{-28,52},{-34,52},{-37,40}}))
  work(f, {hand="detail", pile=VR, coverage=4, fill=true, clip=f})
end

--@ chunk 19
wait(2 * 24 * 60)
for i, H in ipairs(HEADS) do
  local front = nil
  for j = i + 1, #HEADS do local G = HEADS[j]; local f = G.skull + G.ruff; front = front and (front + f) or f end
  for k, pts in ipairs(BONE_PL) do
    if k == 3 or k == 4 or k == 2 then
      local m = poly(HP(H, pts)) * H.skull
      if front then m = m - front end
      local P = (k == 2) and B2 or ((k == 3) and B1 or BD)
      work(m, {hand="detail", pile=P, coverage=4, fill=true, clip=m})
    end
  end
end

--@ chunk 20
wait(2 * 24 * 60)
local d = brush{kind="round", width=1.6, point=0.6}
for i, H in ipairs(HEADS) do
  local front = nil
  for j = i + 1, #HEADS do local G = HEADS[j]; local f = G.skull + G.ruff; front = front and (front + f) or f end
  local clip = H.skull; if front then clip = clip - front end
  for k = 2, 4 do local w = HP(H, BONE_PL[k]); for q = 1, #w do d:reload(Q1, 0.75); d:stroke({w[q], w[q % #w + 1]}, {pressure={0.4, 0.4}, ramps={0.05, 0.05}, clip=clip}) end end
end

--@ chunk 21
wait(2 * 24 * 60)
local g = rect(160, 545, 105, 80) - HEADS[7].skull - HEADS[7].ruff - TABLE - ribbon({{380,580},{412,530},{428,490}}, {26, 22, 16})
work(g, {hand="detail", pile=RB, coverage=4, fill=true, clip=g})
-- a book lying open at the table's near corner, as Tulp's: bone pages, a red cover
local cov = poly({{640,600},{760,584},{770,620},{648,636}}); work(cov, {hand="detail", pile=pile{{"red earth",1},{"bone brown",0.6}}, coverage=4, fill=true, clip=cov})
local pg = poly({{646,596},{756,582},{762,606},{652,620}}); work(pg, {hand="detail", pile=B3, coverage=4, fill=true, clip=pg})
local d = brush{kind="round", width=1.0, point=0.8}
d:reload(Q1, 0.7); d:stroke({{702,588},{706,613}}, {pressure={0.4, 0.4}})
for k = 0, 3 do d:reload(BD, 0.5); d:stroke({{656 + 0, 600 + k * 4}, {696, 595 + k * 4}}, {pressure={0.25, 0.25}}); d:reload(BD, 0.5); d:stroke({{712, 593 + k * 4}, {752, 588 + k * 4}}, {pressure={0.25, 0.25}}) end

--@ chunk 22
wait(1 * 24 * 60)
local g = (TABLE + poly({{170,690},{780,610},{784,640},{176,714}})) * rect(0, 0, 340, 714) - HEADS[7].skull - HEADS[7].ruff - ribbon({{380,580},{412,530},{428,490}}, {26, 22, 16})
work(g, {hand="detail", pile=RB, coverage=4, fill=true, clip=g})

--@ chunk 23
wait(2 * 24 * 60)
VR2 = pile{{"bone brown",1.2},{"cobalt violet",0.4},{"ultramarine ash",0.4},{"lead white",0.25}}
for _, i in ipairs{4, 5, 6, 7} do
  local H = HEADS[i]
  local front = nil
  for j = i + 1, #HEADS do local G = HEADS[j]; local f = G.skull + G.ruff; front = front and (front + f) or f end
  local f = poly(HP(H, {{-34,52},{-10,52},{10,40},{20,54},{-4,66},{-24,68}})) * H.skull - poly(HP(H, {{-34,26},{-27,24},{-24,40},{-28,52},{-34,52},{-37,40}}))
  if front then f = f - front end
  work(f, {hand="detail", pile=VR2, coverage=4, fill=true, clip=f})
end
