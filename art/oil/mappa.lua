-- easel session "mappa": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1, linen={18,16}, seed=9494, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.8},{"raw sienna",0.25}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
C = {500, 500}
OCEAN = ellipse(500, 500, 430, 430) - ellipse(500, 500, 350, 350)
LAND = ellipse(500, 500, 350, 350)
BORDER = rect(0,0,1000,1000) - rect(36,36,928,928)
local function flat(m, p, a) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=a or 0, clip=m, load=1}) end
flat(BORDER, pile{{"cadmium red",1},{"Mars red",0.8},{"rose madder",0.3}})
flat(OCEAN, pile{{"ultramarine blue",1.2},{"bone black",0.5},{"cobalt blue",0.3}}, 0)
flat(LAND, pile{{"lead white",2.2},{"yellow ochre",0.7},{"viridian",0.12}}, 0)
-- the T: the spine crossing the ring
T = rect(150, 470, 700, 26) + rect(487, 470, 26, 380)
flat(T, pile{{"burnt sienna",1},{"yellow ochre",0.8},{"lead white",0.5}}, 0)

--@ chunk 3
print(wait(2*24*60))
function F(m, p) work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
function P(pts) return poly(pts) end
GOLDP = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.4}}
INK = pile{{"bone black",2},{"burnt sienna",0.4}}
GA = math.pi*(3-math.sqrt(5))
-- THE CORE: a white sun-flower at the head of the T
local pet = nil
for i=0,11 do local a = i*math.pi/6
  local tip = {500 + 78*math.cos(a), 300 + 78*math.sin(a)}
  local l = {500 + 34*math.cos(a+0.28), 300 + 34*math.sin(a+0.28)}
  local r = {500 + 34*math.cos(a-0.28), 300 + 34*math.sin(a-0.28)}
  local m = P({l, tip, r}); pet = pet and (pet + m) or m end
CORE = pet + ellipse(500,300,36,36)
F(pet, pile{{"zinc white",2.5},{"lemon chrome",0.1}})
F(ellipse(500,300,36,36), GOLDP)
-- THE CHAPEL: a small church with a red roof and a cross
CHAP = F(P({{300,330},{360,330},{360,390},{300,390}}), pile{{"lead white",2},{"yellow ochre",0.4},{"ultramarine ash",0.15}})
F(P({{292,332},{330,292},{368,332}}), pile{{"cadmium red",1},{"Mars red",0.5}})
F(P({{346,300},{360,300},{360,334},{346,334}}), pile{{"lead white",2},{"yellow ochre",0.4},{"ultramarine ash",0.15}})
F(P({{320,360},{340,360},{340,390},{320,390}}), INK)
-- HYDROPONICS: a walled garden, three trees in a ring
F(ellipse(680,350,72,44), pile{{"emerald green",1},{"viridian",0.4},{"lead white",0.8}})
F(ellipse(680,350,72,44) - ellipse(680,350,62,36), pile{{"burnt sienna",1},{"yellow ochre",0.6},{"lead white",0.4}})
for i,x in ipairs({650,680,710}) do
  F(rect(x-3, 336, 6, 22), pile{{"burnt sienna",1},{"bone brown",0.6}})
  F(ellipse(x, 328, 15, 14), pile{{"viridian",1},{"emerald green",0.6},{"yellow ochre",0.2}})
  F(ellipse(x-5, 322, 4, 4), pile{{"cadmium red",1}})
end

--@ chunk 4
-- THE OUTPOST: a little grey tower with a crimson banner
F(P({{300,600},{340,600},{346,700},{294,700}}), pile{{"lead white",1.5},{"ultramarine ash",0.8},{"bone black",0.15}})
F(P({{292,586},{348,586},{348,604},{292,604}}), pile{{"lead white",1},{"ultramarine ash",0.8},{"bone black",0.3}})
for _,x in ipairs({292,312,332}) do F(rect(x, 574, 12, 14), pile{{"lead white",1},{"ultramarine ash",0.8},{"bone black",0.3}}) end
F(rect(316, 640, 10, 20), INK)
F(rect(318, 520, 4, 56), INK)
F(P({{322,522},{360,530},{350,540},{362,552},{322,548}}), pile{{"cadmium red",1},{"Mars red",0.4}})
-- THE GAUNTLET: a knot of impossible stairs
local stair = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.6}}
local stairD = pile{{"burnt sienna",1},{"bone brown",0.6}}
local function steps(x, y, dx, dy, n)
  for i=0,n-1 do
    F(rect(x + i*dx, y + i*dy, 14, 7), stair)
    F(rect(x + i*dx, y + i*dy + 7, 14, 4), stairD)
  end
end
steps(620, 690, 12, -10, 7)
steps(704, 620, -12, -6, 6)
steps(634, 590, 4, 12, 7)
F(P({{640,700},{720,700},{720,712},{640,712}}), stairD)
-- THE MUSEUM: a columned building with a docent at its door
F(P({{580,760},{720,760},{720,840},{580,840}}), pile{{"lead white",2.2},{"yellow ochre",0.3}})
F(P({{570,762},{650,720},{730,762}}), pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}})
for _,x in ipairs({590,614,686,710}) do F(rect(x-4, 772, 8, 64), pile{{"yellow ochre",0.6},{"lead white",1.2}}) end
F(rect(636, 790, 28, 50), INK)
F(ellipse(650, 802, 7, 10), pile{{"burnt sienna",1},{"yellow ochre",0.8}})
F(rect(645, 812, 10, 26), pile{{"burnt sienna",1},{"bone brown",0.6}})
F(ellipse(652, 801, 2.2, 2.2), pile{{"Mars orange",1},{"cadmium yellow",1}})

--@ chunk 5
print(wait(2*24*60))
-- THE BREACH: a torn black mouth in the edge of the world, violet beasts crawling out
BR = P({{150,560},{196,600},{176,640},{226,680},{190,720},{240,760},{196,800},{150,780},{120,700},{126,620}})
F(BR, pile{{"bone black",2},{"ultramarine blue",0.3}})
F(P({{160,600},{186,640},{168,700},{196,760},{170,770},{150,700},{148,640}}), pile{{"bone black",1.2},{"cobalt violet",0.8},{"magenta",0.3}})
local V = pile{{"cobalt violet",1},{"magenta",0.4},{"lead white",0.6}}
local VD = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"bone black",0.2}}
local function beast(x, y, s, flip)
  F(ellipse(x, y, 16*s, 8*s), V)
  F(ellipse(x + flip*16*s, y - 6*s, 7*s, 6*s), V)
  for k=-1,1 do F(P({{x + k*8*s, y + 5*s},{x + k*8*s + 3*s, y + 16*s},{x + k*8*s - 3*s, y + 16*s}}), VD) end
  F(P({{x - flip*14*s, y - 2*s},{x - flip*34*s, y - 14*s},{x - flip*16*s, y + 4*s}}), VD)
  F(ellipse(x + flip*19*s, y - 8*s, 1.6*s, 1.6*s), pile{{"zinc white",2}})
end
beast(250, 660, 1.1, 1); beast(236, 730, 0.9, 1); beast(266, 790, 0.8, 1)
-- THE SUN: a great gold face in the upper right margin
local cx, cy = 885, 115
local rays = nil
for i=0,15 do local a = i*math.pi/8
  local m = P({{cx + 52*math.cos(a+0.16), cy + 52*math.sin(a+0.16)}, {cx + 78*math.cos(a), cy + 78*math.sin(a)}, {cx + 52*math.cos(a-0.16), cy + 52*math.sin(a-0.16)}})
  rays = rays and (rays + m) or m end
F(rays, pile{{"cadmium yellow",1},{"Mars orange",0.5}})
F(ellipse(cx, cy, 54, 54), pile{{"cadmium yellow",1.4},{"lemon chrome",0.3},{"lead white",0.3}})
F(ellipse(cx-18, cy-8, 6, 4), INK); F(ellipse(cx+18, cy-8, 6, 4), INK)
F(P({{cx-3,cy-6},{cx+3,cy-6},{cx+6,cy+12},{cx-6,cy+12}}), pile{{"Mars orange",1},{"cadmium yellow",0.5}})
F(P({{cx-16,cy+24},{cx+16,cy+24},{cx+8,cy+30},{cx-8,cy+30}}), pile{{"cadmium red",1},{"Mars red",0.4}})
F(ellipse(cx-30, cy+12, 7, 5), pile{{"Mars orange",1},{"cadmium red",0.3}}); F(ellipse(cx+30, cy+12, 7, 5), pile{{"Mars orange",1},{"cadmium red",0.3}})
-- THE SAIL: a ship on the ocean of space
local sx, sy = 790, 790
F(P({{sx-34,sy},{sx+34,sy},{sx+24,sy+14},{sx-24,sy+14}}), pile{{"burnt sienna",1},{"bone brown",0.6}})
F(rect(sx-2, sy-64, 4, 64), INK)
F(P({{sx-48,sy-60},{sx+48,sy-60},{sx+40,sy-10},{sx-40,sy-10}}), pile{{"cadmium yellow",1},{"yellow ochre",0.6},{"lead white",0.6}})
F(P({{sx+2,sy-74},{sx+20,sy-68},{sx+2,sy-62}}), pile{{"cadmium red",1}})

--@ chunk 6
print(wait(2*24*60))
local r = brush{kind="round", width=4, point=0.6}
local GOLD = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.3}}
local function circ(cx, cy, R, w, p)
  local pts = {} for i=0,96 do local a = 2*math.pi*i/96; pts[#pts+1] = {cx + R*math.cos(a), cy + R*math.sin(a)} end
  r:reload(p, 0.8); r:stroke(pts, {pressure={r:pressure_for(w), r:pressure_for(w)}})
end
circ(500,500,432,4,GOLD); circ(500,500,350,4,GOLD); circ(500,500,422,1.5,INK)
-- border: gold rule and a row of gold dots
local b = brush{kind="round", width=4, point=0.6}
for _,s in ipairs({{{40,40},{960,40}},{{960,40},{960,960}},{{960,960},{40,960}},{{40,960},{40,40}}}) do
  b:reload(GOLD, 0.8); b:stroke(s, {pressure={b:pressure_for(3), b:pressure_for(3)}})
end
local d = brush{kind="round", width=7, point=0}
for i=0,24 do local t = i/24
  for _,p in ipairs({{lerp(30,970,t),18},{lerp(30,970,t),982},{18,lerp(30,970,t)},{982,lerp(30,970,t)}}) do d:reload(GOLD, 0.6); d:touch(p[1], p[2], {pressure=0.8}) end
end
-- waves in the ocean: little white curls, and stars
local w = brush{kind="round", width=3, point=0.8}
local WH = pile{{"lead white",2},{"cerulean blue",0.4}}
for i=0,35 do local a = 2*math.pi*i/36 + 0.05
  local R = 390 + 12*math.sin(i*2.3)
  local x, y = 500 + R*math.cos(a), 500 + R*math.sin(a)
  if not (x > 730 and y > 720) and not (x < 260 and y > 560 and y < 820) then
    local tx, ty = -math.sin(a), math.cos(a)
    w:reload(WH, 0.6); w:stroke({{x - tx*10, y - ty*10},{x, y - 4*math.cos(a) - 4},{x + tx*10, y + ty*10}}, {pressure={w:pressure_for(1.6), w:pressure_for(0.6)}})
  end
end
-- roads: dotted lines from vignette to vignette
local dot = brush{kind="round", width=4, point=0}
local RD = pile{{"burnt sienna",1},{"bone brown",0.5}}
local function road(pts)
  for i=1,#pts-1 do local a, c = pts[i], pts[i+1]
    local L = math.sqrt((c[1]-a[1])^2 + (c[2]-a[2])^2)
    for k=0,math.floor(L/12) do local t = k*12/L; dot:reload(RD, 0.6); dot:touch(lerp(a[1],c[1],t), lerp(a[2],c[2],t), {pressure=0.6}) end
  end
end
road({{330,392},{360,440},{330,560}})
road({{420,300},{380,340}})
road({{580,300},{610,340}})
road({{330,700},{420,740},{560,790}})
road({{680,400},{640,450},{640,560}})
road({{300,640},{250,660}})
road({{700,720},{760,760}})

--@ chunk 7
-- tiny pilgrims on the roads: a dark robe, a pale head, a staff, a crimson one among them
local function pilgrim(x, y, p)
  F(P({{x-4,y-14},{x+4,y-14},{x+6,y},{x-6,y}}), p)
  F(ellipse(x, y-17, 3, 3), pile{{"lead white",2},{"Mars orange",0.2}})
  F(rect(x+6, y-22, 1.6, 23), INK)
end
pilgrim(352, 470, pile{{"bone brown",1},{"burnt sienna",0.5}})
pilgrim(470, 765, pile{{"cadmium red",1},{"Mars red",0.6}})
pilgrim(400, 742, pile{{"ultramarine blue",1},{"lead white",0.3}})
pilgrim(645, 470, pile{{"bone brown",1},{"burnt sienna",0.5}})
pilgrim(600, 330, pile{{"viridian",1},{"lead white",0.3}})
-- scrolls with abstract-mark lettering
local function scroll(x, y, w)
  F(P({{x,y},{x+w,y},{x+w,y+18},{x,y+18}}), pile{{"lead white",2.5},{"yellow ochre",0.3}})
  F(ellipse(x, y+9, 5, 10), pile{{"lead white",1.6},{"yellow ochre",0.6},{"burnt sienna",0.1}})
  F(ellipse(x+w, y+9, 5, 10), pile{{"lead white",1.6},{"yellow ochre",0.6},{"burnt sienna",0.1}})
  local r = brush{kind="round", width=2.5, point=0.8}
  local xx = x + 8
  while xx < x + w - 10 do local l = 4 + (xx*7 % 6)
    r:reload(INK, 0.6); r:stroke({{xx, y+9},{xx+l, y+9}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}}); xx = xx + l + 4 end
end
scroll(270, 404, 120); scroll(450, 196, 100); scroll(620, 404, 120); scroll(250, 712, 110)
scroll(560, 852, 120); scroll(150, 840, 70)
scroll(60, 70, 230)    -- the title, top left
scroll(700, 900, 230)  -- a colophon, bottom right

--@ chunk 8
print(wait(3*24*60))
local GOLD = pile{{"cadmium yellow",1.2},{"yellow ochre",0.8},{"lead white",0.2}}
-- gold rings as thin filled bands (crisper than strokes)
local g1 = ellipse(500,500,436,436) - ellipse(500,500,429,429)
local g2 = ellipse(500,500,354,354) - ellipse(500,500,347,347)
F(g1 - P({{740,700},{860,700},{860,830},{740,830}}), GOLD)
F(g2 - P({{740,700},{860,700},{860,830},{740,830}}) - BR:grow(2), GOLD)
-- lettering: bolder marks on the scrolls, and red initials
local r = brush{kind="round", width=4, point=0.6}
local function letters(x, y, w, red)
  local xx = x + 10
  if red then F(rect(x+6, y+2, 12, 14), pile{{"cadmium red",1}}); xx = x + 24 end
  while xx < x + w - 10 do local l = 3 + (math.floor(xx*13) % 7)
    r:reload(INK, 0.7); r:stroke({{xx, y+5},{xx+1, y+13}}, {pressure={r:pressure_for(2), r:pressure_for(1.6)}})
    if l > 5 then r:reload(INK, 0.6); r:stroke({{xx, y+9},{xx+l*0.6, y+9}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}}) end
    xx = xx + l + 3 end
end
letters(60, 70, 230, true); letters(700, 900, 230, true)
for _,s in ipairs({{270,404,120},{450,196,100},{620,404,120},{250,712,110},{560,852,120},{150,840,70}}) do letters(s[1], s[2], s[3], false) end
-- a golden-angle rosette in the lower-left corner: the station's mark
local GA = math.pi*(3-math.sqrt(5))
local d = brush{kind="round", width=6, point=0}
for i=1,90 do local rr = 5.5*math.sqrt(i); local a = i*GA
  d:reload((i % 2 == 0) and GOLD or pile{{"cadmium red",1},{"Mars red",0.4}}, 0.6); d:touch(105 + rr*math.cos(a), 900 + rr*math.sin(a), {pressure=0.8}) end
-- the Adversary's absence: no glyph, just a violet smudge on the scroll by the Breach
F(ellipse(186, 849, 12, 6), pile{{"cobalt violet",1},{"magenta",0.3},{"lead white",0.4}})
