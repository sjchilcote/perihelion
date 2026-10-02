-- easel session "shrieker": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={22,20}, seed=23,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=120, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"raw sienna",0.6},{"lead white",0.5},{"ultramarine blue",0.6}}, um=40, apply="brush"}}}
print(W, H)

--@ chunk 2
VP = {560, 690}
function rarch(bx, by, hw, h, a, n)
  n = n or 24
  local loc = {{-hw, 0}}
  for i = 0, n do local t = math.pi - math.pi * i / n; loc[#loc+1] = {hw * math.cos(t), (h - hw) + hw * math.sin(t)} end
  loc[#loc+1] = {hw, 0}
  local out = {}
  for _, p in ipairs(loc) do local dx, dy = p[1], -p[2]; out[#out+1] = {bx + dx * math.cos(a) - dy * math.sin(a), by + dx * math.sin(a) + dy * math.cos(a)} end
  return out
end
DOORS = {
  {bx = 560, by = 900, hw = 95, h = 390, a = 0},
  {bx = 196, by = 1010, hw = 74, h = 330, a = -0.42},
  {bx = 936, by = 470, hw = 68, h = 300, a = -math.pi / 2 - 0.18},
}
for _, d in ipairs(DOORS) do d.pts = rarch(d.bx, d.by, d.hw, d.h, d.a); d.m = poly(d.pts) end
BACK = poly({{380, 330}, {760, 330}, {760, 900}, {380, 900}})
FLOORM = poly({{380, 900}, {760, 900}, {1000, 1333}, {0, 1333}})
CEIL = poly({{380, 330}, {760, 330}, {1000, 0}, {0, 0}})
LWALL = poly({{0, 0}, {380, 330}, {380, 900}, {0, 1333}})
RWALL = poly({{1000, 0}, {760, 330}, {760, 900}, {1000, 1333}})
WD = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"ultramarine blue",0.2}}
WM = pile{{"bone brown",2},{"burnt sienna",0.6},{"raw sienna",0.6},{"bone black",0.3}}
FL = pile{{"bone brown",2},{"burnt sienna",0.4},{"bone black",0.8},{"ultramarine blue",0.3}}
CE = pile{{"bone brown",1.5},{"bone black",1},{"burnt sienna",0.4}}
PV = pile{{"cobalt violet",1},{"ultramarine ash",1},{"zinc white",1.2},{"cerulean blue",0.3}}
PVL = pile{{"zinc white",2},{"cobalt violet",0.6},{"cerulean blue",0.6}}
PVD = pile{{"ultramarine blue",1},{"cobalt violet",1},{"bone black",0.4},{"zinc white",0.3}}
local doors = DOORS[1].m + DOORS[2].m + DOORS[3].m
local function W(m, p, ang) m = m - doors; work(m, {hand="broad", pile=p, coverage=2.8, fill=true, clip=m, angle=ang}) end
W(CEIL, CE, 0)
W(LWALL, WD, math.pi / 2)
W(RWALL, WD, math.pi / 2)
W(BACK, WM, math.pi / 2)
W(FLOORM, FL, 0)
for _, d in ipairs(DOORS) do
  work(d.m, {hand="body", pile=PVD, coverage=3, fill=true, clip=d.m, angle=d.a + math.pi / 2})
end

--@ chunk 3
wait(3 * 24 * 60)
Q2 = pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.5},{"bone black",0.3}}
Q3 = pile{{"burnt sienna",1.5},{"raw sienna",1.5},{"bone brown",1}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",1},{"burnt sienna",0.3},{"lead white",0.3}}
HL = pile{{"lead white",3},{"yellow ochre",1},{"cadmium yellow",0.5}}
NDW = pile{{"bone black",1},{"bone brown",2},{"ultramarine blue",0.5},{"burnt sienna",0.5}}
BN = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
CZ = pile{{"zinc white",3},{"cerulean blue",1}}
-- portal air: lighter toward the middle of each doorway
for _, d in ipairs(DOORS) do
  local c = d.pts[math.floor(#d.pts / 2) + 1]
  local cx, cy = (c[1] + d.bx) / 2, (c[2] + d.by) / 2
  local mid = d.m * ellipse(cx, cy, d.hw * 0.8, d.h * 0.42):shrink(0)
  work(mid, {hand="body", pile=PV, coverage=3, fill=true, clip=d.m, angle=d.a + math.pi / 2})
  local core = d.m * ellipse(cx, cy, d.hw * 0.42, d.h * 0.26)
  work(core, {hand="body", pile=PVL, coverage=3, fill=true, clip=d.m, angle=d.a + math.pi / 2})
  blend(d.m:shrink(4), {angle=d.a + math.pi / 2})
end
-- corridor ribs: bronze bands running back toward the far wall
local b = brush{kind="filbert", width=8}
local h = brush{kind="round", width=1.6, point=0.7}
for _, t in ipairs{0.18, 0.42, 0.66} do
  local function L(x0, y0, x1, y1) return {lerp(x0, x1, t), lerp(y0, y1, t)} end
  local ring = {L(0, 1333, 380, 900), L(0, 0, 380, 330), L(1000, 0, 760, 330), L(1000, 1333, 760, 900)}
  local w = lerp(1, 0.45, t)
  local bb = brush{kind="filbert", width=12 * w}
  for k = 1, 3 do
    bb:reload(k == 1 and Q3 or Q2, 0.8); bb:stroke({ring[k], ring[k + 1]}, {pressure={0.7, 0.7}, ramps={0.05, 0.05}, clip=-(DOORS[1].m + DOORS[2].m + DOORS[3].m)})
  end
  h:reload(Q5, 0.6); h:stroke({{ring[1][1] + 4, ring[1][2]}, {ring[2][1] + 4, ring[2][2] + 4}}, {pressure={0.5, 0.5}, clip=-(DOORS[1].m + DOORS[2].m + DOORS[3].m)})
end

--@ chunk 4
VOID = pile{{"bone black",1.2},{"ultramarine blue",1},{"bone brown",0.4}}
function tube(T, B, w0, w1, P)
  local dx, dy = B[1] - T[1], B[2] - T[2]
  local len = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / len, -dx / len
  if nx > 0 then nx, ny = -nx, -ny end
  local function line(off, s0, s1) local t = {} for i = 0, 8 do local s = lerp(s0 or 0.02, s1 or 0.98, i / 8); local w = lerp(w0, w1, s); t[#t+1] = {T[1] + dx * s + nx * w * off, T[2] + dy * s + ny * w * off} end return t end
  local o = {}
  for _, p in ipairs(line(1, 0, 1)) do o[#o+1] = p end
  local bk = line(-1, 0, 1); for i = #bk, 1, -1 do o[#o+1] = bk[i] end
  local m = poly(o, true)
  work(m, {hand="detail", pile=P.base, coverage=3, fill=true, clip=m, angle=math.atan(dy, dx)})
  local b = brush{kind="filbert", width=math.max(1.2, (w0 + w1) * 0.35)}
  if P.lit then b:reload(P.lit, 0.8); b:stroke(line(0.45), {pressure={0.7, 0.5}, clip=m}) end
  if P.dark then b:reload(P.dark, 0.8); b:stroke(line(-0.45), {pressure={0.7, 0.7}, clip=m}) end
  local r = brush{kind="round", width=math.max(0.9, (w0 + w1) * 0.1), point=0.6}
  if P.hi then r:reload(P.hi, 0.7); r:stroke(line(0.65, 0.05, 0.7), {pressure={0.3, 0.8, 0.1}, clip=m}) end
  return m
end
-- the bell
BELL = poly({{404,596},{496,596},{522,630},{532,700},{540,800},{560,940},{596,1080},{640,1168},{646,1192},{254,1192},{262,1168},{306,1080},{340,940},{360,800},{368,700},{378,630}}, true)
  - poly({{566,1200},{590,1150},{606,1162},{626,1200}})
work(BELL, {hand="body", pile=Q3, coverage=3, fill=true, clip=BELL, angle=math.pi/2, tool="filbert 7"})
local lit = BELL * poly({{380,600},{430,600},{400,800},{350,1000},{300,1200},{250,1200},{300,1000},{350,800}})
work(lit, {hand="body", pile=Q4, coverage=3, fill=true, clip=lit, angle=math.pi/2, tool="filbert 7"})
local sh = BELL * poly({{500,600},{540,600},{580,900},{660,1200},{560,1200},{520,900},{490,700}})
work(sh, {hand="body", pile=Q2, coverage=3, fill=true, clip=sh, angle=math.pi/2, tool="filbert 7"})
-- the person-shaped absence through its front
ABS = ellipse(452, 812, 25, 29) + poly({{438,838},{466,838},{506,866},{520,960},{510,1080},{500,1150},{404,1150},{394,1080},{384,960},{398,866}}, true)
work(ABS, {hand="detail", pile=VOID, coverage=3, fill=true, clip=ABS})
-- neck of bone, the head thrown back, mouth wide
local neck = ribbon({{450, 600}, {456, 560}, {462, 520}}, {16, 14, 13})
work(neck, {hand="detail", pile=BN, coverage=3, fill=true, clip=neck})
HEAD = ellipse(464, 462, 40, 56)
work(HEAD, {hand="detail", pile=BN, coverage=3, fill=true, clip=HEAD})
MOUTH = ellipse(468, 488, 15, 34)
work(MOUTH, {hand="detail", pile=VOID, coverage=3, fill=true, clip=MOUTH})
for _, e in ipairs{{448, 436}, {484, 438}} do local m = ellipse(e[1], e[2], 7, 3.5); work(m, {hand="detail", pile=VOID, coverage=3, fill=true, clip=m}) end
-- arms flung up
local PA = {base=Q3, lit=Q5, dark=NDW, hi=HL}
tube({390, 632}, {322, 530}, 9, 7, PA); tube({322, 530}, {292, 410}, 7, 5.5, PA)
tube({512, 632}, {598, 566}, 9, 7, PA); tube({598, 566}, {662, 470}, 7, 5.5, PA)
local fb = brush{kind="round", width=2.8, point=0.5}
for _, f in ipairs{{292,410,270,368},{292,410,284,360},{293,410,298,362},{294,412,312,372},{290,414,268,398},{291,412,280,380}} do fb:reload(Q4, 0.7); fb:stroke({{f[1], f[2]}, {f[3], f[4]}}, {pressure={0.8, 0.1}, ramps={0.05, 0.6}}) end
for _, f in ipairs{{662,470,668,426},{663,470,680,430},{664,472,692,442},{662,474,698,462},{660,472,650,436}} do fb:reload(Q4, 0.7); fb:stroke({{f[1], f[2]}, {f[3], f[4]}}, {pressure={0.8, 0.1}, ramps={0.05, 0.6}}) end
-- a bone clapper hanging below the rim
local cl = ellipse(452, 1222, 20, 24)
work(cl, {hand="detail", pile=BN, coverage=3, fill=true, clip=cl})

--@ chunk 5
wait(3 * 24 * 60)
CC = pile{{"cerulean blue",1},{"cobalt violet",1},{"ultramarine ash",1},{"zinc white",1}}
BS = pile{{"lead white",2},{"raw sienna",1},{"bone brown",0.4},{"ultramarine ash",0.4}}
local function S(br, p, pts, pr, rp, clip) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}, clip=clip}) end
local function bw(y) -- the bell's half-width at height y
  local t = {{596, 46}, {630, 72}, {700, 82}, {800, 90}, {940, 110}, {1080, 145}, {1168, 190}, {1192, 196}}
  for i = 1, #t - 1 do if y <= t[i+1][1] then return lerp(t[i][2], t[i+1][2], (y - t[i][1]) / (t[i+1][1] - t[i][1])) end end
  return 196
end
local function band(y, sag, n) local t = {} for i = 0, n do local u = -1 + 2 * i / n; local w = bw(y) - 3; t[#t+1] = {450 + u * w, y + sag * (1 - u * u)} end return t end
local f6 = brush{kind="filbert", width=6}
local f10 = brush{kind="filbert", width=12}
local r2 = brush{kind="round", width=2.2, point=0.6}
local r1 = brush{kind="round", width=1.3, point=0.8}
-- broad sheen down the lit side, a darker core on the right
S(f10, Q5, {{410, 640}, {398, 760}, {380, 900}, {352, 1040}, {316, 1150}}, {0.2, 0.8, 0.6, 0.1}, {0.2, 0.3}, BELL)
S(f6, HL, {{404, 620}, {392, 700}, {380, 800}}, {0.1, 0.8, 0.0}, {0.2, 0.4}, BELL)
S(f10, NDW, {{516, 660}, {528, 800}, {548, 940}, {580, 1080}, {612, 1160}}, {0.3, 0.7, 0.6, 0.3}, {0.2, 0.3}, BELL)
-- rings cast round the bell: the shoulder, the waist, the sound-bow, the lip
for _, y in ipairs{640, 702, 1104, 1150} do
  S(r2, NDW, band(y, 6, 12), {0.7, 0.7}, {0.05, 0.05}, BELL)
  local lb = band(y + 4, 6, 12); local half = {} for i = 1, 6 do half[#half+1] = lb[i] end
  S(r1, Q5, half, {0.2, 0.7}, {0.1, 0.1}, BELL)
end
-- the lip: a heavy rim, lit along its top
local lip = BELL * rect(0, 1168, 1000, 26)
work(lip, {hand="detail", pile=Q4, coverage=3, fill=true, clip=lip, angle=0})
local lt = band(1170, 4, 14); local lh = {} for i = 1, 9 do lh[#lh+1] = lt[i] end
S(r1, HL, lh, {0.3, 0.8, 0.2}, {0.1, 0.2}, BELL)
-- cold rim light from the portals behind, down the right contour
local rc = {} for y = 610, 1180, 30 do rc[#rc+1] = {450 + bw(y) - 2, y} end
S(r1, CZ, rc, {0.2, 0.6, 0.3}, {0.2, 0.2})
-- the crack from the chipped rim, with cold light breaking through it
local crack = {{596, 1150}, {578, 1100}, {584, 1060}, {562, 1000}, {566, 960}, {546, 910}, {552, 870}, {536, 830}}
S(r2, VOID, crack, {0.8, 0.3}, {0.05, 0.5})
S(r1, CC, {{598, 1148}, {580, 1098}, {586, 1058}, {564, 998}}, {0.5, 0.0}, {0.05, 0.6})
S(r1, VOID, {{562, 1000}, {590, 990}, {604, 1010}}, {0.6, 0.1})
-- the absence edged in faint cold
local ar = ABS:rim(1.2)
work(ar, {hand="detail", pile=CC, coverage=2, fill=true, clip=ar})
-- golden-angle studs of bone over the shoulder
local GA = math.rad(137.50776)
local st = brush{kind="round", width=2.4, point=0.2}
for k = 3, 40 do local r = 9 * math.sqrt(k); local a = k * GA; local x, y = 450 + r * math.cos(a) * 1.3, 690 + r * math.sin(a) * 0.55
  if BELL:at(x, y) > 0.9 and ABS:at(x, y) < 0.1 then st:reload(BN, 0.6); st:touch(x, y, {pressure=0.6}) end end
-- head: shade, the mouth's gape, a crown of thirteen bronze spikes behind it
local crown = brush{kind="round", width=3.4, point=0.6}
for k = 0, 12 do local a = math.pi + 0.15 + k * (math.pi - 0.3) / 12 + 0.05 * math.sin(k * 2.3); local r0 = 58; local r1_ = 84 + 10 * math.sin(k * 1.7)
  S(crown, k % 3 == 0 and Q5 or Q3, {{464 + r0 * math.cos(a) * 0.75, 462 + r0 * math.sin(a)}, {464 + r1_ * math.cos(a) * 0.8, 462 + r1_ * math.sin(a)}}, {0.8, 0.0}, {0.05, 0.7}) end
local hs = HEAD * poly({{474, 400}, {520, 400}, {520, 530}, {470, 530}, {486, 470}})
work(hs, {hand="detail", pile=BS, coverage=2.5, fill=true, clip=hs})
S(r2, NDW, {{456, 456}, {452, 488}, {456, 518}, {468, 524}}, {0.5, 0.5}, {0.1, 0.1})
local inner = ellipse(469, 494, 9, 25)
work(inner, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.5}}, coverage=3, fill=true, clip=inner})
S(r1, HL, {{430, 420}, {440, 405}, {456, 400}}, {0.2, 0.7, 0.0})
for k = 0, 3 do S(r1, NDW, {{448, 590 - k * 18}, {462, 590 - k * 18}}, {0.5, 0.5}) end

--@ chunk 6
local M = {468, 494}
local doors = DOORS[1].m + DOORS[2].m + DOORS[3].m
local out = -(doors:grow(2) + BELL + HEAD:grow(3))
local GA = math.rad(137.50776)
local a1 = brush{kind="round", width=3.0, point=0.5}
local a2 = brush{kind="round", width=1.6, point=0.7}
local radii = {66, 104, 152, 214, 290, 380, 480, 590}
local function arcs(cx, cy, rot, clip, warm, cold, scale)
  for i, r in ipairs(radii) do
    local p = math.max(0.25, 0.85 - i * 0.07) * (scale or 1)
    local nseg = 3 + i
    for s = 0, nseg - 1 do
      local a0 = rot + s * 2 * math.pi / nseg + 0.3 * math.sin(i * 2.1 + s)
      local a1_ = a0 + (2 * math.pi / nseg) * (0.55 + 0.25 * math.sin(i + s * 1.3))
      local pts = {}
      for k = 0, 10 do local a = lerp(a0, a1_, k / 10); pts[#pts+1] = {cx + r * math.cos(a), cy + r * math.sin(a) * 0.92} end
      local br = (i + s) % 2 == 0 and a1 or a2
      br:reload((i % 2 == 0) and warm or cold, 0.8)
      br:stroke(pts, {pressure={0.0, p, p, 0.0}, ramps={0.2, 0.2}, clip=clip})
      -- a notch at the arc's middle, counted in golden gaps
      local am = (a0 + a1_) / 2
      for n = 0, (i % 3) do
        local an = am + n * 0.06
        a2:reload(warm, 0.7)
        a2:stroke({{cx + (r - 6) * math.cos(an), cy + (r - 6) * math.sin(an) * 0.92}, {cx + (r + 7) * math.cos(an), cy + (r + 7) * math.sin(an) * 0.92}}, {pressure={0.6, 0.6}, clip=clip})
      end
    end
  end
end
arcs(M[1], M[2], 0, out, HL, CZ)
-- through each doorway the same cry comes out turned
for j, d in ipairs(DOORS) do
  local turn = ({0.5, -0.9, 1.6})[j]
  local dx, dy = M[1] - d.bx, M[2] - d.by
  local cx = d.bx + dx * math.cos(turn) - dy * math.sin(turn)
  local cy = d.by + dx * math.sin(turn) + dy * math.cos(turn)
  arcs(cx, cy, turn, d.m:shrink(3), PVD, VOID, 1.1)
end

--@ chunk 7
local function W(d, u, v) local dx, dy = u, -v; return {d.bx + dx * math.cos(d.a) - dy * math.sin(d.a), d.by + dx * math.sin(d.a) + dy * math.cos(d.a)} end
local function WP(d, pts) local t = {} for i, p in ipairs(pts) do t[i] = W(d, p[1], p[2]) end return t end
local function S(br, p, pts, pr, rp, clip) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}, clip=clip}) end
local f = brush{kind="filbert", width=8}
local r3 = brush{kind="round", width=3.2, point=0.6}
local r1 = brush{kind="round", width=1.3, point=0.8}
local DK = pile{{"bone black",1.5},{"ultramarine blue",0.6},{"cobalt violet",0.3}}
-- surrounds: a bronze band round each doorway, lit on the side toward the cry
for _, d in ipairs(DOORS) do
  local o = rarch(d.bx, d.by, d.hw + 7, d.h + 7, d.a, 24)
  for i = 1, #o - 1, 5 do local s = {} for k = i, math.min(#o, i + 5) do s[#s+1] = o[k] end; S(f, Q3, s, {0.7, 0.7}, {0.05, 0.05}) end
  local o2 = rarch(d.bx, d.by, d.hw + 1, d.h + 1, d.a, 24)
  for i = 1, #o2 - 1, 5 do local s = {} for k = i, math.min(#o2, i + 5) do s[#s+1] = o2[k] end; S(r1, NDW, s, {0.6, 0.6}, {0.05, 0.05}) end
  local o3 = rarch(d.bx, d.by, d.hw + 11, d.h + 11, d.a, 24)
  local s = {} for k = 3, 14 do s[#s+1] = o3[k] end
  S(r1, Q5, s, {0.2, 0.7, 0.1})
end
-- centre door: a tall shape leaning out, two long hands round the left jamb, a pair of eye-points
local d = DOORS[1]
local body = poly(WP(d, {{-6, 300}, {22, 300}, {34, 250}, {30, 160}, {18, 60}, {4, 10}, {-10, 60}, {-18, 160}, {-20, 250}}), true) * d.m
work(body, {hand="detail", pile=DK, coverage=3, fill=true, clip=body})
for _, hnd in ipairs{{-60, 230}, {-66, 170}} do
  S(r3, DK, WP(d, {{-10, hnd[2] - 10}, {-40, hnd[2]}, {hnd[1], hnd[2] + 4}}), {0.9, 0.7}, {0.05, 0.1})
  for k = 0, 3 do S(r1, DK, WP(d, {{hnd[1], hnd[2] + 4 - k * 5}, {-93, hnd[2] + 2 - k * 6}, {-99, hnd[2] - 6 - k * 6}}), {0.8, 0.3}, {0.05, 0.4}) end
end
for _, e in ipairs{{4, 270}, {16, 268}} do local p = W(d, e[1], e[2]); S(r1, CZ, {p, {p[1] + 0.8, p[2]}}, {0.8, 0.8}) end
-- left door: thin limbs reaching out of the light, fingers splayed
d = DOORS[2]
for j, l in ipairs{{-20, 120, -60, 230}, {10, 90, 40, 250}, {-5, 160, -30, 290}, {20, 140, 55, 180}} do
  S(r3, DK, WP(d, {{l[1] * 0.3, 40 + j * 10}, {l[1], l[2]}, {l[3], l[4]}}), {0.9, 0.5}, {0.05, 0.3}, d.m)
  for k = -2, 2 do S(r1, DK, WP(d, {{l[3], l[4]}, {l[3] + k * 7, l[4] + 18 - math.abs(k) * 3}}), {0.7, 0.0}, {0.05, 0.6}, d.m) end
end
for _, e in ipairs{{-10, 200}, {0, 202}, {28, 120}, {36, 121}, {-40, 90}} do local p = W(d, e[1], e[2]); S(r1, HL, {p, {p[1] + 0.8, p[2]}}, {0.8, 0.8}) end
-- right door: another bell coming, small and dark, its bone face a point
d = DOORS[3]
local bell = poly(WP(d, {{-14, 230}, {14, 230}, {22, 200}, {30, 140}, {44, 90}, {-44, 90}, {-30, 140}, {-22, 200}}), true) * d.m
work(bell, {hand="detail", pile=DK, coverage=3, fill=true, clip=bell})
local face = ellipse(W(d, 0, 250)[1], W(d, 0, 250)[2], 10, 10) * d.m
work(face, {hand="detail", pile=BN, coverage=3, fill=true, clip=face})
local mo = W(d, 0, 246); S(r1, DK, {mo, {mo[1] + 1, mo[2] + 1}}, {0.9, 0.9})
-- the air of each doorway shivering: wavering lines across the light
for _, dd in ipairs(DOORS) do
  for k = 1, 5 do
    local v = dd.h * k / 6.5
    local pts = {} for i = 0, 10 do local u = -dd.hw + 2 * dd.hw * i / 10; pts[#pts+1] = W(dd, u, v + 4 * math.sin(i * 1.7 + k)) end
    S(r1, PV, pts, {0.4, 0.4}, {0.1, 0.1}, dd.m:shrink(4))
  end
end

--@ chunk 8
wait(2 * 24 * 60)
local body = BELL - ABS:grow(1.5)
-- re-lay the bell in three vertical zones: lit, middle, shadow, then join the seams
local litz = body * poly({{380,590},{436,590},{424,700},{400,850},{370,1000},{330,1200},{240,1200},{300,1000},{340,800},{360,650}})
local shz = body * poly({{486,590},{540,590},{580,900},{660,1200},{540,1200},{520,1000},{500,800},{490,680}})
local mid = body - litz - shz
work(mid, {hand="body", pile=Q3, coverage=3, fill=true, clip=mid, angle=math.pi/2, tool="filbert 6"})
work(litz, {hand="body", pile=Q5, coverage=3, fill=true, clip=litz, angle=math.pi/2, tool="filbert 6"})
work(shz, {hand="body", pile=Q2, coverage=3, fill=true, clip=shz, angle=math.pi/2, tool="filbert 6"})
local seams = (litz:grow(5) - litz:shrink(5) + shz:grow(5) - shz:shrink(5)) * body
blend(seams, {angle=math.pi/2})
-- a highlight down the lit flank
local h = brush{kind="filbert", width=4}
h:reload(HL, 0.8); h:stroke({{404, 610}, {396, 700}, {384, 800}, {366, 920}}, {pressure={0.2, 0.8, 0.5, 0.0}, ramps={0.2, 0.4}, clip=body})
-- cast shadow on the floor under the bell, and the cold spill of the doorways on the floor
local cs = ellipse(450, 1205, 230, 26) - BELL
work(cs, {hand="body", pile=VOID, coverage=2.5, fill=true, clip=cs, angle=0, edge="soft"})
local spill = poly({{470, 905}, {650, 905}, {700, 1000}, {520, 1000}}) - BELL
work(spill, {hand="body", pile=PV, coverage=1.4, clip=spill, angle=0, edge="soft", load=0.5})

--@ chunk 9
wait(3 * 24 * 60)
local function S(br, p, pts, pr, rp, clip) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}, clip=clip}) end
local body = BELL - ABS:grow(1.5)
local function zone(pts, p) local z = body * poly(pts, true); work(z, {hand="body", pile=p, coverage=3, fill=true, clip=z, angle=math.pi/2, tool="filbert 5"}) end
-- shadow flank and its core, the lit flank and its sheen: facets of a turning bell
zone({{500,596},{524,630},{536,700},{546,800},{566,940},{604,1080},{648,1170},{648,1196},{560,1196},{540,1080},{522,940},{510,800},{502,700},{494,620}}, Q2)
zone({{520,640},{530,700},{540,800},{556,940},{590,1080},{626,1170},{600,1196},{576,1100},{552,960},{530,820},{518,700}}, NDW)
zone({{396,604},{422,604},{410,700},{396,820},{372,960},{338,1100},{300,1190},{262,1190},{300,1090},{334,960},{358,820},{372,700},{382,630}}, Q4)
zone({{404,612},{414,612},{402,720},{386,850},{360,980},{330,1100},{314,1150},{322,1100},{350,980},{376,850},{392,720}}, HL)
-- the absence restated, edged cold
work(ABS, {hand="detail", pile=VOID, coverage=3, fill=true, clip=ABS})
local ar = ABS:rim(1.4)
work(ar, {hand="detail", pile=CC, coverage=2.5, fill=true, clip=ar})
-- floor: the blotched spill laid back, a few cold glints running out of the centre door instead
local spill = poly({{460, 900}, {660, 900}, {710, 1006}, {510, 1006}}) - BELL
work(spill, {hand="body", pile=FL, coverage=3, fill=true, clip=spill, angle=0})
local r1 = brush{kind="round", width=1.6, point=0.7}
for k = -2, 2 do S(r1, PV, {{560 + k * 30, 904}, {560 + k * 46, 960}, {560 + k * 70, 1040}}, {0.6, 0.0}, {0.05, 0.7}) end

--@ chunk 10
wait(3 * 24 * 60)
local function S(br, p, pts, pr, rp, clip) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}, clip=clip}) end
local function bw(y) -- the bell's half-width at height y
  local t = {{596, 46}, {630, 72}, {700, 82}, {800, 90}, {940, 110}, {1080, 145}, {1168, 190}, {1192, 196}}
  for i = 1, #t - 1 do if y <= t[i+1][1] then return lerp(t[i][2], t[i+1][2], (y - t[i][1]) / (t[i+1][1] - t[i][1])) end end
  return 196
end
local function band(y, sag, n) local t = {} for i = 0, n do local u = -1 + 2 * i / n; local w = bw(y) - 3; t[#t+1] = {450 + u * w, y + sag * (1 - u * u)} end return t end
local f6 = brush{kind="filbert", width=6}
local f10 = brush{kind="filbert", width=12}
local r2 = brush{kind="round", width=2.2, point=0.6}
local r1 = brush{kind="round", width=1.3, point=0.8}
-- broad sheen down the lit side, a darker core on the right
S(f10, Q5, {{410, 640}, {398, 760}, {380, 900}, {352, 1040}, {316, 1150}}, {0.2, 0.8, 0.6, 0.1}, {0.2, 0.3}, BELL)
S(f6, HL, {{404, 620}, {392, 700}, {380, 800}}, {0.1, 0.8, 0.0}, {0.2, 0.4}, BELL)
S(f10, NDW, {{516, 660}, {528, 800}, {548, 940}, {580, 1080}, {612, 1160}}, {0.3, 0.7, 0.6, 0.3}, {0.2, 0.3}, BELL)
-- rings cast round the bell: the shoulder, the waist, the sound-bow, the lip
for _, y in ipairs{640, 702, 1104, 1150} do
  S(r2, NDW, band(y, 6, 12), {0.7, 0.7}, {0.05, 0.05}, BELL)
  local lb = band(y + 4, 6, 12); local half = {} for i = 1, 6 do half[#half+1] = lb[i] end
  S(r1, Q5, half, {0.2, 0.7}, {0.1, 0.1}, BELL)
end
-- the lip: a heavy rim, lit along its top
local lip = BELL * rect(0, 1168, 1000, 26)
work(lip, {hand="detail", pile=Q4, coverage=3, fill=true, clip=lip, angle=0})
local lt = band(1170, 4, 14); local lh = {} for i = 1, 9 do lh[#lh+1] = lt[i] end
S(r1, HL, lh, {0.3, 0.8, 0.2}, {0.1, 0.2}, BELL)
-- cold rim light from the portals behind, down the right contour
local rc = {} for y = 610, 1180, 30 do rc[#rc+1] = {450 + bw(y) - 2, y} end
S(r1, CZ, rc, {0.2, 0.6, 0.3}, {0.2, 0.2})
-- the crack from the chipped rim, with cold light breaking through it
local crack = {{596, 1150}, {578, 1100}, {584, 1060}, {562, 1000}, {566, 960}, {546, 910}, {552, 870}, {536, 830}}
S(r2, VOID, crack, {0.8, 0.3}, {0.05, 0.5})
S(r1, CC, {{598, 1148}, {580, 1098}, {586, 1058}, {564, 998}}, {0.5, 0.0}, {0.05, 0.6})
S(r1, VOID, {{562, 1000}, {590, 990}, {604, 1010}}, {0.6, 0.1})
local GA = math.rad(137.50776)
local st = brush{kind="round", width=2.4, point=0.2}
for k = 3, 40 do local r = 9 * math.sqrt(k); local a = k * GA; local x, y = 450 + r * math.cos(a) * 1.3, 690 + r * math.sin(a) * 0.55
  if BELL:at(x, y) > 0.9 and ABS:at(x, y) < 0.1 then st:reload(BN, 0.6); st:touch(x, y, {pressure=0.6}) end end
-- the long hands of the thing in the centre door, round its left jamb
local d = DOORS[1]
local function W(u, v) return {d.bx + u, d.by - v} end
local DK = pile{{"bone black",1.5},{"ultramarine blue",0.6},{"cobalt violet",0.3}}
local clip = d.m - BELL:grow(2)
for _, hv in ipairs{236, 176, 120} do
  local r3 = brush{kind="round", width=3.0, point=0.6}
  r3:reload(DK, 0.85); r3:stroke({W(-14, hv - 12), W(-50, hv - 2), W(-80, hv + 2)}, {pressure={0.9, 0.6}, ramps={0.05, 0.1}, clip=clip})
  for k = 0, 3 do r1:reload(DK, 0.85); r1:stroke({W(-80, hv + 2 - k * 4), W(-92, hv - k * 5), W(-94, hv - 8 - k * 5)}, {pressure={0.8, 0.2}, ramps={0.05, 0.5}, clip=clip}) end
end

--@ chunk 11
local function S(br, p, pts, pr, rp, clip) br:reload(p, 0.85); br:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps=rp or {0.2, 0.3}, clip=clip}) end
local f = brush{kind="filbert", width=6}
local r2 = brush{kind="round", width=2.2, point=0.6}
local r1 = brush{kind="round", width=1.3, point=0.8}
-- the mask turned: shadowed right cheek, a hollow under the brow, cracks running from the mouth
S(f, BS, {{490, 420}, {500, 455}, {498, 495}, {486, 518}}, {0.3, 0.8, 0.3}, {0.2, 0.3}, HEAD)
S(r2, NDW, {{438, 446}, {446, 432}, {462, 428}}, {0.2, 0.6, 0.1}, {0.2, 0.3}, HEAD)
S(r2, NDW, {{474, 430}, {488, 432}, {496, 444}}, {0.2, 0.6, 0.1}, {0.2, 0.3}, HEAD)
S(r1, NDW, {{456, 470}, {440, 456}, {432, 462}}, {0.6, 0.1}, {0.05, 0.6}, HEAD)
S(r1, NDW, {{482, 506}, {494, 520}, {500, 516}}, {0.6, 0.1}, {0.05, 0.6}, HEAD)
S(r1, HL, {{432, 430}, {440, 412}, {458, 404}}, {0.2, 0.8, 0.0})
-- the mouth's rim lit cold from within, the first rings of the cry thick and bright
local e = {} for i = 0, 16 do local a = 2 * math.pi * i / 16; e[#e+1] = {468 + 16 * math.cos(a), 494 + 35 * math.sin(a)} end
S(r1, CZ, e, {0.6, 0.6})
local thick = brush{kind="round", width=4.0, point=0.4}
for i, r in ipairs{48, 62} do
  for s = 0, 2 do local a0 = -0.2 + s * 2.1; local pts = {} for k = 0, 10 do local a = a0 + 1.3 * k / 10; pts[#pts+1] = {468 + r * math.cos(a), 494 + r * math.sin(a) * 0.92} end
    S(thick, i == 1 and HL or CZ, pts, {0.0, 0.8, 0.8, 0.0}, {0.2, 0.2}, -(HEAD:grow(3) + BELL)) end
end
