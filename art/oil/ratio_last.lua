-- easel session "ratio_last": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={18,16}, seed=8181,
  ground={{pile={{"lead white",3},{"rose madder",0.2},{"cerulean blue",0.2},{"yellow ochre",0.1}}, um=100, apply="knife", texture=0.25}}}
-- one-point, flat-shaded: VP in the middle, floor at Y=1.6
VX, VY, F = 500, 300, 480
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
FY = 1.6
SKY = above(function(x) return VY end)
GROUND = below(function(x) return VY end)
-- pastel sky in flat stepped bands, as polygons in a low-poly sky: pink near the horizon, lilac, pale blue above
local bands = {
  {0, 70, pile{{"lead white",2},{"cerulean blue",0.45},{"zinc white",0.5}, medium=0.05}},
  {70, 150, pile{{"lead white",2},{"cobalt violet",0.3},{"cerulean blue",0.2},{"zinc white",0.4}, medium=0.05}},
  {150, 230, pile{{"lead white",2},{"rose madder",0.22},{"cobalt violet",0.15},{"zinc white",0.4}, medium=0.05}},
  {230, 300, pile{{"lead white",2},{"rose madder",0.15},{"cadmium yellow",0.12},{"zinc white",0.4}, medium=0.05}},
}
for _, b in ipairs(bands) do local m = rect(0, b[1], 1000, b[2] - b[1]); work(m, {hand="body", tool="filbert 10", pile=b[3], coverage=4, fill=true, clip=m, angle=0, load=1}) end
-- the floor: a pale lilac-gray plane
work(GROUND, {hand="body", tool="filbert 12", pile=pile{{"lead white",2},{"cobalt violet",0.25},{"ultramarine ash",0.3},{"bone black",0.05}, medium=0.05}, coverage=4, fill=true, clip=GROUND, angle=0, load=1})

--@ chunk 2
-- floor grid in thin cyan lines to the VP; shelf units either side of the aisle, flat-shaded: aisle-facing side, end face, top
print(wait(2*24*60))
local grid = pile{{"cerulean blue",1},{"lead white",1},{"cobalt blue",0.2}, medium=0.05}
for X = -12, 12, 1.2 do
  local b = brush{kind="round", width=1.1, point=0.3}
  b:load(grid, 0.8); b:stroke({pt(X, FY, 0.9), pt(X, FY, 200)}, {pressure={0.6, 0.2}, clip=GROUND})
end
for _, Z in ipairs{1.2, 1.6, 2.1, 2.8, 3.7, 4.9, 6.5, 8.6, 11.4, 15, 20, 27, 36} do
  local b = brush{kind="round", width=math.max(0.6, 2.2 / Z * 2), point=0.3}
  b:load(grid, 0.8); b:stroke({pt(-60, FY, Z), pt(60, FY, Z)}, {pressure={0.5, 0.5}, clip=GROUND})
end
-- shelf units: X from 1.5 to 2.4 (right) / -2.4 to -1.5 (left), height 3.0, length L, with gaps
local side = pile{{"lead white",1.6},{"cobalt violet",0.45},{"ultramarine ash",0.3}, medium=0.05}
local endf = pile{{"lead white",1},{"cobalt violet",0.5},{"ultramarine blue",0.3},{"bone black",0.08}, medium=0.05}
local topf = pile{{"lead white",2},{"rose madder",0.15},{"zinc white",0.5}, medium=0.05}
UNITS = {}
local zs = {{2.2, 4.4}, {5.2, 7.4}, {8.4, 11.2}, {12.6, 16.4}, {18.2, 23}, {25.5, 32}, {35, 44}, {48, 62}, {66, 90}}
for _, s in ipairs{-1, 1} do
  for i = #zs, 1, -1 do
    local z0, z1 = zs[i][1], zs[i][2]
    local xi, xo = s * 1.5, s * 2.6
    local H = FY - 3.0
    local sideM = poly({pt(xi, FY, z0), pt(xi, FY, z1), pt(xi, H, z1), pt(xi, H, z0)})
    local endM = poly({pt(xi, FY, z0), pt(xo, FY, z0), pt(xo, H, z0), pt(xi, H, z0)})
    local topM = poly({pt(xi, H, z0), pt(xo, H, z0), pt(xo, H, z1), pt(xi, H, z1)})
    work(sideM, {hand="detail", pile=side, coverage=4, fill=true, clip=sideM, load=1})
    work(topM, {hand="detail", pile=topf, coverage=4, fill=true, clip=topM, load=1})
    work(endM, {hand="detail", pile=endf, coverage=4, fill=true, clip=endM, load=1})
    UNITS[#UNITS+1] = {s=s, z0=z0, z1=z1, xi=xi, xo=xo, H=H, side=sideM, endm=endM}
  end
end
print(#UNITS)

--@ chunk 3
-- books: on each aisle-facing side, five shelves of flat pastel spines with a dark gap above each row; shelf boards;
-- end faces repainted flat with the body hand
print(wait(2*24*60))
local endf = pile{{"lead white",1},{"cobalt violet",0.55},{"ultramarine blue",0.35},{"bone black",0.1}, medium=0.05}
local cols = {
  pile{{"lead white",1.5},{"rose madder",0.5}, medium=0.05},
  pile{{"lead white",1.5},{"viridian",0.25},{"cerulean blue",0.2}, medium=0.05},
  pile{{"lead white",1.5},{"cadmium yellow",0.45}, medium=0.05},
  pile{{"lead white",1.5},{"cerulean blue",0.5}, medium=0.05},
  pile{{"lead white",1.3},{"cobalt violet",0.6}, medium=0.05},
  pile{{"lead white",1.2},{"Mars orange",0.4},{"rose madder",0.15}, medium=0.05},
}
local gap = pile{{"ultramarine blue",1},{"cobalt violet",0.5},{"bone black",0.4},{"lead white",0.4}, medium=0.05}
local board = pile{{"lead white",2},{"zinc white",0.5}, medium=0.05}
local n = 0
for _, u in ipairs(UNITS) do
  work(u.endm, {hand="body", tool="filbert 6", pile=endf, coverage=5, fill=true, clip=u.endm, angle=math.pi/2, load=1})
  for r = 0, 4 do
    local yb = FY - 0.1 - r * 0.58
    local yt = yb - 0.46
    -- dark recess behind the books
    local rec = poly({pt(u.xi, yb, u.z0), pt(u.xi, yb, u.z1), pt(u.xi, yb - 0.56, u.z1), pt(u.xi, yb - 0.56, u.z0)})
    local Zm = (u.z0 + u.z1) / 2
    local tool = {kind="flat", width=math.max(1.5, 0.3 * F / Zm)}
    work(rec, {hand="body", tool=tool, pile=gap, coverage=4, fill=true, clip=rec, angle=0, load=1})
    local Z = u.z0 + 0.04
    local seed = math.floor(u.z0 * 7 + r * 3 + (u.s > 0 and 1 or 0))
    while Z < u.z1 - 0.05 do
      seed = seed + 1
      local h = (seed * 0.618034) % 1
      local w = 0.05 + 0.05 * h
      local hgt = 0.34 + 0.12 * ((seed * 0.381966) % 1)
      local a, b = pt(u.xi, yb, Z + w / 2), pt(u.xi, yb - hgt, Z + w / 2)
      local pw = math.max(0.6, F * 1.5 * w / (Z * Z) * 0.9)
      if pw > 0.6 or h < 0.5 then
        local br = brush{kind="flat", width=math.min(pw, 30), stiffness=0.6}
        br:load(cols[1 + math.floor(h * 6) % 6], 0.9)
        br:stroke({a, b}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=u.side})
        n = n + 1
      end
      Z = Z + w + 0.004
    end
    local bb = brush{kind="round", width=math.max(0.7, 0.04 * F / Zm), stiffness=0.6}
    bb:load(board, 0.9); bb:stroke({pt(u.xi, yb + 0.01, u.z0), pt(u.xi, yb + 0.01, u.z1)}, {pressure={0.8, 0.8}, clip=u.side})
  end
end
print("books", n)

--@ chunk 4
-- the yellow octagon sun; the saved real things hung on the shelf ends as dark oil paintings in thin frames
print(wait(4*24*60))
local sun = {}
for j = 0, 7 do local a = math.pi / 8 + j * math.pi / 4; sun[#sun+1] = {500 + 52 * math.cos(a), 70 + 52 * math.sin(a)} end
SUN = poly(sun)
work(SUN, {hand="body", tool="filbert 5", pile=pile{{"cadmium yellow",1},{"lemon chrome",0.6},{"lead white",0.6}, medium=0.05}, coverage=6, fill=true, clip=SUN, angle=0, load=1})
local sun2 = {}
for j = 0, 7 do local a = math.pi / 8 + j * math.pi / 4; sun2[#sun2+1] = {500 + 34 * math.cos(a), 70 + 34 * math.sin(a)} end
local S2 = poly(sun2)
work(S2, {hand="detail", pile=pile{{"lemon chrome",1},{"lead white",1.2}, medium=0.05}, coverage=6, fill=true, clip=S2, load=1})
-- frames
local frameP = pile{{"lead white",2},{"cadmium yellow",0.2}, medium=0.05}
local function framed(x, y, w, h)
  local outer = rect(x - 5, y - 5, w + 10, h + 10)
  local inner = rect(x, y, w, h)
  work(outer - inner, {hand="detail", pile=frameP, coverage=6, fill=true, clip=outer - inner, load=1})
  return inner
end
-- 1. the TESTAMENT hull fragment, left near shelf end: dark bronze scale-plates, warm rims
local A = framed(40, 150, 100, 130)
work(A, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.4},{"burnt sienna",1},{"Mars brown",0.4}, medium=0.06}, coverage=6, fill=true, clip=A, angle=0.4, load=1})
for row = 0, 5 do
  for c = 0, 4 do
    local x, y = 48 + c * 22 + (row % 2) * 11, 160 + row * 22
    local b = brush{kind="filbert", width=18, stiffness=0.5}
    b:load(pile{{"burnt sienna",1},{"raw sienna",0.8},{"bone black",0.5},{"yellow ochre",0.3}, medium=0.06}, 0.9)
    b:stroke({{x, y - 6}, {x, y + 4}}, {pressure={0.85, 0.7}, orient="across", clip=A})
    local r = brush{kind="round", width=1.6, point=0.4}
    r:load(pile{{"yellow ochre",1},{"lead white",0.8},{"Mars orange",0.2}, medium=0.06}, 0.8)
    r:stroke({{x + 2, y + 6}, {x + 8, y + 3}, {x + 9, y - 3}}, {pressure={0.3, 0.7}, clip=A})
  end
end
-- 2. the crimson rag, right near shelf end: dark ground, a twisted crimson cloth
local B = framed(866, 170, 92, 120)
work(B, {hand="body", tool="filbert 6", pile=pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.2}, medium=0.06}, coverage=6, fill=true, clip=B, angle=0, load=1})
local rag = poly({{886, 196}, {930, 188}, {942, 220}, {920, 250}, {934, 280}, {898, 276}, {904, 238}, {880, 222}}, true)
work(rag, {hand="body", tool="filbert 4", pile=pile{{"cadmium red",1},{"rose madder",0.5},{"burnt sienna",0.4}, medium=0.06}, coverage=6, fill=true, clip=rag, angle=1.2, load=1})
local fb = brush{kind="round", width=3, point=0.4}
fb:load(pile{{"bone black",1.5},{"burnt sienna",0.6},{"cadmium red",0.4}, medium=0.06}, 0.9); fb:stroke({{896, 210}, {918, 230}, {912, 262}}, {pressure={0.6, 0.6}, clip=rag})
fb:load(pile{{"vermilion",1},{"lead white",0.4}, medium=0.05}, 0.9); fb:stroke({{902, 198}, {932, 196}, {938, 218}}, {pressure={0.5, 0.5}, clip=rag})
-- 3. a docent's bone face, on the end of the second unit on the left
local C = framed(270, 190, 52, 70)
work(C, {hand="body", tool="filbert 4", pile=pile{{"bone black",1.6},{"burnt sienna",0.9}, medium=0.06}, coverage=6, fill=true, clip=C, angle=0, load=1})
local face = ellipse(296, 226, 15, 22)
work(face, {hand="detail", pile=pile{{"lead white",1.8},{"yellow ochre",0.5},{"raw sienna",0.1}, medium=0.05}, coverage=6, fill=true, clip=face, load=1})
local lens = ellipse(300, 220, 3.5, 3.5)
work(lens, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.06}, coverage=6, fill=true, clip=lens, load=1})
local hood = brush{kind="round", width=5, point=0.4}
hood:load(pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.6}, medium=0.06}, 0.9); hood:stroke({{279, 240}, {280, 208}, {296, 200}, {312, 208}, {313, 240}}, {pressure={0.8, 0.8}, clip=C})

--@ chunk 5
-- on dry paint: book spines restated on the near units (they sank into the wet recess); then the floating text panels and Ratio
print(wait(3*24*60))
local cols = {
  pile{{"lead white",1.5},{"rose madder",0.5}, medium=0.05},
  pile{{"lead white",1.5},{"viridian",0.25},{"cerulean blue",0.2}, medium=0.05},
  pile{{"lead white",1.5},{"cadmium yellow",0.45}, medium=0.05},
  pile{{"lead white",1.5},{"cerulean blue",0.5}, medium=0.05},
  pile{{"lead white",1.3},{"cobalt violet",0.6}, medium=0.05},
  pile{{"lead white",1.2},{"Mars orange",0.4},{"rose madder",0.15}, medium=0.05},
}
local keep = rect(260, 180, 72, 90)
for _, u in ipairs(UNITS) do
  if u.z0 < 9 then
    for r = 0, 4 do
      local yb = FY - 0.1 - r * 0.58
      local Z = u.z0 + 0.06
      local seed = math.floor(u.z0 * 11 + r * 5 + (u.s > 0 and 2 or 0))
      while Z < u.z1 - 0.08 do
        seed = seed + 1
        local h = (seed * 0.618034) % 1
        local w = 0.07 + 0.06 * h
        local hgt = 0.3 + 0.14 * ((seed * 0.381966) % 1)
        local pw = math.max(0.8, F * 1.5 * w / (Z * Z) * 0.8)
        local br = brush{kind="flat", width=math.min(pw, 26), stiffness=0.6}
        br:load(cols[1 + math.floor(h * 6) % 6], 0.95)
        br:stroke({pt(u.xi, yb - 0.02, Z + w / 2), pt(u.xi, yb - hgt, Z + w / 2)}, {pressure={0.95, 0.95}, ramps={0.02, 0.02}, orient="across", clip=u.side - keep})
        Z = Z + w + 0.02
      end
    end
  end
end

--@ chunk 6
-- floating text panels drifting over the aisle and up into the sky; Ratio small in the aisle with an armful of glowing panels
local panel = pile{{"zinc white",1.5},{"cerulean blue",0.3},{"lead white",0.6}, medium=0.05}
local edgeP = pile{{"cerulean blue",1},{"lead white",0.6},{"cobalt blue",0.2}, medium=0.05}
local markP = pile{{"cobalt blue",1},{"cerulean blue",0.5},{"lead white",0.4}, medium=0.05}
local function panelAt(cx, cy, w, h, tilt, seed)
  local c, s = math.cos(tilt), math.sin(tilt)
  local function R(u, v) return {cx + u * c - v * s, cy + u * s + v * c} end
  local m = poly({R(-w / 2, -h / 2), R(w / 2, -h / 2), R(w / 2, h / 2), R(-w / 2, h / 2)})
  work(m, {hand="detail", pile=panel, coverage=5, fill=true, clip=m, load=0.9})
  local e = brush{kind="round", width=math.max(0.8, w * 0.03), point=0.3}
  e:load(edgeP, 0.9); e:stroke({R(-w / 2, -h / 2), R(w / 2, -h / 2), R(w / 2, h / 2), R(-w / 2, h / 2), R(-w / 2, -h / 2)}, {pressure={0.6, 0.6}})
  -- abstract text: short dashes in lines, a little block mark
  for li = 0, 4 do
    local v = -h / 2 + h * (0.2 + li * 0.15)
    local u = -w / 2 + w * 0.1
    local k = seed + li * 7
    while u < w / 2 - w * 0.12 do
      k = k + 1
      local L = w * (0.06 + 0.12 * ((k * 0.618034) % 1))
      local b = brush{kind="round", width=math.max(0.6, h * 0.04), point=0.2}
      b:load(markP, 0.8); b:stroke({R(u, v), R(math.min(u + L, w / 2 - w * 0.1), v)}, {pressure={0.6, 0.6}, clip=m})
      u = u + L + w * 0.04
    end
  end
end
for i, q in ipairs{{420, 215, 46, 34, -0.12}, {585, 190, 54, 40, 0.15}, {500, 150, 30, 22, 0.05}, {370, 120, 36, 26, -0.2}, {640, 112, 40, 30, 0.22}, {520, 245, 26, 19, -0.05}, {455, 175, 22, 16, 0.12}} do
  panelAt(q[1], q[2], q[3], q[4], q[5], i * 13)
end
-- Ratio, small in the aisle at about Z 7: chibi, low-poly — big head of flat facets, black hair, pale face, a short teal dress
local Z = 7.5
local k = F / Z
local bx, by = P(0.05, FY, Z)
local function Q(x, y) return {bx + x * k, by - y * k} end
local shadow = ellipse(bx, by + 1, 0.42 * k, 0.07 * k)
work(shadow, {hand="detail", pile=pile{{"lead white",1},{"cobalt violet",0.5},{"ultramarine ash",0.4}, medium=0.05}, coverage=5, fill=true, clip=shadow, load=1})
local legs = poly({Q(-0.12, 0), Q(-0.04, 0), Q(-0.04, 0.35), Q(-0.12, 0.35)}) + poly({Q(0.04, 0), Q(0.12, 0), Q(0.12, 0.35), Q(0.04, 0.35)})
work(legs, {hand="detail", pile=pile{{"lead white",1.6},{"rose madder",0.15},{"yellow ochre",0.1}, medium=0.05}, coverage=6, fill=true, clip=legs, load=1})
local dress = poly({Q(-0.24, 0.3), Q(0.24, 0.3), Q(0.13, 0.72), Q(-0.13, 0.72)})
work(dress, {hand="detail", pile=pile{{"viridian",0.6},{"cerulean blue",0.6},{"lead white",0.8}, medium=0.05}, coverage=6, fill=true, clip=dress, load=1})
local dressL = poly({Q(0.0, 0.3), Q(0.24, 0.3), Q(0.13, 0.72), Q(0.0, 0.72)})
work(dressL, {hand="detail", pile=pile{{"viridian",0.4},{"cerulean blue",0.5},{"lead white",1.4}, medium=0.05}, coverage=6, fill=true, clip=dressL, load=1})
-- head: hair as an octagonal black mass with a fringe, face as two flat facets
local hair = {}
for j = 0, 7 do local a = math.pi / 8 + j * math.pi / 4; hair[#hair+1] = Q(0.26 * math.cos(a), 1.0 + 0.28 * math.sin(a)) end
HAIR = poly(hair) + poly({Q(-0.27, 0.95), Q(-0.18, 0.72), Q(-0.1, 0.9)}) + poly({Q(0.27, 0.95), Q(0.18, 0.72), Q(0.1, 0.9)})
work(HAIR, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.05}, coverage=6, fill=true, clip=HAIR, load=1})
local faceL = poly({Q(-0.17, 1.0), Q(0.0, 1.03), Q(0.0, 0.8), Q(-0.12, 0.84)})
local faceR = poly({Q(0.0, 1.03), Q(0.17, 1.0), Q(0.12, 0.84), Q(0.0, 0.8)})
work(faceL, {hand="detail", pile=pile{{"lead white",2},{"rose madder",0.12},{"yellow ochre",0.06}, medium=0.05}, coverage=6, fill=true, clip=faceL, load=1})
work(faceR, {hand="detail", pile=pile{{"lead white",1.5},{"rose madder",0.18},{"cobalt violet",0.1}, medium=0.05}, coverage=6, fill=true, clip=faceR, load=1})
-- the armful of glowing panels held against her chest
for j, q in ipairs{{-0.22, 0.6, -0.25}, {0.0, 0.66, 0.1}, {0.2, 0.58, 0.3}} do
  local cx, cy = Q(q[1], q[2])[1], Q(q[1], q[2])[2]
  local c, s = math.cos(q[3]), math.sin(q[3])
  local w, h = 0.26 * k, 0.2 * k
  local function R(u, v) return {cx + u * c - v * s, cy + u * s + v * c} end
  local m = poly({R(-w / 2, -h / 2), R(w / 2, -h / 2), R(w / 2, h / 2), R(-w / 2, h / 2)})
  work(m, {hand="detail", pile=pile{{"zinc white",2.5},{"cerulean blue",0.15},{"lemon chrome",0.05}, medium=0.04}, coverage=6, fill=true, clip=m, load=1})
  local e = brush{kind="round", width=1.2, point=0.3}
  e:load(pile{{"cerulean blue",1},{"lead white",0.5}, medium=0.05}, 0.9); e:stroke({R(-w / 2, -h / 2), R(w / 2, -h / 2), R(w / 2, h / 2), R(-w / 2, h / 2), R(-w / 2, -h / 2)}, {pressure={0.5, 0.5}})
end
local glow = ellipse(bx, by - 0.62 * k, 0.55 * k, 0.32 * k) - HAIR - faceL - faceR
stipple(glow, {pile=pile{{"zinc white",2},{"cerulean blue",0.12}, medium=0.04}, width=1, coverage=function(x, y) local d = math.sqrt(((x - bx) / (0.55 * k))^2 + ((y - by + 0.62 * k) / (0.32 * k))^2); return clamp(1 - d, 0, 1)^1.5 * 1.6 end, feather=0.9, cluster=0.1})
print(bx, by, k)

--@ chunk 7
-- on set paint: her face restated above the armful (the panels rode up over it), two dot eyes; the floor grid stronger
print(wait(3*24*60))
local Z = 7.5
local k = F / Z
local bx, by = P(0.05, FY, Z)
local function Q(x, y) return {bx + x * k, by - y * k} end
local hair = {}
for j = 0, 7 do local a = math.pi / 8 + j * math.pi / 4; hair[#hair+1] = Q(0.26 * math.cos(a), 1.06 + 0.28 * math.sin(a)) end
local H = poly(hair)
work(H, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.05}, coverage=7, fill=true, clip=H, load=1})
local faceL = poly({Q(-0.17, 1.04), Q(0.0, 1.08), Q(0.0, 0.84), Q(-0.12, 0.88)})
local faceR = poly({Q(0.0, 1.08), Q(0.17, 1.04), Q(0.12, 0.88), Q(0.0, 0.84)})
work(faceL, {hand="detail", pile=pile{{"lead white",2},{"rose madder",0.12},{"yellow ochre",0.06}, medium=0.05}, coverage=7, fill=true, clip=faceL, load=1})
work(faceR, {hand="detail", pile=pile{{"lead white",1.5},{"rose madder",0.18},{"cobalt violet",0.1}, medium=0.05}, coverage=7, fill=true, clip=faceR, load=1})
local fringe = poly({Q(-0.2, 1.12), Q(0.2, 1.12), Q(0.17, 1.02), Q(0.05, 1.05), Q(-0.05, 0.99), Q(-0.17, 1.03)})
work(fringe, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4}, medium=0.05}, coverage=7, fill=true, clip=fringe, load=1})
for _, dx in ipairs{-0.07, 0.07} do
  local e = brush{kind="round", width=2.2}
  e:load(pile{{"bone black",2},{"ultramarine blue",0.3}, medium=0.05}, 0.9); e:touch(bx + dx * k, by - 0.95 * k, {pressure=0.7})
end
local grid = pile{{"cerulean blue",1},{"lead white",0.6},{"cobalt blue",0.3}, medium=0.05}
local AISLE = poly({pt(-1.5, FY, 0.9), pt(-1.5, FY, 200), pt(1.5, FY, 200), pt(1.5, FY, 0.9)}) - ellipse(bx, by - 0.3 * k, 0.5 * k, 0.6 * k)
for _, X in ipairs{-1.2, -0.6, 0, 0.6, 1.2} do
  local b = brush{kind="round", width=1.6, point=0.3}
  b:load(grid, 0.85); b:stroke({pt(X, FY, 0.9), pt(X, FY, 120)}, {pressure={0.8, 0.15}, clip=AISLE})
end
for _, Zg in ipairs{1.2, 1.6, 2.1, 2.8, 3.7, 4.9, 6.5, 8.6, 11.4, 15, 20, 27} do
  local b = brush{kind="round", width=math.max(0.7, 4 / Zg), point=0.3}
  b:load(grid, 0.85); b:stroke({pt(-1.5, FY, Zg), pt(1.5, FY, Zg)}, {pressure={0.7, 0.7}, clip=AISLE})
end

--@ chunk 8
-- the face muddied by the wet hair under it: let it dry, then the two facets again, clean, and two dark dot eyes
print(wait(7*24*60))
local Z = 7.5
local k = F / Z
local bx, by = P(0.05, FY, Z)
local function Q(x, y) return {bx + x * k, by - y * k} end
local faceL = poly({Q(-0.16, 1.0), Q(0.0, 1.03), Q(0.0, 0.85), Q(-0.11, 0.89)})
local faceR = poly({Q(0.0, 1.03), Q(0.16, 1.0), Q(0.11, 0.89), Q(0.0, 0.85)})
work(faceL, {hand="detail", pile=pile{{"lead white",2.2},{"rose madder",0.1},{"yellow ochre",0.05}, medium=0.04}, coverage=8, fill=true, clip=faceL, load=1})
work(faceR, {hand="detail", pile=pile{{"lead white",1.8},{"rose madder",0.16},{"cobalt violet",0.08}, medium=0.04}, coverage=8, fill=true, clip=faceR, load=1})
print(wait(3*24*60))
for _, dx in ipairs{-0.065, 0.065} do
  local e = ellipse(bx + dx * k, by - 0.94 * k, 1.6, 2.2)
  work(e, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.3}, medium=0.05}, coverage=6, fill=true, clip=e, load=1})
end
local m = brush{kind="round", width=1, point=0.5}
m:load(pile{{"rose madder",1},{"lead white",0.6}, medium=0.05}, 0.8); m:stroke({{bx - 2, by - 0.88 * k}, {bx + 2, by - 0.88 * k}}, {pressure={0.5, 0.5}})
