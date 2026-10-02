-- easel session "triptych": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={16,18}, seed=1616, ground={{pile={{"lead white",2},{"yellow ochre",0.3}}, um=160, apply="knife", texture=0.2}}}
INNER = rect(52, 52, 896, 1229)
BORDER = -INNER
HEAVEN = ellipse(500, 40, 290, 200) * INNER
MC = {500, 640}
MAND = ellipse(MC[1], MC[2], 300, 390)
SUNC = {500, 150}
SUND = ellipse(SUNC[1], SUNC[2], 88, 88)
local RED  = pile{{"red earth",1.5},{"Mars red",0.6},{"bone black",0.3}}
local GOLD = pile{{"yellow ochre",1.5},{"Mars yellow",0.8},{"cadmium yellow",0.3},{"lead white",0.5}}
local BLUE = pile{{"ultramarine blue",1.5},{"cobalt blue",0.5},{"bone black",0.3},{"lead white",0.2}}
work(BORDER, {hand="body", tool="filbert 8", pile=RED, coverage=3.2, fill=true, angle=0, clip=BORDER, seed=101})
local field = INNER - HEAVEN - MAND
work(field, {hand="body", tool="filbert 10", pile=GOLD, coverage=3, fill=true, angle=0.05, clip=field, seed=102})
local hv = HEAVEN - MAND
work(hv, {hand="body", tool="filbert 6", pile=BLUE, coverage=3.5, fill=true, angle=0, clip=hv, seed=103})
print(wait(2 * 24 * 60))

--@ chunk 2
-- the solar sail as a mandorla: concentric bands, darkest outside (as in the icons), palest gold-white at its heart;
-- the Sun as a gold disc in heaven
local B1 = pile{{"ultramarine blue",1.5},{"bone black",0.5},{"cobalt blue",0.4}}
local B2 = pile{{"cobalt blue",1},{"ultramarine blue",0.6},{"lead white",0.5}}
local B3 = pile{{"cerulean blue",0.6},{"lead white",1.6},{"cobalt blue",0.3}}
local B4 = pile{{"lead white",2},{"Mars yellow",0.4},{"cadmium yellow",0.2}}
local bands = {{B1, 300, 390}, {B2, 250, 330}, {B3, 200, 268}, {B4, 150, 205}}
local prev = nil
for i, b in ipairs(bands) do
  local m = ellipse(MC[1], MC[2], b[2], b[3])
  local inner = (i < #bands) and ellipse(MC[1], MC[2], bands[i + 1][2], bands[i + 1][3]) or nil
  local ring = inner and (m - inner) or m
  work(ring, {hand="body", tool="filbert 6", pile=b[1], coverage=3.2, fill=true, angle=function(x, y) return math.atan(y - MC[2], x - MC[1]) + 1.57 end, clip=ring, seed=200 + i})
end
local SG = pile{{"Mars yellow",1},{"cadmium yellow",0.7},{"yellow ochre",0.5},{"lead white",0.5}}
work(SUND, {hand="body", tool="filbert 5", pile=SG, coverage=3.5, fill=true, angle=function(x, y) return math.atan(y - SUNC[2], x - SUNC[1]) + 1.57 end, clip=SUND, seed=210})
print(wait(2 * 24 * 60))

--@ chunk 3
-- the TESTAMENT as a monstrance: the bronze ring round a gold hub, the spine as stem and finial, a stepped foot;
-- the docents kneeling; the sea of fire
local function W(m, p, a, s) work(m, {hand="detail", tool={kind="filbert", width=4}, pile=p, coverage=4.5, fill=true, angle=a or 1.57, clip=m, seed=s}) end
local BRZ  = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.35}}
local BRZD = pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.5}}
local HUBG = pile{{"cadmium yellow",1},{"Mars yellow",0.6},{"lead white",0.6}}
local WHITE = pile{{"lead white",3},{"yellow ochre",0.15}}
local FIRE = pile{{"vermilion",1},{"Mars orange",0.8},{"cadmium red",0.3}}
local FIRED = pile{{"Mars red",1},{"red earth",0.6},{"bone black",0.2}}
RC = {500, 600}
RINGM = ellipse(RC[1], RC[2], 190, 190) - ellipse(RC[1], RC[2], 130, 130)
SPINE = rect(478, 330, 44, 280) + rect(478, 790, 44, 200)
FINIAL = poly({{470,330},{530,330},{500,262}})
FOOT = poly({{400,990},{600,990},{640,1050},{360,1050}}) + rect(330, 1050, 340, 22)
HUB = ellipse(RC[1], RC[2], 44, 44)
STRUTS = ribbon({{500, 556}, {500, 470}}, 12) + ribbon({{500, 644}, {500, 730}}, 12) + ribbon({{456, 600}, {370, 600}}, 12) + ribbon({{544, 600}, {630, 600}}, 12)
W(SPINE + FINIAL, BRZ, 1.57, 301)
W(FOOT, BRZD, 0, 302)
W(RINGM, BRZ, 0, 303)
W(STRUTS, BRZD, 0, 304)
W(HUB, HUBG, 0, 305)
-- docents: small white kneeling figures, each with a tiny halo
DOC = {}
for i = 0, 7 do
  local x = 300 + i * 57
  if math.abs(x - 500) > 40 then
    local body = poly({{x - 10, 1086}, {x + 10, 1086}, {x + 16, 1120}, {x - 16, 1120}}, true)
    local head = ellipse(x, 1078, 7, 7)
    W(body, WHITE, 1.57, 310 + i)
    W(head, WHITE, 0, 320 + i)
    DOC[#DOC + 1] = x
  end
end
SEA = rect(52, 1140, 896, 141)
W(SEA, FIRED, 0, 330)
for k = 0, 22 do
  local x = 62 + k * 40 + rand(-6, 6)
  local fl = poly({{x - 18, 1176}, {x + 18, 1176}, {x + 5, 1152}, {x + 1, 1132}, {x - 6, 1150}}, true) * INNER
  W(fl, FIRE, -1.57, 340 + k)
end
print(wait(4 * 24 * 60))

--@ chunk 4
-- the hub restated on dry paint, then all the lines: segments and arcs only
local HUBG = pile{{"cadmium yellow",1},{"Mars yellow",0.5},{"lead white",0.8}}
work(HUB, {hand="detail", tool={kind="filbert", width=4}, pile=HUBG, coverage=6, fill=true, angle=0, clip=HUB, seed=401})
print(wait(4 * 24 * 60))
local rig = brush{kind="rigger", width=2.0, point=0.85}
local fine = brush{kind="rigger", width=1.3, point=0.95}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.55, 0.5}, ramps={0.08, 0.15}, clip=clip}) end
local function seg(b, p, a, c, pr, clip) S(b, p, 0.8, {a, c}, pr, clip) end
local function arc(cx, cy, rx, ry, a0, a1, n) local t = {} for k = 0, n do local a = lerp(a0, a1, k / n); t[#t + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end return t end
local OUT  = pile{{"bone brown",1},{"bone black",0.6},{"red earth",0.3}}
local GOLDL = pile{{"lead white",1.5},{"Mars yellow",1},{"cadmium yellow",0.5}}
local GOLDD = pile{{"Mars yellow",1},{"raw sienna",0.6},{"yellow ochre",0.5}}
local REDL = pile{{"red earth",1.2},{"Mars red",0.6},{"bone black",0.2}}
local WARM = pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.6}}
-- the Sun's calm face, its rays
local sx, sy = SUNC[1], SUNC[2]
S(rig, OUT, 0.8, arc(sx - 28, sy - 8, 16, 8, 0.15 * math.pi, 0.85 * math.pi, 8), {0.5, 0.5})
S(rig, OUT, 0.8, arc(sx + 28, sy - 8, 16, 8, 0.15 * math.pi, 0.85 * math.pi, 8), {0.5, 0.5})
seg(rig, OUT, {sx, sy - 4}, {sx - 4, sy + 22}, {0.45, 0.45}); seg(rig, OUT, {sx - 4, sy + 22}, {sx + 6, sy + 24}, {0.45, 0.45})
S(rig, OUT, 0.8, arc(sx, sy + 30, 20, 9, 0.2 * math.pi, 0.8 * math.pi, 8), {0.5, 0.5})
S(rig, OUT, 0.7, arc(sx, sy, 88, 88, 0, 2 * math.pi, 60), {0.5, 0.5})
for k = 0, 23 do
  local a = 2 * math.pi * k / 24
  local r1 = (k % 2 == 0) and 128 or 110
  seg(rig, GOLDL, {sx + 94 * math.cos(a), sy + 94 * math.sin(a)}, {sx + r1 * math.cos(a), sy + r1 * math.sin(a)}, {0.6, 0.15}, HEAVEN - MAND)
end
-- the mandorla: band rims and gold rays through the blue
for _, b in ipairs({{300, 390}, {250, 330}, {200, 268}, {150, 205}}) do S(fine, GOLDL, 0.7, arc(MC[1], MC[2], b[1], b[2], 0, 2 * math.pi, 90), {0.4, 0.4}) end
local keep = MAND - (RINGM:grow(3) + SPINE:grow(3) + FINIAL:grow(3) + FOOT:grow(3) + HUB:grow(3) + STRUTS:grow(3))
for k = 0, 71 do
  local a = 2 * math.pi * k / 72
  local r0 = (k % 2 == 0) and 0.55 or 0.68
  seg(fine, GOLDL, {MC[1] + 300 * r0 * math.cos(a), MC[2] + 390 * r0 * math.sin(a)}, {MC[1] + 298 * math.cos(a), MC[2] + 388 * math.sin(a)}, {0.35, 0.1}, keep)
end
-- the ring: rims, plate seams, warm windows
S(rig, GOLDL, 0.8, arc(RC[1], RC[2], 190, 190, 0, 2 * math.pi, 90), {0.5, 0.5})
S(rig, OUT, 0.8, arc(RC[1], RC[2], 130, 130, 0, 2 * math.pi, 70), {0.5, 0.5})
S(fine, GOLDD, 0.7, arc(RC[1], RC[2], 183, 183, 0, 2 * math.pi, 90), {0.35, 0.35})
for k = 0, 35 do
  local a = 2 * math.pi * (k + 0.5) / 36 + 0.04 * math.sin(k * 2.7)
  seg(fine, OUT, {RC[1] + 133 * math.cos(a), RC[2] + 133 * math.sin(a)}, {RC[1] + 146 * math.cos(a), RC[2] + 146 * math.sin(a)}, {0.45, 0.45})
  seg(fine, OUT, {RC[1] + 174 * math.cos(a), RC[2] + 174 * math.sin(a)}, {RC[1] + 187 * math.cos(a), RC[2] + 187 * math.sin(a)}, {0.45, 0.45})
end
local tip = brush{kind="round", width=3, point=0.5}
for k = 0, 59 do
  if (k * 7) % 5 ~= 0 then
    local a = 2 * math.pi * k / 60
    tip:reload(WARM, 0.8); tip:touch(RC[1] + 140 * math.cos(a), RC[2] + 140 * math.sin(a), {pressure=0.6})
  end
end
-- fold notation in gold around the ring: room-glyphs with rotated golden insets, edge ticks, bridges between,
-- and one bridge that leaves a glyph and returns to it
local function poly_pts(cx, cy, r, n, rot) local t = {} for i = 0, n do local a = rot + 2 * math.pi * i / n; t[#t + 1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return t end
local function glyph(cx, cy, n, r, rot, turn)
  local p = poly_pts(cx, cy, r, n, rot)
  for i = 1, n do seg(fine, GOLDL, p[i], p[i + 1], {0.5, 0.5}) end
  local q = poly_pts(cx, cy, r * 0.618, n, rot + turn)
  for i = 1, n do seg(fine, GOLDL, q[i], q[i + 1], {0.4, 0.4}) end
  local mx, my = (p[1][1] + p[2][1]) / 2, (p[1][2] + p[2][2]) / 2
  local ox, oy = mx - cx, my - cy
  local l = math.sqrt(ox * ox + oy * oy)
  seg(fine, GOLDL, {mx, my}, {mx + ox / l * 5, my + oy / l * 5}, {0.5, 0.5})
end
local G = {}
for k = 0, 7 do
  local a = 2 * math.pi * k / 8 + math.pi / 8
  local cx, cy = RC[1] + 160 * math.cos(a), RC[2] + 160 * math.sin(a)
  G[#G + 1] = {cx, cy, a}
  glyph(cx, cy, ({5, 4, 6, 3, 5, 6, 4, 5})[k + 1], 11, a, ({0.6, 0.0, 1.05, 0.3, 2.2, 0.5, 1.57, 0.9})[k + 1])
end
for k = 1, 8 do
  local a0 = G[k][3] + 0.13
  local a1 = G[k % 8 + 1][3] - 0.13
  if k % 2 == 1 then S(fine, GOLDD, 0.7, arc(RC[1], RC[2], 160, 160, a0, a1, 8), {0.35, 0.35}) end
end
local g = G[3]
S(fine, GOLDL, 0.7, arc(g[1] + 14 * math.cos(g[3]), g[2] + 14 * math.sin(g[3]), 9, 9, g[3] - 2.4, g[3] + 2.4, 12), {0.4, 0.4})
-- the spine and foot: seams and gold edges; a gold star at the finial
for y = 350, 590, 30 do seg(fine, OUT, {478, y}, {522, y}, {0.45, 0.45}) end
for y = 810, 980, 30 do seg(fine, OUT, {478, y}, {522, y}, {0.45, 0.45}) end
seg(rig, GOLDL, {480, 332}, {480, 410}, {0.45, 0.3}); seg(rig, GOLDL, {480, 790}, {480, 988}, {0.45, 0.3})
seg(rig, GOLDL, {470, 330}, {500, 262}, {0.5, 0.4})
seg(rig, GOLDL, {400, 990}, {600, 990}, {0.55, 0.55}); seg(rig, GOLDL, {360, 1050}, {640, 1050}, {0.55, 0.55})
seg(rig, OUT, {400, 990}, {360, 1050}); seg(rig, OUT, {600, 990}, {640, 1050})
seg(rig, GOLDL, {330, 1072}, {670, 1072}, {0.5, 0.5})
for _, d in ipairs({{500, 248}, {500, 236}}) do tip:reload(GOLDL, 0.9); tip:touch(d[1], d[2], {pressure=0.9}) end
S(rig, OUT, 0.8, arc(RC[1], RC[2], 44, 44, 0, 2 * math.pi, 30), {0.5, 0.5})
S(fine, OUT, 0.7, arc(RC[1], RC[2], 26, 26, 0, 2 * math.pi, 24), {0.4, 0.4})
-- docents: tiny halos, hands raised, outlines
for _, x in ipairs(DOC) do
  S(fine, GOLDL, 0.8, arc(x, 1078, 11, 11, math.pi * 0.95, math.pi * 2.05, 12), {0.5, 0.5})
  local dir = (x < 500) and 1 or -1
  seg(fine, OUT, {x + dir * 4, 1094}, {x + dir * 14, 1086}, {0.5, 0.4})
  seg(fine, OUT, {x - 16, 1120}, {x + 16, 1120}, {0.4, 0.4})
end
-- fire: short tongues; glyphs; frame
local FO = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.3}}
local FY = pile{{"cadmium yellow",1},{"lead white",0.6}}
for k = 0, 44 do
  local x = 58 + k * 20
  for _, row in ipairs({1205, 1245}) do seg(rig, (k + row) % 2 == 0 and FO or FY, {x, row}, {x + 5, row - rand(18, 28)}, {0.65, 0.0}) end
end
local function glyphs(x0, y0, n, sd)
  for i = 0, n - 1 do
    local x = x0 + i * 26
    seg(rig, REDL, {x, y0}, {x, y0 + 34}, {0.65, 0.65})
    local kd = (i + sd) % 3
    if kd == 0 then seg(rig, REDL, {x, y0 + 17}, {x + 14, y0 + 17}, {0.6, 0.6}); seg(rig, REDL, {x + 14, y0 + 17}, {x + 14, y0 + 34}, {0.6, 0.6})
    elseif kd == 1 then seg(rig, REDL, {x, y0}, {x + 15, y0 + 10}, {0.6, 0.6}); seg(rig, REDL, {x + 15, y0 + 10}, {x, y0 + 20}, {0.6, 0.6})
    else seg(rig, REDL, {x + 15, y0}, {x + 15, y0 + 34}, {0.6, 0.6}); seg(rig, REDL, {x, y0}, {x + 15, y0 + 34}, {0.6, 0.6}) end
  end
  seg(rig, REDL, {x0 - 4, y0 - 12}, {x0 + n * 26 - 10, y0 - 12}, {0.45, 0.45})
end
glyphs(80, 330, 3, 0); glyphs(90, 390, 3, 2)
glyphs(840, 330, 3, 1); glyphs(830, 390, 3, 0)
for _, s in ipairs({{{62,62},{938,62}}, {{938,62},{938,1271}}, {{938,1271},{62,1271}}, {{62,1271},{62,62}}}) do seg(rig, OUT, s[1], s[2], {0.5, 0.5}) end

--@ chunk 5
-- the mandorla's rim lines ran across the bronze ring: cover them there with the ring's own bronze
local BRZ = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.35}}
local rig = brush{kind="round", width=5, point=0.3}
local clip = RINGM:shrink(1)
for _, b in ipairs({{300, 390}, {250, 330}, {200, 268}, {150, 205}}) do
  for k = 0, 89 do
    local a0, a1 = 2 * math.pi * k / 90, 2 * math.pi * (k + 1) / 90
    local p = {MC[1] + b[1] * math.cos(a0), MC[2] + b[2] * math.sin(a0)}
    local q = {MC[1] + b[1] * math.cos(a1), MC[2] + b[2] * math.sin(a1)}
    if RINGM:at(p[1], p[2]) > 0.5 or RINGM:at(q[1], q[2]) > 0.5 then
      rig:reload(BRZ, 0.9); rig:stroke({p, q}, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=clip})
    end
  end
end
