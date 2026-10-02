-- easel session "mess_after": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=16/9, linen={18,16}, seed=1943,
  ground={{pile={{"bone black",1},{"ultramarine blue",0.4},{"lead white",0.3}}, um=120, apply="knife", texture=0.25}}}
WIN = poly({{340, 150}, {1000, 104}, {1000, 404}, {340, 372}})
CEIL = poly({{340, 150}, {1000, 104}, {1000, 150}, {340, 182}})
BACKW = poly({{340, 182}, {1000, 150}, {1000, 300}, {340, 300}})
CTOP = poly({{340, 300}, {1000, 300}, {1000, 318}, {340, 312}})
CFRONT = poly({{340, 312}, {1000, 318}, {1000, 404}, {340, 372}})
PORT = ellipse(150, 230, 72, 72)
local function W(m, p, w, ang, cov) if m:area() > 0.3 then work(m, {hand="body", tool={kind="filbert", width=w or 8}, pile=p, coverage=cov or 3.8, fill=true, clip=m, angle=ang or 0, length={30,90}}) end end
-- the corridor: dark slate wall, darker floor
W(rect(0, 0, 1000, 380) - WIN - PORT, pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.12}}, 10, math.pi/2)
W(rect(0, 372, 1000, 190) - WIN, pile{{"bone black",1.6},{"bone brown",0.4},{"ultramarine blue",0.2}}, 10, 0)
-- the mess beyond the glass, unlit: everything a dull cold dark
W(CEIL, pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.12}}, 5, 0)
W(BACKW, pile{{"bone black",1},{"viridian",0.25},{"ultramarine ash",0.5},{"lead white",0.18}}, 6, math.pi/2)
W(CTOP, pile{{"bone black",0.9},{"ultramarine ash",0.6},{"lead white",0.3}}, 3, 0)
W(CFRONT, pile{{"bone black",1.2},{"Mars red",0.35},{"bone brown",0.4}}, 6, 0)
-- the viewport: space and the Testament's faint bronze arc
W(PORT, pile{{"bone black",1.8},{"ultramarine blue",0.5}}, 5, 0)

--@ chunk 2
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- the red emergency strip along the corridor wall's foot, and its light on the corridor floor
local strip = poly({{0, 378}, {340, 374}, {340, 380}, {0, 384}})
fill(strip, pile{{"cadmium red",1},{"vermilion",0.6},{"lead white",0.4}}, 2)
local fz = poly({{0, 386}, {340, 380}, {380, 470}, {0, 500}})
local R1 = pile{{"Mars red",1},{"bone black",0.9},{"bone brown",0.3}}
local R2 = pile{{"Mars red",1},{"bone black",1.4},{"bone brown",0.4}}
fill(fz * rect(0, 380, 1000, 40), R1, 5)
fill(fz * rect(0, 420, 1000, 90), R2, 5)
blend(fz * rect(0, 410, 1000, 22), {angle=0, tool={kind="badger", width=10}})
-- red light falling IN through the window: a dim red wedge across the counter front and up the back wall
local wedge = poly({{340, 300}, {640, 296}, {760, 372}, {340, 372}}) * WIN
fill(wedge * CFRONT, pile{{"Mars red",1},{"cadmium red",0.3},{"bone black",0.7},{"bone brown",0.2}}, 4)
local wb = poly({{340, 230}, {520, 226}, {600, 300}, {340, 300}}) * BACKW
fill(wb, pile{{"Mars red",0.6},{"bone black",1},{"ultramarine ash",0.4},{"lead white",0.15}}, 4, math.pi/2)
blend((poly({{340, 220}, {560, 220}, {660, 300}, {340, 300}}) - poly({{340, 240}, {490, 236}, {560, 300}, {340, 300}})) * BACKW, {angle=0.6, tool={kind="badger", width=10}})
blend((poly({{340, 300}, {700, 296}, {820, 372}, {340, 372}}) - poly({{340, 300}, {600, 298}, {700, 372}, {340, 372}})) * CFRONT, {angle=0.6, tool={kind="badger", width=10}})
-- the window frame: top rail, sill and mullions (as in the lit picture)
local FR = pile{{"bone black",1.8},{"ultramarine blue",0.3}}
local rb = brush{kind="round", width=6, point=0.2}
rb:reload(FR, 0.95); rb:stroke({{340,150},{1000,104}}, {pressure={0.8,0.8}})
rb:reload(FR, 0.95); rb:stroke({{340,372},{1000,404}}, {pressure={0.8,0.8}})
rb:reload(FR, 0.95); rb:stroke({{342,150},{342,372}}, {pressure={0.8,0.8}})
for _,x in ipairs({600, 860}) do rb:reload(FR, 0.95); rb:stroke({{x, 132 - (x-600)*0.07}, {x, 386 + (x-600)*0.05}}, {pressure={0.7,0.7}}) end

--@ chunk 3
print(wait(2*24*60))
local function W(m, p, w, ang) if m:area() > 0.3 then work(m, {hand="body", tool={kind="filbert", width=w or 8}, pile=p, coverage=4.3, fill=true, clip=m, angle=ang or 0, length={30,90}}) end end
local FRM = ribbon({{340,150},{1000,104}}, 8) + ribbon({{340,372},{1000,404}}, 8) + ribbon({{342,150},{342,372}}, 8) + ribbon({{600,132},{600,386}}, 7) + ribbon({{860,114},{860,399}}, 7)
local strip = poly({{0, 376}, {340, 372}, {340, 382}, {0, 386}})
-- corridor wall: near-black slate, a faint red catch low down near the strip
W(rect(0, 0, 1000, 340) - WIN - PORT - FRM, pile{{"bone black",1.8},{"ultramarine blue",0.45},{"lead white",0.04}}, 10, math.pi/2)
W(rect(0, 340, 340, 36) - PORT, pile{{"bone black",1.6},{"Mars red",0.35},{"ultramarine blue",0.2}}, 6, 0)
blend(rect(0, 326, 340, 26), {angle=math.pi/2, tool={kind="badger", width=10}})
-- the corridor floor: deep red near the strip, falling off to black
local fl = rect(0, 384, 1000, 200) - WIN - FRM
local F = {
  {0, 30, pile{{"Mars red",1},{"bone black",1.1},{"cadmium red",0.15}}},
  {30, 80, pile{{"Mars red",0.8},{"bone black",1.5},{"bone brown",0.3}}},
  {80, 999, pile{{"bone black",2},{"bone brown",0.4},{"Mars red",0.15}}},
}
local function fd(x,y) return (y - 384) + math.max(0, x - 340)*0.6 end
for _,f in ipairs(F) do W(fl * mask(function(x,y) local v = fd(x,y); return (v >= f[1] and v < f[2]) and 1 or 0 end), f[3], 6, 0) end
blend(fl * mask(function(x,y) local v = fd(x,y); return (math.abs(v-30) < 10 or math.abs(v-80) < 14) and 1 or 0 end), {angle=0, tool={kind="badger", width=10}})
-- the mess, dead: back wall and counter in deep dull darks
local inner = WIN - FRM
local BW = BACKW * inner
local function rd(x,y) return (x - 340) + (y - 300)*1.6 end
W(BW * mask(function(x,y) return (rd(x,y) < 200) and 1 or 0 end), pile{{"bone black",1.3},{"Mars red",0.45},{"ultramarine ash",0.3}}, 5, math.pi/2)
W(BW * mask(function(x,y) return (rd(x,y) >= 200) and 1 or 0 end), pile{{"bone black",1.5},{"viridian",0.15},{"ultramarine ash",0.45},{"lead white",0.06}}, 5, math.pi/2)
blend(BW * mask(function(x,y) return (math.abs(rd(x,y) - 200) < 40) and 1 or 0 end), {angle=0.6, tool={kind="badger", width=12}})
W(CEIL * inner, pile{{"bone black",1.7},{"ultramarine ash",0.4}}, 5, 0)
local CF = CFRONT * inner
W(CF * mask(function(x,y) return (rd(x,y) < 380) and 1 or 0 end), pile{{"Mars red",1},{"bone black",1.1},{"bone brown",0.3}}, 5, 0)
W(CF * mask(function(x,y) return (rd(x,y) >= 380) and 1 or 0 end), pile{{"bone black",1.6},{"Mars red",0.3},{"bone brown",0.3}}, 5, 0)
blend(CF * mask(function(x,y) return (math.abs(rd(x,y) - 380) < 50) and 1 or 0 end), {angle=0.6, tool={kind="badger", width=12}})
W(CTOP * inner, pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.12}}, 3, 0)

--@ chunk 4
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- dead fluorescent tubes on the ceiling; the second has dropped at one end and hangs by its wire
local TUBE = pile{{"lead white",0.55},{"bone black",0.9},{"ultramarine ash",0.5}}
local TL = pile{{"lead white",0.8},{"bone black",0.6},{"Mars red",0.25}}
local tb = brush{kind="round", width=6, point=0.2}
tb:reload(TUBE, 0.95); tb:stroke({{380,170},{560,160}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
tb:reload(TUBE, 0.95); tb:stroke({{880,142},{980,136}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
local fx = brush{kind="round", width=3, point=0.2}
fx:reload(pile{{"bone black",1.6}}, 0.9); fx:stroke({{376,166},{564,156}}, {pressure={0.6,0.6}})
-- the hanging one: fixed at its right end, dropped at the left, a wire from the ceiling
tb:reload(TUBE, 0.95); tb:stroke({{830,150},{760,190},{690,232}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
local wr = brush{kind="round", width=1, point=0.6}
wr:reload(pile{{"bone black",1.6}}, 0.8); wr:stroke({{700,148},{696,190},{692,228}}, {pressure={0.35,0.35}})
local hl = brush{kind="round", width=1.4, point=0.5}
hl:reload(TL, 0.7); hl:stroke({{828,148},{758,188},{692,229}}, {pressure={0.4,0.3}})
hl:reload(TL, 0.6); hl:stroke({{382,168},{558,158}}, {pressure={0.35,0.3}})
-- three mugs left where the three sat
local MG = pile{{"lead white",0.7},{"bone black",0.6},{"ultramarine ash",0.4}}
local MGR = pile{{"lead white",0.6},{"Mars red",0.5},{"bone black",0.3}}
for i,x in ipairs({488, 640, 812}) do
  local m = rect(x - 6, 286, 12, 16)
  fill(m, (i == 1) and MGR or MG, 1.2)
  fill(ellipse(x, 286, 6, 1.8), pile{{"bone black",1.5}}, 1)
  local h = brush{kind="round", width=1.6, point=0.3}
  h:reload((i == 1) and MGR or MG, 0.9); h:stroke({{x + 6, 290}, {x + 10, 292}, {x + 10, 298}, {x + 6, 299}}, {pressure={0.55,0.55}})
end
-- the stools: one still standing, one knocked over on its side
local ST = pile{{"lead white",0.6},{"bone black",0.8},{"ultramarine ash",0.4}}
local STR = pile{{"lead white",0.6},{"Mars red",0.6},{"bone black",0.3}}
fill(rect(485, 312, 6, 46), STR, 1.2)
fill(ellipse(488, 312, 14, 3), STR, 1)
-- the fallen stool, lying on the mess floor beyond the counter end, seen through the lower glass
local p = brush{kind="round", width=5, point=0.2}
p:reload(ST, 0.9); p:stroke({{612,364},{660,352}}, {pressure={0.8,0.8}})
fill(ellipse(606, 360, 5, 11), ST, 1)
fill(ellipse(664, 354, 11, 3), ST, 1)
-- the viewport: frame ring and the Testament's faint bronze arc
local ring = ellipse(150, 230, 78, 78) - ellipse(150, 230, 72, 72)
fill(ring, pile{{"lead white",0.5},{"bone black",0.9},{"ultramarine ash",0.4}}, 2)
local ab = brush{kind="round", width=2.2, point=0.5}
ab:reload(pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.3}}, 0.8); ab:stroke({{88,260},{120,236},{160,224},{200,228},{222,240}}, {pressure={0.45,0.35}, clip=ellipse(150,230,71,71)})
local sb = brush{kind="round", width=1, point=0.8}
for i=1,12 do local x, y = rand(90, 210), rand(170, 220); sb:reload(pile{{"zinc white",3}}, 0.5); sb:touch(x, y, {pressure=rand(0.08,0.2)}) end

--@ chunk 5
print(wait(24*60))
-- frost creeping in from the glass edges and the mullions
local glass = WIN
local function edge(x,y)
  local dtop = y - (150 - (x-340)*46/660)
  local dbot = (372 + (x-340)*32/660) - y
  local dl = x - 340
  local dm = math.min(math.abs(x - 600), math.abs(x - 860))
  return math.min(dtop, dbot, dl, dm)
end
local fr = glass * mask(function(x,y) local d = edge(x,y); return (d < 12 + 10*math.max(0, (y - 280)/100)) and 1 or 0 end)
stipple(fr, {pile=pile{{"lead white",1.4},{"cerulean blue",0.2},{"bone black",0.15}}, width=1.2, coverage=1.3, pressure={0.12,0.35}, cluster={0.6, 6}})
local fb = brush{kind="round", width=0.7, point=0.8}
for i=1,120 do
  local side = math.random(1, 4)
  local x, y, a
  if side == 1 then x = rand(345, 995); y = 150 - (x-340)*46/660 + 4; a = math.pi/2 + rand(-0.5,0.5)
  elseif side == 2 then x = rand(345, 995); y = 372 + (x-340)*32/660 - 4; a = -math.pi/2 + rand(-0.5,0.5)
  elseif side == 3 then x = 346; y = rand(156, 370); a = rand(-0.5,0.5)
  else local mx = (math.random() < 0.5) and 600 or 860; x = mx + ((math.random() < 0.5) and -4 or 4); y = rand(140, 390); a = (x > mx) and rand(-0.5,0.5) or (math.pi + rand(-0.5,0.5)) end
  local L = rand(6, 22)
  fb:reload(pile{{"lead white",1.6},{"cerulean blue",0.25}}, 0.5)
  fb:stroke({{x, y}, {x + L*math.cos(a), y + L*math.sin(a)}}, {pressure={0.3,0.02}, clip=glass})
end
-- the strip's own hot core
local s = brush{kind="round", width=2, point=0.3}
s:reload(pile{{"cadmium red",1},{"vermilion",0.5},{"lead white",0.8}}, 0.9); s:stroke({{0, 380}, {338, 377}}, {pressure={0.55,0.55}})

--@ chunk 6
print(wait(24*60))
local function edge(x,y)
  local dtop = y - (150 - (x-340)*46/660)
  local dbot = (372 + (x-340)*32/660) - y
  local dl = x - 340
  local dm = math.min(math.abs(x - 600), math.abs(x - 860))
  return math.min(dtop, dbot, dl, dm)
end
local mugs = rect(478,280,30,26) + rect(630,280,30,26) + rect(802,280,30,26) + rect(470,305,36,60)
local fr = (WIN * mask(function(x,y) local d = edge(x,y); return (d < 30) and 1 or 0 end)):grow(2) * WIN - mugs
local HZ1 = pile{{"bone black",1.1},{"ultramarine ash",0.6},{"lead white",0.32},{"Mars red",0.08}}
local HZ0 = pile{{"bone black",1.3},{"ultramarine ash",0.5},{"lead white",0.18},{"Mars red",0.12}}
local outer = fr * mask(function(x,y) return (edge(x,y) < 12) and 1 or 0 end)
work(fr - outer, {hand="body", tool={kind="filbert", width=3}, pile=HZ0, coverage=4.5, fill=true, clip=fr, angle=0, length={8,24}})
work(outer, {hand="body", tool={kind="filbert", width=3}, pile=HZ1, coverage=4.5, fill=true, clip=fr, angle=0, length={8,24}})
blend(fr * mask(function(x,y) local d = edge(x,y); return (d > 6 and d < 36) and 1 or 0 end) - mugs, {tool={kind="badger", width=6}})
print(wait(24*60))
-- frame and mullions, crisp and dark again
local FR = pile{{"bone black",1.8},{"ultramarine blue",0.3}}
local rb = brush{kind="round", width=6, point=0.2}
rb:reload(FR, 0.95); rb:stroke({{340,150},{1000,104}}, {pressure={0.8,0.8}})
rb:reload(FR, 0.95); rb:stroke({{340,372},{1000,404}}, {pressure={0.8,0.8}})
rb:reload(FR, 0.95); rb:stroke({{342,150},{342,372}}, {pressure={0.8,0.8}})
for _,x in ipairs({600, 860}) do rb:reload(FR, 0.95); rb:stroke({{x, 132 - (x-600)*0.07}, {x, 386 + (x-600)*0.05}}, {pressure={0.7,0.7}}) end
-- a few fine ice needles, faint
local fb = brush{kind="round", width=0.6, point=0.8}
for i=1,80 do
  local side = math.random(1, 4)
  local x, y, a
  if side == 1 then x = rand(345, 995); y = 150 - (x-340)*46/660 + 4; a = math.pi/2 + rand(-0.5,0.5)
  elseif side == 2 then x = rand(345, 995); y = 372 + (x-340)*32/660 - 4; a = -math.pi/2 + rand(-0.5,0.5)
  elseif side == 3 then x = 347; y = rand(156, 370); a = rand(-0.5,0.5)
  else local mx = (math.random() < 0.5) and 600 or 860; x = mx + ((math.random() < 0.5) and -5 or 5); y = rand(140, 390); a = (x > mx) and rand(-0.5,0.5) or (math.pi + rand(-0.5,0.5)) end
  local L = rand(5, 16)
  fb:reload(pile{{"lead white",1},{"cerulean blue",0.2},{"bone black",0.2}}, 0.45)
  fb:stroke({{x, y}, {x + L*math.cos(a), y + L*math.sin(a)}}, {pressure={0.22,0.02}, clip=WIN - mugs})
end

--@ chunk 7
print(wait(24*60))
local function edge(x,y)
  local dtop = y - (150 - (x-340)*46/660)
  local dbot = (372 + (x-340)*32/660) - y
  local dl = x - 340
  local dm = math.min(math.abs(x - 600), math.abs(x - 860))
  return math.min(dtop, dbot, dl, dm)
end
local mugs = rect(478,280,30,26) + rect(630,280,30,26) + rect(802,280,30,26) + rect(470,305,36,60) + rect(600,345,70,25)
local band = WIN * mask(function(x,y) local d = edge(x,y); return (d >= 6 and d < 42) and 1 or 0 end) - mugs
local function W(m, p, w, ang) if m:area() > 0.3 then work(m, {hand="body", tool={kind="filbert", width=w or 4}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0, length={10,30}}) end end
local function rd(x,y) return (x - 340) + (y - 300)*1.6 end
local BW = BACKW * band
W(BW * mask(function(x,y) return (rd(x,y) < 200) and 1 or 0 end), pile{{"bone black",1.3},{"Mars red",0.45},{"ultramarine ash",0.3}}, 4, math.pi/2)
W(BW * mask(function(x,y) return (rd(x,y) >= 200) and 1 or 0 end), pile{{"bone black",1.5},{"viridian",0.15},{"ultramarine ash",0.45},{"lead white",0.06}}, 4, math.pi/2)
W(CEIL * band, pile{{"bone black",1.7},{"ultramarine ash",0.4}}, 4, 0)
local CF = CFRONT * band
W(CF * mask(function(x,y) return (rd(x,y) < 380) and 1 or 0 end), pile{{"Mars red",1},{"bone black",1.1},{"bone brown",0.3}}, 4, 0)
W(CF * mask(function(x,y) return (rd(x,y) >= 380) and 1 or 0 end), pile{{"bone black",1.6},{"Mars red",0.3},{"bone brown",0.3}}, 4, 0)
W(CTOP * band, pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.12}}, 2, 0)
-- the rim itself: a thin dim rime
local rim = WIN * mask(function(x,y) return (edge(x,y) < 6) and 1 or 0 end) - mugs
W(rim, pile{{"bone black",1.2},{"ultramarine ash",0.6},{"lead white",0.25}}, 2, 0)
blend(WIN * mask(function(x,y) local d = edge(x,y); return (d >= 3 and d < 12) and 1 or 0 end) - mugs, {tool={kind="badger", width=4}})
print(wait(24*60))
local FR = pile{{"bone black",1.8},{"ultramarine blue",0.3}}
local rb = brush{kind="round", width=6, point=0.2}
rb:reload(FR, 0.95); rb:stroke({{340,150},{1000,104}}, {pressure={0.85,0.85}})
rb:reload(FR, 0.95); rb:stroke({{340,372},{1000,404}}, {pressure={0.85,0.85}})
rb:reload(FR, 0.95); rb:stroke({{342,150},{342,372}}, {pressure={0.85,0.85}})
for _,x in ipairs({600, 860}) do rb:reload(FR, 0.95); rb:stroke({{x, 132 - (x-600)*0.07}, {x, 386 + (x-600)*0.05}}, {pressure={0.8,0.8}}) end
local fb = brush{kind="round", width=0.6, point=0.8}
for i=1,70 do
  local side = math.random(1, 4)
  local x, y, a
  if side == 1 then x = rand(345, 995); y = 150 - (x-340)*46/660 + 4; a = math.pi/2 + rand(-0.5,0.5)
  elseif side == 2 then x = rand(345, 995); y = 372 + (x-340)*32/660 - 4; a = -math.pi/2 + rand(-0.5,0.5)
  elseif side == 3 then x = 347; y = rand(156, 370); a = rand(-0.5,0.5)
  else local mx = (math.random() < 0.5) and 600 or 860; x = mx + ((math.random() < 0.5) and -5 or 5); y = rand(140, 390); a = (x > mx) and rand(-0.5,0.5) or (math.pi + rand(-0.5,0.5)) end
  local L = rand(5, 14)
  fb:reload(pile{{"lead white",1},{"cerulean blue",0.2},{"bone black",0.3}}, 0.4)
  fb:stroke({{x, y}, {x + L*math.cos(a), y + L*math.sin(a)}}, {pressure={0.2,0.02}, clip=WIN - mugs})
end

--@ chunk 8
print(wait(24*60))
local TUBE = pile{{"lead white",0.55},{"bone black",0.9},{"ultramarine ash",0.5}}
local TL = pile{{"lead white",0.8},{"bone black",0.5},{"Mars red",0.3}}
local tb = brush{kind="round", width=6, point=0.2}
tb:reload(TUBE, 0.95); tb:stroke({{380,176},{560,166}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
local hl = brush{kind="round", width=1.4, point=0.5}
hl:reload(TL, 0.7); hl:stroke({{382,174},{558,164}}, {pressure={0.4,0.3}})
local fx = brush{kind="round", width=2.4, point=0.2}
fx:reload(pile{{"bone black",1.6}}, 0.9); fx:stroke({{420,160},{420,170}}, {pressure={0.6,0.6}}); fx:stroke({{520,155},{520,165}}, {pressure={0.6,0.6}})
-- hanging tube: restate the full length and the wire
tb:reload(TUBE, 0.95); tb:stroke({{848,140},{770,184},{700,226}}, {pressure={0.8,0.8}, ramps={0.02,0.02}})
hl:reload(TL, 0.7); hl:stroke({{846,138},{768,182},{700,223}}, {pressure={0.4,0.3}})
local wr = brush{kind="round", width=1, point=0.6}
wr:reload(pile{{"bone black",1.6}}, 0.8); wr:stroke({{706,146},{703,190},{700,222}}, {pressure={0.35,0.35}})
-- the knocked-over stool, clearer: seat disc on its edge, post lying on the floor, red light on its top
local ST = pile{{"lead white",0.7},{"bone black",0.7},{"ultramarine ash",0.4}}
local p = brush{kind="round", width=5, point=0.2}
p:reload(ST, 0.95); p:stroke({{640,366},{700,358}}, {pressure={0.85,0.85}})
local d = ellipse(634, 358, 5, 13)
work(d, {hand="detail", tool={kind="round", width=1.2}, pile=ST, coverage=4.5, fill=true, clip=d})
local foot = ellipse(704, 359, 12, 3)
work(foot, {hand="detail", tool={kind="round", width=1.2}, pile=ST, coverage=4.5, fill=true, clip=foot})
local r = brush{kind="round", width=1.4, point=0.5}
r:reload(pile{{"cadmium red",1},{"lead white",0.6}}, 0.7); r:stroke({{641,363},{699,355}}, {pressure={0.4,0.3}})
r:reload(pile{{"cadmium red",1},{"lead white",0.6}}, 0.7); r:stroke({{630,346},{631,370}}, {pressure={0.35,0.3}})
