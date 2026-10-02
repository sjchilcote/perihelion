-- easel session "rose_window": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen={16,18}, seed=1919, ground={{pile={{"bone black",1.6},{"burnt sienna",0.6},{"ultramarine blue",0.3}}, um=140, apply="knife", texture=0.3}}}
C = {500, 470}
RUBY = pile{{"cadmium red",1},{"rose madder",0.8},{"vermilion",0.2}}
BLUE = pile{{"ultramarine blue",1.2},{"cobalt blue",0.8},{"lead white",0.35}}
GOLD = pile{{"cadmium yellow",1},{"Indian yellow",0.4},{"lead white",0.5}}
GREEN = pile{{"emerald green",0.8},{"viridian",0.6},{"lead white",0.5}}
VIOL = pile{{"cobalt violet",1},{"ultramarine blue",0.3},{"lead white",0.3}}
CRM = pile{{"lead white",2},{"lemon chrome",0.15}}
function arcpts(r, a0, a1, n) local t = {} for k = 0, n do local a = lerp(a0, a1, k / n); t[#t + 1] = {C[1] + r * math.cos(a), C[2] + r * math.sin(a)} end; return t end
function sector(r0, r1, a0, a1) local t = arcpts(r1, a0, a1, 12); local b = arcpts(r0, a1, a0, 8); for _, p in ipairs(b) do t[#t + 1] = p end; return t end
local function W(m, p, s) work(m, {hand="detail", tool={kind="filbert", width=5}, pile=p, coverage=4.2, fill=true, angle=0.3, clip=m, seed=s}) end
-- medallion: sun glass in deep blue
W(ellipse(C[1], C[2], 128, 128) - ellipse(C[1], C[2], 92, 92), BLUE, 101)
W(ellipse(C[1], C[2], 92, 92), GOLD, 102)
-- twelve petals, ruby and blue alternately, each with a border of the other colour's glass
PET = {}
for i = 0, 11 do
  local a = -math.pi / 2 + i * math.pi / 6
  local a0, a1 = a - math.pi / 12 + 0.03, a + math.pi / 12 - 0.03
  PET[#PET + 1] = {a = a, a0 = a0, a1 = a1}
  W(poly(sector(140, 330, a0, a1)), (i % 2 == 0) and BLUE or RUBY, 110 + i)
end
-- outer ring: blue glass, with twelve gold roundels for the glyphs, green and violet between
W(ellipse(C[1], C[2], 440, 440) - ellipse(C[1], C[2], 348, 348), BLUE, 130)
print(wait(3 * 24 * 60))
for i = 0, 11 do
  local a = -math.pi / 2 + i * math.pi / 6
  W(ellipse(C[1] + 394 * math.cos(a), C[2] + 394 * math.sin(a), 36, 36), (i % 2 == 0) and GOLD or GREEN, 140 + i)
  local b = a + math.pi / 12
  W(ellipse(C[1] + 394 * math.cos(b), C[2] + 394 * math.sin(b), 14, 14), (i % 2 == 0) and RUBY or VIOL, 160 + i)
end
print(wait(3 * 24 * 60))

--@ chunk 2
-- the little scenes in the petals (upright), and the coloured light falling on the wall
local function W(pts, p, s) local m = poly(pts); work(m, {hand="detail", tool={kind="filbert", width=3}, pile=p, coverage=4.5, fill=true, angle=0.3, clip=m, seed=s}) end
local function Wm(m, p, s) work(m, {hand="detail", tool={kind="filbert", width=3}, pile=p, coverage=4.5, fill=true, angle=0.3, clip=m, seed=s}) end
SC = {}
for i, P in ipairs(PET) do SC[i] = {C[1] + 238 * math.cos(P.a), C[2] + 238 * math.sin(P.a)} end
local function at(i, pts) local c = SC[i]; local t = {} for _, p in ipairs(pts) do t[#t + 1] = {c[1] + p[1], c[2] + p[2]} end; return t end
local function el(i, x, y, rx, ry) return ellipse(SC[i][1] + x, SC[i][2] + y, rx, ry) end
-- 1 the CUCULUS crosses
W(at(1, {{-30,-6},{20,-16},{34,-6},{22,8},{-24,10}}), GOLD, 201); W(at(1, {{-24,10},{22,8},{18,16},{-18,18}}), RUBY, 202)
-- 2 the seed burrows
for k = 0, 2 do Wm(el(2, -18 + k * 16, 18, 8, 6), GOLD, 203 + k) end; W(at(2, {{-6,-34},{10,-30},{4,10},{-4,10}}), BLUE, 206)
-- 3 the new frame takes the tabard
Wm(el(3, 0, -30, 7, 8), CRM, 207); W(at(3, {{-10,-20},{10,-20},{12,10},{-12,10}}), RUBY, 208); W(at(3, {{-9,10},{-2,10},{-4,34},{-11,34}}), GOLD, 209); W(at(3, {{2,10},{9,10},{11,34},{4,34}}), GOLD, 210)
-- 4 the dead outpost
W(at(4, {{-26,-20},{26,-20},{26,26},{-26,26}}), CRM, 211); W(at(4, {{-10,4},{2,4},{2,26},{-10,26}}), BLUE, 212); W(at(4, {{8,-8},{18,-8},{18,2},{8,2}}), BLUE, 213)
-- 5 Ratio on her screen
W(at(5, {{-24,-22},{24,-22},{24,18},{-24,18}}), CRM, 214); W(at(5, {{-18,-16},{18,-16},{18,12},{-18,12}}), GREEN, 215); Wm(el(5, 0, -2, 8, 9), CRM, 216)
-- 6 the docents
Wm(el(6, -12, 4, 9, 22), CRM, 217); Wm(el(6, 12, 4, 9, 22), CRM, 218); W(at(6, {{-30,-30},{30,-30},{30,-22},{-30,-22}}), GOLD, 219)
-- 7 a Warden
W(at(7, {{-20,30},{-8,-30},{8,-10},{20,30}}), GREEN, 220); W(at(7, {{-8,-30},{4,-40},{12,-22},{8,-10}}), RUBY, 221)
-- 8 the lightning
W(at(8, {{-8,-36},{10,-36},{0,-6},{14,-6},{-10,36},{-2,4},{-14,4}}), GOLD, 222)
-- 9 the sail spreads
W(at(9, {{-4,30},{-30,-30},{10,-34}}), GOLD, 223); W(at(9, {{-4,30},{10,-34},{30,-4}}), RUBY, 224)
-- 10 perihelion
Wm(el(10, 0, 0, 26, 26), GOLD, 225)
-- 11 the station sails on
Wm(el(11, 0, 0, 26, 26) - el(11, 0, 0, 15, 15), GOLD, 226); Wm(el(11, 0, 0, 6, 6), RUBY, 227)
-- 12 the seed, an ark
Wm(el(12, 0, -10, 16, 12), CRM, 228); W(at(12, {{-28,4},{28,4},{18,20},{-18,20}}), BLUE, 229)
-- coloured light on the wall below and to the sides: dimmer patches with lost edges
local dims = {pile{{"cadmium red",1},{"rose madder",0.6},{"bone black",0.5}}, pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"bone black",0.3},{"lead white",0.2}}, pile{{"Indian yellow",1},{"yellow ochre",0.6},{"bone black",0.35}}}
local patches = {{{240,940},{330,930},{350,990},{250,998}}, {{380,950},{480,944},{490,995},{390,998}}, {{540,948},{640,952},{650,998},{545,996}}, {{690,935},{770,945},{760,995},{680,990}}, {{40,780},{90,800},{80,880},{30,860}}, {{920,790},{970,770},{975,860},{925,870}}}
for i, p in ipairs(patches) do
  local m = poly(p)
  work(m, {hand="body", tool="filbert 5", pile=dims[(i % 3) + 1], coverage=2.6, fill=true, angle=0.2, edge="soft", clip=m:grow(6), seed=240 + i})
end
print(wait(4 * 24 * 60))

--@ chunk 3
-- tracery and leads, on dry glass; the sun's face; glyphs in the roundels; the glow
local TR = pile{{"bone black",1.8},{"burnt sienna",0.6},{"raw sienna",0.2}}
local LEAD = pile{{"bone black",2},{"ultramarine blue",0.3}}
local fl = brush{kind="flat", width=7}
local rd = brush{kind="round", width=3, point=0.4}
local fine = brush{kind="rigger", width=1.6, point=0.9}
local function seg(b, p, a, c, pr) b:reload(p, 0.85); b:stroke({a, c}, {pressure=pr or {0.8, 0.8}, ramps={0.03, 0.03}}) end
local function arc(b, p, cx, cy, r, a0, a1, pr)
  local n = math.max(2, math.floor(math.abs(a1 - a0) * r / 12))
  for k = 0, n - 1 do
    local t0, t1 = lerp(a0, a1, k / n), lerp(a0, a1, (k + 1) / n)
    seg(b, p, {cx + r * math.cos(t0), cy + r * math.sin(t0)}, {cx + r * math.cos(t1), cy + r * math.sin(t1)}, pr)
  end
end
local cx, cy = C[1], C[2]
-- thin leads first
for _, P in ipairs(PET) do
  for _, r in ipairs({176, 300}) do arc(rd, LEAD, cx, cy, r, P.a0, P.a1, {0.6, 0.6}) end
  seg(rd, LEAD, {cx + 140 * math.cos(P.a), cy + 140 * math.sin(P.a)}, {cx + 176 * math.cos(P.a), cy + 176 * math.sin(P.a)}, {0.6, 0.6})
  seg(rd, LEAD, {cx + 300 * math.cos(P.a), cy + 300 * math.sin(P.a)}, {cx + 330 * math.cos(P.a), cy + 330 * math.sin(P.a)}, {0.6, 0.6})
  local b = P.a + math.pi / 12
  seg(rd, LEAD, {cx + 348 * math.cos(b - 0.06), cy + 348 * math.sin(b - 0.06)}, {cx + 380 * math.cos(b - 0.03), cy + 380 * math.sin(b - 0.03)}, {0.6, 0.6})
  seg(rd, LEAD, {cx + 408 * math.cos(b + 0.03), cy + 408 * math.sin(b + 0.03)}, {cx + 440 * math.cos(b + 0.06), cy + 440 * math.sin(b + 0.06)}, {0.6, 0.6})
  seg(rd, LEAD, {cx + 92 * math.cos(b), cy + 92 * math.sin(b)}, {cx + 128 * math.cos(b), cy + 128 * math.sin(b)}, {0.6, 0.6})
end
-- the glow: lighter streaks in the glass, as old glass varies
local LB = pile{{"cobalt blue",1},{"lead white",1.2},{"cerulean blue",0.3}}
local LR = pile{{"vermilion",1},{"cadmium red",0.5},{"lead white",0.5}}
for i, P in ipairs(PET) do
  for k = 0, 2 do
    local a = lerp(P.a0 + 0.04, P.a1 - 0.04, (k + 0.5) / 3)
    local r0 = (k == 1) and 305 or 150
    fine:reload((i % 2 == 1) and LB or LR, 0.6)
    fine:stroke({{cx + r0 * math.cos(a), cy + r0 * math.sin(a)}, {cx + (r0 + 20) * math.cos(a + 0.02), cy + (r0 + 20) * math.sin(a + 0.02)}}, {pressure={0.5, 0.2}})
  end
end
-- the sun's face, in lead
arc(fine, LEAD, cx - 30, cy - 8, 14, 0.15 * math.pi, 0.85 * math.pi, {0.6, 0.6})
arc(fine, LEAD, cx + 30, cy - 8, 14, 0.15 * math.pi, 0.85 * math.pi, {0.6, 0.6})
seg(fine, LEAD, {cx, cy - 6}, {cx - 5, cy + 20}, {0.5, 0.5}); seg(fine, LEAD, {cx - 5, cy + 20}, {cx + 5, cy + 22}, {0.5, 0.5})
arc(fine, LEAD, cx, cy + 22, 22, 0.25 * math.pi, 0.75 * math.pi, {0.6, 0.6})
for k = 0, 15 do local a = 2 * math.pi * k / 16; seg(fine, pile{{"Mars orange",1},{"cadmium red",0.4}}, {cx + 62 * math.cos(a), cy + 62 * math.sin(a)}, {cx + 86 * math.cos(a), cy + 86 * math.sin(a)}, {0.5, 0.2}) end
-- fold glyphs in the roundels
for i = 0, 11 do
  local a = -math.pi / 2 + i * math.pi / 6
  local gx, gy = cx + 394 * math.cos(a), cy + 394 * math.sin(a)
  local n = 3 + (i % 4)
  local p, q = {}, {}
  for j = 0, n do local t = i * 0.5 + 2 * math.pi * j / n; p[#p + 1] = {gx + 22 * math.cos(t), gy + 22 * math.sin(t)}; local u = t + 0.3 + (i % 3) * 0.4; q[#q + 1] = {gx + 13.6 * math.cos(u), gy + 13.6 * math.sin(u)} end
  for j = 1, n do seg(rd, LEAD, p[j], p[j + 1], {0.6, 0.6}); seg(fine, LEAD, q[j], q[j + 1], {0.6, 0.6}) end
end
-- tracery: heavy bronze, nearly black against the light
for _, r in ipairs({92, 130, 138, 332, 346, 442}) do arc(fl, TR, cx, cy, r, 0, 2 * math.pi, {0.85, 0.85}) end
for _, P in ipairs(PET) do
  for _, a in ipairs({P.a0 - 0.03, P.a1 + 0.03}) do seg(fl, TR, {cx + 136 * math.cos(a), cy + 136 * math.sin(a)}, {cx + 334 * math.cos(a), cy + 334 * math.sin(a)}, {0.85, 0.85}) end
  local gx, gy = cx + 394 * math.cos(P.a), cy + 394 * math.sin(P.a)
  arc(fl, TR, gx, gy, 37, 0, 2 * math.pi, {0.7, 0.7})
  local b = P.a + math.pi / 12
  arc(rd, TR, cx + 394 * math.cos(b), cy + 394 * math.sin(b), 15, 0, 2 * math.pi, {0.7, 0.7})
end
-- a thin warm edge where the bronze catches the glow
arc(fine, pile{{"raw sienna",1},{"Mars orange",0.4},{"lead white",0.3}}, cx, cy, 447, 0, 2 * math.pi, {0.35, 0.35})

--@ chunk 4
-- (2) paint out the blocky patches with the wall's dark; (1) the glass lit from behind
local WALL = pile{{"bone black",1.6},{"burnt sienna",0.6},{"ultramarine blue",0.3}}
for _, p in ipairs({{{230,925},{340,915},{362,1005},{240,1005}}, {{370,935},{492,930},{502,1005},{380,1005}}, {{530,935},{652,940},{662,1005},{535,1005}}, {{678,922},{782,932},{772,1005},{668,1000}}, {{25,765},{102,788},{92,895},{15,875}}, {{908,775},{985,755},{990,875},{912,885}}}) do
  local m = poly(p)
  work(m, {hand="body", tool="filbert 6", pile=WALL, coverage=4.5, fill=true, angle=0.2, clip=m, seed=401})
end
local cx, cy = C[1], C[2]
local BL1 = pile{{"cobalt blue",1},{"lead white",0.9},{"cerulean blue",0.4}}
local BL2 = pile{{"cerulean blue",1},{"lead white",1.6},{"cobalt blue",0.3}}
local RU1 = pile{{"vermilion",1},{"cadmium red",0.6},{"lead white",0.3},{"cadmium yellow",0.1}}
local RU2 = pile{{"vermilion",1},{"cadmium yellow",0.35},{"lead white",0.7}}
for i, P in ipairs(PET) do
  local even = (i % 2 == 1)
  -- the inner band, a step lighter
  local inner = poly(sector(144, 172, P.a0 + 0.02, P.a1 - 0.02))
  work(inner, {hand="detail", tool={kind="filbert", width=4}, pile=even and BL2 or RU2, coverage=4.5, fill=true, angle=P.a, clip=inner, seed=410 + i})
  -- the main pane: lighter toward its centre and toward the Sun, the scene kept clear
  local sc = SC[i]
  local pane = poly(sector(181, 296, P.a0 + 0.025, P.a1 - 0.025)) - ellipse(sc[1], sc[2], 46, 46)
  stipple(pane, {pile=even and BL1 or RU1, width=5, coverage=function(x, y)
      local r = math.sqrt((x - cx)^2 + (y - cy)^2)
      return clamp(2.4 * (1 - (r - 181) / 140), 0.2, 2.4) end, feather=0.8, cluster=0.2, clip=pane, seed=430 + i})
end
-- the blue ring round the Sun, pale and luminous
local ringb = ellipse(cx, cy, 126, 126) - ellipse(cx, cy, 95, 95)
work(ringb, {hand="detail", tool={kind="filbert", width=4}, pile=BL2, coverage=4.5, fill=true, angle=0, clip=ringb, seed=450})
-- the Sun's disc hotter at its centre
local SUNW = pile{{"lead white",2},{"lemon chrome",0.6},{"cadmium yellow",0.3}}
stipple(ellipse(cx, cy, 80, 80), {pile=SUNW, width=5, coverage=function(x, y) local d = math.sqrt((x - cx)^2 + (y - cy)^2) / 80; return clamp(1.8 * (1 - d), 0, 1.8) end, feather=0.9, seed=451})
print(wait(4 * 24 * 60))

--@ chunk 5
-- leads and face restated; flecks of light over the leads near the centre; soft slanted light thrown on wall and floor
local cx, cy = C[1], C[2]
local LEAD = pile{{"bone black",2},{"ultramarine blue",0.3}}
local rd = brush{kind="round", width=3, point=0.4}
local fine = brush{kind="rigger", width=1.6, point=0.9}
local function seg(b, p, a, c, pr) b:reload(p, 0.85); b:stroke({a, c}, {pressure=pr or {0.6, 0.6}, ramps={0.03, 0.03}}) end
local function arc(b, p, x0, y0, r, a0, a1, pr)
  local n = math.max(2, math.floor(math.abs(a1 - a0) * r / 12))
  for k = 0, n - 1 do local t0, t1 = lerp(a0, a1, k / n), lerp(a0, a1, (k + 1) / n); seg(b, p, {x0 + r * math.cos(t0), y0 + r * math.sin(t0)}, {x0 + r * math.cos(t1), y0 + r * math.sin(t1)}, pr) end
end
for _, P in ipairs(PET) do
  seg(rd, LEAD, {cx + 140 * math.cos(P.a), cy + 140 * math.sin(P.a)}, {cx + 176 * math.cos(P.a), cy + 176 * math.sin(P.a)})
  local b = P.a + math.pi / 12
  seg(rd, LEAD, {cx + 94 * math.cos(b), cy + 94 * math.sin(b)}, {cx + 127 * math.cos(b), cy + 127 * math.sin(b)})
end
arc(fine, LEAD, cx - 30, cy - 8, 14, 0.15 * math.pi, 0.85 * math.pi)
arc(fine, LEAD, cx + 30, cy - 8, 14, 0.15 * math.pi, 0.85 * math.pi)
seg(fine, LEAD, {cx, cy - 6}, {cx - 5, cy + 20}); seg(fine, LEAD, {cx - 5, cy + 20}, {cx + 5, cy + 22})
arc(fine, LEAD, cx, cy + 22, 22, 0.25 * math.pi, 0.75 * math.pi)
for k = 0, 15 do local a = 2 * math.pi * k / 16; seg(fine, pile{{"Mars orange",1},{"cadmium yellow",0.4}}, {cx + 64 * math.cos(a), cy + 64 * math.sin(a)}, {cx + 86 * math.cos(a), cy + 86 * math.sin(a)}, {0.45, 0.15}) end
-- light bleeding over the leads nearest the Sun: small bright flecks
local FL = pile{{"zinc white",3},{"lemon chrome",0.4}}
local tip = brush{kind="round", width=2.6, point=0.5}
for k = 0, 47 do
  local a = 2 * math.pi * (k + 0.3) / 48
  for _, r in ipairs({92, 130, 138}) do
    if (k + r) % 3 ~= 0 then tip:reload(FL, 0.8); tip:touch(cx + r * math.cos(a), cy + r * math.sin(a), {pressure=rand(0.35, 0.7)}) end
  end
end
for _, P in ipairs(PET) do for k = 0, 2 do local a = lerp(P.a0, P.a1, (k + 0.5) / 3); tip:reload(FL, 0.7); tip:touch(cx + 176 * math.cos(a), cy + 176 * math.sin(a), {pressure=0.4}) end end
-- light thrown down and to the right: long slanted soft shapes
local LR = pile{{"cadmium red",1},{"rose madder",0.6},{"bone black",0.35}}
local LB = pile{{"ultramarine blue",1},{"cobalt blue",0.6},{"bone black",0.25},{"lead white",0.2}}
local LG = pile{{"Indian yellow",1},{"yellow ochre",0.6},{"bone black",0.25}}
local shafts = {
  {{{180,905},{240,900},{330,1000},{250,1000}}, LB}, {{{300,915},{360,912},{440,1000},{370,1000}}, LG},
  {{{420,925},{480,922},{560,1000},{490,1000}}, LR}, {{{540,930},{600,928},{680,1000},{610,1000}}, LB},
  {{{660,925},{715,922},{790,1000},{725,1000}}, LG}, {{{900,740},{940,720},{995,840},{960,860}}, LR},
  {{{20,700},{55,690},{95,800},{60,812}}, LB},
}
for i, s in ipairs(shafts) do
  local m = poly(s[1])
  work(m, {hand="body", tool="filbert 5", pile=s[2], coverage=2.2, fill=true, angle=0.85, edge="lost", length={20, 60}, seed=500 + i})
end
