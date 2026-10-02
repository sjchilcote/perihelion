-- easel session "bosch": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=0.75, linen={22,20}, seed=1510,
  ground={{pile={{"bone black",2},{"bone brown",0.6},{"ultramarine blue",0.3},{"lead white",0.12}}, um=80, apply="knife", texture=0.1}}}
-- H = 1333. Horizon at 330.
HZ = 330
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local sky = pile{{"bone black",2},{"ultramarine blue",0.5},{"cobalt violet",0.2}}
work(rect(0, 0, 1000, HZ - 60), {hand="broad", pile=sky, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
-- the violet fire-glow along the horizon, stepped warm-to-cold, blended wet
local g1 = pile{{"cobalt violet",1},{"bone black",0.8},{"ultramarine blue",0.3}}
local g2 = pile{{"cobalt violet",1},{"magenta",0.2},{"lead white",0.4},{"bone black",0.3}}
local g3 = pile{{"cobalt violet",0.8},{"lead white",1.3},{"magenta",0.15}}
work(rect(0, HZ - 70, 1000, 30), {hand="broad", pile=g1, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, HZ - 42, 1000, 26), {hand="broad", pile=g2, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, HZ - 18, 1000, 22), {hand="broad", pile=g3, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
blend(rect(0, HZ - 90, 1000, 96), {angle=0})
-- the land: dark umber, with an olive-dark middle plain and a dark pool around the tree-man's feet
local land = pile{{"bone black",1.6},{"bone brown",0.8},{"viridian",0.2},{"lead white",0.1}}
local mid = pile{{"bone black",1.2},{"bone brown",0.7},{"viridian",0.35},{"lead white",0.18}}
work(rect(0, HZ, 1000, 1010), {hand="broad", pile=land, coverage=3.5, fill=true, clip=true, angle=0, load=1})
POOL = ellipse(500, 880, 330, 90)
W(POOL, pile{{"bone black",1.2},{"ultramarine blue",0.6},{"viridian",0.3},{"lead white",0.3}})
work(rect(0, HZ + 4, 1000, 140), {hand="broad", pile=mid, coverage=3, fill=true, clip=true, angle=0, load=1, ruler=true})
print(wait(4*1440))

--@ chunk 2
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.6}, ramps={0.03, 0.1}}) end
local dk = pile{{"bone black",2},{"ultramarine blue",0.3}}
local vf = pile{{"cobalt violet",1},{"lead white",1.6},{"magenta",0.15}}
local vfw = pile{{"lead white",2.6},{"cobalt violet",0.4}}
local vfd = pile{{"cobalt violet",1},{"magenta",0.3},{"bone black",0.4},{"lead white",0.3}}
-- fires: tongues of cold violet licking up from the horizon, with smoke
for i = 1, 40 do
  local x = rand(0, 1000); local h = rand(30, 120); local y0 = HZ - 8
  local p = (math.random() < 0.3) and vfw or ((math.random() < 0.6) and vf or vfd)
  st(p, {{x, y0}, {x + rand(-8, 8), y0 - h * 0.5}, {x + rand(-14, 14), y0 - h}}, rand(4, 9), {0.8, 0.05})
end
for i = 1, 12 do
  local x = rand(0, 1000); local y = rand(120, 230)
  local b = brush{kind="filbert", width=rand(18, 30)}; b:reload(pile{{"cobalt violet",0.5},{"bone black",1},{"lead white",0.3}}, 0.4)
  b:stroke({{x, y + 30}, {x + rand(-20, 20), y}, {x + rand(-30, 30), y - 40}}, {pressure={0.4, 0.05}, ramps={0.3, 0.5}})
end
-- silhouettes of Testator architecture folding against the fire: arches bent over, a tower kinked, a dome inverted
W(poly({{40, HZ}, {44, 240}, {70, 210}, {96, 240}, {100, HZ}}) - ellipse(70, 280, 14, 24), dk)
W(poly({{130, HZ}, {136, 220}, {170, 200}, {190, 160}, {230, 140}, {236, 150}, {200, 176}, {184, 214}, {160, 236}, {160, HZ}}), dk)
W(poly({{780, HZ}, {790, 180}, {840, 160}, {860, 200}, {830, 210}, {820, 240}, {860, 260}, {870, HZ}}), dk)
W(ellipse(930, 280, 40, 26) * below(function(x) return 280 end) + rect(925, 300, 10, 30), dk)
W(poly({{300, HZ}, {320, 250}, {360, 230}, {390, 250}, {400, 290}, {380, 280}, {360, 258}, {330, 270}, {320, HZ}}), dk)
-- a spiral that eats itself: a ramp winding into a hole, far right
local sp = {} for k = 0, 40 do local a = k * 0.4; local r = 46 - k * 1.05; sp[#sp+1] = {660 + r * math.cos(a), 270 + r * 0.6 * math.sin(a)} end
st(dk, sp, 5, {0.8, 0.4})
print(wait(2*1440))
-- the tree-man: a hollow broken bronze station section as his body (an egg, broken open behind), standing in the pool on two hollow tube legs; a folded ring as the disc on his head
local bz = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.6},{"burnt sienna",0.15}}
local bzD = pile{{"burnt sienna",0.8},{"bone brown",0.6},{"raw sienna",0.4}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.4},{"raw sienna",0.06}}
local inner = pile{{"bone black",1.2},{"Mars red",0.4},{"cobalt violet",0.3},{"lead white",0.15}}
-- legs: two hollow pipes, splayed, standing in boats on the pool
W(poly({{430, 900}, {450, 900}, {470, 700}, {446, 700}}), bzD)
W(poly({{560, 900}, {582, 900}, {560, 700}, {536, 700}}), bzD)
st(bz, {{448, 702}, {432, 898}}, 3, {0.5, 0.5}); st(bz, {{538, 702}, {562, 898}}, 3, {0.5, 0.5})
W(poly({{400, 896}, {480, 896}, {470, 912}, {410, 912}}), bz); W(poly({{530, 896}, {612, 896}, {602, 912}, {540, 912}}), bz)
-- the body: an egg-shaped hull section, open at the back, with figures inside
TM = ellipse(500, 640, 110, 85)
W(TM, bz)
W(ellipse(530, 640, 72, 54), inner)
W(ellipse(500, 640, 110, 85) - ellipse(500, 640, 102, 77), bzD)
-- his head turned back over his shoulder, pale face, and the folded-ring disc as his hat
W(ellipse(388, 520, 34, 40), bone)
st(pile{{"bone black",2}}, {{376, 516}, {384, 517}}, 2); st(pile{{"bone black",2}}, {{392, 518}, {398, 519}}, 2)
st(bzD, {{378, 540}, {394, 540}}, 1.6)
W(ellipse(388, 474, 90, 22), bz)
W(ellipse(388, 474, 60, 13), bzD)

--@ chunk 3
print(wait(2*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.6}, ramps={0.03, 0.1}}) end
local bz = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.6},{"burnt sienna",0.15}}
local bzD = pile{{"burnt sienna",0.8},{"bone brown",0.6},{"raw sienna",0.4}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.4},{"raw sienna",0.06}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.3}}
local crew = pile{{"ultramarine blue",1},{"bone black",0.5},{"lead white",0.35}}
local skin = pile{{"lead white",1.8},{"yellow ochre",0.4},{"rose madder",0.1}}
local red = pile{{"vermilion",1},{"cadmium red",0.4}}
local vio = pile{{"cobalt violet",1},{"lead white",1.4},{"magenta",0.15}}
-- neck: a bent bronze conduit from the egg to the head
W(poly({{392, 556}, {412, 556}, {430, 580}, {418, 594}, {398, 572}}), bz)
-- a ladder up into the broken egg and figures inside it, sitting at a table
st(bzD, {{570, 760}, {540, 660}}, 2); st(bzD, {{586, 756}, {556, 656}}, 2)
for k = 1, 7 do local t = k / 8; st(bzD, {{lerp(570, 540, t), lerp(760, 660, t)}, {lerp(586, 556, t), lerp(756, 656, t)}}, 1.4) end
local function man(x, y, s, p) s = s or 1; st(p or crew, {{x, y - 7 * s}, {x, y}}, 2.4 * s, {0.75, 0.75}); local h = brush{kind="round", width=2.4 * s, point=0.05}; h:reload(skin, 0.9); h:touch(x, y - 9 * s, {pressure=0.7}) end
man(510, 660); man(530, 664); man(552, 656, 0.9); st(bone, {{500, 664}, {560, 662}}, 2)
man(560, 700, 0.9)
-- the pool: tiny figures wading, skating, and one in a floating disc
for k = 1, 9 do man(rand(220, 780), rand(850, 940), 1.1) end
W(ellipse(700, 900, 26, 7), bz); man(700, 898, 1.1)
-- a Warden: crested shell on many legs, carrying a captive in its blade-claws, walking left across the plain
local function warden(x, y, s, dir)
  for k = 0, 5 do local lx = x - 30 * s + k * 12 * s; st(dk, {{lx, y}, {lx + dir * 6 * s, y + 14 * s}, {lx + dir * 2 * s, y + 26 * s}}, 2.4 * s, {0.8, 0.5}) end
  W(ellipse(x, y - 4 * s, 38 * s, 22 * s) * above(function(xx) return y + 4 * s end), pile{{"bone black",1},{"raw sienna",0.6},{"viridian",0.35},{"lead white",0.2}})
  for k = 0, 6 do local a = math.pi * (0.15 + 0.7 * k / 6); local px, py = x + 36 * s * math.cos(a), y - 4 * s - 22 * s * math.sin(a); st(bone, {{px, py}, {px + 6 * s * math.cos(a), py - 8 * s * math.sin(a)}}, 2 * s, {0.75, 0.1}) end
  st(dk, {{x + dir * 36 * s, y - 6 * s}, {x + dir * 52 * s, y - 14 * s}, {x + dir * 60 * s, y - 2 * s}}, 3 * s, {0.8, 0.2})
end
warden(200, 760, 1, -1); man(140, 760, 1.1, crew)
warden(820, 1010, 1.4, 1)
-- scuttlers: small dark many-legged things, in a line, carrying a folded arch between them
for k = 0, 4 do
  local x, y = 260 + k * 34, 1080 + k * 6
  W(ellipse(x, y, 10, 6), dk)
  for j = -1, 1 do st(dk, {{x + j * 6, y + 3}, {x + j * 8, y + 10}}, 1.4) end
end
st(bz, {{250, 1062}, {280, 1040}, {330, 1036}, {380, 1070}}, 6, {0.8, 0.8})
-- the Shrieker-bell: a great inverted bell on legs, a figure trapped under it, its clapper a curled figure
W(poly({{620, 1180}, {650, 1100}, {700, 1084}, {750, 1100}, {780, 1180}}, true), bz)
W(ellipse(700, 1182, 82, 14), dk)
man(700, 1176, 1.2, red)
st(bzD, {{700, 1084}, {700, 1060}, {712, 1050}}, 4)
for _, x in ipairs({630, 670, 730, 770}) do st(dk, {{x, 1184}, {x + (x < 700 and -10 or 10), 1220}}, 2.6) end
-- folded Testator arch in the foreground left, twisted back on itself, with a crew member climbing it
st(bz, {{60, 1300}, {70, 1180}, {120, 1120}, {180, 1150}, {170, 1210}, {120, 1200}, {110, 1240}}, 14, {0.85, 0.85})
st(bzD, {{66, 1300}, {74, 1184}, {122, 1128}, {176, 1156}}, 3, {0.6, 0.6})
man(120, 1118, 1.2)
-- tiny cold violet lights: eyes in the dark, fires in the near ground
for k = 1, 30 do local b = brush{kind="round", width=2.2, point=0.05}; b:reload(vio, 0.85); b:touch(rand(20, 980), rand(360, 1300), {pressure=0.6}) end

--@ chunk 4
print(wait(2*1440))
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.6}, ramps={0.03, 0.1}}) end
local crew = pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.45}}
local pale = pile{{"lead white",2.2},{"yellow ochre",0.3},{"rose madder",0.12}}
local skin = pile{{"lead white",1.8},{"yellow ochre",0.4},{"rose madder",0.1}}
local red = pile{{"vermilion",1},{"cadmium red",0.4}}
local bzS = pile{{"burnt sienna",0.7},{"raw sienna",0.5},{"bone brown",0.4},{"lead white",0.2}}
local bzL = pile{{"lead white",1.8},{"yellow ochre",0.6}}
-- shade the egg-body: the right side turned away from the fire, a lit rim on the left
for k = 1, 10 do local a = rand(-1.1, 1.1); st(bzS, {{500 + 104 * math.cos(a) * 0.9, 640 + 80 * math.sin(a)}, {500 + 104 * math.cos(a) * 0.98, 640 + 82 * math.sin(a)}}, 10, {0.7, 0.7}) end
local rim = {} for k = 0, 12 do local a = math.pi * (0.62 + 0.75 * k / 12); rim[#rim+1] = {500 + 106 * math.cos(a), 640 + 81 * math.sin(a)} end
st(bzL, rim, 3, {0.6, 0.6})
-- crack edges round the opening
for k = 0, 10 do local a = k * 2 * math.pi / 10; local x, y = 530 + 72 * math.cos(a), 640 + 54 * math.sin(a); st(bzL, {{x, y}, {x + 8 * math.cos(a + 0.5), y + 8 * math.sin(a + 0.5)}}, 2, {0.7, 0.1}) end
-- people at a readable size: crew in navy and pale naked souls, as Bosch's
local function man(x, y, s, p) s = s or 2.2; st(p or crew, {{x, y - 8 * s}, {x, y}}, 2.6 * s, {0.8, 0.75}); local h = brush{kind="round", width=2.6 * s, point=0.05}; h:reload(skin, 0.95); h:touch(x, y - 10 * s, {pressure=0.75}); st(p or crew, {{x - 3 * s, y - 6 * s}, {x - 6 * s, y - 2 * s}}, 1.4 * s, {0.7, 0.4}) end
-- a procession across the plain toward the tree-man, led by a Warden
for k = 0, 7 do man(250 + k * 22 + rand(-4, 4), 790 + k * 2 + rand(-3, 3), 2, (k % 3 == 0) and crew or pale) end
-- in the pool: figures wading in a ring, one upside-down with legs in the air
for k = 0, 6 do local a = k * 2 * math.pi / 7; man(500 + 210 * math.cos(a), 900 + 26 * math.sin(a), 1.8, (k % 2 == 0) and pale or crew) end
st(pale, {{330, 870}, {326, 850}}, 4); st(pale, {{336, 870}, {342, 850}}, 4); W(ellipse(333, 874, 6, 3), skin)
-- on the hat-disc: two figures dancing round a bagpipe-like folded conduit
man(360, 466, 1.6, pale); man(416, 466, 1.6, crew)
st(bzS, {{380, 466}, {388, 440}, {402, 432}, {400, 452}}, 6, {0.8, 0.6})
-- carried away by scuttlers: a pale figure laid on the folded arch
st(pale, {{285, 1030}, {330, 1028}}, 5); W(ellipse(280, 1026, 5, 5), skin)
-- someone peering out from under the bell; one riding the far Warden
man(670, 1170, 1.6, pale); man(820, 980, 1.8, crew)
-- a woman-thing: a pale figure with a bronze plate for a head, walking a creature on a leash
man(900, 1250, 2.2, pale); W(ellipse(900, 1222, 10, 6), bzL)
st(pile{{"bone black",2}}, {{892, 1238}, {860, 1264}}, 1.2); local dk = pile{{"bone black",2},{"ultramarine blue",0.3}}
W(ellipse(850, 1266, 14, 8), dk); for j = -1, 1 do st(dk, {{850 + j * 8, 1270}, {852 + j * 10, 1282}}, 1.6) end
-- a red banner on a pole stuck in the pool
st(pile{{"bone brown",1},{"bone black",0.5}}, {{740, 930}, {744, 820}}, 2.4)
W(poly({{744, 822}, {786, 832}, {744, 846}}), red)

--@ chunk 5
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.6}, ramps={0.03, 0.1}}) end
local dkM = pile{{"bone black",1.4},{"bone brown",0.5},{"cobalt violet",0.2},{"lead white",0.15}}
local litV = pile{{"cobalt violet",1},{"lead white",1.6},{"magenta",0.15}}
local bz = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.5},{"burnt sienna",0.15}}
local pale = pile{{"lead white",2.2},{"yellow ochre",0.3},{"rose madder",0.12}}
-- the middle distance: a folded Testator town, buildings bending into each other, violet windows lit by the fires
local blds = {{60, 420, 40, 70, 0.25}, {120, 410, 50, 90, -0.2}, {600, 420, 60, 80, 0.3}, {680, 400, 40, 110, -0.35}, {740, 425, 70, 60, 0.15}, {880, 410, 50, 90, 0.4}}
for _, b in ipairs(blds) do
  local x, y, w, h, lean = b[1], b[2], b[3], b[4], b[5]
  local poly4 = poly({{x, y}, {x + w, y}, {x + w + lean * h, y - h}, {x + lean * h, y - h * 1.05}})
  W(poly4, dkM)
  for k = 1, 3 do local wx, wy = x + w * 0.3 + lean * h * k / 4, y - h * k / 4; local q = brush{kind="round", width=3, point=0.05}; q:reload(litV, 0.9); q:touch(wx, wy, {pressure=0.6}) end
end
-- a bridge folded into a loop, joining two of them
local lp = {} for k = 0, 30 do local a = math.pi + k * 2 * math.pi / 30 * 1.2; lp[#lp+1] = {700 + 40 * math.cos(a), 340 + 22 * math.sin(a) - k * 0.6} end
st(dkM, lp, 5, {0.8, 0.8})
-- a broken bronze ring stood on edge in the plain, with figures climbing through it
local ring = {} for k = 0, 34 do local a = math.rad(-60 + 300 * k / 34); ring[#ring+1] = {220 + 50 * math.cos(a), 400 + 50 * math.sin(a)} end
st(bz, ring, 8, {0.85, 0.85})
local function man(x, y, s, p) s = s or 1.8; st(p, {{x, y - 8 * s}, {x, y}}, 2.6 * s, {0.8, 0.75}); local h = brush{kind="round", width=2.6 * s, point=0.05}; h:reload(pale, 0.95); h:touch(x, y - 10 * s, {pressure=0.75}) end
man(210, 448, 1.6, pale); man(240, 420, 1.4, pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.45}})
-- a Shrieker's cry: three violet rings radiating from the bell
for r = 30, 90, 30 do local c = {} for k = 0, 20 do local a = math.rad(200 + 140 * k / 20); c[#c+1] = {700 + r * 1.3 * math.cos(a), 1120 + r * math.sin(a)} end; st(litV, c, 1.6, {0.5, 0.5}) end

--@ chunk 6
-- PASS 2, chunk A: thick glowing fires with dark smoke, their reflection in the pool; the egg-man modelled
local function st(p, pts, w, pr, kind) local b = brush{kind=kind or "filbert", width=w or 2}; b:reload(p, 0.9); b:stroke(pts, {pressure=pr or {0.8, 0.05}, ramps={0.05, 0.6}}) end
local smoke = pile{{"bone black",1.4},{"cobalt violet",0.25},{"lead white",0.25}}
local f1 = pile{{"cobalt violet",1},{"magenta",0.3},{"bone black",0.3},{"lead white",0.4}}
local f2 = pile{{"cobalt violet",1},{"lead white",1.6},{"magenta",0.15}}
local f3 = pile{{"lead white",3},{"cobalt violet",0.25},{"lemon chrome",0.05}}
-- smoke first, rising and leaning
for i = 1, 26 do
  local x = rand(0, 1000); local y = rand(150, 250)
  st(smoke, {{x, y + 40}, {x + rand(-10, 10), y}, {x + rand(10, 40), y - 50}, {x + rand(30, 70), y - 90}}, rand(20, 34), {0.55, 0.05})
end
-- flames: broad violet tongues, then paler cores, then white hearts
for i = 1, 55 do
  local x = rand(-10, 1010); local h = rand(50, 130); local y0 = HZ - 4
  st(f1, {{x, y0}, {x + rand(-10, 10), y0 - h * 0.5}, {x + rand(-18, 18), y0 - h}}, rand(14, 22))
end
for i = 1, 45 do
  local x = rand(-10, 1010); local h = rand(30, 90); local y0 = HZ - 4
  st(f2, {{x, y0}, {x + rand(-8, 8), y0 - h * 0.5}, {x + rand(-12, 12), y0 - h}}, rand(8, 14))
end
for i = 1, 30 do
  local x = rand(0, 1000); local h = rand(15, 50); local y0 = HZ - 3
  st(f3, {{x, y0}, {x + rand(-5, 5), y0 - h}}, rand(5, 9))
end
-- reflection of the fires in the pool: violet streaks along its far edge
for i = 1, 26 do
  local x = rand(200, 800); local y = rand(800, 840)
  if POOL:at(x, y) > 0.5 then st((math.random() < 0.5) and f2 or f1, {{x, y}, {x + rand(-2, 2), y + rand(14, 30)}}, rand(3, 6), {0.7, 0.1}) end
end
for i = 1, 14 do local x = rand(230, 770); local y = rand(800, 830); if POOL:at(x, y) > 0.5 then st(f3, {{x, y}, {x + rand(10, 20), y}}, 2.2, {0.6, 0.3}, "round") end end
-- the egg-man: a dark shadow crescent on the right, a pale highlight up on the left
local sh = pile{{"burnt sienna",0.7},{"bone brown",0.7},{"bone black",0.3}}
local hi = pile{{"lead white",2.4},{"yellow ochre",0.3}}
for k = 0, 14 do local a = -0.9 + 1.8 * k / 14; st(sh, {{500 + 96 * math.cos(a), 640 + 74 * math.sin(a)}, {500 + 104 * math.cos(a + 0.12), 640 + 80 * math.sin(a + 0.12)}}, 10, {0.8, 0.8}) end
st(hi, {{420, 612}, {432, 594}, {450, 582}}, 8, {0.7, 0.1})
st(hi, {{416, 640}, {418, 626}}, 5, {0.6, 0.1})
st(hi, {{372, 512}, {380, 504}}, 4, {0.6, 0.1})
st(sh, {{404, 520}, {408, 540}, {398, 556}}, 5, {0.6, 0.3})
print(wait(3*1440))

--@ chunk 7
-- PASS 2, chunk B: fill the dark field with small strange scenes, each a few crisp strokes
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 1.6", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 2, point=0.6}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.7, 0.6}, ramps={0.03, 0.1}}) end
local crew = pile{{"ultramarine blue",1},{"bone black",0.4},{"lead white",0.45}}
local pale = pile{{"lead white",2.2},{"yellow ochre",0.3},{"rose madder",0.12}}
local skin = pile{{"lead white",1.8},{"yellow ochre",0.4},{"rose madder",0.1}}
local red = pile{{"vermilion",1},{"cadmium red",0.4}}
local bz = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.5},{"burnt sienna",0.15}}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.45},{"raw sienna",0.06}}
local dk = pile{{"bone black",2},{"ultramarine blue",0.3}}
local shell = pile{{"bone black",1},{"raw sienna",0.6},{"viridian",0.35},{"lead white",0.2}}
local vio = pile{{"cobalt violet",1},{"lead white",1.6},{"magenta",0.15}}
local function man(x, y, s, p) s = s or 1.8; local q = p or ((math.random() < 0.5) and crew or pale); st(q, {{x, y - 8 * s}, {x, y}}, 2.6 * s, {0.8, 0.75}); local h = brush{kind="round", width=2.6 * s, point=0.05}; h:reload(skin, 0.95); h:touch(x, y - 10 * s, {pressure=0.75}) end
-- 1. a folded ladder climbed in a loop
local lc = {}; for k = 0, 40 do local a = k * 2 * math.pi / 40; lc[#lc+1] = {880 + 46 * math.cos(a), 650 + 62 * math.sin(a)} end
local li = {}; for k = 0, 40 do local a = k * 2 * math.pi / 40; li[#li+1] = {880 + 34 * math.cos(a), 650 + 50 * math.sin(a)} end
st(bz, lc, 2.4); st(bz, li, 2.4)
for k = 0, 19 do local a = k * 2 * math.pi / 20; st(bz, {{880 + 34 * math.cos(a), 650 + 50 * math.sin(a)}, {880 + 46 * math.cos(a), 650 + 62 * math.sin(a)}}, 1.4) end
man(880, 590, 1.4); man(934, 660, 1.4); man(870, 716, 1.4, pale); man(830, 640, 1.4)
-- 2. a docent playing a bone instrument while figures dance in a ring
W(poly({{452, 1210}, {462, 1150}, {474, 1144}, {486, 1150}, {494, 1210}}, true), pile{{"lead white",1.4},{"bone black",0.6},{"cerulean blue",0.2}})
W(ellipse(474, 1138, 8, 10), bone)
st(bone, {{466, 1130}, {474, 1118}, {482, 1130}}, 2)
st(bone, {{494, 1150}, {520, 1120}, {528, 1150}, {500, 1176}}, 3)
for k = 1, 4 do st(bone, {{504 + k * 4, 1134 + k * 2}, {504 + k * 4, 1160 - k * 2}}, 1) end
for k = 0, 5 do local a = k * 2 * math.pi / 6 + 0.3; man(474 + 60 * math.cos(a), 1220 + 16 * math.sin(a), 1.5) end
-- 3. a Warden balancing a dome on its back
W(ellipse(110, 660, 30, 16) * above(function(x) return 666 end), shell)
for k = 0, 4 do local lx = 86 + k * 12; st(dk, {{lx, 664}, {lx - 4, 676}, {lx - 2, 688}}, 2.2) end
W(ellipse(110, 636, 22, 18) * above(function(x) return 640 end), bz)
st(bz, {{88, 640}, {132, 640}}, 2.4); st(bone, {{110, 618}, {110, 608}}, 2)
-- 4. a procession, each figure carrying a smaller copy of himself on his head, and that one a smaller still
for k = 0, 6 do
  local x, y = 300 + k * 36, 1300 - k * 3
  man(x, y, 1.8); man(x, y - 21, 1.0); man(x, y - 33, 0.55)
end
-- 5. figures inside a glowing violet fold
W(poly({{820, 1120}, {900, 1090}, {960, 1130}, {930, 1200}, {850, 1190}}, true), vio)
W(poly({{840, 1140}, {900, 1110}, {940, 1140}, {920, 1180}, {860, 1176}}, true), pile{{"cobalt violet",1},{"lead white",2.4}})
for _, p in ipairs({{870, 1170}, {890, 1160}, {912, 1170}, {900, 1140}}) do man(p[1], p[2], 1.2, dk) end
st(dk, {{820, 1120}, {900, 1090}, {960, 1130}}, 2)
-- 6. a group round a small violet fire on the upper plain; figures tumbling into a hole beside it
W(ellipse(420, 420, 10, 4), vio); st(vio, {{420, 418}, {422, 396}}, 4, {0.8, 0.05})
for k = 0, 4 do local a = k * 2 * math.pi / 5; man(420 + 32 * math.cos(a), 424 + 8 * math.sin(a), 1.3) end
W(ellipse(560, 440, 24, 7), dk)
st(pale, {{554, 432}, {548, 420}}, 3.5); st(pale, {{566, 434}, {574, 424}}, 3.5); W(ellipse(570, 438, 4, 3), skin)
-- 7. winged things in the smoke, carrying figures
for _, b in ipairs({{300, 120}, {640, 90}, {860, 140}}) do
  st(dk, {{b[1] - 18, b[2] - 6}, {b[1], b[2]}, {b[1] + 18, b[2] - 6}}, 3, {0.8, 0.8})
  man(b[1], b[2] + 18, 1.0, pale)
end
-- 8. a pale figure riding a giant fish across the plain, far right
W(ellipse(900, 470, 34, 11), shell); W(poly({{930, 470}, {948, 460}, {948, 480}}), shell); man(895, 460, 1.4, pale)
-- 9. scattered small acts across the dark: pairs, a figure in a barrel, a kneeling one, a spinning plate on a pole
for _, s in ipairs({{180, 900}, {640, 760}, {600, 990}, {120, 1010}, {380, 980}, {970, 900}, {700, 1270}, {960, 1290}}) do man(s[1], s[2], 1.5); man(s[1] + 14, s[2] + 2, 1.4) end
W(poly({{240, 1110}, {262, 1110}, {264, 1140}, {238, 1140}}, true), bz); man(251, 1112, 1.2, pale)
st(dk, {{560, 1060}, {560, 1010}}, 1.6); W(ellipse(560, 1008, 16, 4), bz); man(574, 1068, 1.3, red)
for k = 1, 30 do local b = brush{kind="round", width=2.2, point=0.05}; b:reload(vio, 0.85); b:touch(rand(20, 980), rand(360, 1300), {pressure=0.6}) end
