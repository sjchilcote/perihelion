-- easel session "ratio_window_years": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=4/3, linen={20,18}, seed=90,
  ground={{pile={{"lead white",1},{"burnt sienna",0.4},{"yellow ochre",0.3},{"bone black",0.3}}, um=120, apply="knife", texture=0.3}}}
VX, VY, VR = 470, 285, 205
SEATY, SEATF = 545, 625
local function mix(a, b, t)
  local acc, order = {}, {}
  for _,v in ipairs(a) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*(1-t) end
  for _,v in ipairs(b) do if not acc[v[1]] then order[#order+1] = v[1] end; acc[v[1]] = (acc[v[1]] or 0) + v[2]*t end
  local o = {}
  for _,k in ipairs(order) do if acc[k] > 0.001 then o[#o+1] = {k, acc[k]} end end
  return pile(o)
end
MIX = mix
-- the nook's wall: warm prefab panels, brightest round the viewport, falling to warm dark at the edges
local WL = {{"lead white",1},{"yellow ochre",0.45},{"burnt sienna",0.2},{"bone black",0.12}}
local WD = {{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.6},{"lead white",0.15}}
local wall = rect(0, 0, 1000, SEATY) - ellipse(VX, VY, VR + 30, VR + 30)
local N = 9
for i=0,N-1 do
  local lo, hi = VR + 30 + i*70, VR + 30 + (i+1)*70
  if i == N-1 then hi = 5000 end
  local m = wall * mask(function(x,y) local r = math.sqrt((x-VX)^2 + ((y-VY)*1.15)^2); return (r >= lo and r < hi) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=8}, pile=mix(WL, WD, (i/(N-1))^0.9), coverage=3.8, fill=true, clip=wall, angle=1.5708, length={30,90}}) end
end
-- the seat: padded cushion top, upholstered front
local top = rect(0, SEATY, 1000, SEATF - SEATY)
local SL = {{"viridian",0.4},{"lead white",0.6},{"yellow ochre",0.3},{"bone black",0.2}}
local SD = {{"viridian",0.5},{"bone black",0.6},{"bone brown",0.4}}
for i=0,5 do
  local m = top * rect(-5 + i*170, 0, 172, H)
  work(m, {hand="body", tool={kind="filbert", width=7}, pile=mix(SL, SD, math.abs(i - 2.6)/3.2), coverage=3.8, fill=true, clip=top, angle=0, length={30,90}})
end
local front = rect(0, SEATF, 1000, H - SEATF)
work(front, {hand="body", tool={kind="filbert", width=10}, pile=pile{{"viridian",0.4},{"bone black",0.8},{"bone brown",0.5}}, coverage=3.8, fill=true, clip=front, angle=0, length={30,90}})

--@ chunk 2
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
GL = ellipse(VX, VY, VR, VR)
-- outside: space warming toward the Sun, upper right; the Testament's bronze curve below
SUX, SUY = 610, 140
local function hy(x) return VY + 40 + 0.0018*(x-VX)^2 + 0.15*(x-VX) end
local sky = GL * mask(function(x,y) return (y < hy(x)) and 1 or 0 end)
HULLV = GL - sky
local SK = {
  {0, 14, pile{{"zinc white",3},{"lemon chrome",0.2}}},
  {14, 32, pile{{"lead white",1.6},{"cadmium yellow",0.5},{"Mars orange",0.15}}},
  {32, 70, pile{{"Mars orange",0.6},{"ultramarine blue",0.5},{"lead white",0.5},{"bone black",0.3}}},
  {70, 140, pile{{"ultramarine blue",1},{"bone black",0.9},{"burnt sienna",0.2},{"lead white",0.1}}},
  {210, 999, pile{{"bone black",1.4},{"ultramarine blue",0.8}}},
}
for _,s in ipairs(SK) do
  local m = sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (r >= s[1] and r < s[2]) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=5}, pile=s[3], coverage=4, fill=true, clip=sky, angle=function(x,y) return math.atan(y-SUY, x-SUX) + 1.5708 end, length={15,45}}) end
end
for _,c in ipairs({14, 32, 70, 140}) do
  blend(sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (math.abs(r-c) < 10 + c*0.06) and 1 or 0 end), {angle=function(x,y) return math.atan(y-SUY, x-SUX) + 1.5708 end, tool={kind="badger", width=8}})
end
local HB = {
  {0, 18, pile{{"yellow ochre",1},{"lead white",0.8},{"cadmium yellow",0.3}}},
  {18, 60, pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.25}}},
  {60, 130, pile{{"burnt sienna",1},{"yellow ochre",0.4},{"bone brown",0.4}}},
  {130, 999, pile{{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.5}}},
}
for _,h in ipairs(HB) do
  local m = HULLV * mask(function(x,y) local d = y - hy(x); return (d >= h[1] and d < h[2]) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=5}, pile=h[3], coverage=4, fill=true, clip=HULLV, angle=0.2, length={20,60}}) end
end
blend(HULLV * mask(function(x,y) local d = y - hy(x); return (math.abs(d-18) < 6 or math.abs(d-60) < 10 or math.abs(d-130) < 14) and 1 or 0 end), {angle=0.2, tool={kind="badger", width=8}})
-- the frame: a thick padded ring, warm grey, lit from the window side
FRAME = ellipse(VX, VY, VR + 30, VR + 30) - GL
fill(FRAME, pile{{"lead white",0.9},{"bone black",0.6},{"burnt sienna",0.3},{"yellow ochre",0.2}}, 4, 0)

--@ chunk 3
local wall = rect(0, 0, 1000, SEATY) - ellipse(VX, VY, VR + 32, VR + 32)
local function r(x,y) return math.sqrt((x-VX)^2 + ((y-VY)*1.15)^2) end
local tg = function(x,y) return math.atan(y-VY, x-VX) + 1.5708 end
blend(wall * mask(function(x,y) local v = r(x,y) - (VR + 30); local k = v % 70; return (v > 30 and (k < 14 or k > 56)) and 1 or 0 end), {angle=tg, tool={kind="badger", width=10}})
local top = rect(0, SEATY, 1000, SEATF - SEATY)
blend(top * mask(function(x,y) local k = (x + 5) % 170; return (k < 22 or k > 148) and 1 or 0 end), {angle=0, tool={kind="badger", width=10}})
print(wait(3*24*60))
-- seat seams: buttoned cushions, a piped front edge
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local SEAM = pile{{"viridian",0.4},{"bone black",1},{"bone brown",0.3}}
local sb = brush{kind="round", width=2, point=0.4}
for _,x in ipairs({200, 400, 600, 800}) do sb:reload(SEAM, 0.8); sb:stroke({{x, SEATY + 2}, {x + 6, SEATF - 2}}, {pressure={0.55,0.45}}) end
for _,x in ipairs({100, 300, 500, 700, 900}) do local bb = brush{kind="round", width=4, point=0.3}; bb:reload(SEAM, 0.9); bb:touch(x, 585, {pressure=0.6}) end
local pip = brush{kind="round", width=3, point=0.3}
pip:reload(pile{{"viridian",0.3},{"lead white",0.8},{"yellow ochre",0.3},{"bone black",0.15}}, 0.8); pip:stroke({{0, SEATF - 1}, {1000, SEATF - 1}}, {pressure={0.6,0.6}})
pip:reload(pile{{"lead white",1},{"yellow ochre",0.4},{"burnt sienna",0.2}}, 0.8); pip:stroke({{0, SEATY + 1}, {1000, SEATY + 1}}, {pressure={0.5,0.5}})
-- the frame: lit inner bevel on the lower left (facing the room's lamp), shadow at top, bolts
local inner = ellipse(VX, VY, VR + 10, VR + 10) - GL
fill(inner * mask(function(x,y) return ((x-VX) - (y-VY) < 0) and 1 or 0 end), pile{{"lead white",1.3},{"yellow ochre",0.4},{"bone black",0.12}}, 2)
fill(inner * mask(function(x,y) return ((x-VX) - (y-VY) >= 0) and 1 or 0 end), pile{{"bone black",1},{"bone brown",0.6},{"lead white",0.2}}, 2)
local bt = brush{kind="round", width=5, point=0.3}
for k=0,15 do local a = 2*math.pi*k/16; bt:reload(pile{{"bone black",0.9},{"lead white",0.4},{"burnt sienna",0.2}}, 0.8); bt:touch(VX + (VR + 21)*math.cos(a), VY + (VR + 21)*math.sin(a), {pressure=0.5}) end

--@ chunk 4
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- prefab panel seams on the wall
local wall = rect(0, 0, 1000, SEATY) - ellipse(VX, VY, VR + 32, VR + 32)
local sm = brush{kind="round", width=1.6, point=0.4}
for _,x in ipairs({120, 820}) do sm:reload(pile{{"bone brown",1},{"bone black",0.5},{"burnt sienna",0.3}}, 0.7); sm:stroke({{x, 0}, {x, SEATY}}, {pressure={0.5,0.5}, clip=wall}) end
sm:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.7); sm:stroke({{0, 40}, {1000, 40}}, {pressure={0.45,0.45}, clip=wall})
-- the blanket: a folded knit throw, rust and ochre, hanging over the seat's front
BLK = poly({{40,528},{330,520},{348,560},{330,620},{340,705},{250,712},{170,700},{60,706},{52,620},{30,575}}, true)
fill(BLK, pile{{"cobalt blue",0.6},{"lead white",0.8},{"viridian",0.2},{"yellow ochre",0.15}}, 5, 1.5708)
-- the paperback, open and face down on the cushion like a small tent
BOOK = poly({{520,580},{578,552},{640,578},{580,590}}, true)
fill(BOOK, pile{{"cadmium yellow",1},{"Mars orange",0.3},{"lead white",0.3}}, 2)
fill(poly({{520,580},{580,590},{580,595},{522,585}}), pile{{"lead white",1.4},{"yellow ochre",0.25}}, 1.2)
fill(poly({{580,590},{640,578},{638,583},{580,595}}), pile{{"lead white",1.1},{"yellow ochre",0.25},{"bone black",0.1}}, 1.2)
-- the mug, on the cushion by the window
MUG = poly({{700,505},{746,505},{748,570},{702,570}}, true)
fill(MUG, pile{{"cadmium red",1},{"Mars red",0.4},{"lead white",0.2}}, 2, 1.5708)
fill(ellipse(723, 505, 23, 6), pile{{"bone brown",1},{"burnt sienna",0.4},{"bone black",0.4}}, 1.2)
local hb = brush{kind="round", width=4.5, point=0.2}
hb:reload(pile{{"cadmium red",1},{"Mars red",0.6}}, 0.9); hb:stroke({{748,520},{764,526},{764,548},{748,554}}, {pressure={0.7,0.7}})

--@ chunk 5
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- crayon: the station as a child sees it (a big ring with a pole through it), a yellow sun with rays, a tiny figure
local cr = brush{kind="round", width=2.8, point=0.3}
local function cstroke(p, pts, pr) cr:reload(p, 0.85); cr:stroke(pts, {pressure={pr or 0.55, pr or 0.5}, shake=1.2}) end
local ORA = pile{{"Mars orange",1},{"cadmium yellow",0.4}}
local pts = {}
for k=0,28 do local a = 2*math.pi*k/28; pts[#pts+1] = {822 + 52*math.cos(a), 228 + 20*math.sin(a)} end
cstroke(ORA, pts)
cstroke(pile{{"burnt sienna",1},{"Mars orange",0.3}}, {{818,150},{822,228},{826,292}}, 0.6)
cstroke(pile{{"cadmium yellow",1},{"lemon chrome",0.5}}, {{768,148},{780,140},{790,150},{780,160},{768,148}})
for _,a in ipairs({0, 0.8, 1.6, 2.4, 3.2, 4.0, 4.8, 5.6}) do cstroke(pile{{"cadmium yellow",1}}, {{780 + 14*math.cos(a), 150 + 14*math.sin(a)}, {780 + 22*math.cos(a), 150 + 22*math.sin(a)}}, 0.4) end
cstroke(pile{{"cobalt blue",1},{"lead white",0.2}}, {{760,280},{800,276},{850,282},{900,276}}, 0.45)
cstroke(pile{{"bone black",1.2}}, {{880,190},{880,206}}, 0.4); cstroke(pile{{"bone black",1.2}}, {{874,196},{886,196}}, 0.35)
cstroke(pile{{"cadmium red",1}}, {{878,176},{880,186}}, 0.4)
-- tape at the corners
local TP = pile{{"lead white",1.4},{"yellow ochre",0.3},{"bone black",0.08}}
for _,c in ipairs({{742,118,-0.6},{903,108,0.6},{752,298,0.6},{912,288,-0.6}}) do
  local ca, sa = math.cos(c[3]), math.sin(c[3])
  local t = poly({{c[1] - 14*ca + 4*sa, c[2] - 14*sa - 4*ca}, {c[1] + 14*ca + 4*sa, c[2] + 14*sa - 4*ca}, {c[1] + 14*ca - 4*sa, c[2] + 14*sa + 4*ca}, {c[1] - 14*ca - 4*sa, c[2] - 14*sa + 4*ca}})
  fill(t, TP, 1)
end
-- the blanket: knit ribs and a plaid of darker bands, lit fold on top
local kb = brush{kind="round", width=1.4, point=0.5}
for x=48,335,9 do kb:reload(pile{{"cobalt blue",1},{"ultramarine blue",0.4}}, 0.6); kb:stroke({{x, 560}, {x + 2, 704}}, {pressure={0.35,0.3}, clip=BLK}) end
for _,y in ipairs({600, 640, 680}) do kb:reload(pile{{"lead white",1.5},{"yellow ochre",0.2}}, 0.7); kb:stroke({{40, y}, {345, y}}, {pressure={0.9,0.9}, clip=BLK}) end
for _,y in ipairs({612, 652, 692}) do kb:reload(pile{{"cadmium yellow",1},{"lead white",0.5}}, 0.7); kb:stroke({{40, y}, {345, y}}, {pressure={0.6,0.6}, clip=BLK}) end
local lf = brush{kind="round", width=5, point=0.3}
lf:reload(pile{{"lead white",1.4},{"cerulean blue",0.3}}, 0.8); lf:stroke({{50,540},{180,528},{320,526}}, {pressure={0.6,0.3}})
lf:reload(pile{{"ultramarine blue",1},{"bone black",0.4}}, 0.8); lf:stroke({{50,572},{200,568},{340,562}}, {pressure={0.55,0.4}})
-- the book's cover: title marks; the mug's glaze highlight and steam; headphone glint
local tb = brush{kind="round", width=1, point=0.5}
tb:reload(pile{{"lead white",1.6}}, 0.7); tb:stroke({{556,572},{586,560}}, {pressure={0.4,0.4}})
tb:reload(pile{{"cadmium yellow",1}}, 0.7); tb:stroke({{562,578},{596,566}}, {pressure={0.35,0.35}})
local mh = brush{kind="round", width=2.4, point=0.5}
mh:reload(pile{{"lead white",1.6},{"cadmium red",0.15}}, 0.8); mh:stroke({{706,512},{708,562}}, {pressure={0.5,0.3}})
local st = brush{kind="rigger", width=1.2, point=1}
st:reload(pile{{"lead white",2},{"zinc white",0.5}}, 0.35)
st:stroke({{718,498},{712,480},{722,462},{716,442}}, {pressure={0.18,0.0}})
st:reload(pile{{"lead white",2},{"zinc white",0.5}}, 0.3)
st:stroke({{730,498},{736,478},{728,460}}, {pressure={0.15,0.0}})
-- scale plates on the bronze outside, catching the Sun on their upper edges
local function hy(x) return VY + 40 + 0.0018*(x-VX)^2 + 0.15*(x-VX) end
local bD = brush{kind="round", width=1.5, point=0.5}
local bL = brush{kind="round", width=1.0, point=0.7}
local d, row = 4, 0
while d < 200 do
  local h = 2.2 + d*0.06
  local w = h*3
  local x = VX - VR - 10 + ((row*0.37)%1)*w
  while x < VX + VR + 10 do
    local y = hy(x) + d
    if HULLV:at(x, y) > 0.5 then
      local pts, lit = {}, {}
      for k=0,6 do local a = -1 + k/3; pts[#pts+1] = {x + a*w*0.5, y + h*(1 - a*a)}; lit[#lit+1] = {x + a*w*0.5, y + h*(1 - a*a) - 1.1} end
      bD:reload(pile{{"bone brown",1},{"bone black",0.5}}, 0.7); bD:stroke(pts, {pressure={0.3 + h*0.02, 0.2}})
      bL:reload(pile{{"lead white",1.2},{"cadmium yellow",0.6}}, 0.6); bL:stroke({lit[4], lit[5], lit[6], lit[7]}, {pressure={0.3*(1 - d/220), 0.04}})
    end
    x = x + w*rand(0.95, 1.08)
  end
  d = d + h*1.1; row = row + 1
end
local rim = brush{kind="round", width=2.4, point=0.5}
local rp = {}
for x=VX-VR+8, VX+VR-8, 8 do local y = hy(x); if GL:at(x, y) > 0.5 then rp[#rp+1] = {x, y} end end
rim:reload(pile{{"lead white",1.2},{"yellow ochre",0.6}}, 0.75); rim:stroke(rp, {pressure={0.2,0.45}})

--@ chunk 6
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- fairy lights: a thin wire swagged round the frame, small warm bulbs with a glow
local wire = {}
local bulbs = {}
local n = 46
for k=0,n do
  local a = math.pi*0.92 + (2.16*math.pi)*k/n
  local sag = 14*math.abs(math.sin(k*math.pi/4))
  local rr = VR + 44 + sag
  local x, y = VX + rr*math.cos(a), VY + rr*math.sin(a)
  wire[#wire+1] = {x, y}
  if k % 2 == 0 then bulbs[#bulbs+1] = {x, y + 4} end
end
-- the loose end droops down to the seat
for k=1,6 do local p = wire[#wire]; wire[#wire+1] = {p[1] - 8 - k*2, p[2] + 22} ; if k % 2 == 0 then bulbs[#bulbs+1] = {wire[#wire][1], wire[#wire][2] + 4} end end
local wb = brush{kind="round", width=1.2, point=0.5}
wb:reload(pile{{"bone black",1.4},{"viridian",0.2}}, 0.8); wb:stroke(wire, {pressure={0.45,0.45}})
local G1 = pile{{"cadmium yellow",1},{"Mars orange",0.4},{"lead white",0.6}}
local G2 = pile{{"lead white",2.5},{"cadmium yellow",0.5}}
local HALO = pile{{"cadmium yellow",1},{"lead white",1},{"Mars orange",0.2}}
for i,b in ipairs(bulbs) do
  local hm = ellipse(b[1], b[2], 9, 9) - ellipse(b[1], b[2], 4, 4)
  work(hm, {hand="scumble", tool={kind="filbert", width=2}, pile=HALO, coverage=0.6, load=0.18, pressure={0.08,0.18}, clip=hm})
  fill(ellipse(b[1], b[2], 3.6, 4.4), (i % 5 == 0) and pile{{"cadmium red",1},{"Mars orange",0.6},{"lead white",0.4}} or G1, 1)
end
print(wait(12*60))
local cb = brush{kind="round", width=1.6, point=0.4}
for _,b in ipairs(bulbs) do cb:reload(G2, 0.9); cb:touch(b[1] - 0.6, b[2] - 0.8, {pressure=0.45}) end
-- crayon lines thicker, a second pass
local cr = brush{kind="round", width=4, point=0.3}
local pts = {}
for k=0,28 do local a = 2*math.pi*k/28; pts[#pts+1] = {822 + 52*math.cos(a), 228 + 20*math.sin(a)} end
cr:reload(pile{{"Mars orange",1},{"cadmium red",0.3}}, 0.85); cr:stroke(pts, {pressure={0.6,0.55}, shake=1.5})
cr:reload(pile{{"burnt sienna",1},{"Mars red",0.3}}, 0.85); cr:stroke({{818,150},{822,228},{826,292}}, {pressure={0.65,0.6}, shake=1.5})
cr:reload(pile{{"cadmium yellow",1},{"lemon chrome",0.4}}, 0.85); cr:stroke({{768,148},{780,138},{792,150},{780,162},{768,148}}, {pressure={0.65,0.6}, shake=1.2})
local cg = brush{kind="round", width=3, point=0.3}
for k=0,9 do cg:reload(pile{{"emerald green",1},{"viridian",0.4}}, 0.8); local x = 760 + k*15; cg:stroke({{x, 284}, {x + 3, 274}}, {pressure={0.55,0.5}}) end
-- the blanket's corner falls over the seat edge in a soft fold, with a shadow under it
local fold = poly({{300,600},{345,560},{362,610},{352,700},{320,716},{300,690}}, true)
fill(fold, pile{{"cobalt blue",0.6},{"lead white",0.6},{"ultramarine blue",0.3},{"bone black",0.1}}, 3, 1.5708)

--@ chunk 7
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
local function hy(x) return VY + 40 + 0.0018*(x-VX)^2 + 0.15*(x-VX) end
local sky = GL * mask(function(x,y) return (y < hy(x)) and 1 or 0 end)
local gap = sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (r >= 120) and 1 or 0 end)
fill(gap, pile{{"ultramarine blue",1},{"bone black",1.1},{"lead white",0.06}}, 4)
blend(sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (math.abs(r-130) < 18) and 1 or 0 end), {angle=function(x,y) return math.atan(y-SUY, x-SUX) + 1.5708 end, tool={kind="badger", width=8}})
local sb = brush{kind="round", width=1, point=0.8}
for i=1,30 do local x, y = rand(VX-VR, VX+VR), rand(VY-VR, VY+20); if (gap:shrink(2)):at(x,y) > 0.5 then sb:reload(pile{{"zinc white",3}}, 0.5); sb:touch(x, y, {pressure=rand(0.08,0.22)}) end end
-- the children's drawings: the station one again on its paper, and new ones all round the viewport
local PAP = pile{{"lead white",2},{"yellow ochre",0.08}}
local function sheet(pts) fill(poly(pts), PAP, 2) end
sheet({{740,120},{905,108},{915,290},{750,302}})
sheet({{60,70},{190,62},{196,180},{66,188}})
sheet({{36,250},{160,256},{156,372},{30,366}})
sheet({{770,330},{920,322},{926,450},{776,456}})
sheet({{620,24},{730,20},{734,96},{624,100}})
local TP = pile{{"lead white",1.4},{"yellow ochre",0.3},{"bone black",0.08}}
for _,c in ipairs({{60,70},{190,62},{36,250},{160,256},{770,330},{920,322},{620,24},{730,20},{742,118},{903,108}}) do local tb = brush{kind="round", width=6, point=0.2}; tb:reload(TP, 0.8); tb:stroke({{c[1]-7,c[2]-3},{c[1]+7,c[2]+3}}, {pressure={0.6,0.6}}) end

--@ chunk 8
print(wait(24*60))
local cr = brush{kind="round", width=2.6, point=0.3}
local function c(p, pts, pr) cr:reload(p, 0.85); cr:stroke(pts, {pressure={pr or 0.55, pr or 0.5}, shake=1.2}) end
local RED = pile{{"cadmium red",1},{"vermilion",0.3}}
local GRY = pile{{"bone black",0.6},{"lead white",0.6},{"ultramarine ash",0.4}}
local YEL = pile{{"cadmium yellow",1},{"lemon chrome",0.4}}
local GRN = pile{{"emerald green",1},{"viridian",0.3}}
local BLU = pile{{"cobalt blue",1},{"lead white",0.2}}
local ORA = pile{{"Mars orange",1},{"cadmium yellow",0.4}}
local BLK = pile{{"bone black",1.2}}
-- the station again (kept), and redrawn bold
local pts = {}
for k=0,28 do local a = 2*math.pi*k/28; pts[#pts+1] = {822 + 52*math.cos(a), 228 + 20*math.sin(a)} end
c(ORA, pts); c(pile{{"burnt sienna",1}}, {{818,150},{822,228},{826,292}}, 0.6)
-- the knight: a grey robot figure with a crimson tabard and a white cross, holding a little sword
c(GRY, {{120,90},{132,86},{140,96},{130,106},{120,90}})
c(GRY, {{124,106},{118,150},{142,150},{136,106}})
c(RED, {{122,112},{124,148},{136,148},{134,112},{122,112}}, 0.7)
c(pile{{"lead white",2}}, {{129,118},{129,140}}, 0.45); c(pile{{"lead white",2}}, {{124,126},{134,126}}, 0.45)
c(GRY, {{120,150},{116,172}}); c(GRY, {{140,150},{144,172}})
c(GRY, {{118,112},{100,128}}); c(GRY, {{142,112},{160,100}}); c(pile{{"lead white",1},{"ultramarine ash",0.4}}, {{160,100},{176,80}}, 0.45)
-- Ratio: a little lantern with a warm window and a smiling face
c(GRY, {{70,300},{110,300},{110,350},{70,350},{70,300}})
c(GRY, {{78,300},{90,286},{102,300}})
c(YEL, {{78,310},{102,310},{102,338},{78,338},{78,310}}, 0.7)
c(BLK, {{84,320},{85,322}}, 0.4); c(BLK, {{95,320},{96,322}}, 0.4); c(BLK, {{84,329},{90,333},{96,329}}, 0.35)
for _,a in ipairs({0.2, 1.0, 2.2, 3.0}) do c(YEL, {{90 + 30*math.cos(a), 324 - 30*math.sin(a)}, {90 + 40*math.cos(a), 324 - 40*math.sin(a)}}, 0.35) end
-- a bug: a round green beetle with six legs and feelers
c(GRN, {{830,392},{846,376},{866,380},{874,398},{862,414},{840,414},{830,392}})
c(BLK, {{852,377},{852,413}}, 0.4)
for _,y in ipairs({384, 396, 408}) do c(BLK, {{834,y},{816,y-6}}, 0.4); c(BLK, {{870,y},{888,y-6}}, 0.4) end
c(BLK, {{846,378},{838,360}}, 0.35); c(BLK, {{858,378},{866,360}}, 0.35)
-- the Sun, small, and a long ship over the top sheet
c(YEL, {{650,58},{660,48},{670,58},{660,68},{650,58}}); c(BLU, {{684,64},{720,58}}, 0.6); c(BLU, {{680,72},{724,66},{716,60}}, 0.5)

--@ chunk 9
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- a second mug, smaller, a child's, beside the first
local M2 = poly({{776,526},{806,526},{806,572},{778,572}}, true)
fill(M2, pile{{"cobalt blue",1},{"lead white",0.6}}, 2, 1.5708)
fill(ellipse(791, 526, 15, 4), pile{{"lead white",1.4},{"bone brown",0.3}}, 1)
local hb = brush{kind="round", width=3, point=0.2}
hb:reload(pile{{"cobalt blue",1},{"lead white",0.6}}, 0.9); hb:stroke({{806,536},{818,542},{816,558},{806,560}}, {pressure={0.65,0.65}})
local dots = brush{kind="round", width=3.5, point=0.2}
for _,p in ipairs({{784,540},{798,548},{786,558}}) do dots:reload(pile{{"cadmium yellow",1},{"lead white",0.4}}, 0.9); dots:touch(p[1], p[2], {pressure=0.5}) end
-- the small bone tablet propped on the sill under the viewport: a fold glyph cut in it
local tab = poly({{430,488},{478,484},{482,540},{434,544}}, true)
fill(tab, pile{{"lead white",1.3},{"yellow ochre",0.4},{"raw sienna",0.1}}, 2)
fill(poly({{478,484},{486,488},{490,540},{482,540}}), pile{{"yellow ochre",1},{"raw sienna",0.4},{"bone brown",0.3}}, 1.2)
local g = brush{kind="round", width=1.4, point=0.5}
local cx, cy = 456, 514
local INK = pile{{"bone brown",1},{"raw sienna",0.5}}
for k=0,5 do
  local a = k*math.pi/3
  local px, py = cx + 9*math.cos(a), cy + 9*math.sin(a)
  local pts = {}
  for j=0,10 do local t = 2*math.pi*j/10; pts[#pts+1] = {px + 5*math.cos(t), py + 5*math.sin(t)} end
  g:reload(INK, 0.7); g:stroke(pts, {pressure={0.35,0.35}})
end
local hp = {}
for j=0,10 do local t = 2*math.pi*j/10; hp[#hp+1] = {cx + 4*math.cos(t), cy + 4*math.sin(t)} end
g:reload(INK, 0.8); g:stroke(hp, {pressure={0.45,0.45}})
-- the fairy lights glow a little warmer: a tiny halo on each bulb
