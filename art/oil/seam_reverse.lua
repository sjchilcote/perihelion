-- easel session "seam_reverse": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.5, linen={18,16}, seed=5527,
  ground={{pile={{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"lead white",1}}, um=120, apply="knife", texture=0.4}}}
-- inside the nave looking back at the end wall and the cut: one-point perspective, metres
VX, VY, F = 500, 320, 520
function P(X, Y, Z) return VX + F*X/Z, VY + F*Y/Z end   -- Y down; floor at Y = EYE
function pt(X, Y, Z) local x, y = P(X, Y, Z); return {x, y} end
EYE, HWN, CROWN, ZW = 1.6, 4.2, 7.2, 9.0
FLY = EYE
-- pointed arch section: half width HWN at floor, spring at 2.2 m, crown at CROWN
function ARCH(Z, hw, n)
  hw = hw or HWN; n = n or 14
  local L, R = {}, {}
  L[#L+1] = pt(-hw, FLY, Z)
  for i = 0, n do
    local u = i / n
    local X = -hw * (1 - u) ^ 1.4
    local Yh = 2.2 + (CROWN - 2.2) * math.sin(u * math.pi / 2) ^ 0.8
    L[#L+1] = pt(X, FLY - Yh, Z)
  end
  for i = n, 0, -1 do
    local u = i / n
    local X = hw * (1 - u) ^ 1.4
    local Yh = 2.2 + (CROWN - 2.2) * math.sin(u * math.pi / 2) ^ 0.8
    R[#R+1] = pt(X, FLY - Yh, Z)
  end
  R[#R+1] = pt(hw, FLY, Z)
  for _, p in ipairs(R) do L[#L+1] = p end
  return L
end
ENDW = poly(ARCH(ZW))
FLOOR = poly({pt(-HWN, FLY, 0.6), pt(-HWN, FLY, ZW), pt(HWN, FLY, ZW), pt(HWN, FLY, 0.6)}) + rect(0, 600, 1000, 80)
-- the cut: a ragged rounded rectangle, X -1.3..1.35, from the floor to 2.7 m
local cp = {}
local corners = {{-1.3, 0.0}, {1.35, 0.0}, {1.32, 2.55}, {-1.28, 2.62}}
CUTPTS = {pt(-1.3, FLY, ZW), pt(1.35, FLY, ZW), pt(1.36, FLY - 1.3, ZW), pt(1.3, FLY - 2.45, ZW), pt(1.12, FLY - 2.68, ZW),
  pt(0.3, FLY - 2.72, ZW), pt(-0.6, FLY - 2.7, ZW), pt(-1.15, FLY - 2.66, ZW), pt(-1.32, FLY - 2.45, ZW), pt(-1.33, FLY - 1.2, ZW)}
CUT = poly(CUTPTS):roughen(1.5, 12, 7)
-- the reveal: the wall is 0.55 m thick; we see its inner faces converging toward the VP
local back = {}
for i, p in ipairs(CUTPTS) do
  local X = (p[1] - VX) * ZW / F; local Y = (p[2] - VY) * ZW / F
  back[i] = pt(X, Y, ZW + 0.55)
end
HOLE = poly(back):roughen(1.2, 10, 8)
REVEAL = CUT - HOLE
NAVE = everywhere() - FLOOR - ENDW
print(W, H, CUT:area(), HOLE:area(), P(0, FLY, ZW))

--@ chunk 2
-- lay-in: vault and side walls warm dark bronze, the end wall lit, the floor, the cold hole, the raw reveal
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local vD = pile{{"burnt sienna",1.5},{"raw sienna",1},{"bone black",0.8},{"yellow ochre",0.3}, medium=0.06}
local vM = pile{{"raw sienna",1.5},{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.35},{"lead white",0.35}, medium=0.06}
local upper = above(function(x) return 150 end)
work(NAVE * upper, {hand="body", tool="filbert 12", pile=vD, coverage=3.5, fill=true, clip=NAVE, angle=toVP, load=1})
work(NAVE - upper, {hand="body", tool="filbert 10", pile=vM, coverage=3.5, fill=true, clip=NAVE, angle=toVP, load=1})
local eL = pile{{"yellow ochre",2},{"raw sienna",0.7},{"lead white",1.2},{"burnt sienna",0.35}, medium=0.06}
local eM = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.6},{"lead white",0.6},{"bone black",0.15}, medium=0.06}
local W = ENDW - CUT
local yS = select(2, P(0, FLY - 3.6, ZW))
work(W * below(function(x) return yS end), {hand="body", tool="filbert 6", pile=eL, coverage=3.5, fill=true, clip=W, angle=math.pi/2, load=1})
work(W * above(function(x) return yS end), {hand="body", tool="filbert 6", pile=eM, coverage=3.5, fill=true, clip=W, angle=math.pi/2, load=1})
local fl = pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.7},{"bone black",0.2}, medium=0.06}
work(FLOOR, {hand="body", tool="filbert 10", pile=fl, coverage=3.5, fill=true, clip=FLOOR, angle=toVP, load=1})
local hole = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.5}, medium=0.06}
work(HOLE, {hand="body", tool="filbert 4", pile=hole, coverage=4, fill=true, clip=HOLE, angle=math.pi/2, load=1})
local rv = pile{{"burnt sienna",1},{"Mars orange",0.6},{"yellow ochre",0.8},{"bone black",0.4}, medium=0.06}
work(REVEAL, {hand="body", tool="filbert 3", pile=rv, coverage=4, fill=true, clip=REVEAL, angle=toVP, load=1})

--@ chunk 3
-- through the hole: the outpost corridor, small and straight, gray going to black; ribs as nested frames
print(wait(2*24*60))
local Z0 = ZW + 0.55
local function frame(Z) return poly({pt(-1.65, FLY, Z), pt(1.65, FLY, Z), pt(1.65, FLY - 2.45, Z), pt(-1.65, FLY - 2.45, Z)}) end
CZ = {Z0, Z0 + 1.2, Z0 + 2.8, Z0 + 5, Z0 + 8, Z0 + 12.5, Z0 + 19, Z0 + 30, Z0 + 60}
local piles = {
  pile{{"bone black",1.4},{"ultramarine ash",1},{"lead white",0.9},{"burnt sienna",0.15}, medium=0.06},
  pile{{"bone black",1.6},{"ultramarine ash",1},{"lead white",0.65},{"burnt sienna",0.15}, medium=0.06},
  pile{{"bone black",1.8},{"ultramarine ash",1},{"lead white",0.45}, medium=0.06},
  pile{{"bone black",2},{"ultramarine ash",0.9},{"lead white",0.3}, medium=0.06},
  pile{{"bone black",2},{"ultramarine ash",0.8},{"lead white",0.18}, medium=0.06},
  pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.08}, medium=0.06},
  pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}, medium=0.06},
  pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.4}, medium=0.06},
}
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
for i = 1, #CZ - 1 do
  local m = (everywhere() - frame(CZ[i + 1])) * frame(CZ[i]):grow(i == 1 and 40 or 0) * HOLE
  if i == #CZ - 1 then m = frame(CZ[i]) * HOLE end
  work(m, {hand="body", tool="filbert 3", pile=piles[i], coverage=4, fill=true, clip=m, angle=toVP, load=1})
end
-- rib frames: near-black lines at uneven depths
local rib = pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.4}, medium=0.06}
for _, Z in ipairs{Z0 + 1.7, Z0 + 4.1, Z0 + 7.0, Z0 + 11.5} do
  local w = math.max(0.8, 0.22 * F / Z)
  local b = brush{kind="flat", width=w, stiffness=0.6}
  local c = {pt(-1.65, FLY, Z), pt(-1.65, FLY - 2.45, Z), pt(1.65, FLY - 2.45, Z), pt(1.65, FLY, Z)}
  for j = 1, 3 do b:load(rib, 1); b:stroke({c[j], c[j + 1]}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, orient="across", clip=HOLE}) end
end

--@ chunk 4
-- the torn chambered edge round the cut, and the nave's pointed ribs coming toward us
print(wait(1*24*60))
local band = (CUT:grow(10) - CUT) * ENDW
local raw = pile{{"Mars orange",1},{"yellow ochre",1},{"lead white",0.7},{"burnt sienna",0.3}, medium=0.06}
work(band, {hand="body", tool="filbert 3", pile=raw, coverage=4, fill=true, clip=band, load=1})
local cellP = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",0.9}, medium=0.06}
local lipP = pile{{"lead white",2},{"yellow ochre",0.8},{"cadmium yellow",0.15}, medium=0.06}
-- chambers: small dark cells in the torn face, each with a lit septum on its upper side
local o = outline{pts=CUTPTS, closed=true, char="broken", seed=4, amount=0.6}
local L = o:length()
local n = 0
local t = 0
while t < 1 do
  local cx, cy = o:at(t)
  local dx, dy = cx - VX, cy - (VY + 20)
  local d = math.sqrt(dx*dx + dy*dy); dx, dy = dx / d, dy / d
  local off = rand(3.5, 7)
  local x, y = cx + dx * off, cy + dy * off
  local s = rand(1.6, 3.2)
  local b = brush{kind="round", width=s * 1.4, stiffness=0.4}
  b:load(cellP, 0.9)
  b:stroke({{x - dy * s, y + dx * s}, {x + dy * s, y - dx * s}}, {pressure={0.8, 0.7}, clip=band})
  local lb = brush{kind="round", width=0.9, point=0.5}
  lb:load(lipP, 0.7)
  lb:stroke({{x - dy * s + dx * 1.5, y + dx * s + dy * 1.5}, {x + dy * s + dx * 1.5, y - dx * s + dy * 1.5}}, {pressure={0.5, 0.4}, clip=band})
  n = n + 1
  t = t + rand(5, 9) / L
end
print("cells", n)
-- ribs: pointed arches of bronze at uneven depths, a lit underside edge
RIBZS = {2.1, 3.2, 4.6, 6.2, 7.8}
local ribD = pile{{"burnt sienna",1.2},{"Mars brown",0.8},{"bone black",0.8},{"raw sienna",0.3}, medium=0.06}
local ribL = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.4},{"Mars orange",0.2}, medium=0.06}
for i = #RIBZS, 1, -1 do
  local Z = RIBZS[i]
  local w = 0.32 * F / Z
  local pts = ARCH(Z)
  local b = brush{kind="round", width=w, stiffness=0.6}
  b:load(ribD, 1)
  b:stroke(pts, {pressure={0.9, 0.9}, clip=-FLOOR})
  local pin = ARCH(Z, HWN - 0.17)
  local lb = brush{kind="round", width=math.max(1, w * 0.18), point=0.4}
  lb:load(ribL, 0.85)
  lb:stroke(pin, {pressure={0.6, 0.6}, clip=-FLOOR})
end

--@ chunk 5
-- side walls and vault darker toward the edges (no horizontal seam), then the ribs whole, reloaded per half
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local d1 = pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",1.0},{"yellow ochre",0.2}, medium=0.06}
local d2 = pile{{"burnt sienna",1.2},{"raw sienna",1},{"bone black",0.6},{"yellow ochre",0.5},{"lead white",0.2}, medium=0.06}
local outer = mask(function(x, y) return (math.abs(x - VX) > 360 or y < 90) and 1 or 0 end):soften(20)
local N = NAVE - ENDW:grow(1)
work(N * outer, {hand="body", tool="filbert 12", pile=d1, coverage=4, fill=true, clip=N, angle=toVP, load=1})
work(N - outer, {hand="body", tool="filbert 10", pile=d2, coverage=4, fill=true, clip=N, angle=toVP, load=1})
local ribD = pile{{"burnt sienna",1.2},{"Mars brown",0.8},{"bone black",0.9},{"raw sienna",0.3}, medium=0.06}
local ribL = pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.4},{"Mars orange",0.2}, medium=0.06}
for i = #RIBZS, 1, -1 do
  local Z = RIBZS[i]
  local w = 0.32 * F / Z
  local pts = ARCH(Z)
  local half = math.ceil(#pts / 2)
  local A, B = {}, {}
  for j = 1, half do A[#A+1] = pts[j] end
  for j = half, #pts do B[#B+1] = pts[j] end
  for _, seg in ipairs{A, B} do
    for j = 1, #seg - 1, 3 do
      local s = {}
      for q = j, math.min(j + 3, #seg) do s[#s+1] = seg[q] end
      if #s >= 2 then
        local b = brush{kind="round", width=w, stiffness=0.6}
        b:load(ribD, 1)
        b:stroke(s, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, clip=-FLOOR})
      end
    end
  end
end
RIBDONE = true

--@ chunk 6
-- ribs again on set paint; the end wall's inner face laid in golden-spiral scale plates round the cut
print(wait(4*24*60))
local ribD = pile{{"burnt sienna",1},{"Mars brown",1},{"bone black",1.1}, medium=0.06}
local ribL = pile{{"yellow ochre",1.5},{"lead white",1.1},{"raw sienna",0.3},{"Mars orange",0.2}, medium=0.06}
local function strokeSeg(pts, w, pl, ld, pr)
  for j = 1, #pts - 1, 3 do
    local s = {}
    for q = j, math.min(j + 3, #pts) do s[#s+1] = pts[q] end
    if #s >= 2 then
      local b = brush{kind="round", width=w, stiffness=0.6, point=0.2}
      b:load(pl, ld)
      b:stroke(s, {pressure=pr, ramps={0.02, 0.02}, clip=-FLOOR - ENDW})
    end
  end
end
for i = #RIBZS, 1, -1 do
  local Z = RIBZS[i]
  local w = 0.3 * F / Z
  strokeSeg(ARCH(Z), w, ribD, 1, {0.95, 0.95})
end
-- plates: Vogel spiral about a point just above the cut, warm lit bronze varied
local cx, cy = P(0.0, FLY - 2.0, ZW)
local W = ENDW - CUT:grow(10)
local pl = {
  pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.6}, medium=0.06},
  pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.3},{"yellow ochre",0.6}, medium=0.06},
  pile{{"yellow ochre",2},{"lead white",1},{"Mars orange",0.3}, medium=0.06},
  pile{{"burnt sienna",1.2},{"Mars orange",0.5},{"yellow ochre",0.6},{"bone black",0.2}, medium=0.06},
}
local sh = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",0.7}, medium=0.08}
PLR = {}
for n = 1, 900 do
  local r = 7.5 * math.sqrt(n)
  local th = n * 2.399963
  local x, y = cx + r * math.cos(th), cy + r * math.sin(th)
  if W:at(x, y) > 0.5 then
    local sz = 13 + 3 * ((n * 0.618034) % 1)
    local c, s = math.cos(th), math.sin(th)
    local b = brush{kind="filbert", width=sz, stiffness=0.5}
    b:load(pl[1 + (n * 7) % 4], 0.8)
    b:stroke({{x - c * sz * 0.4, y - s * sz * 0.4}, {x + c * sz * 0.25, y + s * sz * 0.25}}, {pressure={0.8, 0.7}, ramps={0.1, 0.3}, orient="across", clip=W})
    PLR[#PLR+1] = {x=x, y=y, a=th, sz=sz}
  end
end
print(#PLR)

--@ chunk 7
-- the plates read as beans: larger overlapping scales over them, painted from the centre out
print(wait(1*24*60))
local W = ENDW - CUT:grow(10)
local pl = {
  pile{{"yellow ochre",1.5},{"raw sienna",1},{"burnt sienna",0.5},{"lead white",0.6}, medium=0.06},
  pile{{"raw sienna",1.5},{"burnt sienna",1},{"bone black",0.35},{"yellow ochre",0.6}, medium=0.06},
  pile{{"yellow ochre",2},{"lead white",1},{"Mars orange",0.3}, medium=0.06},
  pile{{"burnt sienna",1.2},{"Mars orange",0.5},{"yellow ochre",0.6},{"bone black",0.2}, medium=0.06},
  pile{{"raw sienna",1},{"viridian",0.25},{"yellow ochre",0.8},{"lead white",0.4},{"bone black",0.3}, medium=0.06},
}
for i, p in ipairs(PLR) do
  local sz = p.sz * 1.75
  local c, s = math.cos(p.a), math.sin(p.a)
  local b = brush{kind="filbert", width=sz, stiffness=0.5}
  local k = 1 + ((i * 0.618034 * 13) // 1) % 5
  b:load(pl[k], 0.85)
  b:stroke({{p.x - c * sz * 0.3, p.y - s * sz * 0.3}, {p.x + c * sz * 0.2, p.y + s * sz * 0.2}}, {pressure={0.85, 0.75}, ramps={0.1, 0.3}, orient="across", clip=W})
end

--@ chunk 8
-- give the camouflage its scales back: a dark crescent under each plate's free edge, a lit lip above it
print(wait(4*24*60))
local W = ENDW - CUT:grow(10)
local sh = pile{{"burnt sienna",1},{"Mars brown",0.9},{"bone black",1}, medium=0.08}
local lip = pile{{"lead white",1.6},{"yellow ochre",1},{"cadmium yellow",0.15}, medium=0.06}
for i, p in ipairs(PLR) do
  local sz = p.sz * 1.75
  local R = sz * 0.5
  local ox, oy = p.x + math.cos(p.a) * sz * 0.12, p.y + math.sin(p.a) * sz * 0.12
  local pts, lp = {}, {}
  for k = -3, 3 do
    local a = p.a + k * 0.32
    pts[#pts+1] = {ox + math.cos(a) * R, oy + math.sin(a) * R}
    lp[#lp+1] = {ox + math.cos(a) * (R - 3), oy + math.sin(a) * (R - 3)}
  end
  local b = brush{kind="round", width=3.6, point=0.2}
  b:load(sh, 0.8)
  b:stroke(pts, {pressure={0.5, 0.8}, swell={0.5, 1, 0.5}, clip=W})
  local lb = brush{kind="round", width=1.3, point=0.6}
  lb:load(lip, 0.6)
  lb:stroke(lp, {pressure={0.15, 0.55}, swell={0.3, 1, 0.3}, clip=W})
end
print(#PLR)

--@ chunk 9
-- floor: darker toward the walls, a bone aisle runner to the cut; then the good chairs, facing us, each casting its shadow toward the cut
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local fd = pile{{"burnt sienna",1.2},{"raw sienna",1},{"bone black",0.7},{"yellow ochre",0.3}, medium=0.06}
local side = FLOOR - poly({pt(-2.2, FLY, 0.6), pt(-1.2, FLY, ZW), pt(1.2, FLY, ZW), pt(2.2, FLY, 0.6)})
work(side, {hand="body", tool="filbert 10", pile=fd, coverage=3.5, fill=true, clip=side, angle=toVP, load=1})
local runner = poly({pt(-0.38, FLY, 0.8), pt(-0.38, FLY, ZW), pt(0.38, FLY, ZW), pt(0.38, FLY, 0.8)}) * FLOOR
local boneP = pile{{"lead white",2},{"yellow ochre",0.6},{"raw sienna",0.15}, medium=0.06}
work(runner, {hand="body", tool="filbert 5", pile=boneP, coverage=4, fill=true, clip=runner, angle=toVP, load=1})
print(wait(2*24*60))
local back = {
  pile{{"yellow ochre",1.5},{"raw sienna",0.8},{"lead white",0.7},{"burnt sienna",0.3}, medium=0.06},
  pile{{"raw sienna",1.3},{"burnt sienna",0.8},{"yellow ochre",0.8},{"lead white",0.4}, medium=0.06},
}
local dk = pile{{"burnt sienna",1},{"Mars brown",0.9},{"bone black",0.9}, medium=0.06}
local seatP = pile{{"yellow ochre",1.5},{"lead white",1.1},{"raw sienna",0.3}, medium=0.06}
local shP = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",0.8},{"raw sienna",0.3}, medium=0.08}
local bone = pile{{"lead white",2.2},{"yellow ochre",0.4}, medium=0.06}
CHM = nil
local rows = {7.0, 5.4, 4.0, 2.9}
local cols = {-2.95, -2.1, -1.25, 1.25, 2.1, 2.95}
for ri, Z in ipairs(rows) do
  for ci, X0 in ipairs(cols) do
    local X = X0 + 0.08 * math.sin(ri * 3.1 + ci * 1.7)
    local k = F / Z
    local bx, by = P(X, FLY, Z)
    if bx > -40 and bx < 1040 then
      -- shadow on the floor, thrown away from us toward the cut
      local s = ellipse(0, 0, 1, 1)
      local sp = poly({pt(X - 0.3, FLY, Z), pt(X + 0.3, FLY, Z), pt(X + 0.25, FLY, Z + 1.3), pt(X - 0.25, FLY, Z + 1.3)}, true) * FLOOR
      work(sp, {hand="detail", pile=shP, coverage=3, fill=true, clip=sp, load=0.8})
      -- the back (behind the seat, so a touch higher), a tall paddle with a bone spine
      local bb = brush{kind="filbert", width=0.42 * k, stiffness=0.5}
      bb:load(back[1 + (ri + ci) % 2], 0.9)
      local bxx, byy = P(X, FLY, Z + 0.25)
      bb:stroke({{bxx, byy - 1.35 * k}, {bxx, byy - 0.5 * k}}, {pressure={0.9, 0.8}, ramps={0.15, 0.1}})
      local sb = brush{kind="round", width=math.max(0.6, 0.035 * k), point=0.5}
      sb:load(bone, 0.8)
      sb:stroke({{bxx, byy - 1.3 * k}, {bxx, byy - 0.6 * k}}, {pressure={0.6, 0.4}})
      -- stem and foot
      local st = brush{kind="round", width=math.max(1, 0.07 * k), stiffness=0.6}
      st:load(dk, 0.9)
      st:stroke({{bx, by - 0.45 * k}, {bx, by}}, {pressure={0.9, 0.9}})
      local ft = brush{kind="flat", width=math.max(1, 0.05 * k)}
      ft:load(dk, 0.9)
      ft:stroke({{bx - 0.24 * k, by}, {bx + 0.24 * k, by}}, {pressure={0.8, 0.8}, orient="across"})
      -- lens seat: a lit top, a dark rim under it
      local se = brush{kind="round", width=math.max(1, 0.09 * k), stiffness=0.5}
      se:load(seatP, 0.9)
      se:stroke({{bx - 0.36 * k, by - 0.5 * k}, {bx, by - 0.53 * k}, {bx + 0.36 * k, by - 0.5 * k}}, {pressure={0.4, 0.4}, swell={0.4, 1, 0.4}})
      se:load(dk, 0.9)
      se:stroke({{bx - 0.3 * k, by - 0.45 * k}, {bx + 0.3 * k, by - 0.45 * k}}, {pressure={0.35, 0.35}, swell={0.4, 1, 0.4}})
    end
  end
end

--@ chunk 10
-- what came in from outside: tripod and taped board seen from the nave side, cables over the sill, the Commando in the cut
print(wait(2*24*60))
local Zc = ZW + 1.2
local iD = pile{{"bone black",2},{"ultramarine ash",0.6},{"lead white",0.25}, medium=0.06}
local iM = pile{{"bone black",1.5},{"ultramarine ash",0.8},{"lead white",0.6}, medium=0.06}
local warm = pile{{"lead white",1.5},{"yellow ochre",0.8},{"Mars orange",0.2}, medium=0.06}
local function rod(a, b, w, pl, pr, clipm)
  local br = brush{kind="round", width=w, stiffness=0.6}
  br:load(pl, 0.9)
  br:stroke({a, b}, {pressure=pr or {0.85, 0.8}, clip=clipm})
end
-- tripod just beyond the cut on the left, its sensor aimed at us
local tz = ZW + 1.0
local head = pt(-0.85, FLY - 1.25, tz)
rod(head, pt(-1.25, FLY, tz - 0.3), 2.2, iD, nil, HOLE)
rod(head, pt(-0.45, FLY, tz - 0.2), 2.2, iD, nil, HOLE)
rod(head, pt(-0.9, FLY, tz + 0.5), 1.8, iD, nil, HOLE)
local hx, hy = head[1], head[2]
local hb = rect(hx - 9, hy - 9, 18, 10) * HOLE
work(hb, {hand="detail", pile=iM, coverage=4, fill=true, clip=hb, load=1})
local lens = ellipse(hx + 1, hy - 4, 3, 3) * HOLE
work(lens, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.5}, medium=0.06}, coverage=4, fill=true, clip=lens, load=1})
rod({hx + 2.5, hy - 5}, {hx + 3, hy - 4.5}, 1.2, pile{{"vermilion",1},{"lead white",0.3}, medium=0.06}, {0.8, 0.8})
-- the back of the taped warning board, against the right of the opening
local bq = poly({pt(0.95, FLY - 2.15, ZW + 0.7), pt(1.6, FLY - 2.2, ZW + 0.7), pt(1.6, FLY - 1.45, ZW + 0.7), pt(0.97, FLY - 1.4, ZW + 0.7)}) * HOLE
work(bq, {hand="detail", pile=pile{{"lead white",0.8},{"bone black",0.8},{"raw sienna",0.3},{"ultramarine ash",0.2}, medium=0.06}, coverage=4, fill=true, clip=bq, load=1})
local tape = pile{{"lead white",1.2},{"bone black",0.4},{"yellow ochre",0.25}, medium=0.06}
for _, c in ipairs{pt(0.97, FLY - 2.12, ZW + 0.7), pt(0.99, FLY - 1.45, ZW + 0.7)} do
  rod({c[1] - 3, c[2] - 2}, {c[1] + 4, c[2] + 2}, 2.6, tape, {0.7, 0.7}, HOLE)
end
-- the Commando, stepping in out of the gray, toward us; dark, the nave light on his front planes
local Z = ZW + 0.45
local k = F / Z
local fx, fy = P(0.18, FLY, Z)
local function Q(x, y) return {fx + x * k, fy - y * k} end
local fig = ribbon({Q(-0.11,0.93), Q(-0.14,0.5), Q(-0.15,0.1)}, {0.17*k, 0.13*k, 0.11*k})
  + ribbon({Q(0.11,0.93), Q(0.13,0.52), Q(0.12,0.12)}, {0.17*k, 0.13*k, 0.11*k})
  + poly({Q(-0.27,0.0), Q(-0.04,0.0), Q(-0.06,0.14), Q(-0.24,0.14)}) + poly({Q(0.04,0.0), Q(0.25,0.0), Q(0.23,0.14), Q(0.06,0.14)})
  + poly({Q(-0.2,0.88), Q(0.2,0.88), Q(0.21,1.06), Q(-0.21,1.06)}, true)
  + poly({Q(-0.18,1.02), Q(0.18,1.02), Q(0.24,1.32), Q(0.31,1.5), Q(0.28,1.58), Q(0.1,1.61), Q(-0.1,1.61), Q(-0.28,1.58), Q(-0.31,1.5), Q(-0.24,1.32)}, true)
  + poly({Q(-0.05,1.55), Q(0.05,1.55), Q(0.05,1.67), Q(-0.05,1.67)})
  + ellipse(fx, fy - 1.76 * k, 0.105 * k, 0.13 * k)
  + ellipse(fx - 0.3 * k, fy - 1.53 * k, 0.12 * k, 0.085 * k) + ellipse(fx + 0.3 * k, fy - 1.53 * k, 0.12 * k, 0.085 * k)
  + ribbon({Q(-0.31,1.5), Q(-0.37,1.22), Q(-0.33,0.97)}, {0.12*k, 0.1*k, 0.09*k})
  + ribbon({Q(0.31,1.5), Q(0.4,1.28), Q(0.3,1.12), Q(0.12,1.08)}, {0.12*k, 0.1*k, 0.09*k, 0.08*k})    -- right arm: hand on the cut's edge? no: carrying the rifle across
  + ribbon({Q(-0.25,1.0), Q(0.05,1.12), Q(0.45,1.3)}, {0.05*k, 0.05*k, 0.04*k})
FIGR, FRK, FRX, FRY = fig, k, fx, fy
local figD = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.3}, medium=0.06}
work(fig, {hand="detail", pile=figD, coverage=5, fill=true, clip=fig, load=1})
-- his shadow thrown away from us into the corridor
local sh = poly({pt(0.18 - 0.22, FLY, Z), pt(0.18 + 0.22, FLY, Z), pt(0.18 + 0.35, FLY, Z + 4), pt(0.18 - 0.35, FLY, Z + 4)}) * HOLE - fig
work(sh, {hand="detail", pile=pile{{"bone black",2},{"ultramarine blue",0.4},{"burnt sienna",0.3}, medium=0.06}, coverage=4, fill=true, clip=sh, load=1})
-- cables: out of the gray, over the sill, across the nave floor toward us
CBL = {
  {pt(-0.5, FLY, ZW + 3), pt(-0.6, FLY, ZW + 0.3), pt(-0.75, FLY, ZW - 0.6), pt(-0.55, FLY, 6.5), pt(-0.95, FLY, 4.8), pt(-0.7, FLY, 3.4), pt(-1.0, FLY, 2.2), pt(-0.9, FLY, 1.3)},
  {pt(0.85, FLY, ZW + 2), pt(0.9, FLY, ZW + 0.2), pt(1.0, FLY, ZW - 1.0), pt(0.75, FLY, 6.0), pt(1.05, FLY, 4.2), pt(0.85, FLY, 2.8), pt(1.15, FLY, 1.6)},
}
for _, c in ipairs(CBL) do
  for i = 1, #c - 1 do
    local Zm = F * FLY / math.max(1, ((c[i][2] + c[i+1][2]) / 2) - VY)
    local w = math.max(1.2, 0.05 * F / Zm)
    local b = brush{kind="round", width=w, stiffness=0.4}
    b:load(pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.4}, medium=0.06}, 0.95)
    b:stroke({c[i], c[i+1]}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}, clip=-fig})
  end
end

--@ chunk 11
-- the nave's light on the Commando's front: plates picked out warm against the cold gray; visor dark
print(wait(2*24*60))
local k, fx, fy = FRK, FRX, FRY
local function Q(x, y) return {fx + x * k, fy - y * k} end
local lt = pile{{"yellow ochre",1.5},{"lead white",0.9},{"raw sienna",0.4},{"burnt sienna",0.3}, medium=0.06}
local mt = pile{{"raw sienna",1.2},{"burnt sienna",0.8},{"yellow ochre",0.5},{"bone black",0.4}, medium=0.06}
local hot = pile{{"lead white",2},{"yellow ochre",0.7},{"cadmium yellow",0.2}, medium=0.06}
local vis = pile{{"bone black",2},{"ultramarine blue",0.3}, medium=0.06}
local function st(pts, pl, w, pr, tool)
  local b = brush{kind=tool or "filbert", width=w, stiffness=0.5}
  b:load(pl, 0.85)
  b:stroke(pts, {pressure=pr, clip=FIGR})
end
-- helmet: lit dome, dark visor band
st({Q(0.0,1.86), Q(0.0,1.72)}, mt, 0.17 * k, {0.8, 0.7})
st({Q(-0.03,1.86), Q(-0.02,1.78)}, lt, 0.08 * k, {0.7, 0.5})
st({Q(-0.08,1.74), Q(0.08,1.74)}, vis, 0.04 * k, {0.8, 0.8}, "round")
-- pauldrons and chest
st({Q(-0.38,1.56), Q(-0.22,1.58)}, lt, 0.07 * k, {0.8, 0.6})
st({Q(0.22,1.58), Q(0.38,1.55)}, mt, 0.07 * k, {0.8, 0.6})
st({Q(-0.12,1.5), Q(-0.1,1.22)}, mt, 0.14 * k, {0.8, 0.7})
st({Q(0.1,1.5), Q(0.1,1.22)}, mt, 0.12 * k, {0.7, 0.6})
st({Q(-0.14,1.48), Q(-0.12,1.3)}, lt, 0.05 * k, {0.7, 0.4})
st({Q(-0.2,1.04), Q(0.2,1.04)}, lt, 0.03 * k, {0.6, 0.6}, "round")
-- thighs, knees, shins (left leg nearer the light)
st({Q(-0.13,0.88), Q(-0.14,0.6)}, mt, 0.1 * k, {0.75, 0.6})
st({Q(-0.15,0.85), Q(-0.15,0.62)}, lt, 0.04 * k, {0.6, 0.4})
st({Q(0.12,0.88), Q(0.13,0.6)}, mt, 0.09 * k, {0.6, 0.5})
st({Q(-0.14,0.53), Q(-0.14,0.49)}, hot, 0.06 * k, {0.8, 0.8}, "round")
st({Q(0.13,0.53), Q(0.13,0.49)}, lt, 0.05 * k, {0.7, 0.7}, "round")
st({Q(-0.15,0.4), Q(-0.15,0.15)}, mt, 0.07 * k, {0.6, 0.4})
st({Q(-0.22,0.1), Q(-0.07,0.1)}, lt, 0.03 * k, {0.6, 0.6}, "round")
st({Q(0.07,0.1), Q(0.22,0.1)}, mt, 0.03 * k, {0.6, 0.6}, "round")
-- rifle catching the light along its top
st({Q(-0.22,1.02), Q(0.05,1.13), Q(0.42,1.29)}, hot, 0.015 * k, {0.6, 0.6}, "round")

--@ chunk 12
-- the soft-masked wall pass left a fuzzy box: repaint the vault bay by bay between the ribs, darker toward us
print(wait(2*24*60))
local toVP = function(x, y) return math.atan(VY - y, VX - x) end
local RM = nil
for _, Z in ipairs(RIBZS) do
  local r = ribbon(ARCH(Z), 0.3 * F / Z + 1)
  RM = RM and (RM + r) or r
end
local top = above(function(x) return 332 end)
local piles = {
  pile{{"burnt sienna",1},{"Mars brown",0.6},{"bone black",1.1},{"raw sienna",0.3}, medium=0.06},
  pile{{"burnt sienna",1.2},{"raw sienna",0.6},{"bone black",0.9},{"yellow ochre",0.2}, medium=0.06},
  pile{{"burnt sienna",1.2},{"raw sienna",0.8},{"bone black",0.7},{"yellow ochre",0.35},{"lead white",0.1}, medium=0.06},
  pile{{"burnt sienna",1},{"raw sienna",1},{"bone black",0.55},{"yellow ochre",0.5},{"lead white",0.25}, medium=0.06},
  pile{{"raw sienna",1.2},{"burnt sienna",0.8},{"yellow ochre",0.7},{"bone black",0.4},{"lead white",0.4}, medium=0.06},
  pile{{"raw sienna",1.2},{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.3},{"lead white",0.6}, medium=0.06},
}
local zs = {0.6}
for _, Z in ipairs(RIBZS) do zs[#zs+1] = Z end
zs[#zs+1] = ZW
for i = 1, #zs - 1 do
  local outer = (i == 1) and everywhere() or poly(ARCH(zs[i]))
  local inner = poly(ARCH(zs[i + 1]))
  local m = (outer - inner) * top - FLOOR - RM - ENDW
  work(m, {hand="body", tool="filbert 8", pile=piles[i], coverage=4, fill=true, clip=m, angle=toVP, load=1})
end

--@ chunk 13
-- porthole niches in the bays, a few lit by small bone lamps; a dark side on each chair back
print(wait(1*24*60))
local niche = pile{{"burnt sienna",1},{"Mars brown",0.8},{"bone black",1}, medium=0.06}
local lampP = pile{{"lead white",2.5},{"cadmium yellow",0.25},{"yellow ochre",0.2}, medium=0.05}
local zs = {RIBZS[1], RIBZS[2], RIBZS[3], RIBZS[4], RIBZS[5], ZW}
local n = 0
for i = 1, #zs - 1 do
  local Zm = (zs[i] + zs[i + 1]) / 2
  for _, sx in ipairs{-1, 1} do
    for _, h in ipairs{2.6, 3.6} do
      local X = sx * (HWN - 0.05)
      local x, y = P(X, FLY - h, Zm)
      local k = F / Zm
      local rx = math.max(1.5, 0.22 * k * 0.45)
      local ry = math.max(2, 0.22 * k)
      if x > 5 and x < 995 then
        local e = ellipse(x, y, rx, ry)
        work(e, {hand="detail", pile=niche, coverage=4, fill=true, clip=e, load=1})
        n = n + 1
        if ((i * 3 + (sx > 0 and 1 or 0) + h * 2) * 0.618034) % 1 < 0.5 then
          local l = ellipse(x, y + ry * 0.1, rx * 0.5, ry * 0.45)
          work(l, {hand="detail", pile=lampP, coverage=4, fill=true, clip=l, load=1})
        end
      end
    end
  end
end
print("niches", n)

--@ chunk 14
-- chair backs turned: a shadow side and a lit edge; a warm sheen along the cables
print(wait(2*24*60))
local dk = pile{{"burnt sienna",1},{"Mars brown",0.7},{"bone black",0.7},{"raw sienna",0.3}, medium=0.06}
local lt = pile{{"lead white",1.8},{"yellow ochre",0.7}, medium=0.06}
local rows = {7.0, 5.4, 4.0, 2.9}
local cols = {-2.95, -2.1, -1.25, 1.25, 2.1, 2.95}
for ri, Z in ipairs(rows) do
  for ci, X0 in ipairs(cols) do
    local X = X0 + 0.08 * math.sin(ri * 3.1 + ci * 1.7)
    local k = F / Z
    local bxx, byy = P(X, FLY, Z + 0.25)
    if bxx > -40 and bxx < 1040 then
      local side = (X < 0) and -1 or 1   -- the side away from the aisle turns into shadow
      local b = brush{kind="round", width=math.max(1, 0.07 * k), stiffness=0.5}
      b:load(dk, 0.9)
      b:stroke({{bxx + side * 0.17 * k, byy - 1.3 * k}, {bxx + side * 0.18 * k, byy - 0.6 * k}}, {pressure={0.7, 0.6}})
      local l = brush{kind="round", width=math.max(0.7, 0.025 * k), point=0.5}
      l:load(lt, 0.8)
      l:stroke({{bxx - side * 0.16 * k, byy - 1.32 * k}, {bxx - side * 0.17 * k, byy - 0.7 * k}}, {pressure={0.6, 0.2}})
      l:load(lt, 0.8)
      l:stroke({{bxx - 0.12 * k, byy - 1.44 * k}, {bxx + 0.12 * k, byy - 1.44 * k}}, {pressure={0.4, 0.4}})
    end
  end
end
local hi = pile{{"lead white",1.2},{"yellow ochre",0.8},{"burnt sienna",0.2}, medium=0.06}
for _, c in ipairs(CBL) do
  for i = 3, #c - 1 do
    local b = brush{kind="round", width=1.0, point=0.5}
    b:load(hi, 0.6)
    b:stroke({{c[i][1] - 1.5, c[i][2] - 1.5}, {c[i+1][1] - 1.5, c[i+1][2] - 1.5}}, {pressure={0.4, 0.4}, clip=-FIGR})
  end
end

