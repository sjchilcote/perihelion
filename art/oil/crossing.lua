-- easel session "crossing": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=6661, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"bone brown",1},{"raw sienna",0.2},{"ultramarine blue",0.3},{"lead white",0.05}}, um=45, apply="brush", texture=0.35}}}
VP = {505, 262}
XW, YF, YC, ZS = 520, 330, -250, 2.0
function pr(X, Y, z) return {VP[1] + X/z, VP[2] + Y/z} end
SEAM = poly({pr(-XW, YC, ZS), pr(XW, YC, ZS), pr(XW, YF, ZS), pr(-XW, YF, ZS)})
FLOOR = poly({pr(-XW, YF, 0.5), pr(XW, YF, 0.5), pr(XW, YF, ZS), pr(-XW, YF, ZS)})
CEIL = poly({pr(-XW, YC, 0.4), pr(XW, YC, 0.4), pr(XW, YC, ZS), pr(-XW, YC, ZS)})
LW = poly({pr(-XW, YC, 0.4), pr(-XW, YC, ZS), pr(-XW, YF, ZS), pr(-XW, YF, 0.4)})
RW = poly({pr(XW, YC, 0.4), pr(XW, YC, ZS), pr(XW, YF, ZS), pr(XW, YF, 0.4)})
BF = pile{{"bone black",2},{"bone brown",0.9},{"raw sienna",0.25},{"ultramarine blue",0.2},{"lead white",0.06}}
BW = pile{{"bone black",1.8},{"bone brown",1},{"raw sienna",0.35},{"lead white",0.06}}
BC = pile{{"bone black",2.6},{"bone brown",0.5},{"ultramarine blue",0.3}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR - SEAM, {hand="body", pile=BF, coverage=3, fill=true, clip=FLOOR - SEAM, angle=toVP, length={20, 50}, tool="filbert 9"})
work(CEIL - SEAM, {hand="body", pile=BC, coverage=3, fill=true, clip=CEIL - SEAM, angle=toVP, length={20, 50}, tool="filbert 9"})
work((LW + RW) - SEAM, {hand="body", pile=BW, coverage=3, fill=true, clip=(LW + RW) - SEAM, angle=toVP, length={15, 40}, tool="filbert 8"})
-- beyond the seam: cold inverted light
COLD = {
 pile{{"lead white",2},{"cerulean blue",0.35},{"zinc white",0.5}},
 pile{{"lead white",1.4},{"cerulean blue",0.5},{"ultramarine blue",0.15}},
 pile{{"lead white",0.9},{"cerulean blue",0.5},{"ultramarine blue",0.35},{"bone black",0.12}},
}
work(SEAM, {hand="body", pile=COLD[2], coverage=4, fill=true, clip=SEAM, angle=toVP, length={12, 30}, tool="filbert 6"})

--@ chunk 2
print(wait(5*24*60), drying(500,300))
local function cp(X, Y, z) return pr(X, Y, z) end
-- inverted corridor beyond the seam: ceiling brightest, walls mid, floor deeper
local CI = poly({cp(-XW, YC, ZS), cp(XW, YC, ZS), cp(XW, YC, 9), cp(-XW, YC, 9)})
local FI = poly({cp(-XW, YF, ZS), cp(XW, YF, ZS), cp(XW, YF, 9), cp(-XW, YF, 9)})
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(CI * SEAM, {hand="body", pile=COLD[1], coverage=4, fill=true, clip=CI * SEAM, angle=toVP, length={10, 25}, tool="filbert 5"})
work(FI * SEAM, {hand="body", pile=COLD[3], coverage=4, fill=true, clip=FI * SEAM, angle=toVP, length={10, 25}, tool="filbert 5"})

--@ chunk 3
print(wait(6*24*60), drying(500,300))
-- near ribs: bronze rings, a warm lit edge on each
local RB = pile{{"bone black",2.3},{"bone brown",0.6},{"ultramarine blue",0.2}}
local RL = pile{{"raw sienna",1},{"Mars orange",0.3},{"yellow ochre",0.3},{"lead white",0.45},{"bone black",0.2}}
local function ring(z, p, w, pr_, dx)
  dx = dx or 0
  local pts = {pr(-XW, YF, z), pr(-XW, YC, z), pr(XW, YC, z), pr(XW, YF, z)}
  local b = brush{kind="filbert", width=w, stiffness=0.5}
  for i = 1, 3 do b:reload(p, 0.9) b:stroke({{pts[i][1] + dx, pts[i][2]}, {pts[i+1][1] + dx, pts[i+1][2]}}, {pressure={pr_, pr_}, ramps={0.02, 0.02}, clip=-SEAM}) end
  b:reload(p, 0.9) b:stroke({pts[4], pts[1]}, {pressure={pr_*0.8, pr_*0.8}, ramps={0.02, 0.02}, clip=-SEAM})
end
local z = 0.55
while z < 1.95 do
  local w = clamp(14/z, 4, 26)
  ring(z, RB, w, 0.8)
  local e = brush{kind="rigger", width=clamp(2/z, 0.8, 3), point=1}
  local a, b2, c, d = pr(-XW, YF, z*1.03), pr(-XW, YC, z*1.03), pr(XW, YC, z*1.03), pr(XW, YF, z*1.03)
  for _, s in ipairs({{a, b2}, {b2, c}, {c, d}}) do e:load(RL, 0.9) e:stroke(s, {pressure={0.5, 0.5}, ramps={0.03, 0.03}, clip=-SEAM}) end
  z = z * 1.28
end
-- plate seams on the walls between ribs (short horizontal joints)
local PS = pile{{"bone black",2.2},{"bone brown",0.6}}
for _, sd in ipairs({-1, 1}) do
  for _, Y in ipairs({-120, 10, 140, 250}) do
    local r = brush{kind="rigger", width=1.2, point=1}
    r:load(PS, 0.85) r:stroke({pr(sd*XW, Y, 0.45), pr(sd*XW, Y, 1.98)}, {pressure={0.5, 0.3}, clip=-SEAM})
  end
end

--@ chunk 4
print(wait(5*24*60), drying(500,300))
-- inverted ribs folding: each ring smaller, turned a little further, slipping off-centre
local DI = pile{{"ultramarine blue",1},{"bone black",0.9},{"cerulean blue",0.3},{"lead white",0.25}}
local DI2 = pile{{"ultramarine blue",0.8},{"cerulean blue",0.4},{"lead white",0.7},{"bone black",0.3}}
FRAMES = {}
local z = 2.25
local k = 0
while z < 30 do
  k = k + 1
  local th = 0.07*k^1.25
  local ox, oy = 6*math.sin(k*0.9)*k^0.5, 4*math.cos(k*1.3)*k^0.5
  local c, s = math.cos(th), math.sin(th)
  local function q(X, Y) local p = pr(X, Y, z) local dx, dy = p[1] - VP[1], p[2] - VP[2] return {VP[1] + ox + c*dx - s*dy, VP[2] + oy + s*dx + c*dy} end
  local pts = {q(-XW, YF), q(-XW, YC), q(XW, YC), q(XW, YF)}
  FRAMES[#FRAMES+1] = pts
  local w = clamp(12/z, 0.6, 6)
  local b = brush{kind="filbert", width=w, stiffness=0.5}
  for i = 1, 4 do local a, bb = pts[i], pts[(i % 4) + 1] b:reload((k % 2 == 0) and DI or DI2, 0.9) b:stroke({a, bb}, {pressure={0.75, 0.75}, ramps={0.02, 0.02}, clip=SEAM}) end
  -- the corners join the next ring: diagonal creases of the walls
  z = z * 1.3
end
-- crease lines from the seam corners into the folding rings
local r = brush{kind="rigger", width=1.2, point=1}
local corners = {pr(-XW, YF, ZS), pr(-XW, YC, ZS), pr(XW, YC, ZS), pr(XW, YF, ZS)}
for i = 1, 4 do
  local pts = {corners[i]}
  for _, f in ipairs(FRAMES) do pts[#pts+1] = f[i] end
  r:load(DI, 0.9) r:stroke(pts, {pressure={0.6, 0.15}, clip=SEAM})
end
print(#FRAMES)

--@ chunk 5
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local function P(t) return poly(t, true) end
-- rear half: bronze, still in our world
HAUNCH = P({{448, 378}, {470, 366}, {540, 366}, {562, 378}, {566, 404}, {556, 420}, {454, 420}, {444, 404}})
LEGL = P({{452, 410}, {476, 410}, {474, 436}, {470, 452}, {454, 452}, {456, 436}})
LEGR = P({{534, 410}, {558, 410}, {556, 436}, {552, 452}, {536, 452}, {538, 436}})
HOOF = P({{450, 450}, {474, 450}, {476, 458}, {448, 458}}) + P({{532, 450}, {556, 450}, {558, 458}, {530, 458}})
REAR = HAUNCH + LEGL + LEGR + HOOF
local BRD = pile{{"bone black",2.2},{"bone brown",0.6},{"ultramarine blue",0.2}}
fill(poly({{440, 455}, {570, 455}, {600, 468}, {420, 468}}), pile{{"bone black",2.4},{"bone brown",0.4}}, "round 2")
fill(REAR, BRD)
-- front half: the upper body and masts, past the seam, cold and inverted
TORSO = P({{478, 372}, {532, 372}, {538, 300}, {546, 262}, {528, 248}, {482, 248}, {464, 262}, {472, 300}})
HEADC = P({{494, 226}, {516, 226}, {520, 246}, {490, 246}})
MASTS = rect(470, 160, 4, 92) + rect(536, 150, 4, 102) + rect(458, 182, 28, 3) + rect(526, 172, 26, 3)
ARMS = P({{464, 262}, {452, 266}, {440, 320}, {450, 324}, {462, 290}}) + P({{546, 262}, {558, 266}, {572, 316}, {562, 320}, {548, 290}})
FRONT = TORSO + HEADC + MASTS + ARMS
local CI = pile{{"lead white",1.1},{"cerulean blue",0.45},{"ultramarine blue",0.25},{"bone black",0.08}}
fill(FRONT, CI)

--@ chunk 6
print(wait(6*24*60), drying(505,390), drying(505,300))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- the crimson rag still on it: over the haunch, torn; where it crosses the seam it turns to inverted cyan
local CRD = pile{{"rose madder",0.8},{"Mars red",0.5},{"bone black",1.1}}
local CRL = pile{{"Mars red",0.8},{"cadmium red",0.35},{"rose madder",0.4},{"bone black",0.4}}
local CYAN = pile{{"cerulean blue",0.7},{"viridian",0.25},{"lead white",1},{"ultramarine blue",0.1}}
RAG = poly({{470, 370}, {540, 368}, {552, 384}, {546, 398}, {538, 392}, {532, 410}, {522, 400}, {512, 414}, {500, 398}, {488, 410}, {480, 396}, {466, 400}, {462, 384}}, true)
fill(RAG, CRD)
fill(RAG * poly({{505, 360}, {560, 360}, {560, 420}, {505, 420}}), CRL)
RAGUP = poly({{486, 372}, {520, 372}, {516, 330}, {500, 318}, {492, 334}}, true)
fill(RAGUP, CYAN)
-- folding: the upper body slips sideways in bands, each copy a little smaller
local DI = pile{{"ultramarine blue",1},{"bone black",0.9},{"cerulean blue",0.3},{"lead white",0.25}}
local r
local function L(p, pts, pr_, w) r = brush{kind="rigger", width=w or 0.9, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.8}, ramps={0.03, 0.03}}) end
for i, y in ipairs({300, 280, 262, 246}) do
  local dx = i*3
  L(DI, {{470 + dx, y}, {540 + dx, y}}, 0.6, 1.0)
end
L(DI, {{505, 372}, {505, 300}}, 0.6, 1.0) L(DI, {{508, 300}, {509, 280}}, 0.6, 1.0) L(DI, {{512, 280}, {513, 262}}, 0.6, 1.0)
-- ghost copies of the head and masts, smaller, offset into the fold
local GH = pile{{"lead white",0.9},{"cerulean blue",0.5},{"ultramarine blue",0.3}}
for i, s in ipairs({0.8, 0.62, 0.48}) do
  local cx, cy = 505 + i*16, 236 - i*14
  local w, h = 14*s, 10*s
  L(DI, {{cx - w, cy - h}, {cx + w, cy - h}, {cx + w, cy + h}, {cx - w, cy + h}, {cx - w, cy - h}}, 0.5, 0.7)
  L(DI, {{cx - w*2.5, cy - h*1.5}, {cx - w*2.5, cy - h*8}}, 0.45, 0.6)
  L(DI, {{cx + w*2.6, cy - h*1.5}, {cx + w*2.6, cy - h*9}}, 0.45, 0.6)
end
-- mast tips, plates and the visor line on the leading copy
L(DI, {{472, 160}, {472, 252}}, 0.5, 0.6) L(DI, {{538, 150}, {538, 252}}, 0.5, 0.6)
L(DI, {{494, 236}, {516, 236}}, 0.7, 1.1)

--@ chunk 7
print(wait(6*24*60), drying(505,390))
-- bronze rims on the rear half from the warm world behind us; a cold rim where the seam light touches it
local AM = pile{{"Mars orange",0.6},{"raw sienna",0.4},{"lead white",0.6},{"bone black",0.2}}
local CO = pile{{"lead white",1.4},{"cerulean blue",0.4}}
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local r
local function L(p, pts, pr_, w) r = brush{kind="rigger", width=w or 0.9, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr_*0.4, pr_, pr_*0.4}, ramps={0.05, 0.1}}) end
L(CO, {{448, 378}, {470, 366}, {540, 366}, {562, 378}}, 0.55, 1.1)
L(AM, {{562, 380}, {566, 404}, {556, 420}}, 0.45, 0.9)
L(AM, {{444, 382}, {444, 404}, {454, 420}}, 0.4, 0.9)
L(AM, {{556, 412}, {552, 450}}, 0.4, 0.8) L(AM, {{454, 412}, {456, 450}}, 0.35, 0.8)
L(JD, {{462, 400}, {548, 400}}, 0.5, 0.8)
L(JD, {{505, 366}, {505, 420}}, 0.45, 0.8)
for _, x in ipairs({470, 490, 520, 540}) do L(JD, {{x, 404}, {x, 418}}, 0.4, 0.6) end
-- the rosary set down on the near floor
local BEAD = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.35},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local path = {}
for k = 0, 30 do local t = k/30*2*math.pi path[#path+1] = {492 + 30*math.cos(t) + 4*math.sin(3*t), 545 + 8*math.sin(t)} end
local c = brush{kind="rigger", width=0.8, point=1}
c:load(CHN, 0.85) c:stroke(path, {pressure={0.35, 0.35}})
local b = brush{kind="round", width=2.4, point=0.4}
for i = 1, #path, 1 do b:load(BEAD, 0.9) b:touch(path[i][1], path[i][2], {pressure=0.5}) end
c:load(CHN, 0.85) c:stroke({{522, 545}, {532, 550}, {540, 553}}, {pressure={0.35, 0.35}})
local cr = brush{kind="filbert", width=2.2, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({{540, 553}, {556, 556}}, {pressure={0.75, 0.75}})
cr:load(BEAD, 0.95) cr:stroke({{547, 549}, {546, 561}}, {pressure={0.75, 0.75}})

--@ chunk 8
print(wait(8*24*60), drying(505,390), drying(505,300))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local BRD = pile{{"bone black",2.2},{"bone brown",0.6},{"ultramarine blue",0.2}}
fill(HAUNCH - RAG:grow(0.5) + LEGL + LEGR, BRD)
-- the cold half outlined in inverted dark, edge on the side away from the fold
local DI = pile{{"ultramarine blue",1},{"bone black",1.1},{"cerulean blue",0.2},{"lead white",0.15}}
local r
local function L(pts, pr_, w) r = brush{kind="rigger", width=w or 1.2, point=1} r:load(DI, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, ramps={0.03, 0.03}}) end
L({{478, 372}, {472, 300}, {464, 262}, {482, 248}, {528, 248}, {546, 262}, {538, 300}, {532, 372}}, 0.7, 1.6)
L({{464, 262}, {452, 266}, {440, 320}, {450, 324}, {462, 290}}, 0.6, 1.3)
L({{546, 262}, {558, 266}, {572, 316}, {562, 320}, {548, 290}}, 0.6, 1.3)
L({{494, 226}, {516, 226}, {520, 246}, {490, 246}, {494, 226}}, 0.6, 1.3)
-- slip: the torso's upper band displaced into the fold, a sliver of field showing through
local slip = poly({{462, 276}, {548, 276}, {548, 281}, {462, 281}})
fill(slip * TORSO, COLD[1], "round 1")
L({{462, 276}, {548, 276}}, 0.6, 1.0)
L({{462, 281}, {548, 281}}, 0.6, 1.0)
