-- easel session "sail_mirror": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=16/9, linen={16,13}, seed=6181,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"bone black",1.2},{"ultramarine blue",0.8},{"burnt sienna",0.4},{"lead white",0.2}, medium=0.45}, um=24, apply="brush"},
  }}

--@ chunk 2
-- the horizon of the sail: a faint convex curve; black sky above, the mirror-film below (the same black, a breath bluer)
HZ = {{-10,306},{200,298},{400,294},{600,294},{800,298},{1010,306}}
FILM = below(HZ)
SKY = everywhere() - FILM
SUN = {716, 128}
SUNR = {716, 470}
local sky = pile{{"bone black",3},{"ultramarine blue",0.5}}
local film = pile{{"bone black",2.6},{"ultramarine blue",0.8},{"cobalt violet",0.1}}
work(SKY, {hand="broad", pile=sky, coverage=3, fill=true, angle=0.02, angle_jitter=0.2, clip=SKY})
work(FILM, {hand="broad", pile=film, coverage=3, fill=true, angle=0.0, angle_jitter=0.1, clip=FILM})

--@ chunk 3
print(wait(3*24*60))
-- the Sun above: disc and long corona strokes (laid on dry paint)
function corona(C, n, clipm, scale, warm)
  local cW = pile{{"lead white",3},{"zinc white",1},{"cadmium yellow",0.35}}
  local cG = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
  local cO = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}
  if warm then cW = pile{{"lead white",3},{"cadmium yellow",0.6},{"Indian yellow",0.2}} end
  local thin = brush{kind="round", width=2.2, point=0.5}
  local mid = brush("filbert", 5)
  local wide = brush("filbert", 9)
  for i = 1, n do
    local a = rand(-math.pi, math.pi)
    local r0 = rand(30, 55)
    local len = (40 + 260 * rand(0, 1)^1.8) * scale
    local br = (len > 170) and wide or ((math.random() < 0.5) and mid or thin)
    local p = (len < 90) and cW or ((len < 170) and cG or cO)
    local x0, y0 = C[1] + math.cos(a) * r0, C[2] + math.sin(a) * r0
    local x1, y1 = C[1] + math.cos(a) * (r0 + len), C[2] + math.sin(a) * (r0 + len)
    br:reload(p, 0.5)
    br:stroke({{x0, y0}, {(x0 + x1) / 2, (y0 + y1) / 2}, {x1, y1}}, {pressure={0.5, 0.02}, ramps={0.1, 0.8}, orient="along", clip=clipm})
  end
  local disc = ellipse(C[1], C[2], 40, 40) * clipm
  work(disc, {hand="body", pile=cW, coverage=2.8, fill=true, angle=0, clip=true})
  local core = ellipse(C[1], C[2], 27, 27) * clipm
  work(core, {hand="body", pile=pile{{"zinc white",4},{"lemon chrome",0.12}}, coverage=2.6, fill=true, angle=0, clip=true})
end
corona(SUN, 170, SKY, 1.0, false)

--@ chunk 4
-- the Sun beneath: the reflection, laid with its own strokes; the film dims it a little and warms it
corona(SUNR, 150, FILM, 0.9, true)

--@ chunk 5
print(wait(2*24*60))
-- a dense inner corona round each disc: many short strokes, so the Sun glows rather than spikes
function inner(C, n, clipm, warm)
  local w = warm and pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}} or pile{{"lead white",2.5},{"zinc white",0.5},{"cadmium yellow",0.5}}
  local g = pile{{"lead white",1.5},{"cadmium yellow",0.8},{"Mars orange",0.3}}
  local b = brush("filbert", 4)
  local t = brush{kind="round", width=2, point=0.5}
  for i = 1, n do
    local a = rand(-math.pi, math.pi)
    local r0 = rand(36, 48); local len = rand(12, 70) * rand(0.5, 1)
    local br = (math.random() < 0.5) and b or t
    br:reload((len < 35) and w or g, 0.55)
    br:stroke({{C[1] + math.cos(a) * r0, C[2] + math.sin(a) * r0}, {C[1] + math.cos(a) * (r0 + len), C[2] + math.sin(a) * (r0 + len)}}, {pressure={0.6, 0.05}, ramps={0.05, 0.8}, orient="along", clip=clipm})
  end
end
inner(SUN, 260, SKY, false)
inner(SUNR, 220, FILM, true)
-- stars above, and their reflections below scattered fresh (the film shows its own field)
local st = brush{kind="round", width=1.4, point=0.6}
local n = 0
for i = 1, 260 do
  local x, y = rand(0, 1000), rand(0, 562)
  local d1 = math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2); local d2 = math.sqrt((x - SUNR[1])^2 + (y - SUNR[2])^2)
  if d1 > 160 and d2 > 150 then
    local below = FILM:at(x, y) > 0.5
    if n % 6 == 0 then st:load(below and pile{{"zinc white",2},{"ultramarine ash",0.4}} or pile{{"zinc white",3},{"cerulean blue",0.1}}, 0.5) end
    st:touch(x, y, {pressure=rand(0.12, below and 0.3 or 0.45)}); n = n + 1
  end
end
print(n)

--@ chunk 6
print(wait(2*24*60))
-- broad soft rays filling between the spikes near each Sun, so it glows
function soft(C, n, clipm)
  local p = pile{{"lead white",1.5},{"cadmium yellow",0.6},{"Mars orange",0.4},{"bone black",0.05}}
  local b = brush("filbert", 14)
  for i = 1, n do
    local a = rand(-math.pi, math.pi); local r0 = rand(38, 50); local len = rand(60, 150)
    b:reload(p, 0.35)
    b:stroke({{C[1] + math.cos(a) * r0, C[2] + math.sin(a) * r0}, {C[1] + math.cos(a) * (r0 + len), C[2] + math.sin(a) * (r0 + len)}}, {pressure={0.35, 0.02}, ramps={0.05, 0.85}, orient="along", clip=clipm})
  end
end
soft(SUN, 60, SKY); soft(SUNR, 50, FILM)
local st = brush{kind="round", width=2.2, point=0.5}
local n = 0
for i = 1, 140 do
  local x, y = rand(0, 1000), rand(0, 562)
  local d1 = math.sqrt((x - SUN[1])^2 + (y - SUN[2])^2); local d2 = math.sqrt((x - SUNR[1])^2 + (y - SUNR[2])^2)
  if d1 > 200 and d2 > 190 then
    local below = FILM:at(x, y) > 0.5
    if n % 5 == 0 then st:load(below and pile{{"zinc white",3},{"ultramarine ash",0.3}} or pile{{"zinc white",4}}, 0.6) end
    st:touch(x, y, {pressure=rand(0.25, below and 0.45 or 0.65)}); n = n + 1
  end
end

--@ chunk 7
-- far off along the curve, the TESTAMENT, small, hanging on tethers that run down to the film; its reflection drawn beneath
local bz = pile{{"bone black",2},{"burnt sienna",1},{"raw sienna",0.3}}
local lit = pile{{"lead white",1.5},{"yellow ochre",0.8},{"cadmium yellow",0.2}}
local b = brush{kind="round", width=2.2, point=0.4}
local r = brush{kind="round", width=1.0, point=0.9}
-- above: spine, edge-on ring, maw
b:load(bz, 0.8); b:stroke({{118,222},{196,226}}, {pressure={0.9, 0.9}})
b:load(bz, 0.8); b:stroke({{158,204},{156,224},{158,246}}, {pressure={0.9, 0.9}})
b:load(bz, 0.8); b:stroke({{112,218},{118,224},{112,230}}, {pressure={0.8, 0.8}})
r:load(lit, 0.6); r:stroke({{120,221},{196,225}}, {pressure={0.4, 0.5}})
r:load(lit, 0.6); r:stroke({{159,204},{159,224}}, {pressure={0.4, 0.3}})
-- tethers to the horizon
local t = brush{kind="round", width=0.8, point=0.9}
for _, s in ipairs({{{196,226},{240,298}}, {{196,226},{176,299}}, {{196,226},{214,298}}}) do t:load(bz, 0.6); t:stroke(s, {pressure={0.4, 0.35}}) end
-- below: the reflection, drawn again by hand, a little dimmer
local bz2 = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.4}}
b:load(bz2, 0.8); b:stroke({{120,385},{197,381}}, {pressure={0.85, 0.85}})
b:load(bz2, 0.8); b:stroke({{157,405},{156,384},{158,361}}, {pressure={0.85, 0.85}})
b:load(bz2, 0.8); b:stroke({{113,390},{119,384},{113,377}}, {pressure={0.75, 0.75}})
r:load(pile{{"lead white",1},{"yellow ochre",0.6},{"ultramarine ash",0.3}}, 0.5); r:stroke({{121,383},{196,380}}, {pressure={0.3, 0.35}})
for _, s in ipairs({{{197,381},{240,312}}, {{197,381},{177,311}}, {{197,381},{215,312}}}) do t:load(bz2, 0.6); t:stroke(s, {pressure={0.35, 0.3}}) end

--@ chunk 8
print(wait(2*24*60))
-- the Commando walking on the mirror toward the Sun: war-body silhouette, feet on the film
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
FIGU = poly({{323,240},{331,236},{339,238},{342,246},{340,256},{334,260},{324,258},{320,250}}, true)          -- helm
  + poly({{306,262},{318,258},{344,258},{356,264},{356,272},{344,270},{318,270},{304,272}}, true)              -- pauldrons
  + poly({{316,268},{346,268},{344,292},{338,306},{322,306},{316,292}}, true)                                 -- torso
  + poly({{320,304},{340,304},{346,318},{316,318}}, true)                                                     -- faulds
  + ribbon({{336,316},{348,334},{356,352}}, {10, 8, 7})                                                       -- front leg, striding
  + ribbon({{324,316},{318,334},{308,350}}, {10, 8, 7})                                                       -- back leg
  + poly({{352,350},{366,350},{366,356},{350,356}}) + poly({{300,348},{312,350},{312,356},{298,356}})         -- feet
  + ribbon({{350,268},{358,288},{360,306}}, {7, 6, 5}) + ribbon({{310,268},{304,288},{302,304}}, {7, 6, 5})   -- arms
work(FIGU, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})
-- his reflection, drawn by hand beneath him, upside down, a shade cooler
local blk2 = pile{{"bone black",2.6},{"ultramarine blue",0.6}}
FIGD = poly({{300,357},{312,357},{312,362},{299,364}}) + poly({{350,357},{366,357},{366,362},{352,363}})
  + ribbon({{309,362},{318,379},{324,397}}, {7, 8, 10}) + ribbon({{356,362},{348,380},{336,397}}, {7, 8, 10})
  + poly({{316,395},{346,395},{340,410},{320,410}}, true)
  + poly({{322,407},{338,407},{344,421},{346,445},{316,445},{316,421}}, true)
  + poly({{304,441},{318,443},{344,443},{356,441},{356,449},{344,455},{318,455},{306,451}}, true)
  + poly({{320,463},{324,455},{334,453},{340,457},{342,467},{339,475},{331,477},{323,473}}, true)
  + ribbon({{360,407},{358,425},{350,445}}, {5, 6, 7}) + ribbon({{302,409},{304,425},{310,445}}, {5, 6, 7})
work(FIGD, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=blk2, coverage=3.6, fill=true, angle=math.pi/2, clip=true, load=0.9})

--@ chunk 9
print(wait(3*24*60))
-- gold rim on his sunward (right) edges; a fainter rim on the reflection's; a red rag; the seam running away
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local r = brush{kind="round", width=1.1, point=0.9}
for _, s in ipairs({ {{336,237},{342,246},{340,256}}, {{345,258},{356,264},{356,271}}, {{346,270},{344,292},{338,306}}, {{344,306},{346,318}},
                     {{352,330},{358,348}}, {{360,290},{361,305}} }) do
  r:load(gold, 0.55); r:stroke(s, {pressure={0.5, 0.35}})
end
local gold2 = pile{{"lead white",1.2},{"cadmium yellow",0.4},{"ultramarine ash",0.3}}
for _, s in ipairs({ {{338,475},{342,466},{340,457}}, {{345,455},{356,449},{356,442}}, {{346,443},{344,421},{338,408}}, {{344,407},{346,396}}, {{350,383},{356,366}} }) do
  r:load(gold2, 0.5); r:stroke(s, {pressure={0.35, 0.2}})
end
local rag = brush{kind="round", width=2.6, point=0.6}
rag:load(pile{{"cadmium red",1.5},{"vermilion",0.5}}, 0.7)
rag:stroke({{308,262},{296,252},{284,250}}, {pressure={0.7, 0.1}, ramps={0.1, 0.6}})
rag:load(pile{{"cadmium red",1},{"vermilion",0.4},{"bone black",0.3}}, 0.6)
rag:stroke({{308,452},{296,462},{284,464}}, {pressure={0.6, 0.1}, ramps={0.1, 0.6}})
-- the seam: a thin bright line running from the lower left foreground away to the horizon, passing beside his feet
local sm = brush{kind="round", width=3, point=0.7}
sm:load(pile{{"lead white",2},{"cadmium yellow",0.4},{"ultramarine ash",0.3}}, 0.7)
sm:stroke({{-10, 560}, {150, 452}, {280, 366}, {400, 316}, {470, 297}}, {pressure={0.9, 0.05}, ramps={0.02, 0.6}})
sm:load(pile{{"ultramarine ash",1},{"lead white",0.8},{"bone black",0.4}}, 0.6)
sm:stroke({{560, 562}, {640, 450}, {700, 360}, {730, 300}}, {pressure={0.5, 0.05}, ramps={0.02, 0.6}})
-- the film's faint sheen: a few long low strokes lying along the curve
local sh = brush("filbert", 10)
for i = 1, 14 do
  local y = rand(320, 550); local x0 = rand(-20, 600)
  sh:reload(pile{{"ultramarine ash",1},{"bone black",1},{"lead white",0.3}}, 0.35)
  sh:stroke({{x0, y}, {x0 + rand(120, 300), y - rand(2, 8)}}, {pressure={0.05, 0.3}, swell={0.3, 1, 0.3}, ramps={0.3, 0.3}, clip=FILM - FIGD:grow(3)})
end

--@ chunk 10
print(wait(3*24*60))
-- the sheen came out as grey bars: repaint the film (all but the reflections of the figure and the station), then lay the Sun beneath again
local film = pile{{"bone black",2.6},{"ultramarine blue",0.8},{"cobalt violet",0.1}}
FZ = FILM - FIGD:grow(2) - rect(100, 355, 150, 60)
work(FZ, {hand="body", tool="filbert 10", pile=film, coverage=3.4, fill=true, angle=0.0, clip=FZ, length={80, 220}, load=0.95})

--@ chunk 11
print(wait(3*24*60))
corona(SUNR, 150, FILM, 0.9, true)
inner(SUNR, 220, FILM, true)
soft(SUNR, 50, FILM)
-- figure and reflection: a second coat, true near-black
local bk = pile{{"bone black",4},{"ultramarine blue",0.2}}
work(FIGU:shrink(0.5), {hand="detail", tool={kind="round", width=2, point=0.3}, pile=bk, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=1.0})
work(FIGD:shrink(0.5), {hand="detail", tool={kind="round", width=2, point=0.3}, pile=bk, coverage=3.6, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 12
print(wait(3*24*60))
-- stars in the film, the seams, rims restated
local st = brush{kind="round", width=2, point=0.5}
local n = 0
for i = 1, 160 do
  local x, y = rand(0, 1000), rand(300, 562)
  if math.sqrt((x - SUNR[1])^2 + (y - SUNR[2])^2) > 200 and FZ:at(x, y) > 0.5 then
    if n % 5 == 0 then st:load(pile{{"zinc white",3},{"ultramarine ash",0.3}}, 0.55) end
    st:touch(x, y, {pressure=rand(0.15, 0.45)}); n = n + 1
  end
end
local sm = brush{kind="round", width=3, point=0.7}
sm:load(pile{{"lead white",2},{"cadmium yellow",0.4},{"ultramarine ash",0.3}}, 0.7)
sm:stroke({{-10, 560}, {150, 452}, {280, 366}, {400, 316}, {470, 297}}, {pressure={0.9, 0.05}, ramps={0.02, 0.6}, clip=-(FIGD:grow(1) + FIGU:grow(1))})
local gold = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local r = brush{kind="round", width=1.2, point=0.9}
for _, s in ipairs({ {{336,237},{342,246},{340,256}}, {{345,258},{356,264},{356,271}}, {{346,270},{344,292},{338,306}}, {{352,330},{358,348}}, {{360,290},{361,305}} }) do
  r:load(gold, 0.6); r:stroke(s, {pressure={0.6, 0.4}})
end
local gold2 = pile{{"lead white",1.5},{"cadmium yellow",0.4},{"ultramarine ash",0.2}}
for _, s in ipairs({ {{338,475},{342,466},{340,457}}, {{345,455},{356,449},{356,442}}, {{346,443},{344,421},{338,408}}, {{350,383},{356,366}} }) do
  r:load(gold2, 0.55); r:stroke(s, {pressure={0.45, 0.25}})
end
print(n)
