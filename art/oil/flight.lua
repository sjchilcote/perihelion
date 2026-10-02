-- easel session "flight": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=400, aspect=1.5, linen={14,14}, seed=17,
 ground={{pile={{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.5}}, um=100, apply="knife", texture=0.2}}}
local sp = pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.5}}
work(everywhere(), {hand="body", pile=sp, coverage=2.2, fill=true, tool="filbert 14", length={60,160}, angle=0.15})
print(W,H)

--@ chunk 2
-- sun glare, upper left, partly off-canvas
local g1 = pile{{"lead white",2},{"Mars orange",0.5},{"ultramarine ash",0.3}}
local g2 = pile{{"zinc white",2},{"cadmium yellow",0.5},{"Mars orange",0.2}}
local core = pile{{"zinc white",3},{"lemon chrome",0.3}}
local halo = ellipse(60,60,300,260):soften(60)
work(halo - ellipse(60,60,150,130), {hand="glaze", pile=g1, coverage=1.0, tool="filbert 12", angle=0.6})
work(ellipse(60,60,170,150):roughen(10,60,3), {hand="scumble", pile=g2, coverage=1.6, tool="filbert 10", angle=0.6})
work(ellipse(55,55,85,80), {hand="body", pile=core, coverage=3.5, fill=true, clip=true, tool="filbert 8"})
-- the dart: seen from behind, its rear base big and near, tapering toward the target
local dartP = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1.2}}
dart = poly({{430,430},{470,360},{560,330},{660,290},{700,272},{690,300},{690,400},{660,500},{580,560},{480,560},{430,500}}, true)
work(dart, {hand="body", pile=dartP, coverage=3, fill=true, clip=true, tool="filbert 8", angle=-0.4})

--@ chunk 3
-- soften the sun's hard ring into glare
blend(ellipse(60,60,230,210) - ellipse(55,55,70,65), {angle=0.6, clip=ellipse(60,60,240,220)})
-- dart modeling: lit flank toward the sun (upper-left), scorched plates
local dart = poly({{430,430},{470,360},{560,330},{660,290},{700,272},{690,300},{690,400},{660,500},{580,560},{480,560},{430,500}}, true)
local lit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}
local mid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
local scorch = pile{{"bone black",2},{"burnt sienna",1}}
local b = brush("filbert", 7)
-- plate strokes running from the near base toward the nose
for i=1,9 do
  local t = (i-1)/8
  local x0 = lerp(440,560,t) ; local y0 = lerp(470,330,t)
  b:reload(i<5 and lit or mid, 0.7)
  b:stroke({{x0+rand(-5,5),y0+rand(-5,5)},{lerp(x0,690,0.5),lerp(y0,285,0.5)},{690,285}}, {pressure={0.6,0.1}, ramps={0.1,0.7}, clip=dart})
end
-- rear face: dark engine ring of the base, close to us
local base = ellipse(530,490,85,62)
work(base*dart, {hand="body", pile=scorch, coverage=3, fill=true, clip=true, tool="filbert 6"})
local ring = base:rim(8, 3)
work(ring*dart, {hand="detail", pile=mid, coverage=3, fill=true, clip=true, tool="round 3"})

--@ chunk 4
local dart = poly({{430,430},{470,360},{560,330},{660,290},{700,272},{690,300},{690,400},{660,500},{580,560},{480,560},{430,500}}, true)
local base = ellipse(530,490,85,62)
local dk = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",2}}
local fins = poly({{440,520},{385,575},{470,550}}) + poly({{640,520},{700,585},{610,550}}) + poly({{600,365},{640,320},{650,350}})
-- opaque dark armour body (shadow side away from sun), keep base and lit flank
local flank = ribbon({{440,450},{480,375},{560,340},{650,300},{695,278}}, 22)
work((dart + fins) - base:grow(6) - flank, {hand="body", pile=dk, coverage=3.2, fill=true, clip=true, tool="filbert 6", angle=-0.5})
-- sunlit rim along the upper-left edge, scorched warm
local rimP = pile{{"Mars orange",1},{"yellow ochre",1},{"lead white",1.2}}
local r = brush("filbert", 5)
r:reload(rimP, 0.8)
r:stroke({{436,470},{455,395},{500,358},{580,330},{660,292},{698,275}}, {pressure={0.7,0.15}, ramps={0.1,0.7}})
-- the TESTAMENT: far bronze speck dead ahead with a glint
local bronze = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
work(ellipse(780,205,5,4), {hand="detail", pile=bronze, coverage=3.5, fill=true, clip=true, tool="round 2"})
local gl = pile{{"zinc white",3},{"lemon chrome",0.4}}
local t = brush{kind="round", width=2, point=0.6}
t:reload(gl, 0.8)
t:stroke({{771,205},{789,205}}, {pressure={0.5,0.1}})
t:reload(gl, 0.8)
t:stroke({{780,197},{780,213}}, {pressure={0.4,0.1}})

--@ chunk 5
wait(3*24*60)
local dart = poly({{430,430},{470,360},{560,330},{660,290},{700,272},{690,300},{690,400},{660,500},{580,560},{480,560},{430,500}}, true)
local base = ellipse(530,490,85,62)
local fins = poly({{440,520},{385,575},{470,550}}) + poly({{640,520},{700,585},{610,550}})
local dk = pile{{"Mars brown",2},{"ultramarine blue",1.5},{"bone black",3}}
local flank = ribbon({{440,450},{480,375},{560,340},{650,300},{695,278}}, 16)
work((dart + fins) - base:grow(4) - flank, {hand="body", pile=dk, coverage=4, fill=true, clip=true, tool="filbert 6", angle=-0.5})
-- scorched rear plate: dull the ring to a burnt bronze, deepen the nozzle
local burnt = pile{{"burnt sienna",2},{"bone black",1.5},{"raw sienna",0.5}}
work(base:rim(10,3)*dart, {hand="body", pile=burnt, coverage=3.5, fill=true, clip=true, tool="round 3"})
local noz = pile{{"bone black",3},{"Mars brown",1}}
work(ellipse(530,492,55,40), {hand="body", pile=noz, coverage=4, fill=true, clip=true, tool="filbert 5"})

--@ chunk 6
wait(3*24*60)
local dart = poly({{430,430},{470,360},{560,330},{660,290},{700,272},{690,300},{690,400},{660,500},{580,560},{480,560},{430,500}}, true)
local base = ellipse(530,490,85,62)
local lit = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",1}}
local mid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
local soot = pile{{"bone black",3},{"burnt sienna",0.6}}
local b = brush("filbert", 5)
-- plates on the sun side: tapered strokes converging on the nose
for i=1,6 do
  local t = (i-1)/5
  local x0, y0 = lerp(445,600,t), lerp(440,330,t)
  b:reload(i%2==1 and lit or mid, 0.7)
  b:stroke({{x0,y0},{lerp(x0,692,0.55),lerp(y0,282,0.55)+6},{692,284}}, {pressure={0.55,0.08}, ramps={0.1,0.7}, clip=dart - base:grow(3)})
end
-- scorch streaks blown back along the shadow side
for i=1,7 do
  local x0, y0 = rand(560,680), rand(330,500)
  b:reload(soot, 0.8)
  b:stroke({{692,284},{x0,y0}}, {pressure={0.1,0.5}, ramps={0.3,0.3}, clip=dart - base:grow(3)})
end
-- sun catching the top lip of the rear ring
local rimP = pile{{"zinc white",2},{"Indian yellow",0.6},{"yellow ochre",0.4}}
local r = brush{kind="round", width=3, point=0.6}
r:reload(rimP, 0.8)
r:stroke({{452,480},{470,448},{510,430},{550,430}}, {pressure={0.6,0.15}})
r:reload(rimP, 0.8)
r:stroke({{440,470},{462,400},{510,360}}, {pressure={0.5,0.1}})
-- a few far stars, away from the sun
local st = pile{{"zinc white",3},{"cerulean blue",0.2}}
for i=1,14 do
  local x, y = rand(330,990), rand(10,660)
  if not ((x>400 and x<710 and y>260 and y<590)) then
    local s = brush{kind="round", width=rand(1,2), point=0.5}
    s:reload(st, 0.6)
    s:touch(x, y, {pressure=rand(0.3,0.6)})
  end
end
