-- easel session "breach_far": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.5, linen={16,18}, seed=5150, ground={{pile={{"ultramarine blue",1},{"magenta",0.3},{"bone black",1.0},{"lead white",0.45},{"viridian",0.2}}, um=140, apply="knife", texture=0.4}}}
FN = noise{seed=8, period=320, octaves=3}
-- the drift of the space: it turns slowly round the staging-structure
SC = {760, 230}
function drift(x, y) return math.atan(y - SC[2], x - SC[1]) + math.pi / 2 + 0.25 + 0.7 * FN(x, y) end
GOLDPT = {92, 236}
print(W, H)

--@ chunk 2
-- the field: deep cold everywhere; a colder haze round the structure, the void under the bridge darkest
local DEEP = pile{{"ultramarine blue",2},{"viridian",0.5},{"bone black",1.2},{"lead white",0.3},{"magenta",0.2}}
local HAZE = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.3},{"cobalt violet",0.4}}
local VOID = pile{{"ultramarine blue",1.5},{"magenta",0.4},{"bone black",1.8}}
local MAGH = pile{{"magenta",1},{"cobalt violet",1},{"ultramarine blue",0.8},{"lead white",0.6}}
work(everywhere(), {hand="body", pile=DEEP, coverage=1.6, fill=true, angle=drift, length={40, 100}, seed=201})
work(ellipse(760, 230, 330, 220):soften(90), {hand="body", pile=HAZE, coverage=1.0, angle=drift, length={40, 100}, seed=202})
work(ellipse(560, 430, 200, 90):soften(70), {hand="body", pile=MAGH, coverage=0.7, angle=drift, length={30, 80}, seed=203})
work(rect(-10, 520, 1020, 160):soften(60), {hand="body", pile=VOID, coverage=1.4, fill=true, angle=drift, length={40, 100}, seed=204})
blend(everywhere(), {angle=drift, tool={kind="badger", width=18}, seed=205})

--@ chunk 3
-- the staging-space: hinged planes that unfold into more of themselves, organs of one thing
ICEF  = pile{{"cerulean blue",1},{"viridian",0.3},{"lead white",2.5},{"zinc white",0.5}}
ICEM  = pile{{"cerulean blue",1},{"ultramarine blue",0.6},{"lead white",1.4},{"viridian",0.2}}
LIMEF = pile{{"emerald green",1},{"lemon chrome",0.3},{"lead white",1.6},{"cerulean blue",0.4}}
MAGF  = pile{{"magenta",1},{"cobalt violet",1},{"lead white",0.8},{"ultramarine blue",0.3}}
VIOF  = pile{{"ultramarine blue",1.5},{"magenta",0.5},{"bone black",0.7},{"lead white",0.4}}
FAR_I = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",1},{"bone black",0.4}}
FAR_M = pile{{"cobalt violet",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.5}}
FAR_L = pile{{"viridian",0.6},{"cerulean blue",1},{"lead white",0.9},{"bone black",0.5}}
NEAR = {ICEF, LIMEF, MAGF, ICEM, VIOF}
FARP = {FAR_I, FAR_L, FAR_M, FAR_I, FAR_M}
STRUCT = {}
local budget = 70
local function unfold(A, B, th, w, depth, k, far)
  if depth <= 0 or budget <= 0 or w < 8 then return end
  budget = budget - 1
  local sk = rand(-0.25, 0.25)
  local A2 = {A[1] + w * math.cos(th - sk), A[2] + w * math.sin(th - sk)}
  local B2 = {B[1] + w * math.cos(th + sk), B[2] + w * math.sin(th + sk)}
  -- the new hinge grows or shrinks about its middle
  local g = rand(0.8, 1.15)
  local mx, my = (A2[1] + B2[1]) / 2, (A2[2] + B2[2]) / 2
  A2 = {mx + (A2[1] - mx) * g, my + (A2[2] - my) * g}
  B2 = {mx + (B2[1] - mx) * g, my + (B2[2] - my) * g}
  local pts = {A, B, B2, A2}
  local q = poly(pts)
  local p = (far and FARP or NEAR)[(k % 5) + 1]
  work(q, {hand="detail", tool={kind="filbert", width=math.max(2, math.min(5, w / 18))}, pile=p, coverage=3.2, fill=true,
    angle=th + math.pi / 2, clip=q, seed=3000 + #STRUCT})
  STRUCT[#STRUCT + 1] = {pts = pts, far = far}
  unfold(A2, B2, th + rand(0.5, 1.1) * ((k % 2 == 0) and 1 or -1), w * rand(0.7, 0.9), depth - 1, k + 1, far)
  if rand(0, 1) < 0.5 then
    unfold(B, B2, th + rand(-1.6, -0.6), w * rand(0.55, 0.75), depth - 2, k + 2, far)
  end
end
-- far roots first, near last, so the near overlap the far
unfold({540,112}, {566,100}, -0.4, 34, 5, 1, true)
unfold({880,96}, {912,110}, -1.2, 40, 5, 2, true)
unfold({960,250}, {985,280}, 3.6, 38, 4, 3, true)
unfold({640,262}, {688,240}, -1.0, 78, 6, 0, false)
unfold({770,330}, {820,350}, -0.3, 92, 6, 2, false)
unfold({860,440}, {930,420}, -1.9, 110, 5, 4, false)
print(#STRUCT, budget)

--@ chunk 4
-- vaster: more of the thing, larger near, a ring of organs round the eye of the turning
local budget = 90
local function unfold(A, B, th, w, depth, k, far)
  if depth <= 0 or budget <= 0 or w < 8 then return end
  budget = budget - 1
  local sk = rand(-0.25, 0.25)
  local A2 = {A[1] + w * math.cos(th - sk), A[2] + w * math.sin(th - sk)}
  local B2 = {B[1] + w * math.cos(th + sk), B[2] + w * math.sin(th + sk)}
  local g = rand(0.8, 1.15)
  local mx, my = (A2[1] + B2[1]) / 2, (A2[2] + B2[2]) / 2
  A2 = {mx + (A2[1] - mx) * g, my + (A2[2] - my) * g}
  B2 = {mx + (B2[1] - mx) * g, my + (B2[2] - my) * g}
  local pts = {A, B, B2, A2}
  local q = poly(pts)
  local p = (far and FARP or NEAR)[(k % 5) + 1]
  work(q, {hand="detail", tool={kind="filbert", width=math.max(2, math.min(5, w / 18))}, pile=p, coverage=3.2, fill=true,
    angle=th + math.pi / 2, clip=q, seed=4000 + #STRUCT})
  STRUCT[#STRUCT + 1] = {pts = pts, far = far}
  unfold(A2, B2, th + rand(0.5, 1.1) * ((k % 2 == 0) and 1 or -1), w * rand(0.7, 0.9), depth - 1, k + 1, far)
  if rand(0, 1) < 0.55 then unfold(B, B2, th + rand(-1.6, -0.6), w * rand(0.55, 0.75), depth - 2, k + 2, far) end
end
-- far, round the eye
unfold({700,140}, {730,128}, 2.6, 46, 5, 1, true)
unfold({600,190}, {612,160}, -2.2, 40, 4, 3, true)
unfold({830,180}, {850,206}, 0.4, 44, 5, 0, true)
unfold({480,240}, {500,214}, -2.6, 36, 4, 2, true)
-- near, huge
unfold({620,420}, {700,380}, -0.9, 150, 5, 0, false)
unfold({960,60}, {1000,120}, 2.5, 130, 5, 3, false)
unfold({990,380}, {1010,470}, 3.3, 140, 4, 1, false)
print(#STRUCT, budget)

--@ chunk 5
-- the bridge: a road of tiles laid over nothing, narrowing as it goes in, some tiles lifting, some gone
BPATH = {{-30,650},{120,612},{260,575},{380,535},{480,488},{560,446},{620,410}}
local function seglen(a, b) return math.sqrt((b[1] - a[1])^2 + (b[2] - a[2])^2) end
local total, lens = 0, {}
for i = 1, #BPATH - 1 do lens[i] = seglen(BPATH[i], BPATH[i + 1]); total = total + lens[i] end
function bpt(t)
  local d = t * total
  for i = 1, #BPATH - 1 do
    if d <= lens[i] or i == #BPATH - 1 then
      local f = clamp(d / lens[i], 0, 1)
      local a, b = BPATH[i], BPATH[i + 1]
      return {lerp(a[1], b[1], f), lerp(a[2], b[2], f)}, {(b[1] - a[1]) / lens[i], (b[2] - a[2]) / lens[i]}
    end
    d = d - lens[i]
  end
end
function bwidth(t) return lerp(64, 9, t^0.8) end
TILES = {}
local n = 22
for i = 0, n - 1 do
  local t0, t1 = i / n, (i + 0.86) / n
  local p0, d0 = bpt(t0)
  local p1, d1 = bpt(t1)
  local w0, w1 = bwidth(t0), bwidth(t1)
  -- across the bridge: perpendicular to the way, flattened toward horizontal (seen from above and behind)
  local function across(d, w) local nx, ny = -d[2], d[1]; return {nx * w * 0.55 + w * 0.8, ny * w * 0.55} end
  local a0, a1 = across(d0, w0), across(d1, w1)
  local lift = (i % 5 == 3) and rand(6, 14) * (1 - t0) or 0
  local gone = (i % 7 == 5)
  if not gone then
    local pts = {{p0[1] - a0[1], p0[2] - a0[2]}, {p0[1] + a0[1], p0[2] + a0[2]}, {p1[1] + a1[1], p1[2] + a1[2] - lift}, {p1[1] - a1[1], p1[2] - a1[2] - lift}}
    local side = {pts[1], pts[2], {pts[2][1], pts[2][2] + 6 * (1 - t0) + 1.5}, {pts[1][1], pts[1][2] + 6 * (1 - t0) + 1.5}}
    local far = t0 > 0.55
    local top = poly(pts)
    local sd = poly(side) - top
    work(sd, {hand="detail", pile=far and FAR_M or VIOF, coverage=3.5, fill=true, angle=0, clip=sd, seed=5000 + i})
    work(top, {hand="detail", tool={kind="filbert", width=math.max(2, w0 / 14)}, pile=far and FAR_I or ((i % 3 == 1) and ICEM or ICEF),
      coverage=3.2, fill=true, angle=math.atan(d0[2], d0[1]), clip=top, seed=5050 + i})
    TILES[#TILES + 1] = {pts = pts, t = t0, far = far}
  end
end
print(#TILES)

--@ chunk 6
-- the pilgrim: a heavier, stranger frame, hunched and broad, walking in; and far behind him the last warm point
local F = bpt(0.34)
local fx, fy = F[1] + 4, F[2] - 2
FOOT = {fx, fy}
local DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
local CRIM = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
PBODY = ribbon({{fx - 4, fy - 40}, {fx - 9, fy - 20}, {fx - 13, fy}}, 9) + ribbon({{fx + 5, fy - 40}, {fx + 9, fy - 20}, {fx + 11, fy - 4}}, 9)
  + poly({{fx - 16, fy - 42}, {fx + 14, fy - 42}, {fx + 22, fy - 70}, {fx + 12, fy - 86}, {fx - 14, fy - 84}, {fx - 22, fy - 66}})
  + ellipse(fx + 10, fy - 88, 7, 7) + ellipse(fx - 17, fy - 78, 10, 8) + ellipse(fx + 17, fy - 80, 10, 8)
  + ribbon({{fx - 22, fy - 74}, {fx - 28, fy - 50}, {fx - 30, fy - 30}}, 7) + ribbon({{fx + 22, fy - 76}, {fx + 32, fy - 62}, {fx + 37, fy - 54}}, 7)
PSTAFF = ribbon({{fx + 46, fy + 2}, {fx + 38, fy - 50}, {fx + 30, fy - 112}}, 3)
PRAG = poly({{fx - 14, fy - 84}, {fx + 6, fy - 85}, {fx + 2, fy - 60}, {fx - 10, fy - 47}, {fx - 36, fy - 40}, {fx - 46, fy - 44}, {fx - 28, fy - 60}}, true)
work(PBODY, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=1.5, clip=PBODY, seed=6001})
work(PSTAFF, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=-1.4, clip=PSTAFF, seed=6002})
work(PRAG, {hand="detail", pile=CRIM, coverage=4, fill=true, angle=2.8, clip=PRAG, seed=6003})
-- the TESTAMENT: a tiny gold point, a breath of warmth round it
local G1 = pile{{"Mars orange",1},{"lead white",1.2},{"Indian yellow",0.5}}
local G2 = pile{{"lead white",3},{"lemon chrome",0.6}}
local gx, gy = GOLDPT[1], GOLDPT[2]
stipple(ellipse(gx, gy, 26, 26), {pile=G1, width=3, coverage=function(x, y) local d = math.sqrt((x - gx)^2 + (y - gy)^2) / 26; return clamp(1.2 * (1 - d), 0, 1.2) end, feather=0.9, pressure={0.15, 0.3}, seed=6004})
blend(ellipse(gx, gy, 30, 30), {angle=0, tool={kind="badger", width=8}, seed=6005})
local core = ellipse(gx, gy, 2.6, 2.6)
work(core, {hand="detail", pile=G2, coverage=4, fill=true, angle=0, clip=core, seed=6006})
print(fx, fy)

--@ chunk 7
-- the gold point's halo came up as a grey disc: put the field back over it; tiles falling off the bridge into the nothing;
-- far specks of the structure toward its eye
local gx, gy = GOLDPT[1], GOLDPT[2]
local FIELDC = pile{{"ultramarine blue",2},{"viridian",0.3},{"bone black",1.1},{"lead white",0.55},{"magenta",0.2}}
local disc = ellipse(gx, gy, 32, 32)
work(disc, {hand="body", tool="filbert 4", pile=FIELDC, coverage=3.5, fill=true, angle=drift, edge="soft", clip=disc:grow(4), seed=7001})
blend(disc:grow(6), {angle=drift, tool={kind="badger", width=10}, seed=7002})
-- falling tiles, tumbling down into the void below the bridge
local falls = {{150,640,14,6,0.5}, {330,600,10,4,-0.7}, {420,575,8,3,1.0}, {270,650,9,4,1.4}, {505,520,6,2.5,-0.3}, {80,600,8,3,-1.1}}
for i, f in ipairs(falls) do
  local c, s = math.cos(f[5]), math.sin(f[5])
  local function P(u, v) return {f[1] + u * c - v * s, f[2] + u * s + v * c} end
  local q = poly({P(-f[3], -f[4]), P(f[3], -f[4]), P(f[3], f[4]), P(-f[3], f[4])})
  work(q, {hand="detail", pile=(i % 2 == 0) and ICEM or FAR_I, coverage=3.5, fill=true, angle=f[5], clip=q, seed=7010 + i})
end
-- the far specks, fainter and smaller toward the eye of the turning
for i = 1, 22 do
  local a = rand(0, 2 * math.pi)
  local r = rand(30, 150)
  local x, y = SC[1] + r * math.cos(a) * 1.2, SC[2] + r * math.sin(a) * 0.8
  local sz = 2 + r / 40
  local q = poly({{x - sz, y - sz * 0.5}, {x + sz, y - sz * 0.7}, {x + sz * 0.8, y + sz * 0.5}, {x - sz, y + sz * 0.6}})
  work(q, {hand="detail", pile=FARP[(i % 5) + 1], coverage=3.5, fill=true, angle=a, clip=q, seed=7100 + i})
end

--@ chunk 8
print(wait(3*24*60)); print(drying(700,250), drying(200,560))

--@ chunk 9
-- on dry paint: hinges and joints that make the planes floors; the bridge's joints; the pilgrim's rims and cross; the gold point
local rig = brush{kind="rigger", width=1.8, point=0.85}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.15, 0.3}}) end
local ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local ICED = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.3}}
local FARL = pile{{"cerulean blue",1},{"lead white",1.5},{"ultramarine blue",0.6}}
local GOLD = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.3}}
local function L(a, b, f) return {lerp(a[1], b[1], f), lerp(a[2], b[2], f)} end
for _, s in ipairs(STRUCT) do
  local a, b, c, d = s.pts[1], s.pts[2], s.pts[3], s.pts[4]
  local size = math.sqrt((d[1] - a[1])^2 + (d[2] - a[2])^2)
  if s.far then
    S(FARL, 0.5, {a, b}, {0.25, 0.2})
  else
    S(ICE, 0.7, {a, b}, {0.45, 0.35})
    if size > 40 then
      for _, f in ipairs({0.33, 0.66}) do
        S(ICED, 0.5, {L(a, d, f), L(b, c, f)}, {0.28, 0.22})
        S(ICED, 0.5, {L(a, b, f), L(d, c, f)}, {0.28, 0.22})
      end
    end
  end
end
for _, t in ipairs(TILES) do
  local a, b, c, d = t.pts[1], t.pts[2], t.pts[3], t.pts[4]
  S(t.far and FARL or ICE, 0.6, {d, c}, {t.far and 0.2 or 0.4, t.far and 0.15 or 0.3})
  if not t.far then S(ICED, 0.5, {L(a, b, 0.5), L(d, c, 0.5)}, {0.3, 0.25}) end
end
-- the pilgrim: the structure's cold on everything that faces it, the faint warm of home on what faces back
local fx, fy = FOOT[1], FOOT[2]
S(ICE, 0.7, {{fx + 14, fy - 86}, {fx + 22, fy - 72}, {fx + 18, fy - 56}, {fx + 14, fy - 44}}, {0.4, 0.3})
S(ICE, 0.7, {{fx + 12, fy - 95}, {fx + 17, fy - 88}}, {0.4, 0.3})
S(ICE, 0.6, {{fx + 25, fy - 80}, {fx + 30, fy - 70}, {fx + 38, fy - 57}}, {0.35, 0.3})
S(ICE, 0.6, {{fx + 32, fy - 110}, {fx + 40, fy - 50}, {fx + 47, fy}}, {0.3, 0.2})
S(ICE, 0.6, {{fx + 9, fy - 38}, {fx + 14, fy - 20}, {fx + 15, fy - 6}}, {0.3, 0.2})
S(GOLD, 0.5, {{fx - 26, fy - 82}, {fx - 28, fy - 72}}, {0.25, 0.15})
S(GOLD, 0.4, {{fx - 33, fy - 52}, {fx - 34, fy - 32}}, {0.2, 0.1})
-- the bone cross on his back, over the rag
local fl = brush{kind="flat", width=3.2}
fl:reload(BONE, 0.9); fl:stroke({{fx - 4, fy - 82}, {fx - 4, fy - 58}}, {pressure={0.8, 0.8}})
fl:reload(BONE, 0.9); fl:stroke({{fx - 12, fy - 75}, {fx + 4, fy - 75}}, {pressure={0.8, 0.8}})
S(ICE, 0.5, {{fx - 2, fy - 82}, {fx - 2, fy - 59}}, {0.25, 0.2})
-- the TESTAMENT's last light: a hot core and a few short warm rays
local gx, gy = GOLDPT[1], GOLDPT[2]
local WR = pile{{"Mars orange",1},{"lead white",1.5},{"cadmium yellow",0.5}}
for k = 0, 7 do
  local a = k * math.pi / 4 + 0.2
  S(WR, 0.4, {{gx + 2 * math.cos(a), gy + 2 * math.sin(a)}, {gx + 9 * math.cos(a), gy + 9 * math.sin(a)}}, {0.3, 0.0})
end
local tip = brush{kind="round", width=3, point=0.5}
tip:reload(pile{{"zinc white",4},{"lemon chrome",0.4}}, 1.0); tip:touch(gx, gy, {pressure=0.9})

--@ chunk 10
-- the legs came up pale over the light tiles: heavier, darker legs on the dry tiles; the rag torn into hanging strips; plates on his back
local fx, fy = FOOT[1], FOOT[2]
local DARKSTEEL = pile{{"bone black",1.8},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local legs = ribbon({{fx - 4, fy - 42}, {fx - 9, fy - 20}, {fx - 14, fy + 1}}, 12) + ribbon({{fx + 5, fy - 42}, {fx + 9, fy - 20}, {fx + 11, fy - 3}}, 12)
work(legs, {hand="detail", pile=DARKSTEEL, coverage=5, fill=true, angle=1.6, clip=legs, seed=10001})
local CRIMD = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.3}}
local CRIM = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
local fb = brush{kind="filbert", width=3}
local rig = brush{kind="rigger", width=2.4, point=0.8}
-- torn strips hanging from the rag's lower edge, lifting toward the left
for i, s in ipairs({{-10,-50,-14,-34}, {-18,-46,-24,-30}, {-27,-43,-36,-30}, {-36,-42,-48,-34}, {-4,-56,-5,-40}}) do
  rig:reload((i % 2 == 0) and CRIMD or CRIM, 0.8)
  rig:stroke({{fx + s[1], fy + s[2]}, {fx + (s[1] + s[3]) / 2 - 2, fy + (s[2] + s[4]) / 2}, {fx + s[3], fy + s[4]}}, {pressure={0.8, 0.1}, ramps={0.05, 0.6}})
end
-- shadow down the rag's side away from home
fb:reload(CRIMD, 0.6); fb:stroke({{fx + 2, fy - 82}, {fx, fy - 66}, {fx - 8, fy - 52}}, {pressure={0.5, 0.4}})
-- the strange frame: a ridge of plates down the spine above the rag, an extra plate jutting from the shoulder
local ICE = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
for k = 0, 3 do
  rig:reload(ICE, 0.5); rig:stroke({{fx + 6 + k * 2, fy - 90 + k * 3}, {fx + 14 + k * 2, fy - 88 + k * 3}}, {pressure={0.35, 0.2}})
end
local spur = poly({{fx + 18, fy - 86}, {fx + 30, fy - 98}, {fx + 26, fy - 82}})
work(spur, {hand="detail", pile=DARKSTEEL, coverage=4.5, fill=true, angle=-0.8, clip=spur, seed=10002})
rig:reload(ICE, 0.6); rig:stroke({{fx + 19, fy - 87}, {fx + 30, fy - 98}}, {pressure={0.35, 0.25}})

--@ chunk 11
for i,s in ipairs(STRUCT) do local t={} for _,p in ipairs(s.pts) do t[#t+1]=string.format("%.1f,%.1f",p[1],p[2]) end print(i, s.far and 1 or 0, table.concat(t," ")) end

--@ chunk 12
SKYC = pile{{"ultramarine blue",2},{"viridian",0.3},{"bone black",1.3},{"lead white",0.35},{"magenta",0.2}}
PIDX = {4, 0, 4, 5, 4, 4, 4, 5, 4, 5, 4, 5, 4, 4, 4, 4, 4, 5, 0, 4, 0, 1, 2, 3, 4, 5, 1, 1, 4, 5, 1, 3, 0, 5, 1, 0, 0, 5, 0, 2, 3, 3, 5, 0, 2, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 4, 5, 4, 4, 4, 0, 0, 0, 0, 0, 5, 4, 5, 4, 4, 1, 2, 3, 4, 4, 5, 3, 4, 5, 4, 5, 1, 2, 3, 3, 2, 3, 2, 3, 4, 4, 4, 5}  -- each plane's colour, read from the canvas
-- (a) paint the grey disc round the TESTAMENT point out, back to sky
local gx, gy = GOLDPT[1], GOLDPT[2]
local disc = ellipse(gx, gy, 40, 40)
work(disc, {hand="body", tool="filbert 4", pile=SKYC, coverage=3.8, fill=true, angle=drift, edge="soft", clip=disc:grow(6), seed=11001})
blend(disc:grow(8), {angle=drift, tool={kind="badger", width=10}, seed=11002})
-- (b) where a near plane lies over earlier planes, the earlier planes' joint lines run across it: repaint those parts in its own colour
local later = {}
local acc = nil
for i = #STRUCT, 1, -1 do later[i] = acc; local q = poly(STRUCT[i].pts); acc = acc and (acc + q) or q end
local back = nil
for i, s in ipairs(STRUCT) do
  local q = poly(s.pts)
  if back and not s.far then
    local r = q * back:grow(3)
    if later[i] then r = r - later[i]:grow(1) end
    if PIDX[i] > 0 then
    local p = NEAR[PIDX[i]]
    work(r, {hand="detail", tool={kind="filbert", width=3}, pile=p, coverage=3.5, fill=true, angle=0.3, clip=q, seed=11100 + i})
    end
  end
  back = back and (back + q) or q
end

--@ chunk 13
-- the pilgrim redrawn larger and stranger, seen from behind: a broad hunched plate back with a spur, sensor masts
-- rising from the shoulders, digitigrade legs, a long arm out to the staff. All dark first; the rag goes on when this is dry.
local fx, fy = FOOT[1], FOOT[2]
local DARKSTEEL = pile{{"bone black",1.8},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local DS2 = pile{{"bone black",1.4},{"ultramarine blue",0.8},{"viridian",0.3},{"lead white",0.25}}
NBACK = poly({{fx - 25, fy - 58}, {fx + 22, fy - 58}, {fx + 31, fy - 92}, {fx + 17, fy - 113}, {fx - 20, fy - 111}, {fx - 32, fy - 88}})
NHELM = poly({{fx - 3, fy - 112}, {fx + 10, fy - 120}, {fx + 17, fy - 113}, {fx + 12, fy - 104}, {fx, fy - 104}})
NPAUL = poly({{fx - 38, fy - 100}, {fx - 26, fy - 112}, {fx - 12, fy - 106}, {fx - 16, fy - 94}, {fx - 34, fy - 90}}, true)
  + poly({{fx + 12, fy - 108}, {fx + 26, fy - 116}, {fx + 38, fy - 104}, {fx + 34, fy - 92}, {fx + 16, fy - 96}}, true)
NSPUR = poly({{fx + 30, fy - 108}, {fx + 52, fy - 132}, {fx + 36, fy - 100}})
NLEGS = ribbon({{fx - 7, fy - 58}, {fx - 16, fy - 36}, {fx - 7, fy - 17}, {fx - 15, fy + 1}}, 12)
  + ribbon({{fx + 8, fy - 58}, {fx + 16, fy - 37}, {fx + 9, fy - 18}, {fx + 13, fy - 3}}, 12)
NFEET = poly({{fx - 24, fy - 2}, {fx - 8, fy - 4}, {fx - 6, fy + 3}, {fx - 22, fy + 4}}) + poly({{fx + 6, fy - 6}, {fx + 20, fy - 6}, {fx + 21, fy}, {fx + 6, fy}})
NARMS = ribbon({{fx + 30, fy - 98}, {fx + 41, fy - 80}, {fx + 38, fy - 62}}, 9) + ribbon({{fx - 32, fy - 94}, {fx - 41, fy - 70}, {fx - 42, fy - 46}}, 9)
  + ribbon({{fx - 22, fy - 84}, {fx - 30, fy - 66}, {fx - 26, fy - 52}}, 5)
NMASTS = ribbon({{fx - 28, fy - 108}, {fx - 33, fy - 130}, {fx - 40, fy - 156}}, 2.6) + ribbon({{fx + 22, fy - 114}, {fx + 25, fy - 132}, {fx + 30, fy - 146}}, 2.2)
  + ellipse(fx - 40, fy - 158, 4, 3) + ellipse(fx + 30, fy - 148, 3, 2.5)
NSTAFF = ribbon({{fx + 46, fy + 2}, {fx + 38, fy - 50}, {fx + 27, fy - 140}}, 3.4)
NFIG = NBACK + NHELM + NPAUL + NSPUR + NLEGS + NFEET + NARMS + NMASTS
work(NFIG, {hand="detail", pile=DARKSTEEL, coverage=5, fill=true, angle=1.5, clip=NFIG, seed=12001})
work(NSTAFF, {hand="detail", pile=DARKSTEEL, coverage=5, fill=true, angle=-1.45, clip=NSTAFF, seed=12002})
-- the plate back: a slightly lighter, colder plate in the middle of the back, so it reads as a shell
local shell = poly({{fx - 14, fy - 66}, {fx + 14, fy - 66}, {fx + 20, fy - 92}, {fx + 10, fy - 106}, {fx - 12, fy - 104}, {fx - 20, fy - 88}})
work(shell, {hand="detail", pile=DS2, coverage=3.5, fill=true, angle=1.5, clip=shell, seed=12003})

--@ chunk 14
print(wait(4*24*60)); print(drying(FOOT[1],FOOT[2]-80))

--@ chunk 15
-- the crimson rag, on dry paint: over the shoulders and down the back, torn into strips that hang and lift toward home
local fx, fy = FOOT[1], FOOT[2]
local CRIM  = pile{{"cadmium red",1},{"rose madder",0.8},{"Mars red",0.5},{"bone brown",0.3}}
local CRIMD = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.3}}
NRAG = poly({{fx - 26, fy - 107}, {fx + 12, fy - 109}, {fx + 10, fy - 82}, {fx - 4, fy - 70}, {fx - 28, fy - 64}, {fx - 38, fy - 72}, {fx - 34, fy - 94}}, true)
work(NRAG, {hand="detail", tool={kind="filbert", width=3}, pile=CRIM, coverage=4.5, fill=true, angle=2.2, clip=NRAG, seed=13001})
local fb = brush{kind="filbert", width=3.4}
local strips = {
  {{fx + 6, fy - 80}, {fx + 5, fy - 66}, {fx + 2, fy - 52}},
  {{fx - 2, fy - 72}, {fx - 5, fy - 58}, {fx - 9, fy - 44}},
  {{fx - 10, fy - 68}, {fx - 15, fy - 54}, {fx - 22, fy - 42}},
  {{fx - 18, fy - 66}, {fx - 26, fy - 54}, {fx - 36, fy - 46}},
  {{fx - 27, fy - 65}, {fx - 38, fy - 56}, {fx - 52, fy - 52}},
  {{fx - 34, fy - 70}, {fx - 46, fy - 66}, {fx - 60, fy - 66}},
}
for i, s in ipairs(strips) do
  fb:reload((i % 2 == 0) and CRIMD or CRIM, 0.8)
  fb:stroke(s, {pressure={0.75, 0.05}, ramps={0.05, 0.65}})
end
-- folds: a darker crimson in the hollows of the drape
fb:reload(CRIMD, 0.6); fb:stroke({{fx - 4, fy - 104}, {fx - 8, fy - 88}, {fx - 16, fy - 72}}, {pressure={0.5, 0.3}})
fb:reload(CRIMD, 0.6); fb:stroke({{fx + 8, fy - 104}, {fx + 6, fy - 90}}, {pressure={0.45, 0.3}})

--@ chunk 16
print(wait(4*24*60)); print(drying(FOOT[1]-10,FOOT[2]-90))

--@ chunk 17
-- on dry paint: the structure's joints again, fewer, each stopping at the edge of whatever lies in front of it;
-- the cross on the rag; the cold down his right edge; the TESTAMENT's point and its thin rays
local rig = brush{kind="rigger", width=1.8, point=0.85}
local function S(p, ld, pts, pr, clip) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.15, 0.3}, clip=clip}) end
local ICE  = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local ICED = pile{{"cerulean blue",1},{"ultramarine blue",1},{"lead white",0.6},{"bone black",0.3}}
local FARL = pile{{"cerulean blue",1},{"lead white",1.5},{"ultramarine blue",0.6}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.3}}
local GOLD = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local function L(a, b, f) return {lerp(a[1], b[1], f), lerp(a[2], b[2], f)} end
local front = nil
for i = #STRUCT, 1, -1 do
  local s = STRUCT[i]
  local q = poly(s.pts)
  local vis = front and (q - front:grow(1)) or q
  local a, b, c, d = s.pts[1], s.pts[2], s.pts[3], s.pts[4]
  local size = math.sqrt((d[1] - a[1])^2 + (d[2] - a[2])^2)
  if s.far then
    S(FARL, 0.5, {a, b}, {0.22, 0.18}, vis)
  else
    S(ICE, 0.7, {a, b}, {0.42, 0.34}, vis)
    local fs = (size > 90) and {0.33, 0.66} or ((size > 50) and {0.5} or {})
    for _, f in ipairs(fs) do
      S(ICED, 0.5, {L(a, d, f), L(b, c, f)}, {0.26, 0.2}, vis)
      S(ICED, 0.5, {L(a, b, f), L(d, c, f)}, {0.26, 0.2}, vis)
    end
  end
  front = front and (front + q) or q
end
-- the pilgrim
local fx, fy = FOOT[1], FOOT[2]
local fl = brush{kind="flat", width=3.6}
fl:reload(BONE, 0.9); fl:stroke({{fx - 6, fy - 104}, {fx - 6, fy - 76}}, {pressure={0.85, 0.85}})
fl:reload(BONE, 0.9); fl:stroke({{fx - 15, fy - 96}, {fx + 3, fy - 96}}, {pressure={0.85, 0.85}})
S(ICE, 0.5, {{fx - 4, fy - 104}, {fx - 4, fy - 77}}, {0.22, 0.18})
for _, e in ipairs({
  {{fx + 10, fy - 120}, {fx + 17, fy - 113}, {fx + 13, fy - 105}},
  {{fx + 26, fy - 116}, {fx + 38, fy - 104}, {fx + 34, fy - 93}},
  {{fx + 34, fy - 110}, {fx + 52, fy - 132}},
  {{fx + 31, fy - 92}, {fx + 27, fy - 76}, {fx + 22, fy - 59}},
  {{fx + 35, fy - 97}, {fx + 45, fy - 80}, {fx + 42, fy - 62}},
  {{fx + 14, fy - 58}, {fx + 22, fy - 37}, {fx + 15, fy - 18}, {fx + 19, fy - 3}},
  {{fx + 23, fy - 114}, {fx + 26, fy - 132}, {fx + 32, fy - 147}},
  {{fx + 30, fy - 140}, {fx + 41, fy - 50}, {fx + 49, fy + 1}},
}) do S(ICE, 0.7, e, {0.42, 0.3}) end
S(GOLD, 0.35, {{fx - 37, fy - 101}, {fx - 27, fy - 113}}, {0.2, 0.12})
S(GOLD, 0.3, {{fx - 30, fy - 110}, {fx - 36, fy - 132}}, {0.15, 0.1})
-- the TESTAMENT: a tiny gold point, four thin rays
local gx, gy = GOLDPT[1], GOLDPT[2]
local hair = brush{kind="rigger", width=1.2, point=0.95}
local WR = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
for _, a in ipairs({0.15, 1.75, 3.3, 4.75}) do
  local len = rand(9, 14)
  hair:reload(WR, 0.5)
  hair:stroke({{gx + 1.5 * math.cos(a), gy + 1.5 * math.sin(a)}, {gx + len * math.cos(a), gy + len * math.sin(a)}}, {pressure={0.4, 0.0}, ramps={0.05, 0.8}})
end
local tip = brush{kind="round", width=2.6, point=0.5}
tip:reload(GOLD, 1.0); tip:touch(gx, gy, {pressure=0.9})
tip:reload(pile{{"zinc white",4},{"lemon chrome",0.5}}, 1.0); tip:touch(gx, gy, {pressure=0.5})
