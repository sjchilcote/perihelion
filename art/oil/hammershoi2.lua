-- easel session "hammershoi2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=7272, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",1},{"ultramarine ash",0.6},{"bone brown",0.4},{"lead white",0.35}}, um=45, apply="brush", texture=0.35}}}
VP = {500, 250}
XW, YF, YC, ZF = 520, 330, -300, 6.5
function pr(X, Y, z) return {VP[1] + X/z, VP[2] + Y/z} end
FLOOR = poly({pr(-XW, YF, 0.5), pr(XW, YF, 0.5), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
CEIL = poly({pr(-XW, YC, 0.4), pr(XW, YC, 0.4), pr(XW, YC, ZF), pr(-XW, YC, ZF)})
LW = poly({pr(-XW, YC, 0.4), pr(-XW, YC, ZF), pr(-XW, YF, ZF), pr(-XW, YF, 0.4)})
RW = poly({pr(XW, YC, 0.4), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(XW, YF, 0.4)})
ENDW = poly({pr(-XW, YC, ZF), pr(XW, YC, ZF), pr(XW, YF, ZF), pr(-XW, YF, ZF)})
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
local F = pile{{"bone black",1},{"ultramarine ash",0.5},{"bone brown",0.5},{"lead white",0.25}}
local W = pile{{"lead white",0.6},{"ultramarine ash",0.5},{"bone black",0.6},{"bone brown",0.3}}
local C = pile{{"bone black",1.4},{"ultramarine ash",0.4},{"bone brown",0.3},{"lead white",0.1}}
local E = pile{{"lead white",1.4},{"ultramarine ash",0.35},{"bone black",0.3},{"yellow ochre",0.05}}
work(FLOOR, {hand="body", pile=F, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
work(CEIL, {hand="body", pile=C, coverage=3, fill=true, clip=CEIL, angle=toVP, length={20, 50}, tool="filbert 9"})
work(LW + RW, {hand="body", pile=W, coverage=3, fill=true, clip=LW + RW, angle=toVP, length={15, 40}, tool="filbert 8"})
work(ENDW, {hand="detail", pile=E, coverage=4, fill=true, clip=ENDW, tool={kind="round", width=2}, length={3, 8}})

--@ chunk 2
print(wait(5*24*60), drying(500,300))
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
-- walls darker toward us, graded by dithered strokes
local P3 = {
 pile{{"bone black",1.2},{"ultramarine ash",0.5},{"bone brown",0.3},{"lead white",0.15}},
 pile{{"bone black",0.9},{"ultramarine ash",0.5},{"bone brown",0.3},{"lead white",0.32}},
 pile{{"lead white",0.6},{"ultramarine ash",0.5},{"bone black",0.6},{"bone brown",0.3}},
}
local cells = {}
for y = 0, 566, 3.2 do for x = 0, 1004, 3.4 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  local d = math.abs(xx - VP[1])
  if d > 140 and (LW + RW):at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (d - 140)/220*3 + randn(0, 0.35)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(3 - math.floor(t), 1, 3)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=3.6, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(P3[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(P3[i], 0.9) end
    local a = toVP(c.x, c.y) + randn(0, 0.04)
    local h = rand(4, 8)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.55}, clip=LW + RW})
  end
end end
print(#cells)

--@ chunk 3
print(wait(6*24*60), drying(500,300), drying(150,250))
-- ribs: grey, a cool edge toward the window
local RB = pile{{"bone black",1.4},{"ultramarine ash",0.4},{"bone brown",0.3},{"lead white",0.1}}
local RL = pile{{"lead white",1},{"ultramarine ash",0.3},{"bone black",0.3}}
local z = 0.7
while z < 6.3 do
  for _, sd in ipairs({-1, 1}) do
    local w = clamp(16/z, 2, 22)
    local b = brush{kind="filbert", width=w, stiffness=0.5}
    b:reload(RB, 0.9) b:stroke({pr(sd*XW, YF, z), pr(sd*XW, YC, z)}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
    local e = brush{kind="rigger", width=clamp(2/z, 0.5, 3), point=1}
    e:load(RL, 0.85) e:stroke({pr(sd*XW, YF, z*1.03), pr(sd*XW, YC, z*1.03)}, {pressure={0.4, 0.4}, ramps={0.03, 0.03}})
  end
  z = z * 1.3
end
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
-- window: grey-white, the Sun only a pale disc
local W = poly({{478, 210}, {522, 210}, {522, 238}, {478, 238}}) + ellipse(500, 210, 22, 10)
fill(W:grow(2.5), pile{{"bone black",1.6},{"ultramarine ash",0.3}})
fill(W, pile{{"lead white",2.2},{"ultramarine ash",0.25},{"bone black",0.08}})
local sb = brush{kind="round", width=3, point=0.3}
sb:load(pile{{"lead white",2},{"zinc white",1}}, 0.95) sb:touch(507, 220, {pressure=0.6})
local mb = brush{kind="rigger", width=1.0, point=1}
mb:load(pile{{"bone black",1.6},{"ultramarine ash",0.3}}, 0.9) mb:stroke({{500, 201}, {500, 238}}, {pressure={0.6, 0.6}})
-- altar, its crimson cloth faded
ALT = poly({{462, 275}, {538, 275}, {540, 300}, {460, 300}})
fill(ALT, pile{{"lead white",1.2},{"ultramarine ash",0.3},{"bone brown",0.15},{"bone black",0.2}})
fill(rect(460, 296, 80, 4), pile{{"bone black",1.6},{"bone brown",0.4}}, "round 1")
fill(poly({{486, 275}, {514, 275}, {514, 300}, {486, 300}}), pile{{"Mars red",0.4},{"rose madder",0.3},{"bone black",0.6},{"lead white",0.3}}, "round 1")

--@ chunk 4
print(wait(6*24*60), drying(300,400))
local function q(X0, X1, Y0, Y1, z) return poly({pr(X0, Y0, z), pr(X1, Y0, z), pr(X1, Y1, z), pr(X0, Y1, z)}) end
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 1.6", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
-- the narrow strip of grey light down the aisle
local strip = poly({pr(-50, YF, 6.3), pr(50, YF, 6.3), pr(80, YF, 1.0), pr(-80, YF, 1.0)})
STRIP = strip
local SL = {
 pile{{"bone black",0.8},{"ultramarine ash",0.6},{"lead white",0.5},{"bone brown",0.2}},
 pile{{"lead white",1},{"ultramarine ash",0.45},{"bone black",0.35}},
}
local cells = {}
for y = 300, 566, 2.6 do for x = 380, 620, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if strip:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local t = (yy - 300)/266
    local v = 2.3 - t*1.2 + randn(0, 0.25)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 2)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
for i = 1, 2 do if g[i] then
  b:reload(SL[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(SL[i], 0.9) end
    local a = math.atan(VP[2] - c.y, VP[1] - c.x)
    local h = rand(4, 8)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.7, 0.6}, clip=strip})
  end
end end
print(#cells)
-- empty pews, back to front so nearer ones overlap
local PEW = pile{{"bone black",1.4},{"bone brown",0.6},{"ultramarine ash",0.3},{"lead white",0.06}}
local UND = pile{{"bone black",2},{"bone brown",0.4}}
local DUST = pile{{"lead white",0.7},{"ultramarine ash",0.35},{"bone brown",0.2},{"bone black",0.5}}
for _, z in ipairs({4.3, 3.3, 2.55, 1.95, 1.5, 1.15}) do
  fill(q(-480, -150, 170, 236, z) + q(150, 480, 170, 236, z), PEW, "round 2")
  fill(q(-480, -150, 236, YF, z*1.02) + q(150, 480, 236, YF, z*1.02) - (q(-470, -440, 236, YF, z) + q(-190, -160, 236, YF, z) + q(160, 190, 236, YF, z) + q(440, 470, 236, YF, z)), UND, "round 2")
  -- the seat in front of each back: a lighter plane where dust lies
  local seat = q(-480, -150, 236, 246, z*1.08) + q(150, 480, 236, 246, z*1.08)
  fill(seat, DUST, "round 1.4")
  local r = brush{kind="rigger", width=clamp(2.2/z, 0.6, 2), point=1}
  r:load(DUST, 0.9) r:stroke({pr(-480, 171, z), pr(-150, 171, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
  r:load(DUST, 0.9) r:stroke({pr(150, 171, z), pr(480, 171, z)}, {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
end

--@ chunk 5
print(wait(8*24*60), drying(300,400), drying(500,330))
local function q(X0, X1, Y0, Y1, z) return poly({pr(X0, Y0, z), pr(X1, Y0, z), pr(X1, Y1, z), pr(X0, Y1, z)}) end
local function e(X, Y, z, rx, ry) local c = pr(X, Y, z) return ellipse(c[1], c[2], rx/z, ry/z) end
local function fill(m, p, t) if m then work(m, {hand="detail", tool=t or "round 0.9", pile=p, coverage=5, fill=true, clip=m, angle=0}) end end
-- the kneeling frame in the grey strip, back to us, crimson rag on its back
local z = 4.6
local PL = pile{{"bone black",2},{"ultramarine blue",0.3},{"lead white",0.1}}
local body = q(-34, 34, 210, 290, z) + e(0, 190, z, 46, 22) + q(-30, 30, 290, 330, z) + e(0, 166, z, 16, 18) + q(-50, 50, 302, 330, z*1.02)
fill(poly({pr(-60, 330, z*1.02), pr(60, 330, z*1.02), pr(70, 330, z*0.9), pr(-70, 330, z*0.9)}), pile{{"bone black",1.4},{"ultramarine ash",0.4}})
fill(body, PL)
fill(q(-28, 28, 214, 300, z*0.995), pile{{"Mars red",0.5},{"rose madder",0.4},{"bone black",0.7},{"lead white",0.12}})
local CO = pile{{"lead white",1.2},{"ultramarine ash",0.35},{"bone black",0.2}}
local r = brush{kind="rigger", width=0.6, point=1}
local hc = pr(0, 166, z)
r:load(CO, 0.9) r:stroke({{hc[1] - 3, hc[2] - 3}, {hc[1], hc[2] - 4}, {hc[1] + 3, hc[2] - 3}}, {pressure={0.2, 0.45, 0.2}})
local s1, s2 = pr(-46, 180, z), pr(46, 180, z)
r:load(CO, 0.9) r:stroke({s1, {s1[1] + 3, s1[2] - 1.5}}, {pressure={0.4, 0.3}})
r:load(CO, 0.9) r:stroke({s2, {s2[1] - 3, s2[2] - 1.5}}, {pressure={0.4, 0.3}})
-- cold candles: the stands at the pew ends with dead white stubs
local CB = pile{{"lead white",1.2},{"ultramarine ash",0.3},{"bone black",0.25}}
for _, zz in ipairs({3.3, 2.55, 1.95, 1.5}) do
  for _, sd in ipairs({-1, 1}) do
    local p = pr(sd*140, 175, zz)
    local st = brush{kind="rigger", width=clamp(3/zz, 0.8, 2.4), point=1}
    st:load(pile{{"bone black",1.6},{"bone brown",0.4}}, 0.9) st:stroke({pr(sd*140, YF, zz), p}, {pressure={0.6, 0.6}})
    local b = brush{kind="filbert", width=clamp(2.2/zz, 0.8, 1.8), stiffness=0.6}
    b:load(CB, 0.9) b:stroke({p, {p[1], p[2] - 14/zz}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
  end
end
-- three dead candles on the altar, and the one still lit
for _, x in ipairs({468, 476, 532}) do local b = brush{kind="filbert", width=1.3, stiffness=0.6} b:load(CB, 0.9) b:stroke({{x, 275}, {x, 268}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}}) end
local b = brush{kind="filbert", width=1.3, stiffness=0.6}
b:load(pile{{"lead white",1.6},{"yellow ochre",0.2},{"bone black",0.1}}, 0.9) b:stroke({{524, 275}, {524, 267}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}})
local GL = pile{{"Mars orange",0.4},{"cadmium yellow",0.4},{"lead white",1}}
local g = brush{kind="filbert", width=1.1, stiffness=0.4}
for k = 0, 11 do local a = k/12*2*math.pi g:load(GL, 0.5) g:stroke({{524 + math.cos(a)*1.2, 264 + math.sin(a)*1.4}, {524 + math.cos(a)*3.6, 264 + math.sin(a)*4}}, {pressure={0.4, 0.05}}) end
local f = brush{kind="round", width=1.5, point=0.9}
f:load(pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.1}}, 0.95) f:stroke({{524, 266.5}, {524, 263}}, {pressure={0.8, 0}})
