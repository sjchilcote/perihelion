-- easel session "crew_rite": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=1.6, linen=18, seed=4407,
  ground={{pile={{"bone black",1.4},{"ultramarine ash",0.8},{"viridian",0.2},{"lead white",0.2}}, um=120, apply="knife", texture=0.3}}}
function hw(y) local d = y-300; if d > 0 then return 55 + 0.00563*d*d else return 55 + 0.00328*d*d end end
local L, R = {}, {}
for y=-5,630,5 do L[#L+1] = {500-hw(y), y}; R[#R+1] = {500+hw(y), y} end
local pts = {}
for i=1,#L do pts[#pts+1] = L[i] end
for i=#R,1,-1 do pts[#pts+1] = R[i] end
BAND = poly(pts)
LWALL = mask(function(x,y) return x < 500 - hw(y) and 1 or 0 end)
RWALL = mask(function(x,y) return x > 500 + hw(y) and 1 or 0 end)
VP = poly({{60,150},{290,175},{300,420},{50,455}}, true)
DK = pile{{"bone black",1.5},{"ultramarine ash",0.6},{"bone brown",0.2},{"lead white",0.04}}
FLD = pile{{"bone black",1.5},{"bone brown",0.6},{"ultramarine ash",0.3},{"lead white",0.03}}
work((LWALL + RWALL) - VP:grow(9), {hand="body", pile=DK, coverage=3.4, fill=true, clip=true, angle=1.5708})
work(BAND, {hand="body", pile=FLD, coverage=3.4, fill=true, clip=true, angle=0})
local SPc = pile{{"bone black",2},{"ultramarine blue",1}}
local SPl = pile{{"ultramarine blue",1},{"bone black",0.8},{"lead white",0.3}}
work(VP:grow(9), {hand="body", tool="filbert 6", pile=SPc, coverage=4, fill=true, clip=true, angle=0.3})
work(VP * ellipse(170, 300, 95, 95), {hand="body", tool="filbert 5", pile=SPl, coverage=3, fill=true, clip=true, angle=0.3})

--@ chunk 2
blend(VP * (ellipse(170,300,108,108) - ellipse(170,300,80,80)), {tool={kind="badger", width=10}})
print(wait(2*24*60))
function yt(t) if t >= 0 then return 300 + 325*t^1.7 else return 300 - 300*(-t)^1.7 end end
local TRAY = pile{{"lead white",0.2},{"bone black",1.4},{"ultramarine ash",0.8}}
local SOIL = pile{{"bone brown",1},{"bone black",1},{"burnt sienna",0.2}}
BEDS = {}
local ts = {}
for k=1,10 do ts[#ts+1] = 0.03 + (k-1)*0.105 end
for k=1,10 do ts[#ts+1] = -(0.03 + (k-1)*0.105) end
for _,t in ipairs(ts) do
  local y = yt(t)
  local dy = math.abs(yt(t + 0.05) - yt(t - 0.05))
  local h = math.max(2.5, dy*0.55)
  local w = hw(y)*0.74
  if y > -20 and y < 650 then
    local up = t >= 0
    local soil = rect(500-w, y-h/2, 2*w, h)
    local lipH = math.max(1.5, h*0.35)
    local lip = up and rect(500-w, y+h/2, 2*w, lipH) or rect(500-w, y-h/2-lipH, 2*w, lipH)
    local tool = (h > 8) and "round 3" or "round 1.4"
    work(soil, {hand="detail", tool=tool, pile=SOIL, coverage=4, fill=true, clip=true, angle=0})
    work(lip, {hand="detail", tool=tool, pile=TRAY, coverage=4, fill=true, clip=true, angle=0})
    BEDS[#BEDS+1] = {t=t, y=y, h=h, w=w, up=up, lipH=lipH}
  end
end
print(#BEDS)

--@ chunk 3
print(wait(4*24*60))
-- withered crop: dry stalks and curled dead leaves, low and sparse
local ST = pile{{"bone brown",1},{"raw sienna",0.5},{"bone black",0.7}}
local SL = pile{{"raw sienna",0.7},{"bone brown",0.6},{"bone black",0.4},{"lead white",0.1}}
for _,B in ipairs(BEDS) do
  local n = math.floor(B.w / math.max(4, B.h*0.9))
  local s = math.max(0.4, math.min(2.2, B.h*0.16))
  local b = brush{kind="rigger", width=s, point=1}
  for i = 1, n do
    local x = 500 - B.w*0.95 + 2*B.w*0.95*rand(0,1)
    local hgt = B.h*rand(0.8, 2.2)
    local base = B.up and (B.y - B.h*0.3) or (B.y + B.h*0.3)
    local dir = B.up and -1 or 1
    local lean = rand(-0.6, 0.6)*hgt
    b:reload((i % 3 == 0) and SL or ST, 0.8)
    b:stroke({{x, base}, {x + lean*0.4, base + dir*hgt*0.6}, {x + lean, base + dir*hgt*0.85}}, {pressure={0.5, 0.15}})
  end
end
-- dead lamps: housings with dark lenses, the near and the overhead
local HOUS = pile{{"bone black",1.6},{"ultramarine ash",0.8},{"lead white",0.1}}
local DEAD = pile{{"bone black",1.2},{"cobalt violet",0.3},{"ultramarine ash",0.3},{"lead white",0.1}}
local ROD = pile{{"bone black",1.5},{"ultramarine ash",0.6}}
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.4", pile=p, coverage=4.5, fill=true, clip=true, angle=0}) end
for _,Lm in ipairs({{x0=438, x1=562, y=362, hh=6, lh=4, down=false}, {x0=470, x1=530, y=326, hh=3, lh=2.5, down=false}, {x0=414, x1=586, y=158, hh=7, lh=5, down=true}, {x0=450, x1=550, y=228, hh=4, lh=3, down=true}}) do
  local w = Lm.x1 - Lm.x0
  local hs, ln
  if Lm.down then hs = rect(Lm.x0, Lm.y + Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 2, Lm.y, w - 4, Lm.lh)
  else hs = rect(Lm.x0, Lm.y - Lm.hh - Lm.lh, w, Lm.hh); ln = rect(Lm.x0 + 2, Lm.y - Lm.lh, w - 4, Lm.lh) end
  local rb = brush{kind="round", width=math.max(1, Lm.hh*0.18), point=0.3}
  for _,x in ipairs({Lm.x0 + w*0.12, Lm.x1 - w*0.12}) do
    rb:reload(ROD, 0.9)
    if Lm.down then rb:stroke({{x, Lm.y + Lm.lh + Lm.hh}, {x + (500-x)*0.1, Lm.y + Lm.lh + Lm.hh + 45}}, {pressure={0.7,0.7}})
    else rb:stroke({{x, Lm.y - Lm.lh - Lm.hh}, {x + (500-x)*0.1, Lm.y - Lm.lh - Lm.hh - math.min(55, w*0.4)}}, {pressure={0.7,0.7}}) end
  end
  fill(hs, HOUS, "round 2")
  fill(ln, DEAD)
end
-- window mullions and the far Sun
local MU = pile{{"bone black",1.4},{"ultramarine ash",0.7},{"lead white",0.12}}
local mb = brush{kind="filbert", width=6, stiffness=0.6}
for _, s in ipairs({{{140, 152}, {134, 450}}, {{222, 162}, {220, 440}}, {{48, 245}, {298, 249}}, {{48, 345}, {300, 342}}}) do mb:reload(MU, 0.9) mb:stroke(s, {pressure={0.8, 0.8}, clip=VP:grow(9)}) end
local rim = brush{kind="rigger", width=2.6, point=1}
local rp = {} for k = 0, 40 do local t = k/40*2*math.pi rp[#rp+1] = {175 + 128*math.cos(t)*(1 + 0.04*math.cos(4*t)), 302 + 150*math.sin(t)*(1 + 0.04*math.cos(4*t))} end
local SUN = pile{{"zinc white",4},{"lemon chrome",0.2}}
local sb = brush{kind="round", width=6, point=0.3}
sb:load(SUN, 0.95) sb:touch(178, 292, {pressure=0.8})
local f = brush{kind="rigger", width=0.8, point=1}
f:load(SUN, 0.9) f:stroke({{160, 294}, {178, 292}, {196, 290}}, {pressure={0, 0.5, 0}, swell={0.1, 1, 0.1}})
f:load(SUN, 0.9) f:stroke({{179, 276}, {178, 292}, {177, 308}}, {pressure={0, 0.45, 0}, swell={0.1, 1, 0.1}})

--@ chunk 4
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
CTOP = poly({{424, 438}, {586, 438}, {596, 452}, {414, 452}})
CFRONT = rect(414, 452, 182, 40)
CSHELF = rect(420, 478, 170, 4)
WHEELS = ellipse(430, 500, 8, 8) + ellipse(580, 500, 8, 8)
local CART = pile{{"bone black",1.6},{"ultramarine ash",0.7},{"lead white",0.1}}
local CARTD = pile{{"bone black",2},{"ultramarine ash",0.4}}
fill(CTOP, CART) fill(CFRONT, CARTD) fill(WHEELS, CARTD) fill(CSHELF, CART, "round 1.4")
-- cart shadow on the deck
local sh = ellipse(505, 500, 110, 10) - WHEELS
fill(sh, pile{{"bone black",2.2},{"bone brown",0.3}}, "round 2")
-- the Commando kneeling before the cart, back to us, helm bowed: plates
FB = {458, 616}
local S = 0.62
function P(u, v) return {FB[1] + u*S, FB[2] - v*S} end
function pp(t) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, true) end
FP = {
 shinL = {{-48, -6}, {-6, -10}, {-4, 12}, {-46, 16}},
 bootL = {{-62, -8}, {-44, -8}, {-44, 18}, {-60, 14}},
 thighR = {{6, 4}, {34, 2}, {38, 70}, {8, 72}},
 shinR = {{4, -10}, {40, -12}, {38, 6}, {6, 8}},
 kneeL = {{-50, 2}, {-30, -2}, {-26, 30}, {-46, 32}},
 cuisseL = {{-44, 20}, {-12, 18}, {-6, 74}, {-36, 76}},
 faulds = {{-40, 66}, {40, 66}, {36, 94}, {-36, 94}},
 torso = {{-38, 90}, {38, 90}, {44, 158}, {-44, 156}},
 paulL = {{-62, 132}, {-38, 126}, {-26, 156}, {-40, 168}, {-62, 160}},
 paulR = {{34, 128}, {58, 132}, {62, 160}, {46, 170}, {26, 156}},
 armL = {{-60, 96}, {-42, 96}, {-38, 132}, {-58, 134}},
 armR = {{40, 94}, {58, 96}, {60, 132}, {42, 132}},
 gorget = {{-16, 152}, {16, 152}, {14, 166}, {-14, 166}},
 helm = {{-18, 160}, {16, 160}, {20, 176}, {14, 192}, {-12, 194}, {-20, 178}},
}
FORD = {"bootL","shinL","shinR","thighR","kneeL","cuisseL","faulds","torso","armL","armR","paulL","paulR","gorget","helm"}
local m = nil
for _, k in ipairs(FORD) do local q = pp(FP[k]) m = m and (m + q) or q end
FIG = m
local FC = pile{{"bone black",2.2},{"ultramarine blue",0.35},{"lead white",0.08}}
fill(FIG, FC, "round 1.6")

--@ chunk 5
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.6", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
FB = {470, 618}
function P(u, v) return {FB[1] + u, FB[2] - v} end
function pp(t) local o = {} for _, q in ipairs(t) do o[#o+1] = P(q[1], q[2]) end return poly(o, true) end
FP = {
 bootL = {{-50, 0}, {-18, 0}, {-16, 22}, {-48, 24}},
 bootR = {{18, 2}, {52, 0}, {50, 24}, {16, 22}},
 calfL = {{-46, 20}, {-18, 20}, {-16, 40}, {-44, 42}},
 calfR = {{16, 20}, {48, 20}, {46, 42}, {14, 40}},
 haunch = {{-54, 34}, {54, 34}, {50, 74}, {-50, 74}},
 faulds = {{-50, 68}, {50, 68}, {46, 98}, {-46, 98}},
 torso = {{-46, 94}, {46, 94}, {52, 168}, {-52, 168}},
 armL = {{-70, 104}, {-50, 100}, {-46, 152}, {-66, 154}},
 gauntL = {{-76, 80}, {-56, 80}, {-52, 106}, {-72, 108}},
 armR = {{50, 100}, {70, 104}, {66, 154}, {46, 152}},
 paulL = {{-74, 150}, {-44, 144}, {-30, 174}, {-46, 186}, {-74, 178}},
 paulR = {{42, 144}, {72, 150}, {74, 178}, {46, 186}, {30, 174}},
 gorget = {{-18, 162}, {18, 162}, {16, 174}, {-16, 174}},
 helm = {{-22, 164}, {22, 164}, {26, 182}, {18, 200}, {-18, 200}, {-26, 182}},
}
FORD = {"bootL","bootR","calfL","calfR","haunch","faulds","torso","armL","gauntL","armR","paulL","paulR","gorget","helm"}
local m = nil
for _, k in ipairs(FORD) do local q = pp(FP[k]) m = m and (m + q) or q end
FIG2 = m
-- the old small figure painted out where the new one does not cover it
local old = FIG:grow(1.5) - FIG2
work(old * BAND, {hand="detail", tool="round 1.6", pile=FLD, coverage=4.5, fill=true, clip=old * BAND, angle=0})
local FC = pile{{"bone black",2.2},{"ultramarine blue",0.35},{"lead white",0.08}}
fill(FIG2, FC)

--@ chunk 6
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 2", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
local CART = pile{{"bone black",1.6},{"ultramarine ash",0.7},{"lead white",0.1}}
local CARTD = pile{{"bone black",2},{"ultramarine ash",0.4}}
local ext = poly({{586, 438}, {660, 438}, {670, 452}, {596, 452}})
CTOP2 = poly({{424, 438}, {660, 438}, {670, 452}, {414, 452}}) - FIG2
local front = rect(596, 452, 74, 40)
local w2 = ellipse(655, 500, 8, 8)
fill(ext - FIG2, CART) fill(front, CARTD) fill(w2, CARTD) fill(rect(590, 478, 76, 4), CART, "round 1.4")
-- old right wheel inside the cart's span painted as shelf shadow
fill(ellipse(580, 500, 9, 9) - FIG2, pile{{"bone black",2.2},{"bone brown",0.3}})
fill(ellipse(625, 500, 50, 9) - w2 - FIG2, pile{{"bone black",2.2},{"bone brown",0.3}})

--@ chunk 7
print(wait(4*24*60))
CND = {600, 441}
local WP = {
 pile{{"bone black",1.6},{"bone brown",0.7},{"burnt sienna",0.25},{"lead white",0.08}},
 pile{{"bone black",1.1},{"burnt sienna",0.5},{"Mars orange",0.2},{"lead white",0.15}},
 pile{{"bone black",0.6},{"Mars orange",0.4},{"raw sienna",0.4},{"lead white",0.3}},
 pile{{"Mars orange",0.6},{"yellow ochre",0.4},{"lead white",0.7},{"bone black",0.15}},
}
local region = -(FIG2:grow(0.6)) * (-VP:grow(9))
local cells = {}
for y = 340, 566, 2.6 do for x = 450, 760, 2.8 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if region:at(clamp(xx,0,999), clamp(yy,0,624)) > 0.5 then
    local d = math.sqrt((xx - CND[1])^2 + ((yy - CND[2])*1.5)^2)
    local v = 4.2 - d/30 + randn(0, 0.3)
    if v > 0.8 then cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v), 1, 4)} end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=2.6, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(WP[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(WP[i], 0.9) end
    local h = rand(2, 4)
    b:stroke({{c.x - h, c.y}, {c.x + h, c.y}}, {pressure={0.7, 0.55}, clip=region})
  end
end end
print(#cells)

--@ chunk 8
print(wait(6*24*60), drying(600,441))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.6", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
local notfig = -(FIG2:grow(0.6))
-- the wall beyond a tight radius back to dark
local walls = (LWALL + RWALL) - VP:grow(10)
local outer = walls * notfig * mask(function(x,y) local d = math.sqrt((x - CND[1])^2 + ((y - CND[2])*1.5)^2) return d > 48 and 1 or 0 end)
fill(outer * rect(440, 330, 330, 260), DK, "round 2")
local mid = walls * notfig * mask(function(x,y) local d = math.sqrt((x - CND[1])^2 + ((y - CND[2])*1.5)^2) return (d > 28 and d <= 48) and 1 or 0 end)
fill(mid, pile{{"bone black",1.4},{"bone brown",0.6},{"burnt sienna",0.25},{"ultramarine ash",0.2},{"lead white",0.08}}, "round 2")
-- the cart restated: front face dark, top a lit plane, a bright near edge
local CF = pile{{"bone black",2},{"ultramarine ash",0.4},{"bone brown",0.2}}
fill(rect(414, 454, 256, 38) * notfig, CF, "round 2")
local topL = pile{{"bone black",0.9},{"burnt sienna",0.4},{"Mars orange",0.15},{"lead white",0.22}}
local topH = pile{{"bone black",0.5},{"Mars orange",0.35},{"raw sienna",0.35},{"lead white",0.4}}
CTOPM = poly({{424, 438}, {660, 438}, {670, 452}, {414, 452}}) * notfig
fill(CTOPM, topL, "round 1.6")
fill(CTOPM * ellipse(CND[1], 445, 42, 10), topH, "round 1.4")
fill(rect(590, 478, 76, 3) * notfig, pile{{"bone black",1.4},{"ultramarine ash",0.5},{"lead white",0.15}}, "round 1.2")
fill(ellipse(655, 500, 8, 8), CF, "round 1.4")
fill(ellipse(625, 503, 50, 8) - ellipse(655, 500, 8, 8), pile{{"bone black",2.2},{"bone brown",0.3}}, "round 2")

--@ chunk 9
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.6", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
local notfig = -(FIG2:grow(0.6))
local reg = BAND * rect(450, 340, 260, 97) * notfig
fill(reg, FLD, "round 2")
local soft = pile{{"bone black",1.3},{"burnt sienna",0.45},{"Mars orange",0.15},{"lead white",0.12}}
local s = brush{kind="filbert", width=4, stiffness=0.4}
for k = 1, 22 do
  local x = CND[1] + rand(-45, 45) local y = 436 - rand(2, 22)*(1 - math.abs(x - CND[1])/60)
  s:load(soft, 0.6) s:stroke({{x - 5, y}, {x + 5, y}}, {pressure={0.5, 0.3}, clip=reg})
end
blend(reg * ellipse(CND[1], 425, 60, 20), {angle=0, tool={kind="badger", width=6}, length={10, 20}})

--@ chunk 10
print(wait(6*24*60), drying(600,444))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 0.9", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
local BG = pile{{"bone black",1},{"ultramarine ash",0.5},{"lead white",0.35}}
local BGL = pile{{"lead white",1.2},{"ultramarine ash",0.3},{"Mars orange",0.15},{"bone black",0.3}}
local AMB = pile{{"cadmium yellow",1},{"Mars orange",0.8},{"lead white",0.3}}
local DKB = pile{{"bone black",2.2},{"ultramarine ash",0.3}}
-- seven crew badges laid in a row on the cart, each a small slab with an amber stripe and a dark ID window
for i = 0, 6 do
  local x = 550 + i*12.6 + rand(-0.6, 0.6)
  local slab = poly({{x, 438.5}, {x + 9, 438}, {x + 9.6, 445}, {x - 0.4, 445.5}})
  fill(slab, BG)
  fill(rect(x + 0.6, 441.6, 8.2, 1.4), AMB, "round 0.6")
  fill(rect(x + 2, 438.8, 3.4, 2.2), DKB, "round 0.5")
  local e = brush{kind="rigger", width=0.4, point=1}
  e:load(BGL, 0.9) e:stroke({{x, 438.3}, {x + 9, 437.8}}, {pressure={0.4, 0.4}})
end
-- the watering can, upright again at the right end
local CAN = pile{{"chrome yellow",1.5},{"Mars orange",0.5},{"bone black",0.35}}
local CAND = pile{{"Mars orange",1},{"bone brown",0.8},{"bone black",0.4}}
local CANL = pile{{"chrome yellow",1},{"cadmium yellow",0.5},{"lead white",0.6}}
local body = poly({{644, 444}, {646, 421}, {664, 421}, {666, 444}}, true)
fill(body, CAN, "round 1.2")
fill(poly({{656, 421}, {666, 421}, {666, 444}, {657, 444}}, true), CAND, "round 1")
local sp = brush{kind="round", width=2.4, point=0.4}
sp:load(CAN, 0.9) sp:stroke({{646, 432}, {636, 424}, {630, 416}}, {pressure={0.8, 0.5}})
local hd = brush{kind="rigger", width=1.4, point=1}
hd:load(CAND, 0.9) hd:stroke({{649, 421}, {655, 411}, {662, 421}}, {pressure={0.6, 0.6}})
hd:load(CANL, 0.9) hd:stroke({{646.5, 423}, {645.5, 443}}, {pressure={0.5, 0.5}})
-- a small bone cross propped against the can
local BONE = pile{{"lead white",1.4},{"yellow ochre",0.35},{"raw sienna",0.12},{"bone black",0.15}}
local cr = brush{kind="filbert", width=1.8, stiffness=0.6}
cr:load(BONE, 0.95) cr:stroke({{636, 445}, {642, 418}}, {pressure={0.75, 0.75}})
cr:load(BONE, 0.95) cr:stroke({{633, 426}, {645, 428.5}}, {pressure={0.75, 0.75}})

--@ chunk 11
print(wait(5*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 0.8", pile=p, coverage=4.5, fill=true, clip=m, angle=0}) end
-- the candle-LED, front and centre of the row
local CB = pile{{"lead white",1.6},{"yellow ochre",0.2},{"bone black",0.15}}
fill(rect(597, 438, 6, 9), CB)
local GL = pile{{"Mars orange",0.6},{"cadmium yellow",0.5},{"lead white",1.2}}
local s = brush{kind="filbert", width=1.8, stiffness=0.4}
for k = 0, 17 do
  local a = k/18*2*math.pi
  s:load(GL, 0.6) s:stroke({{600 + math.cos(a)*2.5, 434 + math.sin(a)*3}, {600 + math.cos(a)*8, 434 + math.sin(a)*9}}, {pressure={0.45, 0.05}})
end
local FLM = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.15}}
local f = brush{kind="round", width=2.4, point=0.9}
f:load(FLM, 0.95) f:stroke({{600, 437.5}, {600.2, 433}, {599.8, 429}}, {pressure={0.8, 0.0}})
local HOT = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}}
local h = brush{kind="round", width=1.3, point=0.5}
h:load(HOT, 0.95) h:touch(600, 435, {pressure=0.6})

--@ chunk 12
print(wait(4*24*60), drying(470,500))
-- the candle's glow: the spikes painted down, a soft round warmth instead
local s = brush{kind="filbert", width=3, stiffness=0.4}
local WD = pile{{"bone black",1},{"burnt sienna",0.5},{"Mars orange",0.25},{"lead white",0.2}}
local m = ellipse(600, 433, 11, 11) - rect(596, 437, 8, 11) - ellipse(600, 433, 3, 4)
work(m, {hand="detail", tool="round 1.2", pile=WD, coverage=5, fill=true, clip=m, angle=0})
-- the can trimmed: the dark side wider, a handle and spout in shadow
local CAND = pile{{"Mars orange",0.8},{"bone brown",0.9},{"bone black",0.5}}
work(poly({{652, 420}, {667, 420}, {667, 445}, {654, 445}}, true), {hand="detail", tool="round 1", pile=CAND, coverage=5, fill=true, clip=true, angle=0})
-- plates on the kneeling figure
local JD = pile{{"bone black",2.6},{"ultramarine blue",0.3}}
local MG = pile{{"bone black",1.4},{"ultramarine blue",0.4},{"lead white",0.25}}
local r
local function ln(p, uv, pr_, w) r = brush{kind="rigger", width=w or 0.8, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_, pr_*0.85}, clip=FIG2:grow(0.4)}) end
for _, s2 in ipairs({{{-50, 68}, {50, 68}}, {{-46, 96}, {46, 96}}, {{-52, 166}, {52, 166}}, {{-18, 163}, {18, 163}}, {{-46, 34}, {46, 34}}, {{-46, 22}, {-18, 22}}, {{18, 22}, {48, 22}}}) do ln(JD, s2, 0.6, 1.0) end
for _, v in ipairs({76, 84}) do ln(JD, {{-48, v}, {0, v - 1}, {48, v}}, 0.5, 0.7) end
ln(JD, {{0, 98}, {1, 130}, {0, 164}}, 0.55, 0.9) ln(MG, {{2, 100}, {3, 130}, {2, 162}}, 0.35, 0.6)
for _, o in ipairs({0, 9}) do ln(JD, {{-72, 160 + o}, {-56, 154 + o}, {-36, 160 + o}}, 0.5, 0.8) ln(JD, {{36, 160 + o}, {56, 154 + o}, {72, 160 + o}}, 0.5, 0.8) end
ln(JD, {{-3, 168}, {-2, 184}, {0, 198}}, 0.5, 0.8) ln(MG, {{-1, 170}, {0, 184}, {2, 197}}, 0.35, 0.5)
ln(MG, {{-48, 12}, {-18, 12}}, 0.35, 0.6) ln(MG, {{18, 12}, {50, 12}}, 0.35, 0.6)
-- the dead lamp on the left pauldron
local DL = pile{{"bone black",1.4},{"ultramarine ash",0.4},{"lead white",0.18}}
local q = P(-58, 178)
work(ellipse(q[1], q[2], 4.5, 3.5), {hand="detail", tool="round 0.8", pile=DL, coverage=4.5, fill=true, clip=true, angle=0})

--@ chunk 13
print(wait(6*24*60), drying(470,500))
-- warm rims on the edges that face the candle (front-right), the rest in the dark
local AM = pile{{"Mars orange",0.6},{"burnt sienna",0.3},{"lead white",0.5},{"bone black",0.3}}
local AMH = pile{{"Mars orange",0.5},{"cadmium yellow",0.3},{"lead white",0.9}}
local r
local function rim(p, uv, pr_, w) r = brush{kind="rigger", width=w or 0.9, point=1} local pts = {} for _, q in ipairs(uv) do pts[#pts+1] = P(q[1], q[2]) end r:load(p, 0.9) r:stroke(pts, {pressure={pr_*0.3, pr_, pr_*0.3}}) end
rim(AMH, {{30, 174}, {46, 186}, {74, 178}}, 0.55)
rim(AMH, {{72, 150}, {74, 178}}, 0.5)
rim(AMH, {{18, 200}, {26, 182}, {22, 164}}, 0.6)
rim(AM, {{70, 104}, {66, 152}}, 0.45)
rim(AM, {{46, 94}, {52, 168}}, 0.35)
rim(AM, {{54, 34}, {50, 74}}, 0.4)
rim(AM, {{50, 68}, {46, 98}}, 0.35)
rim(AM, {{52, 0}, {50, 24}}, 0.4)
rim(AM, {{-18, 200}, {18, 200}}, 0.3)
-- the rosary hanging from the left gauntlet, its crucifix catching a little of the light
local BEAD = pile{{"lead white",1},{"yellow ochre",0.3},{"bone black",0.35},{"Mars orange",0.1}}
local CHN = pile{{"bone black",1},{"yellow ochre",0.3},{"lead white",0.2}}
local g0 = P(-66, 80)
local path = {g0, {g0[1] - 2, g0[2] + 9}, {g0[1] - 1, g0[2] + 18}, {g0[1] + 1, g0[2] + 26}}
local c = brush{kind="rigger", width=0.6, point=1}
c:load(CHN, 0.85) c:stroke(path, {pressure={0.35, 0.35}})
local b = brush{kind="round", width=1.8, point=0.4}
for i = 1, #path - 1 do for k = 0, 2 do local t = k/3 local p = {path[i][1] + (path[i+1][1]-path[i][1])*t, path[i][2] + (path[i+1][2]-path[i][2])*t} b:load(BEAD, 0.9) b:touch(p[1], p[2], {pressure=0.45}) end end
local x0, y0 = g0[1] + 1, g0[2] + 27
local cr = brush{kind="filbert", width=1.6, stiffness=0.6}
cr:load(BEAD, 0.95) cr:stroke({{x0, y0}, {x0, y0 + 12}}, {pressure={0.7, 0.7}})
cr:load(BEAD, 0.95) cr:stroke({{x0 - 4, y0 + 4}, {x0 + 4, y0 + 4}}, {pressure={0.7, 0.7}})
-- the candle's last touches: hot core and a soft blended ring on dry paint
local GL = pile{{"Mars orange",0.6},{"burnt sienna",0.3},{"lead white",0.7},{"bone black",0.2}}
local s = brush{kind="filbert", width=2, stiffness=0.4}
for k = 0, 23 do local a = k/24*2*math.pi s:load(GL, 0.55) s:stroke({{600 + math.cos(a)*3, 433 + math.sin(a)*3.5}, {600 + math.cos(a)*7, 433 + math.sin(a)*8}}, {pressure={0.4, 0.05}}) end
blend(ellipse(600, 433, 10, 11) - rect(596, 437, 8, 11), {angle=function(x,y) return math.atan(y - 433, x - 600) end, tool={kind="badger", width=3}, length={4, 8}})

--@ chunk 14
print(wait(4*24*60))
local FLM = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.15}}
local f = brush{kind="round", width=2.4, point=0.9}
f:load(FLM, 0.95) f:stroke({{600, 437.5}, {600.2, 433}, {599.8, 429}}, {pressure={0.8, 0.0}})
local HOT = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}}
local h = brush{kind="round", width=1.3, point=0.5}
h:load(HOT, 0.95) h:touch(600, 435, {pressure=0.6})

--@ chunk 15
print(wait(4*24*60))
local function fill(m, p, t) work(m, {hand="detail", tool=t or "round 1.2", pile=p, coverage=5, fill=true, clip=m, angle=0}) end
-- bowed helm: square top cut back to a dome
local top = pp({{-30, 184}, {30, 184}, {30, 206}, {-30, 206}})
local c = P(0, 182)
local dome = ellipse(c[1], c[2], 22, 15)
fill(top - dome, FLD)
local FC = pile{{"bone black",2.2},{"ultramarine blue",0.35},{"lead white",0.08}}
fill(dome * top, FC)
-- candle glow cut back to a small warm halo
local MIDW = pile{{"bone black",1.2},{"bone brown",0.6},{"burnt sienna",0.35},{"Mars orange",0.1},{"lead white",0.12}}
local halo = ellipse(600, 433, 13, 12) - rect(596, 437, 8, 11)
fill(halo, MIDW)
-- stray yellow spout stroke above the cross
fill(poly({{626, 408}, {642, 408}, {640, 419}, {628, 420}}), MIDW, "round 1")

--@ chunk 16
print(wait(5*24*60))
work(poly({{626, 406}, {644, 406}, {642, 420}, {628, 421}}) - ellipse(600, 433, 14, 13), {hand="detail", tool="round 1", pile=DK, coverage=5, fill=true, clip=true, angle=0})
local G1 = pile{{"bone black",0.9},{"burnt sienna",0.45},{"Mars orange",0.25},{"lead white",0.28}}
local G2 = pile{{"Mars orange",0.6},{"cadmium yellow",0.3},{"lead white",0.8},{"bone black",0.15}}
local s = brush{kind="filbert", width=1.6, stiffness=0.4}
for k = 0, 29 do
  local a = k/30*2*math.pi
  s:load(G1, 0.6) s:stroke({{600 + math.cos(a)*4, 432 + math.sin(a)*4.5}, {600 + math.cos(a)*10, 432 + math.sin(a)*10.5}}, {pressure={0.45, 0.05}, clip=-rect(596, 437, 8, 11)})
  s:load(G2, 0.6) s:stroke({{600 + math.cos(a)*2.2, 432 + math.sin(a)*2.5}, {600 + math.cos(a)*5.5, 432 + math.sin(a)*6}}, {pressure={0.45, 0.05}, clip=-rect(596, 437, 8, 11)})
end

--@ chunk 17
print(wait(5*24*60))
blend(ellipse(600, 432, 11, 11) - rect(596, 437, 8, 11), {angle=function(x,y) return math.atan(y - 432, x - 600) end, tool={kind="badger", width=3}, length={4, 8}})
print(wait(3*24*60))
local FLM = pile{{"lead white",2},{"cadmium yellow",0.7},{"Mars orange",0.15}}
local f = brush{kind="round", width=2.6, point=0.9}
f:load(FLM, 0.95) f:stroke({{600, 437.5}, {600.2, 433}, {599.8, 428.5}}, {pressure={0.85, 0.0}})
local HOT = pile{{"zinc white",2},{"lead white",1},{"cadmium yellow",0.2}}
local h = brush{kind="round", width=1.4, point=0.5}
h:load(HOT, 0.95) h:touch(600, 435, {pressure=0.6})
-- helm dome rim and the bowed brow edge, lit from the candle's side
local AMH = pile{{"Mars orange",0.5},{"cadmium yellow",0.3},{"lead white",0.9}}
local c = P(0, 182)
local pts = {} for k = 0, 10 do local a = -0.2 - k/10*1.2 pts[#pts+1] = {c[1] + 22*math.cos(a), c[2] + 15*math.sin(a)} end
local r = brush{kind="rigger", width=0.9, point=1}
r:load(AMH, 0.9) r:stroke(pts, {pressure={0.15, 0.55, 0.2}})
