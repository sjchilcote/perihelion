-- easel session "outpost_ext": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=4242,
  ground={{pile={{"bone black",2},{"burnt sienna",1},{"raw sienna",0.6},{"lead white",0.5}}, um=90, apply="knife", texture=0.3}}}
function yL(x) return 230 - 190 * (clamp(x, 0, 1000) / 1000)^0.8 end
local limb = {}
for x = -10, 1010, 20 do limb[#limb + 1] = {x, yL(x)} end
hullM = below(limb)
spaceM = above(limb)
local spaceP = pile{{"bone black",2},{"ultramarine blue",1.2},{"cobalt blue",0.3}}
local hullP = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.8}}
work(spaceM, {hand="body", pile=spaceP, coverage=3.5, fill=true, angle=0.2, clip=true, load=1})
work(hullM, {hand="body", pile=hullP, coverage=3.5, fill=true, angle=-0.15, clip=true, load=1})
print(wait(5*1440))

--@ chunk 2
B = {
  pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",1}},
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
  pile{{"bone black",1.5},{"raw sienna",1},{"viridian",0.4},{"yellow ochre",0.3}},
  pile{{"bone black",2},{"bone brown",1},{"raw sienna",0.5}},
}
SHEEN = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.5}}
GOLD = pile{{"yellow ochre",2},{"lead white",1},{"raw sienna",0.5}}
HOT = pile{{"lead white",2},{"Mars yellow",1},{"yellow ochre",0.5}}
SHD = pile{{"bone black",2},{"bone brown",1}}
VERD = pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
function rowsList()
  local rows, d, k = {}, 3, 0
  while d < 540 do
    k = k + 1
    local h = 5 + 0.12 * d
    rows[#rows + 1] = {d = d, h = h, w = 1.35 * h, k = k}
    d = d + h * 0.72
  end
  return rows
end
function plate(cx, cy, w, h, sl, light)
  local fb = brush{kind="filbert", width=math.max(1.5, h * 0.8)}
  local r = math.random()
  local p = (r < 0.5) and B[1] or ((r < 0.78) and B[4] or ((r < 0.92) and B[2] or B[3]))
  local x0, x1 = cx - w/2 + h*0.3, cx + w/2 - h*0.3
  fb:reload(p, 0.8)
  fb:stroke({{x0, cy + sl*(x0-cx)}, {x1, cy + sl*(x1-cx)}}, {pressure={0.7, 0.7}, ramps={0.1,0.1}})
  -- sheen on the sunward half
  local sb = brush{kind="filbert", width=math.max(1.2, h * 0.45)}
  sb:reload(SHEEN, 0.5 * light)
  local xs = cx + w*0.05
  sb:stroke({{xs, cy + h*0.1 + sl*(xs-cx)}, {x1 + h*0.1, cy + h*0.12 + sl*(x1-cx)}}, {pressure={0.45, 0.35}, ramps={0.3,0.2}})
  -- lower rounded edge
  local edge = {}
  for i = 0, 10 do local a = math.pi * i / 10; local ex = cx + (w/2) * math.cos(a); edge[#edge+1] = {ex, cy + (h/2) * math.sin(a) + sl*(ex-cx)} end
  if h > 9 then
    local db = brush{kind="round", width=math.max(1, h * 0.12), point=0.4}
    local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1], e[2] + h*0.05} end
    db:reload(SHD, 0.7); db:stroke(sh, {pressure={0.55, 0.55}, ramps={0.1,0.1}})
  end
  -- raking rim: right flank of the bulge
  local rb = brush{kind="round", width=math.max(0.9, h * 0.09), point=0.6}
  local rim = {} for i = 1, 5 do rim[i] = {edge[i][1] - h*0.06, edge[i][2] - h*0.07} end
  rb:reload((light > 0.75) and HOT or GOLD, 0.6)
  rb:stroke(rim, {pressure={0.55 * light + 0.15, 0.1}, ramps={0.05, 0.6}})
end
function paintRows(dmin, dmax, x0, x1)
  local rows = rowsList()
  local n = 0
  for i = #rows, 1, -1 do
    local R = rows[i]
    if R.d >= dmin and R.d < dmax then
      local off = ((R.k * 0.618) % 1) * R.w
      for cx = -R.w + off, 1000 + R.w, R.w do
        if cx > x0 - R.w and cx < x1 + R.w then
          local cy = yL(cx) + R.d
          if cy - R.h < 570 then
            local sl = (yL(cx + 5) - yL(cx - 5)) / 10
            local light = clamp(0.45 + 0.4 * (cx / 1000) + 0.25 * (1 - R.d / 540) + rand(-0.15, 0.15), 0.2, 1)
            plate(cx, cy, R.w * rand(0.95, 1.05), R.h, sl, light)
            n = n + 1
          end
        end
      end
    end
  end
  return n
end
print(paintRows(250, 600, 0, 1000))

--@ chunk 3
B = {
  pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",1}},
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
  pile{{"bone black",1.5},{"raw sienna",1},{"viridian",0.4},{"yellow ochre",0.3}},
  pile{{"bone black",2},{"bone brown",1},{"raw sienna",0.5}},
}
SHEEN = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.5}}
GOLD = pile{{"yellow ochre",2},{"lead white",1},{"raw sienna",0.5}}
HOT = pile{{"lead white",2},{"Mars yellow",1},{"yellow ochre",0.5}}
SHD = pile{{"bone black",2},{"bone brown",1}}
VERD = pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
function rowsList()
  local rows, d, k = {}, 3, 0
  while d < 540 do
    k = k + 1
    local h = 5 + 0.12 * d
    rows[#rows + 1] = {d = d, h = h, w = 1.35 * h, k = k}
    d = d + h * 0.72
  end
  return rows
end
function plate(cx, cy, w, h, sl, light)
  local fb = brush{kind="filbert", width=math.max(1.5, h * 0.8)}
  local r = math.random()
  local p = (r < 0.5) and B[1] or ((r < 0.78) and B[4] or ((r < 0.92) and B[2] or B[3]))
  local x0, x1 = cx - w/2 + h*0.3, cx + w/2 - h*0.3
  fb:reload(p, 0.8)
  fb:stroke({{x0, cy + sl*(x0-cx)}, {x1, cy + sl*(x1-cx)}}, {pressure={0.7, 0.7}, ramps={0.1,0.1}})
  -- lower rounded edge
  local edge = {}
  for i = 0, 10 do local a = math.pi * i / 10; local ex = cx + (w/2) * math.cos(a); edge[#edge+1] = {ex, cy + (h/2) * math.sin(a) + sl*(ex-cx)} end
  if h > 9 then
    local db = brush{kind="round", width=math.max(1, h * 0.12), point=0.4}
    local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1], e[2] + h*0.05} end
    db:reload(SHD, 0.7); db:stroke(sh, {pressure={0.55, 0.55}, ramps={0.1,0.1}})
  end
  -- sheen: a soft band inside the sunward flank
  local sb = brush{kind="filbert", width=math.max(1.2, h * 0.28)}
  local sh2 = {} for i = 1, 6 do sh2[i] = {edge[i][1] - h*0.16 - w*0.04, edge[i][2] - h*0.2} end
  sb:reload(SHEEN, 0.45 * light)
  sb:stroke(sh2, {pressure={0.4, 0.15}, ramps={0.1,0.5}})
  -- raking rim: right flank of the bulge
  local rb = brush{kind="round", width=math.max(0.9, h * 0.09), point=0.6}
  local rim = {} for i = 1, 5 do rim[i] = {edge[i][1] - h*0.06, edge[i][2] - h*0.07} end
  rb:reload((light > 0.75) and HOT or GOLD, 0.6)
  rb:stroke(rim, {pressure={0.55 * light + 0.15, 0.1}, ramps={0.05, 0.6}})
end
function paintRows(dmin, dmax, x0, x1)
  local rows = rowsList()
  local n = 0
  for i = #rows, 1, -1 do
    local R = rows[i]
    if R.d >= dmin and R.d < dmax then
      local off = ((R.k * 0.618) % 1) * R.w
      for cx = -R.w + off, 1000 + R.w, R.w do
        if cx > x0 - R.w and cx < x1 + R.w then
          local cy = yL(cx) + R.d
          if cy - R.h < 570 then
            local sl = (yL(cx + 5) - yL(cx - 5)) / 10
            local light = clamp(0.45 + 0.4 * (cx / 1000) + 0.25 * (1 - R.d / 540) + rand(-0.15, 0.15), 0.2, 1)
            plate(cx, cy, R.w * rand(0.95, 1.05), R.h, sl, light)
            n = n + 1
          end
        end
      end
    end
  end
  return n
end
print(wait(3*1440)); print(paintRows(250, 600, 0, 1000)); print(paintRows(100, 250, 0, 1000))

--@ chunk 4
B = {
  pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",1}},
  pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}},
  pile{{"bone black",1.5},{"raw sienna",1},{"viridian",0.4},{"yellow ochre",0.3}},
  pile{{"bone black",2},{"bone brown",1},{"raw sienna",0.5}},
}
SHEEN = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.5}}
GOLD = pile{{"yellow ochre",2},{"lead white",1},{"raw sienna",0.5}}
HOT = pile{{"lead white",2},{"Mars yellow",1},{"yellow ochre",0.5}}
SHD = pile{{"bone black",2},{"bone brown",1}}
VERD = pile{{"viridian",1},{"cerulean blue",0.5},{"lead white",1},{"yellow ochre",0.4},{"bone black",0.3}}
function rowsList()
  local rows, d, k = {}, 3, 0
  while d < 540 do
    k = k + 1
    local h = 5 + 0.12 * d
    rows[#rows + 1] = {d = d, h = h, w = 1.35 * h, k = k}
    d = d + h * 0.72
  end
  return rows
end
function plate(cx, cy, w, h, sl, light)
  local fb = brush{kind="filbert", width=math.max(1.5, h * 0.8)}
  local r = math.random()
  local p = (r < 0.5) and B[1] or ((r < 0.78) and B[4] or ((r < 0.92) and B[2] or B[3]))
  local x0, x1 = cx - w/2 + h*0.3, cx + w/2 - h*0.3
  fb:reload(p, 0.8)
  fb:stroke({{x0, cy + sl*(x0-cx)}, {x1, cy + sl*(x1-cx)}}, {pressure={0.7, 0.7}, ramps={0.1,0.1}})
  -- lower rounded edge
  local edge = {}
  for i = 0, 10 do local a = math.pi * i / 10; local ex = cx + (w/2) * math.cos(a); edge[#edge+1] = {ex, cy + (h/2) * math.sin(a) + sl*(ex-cx)} end
  if h > 9 then
    local db = brush{kind="round", width=math.max(1, h * 0.12), point=0.4}
    local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1], e[2] + h*0.05} end
    db:reload(SHD, 0.7); db:stroke(sh, {pressure={0.55, 0.55}, ramps={0.1,0.1}})
  end
  -- sheen: a soft band inside the sunward flank
  local sb = brush{kind="filbert", width=math.max(1.2, h * 0.28)}
  local sh2 = {} for i = 1, 6 do sh2[i] = {edge[i][1] - h*0.16 - w*0.04, edge[i][2] - h*0.2} end
  sb:reload(SHEEN, 0.45 * light)
  sb:stroke(sh2, {pressure={0.4, 0.15}, ramps={0.1,0.5}})
  -- raking rim: right flank of the bulge
  local rb = brush{kind="round", width=math.max(0.9, h * 0.09), point=0.6}
  local rim = {} for i = 1, 5 do rim[i] = {edge[i][1] - h*0.06, edge[i][2] - h*0.07} end
  rb:reload((light > 0.75) and HOT or GOLD, 0.6)
  rb:stroke(rim, {pressure={0.55 * light + 0.15, 0.1}, ramps={0.05, 0.6}})
end
function paintRows(dmin, dmax, x0, x1)
  local rows = rowsList()
  local n = 0
  for i = #rows, 1, -1 do
    local R = rows[i]
    if R.d >= dmin and R.d < dmax then
      local off = ((R.k * 0.618) % 1) * R.w
      for cx = -R.w + off, 1000 + R.w, R.w do
        if cx > x0 - R.w and cx < x1 + R.w then
          local cy = yL(cx) + R.d
          if cy - R.h < 570 then
            local sl = (yL(cx + 5) - yL(cx - 5)) / 10
            local light = clamp(0.45 + 0.4 * (cx / 1000) + 0.25 * (1 - R.d / 540) + rand(-0.15, 0.15), 0.2, 1)
            plate(cx, cy, R.w * rand(0.95, 1.05), R.h, sl, light)
            n = n + 1
          end
        end
      end
    end
  end
  return n
end
print(paintRows(0, 100, 0, 1000))
-- the limb: sun grazing the far plates, a thin bright edge against space
local lb = brush{kind="round", width=2.2, point=0.5}
for x = 0, 990, 12 do
  local k = clamp(0.3 + 0.7 * x / 1000, 0, 1)
  lb:reload((k > 0.6) and HOT or GOLD, 0.6)
  lb:stroke({{x, yL(x) + 1.5}, {x + 12.5, yL(x + 12.5) + 1.5}}, {pressure={0.3 + 0.35*k, 0.3 + 0.35*k}})
end

--@ chunk 5
-- the outpost: gray prefab boxes on the hull, shadows thrown left across the plates
function yb(x) return yL(x) + 205 end
DX, DY = 13, -9
function boxFaces(xa, xb, h, lift)
  lift = lift or 0
  local a, b = yb(xa) - lift, yb(xb) - lift
  local front = {{xa, a}, {xb, b}, {xb, b - h}, {xa, a - h}}
  local side = {{xb, b}, {xb + DX, b + DY}, {xb + DX, b + DY - h}, {xb, b - h}}
  local top = {{xa, a - h}, {xb, b - h}, {xb + DX, b + DY - h}, {xa + DX, a + DY - h}}
  return front, side, top
end
MODS = {
  {370, 450, 40, 0}, {445, 535, 62, 0}, {528, 590, 38, 0}, {462, 502, 20, 62}, {600, 640, 22, 0},
}
GF = pile{{"bone black",1.5},{"zinc white",0.6},{"ultramarine ash",0.5},{"burnt sienna",0.1}}
GS = pile{{"zinc white",2},{"bone black",0.45},{"ultramarine ash",0.3},{"yellow ochre",0.15}}
GT = pile{{"zinc white",1.2},{"bone black",0.6},{"ultramarine ash",0.4},{"yellow ochre",0.1}}
-- shadows first, on the hull
local shG = pile{{"bone black",2},{"bone brown",1}, medium=0.55}
local shadow = nil
for _, m in ipairs(MODS) do
  local xa, xb, h, lift = m[1], m[2], m[3], m[4]
  local L = 1.7 * (h + lift)
  local q = poly({{xa, yb(xa)}, {xb + DX, yb(xb) + DY}, {xb + DX - L, yb(xb - L) + DY + 4}, {xa - L, yb(xa - L) + 4}})
  shadow = shadow and (shadow + q) or q
end
-- the dish array and mast stand left of M1; their shadows too
shadow = shadow + poly({{330, yb(330)}, {372, yb(372)}, {300, yb(300) + 3}, {260, yb(260) + 3}})
OUTSH = shadow
work(shadow, {hand="body", tool="filbert 6", pile=shG, coverage=2.2, fill=true, angle=-0.2, clip=true, load=0.8})
OUTM = nil
for _, m in ipairs(MODS) do
  local f, s, t = boxFaces(m[1], m[2], m[3], m[4])
  local fm, sm, tm = poly(f), poly(s), poly(t)
  OUTM = OUTM and (OUTM + fm + sm + tm) or (fm + sm + tm)
  work(fm, {hand="detail", tool="round 3", pile=GF, coverage=4, fill=true, load=1})
  work(sm, {hand="detail", tool="round 3", pile=GS, coverage=4, fill=true, load=1})
  work(tm, {hand="detail", tool="round 3", pile=GT, coverage=4, fill=true, load=1})
end
print(wait(4*1440))

--@ chunk 6
local GF2 = pile{{"bone black",2},{"zinc white",0.4},{"ultramarine ash",0.5},{"burnt sienna",0.15}}
local GS2 = pile{{"zinc white",2},{"bone black",0.35},{"yellow ochre",0.2},{"ultramarine ash",0.15}}
local GT2 = pile{{"zinc white",1},{"bone black",0.8},{"ultramarine ash",0.4}}
local shG = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.4}
work(OUTSH - OUTM:grow(1), {hand="body", tool="filbert 6", pile=shG, coverage=3, fill=true, angle=-0.2, clip=true, load=0.9})
for _, m in ipairs(MODS) do
  local f, s, t = boxFaces(m[1], m[2], m[3], m[4])
  work(poly(f), {hand="detail", tool="round 3", pile=GF2, coverage=5, fill=true, load=1})
  work(poly(s), {hand="detail", tool="round 3", pile=GS2, coverage=5, fill=true, load=1})
  work(poly(t), {hand="detail", tool="round 3", pile=GT2, coverage=5, fill=true, load=1})
end
print(wait(4*1440))

--@ chunk 7
-- cast shadows thrown down-left across the plates; then the outpost's equipment
local shG = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.3}
local sh = nil
for _, m in ipairs(MODS) do
  local xa, xb, h = m[1], m[2], m[3] + m[4]
  local L = 1.4 * h
  local q = poly({{xa, yb(xa)}, {xb + DX, yb(xb) + DY}, {xb + DX - L, yb(xb - L) + DY + 0.5*h}, {xa - L, yb(xa - L) + 0.5*h}})
  sh = sh and (sh + q) or q
end
SH2 = sh - OUTM:grow(0.5)
work(SH2, {hand="body", tool="filbert 6", pile=shG, coverage=3, fill=true, angle=-0.2, clip=true, load=0.9})
print(wait(3*1440))
local dk = pile{{"bone black",2},{"ultramarine ash",0.4}}
local lit = pile{{"zinc white",2},{"bone black",0.3},{"yellow ochre",0.25}}
local amber = pile{{"chrome yellow",2},{"Mars orange",0.6},{"yellow ochre",0.5}}
local r1 = brush{kind="round", width=1.2, point=0.7}
local r2 = brush{kind="round", width=2.2, point=0.5}
local function st(b, p, pts, pr) b:reload(p, 0.7); b:stroke(pts, {pressure=pr or {0.6,0.6}, ramps={0.05,0.1}}) end
-- dead windows: dark slots along M1 and M2 fronts
for _, w in ipairs({{380,0.55},{395,0.55},{410,0.55},{425,0.55}}) do
  local x = w[1]; local y = yb(x) - 26
  work(poly({{x, y}, {x + 9, y - 1.6}, {x + 9, y + 5.4}, {x, y + 7}}), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
end
for _, x in ipairs({455, 470, 485, 500, 515}) do
  local y = yb(x) - 48
  work(poly({{x, y}, {x + 9, y - 1.6}, {x + 9, y + 6.4}, {x, y + 8}}), {hand="detail", tool="round 1.2", pile=dk, coverage=5, fill=true})
end
-- seams on the prefab panels
for _, x in ipairs({410, 490}) do st(r1, dk, {{x, yb(x) - 1}, {x, yb(x) - ((x < 445) and 39 or 61)}}, {0.4,0.4}) end
-- amber hazard band low on M2 and M3, black diagonal stripes
for _, m in ipairs({{446, 534}, {529, 589}}) do
  local xa, xb = m[1], m[2]
  work(poly({{xa, yb(xa) - 2}, {xb, yb(xb) - 2}, {xb, yb(xb) - 8}, {xa, yb(xa) - 8}}), {hand="detail", tool="round 1.4", pile=amber, coverage=5, fill=true})
end
print(wait(2*1440))
for x = 448, 586, 7 do
  if x < 532 or x > 531 then st(r1, dk, {{x, yb(x) - 2.5}, {x + 4, yb(x + 4) - 7.5}}, {0.6,0.6}) end
end
-- placards: pale cards with machine glyphs
for _, pc in ipairs({{372, 18}, {540, 20}, {604, 12}}) do
  local x, up = pc[1], pc[2]
  local y = yb(x) - up - 9
  work(poly({{x, y}, {x + 12, y - 2}, {x + 12, y + 7}, {x, y + 9}}), {hand="detail", tool="round 1.2", pile=pile{{"zinc white",2},{"yellow ochre",0.3},{"bone black",0.15}}, coverage=5, fill=true})
end

--@ chunk 8
-- the scorched module, the bent antenna, the mast, dishes, a truss boom, and the crude brackets
local dk = pile{{"bone black",2},{"ultramarine ash",0.4}}
local soot = pile{{"bone black",2},{"bone brown",1}}
local lit = pile{{"zinc white",2},{"bone black",0.3},{"yellow ochre",0.25}}
local mid = pile{{"bone black",1.5},{"zinc white",0.6},{"ultramarine ash",0.5}}
local ember = pile{{"burnt sienna",1},{"Mars orange",0.5},{"bone black",0.6}}
local r1 = brush{kind="round", width=1.2, point=0.7}
local r2 = brush{kind="round", width=2, point=0.5}
local r3 = brush{kind="round", width=3, point=0.4}
local function st(b, p, pts, pr) b:reload(p, 0.7); b:stroke(pts, {pressure=pr or {0.6,0.6}, ramps={0.05,0.1}}) end
-- scorch: soot blown up and left from a torn hole in M3's front
local f, s, t = boxFaces(528, 590, 38, 0)
local m3 = poly(f) + poly(t) + poly(s)
work(m3 * poly({{528,330},{575,300},{600,270},{528,265}}), {hand="scumble", pile=soot, load=0.45, pressure={0.2,0.5}, coverage=1.6, clip=true, angle=-0.6})
local hole = poly({{548, yb(548) - 10}, {553, yb(553) - 27}, {559, yb(559) - 22}, {565, yb(565) - 31}, {571, yb(571) - 12}, {563, yb(563) - 6}, {556, yb(556) - 13}})
work(hole, {hand="detail", tool="round 1.4", pile=pile{{"bone black",2},{"burnt sienna",0.3}}, coverage=5, fill=true})
-- peeled lips of the tear, catching the sun on their right edges
st(r1, lit, {{565, yb(565) - 31}, {572, yb(572) - 36}, {576, yb(576) - 30}}, {0.55,0.4})
st(r1, lit, {{571, yb(571) - 12}, {579, yb(579) - 10}}, {0.5,0.4})
st(r1, mid, {{553, yb(553) - 27}, {547, yb(547) - 34}}, {0.5,0.4})
st(r1, ember, {{556, yb(556) - 13}, {560, yb(560) - 18}}, {0.4,0.3})
-- soot trailing onto the hull plates below-left of the hole
work(poly({{548, yb(548)}, {566, yb(566)}, {520, yb(520) + 22}, {496, yb(496) + 20}}) - OUTM, {hand="scumble", pile=soot, load=0.35, pressure={0.15,0.4}, coverage=1.2, clip=true, angle=2.6})
-- mast on M4, with crossbars
local mx = 486
local mtop = yb(mx) - 82
st(r2, mid, {{mx, mtop}, {mx + 2, mtop - 85}}, {0.55,0.4})
st(r1, lit, {{mx + 1.2, mtop}, {mx + 3, mtop - 85}}, {0.4,0.3})
for k = 1, 3 do local y = mtop - 20*k; st(r1, mid, {{mx - 7 + k, y + 1}, {mx + 9 - k, y - 1}}, {0.45,0.45}) end
-- the bent antenna on M1
local ax = 398; local ab = yb(ax) - 40
st(r2, mid, {{ax, ab}, {ax + 1, ab - 44}, {ax + 22, ab - 34}}, {0.55,0.45})
st(r1, lit, {{ax + 1.1, ab}, {ax + 2, ab - 44}}, {0.35,0.3})
st(r1, lit, {{ax + 2, ab - 44.5}, {ax + 22, ab - 35}}, {0.35,0.3})
-- dish array on stub legs left of M1
for _, d in ipairs({{318, 9, 12}, {340, 11, 16}, {358, 8, 10}}) do
  local cx, rr, up = d[1], d[2], d[3]
  local cy = yb(cx) - up
  st(r1, dk, {{cx, cy + 2}, {cx - 2, yb(cx)}}, {0.6,0.6})
  st(r1, dk, {{cx, cy + 2}, {cx + 4, yb(cx + 4)}}, {0.6,0.6})
  local bowl = ellipse(cx, cy, rr, rr * 0.55)
  work(bowl, {hand="detail", tool="round 1.2", pile=mid, coverage=5, fill=true})
  work(bowl * rect(cx, cy - rr, rr, 2 * rr), {hand="detail", tool="round 1.2", pile=lit, coverage=4, fill=true})
  st(r1, dk, {{cx - 1, cy}, {cx - 5, cy - rr * 0.9}}, {0.4,0.3})
end
-- truss boom from M5 out over the plates, a small dish at its end
local x0 = 640 + DX; local y0 = yb(640) + DY - 16
local x1, y1 = 735, yb(735) - 30
st(r1, mid, {{x0, y0}, {x1, y1}}, {0.5,0.5})
st(r1, mid, {{x0, y0 + 7}, {x1, y1 + 5}}, {0.5,0.5})
for k = 0, 9 do
  local ta, tb = k / 10, (k + 1) / 10
  st(r1, (k % 2 == 0) and lit or mid, {{lerp(x0, x1, ta), lerp(y0, y1, ta)}, {lerp(x0, x1, tb), lerp(y0, y1, tb) + lerp(7, 5, tb)}}, {0.4,0.4})
end
local db = ellipse(x1 + 6, y1 - 4, 10, 6)
work(db, {hand="detail", tool="round 1.2", pile=mid, coverage=5, fill=true})
work(db * rect(x1 + 6, y1 - 12, 12, 16), {hand="detail", tool="round 1.2", pile=lit, coverage=4, fill=true})
-- brackets: crude clamps at the module feet, biting into plate edges
for _, x in ipairs({372, 448, 447, 533, 531, 588, 602, 638}) do
  local y = yb(x)
  st(r3, dk, {{x, y - 4}, {x - 1, y + 5}, {x - 7, y + 7}}, {0.7,0.6})
  st(r1, lit, {{x + 1.2, y - 4}, {x + 0.4, y + 4.5}}, {0.4,0.3})
  st(r1, pile{{"bone black",1},{"zinc white",1}}, {{x - 4, y + 6}, {x - 3.5, y + 6}}, {0.6,0.6})
end

--@ chunk 9
print(wait(3*1440))
-- the hull turns away from the sun toward the lower left: a lean dark glaze
local turn = (hullM * poly({{0, 230}, {260, 330}, {420, 562}, {0, 562}})):soften(30) - OUTM:grow(2)
work(turn, {hand="glaze", pile=pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.3}, medium=0.75}, coverage=1.4, fill=true, clip=true, angle=-0.2})
-- stars
local fine = brush{kind="round", width=1.3, point=0.9}
local n = 0
for i = 1, 200 do
  local x, y = rand(5, 995), rand(4, 225)
  if spaceM:shrink(4):at(x, y) > 0.5 then
    fine:reload(pile{{"zinc white",3},{"cerulean blue",0.1}}, 0.4); fine:touch(x, y, {pressure=rand(0.15, 0.35)}); n = n + 1
  end
  if n > 40 then break end
end
-- machine glyphs on the placards
local gk = brush{kind="round", width=0.9, point=0.8}
for _, pc in ipairs({{372, 18}, {540, 20}, {604, 12}}) do
  local x, up = pc[1], pc[2]
  local y = yb(x) - up - 9
  for row = 0, 2 do
    local xx = x + 2
    while xx < x + 10 do
      local w = rand(1, 3)
      gk:reload(pile{{"bone black",2}}, 0.5); gk:stroke({{xx, y + 2 + row*2.3 - (xx - x)*0.16}, {xx + w, y + 2 + row*2.3 - (xx + w - x)*0.16}}, {pressure={0.5,0.5}})
      xx = xx + w + 1
    end
  end
end
-- the torn lip of the scorched module, bright where it faces the sun
local r1 = brush{kind="round", width=1.3, point=0.7}
r1:reload(pile{{"zinc white",2},{"yellow ochre",0.3},{"bone black",0.2}}, 0.7)
r1:stroke({{585, yb(585) - 40}, {600, yb(600) - 45}, {608, yb(608) - 52}}, {pressure={0.55,0.3}, ramps={0.05,0.4}})

--@ chunk 10
-- PASS 2: lay a dark substrate over the hull below the limb zone; the new plates go over it, gaps read as shadow
local lim = {}
for x = -10, 1010, 20 do lim[#lim + 1] = {x, yL(x) + 38} end
local sub = hullM * below(lim)
work(sub, {hand="body", pile=pile{{"bone black",2},{"bone brown",0.8},{"raw sienna",0.4}}, coverage=3.5, fill=true, angle=-0.15, clip=true, load=1})
print(wait(4*1440))

--@ chunk 11
-- PASS 2 hull: plates on golden-angle spirals laid out on the hull's surface, foreshortened toward the limb,
-- each a little different in size, tilt and wear, rolling from sun into shadow across a terminator band.
PS = 10              -- a plate's size on the surface
SC = 5.65            -- Vogel spacing constant (nearest neighbour ~ 1.77*SC)
SPC = {-700, -520}   -- the spiral's centre on the surface, far outside the frame
function surfToCanvas(X, S)
  local d = (5 / 0.12) * (math.exp(0.12 * S / PS) - 1)
  local sc = (5 + 0.12 * d) / PS
  local x = 520 + X * sc
  return x, yL(x) + d, 5 + 0.12 * d
end
-- terminator: signed distance across a band running from the limb at upper left down toward the lower middle
function sunAt(x, y)
  local ax, ay, bx, by = 120, 215, 470, 562
  local vx, vy = bx - ax, by - ay
  local L = math.sqrt(vx*vx + vy*vy)
  local sd = ((x - ax) * vy - (y - ay) * vx) / L     -- >0 to the right (sunward)
  return clamp(0.5 + sd / 170, 0, 1)
end
PB = {
  lit = pile{{"raw sienna",2},{"yellow ochre",0.8},{"burnt sienna",0.6},{"bone black",0.3}},
  mid = pile{{"bone black",1.2},{"raw sienna",1.5},{"burnt sienna",0.8}},
  dark = pile{{"bone black",2},{"burnt sienna",0.8},{"raw sienna",0.5}},
  deep = pile{{"bone black",2},{"bone brown",0.8},{"ultramarine blue",0.3}},
  verd = pile{{"bone black",1},{"raw sienna",0.8},{"viridian",0.5},{"yellow ochre",0.3}},
  verdL = pile{{"viridian",1},{"cerulean blue",0.4},{"lead white",0.8},{"yellow ochre",0.6},{"bone black",0.3}},
  worn = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.4},{"lead white",0.25}},
}
function plate2(cx, cy, w, h, tilt, sun, kind)
  local ca, sa = math.cos(tilt), math.sin(tilt)
  local function P(u, v) return {cx + u * ca - v * sa, cy + u * sa + v * ca} end
  if kind == "missing" then
    local hb = brush{kind="filbert", width=math.max(1.5, h * 0.8)}
    hb:reload(PB.deep, 0.9); hb:stroke({P(-w/2 + h*0.3, 0), P(w/2 - h*0.3, 0)}, {pressure={0.8,0.8}, ramps={0.1,0.1}})
    return
  end
  local body
  local r = math.random()
  if sun > 0.66 then body = (r < 0.55) and PB.lit or ((r < 0.8) and PB.mid or ((r < 0.92) and PB.worn or PB.verd))
  elseif sun > 0.33 then body = (r < 0.6) and PB.mid or ((r < 0.88) and PB.dark or PB.verd)
  else body = (r < 0.75) and PB.dark or ((r < 0.9) and PB.deep or PB.verd) end
  local fb = brush{kind="filbert", width=math.max(1.5, h * 0.82)}
  fb:reload(body, 0.85)
  fb:stroke({P(-w/2 + h*0.32, -h*0.02), P(w/2 - h*0.32, -h*0.02)}, {pressure={0.75,0.7}, ramps={0.1,0.1}})
  local edge = {}
  for i = 0, 12 do local a = math.pi * i / 12; edge[#edge+1] = P((w/2) * math.cos(a), (h/2) * math.sin(a)) end
  -- dark underside: the plate's own shadow on the course below
  if h > 7 then
    local db = brush{kind="round", width=math.max(1, h * 0.16), point=0.4}
    local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1] + h*0.03, e[2] + h*0.08} end
    db:reload(PB.deep, 0.7); db:stroke(sh, {pressure={0.6,0.6}, ramps={0.1,0.1}})
  end
  -- a broad sheen on the sunward flank, then the worn lit lip
  if sun > 0.3 and h > 6 then
    local sb = brush{kind="filbert", width=math.max(1.2, h * 0.3)}
    local s2 = {} for i = 1, 7 do s2[i] = {edge[i][1] - h*0.18 - w*0.03, edge[i][2] - h*0.22} end
    sb:reload((math.random() < 0.15) and PB.verdL or PB.worn, 0.35 * sun)
    sb:stroke(s2, {pressure={0.4 * sun, 0.1}, ramps={0.1,0.6}})
  end
  if sun > 0.15 then
    local rb = brush{kind="round", width=math.max(0.9, h * 0.085), point=0.6}
    local n1 = math.random(4, 7)
    local lip = {} for i = 1, n1 do lip[i] = {edge[i][1] - h*0.05, edge[i][2] - h*0.07} end
    rb:reload((sun > 0.8) and HOT or ((sun > 0.5) and GOLD or SHEEN), 0.6)
    rb:stroke(lip, {pressure={0.25 + 0.45 * sun, 0.05}, ramps={0.05, 0.6}})
  end
  if kind == "recut" and h > 10 then
    local cb = brush{kind="round", width=math.max(1, h * 0.1), point=0.3}
    local a, b = P(w*0.1, -h*0.3), P(w*0.42, h*0.38)
    cb:reload(PB.deep, 0.8); cb:stroke({a, b}, {pressure={0.6,0.6}})
    cb:reload(GOLD, 0.5); cb:stroke({{a[1] + 1, a[2]}, {b[1] + 1, b[2]}}, {pressure={0.3,0.3}})
  end
end
function hullPlates(dmin, dmax)
  local list = {}
  local Rmin, Rmax = 0, 1e9
  for n = 1, 60000 do
    local r = SC * math.sqrt(n)
    local th = n * 2.399963
    local X, S = SPC[1] + r * math.cos(th), SPC[2] + r * math.sin(th)
    if S > 20 and S < 260 then
      local x, y, h = surfToCanvas(X, S)
      local d = y - yL(x)
      if d >= dmin and d < dmax and x > -40 and x < 1040 and y < 590 then
        list[#list + 1] = {x, y, h, S}
      end
    end
  end
  table.sort(list, function(a, b) return a[4] > b[4] end)   -- nearest first: farther courses overlap them
  for _, p in ipairs(list) do
    local x, y, h = p[1], p[2], p[3]
    local sz = rand(0.85, 1.2)
    local hh = h * sz
    local ww = hh * rand(1.25, 1.5)
    local sl = (yL(x + 5) - yL(x - 5)) / 10
    local tilt = math.atan(sl) + randn(0, 0.12)
    local rk = math.random()
    local kind = (rk < 0.012) and "missing" or ((rk < 0.04) and "recut" or "plain")
    plate2(x + randn(0, h * 0.06), y, ww, hh, tilt, clamp(sunAt(x, y) + randn(0, 0.06), 0, 1), kind)
  end
  return #list
end
print(hullPlates(250, 700))
print(hullPlates(100, 250))

--@ chunk 12
function plate2_dummy() end

--@ chunk 13
function plate2(cx, cy, w, h, tilt, sun, kind)
  local ca, sa = math.cos(tilt), math.sin(tilt)
  local function P(u, v) return {cx + u * ca - v * sa, cy + u * sa + v * ca} end
  if kind == "missing" then
    local hb = brush{kind="filbert", width=math.max(1.5, h * 0.8)}
    hb:reload(PB.deep, 0.9); hb:stroke({P(-w/2 + h*0.3, 0), P(w/2 - h*0.3, 0)}, {pressure={0.8,0.8}, ramps={0.1,0.1}})
    return
  end
  local body
  local r = math.random()
  if sun > 0.66 then body = (r < 0.55) and PB.lit or ((r < 0.8) and PB.mid or ((r < 0.92) and PB.worn or PB.verd))
  elseif sun > 0.33 then body = (r < 0.6) and PB.mid or ((r < 0.88) and PB.dark or PB.verd)
  else body = (r < 0.75) and PB.dark or ((r < 0.9) and PB.deep or PB.verd) end
  local fb = brush{kind="filbert", width=math.max(1.5, h * 0.82)}
  fb:reload(body, 0.85)
  fb:stroke({P(-w/2 + h*0.32, -h*0.02), P(w/2 - h*0.32, -h*0.02)}, {pressure={0.75,0.7}, ramps={0.1,0.1}})
  local edge = {}
  for i = 0, 12 do local a = math.pi * i / 12; edge[#edge+1] = P((w/2) * math.cos(a), (h/2) * math.sin(a)) end
  -- dark underside: the plate's own shadow on the course below
  if h > 7 then
    local db = brush{kind="round", width=math.max(1, h * 0.16), point=0.4}
    local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1] + h*0.03, e[2] + h*0.08} end
    db:reload(PB.deep, 0.7); db:stroke(sh, {pressure={0.6,0.6}, ramps={0.1,0.1}})
  end
  -- a broad sheen on the sunward flank, then the worn lit lip
  if sun > 0.3 and h > 6 then
    local sb = brush{kind="filbert", width=math.max(1.2, h * 0.3)}
    local s2 = {} for i = 1, 7 do s2[i] = {edge[i][1] - h*0.18 - w*0.03, edge[i][2] - h*0.22} end
    sb:reload((math.random() < 0.05) and PB.verdL or PB.worn, 0.35 * sun)
    sb:stroke(s2, {pressure={0.4 * sun, 0.1}, ramps={0.1,0.6}})
  end
  if sun > 0.15 then
    local rb = brush{kind="round", width=math.max(0.9, h * 0.085), point=0.6}
    local n1 = math.random(4, 7)
    local lip = {} for i = 1, n1 do lip[i] = {edge[i][1] - h*0.05, edge[i][2] - h*0.07} end
    rb:reload((sun > 0.8) and HOT or ((sun > 0.5) and GOLD or SHEEN), 0.6)
    rb:stroke(lip, {pressure={0.25 + 0.45 * sun, 0.05}, ramps={0.05, 0.6}})
  end
  if kind == "recut" and h > 10 then
    local cb = brush{kind="round", width=math.max(1, h * 0.1), point=0.3}
    local a, b = P(w*0.1, -h*0.3), P(w*0.42, h*0.38)
    cb:reload(PB.deep, 0.8); cb:stroke({a, b}, {pressure={0.6,0.6}})
    cb:reload(GOLD, 0.5); cb:stroke({{a[1] + 1, a[2]}, {b[1] + 1, b[2]}}, {pressure={0.3,0.3}})
  end
end
-- PASS 2: the first spiral courses were too small (gaps everywhere, coin-like) and too pale. Larger, darker, overlapping.
print(wait(3*1440))
PB.lit = pile{{"raw sienna",2},{"burnt sienna",0.8},{"bone black",0.6},{"yellow ochre",0.3}}
PB.worn = pile{{"yellow ochre",1.2},{"raw sienna",1},{"burnt sienna",0.5},{"bone black",0.2}}
function hullPlates(dmin, dmax)
  local list = {}
  for n = 1, 60000 do
    local r = SC * math.sqrt(n)
    local th = n * 2.399963
    local X, S = SPC[1] + r * math.cos(th), SPC[2] + r * math.sin(th)
    if S > 20 and S < 260 then
      local x, y, h = surfToCanvas(X, S)
      local d = y - yL(x)
      if d >= dmin and d < dmax and x > -50 and x < 1050 and y < 600 then list[#list + 1] = {x, y, h, S} end
    end
  end
  table.sort(list, function(a, b) return a[4] > b[4] end)
  for _, p in ipairs(list) do
    local x, y, h = p[1], p[2], p[3]
    local hh = h * rand(1.25, 1.6)
    local ww = hh * rand(1.3, 1.55)
    local sl = (yL(x + 5) - yL(x - 5)) / 10
    local tilt = math.atan(sl) + randn(0, 0.12)
    local rk = math.random()
    local kind = (rk < 0.012) and "missing" or ((rk < 0.04) and "recut" or "plain")
    plate2(x + randn(0, h * 0.06), y, ww, hh, tilt, clamp(sunAt(x, y) + randn(0, 0.06), 0, 1), kind)
  end
  return #list
end
print(hullPlates(250, 700))
print(hullPlates(100, 250))
print(hullPlates(36, 100))

--@ chunk 14
-- PASS 2: accents over the dry plates: each course's dark underside and its worn lit lip, strong where the sun rakes.
print(wait(4*1440))
local list = {}
for n = 1, 60000 do
  local r = SC * math.sqrt(n)
  local th = n * 2.399963
  local X, S = SPC[1] + r * math.cos(th), SPC[2] + r * math.sin(th)
  if S > 20 and S < 260 then
    local x, y, h = surfToCanvas(X, S)
    local d = y - yL(x)
    if d >= 36 and x > -50 and x < 1050 and y < 600 then list[#list + 1] = {x, y, h, S} end
  end
end
table.sort(list, function(a, b) return a[4] > b[4] end)
for _, p in ipairs(list) do
  local x, y, h = p[1], p[2] + p[3] * 0.1, p[3] * 1.4
  local w = h * 1.42
  local sun = clamp(sunAt(x, y) + randn(0, 0.06), 0, 1)
  local sl = (yL(x + 5) - yL(x - 5)) / 10
  local tilt = math.atan(sl) + randn(0, 0.1)
  local ca, sa = math.cos(tilt), math.sin(tilt)
  local edge = {}
  for i = 0, 12 do local a = math.pi * i / 12; local u, v = (w/2) * math.cos(a), (h/2) * math.sin(a); edge[#edge+1] = {x + u*ca - v*sa, y + u*sa + v*ca} end
  local db = brush{kind="round", width=math.max(1, h * 0.11), point=0.4}
  local sh = {} for i, e in ipairs(edge) do sh[i] = {e[1], e[2] + h*0.07} end
  db:reload(PB.deep, 0.7); db:stroke(sh, {pressure={0.55,0.55}, ramps={0.1,0.1}})
  if sun > 0.2 then
    local rb = brush{kind="round", width=math.max(0.9, h * 0.075), point=0.6}
    local n1 = math.random(4, 8)
    local lip = {} for i = 1, n1 do lip[i] = {edge[i][1] - h*0.04, edge[i][2] - h*0.05} end
    rb:reload((sun > 0.75) and HOT or ((sun > 0.45) and GOLD or SHEEN), 0.65)
    rb:stroke(lip, {pressure={0.3 + 0.5 * sun, 0.05}, ramps={0.05, 0.6}})
  end
end
print(#list)

--@ chunk 15
-- PASS 2 outpost, part 1: heavier modules, sharp shadows thrown left along the plates.
print(wait(3*1440))
DX, DY = 20, -12
MODS2 = { {365,448,42,0}, {440,535,66,0}, {528,592,40,0}, {458,505,22,66}, {600,648,24,0} }
local deep = pile{{"bone black",2},{"bone brown",0.8},{"ultramarine blue",0.4}}
local sh = nil
for _, m in ipairs(MODS2) do
  local xa, xb, h, lift = m[1], m[2], m[3], m[4]
  local H = h + lift
  local L = 2.1 * H
  local q = poly({{xa, yb(xa)}, {xb, yb(xb)}, {xb + DX, yb(xb) + DY}, {xb + DX - L, yb(xb + DX - L) + DY + 0.22*H}, {xa - L, yb(xa - L) + 0.22*H}})
  sh = sh and (sh + q) or q
end
-- mast and dish shadows: thin long bars
sh = sh + ribbon({{486, yb(486)}, {486 - 300, yb(186) + 30}}, 3) + ribbon({{400, yb(400)}, {400 - 150, yb(250) + 14}}, 2.5)
SH3 = sh
OUTM2 = nil
for _, m in ipairs(MODS2) do
  local f, s, t = boxFaces(m[1], m[2], m[3], m[4])
  local mm = poly(f) + poly(s) + poly(t)
  OUTM2 = OUTM2 and (OUTM2 + mm) or mm
end
work(SH3 - OUTM2:grow(0.5), {hand="detail", tool="round 3", pile=deep, coverage=4.5, fill=true, load=1})
local GF = pile{{"bone black",2},{"zinc white",0.45},{"ultramarine ash",0.5},{"burnt sienna",0.15}}
local GS = pile{{"zinc white",2},{"bone black",0.35},{"yellow ochre",0.25},{"ultramarine ash",0.1}}
local GT = pile{{"zinc white",1.3},{"bone black",0.6},{"ultramarine ash",0.35},{"yellow ochre",0.1}}
for _, m in ipairs(MODS2) do
  local f, s, t = boxFaces(m[1], m[2], m[3], m[4])
  work(poly(f), {hand="detail", tool="round 3", pile=GF, coverage=5, fill=true, load=1})
  work(poly(s), {hand="detail", tool="round 3", pile=GS, coverage=5, fill=true, load=1})
  work(poly(t), {hand="detail", tool="round 3", pile=GT, coverage=5, fill=true, load=1})
end
print(wait(4*1440))

--@ chunk 16
-- PASS 2 outpost, part 2: thickness and edges, panels, dead windows, hazard bands, placards; struts and clamps
-- biting the plates; cables across the hull; equipment; the scorched module's soot streaking onto the plates.
local dk = pile{{"bone black",2},{"ultramarine ash",0.4}}
local deep = pile{{"bone black",2},{"bone brown",0.8},{"ultramarine blue",0.4}}
local lit = pile{{"zinc white",2},{"bone black",0.25},{"yellow ochre",0.3}}
local mid = pile{{"bone black",1.5},{"zinc white",0.6},{"ultramarine ash",0.5}}
local amber = pile{{"chrome yellow",2},{"Mars orange",0.6},{"yellow ochre",0.5}}
local soot = pile{{"bone black",2},{"bone brown",1}}
local r1 = brush{kind="round", width=1.2, point=0.7}
local r2 = brush{kind="round", width=2.2, point=0.5}
local r3 = brush{kind="round", width=3.4, point=0.4}
local function st(b, p, pts, pr, clipM) b:reload(p, 0.7); b:stroke(pts, {pressure=pr or {0.6,0.6}, ramps={0.05,0.1}, clip=clipM}) end
for i, m in ipairs(MODS2) do
  local xa, xb, h, lift = m[1], m[2], m[3], m[4]
  local f, s, t = boxFaces(xa, xb, h, lift)
  local fm = poly(f)
  -- edges: the sunlit vertical corner and the roof's front edge
  st(r2, lit, {{xb + 0.6, yb(xb) - lift - 1}, {xb + 0.6, yb(xb) - lift - h + 1}}, {0.55,0.5})
  st(r1, lit, {{xa + 1, yb(xa) - lift - h + 1}, {xb - 1, yb(xb) - lift - h + 1}}, {0.5,0.5})
  -- dark skirt along the bottom of the front: its underside
  st(r2, deep, {{xa, yb(xa) - lift - 1.5}, {xb, yb(xb) - lift - 1.5}}, {0.6,0.6}, fm)
  -- prefab panel joints and rivet rows
  local np = math.floor((xb - xa) / 22)
  for k = 1, np do
    local x = xa + k * (xb - xa) / (np + 1)
    st(r1, dk, {{x, yb(x) - lift - 2}, {x, yb(x) - lift - h + 2}}, {0.4,0.4}, fm)
  end
  -- roof hardware: a vent box and a hatch rim
  if lift == 0 and h > 30 then
    local vx = xa + (xb - xa) * 0.3
    local vy = yb(vx) - h + DY * 0.5
    work(poly({{vx, vy}, {vx + 10, vy - 1.5}, {vx + 10, vy - 6}, {vx, vy - 4.5}}), {hand="detail", tool="round 1.2", pile=mid, coverage=5, fill=true})
    st(r1, lit, {{vx + 10.5, vy - 1.5}, {vx + 10.5, vy - 6}}, {0.4,0.4})
  end
end
-- dead windows
local function win(x, up, w2, h2)
  local y = yb(x) - up
  work(poly({{x, y}, {x + w2, y - w2*0.16}, {x + w2, y - w2*0.16 + h2}, {x, y + h2}}), {hand="detail", tool="round 1.1", pile=dk, coverage=5, fill=true})
end
for _, x in ipairs({374, 390, 406, 422}) do win(x, 30, 9, 7) end
for _, x in ipairs({450, 466, 482, 498, 514}) do win(x, 52, 9, 8) end
-- hazard bands with black diagonals
for _, m in ipairs({{441, 534}, {529, 591}, {601, 647}}) do
  local xa, xb = m[1], m[2]
  work(poly({{xa, yb(xa) - 4}, {xb, yb(xb) - 4}, {xb, yb(xb) - 10}, {xa, yb(xa) - 10}}), {hand="detail", tool="round 1.4", pile=amber, coverage=5, fill=true})
end
-- placards
for _, pc in ipairs({{370, 20}, {541, 22}, {606, 14}, {440, 40}}) do
  local x, up = pc[1], pc[2]
  local y = yb(x) - up - 9
  work(poly({{x, y}, {x + 12, y - 2}, {x + 12, y + 7}, {x, y + 9}}), {hand="detail", tool="round 1.2", pile=pile{{"zinc white",2},{"yellow ochre",0.3},{"bone black",0.15}}, coverage=5, fill=true})
end
print(wait(2*1440))
for x = 443, 645, 7 do if (x < 534 or x > 528) then st(r1, dk, {{x, yb(x) - 4.5}, {x + 4, yb(x + 4) - 9.5}}, {0.6,0.6}) end end
local gk = brush{kind="round", width=0.9, point=0.8}
for _, pc in ipairs({{370, 20}, {541, 22}, {606, 14}, {440, 40}}) do
  local x, up = pc[1], pc[2]
  local y = yb(x) - up - 9
  for row = 0, 2 do
    local xx = x + 2
    while xx < x + 10 do
      local w = rand(1, 3)
      gk:reload(dk, 0.5); gk:stroke({{xx, y + 2 + row*2.3 - (xx - x)*0.16}, {xx + w, y + 2 + row*2.3 - (xx + w - x)*0.16}}, {pressure={0.5,0.5}})
      xx = xx + w + 1
    end
  end
end
-- struts and clamps: braces from the module walls down onto plate lips, the plates scraped bright around the jaws
local scr = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.4}}
local braces = {{366, 18, -26, 16}, {448, 10, -16, 14}, {440, 30, -30, 22}, {536, 12, -14, 16}, {592, 14, 18, 14}, {600, 10, -12, 12}, {650, 12, 22, 16}}
for _, b in ipairs(braces) do
  local x, up, dx, dy = b[1], b[2], b[3], b[4]
  local y0 = yb(x) - up
  local x1, y1 = x + dx, yb(x + dx) + dy * 0.35
  st(r3, mid, {{x, y0}, {x1, y1}}, {0.75,0.7})
  st(r1, lit, {{x + 1.2, y0 - 1}, {x1 + 1.2, y1 - 1}}, {0.4,0.35})
  -- the jaw: a U biting the lip
  st(r3, dk, {{x1 - 5, y1 - 2}, {x1 - 5, y1 + 4}, {x1 + 5, y1 + 4}, {x1 + 5, y1 - 2}}, {0.8,0.8})
  st(r1, lit, {{x1 - 5, y1 - 2.5}, {x1 + 5, y1 - 2.5}}, {0.45,0.45})
  st(r1, pile{{"zinc white",1},{"bone black",0.8}}, {{x1, y1 + 1}, {x1 + 0.5, y1 + 1}}, {0.7,0.7})
  -- scrapes and a dent crease in the plate around it
  for k = 1, 4 do
    local a = rand(-0.6, 0.6) + ((dx < 0) and math.pi or 0)
    local L = rand(5, 11)
    st(r1, scr, {{x1 + math.cos(a) * 6, y1 + 3 + math.sin(a) * 2}, {x1 + math.cos(a) * (6 + L), y1 + 3 + math.sin(a) * (2 + L * 0.3)}}, {0.35,0.1})
  end
  st(r2, deep, {{x1 - 9, y1 + 7}, {x1, y1 + 9}, {x1 + 9, y1 + 7}}, {0.5,0.4})
end
-- cables across the plates, sagging into the hollows
local cab = {
  {{366, yb(366) - 3}, {300, yb(300) + 22}, {200, yb(200) + 60}, {80, yb(80) + 120}, {-10, 520}},
  {{470, yb(470) - 2}, {440, yb(440) + 40}, {400, yb(400) + 110}, {360, 570}},
  {{560, yb(560) - 2}, {600, yb(600) + 50}, {660, yb(660) + 140}, {700, 575}},
}
for _, c in ipairs(cab) do
  st(r2, deep, c, {0.6,0.75})
  local up = {} for i, p in ipairs(c) do up[i] = {p[1] + 0.6, p[2] - 1.1} end
  st(r1, pile{{"bone black",1.2},{"zinc white",0.6},{"yellow ochre",0.2}}, up, {0.3,0.3})
end
-- mast, bent antenna, dish array, truss boom
local mx = 486; local mtop = yb(mx) - 88
st(r2, mid, {{mx, mtop}, {mx + 2, mtop - 90}}, {0.6,0.45})
st(r1, lit, {{mx + 1.3, mtop}, {mx + 3, mtop - 90}}, {0.45,0.3})
for k = 1, 3 do local y = mtop - 20*k; st(r1, mid, {{mx - 8 + k, y + 1}, {mx + 10 - k, y - 1}}, {0.5,0.5}) end
local ax = 398; local ab = yb(ax) - 42
st(r2, mid, {{ax, ab}, {ax + 1, ab - 46}, {ax + 24, ab - 36}}, {0.6,0.5})
st(r1, lit, {{ax + 1.2, ab}, {ax + 2, ab - 46}}, {0.4,0.3})
for _, d in ipairs({{318, 10, 13}, {341, 12, 17}, {358, 8, 11}}) do
  local cx, rr, up = d[1], d[2], d[3]
  local cy = yb(cx) - up
  st(r2, dk, {{cx, cy + 2}, {cx - 3, yb(cx)}}, {0.6,0.6}); st(r2, dk, {{cx, cy + 2}, {cx + 5, yb(cx + 5)}}, {0.6,0.6})
  local bowl = ellipse(cx, cy, rr, rr * 0.55)
  work(bowl, {hand="detail", tool="round 1.2", pile=mid, coverage=5, fill=true})
  work(bowl * rect(cx, cy - rr, rr, 2 * rr), {hand="detail", tool="round 1.2", pile=lit, coverage=4, fill=true})
  st(r1, dk, {{cx - 1, cy}, {cx - 5, cy - rr * 0.9}}, {0.45,0.3})
end
local x0 = 648 + DX; local y0 = yb(648) + DY - 18
local x1, y1 = 745, yb(745) - 32
for _, o in ipairs({0, 8}) do st(r2, mid, {{x0, y0 + o}, {x1, y1 + o * 0.7}}, {0.55,0.55}) end
for k = 0, 9 do
  local ta, tb = k / 10, (k + 1) / 10
  st(r1, (k % 2 == 0) and lit or mid, {{lerp(x0, x1, ta), lerp(y0, y1, ta)}, {lerp(x0, x1, tb), lerp(y0, y1, tb) + lerp(8, 5.6, tb)}}, {0.45,0.45})
end
local db = ellipse(x1 + 7, y1 - 4, 12, 7)
work(db, {hand="detail", tool="round 1.2", pile=mid, coverage=5, fill=true})
work(db * rect(x1 + 7, y1 - 12, 14, 18), {hand="detail", tool="round 1.2", pile=lit, coverage=4, fill=true})

--@ chunk 17
-- PASS 2 outpost, part 3: the scorched module. A hole torn outward, its lips peeled and lit, soot up its face and
-- streaked down across the plates below it.
print(wait(2*1440))
local soot = pile{{"bone black",2},{"bone brown",1}}
local burn = pile{{"Mars brown",1},{"bone black",1},{"burnt sienna",0.5}}
local lit = pile{{"zinc white",2},{"bone black",0.25},{"yellow ochre",0.3}}
local mid = pile{{"bone black",1.5},{"zinc white",0.6},{"ultramarine ash",0.5}}
local f, s, t = boxFaces(528, 592, 40, 0)
local fm, tm = poly(f), poly(t)
local hc = 560
local hole = poly({{546, yb(546) - 9}, {550, yb(550) - 24}, {556, yb(556) - 20}, {561, yb(561) - 33}, {567, yb(567) - 22}, {574, yb(574) - 27}, {576, yb(576) - 11}, {566, yb(566) - 5}, {555, yb(555) - 12}})
work(fm * ellipse(hc, yb(hc) - 18, 26, 20):roughen(4, 12, 3), {hand="scumble", pile=burn, load=0.5, pressure={0.2,0.5}, coverage=1.5, clip=true})
work((fm + tm) * poly({{528, yb(528) - 20}, {592, yb(592) - 30}, {612, yb(592) - 60}, {528, yb(528) - 60}}), {hand="scumble", pile=soot, load=0.4, pressure={0.15,0.45}, coverage=1.3, clip=true, angle=-1.2})
work(hole, {hand="detail", tool="round 1.4", pile=pile{{"bone black",2},{"burnt sienna",0.2}}, coverage=5, fill=true})
local r1 = brush{kind="round", width=1.4, point=0.7}
local function st(p, pts, pr) r1:reload(p, 0.7); r1:stroke(pts, {pressure=pr, ramps={0.05,0.3}}) end
st(lit, {{561, yb(561) - 33}, {566, yb(566) - 42}, {571, yb(571) - 38}}, {0.6,0.3})
st(lit, {{574, yb(574) - 27}, {583, yb(583) - 30}, {586, yb(586) - 24}}, {0.55,0.3})
st(lit, {{576, yb(576) - 11}, {585, yb(585) - 8}}, {0.5,0.3})
st(mid, {{550, yb(550) - 24}, {543, yb(543) - 31}, {540, yb(540) - 26}}, {0.5,0.3})
st(mid, {{546, yb(546) - 9}, {538, yb(538) - 5}}, {0.5,0.3})
-- soot streaks fanning down across the plates
local sb = brush{kind="round", width=3, point=0.3}
for k = 1, 14 do
  local a = rand(1.75, 2.6)
  local L = rand(40, 120)
  local x0, y0 = hc + rand(-8, 8), yb(hc) + rand(-2, 3)
  local pts = {}
  for i = 0, 5 do local u = i / 5; pts[#pts + 1] = {x0 + math.cos(a) * L * u, y0 + math.sin(a) * L * u * 0.55 + 6 * u * u} end
  sb:reload(soot, rand(0.25, 0.45)); sb:stroke(pts, {pressure={0.55, 0.0}, ramps={0.05, 0.9}})
end
work(poly({{545, yb(545)}, {578, yb(578)}, {520, yb(520) + 50}, {470, yb(470) + 60}}) - OUTM2, {hand="scumble", pile=soot, load=0.25, pressure={0.1,0.3}, coverage=0.9, clip=true, angle=2.5})

--@ chunk 18
print(SH3:area(), (SH3 - OUTM2):area(), SH3:at(300, yb(300)+5), yb(300))

--@ chunk 19
-- PASS 2: the sun sits a little behind and right of the outpost: its shadows fall long, down and left across the plates.
print(wait(2*1440))
local sh = nil
for _, m in ipairs(MODS2) do
  local xa, xb, h, lift = m[1], m[2], m[3], m[4]
  local H = h + lift
  local L, V = 1.6 * H, 0.65 * H
  local q = poly({{xa, yb(xa)}, {xb + DX, yb(xb) + DY}, {xb + DX - L, yb(xb + DX - L) + DY + V}, {xa - L, yb(xa - L) + V}})
  sh = sh and (sh + q) or q
end
sh = sh + ribbon({{487, yb(487) - 2}, {487 - 230, yb(257) + 100}}, 3.2) + ribbon({{399, yb(399) - 2}, {399 - 90, yb(309) + 40}, {399 - 60, yb(339) + 30}}, 2.4)
local m = sh - OUTM2:grow(0.6)
local deepT = pile{{"bone black",2},{"bone brown",0.8},{"ultramarine blue",0.4}, medium=0.3}
work(m, {hand="detail", tool="round 3", pile=deepT, coverage=3.5, fill=true, load=1})
print(m:area())

--@ chunk 20
-- PASS 2: deepen the night side past the terminator, a lean glaze so the plates still turn under it
print(wait(3*1440))
local lim = {}
for x = -10, 1010, 20 do lim[#lim + 1] = {x, yL(x) + 30} end
local night = (hullM * below(lim) * mask(function(x, y) return (sunAt(x, y) < 0.38) and 1 or 0 end)):soften(14) - OUTM2:grow(2)
work(night, {hand="glaze", pile=pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.4}, medium=0.7}, coverage=1.5, fill=true, clip=true, angle=-0.3})

--@ chunk 21
-- PASS 2: the night glaze went to a black wedge. Re-lay the plates on that side, dark bronze turning from dim lips into
-- shadow, so the terminator is plates rolling over, not a blot.
print(wait(4*1440))
local list = {}
for n = 1, 60000 do
  local r = SC * math.sqrt(n)
  local th = n * 2.399963
  local X, S = SPC[1] + r * math.cos(th), SPC[2] + r * math.sin(th)
  if S > 20 and S < 260 then
    local x, y, h = surfToCanvas(X, S)
    local d = y - yL(x)
    if d >= 30 and x > -50 and x < 1050 and y < 600 and sunAt(x, y) < 0.5 then list[#list + 1] = {x, y, h, S} end
  end
end
table.sort(list, function(a, b) return a[4] > b[4] end)
for _, p in ipairs(list) do
  local x, y, h = p[1], p[2], p[3]
  local hh = h * rand(1.25, 1.6)
  local ww = hh * rand(1.3, 1.55)
  local sl = (yL(x + 5) - yL(x - 5)) / 10
  local tilt = math.atan(sl) + randn(0, 0.12)
  local s = sunAt(x, y)
  -- across the band the lips fade; deep in the night they only just show
  plate2(x + randn(0, h * 0.06), y, ww, hh, tilt, clamp(0.16 + s * 0.9 + randn(0, 0.04), 0, 1), (math.random() < 0.012) and "missing" or "plain")
end
print(#list)
