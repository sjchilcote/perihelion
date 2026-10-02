-- easel session "rothko": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1200, aspect=2.4, linen={18,16}, seed=1958,
  ground={{pile={{"bone black",1.5},{"Mars red",0.6},{"bone brown",0.6},{"lead white",0.2}}, um=90, apply="knife", texture=0.25}}}
PX = {{24, 318}, {353, 647}, {682, 976}}
PY0, PY1 = 22, 395
local function panel(i) return rect(PX[i][1], PY0, PX[i][2] - PX[i][1], PY1 - PY0) end
local g1 = pile{{"Mars red",1},{"bone black",0.7},{"rose madder",0.3}}
local g2 = pile{{"bone black",1.2},{"cobalt violet",0.6},{"ultramarine blue",0.5}}
local g3 = pile{{"bone black",1.6},{"cobalt violet",0.5},{"magenta",0.1}}
work(panel(1), {hand="body", pile=g1, coverage=3.5, fill=true, angle=math.pi/2, edge="soft", load=1})
work(panel(2), {hand="body", pile=g2, coverage=3.5, fill=true, angle=math.pi/2, edge="soft", load=1})
work(panel(3), {hand="body", pile=g3, coverage=3.5, fill=true, angle=math.pi/2, edge="soft", load=1})
print(wait(5*1440))

--@ chunk 2
function field(x0, y0, x1, y1, s)
  return rect(x0, y0, x1 - x0, y1 - y0):roughen(3, 25, s):soften(4)
end
F = {
  {field(42, 42, 300, 236, 1), pile{{"cadmium red",1},{"rose madder",0.8},{"Mars red",0.3}}},
  {field(46, 252, 296, 268, 2), pile{{"lead white",2},{"yellow ochre",0.5},{"raw sienna",0.2},{"Mars red",0.12}}},
  {field(42, 284, 300, 376, 3), pile{{"rose madder",1},{"Mars red",0.6},{"cadmium red",0.4},{"bone black",0.25}}},
  {field(371, 42, 629, 270, 4), pile{{"ultramarine blue",1},{"cerulean blue",0.6},{"lead white",0.45},{"bone black",0.1}}},
  {field(376, 286, 624, 294, 5), pile{{"lead white",2},{"cerulean blue",0.3},{"bone black",0.12}}},
  {field(371, 310, 629, 376, 6), pile{{"ultramarine blue",1},{"cobalt violet",0.8},{"bone black",0.45}}},
  {field(700, 42, 958, 282, 7), pile{{"bone black",1},{"cobalt violet",0.75},{"ultramarine blue",0.3},{"lead white",0.18}}},
}
for _, f in ipairs(F) do
  work(f[1], {hand="body", tool="filbert 8", pile=f[2], coverage=3.2, fill=true, angle=0, clip=true, load=0.9})
end
-- VOID: the big field's lower edge folds into a smaller copy of itself, and that one into a smaller one
VOIDS = {field(762, 300, 896, 352, 8), field(803, 364, 855, 383, 9)}
local vs = pile{{"bone black",1},{"cobalt violet",0.85},{"magenta",0.12},{"lead white",0.24}}
for _, m in ipairs(VOIDS) do work(m, {hand="detail", tool="round 3", pile=vs, coverage=4, fill=true, load=1}) end
-- feather every edge while wet
local edges = nil
for _, f in ipairs(F) do local e = f[1]:grow(5) - f[1]:shrink(5); edges = edges and (edges + e) or e end
for _, m in ipairs(VOIDS) do edges = edges + (m:grow(4) - m:shrink(4)) end
blend(edges, {angle=0, tool={kind="badger", width=12}})
blend(edges, {angle=math.pi/2, tool={kind="badger", width=12}})
print(wait(5*1440))

--@ chunk 3
local G = {
  pile{{"Mars red",1},{"bone black",0.8},{"rose madder",0.3}},
  pile{{"bone black",1.3},{"cobalt violet",0.6},{"ultramarine blue",0.5}},
  pile{{"bone black",1.7},{"cobalt violet",0.5},{"magenta",0.1}},
}
local FL = {
  {1, field(42, 42, 300, 236, 11), pile{{"rose madder",1},{"cadmium red",0.6},{"Mars red",0.45},{"bone black",0.12}}},
  {1, field(48, 254, 294, 264, 12), pile{{"lead white",1.6},{"yellow ochre",0.5},{"raw sienna",0.25},{"Mars red",0.2}}},
  {1, field(42, 282, 300, 376, 13), pile{{"rose madder",1},{"Mars red",0.7},{"bone black",0.35}}},
  {2, field(371, 42, 629, 270, 14), pile{{"ultramarine blue",1},{"cerulean blue",0.25},{"lead white",0.22},{"bone black",0.3}}},
  {2, field(378, 286, 622, 292, 15), pile{{"lead white",1.4},{"cerulean blue",0.25},{"bone black",0.25}}},
  {2, field(371, 308, 629, 376, 16), pile{{"ultramarine blue",1},{"cobalt violet",0.7},{"bone black",0.7}}},
  {3, field(700, 42, 958, 282, 17), pile{{"bone black",1.4},{"cobalt violet",0.6},{"ultramarine blue",0.3},{"lead white",0.07}}},
  {3, field(764, 300, 894, 350, 18), pile{{"bone black",1.2},{"cobalt violet",0.7},{"magenta",0.12},{"lead white",0.12}}},
  {3, field(805, 362, 853, 380, 19), pile{{"bone black",1.1},{"cobalt violet",0.75},{"magenta",0.14},{"lead white",0.16}}},
}
for i = 1, 3 do
  local pm = rect(PX[i][1], PY0, PX[i][2] - PX[i][1], PY1 - PY0)
  local fs = nil
  for _, f in ipairs(FL) do if f[1] == i then fs = fs and (fs + f[2]) or f[2] end end
  work(pm:shrink(2) - fs:shrink(3), {hand="body", tool="filbert 6", pile=G[i], coverage=3.5, fill=true, angle=math.pi/2, clip=true, load=1})
end
for _, f in ipairs(FL) do
  work(f[2], {hand="body", tool="filbert 6", pile=f[3], coverage=3.5, fill=true, angle=0, clip=true, load=1})
end
-- feather: a stipple of each panel's ground across its fields' edges, then each field's own clean blend
for _, f in ipairs(FL) do
  local e = f[2]:grow(4) - f[2]:shrink(3)
  stipple(e, {pile=G[f[1]], width=2.5, coverage=0.9, feather=0.6, pressure={0.3, 0.6}})
end
for _, f in ipairs(FL) do
  blend(f[2]:grow(6) - f[2]:shrink(6), {angle=0, tool={kind="badger", width=10}})
end
print(wait(5*1440))

--@ chunk 4
local GL = {
  {field(40, 40, 302, 238, 21), pile{{"rose madder",1},{"cadmium red",0.3}, medium=0.85}},
  {field(40, 280, 302, 378, 22), pile{{"rose madder",1},{"bone brown",0.3}, medium=0.85}},
  {field(369, 40, 631, 272, 23), pile{{"ultramarine blue",1},{"cobalt violet",0.4},{"bone black",0.15}, medium=0.85}},
  {field(369, 306, 631, 378, 24), pile{{"cobalt violet",1},{"ultramarine blue",0.6}, medium=0.85}},
  {field(698, 40, 960, 284, 25), pile{{"cobalt violet",1},{"bone black",0.4},{"magenta",0.1}, medium=0.88}},
}
for _, g in ipairs(GL) do
  work(g[1], {hand="glaze", pile=g[2], coverage=1.2, fill=true, clip=true, angle=0, load=0.35, pressure={0.1, 0.25}})
  blend(g[1], {angle=0, tool={kind="badger", width=20}})
end
print(wait(6*1440))

--@ chunk 5
local f = field(700, 42, 958, 282, 31)
local vp = pile{{"bone black",1.6},{"cobalt violet",0.55},{"ultramarine blue",0.25},{"magenta",0.06}}
local g3 = pile{{"bone black",1.7},{"cobalt violet",0.5},{"magenta",0.1}}
work(f, {hand="body", tool="filbert 6", pile=vp, coverage=3.5, fill=true, angle=0, clip=true, load=1})
stipple(f:grow(4) - f:shrink(3), {pile=g3, width=2.5, coverage=0.9, feather=0.6, pressure={0.3, 0.6}})
blend(f:grow(6) - f:shrink(6), {angle=0, tool={kind="badger", width=10}})
print(wait(4*1440))
