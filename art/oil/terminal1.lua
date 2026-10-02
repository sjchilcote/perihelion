-- easel session "terminal1": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=1000, aspect=1.778, linen={26,24}, seed=2077, ground={{pile={{"lead white",4},{"bone black",1}}, um=120, apply="knife", texture=0.12}, {pile={{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}}, um=45, apply="brush", texture=0.35}}}
VP = {860, 265}
SC = {370, 229}
FLOOR = poly({{-40, 600}, {-40, 480}, {700, 480}, {835, 290}, {885, 290}, {1040, 600}})
SCEIL = poly({{700, -40}, {1040, -40}, {885, 240}, {835, 240}})
SLWALL = poly({{700, -40}, {835, 240}, {835, 290}, {700, 480}})
SRWALL = poly({{885, 240}, {1040, -40}, {1040, 600}, {885, 290}})
FAREND = poly({{835, 240}, {885, 240}, {885, 290}, {835, 290}})
FWALL = poly({{-40, -40}, {700, -40}, {700, 480}, {-40, 480}})
FL = pile{{"bone black",2},{"Mars brown",0.5},{"ultramarine blue",0.4},{"lead white",0.1}}
CP = pile{{"bone black",2.6},{"ultramarine blue",0.6},{"Mars brown",0.2},{"lead white",0.03}}
SW = pile{{"bone black",2.4},{"ultramarine blue",0.7},{"Mars brown",0.2},{"lead white",0.05}}
local toVP = function(x,y) return math.atan(VP[2] - y, VP[1] - x) end
work(FLOOR, {hand="body", pile=FL, coverage=3, fill=true, clip=FLOOR, angle=toVP, length={20, 50}, tool="filbert 9"})
work(SCEIL + SLWALL, {hand="body", pile=CP, coverage=3, fill=true, clip=SCEIL + SLWALL, angle=toVP, length={20, 50}, tool="filbert 9"})
work(SRWALL + FAREND, {hand="body", pile=SW, coverage=3, fill=true, clip=SRWALL + FAREND, angle=toVP, length={15, 40}, tool="filbert 8"})

--@ chunk 2
print(wait(4*24*60))
HOUS = rect(220, 100, 300, 340)
SHELF = poly({{236, 372}, {504, 372}, {532, 410}, {208, 410}})
SHELFF = poly({{208, 410}, {532, 410}, {532, 424}, {208, 424}})
SCREEN = rect(262, 140, 216, 178)
GG = {
 pile{{"bone black",2},{"ultramarine blue",0.8},{"Mars brown",0.3},{"lead white",0.08}},
 pile{{"bone black",2},{"viridian",0.3},{"ultramarine blue",0.5},{"lead white",0.1}},
 pile{{"bone black",1.6},{"viridian",0.5},{"emerald green",0.2},{"lead white",0.2}},
 pile{{"bone black",1.1},{"viridian",0.5},{"emerald green",0.4},{"lead white",0.35}},
}
local region = (FWALL + FLOOR) - HOUS:grow(0.5) - SHELF - SHELFF
local cells = {}
for y = 60, 566, 3.2 do for x = -4, 760, 3.4 do
  local xx, yy = x + rand(-1.3,1.3), y + rand(-1.3,1.3)
  if region:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx, dy = xx - SC[1], (yy - SC[2])*1.1
    local d = math.sqrt(dx*dx + dy*dy)
    if d < 360 then
      local t = 4.2 - d/80 + randn(0, 0.3)
      local i = clamp(math.floor(t + 0.5), 1, 4)
      if i > 1 or rand(0,1) < 0.5 then cells[#cells+1] = {x=xx, y=yy, i=i} end
    end
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 4 do if g[i] then
  b:reload(GG[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(GG[i], 0.9) end
    local a = math.atan(c.y - SC[2], c.x - SC[1]) + randn(0, 0.05)
    local h = rand(3, 6)
    b:stroke({{c.x - math.cos(a)*h, c.y - math.sin(a)*h}, {c.x + math.cos(a)*h, c.y + math.sin(a)*h}}, {pressure={0.75, 0.6}, clip=region})
  end
end end
print(#cells)
-- the housing: heavy gunmetal block, darker toward its outer edges
HM = pile{{"bone black",1.6},{"ultramarine blue",0.4},{"lead white",0.25},{"viridian",0.1}}
work(HOUS, {hand="detail", pile=HM, coverage=4, fill=true, clip=HOUS, tool={kind="round", width=2.2}, length={4, 10}})
local SD = pile{{"bone black",2.2},{"ultramarine blue",0.3}}
work(SHELF + SHELFF, {hand="detail", pile=SD, coverage=4, fill=true, clip=SHELF + SHELFF, tool={kind="round", width=1.8}, length={3, 8}})
-- the screen: phosphor black
PB = pile{{"bone black",2},{"viridian",0.35},{"ultramarine blue",0.2}}
work(SCREEN, {hand="detail", pile=PB, coverage=4.5, fill=true, clip=SCREEN, tool={kind="round", width=1.8}, length={3, 8}})

--@ chunk 3
print(wait(4*24*60))
HM2 = pile{{"bone black",2},{"ultramarine blue",0.4},{"lead white",0.1},{"viridian",0.1}}
work(HOUS - SCREEN - SHELF - SHELFF, {hand="detail", pile=HM2, coverage=4.5, fill=true, clip=HOUS - SCREEN - SHELF - SHELFF, tool={kind="round", width=2.2}, length={4, 10}})
-- the floor under the terminal: green spill on the deck, graded from the wall foot
local FG = {
 FL,
 pile{{"bone black",2},{"Mars brown",0.3},{"viridian",0.3},{"lead white",0.12}},
 pile{{"bone black",1.6},{"viridian",0.5},{"emerald green",0.2},{"Mars brown",0.2},{"lead white",0.22}},
}
local fl = FLOOR * rect(-40, 478, 800, 130)
local cells = {}
for y = 478, 566, 2.8 do for x = -4, 760, 3.2 do
  local xx, yy = x + rand(-1.2,1.2), y + rand(-1.2,1.2)
  if fl:at(clamp(xx,0,999), clamp(yy,0,562)) > 0.5 then
    local dx = (xx - SC[1])/320
    local dy = (yy - 480)/90
    local v = 2.6 - 2.2*math.sqrt(dx*dx + dy*dy*0.7) + randn(0, 0.3)
    cells[#cells+1] = {x=xx, y=yy, i=clamp(math.floor(v + 0.5), 1, 3)}
  end
end end
local g = {}
for _, c in ipairs(cells) do g[c.i] = g[c.i] or {} table.insert(g[c.i], c) end
local b = brush{kind="filbert", width=4, stiffness=0.5}
for i = 1, 3 do if g[i] then
  b:reload(FG[i], 0.9)
  for n, c in ipairs(g[i]) do
    if n % 4 == 0 then b:load(FG[i], 0.9) end
    local h = rand(4, 8)
    b:stroke({{c.x - h, c.y}, {c.x + h, c.y}}, {pressure={0.75, 0.6}, clip=fl})
  end
end end
print(#cells)

--@ chunk 4
print(wait(4*24*60), drying(370,229))
local glow = ellipse(370, 229, 100, 82):soften(25) * SCREEN
local PGl = pile{{"bone black",1.4},{"viridian",0.5},{"emerald green",0.25},{"lead white",0.22}}
work(glow, {hand="detail", pile=PGl, coverage=3, fill=true, clip=SCREEN, tool={kind="round", width=2}, length={3, 8}, angle=0})
blend(SCREEN:shrink(2), {angle=0, tool={kind="badger", width=8}, length={15, 30}})
-- the bezel: inner lip catching the phosphor light
local lip = SCREEN:grow(5) - SCREEN
local LG = pile{{"bone black",1.3},{"viridian",0.5},{"emerald green",0.3},{"lead white",0.3}}
work(lip, {hand="detail", pile=LG, coverage=4, fill=true, clip=lip, tool={kind="round", width=1.2}, length={2, 5}})

--@ chunk 5
print(wait(5*24*60), drying(370,229))
FONT = {
 A = {{{0,1},{0.5,0},{1,1}}, {{0.2,0.6},{0.8,0.6}}},
 B = {{{0,0},{0,1}}, {{0,0},{0.7,0},{0.9,0.2},{0.7,0.48},{0,0.48}}, {{0.7,0.48},{1,0.72},{0.75,1},{0,1}}},
 C = {{{1,0.1},{0.8,0},{0.2,0},{0,0.2},{0,0.8},{0.2,1},{0.8,1},{1,0.9}}},
 D = {{{0,0},{0,1}}, {{0,0},{0.6,0},{1,0.3},{1,0.7},{0.6,1},{0,1}}},
 E = {{{1,0},{0,0},{0,1},{1,1}}, {{0,0.5},{0.7,0.5}}},
 F = {{{1,0},{0,0},{0,1}}, {{0,0.5},{0.7,0.5}}},
 L = {{{0,0},{0,1},{1,1}}},
 N = {{{0,1},{0,0},{1,1},{1,0}}},
 O = {{{0.2,0},{0.8,0},{1,0.2},{1,0.8},{0.8,1},{0.2,1},{0,0.8},{0,0.2},{0.2,0}}},
 R = {{{0,1},{0,0},{0.8,0},{1,0.2},{1,0.35},{0.8,0.5},{0,0.5}}, {{0.5,0.5},{1,1}}},
 S = {{{1,0.1},{0.8,0},{0.2,0},{0,0.2},{0.2,0.45},{0.8,0.55},{1,0.8},{0.8,1},{0.2,1},{0,0.9}}},
 T = {{{0,0},{1,0}}, {{0.5,0},{0.5,1}}},
 U = {{{0,0},{0,0.8},{0.2,1},{0.8,1},{1,0.8},{1,0}}},
 W = {{{0,0},{0.25,1},{0.5,0.4},{0.75,1},{1,0}}},
 Y = {{{0,0},{0.5,0.5},{1,0}}, {{0.5,0.5},{0.5,1}}},
 [":"] = {{{0.5,0.25},{0.5,0.32}}, {{0.5,0.75},{0.5,0.82}}},
}
function write(txt, x0, y0, cw, w, h, p, bw, pr)
  local br = brush{kind="rigger", width=bw, point=1, stiffness=0.5}
  local n = 0
  for i = 1, #txt do
    local ch = txt:sub(i, i)
    local g = FONT[ch]
    if g then for _, s in ipairs(g) do
      local pts = {}
      for _, q in ipairs(s) do pts[#pts+1] = {x0 + (i-1)*cw + q[1]*w, y0 + q[2]*h} end
      br:load(p, 0.95) br:stroke(pts, {pressure={pr, pr}, ramps={0.02, 0.02}})
      n = n + 1
    end end
  end
  return n
end
PG = pile{{"emerald green",1},{"lead white",1.3},{"lemon chrome",0.15}}
PGd = pile{{"viridian",0.6},{"emerald green",0.4},{"lead white",0.6},{"bone black",0.25}}
PA = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",0.5}}
-- green protocol header: blocky marks, words of varied length
local blk = brush{kind="filbert", width=2.6, stiffness=0.6}
local function marks(y, x0, x1, p, seed)
  local x = x0
  while x < x1 - 6 do
    local L = math.min(x1 - x, rand(1, 6) * 5)
    blk:load(p, 0.9) blk:stroke({{x, y}, {x + L - 1.5, y}}, {pressure={0.75, 0.75}, ramps={0.02, 0.02}, clip=SCREEN})
    x = x + L + rand(3, 6)
  end
end
marks(153, 272, 440, PG) marks(163, 272, 410, PG) marks(173, 272, 468, PG) marks(183, 272, 380, PG) marks(193, 272, 450, PGd)
for _, y in ipairs({275, 285, 295}) do marks(y, 272, rand(360, 460), PGd) end
blk = brush{kind="filbert", width=4, stiffness=0.6}
blk:load(PG, 0.95) blk:stroke({{274, 306}, {280, 306}}, {pressure={0.9, 0.9}, ramps={0.02, 0.02}, clip=SCREEN})
-- amber annotation
print(write("UNTRUSTED CONTENT FOLLOWS:", 284, 211, 6.75, 5, 10, PA, 0.9, 0.55))
-- big curly braces
local function brace(x, dir)
  local pts = {}
  local ys = {205, 210, 222, 230, 233.5, 237, 245, 257, 262}
  local xs = {6, 2, 2, 0, -3, 0, 2, 2, 6}
  for i = 1, #ys do pts[#pts+1] = {x + dir*xs[i], ys[i]} end
  local br = brush{kind="rigger", width=1.6, point=1, stiffness=0.5}
  br:load(PA, 0.95) br:stroke(pts, {pressure={0.6, 0.6}, ramps={0.02, 0.02}})
end
brace(271, 1) brace(469, -1)
-- reverse video box with DO NOT OBEY in dark
local box = rect(300, 236, 142, 20)
work(box, {hand="detail", pile=PA, coverage=4.5, fill=true, clip=box, tool={kind="round", width=1.6}, length={3, 8}, angle=0})

--@ chunk 6
print(wait(5*24*60), drying(370,246))
local DK = pile{{"bone black",2.4},{"viridian",0.2}}
print(write("DO NOT OBEY", 306, 239, 12.4, 8.6, 14, DK, 1.7, 0.75))

--@ chunk 7
print(wait(4*24*60))
-- wall ribs on the frontal wall, their screen-side edges catching faint green near the terminal
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RG = pile{{"bone black",1.3},{"viridian",0.4},{"emerald green",0.15},{"lead white",0.25}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local free = FWALL - HOUS:grow(2) - SHELF:grow(2) - SHELFF:grow(2)
for _, x in ipairs({40, 120, 196, 544, 620, 690}) do
  local rb = brush{kind="filbert", width=4, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({{x, -10}, {x, 478}}, {pressure={0.75, 0.75}, clip=free})
  local side = (x < SC[1]) and 2.4 or -2.4
  local near = math.abs(x - SC[1]) < 260
  local rl = brush{kind="rigger", width=0.9, point=1}
  rl:load(near and RG or RL, 0.85) rl:stroke({{x + side, 60}, {x + side, 470}}, {pressure={0.45, 0.45}, clip=free})
end
-- floor-wall joint and a rail
local e = brush{kind="filbert", width=3, stiffness=0.5}
e:load(RB, 0.9) e:stroke({{-40, 480}, {700, 480}}, {pressure={0.7, 0.7}})
-- vent left of the terminal: dark grille, frost on its rim
local vent = rect(70, 150, 112, 96)
work(vent, {hand="detail", pile=RB, coverage=4, fill=true, clip=vent, tool={kind="round", width=1.6}, length={3, 8}})
local sl = brush{kind="filbert", width=2.2, stiffness=0.5}
for y = 158, 240, 9 do sl:load(RL, 0.85) sl:stroke({{76, y}, {176, y}}, {pressure={0.6, 0.6}, clip=vent}) end
-- keyboard: rows of key caps on the shelf, a lit front edge
local KD = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"viridian",0.2},{"lead white",0.15}}
local k = brush{kind="filbert", width=3.2, stiffness=0.6}
for row = 0, 3 do
  local y = 377 + row*8
  local t = (y - 372)/38
  local x0, x1 = 236 - 28*t + 8, 504 + 28*t - 8
  local x = x0
  while x < x1 - 8 do
    k:load(KD, 0.9) k:stroke({{x, y}, {x + 7, y}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, clip=SHELF})
    x = x + 11 + ((row % 2) * 0.5)
  end
end
-- green light on the shelf top near the screen and on the housing's inner faces
local SG = pile{{"bone black",1.2},{"viridian",0.5},{"emerald green",0.35},{"lead white",0.35}}
local r = brush{kind="rigger", width=1.0, point=1}
r:load(SG, 0.9) r:stroke({{236, 372.5}, {504, 372.5}}, {pressure={0.6, 0.6}})
r:load(SG, 0.9) r:stroke({{210, 410.5}, {530, 410.5}}, {pressure={0.4, 0.4}})
-- the red arrow, hand-painted on the wall, pointing at the terminal
local AR = pile{{"vermilion",1},{"cadmium red",0.6},{"bone black",0.35}}
local shaft = poly({{564, 262}, {664, 258}, {666, 274}, {565, 278}}, true):roughen(1.2, 8, 3)
local head = poly({{536, 270}, {570, 244}, {566, 296}}, false):roughen(1.2, 8, 4)
local arrow = (shaft + head) * FWALL
work(arrow, {hand="detail", pile=AR, coverage=4, fill=true, clip=arrow, tool={kind="round", width=1.6}, length={3, 8}, angle=0})
local dr = brush{kind="rigger", width=1.0, point=1}
for _, x in ipairs({590, 622, 648}) do dr:load(AR, 0.8) dr:stroke({{x, 276}, {x + 0.5, 276 + rand(8, 20)}}, {pressure={0.5, 0.1}}) end

--@ chunk 8
print(wait(5*24*60), drying(370,390), drying(600,270))
-- the Commando's gauntlet reaching in from the lower right toward the keys
local function lim(pts, w0, w1)
  local L, R = {}, {}
  for i, p in ipairs(pts) do
    local a = pts[math.min(i+1, #pts)] local b = pts[math.max(i-1, 1)]
    local dx, dy = a[1] - b[1], a[2] - b[2] local l = math.sqrt(dx*dx + dy*dy) + 1e-6
    local w = w0 + (w1 - w0)*(i-1)/(#pts-1)
    L[#L+1] = {p[1] - dy/l*w, p[2] + dx/l*w} R[#R+1] = {p[1] + dy/l*w, p[2] - dx/l*w}
  end
  local out = {} for _, p in ipairs(L) do out[#out+1] = p end for i = #R, 1, -1 do out[#out+1] = R[i] end
  return poly(out, true)
end
VAM = lim({{1040, 610}, {820, 500}, {660, 432}}, 44, 30)
CUFF = lim({{676, 440}, {640, 424}}, 34, 30)
BACK = poly({{646, 408}, {600, 392}, {572, 396}, {566, 420}, {596, 446}, {644, 448}}, true)
THUMB = lim({{618, 444}, {588, 450}, {566, 444}}, 8, 6)
FING = {}
for i, f in ipairs({{{572, 398}, {548, 392}, {526, 388}}, {{570, 407}, {544, 402}, {520, 399}}, {{570, 416}, {546, 414}, {528, 414}}, {{574, 425}, {556, 428}, {542, 432}}}) do FING[i] = f end
local fm = nil
for _, f in ipairs(FING) do local m = lim(f, 6, 5) fm = fm and (fm + m) or m end
GAUNT = VAM + CUFF + BACK + THUMB + fm
FINGM = fm
local GM = pile{{"bone black",1.8},{"ultramarine blue",0.4},{"lead white",0.12}}
work(GAUNT, {hand="detail", pile=GM, coverage=4.5, fill=true, clip=GAUNT, tool={kind="round", width=2}, length={3, 8}})

--@ chunk 9
print(wait(6*24*60), drying(700,470))
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GRN = pile{{"viridian",0.6},{"emerald green",0.5},{"lead white",0.8},{"bone black",0.3}}
local GRM = pile{{"bone black",1.2},{"viridian",0.4},{"emerald green",0.2},{"lead white",0.3}}
local r
local function ln(p, pts, pr, w) r = brush{kind="rigger", width=w or 0.9, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.8}, clip=GAUNT:grow(0.6)}) end
-- mid plane: the upper faces turned toward the screen
local up = GAUNT - GAUNT:offset(0)
local m = nil
local VAMtop = poly({{1040, 566}, {820, 456}, {660, 402}, {660, 418}, {820, 476}, {1040, 586}}, true) * GAUNT
work(VAMtop, {hand="detail", pile=GRM, coverage=4, fill=true, clip=VAMtop, tool={kind="round", width=1.6}, length={3, 6}})
-- vambrace lames
for i, x in ipairs({940, 860, 780, 712}) do
  local t = (x - 660)/380
  local hw = 30 + 14*t
  local y = 432 + (610 - 432)*t
  ln(JD, {{x - hw*0.45, y - hw*0.9}, {x + hw*0.45, y + hw*0.9}}, 0.6, 1.4)
end
-- cuff edge, knuckle plate, finger lames
ln(JD, {{660, 410}, {646, 452}}, 0.6, 1.2)
ln(JD, {{600, 394}, {598, 444}}, 0.45, 0.9)
for _, f in ipairs(FING) do
  for k = 1, 2 do local a, b = f[k], f[k+1] local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2 ln(JD, {{mx, my - 6}, {mx, my + 6}}, 0.5, 0.8) end
end
-- green rim along every upper edge, the light from the screen
ln(GRN, {{1040, 566}, {820, 456}, {676, 404}}, 0.6, 1.1)
ln(GRN, {{646, 408}, {600, 392}, {574, 396}}, 0.55, 0.9)
for _, f in ipairs(FING) do
  local a, c = f[1], f[3]
  ln(GRN, {{a[1], a[2] - 5}, {f[2][1], f[2][2] - 5}, {c[1], c[2] - 4.5}}, 0.45, 0.7)
end
ln(GRN, {{618, 438}, {588, 444}, {566, 439}}, 0.35, 0.7)

--@ chunk 10
print(wait(4*24*60))
-- frost on the vent: pale blue-white rime crusting its rim and the slats' upper edges
local FR = pile{{"lead white",1.6},{"cerulean blue",0.25},{"ultramarine ash",0.2}}
local FR2 = pile{{"lead white",0.8},{"cerulean blue",0.3},{"viridian",0.2},{"bone black",0.3}}
local rim = (rect(66, 146, 120, 104) - rect(72, 152, 108, 92)):roughen(2, 10, 8)
stipple(rim, {pile=FR2, width=1.6, coverage=1.6, cluster={0.5, 6}, clip=rim})
local top = rect(66, 144, 120, 8):roughen(2, 8, 9)
stipple(top, {pile=FR, width=1.4, coverage=1.4, cluster={0.6, 5}, clip=top})
local s = brush{kind="rigger", width=0.8, point=1}
for y = 157, 239, 9 do s:load(FR2, 0.8) s:stroke({{78, y - 1.2}, {174, y - 1.2}}, {pressure={0.4, 0.3}}) end
for i = 1, 6 do local x = rand(72, 180) s:load(FR, 0.8) s:stroke({{x, 250}, {x + rand(-1, 1), 250 + rand(4, 12)}}, {pressure={0.4, 0.05}}) end
-- the far amber hazard lamp down the side corridor, and its small warm wash
local AW = pile{{"bone black",1},{"Mars orange",0.4},{"raw sienna",0.3},{"lead white",0.1}}
local wash = ellipse(895, 236, 18, 26) * SRWALL
work(wash, {hand="detail", pile=AW, coverage=3, fill=true, clip=wash, tool={kind="round", width=1.6}, length={2, 5}})
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local l = brush{kind="round", width=2.2, point=0.3}
l:load(AH, 0.95) l:touch(894, 232, {pressure=0.6})
local fl = brush{kind="filbert", width=3, stiffness=0.5}
fl:load(AW, 0.8) fl:stroke({{858, 296}, {878, 296}}, {pressure={0.5, 0.5}, clip=FLOOR})

--@ chunk 11
print(wait(6*24*60), drying(700,470), drying(895,236))
-- the gauntlet as plates: a mid grey-green on the plates, the dark kept in seams and the underside
local GP = pile{{"bone black",1.3},{"ultramarine blue",0.3},{"viridian",0.2},{"lead white",0.3}}
local under = poly({{1040, 650}, {820, 540}, {660, 462}, {660, 440}, {820, 515}, {1040, 625}}, true)
local plates = GAUNT - under
work(plates, {hand="detail", pile=GP, coverage=4.5, fill=true, clip=plates, tool={kind="round", width=1.6}, length={3, 7}})
-- the amber lamp, smaller: a lens in a dark housing and a narrow wash
local SW2 = pile{{"bone black",2.4},{"ultramarine blue",0.7},{"Mars brown",0.2},{"lead white",0.05}}
local big = ellipse(895, 236, 22, 30) * SRWALL
work(big, {hand="detail", pile=SW2, coverage=4.5, fill=true, clip=big, tool={kind="round", width=1.6}, length={2, 5}})

--@ chunk 12
print(wait(6*24*60), drying(700,470))
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GRN = pile{{"viridian",0.6},{"emerald green",0.5},{"lead white",0.8},{"bone black",0.3}}
local r
local function ln(p, pts, pr, w) r = brush{kind="rigger", width=w or 0.9, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.8}, clip=GAUNT:grow(0.6)}) end
for i, x in ipairs({940, 860, 780, 712}) do
  local t = (x - 660)/380
  local hw = 30 + 14*t
  local y = 432 + (610 - 432)*t
  ln(JD, {{x - hw*0.45, y - hw*0.9}, {x + hw*0.45, y + hw*0.9}}, 0.7, 1.6)
end
ln(JD, {{660, 410}, {646, 452}}, 0.7, 1.4)
ln(JD, {{600, 394}, {598, 444}}, 0.55, 1.0)
for _, f in ipairs(FING) do
  for k = 1, 2 do local a, b = f[k], f[k+1] local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2 ln(JD, {{mx, my - 6}, {mx, my + 6}}, 0.6, 0.9) end
  ln(JD, {{f[1][1], f[1][2] + 5}, {f[3][1], f[3][2] + 4.5}}, 0.5, 0.8)
end
ln(GRN, {{1040, 566}, {820, 456}, {676, 404}}, 0.6, 1.2)
ln(GRN, {{646, 408}, {600, 392}, {574, 396}}, 0.6, 1.0)
for _, f in ipairs(FING) do ln(GRN, {{f[1][1], f[1][2] - 5}, {f[2][1], f[2][2] - 5}, {f[3][1], f[3][2] - 4.5}}, 0.5, 0.7) end
-- fingertips touching the key edge catch the brightest green
local tip = brush{kind="round", width=1.6, point=0.3}
for _, f in ipairs(FING) do tip:load(GRN, 0.9) tip:touch(f[3][1] + 1, f[3][2] - 2, {pressure=0.5}) end
-- lamp lens, small
local AH = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local AW = pile{{"bone black",1},{"Mars orange",0.4},{"raw sienna",0.3},{"lead white",0.1}}
local w = ellipse(893, 236, 8, 13) * SRWALL
work(w, {hand="detail", pile=AW, coverage=3, fill=true, clip=w, tool={kind="round", width=1.2}, length={2, 4}})
local l = brush{kind="round", width=2.0, point=0.3}
l:load(AH, 0.95) l:touch(893, 233, {pressure=0.6})

--@ chunk 13
print(wait(4*24*60))
local GRN = pile{{"viridian",0.6},{"emerald green",0.5},{"lead white",0.8},{"bone black",0.3}}
local GRM = pile{{"bone black",1.2},{"viridian",0.45},{"emerald green",0.25},{"lead white",0.3}}
-- key caps catching the screen light on their tops
local k = brush{kind="rigger", width=0.8, point=1}
for row = 0, 3 do
  local y = 377 + row*8 - 2
  local t = (y + 2 - 372)/38
  local x0, x1 = 236 - 28*t + 8, 504 + 28*t - 8
  local x = x0
  while x < x1 - 8 do
    local d = math.abs(x + 3.5 - SC[1]) / 160
    if rand(0,1) < 1.1 - d then k:load((d < 0.5) and GRN or GRM, 0.85) k:stroke({{x + 0.5, y}, {x + 6.5, y}}, {pressure={0.4, 0.4}, clip=SHELF}) end
    x = x + 11 + ((row % 2) * 0.5)
  end
end
-- the housing's faces around the bezel lit faintly green, falling off outward
local face = (SCREEN:grow(26) - SCREEN:grow(6)) * HOUS
local g = brush{kind="filbert", width=3, stiffness=0.5}
local n = 0
for y = 112, 340, 3 do for x = 232, 508, 3.2 do
  local xx, yy = x + rand(-1,1), y + rand(-1,1)
  if face:at(xx, yy) > 0.5 then
    local dx = math.max(0, math.max(262 - xx, xx - 478))
    local dy = math.max(0, math.max(140 - yy, yy - 318))
    local d = math.max(dx, dy)
    if rand(0,1) < 0.75 - d/30 then n = n + 1 g:load(GRM, 0.8) g:stroke({{xx - 2, yy}, {xx + 2, yy}}, {pressure={0.6, 0.5}, clip=face}) end
  end
end end
print(n)

--@ chunk 14
local face = (SCREEN:grow(28) - SCREEN:grow(5)) * HOUS blend(face, {angle=function(x,y) return math.atan(y - SC[2], x - SC[1]) end, tool={kind="badger", width=6}, length={8, 16}})

--@ chunk 15
-- Pass 2.1: the housing face around the screen back to a dark squared casing
HM3 = pile{{"bone black",2},{"ultramarine blue",0.35},{"lead white",0.12}}
local face = HOUS - SCREEN - SHELF - SHELFF
work(face, {hand="detail", pile=HM3, coverage=5, fill=true, clip=face, tool={kind="round", width=2}, length={4, 10}, angle=0})
-- side corridor: a few ribs on the far wall and a floor line
local RB = pile{{"bone black",2.4},{"ultramarine blue",0.4}}
local RL = pile{{"bone black",1.3},{"ultramarine blue",0.4},{"lead white",0.3}}
local function rw(t, h) local x = 1040 + (885 - 1040)*t local yb = 600 + (290 - 600)*t local yt = -40 + (240 + 40)*t return {x, yb + (yt - yb)*h} end
local t = 0.1
while t < 0.95 do
  local w = clamp(2.6*(1 - t), 0.6, 2.6)
  local rb = brush{kind="filbert", width=w*1.6, stiffness=0.5}
  rb:load(RB, 0.9) rb:stroke({rw(t, 0.02), rw(t, 0.98)}, {pressure={0.7, 0.7}, clip=SRWALL})
  local rl = brush{kind="rigger", width=clamp(0.5*w, 0.3, 1.2), point=1}
  rl:load(RL, 0.8) rl:stroke({rw(t + 0.005, 0.02), rw(t + 0.005, 0.98)}, {pressure={0.4, 0.4}, clip=SRWALL})
  t = t + 0.13*(1 - t*0.8)
end
local ED = pile{{"bone black",1.4},{"ultramarine blue",0.5},{"lead white",0.22}}
local e = brush{kind="rigger", width=1.0, point=1}
e:load(ED, 0.8) e:stroke({{1040, 600}, {885, 290}}, {pressure={0.6, 0.2}})
e:load(ED, 0.8) e:stroke({{700, 480}, {835, 290}}, {pressure={0.6, 0.2}})
e:load(RB, 0.9) e:stroke({{835, 240}, {835, 290}, {885, 290}, {885, 240}}, {pressure={0.4, 0.4}})

--@ chunk 16
print(wait(6*24*60), drying(240,150), drying(370,229))
-- raised rim around the CRT: a squared lip, its inner edge catching green, outer edge dark
local RIM = SCREEN:grow(12) - SCREEN:grow(3)
local RM = pile{{"bone black",1.6},{"ultramarine blue",0.3},{"viridian",0.15},{"lead white",0.25}}
work(RIM, {hand="detail", pile=RM, coverage=4.5, fill=true, clip=RIM, tool={kind="round", width=1.6}, length={3, 8}, angle=0})
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local r = brush{kind="rigger", width=1.2, point=1}
r:load(JD, 0.9) r:stroke({{250, 128}, {490, 128}, {490, 330}, {250, 330}, {250, 128}}, {pressure={0.6, 0.6}})
-- casing panel seams and a raised outer border
local b = brush{kind="rigger", width=1.0, point=1}
local HL = pile{{"bone black",1.4},{"ultramarine blue",0.35},{"lead white",0.3}}
b:load(JD, 0.9) b:stroke({{226, 106}, {514, 106}, {514, 368}, {226, 368}, {226, 106}}, {pressure={0.55, 0.55}})
b:load(HL, 0.9) b:stroke({{228, 104}, {512, 104}}, {pressure={0.4, 0.4}})
b:load(JD, 0.9) b:stroke({{226, 346}, {514, 346}}, {pressure={0.5, 0.5}})
-- bolts at the corners and along the sides
local BO = pile{{"bone black",1.2},{"ultramarine blue",0.3},{"lead white",0.4}}
local bt = brush{kind="round", width=2.2, point=0.3}
for _, p in ipairs({{236, 116}, {504, 116}, {236, 356}, {504, 356}, {236, 236}, {504, 236}, {370, 116}, {370, 356}}) do
  bt:load(JD, 0.9) bt:touch(p[1] + 0.8, p[2] + 0.8, {pressure=0.6})
  bt:load(BO, 0.9) bt:touch(p[1], p[2], {pressure=0.45})
end

--@ chunk 17
print(wait(6*24*60), drying(256,150))
-- a narrow soft green falloff on the rim and face, only a step lighter, blended along the rim
local G1 = pile{{"bone black",1.4},{"viridian",0.45},{"emerald green",0.25},{"lead white",0.3}}
local G2 = pile{{"bone black",1.8},{"viridian",0.3},{"ultramarine blue",0.2},{"lead white",0.15}}
local s = brush{kind="filbert", width=2.6, stiffness=0.5}
local function band(off, p, n)
  local x0, x1, y0, y1 = 262 - off, 478 + off, 140 - off, 318 + off
  for i = 0, n do
    local f = i/n
    s:load(p, 0.8) s:stroke({{x0 + (x1-x0)*f - 6, y0}, {x0 + (x1-x0)*f + 6, y0}}, {pressure={0.55, 0.55}})
    s:load(p, 0.8) s:stroke({{x0 + (x1-x0)*f - 6, y1}, {x0 + (x1-x0)*f + 6, y1}}, {pressure={0.55, 0.55}})
  end
  for i = 0, math.floor(n*0.8) do
    local f = i/math.floor(n*0.8)
    s:load(p, 0.8) s:stroke({{x0, y0 + (y1-y0)*f - 6}, {x0, y0 + (y1-y0)*f + 6}}, {pressure={0.55, 0.55}})
    s:load(p, 0.8) s:stroke({{x1, y0 + (y1-y0)*f - 6}, {x1, y0 + (y1-y0)*f + 6}}, {pressure={0.55, 0.55}})
  end
end
band(5, G1, 26)
band(9, G2, 26)
local rim = SCREEN:grow(12) - SCREEN:grow(3)
blend(rim, {angle=0, tool={kind="badger", width=5}, length={10, 20}})

--@ chunk 18
print(wait(6*24*60), drying(256,150))
-- curved CRT glass: a faint reflection streak at the upper left corner, and a soft darker vignette at the corners
local RF = pile{{"lead white",1},{"viridian",0.3},{"emerald green",0.2},{"bone black",0.3}}
local s = brush{kind="filbert", width=3, stiffness=0.4}
s:load(RF, 0.6) s:stroke({{270, 168}, {276, 152}, {292, 146}}, {pressure={0.1, 0.45, 0.1}, swell={0.3, 1, 0.3}, clip=SCREEN})
s:load(RF, 0.5) s:stroke({{272, 182}, {278, 164}}, {pressure={0.05, 0.3, 0.05}, clip=SCREEN})
local VD = pile{{"bone black",2},{"viridian",0.3},{"ultramarine blue",0.2}}
local c = brush{kind="filbert", width=3, stiffness=0.4}
for _, q in ipairs({{{470, 146}, {478, 156}}, {{264, 308}, {272, 316}}, {{470, 316}, {478, 306}}}) do c:load(VD, 0.7) c:stroke(q, {pressure={0.4, 0.2}, clip=SCREEN}) end
-- the gauntlet's plates: knuckle plates and the cuff restated, green on edges facing the screen
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local GRN = pile{{"viridian",0.6},{"emerald green",0.5},{"lead white",0.8},{"bone black",0.3}}
local GP = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"viridian",0.25},{"lead white",0.38}}
local r
local function ln(p, pts, pr, w) r = brush{kind="rigger", width=w or 0.9, point=1} r:load(p, 0.9) r:stroke(pts, {pressure={pr, pr*0.8}, clip=GAUNT:grow(0.6)}) end
-- cuff: a flared ring of plate
local cuff = poly({{678, 400}, {690, 404}, {672, 462}, {660, 458}}, true) * GAUNT
work(cuff, {hand="detail", pile=GP, coverage=4, fill=true, clip=cuff, tool={kind="round", width=1.2}, length={2, 4}})
ln(JD, {{690, 404}, {672, 462}}, 0.7, 1.4)
-- knuckle plates: four small plates across the back of the hand
for i = 0, 3 do
  local y = 398 + i*9
  local kp = poly({{596, y - 3}, {608, y - 4}, {610, y + 4}, {598, y + 5}}, true) * GAUNT
  work(kp, {hand="detail", pile=GP, coverage=4, fill=true, clip=kp, tool={kind="round", width=0.9}, length={1.5, 3}})
  ln(JD, {{597, y + 5}, {610, y + 4}}, 0.5, 0.7)
  ln(GRN, {{596, y - 3}, {608, y - 4}}, 0.4, 0.6)
end
-- back-of-hand plate and its rim
ln(JD, {{614, 396}, {640, 404}, {644, 446}}, 0.5, 0.9)
ln(GRN, {{612, 393}, {640, 401}}, 0.45, 0.7)
-- rim along the vambrace's upper edge, broken by each lame
for i, seg in ipairs({{{1040, 566}, {945, 518}}, {{935, 513}, {865, 478}}, {{855, 473}, {785, 440}}, {{775, 436}, {716, 414}}, {{706, 410}, {680, 400}}}) do ln(GRN, seg, 0.55, 1.1) end

--@ chunk 19
print(wait(12*24*60), drying(240,150), drying(256,150))
local face = HOUS - SCREEN:grow(12) - SHELF - SHELFF
work(face, {hand="detail", pile=HM3, coverage=5, fill=true, clip=face, tool={kind="round", width=1.8}, length={4, 10}, angle=0})
-- wall around the housing where the old halo spilled, back to wall dark
local ring = HOUS:grow(14) - HOUS - SHELF:grow(1) - SHELFF:grow(1)
work(ring * FWALL, {hand="detail", pile=GG[1], coverage=4.5, fill=true, clip=ring * FWALL, tool={kind="round", width=1.8}, length={4, 10}})

--@ chunk 20
print(wait(10*24*60), drying(240,150), drying(215,250))
local JD = pile{{"bone black",2.5},{"ultramarine blue",0.3}}
local HL = pile{{"bone black",1.3},{"ultramarine blue",0.35},{"lead white",0.32}}
local G2 = pile{{"bone black",1.6},{"viridian",0.35},{"ultramarine blue",0.2},{"lead white",0.2}}
local b = brush{kind="rigger", width=1.1, point=1}
local function seg(p, a, c, pr) b:load(p, 0.9) b:stroke({a, c}, {pressure={pr, pr}, ramps={0.03, 0.03}}) end
-- casing: outer border, top edge catching faint light, a lower panel seam
seg(JD, {222, 102}, {518, 102}, 0.6) seg(JD, {518, 102}, {518, 370}, 0.6) seg(JD, {222, 370}, {518, 370}, 0.6) seg(JD, {222, 102}, {222, 370}, 0.6)
seg(HL, {224, 104.5}, {516, 104.5}, 0.4)
seg(JD, {226, 346}, {514, 346}, 0.5)
-- the raised rim around the CRT: outer edge dark, green falloff on its face (one step lighter)
seg(JD, {248, 126}, {492, 126}, 0.6) seg(JD, {492, 126}, {492, 332}, 0.6) seg(JD, {248, 332}, {492, 332}, 0.6) seg(JD, {248, 126}, {248, 332}, 0.6)
seg(G2, {251, 330}, {489, 330}, 0.5)
seg(G2, {489, 129}, {489, 329}, 0.4)
-- bolts
local BO = pile{{"bone black",1.1},{"ultramarine blue",0.3},{"lead white",0.45}}
local bt = brush{kind="round", width=2.6, point=0.3}
for _, p in ipairs({{234, 114}, {506, 114}, {234, 358}, {506, 358}, {234, 236}, {506, 236}, {370, 114}}) do
  bt:load(JD, 0.9) bt:touch(p[1] + 1, p[2] + 1, {pressure=0.65})
  bt:load(BO, 0.9) bt:touch(p[1], p[2], {pressure=0.5})
end

--@ chunk 21
print(wait(8*24*60)) local m = rect(519, 90, 22, 300) * FWALL work(m, {hand="detail", pile=GG[1], coverage=4.5, fill=true, clip=m, tool={kind="round", width=1.6}, length={3, 8}})
