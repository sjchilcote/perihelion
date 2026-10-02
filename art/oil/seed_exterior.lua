-- easel session "seed_exterior": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.6, linen={18,16}, seed=61,
  ground={{pile={{"bone brown",1},{"burnt sienna",0.4},{"lead white",0.25},{"bone black",0.4}}, um=120, apply="knife", texture=0.25}}}
-- space above the outer hull
SURF = 112
local sp = rect(0, 0, 1000, SURF)
work(sp * rect(0,0,1000,60), {hand="body", tool={kind="filbert", width=10}, pile=pile{{"bone black",1.6},{"ultramarine blue",1}}, coverage=3.6, fill=true, clip=sp, angle=0, length={40,120}})
work(sp * rect(0,60,1000,60), {hand="body", tool={kind="filbert", width=10}, pile=pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.15},{"cobalt blue",0.2}}, coverage=3.6, fill=true, clip=sp, angle=0, length={40,120}})
blend(sp * rect(0, 48, 1000, 24), {angle=0, tool={kind="badger", width=12}})
-- the hull in section: armour layers and voids
LAYERS = {{SURF, 152, "a"}, {152, 186, "v"}, {186, 214, "a"}, {214, 262, "v"}, {262, 290, "a"}, {290, 470, "v"}, {470, 500, "a"}, {500, 546, "v"}, {546, 576, "a"}, {576, 604, "v"}, {604, 625, "a"}}
ARM = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone brown",0.4},{"lead white",0.15}}
VOID = pile{{"bone black",1.4},{"bone brown",0.6},{"ultramarine blue",0.2}}
ARMM, VOIDM = nil, nil
for _,L in ipairs(LAYERS) do
  local m = rect(-5, L[1], 1010, L[2] - L[1])
  if L[3] == "a" then
    work(m, {hand="body", tool={kind="filbert", width=6}, pile=ARM, coverage=3.8, fill=true, clip=m, angle=0, length={30,100}})
    ARMM = ARMM and (ARMM + m) or m
  else
    work(m, {hand="body", tool={kind="filbert", width=8}, pile=VOID, coverage=3.8, fill=true, clip=m, angle=0, length={30,100}})
    VOIDM = VOIDM and (VOIDM + m) or m
  end
end

--@ chunk 2
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- the pod and its tunnel, defined first so the station structure stops at them
local function podpts(cx, cy, L, R)
  local pts = {}
  for k=0,40 do
    local t = k/40*2*math.pi
    local x = math.cos(t)
    local y = math.sin(t)
    local w = (x > 0) and (1 - 0.55*x^4) or (1 - 0.15*x^2)
    pts[#pts+1] = {cx + L*x, cy + R*y*w}
  end
  return pts
end
POD = poly(podpts(585, 382, 245, 112), true)
POD_IN = poly(podpts(585, 382, 222, 92), true)
local tc = {{140, SURF - 4}, {200, 190}, {270, 290}, {350, 362}}
TUN = ribbon(tc, {120, 116, 110, 100})
-- ribs: vertical struts crossing the voids
RIBS = nil
for _,x in ipairs({70, 210, 330, 470, 620, 760, 880, 960}) do
  local r = rect(x - 7, SURF, 14, 625 - SURF)
  RIBS = RIBS and (RIBS + r) or r
end
local ribv = RIBS * VOIDM - POD:grow(10) - TUN
fill(ribv, pile{{"burnt sienna",1},{"bone brown",0.8},{"yellow ochre",0.25}}, 2, 1.5708)
-- section hatching on the cut armour: engraver's diagonal lines
local AH = ARMM - POD:grow(6) - TUN
local hb = brush{kind="round", width=0.8, point=0.7}
for x=-200,1000,7 do
  hb:reload(pile{{"bone brown",1},{"bone black",0.6}}, 0.6)
  hb:stroke({{x, 625}, {x + 515, 110}}, {pressure={0.3,0.3}, clip=AH})
end
-- the outer hull's skin: scale plates in profile along the surface
local sb = brush{kind="round", width=1.6, point=0.4}
local x = 0
while x < 1000 do
  local w = rand(16, 22)
  sb:reload(pile{{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}, 0.8)
  sb:stroke({{x, SURF + 1}, {x + w*0.5, SURF - 5}, {x + w, SURF + 1}}, {pressure={0.55,0.4}, clip=rect(0,0,1000,625) - TUN:grow(2)})
  x = x + w
end
-- the tunnel, sealed: dark bore, scar plates across it
fill(TUN * rect(0, SURF - 8, 1000, 600) - POD, pile{{"bone black",1.5},{"bone brown",0.5},{"Mars red",0.1}}, 4, 0.9)

--@ chunk 3
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- crushed armour where the pod forced through the layers: dark broken edges
local crush = (POD:grow(12) - POD) * ARMM
fill(crush, pile{{"bone black",1.2},{"bone brown",0.8},{"burnt sienna",0.3}}, 2)
-- the pod's shell, cut: dark grey armour with a lit upper edge
SHELL = POD - POD_IN
fill(SHELL, pile{{"bone black",1.1},{"ultramarine ash",0.7},{"lead white",0.3}}, 3, 0)
-- interior rooms, warm
WALLS = {
  {362, 470, pile{{"Mars orange",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"bone black",0.2}}},
  {470, 600, pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.3},{"bone black",0.15}}},
  {600, 712, pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",0.35},{"bone black",0.15}}},
  {712, 820, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"lead white",0.2},{"Mars red",0.1}}},
}
for _,w in ipairs(WALLS) do fill(POD_IN * rect(w[1], 0, w[2] - w[1], 625), w[3], 3, 1.5708) end
-- floor deck and the bulkheads between rooms
DECK = POD_IN * rect(0, 436, 1000, 9)
fill(DECK, pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.3}}, 2)
fill(POD_IN * rect(0, 445, 1000, 40), pile{{"bone black",1.2},{"bone brown",0.6},{"burnt sienna",0.2}}, 2)
for _,x in ipairs({470, 600, 712}) do fill(POD_IN * rect(x - 4, 0, 8, 625), pile{{"bone black",1.1},{"ultramarine ash",0.6},{"lead white",0.25}}, 1.5, 1.5708) end

--@ chunk 4
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local DK = pile{{"bone black",1.4},{"ultramarine ash",0.5},{"lead white",0.12}}
local MID = pile{{"bone black",1},{"ultramarine ash",0.7},{"lead white",0.35}}
-- fabricator: a heavy machine, its round mouth glowing
local fab = POD_IN * poly({{372,330},{455,322},{458,436},{368,436}}, true)
fill(fab, DK, 2.5)
fill(ellipse(424, 388, 28, 33), pile{{"Mars orange",1},{"cadmium red",0.4},{"bone black",0.2}}, 1.5)
fill(ellipse(426, 388, 18, 23), pile{{"cadmium yellow",1},{"Mars orange",0.7},{"lead white",0.3}}, 1.2)
fill(ellipse(428, 388, 8, 11), pile{{"lead white",2},{"cadmium yellow",0.8}}, 1)
-- the glow spills onto the floor and bulkhead
local spill = POD_IN * poly({{450,410},{468,400},{468,436},{440,436}})
fill(spill, pile{{"Mars orange",1},{"cadmium yellow",0.5},{"burnt sienna",0.3}}, 1.5)
-- the rack of spare frames: a rail and three standing frames
fill(POD_IN * rect(478, 318, 116, 6), DK, 1.5)
local function frame(x)
  local s = 1
  local body = ellipse(x, 340, 6, 7) + poly({{x-9,350},{x+9,350},{x+8,392},{x-8,392}}, true) + ribbon({{x-4,392},{x-5,434}}, 5) + ribbon({{x+4,392},{x+5,434}}, 5) + ribbon({{x-9,352},{x-12,385}}, 4) + ribbon({{x+9,352},{x+12,385}}, 4)
  fill(POD_IN * body, MID, 1.2)
  local e = brush{kind="round", width=1, point=0.5}
  e:reload(pile{{"lead white",1.5},{"yellow ochre",0.4}}, 0.7); e:stroke({{x-8,352},{x-7,390}}, {pressure={0.4,0.3}})
  local h = brush{kind="round", width=1, point=0.5}
  h:reload(DK, 0.8); h:stroke({{x, 324}, {x, 333}}, {pressure={0.4,0.4}})
end
frame(503); frame(536); frame(569)
-- the archive: a tall cabinet with four status lights
fill(POD_IN * rect(626, 326, 64, 108), DK, 2)
fill(POD_IN * rect(632, 334, 52, 54), MID, 1.5)
local lb = brush{kind="round", width=5, point=0.2}
for i,p in ipairs({pile{{"emerald green",1},{"zinc white",0.6}}, pile{{"emerald green",1},{"zinc white",0.6}}, pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.4}}, pile{{"cerulean blue",1},{"zinc white",0.8}}}) do
  lb:reload(p, 0.9); lb:touch(640 + (i-1)*12, 404, {pressure=0.6})
end
local tb = brush{kind="round", width=0.9, point=0.5}
for r=0,4 do tb:reload(pile{{"lead white",1},{"cerulean blue",0.3}}, 0.6); tb:stroke({{637, 342 + r*9}, {637 + rand(20, 42), 342 + r*9}}, {pressure={0.35,0.35}}) end
-- the sacred corner: a cross on the wall, a crimson cloth over a small ledge, a small lamp
fill(POD_IN * rect(726, 410, 52, 6), DK, 1.5)
local CL = pile{{"rose madder",1},{"cadmium red",0.6},{"bone black",0.2}}
fill(POD_IN * poly({{728,416},{776,416},{772,436},{760,428},{748,436},{738,428},{730,436}}, true), CL, 1.2)
fill(POD_IN * poly({{726,404},{778,404},{778,411},{726,411}}), CL, 1)
local cb = brush{kind="round", width=3, point=0.3}
cb:reload(pile{{"lead white",1.6},{"yellow ochre",0.6}}, 0.9); cb:stroke({{752, 340}, {752, 392}}, {pressure={0.7,0.7}})
cb:reload(pile{{"lead white",1.6},{"yellow ochre",0.6}}, 0.9); cb:stroke({{738, 356}, {766, 356}}, {pressure={0.7,0.7}})
-- warm ceiling lamps in each room
local wl = brush{kind="round", width=4, point=0.3}
for _,x in ipairs({415, 536, 656, 752}) do wl:reload(pile{{"lead white",2},{"cadmium yellow",0.8}}, 0.9); wl:touch(x, 302 + math.abs(x - 585)*0.05, {pressure=0.5}) end

--@ chunk 5
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- archive lights as lit lenses
for i,p in ipairs({pile{{"emerald green",1},{"zinc white",0.7}}, pile{{"emerald green",1},{"zinc white",0.7}}, pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.5}}, pile{{"cerulean blue",1},{"zinc white",1}}}) do
  fill(ellipse(640 + (i-1)*12, 404, 3.6, 3.6), p, 1)
end
-- roots: cables the pod has grown out into the station's ribs
local CAB = pile{{"bone black",1.2},{"Mars red",0.3},{"burnt sienna",0.4}}
local CABL = pile{{"burnt sienna",1},{"Mars orange",0.6},{"lead white",0.2}}
local function root(pts, w)
  local b = brush{kind="round", width=w, point=0.6}
  b:reload(CAB, 0.9); b:stroke(pts, {pressure={0.8,0.25}, clip=rect(0,0,1000,625) - POD_IN - TUN})
  local l = brush{kind="round", width=math.max(0.8, w*0.3), point=0.6}
  local lp = {}
  for i,p in ipairs(pts) do lp[i] = {p[1], p[2] - w*0.25} end
  l:reload(CABL, 0.6); l:stroke(lp, {pressure={0.4,0.1}, clip=rect(0,0,1000,625) - POD_IN - TUN})
end
root({{810,360},{850,330},{880,300},{888,262},{882,230}}, 5)
root({{800,410},{840,440},{870,470},{880,505},{884,560}}, 5)
root({{700,480},{720,520},{760,545},{762,600}}, 4)
root({{560,492},{590,520},{620,548},{622,600}}, 4)
root({{470,488},{480,520},{474,548}}, 3.5)
root({{720,276},{740,240},{760,220},{762,190}}, 3.5)
root({{600,268},{615,240},{620,214}}, 3)
root({{840,382},{900,390},{955,400},{962,430}}, 4)
-- scar plates sealing the tunnel: overlapping grey-bronze patches across the bore
local SP = {pile{{"bone black",0.8},{"ultramarine ash",0.6},{"burnt sienna",0.4},{"lead white",0.3}}, pile{{"burnt sienna",0.8},{"bone black",0.6},{"ultramarine ash",0.4},{"lead white",0.2}}}
local i = 0
for _,c in ipairs({{150,128,0.85},{180,170,0.95},{210,214,1.0},{245,258,0.95},{285,300,0.85}}) do
  i = i + 1
  local cx, cy, a = c[1], c[2], c[3]
  local ca, sa = math.cos(a), math.sin(a)
  local function R(u, v) return {cx + u*ca - v*sa, cy + u*sa + v*ca} end
  local plate = poly({R(-14,-58), R(16,-56), R(18,58), R(-12,60)}) * TUN
  fill(plate, SP[(i%2)+1], 2, a + 1.5708)
  local rv = brush{kind="round", width=2.5, point=0.3}
  for _,v in ipairs({-44, -15, 15, 44}) do local p = R(0, v); rv:reload(pile{{"bone black",1.4}}, 0.7); rv:touch(p[1], p[2], {pressure=0.4}) end
  local e = brush{kind="round", width=1.2, point=0.5}
  e:reload(pile{{"lead white",1.2},{"yellow ochre",0.3}}, 0.6); e:stroke({R(-14,-56), R(-12,58)}, {pressure={0.35,0.3}, clip=TUN})
end
-- the section: plate joints in the armour and diagonal bracing in the voids
local J = pile{{"bone black",1.3},{"bone brown",0.5}}
local jb = brush{kind="round", width=1.2, point=0.5}
for _,L in ipairs(LAYERS) do
  if L[3] == "a" then
    local x = rand(0, 60)
    while x < 1000 do
      jb:reload(J, 0.7); jb:stroke({{x, L[1] + 1}, {x + 2, L[2] - 1}}, {pressure={0.45,0.45}, clip=ARMM - POD:grow(12) - TUN})
      x = x + rand(45, 90)
    end
    jb:reload(J, 0.7); jb:stroke({{0, L[2] - 0.5}, {1000, L[2] - 0.5}}, {pressure={0.5,0.5}, clip=rect(0,0,1000,625) - POD:grow(12) - TUN})
    jb:reload(pile{{"yellow ochre",1},{"lead white",0.6}}, 0.6); jb:stroke({{0, L[1] + 0.8}, {1000, L[1] + 0.8}}, {pressure={0.35,0.35}, clip=rect(0,0,1000,625) - POD:grow(12) - TUN})
  end
end
local BR = pile{{"burnt sienna",1},{"bone brown",0.8},{"bone black",0.3}}
local bb = brush{kind="round", width=3, point=0.3}
for _,s in ipairs({{70,500,210,546},{210,500,70,546},{760,500,880,546},{880,500,760,546},{330,152,470,186},{620,214,760,262},{760,214,620,262},{880,152,960,186},{210,576,330,604},{470,576,620,604}}) do
  bb:reload(BR, 0.8); bb:stroke({{s[1], s[2]}, {s[3], s[4]}}, {pressure={0.6,0.6}, clip=VOIDM - POD:grow(12) - TUN})
end

--@ chunk 6
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- roots, heavier, warm where they leave the pod
local CAB = pile{{"bone black",1},{"Mars red",0.5},{"burnt sienna",0.6}}
local CABL = pile{{"Mars orange",1},{"burnt sienna",0.5},{"lead white",0.35}}
local okm = rect(0,0,1000,625) - POD_IN - TUN - rect(0,0,1000,SURF)
local function root(pts, w)
  local b = brush{kind="round", width=w, point=0.7}
  b:reload(CAB, 0.95); b:stroke(pts, {pressure={0.85,0.15}, ramps={0.05,0.6}, clip=okm})
  local lp = {}
  for i,p in ipairs(pts) do lp[i] = {p[1] - w*0.15, p[2] - w*0.3} end
  local l = brush{kind="round", width=math.max(1, w*0.28), point=0.7}
  l:reload(CABL, 0.7); l:stroke(lp, {pressure={0.55,0.05}, ramps={0.05,0.7}, clip=okm})
end
root({{812,365},{852,334},{880,302},{886,262},{882,222},{884,190}}, 9)
root({{806,406},{842,440},{870,472},{880,508},{884,566},{882,610}}, 9)
root({{702,482},{722,520},{760,546},{762,604}}, 7)
root({{560,494},{590,522},{618,548},{622,606}}, 7)
root({{468,490},{478,522},{472,552},{470,580}}, 6)
root({{718,278},{740,242},{760,220},{762,186}}, 6)
root({{598,270},{614,240},{620,212}}, 5)
root({{838,384},{900,392},{955,402},{962,440},{960,480}}, 7)
root({{880,302},{920,280},{955,256},{962,228}}, 4)
root({{884,508},{920,520},{958,540}}, 4)
-- the pod's shell: engraver's hatching, a lit upper edge, a hard outline
local hb = brush{kind="round", width=0.7, point=0.7}
for x=200,1000,6 do hb:reload(pile{{"bone black",1.5}}, 0.5); hb:stroke({{x, 500}, {x + 200, 260}}, {pressure={0.28,0.28}, clip=SHELL * below(function(x) return 382 end)}) end
local function podpts(cx, cy, L, R, a0, a1)
  local pts = {}
  for k=0,40 do
    local t = a0 + (a1-a0)*k/40
    local x, y = math.cos(t), math.sin(t)
    local w = (x > 0) and (1 - 0.55*x^4) or (1 - 0.15*x^2)
    pts[#pts+1] = {cx + L*x, cy + R*y*w}
  end
  return pts
end
local ol = brush{kind="round", width=2, point=0.4}
ol:reload(pile{{"bone black",2}}, 0.9); ol:stroke(podpts(585, 382, 246, 113, 0, 2*math.pi), {pressure={0.6,0.6}})
local lit = brush{kind="round", width=1.6, point=0.5}
lit:reload(pile{{"lead white",1.5},{"ultramarine ash",0.4}}, 0.8); lit:stroke(podpts(585, 382, 240, 108, math.pi*1.1, math.pi*1.85), {pressure={0.5,0.4}})
-- the fabricator's glow warming the rear room
local glow = POD_IN * ellipse(430, 388, 60, 70) - ellipse(424, 388, 30, 35)
work(glow, {hand="scumble", tool={kind="filbert", width=3}, pile=pile{{"Mars orange",1},{"cadmium yellow",0.4},{"lead white",0.2}}, coverage=0.7, load=0.25, pressure={0.1,0.25}, clip=glow})
-- stars in the cool space above
local sb = brush{kind="round", width=1.0, point=0.8}
for i=1,120 do local x, y = rand(2, 998), rand(2, SURF - 8); sb:reload(pile{{"zinc white",3}}, 0.5); sb:touch(x, y, {pressure=rand(0.06,0.25)}) end
-- the scar where the pod entered: a raised weld cap over the tunnel mouth on the surface
local cap = poly({{78,SURF-10},{208,SURF-12},{212,SURF+2},{74,SURF+4}}, true)
fill(cap, pile{{"bone black",0.8},{"ultramarine ash",0.6},{"burnt sienna",0.4},{"lead white",0.3}}, 2)
local cl = brush{kind="round", width=1.4, point=0.5}
cl:reload(pile{{"lead white",1.4},{"ultramarine ash",0.3}}, 0.7); cl:stroke({{80,SURF-10},{206,SURF-12}}, {pressure={0.45,0.35}})
-- a title cartouche line, as on an engraved plate, kept to abstract marks
local tl = brush{kind="round", width=1.2, point=0.7}
local x = 640
while x < 960 do local L = rand(8, 24); tl:reload(pile{{"lead white",1.2},{"yellow ochre",0.4}}, 0.6); tl:stroke({{x, 30}, {x + L*0.5, 27}, {x + L, 30}}, {pressure={0.35,0.3}}); x = x + L + rand(4, 9) end

--@ chunk 7
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local room = POD_IN * rect(362, 0, 104, 436)
fill(room, pile{{"Mars orange",1},{"burnt sienna",0.7},{"bone black",0.3}}, 2.5, 1.5708)
local fab = POD_IN * poly({{372,330},{455,322},{458,436},{368,436}}, true)
fill(fab, pile{{"bone black",1.4},{"ultramarine ash",0.5},{"lead white",0.12}}, 2)
local R = {
  {33, 40, pile{{"burnt sienna",1},{"Mars orange",0.6},{"bone black",0.3}}},
  {26, 33, pile{{"Mars orange",1},{"cadmium red",0.3},{"bone black",0.1}}},
  {18, 26, pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.15}}},
  {10, 18, pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",0.5}}},
  {0, 10, pile{{"lead white",2},{"cadmium yellow",0.6}}},
}
for _,r in ipairs(R) do
  local m = (ellipse(424, 388, r[2]*0.85, r[2]) - ellipse(424, 388, r[1]*0.85, r[1]))
  fill(m, r[3], 1.5)
end
blend(ellipse(424, 388, 36, 42), {tool={kind="badger", width=4}})
-- a hard dark lip on the mouth
local lip = brush{kind="round", width=2, point=0.4}
local pts = {}
for k=0,30 do local t = 2*math.pi*k/30; pts[#pts+1] = {424 + 34*math.cos(t), 388 + 40*math.sin(t)} end
lip:reload(pile{{"bone black",1.6}}, 0.9); lip:stroke(pts, {pressure={0.55,0.55}})
-- the glow catches the bulkhead and floor
local e = brush{kind="round", width=1.6, point=0.5}
e:reload(pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.8); e:stroke({{462,350},{462,434}}, {pressure={0.45,0.1}})
e:reload(pile{{"Mars orange",1},{"cadmium yellow",0.5}}, 0.8); e:stroke({{440,437},{466,437},{500,437}}, {pressure={0.5,0.05}})

--@ chunk 8
print(wait(3*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=5, fill=true, clip=m, angle=ang or 0}) end end
local fab = POD_IN * poly({{372,330},{455,322},{458,436},{368,436}}, true) - ellipse(424, 388, 30, 35)
fill(fab, pile{{"bone black",1.6},{"ultramarine ash",0.4},{"lead white",0.08}}, 2)
fill(POD_IN * rect(456, 300, 18, 136) - ellipse(424, 388, 30, 35), pile{{"Mars orange",1},{"burnt sienna",0.8},{"bone black",0.35}}, 1.5, 1.5708)
fill(POD_IN * rect(466, 0, 8, 625), pile{{"bone black",1.1},{"ultramarine ash",0.6},{"lead white",0.25}}, 1.5, 1.5708)
local R = {
  {22, 30, pile{{"Mars orange",1},{"cadmium red",0.35}}},
  {14, 22, pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.2}}},
  {7, 14, pile{{"cadmium yellow",1},{"lead white",0.6}}},
  {0, 7, pile{{"lead white",2.5},{"cadmium yellow",0.4}}},
}
for _,r in ipairs(R) do fill(ellipse(424, 388, r[2]*0.85, r[2]) - ellipse(424, 388, r[1]*0.85, r[1]), r[3], 1.2) end
print(wait(24*60))
local lip = brush{kind="round", width=2.2, point=0.4}
local pts = {}
for k=0,30 do local t = 2*math.pi*k/30; pts[#pts+1] = {424 + 26.5*math.cos(t), 388 + 31*math.sin(t)} end
lip:reload(pile{{"bone black",1.6}}, 0.9); lip:stroke(pts, {pressure={0.6,0.6}})
local e = brush{kind="round", width=1.6, point=0.5}
e:reload(pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.3}}, 0.8); e:stroke({{452,370},{456,392},{452,412}}, {pressure={0.5,0.3}})
e:reload(pile{{"lead white",1.5},{"ultramarine ash",0.3}}, 0.6); e:stroke({{374,330},{455,322}}, {pressure={0.4,0.3}})
