-- easel session "book_cover": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={18,16}, seed=2626, ground={{pile={{"lead white",6},{"bone black",0.3}}, um=120, apply="knife", texture=0.3},{pile={{"lead white",3},{"yellow ochre",0.6},{"Mars orange",0.15}}, um=30, apply="brush"}}}
print(W,H)

--@ chunk 2
-- every shape a partition of the page, painted side by side on the bare ground: no colour over another wet colour
function flat(m, p) work(m, {hand="body", pile=p, coverage=3.5, fill=true, tool="filbert 8", angle=0, clip=m, load=1}); return m end
function F(m, p) work(m, {hand="detail", pile=p, coverage=7, fill=true, clip=m, load=1}); return m end
CREAM = pile{{"lead white",2.5},{"yellow ochre",0.5},{"Mars orange",0.12}}
PEACH = pile{{"lead white",2},{"Mars orange",0.35},{"yellow ochre",0.4}}
GOLD = pile{{"cadmium yellow",1},{"yellow ochre",1},{"lead white",0.3}}
CR = pile{{"cadmium red",1},{"Mars red",0.6}}
KG = pile{{"lead white",1.2},{"ultramarine ash",0.5},{"yellow ochre",0.4},{"burnt sienna",0.12}}
PURP = pile{{"cobalt violet",1},{"magenta",0.35},{"lead white",0.7}}
INK = pile{{"bone black",2},{"ultramarine blue",0.3}}
PAGE = rect(40,40,920,1253)
BAND = rect(40,40,920,190)
FOOT = rect(40,1180,920,113)
ART = PAGE - BAND - FOOT
-- the knight
HELM = ellipse(480, 560, 92, 88)
VISOR = poly({{392,540},{568,532},{572,574},{390,582}}, true)
TAB = poly({{400,660},{560,660},{582,800},{590,900},{372,900},{380,800}}, true)
BODY = poly({{360,636},{600,636},{640,760},{650,900},{310,900},{320,760}}, true)
LARM = poly({{340,660},{300,740},{300,840},{350,880},{372,860},{340,820},{350,730},{372,690}}, true)
RARM = poly({{620,660},{660,740},{664,840},{620,890},{600,872},{628,820},{620,730},{596,690}}, true)
LTHIGH = poly({{330,880},{480,880},{470,950},{320,950}}, true)
RTHIGH = poly({{500,880},{650,880},{660,950},{510,950}}, true)
LSHIN = poly({{330,940},{440,940},{430,1110},{340,1110}}, true)
RSHIN = poly({{530,940},{640,940},{630,1110},{540,1110}}, true)
KNIGHT = HELM + BODY + LARM + RARM + LTHIGH + RTHIGH + LSHIN + RSHIN
-- Ratio on his left knee
RHEAD = ellipse(400, 800, 26, 24)
RFACE = poly({{384,794},{416,794},{416,824},{384,824}})
RHAIR = poly({{372,790},{428,790},{432,870},{368,870}}) + RHEAD - RFACE
RDRESS = poly({{382,826},{418,826},{424,876},{376,876}})
RARMW = poly({{416,832},{440,808},{452,776},{462,780},{450,814},{424,846}})
RHAND = ellipse(458, 772, 8, 8)
RLEGS = rect(384,876,10,14) + rect(404,876,10,14)
RATIO = RHAIR + RFACE + RDRESS + RARMW + RHAND + RLEGS
-- the bug at his feet
BUG = ellipse(700, 1100, 150, 62) + ellipse(565, 1112, 46, 40)
local spk = nil
for k=0,6 do local a = math.pi*(1.08 + 0.84*k/6); local x, y = 700 + 146*math.cos(a), 1100 + 60*math.sin(a)
  local s = poly({{x-14,y+10},{x + 34*math.cos(a), y + 34*math.sin(a)},{x+14,y+10}}); spk = spk and (spk + s) or s end
SPK = spk - BUG
-- sun, ring, ground
SUN = ellipse(760, 380, 120, 120)
RING = (ellipse(500, 1900, 1120, 1120) - ellipse(500, 1900, 1070, 1070)) * ART
GROUNDM = ellipse(500, 1900, 1070, 1070) * ART
local FIG = KNIGHT + RATIO + BUG + SPK
flat(BAND, CR)
flat(FOOT + (rect(0,0,1000,1333) - PAGE), CREAM)
flat(SUN - FIG, pile{{"cadmium yellow",1.2},{"Mars orange",0.5},{"lead white",0.6}})
flat(RING - FIG, GOLD)
flat(GROUNDM - FIG, pile{{"yellow ochre",1},{"lead white",1.2},{"viridian",0.12}})
flat(ART - SUN - RING - GROUNDM - FIG, PEACH)

--@ chunk 3
local RALL = RATIO:grow(1)
local CROSS = rect(470,690,20,110) + rect(436,724,88,20)
F(KNIGHT - TAB - VISOR - RALL, KG)
F(TAB - CROSS - RALL, CR)
F(VISOR, INK)
F(BUG, PURP)
F(SPK, pile{{"cobalt violet",1},{"ultramarine blue",0.5},{"lead white",0.3}})
F(RHAIR, INK)
CROSSM = CROSS

--@ chunk 4
print(wait(5*24*60))
local SK = pile{{"lead white",2.8},{"rose madder",0.15},{"yellow ochre",0.1}}
local WH = pile{{"zinc white",2.8}}
F(CROSSM - RATIO:grow(1), pile{{"lead white",2.2},{"yellow ochre",0.4}})
F(RFACE, SK); F(RHAND, SK)
F(RDRESS, WH); F(RARMW, WH)
F(RLEGS, pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.5}})
F(ellipse(410, 556, 10, 10), pile{{"lead white",2.5},{"cadmium yellow",0.6}})   -- the knight's light, looking at her

--@ chunk 5
print(wait(3*24*60))
local KG2 = pile{{"lead white",1},{"ultramarine ash",0.7},{"yellow ochre",0.3},{"burnt sienna",0.15},{"bone black",0.08}}
F(KNIGHT - TAB - VISOR - RATIO:grow(1) - BUG - SPK, KG2)

--@ chunk 6
print(wait(3*24*60))
local r = brush{kind="round", width=3, point=0.8}
r:reload(INK, 0.8); r:touch(394, 806, {pressure=0.6}); r:reload(INK, 0.8); r:touch(406, 806, {pressure=0.6})
r:reload(pile{{"rose madder",1},{"lead white",0.6}}, 0.6); r:stroke({{395,815},{400,818},{405,815}}, {pressure={r:pressure_for(1.4), r:pressure_for(1.4)}})
for _,s in ipairs({{{470,758},{480,748}},{{474,776},{488,772}}}) do r:reload(INK, 0.6); r:stroke(s, {pressure={r:pressure_for(1.8), r:pressure_for(1.8)}}) end
r:reload(INK, 0.7); r:stroke({{548,1108},{556,1114},{564,1108}}, {pressure={r:pressure_for(1.8), r:pressure_for(1.8)}})
r:reload(INK, 0.7); r:stroke({{572,1104},{580,1110},{588,1104}}, {pressure={r:pressure_for(1.8), r:pressure_for(1.8)}})
-- seams on the knight's plates
for _,s in ipairs({{{330,880},{650,880}},{{330,946},{480,946}},{{510,946},{650,946}},{{350,760},{380,770}},{{610,770},{640,760}}}) do
  r:reload(pile{{"ultramarine ash",1},{"bone brown",0.6},{"bone black",0.3}}, 0.6); r:stroke(s, {pressure={r:pressure_for(2), r:pressure_for(2)}}) end
-- title in hand-drawn cream capitals, two lines
local m = brush{kind="round", width=8, point=0.5}
local CRM = pile{{"lead white",2.8},{"yellow ochre",0.3}}
local function L(pts) m:reload(CRM, 0.9); m:stroke(pts, {pressure={m:pressure_for(5), m:pressure_for(5)}}) end
local G = {
  A={{{0,1},{0.5,0},{1,1}},{{0.25,0.55},{0.75,0.55}}}, B={{{0,0},{0,1}},{{0,0},{0.7,0},{0.8,0.25},{0.6,0.48},{0,0.48}},{{0.6,0.48},{0.85,0.72},{0.7,1},{0,1}}},
  D={{{0,0},{0,1}},{{0,0},{0.6,0},{0.9,0.3},{0.9,0.7},{0.6,1},{0,1}}}, E={{{0.9,0},{0,0},{0,1},{0.9,1}},{{0,0.5},{0.7,0.5}}},
  G={{{0.9,0.15},{0.6,0},{0.2,0.05},{0,0.5},{0.2,0.95},{0.6,1},{0.9,0.8},{0.9,0.55},{0.55,0.55}}}, H={{{0,0},{0,1}},{{0.9,0},{0.9,1}},{{0,0.5},{0.9,0.5}}},
  I={{{0.4,0},{0.4,1}}}, K={{{0,0},{0,1}},{{0.9,0},{0,0.6}},{{0.3,0.4},{0.9,1}}}, N={{{0,1},{0,0},{0.9,1},{0.9,0}}},
  O={{{0.45,0},{0.1,0.15},{0,0.5},{0.1,0.85},{0.45,1},{0.8,0.85},{0.9,0.5},{0.8,0.15},{0.45,0}}},
  R={{{0,1},{0,0},{0.7,0},{0.85,0.25},{0.7,0.5},{0,0.5}},{{0.4,0.5},{0.9,1}}}, T={{{0,0},{0.9,0}},{{0.45,0},{0.45,1}}},
}
local function word(str, x, y, s, gap)
  for i=1,#str do local c = str:sub(i,i)
    if c == " " then x = x + s*0.7 else
      for _,stroke in ipairs(G[c]) do local pts = {} for _,p in ipairs(stroke) do pts[#pts+1] = {x + p[1]*s*0.8, y + p[2]*s} end L(pts) end
      x = x + s*(c == "I" and 0.55 or 0.95) + gap end end
end
word("RATIO AND THE", 205, 70, 50, 6)
word("BIG KNIGHT", 250, 150, 56, 8)
-- author line: abstract marks on the cream foot
local t = brush{kind="round", width=4, point=0.6}
local x = 360
while x < 640 do local l = 10 + (math.floor(x*7) % 20); if x + l > 640 then break end
  t:reload(pile{{"bone brown",1.4},{"burnt sienna",0.5}}, 0.7); t:stroke({{x, 1240},{x+l, 1240}}, {pressure={t:pressure_for(3), t:pressure_for(3)}}); x = x + l + 10 end
