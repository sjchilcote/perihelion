-- easel session "lattice": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=700, aspect=1.4, linen={16,13}, seed=5150,
  ground={
    {pile={{"lead white",4},{"bone black",0.2}}, um=80, apply="knife", texture=0.3},
    {pile={{"rose madder",1},{"bone brown",1.5},{"ultramarine blue",0.6},{"lead white",0.3}, medium=0.5}, um=24, apply="brush"},
  }}
print(W, H)

--@ chunk 2
LAT = rect(330, 150, 420, 420)
VP = {545, 355}
OUT = everywhere() - LAT
FLOW = noise{seed=31, period=260, octaves=3, warp={300, 120}}
function flowang(x, y) return FLOW(x, y) * 3.2 end
fDeep = pile{{"bone brown",2},{"rose madder",1},{"ultramarine blue",0.6}}
fWarm = pile{{"rose madder",1},{"burnt sienna",1},{"bone brown",1}}
fViol = pile{{"cobalt violet",1},{"bone brown",1.5},{"rose madder",0.5}}
gCold = pile{{"zinc white",2},{"cerulean blue",1},{"ultramarine ash",0.5},{"bone black",0.1}}
gGlare = pile{{"zinc white",3},{"cerulean blue",0.25},{"lemon chrome",0.08}}
work(OUT, {hand="broad", pile=fDeep, coverage=2.6, fill=true, angle=flowang, clip=OUT})
local warmz = OUT * mask(function(x, y) return smoothstep(0.1, 0.5, FLOW(x + 500, y)) end)
work(warmz, {hand="broad", pile=fWarm, coverage=1.6, fill=true, angle=flowang, clip=OUT})
local violz = OUT * mask(function(x, y) return smoothstep(0.15, 0.55, -FLOW(x - 300, y + 200)) end)
work(violz, {hand="broad", pile=fViol, coverage=1.4, fill=true, angle=flowang, clip=OUT})
work(LAT, {hand="broad", pile=gCold, coverage=2.6, fill=true, angle=0, ruler=true, clip=LAT})
local core = rect(470, 290, 150, 130)
work(core, {hand="body", pile=gGlare, coverage=2.6, fill=true, angle=0, ruler=true, clip=LAT})

--@ chunk 3
-- folds: long strokes that follow the flow, lit ridges and dark creases, then melted together
fLit = pile{{"rose madder",1},{"Mars orange",0.6},{"lead white",0.6},{"Indian yellow",0.2}}
fEmber = pile{{"Mars orange",1},{"rose madder",0.6},{"Indian yellow",0.4},{"lead white",0.3}}
fCrease = pile{{"bone black",1},{"rose madder",0.6},{"ultramarine blue",0.6}}
function streamline(x, y, n, step)
  local pts = {{x, y}}
  for i = 1, n do
    local a = flowang(x, y)
    x = x + math.cos(a) * step; y = y + math.sin(a) * step
    pts[#pts+1] = {x, y}
  end
  return pts
end
local b = brush("filbert", 16)
local c = brush("filbert", 9)
for i = 1, 90 do
  local x, y = rand(-20, 1020), rand(-20, 735)
  if LAT:grow(20):at(x, y) < 0.5 then
    local r = math.random()
    local p = (r < 0.4) and fLit or ((r < 0.6) and fEmber or fCrease)
    local br = (math.random() < 0.5) and b or c
    br:reload(p, 0.6)
    br:stroke(streamline(x, y, math.random(14, 30), 9), {pressure={0.3, 0.6}, swell={0.6, 1, 0.5}, ramps={0.3, 0.4}, orient="across", clip=OUT})
  end
end
blend(OUT, {angle=flowang})

--@ chunk 4
print(wait(3*24*60))
-- the lattice: nested frames receding to one point, every wall ruled into plates; hard, exact, cold
lDark = pile{{"ultramarine blue",1},{"bone black",1},{"zinc white",0.3}}
lMid  = pile{{"zinc white",1},{"ultramarine ash",1},{"cerulean blue",0.5},{"bone black",0.2}}
lHot  = pile{{"zinc white",4},{"cerulean blue",0.15}}
local X0, Y0, X1, Y1 = 330, 150, 750, 570
local function F(s) return {VP[1] + (X0 - VP[1])*s, VP[2] + (Y0 - VP[2])*s, VP[1] + (X1 - VP[1])*s, VP[2] + (Y1 - VP[2])*s} end
local S = {1, 0.74, 0.55, 0.41, 0.305, 0.227, 0.169, 0.126}
local dk = brush{kind="round", width=3.2, point=0.3}
local md = brush{kind="round", width=1.6, point=0.6}
local hot = brush{kind="round", width=1.2, point=0.7}
local function line(br, p, a, b, pr) br:load(p, 0.6); br:stroke({a, b}, {pressure={pr, pr}, ramps={0.02, 0.02}}) end
-- longitudinal rails: corners and wall divisions, straight to the vanishing point
for k = 0, 8 do
  local t = k / 8
  local top = {lerp(X0, X1, t), Y0}; local bot = {lerp(X0, X1, t), Y1}
  local lef = {X0, lerp(Y0, Y1, t)}; local rig = {X1, lerp(Y0, Y1, t)}
  local inner = S[#S]
  for _, q in ipairs({top, bot, lef, rig}) do
    local e = {VP[1] + (q[1] - VP[1])*inner, VP[2] + (q[2] - VP[2])*inner}
    line((k % 4 == 0) and dk or md, (k % 4 == 0) and lDark or lMid, q, e, 0.8)
  end
end
-- the frames (ribs), and plate seams between them
for i, s in ipairs(S) do
  local f = F(s)
  local br = dk
  for _, seg in ipairs({{{f[1],f[2]},{f[3],f[2]}}, {{f[3],f[2]},{f[3],f[4]}}, {{f[3],f[4]},{f[1],f[4]}}, {{f[1],f[4]},{f[1],f[2]}}}) do
    line(br, lDark, seg[1], seg[2], 0.9)
  end
  if i < #S then
    local g = F((s + S[i+1]) / 2)
    for _, seg in ipairs({{{g[1],g[2]},{g[3],g[2]}}, {{g[3],g[4]},{g[1],g[4]}}, {{g[1],g[2]},{g[1],g[4]}}, {{g[3],g[2]},{g[3],g[4]}}}) do
      line(md, lMid, seg[1], seg[2], 0.6)
    end
  end
  -- glare along the lit edge of every rib (upper and left)
  line(hot, lHot, {f[1] + 2.5, f[2] + 2.5}, {f[3] - 2.5, f[2] + 2.5}, 0.7)
  line(hot, lHot, {f[1] + 2.5, f[2] + 2.5}, {f[1] + 2.5, f[4] - 2.5}, 0.7)
end
-- the heavy outer rib
local big = brush("flat", 8)
for _, seg in ipairs({{{X0,Y0},{X1,Y0}}, {{X1,Y0},{X1,Y1}}, {{X1,Y1},{X0,Y1}}, {{X0,Y1},{X0,Y0}}}) do
  big:load(lDark, 0.7); big:stroke(seg, {pressure={0.9, 0.9}, ramps={0.01, 0.01}, orient="across"})
end

--@ chunk 5
-- the four walls take four flat values (ceiling glaring, floor cold-dark), then rows of identical windows
local X0, Y0, X1, Y1 = 330, 150, 750, 570
local s = 0.126
local ix0, iy0 = VP[1] + (X0 - VP[1])*s, VP[2] + (Y0 - VP[2])*s
local ix1, iy1 = VP[1] + (X1 - VP[1])*s, VP[2] + (Y1 - VP[2])*s
local top = poly({{X0,Y0},{X1,Y0},{ix1,iy0},{ix0,iy0}})
local bot = poly({{X0,Y1},{X1,Y1},{ix1,iy1},{ix0,iy1}})
local rig = poly({{X1,Y0},{X1,Y1},{ix1,iy1},{ix1,iy0}})
local lef = poly({{X0,Y0},{X0,Y1},{ix0,iy1},{ix0,iy0}})
local gzBlue = pile{{"ultramarine blue",1},{"cerulean blue",0.5}, medium=0.75}
local gzDeep = pile{{"ultramarine blue",1},{"bone black",0.4}, medium=0.7}
local gzWhite = pile{{"zinc white",1}, medium=0.6}
work(bot, {hand="glaze", pile=gzDeep, coverage=1.5, fill=true, angle=0, ruler=true, clip=true, load=0.55})
work(rig, {hand="glaze", pile=gzBlue, coverage=1.4, fill=true, angle=math.pi/2, ruler=true, clip=true, load=0.45})
work(top, {hand="glaze", pile=gzWhite, coverage=1.4, fill=true, angle=0, ruler=true, clip=true, load=0.4})
-- windows: identical bright rectangles on the side walls, one per plate, perspective-scaled
local w = brush("flat", 3)
local S = {1, 0.74, 0.55, 0.41, 0.305, 0.227, 0.169}
local n = 0
for i = 1, #S - 1 do
  local sm = (S[i] + S[i+1]) / 2
  for _, side in ipairs({-1, 1}) do
    local xw = VP[1] + ((side < 0) and (X0 - VP[1]) or (X1 - VP[1])) * sm
    for k = 1, 3 do
      local yw = VP[2] + (lerp(Y0, Y1, k/4) - VP[2]) * sm
      local hh = 9 * sm
      w:load(lHot, 0.6)
      w:stroke({{xw - side*3*sm, yw - hh}, {xw - side*3*sm, yw + hh}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, orient="across"})
      n = n + 1
    end
  end
end
print(n)

--@ chunk 6
print(wait(3*24*60))
-- re-rule the lattice over the walls: dark seams on the pale walls, glaring seams on the blue ones
local X0, Y0, X1, Y1 = 330, 150, 750, 570
local function wall(x, y) local dx, dy = (x - VP[1]) / 210, (y - VP[2]) / 210
  if math.abs(dy) >= math.abs(dx) then return (dy < 0) and "top" or "bot" else return (dx < 0) and "lef" or "rig" end end
local function pfor(a, b) local w = wall((a[1]+b[1])/2, (a[2]+b[2])/2); return (w == "bot" or w == "rig") and lHot or lDark end
local function F(s) return {VP[1] + (X0 - VP[1])*s, VP[2] + (Y0 - VP[2])*s, VP[1] + (X1 - VP[1])*s, VP[2] + (Y1 - VP[2])*s} end
local S = {1, 0.74, 0.55, 0.41, 0.305, 0.227, 0.169, 0.126}
local md = brush{kind="round", width=1.5, point=0.6}
local dk = brush{kind="round", width=2.6, point=0.4}
local function line(br, a, b, pr) br:load(pfor(a, b), 0.6); br:stroke({a, b}, {pressure={pr, pr}, ramps={0.02, 0.02}}) end
for k = 0, 8 do
  local t = k / 8
  for _, q in ipairs({{lerp(X0, X1, t), Y0}, {lerp(X0, X1, t), Y1}, {X0, lerp(Y0, Y1, t)}, {X1, lerp(Y0, Y1, t)}}) do
    local e = {VP[1] + (q[1] - VP[1])*0.126, VP[2] + (q[2] - VP[2])*0.126}
    -- split each rail so each part takes its wall's colour
    line((k % 4 == 0) and dk or md, q, e, 0.75)
  end
end
for i, s in ipairs(S) do
  local f = F(s)
  for _, seg in ipairs({{{f[1],f[2]},{f[3],f[2]}}, {{f[3],f[2]},{f[3],f[4]}}, {{f[3],f[4]},{f[1],f[4]}}, {{f[1],f[4]},{f[1],f[2]}}}) do line(dk, seg[1], seg[2], 0.85) end
  if i < #S then
    local g = F((s + S[i+1]) / 2)
    for _, seg in ipairs({{{g[1],g[2]},{g[3],g[2]}}, {{g[3],g[4]},{g[1],g[4]}}, {{g[1],g[2]},{g[1],g[4]}}, {{g[3],g[2]},{g[3],g[4]}}}) do line(md, seg[1], seg[2], 0.55) end
  end
end

--@ chunk 7
-- their organs, soft and warm, pressing flat against the rigid frame from outside
fOrgan = pile{{"rose madder",1},{"lead white",1},{"Mars orange",0.3}}
fOrganD = pile{{"rose madder",1},{"bone brown",0.8},{"cobalt violet",0.4}}
fBlanch = pile{{"lead white",2},{"rose madder",0.4},{"Indian yellow",0.2}}
ORG = {}
local defs = {{470, 112, 78, 52}, {795, 330, 58, 92}, {292, 240, 50, 66}, {690, 610, 92, 50}}
for i, d in ipairs(defs) do
  local m = (ellipse(d[1], d[2], d[3], d[4]):roughen(6, 50, 40 + i) + ellipse(d[1] + d[3]*0.5, d[2] - d[4]*0.3, d[3]*0.55, d[4]*0.55):roughen(5, 40, 60 + i)) - LAT
  ORG[i] = m
  local ang = function(x, y) return math.atan(y - d[2], x - d[1]) + math.pi/2 end
  work(m, {hand="body", pile=fOrganD, coverage=2.4, fill=true, angle=ang, clip=m:soften(3)})
  local lit = m * ellipse(d[1] - d[3]*0.15, d[2] - d[4]*0.2, d[3]*0.7, d[4]*0.65)
  work(lit, {hand="body", pile=fOrgan, coverage=2.2, fill=true, angle=ang, clip=m})
  local contact = m * (LAT:grow(10) - LAT)
  work(contact, {hand="body", pile=fBlanch, coverage=2, fill=true, angle=0, clip=m})
  blend(m, {angle=ang})
end

--@ chunk 8
-- model the organs: creases and ridges curling round each, veins, and their outer edges lost into the folds
local defs = {{470, 112, 78, 52}, {795, 330, 58, 92}, {292, 240, 50, 66}, {690, 610, 92, 50}}
local ridgeP = pile{{"lead white",1.5},{"rose madder",0.6},{"Indian yellow",0.3}}
local veinP = pile{{"rose madder",1},{"cobalt violet",0.6},{"bone brown",0.4}}
local b = brush("filbert", 7)
local v = brush{kind="round", width=1.4, point=0.8}
FARLAT = -LAT:grow(14)
for i, d in ipairs(defs) do
  local m = ORG[i]
  for k = 1, 9 do
    local r0 = rand(0.25, 0.9)
    local a0 = rand(0, 6.28)
    local pts = {}
    for j = 0, 8 do
      local a = a0 + j * 0.22
      local rr = r0 * (1 + 0.12 * math.sin(j * 1.3 + k))
      pts[#pts+1] = {d[1] + math.cos(a) * d[3] * rr, d[2] + math.sin(a) * d[4] * rr}
    end
    b:reload((k % 3 == 0) and ridgeP or fOrganD, 0.55)
    b:stroke(pts, {pressure={0.2, 0.5}, swell={0.5, 1, 0.4}, ramps={0.3, 0.4}, orient="across", clip=m})
  end
  for k = 1, 5 do
    local x, y = d[1] + rand(-0.6, 0.6) * d[3], d[2] + rand(-0.6, 0.6) * d[4]
    local pts = {{x, y}}
    for j = 1, 6 do x = x + rand(-9, 9); y = y + rand(-9, 9); pts[#pts+1] = {x, y} end
    v:reload(veinP, 0.5)
    v:stroke(pts, {pressure={0.35, 0.1}, ramps={0.1, 0.5}, clip=m})
  end
  local outer = m:grow(1)
  lose(outer, {pile=fDeep, where=FARLAT, reach={6, 16}, load=0.35, tool="filbert 6"})
end

--@ chunk 9
-- the seam: the lattice's lower-left corner has opened and the folding pours in
SEAM = poly({{328,428},{352,446},{366,478},{392,500},{404,532},{446,552},{470,572},{328,572}}):roughen(5, 30, 77)
local tongue = poly({{360,470},{420,505},{500,520},{560,540},{470,560},{400,550}}, true):roughen(6, 40, 78) * LAT
work(SEAM, {hand="body", pile=fDeep, coverage=2.6, fill=true, angle=-0.7, clip=SEAM})
local b = brush("filbert", 10)
for i = 1, 26 do
  local x, y = rand(180, 360), rand(470, 700)
  local pts = {{x, y}}
  local a = math.atan(500 - y, 430 - x) + rand(-0.3, 0.3)
  for j = 1, 22 do
    a = a + rand(-0.25, 0.25) + 0.04
    x = x + math.cos(a) * 9; y = y + math.sin(a) * 9
    pts[#pts+1] = {x, y}
  end
  local r = math.random()
  b:reload((r < 0.35) and fEmber or ((r < 0.7) and fLit or fViol), 0.6)
  b:stroke(pts, {pressure={0.5, 0.25}, swell={0.7, 1, 0.4}, ramps={0.2, 0.5}, orient="across", clip=SEAM:grow(2) + tongue + (OUT * rect(150, 420, 260, 300))})
end
blend(SEAM:grow(3) + tongue, {angle=-0.5})
-- the broken lattice lines at the seam's lip: a few glaring splinters
local s = brush{kind="round", width=1.4, point=0.8}
s:load(lHot, 0.6)
for _, seg in ipairs({{{352,446},{362,452}}, {{392,500},{404,509}}, {{446,552},{452,560}}, {{366,478},{371,489}}}) do
  s:stroke(seg, {pressure={0.6, 0.3}, ramps={0.02, 0.5}})
end

--@ chunk 10
-- soften: the tendrils into the folds, and each organ's outer edge into the dark (not where it presses the frame)
blend((OUT * rect(140, 400, 280, 320)) - SEAM:grow(2), {angle=-0.6})
for i = 1, 4 do
  local ring = (ORG[i]:grow(9) - ORG[i]:shrink(9)) - LAT:grow(5)
  blend(ring:soften(3), {angle=0.8})
end
-- the far end of the corridor: the glare at its heart
local g = rect(522, 334, 46, 44)
work(g, {hand="body", pile=gGlare, coverage=2.4, fill=true, angle=0, ruler=true, clip=true})

--@ chunk 11
-- dissolve the rectangular edge the last blend left
local r = rect(140, 400, 280, 320)
local band = ((r:grow(22) - r:shrink(22)) * OUT - SEAM:grow(2)):soften(14)
blend(band, {angle=-0.6})
blend(band, {angle=0.9})

--@ chunk 12
-- the pour: warm living light curling through the opened corner and along the corridor floor
local inside = SEAM:grow(3) + (poly({{360,470},{430,500},{520,520},{580,545},{470,566},{390,556}}, true) * LAT)
local b = brush("filbert", 6)
for i = 1, 22 do
  local x, y = rand(300, 380), rand(470, 580)
  local a = rand(-0.5, 0.1)
  local pts = {{x, y}}
  for j = 1, 18 do a = a + rand(-0.3, 0.3); x = x + math.cos(a) * 8; y = y + math.sin(a) * 6; pts[#pts+1] = {x, y} end
  b:reload((i % 3 == 0) and fLit or fEmber, 0.6)
  b:stroke(pts, {pressure={0.55, 0.15}, swell={0.8, 1, 0.3}, ramps={0.15, 0.6}, orient="across", clip=inside})
end

--@ chunk 13
local inside = SEAM:grow(3) + (poly({{360,470},{430,500},{520,520},{580,545},{470,566},{390,556}}, true) * LAT)
blend(inside, {angle=-0.3})

--@ chunk 14
-- a few broad soft folds back into the flattened pour (into wet paint, no blending)
local inside = SEAM:grow(3) + (poly({{360,470},{430,500},{520,520},{580,545},{470,566},{390,556}}, true) * LAT)
local b = brush("filbert", 13)
local paths = {
  {{318,560},{350,540},{390,530},{440,532},{500,538},{560,545}},
  {{322,520},{350,505},{372,500},{400,515},{430,522}},
  {{330,470},{345,480},{352,500},{370,520},{395,545},{430,560}},
  {{318,545},{360,556},{410,560},{460,562}},
}
for i, p in ipairs(paths) do
  b:reload((i % 2 == 1) and fLit or fEmber, 0.6)
  b:stroke(p, {pressure={0.45, 0.3}, swell={0.7, 1, 0.6}, ramps={0.2, 0.4}, orient="across", clip=inside})
end
b:reload(fCrease, 0.5)
b:stroke({{326,500},{345,512},{360,530},{388,538}}, {pressure={0.4, 0.2}, ramps={0.2, 0.5}, orient="across", clip=inside})
