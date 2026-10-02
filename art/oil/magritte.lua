-- easel session "magritte": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=0.8, linen={22,20}, seed=1954,
  ground={{pile={{"lead white",3},{"cerulean blue",0.2}}, um=80, apply="knife", texture=0.05}}}
-- H = 1250. Sky to y 640.
SKYM = rect(0, 0, 1000, 640)
local steps = {
  {{"lead white",1.6},{"cerulean blue",0.6},{"cobalt blue",0.25}},
  {{"lead white",1.9},{"cerulean blue",0.55},{"cobalt blue",0.15}},
  {{"lead white",2.3},{"cerulean blue",0.45},{"cobalt blue",0.08}},
  {{"lead white",2.7},{"cerulean blue",0.35}},
  {{"lead white",3},{"cerulean blue",0.25},{"yellow ochre",0.03}},
  {{"lead white",3},{"cerulean blue",0.18},{"yellow ochre",0.06}},
}
local h = 640 / #steps
for i, s in ipairs(steps) do
  work(rect(0, (i - 1) * h - 5, 1000, h + 10) * SKYM, {hand="broad", pile=pile(s), coverage=3, fill=true, clip=true, angle=0, load=0.9, ruler=true})
end
blend(SKYM, {angle=0})
blend(SKYM, {angle=math.pi/2})

--@ chunk 2
print(wait(3*1440))
local steps = {
  {{"cerulean blue",1},{"cobalt blue",0.5},{"lead white",0.8}},
  {{"cerulean blue",1},{"cobalt blue",0.35},{"lead white",1.1}},
  {{"cerulean blue",1},{"cobalt blue",0.2},{"lead white",1.5}},
  {{"cerulean blue",1},{"cobalt blue",0.1},{"lead white",2}},
  {{"cerulean blue",0.9},{"lead white",2.5}},
  {{"cerulean blue",0.7},{"lead white",2.9},{"yellow ochre",0.04}},
  {{"cerulean blue",0.55},{"lead white",3.2},{"yellow ochre",0.06}},
  {{"cerulean blue",0.45},{"lead white",3.4},{"yellow ochre",0.08}},
}
local h = 640 / #steps
for i, s in ipairs(steps) do
  work(rect(0, (i - 1) * h - 4, 1000, h + 8) * SKYM, {hand="broad", pile=pile(s), coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
end
blend(SKYM, {angle=0})
blend(SKYM, {angle=0.02})

--@ chunk 3
print(wait(2*1440))
local wht = pile{{"lead white",3},{"yellow ochre",0.03}}
local shd = pile{{"lead white",2.4},{"cerulean blue",0.2},{"bone black",0.12},{"cobalt violet",0.05}}
local function cloud(cx, cy, w, h, seed)
  local m = nil
  for i = 1, 7 do
    local x = cx + rand(-w * 0.45, w * 0.45); local y = cy + rand(-h * 0.25, h * 0.1)
    local e = ellipse(x, y, rand(w * 0.18, w * 0.3), rand(h * 0.35, h * 0.55))
    m = m and (m + e) or e
  end
  m = (m * above(function(x) return cy + h * 0.25 end)):soften(4)
  work(m, {hand="detail", tool="round 4", pile=wht, coverage=4.5, fill=true, load=1})
  local base = m * below(function(x) return cy end)
  work(base, {hand="detail", tool="round 4", pile=shd, coverage=3.5, fill=true, load=0.9})
  blend(m:grow(6), {angle=0, tool={kind="badger", width=16}})
end
cloud(230, 200, 260, 90); cloud(720, 120, 220, 70); cloud(560, 330, 300, 80); cloud(150, 440, 180, 55); cloud(860, 420, 160, 50)
print(wait(3*1440))
-- the spine: a thin straight bronze-grey rod crossing the blue, with small exact rings along it
local rod = pile{{"lead white",1.2},{"raw sienna",0.4},{"cerulean blue",0.3},{"bone black",0.2}}
local rodL = pile{{"lead white",2.4},{"yellow ochre",0.2}}
local b = brush{kind="round", width=4.5, point=0.2}
b:reload(rod, 1); b:stroke({{-10, 560}, {1010, 60}}, {pressure={0.8, 0.8}, ramps={0.01, 0.01}})
local l = brush{kind="round", width=1.3, point=0.4}
l:reload(rodL, 0.8); l:stroke({{-10, 558}, {1010, 58}}, {pressure={0.5, 0.5}, ramps={0.01, 0.01}})
for t = 0.08, 0.95, 0.11 do
  local x, y = lerp(-10, 1010, t), lerp(560, 60, t)
  local rb = brush{kind="round", width=3, point=0.2}
  rb:reload(rod, 0.9); rb:stroke({{x - 4, y - 8}, {x + 4, y + 8}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
end

--@ chunk 4
local rod = pile{{"lead white",1},{"raw sienna",0.45},{"cerulean blue",0.25},{"bone black",0.3}}
local rodL = pile{{"lead white",2.6},{"yellow ochre",0.2}}
local A, B = {0, 555}, {1000, 62}
for k = 0, 9 do
  local t0, t1 = k / 10, (k + 1) / 10 + 0.01
  local p0 = {lerp(A[1], B[1], t0), lerp(A[2], B[2], t0)}; local p1 = {lerp(A[1], B[1], t1), lerp(A[2], B[2], t1)}
  local b = brush{kind="round", width=5, point=0.2}; b:reload(rod, 1); b:stroke({p0, p1}, {pressure={0.8, 0.8}, ramps={0.01, 0.01}})
  local l = brush{kind="round", width=1.4, point=0.4}; l:reload(rodL, 0.8); l:stroke({{p0[1], p0[2] - 2}, {p1[1], p1[2] - 2}}, {pressure={0.5, 0.5}, ramps={0.01, 0.01}})
end
-- night: the ground, the house terrace and street in darkness
local night = pile{{"bone black",1.6},{"ultramarine blue",0.5},{"viridian",0.15},{"lead white",0.1}}
local tree = pile{{"bone black",1.8},{"viridian",0.4},{"ultramarine blue",0.3}}
TREEL = poly({{0, 640}, {0, 360}, {40, 330}, {90, 300}, {150, 310}, {200, 350}, {240, 410}, {250, 480}, {238, 560}, {220, 640}}, true)
TREER = poly({{1000, 640}, {1000, 330}, {960, 300}, {900, 290}, {840, 320}, {800, 380}, {770, 460}, {770, 560}, {790, 640}}, true)
work(rect(0, 600, 1000, 650), {hand="body", pile=night, coverage=3.5, fill=true, clip=true, angle=0, load=1})
work(TREEL + TREER, {hand="body", pile=tree, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
print(wait(4*1440))

--@ chunk 5
print(wait(2*1440))
local tree = pile{{"bone black",1.8},{"viridian",0.4},{"ultramarine blue",0.3}}
local roofP = pile{{"bone black",1.8},{"ultramarine blue",0.4},{"bone brown",0.3}}
local facade = pile{{"bone black",1.4},{"bone brown",0.6},{"raw sienna",0.25},{"ultramarine blue",0.2}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
-- restate the left tree over the spine, and ragged leafy edges on both
W(TREEL * rect(0, 300, 260, 270), tree)
for i = 1, 70 do
  local side = (i % 2 == 0)
  local a = rand(math.pi * 0.9, math.pi * 2.05)
  local cx, cy, rx, ry = side and 125 or 885, side and 420 or 410, side and 125 or 115, 120
  local x, y = cx + rx * math.cos(a), cy + ry * math.sin(a)
  if y < 600 then local b = brush{kind="round", width=rand(10, 18), point=0.05}; b:reload(tree, 0.9); b:touch(x, y, {pressure=0.75}) end
end
-- the terrace: three Testator houses, each with a low domed roof against the sky
HOUSES = {{235, 420}, {420, 600}, {600, 785}}
for _, h in ipairs(HOUSES) do
  local x0, x1 = h[1], h[2]; local cx = (x0 + x1) / 2
  W(ellipse(cx, 610, (x1 - x0) / 2, 70) * above(function(x) return 612 end), roofP)
  W(rect(cx - 8, 520, 16, 30) + ellipse(cx, 520, 9, 9), roofP)
end
W(rect(235, 605, 550, 380), facade)
print(wait(3*1440))
-- bone trim: eave lines and pilasters between the houses
local bone = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.55}}
local function st(p, pts, w) local b = brush{kind="round", width=w or 3, point=0.2}; b:reload(p, 0.85); b:stroke(pts, {pressure={0.7, 0.7}, ramps={0.01, 0.01}}) end
st(bone, {{235, 612}, {785, 612}}, 4)
for _, x in ipairs({238, 420, 600, 782}) do st(bone, {{x, 614}, {x, 982}}, 5) end
-- round doors with bone surrounds, and windows: all dark but two
local doorD = pile{{"bone black",2},{"bone brown",0.4}}
for _, h in ipairs(HOUSES) do
  local cx = (h[1] + h[2]) / 2
  W(ellipse(cx, 930, 38, 50) * above(function(x) return 982 end), bone)
  W(ellipse(cx, 930, 30, 42) * above(function(x) return 982 end), doorD)
  for _, wx in ipairs({cx - 50, cx + 50}) do
    W(rect(wx - 22, 680, 44, 70) + ellipse(wx, 680, 22, 20), bone)
  end
end
print(wait(2*1440))
local winD = pile{{"bone black",1.8},{"ultramarine blue",0.4}}
local glow = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.3}}
local lit = {[2] = true, [5] = true}
local k = 0
for _, h in ipairs(HOUSES) do
  local cx = (h[1] + h[2]) / 2
  for _, wx in ipairs({cx - 50, cx + 50}) do
    k = k + 1
    W(rect(wx - 17, 684, 34, 62) + ellipse(wx, 684, 17, 15), lit[k] and glow or winD, "round 2")
  end
end

--@ chunk 6
print(wait(3*1440))
local tree = pile{{"bone black",1.8},{"viridian",0.4},{"ultramarine blue",0.3}}
local doorD = pile{{"bone black",2},{"bone brown",0.4}}
local facadeL = pile{{"bone black",1},{"bone brown",0.6},{"raw sienna",0.45},{"lead white",0.25}}
local facadeL2 = pile{{"bone black",0.7},{"raw sienna",0.6},{"bone brown",0.4},{"lead white",0.45},{"yellow ochre",0.15}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
W(((TREEL:grow(34) + TREER:grow(34)) * rect(0, 250, 1000, 740)) - rect(235, 520, 550, 470) - ellipse(327, 610, 93, 70) - ellipse(510, 610, 90, 70) - ellipse(692, 610, 93, 70) - rect(318, 515, 400, 40), tree)
for _, h in ipairs(HOUSES) do local cx = (h[1] + h[2]) / 2; W(ellipse(cx, 930, 29, 41) * above(function(x) return 981 end), doorD) end
-- the lamp's light on the facade: two soft warm steps, blended while wet
local LX, LY = 700, 800
local ring1 = (ellipse(LX, LY + 20, 110, 120) - ellipse(LX, LY + 20, 60, 66)) * rect(240, 615, 540, 365)
local ring0 = ellipse(LX, LY + 20, 60, 66) * rect(240, 615, 540, 365)
local keepOut = (rect(668, 664, 64, 90) + ellipse(700, 684, 20, 18)) + ellipse(692, 930, 40, 52) + rect(595, 615, 10, 370) + rect(777, 615, 10, 370)
W(ring1 - keepOut, facadeL); W(ring0 - keepOut, facadeL2)
blend((ellipse(LX, LY + 20, 125, 135) * rect(240, 615, 540, 365)) - keepOut, {angle=0, tool={kind="badger", width=14}})
print(wait(3*1440))
-- the lamp-post, a bronze column with a lit globe
local bronze = pile{{"bone black",1.2},{"raw sienna",0.6},{"burnt sienna",0.3}}
local b = brush{kind="round", width=6, point=0.1}; b:reload(bronze, 1); b:stroke({{LX, 1070}, {LX, 800}}, {pressure={0.85, 0.85}, ramps={0.01, 0.01}})
W(rect(LX - 9, 1060, 18, 12), bronze, "round 2")
W(ellipse(LX, 784, 15, 17), pile{{"lead white",2.5},{"cadmium yellow",0.5},{"lemon chrome",0.2}}, "round 2")
local c = brush{kind="round", width=12, point=0.05}; c:reload(pile{{"lead white",3},{"lemon chrome",0.2}}, 1); c:touch(LX, 782, {pressure=0.8})
local cap = brush{kind="round", width=4, point=0.2}; cap:reload(bronze, 1); cap:stroke({{LX - 12, 766}, {LX, 760}, {LX + 12, 766}}, {pressure={0.8, 0.8}})
-- the street: a pavement edge, the wet road below with the lamp and the two windows reflected
local pave = pile{{"bone black",1.4},{"ultramarine blue",0.4},{"lead white",0.25},{"bone brown",0.2}}
W(rect(0, 985, 1000, 40), pave)
local refl = pile{{"cadmium yellow",1},{"lead white",0.8},{"Mars orange",0.3}}
for i = 1, 12 do
  local y = 1050 + i * 14; local w = 6 + i * 0.6
  local rb = brush{kind="round", width=3, point=0.3}; rb:reload(refl, 0.7 - i * 0.03)
  rb:stroke({{LX - w / 2 + rand(-3, 3), y}, {LX + w / 2 + rand(-3, 3), y}}, {pressure={0.6, 0.6}})
end
for _, x in ipairs({460, 692}) do for i = 1, 6 do local y = 1060 + i * 20; local rb = brush{kind="round", width=2.5, point=0.3}; rb:reload(refl, 0.45); rb:stroke({{x - 8, y}, {x + 8, y}}, {pressure={0.5, 0.5}}) end end

--@ chunk 7
print(wait(4*1440))
local tree = pile{{"bone black",1.8},{"viridian",0.4},{"ultramarine blue",0.3}}
local facade = pile{{"bone black",1.4},{"bone brown",0.6},{"raw sienna",0.25},{"ultramarine blue",0.2}}
local facadeM = pile{{"bone black",1.2},{"bone brown",0.6},{"raw sienna",0.35},{"lead white",0.1}}
local facadeL = pile{{"bone black",1},{"bone brown",0.6},{"raw sienna",0.45},{"lead white",0.22}}
local facadeL2 = pile{{"bone black",0.8},{"raw sienna",0.55},{"bone brown",0.45},{"lead white",0.35},{"yellow ochre",0.1}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
-- tree steps beside the domes
W((rect(235, 505, 50, 110) - ellipse(327, 610, 93, 70)) + (rect(735, 505, 52, 110) - ellipse(692, 610, 93, 70)), tree)
-- the glow: base, then three steps, all wet, blended together
local LX, LY = 700, 820
local F = rect(240, 616, 538, 366)
local keep = rect(616, 655, 52, 100) + rect(716, 655, 52, 100) + ellipse(692, 930, 40, 52) + rect(594, 614, 12, 370) + rect(775, 614, 12, 370) + rect(LX - 5, 795, 10, 280)
W((ellipse(LX, LY, 200, 190) * F) - keep, facade)
W((ellipse(LX, LY, 150, 145) * F) - keep, facadeM)
W((ellipse(LX, LY, 100, 98) * F) - keep, facadeL)
W((ellipse(LX, LY, 52, 52) * F) - keep, facadeL2)
blend((ellipse(LX, LY, 195, 185) * F) - keep, {angle=0, tool={kind="badger", width=24}})
blend((ellipse(LX, LY, 195, 185) * F) - keep, {angle=math.pi / 2, tool={kind="badger", width=24}})

--@ chunk 8
print(wait(3*1440))
local facade = pile{{"bone black",1.4},{"bone brown",0.6},{"raw sienna",0.25},{"ultramarine blue",0.2}}
local facadeM = pile{{"bone black",1.2},{"bone brown",0.6},{"raw sienna",0.35},{"lead white",0.1}}
local facadeL = pile{{"bone black",1},{"bone brown",0.6},{"raw sienna",0.45},{"lead white",0.22}}
local facadeL2 = pile{{"bone black",0.8},{"raw sienna",0.55},{"bone brown",0.45},{"lead white",0.35},{"yellow ochre",0.1}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local F = rect(236, 614, 550, 370)
local LX, LY = 700, 820
W(F - ellipse(LX, LY, 160, 150), facade)
W((ellipse(LX, LY, 160, 150) - ellipse(LX, LY, 105, 100)) * F, facadeM)
W((ellipse(LX, LY, 105, 100) - ellipse(LX, LY, 55, 55)) * F, facadeL)
W(ellipse(LX, LY, 55, 55) * F, facadeL2)
blend(F:shrink(2), {angle=0, tool={kind="badger", width=28}})
blend(ellipse(LX, LY, 190, 180) * F:shrink(2), {angle=math.pi / 2, tool={kind="badger", width=28}})
print(wait(4*1440))

--@ chunk 9
local bone = pile{{"lead white",1.2},{"yellow ochre",0.4},{"bone black",0.5}}
local doorD = pile{{"bone black",2},{"bone brown",0.4}}
local winD = pile{{"bone black",1.8},{"ultramarine blue",0.4}}
local glow = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.3}}
local bronze = pile{{"bone black",1.2},{"raw sienna",0.6},{"burnt sienna",0.3}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w) local b = brush{kind="round", width=w or 3, point=0.2}; b:reload(p, 0.9); b:stroke(pts, {pressure={0.75, 0.75}, ramps={0.01, 0.01}}) end
-- eave and pilasters, in segments so the brush never runs dry
for x = 236, 780, 60 do st(bone, {{x, 613}, {math.min(x + 62, 786), 613}}, 5) end
for _, x in ipairs({239, 420, 600, 783}) do for y = 614, 980, 70 do st(bone, {{x, y}, {x, math.min(y + 72, 982)}}, 6) end end
-- windows and doors
local k = 0
for _, h in ipairs(HOUSES) do
  local cx = (h[1] + h[2]) / 2
  W(ellipse(cx, 930, 38, 50) * above(function(x) return 982 end), bone)
  for _, wx in ipairs({cx - 50, cx + 50}) do W(rect(wx - 22, 680, 44, 70) + ellipse(wx, 680, 22, 20), bone) end
end
print(wait(3*1440))
local lit = {[2] = true, [5] = true}
for _, h in ipairs(HOUSES) do
  local cx = (h[1] + h[2]) / 2
  W(ellipse(cx, 930, 30, 42) * above(function(x) return 981 end), doorD)
  for _, wx in ipairs({cx - 50, cx + 50}) do k = k + 1; W(rect(wx - 17, 684, 34, 62) + ellipse(wx, 684, 17, 15), lit[k] and glow or winD) end
end
-- the lamp
local LX = 700
local b = brush{kind="round", width=6, point=0.1}; b:reload(bronze, 1); b:stroke({{LX, 1070}, {LX, 935}}, {pressure={0.85, 0.85}, ramps={0.01, 0.01}})
b:reload(bronze, 1); b:stroke({{LX, 940}, {LX, 800}}, {pressure={0.85, 0.85}, ramps={0.01, 0.01}})
W(rect(LX - 9, 1060, 18, 12), bronze)
W(ellipse(LX, 784, 15, 17), pile{{"lead white",2.5},{"cadmium yellow",0.5},{"lemon chrome",0.2}})
st(bronze, {{LX - 12, 766}, {LX, 760}, {LX + 12, 766}}, 4)
