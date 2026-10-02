-- easel session "matisse": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=0.75, linen={22,20}, seed=1947,
  ground={{pile={{"lead white",3},{"yellow ochre",0.08}}, um=80, apply="knife", texture=0.05}}}
-- H = 1333. The blue sheet, cut a little irregular, on white paper
BLUE = poly({{70, 74}, {932, 66}, {938, 1262}, {64, 1270}})
work(BLUE, {hand="body", pile=pile{{"ultramarine blue",1},{"cobalt blue",0.6},{"bone black",0.08}}, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
print(wait(5*1440))

--@ chunk 2
local yel = pile{{"cadmium yellow",1},{"lemon chrome",0.4}}
local blk = pile{{"bone black",2},{"ultramarine blue",0.1}}
local function W(m, p, t) work(m, {hand="detail", tool=t or "round 3", pile=p, coverage=5, fill=true, load=1}) end
local function burst(cx, cy, r, n, seed)
  local pts = {}
  for k = 0, 2 * n - 1 do
    local a = k * math.pi / n + rand(-0.12, 0.12)
    local rr = (k % 2 == 0) and r * rand(0.85, 1.15) or r * rand(0.35, 0.5)
    pts[#pts+1] = {cx + rr * math.cos(a), cy + rr * math.sin(a)}
  end
  return poly(pts)
end
-- the Sun at the bottom edge: a huge jagged burst, cut off by the sheet's edge
SUN = burst(500, 1280, 330, 13) * BLUE
W(SUN, yel)
-- star-bursts scattered around the figure
STARS = nil
for _, s in ipairs({{180, 210, 58, 6}, {800, 170, 50, 5}, {150, 560, 64, 7}, {840, 520, 70, 6}, {230, 860, 46, 5}, {790, 860, 56, 6}, {660, 330, 34, 5}, {330, 410, 30, 5}, {880, 1040, 40, 5}, {120, 1090, 44, 6}}) do
  local m = burst(s[1], s[2], s[3], s[4])
  STARS = STARS and (STARS + m) or m
end
W(STARS * BLUE, yel)
-- the Commando, a black cut-out, diving head-first toward the Sun, arms flung out like flames
local body = poly({{455, 800}, {430, 720}, {420, 640}, {436, 560}, {470, 520}, {520, 518}, {552, 560}, {560, 640}, {540, 720}, {512, 800}}, true)
local head = ellipse(484, 850, 42, 48)
local legL = poly({{440, 560}, {470, 530}, {440, 420}, {400, 300}, {380, 230}, {350, 236}, {372, 320}, {400, 440}}, true)
local legR = poly({{520, 530}, {552, 560}, {580, 450}, {620, 340}, {660, 260}, {632, 248}, {590, 330}, {546, 430}}, true)
local armL = poly({{438, 720}, {400, 700}, {350, 720}, {300, 690}, {262, 700}, {236, 664}, {270, 672}, {300, 650}, {350, 676}, {420, 666}}, true)
local armR = poly({{540, 712}, {590, 700}, {640, 730}, {690, 700}, {730, 716}, {760, 680}, {726, 684}, {690, 664}, {640, 690}, {560, 670}}, true)
FIGM = body + head + legL + legR + armL + armR
W(FIGM, blk)
print(wait(5*1440))

--@ chunk 3
local red = pile{{"cadmium red",1},{"vermilion",0.5}}
-- the tabard's cross as the heart, cut a little crooked
local c = poly({{480, 610}, {500, 608}, {502, 642}, {530, 640}, {532, 660}, {502, 662}, {504, 700}, {484, 702}, {482, 664}, {454, 666}, {452, 646}, {481, 644}})
work(c, {hand="detail", tool="round 2", pile=red, coverage=5, fill=true, load=1})
