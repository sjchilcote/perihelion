-- easel session "travel_poster": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=2/3, linen={18,16}, seed=3030, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.5},{"Mars orange",0.1}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
function flat(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=m, load=1}); return m end
BAND = rect(0,1260,1000,240)
SUN = ellipse(500, 700, 360, 360)
SPINE = poly({{430,1260},{570,1260},{528,560},{512,250},{500,190},{488,250},{472,560}})
SPL = SPINE * rect(0,0,500,1500)
SPR = SPINE - SPL
OUT = ellipse(500, 640, 470, 160)
MID = ellipse(500, 630, 440, 138)
INN = ellipse(500, 615, 395, 110)
RIM = OUT - MID
FACE = MID - INN
FRONT = below(function(x) return 640 end)
RIMF = RIM * FRONT; FACEF = FACE * FRONT
RIMB = (RIM - FRONT) - SPINE; FACEB = (FACE - FRONT) - SPINE
SAIL = poly({{506,230},{600,150},{740,100},{900,96},{980,130},{940,170},{820,180},{700,210},{600,260},{530,300}}, true) - SPINE
OBJ = SPINE + RIMF + FACEF + RIMB + FACEB + SAIL
local bandsP = {
  pile{{"ultramarine blue",1.2},{"bone black",0.5},{"cobalt blue",0.2}},
  pile{{"ultramarine blue",1},{"cobalt blue",0.5},{"lead white",0.25}},
  pile{{"cobalt blue",1},{"cerulean blue",0.4},{"lead white",0.6}},
  pile{{"cobalt violet",0.5},{"lead white",1.4},{"cerulean blue",0.3}},
  pile{{"lead white",1.6},{"Mars orange",0.4},{"cobalt violet",0.15}},
  pile{{"Mars orange",0.8},{"cadmium yellow",0.6},{"lead white",1.2}},
}
local SKY = rect(0,0,1000,1260) - OBJ - SUN
for i=1,6 do flat(SKY * rect(0,(i-1)*210,1000,210), bandsP[i]) end
flat(SUN - OBJ, pile{{"cadmium yellow",1.2},{"Mars orange",0.4},{"lead white",0.5}})
flat(BAND, pile{{"ultramarine blue",1},{"bone black",0.6}})
flat(SPL - RIMF - FACEF, pile{{"yellow ochre",1.2},{"Mars orange",0.4},{"lead white",0.5}})
flat(SPR - RIMF - FACEF, pile{{"burnt sienna",1.2},{"bone brown",0.6},{"Mars orange",0.2}})
flat(RIMF + RIMB, pile{{"bone brown",1.2},{"burnt sienna",0.8},{"ultramarine blue",0.2}})
flat(FACEF + FACEB, pile{{"cadmium yellow",0.8},{"yellow ochre",1},{"lead white",0.4}})
flat(SAIL, pile{{"lead white",2.5},{"yellow ochre",0.3}})

--@ chunk 3
print(wait(4*24*60))
function F(m, p) work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
-- ring face: a deep bronze so it stands against the sun; spine's lit side pale and gleaming
F(FACEF + FACEB, pile{{"burnt sienna",1},{"yellow ochre",0.8},{"Mars orange",0.4}})
F(SPL - RIMF - FACEF, pile{{"lead white",2},{"yellow ochre",0.7},{"Mars orange",0.15}})

--@ chunk 4
print(wait(4*24*60))
local r = brush{kind="round", width=5, point=0.6}
local HI = pile{{"lead white",2.6},{"cadmium yellow",0.4}}
local function arc(cx, cy, rx, ry, a0, a1, w, p, clip)
  local pts = {} for i=0,40 do local a = a0 + (a1-a0)*i/40; pts[#pts+1] = {cx + rx*math.cos(a), cy + ry*math.sin(a)} end
  r:reload(p, 0.8); r:stroke(pts, {pressure={r:pressure_for(w), r:pressure_for(w)}, clip=clip})
end
-- gleam along the ring's inner lip (front) and outer upper edge (back)
arc(500, 615, 397, 112, 0.05, math.pi-0.05, 3, HI, FACEF:grow(3))
arc(500, 640, 468, 158, math.pi+0.1, 2*math.pi-0.1, 2.5, HI, -SPINE)
-- the spine's gleaming edge and a few Deco bands across it
r:reload(HI, 0.8); r:stroke({{432,1258},{474,560},{490,250},{500,196}}, {pressure={r:pressure_for(3), r:pressure_for(1)}, clip=SPINE:grow(2) - RIMF - FACEF})
for _,y in ipairs({820, 960, 1100}) do
  local hw = 30 + (y-560)*0.11
  r:reload(pile{{"bone brown",1.2},{"burnt sienna",0.8}}, 0.7); r:stroke({{500-hw,y},{500+hw,y}}, {pressure={r:pressure_for(3), r:pressure_for(3)}, clip=SPINE})
end
-- Deco rays radiating from the sun across the lower sky
for i=-4,4 do
  local a = math.pi/2 + i*0.14
  r:reload(pile{{"lead white",2},{"cadmium yellow",0.3},{"Mars orange",0.2}}, 0.5)
  r:stroke({{500 + 380*math.cos(a), 700 + 380*math.sin(a)},{500 + 700*math.cos(a), 700 + 700*math.sin(a)}}, {pressure={r:pressure_for(2.5), r:pressure_for(5)}, clip=rect(0,0,1000,1258) - SPINE - SUN - RIMF - FACEF})
end
-- the CUCULUS: a tiny dark seed coming in at the upper left, a fiery trail behind
r:reload(pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",0.6}}, 0.6)
r:stroke({{30,90},{120,170},{190,230}}, {pressure={r:pressure_for(1), r:pressure_for(5)}})
local s = brush{kind="round", width=16, point=0}
s:reload(pile{{"bone black",2},{"burnt sienna",0.4}}, 0.8); s:touch(198, 238, {pressure=0.8})
-- the sail: a shadow fold and its rigging line to the spine top
r:reload(pile{{"lead white",1.4},{"yellow ochre",0.8},{"cobalt violet",0.15}}, 0.7); r:stroke({{560,276},{700,200},{860,150},{960,140}}, {pressure={r:pressure_for(4), r:pressure_for(2)}, clip=SAIL})
-- title: TESTAMENT in big Deco capitals, gold
local m = brush{kind="round", width=14, point=0.2}
local GLD = pile{{"cadmium yellow",1.2},{"yellow ochre",0.8},{"lead white",0.6}}
local function L(pts, w) m:reload(GLD, 0.95); m:stroke(pts, {pressure={m:pressure_for(w or 11), m:pressure_for(w or 11)}}) end
local G = {
  T={{{0,0},{1,0}},{{0.5,0},{0.5,1}}}, E={{{0.9,0},{0,0},{0,1},{0.9,1}},{{0,0.5},{0.65,0.5}}},
  S={{{0.9,0.08},{0.6,0},{0.15,0.05},{0.05,0.25},{0.2,0.45},{0.75,0.55},{0.95,0.75},{0.85,0.95},{0.4,1},{0.05,0.92}}},
  A={{{0,1},{0.5,0},{1,1}},{{0.22,0.62},{0.78,0.62}}}, M={{{0,1},{0,0},{0.5,0.6},{1,0},{1,1}}}, N={{{0,1},{0,0},{0.9,1},{0.9,0}}},
}
local x, y, s2 = 70, 1300, 100
for c in ("TESTAMENT"):gmatch(".") do
  for _,st in ipairs(G[c]) do local pts = {} for _,p in ipairs(st) do pts[#pts+1] = {x + p[1]*s2*0.78, y + p[2]*s2} end L(pts) end
  x = x + s2*0.78 + 22
end
-- a thin gold rule and a line of abstract marks below
m:reload(GLD, 0.8); m:stroke({{70,1272},{930,1272}}, {pressure={m:pressure_for(3), m:pressure_for(3)}})
local t = brush{kind="round", width=4, point=0.6}
local xx = 260
while xx < 740 do local l = 10 + (math.floor(xx*7) % 22); if xx + l > 740 then break end
  t:reload(pile{{"lead white",2},{"yellow ochre",0.4}}, 0.7); t:stroke({{xx,1450},{xx+l,1450}}, {pressure={t:pressure_for(3), t:pressure_for(3)}}); xx = xx + l + 10 end

--@ chunk 5
print(wait(3*24*60))
local m = brush{kind="flat", width=18}
local GLD = pile{{"cadmium yellow",1.2},{"yellow ochre",0.8},{"lead white",0.6}}
local function L(pts) m:reload(GLD, 1); m:stroke(pts, {pressure={0.9, 0.9}, orient="across", shake=0}) end
local G = {
  T={{{0,0},{1,0}},{{0.5,0},{0.5,1}}}, E={{{0.9,0},{0,0},{0,1},{0.9,1}},{{0,0.5},{0.65,0.5}}},
  S={{{0.9,0.08},{0.6,0},{0.15,0.05},{0.05,0.25},{0.2,0.45},{0.75,0.55},{0.95,0.75},{0.85,0.95},{0.4,1},{0.05,0.92}}},
  A={{{0,1},{0.5,0},{1,1}},{{0.22,0.62},{0.78,0.62}}}, M={{{0,1},{0,0},{0.5,0.6},{1,0},{1,1}}}, N={{{0,1},{0,0},{0.9,1},{0.9,0}}},
}
local x, y, s2 = 70, 1300, 100
for c in ("TESTAMENT"):gmatch(".") do
  for _,st in ipairs(G[c]) do
    for k=1,#st-1 do L({{x + st[k][1]*s2*0.78, y + st[k][2]*s2}, {x + st[k+1][1]*s2*0.78, y + st[k+1][2]*s2}}) end
  end
  x = x + s2*0.78 + 22
end
