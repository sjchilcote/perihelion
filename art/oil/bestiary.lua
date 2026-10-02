-- easel session "bestiary": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=560, aspect=0.75, linen={18,16}, seed=1212, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.25}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
local function flat(m, p, t) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool=t or "filbert 8", angle=0, clip=m, load=1}) end
GOLD = pile{{"cadmium yellow",1.2},{"yellow ochre",1},{"lead white",0.25}}
PAN = { {80,150,410,500}, {510,150,410,500}, {80,670,410,500}, {510,670,410,500} }
local inner = nil
for _,p in ipairs(PAN) do local m = rect(p[1], p[2], p[3], p[4]); inner = inner and (inner + m) or m end
BORD = rect(0,0,1000,1333) - rect(40,40,920,1253)
flat(BORD, pile{{"ultramarine blue",1},{"cobalt blue",0.4},{"lead white",0.3}})
flat(rect(40,40,920,1253) - inner, GOLD)
flat(rect(80,150,410,500) + rect(510,670,410,500), pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.25}})
flat(rect(510,150,410,500) + rect(80,670,410,500), pile{{"cadmium red",1},{"Mars red",0.6},{"rose madder",0.2}})

--@ chunk 3
print(wait(2*24*60))
function F(m, p) work(m, {hand="detail", pile=p, coverage=6, fill=true, clip=m, load=1}); return m end
function P(pts) return poly(pts) end
INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
PALE = pile{{"lead white",2.2},{"cobalt violet",0.25},{"ultramarine ash",0.2}}
VIO = pile{{"cobalt violet",1},{"magenta",0.3},{"lead white",0.6}}
VIOD = pile{{"cobalt violet",1},{"ultramarine blue",0.6},{"bone black",0.2}}
-- diaper: gold dots on every panel ground
local d = brush{kind="round", width=6, point=0}
for _,p in ipairs(PAN) do
  for i=0,8 do for j=0,10 do if (i+j) % 2 == 0 then d:reload(GOLD, 0.6); d:touch(p[1] + 24 + i*45, p[2] + 22 + j*45, {pressure=0.7}) end end end
end
-- I. THE WARDEN: crested shell, many legs, bladed forelimbs
local cx, cy = 285, 360
for i=0,5 do local x = cx - 110 + i*44
  F(P({{x,cy+40},{x+8,cy+40},{x-6+(i-2.5)*6,cy+110},{x-14+(i-2.5)*6,cy+110}}), VIOD)
  F(P({{x-14+(i-2.5)*6,cy+108},{x-6+(i-2.5)*6,cy+108},{x-16+(i-2.5)*8,cy+130}}), VIOD)
end
F(P({{cx-150,cy+50},{cx-130,cy-30},{cx-60,cy-80},{cx+40,cy-90},{cx+130,cy-40},{cx+150,cy+40},{cx+90,cy+60},{cx-90,cy+62}}), VIO)
for k=0,5 do local x = cx - 110 + k*44 -- the shell's segments
  F(P({{x,cy-70+math.abs(k-2.5)*8},{x+6,cy-70+math.abs(k-2.5)*8},{x+10,cy+56},{x+2,cy+56}}), VIOD) end
for k=0,6 do local x = cx - 90 + k*30 -- the crest
  F(P({{x-10,cy-74+math.abs(k-3)*6},{x,cy-130+math.abs(k-3)*14},{x+10,cy-76+math.abs(k-3)*6}}), PALE) end
-- bladed forelimbs and the head
F(P({{cx+130,cy-20},{cx+170,cy-50},{cx+178,cy-40},{cx+140,cy-6}}), VIOD)
F(P({{cx+170,cy-50},{cx+190,cy-150},{cx+180,cy-40}}), PALE)
F(P({{cx+120,cy+10},{cx+170,cy+20},{cx+168,cy+32},{cx+120,cy+26}}), VIOD)
F(P({{cx+166,cy+18},{cx+200,cy-60},{cx+178,cy+28}}), PALE)
F(ellipse(cx+150, cy+4, 18, 14), VIO)
for _,e in ipairs({{cx+150,cy},{cx+160,cy+8},{cx+142,cy+10}}) do F(ellipse(e[1], e[2], 3, 3), pile{{"zinc white",2},{"cerulean blue",0.3}}) end

--@ chunk 4
-- II. THE SHRIEKER: a broken bell with a person-shaped hole, screaming
local cx, cy = 715, 360
local BELL = P({{cx-30,cy-140},{cx+30,cy-140},{cx+50,cy-100},{cx+70,cy+40},{cx+120,cy+90},{cx-120,cy+90},{cx-70,cy+40},{cx-50,cy-100}})
F(BELL, PALE)
F(P({{cx+10,cy-140},{cx+30,cy-140},{cx+50,cy-100},{cx+70,cy+40},{cx+120,cy+90},{cx+40,cy+90}}), pile{{"lead white",1.5},{"cobalt violet",0.4},{"ultramarine ash",0.4}})
-- the crack and the broken lip
F(P({{cx+60,cy+90},{cx+80,cy+60},{cx+92,cy+76},{cx+104,cy+60},{cx+120,cy+90}}), pile{{"cadmium red",1},{"Mars red",0.6},{"rose madder",0.2}})
F(P({{cx+18,cy-138},{cx+26,cy-90},{cx+14,cy-50},{cx+30,cy}, {cx+24,cy+2},{cx+6,cy-50},{cx+18,cy-92},{cx+12,cy-138}}), INK)
-- the person-shaped hole
F(ellipse(cx-10, cy-58, 15, 17), INK)
F(P({{cx-30,cy-38},{cx+10,cy-38},{cx+18,cy+10},{cx+8,cy+60},{cx-2,cy+60},{cx-10,cy+20},{cx-18,cy+60},{cx-28,cy+60},{cx-38,cy+10}}), INK)
F(P({{cx-30,cy-34},{cx-58,cy+6},{cx-50,cy+12},{cx-26,cy-18}}), INK)
F(P({{cx+10,cy-34},{cx+38,cy+6},{cx+30,cy+12},{cx+6,cy-18}}), INK)
-- the scream: violet arcs
local r = brush{kind="round", width=6, point=0.6}
for k=1,3 do
  local pts = {} for i=0,10 do local a = -0.7 + 1.4*i/10; pts[#pts+1] = {cx + (130 + k*22)*math.cos(a - math.pi/2) * 0.9, cy - 40 + (130 + k*22)*math.sin(a - math.pi/2)*0.7} end
  r:reload(VIO, 0.7); r:stroke(pts, {pressure={r:pressure_for(3), r:pressure_for(3)}, clip=rect(510,150,410,500)})
end
-- the bell's crown loop
F(ellipse(cx, cy-152, 16, 14) - ellipse(cx, cy-152, 8, 7), pile{{"lead white",1.5},{"cobalt violet",0.4},{"ultramarine ash",0.4}})

--@ chunk 5
print(wait(3*24*60))
-- III. THE SMALL SCUTTLING THINGS: a swarm, pale, many-legged
local function scut(x, y, s, a)
  local ca, sa = math.cos(a), math.sin(a)
  local function R(px, py) return {x + (px*ca - py*sa)*s, y + (px*sa + py*ca)*s} end
  for k=-2,2 do
    F(P({R(k*6, 0), R(k*6+2, 0), R(k*8+2, 14), R(k*8, 14)}), VIOD)
    F(P({R(k*6, 0), R(k*6+2, 0), R(k*8+2, -14), R(k*8, -14)}), VIOD)
  end
  F(P({R(-18,-6), R(14,-7), R(22,0), R(14,7), R(-18,6), R(-22,0)}), PALE)
  F(P({R(16,-4), R(22,0), R(16,4)}), pile{{"cobalt violet",1},{"magenta",0.4}})
end
local GA = math.pi*(3-math.sqrt(5))
for i=1,26 do
  local rr = 24*math.sqrt(i); local a = i*GA
  local x, y = 285 + rr*1.25*math.cos(a), 900 + rr*0.95*math.sin(a)
  if x > 105 and x < 465 and y > 690 and y < 1080 then scut(x, y, 0.9 + 0.25*math.sin(i), a + math.pi/2) end
end
-- IV. THE FOLD: a pentagon folding into a smaller copy of itself, again and again, drawn with care
local cx, cy = 715, 890
local s, a = 170, -math.pi/2
local cols = {PALE, VIO, pile{{"lead white",2},{"yellow ochre",0.4}}, VIOD, PALE, VIO, pile{{"lead white",2},{"yellow ochre",0.4}}, VIOD}
for d=1,8 do
  local p = {} for k=0,4 do local t = a + k*2*math.pi/5; p[#p+1] = {cx + s*math.cos(t), cy + s*math.sin(t)} end
  F(P(p), cols[d])
  s = s * 0.72; a = a + 0.42; cx = cx + 6; cy = cy + 4
end

--@ chunk 6
print(wait(3*24*60))
-- the Shrieker's hole repainted dark on dry paint
local cx, cy = 715, 360
F(ellipse(cx-10, cy-58, 15, 17), INK)
F(P({{cx-30,cy-38},{cx+10,cy-38},{cx+18,cy+10},{cx+8,cy+60},{cx-2,cy+60},{cx-10,cy+20},{cx-18,cy+60},{cx-28,cy+60},{cx-38,cy+10}}), INK)
F(P({{cx-30,cy-34},{cx-58,cy+6},{cx-50,cy+12},{cx-26,cy-18}}), INK)
F(P({{cx+10,cy-34},{cx+38,cy+6},{cx+30,cy+12},{cx+6,cy-18}}), INK)
-- the Fold's crisp ink contours, every edge ruled
local r = brush{kind="round", width=3, point=0.6}
local fx, fy, s, a = 715, 890, 170, -math.pi/2
for d=1,8 do
  local p = {} for k=0,4 do local t = a + k*2*math.pi/5; p[#p+1] = {fx + s*math.cos(t), fy + s*math.sin(t)} end
  for k=1,5 do local q, w = p[k], p[k % 5 + 1]; r:reload(INK, 0.6); r:stroke({q, w}, {pressure={r:pressure_for(1.6), r:pressure_for(1.6)}}) end
  s = s * 0.72; a = a + 0.42; fx = fx + 6; fy = fy + 4
end
-- scrolls with lettering, one under each beast, and a title scroll across the top
local function scroll(x, y, w)
  F(P({{x,y},{x+w,y},{x+w,y+26},{x,y+26}}), pile{{"lead white",2.5},{"yellow ochre",0.3}})
  F(ellipse(x, y+13, 7, 14), pile{{"lead white",1.6},{"yellow ochre",0.6},{"burnt sienna",0.1}})
  F(ellipse(x+w, y+13, 7, 14), pile{{"lead white",1.6},{"yellow ochre",0.6},{"burnt sienna",0.1}})
  F(rect(x+10, y+5, 14, 16), pile{{"cadmium red",1}})
  local xx = x + 32
  while xx < x + w - 12 do local l = 3 + (math.floor(xx*13) % 7)
    r:reload(INK, 0.7); r:stroke({{xx, y+7},{xx+1, y+19}}, {pressure={r:pressure_for(2.2), r:pressure_for(1.8)}})
    if l > 5 then r:reload(INK, 0.6); r:stroke({{xx, y+13},{xx+l*0.6, y+13}}, {pressure={r:pressure_for(1.5), r:pressure_for(1.5)}}) end
    xx = xx + l + 3 end
end
scroll(130, 600, 300); scroll(560, 600, 300); scroll(130, 1120, 300); scroll(560, 1120, 300)
scroll(160, 70, 680)

--@ chunk 7
-- the lower margin: two little pilgrims fighting a Warden-thing with sword and staff
local r = brush{kind="round", width=6, point=0.5}
local function st(p, pts, w) r:reload(p, 0.8); r:stroke(pts, {pressure={r:pressure_for(w), r:pressure_for(w)}}) end
local RED = pile{{"cadmium red",1},{"Mars red",0.5}}
local BRN = pile{{"burnt sienna",1},{"bone brown",0.6}}
local SK = pile{{"lead white",2},{"Mars orange",0.2}}
local STEEL = pile{{"lead white",1.5},{"ultramarine ash",0.6}}
-- pilgrim 1, crimson, sword raised
st(RED, {{360,1212},{362,1262}}, 14)
st(SK, {{361,1196},{361,1200}}, 11)
st(RED, {{362,1222},{384,1206}}, 5)
st(STEEL, {{384,1206},{420,1176}}, 3.5)
st(BRN, {{354,1262},{348,1282}}, 5); st(BRN, {{366,1262},{372,1282}}, 5)
-- pilgrim 2, brown, staff thrust
st(BRN, {{300,1214},{302,1264}}, 14)
st(SK, {{301,1198},{301,1202}}, 11)
st(BRN, {{304,1226},{330,1230}}, 5)
st(INK, {{318,1250},{430,1214}}, 3)
st(BRN, {{294,1264},{290,1282}}, 5); st(BRN, {{306,1264},{312,1282}}, 5)
-- the beast, violet, legs scrabbling
F(P({{450,1230},{480,1196},{560,1190},{620,1214},{630,1250},{450,1252}}), VIO)
for k=0,5 do st(VIOD, {{470+k*28,1250},{462+k*28,1282}}, 4) end
for k=0,4 do st(VIOD, {{480+k*30,1200},{486+k*30,1244}}, 3) end
for k=0,4 do F(P({{490+k*24,1196},{498+k*24,1166},{506+k*24,1194}}), PALE) end
st(PALE, {{454,1232},{424,1196}}, 4)
F(ellipse(450,1236,3,3), pile{{"zinc white",2}})
-- gold dots round the blue border
local d = brush{kind="round", width=7, point=0}
for i=0,20 do local t = i/20
  for _,p in ipairs({{lerp(30,970,t),20},{lerp(30,970,t),1313}}) do d:reload(GOLD, 0.6); d:touch(p[1], p[2], {pressure=0.8}) end end
for i=0,28 do local t = i/28
  for _,p in ipairs({{20,lerp(30,1300,t)},{980,lerp(30,1300,t)}}) do d:reload(GOLD, 0.6); d:touch(p[1], p[2], {pressure=0.8}) end end

--@ chunk 8
local SK = pile{{"lead white",2},{"Mars orange",0.2}}
F(P({{350,1206},{370,1206},{378,1262},{344,1262}}), pile{{"cadmium red",1},{"Mars red",0.5}})
F(P({{290,1208},{310,1208},{318,1264},{284,1264}}), pile{{"burnt sienna",1},{"bone brown",0.6}})
F(ellipse(361,1194,8,9), SK); F(ellipse(301,1196,8,9), SK)
F(rect(357,1214,8,26) * rect(0,0,1000,1333), pile{{"lead white",2},{"yellow ochre",0.6}})
F(rect(350,1222,22,6), pile{{"lead white",2},{"yellow ochre",0.6}})
