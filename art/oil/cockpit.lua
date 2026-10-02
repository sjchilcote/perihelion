-- easel session "cockpit": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=91,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.3},{"lead white",0.15}}, um=120, apply="knife", texture=0.25}}}
-- the canopy glass: one wide pane outline, struts later
GLASS = poly({{70,28},{930,28},{985,395},{15,395}})
-- space through the glass: deep blue-black, warming toward the Sun at the right edge
local SP1 = pile{{"bone black",1.5},{"ultramarine blue",1}}
local SP2 = pile{{"ultramarine blue",1},{"bone black",0.8},{"lead white",0.15},{"burnt sienna",0.1}}
local SP3 = pile{{"ultramarine blue",0.6},{"bone black",0.4},{"lead white",0.5},{"Mars orange",0.2}}
work(GLASS * rect(0,0,640,H), {hand="body", tool={kind="filbert", width=12}, pile=SP1, coverage=3, fill=true, clip=GLASS, angle=0.2, length={40,120}})
work(GLASS * rect(640,0,220,H), {hand="body", tool={kind="filbert", width=10}, pile=SP2, coverage=3, fill=true, clip=GLASS, angle=0.2, length={40,120}})
work(GLASS * rect(860,0,200,H), {hand="body", tool={kind="filbert", width=8}, pile=SP3, coverage=3, fill=true, clip=GLASS, angle=0.2, length={30,90}})
blend(GLASS * (rect(615,0,50,H) + rect(835,0,50,H)), {angle=0, tool={kind="badger", width=12}})
-- the cockpit around it, near black
local FR = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
work(rect(0,0,1000,H) - GLASS, {hand="body", tool={kind="filbert", width=14}, pile=FR, coverage=3, fill=true, clip=true, angle=0, length={40,120}})

--@ chunk 2
print(wait(24*60))
-- the Testament's ring: the near band fills the lower glass, its far side arcs across the sky
function ytop(x) local u = (x-420)/900; return 900 - 700*math.sqrt(math.max(0, 1-u*u)) end
function yfar(x) local u = (x-520)/560; if math.abs(u) >= 1 then return nil end return 150 - 105*math.sqrt(1-u*u) end
NEAR = GLASS * mask(function(x,y) return (y > ytop(x)) and 1 or 0 end)
local FARB = GLASS * mask(function(x,y) local a = yfar(x); if not a then return 0 end return (y > a and y < a + 7 + 14*(1 - math.abs((x-520)/560))) and 1 or 0 end)
FAR = FARB
local B1 = pile{{"bone black",1},{"burnt sienna",0.8},{"yellow ochre",0.3},{"bone brown",0.4}}
local B2 = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.5}}
local B3 = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"raw sienna",0.5},{"bone black",0.15}}
work(FAR, {hand="detail", tool={kind="filbert", width=3}, pile=B1, coverage=4, fill=true, clip=FAR, angle=0})
-- the near face: backlit, darkest on the left, warming toward the Sun side
local function z(x,y) return x + (y - ytop(x))*0.6 end
local Z = {{-999, 380, B1}, {380, 700, pile{{"bone black",0.7},{"burnt sienna",0.9},{"yellow ochre",0.45},{"bone brown",0.2}}}, {700, 2000, B2}}
for _,r in ipairs(Z) do
  local m = NEAR * mask(function(x,y) local v = z(x,y); return (v >= r[1] and v < r[2]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=10}, pile=r[3], coverage=3.5, fill=true, clip=NEAR, angle=function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end, length={30,90}})
end
blend(NEAR * mask(function(x,y) local v = z(x,y); return (math.abs(v-380) < 40 or math.abs(v-700) < 40) and 1 or 0 end), {tool={kind="badger", width=14}})
-- the ring's outer rim, seen nearly edge-on just above the face, lit hot by the Sun
RIM = GLASS * mask(function(x,y) local t = ytop(x); return (y > t - 9 and y <= t) and 1 or 0 end)
work(RIM, {hand="detail", tool={kind="filbert", width=2.5}, pile=B3, coverage=4, fill=true, clip=RIM, angle=0})

--@ chunk 3
print(wait(3*24*60))
local function ang(x,y) return math.atan(y - 900, x - 420) + 1.5708 end
local function z(x,y) return x + (y - ytop(x))*0.6 end
local Z = {
  {-999, 300, pile{{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.5},{"yellow ochre",0.2}}},
  {300, 560, pile{{"burnt sienna",1},{"bone brown",0.5},{"yellow ochre",0.4},{"bone black",0.3}}},
  {560, 800, pile{{"burnt sienna",1},{"yellow ochre",0.8},{"raw sienna",0.3},{"bone black",0.15}}},
  {800, 2000, pile{{"yellow ochre",1},{"raw sienna",0.6},{"burnt sienna",0.4},{"lead white",0.2}}},
}
local face = NEAR - RIM
for _,r in ipairs(Z) do
  local m = face * mask(function(x,y) local v = z(x,y); return (v >= r[1] and v < r[2]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=8}, pile=r[3], coverage=4, fill=true, clip=face, angle=ang, length={30,90}})
end
blend(face * mask(function(x,y) local v = z(x,y); return (math.abs(v-300) < 30 or math.abs(v-560) < 30 or math.abs(v-800) < 30) and 1 or 0 end), {angle=ang, tool={kind="badger", width=10}})
-- the far side of the ring, curving properly across the sky
local SP1 = pile{{"bone black",1.5},{"ultramarine blue",1}}
local oldfar = FAR:grow(2)
work(oldfar, {hand="detail", tool={kind="filbert", width=4}, pile=SP1, coverage=4.5, fill=true, clip=oldfar, angle=0})
function yfar2(x) local u = (x-560)/520; if math.abs(u) >= 1 then return nil end return 175 - 130*math.sqrt(1-u*u) end
FAR2 = GLASS * mask(function(x,y) local a = yfar2(x); if not a then return 0 end local th = 4 + 12*math.sqrt(1 - ((x-560)/520)^2); return (y > a and y < a + th) and 1 or 0 end) - NEAR:grow(1)
work(FAR2, {hand="detail", tool={kind="filbert", width=2.5}, pile=pile{{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.6}}, coverage=4.5, fill=true, clip=FAR2, angle=0})

--@ chunk 4
-- the sky by the Sun again, as smooth graded bands with the seams fused
local sky = GLASS - NEAR - FAR2:grow(1)
local S = {
  {560, 700, pile{{"ultramarine blue",1},{"bone black",1.1},{"lead white",0.08}}},
  {700, 800, pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.25},{"burnt sienna",0.08}}},
  {800, 880, pile{{"ultramarine blue",0.8},{"bone black",0.4},{"lead white",0.55},{"Mars orange",0.12}}},
  {880, 1100, pile{{"lead white",1},{"ultramarine blue",0.35},{"Mars orange",0.2},{"bone black",0.15}}},
}
for _,s in ipairs(S) do
  local m = sky * mask(function(x,y) local v = x - 0.25*y; return (v >= s[1] - 0.25*0 and v < s[2]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=s[3], coverage=4, fill=true, clip=sky, angle=1.82, length={20,60}})
end
blend(sky * mask(function(x,y) local v = x - 0.25*y; return (math.abs(v-700) < 20 or math.abs(v-800) < 20 or math.abs(v-880) < 20) and 1 or 0 end), {angle=1.82, tool={kind="badger", width=8}})
-- scale plates on the near face: a dark lip and a sunward lit edge, growing toward us
local LD = pile{{"bone black",1.4},{"burnt sienna",0.6},{"bone brown",0.3}}
local LL = pile{{"yellow ochre",1},{"lead white",0.7},{"cadmium yellow",0.2}}
local LLd = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.2}}
local face = NEAR - RIM
local bD = brush{kind="round", width=1.4, point=0.5}
local bL = brush{kind="round", width=1.0, point=0.7}
local n = 0
local d = 4
local row = 0
while d < 260 do
  local h = 2.2 + d*0.07
  local w = h*2.8
  local x = -20 + ((row*0.37) % 1)*w
  while x < 1010 do
    local y = ytop(x) + d
    if face:at(x, y) > 0.5 then
      local t = math.atan(y - 900, x - 420) + 1.5708
      local ct, st = math.cos(t), math.sin(t)
      local pts, lit = {}, {}
      for k=0,6 do
        local a = -1 + k/3
        local ox, oy = a*w*0.5, h*(1 - a*a)
        pts[#pts+1] = {x + ox*ct - oy*st, y + ox*st + oy*ct}
        lit[#lit+1] = {x + ox*ct - (oy-1.1)*st, y + ox*st + (oy-1.1)*ct}
      end
      if n % 8 == 0 then bD:load(LD, 0.8) end
      bD:stroke(pts, {pressure={0.35 + h*0.02, 0.25}})
      local sun = (x - 0.4*(y-ytop(x))) / 1000
      if sun > 0.25 then
        if n % 6 == 0 then bL:load((sun > 0.6) and LL or LLd, 0.6) end
        bL:stroke({lit[4], lit[5], lit[6], lit[7]}, {pressure={0.15 + 0.3*sun, 0.05}})
      end
      n = n + 1
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1
  row = row + 1
end
print(n)

--@ chunk 5
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
local FR = pile{{"bone black",2},{"ultramarine blue",0.3},{"burnt sienna",0.2}}
local FRM = pile{{"bone black",1.4},{"ultramarine ash",0.6},{"lead white",0.12}}
local FRL = pile{{"lead white",0.8},{"ultramarine ash",0.6},{"bone black",0.6},{"Mars orange",0.1}}
-- the canopy struts and the heavy sill
STRUT_L = poly({{318,400},{344,400},{278,22},{254,22}})
STRUT_R = poly({{676,400},{702,400},{770,22},{746,22}})
SILL = poly({{0,390},{1000,390},{1000,420},{0,420}}) + poly({{0,0},{1000,0},{1000,34},{0,34}})
fill(STRUT_L + STRUT_R + SILL, FR, 4)
local e = brush{kind="round", width=2.2, point=0.4}
e:reload(FRL, 0.8); e:stroke({{344,398},{278,24}}, {pressure={0.55,0.45}})
e:reload(FRL, 0.8); e:stroke({{702,398},{770,24}}, {pressure={0.6,0.5}})
e:reload(FRM, 0.8); e:stroke({{6,391},{994,391}}, {pressure={0.6,0.6}})
e:reload(FRM, 0.8); e:stroke({{6,33},{994,33}}, {pressure={0.5,0.5}})
-- rivets on the struts
local rv = brush{kind="round", width=3, point=0.3}
for k=1,8 do
  local t = k/9
  for _,S in ipairs({{331,400,266,22},{689,400,758,22}}) do
    local x, y = S[1] + (S[3]-S[1])*t, S[2] + (S[4]-S[2])*t
    rv:reload(FRM, 0.7); rv:touch(x, y, {pressure=0.4})
  end
end
-- the instrument panel: hooded screens glowing amber, rows of keys, a dial
local PAN = pile{{"bone black",1.4},{"ultramarine ash",0.5},{"bone brown",0.3},{"lead white",0.08}}
fill(poly({{60,430},{940,430},{1000,562},{0,562}}), PAN, 6)
local SCR = pile{{"Mars orange",1},{"cadmium yellow",0.4},{"bone black",0.35}}
local SCRL = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",0.6}}
for _,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do
  fill(rect(s[1]-4, s[2]-6, s[3]+8, s[4]+10), FR, 2)
  fill(rect(s[1], s[2], s[3], s[4]), SCR, 2)
  local tb = brush{kind="round", width=1.3, point=0.4}
  for r=0,4 do
    tb:reload(SCRL, 0.8)
    local y = s[2] + 9 + r*10
    local L = rand(0.3, 0.9)*s[3]
    tb:stroke({{s[1] + 8, y}, {s[1] + 8 + L, y}}, {pressure={0.4,0.35}})
  end
end
-- a curve on the left screen and a bar graph on the right
local cb = brush{kind="round", width=1.3, point=0.4}
cb:reload(SCRL, 0.8); cb:stroke({{125,510},{160,498},{195,503},{230,488},{265,478}}, {pressure={0.45,0.4}})
for k=0,6 do cb:reload(SCRL, 0.8); local x = 745 + k*18; cb:stroke({{x, 512}, {x, 512 - rand(8, 34)}}, {pressure={0.8,0.8}}) end
-- keys
local KEY = pile{{"bone black",1},{"ultramarine ash",0.8},{"lead white",0.25}}
local KA = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.3}}
local kb = brush{kind="round", width=5, point=0.2}
for r=0,1 do for k=0,14 do
  local x, y = 140 + k*50 + r*20, 532 + r*16
  kb:reload((k*7 + r*3) % 9 == 0 and KA or KEY, 0.8); kb:touch(x, y, {pressure=0.6})
end end

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
-- screens again, on dry paint: hot amber
local SCR = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.3}}
local SCRD = pile{{"Mars orange",1},{"burnt sienna",0.4},{"bone black",0.15}}
local SCRL = pile{{"cadmium yellow",1},{"lead white",1}}
for i,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do
  fill(rect(s[1], s[2], s[3], s[4]), SCRD, 2)
  fill(rect(s[1]+3, s[2]+3, s[3]-6, s[4]*0.45), SCR, 2)
end
print(wait(24*60))
local tb = brush{kind="round", width=1.2, point=0.4}
for i,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do
  for r=0,4 do
    local y = s[2] + 9 + r*10
    local x = s[1] + 8
    while x < s[1] + s[3] - 14 do
      local L = rand(4, 16)
      if math.random() < 0.8 then tb:reload(SCRL, 0.7); tb:stroke({{x, y}, {x + L, y}}, {pressure={0.4,0.35}}) end
      x = x + L + rand(3, 7)
    end
  end
end
-- keys catching the screens' glow
local kb = brush{kind="round", width=6, point=0.2}
local KEY = pile{{"bone black",1},{"ultramarine ash",0.6},{"lead white",0.4},{"Mars orange",0.1}}
local KA = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.4}}
local KG = pile{{"emerald green",1},{"zinc white",0.6}}
for r=0,1 do for k=0,14 do
  local x, y = 140 + k*50 + r*20, 534 + r*15
  local p = KEY
  if (k*7 + r*3) % 9 == 0 then p = KA elseif (k*5 + r) % 11 == 0 then p = KG end
  kb:reload(p, 0.9); kb:touch(x, y, {pressure=0.7})
end end
-- the target patch on the hull: an old breach plate, darker, its own scale pattern broken
local P = poly({{445,282},{500,276},{520,300},{506,326},{452,330},{436,306}}, true)
fill(P, pile{{"bone black",1},{"burnt sienna",0.7},{"bone brown",0.6}}, 2)
local cr = brush{kind="round", width=1.0, point=0.5}
for k=1,6 do cr:reload(pile{{"bone black",1.6}}, 0.8); local x = rand(448, 500); cr:stroke({{x, 284 + rand(0,8)}, {x + rand(-8, 8), 322 - rand(0, 8)}}, {pressure={0.4,0.2}}) end
cr:reload(pile{{"yellow ochre",1},{"lead white",0.6}}, 0.7); cr:stroke({{500,277},{520,300},{507,325}}, {pressure={0.4,0.2}})

--@ chunk 7
print(wait(24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
local PANE_R = GLASS * poly({{770,34},{1000,34},{1000,390},{702,390}})
-- the Sun, at the right edge of the glass
local SX, SY = 935, 90
local G1 = pile{{"lead white",2},{"zinc white",1},{"Mars orange",0.15}}
local G2 = pile{{"zinc white",3},{"lemon chrome",0.25}}
local halo = ellipse(SX, SY, 70, 70) * PANE_R
work(halo, {hand="glaze", tool={kind="filbert", width=6}, pile=pile{{"lead white",3},{"zinc white",1},{"Mars orange",0.15},medium=0.6}, load=0.3, pressure={0.1,0.25}, coverage=1.4, clip=halo})
blend(ellipse(SX, SY, 78, 78) * PANE_R, {tool={kind="badger", width=12}})
fill(ellipse(SX, SY, 30, 30) * PANE_R, G1, 3)
fill(ellipse(SX, SY, 14, 14) * PANE_R, G2, 2)
blend((ellipse(SX, SY, 36, 36) - ellipse(SX, SY, 10, 10)) * PANE_R, {tool={kind="badger", width=6}})

--@ chunk 8
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
local SX, SY = 935, 90
-- the flare dragged across the glass, and the scratches it lights
local FL = pile{{"zinc white",2},{"lead white",1},{"Mars orange",0.1}}
local rr = brush{kind="rigger", width=1.6, point=1}
rr:reload(FL, 0.6); rr:stroke({{SX, SY}, {SX - 300, SY + 150}, {SX - 600, SY + 300}}, {pressure={0.5,0.0}, ramps={0.02,0.95}, clip=GLASS - STRUT_L - STRUT_R})
for _,a in ipairs({0.6, 1.4, 2.3, 3.6, 4.6, 5.5}) do
  local L = rand(40, 75)
  rr:reload(FL, 0.6); rr:stroke({{SX, SY}, {SX + L*math.cos(a), SY + L*math.sin(a)}}, {pressure={0.4,0.0}, clip=GLASS})
end
local fb = brush{kind="round", width=6, point=0.2}
for k,t in ipairs({0.3, 0.55, 0.75}) do
  local x, y = SX - 600*t, SY + 300*t
  fb:reload(pile{{"lead white",1},{"cobalt violet",0.25},{"Mars orange",0.1},medium=0.4}, 0.4)
  fb:touch(x, y, {pressure=0.25 + 0.1*k})
end
local sc = brush{kind="round", width=0.7, point=0.7}
for i=1,40 do
  local a = rand(0, 2*math.pi); local r = rand(30, 230)
  local x, y = SX + r*math.cos(a)*1.3, SY + r*math.sin(a)*0.8
  if GLASS:at(x, y) > 0.5 then
    local t = a + 1.5708 + rand(-0.3, 0.3)
    local L = rand(8, 26) * (1 - r/260)
    sc:reload(pile{{"zinc white",2},{"lead white",1}}, 0.5)
    sc:stroke({{x, y}, {x + L*math.cos(t), y + L*math.sin(t)}}, {pressure={0.25*(1 - r/260) + 0.05, 0.02}})
  end
end
-- the station's sunward rim burns
local RL = pile{{"lead white",1.5},{"cadmium yellow",0.6},{"yellow ochre",0.3}}
local eb = brush{kind="round", width=2.2, point=0.5}
local pts = {}
for x=520,985,15 do pts[#pts+1] = {x, ytop(x) - 1} end
eb:reload(RL, 0.8); eb:stroke(pts, {pressure={0.1,0.6}, clip=GLASS - STRUT_L - STRUT_R})
local pts2 = {}
for x=600,1000,15 do local a = yfar2(x); if a then pts2[#pts2+1] = {x, a + 0.5} end end
eb:reload(RL, 0.6); eb:stroke(pts2, {pressure={0.1,0.4}, clip=GLASS - STRUT_L - STRUT_R})
-- the HUD: a cold cyan reticle projected round the target patch, with glyphs and a range
local CY = pile{{"cerulean blue",1},{"zinc white",1.2},{"viridian",0.2}}
local h = brush{kind="round", width=1.4, point=0.4}
local cx, cy = 478, 303
local function br(pts) h:reload(CY, 0.8); h:stroke(pts, {pressure={0.45,0.45}, clip=GLASS - STRUT_L - STRUT_R}) end
br({{cx-58, cy-30}, {cx-58, cy-44}, {cx-44, cy-44}})
br({{cx+44, cy-44}, {cx+58, cy-44}, {cx+58, cy-30}})
br({{cx-58, cy+30}, {cx-58, cy+44}, {cx-44, cy+44}})
br({{cx+44, cy+44}, {cx+58, cy+44}, {cx+58, cy+30}})
br({{cx-12, cy}, {cx-4, cy}}); br({{cx+4, cy}, {cx+12, cy}}); br({{cx, cy-12}, {cx, cy-4}}); br({{cx, cy+4}, {cx, cy+12}})
local pts3 = {}
for k=0,24 do local a = 2*math.pi*k/24; pts3[#pts3+1] = {cx + 34*math.cos(a), cy + 34*math.sin(a)} end
h:reload(CY, 0.6); h:stroke(pts3, {pressure={0.25,0.25}, clip=GLASS})
-- angular glyphs and the closing range
local g = brush{kind="round", width=1.3, point=0.4}
local function glyph(x, y, segs) for _,s in ipairs(segs) do g:reload(CY, 0.8); g:stroke({{x + s[1], y + s[2]}, {x + s[3], y + s[4]}}, {pressure={0.45,0.45}}) end end
local gx, gy = cx + 70, cy - 46
glyph(gx, gy, {{0,0,8,0},{8,0,4,10}}); glyph(gx + 13, gy, {{0,10,4,0},{4,0,8,10},{2,6,7,6}}); glyph(gx + 26, gy, {{0,0,0,10},{0,5,8,0},{0,5,8,10}})
glyph(gx, gy + 16, {{0,0,8,0},{0,0,0,10},{0,10,8,10}}); glyph(gx + 13, gy + 16, {{0,0,8,10},{8,0,0,10}})
-- range: "0.48" in block stencil
local rx, ry = cx + 70, cy + 34
glyph(rx, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0}})
g:reload(CY, 0.8); g:touch(rx + 12, ry + 12, {pressure=0.5})
glyph(rx + 16, ry, {{0,0,0,7},{0,7,8,7},{6,0,6,12}})
glyph(rx + 28, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0},{0,6,8,6}})
glyph(rx + 42, ry, {{0,6,6,6},{0,8,6,8}})
-- a chevron ladder down to the patch
for k=0,2 do glyph(cx - 4, cy + 52 + k*9, {{0,0,4,4},{4,4,8,0}}) end

--@ chunk 9
print(wait(2*24*60))
local SX, SY = 935, 90
local PANE_R = GLASS * poly({{770,34},{1000,34},{1000,390},{702,390}})
local nearR = NEAR * PANE_R
-- the glare: graded rings of light laid opaque over the right pane, fused at the seams
local Rg = {
  {0, 34, pile{{"zinc white",3},{"lemon chrome",0.2}}},
  {34, 70, pile{{"lead white",2},{"zinc white",1},{"cadmium yellow",0.2}}},
  {70, 120, pile{{"lead white",1.5},{"ultramarine blue",0.15},{"Mars orange",0.25},{"zinc white",0.5}}},
  {120, 175, pile{{"lead white",0.9},{"ultramarine blue",0.4},{"Mars orange",0.15},{"bone black",0.12}}},
}
for _,g in ipairs(Rg) do
  local m = (ellipse(SX, SY, g[2], g[2]) - ellipse(SX, SY, g[1], g[1])) * PANE_R - nearR - STRUT_R:grow(1)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=4}, pile=g[3], coverage=4, fill=true, clip=m, angle=function(x,y) return math.atan(y-SY, x-SX) + 1.5708 end}) end
end
blend((ellipse(SX, SY, 182, 182)) * PANE_R - nearR - STRUT_R:grow(1), {angle=function(x,y) return math.atan(y-SY, x-SX) end, tool={kind="badger", width=12}})
-- the glare washes the sunward hull nearest it
local wash = ellipse(SX, SY, 260, 260) * nearR
work(wash, {hand="glaze", tool={kind="filbert", width=6}, pile=pile{{"lead white",2},{"cadmium yellow",0.4},medium=0.6}, load=0.25, pressure={0.1,0.2}, coverage=1.0, clip=wash})

--@ chunk 10
print(wait(24*60))
local SX, SY = 935, 90
local PANE_R = GLASS * poly({{770,34},{1000,34},{1000,390},{702,390}})
local nearR = NEAR * PANE_R
local tg = function(x,y) return math.atan(y-SY, x-SX) + 1.5708 end
-- taper the glare's toothed edge into the sky
local edge = (ellipse(SX, SY, 215, 215) - ellipse(SX, SY, 150, 150)) * PANE_R - nearR - STRUT_R:grow(1)
work(edge, {hand="body", tool={kind="filbert", width=5}, pile=pile{{"ultramarine blue",0.8},{"lead white",0.6},{"bone black",0.35},{"Mars orange",0.1}}, coverage=4, fill=true, clip=edge, angle=tg})
blend((ellipse(SX, SY, 225, 225) - ellipse(SX, SY, 130, 130)) * PANE_R - nearR - STRUT_R:grow(1), {angle=tg, tool={kind="badger", width=14}})
-- the streaks on the hull back to lit bronze
local hz = ellipse(SX, SY, 270, 270) * nearR
work(hz, {hand="body", tool={kind="filbert", width=5}, pile=pile{{"yellow ochre",1},{"raw sienna",0.5},{"lead white",0.45},{"burnt sienna",0.2}}, coverage=4, fill=true, clip=hz, angle=function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end})

--@ chunk 11
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
-- scales back over the repainted sunward hull
local face = NEAR - RIM
local zone = ellipse(935, 90, 270, 270) * face
local bD = brush{kind="round", width=1.3, point=0.5}
local bL = brush{kind="round", width=1.0, point=0.7}
local LD = pile{{"burnt sienna",1},{"bone brown",0.6},{"bone black",0.3}}
local LL = pile{{"lead white",1.4},{"cadmium yellow",0.5},{"yellow ochre",0.3}}
local d, row, n = 4, 0, 0
while d < 200 do
  local h = 2.2 + d*0.07
  local w = h*2.8
  local x = 700 + ((row*0.37) % 1)*w
  while x < 1000 do
    local y = ytop(x) + d
    if zone:at(x, y) > 0.5 then
      local t = math.atan(y - 900, x - 420) + 1.5708
      local ct, st = math.cos(t), math.sin(t)
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; local ox, oy = a*w*0.5, h*(1 - a*a); pts[#pts+1] = {x + ox*ct - oy*st, y + ox*st + oy*ct}; lit[#lit+1] = {x + ox*ct - (oy-1.1)*st, y + ox*st + (oy-1.1)*ct} end
      if n % 8 == 0 then bD:load(LD, 0.8); bL:load(LL, 0.6) end
      bD:stroke(pts, {pressure={0.3 + h*0.02, 0.2}})
      bL:stroke({lit[4], lit[5], lit[6], lit[7]}, {pressure={0.35, 0.05}})
      n = n + 1
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
-- a strip of worn crimson cloth knotted round the left strut, its tails hanging
local CR = pile{{"cadmium red",0.6},{"rose madder",1},{"bone black",0.35}}
local CRL = pile{{"vermilion",1},{"rose madder",0.5},{"lead white",0.25}}
local CRD = pile{{"rose madder",1},{"bone black",1}}
local knot = poly({{283,150},{306,146},{311,166},{288,171}}, true)
fill(knot, CR, 2)
local t1 = poly({{292,168},{302,167},{298,205},{306,240},{296,262},{290,236},{287,204}}, true)
local t2 = poly({{301,166},{310,164},{318,198},{316,226},{309,222},{306,196}}, true)
fill(t1, CR, 2); fill(t2, CRD, 2)
local cb = brush{kind="round", width=1.4, point=0.5}
cb:reload(CRL, 0.8); cb:stroke({{288,172},{291,205},{294,238}}, {pressure={0.45,0.2}})
cb:reload(CRL, 0.7); cb:stroke({{285,152},{300,149}}, {pressure={0.45,0.3}})
local fr = brush{kind="round", width=0.8, point=0.7}
for k=0,4 do fr:reload(CR, 0.7); fr:stroke({{291 + k*1.5, 258}, {290 + k*1.8, 266 + (k%2)*3}}, {pressure={0.35,0.05}}) end
-- a small bone cross hanging on a cord from the top frame, swung out of true
local cord = brush{kind="round", width=0.9, point=0.6}
cord:reload(pile{{"bone brown",1},{"bone black",0.4}}, 0.8); cord:stroke({{520,34},{528,72},{534,108}}, {pressure={0.4,0.4}})
local BONE = pile{{"lead white",1.3},{"yellow ochre",0.4},{"raw sienna",0.15}}
local BONED = pile{{"yellow ochre",1},{"raw sienna",0.6},{"bone brown",0.4}}
local function rot(px, py, a, ox, oy) local c, s = math.cos(a), math.sin(a); return {ox + px*c - py*s, oy + px*s + py*c} end
local a = -0.25
local ox, oy = 535, 108
local vbar = poly({rot(-3,0,a,ox,oy), rot(3,0,a,ox,oy), rot(3,34,a,ox,oy), rot(-3,34,a,ox,oy)})
local hbar = poly({rot(-12,8,a,ox,oy), rot(12,8,a,ox,oy), rot(12,14,a,ox,oy), rot(-12,14,a,ox,oy)})
fill(vbar + hbar, BONED, 1.2)
local lb = brush{kind="round", width=1.3, point=0.5}
local p1, p2 = rot(-2,1,a,ox,oy), rot(-2,33,a,ox,oy)
lb:reload(BONE, 0.85); lb:stroke({p1, p2}, {pressure={0.5,0.4}})
local p3, p4 = rot(-11,9,a,ox,oy), rot(11,9,a,ox,oy)
lb:reload(BONE, 0.85); lb:stroke({p3, p4}, {pressure={0.5,0.4}})
-- a faint motion trail: its last swing
local tr = brush{kind="round", width=3, point=0.3}
tr:reload(pile{{"lead white",1},{"yellow ochre",0.3},medium=0.6}, 0.25); tr:stroke({rot(0,30,a-0.35,529,72), rot(0,30,a-0.15,529,72), rot(0,30,a,529,72)}, {pressure={0.1,0.25}})

--@ chunk 12
print(wait(24*60))
-- the hull falls darker toward us (it is lit from behind); a dark band above the sill
local face = NEAR - RIM - STRUT_L - STRUT_R
local low = face * mask(function(x,y) return (y > 330) and 1 or 0 end)
work(low, {hand="scumble", tool={kind="filbert", width=6}, pile=pile{{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.6}}, coverage=1.3, load=0.45, pressure={0.2,0.45}, clip=low, angle=0})
blend(face * rect(0, 318, 1000, 28), {angle=0, tool={kind="badger", width=10}})
-- amber screen-glow spilling onto the panel
local GLO = pile{{"Mars orange",1},{"bone brown",0.8},{"bone black",0.4}}
for _,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do
  local m = rect(s[1]-10, s[2]+s[4]+4, s[3]+20, 16) * poly({{60,430},{940,430},{1000,562},{0,562}})
  work(m, {hand="scumble", tool={kind="filbert", width=4}, pile=GLO, coverage=1.0, load=0.3, pressure={0.12,0.3}, clip=m, angle=0})
end
-- amber glints on the inner faces of the struts and sill
local g = brush{kind="round", width=1.6, point=0.4}
g:reload(pile{{"Mars orange",1},{"cadmium yellow",0.5}}, 0.6); g:stroke({{318,398},{300,300}}, {pressure={0.35,0.0}})
g:reload(pile{{"Mars orange",1},{"cadmium yellow",0.5}}, 0.6); g:stroke({{676,398},{692,300}}, {pressure={0.35,0.0}})
g:reload(pile{{"Mars orange",1},{"bone brown",0.4}}, 0.6); g:stroke({{60,419},{940,419}}, {pressure={0.4,0.4}})

--@ chunk 13
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
local face = NEAR - RIM - STRUT_L - STRUT_R
local ang = function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end
-- a proper graded fall-off toward us, opaque, in three bands, seams fused
local Bd = {
  {300, 335, pile{{"burnt sienna",1},{"bone brown",0.6},{"yellow ochre",0.3},{"bone black",0.25}}},
  {335, 365, pile{{"bone brown",1},{"burnt sienna",0.7},{"bone black",0.4}}},
  {365, 400, pile{{"bone brown",1},{"bone black",0.7},{"burnt sienna",0.4}}},
}
for _,b in ipairs(Bd) do
  local m = face * rect(0, b[1], 1000, b[2]-b[1])
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=b[3], coverage=4.2, fill=true, clip=m, angle=ang, length={20,60}})
end
blend(face * (rect(0, 290, 1000, 20) + rect(0, 326, 1000, 18) + rect(0, 356, 1000, 18)), {angle=0, tool={kind="badger", width=8}})
-- panel strips back to panel
local PAN = pile{{"bone black",1.4},{"ultramarine ash",0.5},{"bone brown",0.3},{"lead white",0.08}}
for _,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do
  fill(rect(s[1]-12, s[2]+s[4]+3, s[3]+24, 20) * poly({{60,430},{940,430},{1000,562},{0,562}}), PAN, 3)
end

--@ chunk 14
print(wait(2*24*60))
-- dim scale lips in the shadowed band
local face = NEAR - RIM - STRUT_L - STRUT_R
local zone = face * rect(0, 300, 1000, 100)
local bD = brush{kind="round", width=1.8, point=0.5}
local bL = brush{kind="round", width=1.2, point=0.7}
local LD = pile{{"bone black",1.4},{"bone brown",0.5}}
local LL = pile{{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.15}}
local d, row, n = 4, 0, 0
while d < 260 do
  local h = 2.2 + d*0.07
  local w = h*2.8
  local x = -20 + ((row*0.37) % 1)*w
  while x < 1010 do
    local y = ytop(x) + d
    if zone:at(x, y) > 0.5 then
      local t = math.atan(y - 900, x - 420) + 1.5708
      local ct, st = math.cos(t), math.sin(t)
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; local ox, oy = a*w*0.5, h*(1 - a*a); pts[#pts+1] = {x + ox*ct - oy*st, y + ox*st + oy*ct}; lit[#lit+1] = {x + ox*ct - (oy-1.2)*st, y + ox*st + (oy-1.2)*ct} end
      if n % 8 == 0 then bD:load(LD, 0.8); bL:load(LL, 0.5) end
      bD:stroke(pts, {pressure={0.4, 0.3}})
      if x > 450 then bL:stroke({lit[5], lit[6], lit[7]}, {pressure={0.25, 0.05}}) end
      n = n + 1
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
-- the HUD again over all of it
local CY = pile{{"cerulean blue",1},{"zinc white",1.2},{"viridian",0.2}}
local h = brush{kind="round", width=1.4, point=0.4}
local clipg = GLASS - STRUT_L - STRUT_R
local cx, cy = 478, 303
local function br(pts) h:reload(CY, 0.8); h:stroke(pts, {pressure={0.45,0.45}, clip=clipg}) end
br({{cx-58, cy-30}, {cx-58, cy-44}, {cx-44, cy-44}}); br({{cx+44, cy-44}, {cx+58, cy-44}, {cx+58, cy-30}})
br({{cx-58, cy+30}, {cx-58, cy+44}, {cx-44, cy+44}}); br({{cx+44, cy+44}, {cx+58, cy+44}, {cx+58, cy+30}})
br({{cx-12, cy}, {cx-4, cy}}); br({{cx+4, cy}, {cx+12, cy}}); br({{cx, cy-12}, {cx, cy-4}}); br({{cx, cy+4}, {cx, cy+12}})
local pts3 = {}
for k=0,24 do local a = 2*math.pi*k/24; pts3[#pts3+1] = {cx + 34*math.cos(a), cy + 34*math.sin(a)} end
h:reload(CY, 0.6); h:stroke(pts3, {pressure={0.25,0.25}, clip=clipg})
local g = brush{kind="round", width=1.3, point=0.4}
local function glyph(x, y, segs) for _,s in ipairs(segs) do g:reload(CY, 0.8); g:stroke({{x + s[1], y + s[2]}, {x + s[3], y + s[4]}}, {pressure={0.45,0.45}}) end end
local rx, ry = cx + 70, cy + 34
glyph(rx, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0}})
g:reload(CY, 0.8); g:touch(rx + 12, ry + 12, {pressure=0.5})
glyph(rx + 16, ry, {{0,0,0,7},{0,7,8,7},{6,0,6,12}})
glyph(rx + 28, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0},{0,6,8,6}})
glyph(rx + 42, ry, {{0,6,6,6},{0,8,6,8}})
for k=0,2 do glyph(cx - 4, cy + 52 + k*9, {{0,0,4,4},{4,4,8,0}}) end

--@ chunk 15
print(wait(24*60))
local P = poly({{452,288},{500,283},{514,302},{502,322},{458,325},{445,306}}, true)
local m = P - ribbon({{466,303},{474,303}}, 2) - ribbon({{482,303},{490,303}}, 2) - ribbon({{478,291},{478,299}}, 2) - ribbon({{478,307},{478,315}}, 2) - (ellipse(478,303,35,35) - ellipse(478,303,33,33))
work(m, {hand="detail", tool={kind="filbert", width=2}, pile=pile{{"bone black",1.2},{"burnt sienna",0.6},{"bone brown",0.5}}, coverage=4.5, fill=true, clip=m})
local e = brush{kind="round", width=1.1, point=0.5}
e:reload(pile{{"yellow ochre",1},{"lead white",0.7}}, 0.7); e:stroke({{500,284},{514,302},{503,321}}, {pressure={0.45,0.25}})

--@ chunk 16
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
SX2, SY2 = 958, 88
KEEP = STRUT_L:grow(1) + STRUT_R:grow(1) + rect(276,140,48,135) + rect(512,34,40,115)
SKY = GLASS - NEAR:grow(0.5) - FAR2:grow(0.5) - KEEP
-- space: near-black, a faint deep-blue haze only toward the Sun
local function r(x,y) return math.sqrt((x-SX2)^2 + ((y-SY2)*1.2)^2) end
local K = {
  {0, 120, pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.12},{"cobalt blue",0.2}}},
  {120, 260, pile{{"ultramarine blue",1},{"bone black",1.6},{"lead white",0.03}}},
  {260, 9999, pile{{"bone black",2},{"ultramarine blue",0.6}}},
}
for _,k in ipairs(K) do
  local m = SKY * mask(function(x,y) local v = r(x,y); return (v >= k[1] and v < k[2]) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=8}, pile=k[3], coverage=4.2, fill=true, clip=SKY, angle=function(x,y) return math.atan(y-SY2, x-SX2) + 1.5708 end, length={30,90}}) end
end
blend(SKY * mask(function(x,y) local v = r(x,y); return (math.abs(v-120) < 25 or math.abs(v-260) < 30) and 1 or 0 end), {angle=function(x,y) return math.atan(y-SY2, x-SX2) + 1.5708 end, tool={kind="badger", width=12}})
-- the cockpit interior and panel, darker
local IN = pile{{"bone black",2.2},{"ultramarine blue",0.25},{"burnt sienna",0.15}}
local PANM = poly({{60,430},{940,430},{1000,562},{0,562}})
local SCRS = rect(112,445,166,80) + rect(322,440,166,72) + rect(512,440,166,72) + rect(722,445,166,80)
fill(PANM - SCRS, IN, 5)
-- screens: dark glass
local GL = pile{{"bone black",1.6},{"bone brown",0.5},{"Mars orange",0.15}}
for _,s in ipairs({{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}) do fill(rect(s[1], s[2], s[3], s[4]), GL, 2) end
-- the hull's shadow side, darker
local face = NEAR - RIM - KEEP
local function z(x,y) return x + (y - ytop(x))*0.6 end
local ang = function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end
local hud = ellipse(478, 303, 105, 75)
local D = {
  {-999, 260, pile{{"bone black",1.2},{"bone brown",0.8},{"burnt sienna",0.3}}},
  {260, 460, pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.5}}},
}
for _,d in ipairs(D) do
  local m = face * mask(function(x,y) local v = z(x,y); return (v >= d[1] and v < d[2]) and 1 or 0 end) - hud
  work(m, {hand="body", tool={kind="filbert", width=6}, pile=d[3], coverage=4.2, fill=true, clip=m, angle=ang, length={20,60}})
end
blend(face * mask(function(x,y) local v = z(x,y); return (math.abs(v-260) < 25 or math.abs(v-460) < 30) and 1 or 0 end) - hud, {angle=ang, tool={kind="badger", width=10}})

--@ chunk 17
print(wait(24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
-- rebuild the masks of the cloth and the cross so the leftover boxes can be filled round them
local cloth = poly({{283,150},{306,146},{311,166},{288,171}}, true) + poly({{292,168},{302,167},{298,205},{306,240},{296,262},{290,236},{287,204}}, true) + poly({{301,166},{310,164},{318,198},{316,226},{309,222},{306,196}}, true)
local function rot(px, py, a, ox, oy) local c, s = math.cos(a), math.sin(a); return {ox + px*c - py*s, oy + px*s + py*c} end
local a, ox, oy = -0.25, 535, 108
local cross = poly({rot(-3,0,a,ox,oy), rot(3,0,a,ox,oy), rot(3,34,a,ox,oy), rot(-3,34,a,ox,oy)}) + poly({rot(-12,8,a,ox,oy), rot(12,8,a,ox,oy), rot(12,14,a,ox,oy), rot(-12,14,a,ox,oy)}) + ribbon({{520,34},{528,72},{534,108}}, 2.5)
local protect = cloth:grow(1.2) + cross:grow(1.2) + STRUT_L:grow(0.5) + STRUT_R:grow(0.5)
local boxes = (rect(276,140,48,135) + rect(512,34,40,115)) * GLASS - protect
local SKYD = pile{{"bone black",2},{"ultramarine blue",0.6}}
local HULLD = pile{{"bone black",1.2},{"bone brown",0.8},{"burnt sienna",0.3}}
fill(boxes - NEAR - FAR2, SKYD, 2)
fill(boxes * NEAR, HULLD, 2)
fill(boxes * FAR2, pile{{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.6}}, 1.5)
-- the hull round the HUD into the same shadow, graded
local face = NEAR - RIM - protect
local hud = ellipse(478, 303, 105, 75) * face
local HM = pile{{"bone brown",1},{"bone black",0.6},{"burnt sienna",0.5}}
work(hud, {hand="body", tool={kind="filbert", width=5}, pile=HM, coverage=4.2, fill=true, clip=hud, angle=function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end})
blend(face * (ellipse(478, 303, 120, 88) - ellipse(478, 303, 92, 64)), {tool={kind="badger", width=10}})
-- sky deeper all round; the haze kept tight to the Sun
local SKY2 = GLASS - NEAR:grow(0.5) - FAR2:grow(0.5) - protect
local function r(x,y) return math.sqrt((x-SX2)^2 + ((y-SY2)*1.2)^2) end
local mid = SKY2 * mask(function(x,y) local v = r(x,y); return (v >= 70 and v < 300) and 1 or 0 end)
work(mid, {hand="body", tool={kind="filbert", width=7}, pile=pile{{"bone black",2},{"ultramarine blue",0.7}}, coverage=4.2, fill=true, clip=mid, angle=function(x,y) return math.atan(y-SY2, x-SX2) + 1.5708 end})
blend(SKY2 * mask(function(x,y) local v = r(x,y); return (math.abs(v-70) < 22) and 1 or 0 end), {angle=function(x,y) return math.atan(y-SY2, x-SX2) + 1.5708 end, tool={kind="badger", width=10}})
-- the far ring near the Sun: bronze again, not glare-white
local fz = FAR2 * rect(720, 0, 300, 140) - protect
fill(fz, pile{{"bone brown",1},{"burnt sienna",0.7},{"bone black",0.4}}, 1.5)

--@ chunk 18
print(wait(2*24*60))
-- dim scale lips back into the shadowed hull, and the HUD redrawn
local face = NEAR - RIM - STRUT_L:grow(0.5) - STRUT_R:grow(0.5) - rect(276,140,48,135)
local zone = face * mask(function(x,y) return ((x + (y - ytop(x))*0.6) < 470 or ((x-478)/105)^2 + ((y-303)/75)^2 < 1) and 1 or 0 end)
local bD = brush{kind="round", width=1.5, point=0.5}
local bL = brush{kind="round", width=1.0, point=0.7}
local LD = pile{{"bone black",1.6},{"bone brown",0.4}}
local LL = pile{{"burnt sienna",1},{"bone brown",0.6},{"yellow ochre",0.2}}
local d, row, n = 4, 0, 0
while d < 260 do
  local h = 2.2 + d*0.07
  local w = h*2.8
  local x = -20 + ((row*0.37) % 1)*w
  while x < 1010 do
    local y = ytop(x) + d
    if zone:at(x, y) > 0.5 then
      local t = math.atan(y - 900, x - 420) + 1.5708
      local ct, st = math.cos(t), math.sin(t)
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; local ox, oy = a*w*0.5, h*(1 - a*a); pts[#pts+1] = {x + ox*ct - oy*st, y + ox*st + oy*ct}; lit[#lit+1] = {x + ox*ct - (oy-1.1)*st, y + ox*st + (oy-1.1)*ct} end
      if n % 8 == 0 then bD:load(LD, 0.8); bL:load(LL, 0.5) end
      bD:stroke(pts, {pressure={0.35 + h*0.015, 0.25}})
      bL:stroke({lit[5], lit[6], lit[7]}, {pressure={0.18, 0.04}})
      n = n + 1
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
local m = poly({{452,288},{500,283},{514,302},{502,322},{458,325},{445,306}}, true)
work(m, {hand="detail", tool={kind="filbert", width=2}, pile=pile{{"bone black",1.4},{"burnt sienna",0.4},{"bone brown",0.5}}, coverage=4.5, fill=true, clip=m})
local e = brush{kind="round", width=1.1, point=0.5}
e:reload(pile{{"yellow ochre",1},{"burnt sienna",0.6}}, 0.7); e:stroke({{500,284},{514,302},{503,321}}, {pressure={0.45,0.25}})
print(n)

--@ chunk 19
print(wait(24*60))
-- the HUD again
local CY = pile{{"cerulean blue",1},{"zinc white",1.2},{"viridian",0.2}}
local h = brush{kind="round", width=1.4, point=0.4}
local clipg = GLASS - STRUT_L - STRUT_R
local cx, cy = 478, 303
local function br(pts) h:reload(CY, 0.8); h:stroke(pts, {pressure={0.45,0.45}, clip=clipg}) end
br({{cx-58, cy-30}, {cx-58, cy-44}, {cx-44, cy-44}}); br({{cx+44, cy-44}, {cx+58, cy-44}, {cx+58, cy-30}})
br({{cx-58, cy+30}, {cx-58, cy+44}, {cx-44, cy+44}}); br({{cx+44, cy+44}, {cx+58, cy+44}, {cx+58, cy+30}})
br({{cx-12, cy}, {cx-4, cy}}); br({{cx+4, cy}, {cx+12, cy}}); br({{cx, cy-12}, {cx, cy-4}}); br({{cx, cy+4}, {cx, cy+12}})
local pts3 = {}
for k=0,24 do local a = 2*math.pi*k/24; pts3[#pts3+1] = {cx + 34*math.cos(a), cy + 34*math.sin(a)} end
h:reload(CY, 0.6); h:stroke(pts3, {pressure={0.25,0.25}, clip=clipg})
local g = brush{kind="round", width=1.3, point=0.4}
local function glyph(x, y, segs) for _,s in ipairs(segs) do g:reload(CY, 0.8); g:stroke({{x + s[1], y + s[2]}, {x + s[3], y + s[4]}}, {pressure={0.45,0.45}}) end end
local rx, ry = cx + 70, cy + 34
glyph(rx, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0}})
g:reload(CY, 0.8); g:touch(rx + 12, ry + 12, {pressure=0.5})
glyph(rx + 16, ry, {{0,0,0,7},{0,7,8,7},{6,0,6,12}})
glyph(rx + 28, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0},{0,6,8,6}})
glyph(rx + 42, ry, {{0,6,6,6},{0,8,6,8}})
for k=0,2 do glyph(cx - 4, cy + 52 + k*9, {{0,0,4,4},{4,4,8,0}}) end

--@ chunk 20
print(wait(24*60))
local cloth = poly({{283,150},{306,146},{311,166},{288,171}}, true) + poly({{292,168},{302,167},{298,205},{306,240},{296,262},{290,236},{287,204}}, true) + poly({{301,166},{310,164},{318,198},{316,226},{309,222},{306,196}}, true)
PROT = cloth:grow(1.2) + STRUT_L:grow(0.5) + STRUT_R:grow(0.5)
FACE = NEAR - RIM - PROT
local ang = function(x,y) return math.atan(y - 900, x - 420) + 1.5708 end
local function z(x,y) return x - 0.3*(y - ytop(x)) end
local B = {
  {-999, 260, pile{{"bone black",1.3},{"bone brown",0.8},{"burnt sienna",0.25}}},
  {260, 450, pile{{"bone brown",1},{"bone black",0.7},{"burnt sienna",0.45}}},
  {450, 600, pile{{"burnt sienna",1},{"bone brown",0.7},{"bone black",0.35},{"yellow ochre",0.15}}},
  {600, 740, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"bone brown",0.3},{"bone black",0.1}}},
  {740, 860, pile{{"yellow ochre",1},{"burnt sienna",0.5},{"raw sienna",0.4}}},
  {860, 2000, pile{{"yellow ochre",1},{"cadmium yellow",0.3},{"lead white",0.35},{"raw sienna",0.3}}},
}
for _,b in ipairs(B) do
  local m = FACE * mask(function(x,y) local v = z(x,y); return (v >= b[1] and v < b[2]) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=6}, pile=b[3], coverage=4.3, fill=true, clip=m, angle=ang, length={20,60}}) end
end
blend(FACE * mask(function(x,y) local v = z(x,y); for _,c in ipairs({260,450,600,740,860}) do if math.abs(v-c) < 22 then return 1 end end return 0 end), {angle=ang, tool={kind="badger", width=10}})

--@ chunk 21
print(wait(2*24*60))
local function z(x,y) return x - 0.3*(y - ytop(x)) end
local bD = brush{kind="round", width=1.4, point=0.5}
local bL = brush{kind="round", width=1.0, point=0.7}
local LD = pile{{"bone black",1.5},{"bone brown",0.5}}
local LLd = pile{{"burnt sienna",1},{"bone brown",0.5},{"yellow ochre",0.3}}
local LLm = pile{{"yellow ochre",1},{"burnt sienna",0.4},{"lead white",0.2}}
local LLh = pile{{"lead white",1.4},{"cadmium yellow",0.6},{"yellow ochre",0.3}}
local d, row, n = 4, 0, 0
while d < 260 do
  local h = 2.2 + d*0.07
  local w = h*2.8
  local x = -20 + ((row*0.37) % 1)*w
  while x < 1010 do
    local y = ytop(x) + d
    if FACE:at(x, y) > 0.5 then
      local v = z(x, y)
      local t = math.atan(y - 900, x - 420) + 1.5708
      local ct, st = math.cos(t), math.sin(t)
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; local ox, oy = a*w*0.5, h*(1 - a*a); pts[#pts+1] = {x + ox*ct - oy*st, y + ox*st + oy*ct}; lit[#lit+1] = {x + ox*ct - (oy-1.1)*st, y + ox*st + (oy-1.1)*ct} end
      bD:reload(LD, 0.7)
      bD:stroke(pts, {pressure={0.32 + h*0.015, 0.22}})
      local lp, pr = LLd, 0.15
      if v > 600 then lp, pr = LLm, 0.28 end
      if v > 800 then lp, pr = LLh, 0.4 end
      if v > 300 then bL:reload(lp, 0.6); bL:stroke({lit[4], lit[5], lit[6], lit[7]}, {pressure={pr, 0.04}}) end
      n = n + 1
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
local m = poly({{452,288},{500,283},{514,302},{502,322},{458,325},{445,306}}, true)
work(m, {hand="detail", tool={kind="filbert", width=2}, pile=pile{{"bone black",1.5},{"burnt sienna",0.3},{"bone brown",0.5}}, coverage=4.5, fill=true, clip=m})
local e = brush{kind="round", width=1.1, point=0.5}
e:reload(pile{{"yellow ochre",1},{"lead white",0.5}}, 0.7); e:stroke({{500,284},{514,302},{503,321}}, {pressure={0.45,0.25}})
print(n)

--@ chunk 22
print(wait(24*60))
-- the HUD: a cold cyan reticle projected round the target patch, with glyphs and a range
local CY = pile{{"cerulean blue",1},{"zinc white",1.2},{"viridian",0.2}}
local h = brush{kind="round", width=1.4, point=0.4}
local cx, cy = 478, 303
local function br(pts) h:reload(CY, 0.8); h:stroke(pts, {pressure={0.45,0.45}, clip=GLASS - STRUT_L - STRUT_R}) end
br({{cx-58, cy-30}, {cx-58, cy-44}, {cx-44, cy-44}})
br({{cx+44, cy-44}, {cx+58, cy-44}, {cx+58, cy-30}})
br({{cx-58, cy+30}, {cx-58, cy+44}, {cx-44, cy+44}})
br({{cx+44, cy+44}, {cx+58, cy+44}, {cx+58, cy+30}})
br({{cx-12, cy}, {cx-4, cy}}); br({{cx+4, cy}, {cx+12, cy}}); br({{cx, cy-12}, {cx, cy-4}}); br({{cx, cy+4}, {cx, cy+12}})
local pts3 = {}
for k=0,24 do local a = 2*math.pi*k/24; pts3[#pts3+1] = {cx + 34*math.cos(a), cy + 34*math.sin(a)} end
h:reload(CY, 0.6); h:stroke(pts3, {pressure={0.25,0.25}, clip=GLASS})
-- angular glyphs and the closing range
local g = brush{kind="round", width=1.3, point=0.4}
local function glyph(x, y, segs) for _,s in ipairs(segs) do g:reload(CY, 0.8); g:stroke({{x + s[1], y + s[2]}, {x + s[3], y + s[4]}}, {pressure={0.45,0.45}}) end end
local gx, gy = cx + 70, cy - 46
glyph(gx, gy, {{0,0,8,0},{8,0,4,10}}); glyph(gx + 13, gy, {{0,10,4,0},{4,0,8,10},{2,6,7,6}}); glyph(gx + 26, gy, {{0,0,0,10},{0,5,8,0},{0,5,8,10}})
glyph(gx, gy + 16, {{0,0,8,0},{0,0,0,10},{0,10,8,10}}); glyph(gx + 13, gy + 16, {{0,0,8,10},{8,0,0,10}})
-- range: "0.48" in block stencil
local rx, ry = cx + 70, cy + 34
glyph(rx, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0}})
g:reload(CY, 0.8); g:touch(rx + 12, ry + 12, {pressure=0.5})
glyph(rx + 16, ry, {{0,0,0,7},{0,7,8,7},{6,0,6,12}})
glyph(rx + 28, ry, {{0,0,8,0},{8,0,8,12},{8,12,0,12},{0,12,0,0},{0,6,8,6}})
glyph(rx + 42, ry, {{0,6,6,6},{0,8,6,8}})
-- a chevron ladder down to the patch
for k=0,2 do glyph(cx - 4, cy + 52 + k*9, {{0,0,4,4},{4,4,8,0}}) end

--@ chunk 23
print(wait(2*24*60))
local function fill(m, p, w) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end end
-- the Sun: a small hard disc with a crisp rim
local disc = ellipse(SX2, SY2, 17, 17) * GLASS
fill(disc, pile{{"zinc white",3},{"lemon chrome",0.15}}, 2)
local rim = brush{kind="round", width=1.2, point=0.5}
local pts = {}
for k=0,30 do local a = 2*math.pi*k/30; pts[#pts+1] = {SX2 + 17.5*math.cos(a), SY2 + 17.5*math.sin(a)} end
rim:reload(pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.15}}, 0.8); rim:stroke(pts, {pressure={0.4,0.4}, clip=GLASS})
-- thin long radial streaks across the scratched glass
local rr = brush{kind="rigger", width=1.0, point=1}
local W = pile{{"zinc white",3},{"lead white",1}}
for _,s in ipairs({{3.0, 330}, {2.62, 260}, {2.25, 180}, {3.4, 200}, {1.95, 120}, {4.0, 140}, {2.85, 120}, {1.6, 90}}) do
  rr:reload(W, 0.6)
  rr:stroke({{SX2 + 19*math.cos(s[1]), SY2 + 19*math.sin(s[1])}, {SX2 + s[2]*math.cos(s[1]), SY2 + s[2]*math.sin(s[1])}}, {pressure={0.35,0.0}, ramps={0.02,0.95}, clip=GLASS - KEEP})
end
-- the long flare line, thinner
rr:reload(W, 0.5); rr:stroke({{SX2 - 20, SY2 + 10}, {SX2 - 320, SY2 + 160}, {SX2 - 620, SY2 + 310}}, {pressure={0.22,0.0}, ramps={0.02,0.95}, clip=GLASS - KEEP})
-- scratches lit near the Sun
local sc = brush{kind="round", width=0.6, point=0.7}
for i=1,30 do
  local a = rand(1.4, 4.4); local rad = rand(26, 200)
  local x, y = SX2 + rad*math.cos(a), SY2 + rad*math.sin(a)
  if (GLASS - KEEP):at(x, y) > 0.5 then
    local t = a + 1.5708 + rand(-0.3, 0.3)
    local L = rand(6, 20) * (1 - rad/230)
    sc:reload(W, 0.5); sc:stroke({{x, y}, {x + L*math.cos(t), y + L*math.sin(t)}}, {pressure={0.22*(1 - rad/230) + 0.04, 0.02}})
  end
end
-- hot gold sunward edges of the ring
local HG = pile{{"lead white",1.4},{"cadmium yellow",0.8},{"chrome yellow",0.3}}
local eb = brush{kind="round", width=2.6, point=0.5}
local p1 = {}
for x=420,990,10 do p1[#p1+1] = {x, ytop(x) - 1.5} end
eb:reload(HG, 0.9); eb:stroke(p1, {pressure={0.05,0.75}, clip=GLASS - KEEP})
local p2 = {}
for x=640,1040,10 do local a = yfar2(x); if a then p2[#p2+1] = {x, a + 0.6} end end
local eb2 = brush{kind="round", width=1.8, point=0.5}
eb2:reload(HG, 0.8); eb2:stroke(p2, {pressure={0.05,0.6}, clip=GLASS - KEEP})
-- screens: amber line graphs, numerals, a ring schematic, glowing edges
local A = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.4}}
local AE = pile{{"Mars orange",1},{"cadmium yellow",0.4}}
local b = brush{kind="round", width=1.1, point=0.5}
local function ln(pts, pr) b:reload(A, 0.8); b:stroke(pts, {pressure={pr or 0.4, pr or 0.4}}) end
local S = {{120,455,150,62},{330,450,150,56},{520,450,150,56},{730,455,150,62}}
for _,s in ipairs(S) do
  local e = brush{kind="round", width=1.6, point=0.4}
  e:reload(AE, 0.7); e:stroke({{s[1]+1, s[2]+1}, {s[1]+s[3]-1, s[2]+1}, {s[1]+s[3]-1, s[2]+s[4]-1}, {s[1]+1, s[2]+s[4]-1}, {s[1]+1, s[2]+1}}, {pressure={0.35,0.35}})
end
-- 1: line graph closing in
local s = S[1]
ln({{128,507},{150,500},{170,503},{190,494},{210,489},{230,478},{252,470},{262,464}})
ln({{128,510},{262,510}}, 0.25); ln({{130,462},{130,510}}, 0.25)
-- 2: numerals in blocks
local nb = brush{kind="round", width=1.2, point=0.4}
local function dig(x, y, segs) for _,q in ipairs(segs) do nb:reload(A, 0.8); nb:stroke({{x+q[1], y+q[2]}, {x+q[3], y+q[4]}}, {pressure={0.45,0.45}}) end end
local ZERO = {{0,0,7,0},{7,0,7,12},{7,12,0,12},{0,12,0,0}}
local FOUR = {{0,0,0,7},{0,7,7,7},{5,0,5,12}}
local EIGHT = {{0,0,7,0},{7,0,7,12},{7,12,0,12},{0,12,0,0},{0,6,7,6}}
local ONE = {{4,0,4,12}}
dig(340, 460, ZERO); nb:reload(A, 0.8); nb:touch(350, 472, {pressure=0.4}); dig(354, 460, FOUR); dig(366, 460, EIGHT)
dig(340, 482, ONE); dig(350, 482, EIGHT); dig(362, 482, ZERO); dig(374, 482, FOUR)
for r=0,3 do ln({{395, 462 + r*11}, {395 + rand(30, 75), 462 + r*11}}, 0.3) end
-- 3: the ring, small, with a target tick on it
local pts = {}
for k=0,30 do local a = 2*math.pi*k/30; pts[#pts+1] = {595 + 34*math.cos(a), 478 + 13*math.sin(a)} end
ln(pts, 0.4)
ln({{595, 465}, {595, 491}}, 0.3)
nb:reload(pile{{"zinc white",1},{"cadmium yellow",0.5}}, 0.9); nb:touch(624, 485, {pressure=0.6})
ln({{624, 485}, {640, 498}, {660, 498}}, 0.3)
-- 4: bar graph and a waveform
for k=0,6 do b:reload(A, 0.8); local x = 742 + k*9; b:stroke({{x, 510}, {x, 510 - rand(6, 30)}}, {pressure={0.75,0.75}}) end
local wv = {}
for k=0,30 do local x = 810 + k*2.2; wv[#wv+1] = {x, 485 + 9*math.sin(k*0.8)*math.exp(-k/18)} end
ln(wv, 0.35)

--@ chunk 24
print(wait(24*60))
local SX3, SY3 = 918, 92
local G = GLASS - STRUT_R:grow(0.5)
-- a faint deep-blue haze held close round it
local hz = (ellipse(SX3, SY3, 48, 48) - ellipse(SX3, SY3, 15, 15)) * G
work(hz, {hand="scumble", tool={kind="filbert", width=3}, pile=pile{{"ultramarine blue",1},{"cobalt blue",0.4},{"lead white",0.4}}, coverage=1.2, load=0.3, pressure={0.12,0.3}, clip=hz})
blend(ellipse(SX3, SY3, 54, 54) * G - ellipse(SX3, SY3, 15, 15), {angle=function(x,y) return math.atan(y-SY3, x-SX3) + 1.5708 end, tool={kind="badger", width=6}})
print(wait(24*60))
work(ellipse(SX3, SY3, 13, 13) * G, {hand="detail", tool={kind="round", width=1.6}, pile=pile{{"zinc white",3},{"lemon chrome",0.12}}, coverage=5, fill=true, clip=true})
local rim = brush{kind="round", width=1.1, point=0.5}
local pts = {}
for k=0,30 do local a = 2*math.pi*k/30; pts[#pts+1] = {SX3 + 13.6*math.cos(a), SY3 + 13.6*math.sin(a)} end
rim:reload(pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.2}}, 0.8); rim:stroke(pts, {pressure={0.4,0.4}, clip=G})
local rr = brush{kind="rigger", width=0.9, point=1}
for _,s in ipairs({{3.05, 260}, {2.5, 170}, {3.55, 150}, {1.9, 110}, {4.3, 90}, {0.2, 30}, {1.2, 60}}) do
  rr:reload(pile{{"zinc white",3},{"lead white",1}}, 0.6)
  rr:stroke({{SX3 + 15*math.cos(s[1]), SY3 + 15*math.sin(s[1])}, {SX3 + s[2]*math.cos(s[1]), SY3 + s[2]*math.sin(s[1])}}, {pressure={0.35,0.0}, ramps={0.02,0.95}, clip=G})
end

--@ chunk 25
print(wait(24*60))
local SX3, SY3 = 918, 92
local G = GLASS - STRUT_R:grow(0.5) - FAR2:grow(0.5) - NEAR
local tg = function(x,y) return math.atan(y-SY3, x-SX3) + 1.5708 end
local a = (ellipse(SX3, SY3, 26, 26) - ellipse(SX3, SY3, 14.5, 14.5)) * G
local b = (ellipse(SX3, SY3, 62, 62) - ellipse(SX3, SY3, 26, 26)) * G
work(a, {hand="detail", tool={kind="round", width=1.8}, pile=pile{{"ultramarine blue",1},{"bone black",1.1},{"lead white",0.1}}, coverage=5, fill=true, clip=a, angle=tg})
work(b, {hand="body", tool={kind="filbert", width=3}, pile=pile{{"bone black",2},{"ultramarine blue",0.6}}, coverage=5, fill=true, clip=b, angle=tg})
blend((ellipse(SX3, SY3, 32, 32) - ellipse(SX3, SY3, 20, 20)) * G, {angle=tg, tool={kind="badger", width=4}})
print(wait(24*60))
local rim = brush{kind="round", width=1.1, point=0.5}
local pts = {}
for k=0,30 do local t = 2*math.pi*k/30; pts[#pts+1] = {SX3 + 13.6*math.cos(t), SY3 + 13.6*math.sin(t)} end
rim:reload(pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.2}}, 0.8); rim:stroke(pts, {pressure={0.4,0.4}, clip=GLASS})
local rr = brush{kind="rigger", width=0.9, point=1}
for _,s in ipairs({{3.05, 260}, {2.5, 170}, {3.55, 150}, {1.9, 110}, {4.3, 90}, {0.2, 30}, {1.2, 60}, {2.8, 120}, {3.9, 70}}) do
  rr:reload(pile{{"zinc white",3},{"lead white",1}}, 0.6)
  rr:stroke({{SX3 + 15*math.cos(s[1]), SY3 + 15*math.sin(s[1])}, {SX3 + s[2]*math.cos(s[1]), SY3 + s[2]*math.sin(s[1])}}, {pressure={0.35,0.0}, ramps={0.02,0.95}, clip=GLASS - STRUT_R:grow(0.5)})
end

--@ chunk 26
local m = FAR2 * ellipse(918, 92, 75, 40) - ellipse(918, 92, 15, 15)
work(m, {hand="detail", tool={kind="round", width=1.6}, pile=pile{{"bone brown",1},{"burnt sienna",0.7},{"bone black",0.4}}, coverage=5, fill=true, clip=m, angle=0})
print(wait(24*60))
local p2 = {}
for x=840,905,5 do local a = yfar2(x); if a then p2[#p2+1] = {x, a + 0.6} end end
local eb = brush{kind="round", width=1.8, point=0.5}
eb:reload(pile{{"lead white",1.4},{"cadmium yellow",0.8},{"chrome yellow",0.3}}, 0.8); eb:stroke(p2, {pressure={0.4,0.6}, clip=GLASS - ellipse(918, 92, 14, 14)})
