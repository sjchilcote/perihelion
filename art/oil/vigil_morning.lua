-- easel session "vigil_morning": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.6, linen={18,16}, seed=11,
  ground={{pile={{"bone black",1},{"ultramarine blue",1.2},{"rose madder",0.15},{"lead white",0.25}}, um=120, apply="knife", texture=0.3}}}
function hz(x) return 440 + 0.00015*(x-380)^2 + 0.02*(x-380) end
function hzd(x) return 0.0003*(x-380) + 0.02 end
SUNX, SUNY = 488, 318
local sky = above(hz)
local K = {
  pile{{"bone black",2},{"ultramarine blue",1}},
  pile{{"bone black",1.2},{"ultramarine blue",1},{"rose madder",0.2}},
  pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.12},{"rose madder",0.15}},
  pile{{"ultramarine blue",1},{"bone black",0.45},{"lead white",0.3},{"cobalt violet",0.2}},
}
local YE = {-10, 140, 250, 345, 700}
for i=1,4 do
  local m = sky * rect(-5, YE[i], 1010, YE[i+1]-YE[i])
  work(m, {hand="body", tool={kind="filbert", width=14}, pile=K[i], coverage=2.6, fill=true, angle=0.03, length={70,180}, clip=sky})
end
for i=2,4 do blend(sky * rect(-5, YE[i]-9, 1010, 18), {angle=0.03, tool={kind="badger", width=14}}) end
-- the hull: cool dim bronze, catching starlight only at the far edge
local hull = below(hz)
HB = {
  pile{{"lead white",1},{"ultramarine ash",1},{"raw sienna",0.35},{"bone black",0.15}},
  pile{{"raw sienna",0.6},{"bone black",1},{"ultramarine blue",0.5},{"lead white",0.35}},
  pile{{"bone black",1},{"raw sienna",0.6},{"ultramarine blue",0.5},{"lead white",0.1}},
  pile{{"bone black",1.5},{"ultramarine blue",0.5},{"burnt sienna",0.3}},
}
local HE = {-1, 5, 22, 70, 400}
for i=1,4 do
  local m = hull * mask(function(x,y) local d=y-hz(x); return (d>=HE[i] and d<HE[i+1]) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=(i<3) and 6 or 14}, pile=HB[i], coverage=2.8, fill=true,
           angle=function(x,y) return math.atan(hzd(x)) end, length={40,140}, clip=hull})
end

--@ chunk 2
local sky = above(hz)
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local low = sky * rect(-5, 300, 1010, 300)
work(low, {hand="body", tool={kind="filbert", width=14}, pile=K4b, coverage=2.2, fill=true, angle=0.03, length={70,180}, clip=sky})
for _,y in ipairs({140, 250, 300, 345}) do
  blend(sky * rect(-5, y-28, 1010, 56), {angle=0.03, tool={kind="badger", width=18}})
end
local hull = below(hz)
local HBz = pile{{"bone black",1},{"burnt sienna",0.6},{"raw sienna",0.45},{"ultramarine blue",0.35},{"lead white",0.12}}
local m = hull * mask(function(x,y) local d=y-hz(x); return (d>=3.5 and d<75) and 1 or 0 end)
work(m, {hand="body", tool={kind="filbert", width=8}, pile=HBz, coverage=2.6, fill=true, angle=function(x,y) return math.atan(hzd(x)) end, length={40,140}, clip=hull})
blend(hull * mask(function(x,y) local d=y-hz(x); return (d>=55 and d<95) and 1 or 0 end), {angle=0, tool={kind="badger", width=14}})

--@ chunk 3
print(wait(3*24*60))
-- the far Sun: a small white-hot star with a modest corona
local sky = above(hz)
local GL = pile{{"lead white",3},{"zinc white",1},{"cerulean blue",0.1},medium=0.6}
local GL2 = pile{{"lead white",3},{"lemon chrome",0.3},{"Mars orange",0.1},medium=0.6}
for i,r in ipairs({60, 38, 22}) do
  local m = ellipse(SUNX, SUNY, r, r):soften(r*0.45) * sky
  work(m, {hand="glaze", tool={kind="filbert", width=6}, pile=(i==3) and GL2 or GL, load=0.22, pressure={0.1,0.22}, coverage=1.2, clip=m, angle=0.3})
end
blend(ellipse(SUNX, SUNY, 64, 64) * sky, {tool={kind="badger", width=14}})
work(ellipse(SUNX, SUNY, 7.5, 7.5), {hand="detail", pile=pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.2}}, coverage=4, fill=true, clip=true})
work(ellipse(SUNX, SUNY, 4.2, 4.2), {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=4, fill=true, clip=true})
local rr = brush{kind="rigger", width=1.0, point=1}
local WRAY = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.1}}
for i,a in ipairs({0.25, 1.05, 1.9, 2.75, 3.55, 4.4, 5.2, 5.85}) do
  local L = (i%2==1) and rand(55,80) or rand(25,38)
  rr:reload(WRAY, 0.5)
  rr:stroke({{SUNX+8*math.cos(a), SUNY+8*math.sin(a)}, {SUNX+L*math.cos(a), SUNY+L*math.sin(a)}}, {pressure={0.4,0.0}, ramps={0.05,0.9}})
end
-- the stars
local ST = {pile{{"zinc white",3},{"lead white",1}}, pile{{"zinc white",2},{"cerulean blue",0.4}}, pile{{"lead white",3},{"chrome yellow",0.3}}, pile{{"lead white",2},{"vermilion",0.2}}}
local sb = brush{kind="round", width=1.0, point=0.8}
local free = sky - ellipse(SUNX, SUNY, 70, 70) - below(function(x) return hz(x)-4 end)
local n = 0
for i=1,1400 do
  local x, y = rand(2, 998), rand(2, 430)
  if free:at(x,y) > 0.5 and math.random() < 1.1 - y/480 then
    sb:reload(ST[math.random(1,4)], 0.5)
    sb:touch(x, y, {pressure=(math.random()<0.08) and rand(0.3,0.45) or rand(0.06,0.2)})
    n = n + 1
  end
end
-- a faint band of the galaxy, stippled
local band = mask(function(x,y) local d = (y - (60 + 0.32*x)); return math.exp(-(d/45)^2) > 0.3 and 1 or 0 end) * free
stipple(band, {pile=pile{{"lead white",2},{"ultramarine ash",1},{"cobalt violet",0.2}}, width=0.9, coverage=0.5, pressure={0.05,0.15}, cluster={0.6, 12}})
print(n)

--@ chunk 4
local sky = above(hz)
-- take the milky band back into the sky, zone by zone
local K1 = pile{{"bone black",2},{"ultramarine blue",1}}
local K2 = pile{{"bone black",1.2},{"ultramarine blue",1},{"rose madder",0.2}}
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local band = mask(function(x,y) local d = (y - (60 + 0.32*x)); return math.exp(-(d/45)^2) > 0.22 and 1 or 0 end) * sky - ellipse(SUNX,SUNY,66,66)
local Z = {{-10,140,K1},{140,250,K2},{250,700,K4b}}
for _,z in ipairs(Z) do
  local m = band * rect(-5, z[1], 1010, z[2]-z[1])
  work(m, {hand="body", tool={kind="filbert", width=10}, pile=z[3], coverage=3, fill=true, angle=0.32, length={30,90}, clip=m})
end
blend(band:grow(6) - band:shrink(6), {angle=0.32, tool={kind="badger", width=10}})
-- the corona again, as graded rings, fused only at their seams
local RG = {
  {0, 11, pile{{"lead white",2},{"zinc white",1},{"cerulean blue",0.2}}},
  {11, 24, pile{{"lead white",1.2},{"ultramarine blue",0.4},{"bone black",0.15},{"zinc white",0.5}}},
  {24, 42, pile{{"ultramarine blue",1},{"lead white",0.55},{"bone black",0.5}}},
  {42, 68, K4b},
}
for _,g in ipairs(RG) do
  local m = (ellipse(SUNX,SUNY,g[2],g[2]) - ellipse(SUNX,SUNY,g[1],g[1])) * sky
  work(m, {hand="body", tool={kind="filbert", width=4}, pile=g[3], coverage=3.2, fill=true,
           angle=function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end, length={8,30}, clip=m})
end
for _,r in ipairs({11, 24, 42, 66}) do
  blend((ellipse(SUNX,SUNY,r+6,r+6) - ellipse(SUNX,SUNY,r-6,r-6)) * sky, {angle=function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end, tool={kind="badger", width=8}})
end

--@ chunk 5
print(wait(2*24*60))
local function lerp2(a,b,t) return {a[1]+(b[1]-a[1])*t, a[2]+(b[2]-a[2])*t} end
MAST_DK = pile{{"bone black",2},{"bone brown",1},{"ultramarine blue",0.5}}
-- the sail, whole and set: a taut film from the yard to the boom, catching the far Sun
SAILQ = poly({{600,131},{700,115},{806,99},{802,250},{797,404},{705,392},{614,377},{608,250}}, true)
HX, HY = 712, 238
local function sd(x,y) return math.sqrt(((x-HX)/95)^2 + ((y-HY)/150)^2) end
local SP = {
  {0, 0.18, pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.5}}},
  {0.18, 0.42, pile{{"lead white",3},{"chrome yellow",0.6},{"ultramarine ash",0.4}}},
  {0.42, 0.7, pile{{"ultramarine ash",1},{"lead white",0.8},{"raw sienna",0.25},{"bone black",0.15}}},
  {0.7, 0.95, pile{{"ultramarine blue",1},{"ultramarine ash",0.8},{"bone black",0.45},{"lead white",0.3}}},
  {0.95, 9, pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.15}}},
}
for _,s in ipairs(SP) do
  local m = mask(function(x,y) local d = sd(x,y); return (d>=s[1] and d<s[2]) and 1 or 0 end) * SAILQ
  if m:area() > 2 then
    work(m, {hand="body", tool={kind="filbert", width=5}, pile=s[3], coverage=3.2, fill=true, angle=math.pi/2, length={20,60}, clip=SAILQ})
  end
end
local seams = mask(function(x,y) local d = sd(x,y); for _,c in ipairs({0.18,0.42,0.7,0.95}) do if math.abs(d-c)<0.05 then return 1 end end return 0 end) * SAILQ:shrink(2)
blend(seams, {angle=math.pi/2, tool={kind="badger", width=8}})
-- mast (a lattice), yard and boom
local A1,B1 = {783,506},{801,36}
local A2,B2 = {795,506},{814,36}
local rails = ribbon({A1, lerp2(A1,B1,0.5), B1}, {2.6,2.2,1.8}) + ribbon({A2, lerp2(A2,B2,0.5), B2}, {2.6,2.2,1.8})
local braces
local t = 0.03
while t < 0.96 do
  local r = ribbon({lerp2(A1,B1,t), lerp2(A2,B2,t+0.028)}, 1.1)
  braces = braces and (braces + r) or r
  t = t + rand(0.035,0.055)
end
local yard = ribbon({{812,96},{760,104},{700,114},{640,123},{596,130}}, {2.6,2.3,2.1,1.9,1.7})
local boom = ribbon({{800,405},{750,399},{700,393},{650,384},{612,378}}, {2.2,2,1.8,1.6,1.5})
MASTM = rails + braces + yard + boom
work(MASTM, {hand="detail", pile=MAST_DK, coverage=3.5, fill=true})
local foot = poly({{780,509},{783,500},{798,500},{801,509}}) + ellipse(790.5,509,13,2.6)
work(foot, {hand="detail", pile=MAST_DK, coverage=4, fill=true})
local function cable(a, b, sag, w)
  local pts = {}
  for i=0,12 do local tt=i/12; pts[#pts+1] = {a[1]+(b[1]-a[1])*tt, a[2]+(b[2]-a[2])*tt + sag*4*tt*(1-tt)} end
  local r = brush{kind="round", width=w, point=0.6}
  r:reload(MAST_DK, 0.9); r:stroke(pts, {pressure={0.35,0.3}})
end
cable({807,150}, {872,518}, 6, 1.0)
cable({797,330}, {754,505}, 3, 0.9)
cable({612,378}, {700,470}, 4, 0.8)
-- the frame: same body, younger
function fig_parts(dx, dy)
  dx = dx or 0; dy = dy or 0
  local function P(t) local o={} for i,p in ipairs(t) do o[i]={p[1]+dx,p[2]+dy} end return o end
  local parts = {}
  parts.torso = poly(P{{369,494},{367,474},{368,456},{366,447},{370,441},{380,438},{398,438},{408,441},{411,447},{409,456},{408,474},{406,494}}, true)
  parts.lpaul = ellipse(368+dx,444+dy,7,5.5)
  parts.rpaul = ellipse(409+dx,444+dy,7,5.5)
  parts.neck = poly(P{{385,440},{386,430},{394,430},{395,440}}, true)
  parts.head = poly(P{{383,429},{383,420},{387,413},{394,411},{400,414},{403,421},{401,429},{396,433},{387,432}}, true)
  parts.ant = ribbon(P{{399,414},{404,404},{407,398}}, {1.6,1.2,0.9})
  parts.larm = ribbon(P{{366,447},{359,456},{355,463}}, {10,9,8.5})
  parts.knee = ellipse(353+dx,466+dy,8.5,7.5) + ribbon(P{{355,467},{363,490}}, {13,15})
  parts.rarm = ribbon(P{{412,447},{419,460},{423,472},{429,484},{433,492}}, {10,8.5,7.5,6.5,6.5})
  parts.hand = ellipse(434+dx,494+dy,6,3.2)
  parts.hips = poly(P{{360,498},{364,486},{410,486},{418,498}}, true)
  local all = parts.torso + parts.lpaul + parts.rpaul + parts.neck + parts.head + parts.ant + parts.larm + parts.knee + parts.rarm + parts.hand + parts.hips
  return all, parts
end
FIG, FIGP = fig_parts(0,0)
FIG_DK = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.8}}
work(FIG, {hand="detail", pile=FIG_DK, coverage=4, fill=true})
-- the lamp
LAMP_HOUSE = pile{{"bone black",1.5},{"ultramarine blue",0.4},{"burnt sienna",0.3},{"lead white",0.1}}
local base = ellipse(448,495.5,8.5,2.4)
local body = poly({{442.5,495},{442.5,486},{453.5,486},{453.5,495}})
local cap = ellipse(448,485.5,6.2,3.2) + rect(445.5,481.5,5,3)
LAMP = base + body + cap
work(LAMP, {hand="detail", pile=LAMP_HOUSE, coverage=4, fill=true})
local stalk = ribbon({{449,482},{449.5,477},{450,474.5}}, {1.0,0.8,0.7})
work(stalk, {hand="detail", pile=MAST_DK, coverage=3, fill=true})

--@ chunk 6
local SAILN = poly({{599,132},{700,116},{805,100},{800,250},{797,402},{705,391},{613,377},{607,250}}) - MASTM
local K2 = pile{{"bone black",1.2},{"ultramarine blue",1},{"rose madder",0.2}}
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local spill = SAILQ:grow(1.5) - SAILN:grow(0.3) - MASTM
work(spill * above(function(x) return 250 end), {hand="detail", tool={kind="filbert", width=3}, pile=K2, coverage=3.5, fill=true, clip=spill})
work(spill * below(function(x) return 250 end), {hand="detail", tool={kind="filbert", width=3}, pile=K4b, coverage=3.5, fill=true, clip=spill})
-- the mirror: a long vertical blaze where the film reflects the Sun, silver-blue film either side
local function u(x,y) local w = 22 + 0.10*math.abs(y-250); return math.abs(x - (712 + 0.05*(y-250))) / w end
local SP = {
  {0, 0.3, pile{{"zinc white",3},{"lead white",1},{"lemon chrome",0.5}}},
  {0.3, 0.75, pile{{"lead white",3},{"chrome yellow",0.5},{"ultramarine ash",0.5}}},
  {0.75, 1.4, pile{{"ultramarine ash",1},{"lead white",0.7},{"raw sienna",0.2},{"bone black",0.12}}},
  {1.4, 2.4, pile{{"ultramarine blue",1},{"ultramarine ash",1},{"bone black",0.35},{"lead white",0.35}}},
  {2.4, 99, pile{{"ultramarine blue",1},{"ultramarine ash",0.6},{"bone black",0.6},{"lead white",0.2}}},
}
for _,s in ipairs(SP) do
  local m = mask(function(x,y) local d = u(x,y); return (d>=s[1] and d<s[2]) and 1 or 0 end) * SAILN
  if m:area() > 2 then
    work(m, {hand="body", tool={kind="filbert", width=4}, pile=s[3], coverage=3.5, fill=true, angle=math.pi/2, length={25,70}, clip=SAILN})
  end
end
local seams = mask(function(x,y) local d = u(x,y); for _,c in ipairs({0.3,0.75,1.4,2.4}) do if math.abs(d-c)<0.12 then return 1 end end return 0 end) * SAILN:shrink(1.5)
blend(seams, {angle=0, tool={kind="badger", width=6}})
work(MASTM, {hand="detail", pile=MAST_DK, coverage=2.5, fill=true})

--@ chunk 7
print(wait(3*24*60)); print(drying(700,250), drying(390,460), drying(300,520))
-- scale plates: each a dark under-lip and a thin cool lit crest, shrinking toward the horizon
local LIPK = pile{{"bone black",1.5},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local LIPL = pile{{"lead white",1},{"ultramarine ash",1},{"raw sienna",0.3}}
local okm = below(hz) - FIG:grow(1.5) - MASTM:grow(1.5) - LAMP:grow(2)
local bk = brush{kind="round", width=1.2, point=0.5}
local bl = brush{kind="round", width=0.8, point=0.6}
local function lip(cx, cy, w, h, lit)
  local pts, top = {}, {}
  for i=1,9 do local th = math.pi*i/10; local x, y = cx + w/2*math.cos(th), cy - h + h*math.sin(th); pts[#pts+1] = {x,y}; top[#top+1] = {x, y-0.6-h*0.06} end
  bk:reload(LIPK, 0.6); bk:stroke(pts, {pressure={0.3+h*0.01,0.2}, clip=okm})
  if lit > 0 then bl:reload(LIPL, 0.45); bl:stroke(top, {pressure={lit, lit*0.4}, clip=okm}) end
end
local d, k, n = 2.5, 0, 0
while d < 190 do
  k = k + 1
  local h = math.max(1.2, d*0.3)
  local w = h*3.1
  local x = -((k*0.63)%1)*w
  while x < 1010 do
    local ww = w*rand(0.88,1.12)
    local xc = x + ww/2
    local y = hz(xc) + d + rand(-0.1,0.1)*h
    if y < 630 and okm:at(xc, y) > 0.5 then
      lip(xc, y, ww, h, (d < 40) and 0.22 or 0.12); n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end
print(n)

--@ chunk 8
-- the near plates were lit too brightly for a dim far Sun: scumble the hull's own dark back over them
local hull = below(hz) - FIG:grow(1) - MASTM:grow(1) - LAMP:grow(1.5)
local P1 = pile{{"bone black",1},{"burnt sienna",0.6},{"raw sienna",0.45},{"ultramarine blue",0.35},{"lead white",0.1}}
local P2 = pile{{"bone black",1.5},{"ultramarine blue",0.5},{"burnt sienna",0.35}}
local m1 = hull * mask(function(x,y) local d=y-hz(x); return (d>=14 and d<60) and 1 or 0 end)
local m2 = hull * mask(function(x,y) local d=y-hz(x); return (d>=60) and 1 or 0 end)
work(m1, {hand="scumble", tool={kind="filbert", width=6}, pile=P1, coverage=1.3, load=0.4, pressure={0.2,0.45}, angle=0, clip=m1})
work(m2, {hand="scumble", tool={kind="filbert", width=9}, pile=P2, coverage=1.5, load=0.45, pressure={0.25,0.5}, angle=0, clip=m2})

--@ chunk 9
local hull = below(hz) - FIG:grow(1) - MASTM:grow(1) - LAMP:grow(1.5)
blend(hull * mask(function(x,y) local d=y-hz(x); return (d>=48 and d<74) and 1 or 0 end), {angle=0, tool={kind="badger", width=16}})
blend(hull * mask(function(x,y) local d=y-hz(x); return (d>=8 and d<20) and 1 or 0 end), {angle=0, tool={kind="badger", width=10}})
print(wait(2*24*60))
-- scale plates: each a dark under-lip and a thin cool lit crest, shrinking toward the horizon
local LIPK = pile{{"bone black",1.5},{"ultramarine blue",0.5},{"burnt sienna",0.4}}
local LIPL = pile{{"ultramarine ash",1},{"raw sienna",0.6},{"lead white",0.3},{"bone black",0.25}}
local okm = below(hz) - FIG:grow(1.5) - MASTM:grow(1.5) - LAMP:grow(2)
local bk = brush{kind="round", width=1.2, point=0.5}
local bl = brush{kind="round", width=0.8, point=0.6}
local function lip(cx, cy, w, h, lit)
  local pts, top = {}, {}
  for i=1,9 do local th = math.pi*i/10; local x, y = cx + w/2*math.cos(th), cy - h + h*math.sin(th); pts[#pts+1] = {x,y}; top[#top+1] = {x, y-0.6-h*0.06} end
  bk:reload(LIPK, 0.75); bk:stroke(pts, {pressure={0.4+h*0.012,0.3}, clip=okm})
  if lit > 0 then bl:reload(LIPL, 0.45); bl:stroke(top, {pressure={lit, lit*0.4}, clip=okm}) end
end
local d, k, n = 2.5, 0, 0
while d < 190 do
  k = k + 1
  local h = math.max(1.2, d*0.3)
  local w = h*3.1
  local x = -((k*0.63)%1)*w
  while x < 1010 do
    local ww = w*rand(0.88,1.12)
    local xc = x + ww/2
    local y = hz(xc) + d + rand(-0.1,0.1)*h
    if y < 630 and okm:at(xc, y) > 0.5 then
      lip(xc, y, ww, h, (d < 30) and 0.2 or 0.1); n = n + 1
    end
    x = x + ww
  end
  d = d + h*rand(0.95,1.05)
end
print(n)

--@ chunk 10
print(wait(2*24*60)); print(drying(390,460), drying(449,505), drying(700,250))
local P = FIGP
-- the crimson tabard, whole, hanging down the back between the pauldrons
TABARD = poly({{373,446},{388,443},{404,446},{405,470},{406,494},{389,496},{371,494},{372,470}}) * FIG:shrink(1.2)
local TAB = pile{{"rose madder",1},{"cadmium red",0.7},{"bone black",0.35},{"ultramarine blue",0.1}}
local TAB_D = pile{{"rose madder",1},{"Mars red",0.6},{"bone black",0.8}}
work(TABARD, {hand="detail", tool={kind="filbert", width=2.4}, pile=TAB, coverage=3.5, fill=true, angle=math.pi/2, length={6,16}, clip=TABARD})
local folds = TABARD * mask(function(x,y) local u = (x-371)%8; return (u<1.6) and 1 or 0 end) * below(function(x) return 466 end)
work(folds, {hand="detail", tool={kind="round", width=1.2}, pile=TAB_D, coverage=2.5, fill=true, angle=math.pi/2, clip=folds})
-- the lamp's window and its warm pool on the plates
local LENS_O = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
local LENS_C = pile{{"lead white",3},{"cadmium yellow",1.2},{"Indian yellow",0.3}}
work(rect(443.6,487,8.8,4.4), {hand="detail", pile=LENS_O, coverage=4, fill=true, angle=0, clip=true})
work(ellipse(448,489.2,3.2,1.5), {hand="detail", pile=LENS_C, coverage=4, fill=true, angle=0, clip=true})
LP1 = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.5}}
LP2 = pile{{"Mars orange",1},{"cadmium yellow",0.3},{"burnt sienna",0.5},{"lead white",0.15}}
LP3 = pile{{"burnt sienna",1},{"Mars orange",0.4},{"bone brown",0.5},{"ultramarine blue",0.1}}
PCX, PCY, PRX, PRY = 449, 499, 32, 10
local function pd(x,y) return math.sqrt(((x-PCX)/PRX)^2 + ((y-PCY)/PRY)^2) end
local POOLM = ellipse(PCX, PCY, PRX, PRY) - LAMP:grow(0.4) - FIG:grow(0.6)
for i,rg in ipairs({{0, 0.38, LP1}, {0.38, 0.68, LP2}, {0.68, 1.01, LP3}}) do
  local m = mask(function(x,y) local d = pd(x,y); return (d>=rg[1] and d<rg[2]) and 1 or 0 end) * POOLM
  work(m, {hand="body", tool={kind="filbert", width=3.2}, pile=rg[3], coverage=3, fill=true, angle=0, length={5,14}, edge=(i==3) and "soft" or "firm", clip=(i==3) and nil or POOLM})
end
blend(mask(function(x,y) local d = pd(x,y); return (math.abs(d-0.38)<0.07 or math.abs(d-0.68)<0.07) and 1 or 0 end) * POOLM, {angle=0, tool={kind="badger", width=4}})
lose(ellipse(PCX, PCY, PRX, PRY) - LAMP:grow(0.5) - FIG:grow(0.5), {pile=LP3, where=1, load=0.15, tool="filbert 3"})
-- stars again where the sky was reworked
local sky = above(hz)
local ST = {pile{{"zinc white",3},{"lead white",1}}, pile{{"zinc white",2},{"cerulean blue",0.4}}, pile{{"lead white",3},{"chrome yellow",0.3}}, pile{{"lead white",2},{"vermilion",0.2}}}
local sb = brush{kind="round", width=1.1, point=0.8}
local free = sky - ellipse(SUNX, SUNY, 72, 72) - below(function(x) return hz(x)-4 end) - SAILQ:grow(3) - MASTM:grow(2) - FIG:grow(2)
local n = 0
for i=1,1600 do
  local x, y = rand(2, 998), rand(2, 432)
  if free:at(x,y) > 0.5 then
    sb:reload(ST[math.random(1,4)], 0.55)
    sb:touch(x, y, {pressure=(math.random()<0.07) and rand(0.35,0.5) or rand(0.1,0.24)})
    n = n + 1
  end
  if n > 650 then break end
end
print(n)

--@ chunk 11
print(wait(2*24*60)); print(drying(389,470), drying(700,250))
-- the tabard is in the frame's own shadow: deepen it at the sides and hem, keep the crimson in the middle
local TAB_D = pile{{"rose madder",1},{"Mars red",0.5},{"bone black",1.0},{"ultramarine blue",0.15}}
local sides = TABARD * mask(function(x,y) local c = 389; return (math.abs(x-c) > 9 or y > 486) and 1 or 0 end)
work(sides, {hand="detail", tool={kind="filbert", width=2.2}, pile=TAB_D, coverage=3, fill=true, angle=math.pi/2, length={5,14}, clip=sides})
local CROSS = pile{{"lead white",2},{"chrome yellow",0.6},{"lemon chrome",0.2}}
local cr = ribbon({{389,450},{389.2,465},{389.4,481}}, 2.6) + ribbon({{381,459.5},{389,459.3},{397,459.1}}, 2.4)
work(cr, {hand="detail", tool={kind="round", width=1.2}, pile=CROSS, coverage=4, fill=true, clip=cr})
-- far sunlight rims the contour that faces the Sun (up and to the right)
local RIMC = pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25}}
local edge = FIG * mask(function(x,y) if x < 340 or x > 445 or y < 395 or y > 500 then return 0 end return (FIG:at(x+1.3, y-1.0) < 0.5) and 1 or 0 end)
local nz = noise{seed=5, period=8, octaves=2}
edge = edge * mask(function(x,y) return nz(x,y) > -0.5 and 1 or 0 end)
work(edge, {hand="detail", tool={kind="round", width=0.9, point=0.5}, pile=RIMC, coverage=3, fill=true, clip=edge, pressure={0.3,0.6}})
-- Ratio's light on the near hand
local handlit = FIGP.hand * mask(function(x,y) return (x > 434.5 or y > 495.3) and 1 or 0 end) * FIG:shrink(0.2)
work(handlit, {hand="detail", tool={kind="round", width=1.1, point=0.5}, pile=LP1, coverage=3, fill=true, clip=handlit})
-- the sail: the Sun's reflection as one hot streak; a few panel seams
local r = brush{kind="rigger", width=2.2, point=1}
local HOT = pile{{"zinc white",4},{"lemon chrome",0.25}}
for _,o in ipairs({0, -2.2, 2.0}) do
  local pts = {}
  for i=0,10 do local y = 150 + 215*i/10; pts[#pts+1] = {712 + 0.05*(y-250) + o, y} end
  r:reload(HOT, 0.8); r:stroke(pts, {pressure={0.15, 0.15}, swell={0.3,0.8,1.2,1.5,1.2,0.8,0.3}, clip=SAILQ})
end
local sm = brush{kind="round", width=0.8, point=0.6}
local SEAM = pile{{"ultramarine blue",1},{"bone black",0.8},{"ultramarine ash",0.4}}
for _,x in ipairs({632, 656, 681, 744, 768, 789}) do
  local y0 = 131 - (x-599)*0.155
  local y1 = 377 + (x-613)*0.135
  sm:reload(SEAM, 0.6); sm:stroke({{x, y0+3}, {x+0.6, (y0+y1)/2}, {x+1.0, y1-3}}, {pressure={0.22,0.18}, clip=SAILQ})
end

--@ chunk 12
-- the sail again, over dry paint: a silver-blue mirror with one steady band of reflected sunlight
local S = SAILQ * poly({{599,132},{700,116},{805,100},{800,250},{797,402},{705,391},{613,377},{607,250}}) - MASTM:grow(0.5)
local function u(x,y) return math.abs(x - (712 + 0.04*(y-250))) end
local SP = {
  {0, 7, pile{{"zinc white",2},{"lead white",2},{"lemon chrome",0.35}}},
  {7, 20, pile{{"lead white",3},{"chrome yellow",0.45},{"ultramarine ash",0.6}}},
  {20, 42, pile{{"ultramarine ash",1},{"lead white",0.6},{"raw sienna",0.15},{"ultramarine blue",0.2}}},
  {42, 72, pile{{"ultramarine blue",1},{"ultramarine ash",1.1},{"bone black",0.3},{"lead white",0.3}}},
  {72, 999, pile{{"ultramarine blue",1},{"ultramarine ash",0.7},{"bone black",0.55},{"lead white",0.18}}},
}
for _,s in ipairs(SP) do
  local m = mask(function(x,y) local d = u(x,y); return (d>=s[1] and d<s[2]) and 1 or 0 end) * S
  work(m, {hand="body", tool={kind="filbert", width=4}, pile=s[3], coverage=3.6, fill=true, angle=math.pi/2, length={30,80}, clip=S})
end
blend(mask(function(x,y) local d = u(x,y); for _,c in ipairs({7,20,42,72}) do if math.abs(d-c)<3.5 then return 1 end end return 0 end) * S:shrink(1.5), {angle=0, tool={kind="badger", width=6}})

--@ chunk 13
local S = SAILQ * poly({{599,132},{700,116},{805,100},{800,250},{797,402},{705,391},{613,377},{607,250}}) - MASTM:grow(0.5)
local function u(x,y) return math.abs(x - (712 + 0.04*(y-250))) end
blend(mask(function(x,y) local d = u(x,y); for _,c in ipairs({7,20,42,72}) do if math.abs(d-c)<7 then return 1 end end return 0 end) * S:shrink(1.5), {angle=0, tool={kind="badger", width=10}})
-- lift the dark collar out of the corona
local sky = above(hz)
local KR = pile{{"ultramarine blue",1},{"bone black",0.55},{"lead white",0.32},{"cobalt violet",0.12}}
local ring = (ellipse(SUNX,SUNY,76,76) - ellipse(SUNX,SUNY,44,44)) * sky
work(ring, {hand="body", tool={kind="filbert", width=5}, pile=KR, coverage=3, fill=true, angle=function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end, length={10,35}, clip=ring})
blend((ellipse(SUNX,SUNY,82,82) - ellipse(SUNX,SUNY,70,70)) * sky, {angle=function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end, tool={kind="badger", width=10}})
blend((ellipse(SUNX,SUNY,50,50) - ellipse(SUNX,SUNY,38,38)) * sky, {angle=function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end, tool={kind="badger", width=8}})

--@ chunk 14
local sky = above(hz)
local tg = function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end
local rd = function(x,y) return math.atan(y-SUNY,x-SUNX) end
blend((ellipse(SUNX,SUNY,96,96) - ellipse(SUNX,SUNY,62,62)) * sky, {angle=rd, tool={kind="badger", width=14}})
blend((ellipse(SUNX,SUNY,90,90) - ellipse(SUNX,SUNY,66,66)) * sky, {angle=tg, tool={kind="badger", width=14}})
print(wait(2*24*60))
local r = brush{kind="rigger", width=2.0, point=1}
local HOT = pile{{"zinc white",4},{"lemon chrome",0.25}}
for _,o in ipairs({0, -2.0, 2.2, -4.5}) do
  local pts = {}
  for i=0,10 do local y = 140 + 240*i/10; pts[#pts+1] = {712 + 0.04*(y-250) + o, y} end
  r:reload(HOT, 0.85); r:stroke(pts, {pressure={0.2, 0.2}, swell={0.3,0.8,1.2,1.6,1.3,0.9,0.4}, clip=SAILQ})
end
-- the Sun's core restated, and its short rays
work(ellipse(SUNX, SUNY, 4.5, 4.5), {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=4, fill=true, clip=true})
local rr = brush{kind="rigger", width=1.0, point=1}
for i,a in ipairs({0.2, 1.0, 1.8, 2.6, 3.4, 4.2, 5.0, 5.8}) do
  local L = (i%2==1) and rand(40,58) or rand(20,30)
  rr:reload(HOT, 0.5)
  rr:stroke({{SUNX+6*math.cos(a), SUNY+6*math.sin(a)}, {SUNX+L*math.cos(a), SUNY+L*math.sin(a)}}, {pressure={0.35,0.0}, ramps={0.05,0.9}})
end

--@ chunk 15
-- the halo spread too far: bring the sky back in from outside, graded, along the circles
local sky = above(hz)
local tg = function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local KM = pile{{"ultramarine blue",1},{"bone black",0.72},{"lead white",0.25},{"cobalt violet",0.06},{"burnt sienna",0.07}}
local r1 = (ellipse(SUNX,SUNY,82,82) - ellipse(SUNX,SUNY,60,60)) * sky
local r2 = (ellipse(SUNX,SUNY,108,108) - ellipse(SUNX,SUNY,82,82)) * sky
work(r1, {hand="body", tool={kind="filbert", width=5}, pile=KM, coverage=3.2, fill=true, angle=tg, length={12,40}, clip=r1})
work(r2, {hand="body", tool={kind="filbert", width=6}, pile=K4b, coverage=3.4, fill=true, angle=tg, length={15,50}, clip=r2})
for _,r in ipairs({60, 82, 108}) do
  blend((ellipse(SUNX,SUNY,r+4,r+4) - ellipse(SUNX,SUNY,r-4,r-4)) * sky, {angle=tg, tool={kind="badger", width=6}})
end

--@ chunk 16
-- more of the sky's stars, brighter, thinning toward the horizon
local sky = above(hz)
local free = sky - ellipse(SUNX, SUNY, 112, 112) - below(function(x) return hz(x)-5 end) - SAILQ:grow(3) - MASTM:grow(2) - FIG:grow(2)
local ST = {pile{{"zinc white",3},{"lead white",1}}, pile{{"zinc white",2},{"cerulean blue",0.5}}, pile{{"lead white",3},{"chrome yellow",0.35}}, pile{{"lead white",2},{"vermilion",0.25}}}
local sb = brush{kind="round", width=1.3, point=0.8}
local n = 0
for i=1,2000 do
  local x, y = rand(2, 998), rand(2, 430)
  if free:at(x,y) > 0.5 and math.random() < 1.15 - y/430 then
    sb:reload(ST[math.random(1,4)], 0.6)
    sb:touch(x, y, {pressure=(math.random()<0.1) and rand(0.45,0.65) or rand(0.18,0.32)})
    n = n + 1
  end
  if n > 420 then break end
end
local rr = brush{kind="rigger", width=0.8, point=1}
for _,p in ipairs({{120,60},{262,170},{905,42},{560,96},{58,300},{930,250},{330,30}}) do
  if free:at(p[1],p[2]) > 0.5 then
    rr:reload(ST[1], 0.6)
    rr:stroke({{p[1]-5,p[2]},{p[1]+5,p[2]}}, {pressure={0.25,0.25}, swell={0.2,1,0.2}})
    rr:stroke({{p[1],p[2]-5},{p[1],p[2]+5}}, {pressure={0.25,0.25}, swell={0.2,1,0.2}})
    sb:reload(ST[1], 0.8); sb:touch(p[1], p[2], {pressure=0.6})
  end
end
print(n)

--@ chunk 17
print(wait(60))

--@ chunk 18
-- pass: the corona as one soft glow. Radial strokes graded by distance, then fused along the radius only.
local sky = above(hz)
local rd = function(x,y) return math.atan(y-SUNY,x-SUNX) end
local tg = function(x,y) return math.atan(y-SUNY,x-SUNX)+math.pi/2 end
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local Z = {
  {5, 10, pile{{"zinc white",2},{"lead white",2},{"cerulean blue",0.15},{"lemon chrome",0.1}}},
  {10, 18, pile{{"lead white",2},{"zinc white",0.5},{"ultramarine blue",0.35},{"cerulean blue",0.2}}},
  {18, 28, pile{{"lead white",1},{"ultramarine blue",0.6},{"bone black",0.15}}},
  {28, 42, pile{{"ultramarine blue",1},{"lead white",0.55},{"bone black",0.45}}},
  {42, 60, pile{{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.3},{"cobalt violet",0.05}}},
  {60, 118, K4b},
}
for _,z in ipairs(Z) do
  local m = (ellipse(SUNX,SUNY,z[2],z[2]) - ellipse(SUNX,SUNY,z[1],z[1])) * sky
  work(m, {hand="body", tool={kind="filbert", width=(z[1]<20) and 2.5 or 5}, pile=z[3], coverage=3.4, fill=true, angle=rd, length={6,24}, clip=m, edge=(z[2]==118) and "soft" or nil})
end
blend((ellipse(SUNX,SUNY,72,72) - ellipse(SUNX,SUNY,6,6)) * sky, {angle=rd, tool={kind="badger", width=10}})
blend((ellipse(SUNX,SUNY,123,123) - ellipse(SUNX,SUNY,112,112)) * sky, {angle=tg, tool={kind="badger", width=6}})

--@ chunk 19
print(wait(3*24*60)); print(drying(SUNX+30,SUNY), drying(SUNX+90,SUNY))
local sky = above(hz)
local rd = function(x,y) return math.atan(y-SUNY,x-SUNX) end
local K2 = pile{{"bone black",1.2},{"ultramarine blue",1},{"rose madder",0.2}}
local K4b = pile{{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.18},{"burnt sienna",0.15},{"rose madder",0.1}}
local outer = (ellipse(SUNX,SUNY,128,128) - ellipse(SUNX,SUNY,44,44)) * sky
work(outer * above(function(x) return 250 end), {hand="body", tool={kind="filbert", width=6}, pile=K2, coverage=3.6, fill=true, angle=rd, length={15,40}, clip=outer, edge="soft"})
work(outer * below(function(x) return 250 end), {hand="body", tool={kind="filbert", width=6}, pile=K4b, coverage=3.6, fill=true, angle=rd, length={15,40}, clip=outer, edge="soft"})
local Z = {
  {0, 9, pile{{"zinc white",2},{"lead white",2},{"cerulean blue",0.15},{"lemon chrome",0.1}}},
  {9, 17, pile{{"lead white",2},{"zinc white",0.5},{"ultramarine blue",0.35},{"cerulean blue",0.2}}},
  {17, 28, pile{{"lead white",1},{"ultramarine blue",0.6},{"bone black",0.15}}},
  {28, 44, pile{{"ultramarine blue",1},{"lead white",0.4},{"bone black",0.6}}},
}
for _,z in ipairs(Z) do
  local m = (ellipse(SUNX,SUNY,z[2],z[2]) - ellipse(SUNX,SUNY,z[1],z[1])) * sky
  work(m, {hand="body", tool={kind="filbert", width=2.5}, pile=z[3], coverage=3.6, fill=true, angle=rd, length={5,16}, clip=m})
end
for _,r in ipairs({9, 17, 28, 44}) do
  blend((ellipse(SUNX,SUNY,r+3.5,r+3.5) - ellipse(SUNX,SUNY,r-3.5,r-3.5)) * sky, {angle=rd, tool={kind="badger", width=5}})
end

--@ chunk 20
-- the sail as a smoother mirror: long full-height strokes in graded silver-blue, seams fused across
SAILS = poly({{599,132},{700,116},{805,100},{800,250},{797,402},{705,391},{613,377},{607,250}}) * SAILQ - MASTM:grow(0.5)
local function u(x,y) return math.abs(x - (712 + 0.04*(y-250))) end
local SP = {
  {0, 9, pile{{"lead white",3},{"zinc white",1},{"lemon chrome",0.2},{"ultramarine ash",0.3}}},
  {9, 22, pile{{"lead white",2},{"ultramarine ash",1},{"chrome yellow",0.15}}},
  {22, 38, pile{{"ultramarine ash",1.2},{"lead white",0.7},{"ultramarine blue",0.2}}},
  {38, 58, pile{{"ultramarine ash",1},{"ultramarine blue",0.45},{"lead white",0.45},{"bone black",0.1}}},
  {58, 80, pile{{"ultramarine blue",1},{"ultramarine ash",1},{"bone black",0.3},{"lead white",0.3}}},
  {80, 999, pile{{"ultramarine blue",1},{"ultramarine ash",0.7},{"bone black",0.5},{"lead white",0.2}}},
}
for _,s in ipairs(SP) do
  local m = mask(function(x,y) local d = u(x,y); return (d>=s[1] and d<s[2]) and 1 or 0 end) * SAILS
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=s[3], coverage=3.8, fill=true, angle=math.pi/2, length={120,260}, angle_jitter=0.01, clip=SAILS})
end
blend(mask(function(x,y) local d = u(x,y); for _,c in ipairs({9,22,38,58,80}) do if math.abs(d-c)<6 then return 1 end end return 0 end) * SAILS:shrink(1.5), {angle=0, tool={kind="badger", width=8}})
-- the cold rim only where the frame faces the Sun (up and to the right); put the far side back into the dark
local band = FIG - FIG:shrink(1.3)
local away = band * mask(function(x,y) return ((x < 392 and y > 419) or y > 487) and 1 or 0 end) - FIGP.hand
work(away, {hand="detail", tool={kind="round", width=1.0, point=0.5}, pile=FIG_DK, coverage=4, fill=true, clip=away})

--@ chunk 21
print(wait(2*24*60)); print(drying(712,250), drying(SUNX+20,SUNY), drying(380,460))
-- one long clean blaze down the mirror
local r = brush{kind="rigger", width=2.4, point=1}
local HOT = pile{{"zinc white",4},{"lemon chrome",0.2}}
for _,o in ipairs({0, 1.6}) do
  local pts = {}
  for i=0,12 do local y = 128 + 262*i/12; pts[#pts+1] = {712 + 0.04*(y-250) + o, y} end
  r:reload(HOT, 0.9); r:stroke(pts, {pressure={0.3, 0.3}, swell={0.2,0.6,1,1.3,1.5,1.3,1,0.6,0.2}, clip=SAILS})
end
-- crisp edges: the film's taped hem, lit along the top and the Sun side
local e = brush{kind="round", width=1.1, point=0.5}
local HEM = pile{{"lead white",2},{"ultramarine ash",1}}
local HEMD = pile{{"ultramarine blue",1},{"bone black",1}}
e:reload(HEM, 0.7); e:stroke({{600,133.5},{700,117.5},{804,101.5}}, {pressure={0.3,0.3}})
e:reload(HEMD, 0.7); e:stroke({{614,376},{705,389.5},{796,400.5}}, {pressure={0.35,0.35}})
e:reload(HEMD, 0.7); e:stroke({{599.5,134},{604,250},{613.5,376}}, {pressure={0.3,0.3}})
-- rigging: sheets and stays
local function line(a, b, sag, w)
  local pts = {}
  for i=0,14 do local t=i/14; pts[#pts+1] = {a[1]+(b[1]-a[1])*t, a[2]+(b[2]-a[2])*t + sag*4*t*(1-t)} end
  local rb = brush{kind="round", width=w, point=0.6}
  rb:reload(MAST_DK, 0.9); rb:stroke(pts, {pressure={0.32,0.28}})
end
line({600,132}, {806,48}, 5, 0.8)
line({613,378}, {655,452}, 2, 0.8)
line({797,402}, {842,512}, 2, 0.8)
line({596,130}, {560,447}, 8, 0.7)
-- the Sun: core restated and a few long thin rays over the quieter glow
work(ellipse(SUNX, SUNY, 4.6, 4.6), {hand="detail", pile=pile{{"zinc white",4},{"lemon chrome",0.15}}, coverage=4, fill=true, clip=true})
local rr = brush{kind="rigger", width=0.9, point=1}
for i,a in ipairs({0.12, 0.92, 1.6, 2.35, 3.25, 4.05, 4.75, 5.5}) do
  local L = (i%2==1) and rand(62,85) or rand(22,32)
  rr:reload(HOT, 0.5)
  rr:stroke({{SUNX+5*math.cos(a), SUNY+5*math.sin(a)}, {SUNX+L*math.cos(a), SUNY+L*math.sin(a)}}, {pressure={0.3,0.0}, ramps={0.05,0.92}})
end

--@ chunk 22
-- the sail as a smoother mirror: long full-height strokes in graded silver-blue, seams fused across
print(wait(3*24*60))
SAILS = poly({{599,132},{700,116},{805,100},{800,250},{797,402},{705,391},{613,377},{607,250}}) * SAILQ - MASTM:grow(0.5)
local function u(x,y) return math.abs(x - (712 + 0.04*(y-250))) end
local SP = {
  {0, 9, pile{{"lead white",3},{"zinc white",1},{"lemon chrome",0.2},{"ultramarine ash",0.3}}},
  {9, 22, pile{{"lead white",2},{"ultramarine ash",1},{"chrome yellow",0.15}}},
  {22, 38, pile{{"ultramarine ash",1.2},{"lead white",0.7},{"ultramarine blue",0.2}}},
  {38, 58, pile{{"ultramarine ash",1},{"ultramarine blue",0.45},{"lead white",0.45},{"bone black",0.1}}},
  {58, 80, pile{{"ultramarine blue",1},{"ultramarine ash",1},{"bone black",0.3},{"lead white",0.3}}},
  {80, 999, pile{{"ultramarine blue",1},{"ultramarine ash",0.7},{"bone black",0.5},{"lead white",0.2}}},
}
for _,s in ipairs(SP) do
  local m = mask(function(x,y) local d = u(x,y); return (d>=s[1] and d<s[2]) and 1 or 0 end) * SAILS
  work(m, {hand="body", tool={kind="flat", width=6}, pile=s[3], coverage=5, fill=true, angle=math.pi/2, length={150,280}, ruler=true, mix_jitter=0, clip=SAILS})
end
blend(mask(function(x,y) local d = u(x,y); for _,c in ipairs({9,22,38,58,80}) do if math.abs(d-c)<6 then return 1 end end return 0 end) * SAILS:shrink(1.5), {angle=0, tool={kind="badger", width=8}})
print(wait(3*24*60))
-- one long clean blaze down the mirror
local r = brush{kind="rigger", width=2.4, point=1}
local HOT = pile{{"zinc white",4},{"lemon chrome",0.2}}
for _,o in ipairs({0, 1.6}) do
  local pts = {}
  for i=0,12 do local y = 128 + 262*i/12; pts[#pts+1] = {712 + 0.04*(y-250) + o, y} end
  r:reload(HOT, 0.9); r:stroke(pts, {pressure={0.3, 0.3}, swell={0.2,0.6,1,1.3,1.5,1.3,1,0.6,0.2}, clip=SAILS})
end
-- crisp edges: the film's taped hem, lit along the top and the Sun side
local e = brush{kind="round", width=1.1, point=0.5}
local HEM = pile{{"lead white",2},{"ultramarine ash",1}}
local HEMD = pile{{"ultramarine blue",1},{"bone black",1}}
e:reload(HEM, 0.7); e:stroke({{600,133.5},{700,117.5},{804,101.5}}, {pressure={0.3,0.3}})
e:reload(HEMD, 0.7); e:stroke({{614,376},{705,389.5},{796,400.5}}, {pressure={0.35,0.35}})
e:reload(HEMD, 0.7); e:stroke({{599.5,134},{604,250},{613.5,376}}, {pressure={0.3,0.3}})
