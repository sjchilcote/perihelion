-- easel session "bridge": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={18,16}, seed=4242,
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
local dark = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}, medium=0.06}
local dark2 = pile{{"bone black",1.8},{"ultramarine ash",0.6},{"burnt sienna",0.3}, medium=0.06}
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
-- the doorway: a dim cold rectangle in the left wall, and the Commando standing in it, in shadow
local door = poly({{38, 160}, {122, 152}, {122, 452}, {38, 470}})
work(door, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.5},{"ultramarine ash",0.9},{"lead white",0.25}, medium=0.06}, coverage=5, fill=true, clip=door, angle=math.pi/2, load=1})
local k = 150
local fx, fy = 82, 462
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.13,0.5), Q(-0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.11,0.93), Q(0.13,0.5), Q(0.14,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.25,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.23,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx + 0.02 * k, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.34,1.24), Q(-0.31,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
FIG = fig
work(fig, {hand="body", tool="filbert 4", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=6, fill=true, clip=fig, angle=math.pi/2, load=1})
FK, FX, FYY = k, fx, fy

--@ chunk 7
-- on set paint: the doorway dimmer and the Commando restated dark in it; the sun pouring through the window as long warm stripes
-- across the floor toward the lower left, the chairs' shadows cut out of them; warm edges on the chairs' sunward sides
print(wait(4*24*60))
local door = poly({{38, 160}, {122, 152}, {122, 452}, {38, 470}}) - FIG
work(door, {hand="body", tool="filbert 3", pile=pile{{"bone black",1.8},{"ultramarine ash",0.8},{"lead white",0.1}, medium=0.06}, coverage=6, fill=true, clip=door, angle=math.pi/2, load=1})
work(FIG, {hand="body", tool="filbert 3", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=7, fill=true, clip=FIG, angle=math.pi/2, load=1})
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
local door = poly({{38, 160}, {122, 152}, {122, 452}, {38, 470}}) - FIG
work(door, {hand="body", tool="filbert 3", pile=pile{{"bone black",1.6},{"ultramarine blue",0.6},{"lead white",0.12}, medium=0.06}, coverage=7, fill=true, clip=door, angle=math.pi/2, load=1})

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
-- accents on set paint: frost feathering in from the glass's edges and corners; the amber standby; a coat on a chair-back;
-- loose papers and a pen afloat under the ceiling; the Commando restated smooth and dark
print(wait(3*24*60))
local frost = pile{{"zinc white",2},{"lead white",0.6},{"ultramarine ash",0.3}, medium=0.04}
local frostD = pile{{"lead white",1},{"zinc white",0.6},{"ultramarine ash",0.5},{"bone black",0.2}, medium=0.05}
local V = VIEW - MULL - CHM
local function feather(x, y, ang, len, depth, pl)
  local ex, ey = x + math.cos(ang) * len, y + math.sin(ang) * len
  local b = brush{kind="round", width=math.max(0.6, 1.6 - depth * 0.4), point=0.7}
  b:load(pl, 0.8); b:stroke({{x, y}, {ex, ey}}, {pressure={0.7, 0.05}, clip=V})
  if depth < 3 then
    for _, t in ipairs{0.3, 0.55, 0.8} do
      local bx, by = x + (ex - x) * t, y + (ey - y) * t
      for _, s in ipairs{-1, 1} do feather(bx, by, ang + s * (0.7 + 0.2 * rand(-1, 1)), len * 0.38, depth + 1, frostD) end
    end
  end
end
-- along the sill and up the lower corners, and in from each mullion
for x = 160, 990, 38 do feather(x + rand(-8, 8), VBOT(x) - 2, -math.pi / 2 + rand(-0.5, 0.5), rand(22, 46), 0, frost) end
for y = 120, 330, 34 do feather(152, y + rand(-6, 6), rand(-0.4, 0.4), rand(20, 40), 0, frost) end
for _, x in ipairs{330, 525, 720, 905} do
  for y = 140, 320, 60 do feather(x + 7, y + rand(-10, 10), rand(-0.5, 0.3), rand(12, 26), 1, frostD); feather(x - 7, y + rand(-10, 10), math.pi + rand(-0.3, 0.5), rand(12, 26), 1, frostD) end
end
-- the amber standby on the middle console's screen
local s = SCREENS[3]
local am = ellipse(s.x + 35, s.y + 11, 9, 5)
work(am, {hand="detail", pile=pile{{"chrome yellow",1},{"Mars orange",0.8},{"lead white",0.5}, medium=0.05}, coverage=5, fill=true, clip=am, load=1})
local glowm = ellipse(s.x + 35, s.y + 11, 30, 14) - am
stipple(glowm, {pile=pile{{"Mars orange",1},{"burnt sienna",0.6},{"chrome yellow",0.4}, medium=0.06}, width=1, coverage=function(x, y) local d = math.sqrt(((x - s.x - 35) / 30)^2 + ((y - s.y - 11) / 14)^2); return clamp(1 - d, 0, 1)^1.5 * 2 end, feather=0.9, cluster=0.1})
-- a coat slung over the second chair's back
local c = CHAIRS[2]
local coat = poly({{c.x - 44, 352}, {c.x + 30, 345}, {c.x + 36, 380}, {c.x + 18, 430}, {c.x - 10, 472}, {c.x - 34, 470}, {c.x - 50, 420}}, true)
work(coat, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.4},{"viridian",0.2},{"burnt sienna",0.5},{"yellow ochre",0.2}, medium=0.06}, coverage=6, fill=true, clip=coat, angle=math.pi/2, load=1})
local cb = brush{kind="round", width=1.6, point=0.4}
cb:load(pile{{"yellow ochre",1},{"lead white",0.6},{"raw sienna",0.3}, medium=0.06}, 0.8)
cb:stroke({{c.x + 30, 346}, {c.x + 36, 380}, {c.x + 18, 430}}, {pressure={0.7, 0.2}, clip=coat:grow(1)})
cb:load(pile{{"bone black",2},{"burnt sienna",0.4}, medium=0.06}, 0.8)
cb:stroke({{c.x - 20, 360}, {c.x - 12, 420}, {c.x - 18, 465}}, {pressure={0.6, 0.3}, clip=coat})
-- papers drifting, caught in the shafts, and the pen frozen against the ceiling
local paper = pile{{"lead white",1.6},{"yellow ochre",0.3},{"bone black",0.1}, medium=0.05}
local paperD = pile{{"lead white",0.8},{"bone black",0.6},{"ultramarine ash",0.3}, medium=0.05}
for _, q in ipairs{{460, 250, 0.4, true}, {620, 180, -0.3, true}, {300, 60, 0.15, false}, {800, 40, -0.5, false}, {700, 300, 0.8, true}} do
  local x, y, a = q[1], q[2], q[3]
  local function R(u, v) return {x + u * math.cos(a) - v * math.sin(a), y + u * math.sin(a) + v * math.cos(a)} end
  local m = poly({R(-14, -9), R(14, -11), R(13, 9), R(-12, 10)})
  work(m, {hand="detail", pile=q[4] and paper or paperD, coverage=5, fill=true, clip=m, load=1})
end
local pb = brush{kind="round", width=2.4, point=0.5}
pb:load(pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}, 0.9); pb:stroke({{520, 22}, {556, 14}}, {pressure={0.8, 0.8}})
pb:load(pile{{"lead white",1.5},{"yellow ochre",0.3}, medium=0.05}, 0.8); pb:stroke({{522, 20}, {552, 14}}, {pressure={0.3, 0.3}})
-- the Commando, dark and smooth, in shadow in the doorway, a thin warm edge on the side toward the window
work(FIG, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.3}, medium=0.06}, coverage=7, fill=true, clip=FIG, load=1})
local k, fx, fy = FK, FX, FYY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local wr = brush{kind="round", width=1.6, point=0.5}
wr:load(pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.4}, medium=0.06}, 0.8)
wr:stroke({Q(0.1,1.86), Q(0.1,1.7)}, {pressure={0.6, 0.3}, clip=FIG:grow(1)})
wr:stroke({Q(0.38,1.55), Q(0.4,1.25), Q(0.36,1.0)}, {pressure={0.6, 0.15}, clip=FIG:grow(1)})

--@ chunk 11
-- frost read as little white trees: a frosted crust stippled along the sill and corners in a warm-gray (sun through ice), thinning upward,
-- swallowing the twigs; the coat repainted as dark cloth with folds
print(wait(3*24*60))
local V = VIEW - MULL - CHM
local crust = pile{{"lead white",1.2},{"yellow ochre",0.45},{"bone black",0.35},{"burnt sienna",0.15}, medium=0.06}
local function cov(x, y)
  local d = VBOT(x) - y
  local e = math.min(x - 150, 100)
  local v = clamp(1 - d / 70, 0, 1) ^ 1.3 * 3.2
  v = math.max(v, clamp(1 - (x - 150) / 60, 0, 1) ^ 1.5 * 2.5)
  return v
end
stipple(V, {pile=crust, width=1.4, coverage=cov, feather=0.9, cluster=0.35, dips={30, 0.6, 0}})
-- a few crisp feathers restated warm on top, near the sill
local fe = pile{{"lead white",1.8},{"yellow ochre",0.4}, medium=0.05}
for x = 175, 990, 70 do
  local y = VBOT(x) - 4
  local a = -math.pi / 2 + rand(-0.4, 0.4)
  local b = brush{kind="round", width=1.0, point=0.7}
  b:load(fe, 0.7); b:stroke({{x, y}, {x + math.cos(a) * 30, y + math.sin(a) * 30}}, {pressure={0.6, 0.05}, clip=V})
end
local c = CHAIRS[2]
local coat = poly({{c.x - 44, 352}, {c.x + 30, 345}, {c.x + 36, 380}, {c.x + 18, 430}, {c.x - 10, 472}, {c.x - 34, 470}, {c.x - 50, 420}}, true)
work(coat, {hand="body", tool="filbert 4", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.2}, medium=0.06}, coverage=7, fill=true, clip=coat, angle=math.pi/2, load=1})
local fold = pile{{"bone black",1.2},{"burnt sienna",0.8},{"yellow ochre",0.25},{"lead white",0.15}, medium=0.06}
for _, f in ipairs{{{c.x + 8, 352}, {c.x + 14, 400}, {c.x + 4, 455}}, {{c.x - 26, 360}, {c.x - 30, 420}, {c.x - 22, 466}}} do
  local b = brush{kind="round", width=2.4, point=0.4}
  b:load(fold, 0.8); b:stroke(f, {pressure={0.6, 0.3}, clip=coat})
end
local cb = brush{kind="round", width=1.8, point=0.4}
cb:load(pile{{"yellow ochre",1},{"lead white",0.7},{"raw sienna",0.3}, medium=0.06}, 0.85)
cb:stroke({{c.x + 30, 346}, {c.x + 36, 380}, {c.x + 18, 430}, {c.x - 8, 470}}, {pressure={0.8, 0.2}, clip=coat:grow(1)})
-- the collar folded over the headrest
local col = poly({{c.x - 30, 336}, {c.x + 26, 332}, {c.x + 30, 352}, {c.x - 34, 356}}, true)
work(col, {hand="detail", pile=pile{{"bone black",1.6},{"burnt sienna",0.7}, medium=0.06}, coverage=6, fill=true, clip=col, load=1})

--@ chunk 12
-- the twig "arrows" by the mullions buried in a narrow crust that climbs each mullion; the doorway's floor darkened
print(wait(2*24*60))
local V = VIEW - MULL - CHM
local crust = pile{{"lead white",1.2},{"yellow ochre",0.45},{"bone black",0.35},{"burnt sienna",0.15}, medium=0.06}
for _, x in ipairs{330, 525, 720, 905} do
  local m = rect(x - 40, 100, 80, 260) * V
  stipple(m, {pile=crust, width=1.3, coverage=function(px, py) return clamp(1 - math.abs(px - x) / 34, 0, 1) ^ 1.2 * 3 end, feather=0.9, cluster=0.35, dips={30, 0.6, 0}})
end
local df = rect(36, 455, 116, 108) * FLOORM - FIG
work(df, {hand="body", tool="filbert 5", pile=pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=df, angle=2.66, load=1})
