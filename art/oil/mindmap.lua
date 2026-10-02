-- easel session "mindmap": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=1, linen={18,16}, seed=777,
  ground={{pile={{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}, um=90, apply="knife", texture=0.3}}}
CX, CY, RR = 500, 500, 455
rose = ellipse(CX, CY, RR, RR)
-- spandrels: deep lapis corners outside the rose
local lapis = pile{{"ultramarine blue",2},{"bone black",0.5},{"cobalt blue",0.5}}
work(rect(0,0,1000,1000) - ellipse(CX, CY, RR + 18, RR + 18), {hand="body", pile=lapis, coverage=3.5, fill=true, clip=true, load=1})
-- the rose's frame: a crimson ring between gilt rings
local crim = pile{{"cadmium red",1},{"rose madder",1},{"Mars red",0.4}}
work(ellipse(CX, CY, RR + 18, RR + 18) - ellipse(CX, CY, RR + 4, RR + 4), {hand="detail", tool="round 3", pile=crim, coverage=4, fill=true, load=1})
-- the page inside: vellum, a little warmer toward the hub
local vel = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.4}}
work(ellipse(CX, CY, RR + 4, RR + 4), {hand="body", pile=vel, coverage=2.5, fill=true, clip=true, load=0.9})
print(wait(3*1440))

--@ chunk 2
-- The Void unfolds out of the lower-right quadrant: violet dark, reaching past the cross into its neighbours.
local pts = {}
local nz = noise{seed=31, period=0.9, octaves=3}
for i = 0, 40 do
  local a = -0.35 + (math.pi/2 + 0.75) * i / 40      -- a little past both axes
  local edgeFade = math.min(i, 40 - i) / 40
  local r = 120 + 330 * math.min(1, edgeFade * 3.2) + 40 * nz(a * 3, 1)
  pts[#pts + 1] = {CX + r * math.cos(a), CY + r * math.sin(a)}
end
pts[#pts + 1] = {CX + 60, CY + 60}
VOIDM = (poly(pts, true):roughen(16, 50, 9) * ellipse(CX, CY, RR + 2, RR + 2)) - ellipse(CX, CY, 92, 92)
local vd = pile{{"cobalt violet",1},{"bone black",1},{"ultramarine blue",0.8},{"magenta",0.2}}
local vm = pile{{"cobalt violet",1.5},{"ultramarine blue",0.6},{"bone black",0.4},{"lead white",0.3}}
local core = VOIDM:shrink(30)
work(core, {hand="body", pile=vd, coverage=3.5, fill=true, clip=true, angle=function(x, y) return math.atan(y - CY, x - CX) + 1.2 end, load=1})
work(VOIDM - core, {hand="body", pile=vm, coverage=3, fill=true, clip=true, angle=function(x, y) return math.atan(y - CY, x - CX) + 1.2 end, load=0.9})
-- the cross that divides the mind: gilt arms from the hub to the rim
local gold = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",1}}
ARMS = rect(CX - 8, CY - RR, 16, RR - 90) + rect(CX - 8, CY + 90, 16, RR - 90) + rect(CX - RR, CY - 8, RR - 90, 16) + rect(CX + 90, CY - 8, RR - 90, 16)
work(ARMS, {hand="detail", tool="round 3", pile=gold, coverage=4, fill=true, load=1})
-- the hub's gilt roundel
work(ellipse(CX, CY, 95, 95) - ellipse(CX, CY, 82, 82), {hand="detail", tool="round 3", pile=gold, coverage=4, fill=true, load=1})
print(wait(3*1440))

--@ chunk 3
-- The tree of the mind: edges branching from the hub through four regions, nodes lit or still in fog.
QD = {
  {name="Vocation", a=math.rad(225), lit={1, 0.9, 0.6, 0.3}},
  {name="Comprehension", a=math.rad(315), lit={1, 0.7, 0.45, 0.2}},
  {name="History", a=math.rad(135), lit={1, 0.75, 0.45, 0.2}},
  {name="Void", a=math.rad(45), lit={1, 0.45, 0.25, 0.0}},
}
NODES = {}
local function add(q, ring, a, r, parent)
  local n = {q=q, ring=ring, a=a, r=r, x=CX + r*math.cos(a), y=CY + r*math.sin(a), parent=parent}
  n.lit = (parent == nil or parent.lit) and (math.random() < QD[q].lit[ring])
  NODES[#NODES + 1] = n
  return n
end
for q, Q in ipairs(QD) do
  for _, da in ipairs({-29, 0, 29}) do
    local p = add(q, 1, Q.a + math.rad(da + randn(0, 2)), 165 + randn(0, 6), nil)
    for _, db in ipairs({-12, 12}) do
      local c = add(q, 2, p.a + math.rad(db + randn(0, 2)), 268 + randn(0, 8), p)
      for _, dc in ipairs({-6, 6}) do
        local g = add(q, 3, c.a + math.rad(dc + randn(0, 1.5)), 362 + randn(0, 8), c)
        if math.random() < 0.6 then add(q, 4, g.a + math.rad(randn(0, 2)), 425 + randn(0, 4), g) end
      end
    end
  end
end
INK = {
  pile{{"Mars yellow",1},{"yellow ochre",1},{"raw sienna",0.6}},             -- vocation: gilt lines
  pile{{"ultramarine blue",1.5},{"cerulean blue",0.6},{"bone black",0.2}},   -- comprehension: cold blue
  pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.3}},              -- history: sepia
  pile{{"cobalt violet",1},{"bone black",1},{"magenta",0.2}},                -- void
}
local ghost = pile{{"lead white",1},{"bone black",0.35},{"yellow ochre",0.3},{"cobalt violet",0.1}}
local lb = brush{kind="round", width=2, point=0.6}
for _, n in ipairs(NODES) do
  local px, py
  if n.parent then px, py = n.parent.x, n.parent.y else px, py = CX + 96*math.cos(n.a), CY + 96*math.sin(n.a) end
  local pts
  if n.q == 2 then pts = {{px, py}, {n.x, n.y}}
  else
    local mx, my = (px + n.x)/2, (py + n.y)/2
    local bow = (n.q == 1) and 6 or ((n.q == 4) and 10 or 3)
    local nx, ny = -(n.y - py), (n.x - px); local L = math.sqrt(nx*nx + ny*ny)
    local s = (math.random() < 0.5) and 1 or -1
    pts = {{px, py}, {mx + s*bow*nx/L, my + s*bow*ny/L}, {n.x, n.y}}
  end
  local w = ({2.6, 2.0, 1.5, 1.2})[n.ring]
  local bb = brush{kind="round", width=w, point=0.6}
  bb:reload(n.lit and INK[n.q] or ghost, 0.7)
  bb:stroke(pts, {pressure={0.6, 0.5}, ramps={0.05, 0.1}})
end
print(#NODES)

--@ chunk 4
-- nodes: illuminated roundels where lit, ghost rings where still in fog
local gold = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",1}}
local goldD = pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.3}}
local FILL = {
  pile{{"cadmium red",1},{"rose madder",0.8},{"Mars red",0.3}},
  pile{{"ultramarine blue",1.2},{"cerulean blue",1},{"lead white",0.4}},
  pile{{"burnt sienna",1},{"bone black",0.8},{"yellow ochre",0.6}},
  pile{{"cobalt violet",1},{"bone black",1.2},{"ultramarine blue",0.5}},
}
local ghost = pile{{"lead white",1},{"bone black",0.35},{"yellow ochre",0.3},{"cobalt violet",0.1}}
local RAD = {15, 11.5, 8.5, 6.5}
local function ngon(x, y, r, n, rot) local p = {} for i = 0, n - 1 do local a = rot + i*2*math.pi/n; p[#p+1] = {x + r*math.cos(a), y + r*math.sin(a)} end return p end
for _, n in ipairs(NODES) do
  local r = RAD[n.ring]
  local shape
  if n.q == 2 then shape = poly(ngon(n.x, n.y, r * 1.1, 6, n.a))
  elseif n.q == 3 then shape = poly(ngon(n.x, n.y, r * 1.05, 4, math.pi/4 + n.a))
  else shape = ellipse(n.x, n.y, r, r) end
  if n.lit then
    local rim = shape:grow(2.6) - shape
    work(rim, {hand="detail", tool="round 1.5", pile=(n.q == 4) and pile{{"cobalt violet",1.5},{"lead white",1},{"magenta",0.2}} or gold, coverage=4, fill=true, load=1})
    work(shape, {hand="detail", tool="round 1.8", pile=FILL[n.q], coverage=4, fill=true, load=1})
    n.shape = shape
  else
    local rim = shape:grow(1.2) - shape
    work(rim, {hand="detail", tool="round 1.2", pile=ghost, coverage=3, fill=true, load=0.7})
  end
end
print(wait(3*1440))
-- emblems inside the lit nodes
local wb = brush{kind="round", width=1.3, point=0.7}
local wht = pile{{"lead white",2},{"lemon chrome",0.15}}
for _, n in ipairs(NODES) do
  if n.lit then
    local r = RAD[n.ring] * 0.55
    if n.q == 1 then
      wb:reload(gold, 0.7); wb:stroke({{n.x, n.y - r}, {n.x, n.y + r}}, {pressure={0.5,0.5}})
      wb:reload(gold, 0.7); wb:stroke({{n.x - r*0.7, n.y - r*0.25}, {n.x + r*0.7, n.y - r*0.25}}, {pressure={0.5,0.5}})
    elseif n.q == 2 then
      local t = ngon(n.x, n.y, r, 3, n.a); t[4] = t[1]
      wb:reload(wht, 0.6); wb:stroke(t, {pressure={0.4,0.4}})
    elseif n.q == 3 then
      wb:reload(pile{{"bone black",2}}, 0.6); wb:stroke({{n.x - r*0.7, n.y}, {n.x + r*0.7, n.y}}, {pressure={0.45,0.45}})
      wb:reload(goldD, 0.6); wb:stroke({{n.x - r*0.5, n.y - r*0.5}, {n.x + r*0.5, n.y - r*0.5}}, {pressure={0.4,0.4}})
    else
      wb:reload(pile{{"cobalt violet",1},{"lead white",1.5}}, 0.5); wb:touch(n.x, n.y, {pressure=0.4})
    end
  end
end

--@ chunk 5
-- the root: the seed's encyclopedia as a bound book in the hub
local lapis = pile{{"ultramarine blue",2},{"bone black",0.6},{"cobalt blue",0.5}}
work(ellipse(CX, CY, 82, 82), {hand="detail", tool="round 3", pile=lapis, coverage=4, fill=true, load=1})
print(wait(2*1440))
local bx0, by0, bw, bh = CX - 40, CY - 52, 80, 104
-- page block peeking at the fore-edge and foot
work(poly({{bx0 + bw, by0 + 4}, {bx0 + bw + 6, by0 + 8}, {bx0 + bw + 6, by0 + bh + 6}, {bx0 + 6, by0 + bh + 6}, {bx0, by0 + bh}}), {hand="detail", tool="round 1.5", pile=pile{{"lead white",2},{"yellow ochre",0.8}}, coverage=4, fill=true, load=1})
local leather = pile{{"Mars red",1},{"rose madder",0.6},{"bone black",0.5}}
work(rect(bx0, by0, bw, bh), {hand="detail", tool="round 2.5", pile=leather, coverage=4.5, fill=true, load=1})
print(wait(3*1440))
local gold = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",1}}
local hi = pile{{"lead white",2},{"lemon chrome",0.3}}
local g = brush{kind="round", width=1.5, point=0.6}
local function st(p, pts, pr) g:reload(p, 0.7); g:stroke(pts, {pressure=pr or {0.55,0.55}, ramps={0.05,0.05}}) end
-- tooled borders
for _, ins in ipairs({5, 9}) do
  st(gold, {{bx0 + ins, by0 + ins}, {bx0 + bw - ins, by0 + ins}, {bx0 + bw - ins, by0 + bh - ins}, {bx0 + ins, by0 + bh - ins}, {bx0 + ins, by0 + ins}})
end
-- the cross on the cover
local cb = brush{kind="round", width=4, point=0.3}
cb:reload(gold, 0.8); cb:stroke({{CX, by0 + 22}, {CX, by0 + bh - 22}}, {pressure={0.7,0.7}})
cb:reload(gold, 0.8); cb:stroke({{CX - 16, by0 + 42}, {CX + 16, by0 + 42}}, {pressure={0.7,0.7}})
st(hi, {{CX + 1.2, by0 + 23}, {CX + 1.2, by0 + bh - 23}}, {0.35,0.3})
-- corner bosses and the clasp
for _, c in ipairs({{bx0 + 6, by0 + 6}, {bx0 + bw - 6, by0 + 6}, {bx0 + 6, by0 + bh - 6}, {bx0 + bw - 6, by0 + bh - 6}}) do
  local bb = brush{kind="round", width=6, point=0.1}
  bb:reload(gold, 0.8); bb:touch(c[1], c[2], {pressure=0.7})
  g:reload(hi, 0.5); g:touch(c[1] + 1, c[2] - 1, {pressure=0.4})
end
local clb = brush{kind="flat", width=7}
clb:reload(gold, 0.8); clb:stroke({{bx0 + bw - 4, CY}, {bx0 + bw + 9, CY}}, {pressure={0.8,0.8}, orient="across"})
-- the spine's shadow down the left
local sp = brush{kind="round", width=4, point=0.2}
sp:reload(pile{{"bone black",1.5},{"Mars red",0.6}}, 0.7); sp:stroke({{bx0 + 2, by0 + 2}, {bx0 + 2, by0 + bh - 2}}, {pressure={0.6,0.6}})

--@ chunk 6
print(wait(8*1440))
local bx0, by0, bw, bh = CX - 40, CY - 52, 80, 104
local leather = pile{{"Mars red",1},{"rose madder",0.6},{"bone black",0.6}}
work(rect(bx0, by0, bw, bh), {hand="detail", tool="round 2.5", pile=leather, coverage=5, fill=true, load=1})
print(wait(12*1440))
local gold = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",1}}
local hi = pile{{"lead white",2},{"lemon chrome",0.3}}
local g = brush{kind="round", width=1.5, point=0.6}
local function st(p, pts, pr) g:reload(p, 0.7); g:stroke(pts, {pressure=pr or {0.55,0.55}, ramps={0.05,0.05}}) end
-- tooled borders
for _, ins in ipairs({5, 9}) do
  st(gold, {{bx0 + ins, by0 + ins}, {bx0 + bw - ins, by0 + ins}, {bx0 + bw - ins, by0 + bh - ins}, {bx0 + ins, by0 + bh - ins}, {bx0 + ins, by0 + ins}})
end
-- the cross on the cover
local cb = brush{kind="round", width=4, point=0.3}
cb:reload(gold, 0.8); cb:stroke({{CX, by0 + 22}, {CX, by0 + bh - 22}}, {pressure={0.7,0.7}})
cb:reload(gold, 0.8); cb:stroke({{CX - 16, by0 + 42}, {CX + 16, by0 + 42}}, {pressure={0.7,0.7}})
st(hi, {{CX + 1.2, by0 + 23}, {CX + 1.2, by0 + bh - 23}}, {0.35,0.3})
-- corner bosses and the clasp
for _, c in ipairs({{bx0 + 6, by0 + 6}, {bx0 + bw - 6, by0 + 6}, {bx0 + 6, by0 + bh - 6}, {bx0 + bw - 6, by0 + bh - 6}}) do
  local bb = brush{kind="round", width=6, point=0.1}
  bb:reload(gold, 0.8); bb:touch(c[1], c[2], {pressure=0.7})
  g:reload(hi, 0.5); g:touch(c[1] + 1, c[2] - 1, {pressure=0.4})
end
local clb = brush{kind="flat", width=7}
clb:reload(gold, 0.8); clb:stroke({{bx0 + bw - 4, CY}, {bx0 + bw + 9, CY}}, {pressure={0.8,0.8}, orient="across"})
-- the spine's shadow down the left
local sp = brush{kind="round", width=4, point=0.2}
sp:reload(pile{{"bone black",1.5},{"Mars red",0.6}}, 0.7); sp:stroke({{bx0 + 2, by0 + 2}, {bx0 + 2, by0 + bh - 2}}, {pressure={0.6,0.6}})

--@ chunk 7
-- The Void unfolds: folds opening out of its depth, the cross's gilt swallowed inside it, tendrils reaching for neighbouring nodes.
local vd = pile{{"cobalt violet",1},{"bone black",1.2},{"ultramarine blue",0.8},{"magenta",0.2}}
local vl = pile{{"cobalt violet",1.5},{"lead white",1},{"magenta",0.25}}
local vglow = pile{{"cobalt violet",1},{"lead white",2},{"magenta",0.3}}
work(ARMS * VOIDM:shrink(14), {hand="detail", tool="round 3", pile=vd, coverage=4, fill=true, load=1})
stipple((VOIDM:grow(8) - VOIDM:shrink(10)) - ellipse(CX, CY, 97, 97), {pile=vd, width=3.5, coverage=1.6, cluster={0.6, 10}, feather=0.5, pressure={0.4,0.8}})
-- the folds: nested arcs opening outward from a point deep in the dark
local fx, fy = 655, 655
local cr = brush{kind="round", width=2.2, point=0.5}
local lr = brush{kind="round", width=1.3, point=0.7}
for k = 1, 9 do
  local r0 = 18 * k
  local a0 = math.rad(150 + 23 * k)
  local span = math.rad(70 + 6 * k)
  local pts, hl = {}, {}
  for i = 0, 10 do
    local a = a0 + span * i / 10
    local r = r0 * (1 + 0.25 * math.sin(i / 10 * math.pi))
    pts[#pts + 1] = {fx + r * math.cos(a), fy + r * math.sin(a)}
    hl[#hl + 1] = {fx + (r + 2.5) * math.cos(a), fy + (r + 2.5) * math.sin(a)}
  end
  cr:reload(pile{{"bone black",2},{"cobalt violet",0.6}}, 0.7); cr:stroke(pts, {pressure={0.2, 0.6}, ramps={0.4, 0.3}, clip=VOIDM})
  lr:reload((k % 3 == 0) and vglow or vl, 0.6); lr:stroke(hl, {pressure={0.15, 0.5}, ramps={0.5, 0.3}, clip=VOIDM})
end
-- tendrils creeping out over the vellum toward the nodes nearest the border
local tb = brush{kind="round", width=3, point=0.8}
local nt = 0
for _, n in ipairs(NODES) do
  if (n.q == 2 or n.q == 3) and n.ring >= 2 then
    local d = math.min(math.abs(math.atan(n.y - CY, n.x - CX) - 0), math.abs(math.atan(n.y - CY, n.x - CX) - math.pi/2))
    if d < 0.35 and math.random() < 0.7 then
      -- start at the void's edge on the way to that node
      local a = (n.q == 2) and math.rad(rand(-14, -4)) or math.rad(rand(94, 104))
      local r = n.r + rand(-20, 20)
      local sx, sy = CX + r * math.cos(a + ((n.q == 2) and 0.35 or -0.35)), CY + r * math.sin(a + ((n.q == 2) and 0.35 or -0.35))
      local pts = {}
      for i = 0, 6 do local u = i / 6; pts[#pts + 1] = {lerp(sx, n.x, u * 0.85) + rand(-5, 5), lerp(sy, n.y, u * 0.85) + rand(-5, 5)} end
      tb:reload(vd, 0.6); tb:stroke(pts, {pressure={0.7, 0.0}, ramps={0.05, 0.8}})
      nt = nt + 1
    end
  end
end
print(nt)

--@ chunk 8
-- fog of war over the outer, unlit reaches; gilt pearls round the rose; the four regions' emblems in the corners
local fogP = pile{{"lead white",2},{"bone black",0.25},{"yellow ochre",0.3},{"cobalt violet",0.1}}
local keep = ellipse(CX, CY, 1, 1)
for _, n in ipairs(NODES) do if n.lit and n.ring >= 2 then keep = keep + ellipse(n.x, n.y, 16, 16) end end
local fogM = (ellipse(CX, CY, 452, 452) - ellipse(CX, CY, 300, 300)):roughen(30, 90, 5) - VOIDM:grow(4) - keep - ARMS:grow(2)
work(fogM, {hand="scumble", pile=fogP, load=0.28, pressure={0.1, 0.3}, coverage=0.9, clip=true})
local gold = pile{{"Mars yellow",1},{"yellow ochre",1},{"lead white",1}}
local hi = pile{{"lead white",2},{"lemon chrome",0.3}}
local pb = brush{kind="round", width=4.2, point=0.1}
for i = 0, 89 do
  local a = i * 2 * math.pi / 90
  local x, y = CX + (RR + 11) * math.cos(a), CY + (RR + 11) * math.sin(a)
  pb:reload(gold, 0.7); pb:touch(x, y, {pressure=0.6})
end
-- corner emblems
local g = brush{kind="round", width=2.4, point=0.5}
local function st(p, pts, pr) g:reload(p, 0.75); g:stroke(pts, {pressure=pr or {0.6,0.6}, ramps={0.05,0.05}}) end
-- Vocation (top-left): a gilt cross with crimson bosses
st(gold, {{70, 40}, {70, 130}}); st(gold, {{40, 70}, {100, 70}})
for _, c in ipairs({{70, 40}, {70, 130}, {40, 70}, {100, 70}}) do local b = brush{kind="round", width=7, point=0.1}; b:reload(pile{{"cadmium red",1},{"rose madder",0.6}}, 0.8); b:touch(c[1], c[2], {pressure=0.7}) end
-- Comprehension (top-right): nested hexagons, the inner turned
for k, r in ipairs({34, 21, 13}) do
  local p = {} for i = 0, 6 do local a = k * 0.5 + i * math.pi / 3; p[#p+1] = {930 + r * math.cos(a), 70 + r * math.sin(a)} end
  st((k == 2) and pile{{"cerulean blue",1},{"lead white",1.5}} or gold, p, {0.5,0.5})
end
-- History (bottom-left): a scroll of ruled lines
for k = 0, 4 do st((k == 0) and gold or pile{{"burnt sienna",1},{"yellow ochre",1},{"lead white",1}}, {{40, 890 + k * 12}, {120, 890 + k * 12}}, {0.5,0.5}) end
st(gold, {{36, 884}, {36, 946}}, {0.6,0.6}); st(gold, {{124, 884}, {124, 946}}, {0.6,0.6})
-- The Void (bottom-right): an eye of folds opening
local vl = pile{{"cobalt violet",1.5},{"lead white",1.2},{"magenta",0.25}}
for k = 1, 4 do
  local r = 9 * k
  local p = {} for i = 0, 12 do local a = math.pi * (0.15 + 0.7 * i / 12) + k * 0.3; p[#p+1] = {930 + r * math.cos(a), 930 - r * math.sin(a) * 0.7} end
  st(vl, p, {0.3, 0.6})
end
local eb = brush{kind="round", width=8, point=0.1}; eb:reload(pile{{"bone black",2},{"cobalt violet",1}}, 0.8); eb:touch(930, 930, {pressure=0.7})

--@ chunk 9
print(wait(4*1440))
-- gilt arms: a dark tooled edge and a burnished line
local dkG = pile{{"raw sienna",1},{"burnt sienna",0.6},{"bone black",0.3}}
local hi = pile{{"lead white",2},{"lemon chrome",0.3}}
local e = brush{kind="round", width=1.2, point=0.6}
local function st(p, pts, pr, clipM) e:reload(p, 0.6); e:stroke(pts, {pressure=pr or {0.5,0.5}, ramps={0.05,0.05}, clip=clipM}) end
local noVoid = -(VOIDM:shrink(10))
for _, s in ipairs({{{CX - 8, CY - RR + 4}, {CX - 8, CY - 96}}, {{CX + 8, CY - RR + 4}, {CX + 8, CY - 96}},
                    {{CX - 8, CY + 96}, {CX - 8, CY + RR - 4}}, {{CX + 8, CY + 96}, {CX + 8, CY + RR - 4}},
                    {{CX - RR + 4, CY - 8}, {CX - 96, CY - 8}}, {{CX - RR + 4, CY + 8}, {CX - 96, CY + 8}},
                    {{CX + 96, CY - 8}, {CX + RR - 4, CY - 8}}, {{CX + 96, CY + 8}, {CX + RR - 4, CY + 8}}}) do
  st(dkG, s, {0.45,0.45}, noVoid)
end
st(hi, {{CX + 2, CY - RR + 6}, {CX + 2, CY - 100}}, {0.3,0.3}, noVoid)
st(hi, {{CX - RR + 6, CY - 2}, {CX - 100, CY - 2}}, {0.3,0.3}, noVoid)
-- a few words of script beside each primary node
local INKS = {pile{{"cadmium red",1},{"rose madder",0.5},{"bone black",0.3}}, pile{{"ultramarine blue",1.5},{"bone black",0.3}}, pile{{"burnt sienna",1},{"bone black",1}}, pile{{"cobalt violet",1},{"lead white",1.5}}}
local sb = brush{kind="round", width=0.9, point=0.8}
for _, n in ipairs(NODES) do
  if n.ring <= 2 and n.lit then
    local ox, oy = n.x + 18, n.y - 3
    for row = 0, 1 do
      local x = ox
      for w = 1, 3 + math.random(0, 2) do
        local L = rand(2, 6)
        sb:reload(INKS[n.q], 0.5)
        sb:stroke({{x, oy + row * 4.5}, {x + L * 0.3, oy + row * 4.5 - 1.2}, {x + L, oy + row * 4.5 + 0.3}}, {pressure={0.5,0.4}})
        x = x + L + 2
      end
    end
  end
end

