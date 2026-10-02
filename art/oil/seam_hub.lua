-- easel session "seam_hub": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=8080, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",1.6},{"bone brown",1},{"raw sienna",0.3},{"lead white",0.1}}, um=45, apply="brush", texture=0.35}}}
-- the octagonal hub seen from the seventh doorway: five faces visible, ceiling and floor
F = {
 L  = {{20, 40}, {230, 115}, {230, 420}, {20, 530}},
 BL = {{230, 115}, {385, 150}, {385, 382}, {230, 420}},
 B  = {{385, 150}, {615, 150}, {615, 382}, {385, 382}},
 BR = {{615, 150}, {770, 115}, {770, 420}, {615, 382}},
 R  = {{770, 115}, {980, 40}, {980, 530}, {770, 420}},
}
CEILM = poly({{-40, -40}, {1040, -40}, {980, 40}, {770, 115}, {615, 150}, {385, 150}, {230, 115}, {20, 40}})
FLOORM = poly({{20, 530}, {230, 420}, {385, 382}, {615, 382}, {770, 420}, {980, 530}, {1040, 600}, {-40, 600}})
local WB = pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.8},{"lead white",0.15}}
local WB2 = pile{{"bone brown",1},{"raw sienna",0.4},{"bone black",1.1},{"lead white",0.08}}
local CB = pile{{"bone black",1.8},{"bone brown",0.6},{"ultramarine blue",0.2}}
local FB = pile{{"bone brown",1},{"bone black",0.9},{"raw sienna",0.4},{"lead white",0.12}}
work(CEILM, {hand="body", pile=CB, coverage=3.5, fill=true, clip=CEILM, angle=0, length={20, 50}, tool="filbert 9"})
work(FLOORM, {hand="body", pile=FB, coverage=3.5, fill=true, clip=FLOORM, angle=0, length={20, 50}, tool="filbert 9"})
for k, f in pairs(F) do
  local m = poly(f)
  work(m, {hand="body", pile=(k == "B" or k == "BL" or k == "BR") and WB or WB2, coverage=3.5, fill=true, clip=m, angle=1.57, length={15, 40}, tool="filbert 7"})
end

--@ chunk 2
print(wait(5*24*60))
function fp(f, u, v)
  local tl, tr, br, bl = f[1], f[2], f[3], f[4]
  local top = {tl[1] + (tr[1]-tl[1])*u, tl[2] + (tr[2]-tl[2])*u}
  local bot = {bl[1] + (br[1]-bl[1])*u, bl[2] + (br[2]-bl[2])*u}
  return {top[1] + (bot[1]-top[1])*v, top[2] + (bot[2]-top[2])*v}
end
function archpts(f, u0, u1, vs, vt)
  local p = {fp(f, u0, 1.0)}
  p[#p+1] = fp(f, u0, vs)
  for k = 1, 11 do local t = k/12 local u = u0 + (u1-u0)*t p[#p+1] = fp(f, u, vs - (vs - vt)*math.sin(t*math.pi)) end
  p[#p+1] = fp(f, u1, vs)
  p[#p+1] = fp(f, u1, 1.0)
  return p
end
ARCH = {
 {f="L", u0=0.42, u1=0.8, vs=0.36, vt=0.2},
 {f="L", u0=0.06, u1=0.24, vs=0.42, vt=0.32},
 {f="BL", u0=0.2, u1=0.8, vs=0.34, vt=0.18},
 {f="B", u0=0.28, u1=0.72, vs=0.3, vt=0.12},
 {f="BR", u0=0.2, u1=0.8, vs=0.34, vt=0.18},
 {f="R", u0=0.2, u1=0.58, vs=0.36, vt=0.2},
}
for i, a in ipairs(ARCH) do a.pts = archpts(F[a.f], a.u0, a.u1, a.vs, a.vt) a.m = poly(a.pts) end
-- each arch: a dark recess first, then its own corridor
local DK = pile{{"bone black",2.2},{"bone brown",0.4}}
local all = nil for _, a in ipairs(ARCH) do all = all and (all + a.m) or a.m end
ARCHM = all
work(all, {hand="detail", tool="round 1.6", pile=DK, coverage=5, fill=true, clip=all, angle=0})

--@ chunk 3
print(wait(5*24*60))
-- corridor inside an arch: bounding corners of the arch opening, an end-rectangle placed, rotated and scaled
local function fill(m, p) work(m, {hand="detail", tool="round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
function corridor(a, ex, ey, es, rot, P)
  local xs, ys = {}, {}
  for _, p in ipairs(a.pts) do xs[#xs+1] = p[1] ys[#ys+1] = p[2] end
  local x0, x1, y0, y1 = math.min(table.unpack(xs)), math.max(table.unpack(xs)), math.min(table.unpack(ys)), math.max(table.unpack(ys))
  local cx, cy = (x0 + x1)/2 + ex, (y0 + y1)/2 + ey
  local hw, hh = (x1 - x0)/2*es, (y1 - y0)/2*es
  local c, s = math.cos(rot), math.sin(rot)
  local function R(dx, dy) return {cx + c*dx - s*dy, cy + s*dx + c*dy} end
  local e = {R(-hw, -hh), R(hw, -hh), R(hw, hh), R(-hw, hh)}
  local o = {{x0 - 40, y0 - 40}, {x1 + 40, y0 - 40}, {x1 + 40, y1 + 40}, {x0 - 40, y1 + 40}}
  local planes = {
   {poly({o[1], o[2], e[2], e[1]}), P.ceil}, {poly({o[4], o[3], e[3], e[4]}), P.floor},
   {poly({o[1], o[4], e[4], e[1]}), P.left}, {poly({o[2], o[3], e[3], e[2]}), P.right},
   {poly(e), P.far},
  }
  for _, pl in ipairs(planes) do fill(pl[1] * a.m:shrink(0.5), pl[2]) end
  a.e = e a.o = o
  return e
end
local function pp(t) return pile(t) end
-- 1: cold blue, tilted steeply upward
corridor(ARCH[1], 10, -60, 0.18, 0.25, {ceil=pp{{"ultramarine blue",0.8},{"bone black",1},{"lead white",0.2}}, floor=pp{{"cerulean blue",0.7},{"lead white",0.7},{"ultramarine blue",0.3}}, left=pp{{"ultramarine blue",0.8},{"lead white",0.5},{"bone black",0.5}}, right=pp{{"cerulean blue",0.6},{"lead white",0.9},{"ultramarine blue",0.2}}, far=pp{{"lead white",2},{"cerulean blue",0.4}}})
-- 2 (small, far left): dark teal, upside down
corridor(ARCH[2], 0, 6, 0.25, math.pi, {ceil=pp{{"viridian",0.6},{"bone black",1},{"lead white",0.3}}, floor=pp{{"viridian",0.5},{"bone black",1.5}}, left=pp{{"viridian",0.6},{"bone black",0.8},{"lead white",0.4}}, right=pp{{"viridian",0.4},{"bone black",1.2},{"lead white",0.2}}, far=pp{{"viridian",0.6},{"lead white",1.4}}})
-- 3: green-gold, rotated
corridor(ARCH[3], 6, 4, 0.22, 0.6, {ceil=pp{{"bone black",1},{"emerald green",0.3},{"yellow ochre",0.3}}, floor=pp{{"yellow ochre",0.8},{"emerald green",0.3},{"lead white",0.6}}, left=pp{{"emerald green",0.4},{"yellow ochre",0.5},{"bone black",0.4},{"lead white",0.3}}, right=pp{{"yellow ochre",0.6},{"lead white",0.8},{"emerald green",0.2}}, far=pp{{"lead white",2},{"lemon chrome",0.3}}})
-- 5: rust-red, the floor become a wall (turned a quarter)
corridor(ARCH[5], -4, 6, 0.24, -math.pi/2, {ceil=pp{{"Mars red",0.6},{"bone black",1}}, floor=pp{{"Mars orange",0.8},{"red earth",0.5},{"lead white",0.4}}, left=pp{{"red earth",0.8},{"bone black",0.6},{"lead white",0.2}}, right=pp{{"Mars red",0.5},{"bone black",1.1}}, far=pp{{"Mars orange",0.6},{"lead white",1.4},{"cadmium yellow",0.2}}})
-- 6: pale violet-white, slipped sideways and twisted
corridor(ARCH[6], 30, 20, 0.2, -0.3, {ceil=pp{{"cobalt violet",0.4},{"bone black",0.8},{"lead white",0.6}}, floor=pp{{"cobalt violet",0.5},{"lead white",1.2}}, left=pp{{"cobalt violet",0.6},{"lead white",0.6},{"bone black",0.3}}, right=pp{{"lead white",1.6},{"cobalt violet",0.3}}, far=pp{{"lead white",2.2},{"cobalt violet",0.1}}})

--@ chunk 4
print(wait(5*24*60))
-- 4 (straight ahead): the hub itself again, small, seen through the arch, with a figure in its doorway
local a = ARCH[4]
local xs, ys = {}, {}
for _, p in ipairs(a.pts) do xs[#xs+1] = p[1] ys[#ys+1] = p[2] end
local x0, x1, y0, y1 = math.min(table.unpack(xs)), math.max(table.unpack(xs)), math.min(table.unpack(ys)), math.max(table.unpack(ys))
local cx, cy = (x0 + x1)/2, (y0 + y1)/2 + 10
local s = 0.2
local function S(p) return {cx + (p[1] - 500)*s, cy + (p[2] - 290)*s} end
local function SP(t) local o = {} for _, p in ipairs(t) do o[#o+1] = S(p) end return poly(o) end
local function fill(m, p) work(m, {hand="detail", tool="round 0.8", pile=p, coverage=5, fill=true, clip=m * a.m:shrink(0.5), angle=0}) end
-- the corridor leading to it: plain bronze
local e = {S({-40, -40}), S({1040, -40}), S({1040, 600}), S({-40, 600})}
local o = {{x0 - 40, y0 - 40}, {x1 + 40, y0 - 40}, {x1 + 40, y1 + 40}, {x0 - 40, y1 + 40}}
fill(poly({o[1], o[2], e[2], e[1]}), pile{{"bone black",1.6},{"bone brown",0.6}})
fill(poly({o[4], o[3], e[3], e[4]}), pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.6},{"lead white",0.15}})
fill(poly({o[1], o[4], e[4], e[1]}), pile{{"bone brown",1},{"bone black",0.9},{"lead white",0.08}})
fill(poly({o[2], o[3], e[3], e[2]}), pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.7},{"lead white",0.12}})
-- the small hub: ceiling, floor, walls, the same five faces
fill(SP({{-40, -40}, {1040, -40}, {1040, 600}, {-40, 600}}), pile{{"bone black",1.6},{"bone brown",0.6}})
for k, f in pairs(F) do fill(SP(f), (k == "B" or k == "BL" or k == "BR") and pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.8},{"lead white",0.15}} or pile{{"bone brown",1},{"raw sienna",0.4},{"bone black",1.1},{"lead white",0.08}}) end
fill(SP({{20, 530}, {230, 420}, {385, 382}, {615, 382}, {770, 420}, {980, 530}, {1040, 600}, {-40, 600}}), pile{{"bone brown",1},{"bone black",0.9},{"raw sienna",0.4},{"lead white",0.12}})
for _, b in ipairs(ARCH) do local o2 = {} for _, p in ipairs(b.pts) do o2[#o2+1] = S(p) end fill(poly(o2), pile{{"bone black",2},{"bone brown",0.4}}) end
SMALL = {S = S, cx = cx, cy = cy, s = s}

--@ chunk 5
print(wait(6*24*60))
-- ribs inside each corridor: frames interpolated from the arch opening to the far end, so each reads as a passage
local DK = pile{{"bone black",1.8},{"bone brown",0.5}}
for i, a in ipairs(ARCH) do
  if a.e then
    for k = 1, 5 do
      local t = 1 - (1 - k/6)^2
      local q = {}
      for j = 1, 4 do q[j] = {a.o[j][1] + (a.e[j][1] - a.o[j][1])*t, a.o[j][2] + (a.e[j][2] - a.o[j][2])*t} end
      local w = clamp(3.2*(1 - t), 0.6, 3)
      local b = brush{kind="rigger", width=w, point=1}
      for j = 1, 4 do b:load(DK, 0.9) b:stroke({q[j], q[(j % 4) + 1]}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}, clip=a.m:shrink(0.5)}) end
    end
    local b = brush{kind="rigger", width=0.8, point=1}
    for j = 1, 4 do b:load(DK, 0.85) b:stroke({a.o[j], a.e[j]}, {pressure={0.5, 0.3}, clip=a.m:shrink(0.5)}) end
  end
end
-- inside the far hub: its tiny amber lamp, and a tiny figure standing in its near doorway
local S = SMALL.S
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.5}}
local l = brush{kind="round", width=2.2, point=0.3}
local lp = S({500, 215})
local ch = brush{kind="rigger", width=0.4, point=1}
ch:load(DK, 0.9) ch:stroke({S({500, 120}), lp}, {pressure={0.5, 0.5}})
l:load(AM, 0.95) l:touch(lp[1], lp[2], {pressure=0.6})
local fg = S({480, 560})
local FC = pile{{"bone black",2.4},{"ultramarine blue",0.3}}
local f = brush{kind="round", width=2.6, point=0.3}
f:load(FC, 0.95) f:stroke({{fg[1], fg[2] - 1}, {fg[1], fg[2] - 14}}, {pressure={0.8, 0.8}})
f:load(FC, 0.95) f:touch(fg[1], fg[2] - 16, {pressure=0.7})

--@ chunk 6
print(wait(6*24*60))
-- the violet seam-line around each arch: a hard cold line, slightly off the arch, broken in places
local SV = pile{{"cobalt violet",1},{"lead white",0.9},{"magenta",0.15}}
local SVd = pile{{"cobalt violet",0.8},{"ultramarine blue",0.3},{"lead white",0.3}}
for i, a in ipairs(ARCH) do
  local pts = {}
  local cx, cy = 0, 0
  for _, p in ipairs(a.pts) do cx = cx + p[1]/#a.pts cy = cy + p[2]/#a.pts end
  for _, p in ipairs(a.pts) do local dx, dy = p[1] - cx, p[2] - cy local d = math.sqrt(dx*dx + dy*dy) + 1e-6 pts[#pts+1] = {p[1] + dx/d*3.5, p[2] + dy/d*3.5} end
  for j = 1, #pts - 1 do
    local b = brush{kind="rigger", width=1.4, point=1}
    b:load((j % 3 == 0) and SVd or SV, 0.9) b:stroke({pts[j], pts[j + 1]}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}})
  end
end
-- floor: an octagonal plate pattern, radial joints toward the hub's centre
local C = {500, 455}
local FJ = pile{{"bone black",1.8},{"bone brown",0.6}}
local FL = pile{{"raw sienna",0.6},{"bone brown",0.6},{"lead white",0.35},{"bone black",0.3}}
for _, p in ipairs({{230, 420}, {385, 382}, {615, 382}, {770, 420}, {20, 530}, {980, 530}}) do
  local b = brush{kind="rigger", width=1.2, point=1}
  b:load(FJ, 0.9) b:stroke({p, {C[1] + (C[1] - p[1])*1.6, C[2] + (C[2] - p[2])*1.6}}, {pressure={0.45, 0.8}, clip=FLOORM})
end
for _, r in ipairs({0.35, 0.65}) do
  local pts = {}
  for _, p in ipairs({{20, 530}, {230, 420}, {385, 382}, {615, 382}, {770, 420}, {980, 530}}) do pts[#pts+1] = {C[1] + (p[1] - C[1])*r, C[2] + (p[2] - C[2])*r*0.9} end
  local b = brush{kind="rigger", width=1.0, point=1}
  b:load(FJ, 0.9) b:stroke(pts, {pressure={0.5, 0.5}, clip=FLOORM})
end
-- the lamp hanging in the centre: chain and housing
local ch = brush{kind="rigger", width=1.4, point=1}
ch:load(FJ, 0.9) ch:stroke({{500, -10}, {500, 196}}, {pressure={0.6, 0.6}})
local H = pile{{"bone black",1.6},{"bone brown",0.8}}
work(poly({{486, 196}, {514, 196}, {520, 210}, {480, 210}}), {hand="detail", tool="round 1", pile=H, coverage=5, fill=true, clip=true, angle=0})

--@ chunk 7
print(wait(6*24*60))
-- the amber lamp lit: core, short radial strokes blended along the radius, and its pool on the floor beneath
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.7},{"lead white",0.5}}
local AH = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.15}}
local G1 = pile{{"Mars orange",0.6},{"raw sienna",0.5},{"lead white",0.4},{"bone black",0.2}}
local s = brush{kind="filbert", width=2.6, stiffness=0.4}
for k = 0, 35 do local a = k/36*2*math.pi s:load(G1, 0.55) s:stroke({{500 + math.cos(a)*10, 220 + math.sin(a)*8}, {500 + math.cos(a)*rand(26, 40), 220 + math.sin(a)*rand(20, 32)}}, {pressure={0.45, 0.05}, clip=-ARCHM}) end
blend(ellipse(500, 220, 44, 36) - ARCHM, {angle=function(x,y) return math.atan(y - 220, x - 500) end, tool={kind="badger", width=5}, length={8, 18}})
local c = brush{kind="filbert", width=6, stiffness=0.5}
c:load(AM, 0.95) c:stroke({{490, 216}, {510, 216}}, {pressure={0.85, 0.85}})
local k = brush{kind="round", width=3, point=0.3}
k:load(AH, 0.95) k:touch(500, 216, {pressure=0.7})
-- pool on the floor under it
local PL = {pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.5},{"lead white",0.25}}, pile{{"raw sienna",0.8},{"yellow ochre",0.4},{"Mars orange",0.15},{"lead white",0.45},{"bone black",0.2}}}
local cells = {}
for y = 400, 540, 2.6 do for x = 330, 670, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  local d = math.sqrt(((xx - 500)/160)^2 + ((yy - 455)/50)^2)
  if FLOORM:at(xx, yy) > 0.5 then local v = 2.3 - d*1.6 + randn(0, 0.3) if v > 0.8 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 2)} end end
end end
local g = {}
for _, cc in ipairs(cells) do g[cc.i] = g[cc.i] or {} table.insert(g[cc.i], cc) end
local b = brush{kind="filbert", width=2.8, stiffness=0.5}
for i = 1, 2 do if g[i] then b:reload(PL[i], 0.9) for n, cc in ipairs(g[i]) do if n % 4 == 0 then b:load(PL[i], 0.9) end b:stroke({{cc.x - 4, cc.y}, {cc.x + 4, cc.y}}, {pressure={0.65, 0.5}, clip=FLOORM}) end end end
print(#cells)

--@ chunk 8
blend(ellipse(500, 455, 220, 75) * FLOORM, {angle=0, tool={kind="badger", width=10}, length={20, 40}})

--@ chunk 9
print(wait(8*24*60))
-- the lamp lower and larger, hanging in front of the far arch; its glow laid over everything behind it
local FJ = pile{{"bone black",1.8},{"bone brown",0.6}}
local ch = brush{kind="rigger", width=1.4, point=1}
ch:load(FJ, 0.9) ch:stroke({{500, 196}, {500, 262}}, {pressure={0.6, 0.6}})
local G1 = pile{{"Mars orange",0.6},{"raw sienna",0.4},{"lead white",0.55},{"bone black",0.15}}
local s = brush{kind="filbert", width=2.4, stiffness=0.4}
for k = 0, 39 do local a = k/40*2*math.pi s:load(G1, 0.5) s:stroke({{500 + math.cos(a)*9, 276 + math.sin(a)*8}, {500 + math.cos(a)*rand(22, 34), 276 + math.sin(a)*rand(18, 28)}}, {pressure={0.4, 0.05}}) end
local H = pile{{"bone black",1.6},{"bone brown",0.8}}
work(poly({{484, 262}, {516, 262}, {522, 272}, {478, 272}}), {hand="detail", tool="round 1", pile=H, coverage=5, fill=true, clip=true, angle=0})
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.7},{"lead white",0.5}}
local AH = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.15}}
local c = brush{kind="filbert", width=8, stiffness=0.5}
c:load(AM, 0.95) c:stroke({{488, 280}, {512, 280}}, {pressure={0.9, 0.9}})
local k2 = brush{kind="round", width=3.6, point=0.3}
k2:load(AH, 0.95) k2:touch(500, 279, {pressure=0.75})
-- the near doorway we stand in: a heavy dark frame around the view
local FR = pile{{"bone black",2.2},{"bone brown",0.6}}
local frame = (rect(-10, -10, 1020, 30) + rect(-10, -10, 34, 600) + rect(976, -10, 40, 600)) 
work(frame, {hand="detail", tool="round 2", pile=FR, coverage=5, fill=true, clip=frame, angle=0})
local R = pile{{"raw sienna",0.6},{"bone brown",0.6},{"lead white",0.35},{"bone black",0.3}}
local r = brush{kind="rigger", width=1.4, point=1}
r:load(R, 0.9) r:stroke({{24, 20}, {24, 600}}, {pressure={0.5, 0.5}}) r:load(R, 0.9) r:stroke({{976, 20}, {976, 600}}, {pressure={0.5, 0.5}}) r:load(R, 0.9) r:stroke({{24, 20}, {976, 20}}, {pressure={0.4, 0.4}})
-- the Commando, small, standing just inside the threshold, back to us, deciding
FB2 = {470, 548}
local S = 0.42
function P(u, v) return {FB2[1] + u*S, FB2[2] - v*S} end
function pp(t) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, true) end
local FP = {
 {{-28, 0}, {-6, 0}, {-6, 10}, {-24, 11}}, {{8, 0}, {30, 0}, {30, 10}, {10, 11}},
 {{-25, 10}, {-8, 10}, {-7, 72}, {-24, 74}}, {{10, 10}, {27, 10}, {28, 74}, {11, 74}},
 {{-28, 70}, {-4, 70}, {-2, 132}, {-30, 132}}, {{4, 70}, {30, 70}, {32, 132}, {2, 132}},
 {{-36, 124}, {36, 124}, {32, 152}, {-32, 152}}, {{-34, 148}, {34, 148}, {40, 212}, {-40, 210}},
 {{-16, 210}, {16, 210}, {14, 228}, {-14, 228}}, {{-17, 224}, {17, 224}, {20, 250}, {10, 264}, {-10, 265}, {-20, 250}},
 {{-58, 186}, {-34, 182}, {-24, 210}, {-36, 222}, {-58, 214}}, {{34, 182}, {58, 186}, {58, 214}, {36, 222}, {24, 210}},
 {{-58, 150}, {-42, 150}, {-40, 188}, {-56, 190}}, {{42, 150}, {58, 150}, {56, 190}, {40, 188}},
 {{-60, 100}, {-44, 100}, {-42, 152}, {-58, 152}}, {{44, 100}, {60, 100}, {58, 152}, {42, 152}},
}
local m = nil for _, q in ipairs(FP) do local x = pp(q) m = m and (m + x) or x end
FIG = m
work(poly({P(-40, 2), P(40, 2), P(60, -14), P(-60, -14)}), {hand="detail", tool="round 1.2", pile=pile{{"bone black",2},{"bone brown",0.5}}, coverage=5, fill=true, clip=true, angle=0})
work(FIG, {hand="detail", tool="round 1.2", pile=pile{{"bone black",2.4},{"ultramarine blue",0.35},{"lead white",0.06}}, coverage=5, fill=true, clip=FIG, angle=0})

--@ chunk 10
print(wait(8*24*60), drying(470,500))
-- the figure's plates and rims: amber from the lamp above, a touch of each corridor's colour on its sides
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local AM = pile{{"Mars orange",0.5},{"yellow ochre",0.4},{"lead white",0.7}}
local BL = pile{{"cerulean blue",0.6},{"lead white",0.9}}
local RD = pile{{"Mars orange",0.6},{"red earth",0.3},{"lead white",0.6}}
local function ln(p, uv, pr_, w) local r = brush{kind="rigger", width=w or 0.7, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG:grow(0.4)}) end
for _, s2 in ipairs({{{-31, 132}, {32, 132}}, {{-34, 152}, {33, 152}}, {{-16, 211}, {16, 211}}, {{-25, 72}, {-6, 72}}, {{10, 72}, {28, 72}}, {{0, 150}, {0, 208}}}) do ln(JD, s2, 0.5, 0.8) end
ln(AM, {{-17, 224}, {17, 224}, {20, 250}}, 0.55, 0.8) ln(AM, {{-34, 182}, {-58, 186}}, 0.45, 0.7) ln(AM, {{34, 182}, {58, 186}}, 0.45, 0.7)
ln(BL, {{-58, 150}, {-60, 100}}, 0.4, 0.6) ln(BL, {{-40, 210}, {-34, 148}}, 0.35, 0.6)
ln(RD, {{58, 150}, {60, 100}}, 0.4, 0.6) ln(RD, {{40, 212}, {34, 148}}, 0.35, 0.6)
-- the violet seams restated stronger
local SV = pile{{"cobalt violet",1},{"lead white",0.8},{"magenta",0.2}}
for i, a in ipairs(ARCH) do
  local cx, cy = 0, 0
  for _, p in ipairs(a.pts) do cx = cx + p[1]/#a.pts cy = cy + p[2]/#a.pts end
  local pts = {}
  for _, p in ipairs(a.pts) do local dx, dy = p[1] - cx, p[2] - cy local d = math.sqrt(dx*dx + dy*dy) + 1e-6 pts[#pts+1] = {p[1] + dx/d*4.5, p[2] + dy/d*4.5} end
  for j = 1, #pts - 1 do local b = brush{kind="rigger", width=2.0, point=1} b:load(SV, 0.9) b:stroke({pts[j], pts[j + 1]}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}}) end
end

--@ chunk 11
blend(ellipse(500, 276, 40, 34) - poly({{484, 262}, {516, 262}, {522, 272}, {478, 272}}) - ellipse(500, 280, 13, 5), {angle=function(x,y) return math.atan(y - 276, x - 500) end, tool={kind="badger", width=4}, length={8, 16}}) local m = rect(578, 248, 30, 16) work(m, {hand="detail", tool="round 1", pile=pile{{"bone black",1.6},{"bone brown",0.6}}, coverage=5, fill=true, clip=m, angle=0})

--@ chunk 12
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
fill(rect(486, 209, 28, 14), pile{{"bone black",1.6},{"bone brown",0.6}}, "round 1")
local A = ARCHM
local Z = {
 {36, pile{{"bone black",1},{"bone brown",0.8},{"raw sienna",0.5},{"Mars orange",0.1},{"lead white",0.15}}},
 {26, pile{{"raw sienna",0.8},{"Mars orange",0.3},{"bone black",0.4},{"lead white",0.35}}},
 {16, pile{{"Mars orange",0.5},{"yellow ochre",0.5},{"lead white",0.7},{"bone black",0.1}}},
}
local back = pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.8},{"lead white",0.15}}
fill((ellipse(500, 278, 46, 40) - ellipse(500, 278, 36, 31)) - A, back)
fill((ellipse(500, 278, 46, 40) - ellipse(500, 278, 36, 31)) * A, pile{{"bone black",1.4},{"bone brown",0.6},{"lead white",0.05}})
for i, z in ipairs(Z) do
  local r = z[1]
  local nxt = Z[i + 1] and Z[i + 1][1] or 0
  fill(ellipse(500, 278, r, r*0.86) - ellipse(500, 278, nxt, nxt*0.86), z[2])
end
blend(ellipse(500, 278, 44, 38), {angle=function(x,y) return math.atan(y - 278, x - 500) end, tool={kind="badger", width=6}, length={8, 18}})

--@ chunk 13
print(wait(8*24*60))
local FJ = pile{{"bone black",1.8},{"bone brown",0.6}}
local ch = brush{kind="rigger", width=1.4, point=1}
ch:load(FJ, 0.9) ch:stroke({{500, 196}, {500, 264}}, {pressure={0.6, 0.6}})
work(poly({{486, 264}, {514, 264}, {520, 273}, {480, 273}}), {hand="detail", tool="round 1", pile=pile{{"bone black",1.6},{"bone brown",0.8}}, coverage=5, fill=true, clip=true, angle=0})
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.7},{"lead white",0.5}}
local AH = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.15}}
local c = brush{kind="filbert", width=8, stiffness=0.5}
c:load(AM, 0.95) c:stroke({{489, 281}, {511, 281}}, {pressure={0.9, 0.9}})
local k2 = brush{kind="round", width=3.6, point=0.3}
k2:load(AH, 0.95) k2:touch(500, 280, {pressure=0.75})

--@ chunk 14
local m = rect(576, 246, 34, 20) - ARCHM work(m, {hand="detail", tool="round 1.4", pile=pile{{"bone brown",1},{"raw sienna",0.6},{"bone black",0.8},{"lead white",0.15}}, coverage=5, fill=true, clip=m, angle=1.57})
