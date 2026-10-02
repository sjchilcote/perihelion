-- easel session "klimt": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
canvas{size=900, aspect=0.9, linen={18,16}, seed=1908,
  ground={{pile={{"yellow ochre",2},{"lead white",1},{"Indian yellow",0.5}}, um=80, apply="knife", texture=0.2}}}
-- H = 1111
GOLD = pile{{"Indian yellow",1},{"yellow ochre",1},{"lead white",0.6},{"cadmium yellow",0.2}}
HIM = poly({{250, 160}, {330, 130}, {400, 170}, {430, 300}, {470, 470}, {470, 600}, {450, 800}, {470, 1060}, {150, 1060}, {170, 820}, {175, 600}, {200, 400}, {225, 250}}, true)
HER = poly({{620, 240}, {700, 230}, {760, 300}, {800, 480}, {830, 700}, {860, 1060}, {530, 1060}, {545, 800}, {560, 640}, {580, 450}, {590, 320}}, true)
HAIR = poly({{612, 250}, {640, 222}, {690, 216}, {730, 240}, {752, 290}, {772, 400}, {790, 520}, {752, 520}, {720, 400}, {700, 340}, {640, 340}, {612, 320}}, true)
FACE = ellipse(668, 290, 34, 46)
HEAD = poly({{278, 150}, {340, 128}, {378, 160}, {372, 232}, {292, 232}}, true)
TERM = rect(476, 540, 46, 64)
work(rect(0, 0, 1000, 1111) - HIM - HER, {hand="body", pile=GOLD, coverage=3.2, fill=true, clip=true, angle=0.5, load=1})
work(HIM, {hand="body", pile=pile{{"bone black",1.5},{"ultramarine ash",0.6},{"lead white",0.2}}, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(HER - HAIR - FACE, {hand="body", pile=pile{{"lead white",2},{"cerulean blue",0.5},{"yellow ochre",0.3}}, coverage=3.5, fill=true, clip=true, angle=math.pi/2, load=1})
work(HAIR - FACE, {hand="detail", tool="round 3", pile=pile{{"bone black",2},{"ultramarine blue",0.3}}, coverage=4, fill=true, load=1})
work(FACE, {hand="detail", tool="round 3", pile=pile{{"lead white",2.5},{"yellow ochre",0.25},{"rose madder",0.1}}, coverage=4, fill=true, load=1})
work(TERM, {hand="detail", tool="round 2", pile=pile{{"bone black",1.5},{"ultramarine ash",0.8},{"lead white",0.3}}, coverage=4, fill=true, load=1})
print(wait(5*1440))

--@ chunk 2
local P = {
  blk = pile{{"bone black",2},{"ultramarine blue",0.2}},
  sil = pile{{"lead white",2},{"bone black",0.35},{"ultramarine ash",0.2}},
  crim = pile{{"cadmium red",1},{"rose madder",0.7},{"Mars red",0.2}},
  gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}},
  dgold = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.2}},
  blue = pile{{"cerulean blue",1},{"lead white",1},{"cobalt blue",0.3}},
  pale = pile{{"lead white",2.5},{"cerulean blue",0.2}},
}
-- his robe: Klimt's rectilinear pattern, packed upright oblongs
local inHim = HIM:shrink(4) - HEAD
local n = 0
for i = 1, 520 do
  local x, y = rand(150, 470), rand(230, 1060)
  if inHim:at(x, y) > 0.5 then
    local r = math.random()
    local p = (r < 0.38) and P.blk or ((r < 0.62) and P.sil or ((r < 0.82) and P.crim or P.gold))
    local w, h = rand(7, 18), rand(16, 46)
    local b = brush{kind="flat", width=w}
    b:reload(p, 0.85); b:stroke({{x, y}, {x, y + h}}, {pressure={0.8, 0.8}, ramps={0.02, 0.02}, orient="across", clip=inHim})
    n = n + 1
  end
end
-- her robe: Klimt's curvilinear pattern, discs and spirals
local inHer = HER:shrink(4) - HAIR - FACE
for i = 1, 260 do
  local x, y = rand(530, 860), rand(330, 1060)
  if inHer:at(x, y) > 0.5 then
    local r = rand(6, 15)
    local b = brush{kind="round", width=2 * r, point=0.05}
    local c = math.random()
    b:reload((c < 0.55) and P.gold or ((c < 0.8) and P.blue or P.pale), 0.85); b:touch(x, y, {pressure=0.75, clip=inHer})
    local b2 = brush{kind="round", width=r * 0.8, point=0.05}
    b2:reload((c < 0.55) and P.blue or P.gold, 0.8); b2:touch(x, y, {pressure=0.7, clip=inHer})
  end
end
local sb = brush{kind="round", width=2, point=0.7}
for i = 1, 60 do
  local x, y = rand(540, 850), rand(340, 1050)
  if inHer:at(x, y) > 0.5 then
    local pts = {} local a0 = rand(0, 6.28)
    for k = 0, 30 do local a = a0 + k * 0.42; local rr = 1 + k * 0.45; pts[#pts+1] = {x + rr * math.cos(a), y + rr * math.sin(a)} end
    sb:reload(P.dgold, 0.7); sb:stroke(pts, {pressure={0.5, 0.6}, clip=inHer})
  end
end
-- the ground: golden-angle spirals and fold-notation circles in darker gold
local outside = rect(0, 0, 1000, 1111) - HIM:grow(3) - HER:grow(3)
for i = 1, 70 do
  local x, y = rand(10, 990), rand(10, 1100)
  if outside:at(x, y) > 0.5 then
    if math.random() < 0.55 then
      local pts = {} local a0 = rand(0, 6.28)
      for k = 0, 40 do local a = a0 + k * 0.38; local rr = 1.5 + k * 0.55; pts[#pts+1] = {x + rr * math.cos(a), y + rr * math.sin(a)} end
      sb:reload(P.dgold, 0.7); sb:stroke(pts, {pressure={0.45, 0.6}, clip=outside})
    else
      local R = rand(10, 20)
      local c = {} for k = 0, 32 do local a = k * math.pi / 16; c[#c+1] = {x + R * math.cos(a), y + R * math.sin(a)} end
      sb:reload(P.dgold, 0.7); sb:stroke(c, {pressure={0.5, 0.5}, clip=outside})
      local nsd = math.random(3, 7); local rot = rand(0, 6.28)
      for d = 0, 1 do
        local rr = R * 0.75 * (0.618 ^ d); local q = {}
        for k = 0, nsd do local a = rot + d * 2.399 + k * 2 * math.pi / nsd; q[#q+1] = {x + rr * math.cos(a), y + rr * math.sin(a)} end
        sb:reload(P.dgold, 0.6); sb:stroke(q, {pressure={0.45, 0.45}, clip=outside})
      end
    end
  end
end
print(n)
print(wait(4*1440))

--@ chunk 3
local blk = pile{{"bone black",2},{"ultramarine blue",0.2}}
local steel = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.5}}
local steelL = pile{{"lead white",2},{"ultramarine ash",0.5},{"bone black",0.3}}
local skin = pile{{"lead white",2.5},{"yellow ochre",0.25},{"rose madder",0.12}}
local skinS = pile{{"lead white",1.6},{"yellow ochre",0.35},{"rose madder",0.15},{"cerulean blue",0.1}}
local pale = pile{{"lead white",2},{"cerulean blue",0.5},{"yellow ochre",0.3}}
-- his arm: a sleeve of oblongs from the shoulder to the terminal
ARMH = ribbon({{415, 400}, {440, 480}, {462, 552}}, {44, 38, 30})
work(ARMH - HIM:shrink(10), {hand="detail", tool="round 3", pile=blk, coverage=4, fill=true, load=1})
-- her arm: a pale sleeve of discs reaching from her shoulder down-left to the terminal
ARMR = ribbon({{600, 430}, {575, 510}, {542, 572}}, {40, 34, 26})
work(ARMR - HER:shrink(10), {hand="detail", tool="round 3", pile=pale, coverage=4, fill=true, load=1})
-- the gauntlet, modelled: plates on the back of the hand, fingers gripping the connector
GAUNT = poly({{448, 545}, {470, 538}, {486, 548}, {490, 572}, {478, 590}, {455, 588}, {444, 568}}, true)
work(GAUNT, {hand="detail", tool="round 2", pile=steel, coverage=4.5, fill=true, load=1})
-- her hand: long fingers reaching toward the port
HANDR = poly({{560, 566}, {548, 562}, {530, 566}, {518, 572}, {512, 580}, {524, 582}, {536, 580}, {548, 586}, {562, 584}}, true)
work(HANDR, {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
print(wait(4*1440))
local r = brush{kind="round", width=1.6, point=0.7}
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 1.6, point=0.7}; b:reload(p, 0.7); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.1, 0.3}}) end
-- gauntlet plates and light
st(steelL, {{452, 552}, {468, 543}, {482, 550}}, {0.55, 0.35}, 2)
st(blk, {{450, 566}, {486, 566}}, {0.5, 0.5}, 1.4)
st(blk, {{456, 578}, {482, 580}}, {0.5, 0.5}, 1.4)
st(steelL, {{458, 570}, {478, 571}}, {0.35, 0.2})
st(steelL, {{487, 556}, {489, 572}}, {0.45, 0.2}, 1.4)
-- the connector plugged into the terminal, glowing at the seam
st(pile{{"bone black",1},{"lead white",0.6}}, {{484, 566}, {498, 566}}, {0.8, 0.8}, 5)
st(pile{{"cadmium yellow",1},{"lead white",1.5}}, {{497, 562}, {497, 570}}, {0.6, 0.6}, 1.6)
-- her hand: shadow side, finger divisions, a light on the knuckles
st(skinS, {{560, 582}, {546, 584}, {532, 580}, {518, 580}}, {0.5, 0.3})
st(skinS, {{548, 571}, {526, 574}}, {0.35, 0.15}, 1.1)
st(skinS, {{546, 576}, {522, 578}}, {0.35, 0.15}, 1.1)
st(pile{{"lead white",3},{"yellow ochre",0.1}}, {{556, 566}, {540, 564}, {526, 567}}, {0.4, 0.2}, 1.2)
-- the patterns interlock where they meet: his oblongs into her sleeve, her discs into his
local crim = pile{{"cadmium red",1},{"rose madder",0.7},{"Mars red",0.2}}
local gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}}
local blue = pile{{"cerulean blue",1},{"lead white",1},{"cobalt blue",0.3}}
for i = 1, 14 do
  local x, y = rand(500, 590), rand(440, 560)
  if (ARMR + HER):at(x, y) > 0.5 and HANDR:at(x, y) < 0.5 then local b = brush{kind="flat", width=rand(6, 10)}; b:reload((math.random() < 0.5) and crim or blk, 0.85); b:stroke({{x, y}, {x, y + rand(12, 24)}}, {pressure={0.8, 0.8}, orient="across", clip=ARMR + HER}) end
end
for i = 1, 14 do
  local x, y = rand(400, 470), rand(380, 540)
  if (ARMH + HIM):at(x, y) > 0.5 and GAUNT:at(x, y) < 0.5 then local b = brush{kind="round", width=rand(10, 18), point=0.05}; b:reload((math.random() < 0.5) and gold or blue, 0.85); b:touch(x, y, {pressure=0.75, clip=ARMH + HIM}) end
end
-- oblongs and discs on the sleeves themselves
for i = 1, 22 do local t = rand(0, 1); local x, y = lerp(418, 456, t), lerp(405, 540, t); local b = brush{kind="flat", width=rand(7, 12)}; b:reload(({gold, crim, pile{{"lead white",2},{"bone black",0.35}}})[math.random(1, 3)], 0.85); b:stroke({{x + rand(-10, 10), y}, {x + rand(-10, 10), y + rand(10, 20)}}, {pressure={0.8, 0.8}, orient="across", clip=ARMH}) end
for i = 1, 16 do local t = rand(0, 1); local x, y = lerp(598, 548, t), lerp(435, 560, t); local b = brush{kind="round", width=rand(8, 14), point=0.05}; b:reload((math.random() < 0.6) and gold or blue, 0.85); b:touch(x + rand(-8, 8), y, {pressure=0.75, clip=ARMR}) end

--@ chunk 4
print(wait(2*1440))
local blk = pile{{"bone black",2},{"ultramarine blue",0.2}}
local steel = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.45}}
local steelM = pile{{"bone black",0.8},{"ultramarine ash",0.8},{"lead white",0.9}}
local steelL = pile{{"lead white",2.2},{"ultramarine ash",0.4},{"bone black",0.2}}
local gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}}
local skin = pile{{"lead white",2.5},{"yellow ochre",0.25},{"rose madder",0.12}}
local skinS = pile{{"lead white",1.4},{"yellow ochre",0.4},{"rose madder",0.2},{"cerulean blue",0.12}}
local skinL = pile{{"lead white",3},{"yellow ochre",0.1}}
-- the terminal: a dark plate in a gold frame, a lit port
TERM2 = rect(474, 528, 48, 82)
work(TERM2:grow(4) - TERM2, {hand="detail", tool="round 1.6", pile=gold, coverage=4.5, fill=true, load=1})
work(TERM2, {hand="detail", tool="round 2", pile=blk, coverage=4.5, fill=true, load=1})
work(rect(492, 560, 12, 18), {hand="detail", tool="round 1.2", pile=pile{{"cadmium yellow",1},{"lead white",1.5}}, coverage=4.5, fill=true, load=1})
-- the gauntlet coming out of his sleeve, fist closed on the plug
local fist = poly({{430, 548}, {452, 540}, {474, 544}, {482, 558}, {480, 580}, {464, 590}, {440, 588}, {428, 572}}, true)
work(fist, {hand="detail", tool="round 1.6", pile=steel, coverage=4.5, fill=true, load=1})
-- her hand reaching from the right, index finger extended toward the port
local hand = poly({{586, 556}, {570, 552}, {552, 556}, {536, 562}, {520, 566}, {514, 570}, {520, 574}, {538, 574}, {552, 580}, {570, 588}, {588, 586}}, true)
work(hand, {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
print(wait(4*1440))
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 1.6, point=0.7}; b:reload(p, 0.75); b:stroke(pts, {pressure=pr or {0.5, 0.4}, ramps={0.1, 0.3}}) end
-- the plug in the port
st(steelM, {{478, 569}, {494, 569}}, {0.8, 0.8}, 6)
st(steelL, {{478, 566.5}, {494, 566.5}}, {0.4, 0.4}, 1.2)
-- gauntlet: knuckle plates, finger segments wrapped round the plug, cuff, light from above left
for _, y in ipairs({556, 565, 574}) do st(blk, {{456, y - 1}, {478, y}}, {0.5, 0.5}, 1.3) end
st(steelL, {{436, 550}, {452, 543}, {470, 546}}, {0.6, 0.3}, 2)
st(steelM, {{458, 551}, {476, 553}}, {0.45, 0.3}, 1.6)
st(steelM, {{460, 560}, {478, 562}}, {0.4, 0.3}, 1.6)
st(steelM, {{460, 569}, {477, 571}}, {0.35, 0.25}, 1.6)
st(blk, {{432, 546}, {428, 590}}, {0.7, 0.7}, 2.4)
st(pile{{"cadmium red",1},{"rose madder",0.5}}, {{424, 548}, {422, 588}}, {0.7, 0.7}, 3)
-- her hand: shadowed underside, finger divisions, light along the top, nail of the reaching finger
st(skinS, {{586, 584}, {568, 586}, {550, 578}, {534, 574}, {520, 573}}, {0.55, 0.3}, 1.8)
st(skinS, {{560, 568}, {540, 569}}, {0.35, 0.15}, 1.1)
st(skinS, {{560, 574}, {542, 574}}, {0.35, 0.15}, 1.1)
st(skinL, {{580, 556}, {562, 554}, {542, 560}, {522, 566}}, {0.45, 0.2}, 1.4)
st(pile{{"rose madder",0.4},{"lead white",2}}, {{517, 568}, {514, 570}}, {0.4, 0.3}, 1.2)
-- her sleeve's gold cuff at the wrist
st(gold, {{592, 552}, {594, 590}}, {0.8, 0.8}, 5)

--@ chunk 5
print(wait(3*1440))
local gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}}
local blk = pile{{"bone black",2},{"ultramarine blue",0.2}}
local steel = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"lead white",0.45}}
local steelM = pile{{"bone black",0.8},{"ultramarine ash",0.8},{"lead white",0.9}}
local steelL = pile{{"lead white",2.2},{"ultramarine ash",0.4},{"bone black",0.2}}
local skin = pile{{"lead white",2.5},{"yellow ochre",0.25},{"rose madder",0.12}}
local skinS = pile{{"lead white",1.4},{"yellow ochre",0.4},{"rose madder",0.2},{"cerulean blue",0.12}}
local skinL = pile{{"lead white",3},{"yellow ochre",0.1}}
local gnd = pile{{"Indian yellow",1},{"yellow ochre",1},{"lead white",0.6},{"cadmium yellow",0.2}}
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 1.6, point=0.7}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.5}, ramps={0.08, 0.25}}) end
-- clear the mitten-like hand back to gold, then fingers one by one
work(poly({{510, 552}, {560, 548}, {560, 592}, {510, 590}}) - TERM2:grow(4), {hand="detail", tool="round 2", pile=gnd, coverage=4.5, fill=true, load=1})
print(wait(2*1440))
local fingers = {
  {{{570, 562}, {552, 562}, {536, 564}, {524, 566}}, 7.0},   -- index, reaching
  {{{570, 568}, {556, 571}, {546, 576}, {542, 581}}, 6.6},   -- middle, curled
  {{{572, 574}, {562, 579}, {556, 585}}, 6.2},               -- ring
  {{{574, 580}, {568, 586}, {566, 590}}, 5.2},               -- little
  {{{580, 556}, {568, 552}, {558, 552}}, 6.4},               -- thumb above
}
for _, f in ipairs(fingers) do st(skin, f[1], {0.85, 0.65}, f[2]) end
work(ellipse(582, 570, 14, 16), {hand="detail", tool="round 1.6", pile=skin, coverage=4.5, fill=true, load=1})
print(wait(3*1440))
for _, f in ipairs(fingers) do
  local q = {} for i, p in ipairs(f[1]) do q[i] = {p[1], p[2] + f[2] * 0.3} end
  st(skinS, q, {0.45, 0.3}, f[2] * 0.35)
  local h = {} for i, p in ipairs(f[1]) do h[i] = {p[1], p[2] - f[2] * 0.3} end
  st(skinL, h, {0.35, 0.15}, f[2] * 0.25)
end
st(pile{{"rose madder",0.4},{"lead white",2}}, {{526, 565.5}, {524, 566.5}}, {0.5, 0.4}, 1.6)
st(skinS, {{592, 574}, {586, 586}, {576, 592}}, {0.5, 0.3}, 2.4)
-- the gauntlet: segmented fingers wrapped round the plug, thumb plate over the top
local fy = {558, 565, 572, 579}
for i, y in ipairs(fy) do
  st(steel, {{452, y}, {466, y + 0.5}, {476, y + 1.5}}, {0.85, 0.75}, 6.4)
end
print(wait(2*1440))
for i, y in ipairs(fy) do
  st(steelL, {{454, y - 2.2}, {466, y - 1.8}, {474, y - 0.6}}, {0.4, 0.2}, 1.2)
  st(blk, {{453, y + 3.2}, {476, y + 4.5}}, {0.45, 0.45}, 1)
  st(blk, {{464, y - 3}, {464, y + 3}}, {0.4, 0.4}, 0.9)
end
st(steelM, {{440, 552}, {458, 548}, {472, 552}}, {0.8, 0.5}, 5)
st(steelL, {{442, 549.5}, {458, 545.5}, {470, 549}}, {0.45, 0.2}, 1.4)

--@ chunk 6
local skin = pile{{"lead white",2.5},{"yellow ochre",0.25},{"rose madder",0.12}}
local skinS = pile{{"lead white",1.4},{"yellow ochre",0.4},{"rose madder",0.2},{"cerulean blue",0.12}}
local skinL = pile{{"lead white",3},{"yellow ochre",0.1}}
local blush = pile{{"lead white",2},{"rose madder",0.4},{"cadmium red",0.1}}
local ink = pile{{"bone brown",1},{"bone black",0.8}}
local lip = pile{{"cadmium red",1},{"rose madder",0.6},{"lead white",0.3}}
local gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}}
local blue = pile{{"cerulean blue",1},{"lead white",1},{"cobalt blue",0.3}}
local blk = pile{{"bone black",2},{"ultramarine blue",0.2}}
local steelL = pile{{"lead white",2.2},{"ultramarine ash",0.4},{"bone black",0.2}}
local function st(p, pts, pr, w) local b = brush{kind="round", width=w or 1.6, point=0.7}; b:reload(p, 0.8); b:stroke(pts, {pressure=pr or {0.6, 0.5}, ramps={0.1, 0.3}}) end
-- her face: turned a little toward him, eyes lowered and closed, as Klimt's women
local fx, fy = 668, 290
st(skinS, {{fx - 30, fy - 18}, {fx - 33, fy + 6}, {fx - 26, fy + 30}, {fx - 12, fy + 44}}, {0.55, 0.35}, 7)
st(skinL, {{fx + 8, fy - 30}, {fx + 16, fy - 6}, {fx + 14, fy + 18}}, {0.45, 0.2}, 8)
st(blush, {{fx - 20, fy + 12}, {fx - 12, fy + 16}}, {0.35, 0.2}, 7)
st(blush, {{fx + 10, fy + 12}, {fx + 18, fy + 13}}, {0.3, 0.15}, 6)
st(ink, {{fx - 22, fy - 4}, {fx - 15, fy - 1}, {fx - 7, fy - 2}}, {0.45, 0.2}, 1.3)
st(ink, {{fx + 5, fy - 2}, {fx + 12, fy - 1}, {fx + 19, fy - 4}}, {0.45, 0.2}, 1.3)
st(ink, {{fx - 22, fy - 13}, {fx - 13, fy - 16}, {fx - 6, fy - 14}}, {0.35, 0.1}, 1.1)
st(ink, {{fx + 4, fy - 14}, {fx + 12, fy - 16}, {fx + 20, fy - 13}}, {0.35, 0.1}, 1.1)
st(skinS, {{fx - 1, fy - 6}, {fx - 3, fy + 10}, {fx + 1, fy + 14}}, {0.4, 0.3}, 1.6)
st(lip, {{fx - 8, fy + 25}, {fx - 2, fy + 23}, {fx + 2, fy + 24}, {fx + 8, fy + 25}}, {0.6, 0.4}, 3)
st(skinS, {{fx - 6, fy + 28.5}, {fx + 6, fy + 28.5}}, {0.3, 0.2}, 1.2)
-- a gold diadem in her hair, set with blue
st(gold, {{fx - 34, fy - 34}, {fx - 14, fy - 48}, {fx + 12, fy - 50}, {fx + 34, fy - 38}}, {0.8, 0.8}, 5)
for k = 0, 6 do local t = k / 6; local b = brush{kind="round", width=5, point=0.05}; b:reload(blue, 0.8); b:touch(lerp(fx - 30, fx + 30, t), fy - 41 - 9 * math.sin(math.pi * t), {pressure=0.7}) end
-- his helmet: a dark visor with a pale slit, crowned with gold oblongs
st(blk, {{288, 200}, {368, 196}}, {0.8, 0.8}, 12)
st(steelL, {{298, 198}, {360, 195}}, {0.6, 0.6}, 2)
for x = 290, 365, 12 do local b = brush{kind="flat", width=7}; b:reload(gold, 0.85); b:stroke({{x, 140 + math.abs(x - 330) * 0.3}, {x, 160 + math.abs(x - 330) * 0.3}}, {pressure={0.8, 0.8}, orient="across"}) end
-- flowers at their feet, as in The Kiss
local fl = {pile{{"cadmium red",1},{"rose madder",0.5}}, blue, pile{{"lead white",2.5}}, pile{{"cobalt violet",1},{"lead white",1}}}
for i = 1, 70 do
  local x, y = rand(20, 980), rand(1050, 1105)
  local b = brush{kind="round", width=rand(6, 11), point=0.05}
  b:reload(fl[math.random(1, 4)], 0.85); b:touch(x, y, {pressure=0.75})
  local c = brush{kind="round", width=3, point=0.05}; c:reload(gold, 0.8); c:touch(x, y, {pressure=0.6})
end

--@ chunk 7
print(wait(3*1440))
local blk = pile{{"bone black",2},{"ultramarine blue",0.2}}
local gold = pile{{"Indian yellow",1},{"yellow ochre",0.8},{"lead white",0.5},{"cadmium yellow",0.3}}
local dgold = pile{{"raw sienna",1},{"yellow ochre",0.8},{"burnt sienna",0.2}}
local hairTop = HAIR * rect(600, 200, 170, 60) - FACE:grow(1) - ellipse(668, 248, 40, 12)
work(hairTop, {hand="detail", tool="round 2", pile=blk, coverage=4.5, fill=true, load=1})
-- a gold contour round both robes, as Klimt's figures are edged
local function edgeLine(m, w)
  local e = m:grow(w) - m
  work(e - TERM2:grow(5), {hand="detail", tool="round 2", pile=gold, coverage=4.5, fill=true, load=1})
end
edgeLine(HIM, 3.5)
edgeLine(HER, 3.5)
-- gold-leaf tooth on the ground: sparse darker flecks
local outside = rect(0, 0, 1000, 1045) - HIM:grow(6) - HER:grow(6) - TERM2:grow(6) - rect(400, 520, 220, 90)
stipple(outside, {pile=dgold, width=2.2, coverage=0.25, cluster={0.5, 20}, pressure={0.3, 0.6}})
