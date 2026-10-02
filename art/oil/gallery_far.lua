-- easel session "gallery_far": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=6061,
  ground={{pile={{"burnt sienna",1},{"raw sienna",1},{"bone black",1},{"lead white",0.6}}, um=120, apply="knife", texture=0.4}}}
-- one camera, two halls. Y down from eye, floor at Y = 1.6
VX, VY, F = 500, 340, 500
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY = 1.6
-- HALL A (east wing, Testator bronze): pointed vault, half width 4.5, crown 7.4 m up, end wall at 26
AHW, ACROWN, AZE = 4.5, 7.4, 26
function AARCH(Z, hw, n)
  hw = hw or AHW; n = n or 14
  local t = {pt(-hw, FY, Z)}
  for i = 0, n do local u = i / n
    t[#t+1] = pt(-hw * (1 - u) ^ 1.4, FY - (2.6 + (ACROWN - 2.6) * math.sin(u * math.pi / 2) ^ 0.8), Z) end
  for i = n, 0, -1 do local u = i / n
    t[#t+1] = pt(hw * (1 - u) ^ 1.4, FY - (2.6 + (ACROWN - 2.6) * math.sin(u * math.pi / 2) ^ 0.8), Z) end
  t[#t+1] = pt(hw, FY, Z)
  return t
end
AEND = poly(AARCH(AZE))
AFLOOR = poly({pt(-AHW, FY, 0.6), pt(-AHW, FY, AZE), pt(AHW, FY, AZE), pt(AHW, FY, 0.6)}) + rect(0, 620, 1000, 60)
ARIBZ = {2.4, 3.6, 5.2, 7.3, 10.2, 14.0, 19.0}
-- HALL B (west wing, another maker): a straight-columned arcade with round arches, its axis turned 0.62 rad
TH = 0.62
function BW(u, Y, w) -- B-local (u across, w along) to world, then canvas
  local X = u * math.cos(TH) + w * math.sin(TH) - 2.2
  local Z = -u * math.sin(TH) + w * math.cos(TH) + 1.0
  return X, Y, Z
end
function bpt(u, Y, w) local X, Yy, Z = BW(u, Y, w); return pt(X, Yy, Z) end
print(W, H, P(math.sin(TH) * 1000, 0, math.cos(TH) * 1000))

--@ chunk 2
-- hall A laid in: vault and walls warm bronze-dark graded toward its glowing end; floor bronze; the end wall's gold light
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local SHELL = everywhere() - AFLOOR - AEND
local bands = {
  {0.6, 4.0, pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}},
  {4.0, 9.0, pile{{"bone black",1.0},{"burnt sienna",1},{"raw sienna",0.5}, medium=0.06}},
  {9.0, 16.0, pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}},
  {16.0, AZE, pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.2},{"lead white",0.3}, medium=0.06}},
}
for _, b in ipairs(bands) do
  local outer = (b[1] <= 0.6) and everywhere() or poly(AARCH(b[1]))
  local m = (outer - poly(AARCH(b[2]))) * SHELL
  work(m, {hand="body", tool="filbert 9", pile=b[3], coverage=4, fill=true, clip=m, angle=toVP, load=1})
  local f = AFLOOR * poly({pt(-9, FY, b[1]), pt(9, FY, b[1]), pt(9, FY, b[2]), pt(-9, FY, b[2])})
  work(f, {hand="body", tool="filbert 9", pile=b[3], coverage=4, fill=true, clip=f, angle=toVP, load=1})
end
local e1 = pile{{"lead white",2},{"yellow ochre",1},{"cadmium yellow",0.3}, medium=0.05}
local e2 = pile{{"lead white",3},{"cadmium yellow",0.3},{"zinc white",0.5}, medium=0.05}
work(AEND, {hand="body", tool="filbert 4", pile=e1, coverage=4, fill=true, clip=AEND, angle=math.pi/2, load=1})
local core = ellipse(VX, VY - 6, 14, 22) * AEND
work(core, {hand="detail", pile=e2, coverage=4, fill=true, clip=core, load=1})
-- bone runner down hall A
ARUN = poly({pt(-0.45, FY, 0.8), pt(-0.45, FY, AZE), pt(0.45, FY, AZE), pt(0.45, FY, 0.8)})
work(ARUN, {hand="body", tool="filbert 5", pile=pile{{"lead white",1.4},{"yellow ochre",0.6},{"raw sienna",0.3},{"bone black",0.2}, medium=0.06}, coverage=4, fill=true, clip=ARUN, angle=toVP, load=1})

--@ chunk 3
-- hall A's ribs on set paint, at the band seams; a warm lit inner lip on each; the wall-floor line
print(wait(3*24*60))
ARIBZ = {2.4, 4.0, 5.9, 9.0, 12.4, 16.0, 20.5}
local rd = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.06}
local function seg(pts, w, pl, ld, pr, clipm)
  for j = 1, #pts - 1, 3 do
    local s = {}
    for q = j, math.min(j + 3, #pts) do s[#s+1] = pts[q] end
    if #s >= 2 then
      local b = brush{kind="round", width=w, stiffness=0.6, point=0.2}
      b:load(pl, ld); b:stroke(s, {pressure=pr, ramps={0.02, 0.02}, clip=clipm})
    end
  end
end
for i = #ARIBZ, 1, -1 do
  local Z = ARIBZ[i]
  local t = (i - 1) / (#ARIBZ - 1)
  seg(AARCH(Z), math.max(1.5, 0.32 * F / Z), rd, 1, {0.95, 0.95}, -AFLOOR)
  local lip = pile{{"lead white", lerp(0.8, 2, t)}, {"yellow ochre", 1}, {"Mars orange", 0.2}, {"burnt sienna", lerp(0.4, 0.05, t)}, medium=0.06}
  seg(AARCH(Z + 0.06, AHW - 0.2), math.max(0.8, 0.06 * F / Z), lip, 0.85, {0.6, 0.6}, -AFLOOR)
end
-- the wall-floor lines
local b = brush{kind="round", width=2.5, stiffness=0.6}
b:load(rd, 1); b:stroke({pt(-AHW, FY, 0.9), pt(-AHW, FY, AZE)}, {pressure={0.9, 0.5}})
b:load(rd, 1); b:stroke({pt(AHW, FY, 0.9), pt(AHW, FY, AZE)}, {pressure={0.9, 0.5}})

--@ chunk 4
-- HALL B: slender pale columns, round arches, a cold light from its own far end. Far to near.
print(wait(1*24*60))
BU, BH = 2.8, 5.2
BWS = {3.4, 6.4, 9.6, 13.0, 16.6, 20.4, 24.4, 28.6}
-- its far end: a round-arched opening full of cold light, standing in hall A's right wall
local endp = {}
for i = 0, 20 do local a = math.pi * i / 20; endp[#endp+1] = bpt(-BU * math.cos(a), FY - BH - BU * math.sin(a), 33) end
endp[#endp+1] = bpt(BU, FY, 33); table.insert(endp, 1, bpt(-BU, FY, 33))
BEND = poly(endp)
local c1 = pile{{"zinc white",2},{"cerulean blue",0.35},{"viridian",0.1},{"lead white",0.5}, medium=0.05}
local c0 = pile{{"zinc white",1},{"cerulean blue",0.5},{"ultramarine ash",0.6},{"bone black",0.3}, medium=0.05}
work(BEND, {hand="body", tool="filbert 3", pile=c0, coverage=4, fill=true, clip=BEND, angle=math.pi/2, load=1})
local bc = ellipse(P(select(1, BW(0, 0, 33)), 0, select(3, BW(0, 0, 33))), VY - 2, 9, 16) * BEND
work(bc, {hand="detail", pile=c1, coverage=4, fill=true, clip=bc, load=1})
BCOLS = {}
local sD = pile{{"ultramarine ash",1},{"bone black",0.8},{"zinc white",0.5},{"viridian",0.12}, medium=0.06}
local sM = pile{{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.3},{"viridian",0.1}, medium=0.06}
local sL = pile{{"zinc white",2},{"cerulean blue",0.3},{"viridian",0.06}, medium=0.05}
local function seg(pts, w, pl, pr)
  for j = 1, #pts - 1, 3 do
    local s = {}
    for q = j, math.min(j + 3, #pts) do s[#s+1] = pts[q] end
    if #s >= 2 then local b = brush{kind="round", width=w, stiffness=0.6}; b:load(pl, 1); b:stroke(s, {pressure=pr, ramps={0.02, 0.02}}) end
  end
end
for i = #BWS, 1, -1 do
  local w = BWS[i]
  local _, _, Zm = BW(0, 0, w)
  -- transverse round arch across the hall, at this column pair
  local ta = {}
  for j = 0, 24 do local a = math.pi * j / 24; ta[#ta+1] = bpt(-BU * math.cos(a), FY - BH - BU * math.sin(a), w) end
  seg(ta, math.max(1.2, 0.26 * F / Zm), sD, {0.9, 0.9})
  local tl = {}
  for j = 0, 24 do local a = math.pi * j / 24; tl[#tl+1] = bpt(-(BU - 0.1) * math.cos(a), FY - BH - (BU - 0.1) * math.sin(a), w + 0.12) end
  seg(tl, math.max(0.7, 0.05 * F / Zm), sL, {0.55, 0.55})
  -- arcade arches along each side, to the next column
  if i < #BWS then
    for _, u in ipairs{-BU, BU} do
      local aa = {}
      local w2 = BWS[i + 1]
      local r = (w2 - w) / 2
      for j = 0, 12 do local a = math.pi * j / 12; aa[#aa+1] = bpt(u, FY - BH - r * 0.8 * math.sin(a), w + r - r * math.cos(a)) end
      seg(aa, math.max(1, 0.2 * F / Zm), sD, {0.85, 0.85})
    end
  end
  -- the two columns
  for _, u in ipairs{-BU, BU} do
    local _, _, Z = BW(u, 0, w)
    if Z > 0.8 then
      local base, top = bpt(u, FY, w), bpt(u, FY - BH, w)
      local cw = 0.36 * F / Z
      local m = ribbon({top, base}, cw)
      work(m, {hand="body", tool={kind="filbert", width=math.max(1.2, cw * 0.5)}, pile=sM, coverage=4, fill=true, clip=m, angle=math.pi/2, load=1})
      local sh = ribbon({{top[1] - cw * 0.25, top[2]}, {base[1] - cw * 0.25, base[2]}}, cw * 0.5) * m
      work(sh, {hand="detail", pile=sD, coverage=4, fill=true, clip=sh, load=1})
      -- the cold light from its far end, on the column's right edge
      local rb = brush{kind="round", width=math.max(0.8, cw * 0.14), point=0.4}
      rb:load(sL, 0.9)
      rb:stroke({{top[1] + cw * 0.36, top[2]}, {base[1] + cw * 0.36, base[2]}}, {pressure={0.75, 0.4}})
      -- capital and plinth: plain cool blocks
      local cap = rect(top[1] - cw * 0.85, top[2] - cw * 0.5, cw * 1.7, cw * 0.5)
      work(cap, {hand="detail", pile=sM, coverage=4, fill=true, clip=cap, load=1})
      local pl = rect(base[1] - cw * 0.75, base[2] - cw * 0.6, cw * 1.5, cw * 0.6)
      work(pl, {hand="detail", pile=sD, coverage=4, fill=true, clip=pl, load=1})
      BCOLS[#BCOLS+1] = {Z=Z, m=m + cap + pl, x=base[1], y=base[2], cw=cw}
    end
  end
end
print(#BCOLS)

--@ chunk 5
-- hall A's floor: a warm sheen from its end down both sides of the runner, the near step softened; plinth undersides squared
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fl = AFLOOR - ARUN
local colm = nil
for _, c in ipairs(BCOLS) do colm = colm and (colm + c.m) or c.m end
BCOLM = colm
fl = fl - colm:grow(2)
local s1 = pile{{"raw sienna",1},{"yellow ochre",0.9},{"burnt sienna",0.6},{"lead white",0.45},{"bone black",0.15}, medium=0.06}
local s2 = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone black",0.6},{"yellow ochre",0.25}, medium=0.06}
local s3 = pile{{"bone black",1.2},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local yA, yB = select(2, P(0, FY, 9)), select(2, P(0, FY, 4.5))
work(fl * above(function(x) return yA end), {hand="body", tool="filbert 5", pile=s1, coverage=4, fill=true, clip=fl, angle=toVP, load=1})
work(fl * below(function(x) return yA end) * above(function(x) return yB end), {hand="body", tool="filbert 7", pile=s2, coverage=4, fill=true, clip=fl, angle=toVP, load=1})
work(fl * below(function(x) return yB end), {hand="body", tool="filbert 9", pile=s3, coverage=4, fill=true, clip=fl, angle=toVP, load=1})
blend(fl * rect(0, yA - 5, 1000, 10), {angle=0})
blend(fl * rect(0, yB - 8, 1000, 16), {angle=0})

--@ chunk 6
-- the furniture of both halls, far to near. A: bronze pedestal chairs with egg backs facing its gold end.
-- B: straight pale chairs on four legs facing its cold end. Each lit only by its own hall's light.
print(wait(2*24*60))
local function frontcols(Z) local m = nil; for _, c in ipairs(BCOLS) do if c.Z < Z then m = m and (m + c.m) or c.m end end; return m end
local aD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.06}
local aM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}
local aRim = pile{{"lead white",1.6},{"yellow ochre",1},{"cadmium yellow",0.2}, medium=0.06}
local bM = pile{{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.4},{"viridian",0.08}, medium=0.06}
local bD = pile{{"ultramarine ash",1},{"bone black",0.9},{"zinc white",0.3}, medium=0.06}
local bRim = pile{{"zinc white",2},{"cerulean blue",0.3}, medium=0.05}
local items = {}
for _, Z in ipairs{13.5, 10.6, 8.2, 6.1, 4.4} do
  for _, X in ipairs{-3.3, -2.3, -1.3, 1.3, 2.3, 3.3} do
    items[#items+1] = {kind="A", X=X + 0.07 * math.sin(Z * 2.1 + X * 3), Z=Z}
  end
end
for _, q in ipairs{{-1.2, 18}, {1.2, 18}, {-1.2, 14.5}, {1.2, 14.5}, {-1.2, 11}, {1.2, 11}, {-1.2, 7.8}, {1.2, 7.8}} do
  local X, _, Z = BW(q[1], 0, q[2])
  if Z > 2.5 then items[#items+1] = {kind="B", X=X, Z=Z, u=q[1], w=q[2]} end
end
table.sort(items, function(a, b) return a.Z > b.Z end)
local function st(pts, pl, w, pr, kind, clipm)
  local b = brush{kind=kind or "round", width=w, stiffness=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
local n = 0
for _, it in ipairs(items) do
  local k = F / it.Z
  local fc = frontcols(it.Z)
  local clipm = fc and (everywhere() - fc) or nil
  if it.kind == "A" then
    local bx, by = P(it.X, FY, it.Z)
    local m = ellipse(bx, by - 1.05 * k, 0.27 * k, 0.45 * k) + rect(bx - 0.03 * k, by - 0.6 * k, 0.06 * k, 0.6 * k)
      + ellipse(bx, by - 0.5 * k, 0.33 * k, 0.06 * k) + ellipse(bx, by, 0.2 * k, 0.04 * k)
    if clipm then m = m * clipm end
    work(m, {hand="detail", pile=aD, coverage=5, fill=true, clip=m, load=1})
    local back = ellipse(bx, by - 1.05 * k, 0.24 * k, 0.42 * k) * m
    work(back - rect(bx - 0.3 * k, 0, 0.3 * k + 0.14 * k, 1000), {hand="detail", pile=aM, coverage=4, fill=true, clip=back, load=1})
    -- the gold rim of its own hall's light on the crown of the back and the seat lip
    local pts = {}
    for j = 0, 8 do local a = math.pi * (1.2 + 0.6 * j / 8); pts[#pts+1] = {bx + 0.25 * k * math.cos(a), by - 1.05 * k + 0.43 * k * math.sin(a)} end
    st(pts, aRim, math.max(0.7, 0.03 * k), {0.4, 0.4}, "round", m)
    st({{bx - 0.3 * k, by - 0.53 * k}, {bx + 0.3 * k, by - 0.53 * k}}, aRim, math.max(0.6, 0.02 * k), {0.3, 0.3}, "round", m)
  else
    -- a chair of B, square to B's axis: seat block, tall straight back, four legs
    local function C(du, Y, dw) return bpt(it.u + du, FY - Y, it.w + dw) end
    local seat = poly({C(-0.24, 0.48, -0.22), C(0.24, 0.48, -0.22), C(0.24, 0.48, 0.22), C(-0.24, 0.48, 0.22)})
    local back = poly({C(-0.24, 0.48, 0.2), C(0.24, 0.48, 0.2), C(0.22, 1.55, 0.22), C(-0.22, 1.55, 0.22)})
    local legs = nil
    for _, q in ipairs{{-0.22, -0.2}, {0.22, -0.2}, {-0.22, 0.2}, {0.22, 0.2}} do
      local r = ribbon({C(q[1], 0, q[2]), C(q[1], 0.48, q[2])}, math.max(0.8, 0.03 * k))
      legs = legs and (legs + r) or r
    end
    local m = seat + back + legs
    if clipm then m = m * clipm end
    work(m, {hand="detail", pile=bD, coverage=5, fill=true, clip=m, load=1})
    work(back * m, {hand="detail", pile=bM, coverage=4, fill=true, clip=back * m, load=1})
    -- the cold light from B's end on the edges facing it
    st({C(0.22, 1.55, 0.22), C(0.24, 0.5, 0.2)}, bRim, math.max(0.7, 0.03 * k), {0.6, 0.5}, "round", m)
    st({C(-0.22, 1.55, 0.22), C(0.22, 1.55, 0.22)}, bRim, math.max(0.6, 0.02 * k), {0.5, 0.5}, "round", m)
    st({C(-0.24, 0.48, -0.22), C(0.24, 0.48, -0.22)}, bRim, math.max(0.6, 0.02 * k), {0.3, 0.3}, "round", m)
  end
  n = n + 1
end
print(n)

--@ chunk 7
-- hall A's chair backs went violet (mid laid into the wet dark): repaint warm, then their gold rims; the Commando, of hall A
print(wait(3*24*60))
local function frontcols(Z) local m = nil; for _, c in ipairs(BCOLS) do if c.Z < Z then m = m and (m + c.m) or c.m end end; return m end
local warm = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.7},{"Mars brown",0.3}, medium=0.06}
local aRim = pile{{"lead white",1.6},{"yellow ochre",1},{"cadmium yellow",0.25}, medium=0.06}
local items = {}
for _, Z in ipairs{13.5, 10.6, 8.2, 6.1, 4.4} do
  for _, X in ipairs{-3.3, -2.3, -1.3, 1.3, 2.3, 3.3} do items[#items+1] = {X=X + 0.07 * math.sin(Z * 2.1 + X * 3), Z=Z} end
end
for _, it in ipairs(items) do
  local k = F / it.Z
  local bx, by = P(it.X, FY, it.Z)
  local fc = frontcols(it.Z)
  local back = ellipse(bx, by - 1.05 * k, 0.25 * k, 0.43 * k)
  for _, it2 in ipairs(items) do if it2.Z < it.Z then local k2 = F / it2.Z; local x2, y2 = P(it2.X, FY, it2.Z); back = back - ellipse(x2, y2 - 1.05 * k2, 0.28 * k2, 0.46 * k2) end end
  if fc then back = back - fc end
  work(back, {hand="detail", pile=warm, coverage=5, fill=true, clip=back, load=1})
  local pts = {}
  for j = 0, 8 do local a = math.pi * (1.15 + 0.7 * j / 8); pts[#pts+1] = {bx + 0.235 * k * math.cos(a), by - 1.05 * k + 0.415 * k * math.sin(a)} end
  local b = brush{kind="round", width=math.max(0.8, 0.035 * k), point=0.5}
  b:load(aRim, 0.9); b:stroke(pts, {pressure={0.5, 0.5}, clip=back})
  local sb = brush{kind="round", width=math.max(0.6, 0.02 * k), point=0.5}
  sb:load(aRim, 0.8); sb:stroke({{bx + 0.2 * k, by - 0.85 * k}, {bx + 0.235 * k, by - 1.15 * k}}, {pressure={0.4, 0.4}, clip=back})
end
-- the Commando on hall A's runner, walking toward its gold end; lit only by it
local Z = 7.0
local k = F / Z
local fx, fy = P(0.05, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.1,0.93), Q(-0.12,0.52), Q(-0.1,0.14)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.1,0.93), Q(0.13,0.5), Q(0.18,0.2)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.22,0.06), Q(-0.02,0.06), Q(-0.03,0.19), Q(-0.2,0.19)}) + poly({Q(0.1,0.0), Q(0.28,0.03), Q(0.26,0.22), Q(0.12,0.2)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.36,1.24), Q(-0.37,0.98)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.3,1.5), Q(0.35,1.24), Q(0.31,1.0)}, {0.12*k, 0.1*k, 0.09*k})
local fc = frontcols(Z)
if fc then fig = fig - fc end
GFIG, GK, GX, GY = fig, k, fx, fy
-- his shadow, thrown toward us by hall A's end light, along the runner
local sh = poly({pt(-0.18, FY, Z), pt(0.28, FY, Z), pt(0.45, FY, 2.2), pt(-0.4, FY, 2.2)}, true) * AFLOOR - fig
if fc then sh = sh - fc end
work(sh, {hand="body", tool="filbert 5", pile=pile{{"bone black",1.5},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}, coverage=4, fill=true, clip=sh, angle=math.pi/2, load=1})
work(fig, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.2}, medium=0.06}, coverage=5, fill=true, clip=fig, load=1})
print(fx, fy, k)

--@ chunk 8
-- the Commando's gold rim from his hall's end; his shadow narrowed (runner restated either side); hall B's floor joints, cold
print(wait(2*24*60))
local k, fx, fy = GK, GX, GY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local hot = pile{{"lead white",2.5},{"cadmium yellow",0.3},{"yellow ochre",0.2}, medium=0.05}
local warm = pile{{"lead white",1.5},{"yellow ochre",1},{"Mars orange",0.2}, medium=0.06}
local function ln(pts, pl, w, pr)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(pl, 0.85); b:stroke(pts, {pressure=pr, clip=GFIG})
end
ln({Q(-0.09,1.86), Q(0,1.895), Q(0.09,1.86), Q(0.1,1.76)}, hot, 1.8, {0.8, 0.6})
ln({Q(-0.39,1.55), Q(-0.3,1.615), Q(-0.12,1.6)}, hot, 1.8, {0.6, 0.8})
ln({Q(0.12,1.6), Q(0.3,1.615), Q(0.39,1.55)}, hot, 1.8, {0.8, 0.6})
ln({Q(-0.39,1.45), Q(-0.42,1.2), Q(-0.41,1.0)}, warm, 1.4, {0.7, 0.2})
ln({Q(0.38,1.45), Q(0.4,1.2), Q(0.36,1.0)}, warm, 1.4, {0.7, 0.2})
ln({Q(-0.2,0.9), Q(-0.21,0.5), Q(-0.18,0.2)}, warm, 1.1, {0.5, 0.1})
ln({Q(0.2,0.9), Q(0.22,0.5), Q(0.27,0.22)}, warm, 1.1, {0.5, 0.1})
-- runner either side of a narrower shadow
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local narrow = poly({pt(-0.12, FY, 7.0), pt(0.22, FY, 7.0), pt(0.3, FY, 1.0), pt(-0.3, FY, 1.0)})
local sides = ARUN * below(function(x) return fy end) - narrow - BCOLM
work(sides, {hand="body", tool="filbert 4", pile=pile{{"lead white",1.2},{"yellow ochre",0.6},{"raw sienna",0.4},{"bone black",0.3}, medium=0.06}, coverage=5, fill=true, clip=sides, angle=toVP, load=1})
-- hall B's floor: cold joint lines along its axis and across, only its own (they do not touch A's chairs)
local cj = pile{{"zinc white",1.5},{"ultramarine ash",0.8},{"cerulean blue",0.2},{"bone black",0.2}, medium=0.05}
local keep = BCOLM:grow(1) + GFIG:grow(1)
local floorB = AFLOOR * below(function(x) return 470 end) - keep
for _, u in ipairs{-1.8, -0.6, 0.6, 1.8} do
  local b = brush{kind="round", width=1.1, point=0.4}
  b:load(cj, 0.8); b:stroke({bpt(u, FY, 0.6), bpt(u, FY, 6.0)}, {pressure={0.6, 0.3}, clip=floorB})
end
for _, w in ipairs{1.2, 2.2, 3.4, 4.8} do
  local b = brush{kind="round", width=1.0, point=0.4}
  b:load(cj, 0.8); b:stroke({bpt(-2.8, FY, w), bpt(2.8, FY, w)}, {pressure={0.4, 0.4}, clip=floorB})
end

--@ chunk 9
-- hall B's chairs standing in hall A's aisle, nearer than the Commando; -- the furniture of both halls, far to near. A: bronze pedestal chairs with egg backs facing its gold end.
-- B: straight pale chairs on four legs facing its cold end. Each lit only by its own hall's light.
print(wait(2*24*60))
local function frontcols(Z) local m = nil; for _, c in ipairs(BCOLS) do if c.Z < Z then m = m and (m + c.m) or c.m end end; return m end
local aD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.06}
local aM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}
local aRim = pile{{"lead white",1.6},{"yellow ochre",1},{"cadmium yellow",0.2}, medium=0.06}
local bM = pile{{"zinc white",1},{"ultramarine ash",0.8},{"bone black",0.4},{"viridian",0.08}, medium=0.06}
local bD = pile{{"ultramarine ash",1},{"bone black",0.9},{"zinc white",0.3}, medium=0.06}
local bRim = pile{{"zinc white",2},{"cerulean blue",0.3}, medium=0.05}
local items = {}
for _, q in ipairs{{-1.2, 4.6}, {1.2, 4.6}, {0.0, 6.2}} do
  local X, _, Z = BW(q[1], 0, q[2])
  if Z > 2.5 then items[#items+1] = {kind="B", X=X, Z=Z, u=q[1], w=q[2]} end
end
table.sort(items, function(a, b) return a.Z > b.Z end)
local function st(pts, pl, w, pr, kind, clipm)
  local b = brush{kind=kind or "round", width=w, stiffness=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
local n = 0
for _, it in ipairs(items) do
  local k = F / it.Z
  local fc = frontcols(it.Z)
  local clipm = fc and (everywhere() - fc) or nil
  if it.kind == "A" then
    local bx, by = P(it.X, FY, it.Z)
    local m = ellipse(bx, by - 1.05 * k, 0.27 * k, 0.45 * k) + rect(bx - 0.03 * k, by - 0.6 * k, 0.06 * k, 0.6 * k)
      + ellipse(bx, by - 0.5 * k, 0.33 * k, 0.06 * k) + ellipse(bx, by, 0.2 * k, 0.04 * k)
    if clipm then m = m * clipm end
    work(m, {hand="detail", pile=aD, coverage=5, fill=true, clip=m, load=1})
    local back = ellipse(bx, by - 1.05 * k, 0.24 * k, 0.42 * k) * m
    work(back - rect(bx - 0.3 * k, 0, 0.3 * k + 0.14 * k, 1000), {hand="detail", pile=aM, coverage=4, fill=true, clip=back, load=1})
    -- the gold rim of its own hall's light on the crown of the back and the seat lip
    local pts = {}
    for j = 0, 8 do local a = math.pi * (1.2 + 0.6 * j / 8); pts[#pts+1] = {bx + 0.25 * k * math.cos(a), by - 1.05 * k + 0.43 * k * math.sin(a)} end
    st(pts, aRim, math.max(0.7, 0.03 * k), {0.4, 0.4}, "round", m)
    st({{bx - 0.3 * k, by - 0.53 * k}, {bx + 0.3 * k, by - 0.53 * k}}, aRim, math.max(0.6, 0.02 * k), {0.3, 0.3}, "round", m)
  else
    -- a chair of B, square to B's axis: seat block, tall straight back, four legs
    local function C(du, Y, dw) return bpt(it.u + du, FY - Y, it.w + dw) end
    local seat = poly({C(-0.24, 0.48, -0.22), C(0.24, 0.48, -0.22), C(0.24, 0.48, 0.22), C(-0.24, 0.48, 0.22)})
    local back = poly({C(-0.24, 0.48, 0.2), C(0.24, 0.48, 0.2), C(0.22, 1.55, 0.22), C(-0.22, 1.55, 0.22)})
    local legs = nil
    for _, q in ipairs{{-0.22, -0.2}, {0.22, -0.2}, {-0.22, 0.2}, {0.22, 0.2}} do
      local r = ribbon({C(q[1], 0, q[2]), C(q[1], 0.48, q[2])}, math.max(0.8, 0.03 * k))
      legs = legs and (legs + r) or r
    end
    local m = seat + back + legs
    if clipm then m = m * clipm end
    work(m, {hand="detail", pile=bD, coverage=5, fill=true, clip=m, load=1})
    work(back * m, {hand="detail", pile=bM, coverage=4, fill=true, clip=back * m, load=1})
    -- the cold light from B's end on the edges facing it
    st({C(0.22, 1.55, 0.22), C(0.24, 0.5, 0.2)}, bRim, math.max(0.7, 0.03 * k), {0.6, 0.5}, "round", m)
    st({C(-0.22, 1.55, 0.22), C(0.22, 1.55, 0.22)}, bRim, math.max(0.6, 0.02 * k), {0.5, 0.5}, "round", m)
    st({C(-0.24, 0.48, -0.22), C(0.24, 0.48, -0.22)}, bRim, math.max(0.6, 0.02 * k), {0.3, 0.3}, "round", m)
  end
  n = n + 1
end
print(n)

--@ chunk 10
-- runner edges dimmed toward us (they're far from hall A's light); the nearest column's flank given its cold rim and a dark core
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local narrow = poly({pt(-0.12, FY, 7.0), pt(0.22, FY, 7.0), pt(0.3, FY, 1.0), pt(-0.3, FY, 1.0)})
local sides = ARUN - narrow - BCOLM:grow(1) - GFIG
local yM = select(2, P(0, FY, 3.2))
local s1 = sides * below(function(x) return yM end)
local s0 = sides * above(function(x) return yM end) * below(function(x) return GY end)
work(s1, {hand="body", tool="filbert 5", pile=pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.6},{"yellow ochre",0.4},{"lead white",0.25}, medium=0.06}, coverage=5, fill=true, clip=s1, angle=toVP, load=1})
work(s0, {hand="body", tool="filbert 4", pile=pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.6},{"burnt sienna",0.3}, medium=0.06}, coverage=5, fill=true, clip=s0, angle=toVP, load=1})
blend(sides * rect(0, yM - 8, 1000, 16), {angle=math.pi/2})
-- the nearest columns: a dark core down their shadow side, a crisp cold edge toward hall B's light
local sL = pile{{"zinc white",2},{"cerulean blue",0.35}, medium=0.05}
local sK = pile{{"ultramarine ash",1},{"bone black",1.2},{"zinc white",0.2}, medium=0.06}
for _, c in ipairs(BCOLS) do
  if c.Z < 4 then
    local cw = c.cw
    local core = c.m * rect(c.x - cw * 0.35, 0, cw * 0.3, c.y)
    work(core, {hand="body", tool={kind="filbert", width=math.max(2, cw * 0.25)}, pile=sK, coverage=4, fill=true, clip=core, angle=math.pi/2, load=1})
    local b = brush{kind="round", width=math.max(1, cw * 0.06), point=0.4}
    b:load(sL, 0.9); b:stroke({{c.x + cw * 0.44, 0}, {c.x + cw * 0.44, c.y - cw * 0.6}}, {pressure={0.8, 0.5}, clip=c.m})
  end
end
