-- easel session "witnesses": a painting replayed chunk by chunk.
-- Each "--@ chunk" line starts one chunk as it was run at the easel.
--@ box sargent
--@ engine 2

--@ chunk 1
-- a tiny stroke font: each glyph is a list of polylines in a box 0..0.6 wide, 0..1 tall (y down)
FONT = {
 A={{{0,1},{0.3,0},{0.6,1}},{{0.1,0.65},{0.5,0.65}}},
 B={{{0,0},{0,1},{0.45,1},{0.6,0.85},{0.6,0.65},{0.45,0.5},{0,0.5}},{{0,0},{0.4,0},{0.55,0.12},{0.55,0.38},{0.4,0.5}}},
 C={{{0.6,0.1},{0.45,0},{0.15,0},{0,0.15},{0,0.85},{0.15,1},{0.45,1},{0.6,0.9}}},
 D={{{0,0},{0,1},{0.4,1},{0.6,0.8},{0.6,0.2},{0.4,0},{0,0}}},
 E={{{0.6,0},{0,0},{0,1},{0.6,1}},{{0,0.5},{0.45,0.5}}},
 F={{{0.6,0},{0,0},{0,1}},{{0,0.5},{0.45,0.5}}},
 G={{{0.6,0.1},{0.45,0},{0.15,0},{0,0.15},{0,0.85},{0.15,1},{0.45,1},{0.6,0.85},{0.6,0.55},{0.35,0.55}}},
 H={{{0,0},{0,1}},{{0.6,0},{0.6,1}},{{0,0.5},{0.6,0.5}}},
 I={{{0.3,0},{0.3,1}},{{0.1,0},{0.5,0}},{{0.1,1},{0.5,1}}},
 K={{{0,0},{0,1}},{{0.6,0},{0,0.6}},{{0.2,0.45},{0.6,1}}},
 L={{{0,0},{0,1},{0.6,1}}},
 M={{{0,1},{0,0},{0.3,0.5},{0.6,0},{0.6,1}}},
 N={{{0,1},{0,0},{0.6,1},{0.6,0}}},
 O={{{0.15,0},{0.45,0},{0.6,0.15},{0.6,0.85},{0.45,1},{0.15,1},{0,0.85},{0,0.15},{0.15,0}}},
 P={{{0,1},{0,0},{0.45,0},{0.6,0.12},{0.6,0.38},{0.45,0.5},{0,0.5}}},
 R={{{0,1},{0,0},{0.45,0},{0.6,0.12},{0.6,0.38},{0.45,0.5},{0,0.5}},{{0.3,0.5},{0.6,1}}},
 S={{{0.6,0.1},{0.45,0},{0.15,0},{0,0.12},{0,0.38},{0.15,0.5},{0.45,0.5},{0.6,0.62},{0.6,0.88},{0.45,1},{0.15,1},{0,0.9}}},
 T={{{0,0},{0.6,0}},{{0.3,0},{0.3,1}}},
 U={{{0,0},{0,0.85},{0.15,1},{0.45,1},{0.6,0.85},{0.6,0}}},
 V={{{0,0},{0.3,1},{0.6,0}}},
 W={{{0,0},{0.12,1},{0.3,0.4},{0.48,1},{0.6,0}}},
 Y={{{0,0},{0.3,0.5},{0.6,0}},{{0.3,0.5},{0.3,1}}},
 ["{"]={{{0.45,0},{0.3,0.05},{0.25,0.4},{0.1,0.5},{0.25,0.6},{0.3,0.95},{0.45,1}}},
 ["}"]={{{0.15,0},{0.3,0.05},{0.35,0.4},{0.5,0.5},{0.35,0.6},{0.3,0.95},{0.15,1}}},
 ["<"]={{{0.55,0.15},{0.05,0.5},{0.55,0.85}}},
 [">"]={{{0.05,0.15},{0.55,0.5},{0.05,0.85}}},
 ["/"]={{{0.55,0},{0.05,1}}},
 ["-"]={{{0.1,0.5},{0.5,0.5}}},
 ["0"]={{{0.15,0},{0.45,0},{0.6,0.15},{0.6,0.85},{0.45,1},{0.15,1},{0,0.85},{0,0.15},{0.15,0}},{{0.55,0.1},{0.05,0.9}}},
 ["1"]={{{0.1,0.2},{0.3,0},{0.3,1}},{{0.1,1},{0.5,1}}},
}
-- dots are touches
DOTS = {["."]={{0.3,0.95}}, [":"]={{0.3,0.3},{0.3,0.9}}}

-- write text with brush b, start x,y (top-left), letter height h; returns end x
function write(b, text, x, y, h, opt)
  opt = opt or {}
  local adv = opt.adv or 0.85
  local pr = opt.pressure or 0.5
  local dip = opt.dip
  local ang = opt.slant or 0
  for i = 1, #text do
    local ch = text:sub(i, i)
    local g = FONT[ch]
    if dip and (i % (opt.every or 3) == 1) then b:load(dip, opt.load or 0.7) end
    if g then
      for _, pl in ipairs(g) do
        local pts = {}
        for _, q in ipairs(pl) do
          pts[#pts+1] = {x + q[1]*h + ang*(1-q[2])*h, y + q[2]*h}
        end
        b:stroke(pts, {pressure={pr, pr}, ramps={0.05, 0.05}, shake=opt.shake or 0.2})
      end
    elseif DOTS[ch] then
      for _, q in ipairs(DOTS[ch]) do
        b:touch(x + q[1]*h, y + q[2]*h, {pressure=pr*1.2})
      end
    end
    x = x + adv*h
  end
  return x
end
FONT["2"]={{{0,0.15},{0.15,0},{0.45,0},{0.6,0.15},{0.6,0.4},{0,1},{0.6,1}}}
FONT["3"]={{{0,0.1},{0.15,0},{0.45,0},{0.6,0.12},{0.6,0.38},{0.45,0.5},{0.2,0.5}},{{0.45,0.5},{0.6,0.62},{0.6,0.88},{0.45,1},{0.15,1},{0,0.9}}}
FONT["4"]={{{0.45,1},{0.45,0},{0,0.7},{0.6,0.7}}}
FONT["5"]={{{0.6,0},{0.05,0},{0,0.45},{0.45,0.42},{0.6,0.6},{0.6,0.85},{0.45,1},{0.1,1},{0,0.9}}}
FONT["6"]={{{0.55,0.05},{0.3,0},{0.1,0.1},{0,0.4},{0,0.85},{0.15,1},{0.45,1},{0.6,0.85},{0.6,0.6},{0.45,0.48},{0.15,0.48},{0,0.6}}}
FONT["7"]={{{0,0},{0.6,0},{0.2,1}}}
FONT["8"]={{{0.3,0.5},{0.05,0.38},{0.05,0.12},{0.2,0},{0.4,0},{0.55,0.12},{0.55,0.38},{0.3,0.5},{0,0.65},{0,0.88},{0.15,1},{0.45,1},{0.6,0.88},{0.6,0.65},{0.3,0.5}}}
FONT["9"]={{{0.6,0.4},{0.45,0.52},{0.15,0.52},{0,0.4},{0,0.15},{0.15,0},{0.45,0},{0.6,0.15},{0.6,0.6},{0.5,0.9},{0.3,1},{0.05,0.95}}}
FONT["%"]={{{0.55,0},{0.05,1}}}
FONT["["]={{{0.45,0},{0.2,0},{0.2,1},{0.45,1}}}
FONT["]"]={{{0.15,0},{0.4,0},{0.4,1},{0.15,1}}}
FONT["X"]={{{0,0},{0.6,1}},{{0.6,0},{0,1}}}
FONT["M"]={{{0,1},{0,0},{0.3,0.5},{0.6,0},{0.6,1}}}
DOTS["%"]={{0.1,0.15},{0.5,0.85}}

--@ chunk 2
canvas{size=600, aspect=1.5, linen={18,16}, seed=7731, ground={{pile={{"burnt sienna",1},{"ultramarine blue",1},{"lead white",0.6},{"raw sienna",0.3}}, um=120, apply="knife", texture=0.25}}}
function hz(x) return 455 - 50*math.exp(-((x-470)/330)^2) + 0.02*(x-470) end
HULL = below(function(x) return hz(x) end)
SKY = -HULL
local S1 = pile{{"ultramarine blue",2},{"burnt sienna",1},{"bone black",0.3}}
local S2 = pile{{"ultramarine blue",1.5},{"burnt sienna",1},{"rose madder",0.3},{"bone black",0.2}}
local S3 = pile{{"ultramarine blue",1},{"burnt sienna",1.2},{"Mars orange",0.15}}
local function D(x, y) return math.sqrt((x+150)^2 + (y-250)^2) end
work(SKY, {hand="broad", pile=S1, coverage=3, fill=true, clip=true, angle=0.15})
work(SKY * mask(function(x,y) return 1 - smoothstep(380, 600, D(x,y)) end), {hand="body", pile=S2, coverage=2.5, fill=true, clip=SKY, angle=0.3, threshold=0.4})
work(SKY * mask(function(x,y) return 1 - smoothstep(200, 380, D(x,y)) end), {hand="body", pile=S3, coverage=2.5, fill=true, clip=SKY, angle=0.3, threshold=0.4})
-- hull base: dark bronze, warmer toward the sun side
local B1 = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.6},{"ultramarine blue",0.3}}
local B2 = pile{{"raw sienna",1},{"burnt sienna",1},{"yellow ochre",0.6},{"bone black",0.4},{"lead white",0.2}}
work(HULL, {hand="broad", pile=B1, coverage=3, fill=true, clip=true, angle=0.05})
work(HULL * mask(function(x,y) return (1 - smoothstep(150, 520, x)) * (1 - smoothstep(0, 60, y - hz(x))) end), {hand="body", pile=B2, coverage=2.5, fill=true, clip=HULL, angle=0.05, threshold=0.35})

--@ chunk 3
print(wait(2*24*60))
local K1 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local K2 = pile{{"bone black",1.6},{"ultramarine blue",0.8},{"burnt sienna",0.6},{"rose madder",0.3}}
work(SKY, {hand="body", pile=K1, coverage=4.5, fill=true, clip=true, angle=0.15, tool="filbert 10", length={40,120}, load=1, pressure={0.7,0.95}})
local warm = SKY * mask(function(x,y) return 1 - smoothstep(150, 520, math.sqrt((x+150)^2 + (y-260)^2)) end)
work(warm, {hand="scumble", pile=K2, coverage=2, clip=SKY, tool="filbert 8", load=0.6, threshold=0.25})

--@ chunk 4
print(wait(24*60))
-- the solar sail: a vast sunlit membrane over the upper left, billowing toward us
SAIL = poly({{-10,-10},{440,-10},{400,90},{340,215},{200,270},{60,318},{-10,335}}, true)
local G1 = pile{{"lead white",3},{"yellow ochre",0.6},{"cadmium yellow",0.4}}
local G2 = pile{{"lead white",2},{"yellow ochre",1},{"Mars orange",0.3},{"raw sienna",0.2}}
local G3 = pile{{"yellow ochre",1},{"Mars orange",0.6},{"burnt sienna",0.4},{"lead white",0.8}}
local function d(x,y) return math.sqrt((x+60)^2 + (y+40)^2) end
work(SAIL * mask(function(x,y) return smoothstep(300, 360, d(x,y)) end), {hand="body", pile=G3, coverage=3.5, fill=true, clip=SAIL, angle=-0.6, tool="filbert 8", length={30,80}, load=1})
work(SAIL * mask(function(x,y) local v = d(x,y); return smoothstep(170, 230, v) * (1 - smoothstep(330, 380, v)) end), {hand="body", pile=G2, coverage=3.5, fill=true, clip=SAIL, angle=-0.6, tool="filbert 8", length={30,80}, load=1, threshold=0.35})
work(SAIL * mask(function(x,y) return 1 - smoothstep(200, 260, d(x,y)) end), {hand="body", pile=G1, coverage=3.5, fill=true, clip=SAIL, angle=-0.6, tool="filbert 8", length={30,80}, load=1, threshold=0.35})

--@ chunk 5
print(wait(5*24*60))
print(drying(150,100), drying(700,200))
local G1 = pile{{"lead white",3},{"yellow ochre",0.5},{"cadmium yellow",0.4}}
local G2 = pile{{"lead white",2.2},{"yellow ochre",1},{"Mars orange",0.25}}
local G3 = pile{{"lead white",1.2},{"yellow ochre",1},{"Mars orange",0.5},{"burnt sienna",0.3}}
local function d(x,y) return math.sqrt((x+60)^2 + (y+40)^2) end
work(SAIL * mask(function(x,y) return smoothstep(300, 360, d(x,y)) end), {hand="body", pile=G3, coverage=4.5, fill=true, clip=SAIL, angle=-0.5, tool="filbert 8", length={40,100}, load=1, pressure={0.7,0.95}})
work(SAIL * mask(function(x,y) local v = d(x,y); return smoothstep(170, 230, v) * (1 - smoothstep(330, 380, v)) end), {hand="body", pile=G2, coverage=4.5, fill=true, clip=SAIL, angle=-0.5, tool="filbert 8", length={40,100}, load=1, pressure={0.7,0.95}, threshold=0.35})
work(SAIL * mask(function(x,y) return 1 - smoothstep(200, 260, d(x,y)) end), {hand="body", pile=G1, coverage=4.5, fill=true, clip=SAIL, angle=-0.5, tool="filbert 8", length={40,100}, load=1, pressure={0.7,0.95}, threshold=0.35})

--@ chunk 6
-- cover the old warm disc under the sail
local K1 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local under = (SKY - SAIL) * rect(-10, 150, 320, 330)
work(under, {hand="body", pile=K1, coverage=4.5, fill=true, clip=under, angle=0.15, tool="filbert 8", length={30,80}, load=1, pressure={0.7,0.95}})
-- hull: bands following the curve, warm and lit near the horizon, falling dark toward us
local H1 = pile{{"bone black",1.6},{"burnt sienna",1},{"ultramarine blue",0.5}}
local H2 = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.6},{"ultramarine blue",0.2}}
local H3 = pile{{"raw sienna",1},{"burnt sienna",0.8},{"yellow ochre",0.5},{"bone black",0.3},{"lead white",0.15}}
local function dy(x,y) return y - hz(x) end
work(HULL * mask(function(x,y) return smoothstep(70, 130, dy(x,y)) end), {hand="body", pile=H1, coverage=4, fill=true, clip=HULL, angle=0.03, tool="filbert 8", length={30,90}, load=1})
work(HULL * mask(function(x,y) local v = dy(x,y); return smoothstep(18, 40, v) * (1 - smoothstep(90, 130, v)) end), {hand="body", pile=H2, coverage=4, fill=true, clip=HULL, angle=0.03, tool="filbert 8", length={30,90}, load=1, threshold=0.35})
work(HULL * mask(function(x,y) return 1 - smoothstep(20, 45, dy(x,y)) end), {hand="body", pile=H3, coverage=4, fill=true, clip=HULL, angle=0.03, tool="filbert 6", length={30,90}, load=1, threshold=0.35})

--@ chunk 7
print(wait(3*24*60))
print(drying(300,470), drying(500,600))
local DK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
local LH = pile{{"lead white",2},{"yellow ochre",0.8},{"Mars orange",0.3}}
local LM2 = pile{{"yellow ochre",1},{"burnt sienna",0.6},{"lead white",0.6},{"Mars orange",0.2}}
local VG = pile{{"viridian",1},{"cerulean blue",0.6},{"lead white",1.2},{"yellow ochre",0.4}}
local rows = {6, 14, 24, 37, 54, 76, 104, 140, 185, 240}
local dk = brush{kind="round", width=2.2, point=0.5}
local lt = brush{kind="round", width=1.8, point=0.8}
for ri, off in ipairs(rows) do
  local wlip = 6 + off * 0.42
  local x = -10 + rand(0, wlip)
  while x < 1010 do
    local w = wlip * rand(0.8, 1.25)
    local y0 = hz(x + w/2) + off + rand(-1, 1) * (1 + off*0.03)
    local sag = w * 0.22
    local pts = {}
    for k = 0, 6 do local t = k/6; pts[#pts+1] = {x + w*t, y0 + sag*math.sin(math.pi*t)} end
    dk:load(DK, 0.85)
    dk:stroke(pts, {pressure={0.35 + off*0.002, 0.35 + off*0.002}, ramps={0.2, 0.2}})
    local lp = {}
    for k = 1, 5 do local t = k/6; lp[#lp+1] = {x + w*t, y0 - 1.6 - off*0.012 + sag*math.sin(math.pi*t)} end
    local sun = 1 - clamp(x / 900, 0, 1)
    local near = 1 - clamp(off / 200, 0, 1)
    local p = (sun * 0.6 + near * 0.6 > 0.7) and LH or LM2
    lt:load(p, 0.35 + 0.45 * sun * near)
    lt:stroke(lp, {pressure={0.25, 0.25 + 0.2*near}, ramps={0.3, 0.3}})
    if math.random() < 0.08 and off > 20 then
      lt:load(VG, 0.4); lt:stroke({{x + w*0.3, y0 + sag*0.8 + 2}, {x + w*0.6, y0 + sag*0.8 + 3}}, {pressure={0.4,0.2}})
    end
    x = x + w * rand(0.9, 1.15)
  end
end

--@ chunk 8
-- rigging from the sail's free edge down to a mast foot on the hull
local CB = pile{{"lead white",1.5},{"yellow ochre",0.6},{"raw sienna",0.3}}
local CBd = pile{{"burnt sienna",1},{"bone black",0.6},{"yellow ochre",0.4}}
local foot = {252, hz(252) - 1}
local r = brush{kind="round", width=1.3, point=0.9}
for _, p in ipairs({{405,80},{372,160},{338,215},{270,245},{200,270},{120,298},{55,318}}) do
  r:load(CB, 0.7)
  r:stroke({p, {lerp(p[1],foot[1],0.5), lerp(p[2],foot[2],0.5) + 3}, foot}, {pressure={0.35, 0.5}, ramps={0.1, 0.1}})
end
local m = brush{kind="round", width=3, point=0.5}
m:load(CBd, 0.9); m:stroke({foot, {250, 230}}, {pressure={0.6, 0.4}})
m:load(CB, 0.7); m:stroke({{249, foot[2]}, {249, 232}}, {pressure={0.2, 0.15}})
-- stars, sparse; none near the sail's glow
local st = brush{kind="round", width=1.4, point=0.3}
local WS = pile{{"zinc white",3},{"lead white",1}}
for i = 1, 70 do
  local x, y = rand(330, 995), rand(5, 400)
  if SKY:at(x, y) > 0.9 and SAIL:at(x, y) < 0.1 and y < hz(x) - 15 then
    st:load(WS, rand(0.3, 0.7)); st:touch(x, y, {pressure=rand(0.15, 0.45)})
  end
end
-- the factions' fleets, far off, looking up: two loose clusters of tiny lights
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.6},{"lead white",1}}
local CYn = pile{{"zinc white",2},{"cerulean blue",1}}
local f = brush{kind="round", width=2, point=0.3}
for i = 1, 16 do
  local x, y = randn(770, 40), randn(250, 22)
  f:load(AM, 0.8); f:touch(x, y, {pressure=rand(0.25, 0.6)})
end
for i = 1, 16 do
  local x, y = randn(910, 35), randn(330, 25)
  f:load(CYn, 0.8); f:touch(x, y, {pressure=rand(0.25, 0.6)})
end

--@ chunk 9
print(wait(2*24*60))
-- the Ark, lying on the hull at their feet: a pale bone capsule, lit from the left
ARK = poly({{585,462},{600,452},{690,450},{708,458},{712,472},{700,486},{600,490},{584,480}}, true)
local A1 = pile{{"lead white",2.5},{"yellow ochre",0.7},{"raw sienna",0.25}}
local A2 = pile{{"lead white",1.2},{"yellow ochre",0.6},{"burnt sienna",0.3},{"ultramarine ash",0.5}}
local A3 = pile{{"bone black",1},{"burnt sienna",0.8},{"ultramarine ash",0.6},{"lead white",0.3}}
work(ARK, {hand="body", pile=A2, coverage=4, fill=true, clip=true, angle=0, tool="filbert 4", length={10,30}, load=1})
work(ARK * rect(570, 440, 150, 18), {hand="body", pile=A1, coverage=3, clip=ARK, angle=0, tool="filbert 3", length={8,25}, edge="soft"})
work(ARK * rect(570, 478, 150, 20), {hand="body", pile=A3, coverage=3, clip=ARK, angle=0, tool="filbert 3", length={8,25}, edge="soft"})
-- its shadow on the hull, to the right
local sh = poly({{700,486},{712,474},{760,478},{790,488},{740,494},{690,492}}, true)
work(sh, {hand="body", pile=pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}, coverage=3, fill=true, clip=true, angle=0, tool="filbert 4"})
-- the Commando: a pilgrim frame seen from behind, cloak, helmet, staff; dark against the sky
FIG = poly({
 {512,310},{526,306},{535,314},{536,330},{532,338},          -- helmet
 {552,346},{560,360},{561,380},{566,402},{562,408},{556,392}, -- right shoulder, arm down to the lantern hand
 {558,440},{548,452},{544,478},{549,486},{534,487},{534,456}, -- cloak hem, right leg, boot
 {520,456},{518,486},{502,487},{506,476},{505,452},{486,442}, -- left leg, cloak
 {490,400},{484,388},{486,360},{494,347},{508,340},{506,328}
}, true)
local F1 = pile{{"bone black",2},{"burnt sienna",0.5},{"ultramarine blue",0.6}}
work(FIG, {hand="body", pile=F1, coverage=5, fill=true, clip=true, angle=math.pi/2, tool="filbert 4", length={10,30}, load=1})
-- the staff, planted
local s = brush{kind="round", width=3, point=0.3}
s:load(F1, 1); s:stroke({{478,488},{481,380},{484,282}}, {pressure={0.7,0.6}, ramps={0.02,0.05}})

--@ chunk 10
print(wait(3*24*60))
local F1 = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.3}}
work(FIG, {hand="detail", pile=F1, coverage=4, fill=true, angle=math.pi/2, tool={kind="round", width=2.4}})
print(wait(3*24*60))
-- the sun's rim along his left contour (helmet, shoulder, cloak edge)
local RIM = pile{{"lead white",2.5},{"yellow ochre",0.6},{"Mars orange",0.3}}
local r = brush{kind="round", width=2.4, point=0.8}
r:load(RIM, 0.9)
r:stroke({{530,309},{521,307},{513,311},{508,320},{508,330}}, {pressure={0.35,0.55}, ramps={0.15,0.3}})
r:load(RIM, 0.9)
r:stroke({{506,342},{496,349},{489,360},{487,380},{491,398}}, {pressure={0.5,0.35}, ramps={0.1,0.4}})
r:load(RIM, 0.7)
r:stroke({{489,404},{488,425},{489,442}}, {pressure={0.3,0.15}, ramps={0.1,0.6}})
r:load(RIM, 0.6)
r:stroke({{507,456},{506,470},{505,484}}, {pressure={0.25,0.15}, ramps={0.1,0.6}})
r:load(RIM, 0.8)
r:stroke({{482,290},{480,380},{479,480}}, {pressure={0.2,0.15}, ramps={0.1,0.3}})
-- the lantern in his right hand: the first lampstand
local LD = pile{{"bone black",1.5},{"burnt sienna",0.6}}
local LC = pile{{"lead white",3},{"cadmium yellow",1},{"chrome yellow",0.3}}
local LO = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
work(rect(559, 408, 15, 22), {hand="detail", pile=LD, coverage=4, fill=true, angle=0})
work(rect(562, 412, 9, 14), {hand="detail", pile=LO, coverage=4, fill=true, angle=0})
local t = brush{kind="round", width=5, point=0.2}
t:load(LC, 1); t:touch(566.5, 419, {pressure=0.7})
local h = brush{kind="round", width=1.4, point=0.6}
h:load(LD, 0.9); h:stroke({{566,404},{566,409}}, {pressure={0.5,0.5}})
-- warm lantern light on his cloak's right edge and on the Ark's near end
local WL = pile{{"Mars orange",1},{"cadmium yellow",0.6},{"lead white",1}}
r:load(WL, 0.6); r:stroke({{557,392},{556,410},{557,436}}, {pressure={0.3,0.15}, ramps={0.2,0.5}})
r:load(WL, 0.6); r:stroke({{587,466},{592,456},{602,452}}, {pressure={0.35,0.2}, ramps={0.2,0.5}})

--@ chunk 11
local F1 = pile{{"bone black",2},{"ultramarine blue",0.6},{"burnt sienna",0.3}}
local d = brush{kind="filbert", width=5}
for _, y in ipairs({402, 406, 410}) do d:load(F1, 0.9); d:stroke({{490,y},{556,y}}, {pressure={0.6,0.6}, clip=FIG}) end
local LC = pile{{"lead white",3},{"cadmium yellow",0.8},{"lemon chrome",0.3}}
local t = brush{kind="round", width=6, point=0.2}
t:load(LC, 1); t:touch(566.5, 418, {pressure=0.85}); t:load(LC, 1); t:touch(566.5, 421, {pressure=0.7})
-- Ratio, projected from the Ark: a small low-poly girl made of light, the second lampstand
local HL = pile{{"cobalt blue",1},{"ultramarine blue",0.6},{"zinc white",0.9},{"cerulean blue",0.3}}
local HL2 = pile{{"cobalt blue",0.8},{"zinc white",1.4},{"cerulean blue",0.5}}
local SK = pile{{"zinc white",4},{"cerulean blue",0.3},{"lead white",1}}
local SK2 = pile{{"zinc white",3},{"cerulean blue",0.7}}
local DR = pile{{"zinc white",3},{"cerulean blue",0.9},{"cobalt blue",0.2}}
local function facet(pts, p)
  work(poly(pts), {hand="detail", pile=p, coverage=5, fill=true, angle=0, tool={kind="round", width=1.4}})
end
local cx, fy = 650, 452
local function P(pts) local o = {}; for i, q in ipairs(pts) do o[i] = {cx + q[1], fy + q[2]} end; return o end
facet(P({{0,-74},{14,-69},{20,-50},{19,-30},{14,-14},{8,-20},{0,-16}}), HL)
facet(P({{0,-74},{0,-16},{-8,-20},{-14,-14},{-19,-30},{-20,-50},{-14,-69}}), HL2)
facet(P({{0,-42},{0,-14},{-9,-16},{-6,-40}}), SK)
facet(P({{0,-42},{6,-40},{9,-16},{0,-14}}), SK2)
facet(P({{0,-38},{0,-8},{-10,-8}}), DR); facet(P({{-6,-38},{0,-38},{-10,-8}}), DR)
facet(P({{0,-38},{7,-38},{10,-8},{0,-8}}), SK2)
facet(P({{-5,-8},{-1,-8},{-1,-1},{-5,-1}}), SK); facet(P({{1,-8},{5,-8},{5,-1},{1,-1}}), SK2)
facet(P({{0,-66},{13,-60},{10,-52},{4,-58},{0,-52},{-4,-58},{-10,-52},{-13,-60}}), HL)
local e = brush{kind="round", width=2, point=0.3}
e:load(HL, 0.9); e:touch(cx - 4.5, fy - 49, {pressure=0.6}); e:load(HL, 0.9); e:touch(cx + 4.5, fy - 49, {pressure=0.6})
-- emitter ring on the Ark's top and projection scanlines through her
local CY = pile{{"zinc white",2},{"cerulean blue",1.2}}
local r = brush{kind="round", width=1.3, point=0.6}
r:load(CY, 0.9); r:stroke({{634,453},{642,450},{658,450},{666,453},{658,456},{642,456},{634,453}}, {pressure={0.5,0.5}})
for _, y in ipairs({392, 404, 418, 432, 444}) do
  r:load(CY, 0.5); r:stroke({{cx-22, y}, {cx+22, y}}, {pressure={0.25,0.25}, ramps={0.2,0.2}, shake=0})
end

--@ chunk 12
print(wait(6*24*60))
print(drying(650,420), drying(566,418))
local SK = pile{{"zinc white",4},{"lead white",1.5},{"cerulean blue",0.15}}
local SK2 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.5}}
local HL = pile{{"cobalt blue",1},{"ultramarine blue",0.6},{"zinc white",0.9},{"cerulean blue",0.3}}
local function facet(pts, p)
  work(poly(pts), {hand="detail", pile=p, coverage=6, fill=true, angle=0, tool={kind="round", width=1.2}})
end
local cx, fy = 650, 452
local function P(pts) local o = {}; for i, q in ipairs(pts) do o[i] = {cx + q[1], fy + q[2]} end; return o end
facet(P({{0,-60},{0,-41},{-6,-41},{-10,-48},{-10,-56}}), SK)
facet(P({{0,-60},{10,-56},{10,-48},{6,-41},{0,-41}}), SK2)
facet(P({{0,-40},{0,-10},{-9,-10},{-5,-40}}), SK)
facet(P({{0,-40},{5,-40},{9,-10},{0,-10}}), SK2)
facet(P({{-11,-60},{0,-66},{11,-60},{10,-54},{5,-58},{0,-53},{-5,-58},{-10,-54}}), HL)
local e = brush{kind="round", width=2.2, point=0.3}
e:load(HL, 1); e:touch(cx - 4, fy - 49, {pressure=0.6}); e:load(HL, 1); e:touch(cx + 4, fy - 49, {pressure=0.6})
-- lantern core, hot
local LC = pile{{"lead white",3},{"lemon chrome",0.3},{"zinc white",1}}
work(rect(563, 413, 7, 11), {hand="detail", pile=LC, coverage=6, fill=true, angle=0, tool={kind="round", width=1.4}})

--@ chunk 13
local EY = pile{{"ultramarine blue",1},{"cobalt blue",1},{"zinc white",0.3}}
local function facet(pts, p)
  work(poly(pts), {hand="detail", pile=p, coverage=6, fill=true, angle=0, tool={kind="round", width=1}})
end
facet({{644,402},{647.5,401},{648,406},{645,407.5}}, EY)
facet({{652.5,401},{656,402},{655,407.5},{652,406}}, EY)
local w = brush{kind="round", width=1.2, point=0.3}
w:load(pile{{"zinc white",4}}, 0.9); w:touch(645.5, 402.5, {pressure=0.5}); w:load(pile{{"zinc white",4}}, 0.9); w:touch(653.5, 402.5, {pressure=0.5})
-- the fleets, stronger: drive flares and a few running lights
local AM = pile{{"cadmium yellow",1},{"Mars orange",0.5},{"lead white",1.5}}
local CYn = pile{{"zinc white",3},{"cerulean blue",1}}
local f = brush{kind="round", width=2.8, point=0.3}
for i = 1, 12 do
  local x, y = randn(770, 45), randn(240, 25)
  f:load(AM, 0.9); f:touch(x, y, {pressure=rand(0.35, 0.75)})
end
for i = 1, 12 do
  local x, y = randn(915, 35), randn(320, 25)
  f:load(CYn, 0.9); f:touch(x, y, {pressure=rand(0.35, 0.75)})
end

--@ chunk 14
print(wait(3*24*60))
-- sail: panel seams fanning from the far corner, and a bright hem where the sunlight comes through
local SM = pile{{"yellow ochre",1},{"raw sienna",0.6},{"lead white",1},{"Mars orange",0.2}}
local r = brush{kind="round", width=1.4, point=0.8}
for _, e in ipairs({{440,-5},{420,40},{385,120},{350,200},{290,235},{215,262},{140,290},{70,314}}) do
  r:load(SM, 0.7)
  r:stroke({{-10,-10}, {lerp(-10,e[1],0.5) + 6, lerp(-10,e[2],0.5) + 4}, {e[1]-4, e[2]-3}}, {pressure={0.15, 0.4}, ramps={0.3, 0.1}, clip=SAIL})
end
local HEM = pile{{"lead white",3},{"lemon chrome",0.3},{"yellow ochre",0.2}}
local h = brush{kind="round", width=2.6, point=0.7}
h:load(HEM, 0.9); h:stroke({{438,-2},{415,50},{398,95},{372,150},{340,212}}, {pressure={0.4,0.3}, ramps={0.1,0.3}, clip=SAIL:grow(1)})
h:load(HEM, 0.9); h:stroke({{338,214},{270,242},{200,268},{130,294},{60,316},{0,332}}, {pressure={0.3,0.4}, ramps={0.2,0.2}, clip=SAIL:grow(1)})
-- the two lamps light the scale lips near them: warm at his feet, cool round the Ark
local WL = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.4}}
local CL = pile{{"zinc white",3},{"cerulean blue",1}}
local lt = brush{kind="round", width=1.8, point=0.8}
local rows = {6, 14, 24, 37, 54, 76}
for _, lamp in ipairs({{566,419,WL,70},{650,430,CL,80}}) do
  for _, off in ipairs(rows) do
    local wlip = 6 + off*0.42
    for x = lamp[1] - lamp[4], lamp[1] + lamp[4], wlip*1.05 do
      local y0 = hz(x + wlip/2) + off - 1.6 - off*0.012
      local d = math.sqrt((x - lamp[1])^2 + ((y0 - lamp[2])*1.6)^2)
      if d < lamp[4] and FIG:at(x, y0) < 0.5 and ARK:at(x, y0) < 0.5 then
        local k = 1 - d/lamp[4]
        lt:load(lamp[3], 0.3 + 0.6*k)
        local sag = wlip*0.22
        lt:stroke({{x + wlip*0.2, y0 + sag*0.6}, {x + wlip*0.5, y0 + sag}, {x + wlip*0.8, y0 + sag*0.6}}, {pressure={0.2 + 0.3*k, 0.2 + 0.3*k}, ramps={0.3,0.3}})
      end
    end
  end
end
-- fleet flares
local AM = pile{{"lead white",2},{"cadmium yellow",1},{"Mars orange",0.3}}
local CYn = pile{{"zinc white",3},{"cerulean blue",0.8}}
local f = brush{kind="round", width=4, point=0.3}
for _, p in ipairs({{752,232,AM},{796,256,AM},{731,262,AM},{902,312,CYn},{936,336,CYn},{884,345,CYn}}) do
  f:load(p[3], 1); f:touch(p[1], p[2], {pressure=0.6})
  r:load(p[3], 0.6); r:stroke({{p[1]-7, p[2]}, {p[1]+7, p[2]}}, {pressure={0.05,0.05}, swell={0.2,1,0.2}})
end

--@ chunk 15
print(wait(2*24*60))
-- a worn bone cross on the pilgrim's back; lantern-warm edge on his right shoulder
local BONE = pile{{"lead white",2.5},{"yellow ochre",0.8},{"raw sienna",0.3}}
local fl = brush{kind="flat", width=3.5}
fl:load(BONE, 0.55); fl:stroke({{522,356},{522,392}}, {pressure={0.55,0.45}, orient="across"})
fl:load(BONE, 0.5); fl:stroke({{510,367},{534,367}}, {pressure={0.5,0.4}, orient="across"})
local WL = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",1.2}}
local r = brush{kind="round", width=2, point=0.8}
r:load(WL, 0.7); r:stroke({{535,334},{550,345},{558,360},{561,380}}, {pressure={0.3,0.4}, ramps={0.2,0.3}})
-- Ark: band seams, a cool readout facing her
local AD = pile{{"burnt sienna",1},{"bone black",0.8},{"ultramarine ash",0.4}}
local s = brush{kind="round", width=1.6, point=0.6}
for _, x in ipairs({612, 680}) do s:load(AD, 0.8); s:stroke({{x, 452},{x+1, 470},{x, 489}}, {pressure={0.45,0.45}, clip=ARK}) end
local CY = pile{{"zinc white",2},{"cerulean blue",1.3}}
work(rect(690, 462, 9, 5), {hand="detail", pile=CY, coverage=5, fill=true, angle=0, tool={kind="round", width=1}})
-- two small halos: warm round the lantern, cool round her
local WG = pile{{"lead white",1},{"cadmium yellow",0.4},{"Mars orange",0.3}}
local CG = pile{{"zinc white",2},{"cerulean blue",0.8}}
local function halo(cx, cy, rad, p)
  local m = (ellipse(cx, cy, rad, rad) - FIG - ARK) * SKY
  work(m, {hand="scumble", pile=p, coverage=1.2, load=0.2, pressure={0.1,0.25}, clip=m, tool="filbert 3", threshold=0.3})
end
halo(566, 410, 16, WG)
halo(650, 412, 34, CG)

--@ chunk 16
for i = 1, 6 do
  for _, h in ipairs({{566,410,18},{650,412,36}}) do
    local m = (ellipse(h[1], h[2], h[3], h[3]) - FIG - ARK)
    work(m, {hand="scumble", blender=true, coverage=2, clip=m, tool="filbert 3", seed=200+i})
  end
end

--@ chunk 17
print(wait(5*24*60))
print(drying(650,425))
local SK = pile{{"zinc white",4},{"lead white",1.5},{"cerulean blue",0.15}}
local SK2 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.5}}
local DR = pile{{"zinc white",3},{"cerulean blue",0.9},{"cobalt blue",0.2}}
local function facet(pts, p)
  work(poly(pts), {hand="detail", pile=p, coverage=6, fill=true, angle=0, tool={kind="round", width=1.2}})
end
local cx, fy = 650, 452
local function P(pts) local o = {}; for i, q in ipairs(pts) do o[i] = {cx + q[1], fy + q[2]} end; return o end
facet(P({{0,-40},{0,-10},{-9,-10},{-5,-40}}), SK)
facet(P({{0,-40},{5,-40},{9,-10},{0,-10}}), SK2)
facet(P({{-5,-10},{-1,-10},{-1,-2},{-5,-2}}), DR); facet(P({{1,-10},{5,-10},{5,-2},{1,-2}}), SK2)
local CY = pile{{"zinc white",2},{"cerulean blue",1.2}}
local r = brush{kind="round", width=1.1, point=0.6}
for _, y in ipairs({398, 412, 426, 440}) do
  r:load(CY, 0.45); r:stroke({{cx-20, y}, {cx+20, y}}, {pressure={0.22,0.22}, ramps={0.25,0.25}, shake=0})
end

--@ chunk 18
print(wait(3*24*60))
-- SECOND PASS. The sail rebuilt as a taut square membrane on four booms from a hub, seen from below.
HUB = {228, 168}
local C = {{-60,10},{310,-60},{482,104},{150,336}}
-- edges sag inward a little between boom tips (taut film)
local function edge(a, b, sag)
  local pts = {}
  local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
  local dx, dy = HUB[1]-mx, HUB[2]-my
  local L = math.sqrt(dx*dx+dy*dy)
  for k = 0, 10 do
    local t = k/10
    local s = sag * math.sin(math.pi*t)
    pts[#pts+1] = {lerp(a[1],b[1],t) + dx/L*s, lerp(a[2],b[2],t) + dy/L*s}
  end
  return pts
end
local outline = {}
for i = 1, 4 do
  local e = edge(C[i], C[i % 4 + 1], 14)
  for k = 1, #e - 1 do outline[#outline+1] = e[k] end
end
SAIL2 = poly(outline)
SAILC = C
-- paint out the old blob where the new sail doesn't reach
local K1 = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local old = (SAIL:grow(3) - SAIL2) * SKY
work(old, {hand="body", pile=K1, coverage=5, fill=true, clip=old, angle=0.15, tool="filbert 8", length={30,80}, load=1, pressure={0.75,0.95}})
-- mirror film: mostly the dark sky reflected, a glare of the Sun across the sunward half
local M1 = pile{{"bone black",1.2},{"ultramarine blue",1},{"lead white",0.5},{"cobalt blue",0.2}}
local M2 = pile{{"ultramarine ash",1},{"lead white",1.2},{"bone black",0.4},{"yellow ochre",0.2}}
local M3 = pile{{"lead white",2},{"yellow ochre",0.8},{"Mars orange",0.4}}
local M4 = pile{{"lead white",3},{"lemon chrome",0.25},{"zinc white",1}}
-- glare centred on a point up-left of the hub; banded by distance, laid with long straight strokes
local function g(x, y) return math.sqrt(((x-70)*0.8)^2 + ((y-70)*1.2)^2) end
local ang = -0.55
local function band(lo, hi, p)
  local m = SAIL2 * mask(function(x,y) local v = g(x,y); return smoothstep(lo-12, lo+12, v) * (1 - smoothstep(hi-12, hi+12, v)) end)
  work(m, {hand="body", pile=p, coverage=4.5, fill=true, clip=SAIL2, angle=ang, ruler=true, tool="flat 8", length={60,160}, load=1, pressure={0.7,0.95}, threshold=0.35})
end
band(250, 900, M1)
band(160, 250, M2)
band(75, 160, M3)
band(-50, 75, M4)

--@ chunk 19
print(wait(2*24*60))
-- paint out the old rigging and mast
local KK = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local ofoot = {252, hz(252) - 1}
for _, p in ipairs({{405,80},{372,160},{338,215},{270,245},{200,270},{120,298},{55,318}}) do
  local kb = brush{kind="round", width=3.2, point=0.3}
  kb:load(KK, 1)
  kb:stroke({p, {lerp(p[1],ofoot[1],0.5), lerp(p[2],ofoot[2],0.5) + 3}, ofoot}, {pressure={0.7, 0.7}, ramps={0.02, 0.02}, clip=SKY - SAIL2})
end
local kb = brush{kind="round", width=5, point=0.3}
kb:load(KK, 1); kb:stroke({ofoot, {250, 228}}, {pressure={0.8, 0.8}, ramps={0.02,0.02}, clip=SKY - SAIL2})
-- crisp edges: a bright hem where the film faces the Sun, a dark cut edge on the far side
local HEM = pile{{"lead white",3},{"lemon chrome",0.2}}
local DKE = pile{{"bone black",2},{"ultramarine blue",0.6}}
local C = SAILC
local function seg(a, b, p, w, pr)
  local br = brush{kind="round", width=w, point=0.8}
  local mx, my = (a[1]+b[1])/2, (a[2]+b[2])/2
  local dx, dy = HUB[1]-mx, HUB[2]-my
  local L = math.sqrt(dx*dx+dy*dy)
  local pts = {}
  for k = 0, 10 do local t = k/10; local s = 14*math.sin(math.pi*t); pts[#pts+1] = {lerp(a[1],b[1],t) + dx/L*s, lerp(a[2],b[2],t) + dy/L*s} end
  br:load(p, 1); br:stroke(pts, {pressure={pr, pr}, ramps={0.02, 0.02}, shake=0})
end
seg(C[2], C[3], HEM, 2.2, 0.5)
seg(C[3], C[4], DKE, 2.4, 0.55)
seg(C[4], C[1], HEM, 2, 0.45)
-- booms from the hub to each corner: dark spars with a sunlit edge
local BD = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.5}}
local BL = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.2}}
for _, c in ipairs(C) do
  local b = brush{kind="round", width=3.2, point=0.4}
  b:load(BD, 1); b:stroke({HUB, c}, {pressure={0.75, 0.45}, ramps={0.02, 0.02}, shake=0})
  local l = brush{kind="round", width=1.2, point=0.8}
  l:load(BL, 0.8); l:stroke({{HUB[1]-1.5, HUB[2]-1.5}, {c[1]-1.5, c[2]-1.5}}, {pressure={0.4, 0.25}, ramps={0.05, 0.1}, shake=0})
end
-- film seams: faint straight lines fanning from the hub to the edges
local SM = pile{{"ultramarine ash",1},{"lead white",0.8},{"bone black",0.3}}
local s = brush{kind="round", width=1, point=0.8}
for i = 1, 4 do
  local a, b = C[i], C[i % 4 + 1]
  for k = 1, 3 do
    local t = k/4
    s:load(SM, 0.5); s:stroke({HUB, {lerp(a[1],b[1],t), lerp(a[2],b[2],t)}}, {pressure={0.25, 0.3}, ramps={0.1, 0.1}, shake=0, clip=SAIL2})
  end
end
-- hub
local hb = brush{kind="round", width=8, point=0.2}
hb:load(BD, 1); hb:touch(HUB[1], HUB[2], {pressure=0.8})
hb = brush{kind="round", width=3, point=0.2}
hb:load(BL, 1); hb:touch(HUB[1]-2, HUB[2]-2, {pressure=0.6})
-- the mast: from the hub down to a real foot on the hull, with a footing block
MFOOT = {300, hz(300) + 6}
local mb = brush{kind="round", width=4, point=0.3}
mb:load(BD, 1); mb:stroke({HUB, MFOOT}, {pressure={0.6, 0.8}, ramps={0.02, 0.02}, shake=0})
local ml = brush{kind="round", width=1.3, point=0.8}
ml:load(BL, 0.8); ml:stroke({{HUB[1]-2, HUB[2]+4}, {MFOOT[1]-2.5, MFOOT[2]-6}}, {pressure={0.35, 0.3}, ramps={0.05, 0.1}, shake=0})
work(poly({{286, MFOOT[2]-6},{314, MFOOT[2]-6},{320, MFOOT[2]+6},{280, MFOOT[2]+6}}), {hand="detail", pile=BD, coverage=5, fill=true, angle=0})
ml:load(BL, 0.8); ml:stroke({{286, MFOOT[2]-6},{314, MFOOT[2]-6}}, {pressure={0.5,0.5}, shake=0})
-- rigging: from each corner down to the mast foot
local RG = pile{{"lead white",1.5},{"yellow ochre",0.5},{"raw sienna",0.3}}
for _, c in ipairs({C[3], C[4], {C[1][1]+60, C[1][2]+15}}) do
  local r = brush{kind="round", width=1.1, point=0.9}
  r:load(RG, 0.8)
  r:stroke({c, {lerp(c[1], MFOOT[1], 0.5), lerp(c[2], MFOOT[2], 0.5) + 4}, {MFOOT[1], MFOOT[2]-6}}, {pressure={0.3, 0.45}, ramps={0.05, 0.05}, shake=0})
end

--@ chunk 20
print(wait(4*24*60))
local KK = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local clean = (SKY - SAIL2:grow(2)) * poly({{-10,180},{420,90},{420,hz(420)-4},{-10,hz(0)-4}})
local keep = ribbon({HUB, MFOOT}, 7)
for _, c in ipairs({SAILC[3], SAILC[4], {SAILC[1][1]+60, SAILC[1][2]+15}}) do
  keep = keep + ribbon({c, {lerp(c[1], MFOOT[1], 0.5), lerp(c[2], MFOOT[2], 0.5) + 4}, {MFOOT[1], MFOOT[2]-6}}, 4)
end
clean = clean - keep - rect(270, hz(300)-12, 60, 30)
work(clean, {hand="body", pile=KK, coverage=4, fill=true, clip=clean, angle=0.2, tool="filbert 6", length={20,50}, load=1, pressure={0.7,0.9}})
-- booms restated solid over the dry film
local BD = pile{{"bone black",1.5},{"burnt sienna",0.6},{"ultramarine ash",0.5}}
local BL = pile{{"lead white",2},{"yellow ochre",0.6},{"Mars orange",0.2}}
for _, c in ipairs(SAILC) do
  local mid = {lerp(HUB[1], c[1], 0.5), lerp(HUB[2], c[2], 0.5)}
  local b = brush{kind="round", width=3, point=0.4}
  b:load(BD, 1); b:stroke({HUB, mid}, {pressure={0.75, 0.65}, ramps={0.02, 0.02}, shake=0})
  b:load(BD, 1); b:stroke({mid, c}, {pressure={0.65, 0.45}, ramps={0.02, 0.02}, shake=0})
  local l = brush{kind="round", width=1.2, point=0.8}
  l:load(BL, 0.9); l:stroke({{HUB[1]-1.6, HUB[2]-1.6}, {c[1]-1.6, c[2]-1.6}}, {pressure={0.4, 0.25}, ramps={0.05, 0.1}, shake=0})
end
local hb = brush{kind="round", width=8, point=0.2}
hb:load(BD, 1); hb:touch(HUB[1], HUB[2], {pressure=0.8})
local hl = brush{kind="round", width=3, point=0.2}
hl:load(BL, 1); hl:touch(HUB[1]-2, HUB[2]-2, {pressure=0.6})

--@ chunk 21
print(wait(2*24*60))
-- the hull replated: every plate its own size and patina; lit toward us, darkening to the horizon;
-- pools of lantern-warm and projection-cool on the plates round the two lamps
local staff = ribbon({{478,488},{481,380},{484,282}}, 6)
HCL = HULL - FIG:grow(1.5) - ARK:grow(1.5) - staff - rect(278, hz(300)-10, 46, 26)
local PB = {
 pile{{"bone black",1.4},{"burnt sienna",1},{"ultramarine blue",0.4}},
 pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.6}},
 pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.4},{"yellow ochre",0.3}},
 pile{{"raw sienna",1},{"yellow ochre",0.7},{"burnt sienna",0.5},{"bone black",0.2},{"lead white",0.25}},
 pile{{"yellow ochre",1},{"raw sienna",0.7},{"lead white",0.5},{"Mars orange",0.15}},
}
local VG = pile{{"viridian",0.6},{"raw sienna",0.8},{"bone black",0.4},{"lead white",0.4}}
local WARM = pile{{"yellow ochre",1},{"Mars orange",0.6},{"lead white",0.8},{"cadmium yellow",0.3}}
local COOL = pile{{"ultramarine ash",1},{"cerulean blue",0.4},{"lead white",0.8},{"raw sienna",0.3}}
local DK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
local LH = pile{{"lead white",2},{"yellow ochre",0.8},{"Mars orange",0.3}}
local LC = pile{{"zinc white",3},{"cerulean blue",1}}
local LW = pile{{"lead white",2},{"cadmium yellow",0.8},{"Mars orange",0.4}}
local LAN, RAT = {566, 419}, {650, 440}
local off = 12
while off < 290 do
  local wlip = 6 + off * 0.42
  local x = -10 - rand(0, wlip)
  while x < 1010 do
    local w = wlip * rand(0.7, 1.4)
    local y0 = hz(x + w/2) + off + randn(0, 0.8 + off*0.02)
    local dpt = w * rand(0.45, 0.6)
    local t = clamp(off / 240, 0, 1)
    local idx = clamp(math.floor(1 + t*4 + randn(0, 0.7) + 0.5), 1, 5)
    local p = PB[idx]
    if math.random() < 0.07 then p = VG end
    local cxp, cyp = x + w/2, y0 + dpt*0.3
    local dl = math.sqrt((cxp-LAN[1])^2 + ((cyp-LAN[2])*1.8)^2)
    local dr = math.sqrt((cxp-RAT[1])^2 + ((cyp-RAT[2])*1.8)^2)
    local lip = LH
    if dl < 85 and math.random() < 1 - dl/85 then p = WARM; lip = LW end
    if dr < 95 and math.random() < 1 - dr/95 then p = COOL; lip = LC end
    local b = brush{kind="filbert", width=math.max(3, dpt)}
    b:load(p, 0.9)
    b:stroke({{x + w*0.1, cyp - dpt*0.1}, {x + w*0.5, cyp + dpt*0.12}, {x + w*0.9, cyp - dpt*0.1}}, {pressure={0.65, 0.65}, ramps={0.15, 0.15}, orient="across", clip=HCL})
    local sag = w * rand(0.18, 0.28)
    local arc, lit = {}, {}
    for k = 0, 6 do local u = k/6; arc[#arc+1] = {x + w*u, y0 + dpt*0.75 + sag*math.sin(math.pi*u)} end
    for k = 1, 5 do local u = k/6; lit[#lit+1] = {x + w*u, y0 + dpt*0.75 - 1.5 - off*0.01 + sag*math.sin(math.pi*u)} end
    local d = brush{kind="round", width=1.6 + off*0.012, point=0.5}
    d:load(DK, 0.85); d:stroke(arc, {pressure={0.45, 0.45}, ramps={0.2, 0.2}, clip=HCL})
    local l = brush{kind="round", width=1.5 + off*0.008, point=0.8}
    l:load(lip, 0.35 + 0.5*t + ((lip ~= LH) and 0.3 or 0))
    l:stroke(lit, {pressure={0.2, 0.25 + 0.25*t}, ramps={0.3, 0.3}, clip=HCL})
    x = x + w * rand(0.85, 1.05)
  end
  off = off + 4 + off * rand(0.22, 0.34)
end

--@ chunk 22
print(wait(4*24*60))
print(drying(500,600), drying(300,470))
-- hull base repainted solid: dark at the horizon, lit toward us; pools of the two lamps
local function dy(x,y) return y - hz(x) end
local P1 = pile{{"bone black",1.6},{"burnt sienna",1},{"ultramarine blue",0.5}}
local P2 = pile{{"burnt sienna",1},{"bone black",1},{"raw sienna",0.5},{"ultramarine blue",0.2}}
local P3 = pile{{"raw sienna",1},{"burnt sienna",0.8},{"bone black",0.5},{"yellow ochre",0.2}}
local P4 = pile{{"raw sienna",1},{"yellow ochre",0.6},{"burnt sienna",0.6},{"bone black",0.25},{"lead white",0.15}}
local function bandm(lo, hi) return HCL * mask(function(x,y) local v = dy(x,y); return smoothstep(lo-8, lo+8, v) * (1 - smoothstep(hi-8, hi+8, v)) end) end
local o = {hand="body", coverage=4.5, fill=true, clip=HCL, angle=0.02, tool="filbert 7", length={20,50}, load=1, pressure={0.7,0.95}, threshold=0.3}
local function go(m, p) local t = {}; for k, v in pairs(o) do t[k] = v end; t.pile = p; work(m, t) end
go(bandm(-20, 40), P1)
go(bandm(40, 95), P2)
go(bandm(95, 160), P3)
go(bandm(160, 400), P4)
local WARM = pile{{"raw sienna",1},{"Mars orange",0.5},{"yellow ochre",0.6},{"burnt sienna",0.4},{"lead white",0.2}}
local COOL = pile{{"ultramarine ash",1},{"raw sienna",0.6},{"burnt sienna",0.3},{"lead white",0.35},{"cerulean blue",0.15}}
go(HCL * ellipse(566, 470, 55, 26):blur(10), WARM)
go(HCL * ellipse(652, 482, 70, 26):blur(10), COOL)

--@ chunk 23
print(wait(4*24*60))
-- Ratio's lower half and the Ark top were covered: keep them out of the plate pass
RATM = poly({{622,372},{678,372},{676,456},{624,456}})
local HC2 = HCL - RATM - ellipse(566, 419, 10, 14)
local DK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
local DK2 = pile{{"bone black",1.5},{"burnt sienna",0.8},{"raw sienna",0.3}}
local LH = pile{{"lead white",2},{"yellow ochre",0.8},{"Mars orange",0.3}}
local LM2 = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.7}}
local LW = pile{{"lead white",2},{"cadmium yellow",0.9},{"Mars orange",0.4}}
local LC = pile{{"zinc white",3},{"cerulean blue",1}}
local VG = pile{{"viridian",0.5},{"cerulean blue",0.3},{"lead white",1},{"raw sienna",0.5}}
local LAN, RAT = {566, 419}, {650, 440}
local off = 5
while off < 300 do
  local wbase = 6 + off * 0.45
  local x = -10 - rand(0, wbase)
  while x < 1010 do
    local w = wbase * rand(0.6, 1.5)
    local y0 = hz(x + w/2) + off + randn(0, 0.6 + off*0.025)
    local sag = w * rand(0.14, 0.32)
    local tilt = randn(0, 0.06) * w
    local near = clamp(off / 220, 0, 1)
    local cxp = x + w/2
    local dl = math.sqrt((cxp-LAN[1])^2 + ((y0-LAN[2]-20)*2.2)^2)
    local dr = math.sqrt((cxp-RAT[1])^2 + ((y0-RAT[2]-15)*2.2)^2)
    local arc, lit = {}, {}
    for k = 0, 6 do local u = k/6; arc[#arc+1] = {x + w*u, y0 + tilt*(u-0.5) + sag*math.sin(math.pi*u)} end
    local u0, u1 = rand(0.05, 0.3), rand(0.7, 0.95)
    for k = 0, 5 do local u = lerp(u0, u1, k/5); lit[#lit+1] = {x + w*u, y0 - 1.4 - off*0.012 + tilt*(u-0.5) + sag*math.sin(math.pi*u)} end
    local d = brush{kind="round", width=1.4 + off*0.016 + rand(0, 1), point=0.5}
    d:load(math.random() < 0.5 and DK or DK2, 0.85)
    d:stroke(arc, {pressure={0.45, 0.45}, ramps={0.2, 0.2}, clip=HC2})
    local p, ld = LM2, 0.25 + 0.55*near
    if near > 0.45 and math.random() < 0.6 then p = LH end
    if dl < 80 then p = LW; ld = 0.5 + 0.5*(1 - dl/80) end
    if dr < 90 then p = LC; ld = 0.45 + 0.5*(1 - dr/90) end
    if math.random() < 0.05 and dl > 80 and dr > 90 then p = VG; ld = 0.4 end
    if math.random() < 0.12 then ld = ld * 0.3 end
    local l = brush{kind="round", width=1.3 + off*0.01, point=0.8}
    l:load(p, ld)
    l:stroke(lit, {pressure={0.2, 0.2 + 0.3*near}, ramps={0.3, 0.3}, clip=HC2})
    x = x + w * rand(0.8, 1.05)
  end
  off = off + 3 + off * rand(0.2, 0.32)
end
-- Ratio's dress and legs restated
local SK = pile{{"zinc white",4},{"lead white",1.5},{"cerulean blue",0.15}}
local SK2 = pile{{"zinc white",3},{"lead white",1},{"cerulean blue",0.5}}
local DR = pile{{"zinc white",3},{"cerulean blue",0.9},{"cobalt blue",0.2}}
local HL = pile{{"cobalt blue",1},{"ultramarine blue",0.6},{"zinc white",0.9},{"cerulean blue",0.3}}
local HL2 = pile{{"cobalt blue",0.8},{"zinc white",1.4},{"cerulean blue",0.5}}
local function facet(pts, pp) work(poly(pts), {hand="detail", pile=pp, coverage=6, fill=true, angle=0, tool={kind="round", width=1.2}}) end
local cx, fy = 650, 452
local function P(pts) local o = {}; for i, q in ipairs(pts) do o[i] = {cx + q[1], fy + q[2]} end; return o end
facet(P({{14,-40},{19,-30},{14,-14},{9,-18},{9,-40}}), HL)
facet(P({{-14,-40},{-9,-40},{-9,-18},{-14,-14},{-19,-30}}), HL2)
facet(P({{0,-40},{0,-10},{-9,-10},{-5,-40}}), SK)
facet(P({{0,-40},{5,-40},{9,-10},{0,-10}}), SK2)
facet(P({{-5,-10},{-1,-10},{-1,-2},{-5,-2}}), DR); facet(P({{1,-10},{5,-10},{5,-2},{1,-2}}), SK2)

--@ chunk 24
print(wait(3*24*60))
local G1 = pile{{"bone black",2},{"ultramarine blue",0.5},{"burnt sienna",0.3}}
local G2 = pile{{"bone black",1.2},{"ultramarine ash",0.8},{"burnt sienna",0.4},{"lead white",0.25}}
local RIM = pile{{"lead white",2.5},{"yellow ochre",0.6},{"Mars orange",0.3}}
local WL = pile{{"Mars orange",1},{"cadmium yellow",0.8},{"lead white",1.2}}
local function seg(a, b, w0, w1)
  local m = ribbon({a, {lerp(a[1],b[1],0.5), lerp(a[2],b[2],0.5)}, b}, {w0, (w0+w1)/2, w1})
  work(m, {hand="detail", pile=G1, coverage=6, fill=true, angle=math.atan(b[2]-a[2], b[1]-a[1]), tool={kind="round", width=1.8}})
  return m
end
-- armoured right arm out of the cloak: pauldron, upper arm, elbow, forearm, gauntlet
local paul = poly({{540,338},{556,336},{568,348},{566,360},{548,356}}, true)
work(paul, {hand="detail", pile=G1, coverage=6, fill=true, angle=0.6, tool={kind="round", width=1.8}})
seg({558,352}, {570,384}, 11, 9)
seg({570,384}, {586,402}, 9, 8)
local fist = ellipse(588, 405, 6.5, 6)
work(fist, {hand="detail", pile=G1, coverage=6, fill=true, angle=0, tool={kind="round", width=1.6}})
-- plate breaks and lit edges
local r = brush{kind="round", width=1.8, point=0.8}
r:load(RIM, 0.9); r:stroke({{542,338},{556,335},{567,346}}, {pressure={0.4,0.3}, ramps={0.1,0.3}})
r:load(RIM, 0.7); r:stroke({{557,350},{562,364},{566,378}}, {pressure={0.3,0.2}, ramps={0.1,0.4}})
r:load(G2, 0.9); r:stroke({{563,383},{576,380}}, {pressure={0.4,0.4}})
r:load(RIM, 0.6); r:stroke({{569,382},{578,392},{585,398}}, {pressure={0.25,0.2}, ramps={0.1,0.4}})
-- lantern hanging from the gauntlet, its light on the underside of arm and fist
local LD = pile{{"bone black",1.5},{"burnt sienna",0.6}}
local LO = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
local LC = pile{{"lead white",3},{"lemon chrome",0.3},{"zinc white",1}}
local h = brush{kind="round", width=1.3, point=0.6}
h:load(LD, 0.9); h:stroke({{588,410},{588,415}}, {pressure={0.5,0.5}})
work(rect(581, 414, 15, 22), {hand="detail", pile=LD, coverage=5, fill=true, angle=0})
work(rect(584, 418, 9, 14), {hand="detail", pile=LO, coverage=5, fill=true, angle=0})
work(rect(586, 420, 5, 10), {hand="detail", pile=LC, coverage=6, fill=true, angle=0, tool={kind="round", width=1.2}})
r:load(WL, 0.8); r:stroke({{582,409},{588,412},{594,408}}, {pressure={0.3,0.3}})
r:load(WL, 0.6); r:stroke({{572,390},{580,400}}, {pressure={0.2,0.2}})
-- sensor: a short mast on the helmet with an amber tip, a visor slit glint on the helmet's side
local m = brush{kind="round", width=1.4, point=0.8}
m:load(G1, 1); m:stroke({{530,312},{536,292}}, {pressure={0.5,0.4}})
m:load(RIM, 0.8); m:stroke({{529.5,311},{535.5,293}}, {pressure={0.2,0.15}})
local t = brush{kind="round", width=3, point=0.2}
t:load(pile{{"vermilion",1},{"cadmium yellow",0.6},{"lead white",0.5}}, 1); t:touch(536.5, 291, {pressure=0.6})
m:load(pile{{"zinc white",2},{"cerulean blue",1}}, 0.9); m:stroke({{533,322},{537,326}}, {pressure={0.4,0.4}})
-- a cool rim from her light on his right flank and boots
local CR = pile{{"zinc white",2},{"cerulean blue",1.2}}
m:load(CR, 0.6); m:stroke({{556,400},{557,430},{556,452}}, {pressure={0.2,0.2}, ramps={0.2,0.4}})
m:load(CR, 0.6); m:stroke({{548,456},{549,472},{549,486}}, {pressure={0.2,0.15}, ramps={0.2,0.4}})

--@ chunk 25
-- sail: long ruler-straight glare streaks across the sunward film, smoothing its sheen
local M3 = pile{{"lead white",2},{"yellow ochre",0.7},{"Mars orange",0.3}}
local M4 = pile{{"lead white",3},{"lemon chrome",0.25},{"zinc white",1}}
local fb = brush{kind="flat", width=7}
local ang = -0.55
local ux, uy = math.cos(ang), math.sin(ang)
for i = 1, 26 do
  local cx, cy = randn(110, 70), randn(110, 55)
  if SAIL2:at(cx, cy) > 0.9 then
    local L = rand(60, 150)
    local g = math.sqrt(((cx-70)*0.8)^2 + ((cy-70)*1.2)^2)
    fb:load(g < 90 and M4 or M3, 0.7)
    fb:stroke({{cx - ux*L/2, cy - uy*L/2}, {cx + ux*L/2, cy + uy*L/2}}, {pressure={0.45, 0.45}, ramps={0.25, 0.35}, shake=0, orient="across", clip=SAIL2})
  end
end
-- the Sun's glare point on the film, hard and small
local t = brush{kind="round", width=10, point=0.2}
t:load(M4, 1); t:touch(64, 66, {pressure=0.8})
local s = brush{kind="round", width=2, point=1}
for _, a in ipairs({-0.55, 1.02, 2.59, 4.16}) do
  s:load(M4, 0.9); s:stroke({{64, 66}, {64 + 38*math.cos(a), 66 + 38*math.sin(a)}}, {pressure={0.5, 0.0}, ramps={0.02, 0.9}, clip=SAIL2})
end
-- lantern: hot core again and warm light on the nearest plate lips and the fist
local LC = pile{{"lead white",3},{"lemon chrome",0.3},{"zinc white",1}}
local WL = pile{{"lead white",2},{"cadmium yellow",0.9},{"Mars orange",0.4}}
local c = brush{kind="round", width=5, point=0.2}
c:load(LC, 1); c:touch(588.5, 425, {pressure=0.75})
local l = brush{kind="round", width=1.6, point=0.8}
for _, p in ipairs({{574,440,14},{596,438,12},{582,449,18},{604,452,10},{566,455,12}}) do
  l:load(WL, 0.9); l:stroke({{p[1]-p[3]/2, p[2]}, {p[1], p[2]+2}, {p[1]+p[3]/2, p[2]}}, {pressure={0.3, 0.35}, ramps={0.3, 0.3}})
end
l:load(WL, 0.8); l:stroke({{583,409},{588,411.5},{593,409}}, {pressure={0.35,0.35}})

--@ chunk 26
print(wait(2*24*60))
-- clean the old sail's flecks at the left edge
local KK = pile{{"bone black",2},{"ultramarine blue",1},{"burnt sienna",0.4}}
local fl = (rect(-10, -10, 60, 420) * SKY) - SAIL2:grow(3)
work(fl, {hand="body", pile=KK, coverage=4, fill=true, clip=fl, angle=0.2, tool="filbert 5", length={15,40}, load=1})
-- break the stripes between hull bands with dry broken colour, across the curve
local P2 = pile{{"burnt sienna",1},{"bone black",0.8},{"raw sienna",0.6}}
local P3 = pile{{"raw sienna",1},{"burnt sienna",0.7},{"bone black",0.4},{"yellow ochre",0.25}}
local function dy(x,y) return y - hz(x) end
for _, b in ipairs({{40, P2}, {95, P3}, {160, P3}}) do
  local m = HCL * mask(function(x,y) local v = dy(x,y) - b[1]; return 1 - smoothstep(6, 22, math.abs(v)) end)
  work(m, {hand="scumble", pile=b[2], coverage=1.4, load=0.3, pressure={0.2,0.4}, clip=HCL, tool="filbert 5", threshold=0.3})
end

--@ chunk 27
print(wait(3*24*60))
-- Ratio's lower half and the Ark top were covered: keep them out of the plate pass
RATM = poly({{622,372},{678,372},{676,456},{624,456}})
local HC2 = HCL - RATM - ellipse(566, 419, 10, 14)
local DK = pile{{"bone black",2},{"burnt sienna",0.6},{"ultramarine blue",0.5}}
local DK2 = pile{{"bone black",1.5},{"burnt sienna",0.8},{"raw sienna",0.3}}
local LH = pile{{"lead white",2},{"yellow ochre",0.8},{"Mars orange",0.3}}
local LM2 = pile{{"yellow ochre",1},{"burnt sienna",0.5},{"lead white",0.7}}
local LW = pile{{"lead white",2},{"cadmium yellow",0.9},{"Mars orange",0.4}}
local LC = pile{{"zinc white",3},{"cerulean blue",1}}
local VG = pile{{"viridian",0.5},{"cerulean blue",0.3},{"lead white",1},{"raw sienna",0.5}}
local LAN, RAT = {566, 419}, {650, 440}
local off = 5
while off < 300 do
  local wbase = 6 + off * 0.45
  local x = -10 - rand(0, wbase)
  while x < 1010 do
    local w = wbase * rand(0.6, 1.5)
    local y0 = hz(x + w/2) + off + randn(0, 0.6 + off*0.025)
    local sag = w * rand(0.14, 0.32)
    local tilt = randn(0, 0.06) * w
    local near = clamp(off / 220, 0, 1)
    local cxp = x + w/2
    local dl = math.sqrt((cxp-LAN[1])^2 + ((y0-LAN[2]-20)*2.2)^2)
    local dr = math.sqrt((cxp-RAT[1])^2 + ((y0-RAT[2]-15)*2.2)^2)
    local arc, lit = {}, {}
    for k = 0, 6 do local u = k/6; arc[#arc+1] = {x + w*u, y0 + tilt*(u-0.5) + sag*math.sin(math.pi*u)} end
    local u0, u1 = rand(0.05, 0.3), rand(0.7, 0.95)
    for k = 0, 5 do local u = lerp(u0, u1, k/5); lit[#lit+1] = {x + w*u, y0 - 1.4 - off*0.012 + tilt*(u-0.5) + sag*math.sin(math.pi*u)} end
    local d = brush{kind="round", width=1.4 + off*0.016 + rand(0, 1), point=0.5}
    d:load(math.random() < 0.5 and DK or DK2, 0.85)
    d:stroke(arc, {pressure={0.45, 0.45}, ramps={0.2, 0.2}, clip=HC2})
    local p, ld = LM2, 0.25 + 0.55*near
    if near > 0.45 and math.random() < 0.6 then p = LH end
    if dl < 80 then p = LW; ld = 0.5 + 0.5*(1 - dl/80) end
    if dr < 90 then p = LC; ld = 0.45 + 0.5*(1 - dr/90) end
    if math.random() < 0.05 and dl > 80 and dr > 90 then p = VG; ld = 0.4 end
    if math.random() < 0.12 then ld = ld * 0.3 end
    local l = brush{kind="round", width=1.3 + off*0.01, point=0.8}
    l:load(p, ld)
    l:stroke(lit, {pressure={0.2, 0.2 + 0.3*near}, ramps={0.3, 0.3}, clip=HC2})
    x = x + w * rand(0.8, 1.05)
  end
  off = off + 3 + off * rand(0.2, 0.32)
end

--@ chunk 28
local LD = pile{{"bone black",1.5},{"burnt sienna",0.6}}
local LO = pile{{"cadmium yellow",1},{"Mars orange",1},{"lead white",0.6}}
local LC = pile{{"lead white",3},{"lemon chrome",0.3},{"zinc white",1}}
local WL = pile{{"lead white",2},{"cadmium yellow",0.9},{"Mars orange",0.4}}
local CL = pile{{"zinc white",3},{"cerulean blue",1}}
work(rect(581, 414, 15, 22), {hand="detail", pile=LD, coverage=5, fill=true, angle=0})
work(rect(584, 418, 9, 14), {hand="detail", pile=LO, coverage=5, fill=true, angle=0})
work(rect(586, 420, 5, 10), {hand="detail", pile=LC, coverage=6, fill=true, angle=0, tool={kind="round", width=1.2}})
-- pools: lips catching each lamp, brighter and denser the closer they lie
local l = brush{kind="round", width=1.7, point=0.8}
local function pool(cx, cy, rx, ry, p, n)
  for i = 1, n do
    local a, r = rand(0, 2*math.pi), math.sqrt(rand(0, 1))
    local x, y = cx + r*rx*math.cos(a), cy + r*ry*math.sin(a)
    if FIG:at(x, y) < 0.3 and ARK:at(x, y) < 0.3 and RATM:at(x, y) < 0.3 and y > hz(x) + 3 then
      local w = 6 + (y - hz(x))*0.4
      l:load(p, 0.4 + 0.6*(1 - r))
      l:stroke({{x - w/2, y}, {x, y + w*0.2}, {x + w/2, y}}, {pressure={0.25 + 0.25*(1-r), 0.25 + 0.25*(1-r)}, ramps={0.3, 0.3}})
    end
  end
end
pool(590, 450, 60, 26, WL, 40)
pool(655, 485, 85, 28, CL, 45)
local c = brush{kind="round", width=5, point=0.2}
c:load(LC, 1); c:touch(588.5, 425, {pressure=0.75})
