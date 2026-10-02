-- easel session "testator_child": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=500, aspect=0.8, linen={22,20}, seed=171,
  ground={{pile={{"lead white",3},{"raw sienna",1}}, um=100, apply="knife", texture=0.3},
          {pile={{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"lead white",0.3}}, um=35, apply="roller"}}}

--@ chunk 2
-- child proportions from the portrait layout: the vault's back sweep shortened, the whole head large and bowed toward the table
function TX(p) local x, y = p[1], p[2]; if x > 520 then x = 520 + (x - 520) * 0.62 end
  local cx, cy = 300 + (x - 372) * 0.95, 250 + (y - 150) * 0.95
  local a = 0.22; local ox, oy = 480, 520
  return {ox + (cx - ox) * math.cos(a) - (cy - oy) * math.sin(a), oy + (cx - ox) * math.sin(a) + (cy - oy) * math.cos(a)} end
function TP(pts) local t = {} for i, p in ipairs(pts) do t[i] = TX(p) end return t end
SKULL = poly(TP({{372,420},{384,320},{430,232},{520,176},{640,150},{748,166},{800,226},{786,298},{720,358},{650,416},{610,510},{590,610},{548,690},{486,724},{432,700},{398,630},{378,530}}), true)
BODY = poly({{180,1250},{210,1040},{290,900},{400,830},{560,820},{680,880},{760,1000},{800,1250}}, true)
TABLE = poly({{0,1010},{560,980},{580,1060},{0,1100}})
FIG = SKULL + BODY
BG1 = pile{{"bone brown",2},{"bone black",0.9},{"burnt sienna",0.3}}
BGM = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.5},{"raw sienna",0.2}}
BG2 = pile{{"bone brown",2},{"raw sienna",0.8},{"burnt sienna",0.5},{"lead white",0.3}}
local bg = everywhere() - FIG:grow(3) - TABLE
local function ring(r0, r1) return bg * (ellipse(0, 250, r1, r1) - ellipse(0, 250, r0, r0)) end
work(ring(0, 420), {hand="body", pile=BG2, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(ring(420, 720), {hand="body", pile=BGM, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
work(ring(720, 2000), {hand="body", pile=BG1, coverage=3.5, fill=true, clip=bg, angle=math.pi/2})
blend(ring(390, 450), {angle=-0.7}); blend(ring(690, 750), {angle=-0.7})

--@ chunk 3
TU = pile{{"rose madder",0.5},{"red earth",0.6},{"bone brown",0.8},{"bone black",0.2},{"lead white",0.2}}
TUD = pile{{"red earth",0.6},{"bone brown",1},{"bone black",0.5}}
TT = pile{{"burnt sienna",1},{"raw sienna",0.9},{"bone brown",0.6}}
work(BODY - SKULL, {hand="body", pile=TU, coverage=3.5, fill=true, clip=BODY - SKULL, angle=math.pi/2, tool="filbert 9"})
work(TABLE - BODY, {hand="body", pile=TT, coverage=3.5, fill=true, clip=TABLE - BODY, angle=0, tool="filbert 9"})
work(SKULL, {hand="body", pile=pile{{"raw sienna",1},{"bone brown",1},{"lead white",0.9},{"ultramarine ash",0.2}}, coverage=3.5, fill=true, clip=SKULL})

--@ chunk 4
wait(4 * 24 * 60)
Q1 = pile{{"bone brown",2},{"burnt sienna",0.6},{"bone black",0.4}}
Q2 = pile{{"bone brown",1.6},{"burnt sienna",1},{"raw sienna",0.6},{"bone black",0.2}}
Q3 = pile{{"burnt sienna",1.2},{"raw sienna",1.4},{"bone brown",0.7},{"lead white",0.2}}
Q4 = pile{{"raw sienna",2},{"burnt sienna",0.6},{"yellow ochre",1},{"lead white",0.35}}
Q5 = pile{{"yellow ochre",2},{"raw sienna",0.8},{"lead white",0.7},{"vermilion",0.05}}
B1 = pile{{"raw sienna",1},{"bone brown",0.6},{"lead white",1.1},{"ultramarine ash",0.25}}
B2 = pile{{"lead white",2},{"raw sienna",0.6},{"bone brown",0.25},{"ultramarine ash",0.15}}
B3 = pile{{"lead white",3},{"yellow ochre",0.55},{"raw sienna",0.25}}
B4 = pile{{"lead white",3},{"zinc white",0.5},{"yellow ochre",0.35}}
BD = pile{{"raw sienna",1},{"bone brown",1},{"lead white",0.7},{"ultramarine ash",0.25}}
-- the child's vault: fewer, larger, smoother plates
HFo = {
  {{{372,420},{384,320},{430,232},{520,176},{520,260},{470,330},{420,400}}, B4},
  {{{520,176},{640,150},{748,166},{700,240},{600,262},{520,260}}, B3},
  {{{748,166},{800,226},{786,298},{720,358},{700,300},{700,240}}, B1},
  {{{520,260},{600,262},{700,240},{700,300},{720,358},{650,416},{600,440},{560,382},{470,330}}, B2},
  {{{376,402},{420,400},{470,330},{560,382},{600,440},{560,452},{480,432},{410,442}}, B3},
  {{{372,452},{410,442},{480,432},{500,522},{460,602},{400,622},{378,530}}, Q5},
  {{{480,432},{560,452},{600,440},{620,500},{580,562},{500,522}}, Q4},
  {{{600,440},{650,416},{612,510},{596,602},{580,562},{620,500}}, Q3},
  {{{400,622},{460,602},{500,642},{490,702},{450,714},{420,682}}, B3},
  {{{460,602},{500,522},{580,562},{596,602},{562,682},{500,642}}, Q4},
  {{{450,714},{490,702},{500,642},{562,682},{548,692},{486,726}}, Q2},
}
HF = {}
for i, f in ipairs(HFo) do HF[i] = {TP(f[1]), f[2]}; local m = poly(HF[i][1]) * SKULL:grow(2); work(m, {hand="detail", pile=f[2], coverage=4, fill=true, clip=m}) end

--@ chunk 5
wait(2 * 24 * 60)
NECK = poly({{330,752},{396,748},{450,820},{380,840},{320,800}}) - SKULL:shrink(1)
work(NECK * rect(0,0,370,2000), {hand="detail", pile=Q4, coverage=4.5, fill=true, clip=NECK})
work(NECK * rect(370,0,300,2000), {hand="detail", pile=Q2, coverage=4.5, fill=true, clip=NECK})
-- the tunic leaning in toward the table: a shoulder rising to the neck, the near arm reaching forward
LEAN = poly({{240,1000},{280,900},{330,830},{400,812},{470,830},{430,900},{360,980},{300,1040}}, true) - SKULL
work(LEAN * rect(0,0,360,2000), {hand="detail", pile=pile{{"red earth",0.7},{"rose madder",0.4},{"bone brown",0.6},{"lead white",0.35}}, coverage=4.5, fill=true, clip=LEAN})
work(LEAN * rect(360,0,300,2000), {hand="detail", pile=TU, coverage=4.5, fill=true, clip=LEAN})
COLL = poly({{310,800},{356,780},{420,800},{460,830},{400,850},{336,840}}, true)
work(COLL, {hand="detail", pile=B2, coverage=4.5, fill=true, clip=COLL})

--@ chunk 6
wait(3 * 24 * 60)
EYE = pile{{"bone black",1},{"ultramarine blue",0.35},{"burnt sienna",0.3}}
local function bez(t) local a, b, c = TX({396,436}), TX({482,362}), TX({598,418}); local u = 1 - t; return {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]} end
local t, gap = 0.04, 0.27
local tb = brush{kind="round", width=2.2, point=0.2}
EYES = {}
for k = 1, 7 do
  local p = bez(t); local s = 1.25 * (1 - 0.06 * (k - 1))
  local x, y, rx, ry = p[1], p[2] + 1, 10 * s, 8 * s
  EYES[k] = {x, y, rx, ry}
  local sock = ellipse(x, y, rx + 3, ry + 3); work(sock, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=sock})
  local e = ellipse(x, y + 0.5, rx, ry); work(e, {hand="detail", pile=EYE, coverage=4.5, fill=true, clip=e})
  -- the lids barely down: wide open
  local lid = ellipse(x, y, rx + 3, ry + 3) * rect(0, 0, 2000, y - ry * 0.75); work(lid, {hand="detail", pile=B2, coverage=4.5, fill=true, clip=lid})
  tb:reload(pile{{"Mars orange",1},{"raw sienna",0.6},{"cadmium yellow",0.2}}, 0.8); tb:touch(x + rx * 0.15, y + ry * 0.3, {pressure=0.3})
  tb:reload(B4, 0.85); tb:touch(x - rx * 0.35, y - ry * 0.15, {pressure=0.24})
  t = t + gap; gap = gap * 0.72
end

--@ chunk 7
wait(4 * 24 * 60)
-- a band of bone across the face for the eyes to sit in, then larger eyes spread evenly along it
local function bez(t) local a, b, c = TX({390,446}), TX({482,368}), TX({610,420}); local u = 1 - t; return {u*u*a[1] + 2*u*t*b[1] + t*t*c[1], u*u*a[2] + 2*u*t*b[2] + t*t*c[2]} end
EYES = {}
for k = 1, 7 do local t = 0.03 + (k - 1) * 0.15; local p = bez(t); local r = 12.5 - (k - 1) * 1.1; EYES[k] = {p[1], p[2], r, r * 0.85} end
local band = nil
for _, e in ipairs(EYES) do local m = ellipse(e[1], e[2], e[3] + 5, e[4] + 5); band = band and (band + m) or m end
band = band * SKULL
work(band, {hand="detail", pile=B2, coverage=4.5, fill=true, clip=band})
local col = poly({{310,800},{356,780},{420,800},{460,830},{400,850},{336,840}}, true)
work(col * rect(0,0,380,2000), {hand="detail", pile=B3, coverage=4.5, fill=true, clip=col})
work(col * rect(380,0,300,2000), {hand="detail", pile=B1, coverage=4.5, fill=true, clip=col})

--@ chunk 8
wait(4 * 24 * 60)
local tb = brush{kind="round", width=2.6, point=0.2}
local d = brush{kind="round", width=1.2, point=0.8}
for k, e in ipairs(EYES) do
  local x, y, rx, ry = e[1], e[2], e[3], e[4]
  local o = ellipse(x, y, rx, ry); work(o, {hand="detail", pile=EYE, coverage=4.5, fill=true, clip=o})
  local lower = ellipse(x, y + ry * 0.3, rx * 0.8, ry * 0.5) * o; work(lower, {hand="detail", pile=pile{{"ultramarine blue",0.6},{"burnt sienna",0.5},{"bone black",0.5},{"lead white",0.35}}, coverage=4.5, fill=true, clip=lower})
  d:reload(BD, 0.8); d:stroke({{x - rx - 1, y - ry * 0.8}, {x, y - ry - 2}, {x + rx + 1, y - ry * 0.8}}, {pressure={0.2, 0.5, 0.2}})
  tb:reload(pile{{"Mars orange",1},{"raw sienna",0.6},{"cadmium yellow",0.2}}, 0.8); tb:touch(x + rx * 0.2, y + ry * 0.35, {pressure=0.34})
  tb:reload(B4, 0.9); tb:touch(x - rx * 0.35, y - ry * 0.25, {pressure=0.3})
end

--@ chunk 9
wait(2 * 24 * 60)
MOUTH = poly(TP({{412,664},{424,646},{446,638},{470,640},{488,652},{490,668},{474,688},{448,694},{424,686}}), true)
work(MOUTH, {hand="detail", pile=B2, coverage=4.5, fill=true, clip=MOUTH})
-- the tablet on the low table, tilted toward the window
TAB = poly({{120,966},{330,950},{356,1000},{140,1020}})
work(TAB, {hand="detail", pile=B3, coverage=4.5, fill=true, clip=TAB})
local te = poly({{140,1020},{356,1000},{358,1010},{142,1030}}); work(te, {hand="detail", pile=B1, coverage=4.5, fill=true, clip=te})
-- the arm reaching down to it
ARM = ribbon({{330,880},{290,930},{262,966}}, {40, 34, 28})
work(ARM * rect(0,0,300,2000), {hand="detail", pile=pile{{"red earth",0.7},{"rose madder",0.4},{"bone brown",0.6},{"lead white",0.35}}, coverage=4.5, fill=true, clip=ARM})
work(ARM * rect(300,0,300,2000), {hand="detail", pile=TU, coverage=4.5, fill=true, clip=ARM})

--@ chunk 10
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.2, point=0.8}
local a, b = TX({414,668}), TX({488,664})
d:reload(Q1, 0.85); d:stroke({a, {(a[1] + b[1]) / 2, (a[2] + b[2]) / 2 + 1}, b}, {pressure={0.4, 0.55, 0.4}, clip=MOUTH:grow(0.5)})
for _, x in ipairs{430, 448, 466} do local p0, p1 = TX({x, 646}), TX({x - 1, 686}); d:reload(BD, 0.6); d:stroke({p0, p1}, {pressure={0.1, 0.35, 0.1}, clip=MOUTH}) end
function seg(p0, p1, w0, w1) local dx, dy = p1[1] - p0[1], p1[2] - p0[2]; local l = math.sqrt(dx*dx + dy*dy); local nx, ny = -dy / l, dx / l
  return poly({{p0[1] + nx*w0, p0[2] + ny*w0}, {p1[1] + nx*w1, p1[2] + ny*w1}, {p1[1] - nx*w1, p1[2] - ny*w1}, {p0[1] - nx*w0, p0[2] - ny*w0}}) end
local function finger(J, w, P)
  for k = 1, #J - 1 do local m = seg(J[k], J[k+1], w * (1 - 0.1 * (k - 1)), w * (1 - 0.1 * k) * 0.92); work(m, {hand="detail", pile=P[(k % 2) + 1], coverage=4.5, fill=true, clip=m}) end
  for k = 2, #J - 1 do d:reload(Q1, 0.85); d:touch(J[k][1], J[k][2], {pressure=0.4}) end
  local und = {} for k, p in ipairs(J) do und[k] = {p[1] + 1, p[2] + 3} end
  d:reload(Q1, 0.8); d:stroke(und, {pressure={0.4, 0.3}})
end
-- the hand: a small back plate, fingers clenched tight round the stylus, knuckles high
local hb = poly({{236,950},{270,940},{282,968},{248,980}}); work(hb, {hand="detail", pile=Q4, coverage=4.5, fill=true, clip=hb})
local st = brush{kind="round", width=3.2, point=0.5}
st:reload(B4, 0.9); st:stroke({{262,906},{238,946},{212,984}}, {pressure={0.8, 0.7, 0.1}, ramps={0.05, 0.5}})
for i, J in ipairs{{{238,950},{226,940},{220,930},{226,924},{236,928}}, {{240,960},{224,954},{216,944},{222,936},{232,940}}, {{246,970},{230,968},{222,958},{228,950},{238,954}}} do finger(J, 4.4 - i * 0.3, {Q5, Q4}) end
-- the thumb pressing down hard on the stylus
finger({{252,952},{244,938},{240,926},{246,918}}, 4.2, {Q5, Q4})

--@ chunk 11
wait(3 * 24 * 60)
-- clear the small hand back to tablet and table
local zone = poly({{200,900},{300,900},{300,990},{200,990}})
work(zone * TAB, {hand="detail", pile=B3, coverage=4.5, fill=true, clip=zone * TAB})
work((zone - TAB) - BODY - ARM, {hand="detail", pile=BGM, coverage=4.5, fill=true, clip=(zone - TAB) - BODY - ARM})
ARM2 = ribbon({{360,860},{320,910},{288,946}}, {48, 42, 36}) - SKULL
work(ARM2 * rect(0,0,330,2000), {hand="detail", pile=pile{{"red earth",0.7},{"rose madder",0.4},{"bone brown",0.6},{"lead white",0.35}}, coverage=4.5, fill=true, clip=ARM2})
work(ARM2 * rect(330,0,300,2000), {hand="detail", pile=TU, coverage=4.5, fill=true, clip=ARM2})

--@ chunk 12
wait(3 * 24 * 60)
local d = brush{kind="round", width=1.4, point=0.8}
local function finger(J, w, P)
  for k = 1, #J - 1 do local m = seg(J[k], J[k+1], w * (1 - 0.1 * (k - 1)), w * (1 - 0.1 * k) * 0.92); work(m, {hand="detail", pile=P[(k % 2) + 1], coverage=4.5, fill=true, clip=m}) end
  for k = 2, #J - 1 do d:reload(Q1, 0.85); d:touch(J[k][1], J[k][2], {pressure=0.45}) end
  local und = {} for k, p in ipairs(J) do und[k] = {p[1] + 1.5, p[2] + 4.5} end
  d:reload(Q1, 0.8); d:stroke(und, {pressure={0.45, 0.3}})
end
-- the glyph, half-copied: a hexagon and the start of its smaller turned copy, scratched hard
local g = brush{kind="round", width=1.8, point=0.6}
local hex = {} for i = 0, 6 do local a = 0.1 + i * math.pi / 3; hex[#hex+1] = {176 + 22 * math.cos(a), 990 + 11 * math.sin(a)} end
g:reload(Q1, 0.85); g:stroke(hex, {pressure={0.55, 0.55}, ramps={0.05, 0.05}})
local inner = {} for i = 0, 3 do local a = 0.6 + i * math.pi / 3; inner[#inner+1] = {178 + 12 * math.cos(a), 991 + 6 * math.sin(a)} end
g:reload(Q1, 0.85); g:stroke(inner, {pressure={0.6, 0.6}, ramps={0.05, 0.05}})
-- the hand, big: back plate, stylus clenched in a fist of jointed fingers
local hb = poly({{226,920},{280,904},{298,950},{246,970}}); work(hb, {hand="detail", pile=Q4, coverage=4.5, fill=true, clip=hb})
local st = brush{kind="round", width=4.4, point=0.5}
st:reload(B4, 0.9); st:stroke({{262,850},{226,926},{196,994}}, {pressure={0.8, 0.8, 0.15}, ramps={0.05, 0.5}})
for i, J in ipairs{{{230,924},{210,912},{200,896},{208,884},{224,888}}, {{234,940},{212,932},{200,918},{208,904},{224,908}}, {{240,956},{218,952},{206,940},{212,926},{228,928}}} do finger(J, 7 - i * 0.4, {Q5, Q4}) end
finger({{258,922},{246,900},{240,880},{250,868}}, 6.4, {Q5, Q4})
-- knuckles white with effort, and the window catching them
local t = brush{kind="round", width=2.6, point=0.2}
for _, p in ipairs{{208,884},{208,904},{212,926},{250,868},{200,896}} do t:reload(pile{{"lead white",3},{"yellow ochre",0.3}}, 0.9); t:touch(p[1] - 1, p[2] - 2, {pressure=0.3}) end

--@ chunk 13
wait(3 * 24 * 60)
local keep = MOUTH:grow(1)
for _, e in ipairs(EYES) do keep = keep + ellipse(e[1], e[2], e[3] + 5, e[4] + 5) end
local clip = SKULL - keep
local s = brush{kind="round", width=1.5, point=0.6}
for _, f in ipairs(HF) do local p = f[1]; for i = 1, #p do s:reload(BD, 0.6); s:stroke({p[i], p[i % #p + 1]}, {pressure={0.3, 0.3}, ramps={0.05, 0.05}, clip=clip}) end end
local RIM = pile{{"lead white",3},{"yellow ochre",0.4},{"zinc white",0.3}}
local r = brush{kind="filbert", width=4}
r:reload(RIM, 1.0); r:stroke({TX({500,186}), TX({420,236}), TX({384,320}), TX({374,420})}, {pressure={0.2, 0.8, 0.7, 0.2}, ramps={0.2, 0.3}, clip=SKULL:grow(1)})
r:reload(pile{{"yellow ochre",1.5},{"lead white",1},{"raw sienna",0.3}}, 0.9); r:stroke({TX({376,470}), TX({380,560}), TX({398,630})}, {pressure={0.2, 0.6, 0.1}, ramps={0.2, 0.3}, clip=SKULL:grow(1)})
-- the tunic: a lit fold down the near shoulder and a shadow fold, cloth over a small body
TUL = pile{{"red earth",0.7},{"rose madder",0.4},{"bone brown",0.5},{"lead white",0.45}}
local b = BODY - SKULL - ARM2 - COLL
local function F(pts, p) local m = poly(pts) * b; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{360,840},{420,830},{400,1000},{380,1250},{330,1250},{350,1000}}, TUL)
F({{520,840},{600,860},{620,1000},{640,1250},{580,1250},{560,1000}}, TUD)
F({{640,900},{740,980},{780,1250},{680,1250},{660,1000}}, TUD)

--@ chunk 14
wait(3 * 24 * 60)
TUM = pile{{"rose madder",0.5},{"red earth",0.6},{"bone brown",0.9},{"bone black",0.3},{"lead white",0.15}}
TUQ = pile{{"rose madder",0.5},{"red earth",0.6},{"bone brown",0.8},{"bone black",0.2},{"lead white",0.28}}
local b = BODY - SKULL - ARM2 - COLL
local function F(pts, p) local m = poly(pts) * b; if m:area() > 4 then work(m, {hand="detail", pile=p, coverage=4.5, fill=true, clip=m}) end end
F({{360,840},{420,830},{400,1000},{380,1250},{330,1250},{350,1000}}, TUQ)
F({{520,840},{600,860},{620,1000},{640,1250},{580,1250},{560,1000}}, TUM)
F({{640,900},{740,980},{780,1250},{680,1250},{660,1000}}, TUM)
F({{740,980},{800,1100},{820,1250},{780,1250}}, pile{{"bone brown",1},{"bone black",0.5},{"red earth",0.3}})
