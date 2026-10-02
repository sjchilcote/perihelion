-- easel session "window_seat_after": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=4/3, linen={20,18}, seed=89,
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
local WL = {{"lead white",1},{"ultramarine ash",0.45},{"bone black",0.3},{"cerulean blue",0.05}}
local WD = {{"bone black",1.3},{"ultramarine ash",0.6},{"ultramarine blue",0.2},{"lead white",0.1}}
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
local SL = {{"viridian",0.25},{"lead white",0.6},{"ultramarine ash",0.4},{"bone black",0.3}}
local SD = {{"viridian",0.25},{"bone black",0.9},{"ultramarine ash",0.4}}
for i=0,5 do
  local m = top * rect(-5 + i*170, 0, 172, H)
  work(m, {hand="body", tool={kind="filbert", width=7}, pile=mix(SL, SD, math.abs(i - 2.6)/3.2), coverage=3.8, fill=true, clip=top, angle=0, length={30,90}})
end
local front = rect(0, SEATF, 1000, H - SEATF)
work(front, {hand="body", tool={kind="filbert", width=10}, pile=pile{{"viridian",0.2},{"bone black",1.1},{"ultramarine ash",0.4}}, coverage=3.8, fill=true, clip=front, angle=0, length={30,90}})

--@ chunk 2
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
GL = ellipse(VX, VY, VR, VR)
-- outside: space warming toward the Sun, upper right; the Testament's bronze curve below
SUX, SUY = 610, 140
local function hy(x) return VY + 40 + 0.0018*(x-VX)^2 + 0.15*(x-VX) end
local sky = GL * mask(function(x,y) return (y < hy(x)) and 1 or 0 end)
HULLV = GL - sky
local SK = {
  {0, 30, pile{{"zinc white",3},{"lemon chrome",0.2}}},
  {30, 70, pile{{"lead white",2},{"cadmium yellow",0.6},{"Mars orange",0.2}}},
  {70, 130, pile{{"Mars orange",1},{"lead white",0.6},{"cadmium yellow",0.4},{"bone black",0.08}}},
  {130, 210, pile{{"burnt sienna",1},{"ultramarine blue",0.6},{"bone black",0.5},{"lead white",0.1}}},
  {210, 999, pile{{"bone black",1.4},{"ultramarine blue",0.8}}},
}
for _,s in ipairs(SK) do
  local m = sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (r >= s[1] and r < s[2]) and 1 or 0 end)
  if m:area() > 1 then work(m, {hand="body", tool={kind="filbert", width=5}, pile=s[3], coverage=4, fill=true, clip=sky, angle=function(x,y) return math.atan(y-SUY, x-SUX) + 1.5708 end, length={15,45}}) end
end
for _,c in ipairs({30, 70, 130, 210}) do
  blend(sky * mask(function(x,y) local r = math.sqrt((x-SUX)^2 + (y-SUY)^2); return (math.abs(r-c) < 10 + c*0.06) and 1 or 0 end), {angle=function(x,y) return math.atan(y-SUY, x-SUX) + 1.5708 end, tool={kind="badger", width=8}})
end
local HB = {
  {0, 18, pile{{"lead white",1.2},{"cadmium yellow",0.6},{"yellow ochre",0.4}}},
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
fill(FRAME, pile{{"lead white",0.7},{"bone black",0.8},{"ultramarine ash",0.5}}, 4, 0)

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
local SEAM = pile{{"viridian",0.2},{"bone black",1.2},{"ultramarine ash",0.3}}
local sb = brush{kind="round", width=2, point=0.4}
for _,x in ipairs({200, 400, 600, 800}) do sb:reload(SEAM, 0.8); sb:stroke({{x, SEATY + 2}, {x + 6, SEATF - 2}}, {pressure={0.55,0.45}}) end
for _,x in ipairs({100, 300, 500, 700, 900}) do local bb = brush{kind="round", width=4, point=0.3}; bb:reload(SEAM, 0.9); bb:touch(x, 585, {pressure=0.6}) end
local pip = brush{kind="round", width=3, point=0.3}
pip:reload(pile{{"viridian",0.2},{"lead white",0.7},{"ultramarine ash",0.4},{"bone black",0.25}}, 0.8); pip:stroke({{0, SEATF - 1}, {1000, SEATF - 1}}, {pressure={0.6,0.6}})
pip:reload(pile{{"lead white",1},{"ultramarine ash",0.4},{"bone black",0.2}}, 0.8); pip:stroke({{0, SEATY + 1}, {1000, SEATY + 1}}, {pressure={0.5,0.5}})
-- the frame: lit inner bevel on the lower left (facing the room's lamp), shadow at top, bolts
local inner = ellipse(VX, VY, VR + 10, VR + 10) - GL
fill(inner * mask(function(x,y) return ((x-VX) - (y-VY) < 0) and 1 or 0 end), pile{{"lead white",1.3},{"ultramarine ash",0.4},{"cerulean blue",0.1}}, 2)
fill(inner * mask(function(x,y) return ((x-VX) - (y-VY) >= 0) and 1 or 0 end), pile{{"bone black",1.2},{"ultramarine ash",0.5},{"lead white",0.15}}, 2)
local bt = brush{kind="round", width=5, point=0.3}
for k=0,15 do local a = 2*math.pi*k/16; bt:reload(pile{{"bone black",0.9},{"lead white",0.4},{"ultramarine ash",0.3}}, 0.8); bt:touch(VX + (VR + 21)*math.cos(a), VY + (VR + 21)*math.sin(a), {pressure=0.5}) end

--@ chunk 4
print(wait(24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- prefab panel seams on the wall
local wall = rect(0, 0, 1000, SEATY) - ellipse(VX, VY, VR + 32, VR + 32)
local sm = brush{kind="round", width=1.6, point=0.4}
for _,x in ipairs({120, 820}) do sm:reload(pile{{"bone black",1.2},{"ultramarine ash",0.5}}, 0.7); sm:stroke({{x, 0}, {x, SEATY}}, {pressure={0.5,0.5}, clip=wall}) end
sm:reload(pile{{"bone black",1.2},{"ultramarine ash",0.5}}, 0.7); sm:stroke({{0, 40}, {1000, 40}}, {pressure={0.45,0.45}, clip=wall})
-- the blanket: a folded knit throw, rust and ochre, hanging over the seat's front
BLK = poly({{40,528},{330,520},{348,560},{330,620},{340,705},{250,712},{170,700},{60,706},{52,620},{30,575}}, true)
fill(BLK, pile{{"burnt sienna",1},{"Mars orange",0.5},{"yellow ochre",0.3},{"bone black",0.1}}, 5, 1.5708)
-- the paperback, open and face down on the cushion like a small tent
BOOK = poly({{520,580},{578,552},{640,578},{580,590}}, true)
fill(BOOK, pile{{"cobalt blue",1},{"lead white",0.4},{"bone black",0.2}}, 2)
fill(poly({{520,580},{580,590},{580,595},{522,585}}), pile{{"lead white",1.4},{"yellow ochre",0.25}}, 1.2)
fill(poly({{580,590},{640,578},{638,583},{580,595}}), pile{{"lead white",1.1},{"yellow ochre",0.25},{"bone black",0.1}}, 1.2)
-- the mug, on the cushion by the window
MUG = poly({{700,505},{746,505},{748,570},{702,570}}, true)
fill(MUG, pile{{"cadmium red",1},{"Mars red",0.4},{"lead white",0.2}}, 2, 1.5708)
fill(ellipse(723, 505, 23, 6), pile{{"bone brown",1},{"bone black",0.8}}, 1.2)
local hb = brush{kind="round", width=4.5, point=0.2}
hb:reload(pile{{"cadmium red",1},{"Mars red",0.6}}, 0.9); hb:stroke({{748,520},{764,526},{764,548},{748,554}}, {pressure={0.7,0.7}})
-- headphones resting on the cushion
local HD = pile{{"bone black",1.4},{"ultramarine ash",0.5},{"lead white",0.12}}
local band = brush{kind="round", width=6, point=0.2}
band:reload(HD, 0.9); band:stroke({{828,594},{836,560},{870,544},{904,556},{914,590}}, {pressure={0.75,0.75}})
fill(ellipse(830, 596, 15, 10) + ellipse(914, 594, 15, 10), HD, 1.5)
fill(ellipse(830, 593, 9, 5) + ellipse(914, 591, 9, 5), pile{{"cadmium yellow",1},{"Mars orange",0.6},{"bone black",0.2}}, 1)
-- the child's drawing, taped up beside the window, a little crooked
DRW = poly({{740,120},{905,108},{915,290},{750,302}})
fill(DRW, pile{{"lead white",1.6},{"yellow ochre",0.2},{"ultramarine ash",0.2}}, 3)

--@ chunk 5
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- crayon: the station as a child sees it (a big ring with a pole through it), a yellow sun with rays, a tiny figure
local cr = brush{kind="round", width=2.8, point=0.3}
local function cstroke(p, pts, pr) cr:reload(p, 0.85); cr:stroke(pts, {pressure={pr or 0.55, pr or 0.5}, shake=1.2}) end
local ORA = pile{{"Mars orange",0.6},{"lead white",1},{"cadmium yellow",0.2}}
local pts = {}
for k=0,28 do local a = 2*math.pi*k/28; pts[#pts+1] = {822 + 52*math.cos(a), 228 + 20*math.sin(a)} end
cstroke(ORA, pts)
cstroke(pile{{"burnt sienna",0.6},{"lead white",1}}, {{818,150},{822,228},{826,292}}, 0.6)
cstroke(pile{{"cadmium yellow",0.6},{"lead white",1}}, {{768,148},{780,140},{790,150},{780,160},{768,148}})
for _,a in ipairs({0, 0.8, 1.6, 2.4, 3.2, 4.0, 4.8, 5.6}) do cstroke(pile{{"cadmium yellow",0.5},{"lead white",1}}, {{780 + 14*math.cos(a), 150 + 14*math.sin(a)}, {780 + 22*math.cos(a), 150 + 22*math.sin(a)}}, 0.4) end
cstroke(pile{{"cobalt blue",0.5},{"lead white",1}}, {{760,280},{800,276},{850,282},{900,276}}, 0.45)
cstroke(pile{{"bone black",0.6},{"lead white",0.8}}, {{880,190},{880,206}}, 0.4); cstroke(pile{{"bone black",0.6},{"lead white",0.8}}, {{874,196},{886,196}}, 0.35)
cstroke(pile{{"cadmium red",0.5},{"lead white",1}}, {{878,176},{880,186}}, 0.4)
-- tape at the corners
local TP = pile{{"lead white",1.4},{"yellow ochre",0.3},{"bone black",0.08}}
for _,c in ipairs({{742,118,-0.6},{903,108,0.6},{752,298,0.6}}) do
  local ca, sa = math.cos(c[3]), math.sin(c[3])
  local t = poly({{c[1] - 14*ca + 4*sa, c[2] - 14*sa - 4*ca}, {c[1] + 14*ca + 4*sa, c[2] + 14*sa - 4*ca}, {c[1] + 14*ca - 4*sa, c[2] + 14*sa + 4*ca}, {c[1] - 14*ca - 4*sa, c[2] - 14*sa + 4*ca}})
  fill(t, TP, 1)
end
-- the blanket: knit ribs and a plaid of darker bands, lit fold on top
local kb = brush{kind="round", width=1.4, point=0.5}
for x=48,335,9 do kb:reload(pile{{"burnt sienna",1},{"bone brown",0.6}}, 0.6); kb:stroke({{x, 560}, {x + 2, 704}}, {pressure={0.35,0.3}, clip=BLK}) end
for _,y in ipairs({600, 640, 680}) do kb:reload(pile{{"bone brown",1},{"Mars red",0.4}}, 0.7); kb:stroke({{40, y}, {345, y}}, {pressure={0.9,0.9}, clip=BLK}) end
for _,y in ipairs({612, 652, 692}) do kb:reload(pile{{"yellow ochre",1},{"lead white",0.4}}, 0.7); kb:stroke({{40, y}, {345, y}}, {pressure={0.6,0.6}, clip=BLK}) end
local lf = brush{kind="round", width=5, point=0.3}
lf:reload(pile{{"yellow ochre",1},{"lead white",0.6},{"Mars orange",0.2}}, 0.8); lf:stroke({{50,540},{180,528},{320,526}}, {pressure={0.6,0.3}})
lf:reload(pile{{"bone brown",1},{"bone black",0.4}}, 0.8); lf:stroke({{50,572},{200,568},{340,562}}, {pressure={0.55,0.4}})
-- the book's cover: title marks; the mug's glaze highlight and steam; headphone glint
local tb = brush{kind="round", width=1, point=0.5}
tb:reload(pile{{"lead white",1.6}}, 0.7); tb:stroke({{556,572},{586,560}}, {pressure={0.4,0.4}})
tb:reload(pile{{"cadmium yellow",1}}, 0.7); tb:stroke({{562,578},{596,566}}, {pressure={0.35,0.35}})
local mh = brush{kind="round", width=2.4, point=0.5}
mh:reload(pile{{"lead white",1.6},{"cadmium red",0.15}}, 0.8); mh:stroke({{706,512},{708,562}}, {pressure={0.5,0.3}})
local hg = brush{kind="round", width=1.6, point=0.5}
hg:reload(pile{{"lead white",1.5},{"cadmium yellow",0.3}}, 0.7); hg:stroke({{840,556},{870,546},{898,552}}, {pressure={0.4,0.2}})
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
rim:reload(pile{{"lead white",1.5},{"cadmium yellow",0.8}}, 0.85); rim:stroke(rp, {pressure={0.25,0.6}})

--@ chunk 6
print(wait(2*24*60))
local function fill(m, p, w, ang) if m:area() > 0.2 then work(m, {hand="detail", tool={kind="filbert", width=w or 2}, pile=p, coverage=4.5, fill=true, clip=m, angle=ang or 0}) end end
-- the blanket's fold over the seat edge, as before, with a soft shadow
local fold = poly({{300,600},{345,560},{362,610},{352,700},{320,716},{300,690}}, true)
fill(fold, pile{{"burnt sienna",1},{"bone brown",0.6},{"Mars orange",0.2}}, 3, 1.5708)
fill(poly({{352,640},{385,646},{390,716},{354,712}}, true), pile{{"viridian",0.2},{"bone black",1.2},{"ultramarine ash",0.4}}, 2)
-- the dead fairy lights: the wire sags lower, the left run has fallen away to the seat
local wire, bulbs = {}, {}
local n = 46
for k=0,30 do
  local a = math.pi*1.45 + (1.6*math.pi)*k/n
  local sag = 24*math.abs(math.sin(k*math.pi/4))
  local rr = VR + 44 + sag
  local x, y = VX + rr*math.cos(a), VY + rr*math.sin(a) + sag*0.4
  wire[#wire+1] = {x, y}
  if k % 2 == 0 then bulbs[#bulbs+1] = {x, y + 4} end
end
for k=1,7 do local p = wire[#wire]; wire[#wire+1] = {p[1] - 6 - k*1.5, p[2] + 20}; if k % 2 == 0 then bulbs[#bulbs+1] = {wire[#wire][1], wire[#wire][2] + 4} end end
local wb = brush{kind="round", width=1.2, point=0.5}
wb:reload(pile{{"bone black",1.4},{"ultramarine ash",0.3}}, 0.8); wb:stroke(wire, {pressure={0.45,0.45}})
-- the fallen end: from the top left of the frame down across the wall to the cushion
local fall = {{VX + (VR+44)*math.cos(math.pi*1.45), VY + (VR+44)*math.sin(math.pi*1.45)}, {300, 120}, {230, 220}, {200, 330}, {205, 440}, {228, 540}, {260, 552}}
wb:reload(pile{{"bone black",1.4},{"ultramarine ash",0.3}}, 0.8); wb:stroke(fall, {pressure={0.45,0.45}})
for k=2,#fall-1 do bulbs[#bulbs+1] = {fall[k][1] + 2, fall[k][2] + 4} end
local DB = pile{{"bone black",0.8},{"ultramarine ash",0.7},{"lead white",0.35}}
for _,b in ipairs(bulbs) do
  fill(ellipse(b[1], b[2], 3.4, 4.2), DB, 1)
end
print(wait(12*60))
local cb = brush{kind="round", width=1.2, point=0.4}
for _,b in ipairs(bulbs) do cb:reload(pile{{"lead white",1.5},{"cerulean blue",0.2}}, 0.7); cb:touch(b[1] - 1, b[2] - 1.4, {pressure=0.3}) end
-- frost feathering the inside of the glass, from the rim inward, thickest low
local function fr(x,y) local r = math.sqrt((x-VX)^2 + (y-VY)^2); return r end
local rimband = GL * mask(function(x,y) local r = fr(x,y); local depth = 22 + 40*math.max(0, (y-VY)/VR); return (r > VR - depth) and 1 or 0 end)
stipple(rimband, {pile=pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.25}}, width=1.3, coverage=1.6, pressure={0.15,0.45}, cluster={0.6, 7}})
local fb = brush{kind="round", width=0.8, point=0.8}
for i=1,90 do
  local a = rand(0, 2*math.pi)
  local r0 = VR - 2
  local x0, y0 = VX + r0*math.cos(a), VY + r0*math.sin(a)
  local L = rand(15, 45) * (1 + 0.8*math.max(0, math.sin(a)))
  local x1, y1 = VX + (r0 - L)*math.cos(a + rand(-0.12, 0.12)), VY + (r0 - L)*math.sin(a + rand(-0.12, 0.12))
  fb:reload(pile{{"zinc white",2},{"cerulean blue",0.2}}, 0.6); fb:stroke({{x0, y0}, {x1, y1}}, {pressure={0.35,0.02}, clip=GL})
  for j=1,3 do
    local t = rand(0.3, 0.9)
    local xm, ym = x0 + (x1-x0)*t, y0 + (y1-y0)*t
    local side = (j % 2 == 0) and 0.7 or -0.7
    local bl = L*0.25
    fb:reload(pile{{"zinc white",2},{"cerulean blue",0.2}}, 0.5)
    fb:stroke({{xm, ym}, {xm + bl*math.cos(a + math.pi + side), ym + bl*math.sin(a + math.pi + side)}}, {pressure={0.25,0.02}, clip=GL})
  end
end
-- the mug: a dried brown ring inside the rim, a stain ring on the cushion beside it
local sr = brush{kind="round", width=1.6, point=0.5}
local pts = {}
for k=0,24 do local t = 2*math.pi*k/24; pts[#pts+1] = {723 + 20*math.cos(t), 507 + 4.6*math.sin(t)} end
sr:reload(pile{{"bone brown",1},{"burnt sienna",0.4}}, 0.7); sr:stroke(pts, {pressure={0.4,0.4}})
local pts2 = {}
for k=0,24 do local t = 2*math.pi*k/24; pts2[#pts2+1] = {660 + 22*math.cos(t), 588 + 5*math.sin(t)} end
sr:reload(pile{{"bone brown",1},{"burnt sienna",0.5},{"bone black",0.2}}, 0.6); sr:stroke(pts2, {pressure={0.35,0.3}})
-- the paperback's pages frost-stiff: a white rime along its edges
stipple(poly({{518,578},{580,588},{642,576},{642,586},{580,598},{518,588}}), {pile=pile{{"zinc white",2},{"cerulean blue",0.2}}, width=1, coverage=1.2, pressure={0.15,0.4}})
-- frost along the cushion's front piping and on the blanket's top
local fp = rect(0, SEATF - 6, 1000, 10)
stipple(fp, {pile=pile{{"zinc white",2},{"lead white",1},{"cerulean blue",0.2}}, width=1.1, coverage=0.9, pressure={0.15,0.4}, cluster={0.6, 6}})
-- the headphone cord trailing off the seat to the floor
local cd = brush{kind="round", width=1.8, point=0.5}
cd:reload(pile{{"bone black",1.4},{"ultramarine ash",0.3}}, 0.85); cd:stroke({{914,600},{930,612},{940,630},{936,670},{948,705},{975,738},{998,742}}, {pressure={0.55,0.5}})
-- the drawing's loose corner, curling forward: shadow under it, paper back
local cn = poly({{866,262},{915,290},{906,296},{878,300},{870,286}}, true)
fill(poly({{870,276},{916,290},{918,305},{876,312}}, true), pile{{"bone black",1},{"ultramarine ash",0.5},{"lead white",0.25}}, 1.5)
fill(cn, pile{{"lead white",1.3},{"yellow ochre",0.25},{"ultramarine ash",0.3}}, 1.2)
local ce = brush{kind="round", width=1, point=0.5}
ce:reload(pile{{"bone black",0.9},{"ultramarine ash",0.4}}, 0.7); ce:stroke({{866,262},{874,282},{878,300},{906,296}}, {pressure={0.35,0.3}})
