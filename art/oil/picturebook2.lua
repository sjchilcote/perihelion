-- easel session "picturebook2": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=2, linen={18,16}, seed=2424, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.15}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
function flat(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=m, load=1}); return m end
function F(m, p) work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.5},{"Mars orange",0.12}}
PEACH = pile{{"lead white",2},{"Mars orange",0.35},{"yellow ochre",0.4}}
DUSK = pile{{"lead white",1.6},{"cobalt violet",0.35},{"Mars orange",0.2},{"yellow ochre",0.2}}
GROUND = pile{{"yellow ochre",1},{"lead white",1.2},{"viridian",0.12}}
flat(rect(0,0,496,340), DUSK)
flat(rect(504,0,496,340), PEACH)
flat(below(function(x) return 340 + 10*math.sin(x/80) end) * rect(0,0,1000,430) - rect(496,0,8,500), GROUND)
flat(rect(0,430,496,70) + rect(504,430,496,70), CREAM)
F(rect(496,0,8,500), pile{{"burnt sienna",0.6},{"lead white",1.5},{"yellow ochre",0.4}})

--@ chunk 3
print(wait(3*24*60))
PURP = pile{{"cobalt violet",1},{"magenta",0.35},{"lead white",0.7}}
PURPD = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",0.3}}
KG = pile{{"lead white",1},{"ultramarine ash",0.7},{"yellow ochre",0.25},{"bone black",0.15}}
CR = pile{{"cadmium red",1},{"Mars red",0.6}}
-- LEFT: the bug looming in from the right of the page
BUG = poly({{300,380},{310,250},{360,170},{430,140},{500,140},{500,400}}, true) * rect(0,0,496,500)
F(BUG, PURP)
for k=0,5 do
  local x = 330 + k*30
  F(poly({{x,240-k*14},{x+14,170-k*16},{x+26,236-k*14}}), PURPD)   -- spikes along its back
end
for k=0,3 do local x = 320 + k*42; F(poly({{x,370},{x+10,370},{x+2,420},{x-8,420}}), PURPD) end   -- legs
-- the knight standing in front of Ratio, arms out wide
F(ellipse(205, 175, 46, 44), KG)                                     -- helm
F(poly({{160,214},{250,214},{262,330},{148,330}}, true), KG)       -- body
F(poly({{164,226},{120,250},{84,256},{84,270},{122,266},{168,248}}), KG)   -- left arm out
F(poly({{246,226},{290,232},{320,226},{322,240},{292,250},{244,248}}), KG) -- right arm out toward the bug
F(rect(162,326,30,68) + rect(218,326,30,68), KG)                     -- legs
F(poly({{170,222},{240,222},{250,320},{160,320}}, true), CR)        -- tabard
-- RIGHT: the big warm sun
F(ellipse(890, 110, 66, 66), pile{{"cadmium yellow",1.2},{"Mars orange",0.5},{"lead white",0.6}})
-- the bug curled asleep: a round purple mound
F(ellipse(720, 330, 130, 72), PURP)
for k=0,6 do local a = math.pi*(1.1 + 0.8*k/6)
  local x, y = 720 + 128*math.cos(a), 330 + 70*math.sin(a)
  F(poly({{x-12,y+8},{x + 30*math.cos(a), y + 30*math.sin(a)},{x+12,y+8}}), PURPD) end
F(ellipse(600, 360, 44, 34), PURP)                                    -- its head, tucked in
-- the knight sitting at the right, having a rest
F(ellipse(905, 250, 38, 36), KG)
F(poly({{868,282},{944,282},{952,380},{862,380}}, true), KG)
F(poly({{872,288},{938,288},{944,372},{866,372}}, true), CR)
F(poly({{862,372},{960,372},{966,398},{856,398}}), KG)                -- legs out in front

--@ chunk 4
print(wait(3*24*60))
INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
BONE = pile{{"lead white",2.2},{"yellow ochre",0.4}}
local HAIR = INK
F(rect(496,0,8,500), pile{{"burnt sienna",0.6},{"lead white",1.5},{"yellow ochre",0.4}})
-- visors
F(poly({{164,170},{246,166},{248,188},{162,192}}, true), INK)
F(poly({{872,246},{938,244},{940,262},{870,264}}, true), INK)
-- crosses
F(rect(198,236,12,62) + rect(180,254,48,12), BONE)
F(rect(900,296,10,50) + rect(884,312,42,10), BONE)
-- Ratio's hair on both pages (darks first)
F(poly({{50,300},{90,300},{94,350},{46,350}}), HAIR); F(ellipse(70, 304, 20, 18), HAIR)
F(poly({{560,288},{600,288},{604,338},{556,338}}), HAIR); F(ellipse(580, 292, 20, 18), HAIR)
-- the bug's eyes on the left: big round and worried, and two small fangs
F(ellipse(360, 270, 18, 20), pile{{"zinc white",2.5}}); F(ellipse(404, 262, 18, 20), pile{{"zinc white",2.5}})

--@ chunk 5
print(wait(3*24*60))
local SK = pile{{"lead white",2.6},{"rose madder",0.15},{"yellow ochre",0.1}}
local WH = pile{{"zinc white",2.5}}
local BR = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}}
-- LEFT Ratio peeking out behind the knight's arm
F(poly({{56,306},{84,306},{84,330},{56,330}}), SK)
F(poly({{54,330},{88,330},{92,370},{50,370}}), WH)
F(rect(58,370,9,20) + rect(74,370,9,20), BR)
-- RIGHT Ratio standing by the bug's head, one hand out patting it
F(poly({{566,294},{594,294},{594,318},{566,318}}), SK)
F(poly({{564,318},{598,318},{602,360},{560,360}}), WH)
F(rect(568,360,9,22) + rect(584,360,9,22), BR)
F(poly({{598,326},{618,330},{632,322},{634,330},{618,340},{598,336}}), WH)
F(ellipse(636, 326, 6, 5), SK)
-- left bug pupils, looking down at them; and its fangs
F(ellipse(356, 278, 8, 9), INK); F(ellipse(400, 270, 8, 9), INK)
F(poly({{330,330},{340,330},{334,348}}), BONE); F(poly({{352,334},{362,334},{356,352}}), BONE)

--@ chunk 6
print(wait(2*24*60))
local r = brush{kind="round", width=3, point=0.8}
local function dot(x, y) r:reload(INK, 0.7); r:touch(x, y, {pressure=0.6}) end
dot(65, 316); dot(75, 316); dot(575, 304); dot(585, 304)
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.5); r:touch(70, 323, {pressure=0.4})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.5); r:touch(580, 311, {pressure=0.5, drag={4,0}})  -- smiling
-- the knight's single dot of light on each page
local L = pile{{"lead white",2.5},{"cadmium yellow",0.5}}
r:reload(L, 0.8); r:touch(226, 178, {pressure=0.9}); r:reload(L, 0.8); r:touch(890, 254, {pressure=0.9})
-- the sleeping bug: closed eyes as little arcs and a Zzz
r:reload(INK, 0.7); r:stroke({{582,350},{590,355},{598,350}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}})
r:reload(INK, 0.7); r:stroke({{606,346},{614,351},{622,346}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}})
for i,z in ipairs({{660,250,10},{690,220,14},{730,180,18}}) do
  local x, y, s = z[1], z[2], z[3]
  r:reload(pile{{"cobalt violet",1},{"lead white",0.6}}, 0.7)
  r:stroke({{x,y},{x+s,y},{x,y+s},{x+s,y+s}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
end
-- motion marks: the left bug's spikes bristling, the knight's arms bracing
for _,s in ipairs({{{300,150},{290,138}},{{320,130},{316,116}},{{70,250},{60,244}}}) do r:reload(INK, 0.5); r:stroke(s, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}}) end
-- text lines
local t = brush{kind="round", width=4, point=0.6}
local function text(x0, x1, y)
  local x = x0
  while x < x1 do local l = 8 + (math.floor(x*11) % 22)
    if x + l > x1 then break end
    t:reload(pile{{"bone brown",1.4},{"burnt sienna",0.5}}, 0.7); t:stroke({{x, y},{x+l, y}}, {pressure={t:pressure_for(3), t:pressure_for(3)}})
    x = x + l + 9 end
end
text(60, 440, 456); text(60, 260, 476)
text(560, 940, 456); text(560, 820, 476)

--@ chunk 7
print(wait(4*24*60))
local function G(m, p) work(m, {hand="detail", pile=p, coverage=8, fill=true, clip=m, load=1}) end
local SK = pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}}
local WH = pile{{"zinc white",2.8}}
G(poly({{57,307},{83,307},{83,329},{57,329}}), SK)
G(poly({{54,331},{88,331},{92,370},{50,370}}), WH)
G(poly({{567,295},{593,295},{593,317},{567,317}}), SK)
G(poly({{564,319},{598,319},{602,360},{560,360}}), WH)
G(ellipse(356, 278, 8, 9), INK); G(ellipse(400, 270, 8, 9), INK)
G(ellipse(226, 178, 7, 7), pile{{"lead white",2.5},{"cadmium yellow",0.5}})
G(ellipse(890, 254, 6, 6), pile{{"lead white",2.5},{"cadmium yellow",0.5}})
-- the sleeping bug's face, on the visible part of its head
G(ellipse(628, 368, 22, 20), PURP)

--@ chunk 8
print(wait(3*24*60))
local r = brush{kind="round", width=3, point=0.8}
local function dot(x, y) r:reload(INK, 0.8); r:touch(x, y, {pressure=0.7}) end
dot(65, 316); dot(75, 316); dot(575, 304); dot(585, 304)
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:touch(70, 323, {pressure=0.5})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:stroke({{576,311},{580,313},{584,311}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
r:reload(INK, 0.7); r:stroke({{616,364},{622,368},{628,364}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}})
r:reload(INK, 0.7); r:stroke({{634,362},{640,366},{646,362}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}})
r:reload(pile{{"zinc white",2}}, 0.6); r:touch(359, 274, {pressure=0.4}); r:reload(pile{{"zinc white",2}}, 0.6); r:touch(403, 266, {pressure=0.4})

--@ chunk 9
work(poly({{598,326},{618,330},{632,322},{634,330},{618,340},{598,336}}), {hand="detail", pile=pile{{"zinc white",2.8}}, coverage=8, fill=true, clip=poly({{598,326},{618,330},{632,322},{634,330},{618,340},{598,336}}), load=1})
work(ellipse(604,350,12,6) - poly({{560,319},{602,319},{602,362},{560,362}}), {hand="detail", pile=PURP, coverage=8, fill=true, clip=ellipse(604,350,12,6) - poly({{560,319},{602,319},{602,362},{560,362}}), load=1})
