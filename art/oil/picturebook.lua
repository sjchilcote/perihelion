-- easel session "picturebook": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=2, linen={18,16}, seed=2323, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.15}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
function flat(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=m, load=1}); return m end
function F(m, p) work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.5},{"Mars orange",0.12}}
PEACH = pile{{"lead white",2},{"Mars orange",0.35},{"yellow ochre",0.4}}
NIGHT = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"burnt sienna",0.3}}
GOLD = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.3}}
-- left page: a warm peach sky over a soft green-ochre ground
flat(rect(0,0,496,330), PEACH)
LGROUND = below(function(x) return 330 + 12*math.sin(x/70) end) * rect(0,0,496,430)
flat(LGROUND, pile{{"yellow ochre",1},{"lead white",1.2},{"viridian",0.12}})
-- right page: black sky
flat(rect(504,0,496,430), NIGHT)
-- both text strips cream
flat(rect(0,430,496,70) + rect(504,430,496,70), CREAM)
-- the gutter
F(rect(496,0,8,500), pile{{"burnt sienna",0.6},{"lead white",1.5},{"yellow ochre",0.4}})

--@ chunk 3
print(wait(2*24*60))
-- right page: the big warm sun and the gold ring's curve
flat(ellipse(860, 120, 62, 62), pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.4}})
RING = (ellipse(740, 1060, 700, 700) - ellipse(740, 1060, 664, 664)) * rect(504,0,496,430)
flat(RING, GOLD)
RINGIN = ellipse(740, 1060, 664, 664) * rect(504,0,496,430)
flat(RINGIN, pile{{"bone black",1},{"burnt sienna",0.6},{"ultramarine blue",0.3}})
-- a few small stars
local s = brush{kind="round", width=5, point=0}
for _,p in ipairs({{560,60},{640,140},{700,40},{960,260},{590,250},{780,220},{940,40}}) do s:reload(CREAM, 0.6); s:touch(p[1], p[2], {pressure=0.6}) end
-- left page: the CRT-shaped hill
HILL = poly({{60,420},{70,330},{90,316},{230,316},{250,330},{258,420}}, true)
flat(HILL, pile{{"lead white",2},{"yellow ochre",0.6},{"ultramarine ash",0.2}})
F(poly({{92,336},{226,336},{232,396},{88,400}}, true), pile{{"viridian",0.6},{"cerulean blue",0.6},{"lead white",1.2}})

--@ chunk 4
print(wait(4*24*60))
local SUNP = pile{{"cadmium yellow",1.2},{"Mars orange",0.5},{"lead white",0.6}}
F(ellipse(860, 120, 62, 62), SUNP)
F(RING, GOLD)
-- the knight, kneeling to see her: big soft shapes, painted dark-first
local K = pile{{"ultramarine ash",1},{"lead white",0.8},{"bone black",0.3}}
KN = {}
KN.body = poly({{300,240},{460,236},{480,330},{470,420},{300,420},{290,330}}, true)
KN.leg = poly({{380,380},{470,370},{486,420},{360,424}}, true)
KN.arm = poly({{300,250},{262,300},{240,350},{258,360},{290,316},{320,280}}, true)
KN.hand = ellipse(246, 356, 18, 14)
KN.helm = ellipse(360, 170, 74, 70)
for _,k in ipairs({"body","leg","arm","hand","helm"}) do F(KN[k], K) end

--@ chunk 5
print(wait(3*24*60))
local CR = pile{{"cadmium red",1},{"Mars red",0.6}}
local BONE = pile{{"lead white",2.2},{"yellow ochre",0.4}}
local INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
-- tabard and cross
F(poly({{326,244},{434,240},{446,330},{440,420},{320,420},{314,330}}, true), CR)
F(rect(370,268,18,90) + rect(344,296,70,18), BONE)
-- the helm: a dark visor band, a single warm dot of light
F(poly({{300,160},{420,156},{424,186},{298,190}}, true), INK)
F(ellipse(332, 173, 7, 7), pile{{"cadmium yellow",1},{"lead white",1}})
-- Ratio on the hill, waving up
local SK = pile{{"lead white",2.6},{"rose madder",0.15},{"yellow ochre",0.1}}
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.3}}
local WH = pile{{"zinc white",2.5}}
F(poly({{148,250},{172,250},{178,290},{142,290}}), HAIR)      -- hair falling behind
F(poly({{150,284},{170,284},{172,306},{148,306}}), WH)        -- dress
F(rect(152,306,6,10) + rect(162,306,6,10), pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}})
F(ellipse(160, 262, 14, 13), HAIR)
F(poly({{150,262},{170,262},{170,280},{150,280}}), SK)        -- face
F(poly({{170,286},{182,272},{188,258},{192,262},{186,276},{172,292}}), WH)  -- the waving arm
F(ellipse(190, 256, 4, 4), SK)

--@ chunk 6
print(wait(3*24*60))
local INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
local r = brush{kind="round", width=3, point=0.8}
r:reload(INK, 0.7); r:touch(156, 270, {pressure=0.6}); r:reload(INK, 0.7); r:touch(165, 270, {pressure=0.6})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.5); r:touch(160, 276, {pressure=0.4})
-- wave marks beside her hand
for _,s in ipairs({{{198,246},{204,240}},{{200,256},{208,254}}}) do r:reload(INK, 0.5); r:stroke(s, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}}) end
-- right page: the two of them small, walking along the ring
local K = pile{{"ultramarine ash",1},{"lead white",0.8},{"bone black",0.3}}
local CR = pile{{"cadmium red",1},{"Mars red",0.6}}
F(ellipse(722, 304, 14, 13), K)
F(poly({{708,316},{736,316},{740,352},{704,352}}, true), CR)
F(rect(708,350,9,14) + rect(727,350,9,14), K)
F(ellipse(716,306,2.4,2.4), pile{{"cadmium yellow",1},{"lead white",1}})
F(poly({{736,322},{748,336},{744,340},{734,330}}), K)          -- his hand reaching down to hers
F(ellipse(756, 344, 5, 5), pile{{"bone black",2}})            -- her head
F(poly({{751,349},{761,349},{762,358},{750,358}}), pile{{"zinc white",2.5}})
F(poly({{750,342},{753,342},{752,356},{749,356}}), pile{{"bone black",2}})
F(rect(752,358,2.5,5) + rect(757,358,2.5,5), pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}})
-- the abstract text lines under each page
local t = brush{kind="round", width=4, point=0.6}
local function text(x0, x1, y)
  local x = x0
  while x < x1 do local l = 8 + (math.floor(x*7) % 22)
    if x + l > x1 then break end
    t:reload(pile{{"bone brown",1.4},{"burnt sienna",0.5}}, 0.7); t:stroke({{x, y},{x+l, y}}, {pressure={t:pressure_for(3), t:pressure_for(3)}})
    x = x + l + 9 end
end
text(60, 440, 456); text(60, 300, 476)
text(560, 940, 456); text(560, 760, 476)

--@ chunk 7
print(wait(4*24*60))
local SK = pile{{"lead white",2.6},{"rose madder",0.15},{"yellow ochre",0.1}}
F(poly({{151,263},{169,263},{169,280},{151,280}}), SK)
F(ellipse(332, 173, 8, 8), pile{{"lead white",2.5},{"cadmium yellow",0.5}})
F(ellipse(716,306,2.6,2.6), pile{{"lead white",2.5},{"cadmium yellow",0.5}})

--@ chunk 8
print(wait(3*24*60))
local INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
local r = brush{kind="round", width=3, point=0.8}
r:reload(INK, 0.7); r:touch(156, 270, {pressure=0.6}); r:reload(INK, 0.7); r:touch(165, 270, {pressure=0.6})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.5); r:touch(160, 276, {pressure=0.4})
r:reload(pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.3}}, 0.6); r:touch(332, 173, {pressure=0.5})

--@ chunk 9
F(poly({{150,281},{170,281},{172,306},{148,306}}), pile{{"zinc white",2.5}})
F(poly({{170,287},{182,273},{188,259},{192,263},{186,277},{172,293}}), pile{{"zinc white",2.5}})
