-- easel session "icon_ratio": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={16,18}, seed=1515, ground={{pile={{"lead white",2},{"yellow ochre",0.3}}, um=160, apply="knife", texture=0.2}}}
HALO = {500, 370, 185}
INNER = rect(52, 52, 896, 1229)
BORDER = -INNER
HEAVEN = ellipse(500, 30, 230, 120) * INNER
HALOM = ellipse(HALO[1], HALO[2], HALO[3], HALO[3])
local RED  = pile{{"red earth",1.5},{"Mars red",0.6},{"bone black",0.3}}
local GOLD = pile{{"yellow ochre",1.5},{"Mars yellow",0.8},{"cadmium yellow",0.3},{"lead white",0.5}}
local GOLDH = pile{{"Mars yellow",1},{"cadmium yellow",0.6},{"yellow ochre",0.6},{"lead white",0.4},{"Mars orange",0.15}}
local BLUE = pile{{"ultramarine blue",1.5},{"cobalt blue",0.5},{"bone black",0.3},{"lead white",0.2}}
work(BORDER, {hand="body", tool="filbert 8", pile=RED, coverage=3.2, fill=true, angle=0, clip=BORDER, seed=201})
local field = INNER - HEAVEN
work(field, {hand="body", tool="filbert 10", pile=GOLD, coverage=3, fill=true, angle=0.05, clip=field, seed=202})
work(HEAVEN, {hand="body", tool="filbert 6", pile=BLUE, coverage=3.5, fill=true, angle=0, clip=HEAVEN, seed=203})
work(HALOM, {hand="body", tool="filbert 6", pile=GOLDH, coverage=3, fill=true, angle=function(x, y) return math.atan(y - HALO[2], x - HALO[1]) + 1.57 end, clip=HALOM, seed=204})
print(wait(3 * 24 * 60))

--@ chunk 2
-- flat shapes: hair behind, robe, face, bangs and locks, eyes, hands and the CRT, the sea of fire and the ark, the pixel sun
local function W(m, p, a, s) work(m, {hand="detail", tool={kind="filbert", width=4}, pile=p, coverage=4.5, fill=true, angle=a or 1.57, clip=m, seed=s}) end
local BLACK = pile{{"bone black",2},{"ultramarine blue",0.25}}
local ROBE  = pile{{"ultramarine blue",1.5},{"bone black",0.6},{"cobalt blue",0.4}}
local SKIN  = pile{{"lead white",3},{"yellow ochre",0.25},{"vermilion",0.08}}
local CASE  = pile{{"lead white",2},{"yellow ochre",0.5},{"bone black",0.15}}
local SCREEN = pile{{"viridian",0.6},{"bone black",1.2},{"emerald green",0.3}}
local FIRE = pile{{"vermilion",1},{"Mars orange",0.8},{"cadmium red",0.3}}
local FIRED = pile{{"Mars red",1},{"red earth",0.6},{"bone black",0.2}}
local ARK = pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.5}}
local SUNP = pile{{"cadmium yellow",1},{"lemon chrome",0.4},{"lead white",0.4}}
HAIRB = ellipse(500, 350, 128, 128) + poly({{378,360},{430,420},{440,820},{372,800},{360,560}}) + poly({{622,360},{570,420},{560,820},{628,800},{640,560}})
W(HAIRB, BLACK, 1.57, 301)
ROBEM = poly({{452,470},{548,470},{600,640},{640,1050},{360,1050},{400,640}})
W(ROBEM, ROBE, 1.57, 302)
FACE = ellipse(500, 385, 92, 100)
W(FACE, SKIN, 0, 303)
BANGS = poly({{404,350},{420,282},{470,250},{530,250},{580,282},{596,350},{570,330},{548,352},{524,326},{500,352},{476,326},{452,352},{430,330}})
W(BANGS, BLACK, 1.57, 304)
EYES = ellipse(462, 400, 20, 27) + ellipse(538, 400, 20, 27)
W(EYES, BLACK, 0, 305)
HANDS = ellipse(434, 650, 20, 24) + ellipse(566, 650, 20, 24)
CRT = poly({{440,560},{560,560},{566,672},{434,672}})
W(HANDS, SKIN, 0, 306)
W(CRT, CASE, 0, 307)
SCR = poly({{454,574},{546,574},{548,642},{452,642}})
W(SCR, SCREEN, 0, 308)
SHOES = ellipse(462, 1056, 22, 10) + ellipse(538, 1056, 22, 10)
W(SHOES, BLACK, 0, 309)
SEA = rect(52, 1140, 896, 141)
W(SEA, FIRED, 0, 310)
for k = 0, 22 do
  local x = 62 + k * 40 + rand(-6, 6)
  local fl = poly({{x - 18, 1176}, {x + 18, 1176}, {x + 5, 1152}, {x + 1, 1132}, {x - 6, 1150}}, true) * INNER
  W(fl, FIRE, -1.57, 320 + k)
end
ARKH = poly({{410,1180},{590,1180},{560,1222},{440,1222}})
ARKP = ellipse(500, 1160, 34, 26)
W(ARKH, ARK, 0, 350)
W(ARKP, CASE, 0, 351)
local oct = {}
for k = 0, 7 do local a = math.pi / 8 + k * math.pi / 4; oct[#oct + 1] = {500 + 30 * math.cos(a), 72 + 30 * math.sin(a)} end
SUNM = poly(oct)
W(SUNM, SUNP, 0, 360)
for k = 0, 7 do
  local a = k * math.pi / 4
  local px = rect(500 + 46 * math.cos(a) - 5, 72 + 46 * math.sin(a) - 5, 10, 10) * HEAVEN
  W(px, SUNP, 0, 361 + k)
end
print(wait(4 * 24 * 60))

--@ chunk 3
-- the pale shapes came up grey over the wet darks: restate them on dry paint, heavier; then the darks over them once dry
local function W(m, p, a, s, c) work(m, {hand="detail", tool={kind="filbert", width=4}, pile=p, coverage=c or 6, fill=true, angle=a or 1.57, clip=m, seed=s}) end
local SKIN  = pile{{"lead white",3},{"yellow ochre",0.2},{"vermilion",0.1}}
local CASE  = pile{{"lead white",2},{"yellow ochre",0.6},{"bone black",0.1}}
local ARK   = pile{{"burnt sienna",1},{"Mars red",0.6},{"raw sienna",0.6}}
W(FACE - BANGS, SKIN, 0, 401)
W(HANDS, SKIN, 0, 402)
W(CRT - SCR, CASE, 0, 403)
W(ARKH, ARK, 0, 404)
W(ARKP, CASE, 0, 405)
print(wait(4 * 24 * 60))
local BLACK = pile{{"bone black",2.2},{"ultramarine blue",0.25}}
local SCREEN = pile{{"viridian",0.6},{"bone black",1.2},{"emerald green",0.3}}
W(BANGS, BLACK, 1.57, 410)
W(EYES, BLACK, 0, 411)
W(SCR, SCREEN, 0, 412)
print(wait(4 * 24 * 60))

--@ chunk 4
-- lines on dry paint. Every outline as short straight segments or circle arcs, never one long polyline
local rig = brush{kind="rigger", width=2.0, point=0.85}
local fine = brush{kind="rigger", width=1.3, point=0.95}
local fl = brush{kind="flat", width=6}
local function S(b, p, ld, pts, pr, clip) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.55, 0.5}, ramps={0.08, 0.15}, clip=clip}) end
local function seg(b, p, a, c, pr, clip) S(b, p, 0.8, {a, c}, pr, clip) end
local OUT  = pile{{"bone brown",1},{"bone black",0.6},{"red earth",0.3}}
local INC  = pile{{"raw sienna",1},{"burnt sienna",0.5},{"yellow ochre",0.4}}
local GOLDL = pile{{"lead white",1.5},{"Mars yellow",1},{"cadmium yellow",0.5}}
local REDL = pile{{"red earth",1.2},{"Mars red",0.6},{"bone black",0.2}}
local WHT  = pile{{"zinc white",4}}
local PHOS = pile{{"emerald green",1},{"zinc white",2}}
local PHOSD = pile{{"emerald green",1},{"viridian",0.5},{"zinc white",0.6}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.15}}
local LOCK = pile{{"ultramarine blue",1},{"bone black",1},{"lead white",0.4}}
local function arc(cx, cy, rx, ry, a0, a1, n) local t = {} for k = 0, n do local a = lerp(a0, a1, k / n); t[#t + 1] = {cx + rx * math.cos(a), cy + ry * math.sin(a)} end return t end
-- halo: incised rays, scanlines faintly, double rim
local behind = HALOM - (HAIRB:grow(2) + FACE:grow(2) + ROBEM:grow(2))
for k = 0, 55 do
  local a = 2 * math.pi * k / 56
  S(fine, INC, 0.6, {{HALO[1] + 120 * math.cos(a), HALO[2] + 120 * math.sin(a)}, {HALO[1] + 176 * math.cos(a), HALO[2] + 176 * math.sin(a)}}, {0.32, 0.32}, behind)
end
for y = HALO[2] - 180, HALO[2] + 180, 9 do S(fine, pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",0.6}}, 0.5, {{HALO[1] - 190, y}, {HALO[1] + 190, y}}, {0.22, 0.22}, behind) end
S(rig, OUT, 0.7, arc(HALO[1], HALO[2], 184, 184, 0, 2 * math.pi, 90), {0.55, 0.55}, -(HAIRB + ROBEM))
S(fine, REDL, 0.6, arc(HALO[1], HALO[2], 176, 176, 0, 2 * math.pi, 90), {0.4, 0.4}, behind)
-- hair locks: flat stylised strands, a few lines falling down each side, and a parting
for _, x in ipairs({392, 404, 416}) do seg(fine, LOCK, {x, 430}, {x + 4, 790}, {0.45, 0.2}) end
for _, x in ipairs({584, 596, 608}) do seg(fine, LOCK, {x, 430}, {x - 4, 790}, {0.45, 0.2}) end
for k = 0, 6 do local a = math.pi * (1.1 + 0.8 * k / 6); seg(fine, LOCK, {500 + 40 * math.cos(a), 300 + 40 * math.sin(a)}, {500 + 118 * math.cos(a), 350 + 118 * math.sin(a)}, {0.4, 0.2}) end
-- face: square highlights in the eyes, a small mouth, a blush
local function sq(x, y, s) work(rect(x, y, s, s), {hand="detail", pile=WHT, coverage=5, fill=true, angle=0, clip=rect(x, y, s, s), seed=math.floor(x * 7 + y)}) end
sq(466, 382, 8); sq(542, 382, 8); sq(452, 410, 4); sq(528, 410, 4)
seg(fine, pile{{"Mars red",1},{"rose madder",0.5}}, {494, 448}, {506, 448}, {0.6, 0.6})
local BL = pile{{"vermilion",0.6},{"lead white",2}}
for _, c in ipairs({{440, 432}, {560, 432}}) do for k = 0, 2 do seg(fine, BL, {c[1] - 8 + k * 6, c[2] + 3}, {c[1] - 4 + k * 6, c[2] - 3}, {0.4, 0.4}) end end
S(rig, OUT, 0.7, arc(500, 385, 92, 100, 0.1 * math.pi, 0.9 * math.pi, 20), {0.45, 0.45})
-- robe: neckline gold, folds, assist lines
S(rig, GOLDL, 0.8, arc(500, 470, 44, 18, 0.05 * math.pi, 0.95 * math.pi, 16), {0.6, 0.6})
for _, f in ipairs({{{452,700},{430,1040}}, {{548,700},{570,1040}}, {{480,690},{470,1040}}, {{520,690},{530,1040}}}) do seg(rig, OUT, f[1], f[2], {0.4, 0.55}) end
for _, f in ipairs({{{460,720},{440,1030}}, {{540,720},{560,1030}}, {{420,780},{396,1030}}, {{580,780},{604,1030}}, {{500,700},{500,1030}}}) do seg(fine, GOLDL, f[1], f[2], {0.3, 0.15}) end
S(rig, GOLDL, 0.8, {{362, 1040}, {638, 1040}}, {0.6, 0.6})
-- the CRT: the helm in green phosphor, scanlines, a soft glow of short rays
local hx, hy = 500, 606
S(rig, PHOS, 0.9, arc(hx, hy - 4, 16, 20, math.pi, 2 * math.pi, 10), {0.5, 0.5})
seg(rig, PHOS, {hx - 16, hy - 4}, {hx - 16, hy + 22}, {0.5, 0.5}); seg(rig, PHOS, {hx + 16, hy - 4}, {hx + 16, hy + 22}, {0.5, 0.5})
seg(rig, PHOS, {hx - 16, hy + 22}, {hx + 16, hy + 22}, {0.5, 0.5})
seg(fine, PHOS, {hx - 12, hy}, {hx + 12, hy}, {0.5, 0.5}); seg(fine, PHOS, {hx, hy}, {hx, hy + 18}, {0.5, 0.5})
local tip = brush{kind="round", width=4, point=0.4}
tip:reload(WHT, 1.0); tip:touch(hx, hy, {pressure=0.9})
for y = 578, 640, 5 do seg(fine, PHOSD, {456, y}, {544, y}, {0.15, 0.15}, SCR) end
for k = 0, 40 do
  local a = 2 * math.pi * k / 40
  local r0 = 72
  S(fine, PHOSD, 0.5, {{500 + r0 * math.cos(a), 616 + r0 * 0.75 * math.sin(a)}, {500 + (r0 + rand(10, 24)) * math.cos(a), 616 + (r0 + rand(10, 24)) * 0.75 * math.sin(a)}}, {0.35, 0.0}, -(CRT + HANDS + FACE))
end
seg(rig, OUT, {440, 560}, {560, 560}); seg(rig, OUT, {560, 560}, {566, 672}); seg(rig, OUT, {566, 672}, {434, 672}); seg(rig, OUT, {434, 672}, {440, 560})
-- fire tongues, short; the ark: gold rim, the seed with a bone cross
local FO = pile{{"Mars orange",1},{"cadmium yellow",0.5},{"lead white",0.3}}
local FY = pile{{"cadmium yellow",1},{"lead white",0.6}}
for k = 0, 44 do
  local x = 58 + k * 20
  for _, row in ipairs({1200, 1240, 1270}) do
    S(rig, (k + row) % 2 == 0 and FO or FY, 0.8, {{x + (row % 3) * 4, row}, {x + 4 + (row % 3) * 4, row - rand(16, 26)}}, {0.6, 0.0}, INNER - ARKH:grow(3) - ARKP:grow(3))
  end
end
seg(rig, GOLDL, {410, 1180}, {590, 1180}, {0.6, 0.6})
seg(rig, OUT, {590, 1180}, {560, 1222}); seg(rig, OUT, {560, 1222}, {440, 1222}); seg(rig, OUT, {440, 1222}, {410, 1180})
seg(rig, REDL, {500, 1142}, {500, 1176}, {0.7, 0.7}); seg(rig, REDL, {486, 1154}, {514, 1154}, {0.7, 0.7})
-- the pixel sun: a hard highlight square in the octagon
sq(490, 60, 9)
-- glyphs, red under titlos
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
glyphs(110, 230, 4, 1); glyphs(140, 290, 3, 2)
glyphs(770, 230, 4, 0); glyphs(790, 290, 3, 1)
-- the inner frame line, four segments
for _, s in ipairs({{{62,62},{938,62}}, {{938,62},{938,1271}}, {{938,1271},{62,1271}}, {{62,1271},{62,62}}}) do seg(rig, OUT, s[1], s[2], {0.5, 0.5}) end
