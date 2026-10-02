-- easel session "letter_after": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=4/3, linen={18,16}, seed=3132, ground={{pile={{"lead white",3},{"yellow ochre",0.6},{"burnt sienna",0.4},{"bone black",0.2}}, um=120, apply="knife", texture=0.3}}}
BUNK = poly({{0,440},{430,452},{440,560},{430,640},{0,640}})
DESK = poly({{440,500},{860,494},{872,536},{446,546}})
FRAME = poly({{0,560},{436,556},{440,640},{0,644}})
PILLOW = poly({{8,420},{110,412},{140,440},{120,462},{14,466}}, true)
BRK = poly({{760,546},{780,546},{800,620},{786,620}}) + poly({{490,546},{508,546},{470,620},{456,620}})
READER = poly({{560,452},{690,440},{700,500},{570,512}})
SCREEN = poly({{572,456},{680,446},{688,494},{580,504}})
PHOTO = poly({{566,236},{684,230},{688,318},{570,326}})
PHOTO2 = poly({{700,252},{800,244},{806,322},{706,330}})
MUG = poly({{480,462},{522,460},{520,506},{484,508}}, true)
POT = poly({{752,470},{796,470},{790,500},{758,500}})
SLIP = poly({{290,672},{352,664},{366,684},{300,694}}, true) + poly({{360,684},{424,676},{436,698},{370,706}}, true)
LX, LY = 620, 330   -- the reading lamp's shade hangs here, over the desk
local function mix(a, b, t)
  local acc, order = {}, {}
  for _,v in ipairs(a) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*(1-t) end
  for _,v in ipairs(b) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*t end
  local o = {}
  for _,k in ipairs(order) do if acc[k] > 0.001 then o[#o+1] = {k, acc[k]} end end
  return pile(o)
end
MIX = mix
-- the cabin wall: warm cream under the lamp, falling through ochre to warm brown at the corners
local WL = {{"lead white",1.4},{"yellow ochre",0.55},{"cadmium yellow",0.12},{"burnt sienna",0.1}}
local WD = {{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.45},{"lead white",0.12}}
local wall = rect(0,0,1000,622) - BUNK - DESK
local N = 10
for i=0,N-1 do
  local lo, hi = i*85, (i+1)*85
  if i == N-1 then hi = 9999 end
  local m = wall * mask(function(x,y) local r = math.sqrt((x-LX)^2 + ((y-LY-130)*1.25)^2); return (r >= lo and r < hi) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=7}, pile=mix(WL, WD, (i/(N-1))^0.85), coverage=3.8, fill=true, clip=wall, angle=1.5708, length={30,80}}) end
end
local seams = wall * mask(function(x,y) local r = math.sqrt((x-LX)^2 + ((y-LY-130)*1.25)^2); local k = r % 85; return (r > 40 and (k < 14 or k > 71)) and 1 or 0 end)
blend(seams, {angle=1.5708, tool={kind="badger", width=10}})
-- floor: warm deck
local fl = rect(0,620,1000,130)
work(fl, {hand="body", tool={kind="filbert", width=9}, pile=pile{{"bone brown",1},{"burnt sienna",0.5},{"lead white",0.25},{"yellow ochre",0.2}}, coverage=3.8, fill=true, clip=fl, angle=0, length={40,120}})

--@ chunk 2
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- bunk frame and mattress; blanket thrown back toward the foot, sheet showing
fill(FRAME, pile{{"bone brown",1},{"bone black",0.5},{"burnt sienna",0.3}}, 5)
local MAT = BUNK - FRAME
fill(MAT, pile{{"lead white",1.4},{"yellow ochre",0.35},{"ultramarine ash",0.15}}, 5)
BLANK2 = poly({{0,470},{60,462},{150,480},{196,470},{214,500},{196,560},{120,566},{40,560},{0,562}}, true)
fill(BLANK2, pile{{"cadmium red",0.6},{"rose madder",0.6},{"bone brown",0.3},{"lead white",0.2}}, 4, 1.5708)
local FOLD = poly({{196,470},{226,480},{236,512},{214,552},{196,560},{214,500}}, true)
fill(FOLD, pile{{"rose madder",0.7},{"lead white",0.6},{"cadmium red",0.3}}, 2.5)
fill(PILLOW, pile{{"lead white",1.6},{"yellow ochre",0.3}}, 3)
-- the sheet's creases where someone got up
local cr = brush{kind="round", width=1.6, point=0.5}
for _,c in ipairs({{250,490,320,500},{240,520,340,512},{300,530,410,522},{260,470,300,476}}) do cr:reload(pile{{"yellow ochre",1},{"lead white",0.5},{"bone brown",0.2}}, 0.6); cr:stroke({{c[1],c[2]},{(c[1]+c[3])/2, (c[2]+c[4])/2 + 3},{c[3],c[4]}}, {pressure={0.4,0.1}}) end
-- desk and brackets
fill(DESK, pile{{"burnt sienna",1},{"yellow ochre",0.5},{"bone brown",0.4}}, 4)
fill(DESK * rect(440,494,440,12), pile{{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}, 2)
fill(BRK, pile{{"bone brown",1},{"bone black",0.6}}, 2)
-- the reading lamp: a stalk from the wall, a warm conical shade, the bulb glowing under it
local stalk = brush{kind="round", width=3, point=0.3}
stalk:reload(pile{{"bone black",1.2},{"bone brown",0.5}}, 0.9); stalk:stroke({{760,250},{700,260},{650,290},{630,318}}, {pressure={0.7,0.7}})
SHADE = poly({{600,316},{660,316},{684,350},{576,350}}, true)
fill(SHADE, pile{{"Mars orange",1},{"cadmium yellow",0.5},{"burnt sienna",0.4}}, 2)
fill(ellipse(630, 350, 52, 6), pile{{"lead white",2},{"cadmium yellow",0.8}}, 1.5)
-- the light cone onto the desk: a paler warm wedge, opaque, blended at its edges
local cone = poly({{580,352},{680,352},{760,494},{500,500}}) - READER - MUG:grow(1) - PHOTO
fill(cone * rect(0, 352, 1000, 142), MIX({{"lead white",1.6},{"yellow ochre",0.5},{"cadmium yellow",0.2}}, {{"lead white",1.2},{"yellow ochre",0.55},{"burnt sienna",0.1}}, 0.5), 4, 1.5708)
blend((poly({{560,352},{700,352},{790,494},{470,500}}) - poly({{600,352},{660,352},{730,494},{530,498}})) * rect(0,352,1000,142) - READER - MUG:grow(1), {angle=1.5708, tool={kind="badger", width=10}})

--@ chunk 3
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- the reader, propped, with the first line of the message and a cursor
fill(READER, pile{{"bone black",1.4},{"ultramarine ash",0.4}}, 2)
fill(SCREEN, pile{{"lead white",1.5},{"cadmium yellow",0.4},{"yellow ochre",0.3}}, 2)
local tb = brush{kind="round", width=1.6, point=0.4}
local x = 584
while x < 646 do local L = rand(5, 12); tb:reload(pile{{"bone brown",1},{"bone black",0.6}}, 0.8); tb:stroke({{x, 462 - (x-584)*0.09}, {x + L, 462 - (x+L-584)*0.09}}, {pressure={0.5,0.5}}); x = x + L + rand(3, 5) end
tb:reload(pile{{"bone black",1.5}}, 0.9); tb:stroke({{652, 457}, {652, 467}}, {pressure={0.55,0.55}})
-- the mug, warm
fill(MUG, pile{{"lead white",1.4},{"cerulean blue",0.25},{"yellow ochre",0.15}}, 2, 1.5708)
fill(MUG * rect(505, 0, 30, 999), pile{{"lead white",0.9},{"cerulean blue",0.25},{"bone black",0.15}}, 1.5, 1.5708)
fill(ellipse(501, 462, 20, 4), pile{{"bone brown",1},{"burnt sienna",0.5}}, 1)
local hb = brush{kind="round", width=3.4, point=0.2}
hb:reload(pile{{"lead white",1.3},{"cerulean blue",0.25}}, 0.9); hb:stroke({{521,472},{534,476},{534,494},{521,498}}, {pressure={0.65,0.65}})
local st = brush{kind="rigger", width=1.1, point=1}
st:reload(pile{{"lead white",2}}, 0.35); st:stroke({{498,456},{492,440},{500,424},{494,408}}, {pressure={0.18,0.0}})
-- the plant, green and alive in its pot
fill(POT, pile{{"burnt sienna",1},{"Mars orange",0.5},{"lead white",0.15}}, 1.5)
local lb = brush{kind="round", width=3.2, point=0.8}
for i=1,16 do
  local a = -math.pi/2 + rand(-1.1, 1.1)
  local L = rand(18, 42)
  local x0 = 774 + rand(-10, 10)
  lb:reload((i % 3 == 0) and pile{{"viridian",0.6},{"cadmium yellow",1},{"lead white",0.4}} or pile{{"viridian",1},{"cadmium yellow",0.5},{"bone black",0.1}}, 0.85)
  lb:stroke({{x0, 472}, {x0 + L*0.5*math.cos(a), 472 + L*0.5*math.sin(a) - 4}, {x0 + L*math.cos(a), 472 + L*math.sin(a)}}, {pressure={0.75,0.05}, ramps={0.05,0.7}})
end
-- glasses folded on the desk
local GB = pile{{"bone black",1.5}}
local g = brush{kind="round", width=1.4, point=0.5}
local function lens(cx, cy) local p = {}; for k=0,20 do local t = 2*math.pi*k/20; p[#p+1] = {cx + 11*math.cos(t), cy + 5*math.sin(t)} end; g:reload(GB, 0.8); g:stroke(p, {pressure={0.45,0.45}}) end
lens(712, 515); lens(738, 517)
g:reload(GB, 0.8); g:stroke({{723,515},{727,513}}, {pressure={0.45,0.45}})
g:reload(GB, 0.8); g:stroke({{701,513},{688,508},{748,505}}, {pressure={0.4,0.4}})
local gl = brush{kind="round", width=1.2, point=0.5}
gl:reload(pile{{"lead white",2}}, 0.7); gl:stroke({{706,512},{712,511}}, {pressure={0.4,0.2}}); gl:stroke({{732,514},{738,513}}, {pressure={0.4,0.2}})
-- the half-eaten snack: a bar in its torn wrapper on a napkin
fill(poly({{790,512},{836,508},{840,526},{794,530}}), pile{{"lead white",1.8},{"yellow ochre",0.1}}, 1.5)
fill(poly({{796,512},{824,510},{826,520},{798,522}}), pile{{"cadmium red",1},{"vermilion",0.3},{"lead white",0.15}}, 1.2)
fill(poly({{824,510},{836,510},{836,519},{826,520}}), pile{{"burnt sienna",1},{"yellow ochre",0.6},{"bone brown",0.3}}, 1)
local cr = brush{kind="round", width=1, point=0.6}
cr:reload(pile{{"burnt sienna",1},{"yellow ochre",0.5}}, 0.7); for _,c in ipairs({{842,524},{846,520},{838,530}}) do cr:touch(c[1], c[2], {pressure=0.3}) end
-- the slippers by the bunk, warm felt
fill(SLIP, pile{{"burnt sienna",0.6},{"cadmium red",0.4},{"lead white",0.3},{"bone brown",0.3}}, 2)
local sl = brush{kind="round", width=1.4, point=0.5}
sl:reload(pile{{"lead white",1},{"yellow ochre",0.4},{"cadmium red",0.1}}, 0.6); sl:stroke({{294,672},{350,664}}, {pressure={0.45,0.2}}); sl:stroke({{364,684},{424,676}}, {pressure={0.45,0.2}})

--@ chunk 4
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- soften the cone: graded strips across its slanted edges, wall tone to cone tone
local keep = READER:grow(1) + MUG:grow(2) + POT:grow(1) + DESK + SHADE:grow(1) + ellipse(630,350,54,7) + PHOTO:grow(4) + PHOTO2:grow(4) + rect(740,420,70,60)
local band = (poly({{530,352},{730,352},{830,494},{430,500}}) - poly({{610,356},{650,356},{700,494},{560,498}})) * rect(0,356,1000,138) - keep
local W1 = pile{{"lead white",1.2},{"yellow ochre",0.55},{"burnt sienna",0.15},{"cadmium yellow",0.05}}
fill(band, W1, 4, 1.5708)
blend(band:grow(6) - keep, {angle=1.5708, tool={kind="badger", width=14}})
blend(band:grow(6) - keep, {angle=0.3, tool={kind="badger", width=14}})
-- the screen, cleaner
fill(SCREEN, pile{{"lead white",1.8},{"cadmium yellow",0.3},{"yellow ochre",0.2}}, 1.5)
-- photos: the beach one, and the new one pinned beside it
fill(PHOTO, pile{{"lead white",2}}, 1.5)
local ph = poly({{572,242},{680,236},{683,312},{575,318}})
fill(ph * rect(560,230,140,40), pile{{"cerulean blue",1},{"lead white",1.2}}, 1.2)
fill(ph * rect(560,270,140,14), pile{{"cobalt blue",1},{"lead white",0.6}}, 1.2)
fill(ph * rect(560,284,140,40), pile{{"yellow ochre",0.6},{"lead white",1.5}}, 1.2)
fill(PHOTO2, pile{{"lead white",2}}, 1.5)
local p2 = poly({{706,258},{794,251},{799,314},{711,321}})
fill(p2 * rect(700,240,110,44), pile{{"viridian",0.6},{"lead white",1},{"cadmium yellow",0.3}}, 1.2)
fill(p2 * rect(700,284,110,40), pile{{"viridian",1},{"cadmium yellow",0.5},{"bone black",0.2}}, 1.2)

--@ chunk 5
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- message text, one line and a cursor
local tb = brush{kind="round", width=1.6, point=0.4}
local x = 584
while x < 646 do local L = rand(5, 12); tb:reload(pile{{"bone brown",1},{"bone black",0.8}}, 0.8); tb:stroke({{x, 463 - (x-584)*0.09}, {x + L, 463 - (x+L-584)*0.09}}, {pressure={0.55,0.55}}); x = x + L + rand(3, 5) end
tb:reload(pile{{"bone black",1.5}}, 0.9); tb:stroke({{653, 457}, {653, 468}}, {pressure={0.6,0.6}})
-- beach photo figures (the same family as the dead room's photo)
local f = brush{kind="round", width=3.5, point=0.2}
local function fig(x, y, h, top, bot)
  f:reload(top, 0.9); f:stroke({{x, y}, {x, y + h*0.5}}, {pressure={0.7,0.7}})
  f:reload(bot, 0.9); f:stroke({{x, y + h*0.5}, {x, y + h}}, {pressure={0.6,0.6}})
  local hb = brush{kind="round", width=4, point=0.2}; hb:reload(pile{{"lead white",1},{"red earth",0.3},{"yellow ochre",0.3}}, 0.9); hb:touch(x, y - 4, {pressure=0.6})
end
fig(600, 280, 26, pile{{"cadmium red",1}}, pile{{"cobalt blue",1}})
fig(618, 290, 16, pile{{"cadmium yellow",1}}, pile{{"lead white",1},{"red earth",0.3}})
fig(632, 291, 15, pile{{"viridian",0.5},{"lead white",0.8}}, pile{{"lead white",1},{"red earth",0.3}})
fill(ellipse(660, 304, 10, 4), pile{{"burnt sienna",1},{"Mars orange",0.4}}, 1)
-- the new photo: a garden, a person with a child on their shoulders, a bright sky
fig(752, 278, 30, pile{{"cobalt blue",1},{"lead white",0.2}}, pile{{"bone brown",1}})
fig(752, 260, 12, pile{{"cadmium red",1}}, pile{{"cadmium red",1}})
local sun = brush{kind="round", width=6, point=0.2}
sun:reload(pile{{"cadmium yellow",1},{"lead white",0.5}}, 0.9); sun:touch(780, 264, {pressure=0.6})
-- pins and tape
local pin = brush{kind="round", width=4, point=0.2}
pin:reload(pile{{"cadmium red",1},{"lead white",0.2}}, 0.9); pin:touch(756, 249, {pressure=0.6})
local tp = brush{kind="round", width=5, point=0.2}
tp:reload(pile{{"lead white",1.4},{"yellow ochre",0.3}}, 0.8); tp:stroke({{562,232},{574,238}}, {pressure={0.6,0.6}}); tp:stroke({{678,230},{690,234}}, {pressure={0.6,0.6}})
-- the bulb's glow under the shade, a small soft halo on the wall above it
local glow = ellipse(630, 336, 70, 26) - SHADE:grow(1) - ellipse(630,350,54,7)
work(glow, {hand="scumble", tool={kind="filbert", width=3}, pile=pile{{"lead white",1.6},{"cadmium yellow",0.5}}, coverage=0.7, load=0.2, pressure={0.08,0.2}, clip=glow})
-- warm light catching the near edge of the desk and the blanket's top
local e = brush{kind="round", width=2, point=0.4}
e:reload(pile{{"lead white",1.5},{"cadmium yellow",0.5},{"yellow ochre",0.3}}, 0.8); e:stroke({{520,503},{640,499},{760,496}}, {pressure={0.1,0.5}})

--@ chunk 6
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.8, fill=true, clip=m, angle=ang or 0}) end end
local keep = READER:grow(1) + MUG:grow(2) + POT:grow(1) + DESK + SHADE:grow(1) + ellipse(630,350,54,7) + PHOTO:grow(3) + PHOTO2:grow(3) + BUNK
local pl = poly({{470,330},{850,330},{880,500},{420,506}}) * rect(0,320,1000,186) - keep
-- plant leaves stay
local leaves = rect(745,425,60,50)
pl = pl - leaves
-- wall tone as measured round the cone, a touch lighter near the lamp
local W0 = pile{{"lead white",1},{"yellow ochre",0.5},{"burnt sienna",0.22},{"bone brown",0.12}}
local W1 = pile{{"lead white",1.2},{"yellow ochre",0.55},{"burnt sienna",0.2},{"bone brown",0.08}}
local inner = ellipse(630, 420, 110, 80) * pl
fill(pl - inner, W0, 5, 1.5708)
fill(inner, W1, 5, 1.5708)
blend(pl * (ellipse(630, 420, 130, 94) - ellipse(630, 420, 90, 66)), {tool={kind="badger", width=10}})

--@ chunk 7
print(wait(24*60))
local keep = READER:grow(1) + MUG:grow(2) + POT:grow(1) + DESK + SHADE:grow(1) + ellipse(630,350,54,7) + PHOTO:grow(3) + PHOTO2:grow(3) + BUNK + rect(745,425,60,50)
local pl = poly({{460,322},{860,322},{890,504},{410,510}}) * rect(0,318,1000,192) - keep
local WL = {{"lead white",1.4},{"yellow ochre",0.55},{"cadmium yellow",0.12},{"burnt sienna",0.1}}
local WD = {{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.45},{"lead white",0.12}}
local N = 10
for i=0,N-1 do
  local lo, hi = i*85, (i+1)*85
  local m = pl * mask(function(x,y) local r = math.sqrt((x-LX)^2 + ((y-LY-130)*1.25)^2); return (r >= lo and r < hi) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=5}, pile=MIX(WL, WD, (i/(N-1))^0.85), coverage=4.5, fill=true, clip=m, angle=1.5708, length={20,60}}) end
end
blend(pl * mask(function(x,y) local r = math.sqrt((x-LX)^2 + ((y-LY-130)*1.25)^2); local k = r % 85; return (r > 40 and (k < 12 or k > 73)) and 1 or 0 end), {angle=1.5708, tool={kind="badger", width=8}})

--@ chunk 8
print(wait(24*60))
local WL = {{"lead white",1.4},{"yellow ochre",0.55},{"cadmium yellow",0.12},{"burnt sienna",0.1}}
local WD = {{"bone brown",1},{"burnt sienna",0.6},{"bone black",0.45},{"lead white",0.12}}
local patch = rect(742,420,24,52) - POT:grow(1)
local lv = rect(742,420,24,52)
-- small patch behind the plant: the ring tone there
work(patch * mask(function(x,y) return (x < 754) and 1 or 0 end), {hand="detail", tool={kind="filbert", width=2}, pile=MIX(WL, WD, (2/9)^0.85), coverage=4.5, fill=true, clip=patch})
local lb = brush{kind="round", width=3, point=0.8}
for i=1,6 do local a = -math.pi/2 - rand(0.4, 1.0); local L = rand(18, 34); lb:reload(pile{{"viridian",1},{"cadmium yellow",0.5},{"bone black",0.1}}, 0.85); lb:stroke({{770, 472}, {770 + L*math.cos(a), 472 + L*math.sin(a)}}, {pressure={0.75,0.05}, ramps={0.05,0.7}}) end
-- the lamp's arm, from a wall bracket at left, bent down to the shade
local st = brush{kind="round", width=3, point=0.3}
st:reload(pile{{"bone black",1.2},{"bone brown",0.5}}, 0.9); st:stroke({{520,290},{560,288},{594,300},{612,318}}, {pressure={0.7,0.7}})
local bk = brush{kind="round", width=7, point=0.2}
bk:reload(pile{{"bone black",1.2},{"bone brown",0.5}}, 0.9); bk:touch(518, 290, {pressure=0.7})
-- the shade's lit inner rim and a highlight on top
local e = brush{kind="round", width=1.6, point=0.5}
e:reload(pile{{"lead white",1.6},{"cadmium yellow",0.5}}, 0.8); e:stroke({{604,320},{632,317},{658,320}}, {pressure={0.45,0.3}})
