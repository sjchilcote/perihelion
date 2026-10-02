-- easel session "friedrich": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.72, linen={18,16}, seed=1810,
  ground={{pile={{"lead white",2},{"yellow ochre",0.4},{"bone black",0.3},{"ultramarine blue",0.15}}, um=80, apply="knife", texture=0.25}}}
HZ = 452     -- sky meets the dark band
SH = 500     -- the hull's far edge
-- sky, bottom to top: pale gold, cream, cool grey, slate, blue-black
local bands = {
  {HZ - 60, HZ, pile{{"lead white",3},{"Naples"=="" and "lead white" or "yellow ochre",0.5},{"cadmium yellow",0.3}}},
  {HZ - 130, HZ - 60, pile{{"lead white",3},{"yellow ochre",0.45},{"bone black",0.05}}},
  {HZ - 210, HZ - 130, pile{{"lead white",2.2},{"yellow ochre",0.25},{"bone black",0.25},{"ultramarine blue",0.15}}},
  {HZ - 290, HZ - 210, pile{{"lead white",1.3},{"bone black",0.45},{"ultramarine blue",0.4}}},
  {HZ - 370, HZ - 290, pile{{"lead white",0.6},{"bone black",0.7},{"ultramarine blue",0.6}}},
  {-5, HZ - 370, pile{{"lead white",0.25},{"bone black",1},{"ultramarine blue",0.7}}},
}
for _, b in ipairs(bands) do
  work(rect(0, b[1], 1000, b[2] - b[1] + 6), {hand="broad", pile=b[3], coverage=3, fill=true, clip=true, angle=0, load=0.9, ruler=true})
end
blend(rect(0, 0, 1000, HZ - 2), {angle=0})
-- the dark band of space
local sea = pile{{"bone black",1.4},{"ultramarine blue",0.8},{"viridian",0.15},{"lead white",0.12}}
work(rect(0, HZ, 1000, SH - HZ), {hand="broad", pile=sea, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
-- the hull: a thin pale band of bronze
local hull = pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",1.2},{"bone black",0.15}}
work(rect(0, SH, 1000, 82), {hand="broad", pile=hull, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
print(wait(5*1440))

--@ chunk 2
local steps = {
  {{"lead white",0.25},{"bone black",1},{"ultramarine blue",0.7}},
  {{"lead white",0.4},{"bone black",0.85},{"ultramarine blue",0.65}},
  {{"lead white",0.6},{"bone black",0.7},{"ultramarine blue",0.6}},
  {{"lead white",0.9},{"bone black",0.58},{"ultramarine blue",0.5}},
  {{"lead white",1.3},{"bone black",0.45},{"ultramarine blue",0.4}},
  {{"lead white",1.7},{"bone black",0.35},{"ultramarine blue",0.28},{"yellow ochre",0.1}},
  {{"lead white",2.2},{"bone black",0.25},{"ultramarine blue",0.15},{"yellow ochre",0.25}},
  {{"lead white",2.6},{"bone black",0.12},{"yellow ochre",0.4}},
  {{"lead white",3},{"bone black",0.05},{"yellow ochre",0.45},{"cadmium yellow",0.12}},
  {{"lead white",3},{"yellow ochre",0.5},{"cadmium yellow",0.3}},
}
local h = HZ / #steps
for i, s in ipairs(steps) do
  local y0 = (i - 1) * h - 4
  work(rect(0, y0, 1000, h + 8) * rect(0, 0, 1000, HZ), {hand="broad", pile=pile(s), coverage=3, fill=true, clip=true, angle=0, load=0.9, ruler=true})
end
blend(rect(0, 0, 1000, HZ - 2), {angle=0})
blend(rect(0, 0, 1000, HZ - 2), {angle=0.03})

--@ chunk 3
print(wait(5*1440))
local hull = pile{{"lead white",1.5},{"yellow ochre",0.8},{"raw sienna",0.35},{"bone black",0.25}}
local hullD = pile{{"lead white",0.9},{"yellow ochre",0.7},{"raw sienna",0.5},{"bone black",0.4}}
work(rect(0, SH, 1000, 82), {hand="broad", pile=hull, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, 556, 1000, 30), {hand="broad", pile=hullD, coverage=2.5, fill=true, clip=true, angle=0, load=0.9, ruler=true})
blend(rect(0, SH + 2, 1000, 80), {angle=0})
print(wait(4*1440))
-- scale-plate rows: shadowed lower arcs, lit upper lips, growing toward us
local sh = pile{{"raw sienna",0.8},{"bone black",0.6},{"lead white",0.5},{"burnt sienna",0.2}}
local lit = pile{{"lead white",2.4},{"yellow ochre",0.5},{"cadmium yellow",0.1}}
local y, k = SH + 3, 0
while y < 590 do
  k = k + 1
  local h = 3 + (y - SH) * 0.16
  local w = h * 2.4
  local off = ((k * 0.618) % 1) * w
  local db = brush{kind="round", width=math.max(0.8, h * 0.18), point=0.5}
  local lb = brush{kind="round", width=math.max(0.7, h * 0.12), point=0.6}
  for cx = -w + off, 1000 + w, w do
    local pts = {}
    for i = 0, 8 do local a = math.pi * i / 8; pts[#pts+1] = {cx + (w/2) * math.cos(a), y + h * 0.5 * math.sin(a)} end
    db:reload(sh, 0.6); db:stroke(pts, {pressure={0.45, 0.45}, ramps={0.1, 0.1}})
    if math.random() < 0.7 then
      local q = {} for i = 1, 4 do q[i] = {pts[i][1] - 0.5, pts[i][2] - h * 0.25} end
      lb:reload(lit, 0.5); lb:stroke(q, {pressure={0.35, 0.05}, ramps={0.1, 0.5}})
    end
  end
  y = y + h * 0.72
end

--@ chunk 4
print(wait(3*1440))
local pale = pile{{"lead white",2.5},{"yellow ochre",0.4},{"bone black",0.12}}
work(rect(0, SH, 1000, 82), {hand="scumble", pile=pale, load=0.22, pressure={0.08, 0.25}, coverage=0.9, clip=true, angle=0})
print(wait(3*1440))
-- the Commando: tiny, back to us, a crimson rag at the shoulder
local fx, fy = 372, 534
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
local b = brush{kind="round", width=2.2, point=0.5}
local function st(br, p, pts, pr) br:reload(p, 0.8); br:stroke(pts, {pressure=pr or {0.7, 0.7}, ramps={0.03, 0.03}}) end
work(ellipse(fx, fy - 21, 2.2, 2.6), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
work(poly({{fx - 3.6, fy - 18.5}, {fx + 3.6, fy - 18.5}, {fx + 3, fy - 9}, {fx - 3, fy - 9}}), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
st(b, dk, {{fx - 1.5, fy - 9}, {fx - 1.8, fy}})
st(b, dk, {{fx + 1.5, fy - 9}, {fx + 1.9, fy}})
-- the rag, blown a little to the left
local red = pile{{"vermilion",1},{"cadmium red",0.6},{"rose madder",0.2}}
local rb = brush{kind="round", width=1.8, point=0.6}
st(rb, red, {{fx - 2.5, fy - 17}, {fx - 6, fy - 15}, {fx - 9, fy - 14.5}}, {0.65, 0.2})
st(rb, red, {{fx - 2.5, fy - 15.5}, {fx - 7, fy - 12.5}}, {0.55, 0.15})
-- a faint shadow at the feet
local sh = brush{kind="round", width=1.6, point=0.4}
st(sh, pile{{"raw sienna",0.6},{"bone black",0.6},{"lead white",0.5}}, {{fx - 4, fy + 0.8}, {fx + 6, fy + 1.2}}, {0.4, 0.3})

--@ chunk 5
local FIG = rect(358, 508, 22, 30)
local hull = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.25},{"bone black",0.22}}
local hullD = pile{{"lead white",1.4},{"yellow ochre",0.6},{"raw sienna",0.35},{"bone black",0.32}}
work(rect(0, SH, 1000, 50) - FIG, {hand="broad", pile=hull, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, 548, 1000, 40) - FIG, {hand="broad", pile=hullD, coverage=3.5, fill=true, clip=true, angle=0, load=1, ruler=true})
blend(rect(0, SH + 2, 1000, 80) - FIG:grow(4), {angle=0})
print(wait(5*1440))
local sh = pile{{"raw sienna",0.7},{"bone black",0.45},{"lead white",1},{"yellow ochre",0.3}}
local lit = pile{{"lead white",2.6},{"yellow ochre",0.4}}
local y, k = SH + 3, 0
while y < 590 do
  k = k + 1
  local h = 3 + (y - SH) * 0.16
  local w = h * rand(2.2, 2.7)
  local off = ((k * 0.618) % 1) * w
  local db = brush{kind="round", width=math.max(0.7, h * 0.12), point=0.5}
  local lb = brush{kind="round", width=math.max(0.6, h * 0.09), point=0.6}
  for cx = -w + off, 1000 + w, w do
    if math.random() < 0.55 and FIG:grow(3):at(cx, y) < 0.5 then
      local ww = w * rand(0.85, 1.1)
      local pts = {}
      for i = 0, 8 do local a = math.pi * i / 8; pts[#pts+1] = {cx + (ww/2) * math.cos(a), y + h * 0.5 * math.sin(a)} end
      db:reload(sh, 0.45); db:stroke(pts, {pressure={0.35, 0.35}, ramps={0.2, 0.2}})
      if math.random() < 0.5 then local q = {} for i = 1, 4 do q[i] = {pts[i][1] - 0.5, pts[i][2] - h * 0.22} end lb:reload(lit, 0.45); lb:stroke(q, {pressure={0.3, 0.05}, ramps={0.1, 0.5}}) end
    end
  end
  y = y + h * 0.72
end

--@ chunk 6
local hull = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.25},{"bone black",0.22}}
local hullD = pile{{"lead white",1.4},{"yellow ochre",0.6},{"raw sienna",0.35},{"bone black",0.32}}
work(rect(352, 503, 34, 45), {hand="detail", tool="round 3", pile=hull, coverage=4.5, fill=true, load=1})
work(rect(352, 548, 34, 8), {hand="detail", tool="round 3", pile=hullD, coverage=4, fill=true, load=1})
print(wait(5*1440))
local sh = pile{{"raw sienna",0.7},{"bone black",0.45},{"lead white",1},{"yellow ochre",0.3}}
local db = brush{kind="round", width=0.9, point=0.5}
for _, c in ipairs({{356, 512, 10}, {372, 520, 11}, {362, 532, 12}, {380, 540, 12}}) do
  local pts = {} for i = 0, 8 do local a = math.pi * i / 8; pts[#pts+1] = {c[1] + c[3]/2 * math.cos(a), c[2] + 2.5 * math.sin(a)} end
  db:reload(sh, 0.45); db:stroke(pts, {pressure={0.35, 0.35}, ramps={0.2, 0.2}})
end
print(wait(2*1440))
local fx, fy = 372, 534
local dk = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
local b = brush{kind="round", width=2.2, point=0.5}
local function st(br, p, pts, pr) br:reload(p, 0.8); br:stroke(pts, {pressure=pr or {0.7, 0.7}, ramps={0.03, 0.03}}) end
work(ellipse(fx, fy - 21, 2.2, 2.6), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
work(poly({{fx - 3.6, fy - 18.5}, {fx + 3.6, fy - 18.5}, {fx + 3, fy - 9}, {fx - 3, fy - 9}}), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
st(b, dk, {{fx - 1.5, fy - 9}, {fx - 1.8, fy}})
st(b, dk, {{fx + 1.5, fy - 9}, {fx + 1.9, fy}})
local red = pile{{"vermilion",1},{"cadmium red",0.6},{"rose madder",0.2}}
local rb = brush{kind="round", width=2, point=0.6}
st(rb, red, {{fx - 2.5, fy - 17}, {fx - 6.5, fy - 15}, {fx - 10, fy - 14.5}}, {0.7, 0.2})
st(rb, red, {{fx - 2.5, fy - 15.5}, {fx - 7.5, fy - 12.5}}, {0.6, 0.15})
st(brush{kind="round", width=1.6, point=0.4}, pile{{"raw sienna",0.6},{"bone black",0.6},{"lead white",0.5}}, {{fx - 4, fy + 0.8}, {fx + 6, fy + 1.2}}, {0.4, 0.3})
