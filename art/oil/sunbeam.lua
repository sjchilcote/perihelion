-- easel session "sunbeam": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=1.6, linen={18,16}, seed=9127,
  ground={{pile={{"bone brown",2},{"ultramarine blue",1},{"lead white",0.6}}, um=100, apply="knife", texture=0.3}}}
GA = math.pi * (3 - math.sqrt(5))
function yE(x) return 250 + 110 * ((1000 - x) / 1000) ^ 1.6 end
HULL = below(function(x) return yE(x) end)
SKY = everywhere() - HULL
-- the sunlit limb: the right end, where the hull turns into the sun
LIMB = HULL * mask(function(x, y) return (x > 905 + 0.12 * (y - 250)) and 1 or 0 end)
SPACE = pile{{"ultramarine blue",2},{"burnt sienna",1},{"bone black",0.6}}
HD = pile{{"bone brown",2},{"burnt sienna",1},{"ultramarine blue",0.6},{"raw sienna",0.3}}
HD2 = pile{{"bone brown",2},{"raw sienna",1},{"ultramarine blue",0.4}}
work(SKY, {hand="body", pile=SPACE, coverage=3, fill=true, clip=true, angle=0.2})
local nearpart = HULL * mask(function(x, y) return (y - yE(x) > 140) and 1 or 0 end)
work((HULL - LIMB) - nearpart, {hand="body", pile=HD, coverage=3, fill=true, clip=true, angle=0.1})
work(nearpart - LIMB, {hand="body", pile=HD2, coverage=3, fill=true, clip=true, angle=0.1})
LB = pile{{"Mars yellow",2},{"lead white",1.5},{"yellow ochre",1},{"cadmium yellow",0.3}}
work(LIMB, {hand="body", pile=LB, coverage=3, fill=true, clip=true, angle=math.pi/2})

--@ chunk 2
print(wait(2*24*60))
SPACE2 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.6}}
work(SKY, {hand="body", pile=SPACE2, coverage=3, fill=true, clip=true, angle=0.2})
-- terminator: a narrow dim band between night and the lit limb
local TB = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.5},{"yellow ochre",0.5}}
local term = HULL * mask(function(x, y) local d = x - (905 + 0.12 * (y - 250)); return (d > -38 and d <= 0) and 1 or 0 end)
work(term, {hand="body", pile=TB, coverage=3, fill=true, clip=true, angle=math.pi/2 + 0.12})
local LB2 = pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.4}}
local hot = LIMB * mask(function(x, y) return (x > 935 + 0.12 * (y - 250)) and 1 or 0 end)
work(hot, {hand="body", pile=LB2, coverage=3, fill=true, clip=true, angle=math.pi/2 + 0.12})
-- melt the three bands into each other at the terminator (narrow seams, clipped)
local s1 = HULL * mask(function(x, y) local d = x - (905 + 0.12 * (y - 250)); return (math.abs(d) < 8 or math.abs(d + 38) < 8 or math.abs(d - 30) < 7) and 1 or 0 end)
blend(s1, {angle=math.pi/2 + 0.12})

--@ chunk 3
print(wait(24*60))
function yE(x) return 250 + 110 * (math.max(0, 1000 - x) / 1000) ^ 1.6 end
LIPS = {}
local k = 1
while true do
  local v = 4 * k ^ 1.6
  if v > 420 then break end
  local w = 9 + 0.10 * v
  local dv = 4 * ((k + 1) ^ 1.6 - k ^ 1.6)
  local off = ((k * 0.618034) % 1) * w
  local x = -w + off
  while x < 1010 do
    local ww = w * (0.85 + 0.3 * ((x * 0.37 + k * 1.7) % 1))
    LIPS[#LIPS+1] = {x = x, y = yE(x) + v, w = ww, h = math.min(dv * 0.9, ww * 0.45), k = k}
    x = x + ww * 0.92
  end
  k = k + 1
end
LIPD = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.6}}
LIPN = pile{{"raw sienna",2},{"burnt sienna",1},{"bone black",0.6},{"yellow ochre",0.4}}
LIPLD = pile{{"burnt sienna",2},{"Mars orange",0.5},{"raw sienna",1}}
LIPLL = pile{{"lead white",3},{"lemon chrome",0.3},{"Mars yellow",0.5}}
function lip(L, dark, light, scale)
  local x, y, w, h = L.x, L.y, L.w, L.h
  local dw = clamp(0.12 * w, 0.9, 3.2) * (scale or 1)
  local b = brush{kind="round", width=dw, point=0.5}
  b:reload(dark, 0.8)
  b:stroke({{x - w/2, y - h * 0.15}, {x - w * 0.3, y + h * 0.6}, {x, y + h}, {x + w * 0.3, y + h * 0.6}, {x + w/2, y - h * 0.15}},
    {pressure={0.25, 0.25}, swell={0.6, 1.0, 1.2, 1.0, 0.6}})
  if light then
    local l = brush{kind="round", width=math.max(0.7, dw * 0.55), point=0.6}
    l:reload(light, 0.7)
    l:stroke({{x - w * 0.36, y + h * 0.35}, {x, y + h * 0.72}, {x + w * 0.36, y + h * 0.35}}, {pressure={0.1, 0.3}})
  end
end
local n = 0
for _, L in ipairs(LIPS) do
  if L.x < 1005 then
    if LIMB:at(L.x, L.y) > 0.5 then lip(L, LIPLD, LIPLL) else lip(L, LIPD, LIPN) end
    n = n + 1
  end
end
print(#LIPS, n)

--@ chunk 4
print(wait(2*24*60))
local GN = pile{{"bone brown",1},{"ultramarine blue",0.6},{"burnt sienna",0.6},{"bone black",0.4}, medium=0.8}
NIGHT = HULL * mask(function(x, y) return (x - (905 + 0.12 * (y - 250)) < -40) and 1 or 0 end)
work(NIGHT, {hand="glaze", pile=GN, clip=true, load=0.8})
blend(NIGHT, {angle=0.1})

--@ chunk 5
print(wait(24*60))
LIPN2 = pile{{"raw sienna",2},{"yellow ochre",1},{"burnt sienna",0.6},{"bone black",0.3}}
for _, L in ipairs(LIPS) do
  if NIGHT:at(L.x, L.y) > 0.5 then lip(L, LIPD, LIPN2) end
end
-- rows of windows: tiny warm squares between plates, golden-ratio gaps, few lit
local WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.4}}
local WDK = pile{{"bone black",2},{"ultramarine blue",0.5}}
local st = brush{kind="round", width=1.4}
local rows = {{9, 0.09}, {13, 0.05}, {15, 0.12}}
local n = 0
for ri, r in ipairs(rows) do
  local k = r[1]
  local v = 4 * k ^ 1.6 + 2
  local x = 8 + 5 * ri
  local i = 0
  while x < 880 do
    i = i + 1
    local y = yE(x) + v + 0.5 * (4 * ((k + 1) ^ 1.6 - k ^ 1.6))
    local sz = clamp(1 + 0.012 * v, 1, 4)
    local lit = ((i * 0.618034 + ri * 0.3) % 1) < r[2] * 2.2
    local b = brush{kind="round", width=sz}
    b:reload(lit and WIN or WDK, 0.8)
    b:touch(x, y, {pressure=0.7})
    if lit then n = n + 1 end
    x = x + (6 + 0.05 * v) * (1 + 0.618 * ((i * GA) % 1))
  end
end
print(n)

--@ chunk 6
NOTCH = {}
for i = 1, 8 do NOTCH[i] = (i * GA * 1.0 + 0.4) % (2 * math.pi) end
function ocr(th)
  for _, a in ipairs(NOTCH) do
    local d = math.abs(((th - a + math.pi) % (2 * math.pi)) - math.pi)
    if d < 0.15 then return 0.76 end
  end
  return 1
end
function oculus_mask(cx, cy, rx, ry, rot, shear, step)
  return mask(function(x, y)
    local dx, dy = x - cx, y - cy
    if step then
      local v = y - yE(x)
      if v > 0 then
        local kk = (v / 4) ^ (1 / 1.6)
        dx = dx + step * ((math.floor(kk) % 2) * 2 - 1)
        dy = dy - step * 0.8 * (kk % 1)
      end
    end
    local c, s = math.cos(rot), math.sin(rot)
    local u = (c * dx + s * dy) / rx
    local w = (-s * dx + c * dy) / ry
    u = u - shear * w
    local r = math.sqrt(u * u + w * w)
    if r < 0.3 then return 0 end
    local th = math.atan(w, u)
    return r <= ocr(th) and 1 or 0
  end)
end
-- the real aperture, on the sunlit limb
local ap = oculus_mask(960, 335, 13, 30, 0.12, 0, nil)
local apall = ap + ellipse(960, 335, 13 * 0.3, 30 * 0.3)
work(ap, {hand="detail", tool={kind="round", width=1.2}, pile=LIPD, coverage=3, fill=true, clip=true})
local rim = (apall:grow(1.5) - apall) * oculus_mask(958, 335, 13, 30, 0.12, 0, nil):grow(2)
work((apall:grow(1.4) - apall) * mask(function(x, y) return x < 960 and 1 or 0 end), {hand="detail", tool={kind="round", width=1}, pile=LIPLD, coverage=3, fill=true, clip=true})
work((apall:grow(1.4) - apall) * mask(function(x, y) return x >= 960 and 1 or 0 end), {hand="detail", tool={kind="round", width=1}, pile=LIPLL, coverage=3, fill=true, clip=true})
-- the stolen sunbeam: the same oculus, cast across the night plates
PATCH = oculus_mask(330, 468, 112, 64, -0.06, 0.18, 2.5) * NIGHT
SUN = pile{{"lead white",2.5},{"Mars yellow",1},{"cadmium yellow",0.4},{"yellow ochre",0.4}}
work(PATCH, {hand="body", tool={kind="filbert", width=4}, pile=SUN, coverage=3.5, fill=true, clip=true, angle=0.05})
print(PATCH:area(), ap:area())

--@ chunk 7
print(wait(2*24*60))
work(PATCH, {hand="body", tool={kind="filbert", width=3}, pile=SUN, coverage=3.5, fill=true, clip=true, angle=0.05})
print(wait(2*24*60))
-- every plate inside the light: its lip throws a hard little shadow, its edge catches full sun
local SH = pile{{"burnt sienna",2},{"bone brown",1},{"Mars orange",0.3}}
local n = 0
for _, L in ipairs(LIPS) do
  if PATCH:grow(L.w):at(L.x, L.y) > 0.5 then
    local x, y, w, h = L.x, L.y, L.w, L.h
    local b = brush{kind="round", width=clamp(0.16 * w, 1.2, 3.5), point=0.5}
    b:reload(SH, 0.85)
    b:stroke({{x - w/2, y - h * 0.1}, {x - w * 0.3, y + h * 0.62}, {x, y + h}, {x + w * 0.3, y + h * 0.62}, {x + w/2, y - h * 0.1}},
      {pressure={0.35, 0.35}, swell={0.5, 1.0, 1.3, 1.0, 0.5}, clip=PATCH})
    local l = brush{kind="round", width=clamp(0.08 * w, 0.8, 2), point=0.6}
    l:reload(LIPLL, 0.8)
    l:stroke({{x - w * 0.4, y + h * 0.25}, {x, y + h * 0.66}, {x + w * 0.4, y + h * 0.25}}, {pressure={0.3, 0.45}, clip=PATCH})
    n = n + 1
  end
end
print(n)

--@ chunk 8
-- stars: few, uneven, clustered, a couple brighter
local STAR = pile{{"zinc white",3},{"lead white",1}}
local STB = pile{{"zinc white",3},{"cerulean blue",0.3}}
local n = 0
for i = 1, 240 do
  local x = rand(0, 1000)
  local y = rand(0, 360) ^ 1.0
  local cl = noise{seed=4, period=220}
  if SKY:at(x, y) > 0.5 and y < yE(x) - 6 and (cl(x, y) > -0.1 or i % 5 == 0) then
    local big = (i % 37 == 0)
    local b = brush{kind="round", width=big and 2.2 or rand(0.7, 1.3)}
    b:reload((i % 3 == 0) and STB or STAR, big and 0.8 or 0.5)
    b:touch(x, y, {pressure=big and 0.7 or rand(0.3, 0.6)})
    n = n + 1
  end
end
-- the grazing sun just catches the crest of the hull near the limb
local crest = {}
for x = 640, 1000, 10 do crest[#crest+1] = {x, yE(x) + 0.8} end
local r = brush{kind="round", width=1.4, point=0.6}
r:reload(LIPLL, 0.8)
r:stroke(crest, {pressure={0.02, 0.6}, ramps={0.6, 0.02}})
print(n)

--@ chunk 9
-- a row of slightly larger windows low on the hull; a few lit, at golden-ratio gaps
local WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.5}}
local WG = pile{{"Mars orange",1},{"burnt sienna",1},{"cadmium yellow",0.3}}
local k = 17
local v = 4 * k ^ 1.6 + 3
local x = 20
local i = 0
local n = 0
while x < 880 do
  i = i + 1
  local y = yE(x) + v + 6
  if ((i * 0.618034) % 1) < 0.22 and PATCH:grow(6):at(x, y) < 0.1 then
    local g = brush{kind="round", width=5}
    g:reload(WG, 0.3); g:touch(x, y, {pressure=0.25})
    local b = brush{kind="flat", width=2.6}
    b:reload(WIN, 0.85); b:touch(x, y, {pressure=0.7})
    n = n + 1
  end
  x = x + 17 * (1 + 0.618 * ((i * GA) % 1))
end
print(n)

--@ chunk 10
-- a row of slightly larger windows low on the hull; a few lit, at golden-ratio gaps
local WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.5}}
local WG = pile{{"Mars orange",1},{"burnt sienna",1},{"cadmium yellow",0.3}}
local k = 13
local v = 4 * k ^ 1.6 + 3
local x = 20
local i = 0
local n = 0
while x < 880 do
  i = i + 1
  local y = yE(x) + v + 6
  if ((i * 0.618034) % 1) < 0.22 and PATCH:grow(6):at(x, y) < 0.1 then
    local g = brush{kind="round", width=5}
    g:reload(WG, 0.3); g:touch(x, y, {pressure=0.25})
    local b = brush{kind="flat", width=2.6}
    b:reload(WIN, 0.85); b:touch(x, y, {pressure=0.7})
    n = n + 1
  end
  x = x + 17 * (1 + 0.618 * ((i * GA) % 1))
end
print(n)

--@ chunk 11
-- SECOND PASS 1: the hull rolls into the light, plate by plate
TP = {
  pile{{"bone brown",2},{"burnt sienna",1},{"raw sienna",0.6}},
  pile{{"burnt sienna",2},{"raw sienna",1.5},{"bone brown",0.6}},
  pile{{"raw sienna",2},{"burnt sienna",1},{"yellow ochre",1}},
  pile{{"yellow ochre",2},{"Mars yellow",1},{"raw sienna",0.6},{"lead white",0.3}},
  pile{{"Mars yellow",2},{"yellow ochre",1},{"lead white",1}},
  pile{{"lead white",2},{"Mars yellow",1},{"cadmium yellow",0.4}},
}
function plate_face(L, pl, clipm)
  local x, y, w, h = L.x, L.y, L.w, L.h
  local b = brush{kind="filbert", width=clamp(h * 1.1, 2, 14)}
  b:reload(pl, 0.85)
  b:stroke({{x - w * 0.42, y + h * 0.15}, {x, y + h * 0.35}, {x + w * 0.42, y + h * 0.15}}, {pressure={0.8, 0.8}, ramps={0.05, 0.05}, clip=clipm})
end
function crescent(L, dark, light, clipm)
  local x, y, w, h = L.x, L.y, L.w, L.h
  local b = brush{kind="round", width=clamp(0.16 * w, 1.1, 3.6), point=0.5}
  b:reload(dark, 0.85)
  b:stroke({{x - w/2, y - h * 0.1}, {x - w * 0.3, y + h * 0.62}, {x, y + h}, {x + w * 0.3, y + h * 0.62}, {x + w/2, y - h * 0.1}},
    {pressure={0.35, 0.35}, swell={0.5, 1.0, 1.4, 1.0, 0.5}, clip=clipm})
  local l = brush{kind="round", width=clamp(0.08 * w, 0.8, 2), point=0.6}
  l:reload(light, 0.8)
  l:stroke({{x - w * 0.4, y + h * 0.25}, {x, y + h * 0.66}, {x + w * 0.4, y + h * 0.25}}, {pressure={0.3, 0.45}, clip=clipm})
end
local zone = HULL * mask(function(x, y) return (x - 0.12 * (y - 250) > 770) and 1 or 0 end)
local n = 0
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 760 and L.x < 1010 then
    local t = smoothstep(780, 955, d + 14 * (((i * 0.618034) % 1) - 0.5))
    local idx = 1 + math.floor(t * 5.999)
    plate_face(L, TP[idx], zone)
    n = n + 1
  end
end
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 760 and L.x < 1010 then
    local t = smoothstep(780, 955, d)
    if t < 0.35 then crescent(L, LIPD, TP[3], zone) else crescent(L, LIPLD, LIPLL, zone) end
  end
end
print(n)

--@ chunk 12
local zone = HULL * mask(function(x, y) return (x - 0.12 * (y - 250) > 770) and 1 or 0 end)
local edges = {770, 815, 850, 880, 905, 930, 2000}
for j = 1, 6 do
  local a, b = edges[j], edges[j + 1]
  local m = zone * mask(function(x, y) local d = x - 0.12 * (y - 250); return (d > a and d <= b) and 1 or 0 end)
  work(m, {hand="body", tool={kind="filbert", width=5}, pile=TP[j], coverage=3, fill=true, clip=true, angle=0.08})
end
function plate_face2(L, pl, clipm)
  local x, y, w, h = L.x, L.y, L.w, L.h
  local b = brush{kind="filbert", width=clamp(h * 1.2, 2, 16)}
  b:reload(pl, 0.85)
  b:stroke({{x - w * 0.55, y + h * 0.05}, {x, y + h * 0.4}, {x + w * 0.55, y + h * 0.05}}, {pressure={0.85, 0.85}, ramps={0.03, 0.03}, clip=clipm})
end
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 760 and L.x < 1010 then
    local t = smoothstep(780, 955, d + 14 * (((i * 0.618034) % 1) - 0.5))
    plate_face2(L, TP[1 + math.floor(t * 5.999)], zone)
  end
end
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 760 and L.x < 1010 then
    local t = smoothstep(780, 955, d)
    if t < 0.35 then crescent(L, LIPD, TP[3], zone) else crescent(L, LIPLD, LIPLL, zone) end
  end
end

--@ chunk 13
print(wait(24*60))
local zone = HULL * mask(function(x, y) return (x - 0.12 * (y - 250) > 740) and 1 or 0 end)
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 745 and L.x < 1010 then
    local t = smoothstep(770, 960, d + 36 * (((i * 0.618034) % 1) - 0.5))
    plate_face2(L, TP[1 + math.floor(t * 5.999)], zone)
  end
end
for i, L in ipairs(LIPS) do
  local d = L.x - 0.12 * (L.y - 250)
  if d > 745 and L.x < 1010 then
    local t = smoothstep(770, 960, d)
    if t < 0.35 then crescent(L, LIPD, TP[3], zone) else crescent(L, LIPLD, LIPLL, zone) end
  end
end

--@ chunk 14
-- the aperture restated over the repainted limb
local ap = oculus_mask(960, 335, 13, 30, 0.12, 0, nil)
local apall = ap + ellipse(960, 335, 13 * 0.3, 30 * 0.3)
work(ap, {hand="detail", tool={kind="round", width=1.2}, pile=LIPD, coverage=3, fill=true, clip=true})
work((apall:grow(1.4) - apall) * mask(function(x, y) return x >= 960 and 1 or 0 end), {hand="detail", tool={kind="round", width=1}, pile=LIPLL, coverage=3, fill=true, clip=true})
-- SECOND PASS 2: inside the stolen light, the same golden plate faces as on the limb
for i, L in ipairs(LIPS) do
  if PATCH:grow(L.w):at(L.x, L.y) > 0.5 then
    plate_face(L, TP[((i % 3) == 0) and 6 or 5], PATCH)
  end
end
for i, L in ipairs(LIPS) do
  if PATCH:grow(L.w):at(L.x, L.y) > 0.5 then crescent(L, LIPLD, LIPLL, PATCH) end
end
-- a faint warm bounce on the plates around it
local BW = pile{{"Mars orange",1},{"raw sienna",1},{"yellow ochre",0.6}}
local ring = PATCH:grow(26) - PATCH
for _, L in ipairs(LIPS) do
  if ring:at(L.x, L.y + L.h * 0.5) > 0.5 and NIGHT:at(L.x, L.y) > 0.5 then
    local l = brush{kind="round", width=clamp(0.09 * L.w, 0.8, 2.2), point=0.6}
    l:reload(BW, 0.5)
    l:stroke({{L.x - L.w * 0.38, L.y + L.h * 0.3}, {L.x, L.y + L.h * 0.68}, {L.x + L.w * 0.38, L.y + L.h * 0.3}}, {pressure={0.2, 0.35}, clip=-PATCH})
  end
end

--@ chunk 15
local ap = oculus_mask(960, 335, 13, 30, 0.12, 0, nil)
local apall = ap + ellipse(960, 335, 13 * 0.3, 30 * 0.3)
work(ap, {hand="detail", tool={kind="round", width=1.2}, pile=LIPD, coverage=3, fill=true, clip=true})
work((apall:grow(1.4) - apall) * mask(function(x, y) return x >= 960 and 1 or 0 end), {hand="detail", tool={kind="round", width=1}, pile=LIPLL, coverage=3, fill=true, clip=true})
-- SECOND PASS 3: rows of larger windows on the night side; a lit rim on the horizon
local WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.5}}
local WG = pile{{"Mars orange",1},{"burnt sienna",1},{"cadmium yellow",0.3}}
local WDK = pile{{"bone black",2},{"ultramarine blue",0.5}}
local n = 0
for ri, k in ipairs({5, 8, 11}) do
  local v = 4 * k ^ 1.6
  local dv = 4 * ((k + 1) ^ 1.6 - k ^ 1.6)
  local x = 12 + 9 * ri
  local i = 0
  while x < 840 do
    i = i + 1
    local y = yE(x) + v + 0.55 * dv
    local sz = clamp(1.6 + 0.022 * v, 1.6, 6)
    if NIGHT:at(x, y) > 0.5 and PATCH:grow(5):at(x, y) < 0.1 then
      local lit = ((i * 0.618034 + ri * 0.37) % 1) < 0.3
      if lit then
        local g = brush{kind="round", width=sz * 2.4}
        g:reload(WG, 0.25); g:touch(x, y, {pressure=0.2})
      end
      local b = brush{kind="flat", width=sz}
      b:reload(lit and WIN or WDK, 0.85)
      b:touch(x, y, {pressure=0.75})
      if lit then n = n + 1 end
    end
    x = x + (sz * 3.2) * (1 + 0.618 * ((i * GA) % 1))
  end
end
-- the thin lit rim on the horizon, strongest toward the sun
local crest = {}
for x = 560, 1000, 8 do crest[#crest+1] = {x, yE(x) + 0.7} end
local r = brush{kind="round", width=1.8, point=0.6}
r:reload(pile{{"lead white",3},{"lemon chrome",0.3}}, 0.9)
r:stroke(crest, {pressure={0.02, 0.75}, ramps={0.7, 0.02}})
print(n)

--@ chunk 16
local WIN = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.5}}
local WG = pile{{"Mars orange",1},{"burnt sienna",0.6},{"cadmium yellow",0.4}}
local n = 0
for ri, k in ipairs({7, 10, 13}) do
  local v = 4 * k ^ 1.6
  local dv = 4 * ((k + 1) ^ 1.6 - k ^ 1.6)
  local x = 30 + 23 * ri
  local i = 0
  while x < 800 do
    i = i + 1
    local y = yE(x) + v + 0.5 * dv
    local sz = clamp(3 + 0.03 * v, 3, 9)
    if NIGHT:at(x, y) > 0.5 and PATCH:grow(8):at(x, y) < 0.1 and ((i * 0.618034 + ri * 0.21) % 1) < 0.38 then
      local g = brush{kind="round", width=sz * 2.2}
      g:reload(WG, 0.3); g:touch(x, y, {pressure=0.25})
      local b = brush{kind="flat", width=sz}
      b:reload(WIN, 0.9); b:touch(x, y, {pressure=0.9, drag={sz * 0.4, 0}})
      n = n + 1
    end
    x = x + sz * 4.5 * (1 + 0.618 * ((i * GA) % 1))
  end
end
print(n)
