-- easel session "core_ratio": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.5, linen=16, seed=7, ground={{pile={{"bone black",2},{"ultramarine blue",1},{"burnt sienna",1},{"lead white",1}}, um=80, apply="knife", texture=0.3}}}

--@ chunk 2
wallP = pile{{"bone black",2},{"ultramarine blue",2},{"burnt sienna",1},{"lead white",0.6}}
floorP = pile{{"bone black",3},{"burnt sienna",1},{"ultramarine blue",1}}
rackP = pile{{"bone black",2},{"ultramarine ash",2},{"lead white",1},{"burnt sienna",0.5}}
doorP = pile{{"lead white",2},{"bone black",1},{"ultramarine blue",0.6},{"yellow ochre",0.4}}
local wall = rect(0,0,1000,520)
work(wall, {hand="broad", pile=wallP, coverage=2.5, fill=true, angle=0})
local floor = rect(0,515,1000,160)
work(floor, {hand="body", pile=floorP, coverage=2.5, fill=true, angle=0, clip=true})
racks = rect(50,60,380,450)
work(racks, {hand="body", pile=rackP, coverage=3, fill=true, angle=math.pi/2, clip=true, edge="firm"})
door = ellipse(800,300,160,200)
work(door, {hand="body", pile=doorP, coverage=3, fill=true, clip=true, angle=0.3})

--@ chunk 3
modP = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1}}
local mods = nil
for c=0,2 do
  for r=0,8 do
    local x = 62 + c*122
    local y = 70 + r*48
    local m = rect(x, y, 112, 40)
    mods = mods and (mods + m) or m
  end
end
work(mods, {hand="body", pile=modP, coverage=3, fill=true, clip=true, angle=0})
local wall2 = rect(0,0,1000,520) - rect(45,55,390,460) - ellipse(800,300,160,200):grow(4)
work(wall2, {hand="body", pile=pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}, coverage=2.5, fill=true, clip=true, angle=0})

--@ chunk 4
steelP = pile{{"bone black",2},{"lead white",1},{"ultramarine ash",1},{"burnt sienna",0.4}}
steelD = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",0.6},{"lead white",0.4}}
local outer = ellipse(800,300,160,200)
local inner = ellipse(800,300,125,160)
work(outer - inner, {hand="body", pile=steelD, coverage=3, fill=true, clip=true, angle=function(x,y) return math.atan(y-300, x-800)+math.pi/2 end})
work(inner, {hand="body", pile=steelP, coverage=3, fill=true, clip=true, angle=0.2})
-- terminal pedestal
termP = pile{{"bone black",3},{"burnt sienna",1},{"ultramarine blue",0.5},{"lead white",0.3}}
local term = poly({{455,330},{610,330},{600,525},{465,525}})
work(term, {hand="body", pile=termP, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 5
print(wait(2*1440))
mods = nil
for c=0,2 do
  for r=0,8 do
    local m = rect(62 + c*122, 70 + r*48, 112, 40)
    mods = mods and (mods + m) or m
  end
end
local frame = rect(50,60,380,450) - mods
frameP = pile{{"bone black",2},{"ultramarine ash",1.5},{"lead white",0.8},{"ultramarine blue",0.4}}
work(frame, {hand="detail", pile=frameP, coverage=3, fill=true, clip=true})
local inner = ellipse(800,300,125,160)
doorIn = pile{{"bone black",2},{"ultramarine ash",1.5},{"lead white",0.7},{"burnt sienna",0.3}}
work(inner, {hand="body", pile=doorIn, coverage=3.5, fill=true, clip=true, angle=0.15})

--@ chunk 6
scrAmber = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",1}}
scrHot = pile{{"zinc white",3},{"lemon chrome",1}}
local scr = rect(474,342,118,72)
work(scr, {hand="detail", pile=scrAmber, coverage=4, fill=true, clip=true})
work(rect(484,352,98,52), {hand="detail", pile=scrHot, coverage=4, fill=true, clip=true})
-- LEDs
ledG = pile{{"emerald green",1},{"zinc white",1.5},{"lemon chrome",0.3}}
ledA = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"zinc white",1}}
ledOff = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.5}}
local tip = brush{kind="round", width=3.2, point=0.3}
for c=0,2 do
  for r=0,8 do
    local x0 = 62 + c*122
    local y = 70 + r*48 + 31
    for k=0,9 do
      local x = x0 + 10 + k*10
      local roll = math.random()
      local p = ledOff
      if roll < 0.045 then p = ledG elseif roll < 0.075 then p = ledA end
      tip:reload(p, 0.7)
      tip:touch(x, y, {pressure=0.7})
    end
  end
end
-- door bolts around ring
boltP = pile{{"lead white",1.5},{"bone black",1},{"ultramarine ash",1}}
local bb = brush{kind="round", width=7, point=0.2}
for i=0,15 do
  local a = i/16*2*math.pi
  bb:reload(boltP, 0.8)
  bb:touch(800+142*math.cos(a), 300+180*math.sin(a), {pressure=0.8})
end

--@ chunk 7
print(wait(1440*2))
-- screen text: a header line and rows of tally ticks, in dark amber-brown
txtP = pile{{"burnt sienna",1},{"Mars brown",1},{"Indian yellow",0.5}}
local pen = brush{kind="rigger", width=1.6, point=1}
pen:load(txtP, 0.6)
-- header "DAYS ALONE" as short letter strokes
local x = 492
for i=1,9 do
  if i ~= 5 then
    pen:stroke({{x,360},{x,368}}, {pressure={0.6,0.6}})
    pen:stroke({{x,360},{x+4,360}}, {pressure={0.5,0.5}})
  end
  x = x + 7
end
-- tally marks, groups of five
pen:load(txtP, 0.6)
for row=0,2 do
  for g=0,5 do
    local gx = 490 + g*15
    local gy = 376 + row*9
    if not (row==2 and g>3) then
      for t=0,3 do pen:stroke({{gx+t*2.5,gy},{gx+t*2.5,gy+6}}, {pressure={0.5,0.4}}) end
      pen:stroke({{gx-1,gy+5},{gx+9,gy+1}}, {pressure={0.4,0.4}})
    end
    if g%2==1 then pen:load(txtP,0.6) end
  end
end
-- bigger lit LEDs
ledG2 = pile{{"emerald green",1},{"zinc white",2},{"lemon chrome",0.4}}
ledA2 = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"zinc white",1.5}}
local tip = brush{kind="round", width=5, point=0.2}
local lit = {{0,1,3,"g"},{0,4,7,"a"},{1,0,2,"g"},{1,3,5,"g"},{1,6,1,"a"},{2,2,8,"g"},{2,5,4,"a"},{0,7,6,"g"},{2,8,0,"g"},{1,8,9,"a"}}
for _,l in ipairs(lit) do
  local px = 62 + l[1]*122 + 10 + l[3]*10
  local py = 70 + l[2]*48 + 31
  tip:reload(l[4]=="g" and ledG2 or ledA2, 0.8)
  tip:touch(px, py, {pressure=0.8})
end
-- scorch on door: smoky radial streaks from lower left
scorchP = pile{{"bone black",3},{"burnt sienna",1},{"Mars brown",1}}
local sm = (ellipse(800,300,160,200) * (ellipse(700,430,170,140):soften(40)))
work(sm, {hand="scumble", pile=scorchP, coverage=1.6, clip=ellipse(800,300,160,200), angle=-0.7, load=0.5})

--@ chunk 8
print(wait(1440))
local door = ellipse(800,300,160,200)
local sm = door * ellipse(700,430,170,140)
-- break the scorch edge with door steel dragged in
lose(sm, {pile=doorIn, where=1, reach={14,30}, load=0.35, tool="filbert 6"})
-- blacken the core of the scorch
local core = (door * ellipse(690,450,120,95)):roughen(18,60,3)
work(core, {hand="scumble", pile=pile{{"bone black",3},{"ultramarine blue",0.5}}, coverage=1.2, load=0.4, clip=door, angle=-0.6})
-- claw gashes: three parallel pale scratches, twice
clawP = pile{{"lead white",2},{"ultramarine ash",1},{"bone black",0.3}}
local r = brush{kind="rigger", width=2.6, point=1}
local sets = {{700,170,0.95},{810,330,1.1}}
for _,s in ipairs(sets) do
  for k=0,3 do
    r:reload(clawP, 0.7)
    local x0, y0 = s[1]+k*14, s[2]+k*4
    r:stroke({{x0,y0},{x0+40,y0+55},{x0+62,y0+110}}, {pressure={0.2,0.8}, swell={0.6,1,0.4}, ramps={0.2,0.4}, shake=1.5})
  end
end
-- warm glow in the air around the screen
glowP = pile{{"lead white",2},{"Mars orange",1},{"cadmium yellow",0.6}, medium=0.4}
local halo = ellipse(533,378,190,150):soften(80) - rect(474,342,118,72)
work(halo, {hand="glaze", pile=glowP, load=0.22, pressure={0.1,0.25}, coverage=1.2})
-- warm pool on the floor
local pool = ellipse(533,560,260,40):soften(40)
work(pool, {hand="glaze", pile=glowP, load=0.25, pressure={0.1,0.25}, coverage=1.3, angle=0})

--@ chunk 9
local halo = ellipse(533,378,260,200) - rect(470,338,126,80); blend(halo, {angle=0}); blend(ellipse(533,560,330,80), {angle=0})

--@ chunk 10
print(wait(3*1440))
local aff = ellipse(533,378,280,215)
local racksR = rect(45,55,390,460)
local doorE = ellipse(800,300,162,202)
local term = poly({{455,330},{610,330},{600,525},{465,525}})
local scr = rect(474,342,118,72)
-- wall: dark, a touch warmer toward the screen
local wallWarm = pile{{"bone black",3},{"burnt sienna",1.4},{"ultramarine blue",0.8},{"Mars orange",0.3}}
local wallCool = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}
local wallA = (aff * rect(0,0,1000,520)) - racksR - doorE - term
work(wallA - ellipse(533,378,160,130), {hand="body", pile=wallCool, coverage=3, fill=true, clip=true, angle=0})
work(wallA * ellipse(533,378,160,130), {hand="body", pile=wallWarm, coverage=3, fill=true, clip=true, angle=0})
-- floor
work((aff + ellipse(533,560,340,90)) * rect(0,520,1000,160), {hand="body", pile=floorP, coverage=3, fill=true, clip=true, angle=0})
-- terminal
work(term - scr, {hand="body", pile=termP, coverage=3.5, fill=true, clip=true, angle=math.pi/2})

--@ chunk 11
local aff = ellipse(533,378,285,220)
mods = nil
for c=0,2 do
  for r=0,8 do
    local m = rect(62 + c*122, 70 + r*48, 112, 40)
    mods = mods and (mods + m) or m
  end
end
local racksR = rect(50,60,380,450)
local fr = (racksR - mods) * aff
work(mods * aff, {hand="body", pile=modP, coverage=3.5, fill=true, clip=true, angle=0})
work(fr, {hand="detail", pile=frameP, coverage=3.5, fill=true, clip=true})
-- door: whole inner disc and ring repainted
local outer = ellipse(800,300,160,200)
local inner = ellipse(800,300,125,160)
work(inner, {hand="body", pile=doorIn, coverage=3.5, fill=true, clip=true, angle=0.15})
work((outer - inner), {hand="body", pile=steelD, coverage=3.5, fill=true, clip=true, angle=function(x,y) return math.atan(y-300, x-800)+math.pi/2 end})

--@ chunk 12
print(wait(1440))
local racksR = rect(50,60,380,450)
local aff = ellipse(533,378,285,220)
work(mods - aff:shrink(6), {hand="body", pile=modP, coverage=3.5, fill=true, clip=true, angle=0})
work((racksR - mods), {hand="detail", pile=frameP, coverage=3.5, fill=true, clip=true})
local patch = rect(640,430,180,50) - ellipse(800,300,160,200)
work(patch * rect(0,0,1000,520), {hand="body", pile=pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}, coverage=3, fill=true, clip=true, angle=0})
work(patch * rect(0,520,1000,160), {hand="body", pile=floorP, coverage=3, fill=true, clip=true, angle=0})
work(rect(100,520,150,30)+rect(820,520,120,30), {hand="body", pile=floorP, coverage=3, fill=true, clip=true, angle=0})

--@ chunk 13
-- module faces: top lip highlight, a handle, an LED strip
lipP = pile{{"bone black",2},{"ultramarine ash",2},{"lead white",1.2}}
lipW = pile{{"bone black",1.5},{"Mars orange",0.6},{"lead white",1.2},{"ultramarine ash",1}}
handP = pile{{"bone black",1},{"ultramarine ash",1},{"lead white",1}}
local fl = brush("flat", 3)
local hd = brush{kind="round", width=3, point=0.2}
local tip = brush{kind="round", width=4, point=0.2}
local ledOff = pile{{"bone black",2},{"ultramarine ash",1},{"lead white",0.3}}
local ledG = pile{{"emerald green",1.5},{"zinc white",1},{"lemon chrome",0.3}}
local ledA = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"zinc white",1}}
for c=0,2 do
  for r=0,8 do
    local x = 62 + c*122
    local y = 70 + r*48
    local warm = (c==2 and r>=3)
    fl:reload(warm and lipW or lipP, 0.6)
    fl:stroke({{x+2,y+3},{x+110,y+3}}, {pressure={0.7,0.6}, orient="across"})
    hd:reload(handP, 0.6)
    hd:stroke({{x+8,y+12},{x+8,y+30}}, {pressure={0.6,0.6}})
    hd:stroke({{x+104,y+12},{x+104,y+30}}, {pressure={0.6,0.6}})
    -- vents
    hd:reload(ledOff, 0.5)
    for v=0,3 do hd:stroke({{x+60+v*8,y+12},{x+60+v*8,y+22}}, {pressure={0.4,0.4}}) end
    for k=0,7 do
      local roll = math.random()
      local p = ledOff
      if roll < 0.05 then p = ledG elseif roll < 0.08 then p = ledA end
      tip:reload(p, 0.8)
      tip:touch(x+18+k*5, y+31, {pressure=0.75})
    end
  end
end
-- right column catches the warm light on its right edge
local re = brush("flat", 4)
re:reload(lipW, 0.7)
re:stroke({{428,180},{428,505}}, {pressure={0.4,0.8}, orient="across"})

--@ chunk 14
local ledG = pile{{"emerald green",1},{"zinc white",2},{"lemon chrome",0.5}}
local ledA = pile{{"cadmium yellow",1},{"Mars orange",0.4},{"zinc white",1.5}}
local haloG = pile{{"emerald green",1},{"viridian",0.5},{"bone black",0.5},{"lead white",0.5}}
local haloA = pile{{"Mars orange",1},{"burnt sienna",0.5},{"bone black",0.5}}
local tip = brush{kind="round", width=5, point=0.2}
local soft = brush{kind="round", width=10, point=0}
math.randomseed(11)
for i=1,22 do
  local c = math.random(0,2); local r = math.random(0,8); local k = math.random(0,7)
  local x = 62 + c*122 + 18 + k*5
  local y = 70 + r*48 + 31
  local g = (i % 3 ~= 0)
  soft:reload(g and haloG or haloA, 0.35)
  soft:touch(x, y, {pressure=0.35})
  tip:reload(g and ledG or ledA, 0.9)
  tip:touch(x, y, {pressure=0.8})
end
-- patch stray marks under the door
work(rect(730,488,160,40), {hand="body", pile=floorP, coverage=3, fill=true, clip=true, angle=0})
work(rect(130,535,90,20), {hand="body", pile=floorP, coverage=3, fill=true, clip=true, angle=0})
-- warm floor pool painted as colour, not glaze
local poolP = pile{{"bone black",2},{"burnt sienna",1.5},{"Mars orange",0.6},{"lead white",0.3}}
work(ellipse(533,555,230,38), {hand="body", pile=poolP, coverage=3, fill=true, angle=0, edge="lost"})
local poolH = pile{{"Mars orange",1},{"burnt sienna",1},{"lead white",0.6},{"bone black",0.4}}
work(ellipse(533,545,110,14), {hand="body", pile=poolH, coverage=2.5, fill=true, angle=0, edge="soft"})

--@ chunk 15
blend(ellipse(533,552,250,46):soften(20), {angle=0})
print(wait(1440))
local ledG = pile{{"emerald green",1},{"zinc white",3},{"lemon chrome",0.6}}
local ledA = pile{{"cadmium yellow",1},{"zinc white",2},{"Mars orange",0.2}}
local tip = brush{kind="round", width=4.5, point=0.2}
math.randomseed(11)
for i=1,22 do
  local c = math.random(0,2); local r = math.random(0,8); local k = math.random(0,7)
  local x = 62 + c*122 + 18 + k*5
  local y = 70 + r*48 + 31
  local g = (i % 3 ~= 0)
  tip:reload(g and ledG or ledA, 1.0)
  tip:touch(x, y, {pressure=0.9})
end

--@ chunk 16
print(wait(3*1440))
local big = ellipse(533,552,275,55)
local inner = ellipse(533,550,170,26)
work(big - inner, {hand="body", pile=floorP, coverage=3.5, fill=true, angle=0, clip=true})
local poolD = pile{{"bone black",2.5},{"burnt sienna",1.2},{"Mars orange",0.3}}
work(inner, {hand="body", pile=poolD, coverage=3.5, fill=true, angle=0, edge="soft"})
local poolC = pile{{"Mars orange",1},{"burnt sienna",1},{"bone black",0.6},{"lead white",0.3}}
work(ellipse(533,545,70,8), {hand="body", pile=poolC, coverage=2.5, fill=true, angle=0, edge="soft"})
-- door bolts
local boltP = pile{{"lead white",1},{"bone black",1},{"ultramarine ash",1}}
local bb = brush{kind="round", width=8, point=0.2}
for i=0,17 do
  local a = i/18*2*math.pi + 0.1
  bb:reload(boltP, 0.8)
  bb:touch(800+142*math.cos(a), 300+180*math.sin(a), {pressure=0.8})
end
-- scorch: broken soot from lower left, stippled
local door = ellipse(800,300,160,200)
local soot = pile{{"bone black",3},{"burnt sienna",0.4}}
stipple(door * ellipse(690,440,190,160):soften(60), {pile=soot, width=7, coverage=function(x,y) return 1.4*smoothstep(260,20,math.sqrt((x-690)^2+(y-440)^2)) end, cluster=0.6, clip=door})

--@ chunk 17
local door = ellipse(800,300,160,200)
local sootG = pile{{"bone black",3},{"Mars brown",0.5}, medium=0.35}
work(door * ellipse(690,440,170,150):soften(50), {hand="scumble", pile=sootG, load=0.3, pressure={0.15,0.4}, coverage=1.0, clip=door, angle=-0.8})
-- repair rack foot
local racksR = rect(50,60,380,450)
work(racksR * rect(250,495,200,20) - mods, {hand="detail", pile=frameP, coverage=3.5, fill=true, clip=true})
work(mods * rect(250,495,200,20), {hand="body", pile=modP, coverage=3.5, fill=true, clip=true, angle=0})

--@ chunk 18
print(wait(2*1440))
-- claw gashes over the scorch: pale bright metal
local clawP = pile{{"lead white",2},{"ultramarine ash",1},{"bone black",0.2}}
local r = brush{kind="rigger", width=3, point=1}
local sets = {{690,250,1},{760,330,1},{705,385,1}}
for _,s in ipairs(sets) do
  for k=0,3 do
    r:reload(clawP, 0.8)
    local x0, y0 = s[1]+k*13, s[2]+k*3
    r:stroke({{x0,y0},{x0+30,y0+40},{x0+48,y0+85}}, {pressure={0.2,0.9}, swell={0.6,1,0.5}, ramps={0.15,0.45}, shake=1.5})
  end
end
-- soften the halo edges
local wallCool = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}
lose(ellipse(533,378,160,130) - rect(455,330,155,200), {pile=wallCool, where=1, reach={10,35}, load=0.3, tool="filbert 8"})
-- terminal: warm-lit top bevel and a keyboard ledge
local bev = pile{{"Mars orange",1},{"lead white",1},{"burnt sienna",0.5}}
local f = brush("flat", 5)
f:reload(bev, 0.8)
f:stroke({{457,333},{608,333}}, {pressure={0.7,0.7}, orient="across"})
local ledge = poly({{462,425},{604,425},{614,445},{452,445}})
work(ledge, {hand="detail", pile=pile{{"bone black",2},{"burnt sienna",1},{"Mars orange",0.4},{"lead white",0.5}}, coverage=3, fill=true, clip=true})
f:reload(bev, 0.6)
f:stroke({{464,427},{602,427}}, {pressure={0.6,0.6}, orient="across"})

--@ chunk 19
local reg = rect(368,215,75,300)
local racksR = rect(50,60,380,450)
work(mods * reg, {hand="body", pile=modP, coverage=3.5, fill=true, clip=true, angle=0})
work((racksR - mods) * reg, {hand="detail", pile=frameP, coverage=3.5, fill=true, clip=true})
-- wall strip right of rack
local wallWarm = pile{{"bone black",3},{"burnt sienna",1.4},{"ultramarine blue",0.8},{"Mars orange",0.3}}
work(rect(431,215,24,300), {hand="detail", pile=wallWarm, coverage=3.5, fill=true, clip=true})

--@ chunk 20
local fl = brush("flat", 3)
local hd = brush{kind="round", width=3, point=0.2}
for r=0,8 do
  local x = 62 + 2*122
  local y = 70 + r*48
  if y >= 210 then
    fl:reload(lipW, 0.6)
    fl:stroke({{x+60,y+3},{x+110,y+3}}, {pressure={0.6,0.7}, orient="across"})
    hd:reload(handP, 0.6)
    hd:stroke({{x+104,y+12},{x+104,y+30}}, {pressure={0.6,0.6}})
    hd:reload(ledOff or modP, 0.5)
    for v=0,3 do hd:stroke({{x+60+v*8,y+12},{x+60+v*8,y+22}}, {pressure={0.4,0.4}}) end
  end
end
-- frost: pale cold crystals creeping along the top edge, the rack top, and the door's upper rim
local frostP = pile{{"zinc white",3},{"cerulean blue",0.5},{"ultramarine ash",0.3}}
local top = above(function(x) return 28 + 18*math.sin(x/37) + 10*math.sin(x/11) end)
local rackTop = rect(48,52,384,14):roughen(5,20,2)
local door = ellipse(800,300,160,200)
local rimTop = (door - ellipse(800,300,145,185)) * rect(600,90,400,120)
stipple(top + rackTop + rimTop, {pile=frostP, width=3, coverage=0.9, cluster=0.5, feather=0.6})

--@ chunk 21
blend(rect(0,0,1000,75), {angle=0.3}); blend(rect(600,85,400,130)*ellipse(800,300,162,202), {angle=0})

--@ chunk 22
local wallCool = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}
lose(rect(-50,-50,1100,125), {pile=wallCool, where=1, reach={8,22}, load=0.25, tool="filbert 5", angle=-math.pi/2})
-- hazard sill under the door
hazA = pile{{"cadmium yellow",1},{"yellow ochre",1},{"Mars orange",0.3},{"bone black",0.25}}
sill = rect(655,492,240,20)
work(sill, {hand="detail", pile=hazA, coverage=3.5, fill=true, clip=true})
print(wait(2*1440))
local hb = brush("flat", 7)
local blk = pile{{"bone black",3},{"burnt sienna",0.4}}
for i=0,15 do
  local x = 655 + i*16
  hb:reload(blk, 0.8)
  hb:stroke({{x,512},{x+12,492}}, {pressure={0.8,0.8}, clip=sill, orient="across"})
end

--@ chunk 23
-- door hub and locking spokes (upper part, clear of scorch)
local hubP = pile{{"bone black",2},{"ultramarine ash",1.5},{"lead white",0.5}}
local hub = ellipse(812,250,42,52)
work(hub, {hand="detail", pile=hubP, coverage=3.5, fill=true, clip=true})
local sp = brush("flat", 6)
local spokes = {{-1.6},{-0.9},{-0.2},{0.5},{-2.3}}
for _,s in ipairs(spokes) do
  local a = s[1]
  sp:reload(hubP, 0.8)
  sp:stroke({{812+44*math.cos(a),250+54*math.sin(a)},{812+112*math.cos(a),250+150*math.sin(a)}}, {pressure={0.8,0.8}, orient="across", clip=ellipse(800,300,124,159)})
end
local hl = brush{kind="round", width=3, point=0.5}
hl:reload(pile{{"lead white",2},{"ultramarine ash",1}}, 0.6)
hl:stroke({{780,215},{800,202},{830,203}}, {pressure={0.3,0.6}})
-- floor plate seams
local seam = pile{{"bone black",3},{"ultramarine blue",0.6}}
local sb = brush{kind="round", width=2.5, point=0.3}
for _,y in ipairs({548, 590, 640}) do
  sb:reload(seam, 0.7)
  sb:stroke({{0,y},{1000,y+2}}, {pressure={0.6,0.6}, shake=0.5})
end
for _,x in ipairs({160, 420, 690, 900}) do
  sb:reload(seam, 0.7)
  sb:stroke({{x,525},{x-12,667}}, {pressure={0.6,0.6}, shake=0.5})
end
-- the screen's thin reflection on the floor
local rp = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6},{"burnt sienna",0.3}}
local rb = brush("flat", 4)
for i=0,4 do
  rb:reload(rp, 0.4 - i*0.05)
  local y = 560 + i*9
  rb:stroke({{500+i*3,y},{566-i*3,y}}, {pressure={0.4,0.3}, orient="across", shake=1})
end

--@ chunk 24
blend(ellipse(533,575,45,32):soften(8), {angle=math.pi/2})

--@ chunk 25
wait(1440)
local ceil = pile{{"bone black",3},{"ultramarine blue",0.8},{"burnt sienna",0.8}}
local wallCool = pile{{"bone black",3},{"ultramarine blue",1},{"burnt sienna",1.2}}
work(rect(0,0,1000,40), {hand="body", pile=ceil, coverage=3.5, fill=true, clip=true, angle=0})
work(rect(0,40,1000,46) - rect(45,48,392,40), {hand="body", pile=wallCool, coverage=3.5, fill=true, clip=true, angle=0})
print(wait(2*1440))
-- hard ceiling edge: a cold steel lip
local lip = brush("flat", 4)
local lipC = pile{{"bone black",2},{"ultramarine ash",2},{"lead white",1}}
lip:reload(lipC, 0.8)
lip:stroke({{0,41},{500,41}}, {pressure={0.8,0.8}, orient="across"})
lip:reload(lipC, 0.8)
lip:stroke({{500,41},{1000,41}}, {pressure={0.8,0.8}, orient="across"})
-- rime: pale crystals hanging just under the edge
local rime = pile{{"zinc white",3},{"cerulean blue",0.4}}
local band = below(function(x) return 41 end) * above(function(x) return 47 + 4*math.sin(x/23) + 3*math.sin(x/7) end)
stipple(band, {pile=rime, width=2, coverage=1.1, cluster=0.4, feather=0.5, clip=band})
-- warm light from the screen on the nearest edges
local warm = pile{{"Mars orange",1},{"lead white",1},{"cadmium yellow",0.4}}
local rg = brush{kind="rigger", width=2.5, point=1}
rg:reload(warm, 0.35)
rg:stroke({{436,250},{436,380},{436,505}}, {pressure={0.15,0.5}, ramps={0.3,0.3}})
rg:reload(warm, 0.3)
local pts = {}
for a = 2.55, 3.75, 0.1 do pts[#pts+1] = {800 + 159*math.cos(a), 300 + 199*math.sin(a)} end
rg:stroke(pts, {pressure={0.1,0.1}, swell={0.3,1,1,0.3}, ramps={0.3,0.3}})
