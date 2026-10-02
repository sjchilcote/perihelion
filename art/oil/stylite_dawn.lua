-- easel session "stylite_dawn": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=600, aspect=0.75, linen={16,18}, seed=7123, ground={{pile={{"lead white",1},{"ultramarine blue",1},{"magenta",0.3},{"bone black",0.7},{"raw sienna",0.3}}, um=140, apply="knife", texture=0.4}}}
-- the gate: its lit opening fills the upper left; its bronze lip runs along a curve from the top edge down the left
GATEC = {-260, 380}
GATER = 760
function gate_in(x, y) local dx, dy = x - GATEC[1], (y - GATEC[2]) * 0.92; return math.sqrt(dx * dx + dy * dy) end
SWN = noise{seed=5, period=380, octaves=3}
-- the cold turns round a centre low and to the right
function swirl(x, y) return math.atan(y - 900, x - 700) + math.pi / 2 + 0.3 + 0.5 * SWN(x, y) end
function radial(x, y) return math.atan(y - GATEC[2], x - GATEC[1]) + math.pi / 2 end
print(W, H)

--@ chunk 2
OPEN = mask(function(x, y) return gate_in(x, y) < GATER and 1 or 0 end)
LIP  = mask(function(x, y) local r = gate_in(x, y); return (r >= GATER and r < GATER + 85) and 1 or 0 end)
COLD = -(OPEN + LIP)
VIO   = pile{{"ultramarine blue",2},{"magenta",0.6},{"bone black",1.0},{"lead white",0.3}}
PLUM  = pile{{"magenta",1},{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.2}}
TEALD = pile{{"viridian",2},{"ultramarine blue",1},{"bone black",0.9},{"lead white",0.3}}
COBV  = pile{{"cobalt violet",1},{"ultramarine blue",1},{"lead white",0.6}}
work(COLD, {hand="broad", pile=VIO, coverage=2.4, fill=true, angle=swirl, seed=201})
local zn = noise{seed=21, period=300, octaves=3}
local teal = COLD * mask(function(x, y) return clamp(smoothstep(700, 250, y) * smoothstep(500, 800, x) + 0.4 * zn(x, y), 0, 1) end)
local plum = COLD * mask(function(x, y) return clamp(smoothstep(950, 1250, y) * smoothstep(300, 900, x) + 0.4 * zn(x + 300, y), 0, 1) end)
work(teal, {hand="broad", pile=TEALD, coverage=1.4, fill=true, angle=swirl, seed=202})
work(plum, {hand="broad", pile=PLUM, coverage=1.4, fill=true, angle=swirl, seed=203})
work(COLD * ellipse(820, 620, 200, 260):soften(80), {hand="body", pile=COBV, coverage=0.7, angle=swirl, seed=204})
-- the gold
G1 = pile{{"burnt sienna",2},{"Mars orange",1},{"ultramarine blue",0.2}}
G2 = pile{{"Mars orange",1},{"cadmium red",0.3},{"lead white",0.6},{"Indian yellow",0.4}}
G3 = pile{{"cadmium yellow",1},{"Indian yellow",0.5},{"lead white",1.2}}
G4 = pile{{"lead white",3},{"lemon chrome",1}}
local hc = {300, 520}
local function hd(x, y) return math.sqrt((x - hc[1])^2 + ((y - hc[2]) * 0.85)^2) end
local zones = {{G1, 9999}, {G2, 520}, {G3, 330}, {G4, 170}}
for i, z in ipairs(zones) do
  local m = OPEN * mask(function(x, y) return hd(x, y) < z[2] and 1 or 0 end):roughen(10, 60, 220 + i):soften(14)
  work(m, {hand="body", pile=z[1], coverage=2.6, fill=true, angle=radial, length={30, 80}, clip=OPEN, seed=210 + i})
end

--@ chunk 3
local function circ(x, y) return math.atan(y - 520, x - 300) + math.pi / 2 end
blend(OPEN, {angle=circ, tool={kind="badger", width=20}, seed=301})
blend(COLD, {angle=swirl, tool={kind="badger", width=20}, seed=302})
BRZ_D = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
BRZ_M = pile{{"raw sienna",2},{"bone black",1},{"burnt sienna",1}}
work(LIP, {hand="body", pile=BRZ_D, coverage=3, fill=true, angle=radial, clip=true, seed=303})
-- the inner face of the lip, toward the light, a warmer bronze band
local inner = LIP * mask(function(x, y) return gate_in(x, y) < GATER + 30 and 1 or 0 end)
work(inner, {hand="body", pile=BRZ_M, coverage=2.5, fill=true, angle=radial, clip=true, seed=304})

--@ chunk 4
-- the pillar's top: a small disc of bronze, the shaft dropping away under it
DISC = ellipse(470, 1122, 330, 56)
DRUM = poly({{142,1122},{798,1122},{780,1196},{160,1196}}) - DISC
SHAFTB = rect(372, 1190, 200, 150)
-- the Commando, kneeling, facing left
CLOAK = poly({{452,398},{500,406},{532,448},{578,540},{618,640},{644,760},{678,900},{716,1040},{742,1112},{622,1120},{574,1082},{576,950},{584,800},{572,640},{520,560},{492,480}}, true)
HELM = poly({{405,415},{450,405},{484,424},{494,470},{485,515},{455,535},{410,530},{393,510},{390,460},{395,430}}, true)
TORSO = poly({{432,540},{500,532},{560,556},{586,620},{580,720},{560,800},{470,812},{440,740},{424,650},{420,592}}, true)
THIGH = ribbon({{525,790},{470,940},{425,1078}}, 82)
SHIN = ribbon({{425,1086},{540,1094},{655,1098}}, 56)
FOOT = poly({{640,1078},{700,1084},{712,1110},{640,1112}}, true)
UARM = ribbon({{525,590},{512,660},{500,728}}, 48)
FARM = ribbon({{500,730},{455,690},{410,630}}, 40)
HANDS = ellipse(398, 612, 30, 36)
ARMOUR = HELM + TORSO + THIGH + SHIN + FOOT + UARM + FARM + HANDS
FIGURE = ARMOUR + CLOAK
local BRZ_D = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
local BRZ_W = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"Mars orange",0.3}}
work(DRUM + SHAFTB, {hand="body", tool="filbert 6", pile=BRZ_D, coverage=3, fill=true, angle=math.pi/2, clip=true, seed=401})
work(DISC, {hand="body", tool="filbert 6", pile=BRZ_W, coverage=3, fill=true, angle=0.05, clip=true, seed=402})
CRIM = pile{{"cadmium red",1},{"rose madder",0.6},{"bone brown",0.4}}
work(CLOAK, {hand="body", tool="filbert 6", pile=CRIM, coverage=3, fill=true, angle=1.3, clip=true, seed=403})
STEEL = pile{{"bone black",1},{"ultramarine blue",0.5},{"burnt sienna",0.3},{"lead white",0.5}}
work(ARMOUR, {hand="body", tool="filbert 4", pile=STEEL, coverage=3.2, fill=true, angle=1.4, clip=true, seed=404})

--@ chunk 5
-- the armour came up pale and thin over the gold: restate it dark and opaque; the cloak in a body crimson
local DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
work(ARMOUR, {hand="body", tool="filbert 4", pile=DARKSTEEL, coverage=4.5, fill=true, angle=1.4, clip=true, seed=501})
local CRIM2 = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
work(CLOAK - ARMOUR, {hand="body", tool="filbert 6", pile=CRIM2, coverage=4, fill=true, angle=1.3, clip=CLOAK - ARMOUR, seed=502})
-- the gold, less of a target: a smaller radial blend through the rings
local function rad(x, y) return math.atan(y - 520, x - 300) end
blend(OPEN * ellipse(300, 520, 360, 420) - FIGURE:grow(4), {angle=rad, tool={kind="badger", width=16}, seed=503})

--@ chunk 6
print(wait(3*24*60)); print(drying(450,650), drying(600,900))

--@ chunk 7
-- modelling the frame: gold on the planes that face the gate, the cold on the planes that face away
GOLDL = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
GOLDM = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.1}}
ICE   = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
COLDR = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.2},{"cobalt violet",0.4}}
SEAM  = pile{{"bone black",2},{"ultramarine blue",0.5}}
BONE  = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.4}}
local rig = brush{kind="rigger", width=2.4, point=0.85}
local fil = brush{kind="filbert", width=6}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.15, 0.3}}) end
-- face-plate: a broad warm plane on the front, a hard gold edge, the cold along the jaw and cheek
S(fil, GOLDM, 0.45, {{404,430},{400,470},{404,510}}, {0.35, 0.3})
S(rig, GOLDL, 0.8, {{398,428},{392,466},{396,512}}, {0.6, 0.5})
S(rig, GOLDL, 0.7, {{401,424},{428,412},{452,408}}, {0.45, 0.3})
S(rig, COLDR, 0.7, {{412,530},{440,534},{460,532},{482,514}}, {0.35, 0.45})
S(rig, COLDR, 0.6, {{470,480},{478,500},{474,520}}, {0.2, 0.35})
-- visor slit and the optic
S(rig, SEAM, 0.8, {{397,462},{420,460},{446,458}}, {0.55, 0.3})
S(rig, ICE, 0.9, {{399,461},{405,461}}, {0.8, 0.8})
-- dents on the helm and breast: a dark pit with a lit lower lip
for _, d in ipairs({{430,490},{452,446},{462,620},{440,690},{505,700}}) do
  S(rig, SEAM, 0.6, {{d[1]-4, d[2]-2},{d[1]+5, d[2]}}, {0.5, 0.3})
  S(rig, GOLDM, 0.5, {{d[1]-4, d[2]+2.5},{d[1]+3, d[2]+3}}, {0.3, 0.2})
end
-- breast and lorica: gold down the front edge, seams across, cold on the back
S(rig, GOLDL, 0.8, {{428,560},{422,600},{423,650},{430,700},{442,745}}, {0.55, 0.4})
for i, y in ipairs({600, 655, 712, 765}) do
  S(rig, SEAM, 0.7, {{428 + (y - 600) * 0.08, y},{500, y + 6},{575, y + 10}}, {0.45, 0.3})
  S(rig, GOLDM, 0.6, {{430 + (y - 600) * 0.08, y + 3},{462, y + 6}}, {0.4, 0.05})
end
S(rig, GOLDL, 0.7, {{470,552},{510,548},{548,575}}, {0.45, 0.2})
-- arm: the forearm's upper edge to the gold, the elbow to the cold
S(rig, GOLDM, 0.7, {{490,705},{455,668},{420,612}}, {0.4, 0.55})
S(rig, COLDR, 0.6, {{528,690},{530,725},{512,752}}, {0.35, 0.3})
-- gauntlets: knuckles in gold
S(rig, GOLDL, 0.8, {{374,592},{369,612},{372,636}}, {0.6, 0.4})
for _, k in ipairs({{380,600},{378,614},{380,628}}) do S(rig, GOLDL, 0.6, {{k[1], k[2]},{k[1] + 7, k[2] + 1}}, {0.5, 0.2}) end
-- thigh and knee, the shin along the disc
S(rig, GOLDL, 0.8, {{488,790},{458,870},{430,945},{392,1068}}, {0.35, 0.6})
S(fil, GOLDM, 0.5, {{392,1062},{388,1080}}, {0.5, 0.5})
S(rig, GOLDM, 0.6, {{430,1062},{540,1068},{650,1072}}, {0.35, 0.15})
S(rig, COLDR, 0.6, {{560,800},{545,900},{505,1020}}, {0.3, 0.35})
-- the cloak: folds, and the cold along its outer edge
local FOLD = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.2}}
local LITC = pile{{"vermilion",1},{"cadmium yellow",0.3},{"lead white",0.3}}
for i, f in ipairs({{{560,560},{600,760},{640,960},{680,1100}}, {{590,620},{630,800},{690,1000},{720,1100}}, {{540,700},{570,880},{600,1080}}}) do S(fil, FOLD, 0.6, f, {0.45, 0.25}) end
S(rig, COLDR, 0.7, {{500,404},{534,448},{578,540},{618,640},{646,760},{680,900},{718,1040},{744,1108}}, {0.4, 0.3})
S(rig, LITC, 0.7, {{455,400},{476,410},{494,440}}, {0.45, 0.2})
-- the rosary hanging from the gauntlets, and the bone cross
local beads = {}
for i = 0, 16 do
  local t = i / 16
  local x = 392 + 22 * math.sin(math.pi * t) * 0.6 + 6 * t
  local y = 640 + 120 * math.sin(math.pi * t * 0.5)
  rig:reload(BONE, 0.7); rig:touch(x, y, {pressure=0.75})
end
S(rig, BONE, 0.9, {{413,762},{414,808}}, {0.75, 0.7})
S(rig, BONE, 0.9, {{402,776},{426,776}}, {0.75, 0.7})
S(rig, GOLDL, 0.6, {{411,764},{411,806}}, {0.3, 0.3})

--@ chunk 8
-- planes, not lines: the gate's light as a broad plane down the front of every form; the hood over the helm
local function cx(y)
  if y < 540 then return 445 elseif y < 800 then return 505 else return lerp(525, 425, (y - 800) / 280) end
end
local front = mask(function(x, y) return x < cx(y) - 8 and 1 or 0 end):soften(10)
local back  = mask(function(x, y) return x > cx(y) + 12 and 1 or 0 end):soften(10)
local GOLDM = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.15}}
local GOLDD = pile{{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.6},{"lead white",0.3}}
local GOLDL = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local COLDM = pile{{"viridian",1},{"ultramarine blue",1},{"bone black",0.7},{"lead white",0.6}}
local band1 = ARMOUR:rim(22, 8) * front
local band2 = ARMOUR:rim(8, 3) * front
work(band1, {hand="body", tool="filbert 4", pile=GOLDD, coverage=2.5, fill=true, angle=1.45, clip=ARMOUR, seed=801})
work(band2, {hand="body", tool="filbert 3", pile=GOLDM, coverage=2.5, fill=true, angle=1.45, clip=ARMOUR, seed=802})
work(ARMOUR:rim(3, 1) * front, {hand="detail", pile=GOLDL, coverage=2.5, fill=true, angle=1.45, clip=ARMOUR, seed=803})
work(ARMOUR:rim(12, 5) * back, {hand="body", tool="filbert 3", pile=COLDM, coverage=2, fill=true, angle=1.45, clip=ARMOUR, seed=804})
-- the hood: crimson drawn over the crown and back of the helm, the face-plate left bare
HOOD = poly({{436,404},{468,396},{502,408},{522,450},{514,500},{494,532},{472,524},{478,484},{466,442},{448,420}}, true)
local CRIM2 = pile{{"vermilion",1},{"Mars red",1},{"rose madder",0.5},{"bone brown",0.5}}
work(HOOD, {hand="body", tool="filbert 4", pile=CRIM2, coverage=4, fill=true, angle=1.2, clip=true, seed=805})
-- the cloak turns away from the gate: its right side into shadow, the cold on it
local SHC = pile{{"rose madder",1},{"bone brown",1},{"ultramarine blue",0.4},{"bone black",0.3}}
local cl = (CLOAK + HOOD) - ARMOUR
local shade = cl * mask(function(x, y) return x > cx(y) + 60 and 1 or 0 end):soften(25)
work(shade, {hand="body", tool="filbert 6", pile=SHC, coverage=2.5, fill=true, angle=1.3, clip=cl, seed=806})

--@ chunk 9
-- the lit plane came up as light as the gold behind it and the silhouette dissolved:
-- take the plane back down to a warm dark bronze-steel, leaving only a narrow lit edge
local function cx(y)
  if y < 540 then return 445 elseif y < 800 then return 505 else return lerp(525, 425, (y - 800) / 280) end
end
local front = mask(function(x, y) return x < cx(y) - 8 and 1 or 0 end):soften(10)
local WDARK = pile{{"bone black",1.4},{"burnt sienna",1},{"yellow ochre",0.3},{"ultramarine blue",0.3}}
local m = (ARMOUR:rim(26, 6) - ARMOUR:rim(6, 2)) * front - HOOD
work(m, {hand="body", tool="filbert 3", pile=WDARK, coverage=4.5, fill=true, angle=1.45, clip=ARMOUR - HOOD, seed=901})

--@ chunk 10
-- break the gold's target rings: long curving strokes across each ring's seam, then blend the seams
local hc = {300, 520}
local function hd(x, y) return math.sqrt((x - hc[1])^2 + ((y - hc[2]) * 0.85)^2) end
local function flow(x, y) return math.atan(y - hc[2], x - hc[1]) + math.pi / 2 + 0.5 * SWN(x, y) end
local keep = OPEN - FIGURE:grow(4)
local G23 = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"Indian yellow",0.4},{"lead white",0.9}}
local G34 = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
local s1 = keep * mask(function(x, y) return math.abs(hd(x, y) - 520) < 60 and 1 or 0 end):soften(20)
local s2 = keep * mask(function(x, y) return math.abs(hd(x, y) - 330) < 55 and 1 or 0 end):soften(20)
local s3 = keep * mask(function(x, y) return math.abs(hd(x, y) - 170) < 45 and 1 or 0 end):soften(20)
work(s1, {hand="body", tool="filbert 7", pile=G2, coverage=1.3, load=0.6, angle=flow, length={40, 110}, clip=keep, seed=1001})
work(s2, {hand="body", tool="filbert 7", pile=G23, coverage=1.3, load=0.6, angle=flow, length={40, 110}, clip=keep, seed=1002})
work(s3, {hand="body", tool="filbert 7", pile=G34, coverage=1.3, load=0.6, angle=flow, length={30, 90}, clip=keep, seed=1003})
blend(s1 + s2 + s3, {angle=flow, tool={kind="badger", width=16}, seed=1004})

--@ chunk 11
-- the disc and what lies past its edge; last accents
local rig = brush{kind="rigger", width=2.6, point=0.85}
local fil = brush{kind="filbert", width=5}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.15, 0.3}}) end
local GOLDL = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local GOLDM = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.15}}
local SHD = pile{{"bone black",1.5},{"burnt sienna",0.8},{"ultramarine blue",0.5}}
local COLDR = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.2},{"cobalt violet",0.4}}
local ICE = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
-- the figure's shadow thrown across the disc, away from the gate
local sh = DISC * ellipse(640, 1112, 140, 30) - FIGURE
work(sh, {hand="body", tool="filbert 5", pile=SHD, coverage=3, fill=true, angle=0.05, clip=DISC - FIGURE, seed=1101})
-- the disc's rim: gold on the side toward the gate, the cold on the far side
local rimpts, coldpts = {}, {}
for i = 0, 24 do local t = math.pi * (0.55 + 0.45 * i / 24); rimpts[#rimpts + 1] = {470 + 330 * math.cos(t), 1122 + 56 * math.sin(t) * -1} end
S(rig, GOLDM, 0.8, {{145,1124},{170,1150},{260,1172},{380,1178}}, {0.6, 0.1})
S(rig, COLDR, 0.7, {{560,1177},{680,1168},{770,1150},{798,1124}}, {0.1, 0.5})
-- radial seams across the disc's face
for _, a in ipairs({2.4, 1.9, 1.2, 0.6}) do
  S(rig, SHD, 0.6, {{470 + 150 * math.cos(a), 1122 + 25 * math.sin(a)}, {470 + 320 * math.cos(a), 1122 + 54 * math.sin(a)}}, {0.3, 0.4})
end
-- plates unfolding past the edge: small bronze slabs, each with a lit and a cold edge, smaller as they go
local BRZ_D = pile{{"bone black",2},{"burnt sienna",1},{"yellow ochre",1}}
local frs = {{840,1000,46,22,0.5},{900,1080,34,16,-0.4},{760,1260,40,18,0.9},{930,1180,24,11,0.2},{880,880,22,10,-0.9},{960,980,14,7,0.3},{690,1300,20,9,-0.3}}
for i, f in ipairs(frs) do
  local c, s = math.cos(f[5]), math.sin(f[5])
  local function P(u, v) return {f[1] + u * c - v * s, f[2] + u * s + v * c} end
  local q = poly({P(-f[3], -f[4]), P(f[3], -f[4]), P(f[3], f[4]), P(-f[3], f[4])})
  work(q, {hand="detail", pile=BRZ_D, coverage=3.5, fill=true, angle=f[5], clip=q, seed=1110 + i})
  S(rig, GOLDM, 0.6, {P(-f[3], -f[4]), P(f[3], -f[4])}, {0.35, 0.25})
  S(rig, COLDR, 0.5, {P(f[3], -f[4]), P(f[3], f[4])}, {0.3, 0.2})
end
-- the optic: one cold point; rosary beads restated
S(rig, ICE, 0.9, {{398,460},{406,460}}, {0.9, 0.9})
local BONE = pile{{"lead white",2},{"yellow ochre",1},{"raw sienna",0.4}}
for i = 0, 10 do
  local t = i / 10
  rig:reload(BONE, 0.8); rig:touch(394 + 12 * math.sin(math.pi * t), 645 + 115 * t, {pressure=0.95})
end

--@ chunk 12
-- the core must be the lightest thing: feathered pale stipple, densest behind his head, thinning outward, then blended
local hc = {330, 520}
local function hd(x, y) return math.sqrt((x - hc[1])^2 + ((y - hc[2]) * 0.85)^2) end
local keep = OPEN - FIGURE:grow(3)
local HOT  = pile{{"zinc white",4},{"lemon chrome",0.5},{"lead white",1}}
local WARM = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.3}}
local core = keep * ellipse(330, 520, 430, 500)
stipple(core, {pile=WARM, width=8, coverage=function(x, y) return clamp(1.8 * (1 - hd(x, y) / 430), 0, 1.8) end, feather=0.9, cluster=0.3, clip=keep, seed=1201})
stipple(core, {pile=HOT, width=7, coverage=function(x, y) return clamp(2.4 * (1 - hd(x, y) / 260), 0, 2.4) end, feather=0.9, cluster=0.3, clip=keep, seed=1202})
local function rad(x, y) return math.atan(y - hc[2], x - hc[1]) end
blend(core, {angle=rad, tool={kind="badger", width=18}, seed=1203})
blend(core, {angle=function(x, y) return rad(x, y) + math.pi / 2 end, tool={kind="badger", width=18}, seed=1204})

--@ chunk 13
-- quiet the dabbed blue cloud into the turn of the cold; both lights on the face-plate
local keep = COLD - FIGURE:grow(3)
local VEIL = pile{{"ultramarine blue",1},{"viridian",0.4},{"magenta",0.3},{"bone black",0.35},medium=0.7}
local m = keep * ellipse(800, 600, 230, 280):soften(60)
work(m, {hand="glaze", pile=VEIL, coverage=1.1, fill=true, angle=swirl, clip=keep, seed=1301})
blend(m, {angle=swirl, tool={kind="badger", width=20}, seed=1302})
local rig = brush{kind="rigger", width=2.6, point=0.85}
local fil = brush{kind="filbert", width=4}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.15, 0.3}}) end
local GOLDL = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local COLDR = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.2},{"cobalt violet",0.4}}
S(fil, COLDR, 0.35, {{462,486},{466,505},{458,526}}, {0.4, 0.3})
S(rig, COLDR, 0.6, {{430,532},{452,533},{470,522}}, {0.45, 0.35})
S(rig, GOLDL, 0.9, {{397,426},{391,466},{395,514}}, {0.55, 0.45})
S(rig, GOLDL, 0.7, {{372,590},{367,612},{370,638}}, {0.5, 0.35})

--@ chunk 14
-- the helm reads as a blob: a cheek-plate edge, a vent grille, a brighter optic
local rig = brush{kind="rigger", width=2.8, point=0.8}
local function S(p, ld, pts, pr) rig:reload(p, ld); rig:stroke(pts, {pressure=pr, ramps={0.15, 0.3}}) end
local SEAM = pile{{"bone black",2},{"ultramarine blue",0.5}}
local GOLDM = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.15}}
local ICE = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
S(SEAM, 0.8, {{432,420},{438,470},{430,528}}, {0.6, 0.5})
S(GOLDM, 0.6, {{428,424},{433,470},{426,526}}, {0.35, 0.3})
for i = 0, 3 do S(SEAM, 0.7, {{400 + i * 7, 488},{402 + i * 7, 512}}, {0.45, 0.4}) end
S(SEAM, 0.9, {{395,456},{430,454}}, {0.9, 0.7})
rig:reload(ICE, 1.0); rig:touch(404, 456, {pressure=1.0}); rig:reload(ICE, 1.0); rig:touch(408, 456, {pressure=0.9})

--@ chunk 15
print(wait(2*24*60))

--@ chunk 16
-- rebuild the frame as armour: every plate dark, gold-lit along its gate side, cold-lit along its far side
DARKSTEEL = pile{{"bone black",1.6},{"ultramarine blue",0.6},{"burnt sienna",0.4}}
P_GOLDD = pile{{"burnt sienna",1},{"yellow ochre",1},{"bone black",0.5},{"lead white",0.3}}
P_GOLDM = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.1}}
P_COLD  = pile{{"viridian",1},{"ultramarine blue",1},{"bone black",0.6},{"lead white",0.7}}
PLATESF = {}
local function bbox(pts)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0 = math.min(x0, p[1]); y0 = math.min(y0, p[2]); x1 = math.max(x1, p[1]); y1 = math.max(y1, p[2]) end
  return x0, y0, x1, y1
end
-- o: lit = width of the gold band, cold = width of the cold band, ang = stroke angle, front = share of bbox counted as gate side
function armplate(name, pts, o, seed)
  o = o or {}
  local P = poly(pts, true) - HOOD
  local x0, y0, x1, y1 = bbox(pts)
  local w, h = x1 - x0, y1 - y0
  local ang = o.ang or 1.45
  work(P, {hand="body", tool="filbert 3", pile=DARKSTEEL, coverage=4.2, fill=true, angle=ang, clip=P, seed=seed})
  local lw = o.lit or math.max(5, w * 0.28)
  local litz = rect(x0 - 4, y0 - 4, w * (o.front or 0.55) + 4, h + 8)
  local band = P:rim(lw, 2) * litz
  work(band, {hand="body", tool="filbert 2", pile=P_GOLDD, coverage=3, fill=true, angle=ang, clip=P, seed=seed + 1})
  local edge = P:rim(math.max(2, lw * 0.35), 1) * litz
  work(edge, {hand="detail", pile=P_GOLDM, coverage=3, fill=true, angle=ang, clip=P, seed=seed + 2})
  local coldz = rect(x0 + w * (o.back or 0.6), y0 - 4, w + 4, h + 8)
  local cb = P:rim(o.cold or math.max(3, w * 0.15), 1) * coldz
  work(cb, {hand="body", tool="filbert 2", pile=P_COLD, coverage=2.5, fill=true, angle=ang, clip=P, seed=seed + 3})
  PLATESF[#PLATESF + 1] = {name = name, pts = pts}
end
local A = {}
-- legs first (furthest down, and under the arm's line of sight), then torso, arm, head
armplate("greave", {{428,1064},{560,1066},{642,1072},{648,1108},{560,1112},{430,1112}}, {ang=0.05, lit=7, front=0.4}, 1501)
armplate("sole", {{646,1046},{688,1050},{702,1112},{650,1114}}, {ang=1.5, lit=6, front=0.3, back=0.5}, 1505)
armplate("cuisse1", {{492,792},{560,804},{536,900},{462,888}}, {ang=1.9}, 1510)
armplate("cuisse2", {{460,896},{534,906},{486,1040},{412,1028}}, {ang=1.9}, 1515)
armplate("kneecop", {{392,1034},{426,1030},{446,1056},{436,1090},{400,1096},{382,1066}}, {ang=1.6, lit=10}, 1520)
armplate("fauld3", {{448,768},{560,772},{562,808},{452,806}}, {ang=0.1, lit=10}, 1525)
armplate("fauld2", {{440,738},{566,742},{566,774},{446,772}}, {ang=0.1, lit=10}, 1530)
armplate("fauld1", {{434,706},{572,710},{572,744},{440,742}}, {ang=0.1, lit=10}, 1535)
armplate("back", {{500,590},{562,594},{588,650},{580,712},{530,708},{504,672}}, {ang=1.5, front=0.3, back=0.55}, 1540)
armplate("breast", {{426,560},{474,556},{504,588},{508,660},{492,708},{436,710},{422,652},{418,600}}, {ang=1.5, lit=14}, 1545)
armplate("gorget", {{424,530},{468,524},{492,542},{474,562},{432,562}}, {ang=0.2, lit=8}, 1550)
armplate("rerebrace", {{506,604},{546,606},{534,690},{496,686}}, {ang=1.65, front=0.45}, 1555)
armplate("pauldron", {{468,552},{508,538},{548,550},{566,584},{552,620},{520,612},{490,596},{470,578}}, {ang=0.5, lit=10}, 1560)
armplate("couter", {{482,700},{518,694},{532,722},{514,752},{484,746},{474,724}}, {ang=0.8, lit=8}, 1565)
armplate("vambrace", {{438,614},{506,706},{488,736},{418,636}}, {ang=-2.2, lit=8, front=0.5}, 1570)
armplate("gauntlet", {{370,592},{398,582},{420,594},{430,626},{414,648},{384,646},{366,624}}, {ang=1.4, lit=9}, 1575)
armplate("faceplate", {{391,452},{430,450},{436,472},{430,526},{410,532},{394,514},{388,482}}, {ang=1.55, lit=9, front=0.5}, 1580)
armplate("cheek", {{434,452},{470,456},{478,490},{466,524},{434,528},{440,488}}, {ang=1.55, front=0.25, back=0.5}, 1585)
armplate("dome", {{394,428},{410,410},{440,402},{466,404},{474,428},{470,452},{434,452},{394,452}}, {ang=0.3, lit=9}, 1590)
print(#PLATESF)

--@ chunk 17
-- the cloak's folds: valleys in dark crimson, crests in a lighter red, run down from the shoulder and fanning to the pool
local cl = (CLOAK + HOOD) - ARMOUR:grow(1)
local VALLEY = pile{{"rose madder",1},{"bone brown",0.8},{"bone black",0.3}}
local CREST  = pile{{"vermilion",1},{"cadmium red",0.6},{"lead white",0.35}}
local fil = brush{kind="filbert", width=7}
local folds = {
  {{{540,560},{565,760},{590,950},{610,1105}}, VALLEY}, {{{556,570},{585,760},{618,960},{642,1108}}, CREST},
  {{{575,600},{610,780},{650,960},{676,1108}}, VALLEY}, {{{592,640},{630,800},{672,980},{704,1108}}, CREST},
  {{{612,660},{646,820},{694,1000},{728,1106}}, VALLEY}, {{{528,470},{540,520},{556,560}}, VALLEY},
  {{{500,420},{516,460},{512,500}}, CREST}, {{{582,760},{592,900},{596,1040}}, CREST},
}
for i, f in ipairs(folds) do
  fil:reload(f[2], 0.7)
  fil:stroke(f[1], {pressure={0.65, 0.5}, ramps={0.2, 0.3}, clip=cl})
end
blend(cl, {angle=1.35, tool={kind="badger", width=10}, seed=1801})
-- the gold: cover the speckled ring with the colour either side of it, blend round and out
local hc = {330, 520}
local function hd(x, y) return math.sqrt((x - hc[1])^2 + ((y - hc[2]) * 0.85)^2) end
local keep = OPEN - FIGURE:grow(4)
local band = keep * mask(function(x, y) local d = hd(x, y); return (d > 200 and d < 330) and 1 or 0 end):soften(20)
local GMID = pile{{"cadmium yellow",1},{"Indian yellow",0.4},{"lead white",1.4}}
local function circ(x, y) return math.atan(y - hc[2], x - hc[1]) + math.pi / 2 end
work(band, {hand="body", tool="filbert 7", pile=GMID, coverage=2.2, fill=true, angle=circ, length={40, 100}, clip=keep, seed=1802})
blend(band:grow(15) * keep, {angle=circ, tool={kind="badger", width=16}, seed=1803})
blend(band:grow(15) * keep, {angle=function(x, y) return circ(x, y) - math.pi / 2 end, tool={kind="badger", width=16}, seed=1804})

--@ chunk 18
print(wait(3*24*60)); print(drying(470,650))

--@ chunk 19
-- on dry plates: the dark between them, hard glints on the gate edges, the cold on the far edges;
-- the optic, the closed gauntlet, the rosary and the bone cross
local rig = brush{kind="rigger", width=2.4, point=0.85}
local flat = brush{kind="flat", width=4.5}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.15, 0.3}}) end
local SEAM  = pile{{"bone black",2},{"ultramarine blue",0.5}}
local GL    = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local GM    = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.1}}
local CL    = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.5},{"cobalt violet",0.3}}
local ICE   = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local BONE  = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.3}}
local BONED = pile{{"raw sienna",1},{"bone brown",0.6},{"lead white",0.8}}
-- seams
for _, s in ipairs({
  {{434,706},{500,708},{572,710}}, {{440,740},{566,742}}, {{446,772},{566,774}}, {{452,806},{560,808}},
  {{426,561},{450,560},{474,560}}, {{470,580},{500,600},{522,612},{552,620}}, {{462,890},{536,902}},
  {{394,452},{434,451},{470,454}}, {{433,452},{438,490},{432,528}}, {{392,1034},{426,1030}}, {{482,700},{500,698}}}) do
  S(rig, SEAM, 0.8, s, {0.6, 0.5})
end
-- gold glints on the edges that face the gate
for _, s in ipairs({
  {{396,432},{392,450}}, {{390,458},{388,482},{394,512}}, {{420,600},{418,630},{423,660}}, {{436,708},{436,738}},
  {{442,742},{446,770}}, {{450,774},{452,804}}, {{394,1040},{383,1064},{398,1094}}, {{466,892},{440,960},{414,1026}},
  {{426,532},{445,527}}, {{470,556},{490,544},{508,540}}, {{430,1066},{520,1066}}, {{418,638},{438,614}}}) do
  S(rig, GL, 0.8, s, {0.55, 0.35})
end
-- the cold on the far edges
for _, s in ipairs({
  {{548,552},{566,584},{552,620}}, {{470,458},{478,490},{466,524}}, {{586,652},{580,710}}, {{530,722},{516,750}},
  {{688,1052},{702,1110}}, {{560,806},{536,900}}, {{534,906},{488,1040}}, {{472,412},{476,432}}, {{506,592},{508,660}}}) do
  S(rig, CL, 0.7, s, {0.4, 0.3})
end
-- visor slit and the optic
S(rig, SEAM, 0.9, {{390,467},{412,466},{432,464}}, {0.8, 0.6})
rig:reload(ICE, 1.0); rig:touch(399, 466, {pressure=1.0}); rig:reload(ICE, 1.0); rig:touch(403, 466, {pressure=0.8})
-- the gauntlet closed: finger lames across the fist, knuckles in gold
for i, y in ipairs({598, 610, 622, 634}) do
  S(rig, SEAM, 0.7, {{372, y},{392, y - 2},{414, y + 2}}, {0.45, 0.35})
  S(rig, GM, 0.6, {{370, y + 4},{378, y + 4}}, {0.5, 0.3})
end
-- the rosary: beads over the fist and hanging below it
for i = 0, 5 do rig:reload(BONE, 0.8); rig:touch(376 + i * 8, 587 - math.sin(i / 5 * math.pi) * 4, {pressure=1.0}) end
for i = 0, 12 do
  local t = i / 12
  rig:reload(BONE, 0.8); rig:touch(400 + 10 * math.sin(math.pi * t * 0.8), 652 + 108 * t, {pressure=1.0})
end
-- the bone cross: a pale body, gold down its gate side, a shadow down its other side
S(flat, BONE, 0.9, {{412,764},{412,818}}, {0.8, 0.8})
S(flat, BONE, 0.9, {{397,782},{427,782}}, {0.8, 0.8})
S(rig, GL, 0.8, {{409,766},{409,816}}, {0.4, 0.4})
S(rig, BONED, 0.7, {{415.5,788},{415.5,816}}, {0.35, 0.35})

--@ chunk 20
-- the glints were hairlines: restate the gate-side lights with a small filbert, the optic and the cross larger
local fb = brush{kind="filbert", width=3.2}
local fl = brush{kind="flat", width=6}
local function S(b, p, ld, pts, pr) b:reload(p, ld); b:stroke(pts, {pressure=pr or {0.6, 0.5}, ramps={0.2, 0.35}}) end
local GL  = pile{{"lead white",2},{"cadmium yellow",1},{"Indian yellow",0.4}}
local GM  = pile{{"yellow ochre",1.5},{"Mars orange",0.6},{"lead white",1},{"bone black",0.1}}
local CL  = pile{{"viridian",1},{"cerulean blue",1},{"lead white",1.5},{"cobalt violet",0.3}}
local ICE = pile{{"emerald green",1},{"cerulean blue",1},{"zinc white",4}}
local BONE = pile{{"lead white",2.5},{"yellow ochre",1},{"raw sienna",0.3}}
for _, s in ipairs({
  {{399,420},{394,440}}, {{392,474},{390,494},{396,514}}, {{423,575},{420,605},{422,640}}, {{440,712},{442,736}},
  {{446,746},{448,768}}, {{454,778},{456,800}}, {{398,1044},{388,1066},{400,1090}}, {{462,900},{440,960},{420,1020}},
  {{372,600},{369,620},{374,640}}, {{474,560},{496,546},{514,542}}, {{396,428},{420,410},{444,404}}}) do
  S(fb, GM, 0.7, s, {0.55, 0.45})
  S(fb, GL, 0.6, s, {0.3, 0.2})
end
for _, s in ipairs({{{552,560},{566,588},{552,616}}, {{474,466},{478,494},{468,520}}, {{584,656},{580,704}}, {{690,1058},{700,1106}}}) do
  S(fb, CL, 0.6, s, {0.4, 0.3})
end
-- optic
fl:reload(ICE, 1.0); fl:touch(401, 466, {pressure=0.9})
-- the bone cross, larger and clear below the gauntlets
S(fl, BONE, 0.9, {{412,762},{412,826}}, {0.9, 0.9})
S(fl, BONE, 0.9, {{394,784},{430,784}}, {0.9, 0.9})
S(fb, GL, 0.7, {{408,764},{408,824}}, {0.35, 0.35})

--@ chunk 21
-- the pale core now ends in a hard edge: lay the colour between core and yellow across it and blend it out
local hc = {330, 520}
local function hd(x, y) return math.sqrt((x - hc[1])^2 + ((y - hc[2]) * 0.85)^2) end
local keep = OPEN - FIGURE:grow(4)
local band = keep * mask(function(x, y) local d = hd(x, y); return (d > 150 and d < 240) and 1 or 0 end):soften(15)
local GPALE = pile{{"lead white",2},{"cadmium yellow",0.8},{"zinc white",0.6},{"Indian yellow",0.2}}
local function circ(x, y) return math.atan(y - hc[2], x - hc[1]) + math.pi / 2 end
work(band, {hand="body", tool="filbert 7", pile=GPALE, coverage=2.0, fill=true, angle=circ, length={40, 100}, clip=keep, seed=2101})
blend(band:grow(20) * keep, {angle=function(x, y) return circ(x, y) - math.pi / 2 end, tool={kind="badger", width=16}, seed=2102})
blend(band:grow(20) * keep, {angle=circ, tool={kind="badger", width=16}, seed=2103})
