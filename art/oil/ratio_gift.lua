-- easel session "ratio_gift": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=4/3, linen={18,16}, seed=7272, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"burnt sienna",3},{"bone brown",2},{"lead white",1},{"ultramarine blue",0.4}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
GC = {400, 560}
local H0 = pile{{"bone brown",2},{"ultramarine blue",0.6},{"bone black",0.5}}
local H1 = pile{{"bone brown",2},{"burnt sienna",1.2},{"ultramarine blue",0.3}}
local H2 = pile{{"burnt sienna",2},{"Mars orange",0.8},{"bone brown",0.5}}
local d = function(x,y) return math.sqrt(((x-GC[1])/1.3)^2 + (y-GC[2])^2) end
local outer = mask(function(x,y) return d(x,y) > 330 and 1 or 0 end):roughen(15,80,1)
local mid = mask(function(x,y) local v=d(x,y) return (v > 180 and v <= 340) and 1 or 0 end):roughen(12,70,2)
local inner = mask(function(x,y) return d(x,y) <= 190 and 1 or 0 end)
local rad = function(x,y) return math.atan(y-GC[2], x-GC[1]) + math.pi/2 end
work(outer, {hand="broad", pile=H0, coverage=3, fill=true, angle=rad})
work(mid, {hand="broad", pile=H1, coverage=3, fill=true, angle=rad})
work(inner, {hand="body", pile=H2, coverage=3, fill=true, angle=rad, tool="filbert 14"})
for _,r in ipairs({185, 335}) do
  blend(mask(function(x,y) return math.abs(d(x,y)-r) < 26 and 1 or 0 end), {angle=rad, tool={kind="badger", width=24}, pressure={0.35,0.55}})
end

--@ chunk 3
print(wait(2*24*60))
-- ribs: heavy dark rings around the bay, centred behind the bed
local m = nil
for k,s in ipairs({1.35, 1.05, 0.8}) do
  local pts = {}
  for i=0,64 do local a = 2*math.pi*i/64; pts[#pts+1] = {GC[1] + 470*s*math.cos(a), GC[2] - 120 + 380*s*math.sin(a)} end
  local r = ribbon(pts, 32*s); m = m and (m+r) or r
end
DECK = rect(0, 600, 1000, 150)
RIBM = m - DECK
work(RIBM, {hand="body", pile=pile{{"bone black",1.5},{"bone brown",1.5},{"burnt sienna",0.6}}, coverage=3.5, fill=true, tool="filbert 10", angle=function(x,y) return math.atan(y-440,x-400)+math.pi/2 end, clip=RIBM})
-- the deck: lit near the bed, dark toward us
local D1 = pile{{"burnt sienna",2},{"Mars orange",0.6},{"bone brown",0.6}}
local D0 = pile{{"bone brown",2},{"bone black",0.6},{"ultramarine blue",0.3}}
work(DECK * above(function(x) return 660 end), {hand="body", pile=D1, coverage=3.5, fill=true, tool="filbert 12", angle=0, clip=DECK})
work(DECK * below(function(x) return 660 end), {hand="broad", pile=D0, coverage=3.5, fill=true, angle=0, clip=DECK})
blend(DECK * rect(0,640,1000,40), {angle=0, tool={kind="badger", width=24}, pressure={0.35,0.55}})
-- the print bed: a round platform, its top glowing
BEDTOP = ellipse(380, 590, 150, 34)
BEDSIDE = rect(230, 590, 300, 34) + ellipse(380, 624, 150, 34)
work(BEDSIDE - BEDTOP, {hand="detail", pile=pile{{"bone black",1.5},{"burnt sienna",0.8}}, coverage=4, fill=true, clip=BEDSIDE - BEDTOP})
work(BEDTOP, {hand="body", pile=pile{{"Mars orange",1.5},{"cadmium yellow",0.8},{"lead white",0.4}}, coverage=4, fill=true, tool="filbert 6", angle=0, clip=BEDTOP})
work(ellipse(380, 590, 90, 18), {hand="body", pile=pile{{"lead white",2},{"cadmium yellow",0.8},{"lemon chrome",0.2}}, coverage=3, fill=true, tool="filbert 5", angle=0, clip=BEDTOP})
blend(BEDTOP:shrink(3), {angle=0, tool={kind="badger", width=12}, pressure={0.3,0.5}})

--@ chunk 4
print(wait(2*24*60))
NP = {
  helm = {{560,420},{596,410},{624,420},{634,450},{630,484},{606,498},{574,494},{556,470},{552,444}},
  gorget = {{570,492},{626,490},{640,512},{566,516}},
  cuirass = {{578,508},{668,500},{700,540},{700,600},{660,616},{596,612},{580,566}},
  pauldron = {{606,500},{660,494},{690,520},{676,552},{630,548},{600,532}},
  rere = {{604,540},{636,550},{600,566},{566,560}},
  vamb = {{570,550},{560,572},{500,576},{502,556}},
  gaunt = {{504,552},{500,580},{454,586},{440,576},{452,562}},
  hip = {{640,596},{712,590},{720,628},{650,636}},
  thighF = {{596,606},{650,610},{600,646},{556,640}},
  kneeF = {{540,622},{574,618},{582,646},{548,654}},
  shinF = {{550,650},{580,648},{586,712},{560,716}},
  footF = {{548,708},{596,706},{604,726},{532,728}},
  thighB = {{676,620},{722,616},{732,688},{696,694}},
  kneeB = {{690,680},{736,676},{744,706},{694,712}},
  shinB = {{736,684},{820,694},{822,714},{740,712}},
  cannon = {{740,380},{758,380},{762,700},{744,700}},
}
SDK = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
SMD = pile{{"ultramarine ash",1},{"bone black",0.8},{"burnt sienna",0.35},{"lead white",0.2}}
SLT = pile{{"lead white",1},{"Mars orange",0.4},{"ultramarine ash",0.4},{"bone black",0.15}}
function bb(pts) local a,b,c,d = 1e9,-1e9,1e9,-1e9 for _,q in ipairs(pts) do a=math.min(a,q[1]) b=math.max(b,q[1]) c=math.min(c,q[2]) d=math.max(d,q[2]) end return a,b,c,d end
function plate(k, ang)
  local pts = NP[k]; local minx,maxx,miny,maxy = bb(pts)
  local cx, hw = (minx+maxx)/2, (maxx-minx)/2
  local m = poly(pts)
  work(m, {hand="body", pile=SDK, coverage=3, fill=true, tool="filbert 3", angle=ang, clip=m, length={8,25}})
  work(m * rect(minx-4, miny-4, cx - minx + 4, maxy-miny+8), {hand="body", pile=SMD, coverage=2.5, fill=true, tool="filbert 3", angle=ang, clip=m, length={8,25}})
  work(m * rect(minx-4, miny-4, (cx - 0.55*hw) - minx + 4, maxy-miny+8), {hand="body", pile=SLT, coverage=1.6, tool="filbert 2", angle=ang, clip=m, length={6,16}})
end
for _,k in ipairs({"cannon","shinB","kneeB","thighB","hip","cuirass","pauldron","footF","shinF","thighF","kneeF","rere","vamb","gaunt","gorget","helm"}) do
  plate(k, (k:find("shin") or k:find("vamb") or k:find("thigh")) and 0 or math.pi/2)
end
CMDO = nil
for k,p in pairs(NP) do local m = poly(p); CMDO = CMDO and (CMDO + m) or m end

--@ chunk 5
print(wait(3*24*60))
local MID = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"burnt sienna",0.7},{"ultramarine ash",0.4}}
-- bulk him up: a broader back and pauldron, deeper chest
NP.back = {{640,498},{700,500},{730,540},{726,604},{690,612}}
NP.pauldron = {{598,494},{666,486},{704,516},{690,560},{632,556},{594,532}}
for _,k in ipairs({"back","cannon","shinB","kneeB","thighB","hip","cuirass","pauldron","footF","shinF","thighF","kneeF","rere","vamb","gaunt","gorget","helm"}) do
  local m = poly(NP[k]); local minx,maxx,miny,maxy = bb(NP[k]); local cx = (minx+maxx)/2
  work(m, {hand="detail", pile=SDK, coverage=4, fill=true, clip=m})
  work(m * rect(minx-2, miny-2, cx - minx, maxy-miny+4), {hand="detail", pile=MID, coverage=3, fill=true, clip=m})
end
CMDO = CMDO + poly(NP.back) + poly(NP.pauldron)

--@ chunk 6
print(wait(3*24*60))
-- edges: warm print-light on the faces turned toward the bed (left and down), dark seams under each plate
local WARM = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local HOT = pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}}
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.4}}
local r = brush{kind="round", width=4, point=0.8}
for k,pts in pairs(NP) do
  local n = #pts; local cx, cy = 0, 0 for _,q in ipairs(pts) do cx = cx + q[1]/n; cy = cy + q[2]/n end
  for i=1,n do
    local a, b = pts[i], pts[i % n + 1]
    local dx, dy = b[1]-a[1], b[2]-a[2]; local l = math.sqrt(dx*dx+dy*dy)
    if l > 6 then
      local nx, ny = -dy/l, dx/l
      local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
      if (mx-cx)*nx + (my-cy)*ny < 0 then nx, ny = -nx, -ny end
      local tx, ty = 380 - mx, 590 - my; local tl = math.sqrt(tx*tx+ty*ty); tx, ty = tx/tl, ty/tl
      local facing = nx*tx + ny*ty
      local p0 = {a[1] - nx*1.5 + dx*0.06, a[2] - ny*1.5 + dy*0.06}
      local p1 = {b[1] - nx*1.5 - dx*0.06, b[2] - ny*1.5 - dy*0.06}
      if facing > 0.5 then
        r:reload(facing > 0.85 and HOT or WARM, 0.6); r:stroke({p0, p1}, {pressure={r:pressure_for(2), r:pressure_for(1)}, swell={0.4,1,0.5}})
      end
      if ny > 0.6 then r:reload(SEAM, 0.6); r:stroke({{a[1]+nx*1.5, a[2]+ny*1.5},{b[1]+nx*1.5, b[2]+ny*1.5}}, {pressure={r:pressure_for(1.8), r:pressure_for(1.8)}}) end
    end
  end
end
-- visor slit with the one cold optic, turned toward her; the crimson rag on his shoulder
local sl = poly({{556,452},{604,450},{604,460},{556,462}})
work(sl, {hand="detail", pile=SEAM, coverage=5, fill=true, clip=sl})
r:reload(pile{{"cerulean blue",1},{"zinc white",1}}, 0.8); r:stroke({{562,456},{576,456}}, {pressure={r:pressure_for(3), r:pressure_for(3)}})
local rag = poly({{620,498},{680,492},{700,520},{690,560},{678,548},{668,566},{654,550},{640,566},{628,546}})
work(rag, {hand="detail", pile=pile{{"Mars red",1.5},{"rose madder",1},{"bone black",0.2}}, coverage=5, fill=true, clip=rag})
r:reload(pile{{"vermilion",1.2},{"lead white",0.3}}, 0.6); r:stroke({{622,502},{640,498},{660,496}}, {pressure={r:pressure_for(2), r:pressure_for(1)}})

--@ chunk 7
print(wait(2*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local HAIR = pile{{"bone black",2},{"ultramarine blue",0.4}}
local HAIR2 = pile{{"bone black",1.2},{"ultramarine blue",0.6},{"lead white",0.35}}
local WHITE = pile{{"zinc white",2.5},{"cerulean blue",0.05}}
local WSH = pile{{"lead white",1.6},{"cobalt violet",0.2},{"ultramarine ash",0.4}}
local BRZ = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.6}}
local BRZD = pile{{"burnt sienna",1},{"bone brown",0.6},{"yellow ochre",0.4}}
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
local SKIN2 = pile{{"lead white",2.2},{"Mars orange",0.25},{"rose madder",0.15}}
-- hair behind
F({{322,430},{340,414},{334,500},{322,546},{310,540}}, HAIR)
F({{384,428},{396,440},{398,510},{390,548},{376,540}}, HAIR)
-- legs, a little splayed: she is not sure of them yet
F({{336,544},{350,544},{346,586},{330,586}}, BRZ)
F({{358,544},{372,544},{378,584},{364,586}}, BRZD)
F({{326,582},{350,582},{352,594},{322,594}}, WHITE)
F({{360,582},{384,582},{388,594},{358,594}}, WSH)
-- hips and torso: white shell with bronze panels
F({{330,520},{378,520},{382,548},{326,548}}, WHITE)
F({{356,520},{378,520},{382,548},{356,548}}, WSH)
F({{334,478},{376,478},{378,522},{332,522}}, WHITE)
F({{360,478},{376,478},{378,522},{360,522}}, WSH)
F({{344,486},{366,486},{364,510},{346,510}}, BRZ)
-- arms raised in front, hands open, palms up: she is looking at them
F({{334,482},{326,500},{340,512},{350,498}}, WHITE)
F({{340,506},{384,510},{384,520},{340,516}}, WSH)
F({{372,482},{386,496},{396,506},{384,510},{372,496}}, WHITE)
F({{380,508},{398,504},{402,514},{384,518}}, SKIN)
F({{382,516},{400,516},{402,524},{384,524}}, SKIN2)
-- head: big, three-quarter, tilted down
F({{326,420},{344,406},{374,404},{394,418},{398,446},{392,470},{372,484},{346,484},{328,470},{320,446}}, HAIR)
F({{334,436},{388,432},{392,454},{386,474},{366,484},{346,482},{334,468}}, SKIN)
F({{376,440},{388,436},{392,454},{386,474},{376,476}}, SKIN2)
-- stiff printed fringe, faceted points
F({{328,418},{392,414},{396,440},{384,432},{376,446},{366,430},{356,446},{346,432},{336,446},{326,436}}, HAIR2)
F({{332,418},{346,410},{372,408},{386,416},{360,420}}, HAIR)

--@ chunk 8
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
local EYE = pile{{"bone black",2},{"ultramarine blue",0.5}}
-- big dark eyes, looking down at her hands, square highlights
F({{342,452},{356,450},{357,468},{343,469}}, EYE)
F({{366,450},{379,449},{380,466},{367,467}}, EYE)
F({{345,454},{350,454},{350,459},{345,459}}, pile{{"zinc white",2}})
F({{369,453},{374,453},{374,458},{369,458}}, pile{{"zinc white",2}})
-- a small 'o' of a mouth
F({{359,474},{364,474},{364,479},{359,479}}, pile{{"rose madder",1},{"bone black",0.5}})
-- the print-light from below on her: warm facets under the chin, the arms, the hem
local r = brush{kind="round", width=4, point=0.8}
local W = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}
r:reload(W, 0.6); r:stroke({{346,484},{372,484}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}})
r:reload(W, 0.6); r:stroke({{340,516},{384,520}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}})
r:reload(W, 0.6); r:stroke({{326,548},{382,548}}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}})
r:reload(W, 0.6); r:stroke({{322,594},{352,594}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
r:reload(W, 0.6); r:stroke({{358,594},{388,594}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
-- a hair facet catching the glow
r:reload(pile{{"ultramarine ash",0.6},{"Mars orange",0.4},{"bone black",0.6},{"lead white",0.4}}, 0.6); r:stroke({{336,414},{360,408},{384,414}}, {pressure={r:pressure_for(2), r:pressure_for(2)}})
-- her small shadow on the bed and his palm's warm lip
local sh = ellipse(362, 596, 34, 5)
work(sh - poly({{326,582},{350,582},{352,594},{322,594}}) - poly({{360,582},{384,582},{388,594},{358,594}}), {hand="detail", pile=pile{{"burnt sienna",1},{"bone brown",1}}, coverage=3, fill=true, clip=sh})
r:reload(pile{{"lead white",2},{"cadmium yellow",0.6}}, 0.6); r:stroke({{442,576},{470,572},{500,566}}, {pressure={r:pressure_for(1.6), r:pressure_for(1)}})

--@ chunk 9
print(wait(4*24*60)); print(drying(360,460))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
local SKIN = pile{{"lead white",3},{"rose madder",0.15},{"yellow ochre",0.12}}
local SKIN2 = pile{{"lead white",2.2},{"Mars orange",0.25},{"rose madder",0.15}}
local WHITE = pile{{"zinc white",2.5},{"cerulean blue",0.05}}
F({{336,446},{388,442},{392,454},{386,474},{366,484},{346,482},{334,468}}, SKIN)
F({{378,446},{390,444},{392,454},{386,474},{378,476}}, SKIN2)
F({{334,482},{326,500},{340,512},{350,498}}, WHITE)
F({{372,482},{386,496},{396,506},{384,510},{372,496}}, WHITE)
F({{340,506},{384,510},{384,520},{340,516}}, pile{{"lead white",1.8},{"cobalt violet",0.15},{"ultramarine ash",0.3}})
F({{380,508},{398,504},{402,514},{384,518}}, SKIN)
F({{332,486},{340,478},{376,478},{378,522},{332,522}}, WHITE)
-- his open palm, turned up, catching the bed's glow
F({{444,566},{500,558},{502,566},{448,574}}, pile{{"Mars orange",0.8},{"burnt sienna",0.8},{"lead white",0.6}})

--@ chunk 10
print(wait(3*24*60))
local function F(pts, p) local m = poly(pts); work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
local EYE = pile{{"bone black",2},{"ultramarine blue",0.5}}
F({{342,452},{356,450},{357,468},{343,469}}, EYE)
F({{366,450},{379,449},{380,466},{367,467}}, EYE)
F({{345,454},{350,454},{350,459},{345,459}}, pile{{"zinc white",2}})
F({{369,453},{374,453},{374,458},{369,458}}, pile{{"zinc white",2}})
F({{359,474},{364,474},{364,479},{359,479}}, pile{{"rose madder",1},{"bone black",0.5}})
F({{344,486},{366,486},{364,510},{346,510}}, pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.6}})
F({{352,472},{356,470},{355,474}}, pile{{"rose madder",1},{"lead white",1.5}})
local r = brush{kind="round", width=4, point=0.8}
local W = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.8}}
r:reload(W, 0.6); r:stroke({{346,484},{372,484}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}})
r:reload(W, 0.6); r:stroke({{340,516},{384,520}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}})
-- the fingers of his gauntlet curling up at the tip
F({{440,566},{448,562},{444,552},{438,556}}, pile{{"bone black",1.6},{"ultramarine ash",0.5}})
F({{448,562},{456,560},{452,550},{446,552}}, pile{{"bone black",1.6},{"ultramarine ash",0.5}})

--@ chunk 11
local r = brush{kind="round", width=4, point=0.8}
local W = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",0.6}}
local D = pile{{"Mars orange",1},{"burnt sienna",1},{"yellow ochre",0.4}}
-- rib inner edges catching the print-light
for k,s in ipairs({1.35, 1.05, 0.8}) do
  local pts = {}
  for i=34,62 do local a = 2*math.pi*i/64; local x, y = GC[1] + (470*s - 15*s)*math.cos(a), GC[2] - 120 + (380*s - 15*s)*math.sin(a)
    if y < 598 then pts[#pts+1] = {x,y} end end
  if #pts > 2 then r:reload(k == 3 and W or D, 0.5); r:stroke(pts, {pressure={r:pressure_for(0.6), r:pressure_for(0.6)}, swell={0.2,1,1,1,0.2}, clip=-(CMDO:grow(2) + rect(320,400,90,200))}) end
end
-- his helm's edge toward her, warm
r:reload(W, 0.6); r:stroke({{560,424},{554,446},{558,470}}, {pressure={r:pressure_for(1), r:pressure_for(2)}})
r:reload(W, 0.5); r:stroke({{572,494},{600,496}}, {pressure={r:pressure_for(1.4), r:pressure_for(1)}})
-- bed rim
r:reload(pile{{"lead white",2},{"cadmium yellow",0.6}}, 0.6); r:stroke({{232,596},{300,618},{380,624},{460,618},{528,596}}, {pressure={r:pressure_for(1), r:pressure_for(1)}, swell={0.3,1,1,1,0.3}, clip=-CMDO})
