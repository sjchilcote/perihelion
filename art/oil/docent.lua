-- easel session "docent": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.75, linen={14,14}, seed=71,
 ground={{pile={{"burnt sienna",2},{"bone black",1},{"yellow ochre",1}}, um=120, apply="knife", texture=0.3}}}
dk = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
work(everywhere(), {hand="body", pile=dk, coverage=2.2, fill=true, tool="filbert 14", length={40,120}})
print(W,H)

--@ chunk 2
-- body: bell-shaped robe of bronze, head bowed slightly to its right (our left)
body = poly({{470,330},{560,320},{640,380},{680,520},{720,700},{790,950},{880,1333},{130,1333},{220,960},{290,700},{330,520},{380,390}}, true)
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
local bmid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
work(body, {hand="body", pile=bdark, coverage=2.5, fill=true, angle=math.pi/2, angle_jitter=0.3, edge="firm"})
-- lit side: left/center lower, from lamp
local lit = body * ellipse(470, 930, 260, 330):soften(60)
work(lit, {hand="body", pile=bmid, coverage=2.0, fill=true, angle=math.pi/2, edge="soft"})

--@ chunk 3
-- bone face plate, tilted (head bowed, courteous)
face = poly({{430,380},{520,360},{575,410},{580,500},{545,580},{480,600},{430,560},{410,470}}, true)
local bone_sh = pile{{"yellow ochre",2},{"raw sienna",1},{"bone brown",0.6},{"lead white",1}}
local bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
work(face, {hand="body", pile=bone_sh, coverage=2.5, fill=true, edge="firm", tool="filbert 7", angle=math.pi/2})
local facelit = face * ellipse(470, 540, 90, 90)
work(facelit, {hand="body", pile=bone, coverage=2.2, fill=true, edge="soft", tool="filbert 6", angle=1.2})
-- lamp: glowing bowl held low in front
lamp = ellipse(480, 880, 95, 70)
local glow = pile{{"zinc white",3},{"lemon chrome",1},{"cadmium yellow",0.3}}
local hot = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",1}}
work(lamp, {hand="body", pile=hot, coverage=3, fill=true, edge="soft", tool="filbert 8"})
work(ellipse(480, 870, 55, 38), {hand="body", pile=glow, coverage=3, fill=true, edge="soft", tool="filbert 6"})
-- warm light thrown up the robe near lamp
local warm = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",1}}
work(body * ellipse(480, 820, 230, 200) - lamp:grow(10), {hand="body", pile=warm, coverage=1.6, fill=false, edge="soft", angle=math.pi/2, length={20,50}})

--@ chunk 4
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.6}}
local bmid = pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}
local b = brush("filbert", 12)
-- hood: dark around face
local hood = (ellipse(495,470,150,175) - face:grow(6))
work(hood, {hand="body", pile=bdark, coverage=2.4, fill=true, angle=function(x,y) return math.atan(y-470, x-495) end, length={25,60}, clip=true})
-- folds: long tapered strokes from shoulders down, fanning
for i=0,22 do
  local t = i/22
  local x0 = lerp(380, 620, t) + rand(-10,10)
  local x1 = lerp(170, 840, t) + rand(-20,20)
  local d = math.abs(x1-480)
  local p = (i%3==0) and bdark or ((d < 200 and i%3==1) and blit or bmid)
  b:reload(p, 0.8)
  local ym = rand(620, 720)
  b:stroke({{x0, 620}, {lerp(x0,x1,0.45)+rand(-15,15), ym+150}, {x1, 1320}}, {pressure={0.8,0.5}, ramps={0.15,0.3}, clip=body - lamp:grow(25)})
end

--@ chunk 5
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.6}}
local bmid = pile{{"raw sienna",2},{"bone black",0.8},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"burnt sienna",1},{"lead white",0.6}}
-- break the disc: mid/dark band across its rim
local ring = (body * ellipse(470,770,300,260):grow(40) - ellipse(475,800,180,150)):roughen(25,80,5)
work(ring - lamp:grow(20), {hand="body", pile=bmid, coverage=2.2, fill=true, angle=math.pi/2, angle_jitter=0.4, edge="lost", length={30,70}})
-- sleeves / arms reaching to cradle the lamp
local armL = ribbon({{360,640},{330,760},{360,860},{420,910}}, {55,60,55,40})
local armR = ribbon({{610,630},{650,750},{620,860},{545,905}}, {55,62,55,40})
work(armL + armR, {hand="body", pile=bdark, coverage=2.5, fill=true, angle=function(x,y) return math.pi/2 end, edge="firm", length={20,50}, clip=true})
-- lit inner edges of sleeves (from lamp)
local litL = ribbon({{385,700},{370,780},{395,860},{435,895}}, 18)
local litR = ribbon({{590,690},{615,770},{595,850},{540,890}}, 18)
work(litL + litR, {hand="body", pile=blit, coverage=2, fill=true, tool="filbert 5", edge="soft", length={15,40}})

--@ chunk 6
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"ultramarine blue",0.5}}
-- shadow the robe's outer flanks and lower hem, away from lamp
local shade = (body - ellipse(480,820,250,240)):roughen(20,90,9)
work(shade, {hand="body", pile=bdark, coverage=2.4, fill=true, angle=math.pi/2, angle_jitter=0.25, length={40,100}, clip=body, edge="soft"})
-- clean background around silhouette where the ring spilled
local bg = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
work((-body):shrink(0) * rect(0,500,1000,833) * body:grow(60), {hand="body", pile=bg, coverage=2.4, fill=true, clip=-body, length={20,50}})

--@ chunk 7
print(wait(3*24*60))
local bone_sh = pile{{"yellow ochre",2},{"raw sienna",1},{"bone brown",0.5},{"lead white",1.5}}
local bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
work(face, {hand="body", pile=bone_sh, coverage=3, fill=true, clip=true, tool="filbert 7", angle=1.4, length={15,40}})
local facelit = (face * poly({{410,470},{580,440},{580,600},{410,600}})):roughen(10,40,3)
work(facelit, {hand="body", pile=bone, coverage=2.5, fill=true, clip=face, tool="filbert 6", angle=0.3, length={15,35}})
-- break the chest ring: bronze strokes following the curve of shoulders/chest
local bmid = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
local bdk = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.5}}
local chest = (body * ellipse(480,760,290,250) - lamp:grow(30) - (ellipse(480,820,150,140))):roughen(30,100,11)
work(chest, {hand="body", pile=bdk, coverage=1.8, fill=true, angle=function(x,y) return math.atan(y-1000, x-480)+math.pi/2 end, length={30,80}, clip=body, edge="lost"})

--@ chunk 8
local bmid = pile{{"raw sienna",2},{"bone black",0.8},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"Mars orange",0.5},{"lead white",0.8}}
local bdk = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.5}}
-- sleeves, broad bell-cuffs reaching to the lamp
local armL = poly({{340,600},{400,620},{410,760},{450,880},{400,930},{330,900},{300,780}}, true)
local armR = poly({{600,600},{660,620},{690,780},{650,900},{560,930},{530,880},{600,760}}, true)
work(armL + armR, {hand="body", pile=bmid, coverage=2.6, fill=true, angle=math.pi/2, angle_jitter=0.3, length={25,60}, clip=true})
local lL = ribbon({{395,640},{405,770},{440,870}}, {10,22,26})
local lR = ribbon({{610,640},{600,770},{560,870}}, {10,22,26})
work(lL + lR, {hand="body", pile=blit, coverage=2.4, fill=true, tool="filbert 5", clip=armL+armR, length={15,40}, angle=math.pi/2})
-- shadow on sleeve outer sides
local oL = ribbon({{330,640},{310,780},{340,900}}, 24)
local oR = ribbon({{660,640},{685,780},{660,890}}, 24)
work((oL+oR)*(armL+armR), {hand="body", pile=bdk, coverage=2.4, fill=true, tool="filbert 6", clip=true, length={20,50}, angle=math.pi/2})

--@ chunk 9
local bowl = pile{{"bone black",1.5},{"burnt sienna",1},{"raw sienna",1}}
local bowlit = pile{{"Indian yellow",1},{"yellow ochre",1},{"lead white",0.5},{"Mars orange",0.5}}
local hot = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1.2}}
local glow = pile{{"zinc white",3},{"lemon chrome",0.6}}
-- bowl: lower half ellipse, with a lit rim
local bowlm = ellipse(480,905,85,45) * rect(380,895,200,60)
work(bowlm, {hand="body", pile=bowl, coverage=3, fill=true, clip=true, tool="filbert 5", angle=0, length={15,40}})
work(ribbon({{398,898},{440,910},{480,913},{520,910},{562,898}}, 7), {hand="body", pile=bowlit, coverage=2.5, fill=true, tool="round 4", clip=true, angle=0})
-- flame: teardrop above the bowl
local flame = poly({{480,800},{500,850},{505,880},{480,895},{455,880},{460,850}}, true)
work(flame:grow(14), {hand="body", pile=hot, coverage=2.6, fill=true, clip=true, tool="filbert 5", angle=-math.pi/2, length={10,30}})
work(flame, {hand="body", pile=glow, coverage=3, fill=true, clip=true, tool="filbert 4", angle=-math.pi/2, length={10,25}})
-- bone fingers cupping the bowl from each side
local bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.4}}
local boneS = pile{{"yellow ochre",2},{"raw sienna",1},{"bone brown",0.6},{"lead white",1}}
local f = brush{kind="round", width=7, point=0.5}
for i=0,3 do
  f:reload(i%2==0 and bone or boneS, 0.8)
  f:stroke({{405, 880+i*10}, {420, 905+i*10}, {450,925+i*7}}, {pressure={0.8,0.4}, ramps={0.1,0.5}})
  f:reload(i%2==0 and boneS or bone, 0.8)
  f:stroke({{560, 878+i*10}, {542, 905+i*10}, {512,925+i*7}}, {pressure={0.8,0.4}, ramps={0.1,0.5}})
end

--@ chunk 10
wait(2*24*60)
local dk = pile{{"bone black",2},{"burnt sienna",1}}
local gold = pile{{"Indian yellow",1},{"yellow ochre",1},{"lead white",0.6}}
local verd = pile{{"viridian",1},{"cerulean blue",1},{"lead white",2},{"yellow ochre",0.5}}
-- eyes: downcast slots
local r = brush{kind="round", width=6, point=0.7}
r:reload(dk, 0.9)
r:stroke({{448,478},{465,484},{482,482}}, {pressure={0.3,0.2}, swell={0.6,1.3,0.5}})
r:reload(dk, 0.9)
r:stroke({{512,478},{530,481},{547,474}}, {pressure={0.3,0.2}, swell={0.6,1.3,0.5}})
-- golden-angle rosette on the brow
local g = brush{kind="round", width=3, point=0.6}
local ga = math.pi*(3-math.sqrt(5))
for k=1,34 do
  if k%6==1 then g:reload(gold, 0.7) end
  local rr = 3.4*math.sqrt(k)
  local a = k*ga
  g:touch(498+rr*math.cos(a), 425+rr*math.sin(a)*0.85, {pressure=0.5})
end
-- the crack: from crown down across the right eye, mended with bronze staples
local c = brush{kind="round", width=2.5, point=0.8}
c:reload(dk, 0.8)
c:stroke({{548,372},{540,400},{552,430},{538,455},{545,500},{528,540},{534,575}}, {pressure={0.5,0.2}, shake=1.5})
local s = brush{kind="flat", width=3}
for i,y in ipairs({395,440,490,530}) do
  local x = ({541,546,543,531})[i]
  s:reload(verd, 0.8)
  s:stroke({{x-9,y-2},{x+9,y+2}}, {pressure={0.7,0.7}})
end
-- mouth: a small grille of bone slits, closed in courtesy
r:reload(dk, 0.6)
for i=0,3 do r:stroke({{478+i*9,545},{479+i*9,560}}, {pressure={0.15,0.1}}) end

--@ chunk 11
local bone = pile{{"lead white",3},{"yellow ochre",1},{"raw sienna",0.3}}
local boneS = pile{{"yellow ochre",2},{"raw sienna",1},{"bone brown",0.6},{"lead white",1.2}}
local lower = face * rect(400,497,200,120)
work(lower:shrink(3), {hand="body", pile=bone, coverage=3, fill=true, clip=face, tool="filbert 5", angle=0.1, length={12,30}})
-- shadowed edge of the face plate, right and chin underside
work((face - face:shrink(16)) * rect(530,360,80,260), {hand="body", pile=boneS, coverage=2.4, fill=true, clip=face, tool="filbert 4", angle=math.pi/2, length={12,30}})
-- crown shadow
work(face * rect(400,350,200,45):roughen(8,40,2), {hand="body", pile=boneS, coverage=2, fill=true, clip=face, tool="filbert 5", angle=0, length={12,30}})

--@ chunk 12
local midb = pile{{"lead white",2},{"yellow ochre",1.3},{"raw sienna",0.5}}
work(face * rect(400,485,200,28):roughen(6,30,4), {hand="scumble", pile=midb, coverage=1.6, clip=face, tool="filbert 4", angle=0})
blend(face * rect(400,490,200,30), {angle=0, clip=true})
wait(2*24*60)
local dk = pile{{"bone black",2},{"burnt sienna",1}}
local inlay = pile{{"burnt sienna",1},{"Indian yellow",1},{"raw sienna",1}}
local bronzeg = pile{{"viridian",0.6},{"raw sienna",2},{"bone black",0.4},{"yellow ochre",0.5}}
local g = brush{kind="round", width=5, point=0.5}
local ga = math.pi*(3-math.sqrt(5))
for k=1,55 do
  if k%5==1 then g:reload(inlay, 0.8) end
  local rr = 4.6*math.sqrt(k)
  local a = k*ga
  g:touch(492+rr*math.cos(a), 425+rr*math.sin(a)*0.85, {pressure=0.55})
end
local c = brush{kind="round", width=3, point=0.8}
c:reload(dk, 0.8)
c:stroke({{534,500},{545,530},{528,560},{534,600}}, {pressure={0.5,0.15}, shake=1.5})
local s = brush{kind="flat", width=4}
for i,y in ipairs({372,395,440,490,540,575}) do
  local x = ({548,541,546,543,540,530})[i]
  s:reload(bronzeg, 0.9)
  s:stroke({{x-10,y-2},{x+10,y+2}}, {pressure={0.8,0.8}})
end
local r = brush{kind="round", width=4, point=0.6}
r:reload(dk, 0.8)
for i=0,4 do r:stroke({{470+i*9,548},{471+i*9,566}}, {pressure={0.4,0.3}}) end

--@ chunk 13
local dk = pile{{"bone black",2},{"burnt sienna",1}}
local r = brush{kind="round", width=6, point=0.7}
r:reload(dk, 0.9)
r:stroke({{446,477},{463,484},{481,482}}, {pressure={0.35,0.2}, swell={0.6,1.3,0.5}})
-- halo of lamplight in the dark: thin warm glazes (lead white + Mars orange, low load)
local haze = pile{{"lead white",2},{"Mars orange",1},{"yellow ochre",0.5}, medium=0.5}
local halo = ellipse(480,860,330,300):blur(80) - body:shrink(0)
work(halo, {hand="glaze", pile=haze, load=0.25, pressure={0.1,0.22}, coverage=1.2, tool="filbert 14", length={60,140}})

--@ chunk 14
wait(4*24*60)
local warmdk = pile{{"burnt sienna",2},{"ultramarine blue",1.2},{"bone black",0.6}}
local zone = (rect(0,560,1000,560) - body:grow(4)):roughen(30,120,7)
work(zone, {hand="body", pile=warmdk, coverage=3, fill=true, clip=-body, tool="filbert 14", length={50,120}, angle_jitter=0.6})

--@ chunk 15
local warmdk = pile{{"burnt sienna",2},{"ultramarine blue",1.2},{"bone black",0.6}}
local bgall = -body:grow(3)
work(bgall, {hand="body", pile=warmdk, coverage=2.6, fill=true, clip=bgall, tool="filbert 16", length={60,140}, angle=function(x,y) return 1.2 + 0.3*math.sin(x/200) end})
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.6}}
local flank = (body - body:shrink(70)) * rect(0,600,1000,450) - ellipse(480,770,170,200)
work(flank, {hand="body", pile=bdark, coverage=3, fill=true, clip=body, tool="filbert 10", length={30,70}, angle=math.pi/2, angle_jitter=0.2})

--@ chunk 16
wait(2*24*60)
local bmid = pile{{"raw sienna",2},{"bone black",0.6},{"burnt sienna",1},{"yellow ochre",0.5}}
local blit = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.9}}
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
-- collar: a worn bronze ring beneath the face
local collar = ribbon({{385,575},{430,605},{485,615},{545,605},{595,572}}, 22)
work(collar, {hand="body", pile=bmid, coverage=3, fill=true, clip=true, tool="filbert 6", angle=0, length={15,40}})
work(ribbon({{395,585},{440,612},{485,621},{535,612},{585,582}}, 6), {hand="body", pile=blit, coverage=2.5, fill=true, clip=collar, tool="round 4", angle=0, length={10,30}})
-- inscription band at the hem of the bell (fold-notation)
local bandpts = {{215,975},{340,1000},{480,1008},{620,1000},{770,972}}
local band = ribbon(bandpts, 34) * body
work(band, {hand="body", pile=bmid, coverage=3, fill=true, clip=true, tool="filbert 8", angle=0, length={20,60}})

--@ chunk 17
wait(2*24*60)
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.9}}
local band = ribbon({{215,975},{340,1000},{480,1008},{620,1000},{770,972}}, 34) * body
-- shade the band's ends (turning away from the lamp)
work(band * (rect(0,900,330,200) + rect(650,900,350,200)), {hand="body", pile=bdark, coverage=2, fill=true, clip=band, tool="filbert 6", angle=0, length={15,40}, edge="soft"})
-- fold-notation: rows of folded marks, incised; dashes, hooks, doubled strokes
local r = brush{kind="round", width=3, point=0.7}
local x = 250
local k = 0
while x < 740 do
  k = k + 1
  local t = (x-215)/(770-215)
  local yc = 975 + 33*math.sin(t*math.pi) - 2
  if k % 4 == 1 then r:reload(bdark, 0.8) end
  local kind = (k*7) % 5
  if kind == 0 then r:stroke({{x,yc-9},{x,yc+9}}, {pressure={0.5,0.3}})
  elseif kind == 1 then r:stroke({{x-4,yc-8},{x+4,yc},{x-4,yc+8}}, {pressure={0.5,0.3}})
  elseif kind == 2 then r:stroke({{x-4,yc-8},{x-4,yc+8}}, {pressure={0.4,0.3}}); r:stroke({{x+3,yc-8},{x+3,yc+8}}, {pressure={0.4,0.3}})
  elseif kind == 3 then r:stroke({{x-5,yc+6},{x,yc-8},{x+5,yc+6}}, {pressure={0.5,0.3}})
  else r:touch(x, yc, {pressure=0.8}) end
  x = x + rand(13, 20)
end
-- worn highlight along the band's upper edge near the lamp
work(ribbon({{360,985},{480,992},{600,985}}, 5), {hand="body", pile=blit, coverage=2, fill=true, clip=band, tool="round 3", angle=0, length={10,30}})

--@ chunk 18
local bmid = pile{{"raw sienna",2},{"bone black",0.7},{"burnt sienna",1}}
local blit = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.9}}
local hi = pile{{"lead white",2},{"Indian yellow",1},{"yellow ochre",0.5}}
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
-- soften band-end seams
for _,sx in ipairs({330,650}) do
  work(rect(sx-15,950,30,70) * ribbon({{215,975},{340,1000},{480,1008},{620,1000},{770,972}}, 34), {hand="scumble", pile=bmid, coverage=1.5, tool="filbert 4", clip=true})
end
-- hood: lit inner rim around the face, catching the lamp from below
local f = brush("filbert", 6)
f:reload(blit, 0.8)
f:stroke({{405,560},{392,500},{400,430},{430,375}}, {pressure={0.7,0.2}, ramps={0.1,0.6}})
f:reload(blit, 0.8)
f:stroke({{588,555},{600,490},{592,425},{565,370}}, {pressure={0.7,0.15}, ramps={0.1,0.6}})
-- the bell's long folds: lit ridges rising from the hem toward the lamp
local b = brush("filbert", 9)
for i,x in ipairs({300,370,440,530,600,680}) do
  b:reload(i%2==0 and blit or bmid, 0.7)
  local x1 = lerp(x, 480, 0.35)
  b:stroke({{x + (x-480)*0.5, 1320}, {lerp(x,x1,0.5)+(x-480)*0.2, 1150}, {x1, 1030}}, {pressure={0.6,0.1}, ramps={0.2,0.6}, clip=body - ribbon({{215,975},{340,1000},{480,1008},{620,1000},{770,972}}, 36)})
end
-- specular sparks on the sleeve cuffs nearest the flame
local r = brush{kind="round", width=4, point=0.5}
r:reload(hi, 0.8)
r:stroke({{428,860},{440,880}}, {pressure={0.6,0.2}})
r:reload(hi, 0.8)
r:stroke({{540,858},{527,880}}, {pressure={0.6,0.2}})

--@ chunk 19
local bmid = pile{{"raw sienna",2},{"bone black",0.6},{"burnt sienna",1},{"yellow ochre",0.4}}
local blit = pile{{"yellow ochre",2},{"Mars orange",0.6},{"lead white",0.9}}
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
local hi = pile{{"lead white",2},{"Indian yellow",1},{"yellow ochre",0.5}}
local clipm = body - ribbon({{215,975},{340,1000},{480,1008},{620,1000},{770,972}}, 36)
local b = brush("filbert", 16)
for i,x in ipairs({300,370,440,530,600,680}) do
  local x1 = lerp(x, 480, 0.35)
  local s = (x < 480) and 1 or -1
  b:reload(bmid, 0.6)
  b:stroke({{x + (x-480)*0.5 + s*14, 1320}, {lerp(x,x1,0.5)+(x-480)*0.2 + s*10, 1150}, {x1 + s*6, 1030}}, {pressure={0.5,0.1}, ramps={0.2,0.6}, clip=clipm})
end
-- chest catching the flame between the sleeves
local chest = poly({{420,660},{545,660},{560,800},{510,830},{450,830},{405,800}}, true)
work(chest:roughen(10,40,3), {hand="scumble", pile=blit, coverage=1.3, tool="filbert 6", clip=chest, angle=math.pi/2})
-- damage: a chip broken out of the hood's crown, upper right
local chip = poly({{600,360},{640,375},{655,420},{630,445},{612,410}})
work(chip, {hand="body", pile=bdark, coverage=3, fill=true, clip=true, tool="filbert 4"})
local r = brush{kind="round", width=3, point=0.6}
r:reload(hi, 0.8)
r:stroke({{600,360},{612,410},{630,445}}, {pressure={0.5,0.3}, shake=1.2})

--@ chunk 20
wait(3*24*60)
local bmid = pile{{"raw sienna",2},{"bone black",0.5},{"burnt sienna",1},{"yellow ochre",0.8}}
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
local hot = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1.2}}
local glow = pile{{"zinc white",3},{"lemon chrome",0.6}}
plate = poly({{420,660},{545,660},{560,800},{510,830},{450,830},{405,800}}, true)
-- upper plate turns away from the flame
work(plate * rect(380,640,200,75):roughen(10,40,8), {hand="body", pile=bmid, coverage=2.2, fill=true, clip=plate, tool="filbert 6", angle=0, length={15,40}, edge="soft"})
-- the plate's rim
local o = brush{kind="round", width=4, point=0.4}
o:reload(bdark, 0.9)
o:stroke({{405,800},{412,700},{425,662},{485,656},{542,662},{555,720},{560,800}}, {pressure={0.6,0.5}})
-- flame restated in front of the plate's foot
local flame = poly({{480,790},{500,840},{505,875},{480,893},{455,875},{460,840}}, true)
work(flame:grow(12), {hand="body", pile=hot, coverage=2.6, fill=true, clip=true, tool="filbert 5", angle=-math.pi/2, length={10,30}})
work(flame, {hand="body", pile=glow, coverage=3, fill=true, clip=true, tool="filbert 4", angle=-math.pi/2, length={10,25}})

--@ chunk 21
wait(2*24*60)
local bdark = pile{{"bone black",2},{"burnt sienna",1}}
local sien = pile{{"burnt sienna",2},{"bone black",0.5}}
local mid = pile{{"raw sienna",2},{"yellow ochre",1},{"lead white",0.3}}
-- soften the hard seam on the plate with a mid scumble
work(plate * rect(400,700,170,22), {hand="scumble", pile=mid, coverage=1.0, tool="filbert 4", clip=plate, angle=0})
-- rim
local o = brush{kind="round", width=4, point=0.4}
local segs = {{{407,800},{410,720},{422,668}}, {{422,668},{485,657},{545,664}}, {{545,664},{556,730},{560,800}}}
for _,s in ipairs(segs) do o:reload(bdark, 0.9); o:stroke(s, {pressure={0.55,0.5}}) end
-- the lesson: rows of fold-notation, written small, incised
local r = brush{kind="round", width=2.4, point=0.8}
local rows = {685, 705, 728, 750, 772}
for ri,y in ipairs(rows) do
  local x = 428 + rand(0,6)
  local n = 0
  while x < 538 do
    n = n + 1
    if n % 5 == 1 then r:reload(ri <= 2 and bdark or sien, 0.8) end
    local kind = math.random(0,4)
    if kind == 0 then r:stroke({{x,y-5},{x,y+5}}, {pressure={0.5,0.3}})
    elseif kind == 1 then r:stroke({{x-3,y-5},{x+3,y},{x-3,y+5}}, {pressure={0.5,0.3}})
    elseif kind == 2 then r:stroke({{x-3,y+4},{x,y-5},{x+3,y+4}}, {pressure={0.5,0.3}})
    elseif kind == 3 then r:stroke({{x-3,y-5},{x-3,y+5}}, {pressure={0.4,0.3}}); r:stroke({{x+2,y-5},{x+2,y+5}}, {pressure={0.4,0.3}})
    else r:touch(x, y, {pressure=0.7}) end
    x = x + rand(8, 13)
    if math.random() < 0.12 then x = x + 10 end
  end
end

--@ chunk 22
local nearblk = pile{{"bone black",2},{"burnt sienna",1.2},{"ultramarine blue",0.4}}
local bgm = (-body:grow(3)) - ellipse(490,720,330,420):roughen(40,150,3)
work(bgm, {hand="body", pile=nearblk, coverage=2.8, fill=true, clip=-body:grow(3), tool="filbert 16", length={60,140}, angle=function(x,y) return 1.1 + 0.4*math.sin(y/250) end})

--@ chunk 23
wait(2*24*60)
local warm = pile{{"Mars brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local aura = (ellipse(490,720,350,440):roughen(30,150,3):grow(10)) - body:grow(3)
work(aura, {hand="body", pile=warm, coverage=2.6, fill=true, clip=-body:grow(3), tool="filbert 12", length={40,110}, angle=function(x,y) return math.atan(y-820, x-490)+math.pi/2 end, edge="lost"})

--@ chunk 24
local midd = pile{{"Mars brown",1.2},{"bone black",1},{"burnt sienna",0.6}}
local aura = (ellipse(490,720,350,440):roughen(30,150,3):grow(10))
local seam = (aura:grow(45) - aura:shrink(45)) - body:grow(3)
work(seam, {hand="body", pile=midd, coverage=2.4, fill=true, clip=-body:grow(3), tool="filbert 10", length={30,80}, angle=function(x,y) return math.atan(y-820, x-490)+math.pi/2 end})
blend(seam:shrink(6), {angle=function(x,y) return math.atan(y-820, x-490) end, clip=true})

--@ chunk 25
wait(24*60)
local bdark = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",0.4}}
-- quiet the hem: pleats fade into shadow toward the floor
local hem = body * rect(0,1170,1000,170):roughen(25,100,5)
work(hem, {hand="body", pile=bdark, coverage=2.2, fill=true, clip=body, tool="filbert 10", angle=math.pi/2, length={30,80}, edge="soft"})
-- clean stray light marks on the shoulders beside the collar
local sh = (ribbon({{280,560},{330,545},{380,560}}, 30) + ribbon({{600,560},{650,548},{720,575}}, 30)) * body - plate:grow(10)
work(sh, {hand="body", pile=bdark, coverage=2.6, fill=true, clip=body, tool="filbert 6", angle=0.2, length={20,50}})

--@ chunk 26
local nb = pile{{"bone black",2.5},{"burnt sienna",1},{"ultramarine blue",0.3}}
local hem = body * below(function(x) return 1150 + 40*math.sin(x/70) + 25*math.sin(x/23) end)
work(hem, {hand="body", pile=nb, coverage=3.4, fill=true, clip=body, tool="filbert 10", angle=math.pi/2, angle_jitter=0.3, length={40,90}, edge="loose"})
