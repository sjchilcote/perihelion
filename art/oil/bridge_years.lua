-- easel session "bridge_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={18,16}, seed=4343,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.5},{"lead white",0.5}}, um=110, apply="knife", texture=0.4}}}
-- a wide concave viewport wrapping the bridge: its top edge sags toward the middle, its sill rises
function VTOP(x) local u = (x - 520) / 560; return 58 + 56 * (1 - u * u) end
function VBOT(x) local u = (x - 520) / 560; return 352 - 40 * (1 - u * u) end
VIEW = below(VTOP) * above(VBOT) * rect(150, 0, 850, 600)
FRAMEO = below(function(x) return VTOP(x) - 14 end) * above(function(x) return VBOT(x) + 16 end) * rect(136, 0, 864, 600)
FRAME = FRAMEO - VIEW
CEILM = above(function(x) return VTOP(x) - 14 end) * rect(0, 0, 1000, 600)
FLOORM = below(function(x) return VBOT(x) + 16 end)
DOOR = rect(30, 150, 92, 300)
LWALLM = rect(0, 0, 150, 600) - CEILM - FLOORM
-- the TESTAMENT in the window: its hull a huge disc-like limb; space only in the upper-left corner
HULL = VIEW * mask(function(x, y) local dx, dy = x - 980, y - 780; return (dx * dx + dy * dy < 980 * 980) and 1 or 0 end)
SPACE = VIEW - HULL
print(W, H, HULL:area(), SPACE:area(), VIEW:area())

--@ chunk 2
-- value structure: the dead room near-black and cold, lean; through the glass the hull in four warm bands, darker away from the sun
local dark = pile{{"bone black",1.6},{"bone brown",0.6},{"burnt sienna",0.4},{"lead white",0.1}, medium=0.06}
local dark2 = pile{{"bone black",1.4},{"bone brown",0.6},{"raw sienna",0.3},{"lead white",0.15}, medium=0.06}
work(CEILM, {hand="body", tool="filbert 12", pile=dark, coverage=4, fill=true, clip=CEILM, angle=0, load=1})
work(FLOORM, {hand="body", tool="filbert 12", pile=dark2, coverage=4, fill=true, clip=FLOORM, angle=0, load=1})
work(LWALLM, {hand="body", tool="filbert 10", pile=dark, coverage=4, fill=true, clip=LWALLM, angle=math.pi/2, load=1})
work(FRAME, {hand="body", tool="filbert 6", pile=pile{{"bone black",2},{"ultramarine ash",0.5}, medium=0.06}, coverage=5, fill=true, clip=FRAME, angle=0, load=1})
work(SPACE, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"ultramarine blue",0.6}, medium=0.06}, coverage=5, fill=true, clip=SPACE, angle=0, load=1})
local bands = {
  {0, 360, pile{{"bone black",1.2},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}},
  {360, 560, pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6}, medium=0.06}},
  {560, 770, pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.15}, medium=0.06}},
  {770, 1000, pile{{"yellow ochre",1.3},{"raw sienna",0.6},{"lead white",0.6},{"Mars orange",0.2}, medium=0.06}},
}
for _, b in ipairs(bands) do
  local m = HULL * rect(b[1], 0, b[2] - b[1], 600)
  work(m, {hand="body", tool="filbert 6", pile=b[3], coverage=4, fill=true, clip=m, angle=0.35, load=1})
end
for _, x in ipairs{360, 560, 770} do blend(HULL * rect(x - 14, 0, 28, 600), {angle=math.pi/2}) end

--@ chunk 3
-- the hull's scale-plates in rows concentric with its limb: a shadowed lip under each plate, a lit edge on its sunward upper rim;
-- then the ring's curve crossing in front
print(wait(3*24*60))
local CX, CY = 980, 780
local shD = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local litM = pile{{"yellow ochre",1.2},{"raw sienna",0.6},{"lead white",0.4}, medium=0.06}
local litH = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.05}
local n = 0
local row = 0
for r = 960, 520, -24 do
  row = row + 1
  local step = 24 / r
  local off = (row % 2) * 0.5 * step
  for a = math.pi + 0.05 + off, 1.5 * math.pi + 0.6, step do
    local x, y = CX + r * math.cos(a), CY + r * math.sin(a)
    if HULL:at(x, y) > 0.5 then
      local light = clamp((x - 250) / 700, 0, 1)
      local pts, lp = {}, {}
      for j = -2, 2 do
        local aa = a + j * step * 0.22
        pts[#pts+1] = {CX + (r - 3) * math.cos(aa), CY + (r - 3) * math.sin(aa)}
        lp[#lp+1] = {CX + (r + 8) * math.cos(aa), CY + (r + 8) * math.sin(aa)}
      end
      local b = brush{kind="round", width=3.2, point=0.2}
      b:load(shD, 0.8); b:stroke(pts, {pressure={0.4, 0.75}, swell={0.5, 1, 0.5}, clip=HULL})
      if light > 0.15 then
        local lb = brush{kind="round", width=1.3, point=0.5}
        lb:load((light > 0.7) and litH or litM, 0.7)
        lb:stroke(lp, {pressure={0.1, 0.3 + 0.5 * light}, swell={0.3, 1, 0.3}, clip=HULL})
      end
      n = n + 1
    end
  end
end
print("plates", n)
-- the ring: a great band arcing across the window in front of the hull, lit on its upper edge toward the right
local ring = {}
for j = 0, 40 do local t = j / 40; local a = math.pi * (1.05 + 0.9 * t); ring[#ring+1] = {560 + 760 * math.cos(a), 560 + 420 * math.sin(a)} end
RINGM = ribbon(ring, 26) * VIEW
work(RINGM, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"raw sienna",0.3}, medium=0.06}, coverage=5, fill=true, clip=RINGM, angle=0, load=1})
local top = {}
for _, p in ipairs(ring) do top[#top+1] = {p[1], p[2] - 11} end
local rb = brush{kind="round", width=3, point=0.3}
rb:load(litH, 0.9); rb:stroke(top, {pressure={0.05, 0.9}, clip=VIEW})

--@ chunk 4
-- the plates too small for "huge and close", and the band steps show: lay big plates over the whole hull, each a filbert body
-- in a bronze picked by its light (rows concentric with the limb, offset like scales), the ring left alone
print(wait(2*24*60))
local CX, CY = 980, 780
local P4 = {
  pile{{"bone black",1.2},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06},
  pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6}, medium=0.06},
  pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.15}, medium=0.06},
  pile{{"yellow ochre",1.3},{"raw sienna",0.6},{"lead white",0.6},{"Mars orange",0.2}, medium=0.06},
  pile{{"yellow ochre",1.2},{"lead white",1},{"Mars orange",0.2}, medium=0.06},
}
local H = HULL - RINGM:grow(1)
PL = {}
local row = 0
for r = 980, 470, -44 do
  row = row + 1
  local step = 46 / r
  local off = (row % 2) * 0.5 * step
  for a = math.pi - 0.05 + off, 1.5 * math.pi + 0.7, step do
    local x, y = CX + r * math.cos(a), CY + r * math.sin(a)
    if HULL:at(x, y) > 0.3 then
      local light = clamp((x - 200) / 760, 0, 1) + 0.12 * math.sin(row * 2.3 + a * 17)
      local lvl = clamp(math.floor(light * 5) + 1, 1, 5)
      local b = brush{kind="filbert", width=50, stiffness=0.5}
      b:load(P4[lvl], 0.9)
      local nx, ny = math.cos(a), math.sin(a)
      b:stroke({{x - nx * 20, y - ny * 20}, {x + nx * 12, y + ny * 12}}, {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=H})
      PL[#PL+1] = {x=x, y=y, a=a, r=r, light=light}
    end
  end
end
print(#PL)

--@ chunk 5
-- on set paint: each plate's shadowed lip on its outer edge and a lit rim inside it, so the blobs read as overlapping scales
print(wait(4*24*60))
local CX, CY = 980, 780
local H = HULL - RINGM:grow(1)
local sh = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local litM = pile{{"yellow ochre",1.2},{"raw sienna",0.5},{"lead white",0.5}, medium=0.06}
local litH = pile{{"lead white",2},{"yellow ochre",0.7},{"cadmium yellow",0.2}, medium=0.05}
for _, p in ipairs(PL) do
  local R = 25
  local ox, oy = p.x + math.cos(p.a) * 6, p.y + math.sin(p.a) * 6
  local pts, lp = {}, {}
  for k = -3, 3 do
    local aa = p.a + k * 0.32
    pts[#pts+1] = {ox + math.cos(aa) * R, oy + math.sin(aa) * R}
    lp[#lp+1] = {ox + math.cos(aa) * (R - 4), oy + math.sin(aa) * (R - 4)}
  end
  local b = brush{kind="round", width=5, point=0.2}
  b:load(sh, 0.85); b:stroke(pts, {pressure={0.5, 0.85}, swell={0.5, 1, 0.5}, clip=H})
  if p.light > 0.25 then
    local lb = brush{kind="round", width=1.8, point=0.5}
    lb:load((p.light > 0.75) and litH or litM, 0.75)
    -- the rim faces the sun on the right: only the right half of the arc
    local half = {lp[4], lp[5], lp[6], lp[7]}
    lb:stroke(half, {pressure={0.2, 0.3 + 0.6 * clamp(p.light, 0, 1)}, swell={0.4, 1, 0.4}, clip=H})
  end
end
-- the ring's own plates: a few dark joints and its lit top restated
local ring = {}
for j = 0, 40 do local t = j / 40; local a = math.pi * (1.05 + 0.9 * t); ring[#ring+1] = {560 + 760 * math.cos(a), 560 + 420 * math.sin(a)} end
for j = 3, 39, 4 do
  local p, q = ring[j], ring[j + 1]
  local b = brush{kind="round", width=2}
  b:load(sh, 0.9); b:stroke({{p[1], p[2] - 12}, {p[1] + 1, p[2] + 12}}, {pressure={0.8, 0.8}, clip=RINGM})
end

--@ chunk 6
-- the room's things, dark: consoles under the sill, five crew chairs backed to us against the window, the doorway and the Commando in it
local dk = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}, medium=0.06}
local dk2 = pile{{"bone black",1.8},{"ultramarine ash",0.6},{"burnt sienna",0.3},{"lead white",0.08}, medium=0.06}
CONS = below(function(x) return VBOT(x) + 16 end) * above(function(x) return VBOT(x) + 62 end) * rect(150, 0, 850, 600)
work(CONS, {hand="body", tool="filbert 6", pile=dk2, coverage=5, fill=true, clip=CONS, angle=0, load=1})
-- console screens: dead dark glass panels in the console face, one with the amber standby (lit later)
SCREENS = {}
for i, x in ipairs{200, 330, 470, 610, 750, 890} do
  local y = VBOT(x) + 26
  local m = rect(x, y, 70, 22)
  work(m, {hand="detail", pile=pile{{"bone black",2},{"ultramarine ash",0.5},{"viridian",0.08}, medium=0.06}, coverage=5, fill=true, clip=m, load=1})
  SCREENS[i] = {x=x, y=y}
end
-- the chairs, far row: tall backs with headrests, pedestals, seen from behind
CHAIRS = {}
CHM = nil
for i, c in ipairs{{250, 1.0}, {395, 1.05}, {545, 1.1}, {700, 1.05}, {855, 1.0}} do
  local x, s = c[1], c[2]
  local base = 500
  local back = poly({{x - 42 * s, 360}, {x + 42 * s, 360}, {x + 38 * s, 455}, {x - 38 * s, 455}}, true)
  local head = poly({{x - 24 * s, 318}, {x + 24 * s, 318}, {x + 26 * s, 360}, {x - 26 * s, 360}}, true)
  local ped = ribbon({{x, 455}, {x, base}}, 12) + poly({{x - 40, base - 4}, {x + 40, base - 4}, {x + 44, base + 6}, {x - 44, base + 6}})
  local arms = ribbon({{x - 50 * s, 430}, {x - 46 * s, 452}}, 9) + ribbon({{x + 50 * s, 430}, {x + 46 * s, 452}}, 9)
  local m = back + head + ped + arms
  work(m, {hand="body", tool="filbert 4", pile=dk, coverage=6, fill=true, clip=m, angle=math.pi/2, load=1})
  CHAIRS[i] = {x=x, s=s, back=back, head=head, m=m}
  CHM = CHM and (CHM + m) or m
end
-- the doorway: open, warm light beyond (someone lives here)
local door = poly({{38, 160}, {122, 152}, {122, 452}, {38, 470}})
work(door, {hand="body", tool="filbert 4", pile=pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"bone black",0.15}, medium=0.06}, coverage=5, fill=true, clip=door, angle=math.pi/2, load=1})
FIG = rect(-20, -20, 2, 2)

--@ chunk 7
-- on set paint: the doorway dimmer and the Commando restated dark in it; the sun pouring through the window as long warm stripes
-- across the floor toward the lower left, the chairs' shadows cut out of them; warm edges on the chairs' sunward sides
print(wait(4*24*60))

-- shafts on the floor: parallelograms from under the window toward the lower left
local FLO = FLOORM - CONS - CHM - FIG - rect(0, 0, 150, 600)
local s1 = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.55},{"yellow ochre",0.3}, medium=0.06}
local s2 = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.45},{"burnt sienna",0.2}, medium=0.06}
SHAFTS = nil
for i, sx in ipairs{330, 470, 620, 770, 930} do
  local w = 46 + 10 * math.sin(i * 1.7)
  local m = poly({{sx, 410}, {sx + w, 410}, {sx + w - 330, 563}, {sx - 300, 563}})
  -- each chair throws its shadow into the stripe behind it, down-left
  local cs = nil
  for _, c in ipairs(CHAIRS) do
    local sh = poly({{c.x - 45, 455}, {c.x + 45, 455}, {c.x - 70, 563}, {c.x - 190, 563}})
    cs = cs and (cs + sh) or sh
  end
  m = m * FLO - cs
  SHAFTS = SHAFTS and (SHAFTS + m) or m
  work(m, {hand="body", tool="filbert 6", pile=s1, coverage=5, fill=true, clip=m, angle=2.66, load=1})
  local core = poly({{sx + w * 0.2, 410}, {sx + w * 0.8, 410}, {sx + w * 0.8 - 330, 563}, {sx + w * 0.2 - 300, 563}}) * m
  work(core, {hand="body", tool="filbert 5", pile=s2, coverage=5, fill=true, clip=core, angle=2.66, load=1})
end
blend(SHAFTS:grow(3) - SHAFTS:shrink(3) - CHM - CONS - FIG, {angle=2.66})
-- warm edges on the chairs, right side and headrest top; and along the console's top lip
local rim = pile{{"yellow ochre",1.2},{"lead white",0.8},{"Mars orange",0.2}, medium=0.06}
for _, c in ipairs(CHAIRS) do
  local b = brush{kind="round", width=1.8, point=0.5}
  b:load(rim, 0.85); b:stroke({{c.x + 25 * c.s, 320}, {c.x + 27 * c.s, 345}, {c.x + 41 * c.s, 368}, {c.x + 40 * c.s, 440}}, {pressure={0.8, 0.2}, clip=c.m:grow(1)})
  b:load(rim, 0.85); b:stroke({{c.x - 18 * c.s, 319}, {c.x + 22 * c.s, 319}}, {pressure={0.4, 0.8}, clip=c.m:grow(1)})
end
local lip = {}
for x = 150, 1000, 25 do lip[#lip+1] = {x, VBOT(x) + 18} end
local lb = brush{kind="round", width=2, point=0.4}
lb:load(rim, 0.9); lb:stroke(lip, {pressure={0.15, 0.8}, clip=CONS:grow(2) - CHM})

--@ chunk 8
-- the shafts came out as scraps: the whole floor in front of the console laid warm in long stripes running down-left,
-- graded brighter near the window; the chairs' shadows go on next, once this has set. The doorway darker (ultramarine ash
-- is a pale pigment: use blue), the figure restated smooth
print(wait(1*24*60))
local FLO = FLOORM - CONS - CHM - FIG - rect(0, 0, 150, 600)
local warmD = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.7},{"yellow ochre",0.2}, medium=0.06}
local warmM = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.35}, medium=0.06}
local warmL = pile{{"yellow ochre",1.2},{"lead white",0.8},{"raw sienna",0.3}, medium=0.06}
local near = poly({{150, 395}, {1000, 395}, {1000, 450}, {150, 470}}) * FLO
local mid = poly({{150, 470}, {1000, 450}, {1000, 510}, {150, 520}}) * FLO
local far = poly({{150, 520}, {1000, 510}, {1000, 563}, {150, 563}}) * FLO
work(near, {hand="body", tool="filbert 6", pile=warmL, coverage=5, fill=true, clip=near, angle=2.66, load=1})
work(mid, {hand="body", tool="filbert 7", pile=warmM, coverage=5, fill=true, clip=mid, angle=2.66, load=1})
work(far, {hand="body", tool="filbert 8", pile=warmD, coverage=5, fill=true, clip=far, angle=2.66, load=1})
blend(FLO * rect(150, 462, 850, 16), {angle=2.66}); blend(FLO * rect(150, 508, 850, 18), {angle=2.66})

--@ chunk 9
-- the lit floor is one hard box: cut it into shafts. Window mullions; their shadows and the chairs' long shadows laid dark
-- across the floor down-left; the light extended past the window's left end along the rays
print(wait(3*24*60))
local warmM = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.35}, medium=0.06}
local wedge = poly({{150, 400}, {150, 563}, {-200, 563}}) * FLOORM - FIG - rect(0, 0, 40, 600)
work(wedge, {hand="body", tool="filbert 6", pile=warmM, coverage=5, fill=true, clip=wedge, angle=2.66, load=1})
-- mullions on the window
local mul = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
MULL = nil
for _, x in ipairs{330, 525, 720, 905} do
  local m = poly({{x - 6, VTOP(x) - 2}, {x + 6, VTOP(x) - 2}, {x + 6, VBOT(x) + 2}, {x - 6, VBOT(x) + 2}})
  MULL = MULL and (MULL + m) or m
end
work(MULL, {hand="detail", pile=mul, coverage=6, fill=true, clip=MULL, load=1})
-- the shadows: lean opaque darks
local shd = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
local dx = -2.16
local SH = nil
local function band(x0, w, y0)
  return poly({{x0, y0}, {x0 + w, y0}, {x0 + w + dx * (563 - y0), 563}, {x0 + dx * (563 - y0), 563}})
end
for _, x in ipairs{330, 525, 720, 905} do local m = band(x - 30, 60, 398); SH = SH and (SH + m) or m end
for _, c in ipairs(CHAIRS) do local m = band(c.x - 45, 90, 455); SH = SH + m end
SH = SH * FLOORM - CONS - CHM - FIG
work(SH, {hand="body", tool="filbert 6", pile=shd, coverage=6, fill=true, clip=SH, angle=2.66, load=1})
SHADOWS = SH

--@ chunk 10
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0, load=1}) end
-- the consoles lit: every screen glowing, warm and green, with lines of readout
local SG = {pile{{"emerald green",0.5},{"viridian",0.4},{"lead white",1},{"bone black",0.15}}, pile{{"cadmium yellow",0.6},{"Mars orange",0.4},{"lead white",0.8}}, pile{{"cerulean blue",0.6},{"lead white",1.1},{"bone black",0.1}}}
local LN = pile{{"lead white",2},{"lemon chrome",0.1}}
for i, s in ipairs(SCREENS) do
  local m = rect(s.x, s.y, 70, 22)
  fill(m, SG[(i % 3) + 1])
  for row = 0, 2 do
    local x = s.x + 5
    while x < s.x + 62 do local L = rand(4, 14) local b = brush{kind="rigger", width=0.9, point=1} b:load(LN, 0.85) b:stroke({{x, s.y + 5 + row*6}, {x + L, s.y + 5 + row*6}}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}, clip=m}) x = x + L + rand(3, 6) end
  end
end
-- small status lights along the console lip
local LT = {pile{{"cadmium yellow",1},{"lead white",0.6}}, pile{{"emerald green",1},{"lead white",0.6}}, pile{{"vermilion",1},{"lead white",0.4}}}
local d = brush{kind="round", width=2.2, point=0.4}
for x = 170, 990, 22 do local y = VBOT(x) + 54 if CHM:at(clamp(x,0,999), clamp(y,0,562)) < 0.1 and rand(0,1) < 0.6 then d:load(LT[math.random(1, 3)], 0.95) d:touch(x, y, {pressure=0.5}) end end

--@ chunk 11
print(wait(5*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0, load=1}) end
local function L(p, pts, pr, w) local b = brush{kind="rigger", width=w or 1.2, point=1} b:load(p, 0.9) b:stroke(pts, {pressure={pr, pr}, ramps={0.03, 0.03}}) end
-- chair 1: a child's red jacket slung over the back
local c = CHAIRS[1]
local jk = poly({{c.x - 40, 362}, {c.x + 30, 356}, {c.x + 34, 384}, {c.x + 20, 420}, {c.x - 4, 430}, {c.x - 30, 424}, {c.x - 44, 396}}, true)
fill(jk, pile{{"cadmium red",0.8},{"Mars red",0.4},{"bone black",0.35}})
L(pile{{"Mars red",0.6},{"bone black",0.8}}, {{c.x - 10, 364}, {c.x - 6, 426}}, 0.6, 1.6)
L(pile{{"cadmium red",0.6},{"lead white",0.5}}, {{c.x + 30, 358}, {c.x + 34, 384}, {c.x + 20, 418}}, 0.5, 1.2)
L(pile{{"lead white",1.6},{"cadmium yellow",0.2}}, {{c.x - 30, 396}, {c.x + 22, 392}}, 0.5, 1.6)
-- chair 2: a docent's folded bone tablet leaning on the seat-back, inscribed
c = CHAIRS[2]
local tab = poly({{c.x - 24, 380}, {c.x + 20, 376}, {c.x + 22, 432}, {c.x - 22, 436}})
fill(tab, pile{{"lead white",1.3},{"yellow ochre",0.35},{"raw sienna",0.12},{"bone black",0.12}})
for row = 0, 6 do L(pile{{"bone brown",1},{"bone black",0.8}}, {{c.x - 18, 386 + row*6.5}, {c.x + rand(4, 16), 385.5 + row*6.5}}, 0.5, 0.8) end
L(pile{{"bone brown",1},{"bone black",0.6}}, {{c.x - 22, 406}, {c.x + 21, 403}}, 0.6, 1.1)
-- chair 3: a crayon box, open, crayons fanned
c = CHAIRS[3]
local box = poly({{c.x - 26, 408}, {c.x + 26, 404}, {c.x + 28, 432}, {c.x - 24, 436}})
fill(box, pile{{"cadmium yellow",1},{"emerald green",0.2},{"lead white",0.3}})
fill(poly({{c.x - 20, 412}, {c.x + 20, 409}, {c.x + 21, 416}, {c.x - 19, 419}}), pile{{"emerald green",0.8},{"lead white",0.3}}, "round 0.8")
local CRS = {pile{{"vermilion",1}}, pile{{"cobalt blue",1},{"lead white",0.2}}, pile{{"emerald green",1}}, pile{{"cadmium yellow",1}}, pile{{"cobalt violet",1},{"lead white",0.2}}, pile{{"Mars orange",1}}, pile{{"rose madder",1},{"lead white",0.2}}}
for i = 0, 6 do local x = c.x - 20 + i*6.5 L(CRS[i + 1], {{x, 406}, {x + (i - 3)*1.6, 390}}, 0.8, 2.4) end
-- chair 4: the chief's clipboard
c = CHAIRS[4]
local cb = poly({{c.x - 22, 388}, {c.x + 22, 386}, {c.x + 24, 440}, {c.x - 20, 442}})
fill(cb, pile{{"bone brown",1},{"raw sienna",0.6},{"lead white",0.2}})
fill(poly({{c.x - 16, 396}, {c.x + 17, 394}, {c.x + 18, 436}, {c.x - 15, 437}}), pile{{"lead white",2},{"yellow ochre",0.08}})
fill(rect(c.x - 8, 383, 16, 7), pile{{"lead white",0.8},{"ultramarine ash",0.4},{"bone black",0.4}}, "round 0.8")
for row = 0, 5 do L(pile{{"bone black",1.4},{"ultramarine blue",0.3}}, {{c.x - 12, 402 + row*6}, {c.x + rand(0, 14), 401.5 + row*6}}, 0.4, 0.7) end
-- chair 5: empty but turned slightly, as if just left (a mug on the console in front)
c = CHAIRS[5]
fill(poly({{c.x + 50, VBOT(c.x + 50) + 6}, {c.x + 64, VBOT(c.x + 64) + 6}, {c.x + 63, VBOT(c.x + 63) + 22}, {c.x + 51, VBOT(c.x + 51) + 22}}), pile{{"lead white",1.4},{"cobalt blue",0.3}}, "round 0.8")

--@ chunk 12
print(wait(5*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1", pile=p, coverage=5, fill=true, clip=m, angle=0, load=1}) end
local function L(p, pts, w) local b = brush{kind="rigger", width=w or 1.4, point=0.8} b:load(p, 0.9) b:stroke(pts, {pressure={0.65, 0.6}, ramps={0.03, 0.03}}) end
-- a crayon drawing taped to the window frame by the second mullion: the station, stick figures waving
local x0, y0 = 474, 96
local sheet = poly({{x0, y0}, {x0 + 46, y0 - 2}, {x0 + 48, y0 + 40}, {x0 + 2, y0 + 42}})
fill(sheet, pile{{"lead white",2.2},{"yellow ochre",0.08}})
fill(poly({{x0 + 16, y0 - 4}, {x0 + 30, y0 - 5}, {x0 + 31, y0 + 2}, {x0 + 17, y0 + 3}}), pile{{"lead white",1.4},{"yellow ochre",0.3}}, "round 0.6")
local OR = pile{{"Mars orange",1},{"lead white",0.2}}
local ring = {} for k = 0, 16 do local t = k/16*2*math.pi ring[#ring+1] = {x0 + 24 + 14*math.cos(t), y0 + 14 + 5*math.sin(t)} end
L(OR, ring, 1.6) L(OR, {{x0 + 26, y0 + 4}, {x0 + 22, y0 + 24}}, 1.8)
local K = {pile{{"cobalt blue",1},{"lead white",0.2}}, pile{{"vermilion",1}}, pile{{"emerald green",1}}}
for i = 0, 2 do
  local fx = x0 + 10 + i*13
  L(K[i + 1], {{fx, y0 + 28}, {fx, y0 + 35}}, 1.1) L(K[i + 1], {{fx - 3, y0 + 39}, {fx, y0 + 35}, {fx + 3, y0 + 39}}, 0.9)
  L(K[i + 1], {{fx, y0 + 30}, {fx + 4, y0 + 25}}, 0.9) L(K[i + 1], {{fx, y0 + 30}, {fx - 3, y0 + 32}}, 0.9)
  local h = brush{kind="round", width=2.2, point=0.4} h:load(K[i + 1], 0.9) h:touch(fx, y0 + 26, {pressure=0.5})
end
local SU = pile{{"cadmium yellow",1},{"lead white",0.2}}
L(SU, {{x0 + 40, y0 + 4}, {x0 + 43, y0 + 6}, {x0 + 41, y0 + 9}, {x0 + 38, y0 + 7}, {x0 + 40, y0 + 4}}, 1.4)

--@ chunk 13
print(wait(6*24*60))
local dk = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}, medium=0.06}
local scr = nil
for _, s in ipairs(SCREENS) do local m = rect(s.x - 1, s.y - 1, 72, 24) scr = scr and (scr + m) or m end
local over = scr * CHM
work(over, {hand="detail", tool="round 1.2", pile=dk, coverage=6, fill=true, clip=over, angle=math.pi/2, load=1})
local rim = pile{{"yellow ochre",1.2},{"lead white",0.8},{"Mars orange",0.2}, medium=0.06}
for _, c in ipairs(CHAIRS) do
  local b = brush{kind="round", width=1.8, point=0.5}
  b:load(rim, 0.85) b:stroke({{c.x + 25 * c.s, 320}, {c.x + 27 * c.s, 345}, {c.x + 41 * c.s, 368}, {c.x + 40 * c.s, 440}}, {pressure={0.8, 0.2}, clip=c.m:grow(1) * scr:grow(2)})
end
-- readouts on the visible parts of the screens
local LN = pile{{"lead white",1.2},{"bone black",0.5},{"ultramarine blue",0.2}}
for _, s in ipairs(SCREENS) do
  local m = rect(s.x, s.y, 70, 22) - CHM
  for row = 0, 2 do
    local x = s.x + 4
    while x < s.x + 64 do local L = rand(4, 12) local b = brush{kind="filbert", width=1.6, stiffness=0.6} b:load(LN, 0.9) b:stroke({{x, s.y + 5 + row*6}, {x + L, s.y + 5 + row*6}}, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=m}) x = x + L + rand(3, 6) end
  end
end

--@ chunk 14
print(wait(4*24*60)) local c = CHAIRS[1] local jk = poly({{c.x - 40, 362}, {c.x + 30, 356}, {c.x + 34, 384}, {c.x + 20, 420}, {c.x - 4, 430}, {c.x - 30, 424}, {c.x - 44, 396}}, true) local m = jk * rect(150, 340, 200, 40) work(m, {hand="detail", tool="round 1.2", pile=pile{{"cadmium red",0.8},{"Mars red",0.4},{"bone black",0.35}}, coverage=5, fill=true, clip=m, angle=0, load=1}) local b = brush{kind="rigger", width=1.2, point=1} b:load(pile{{"cadmium red",0.6},{"lead white",0.5}}, 0.9) b:stroke({{c.x - 40, 362}, {c.x + 30, 356}}, {pressure={0.5, 0.5}})
