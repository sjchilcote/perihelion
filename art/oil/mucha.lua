-- easel session "mucha": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=2/3, linen={18,16}, seed=1896,
  ground={{pile={{"lead white",3},{"yellow ochre",0.35},{"raw sienna",0.05}}, um=80, apply="knife", texture=0.2}}}
-- H = 1500
CREAM = pile{{"lead white",3},{"yellow ochre",0.4}}
SAGE = pile{{"lead white",2},{"viridian",0.35},{"yellow ochre",0.5},{"bone black",0.1}}
GOLDS = pile{{"yellow ochre",1},{"lead white",1.5},{"Indian yellow",0.3}}
PBLUE = pile{{"lead white",2.5},{"cerulean blue",0.45},{"yellow ochre",0.1}}
HAIRP = pile{{"bone black",1.6},{"ultramarine blue",0.35},{"lead white",0.12}}
SKIN = pile{{"lead white",3},{"yellow ochre",0.15},{"rose madder",0.08}}
FRAME = rect(0, 0, 1000, 1500) - rect(48, 48, 904, 1404)
TITLE = rect(80, 1300, 840, 130)
HALO = ellipse(500, 560, 360, 360)
HALOIN = ellipse(500, 560, 300, 300)
FACE = poly({{430, 420}, {570, 420}, {578, 480}, {560, 540}, {500, 580}, {440, 540}, {422, 480}}, true)
NECK = rect(482, 570, 36, 50)
DRESS = poly({{372, 640}, {430, 606}, {500, 618}, {570, 606}, {628, 640}, {660, 800}, {680, 1000}, {720, 1290}, {280, 1290}, {320, 1000}, {340, 800}}, true)
HAIR = poly({{410, 300}, {500, 280}, {590, 300}, {640, 360}, {660, 450}, {650, 560}, {610, 620}, {578, 600}, {588, 470}, {560, 400}, {440, 400}, {412, 470}, {422, 600}, {390, 620}, {350, 560}, {340, 450}, {360, 360}}, true)
WL = {
  ribbon({{620, 560}, {700, 640}, {720, 760}, {660, 860}, {700, 980}, {780, 1040}}, {44, 40, 34, 28, 20, 8}),
  ribbon({{380, 560}, {300, 640}, {280, 760}, {340, 860}, {300, 980}, {220, 1040}}, {44, 40, 34, 28, 20, 8}),
  ribbon({{640, 400}, {740, 430}, {800, 520}, {770, 620}, {840, 700}}, {30, 28, 22, 16, 6}),
  ribbon({{360, 400}, {260, 420}, {200, 520}, {240, 620}, {170, 690}}, {30, 28, 22, 16, 6}),
}
HAIRALL = HAIR + WL[1] + WL[2] + WL[3] + WL[4]
work(rect(0, 0, 1000, 1500) - FRAME - HALO - TITLE, {hand="body", pile=CREAM, coverage=3, fill=true, clip=true, angle=math.pi/2, load=1})
work(FRAME, {hand="body", pile=SAGE, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(TITLE, {hand="body", pile=GOLDS, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(HALO - HALOIN - HAIRALL - DRESS, {hand="body", pile=GOLDS, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(HALOIN - HAIRALL - FACE - DRESS - NECK, {hand="body", pile=PBLUE, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(DRESS, {hand="body", pile=SAGE, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(FACE + NECK, {hand="detail", tool="round 3", pile=SKIN, coverage=4, fill=true, load=1})
work(HAIRALL - FACE - NECK - DRESS, {hand="detail", tool="round 3", pile=HAIRP, coverage=4, fill=true, load=1})
print(wait(5*1440))

--@ chunk 2
local legs = WL[1] + WL[2] + WL[3] + WL[4]
HL = poly({{420, 330}, {380, 420}, {372, 560}, {340, 680}, {300, 780}, {270, 900}, {300, 1010}, {262, 1090}, {300, 1060}, {340, 980}, {330, 880}, {370, 760}, {400, 650}, {420, 560}, {430, 450}}, true)
HR = poly({{580, 330}, {622, 420}, {630, 560}, {664, 690}, {706, 790}, {732, 905}, {700, 1015}, {742, 1095}, {700, 1062}, {660, 985}, {672, 880}, {632, 760}, {602, 650}, {582, 560}, {570, 450}}, true)
local newHair = HAIR + HL + HR
-- cover the stiff strands with whatever lies behind them
local bg = legs - newHair - DRESS
work(bg * (HALO - HALOIN), {hand="detail", tool="round 3", pile=GOLDS, coverage=4.5, fill=true, load=1})
work(bg * HALOIN, {hand="detail", tool="round 3", pile=PBLUE, coverage=4.5, fill=true, load=1})
work(bg - HALO, {hand="detail", tool="round 3", pile=CREAM, coverage=4.5, fill=true, load=1})
work(DRESS * legs, {hand="detail", tool="round 3", pile=SAGE, coverage=4.5, fill=true, load=1})
-- the dress recoated evenly
work(DRESS - newHair, {hand="body", tool="filbert 8", pile=SAGE, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work((HL + HR) - FACE - NECK, {hand="detail", tool="round 3", pile=HAIRP, coverage=4.5, fill=true, load=1})
HAIRALL = newHair
print(wait(4*1440))

--@ chunk 3
local dgold = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6}}
local blueL = pile{{"cerulean blue",0.6},{"lead white",1.2},{"bone black",0.08}}
local function st(p, pts, pr, w, clipM) local b = brush{kind="round", width=w or 2, point=0.7}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.05}, clip=clipM}) end
local function circ(cx, cy, r, n) local c = {} for k = 0, n do local a = k * 2 * math.pi / n; c[#c+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return c end
-- the gold ring: a chain of fold-notation circles, each a polygon holding a smaller copy turned by the golden angle
local ring = HALO - HALOIN - HAIRALL - DRESS
for k = 0, 23 do
  local a = k * 2 * math.pi / 24
  local cx, cy = 500 + 330 * math.cos(a), 560 + 330 * math.sin(a)
  if ring:at(cx, cy) > 0.5 then
    st(dgold, circ(cx, cy, 22, 36), {0.5, 0.5}, 1.8, ring)
    local n = 3 + (k % 5); local rot = k * 0.7
    for d = 0, 1 do
      local rr = 16 * (0.618 ^ d); local q = {}
      for i = 0, n do local aa = rot + d * 2.399 + i * 2 * math.pi / n; q[#q+1] = {cx + rr * math.cos(aa), cy + rr * math.sin(aa)} end
      st(dgold, q, {0.45, 0.45}, 1.4, ring)
    end
  end
end
st(dgold, circ(500, 560, 360, 120), {0.6, 0.6}, 2.4)
st(dgold, circ(500, 560, 300, 120), {0.6, 0.6}, 2.4, -(HAIRALL + DRESS + FACE))
-- the blue disc: a golden-angle spiral of dots, and faintly the outline of a CRT screen
local disc = HALOIN - HAIRALL - FACE - DRESS - NECK
local dot = brush{kind="round", width=5, point=0.05}
for n = 1, 420 do
  local r = 13 * math.sqrt(n); local a = n * 2.399963
  local x, y = 500 + r * math.cos(a), 560 + r * math.sin(a)
  if disc:at(x, y) > 0.5 then dot:reload(blueL, 0.6); dot:touch(x, y, {pressure=0.35 + 0.002 * math.sqrt(n)}) end
end
local crt = {{290, 380}, {500, 362}, {710, 380}, {728, 560}, {710, 740}, {500, 758}, {290, 740}, {272, 560}, {290, 380}}
st(blueL, crt, {0.45, 0.45}, 2.4, disc)
print(wait(3*1440))
-- whiplash strands sweeping out from the hair, each ending in low-poly facets
local HP = HAIRP
local HG = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.6}}
local strands = {
  {{{372, 600}, {300, 700}, {200, 760}, {140, 860}, {170, 960}, {120, 1030}}, {120, 1030}},
  {{{628, 600}, {705, 690}, {810, 750}, {868, 850}, {838, 955}, {885, 1030}}, {885, 1030}},
  {{{400, 380}, {300, 340}, {200, 380}, {150, 470}, {110, 520}}, {110, 520}},
  {{{600, 380}, {700, 335}, {805, 375}, {852, 465}, {893, 515}}, {893, 515}},
  {{{330, 900}, {250, 980}, {230, 1080}, {170, 1150}}, {170, 1150}},
  {{{675, 905}, {752, 985}, {770, 1085}, {832, 1152}}, {832, 1152}},
}
for _, s in ipairs(strands) do
  st(HP, s[1], {0.9, 0.35}, 16)
  local e = s[2]
  local tri = {{e[1], e[2]}, {e[1] + rand(-26, 26), e[2] + rand(10, 30)}, {e[1] + rand(-30, 30), e[2] - rand(5, 25)}}
  work(poly(tri), {hand="detail", tool="round 1.6", pile=HP, coverage=4.5, fill=true, load=1})
  local tri2 = {{e[1], e[2]}, tri[2], {e[1] + rand(-20, 20), e[2] + rand(30, 45)}}
  work(poly(tri2), {hand="detail", tool="round 1.6", pile=HG, coverage=4.5, fill=true, load=1})
end
-- bangs: a faceted fringe across the forehead
local bang = poly({{430, 410}, {570, 410}, {572, 452}, {552, 440}, {536, 462}, {516, 444}, {498, 466}, {478, 444}, {460, 462}, {446, 440}, {428, 452}})
work(bang, {hand="detail", tool="round 1.6", pile=HP, coverage=4.5, fill=true, load=1})
work(poly({{478, 444}, {498, 466}, {516, 444}, {498, 430}}), {hand="detail", tool="round 1.4", pile=HG, coverage=4.5, fill=true, load=1})
print(wait(3*1440))

--@ chunk 4
local function chaikin(p, it)
  for _ = 1, it do
    local q = {p[1]}
    for i = 1, #p - 1 do local a, b = p[i], p[i+1]; q[#q+1] = {0.75*a[1] + 0.25*b[1], 0.75*a[2] + 0.25*b[2]}; q[#q+1] = {0.25*a[1] + 0.75*b[1], 0.25*a[2] + 0.75*b[2]} end
    q[#q+1] = p[#p]; p = q
  end
  return p
end
local strands = {
  {{372, 600}, {300, 700}, {200, 760}, {140, 860}, {170, 960}, {120, 1030}},
  {{628, 600}, {705, 690}, {810, 750}, {868, 850}, {838, 955}, {885, 1030}},
  {{405, 390}, {300, 340}, {200, 380}, {150, 470}, {110, 520}},
  {{595, 390}, {700, 335}, {805, 375}, {852, 465}, {893, 515}},
  {{330, 900}, {250, 980}, {230, 1080}, {170, 1150}},
  {{675, 905}, {752, 985}, {770, 1085}, {832, 1152}},
}
local W0 = {34, 34, 26, 26, 26, 26}
local all = nil
for i, s in ipairs(strands) do
  local p = chaikin(s, 3)
  local ws = {} for k = 1, #p do ws[k] = W0[i] * (1 - 0.75 * (k - 1) / (#p - 1)) end
  local m = ribbon(p, ws)
  all = all and (all + m) or m
end
STR = all - FACE - NECK
work(STR, {hand="detail", tool="round 3", pile=HAIRP, coverage=4.5, fill=true, load=1})
-- larger low-poly facets where each strand ends
local HG = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.6}}
local HL2 = pile{{"bone black",0.6},{"ultramarine blue",0.5},{"lead white",1.2}}
for i, s in ipairs(strands) do
  local e = s[#s]; local d = s[#s - 1]
  local dx, dy = e[1] - d[1], e[2] - d[2]; local L = math.sqrt(dx*dx + dy*dy); dx, dy = dx / L, dy / L
  local nx, ny = -dy, dx
  local A = {e[1] - nx * 10, e[2] - ny * 10}; local B = {e[1] + nx * 10, e[2] + ny * 10}
  local T = {e[1] + dx * 34, e[2] + dy * 34}; local M = {e[1] + dx * 14 + nx * 18, e[2] + dy * 14 + ny * 18}
  work(poly({A, B, T}), {hand="detail", tool="round 1.4", pile=HAIRP, coverage=4.5, fill=true, load=1})
  work(poly({B, M, T}), {hand="detail", tool="round 1.4", pile=HG, coverage=4.5, fill=true, load=1})
  work(poly({A, {e[1] + dx * 20 - nx * 14, e[2] + dy * 20 - ny * 14}, T}), {hand="detail", tool="round 1.4", pile=HL2, coverage=4.5, fill=true, load=1})
end
print(wait(4*1440))

--@ chunk 5
-- join the strands into flowing wings of hair, so it reads as one mass that breaks into curls
WINGL = poly({{372, 560}, {330, 640}, {250, 720}, {175, 800}, {150, 880}, {168, 950}, {215, 925}, {250, 860}, {268, 960}, {290, 900}, {300, 800}, {340, 720}, {372, 650}}, true)
WINGR = poly({{628, 560}, {672, 640}, {752, 718}, {828, 800}, {852, 880}, {834, 950}, {787, 925}, {752, 860}, {734, 960}, {712, 900}, {702, 800}, {662, 720}, {630, 650}}, true)
local W = (WINGL + WINGR) - DRESS:shrink(30) - FACE - NECK
work(W, {hand="detail", tool="round 3", pile=HAIRP, coverage=4.5, fill=true, load=1})
HAIRALL = HAIRALL + STR + W
print(wait(4*1440))
-- strand lines in a lighter blue-black, following the flow
local LN = pile{{"bone black",0.8},{"ultramarine blue",0.6},{"lead white",1}}
local function chaikin(p, it)
  for _ = 1, it do
    local q = {p[1]}
    for i = 1, #p - 1 do local a, b = p[i], p[i+1]; q[#q+1] = {0.75*a[1] + 0.25*b[1], 0.75*a[2] + 0.25*b[2]}; q[#q+1] = {0.25*a[1] + 0.75*b[1], 0.25*a[2] + 0.75*b[2]} end
    q[#q+1] = p[#p]; p = q
  end
  return p
end
local flows = {
  {{430, 300}, {396, 420}, {390, 560}, {350, 680}, {290, 790}, {250, 900}},
  {{450, 296}, {414, 430}, {400, 580}, {330, 700}, {230, 790}, {180, 880}},
  {{570, 300}, {604, 420}, {610, 560}, {650, 680}, {710, 790}, {750, 900}},
  {{550, 296}, {586, 430}, {600, 580}, {670, 700}, {770, 790}, {820, 880}},
  {{470, 290}, {420, 330}, {340, 345}, {250, 370}},
  {{530, 290}, {580, 330}, {660, 345}, {750, 370}},
}
for _, f in ipairs(flows) do
  local b = brush{kind="round", width=2.2, point=0.8}
  b:reload(LN, 0.7); b:stroke(chaikin(f, 3), {pressure={0.1, 0.6}, ramps={0.3, 0.3}, clip=HAIRALL - FACE})
end

--@ chunk 6
local ink = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.15}}
local eyeD = pile{{"bone black",1.5},{"ultramarine blue",0.6}}
local eyeC = pile{{"cerulean blue",1},{"ultramarine blue",0.4},{"lead white",0.5}}
local wht = pile{{"lead white",3}}
local blush = pile{{"lead white",2},{"rose madder",0.4}}
local lip = pile{{"rose madder",1},{"cadmium red",0.3},{"lead white",0.8}}
local dgold = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6}}
local cream = pile{{"lead white",3},{"yellow ochre",0.4}}
local function st(p, pts, pr, w, clipM) local b = brush{kind="round", width=w or 2, point=0.7}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.05, 0.1}, clip=clipM}) end
-- chibi face: big eyes low on the face, a dot of a nose, a small mouth
for _, ex in ipairs({468, 532}) do
  local e = ellipse(ex, 492, 15, 19)
  work(e, {hand="detail", tool="round 1.4", pile=eyeD, coverage=5, fill=true, load=1})
  work(ellipse(ex, 498, 10, 12), {hand="detail", tool="round 1.2", pile=eyeC, coverage=5, fill=true, load=1})
  local b = brush{kind="round", width=5, point=0.05}; b:reload(wht, 0.9); b:touch(ex - 5, 484, {pressure=0.7})
  st(ink, {{ex - 17, 474}, {ex, 468}, {ex + 17, 474}}, {0.7, 0.5}, 2.6)
end
st(ink, {{500, 515}, {501, 517}}, {0.5, 0.5}, 1.6)
st(lip, {{492, 538}, {500, 541}, {508, 538}}, {0.6, 0.5}, 2.4)
st(blush, {{450, 520}, {460, 522}}, {0.4, 0.3}, 7); st(blush, {{540, 522}, {550, 520}}, {0.4, 0.3}, 7)
-- dress: a gold collar of fold-notation discs, pleat lines, an ornamented hem
local col = ribbon({{440, 612}, {470, 626}, {500, 630}, {530, 626}, {560, 612}}, 18)
work(col * DRESS, {hand="detail", tool="round 2", pile=pile{{"yellow ochre",1},{"lead white",1.5},{"Indian yellow",0.3}}, coverage=4.5, fill=true, load=1})
for k = 0, 4 do local x = 452 + k * 24; local b = brush{kind="round", width=8, point=0.05}; b:reload(pile{{"cerulean blue",1},{"lead white",1}}, 0.8); b:touch(x, 622 + (k == 2 and 6 or (k == 1 or k == 3) and 4 or 0), {pressure=0.7}) end
local SAGED = pile{{"lead white",1.2},{"viridian",0.45},{"yellow ochre",0.5},{"bone black",0.2}}
for _, x0 in ipairs({430, 470, 500, 530, 570}) do st(SAGED, {{x0, 660}, {x0 + (x0 - 500) * 0.35, 1000}, {x0 + (x0 - 500) * 0.8, 1280}}, {0.3, 0.6}, 2.2, DRESS) end
local hem = rect(280, 1220, 440, 50) * DRESS
work(hem, {hand="detail", tool="round 2", pile=pile{{"yellow ochre",1},{"lead white",1.5},{"Indian yellow",0.3}}, coverage=4.5, fill=true, load=1})
print(wait(3*1440))
for x = 300, 700, 30 do
  local c = {} for k = 0, 24 do local a = k * math.pi / 12; c[#c+1] = {x + 10 * math.cos(a), 1245 + 10 * math.sin(a)} end
  st(dgold, c, {0.45, 0.45}, 1.4, hem)
end
-- contour lines round the figure, Mucha's firm outline
local function outlineOf(m, w) work((m:grow(w) - m) - TITLE, {hand="detail", tool="round 1.6", pile=ink, coverage=4.5, fill=true, load=1}) end
outlineOf(DRESS - HAIRALL, 2.4)
outlineOf(HAIRALL + FACE + NECK, 2.6)
outlineOf(FACE, 1.4)

--@ chunk 7
local ink = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.15}}
local dgold = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6}}
local wht = pile{{"lead white",3}}
local SAGED = pile{{"lead white",1},{"viridian",0.5},{"yellow ochre",0.5},{"bone black",0.3}}
-- close the gaps beside and above the face with hair
local gap = (poly({{418, 385}, {582, 385}, {590, 560}, {570, 600}, {430, 600}, {410, 560}}) - FACE:grow(1) - NECK - DRESS) - poly({{430, 410}, {570, 410}, {572, 452}, {428, 452}})
work(gap, {hand="detail", tool="round 2", pile=HAIRP, coverage=4.5, fill=true, load=1})
-- eye lights
for _, ex in ipairs({468, 532}) do local b = brush{kind="round", width=6, point=0.05}; b:reload(wht, 1); b:touch(ex - 5, 486, {pressure=0.8}); local c = brush{kind="round", width=3, point=0.05}; c:reload(wht, 1); c:touch(ex + 5, 504, {pressure=0.7}) end
-- title: RATIO in blocky letters
local y0, h = 1322, 88
local function L(x, parts) local m = nil for _, r in ipairs(parts) do local q = rect(x + r[1], y0 + r[2], r[3], r[4]); m = m and (m + q) or q end return m end
local s = 22
local R = L(150, {{0, 0, s, h}, {0, 0, 90, s}, {68, 0, s, 50}, {0, 40, 90, s}, {50, 50, s, 38}})
local A = L(300, {{0, 0, s, h}, {68, 0, s, h}, {0, 0, 90, s}, {0, 40, 90, s}})
local T = L(450, {{0, 0, 90, s}, {34, 0, s, h}})
local I = L(600, {{20, 0, 50, s}, {34, 0, s, h}, {20, h - s, 50, s}})
local O = L(730, {{0, 0, s, h}, {68, 0, s, h}, {0, 0, 90, s}, {0, h - s, 90, s}})
work(R + A + T + I + O, {hand="detail", tool="round 2", pile=ink, coverage=5, fill=true, load=1})
print(wait(3*1440))
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.05}}) end
local function pad(x, y, r, p) local b = brush{kind="round", width=r, point=0.05}; b:reload(p, 0.85); b:touch(x, y, {pressure=0.75}) end
-- inner border lines and the title band's frame
local function box(x0, y0, x1, y1, p, w) st(p, {{x0, y0}, {x1, y0}}, nil, w); st(p, {{x1, y0}, {x1, y1}}, nil, w); st(p, {{x1, y1}, {x0, y1}}, nil, w); st(p, {{x0, y1}, {x0, y0}}, nil, w) end
box(48, 48, 952, 1452, ink, 2.4)
box(62, 62, 938, 1438, dgold, 1.6)
box(80, 1300, 920, 1430, ink, 2)
-- circuit tendrils: traces that run along the border, jog at right angles, curl like Art Nouveau stems, end in pads
local function tendril(pts, curl)
  st(dgold, pts, {0.55, 0.55}, 2.2)
  local e = pts[#pts]
  local c = {} for k = 0, 16 do local a = curl[1] + k * 0.38 * curl[2]; local r = 14 - k * 0.7; c[#c+1] = {e[1] + curl[3] + r * math.cos(a), e[2] + curl[4] + r * math.sin(a)} end
  st(dgold, c, {0.5, 0.3}, 1.8)
  pad(pts[1][1], pts[1][2], 7, ink)
end
tendril({{90, 1270}, {90, 1150}, {110, 1130}, {110, 980}}, {math.pi, 1, 14, 0})
tendril({{910, 1270}, {910, 1150}, {890, 1130}, {890, 980}}, {0, -1, -14, 0})
tendril({{90, 100}, {90, 260}, {110, 280}, {110, 420}}, {math.pi, -1, 14, 0})
tendril({{910, 100}, {910, 260}, {890, 280}, {890, 420}}, {0, 1, -14, 0})
tendril({{110, 82}, {260, 82}, {280, 100}, {400, 100}}, {-math.pi/2, 1, 0, 14})
tendril({{890, 82}, {740, 82}, {720, 100}, {600, 100}}, {-math.pi/2, -1, 0, 14})
for _, p in ipairs({{90, 700}, {910, 700}, {90, 560}, {910, 560}, {90, 840}, {910, 840}}) do pad(p[1], p[2], 10, dgold); pad(p[1], p[2], 4, ink) end
st(dgold, {{90, 560}, {90, 840}}, {0.5, 0.5}, 1.6); st(dgold, {{910, 560}, {910, 840}}, {0.5, 0.5}, 1.6)
-- small sage leaves along the frame
for y = 160, 1360, 90 do for _, x in ipairs({24, 976}) do local b = brush{kind="filbert", width=9}; b:reload(SAGED, 0.85); b:stroke({{x, y - 14}, {x + (x < 500 and 6 or -6), y}, {x, y + 14}}, {pressure={0.2, 0.2}, swell={0.3, 3, 0.3}}) end end

--@ chunk 8
local SAGED = pile{{"lead white",0.8},{"viridian",0.55},{"yellow ochre",0.5},{"bone black",0.4}}
local dgold = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.4}}
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.7}, ramps={0.03, 0.05}}) end
local function pad(x, y, r, p) local b = brush{kind="round", width=r, point=0.05}; b:reload(p, 0.9); b:touch(x, y, {pressure=0.8}) end
local function tendril(pts, curl)
  st(SAGED, pts, {0.8, 0.8}, 5)
  local e = pts[#pts]
  local c = {} for k = 0, 16 do local a = curl[1] + k * 0.38 * curl[2]; local r = 14 - k * 0.7; c[#c+1] = {e[1] + curl[3] + r * math.cos(a), e[2] + curl[4] + r * math.sin(a)} end
  st(SAGED, c, {0.75, 0.4}, 4)
  pad(pts[1][1], pts[1][2], 12, dgold)
end
tendril({{90, 1270}, {90, 1150}, {110, 1130}, {110, 980}}, {math.pi, 1, 14, 0})
tendril({{910, 1270}, {910, 1150}, {890, 1130}, {890, 980}}, {0, -1, -14, 0})
tendril({{90, 100}, {90, 260}, {110, 280}, {110, 420}}, {math.pi, -1, 14, 0})
tendril({{910, 100}, {910, 260}, {890, 280}, {890, 420}}, {0, 1, -14, 0})
tendril({{110, 82}, {260, 82}, {280, 100}, {400, 100}}, {-math.pi/2, 1, 0, 14})
tendril({{890, 82}, {740, 82}, {720, 100}, {600, 100}}, {-math.pi/2, -1, 0, 14})
st(SAGED, {{90, 560}, {90, 840}}, {0.8, 0.8}, 4); st(SAGED, {{910, 560}, {910, 840}}, {0.8, 0.8}, 4)
for _, p in ipairs({{90, 560}, {910, 560}, {90, 700}, {910, 700}, {90, 840}, {910, 840}}) do pad(p[1], p[2], 14, dgold) end
-- a crown motif at the top centre, between the two top tendrils
for k = -2, 2 do pad(500 + k * 26, 92 - math.abs(k) * -4, 12 - math.abs(k) * 2, dgold) end

--@ chunk 9
-- PASS 2, chunk A: the new hair's design, and the old stalks painted back to what lies behind them
local function chaikin(p, it)
  for _ = 1, it do
    local q = {p[1]}
    for i = 1, #p - 1 do local a, b = p[i], p[i+1]; q[#q+1] = {0.75*a[1] + 0.25*b[1], 0.75*a[2] + 0.25*b[2]}; q[#q+1] = {0.25*a[1] + 0.75*b[1], 0.25*a[2] + 0.75*b[2]} end
    q[#q+1] = p[#p]; p = q
  end
  return p
end
LOCKS = {
  {{{395, 420}, {330, 500}, {270, 580}, {230, 680}, {200, 760}, {170, 805}, {138, 792}, {132, 760}, {155, 744}}, 60},
  {{{405, 520}, {360, 640}, {330, 760}, {300, 880}, {250, 980}, {200, 1042}, {166, 1032}, {164, 1000}, {190, 994}}, 72},
  {{{420, 640}, {392, 760}, {372, 880}, {362, 1000}, {382, 1100}, {420, 1134}, {444, 1112}, {427, 1094}}, 50},
  {{{605, 420}, {672, 505}, {736, 592}, {772, 690}, {802, 772}, {834, 812}, {864, 797}, {868, 765}, {846, 750}}, 58},
  {{{595, 525}, {642, 648}, {672, 770}, {706, 886}, {754, 986}, {802, 1046}, {835, 1034}, {836, 1002}, {810, 995}}, 70},
  {{{582, 650}, {612, 768}, {630, 886}, {642, 1003}, {620, 1099}, {578, 1128}, {556, 1106}, {574, 1092}}, 48},
}
LOCKPTS = {}
local m = nil
for i, L in ipairs(LOCKS) do
  local p = chaikin(L[1], 3)
  LOCKPTS[i] = p
  local ws = {} for k = 1, #p do local t = (k - 1) / (#p - 1); ws[k] = math.max(8, L[2] * (1 - 0.85 * t^1.3)) end
  local r = ribbon(p, ws)
  m = m and (m + r) or r
end
local shoulders = poly({{385, 370}, {330, 470}, {300, 590}, {360, 680}, {425, 620}, {428, 440}}, true)
                + poly({{615, 370}, {672, 472}, {702, 592}, {640, 682}, {576, 622}, {572, 440}}, true)
NEWHAIR = HAIR + shoulders + m
-- paint the old stalks, wings and their facets back
local OLD = (HAIRALL + STR + WINGL + WINGR + HL + HR):grow(5)
for _, e in ipairs({{120, 1030}, {885, 1030}, {110, 520}, {893, 515}, {170, 1150}, {832, 1152}}) do OLD = OLD + ellipse(e[1], e[2] + 10, 44, 48) end
OLD = OLD - NEWHAIR - FACE - NECK - TITLE - FRAME - HAIR
local onDress = OLD * DRESS
local onDisc = (OLD - DRESS) * HALOIN
local onRing = (OLD - DRESS) * (HALO - HALOIN)
local onCream = OLD - DRESS - HALO
work(onDress, {hand="detail", tool="round 3", pile=SAGE, coverage=4.5, fill=true, load=1})
work(onDisc, {hand="detail", tool="round 3", pile=PBLUE, coverage=4.5, fill=true, load=1})
work(onRing, {hand="detail", tool="round 3", pile=GOLDS, coverage=4.5, fill=true, load=1})
work(onCream, {hand="detail", tool="round 3", pile=CREAM, coverage=4.5, fill=true, load=1})
EXPOSED = OLD
print(wait(4*1440))

--@ chunk 10
local band = (EXPOSED:grow(9) - EXPOSED:shrink(4)) - NEWHAIR - FACE - NECK - TITLE - FRAME - HAIR
local col = ribbon({{440, 612}, {470, 626}, {500, 630}, {530, 626}, {560, 612}}, 22)
band = band - col - rect(280, 1215, 440, 60)
work(band * DRESS, {hand="detail", tool="round 3", pile=SAGE, coverage=4.5, fill=true, load=1})
work((band - DRESS) * HALOIN, {hand="detail", tool="round 3", pile=PBLUE, coverage=4.5, fill=true, load=1})
work((band - DRESS) * (HALO - HALOIN), {hand="detail", tool="round 3", pile=GOLDS, coverage=4.5, fill=true, load=1})
work(band - DRESS - HALO, {hand="detail", tool="round 3", pile=CREAM, coverage=4.5, fill=true, load=1})
EXPOSED = EXPOSED:grow(9)
print(wait(4*1440))

--@ chunk 11
-- PASS 2, chunk B: restore the ornament where the stalks were, then lay the new hair
local dgold = pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6}}
local blueL = pile{{"cerulean blue",0.6},{"lead white",1.2},{"bone black",0.08}}
local ink = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.15}}
local SAGED = pile{{"lead white",1.2},{"viridian",0.45},{"yellow ochre",0.5},{"bone black",0.2}}
local function st(p, pts, pr, w, clipM) local b = brush{kind="round", width=w or 2, point=0.7}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.05}, clip=clipM}) end
local function circ(cx, cy, r, n) local c = {} for k = 0, n do local a = k * 2 * math.pi / n; c[#c+1] = {cx + r * math.cos(a), cy + r * math.sin(a)} end return c end
local E = EXPOSED:grow(2) - NEWHAIR
local ring = (HALO - HALOIN - DRESS) * E
for k = 0, 23 do
  local a = k * 2 * math.pi / 24
  local cx, cy = 500 + 330 * math.cos(a), 560 + 330 * math.sin(a)
  if ring:at(cx, cy) > 0.5 then
    st(dgold, circ(cx, cy, 22, 36), {0.5, 0.5}, 1.8, ring)
    local n = 3 + (k % 5); local rot = k * 0.7
    for d = 0, 1 do
      local rr = 16 * (0.618 ^ d); local q = {}
      for i = 0, n do local aa = rot + d * 2.399 + i * 2 * math.pi / n; q[#q+1] = {cx + rr * math.cos(aa), cy + rr * math.sin(aa)} end
      st(dgold, q, {0.45, 0.45}, 1.4, ring)
    end
  end
end
st(dgold, circ(500, 560, 360, 120), {0.6, 0.6}, 2.4, E)
st(dgold, circ(500, 560, 300, 120), {0.6, 0.6}, 2.4, E - DRESS)
local disc = (HALOIN - DRESS) * E
local dot = brush{kind="round", width=5, point=0.05}
for n = 1, 420 do
  local r = 13 * math.sqrt(n); local a = n * 2.399963
  local x, y = 500 + r * math.cos(a), 560 + r * math.sin(a)
  if disc:at(x, y) > 0.5 then dot:reload(blueL, 0.6); dot:touch(x, y, {pressure=0.35 + 0.002 * math.sqrt(n)}) end
end
st(blueL, {{290, 380}, {500, 362}, {710, 380}, {728, 560}, {710, 740}, {500, 758}, {290, 740}, {272, 560}, {290, 380}}, {0.45, 0.45}, 2.4, disc)
for _, x0 in ipairs({430, 470, 500, 530, 570}) do st(SAGED, {{x0, 660}, {x0 + (x0 - 500) * 0.35, 1000}, {x0 + (x0 - 500) * 0.8, 1280}}, {0.3, 0.6}, 2.2, DRESS * E) end
work(((DRESS:grow(2.4) - DRESS) * E) - TITLE, {hand="detail", tool="round 1.6", pile=ink, coverage=4.5, fill=true, load=1})
print(wait(2*1440))
-- the new hair: broad masses of black silk
work(NEWHAIR - HAIR - FACE - NECK, {hand="detail", tool="round 3", pile=HAIRP, coverage=4.5, fill=true, load=1})
print(wait(4*1440))

--@ chunk 12
-- PASS 2, chunk C: Mucha's lines through the hair, faceted curl ends, crisp contours
local ink = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.15}}
local LN = pile{{"bone black",0.7},{"ultramarine blue",0.6},{"lead white",1.1}}
local HG = pile{{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.6}}
local HL2 = pile{{"bone black",0.5},{"ultramarine blue",0.5},{"lead white",1.4}}
for i, p in ipairs(LOCKPTS) do
  local W = LOCKS[i][2]
  for _, off in ipairs({-0.28, 0, 0.26}) do
    local q = {}
    for k = 1, #p - 4 do
      local a, b = p[k], p[math.min(#p, k + 1)]
      local dx, dy = b[1] - a[1], b[2] - a[2]; local L = math.sqrt(dx*dx + dy*dy) + 1e-6
      local t = (k - 1) / (#p - 1); local w = math.max(8, W * (1 - 0.85 * t^1.3))
      q[#q+1] = {a[1] - dy / L * w * off, a[2] + dx / L * w * off}
    end
    local b = brush{kind="round", width=1.8, point=0.8}
    b:reload(LN, 0.7); b:stroke(q, {pressure={0.15, 0.55}, swell={0.5, 1, 1, 0.4}, ramps={0.3, 0.4}, clip=NEWHAIR - FACE})
  end
  -- curl end: two or three low-poly facets
  local e = p[#p]; local d = p[#p - 3]
  local dx, dy = e[1] - d[1], e[2] - d[2]; local L = math.sqrt(dx*dx + dy*dy) + 1e-6; dx, dy = dx / L, dy / L
  local nx, ny = -dy, dx
  local A = {e[1] - nx * 7, e[2] - ny * 7}; local B = {e[1] + nx * 7, e[2] + ny * 7}
  local T = {e[1] + dx * 26, e[2] + dy * 26}
  local M = {e[1] + dx * 12 + nx * 14, e[2] + dy * 12 + ny * 14}
  work(poly({A, B, T}), {hand="detail", tool="round 1.4", pile=HG, coverage=4.5, fill=true, load=1})
  work(poly({B, M, T}), {hand="detail", tool="round 1.4", pile=HL2, coverage=4.5, fill=true, load=1})
  if i % 2 == 0 then work(poly({A, {e[1] + dx * 14 - nx * 13, e[2] + dy * 14 - ny * 13}, T}), {hand="detail", tool="round 1.4", pile=HAIRP, coverage=4.5, fill=true, load=1}) end
end
print(wait(3*1440))
-- crisp contour round the hair, and round the face again where the new hair meets it
work((NEWHAIR:grow(2.6) - NEWHAIR) - FACE - NECK - TITLE, {hand="detail", tool="round 1.6", pile=ink, coverage=4.5, fill=true, load=1})
work((FACE:grow(1.4) - FACE) - NECK, {hand="detail", tool="round 1.4", pile=ink, coverage=4.5, fill=true, load=1})

--@ chunk 13
local function chaikin(p, it)
  for _ = 1, it do
    local q = {p[1]}
    for i = 1, #p - 1 do local a, b = p[i], p[i+1]; q[#q+1] = {0.75*a[1] + 0.25*b[1], 0.75*a[2] + 0.25*b[2]}; q[#q+1] = {0.25*a[1] + 0.75*b[1], 0.25*a[2] + 0.75*b[2]} end
    q[#q+1] = p[#p]; p = q
  end
  return p
end
local function closed(p, it) local q = chaikin(p, it); return q end
MASSL = poly(closed({{392, 380}, {330, 470}, {262, 580}, {222, 690}, {214, 800}, {238, 900}, {268, 990}, {330, 1060}, {396, 1112}, {424, 1090}, {414, 960}, {412, 820}, {416, 680}, {424, 540}, {420, 430}, {392, 380}}, 3), true)
MASSR = poly(closed({{608, 380}, {670, 470}, {738, 580}, {778, 690}, {786, 800}, {762, 900}, {732, 990}, {670, 1060}, {604, 1112}, {576, 1090}, {586, 960}, {588, 820}, {584, 680}, {576, 540}, {580, 430}, {608, 380}}, 3), true)
local add = (MASSL + MASSR) - NEWHAIR - FACE - NECK
work(add, {hand="detail", tool="round 3", pile=HAIRP, coverage=4.5, fill=true, load=1})
NEWHAIR = NEWHAIR + MASSL + MASSR
print(wait(4*1440))
-- long S-curve lines through each mass, following the sweep, so it reads as silk
local LN = pile{{"bone black",0.7},{"ultramarine blue",0.6},{"lead white",1.1}}
local flowsL = {
  {{400, 400}, {350, 520}, {300, 640}, {270, 760}, {275, 880}, {320, 990}, {390, 1080}},
  {{410, 430}, {372, 560}, {340, 690}, {330, 820}, {345, 940}, {390, 1060}},
  {{386, 400}, {320, 500}, {262, 620}, {238, 740}, {240, 850}},
}
for _, f in ipairs(flowsL) do
  for _, side in ipairs({1, -1}) do
    local q = {} for i, p in ipairs(f) do q[i] = {500 + side * (p[1] - 500), p[2]} end
    local b = brush{kind="round", width=1.8, point=0.8}
    b:reload(LN, 0.7); b:stroke(chaikin(q, 3), {pressure={0.15, 0.5}, swell={0.4, 1, 1, 0.4}, ramps={0.3, 0.4}, clip=NEWHAIR - FACE})
  end
end
print(wait(3*1440))
local ink = pile{{"bone brown",1},{"bone black",0.5},{"ultramarine blue",0.15}}
work((NEWHAIR:grow(2.6) - NEWHAIR) - FACE - NECK - TITLE, {hand="detail", tool="round 1.6", pile=ink, coverage=4.5, fill=true, load=1})

--@ chunk 14
print(wait(2*1440))
local Z = (EXPOSED:grow(16) - EXPOSED:shrink(2)) - NEWHAIR:grow(3) - FACE - NECK - TITLE - FRAME - rect(70, 60, 60, 1380) - rect(870, 60, 60, 1380) - rect(60, 60, 880, 70)
local disc = Z * HALOIN - DRESS:grow(3)
local cream = Z - HALO - DRESS:grow(3)
work(cream, {hand="detail", tool="round 3", pile=CREAM, coverage=4, fill=true, load=1})
work(disc, {hand="detail", tool="round 3", pile=PBLUE, coverage=4, fill=true, load=1})
