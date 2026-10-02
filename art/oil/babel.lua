-- easel session "babel": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.4, linen={22,20}, seed=1563,
  ground={{pile={{"lead white",3},{"yellow ochre",0.3},{"cerulean blue",0.15}}, um=80, apply="knife", texture=0.1}}}
-- H = 714
HZ = 520
local sky = {
  {{"lead white",2},{"cerulean blue",0.55},{"bone black",0.05}},
  {{"lead white",2.4},{"cerulean blue",0.4},{"yellow ochre",0.05}},
  {{"lead white",2.8},{"cerulean blue",0.28},{"yellow ochre",0.12}},
  {{"lead white",3},{"cerulean blue",0.15},{"yellow ochre",0.25}},
}
local h = HZ / #sky
for i, s in ipairs(sky) do work(rect(0, (i - 1) * h - 4, 1000, h + 8) * rect(0, 0, 1000, HZ), {hand="broad", pile=pile(s), coverage=3, fill=true, clip=true, angle=0, load=0.9, ruler=true}) end
blend(rect(0, 0, 1000, HZ), {angle=0})
-- land: far hills grey-green, plain warm, foreground darker earth
work(rect(0, HZ - 6, 1000, 50), {hand="broad", pile=pile{{"lead white",1.5},{"viridian",0.3},{"yellow ochre",0.5},{"bone black",0.15}}, coverage=3, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, HZ + 40, 1000, 90), {hand="broad", pile=pile{{"yellow ochre",1},{"raw sienna",0.5},{"viridian",0.2},{"lead white",0.6}}, coverage=3, fill=true, clip=true, angle=0, load=1, ruler=true})
work(rect(0, HZ + 125, 1000, 80), {hand="broad", pile=pile{{"raw sienna",1},{"burnt sienna",0.4},{"bone brown",0.4},{"lead white",0.3}}, coverage=3, fill=true, clip=true, angle=0, load=1, ruler=true})
print(wait(3*1440))

--@ chunk 2
-- the tower: seven tiers on a cone, each band tilted a little upward to the right (the spiral)
CX = 450
TIERS = {}
local yb, wb = 640, 330
for i = 1, 7 do
  local th = 78 - i * 5
  local yt = yb - th
  local wt = wb - 34
  TIERS[i] = {yb = yb, yt = yt, wb = wb, wt = wt, tilt = 10}
  yb, wb = yt + 2, wt - 6
end
local LIT = pile{{"yellow ochre",1},{"raw sienna",0.4},{"lead white",0.9},{"burnt sienna",0.1}}
local MID = pile{{"raw sienna",1},{"burnt sienna",0.4},{"yellow ochre",0.4},{"lead white",0.35}}
local SHD = pile{{"burnt sienna",0.6},{"raw sienna",0.6},{"bone brown",0.6},{"lead white",0.15}}
TOWER = nil
for i, t in ipairs(TIERS) do
  local ragged = (i >= 6)
  local x0b, x1b, x0t, x1t = CX - t.wb, CX + t.wb, CX - t.wt, CX + t.wt
  local pts
  if ragged then
    pts = {{x0b, t.yb}, {x1b, t.yb - t.tilt}, {x1b - 20, t.yt + 30}, {x1b - 60, t.yt + 40}, {x1b - 90, t.yt + 5}, {x0t + 70, t.yt - 6}, {x0t, t.yt + 8}}
  else
    pts = {{x0b, t.yb}, {x1b, t.yb - t.tilt}, {x1t, t.yt - t.tilt}, {x0t, t.yt}}
  end
  local m = poly(pts)
  t.mask = m
  TOWER = TOWER and (TOWER + m) or m
  local L = rect(0, 0, CX - t.wb * 0.25, 800) * m
  local M = rect(CX - t.wb * 0.25, 0, t.wb * 0.75, 800) * m
  local S = rect(CX + t.wb * 0.5, 0, 600, 800) * m
  work(L, {hand="detail", tool="round 3", pile=LIT, coverage=5, fill=true, load=1})
  work(M, {hand="detail", tool="round 3", pile=MID, coverage=5, fill=true, load=1})
  work(S, {hand="detail", tool="round 3", pile=SHD, coverage=5, fill=true, load=1})
end
print(wait(3*1440))

--@ chunk 3
-- each tier as a drum: piers and arches wrapping round, foreshortened toward the edges; lit from the left
local P = {
  pile{{"yellow ochre",1},{"lead white",1.3},{"raw sienna",0.2}},
  pile{{"yellow ochre",1},{"raw sienna",0.4},{"lead white",0.9},{"burnt sienna",0.1}},
  pile{{"raw sienna",1},{"burnt sienna",0.35},{"yellow ochre",0.4},{"lead white",0.4}},
  pile{{"raw sienna",0.8},{"burnt sienna",0.5},{"bone brown",0.4},{"lead white",0.2}},
  pile{{"burnt sienna",0.6},{"bone brown",0.8},{"raw sienna",0.4},{"lead white",0.1}},
}
local ARCH = pile{{"bone brown",1},{"bone black",0.5},{"burnt sienna",0.3}}
local ARCHL = pile{{"burnt sienna",0.8},{"bone brown",0.6},{"raw sienna",0.4}}
local function shadeIdx(th) local k = clamp((th + 1.25) / 2.5, 0, 0.999); return math.floor(k * 5) + 1 end
for i, t in ipairs(TIERS) do
  local H = t.yb - t.yt
  local wM = (t.wb + t.wt) / 2
  local n = math.floor(30 - i * 2)
  for j = 0, n - 1 do
    local th0 = -1.45 + 2.9 * j / n; local th1 = -1.45 + 2.9 * (j + 1) / n
    local x0, x1 = CX + wM * math.sin(th0), CX + wM * math.sin(th1)
    local thm = (th0 + th1) / 2
    local xm = (x0 + x1) / 2
    local tiltY = -t.tilt * (xm - (CX - t.wb)) / (2 * t.wb)
    local ytop, ybot = t.yt + tiltY + 4, t.yb + tiltY - 2
    local wcol = x1 - x0
    if t.mask:at(xm, (ytop + ybot) / 2) > 0.5 then
      -- the pier's face
      local b = brush{kind="flat", width=math.max(2, wcol)}
      b:reload(P[shadeIdx(thm)], 0.9); b:stroke({{xm, ytop}, {xm, ybot}}, {pressure={0.85, 0.85}, orient="across", ramps={0.01, 0.01}, clip=t.mask})
      -- the arch opening: two storeys of arches on the lower tiers, one above
      local aw = wcol * 0.55
      if aw > 1.6 then
        for s = 1, (i <= 3) and 2 or 1 do
          local yA = ytop + H * ((s == 1) and 0.25 or 0.62); local yB = yA + H * 0.28
          local ab = brush{kind="round", width=aw, point=0.05}
          ab:reload((thm < -0.6) and ARCHL or ARCH, 0.9)
          ab:stroke({{xm, yA + aw * 0.4}, {xm, yB}}, {pressure={0.85, 0.85}, ramps={0.0, 0.01}, clip=t.mask})
        end
      end
    end
  end
  -- the ledge on top of the tier: a pale lit edge, a dark line under it
  local lb = brush{kind="round", width=3, point=0.2}
  local dl = brush{kind="round", width=2.4, point=0.2}
  for th = -1.45, 1.4, 0.15 do
    local xa, xb2 = CX + t.wt * math.sin(th) * 1.02, CX + t.wt * math.sin(th + 0.15) * 1.02
    local ya = t.yt - t.tilt * (xa - (CX - t.wb)) / (2 * t.wb)
    local yb2 = t.yt - t.tilt * (xb2 - (CX - t.wb)) / (2 * t.wb)
    lb:reload((th < 0.3) and P[1] or P[3], 0.8); lb:stroke({{xa, ya}, {xb2, yb2}}, {pressure={0.7, 0.7}, ramps={0.01, 0.01}, clip=t.mask:grow(2)})
    dl:reload(ARCH, 0.7); dl:stroke({{xa, ya + 4}, {xb2, yb2 + 4}}, {pressure={0.5, 0.5}, ramps={0.01, 0.01}, clip=t.mask})
  end
end

--@ chunk 4
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 1.6, point=0.5}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.02, 0.05}}) end
-- the Sun, much larger than ours, pale and warm, upper right
W(ellipse(830, 150, 95, 95), pile{{"lead white",3},{"lemon chrome",0.25},{"yellow ochre",0.1}}, "round 3")
W(ellipse(830, 150, 105, 105) - ellipse(830, 150, 95, 95), pile{{"lead white",2.6},{"yellow ochre",0.35},{"Mars orange",0.05}}, "round 2.5")
-- scaffolding on the unfinished upper tiers: poles and cross-braces
local wood = pile{{"bone brown",1},{"burnt sienna",0.6},{"lead white",0.2}}
local t6, t7 = TIERS[6], TIERS[7]
for x = CX + 20, CX + t6.wb - 10, 11 do st(wood, {{x, t6.yb - 4}, {x, t6.yt - 26}}, 1.4) end
for _, y in ipairs({t6.yt - 4, t6.yt - 18}) do st(wood, {{CX + 18, y + 2}, {CX + t6.wb - 8, y - 6}}, 1.3) end
for x = CX - 40, CX + 40, 14 do st(wood, {{x, t7.yb - 2}, {x, t7.yt - 34}}, 1.3) end
st(wood, {{CX - 42, t7.yt - 30}, {CX + 42, t7.yt - 34}}, 1.2)
-- cranes: treadwheel cranes with long jibs, on the upper tiers and one at the foot
local function crane(x, y, len, dir)
  st(wood, {{x, y}, {x, y - 22}}, 2.2)
  st(wood, {{x, y - 20}, {x + dir * len, y - 20 - len * 0.5}}, 1.4)
  st(wood, {{x + dir * len, y - 20 - len * 0.5}, {x + dir * len, y - 20 - len * 0.5 + 26}}, 0.9)
  local wh = {} for k = 0, 16 do local a = k * math.pi / 8; wh[#wh+1] = {x + 6 * math.cos(a), y - 8 + 6 * math.sin(a)} end
  st(wood, wh, 1.1)
end
crane(CX - 60, TIERS[7].yt + 4, 40, -1); crane(CX + 110, TIERS[6].yt + 4, 46, 1); crane(CX - 200, TIERS[4].yt + 4, 30, -1); crane(CX + 230, TIERS[3].yt + 2, 34, 1)
-- workers: tiny figures along the ledges, a dot head and a stroke body
local fig = pile{{"bone brown",1},{"bone black",0.5}}
local figR = pile{{"vermilion",0.6},{"burnt sienna",0.8},{"bone brown",0.3}}
local figW = pile{{"lead white",2},{"yellow ochre",0.3}}
for i, t in ipairs(TIERS) do
  local n = 14 - i
  for k = 1, n do
    local th = rand(-1.3, 1.3)
    local x = CX + t.wt * math.sin(th)
    local y = t.yt - t.tilt * (x - (CX - t.wb)) / (2 * t.wb) - 1
    local r = math.random()
    st((r < 0.6) and fig or ((r < 0.8) and figR or figW), {{x, y - 5}, {x, y}}, 1.6, {0.7, 0.7})
    local h = brush{kind="round", width=1.5, point=0.05}; h:reload(fig, 0.9); h:touch(x, y - 6.5, {pressure=0.7})
  end
end

--@ chunk 5
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 1.6, point=0.5}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.02, 0.05}}) end
-- the harbour: water on the right, from the tower's foot to the edge
local water = pile{{"lead white",1.6},{"cerulean blue",0.5},{"viridian",0.3},{"bone black",0.12}}
WATER = poly({{700, 600}, {1000, 560}, {1000, 714}, {760, 714}, {720, 660}}, true)
W(WATER, water, "round 3")
local wl = pile{{"lead white",2.6},{"cerulean blue",0.2}}
for i = 1, 30 do local x, y = rand(740, 990), rand(575, 705); if WATER:at(x, y) > 0.5 then st(wl, {{x, y}, {x + rand(8, 18), y}}, 1.2, {0.4, 0.3}) end end
-- ships arriving with materials: little hulls, masts, a few sails, and a cargo of bronze plates
local hull = pile{{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.3}}
local sail = pile{{"lead white",2.4},{"yellow ochre",0.3}}
local plates = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.4}}
for _, s in ipairs({{800, 610, 1}, {880, 640, 1.3}, {940, 590, 0.8}, {770, 670, 1.5}}) do
  local x, y, k = s[1], s[2], s[3]
  W(poly({{x - 22 * k, y}, {x + 22 * k, y}, {x + 16 * k, y + 8 * k}, {x - 16 * k, y + 8 * k}}), hull)
  st(hull, {{x, y}, {x, y - 34 * k}}, 1.4 * k)
  W(poly({{x + 1, y - 32 * k}, {x + 15 * k, y - 26 * k}, {x + 14 * k, y - 8 * k}, {x + 1, y - 6 * k}}), sail)
  st(plates, {{x - 16 * k, y - 2}, {x - 4 * k, y - 2}}, 3 * k, {0.8, 0.8})
end
-- quay along the harbour's edge with tiny figures hauling
st(pile{{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.3}}, {{700, 602}, {760, 596}, {840, 588}, {1000, 562}}, 5)
-- the solar sail lying furled in a long cradle at the left foot, like stacked timber
local cradle = pile{{"bone brown",1},{"burnt sienna",0.5},{"lead white",0.2}}
local furl = pile{{"lead white",2.2},{"yellow ochre",0.5},{"cerulean blue",0.1}}
local furlS = pile{{"lead white",1.2},{"yellow ochre",0.5},{"raw sienna",0.3},{"cerulean blue",0.1}}
FURL = poly({{20, 640}, {240, 618}, {250, 636}, {28, 660}}, true)
W(FURL, furl)
W(poly({{24, 652}, {246, 630}, {250, 636}, {28, 660}}), furlS)
for x = 34, 236, 28 do st(cradle, {{x, 638 - (x - 20) * 0.1}, {x - 3, 676 - (x - 20) * 0.1}}, 3) end
for x = 40, 240, 16 do st(furlS, {{x, 643 - (x - 20) * 0.1}, {x + 4, 653 - (x - 20) * 0.1}}, 1.2, {0.4, 0.4}) end
-- a little town of steep roofs in the left foreground
local roof = pile{{"burnt sienna",1},{"Mars red",0.3},{"bone brown",0.3}}
local wallH = pile{{"lead white",1.8},{"yellow ochre",0.5},{"raw sienna",0.15}}
for k = 0, 9 do
  local x = 30 + k * 26 + rand(-5, 5); local y = 690 + rand(-6, 10)
  W(rect(x, y - 14, 18, 16), wallH, "round 1.4")
  W(poly({{x - 2, y - 14}, {x + 9, y - 26}, {x + 20, y - 14}}), roof, "round 1.4")
end
print(wait(3*1440))

--@ chunk 6
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=5, fill=true, load=1}) end
local function st(p, pts, w, pr) local b = brush{kind="round", width=w or 1.6, point=0.5}; b:reload(p, 0.85); b:stroke(pts, {pressure=pr or {0.6, 0.6}, ramps={0.02, 0.05}}) end
-- new bronze scale-plate cladding going up on the top tiers, brighter than the weathered stone below
local bz = pile{{"yellow ochre",1},{"Mars orange",0.25},{"raw sienna",0.4},{"lead white",0.5}}
local bzD = pile{{"burnt sienna",1},{"raw sienna",0.4},{"bone brown",0.3}}
for i = 5, 7 do
  local t = TIERS[i]
  local H = t.yb - t.yt
  for row = 0, 2 do
    local y0 = t.yt + 5 + row * H / 3.3
    for th = -1.35, 0.6, 0.11 do
      local x = CX + ((t.wb + t.wt) / 2) * math.sin(th + row * 0.05)
      local y = y0 - t.tilt * (x - (CX - t.wb)) / (2 * t.wb)
      if t.mask:at(x, y + 3) > 0.5 then
        local w = 6 * math.cos(th) + 1.5
        local pts = {} for k = 0, 6 do local a = math.pi * k / 6; pts[#pts+1] = {x + w * math.cos(a), y + 3 * math.sin(a)} end
        st((th < -0.2) and bz or bzD, pts, 1.2, {0.55, 0.55})
      end
    end
  end
end
-- a long low cloud drifting across the upper tower, as in Bruegel
local cl = pile{{"lead white",2.8},{"cerulean blue",0.08},{"yellow ochre",0.06}}
local clS = pile{{"lead white",2.2},{"cerulean blue",0.15},{"bone black",0.08}}
for i = 1, 16 do
  local x = rand(150, 560); local y = rand(258, 280)
  local b = brush{kind="filbert", width=rand(12, 20)}; b:reload(cl, 0.6)
  b:stroke({{x, y}, {x + rand(40, 90), y + rand(-4, 4)}}, {pressure={0.6, 0.15}, ramps={0.3, 0.5}})
end
for i = 1, 8 do
  local x = rand(170, 540); local y = rand(278, 288)
  local b = brush{kind="filbert", width=rand(8, 12)}; b:reload(clS, 0.5)
  b:stroke({{x, y}, {x + rand(40, 80), y}}, {pressure={0.5, 0.15}, ramps={0.3, 0.5}})
end
-- great gate arches at the foot, dark, with figures streaming in
local dk = pile{{"bone brown",1},{"bone black",0.6}}
for _, x in ipairs({250, 380, 520}) do W(rect(x - 14, 610, 28, 30) + ellipse(x, 610, 14, 14), dk) end
-- tiny figures on the quay, around the cradle and along a road
local fig = pile{{"bone brown",1},{"bone black",0.5}}
local figR = pile{{"vermilion",0.6},{"burnt sienna",0.8}}
local figW = pile{{"lead white",2},{"yellow ochre",0.3}}
local function man(x, y, s) s = s or 1; local r = math.random(); st((r < 0.55) and fig or ((r < 0.8) and figR or figW), {{x, y - 6 * s}, {x, y}}, 1.8 * s, {0.7, 0.7}); local h = brush{kind="round", width=1.8 * s, point=0.05}; h:reload(fig, 0.9); h:touch(x, y - 7.5 * s, {pressure=0.7}) end
for k = 1, 16 do local t = rand(0, 1); man(lerp(700, 960, t), lerp(598, 566, t) - 2) end
for k = 1, 14 do man(rand(30, 250), rand(664, 676), 1.2) end
for k = 1, 12 do local t = rand(0, 1); man(lerp(250, 650, t), 650 + rand(-4, 4)) end
for k = 1, 8 do man(rand(240, 540), rand(642, 648), 0.9) end
