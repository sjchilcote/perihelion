-- easel session "vigil_end": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=7171, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone brown",1},{"raw sienna",0.8},{"bone black",0.8},{"lead white",0.25}}, um=45, apply="brush", texture=0.35}}}
VP = {500, 250}
XW, YF, YC, ZF = 520, 330, -300, 6.5
function pr(X, Y, z) return {VP[1] + X/z, VP[2] + Y/z} end
FLOOR = poly({pr(-XW, YF, 0.5), pr(XW, YF, 0.5), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
CEIL = poly({pr(-XW, YC, 0.4), pr(XW, YC, 0.4), pr(XW, YC, ZF), pr(-XW, YC, ZF)})
LW = poly({pr(-XW, YC, 0.4), pr(-XW, YC, ZF), pr(-XW, YF, ZF), pr(-XW, YF, 0.4)})
RW = poly({pr(XW, YC, 0.4), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(XW, YF, 0.4)})
ENDW = poly({pr(-XW, YC, ZF), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local F = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.2}}
local W = pile{{"raw sienna",1},{"bone brown",0.6},{"yellow ochre",0.3},{"bone black",0.4},{"lead white",0.25}}
local C = pile{{"bone brown",1},{"bone black",1},{"raw sienna",0.3},{"lead white",0.08}}
local E = pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",0.8},{"Mars orange",0.1}}
work(FLOOR, {hand="body", pile=F, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
work(CEIL, {hand="body", pile=C, coverage=3, fill=true, clip=CEIL, angle=toVP, length={20, 50}, tool="filbert 9"})
work(LW + RW, {hand="body", pile=W, coverage=3, fill=true, clip=LW + RW, angle=toVP, length={15, 40}, tool="filbert 8"})
work(ENDW, {hand="detail", pile=E, coverage=4, fill=true, clip=ENDW, tool={kind="round", width=2}, length={3, 8}})

--@ chunk 2
print(wait(5*24*60), drying(500,300))
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
-- walls darken toward us: the light is ahead
local WD = pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.9},{"lead white",0.1}}
local near = (LW + RW) * mask(function(x,y) return math.abs(x - VP[1]) > 230 and 1 or 0 end):soften(40)
work(near, {hand="body", pile=WD, coverage=2.5, fill=true, clip=LW + RW, angle=toVP, length={15, 40}, tool="filbert 8"})
-- ribs on the walls, warm edges toward the far light
local RB = pile{{"bone brown",1},{"bone black",1.2},{"raw sienna",0.3}}
local RL = pile{{"yellow ochre",1},{"raw sienna",0.4},{"lead white",0.7}}
local z = 0.7
while z < 6.3 do
  for _, sd in ipairs({-1, 1}) do
    local w = clamp(16/z, 2, 22)
    local b = brush{kind="filbert", width=w, stiffness=0.5}
    b:reload(RB, 0.9) b:stroke({pr(sd*XW, YF, z), pr(sd*XW, YC, z)}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
    local e = brush{kind="rigger", width=clamp(2/z, 0.5, 3), point=1}
    e:load(RL, 0.9) e:stroke({pr(sd*XW, YF, z*1.03), pr(sd*XW, YC, z*1.03)}, {pressure={0.45, 0.45}, ramps={0.03, 0.03}})
  end
  z = z * 1.3
end

--@ chunk 3
print(wait(5*24*60), drying(500,230))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- the high window in the end wall, arched; the small gentle Sun in it
local W = poly({{478, 210}, {522, 210}, {522, 238}, {478, 238}}) + ellipse(500, 210, 22, 10)
WINM = W
fill(W:grow(2.5), pile{{"bone brown",1},{"bone black",1.2}})
fill(W, pile{{"lead white",2.2},{"cerulean blue",0.12},{"cadmium yellow",0.1}})
local sb = brush{kind="round", width=4, point=0.3}
sb:load(pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.4}}, 0.95) sb:touch(507, 220, {pressure=0.7})
local mb = brush{kind="rigger", width=1.0, point=1}
mb:load(pile{{"bone brown",1},{"bone black",1}}, 0.9) mb:stroke({{500, 201}, {500, 238}}, {pressure={0.6, 0.6}})
-- altar: a bone-white block with a dark cloth, at the foot of the end wall
ALT = poly({{462, 275}, {538, 275}, {540, 300}, {460, 300}})
fill(ALT, pile{{"lead white",1.3},{"yellow ochre",0.4},{"raw sienna",0.15},{"bone black",0.12}})
fill(rect(460, 296, 80, 4), pile{{"bone brown",1},{"bone black",0.8}}, "round 1")
fill(poly({{486, 275}, {514, 275}, {514, 300}, {486, 300}}), pile{{"Mars red",0.7},{"rose madder",0.5},{"bone black",0.5}}, "round 1")
-- the light falling down the aisle: a long warm strip on the floor
local strip = poly({pr(-90, YF, 6.3), pr(90, YF, 6.3), pr(150, YF, 0.9), pr(-150, YF, 0.9)})
AISLE = strip
local SL = {
 pile{{"bone brown",1},{"raw sienna",0.8},{"bone black",0.4},{"lead white",0.35}},
 pile{{"raw sienna",0.8},{"yellow ochre",0.6},{"lead white",0.6},{"bone black",0.15}},
}
local cells = {}
for y = 300, 566, 2.8 do for x = 300, 700, 3 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if strip:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (yy - 300)/266
    local v = 2.2 - t*1.4 + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 2)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3, stiffness=0.5}
for i = 1, 2 do if g[i] then
  b:reload(SL[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(SL[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(3, 7)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=strip})
  end
end end
print(#cells)

--@ chunk 4
print(wait(5*24*60), drying(260,250))
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local P3 = {
 pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.9},{"lead white",0.1}},
 pile{{"raw sienna",0.9},{"bone brown",0.7},{"bone black",0.6},{"yellow ochre",0.15},{"lead white",0.17}},
 pile{{"raw sienna",1},{"bone brown",0.6},{"yellow ochre",0.3},{"bone black",0.4},{"lead white",0.25}},
}
local cells = {}
for y = 0, 566, 3 do for x = 180, 820, 3.2 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  local d = math.abs(xx - VP[1])
  if d > 190 and d < 330 and (LW + RW):at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (d - 190)/140*3 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(3 - math.floor(t), 1, 3)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3.2, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(P3[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(P3[i], 0.9) end
    local a = toVP(c.x, c.y) + randn(0, 0.05)
    local h = rand(3, 7)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=LW + RW})
  end
end end
print(#cells)

--@ chunk 5
print(wait(5*24*60))
ROWS = {4.3, 3.3, 2.55, 1.95, 1.5, 1.15}
local XS = {-430, -330, -230, 230, 330, 430}
local TYPES = {
 [4.3] = {"d", "c", "d", "d", "r", "c"},
 [3.3] = {"c", "d", "c", "d", "c", "d"},
 [2.55] = {"d", "-", "c", "c", "d", "-"},
 [1.95] = {"-", "d", "d", "c", "-", "d"},
 [1.5] = {"c", "-", "d", "-", "d", "c"},
 [1.15] = {"-", "-", "-", "-", "-", "-"},
}
local function e(X, Y, z, rx, ry) local c = pr(X, Y, z) return ellipse(c[1], c[2], rx/z, ry/z) end
local function q(X0, X1, Y0, Y1, z) return poly({pr(X0, Y0, z), pr(X1, Y0, z), pr(X1, Y1, z), pr(X0, Y1, z)}) end
GROUPS = {}
for gi, set in ipairs({{4.3, 3.3, 2.55}, {1.95, 1.5, 1.15}}) do
  local G = {robe=nil, egg=nil, ruff=nil, kid=nil, kidh=nil, hair=nil, pew=nil, rail={}}
  local function add(k, m) G[k] = G[k] and (G[k] + m) or m end
  for _, z in ipairs(set) do
    local zz = z + 0.06
    for i, X in ipairs(XS) do
      local t = TYPES[z][i]
      local jx = X + ((i*37 + math.floor(z*10)*13) % 30) - 15
      if t == "d" then
        add("robe", e(jx, 160, zz, 42, 34) + q(jx - 40, jx + 40, 150, 190, zz))
        add("ruff", e(jx, 120, zz, 30, 9))
        add("egg", e(jx, 88, zz, 21, 30))
      elseif t == "c" then
        add("kid", e(jx, 168, zz, 28, 20) + q(jx - 26, jx + 26, 165, 190, zz))
        add("kidh", e(jx, 138, zz, 17, 18))
      elseif t == "r" then
        add("hair", e(jx, 128, zz, 22, 24) + q(jx - 22, jx + 22, 128, 190, zz))
        RATIO = {jx, zz}
      end
    end
    add("pew", q(-480, -150, 170, YF, z) + q(150, 480, 170, YF, z))
    G.rail[#G.rail+1] = z
  end
  GROUPS[gi] = G
end
print("ok")

--@ chunk 6
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
local ROBE = pile{{"bone brown",1.2},{"raw sienna",0.4},{"bone black",1}}
local EGG = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.06}}
local RUFF = pile{{"lead white",0.9},{"yellow ochre",0.35},{"raw sienna",0.15},{"bone black",0.35}}
local KID = pile{{"ultramarine ash",0.7},{"bone black",0.8},{"lead white",0.35},{"raw sienna",0.1}}
local KIDH = pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.8}}
local HAIR = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local PEW = pile{{"bone black",1.2},{"bone brown",1},{"burnt sienna",0.2},{"lead white",0.05}}
local RL = pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",0.6}}
for gi = 1, 2 do
  local G = GROUPS[gi]
  fill(G.robe, ROBE) fill(G.kid, KID) fill(G.egg, EGG) fill(G.ruff, RUFF) fill(G.kidh, KIDH) fill(G.hair, HAIR)
  fill(G.pew, PEW, "round 2")
  for _, z in ipairs(G.rail) do
    local r = brush{kind="rigger", width=clamp(2.4/z, 0.6, 2.2), point=1}
    r:load(RL, 0.9) r:stroke({pr(-480, 172, z), pr(-150, 172, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
    r:load(RL, 0.9) r:stroke({pr(150, 172, z), pr(480, 172, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
  end
end

--@ chunk 7
print(wait(5*24*60), drying(300,400))
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
local ROBE = pile{{"bone brown",1.2},{"raw sienna",0.4},{"bone black",1}}
local EGG = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.06}}
local RUFF = pile{{"lead white",0.9},{"yellow ochre",0.35},{"raw sienna",0.15},{"bone black",0.35}}
local KID = pile{{"ultramarine ash",0.7},{"bone black",0.8},{"lead white",0.35},{"raw sienna",0.1}}
local KIDH = pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.8}}
local HAIR = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local PEW = pile{{"bone black",1.2},{"bone brown",1},{"burnt sienna",0.2},{"lead white",0.05}}
local UND = pile{{"bone black",2},{"bone brown",0.6}}
local RL = pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",0.6}}
local XS = {-430, -330, -230, 230, 330, 430}
local T = {[1.95] = {"-", "d", "d", "c", "-", "d"}, [1.5] = {"c", "-", "d", "r", "d", "c"}, [1.15] = {"d", "c", "-", "-", "c", "d"}}
local function e(X, Y, z, rx, ry) local c = pr(X, Y, z) return ellipse(c[1], c[2], rx/z, ry/z) end
local function q(X0, X1, Y0, Y1, z) return poly({pr(X0, Y0, z), pr(X1, Y0, z), pr(X1, Y1, z), pr(X0, Y1, z)}) end
local FLOORC = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.6},{"lead white",0.2}}
HEADS = {}
for _, z in ipairs({1.95, 1.5, 1.15}) do
  local zz = z + 0.06
  -- the floor between this pew and the next, so the old tall box is cut back
  fill(q(-480, -150, 236, YF, z*1.12) + q(150, 480, 236, YF, z*1.12), FLOORC, "round 2")
  for i, X in ipairs(XS) do
    local t = T[z][i]
    local jx = X + ((i*37 + math.floor(z*10)*13) % 30) - 15
    if t == "d" then
      fill(e(jx, 160, zz, 42, 34) + q(jx - 40, jx + 40, 150, 200, zz), ROBE)
      fill(e(jx, 88, zz, 21, 30), EGG)
      fill(e(jx, 120, zz, 30, 9), RUFF)
      HEADS[#HEADS+1] = {"d", jx, zz}
    elseif t == "c" then
      fill(e(jx, 168, zz, 28, 20) + q(jx - 26, jx + 26, 165, 200, zz), KID)
      fill(e(jx, 138, zz, 17, 18), KIDH)
      HEADS[#HEADS+1] = {"c", jx, zz}
    elseif t == "r" then
      fill(e(jx, 126, zz, 22, 24) + poly({pr(jx - 24, 130, zz), pr(jx + 24, 130, zz), pr(jx + 20, 200, zz), pr(jx - 20, 200, zz)}), HAIR)
      RATIO = {jx, zz}
    end
  end
  fill(q(-480, -150, 170, 236, z) + q(150, 480, 170, 236, z), PEW, "round 2")
  fill(q(-480, -150, 236, YF, z*1.02) + q(150, 480, 236, YF, z*1.02) - (q(-470, -440, 236, YF, z) + q(-190, -160, 236, YF, z) + q(160, 190, 236, YF, z) + q(440, 470, 236, YF, z)), UND, "round 2")
  local r = brush{kind="rigger", width=clamp(2.4/z, 0.6, 2.2), point=1}
  r:load(RL, 0.9) r:stroke({pr(-480, 172, z), pr(-150, 172, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
  r:load(RL, 0.9) r:stroke({pr(150, 172, z), pr(480, 172, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
end

--@ chunk 8
print(wait(12*24*60), drying(300,400), drying(220,360))
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
local ROBE = pile{{"bone brown",1.2},{"raw sienna",0.4},{"bone black",1.1}}
local EGG = pile{{"bone brown",1},{"raw sienna",0.7},{"bone black",0.7}}
local RUFF = pile{{"lead white",0.9},{"yellow ochre",0.35},{"raw sienna",0.15},{"bone black",0.35}}
local KID = pile{{"ultramarine ash",0.6},{"bone black",1},{"lead white",0.22},{"raw sienna",0.1}}
local KIDH = pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.9}}
local HAIR = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local function e(X, Y, z, rx, ry) local c = pr(X, Y, z) return ellipse(c[1], c[2], rx/z, ry/z) end
local function q(X0, X1, Y0, Y1, z) return poly({pr(X0, Y0, z), pr(X1, Y0, z), pr(X1, Y1, z), pr(X0, Y1, z)}) end
-- restate the near figures opaque on dry paint, clipped above their pew backs
for _, h in ipairs(HEADS) do
  local t, jx, zz = h[1], h[2], h[3]
  local above = poly({pr(-600, -400, zz), pr(600, -400, zz), pr(600, 170, zz - 0.06), pr(-600, 170, zz - 0.06)})
  if t == "d" then
    fill((e(jx, 160, zz, 42, 34) + q(jx - 40, jx + 40, 150, 200, zz)) * above, ROBE)
    fill(e(jx, 88, zz, 21, 30), EGG)
    fill(e(jx, 120, zz, 30, 9), RUFF)
  else
    fill((e(jx, 168, zz, 28, 20) + q(jx - 26, jx + 26, 165, 200, zz)) * above, KID)
    fill(e(jx, 138, zz, 17, 18), KIDH)
  end
end
if RATIO then
  local jx, zz = RATIO[1], RATIO[2]
  local above = poly({pr(-600, -400, zz), pr(600, -400, zz), pr(600, 170, zz - 0.06), pr(-600, 170, zz - 0.06)})
  fill((e(jx, 126, zz, 22, 24) + poly({pr(jx - 24, 130, zz), pr(jx + 24, 130, zz), pr(jx + 20, 200, zz), pr(jx - 20, 200, zz)})) * above, HAIR)
end
-- the Commando, kneeling in the aisle before the altar, back to us
local z = 5.0
local PL = pile{{"bone black",2},{"ultramarine blue",0.3},{"lead white",0.1}}
local body = q(-34, 34, 210, 290, z) + e(0, 190, z, 46, 22) + q(-30, 30, 290, 330, z) + e(0, 165, z, 16, 18) + q(-48, 48, 300, 330, z*1.02)
CMD = body
fill(body, PL, "round 1")
local CR = pile{{"Mars red",0.7},{"rose madder",0.5},{"bone black",0.6}}
fill(q(-28, 28, 215, 300, z*0.995), CR, "round 1")

--@ chunk 9
print(wait(8*24*60))
local function e(X, Y, z, rx, ry) local c = pr(X, Y, z) return ellipse(c[1], c[2], rx/z, ry/z) end
-- candles on the altar and on stands at the pew ends, each a small warm point with a few radial strokes
local CB = pile{{"lead white",1.6},{"yellow ochre",0.2},{"bone black",0.1}}
local GL = pile{{"Mars orange",0.4},{"cadmium yellow",0.4},{"lead white",1}}
local FL = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.1}}
local function candle(x, y, h, s)
  local b = brush{kind="filbert", width=1.4*s, stiffness=0.6}
  b:load(CB, 0.9) b:stroke({{x, y}, {x, y - h}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
  local g = brush{kind="filbert", width=1.2*s, stiffness=0.4}
  for k = 0, 11 do local a = k/12*2*math.pi g:load(GL, 0.5) g:stroke({{x + math.cos(a)*1.2*s, y - h - 2*s + math.sin(a)*1.5*s}, {x + math.cos(a)*3.8*s, y - h - 2*s + math.sin(a)*4.2*s}}, {pressure={0.4, 0.05}}) end
  local f = brush{kind="round", width=1.6*s, point=0.9}
  f:load(FL, 0.95) f:stroke({{x, y - h - 0.5}, {x, y - h - 3.5*s}}, {pressure={0.8, 0}})
end
for _, x in ipairs({468, 476, 524, 532}) do candle(x, 275, 8, 0.9) end
for _, z in ipairs({3.3, 2.55, 1.95, 1.5}) do
  for _, sd in ipairs({-1, 1}) do
    local p = pr(sd*140, 175, z)
    local st = brush{kind="rigger", width=clamp(3/z, 0.8, 2.4), point=1}
    st:load(pile{{"bone brown",1},{"bone black",1}}, 0.9) st:stroke({pr(sd*140, YF, z), p}, {pressure={0.6, 0.6}})
    candle(p[1], p[2], 18/z, clamp(1.6/z*1.4, 0.7, 1.6))
  end
end
-- warm rims on the figures' edges facing the window, and the kneeling frame's helm
local AM = pile{{"yellow ochre",0.6},{"Mars orange",0.3},{"lead white",0.8}}
local r = brush{kind="rigger", width=0.7, point=1}
for _, h in ipairs(HEADS) do
  local c = pr(h[2], (h[1] == "d") and 88 or 138, h[3])
  local rr = ((h[1] == "d") and 21 or 17)/h[3]
  local pts = {} for k = 0, 8 do local a = -math.pi*0.85 + k/8*math.pi*0.7 pts[#pts+1] = {c[1] + rr*math.cos(a), c[2] + rr*1.3*math.sin(a)} end
  r:load(AM, 0.9) r:stroke(pts, {pressure={0.15, 0.45, 0.15}})
end
local hc = pr(0, 165, 5.0)
r:load(AM, 0.9) r:stroke({{hc[1] - 3, hc[2] - 3}, {hc[1], hc[2] - 4}, {hc[1] + 3, hc[2] - 3}}, {pressure={0.2, 0.5, 0.2}})

--@ chunk 10
print(wait(6*24*60))
-- Ratio: her little low-poly body seen from behind, head half-turned so a pale facet of cheek shows; a pale collar of her dress
local jx, zz = RATIO[1], RATIO[2]
local function P(X, Y) return pr(jx + X, Y, zz) end
local SK = pile{{"lead white",2.2},{"rose madder",0.12},{"yellow ochre",0.05}}
local DR = pile{{"lead white",1},{"ultramarine blue",0.4},{"bone black",0.5}}
local HF = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.35}}
work(poly({P(-22, 118), P(-12, 108), P(-8, 136), P(-20, 140)}), {hand="detail", tool="round 0.8", pile=SK, coverage=5, fill=true, clip=true, angle=0})
work(poly({P(-16, 150), P(16, 150), P(18, 160), P(-18, 160)}), {hand="detail", tool="round 0.8", pile=DR, coverage=5, fill=true, clip=true, angle=0})
local r = brush{kind="rigger", width=0.7, point=1}
for _, s in ipairs({{P(-6, 104), P(-10, 150)}, {P(6, 104), P(10, 150)}, {P(0, 102), P(2, 150)}}) do r:load(HF, 0.85) r:stroke(s, {pressure={0.4, 0.4}, ramps={0.03, 0.03}}) end
