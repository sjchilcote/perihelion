-- easel session "picturebook3": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=2, linen={18,16}, seed=2525, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.15}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
function flat(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=m, load=1}); return m end
function F(m, p) work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.5},{"Mars orange",0.12}}
PEACH = pile{{"lead white",2},{"Mars orange",0.35},{"yellow ochre",0.4}}
GOLD = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.3}}
LRING = (ellipse(250, 1000, 640, 640) - ellipse(250, 1000, 604, 604)) * rect(0,0,496,430)
RRING = (ellipse(760, 1110, 770, 770) - ellipse(760, 1110, 734, 734)) * rect(504,0,496,430)
SUN = ellipse(880, 230, 66, 66)
flat(LRING + RRING, GOLD)
flat(SUN, pile{{"cadmium yellow",1.2},{"Mars orange",0.5},{"lead white",0.6}})
flat(rect(504,0,496,430) - RRING - SUN - ellipse(760,1110,734,734), PEACH)
flat(rect(0,430,496,70) + rect(504,430,496,70), CREAM)
F(rect(496,0,8,500), pile{{"burnt sienna",0.6},{"lead white",1.5},{"yellow ochre",0.4}})

--@ chunk 3
print(wait(2*24*60))
NIGHT = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
local inL = ellipse(250, 1000, 604, 604) * rect(0,0,496,430)
local inR = ellipse(760, 1110, 734, 734) * rect(504,0,496,430)
flat(rect(0,0,496,430) - LRING - inL, NIGHT)
flat(inL, pile{{"bone black",1},{"burnt sienna",0.6},{"ultramarine blue",0.3}})
flat(inR, pile{{"yellow ochre",1},{"lead white",1.2},{"viridian",0.12}})

--@ chunk 4
print(wait(2*24*60))
INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
PURP = pile{{"cobalt violet",1},{"magenta",0.35},{"lead white",0.7}}
PURPD = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",0.3}}
KG = pile{{"lead white",1},{"ultramarine ash",0.6},{"yellow ochre",0.35},{"burnt sienna",0.1}}
CR = pile{{"cadmium red",1},{"Mars red",0.6}}
-- LEFT, from behind, sitting on the ring under the stars
-- the knight
F(ellipse(360, 210, 44, 42), KG)
F(poly({{316,244},{404,244},{416,352},{304,352}}, true), KG)
F(poly({{324,250},{396,250},{404,346},{316,346}}, true), CR)
-- the bug, curled and sleepy, at the left
F(ellipse(120, 326, 74, 40), PURP)
for k=0,4 do local x = 76 + k*22; F(poly({{x-8,296},{x,270-k*2},{x+8,296}}), PURPD) end
F(ellipse(190, 318, 28, 24), PURP)
-- Ratio between them: hair framing a three-quarter face turned up, arm pointing
F(poly({{232,268},{266,268},{270,330},{228,330}}), INK)       -- hair down her back
F(ellipse(250, 266, 18, 16), INK)
-- RIGHT, small and far: the bug trotting behind, the knight, Ratio, walking to the sun
F(ellipse(588, 336, 24, 13), PURP)
for k=0,2 do F(poly({{574+k*12,326},{580+k*12,312},{586+k*12,326}}), PURPD) end
for k=0,3 do F(rect(572+k*10, 344, 4, 10), PURPD) end
F(ellipse(650, 282, 16, 15), KG)
F(poly({{636,294},{664,294},{668,330},{632,330}}, true), KG)
F(poly({{638,298},{662,298},{664,328},{636,328}}, true), CR)
F(rect(637,328,10,16) + rect(653,328,10,16), KG)
F(poly({{684,302},{702,302},{704,330},{682,330}}), INK)        -- Ratio's hair (behind)
F(ellipse(693, 302, 11, 10), INK)

--@ chunk 5
print(wait(3*24*60))
local SK = pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}}
local WH = pile{{"zinc white",2.8}}
local BR = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}}
local L = pile{{"lead white",2.5},{"cadmium yellow",0.5}}
-- LEFT: Ratio's face turned up to the right, her dress, her pointing arm
F(poly({{252,262},{266,258},{270,272},{262,280},{252,278}}), SK)
F(poly({{236,296},{264,296},{268,350},{232,350}}), WH)
F(poly({{262,300},{276,272},{286,240},{294,244},{284,276},{270,306}}), WH)
F(ellipse(292, 236, 6, 6), SK)
-- the knight's dot of light, turned to look where she points; the cross on his back
F(ellipse(392, 206, 6, 6), L)
F(rect(354,262,12,58) + rect(338,280,44,11), pile{{"lead white",2.2},{"yellow ochre",0.4}})
-- the bug's sleepy eye
F(ellipse(204, 314, 5, 4), WH)
-- RIGHT: Ratio's face in profile toward the sun, dress, legs; the knight's light
F(poly({{695,296},{704,296},{706,308},{696,310}}), SK)
F(poly({{684,312},{704,312},{708,336},{680,336}}), WH)
F(rect(686,336,5,10) + rect(696,336,5,10), BR)
F(ellipse(658, 280, 3, 3), L)

--@ chunk 6
print(wait(2*24*60))
local r = brush{kind="round", width=3, point=0.8}
-- Ratio's eye and smile on both pages; the bug's closed eye
r:reload(INK, 0.8); r:touch(262, 268, {pressure=0.6})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:touch(264, 275, {pressure=0.4})
r:reload(INK, 0.8); r:touch(701, 302, {pressure=0.4})
r:reload(INK, 0.7); r:stroke({{200,316},{205,319},{210,316}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
-- the stars, and the one she points at: big and warm
local s = brush{kind="round", width=5, point=0}
for _,p in ipairs({{40,40},{110,120},{200,30},{280,90},{430,40},{460,150},{60,200},{400,110},{150,190},{330,30}}) do
  s:reload(pile{{"lead white",2.5},{"yellow ochre",0.2}}, 0.6); s:touch(p[1], p[2], {pressure=0.6}) end
local cx, cy = 330, 120
for i=0,3 do local a = i*math.pi/4
  r:reload(pile{{"lead white",2.5},{"cadmium yellow",0.6}}, 0.8)
  r:stroke({{cx - 18*math.cos(a), cy - 18*math.sin(a)},{cx + 18*math.cos(a), cy + 18*math.sin(a)}}, {pressure={r:pressure_for(0.8), r:pressure_for(0.8)}, swell={0.2,1,0.2}})
end
F(ellipse(cx, cy, 7, 7), pile{{"lead white",2.5},{"cadmium yellow",0.6}})
-- dotted line from her finger to the star
for k=1,4 do local t = k/5; s:reload(pile{{"lead white",2},{"cadmium yellow",0.4}}, 0.5); s:touch(lerp(296,cx,t), lerp(230,cy,t), {pressure=0.35}) end
-- text lines on the left page
local t = brush{kind="round", width=4, point=0.6}
local function text(x0, x1, y)
  local x = x0
  while x < x1 do local l = 8 + (math.floor(x*13) % 22)
    if x + l > x1 then break end
    t:reload(pile{{"bone brown",1.4},{"burnt sienna",0.5}}, 0.7); t:stroke({{x, y},{x+l, y}}, {pressure={t:pressure_for(3), t:pressure_for(3)}})
    x = x + l + 9 end
end
text(60, 440, 456); text(60, 320, 476)
-- THE END: a red ribbon with big hand-lettered-looking marks
local RIB = poly({{600,442},{900,442},{914,462},{900,482},{600,482},{586,462}})
F(RIB, pile{{"cadmium red",1},{"Mars red",0.4}})
F(poly({{570,452},{600,446},{600,478},{570,484},{582,466}}), pile{{"Mars red",1},{"rose madder",0.4}})
F(poly({{900,446},{930,452},{918,466},{930,484},{900,478}}), pile{{"Mars red",1},{"rose madder",0.4}})
local m = brush{kind="round", width=6, point=0.5}
local CRM = pile{{"lead white",2.5},{"yellow ochre",0.3}}
local function L(pts) m:reload(CRM, 0.8); m:stroke(pts, {pressure={m:pressure_for(3.4), m:pressure_for(3.4)}}) end
-- three marks, a gap, three marks: two words
L({{620,450},{644,450}}); L({{632,450},{632,474}})
L({{654,450},{654,474}}); L({{676,450},{676,474}}); L({{654,462},{676,462}})
L({{688,450},{688,474}}); L({{688,450},{706,450}}); L({{688,462},{702,462}}); L({{688,474},{706,474}})
L({{740,450},{740,474}}); L({{740,450},{758,450}}); L({{740,462},{754,462}}); L({{740,474},{758,474}})
L({{770,474},{770,450},{792,474},{792,450}})
L({{806,450},{806,474}}); L({{806,450},{820,452},{826,462},{820,472},{806,474}})

--@ chunk 7
print(wait(4*24*60))
local function G(m, p) work(m, {hand="detail", pile=p, coverage=9, fill=true, clip=m, load=1}) end
local spikes = nil
for k=0,4 do local x = 76 + k*22; local s = poly({{x-8,296},{x,270-k*2},{x+8,296}}); spikes = spikes and (spikes + s) or s end
G(ellipse(120, 326, 74, 40) + ellipse(190, 318, 28, 24) - spikes, PURP)
local tab = poly({{324,250},{396,250},{404,346},{316,346}}, true)
G(ellipse(360, 210, 44, 42) + poly({{316,244},{404,244},{416,352},{304,352}}, true) - tab, KG)
G(tab, CR)
G(poly({{236,296},{264,296},{268,350},{232,350}}), pile{{"zinc white",2.8}})
G(poly({{262,300},{276,272},{286,240},{294,244},{284,276},{270,306}}), pile{{"zinc white",2.8}})
G(poly({{252,262},{266,258},{270,272},{262,280},{252,278}}), pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}})
G(poly({{684,312},{704,312},{708,336},{680,336}}), pile{{"zinc white",2.8}})
G(poly({{636,294},{664,294},{668,330},{632,330}}, true) - poly({{638,298},{662,298},{664,328},{636,328}}, true), KG)

--@ chunk 8
print(wait(4*24*60))
local function G(m, p) work(m, {hand="detail", pile=p, coverage=8, fill=true, clip=m, load=1}) end
G(rect(354,262,12,58) + rect(338,280,44,11), pile{{"lead white",2.2},{"yellow ochre",0.4}})
G(ellipse(392, 206, 6, 6), pile{{"lead white",2.5},{"cadmium yellow",0.5}})
G(ellipse(204, 314, 5, 4), pile{{"zinc white",2.8}})
local r = brush{kind="round", width=3, point=0.8}
r:reload(INK, 0.8); r:touch(262, 268, {pressure=0.6})
r:reload(INK, 0.7); r:stroke({{200,316},{205,319},{210,316}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
-- restate the ribbon's letters, heavier, now the red is dry
local m = brush{kind="round", width=6, point=0.5}
local CRM = pile{{"lead white",2.8},{"yellow ochre",0.3}}
local function L(pts) m:reload(CRM, 0.9); m:stroke(pts, {pressure={m:pressure_for(3.6), m:pressure_for(3.6)}}) end
L({{620,450},{644,450}}); L({{632,450},{632,474}})
L({{654,450},{654,474}}); L({{676,450},{676,474}}); L({{654,462},{676,462}})
L({{688,450},{688,474}}); L({{688,450},{706,450}}); L({{688,462},{702,462}}); L({{688,474},{706,474}})
L({{740,450},{740,474}}); L({{740,450},{758,450}}); L({{740,462},{754,462}}); L({{740,474},{758,474}})
L({{770,474},{770,450},{792,474},{792,450}})
L({{806,450},{806,474}}); L({{806,450},{820,452},{826,462},{820,472},{806,474}})

--@ chunk 9
print(wait(4*24*60))
local function G(m, p) work(m, {hand="detail", pile=p, coverage=10, fill=true, clip=m, load=1}) end
G(poly({{236,296},{264,296},{268,350},{232,350}}), pile{{"zinc white",3}})
G(poly({{695,296},{704,296},{706,308},{696,310}}), pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}})
