-- easel session "ark_open": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,13}, seed=4472,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"burnt sienna",2},{"raw sienna",1},{"ultramarine blue",1.2},{"lead white",0.6}, medium=0.4}, um=22, apply="brush"},
  }}

--@ chunk 2
-- masses: the bronze vault and walls in near-black, the rubble floor, the open Ark, the kneeling frame
O = {455, 1000}                                       -- the box's opening, where the light comes from
FLOOR = below({{0,1060},{300,1040},{600,1035},{1000,1060}})
ARKB = poly({{330,1004},{350,996},{560,990},{580,998},{584,1072},{560,1084},{350,1088},{328,1078}}, true)
ARKTOP = poly({{344,994},{362,986},{556,982},{572,990},{560,1004},{350,1008}}, true)
LID = poly({{352,990},{340,900},{352,884},{560,878},{572,890},{566,986}}, true)
FIG = poly({{690,776},{712,768},{730,780},{734,806},{722,826},{700,830},{684,812}}, true)       -- helm, tilted back
  + poly({{650,840},{700,826},{760,834},{790,860},{780,900},{700,900},{646,880}}, true)         -- pauldrons
  + poly({{676,880},{770,880},{782,960},{770,1030},{690,1030},{670,960}}, true)                -- torso/waist
  + poly({{680,1020},{790,1020},{830,1060},{860,1120},{850,1180},{760,1190},{700,1140},{670,1080}}, true)   -- kneeling legs
  + poly({{700,1150},{780,1160},{790,1333},{700,1333}}, true)                                   -- near shin to the bottom edge
  + ribbon({{656,870},{616,930},{588,980}}, {26, 22, 18}) + poly({{570,972},{596,966},{604,992},{580,1002}}, true)   -- arm reaching to the box's rim
VAULT = everywhere() - FLOOR
local ang = function(x, y) return math.atan(y - 1300, x - 455) + math.pi/2 end
work(VAULT, {hand="broad", pile=pile{{"bone black",2},{"burnt sienna",1.2},{"raw sienna",0.3}}, coverage=3, fill=true, angle=ang})
work(FLOOR, {hand="broad", pile=pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.5}}, coverage=3, fill=true, angle=0.1, clip=FLOOR:grow(2)})

--@ chunk 3
print(wait(2*24*60))
-- the vault overhead: dim scale-plate rows arcing across, catching the gold from below on their lower lips
local plD = pile{{"burnt sienna",1.2},{"bone black",1},{"raw sienna",0.5}}
local plL = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.5}}
local B = {}
local function bb(w) w = math.max(2, math.floor(w + 0.5)); if not B[w] then B[w] = brush("filbert", w) end; return B[w] end
local sh = brush{kind="round", width=2, point=0.5}
local n = 0
for row = 1, 11 do
  local R = 520 + row * 70
  local s = 10 + row * 2.2
  for k = 0, 60 do
    local a = -math.pi + 0.25 + k * (math.pi - 0.5) / 60 + (row % 2) * 0.012
    local x, y = 455 + math.cos(a) * R * 1.05, 1300 + math.sin(a) * R
    if y < 960 and x > -10 and x < 1010 and y > -10 then
      local near = clamp(1 - math.sqrt((x - 455)^2 + (y - 700)^2) / 650, 0, 1)
      local br = bb(s)
      if n % 3 == 0 then br:reload((near > 0.45) and plL or plD, 0.5); sh:reload(pile{{"bone black",3},{"ultramarine blue",0.3}}, 0.5) end
      n = n + 1
      local tx, ty = -math.sin(a), math.cos(a)
      local nx, ny = math.cos(a), math.sin(a)
      br:stroke({{x - tx * s * 0.6, y - ty * s * 0.6}, {x + nx * 2, y + ny * 2}, {x + tx * s * 0.6, y + ty * s * 0.6}}, {pressure={0.55, 0.4}, ramps={0.15, 0.4}})
      sh:stroke({{x - tx * s * 0.6 - nx * s * 0.45, y - ty * s * 0.6 - ny * s * 0.45}, {x - nx * s * 0.55, y - ny * s * 0.55}, {x + tx * s * 0.6 - nx * s * 0.45, y + ty * s * 0.6 - ny * s * 0.45}}, {pressure={0.4, 0.1}, ramps={0.2, 0.4}})
    end
  end
end
print(n)

--@ chunk 4
-- the Ark and the frame laid in: pale frosted box, its lit lid, the inside a well of light; the frame near-black
local arkP = pile{{"lead white",2.5},{"ultramarine ash",0.4},{"bone black",0.2}}
local arkS = pile{{"lead white",1},{"bone black",0.6},{"ultramarine ash",0.6}}
work(ARKB, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=arkS, coverage=3.4, fill=true, angle=0, clip=true})
work(LID, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"lead white",2},{"yellow ochre",0.6},{"cadmium yellow",0.3}}, coverage=3.4, fill=true, angle=math.pi/2, clip=true})
work(ARKTOP, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"zinc white",3},{"cadmium yellow",0.5},{"lead white",1}}, coverage=3.4, fill=true, angle=0, clip=true})
local band = poly({{420,1000},{442,998},{442,1084},{420,1086}})
work(band, {hand="detail", pile=pile{{"vermilion",1},{"lead white",0.4},{"bone black",0.2}}, coverage=2.6, fill=true, angle=math.pi/2, clip=true})
work(FIG, {hand="body", tool="filbert 5", pile=pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 5
print(wait(3*24*60))
-- vault back to near-black (the plates were too loud); the lid made a thin slab leaning back; the helm given its form, tilted up
local blk = pile{{"bone black",3},{"burnt sienna",0.8},{"ultramarine blue",0.2}}
local V = VAULT - FIG:grow(2) - ARKB:grow(1) - ARKTOP:grow(1)
local ang = function(x, y) return math.atan(y - 1300, x - 455) + math.pi/2 end
work(V, {hand="body", tool="filbert 9", pile=blk, coverage=3.6, fill=true, angle=ang, clip=V, length={80, 200}, load=0.95})

--@ chunk 6
print(wait(3*24*60))
LID2 = poly({{356,986},{366,950},{554,946},{566,982}})
work(LID2, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=pile{{"lead white",2.5},{"ultramarine ash",0.4},{"bone black",0.15}}, coverage=3.4, fill=true, angle=0, clip=true})
local e = brush{kind="round", width=1.6, point=0.7}
e:load(pile{{"zinc white",3},{"cadmium yellow",0.4}}, 0.6); e:stroke({{358,984},{564,980}}, {pressure={0.6, 0.6}})
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
HELM = poly({{676,800},{684,772},{700,756},{722,752},{738,762},{740,782},{730,804},{708,818},{688,818}}, true)
MANT = poly({{640,860},{660,834},{690,822},{740,820},{786,840},{800,880},{790,910},{650,900}}, true)
work(HELM + MANT, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true})
FIG = FIG + HELM + MANT

--@ chunk 7
print(wait(3*24*60))
-- the warning as light: a slow fountain of thin gold lines rising out of the box and fanning across the vault
local hot = pile{{"zinc white",2},{"lead white",2},{"cadmium yellow",0.5}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local deep = pile{{"Indian yellow",1},{"Mars orange",0.5},{"lead white",0.8}}
local t2 = brush{kind="round", width=2.0, point=0.6}
local t1 = brush{kind="round", width=1.3, point=0.8}
local clipm = -(FIG:grow(1)) - ARKB
FOUNT = {}
for i = 1, 200 do
  local x0 = rand(372, 548); local y0 = 982
  local spread = (x0 - 460) / 90 + randn(0, 0.5)
  local H = rand(380, 960)
  local pts = {}
  for k = 0, 10 do
    local t = k / 10
    local x = x0 + spread * 260 * t^1.6 + 18 * math.sin(t * 5 + i)
    local y = y0 - H * (1 - (1 - t)^1.6)
    pts[#pts+1] = {x, y}
  end
  FOUNT[i] = pts
  local br = (math.random() < 0.4) and t2 or t1
  -- three segments with fresh paint, hotter at the root
  for seg = 1, 3 do
    local a, b = (seg - 1) * 3 + 1, math.min(11, seg * 3 + 2)
    local q = {}; for k = a, b do q[#q+1] = pts[k] end
    br:reload((seg == 1) and hot or ((seg == 2) and gold or deep), 0.6)
    br:stroke(q, {pressure={0.55 - 0.12 * seg, 0.45 - 0.12 * seg}, ramps={0.1, 0.2}, clip=clipm})
  end
end

--@ chunk 8
print(wait(2*24*60))
-- glyphs of fold notation carried up the fountain: each a small polygon holding a smaller turned copy; larger and sparser as they rise and spread
function glyph(cx, cy, r, sides, rot, p, w)
  local b = brush{kind="round", width=w, point=0.7}
  local function ring(rr, a0)
    local pts = {}
    for k = 0, sides do local a = a0 + k * 2 * math.pi / sides; pts[#pts+1] = {cx + math.cos(a) * rr, cy + math.sin(a) * rr} end
    return pts
  end
  b:load(p, 0.6); b:stroke(ring(r, rot), {pressure={0.5, 0.5}, ramps={0.02, 0.02}})
  b:load(p, 0.6); b:stroke(ring(r * 0.55, rot + math.pi / sides * 0.8), {pressure={0.45, 0.45}, ramps={0.02, 0.02}})
  if r > 9 then b:load(p, 0.5); b:stroke(ring(r * 0.28, rot + 0.4), {pressure={0.4, 0.4}, ramps={0.02, 0.02}}) end
end
local gold = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local hot = pile{{"zinc white",2},{"lead white",2},{"cadmium yellow",0.5}}
local n = 0
for i = 1, 200, 2 do
  local pts = FOUNT[i]
  for _, k in ipairs({4, 7, 10}) do
    if math.random() < 0.55 then
      local p = pts[k]
      if FIG:grow(4):at(p[1], p[2]) < 0.5 then
        local r = lerp(3, 11, (k - 4) / 6) * rand(0.8, 1.3)
        glyph(p[1], p[2], r, math.random(3, 7), rand(0, 6.28), (k == 4) and hot or gold, (r > 8) and 1.4 or 1.0)
        n = n + 1
      end
    end
  end
end
-- higher still, a few drifting free across the vault
for i = 1, 26 do
  local x, y = rand(60, 940), rand(30, 330)
  if FIG:grow(4):at(x, y) < 0.5 then glyph(x, y, rand(9, 18), math.random(4, 7), rand(0, 6.28), gold, 1.5); n = n + 1 end
end
print(n)

--@ chunk 9
-- the light lands: a warm pool on the floor around the box, the frame's rim, the visor full of gold
local pool = ellipse(460, 1090, 260, 50) * FLOOR - ARKB:grow(1) - FIG:grow(2)
work(pool, {hand="body", pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.6},{"burnt sienna",0.3}}, coverage=2, fill=true, angle=0, clip=pool:soften(14),
  load_at=function(x, y) return 0.6 * (1 - smoothstep(0.3, 1.0, math.sqrt(((x - 460) / 260)^2 + ((y - 1090) / 50)^2))) end})
local gold = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local nz = noise{seed=31, period=7}
local edge = mask(function(x, y)
  if x < 560 or x > 880 or y < 740 or y > 1200 then return 0 end
  if FIG:at(x, y) < 0.5 then return 0 end
  if FIG:at(x - 1.6, y - 1.2) > 0.5 then return 0 end
  return nz:at01(x, y) > 0.3 and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=1.4, point=0.8}, pile=gold, coverage=2, fill=true, clip=true, angle=0.8})
-- visor: a band on the helm's upturned face, full of the gold reflection, with a few glyph sparks in it
local vis = poly({{684,786},{694,768},{712,760},{724,766},{716,786},{698,798}}, true)
work(vis, {hand="detail", tool={kind="round", width=1.6, point=0.6}, pile=pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.4}}, coverage=2.6, fill=true, angle=-0.5, clip=true})
local s = brush{kind="round", width=1.4, point=0.8}
s:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.6)
s:stroke({{690,782},{708,768}}, {pressure={0.5, 0.2}})
-- the box's inside: a seething white
local inside = poly({{360,988},{556,984},{548,996},{366,1000}}, true)
work(inside, {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=2.6, fill=true, angle=0, clip=true})

--@ chunk 10
print(wait(2*24*60))
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
-- the forward leg: thigh out toward the box, knee raised, shin down to the floor
LEG = poly({{700,1020},{730,1034},{722,1060},{676,1066},{640,1062},{628,1046},{642,1026}}, true)
  + poly({{628,1046},{652,1046},{660,1100},{666,1112},{630,1116},{622,1104}}, true)
  + poly({{612,1104},{668,1104},{674,1120},{608,1122}}, true)
work(LEG, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true})
FIG = FIG + LEG
-- visor narrowed to a gold slit along the upturned face
local cut = poly({{702,758},{728,762},{726,792},{708,786},{700,772}}, true)
work(cut, {hand="detail", tool={kind="round", width=2, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=0, clip=true})

--@ chunk 11
print(wait(3*24*60))
local gold = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local r = brush{kind="round", width=1.4, point=0.8}
for _, s in ipairs({ {{642,1026},{676,1022},{700,1020}}, {{628,1046},{624,1070},{622,1104}}, {{610,1104},{640,1102}}, {{690,770},{700,758},{712,752},{726,756}},
                     {{662,836},{690,822},{720,820}}, {{646,862},{660,840}} }) do
  r:load(gold, 0.6); r:stroke(s, {pressure={0.55, 0.35}})
end
-- seams on the plates of the frame, faintly lit from the left
local sm = brush{kind="round", width=1.0, point=0.9}
for _, s in ipairs({ {{680,900},{768,900}}, {{676,950},{774,950}}, {{684,1000},{770,1000}}, {{760,1060},{820,1090}}, {{648,1060},{648,1070}} }) do
  sm:load(pile{{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.6}}, 0.5); sm:stroke(s, {pressure={0.3, 0.3}})
end
-- a few glyphs drifting past the frame's helm, reflected in the visor slit
local gl = brush{kind="round", width=1.0, point=0.9}
gl:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.6)
gl:stroke({{688,786},{694,780},{700,784},{694,790},{688,786}}, {pressure={0.4, 0.4}})

--@ chunk 12
print(wait(4*24*60), drying(720, 950), drying(640, 1100))
-- PASS · paint the old frame out, back to the vault's near-black above the floor line and the floor below it
OLD = FIG:grow(3) - ARKB:grow(1) - ARKTOP:grow(1)
local function fl(x) return 1035 + (x - 600) * 0.0625 end
local above = OLD * mask(function(x, y) return y < fl(x) and 1 or 0 end)
local below = OLD - above
work(above, {hand="body", tool="filbert 6", pile=pile{{"bone black",3},{"burnt sienna",0.8},{"ultramarine blue",0.2}}, coverage=3.8, fill=true, angle=function(x, y) return math.atan(y - 1300, x - 455) + math.pi/2 end, clip=true, load=0.95})
work(below, {hand="body", tool="filbert 6", pile=pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.5}}, coverage=3.6, fill=true, angle=0.1, clip=true, load=0.95})

--@ chunk 13
print(wait(4*24*60))
-- the fountain's lines restored exactly where the old frame had cut them (same paths, same colours), clipped to that gap
local hot = pile{{"zinc white",2},{"lead white",2},{"cadmium yellow",0.5}}
local gold = pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}
local deep = pile{{"Indian yellow",1},{"Mars orange",0.5},{"lead white",0.8}}
local t1 = brush{kind="round", width=1.5, point=0.7}
local gap = OLD * mask(function(x, y) return y < 1000 and 1 or 0 end)
for i = 1, #FOUNT do
  local pts = FOUNT[i]
  for seg = 1, 3 do
    local a, b = (seg - 1) * 3 + 1, math.min(11, seg * 3 + 2)
    local q = {}; for k = a, b do q[#q+1] = pts[k] end
    local hit = false
    for _, p in ipairs(q) do if p[1] > 560 and p[2] < 1000 then hit = true end end
    if hit then
      t1:reload((seg == 1) and hot or ((seg == 2) and gold or deep), 0.6)
      t1:stroke(q, {pressure={0.55 - 0.12 * seg, 0.45 - 0.12 * seg}, ramps={0.1, 0.2}, clip=gap})
    end
  end
end

--@ chunk 14
print(wait(3*24*60))
-- the frame, kneeling in three-quarter rear view, smaller and close by the box
NF = {}
NF.helm = poly({{624,872},{630,860},{644,856},{658,862},{662,876},{656,892},{640,898},{626,892}}, true)
NF.paulL = ellipse(614, 908, 18, 11)
NF.paulR = ellipse(674, 906, 21, 12)
NF.back = poly({{616,904},{686,902},{690,940},{680,980},{626,982},{614,944}}, true)
NF.fauld = poly({{624,976},{684,976},{694,1004},{616,1006}}, true)
NF.armL = ribbon({{604,912},{592,948},{584,980}}, {12, 10, 9})
NF.gaunt = poly({{570,978},{592,976},{598,994},{572,996}}, true)
NF.armR = ribbon({{688,912},{698,950},{692,986}}, {12, 10, 9})
NF.thighU = poly({{622,996},{642,1000},{628,1018},{598,1018},{590,1004}}, true)
NF.shinU = ribbon({{598,1012},{600,1036},{604,1056}}, {13, 12, 11})
NF.footU = poly({{590,1052},{622,1052},{624,1063},{588,1063}}, true)
NF.thighD = ribbon({{668,1004},{674,1030},{678,1052}}, {18, 16, 14})
NF.shinD = ribbon({{678,1054},{712,1058},{740,1061}}, {13, 11, 9})
NF.footD = poly({{736,1048},{750,1050},{750,1066},{736,1066}}, true)
NEWF = NF.helm
for _, k in ipairs({"paulL","paulR","back","fauld","armL","gaunt","armR","thighU","shinU","footU","thighD","shinD","footD"}) do NEWF = NEWF + NF[k] end
work(NEWF, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}, coverage=3.8, fill=true, angle=math.pi/2, clip=true, load=0.95})

--@ chunk 15
print(wait(3*24*60))
-- clean up: old rim flecks round the old outline, the dark blot left in the gold pool, and the shin that read as sitting
local function fl(x) return 1035 + (x - 600) * 0.0625 end
local ring = ((FIG:grow(6) - FIG:shrink(4)) - NEWF:grow(2) - ARKB:grow(1)) * mask(function(x, y) return y < fl(x) and 1 or 0 end)
work(ring, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"bone black",3},{"burnt sienna",0.8},{"ultramarine blue",0.2}}, coverage=3.8, fill=true, angle=0, clip=true})
local blot = (FIG:grow(3) * ellipse(460, 1090, 270, 56)) - NEWF:grow(2) - ARKB:grow(1)
work(blot, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"raw sienna",1},{"yellow ochre",1},{"lead white",0.5},{"burnt sienna",0.4}}, coverage=3.2, fill=true, angle=0, clip=true})
local shin = (NF.shinD + NF.footD):grow(2) - NF.thighD
work(shin, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.5}}, coverage=3.8, fill=true, angle=0.1, clip=true})

--@ chunk 16
print(wait(3*24*60))
-- the kneeling leg foreshortened toward us, sole up; heavier, flared pauldrons; a helm with a flat crown tilted up toward the light
local blk = pile{{"bone black",3},{"ultramarine blue",0.3},{"burnt sienna",0.3}}
NF.shinD = poly({{668,1046},{690,1046},{698,1066},{676,1070}}, true)
NF.footD = poly({{674,1064},{704,1062},{708,1078},{676,1080}}, true)
NF.paulR = poly({{652,896},{676,890},{698,894},{708,908},{700,918},{676,914},{656,914}}, true)
NF.paulL = poly({{628,898},{608,894},{596,902},{594,914},{606,918},{622,914}}, true)
NF.crown = poly({{622,866},{628,850},{646,844},{662,850},{660,862},{642,866}}, true)
local add = NF.shinD + NF.footD + NF.paulR + NF.paulL + NF.crown
work(add, {hand="detail", tool={kind="round", width=2.4, point=0.3}, pile=blk, coverage=3.8, fill=true, angle=math.pi/2, clip=true})
NEWF = NEWF + add

--@ chunk 17
print(wait(3*24*60))
local floorP = pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.5}}
local outer = ((FIG:grow(4) + (NF.shinD + NF.footD):grow(3) + ribbon({{678,1054},{712,1058},{745,1061}}, 18)) - ellipse(470, 1088, 200, 38) - NEWF:grow(1) - ARKB:grow(1)) * rect(560, 1036, 300, 120)
work(outer, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=floorP, coverage=4, fill=true, angle=0.1, clip=true, load=1.0})

--@ chunk 18
print(wait(4*24*60))
-- gold rim along every edge that faces the fountain (left and above), broken; plate seams; the visor slit full of gold; the rag
local gold = pile{{"lead white",2},{"cadmium yellow",0.7},{"Indian yellow",0.3}}
local hot = pile{{"zinc white",1},{"lead white",2},{"cadmium yellow",0.5}}
local nz = noise{seed=41, period=6}
local edge = mask(function(x, y)
  if x < 560 or x > 760 or y < 850 or y > 1070 then return 0 end
  if NEWF:at(x, y) < 0.5 then return 0 end
  if NEWF:at(x - 1.5, y - 1.3) > 0.5 then return 0 end
  return nz:at01(x, y) > 0.28 and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=1.2, point=0.8}, pile=gold, coverage=2.2, fill=true, clip=true, angle=0.8})
local hi = edge * mask(function(x, y) return (y < 930) and 1 or 0 end)
work(hi, {hand="detail", tool={kind="round", width=1.0, point=0.9}, pile=hot, coverage=1.6, fill=true, clip=true, angle=0.8})
local v = brush{kind="round", width=2.2, point=0.6}
v:load(pile{{"lead white",2},{"cadmium yellow",0.8},{"Indian yellow",0.3}}, 0.7)
v:stroke({{626,870},{632,862},{642,858}}, {pressure={0.7, 0.5}})
v:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.6)
v:stroke({{630,866},{636,861}}, {pressure={0.5, 0.3}})
local sm = brush{kind="round", width=0.9, point=0.9}
local seam = pile{{"burnt sienna",1},{"raw sienna",0.7},{"bone black",0.5}}
for _, s in ipairs({ {{620,924},{688,922}}, {{618,944},{690,942}}, {{622,962},{684,962}}, {{650,904},{650,980}}, {{628,990},{690,990}},
                     {{600,1030},{608,1030}}, {{672,1028},{680,1028}}, {{632,876},{658,874}} }) do
  sm:load(seam, 0.5); sm:stroke(s, {pressure={0.35, 0.35}})
end
local rag = brush("filbert", 5)
rag:load(pile{{"cadmium red",1.5},{"vermilion",0.5},{"rose madder",0.3}}, 0.8)
rag:stroke({{684,900},{700,888},{714,882},{728,870}}, {pressure={0.7, 0.15}, ramps={0.1, 0.5}, orient="across"})
local rl = brush{kind="round", width=1.4, point=0.7}
rl:load(pile{{"vermilion",1},{"Mars orange",0.6},{"lead white",0.5}}, 0.55)
rl:stroke({{688,896},{702,886},{716,880}}, {pressure={0.45, 0.1}})
-- faint red-gold glow on the rubble round him
local d = brush("flat", 4)
for i = 1, 90 do
  local x, y = rand(560, 790), rand(1040, 1110)
  if NEWF:grow(2):at(x, y) < 0.5 and ARKB:at(x, y) < 0.5 then
    local dd = math.sqrt(((x - 640) / 140)^2 + ((y - 1062) / 40)^2)
    if dd < 1.1 then
      d:reload((math.random() < 0.5) and pile{{"Mars orange",1},{"burnt sienna",0.8},{"lead white",0.3}} or pile{{"raw sienna",1},{"yellow ochre",0.6},{"cadmium red",0.2}}, 0.5)
      d:stroke({{x - 2, y}, {x + 2, y}}, {pressure={0.4 * (1.1 - dd), 0.3 * (1.1 - dd)}, orient=math.pi/2})
    end
  end
end
print(edge:area())

--@ chunk 19
print(wait(3*24*60))
-- the visor slit, plainly gold; the last ghost of the old shin covered
local v = brush{kind="round", width=3.4, point=0.4}
v:load(pile{{"lead white",2},{"cadmium yellow",0.9},{"Indian yellow",0.4}}, 0.8)
v:stroke({{624,872},{630,862},{640,856}}, {pressure={0.8, 0.6}})
local w = brush{kind="round", width=1.4, point=0.8}
w:load(pile{{"zinc white",3},{"lemon chrome",0.2}}, 0.6)
w:stroke({{627,866},{634,859}}, {pressure={0.6, 0.3}})
local ghost = rect(712, 1050, 50, 22) - NEWF:grow(1)
work(ghost, {hand="detail", tool={kind="round", width=3, point=0.3}, pile=pile{{"bone black",1.6},{"burnt sienna",1},{"raw sienna",0.5}}, coverage=4, fill=true, angle=0.1, clip=true, load=1.0})
