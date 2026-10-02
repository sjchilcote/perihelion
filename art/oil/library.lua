-- easel session "library": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=800, aspect=0.8, linen={18,16}, seed=7331,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.7},{"lead white",0.6}}, um=110, apply="knife", texture=0.4}}}
-- one-point; Y down from the eye; walkway at Y = 1.6; shelf walls at X = +-1.0, running up and down out of sight
VX, VY, F = 500, 560, 500
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY, SX, WK = 1.6, 1.0, 0.5
ZN, ZFAR = 0.9, 400
LWALL = poly({pt(-SX, -60, ZN), pt(-SX, -60, ZFAR), pt(-SX, 60, ZFAR), pt(-SX, 60, ZN)})
RWALL = poly({pt(SX, -60, ZN), pt(SX, -60, ZFAR), pt(SX, 60, ZFAR), pt(SX, 60, ZN)})
WALK = poly({pt(-WK, FY, ZN), pt(-WK, FY, ZFAR), pt(WK, FY, ZFAR), pt(WK, FY, ZN)})
-- the reading stations: the same chair, lamp and docent again and again, each twice as far
STZ = {3.4, 6.8, 13.6, 27.2, 54.4, 108.8}
print(W, H, LWALL:area(), WALK:area(), P(-SX, 0, 3.4))

--@ chunk 2
-- lay-in dark: shelf walls a dark umber, the shaft between them and below the walkway near-black and cool
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local void = everywhere() - LWALL - RWALL
local vk = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}, medium=0.06}
work(void, {hand="body", tool="filbert 10", pile=vk, coverage=4, fill=true, clip=void, angle=toVP, load=1})
local wd = pile{{"bone black",1.8},{"burnt sienna",0.8},{"ultramarine blue",0.3}, medium=0.06}
work(LWALL + RWALL, {hand="body", tool="filbert 12", pile=wd, coverage=4, fill=true, clip=LWALL + RWALL, angle=toVP, load=1})
local wk = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
work(WALK, {hand="body", tool="filbert 6", pile=wk, coverage=4, fill=true, clip=WALK, angle=toVP, load=1})

--@ chunk 3
-- lamplight on the shelves at each station: a warm pool on both walls round the lamp's height, two steps
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local LY = FY - 1.25
local function pool(side, Z, dz, dy)
  local t = {}
  for j = 0, 23 do
    local a = 2 * math.pi * j / 24
    t[#t+1] = pt(side * SX, LY + dy * math.sin(a), Z + dz * math.cos(a))
  end
  return poly(t, true)
end
local o = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.8},{"yellow ochre",0.3}, medium=0.06}
local m = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.5},{"lead white",0.35},{"bone black",0.15}, medium=0.06}
POOLS = nil
for _, Z in ipairs(STZ) do
  if Z < 60 then
    for _, side in ipairs{-1, 1} do
      local w = (side < 0) and LWALL or RWALL
      local A = pool(side, Z, 1.6, 2.2) * w
      local B = pool(side, Z, 0.85, 1.2) * w
      local tool = {kind="filbert", width=math.max(1.5, math.min(9, 0.3 * F / Z))}
      work(A - B, {hand="body", tool=tool, pile=o, coverage=4, fill=true, clip=A - B, angle=toVP, load=1})
      work(B, {hand="body", tool=tool, pile=m, coverage=4, fill=true, clip=B, angle=toVP, load=1})
      POOLS = POOLS and (POOLS + A) or A
    end
  end
end

--@ chunk 4
-- shelves and their tablets: bone tablets standing on each shelf, bronze cases among them, lit only in the lamp pools
print(wait(2*24*60))
SHY = {}
for k = -8, 10 do SHY[#SHY+1] = k * 0.42 + 0.05 end
local dark = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.3}, medium=0.06}
local boneL = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.15}, medium=0.06}
local boneM = pile{{"lead white",1},{"yellow ochre",0.5},{"burnt sienna",0.3},{"bone black",0.4}, medium=0.06}
local boneD = pile{{"bone black",1.4},{"burnt sienna",0.6},{"lead white",0.35},{"ultramarine ash",0.3}, medium=0.06}
local brzL = pile{{"Mars orange",0.6},{"yellow ochre",1},{"burnt sienna",0.8},{"lead white",0.3}, medium=0.06}
local brzD = pile{{"burnt sienna",1},{"Mars brown",0.6},{"bone black",0.8}, medium=0.06}
local n = 0
local seed = 0
for _, side in ipairs{-1, 1} do
  local wall = (side < 0) and LWALL or RWALL
  for _, Y in ipairs(SHY) do
    local Z = 0.92
    while Z < 40 do
      seed = seed + 1
      local h = (seed * 0.618034) % 1
      local h2 = (seed * 0.381966 + 0.3) % 1
      local th = (h < 0.12) and 0.18 or 0.05      -- a bronze case is wider
      local x0, yb = P(side * SX, Y, Z)
      local _, yt = P(side * SX, Y - (0.26 + 0.1 * h2), Z)
      if yb > -20 and yt < H + 20 and x0 > -20 and x0 < W + 20 then
        local lit = POOLS:at(x0, (yb + yt) / 2) > 0.4
        local pl
        if h < 0.12 then pl = lit and brzL or brzD
        elseif h < 0.2 then pl = nil
        else pl = lit and ((h2 < 0.6) and boneL or boneM) or boneD end
        if pl then
          local w = math.max(0.7, F * side * SX * th / (Z * (Z + th)) * side * 0.85)
          local b = brush{kind="flat", width=math.max(0.7, math.min(14, w)), stiffness=0.6}
          b:load(pl, 0.9)
          b:stroke({{x0, yb}, {x0, yt}}, {pressure={0.85, 0.85}, ramps={0.03, 0.03}, orient="across"})
          n = n + 1
        end
      end
      local step = math.max(0.055, 7 * Z * Z / (F * SX)) * (1 + 0.3 * h2)
      Z = Z + math.max(step, th + 0.01)
    end
    -- the shelf board itself: a dark line converging to the stack's vanishing point
    local b = brush{kind="round", width=math.max(1.2, 0.05 * F / 0.95), stiffness=0.6}
    b:load(dark, 1)
    b:stroke({pt(side * SX, Y + 0.02, 0.92), pt(side * SX, Y + 0.02, 3), pt(side * SX, Y + 0.02, 40)}, {pressure={0.9, 0.05}, ramps={0.02, 0.02}, clip=wall})
  end
end
print("tablets", n)

--@ chunk 5
-- the walkway restated in front of the shelves (bronze grating), then the stations: lamp, reading chair, docent at its desk
print(wait(1*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local wk = pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
work(WALK, {hand="body", tool="filbert 6", pile=wk, coverage=5, fill=true, clip=WALK, angle=toVP, load=1})
local gr = pile{{"bone black",2},{"ultramarine blue",0.3}, medium=0.06}
for _, Z in ipairs{1.0, 1.15, 1.32, 1.52, 1.75, 2.0, 2.3, 2.65, 3.05, 3.5, 4.0, 4.6, 5.3, 6.1, 7.0, 8.1, 9.3, 10.7, 12.3, 14.2} do
  local b = brush{kind="flat", width=math.max(0.6, 0.025 * F / Z)}
  b:load(gr, 0.9); b:stroke({pt(-WK, FY, Z), pt(WK, FY, Z)}, {pressure={0.7, 0.7}, orient="across", clip=WALK})
end
local edgeL = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.5},{"lead white",0.3}, medium=0.06}
for _, X in ipairs{-WK, WK} do
  local b = brush{kind="round", width=3, point=0.3}
  b:load(edgeL, 0.9); b:stroke({pt(X, FY, 0.95), pt(X, FY, 40)}, {pressure={0.8, 0.1}})
end
local brD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.06}
local brM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"yellow ochre",0.5},{"bone black",0.3}, medium=0.06}
local shade = pile{{"lead white",2.5},{"yellow ochre",0.5},{"cadmium yellow",0.25}, medium=0.05}
local core = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}, medium=0.05}
local boneF = pile{{"lead white",1.6},{"yellow ochre",0.6},{"raw sienna",0.1}, medium=0.06}
local function st(pts, pl, w, pr, kind)
  local b = brush{kind=kind or "round", width=math.max(0.6, w), stiffness=0.5}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}})
end
for i = #STZ, 1, -1 do
  local Z = STZ[i]
  local k = F / Z
  -- the lamp: a slender bronze stem, a bone shade glowing
  local lx, ly = P(-0.4, FY, Z)
  st({{lx, ly}, {lx, ly - 1.25 * k}}, brD, 0.025 * k, {0.9, 0.9})
  local sh = poly({{lx - 0.1 * k, ly - 1.22 * k}, {lx + 0.1 * k, ly - 1.22 * k}, {lx + 0.06 * k, ly - 1.4 * k}, {lx - 0.06 * k, ly - 1.4 * k}})
  work(sh, {hand="detail", pile=shade, coverage=4, fill=true, clip=sh, load=1})
  local c = ellipse(lx, ly - 1.25 * k, 0.05 * k, 0.025 * k)
  work(c, {hand="detail", pile=core, coverage=4, fill=true, clip=c, load=1})
  -- the reading chair beside it: pedestal, lens seat, tall back turned toward the lamp
  local cx, cy = P(-0.22, FY, Z + 0.3)
  local k2 = F / (Z + 0.3)
  st({{cx, cy}, {cx, cy - 0.45 * k2}}, brD, 0.04 * k2, {0.9, 0.9})
  st({{cx - 0.2 * k2, cy - 0.47 * k2}, {cx + 0.2 * k2, cy - 0.47 * k2}}, brM, 0.06 * k2, {0.8, 0.8}, "filbert")
  st({{cx - 0.17 * k2, cy - 0.5 * k2}, {cx - 0.19 * k2, cy - 1.15 * k2}}, brM, 0.09 * k2, {0.85, 0.7}, "filbert")
  -- the docent at its desk on the right: desk slab, bell body, bone face-plate bowed over a tablet
  local dx, dy = P(0.3, FY, Z + 0.2)
  local k3 = F / (Z + 0.2)
  local desk = poly({{dx - 0.22 * k3, dy - 0.75 * k3}, {dx + 0.18 * k3, dy - 0.75 * k3}, {dx + 0.18 * k3, dy}, {dx - 0.22 * k3, dy}})
  work(desk, {hand="detail", pile=brD, coverage=4, fill=true, clip=desk, load=1})
  local top = rect(dx - 0.25 * k3, dy - 0.8 * k3, 0.45 * k3, 0.06 * k3)
  work(top, {hand="detail", pile=brM, coverage=4, fill=true, clip=top, load=1})
  local bell = poly({{dx + 0.02 * k3, dy - 1.55 * k3}, {dx + 0.14 * k3, dy - 1.5 * k3}, {dx + 0.2 * k3, dy - 0.8 * k3}, {dx - 0.08 * k3, dy - 0.8 * k3}, {dx - 0.06 * k3, dy - 1.45 * k3}}, true)
  work(bell, {hand="detail", pile=brM, coverage=4, fill=true, clip=bell, load=1})
  local face = ellipse(dx - 0.04 * k3, dy - 1.5 * k3, 0.06 * k3, 0.08 * k3)
  work(face, {hand="detail", pile=boneF, coverage=4, fill=true, clip=face, load=1})
  st({{dx - 0.18 * k3, dy - 0.82 * k3}, {dx - 0.02 * k3, dy - 0.83 * k3}}, boneF, 0.025 * k3, {0.8, 0.8})
  -- lamp-side rim on the docent
  st({{dx - 0.07 * k3, dy - 1.4 * k3}, {dx - 0.09 * k3, dy - 0.85 * k3}}, shade, 0.015 * k3, {0.6, 0.3})
end

--@ chunk 6
-- the Commando at the first lamp, reading a tablet held up to it; lamp spill on the walkway at each station
print(wait(1*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local spillP = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.6},{"lead white",0.3},{"bone black",0.3}, medium=0.06}
for i = #STZ, 1, -1 do
  local Z = STZ[i]
  local t = {}
  for j = 0, 15 do local a = 2 * math.pi * j / 16; t[#t+1] = pt(-0.2 + 0.32 * math.cos(a), FY, Z + 0.55 * math.sin(a)) end
  local m = poly(t, true) * WALK
  work(m, {hand="detail", pile=spillP, coverage=3, fill=true, clip=m, load=0.9})
end
local Z = 2.9
local k = F / Z
local fx, fy = P(-0.05, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.1,0.93), Q(-0.12,0.52), Q(-0.12,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.1,0.93), Q(0.12,0.52), Q(0.13,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.24,0.0), Q(-0.04,0.0), Q(-0.05,0.14), Q(-0.22,0.14)}) + poly({Q(0.04,0.0), Q(0.24,0.0), Q(0.22,0.14), Q(0.05,0.14)})
  + poly({Q(-0.19,0.88), Q(0.19,0.88), Q(0.2,1.06), Q(-0.2,1.06)}, true)
  + poly({Q(-0.17,1.02), Q(0.17,1.02), Q(0.23,1.32), Q(0.3,1.5), Q(0.27,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.27,1.58), Q(-0.3,1.5), Q(-0.23,1.32)}, true)
  + poly({Q(-0.17,1.12), Q(0.16,1.12), Q(0.18,1.52), Q(-0.18,1.53)})
  + poly({Q(-0.06,1.52), Q(0.04,1.52), Q(0.02,1.63), Q(-0.08,1.63)})
  + ellipse(fx - 0.04 * k, fy - 1.71 * k, 0.105 * k, 0.13 * k)                 -- head bowed a little, toward the tablet
  + ellipse(fx - 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k) + ellipse(fx + 0.29 * k, fy - 1.54 * k, 0.12 * k, 0.08 * k)
  + ribbon({Q(-0.3,1.5), Q(-0.38,1.32), Q(-0.3,1.22)}, {0.12*k, 0.1*k, 0.09*k})   -- both forearms raised before him
  + ribbon({Q(0.3,1.5), Q(0.3,1.3), Q(0.12,1.27)}, {0.12*k, 0.1*k, 0.09*k})
local figD = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.25}, medium=0.06}
work(fig, {hand="detail", pile=figD, coverage=5, fill=true, clip=fig, load=1})
-- the tablet, held up at his left toward the lamp, its fold-notation catching the light
local tab = poly({Q(-0.46,1.42), Q(-0.3,1.44), Q(-0.29,1.2), Q(-0.45,1.18)})
work(tab, {hand="detail", pile=pile{{"lead white",2.4},{"yellow ochre",0.5},{"cadmium yellow",0.15}, medium=0.05}, coverage=5, fill=true, clip=tab, load=1})
local ink = pile{{"burnt sienna",1},{"bone black",0.8}, medium=0.06}
local tc = Q(-0.375, 1.31)
local r, rot = 0.055 * k, 0.3
for nn = 1, 3 do
  local pts = {}
  for j = 0, 5 do local a = rot + 2 * math.pi * j / 5; pts[#pts+1] = {tc[1] + r * math.cos(a), tc[2] + r * math.sin(a)} end
  local b = brush{kind="round", width=1.0, point=0.4}
  b:load(ink, 0.7); b:stroke(pts, {pressure={0.5, 0.5}, clip=tab})
  r = r * 0.6; rot = rot + 2.399963
end
-- the lamp's warmth on his left edges
local rim = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.06}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(rim, 0.85); b:stroke(pts, {pressure=pr, clip=fig})
end
ln({Q(-0.08,1.82), Q(-0.14,1.74), Q(-0.14,1.64)}, 2.2, {0.8, 0.5})
ln({Q(-0.38,1.56), Q(-0.3,1.62), Q(-0.15,1.61)}, 2.2, {0.7, 0.7})
ln({Q(-0.43,1.35), Q(-0.42,1.25)}, 2.0, {0.7, 0.5})
ln({Q(-0.24,1.3), Q(-0.23,1.04)}, 1.6, {0.5, 0.2})
ln({Q(-0.2,0.9), Q(-0.22,0.5), Q(-0.2,0.15)}, 1.6, {0.5, 0.1})
GF = fig

--@ chunk 7
-- the figure came out a ghost over wet paint: let it set, then restate him opaque, the tablet and the rims again
print(wait(4*24*60))
local Z = 2.9
local k = F / Z
local fx, fy = P(-0.05, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local figD = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.25}, medium=0.06}
work(GF, {hand="body", tool="filbert 4", pile=figD, coverage=6, fill=true, clip=GF, angle=math.pi/2, load=1})
print(wait(2*24*60))
local tab = poly({Q(-0.46,1.42), Q(-0.3,1.44), Q(-0.29,1.2), Q(-0.45,1.18)})
work(tab, {hand="body", tool="filbert 3", pile=pile{{"lead white",2.4},{"yellow ochre",0.5},{"cadmium yellow",0.15}, medium=0.05}, coverage=6, fill=true, clip=tab, load=1})
local rim = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.2}, medium=0.06}
local function ln(pts, w, pr)
  local b = brush{kind="round", width=w, point=0.6}
  b:load(rim, 0.9); b:stroke(pts, {pressure=pr, clip=GF})
end
ln({Q(-0.08,1.82), Q(-0.14,1.74), Q(-0.14,1.64)}, 2.4, {0.85, 0.5})
ln({Q(-0.38,1.56), Q(-0.3,1.62), Q(-0.15,1.61)}, 2.4, {0.8, 0.7})
ln({Q(-0.43,1.35), Q(-0.42,1.25)}, 2.2, {0.8, 0.5})
ln({Q(-0.24,1.3), Q(-0.23,1.04)}, 1.8, {0.6, 0.2})
ln({Q(-0.2,0.9), Q(-0.22,0.5), Q(-0.2,0.15)}, 1.8, {0.6, 0.1})
-- the pool of lamp-spill at his feet: its hard rim lost
local t = {}
for j = 0, 15 do local a = 2 * math.pi * j / 16; t[#t+1] = pt(-0.2 + 0.32 * math.cos(a), FY, 3.4 + 0.55 * math.sin(a)) end
local m = poly(t, true)
blend((m:grow(5) - m:shrink(5)) * WALK - GF:grow(2))

--@ chunk 8
-- his reading lamp, tall, just beyond him on the left, its shade above the tablet; stronger warm edges on him
print(wait(1*24*60))
local Z, X = 3.1, -0.62
local k = F / Z
local lx, ly = P(X, FY, Z)
local brD = pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.5}, medium=0.06}
local b = brush{kind="round", width=0.03 * k, stiffness=0.6}
b:load(brD, 1); b:stroke({{lx, ly}, {lx, ly - 1.72 * k}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, clip=-GF})
local glow = ellipse(lx, ly - 1.8 * k, 0.28 * k, 0.24 * k) - GF
work(glow, {hand="scumble", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.8},{"burnt sienna",0.2}, medium=0.06}, coverage=1.6, clip=glow, load=0.6})
blend((ellipse(lx, ly - 1.8 * k, 0.32 * k, 0.28 * k) - ellipse(lx, ly - 1.8 * k, 0.18 * k, 0.15 * k)) - GF)
local sh = poly({{lx - 0.11 * k, ly - 1.72 * k}, {lx + 0.11 * k, ly - 1.72 * k}, {lx + 0.065 * k, ly - 1.9 * k}, {lx - 0.065 * k, ly - 1.9 * k}}) - GF
work(sh, {hand="detail", pile=pile{{"lead white",2.5},{"yellow ochre",0.45},{"cadmium yellow",0.25}, medium=0.05}, coverage=5, fill=true, clip=sh, load=1})
local c = ellipse(lx, ly - 1.72 * k, 0.07 * k, 0.025 * k) - GF
work(c, {hand="detail", pile=pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}, medium=0.05}, coverage=5, fill=true, clip=c, load=1})
-- warm edges on the figure facing the lamp
local fk = F / 2.9
local fx, fy = P(-0.05, FY, 2.9)
local function Q(x, y) return {fx + x * fk, fy - y * fk} end
local rim = pile{{"lead white",2.2},{"yellow ochre",0.7},{"cadmium yellow",0.25}, medium=0.05}
local function ln(pts, w, pr)
  local bb = brush{kind="round", width=w, point=0.5}
  bb:load(rim, 0.95); bb:stroke(pts, {pressure=pr})
end
ln({Q(-0.1,1.83), Q(-0.15,1.76), Q(-0.15,1.66)}, 3, {0.9, 0.5})
ln({Q(-0.4,1.55), Q(-0.33,1.61), Q(-0.18,1.62)}, 3, {0.8, 0.8})
ln({Q(-0.44,1.4), Q(-0.43,1.26)}, 2.6, {0.8, 0.5})
ln({Q(-0.235,0.9), Q(-0.25,0.5), Q(-0.23,0.15)}, 2.2, {0.7, 0.1})

--@ chunk 9
-- pass: the walls repainted in lean cool darks (no white), painting out the oval pools, the old tablets and the lamp globe
print(wait(3*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local keep = GF:grow(1.5) + WALK
local walls = (LWALL + RWALL) - keep
local dk = pile{{"bone black",2},{"ultramarine blue",0.45},{"burnt sienna",0.45}, medium=0.06}
work(walls, {hand="body", tool="filbert 12", pile=dk, coverage=4, fill=true, clip=walls, angle=toVP, load=1})
local void = everywhere() - LWALL - RWALL - WALK - GF:grow(1.5)
work(void, {hand="body", tool="filbert 6", pile=pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.2}, medium=0.06}, coverage=4, fill=true, clip=void, angle=toVP, load=1})

--@ chunk 10
print(wait(3*24*60))
SIDE = -1
-- tablets restated on one wall, lit by the lamps as a falloff: dim body everywhere, lit top end and lamp-side edge near a lamp
LAMPS = {{X=-0.62, Y=FY - 1.8, Z=3.1}}
for i = 2, #STZ do LAMPS[#LAMPS+1] = {X=-0.4, Y=FY - 1.3, Z=STZ[i]} end
function LIGHT(X, Y, Z)
  local best, src = 0, nil
  for _, l in ipairs(LAMPS) do
    local d2 = ((Z - l.Z) / 1.5)^2 + ((Y - l.Y) / 1.7)^2 + ((X - l.X) / 1.4)^2
    local v = math.exp(-d2)
    if v > best then best, src = v, l end
  end
  return best, src
end
local side = SIDE
local wall = (side < 0) and LWALL or RWALL
local body = {
  pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.5}, medium=0.06},
  pile{{"bone black",1.5},{"burnt sienna",0.8},{"raw sienna",0.5}, medium=0.06},
  pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06},
  pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.4}, medium=0.06},
}
local capM = pile{{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.3}, medium=0.06}
local capH = pile{{"lead white",2.2},{"yellow ochre",0.5},{"cadmium yellow",0.15}, medium=0.05}
local brz = {pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}, pile{{"burnt sienna",1},{"Mars orange",0.5},{"yellow ochre",0.6},{"bone black",0.3}, medium=0.06}}
local shelfD = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
local lipP = pile{{"yellow ochre",1},{"raw sienna",0.8},{"lead white",0.5}, medium=0.06}
local seed = (side < 0) and 0 or 50000
local n = 0
local clipw = wall - GF:grow(1.5)
for _, Y in ipairs(SHY) do
  local Z = 0.92
  while Z < 40 do
    seed = seed + 1
    local h = (seed * 0.618034) % 1
    local h2 = (seed * 0.381966 + 0.3) % 1
    local th = (h < 0.1) and 0.18 or 0.05
    local x0, yb = P(side * SX, Y, Z)
    local tall = 0.26 + 0.1 * h2
    local _, yt = P(side * SX, Y - tall, Z)
    if yb > -20 and yt < H + 20 and x0 > -20 and x0 < W + 20 and h >= 0.06 then
      local L, src = LIGHT(side * SX, Y - tall / 2, Z)
      local lvl = (L > 0.55) and 4 or ((L > 0.25) and 3 or ((L > 0.08) and 2 or 1))
      local w = math.max(0.7, math.min(14, F * SX * th / (Z * (Z + th)) * 0.85))
      local b = brush{kind="flat", width=w, stiffness=0.6}
      b:load((h < 0.1) and brz[(lvl >= 3) and 2 or 1] or body[lvl], 0.9)
      b:stroke({{x0, yb}, {x0, yt}}, {pressure={0.85, 0.85}, ramps={0.03, 0.03}, orient="across", clip=clipw})
      if L > 0.12 and h >= 0.1 then
        -- the lit top end, and the edge toward the lamp
        local cb = brush{kind="flat", width=w, stiffness=0.6}
        cb:load((L > 0.45) and capH or capM, 0.85)
        local ch = (yb - yt) * (0.08 + 0.1 * L)
        cb:stroke({{x0, yt}, {x0, yt + ch}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, orient="across", clip=clipw})
        if L > 0.3 then
          local toward = (src.Z < Z) and -1 or 1
          local ex = x0 + toward * w * 0.45 * ((side < 0) and -1 or 1) * -1
          local eb = brush{kind="round", width=math.max(0.6, w * 0.22), point=0.4}
          eb:load(capM, 0.7)
          eb:stroke({{ex, yt + ch}, {ex, yt + (yb - yt) * (0.3 + 0.5 * L)}}, {pressure={0.6, 0.1}, clip=clipw})
        end
      end
      n = n + 1
    end
    local step = math.max(0.055, 7 * Z * Z / (F * SX)) * (1 + 0.3 * h2)
    Z = Z + math.max(step, th + 0.01)
  end
  local bb = brush{kind="round", width=0.05 * F / 0.95, stiffness=0.6}
  bb:load(shelfD, 1)
  bb:stroke({pt(side * SX, Y + 0.02, 0.92), pt(side * SX, Y + 0.02, 3), pt(side * SX, Y + 0.02, 40)}, {pressure={0.9, 0.05}, ramps={0.02, 0.02}, clip=clipw})
  -- the shelf's front lip, warm only near each lamp
  for _, l in ipairs(LAMPS) do
    if math.abs(Y - l.Y) < 2.2 and l.Z < 30 then
      local lb = brush{kind="round", width=math.max(0.7, 0.012 * F / l.Z), point=0.4}
      lb:load(lipP, 0.8)
      local a = math.exp(-((Y - l.Y) / 1.7)^2)
      lb:stroke({pt(side * SX, Y + 0.005, math.max(0.95, l.Z - 1.6 * a)), pt(side * SX, Y + 0.005, l.Z), pt(side * SX, Y + 0.005, l.Z + 1.6 * a)}, {pressure={0.05, 0.7 * a + 0.1}, swell={0.2, 1, 0.2}, clip=clipw})
    end
  end
end
print("tablets", n)

--@ chunk 11
SIDE = 1
-- tablets restated on one wall, lit by the lamps as a falloff: dim body everywhere, lit top end and lamp-side edge near a lamp
LAMPS = {{X=-0.62, Y=FY - 1.8, Z=3.1}}
for i = 2, #STZ do LAMPS[#LAMPS+1] = {X=-0.4, Y=FY - 1.3, Z=STZ[i]} end
function LIGHT(X, Y, Z)
  local best, src = 0, nil
  for _, l in ipairs(LAMPS) do
    local d2 = ((Z - l.Z) / 1.5)^2 + ((Y - l.Y) / 1.7)^2 + ((X - l.X) / 1.4)^2
    local v = math.exp(-d2)
    if v > best then best, src = v, l end
  end
  return best, src
end
local side = SIDE
local wall = (side < 0) and LWALL or RWALL
local body = {
  pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine ash",0.5}, medium=0.06},
  pile{{"bone black",1.5},{"burnt sienna",0.8},{"raw sienna",0.5}, medium=0.06},
  pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.6},{"yellow ochre",0.3}, medium=0.06},
  pile{{"raw sienna",1},{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.4}, medium=0.06},
}
local capM = pile{{"yellow ochre",1},{"lead white",0.8},{"raw sienna",0.3}, medium=0.06}
local capH = pile{{"lead white",2.2},{"yellow ochre",0.5},{"cadmium yellow",0.15}, medium=0.05}
local brz = {pile{{"bone black",1.5},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}, pile{{"burnt sienna",1},{"Mars orange",0.5},{"yellow ochre",0.6},{"bone black",0.3}, medium=0.06}}
local shelfD = pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}
local lipP = pile{{"yellow ochre",1},{"raw sienna",0.8},{"lead white",0.5}, medium=0.06}
local seed = (side < 0) and 0 or 50000
local n = 0
local clipw = wall - GF:grow(1.5)
for _, Y in ipairs(SHY) do
  local Z = 0.92
  while Z < 40 do
    seed = seed + 1
    local h = (seed * 0.618034) % 1
    local h2 = (seed * 0.381966 + 0.3) % 1
    local th = (h < 0.1) and 0.18 or 0.05
    local x0, yb = P(side * SX, Y, Z)
    local tall = 0.26 + 0.1 * h2
    local _, yt = P(side * SX, Y - tall, Z)
    if yb > -20 and yt < H + 20 and x0 > -20 and x0 < W + 20 and h >= 0.06 then
      local L, src = LIGHT(side * SX, Y - tall / 2, Z)
      local lvl = (L > 0.55) and 4 or ((L > 0.25) and 3 or ((L > 0.08) and 2 or 1))
      local w = math.max(0.7, math.min(14, F * SX * th / (Z * (Z + th)) * 0.85))
      local b = brush{kind="flat", width=w, stiffness=0.6}
      b:load((h < 0.1) and brz[(lvl >= 3) and 2 or 1] or body[lvl], 0.9)
      b:stroke({{x0, yb}, {x0, yt}}, {pressure={0.85, 0.85}, ramps={0.03, 0.03}, orient="across", clip=clipw})
      if L > 0.12 and h >= 0.1 then
        -- the lit top end, and the edge toward the lamp
        local cb = brush{kind="flat", width=w, stiffness=0.6}
        cb:load((L > 0.45) and capH or capM, 0.85)
        local ch = (yb - yt) * (0.08 + 0.1 * L)
        cb:stroke({{x0, yt}, {x0, yt + ch}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, orient="across", clip=clipw})
        if L > 0.3 then
          local toward = (src.Z < Z) and -1 or 1
          local ex = x0 + toward * w * 0.45 * ((side < 0) and -1 or 1) * -1
          local eb = brush{kind="round", width=math.max(0.6, w * 0.22), point=0.4}
          eb:load(capM, 0.7)
          eb:stroke({{ex, yt + ch}, {ex, yt + (yb - yt) * (0.3 + 0.5 * L)}}, {pressure={0.6, 0.1}, clip=clipw})
        end
      end
      n = n + 1
    end
    local step = math.max(0.055, 7 * Z * Z / (F * SX)) * (1 + 0.3 * h2)
    Z = Z + math.max(step, th + 0.01)
  end
  local bb = brush{kind="round", width=0.05 * F / 0.95, stiffness=0.6}
  bb:load(shelfD, 1)
  bb:stroke({pt(side * SX, Y + 0.02, 0.92), pt(side * SX, Y + 0.02, 3), pt(side * SX, Y + 0.02, 40)}, {pressure={0.9, 0.05}, ramps={0.02, 0.02}, clip=clipw})
  -- the shelf's front lip, warm only near each lamp
  for _, l in ipairs(LAMPS) do
    if math.abs(Y - l.Y) < 2.2 and l.Z < 30 then
      local lb = brush{kind="round", width=math.max(0.7, 0.012 * F / l.Z), point=0.4}
      lb:load(lipP, 0.8)
      local a = math.exp(-((Y - l.Y) / 1.7)^2)
      lb:stroke({pt(side * SX, Y + 0.005, math.max(0.95, l.Z - 1.6 * a)), pt(side * SX, Y + 0.005, l.Z), pt(side * SX, Y + 0.005, l.Z + 1.6 * a)}, {pressure={0.05, 0.7 * a + 0.1}, swell={0.2, 1, 0.2}, clip=clipw})
    end
  end
end
print("tablets", n)

--@ chunk 12
-- the walkway pools, soft and long along the walk; the stations restated thin and legible; the lamps as small shades with a soft glow
print(wait(1*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local wk = pile{{"bone black",1.6},{"burnt sienna",0.9},{"Mars brown",0.3}, medium=0.06}
local wkM = pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.6},{"yellow ochre",0.2}, medium=0.06}
local wkL = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.4},{"lead white",0.3}, medium=0.06}
local W2 = WALK - GF:grow(1.5)
work(W2, {hand="body", tool="filbert 6", pile=wk, coverage=5, fill=true, clip=W2, angle=toVP, load=1})
for _, l in ipairs(LAMPS) do
  if l.Z < 60 then
    local function el(rx, rz) local t = {}; for j = 0, 19 do local a = 2 * math.pi * j / 20; t[#t+1] = pt(-0.1 + rx * math.cos(a), FY, l.Z + rz * math.sin(a)) end; return poly(t, true) * W2 end
    local o, i = el(0.5, 1.7), el(0.32, 0.9)
    local wv = {kind="filbert", width=math.max(1.2, math.min(6, 0.15 * F / l.Z))}
    work(o - i, {hand="body", tool=wv, pile=wkM, coverage=4, fill=true, clip=o - i, angle=toVP, load=1})
    work(i, {hand="body", tool=wv, pile=wkL, coverage=4, fill=true, clip=i, angle=toVP, load=1})
    blend((el(0.56, 1.95) - el(0.42, 1.45)), {angle=toVP})
    blend((el(0.37, 1.1) - el(0.26, 0.7)), {angle=toVP})
  end
end
-- grating bars again over the pools
local gr = pile{{"bone black",2},{"ultramarine blue",0.3}, medium=0.06}
for _, Z in ipairs{1.0, 1.15, 1.32, 1.52, 1.75, 2.0, 2.3, 2.65, 3.05, 3.5, 4.0, 4.6, 5.3, 6.1, 7.0, 8.1, 9.3, 10.7, 12.3, 14.2} do
  local b = brush{kind="flat", width=math.max(0.6, 0.02 * F / Z)}
  b:load(gr, 0.9); b:stroke({pt(-WK, FY, Z), pt(WK, FY, Z)}, {pressure={0.6, 0.6}, orient="across", clip=W2})
end
-- stations, far to near, thin strokes: lamp, chair, bowed docent at its desk
local brD = pile{{"bone black",1.6},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}
local brL = pile{{"raw sienna",1},{"yellow ochre",0.9},{"lead white",0.5},{"burnt sienna",0.3}, medium=0.06}
local boneF = pile{{"lead white",1.8},{"yellow ochre",0.5}, medium=0.06}
local shade = pile{{"lead white",2.5},{"yellow ochre",0.4},{"cadmium yellow",0.3}, medium=0.05}
local bulb = pile{{"zinc white",2.5},{"lemon chrome",0.15}, medium=0.04}
local glowP = pile{{"yellow ochre",1},{"lead white",1},{"raw sienna",0.3}, medium=0.06}
local function st(pts, pl, w, pr, clipm)
  local b = brush{kind="round", width=math.max(0.5, w), stiffness=0.5, point=0.3}
  b:load(pl, 0.9); b:stroke(pts, {pressure=pr, ramps={0.03, 0.03}, clip=clipm})
end
local notfig = -GF:grow(1)
for i = #STZ, 1, -1 do
  local Z = STZ[i]
  local k = F / Z
  local lx, ly = P(-0.4, FY, Z)
  local tall = (i == 1) and 1.8 or 1.3
  if i == 1 then lx, ly = P(-0.62, FY, 3.1); k = F / 3.1 end
  -- chair (not for the first: the Commando stands at it)
  if i > 1 then
    local cx, cy = P(-0.15, FY, Z + 0.25); local k2 = F / (Z + 0.25)
    st({{cx, cy}, {cx, cy - 0.44 * k2}}, brD, 0.03 * k2, {0.9, 0.9})
    st({{cx - 0.2 * k2, cy - 0.46 * k2}, {cx + 0.2 * k2, cy - 0.46 * k2}}, brL, 0.035 * k2, {0.8, 0.8})
    st({{cx - 0.19 * k2, cy - 0.48 * k2}, {cx - 0.22 * k2, cy - 0.9 * k2}, {cx - 0.17 * k2, cy - 1.12 * k2}}, brD, 0.05 * k2, {0.85, 0.7})
    st({{cx - 0.165 * k2, cy - 0.55 * k2}, {cx - 0.15 * k2, cy - 1.08 * k2}}, brL, 0.015 * k2, {0.5, 0.5})
    -- docent at its desk, bowed toward the lamp
    local dx, dy = P(0.3, FY, Z + 0.2); local k3 = F / (Z + 0.2)
    local desk = poly({{dx - 0.22 * k3, dy - 0.75 * k3}, {dx + 0.16 * k3, dy - 0.75 * k3}, {dx + 0.16 * k3, dy}, {dx - 0.22 * k3, dy}})
    work(desk, {hand="detail", pile=brD, coverage=4, fill=true, clip=desk, load=1})
    st({{dx - 0.25 * k3, dy - 0.77 * k3}, {dx + 0.19 * k3, dy - 0.77 * k3}}, brL, 0.03 * k3, {0.8, 0.8})
    local bell = poly({{dx + 0.0 * k3, dy - 1.5 * k3}, {dx + 0.12 * k3, dy - 1.46 * k3}, {dx + 0.19 * k3, dy - 0.8 * k3}, {dx - 0.06 * k3, dy - 0.8 * k3}, {dx - 0.07 * k3, dy - 1.36 * k3}}, true)
    work(bell, {hand="detail", pile=brD, coverage=4, fill=true, clip=bell, load=1})
    st({{dx - 0.07 * k3, dy - 1.36 * k3}, {dx - 0.06 * k3, dy - 0.82 * k3}}, brL, 0.03 * k3, {0.7, 0.4})
    local face = ellipse(dx - 0.08 * k3, dy - 1.44 * k3, 0.05 * k3, 0.07 * k3)
    work(face, {hand="detail", pile=boneF, coverage=4, fill=true, clip=face, load=1})
    st({{dx - 0.2 * k3, dy - 0.79 * k3}, {dx - 0.05 * k3, dy - 0.8 * k3}}, boneF, 0.02 * k3, {0.8, 0.8})
  end
  -- lamp: thin stem, a small shade, a bulb, and a soft stippled glow around it
  st({{lx, ly}, {lx, ly - tall * k}}, brD, 0.018 * k, {0.9, 0.9}, notfig)
  local sy = ly - tall * k
  local glow = ellipse(lx, sy - 0.04 * k, 0.3 * k, 0.26 * k) - GF:grow(1)
  local function cov(x, y) local d = math.sqrt(((x - lx) / (0.3 * k))^2 + ((y - sy + 0.04 * k) / (0.26 * k))^2); return clamp(1 - d, 0, 1)^1.5 * 2.2 end
  stipple(glow, {pile=glowP, width=math.max(0.8, 0.012 * k), coverage=cov, feather=0.9, cluster=0.1, dips={25, 0.6, 0}})
  local sh = poly({{lx - 0.075 * k, sy}, {lx + 0.075 * k, sy}, {lx + 0.045 * k, sy - 0.12 * k}, {lx - 0.045 * k, sy - 0.12 * k}}) - GF
  work(sh, {hand="detail", pile=shade, coverage=5, fill=true, clip=sh, load=1})
  local bl = ellipse(lx, sy + 0.012 * k, 0.03 * k, 0.014 * k) - GF
  work(bl, {hand="detail", pile=bulb, coverage=5, fill=true, clip=bl, load=1})
end

--@ chunk 13
-- the station pass painted over the Commando (his mask was not subtracted): restate him opaque, then his tablet and warm edges
print(wait(3*24*60))
local Z = 2.9
local k = F / Z
local fx, fy = P(-0.05, FY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local figD = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.25}, medium=0.06}
work(GF, {hand="body", tool="filbert 4", pile=figD, coverage=6, fill=true, clip=GF, angle=math.pi/2, load=1})
work(GF, {hand="detail", pile=figD, coverage=4, fill=true, clip=GF, load=1})
print(wait(3*24*60))
local tab = poly({Q(-0.46,1.42), Q(-0.3,1.44), Q(-0.29,1.2), Q(-0.45,1.18)})
work(tab, {hand="body", tool="filbert 3", pile=pile{{"lead white",2.4},{"yellow ochre",0.5},{"cadmium yellow",0.15}, medium=0.05}, coverage=6, fill=true, clip=tab, load=1})
local ink = pile{{"burnt sienna",1},{"bone black",0.8}, medium=0.06}
local tc = Q(-0.375, 1.31)
local r, rot = 0.055 * k, 0.3
for nn = 1, 3 do
  local pts = {}
  for j = 0, 5 do local a = rot + 2 * math.pi * j / 5; pts[#pts+1] = {tc[1] + r * math.cos(a), tc[2] + r * math.sin(a)} end
  local b = brush{kind="round", width=1.2, point=0.4}
  b:load(ink, 0.8); b:stroke(pts, {pressure={0.6, 0.6}, clip=tab})
  r = r * 0.6; rot = rot + 2.399963
end
local rim = pile{{"lead white",2.2},{"yellow ochre",0.7},{"cadmium yellow",0.25}, medium=0.05}
local function ln(pts, w, pr)
  local bb = brush{kind="round", width=w, point=0.5}
  bb:load(rim, 0.95); bb:stroke(pts, {pressure=pr, clip=GF:grow(1.5)})
end
ln({Q(-0.1,1.83), Q(-0.15,1.76), Q(-0.15,1.66)}, 3, {0.9, 0.5})
ln({Q(-0.4,1.55), Q(-0.33,1.61), Q(-0.18,1.62)}, 3, {0.8, 0.8})
ln({Q(-0.44,1.4), Q(-0.43,1.26)}, 2.6, {0.8, 0.5})
ln({Q(-0.235,0.9), Q(-0.25,0.5), Q(-0.23,0.15)}, 2.2, {0.7, 0.1})
ln({Q(-0.24,1.3), Q(-0.23,1.04)}, 2, {0.6, 0.2})
