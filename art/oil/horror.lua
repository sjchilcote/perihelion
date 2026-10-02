-- easel session "horror": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.0, linen={18,16}, seed=666, ground={{pile={{"lead white",3},{"yellow ochre",1}}, um=120, apply="knife", texture=0.4},{pile={{"burnt sienna",2},{"ultramarine blue",1},{"lead white",1.2},{"yellow ochre",0.5}}, um=30, apply="brush"}}} print(W,H)

--@ chunk 2
VP = {605, 430}
glowM = poly({{520,560},{520,330},{545,285},{605,240},{665,285},{690,330},{690,560}}, true)
floorM = poly({{0,1000},{0,880},{520,560},{690,560},{1000,790},{1000,1000}})
vaultM = poly({{0,0},{1000,0},{1000,200},{690,305},{605,235},{520,305},{0,150}}, true)
wallM = everywhere() - vaultM - floorM - glowM
local function toVP(x, y) return math.atan(VP[2]-y, VP[1]-x) end
vaultP = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",1}}
wallP = pile{{"burnt sienna",2},{"ultramarine blue",1},{"raw sienna",1},{"yellow ochre",0.4}}
floorP = pile{{"bone brown",1.5},{"ultramarine blue",1},{"yellow ochre",0.5},{"lead white",0.25}}
work(vaultM - glowM:grow(6), {hand="body", pile=vaultP, angle=toVP, coverage=2.6, fill=true, clip=everywhere()-glowM:grow(4)})
work(wallM - glowM:grow(6), {hand="body", pile=wallP, angle=function(x,y) return math.pi/2 end, coverage=2.6, fill=true, clip=everywhere()-glowM:grow(4)})
work(floorM - glowM:grow(6), {hand="body", pile=floorP, angle=toVP, coverage=2.6, fill=true, clip=everywhere()-glowM:grow(4)})
glowP = pile{{"lead white",3},{"Indian yellow",0.6},{"cadmium yellow",0.4}}
work(glowM, {hand="body", pile=glowP, angle=math.pi/2, coverage=3, fill=true, clip=true})

--@ chunk 3
print(wait(20*60))
barrel = {{225,425},{300,372},{400,352},{500,356},{610,374},{720,392},{785,430},{800,490},{770,548},{700,585},{580,612},{450,648},{320,662},{240,628},{215,540}}
torso = {{252,440},{238,345},{246,282},{270,256},{318,244},{356,258},{378,292},{372,360},{356,440}}
LEGS = {
  {{280,600},{165,715},{205,950}, {44,30,20}},
  {{470,618},{530,735},{478,868}, {40,28,18}},
  {{675,575},{765,655},{722,770}, {32,22,14}},
  {{350,630},{410,740},{372,885}, {30,22,15}},
  {{565,600},{612,690},{606,800}, {26,18,12}},
  {{745,540},{805,612},{792,705}, {22,16,10}},
}
local m = poly(barrel, true) + poly(torso, true) + ellipse(300,220,24,28)
for _, L in ipairs(LEGS) do
  m = m + ribbon({L[1], L[2], L[3]}, {L[4][1], L[4][2], L[4][3]})
  m = m + ellipse(L[2][1], L[2][2], L[4][2]*0.75, L[4][2]*0.75)
end
-- rail cannon from the right shoulder, and a rotary under the chest
m = m + ribbon({{360,292},{90,352}}, {20,12}) + ribbon({{262,520},{110,566}}, {26,18})
darkP = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1}}
work(m, {hand="body", pile=darkP, coverage=3.2, fill=true, clip=true, angle=function(x,y) return 1.2 end})

--@ chunk 4
-- break the sausage: armour plates along the back, heavy thighs, cowl, hanging organ mass
local function plate(x, y, ang, len, w, lean)
  local ca, sa = math.cos(ang), math.sin(ang)
  local nx, ny = -sa, ca
  local tipx, tipy = x + ca*len + nx*lean, y + sa*len + ny*lean
  return poly({{x - nx*w, y - ny*w}, {x + ca*len*0.55 - nx*w*0.8, y + sa*len*0.55 - ny*w*0.8}, {tipx, tipy},
               {x + ca*len*0.6 + nx*w*0.7, y + sa*len*0.6 + ny*w*0.7}, {x + nx*w, y + ny*w}})
end
local m = poly({{200,600},{215,520},{232,430},{300,372},{330,368},{320,420},{280,520},{260,640}})  -- fill chest front
-- dorsal plates, leaning back toward the rear, irregular
local xs = {372, 405, 446, 480, 522, 556, 598, 630, 668, 700, 735, 762}
for i, x in ipairs(xs) do
  local y = 360 + (x - 380) * 0.07 + rand(-6, 6)
  local ang = -math.pi/2 + 0.55 + rand(-0.25, 0.3)
  m = m + plate(x, y + 8, ang, rand(28, 62) * (1 - (x-372)/1400), rand(9, 16), rand(-6, 6))
end
-- pauldrons and a hunched cowl on the old body
m = m + poly({{232,300},{248,262},{290,250},{300,282},{262,318}}, true)
m = m + poly({{338,250},{372,262},{396,300},{384,330},{350,300}}, true)
m = m + poly({{268,250},{276,214},{298,196},{322,206},{330,240},{318,262}}, true)
-- heavy thighs on the near legs
m = m + ellipse(250, 640, 52, 40) + ellipse(478, 650, 44, 34) + ellipse(670, 600, 36, 28)
-- lower legs: armoured shins and splayed claw-feet
local function foot(x, y, s)
  return poly({{x - 26*s, y + 4*s}, {x - 8*s, y - 18*s}, {x + 10*s, y - 16*s}, {x + 30*s, y + 6*s}, {x + 6*s, y - 2*s}})
end
m = m + foot(205, 950, 1.2) + foot(478, 868, 1.0) + foot(372, 885, 0.8) + foot(722, 770, 0.7) + foot(606, 800, 0.6) + foot(792, 705, 0.5)
m = m + ribbon({{165,715},{190,800},{205,930}}, {34, 28, 16}) + ribbon({{530,735},{505,800},{480,860}}, {28, 22, 12})
m = m:roughen(3, 24, 11)
work(m, {hand="body", pile=darkP, coverage=3.0, fill=true, clip=true, angle=1.0})

--@ chunk 5
print(wait(5*24*60))
print(drying(500,100), drying(900,500), drying(500,500), drying(600,450))
keepOut = poly({{228,445},{226,300},{262,250},{272,200},{300,186},{328,204},{342,248},{382,262},{404,300},{386,348},
                {440,350},{520,348},{600,356},{700,372},{782,380},{806,440},{830,620},{200,720}}, true)
local function d(x, y) local dx, dy = (x-605)/1.0, (y-400)/0.85 return math.sqrt(dx*dx+dy*dy) end
local haze = ellipse(605, 400, 470, 400) - keepOut - glowM
hazeP = pile{{"lead white",3},{"Indian yellow",0.4},{"Mars orange",0.35}, medium=0.3}
work(haze, {hand="glaze", pile=hazeP, clip=true, pressure={0.12,0.28}, coverage=2.2,
  load_at=function(x,y) return clamp(0.4*(1 - d(x,y)/430), 0.02, 0.4) end,
  angle=function(x,y) return math.atan(y-400, x-605) end})
local inner = ellipse(605, 400, 240, 220) - keepOut - glowM
work(inner, {hand="glaze", pile=hazeP, clip=true, pressure={0.15,0.3}, coverage=2,
  load_at=function(x,y) return clamp(0.45*(1 - d(x,y)/240), 0.02, 0.45) end,
  angle=function(x,y) return math.atan(y-400, x-605) end})
blend(ellipse(605, 400, 470, 400) - keepOut:grow(4) - glowM, {angle=0.3})

--@ chunk 6
-- the radial haze failed (hard ellipse, cold streaks). Repaint the hall opaque, graded in bands toward the far door.
local function creature()
  local m = poly(barrel, true) + poly(torso, true) + ellipse(300,220,24,28)
  for _, L in ipairs(LEGS) do
    m = m + ribbon({L[1], L[2], L[3]}, {L[4][1], L[4][2], L[4][3]}) + ellipse(L[2][1], L[2][2], L[4][2]*0.75, L[4][2]*0.75)
  end
  m = m + ribbon({{360,292},{90,352}}, {20,12}) + ribbon({{262,520},{110,566}}, {26,18})
  m = m + poly({{232,300},{248,262},{290,250},{300,282},{262,318}}, true) + poly({{338,250},{372,262},{396,300},{384,330},{350,300}}, true)
  m = m + poly({{268,250},{276,214},{298,196},{322,206},{330,240},{318,262}}, true)
  m = m + ellipse(250, 640, 52, 40) + ellipse(478, 650, 44, 34) + ellipse(670, 600, 36, 28)
  m = m + ribbon({{165,715},{190,800},{205,930}}, {34, 28, 16}) + ribbon({{530,735},{505,800},{480,860}}, {28, 22, 12})
  m = m + ribbon({{372,340},{560,345},{700,360},{785,385}}, {44,50,46,40})
  return m
end
CRE = creature():grow(2)
local function d(x, y) local dy = (y-400)/0.85 return math.sqrt((x-605)^2 + dy*dy) end
local function band(lo, hi, seed)
  local m = ellipse(605, 400, hi, hi*0.85)
  if lo > 0 then m = m - ellipse(605, 400, lo, lo*0.85) end
  return m:roughen(8, 40, seed)
end
local toVP = function(x,y) return math.atan(VP[2]-y, VP[1]-x) end
local W1 = pile{{"lead white",2},{"yellow ochre",1},{"Indian yellow",0.3},{"Mars orange",0.2}}
local W2 = pile{{"yellow ochre",1.5},{"raw sienna",1},{"lead white",0.9},{"burnt sienna",0.3}}
local W3 = pile{{"burnt sienna",1.5},{"raw sienna",1},{"ultramarine blue",0.6},{"yellow ochre",0.5},{"lead white",0.25}}
local V1 = pile{{"lead white",1.5},{"yellow ochre",1},{"burnt sienna",0.4},{"Mars orange",0.2}}
local V2 = pile{{"raw sienna",1},{"burnt sienna",1},{"lead white",0.5},{"ultramarine blue",0.3}}
local V3 = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"bone brown",0.6},{"lead white",0.15}}
local F1 = pile{{"lead white",1.3},{"yellow ochre",1},{"raw sienna",0.5}}
local F2 = pile{{"raw sienna",1},{"bone brown",0.6},{"ultramarine blue",0.4},{"lead white",0.5}}
local F3 = pile{{"bone brown",1.5},{"ultramarine blue",1},{"yellow ochre",0.4},{"lead white",0.2}}
local keep = -(CRE + glowM:grow(3))
local regions = {{vaultM, {V1, V2, V3, vaultP}}, {wallM, {W1, W2, W3, wallP}}, {floorM, {F1, F2, F3, floorP}}}
local edges = {{0,190},{190,300},{300,410},{410,505}}
for _, R in ipairs(regions) do
  for i, e in ipairs(edges) do
    local m = band(e[1], e[2], 20 + i) * R[1] * keep
    if m:area() > 50 then
      work(m, {hand="body", pile=R[2][i], angle=toVP, coverage=2.8, fill=true, clip=keep * R[1]:grow(2)})
    end
  end
end

--@ chunk 7
print(wait(3*24*60))
-- reclaim the back and the legs from the stray haze: a higher, humped dark back
local back = poly({{372,368},{380,338},{440,322},{520,318},{600,330},{680,345},{750,362},{790,392},{785,420},{372,400}}, true):roughen(4, 30, 5)
local legs = back
for _, L in ipairs(LEGS) do
  legs = legs + ribbon({L[1], L[2], L[3]}, {L[4][1]+2, L[4][2]+2, L[4][3]+2}) + ellipse(L[2][1], L[2][2], L[4][2]*0.8, L[4][2]*0.8)
end
work(back + legs, {hand="body", pile=darkP, coverage=3.2, fill=true, clip=true, angle=1.2})
-- sensor masts: antlers and spines off the back, crowding the vault
local mb = brush{kind="round", width=9, point=0.7}
local tb = brush{kind="round", width=4, point=0.9}
local function mast(pts, p0, tines)
  mb:reload(darkP, 1.0)
  mb:stroke(pts, {pressure={p0, 0.12}, ramps={0.02, 0.5}, shake=0.6})
  for _, t in ipairs(tines) do
    tb:reload(darkP, 0.9)
    tb:stroke(t, {pressure={0.75, 0.05}, ramps={0.02, 0.6}, shake=0.8})
  end
end
mast({{420,352},{402,262},{352,172},{332,84},{346,20}}, 1.0, {{{392,240},{440,200},{452,150}}, {{356,180},{300,150},{282,110}}, {{338,110},{372,70}}})
mast({{500,340},{522,250},{502,150},{532,58}}, 0.95, {{{518,232},{570,200},{590,150}}, {{506,170},{462,128}}, {{516,110},{560,80},{578,40}}})
mast({{462,342},{450,282},{474,206},{444,120}}, 0.7, {{{470,226},{430,190}}, {{456,156},{484,118}}})
mast({{590,350},{642,262},{702,192},{764,150},{858,128},{930,132}}, 0.9, {{{662,238},{676,180},{660,130}}, {{742,162},{760,110}}, {{820,134},{860,92},{900,80}}})
mast({{682,368},{742,302},{822,262},{904,252},{980,262}}, 0.8, {{{760,286},{790,230}}, {{860,256},{900,214}}})
mast({{734,382},{790,350},{830,300}}, 0.6, {{{810,326},{860,320}}})
mast({{366,264},{398,200},{430,142},{420,88}}, 0.75, {{{410,174},{456,160}}, {{426,120},{392,96}}})
-- a crown of thin antennae off the old head
mast({{288,198},{276,142},{262,98}}, 0.45, {})
mast({{312,194},{330,134},{352,104}}, 0.45, {})
mast({{300,190},{303,120},{296,60}}, 0.4, {})
-- manipulators hanging forward from the chest, too many joints
local ab = brush{kind="round", width=7, point=0.5}
local function arm(pts, claw)
  ab:reload(darkP, 1.0)
  ab:stroke(pts, {pressure={0.9, 0.55}, ramps={0.02, 0.2}, shake=0.5})
  for _, c in ipairs(claw) do tb:reload(darkP, 0.8) tb:stroke(c, {pressure={0.8, 0.05}}) end
end
arm({{292,452},{206,500},{156,600},{122,642}}, {{{122,642},{100,672},{104,700}}, {{122,642},{132,680},{150,700}}, {{124,640},{90,650}}})
arm({{318,470},{296,584},{250,690},{268,742}}, {{{268,742},{252,772}}, {{268,742},{292,768}}})
arm({{434,602},{402,700},{334,768}}, {{{334,768},{308,780},{296,808}}, {{334,768},{330,800}}})
arm({{232,560},{150,590},{64,640},{40,700}}, {{{40,700},{24,730}}, {{40,700},{56,734}}, {{42,698},{14,698}}})

--@ chunk 8
-- weight the masts and arms, put armour plates back on the hump
local hb = brush{kind="round", width=10}
local sb = brush{kind="round", width=5}
local function shaft(pts, p) hb:reload(darkP, 1.0) hb:stroke(pts, {pressure=p, ramps={0.02, 0.35}, shake=0.5}) end
local function tine(pts) sb:reload(darkP, 0.9) sb:stroke(pts, {pressure={0.9, 0.35}, ramps={0.02, 0.4}, shake=0.6}) end
shaft({{420,352},{402,262},{352,172},{334,110}}, {1.0, 0.45})
shaft({{500,340},{522,250},{504,160}}, {1.0, 0.45})
shaft({{590,350},{642,262},{702,192},{764,150},{830,132}}, {1.0, 0.4})
shaft({{682,368},{742,302},{822,262},{880,254}}, {0.95, 0.4})
shaft({{366,264},{398,200},{426,148}}, {0.9, 0.4})
shaft({{462,342},{450,282},{470,220}}, {0.8, 0.35})
tine({{392,240},{440,200},{452,160}}) tine({{356,180},{300,150}}) tine({{518,232},{570,200},{586,160}})
tine({{662,238},{676,180},{664,140}}) tine({{742,162},{758,118}}) tine({{760,286},{788,236}}) tine({{410,174},{452,160}})
-- sensor nodes: small dark bulbs where masts fork
for _, n in ipairs({{394,246,9,7},{520,236,8,8},{664,236,9,8},{758,288,7,6},{410,176,6,6},{352,178,6,6}}) do
  work(ellipse(n[1], n[2], n[3], n[4]), {hand="detail", pile=darkP, coverage=3, fill=true})
end
-- plates on the hump, leaning back, irregular
local top = {{380,338},{440,322},{520,318},{600,330},{680,345},{750,362},{790,392}}
local function topY(x)
  for i = 1, #top-1 do
    local a, b = top[i], top[i+1]
    if x >= a[1] and x <= b[1] then return lerp(a[2], b[2], (x-a[1])/(b[1]-a[1])) end
  end
  return 360
end
local m = nil
local x = 392
while x < 780 do
  local y = topY(x) + 6
  local len = rand(22, 48) * (1 - (x-392)/1100)
  local ang = -math.pi/2 + 0.6 + rand(-0.25, 0.35)
  local w = rand(8, 14)
  local tx, ty = x + math.cos(ang)*len, y + math.sin(ang)*len
  local p = poly({{x - w, y + 4}, {x - w*0.5 + (tx-x)*0.5, y + (ty-y)*0.55 - 2}, {tx, ty}, {x + w*0.9 + (tx-x)*0.3, y + (ty-y)*0.3}, {x + w, y + 6}})
  m = m and (m + p) or p
  x = x + rand(24, 40)
end
work(m, {hand="detail", pile=darkP, coverage=3, fill=true})
-- heavier manipulators
local ab = brush{kind="round", width=7}
local function arm(pts) ab:reload(darkP, 1.0) ab:stroke(pts, {pressure={1.0, 0.6}, ramps={0.02, 0.2}, shake=0.4}) end
arm({{292,452},{206,500},{156,600},{122,642}})
arm({{318,470},{296,584},{250,690},{268,742}})
arm({{434,602},{402,700},{334,768}})
arm({{232,560},{150,590},{64,640},{40,700}})

--@ chunk 9
print(wait(3*24*60))
print(drying(500,500), drying(300,350))
-- the Adversary graft: a torn seam along the flank, sacs hanging between the legs, tissue creeping up the old body
ORG = (poly({{418,532},{470,488},{540,470},{620,462},{700,470},{762,492},{770,522},{730,548},{660,560},{640,600},{600,632},{560,612},{540,580},{470,575},{430,560}}, true)
       + poly({{330,450},{350,392},{372,372},{392,400},{388,470},{362,500}}, true)
       + ellipse(612, 618, 30, 26) + ellipse(520, 600, 22, 30)):roughen(9, 34, 77)
local swirl = noise{seed=13, period=90, octaves=3, warp={70, 40}}
local sang = function(x, y) return swirl(x, y) * 3.2 end
orgBase = pile{{"cobalt violet",2},{"ultramarine blue",1},{"magenta",0.6},{"bone black",0.3}}
orgCyan = pile{{"zinc white",2},{"cerulean blue",1},{"emerald green",0.6}}
orgMag  = pile{{"magenta",1.5},{"rose madder",0.5},{"zinc white",0.8}}
orgPale = pile{{"zinc white",3},{"cerulean blue",0.3},{"lemon chrome",0.1}}
work(ORG, {hand="body", pile=orgBase, coverage=3, fill=true, clip=true, angle=sang})
local core = ORG:shrink(10) * mask(function(x, y) return swirl(x, y) > 0.05 and 1 or 0 end)
work(core, {hand="scumble", pile=orgCyan, coverage=1.6, clip=ORG, angle=sang, curve={0.6, 0.4}})
local mag = ORG:shrink(6) * mask(function(x, y) return swirl(x + 300, y - 200) > 0.25 and 1 or 0 end)
work(mag, {hand="body", pile=orgMag, coverage=1.2, clip=ORG, angle=sang, length={10, 30}, curve={0.8, 0.5}})
blend(ORG:shrink(4), {angle=sang})
local hot = ORG:shrink(16) * mask(function(x, y) return swirl(x, y) > 0.35 and 1 or 0 end)
work(hot, {hand="detail", pile=orgPale, coverage=1.3, clip=ORG, angle=sang, length={6, 18}})

--@ chunk 10
print(wait(2*24*60))
print(drying(560,520), drying(360,430))
-- the war-metal cage over the graft: ribs and straps of machined plate, torn teeth along the seam
local fb = brush{kind="flat", width=13}
local function rib(pts, p) fb:reload(darkP, 1.0) fb:stroke(pts, {pressure=p or {0.95, 0.8}, ramps={0.02, 0.1}, orient="across", shake=0.3}) end
rib({{452,470},{446,520},{462,575}})
rib({{506,458},{498,530},{512,590}})
rib({{566,452},{556,520},{570,600}}, {0.9, 0.7})
rib({{628,450},{620,512},{634,575}}, {0.95, 0.75})
rib({{690,458},{684,505},{700,552}}, {0.85, 0.7})
rib({{742,476},{738,505},{750,530}}, {0.8, 0.6})
fb:reload(darkP, 1.0) fb:stroke({{430,548},{520,560},{610,548},{700,532},{760,516}}, {pressure={0.7, 0.5}, orient="across"})
-- torn plate teeth hanging into the seam from above, and creeping up the old body
local teeth = nil
local x = 432
while x < 760 do
  local yt = 470 - 0.05*(x-430) + rand(-6, 6)
  local len, w = rand(14, 34), rand(6, 12)
  local tip = {x + rand(-10, 10), yt + len}
  local t = poly({{x - w, yt - 14}, {x + w, yt - 14}, {x + w*0.6, yt + len*0.4}, tip})
  teeth = teeth and (teeth + t) or t
  x = x + rand(18, 34)
end
teeth = teeth + poly({{336,452},{346,420},{360,440},{372,400},{384,430},{392,470},{360,500}}, false)
work(teeth, {hand="detail", pile=darkP, coverage=3, fill=true})
-- drool of tissue from the sacs toward the floor
local db = brush{kind="round", width=6, point=0.8}
local tissue = pile{{"cobalt violet",1.5},{"magenta",0.6},{"cerulean blue",0.4},{"zinc white",0.6}}
for _, s in ipairs({{{612,640},{618,690},{606,740},{612,782}}, {{520,628},{514,672},{524,712}}, {{590,632},{580,668},{586,700}}, {{640,606},{660,650},{652,690}}}) do
  db:reload(tissue, 0.8)
  db:stroke(s, {pressure={0.8, 0.05}, ramps={0.05, 0.7}, shake=1.2})
end

--@ chunk 11
print(drying(420,300), drying(560,380), drying(700,600))
rimP = pile{{"lead white",2},{"Indian yellow",0.5},{"Mars orange",0.25}}
rimHot = pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.25}}
coldP = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt violet",0.4}}
local function offsetToward(pts, off, cx, cy)
  local out = {}
  for i, p in ipairs(pts) do
    local a = pts[math.max(1, i-1)]; local b = pts[math.min(#pts, i+1)]
    local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy) + 1e-6
    local nx, ny = -dy/L, dx/L
    if nx*(cx-p[1]) + ny*(cy-p[2]) < 0 then nx, ny = -nx, -ny end
    out[i] = {p[1] + nx*off, p[2] + ny*off}
  end
  return out
end
local rb = brush{kind="round", width=3, point=0.5}
local function rim(pts, off, pile, pr, cx, cy)
  rb:reload(pile, 0.9)
  rb:stroke(offsetToward(pts, off, cx or 605, cy or 380), {pressure=pr or {0.55, 0.25}, ramps={0.15, 0.4}, shake=0.4})
end
-- warm rims, from the door behind it
rim({{356,256},{376,290},{372,350}}, -3, rimP)
rim({{372,262},{394,298},{386,328}}, -3, rimP)
rim({{304,194},{322,206},{330,236}}, -2.5, rimP, {0.4, 0.15})
rim({{440,324},{520,320},{600,332},{680,347}}, -3, rimP, {0.45, 0.3})
rim({{680,347},{750,364},{790,394}}, -3, rimHot, {0.6, 0.3})
rim({{786,432},{800,490},{772,546}}, -3, rimHot, {0.65, 0.35})
rim({{745,540},{805,612},{792,700}}, -3, rimHot, {0.55, 0.2})
rim({{675,575},{765,655},{724,766}}, -4, rimP, {0.6, 0.2})
rim({{565,600},{612,690},{606,796}}, -3, rimP, {0.5, 0.15})
rim({{682,368},{742,302},{822,262},{880,254}}, -2.5, rimP, {0.45, 0.15}, 700, 420)
rim({{590,350},{642,262},{702,192},{764,150},{830,132}}, -2.5, rimP, {0.45, 0.12}, 640, 420)
rim({{500,340},{522,250},{504,160}}, -2.5, rimP, {0.45, 0.1}, 610, 300)
rim({{420,352},{402,262},{352,172}}, -2, rimP, {0.35, 0.1}, 610, 300)
rim({{366,264},{398,200},{426,148}}, -2, rimP, {0.35, 0.1}, 610, 300)
-- cold light from the graft on the inner edges near it
rim({{470,622},{528,734},{480,864}}, -3, coldP, {0.5, 0.1}, 580, 560)
rim({{350,632},{408,740},{374,880}}, -3, coldP, {0.45, 0.1}, 560, 560)
rim({{565,604},{610,690}}, -3, coldP, {0.4, 0.1}, 560, 560)
rim({{440,640},{520,632},{600,640},{680,602}}, -3, coldP, {0.45, 0.2}, 580, 700)
-- the cold pool on the floor under it
local pool = (ellipse(585, 790, 250, 62) * floorM):soften(20)
local poolP = pile{{"zinc white",1.5},{"cerulean blue",0.6},{"cobalt violet",0.4},{"bone black",0.15}, medium=0.2}
work(pool, {hand="scumble", pile=poolP, coverage=1.6, load=0.35, pressure={0.15, 0.35}, angle=0.05, clip=floorM - CRE})
blend(ellipse(585, 790, 270, 72) * floorM - CRE:grow(3), {angle=0.05})

--@ chunk 12
print(wait(2*24*60))
print(drying(585,790), drying(560,330))
-- repaint the floor: dark polished stone, the door's glow reflected as a streak, a smaller dimmer cold pool
local fl = floorM - CRE:grow(1)
local streak = poly({{528,560},{682,560},{700,700},{716,860},{730,1000},{482,1000},{500,860},{512,700}}, true):roughen(10, 30, 41)
local pool2 = ellipse(588, 772, 165, 44):roughen(10, 30, 42)
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local midDark  = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"raw sienna",0.6},{"lead white",0.25}}
local streakP  = pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.8},{"burnt sienna",0.3}}
local streakFar = pile{{"lead white",1.6},{"yellow ochre",1},{"Indian yellow",0.3}}
local pool2P   = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"zinc white",1.0},{"cerulean blue",0.3}}
local toVP = function(x,y) return math.atan(VP[2]-y, VP[1]-x) end
work(fl * below(function(x) return 700 end) - streak - pool2, {hand="body", pile=nearDark, angle=toVP, coverage=3.4, fill=true, clip=fl - streak:shrink(4) - pool2:shrink(4)})
work(fl * above(function(x) return 700 end) - streak - pool2, {hand="body", pile=midDark, angle=toVP, coverage=3.2, fill=true, clip=fl - streak:shrink(4) - pool2:shrink(4)})
work(fl * streak * above(function(x) return 640 end), {hand="body", pile=streakFar, angle=math.pi/2, coverage=3, fill=true, clip=fl * streak:grow(3)})
work(fl * streak * below(function(x) return 640 end) - pool2, {hand="body", pile=streakP, angle=math.pi/2, coverage=3, fill=true, clip=fl * streak:grow(3) - pool2:shrink(3)})
work(fl * pool2, {hand="body", pile=pool2P, angle=0.05, coverage=3, fill=true, clip=fl * pool2:grow(3)})
blend((streak:rim(10) + pool2:rim(10)) * fl, {angle=math.pi/2})

--@ chunk 13
-- wet into wet on the floor: fade the reflection toward us, soften the pool, reflect the legs
local fl = floorM - CRE:grow(1)
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local lowStreak = poly({{500,760},{716,760},{740,1000},{470,1000}}) * fl
work(lowStreak, {hand="body", pile=nearDark, angle=math.pi/2, coverage=2.2, pressure={0.3,0.7},
  load_at=function(x,y) return clamp((y-760)/240, 0.05, 0.9) end, clip=fl})
-- leg reflections: dark smears straight down from each foot
local rb = brush{kind="filbert", width=12}
for _, f in ipairs({{478,872,150},{372,890,110},{722,774,120},{606,804,170},{792,708,90},{205,954,46}}) do
  rb:reload(nearDark, 0.8)
  rb:stroke({{f[1], f[2]+4}, {f[1]+rand(-4,4), f[2] + f[3]}}, {pressure={0.8, 0.1}, ramps={0.05, 0.6}, shake=1.5, clip=fl})
end
blend(ellipse(595, 800, 220, 140) * fl + lowStreak, {angle=math.pi/2})
-- the feet again: splayed claws
local function foot(x, y, s)
  return poly({{x - 26*s, y + 4*s}, {x - 8*s, y - 18*s}, {x + 10*s, y - 16*s}, {x + 30*s, y + 6*s}, {x + 6*s, y - 2*s}})
end
local feet = foot(205, 950, 1.2) + foot(478, 868, 1.0) + foot(372, 885, 0.8) + foot(722, 770, 0.7) + foot(606, 800, 0.6) + foot(792, 705, 0.5)
work(feet, {hand="detail", pile=darkP, coverage=3, fill=true})
CRE = CRE + feet

--@ chunk 14
print(wait(1*24*60))
-- keep the masts out of the architecture
local MP = {
 {{420,352},{402,262},{352,172},{332,84},{346,20}}, {{500,340},{522,250},{502,150},{532,58}}, {{462,342},{450,282},{474,206},{444,120}},
 {{590,350},{642,262},{702,192},{764,150},{858,128},{930,132}}, {{682,368},{742,302},{822,262},{904,252},{980,262}},
 {{734,382},{790,350},{830,300}}, {{366,264},{398,200},{430,142},{420,88}},
 {{392,240},{440,200},{452,150}}, {{356,180},{300,150},{282,110}}, {{518,232},{570,200},{590,150}}, {{662,238},{676,180},{660,130}},
 {{742,162},{760,110}}, {{760,286},{790,230}}, {{410,174},{456,160}}, {{820,134},{860,92},{900,80}}, {{860,256},{900,214}},
 {{288,198},{276,142},{262,98}}, {{312,194},{330,134},{352,104}}, {{300,190},{303,120},{296,60}},
 {{292,452},{206,500},{156,600},{122,642}}, {{232,560},{150,590},{64,640},{40,700}},
}
for _, p in ipairs(MP) do CRE = CRE + ribbon(p, 12) end
-- transverse arches of the gallery, unevenly spaced (handmade, never repeating)
local function archPts(s, lean)
  local xL, xR = VP[1] - 640*s, VP[1] + 560*s
  local yFL, yFR = VP[2] + 470*s, VP[2] + 380*s
  local ys = VP[2] - 230*s
  local xa, ya = VP[1] + lean*s, VP[2] - 560*s
  local pts = {{xL, yFL}, {xL, ys}}
  for i = 1, 6 do local t = i/6 pts[#pts+1] = {xL + (xa-xL)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  for i = 5, 0, -1 do local t = i/6 pts[#pts+1] = {xR - (xR-xa)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  pts[#pts+1] = {xR, yFR}
  return pts
end
local ribP = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"bone brown",1},{"raw sienna",0.4}}
local edgeP = pile{{"lead white",1.5},{"yellow ochre",1},{"Indian yellow",0.3},{"Mars orange",0.2}}
local keep = -(CRE:grow(2) + glowM:grow(3))
local eb = brush{kind="round", width=3}
for _, a in ipairs({{0.95, 10}, {0.66, -14}, {0.47, 8}, {0.355, -6}, {0.275, 4}}) do
  local s = a[1]
  local pts = archPts(s, a[2])
  local band = ribbon(pts, 46*s):roughen(2, 20, math.floor(s*100))
  work(band * keep, {hand="body", pile=ribP, coverage=3, fill=true, clip=keep, angle=function(x,y) return 0.3 end})
  -- the inner edge of each rib catches the light coming down the hall
  local inner = {}
  for i, p in ipairs(pts) do
    local dx, dy = VP[1]-p[1], VP[2]-p[2]; local L = math.sqrt(dx*dx+dy*dy)
    inner[i] = {p[1] + dx/L*(23*s - 1), p[2] + dy/L*(23*s - 1)}
  end
  for i = 1, #inner - 2, 2 do
    eb:reload(edgeP, 0.9)
    eb:stroke({inner[i], inner[i+1], inner[i+2]}, {pressure={0.55, 0.4}, clip=keep, shake=0.5})
  end
end

--@ chunk 15
-- model the war-metal: plate edges catching the dull bronze of the hall, cold light from the graft below
local plateW = pile{{"burnt sienna",1},{"raw sienna",1},{"ultramarine blue",0.5},{"lead white",0.35}}
local plateWl = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.5},{"lead white",0.6}}
local plateC = pile{{"ultramarine blue",1},{"cobalt violet",0.8},{"zinc white",0.6},{"bone black",0.2}}
local b = brush{kind="filbert", width=5}
local r = brush{kind="round", width=3, point=0.6}
local function edge(br, pile, pts, pr)
  br:reload(pile, 0.7)
  br:stroke(pts, {pressure=pr or {0.5, 0.1}, ramps={0.1, 0.6}, shake=0.4})
end
-- three rows of overlapping plates on the upper flank, smaller toward the rear
for row = 0, 2 do
  local x = 384 + row*14
  while x < 770 do
    local f = 1 - (x-380)/900
    local len = rand(40, 70) * f
    local y0 = 380 + row*30 + 0.05*(x-380) + rand(-4, 4)
    local sag = rand(3, 8)
    edge(b, (row == 0) and plateWl or plateW, {{x, y0 + sag}, {x + len*0.5, y0}, {x + len, y0 + sag*0.6}}, {0.55*f + 0.15, 0.1})
    edge(r, darkP, {{x + 2, y0 + sag + 5}, {x + len*0.6, y0 + 6}}, {0.5, 0.1})
    x = x + len * rand(0.75, 0.95)
  end
end
-- cold light on the lower lips of the cage plates over the graft
for _, x in ipairs({452, 506, 566, 628, 690}) do
  edge(r, plateC, {{x + 4, 462}, {x + 2, 520}, {x + 12, 584}}, {0.4, 0.05})
end
edge(b, plateC, {{432,560},{520,572},{610,560},{700,546}}, {0.35, 0.1})
-- the chest of the beast: vertical plates, faint warm bounce from the left wall
for i, x in ipairs({232, 252, 270, 296}) do
  edge(b, plateW, {{x, 450 + i*10}, {x - 6, 520 + i*6}, {x - 2, 600}}, {0.45, 0.05})
end
-- thighs: curved armour arcs
for _, t in ipairs({{250,640,52,40},{478,650,44,34},{670,600,36,28}}) do
  local cx, cy, rx, ry = t[1], t[2], t[3], t[4]
  local arc = {}
  for k = 0, 6 do local a = math.pi*1.05 + k*0.16 arc[#arc+1] = {cx + math.cos(a)*rx*0.8, cy + math.sin(a)*ry*0.8} end
  edge(b, plateW, arc, {0.5, 0.1})
end
-- pistons along the upper legs
for _, L in ipairs(LEGS) do
  local a, k = L[1], L[2]
  local dx, dy = k[1]-a[1], k[2]-a[2]; local len = math.sqrt(dx*dx+dy*dy)
  local nx, ny = -dy/len, dx/len
  local o = L[4][1]*0.45
  edge(r, plateW, {{a[1] + nx*o + dx*0.15, a[2] + ny*o + dy*0.15}, {k[1] + nx*o*0.7 - dx*0.1, k[2] + ny*o*0.7 - dy*0.1}}, {0.45, 0.3})
end

--@ chunk 16
blend(poly({{380,370},{780,390},{780,470},{430,480},{380,450}}) - ORG:grow(2), {angle=0.1}) blend(poly({{205,440},{320,450},{320,640},{205,640}}), {angle=1.5})

--@ chunk 17
print(wait(36*60))
print(drying(500,420), drying(260,520))
local flank = poly({{380,370},{780,390},{780,470},{430,480},{380,450}}):grow(3) * CRE - ORG:grow(1)
local chest = poly({{205,440},{320,450},{320,640},{205,640}}):grow(3)
work(flank, {hand="body", pile=darkP, coverage=3.4, fill=true, clip=flank, angle=0.15})
work(chest * CRE, {hand="body", pile=darkP, coverage=3.4, fill=true, clip=chest * CRE, angle=1.5})
-- the bit of wall the smear crossed, left of the chest
local wallFix = chest - CRE:grow(1)
work(wallFix, {hand="body", pile=pile{{"burnt sienna",1.5},{"raw sienna",1},{"ultramarine blue",0.6},{"yellow ochre",0.5},{"lead white",0.25}}, coverage=3, fill=true, clip=wallFix, angle=1.57})

--@ chunk 18
-- what he was: a rag of crimson tabard, a bone cross, a rosary hanging from a machine claw; the visor gone cold
local crD = pile{{"Mars red",1},{"rose madder",1},{"bone black",0.15}}
local crL = pile{{"vermilion",1},{"cadmium red",0.5},{"rose madder",0.5}}
local bone = pile{{"lead white",2},{"yellow ochre",1},{"ultramarine ash",0.4}}
local boneL = pile{{"lead white",3},{"yellow ochre",0.8}}
local coldEye = pile{{"zinc white",3},{"cerulean blue",0.6},{"emerald green",0.2}}
local tab = poly({{252,300},{276,290},{300,296},{326,288},{348,300},{352,360},{358,420},{350,470},{342,448},{334,505},{322,470},{310,530},{298,478},{284,512},{272,470},{258,498},{250,440},{246,370}}):roughen(3, 16, 9)
work(tab, {hand="body", pile=crD, coverage=3.2, fill=true, clip=tab, angle=1.57})
local fb = brush{kind="filbert", width=6}
for _, f in ipairs({{{262,310},{258,380},{262,460}}, {{288,304},{286,390},{290,470}}, {{318,300},{322,380},{318,490}}}) do
  fb:reload(crL, 0.6)
  fb:stroke(f, {pressure={0.35, 0.1}, ramps={0.1, 0.6}, shake=0.6, clip=tab})
end
local rb = brush{kind="round", width=3, point=0.5}
rb:reload(crL, 0.8) rb:stroke({{348,302},{354,370},{356,430},{348,468}}, {pressure={0.55, 0.2}, clip=tab:grow(2)})
-- the cross on the breast
local cb = brush{kind="flat", width=5}
cb:reload(bone, 0.9) cb:stroke({{298,318},{298,366}}, {pressure={0.7, 0.6}, orient="across"})
cb:reload(bone, 0.9) cb:stroke({{284,334},{312,334}}, {pressure={0.7, 0.6}, orient="across"})
-- the visor slit, gone the Adversary's cold
rb:reload(coldEye, 0.9) rb:stroke({{286,222},{300,225},{316,224}}, {pressure={0.65, 0.4}})
-- a crown of small cold eyes where the masts fork and around the head
local eb = brush{kind="round", width=3}
for _, e in ipairs({{394,246},{520,236},{664,236},{758,288},{410,176},{352,178},{276,206},{322,212},{268,232},{330,236},{292,246}}) do
  eb:reload(coldEye, 0.8) eb:touch(e[1] + rand(-1,1), e[2] + rand(-1,1), {pressure=rand(0.4, 0.75)})
end
-- the rosary, dangling from the first manipulator's claw
local bead = brush{kind="round", width=3.2}
local path = {{120,646},{117,662},{116,678},{119,694},{124,708}}
for i, p in ipairs(path) do bead:reload(boneL, 0.8) bead:touch(p[1], p[2], {pressure=0.55}) end
for t = 1, 3 do bead:reload(boneL, 0.6) bead:touch(118 + t*0.5, 654 + t*16, {pressure=0.4}) end
cb = brush{kind="flat", width=3}
cb:reload(boneL, 0.9) cb:stroke({{125,714},{126,738}}, {pressure={0.7, 0.6}, orient="across"})
cb:reload(boneL, 0.9) cb:stroke({{118,721},{134,721}}, {pressure={0.7, 0.6}, orient="across"})

--@ chunk 19
-- the tabard is in shadow: take it down to a deep crimson, one warm-lit fold on the side toward the door
local crDD = pile{{"Mars red",0.6},{"rose madder",0.6},{"bone black",0.45},{"ultramarine blue",0.25}}
local tab = poly({{252,300},{276,290},{300,296},{326,288},{348,300},{352,360},{358,420},{350,470},{342,448},{334,505},{322,470},{310,530},{298,478},{284,512},{272,470},{258,498},{250,440},{246,370}}):roughen(3, 16, 9)
local shade = tab - ribbon({{338,300},{344,380},{340,480}}, 14) - rect(278, 310, 42, 66)
work(shade, {hand="body", pile=crDD, coverage=3, fill=true, clip=shade, angle=1.57, length={20, 60}})
-- crusader's visor: the eye slit gets its breath line, a cold cross on the face
local coldEye = pile{{"zinc white",3},{"cerulean blue",0.6},{"emerald green",0.2}}
local rb = brush{kind="round", width=3, point=0.5}
rb:reload(coldEye, 0.9) rb:stroke({{301,226},{301,240},{300,252}}, {pressure={0.6, 0.3}})

--@ chunk 20
print(wait(3*24*60))
print(drying(270,420), drying(300,340))
local crDD = pile{{"Mars red",0.5},{"rose madder",0.5},{"bone black",0.55},{"ultramarine blue",0.3}}
local tab = poly({{252,300},{276,290},{300,296},{326,288},{348,300},{352,360},{358,420},{350,470},{342,448},{334,505},{322,470},{310,530},{298,478},{284,512},{272,470},{258,498},{250,440},{246,370}}):roughen(3, 16, 9)
local crossM = (ribbon({{298,316},{298,368}}, 7) + ribbon({{282,334},{314,334}}, 7)):grow(3)
local shade = tab - ribbon({{338,300},{344,380},{340,480}}, 12) - crossM
work(shade, {hand="body", pile=crDD, coverage=3.4, fill=true, clip=shade, angle=1.57, length={20, 60}})

--@ chunk 21
print(drying(600,900), drying(80,400), drying(900,400))
-- the reflection dies toward us
local fl = floorM - CRE:grow(1)
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local midDark  = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"raw sienna",0.6},{"lead white",0.25}}
local low1 = poly({{470,840},{745,840},{748,915},{466,915}}):roughen(8, 30, 3) * fl
local low2 = poly({{460,915},{760,915},{760,1000},{460,1000}}):roughen(8, 30, 4) * fl
work(low1, {hand="body", pile=midDark, coverage=1.8, angle=math.pi/2, pressure={0.3, 0.7}, clip=fl, broken=0.4})
work(low2, {hand="body", pile=nearDark, coverage=3.2, fill=true, angle=math.pi/2, clip=fl})
-- niches in the bays of the walls: memorial recesses, a few still lit for guests that never came
local nicheD = pile{{"bone brown",1.5},{"ultramarine blue",1},{"burnt sienna",0.6}}
local lampP = pile{{"lead white",2},{"Indian yellow",0.6},{"cadmium yellow",0.3}}
local glowP = pile{{"yellow ochre",1},{"lead white",1},{"Mars orange",0.3}}
local function niche(x, y, w, h, lit)
  local m = poly({{x, y + h}, {x, y + w*0.6}, {x + w*0.5, y}, {x + w, y + w*0.6}, {x + w, y + h}})
  m = m - CRE:grow(2)
  work(m, {hand="detail", pile=nicheD, coverage=3, fill=true})
  if lit then
    local l = ellipse(x + w*0.5, y + h*0.55, w*0.18, h*0.12) - CRE:grow(2)
    work(l:grow(w*0.12), {hand="detail", pile=glowP, coverage=1.5})
    work(l, {hand="detail", pile=lampP, coverage=3, fill=true})
  end
end
niche(62, 330, 58, 240, true)
niche(140, 360, 30, 190, false)
niche(232, 350, 34, 170, false)
niche(326, 370, 22, 140, true)
niche(902, 300, 46, 230, false)
niche(826, 330, 26, 165, true)
niche(776, 352, 18, 120, false)
niche(732, 370, 12, 100, true)

--@ chunk 22
print(drying(560,520), drying(620,600))
-- deepen the graft: violet-black wells under the teeth, cold wet lights, tissue that will not stay inside its cage
local deep = pile{{"ultramarine blue",1},{"cobalt violet",0.6},{"bone black",0.8},{"magenta",0.2}}
local wet = pile{{"zinc white",3},{"cerulean blue",0.4},{"emerald green",0.15}}
local creep = pile{{"cobalt violet",1.2},{"ultramarine blue",0.6},{"magenta",0.3},{"zinc white",0.5}}
local cyanP = pile{{"cerulean blue",1},{"emerald green",0.5},{"zinc white",1.2}}
local fb = brush{kind="filbert", width=9}
-- wells: crescents under each tooth row and low in each cell
for _, c in ipairs({{478,540},{532,548},{596,540},{656,530},{716,520},{470,500},{600,505},{545,590},{612,600}}) do
  fb:reload(deep, 0.8)
  local x, y = c[1] + rand(-5,5), c[2] + rand(-5,5)
  fb:stroke({{x - 18, y - 4}, {x, y + 6}, {x + 16, y - 2}}, {pressure={0.7, 0.3}, ramps={0.1, 0.5}, shake=1.0, clip=ORG})
end
-- the bars do not stay put where they cross the tissue: fragments displaced sideways, like a reflection in moving water
local bb = brush{kind="flat", width=11}
for _, b in ipairs({{506,500,14},{566,505,-12},{628,490,10},{690,500,-9}}) do
  bb:reload(darkP, 1.0)
  bb:stroke({{b[1] + b[3], b[2] - 14}, {b[1] + b[3]*1.2, b[2] + 12}}, {pressure={0.9, 0.8}, orient="across"})
end
-- tissue creeping out over the plates: thin veins up the flank and toward the old body
local vb = brush{kind="round", width=5, point=0.8}
local veins = {
  {{470,480},{456,452},{470,420},{450,396}}, {{540,468},{548,440},{530,410},{544,388}}, {{640,460},{628,430},{650,404}},
  {{430,520},{400,500},{380,470},{372,440}}, {{424,540},{392,548},{360,530},{340,505}}, {{720,470},{740,440},{732,415}},
  {{360,440},{350,410},{360,380},{352,350}}, {{372,420},{390,390},{386,356}},
}
for _, v in ipairs(veins) do
  vb:reload(creep, 0.9)
  vb:stroke(v, {pressure={0.75, 0.05}, ramps={0.05, 0.7}, shake=1.6})
end
-- cold wet lights, sharp, few
local tb = brush{kind="round", width=3, point=0.4}
for _, p in ipairs({{560,500},{590,488},{652,494},{700,505},{514,520},{618,560},{378,410},{352,456},{606,622}}) do
  tb:reload(wet, 0.8)
  tb:stroke({{p[1], p[2]}, {p[1] + rand(-8, 8), p[2] + rand(-3, 6)}}, {pressure={0.6, 0.1}})
end
for _, p in ipairs({{540,530},{640,520},{700,480}}) do
  fb:reload(cyanP, 0.6) fb:touch(p[1], p[2], {pressure=0.5, drag={8, 0.4}})
end

--@ chunk 23
-- the witness: a Testator docent, back turned, at the right edge, a lamp held low
local bronzeD = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"raw sienna",0.6},{"bone black",0.3}}
local bronzeM = pile{{"raw sienna",1},{"burnt sienna",0.8},{"yellow ochre",0.5},{"ultramarine blue",0.3},{"lead white",0.3}}
local boneP = pile{{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.2}}
local boneS = pile{{"lead white",1},{"yellow ochre",0.6},{"ultramarine ash",0.6},{"bone brown",0.3}}
local body = poly({{842,800},{866,786},{900,784},{926,792},{940,850},{948,920},{958,1000},{818,1000},{824,920},{830,850}}, true)
local neck = ribbon({{880,752},{878,790}}, 12)
local head = ellipse(882, 722, 21, 35)
DOC = (body + neck + head):roughen(2, 14, 5)
work(DOC, {hand="body", pile=bronzeD, coverage=3.2, fill=true, clip=DOC, angle=1.57})
-- the long cranium: bone, in shadow, with a pale crown
local hb = brush{kind="filbert", width=8}
hb:reload(boneS, 0.8) hb:stroke({{874,698},{880,720},{884,746}}, {pressure={0.7, 0.4}, clip=head})
hb:reload(boneS, 0.8) hb:stroke({{890,694},{896,716},{892,744}}, {pressure={0.6, 0.3}, clip=head})
local rb = brush{kind="round", width=3, point=0.5}
rb:reload(boneP, 0.9) rb:stroke({{866,712},{868,694},{880,688},{892,692}}, {pressure={0.55, 0.3}})
-- rim light from the far door along the left edges
rb:reload(rimP, 0.9) rb:stroke({{846,804},{834,850},{828,920},{822,990}}, {pressure={0.5, 0.25}})
rb:reload(rimP, 0.9) rb:stroke({{846,800},{866,788},{884,786}}, {pressure={0.45, 0.2}})
-- golden-angle scale plates on its back, dim
local pb = brush{kind="filbert", width=4}
local ga = 2.39996
for i = 1, 34 do
  local r = 7.5 * math.sqrt(i)
  local a = i * ga
  local x, y = 886 + math.cos(a) * r * 1.1, 880 + math.sin(a) * r * 1.6
  if DOC:at(x, y) > 0.5 then
    pb:reload(bronzeM, 0.6)
    pb:stroke({{x - 4, y}, {x, y + 2}, {x + 4, y}}, {pressure={0.4, 0.15}})
  end
end
-- the lamp, held low and away: a warm point the cold maw can't reach
local lamp = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local lampHalo = pile{{"Mars orange",0.6},{"yellow ochre",1},{"lead white",1}, medium=0.3}
rb:reload(bronzeD, 0.9) rb:stroke({{934,860},{956,900},{962,930}}, {pressure={0.8, 0.6}})
work(ellipse(966, 950, 22, 22) - DOC, {hand="scumble", pile=lampHalo, coverage=1.2, load=0.3, pressure={0.15, 0.3}, clip=ellipse(966, 950, 26, 26) - DOC})
work(ellipse(965, 948, 6, 8), {hand="detail", pile=lamp, coverage=3, fill=true})

--@ chunk 24
print(wait(2*24*60))
print(drying(880,880), drying(600,880), drying(965,948))
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local fl = floorM - CRE:grow(1) - DOC:grow(1)
-- the near floor, one dark: no bands, no halo
local low = poly({{330,828},{800,828},{1000,850},{1000,1000},{300,1000}}):roughen(10, 40, 8) * fl
work(low, {hand="body", pile=nearDark, coverage=3.4, fill=true, angle=math.pi/2, clip=fl})
work(ellipse(966, 950, 30, 30) * fl, {hand="body", pile=nearDark, coverage=3.4, fill=true, clip=fl})
-- the docent again: robe dark and whole
local bronzeD = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"raw sienna",0.6},{"bone black",0.3}}
local robe = DOC - ellipse(882, 722, 23, 37)
work(robe, {hand="body", pile=bronzeD, coverage=3.4, fill=true, clip=robe, angle=1.57})
-- its head turns to look; a long bone face in profile
local boneP = pile{{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.2}}
local boneS = pile{{"lead white",1},{"yellow ochre",0.6},{"ultramarine ash",0.6},{"bone brown",0.3}}
local face = poly({{868,706},{852,716},{838,734},{846,742},{866,738},{876,726}}, true)
work(face, {hand="detail", pile=boneS, coverage=3, fill=true})
-- an arm lifts the lamp to the face
local rb = brush{kind="round", width=7}
rb:reload(bronzeD, 1.0) rb:stroke({{922,800},{944,790},{934,764},{904,750}}, {pressure={0.9, 0.7}})
local lampHalo = pile{{"Mars orange",0.5},{"yellow ochre",1},{"lead white",1.2}, medium=0.3}
local lamp = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
work(ellipse(896, 750, 26, 22) - DOC:shrink(2), {hand="scumble", pile=lampHalo, coverage=1.0, load=0.25, pressure={0.12, 0.25}, clip=ellipse(896, 750, 30, 26)})
-- lamplight on the face and the crown, from below
local tb = brush{kind="round", width=3, point=0.4}
local lampLit = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.25}}
tb:reload(lampLit, 0.9) tb:stroke({{840,738},{856,742},{872,736}}, {pressure={0.6, 0.3}})
tb:reload(lampLit, 0.9) tb:stroke({{878,742},{892,746},{900,738}}, {pressure={0.5, 0.2}})
tb:reload(lampLit, 0.8) tb:stroke({{904,742},{902,724},{898,704}}, {pressure={0.45, 0.1}})
work(ellipse(900, 752, 5, 6), {hand="detail", pile=lamp, coverage=3, fill=true})
-- the rim from the far door along its left side and crown
tb:reload(rimP, 0.9) tb:stroke({{846,804},{834,850},{828,920},{822,990}}, {pressure={0.5, 0.25}})
tb:reload(rimP, 0.9) tb:stroke({{862,700},{870,690},{884,686}}, {pressure={0.4, 0.2}})

--@ chunk 25
-- the concentric bands read as a target. Repaint the hall bay by bay: each bay between two ribs one tone, lighter toward the door.
local function archPts(s, lean)
  local xL, xR = VP[1] - 640*s, VP[1] + 560*s
  local yFL, yFR = VP[2] + 470*s, VP[2] + 380*s
  local ys = VP[2] - 230*s
  local xa, ya = VP[1] + lean*s, VP[2] - 560*s
  local pts = {{xL, yFL}, {xL, ys}}
  for i = 1, 6 do local t = i/6 pts[#pts+1] = {xL + (xa-xL)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  for i = 5, 0, -1 do local t = i/6 pts[#pts+1] = {xR - (xR-xa)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  pts[#pts+1] = {xR, yFR}
  return pts
end
local A = {{0.95, 10}, {0.66, -14}, {0.47, 8}, {0.355, -6}, {0.275, 4}}
local ribs, inside = nil, {}
for i, a in ipairs(A) do
  local pts = archPts(a[1], a[2])
  local r = ribbon(pts, 46*a[1]):roughen(2, 20, math.floor(a[1]*100))
  ribs = ribs and (ribs + r) or r
  inside[i] = poly(pts)
end
local niches = nil
for _, n in ipairs({{62,330,58,240},{140,360,30,190},{232,350,34,170},{326,370,22,140},{902,300,46,230},{826,330,26,165},{776,352,18,120},{732,370,12,100}}) do
  local x, y, w, h = n[1], n[2], n[3], n[4]
  local p = poly({{x, y + h}, {x, y + w*0.6}, {x + w*0.5, y}, {x + w, y + w*0.6}, {x + w, y + h}}):grow(1)
  niches = niches and (niches + p) or p
end
local keep = -(CRE:grow(2) + DOC:grow(2) + glowM:grow(2) + floorM + ribs:grow(1) + niches)
local P = {
  pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",1}},
  pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"bone brown",0.5},{"raw sienna",0.4}},
  pile{{"burnt sienna",1.5},{"raw sienna",1},{"ultramarine blue",0.6},{"yellow ochre",0.4},{"lead white",0.2}},
  pile{{"raw sienna",1},{"burnt sienna",0.8},{"yellow ochre",0.6},{"lead white",0.45},{"ultramarine blue",0.3}},
  pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.8},{"burnt sienna",0.3}},
  pile{{"lead white",1.5},{"yellow ochre",1},{"Mars orange",0.2}},
}
local toVP = function(x,y) return math.atan(VP[2]-y, VP[1]-x) end
for i = 1, 6 do
  local m
  if i == 1 then m = -inside[1] elseif i == 6 then m = inside[5] else m = inside[i-1] - inside[i] end
  m = m * keep
  work(m, {hand="body", pile=P[i], angle=toVP, coverage=3.2, fill=true, clip=keep})
end

--@ chunk 26
-- antlers with weight: restate every mast and manipulator the full width of its sleeve
local MP = {
 {{420,352},{402,262},{352,172},{332,84},{346,20}}, {{500,340},{522,250},{502,150},{532,58}}, {{462,342},{450,282},{474,206},{444,120}},
 {{590,350},{642,262},{702,192},{764,150},{858,128},{930,132}}, {{682,368},{742,302},{822,262},{904,252},{980,262}},
 {{734,382},{790,350},{830,300}}, {{366,264},{398,200},{430,142},{420,88}},
 {{288,198},{276,142},{262,98}}, {{312,194},{330,134},{352,104}}, {{300,190},{303,120},{296,60}},
 {{292,452},{206,500},{156,600},{122,642}}, {{232,560},{150,590},{64,640},{40,700}},
}
local TP = {
 {{392,240},{440,200},{452,150}}, {{356,180},{300,150},{282,110}}, {{518,232},{570,200},{590,150}}, {{662,238},{676,180},{660,130}},
 {{742,162},{760,110}}, {{760,286},{790,230}}, {{410,174},{456,160}}, {{820,134},{860,92},{900,80}}, {{860,256},{900,214}},
}
local mb = brush{kind="round", width=12}
for _, p in ipairs(MP) do
  -- in pieces, so the load doesn't run out along a long mast
  for i = 1, #p - 1 do
    mb:reload(darkP, 1.0)
    mb:stroke({p[i], p[i+1]}, {pressure={1.0, 0.95}, ramps={0.0, 0.05}, shake=0.3})
  end
end
local tb = brush{kind="round", width=9}
for _, p in ipairs(TP) do
  for i = 1, #p - 1 do
    tb:reload(darkP, 1.0)
    tb:stroke({p[i], p[i+1]}, {pressure={1.0, 0.9}, ramps={0.0, 0.05}, shake=0.3})
  end
end
-- the rosary, again, from the claw
local boneL = pile{{"lead white",3},{"yellow ochre",0.8}}
local bead = brush{kind="round", width=3.4}
for i, p in ipairs({{121,650},{118,664},{117,678},{119,692},{123,705}}) do bead:reload(boneL, 0.8) bead:touch(p[1], p[2], {pressure=0.6}) end
local cb = brush{kind="flat", width=3.2}
cb:reload(boneL, 0.9) cb:stroke({{125,712},{126,738}}, {pressure={0.75, 0.65}, orient="across"})
cb:reload(boneL, 0.9) cb:stroke({{117,720},{135,720}}, {pressure={0.75, 0.65}, orient="across"})
-- some of the shut lids in the graft open
local iris = pile{{"zinc white",2},{"emerald green",0.5},{"cerulean blue",0.5}}
local pupil = pile{{"bone black",1},{"ultramarine blue",0.5}}
local eb = brush{kind="round", width=6}
for _, e in ipairs({{478,548},{596,548},{716,528},{545,598}}) do
  eb:reload(iris, 0.9) eb:touch(e[1], e[2], {pressure=0.75})
  bead:reload(pupil, 0.9) bead:touch(e[1] + 0.5, e[2] + 0.5, {pressure=0.6})
end

--@ chunk 27
print(wait(4*24*60)) print(drying(402,262), drying(642,262))
-- warm rims back on the antlers, door side, broken
local function offsetToward(pts, off, cx, cy)
  local out = {}
  for i, p in ipairs(pts) do
    local a = pts[math.max(1, i-1)]; local b = pts[math.min(#pts, i+1)]
    local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy) + 1e-6
    local nx, ny = -dy/L, dx/L
    if nx*(cx-p[1]) + ny*(cy-p[2]) < 0 then nx, ny = -nx, -ny end
    out[i] = {p[1] + nx*off, p[2] + ny*off}
  end
  return out
end
local rb = brush{kind="round", width=2.6, point=0.4}
local function rim(seg, w, pile)
  local o = offsetToward(seg, w, 605, 380)
  rb:reload(pile or rimP, 0.85)
  rb:stroke(o, {pressure={rand(0.35, 0.6), 0.1}, ramps={0.2, 0.5}, shake=0.5})
end
local M = {
 {{420,352},{402,262},{352,172},{332,84}}, {{500,340},{522,250},{502,150},{532,58}}, {{462,342},{450,282},{474,206},{444,120}},
 {{590,350},{642,262},{702,192},{764,150},{858,128},{930,132}}, {{682,368},{742,302},{822,262},{904,252},{980,262}},
 {{734,382},{790,350},{830,300}}, {{366,264},{398,200},{430,142},{420,88}},
 {{392,240},{440,200},{452,150}}, {{518,232},{570,200},{590,150}}, {{662,238},{676,180},{660,130}},
 {{742,162},{760,110}}, {{760,286},{790,230}}, {{820,134},{860,92},{900,80}}, {{860,256},{900,214}},
}
for _, p in ipairs(M) do
  for i = 1, #p - 1 do
    if rand(0, 1) < 0.8 then
      local a, b = p[i], p[i+1]
      local t0, t1 = rand(0, 0.25), rand(0.7, 1)
      rim({{lerp(a[1], b[1], t0), lerp(a[2], b[2], t0)}, {lerp(a[1], b[1], t1), lerp(a[2], b[2], t1)}}, 4.5, (i == 1) and rimP or rimHot)
    end
  end
end
-- hard specular glints on the dorsal plates against the door
local gb = brush{kind="round", width=2.2}
for _, g in ipairs({{520,318},{560,322},{600,330},{640,338},{690,348},{730,358},{770,378}}) do
  gb:reload(rimHot, 0.8)
  gb:stroke({{g[1] - rand(4, 12), g[2] + 2}, {g[1] + rand(4, 10), g[2] + 3}}, {pressure={0.5, 0.2}})
end

--@ chunk 28
-- sharpen the antler ends: each blunt end drawn out to a point
local tips = {
 {{332,84},{346,20}}, {{502,150},{532,58}}, {{474,206},{444,120}}, {{858,128},{930,132}}, {{904,252},{980,262}},
 {{790,350},{830,300}}, {{430,142},{420,88}}, {{440,200},{452,150}}, {{570,200},{590,150}}, {{676,180},{660,130}},
 {{742,162},{760,110}}, {{760,286},{790,230}}, {{860,92},{900,80}}, {{860,256},{900,214}}, {{300,150},{282,110}},
 {{276,142},{262,98}}, {{330,134},{352,104}}, {{303,120},{296,60}},
}
local pb = brush{kind="round", width=11, point=1.0}
for _, t in ipairs(tips) do
  local a, b = t[1], t[2]
  local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy)
  local ux, uy = dx/L, dy/L
  local s = {b[1] - ux*14, b[2] - uy*14}
  local e = {b[1] + ux*rand(18, 34) + rand(-4,4), b[2] + uy*rand(18, 34) + rand(-4,4)}
  pb:reload(darkP, 1.0)
  pb:stroke({s, {b[1] + ux*4, b[2] + uy*4}, e}, {pressure={1.0, 0.0}, ramps={0.0, 0.85}})
end
-- the doorway gets a jamb; the grey haze on the rump goes dark
local jamb = (glowM:grow(9) - glowM:shrink(2)) - CRE:grow(1)
work(jamb, {hand="detail", pile=pile{{"burnt sienna",1},{"bone brown",1},{"ultramarine blue",0.6}}, coverage=3, fill=true})
local rump = poly({{735,372},{790,384},{812,420},{800,436},{760,420},{735,400}}, true)
work(rump, {hand="detail", pile=darkP, coverage=3.2, fill=true})

--@ chunk 29
-- light in the air at the door: a thin warm veil, blended, so the antlers stand in glare
local veil = ellipse(610, 330, 230, 170) - CRE:grow(1) - glowM
local veilP = pile{{"lead white",2},{"Indian yellow",0.4},{"Mars orange",0.3}, medium=0.45}
work(veil, {hand="glaze", pile=veilP, load=0.22, pressure={0.08, 0.2}, coverage=1.4, angle=0.15, clip=veil, edge="lost"})
blend(veil, {angle=0.15})
-- seam on the near floor: drag mid-dark across the crenellated edge
local midDark = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"raw sienna",0.6},{"lead white",0.25}}
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local seam = rect(330, 800, 470, 50) * fl
work(seam, {hand="scumble", pile=midDark, coverage=1.6, load=0.5, pressure={0.3, 0.6}, angle=0.0, clip=fl})
-- break the hard lit bar on the tabard into a fold
local crDD = pile{{"Mars red",0.5},{"rose madder",0.5},{"bone black",0.55},{"ultramarine blue",0.3}}
local fb = brush{kind="filbert", width=6}
for _, y in ipairs({330, 372, 418, 452}) do
  fb:reload(crDD, 0.8)
  fb:stroke({{336, y}, {346, y + 10}, {354, y + 14}}, {pressure={0.7, 0.3}})
end

--@ chunk 30
print(wait(3*24*60))
print(drying(610,250), drying(560,820))
-- undo the muddy veil: the inner bays and the door repainted opaque
local function archPts(s, lean)
  local xL, xR = VP[1] - 640*s, VP[1] + 560*s
  local yFL, yFR = VP[2] + 470*s, VP[2] + 380*s
  local ys = VP[2] - 230*s
  local xa, ya = VP[1] + lean*s, VP[2] - 560*s
  local pts = {{xL, yFL}, {xL, ys}}
  for i = 1, 6 do local t = i/6 pts[#pts+1] = {xL + (xa-xL)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  for i = 5, 0, -1 do local t = i/6 pts[#pts+1] = {xR - (xR-xa)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  pts[#pts+1] = {xR, yFR}
  return pts
end
local A = {{0.47, 8}, {0.355, -6}, {0.275, 4}}
local ribs, inside = nil, {}
for i, a in ipairs(A) do
  local pts = archPts(a[1], a[2])
  local r = ribbon(pts, 46*a[1]):roughen(2, 20, math.floor(a[1]*100))
  ribs = ribs and (ribs + r) or r
  inside[i] = poly(pts)
end
local niches = nil
for _, n in ipairs({{826,330,26,165},{776,352,18,120},{732,370,12,100},{326,370,22,140}}) do
  local x, y, w, h = n[1], n[2], n[3], n[4]
  local p = poly({{x, y + h}, {x, y + w*0.6}, {x + w*0.5, y}, {x + w, y + w*0.6}, {x + w, y + h}}):grow(1)
  niches = niches and (niches + p) or p
end
local keep = -(CRE:grow(2) + glowM:grow(9) + floorM + ribs:grow(1) + niches)
local toVP = function(x,y) return math.atan(VP[2]-y, VP[1]-x) end
local P = {
  pile{{"raw sienna",1},{"burnt sienna",0.8},{"yellow ochre",0.6},{"lead white",0.45},{"ultramarine blue",0.3}},
  pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.8},{"burnt sienna",0.3}},
  pile{{"lead white",1.5},{"yellow ochre",1},{"Mars orange",0.2}},
}
for i = 1, 3 do
  local m = (i < 3) and (inside[i] - inside[i+1]) or inside[3]
  m = m * keep * ellipse(610, 330, 250, 200):grow(10)
  work(m, {hand="body", pile=P[i], angle=toVP, coverage=3.2, fill=true, clip=keep})
end
-- the jamb restated and the door light itself, warmer and whiter at its heart
local jamb = (glowM:grow(9) - glowM:shrink(1)) - CRE:grow(1)
work(jamb, {hand="detail", pile=pile{{"burnt sienna",1},{"bone brown",1},{"ultramarine blue",0.6}}, coverage=3, fill=true})
local door = glowM:shrink(1) - CRE:grow(1)
work(door, {hand="body", pile=pile{{"lead white",2.5},{"yellow ochre",0.6},{"Indian yellow",0.4}}, coverage=3, fill=true, clip=door, angle=1.57})
local heart = ellipse(612, 300, 40, 36) - CRE:grow(1)
work(heart, {hand="body", pile=pile{{"zinc white",2},{"lead white",1},{"lemon chrome",0.25}}, coverage=3, fill=true, clip=door, angle=1.57})
-- the grey band on the near floor sunk into the dark
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local band = rect(318, 788, 500, 80):roughen(8, 30, 12) * fl
work(band, {hand="body", pile=nearDark, coverage=3.4, fill=true, angle=math.pi/2, clip=fl})

--@ chunk 31
-- break the fringe: the reflection drawn down in long uneven vertical drags, like a polished floor
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local fb = brush{kind="filbert", width=6}
local x = 420
while x < 790 do
  fb:reload(nearDark, rand(0.5, 0.9))
  local top = 800 - rand(10, 70)
  fb:stroke({{x, 812}, {x + rand(-2, 2), top}}, {pressure={0.8, 0.05}, ramps={0.0, 0.7}, clip=fl, shake=0.8})
  x = x + rand(5, 12)
end
blend(rect(400, 790, 420, 30) * fl, {angle=0})
-- the inner ribs, veiled grey by the failed glaze, restated dark with their lit inner edge
local function archPts(s, lean)
  local xL, xR = VP[1] - 640*s, VP[1] + 560*s
  local yFL, yFR = VP[2] + 470*s, VP[2] + 380*s
  local ys = VP[2] - 230*s
  local xa, ya = VP[1] + lean*s, VP[2] - 560*s
  local pts = {{xL, yFL}, {xL, ys}}
  for i = 1, 6 do local t = i/6 pts[#pts+1] = {xL + (xa-xL)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  for i = 5, 0, -1 do local t = i/6 pts[#pts+1] = {xR - (xR-xa)*(1-math.cos(t*math.pi/2)), ys - (ys-ya)*math.sin(t*math.pi/2)} end
  pts[#pts+1] = {xR, yFR}
  return pts
end
local ribP = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"bone brown",1},{"raw sienna",0.4}}
local edgeP = pile{{"lead white",1.5},{"yellow ochre",1},{"Indian yellow",0.3},{"Mars orange",0.2}}
local keep = -(CRE:grow(2) + glowM:grow(9) + DOC)
local eb = brush{kind="round", width=3}
for _, a in ipairs({{0.47, 8}, {0.355, -6}, {0.275, 4}}) do
  local s = a[1]
  local pts = archPts(s, a[2])
  local band = ribbon(pts, 40*s):roughen(1.5, 20, math.floor(s*100) + 1) * ellipse(610, 330, 270, 220) * keep - floorM
  work(band, {hand="detail", pile=ribP, coverage=3, fill=true})
  local inner = {}
  for i, p in ipairs(pts) do
    local dx, dy = VP[1]-p[1], VP[2]-p[2]; local L = math.sqrt(dx*dx+dy*dy)
    inner[i] = {p[1] + dx/L*(20*s - 1), p[2] + dy/L*(20*s - 1)}
  end
  for i = 2, #inner - 2, 2 do
    eb:reload(edgeP, 0.9)
    eb:stroke({inner[i], inner[i+1], inner[i+2]}, {pressure={0.5, 0.4}, clip=keep * ellipse(610, 330, 270, 220), shake=0.5})
  end
end

--@ chunk 32
-- too many limbs: folded palps under the chest, small crab-arms working under the belly, spurs at the knees
local ab = brush{kind="round", width=8}
local sb = brush{kind="round", width=5, point=0.7}
local function limb(pts, w)
  for i = 1, #pts - 1 do
    ab:reload(darkP, 1.0)
    ab:stroke({pts[i], pts[i+1]}, {pressure={w, w*0.9}, ramps={0, 0.05}})
  end
end
limb({{330,600},{372,660},{340,712},{372,748}}, 1.0)
limb({{300,620},{280,690},{318,730}}, 0.9)
limb({{520,628},{548,672},{530,712},{556,736}}, 0.8)
limb({{430,640},{410,690},{438,720}}, 0.75)
limb({{640,612},{676,650},{664,690}}, 0.7)
for _, c in ipairs({{{372,748},{384,770}}, {{372,748},{360,772}}, {{318,730},{330,752}}, {{556,736},{566,756}}, {{556,736},{544,758}}, {{438,720},{452,738}}, {{664,690},{676,708}}}) do
  sb:reload(darkP, 0.9) sb:stroke(c, {pressure={0.9, 0.0}, ramps={0, 0.8}})
end
-- spurs at the knees
for _, k in ipairs({{165,715,-1},{530,735,1},{765,655,1},{410,740,1},{612,690,1},{805,612,1}}) do
  sb:reload(darkP, 0.9)
  sb:stroke({{k[1], k[2]}, {k[1] + 10*k[3], k[2] - 18}, {k[1] + 20*k[3], k[2] - 30}}, {pressure={1.0, 0.0}, ramps={0, 0.8}})
end
-- the graft's cold light catching the undersides near it
local coldP2 = pile{{"zinc white",2},{"cerulean blue",1},{"cobalt violet",0.5}}
local rb = brush{kind="round", width=2.6, point=0.4}
local function cold(pts, pr) rb:reload(coldP2, 0.85) rb:stroke(pts, {pressure=pr or {0.5, 0.1}, ramps={0.15, 0.5}, shake=0.5}) end
cold({{334,606},{372,662}}) cold({{524,632},{550,672}}) cold({{434,644},{414,688}}, {0.4, 0.1}) cold({{644,616},{676,650}})
cold({{470,640},{530,646},{590,652}}, {0.45, 0.2}) cold({{456,622},{500,616}}, {0.35, 0.1})
-- a cold sheen on the floor directly under the graft
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local sheen = pile{{"cobalt violet",1},{"ultramarine blue",0.8},{"zinc white",0.7},{"cerulean blue",0.2}}
local hb = brush{kind="filbert", width=7}
for i = 1, 16 do
  local x, y = rand(470, 700), rand(700, 770)
  hb:reload(sheen, rand(0.4, 0.7))
  hb:stroke({{x - rand(10, 30), y}, {x + rand(10, 30), y + rand(-2, 2)}}, {pressure={0.4, 0.15}, clip=fl})
end

--@ chunk 33
print(drying(880,720), drying(896,750))
-- the docent's head again: a cowl of bronze, a narrow bone face turned up toward the thing, lamp held out
local bronzeD = pile{{"burnt sienna",1.5},{"ultramarine blue",1},{"raw sienna",0.6},{"bone black",0.3}}
local hood = poly({{844,776},{838,732},{848,700},{870,682},{898,682},{918,700},{928,738},{932,776}}, true):roughen(1.5, 12, 3)
work(hood, {hand="detail", pile=bronzeD, coverage=3.4, fill=true})
local boneS = pile{{"lead white",1.2},{"yellow ochre",0.6},{"ultramarine ash",0.5},{"bone brown",0.25}}
local face = poly({{858,742},{856,716},{864,700},{874,698},{878,716},{874,740},{866,750}}, true)
work(face, {hand="detail", pile=boneS, coverage=3, fill=true})
-- lamp out to the right, a small hot flame, its light on the cowl's edge and the face's jaw
local rb = brush{kind="round", width=6}
rb:reload(bronzeD, 1.0) rb:stroke({{926,792},{946,786},{952,770}}, {pressure={0.9, 0.8}})
local lamp = pile{{"lead white",2},{"cadmium yellow",0.6},{"Indian yellow",0.3}}
local lampLit = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.25}}
local tb = brush{kind="round", width=2.6, point=0.4}
tb:reload(lampLit, 0.9) tb:stroke({{930,770},{926,740},{916,706}}, {pressure={0.55, 0.1}})
tb:reload(lampLit, 0.8) tb:stroke({{860,746},{870,748},{878,738}}, {pressure={0.45, 0.15}})
tb:reload(lampLit, 0.8) tb:stroke({{940,800},{944,840},{946,880}}, {pressure={0.4, 0.1}})
work(ellipse(954, 764, 5, 7), {hand="detail", pile=lamp, coverage=3, fill=true})
-- the door's rim along the cowl's top, left
tb:reload(rimP, 0.9) tb:stroke({{846,730},{850,702},{870,684},{892,682}}, {pressure={0.45, 0.2}})

--@ chunk 34
-- deepen the cells of the graft from below, and open three eyes properly
local deep = pile{{"ultramarine blue",1},{"cobalt violet",0.5},{"bone black",0.9},{"magenta",0.15}}
local fb = brush{kind="filbert", width=10}
for _, c in ipairs({{482,560},{536,566},{598,560},{660,552},{716,540},{560,610},{618,620},{520,612}}) do
  fb:reload(deep, 0.9)
  local x, y = c[1] + rand(-3,3), c[2] + rand(-3,3)
  fb:stroke({{x - 20, y + 4}, {x, y - 2}, {x + 18, y + 4}}, {pressure={0.8, 0.5}, ramps={0.1, 0.4}, shake=1.0, clip=ORG})
end
local white = pile{{"zinc white",3},{"cerulean blue",0.2}}
local iris = pile{{"emerald green",0.6},{"cerulean blue",0.6},{"zinc white",1.2}}
local pupil = pile{{"bone black",1},{"ultramarine blue",0.4}}
local eb = brush{kind="round", width=11}
local ib = brush{kind="round", width=7}
local pb = brush{kind="round", width=3.5}
for _, e in ipairs({{540,522,1.0},{650,512,0.8},{705,500,0.65}}) do
  eb:reload(white, 0.9) eb:touch(e[1], e[2], {pressure=0.75*e[3] + 0.2})
  ib:reload(iris, 0.9) ib:touch(e[1] - 1.5, e[2] + 0.5, {pressure=0.7*e[3] + 0.2})
  pb:reload(pupil, 0.9) pb:touch(e[1] - 2.5, e[2] + 0.5, {pressure=0.7})
end

--@ chunk 35
print(wait(2*24*60))
print(drying(540,560), drying(600,600))
-- the graft's lower body goes deep and dark; the light stays high in it, under the teeth
local deepO = pile{{"bone black",1},{"ultramarine blue",1},{"cobalt violet",0.5},{"magenta",0.2}}
local lower = ORG:shrink(3) * below({{400,520},{500,532},{600,530},{700,515},{780,505}})
lower = lower:roughen(6, 26, 31)
work(lower, {hand="body", pile=deepO, coverage=3.2, fill=true, clip=ORG:shrink(2), angle=0.2, length={12, 40}})
-- a few cold strands of light dragged down into the dark
local strand = pile{{"cobalt violet",1},{"cerulean blue",0.6},{"zinc white",0.8}}
local sb = brush{kind="round", width=4, point=0.7}
for _, s in ipairs({{{470,532},{478,560},{468,590}}, {{590,534},{598,566},{606,600},{612,630}}, {{680,520},{672,548}}, {{528,540},{520,580},{526,610}}}) do
  sb:reload(strand, 0.7) sb:stroke(s, {pressure={0.6, 0.05}, ramps={0.05, 0.7}, shake=1.2})
end
-- eyes: almond, pale, too many and not where eyes go
local white = pile{{"zinc white",3},{"cerulean blue",0.25}}
local irisP = pile{{"emerald green",0.6},{"cerulean blue",0.8},{"zinc white",0.8}}
local pupil = pile{{"bone black",1},{"ultramarine blue",0.4}}
local function eye(x, y, w, h, tilt)
  local c, s = math.cos(tilt), math.sin(tilt)
  local function P(u, v) return {x + u*c - v*s, y + u*s + v*c} end
  local almond = poly({P(-w, 0), P(-w*0.5, -h*0.8), P(0, -h), P(w*0.5, -h*0.8), P(w, 0), P(w*0.5, h*0.8), P(0, h), P(-w*0.5, h*0.8)}, true)
  work(almond, {hand="detail", pile=white, coverage=3, fill=true})
  work(ellipse(x + rand(-1.5, 1.5), y, h*0.85, h*0.85) * almond, {hand="detail", pile=irisP, coverage=3, fill=true})
  work(ellipse(x, y, h*0.32, h*0.75) * almond, {hand="detail", pile=pupil, coverage=3, fill=true})
end
eye(540, 562, 13, 6, 0.1)
eye(652, 548, 11, 5, -0.15)
eye(606, 604, 9, 4.5, 0.3)
eye(478, 572, 7, 3.5, -0.2)

--@ chunk 36
-- soft wet sheens on the dark tissue (into wet, so they melt), lumps that don't agree on where the light is
local sheen1 = pile{{"cobalt violet",1},{"magenta",0.4},{"zinc white",0.6}}
local sheen2 = pile{{"cerulean blue",0.8},{"emerald green",0.3},{"zinc white",0.8}}
local fb = brush{kind="filbert", width=7}
local sw = {{450,548,0.3},{500,590,-0.4},{560,586,0.2},{628,580,-0.6},{690,540,0.5},{585,630,1.2},{530,618,-1.0},{720,522,0.1},{455,566,2.0},{640,606,-2.4}}
for i, s in ipairs(sw) do
  fb:reload((i % 3 == 0) and sheen2 or sheen1, 0.5)
  local a = s[3]
  fb:stroke({{s[1] - math.cos(a)*12, s[2] - math.sin(a)*6}, {s[1], s[2] - 3}, {s[1] + math.cos(a)*12, s[2] + math.sin(a)*6}}, {pressure={0.35, 0.1}, ramps={0.2, 0.5}, clip=ORG:shrink(3)})
end

--@ chunk 37
-- what he was, discarded: an old Church frame lying on the floor at the left, a helm with a dead visor
local metal = pile{{"Mars brown",1.5},{"ultramarine blue",1},{"bone black",0.6},{"raw sienna",0.5},{"lead white",0.15}}
local helm = ellipse(150, 918, 17, 19)
local torso = poly({{56,930},{96,914},{132,912},{142,940},{126,962},{74,970}}, true)
local arm = ribbon({{80,924},{48,898},{22,906}}, {12, 10, 9})
local leg1 = ribbon({{64,958},{24,976},{-6,972}}, {16, 13, 12})
local leg2 = ribbon({{80,966},{44,990},{10,1004}}, {15, 12, 11})
local shoulder = ellipse(124, 920, 14, 11)
local relic = (helm + torso + arm + leg1 + leg2 + shoulder):roughen(1.5, 14, 61) - CRE:grow(1)
work(relic, {hand="detail", pile=metal, coverage=3.2, fill=true})
local crS = pile{{"Mars red",0.6},{"rose madder",0.5},{"bone black",0.35}}
work(poly({{88,932},{120,924},{128,948},{110,972},{98,950},{86,968}}, true) * relic, {hand="detail", pile=crS, coverage=3, fill=true})
-- the dead visor, a cross of shadow
local rb = brush{kind="round", width=3}
local dead = pile{{"bone black",1},{"ultramarine blue",0.5}}
rb:reload(dead, 0.9) rb:stroke({{138,912},{150,910},{162,912}}, {pressure={0.6, 0.6}})
rb:reload(dead, 0.9) rb:stroke({{150,911},{151,928}}, {pressure={0.6, 0.6}})
-- the light from the door finds its upper edges
local tb = brush{kind="round", width=2.4, point=0.4}
for _, e in ipairs({{{136,904},{150,898},{164,904},{168,914}}, {{98,913},{120,909},{134,913}}, {{50,898},{28,902}}, {{60,928},{90,915}}, {{142,936},{130,958}}}) do
  tb:reload(rimP, 0.85) tb:stroke(e, {pressure={0.5, 0.15}, ramps={0.1, 0.5}})
end

--@ chunk 38
print(wait(2*24*60))
print(drying(110,940))
local metal2 = pile{{"Mars brown",2},{"ultramarine blue",1},{"bone black",1},{"raw sienna",0.3}}
local helm = ellipse(150, 918, 17, 19)
local torso = poly({{56,930},{96,914},{132,912},{142,940},{126,962},{74,970}}, true)
local arm = ribbon({{80,924},{48,898},{22,906}}, {12, 10, 9})
local leg1 = ribbon({{64,958},{24,976},{-6,972}}, {16, 13, 12})
local leg2 = ribbon({{80,966},{44,990},{10,1004}}, {15, 12, 11})
local shoulder = ellipse(124, 920, 14, 11)
RELIC = (helm + torso + arm + leg1 + leg2 + shoulder):roughen(1.5, 14, 61) - CRE:grow(1)
local tab = poly({{88,932},{120,924},{128,948},{110,972},{98,950},{86,968}}, true)
local visor = ribbon({{138,912},{162,912}}, 4) + ribbon({{150,911},{151,928}}, 4)
work(RELIC - tab:grow(1) - visor:grow(1), {hand="detail", pile=metal2, coverage=3.4, fill=true})
-- seams and the light finding its edges
local plate = pile{{"burnt sienna",1},{"raw sienna",1},{"ultramarine blue",0.5},{"lead white",0.35}}
local tb = brush{kind="round", width=2.2, point=0.4}
for _, s in ipairs({{{60,944},{100,936}}, {{30,980},{60,964}}, {{36,910},{60,906}}, {{14,994},{50,980}}}) do
  tb:reload(plate, 0.7) tb:stroke(s, {pressure={0.4, 0.1}})
end
for _, e in ipairs({{{136,904},{150,898},{164,904},{168,914}}, {{98,913},{120,909},{134,913}}, {{50,896},{28,900}}, {{58,927},{90,914}}, {{20,970},{56,955}}}) do
  tb:reload(rimP, 0.85) tb:stroke(e, {pressure={0.5, 0.15}, ramps={0.1, 0.5}})
end

--@ chunk 39
-- dim plating on the hump: barely above the dark, short tapered strokes, no blending
local dim = pile{{"Mars brown",1.5},{"ultramarine blue",0.8},{"bone black",0.5},{"raw sienna",0.6},{"lead white",0.3}}
local dimW = pile{{"burnt sienna",1},{"raw sienna",0.8},{"ultramarine blue",0.6},{"bone black",0.3},{"lead white",0.35}}
local b = brush{kind="filbert", width=4}
local rows = {{352, 0.8}, {378, 0.9}, {404, 1.0}, {430, 0.85}, {454, 0.7}}
for ri, r in ipairs(rows) do
  local x = 400 + rand(0, 20)
  while x < 770 do
    local f = 1 - (x - 380) / 1000
    local len = rand(24, 46) * f
    local y = r[1] + 0.045*(x - 400) + rand(-4, 4) + (ri - 3)*2
    if y < 470 then
      b:reload((rand(0,1) < 0.5) and dim or dimW, 0.6)
      b:stroke({{x, y + 4}, {x + len*0.5, y}, {x + len, y + 3}}, {pressure={0.45*r[2], 0.05}, ramps={0.1, 0.6}, shake=0.6})
    end
    x = x + len * rand(0.9, 1.4)
  end
end
-- dim warm bounce on the chest's left contour and the near front leg, from the lit left wall
local tb = brush{kind="round", width=3, point=0.4}
for _, e in ipairs({{{222,450},{216,520},{220,600}}, {{232,640},{196,676},{168,710}}, {{158,722},{170,800},{186,900}}, {{234,300},{240,360},{244,430}}}) do
  tb:reload(dimW, 0.8) tb:stroke(e, {pressure={0.5, 0.15}, ramps={0.1, 0.5}, shake=0.5})
end

--@ chunk 40
-- tabard: one cloth in shadow, a single warm edge
local crM = pile{{"Mars red",0.8},{"rose madder",0.6},{"bone black",0.3}}
local crDD = pile{{"Mars red",0.5},{"rose madder",0.5},{"bone black",0.55},{"ultramarine blue",0.3}}
local strip = ribbon({{340,296},{346,380},{344,476}}, 18)
work(strip, {hand="body", pile=crM, coverage=3.2, fill=true, clip=strip, angle=1.57, length={30, 80}})
local crossCore = ribbon({{298,318},{298,366}}, 5) + ribbon({{284,334},{312,334}}, 5)
local halo = (ribbon({{298,314},{298,370}}, 18) + ribbon({{278,334},{318,334}}, 18)) - crossCore:grow(1.5)
work(halo, {hand="detail", pile=crDD, coverage=3.2, fill=true})
local tb = brush{kind="round", width=2.4, point=0.4}
tb:reload(rimP, 0.85) tb:stroke({{351,304},{356,370},{358,430},{352,466}}, {pressure={0.45, 0.15}, ramps={0.1, 0.5}})

--@ chunk 41
print(wait(2*24*60))
print(drying(344,400))
local crDD = pile{{"Mars red",0.5},{"rose madder",0.5},{"bone black",0.55},{"ultramarine blue",0.3}}
local crM = pile{{"Mars red",0.8},{"rose madder",0.6},{"bone black",0.3}}
local strip = ribbon({{340,296},{346,380},{344,476}}, 20)
work(strip, {hand="body", pile=crDD, coverage=3.4, fill=true, clip=strip, angle=1.57, length={30, 80}})
local fb = brush{kind="filbert", width=5}
fb:reload(crM, 0.6) fb:stroke({{346,304},{350,350},{347,400},{340,450}}, {pressure={0.5, 0.05}, ramps={0.1, 0.7}, shake=0.8})
fb:reload(crM, 0.5) fb:stroke({{270,330},{266,400},{272,470}}, {pressure={0.35, 0.05}, ramps={0.1, 0.7}, shake=0.8})
local tb = brush{kind="round", width=2.4, point=0.4}
tb:reload(rimP, 0.85) tb:stroke({{353,306},{357,370},{356,430},{350,462}}, {pressure={0.5, 0.15}, ramps={0.1, 0.5}})

--@ chunk 42
-- the floor under it, laid again wet-in-wet as one polished reflection
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local R = poly({{330,700},{470,640},{740,640},{860,700},{860,830},{330,830}}):roughen(10, 40, 77) * fl
local midDark  = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"raw sienna",0.6},{"lead white",0.2}}
local streakP  = pile{{"yellow ochre",1.2},{"raw sienna",0.8},{"lead white",0.9},{"Indian yellow",0.2}}
local sheen    = pile{{"cobalt violet",1},{"ultramarine blue",0.8},{"zinc white",0.6}}
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
work(R, {hand="body", pile=midDark, angle=math.pi/2, coverage=3, fill=true, clip=R})
-- the door's light, falling down the floor toward us, thinning
local S = poly({{520,640},{690,640},{705,830},{505,830}}):roughen(8, 30, 78) * R
work(S, {hand="body", pile=streakP, angle=math.pi/2, coverage=2.4, pressure={0.4, 0.8}, clip=R,
  load_at=function(x, y) return clamp(0.9 - (y - 640) / 210, 0.05, 0.9) end})
-- cold of the graft, smeared across under it
local C = ellipse(585, 735, 150, 34) * R
work(C, {hand="body", pile=sheen, angle=0.0, coverage=1.6, pressure={0.3, 0.6}, clip=R, length={20, 50}})
-- each leg's reflection, straight down
local rb = brush{kind="filbert", width=10}
for _, f in ipairs({{478,872,0},{372,890,0},{722,774,60},{606,804,40},{792,708,90}}) do
  if f[3] > 0 then
    rb:reload(nearDark, 0.7)
    rb:stroke({{f[1], f[2] + 4}, {f[1] + rand(-3, 3), f[2] + f[3]}}, {pressure={0.7, 0.1}, ramps={0.05, 0.6}, clip=R, shake=1})
  end
end
blend(R:shrink(4), {angle=math.pi/2})

--@ chunk 43
print(wait(30*60))
print(drying(450,760), drying(600,700))
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local R = poly({{320,690},{470,632},{745,632},{870,690},{870,845},{320,845}}):roughen(6, 40, 79) * fl
local S = poly({{526,630},{688,630},{700,760},{712,850},{498,850},{512,760}}):roughen(6, 26, 80)
local midDark  = pile{{"bone brown",1.6},{"ultramarine blue",0.9},{"raw sienna",0.5},{"lead white",0.12}}
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local sides = R - S
work(sides * above(function(x) return 745 end), {hand="body", pile=midDark, angle=math.pi/2, coverage=3.6, fill=true, clip=sides})
work(sides * below(function(x) return 745 end), {hand="body", pile=nearDark, angle=math.pi/2, coverage=3.6, fill=true, clip=sides})
-- the bottom of the reflection dies into the dark in uneven vertical drags
local fb = brush{kind="filbert", width=7}
local x = 500
while x < 712 do
  fb:reload(nearDark, rand(0.6, 0.95))
  fb:stroke({{x, 852}, {x + rand(-2, 2), 852 - rand(40, 120)}}, {pressure={0.9, 0.05}, ramps={0.0, 0.75}, clip=R * S:grow(4), shake=0.6})
  x = x + rand(4, 9)
end

--@ chunk 44
print(wait(36*60))
print(drying(560,400))
-- break the basket-weave of the plates: dark patches knocked over them, unevenly, the plating seen only in places
local hump = poly({{392,340},{520,328},{640,340},{760,368},{790,420},{770,470},{420,480},{390,440}}, true) - ORG:grow(3)
stipple(hump, {pile=darkP, width=16, coverage=0.75, cluster={0.8, 60}, pressure={0.6, 0.9}, drag=6, seed=4})

--@ chunk 45
-- the chest and the guns: dim plating, muzzles, a bounce of the lit wall along the barrels
local dim = pile{{"Mars brown",1.5},{"ultramarine blue",0.8},{"bone black",0.5},{"raw sienna",0.6},{"lead white",0.3}}
local dimW = pile{{"burnt sienna",1},{"raw sienna",0.8},{"ultramarine blue",0.6},{"bone black",0.3},{"lead white",0.35}}
local b = brush{kind="filbert", width=4}
for col = 0, 4 do
  local x0 = 222 + col*26 + rand(-4, 4)
  local y = 470 + rand(0, 14)
  while y < 640 do
    local len = rand(18, 32)
    b:reload((rand(0,1) < 0.5) and dim or dimW, 0.6)
    b:stroke({{x0 + 6, y}, {x0 + 1, y + len*0.5}, {x0 + 4, y + len}}, {pressure={0.4, 0.05}, ramps={0.1, 0.6}, shake=0.6})
    y = y + len * rand(0.9, 1.3)
  end
end
print(wait(36*60))
local chest = poly({{212,460},{350,470},{360,650},{220,650}})
stipple(chest - ORG:grow(2), {pile=darkP, width=14, coverage=0.6, cluster={0.8, 50}, pressure={0.6, 0.9}, drag=5, seed=9})
-- bounce along the barrels' upper edges
local tb = brush{kind="round", width=2.4, point=0.4}
tb:reload(dimW, 0.9) tb:stroke({{100,342},{200,324},{300,304}}, {pressure={0.45, 0.3}})
tb:reload(dimW, 0.9) tb:stroke({{116,554},{180,536},{240,520}}, {pressure={0.45, 0.3}})
-- muzzles: a bronze lip on the rail, three bores on the rotary
local mb = brush{kind="round", width=3}
mb:reload(dimW, 0.9) mb:stroke({{92,343},{86,350},{90,360},{98,358}}, {pressure={0.6, 0.5}})
local bore = pile{{"bone black",1},{"ultramarine blue",0.4}}
for _, p in ipairs({{108,558},{104,568},{114,572}}) do
  mb:reload(dimW, 0.8) mb:touch(p[1], p[2], {pressure=0.8})
  local s = brush{kind="round", width=1.8}
  s:reload(bore, 0.9) s:touch(p[1], p[2], {pressure=0.7})
end

--@ chunk 46
print(wait(24*60))
-- the guns, cleaned of the old grey haze
local guns = ribbon({{360,292},{90,352}}, {21,13}) + ribbon({{262,520},{110,566}}, {27,19})
work(guns - poly(torso, true), {hand="detail", pile=darkP, coverage=3.4, fill=true})
local dimW = pile{{"burnt sienna",1},{"raw sienna",0.8},{"ultramarine blue",0.6},{"bone black",0.3},{"lead white",0.35}}
local tb = brush{kind="round", width=2.4, point=0.4}
tb:reload(dimW, 0.9) tb:stroke({{96,344},{170,330},{238,318}}, {pressure={0.45, 0.25}})
tb:reload(dimW, 0.9) tb:stroke({{118,556},{180,538},{234,524}}, {pressure={0.45, 0.25}})
local mb = brush{kind="round", width=3}
mb:reload(dimW, 0.9) mb:stroke({{92,344},{86,351},{90,360},{98,358}}, {pressure={0.6, 0.5}})

--@ chunk 47
-- nothing on it holds still: a cold after-image of a leg and an antler, a step out of place
local ghost = pile{{"cobalt violet",1},{"cerulean blue",0.6},{"zinc white",0.8}, medium=0.3}
local gb = brush{kind="round", width=3, point=0.6}
local function g(pts, l) gb:reload(ghost, l or 0.35) gb:stroke(pts, {pressure={0.45, 0.1}, ramps={0.2, 0.5}, shake=1.4}) end
g({{696,566},{788,646},{746,762}}) g({{708,560},{800,640},{760,756}}, 0.25)
g({{760,642},{770,650}}, 0.5)
g({{606,346},{660,256},{722,188},{786,148}}) g({{616,344},{670,252},{732,184}}, 0.25)
g({{822,606},{840,640},{828,690}}) g({{560,618},{604,700},{596,780}}, 0.25)

--@ chunk 48
print(wait(24*60))
print(drying(760,700))
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local S = poly({{526,630},{688,630},{700,760},{712,850},{498,850},{512,760}}):roughen(6, 26, 80)
local M = poly({{320,690},{470,620},{520,612},{520,760},{320,760}}):roughen(6, 40, 81) + poly({{694,612},{760,612},{880,690},{880,770},{702,770}}):roughen(6, 40, 82)
local shadeP = pile{{"bone brown",1.8},{"ultramarine blue",1},{"burnt sienna",0.4},{"raw sienna",0.2}}
local m = M * fl - S
work(m, {hand="body", pile=shadeP, angle=math.pi/2, coverage=3.6, fill=true, clip=fl - S:shrink(3)})

--@ chunk 49
local paleT = pile{{"zinc white",2},{"cerulean blue",0.5},{"cobalt violet",0.5}}
local paleV = pile{{"zinc white",1.5},{"cobalt violet",0.8},{"magenta",0.2}}
local fb = brush{kind="filbert", width=8}
for _, s in ipairs({{{456,496},{474,500},{492,494}}, {{584,504},{602,510},{620,504}}, {{694,500},{706,500}}, {{458,504},{490,502}}, {{586,512},{618,510}}}) do
  fb:reload((s[1][1] > 650) and paleV or paleT, 0.8)
  fb:stroke(s, {pressure={0.75, 0.6}, clip=ORG:shrink(2), shake=0.6})
end

--@ chunk 50
blend((ellipse(474,500,26,12) + ellipse(602,507,26,12) + ellipse(700,500,14,10)) * ORG, {angle=0.4})

--@ chunk 51
print(drying(880,880), drying(880,730))
-- the witness darker: a repoussoir, nearly black, its edges found by the two lights
local robeDark = pile{{"bone brown",1.5},{"ultramarine blue",1},{"burnt sienna",0.6},{"bone black",0.4}}
local hood = poly({{844,776},{838,732},{848,700},{870,682},{898,682},{918,700},{928,738},{932,776}}, true):roughen(1.5, 12, 3)
local face = poly({{858,742},{856,716},{864,700},{874,698},{878,716},{874,740},{866,750}}, true)
local robe = (DOC + hood) - face:grow(2)
work(robe:shrink(2), {hand="body", pile=robeDark, coverage=3.4, fill=true, clip=robe:shrink(1.5), angle=1.57})
local tb = brush{kind="round", width=2.6, point=0.4}
tb:reload(rimP, 0.9) tb:stroke({{846,804},{834,850},{828,920},{822,990}}, {pressure={0.55, 0.3}})
tb:reload(rimP, 0.9) tb:stroke({{846,730},{850,702},{870,684},{892,682}}, {pressure={0.5, 0.2}})
local lampLit = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.25}}
tb:reload(lampLit, 0.9) tb:stroke({{930,770},{926,740},{916,706}}, {pressure={0.55, 0.1}})
tb:reload(lampLit, 0.8) tb:stroke({{938,800},{944,850},{946,900}}, {pressure={0.45, 0.1}})
-- the lamp's arm, and the lamp itself crisper
local rb = brush{kind="round", width=6}
rb:reload(robeDark, 1.0) rb:stroke({{926,792},{946,786},{952,772}}, {pressure={0.9, 0.8}})
work(ellipse(954, 764, 4, 6), {hand="detail", pile=pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.5}}, coverage=3, fill=true})

--@ chunk 52
-- scale: rows of small apertures in the far bays, a few lit, never evenly spaced
local lit = pile{{"lead white",2},{"cadmium yellow",0.5},{"Indian yellow",0.3}}
local dark = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"burnt sienna",0.5}}
local b = brush{kind="round", width=2.6}
local phi = 1.618
local function rowOf(x0, x1, y, dy)
  local x = x0
  local i = 0
  while x < x1 do
    local yy = y + dy * (x - x0)
    if CRE:at(x, yy) < 0.1 and glowM:at(x, yy) < 0.1 then
      local isLit = rand(0, 1) < 0.28
      b:reload(isLit and lit or dark, 0.8)
      b:stroke({{x, yy}, {x, yy + 4}}, {pressure={0.7, 0.7}})
    end
    i = i + 1
    x = x + 5 + 3 * ((i * phi) % 1)
  end
end
for k, y in ipairs({300, 330, 362, 396, 432}) do
  rowOf(704, 768, y + k, 0.18)
  rowOf(440, 506, y + 6 + k, -0.2)
end

--@ chunk 53
local r = poly({{736,358},{770,362},{796,374},{814,398},{812,420},{790,410},{762,392},{738,380}}, true)
work(r, {hand="detail", pile=darkP, coverage=3.4, fill=true})
local tb = brush{kind="round", width=2.6, point=0.4}
tb:reload(rimHot, 0.9) tb:stroke({{742,360},{772,364},{798,376},{814,400}}, {pressure={0.55, 0.25}})

--@ chunk 54
print(CRE ~= nil, ORG ~= nil, DOC ~= nil, #LEGS, rimP ~= nil)

--@ chunk 55
-- SECOND PASS 1: the carapace as a heavy form. Light from the far door wraps its edges; rim width follows the form.
print(wait(2*24*60))
local door = {610, 420}
local rimW = pile{{"lead white",2},{"Indian yellow",0.5},{"Mars orange",0.3}}
local rimH = pile{{"zinc white",1.5},{"lead white",1.5},{"lemon chrome",0.25}}
local bounceW = pile{{"burnt sienna",1},{"Mars red",0.3},{"bone brown",0.6},{"lead white",0.15}}
local bounceC = pile{{"ultramarine blue",1},{"cobalt violet",0.5},{"bone black",0.4},{"zinc white",0.3}}
local glare = pile{{"lead white",1.6},{"yellow ochre",1},{"Indian yellow",0.3}}
local fb = brush{kind="filbert", width=6}
local rb = brush{kind="round", width=3, point=0.5}
-- facing: how much the edge at p, with outward normal n, faces the door (0..1)
local function facing(p, n)
  local dx, dy = door[1]-p[1], door[2]-p[2]; local L = math.sqrt(dx*dx+dy*dy)
  return clamp((n[1]*dx + n[2]*dy)/L, 0, 1)
end
-- the hump's top contour, front to rear, with outward normals (up / up-right)
local top = {{392,334},{440,322},{480,318},{520,318},{560,322},{600,330},{640,338},{680,346},{720,354},{750,362},{775,375},{795,394},{806,420},{804,450},{794,480}}
for i = 1, #top - 1 do
  local a, b = top[i], top[i+1]
  local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy)
  local n = {dy/L, -dx/L}
  local f = facing(a, n)
  if f > 0.05 and rand(0,1) < 0.85 then
    -- a band just inside the edge: wider and brighter where the form faces the door
    local inset = 2 + 7*f
    fb:reload(f > 0.6 and rimH or rimW, 0.5 + 0.4*f)
    fb:stroke({{a[1] - n[1]*inset, a[2] - n[2]*inset}, {b[1] - n[1]*inset*0.8, b[2] - n[2]*inset*0.8}},
      {pressure={0.25 + 0.6*f, 0.15 + 0.4*f}, ramps={0.2, 0.4}, shake=0.5})
    -- the glare eats the silhouette where it faces the light hardest
    if f > 0.55 then
      rb:reload(glare, 0.7)
      rb:stroke({{a[1] + n[1]*2, a[2] + n[2]*2}, {b[1] + n[1]*1, b[2] + n[2]*1}}, {pressure={0.6, 0.3}})
    end
  end
end
-- a turning band behind the rim: half-tone of bronze dropping into the core shadow
local half = pile{{"Mars brown",1.2},{"raw sienna",0.8},{"ultramarine blue",0.5},{"lead white",0.25}}
for i = 3, 12 do
  local a = top[i]
  fb:reload(half, 0.5)
  fb:stroke({{a[1] - 4, a[2] + 16}, {a[1] + 10, a[2] + 14}, {a[1] + 26, a[2] + 18}}, {pressure={0.4, 0.05}, ramps={0.1, 0.7}, shake=0.6})
end
-- warm bounce under the rear belly from the lit floor near the door; cool dark where it faces the void of the hall
for _, s in ipairs({{{690,586},{740,566},{780,540}}, {{640,604},{690,590}}, {{760,560},{790,520}}}) do
  fb:reload(bounceW, 0.6) fb:stroke(s, {pressure={0.45, 0.1}, ramps={0.1, 0.6}, shake=0.5})
end
for _, s in ipairs({{{230,620},{280,650},{330,660}}, {{215,560},{222,610}}}) do
  fb:reload(bounceC, 0.6) fb:stroke(s, {pressure={0.4, 0.1}, ramps={0.1, 0.6}, shake=0.5})
end
-- the old body: rim along the shoulder and helm facing the door, thicker on the convex pauldron
for _, s in ipairs({{{352,256},{372,272},{392,298}, 0.9}, {{318,200},{328,214},{332,236}, 0.6}, {{378,300},{378,340},{372,370}, 0.4}}) do
  rb:reload(rimH, 0.8)
  rb:stroke({s[1], s[2], s[3]}, {pressure={0.3 + 0.5*s[4], 0.1}, swell={0.6, 1.2, 0.5}, ramps={0.1, 0.5}})
end
-- hard glints on the helm crown and pauldron: the brightest metal in the picture
local gb = brush{kind="round", width=2.2}
for _, g in ipairs({{{312,198},{320,202}}, {{380,280},{386,288}}, {{520,320},{534,320}}, {{640,339},{652,341}}}) do
  gb:reload(rimH, 0.9) gb:stroke(g, {pressure={0.7, 0.3}})
end

--@ chunk 56
-- SECOND PASS 2: legs as heavy cylinders. Rim on the door side, varying with the turn; bounce on the far side; knees catch most.
local door = {610, 420}
local rimW = pile{{"lead white",2},{"Indian yellow",0.5},{"Mars orange",0.3}}
local rimH = pile{{"zinc white",1.5},{"lead white",1.5},{"lemon chrome",0.25}}
local bounceW = pile{{"burnt sienna",1},{"Mars red",0.3},{"bone brown",0.6},{"lead white",0.15}}
local bounceC = pile{{"ultramarine blue",1},{"cobalt violet",0.6},{"zinc white",0.5}}
local half = pile{{"Mars brown",1.2},{"raw sienna",0.8},{"ultramarine blue",0.5},{"lead white",0.25}}
local rb = brush{kind="round", width=3, point=0.5}
local fb = brush{kind="filbert", width=5}
local function seg(a, b, w)
  local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy)
  local n = {-dy/L, dx/L}
  local m = {(a[1]+b[1])/2, (a[2]+b[2])/2}
  local tx, ty = door[1]-m[1], door[2]-m[2]; local T = math.sqrt(tx*tx+ty*ty)
  local f = (n[1]*tx + n[2]*ty)/T
  if f < 0 then n = {-n[1], -n[2]}; f = -f end
  local o = w*0.5 - 2
  local t0, t1 = rand(0.05, 0.2), rand(0.75, 0.95)
  local p0 = {a[1] + dx*t0 + n[1]*o, a[2] + dy*t0 + n[2]*o}
  local p1 = {a[1] + dx*t1 + n[1]*o, a[2] + dy*t1 + n[2]*o}
  -- rim, wider where the cylinder's side squarely faces the door
  rb:reload(f > 0.7 and rimH or rimW, 0.85)
  rb:stroke({p0, p1}, {pressure={0.25 + 0.6*f, 0.2 + 0.4*f}, swell={0.7, 1.1, 0.8}, ramps={0.15, 0.3}, shake=0.4})
  -- half-tone turning in from the rim
  local h0 = {p0[1] - n[1]*5, p0[2] - n[2]*5}; local h1 = {p1[1] - n[1]*5, p1[2] - n[2]*5}
  fb:reload(half, 0.4) fb:stroke({h0, h1}, {pressure={0.3*f + 0.1, 0.05}, ramps={0.1, 0.6}})
  -- bounce on the far side: cold near the graft, warm elsewhere, always darker than the rim
  local q0 = {a[1] + dx*0.3 - n[1]*o, a[2] + dy*0.3 - n[2]*o}; local q1 = {a[1] + dx*0.8 - n[1]*o, a[2] + dy*0.8 - n[2]*o}
  local cold = m[1] > 420 and m[1] < 720 and m[2] < 760
  fb:reload(cold and bounceC or bounceW, 0.5)
  fb:stroke({q0, q1}, {pressure={0.3, 0.1}, ramps={0.2, 0.5}})
end
for _, L in ipairs(LEGS) do
  seg(L[1], L[2], L[4][1])
  seg(L[2], L[3], L[4][2])
  -- the knee: a convex ball, the brightest arc on the leg
  local k, r = L[2], L[4][2]*0.75
  local a = math.atan(door[2]-k[2], door[1]-k[1])
  local arc = {}
  for j = -2, 2 do arc[#arc+1] = {k[1] + math.cos(a + j*0.35)*(r - 1.5), k[2] + math.sin(a + j*0.35)*(r - 1.5)} end
  rb:reload(rimH, 0.9) rb:stroke(arc, {pressure={0.35, 0.35}, swell={0.4, 1.3, 0.4}})
end

--@ chunk 57
-- SECOND PASS 1b: the rim again, the light taken from the glare above and behind the hump
local door = {610, 210}
local rimW = pile{{"lead white",2},{"Indian yellow",0.5},{"Mars orange",0.3}}
local rimH = pile{{"zinc white",1.5},{"lead white",1.5},{"lemon chrome",0.25}}
local bounceW = pile{{"burnt sienna",1},{"Mars red",0.3},{"bone brown",0.6},{"lead white",0.15}}
local bounceC = pile{{"ultramarine blue",1},{"cobalt violet",0.5},{"bone black",0.4},{"zinc white",0.3}}
local glare = pile{{"lead white",1.6},{"yellow ochre",1},{"Indian yellow",0.3}}
local fb = brush{kind="filbert", width=6}
local rb = brush{kind="round", width=3, point=0.5}
-- facing: how much the edge at p, with outward normal n, faces the door (0..1)
local function facing(p, n)
  local dx, dy = door[1]-p[1], door[2]-p[2]; local L = math.sqrt(dx*dx+dy*dy)
  return clamp((n[1]*dx + n[2]*dy)/L, 0, 1)
end
-- the hump's top contour, front to rear, with outward normals (up / up-right)
local top = {{392,334},{440,322},{480,318},{520,318},{560,322},{600,330},{640,338},{680,346},{720,354},{750,362},{775,375},{795,394},{806,420},{804,450},{794,480}}
for i = 1, #top - 1 do
  local a, b = top[i], top[i+1]
  local dx, dy = b[1]-a[1], b[2]-a[2]; local L = math.sqrt(dx*dx+dy*dy)
  local n = {dy/L, -dx/L}
  local f = facing(a, n)
  if f > 0.05 and rand(0,1) < 0.85 then
    -- a band just inside the edge: wider and brighter where the form faces the door
    local inset = 2 + 7*f
    fb:reload(f > 0.6 and rimH or rimW, 0.5 + 0.4*f)
    fb:stroke({{a[1] - n[1]*inset, a[2] - n[2]*inset}, {b[1] - n[1]*inset*0.8, b[2] - n[2]*inset*0.8}},
      {pressure={0.25 + 0.6*f, 0.15 + 0.4*f}, ramps={0.2, 0.4}, shake=0.5})
    -- the glare eats the silhouette where it faces the light hardest
    if f > 0.55 then
      rb:reload(glare, 0.7)
      rb:stroke({{a[1] + n[1]*2, a[2] + n[2]*2}, {b[1] + n[1]*1, b[2] + n[2]*1}}, {pressure={0.6, 0.3}})
    end
  end
end

--@ chunk 58
blend(ribbon({{392,338},{480,324},{560,328},{640,344},{720,360},{775,380},{800,410}}, 16), {angle=0.15})

--@ chunk 59
-- SECOND PASS 3: the graft, wet, deep and varied: laid fresh in several colours that pull into each other
local eyes = ellipse(540,562,16,9) + ellipse(652,548,14,8) + ellipse(606,604,12,7) + ellipse(478,572,10,6)
local lower = (ORG:shrink(3) * below({{400,520},{500,532},{600,530},{700,515},{780,505}})) - eyes:grow(2)
local nz = noise{seed=71, period=46, octaves=3, warp={40, 22}}
local rg = noise{seed=72, period=34, octaves=3, kind="ridged"}
local deepBlue = pile{{"ultramarine blue",1},{"bone black",0.8},{"viridian",0.2}}
local deepWine = pile{{"magenta",0.6},{"rose madder",0.6},{"ultramarine blue",0.6},{"bone black",0.6}}
local midViolet = pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"magenta",0.3},{"zinc white",0.3}}
local coldCyan = pile{{"cerulean blue",1},{"emerald green",0.4},{"zinc white",0.8}}
local ang = function(x, y) return nz(x*1.3, y*1.3) * 3.4 end
local A = lower * mask(function(x, y) return nz(x, y) < -0.15 and 1 or 0 end)
local B = lower * mask(function(x, y) local v = nz(x, y) return (v >= -0.15 and v < 0.25) and 1 or 0 end)
local C = lower * mask(function(x, y) return nz(x, y) >= 0.25 and 1 or 0 end)
work(A, {hand="body", pile=deepBlue, coverage=3, fill=true, clip=lower, angle=ang, length={8, 26}, curve={0.7, 0.4}})
work(B, {hand="body", pile=deepWine, coverage=3, fill=true, clip=lower, angle=ang, length={8, 26}, curve={0.7, 0.4}})
work(C, {hand="body", pile=midViolet, coverage=2.6, fill=true, clip=lower, angle=ang, length={8, 26}, curve={0.7, 0.4}})
-- cold light along the ridges of the lumps, dragged into the wet so it melts at one side
local R = lower:shrink(4) * mask(function(x, y) return rg(x, y) > 0.55 and 1 or 0 end)
work(R, {hand="detail", pile=coldCyan, coverage=1.2, clip=lower, angle=ang, length={6, 16}, pressure={0.4, 0.7}})
-- the pale cells above: depth at their bottoms, a cold sheen high in them
local upper = ORG:shrink(3) - lower:grow(1) - eyes:grow(2)
local fb = brush{kind="filbert", width=6}
for _, c in ipairs({{470,528},{530,532},{596,528},{660,518},{716,510}}) do
  fb:reload(midViolet, 0.6)
  fb:stroke({{c[1] - 12, c[2]}, {c[1], c[2] - 6}, {c[1] + 12, c[2]}}, {pressure={0.5, 0.2}, clip=upper, shake=0.8})
end

--@ chunk 60
local eyes = ellipse(540,562,16,9) + ellipse(652,548,14,8) + ellipse(606,604,12,7) + ellipse(478,572,10,6)
local lower = (ORG:shrink(4) * below({{400,520},{500,532},{600,530},{700,515},{780,505}})) - eyes:grow(4)
blend(lower, {coverage=0.7, angle=function(x, y) return math.sin(x/37) * 1.5 + math.cos(y/29) end})
print(wait(8*60))
print(drying(560,330), drying(600,600))
-- the rim was blended into a pale hose: take it back to a thin, varying edge
local inner = ribbon({{396,346},{480,334},{560,338},{640,354},{720,370},{772,390},{792,416}}, {12, 13, 11, 12, 10, 9, 8})
work(inner, {hand="body", pile=darkP, coverage=3.4, fill=true, clip=inner, angle=0.15, length={14, 40}})

--@ chunk 61
-- break the pale tube: dark notches where plates step back, the edge thinned where the form turns away
local top = {{396,334},{440,324},{480,320},{520,320},{560,324},{600,332},{640,340},{680,348},{720,356},{750,364},{775,377},{795,396},{806,420}}
local fb = brush{kind="filbert", width=7}
for i = 1, #top - 1 do
  local a, b = top[i], top[i+1]
  -- how much of this piece of rim stays: thin at the front and the turning rear, full where it lies against the glare
  local keepFrac = (i <= 2 or i >= 11) and 0.25 or rand(0.45, 0.85)
  local t0 = keepFrac
  fb:reload(darkP, 1.0)
  fb:stroke({{lerp(a[1], b[1], t0), lerp(a[2], b[2], t0) + 6}, {b[1], b[2] + 6}}, {pressure={0.9, 0.9}, ramps={0, 0}})
  -- a notch reaching up through the rim at plate joints
  if rand(0,1) < 0.5 then
    local nb = brush{kind="filbert", width=4}
    nb:reload(darkP, 1.0) nb:stroke({{a[1] + 3, a[2] + 8}, {a[1] + 5, a[2] - 1}}, {pressure={0.9, 0.6}})
  end
end
-- the front and rear ends: the rim narrows to a hair
local tb = brush{kind="filbert", width=6}
tb:reload(darkP, 1.0) tb:stroke({{396,342},{440,331},{470,326}}, {pressure={0.9, 0.9}})
tb:reload(darkP, 1.0) tb:stroke({{772,386},{792,402},{802,428}}, {pressure={0.9, 0.9}})

--@ chunk 62
-- SECOND PASS 4: wet lights and the darkest darks in the graft, catchlights in the eyes
print(wait(5*60))
print(drying(560,590), drying(620,570))
local eyes = ellipse(540,562,16,9) + ellipse(652,548,14,8) + ellipse(606,604,12,7) + ellipse(478,572,10,6)
local lower = (ORG:shrink(5) * below({{400,520},{500,532},{600,530},{700,515},{780,505}})) - eyes:grow(3)
local blackest = pile{{"bone black",1.2},{"ultramarine blue",0.5},{"rose madder",0.2}}
local wetW = pile{{"zinc white",3},{"cerulean blue",0.15}}
local fb = brush{kind="filbert", width=5}
local gb = brush{kind="round", width=2.4, point=0.4}
-- deepest folds, under the eyes and between lumps
for _, f in ipairs({{{528,574},{544,578},{558,574}}, {{640,560},{654,563},{668,559}}, {{596,614},{610,617}}, {{470,582},{486,584}}, {{560,600},{576,612},{586,628}}, {{700,532},{724,528}}, {{500,598},{514,614}}}) do
  fb:reload(blackest, 0.9) fb:stroke(f, {pressure={0.6, 0.3}, clip=lower})
end
-- wet glints: few, small, hard, each beside a dark
local n = 0
for i = 1, 60 do
  local x, y = rand(440, 760), rand(520, 640)
  if lower:at(x, y) > 0.9 and n < 16 then
    n = n + 1
    local a = rand(-0.6, 0.6)
    gb:reload(wetW, 0.8)
    gb:stroke({{x, y}, {x + math.cos(a)*rand(3, 8), y + math.sin(a)*rand(1, 3)}}, {pressure={0.6, 0.1}})
  end
end
print("glints", n)
-- catchlights: every eye the same cold window
local cb = brush{kind="round", width=2}
for _, e in ipairs({{536,559},{649,545},{603,602},{476,570}}) do
  cb:reload(wetW, 0.9) cb:touch(e[1], e[2], {pressure=0.6})
end

--@ chunk 63
-- SECOND PASS 5: a real reflection on the polished floor: the door's light laid fresh, the legs and the graft mirrored into it
print(wait(24*60))
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local S = poly({{526,600},{688,600},{700,700},{712,860},{498,860},{512,700}}):roughen(5, 26, 90) * fl
local sTop = pile{{"lead white",1.6},{"yellow ochre",1},{"Indian yellow",0.3},{"raw sienna",0.2}}
local sMid = pile{{"yellow ochre",1},{"raw sienna",1},{"lead white",0.6},{"burnt sienna",0.3}}
local sLow = pile{{"raw sienna",0.8},{"burnt sienna",0.6},{"bone brown",0.8},{"ultramarine blue",0.3}}
work(S * above(function(x) return 670 end), {hand="body", pile=sTop, angle=math.pi/2, coverage=3, fill=true, clip=S})
work(S * below(function(x) return 670 end) * above(function(x) return 770 end), {hand="body", pile=sMid, angle=math.pi/2, coverage=3, fill=true, clip=S})
work(S * below(function(x) return 770 end), {hand="body", pile=sLow, angle=math.pi/2, coverage=3, fill=true, clip=S})
-- the graft's cold violet, mirrored, dim
local vio = pile{{"cobalt violet",1},{"ultramarine blue",0.8},{"bone brown",0.4}}
local fb = brush{kind="filbert", width=9}
for i = 1, 10 do
  local x = rand(520, 690)
  fb:reload(vio, 0.5)
  fb:stroke({{x, 690 + rand(0, 20)}, {x + rand(-3, 3), 740 + rand(0, 30)}}, {pressure={0.4, 0.1}, clip=S, shake=1})
end
-- each lower leg mirrored below its foot, softer and shorter, darker than the leg's surroundings
local refl = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"Mars brown",0.6}}
local rb = brush{kind="filbert", width=10}
for _, L in ipairs(LEGS) do
  local K, F, w = L[2], L[3], L[4][2]
  local depth = (F[2] - K[2]) * 0.7
  rb = brush{kind="filbert", width=math.max(6, w*0.8)}
  rb:reload(refl, 0.8)
  rb:stroke({{F[1], F[2] + 6}, {F[1] + (K[1]-F[1])*0.35, F[2] + depth*0.5}, {F[1] + (K[1]-F[1])*0.7, F[2] + depth}},
    {pressure={0.8, 0.05}, ramps={0.05, 0.8}, clip=fl, shake=1.2})
end
-- soften the whole reflection while it's wet: straight down, as a mirror blurs
blend(S:shrink(3), {angle=math.pi/2})

--@ chunk 64
-- the reflection is darker than what it reflects and dies toward us; soft at its sides
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local S = poly({{520,600},{694,600},{706,700},{718,870},{492,870},{506,700}}):grow(4) * fl
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local midDark = pile{{"bone brown",1.6},{"ultramarine blue",0.9},{"raw sienna",0.5},{"lead white",0.1}}
work(S * below(function(x) return 660 end), {hand="body", pile=nearDark, angle=math.pi/2, coverage=2.6, pressure={0.4, 0.8}, clip=S,
  load_at=function(x, y) return clamp((y - 650) / 200, 0.08, 0.95) end})
local fb = brush{kind="filbert", width=9}
for _, side in ipairs({{506, 1}, {704, -1}}) do
  local y = 610
  while y < 860 do
    local x = side[1] + side[2] * rand(-4, 14) + (y - 610) * 0.05 * (side[2] == 1 and -1 or 1)
    fb:reload(midDark, rand(0.5, 0.9))
    fb:stroke({{x, y}, {x + rand(-2, 2), y + rand(30, 70)}}, {pressure={0.8, 0.2}, clip=fl})
    y = y + rand(18, 34)
  end
end
-- legs mirrored into the wet light
local refl = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"Mars brown",0.6}}
for _, L in ipairs(LEGS) do
  local K, F, w = L[2], L[3], L[4][2]
  local depth = (F[2] - K[2]) * 0.7
  local rb = brush{kind="filbert", width=math.max(6, w*0.8)}
  rb:reload(refl, 0.9)
  rb:stroke({{F[1], F[2] + 6}, {F[1] + (K[1]-F[1])*0.35, F[2] + depth*0.5}, {F[1] + (K[1]-F[1])*0.7, F[2] + depth}},
    {pressure={0.85, 0.05}, ramps={0.05, 0.8}, clip=fl, shake=1.2})
end
-- the belly's dark mirrored across the top of the streak
fb:reload(refl, 0.7) fb:stroke({{520,640},{600,646},{690,638}}, {pressure={0.5, 0.2}, clip=S})

--@ chunk 65
print(wait(2*24*60))
print(drying(600,800))
local fl = floorM - CRE:grow(1) - DOC:grow(1)
local S = poly({{520,600},{694,600},{706,700},{718,875},{492,875},{506,700}}):grow(6) * fl
local nearDark = pile{{"bone brown",2},{"ultramarine blue",1},{"burnt sienna",0.5}}
local midDark = pile{{"bone brown",1.6},{"ultramarine blue",0.9},{"raw sienna",0.5},{"lead white",0.1}}
local lowZ = S * below({{480,770},{560,790},{640,775},{730,792}})
work(lowZ, {hand="body", pile=nearDark, angle=math.pi/2, coverage=3.4, fill=true, clip=S})
local midZ = S * below({{480,700},{560,712},{640,698},{730,708}}) - lowZ
work(midZ, {hand="body", pile=midDark, angle=math.pi/2, coverage=1.4, pressure={0.4, 0.8}, clip=S, length={20, 60}})
-- the legs mirrored, long and soft
local refl = pile{{"bone brown",1.5},{"ultramarine blue",0.8},{"Mars brown",0.6}}
for _, L in ipairs(LEGS) do
  local K, F, w = L[2], L[3], L[4][2]
  if S:at(F[1], F[2] + 20) > 0.5 or S:at(F[1], F[2] + 40) > 0.5 then
    local rb = brush{kind="filbert", width=math.max(8, w)}
    rb:reload(refl, 1.0)
    rb:stroke({{F[1], F[2] + 4}, {F[1] + (K[1]-F[1])*0.4, F[2] + (F[2]-K[2])*0.45}, {F[1] + (K[1]-F[1])*0.8, F[2] + (F[2]-K[2])*0.85}},
      {pressure={0.9, 0.15}, ramps={0.02, 0.7}, clip=fl, shake=1})
  end
end

--@ chunk 66
-- SECOND PASS 6: the docent's lamp gives a small pool of light, which tells us how small the docent is
local L = {954, 764}
local warmHi = pile{{"lead white",1.2},{"yellow ochre",1},{"Mars orange",0.3}}
local warmLo = pile{{"raw sienna",1},{"burnt sienna",0.6},{"yellow ochre",0.4},{"lead white",0.25}}
local keep = -(DOC:grow(1) + ellipse(954,764,6,8))
-- glow on the wall and floor right around the lamp, falling off quickly
stipple(ellipse(L[1], L[2], 46, 40) * keep, {pile=warmLo, width=3.2, feather=1, clip=keep,
  coverage=function(x, y) local d = math.sqrt((x-L[1])^2 + (y-L[2])^2) return clamp(1.8*(1 - d/46), 0, 1.8) end})
stipple(ellipse(L[1], L[2], 22, 20) * keep, {pile=warmHi, width=2.6, feather=1, clip=keep,
  coverage=function(x, y) local d = math.sqrt((x-L[1])^2 + (y-L[2])^2) return clamp(1.6*(1 - d/22), 0, 1.6) end})
-- the pool on the floor at its feet: an ellipse in perspective, mostly hidden by the robe
local P = {925, 992}
stipple(ellipse(P[1], P[2], 85, 16) * keep * floorM, {pile=warmLo, width=3.4, feather=1, clip=keep,
  coverage=function(x, y) local d = math.sqrt(((x-P[1])/85)^2 + ((y-P[2])/16)^2) return clamp(1.8*(1 - d), 0, 1.8) end})
-- lamp-lit hem and the lamp's own hot core
local rb = brush{kind="round", width=2.6, point=0.4}
rb:reload(warmHi, 0.9) rb:stroke({{948,960},{958,996}}, {pressure={0.5, 0.2}})
rb:reload(warmHi, 0.9) rb:stroke({{816,985},{822,998}}, {pressure={0.35, 0.1}})
work(ellipse(954, 764, 3, 4.5), {hand="detail", pile=pile{{"zinc white",2},{"lemon chrome",0.4}}, coverage=3, fill=true})

--@ chunk 67
local core = ellipse(954, 764, 5, 7)
blend(ellipse(954, 764, 46, 40) - DOC:grow(1) - core, {angle=0.5})
-- the pool at its feet, laid in flat strokes that follow the floor, then fused
local warmHi = pile{{"lead white",1},{"yellow ochre",1},{"Mars orange",0.3},{"raw sienna",0.3}}
local warmLo = pile{{"raw sienna",1},{"burnt sienna",0.7},{"bone brown",0.5},{"lead white",0.15}}
local pool = ellipse(930, 990, 95, 20) * floorM - DOC:grow(1)
local inner = ellipse(950, 988, 50, 11) * floorM - DOC:grow(1)
work(pool - inner, {hand="body", pile=warmLo, angle=0.05, coverage=2.4, fill=true, clip=pool, length={14, 40}})
work(inner, {hand="body", pile=warmHi, angle=0.05, coverage=2.6, fill=true, clip=inner:grow(3), length={10, 30}})
blend(ellipse(930, 990, 105, 26) * floorM - DOC:grow(1), {angle=0.05})

--@ chunk 68
-- the hump turns: a warm half-tone under the rim falling into the core shadow, the graft's cold light coming up from below
local half = pile{{"Mars brown",1.2},{"raw sienna",0.8},{"ultramarine blue",0.5},{"lead white",0.3}}
local coldUp = pile{{"cobalt violet",1},{"ultramarine blue",0.8},{"bone black",0.5},{"zinc white",0.25}}
local fb = brush{kind="filbert", width=8}
local top = {{420,330},{480,326},{540,328},{600,338},{660,350},{720,362},{770,382}}
for i = 1, #top - 1 do
  local a, b = top[i], top[i+1]
  for k = 1, 2 do
    local d = 10 + k*8
    fb:reload(half, 0.45 - k*0.12)
    fb:stroke({{a[1] + rand(-4,4), a[2] + d}, {b[1] + rand(-4,4), b[2] + d}}, {pressure={0.35, 0.15}, ramps={0.3, 0.4}, shake=0.6})
  end
end
for _, s in ipairs({{{450,468},{520,456},{580,452}}, {{600,452},{660,446},{720,446}}, {{730,452},{770,470}}, {{410,500},{440,476}}}) do
  fb:reload(coldUp, 0.5)
  fb:stroke(s, {pressure={0.35, 0.1}, ramps={0.2, 0.5}, shake=0.6})
end
