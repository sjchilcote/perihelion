-- easel session "terminal_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=2299, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}, um=45, apply="brush", texture=0.35}}}
VP = {860, 265}
SC = {370, 229}
FLOOR = poly({{-40, 600}, {-40, 480}, {700, 480}, {835, 290}, {885, 290}, {1040, 600}})
SCEIL = poly({{700, -40}, {1040, -40}, {885, 240}, {835, 240}})
SLWALL = poly({{700, -40}, {835, 240}, {835, 290}, {700, 480}})
SRWALL = poly({{885, 240}, {1040, -40}, {1040, 600}, {885, 290}})
FAREND = poly({{835, 240}, {885, 240}, {885, 290}, {835, 290}})
FWALL = poly({{-40, -40}, {700, -40}, {700, 480}, {-40, 480}})
FL = pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.6},{"lead white",0.2}}
CP = pile{{"bone brown",1},{"bone black",0.9},{"raw sienna",0.3},{"lead white",0.12}}
SW = pile{{"raw sienna",0.7},{"bone brown",0.8},{"bone black",0.6},{"lead white",0.22}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR, {hand="body", pile=FL, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
work(SCEIL + SLWALL, {hand="body", pile=CP, coverage=3, fill=true, clip=SCEIL + SLWALL, angle=toVP, length={20, 50}, tool="filbert 9"})
work(SRWALL + FAREND, {hand="body", pile=SW, coverage=3, fill=true, clip=SRWALL + FAREND, angle=toVP, length={15, 40}, tool="filbert 8"})

WW = pile{{"raw sienna",0.8},{"bone brown",0.8},{"bone black",0.5},{"yellow ochre",0.2},{"lead white",0.3}}
work(FWALL, {hand="body", pile=WW, coverage=3, fill=true, clip=FWALL, angle=1.57, length={20, 50}, tool="filbert 9"})

--@ chunk 2
print(wait(4*24*60))
HOUS = rect(220, 100, 300, 340)
SHELF = poly({{236, 372}, {504, 372}, {532, 410}, {208, 410}})
SHELFF = poly({{208, 410}, {532, 410}, {532, 424}, {208, 424}})
SCREEN = rect(262, 140, 216, 178)
GG = {
 WW,
 pile{{"bone black",2},{"Mars red",0.15},{"rose madder",0.25},{"ultramarine blue",0.4},{"lead white",0.12}},
 pile{{"bone black",1.6},{"rose madder",0.35},{"Mars red",0.15},{"lead white",0.25}},
 pile{{"bone black",1.1},{"rose madder",0.35},{"Mars orange",0.1},{"lead white",0.45}},
}
local region = (FWALL + FLOOR) - HOUS:grow(0.5) - SHELF - SHELFF
local cells = {}
for y = 60, 566, 3.2 do for x = -4, 760, 3.4 do
  local xx, yy = x + rand(-1.3,1.3), y + rand(-1.3,1.3)
  if region:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx, dy = xx - SC[1], (yy - SC[2])*1.1
    local d = math.sqrt(dx*dx + dy*dy)
    if d < 360 then
      local t = 4.2 - d/80 + randn(0, 0.3)
      local i = clamp(math.floor(t + 0.5), 1, 4)
      if i > 1 or rand(0,1) < 0.5 then cells[#cells+1] = {x=xx, y=yy, i=i} end
    end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(GG[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(GG[i], 0.9) end
    local a = math.atan(c.y - SC[2], c.x - SC[1]) + randn(0, 0.05)
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=region})
  end
end end
print(#cells)
-- the housing: heavy gunmetal block, darker toward its outer edges
HM = pile{{"bone black",1.6},{"ultramarine blue",0.4},{"lead white",0.25},{"rose madder",0.05}}
work(HOUS, {hand="detail", pile=HM, coverage=4, fill=true, clip=HOUS, tool={kind="round", width=2.2}, length={4, 10}})
local SD = pile{{"bone black",2.2},{"ultramarine blue",0.3}}
work(SHELF + SHELFF, {hand="detail", pile=SD, coverage=4, fill=true, clip=SHELF + SHELFF, tool={kind="round", width=1.8}, length={3, 8}})
-- the screen: phosphor black
PB = pile{{"bone black",2},{"rose madder",0.25},{"ultramarine blue",0.25}}
work(SCREEN, {hand="detail", pile=PB, coverage=4.5, fill=true, clip=SCREEN, tool={kind="round", width=1.8}, length={3, 8}})

--@ chunk 3
print(wait(4*24*60))
HM2 = pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.1},{"rose madder",0.05}}
work(HOUS - SCREEN - SHELF - SHELFF, {hand="detail", pile=HM2, coverage=4.5, fill=true, clip=HOUS - SCREEN - SHELF - SHELFF, tool={kind="round", width=2.2}, length={4, 10}})
-- the floor under the terminal: green spill on the deck, graded from the wall foot
local FG = {
 FL,
 pile{{"bone black",2},{"Mars brown",0.3},{"rose madder",0.25},{"lead white",0.12}},
 pile{{"bone black",1.6},{"rose madder",0.35},{"Mars red",0.1},{"Mars brown",0.2},{"lead white",0.26}},
}
local fl = FLOOR * rect(-40, 478, 800, 130)
local cells = {}
for y = 478, 566, 2.8 do for x = -4, 760, 3.2 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  if fl:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx = (xx - SC[1])/320
    local dy = (yy - 480)/90
    local v = 2.6 - 2.2*math.sqrt(dx*dx + dy*dy*0.7) + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v + 0.5), 1, 3)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(FG[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(FG[i], 0.9) end
    local h = rand(4, 8)
    b:stroke({{c.x - h, c.y}, {c.x + h, c.y}}, {pressure={0.75, 0.6}, clip=fl})
  end
end end
print(#cells)

--@ chunk 4
print(wait(4*24*60), drying(370,229))
local glow = ellipse(370, 229, 100, 82):soften(25) * SCREEN
local PGl = pile{{"bone black",1.3},{"rose madder",0.3},{"ultramarine blue",0.15},{"lead white",0.25}}
work(glow, {hand="detail", pile=PGl, coverage=3, fill=true, clip=SCREEN, tool={kind="round", width=2}, length={3, 8}, angle=0})
blend(SCREEN:shrink(2), {angle=0, tool={kind="badger", width=8}, length={15, 30}})
-- the bezel: inner lip catching the phosphor light
local lip = SCREEN:grow(5) - SCREEN
local LG = pile{{"bone black",1.2},{"rose madder",0.3},{"Mars red",0.1},{"lead white",0.3}}
work(lip, {hand="detail", pile=LG, coverage=4, fill=true, clip=lip, tool={kind="round", width=1.2}, length={2, 5}})

--@ chunk 5
print(wait(4*24*60))
-- wall ribs on the frontal wall, their screen-side edges catching faint green near the terminal
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RG = pile{{"bone black",1.2},{"rose madder",0.3},{"Mars red",0.1},{"lead white",0.3}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local free = FWALL - HOUS:grow(2) - SHELF:grow(2) - SHELFF:grow(2)
for _, x in ipairs({40, 120, 196, 544, 620, 690}) do
  local rb = brush{kind="filbert", width=4, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({{x, -10}, {x, 478}}, {pressure={0.75, 0.75}, clip=free})
  local side = (x < SC[1]) and 2.4 or -2.4
  local near = math.abs(x - SC[1]) < 260
  local rl = brush{kind="rigger", width=0.9, point=1}
  rl:load(near and RG or RL, 0.85) rl:stroke({{x + side, 60}, {x + side, 470}}, {pressure={0.45, 0.45}, clip=free})
end
-- floor-wall joint and a rail
local e = brush{kind="filbert", width=3, stiffness=0.5}
e:load(RB, 0.9) e:stroke({{-40, 480}, {700, 480}}, {pressure={0.7, 0.7}})
-- vent left of the terminal: dark grille, frost on its rim
local vent = rect(70, 150, 112, 96)
work(vent, {hand="detail", pile=RB, coverage=4, fill=true, clip=vent, tool={kind="round", width=1.6}, length={3, 8}})
local sl = brush{kind="filbert", width=2.2, stiffness=0.5}
for y = 158, 240, 9 do sl:load(RL, 0.85) sl:stroke({{76, y}, {176, y}}, {pressure={0.6, 0.6}, clip=vent}) end
-- keyboard: rows of key caps on the shelf, a lit front edge
local KD = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"rose madder",0.1},{"lead white",0.15}}
local k = brush{kind="filbert", width=3.2, stiffness=0.6}
for row = 0, 3 do
  local y = 377 + row*8
  local t = (y - 372)/38
  local x0, x1 = 236 - 28*t + 8, 504 + 28*t - 8
  local x = x0
  while x < x1 - 8 do
    k:load(KD, 0.9) k:stroke({{x, y}, {x + 7, y}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, clip=SHELF})
    x = x + 11 + ((row % 2) * 0.5)
  end
end
-- green light on the shelf top near the screen and on the housing's inner faces
local SG = pile{{"lead white",1.2},{"rose madder",0.25},{"cadmium yellow",0.08},{"bone black",0.25}}
local r = brush{kind="rigger", width=1.0, point=1}
r:load(SG, 0.9) r:stroke({{236, 372.5}, {504, 372.5}}, {pressure={0.6, 0.6}})
r:load(SG, 0.9) r:stroke({{210, 410.5}, {530, 410.5}}, {pressure={0.4, 0.4}})
-- the red arrow, hand-painted on the wall, pointing at the terminal
local AR = pile{{"vermilion",1},{"cadmium red",0.6},{"bone black",0.35}}
local shaft = poly({{564, 262}, {664, 258}, {666, 274}, {565, 278}}, true):roughen(1.2, 8, 3)
local head = poly({{536, 270}, {570, 244}, {566, 296}}, false):roughen(1.2, 8, 4)
local arrow = (shaft + head) * FWALL
work(arrow, {hand="detail", pile=AR, coverage=4, fill=true, clip=arrow, tool={kind="round", width=1.6}, length={3, 8}, angle=0})
local dr = brush{kind="rigger", width=1.0, point=1}
for _, x in ipairs({590, 622, 648}) do dr:load(AR, 0.8) dr:stroke({{x, 276}, {x + 0.5, 276 + rand(8, 20)}}, {pressure={0.5, 0.1}}) end

local small = (poly({{566, 318}, {622, 316}, {623, 326}, {567, 328}}, true):roughen(1, 6, 13) + poly({{548, 323}, {570, 308}, {568, 338}}, false):roughen(1, 6, 14)) * FWALL
work(small, {hand="detail", pile=AR, coverage=4, fill=true, clip=small, tool={kind="round", width=1.2}, length={2, 6}, angle=0})
dr:load(AR, 0.9) dr:stroke({{604, 327}, {604.4, 340}}, {pressure={0.5, 0.1}})

--@ chunk 6
print(wait(4*24*60))
local GRN = pile{{"lead white",1.2},{"rose madder",0.25},{"cadmium yellow",0.08},{"bone black",0.25}}
local GRM = pile{{"bone black",1.2},{"rose madder",0.3},{"Mars red",0.1},{"lead white",0.3}}
-- key caps catching the screen light on their tops
local k = brush{kind="rigger", width=0.8, point=1}
for row = 0, 3 do
  local y = 377 + row*8 - 2
  local t = (y + 2 - 372)/38
  local x0, x1 = 236 - 28*t + 8, 504 + 28*t - 8
  local x = x0
  while x < x1 - 8 do
    local d = math.abs(x + 3.5 - SC[1]) / 160
    if rand(0,1) < 1.1 - d then k:load((d < 0.5) and GRN or GRM, 0.85) k:stroke({{x + 0.5, y}, {x + 6.5, y}}, {pressure={0.4, 0.4}, clip=SHELF}) end
    x = x + 11 + ((row % 2) * 0.5)
  end
end

--@ chunk 7
-- Pass 2.1: the housing face around the screen back to a dark squared casing
HM3 = pile{{"bone black",2},{"ultramarine blue",0.35},{"lead white",0.12}}
local face = HOUS - SCREEN - SHELF - SHELFF
work(face, {hand="detail", pile=HM3, coverage=5, fill=true, clip=face, tool={kind="round", width=2}, length={4, 10}, angle=0})
-- side corridor: a few ribs on the far wall and a floor line
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function rw(t, h) local x = 1040 + (885 - 1040)*t local yb = 600 + (290 - 600)*t local yt = -40 + (240 + 40)*t return {x, yb + (yt - yb)*h} end
local t = 0.1
while t < 0.95 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({rw(t, 0.02), rw(t, 0.98)}, {pressure={0.7, 0.7}, clip=SRWALL})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({rw(t + 0.005, 0.02), rw(t + 0.005, 0.98)}, {pressure={0.4, 0.4}, clip=SRWALL})
  t = t + 0.13*(1 - t*0.8)
end
local ED = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.22}}
local e = brush{kind="rigger", width=1.0, point=1}
e:load(ED, 0.8) e:stroke({{1040, 600}, {885, 290}}, {pressure={0.6, 0.2}})
e:load(ED, 0.8) e:stroke({{700, 480}, {835, 290}}, {pressure={0.6, 0.2}})
e:load(RB, 0.9) e:stroke({{835, 240}, {835, 290}, {885, 290}, {885, 240}}, {pressure={0.4, 0.4}})

--@ chunk 8
print(wait(6*24*60), drying(240,150), drying(370,229))
-- raised rim around the CRT: a squared lip, its inner edge catching green, outer edge dark
local RIM = SCREEN:grow(12) - SCREEN:grow(3)
local RM = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"rose madder",0.1},{"lead white",0.25}}
work(RIM, {hand="detail", pile=RM, coverage=4.5, fill=true, clip=RIM, tool={kind="round", width=1.6}, length={3, 8}, angle=0})
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local r = brush{kind="rigger", width=1.2, point=1}
-- casing panel seams and a raised outer border
local b = brush{kind="rigger", width=1.0, point=1}
local HL = pile{{"bone black",1.4},{"ultramarine blue",0.35},{"lead white",0.3}}
b:load(HL, 0.9) b:stroke({{228, 104}, {512, 104}}, {pressure={0.4, 0.4}})
b:load(JD, 0.9) b:stroke({{226, 346}, {514, 346}}, {pressure={0.5, 0.5}})
-- bolts at the corners and along the sides
local BO = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.4}}
local bt = brush{kind="round", width=2.2, point=0.3}
for _, p in ipairs({{236, 116}, {504, 116}, {236, 356}, {504, 356}, {236, 236}, {504, 236}, {370, 116}, {370, 356}}) do
  bt:load(JD, 0.9) bt:touch(p[1] + 0.8, p[2] + 0.8, {pressure=0.6})
  bt:load(BO, 0.9) bt:touch(p[1], p[2], {pressure=0.45})
end

--@ chunk 9
print(wait(6*24*60), drying(256,150))
-- a narrow soft green falloff on the rim and face, only a step lighter, blended along the rim
local G1 = pile{{"bone black",1.2},{"rose madder",0.3},{"Mars red",0.1},{"lead white",0.3}}
local G2 = pile{{"bone black",1.8},{"rose madder",0.2},{"ultramarine blue",0.2},{"lead white",0.15}}
local s = brush{kind="filbert", width=2.6, stiffness=0.5}
local function band(off, p, n)
  local x0, x1, y0, y1 = 262 - off, 478 + off, 140 - off, 318 + off
  for i = 0, n do
    local f = i/n
    s:load(p, 0.8) s:stroke({{x0 + (x1-x0)*f - 6, y0}, {x0 + (x1-x0)*f + 6, y0}}, {pressure={0.55, 0.55}})
    s:load(p, 0.8) s:stroke({{x0 + (x1-x0)*f - 6, y1}, {x0 + (x1-x0)*f + 6, y1}}, {pressure={0.55, 0.55}})
  end
  for i = 0, math.floor(n*0.8) do
    local f = i/math.floor(n*0.8)
    s:load(p, 0.8) s:stroke({{x0, y0 + (y1-y0)*f - 6}, {x0, y0 + (y1-y0)*f + 6}}, {pressure={0.55, 0.55}})
    s:load(p, 0.8) s:stroke({{x1, y0 + (y1-y0)*f - 6}, {x1, y0 + (y1-y0)*f + 6}}, {pressure={0.55, 0.55}})
  end
end
band(5, G1, 26)
band(9, G2, 26)
local rim = SCREEN:grow(12) - SCREEN:grow(3)
blend(rim, {angle=0, tool={kind="badger", width=5}, length={10, 20}})

--@ chunk 10
print(wait(6*24*60), drying(256,150))
-- curved CRT glass: a faint reflection streak at the upper left corner, and a soft darker vignette at the corners
local RF = pile{{"lead white",1},{"rose madder",0.2},{"bone black",0.3}}
local s = brush{kind="filbert", width=3, stiffness=0.4}
s:load(RF, 0.6) s:stroke({{270, 168}, {276, 152}, {292, 146}}, {pressure={0.1, 0.45, 0.1}, swell={0.3, 1, 0.3}, clip=SCREEN})
s:load(RF, 0.5) s:stroke({{272, 182}, {278, 164}}, {pressure={0.05, 0.3, 0.05}, clip=SCREEN})
local VD = pile{{"bone black",2},{"rose madder",0.2},{"ultramarine blue",0.2}}
local c = brush{kind="filbert", width=3, stiffness=0.4}
for _, q in ipairs({{{470, 146}, {478, 156}}, {{264, 308}, {272, 316}}, {{470, 316}, {478, 306}}}) do c:load(VD, 0.7) c:stroke(q, {pressure={0.4, 0.2}, clip=SCREEN}) end

--@ chunk 11
print(wait(12*24*60), drying(240,150), drying(256,150))
local face = HOUS - SCREEN:grow(12) - SHELF - SHELFF
work(face, {hand="detail", pile=HM3, coverage=5, fill=true, clip=face, tool={kind="round", width=1.8}, length={4, 10}, angle=0})
-- wall around the housing where the old halo spilled, back to wall dark
local ring = HOUS:grow(14) - HOUS - SHELF:grow(1) - SHELFF:grow(1)
work(ring * FWALL, {hand="detail", pile=GG[1], coverage=4.5, fill=true, clip=ring * FWALL, tool={kind="round", width=1.8}, length={4, 10}})

--@ chunk 12
print(wait(10*24*60), drying(240,150), drying(215,250))
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local HL = pile{{"bone black",1.3},{"ultramarine blue",0.35},{"lead white",0.32}}
local G2 = pile{{"bone black",1.6},{"rose madder",0.25},{"ultramarine blue",0.2},{"lead white",0.2}}
local b = brush{kind="rigger", width=1.1, point=1}
local function seg(p, a, c, pr) b:load(p, 0.9) b:stroke({a, c}, {pressure={pr, pr}, ramps={0.03, 0.03}}) end
-- casing: outer border, top edge catching faint light, a lower panel seam
seg(JD, {222, 102}, {518, 102}, 0.6) seg(JD, {518, 102}, {518, 370}, 0.6) seg(JD, {222, 370}, {518, 370}, 0.6) seg(JD, {222, 102}, {222, 370}, 0.6)
seg(HL, {224, 104.5}, {516, 104.5}, 0.4)
seg(JD, {226, 346}, {514, 346}, 0.5)
-- the raised rim around the CRT: outer edge dark, green falloff on its face (one step lighter)
seg(JD, {248, 126}, {492, 126}, 0.6) seg(JD, {492, 126}, {492, 332}, 0.6) seg(JD, {248, 332}, {492, 332}, 0.6) seg(JD, {248, 126}, {248, 332}, 0.6)
seg(G2, {251, 330}, {489, 330}, 0.5)
seg(G2, {489, 129}, {489, 329}, 0.4)
-- bolts
local BO = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"lead white",0.45}}
local bt = brush{kind="round", width=2.6, point=0.3}
for _, p in ipairs({{234, 114}, {506, 114}, {234, 358}, {506, 358}, {234, 236}, {506, 236}, {370, 114}}) do
  bt:load(JD, 0.9) bt:touch(p[1] + 1, p[2] + 1, {pressure=0.65})
  bt:load(BO, 0.9) bt:touch(p[1], p[2], {pressure=0.5})
end

--@ chunk 13
print(wait(6*24*60), drying(370,229))
local function fill(m, p, w) work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m, tool={kind="round", width=w or 1.2}, length={1.5, 4}, angle=0}) end
WBG = pile{{"lead white",2},{"rose madder",0.22},{"cadmium yellow",0.05}}
WFR = pile{{"lead white",2.5},{"rose madder",0.1},{"zinc white",0.5}}
local win = rect(300, 156, 140, 130)
fill(win, WFR, 1.6)
local bg = rect(303, 167, 134, 116)
fill(bg, WBG, 1.6)

--@ chunk 14
print(wait(6*24*60), drying(370,229))
local function fill(m, p, w) work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m, tool={kind="round", width=w or 1.0}, length={1.2, 3}, angle=0}) end
local HAIR = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local SKIN = pile{{"lead white",2.5},{"rose madder",0.12},{"yellow ochre",0.05}}
local SKIN2 = pile{{"lead white",2},{"rose madder",0.3},{"yellow ochre",0.06}}
local DRESS = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.5}}
local bg = rect(303, 167, 134, 116)
HAIRM = poly({{334, 200}, {342, 180}, {358, 172}, {382, 172}, {398, 180}, {406, 200}, {410, 240}, {414, 283}, {326, 283}, {330, 240}}) * bg
fill(HAIRM, HAIR, 1.2)
local body = poly({{344, 262}, {396, 262}, {416, 283}, {324, 283}}) * bg
fill(body, DRESS, 1.2)
local neck = poly({{362, 246}, {378, 246}, {380, 264}, {360, 264}})
fill(neck, SKIN2, 1.0)
FACE = poly({{346, 200}, {394, 200}, {397, 222}, {385, 245}, {370, 252}, {355, 245}, {343, 222}})
fill(FACE, SKIN, 1.0)
local shade = poly({{370, 200}, {394, 200}, {397, 222}, {385, 245}, {370, 252}}) * FACE
fill(shade, SKIN2, 1.0)
-- forearm and the raised hand
local arm = poly({{404, 283}, {416, 283}, {420, 252}, {410, 250}})
fill(arm, SKIN2, 1.0)
local palm = poly({{407, 236}, {420, 232}, {424, 248}, {411, 252}})
fill(palm, SKIN, 1.0)

--@ chunk 15
print(wait(6*24*60), drying(370,229))
local function fill(m, p, w) work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m, tool={kind="round", width=w or 0.9}, length={1, 2.5}, angle=0}) end
local HAIR = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local HF = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.35}}
local EYE = pile{{"bone black",2},{"ultramarine blue",0.6},{"rose madder",0.1}}
local HI = pile{{"zinc white",2},{"lead white",1}}
local SKIN = pile{{"lead white",2.5},{"rose madder",0.12},{"yellow ochre",0.05}}
local MO = pile{{"rose madder",0.6},{"Mars red",0.3},{"bone black",0.4},{"lead white",0.3}}
-- bangs in facets
local bangs = poly({{343, 186}, {397, 186}, {399, 210}, {389, 202}, {380, 213}, {371, 201}, {361, 213}, {352, 202}, {341, 211}})
fill(bangs, HAIR, 1.0)
-- big dark eyes with square highlights
local el = poly({{351, 214}, {364, 212}, {366, 228}, {353, 229}})
local er = poly({{376, 212}, {389, 214}, {387, 229}, {374, 228}})
fill(el + er, EYE, 0.9)
local hl = rect(354.5, 215, 3, 3) + rect(377.5, 215, 3, 3) + rect(361, 224, 1.6, 1.6) + rect(384, 224, 1.6, 1.6)
fill(hl, HI, 0.6)
-- mouth mid-word
local mo = poly({{362, 236}, {379, 236}, {376, 242}, {370, 244}, {365, 242}})
fill(mo, MO, 0.7)
-- hair facets: a few flat lighter planes
local r = brush{kind="rigger", width=0.7, point=1}
for _, s in ipairs({{{344, 182}, {336, 240}}, {{398, 182}, {406, 240}}, {{334, 244}, {330, 282}}, {{406, 246}, {410, 282}}, {{360, 174}, {346, 188}}, {{382, 174}, {396, 188}}}) do
  r:load(HF, 0.85) r:stroke(s, {pressure={0.5, 0.5}, ramps={0.03, 0.03}})
end
-- fingers of the wave
local f = brush{kind="round", width=2.2, point=0.5}
for i, x in ipairs({408.5, 412, 415.5, 419}) do f:load(SKIN, 0.9) f:stroke({{x, 236}, {x + 0.8, 227 + (i == 1 and 4 or 0)}}, {pressure={0.6, 0.45}}) end
f:load(SKIN, 0.9) f:stroke({{422, 244}, {427, 238}}, {pressure={0.55, 0.4}})
-- the window's title bar and her words below it
local TB = pile{{"rose madder",0.5},{"lead white",1.2},{"bone black",0.3}}
local t = brush{kind="filbert", width=2.4, stiffness=0.6}
t:load(TB, 0.9) t:stroke({{306, 161}, {350, 161}}, {pressure={0.75, 0.75}, ramps={0.02, 0.02}})
for _, x in ipairs({424, 430}) do t:load(TB, 0.9) t:stroke({{x, 161}, {x + 2.5, 161}}, {pressure={0.75, 0.75}, ramps={0.02, 0.02}}) end
local WW = pile{{"lead white",2},{"rose madder",0.18},{"cadmium yellow",0.05}}
local PA = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.5}}
local blk = brush{kind="filbert", width=2.4, stiffness=0.6}
local function marks(y, x0, x1, p)
  local x = x0
  while x < x1 - 6 do
    local L = math.min(x1 - x, rand(1, 6) * 4.5)
    blk:load(p, 0.9) blk:stroke({{x, y}, {x + L - 1.5, y}}, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=SCREEN})
    x = x + L + rand(3, 5)
  end
end
-- amber braces of the annotation around her words
local br = brush{kind="rigger", width=1.2, point=1}
br:load(PA, 0.9) br:stroke({{274, 290}, {270, 292}, {270, 300}, {267, 302}, {270, 304}, {270, 312}, {274, 314}}, {pressure={0.55, 0.55}})
br:load(PA, 0.9) br:stroke({{466, 290}, {470, 292}, {470, 300}, {473, 302}, {470, 304}, {470, 312}, {466, 314}}, {pressure={0.55, 0.55}})
marks(296, 280, 452, WW) marks(306, 280, 398, WW)
local cur = brush{kind="filbert", width=3.2, stiffness=0.6}
cur:load(WW, 0.95) cur:stroke({{403, 306}, {407, 306}}, {pressure={0.85, 0.85}, ramps={0.02, 0.02}})
-- the last green line of the old header, half scrolled off the top edge
local PG = pile{{"viridian",0.5},{"emerald green",0.3},{"lead white",0.6},{"bone black",0.4}}
local g = brush{kind="filbert", width=1.6, stiffness=0.6}
local x = 272
while x < 430 do local L = rand(1, 5)*5 g:load(PG, 0.8) g:stroke({{x, 145}, {x + L - 1.5, 145}}, {pressure={0.6, 0.6}, ramps={0.02, 0.02}, clip=SCREEN}) x = x + L + rand(3, 6) end

--@ chunk 16
print(wait(10*24*60), drying(355,225))
local function fill(m, p, w) work(m, {hand="detail", pile=p, coverage=5, fill=true, clip=m, tool={kind="round", width=w or 1.0}, length={1.2, 3}, angle=0}) end
local SKIN = pile{{"lead white",2.5},{"rose madder",0.12},{"yellow ochre",0.05}}
local SKIN2 = pile{{"lead white",2},{"rose madder",0.3},{"yellow ochre",0.06}}
local left = poly({{346, 210}, {370, 211}, {370, 252}, {355, 245}, {343, 222}})
local eyes = poly({{350, 213}, {365, 211}, {367, 229}, {352, 230}}):grow(0.8) + poly({{350, 236}, {392, 236}, {392, 244}, {350, 244}}):grow(0)
fill(left - eyes, SKIN, 0.9)
local neck = poly({{362, 246}, {378, 246}, {380, 264}, {360, 264}}) - poly({{355, 245}, {370, 252}, {385, 245}, {385, 250}, {355, 250}})
fill(neck, SKIN2, 0.9)
-- the hand: a darker outline so it reads against the pale window
local HO = pile{{"rose madder",0.4},{"bone black",0.6},{"lead white",0.5}}
local r = brush{kind="rigger", width=0.7, point=1}
r:load(HO, 0.9) r:stroke({{404, 283}, {407, 252}, {406, 238}, {407, 231}}, {pressure={0.45, 0.45}})
r:load(HO, 0.9) r:stroke({{416, 283}, {420, 254}, {425, 249}, {428, 240}}, {pressure={0.45, 0.45}})
for _, x in ipairs({410.3, 413.8, 417.3}) do r:load(HO, 0.8) r:stroke({{x, 228}, {x + 0.3, 237}}, {pressure={0.3, 0.3}}) end

--@ chunk 17
print(wait(10*24*60))
local SKIN = pile{{"lead white",2.5},{"rose madder",0.12},{"yellow ochre",0.05}}
local SKIN2 = pile{{"lead white",2},{"rose madder",0.3},{"yellow ochre",0.06}}
local eyes = poly({{350, 213}, {365, 211}, {367, 229}, {352, 230}}):grow(0.8) + poly({{375, 211}, {390, 213}, {388, 230}, {373, 229}}):grow(0.8) + poly({{365, 236}, {376, 236}, {374, 243}, {367, 243}}):grow(0.8)
local bangs = poly({{343, 186}, {397, 186}, {399, 210}, {389, 202}, {380, 213}, {371, 201}, {361, 213}, {352, 202}, {341, 211}})
local left = poly({{346, 200}, {370, 200}, {370, 252}, {355, 245}, {343, 222}}) - eyes - bangs
local right = poly({{370, 200}, {394, 200}, {397, 222}, {385, 245}, {370, 252}}) - eyes - bangs
local arm = poly({{405, 283}, {415, 283}, {419, 252}, {408, 250}})
for k = 1, 2 do
  work(left, {hand="body", pile=SKIN, coverage=4, fill=true, clip=left, tool={kind="filbert", width=2.2}, length={3, 6}, angle=1.57})
  work(right + arm, {hand="body", pile=SKIN2, coverage=4, fill=true, clip=right + arm, tool={kind="filbert", width=2.2}, length={3, 6}, angle=1.57})
end

--@ chunk 18
print(wait(6*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- working ceiling lights: warm panels along the side corridor's ceiling and a fixture above the terminal
local LT = pile{{"lead white",2.2},{"cadmium yellow",0.35},{"Mars orange",0.06}}
local LH = pile{{"raw sienna",0.6},{"yellow ochre",0.5},{"lead white",0.9},{"bone black",0.2}}
local fix = rect(250, 30, 240, 14)
fill(fix:grow(3), pile{{"bone black",1.6},{"bone brown",0.6}})
fill(fix, LT)
local glow = rect(240, 44, 260, 26) * FWALL
local s = brush{kind="filbert", width=3, stiffness=0.4}
for k = 1, 60 do local x = rand(244, 496) s:load(LH, 0.6) s:stroke({{x, 46}, {x + rand(-2, 2), 46 + rand(8, 22)}}, {pressure={0.5, 0.05}, clip=glow}) end
for _, z in ipairs({0.25, 0.5, 0.75}) do
  local a = {700 + (835 - 700)*z, -40 + (240 + 40)*z}
  local b = {1040 + (885 - 1040)*z, -40 + (240 + 40)*z}
  local m = poly({{a[1] + 20*(1 - z), a[2] + 4}, {b[1] - 20*(1 - z), b[2] + 4}, {b[1] - 20*(1 - z), b[2] + 4 + 10*(1 - z)}, {a[1] + 20*(1 - z), a[2] + 4 + 10*(1 - z)}}) * SCEIL
  fill(m, LT)
end
-- vent: clean and dark, no frost
local vent = rect(70, 150, 112, 96)
local RB = pile{{"bone black",2},{"bone brown",0.4}}
local RL = pile{{"bone brown",0.8},{"raw sienna",0.6},{"lead white",0.35},{"bone black",0.3}}
fill(vent:grow(4), RB, "round 1.6")
local sl = brush{kind="filbert", width=2.2, stiffness=0.5}
for y = 158, 240, 9 do sl:load(RL, 0.85) sl:stroke({{76, y}, {176, y}}, {pressure={0.6, 0.6}, clip=vent}) end

--@ chunk 19
print(wait(6*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local PAPER = pile{{"lead white",2.2},{"yellow ochre",0.08}}
local TAPE = pile{{"lead white",1.4},{"yellow ochre",0.3},{"cadmium yellow",0.1}}
local CR = {pile{{"cadmium red",1},{"lead white",0.2}}, pile{{"cobalt blue",1},{"lead white",0.3}}, pile{{"cadmium yellow",1},{"lead white",0.2}},
  pile{{"emerald green",1},{"lead white",0.3}}, pile{{"bone black",2}}, pile{{"Mars orange",1},{"lead white",0.2}}, pile{{"cobalt violet",1},{"lead white",0.4}}}
local r
local function cr(p, pts, w) r = brush{kind="rigger", width=w or 0.9, point=0.8} r:load(p, 0.9) r:stroke(pts, {pressure={0.55, 0.5}, ramps={0.03, 0.03}}) end
local function sheet(x, y, w, h, tilt)
  local c, s = math.cos(tilt), math.sin(tilt)
  local function P(u, v) return {x + c*u - s*v, y + s*u + c*v} end
  fill(poly({P(0, 0), P(w, 0), P(w, h), P(0, h)}), PAPER)
  fill(poly({P(w*0.35, -2), P(w*0.65, -2), P(w*0.65, 3), P(w*0.35, 3)}), TAPE, "round 0.8")
  return P
end
-- the station: a ring and a spine
local P = sheet(538, 110, 54, 44, 0.06)
local ring = {} for k = 0, 20 do local t = k/20*2*math.pi ring[#ring+1] = P(27 + 18*math.cos(t), 24 + 7*math.sin(t)) end
cr(CR[6], ring, 1.1) cr(CR[6], {P(30, 6), P(24, 40)}, 1.3) cr(CR[3], {P(46, 12), P(50, 8)}, 1)
-- a big knight with a red tabard and a cross
P = sheet(150, 268, 50, 64, -0.08)
cr(CR[5], {P(25, 6), P(25, 14)}, 2) cr(CR[5], {P(14, 16), P(36, 16), P(38, 44), P(12, 44), P(14, 16)}, 1)
cr(CR[1], {P(18, 20), P(32, 20)}, 2.6) cr(CR[1], {P(18, 30), P(32, 30)}, 2.6) cr(CR[1], {P(18, 38), P(32, 38)}, 2.6)
cr(pile{{"lead white",2}}, {P(25, 20), P(25, 40)}, 1) cr(CR[5], {P(18, 44), P(16, 58)}, 1.2) cr(CR[5], {P(32, 44), P(34, 58)}, 1.2)
cr(CR[3], {P(38, 10), P(44, 6)}, 1) cr(CR[3], {P(41, 4), P(43, 12)}, 1)
-- a little girl with long black hair, waving
P = sheet(536, 330, 46, 56, 0.1)
cr(CR[5], {P(15, 10), P(13, 34)}, 2.4) cr(CR[5], {P(31, 10), P(33, 34)}, 2.4) cr(CR[5], {P(15, 9), P(31, 9)}, 2.6)
local face = {} for k = 0, 12 do local t = k/12*2*math.pi face[#face+1] = P(23 + 7*math.cos(t), 18 + 8*math.sin(t)) end
cr(CR[7], face, 0.8) cr(CR[5], {P(20, 16), P(20, 17)}, 1.4) cr(CR[5], {P(26, 16), P(26, 17)}, 1.4) cr(CR[1], {P(20, 22), P(23, 24), P(26, 22)}, 0.8)
cr(CR[2], {P(16, 28), P(30, 28), P(34, 48), P(12, 48), P(16, 28)}, 1) cr(CR[2], {P(30, 30), P(40, 18)}, 1)
cr(CR[3], {P(38, 6), P(42, 2)}, 1)
-- two more: a sun with rays, and a row of stick figures holding hands
P = sheet(152, 108, 44, 40, 0.05)
local sun = {} for k = 0, 12 do local t = k/12*2*math.pi sun[#sun+1] = P(22 + 8*math.cos(t), 20 + 8*math.sin(t)) end
cr(CR[3], sun, 1.6) for k = 0, 7 do local t = k/8*2*math.pi cr(CR[6], {P(22 + 11*math.cos(t), 20 + 11*math.sin(t)), P(22 + 16*math.cos(t), 20 + 16*math.sin(t))}, 0.9) end
P = sheet(226, 452, 76, 18, -0.03)
for i = 0, 4 do local x = 8 + i*15 cr(CR[(i % 4) + 1], {P(x, 4), P(x, 12)}, 1) cr(CR[(i % 4) + 1], {P(x - 3, 16), P(x, 12), P(x + 3, 16)}, 0.8) end
cr(CR[1], {P(8, 8), P(68, 8)}, 0.7)

--@ chunk 20
print(wait(5*24*60))
-- a crowd of painted arrows by many hands, in many colours, all pointing to the screen
local COL = {
 pile{{"cobalt blue",1},{"lead white",0.4}}, pile{{"cadmium yellow",1},{"lead white",0.2}}, pile{{"emerald green",1},{"lead white",0.3}},
 pile{{"cobalt violet",1},{"lead white",0.5}}, pile{{"Mars orange",1},{"lead white",0.2}}, pile{{"lead white",2},{"rose madder",0.3}},
 pile{{"vermilion",1},{"lead white",0.2}}, pile{{"viridian",1},{"lead white",0.5}}, pile{{"cerulean blue",1},{"lead white",0.6}},
}
local tgt = {370, 229}
local busy = HOUS:grow(10) + SHELF:grow(6) + SHELFF:grow(6) + rect(66, 146, 120, 104) + rect(536, 240, 140, 100)
local n, tries = 0, 0
while n < 34 and tries < 400 do
  tries = tries + 1
  local x, y = rand(40, 690), rand(70, 470)
  if FWALL:at(x, y) > 0.5 and busy:at(x, y) < 0.1 then
    local a = math.atan(tgt[2] - y, tgt[1] - x)
    local L = rand(26, 52)
    local hx, hy = x + math.cos(a)*L, y + math.sin(a)*L
    if busy:at(clamp(hx,0,999), clamp(hy,0,562)) < 0.1 and FWALL:at(clamp(hx,0,999), clamp(hy,0,562)) > 0.5 then
      n = n + 1
      local p = COL[(n % #COL) + 1]
      local w = rand(1.6, 3.4)
      local b = brush{kind="round", width=w, point=0.5}
      local bend = rand(-6, 6)
      b:load(p, 0.95) b:stroke({{x, y}, {(x + hx)/2 - math.sin(a)*bend, (y + hy)/2 + math.cos(a)*bend}, {hx, hy}}, {pressure={0.7, 0.7}, ramps={0.05, 0.05}})
      local hl = rand(8, 14)
      for _, s in ipairs({-1, 1}) do
        local aa = a + math.pi + s*0.55
        b:load(p, 0.95) b:stroke({{hx, hy}, {hx + math.cos(aa)*hl, hy + math.sin(aa)*hl}}, {pressure={0.7, 0.6}})
      end
    end
  end
end
print(n)

--@ chunk 21
print(wait(6*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- a child's hand in a coverall sleeve reaching in from the lower right toward the keys
local SLV = pile{{"ultramarine ash",0.8},{"bone black",0.5},{"lead white",0.6},{"cobalt blue",0.15}}
local SLD = pile{{"ultramarine ash",0.6},{"bone black",0.9},{"lead white",0.3}}
local SKN = pile{{"lead white",1.4},{"yellow ochre",0.25},{"rose madder",0.2},{"burnt sienna",0.1}}
local SKD = pile{{"burnt sienna",0.5},{"rose madder",0.3},{"lead white",0.8},{"bone black",0.2}}
local sleeve = poly({{1010, 560}, {1010, 470}, {720, 404}, {700, 420}, {716, 448}}, true)
fill(sleeve, SLV, "round 2")
fill(poly({{1010, 560}, {1010, 520}, {716, 440}, {716, 448}}, true), SLD, "round 2")
local cuff = poly({{718, 402}, {732, 404}, {716, 448}, {702, 444}}, true)
fill(cuff, SLD)
local hand = poly({{704, 410}, {660, 396}, {638, 398}, {634, 408}, {664, 420}, {702, 440}}, true)
fill(hand, SKN)
local r = brush{kind="round", width=4.2, point=0.6}
for i, f in ipairs({{{640, 398}, {616, 392}}, {{638, 404}, {612, 402}}, {{640, 410}, {616, 412}}, {{646, 416}, {626, 420}}}) do r:load(SKN, 0.9) r:stroke(f, {pressure={0.75, 0.55}}) end
r:load(SKN, 0.9) r:stroke({{670, 424}, {652, 432}, {640, 432}}, {pressure={0.75, 0.55}})
local d = brush{kind="rigger", width=0.8, point=1}
for _, f in ipairs({{{640, 401}, {614, 397}}, {{639, 407}, {613, 407}}, {{642, 413}, {618, 416}}}) do d:load(SKD, 0.8) d:stroke(f, {pressure={0.4, 0.3}}) end
d:load(SKD, 0.8) d:stroke({{700, 440}, {660, 424}, {636, 410}}, {pressure={0.4, 0.3}})
-- warm-white light from the screen on the top edge of hand and sleeve
local RW = pile{{"lead white",1.8},{"rose madder",0.15},{"cadmium yellow",0.05}}
d:load(RW, 0.9) d:stroke({{660, 396}, {638, 398}, {616, 392}}, {pressure={0.45, 0.3}})
d:load(RW, 0.9) d:stroke({{1010, 470}, {860, 436}, {720, 404}}, {pressure={0.4, 0.4}})

--@ chunk 22
print(wait(8*24*60))
local sheets = rect(150, 105, 52, 48) + rect(536, 106, 60, 54) + rect(146, 262, 60, 72) + rect(530, 326, 58, 66) + rect(222, 448, 84, 26)
local ring = (HOUS:grow(70) - HOUS:grow(1) - SHELF:grow(1) - SHELFF:grow(1) - rect(66, 146, 120, 104):grow(4) - sheets:grow(2)) * FWALL
work(ring, {hand="body", pile=WW, coverage=4, fill=true, clip=ring, angle=1.57, length={10, 25}, tool="filbert 5"})
local fl = FLOOR * rect(150, 478, 560, 80)
work(fl, {hand="body", pile=FL, coverage=4, fill=true, clip=fl, angle=0, length={10, 25}, tool="filbert 5"})

--@ chunk 23
print(wait(8*24*60))
-- a crowd of painted arrows by many hands, in many colours, all pointing to the screen
local COL = {
 pile{{"cobalt blue",1},{"lead white",0.4}}, pile{{"cadmium yellow",1},{"lead white",0.2}}, pile{{"emerald green",1},{"lead white",0.3}},
 pile{{"cobalt violet",1},{"lead white",0.5}}, pile{{"Mars orange",1},{"lead white",0.2}}, pile{{"lead white",2},{"rose madder",0.3}},
 pile{{"vermilion",1},{"lead white",0.2}}, pile{{"viridian",1},{"lead white",0.5}}, pile{{"cerulean blue",1},{"lead white",0.6}},
}
local tgt = {370, 229}
local busy = HOUS:grow(10) + SHELF:grow(6) + SHELFF:grow(6) + rect(66, 146, 120, 104) + rect(536, 240, 140, 100)
local n, tries = 0, 0
while n < 34 and tries < 400 do
  tries = tries + 1
  local x, y = rand(40, 690), rand(70, 470)
  if FWALL:at(x, y) > 0.5 and busy:at(x, y) < 0.1 then
    local a = math.atan(tgt[2] - y, tgt[1] - x)
    local L = rand(26, 52)
    local hx, hy = x + math.cos(a)*L, y + math.sin(a)*L
    if busy:at(clamp(hx,0,999), clamp(hy,0,562)) < 0.1 and FWALL:at(clamp(hx,0,999), clamp(hy,0,562)) > 0.5 then
      n = n + 1
      local p = COL[(n % #COL) + 1]
      local w = rand(1.6, 3.4)
      local b = brush{kind="round", width=w, point=0.5}
      local bend = rand(-6, 6)
      b:load(p, 0.95) b:stroke({{x, y}, {(x + hx)/2 - math.sin(a)*bend, (y + hy)/2 + math.cos(a)*bend}, {hx, hy}}, {pressure={0.7, 0.7}, ramps={0.05, 0.05}})
      local hl = rand(8, 14)
      for _, s in ipairs({-1, 1}) do
        local aa = a + math.pi + s*0.55
        b:load(p, 0.95) b:stroke({{hx, hy}, {hx + math.cos(aa)*hl, hy + math.sin(aa)*hl}}, {pressure={0.7, 0.6}})
      end
    end
  end
end
print(n)

--@ chunk 24
print(wait(8*24*60))
local fix0 = rect(696, 180, 50, 230) * FWALL - rect(530, 326, 58, 66):grow(2) - rect(536, 106, 60, 54):grow(2)
work(fix0, {hand="body", pile=WW, coverage=4, fill=true, clip=fix0, angle=1.57, length={10, 25}, tool="filbert 5"})
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
local PAPER = pile{{"lead white",2.2},{"yellow ochre",0.08}}
local TAPE = pile{{"lead white",1.4},{"yellow ochre",0.3},{"cadmium yellow",0.1}}
local CR = {pile{{"cadmium red",1},{"lead white",0.2}}, pile{{"cobalt blue",1},{"lead white",0.3}}, pile{{"cadmium yellow",1},{"lead white",0.2}},
  pile{{"emerald green",1},{"lead white",0.3}}, pile{{"bone black",2}}, pile{{"Mars orange",1},{"lead white",0.2}}, pile{{"cobalt violet",1},{"lead white",0.4}}}
local r
local function cr(p, pts, w) r = brush{kind="rigger", width=(w or 0.9)*1.6, point=0.8} r:load(p, 0.9) r:stroke(pts, {pressure={0.55, 0.5}, ramps={0.03, 0.03}}) end
local function sheet(x, y, w, h, tilt)
  local c, s = math.cos(tilt), math.sin(tilt)
  local function P(u, v) return {x + c*u - s*v, y + s*u + c*v} end
  fill(poly({P(0, 0), P(w, 0), P(w, h), P(0, h)}), PAPER)
  fill(poly({P(w*0.35, -2), P(w*0.65, -2), P(w*0.65, 3), P(w*0.35, 3)}), TAPE, "round 0.8")
  return P
end
-- the station: a ring and a spine
local P = sheet(538, 110, 54, 44, 0.06)
local ring = {} for k = 0, 20 do local t = k/20*2*math.pi ring[#ring+1] = P(27 + 18*math.cos(t), 24 + 7*math.sin(t)) end
cr(CR[6], ring, 1.1) cr(CR[6], {P(30, 6), P(24, 40)}, 1.3) cr(CR[3], {P(46, 12), P(50, 8)}, 1)
-- a big knight with a red tabard and a cross
P = sheet(150, 268, 50, 64, -0.08)
cr(CR[5], {P(25, 6), P(25, 14)}, 2) cr(CR[5], {P(14, 16), P(36, 16), P(38, 44), P(12, 44), P(14, 16)}, 1)
cr(CR[1], {P(18, 20), P(32, 20)}, 2.6) cr(CR[1], {P(18, 30), P(32, 30)}, 2.6) cr(CR[1], {P(18, 38), P(32, 38)}, 2.6)
cr(pile{{"lead white",2}}, {P(25, 20), P(25, 40)}, 1) cr(CR[5], {P(18, 44), P(16, 58)}, 1.2) cr(CR[5], {P(32, 44), P(34, 58)}, 1.2)
cr(CR[3], {P(38, 10), P(44, 6)}, 1) cr(CR[3], {P(41, 4), P(43, 12)}, 1)
-- a little girl with long black hair, waving
P = sheet(536, 330, 46, 56, 0.1)
cr(CR[5], {P(15, 10), P(13, 34)}, 2.4) cr(CR[5], {P(31, 10), P(33, 34)}, 2.4) cr(CR[5], {P(15, 9), P(31, 9)}, 2.6)
local face = {} for k = 0, 12 do local t = k/12*2*math.pi face[#face+1] = P(23 + 7*math.cos(t), 18 + 8*math.sin(t)) end
cr(CR[7], face, 0.8) cr(CR[5], {P(20, 16), P(20, 17)}, 1.4) cr(CR[5], {P(26, 16), P(26, 17)}, 1.4) cr(CR[1], {P(20, 22), P(23, 24), P(26, 22)}, 0.8)
cr(CR[2], {P(16, 28), P(30, 28), P(34, 48), P(12, 48), P(16, 28)}, 1) cr(CR[2], {P(30, 30), P(40, 18)}, 1)
cr(CR[3], {P(38, 6), P(42, 2)}, 1)
-- two more: a sun with rays, and a row of stick figures holding hands
P = sheet(152, 108, 44, 40, 0.05)
local sun = {} for k = 0, 12 do local t = k/12*2*math.pi sun[#sun+1] = P(22 + 8*math.cos(t), 20 + 8*math.sin(t)) end
cr(CR[3], sun, 1.6) for k = 0, 7 do local t = k/8*2*math.pi cr(CR[6], {P(22 + 11*math.cos(t), 20 + 11*math.sin(t)), P(22 + 16*math.cos(t), 20 + 16*math.sin(t))}, 0.9) end
P = sheet(226, 452, 76, 18, -0.03)
for i = 0, 4 do local x = 8 + i*15 cr(CR[(i % 4) + 1], {P(x, 4), P(x, 12)}, 1) cr(CR[(i % 4) + 1], {P(x - 3, 16), P(x, 12), P(x + 3, 16)}, 0.8) end
cr(CR[1], {P(8, 8), P(68, 8)}, 0.7)

--@ chunk 25
print(wait(8*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- the ceiling fixture restated
local LT = pile{{"lead white",2.2},{"cadmium yellow",0.35},{"Mars orange",0.06}}
local fix = rect(250, 30, 240, 14)
fill(fix:grow(3), pile{{"bone black",1.6},{"bone brown",0.6}})
fill(fix, LT)
local LH = pile{{"raw sienna",0.6},{"yellow ochre",0.5},{"lead white",0.9},{"bone black",0.2}}
local s = brush{kind="filbert", width=3, stiffness=0.4}
for k = 1, 40 do local x = rand(244, 496) s:load(LH, 0.55) s:stroke({{x, 47}, {x + rand(-2, 2), 47 + rand(6, 16)}}, {pressure={0.45, 0.05}, clip=rect(240, 46, 260, 30) * FWALL - HOUS}) end
-- the original red arrow and the second, restated whole
local AR = pile{{"vermilion",1},{"cadmium red",0.6},{"bone black",0.35}}
local shaft = poly({{564, 262}, {664, 258}, {666, 274}, {565, 278}}, true)
local head = poly({{536, 270}, {570, 244}, {566, 296}}, false)
fill(shaft + head, AR, "round 1.6")
local small = poly({{566, 318}, {622, 316}, {623, 326}, {567, 328}}, true) + poly({{548, 323}, {570, 308}, {568, 338}}, false)
fill(small, AR)

--@ chunk 26
print(wait(6*24*60)) local ar = poly({{564, 262}, {664, 258}, {666, 274}, {565, 278}}, true) + poly({{536, 270}, {570, 244}, {566, 296}}, false) + poly({{566, 318}, {622, 316}, {623, 326}, {567, 328}}, true) + poly({{548, 323}, {570, 308}, {568, 338}}, false) local m = rect(586, 150, 40, 190) * FWALL - ar:grow(1.5) - rect(530, 326, 58, 66):grow(2) - rect(536, 106, 60, 54):grow(2) work(m, {hand="detail", pile=WW, coverage=5, fill=true, clip=m, angle=1.57, tool={kind="round", width=1.8}, length={4, 10}})
